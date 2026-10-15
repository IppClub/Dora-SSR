package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"syscall"

	"github.com/IppClub/Dora-SSR/Studio/internal/studio"
)

func required(name string) string {
	value := os.Getenv(name)
	if value == "" {
		panic("missing " + name)
	}
	return value
}
func port(name, fallback string) int {
	raw := os.Getenv(name)
	if raw == "" {
		raw = fallback
	}
	value, err := strconv.Atoi(raw)
	if err != nil || value < 1 || value > 65535 {
		panic("invalid " + name)
	}
	return value
}

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stderr, nil))
	key, err := studio.DecodeSecretKey(required("STUDIO_SECRET_KEY"))
	if err != nil {
		logger.Error("configuration failed", "error", err)
		os.Exit(2)
	}
	store, err := studio.OpenStore(required("STUDIO_DB_PATH"), key)
	for i := range key {
		key[i] = 0
	}
	if err != nil {
		logger.Error("database failed", "error", err)
		os.Exit(2)
	}
	defer store.Close()
	providers, err := studio.ParseProviders(os.Getenv("STUDIO_PROVIDER_ENDPOINTS"))
	if err != nil {
		logger.Error("provider configuration failed", "error", err)
		os.Exit(2)
	}
	publicOrigin := required("STUDIO_PUBLIC_ORIGIN")
	cfg := studio.Config{PublicOrigin: publicOrigin, Providers: providers, Logger: logger}
	var agent *studio.AgentService
	if hostOrigin := os.Getenv("STUDIO_AGENT_HOST_ORIGIN"); hostOrigin != "" {
		support := os.Getenv("STUDIO_AGENT_SUPPORT_DIR")
		if support == "" {
			support = filepath.Join("dist", "agent-host")
		}
		agent, err = studio.NewAgentService(store, publicOrigin, hostOrigin, required("STUDIO_AGENT_ENGINE_DIR"), support)
		if err != nil {
			logger.Error("agent service failed", "error", err)
			os.Exit(2)
		}
		agent.SetProviders(providers)
		if caPath := os.Getenv("STUDIO_PROVIDER_CA_CERT"); caPath != "" {
			pem, readErr := os.ReadFile(caPath)
			if readErr != nil {
				logger.Error("provider CA failed", "error", readErr)
				os.Exit(2)
			}
			roots, rootsErr := x509.SystemCertPool()
			if rootsErr != nil || roots == nil {
				roots = x509.NewCertPool()
			}
			if !roots.AppendCertsFromPEM(pem) {
				logger.Error("provider CA failed", "error", "no certificates")
				os.Exit(2)
			}
			transport := http.DefaultTransport.(*http.Transport).Clone()
			transport.TLSClientConfig = &tls.Config{MinVersion: tls.VersionTLS12, RootCAs: roots}
			agent.SetProviderClient(&http.Client{Transport: transport})
		}
		defer agent.Close()
		cfg.Agent = agent
		cfg.AgentHostOrigin = hostOrigin
	}
	api, err := studio.NewServer(store, cfg)
	if err != nil {
		logger.Error("server configuration failed", "error", err)
		os.Exit(2)
	}
	apiHandler := api.Handler()
	if webDir := os.Getenv("STUDIO_WEB_DIR"); webDir != "" {
		apiHandler, err = studio.NewWebHandler(webDir, apiHandler)
		if err != nil {
			logger.Error("Studio Web service failed", "error", err)
			os.Exit(2)
		}
	}
	host := os.Getenv("STUDIO_API_HOST")
	if host == "" {
		host = "127.0.0.1"
	}
	apiAddr := fmt.Sprintf("%s:%d", host, port("STUDIO_API_PORT", "8899"))
	cert, keyPath := required("STUDIO_TLS_CERT"), required("STUDIO_TLS_KEY")
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()
	errorsCh := make(chan error, 3)
	go func() {
		logger.Info("Studio API listening", "address", apiAddr, "frontendOrigin", publicOrigin)
		errorsCh <- studio.ListenAndServeTLS(ctx, apiAddr, cert, keyPath, apiHandler, logger)
	}()
	servers := 1
	if agent != nil {
		servers++
		hostAddr := fmt.Sprintf("%s:%d", host, port("STUDIO_AGENT_HOST_PORT", "8900"))
		go func() {
			logger.Info("Studio Agent host listening", "address", hostAddr)
			errorsCh <- studio.ListenAndServeTLS(ctx, hostAddr, cert, keyPath, agent.HostHandler(), logger)
		}()
	}
	if runtimeDir := os.Getenv("STUDIO_RUNTIME_DIR"); runtimeDir != "" {
		runtimeHandler, runtimeErr := studio.NewRuntimeHandler(runtimeDir)
		if runtimeErr != nil {
			logger.Error("Studio Player service failed", "error", runtimeErr)
			cancel()
			return
		}
		servers++
		runtimeAddr := fmt.Sprintf("%s:%d", host, port("STUDIO_RUNTIME_PORT", "8901"))
		go func() {
			logger.Info("Studio Player listening", "address", runtimeAddr)
			errorsCh <- studio.ListenAndServeTLS(ctx, runtimeAddr, cert, keyPath, runtimeHandler, logger)
		}()
	}
	for i := 0; i < servers; i++ {
		if err := <-errorsCh; err != nil && !errors.Is(err, context.Canceled) {
			logger.Error("listener stopped", "error", err)
			cancel()
		}
	}
}
