# Dora Studio 受邀登录服务

> 2026-09-19：服务端已统一迁移到 Go。当前入口是 `pnpm server`（`cmd/studio-server`），首次邀请码使用 `pnpm invite:bootstrap`；本文后续出现的 `.mjs` 名称和旧 Dora-Example 脚本仅用于解释历史接口与验证来源，部署与回归以 [Go 服务说明](README.md) 和 `go test -race ./...` 为准。

首版方式是邀请码＋账号密码。账号、邀请码、密码派生值、会话、云项目与模型设置使用同一个绝对路径的 SQLite 数据库。API 后端与前端必须都通过 HTTPS 提供服务，前端 `/api` 同源反向代理到后端；浏览器不应直接跨源访问 API。

Go 后端 `pnpm server` 必需环境：`STUDIO_DB_PATH`（绝对路径，持久磁盘）、`STUDIO_PUBLIC_ORIGIN`（用户实际访问的前端 HTTPS origin）、`STUDIO_SECRET_KEY`（持久保存的 32 字节 base64 密钥）、`STUDIO_TLS_KEY` 与 `STUDIO_TLS_CERT`（PEM 文件）。可选 `STUDIO_API_HOST` 默认为 `127.0.0.1`、`STUDIO_API_PORT` 默认为 `8899`。启动不会自动发邀请码，且不能每次生成新加密密钥替代稳定配置。共享模型派发还要求部署方通过 `STUDIO_PROVIDER_ENDPOINTS` 配置固定 HTTPS 供应商端点；管理员导入的模型/密文 Key 不会让未配置端点的供应商自动可用。

管理员登录后可在正式页面“共享 API 管理”分阶段导入停用的共享供应商/模型配置及人民币输入输出单价、加密 Key、API 全局并发，再启用；“账号与逐 API 授权”可设每个账号的累计人民币上限和并发，以及该账号对某个 API 的单独上限和并发。创作者只看获授权配置及用量，不看共享 Key。启用必须有托管 Key 与正的 API 并发，撤销在用 Key 前先停用配置。当前共享路由可供专用 Agent 宿主调用，但管理员配置、供应商端点、授信和会话都须实际就绪；BYOK 尚未接入此路由，部署前仍须完成生产安全/故障/账务验收。

前端 `pnpm --filter @dora-studio/web dev` 在提供 `STUDIO_API_URL`（后端 HTTPS origin）及相同或适当的 `STUDIO_TLS_KEY`/`STUDIO_TLS_CERT` 时启用 HTTPS 与 `/api` 代理。生产环境应由站点反向代理完成同源 API 转发，并使用受信证书；Vite 自签证书只供本地联调。

启用项目 Agent 会话时，先运行 `bash Tools/build-scripts/build_studio_agent_host.sh` 生成独立专用引擎（默认目录 `result/dora-studio-agent-engine`），不能使用普通游戏 Player。后端额外设置 `STUDIO_AGENT_ENGINE_DIR`、`STUDIO_AGENT_HOST_ORIGIN`（与前端不同的 HTTPS origin）和 `STUDIO_AGENT_HOST_PORT`，会同时开启独立的宿主监听器；启动时校验引擎能力清单、版本及可信宿主支持文件，校验失败即拒绝开启。前端构建/启动时设置公开的 `VITE_STUDIO_AGENT_HOST_ORIGIN` 为同一宿主 origin，正式页面才显示“连接项目 Agent”与首页“新建并准备生成”。空白/导入项目手动连接时需先保存并手动上传云端；一句描述入口会原子保存项目及描述元数据、自动幂等上传后连接。后端以当前受邀会话和云项目所有权签发临时启动记录；连接后可同步本机作者文件。它尚不投递描述或调用模型。

当前宿主仍用 `__Host-dora-studio-session` 主机限定 Cookie 验证私有资源，因此前端、API 和独立宿主需要同一 HTTPS 主机名、不同端口/来源，并由前端同源代理 `/api`；仅换成不同子域名并不能复用该 Cookie。多节点/不同域名的宿主身份传递尚未设计与验收。开发机若工具链与项目锁定版本不同，脚本只允许以 `DORA_WEB_ALLOW_TOOLCHAIN_DRIFT=1` 作本地诊断，不能把漂移构建当作发布证据。

空账号库启动后，在受信终端且仅执行一次 `pnpm invite:bootstrap`（同一 `STUDIO_DB_PATH`）获得首管理员邀请码；请通过可信渠道交付，不记录在工单或公开日志。浏览器打开登录/邀请码注册，创建管理员账号。以后从“账号管理→邀请新账号”签发创作者或管理员邀请码。邀请码默认 7 天有效、只显示一次、一次核销；账号名 3–64 位，密码至少 12 字符。账号停用不会自动撤销现有会话，需强制退出时另行撤销。

测试源码位于 `Dora-Example/Test/DoraStudio`，从 Dora-Example checkout 通过 `DORA_SSR_ROOT=/path/to/Dora-SSR node Test/DoraStudio/run.mjs` 运行构建与单测；浏览器脚本需显式传入文件名且不包含在默认单测中。本地自动双服务验收使用 `node Test/DoraStudio/run.mjs --no-build login.browser.mjs`：先同时启动独立 HTTPS 前端与 API，设置 `STUDIO_LOGIN_TEST_URL`、`STUDIO_LOGIN_TEST_DB`、Playwright/Chrome 路径；测试数据库必须为空，会由脚本发一张 bootstrap 邀请，然后在浏览器实际完成注册登录和云项目上传。测试放宽自签证书验证，不可用于生产。

共享池与授权专项使用相同双服务配置运行 `tests/admin-models.browser.mjs`，测试库须为空；它用测试 Key 验证管理员配置/授权和创作者金额界面及 403 权限。配置专用 Agent 宿主、`STUDIO_PROVIDER_ENDPOINTS` 与本地 HTTPS 测试供应商桩时，脚本还验证一句描述→原 Agent 请求→供应商桩一次调用→实际 usage 结算。两服务/四服务须同时启动，关闭后检查测试端口不再监听；不要用生产账号库运行。这不是外部 AI 游戏生成验收。

三来源专用宿主验收使用 `tests/agent-service.browser.mjs`：同时启动 HTTPS 前端、API、Agent 宿主，设置 `STUDIO_AGENT_TEST_URL`、`STUDIO_AGENT_TEST_DB`、`STUDIO_AGENT_TEST_HOST_URL` 及 Playwright/Chrome 路径。空数据库会从邀请码注册开始；已有测试账号可设置 `STUDIO_AGENT_TEST_ACCOUNT_NAME` 复用并登录。脚本实际建项目、上传云端、连接 WASM 会话、同步作者文件、刷新账号并退出，验证旧宿主链接拒绝读取；它不验证真实模型生成。

专用宿主运行时每分钟向自身来源发送无正文的 `POST /agent-host/:launch/renew`。只有当前会话仍有效、账号未停用且拥有对应云项目和启动代次才续期；五分钟租约过期不可复活，单次启动最长 24 小时。三服务 Chrome 专项已实际观察续期 200、退出后宿主关闭。长时间后台睡眠超过租约或服务重启仍需重新启动并核对 Agent 会话，不能把续期当作跨崩溃恢复。

一句描述准备与失败恢复验收使用相同三服务及环境变量运行 `tests/prompt-preparation.browser.mjs`：第一次云 PUT 可由浏览器拦截为 503，刷新后在同一项目恢复上传、Agent 同步和 prompt 投递，再切换项目返回而不重复投递；空描述不可提交，原描述留本机。已有脚本账号可用 `STUDIO_AGENT_TEST_ACCOUNT_NAME` 与 `STUDIO_AGENT_TEST_ACCOUNT_PASSWORD` 复用。此脚本不验证游戏生成；原描述尚未同步到云项目/ZIP，在另一设备不保证恢复。

仍需生产化：密码找回与修改、连接级及跨实例抗滥用、证书/反向代理、密钥轮换、过期记录清理、备份恢复，以及真实受邀用户验收。
