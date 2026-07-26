package gitjobs

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/object"
)

func createTestRepository(t testing.TB, commitCount int) (string, string) {
	t.Helper()
	repoPath := t.TempDir()
	repo, err := git.PlainInit(repoPath, false)
	if err != nil {
		t.Fatal(err)
	}
	worktree, err := repo.Worktree()
	if err != nil {
		t.Fatal(err)
	}
	var lastHash string
	for index := 0; index < commitCount; index++ {
		content := []byte(fmt.Sprintf("value %d\n", index))
		if err := os.WriteFile(filepath.Join(repoPath, "tracked.txt"), content, 0o644); err != nil {
			t.Fatal(err)
		}
		if _, err := worktree.Add("tracked.txt"); err != nil {
			t.Fatal(err)
		}
		if index == 1 {
			if err := os.WriteFile(filepath.Join(repoPath, "added.txt"), []byte("added\n"), 0o644); err != nil {
				t.Fatal(err)
			}
			if _, err := worktree.Add("added.txt"); err != nil {
				t.Fatal(err)
			}
		}
		hash, err := worktree.Commit(fmt.Sprintf("commit %d", index), &git.CommitOptions{
			Author: &object.Signature{
				Name:  "Dora",
				Email: "dora@example.com",
				When:  time.Unix(int64(index+1), 0),
			},
		})
		if err != nil {
			t.Fatal(err)
		}
		lastHash = hash.String()
	}
	return repoPath, lastHash
}

func TestParseLogDataModes(t *testing.T) {
	metadata, err := parseGitCommand("", "log --metadata-only -n 100")
	if err != nil {
		t.Fatal(err)
	}
	if !metadata.metadataOnly || metadata.limit != 100 {
		t.Fatalf("unexpected metadata command: %#v", metadata)
	}

	changedFiles, err := parseGitCommand("", "log --changed-files 0123456789012345678901234567890123456789")
	if err != nil {
		t.Fatal(err)
	}
	if changedFiles.commitHash == "" || changedFiles.metadataOnly {
		t.Fatalf("unexpected changed-files command: %#v", changedFiles)
	}

	if _, err := parseGitCommand("", "log --metadata-only --changed-files 0123456789012345678901234567890123456789"); err == nil {
		t.Fatal("expected incompatible log data modes to fail")
	}
}

func TestExecLogLoadsChangedFilesOnDemand(t *testing.T) {
	repoPath, lastHash := createTestRepository(t, 2)
	metadata, err := execLog(repoPath, gitCommand{op: "log", limit: 20, metadataOnly: true})
	if err != nil {
		t.Fatal(err)
	}
	commits := metadata["commits"].([]map[string]any)
	if len(commits) != 2 {
		t.Fatalf("expected 2 commits, got %d", len(commits))
	}
	for _, commit := range commits {
		if _, exists := commit["files"]; exists {
			t.Fatalf("metadata commit unexpectedly contains files: %#v", commit)
		}
	}

	changed, err := execLog(repoPath, gitCommand{op: "log", commitHash: lastHash})
	if err != nil {
		t.Fatal(err)
	}
	files := changed["files"].([]map[string]any)
	if len(files) != 2 {
		t.Fatalf("expected 2 changed files, got %#v", files)
	}
	statusByPath := make(map[string]string, len(files))
	for _, file := range files {
		statusByPath[file["path"].(string)] = file["status"].(string)
	}
	if statusByPath["tracked.txt"] != "M" || statusByPath["added.txt"] != "A" {
		t.Fatalf("unexpected changed files: %#v", statusByPath)
	}
}

func TestWaitGitDataWithContextReturnsOnCancel(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	started := make(chan struct{})
	release := make(chan struct{})
	done := make(chan error, 1)
	go func() {
		_, err := waitGitDataWithContext(ctx, func() (map[string]any, error) {
			close(started)
			<-release
			return map[string]any{"clean": true}, nil
		})
		done <- err
	}()
	<-started
	cancel()
	select {
	case err := <-done:
		if !errors.Is(err, context.Canceled) {
			t.Fatalf("expected context cancellation, got %v", err)
		}
	case <-time.After(time.Second):
		t.Fatal("status wrapper did not release the Git worker after cancellation")
	}
	close(release)
}

func BenchmarkExecLogDataModes(b *testing.B) {
	repoPath := os.Getenv("DORA_GIT_BENCH_REPO")
	if repoPath == "" {
		repoPath, _ = createTestRepository(b, 100)
	}
	b.Run("metadata-only", func(b *testing.B) {
		for index := 0; index < b.N; index++ {
			if _, err := execLog(repoPath, gitCommand{op: "log", limit: 100, metadataOnly: true}); err != nil {
				b.Fatal(err)
			}
		}
	})
	b.Run("with-files", func(b *testing.B) {
		for index := 0; index < b.N; index++ {
			if _, err := execLog(repoPath, gitCommand{op: "log", limit: 100}); err != nil {
				b.Fatal(err)
			}
		}
	})
}
