package gitjobs

import (
	"encoding/json"
	"os"
	"path/filepath"
	"runtime"
	"testing"
	"time"
)

func TestRunPreservesLiteralPathWhitespace(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("Win32 does not represent all literal trailing whitespace names")
	}
	for _, suffix := range []string{" ", "\t", "\u00a0", "\u3000"} {
		t.Run(suffix, func(t *testing.T) {
			root := t.TempDir()
			literal := filepath.Join(root, "repo"+suffix)
			id := StartRun(literal, "init", "")
			defer Dispose(id)
			deadline := time.Now().Add(10 * time.Second)
			for {
				var result struct{ State, Error string }
				if err := json.Unmarshal([]byte(Poll(id)), &result); err != nil {
					t.Fatal(err)
				}
				if result.State == "done" {
					break
				}
				if result.State == "error" || result.State == "canceled" || time.Now().After(deadline) {
					t.Fatalf("init did not complete: %s", Poll(id))
				}
				time.Sleep(10 * time.Millisecond)
			}
			if _, err := os.Stat(filepath.Join(literal, ".git")); err != nil {
				t.Fatal(err)
			}
			if _, err := os.Stat(filepath.Join(root, "repo", ".git")); !os.IsNotExist(err) {
				t.Fatalf("trimmed path used: %v", err)
			}
		})
	}
}

func TestClonePreservesLiteralDestinationWhitespace(t *testing.T) {
	root := t.TempDir()
	for _, name := range []string{" repo ", "repo\u00a0", "repo\u3000"} {
		for _, explicit := range []bool{false, true} {
			dir := ""
			if explicit {
				dir = name
			}
			got, err := cloneTargetPath(root, "https://example.invalid/"+name, dir)
			if err != nil || got != filepath.Join(root, name) {
				t.Fatalf("literal destination %q: %q, %v", name, got, err)
			}
		}
	}
}

func TestRunDoesNotTrimCommandData(t *testing.T) {
	root := t.TempDir()
	id := StartRun(root, "init\u00a0", "")
	defer Dispose(id)
	var result struct{ State string }
	if err := json.Unmarshal([]byte(Poll(id)), &result); err != nil {
		t.Fatal(err)
	}
	if result.State != "error" {
		t.Fatalf("command data was trimmed: %s", Poll(id))
	}
	if _, err := os.Stat(filepath.Join(root, ".git")); !os.IsNotExist(err) {
		t.Fatalf("unexpected init: %v", err)
	}
}

func TestCommandRejectsInvalidUTF8(t *testing.T) {
	if _, err := splitGitCommand("clone https://example/repo.git name\xff"); err == nil {
		t.Fatal("invalid UTF-8 must not be rewritten to a different destination")
	}
}
