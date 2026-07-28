package gitjobs

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/object"
)

func commitResourceFixture(t *testing.T, symlink bool) (string, string) {
	t.Helper()
	repoPath := t.TempDir()
	repo, err := git.PlainInit(repoPath, false)
	if err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(repoPath, "init.lua"), []byte("return true\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	if symlink {
		if err := os.Symlink("../outside", filepath.Join(repoPath, "escape")); err != nil {
			t.Fatal(err)
		}
	}
	worktree, err := repo.Worktree()
	if err != nil {
		t.Fatal(err)
	}
	if _, err := worktree.Add("."); err != nil {
		t.Fatal(err)
	}
	hash, err := worktree.Commit("resource fixture", &git.CommitOptions{
		Author: &object.Signature{
			Name:  "Dora Resource Test",
			Email: "resource@example.com",
			When:  time.Unix(1_700_000_000, 0),
		},
	})
	if err != nil {
		t.Fatal(err)
	}
	return repoPath, hash.String()
}

func TestVerifyResourceAcceptsRegularFiles(t *testing.T) {
	repoPath, head := commitResourceFixture(t, false)
	data, err := execVerifyResource(repoPath, gitCommand{commitHash: head})
	if err != nil {
		t.Fatal(err)
	}
	if data["commit"] != head || data["files"] != 1 {
		t.Fatalf("unexpected verification data: %#v", data)
	}
}

func TestVerifyResourceRejectsSymbolicLinks(t *testing.T) {
	repoPath, head := commitResourceFixture(t, true)
	if _, err := execVerifyResource(repoPath, gitCommand{commitHash: head}); err == nil {
		t.Fatal("expected symbolic link to be rejected")
	}
}

func TestParseVerifyResource(t *testing.T) {
	head := "0123456789abcdef0123456789abcdef01234567"
	cmd, err := parseGitCommand("/tmp/repo", "verify-resource "+head)
	if err != nil {
		t.Fatal(err)
	}
	if cmd.op != "verify-resource" || cmd.commitHash != head {
		t.Fatalf("unexpected parsed command: %+v", cmd)
	}
	if _, err := parseGitCommand("/tmp/repo", "verify-resource deadbeef"); err == nil {
		t.Fatal("expected short hash to be rejected")
	}
}
