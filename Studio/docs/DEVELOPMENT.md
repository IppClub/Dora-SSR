# Studio 开发与验证

## Go 后端迁移验证（2026-09-19）

Studio 可部署后端已全部迁移到 `cmd/studio-server` 与 `internal/studio`，旧 `apps/server/*.mjs` 实现已删除。服务端回归使用 `go test -race ./...`，覆盖真实 TLS Cookie 注册/登录、持久限流、项目快照、管理员与模型配置、密钥、额度、BYOK 兼容投影、Agent Host、真实 HTTPS 供应商代理、SSE 完整性、账务结算与并发排队。`pnpm build` 同时构建 Web、Agent Host 和 Go 二进制。

本机用户操作验收使用 `scripts/go-backend-acceptance.mjs` 驱动系统 Chrome，依次执行登录、创建项目、返回首页后重开、账号管理、共享模型设置、Agent 工作区和退出登录，并保存 `apps/web/artifacts/go-backend/result.json` 与截图。该脚本只允许在显式测试 URL 下使用 `--ignore-certificate-errors` 接受本机自签证书，不能作为生产浏览器参数。

完整 Agent 游戏验收使用 `scripts/go-agent-game-acceptance.mjs` 与 `scripts/rich-game-fixture-provider.mjs`：从空数据库注册管理员和创作者，经正式管理页面配置加密共享 Key、API/账号/逐 API 额度，创作者选择模型后连续完成三轮创作。第一轮建立平台、角色和点击玩法，第二轮增加雨景，第三轮增加星光目标和终点；每轮原 Agent 都独立调用 `edit_file → build → previewGame`，真实隔离 Player 生成一帧画面，源码自动写回，账本金额递增且预留归零。脚本还防止把上一轮的“已完成”误认成新任务终态，逐帧检查深绿场景、蓝色雨滴和黄色星光，最后模拟用户点击“编译项目”“运行游戏”和画布，核对最终 READY/点击日志。结果、三轮画面和最终运行截图保存于 `apps/web/artifacts/go-agent-multiround/`。模型决策由确定性的本地 HTTPS 桩模拟，验证的是多轮完整产品链路而非外部模型创作质量。

## 当前验证口径与下一道工程门槛（2026-09-16）

测试源码已统一迁移到 `Dora-Example/Test/DoraStudio`，Studio 仓库不再保留副本。当前完整构建与 Node.js 单测从 Dora-Example checkout 执行：`DORA_SSR_ROOT=/path/to/Dora-SSR node Test/DoraStudio/run.mjs`；单独运行浏览器脚本可追加 `--no-build 脚本文件名`。本文旧记录中的 `tests/<name>` 均指 `Dora-Example/Test/DoraStudio/tests/<name>`。

当前源码通过上述命令构建与单测。真实 DeepSeek `deepseek-flash` 已在隔离 HTTPS 前端/API/Agent Host/Player 环境完成首轮及两次同项目继续描述：三轮分别由原 Agent 调用编辑、`build` 和 `previewGame`，作者 r1→r2→r3，740×340 PNG 的源码/图像哈希逐轮变化。成功链共 16 笔请求、147,472 输入/3,325 输出 token、¥0.321544；含前序失败诊断的隔离账本共 80 笔、¥1.460134，结束时全部 `settled`。刷新后注入一次 Agent launch 503，重试恢复同一项目且失败未新增结算；另一个受邀账号读取项目返回 404。证据脚本为 `tests/real-model-setup.browser.mjs`、`tests/real-game.browser.mjs` 和 `tests/real-project-isolation.browser.mjs`，截图在 `apps/web/artifacts/real-mvp/`。

受邀预览 MVP 的代理用户整链已通过，可开始小规模技术预览。产品不限制继续描述轮次；Studio 对单次 prompt 显式设置 `maxSteps: 999`，防止继承原 Agent 的全局默认值变化，同时仍保留异常循环的有限边界；这不是用户继续轮次上限。下一工程门槛是受邀真人走查、完整 Agent 对照、BYOK 派发、公开发布/Remix、外部 clone、设备矩阵和生产运维。

这证明**受控工具回复下 XML 生成游戏可经原 Agent 的 `build`/`previewGame` 在浏览器实际试玩**，不证明 XML 所有节点、嵌入 Yue、模型自主规划、音乐音效、原 Agent 全工具/模式/子任务、BYOK 派发、发布/Remix、真实外部供应商、锁定工具链构建或受邀真人签收。工程下一道门槛应是原 Agent 完整能力对照与真实模型/继续迭代整链，再补 BYOK 派发、发布/clone 与部署设备安全出口；禁止以回写或任务终态再加一条 Studio 自动编译来代替原工具。

现行行为：Studio 不在 Agent 作者回写后自动调用编译器或 Player；构建/试玩由原 Agent 工具显式触发，用户手动操作另行保留。早期章节若写“回写后自动编译/试玩”，均为已撤回的历史状态。正式 App 已移除对应后处理及自动运行意图；综合浏览器测试先断言未编译、无运行 iframe，再通过显式界面操作验证编译和试玩。此前该脚本的 SQLite `decompressText` WASM 内存越界经减小栈上解压临时块、重建专用宿主后连续两次无预热 Chrome/WASM 运行消失，脚本整链通过；这不证明根因已完全隔离，也不是原 Agent `previewGame` 工具试玩验证。

## 原 Agent XML 构建工具（2026-09-16）

原 Web 最小引擎的 `Projects/Web/CMakeLists.txt` 排除 `LuaFromXml.cpp`，`LuaEngine.cpp` 未绑定 `xml.tolua`，因此专用 Agent 宿主不能只靠前端复制 WebServer 方法得到原转换行为。现在仅对 `DORA_WEB_STUDIO_AGENT_HOST` 档重新加入原 `LuaFromXml.cpp` 并注册 `Dora.xml.tolua`，普通 Player 保持排除。原 `Build.ts` 的 Studio 分支接受 `.xml` 后，`AgentSessionBridge.lua` 只在该原工具请求到达时同步调用受信 `StudioAgentXmlBuild.lua`：检查源文件仍一致，调用原转换器，输出 `-- [xml]: 相对文件` 加 Lua 并保存相邻目标；失败清除旧目标，源变化不覆盖既有目标。原生 Web IDE/Android 分支仍使用 WebServer，作者回写与任务终态不调用本转换器。XML 适配经支持包摘要、启动账号/项目租约和宿主快照固定路径白名单校验。

本机 `DORA_WEB_ALLOW_TOOLCHAIN_DRIFT=1 bash Tools/build-scripts/build_studio_agent_host.sh` 编译、链接成功；Emscripten/Rust/Node/CMake 版本漂移，需按锁定版本重做发布构建。`luac -p`、`agent-xml-build.test.mjs` 的正常/失败/源变化夹具、完整 `pnpm test` 构建和单测 358/358 通过。隔离前端/API/专用宿主/独立 Player/本地固定模型桩五服务在三个新数据库执行 Chrome 原 Agent `edit_file → build`：普通 XML 生成包含节点名称的相邻 Lua，非法闭合标签把诊断送回模型而不生成 Lua，最终受信包强化产物内容断言后合法 XML 复跑通过；作者 r1 写回后均“尚未编译”且无 iframe。`agent-host-callback.browser.mjs` 在新引擎/受信包下 `passed=true`、`errors=[]`。这些仍不能外推为复杂 XML/嵌入 Yue/游戏试玩、原 Agent 全模式、真实供应商或真人签收。

## 原 Agent Yue 构建工具（2026-09-16）

原 `Build.ts` 的 Studio 分支现将 `.yue` 交给 `AgentSessionBridge.lua`，仅在原 Agent `build` 工具调用时启动。独立专用 Agent Web 引擎已带 Yue 编译器，因此宿主 `StudioAgentYueBuild.lua` 调用原 `Dora.yue.compile`，并从受信原 `Utils.lua` 复用 WebServer 的 TIC80 检测、全局变量检查与来源头规则。编译器的异步写入先落到同目录带请求 ID 的临时 Lua；临时路径已有作者文件时先拒绝，完成回调还要验证请求仍活跃、源文件仍与发起时一致，才保存目标 Lua。编译检查失败清除旧目标，取消或源文件变更不接受迟到结果。原 Build 工具不二次保存 Yue 输出，原生分支不变；Studio 回写或任务终态也不主动编译。支持包清单及服务器快照只允许固定 `StudioAgentYueBuild.lua`、`lua/Utils.lua`，逐文件核对原源码 SHA-256。

`luac -p` 与最终完整 `pnpm test` 构建/单测 357/357 通过；`agent-yue-build.test.mjs` 用 Lua 回调夹具检查成功、取消、失败清理、源文件异步变更及临时路径占用时不覆盖。隔离五服务 HTTPS Chrome 的 `admin-models.browser.mjs` 用三个独立数据库和固定模型桩按原 `edit_file → build` 验证普通 Yue、语法错误 Yue、TIC80 Yue：正常输出相邻 Lua 的 Yue 来源头，错误通过原工具向模型回报且不生成 Lua，TIC80 头顺序与原规则一致；最终受信包另用第四个新数据库复跑普通 Yue。四轮回写后工作台仍“尚未编译”、无试玩 iframe。`agent-host-callback.browser.mjs` 的最终受信包综合 Chrome `passed=true`、`errors=[]`。测试后停止新增服务，既有预览不受影响。正式浏览器取消/迟到回调、复杂宏与多文件 Yue、XML 及真实外部模型/受邀真人仍待验收。

## 原 Agent TIC80 Lua/Teal 与 Yarn 构建工具（2026-09-16）

现有 Lua/Teal Worker 的生成脚本从 Dora 原 `Utils.lua` 和 `WebServer.lua` 抽取 TIC80 检测、编译前替换和编译后还原规则，编译核心返回是否为 TIC80；原 `Build.ts` 工具据此把 Teal 来源头放在前导 `-- tic80` 后，而普通 Teal 仍把来源头放在开头。Lua 检查路径保持原有 TIC80 处理。Yarn 则不复制解析器：独立 Emscripten Worker 直接编译仓库的 `yarnflow/yarn_compiler.cpp`、原 YueParser 依赖，只调用 `compileFile`，成功只表示检查通过，失败传原节点/行/列诊断。两个 Worker 均作为专用 Agent 宿主支持文件由服务器校验摘要、按受邀会话/项目/启动代次授权；受信 Agent 宿主仅核对当前文件并处理原工具请求，不载入 WebServer 模块、不运行游戏或追加任务后处理。

`teal-tic80.test.mjs` 使用实际编译 WASM 比较普通/TIC80 Teal 和 Lua 检查，`yarn-compiler.test.mjs` 使用实际 YarnFlow WASM 检查完整/空节点，工具专项检查不额外写入源码。五服务 HTTPS Chrome `admin-models.browser.mjs` 在三个隔离空数据库分别验证原 Agent 的 TIC80 Teal 成功、合法 Yarn 成功且无 Lua 输出、非法 Yarn 失败诊断进入模型工具消息；每轮作者 r1 回写后仍“尚未编译”、无运行 iframe。最终稳定源码完整 `pnpm test` 构建/单测再跑 356/356；新受信包长会话综合 `agent-host-callback.browser.mjs` 回归 `passed=true`、`errors=[]`，原手动编译/运行/点击与无 Studio 后处理保持正常。最终包上隔离数据库又重跑严格 Yarn 失败断言和原 `edit_file → build → previewGame` 五服务 PNG/绿色像素专项，均通过。该证据不覆盖 Yue/XML、复杂项目与真人/外部模型验收。

## 原 Agent Lua/Teal 构建工具（2026-09-16）

原 `Build.ts` 在受信 Studio 桥存在时，把普通 `.lua`、`.tl` 文件送到 `build-script` 工具请求，等待原工具结果并由原工具保存 Teal 生成的 `.lua`；Lua 成功只代表原来源代码检查，不写回。原 Web IDE/Android 分支仍使用原 `Script.Dev.WebServer.buildAsync`。Studio 独立 Agent WASM 宿主不能安全加载 WebServer（其模块顶层会改动 HTTP 服务/路由），因此使用现有 `agent-contracts` 从原 `tl.lua` 和 WebServer Lua 检查源构建的 Worker。Worker、编译核心和声明经专用宿主支持包摘要验证、会话启动资源鉴权；请求读取当前 Agent 文件系统并核对来源内容，取消后不接受迟到结果。当前 TIC80 特殊重写、Yue/XML/Yarn 分支明确失败，不伪装为等价通过。

`agent-tool-script-build.test.mjs`、`agent-wasm-source.test.mjs` 和宿主快照专项覆盖源绑定、输出、缺口、取消及受信包隔离，完整 `pnpm test` 构建/单测 349/349。五服务 HTTPS Chrome `admin-models.browser.mjs` 通过本地固定模型回复在两个隔离数据库分别调用原 `edit_file → build`：Teal 生成 `-- [tl]: main.tl` 开头的相邻 Lua，Lua 只检查且原文仍在；两轮作者 r1 回写后工作台仍“尚未编译”、无运行 iframe，人民币账本结算。第三个隔离数据库用不闭合括号的 Lua 检查原 `build` 将 `success=false` 和源行/列语法诊断回给模型，源文件未被工具重写；首轮错误为测试桩只摘了顶层 `message/messages` 而原返回是 `results[]` batch，完整工具内容复查不是 `{}`。新受信包下长会话综合 `agent-host-callback.browser.mjs` 回归 `passed=true`、`errors=[]`，写回无额外编译/运行及用户显式编译/运行/点击保持正常。该证据不覆盖复杂 Teal 项目、其他语言工具或真实模型。

## 原 Agent `previewGame` 工具与独立 Player（2026-09-16）

原 `CommandPreview.ts` 仅在受信 Studio 工具桥存在时把既有 `previewGame` 工具请求送出，保留原参数、入口校验、视觉预算与结果流程；原生 Dora 捕获路径不改。宿主从当前 Agent 文件系统读取原 `build` 已生成的 `.lua` 入口，绝不顺手编译。绑定项目/账号/代次/会话的反向端口请求父页面启动独立浏览器 Player，在原工具指定时刻捕帧；有界 PNG 写回同一 Agent 文件系统 `.agent/vision`，元数据送回原工具。超时、取消或失配会停止运行并拒绝迟到结果；父页面只在该工具请求期间切换试玩视图。

`tests/agent-tool-preview-host.test.mjs`、`tests/agent-wasm-source.test.mjs` 和 `tests/agent-session-port.test.mjs` 检查入口、帧格式/大小、绑定、期限和取消。完整 `pnpm test` 构建/单测 345/345；`luac -p`、测试脚本语法及卡片格式通过。五服务 HTTPS Chrome `tests/admin-models.browser.mjs` 的固定模型桩按原 Agent `edit_file → build → execute_command(previewGame)` 走通，返回 1 帧真实 Player PNG；740×340 截图绿色游戏区域通过像素检查，原视觉预算计一次，作者回写后仍“尚未编译”且无 Studio 自动运行实例。`agent-host-callback.browser.mjs` 长会话综合 Chrome 回归 `passed=true`、`errors=[]`，再次检查正式 App 回写无额外编译/试玩以及用户手动编译/运行/点击。此证据不覆盖原 `enterEntryAsync`、其他语言/工具模式、真实模型或真人验收。

## 原 Agent `execute_command` Lua 模式与试玩入口边界（2026-09-16）

原命令工具在 Lua 沙箱建立前加载 `Script.Dev.Entry`；专用 Studio Agent WASM 宿主不包含原 Web IDE 的 Dev UI 与游戏进程。`StudioAgentEntry.lua` 只在 `AgentSessionBridge.open` 的正式宿主会话期间绑定这个模块名，提供空闲状态与清理操作，让非渲染 Lua 命令保留原执行器、输出、超时/取消、步骤和日志流程；调用游戏入口时明确失败，绝不在持有模型/作者文件权限的受信 Agent 宿主内运行用户游戏。未来 `enterEntryAsync`/`previewGame` 必须经独立浏览器 Player 工具通道实现，不能将此临时入口适配当作完整能力。

`pnpm test` 完整构建/单测 338/338、`luac -p`、Lua CLI 直接检查适配层拒绝 `enterEntryAsync`。隔离四服务 Chrome `tests/admin-models.browser.mjs` 在 `STUDIO_FIXTURE_GAME=1 STUDIO_FIXTURE_BUILD=1 STUDIO_FIXTURE_COMMAND=1` 下实测原 Agent 按次调用 `edit_file`、`build`、`execute_command`，最后固定 Lua 输出被原供应商桩收到、步骤完成，工作台没有自行编译/试玩。这是受控模型工具回复，不是外部 AI 或非模拟游戏验证。历史综合 `tests/agent-host-callback.browser.mjs` 本次在 SQLite `decompressText` 发生 WASM 内存越界，失败证据保留，须另行定位；不能把单测全绿或本专项成功外推为该压力脚本通过。

## 原 Agent `build` 工具驱动浏览器转译（2026-09-16）

原 `Assets/Script/Lib/Agent/Tool/Build.ts` 仅在可信 Studio 会话桥安装工具入口时走新的 TS/TSX 转译适配；原 Web IDE WebSocket/Android 分支保持原样。`AgentSessionBridge.lua` 将原会话与项目根、工具请求 ID 绑定，宿主 JS 只处理受限 `transpile-ts`，读取当前专用 Agent FS 源码后调用本来源浏览器编译 Worker。Worker/声明通过受信 manifest 校验并在当前登录、项目和启动租约内供给；结果返回原工具流程保存 `.lua`，取消/超时不留阻塞下次工具调用的请求。工作台并没有任务终态/作者回写后的编译或运行后处理。已有同名 `.lua` 属于原 Agent 构建产物，用户以后明确点击 Studio 编译时允许 Worker 重新生成它。

`pnpm test` 完整构建和单测 338/338；`luac -p Studio/packages/runtime-web/AgentSessionBridge.lua`；Chrome `tests/compiler-worker.browser.mjs` 验证同名 Lua 替换及原编译/取消/诊断回归。四个独立 HTTPS 服务的 `tests/admin-models.browser.mjs` 用 `STUDIO_FIXTURE_GAME=1 STUDIO_FIXTURE_BUILD=1` 验证本地模型桩先调用原 `edit_file` 再调用原 `build`，供应商收到了成功的工具结果，Agent 执行记录完成，作者 r1 已核对而工作台仍“尚未编译”、无试玩 iframe。该桩不是真实外部模型，TS/TSX 以外构建、原 Agent 自动试玩和视觉反馈还没有通过。

## 原 Agent 编辑工具回写与构建触发边界（2026-09-16）

按最新产品确认，Studio 不再在作者回写后额外调用编译器或自动启动试玩；只有原 Agent 的 `build`、命令/`previewGame` 工具调用可以触发这些动作。正式首页的首轮描述经原 Agent 工具修改文件后，主任务到达精确终态时，工作台自动进入已有 quiesce→捕获文件→作者 revision/检查点提交→宿主基线确认的回写流程；投递的原 request ID、task ID 与本机 `writebackState=attempted/confirmed` 收据绑定。确认不明保留原文件及人工“核对并接收”入口，不在刷新后自动再接收。无文件变更也记录终态核对，但不伪造构建/运行结果。

`tests/agent-auto-writeback.test.mjs` 检查只接受初始 prompt 的主任务 `DONE/FAILED/STOPPED`，拒绝进行中、旧任务、子 Agent 和互相矛盾的状态；`tests/workspace.browser.mjs` 用真实 Chrome IndexedDB 验证一次性回写标记跨重开保存、错 task/作者 revision 及重复尝试被拒。四个 HTTPS 服务（正式前端/API/专用 Agent WASM 宿主/本地测试供应商）同时运行的 `tests/admin-models.browser.mjs` 在 `STUDIO_FIXTURE_GAME=1` 下观察原 Agent `edit_file` 真正修改 `main.ts`，工作台自动接收为 r1，源码含真实绘图/点击逻辑，而工作区仍为“尚未编译”、无试玩 iframe。完整 `pnpm test` 构建/单测 335/335 通过。此专项只证明原 Agent 编辑工具与自动作者回写，不证明原 `build` 和 `previewGame` 已在正式宿主等价接通；原 Web `Build.ts` 的 TypeScript 路径仍依赖 Web IDE WebSocket，专用宿主没有该连接，下一阶段必须实现由工具请求驱动的可信浏览器编译/试玩桥，而不能加任务后处理来代替。

## 首页描述投递、共享模型派发与四服务浏览器验收（2026-09-16）

正式首页现在要求创作者明确选择获授权的共享模型：独立 r0 项目、原描述、授权 grant ID 和命令 ID 同一 IndexedDB 事务提交；已有云上传/Agent 文件同步完成后，可信 WASM 宿主核对作者基线并释放原 Agent 的项目静止锁，读取宿主同源保护的模型配置，然后调用原 `Session.sendPrompt`。投递前先持久标记“已尝试”，收到原任务 ID 才改为“已确认”；不确定时保留原项目、描述与会话记录，禁止自动再次投递。原 Agent 的 JSON/SSE/非流式模型请求在 Studio 配置下附请求 ID；普通原生 Agent 不增加此头。宿主模型路由逐请求复核当前受邀会话、未过期启动记录、所属云项目与账号 grant，固定 HTTPS 供应商端点只能由部署方 `STUDIO_PROVIDER_ENDPOINTS` 配置，真实 Key 从密文库内受信读取；费率/预留/三级准入/实际 usage 仍由原 SQLite 账本执行。SSE 非终止事件可实时转发，`[DONE]` 只在账本结算后送出。

`tests/agent-model-route.test.mjs` 以真实会话、项目、目录/密钥、grant 与账本验证外账号/错来源/错模型/缺 ID 被拒、同请求和改正文重试不再派发、非流式及 SSE 实际 usage 双层结算、缺 `[DONE]` 在途待核、金额不足及会话撤销。`tests/agent-wasm-source.test.mjs`、`tests/agent-session-port.test.mjs` 覆盖专用命令/确认及静止锁释放；`luac -p` 检查宿主 Lua 桥。`tests/workspace.browser.mjs` 的真实 Chrome IndexedDB 验证 grant/命令 ID 和 attempted→confirmed 标记跨重开保存、重复/改绑定被拒。

长任务租约增量：`agent-launch-store` 的 5 分钟资源租约现可由登录中的专用宿主通过同源 POST 续期，但过期不能复活，单次启动最长 24 小时；路由在续期前重查会话、项目和 generation。`tests/agent-launch-store.test.mjs` 与 `tests/agent-service-handler.test.mjs` 验证期限、错来源/他人账号/隐藏正文/停用账号/撤销会话拒绝；独立三服务 Chrome `tests/agent-service.browser.mjs` 实际观察宿主 `renew` 200、会话刷新保持连接、退出后 iframe 关闭与私有配置 403。`model-grants-readiness.test.mjs` 验证正式创作者可选模型须同时具备部署端点、密文 Key 和当前账号金额/并发许可；管理员配置启用不再被前端直接误认为可以开始创作。

本机四个 HTTPS 服务同时运行（正式前端/API、专用 Agent WASM 宿主、测试供应商桩），`tests/admin-models.browser.mjs` 从管理员邀请码＋密码配置池/授权到创作者注册、选模型、输入描述、云项目和原 Agent 任务执行，供应商桩收到 1 次请求，账本记录 1 笔 `settled`，账号与逐 API 用量均大于 0；测试 Key 不相符的故障轮次收到供应商拒绝，账本留下 `in-flight` 而没有假结算。`tests/prompt-preparation.browser.mjs` 在已配置同账号/额度的环境中验证首个云 PUT 503、刷新后同一项目完成 Agent 投递、另建项目后切回而不重新投递；页面 JS 异常为零。全部测试用假 Key/本地桩，不消耗外部 API。实际 AI 游戏修改、自动回写编译试玩、BYOK 派发、跨崩溃请求身份、队列调度及生产用户验收仍未完成，详见 [接线契约](MODEL_GATEWAY.md)。

`tests/gateway-controls.browser.mjs` 复用上述已配置隔离环境，从正式管理员界面把逐 API 金额降为 0、停用共享配置和换成供应商拒绝的 Key；创作者候选会在额度不足/停用时关闭，拒绝轮次的 Agent 状态为失败，SQLite 请求保持 `in-flight` 而非伪造结算；恢复额度、配置和测试 Key 后候选重新可用。该脚本要求 `STUDIO_GATEWAY_TEST_URL` 与 `STUDIO_GATEWAY_TEST_DB`，可用同组账号环境变量覆盖默认验收账号。它与成功路径都使用本地桩，不能代替真实外部供应商证据。

## 管理员共享模型池与逐账号授权（2026-09-16）

正式 App 新增“共享 API 管理”：管理员可先保存停用配置及人民币输入/输出单价，再导入加密共享 Key、设置 API 全局并发、启用配置；账号页分别设置账号累计金额/总并发和账号×API 累计金额/并发。共享 Key 不回传列表/详情，创作者不能打开管理页或读管理员接口。`model-configuration-store`、`model-secret-vault` 和 `model-ledger-sqlite` 的管理员写入在 SQLite 事务内复核当前会话和管理员身份，路由则先做同源与角色检查；启用需要密钥和 API 容量，撤销在用密钥须先停用配置。

`tests/admin-shared-models-handler.test.mjs`、`tests/admin-model-allowances-handler.test.mjs` 和 `tests/model-admin-session-guard.test.mjs` 分别覆盖 HTTP 管理入口、两级额度与数据库写事务权限。此前双服务专项从管理员邀请码＋密码注册到创作者 ¥5 授权展示与管理员接口 403 已通过；四服务的模型派发/结算增量见本文件首节。测试使用假 Key，不是外部供应商或真实用户验收。最新完整 `pnpm test` 全量构建/单测 334/334 通过，浏览器脚本单独运行。

## 兼容供应商传输与账务接线专项（2026-09-16）

`apps/server/model-provider-transport.mjs` 是受信内部传输：固定 HTTPS 端点由部署方配置，密钥从服务端密文库取，不从游戏包或请求 URL 取。原 Agent 的 JSON/SSE 语义逐块保留；流式缺 `[DONE]`、非法回复和供应商失败不报告完成，缺 usage 返回 `null` 供原账本暂挂而非零计费。`tests/model-provider-transport.test.mjs` 的五项专项与新增 `tests/agent-model-route.test.mjs` 的受邀宿主路由专项均已纳入完整 334/334 回归；后者验证会话/项目/grant、金额、重试与 SSE 结算。使用临时 HTTPS 供应商桩，不证明外部供应商、跨崩溃请求幂等或 BYOK，详见 [接线契约](MODEL_GATEWAY.md)。

## 一句描述项目准备与故障恢复（2026-09-16）

正式 App 首页在受邀账号和独立 Agent 宿主均就绪时启用“新建并启动 Agent 创作”。空描述禁用；创作者须明确选择可见的共享授权；提交把独立 r0 项目、原描述、grant 与命令 ID 同一 IndexedDB 事务写入，再以固定快照/持久请求 ID 上传云端，启动专用 Agent 会话、同步作者文件并投递原 `Session.sendPrompt`。受保护模型路由可接服务端固定 HTTPS 兼容供应商。原 Agent 可通过已有工具修改文件、构建并启动独立 Player 试玩；Studio 不会在任务结束或回写后额外自动编译。描述元数据目前只保存在原浏览器项目中，不进入云快照或 ZIP；换设备/清理站点数据不会恢复该描述。

失败后不要从首页再提交产生新项目：在已有项目点击“继续准备创作”，云上传若有待确认记录则复用原请求，已确认云版本不重新上传，Agent 启动/同步失败可在同项目重试。页面会区分授权加载/失败/无额度、启动中、可重试失败、投递确认不明、已启动和回写已核对；投递前写入 `attempted`，收到任务 ID 才写入 `confirmed`，确认不确定时不自动重发。Agent 连接后可持续描述修改，产品不限制轮次。`tests/prompt-preparation.browser.mjs` 在隔离 HTTPS 前端、API、Agent 宿主和模型桩同时运行时验证空输入、首次云 PUT 503、刷新后的同项目恢复与 prompt 投递、快速任务回写、另建项目后切回不重发；`tests/workspace.browser.mjs` 验证元数据原子保存/重开、投递标记及重复/改绑定拒绝。两项浏览器脚本均不包含在 `pnpm test`；暂不替代真正游戏生成或人工试玩验收。

## 独立 Agent Web 引擎与三来源联调（2026-09-16）

`bash Tools/build-scripts/build_studio_agent_host.sh` 使用单独的 `build/studio-agent-host` 与 `result/dora-studio-agent-engine`，开启 `DORA_WEB_STUDIO_AGENT_HOST`，不改写公开游戏 Player。脚本检查 `studioAgentHost` 能力标志、专用快照请求 WASM 导出与 JS/WASM/data 资源；项目锁定 Web 工具链不一致时，只能用 `DORA_WEB_ALLOW_TOOLCHAIN_DRIFT=1` 进行本机诊断构建，发布仍须按锁定版本重建。

正式服务可选择开启第二 HTTPS 宿主监听器，启动时拒绝普通 Player，并将宿主 HTML、引擎字节与 Agent 私有启动文件绑定到有效账号会话及所属云项目。前端通过 `VITE_STUDIO_AGENT_HOST_ORIGIN` 开启“连接项目 Agent”；空白/导入项目手动连接时仍需先手动上传云版本，一句描述入口会自动上传后连接。宿主占用屏幕内 16×16 的透明、不可交互运行层，不能用 `hidden`/`display:none` 停止其逻辑帧队列；会话退出或账号变化时立即关闭本地运行层。部署配置与同主机 Cookie 约束见 `apps/server/LOGIN_SERVICE.md`。

`node tests/agent-service.browser.mjs` 是独立浏览器验收，不包含在 `pnpm test`：全新临时账号库从邀请码注册开始，实际完成项目创建/上传、Agent WASM 会话连接、作者文件同步、账号刷新及退出后旧资源 403。真实模型调用、prompt 自动投递、Agent 修改回写和生成游戏试玩不在此专项覆盖范围。

## Teal 编译构建前置（2026-09-15）

`pnpm build` / `pnpm test` 现在通过 agent-contracts 构建 Teal Wasm，需 PATH 中提供 Emscripten `emcc`，或设置 `STUDIO_EMCC` 为编译器可执行文件路径。本机验证版本为 Emscripten 5.0.5。该要求属于开发构建；最终用户浏览器仅加载静态 Worker/Wasm，不安装 SDK。

应用准备脚本发布到 `.generated/teal`，只有包含非声明 `.tl` 的项目才按需加载。正式 App 回归命令仍为 `STUDIO_TEST_APP=1 node tests/runtime-host.browser.mjs`（同时配置 Playwright 模块与 Chrome 路径）；新增报告字段 `tealImportedCompiledAndPlayed`。Wasm 工具链许可证完整归集与 CI SDK 配置仍须在发布前完成。

## 本地检查点存储（2026-09-15）

- 恢复取消浏览器验证：Chrome 在无草稿时取消恢复、拒绝放弃草稿、同意放弃但取消第二次恢复确认三种路径中，编辑内容均保留；随后确认恢复仍只生成 r2。完整 App 回归 checkpointCancellationPreservesDraft=true、checkpointRestoredFromUI=true、errors=[]。

- 正式 UI 已接入“版本记录”及逐版本恢复，手动保存现在也创建旧版本检查点，另存副本不创建。切换项目/保存后清理旧列表；恢复使用已保存 base revision，成功调用 activate 清除旧编译结果。
- Chrome runtime-host.browser.mjs 的 App 流程验证编辑→保存 r1→版本记录→确认恢复 r0→r2 内容一致、状态尚未编译，checkpointRestoredFromUI=true，完整 App 回归 errors=[]。完整构建及 64 项测试通过。未替代人工验收。

- 恢复 API：restoreCheckpoint 读取旧快照，以调用者期望的当前 revision 做条件保存，产生新 revision 并原子保留恢复前检查点。Chrome 验证 r10→恢复 r9 内容形成 r11，checkpoint r10 完整保留；重复使用旧 base revision 的恢复返回 conflict，r11 内容不变。全量构建及 64 项测试通过，恢复 UI 仍待接入。

- v1 升级专项已通过：Chrome 中用旧 schema 创建真实数据库，写入 r7 源码、二进制资产及引用，关闭后由 LocalWorkspace 升至 v2。核对旧内容，再原子保存 r8/checkpoint r7，关闭重开读取检查点与旧 LocalProject 完全一致。证据为 workspace.browser.mjs 的 migration 断言；未测试浏览器强制退出或真实配额耗尽。

- LocalWorkspace.save 增加显式 checkpoint 参数，仅更新已有项目时保存旧版本；版本冲突检查先于检查点创建，检查点/资源/项目同一事务，提交完成才返回成功。loadCheckpoint 可读取旧版本。检查点直接保存完整快照，不依赖可能已回收的资源引用。
- IndexedDB schema v2 的升级仅补建缺失存储，项目删除事务清理所属检查点。Chrome 152 workspace.browser.mjs 核对旧项目与检查点内容一致、注入中止后的后续保存成功、项目删除后检查点消失；原冲突/配额/引用清理回归仍通过。完整构建及 64 项测试通过。
- 检查点容量管理、恢复 UI 和 Agent 实际绑定尚待完成；不把存储 API 视为用户已可回滚。

## Dora 包导入（2026-09-15）

- 新入口“导入 Dora 游戏包”接受 .dora/.zip，通过共享 inspectPackage 执行现有严格解析与 manifest/引擎版本检查，复用包根目录归一化，不自行实现 ZIP 解析。
- restoreDoraPackage 将已验证文件转换为独立 UUID/r0 快照，文本严格 UTF-8 解码、二进制复制，不覆盖已有项目；Yue/Teal/XML 可保留编辑但当前浏览器编译不支持，界面明确提示。仅 Wasm 入口明确拒绝。无 manifest 的普通 ZIP 尚不支持。
- `pnpm test` 完整构建及 41 项测试通过，新增文本/二进制/独立身份和输入变更隔离测试；`node Tools/build-scripts/check_web_package.mjs` 既有包验证与原子安装回归通过。
- Chrome 152.0.7977.83：`STUDIO_TEST_APP=1` 的 runtime-host.browser.mjs 用共享 ZIP 写出器生成带 Imported/ 顶层目录的 .dora，文件选择上传后核对 init.lua 源码，编译 r0 并运行，日志收到 STUDIO_DORA_IMPORT_READY，真实 FS `/game/Resources/import.bin` 为 `[255,0,127]`。再上传损坏包，错误可见，项目数量及原项目源码不变。报告 apps/web/artifacts/runtime-app/result.json 中 doraPackageImportedAndExecuted/invalidDoraImportPreservesProject/appPassed=true，errors=[]。此为 Lua 测试包自动化证据，非全部原生项目兼容或人工验收。

## ZIP 导出基础（2026-09-15）

- 备份一致性修复：inspectArchive 的 projectBackup 模式仅放宽发布文件名过滤，继续校验安全路径、链接、CRC 与大小；Studio 恢复仍要求严格元数据/文件清单。inspectPackage/inspectLovePackage 强制关闭此模式，不能借选项绕过发布包规则。createArchive 与读取器统一大小写冲突规则。exportProject 提前拒绝不可恢复的名称或超过 64 KiB 的元数据，不生成坏备份。
- `check_web_package.mjs` 新增隐藏配置/.log 字节往返、默认读取及 Dora/Love 包强制过滤、大小写文件/目录冲突测试，全部通过。

- 恢复入口：侧栏“恢复 Studio ZIP”读取共享 ZIP 检查器结果，严格校验 .studio 元数据、文件种类/集合、文本 UTF-8 和项目快照，创建新 UUID/revision 0，再写入本地存储。不会复用或覆盖原项目 ID。
- 完整 `pnpm test` 构建及 40 项测试通过，恢复专项覆盖文本/二进制保真、独立身份、元数据错误/版本/入口及非法 UTF-8。Chrome 152.0.7977.83 运行 `STUDIO_TEST_APP=1` 的 runtime-host.browser.mjs：实际下载文件恢复后，项目列表增加一个项目、源码一致、r0 编译运行成功，运行 FS 中 fixture.bin 仍为 `[0,255,9,128]`。报告 apps/web/artifacts/runtime-app/result.json 中 zipRestoredAsNewPlayableProject/appPassed=true，errors=[]。普通 .dora/无 Studio 元数据的 ZIP 当前尚不支持，仍为首版待办。

- App 接入“下载 ZIP”，复制当前草稿后导出，包含源码/资源和保留路径 .studio/project.json（名称、入口、文件种类），不含游戏存档或云凭据，不改变保存状态。共享包读取器精确允许该元数据路径。
- Chrome 152 实际下载后读回核对 main.ts、二进制素材及入口一致，projectZIPDownloaded=true，完整 App 回归页面错误为 0。此为源码备份，不是不可变发布产物；原生可运行性尚未验收。

- 共享 Projects/Web/web-package.js 增加 createArchive 与 inspectArchive 导出，生成标准未压缩 ZIP（UTF-8 名称、CRC、中央目录），复用原路径与体积限制，不新增第三方 ZIP 实现。
- `node Tools/build-scripts/check_web_package.mjs` 通过：中文名称/文本和二进制往返、遍历路径与文件目录冲突拒绝，既有 .dora 验证/原子安装回归仍通过。
- Studio 已接入共享包的下载与备份恢复；通用游戏包导入、发布与用户验收仍需分别完成。

## 素材上传（2026-09-15）

- 媒体浏览器验证：上传现有 logo.png 与生成的 fixture.wav，检查图片 naturalWidth、音频初始 paused、调用 play 后 currentTime 推进。初次切换因新控件短暂使用旧已撤销 URL 出错；现将 URL 与文件对象绑定，切换时不渲染旧源。Chrome 152 完整回归通过，imagePreviewDecoded/audioPreviewPlayed=true、页面错误为 0。此为解码/播放状态验证，不是人工听觉或真实手势策略验收。

- 预览实现：ResourcePreview 使用 Blob URL 和原生 img/audio 控件，支持 PNG/JPEG/WebP/GIF/WAV/OGG/MP3；音频无 autoplay，HTML/SVG/脚本不作为活动内容嵌入。资源行可选择，解码失败明确提示且不删文件，更换与卸载释放 URL。构建和 39 项测试通过；媒体解码、播放与视觉效果尚需实际浏览器验证。

- 浏览器增量：正式 App 文件选择上传 fixture.bin `[0,255,9,128]`；第二次同名不同内容上传明确显示冲突且列表不重复。实际运行 `/game/Resources/fixture.bin` 字节一致；保存刷新重开并重新编译运行后再次一致。Chrome 152 报告 uploadedResourceRestored=true、页面错误为 0。这是文件链路验证，尚不覆盖素材预览、图片/音频解码或大文件压力。

- 资源页支持多文件选择，二进制保存在 Resources/原文件名，更新草稿并使旧编译产物失效；用户需保存项目。已有文件不覆盖，冲突要求重命名后上传。
- appendResources 先校验文件路径/数量/单文件 64 MiB/总量 256 MiB，再读取；失败不修改原列表，读取完成前锁定编辑操作。
- 全量构建和 38 项测试通过，随后上传专项测试通过，覆盖二进制保真、原列表不变、重复/越界文件名、超限和读取大小不符。真实文件选择、保存重开、游戏资源加载和预览仍需浏览器验证。

## 运行环境前置检查（2026-09-15）

- RuntimePreview 在创建实例前检查安全上下文、crossOriginIsolated、SharedArrayBuffer、OffscreenCanvas 和画布转移接口；缺失时显示具体配置/兼容性提示，编辑保存能力保持可用。
- `pnpm test` 全量构建及 38 项测试通过，分别覆盖缺少各能力及能力齐全的判断。接口存在不证明 GPU 初始化成功，也不替代目标浏览器实测；运行页自身来源的隔离仍由启动结果验证。

## TypeScript 异常中止与修复（2026-09-15）

- 错误详情修复：Web traceback 不再仅排入下一逻辑帧处理的日志队列，而是先同步代理到页面 Module.print，再继续启动失败处理，避免实例销毁前丢失诊断。原生仍使用原日志队列。
- 重建标识 `bff3797ea36baa41549dc47f346c6576a05852d88cada361e1e5a720ffbf6a07`，Chrome 152 回归通过：日志面板实际包含 `Error: STUDIO_EXPECTED_FAILURE` 及 `/game/main.lua` 堆栈，报告 scriptErrorDetailsVisible/scriptFailureRecovered 均 true，页面错误为 0。堆栈暂为 Lua 行号，TS 源映射定位尚未实现。

- 根因：TOLUA_RELEASE 的 LuaEngine::call 使用 lua_call，不保护脚本异常。Web 分支现在无论 Release 与否均使用 lua_pcall；错误格式化使用受保护 luaL_tolstring，再使用 luaL_traceback，不依赖可被脚本修改的 debug.traceback。原生 Release 调用分支不变，公共 traceback 改动仍需原生回归。
- 重建/装配标识 `6a18f373dcb9be87834a868f263d91883a0b798ef5b233fcc312dfed2b34503c`。Chrome 152 正式 App 原失败用例通过：出现 Failed to initialize、iframe 被移除，恢复正常代码后编译试玩成功，`scriptFailureRecovered=true`，无页面错误或 panic。正常图形、输入、保存重开、移动尺寸测试也通过。此结果不覆盖所有底层 Wasm 中止与异常类型。

- 正式 App 回归新增 `throw new Error("STUDIO_EXPECTED_FAILURE")`，要求失败状态可见、iframe 销毁，并在修正后恢复。当前失败：实际输出 `PANIC: unprotected error in call to Lua API (error object is not a string)` 与 `Aborted(native code called abort())`，等待预期 Failed to initialize 通知超时。
- 测试保留，报告 runtime-app/result.json 当前记录失败，不删除或降低断言来隐藏问题。需调查 Lua 非字符串异常处理和 pthread abort 向父端通知路径。此前正常图形/输入/保存恢复通过不覆盖此错误用例。

## 项目预览存档命名空间（2026-09-15）

- 后续实测：Player 重建并重新装配，资源标识 `b318803c5094b108a82cf95410655f99c0a49b4116142f78e97ccfbcc6222069`。Chrome 152 RuntimeHost 测试在真实 `/user/settings/studio-check.txt` 写入并等待 doraSyncUserStorage，销毁重建同项目后内容一致；新 projectId 同路径不存在。报告 `storageRestoredAndSeparated=true`、错误为 0，见 runtime-host/result.json。该测试主动调用同步，不证明任意游戏自动落盘或异常退出不丢数据。

- runtimeStorageId 使用 SHA-256 编码 preview 协议标记、Studio 来源及 projectId，生成不含用户路径字符的稳定目录名。运行入口设置异步 doraStorageId，Web 加载器等待其完成再挂载 IDBFS 和 /user 链接；旧同步标识仍支持。
- `pnpm test` 构建与 37 项测试通过；命名稳定性、项目/来源区分、特殊字符，以及加载器异步目录和非法路径拒绝有测试。
- 本轮尚未重新链接 Player 或实测不同项目写入/读回。命名空间只防正常流程串档，同源恶意运行代码仍可能直接访问浏览器存储；不是租户授权或生产安全边界。

## 运行日志接入（2026-09-15）

- 运行桥包装 Module.print/printErr，以共享 RuntimeEvent 和当前身份转发，处理 error/warning 标签；限制每秒 200 条及一次省略提示，单条截断到 8192 字符。销毁后不再转发。
- 正式试玩区增加折叠日志，使用 React 文本节点显示，不解释 HTML，保留最近 200 条；重跑清空上次日志。
- 全量构建及 35 项测试通过；随后新增日志专项断言，通道 4 项测试通过。Chrome 152 实际展开面板观察点击日志，`logsVisibleInApp=true`，图形、键盘、保存重开与重跑回归通过。尚未覆盖全部引擎错误路径或长时间日志压力测试。

## 正式 App 编译试玩实测（2026-09-15）

- Edge 回归：设置 `STUDIO_BROWSER_LABEL=edge` 和 Edge executable，153.0.4234.32 正式 App 全路径通过，所有 appPassed/pointerReceived/keyboardReceived/logsVisibleInApp/savedReopenedAndExecuted/mobileViewportPassed/scriptErrorDetailsVisible/scriptFailureRecovered 标记 true，页面错误为 0。独立目录 runtime-app-edge 避免覆盖 Chrome 证据；浏览器标签仅命名证据，不决定实际执行文件。仍是 Chromium 引擎覆盖。

- 390×844 布局增量：正式 App 浏览器测试在重开运行后切换手机尺寸，断言文档宽度不超过视口、Agent/工作区可见性正确，并保存 mobile.png。Chrome 152 通过，`mobileViewportPassed=true`，截图已查看。仅桌面浏览器模拟视口，不视为触屏、软键盘或真实移动设备验证。

- 键盘增量：测试项目注册 onKeyDown/onKeyUp，点击试玩后发送 ArrowRight，必须分别观察 `STUDIO_KEY_RECEIVED\tRight` 与 `STUDIO_KEY_RELEASED\tRight`。Chrome 152 通过，鼠标、保存重开与重跑断言仍通过，页面错误为 0。此结果覆盖一次正常按下/释放，不证明失焦、组合键、移动软键盘或异常中断后的全部输入行为。

- 图形与输入增量：测试项目改为 TypeScript DrawNode 绿色矩形、onTapBegan 回调。实际点击 iframe 内 canvas 后必须出现 `STUDIO_POINTER_RECEIVED`；Chrome 152 通过，`pointerReceived=true`，桌面截图已查看并确认矩形可见。保存重开断言同步核对完整图形脚本，再次编译执行通过，页面错误为 0。这不是像素精度、键盘、触屏或完整玩法验收。

- 保存重开增量：同一正式 App 测试中保存 r1 后刷新，从本机项目列表重新打开，逐字核对 main.ts；断言重开未自动创建 iframe，再编译并运行，必须观察到新增项目执行日志。Chrome 152 通过，报告 `savedReopenedAndExecuted=true`、错误为 0。此验证使用真实 IndexedDB，不复用页面里的旧 artifact。

- `STUDIO_TEST_APP=1` 执行 runtime-host.browser.mjs，用临时 Vite 服务加载正式 App，另一个来源供应实际 Player。浏览器操作新建项目、修改 main.ts、编译、切换试玩、运行、停止、重跑。
- 初次发现运行状态正常但项目代码未执行：Director 只扫描 init.*，没有使用 manifest 指定入口。Web 分支现在从页面取得已校验 manifest.entry，在 `/game` 执行，并返回执行成功与否；原生入口逻辑不变。实验 Player 重建及装配成功。
- Chrome 152.0.7977.83 重跑通过，主项目日志两次出现、停止后 Worker 为 0、页面错误为 0。引擎资源标识 `7b5772acf94d83ca76f33491fcc5d30a73ab6a9a223e18fe7e0673afd6b0b641`。`apps/web/artifacts/runtime-app/result.json` 与 desktop.png，桌面截图已查看。
- 添加官方 SVG favicon 后页面资源错误消失。本轮项目仅输出日志，截图试玩画布无游戏图形是预期结果；尚未验证图形游戏交互、保存重开后的试玩、移动布局或用户验收。需继续补齐而非将本测试等同首版完成。

## 正式试玩组件（2026-09-15）

- App 试玩标签接入 RuntimePreview，传递当前编译产物；显示加载/启动/运行/错误及 revision，支持运行、重新运行和停止。项目切换或离开试玩标签卸载运行容器。
- 构建/开发启动前设置 `VITE_DORA_RUNTIME_URL` 为独立来源的运行入口 URL，`VITE_DORA_ENGINE_BUILD` 为生成的 studio-runtime.json 中 engineBuild。运行按钮不再受配置或构建产物前置检查限制；缺少配置或实际产物时由启动过程返回真实错误，不回退到同源演示。
- Vite 开发/预览添加 COOP/COEP；生产静态服务器也必须提供这些头，运行服务按运行页要求提供隔离响应头。正式部署与安全策略尚未完成。
- `pnpm test` 全量构建及 35 项测试通过。首次构建暴露 React ref 初值和项目 ID 字段错误，已修正。当前尚未完成配置后的 App 浏览器端到端和视觉验收。

## 真实 RuntimeHost 浏览器联调（2026-09-15）

- `tests/runtime-host.browser.mjs` 启动两个不同端口来源，实际加载生成的运行入口及 pthread 引擎。父端使用正式 RuntimeHost 发送带哈希产物，Lua 输出 `STUDIO_CHANNEL_GAME_READY`；父端收到 loading/ready/running。
- 停止后等待并断言旧 Worker 数量为 0；重新 start 得到不同 runId，第二次 Lua 执行和 running 均通过，页面错误为 0。证据 `apps/web/artifacts/runtime-host/result.json`。测试结束关闭浏览器与两个临时服务。
- 两个来源均为本机 127.0.0.1 的不同端口，属于跨来源但非跨站测试；使用 COOP/COEP/CORP 与 SwiftShader、免手势音频参数。此结果不是生产来源安全或实际移动设备证明，也不是正式 App 用户验收。

## 运行入口装配（2026-09-15）

- `runtime-entry.ts` 从 fragment 读取连接身份并在引擎启动前安装接收端，配置错误提供拒绝的快照 Promise，避免默认演示回退；pagehide 清理通道。
- 在 Studio 执行 `STUDIO_RUNTIME_DIR=/绝对路径/Player构建目录 node apps/web/scripts/prepare-runtime.mjs`，生成仓库 `build/studio-runtime/`。要求 dora-preset、threads 与隔离标记；复用 Player HTML 并在引擎前插入桥接脚本，壳层结构不匹配时拒绝生成。引擎资源组合哈希作为 engineBuild，元数据不包含本机源目录。
- 本机输入 `build/studio-main-worker` 装配成功。全量构建及 35 项测试通过；初次 Window 类型声明缺失导致构建失败，补齐声明后通过。生成成功不等于实际运行成功，父端握手/iframe 运行与正式 App 仍需联调。

## RuntimeHost 父端生命周期（2026-09-15）

- `apps/web/src/runtime-host.ts` 为每次 start 创建独立 iframe、MessageChannel、session/request/run 身份及 nonce；URL fragment 只含连接配置，不含源码。发送前复制产物，收到消息使用共享守卫和身份匹配；停止/重启关闭端口并移除页面，启动超时同样销毁。
- 默认拒绝与 Studio 同源的运行页；同源仅可通过显式开发开关启用，不作为生产隔离方案。沙箱与跨来源隔离策略仍需实际部署和浏览器验证。
- `pnpm build` 和 `node --test tests/runtime-host.test.mjs` 通过：旧页销毁、端口关闭、新 runId、外来/迟到事件拒绝、running 清除启动定时器、超时销毁及默认同源拒绝。
- 本轮测试使用模拟 DOM/端口。运行入口脚本、构建资源供应和正式 App 按钮尚未装配，不能据此宣布浏览器试玩闭环完成。

## 运行消息接收端（2026-09-15）

- `apps/web/src/runtime-bridge.ts` 在 Emscripten 启动前创建待接收快照 Promise；只接受指定 parent Window、精确 origin、nonce 的一次 MessagePort 连接。后续沿专用端口传递共享 RuntimeCommand，检查运行身份与 engineBuild/profile，调用已有快照适配器，只解析一次有效快照。
- 超时、解码错误、快照错误和主动 dispose 关闭通道并清理监听；迟到异步结果不再交付。运行页状态转换为带身份的 RuntimeEvent。当前仅实现接收端，不支持通过此模块执行 stop/restart；最终停止由父端销毁实例实现，父端仍待接入。
- 全量构建与 33 项测试通过；随后新增旧身份/有效快照/单次交付断言，`node --test tests/runtime-bridge.test.mjs` 3 项通过。测试采用模拟窗口/端口，不替代真实跨来源 iframe、COOP/COEP 和生产安全验证。

## 编译产物到运行快照（2026-09-15）

- `contracts.serializeArtifactContent` 抽取既有哈希输入规则，编译 Worker 复用；不引入浏览器或服务器依赖。
- `apps/web/src/runtime-snapshot.ts` 验证产物结构、复制输入、重新计算完整内容哈希，输出供内存加载器使用的 manifest 与二进制文件，保留 projectId/revision/buildId/sha256。当前版本/profile 明确固定为已有 Player 接受的 1.9.3/dora-preset；不是完整引擎版本注册实现。
- `pnpm test` 全量构建及 31 项测试通过，新增文本 UTF-8/二进制精确传递、逐文件哈希、篡改拒绝、异步期间输入修改隔离。Chrome 152 实际编译 Worker TS/Lua/资源/哈希/取消/超时恢复通过，编译期间 52 次主线程心跳，无原生服务请求。
- 正式 UI 尚未调用此适配器，也尚未建立生产运行来源与消息授权；不能视为编辑→试玩端到端完成。

## 内存快照加载入口（2026-09-15）

- 后续真实启动验证：`Module.doraSnapshot` 可为 Promise，启动依赖等待快照校验挂载完成。失败直接 abort，不先解除依赖触发 main。`runtime-startup.test.mjs` 验证等待、禁止默认 manifest 下载、非法快照报告故障且不放行 main；全量构建及 29 项测试通过。
- `STUDIO_TEST_SNAPSHOT=1` 运行 `tests/runtime-worker.browser.mjs`，在测试壳层把完整演示字节注入 Module；Chrome 152 真实 Wasm 中完成演示及 152 字节 PNG 回读，`projectRequests=[]`，错误为 0。证据 `apps/web/artifacts/runtime-worker-snapshot/startup.json`。测试初次因构建 HTML 压缩导致注入标记不匹配而失败，改用空白兼容匹配后通过。此注入仅为测试，不是生产消息通道；正式工作室仍未接入。

- `DoraWebLoader.mountSnapshot(module, manifest, files)` 接受 manifest 与 `{path, bytes: Uint8Array}` 列表；检查文件集合、大小、SHA-256，并复制输入，所有字节校验完成后才原子替换 `/game`。URL 字段仍按已有 manifest 规范验证，但此路径不访问网络。所有快照文件预先挂载，后续 fetchPath 命中已挂载状态。
- 与 `mountStartup` 共享 `mountLoaded`，保留目录备份/回滚和旧 manifest 失效机制，未复制维护另一套 FS 实现。
- `node Tools/build-scripts/check_web_loader.mjs` 通过：既有 manifest、懒加载/去重/重试和 IDBFS 回归；新增禁止网络、输入修改隔离、损坏内容/集合拒绝、替换失败回滚及后续恢复。
- 此轮使用模拟文件系统验证。真实运行容器的消息鉴权、快照适配、启动等待、Wasm 挂载与正式界面仍未连接；不代表本地试玩闭环完成。

## 故障后的宿主清理（2026-09-15）

- `Projects/Web/web-platform.js` 监听 `dora-statechange/faulted`，注销监听、释放指针捕获和锁定、清空输入记录、取消音频回调并暂停 SDL 音频、释放 Worklet。故障清理跳过 Wasm 调用和模拟输入事件，避免重入已经中止或等待页面的运行线程。
- `tests/web-platform.test.mjs` 在 Wasm 调用必定抛错的模拟环境中验证清理、捕获释放、监听注销及重复 dispose；`pnpm test` 全量构建和 28 项测试通过。
- Chrome 152 实际 GPU 丢失探针验证：预先按住 ArrowRight，故障后 `active=false`、按键/指针记录为 0、SDL AudioContext suspended、Worklet context closed；尝试解锁音频/恢复后仍停止，引擎帧号 33/33，新实例完整演示成功，错误为 0。报告：`apps/web/artifacts/runtime-worker-gpu/startup.json`。
- 本轮不证明原生控制器内部状态完全清空、真实发声的听觉效果、反复创建销毁无泄漏或其他浏览器通过；这些仍属 P0 验收范围。

## 运行消息边界增量验证（2026-09-15）

- 后续诊断校验增量：`isDiagnostic` 校验可选路径类型、非负安全整数 UTF-16 位置及跨度加法溢出；保留声明文件的绝对路径，不误用项目资源路径约束。编译客户端已接入，畸形诊断不结束当前任务，随后有效结果仍可正常完成。`pnpm test` 全量构建及 27 项测试通过；非法偏移、NaN/Infinity、小数、错误路径类型和伪装 severity 均有客户端测试。

- contracts 增加 `isCorrelation`、`isBuildArtifact`、`isRuntimeCommand`、`isRuntimeEvent`，对跨线程结构化克隆数据做运行时校验；拒绝错误协议、无效身份、跨项目/修订加载、未知命令/状态、非有限帧耗时。
- 编译客户端复用产物校验；source map 使用实际编译器的 `输出文件.map` 命名，并要求对应文本输出存在。SHA-256 这里只验证格式，不替代内容重新计算或发布完整性校验。
- `cd Studio && pnpm test`：独立全量构建及 26 项测试通过（其中协议测试 10 项）。
- `tests/compiler-worker.browser.mjs`：Chrome 152.0.7977.83 实际 Worker TS/Lua、多文件诊断、资源、哈希、取消、超时及恢复通过，编译期间主线程心跳 55 次，无原生服务请求。运行需按下述方式指定外部 Playwright 模块；直接执行因本工作区未安装 Playwright 失败，配置已有运行环境后通过。
- 不提升游戏运行隔离或 RuntimeHost 的完成状态。这些校验尚未接入真实运行消费者；消息体积限制、完整编译消息解码、Worker 主循环及 GPU 故障恢复仍待实现。类型守卫只处理消息结构，不承担来源/权限验证。

## 当前工程

正式代码包括 `packages/contracts`、`packages/compiler`、`packages/tstl`、`packages/compiler-web` 和 `apps/web`。Web 应用已建立 React/Vite 工作室入口，接入本地存储及真实编译；原型仍在 `prototype`，两者独立。
Studio 使用自己的 pnpm workspace 和锁文件；TypeScript 固定为现有 IDE 的 5.9.3，未升级编译语义。

在 `Studio` 目录执行：

```sh
pnpm install --frozen-lockfile
pnpm test
```

contracts/compiler 导出构建后的 ESM 与 `.d.ts`；tstl 明确导出 TypeScript 源码，由消费者的打包器编译，不作为未经编译的 Node 入口。消费者使用包名，不引用其他应用内部源码。
contracts 使用纯 ES2022 类型环境，不包含 DOM 或 Node 类型；当前测试由 Node 自带测试运行器执行。
后续生产服务器的受支持 Node LTS 版本需在服务器切片锁定，当前本机测试版本不代表部署版本。

## 协议基线

- 文本和二进制文件组成完整快照；入口必须存在并为文本文件。
- revision 为非负安全整数，路径必须是项目相对路径，拒绝目录穿越、重复文件及文件/目录冲突。
- 编译结果关联 session/project/revision/request/build/compiler；运行事件另关联 runId。
- 取消请求有独立 requestId，targetRequestId 只指向原请求，不能取消同项目的新任务。
- 协议版本与引擎 build/profile、编译器版本分开；不兼容不得默默降级。
- 二进制采用结构化克隆表示；未来 HTTP 编解码、资源大小限制和完整消息运行时校验仍需实现。
- 编译 Worker 已实现通过 terminate 处理超时/取消；RuntimeHost 尚未实现，终止编译不等于终止游戏。

## 2026-09-15 验证

`pnpm test`：共享协议构建通过，7 项单元测试通过，涵盖快照克隆、非法路径、版本/修订错误、重复文件、目录冲突、迟到结果、运行会话与取消目标隔离。

仅证明协议基础；正式前端、持久化、运行宿主、完整 Agent 和云服务尚未实现，没有用户验收结论。

## 纯快照编译迁移（2026-09-15）

`packages/compiler` 提供封闭的快照 CompilerHost、Dora 编译选项和可注入的 TSTL 发射接口。项目内容和声明由调用者一次提供，Host 复制输入后不访问磁盘、网络或 Monaco；模块别名、输出与源码映射按同一程序关联。

旧 IDE 通过 `link:../../Studio/packages/compiler` 消费构建后的包。`predev` 和原 `build-project.js` 开始时，用旧 IDE 自身锁定的 TypeScript 构建共享包，不要求先安装整个 Studio。旧 IDE 锁文件只新增本地依赖，不升级其他依赖；原 `Assets/www` 发布步骤不变。本轮只执行 Vite 构建，没有同步生成产物到 `Assets/www`。

完整快照入口使用共享 Host，同时将 TSTL 发射阶段的文件读取限制在该 Host 内。请求自身提供 Dora 声明时，不读取 Monaco 的声明缓存。新增 `luaExternalModules` 用于显式标识运行时提供的 `Dora` 模块，不把任意缺失依赖伪装成存在。现有 TSTL 的相对导入禁用与 Lua55 目标保持不变。

验证结果：

- `pnpm test`：15 项协议/编译测试通过，使用真实 TS 5.9.3、现有 Dora TSTL 和仓库声明、lualib。覆盖嵌套多文件、模块别名、Dora 导入、源码映射、错误文件/偏移、缺失依赖、修复恢复、不同项目隔离、快照不受后续输入修改影响。
- 旧 IDE `node scripts/build-studio-compiler.cjs`、`node scripts/test-tstl-truthiness.mjs`、`node scripts/test-transpile-protocol.mjs` 通过。
- 旧 IDE `node node_modules/vite/bin/vite.js build` 通过。
- `Studio/tests/compiler.browser.mjs` 在 Chrome 152.0.7977.83 运行实际构建的 `compiler.html`：5 个编译任务（同项目重编译、另一项目、缺失依赖、修复恢复）通过，零原生文件请求。测试 HTTP 服务仅提供静态产物与任务队列，编译在浏览器中真实执行；测试结束关闭浏览器与临时服务。
- `node Studio/tests/ide-types.baseline.mjs` 对照 HEAD 与当前修改文件：35 项既有类型诊断，无新增。原 IDE 的 `ignoreDeprecations: 6.0` 与锁定 TS5.9.3 不兼容，对照测试临时使用 5.0；没有修改原配置，也不声称完整类型检查通过。

浏览器测试命令（仓库根目录，先构建旧 IDE）：

```sh
STUDIO_PLAYWRIGHT_MODULE=/path/to/playwright \
STUDIO_CHROME_PATH=/path/to/chrome \
node Studio/tests/compiler.browser.mjs
```

临时迁移边界与退出条件：

- TSTL 本体已整体迁入 `packages/tstl`，测试使用包导出，已移除对旧应用内部源码的定位。独立浏览器 Worker 已落地，正式工作室消费者仍待接入。
- 无完整快照的手动编辑/声明生成仍使用旧交互式 Host。后续将其文件收集与 Monaco 更新移入适配器，让全部发射路径消费共享快照后删除旧 Host；不能长期维护两套解析规则。
- 当前测试不证明 Studio 已能试玩、终止游戏、离线使用或完成用户验收。S-P0-03/04 保持进行中。

## TSTL 独立共享包（2026-09-15）

旧 vendor、许可证、路径适配和浏览器 TypeScript shim 整体移入 `packages/tstl`，只维护一份源码。旧 IDE 的路径和 shim 文件仅转导出；vendor 不再读取应用 `Info`。保留 TypeScript 5.9.3、source-map 0.7.6 和现有编译语义；修复构造初始化顺序，使现代类字段模式也能使用该包。

Studio 用 `workspace:*`，旧 IDE 用 `file:../../Studio/packages/tstl` 安装该源码包及依赖；安装目录中的副本由 pnpm 生成，不是第二份维护源码。共享包变更后在旧 IDE 执行 `pnpm install --frozen-lockfile`，再构建。浏览器打包将 `path`、`typescript`、`url` 分别适配到包导出的路径实现、浏览器 shim 和浏览器 URL；包不反向依赖旧 IDE。

验证入口与范围：

- `cd Studio && pnpm test`：18 项通过，新增独立浏览器打包、现代类字段初始化及 POSIX/Windows 路径切换回归。
- `node Studio/tests/standalone-install.mjs`：隔离临时目录，不含 Tools，离线冻结安装后构建与全部 18 项测试通过。
- `node Studio/tests/ide-standalone-install.mjs`：隔离旧 IDE 与共享包源码，无 Studio 安装目录或预构建产物；离线冻结安装、共享核心构建、truthiness 与 Vite 构建通过。
- 旧 IDE truthiness、ES6 子集（英文与中文声明及 Lua API）回归通过；原发布脚本入口保留，本轮未运行 Assets/www 完整同步。
- 实际 Chrome 152.0.7977.83 的 5 个编译任务通过，零原生文件请求；这仍是旧 IDE 编译入口的浏览器回归，不是 Studio 试玩或用户验收。

上述隔离安装脚本需要本地 pnpm 缓存已包含锁定依赖；缺缓存时应先正常安装，不将离线缓存缺失解释为产品运行失败。测试临时目录和浏览器服务由脚本清理。

## 浏览器编译 Worker（2026-09-15）

`packages/compiler-web` 构建独立静态目录 `dist/browser`。应用通过包导出的 `createBrowserCompiler(workerURL)` 创建客户端，并将整个 browser 目录原样部署。Worker 在自身线程加载锁定的 TypeScript 和共享 TSTL；不需要旧 IDE 的页面、任务队列或原生服务。声明和 lualib 由调用者随完整快照提供；当前 compilerVersion 为 `dora-tstl-0.1.0-ts5.9.3`，options 暂只接受空对象，不静默忽略未知选项。

客户端一次只保留一个活动任务；新请求取消旧请求，完成、失败、取消和超时均释放 Worker。同步编译不能依靠取消消息中断，因此取消会终止 Worker，下一任务重新加载编译器。这样会有冷启动开销，尚未做性能优化；不自动重试或发布旧结果。调用者身份与文件先复制，回复按完整身份和 buildId 关联，忽略迟到或不匹配消息。

TS/TSX 经真实编译生成 Lua、诊断与源码映射；Lua 文件原样打包，不在此阶段证明 Lua 语法或运行正确。混合项目仍编译 TS 文件。二进制资源保留，拒绝编译输出覆盖已有资源及文件/目录冲突。产物含内容 SHA-256；哈希不是签名或源码授权机制。

验证：

- `pnpm test`：23 项测试通过，包括任务替换、迟到回复、身份复制、定向取消、超时恢复及 Worker 启动/执行/解码失败。
- `node Studio/tests/standalone-install.mjs`：包含新 Worker 包的隔离安装、构建和 23 项测试通过。
- `Studio/tests/compiler-worker.browser.mjs` 使用前述 Playwright/Chrome 环境变量执行。Chrome 152.0.7977.83 通过真实 Worker TS/Lua、多文件、诊断偏移、二进制资源、内容哈希、启动前取消、收到 compileStarted 后取消、超时与后续编译恢复、产物覆盖拒绝；编译期间页面计时器持续运行，未请求原生服务。

边界：当前仅 Chrome 桌面测试，不是浏览器矩阵或用户验收；正式编辑器、持久化、诊断 UI、运行时和游戏故障隔离尚未接入。请求资源大小限制、完整消息解码门禁与生产部署头策略仍需在应用入口完善。S-P0-06 保持进行中。

## 本地项目事务存储（2026-09-15）

`apps/web/src/workspace.ts` 是 Web 应用的 IndexedDB 适配，不是另一套通用存储框架。`LocalWorkspace.open()` 后可调用 `list/load/save/remove/close`；`save(name, snapshot, null)` 仅创建 revision 0，后续保存必须传当前 baseRevision，快照 revision 严格递增一次。项目读取和条件写入在同一个读写事务内，两个标签页争用同一修订只有一个提交成功。冲突返回 `WorkspaceError.code = conflict`，调用者应保留未保存草稿，再读取最新版处理冲突，不能自动重试覆盖。

文本随项目记录保存；二进制按 SHA-256 去重，按项目而非文件名计引用。项目和资源引用变化在同一事务提交；失败则全部回滚。只有事务完成才返回保存成功，单次 put 成功不代表已保存。删除也要求 baseRevision，回收无人引用的二进制内容；保留不含名称或源码的已删除项目 ID，禁止复用旧 ID，以免旧标签页误写新项目。另存或重新导入应生成新项目 ID。

配额不足返回 `quota`，连接关闭返回 `closed`，存储不可用返回 `unavailable`；不静默退回只在内存保存。该层不申请持久存储权限，不把浏览器存储视为永久备份；配额提示 UI、导出、云备份与设备间同步仍待实现。

验证：

- 正式应用存储模块 TypeScript 构建通过；`pnpm test` 的既有 23 项回归仍通过。
- 使用前述 Playwright/Chrome 环境变量运行 `node Studio/tests/workspace.browser.mjs`。Chrome 152.0.7977.83 验证真实 IndexedDB 重载恢复、输入复制、二进制去重、两个页面同时保存的原子冲突、过期删除拒绝、资源引用回收、已删除 ID 防复用及关闭连接拒绝访问。
- 故障注入覆盖资源写入后项目 put 抛出 QuotaExceededError，以及 put 成功后事务被中止：原项目和资源引用均保持不变，下一次保存恢复成功。这是回滚逻辑验证，不是实际填满磁盘或浏览器容量上限测量。
- `node Studio/tests/standalone-install.mjs` 已包含 apps 目录，不含旧 IDE 的隔离冻结安装、构建和 23 项测试通过。浏览器存储测试单独执行，不包含在该 Node 测试计数内。

尚未完成正式工作室 UI、编辑/保存状态提示、ZIP 导入导出、配额 UX 和跨浏览器/移动设备验证，因此 S-P0-05 保持进行中；没有用户验收结论。

## 正式工作室本地开发版（2026-09-15）

`apps/web` 已建立 React 19.2.6/Vite 8.0.16 入口，沿用旧 IDE 锁定版本和原型的深灰/金黄主题、无底部文字标识、紧凑工具栏与右侧 Agent 面板。当前编辑器为原生文本编辑区，不宣称具备 Monaco 的补全和语言服务。Agent 和试玩明确标注待接入，不模拟对话、不发出模型请求，也不把编译成功显示为试玩成功。

### 启动与本轮验收操作

在 Studio 目录执行：

```sh
pnpm install --frozen-lockfile
pnpm build
pnpm --filter @dora-studio/web preview --port 8898 --strictPort
```

打开 `http://127.0.0.1:8898/`；停止预览用该终端的 Ctrl+C。开发模式先构建共享包，再运行 `pnpm --filter @dora-studio/web dev`。静态编译器、声明和官方标识由 prepare 脚本复制到忽略的 `.generated` 目录，Vite 发布到 dist；不访问旧 IDE 服务，也不向 Assets/www 写入产物。

1. 输入项目名并创建 TypeScript 项目，在代码区编辑 main.ts；点击保存，刷新页面后从最近项目重开，内容应保留。
2. 输入 `export const answer: number = "wrong";` 并编译；问题列表应出现真实类型错误，点击可选中错误位置。改为 `export const answer = 42;` 后重新编译应成功。
3. 在两个标签页打开同一项目；先在一个页面修改保存，再在另一页修改保存，应提示冲突并保留草稿。“另存副本”应创建新 ID，不覆盖已有项目。
4. 未保存时切换项目或离开页面有保护提示。手机界面通过“工作区 / Dora Agent”切换单面板；试玩页明确提示运行时尚未接入。

保存中暂时禁用文本编辑，成功只认 IndexedDB 事务完成；编译仍消费不可变快照，编辑或项目切换会取消并隔离旧任务。新建文本文件支持项目相对路径；资源上传、ZIP 导入导出、外部链接、云同步、完整 Agent、运行时及发布仍待实现。

验证：`pnpm test` 23 项回归、React 类型检查与 Vite 生产构建通过；包含正式应用与资产准备的隔离冻结安装/构建通过。`Studio/tests/workbench.browser.mjs` 在 Chrome 152.0.7977.83 验证上述核心流程、真实诊断定位、冲突另存、未保存切换取消，以及 1024/736/390/320 宽度无整页溢出。桌面和手机截图已查看，位于忽略目录 `apps/web/artifacts/`。测试创建的项目在隔离浏览器上下文中，不修改用户当前浏览器项目。

这是本地工作室接入验证，不是首版产品或真实移动设备验收。用户视觉与操作评审仍待反馈；S-P0-05/06 保持进行中。

## 试玩隔离门槛

真实 Dora Player 的 iframe 隔离测试已完成第一轮，结果未通过故障恢复门槛；详见 [运行隔离验证](RUNTIME_ISOLATION.md)。因此不将现有 Player 直接嵌入工作室冒充可恢复试玩，后续继续运行 Worker/主线程桥接与 GPU 故障验证。编译 Worker 的成功不能证明游戏运行 Worker 已实现。
# Agent 宿主支持产物

`node tests/agent-host-page.browser.mjs` 验证构建后页面的配置 401/超大响应/重定向和资源缺失处理，不加载实际 WASM；实际引擎链路仍由 `agent-host-callback.browser.mjs` 验证。两者都使用 Playwright/Chrome，自动化通过不等于人工验收。

支持包现包含独立 `index.html` 与 `page.js`。部署目录须提供固定的 `host-config.json`、`host-manifest.json`、`dora-web-features.json` 和 `dora-player-runtime.js`/WASM 及其依赖；清单仅允许可信宿主入口、原 Agent 库和启动配置，不得混入用户游戏脚本。服务端须按当前账号/项目授权配置与清单请求，正确提供 COOP/COEP/CORP，并与工作台使用独立来源。当前测试服务只验证这些接口形状，不提供实际认证。

在 Studio 目录执行 `pnpm build:agent-host`（完整 `pnpm build` 也会执行），生成 `dist/agent-host/host.js`、页面、两份原样 Lua 桥接、从原 TypeScript 编译的 `lua/` Agent 库及 SHA-256 清单。此目录独立于 `apps/web/dist`，不要当作普通游戏 Player 或同源工作台页面部署。消费清单列出的文件，不扫描旧构建目录中的残留文件。

这不是完整可部署服务：仍需带 `studioAgentHost` 标记的专用引擎、可信配置服务和独立来源部署。`host.js` 导出存储命名空间、独占占用和初始化桥接；Agent Lua 直接编译自原实现，不维护第二份决策源码。清单校验只证明文件一致性，不提供来源认证或用户授权。

真实 WASM 回归 `node tests/agent-host-callback.browser.mjs` 现在读取该构建产物，因此运行前须先完成构建；它仍需专用引擎构建和 Playwright/Chrome 环境。不要把该测试服务作为正式产品服务使用。
