package studio

import (
	"context"
	"crypto/tls"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"math/big"
	"net"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

const sessionCookie = "__Host-dora-studio-session"

type Provider struct {
	ID                 string `json:"id"`
	Label              string `json:"label"`
	Endpoint           string `json:"endpoint,omitempty"`
	IncludeStreamUsage bool   `json:"includeStreamUsage,omitempty"`
}

type Config struct {
	PublicOrigin    string
	AgentHostOrigin string
	Providers       map[string]Provider
	SessionTTL      time.Duration
	Logger          *slog.Logger
	Agent           *AgentService
}

type Server struct {
	store *Store
	cfg   Config
}

func NewServer(store *Store, cfg Config) (*Server, error) {
	if store == nil {
		return nil, errors.New("store required")
	}
	u, err := url.Parse(cfg.PublicOrigin)
	if err != nil || u.Scheme != "https" || u.String() != cfg.PublicOrigin {
		return nil, errors.New("public origin must be exact HTTPS origin")
	}
	if cfg.SessionTTL == 0 {
		cfg.SessionTTL = 7 * 24 * time.Hour
	}
	if cfg.Logger == nil {
		cfg.Logger = slog.Default()
	}
	if len(cfg.Providers) == 0 {
		return nil, errors.New("provider catalog required")
	}
	return &Server{store: store, cfg: cfg}, nil
}

func (s *Server) Handler() http.Handler { return http.HandlerFunc(s.serveHTTP) }

func (s *Server) serveHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "private, no-store")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	defer func() {
		if v := recover(); v != nil {
			s.cfg.Logger.Error("request panic", "panic", v, "path", r.URL.Path)
			if !responseCommitted(w) {
				http.Error(w, "", 500)
			}
		}
	}()
	if s.cfg.Agent != nil && strings.HasPrefix(r.URL.Path, "/api/projects/") && strings.Contains(r.URL.Path, "/agent-launch") {
		s.cfg.Agent.HandleAPI(w, r, s)
		return
	}
	switch {
	case r.URL.Path == "/api/auth/register" || r.URL.Path == "/api/auth/login" || r.URL.Path == "/api/admin/invitations":
		s.authRoutes(w, r)
	case r.URL.Path == "/api/session":
		s.sessionRoute(w, r)
	case r.URL.Path == "/api/session/logout":
		s.logoutRoute(w, r)
	case r.URL.Path == "/api/projects" || strings.HasPrefix(r.URL.Path, "/api/projects/"):
		s.projectRoutes(w, r)
	case r.URL.Path == "/api/admin/accounts" || r.URL.Path == "/api/admin/account-audit" || strings.HasPrefix(r.URL.Path, "/api/admin/accounts/"):
		s.adminAccountRoutes(w, r)
	case r.URL.Path == "/api/admin/shared-models" || strings.HasPrefix(r.URL.Path, "/api/admin/shared-models/"):
		s.adminSharedModelRoutes(w, r)
	case r.URL.Path == "/api/admin/model-allowances/batch" || strings.HasPrefix(r.URL.Path, "/api/admin/model-accounts/") || strings.HasPrefix(r.URL.Path, "/api/admin/model-grants/"):
		s.adminAllowanceRoutes(w, r)
	case r.URL.Path == "/api/model-grants" || strings.HasPrefix(r.URL.Path, "/api/model-grants/") || strings.HasPrefix(r.URL.Path, "/api/byok/"):
		s.modelSettingsRoutes(w, r)
	default:
		http.NotFound(w, r)
	}
}

type trackingWriter interface{ Written() bool }

func responseCommitted(w http.ResponseWriter) bool {
	if t, ok := w.(trackingWriter); ok {
		return t.Written()
	}
	return false
}
func jsonResponse(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if value != nil {
		_ = json.NewEncoder(w).Encode(value)
	}
}
func empty(w http.ResponseWriter, status int)    { w.WriteHeader(status) }
func method(w http.ResponseWriter, allow string) { w.Header().Set("Allow", allow); empty(w, 405) }
func sameOrigin(r *http.Request, origin string, required bool) bool {
	v := r.Header.Get("Origin")
	return r.Header.Get("Sec-Fetch-Site") != "cross-site" && ((!required && v == "") || v == origin)
}
func jsonBody(r *http.Request, max int64, dst any) error {
	if !strings.EqualFold(strings.TrimSpace(strings.Split(r.Header.Get("Content-Type"), ";")[0]), "application/json") {
		return errors.New("content-type")
	}
	r.Body = http.MaxBytesReader(nil, r.Body, max)
	d := json.NewDecoder(r.Body)
	d.DisallowUnknownFields()
	if err := d.Decode(dst); err != nil {
		return err
	}
	if err := d.Decode(&struct{}{}); err != io.EOF {
		return errors.New("trailing json")
	}
	return nil
}
func page(r *http.Request, defaultLimit, max int) (string, int, error) {
	q := r.URL.Query()
	for k, v := range q {
		if (k != "after" && k != "limit") || len(v) != 1 {
			return "", 0, errors.New("invalid page")
		}
	}
	after := q.Get("after")
	raw := q.Get("limit")
	if raw == "" {
		raw = strconv.Itoa(defaultLimit)
	}
	n, err := strconv.Atoi(raw)
	if err != nil || n < 1 || n > max {
		return "", 0, errors.New("invalid page")
	}
	return after, n, nil
}
func searchableAccountPage(r *http.Request, defaultLimit, max int) (string, int, string, error) {
	q := r.URL.Query()
	for key, values := range q {
		if (key != "after" && key != "limit" && key != "q") || len(values) != 1 {
			return "", 0, "", errors.New("invalid account page")
		}
	}
	raw := q.Get("limit")
	if raw == "" {
		raw = strconv.Itoa(defaultLimit)
	}
	limit, err := strconv.Atoi(raw)
	query := strings.TrimSpace(q.Get("q"))
	if err != nil || limit < 1 || limit > max || len(query) > 256 || !utf8.ValidString(query) {
		return "", 0, "", errors.New("invalid account page")
	}
	return q.Get("after"), limit, query, nil
}

func sessionToken(r *http.Request) string {
	c, err := r.Cookie(sessionCookie)
	if err != nil || len(c.Value) != 43 {
		return ""
	}
	return c.Value
}
func (s *Server) authenticate(r *http.Request) (*Account, string, error) {
	token := sessionToken(r)
	session, err := s.store.ResolveSession(r.Context(), token)
	if err != nil {
		return nil, token, err
	}
	if session == nil {
		return nil, token, nil
	}
	a, err := s.store.Account(r.Context(), session.AccountID)
	if err != nil {
		return nil, token, err
	}
	if a == nil || !a.Enabled {
		return nil, token, nil
	}
	return a, token, nil
}
func (s *Server) requireAccount(w http.ResponseWriter, r *http.Request) (*Account, string, bool) {
	a, t, err := s.authenticate(r)
	if err != nil {
		empty(w, 500)
		return nil, t, false
	}
	if a == nil {
		empty(w, 401)
		return nil, t, false
	}
	return a, t, true
}
func (s *Server) requireAdmin(w http.ResponseWriter, r *http.Request) (*Account, string, bool) {
	a, t, ok := s.requireAccount(w, r)
	if !ok {
		return nil, t, false
	}
	if !a.Administrator {
		empty(w, 403)
		return nil, t, false
	}
	return a, t, true
}

func (s *Server) issueCookie(w http.ResponseWriter, r *http.Request, account string) {
	token, _, err := s.store.IssueSession(r.Context(), account, s.cfg.SessionTTL)
	if err != nil {
		empty(w, 500)
		return
	}
	http.SetCookie(w, &http.Cookie{Name: sessionCookie, Value: token, Path: "/", MaxAge: int(s.cfg.SessionTTL.Seconds()), Secure: true, HttpOnly: true, SameSite: http.SameSiteLaxMode})
	jsonResponse(w, 200, map[string]any{"version": 1, "account": map[string]string{"accountId": account}})
}

func (s *Server) authRoutes(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		method(w, "POST")
		return
	}
	if r.TLS == nil || !sameOrigin(r, s.cfg.PublicOrigin, true) || r.URL.RawQuery != "" {
		empty(w, 403)
		return
	}
	if r.URL.Path == "/api/admin/invitations" {
		a, t, ok := s.requireAdmin(w, r)
		if !ok {
			return
		}
		var b struct {
			Administrator bool `json:"administrator"`
		}
		if err := jsonBody(r, 2048, &b); err != nil {
			empty(w, 400)
			return
		}
		code, expires, err := s.store.IssueInvite(r.Context(), t, a.AccountID, b.Administrator, 7*24*time.Hour)
		if err != nil {
			writeStoreError(w, err)
			return
		}
		jsonResponse(w, 201, map[string]any{"version": 1, "code": code, "expiresAt": expires})
		return
	}
	if r.URL.Path == "/api/auth/register" {
		var b struct{ Code, AccountID, Password string }
		if err := jsonBody(r, 2048, &b); err != nil {
			empty(w, 400)
			return
		}
		allowed, err := s.store.AllowLoginAttempt(r.Context(), "register:"+digestString(remoteAddress(r)), 20)
		if err != nil {
			empty(w, 500)
			return
		}
		if !allowed {
			empty(w, 429)
			return
		}
		if err := s.store.Register(r.Context(), b.Code, b.AccountID, b.Password); err != nil {
			writeStoreError(w, err)
			return
		}
		s.issueCookie(w, r, b.AccountID)
		return
	}
	var b struct{ AccountID, Password string }
	if err := jsonBody(r, 2048, &b); err != nil {
		empty(w, 400)
		return
	}
	remote := remoteAddress(r)
	ipKey := "login-ip:" + digestString(remote)
	accountKey := "login-account:" + digestString(remote+"\x00"+b.AccountID)
	ipAllowed, err := s.store.AllowLoginAttempt(r.Context(), ipKey, 30)
	if err != nil {
		empty(w, 500)
		return
	}
	accountAllowed, err := s.store.AllowLoginAttempt(r.Context(), accountKey, 10)
	if err != nil {
		empty(w, 500)
		return
	}
	if !ipAllowed || !accountAllowed {
		empty(w, 401)
		return
	}
	ok, err := s.store.VerifyLogin(r.Context(), b.AccountID, b.Password)
	if err != nil {
		empty(w, 500)
		return
	}
	if !ok {
		empty(w, 401)
		return
	}
	if err := s.store.ClearLoginAttempt(r.Context(), accountKey); err != nil {
		empty(w, 500)
		return
	}
	s.issueCookie(w, r, b.AccountID)
}

func remoteAddress(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil {
		return host
	}
	return r.RemoteAddr
}

func (s *Server) sessionRoute(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		method(w, "GET")
		return
	}
	if r.URL.RawQuery != "" || !sameOrigin(r, s.cfg.PublicOrigin, false) {
		empty(w, 400)
		return
	}
	a, _, ok := s.requireAccount(w, r)
	if !ok {
		return
	}
	jsonResponse(w, 200, map[string]any{"version": 1, "account": map[string]string{"accountId": a.AccountID}})
}
func (s *Server) logoutRoute(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		method(w, "POST")
		return
	}
	if r.URL.RawQuery != "" || !sameOrigin(r, s.cfg.PublicOrigin, true) {
		empty(w, 403)
		return
	}
	if err := s.store.RevokeSession(r.Context(), sessionToken(r)); err != nil {
		empty(w, 500)
		return
	}
	http.SetCookie(w, &http.Cookie{Name: sessionCookie, Path: "/", MaxAge: -1, Secure: true, HttpOnly: true, SameSite: http.SameSiteLaxMode})
	empty(w, 204)
}

func projectPath(path string) (id, tail string, ok bool) {
	p := strings.TrimPrefix(path, "/api/projects/")
	if p == path {
		return "", "", false
	}
	parts := strings.Split(p, "/")
	decoded, err := url.PathUnescape(parts[0])
	if err != nil || !validIdentity(decoded, 256) {
		return "", "", false
	}
	if len(parts) > 1 {
		tail = strings.Join(parts[1:], "/")
	}
	return decoded, tail, true
}
func (s *Server) projectRoutes(w http.ResponseWriter, r *http.Request) {
	a, t, ok := s.requireAccount(w, r)
	if !ok {
		return
	}
	if !sameOrigin(r, s.cfg.PublicOrigin, r.Method != "GET") {
		empty(w, 403)
		return
	}
	if expected := r.Header.Get("X-Studio-Account"); expected != "" && expected != url.QueryEscape(a.AccountID) {
		empty(w, 409)
		return
	}
	if r.URL.Path == "/api/projects" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		after, limit, err := page(r, 20, 100)
		if err != nil || len(after) > 256 {
			empty(w, 400)
			return
		}
		items, more, err := s.store.ListProjects(r.Context(), a.AccountID, after, limit)
		if err != nil {
			empty(w, 500)
			return
		}
		var next any = nil
		if more {
			next = items[len(items)-1]["projectId"]
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "items": items, "nextCursor": next})
		return
	}
	id, tail, valid := projectPath(r.URL.Path)
	if !valid {
		empty(w, 404)
		return
	}
	if r.Method == "PUT" && tail == "" {
		var b struct {
			ExpectedAccountID string          `json:"expectedAccountId"`
			RequestID         string          `json:"requestId"`
			BaseRevision      int64           `json:"baseRevision"`
			Name              string          `json:"name"`
			Snapshot          ProjectSnapshot `json:"snapshot"`
		}
		if err := jsonBody(r, 32<<20, &b); err != nil || b.ExpectedAccountID != a.AccountID || b.Snapshot.ProjectID != id {
			empty(w, 400)
			return
		}
		rev, replayed, err := s.store.SaveProject(r.Context(), t, a.AccountID, b.RequestID, b.BaseRevision, b.Name, b.Snapshot)
		if err != nil {
			writeProjectError(w, err)
			return
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "projectId": id, "requestId": b.RequestID, "cloudRevision": rev, "replayed": replayed})
		return
	}
	if r.Method == "DELETE" && tail == "" {
		if r.ContentLength > 0 || r.URL.RawQuery != "" {
			empty(w, 400)
			return
		}
		if err := s.store.DeleteProject(r.Context(), a.AccountID, id); err != nil {
			empty(w, 500)
			return
		}
		empty(w, 204)
		return
	}
	if r.Method != "GET" {
		method(w, "GET")
		return
	}
	if tail == "history" {
		afterRaw, limit, err := page(r, 20, 100)
		after := int64(0)
		if afterRaw != "" {
			after, err = strconv.ParseInt(afterRaw, 10, 64)
		}
		if err != nil || after < 0 {
			empty(w, 400)
			return
		}
		items, more, err := s.store.ProjectHistory(r.Context(), a.AccountID, id, after, limit)
		if err != nil {
			empty(w, 500)
			return
		}
		var next any = nil
		if more {
			next = items[len(items)-1]["cloudRevision"]
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "items": items, "nextCursor": next})
		return
	}
	revision := int64(0)
	if strings.HasPrefix(tail, "versions/") {
		var err error
		revision, err = strconv.ParseInt(strings.TrimPrefix(tail, "versions/"), 10, 64)
		if err != nil || revision < 1 {
			empty(w, 400)
			return
		}
	} else if tail != "" {
		empty(w, 404)
		return
	}
	record, err := s.store.Project(r.Context(), a.AccountID, id, revision)
	if err != nil {
		empty(w, 500)
		return
	}
	if record == nil {
		empty(w, 404)
		return
	}
	jsonResponse(w, 200, map[string]any{"version": 1, "cloudRevision": record.CloudRevision, "name": record.Name, "updatedAt": record.UpdatedAt, "snapshot": record.Snapshot})
}

func (s *Server) adminAccountRoutes(w http.ResponseWriter, r *http.Request) {
	if !sameOrigin(r, s.cfg.PublicOrigin, r.Method != "GET") {
		empty(w, 403)
		return
	}
	a, t, ok := s.requireAdmin(w, r)
	if !ok {
		return
	}
	if r.URL.Path == "/api/admin/accounts" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		after, limit, query, err := searchableAccountPage(r, 20, 100)
		if err != nil {
			empty(w, 400)
			return
		}
		items, more, err := s.store.SearchAccounts(r.Context(), query, after, limit)
		if err != nil {
			empty(w, 500)
			return
		}
		var next any = nil
		if more {
			next = items[len(items)-1].AccountID
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "items": items, "nextCursor": next})
		return
	}
	if r.URL.Path == "/api/admin/account-audit" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		raw, limit, err := page(r, 20, 100)
		after := int64(0)
		if raw != "" {
			after, err = strconv.ParseInt(raw, 10, 64)
		}
		if err != nil {
			empty(w, 400)
			return
		}
		items, more, err := s.store.AccountAudit(r.Context(), after, limit)
		if err != nil {
			empty(w, 500)
			return
		}
		var next any = nil
		if more {
			next = items[len(items)-1]["sequence"]
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "items": items, "nextCursor": next})
		return
	}
	id, err := url.PathUnescape(strings.TrimPrefix(r.URL.Path, "/api/admin/accounts/"))
	if err != nil || !validIdentity(id, 256) {
		empty(w, 400)
		return
	}
	if r.Method == "GET" {
		target, err := s.store.Account(r.Context(), id)
		if err != nil {
			empty(w, 500)
			return
		}
		if target == nil {
			empty(w, 404)
			return
		}
		jsonResponse(w, 200, target)
		return
	}
	if r.Method != "PUT" {
		method(w, "GET, PUT")
		return
	}
	var b struct {
		Enabled         bool  `json:"enabled"`
		Administrator   bool  `json:"administrator"`
		ExpectedVersion int64 `json:"expectedVersion"`
	}
	if err = jsonBody(r, 4096, &b); err != nil {
		empty(w, 400)
		return
	}
	target, err := s.store.UpdateAccount(r.Context(), t, a.AccountID, id, b.Enabled, b.Administrator, b.ExpectedVersion)
	if err != nil {
		writeStoreError(w, err)
		return
	}
	jsonResponse(w, 200, target)
}

func (s *Server) adminSharedModelRoutes(w http.ResponseWriter, r *http.Request) {
	if !sameOrigin(r, s.cfg.PublicOrigin, r.Method != "GET") {
		empty(w, 403)
		return
	}
	a, t, ok := s.requireAdmin(w, r)
	if !ok {
		return
	}
	if r.URL.Path == "/api/admin/shared-models" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		after, limit, err := page(r, 20, 50)
		if err != nil {
			empty(w, 400)
			return
		}
		items, err := s.store.ListConfigurations(r.Context(), "shared", "platform", after, limit+1)
		if err != nil {
			empty(w, 500)
			return
		}
		more := len(items) > limit
		if more {
			items = items[:limit]
		}
		var next any = nil
		if more {
			next = items[len(items)-1].ID
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "items": items, "nextCursor": next})
		return
	}
	p := strings.TrimPrefix(r.URL.Path, "/api/admin/shared-models/")
	parts := strings.Split(p, "/")
	if !validSlug(parts[0], 128) || len(parts) > 2 {
		empty(w, 404)
		return
	}
	id := parts[0]
	resource := ""
	if len(parts) == 2 {
		resource = parts[1]
	}
	config, err := s.store.GetConfiguration(r.Context(), id)
	if err != nil {
		empty(w, 500)
		return
	}
	if r.Method == "GET" && resource == "" {
		if config == nil || config.Kind != "shared" {
			empty(w, 404)
			return
		}
		v, available, _ := s.store.SecretMetadata(r.Context(), "shared", "platform", id)
		api, _ := s.store.Scope(r.Context(), "api", id)
		jsonResponse(w, 200, map[string]any{"version": 1, "configuration": config, "secret": map[string]any{"version": v, "available": available}, "api": api})
		return
	}
	if resource == "secret" {
		if config == nil || config.Kind != "shared" {
			empty(w, 404)
			return
		}
		var b struct {
			ExpectedVersion int64  `json:"expectedVersion"`
			Key             string `json:"key,omitempty"`
			Consent         bool   `json:"consent,omitempty"`
		}
		if r.Method != "PUT" && r.Method != "DELETE" {
			method(w, "PUT, DELETE")
			return
		}
		if err := jsonBody(r, 65536, &b); err != nil {
			empty(w, 400)
			return
		}
		if r.Method == "PUT" {
			if !b.Consent || !validIdentity(b.Key, 16384) {
				empty(w, 400)
				return
			}
			version, err := s.store.PutSecret(r.Context(), "shared", "platform", id, b.ExpectedVersion, []byte(b.Key), a.AccountID, t)
			if err != nil {
				writeStoreError(w, err)
				return
			}
			jsonResponse(w, 200, map[string]any{"version": version, "available": true})
		} else {
			version, err := s.store.RevokeSecret(r.Context(), "shared", "platform", id, b.ExpectedVersion, a.AccountID, t)
			if err != nil {
				writeStoreError(w, err)
				return
			}
			jsonResponse(w, 200, map[string]any{"version": version, "available": false})
		}
		return
	}
	if resource == "limits" {
		if r.Method != "PUT" {
			method(w, "PUT")
			return
		}
		if config == nil {
			empty(w, 404)
			return
		}
		var b struct {
			Enabled     bool   `json:"enabled"`
			Limit       int64  `json:"limit"`
			AmountLimit string `json:"amountLimit"`
		}
		if err := jsonBody(r, 4096, &b); err != nil || b.Limit < 0 || b.Limit > 1000 || decimal(b.AmountLimit) == nil {
			empty(w, 400)
			return
		}
		if err := s.store.ConfigureScope(r.Context(), "api", id, ModelScope{Enabled: b.Enabled, Limit: b.Limit, AmountLimit: b.AmountLimit}, a.AccountID, t); err != nil {
			writeStoreError(w, err)
			return
		}
		api, _ := s.store.Scope(r.Context(), "api", id)
		jsonResponse(w, 200, map[string]any{"version": 1, "api": api})
		return
	}
	if resource != "" {
		empty(w, 404)
		return
	}
	if r.Method != "PUT" {
		method(w, "GET, PUT")
		return
	}
	var b struct {
		ExpectedVersion          int64 `json:"expectedVersion"`
		Label, Model, ProviderID string
		Enabled                  bool
		Pricing                  map[string]string
	}
	if err := jsonBody(r, 4096, &b); err != nil {
		empty(w, 400)
		return
	}
	saved, err := s.store.PutConfiguration(r.Context(), Configuration{ID: id, Kind: "shared", OwnerID: "platform", Label: b.Label, Model: b.Model, ProviderID: b.ProviderID, Enabled: b.Enabled, Pricing: b.Pricing}, b.ExpectedVersion, a.AccountID, t, s.cfg.Providers)
	if err != nil {
		writeStoreError(w, err)
		return
	}
	jsonResponse(w, 200, map[string]any{"version": 1, "configuration": saved})
}

func (s *Server) adminAllowanceRoutes(w http.ResponseWriter, r *http.Request) {
	if !sameOrigin(r, s.cfg.PublicOrigin, r.Method != "GET") {
		empty(w, 403)
		return
	}
	a, t, ok := s.requireAdmin(w, r)
	if !ok {
		return
	}
	if r.URL.Path == "/api/admin/model-allowances/batch" {
		if r.Method != "PUT" {
			method(w, "PUT")
			return
		}
		var b struct {
			AccountIDs []string `json:"accountIds"`
			Account    struct {
				Enabled     bool
				Limit       int64
				AmountLimit string
			} `json:"account"`
			Grant *struct {
				APIID       string `json:"apiId"`
				Enabled     bool
				Limit       int64
				AmountLimit string
			} `json:"grant"`
		}
		if err := jsonBody(r, 32768, &b); err != nil || len(b.AccountIDs) < 1 || len(b.AccountIDs) > 100 || b.Account.Limit < 0 || b.Account.Limit > 1000 || decimal(b.Account.AmountLimit) == nil {
			empty(w, 400)
			return
		}
		if b.Grant != nil {
			configuration, _ := s.store.GetConfiguration(r.Context(), b.Grant.APIID)
			if !validSlug(b.Grant.APIID, 128) || b.Grant.Limit < 0 || b.Grant.Limit > 1000 || decimal(b.Grant.AmountLimit) == nil || configuration == nil || configuration.Kind != "shared" {
				empty(w, 400)
				return
			}
		}
		updates := make([]BatchAllowanceUpdate, 0, len(b.AccountIDs))
		for _, accountID := range b.AccountIDs {
			update := BatchAllowanceUpdate{AccountID: accountID, Account: ModelScope{Enabled: b.Account.Enabled, Limit: b.Account.Limit, AmountLimit: b.Account.AmountLimit}}
			if b.Grant != nil {
				update.Grant = &ModelScope{Enabled: b.Grant.Enabled, Limit: b.Grant.Limit, AmountLimit: b.Grant.AmountLimit, APIID: b.Grant.APIID}
			}
			updates = append(updates, update)
		}
		items, err := s.store.ConfigureAllowancesBatch(r.Context(), updates, a.AccountID, t)
		if err != nil {
			writeStoreError(w, err)
			return
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "items": items})
		return
	}
	if strings.HasPrefix(r.URL.Path, "/api/admin/model-accounts/") {
		p := strings.TrimPrefix(r.URL.Path, "/api/admin/model-accounts/")
		grants := strings.HasSuffix(p, "/grants")
		if grants {
			p = strings.TrimSuffix(p, "/grants")
		}
		id, err := url.PathUnescape(p)
		if err != nil || !validIdentity(id, 256) {
			empty(w, 400)
			return
		}
		if target, _ := s.store.Account(r.Context(), id); target == nil {
			empty(w, 404)
			return
		}
		if grants {
			if r.Method != "GET" {
				method(w, "GET")
				return
			}
			after, limit, err := page(r, 20, 50)
			if err != nil {
				empty(w, 400)
				return
			}
			items, err := s.store.Grants(r.Context(), id, after, limit+1)
			if err != nil {
				empty(w, 500)
				return
			}
			more := len(items) > limit
			if more {
				items = items[:limit]
			}
			var next any = nil
			if more {
				next = items[len(items)-1]["grantId"]
			}
			jsonResponse(w, 200, map[string]any{"version": 1, "items": items, "nextCursor": next})
			return
		}
		if r.Method == "GET" {
			v, err := s.store.Scope(r.Context(), "account", id)
			if err != nil {
				empty(w, 404)
				return
			}
			jsonResponse(w, 200, map[string]any{"version": 1, "id": id, "scope": v})
			return
		}
		if r.Method != "PUT" {
			method(w, "GET, PUT")
			return
		}
		var b struct {
			Enabled     bool
			Limit       int64
			AmountLimit string
		}
		if err := jsonBody(r, 4096, &b); err != nil || b.Limit < 0 || b.Limit > 1000 || decimal(b.AmountLimit) == nil {
			empty(w, 400)
			return
		}
		v := ModelScope{Enabled: b.Enabled, Limit: b.Limit, AmountLimit: b.AmountLimit}
		if err = s.store.ConfigureScope(r.Context(), "account", id, v, a.AccountID, t); err != nil {
			writeStoreError(w, err)
			return
		}
		saved, _ := s.store.Scope(r.Context(), "account", id)
		jsonResponse(w, 200, map[string]any{"version": 1, "id": id, "scope": saved})
		return
	}
	id := strings.TrimPrefix(r.URL.Path, "/api/admin/model-grants/")
	if !validSlug(id, 128) {
		empty(w, 404)
		return
	}
	if r.Method == "GET" {
		v, err := s.store.Scope(r.Context(), "grant", id)
		if err != nil {
			empty(w, 404)
			return
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "id": id, "scope": v})
		return
	}
	if r.Method != "PUT" {
		method(w, "GET, PUT")
		return
	}
	var b struct {
		Enabled                       bool
		Limit                         int64
		AmountLimit, AccountID, APIID string
	}
	if err := jsonBody(r, 4096, &b); err != nil || b.Limit < 0 || b.Limit > 1000 || decimal(b.AmountLimit) == nil {
		empty(w, 400)
		return
	}
	c, _ := s.store.GetConfiguration(r.Context(), b.APIID)
	account, _ := s.store.Account(r.Context(), b.AccountID)
	if c == nil || c.Kind != "shared" || account == nil {
		empty(w, 404)
		return
	}
	v := ModelScope{Enabled: b.Enabled, Limit: b.Limit, AmountLimit: b.AmountLimit, AccountID: b.AccountID, APIID: b.APIID}
	if err := s.store.ConfigureScope(r.Context(), "grant", id, v, a.AccountID, t); err != nil {
		writeStoreError(w, err)
		return
	}
	saved, _ := s.store.Scope(r.Context(), "grant", id)
	jsonResponse(w, 200, map[string]any{"version": 1, "id": id, "scope": saved})
}

func (s *Server) modelSettingsRoutes(w http.ResponseWriter, r *http.Request) {
	if !sameOrigin(r, s.cfg.PublicOrigin, r.Method != "GET") {
		empty(w, 403)
		return
	}
	a, t, ok := s.requireAccount(w, r)
	if !ok {
		return
	}
	if r.URL.Path == "/api/byok/providers" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		items := []Provider{}
		for _, p := range s.cfg.Providers {
			items = append(items, Provider{ID: p.ID, Label: p.Label})
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "providers": items})
		return
	}
	if r.URL.Path == "/api/byok/configurations" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		after, limit, err := page(r, 20, 50)
		if err != nil {
			empty(w, 400)
			return
		}
		items, err := s.store.ListConfigurations(r.Context(), "byok", a.AccountID, after, limit+1)
		if err != nil {
			empty(w, 500)
			return
		}
		more := len(items) > limit
		if more {
			items = items[:limit]
		}
		var next any = nil
		if more {
			next = items[len(items)-1].ID
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "configurations": items, "nextCursor": next})
		return
	}
	if strings.HasPrefix(r.URL.Path, "/api/byok/configurations/") {
		p := strings.TrimPrefix(r.URL.Path, "/api/byok/configurations/")
		secret := strings.HasSuffix(p, "/secret")
		if secret {
			p = strings.TrimSuffix(p, "/secret")
		}
		if !validSlug(p, 128) {
			empty(w, 404)
			return
		}
		c, _ := s.store.GetConfiguration(r.Context(), p)
		if c != nil && (c.Kind != "byok" || c.OwnerID != a.AccountID) {
			empty(w, 404)
			return
		}
		if secret {
			s.byokSecret(w, r, a, t, p, c)
			return
		}
		if r.Method == "GET" {
			if c == nil {
				empty(w, 404)
				return
			}
			jsonResponse(w, 200, c)
			return
		}
		if r.Method != "PUT" {
			method(w, "GET, PUT")
			return
		}
		var b struct {
			Label, Model, ProviderID string
			Enabled                  bool
			ExpectedVersion          int64
		}
		if err := jsonBody(r, 8192, &b); err != nil {
			empty(w, 400)
			return
		}
		saved, err := s.store.PutConfiguration(r.Context(), Configuration{ID: p, Kind: "byok", OwnerID: a.AccountID, Label: b.Label, Model: b.Model, ProviderID: b.ProviderID, Enabled: b.Enabled}, b.ExpectedVersion, a.AccountID, t, s.cfg.Providers)
		if err != nil {
			writeStoreError(w, err)
			return
		}
		status := 200
		if b.ExpectedVersion == 0 {
			status = 201
		}
		jsonResponse(w, status, saved)
		return
	}
	if r.URL.Path == "/api/model-grants" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		after, limit, err := page(r, 20, 50)
		if err != nil {
			empty(w, 400)
			return
		}
		rows, err := s.store.Grants(r.Context(), a.AccountID, after, limit+1)
		if err != nil {
			empty(w, 500)
			return
		}
		pageRows := rows
		if len(pageRows) > limit {
			pageRows = pageRows[:limit]
		}
		configurations := []map[string]any{}
		for _, row := range pageRows {
			grantID := row["grantId"].(string)
			if !validSlug(grantID, 128) {
				continue
			}
			c, _ := s.store.GetConfiguration(r.Context(), row["apiId"].(string))
			if c != nil && c.Kind == "shared" && c.OwnerID == "platform" {
				provider, deployed := s.cfg.Providers[c.ProviderID]
				_, secret, _ := s.store.SecretMetadata(r.Context(), "shared", "platform", c.ID)
				allowance, allowanceErr := s.allowance(r.Context(), a.AccountID, grantID)
				enabled := c.Enabled && deployed && provider.Endpoint != "" && secret && allowanceErr == nil && allowance["state"] == "available"
				configurations = append(configurations, map[string]any{"grantId": grantID, "label": c.Label, "model": c.Model, "enabled": enabled})
			}
		}
		more := len(rows) > limit
		var next any = nil
		if more {
			next = pageRows[len(pageRows)-1]["grantId"]
		}
		jsonResponse(w, 200, map[string]any{"version": 1, "configurations": configurations, "nextCursor": next})
		return
	}
	if strings.HasPrefix(r.URL.Path, "/api/model-grants/") && strings.HasSuffix(r.URL.Path, "/allowance") {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		id := strings.TrimSuffix(strings.TrimPrefix(r.URL.Path, "/api/model-grants/"), "/allowance")
		v, err := s.allowance(r.Context(), a.AccountID, id)
		if errors.Is(err, errNotFound) {
			empty(w, 404)
			return
		}
		if err != nil {
			empty(w, 500)
			return
		}
		jsonResponse(w, 200, v)
		return
	}
	if r.URL.Path == "/api/byok/usage" {
		if r.Method != "GET" {
			method(w, "GET")
			return
		}
		s.byokUsage(w, r, a.AccountID)
		return
	}
	empty(w, 404)
}

func (s *Server) byokSecret(w http.ResponseWriter, r *http.Request, a *Account, token, id string, c *Configuration) {
	if r.Method == "GET" {
		if c == nil {
			empty(w, 404)
			return
		}
		v, available, err := s.store.SecretMetadata(r.Context(), "byok", a.AccountID, id)
		if err != nil {
			empty(w, 500)
			return
		}
		jsonResponse(w, 200, map[string]any{"version": v, "available": available})
		return
	}
	if c == nil {
		empty(w, 404)
		return
	}
	if r.Method != "PUT" && r.Method != "DELETE" {
		method(w, "GET, PUT, DELETE")
		return
	}
	var b struct {
		ExpectedVersion int64
		Key             string
		Consent         bool
	}
	if err := jsonBody(r, 65536, &b); err != nil {
		empty(w, 400)
		return
	}
	if r.Method == "PUT" {
		if !b.Consent || !validIdentity(b.Key, 16384) {
			empty(w, 400)
			return
		}
		v, err := s.store.PutSecret(r.Context(), "byok", a.AccountID, id, b.ExpectedVersion, []byte(b.Key), a.AccountID, token)
		if err != nil {
			writeStoreError(w, err)
			return
		}
		jsonResponse(w, 200, map[string]any{"version": v, "available": true})
	} else {
		v, err := s.store.RevokeSecret(r.Context(), "byok", a.AccountID, id, b.ExpectedVersion, a.AccountID, token)
		if err != nil {
			writeStoreError(w, err)
			return
		}
		jsonResponse(w, 200, map[string]any{"version": v, "available": false})
	}
}

func (s *Server) allowance(ctx context.Context, account, grant string) (map[string]any, error) {
	apiID, ok := s.store.OwnedGrant(ctx, account, grant)
	if !ok {
		return nil, errNotFound
	}
	api, err := s.store.Scope(ctx, "api", apiID)
	if err != nil {
		return nil, err
	}
	acct, err := s.store.Scope(ctx, "account", account)
	if err != nil {
		return nil, err
	}
	g, err := s.store.Scope(ctx, "grant", grant)
	if err != nil {
		return nil, err
	}
	enabled := api.Enabled && acct.Enabled && g.Enabled
	capacity := api.Limit > 0 && acct.Limit > 0 && g.Limit > 0
	available := minimumAvailable(acct, g)
	if apiLimit := decimal(api.AmountLimit); apiLimit != nil && apiLimit.Sign() > 0 {
		available = minimumBigInt(available, scopeAvailable(api))
	}
	state := "available"
	if !enabled {
		state = "unavailable"
	} else if !capacity {
		state = "zero-capacity"
	} else if available.Sign() == 0 {
		state = "insufficient-amount"
	} else if api.Active >= api.Limit || acct.Active >= acct.Limit || g.Active >= g.Limit {
		state = "concurrency"
	}
	var av any = nil
	if enabled && capacity {
		av = available.String()
	}
	return map[string]any{"version": 1, "funding": "platform", "currency": "CNY", "unit": "nano-CNY", "grantId": grant, "state": state, "available": av, "api": map[string]string{"spent": api.Spent, "reserved": api.Reserved, "limit": api.AmountLimit}, "account": map[string]string{"spent": acct.Spent, "reserved": acct.Reserved, "limit": acct.AmountLimit}, "grant": map[string]string{"spent": g.Spent, "reserved": g.Reserved, "limit": g.AmountLimit}}, nil
}
func minimumAvailable(scopes ...*ModelScope) *big.Int {
	var minimum *big.Int
	for _, scope := range scopes {
		minimum = minimumBigInt(minimum, scopeAvailable(scope))
	}
	return orZero(minimum)
}
func scopeAvailable(scope *ModelScope) *big.Int {
	available := orZero(decimal(scope.AmountLimit))
	available.Sub(available, orZero(decimal(scope.Spent)))
	available.Sub(available, orZero(decimal(scope.Reserved)))
	if available.Sign() < 0 {
		available.SetInt64(0)
	}
	return available
}
func minimumBigInt(current, candidate *big.Int) *big.Int {
	if current == nil || candidate.Cmp(current) < 0 {
		return candidate
	}
	return current
}
func orZero(v *big.Int) *big.Int {
	if v == nil {
		return new(big.Int)
	}
	return v
}
func (s *Server) byokUsage(w http.ResponseWriter, r *http.Request, account string) {
	after, limit, err := page(r, 50, 100)
	if err != nil {
		empty(w, 400)
		return
	}
	tx, err := s.store.db.BeginTx(r.Context(), &sql.TxOptions{ReadOnly: true})
	if err != nil {
		empty(w, 500)
		return
	}
	defer tx.Rollback()
	rows, err := tx.QueryContext(r.Context(), `SELECT id,data FROM byok_requests WHERE account_id=? AND id>? ORDER BY id LIMIT ?`, account, after, limit+1)
	if err != nil {
		empty(w, 500)
		return
	}
	defer rows.Close()
	records := []map[string]any{}
	for rows.Next() {
		var id, raw string
		if rows.Scan(&id, &raw) != nil {
			empty(w, 500)
			return
		}
		v, err := decodeByokUsageRecord(id, raw)
		if err != nil {
			empty(w, 500)
			return
		}
		records = append(records, v)
	}
	if err := rows.Err(); err != nil {
		empty(w, 500)
		return
	}
	rows.Close()
	more := len(records) > limit
	if more {
		records = records[:limit]
	}
	var next any = nil
	if more {
		next = records[len(records)-1]["requestId"]
	}
	summary := map[string]*big.Int{"registeredRequests": new(big.Int), "knownUsageRequests": new(big.Int), "pendingUsageRequests": new(big.Int), "inputTokens": new(big.Int), "outputTokens": new(big.Int)}
	all, err := tx.QueryContext(r.Context(), `SELECT id,data FROM byok_requests WHERE account_id=?`, account)
	if err != nil {
		empty(w, 500)
		return
	}
	for all.Next() {
		var id, raw string
		if all.Scan(&id, &raw) != nil {
			all.Close()
			empty(w, 500)
			return
		}
		record, err := decodeByokUsageRecord(id, raw)
		if err != nil {
			all.Close()
			empty(w, 500)
			return
		}
		summary["registeredRequests"].Add(summary["registeredRequests"], big.NewInt(1))
		if record["usage"] == nil {
			summary["pendingUsageRequests"].Add(summary["pendingUsageRequests"], big.NewInt(1))
		} else {
			summary["knownUsageRequests"].Add(summary["knownUsageRequests"], big.NewInt(1))
			usage := record["usage"].(map[string]string)
			summary["inputTokens"].Add(summary["inputTokens"], orZero(decimal(usage["inputTokens"])))
			summary["outputTokens"].Add(summary["outputTokens"], orZero(decimal(usage["outputTokens"])))
		}
	}
	if err := all.Close(); err != nil {
		empty(w, 500)
		return
	}
	if err := tx.Commit(); err != nil {
		empty(w, 500)
		return
	}
	encodedSummary := map[string]string{}
	for key, value := range summary {
		encodedSummary[key] = value.String()
	}
	jsonResponse(w, 200, map[string]any{"version": 1, "funding": "byok", "records": records, "summary": encodedSummary, "nextCursor": next})
}

func decodeByokUsageRecord(id, raw string) (map[string]any, error) {
	var stored struct {
		Binding struct {
			ProjectID       string `json:"projectId"`
			ConfigurationID string `json:"configurationId"`
			Model           string `json:"model"`
		} `json:"binding"`
		Version    int64                      `json:"version"`
		State      string                     `json:"state"`
		Usage      map[string]json.RawMessage `json:"usage"`
		CreatedAt  int64                      `json:"createdAt"`
		RecordedAt *int64                     `json:"recordedAt"`
	}
	if err := json.Unmarshal([]byte(raw), &stored); err != nil || !validIdentity(id, 256) || !validIdentity(stored.Binding.ProjectID, 256) || !validIdentity(stored.Binding.ConfigurationID, 256) || !validIdentity(stored.Binding.Model, 256) || stored.Version < 1 || stored.CreatedAt < 0 || (stored.State != "pending-usage" && stored.State != "recorded") {
		return nil, errors.New("invalid byok usage record")
	}
	record := map[string]any{"requestId": id, "projectId": stored.Binding.ProjectID, "configurationId": stored.Binding.ConfigurationID, "model": stored.Binding.Model, "version": stored.Version, "state": stored.State, "createdAt": stored.CreatedAt, "usage": nil}
	if stored.State == "recorded" {
		if stored.Usage == nil {
			return nil, errors.New("invalid byok usage record")
		}
		usage := map[string]string{}
		for key, value := range stored.Usage {
			decoded := decodeNano(value)
			if decimal(decoded) == nil {
				return nil, errors.New("invalid byok usage record")
			}
			usage[key] = decoded
		}
		if _, ok := usage["inputTokens"]; !ok {
			return nil, errors.New("invalid byok usage record")
		}
		if _, ok := usage["outputTokens"]; !ok {
			return nil, errors.New("invalid byok usage record")
		}
		record["usage"] = usage
	}
	if stored.RecordedAt != nil {
		record["recordedAt"] = *stored.RecordedAt
	}
	return record, nil
}

func writeStoreError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, errUnauthorized):
		empty(w, 401)
	case errors.Is(err, errForbidden):
		empty(w, 403)
	case errors.Is(err, errNotFound):
		empty(w, 404)
	case errors.Is(err, errConflict):
		empty(w, 409)
	case errors.Is(err, errQuota):
		empty(w, 429)
	default:
		empty(w, 500)
	}
}
func writeProjectError(w http.ResponseWriter, err error) {
	switch {
	case errors.Is(err, errUnauthorized):
		empty(w, 401)
	case errors.Is(err, errConflict):
		w.Header().Set("X-Studio-Project-Error", "revision-conflict")
		empty(w, 409)
	case errors.Is(err, errQuota):
		empty(w, 413)
	default:
		empty(w, 400)
	}
}

func ListenAndServeTLS(ctx context.Context, addr, cert, key string, handler http.Handler, logger *slog.Logger) error {
	srv := &http.Server{Addr: addr, Handler: handler, ReadHeaderTimeout: 10 * time.Second, ReadTimeout: 35 * time.Second, WriteTimeout: 11 * time.Minute, IdleTimeout: 90 * time.Second, MaxHeaderBytes: 32 << 10, TLSConfig: &tls.Config{MinVersion: tls.VersionTLS12}}
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		return err
	}
	done := make(chan error, 1)
	go func() { done <- srv.ServeTLS(ln, cert, key) }()
	select {
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
		defer cancel()
		return srv.Shutdown(shutdownCtx)
	case err := <-done:
		return err
	}
}

func DecodeSecretKey(encoded string) ([]byte, error) {
	b, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil || len(b) != 32 {
		return nil, errors.New("secret key must be 32-byte base64")
	}
	return b, nil
}
func ParseProviders(encoded string) (map[string]Provider, error) {
	defaults := map[string]Provider{"deepseek": {ID: "deepseek", Label: "DeepSeek"}, "zai": {ID: "zai", Label: "ZAI"}, "openai": {ID: "openai", Label: "OpenAI"}}
	if encoded == "" {
		return defaults, nil
	}
	raw, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		return nil, err
	}
	var items []Provider
	if err = json.Unmarshal(raw, &items); err != nil {
		return nil, err
	}
	out := map[string]Provider{}
	for _, p := range items {
		u, err := url.Parse(p.Endpoint)
		if err != nil || u.Scheme != "https" || u.Host == "" || u.User != nil || u.RawQuery != "" || u.Fragment != "" || !validSlug(p.ID, 128) {
			return nil, fmt.Errorf("invalid provider %q", p.ID)
		}
		if p.Label == "" {
			p.Label = p.ID
		}
		out[p.ID] = p
	}
	return out, nil
}
