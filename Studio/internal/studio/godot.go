package studio

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// The runtime stays on the Player/Agent origins, with the existing isolation
// headers and a fixed public inventory. Do not expose arbitrary package paths.
var godotFiles = []string{"dora-godot.js", "dora-godot.wasm", "shared_gl.mjs", "runtime_bridge.mjs",
	"LICENSE.txt", "COPYRIGHT.txt", "AUTHORS.md"}

func loadGodotAssets(root string) (map[string][]byte, error) {
	raw, err := os.ReadFile(filepath.Join(root, "godot", "manifest.json"))
	if err != nil {
		return nil, err
	}
	var manifest struct {
		Format    string            `json:"package_format"`
		Version   int               `json:"package_version"`
		Godot     string            `json:"godot_version"`
		ABI       int               `json:"bridge_abi"`
		Backend   string            `json:"graphics_backend"`
		Artifacts map[string]string `json:"artifacts"`
	}
	if json.Unmarshal(raw, &manifest) != nil || manifest.Format != "dora-godot-runtime" || manifest.Version != 1 ||
		manifest.Godot != "4.6-stable" || manifest.ABI != 1 || manifest.Backend != "webgl2" {
		return nil, fmt.Errorf("invalid Godot Web runtime manifest")
	}
	files := map[string][]byte{"godot/manifest.json": raw}
	for _, name := range godotFiles {
		b, readErr := os.ReadFile(filepath.Join(root, "godot", name))
		if readErr != nil {
			return nil, readErr
		}
		sum := sha256.Sum256(b)
		if len(b) == 0 || hex.EncodeToString(sum[:]) != manifest.Artifacts[name] {
			return nil, fmt.Errorf("Godot runtime integrity failed: %s", name)
		}
		files["godot/"+name] = b
	}
	return files, nil
}
