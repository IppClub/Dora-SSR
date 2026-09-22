# Dora Studio Go 后端

Studio 后端由 `cmd/studio-server` 启动，核心实现位于 `internal/studio`。一个进程使用同一 SQLite 数据库并可监听两个 HTTPS 来源：Studio API 与隔离的 Agent Host。旧 Node.js 后端已经移除，避免路由、事务和安全策略形成两套实现。

## 构建与测试

```bash
cd Studio
pnpm build:server
pnpm test:server
```

生成首个管理员邀请码：

```bash
STUDIO_DB_PATH=/absolute/path/studio.db \
STUDIO_SECRET_KEY='<32-byte-base64-key>' \
pnpm invite:bootstrap
```

## 启动环境

必需：

- `STUDIO_DB_PATH`：本机 SQLite 文件绝对路径。
- `STUDIO_PUBLIC_ORIGIN`：前端精确 HTTPS origin。
- `STUDIO_SECRET_KEY`：32 字节主密钥的 Base64；只从部署密钥管理注入。
- `STUDIO_TLS_KEY`、`STUDIO_TLS_CERT`：HTTPS 私钥与证书。

可选同源 Studio Web：

- `STUDIO_WEB_DIR`：Vite 生产构建目录。设置后，API 监听器同时提供受控的 Web 静态资源和 SPA 路由；`/api/*` 始终交给现有鉴权 API。目录在启动时固定清单并拒绝符号链接，不能用作通用文件服务器。

可选 Agent Host：

- `STUDIO_AGENT_HOST_ORIGIN`：与前端不同的精确 HTTPS origin。
- `STUDIO_AGENT_HOST_PORT`：默认 `8900`。
- `STUDIO_AGENT_ENGINE_DIR`：专用 Agent Web 引擎构建目录。
- `STUDIO_AGENT_SUPPORT_DIR`：默认 `dist/agent-host`。
- `STUDIO_PROVIDER_ENDPOINTS`：Base64 编码的受信供应商 JSON 数组；端点只允许 HTTPS。
- `STUDIO_PROVIDER_CA_CERT`：可选的 PEM CA 证书包，用于显式信任企业内网或本地验收的 HTTPS 模型端点；不会关闭主机名或证书链验证。

可选独立游戏 Player：

- `STUDIO_RUNTIME_DIR`：`build/studio-runtime` 的绝对路径；设置后由同一 Go 进程托管第三个、无认证能力的独立 HTTPS Player 来源。
- `STUDIO_RUNTIME_PORT`：默认 `8901`。前端 `VITE_DORA_RUNTIME_URL` 应指向这个来源的 `/index.html`。
- Player、API 与 Agent Host 使用同一套 `STUDIO_TLS_CERT`/`STUDIO_TLS_KEY`，但监听来源彼此独立。本地自签名证书仍必须由浏览器信任；生产环境应使用受信任证书。

API 默认监听 `127.0.0.1:8899`，可用 `STUDIO_API_HOST` 和 `STUDIO_API_PORT` 修改。服务接收 `SIGINT`/`SIGTERM` 后停止接入、等待请求结束、关闭 Agent 启动租约并关闭数据库。

## 本地开发与 Linux 部署包

macOS 本地开发服务器：

```bash
cd Studio
./scripts/studio-macos.sh dev start
./scripts/studio-macos.sh dev rebuild
./scripts/studio-macos.sh dev status
./scripts/studio-macos.sh dev logs
./scripts/studio-macos.sh dev stop
```

首次启动会在忽略目录 `.runtime/dev-server` 生成开发数据库、稳定主密钥及 30 天自签名证书。自签名证书只用于本机开发。可编辑该目录中的 `studio.env` 调整端口或外部模型配置。

在 macOS 打包完整 Linux 部署归档：

```bash
./scripts/studio-macos.sh package amd64 studio.example.com
./scripts/studio-macos.sh package aarch64 studio.example.com
./scripts/studio-macos.sh package all studio.example.com
```

默认三个来源分别使用 `8899`、`8900`、`8901`；可通过 `STUDIO_PACKAGE_PUBLIC_ORIGIN`、`STUDIO_PACKAGE_AGENT_HOST_ORIGIN`、`STUDIO_PACKAGE_RUNTIME_ORIGIN` 覆盖。脚本固定 `CGO_ENABLED=0`，验证 Linux/纯 Go 构建信息，构建全部 Studio 前端，并打包经过能力清单校验的 Agent 引擎和 pthread Studio Player。该 Player 明确启用仅供 Agent 创作命令使用的音乐生成能力；Web IDE 导出的普通 HTML 游戏仍默认关闭 MUSIC。`dev start/restart` 会自动重建不合格的本地产物，`dev rebuild` 或 `STUDIO_PACKAGE_REBUILD_ENGINES=1` 可强制重建。归档输出到 `Studio/build/packages/`。

## 设计边界

- 会话令牌、邀请码和密码明文不入库；密码使用 scrypt。
- 模型密钥使用 AES-256-GCM，AAD 绑定所有权、配置和版本。
- 项目保存、账号管理、额度预留与结算均在 SQLite 事务中完成。
- Agent Host 资源逐次绑定账号、项目、启动代次和当前会话；等待模型槽位时不持有解密密钥。
- 浏览器游戏仍在独立 Player/Agent Web 引擎中运行，Go 服务不执行用户游戏代码。
