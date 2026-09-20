package studio

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestRuntimeHandlerDedicatedStaticSurface(t *testing.T) {
	root := t.TempDir()
	for path, name := range runtimeFiles {
		if path == "/" {
			continue
		}
		content := []byte(name)
		if name == "studio-runtime.json" {
			content = []byte(`{"engineBuild":"test-build","engineVersion":"1.9.3","profile":"dora-preset","entry":"index.html"}`)
		}
		if err := os.WriteFile(filepath.Join(root, name), content, 0o600); err != nil {
			t.Fatal(err)
		}
	}
	handler, err := NewRuntimeHandler(root)
	if err != nil {
		t.Fatal(err)
	}
	for _, path := range []string{"/", "/index.html?engineBuild=test-build", "/dora-player-runtime.wasm"} {
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, "https://player.example"+path, nil))
		if recorder.Code != http.StatusOK {
			t.Fatalf("%s returned %d", path, recorder.Code)
		}
		if recorder.Header().Get("Cross-Origin-Embedder-Policy") != "require-corp" || recorder.Header().Get("Cache-Control") != "no-store" {
			t.Fatalf("%s omitted isolation headers", path)
		}
		if recorder.Header().Get("Cross-Origin-Resource-Policy") != "cross-origin" {
			t.Fatalf("%s cannot be embedded by the Studio origin", path)
		}
	}
	for _, test := range []struct {
		request *http.Request
		status  int
	}{
		{httptest.NewRequest(http.MethodPost, "https://player.example/index.html", nil), http.StatusMethodNotAllowed},
		{httptest.NewRequest(http.MethodGet, "https://player.example/private.txt", nil), http.StatusNotFound},
		{httptest.NewRequest(http.MethodGet, "https://player.example/index.html?engineBuild=stale-build", nil), http.StatusNotFound},
	} {
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, test.request)
		if recorder.Code != test.status {
			t.Fatalf("unexpected status %d", recorder.Code)
		}
	}
}

func TestRuntimeHandlerRejectsIncompleteBuild(t *testing.T) {
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, "studio-runtime.json"), []byte(`{"engineBuild":"test-build","engineVersion":"1.9.3","profile":"dora-preset","entry":"index.html"}`), 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := NewRuntimeHandler(root); err == nil {
		t.Fatal("incomplete runtime build was accepted")
	}
}
