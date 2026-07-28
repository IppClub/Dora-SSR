package gitjobs

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
)

func execVerifyUpdate(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, fmt.Errorf("open update repository: %w", err)
	}
	commitHash := plumbing.NewHash(cmd.commitHash)
	commit, err := repo.CommitObject(commitHash)
	if err != nil {
		return nil, fmt.Errorf("update commit %s is unavailable: %w", cmd.commitHash, err)
	}
	fingerprint, err := verifyCommitSignature(commit, trustedUpdaterReleaseKeys, "update")
	if err != nil {
		return nil, err
	}
	descendant := true
	if cmd.target != "" {
		descendant, err = isCommitAncestor(repo, plumbing.NewHash(cmd.target), commitHash)
		if err != nil {
			return nil, fmt.Errorf("failed to verify update history: %w", err)
		}
		if !descendant {
			return nil, fmt.Errorf("update commit %s is not a descendant of last-known-good %s", cmd.commitHash, cmd.target)
		}
	}
	return map[string]any{
		"commit":     cmd.commitHash,
		"previous":   cmd.target,
		"descendant": descendant,
		"signer":     fingerprint,
	}, nil
}

func execVerifyUpdatePackage(repoPath string, cmd gitCommand) (map[string]any, error) {
	if len(cmd.paths) != 1 {
		return nil, fmt.Errorf("update package path is required")
	}
	relative := filepath.Clean(filepath.FromSlash(cmd.paths[0]))
	if relative == "." || filepath.IsAbs(relative) || relative == ".." ||
		strings.HasPrefix(relative, ".."+string(filepath.Separator)) {
		return nil, fmt.Errorf("update package path must stay inside the repository")
	}
	root, err := filepath.Abs(repoPath)
	if err != nil {
		return nil, err
	}
	target := filepath.Join(root, relative)
	info, err := os.Lstat(target)
	if err != nil {
		return nil, fmt.Errorf("read update package: %w", err)
	}
	if !info.Mode().IsRegular() {
		return nil, fmt.Errorf("update package must be a regular file")
	}
	if info.Size() != cmd.expectedSize {
		return nil, fmt.Errorf("update package size mismatch: expected %d, got %d", cmd.expectedSize, info.Size())
	}
	file, err := os.Open(target)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		return nil, err
	}
	actual := hex.EncodeToString(hash.Sum(nil))
	if actual != cmd.expectedHash {
		return nil, fmt.Errorf("update package SHA-256 mismatch: expected %s, got %s", cmd.expectedHash, actual)
	}
	return map[string]any{
		"path":   filepath.ToSlash(relative),
		"size":   info.Size(),
		"sha256": actual,
	}, nil
}
