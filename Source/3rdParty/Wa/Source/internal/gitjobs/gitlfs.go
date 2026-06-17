package gitjobs

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/format/gitattributes"
	"github.com/go-git/go-git/v5/plumbing/object"
)

const lfsPointerVersion = "https://git-lfs.github.com/spec/v1"

type lfsPointer struct {
	OID  string
	Size int64
}

type lfsBatchRequest struct {
	Operation string           `json:"operation"`
	Transfers []string         `json:"transfers,omitempty"`
	Ref       *lfsBatchRef     `json:"ref,omitempty"`
	Objects   []lfsBatchObject `json:"objects"`
}

type lfsBatchRef struct {
	Name string `json:"name"`
}

type lfsBatchObject struct {
	OID     string               `json:"oid"`
	Size    int64                `json:"size"`
	Actions map[string]lfsAction `json:"actions,omitempty"`
	Error   *lfsObjectError      `json:"error,omitempty"`
}

type lfsBatchResponse struct {
	Objects []lfsBatchObject `json:"objects"`
}

type lfsAction struct {
	Href   string            `json:"href"`
	Header map[string]string `json:"header,omitempty"`
}

type lfsObjectError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

const (
	lfsConcurrentTransfers = 3
	lfsBatchChunkSize      = 100
)

var lfsHTTPClient = &http.Client{
	Timeout: 30 * time.Minute,
	Transport: &http.Transport{
		Proxy:                 http.ProxyFromEnvironment,
		DialContext:           (&net.Dialer{Timeout: 30 * time.Second, KeepAlive: 30 * time.Second}).DialContext,
		TLSHandshakeTimeout:   10 * time.Second,
		ResponseHeaderTimeout: 60 * time.Second,
		MaxIdleConns:          10,
		MaxIdleConnsPerHost:   10,
		IdleConnTimeout:       90 * time.Second,
	},
}

func encodeLFSPointer(pointer lfsPointer) []byte {
	return []byte(fmt.Sprintf("version %s\noid sha256:%s\nsize %d\n", lfsPointerVersion, pointer.OID, pointer.Size))
}

func decodeLFSPointer(data []byte) (lfsPointer, bool) {
	if len(data) == 0 || len(data) >= 1024 {
		return lfsPointer{}, false
	}
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")
	if len(lines) != 3 || lines[0] != "version "+lfsPointerVersion || !strings.HasPrefix(lines[1], "oid sha256:") || !strings.HasPrefix(lines[2], "size ") {
		return lfsPointer{}, false
	}
	oid := strings.TrimPrefix(lines[1], "oid sha256:")
	if len(oid) != 64 {
		return lfsPointer{}, false
	}
	if _, err := hex.DecodeString(oid); err != nil {
		return lfsPointer{}, false
	}
	size, err := strconv.ParseInt(strings.TrimPrefix(lines[2], "size "), 10, 64)
	if err != nil || size < 0 {
		return lfsPointer{}, false
	}
	return lfsPointer{OID: oid, Size: size}, true
}

func lfsObjectPath(repoPath, oid string) string {
	return filepath.Join(repoPath, ".git", "lfs", "objects", oid[:2], oid[2:4], oid)
}

func cacheLFSFile(repoPath, path string) (lfsPointer, error) {
	sourcePath := filepath.Join(repoPath, filepath.Clean(path))
	source, err := os.Open(sourcePath)
	if err != nil {
		return lfsPointer{}, err
	}
	defer source.Close()
	info, err := source.Stat()
	if err != nil {
		return lfsPointer{}, err
	}
	hash := sha256.New()
	tempDir := filepath.Join(repoPath, ".git", "lfs", "tmp")
	if err := os.MkdirAll(tempDir, 0777); err != nil {
		return lfsPointer{}, err
	}
	temp, err := os.CreateTemp(tempDir, "object-*")
	if err != nil {
		return lfsPointer{}, err
	}
	tempPath := temp.Name()
	defer os.Remove(tempPath)
	if _, err := io.Copy(io.MultiWriter(temp, hash), source); err != nil {
		temp.Close()
		return lfsPointer{}, err
	}
	if err := temp.Close(); err != nil {
		return lfsPointer{}, err
	}
	oid := hex.EncodeToString(hash.Sum(nil))
	target := lfsObjectPath(repoPath, oid)
	if _, err := os.Stat(target); err == nil {
		return lfsPointer{OID: oid, Size: info.Size()}, nil
	} else if !os.IsNotExist(err) {
		return lfsPointer{}, err
	}
	if err := os.MkdirAll(filepath.Dir(target), 0777); err != nil {
		return lfsPointer{}, err
	}
	if err := os.Rename(tempPath, target); err != nil {
		return lfsPointer{}, err
	}
	return lfsPointer{OID: oid, Size: info.Size()}, nil
}

func lfsMatcher(repoPath string) (gitattributes.Matcher, bool, error) {
	_, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, false, err
	}
	patterns, err := gitattributes.ReadPatterns(worktree.Filesystem, nil)
	if err != nil {
		return nil, false, err
	}
	if len(patterns) == 0 {
		return nil, false, nil
	}
	return gitattributes.NewMatcher(patterns), true, nil
}

func isLFSTracked(matcher gitattributes.Matcher, path string) bool {
	parts := strings.Split(filepath.ToSlash(path), "/")
	attrs, matched := matcher.Match(parts, []string{"filter"})
	if !matched {
		lowered := make([]string, len(parts))
		for i, p := range parts {
			lowered[i] = strings.ToLower(p)
		}
		attrs, matched = matcher.Match(lowered, []string{"filter"})
	}
	if !matched {
		return false
	}
	attr, ok := attrs["filter"]
	return ok && attr.IsValueSet() && attr.Value() == "lfs"
}

func cleanLFSIndex(repoPath string) ([]string, error) {
	repo, _, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	matcher, enabled, err := lfsMatcher(repoPath)
	if err != nil || !enabled {
		return nil, err
	}
	idx, err := repo.Storer.Index()
	if err != nil {
		return nil, err
	}
	var cleaned []string
	for _, entry := range idx.Entries {
		if !isLFSTracked(matcher, entry.Name) {
			continue
		}
		indexData, err := readIndexFile(repo, entry.Name)
		if err == nil {
			if _, alreadyPointer := decodeLFSPointer(indexData); alreadyPointer {
				continue
			}
		}
		info, err := os.Stat(filepath.Join(repoPath, filepath.Clean(entry.Name)))
		if os.IsNotExist(err) {
			continue
		}
		if err != nil {
			return nil, err
		}
		if !info.Mode().IsRegular() {
			continue
		}
		pointer, err := cacheLFSFile(repoPath, entry.Name)
		if err != nil {
			return nil, err
		}
		pointerData := encodeLFSPointer(pointer)
		obj := repo.Storer.NewEncodedObject()
		obj.SetType(plumbing.BlobObject)
		obj.SetSize(int64(len(pointerData)))
		writer, err := obj.Writer()
		if err != nil {
			return nil, err
		}
		if _, err := writer.Write(pointerData); err != nil {
			writer.Close()
			return nil, err
		}
		if err := writer.Close(); err != nil {
			return nil, err
		}
		hash, err := repo.Storer.SetEncodedObject(obj)
		if err != nil {
			return nil, err
		}
		entry.Hash = hash
		entry.Size = uint32(len(pointerData))
		cleaned = append(cleaned, entry.Name)
	}
	if len(cleaned) != 0 {
		if err := repo.Storer.SetIndex(idx); err != nil {
			return nil, err
		}
	}
	return cleaned, nil
}

func normalizeLFSStatus(repoPath string, status git.Status) error {
	repo, _, err := openWorktree(repoPath)
	if err != nil {
		return err
	}
	matcher, enabled, err := lfsMatcher(repoPath)
	if err != nil || !enabled {
		return err
	}
	for path, fileStatus := range status {
		if fileStatus.Worktree == git.Unmodified || !isLFSTracked(matcher, path) {
			continue
		}
		pointerData, err := readIndexFile(repo, path)
		if err != nil {
			continue
		}
		pointer, ok := decodeLFSPointer(pointerData)
		if !ok {
			continue
		}
		actual, err := hashFile(filepath.Join(repoPath, filepath.Clean(path)))
		if err == nil && actual.OID == pointer.OID && actual.Size == pointer.Size {
			fileStatus.Worktree = git.Unmodified
		}
	}
	return nil
}

func dehydrateCleanLFSFiles(repoPath string) (map[string]lfsPointer, error) {
	repo, _, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	matcher, enabled, err := lfsMatcher(repoPath)
	if err != nil || !enabled {
		return nil, err
	}
	idx, err := repo.Storer.Index()
	if err != nil {
		return nil, err
	}
	dehydrated := map[string]lfsPointer{}
	for _, entry := range idx.Entries {
		if !isLFSTracked(matcher, entry.Name) {
			continue
		}
		indexData, err := readIndexFile(repo, entry.Name)
		if err != nil {
			continue
		}
		pointer, ok := decodeLFSPointer(indexData)
		if !ok {
			continue
		}
		actual, err := hashFile(filepath.Join(repoPath, filepath.Clean(entry.Name)))
		if err != nil || actual != pointer {
			continue
		}
		if err := os.WriteFile(filepath.Join(repoPath, filepath.Clean(entry.Name)), indexData, 0666); err != nil {
			return nil, err
		}
		dehydrated[entry.Name] = pointer
	}
	return dehydrated, nil
}

func rehydrateLFSFiles(repoPath string, files map[string]lfsPointer) error {
	for path, pointer := range files {
		if err := hydrateLFSFile(repoPath, path, pointer); err != nil {
			return err
		}
	}
	return nil
}

func hashFile(path string) (lfsPointer, error) {
	file, err := os.Open(path)
	if err != nil {
		return lfsPointer{}, err
	}
	defer file.Close()
	hash := sha256.New()
	size, err := io.Copy(hash, file)
	if err != nil {
		return lfsPointer{}, err
	}
	return lfsPointer{OID: hex.EncodeToString(hash.Sum(nil)), Size: size}, nil
}

func lfsPointersAtCommit(repo *git.Repository, hash plumbing.Hash) (map[string]lfsPointer, error) {
	commit, err := repo.CommitObject(hash)
	if err != nil {
		return nil, err
	}
	tree, err := commit.Tree()
	if err != nil {
		return nil, err
	}
	result := map[string]lfsPointer{}
	err = tree.Files().ForEach(func(file *object.File) error {
		if file.Size >= 1024 {
			return nil
		}
		reader, err := file.Reader()
		if err != nil {
			return err
		}
		data, err := io.ReadAll(reader)
		reader.Close()
		if err != nil {
			return err
		}
		if pointer, ok := decodeLFSPointer(data); ok {
			result[file.Name] = pointer
		}
		return nil
	})
	return result, err
}

func lfsPointersAtHead(repo *git.Repository) (map[string]lfsPointer, error) {
	head, err := repo.Head()
	if err != nil {
		return nil, err
	}
	return lfsPointersAtCommit(repo, head.Hash())
}

func lfsPointersReachable(repo *git.Repository, hash plumbing.Hash) (map[string]lfsPointer, error) {
	result := map[string]lfsPointer{}
	iter, err := repo.Log(&git.LogOptions{From: hash})
	if err != nil {
		if errors.Is(err, plumbing.ErrObjectNotFound) {
			return mergeLFSPointersAtCommit(repo, result, hash)
		}
		return result, err
	}
	defer iter.Close()
	visited := false
	err = iter.ForEach(func(commit *object.Commit) error {
		visited = true
		if _, err := mergeLFSPointersAtCommit(repo, result, commit.Hash); err != nil {
			return err
		}
		return nil
	})
	if errors.Is(err, plumbing.ErrObjectNotFound) {
		if visited {
			return result, nil
		}
		return mergeLFSPointersAtCommit(repo, result, hash)
	}
	return result, err
}

func mergeLFSPointersAtCommit(repo *git.Repository, result map[string]lfsPointer, hash plumbing.Hash) (map[string]lfsPointer, error) {
	pointers, err := lfsPointersAtCommit(repo, hash)
	if err != nil {
		return result, err
	}
	for _, pointer := range pointers {
		result[pointer.OID] = pointer
	}
	return result, nil
}

func lfsPointersForFetch(repo *git.Repository, remote string) (map[string]lfsPointer, error) {
	result := map[string]lfsPointer{}
	head, err := repo.Head()
	if errors.Is(err, plumbing.ErrReferenceNotFound) {
		err = nil
	} else if err != nil {
		return nil, err
	} else {
		pointers, err := lfsPointersReachable(repo, head.Hash())
		if err != nil {
			return nil, err
		}
		for oid, pointer := range pointers {
			result[oid] = pointer
		}
	}
	iter, err := repo.References()
	if err != nil {
		return nil, err
	}
	defer iter.Close()
	err = iter.ForEach(func(ref *plumbing.Reference) error {
		if !strings.HasPrefix(ref.Name().String(), "refs/remotes/"+remote+"/") || strings.HasSuffix(ref.Name().String(), "/HEAD") {
			return nil
		}
		pointers, err := lfsPointersReachable(repo, ref.Hash())
		if err != nil {
			return err
		}
		for oid, pointer := range pointers {
			result[oid] = pointer
		}
		return nil
	})
	return result, err
}

func fetchLFS(ctx context.Context, j *job, repoPath, remote string, hydrate, allRemote bool) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, err
	}
	var pointers map[string]lfsPointer
	if allRemote {
		pointers, err = lfsPointersForFetch(repo, remote)
	} else {
		pointers, err = lfsPointersAtHead(repo)
	}
	if errors.Is(err, plumbing.ErrReferenceNotFound) {
		return map[string]any{"objects": 0}, nil
	}
	if err != nil || len(pointers) == 0 {
		return map[string]any{"objects": 0}, err
	}
	unique := uniqueLFSPointers(pointers)
	missing := make([]lfsBatchObject, 0, len(unique))
	for _, pointer := range unique {
		if validLFSObject(repoPath, pointer) {
			continue
		}
		missing = append(missing, lfsBatchObject{OID: pointer.OID, Size: pointer.Size})
	}
	var downloaded int
	if len(missing) != 0 {
		j.setProgressMessage("downloading LFS objects")
		var batchObjects []lfsBatchObject
		for chunkStart := 0; chunkStart < len(missing); chunkStart += lfsBatchChunkSize {
			chunkEnd := chunkStart + lfsBatchChunkSize
			if chunkEnd > len(missing) {
				chunkEnd = len(missing)
			}
			objects, batchErr := requestLFSBatch(ctx, repo, remote, "download", missing[chunkStart:chunkEnd], j.req.cmd.options)
			if batchErr != nil {
				return nil, batchErr
			}
			batchObjects = append(batchObjects, objects...)
		}
		var toDownload []lfsBatchObject
		for _, object := range batchObjects {
			if object.Error != nil {
				return nil, fmt.Errorf("LFS object %s: %s", object.OID, object.Error.Message)
			}
			if _, ok := object.Actions["download"]; ok {
				toDownload = append(toDownload, object)
			}
		}
		n, dlErr := downloadLFSObjectsConcurrent(ctx, repo, remote, repoPath, toDownload, j.req.cmd.options, func(done, total int) {
			j.setProgressMessage(fmt.Sprintf("downloading LFS objects %d/%d", done, total))
		})
		if dlErr != nil {
			return nil, dlErr
		}
		downloaded = n
	}
	if hydrate {
		j.setProgressMessage("checking out LFS objects")
		for path, pointer := range pointers {
			if err := hydrateLFSFile(repoPath, path, pointer); err != nil {
				return nil, err
			}
		}
	}
	return map[string]any{"objects": len(unique), "downloaded": downloaded, "hydrated": hydrate}, nil
}

func pushLFS(ctx context.Context, j *job, repoPath, remote, branch string) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, err
	}
	var pointers map[string]lfsPointer
	if branch == "" {
		head, headErr := repo.Head()
		if headErr != nil {
			return nil, headErr
		}
		pointers, err = lfsPointersReachable(repo, head.Hash())
	} else {
		ref, refErr := repo.Reference(plumbingBranch(branch), true)
		if refErr != nil {
			return nil, refErr
		}
		pointers, err = lfsPointersReachable(repo, ref.Hash())
	}
	if errors.Is(err, plumbing.ErrReferenceNotFound) {
		return map[string]any{"objects": 0}, nil
	}
	if err != nil || len(pointers) == 0 {
		return map[string]any{"objects": 0}, err
	}
	objects := make([]lfsBatchObject, 0)
	for _, pointer := range uniqueLFSPointers(pointers) {
		if !validLFSObject(repoPath, pointer) {
			return nil, fmt.Errorf("missing local LFS object %s", pointer.OID)
		}
		objects = append(objects, lfsBatchObject{OID: pointer.OID, Size: pointer.Size})
	}
	j.setProgressMessage("uploading LFS objects")
	var batchObjects []lfsBatchObject
	for chunkStart := 0; chunkStart < len(objects); chunkStart += lfsBatchChunkSize {
		chunkEnd := chunkStart + lfsBatchChunkSize
		if chunkEnd > len(objects) {
			chunkEnd = len(objects)
		}
		batch, batchErr := requestLFSBatch(ctx, repo, remote, "upload", objects[chunkStart:chunkEnd], j.req.cmd.options)
		if batchErr != nil {
			return nil, batchErr
		}
		batchObjects = append(batchObjects, batch...)
	}
	var toUpload []lfsBatchObject
	var toVerify []lfsBatchObject
	for _, object := range batchObjects {
		if object.Error != nil {
			return nil, fmt.Errorf("LFS object %s: %s", object.OID, object.Error.Message)
		}
		if _, ok := object.Actions["upload"]; ok {
			toUpload = append(toUpload, object)
			if _, ok := object.Actions["verify"]; ok {
				toVerify = append(toVerify, object)
			}
		}
	}
	uploaded, ulErr := uploadLFSObjectsConcurrent(ctx, repo, remote, repoPath, toUpload, j.req.cmd.options, func(done, total int) {
		j.setProgressMessage(fmt.Sprintf("uploading LFS objects %d/%d", done, total))
	})
	if ulErr != nil {
		return nil, ulErr
	}
	for _, object := range toVerify {
		if err := verifyLFSObject(ctx, repo, remote, object, object.Actions["verify"], j.req.cmd.options); err != nil {
			return nil, err
		}
	}
	return map[string]any{"objects": len(objects), "uploaded": uploaded}, nil
}

func downloadLFSObjectsConcurrent(ctx context.Context, repo *git.Repository, remote, repoPath string, objects []lfsBatchObject, options runOptions, progress func(done, total int)) (int, error) {
	total := len(objects)
	var (
		completed atomic.Int32
		firstErr  error
		errOnce   sync.Once
		failed    atomic.Bool
		wg        sync.WaitGroup
	)
	sem := make(chan struct{}, lfsConcurrentTransfers)
	for _, obj := range objects {
		if failed.Load() {
			break
		}
		wg.Add(1)
		obj := obj
		go func() {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()
			if failed.Load() || ctx.Err() != nil {
				return
			}
			if err := downloadLFSObject(ctx, repo, remote, repoPath, obj, obj.Actions["download"], options); err != nil {
				errOnce.Do(func() { firstErr = err })
				failed.Store(true)
				return
			}
			done := int(completed.Add(1))
			progress(done, total)
		}()
	}
	wg.Wait()
	if firstErr != nil {
		return int(completed.Load()), firstErr
	}
	return int(completed.Load()), ctx.Err()
}

func uploadLFSObjectsConcurrent(ctx context.Context, repo *git.Repository, remote, repoPath string, objects []lfsBatchObject, options runOptions, progress func(done, total int)) (int, error) {
	total := len(objects)
	var (
		completed atomic.Int32
		firstErr  error
		errOnce   sync.Once
		failed    atomic.Bool
		wg        sync.WaitGroup
	)
	sem := make(chan struct{}, lfsConcurrentTransfers)
	for _, obj := range objects {
		if failed.Load() {
			break
		}
		wg.Add(1)
		obj := obj
		go func() {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()
			if failed.Load() || ctx.Err() != nil {
				return
			}
			if err := uploadLFSObject(ctx, repo, remote, repoPath, obj, obj.Actions["upload"], options); err != nil {
				errOnce.Do(func() { firstErr = err })
				failed.Store(true)
				return
			}
			done := int(completed.Add(1))
			progress(done, total)
		}()
	}
	wg.Wait()
	if firstErr != nil {
		return int(completed.Load()), firstErr
	}
	return int(completed.Load()), ctx.Err()
}

func uniqueLFSPointers(paths map[string]lfsPointer) map[string]lfsPointer {
	result := map[string]lfsPointer{}
	for _, pointer := range paths {
		result[pointer.OID] = pointer
	}
	return result
}

func validLFSObject(repoPath string, pointer lfsPointer) bool {
	actual, err := hashFile(lfsObjectPath(repoPath, pointer.OID))
	return err == nil && actual == pointer
}

func hydrateLFSFile(repoPath, path string, pointer lfsPointer) error {
	if err := validateRelativeGitPath(path); err != nil {
		return err
	}
	source, err := os.Open(lfsObjectPath(repoPath, pointer.OID))
	if err != nil {
		return err
	}
	defer source.Close()
	targetPath := filepath.Join(repoPath, filepath.Clean(path))
	if err := os.MkdirAll(filepath.Dir(targetPath), 0777); err != nil {
		return err
	}
	target, err := os.OpenFile(targetPath, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0666)
	if err != nil {
		return err
	}
	_, copyErr := io.Copy(target, source)
	closeErr := target.Close()
	if copyErr != nil {
		return copyErr
	}
	return closeErr
}

func requestLFSBatch(ctx context.Context, repo *git.Repository, remote, operation string, objects []lfsBatchObject, options runOptions) ([]lfsBatchObject, error) {
	endpoint, err := lfsEndpoint(repo, remote)
	if err != nil {
		return nil, err
	}
	refName := ""
	if head, err := repo.Head(); err == nil {
		refName = head.Name().String()
	}
	body, err := json.Marshal(lfsBatchRequest{
		Operation: operation,
		Transfers: []string{"basic"},
		Ref:       &lfsBatchRef{Name: refName},
		Objects:   objects,
	})
	if err != nil {
		return nil, err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, strings.TrimRight(endpoint, "/")+"/objects/batch", bytes.NewReader(body))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/vnd.git-lfs+json")
	req.Header.Set("Content-Type", "application/vnd.git-lfs+json")
	applyLFSAuth(req, safeLFSOptions(repo, remote, endpoint, options))
	res, err := lfsHTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		data, _ := io.ReadAll(io.LimitReader(res.Body, 4096))
		return nil, fmt.Errorf("LFS batch request failed: HTTP %d: %s", res.StatusCode, strings.TrimSpace(string(data)))
	}
	var decoded lfsBatchResponse
	if err := json.NewDecoder(res.Body).Decode(&decoded); err != nil {
		return nil, err
	}
	return decoded.Objects, nil
}

func lfsEndpoint(repo *git.Repository, remote string) (string, error) {
	cfg, err := repo.Config()
	if err != nil {
		return "", err
	}
	if cfg.Raw != nil {
		if value := cfg.Raw.Section("lfs").Option("url"); value != "" {
			return strings.TrimRight(value, "/"), nil
		}
	}
	if worktree, err := repo.Worktree(); err == nil {
		if data, err := os.ReadFile(filepath.Join(worktree.Filesystem.Root(), ".lfsconfig")); err == nil {
			lfsCfg := config.NewConfig()
			if err := lfsCfg.Unmarshal(data); err == nil && lfsCfg.Raw != nil {
				if value := lfsCfg.Raw.Section("lfs").Option("url"); value != "" {
					return strings.TrimRight(value, "/"), nil
				}
			}
		}
	}
	remoteCfg := cfg.Remotes[remote]
	if remoteCfg == nil || len(remoteCfg.URLs) == 0 {
		return "", fmt.Errorf("remote %q has no URL", remote)
	}
	raw := remoteCfg.URLs[0]
	parsed, err := url.Parse(raw)
	if err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") {
		return "", fmt.Errorf("LFS requires an HTTPS remote or lfs.url configuration")
	}
	path := strings.TrimSuffix(parsed.Path, "/")
	if !strings.HasSuffix(path, ".git") {
		path += ".git"
	}
	parsed.Path = path + "/info/lfs"
	parsed.RawQuery = ""
	parsed.Fragment = ""
	return parsed.String(), nil
}

func firstRemoteName(repo *git.Repository) string {
	cfg, err := repo.Config()
	if err != nil {
		return "origin"
	}
	if _, ok := cfg.Remotes["origin"]; ok {
		return "origin"
	}
	for name := range cfg.Remotes {
		return name
	}
	return "origin"
}

func downloadLFSObject(ctx context.Context, repo *git.Repository, remote, repoPath string, object lfsBatchObject, action lfsAction, options runOptions) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, action.Href, nil)
	if err != nil {
		return err
	}
	applyActionHeaders(req, action, safeLFSOptions(repo, remote, action.Href, options))
	res, err := lfsHTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return fmt.Errorf("LFS download %s failed: HTTP %d", object.OID, res.StatusCode)
	}
	tempDir := filepath.Join(repoPath, ".git", "lfs", "tmp")
	if err := os.MkdirAll(tempDir, 0777); err != nil {
		return err
	}
	temp, err := os.CreateTemp(tempDir, "download-*")
	if err != nil {
		return err
	}
	tempPath := temp.Name()
	defer os.Remove(tempPath)
	hash := sha256.New()
	size, err := io.Copy(io.MultiWriter(temp, hash), res.Body)
	if closeErr := temp.Close(); err == nil {
		err = closeErr
	}
	if err != nil {
		return err
	}
	if size != object.Size || hex.EncodeToString(hash.Sum(nil)) != object.OID {
		return fmt.Errorf("LFS download %s failed integrity check", object.OID)
	}
	target := lfsObjectPath(repoPath, object.OID)
	if err := os.MkdirAll(filepath.Dir(target), 0777); err != nil {
		return err
	}
	return os.Rename(tempPath, target)
}

func uploadLFSObject(ctx context.Context, repo *git.Repository, remote, repoPath string, object lfsBatchObject, action lfsAction, options runOptions) error {
	file, err := os.Open(lfsObjectPath(repoPath, object.OID))
	if err != nil {
		return err
	}
	defer file.Close()
	req, err := http.NewRequestWithContext(ctx, http.MethodPut, action.Href, file)
	if err != nil {
		return err
	}
	req.ContentLength = object.Size
	applyActionHeaders(req, action, safeLFSOptions(repo, remote, action.Href, options))
	res, err := lfsHTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return fmt.Errorf("LFS upload %s failed: HTTP %d", object.OID, res.StatusCode)
	}
	return nil
}

func verifyLFSObject(ctx context.Context, repo *git.Repository, remote string, object lfsBatchObject, action lfsAction, options runOptions) error {
	body, err := json.Marshal(lfsBatchObject{OID: object.OID, Size: object.Size})
	if err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, action.Href, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/vnd.git-lfs+json")
	applyActionHeaders(req, action, safeLFSOptions(repo, remote, action.Href, options))
	res, err := lfsHTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer res.Body.Close()
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return fmt.Errorf("LFS verify %s failed: HTTP %d", object.OID, res.StatusCode)
	}
	return nil
}

func applyActionHeaders(req *http.Request, action lfsAction, options runOptions) {
	for key, value := range action.Header {
		req.Header.Set(key, value)
	}
	if req.Header.Get("Authorization") == "" {
		applyLFSAuth(req, options)
	}
}

func applyLFSAuth(req *http.Request, options runOptions) {
	auth := options.Auth
	switch strings.ToLower(auth.Type) {
	case "basic":
		if auth.Username != "" || auth.Password != "" {
			req.SetBasicAuth(auth.Username, auth.Password)
		}
	case "token":
		if auth.Token != "" {
			req.SetBasicAuth(firstNonEmpty(auth.Username, "token"), auth.Token)
		}
	}
}

func safeLFSOptions(repo *git.Repository, remote, target string, options runOptions) runOptions {
	cfg, err := repo.Config()
	if err != nil {
		return runOptions{}
	}
	remoteCfg := cfg.Remotes[remote]
	if remoteCfg == nil || len(remoteCfg.URLs) == 0 {
		return runOptions{}
	}
	remoteURL, remoteErr := url.Parse(remoteCfg.URLs[0])
	targetURL, targetErr := url.Parse(target)
	if remoteErr != nil || targetErr != nil || remoteURL.Host == "" || !strings.EqualFold(remoteURL.Host, targetURL.Host) {
		return runOptions{}
	}
	return options
}
