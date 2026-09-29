# Dora Agent 本地第三方 Agent 执行后端设计

状态：OpenCode、Codex、ZCode、Claude Code 本地执行后端已完成 macOS 开发和真实 CLI 验收；前三种 Agent 已完成真实 Dora 引擎与游戏创作验收，Claude Code 的新版 Dora 进程端到端浏览器验收待补。Windows/Linux 的实现已纳入桌面平台条件编译，仍待对应真机验证。实施顺序见 [PLAN.md](./PLAN.md)，实际状态和证据以 [开发进度跟踪表](./PROGRESS.md) 为准。

创建：2026-09-28；最后更新：2026-09-29

产品边界：本功能属于 Dora SSR 本地引擎自带的 Dora Agent / Web IDE，代码范围是 `Assets/Script/Dev`、`Assets/Script/Lib/Agent` 和 `Tools/dora-dora`。它与 `Studio/` 下的 Dora Studio 产品、云端 Agent 服务、浏览器 Studio 工作区及其发布路线无关；实现和验收不得以 Dora Studio 作为依赖或交付入口。

## 1. 目标与范围

在 Windows、macOS 和 Linux 桌面设备上，Dora Agent 可以把 Composer 中的用户任务交给本机已经安装的第三方命令行 Agent。当前实现 OpenCode、Codex、ZCode 和 Claude Code。第三方 Agent 直接完成代码编辑、构建和游戏验证，Dora Agent 本身不再为该任务发起任何 LLM 请求。

首版目标：

- 在 Agent 配置窗口中检测、配置和验证本地第三方 Agent。
- 验证成功的本地 Agent 作为一种执行后端出现在 Composer 选择器中。
- 用户选择本地 Agent 后，Prompt 一次性发送给对应 CLI；Dora 不参与其推理和工具循环。
- 捕获第三方 Agent 的结构化输出或 stdout/stderr，并实时显示在 Agent Step List 中。
- 第三方 Agent 通过 `dora cli`，尤其是 `dora cli agent`，访问 Dora 引擎能力。
- 本地 Agent 默认以其支持的完整权限、非交互模式运行。
- 用户正在运行的游戏可以被 Agent 的测试运行打断；多个 Agent 测试运行按 FIFO 排队且互斥。
- 每个 Dora 对话默认持续续接同一个第三方 Agent session，并允许用户显式新建 session、弃用旧 session。
- 在项目工作目录中按所选 Agent 安装适配的 Dora Engine Skill。

首版不包含：

- Dora Agent 与第三方 Agent 之间的双向应用层协议、工具 RPC 或问卷交互。
- Dora Agent 参与第三方 Agent 的推理、审批、重试决策或上下文压缩。
- 在不同第三方 Agent 之间迁移或共享 session。
- 非桌面 Dora 运行环境启动本地进程。
- Dora Studio 的本地或云端 Agent 接入、Studio 模型网关和 Studio 项目同步。
- 后台并行运行多个会争用同一项目或 Entry 运行时的第三方 Agent。
- 恢复已被用户弃用的第三方 session；历史只保留用于显示和审计。

## 2. 核心设计原则

### 2.1 单向依赖

依赖关系固定为：

```text
Dora UI
  └── Local Agent Runner
        ├── 启动 / 停止第三方 CLI
        ├── 保存第三方 resumeId
        ├── 安装项目级 Dora Skill
        └── stdout / stderr / JSONL → Agent Step List

第三方 Agent
  └── dora cli agent → Dora 引擎 Tool Bridge
```

Dora 只向第三方 Agent 发送一次 Prompt，之后只观察进程输出和退出状态。第三方 Agent 不回调 Dora Agent，也不会把自己的工具调用映射为 Dora Agent 工具调用。

`dora cli agent` 只提供引擎状态、受控预览、日志和单向 command bridge，不启动 Dora Agent 或第三方 Agent，因此第三方 Agent 调用它不会形成递归调用。

### 2.2 执行后端而非伪模型

Composer 当前显示“模型”，但本地 Agent 不是模型配置。界面复用原有选择位置，数据模型升级为执行后端：

```ts
type AgentBackendId = `llm:${number}` | `local:${number}`;

type AgentBackendChoice =
	| {id: AgentBackendId; kind: "llm"; name: string; llmConfigId: number}
	| {id: AgentBackendId; kind: "local"; name: string; localAgentConfigId: number};
```

现有 LLM API 路径保持不变。本地 Agent 使用独立配置和运行入口，不在 `LLMConfig` 中伪造 URL、model 或 API key。

### 2.3 Dora 会话和第三方会话分离

- **Dora AgentSession**：保存用户可见消息、任务、Step、checkpoint 和界面历史。
- **第三方 external session**：由 Codex、Claude Code、OpenCode、ZCode 等 CLI 自己保存上下文。
- **external resumeId**：Dora 唯一需要保存的第三方上下文标识。

Dora 不把完整历史重新发送给第三方 Agent。每一轮重新启动 CLI 进程，并通过第三方 Agent 自己的 resume 参数续接上下文。

## 3. 组件边界

| 组件 | 职责 | 不负责 |
| --- | --- | --- |
| Agent 配置窗口 | 本地 Agent 配置、检测、验证和状态展示 | 启动实际开发任务 |
| Composer | 选择下一轮执行后端、发送 Prompt、停止当前任务、新建本地 session | 解释第三方协议 |
| Local Agent Runner | 参数拼装、进程生命周期、输出读取、session 捕获和错误归一化 | Dora LLM 调用和游戏引擎实现 |
| Local Agent Adapter | 每种 CLI 的检测、验证、fresh/resume 参数、输出解析、权限参数和 Skill 调用语法 | UI 与持久化 |
| Session Store | Dora session 与 external resumeId 的映射、代次和弃用状态 | 保存第三方完整隐藏上下文 |
| Skill Installer | 按项目和 Agent 安装/升级 Engine Coding、Command 和 Music Skill | 修改用户的 AGENTS.md/CLAUDE.md |
| Dora CLI Tool Bridge | 引擎状态、构建、文档、预览、日志及 Lua/Git command 访问 | 启动或编排任何 Agent |
| EntryRunQueue / EntryLease | Agent 预览 FIFO、Entry 互斥、Agent 优先和清理 | 第三方 Agent session 管理 |

## 4. 本地 Agent 配置与验证

### 4.1 平台范围

本地 Agent 配置只在 Dora SSR 本地 Web IDE 运行于 `Windows`、`macOS` 和 `Linux` 时展示。其他 Dora 运行环境不提供本地进程能力，也不显示不可用的选择项。此处的 Web IDE 是 Dora 引擎内置开发界面，不是 Dora Studio。

GUI 应用获得的 `PATH` 可能与用户终端不同，因此配置必须允许自动检测和显式可执行文件路径。实际验证和运行必须使用完全相同的 executable、参数、环境处理和工作目录策略。

### 4.2 配置结构

```ts
interface LocalAgentConfig {
	id: number;
	name: string;
	provider: "codex" | "claude-code" | "opencode" | "zcode";
	executable: string;
	extraArgs: string[];
	verifiedAt?: number;
	verifiedVersion?: string;
	verifiedFingerprint?: string;
}
```

命令使用 executable 与参数数组保存和启动，不保存一个交给 shell 解析的拼接字符串。修改 executable、provider 或参数后立即清除验证状态。

### 4.3 配置窗口

原“大模型配置”窗口升级为“Agent 配置”，至少包含：

- `LLM API`
- `本地 Agent`

本地 Agent 页直接显示 OpenCode、Codex、ZCode、Claude Code Logo 卡片与激活状态。选择卡片后载入真实默认命令，用户可以直接验证或调整 executable/额外参数；“验证并激活”成功后配置才出现在 Composer 中。已有配置可从同一卡片进入修改、重新验证或移除。

### 4.4 验证流程

验证不能只执行 `--version`，应使用与实际运行相同的 Adapter：

1. 解析 executable，禁止 shell 插值。
2. 执行无副作用版本或登录探针。
3. 在临时工作目录中以非交互、完整权限和结构化输出模式发送最小 Prompt。
4. 验证进程成功、输出可解析、Agent 能返回约定文本，并取得 session ID（若该 Agent 会在首轮报告）。
5. 清理临时目录，记录版本、可执行文件指纹和验证时间。

实际模型探针可能产生第三方服务用量，界面必须明确提示。登录、限额、网络、命令不存在和输出协议不兼容要分别显示，不以退出码零单独认定可用。

## 5. Local Agent Adapter

所有供应商差异收敛到 Adapter：

```ts
interface LocalAgentAdapter {
	detect(config: LocalAgentConfig): Promise<DetectionResult>;
	verify(config: LocalAgentConfig): Promise<VerificationResult>;
	buildFreshCommand(input: LocalAgentTurnInput): SpawnSpec;
	buildResumeCommand(input: LocalAgentTurnInput, resumeId: string): SpawnSpec;
	parseStdout(chunk: Uint8Array): LocalAgentEvent[];
	parseStderr(chunk: Uint8Array): LocalAgentEvent[];
	flush(): LocalAgentEvent[];
	getResumeId(): string | undefined;
	isSessionMissing(events: readonly LocalAgentEvent[]): boolean;
	skillInvocation(prompt: string): string;
}
```

首版预设：

| Agent | Fresh / streaming | Resume | Skill 调用 |
| --- | --- | --- | --- |
| Codex | `codex exec --json --dangerously-bypass-approvals-and-sandbox` | `codex exec … resume <thread-id> <prompt>` | `$dora-engine-coding …` |
| Claude Code | `claude -p --dangerously-skip-permissions --output-format stream-json --verbose`，fresh 时指定 session ID | `claude -p --resume <id> …` | `/dora-engine-coding …` |
| OpenCode | `opencode run --format json --dir <project>` | `opencode run --session <id> …` | `Use the dora-engine-coding skill: …` |
| ZCode | 使用其 app-server 结构化协议 | 使用协议的 session resume/load | `Use the dora-engine-coding skill: …` |

具体参数以实现时安装版本的 `--help` 和真实运行验证为准，不能只依据本文长期假设。用户配置的显式参数优先时，Adapter 不得追加互相冲突的 fresh/resume 参数。

## 6. 进程生命周期与权限

### 6.1 启动

- cwd 固定为当前 Dora 项目根目录。
- `shell: false` 或等价安全启动方式。
- Prompt 通过参数数组或协议 stdin 传递，不拼接 shell 命令。
- stdout 和 stderr 始终使用 pipe。
- 本地 Agent 默认使用其支持的完整权限和非交互参数。
- Dora 的网络、命令执行和计划模式开关不作用于本地 Agent，选择本地 Agent 后隐藏这些开关并显示“本地 · 完整权限”。

### 6.2 停止

Composer 的停止按钮终止当前第三方 Agent turn：

1. 先发送该平台的正常中断信号。
2. 给予短暂退出宽限期。
3. 超时后终止整个进程树；Windows 必须覆盖子进程。
4. Step 状态记为 `STOPPED`，保留已经收到的消息和 resumeId。

第一版运行期间不向第三方 Agent 发送第二条用户消息，也不接入 Dora Questionnaire。用户必须等待完成或停止后再发送下一轮。

### 6.3 无输出保护

Runner 记录 stdout/stderr 的最后活动时间。长时间完全没有任何字节时结束任务并报告静默超时；正常的长工具调用只要仍有协议字节就不能误判为静默。

## 7. Dora CLI Tool Bridge 与 Entry 运行权

第三方 Agent 使用普通 `dora cli` 完成文件之外的 Dora 工作。专用 Agent 命令的最小契约为：

```text
dora cli agent status [-p project]
dora cli agent preview [-p project] [--entry init.lua]
                       [--capture-at 0.5,2] [--queue-timeout 30]
dora cli agent command [-p project] --input request.json
dora cli agent log [-n lines]
```

Agent 子命令 stdout 始终只输出一个 JSON 对象；诊断写入 stderr；成功退出码为 0，失败为非零。第三方 Agent 还可以使用现有的：

```text
dora cli doc search …
dora cli doc read …
dora cli build …
dora cli status …
dora cli log …
```

`agent preview` 的 Entry 运行规则：

- 多个 Agent preview 请求进入同一 FIFO 队列。
- 队首请求才可以获取 EntryLease。
- 已由其他 Agent 持有的运行不能被抢占。
- 当前运行若没有 Agent owner，则视为用户游戏，Agent 可以停止它并取得运行权。
- 结果返回 `interruptedUserRun`，让 UI/日志说明用户游戏已被打断。
- 完成、失败和异常路径只清理当前请求拥有的 Entry，并释放队列。
- WebServer 只在收到 `/agent/preview` 时延迟加载 `EntryRunQueue`、`Operation` 和 `CommandPreview`。
- WebServer 只在收到 `/agent/command` 时延迟加载 `Validation` 与 `Command`；JSON 请求使用 `mode: "lua"` + `code`，或 `mode: "git"` + `command/cwd`。
- Command bridge 复用 Dora Agent 已有 `executeCommand()` 的校验、超时、沙箱、EntryLease 和 Web IDE 刷新，不复制实现。音乐生成通过 Lua mode 调用 `Agent.Gen.Music.generateMusicAsync`，不增加独立的音乐 CLI/RPC。
- 普通 Git 可直接调用本地 `git`；Dora Git mode 为统一 JSON、项目根约束和 Web IDE 同步而保留。

## 8. 项目级 Dora Engine Skill

### 8.1 安装时机和路径

配置验证不绑定具体项目。每次本地 Agent turn 启动前，Runner 对当前 projectRoot 幂等安装三项 Skill：

```text
Claude Code:
  .claude/skills/dora-engine-coding/SKILL.md
  .claude/skills/dora-agent-command/SKILL.md
  .claude/skills/music-generation/{SKILL.md,references/*}

Codex / OpenCode / ZCode:
  .agents/skills/dora-engine-coding/SKILL.md
  .agents/skills/dora-agent-command/SKILL.md
  .agents/skills/music-generation/{SKILL.md,references/*}
```

只安装当前 Adapter 需要的路径；切换到另一类 Agent 时再补充对应路径。

### 8.2 Skill 内容

第三方 Agent Skill 是独立源码，不能原样复制 Dora Agent 内部 Skill。它至少包含：

- Dora runtime、入口文件、TypeScript 转 Lua和模块导入规则。
- 禁止在 Dora 游戏代码中生成 DOM、Canvas、Node.js 专用代码。
- 不依赖用户 shell 中已有 `dora` 命令、alias 或 PATH 配置。运行中的引擎根据 `App.executablePath` 和 `Content.assetPath` 在 writable path 生成私有 `dora` shim，并只为第三方 Agent 进程树把 shim 目录置于 PATH 首位；不会修改全局环境。该 shim 只接受 `dora cli ...`，避免 Agent 的裸 `dora help` 等探测意外启动第二个引擎进程；shim 创建失败时才在当前 Prompt 中提供完整绝对命令作为降级。
- 不猜测 Dora API；使用 `dora cli doc search/read` 查证。
- 使用 Agent 自己的文件工具修改源码。
- 使用 `dora cli build` 做编译验证。
- 使用 `dora cli agent preview/status/log` 做受控运行和画面验证。
- 使用 `dora-agent-command` 的 JSON 请求调用引擎 Lua/Git mode；明确它不会启动 Dora Agent。
- 使用 `music-generation` 编写 typed definition、构建并通过同一 command bridge 生成音频；详细类型与 SoundFont 预设放在 references 中按需读取。
- 说明 preview 会抢占用户游戏并进入 Agent FIFO。
- 说明 `dora cli agent` 只连接引擎，不会启动 Agent，禁止自行构造嵌套 Agent 调度。
- 以 stdout JSON 判断 CLI 结果，stderr 只作为诊断。

### 8.3 所有权与升级

- Dora 管理的文件带版本标记。
- 文件缺失时创建；已知 Dora 管理版本可原子升级。Skill 不保存机器相关路径，因此 Dora 安装位置或 Asset 根目录改变时无需改写。
- 没有管理标记的用户文件不得覆盖，状态显示为“自定义 Skill”。
- 不删除整个 skill 目录，不修改 `AGENTS.md`、`CLAUDE.md` 或其他 Agent 的配置。
- 每轮 Prompt（包括 resume）都会列出当前三项 Skill 并要求按需重新读取，因此已有 external session 也能发现升级后的能力。

## 9. 第三方 Session 管理

### 9.1 持久化结构

```ts
interface ExternalAgentSession {
	id: number;
	agentSessionId: number;
	backendConfigId: number;
	generation: number;
	externalResumeId?: string;
	status: "active" | "abandoned";
	skillVersion: string;
	createdAt: number;
	updatedAt: number;
	abandonedAt?: number;
}
```

每个 Dora AgentSession 最多有一个活动的 external session。历史 external session 可以有多个，但首版不提供恢复入口。

### 9.2 默认续接

```text
发送 Prompt
  ├── 没有活动 resumeId → Fresh + Skill invocation
  └── 有活动 resumeId   → Resume 同一个第三方 session
```

- resumeId 一旦从输出流取得就立即持久化，不等待进程成功退出。
- 上一轮成功、失败或用户停止，只要 resumeId 已知，下一轮默认继续。
- 第三方 Agent 在报告 resumeId 前退出时，下一轮重新 fresh。
- 每个 Dora task 保存 backendConfigId、externalSessionId 和 generation 快照。

### 9.3 Session 丢失与自动重建

只有 Adapter 明确识别为“session 不存在/已失效”时才自动重建一次：

1. 将旧 external session 标记为 abandoned。
2. 创建下一 generation。
3. 使用带 Skill 调用的当前 Prompt 启动 fresh session。
4. 在 Step List 中显示“原 session 不可用，已新建 session”。

登录失败、网络失败、服务限额、参数错误和未知协议错误不能触发静默重建。

### 9.4 用户新建 Session

本地 Agent 被选中时，Composer 在后端选择器附近显示 session 状态和菜单：

```text
[Codex · 本地] [会话 a1b2c3d4 ▾]
                  ├── 新建会话
                  └── 复制 Session ID
```

“新建会话”只更新 Dora 持久化状态，不立即启动 CLI：

- 旧 session 标为 abandoned。
- 创建 `generation + 1` 的活动记录，resumeId 为空。
- 下一条 Prompt 启动 fresh session。
- 历史消息和 Step 继续显示，但旧 session 不再被续接。
- 不删除第三方 Agent 自己保存在本机的 session 数据。
- Agent 正在运行时禁用新建操作，用户需要先停止。

切换到另一个本地 Agent 或在 Dora LLM 与本地 Agent 之间切换后，下一次实际发送自动开启新的 external session，避免两个后端拥有不一致的对话历史。仅改变下拉选择、不发送时不弃用现有 session。

## 10. 消息流与 Step List

### 10.1 统一事件

```ts
type LocalAgentEventType =
	| "session"
	| "assistant"
	| "reasoning"
	| "activity"
	| "command"
	| "stderr"
	| "status";

interface LocalAgentEvent {
	type: LocalAgentEventType;
	content: string;
	resumeId?: string;
	rawType?: string;
	timestamp: number;
}
```

已知 Agent 优先解析 JSONL/协议事件；不支持结构化输出时按有界文本块回退。不能因为未知事件而停止整个任务，未知事件可以保留 rawType 并按 activity 展示。

### 10.2 Step 复用

首版复用现有 AgentSessionStep 持久化和增量 patch 通道，新增工具类型：

```ts
{
	tool: "local_agent_message",
	status: "RUNNING",
	params: {
		agent: "codex",
		eventType: "assistant"
	},
	result: {
		content: "正在检查项目结构……"
	}
}
```

规则：

- 同一语义消息的连续 chunk 更新同一个 Step，不为每个 token 或每行新建记录。
- 以约 50—100ms 的批次合并 UI patch，避免 React 和数据库高频写入。
- stderr 作为可折叠诊断消息显示，不冒充 Agent 回复。
- 第三方最终回复仍显示在 Step List，不再调用 Dora LLM 生成第二份总结。
- 进程退出后将最后消息和任务标记为 `DONE`、`FAILED` 或 `STOPPED`。
- 不展示供应商未明确提供的隐藏推理；只显示 CLI 实际输出的内容。

本地 Agent 模式隐藏 Dora 上下文占用环；如果第三方协议明确报告 usage/context，可后续单独展示，缺失时不填零或估算。

## 11. 服务接口建议

以下为内部接口边界，不是需要对外稳定的公共 HTTP API：

```text
/local-agent/list
/local-agent/create
/local-agent/update
/local-agent/delete
/local-agent/detect
/local-agent/verify

/agent/session/local/send
/agent/session/local/stop
/agent/session/local/new
```

`/agent/session/local/send` 输入至少包含 Dora sessionId、Prompt 和 localAgentConfigId。服务端必须重新读取并验证配置、项目根目录和当前 session 映射，不能信任前端传入的 executable 或 resumeId。

事件继续走现有 Agent session refresh/patch 数据流，避免建立第二套 WebSocket 或第三方 Agent RPC。

## 12. UI 行为

### 12.1 Composer

选择列表分组：

```text
Dora Agent
  DeepSeek V3
  Claude API

本地 Agent
  Codex · 本地
  Claude Code · 本地
  OpenCode · 本地
```

- 只显示验证通过的本地配置。
- 选择只影响下一轮；正在运行的 task 使用启动时快照。
- 本地模式隐藏计划、网络、命令和上下文环，显示完整权限与 session 状态。
- 运行中 textarea 禁用，只保留停止操作。
- 无可用 LLM 但有已验证本地 Agent 时，不显示“必须配置 LLM”的阻塞卡片。

### 12.2 Agent 配置窗口

- 支持 Agent 预设、自动检测、显式路径和高级参数。
- 验证结果显示实际 executable、版本、登录状态、测试输出尾部和失败分类。
- 项目级 Skill 状态不混入全局配置验证；选择项目后可显示当前项目“已安装/自定义/待安装”。

### 12.3 历史

- 用户 Prompt 继续存为普通 AgentSessionMessage。
- 第三方输出存为 local_agent_message Steps。
- 新建、自动重建和后端切换写入可见的 session 分隔事件。
- 重开 Dora 对话后能够恢复历史显示和下一轮 resumeId。

## 13. 错误、安全与隐私

### 13.1 错误分类

至少区分：

- executable 不存在或不可执行。
- 未登录或凭据失效。
- Agent 不支持所需的非交互、结构化或 resume 能力。
- session 不存在。
- provider 网络、限额或模型错误。
- 进程崩溃、非零退出、静默超时、用户停止。
- Dora Skill 安装失败或与用户文件冲突。
- Dora 引擎不可用、preview 排队超时、构建或运行失败。

### 13.2 安全边界

- 完整权限是本地 Agent 模式的产品默认，界面必须明确显示。
- 所有启动参数使用数组，不通过 shell 拼接 Prompt、路径或 resumeId。
- 配置接口不得把凭据、完整环境变量或敏感命令行写入 Step。
- 日志保存 provider、版本、退出码、时间和必要诊断，不复制第三方凭据。
- Skill 和第三方输出都是不可信输入；Dora UI 只渲染，不把输出作为自身控制指令执行。
- 项目路径、Skill 路径和 preview entry 必须做绝对根与相对路径校验。

## 14. 兼容与迁移

- 现有 LLMConfig 表和 `/agent/session/send` 保持兼容。
- 本地 Agent 使用独立配置表、external session 表和 send 路径。
- Composer 选择值从数字升级为带类型前缀的字符串；持久化旧数字时按 `llm:<id>` 迁移。
- 旧 AgentSession 没有 external session 记录时正常按 Dora LLM 会话读取。
- 非桌面 Dora Agent 继续使用现有能力，不暴露本地 Agent 配置。
- 生成的 Lua、TypeScript 源以及 `Tools/dora-dora` 本地 Web IDE 组件要保持同步。
- 不修改 Dora Studio 服务、Studio 数据模型、Studio Agent Host 或 Studio 产品界面。

## 15. 验收门槛

首版完成必须同时具备：

1. Windows、macOS、Linux 各至少验证一种第三方 Agent 的检测、真实最小调用、停止和 resume。
2. Codex、Claude Code、OpenCode、ZCode 每个 Adapter 至少完成参数契约和输出 fixture 测试；声明可用的 Adapter 必须另有真实 CLI 验证。
3. 选择本地 Agent 后抓取网络/日志证据，确认 Dora 没有发起 LLM 请求。
4. stdout/stderr/JSONL 能实时反显，长输出不会逐 token 膨胀 Step 或卡死 UI。
5. Fresh → resume → stop → resume → new session → fresh 的 session 状态链通过。
6. session 丢失只自动重建一次，认证/网络错误不误触发重建。
7. Skill 在对应 Agent 目录正确安装、升级并保护用户修改。
8. 第三方 Agent 能依据 Skill 使用 `dora cli doc/build/agent preview/agent command` 完成一次真实游戏修改、Lua/Git 引擎命令和音乐生成验证。
9. Agent preview 打断用户游戏、多个 Agent 请求 FIFO 排队、失败清理和队列超时通过真实引擎验证。
10. 现有本地 Dora LLM Agent、模型切换、计划模式、Step List 和 checkpoint 无回归；Dora Studio 不在本功能验收范围内，也不得因此产生依赖或行为变化。

## 16. ai4kanban 参考与取舍

本方案参考本机 `/Users/Jin/Workspace/ai4kanban` 的以下做法：

- Skill 同时支持 `.claude/skills` 和 `.agents/skills`，并由安装器判断版本和所有权。
- 每轮重新启动 CLI，第三方 Agent 自己保存对话历史，上层只持久化 resumeId。
- Fresh 和 resume 参数由每个 harness/Adapter 独立定义。
- resumeId 从输出流尽早捕获；丢失的 session 使用带完整初始指导的 Prompt 重建。
- 不允许不同 Agent 直接续接彼此的 session。

没有引入 ai4kanban 的卡片、Delivery、工作树、后台 Run 管理和复杂审批体系。Dora 只保留本功能必需的配置、进程、消息、Skill 和 session 五个边界。
