package studio

import (
	"encoding/json"
	"errors"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

var runtimeFiles = map[string]string{
	"/":                         "index.html",
	"/index.html":               "index.html",
	"/studio-runtime.js":        "studio-runtime.js",
	"/studio-runtime.json":      "studio-runtime.json",
	"/dora-player-runtime.js":   "dora-player-runtime.js",
	"/dora-player-runtime.wasm": "dora-player-runtime.wasm",
	"/dora-player-runtime.data": "dora-player-runtime.data",
	"/dora-web-features.json":   "dora-web-features.json",
	"/audio-worklet.js":         "audio-worklet.js",
	"/dora-audio-mixer.wasm":    "dora-audio-mixer.wasm",
}

type runtimeManifest struct {
	EngineBuild   string `json:"engineBuild"`
	EngineVersion string `json:"engineVersion"`
	Profile       string `json:"profile"`
	Entry         string `json:"entry"`
}

// NewRuntimeHandler serves the immutable game Player on a dedicated origin.
// It never shares the authenticated API or Agent Host handler.
func NewRuntimeHandler(root string) (http.Handler, error) {
	root, err := filepath.Abs(root)
	if err != nil {
		return nil, err
	}
	raw, err := os.ReadFile(filepath.Join(root, "studio-runtime.json"))
	if err != nil {
		return nil, err
	}
	var manifest runtimeManifest
	if json.Unmarshal(raw, &manifest) != nil || manifest.EngineBuild == "" || manifest.EngineVersion == "" || manifest.Profile != "dora-preset" || manifest.Entry != "index.html" {
		return nil, errors.New("invalid Studio Player manifest")
	}
	for _, name := range runtimeFiles {
		info, statErr := os.Stat(filepath.Join(root, name))
		if statErr != nil || !info.Mode().IsRegular() {
			return nil, errors.New("incomplete Studio Player build")
		}
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cross-Origin-Opener-Policy", "same-origin")
		w.Header().Set("Cross-Origin-Embedder-Policy", "require-corp")
		// Studio deliberately embeds the Player from its separate origin. COEP on
		// the Studio page rejects that iframe unless the Player opts into
		// cross-origin embedding; the fixed allowlist below remains the resource
		// exposure boundary.
		w.Header().Set("Cross-Origin-Resource-Policy", "cross-origin")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("Cache-Control", "no-store")
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			w.Header().Set("Allow", "GET, HEAD")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		name, ok := runtimeFiles[r.URL.Path]
		query := r.URL.Query()
		validBuildQuery := r.URL.RawQuery == "" || (len(query) == 1 && query.Get("engineBuild") == manifest.EngineBuild)
		if !ok || !validBuildQuery || r.URL.Fragment != "" || strings.Contains(r.URL.Path, "..") {
			http.NotFound(w, r)
			return
		}
		file, openErr := os.Open(filepath.Join(root, name))
		if openErr != nil {
			http.NotFound(w, r)
			return
		}
		defer file.Close()
		info, statErr := file.Stat()
		if statErr != nil || !info.Mode().IsRegular() {
			http.NotFound(w, r)
			return
		}
		http.ServeContent(w, r, name, time.Time{}, file)
	}), nil
}
