package gitjobs

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/transport"
	"github.com/go-git/go-git/v5/plumbing/transport/http"
)

type State string

const (
	StateQueued   State = "queued"
	StateRunning  State = "running"
	StateDone     State = "done"
	StateError    State = "error"
	StateCanceled State = "canceled"
)

type pollResult struct {
	ID        int64   `json:"id"`
	State     State   `json:"state"`
	Kind      string  `json:"kind"`
	RepoPath  string  `json:"repoPath"`
	StartedAt string  `json:"startedAt,omitempty"`
	EndedAt   string  `json:"endedAt,omitempty"`
	Progress  float64 `json:"progress"`
	Message   string  `json:"message,omitempty"`
	Error     string  `json:"error,omitempty"`
	Data      any     `json:"data,omitempty"`
}

type cloneRequest struct {
	url    string
	path   string
	branch string
	token  string
	depth  int
	force  bool
	cmd    commandRequest
}

type job struct {
	id       int64
	kind     string
	repoPath string
	ctx      context.Context
	cancel   context.CancelFunc
	req      cloneRequest

	mu        sync.Mutex
	state     State
	startedAt time.Time
	endedAt   time.Time
	progress  float64
	message   string
	err       string
	data      map[string]any
}

type progressWriter struct {
	job *job
}

var (
	nextID     int64
	queue      chan *job
	workerOnce sync.Once
	procsOnce  sync.Once

	mu          sync.Mutex
	jobs        = map[int64]*job{}
	activePaths = map[string]int64{}
)

func StartClone(url, path, branch, token string, depth int) int64 {
	url = strings.TrimSpace(url)
	path = strings.TrimSpace(path)
	branch = strings.TrimSpace(branch)
	token = strings.TrimSpace(token)
	if depth < 0 {
		depth = 0
	}
	if url == "" || path == "" {
		return createRejectedJob(path, "clone", "url and path are required")
	}

	return startJob("clone", path, cloneRequest{
		url:    url,
		path:   path,
		branch: branch,
		token:  token,
		depth:  depth,
	})
}

func StartPull(path, branch, token string, force bool) int64 {
	path = strings.TrimSpace(path)
	branch = strings.TrimSpace(branch)
	token = strings.TrimSpace(token)
	if path == "" {
		return createRejectedJob(path, "pull", "path is required")
	}
	return startJob("pull", path, cloneRequest{
		path:   path,
		branch: branch,
		token:  token,
		force:  force,
	})
}

func startJob(kind, path string, req cloneRequest) int64 {
	procsOnce.Do(func() {
		runtime.GOMAXPROCS(1)
	})
	workerOnce.Do(func() {
		queue = make(chan *job, 32)
		go worker()
	})

	ctx, cancel := context.WithCancel(context.Background())
	id := atomic.AddInt64(&nextID, 1)
	j := &job{
		id:       id,
		kind:     kind,
		repoPath: path,
		ctx:      ctx,
		cancel:   cancel,
		req:      req,
		state:    StateQueued,
		progress: 0,
		message:  "queued",
	}
	mu.Lock()
	if existing := activePaths[path]; existing != 0 {
		mu.Unlock()
		cancel()
		return createRejectedJob(path, kind, fmt.Sprintf("repo path is already used by job %d", existing))
	}
	jobs[id] = j
	activePaths[path] = id
	mu.Unlock()

	queue <- j
	return id
}

func Poll(id int64) string {
	mu.Lock()
	j := jobs[id]
	mu.Unlock()
	if j == nil {
		return marshal(pollResult{
			ID:    id,
			State: StateError,
			Error: "job not found",
		})
	}
	return j.snapshot()
}

func Cancel(id int64) bool {
	mu.Lock()
	j := jobs[id]
	mu.Unlock()
	if j == nil {
		return false
	}
	j.cancel()
	j.setQueuedCanceled()
	return true
}

func Dispose(id int64) bool {
	mu.Lock()
	j := jobs[id]
	if j == nil {
		mu.Unlock()
		return false
	}
	delete(jobs, id)
	if activePaths[j.repoPath] == id {
		delete(activePaths, j.repoPath)
	}
	mu.Unlock()
	if j.cancel != nil {
		j.cancel()
	}
	return true
}

func worker() {
	for j := range queue {
		runJob(j)
	}
}

func runJob(j *job) {
	defer func() {
		mu.Lock()
		if activePaths[j.repoPath] == j.id {
			delete(activePaths, j.repoPath)
		}
		mu.Unlock()
	}()
	if errors.Is(j.ctx.Err(), context.Canceled) {
		j.setCanceled()
		return
	}
	switch j.kind {
	case "add", "branch", "checkout", "clean", "commit", "diff", "fetch", "init", "log", "ls-remote", "mv", "push", "remote", "reset", "restore", "rm", "status", "tag":
		runCommand(j.ctx, j)
	case "clone":
		if j.req.cmd.command != "" {
			runCommand(j.ctx, j)
		} else {
			runClone(j)
		}
	case "pull":
		if j.req.cmd.command != "" {
			runCommand(j.ctx, j)
		} else {
			runPull(j)
		}
	default:
		j.setError(fmt.Errorf("unsupported git job kind %q", j.kind))
	}
}

func runClone(j *job) {
	j.setRunning("starting clone")

	if err := prepareClonePath(j.req.path); err != nil {
		j.setError(err)
		return
	}

	opts := &git.CloneOptions{
		URL:   j.req.url,
		Depth: j.req.depth,
		Progress: progressWriter{
			job: j,
		},
	}
	if j.req.branch != "" {
		opts.ReferenceName = plumbingBranch(j.req.branch)
		opts.SingleBranch = true
	}
	if auth := tokenAuth(j.req.token); auth != nil {
		opts.Auth = auth
	}

	_, err := git.PlainCloneContext(j.ctx, j.req.path, false, opts)
	if err != nil {
		if errors.Is(j.ctx.Err(), context.Canceled) {
			j.setCanceled()
			return
		}
		j.setError(err)
		return
	}
	j.setDone("clone completed")
}

func runPull(j *job) {
	j.setRunning("starting pull")

	repo, err := git.PlainOpen(j.req.path)
	if err != nil {
		j.setError(err)
		return
	}
	worktree, err := repo.Worktree()
	if err != nil {
		j.setError(err)
		return
	}

	opts := &git.PullOptions{
		RemoteName: "origin",
		Force:      j.req.force,
		Progress: progressWriter{
			job: j,
		},
	}
	if j.req.branch != "" {
		opts.ReferenceName = plumbingBranch(j.req.branch)
		opts.SingleBranch = true
	}
	if auth := tokenAuth(j.req.token); auth != nil {
		opts.Auth = auth
	}

	err = worktree.PullContext(j.ctx, opts)
	if err != nil {
		if errors.Is(j.ctx.Err(), context.Canceled) {
			j.setCanceled()
			return
		}
		if errors.Is(err, git.NoErrAlreadyUpToDate) {
			j.setDone("already up-to-date")
			return
		}
		j.setError(err)
		return
	}
	j.setDone("pull completed")
}

func prepareClonePath(path string) error {
	if _, err := os.Stat(path); err == nil {
		entries, readErr := os.ReadDir(path)
		if readErr != nil {
			return readErr
		}
		if len(entries) != 0 {
			return fmt.Errorf("%q already exists and is not empty", path)
		}
		return nil
	} else if !os.IsNotExist(err) {
		return err
	}
	return os.MkdirAll(path, 0777)
}

func tokenAuth(token string) transport.AuthMethod {
	if token == "" {
		return nil
	}
	return &http.BasicAuth{
		Username: "token",
		Password: token,
	}
}

func (w progressWriter) Write(p []byte) (int, error) {
	msg := strings.TrimSpace(string(p))
	if msg != "" {
		w.job.setProgressMessage(msg)
	}
	return len(p), nil
}

func (j *job) setRunning(message string) {
	j.mu.Lock()
	defer j.mu.Unlock()
	j.state = StateRunning
	j.startedAt = time.Now()
	j.message = message
	j.progress = 0.05
}

func (j *job) setProgressMessage(message string) {
	j.mu.Lock()
	defer j.mu.Unlock()
	if j.state != StateRunning {
		return
	}
	j.message = message
	if j.progress < 0.9 {
		j.progress += 0.01
	}
}

func (j *job) setDone(message string) {
	j.mu.Lock()
	defer j.mu.Unlock()
	j.state = StateDone
	j.endedAt = time.Now()
	j.progress = 1
	j.message = message
}

func (j *job) setCanceled() {
	j.mu.Lock()
	defer j.mu.Unlock()
	j.state = StateCanceled
	j.endedAt = time.Now()
	j.message = "canceled"
}

func (j *job) setQueuedCanceled() {
	j.mu.Lock()
	defer j.mu.Unlock()
	if j.state != StateQueued {
		return
	}
	j.state = StateCanceled
	j.endedAt = time.Now()
	j.message = "canceled"
}

func (j *job) setError(err error) {
	j.mu.Lock()
	defer j.mu.Unlock()
	j.state = StateError
	j.endedAt = time.Now()
	j.err = err.Error()
	j.message = "failed"
}

func (j *job) setResult(data map[string]any) {
	j.mu.Lock()
	defer j.mu.Unlock()
	j.data = data
}

func (j *job) snapshot() string {
	j.mu.Lock()
	defer j.mu.Unlock()
	result := pollResult{
		ID:       j.id,
		State:    j.state,
		Kind:     j.kind,
		RepoPath: j.repoPath,
		Progress: j.progress,
		Message:  j.message,
		Error:    j.err,
		Data:     j.data,
	}
	if !j.startedAt.IsZero() {
		result.StartedAt = j.startedAt.Format(time.RFC3339)
	}
	if !j.endedAt.IsZero() {
		result.EndedAt = j.endedAt.Format(time.RFC3339)
	}
	return marshal(result)
}

func createRejectedJob(path, kind, errText string) int64 {
	id := atomic.AddInt64(&nextID, 1)
	j := &job{
		id:       id,
		kind:     kind,
		repoPath: path,
		state:    StateError,
		endedAt:  time.Now(),
		progress: 0,
		message:  "rejected",
		err:      errText,
	}
	mu.Lock()
	jobs[id] = j
	mu.Unlock()
	return id
}

func marshal(v pollResult) string {
	data, err := json.Marshal(v)
	if err != nil {
		_, _ = io.WriteString(io.Discard, err.Error())
		return `{"state":"error","error":"json marshal failed"}`
	}
	return string(data)
}
