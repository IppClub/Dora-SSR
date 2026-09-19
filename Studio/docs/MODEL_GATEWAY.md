# Studio Agent 模型网关接线契约

> 2026-09-19：当前网关、密钥、额度、队列和供应商传输实现位于 Go 的 `internal/studio`。本文中的 `.mjs` 名称是迁移前的历史设计映射；现行流式代理逐块转发 SSE，只有完整收到 `[DONE]` 并解析到 usage 才结算，否则保留待核状态。

## 当前代码与真实供应商证据（2026-09-16）

- 隔离 HTTPS 前端、API 与专用 Agent Host 已使用环境中获授权的 DeepSeek Key完成真实调用。Chrome 先从邀请码注册管理员，通过正式管理页面导入 `deepseek-flash`、密文 Key、高峰未命中费率及三级额度，再注册创作者并授权；原 Agent 的 SSE 收据为输入 5,362、输出 34、总 5,396 token，SQLite 请求状态 `settled`，账号人民币已用额增加 ¥0.010996。Key 未回显，临时数据库与证书仅用于本机验收。

- 原 Agent `Assets/Script/Lib/Agent/Utils.ts` 的 `postLLM` 通过 Dora `HttpClient.post` 发送兼容 Chat Completions 的 JSON；流式响应是 SSE，`Authorization: Bearer`、`Content-Type` 和 `Accept` 由原函数固定构造。Agent 会话 `Session.sendPrompt` 可以接收受信宿主注入的 `LLMConfig`，因此可保留原决策循环，而不把真实供应商 Key 注入浏览器。
- 专用 Studio WASM 宿主已增加受信 `prompt`/`resume` 命令：首页明确选择本账号授权的共享模型，描述、grant ID 和命令 ID 随独立项目原子保存；云上传、作者文件同步与持久化完成后释放原 Agent 项目静止锁，再把模型配置投递到原 `Session.sendPrompt`。任务开始由原会话事件展示；投递确认不明先持久记为“已尝试”，不可自动重投。命令确认/文件回写/自动试玩仍不是一个完整交付事务。
- 后端 `executeModelRequest` 已把共享配置目录版本、三级并发、账号及逐 API 金额预留、派发、usage 结算与收据恢复绑定到同一 SQLite 库。专用宿主来源的 `/agent-host/:launch/model/:grant` 现在以当前受邀会话、未过期启动记录、云项目所有权及账号授权查得服务端模型、密文 Key 版本、费率与固定供应商部署连接；正文指纹和原 Agent 请求 ID 绑定原账本，同 ID/正文重复派发被拒。非宿主来源和外账号 grant 被拒。浏览器宿主通过同源 `POST /agent-host/:launch/renew` 每分钟续期短租约，服务端每次重验会话/归属，过期不可复活，单次启动最多 24 小时。BYOK 目前有独立 usage 日志，但没有完整的模型派发准入。
- 新的 `model-provider-transport.mjs` 只接收部署方固定的 HTTPS 兼容端点与服务端密钥，逐块保留原 SSE，必须观察 `[DONE]` 才确认流式完成；非流式回复须有 `choices`。可由可信调用方对支持该扩展的供应商显式启用流式 usage 请求；中断或缺 usage 仍返回 `null`，由原账本暂挂。它把 `prompt_tokens`/`completion_tokens` 及缓存、推理、音频细项归一化为整数计数，细项不重复加入收费总量；供应商拒绝、异常或不完整流不返回成功。
- 管理员共享池及授权已接入正式同源 `/api/admin`：配置目录存服务端人民币输入/输出纳元单价，密钥仅以密文保存并由受信服务端读取，全局 API 并发、账号总金额/并发及账号×API 金额/并发可分别配置。启用共享配置须同时已有密钥和正的 API 容量，撤销在用密钥须先停用配置。所有变更在 SQLite 写事务内重查管理员会话及身份，创作者不可访问；正式前后端浏览器专项已走通管理员导入及创作者 ¥5 授权展示。首页模型候选仅在部署端点、共享密钥及账号三级准入/金额均就绪时可选，不再把仅在目录中启用的供应商误显示为可用；管理员启用动作本身仍未检查部署端点。
- Agent 供应商参数现由 `agent-provider-profiles.mjs` 统一管理，供应商目录、主决策上下文/输出预算、记忆压缩辅助参数和视觉绑定共用同一 profile。首批对齐原版 Agent 的 DeepSeek、ZAI 和 OpenAI；DeepSeek/ZAI 只在压缩请求关闭 thinking，OpenAI 压缩使用 `max_completion_tokens`。未配置受信 HTTPS 端点或服务端密钥的 profile 不构成可用模型。

## 接入前必须满足的边界

1. 共享宿主模型路由已逐请求验证有效账号会话、启动记录、所属云项目和账号授权，正文提供的账号、项目、URL、Key、费率或权限不会成为授权来源；普通试玩来源无该路由。BYOK、跨域宿主身份和同宿主作者代码的能力隔离仍需单独验收。
2. 原 Agent 的三个 `postLLM` 调用路径现可在 `studioGateway` 配置下生成请求 ID 头，服务端绑定完整规范化正文、模型、目录/密钥版本及 grant 指纹；同 ID 重试不重复派发。此 ID 在一次 Agent 调用内稳定，但跨崩溃/任务续接仍可能产生新 ID，需按原任务/步骤持久确定身份或阻断同正文的未核对在途重复。子 Agent、压缩、视觉和音乐链路须实际跑同一入口验证，不能只拦首轮描述。
3. 管理员池/授权具备配置、密文 Key、人民币输入/输出费率及三级上限，固定 HTTPS 连接由部署方 `STUDIO_PROVIDER_ENDPOINTS` 映射，模型路由已消费这些设置并用实际 usage 结算。创作者候选已过滤未部署端点/无密钥/零容量/余额不足/并发饱和的配置；仍须在管理员启用时提示端点未部署、完善费率估算（尤其图像/音频）与供应商/密钥变更审计及真实供应商验收。
4. 浏览器 Agent 的 `LLMConfig.url` 已由宿主同源受保护配置页给出启动记录限定的 Studio 模型路由，`apiKey` 是没有供应商权限的哑值；真实 Key 只在服务端 `withSecret` → 供应商传输范围内出现。JSON/SSE 保留原 Agent 响应语义，SSE `[DONE]` 在账本结算后才送出；缺 usage/供应商失败会暂挂且不送完成标记。流式已有部分内容送出后若供应商失败，HTTP 状态可能仍为 200，必须以缺 `[DONE]` 与账本记录判失败。
5. 取消/断线后不再派发排队调用；已经发出的调用保留并发与金额待核对直至可信终态或审计恢复。部分 SSE 已发往 Agent 也不能以缺 `[DONE]` 当作完成。前端选择模型与资金来源须显式、按账号隔离；不自动换配置、模型或转 BYOK。

四服务 HTTPS 浏览器专项已证明受邀首页→独立项目→原 Agent WASM 任务→测试供应商请求→共享双层金额结算；故意不匹配测试 Key 时供应商拒绝，账本保留 `in-flight` 待核而不伪结算。随后真实 DeepSeek 专项完成外部 SSE 与 usage 结算，满足 #71。它仍没有证明真实模型会自主完成游戏编辑/试玩、BYOK、子 Agent/音乐等全链路、跨崩溃请求身份或排队自动恢复。

新增的 `tests/gateway-controls.browser.mjs` 进一步从正式管理界面验证逐 API 零余额、配置停用、供应商拒绝及恢复；前两者不会再向创作者提供可选模型，拒绝后的原请求保持在途待核。真实 DeepSeek 专项与这组本地可重复失败矩阵共同闭合模型网关门槛；随后真实 DeepSeek 游戏主旅程以 16 笔请求、147,472 输入/3,325 输出 token、¥0.321544 完成首轮及两次继续修改，三轮原工具 Player PNG 均非空且可区分。

新隔离环境可先运行 `tests/real-model-setup.browser.mjs`：脚本只按环境变量名读取已获授权的供应商 Key，并通过正式管理页面输入，绝不输出 Key；它创建管理员、创作者、共享配置和额度。已有环境直接运行 `tests/real-model.browser.mjs`，只传 HTTPS URL、SQLite 路径及创作者登录，按需用 `STUDIO_REAL_MODEL_LABEL` 指定配置短名称；脚本发起一次无工具短回复并核对新增 `finish`、非零 usage、`settled` 状态和人民币已用金额增量。

完整游戏验收使用 `tests/real-game.browser.mjs`，还需配置独立 Player 的 `VITE_DORA_RUNTIME_URL` 与 `VITE_DORA_ENGINE_BUILD`。脚本设置每轮 ¥0.65 安全阈值，完成首轮、两次继续描述、刷新/503 恢复、逐轮源码与 PNG 核验、checkpoint 和唯一结算检查；`tests/real-project-isolation.browser.mjs` 再用第二个受邀账号检查项目读取隔离。供应商 Key 只从授权环境变量进入管理员密码输入框，三个脚本均不打印或保存 Key。
