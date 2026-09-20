package studio

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/cookiejar"
	"net/http/httptest"
	"net/url"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

const testOrigin = "https://studio.test"

func TestXYWHSoftUsesXMLAgentDecisions(t *testing.T) {
	config, vision := profile("xywhsoft")
	if config["contextWindow"] != 128000 || config["maxTokens"] != 8192 || config["supportsFunctionCalling"] != false || vision != nil {
		t.Fatalf("unexpected XYWH Soft profile: %#v, vision=%#v", config, vision)
	}
}

type testApp struct {
	store  *Store
	server *httptest.Server
	client *http.Client
}

func newTestApp(t *testing.T) *testApp {
	t.Helper()
	key := bytes.Repeat([]byte{7}, 32)
	store, err := OpenStore(filepath.Join(t.TempDir(), "studio.db"), key)
	if err != nil {
		t.Fatal(err)
	}
	srv, err := NewServer(store, Config{PublicOrigin: testOrigin, Providers: map[string]Provider{"deepseek": {ID: "deepseek", Label: "DeepSeek"}}})
	if err != nil {
		t.Fatal(err)
	}
	ts := httptest.NewUnstartedServer(srv.Handler())
	ts.TLS = &tls.Config{MinVersion: tls.VersionTLS12}
	ts.StartTLS()
	jar, _ := cookiejar.New(nil)
	client := ts.Client()
	client.Jar = jar
	t.Cleanup(func() { ts.Close(); store.Close() })
	return &testApp{store, ts, client}
}
func (a *testApp) do(t *testing.T, method, path string, body any, origin bool) (int, map[string]any, http.Header) {
	t.Helper()
	var reader io.Reader
	if body != nil {
		raw, err := json.Marshal(body)
		if err != nil {
			t.Fatal(err)
		}
		reader = bytes.NewReader(raw)
	}
	req, err := http.NewRequest(method, a.server.URL+path, reader)
	if err != nil {
		t.Fatal(err)
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	if origin {
		req.Header.Set("Origin", testOrigin)
	}
	resp, err := a.client.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatal(err)
	}
	var value map[string]any
	if len(bytes.TrimSpace(raw)) > 0 {
		if err = json.Unmarshal(raw, &value); err != nil {
			t.Fatalf("%s %s returned non-json %q: %v", method, path, raw, err)
		}
	}
	return resp.StatusCode, value, resp.Header
}
func mustStatus(t *testing.T, got, want int) {
	t.Helper()
	if got != want {
		t.Fatalf("status %d, want %d", got, want)
	}
}
func register(t *testing.T, a *testApp, code, id string) {
	t.Helper()
	status, _, _ := a.do(t, "POST", "/api/auth/register", map[string]any{"code": code, "accountId": id, "password": "correct horse battery staple"}, true)
	mustStatus(t, status, 200)
}

func TestLoginRateLimitIsSharedAndExpires(t *testing.T) {
	a := newTestApp(t)
	clock := time.Unix(1_800_000_000, 0)
	a.store.now = func() time.Time { return clock }
	code, _, err := a.store.IssueInvite(context.Background(), "", "bootstrap", false, time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	register(t, a, code, "rate-limited-user")
	status, _, _ := a.do(t, "POST", "/api/session/logout", nil, true)
	mustStatus(t, status, 204)
	for attempt := 0; attempt < 10; attempt++ {
		status, _, _ = a.do(t, "POST", "/api/auth/login", map[string]any{"accountId": "rate-limited-user", "password": "wrong password"}, true)
		mustStatus(t, status, 401)
	}
	status, _, _ = a.do(t, "POST", "/api/auth/login", map[string]any{"accountId": "rate-limited-user", "password": "correct horse battery staple"}, true)
	mustStatus(t, status, 401)
	clock = clock.Add(16 * time.Minute)
	status, _, _ = a.do(t, "POST", "/api/auth/login", map[string]any{"accountId": "rate-limited-user", "password": "correct horse battery staple"}, true)
	mustStatus(t, status, 200)
}

func TestUserProjectLifecycle(t *testing.T) {
	a := newTestApp(t)
	code, _, err := a.store.IssueInvite(context.Background(), "", "bootstrap", true, time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	register(t, a, code, "admin-user")
	status, session, _ := a.do(t, "GET", "/api/session", nil, false)
	mustStatus(t, status, 200)
	if session["account"].(map[string]any)["accountId"] != "admin-user" {
		t.Fatal("wrong session projection")
	}
	snapshot := map[string]any{"version": 1, "projectId": "project-1", "revision": 3, "entry": "main.ts", "files": []any{map[string]any{"path": "main.ts", "kind": "text", "text": "print('hello')"}, map[string]any{"path": "Resources/a.bin", "kind": "binary", "base64": "AP8="}}}
	upload := map[string]any{"expectedAccountId": "admin-user", "requestId": "upload-1", "baseRevision": 0, "name": "First project", "snapshot": snapshot}
	reqBody, _ := json.Marshal(upload)
	req, _ := http.NewRequest("PUT", a.server.URL+"/api/projects/project-1", bytes.NewReader(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Origin", testOrigin)
	req.Header.Set("X-Studio-Account", url.QueryEscape("admin-user"))
	resp, err := a.client.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	mustStatus(t, resp.StatusCode, 200)
	status, project, _ := a.do(t, "GET", "/api/projects/project-1", nil, false)
	mustStatus(t, status, 200)
	if project["cloudRevision"] != float64(1) {
		t.Fatalf("unexpected project: %#v", project)
	}
	status, page, _ := a.do(t, "GET", "/api/projects?limit=20", nil, false)
	mustStatus(t, status, 200)
	if len(page["items"].([]any)) != 1 {
		t.Fatalf("unexpected projects: %#v", page)
	}
	status, _, _ = a.do(t, "POST", "/api/session/logout", map[string]any{}, true)
	mustStatus(t, status, 204)
	status, _, _ = a.do(t, "GET", "/api/projects", nil, false)
	mustStatus(t, status, 401)
}

func TestAdministrationModelsAndBYOK(t *testing.T) {
	a := newTestApp(t)
	bootstrap, _, _ := a.store.IssueInvite(context.Background(), "", "bootstrap", true, time.Hour)
	register(t, a, bootstrap, "admin-user")
	status, invite, _ := a.do(t, "POST", "/api/admin/invitations", map[string]any{"administrator": false}, true)
	mustStatus(t, status, 201)
	creatorClient := a.client
	jar, _ := cookiejar.New(nil)
	a.client = &http.Client{Transport: creatorClient.Transport, Jar: jar}
	register(t, a, invite["code"].(string), "creator-user")
	a.client = creatorClient
	status, secondInvite, _ := a.do(t, "POST", "/api/admin/invitations", map[string]any{"administrator": false}, true)
	mustStatus(t, status, 201)
	secondJar, _ := cookiejar.New(nil)
	a.client = &http.Client{Transport: creatorClient.Transport, Jar: secondJar}
	register(t, a, secondInvite["code"].(string), "creator-batch")
	a.client = creatorClient
	status, search, _ := a.do(t, "GET", "/api/admin/accounts?limit=20&q=batch", nil, false)
	mustStatus(t, status, 200)
	searchItems := search["items"].([]any)
	if len(searchItems) != 1 || searchItems[0].(map[string]any)["accountId"] != "creator-batch" {
		t.Fatalf("unexpected account search: %#v", search)
	}
	status, _, _ = a.do(t, "PUT", "/api/admin/shared-models/deepseek-main", map[string]any{"expectedVersion": 0, "label": "DeepSeek", "model": "deepseek-chat", "providerId": "deepseek", "enabled": false, "pricing": map[string]string{"inputNanoCnyPerMillion": "1000000000", "outputNanoCnyPerMillion": "2000000000"}}, true)
	mustStatus(t, status, 200)
	status, _, _ = a.do(t, "PUT", "/api/admin/shared-models/deepseek-main/secret", map[string]any{"expectedVersion": 0, "key": "test-secret", "consent": true}, true)
	mustStatus(t, status, 200)
	status, _, _ = a.do(t, "PUT", "/api/admin/shared-models/deepseek-main/limits", map[string]any{"enabled": true, "limit": 2}, true)
	mustStatus(t, status, 200)
	status, _, _ = a.do(t, "PUT", "/api/admin/shared-models/deepseek-main", map[string]any{"expectedVersion": 1, "label": "DeepSeek", "model": "deepseek-chat", "providerId": "deepseek", "enabled": true, "pricing": map[string]string{"inputNanoCnyPerMillion": "1000000000", "outputNanoCnyPerMillion": "2000000000"}}, true)
	mustStatus(t, status, 200)
	status, batch, _ := a.do(t, "PUT", "/api/admin/model-allowances/batch", map[string]any{
		"accountIds": []string{"creator-batch", "admin-user"},
		"account":    map[string]any{"enabled": true, "limit": 3, "amountLimit": "12000000000"},
		"grant":      map[string]any{"apiId": "deepseek-main", "enabled": true, "limit": 2, "amountLimit": "6000000000"},
	}, true)
	mustStatus(t, status, 200)
	if len(batch["items"].([]any)) != 2 {
		t.Fatalf("unexpected batch receipt: %#v", batch)
	}
	batchAccount, err := a.store.Scope(context.Background(), "account", "creator-batch")
	if err != nil || batchAccount.AmountLimit != "12000000000" || batchAccount.Limit != 3 {
		t.Fatalf("batch account scope missing: %#v %v", batchAccount, err)
	}
	batchGrants, err := a.store.Grants(context.Background(), "creator-batch", "", 10)
	if err != nil || len(batchGrants) != 1 || batchGrants[0]["apiId"] != "deepseek-main" {
		t.Fatalf("batch grant missing: %#v %v", batchGrants, err)
	}
	status, _, _ = a.do(t, "PUT", "/api/admin/model-allowances/batch", map[string]any{
		"accountIds": []string{"creator-batch", "missing-user"},
		"account":    map[string]any{"enabled": true, "limit": 9, "amountLimit": "99000000000"},
	}, true)
	mustStatus(t, status, 404)
	batchAccount, err = a.store.Scope(context.Background(), "account", "creator-batch")
	if err != nil || batchAccount.AmountLimit != "12000000000" || batchAccount.Limit != 3 {
		t.Fatalf("failed batch was not atomic: %#v %v", batchAccount, err)
	}
	status, _, _ = a.do(t, "PUT", "/api/admin/model-accounts/creator-user", map[string]any{"enabled": true, "limit": 2, "amountLimit": "10000000000"}, true)
	mustStatus(t, status, 200)
	status, _, _ = a.do(t, "PUT", "/api/admin/model-grants/grant-1", map[string]any{"accountId": "creator-user", "apiId": "deepseek-main", "enabled": true, "limit": 1, "amountLimit": "5000000000"}, true)
	mustStatus(t, status, 200)
	a.client = &http.Client{Transport: creatorClient.Transport, Jar: jar}
	status, grants, _ := a.do(t, "GET", "/api/model-grants?limit=20", nil, false)
	mustStatus(t, status, 200)
	configurations := grants["configurations"].([]any)
	if len(configurations) != 1 || configurations[0].(map[string]any)["enabled"] != false {
		t.Fatalf("unexpected grants: %#v", grants)
	}
	if _, leaked := configurations[0].(map[string]any)["apiId"]; leaked {
		t.Fatalf("internal API binding leaked: %#v", configurations[0])
	}
	status, allowance, _ := a.do(t, "GET", "/api/model-grants/grant-1/allowance", nil, false)
	mustStatus(t, status, 200)
	if allowance["state"] != "available" {
		t.Fatalf("unexpected allowance: %#v", allowance)
	}
	status, created, _ := a.do(t, "PUT", "/api/byok/configurations/byok-1", map[string]any{"label": "Personal", "model": "deepseek-chat", "providerId": "deepseek", "enabled": true, "expectedVersion": 0}, true)
	mustStatus(t, status, 201)
	if created["version"] != float64(1) {
		t.Fatal("wrong byok version")
	}
	status, _, _ = a.do(t, "PUT", "/api/byok/configurations/byok-1/secret", map[string]any{"expectedVersion": 0, "key": "personal-secret", "consent": true}, true)
	mustStatus(t, status, 200)
	status, meta, _ := a.do(t, "GET", "/api/byok/configurations/byok-1/secret", nil, false)
	mustStatus(t, status, 200)
	if meta["available"] != true {
		t.Fatal("secret not available")
	}
}

func TestLegacyTaggedNanoScope(t *testing.T) {
	a := newTestApp(t)
	raw := `{"enabled":true,"limit":2,"active":0,"amountLimit":{"$nano":"99"},"spent":{"$nano":"2"},"reserved":{"$nano":"3"}}`
	if _, err := a.store.db.Exec(`INSERT INTO model_scopes(kind,id,data) VALUES('account','legacy',?)`, raw); err != nil {
		t.Fatal(err)
	}
	scope, err := a.store.Scope(context.Background(), "account", "legacy")
	if err != nil {
		t.Fatal(err)
	}
	if scope.AmountLimit != "99" || scope.Spent != "2" || scope.Reserved != "3" {
		t.Fatalf("legacy scope not decoded: %#v", scope)
	}
}

func TestByokUsageReportProjectsSafeRecordsAndFullSummary(t *testing.T) {
	a := newTestApp(t)
	code, _, err := a.store.IssueInvite(context.Background(), "", "bootstrap", false, time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	register(t, a, code, "byok-user")
	pending := `{"binding":{"accountId":"byok-user","projectId":"project-1","configurationId":"byok-1","model":"model-a","fingerprint":"must-not-leak"},"version":1,"state":"pending-usage","usage":null,"createdAt":100}`
	recorded := `{"binding":{"accountId":"byok-user","projectId":"project-2","configurationId":"byok-1","model":"model-a","fingerprint":"must-not-leak"},"version":2,"state":"recorded","usage":{"inputTokens":{"$nano":"12"},"outputTokens":{"$nano":"5"},"cachedInputTokens":{"$nano":"3"}},"createdAt":101,"recordedAt":102}`
	if _, err = a.store.db.Exec(`INSERT INTO byok_requests(id,account_id,data) VALUES('request-1','byok-user',?),('request-2','byok-user',?)`, pending, recorded); err != nil {
		t.Fatal(err)
	}
	status, report, _ := a.do(t, "GET", "/api/byok/usage?after=&limit=20", nil, false)
	mustStatus(t, status, 200)
	summary := report["summary"].(map[string]any)
	if summary["registeredRequests"] != "2" || summary["knownUsageRequests"] != "1" || summary["pendingUsageRequests"] != "1" || summary["inputTokens"] != "12" || summary["outputTokens"] != "5" {
		t.Fatalf("incorrect BYOK summary: %#v", summary)
	}
	records := report["records"].([]any)
	if len(records) != 2 {
		t.Fatalf("incorrect BYOK page: %#v", records)
	}
	for _, value := range records {
		record := value.(map[string]any)
		if _, leaked := record["binding"]; leaked || strings.Contains(fmt.Sprint(record), "must-not-leak") {
			t.Fatalf("private BYOK binding leaked: %#v", record)
		}
	}
}

func TestStreamProviderResponseRequiresDoneAndPreservesUsage(t *testing.T) {
	response := "data: {\"choices\":[{\"delta\":{\"content\":\"ok\"}}]}\n\n" +
		"data: {\"choices\":[],\"usage\":{\"prompt_tokens\":10,\"completion_tokens\":5}}\n\n" +
		"data: [DONE]\n\n"
	recorder := httptest.NewRecorder()
	usage, complete := streamProviderResponse(recorder, strings.NewReader(response), 4096)
	if !complete || usage == nil || usage.InputTokens.String() != "10" || usage.OutputTokens.String() != "5" {
		t.Fatalf("stream completion or usage lost: complete=%v usage=%#v", complete, usage)
	}
	if recorder.Body.String() != response {
		t.Fatal("stream bytes changed")
	}
	_, complete = streamProviderResponse(httptest.NewRecorder(), strings.NewReader(strings.TrimSuffix(response, "data: [DONE]\n\n")), 4096)
	if complete {
		t.Fatal("incomplete SSE was treated as settled")
	}
}

func TestAgentLaunchAssetsModelAndLedger(t *testing.T) {
	blocked := make(chan struct{}, 1)
	release := make(chan struct{})
	provider := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer shared-secret" {
			http.Error(w, "", 401)
			return
		}
		var body map[string]any
		if json.NewDecoder(r.Body).Decode(&body) != nil || body["model"] != "deepseek-chat" {
			http.Error(w, "", 400)
			return
		}
		if messages, ok := body["messages"].([]any); ok && len(messages) > 0 {
			if first, ok := messages[0].(map[string]any); ok && first["content"] == "block" {
				blocked <- struct{}{}
				<-release
			}
		}
		jsonResponse(w, 200, map[string]any{"id": "reply-1", "choices": []any{map[string]any{"message": map[string]any{"role": "assistant", "content": "ok"}}}, "usage": map[string]any{"prompt_tokens": 10, "completion_tokens": 5}})
	}))
	defer provider.Close()
	key := bytes.Repeat([]byte{9}, 32)
	store, err := OpenStore(filepath.Join(t.TempDir(), "studio.db"), key)
	if err != nil {
		t.Fatal(err)
	}
	defer store.Close()
	ctx := context.Background()
	invite, _, _ := store.IssueInvite(ctx, "", "bootstrap", true, time.Hour)
	if err = store.Register(ctx, invite, "admin-user", "correct horse battery staple"); err != nil {
		t.Fatal(err)
	}
	token, _, _ := store.IssueSession(ctx, "admin-user", time.Hour)
	providers := map[string]Provider{"deepseek": {ID: "deepseek", Label: "DeepSeek", Endpoint: provider.URL}}
	config, err := store.PutConfiguration(ctx, Configuration{ID: "deepseek-main", Kind: "shared", OwnerID: "platform", Label: "DeepSeek", Model: "deepseek-chat", ProviderID: "deepseek", Enabled: false, Pricing: map[string]string{"inputNanoCnyPerMillion": "1000000000", "outputNanoCnyPerMillion": "2000000000"}}, 0, "admin-user", token, providers)
	if err != nil {
		t.Fatal(err)
	}
	if _, err = store.PutSecret(ctx, "shared", "platform", config.ID, 0, []byte("shared-secret"), "admin-user", token); err != nil {
		t.Fatal(err)
	}
	if err = store.ConfigureScope(ctx, "api", config.ID, ModelScope{Enabled: true, Limit: 2, AmountLimit: "0"}, "admin-user", token); err != nil {
		t.Fatal(err)
	}
	config.Enabled = true
	if _, err = store.PutConfiguration(ctx, *config, 1, "admin-user", token, providers); err != nil {
		t.Fatal(err)
	}
	if err = store.ConfigureScope(ctx, "account", "admin-user", ModelScope{Enabled: true, Limit: 2, AmountLimit: "100000000000"}, "admin-user", token); err != nil {
		t.Fatal(err)
	}
	if err = store.ConfigureScope(ctx, "grant", "grant-1", ModelScope{Enabled: true, Limit: 1, AmountLimit: "50000000000", AccountID: "admin-user", APIID: config.ID}, "admin-user", token); err != nil {
		t.Fatal(err)
	}
	snapshot := ProjectSnapshot{Version: 1, ProjectID: "project-1", Revision: 0, Entry: "main.ts", Files: []ProjectFile{{Path: "main.ts", Kind: "text", Text: "print('hello')"}}}
	if _, _, err = store.SaveProject(ctx, token, "admin-user", "upload-1", 0, "Agent project", snapshot); err != nil {
		t.Fatal(err)
	}
	agent, err := NewAgentService(store, testOrigin, "https://agent.test", filepath.Join("..", "..", "..", "build", "studio-agent-host"), filepath.Join("..", "..", "dist", "agent-host"))
	if err != nil {
		t.Fatal(err)
	}
	defer agent.Close()
	agent.SetProviders(providers)
	agent.client = provider.Client()
	api, err := NewServer(store, Config{PublicOrigin: testOrigin, Providers: providers, Agent: agent})
	if err != nil {
		t.Fatal(err)
	}
	apiServer := httptest.NewTLSServer(api.Handler())
	defer apiServer.Close()
	hostServer := httptest.NewTLSServer(agent.HostHandler())
	defer hostServer.Close()
	request := func(client *http.Client, method, target, origin string, body any) *http.Response {
		var reader io.Reader
		if body != nil {
			raw, _ := json.Marshal(body)
			reader = bytes.NewReader(raw)
		}
		req, _ := http.NewRequest(method, target, reader)
		req.AddCookie(&http.Cookie{Name: sessionCookie, Value: token})
		if origin != "" {
			req.Header.Set("Origin", origin)
		}
		if body != nil {
			req.Header.Set("Content-Type", "application/json")
		}
		resp, err := client.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		return resp
	}
	resp := request(apiServer.Client(), "POST", apiServer.URL+"/api/projects/project-1/agent-launch", testOrigin, nil)
	mustStatus(t, resp.StatusCode, 201)
	var launch map[string]any
	if err = json.NewDecoder(resp.Body).Decode(&launch); err != nil {
		t.Fatal(err)
	}
	resp.Body.Close()
	if generation, ok := launch["generation"].(string); !ok || len(generation) != 36 || strings.Count(generation, "-") != 4 {
		t.Fatalf("Agent generation is not a UUID: %#v", launch)
	}
	launchURL, _ := url.Parse(launch["url"].(string))
	launchID := strings.Split(strings.TrimPrefix(launchURL.Path, "/agent-host/"), "/")[0]
	if len(launchID) != 36 || strings.Count(launchID, "-") != 4 {
		t.Fatalf("Agent launch ID is not a UUID: %q", launchID)
	}
	base := hostServer.URL + strings.TrimSuffix(launchURL.Path, "/index.html")
	resp = request(hostServer.Client(), "GET", base+"/index.html", "", nil)
	mustStatus(t, resp.StatusCode, 200)
	html, _ := io.ReadAll(resp.Body)
	resp.Body.Close()
	if !bytes.Contains(html, []byte("script")) {
		t.Fatal("agent host HTML missing")
	}
	resp = request(hostServer.Client(), "GET", base+"/model-config/grant-1", "", nil)
	mustStatus(t, resp.StatusCode, 200)
	var binding map[string]any
	json.NewDecoder(resp.Body).Decode(&binding)
	resp.Body.Close()
	if binding["grantId"] != "grant-1" {
		t.Fatalf("bad model binding: %#v", binding)
	}
	payload := map[string]any{"model": "deepseek-chat", "messages": []any{map[string]any{"role": "user", "content": "hello"}}, "stream": false, "max_tokens": 64}
	raw, _ := json.Marshal(payload)
	req, _ := http.NewRequest("POST", base+"/model/grant-1", bytes.NewReader(raw))
	req.AddCookie(&http.Cookie{Name: sessionCookie, Value: token})
	req.Header.Set("Origin", "https://agent.test")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Studio-Model-Request-Id", "request-1")
	resp, err = hostServer.Client().Do(req)
	if err != nil {
		t.Fatal(err)
	}
	mustStatus(t, resp.StatusCode, 200)
	var reply map[string]any
	json.NewDecoder(resp.Body).Decode(&reply)
	resp.Body.Close()
	if reply["id"] != "reply-1" {
		t.Fatalf("provider response lost: %#v", reply)
	}
	var ledgerRaw string
	ledgerID := launchURL.Path[strings.Index(launchURL.Path, "/agent-host/")+len("/agent-host/"):]
	ledgerID = strings.Split(ledgerID, "/")[0] + "_request-1"
	if err = store.db.QueryRow(`SELECT data FROM model_requests WHERE id=?`, ledgerID).Scan(&ledgerRaw); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(ledgerRaw, "settled") {
		t.Fatalf("request not settled: %s", ledgerRaw)
	}
	accountScope, err := store.Scope(ctx, "account", "admin-user")
	if err != nil {
		t.Fatal(err)
	}
	if accountScope.Active != 0 || accountScope.Spent == "0" {
		t.Fatalf("usage not settled: %#v", accountScope)
	}
	call := func(id, content string) chan int {
		done := make(chan int, 1)
		go func() {
			payload := map[string]any{"model": "deepseek-chat", "messages": []any{map[string]any{"role": "user", "content": content}}, "stream": false, "max_tokens": 64}
			raw, _ := json.Marshal(payload)
			req, _ := http.NewRequest("POST", base+"/model/grant-1", bytes.NewReader(raw))
			req.AddCookie(&http.Cookie{Name: sessionCookie, Value: token})
			req.Header.Set("Origin", "https://agent.test")
			req.Header.Set("Content-Type", "application/json")
			req.Header.Set("X-Studio-Model-Request-Id", id)
			response, err := hostServer.Client().Do(req)
			if err != nil {
				done <- 0
				return
			}
			io.Copy(io.Discard, response.Body)
			response.Body.Close()
			done <- response.StatusCode
		}()
		return done
	}
	first := call("request-block", "block")
	select {
	case <-blocked:
	case <-time.After(3 * time.Second):
		t.Fatal("first model request did not dispatch")
	}
	second := call("request-wait", "after")
	deadline := time.Now().Add(3 * time.Second)
	queued := false
	for time.Now().Before(deadline) {
		response := request(hostServer.Client(), "GET", base+"/model-queue", "", nil)
		var state map[string]any
		json.NewDecoder(response.Body).Decode(&state)
		response.Body.Close()
		if state["state"] == "queued" && state["position"] == float64(1) {
			queued = true
			break
		}
		time.Sleep(25 * time.Millisecond)
	}
	if !queued {
		t.Fatal("queued model request was not reported")
	}
	close(release)
	if status := <-first; status != 200 {
		t.Fatalf("first queued scenario status %d", status)
	}
	if status := <-second; status != 200 {
		t.Fatalf("second queued scenario status %d", status)
	}
}
