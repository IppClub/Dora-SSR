package gitjobs

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/go-git/go-git/v5"
)

func TestLFSProgressReaderReportsBytes(t *testing.T) {
	var received int64
	reader := lfsProgressReader{
		reader: strings.NewReader("Dora SSR"),
		progress: func(bytes int64) {
			received += bytes
		},
	}
	data, err := io.ReadAll(reader)
	if err != nil {
		t.Fatal(err)
	}
	if string(data) != "Dora SSR" {
		t.Fatalf("unexpected data: %q", data)
	}
	if received != int64(len(data)) {
		t.Fatalf("reported %d bytes, expected %d", received, len(data))
	}
}

func TestLFSDownloadProgressMessage(t *testing.T) {
	message := lfsDownloadProgressMessage(1, 3, 5*1024*1024, 20*1024*1024)
	if message != "downloading LFS objects 1/3 · 5.0 MiB / 20.0 MiB" {
		t.Fatalf("unexpected progress message: %q", message)
	}
}

func TestDownloadLFSObjectReportsIntermediateBytes(t *testing.T) {
	const chunkSize = 128 * 1024
	payload := bytes.Repeat([]byte("Dora SSR"), chunkSize)
	hash := sha256.Sum256(payload)
	object := lfsBatchObject{
		OID:  hex.EncodeToString(hash[:]),
		Size: int64(len(payload)),
	}
	server := httptest.NewServer(http.HandlerFunc(func(writer http.ResponseWriter, _ *http.Request) {
		flusher, _ := writer.(http.Flusher)
		for offset := 0; offset < len(payload); offset += chunkSize {
			end := offset + chunkSize
			if end > len(payload) {
				end = len(payload)
			}
			_, _ = writer.Write(payload[offset:end])
			if flusher != nil {
				flusher.Flush()
			}
			time.Sleep(time.Millisecond)
		}
	}))
	defer server.Close()

	repoPath := t.TempDir()
	repo, err := git.PlainInit(repoPath, false)
	if err != nil {
		t.Fatal(err)
	}
	var (
		mu       sync.Mutex
		received int64
		updates  int
	)
	err = downloadLFSObject(
		context.Background(),
		repo,
		"origin",
		repoPath,
		object,
		lfsAction{Href: server.URL},
		runOptions{},
		func(bytes int64) {
			mu.Lock()
			received += bytes
			updates++
			mu.Unlock()
		},
	)
	if err != nil {
		t.Fatal(err)
	}
	if received != object.Size {
		t.Fatalf("reported %d bytes, expected %d", received, object.Size)
	}
	if updates < 2 {
		t.Fatalf("expected intermediate progress updates, got %d", updates)
	}
	if !validLFSObject(repoPath, lfsPointer{OID: object.OID, Size: object.Size}) {
		t.Fatal("downloaded LFS object is invalid")
	}
}
