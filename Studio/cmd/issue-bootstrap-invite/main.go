package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/IppClub/Dora-SSR/Studio/internal/studio"
)

func main() {
	path := os.Getenv("STUDIO_DB_PATH")
	if path == "" {
		fmt.Fprintln(os.Stderr, "missing STUDIO_DB_PATH")
		os.Exit(2)
	}
	key := make([]byte, 32)
	if raw := os.Getenv("STUDIO_SECRET_KEY"); raw != "" {
		decoded, err := base64.StdEncoding.DecodeString(raw)
		if err != nil || len(decoded) != 32 {
			fmt.Fprintln(os.Stderr, "invalid STUDIO_SECRET_KEY")
			os.Exit(2)
		}
		copy(key, decoded)
	}
	store, err := studio.OpenStore(path, key)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer store.Close()
	code, expires, err := store.IssueInvite(context.Background(), "", "bootstrap", true, 7*24*time.Hour)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"code": code, "expiresAt": expires, "administrator": true})
}
