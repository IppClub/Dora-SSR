# 当前账号读取接口

> 2026-09-19：本页保留接口设计和历史验证记录。当前实现位于 `internal/studio`，HTTPS 服务入口为 `cmd/studio-server`，不再存在可部署的 Node.js 服务端模块。

## 邀请码、密码和 HTTPS 服务（当前实现）

Go 存储层在共享 SQLite 中保存一次性邀请码 SHA-256 摘要、到期/核销状态与每账号随机盐的 scrypt 密码派生值；核销建档、密码记录和审计同事务。首位管理员只能在空账号库通过 `pnpm invite:bootstrap` 受信命令领取邀请码；之后管理员可在后台经会话绑定的 `POST /api/admin/invitations` 发创作者/管理员邀请码。原始邀请码只在生成时显示一次。注册和登录分别使用 `POST /api/auth/register`、`POST /api/auth/login`，同源 JSON、实际 TLS 连接和持久失败次数限制；非 TLS 请求拒绝，成功签发随机会话并下发 `__Host-dora-studio-session` Secure/HttpOnly/SameSite=Lax/Path=/ Cookie。账号停用拒绝密码登录。

`cmd/studio-server` 提供真实 HTTPS API 服务；它要求明确的绝对 SQLite 路径、前端 HTTPS origin、稳定 32 字节 base64 密钥、证书/私钥，并不内置试玩渲染。Vite 在提供 `STUDIO_API_URL` 与 TLS 环境时将同源 `/api` 代理到此服务。当前 Go 验收脚本从实际页面完成登录、项目创建/重开、管理页面、Agent 工作区和退出；自签证书和测试上下文的证书放宽只适用于本地。

当前缺口：生产反向代理与证书、持久密钥运维/轮换、密码找回、连接层限流、会话/邀请过期清理、对象存储及真实受邀用户验收。Go 登录失败计数已在共享 SQLite 中跨进程持久化；它不能替代反向代理的连接级防护。

## 管理员账号修改接口

分段 HTTP 测试已验证：入口认证完成、正文未完成时，由独立连接撤销会话或管理员角色，补完正文分别返回 401/403，目标行/版本/审计不变。该证据覆盖这两个时序，不替代服务器请求期限、连接限流、多进程负载或全部故障注入。

admin-account handler 现挂载 PUT `/api/admin/accounts/:accountId`，仅接受 enabled、administrator、expectedVersion，要求 JSON、同源 Origin、最多 4 KiB 正文；操作者来自当前 Cookie 认证，不接受 actorId。写入调用同库会话绑定事务，旧版本/最后管理员返回 409，缺目标 404，失效会话 401、失去管理员资格 403。账号 ID 为单个 URL 编码段；不能借此创建账号、兑换邀请或设置密码。当前仍需部署显式挂载管理 handler，未连接管理 UI；后续应补慢速正文/撤销争用与用户端冲突恢复验收。

## 管理员只读接口

HTTP 写操作使用 `updateByAdministratorSession`，由服务端传入认证取得的 actorId 和请求 Cookie 令牌。账号与会话必须同库，写事务内核对令牌摘要对应操作者、未撤销/未过期，再执行管理员权限、版本和最后管理员检查。缺会话表或数据库失败不会跳过检查。令牌不进入审计；只读入口认证不能替代此写入约束。`updateByAdministrator` 仍是无会话的可信内部操作，不得作为公开写接口的替代路径。

账号写操作的存储基础为 `updateByAdministrator(accountId, changes, {expectedVersion, actorId})`：BEGIN IMMEDIATE 内重新核对操作者启用且为管理员，仅修改已有账号，拒绝移除最后一名启用管理员；检查、CAS、修改与审计同事务。低层 put 仍为受信的引导/恢复入口，不能暴露给 HTTP 或由客户端选择跳过权限；公开写接口已使用会话绑定版本。

`createAdminAccountHandler({studioOrigin,sessions,accounts})` 挂载 GET `/api/admin/accounts` 和 `/api/admin/account-audit`，通过持久会话及当前管理员状态授权。匿名/停用/撤销会话返回 401，普通账号/已撤管理权限返回 403；分页参数只接受 after/limit，响应 private/no-store。统一 handler 和当前 HTTPS 服务已挂载管理读写路由；读取时的权限检查不替代写操作的事务内权限核对。

## 持久账号状态

账号包含 administrator 布尔标记，新增和旧表迁移均默认 false；迁移不会改变既有版本或授予权限。可信 put 可显式设置该标记，未传则保留；与 enabled 共用 CAS 版本和审计。`isAdministrator` 仅当账号存在、启用且标记为 true 时返回 true。公开角色修改与最后一名管理员保护已接入，内部 put 的调用方仍必须先授权，不能将用户提交的 administrator/actorId 直接传入。

可信管理读取 `accounts.list({after,limit})` 按 accountId 游标分页（包含停用账号），`accounts.audit({after,limit})` 按审计 sequence 分页；每页默认 20、最多 100，以额外一行判断 nextCursor，末页为 null。返回数据为独立对象，不包含会话令牌或密码。两者没有自身管理员鉴权，当前不挂载公开 HTTP 路由；调用者必须先验证管理权限。跨页不保证同一时间快照，新写入的较小 accountId 可能需要从头刷新才能发现。

`openAccountStore` 保存登录方式无关的 accountId、enabled 和 version，未知账号默认拒绝；将 `accounts.isAllowed` 注入统一 handler，接口每次读取最新状态。可信 put 要求 actorId 和 expectedVersion，状态变更与审计在同一 BEGIN IMMEDIATE 事务提交，不能用过期版本覆盖他人的停用操作。

低层 `accounts.put` 是受信内部接口，不可直接暴露为注册 API；actorId 参数不等于管理员鉴权。注册由邀请码核销事务写账号，角色/管理员授权与审计查询页面已接入。账号停用不删除会话，重新启用后尚未过期/撤销的会话可恢复；需要强制重新登录时应另行撤销会话。实际模型派发仍需独立核对账号及账本准入，不能只依赖设置接口鉴权。

## 退出当前会话

统一 account-model handler 挂载 `POST /api/session/logout`。要求精确同源 Origin，拒绝跨站、GET 和查询参数；只撤销当前 Cookie 指定的令牌，然后用 Secure/HttpOnly/Path=/、Max-Age=0 清除 Cookie。重复退出返回 204，不撤销该账号其他设备的会话；账号停用不阻止用户退出。存储失败返回 500，不报告已退出。

默认 StudioApp 已提供退出按钮。操作期间立即撤下旧身份，禁止重复点击和自动账号核对，退休的读取请求不能重新恢复身份；仅 204 显示退出成功。失败提示刷新核对，不宣称会话已撤销。HTTPS 浏览器测试经按钮验证 503 失败/核对恢复及成功清除 Cookie，退出前的未保存代码保留并可保存为下一 revision。本机项目不随退出删除，公共设备使用者仍需注意本地作品数据保留。

## Cookie 认证适配

StudioApp 成功退出时广播无敏感内容的 session-invalidated，同源页面收到后重新向服务端读取身份；广播不是身份凭证。BroadcastChannel 不可用时退回已有焦点/手动核对，通知失败不报告退出失败。同源双标签页 HTTPS 回归已验证，不支持跨设备即时推送。

`createSessionAuthenticator({sessions, allowAccount})` 可作为接口的 authenticate 注入：只读取固定 `__Host-dora-studio-session` Cookie，拒绝重复、非法或过大的值；每次查会话后必须由 allowAccount 明确返回 true，再核对会话仍有效，避免异步账号检查期间发生撤销却继续放行。结果只含 accountId，不授权管理员或具体项目操作。

登录路由在 HTTPS 下签发 Secure、HttpOnly、Path=/、无 Domain、SameSite=Lax Cookie；Cookie 读取代码自身不能验证其签发属性，浏览器联调已从实际注册登录验证传输。allowAccount 必须读取真实账号状态，不可部署为恒 true。异常由外层接口处理为不可用，不退回匿名或默认账号。

model-settings.browser.mjs 现使用临时自签 HTTPS 服务、真实会话存储及统一账号/模型 handler。测试通过浏览器预置安全 Cookie（不经过登录签发），确认 HttpOnly 不可由 document.cookie 读取、默认入口可取得身份、撤销后账号与业务接口均拒绝。证书验证仅在该测试 context 放宽，不能沿用至生产。该测试依赖 openssl 创建一次性证书，最终关闭服务并清理临时证书和数据库。

## 登录方式无关的持久会话

`openSessionStore` 是可信服务内部接口，不是登录端点。验证登录凭据/邀请资格之后才允许 issue；每次生成 32 随机字节的不透明令牌，只返回一次，SQLite 保存 SHA-256 摘要、账号、签发/到期/撤销时间。有效期由部署指定，当前接受 1 毫秒至 30 天；到期时刻即失效。resolve、单会话撤销、账号全部现有会话撤销支持独立连接和重开数据库。

账号撤销会话不等于禁用账号，不阻止后续合法登录再次签发。真实认证器与登录路由已核对账号是否启用；会话签发与账户状态的完全事务协调、过期记录清理和会话数量限制尚未实现。session-store 已连接 Cookie 登录/退出路由，但仍不能独立暴露 issue 给客户端；测试时钟注入不是生产客户端参数。

`createSessionRoute({studioOrigin, authenticate})` 提供 `GET /api/session`。部署层注入真实认证函数，每次请求重新取得已验证账号；无账号返回 401，认证失败或非法账号结果返回无正文 500。成功仅返回 `{version:1, account:{accountId}}`，不投影 token、邮箱、角色或其他认证内部字段。

路由拒绝查询参数、跨 Origin 和 Sec-Fetch-Site: cross-site 请求；仅允许 GET，所有本路由响应 private/no-store。它不设置 Cookie、不建立登录会话，也不接受请求头/查询里的账号 ID 作为授权。后续业务接口仍必须独立鉴权，不能信任前端曾读取过的 accountId。

在静态/SPA fallback 之前挂载，并沿用模型设置等业务接口的同一个真实认证器。默认 main.tsx 现通过 StudioApp 读取此接口，启动、窗口重新获得焦点或手动刷新时重新核对；核对期间撤下旧账号并关闭设置，失败不保留旧身份。请求限时 10 秒、正文最多 4 KiB，拒绝重定向和非法响应；401 显示未登录，其他失败显示暂不可读。本地 App 不因身份变化重新挂载，未保存草稿继续保留。

正式登录与邀请已接入；退出路由、会话撤销及同浏览器退出广播也已接入，详见前述实现说明。页面持续聚焦期间不保证实时发现其他设备退出，业务接口须每次重新鉴权。首版方式为邀请码＋密码，双服务浏览器测试使用默认 main.tsx 的真实注册登录；旧设置测试仍使用预置会话。

管理窗口提供账号列表与操作记录两个视图。操作记录通过 `GET /api/admin/account-audit` 分页读取，展示操作者、时间及前后账号状态；历史审计缺失的 administrator 字段显示为“权限未记录”。读取失败清除旧记录，视图切换取消请求，返回列表重新读取。此界面不提供审计修改或删除，也不宣称实时推送外部撤权。

`GET /api/admin/accounts/:accountId` 返回当前账号状态及版本，沿用每次请求的会话与管理员核对，不接受查询参数；不存在返回 404。前端在写入结果不确定时只读核对，不重发修改；状态符合且版本推进后显示服务器当前值，不将其当成原请求的唯一提交凭证。
