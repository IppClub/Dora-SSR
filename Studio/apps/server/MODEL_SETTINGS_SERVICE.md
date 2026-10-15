# Model settings HTTP integration

> 2026-09-19：当前实现已迁移至 Go 的 `internal/studio`；本文中的 `.mjs` 模块名是迁移前的设计来源，不是现行部署入口。

`createAccountModelHandler` in `account-model-handler.mjs` composes session read/logout, optional HTTPS invite/password login when supplied a `login` store, account administration (list, detail, audit and writes), and these settings routes. Supply the session store, the real `accounts` store, model stores, origin and provider definitions. All routes use that account store for current enabled status; administrative routes additionally check current administrator authority. It owns no stores and does not provide supplier transport. Older model-settings integration tests use manually issued test sessions; `login.browser.mjs` separately proves a real dual-service registration/login and HTTPS Cookie flow.

`createModelSettingsHandler` in `model-settings-handler.mjs` composes the platform grant list/allowance, BYOK provider discovery, configuration list/detail/write, secret management and usage routes. Mount it before a static/SPA handler:

```js
const settings = createModelSettingsHandler({
  studioOrigin, authenticate, catalog, vault, ledger, providers,
});
// Inside the HTTP server request callback:
if (await settings(req, res)) return;
// Continue with other explicitly mounted APIs, then static assets.
```

The caller owns store initialization and shutdown. Authentication is required and has no fixture or anonymous fallback. It must return the current authenticated account, never an account supplied by an arbitrary header or query. The browser integration test deliberately supplies a fixture identity; that is not deployable authentication.

Use `openModelStores` from `model-stores.mjs` for shared deployment assembly. Supply an absolute local database file path, approved provider IDs, externally provisioned vault keys/active key ID, and the optional BYOK configuration count cap. It opens the catalog, vault and strict-version ledger on the same database; no relaxed dispatch option or generated master key is provided. Pass the returned stores to this handler, drain active requests before `stores.close()`, and do not separately close its children. Shutdown is idempotent and attempts all owned handles; partial assembly failure closes already-opened stores. Initialization is not one schema transaction, so a failed startup can leave created tables, but does not delete existing data. The real-App browser fixture uses this assembly with test credentials. It still does not supply production authentication or model transport.

## Mounted routes

| Path | Methods | Purpose |
| --- | --- | --- |
| `/api/model-grants` | GET | Current account's shared configuration choices |
| `/api/model-grants/:id/allowance` | GET | Exact CNY allowance snapshot for an owned grant |
| `/api/byok/providers` | GET | Approved provider IDs and labels |
| `/api/byok/configurations` | GET | Owned configuration metadata pages |
| `/api/byok/configurations/:id` | GET, PUT | Owned metadata lookup, create and versioned update |
| `/api/byok/configurations/:id/secret` | GET, PUT, DELETE | Secret presence/version, consent-gated save and revocation |
| `/api/byok/usage` | GET | Account usage summary and request detail pages |

Shared grant `apiId` must match the corresponding shared catalog configuration `id`. The grant list skips missing/non-shared bindings and grant IDs incompatible with the allowance path. Its cursor advances over examined ledger rows, so an empty displayed page may still have a next page. Do not derive the cursor from the displayed choices. Catalog enablement is not admission: account/grant/API status, current budget and concurrency must be rechecked at actual dispatch.

The platform settings selector is view-only and does not change an Agent's active model. Configuration creation likewise does not validate provider connectivity or store a secret. Secret operations use their separate version and consent flow. Do not wire these read/settings endpoints as model-dispatch authorization.

The composed allowance route always receives the catalog: missing or non-shared configuration bindings return 404, and disabled configurations report unavailable with no available amount while retaining historical ledger totals. The low-level allowance route can be used without a catalog for isolated ledger tests; production settings integration must use the composed handler. These reads are not an atomic dispatch authorization across the catalog and ledger.

Provider discovery and metadata writes derive choices from the same immutable deployment list. Initialize the catalog's provider allowlist from those same definitions. Only IDs and display labels are exposed; endpoint definitions, transport credentials and dispatch are not part of this handler. Empty provider lists disable new BYOK choices without fabricating a provider.

Unknown or malformed paths in `/api/byok` and `/api/model-grants` return private/no-store 404 responses instead of accidentally receiving the HTML app shell. Other namespaces return `false` without touching the response. Route-specific method, Origin, account ownership, body limits and version checks remain in their original handlers.

This is a reusable request handler, not a listening production server. Production still needs authentication/invitation/session wiring, configured providers, secret master-key provisioning, request deadlines/rate limits, coordinated lifecycle policy and deployment configuration. The catalog now enforces a transactional per-account BYOK configuration count cap (see MODEL_CONFIGURATIONS.md); that does not substitute for request rate limits or account authorization. It does not create an Agent or make model calls. The shared real-App browser test exercises this exact composition.
