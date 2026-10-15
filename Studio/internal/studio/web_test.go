package studio

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestWebHandlerServesAssetsRoutesAndAPI(t *testing.T) {
	root := t.TempDir()
	if err := os.Mkdir(filepath.Join(root, "assets"), 0o700); err != nil {
		t.Fatal(err)
	}
	for name, content := range map[string]string{
		"index.html":               "<!doctype html><title>Studio</title>",
		"assets/index-AbCd1234.js": "console.log('studio')",
		"declarations.json":        "{}",
	} {
		path := filepath.Join(root, filepath.FromSlash(name))
		if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	api := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Studio-API", "yes")
		w.WriteHeader(http.StatusNoContent)
	})
	handler, err := NewWebHandler(root, api)
	if err != nil {
		t.Fatal(err)
	}
	for _, test := range []struct {
		path, body, cache string
		status            int
	}{
		{"/", "Studio", "no-store", http.StatusOK},
		{"/workspace/project", "Studio", "no-store", http.StatusOK},
		{"/assets/index-AbCd1234.js", "studio", "public, max-age=31536000, immutable", http.StatusOK},
		{"/missing.js", "404", "", http.StatusNotFound},
	} {
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, "https://studio.example"+test.path, nil))
		if recorder.Code != test.status || !strings.Contains(recorder.Body.String(), test.body) {
			t.Fatalf("%s returned %d %q", test.path, recorder.Code, recorder.Body.String())
		}
		if test.cache != "" && recorder.Header().Get("Cache-Control") != test.cache {
			t.Fatalf("%s cache policy is %q", test.path, recorder.Header().Get("Cache-Control"))
		}
		if recorder.Header().Get("Cross-Origin-Embedder-Policy") != "require-corp" {
			t.Fatalf("%s omitted isolation headers", test.path)
		}
	}
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, httptest.NewRequest(http.MethodGet, "https://studio.example/api/session", nil))
	if recorder.Code != http.StatusNoContent || recorder.Header().Get("X-Studio-API") != "yes" {
		t.Fatal("API route was not delegated")
	}
}

func TestWebHandlerRejectsUnsafeOrIncompleteTree(t *testing.T) {
	api := http.HandlerFunc(func(http.ResponseWriter, *http.Request) {})
	if _, err := NewWebHandler(t.TempDir(), api); err == nil {
		t.Fatal("missing index was accepted")
	}
	root := t.TempDir()
	if err := os.WriteFile(filepath.Join(root, "index.html"), []byte("ok"), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(filepath.Join(root, "index.html"), filepath.Join(root, "alias.html")); err == nil {
		if _, err := NewWebHandler(root, api); err == nil {
			t.Fatal("symbolic link was accepted")
		}
	}
}
