package studio

import (
	"errors"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

var immutableWebAsset = regexp.MustCompile(`-[A-Za-z0-9_-]{8,}\.[A-Za-z0-9]+$`)

// NewWebHandler serves a verified Vite distribution and keeps API routes on
// the existing authenticated handler. The file inventory is fixed at startup,
// so files added later cannot accidentally become public.
func NewWebHandler(root string, api http.Handler) (http.Handler, error) {
	if api == nil {
		return nil, errors.New("API handler required")
	}
	root, err := filepath.Abs(root)
	if err != nil {
		return nil, err
	}
	files := map[string]string{}
	err = filepath.WalkDir(root, func(path string, entry os.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		info, infoErr := entry.Info()
		if infoErr != nil {
			return infoErr
		}
		if info.Mode()&os.ModeSymlink != 0 {
			return errors.New("Studio Web directory contains a symbolic link")
		}
		if entry.IsDir() {
			return nil
		}
		if !info.Mode().IsRegular() {
			return errors.New("Studio Web directory contains a special file")
		}
		relative, relativeErr := filepath.Rel(root, path)
		if relativeErr != nil {
			return relativeErr
		}
		files["/"+filepath.ToSlash(relative)] = path
		return nil
	})
	if err != nil {
		return nil, err
	}
	index, ok := files["/index.html"]
	if !ok {
		return nil, errors.New("Studio Web directory is missing index.html")
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/api" || strings.HasPrefix(r.URL.Path, "/api/") {
			api.ServeHTTP(w, r)
			return
		}
		w.Header().Set("Cross-Origin-Opener-Policy", "same-origin")
		w.Header().Set("Cross-Origin-Embedder-Policy", "require-corp")
		w.Header().Set("Cross-Origin-Resource-Policy", "same-origin")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			w.Header().Set("Allow", "GET, HEAD")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		requestPath := r.URL.Path
		if requestPath == "/" {
			requestPath = "/index.html"
		}
		file, found := files[requestPath]
		if !found && !strings.Contains(filepath.Base(requestPath), ".") {
			file, found = index, true
			requestPath = "/index.html"
		}
		if !found || strings.Contains(requestPath, "\\") || strings.Contains(requestPath, "..") {
			http.NotFound(w, r)
			return
		}
		if requestPath == "/index.html" {
			w.Header().Set("Cache-Control", "no-store")
		} else if immutableWebAsset.MatchString(filepath.Base(requestPath)) {
			w.Header().Set("Cache-Control", "public, max-age=31536000, immutable")
		} else {
			w.Header().Set("Cache-Control", "no-cache")
		}
		opened, openErr := os.Open(file)
		if openErr != nil {
			http.NotFound(w, r)
			return
		}
		defer opened.Close()
		info, statErr := opened.Stat()
		if statErr != nil || !info.Mode().IsRegular() {
			http.NotFound(w, r)
			return
		}
		http.ServeContent(w, r, filepath.Base(file), time.Time{}, opened)
	}), nil
}
