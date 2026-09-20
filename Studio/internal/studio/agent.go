package studio

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/big"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

type AgentConfig struct {
	StudioOrigin string `json:"parentOrigin"`
	HostOrigin   string `json:"-"`
	AccountID    string `json:"accountId"`
	ProjectID    string `json:"projectId"`
	Generation   string `json:"generation"`
	ProjectRoot  string `json:"projectRoot"`
	Title        string `json:"title"`
	Version      int    `json:"version"`
}
type AgentFile struct {
	Path  string
	Bytes []byte
}
type AgentSnapshot struct {
	Config   AgentConfig
	Manifest map[string]any
	Files    []AgentFile
}
type launchEntry struct {
	Snapshot         AgentSnapshot
	Created, Expires time.Time
	Bytes            int64
}
type modelWaiter struct {
	launchID string
	intent   ModelIntent
	queuedAt time.Time
}

var (
	errQueueFull    = errors.New("model queue full")
	errQueueTimeout = errors.New("model queue timeout")
	errQueueClosed  = errors.New("model queue closed")
)

type AgentService struct {
	mu                                      sync.Mutex
	store                                   *Store
	studioOrigin, hostOrigin, engineVersion string
	assets                                  map[string][]byte
	supportDir                              string
	launches                                map[string]*launchEntry
	maxEntries                              int
	maxBytes, usedBytes                     int64
	client                                  *http.Client
	closed                                  bool
	waiters                                 []*modelWaiter
}

func NewAgentService(store *Store, studioOrigin, hostOrigin, engineDir, supportDir string) (*AgentService, error) {
	if studioOrigin == hostOrigin || !strings.HasPrefix(hostOrigin, "https://") {
		return nil, errors.New("agent host origin must be distinct HTTPS origin")
	}
	a := &AgentService{store: store, studioOrigin: studioOrigin, hostOrigin: hostOrigin, supportDir: supportDir, launches: map[string]*launchEntry{}, assets: map[string][]byte{}, maxEntries: 32, maxBytes: 64 << 20, client: &http.Client{Timeout: 10 * time.Minute}}
	if err := a.loadAssets(engineDir); err != nil {
		return nil, err
	}
	return a, nil
}

func (a *AgentService) loadAssets(engineDir string) error {
	manifestRaw, err := os.ReadFile(filepath.Join(a.supportDir, "manifest.json"))
	if err != nil {
		return err
	}
	var support struct {
		Kind     string          `json:"kind"`
		Requires map[string]bool `json:"requires"`
		Files    []struct {
			Path, SHA256 string
			Size         int64
		}
	}
	if err = json.Unmarshal(manifestRaw, &support); err != nil {
		return err
	}
	if support.Kind != "dora-studio-agent-host-support" || !support.Requires["studioAgentHost"] || !support.Requires["separateOrigin"] {
		return errors.New("invalid agent support build")
	}
	allowed := []string{"index.html", "page.js", "compiler/worker.js", "compiler/typescript.js", "compiler/compile-worker.js", "declarations/Dora.d.ts", "declarations/es6-subset.d.ts", "declarations/lua.d.ts", "declarations/jsx.d.ts", "declarations/lualib_bundle.lua", "teal/api.js", "teal/worker.mjs", "teal/compiler.mjs", "teal/declarations.json", "yarn/worker.mjs", "yarn/compiler.mjs"}
	entries := map[string]struct {
		Hash string
		Size int64
	}{}
	for _, f := range support.Files {
		entries[f.Path] = struct {
			Hash string
			Size int64
		}{f.SHA256, f.Size}
	}
	for _, name := range allowed {
		b, err := os.ReadFile(filepath.Join(a.supportDir, filepath.FromSlash(name)))
		if err != nil {
			return err
		}
		e, ok := entries[name]
		sum := sha256.Sum256(b)
		if !ok || int64(len(b)) != e.Size || hex.EncodeToString(sum[:]) != e.Hash {
			return fmt.Errorf("agent support integrity failed: %s", name)
		}
		a.assets[name] = b
	}
	engine := []string{"dora-player-runtime.js", "dora-player-runtime.wasm", "dora-player-runtime.data", "dora-web-features.json", "audio-worklet.js", "dora-audio-mixer.wasm"}
	for _, name := range engine {
		b, err := os.ReadFile(filepath.Join(engineDir, name))
		if err != nil {
			return err
		}
		if len(b) == 0 {
			return fmt.Errorf("empty agent asset: %s", name)
		}
		a.assets[name] = b
	}
	var features map[string]any
	if err = json.Unmarshal(a.assets["dora-web-features.json"], &features); err != nil || features["studioAgentHost"] != true || features["activeProfile"] != "dora-preset" {
		return errors.New("not a dedicated agent engine")
	}
	raw, err := os.ReadFile(filepath.Join(engineDir, "dora-web-manifest.json"))
	if err != nil {
		return err
	}
	var m map[string]any
	if err = json.Unmarshal(raw, &m); err != nil {
		return err
	}
	a.engineVersion, _ = m["engineVersion"].(string)
	if a.engineVersion == "" {
		return errors.New("invalid engine manifest")
	}
	return nil
}

func (a *AgentService) Close() {
	a.mu.Lock()
	defer a.mu.Unlock()
	a.closed = true
	a.launches = map[string]*launchEntry{}
	a.usedBytes = 0
}
func (a *AgentService) expireLocked(now time.Time) {
	for id, e := range a.launches {
		if !e.Expires.After(now) {
			delete(a.launches, id)
			a.usedBytes -= e.Bytes
		}
	}
}
func (a *AgentService) get(id string) (AgentSnapshot, bool) {
	a.mu.Lock()
	defer a.mu.Unlock()
	a.expireLocked(time.Now())
	e, ok := a.launches[id]
	if !ok {
		return AgentSnapshot{}, false
	}
	return cloneSnapshot(e.Snapshot), true
}
func cloneSnapshot(s AgentSnapshot) AgentSnapshot {
	b, _ := json.Marshal(s.Config)
	var c AgentConfig
	json.Unmarshal(b, &c)
	mraw, _ := json.Marshal(s.Manifest)
	var m map[string]any
	json.Unmarshal(mraw, &m)
	files := make([]AgentFile, len(s.Files))
	for i, f := range s.Files {
		files[i] = AgentFile{Path: f.Path, Bytes: append([]byte{}, f.Bytes...)}
	}
	return AgentSnapshot{Config: c, Manifest: m, Files: files}
}

func (a *AgentService) put(s AgentSnapshot) (string, time.Time, error) {
	id, err := randomUUID()
	if err != nil {
		return "", time.Time{}, err
	}
	raw, _ := json.Marshal(struct {
		C AgentConfig
		M map[string]any
	}{s.Config, s.Manifest})
	size := int64(len(raw))
	for _, f := range s.Files {
		size += int64(len(f.Path) + len(f.Bytes))
	}
	a.mu.Lock()
	defer a.mu.Unlock()
	a.expireLocked(time.Now())
	if a.closed {
		return "", time.Time{}, errors.New("closed")
	}
	if len(a.launches) >= a.maxEntries || a.usedBytes+size > a.maxBytes {
		return "", time.Time{}, errQuota
	}
	now := time.Now()
	expires := now.Add(5 * time.Minute)
	a.launches[id] = &launchEntry{Snapshot: cloneSnapshot(s), Created: now, Expires: expires, Bytes: size}
	a.usedBytes += size
	return id, expires, nil
}

func (a *AgentService) createSnapshot(c AgentConfig) (AgentSnapshot, error) {
	raw, err := os.ReadFile(filepath.Join(a.supportDir, "manifest.json"))
	if err != nil {
		return AgentSnapshot{}, err
	}
	var support struct {
		Files []struct {
			Path, SHA256 string
			Size         int64
		}
	}
	if err = json.Unmarshal(raw, &support); err != nil {
		return AgentSnapshot{}, err
	}
	files := []AgentFile{}
	seen := map[string]bool{}
	for _, f := range support.Files {
		if _, static := a.assets[f.Path]; static || strings.HasPrefix(f.Path, "declarations/") {
			continue
		}
		allowed := f.Path == "AgentHostSession.lua" || f.Path == "AgentSessionBridge.lua" || f.Path == "StudioAgentEntry.lua" || f.Path == "StudioAgentYueBuild.lua" || f.Path == "StudioAgentXmlBuild.lua" || f.Path == "lua/Utils.lua" || strings.HasPrefix(f.Path, "lua/Agent/") || f.Path == "lua/DoraX.lua" || f.Path == "lua/lualib_bundle.lua" || strings.HasPrefix(f.Path, "docs/")
		if !allowed {
			continue
		}
		b, err := os.ReadFile(filepath.Join(a.supportDir, filepath.FromSlash(f.Path)))
		if err != nil {
			return AgentSnapshot{}, err
		}
		sum := sha256.Sum256(b)
		if int64(len(b)) != f.Size || hex.EncodeToString(sum[:]) != f.SHA256 {
			return AgentSnapshot{}, errors.New("agent support integrity mismatch")
		}
		if strings.HasPrefix(f.Path, "docs/") {
			var bundle struct {
				Version   int    `json:"version"`
				Language  string `json:"language"`
				Documents []struct{ Path, Text string }
			}
			if json.Unmarshal(b, &bundle) != nil || bundle.Version != 1 || len(bundle.Documents) > 4096 {
				return AgentSnapshot{}, errors.New("invalid agent document bundle")
			}
			language := "en"
			if bundle.Language == "zh" {
				language = "zh-Hans"
			} else if bundle.Language != "en" {
				return AgentSnapshot{}, errors.New("invalid agent document language")
			}
			for _, document := range bundle.Documents {
				prefix := "@dora-doc/"
				if !strings.HasPrefix(document.Path, prefix) {
					return AgentSnapshot{}, errors.New("invalid agent document path")
				}
				parts := strings.SplitN(strings.TrimPrefix(document.Path, prefix), "/", 2)
				if len(parts) != 2 || !validProjectPath(parts[1]) {
					return AgentSnapshot{}, errors.New("invalid agent document path")
				}
				var path string
				if parts[0] == "dora-tutorial" {
					path = "Doc/" + language + "/Tutorial/" + parts[1]
				} else if parts[0] == "dora-api" || parts[0] == "love-api" || parts[0] == "tic80-api" {
					path = "Script/Lib/Dora/" + language + "/" + parts[1]
				} else {
					return AgentSnapshot{}, errors.New("invalid agent document kind")
				}
				if seen[path] {
					return AgentSnapshot{}, errors.New("duplicate agent document")
				}
				seen[path] = true
				files = append(files, AgentFile{path, []byte(document.Text)})
			}
			continue
		}
		path := strings.TrimPrefix(f.Path, "lua/")
		if seen[path] {
			return AgentSnapshot{}, errors.New("duplicate agent file")
		}
		seen[path] = true
		files = append(files, AgentFile{path, b})
	}
	required := []string{"Agent/Session.lua", "AgentHostSession.lua", "AgentSessionBridge.lua", "StudioAgentEntry.lua", "StudioAgentYueBuild.lua", "StudioAgentXmlBuild.lua", "Utils.lua", "lualib_bundle.lua"}
	for _, p := range required {
		if !seen[p] {
			return AgentSnapshot{}, fmt.Errorf("missing agent support file %s", p)
		}
	}
	files = append(files, AgentFile{"init.lua", []byte("require('AgentHostSession').startConfigured(require('Dora').Content:load('/game/studio-host.json'))")})
	cfgRaw, _ := json.Marshal(map[string]any{"version": 1, "projectRoot": c.ProjectRoot, "title": c.Title})
	files = append(files, AgentFile{"studio-host.json", cfgRaw})
	manifestFiles := []map[string]any{}
	for _, f := range files {
		sum := sha256.Sum256(f.Bytes)
		manifestFiles = append(manifestFiles, map[string]any{"path": f.Path, "url": "host-files/" + f.Path, "size": len(f.Bytes), "sha256": hex.EncodeToString(sum[:]), "startup": true})
	}
	manifest := map[string]any{"format": "dora-web-game", "version": 1, "engineVersion": a.engineVersion, "profile": "dora-preset", "entry": "init.lua", "files": manifestFiles}
	return AgentSnapshot{Config: c, Manifest: manifest, Files: files}, nil
}

func (a *AgentService) authorize(r *http.Request, id string) (AgentSnapshot, *Account, bool) {
	snap, ok := a.get(id)
	if !ok {
		return AgentSnapshot{}, nil, false
	}
	token := sessionToken(r)
	session, err := a.store.ResolveSession(r.Context(), token)
	if err != nil || session == nil || session.AccountID != snap.Config.AccountID {
		return AgentSnapshot{}, nil, false
	}
	acct, err := a.store.Account(r.Context(), session.AccountID)
	if err != nil || acct == nil || !acct.Enabled {
		return AgentSnapshot{}, nil, false
	}
	project, err := a.store.Project(r.Context(), acct.AccountID, snap.Config.ProjectID, 0)
	if err != nil || project == nil {
		return AgentSnapshot{}, nil, false
	}
	return snap, acct, true
}

func (a *AgentService) HandleAPI(w http.ResponseWriter, r *http.Request, srv *Server) {
	if !sameOrigin(r, a.studioOrigin, true) {
		empty(w, 403)
		return
	}
	acct, _, ok := srv.requireAccount(w, r)
	if !ok {
		return
	}
	p := strings.TrimPrefix(r.URL.Path, "/api/projects/")
	parts := strings.Split(p, "/")
	if len(parts) < 2 || parts[1] != "agent-launch" || !validSlug(parts[0], 128) {
		empty(w, 404)
		return
	}
	projectID := parts[0]
	record, err := a.store.Project(r.Context(), acct.AccountID, projectID, 0)
	if err != nil || record == nil {
		empty(w, 403)
		return
	}
	if len(parts) == 2 {
		if r.Method != "POST" {
			method(w, "POST")
			return
		}
		if r.ContentLength > 0 {
			empty(w, 400)
			return
		}
		generation, err := randomUUID()
		if err != nil {
			empty(w, 500)
			return
		}
		c := AgentConfig{Version: 1, StudioOrigin: a.studioOrigin, HostOrigin: a.hostOrigin, AccountID: acct.AccountID, ProjectID: projectID, Generation: generation, ProjectRoot: "/user/studio-project", Title: "Studio 项目 " + projectID[:min(8, len(projectID))]}
		snap, err := a.createSnapshot(c)
		if err != nil {
			empty(w, 500)
			return
		}
		id, expires, err := a.put(snap)
		if err != nil {
			empty(w, 503)
			return
		}
		jsonResponse(w, 201, map[string]any{"version": 1, "projectId": projectID, "generation": c.Generation, "expiresAt": expires.UnixMilli(), "url": a.hostOrigin + "/agent-host/" + id + "/index.html"})
		return
	}
	if len(parts) == 3 && r.Method == "DELETE" {
		id := parts[2]
		a.mu.Lock()
		if e := a.launches[id]; e != nil && e.Snapshot.Config.AccountID == acct.AccountID && e.Snapshot.Config.ProjectID == projectID {
			delete(a.launches, id)
			a.usedBytes -= e.Bytes
		}
		a.mu.Unlock()
		empty(w, 204)
		return
	}
	method(w, "DELETE")
}

func (a *AgentService) HostHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "private, no-store")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("Cross-Origin-Resource-Policy", "same-origin")
		if !strings.HasPrefix(r.URL.Path, "/agent-host/") {
			http.NotFound(w, r)
			return
		}
		p := strings.TrimPrefix(r.URL.Path, "/agent-host/")
		parts := strings.SplitN(p, "/", 2)
		if len(parts) != 2 {
			http.NotFound(w, r)
			return
		}
		id, resource := parts[0], parts[1]
		snap, acct, ok := a.authorize(r, id)
		if !ok {
			empty(w, 403)
			return
		}
		switch {
		case resource == "renew":
			a.renew(w, r, id)
		case resource == "model-queue":
			jsonResponse(w, 200, a.queueState(id))
		case strings.HasPrefix(resource, "model-config/"):
			a.modelConfig(w, r, id, strings.TrimPrefix(resource, "model-config/"), snap, acct)
		case strings.HasPrefix(resource, "model/") || strings.HasPrefix(resource, "vision/"):
			kind := "model"
			grant := strings.TrimPrefix(resource, "model/")
			if strings.HasPrefix(resource, "vision/") {
				kind = "vision"
				grant = strings.TrimPrefix(resource, "vision/")
			}
			a.model(w, r, id, kind, grant, snap, acct)
		case resource == "host-config.json":
			a.writeBytes(w, r, "application/json", mustJSON(snap.Config))
		case resource == "host-manifest.json":
			a.writeBytes(w, r, "application/json", mustJSON(snap.Manifest))
		case strings.HasPrefix(resource, "host-files/"):
			name := strings.TrimPrefix(resource, "host-files/")
			for _, f := range snap.Files {
				if f.Path == name {
					a.writeBytes(w, r, "application/octet-stream", f.Bytes)
					return
				}
			}
			empty(w, 404)
		default:
			if b, ok := a.assets[resource]; ok {
				w.Header().Set("Cross-Origin-Opener-Policy", "same-origin")
				w.Header().Set("Cross-Origin-Embedder-Policy", "require-corp")
				if resource == "index.html" {
					w.Header().Set("Cross-Origin-Resource-Policy", "cross-origin")
				}
				a.writeBytes(w, r, mime.TypeByExtension(filepath.Ext(resource)), b)
				return
			}
			empty(w, 404)
		}
	})
}
func mustJSON(v any) []byte { b, _ := json.Marshal(v); return b }
func (a *AgentService) writeBytes(w http.ResponseWriter, r *http.Request, typ string, b []byte) {
	if r.Method != "GET" && r.Method != "HEAD" {
		method(w, "GET, HEAD")
		return
	}
	if typ == "" {
		typ = "application/octet-stream"
	}
	w.Header().Set("Content-Type", typ)
	w.Header().Set("Content-Length", fmt.Sprint(len(b)))
	w.WriteHeader(200)
	if r.Method == "GET" {
		_, _ = w.Write(b)
	}
}
func (a *AgentService) renew(w http.ResponseWriter, r *http.Request, id string) {
	if r.Method != "POST" {
		method(w, "POST")
		return
	}
	if !sameOrigin(r, a.hostOrigin, true) {
		empty(w, 403)
		return
	}
	a.mu.Lock()
	defer a.mu.Unlock()
	e := a.launches[id]
	if e == nil {
		empty(w, 404)
		return
	}
	expires := time.Now().Add(5 * time.Minute)
	maximum := e.Created.Add(24 * time.Hour)
	if expires.After(maximum) {
		expires = maximum
	}
	e.Expires = expires
	jsonResponse(w, 200, map[string]any{"version": 1, "expiresAt": expires.UnixMilli()})
}
func (a *AgentService) queueState(id string) map[string]any {
	a.mu.Lock()
	defer a.mu.Unlock()
	for index, waiter := range a.waiters {
		if waiter.launchID == id {
			return map[string]any{"version": 1, "state": "queued", "queuedAt": waiter.queuedAt.UnixMilli(), "position": index + 1}
		}
	}
	return map[string]any{"version": 1, "state": "idle"}
}

func (a *AgentService) removeWaiter(target *modelWaiter) {
	a.mu.Lock()
	defer a.mu.Unlock()
	for index, waiter := range a.waiters {
		if waiter == target {
			a.waiters = append(a.waiters[:index], a.waiters[index+1:]...)
			return
		}
	}
}

func (a *AgentService) waitForAdmission(ctx context.Context, launchID string, intent ModelIntent) error {
	err := a.store.BeginModelRequest(ctx, intent)
	if !errors.Is(err, errConcurrency) {
		return err
	}
	waiter := &modelWaiter{launchID: launchID, intent: intent, queuedAt: time.Now()}
	a.mu.Lock()
	if a.closed {
		a.mu.Unlock()
		return errQueueClosed
	}
	accountQueued := 0
	for _, current := range a.waiters {
		if current.intent.AccountID == intent.AccountID {
			accountQueued++
		}
	}
	if accountQueued >= 3 || len(a.waiters) >= 256 {
		a.mu.Unlock()
		return errQueueFull
	}
	a.waiters = append(a.waiters, waiter)
	a.mu.Unlock()
	defer a.removeWaiter(waiter)
	timer := time.NewTimer(4 * time.Minute)
	ticker := time.NewTicker(250 * time.Millisecond)
	defer timer.Stop()
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-timer.C:
			return errQueueTimeout
		case <-ticker.C:
			a.mu.Lock()
			if a.closed {
				a.mu.Unlock()
				return errQueueClosed
			}
			canTry := true
			for _, prior := range a.waiters {
				if prior == waiter {
					break
				}
				if prior.intent.AccountID == intent.AccountID || prior.intent.APIID == intent.APIID || prior.intent.GrantID == intent.GrantID {
					canTry = false
					break
				}
			}
			a.mu.Unlock()
			if !canTry {
				continue
			}
			err = a.store.BeginModelRequest(ctx, intent)
			if !errors.Is(err, errConcurrency) {
				return err
			}
		}
	}
}

func profile(provider string) (map[string]any, map[string]any) {
	base := map[string]any{"contextWindow": 128000, "temperature": 0.1, "maxTokens": 8192, "supportsFunctionCalling": true, "customOptions": map[string]any{"auxiliaryOptions": map[string]any{"max_tokens": 8192, "reasoning_effort": nil, "thinking": map[string]string{"type": "disabled"}}}}
	var vision map[string]any
	switch provider {
	case "deepseek":
		base["contextWindow"] = 1000000
		base["maxTokens"] = 64000
		vision = map[string]any{"provider": "deepseek", "model": "deepseek-flash"}
	case "zai":
		vision = map[string]any{"provider": "glm-coding-cn", "model": "glm-5.3-flash"}
	case "openai":
		base["customOptions"] = map[string]any{"auxiliaryOptions": map[string]any{"max_tokens": nil, "max_completion_tokens": 8192, "reasoning_effort": "none"}}
	case "xywhsoft":
		// ling-3.0-tiny accepts simple forced function calls but repeatedly emits
		// empty arguments for the Agent's larger tool set. Use the Agent's native
		// XML decision protocol for this deployed provider instead.
		base["supportsFunctionCalling"] = false
	}
	return base, vision
}
func (a *AgentService) modelConfig(w http.ResponseWriter, r *http.Request, id, grant string, snap AgentSnapshot, acct *Account) {
	if r.Method != "GET" {
		method(w, "GET")
		return
	}
	apiID, ok := a.store.OwnedGrant(r.Context(), acct.AccountID, grant)
	if !ok {
		empty(w, 403)
		return
	}
	c, _ := a.store.GetConfiguration(r.Context(), apiID)
	if c == nil || !c.Enabled || c.Pricing == nil {
		empty(w, 503)
		return
	}
	_, available, _ := a.store.SecretMetadata(r.Context(), "shared", "platform", c.ID)
	if !available {
		empty(w, 503)
		return
	}
	p, vision := profile(c.ProviderID)
	p["url"] = a.hostOrigin + "/agent-host/" + id + "/model/" + grant
	p["model"] = c.Model
	p["apiKey"] = "studio-agent"
	p["studioGateway"] = true
	if vision != nil {
		vision["url"] = a.hostOrigin + "/agent-host/" + id + "/vision/" + grant
		p["studioVision"] = vision
	}
	jsonResponse(w, 200, map[string]any{"version": 1, "grantId": grant, "configurationVersion": c.Version, "llmConfig": p})
}

func (a *AgentService) model(w http.ResponseWriter, r *http.Request, launchID, kind, grant string, snap AgentSnapshot, acct *Account) {
	if r.Method != "POST" {
		method(w, "POST")
		return
	}
	if !sameOrigin(r, a.hostOrigin, true) {
		jsonResponse(w, 403, map[string]string{"error": "wrong-origin"})
		return
	}
	requestID := r.Header.Get("X-Studio-Model-Request-Id")
	if !validSlug(requestID, 128) {
		jsonResponse(w, 400, map[string]string{"error": "request-id-required"})
		return
	}
	apiID, ok := a.store.OwnedGrant(r.Context(), acct.AccountID, grant)
	if !ok {
		jsonResponse(w, 403, map[string]string{"error": "model-grant-forbidden"})
		return
	}
	c, _ := a.store.GetConfiguration(r.Context(), apiID)
	provider := a.provider(c)
	if c == nil || !c.Enabled || provider.Endpoint == "" {
		jsonResponse(w, 503, map[string]string{"error": "model-configuration-unavailable"})
		return
	}
	limit := int64(1 << 20)
	if kind == "vision" {
		limit = 20 << 20
	}
	body, err := io.ReadAll(http.MaxBytesReader(w, r.Body, limit))
	if err != nil {
		jsonResponse(w, 413, map[string]string{"error": "request-too-large"})
		return
	}
	var payload map[string]any
	if err = json.Unmarshal(body, &payload); err != nil {
		jsonResponse(w, 400, map[string]string{"error": "invalid-completion-request"})
		return
	}
	expected := c.Model
	if kind == "vision" {
		_, v := profile(c.ProviderID)
		if v == nil {
			jsonResponse(w, 503, map[string]string{"error": "vision-provider-unavailable"})
			return
		}
		expected = v["model"].(string)
	}
	if payload["model"] != expected {
		jsonResponse(w, 403, map[string]string{"error": "model-mismatch"})
		return
	}
	inputRate := decimal(c.Pricing["inputNanoCnyPerMillion"])
	outputRate := decimal(c.Pricing["outputNanoCnyPerMillion"])
	if inputRate == nil || outputRate == nil {
		jsonResponse(w, 503, map[string]string{"error": "model-configuration-unavailable"})
		return
	}
	outputTokens := int64(8192)
	for _, key := range []string{"max_tokens", "max_completion_tokens"} {
		if value, ok := payload[key].(float64); ok {
			if value < 1 || value > 65536 || value != float64(int64(value)) {
				jsonResponse(w, 400, map[string]string{"error": "invalid-completion-request"})
				return
			}
			if int64(value) > outputTokens {
				outputTokens = int64(value)
			}
		}
	}
	inputTokens := int64(len(body))
	if inputTokens < 1024 {
		inputTokens = 1024
	}
	reservation := new(big.Int).Add(charge(big.NewInt(inputTokens), inputRate), charge(big.NewInt(outputTokens), outputRate))
	fingerprintBytes := sha256.Sum256(append([]byte(fmt.Sprintf("%s\x00%s\x00%d\x00", kind, c.ID, c.Version)), body...))
	ledgerID := launchID + "_" + requestID
	intent := ModelIntent{RequestID: ledgerID, AccountID: acct.AccountID, APIID: c.ID, GrantID: grant, Fingerprint: hex.EncodeToString(fingerprintBytes[:]), ConfigurationVersion: c.Version, Reservation: reservation, InputRate: inputRate, OutputRate: outputRate}
	if err := a.waitForAdmission(r.Context(), launchID, intent); err != nil {
		switch {
		case errors.Is(err, errConflict):
			jsonResponse(w, 409, map[string]string{"error": "request-already-recorded"})
		case errors.Is(err, errQueueTimeout):
			gatewayError(w, payload, "model-queue-timeout", "共享模型持续繁忙，请稍后重新发起。")
		case errors.Is(err, errQueueFull):
			gatewayError(w, payload, "model-queue-full", "当前账号等待中的模型请求过多，请等待已有任务完成。")
		case errors.Is(err, errQueueClosed):
			gatewayError(w, payload, "model-queue-unavailable", "模型排队服务正在关闭，请稍后重试。")
		case errors.Is(err, errInsufficient):
			gatewayError(w, payload, "model-amount-insufficient", "当前账号的模型额度不足，请补充额度后重试。")
		default:
			gatewayError(w, payload, "model-grant-unavailable", "当前模型授权不可用，请刷新账号或联系管理员。")
		}
		return
	}
	var response *http.Response
	err = a.store.WithSecret(r.Context(), "shared", "platform", c.ID, func(secret []byte, version int64) error {
		req, err := http.NewRequestWithContext(r.Context(), "POST", provider.Endpoint, bytes.NewReader(body))
		if err != nil {
			return err
		}
		req.Header.Set("Content-Type", "application/json")
		req.Header.Set("Authorization", "Bearer "+string(secret))
		response, err = a.client.Do(req)
		return err
	})
	if err != nil {
		_ = a.store.FinishModelRequest(context.Background(), ledgerID, nil)
		jsonResponse(w, 503, map[string]string{"error": "model-secret-unavailable"})
		return
	}
	defer response.Body.Close()
	for k, values := range response.Header {
		if strings.EqualFold(k, "Content-Type") {
			for _, v := range values {
				w.Header().Add(k, v)
			}
		}
	}
	contentType := response.Header.Get("Content-Type")
	if response.StatusCode >= 200 && response.StatusCode < 300 && strings.Contains(strings.ToLower(contentType), "text/event-stream") {
		w.WriteHeader(response.StatusCode)
		usage, complete := streamProviderResponse(w, response.Body, 64<<20)
		if !complete {
			usage = nil
		}
		_ = a.store.FinishModelRequest(context.Background(), ledgerID, usage)
		return
	}
	responseBody, readErr := io.ReadAll(io.LimitReader(response.Body, (64<<20)+1))
	if readErr != nil || len(responseBody) > 64<<20 {
		_ = a.store.FinishModelRequest(context.Background(), ledgerID, nil)
		jsonResponse(w, 503, map[string]string{"error": "model-unavailable"})
		return
	}
	var usage *ModelUsage
	if response.StatusCode >= 200 && response.StatusCode < 300 {
		usage = parseProviderUsage(responseBody)
	}
	_ = a.store.FinishModelRequest(context.Background(), ledgerID, usage)
	w.WriteHeader(response.StatusCode)
	_, _ = w.Write(responseBody)
}

func streamProviderResponse(w http.ResponseWriter, source io.Reader, maximum int64) (*ModelUsage, bool) {
	var captured bytes.Buffer
	buffer := make([]byte, 32<<10)
	var total int64
	complete := false
	for {
		n, err := source.Read(buffer)
		if n > 0 {
			total += int64(n)
			if total > maximum {
				return nil, false
			}
			chunk := buffer[:n]
			_, _ = captured.Write(chunk)
			if _, writeErr := w.Write(chunk); writeErr != nil {
				return nil, false
			}
			if flusher, ok := w.(http.Flusher); ok {
				flusher.Flush()
			}
		}
		if errors.Is(err, io.EOF) {
			complete = true
			break
		}
		if err != nil {
			return nil, false
		}
	}
	body := captured.Bytes()
	if !bytes.Contains(body, []byte("data: [DONE]")) {
		complete = false
	}
	return parseProviderUsage(body), complete
}

func parseProviderUsage(body []byte) *ModelUsage {
	var doc map[string]any
	if json.Unmarshal(body, &doc) == nil {
		if usage := usageFromMap(doc["usage"]); usage != nil {
			return usage
		}
	}
	for _, line := range strings.Split(string(body), "\n") {
		line = strings.TrimSpace(line)
		if !strings.HasPrefix(line, "data:") {
			continue
		}
		data := strings.TrimSpace(strings.TrimPrefix(line, "data:"))
		if data == "[DONE]" {
			continue
		}
		var event map[string]any
		if json.Unmarshal([]byte(data), &event) == nil {
			if usage := usageFromMap(event["usage"]); usage != nil {
				return usage
			}
		}
	}
	return nil
}
func usageFromMap(value any) *ModelUsage {
	m, ok := value.(map[string]any)
	if !ok {
		return nil
	}
	number := func(keys ...string) *big.Int {
		for _, key := range keys {
			if v, ok := m[key].(float64); ok && v >= 0 && v == float64(int64(v)) {
				return big.NewInt(int64(v))
			}
		}
		return nil
	}
	input, output := number("prompt_tokens", "input_tokens"), number("completion_tokens", "output_tokens")
	if input == nil || output == nil {
		return nil
	}
	return &ModelUsage{InputTokens: input, OutputTokens: output}
}
func (a *AgentService) provider(c *Configuration) Provider {
	if c == nil {
		return Provider{}
	}
	return aProviderCatalog.Load(a, c.ProviderID)
}

type providerCatalog struct {
	mu sync.RWMutex
	m  map[*AgentService]map[string]Provider
}

var aProviderCatalog = providerCatalog{m: map[*AgentService]map[string]Provider{}}

func (p *providerCatalog) Set(a *AgentService, m map[string]Provider) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.m[a] = m
}
func (p *providerCatalog) Load(a *AgentService, id string) Provider {
	p.mu.RLock()
	defer p.mu.RUnlock()
	return p.m[a][id]
}
func (a *AgentService) SetProviders(v map[string]Provider) { aProviderCatalog.Set(a, v) }
func (a *AgentService) SetProviderClient(client *http.Client) {
	if client != nil {
		a.client = client
	}
}
func gatewayError(w http.ResponseWriter, body map[string]any, code, message string) {
	payload := map[string]any{"error": map[string]any{"message": message, "type": "studio_gateway_error", "code": code}}
	if body["stream"] == true {
		w.Header().Set("Content-Type", "text/event-stream; charset=utf-8")
		w.WriteHeader(200)
		fmt.Fprintf(w, "data: %s\n\ndata: [DONE]\n\n", mustJSON(payload))
		return
	}
	jsonResponse(w, 200, payload)
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
