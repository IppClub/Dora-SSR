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

## 设计边界

- 会话令牌、邀请码和密码明文不入库；密码使用 scrypt。
- 模型密钥使用 AES-256-GCM，AAD 绑定所有权、配置和版本。
- 项目保存、账号管理、额度预留与结算均在 SQLite 事务中完成。
- Agent Host 资源逐次绑定账号、项目、启动代次和当前会话；等待模型槽位时不持有解密密钥。
- 浏览器游戏仍在独立 Player/Agent Web 引擎中运行，Go 服务不执行用户游戏代码。
