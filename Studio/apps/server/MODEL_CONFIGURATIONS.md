# 非秘密模型配置目录

> 2026-09-19：当前实现已迁移至 Go 的 `internal/studio`；本文中的 `.mjs` 模块名是迁移前的设计来源，不是现行部署入口。

model-configuration-store.mjs 保存配置 ID、资金来源、所属账号、显示名、模型、供应商引用、启用状态和版本。只允许部署提供的 providerIds，目录不保存 Key、任意服务 URL 或请求头；实际供应商定义与出站安全策略尚需实现。

put 是可信内部接口：调用方负责管理员/用户权限，actorId 必须来自认证上下文。新记录 expectedVersion=0，更新使用原版本；已有 ID 的资金来源和所属账号不可转移。配置写入与审计同一事务提交。get 为内部读取；listOwnedByok/ownedByok 按账号过滤，仍不能用客户端账号参数代替身份认证。

authorizeOwnedByok 将平台认证结果和持久配置归属结合，可直接用于 BYOK secret 路由。停用配置仍允许所属用户管理/撤销托管 Key；实际模型派发必须另外检查 enabled、供应商定义、账号状态和任务执行授权。

密钥版本、配置版本和额度账本各有生命周期，当前目录不自动把配置变更同步成共享 API 额度或请求费率。正式管理服务需协调这些变更，不能以非秘密目录存在宣称完整配置导入完成。

测试覆盖持久重开、归属不可转移、供应商白名单副本隔离、审计故障回滚、跨账号查询拒绝；真实 App 配置列表、创建、核对和密钥 UI 已接通统一模型设置处理器，测试使用目录判断归属，但登录身份仍是 fixture。身份系统、生产供应商定义和真实调用尚未接入。

GET /api/byok/configurations 列出认证账号自己的 BYOK 配置，支持 after/limit（最多 50）。显式投影 ID、名称、模型、供应商引用、启用状态和版本，不返回 ownerId、密钥或内部未来扩展字段。停用配置仍在列表中，供用户查看及撤销密钥；列表存在不授权实际调用。HTTP 测试验证账号隔离、共享配置不混入、末页游标及非法参数拒绝。配置列表 UI 已通过真实 App 测试，正式服务部署尚待接入。
# BYOK metadata write boundary

`openModelConfigurationStore` accepts deployment setting `maxByokConfigurationsPerAccount` (default 100, nonnegative safe integer). This is a technical storage cap, not a model concurrency or monetary allowance. All BYOK records, including disabled ones, count; shared records do not. New records check the count within the same `BEGIN IMMEDIATE` transaction as insertion and audit. Existing records remain editable after the cap is lowered, including to zero. All server instances sharing the database must use the same configured cap. There is no per-user override/admin UI or deletion lifecycle yet. The write route returns 429 on capacity rejection; the UI reports a platform restriction without automatic retry.

The same configuration path supports authenticated `GET`, projecting only owned BYOK public metadata. The creation form retains its request ID while mounted and uses this lookup after an uncertain write; lookup failure does not prove the write failed and must never trigger an automatic replacement create. Closing/reloading the form currently loses this in-memory recovery ID, so durable recovery remains future work. Neither lookup nor creation invokes a provider.

`model-byok-configuration-write-route.mjs` provides `PUT /api/byok/configurations/:id` with `label`, `model`, `providerId`, `enabled`, and `expectedVersion`. The caller chooses a stable non-secret configuration ID (for example a UUID); create uses version zero and subsequent updates require the current version. Ambiguous writes must be reconciled by reading the owned catalog rather than automatically creating a different ID.

Identity comes exclusively from authentication, rechecked after bounded body delivery. Writes require the configured Origin, strict UTF-8 JSON, an 8 KiB limit and a deployment-approved provider reference. Neither arbitrary endpoints nor secrets are accepted. Other owners and shared configurations cannot be edited. The existing synchronous catalog transaction performs CAS and audit atomically. Configuration enablement is not model dispatch authorization and saving does not validate supplier connectivity.

The HTTP handler is connected to the settings creation form in the real-App browser fixture, but is not mounted in a production authenticated service. `model-byok-providers-route.mjs` exposes authenticated public provider choices (ID and label only); deployment must supply this list and the write/catalog allowlists from the same approved definitions. Deployment must enforce request deadlines/rate limits and configuration resource quotas. Production provider definitions and configuration/secret/ledger lifecycle coordination remain separate integration work.
