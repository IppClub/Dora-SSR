package gitjobs

import (
	"bytes"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"strings"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/object"
	"golang.org/x/crypto/ssh"
)

// Dora-Releases release key:
// SHA256:Kf0tNlIMveWsTZTKn+W+dDGc20prHQZZRiJPAYoYo0Y
var trustedUpdaterReleaseKeys = []string{
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5WjsgiCspURMpOxpnnzPguZLNke9/+xOal6IWO9Uzp Dora-Releases release signing key",
}

type sshSignatureEnvelope struct {
	Version       uint32
	PublicKey     []byte
	Namespace     string
	Reserved      string
	HashAlgorithm string
	Signature     []byte
}

func parseSSHPublicKey(text string) (ssh.PublicKey, error) {
	key, _, _, _, err := ssh.ParseAuthorizedKey([]byte(strings.TrimSpace(text)))
	if err != nil {
		return nil, err
	}
	if key.Type() != ssh.KeyAlgoED25519 {
		return nil, fmt.Errorf("release key must be Ed25519, got %s", key.Type())
	}
	return key, nil
}

func parseSSHSignature(text string) (*sshSignatureEnvelope, *ssh.Signature, error) {
	block, rest := pem.Decode([]byte(text))
	if block == nil || block.Type != "SSH SIGNATURE" {
		return nil, nil, errors.New("commit does not contain an SSH signature")
	}
	if len(bytes.TrimSpace(rest)) != 0 {
		return nil, nil, errors.New("unexpected data after SSH signature")
	}
	const magic = "SSHSIG"
	if len(block.Bytes) < len(magic) || string(block.Bytes[:len(magic)]) != magic {
		return nil, nil, errors.New("invalid SSH signature magic")
	}
	var envelope sshSignatureEnvelope
	if err := ssh.Unmarshal(block.Bytes[len(magic):], &envelope); err != nil {
		return nil, nil, fmt.Errorf("invalid SSH signature envelope: %w", err)
	}
	if envelope.Version != 1 {
		return nil, nil, fmt.Errorf("unsupported SSH signature version %d", envelope.Version)
	}
	if envelope.Namespace != "git" {
		return nil, nil, fmt.Errorf("unexpected SSH signature namespace %q", envelope.Namespace)
	}
	if envelope.Reserved != "" {
		return nil, nil, errors.New("SSH signature reserved field must be empty")
	}
	var signature ssh.Signature
	if err := ssh.Unmarshal(envelope.Signature, &signature); err != nil {
		return nil, nil, fmt.Errorf("invalid SSH signature payload: %w", err)
	}
	return &envelope, &signature, nil
}

func commitSigningPayload(commit *object.Commit) ([]byte, error) {
	encoded := &plumbing.MemoryObject{}
	if err := commit.EncodeWithoutSignature(encoded); err != nil {
		return nil, err
	}
	reader, err := encoded.Reader()
	if err != nil {
		return nil, err
	}
	defer reader.Close()
	return io.ReadAll(reader)
}

func sshSignedData(namespace, reserved, hashAlgorithm string, digest []byte) []byte {
	fields := struct {
		Namespace     string
		Reserved      string
		HashAlgorithm string
		Hash          []byte
	}{
		Namespace:     namespace,
		Reserved:      reserved,
		HashAlgorithm: hashAlgorithm,
		Hash:          digest,
	}
	return append([]byte("SSHSIG"), ssh.Marshal(fields)...)
}

func verifyCommitSignature(commit *object.Commit, trustedKeys []string, subject string) (string, error) {
	if len(trustedKeys) == 0 {
		return "", fmt.Errorf("no trusted Dora %s release key is configured", subject)
	}
	envelope, signature, err := parseSSHSignature(commit.PGPSignature)
	if err != nil {
		return "", err
	}
	embeddedKey, err := ssh.ParsePublicKey(envelope.PublicKey)
	if err != nil {
		return "", fmt.Errorf("invalid SSH signature public key: %w", err)
	}
	if embeddedKey.Type() != ssh.KeyAlgoED25519 {
		return "", fmt.Errorf("%s signature must use Ed25519, got %s", subject, embeddedKey.Type())
	}
	payload, err := commitSigningPayload(commit)
	if err != nil {
		return "", err
	}
	var digest []byte
	switch envelope.HashAlgorithm {
	case "sha256":
		sum := sha256.Sum256(payload)
		digest = sum[:]
	case "sha512":
		sum := sha512.Sum512(payload)
		digest = sum[:]
	default:
		return "", fmt.Errorf("unsupported SSH signature hash %q", envelope.HashAlgorithm)
	}
	signedData := sshSignedData(envelope.Namespace, envelope.Reserved, envelope.HashAlgorithm, digest)
	for _, text := range trustedKeys {
		key, parseErr := parseSSHPublicKey(text)
		if parseErr != nil {
			return "", fmt.Errorf("invalid compiled %s key: %w", subject, parseErr)
		}
		if !bytes.Equal(key.Marshal(), embeddedKey.Marshal()) {
			continue
		}
		if err := key.Verify(signedData, signature); err != nil {
			return "", fmt.Errorf("invalid %s commit signature: %w", subject, err)
		}
		return ssh.FingerprintSHA256(key), nil
	}
	return "", fmt.Errorf("%s commit was not signed by a trusted release key", subject)
}

func isCommitAncestor(repo *git.Repository, ancestor, descendant plumbing.Hash) (bool, error) {
	if ancestor == descendant {
		return true, nil
	}
	start, err := repo.CommitObject(descendant)
	if err != nil {
		return false, err
	}
	iter := object.NewCommitPreorderIter(start, nil, nil)
	defer iter.Close()
	found := false
	err = iter.ForEach(func(commit *object.Commit) error {
		if commit.Hash == ancestor {
			found = true
			return io.EOF
		}
		return nil
	})
	if err != nil && !errors.Is(err, io.EOF) {
		return false, err
	}
	return found, nil
}
