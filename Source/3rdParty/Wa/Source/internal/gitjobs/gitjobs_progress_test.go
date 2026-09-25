//go:build !js

package gitjobs

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func TestSnapshotReportsCloneTransferredBytes(t *testing.T) {
	repoPath := t.TempDir()
	packPath := filepath.Join(repoPath, ".git", "objects", "pack")
	if err := os.MkdirAll(packPath, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(packPath, "tmp_pack_download"), make([]byte, 1536), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(packPath, "pack-test.idx"), make([]byte, 512), 0o644); err != nil {
		t.Fatal(err)
	}

	j := &job{id: 7, kind: "clone", repoPath: repoPath, state: StateRunning, transferPath: repoPath}
	var result pollResult
	if err := json.Unmarshal([]byte(j.snapshot()), &result); err != nil {
		t.Fatal(err)
	}
	if result.TransferredBytes != 1536 {
		t.Fatalf("transferred bytes = %d, want 1536", result.TransferredBytes)
	}
}

func TestTransferredBytesNeverMoveBackward(t *testing.T) {
	j := &job{}
	j.setTransferredBytes(2048)
	j.setTransferredBytes(1024)
	if j.transferredBytes != 2048 {
		t.Fatalf("transferred bytes = %d, want 2048", j.transferredBytes)
	}
}
