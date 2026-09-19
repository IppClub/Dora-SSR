# Cloud project storage and synchronization

> 2026-09-19：当前实现已迁移至 Go 的 `internal/studio`；本文中的 `.mjs` 模块名是迁移前的设计来源，不是现行部署入口。

## Current integration

The unified account handler mounts authenticated project reads and writes. Session, account and project tables share SQLite for transaction-bound upload authorization. Callers own stores and close them after draining requests.

The workbench presents one project catalog. IndexedDB is the browser authoring workspace and authenticated remote storage is its automatic durable copy; users do not choose between local and cloud projects. A project found on another device is materialized into IndexedDB when opened with the same identity and name. ZIP restore creates an independent project. Timestamped synchronization history can be downloaded without changing the current project.

Normal synchronization is silent. Failures retain the frontend workspace and retry after connectivity returns. Only when the authenticated remote content is newer does the UI ask whether to retain the frontend workspace or adopt the remote content. Comparison loads the exact internal baseline and latest remote snapshot; overlapping changes require explicit choices. Applying a valid result retires the Agent and atomically saves content, checkpoint and synchronization baseline.

## HTTP contract

- GET /api/projects: project metadata pages using after/limit.
- GET /api/projects/:id: latest snapshot.
- GET /api/projects/:id/history: ascending revision pages.
- GET /api/projects/:id/versions/:revision: immutable snapshot.
- PUT /api/projects/:id: {expectedAccountId, requestId, baseRevision, name, snapshot}.

Binary files use canonical base64. PUT requires exact Origin, JSON, strict fields, matching project ID and current authenticated account. expectedAccountId is only a precondition. GET optionally checks X-Studio-Account against encodeURIComponent(accountId), used by snapshot downloads/comparison. Administrators cannot read other owners' private source.

All responses are private/no-store. Receipts contain version, projectId, requestId, cloudRevision and replayed. Invalid input is 400; authentication failure 401; origin rejection 403; missing source 404; precondition conflict 409; body/storage limits 413. Only definitive revision conflicts carry X-Studio-Project-Error: revision-conflict.

Upload collection defaults to 32 MiB and 30 seconds; timeout closes the connection. Global resource and request limits remain deployment work.

## Persistence and recovery

ProjectSnapshot remains the format. Internal synchronization revisions are concurrency tokens and are not a user-facing project version model. New remote records require baseRevision 0. BEGIN IMMEDIATE covers session/account revalidation, CAS, quota, snapshot and receipt insertion. HTTP uses saveSession; plain save is trusted provisioning only. The pre-launch schema requires the project name and has no compatibility migration or fallback for unnamed records.

Owner-scoped request IDs bind normalized content and base revision. Exact retries return original receipts, not necessarily the latest cloud revision. Changed-content reuse fails.

LocalWorkspace v5 persists account/project-bound pending snapshots before dispatch. Unknown outcomes remain pending; explicit resume reuses the original request. Only definitive revision-conflict responses move pending content into the most recent rejected record and permit comparison. Later confirmations and merges preserve it; another rejection replaces it. This is not a complete rejection history.

Merge transactions require matching local revision, cloud baseline and no pending upload. They save checkpoints/content/baseline together; dirty drafts are not silently replaced. Obsolete async completions must not activate another account/project view.

## Limits and remaining work

Provisional per-account defaults: 100 projects, 10,000 historical snapshots, 512 MiB serialized snapshots. Every historical version counts. All server processes must share the policy. Byte counts include JSON/base64, not indexes, receipts, WAL or filesystem overhead. These are not finalized product plans or per-user admin controls.

Missing: archive/object storage, retention/global capacity policies, project deletion tombstones, exhaustive failure/identity races and production backup/restore. Older project tests use seeded sessions; `login.browser.mjs` proves a project upload after actual invitation registration and login across separate frontend/API services. Local HTTPS browser evidence is not actual-device or human acceptance.
