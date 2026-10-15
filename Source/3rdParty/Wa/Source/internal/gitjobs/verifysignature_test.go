package gitjobs

import (
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha512"
	"encoding/pem"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/object"
	"golang.org/x/crypto/ssh"
)

func signedTestCommit(t *testing.T) (*object.Commit, string) {
	t.Helper()
	publicKey, privateKey, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	signer, err := ssh.NewSignerFromKey(privateKey)
	if err != nil {
		t.Fatal(err)
	}
	commit := &object.Commit{
		Author: object.Signature{
			Name:  "Dora Release Test",
			Email: "release@example.com",
			When:  time.Unix(1_700_000_000, 0),
		},
		Committer: object.Signature{
			Name:  "Dora Release Test",
			Email: "release@example.com",
			When:  time.Unix(1_700_000_000, 0),
		},
		Message: "signed release\n",
	}
	payload, err := commitSigningPayload(commit)
	if err != nil {
		t.Fatal(err)
	}
	digest := sha512.Sum512(payload)
	signature, err := signer.Sign(rand.Reader, sshSignedData("git", "", "sha512", digest[:]))
	if err != nil {
		t.Fatal(err)
	}
	envelope := sshSignatureEnvelope{
		Version:       1,
		PublicKey:     signer.PublicKey().Marshal(),
		Namespace:     "git",
		HashAlgorithm: "sha512",
		Signature:     ssh.Marshal(signature),
	}
	commit.PGPSignature = string(pem.EncodeToMemory(&pem.Block{
		Type:  "SSH SIGNATURE",
		Bytes: append([]byte("SSHSIG"), ssh.Marshal(envelope)...),
	}))
	parsedPublic, err := ssh.NewPublicKey(publicKey)
	if err != nil {
		t.Fatal(err)
	}
	return commit, string(ssh.MarshalAuthorizedKey(parsedPublic))
}

func TestVerifyCommitSignature(t *testing.T) {
	commit, publicKey := signedTestCommit(t)
	fingerprint, err := verifyCommitSignature(commit, []string{publicKey}, "update")
	if err != nil {
		t.Fatal(err)
	}
	if fingerprint == "" {
		t.Fatal("expected signer fingerprint")
	}
}

func TestVerifyCommitSignatureRejectsTamperedPayload(t *testing.T) {
	commit, publicKey := signedTestCommit(t)
	commit.Message = "tampered release\n"
	if _, err := verifyCommitSignature(commit, []string{publicKey}, "update"); err == nil {
		t.Fatal("expected tampered commit verification to fail")
	}
}

func TestVerifyCommitSignatureRejectsUntrustedKey(t *testing.T) {
	commit, _ := signedTestCommit(t)
	_, otherKey := signedTestCommit(t)
	if _, err := verifyCommitSignature(commit, []string{otherKey}, "update"); err == nil {
		t.Fatal("expected untrusted update key verification to fail")
	}
}

func TestVerifyCommitSignatureGeneratedByGit(t *testing.T) {
	if _, err := exec.LookPath("git"); err != nil {
		t.Skip("git executable is unavailable")
	}
	if _, err := exec.LookPath("ssh-keygen"); err != nil {
		t.Skip("ssh-keygen executable is unavailable")
	}
	repoPath := t.TempDir()
	keyPath := filepath.Join(t.TempDir(), "update-release")
	run := func(name string, args ...string) {
		t.Helper()
		cmd := exec.Command(name, args...)
		cmd.Dir = repoPath
		if output, err := cmd.CombinedOutput(); err != nil {
			t.Fatalf("%s %v failed: %v\n%s", name, args, err, output)
		}
	}
	run("ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", keyPath)
	run("git", "init", "-q")
	run("git", "config", "user.name", "Dora Release Test")
	run("git", "config", "user.email", "release@example.com")
	run("git", "config", "gpg.format", "ssh")
	run("git", "config", "user.signingkey", keyPath)
	if err := os.WriteFile(filepath.Join(repoPath, "resource.json"), []byte("{}\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	run("git", "add", "resource.json")
	run("git", "commit", "-q", "-S", "-m", "signed by Git")

	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		t.Fatal(err)
	}
	head, err := repo.Head()
	if err != nil {
		t.Fatal(err)
	}
	commit, err := repo.CommitObject(head.Hash())
	if err != nil {
		t.Fatal(err)
	}
	publicKey, err := os.ReadFile(keyPath + ".pub")
	if err != nil {
		t.Fatal(err)
	}
	if _, err := verifyCommitSignature(commit, []string{string(publicKey)}, "update"); err != nil {
		t.Fatalf("real Git SSH signature was rejected: %v", err)
	}
}
