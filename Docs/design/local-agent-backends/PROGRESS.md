# Dora Agent 本地第三方 Agent 支持开发进度

关联文档：[设计方案](./README.md) · [实施计划](./PLAN.md)

创建：2026-09-28；最后更新：2026-09-28

## 1. 当前结论

OpenCode、Codex、ZCode 的首版本地执行后端已经完成开发，并在 macOS 上通过真实 CLI、真实 Dora 引擎、三款独立游戏创作、原生构建、Web 构建和浏览器模拟用户验收。

本功能属于 Dora SSR 本地引擎的 Dora Agent / Web IDE，与 `Studio/` 下的 Dora Studio 无关。本次实现和新增测试均未放入或依赖 Studio。

Windows、Linux 已采用相同的桌面条件编译和 xrt 跨平台 subprocess 实现，但本轮没有对应真机，因此状态只记为“实现完成，待平台验证”，不把 macOS 结果外推为跨平台通过。Claude Code 不在本次范围。

## 2. 交付状态

| 范围 | 状态 | 实现与证据 |
| --- | --- | --- |
| Dora CLI Tool Bridge、Entry FIFO、Agent 抢占用户游戏 | 已完成（本地） | `dora cli agent status/preview/log`、`EntryRunQueue`、`EntryLease`；契约和优先级测试通过 |
| 桌面 subprocess Bridge | 已完成（macOS） | `Process.spawn/read/write/stop/destroy`；参数数组启动、增量 stdout/stderr、stdin 关闭、中断和进程树终止；macOS Debug 原生构建通过 |
| LocalAgent 配置与验证 | 已完成（macOS） | 独立 `LocalAgentConfig` 表、CRUD、版本探针、隔离临时目录中的真实最小 Prompt 验证与清理；修改 executable/provider/args 会清除验证状态 |
| OpenCode Adapter | 已完成（macOS） | `run --format json --auto --dir`，支持 `--session`；真实 fresh/resume 通过 |
| Codex Adapter | 已完成（macOS） | `exec --json --dangerously-bypass-approvals-and-sandbox`，支持 `exec resume`；真实 fresh/resume 通过 |
| ZCode Adapter | 已完成（macOS） | `--prompt --json --mode yolo --cwd`，支持 `--resume`；真实 fresh/resume 与多行 JSON `response` 解析通过 |
| Dora 会话接入 | 已完成（macOS） | `/agent/session/send-local` 独立路径不读取 LLM 配置；消息和有界 transcript 进入 `local_agent_message` Step；停止状态持久化 |
| 消息反显与 Composer | 已完成（本地） | verified local backend 出现在选择器；本地模式隐藏 LLM 工具控件和 context window，仅保留靠左的“新会话”按钮；Step List 将本地 Agent 事件逐条渲染为独立卡片 |
| external session | 已完成（macOS） | 默认 resume、切换配置弃用映射、显式 New session、resume ID 持久化、missing session 单次 fresh 重建 |
| Dora 命令环境与 Engine Skill | 已完成（macOS） | v4 在 writable path 生成私有 `dora` shim，仅向第三方 Agent 进程树注入 PATH；Skill 不含机器路径，fresh/resume 均可直接用 `dora cli`；无管理标记的自定义内容保留 |
| 停止与清理 | 已完成（macOS） | 受控进程验收：RUNNING → STOPPED，Step 为 STOPPED，exit code 130，resume ID/已收消息保留，进程不存在 |
| 真实游戏创作 | 已完成（macOS） | 三种 Agent 分别从空目录创作独立游戏，使用 Dora CLI build/preview 完成自检，并以原 session 续轮到 DONE |
| Windows 真机 | 待平台验证 | 需验证 GUI PATH、Unicode/空格路径、interrupt/kill-tree 和真实三 CLI |
| Linux 真机 | 待平台验证 | 需验证发行包环境、GUI PATH、信号/进程组和真实三 CLI |
| Claude Code | 暂缓 | 不属于首版三 Agent 范围 |

## 3. 主要实现位置

- `Source/Http/XrtNetwork.c/.h`：xrt subprocess 窄封装；只在 Windows、macOS、桌面 Linux 启用。
- `Source/Lua/LuaManual.cpp/.h`、`Source/Lua/LuaEngine.cpp`：桌面 Lua `Process` API。
- `Assets/Script/Lib/Agent/LocalAgent.ts/.lua`：配置、验证、三种 Adapter、输出解析、Skill、session 与进程生命周期。
- `Assets/Script/Lib/Agent/Session.ts/.lua`：local turn、Step、消息、停止与运行态恢复。
- `Assets/Script/Dev/WebServer.yue/.lua`：本地配置、验证、发送和 session API；相关模块延迟加载。
- `Tools/dora-dora/src/`：Agent 配置页、Composer 后端切换、session UI 与 Step 反显。
- `Tools/dora-dora/scripts/test-local-agent-backends.mjs`：静态契约与三种真实 CLI fresh/resume 测试。

## 4. 2026-09-28 验收证据

### 4.1 真实本地 Agent CLI

执行：

```bash
cd Tools/dora-dora
pnpm run test:local-agent-backends:real
```

结果：

- Codex CLI `0.157.0`：fresh + resume 通过，取得 `01a0e78e-963…`。
- OpenCode `1.18.32`：fresh + resume 通过，取得 `ses_f1871009…`。
- ZCode `3.9.2-16`：fresh + resume 通过，取得 `sess_2c62233…`。
- 三者都以非交互完整权限参数运行，输出包含约定 marker 和可恢复 session ID。

### 4.2 真实 Dora 引擎链路

- `/local-agent/verify` 对本机 OpenCode、Codex、ZCode 均返回成功和对应版本。
- 新构建再次验证 OpenCode `1.18.32` 成功，验证结束后不存在 `.dora-local-agent-verify-*` 残留目录。
- OpenCode 首轮与续轮使用同一 `ses_…`，assistant 消息与 Step transcript 均持久化。
- Codex 返回 `DORA_CODEX_SKILL_OK` 和 resume ID；新版 Skill 不再出现缺少 YAML frontmatter 的告警。
- ZCode 返回 `DORA_ZCODE_PARSE_OK` 和 `sess_…`，验证了 pretty multi-line JSON 的顶层 `response` 解析。
- `/agent/session/local/new` 清空 resume ID 并将 generation 从 3 增到 4，下一轮会 fresh。
- local turn 创建后立即保持 RUNNING；GET session 不会误归一化为 STOPPED。
- 受控 stop fixture 验证中断、STOPPED Step、保留 transcript/resume ID 和无残留进程。

### 4.3 浏览器模拟用户验收

在真实 Web IDE `http://127.0.0.1:8866` 完成：

- Composer 下拉显示 `OpenCode · Local`、`Codex · Local`、`ZCode · Local`。
- 选择 `OpenCode · Local` 后隐藏 LLM context window 与说明文本，仅显示低强调度的“新会话”按钮。
- 本地模式不显示规划、下载、执行命令等 Dora LLM 控件。
- 为避免污染当前打开的无关游戏项目，浏览器验收不在该项目发送 Prompt；发送、反显、resume、新 session 和 stop 由同一运行中的真实 Dora 引擎 API 完成验收。

### 4.4 构建与自动化回归

通过：

```bash
cd Tools/dora-dora
pnpm run test:local-agent-backends
pnpm run test:entry-run-queue
pnpm run test:entry-lease
pnpm run test:cli-agent
pnpm run test:agent-patch-batch
pnpm run test:agent-session-snapshot
pnpm run test:agent-step-budget
pnpm run build
```

原生构建：

```bash
xcodebuild -project Projects/macOS/Dora.xcodeproj \
  -scheme Dora -configuration Debug \
  -derivedDataPath Projects/macOS/build/local-agent \
  CODE_SIGNING_ALLOWED=NO build
```

结果：`** BUILD SUCCEEDED **`。Web API parity 明确将桌面专属 `Process` 排除，Web runtime 与 Vite 产物构建通过。

Skill v3 路径验证（已被 v4 shim 方案替代）：新构建的 macOS Dora 运行时能够返回实际 Dora 与 Asset 绝对路径，带空格路径的完整命令执行成功。v4 改为在 writable path 生成私有 `dora` shim，并通过 `Process.spawn.env` 只向第三方 Agent 进程树注入 PATH；Skill 和正常 Prompt 不再保存或重复机器路径，shim 失败时保留完整命令降级。

Skill v4 真实验收：原生 `Process.spawn.env` 覆盖测试确认自定义 PATH 和变量进入子进程，同时未丢失继承的 HOME；生成的 POSIX shim 权限为 `0700`。真实 OpenCode 由 `LocalAgent.run` 启动，在没有用户 `dora` alias 的隔离项目中直接执行 `dora cli doc search Node -l en -n 1`，返回 `DORA_SHIM_OK`，最终结果为 `success=true`、exit code 0；生成的 Skill 只含稳定 `dora cli` 指令，不含 Dora 或 Asset 绝对路径。

## 5. 真实游戏创作验收

三种 Agent 分别获得独立空目录和开放式游戏创作任务，要求自行编写 `init.ts`、调用 Dora CLI 构建和预览、查看截图、修复问题并提交验收报告；没有预置游戏源码。

| Agent | 创作项目 | Dora CLI 与运行验收 | session 结果 |
| --- | --- | --- | --- |
| OpenCode | `LocalAgentCreativeAcceptance/OpenCode`，《星尘接力》，718 行 | build/preview 成功；验证标题、实际游玩和 6 秒结束态截图，之后恢复 60 秒正式配置 | `ses_f185c3394ffeVJ689nhSedtijE`，续轮 DONE |
| Codex | `LocalAgentCreativeAcceptance/Codex`，《轨道守卫》，487 行 | build/preview 成功；验证实际游玩、GAME OVER 与按 R 重开 | `01a0e7a3-d263-7413-b95b-b353e851a1d4`，续轮 DONE |
| ZCode | `LocalAgentCreativeAcceptance/ZCode`，《霓虹换轨》，607 行 | build/preview 成功；验证启动标题画面；本轮未自动注入点击来完整走查交互关卡 | `sess_6a0c7293-7746-4295-8cdf-f69c3db24365`，续轮 DONE |

项目内报告：

- `/Users/Jin/Workspace/Dora/LocalAgentCreativeAcceptance/OpenCode/acceptance-report.md`
- `/Users/Jin/Workspace/Dora/LocalAgentCreativeAcceptance/Codex/acceptance-report.md`
- `/Users/Jin/Workspace/Dora/LocalAgentCreativeAcceptance/ZCode/acceptance-report.md`

本轮由真实创作流程发现并修复：

- TypeScript build 快照重复加入 `lualib_bundle.lua`，导致真实项目构建失败；现按 source root 计算目标路径并去重，三个项目随后均可独立 clean build。
- Entry preview 清理普通 `Routine` 时会连带结束 LocalAgent 的进程监控，使外部进程结束后会话仍停在 RUNNING；监控改挂 `Director.systemUI` 后，三种 Agent 均完成 RUNNING → DONE。
- ZCode 在进程退出前可能不输出可解析的 assistant 消息；现立即显示启动状态，并每 30 秒反显运行心跳，超时单独放宽到 30 分钟。它仍不是 token 级流式输出。
- Web IDE Step List 将 status、stderr、assistant、command 和 activity 逐条投影为独立 Step 卡片，界面编号直接按 `1`、`2`……递增；后端仍保留单一可恢复执行 Step、原始事件和 transcript。真实 Codex 历史任务在浏览器中验证 34 条事件均独立显示，命令、消息、活动、告警、DONE 状态与最终摘要完整可见。
- 移除 Composer 上方独立的 Local Agent session 横条和底部重复的权限/session 文本，只在 Composer 左侧工具区提供低强调的本地化“新会话”按钮。按钮沿用原有 `/agent/session/local/new` 语义，任务运行中禁用。
- 第三方 Agent 不向 Dora 回传可靠的 context window/token usage；本地 Agent 模式隐藏 Composer 的 context usage 圆环，内置 Dora LLM 模式继续展示真实或估算的上下文占用。
- 第三方 Agent 正文只在逐条 Step 中显示；运行中恢复 Summary 区“正在思考”动画，结束后只显示“已完成/失败/已停止”的简短状态摘要，不重复正文。OpenCode `tool_use.part.state` 与 Codex `mcp_tool_call` 均解析为 command Step；工具调用默认折叠并只显示 260 字符的单行预览，用户主动展开后在限高滚动区域中查看完整内容。旧会话中误存为 activity 的 Codex MCP 调用也会按工具调用折叠，普通 assistant 正文不截断。
- Local Agent 新增配置使用 OpenCode、Codex、ZCode 三套真实模板；切换模板会同步更新名称、可执行程序和额外参数，Codex 默认加入 `--skip-git-repo-check`。配置窗口同时展示 Dora 自动追加的完整核心命令预览，Local Agent 页签、表格、弹窗、状态、说明和错误提示均补齐中英文 i18n。

## 6. 已知边界与后续项

- Windows/Linux 真机验收未执行；发布前应按第 2 节逐项补证。
- 首版验证探针会产生第三方模型用量；配置界面应继续明确这一点。
- Codex 运行日志中可能出现用户全局配置或其它 skill 的警告；本次验收只确认 Dora 注入 skill 的 frontmatter 告警已消失。
- ZCode CLI 当前输出模式本身会长时间缓冲；Dora 已增加状态与心跳，但若需要实时展示推理/工具调用，仍取决于 ZCode 后续提供稳定的增量事件协议。
- Claude Code Adapter、`.claude/skills` 路径和其真实 session 协议留待下一阶段。

## 7. 维护规则

- 源码检查不能替代构建；mock 不能替代真实 CLI；macOS 不能替代 Windows/Linux。
- 变更 Adapter 参数前必须重新核对已安装 CLI 的 `--help` 并跑真实 fresh/resume。
- 本功能测试保持在 `Tools/dora-dora/scripts` 或原生测试位置，不写入 `Studio/`。
- 更新功能范围时同步修改 `README.md`、`PLAN.md` 和本文件。
