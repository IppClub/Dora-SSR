package gitjobs

import (
	"crypto/sha256"
	"encoding/hex"
	"os"
	"path/filepath"
	"strconv"
	"testing"
)

func TestVerifyUpdateCommitSignature(t *testing.T) {
	commit, publicKey := signedTestCommit(t)
	fingerprint, err := verifyCommitSignature(commit, []string{publicKey}, "update")
	if err != nil {
		t.Fatal(err)
	}
	if fingerprint == "" {
		t.Fatal("expected update signer fingerprint")
	}
}

func TestParseVerifyUpdate(t *testing.T) {
	head := "0123456789abcdef0123456789abcdef01234567"
	previous := "89abcdef0123456789abcdef0123456789abcdef"
	cmd, err := parseGitCommand("/tmp/repo", "verify-update "+head+" "+previous)
	if err != nil {
		t.Fatal(err)
	}
	if cmd.op != "verify-update" || cmd.commitHash != head || cmd.target != previous {
		t.Fatalf("unexpected parsed command: %+v", cmd)
	}
	if _, err := parseGitCommand("/tmp/repo", "verify-update deadbeef"); err == nil {
		t.Fatal("expected short update hash to be rejected")
	}
}

func TestVerifyUpdatePackage(t *testing.T) {
	root := t.TempDir()
	data := []byte("Dora update package")
	path := filepath.Join(root, "package.zip")
	if err := os.WriteFile(path, data, 0o644); err != nil {
		t.Fatal(err)
	}
	sum := sha256.Sum256(data)
	expected := hex.EncodeToString(sum[:])
	command := "verify-update-package package.zip " + expected + " " + strconv.Itoa(len(data))
	cmd, err := parseGitCommand(root, command)
	if err != nil {
		t.Fatal(err)
	}
	result, err := execVerifyUpdatePackage(root, cmd)
	if err != nil {
		t.Fatal(err)
	}
	if result["sha256"] != expected {
		t.Fatalf("unexpected package hash: %v", result["sha256"])
	}
}

func TestVerifyUpdatePackageRejectsMismatchAndEscape(t *testing.T) {
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, "package.zip"), []byte("bad"), 0o644); err != nil {
		t.Fatal(err)
	}
	cmd, err := parseGitCommand(root, "verify-update-package package.zip 0000000000000000000000000000000000000000000000000000000000000000 3")
	if err != nil {
		t.Fatal(err)
	}
	if _, runErr := execVerifyUpdatePackage(root, cmd); runErr == nil {
		t.Fatal("expected update package hash mismatch")
	}
	escape := gitCommand{
		op:           "verify-update-package",
		paths:        []string{"../package.zip"},
		expectedHash: "0000000000000000000000000000000000000000000000000000000000000000",
		expectedSize: 3,
	}
	if _, err := execVerifyUpdatePackage(root, escape); err == nil {
		t.Fatal("expected escaping update package path to be rejected")
	}
}
