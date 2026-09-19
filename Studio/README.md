# Dora Studio

Dora Studio 是基于 Dora Web 引擎的浏览器游戏创作产品：浏览器负责编辑、编译与试玩，Go 后端负责身份、模型密钥/流控/账务、项目同步与发布，不承担游戏运行和渲染。Agent 编排与完整工具的部署位置仍按设计方案进行浏览器迁移和隔离验证，不预设必须云端执行。

首版面向受邀用户，以一句描述生成游戏为主入口，AI 直接修改并自动试玩，代码始终可编辑；完整迁移现有 Dora Agent 能力，不重新设计 Agent 行为或试玩标准。

同时支持新建项目、上传 `.dora`/ZIP、从外部公开 Git/ZIP 链接复制，以及从人工开放源码并允许 Remix 的 Studio 分享链接 clone。作品可公开链接试玩，源码默认私有。

模型支持管理员提供的共享 API 配置池和用户自带 Key。共享 API 按配置、账号及逐 API 授权限制并发与累计人民币使用额度，预留后按实际用量结算；用户自带 Key 经授权云端加密保存。Agent 在页面关闭或断线后保存检查点并暂停。

当前已有设计文档、独立可点击原型、正式 workspace、共享协议与纯快照编译核心。正式 React 工作室已支持本地创建/编辑/保存/重开、真实浏览器编译试玩，以及首版确定的“邀请码＋账号密码”登录与云项目上传。管理员可导入共享模型配置、人民币费率及加密 Key，设 API 全局并发、账号总额度和逐 API 授权。首页的一句描述会原子新建项目、云上传和同步作者文件，再向原 Dora Agent 投递 prompt；专用 Web 宿主的受保护模型路由能按授权调用部署方固定的 HTTPS 兼容供应商端点并以实际 usage 结算。四个 HTTPS 服务（含本地测试供应商桩）的浏览器联调已证明一次原 Agent 模型请求与一笔人民币账务，不等于真实外部模型生成游戏。Agent 自动写回/编译试玩、BYOK 派发、发布与全产品验收仍未完成，不能把原型模拟交互视为已实现功能。

- [产品与技术设计方案](docs/DESIGN.md)
- [开发进度跟踪表](docs/PROGRESS.md)
- [工程开发与验证](docs/DEVELOPMENT.md)
- [模型网关接线契约与当前缺口](docs/MODEL_GATEWAY.md)
- [受邀登录服务启动与边界](apps/server/LOGIN_SERVICE.md)
- [可点击原型与评审说明](prototype/README.md)
- [上游 Web 运行时设计](../Docs/design/web-runtime/README.md)
- [上游 Web 运行时进度](../Docs/design/web-runtime/PROGRESS.md)

工程采用同仓起步、独立应用、共享能力、独立部署的路线。现有 `Tools/dora-dora` 保留原生 Web IDE 职责；引擎源码仍在 `Source/` 与 `Projects/Web/`，不复制到 Studio。

服务端已统一迁移到 Go，入口为 `cmd/studio-server`，不再保留 Node.js 后端实现。`pnpm build:server` 生成 `build/bin/dora-studio-server`，`pnpm test:server` 执行含竞态检测的服务端测试。环境变量、双 HTTPS 来源和启动示例见 [Go 服务说明](apps/server/README.md)。
