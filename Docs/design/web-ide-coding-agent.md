# Web IDE CodingAgent 接入设计

## 1. 背景

当前项目已经具备以下能力基础：

- 脚本层 `CodingAgent`，可基于 LLM 进行多步代码分析、搜索、编辑和总结。
- `Agent.Tools`，已提供任务、checkpoint、文件修改回滚、文件搜索、TypeScript 构建等基础能力。
- Dora Web IDE，已具备资源树、文件编辑、预览、运行、LLM 配置、WebSocket 通道和编辑状态持久化能力。

当前缺失的是一层面向 Web IDE 用户的交互壳：

- 资源树上下文下发
- Agent 会话管理
- Web 端消息展示
- 任务状态查询与停止
- 修改结果确认与回滚

本设计目标是在不破坏现有 Web IDE 主编辑流的前提下，为资源树选中对象提供 `CodingAgent` 对话能力。

## 2. 目标

### 2.1 用户目标

用户在 Web IDE 左侧资源树中选中一个文件或目录后，可以直接发起与该资源相关的 Agent 对话，例如：

- 解释当前文件
- 修复当前脚本错误
- 在当前目录内重构
- 生成新文件
- 查询 Dora API 用法

### 2.2 技术目标

- 复用现有 `CodingAgent` 与 `Agent.Tools`，避免重复实现编辑能力。
- 复用现有 Web IDE 服务层协议风格，沿用 `WebServer.yue + Service.ts` 的接口组织方式。
- 保持当前 `CodingAgent` 的执行模型不变，即工具步骤非流式，最终总结阶段流式。
- 将 Agent UI 作为 Web IDE 的一个工作区视图，而不是替换当前文件编辑模型。

## 3. 非目标

以下内容不在第一阶段范围内：

- 完整多轮流式 token 逐字输出
- Agent 多人协作或共享会话
- 自动执行高风险写入且无回滚入口
- 跨 workspace 的全局 Agent 管理后台
- 重写现有资源树、编辑器或预览架构

## 4. 现状分析

### 4.1 引擎脚本侧

#### `Assets/Script/Lib/Agent/CodingAgent.ts`

- 已实现任务式多步决策流。
- 输入核心是 `prompt`、`workDir`、`taskId`、`stopToken`、`memoryContext` 等。
- 输出是单次任务结果，不包含 Web 会话概念。
- 当前真正使用流式调用的阶段只有最终总结节点 `FormatResponseNode`。
- `read_file`、`search_files`、`edit_file`、`run_ts_build` 等工具调用阶段目前都不是流式执行。
- 当前更适合作为“执行引擎”，而不是直接作为 Web 交互层。

#### `Assets/Script/Lib/Agent/Tools.ts`

- 已实现：
  - `createTask`
  - `setTaskStatus`
  - `readFile`
  - `readFileRange`
  - `searchFiles`
  - `listFiles`
  - `runSingleTsTranspile`
  - checkpoint 记录与回滚
- 已具备构建“Agent 操作可追踪、可撤销”能力。

这说明后端执行基础已足够，不需要再重新定义底层文件操作协议。

### 4.2 Web IDE 后端

#### `Assets/Script/Dev/WebServer.yue`

已存在的关键接口：

- `/assets`：资源树
- `/editing-info`：编辑标签状态持久化
- `/llm/list` `/llm/create` `/llm/update` `/llm/delete`：模型配置
- `/command`：向引擎发命令
- `/run` `/stop`：运行控制
- `/read` `/write` `/build` `/rename` `/delete` `/new`：文件操作
- 已存在 `getProjectDirFromFile` 逻辑，可通过向上搜索包含名为 `init` 文件的目录识别项目根目录

说明 Web IDE 已有清晰的 HTTP API 风格，新增 Agent 接口应延续这一模式。
`Assets/Script/Dev/WebServer.lua` 仅作为 YueScript 编译产物存在，设计与实现应以 `WebServer.yue` 为主。

### 4.3 Web IDE 前端

#### `Tools/dora-dora/src/App.tsx`

- 已持有：
  - `selectedNode`
  - `selectedKeys`
  - `files`
  - `tabIndex`
  - `treeData`
- 左侧为资源树，右侧为主工作区。
- 当前主工作区支持代码编辑、Markdown、Yarn、Blockly、图片、Spine、TIC80 等视图。

#### `Tools/dora-dora/src/FileTree.tsx`

- 已有右键菜单扩展能力。
- 当前上下文菜单是新增、删除、重命名、上传、下载、构建等。
- 很适合增加 `Dora!` 入口。
- 文件节点的右键 Agent 入口应复用 `Upload` 同类目录提升逻辑，即对文件取父目录。

#### `Tools/dora-dora/src/Service.ts`

- 已集中管理所有 HTTP 和 WebSocket 通信。
- 适合新增 `agentSessionCreate`、`agentSessionSend`、`agentTaskStatus` 等 API 封装。

## 5. 核心设计决策

## 5.1 设计决策一：入口以“项目根目录”识别规则为准

原因：

- Dora 当前已有明确的项目识别语义，即包含名为 `init` 文件的目录是项目根目录，后缀不限。
- Agent 的工作目录若不绑定到项目根目录，容易产生搜索范围、生成目标和运行上下文不一致的问题。
- 文件节点仍然主要承担“打开编辑”的职责，不应因为左键而打断当前编辑流。
- 对文件节点使用右键菜单进入 Agent 更合适，但应以“向上搜索所属项目根目录”为准，而不是直接取父目录。

结论：

- 左键单击目录节点时，先检查该目录是否为项目根目录。
- 只有命中项目根目录时，才进入 Agent 交互界面，并将该目录绑定为后续任务的 `workDir` / scope。
- 若左键目录节点不是项目根目录，则不进入 Agent 界面，保持现有普通目录行为。
- 左键单击文件节点时，保持现有文件打开行为不变。
- 右键菜单提供统一入口 `Dora!`。
- 若右键目标是文件节点，则向上搜索其所属项目根目录；找到才打开 Agent，找不到则提示当前文件未归属一个项目中。
- 若右键目标是目录节点，则仅当该目录为项目根目录时才打开 Agent。
- Agent 是现有编辑工作区的一种新视图，而不是新的全局模式。

## 5.2 设计决策二：在 `CodingAgent` 外增加 Web 会话层

原因：

- `CodingAgent` 当前是一次任务执行器，不具备会话状态管理。
- Web UI 需要：
  - 消息列表
  - 当前 scope
  - 正在运行的任务 ID
  - 结果历史
  - checkpoint 入口

结论：

- 新增一个“会话管理层”包装 `CodingAgent`。
- `CodingAgent` 继续负责推理和工具执行。
- 会话层负责前后端协议与状态持久化。

## 5.3 设计决策三：沿用“工具步骤非流式，最终回答流式”的现有执行模型

原因：

- 当前 `CodingAgent` 已经明确区分了工具执行阶段和最终总结阶段。
- 只有最终总结 `FormatResponseNode` 使用流式输出，其余步骤没有现成的流式事件源。
- 若强行改造所有工具调用为流式，将显著扩大实现与调试范围。

结论：

- 第一阶段保留现状：
  - 工具步骤以离散步骤结果展示
  - 最终 assistant 总结支持流式显示
  - 任务状态通过轮询或状态接口查询
- 后续如需增强体验，优先增加步骤级事件推送，而不是先把全部工具改成 token 流。

## 5.4 设计决策四：checkpoint 必须归属到 `edit_file` 步骤上展示

原因：

- 当前 checkpoint 的创建点就在 `edit_file` 执行成功之后。
- 用户真正关心的是“哪一步改了哪些文件”，而不是抽象的 task 级 checkpoint 列表。
- 若 checkpoint 不绑定具体步骤，前端无法自然展示修改过程，也无法准确挂接 diff 入口。

结论：

- checkpoint 在 UI 上应归属于对应的 `edit_file` 步骤。
- `edit_file` 步骤要展示：
  - checkpoint 标记
  - checkpoint 序号
  - 关联修改文件名
  - 文件 diff 入口

## 6. 目标交互

## 6.1 入口

建议提供两个入口：

- 左键单击项目根目录节点，直接进入该项目的 Agent 界面
- 资源树右键菜单增加 `Dora!`

其中：

- 右键目录节点时，只有当前目录是项目根目录才允许进入 Agent
- 右键文件节点时，从该文件所在目录开始向上搜索项目根目录
- 找到项目根目录后，`Dora!` 进入该项目作用域
- 找不到则提示“当前文件未归属一个项目中”

## 6.2 作用域

会话需绑定作用域：

- `project`，以项目根目录作为工作空间

规则：

- 项目作用域：默认以项目根目录作为搜索、分析、生成和修改的工作目录。
- 项目根目录识别规则与引擎现有规则保持一致，即目录下存在名为 `init` 的文件，后缀不限。
- 文件节点右键进入 Agent 时，不创建独立文件 scope，而是向上搜索最近的项目根目录。
- 文件内容仍可作为上下文传入，但任务的工作目录以项目根目录 scope 为准。
- 内置资源或只读资源：不支持 Agent 功能，相关功能入口不可见。

## 6.3 主工作区布局

建议在主工作区新增 `Agent` 标签页。

Agent 标签页结构：

- 顶部：
  - 当前作用域标题
  - 任务状态
  - 停止按钮
  - rollback 入口
- 中部：
  - 消息列表
  - 步骤列表
  - 对 `edit_file` 步骤显示 checkpoint 标记、文件名和 diff 入口
- 底部：
  - 输入框
  - 快捷提示按钮

快捷提示按钮建议：

- 解释这个文件
- 修复当前错误
- 补充注释
- 重构当前目录
- 搜索 Dora API 用法

## 7. 系统架构

```text
Web IDE React UI
  -> Service.ts
    -> WebServer.yue Agent API
      -> WebIDEAgentSession
        -> CodingAgent.runCodingAgent(...)
          -> Agent.Tools
            -> 文件系统 / DB / LLM / checkpoint
```

分层职责：

- UI 层：展示消息、接收输入、切换会话、展示任务状态、步骤和 diff。
- Service 层：HTTP API 封装。
- WebServer 层：请求解析、路由、返回 JSON。
- Session 层：维护会话与任务关系。
- CodingAgent 层：执行实际推理和工具操作。
- Agent.Tools 层：文件操作、任务状态、checkpoint 能力。

## 8. 后端设计

## 8.1 新增模块

建议新增：

- `Assets/Script/Lib/Agent/WebIDEAgentSession.ts`

职责：

- 创建会话
- 保存会话消息
- 记录会话 scope
- 触发 Agent 任务
- 查询任务状态
- 保存步骤记录
- 将 checkpoint 关联到对应的 `edit_file` 步骤

建议同时生成对应 Lua 文件。

## 8.2 数据模型

### 8.2.1 Session

```ts
interface AgentSession {
	id: number;
	scopeType: "project";
	scopePath: string;
	title: string;
	status: "IDLE" | "RUNNING" | "DONE" | "FAILED";
	currentTaskId?: number;
	readonly: boolean;
	createdAt: number;
	updatedAt: number;
}
```

### 8.2.2 Message

```ts
interface AgentSessionMessage {
	id: number;
	sessionId: number;
	role: "user" | "assistant" | "system";
	content: string;
	kind?: "text" | "summary" | "error";
	taskId?: number;
	createdAt: number;
}
```

### 8.2.3 Task binding

会话与 `AgentTask` 采用 1:N 关系：

- 一个 session 可以有多轮任务
- 一次用户输入通常触发一个 task

### 8.2.4 Step

为了正确展示 checkpoint 与 diff，建议引入显式步骤模型：

```ts
interface AgentSessionStep {
	id: number;
	sessionId: number;
	taskId: number;
	step: number;
	tool: string;
	reason: string;
	paramsJson: string;
	resultJson?: string;
	checkpointId?: number;
	checkpointSeq?: number;
	createdAt: number;
}
```

说明：

- 普通步骤只需要 `tool`、`reason`、`resultJson`。
- `edit_file` 步骤额外记录 `checkpointId` 和 `checkpointSeq`。
- 前端展示步骤时，应以 `AgentSessionStep` 为主模型，而不是直接拼接 history 文本。

## 8.3 新增 HTTP 接口

### 8.3.1 `POST /agent/session/create`

请求：

```json
{
	"scopeType": "project",
	"scopePath": "/abs/path/to/project",
	"title": "MyProject"
}
```

响应：

```json
{
	"success": true,
	"sessionId": 1
}
```

### 8.3.2 `POST /agent/session/get`

请求：

```json
{
	"sessionId": 1
}
```

响应：

```json
{
	"success": true,
	"session": { },
	"messages": [ ]
}
```

### 8.3.3 `POST /agent/session/send`

请求：

```json
{
	"sessionId": 1,
	"prompt": "解释这个文件在做什么",
	"useCurrentEditorContent": true
}
```

响应：

```json
{
	"success": true,
	"taskId": 12
}
```

实现说明：

- 创建 user message
- 创建 Agent task
- 异步调用 `runCodingAgent`
- 完成后写入 assistant message

### 8.3.4 `POST /agent/task/status`

请求：

```json
{
	"taskId": 12
}
```

响应：

```json
{
	"success": true,
	"status": "RUNNING",
	"steps": 3,
	"message": ""
}
```

建议扩展为步骤详情返回：

```json
{
	"success": true,
	"status": "RUNNING",
	"steps": [
		{
			"step": 1,
			"tool": "read_file",
			"reason": "查看当前文件",
			"result": { "success": true }
		},
		{
			"step": 2,
			"tool": "edit_file",
			"reason": "修复空指针问题",
			"checkpointId": 21,
			"checkpointSeq": 1,
			"files": [
				{
					"path": "Script/Foo.ts",
					"changeType": "write"
				}
			]
		}
	]
}
```

这样前端不需要自己推断哪个 checkpoint 对应哪个 `edit_file` 步骤。

### 8.3.5 `POST /agent/task/stop`

请求：

```json
{
	"taskId": 12
}
```

响应：

```json
{
	"success": true
}
```

### 8.3.6 `POST /agent/checkpoint/list`

请求：

```json
{
	"taskId": 12
}
```

响应：

```json
{
	"success": true,
	"items": [ ]
}
```

### 8.3.7 `POST /agent/checkpoint/rollback`

请求：

```json
{
	"taskId": 12,
	"targetSeq": 2,
	"workDir": "/abs/workspace"
}
```

响应：

```json
{
	"success": true,
	"headSeq": 2
}
```

### 8.3.8 `POST /agent/checkpoint/diff`

请求：

```json
{
	"checkpointId": 21
}
```

响应：

```json
{
	"success": true,
	"files": [
		{
			"path": "Script/Foo.ts",
			"op": "write",
			"beforeExists": true,
			"afterExists": true,
			"beforeContent": "...",
			"afterContent": "..."
		}
	]
}
```

说明：

- 接口直接返回 checkpoint 记录中的 `beforeContent` 和 `afterContent`。
- 前端负责渲染为文件级 diff 视图。
- 这样可以保证展示的是“当时那一步的真实改动”，而不是事后重新读盘推断的结果。

## 8.4 `CodingAgent` 接入策略

不建议直接修改 `CodingAgent` 的核心流程为聊天模式。

建议保留：

- `runCodingAgent(options, callback)`

会话层通过拼接 prompt 注入上下文：

- scope 信息
- 当前文件路径
- 当前目录路径
- 当前编辑内容摘要
- 最近几轮用户问题与答案摘要

第一阶段上下文策略：

- 当前作用域描述
- 最近 3 轮消息
- 当前活动文件内容或目录信息

第一阶段不改造 `CodingAgent` 为工具阶段流式执行器。
Web IDE 只需要消费两类输出：

- 工具阶段的离散步骤记录
- 最终 `FormatResponseNode` 的流式总结文本

### 8.4.1 改造目标

`CodingAgent.ts` 需要从“内部自洽的任务执行器”改造成“可观测的执行引擎”。

改造目标不是让它直接依赖 Web IDE，而是让它能够向外输出结构化执行信息，供 Web 会话层消费。

第一阶段至少要向外提供：

- 任务开始与结束信息
- 每一步决策出的 tool call
- 每个工具步骤的执行结果
- `edit_file` 步骤产生的 checkpoint 信息
- 最终总结阶段的流式文本增量

### 8.4.2 建议新增运行事件接口

建议在 `CodingAgentRunOptions` 中增加：

```ts
onEvent?: (event: CodingAgentEvent) => void;
sessionId?: number;
```

建议新增事件模型：

```ts
type CodingAgentEvent =
	| {
		type: "task_started";
		taskId: number;
		prompt: string;
		workDir: string;
	}
	| {
		type: "decision_made";
		step: number;
		tool: AgentToolName;
		reason: string;
		params: Record<string, unknown>;
	}
	| {
		type: "tool_started";
		step: number;
		tool: AgentToolName;
	}
	| {
		type: "tool_finished";
		step: number;
		tool: AgentToolName;
		result: Record<string, unknown>;
	}
	| {
		type: "checkpoint_created";
		step: number;
		tool: "edit_file";
		checkpointId: number;
		checkpointSeq: number;
		files: {
			path: string;
			op: string;
		}[];
	}
	| {
		type: "summary_stream";
		textDelta: string;
		fullText: string;
	}
	| {
		type: "task_finished";
		success: boolean;
		taskId?: number;
		message: string;
		steps?: number;
	};
```

说明：

- `CodingAgent` 只负责抛出结构化事件，不直接处理 WebSocket、HTTP 或 UI。
- WebIDE 会话层负责接收这些事件并写入 session / step 数据。

### 8.4.3 建议改造点位

建议在以下位置发事件：

1. `runCodingAgentAsync(...)`
- 创建 shared 后，发 `task_started`
- 返回前，发 `task_finished`

2. `MainDecisionAgent.post(...)`
- 当一步决策已确定 `tool/reason/params` 后，发 `decision_made`

3. 各 Action 的 `exec/post`
- 工具开始执行前，发 `tool_started`
- 工具结果落地到 history 后，发 `tool_finished`

4. `EditFileAction.post(...)`
- 若执行结果中存在 `checkpointId/checkpointSeq`
- 额外发 `checkpoint_created`

5. `FormatResponseNode.exec(...)`
- 在流式总结过程中发 `summary_stream`

### 8.4.4 `edit_file` 特殊处理

`edit_file` 是当前唯一会生成 checkpoint 的高价值步骤，建议作为特殊步骤处理。

当前 `EditFileAction.exec()` 已经能返回：

- `checkpointId`
- `checkpointSeq`
- `mode`
- `replaced`

建议继续补充：

```ts
files: [
	{
		path: input.path,
		op: "create" | "write"
	}
]
```

这样 Web 会话层不必再从 checkpoint 反推“是哪个文件触发了这一步修改”。

### 8.4.5 `CodingAgent` 与 `Tools` 的职责边界

不建议把 diff 计算逻辑塞进 `CodingAgent.ts`。

建议职责划分如下：

- `CodingAgent.ts`
  - 提供步骤级事件
  - 告诉外部哪一步创建了哪个 checkpoint
  - 告诉外部该步骤涉及哪些文件

- `Agent.Tools.ts`
  - 提供 checkpoint 文件内容查询
  - 提供 rollback 能力
  - 维护 checkpoint 的 before/after 内容

- WebIDE Session / API 层
  - 将 `CodingAgentEvent` 转为可持久化的 step 记录
  - 为前端提供 `/agent/checkpoint/diff`

### 8.4.6 最小改造范围

第一阶段只建议对 `CodingAgent.ts` 做以下最小改造：

1. 增加 `onEvent`
2. 在任务生命周期、决策点、工具结束点发结构化事件
3. 在 `EditFileAction` 中显式上报 checkpoint 信息和文件列表
4. 在 `FormatResponseNode` 中把流式文本增量向外透出

不建议第一阶段做：

- 全工具流式输出
- 让 `CodingAgent.ts` 直接依赖 WebServer 或 WebSocket
- 让前端解析自然语言总结来重建步骤信息

## 8.6 详细接口设计

### 8.6.1 `CodingAgentEvent` 详细定义

建议的 TypeScript 类型如下：

```ts
export interface CodingAgentTaskStartedEvent {
	type: "task_started";
	sessionId?: number;
	taskId: number;
	prompt: string;
	workDir: string;
	maxSteps: number;
}

export interface CodingAgentDecisionMadeEvent {
	type: "decision_made";
	sessionId?: number;
	taskId: number;
	step: number;
	tool: AgentToolName;
	reason: string;
	params: Record<string, unknown>;
}

export interface CodingAgentToolStartedEvent {
	type: "tool_started";
	sessionId?: number;
	taskId: number;
	step: number;
	tool: AgentToolName;
}

export interface CodingAgentToolFinishedEvent {
	type: "tool_finished";
	sessionId?: number;
	taskId: number;
	step: number;
	tool: AgentToolName;
	result: Record<string, unknown>;
}

export interface CodingAgentCheckpointCreatedEvent {
	type: "checkpoint_created";
	sessionId?: number;
	taskId: number;
	step: number;
	tool: "edit_file";
	checkpointId: number;
	checkpointSeq: number;
	files: {
		path: string;
		op: "write" | "create" | "delete";
	}[];
}

export interface CodingAgentSummaryStreamEvent {
	type: "summary_stream";
	sessionId?: number;
	taskId: number;
	textDelta: string;
	fullText: string;
}

export interface CodingAgentTaskFinishedEvent {
	type: "task_finished";
	sessionId?: number;
	taskId?: number;
	success: boolean;
	message: string;
	steps?: number;
}

export type CodingAgentEvent =
	| CodingAgentTaskStartedEvent
	| CodingAgentDecisionMadeEvent
	| CodingAgentToolStartedEvent
	| CodingAgentToolFinishedEvent
	| CodingAgentCheckpointCreatedEvent
	| CodingAgentSummaryStreamEvent
	| CodingAgentTaskFinishedEvent;
```

字段约束：

- `step` 采用与 `shared.step + 1` 一致的用户可见步号。
- `params` 为原始结构化参数，不做自然语言格式化。
- `result` 为工具执行结果，不做裁剪之外的语义变换。
- `summary_stream` 只用于最终回答阶段，不用于工具步骤。

### 8.6.2 `WebIDEAgentSession` 数据表设计

建议新增以下表：

```sql
CREATE TABLE IF NOT EXISTS AgentSession(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	scope_type TEXT NOT NULL,
	scope_path TEXT NOT NULL,
	title TEXT NOT NULL,
	readonly INTEGER NOT NULL DEFAULT 0,
	status TEXT NOT NULL,
	current_task_id INTEGER,
	created_at INTEGER NOT NULL,
	updated_at INTEGER NOT NULL
);
```

```sql
CREATE TABLE IF NOT EXISTS AgentSessionMessage(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	session_id INTEGER NOT NULL,
	task_id INTEGER,
	role TEXT NOT NULL,
	kind TEXT NOT NULL DEFAULT 'text',
	content TEXT NOT NULL,
	created_at INTEGER NOT NULL
);
```

```sql
CREATE TABLE IF NOT EXISTS AgentSessionStep(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	session_id INTEGER NOT NULL,
	task_id INTEGER NOT NULL,
	step INTEGER NOT NULL,
	tool TEXT NOT NULL,
	reason TEXT NOT NULL,
	params_json TEXT NOT NULL,
	result_json TEXT,
	checkpoint_id INTEGER,
	checkpoint_seq INTEGER,
	status TEXT NOT NULL,
	created_at INTEGER NOT NULL,
	updated_at INTEGER NOT NULL
);
```

推荐索引：

```sql
CREATE INDEX IF NOT EXISTS idx_agent_session_scope ON AgentSession(scope_type, scope_path);
CREATE INDEX IF NOT EXISTS idx_agent_message_session_id ON AgentSessionMessage(session_id, id);
CREATE INDEX IF NOT EXISTS idx_agent_step_task_step ON AgentSessionStep(task_id, step);
CREATE INDEX IF NOT EXISTS idx_agent_step_checkpoint ON AgentSessionStep(checkpoint_id);
```

状态建议：

- `AgentSession.status`: `IDLE | RUNNING | DONE | FAILED`
- `AgentSessionStep.status`: `PENDING | RUNNING | DONE | FAILED`

### 8.6.3 `WebIDEAgentSession` 模块接口

建议导出：

```ts
createSession(req: {
	scopeType: "project";
	scopePath: string;
	title: string;
	readonly: boolean;
}): { success: true; sessionId: number } | { success: false; message: string };

getSession(sessionId: number): {
	success: true;
	session: AgentSessionRecord;
	messages: AgentSessionMessageRecord[];
	steps: AgentSessionStepRecord[];
} | {
	success: false;
	message: string;
};

appendUserMessage(sessionId: number, taskId: number | undefined, content: string): boolean;
appendAssistantMessage(sessionId: number, taskId: number | undefined, kind: string, content: string): boolean;
upsertStepFromEvent(sessionId: number, event: CodingAgentEvent): boolean;
setSessionTask(sessionId: number, taskId: number | undefined, status: string): boolean;
```

会话层消费 `CodingAgentEvent` 的规则：

- `task_started`
  - 更新 session 当前 task
- `decision_made`
  - 创建 step 记录，状态为 `PENDING`
- `tool_started`
  - 将该 step 状态改为 `RUNNING`
- `tool_finished`
  - 写入 `result_json`，状态为 `DONE`
- `checkpoint_created`
  - 回填到对应 step 的 `checkpoint_id` / `checkpoint_seq`
- `summary_stream`
  - 更新一条临时 assistant message，或维护内存态缓冲
- `task_finished`
  - 将 session 状态改为 `DONE` 或 `FAILED`

### 8.6.4 `WebServer.yue` 新增接口详细定义

#### `POST /agent/project-root`

用途：

- 给前端提供统一的项目根目录解析能力
- 避免在 React 端复制项目根目录识别逻辑

请求：

```json
{
	"path": "/abs/path/to/file/or/dir",
	"isDir": false
}
```

响应：

```json
{
	"success": true,
	"found": true,
	"projectRoot": "/abs/path/to/project",
	"title": "MyProject"
}
```

未找到：

```json
{
	"success": true,
	"found": false,
	"message": "当前文件未归属一个项目中"
}
```

实现建议：

- 若传入目录：
  - 检查该目录下是否存在名为 `init` 的文件
- 若传入文件：
  - 从其所在目录开始向上搜索
- 该逻辑应复用或抽取自现有 `getProjectDirFromFile`

#### `POST /agent/session/create`

请求：

```json
{
	"scopeType": "project",
	"scopePath": "/abs/path/to/project",
	"title": "MyProject",
	"readonly": false
}
```

响应：

```json
{
	"success": true,
	"sessionId": 7
}
```

#### `POST /agent/session/get`

请求：

```json
{
	"sessionId": 7
}
```

响应：

```json
{
	"success": true,
	"session": {
		"id": 7,
		"scopeType": "project",
		"scopePath": "/abs/path/to/project",
		"title": "MyProject",
		"readonly": false,
		"status": "RUNNING",
		"currentTaskId": 12
	},
	"messages": [],
	"steps": []
}
```

#### `POST /agent/session/send`

请求：

```json
{
	"sessionId": 7,
	"prompt": "修复当前项目中角色初始化的问题",
	"entryFile": "/abs/path/to/project/Script/Player.ts",
	"useCurrentEditorContent": true,
	"editorContent": "..."
}
```

字段说明：

- `entryFile` 为触发入口文件，可选
- `editorContent` 仅在前端有未保存内容时传入

响应：

```json
{
	"success": true,
	"taskId": 12
}
```

后台执行流程：

1. session 追加一条 user message
2. 调用 `runCodingAgent`
3. 通过 `onEvent` 持续落地 step / checkpoint / stream 状态
4. 任务完成后写 assistant message

#### `POST /agent/task/status`

请求：

```json
{
	"taskId": 12
}
```

响应：

```json
{
	"success": true,
	"task": {
		"taskId": 12,
		"status": "RUNNING",
		"steps": 2
	},
	"steps": [
		{
			"id": 31,
			"step": 1,
			"tool": "read_file",
			"reason": "查看角色初始化逻辑",
			"params": {
				"path": "Script/Player.ts"
			},
			"result": {
				"success": true
			},
			"status": "DONE"
		},
		{
			"id": 32,
			"step": 2,
			"tool": "edit_file",
			"reason": "修复空引用",
			"params": {
				"path": "Script/Player.ts"
			},
			"result": {
				"success": true,
				"mode": "replace",
				"replaced": 1
			},
			"checkpointId": 21,
			"checkpointSeq": 1,
			"files": [
				{
					"path": "Script/Player.ts",
					"op": "write"
				}
			],
			"status": "DONE"
		}
	],
	"streamingMessage": {
		"role": "assistant",
		"content": "正在总结修改结果……"
	}
}
```

#### `POST /agent/task/stop`

请求：

```json
{
	"sessionId": 7,
	"taskId": 12
}
```

响应：

```json
{
	"success": true
}
```

说明：

- 会话层需要维护 taskId 到 stopToken 的映射
- stop 后 session 状态应更新为 `IDLE` 或 `FAILED`

#### `POST /agent/checkpoint/list`

请求：

```json
{
	"taskId": 12
}
```

响应：

```json
{
	"success": true,
	"items": [
		{
			"checkpointId": 21,
			"checkpointSeq": 1,
			"step": 2,
			"tool": "edit_file",
			"files": [
				{
					"path": "Script/Player.ts",
					"op": "write"
				}
			]
		}
	]
}
```

#### `POST /agent/checkpoint/diff`

请求：

```json
{
	"checkpointId": 21
}
```

响应：

```json
{
	"success": true,
	"files": [
		{
			"path": "Script/Player.ts",
			"op": "write",
			"beforeExists": true,
			"afterExists": true,
			"beforeContent": "old content",
			"afterContent": "new content"
		}
	]
}
```

#### `POST /agent/checkpoint/rollback`

请求：

```json
{
	"sessionId": 7,
	"taskId": 12,
	"targetSeq": 0
}
```

响应：

```json
{
	"success": true,
	"headSeq": 0
}
```

### 8.6.5 `Agent.Tools.ts` 需新增的稳定接口

建议在 `Agent.Tools.ts` 中正式提供：

```ts
export interface CheckpointDiffFile {
	path: string;
	op: "write" | "create" | "delete";
	beforeExists: boolean;
	afterExists: boolean;
	beforeContent: string;
	afterContent: string;
}

export function getCheckpointDiff(checkpointId: number): {
	success: true;
	files: CheckpointDiffFile[];
} | {
	success: false;
	message: string;
};
```

说明：

- 不建议继续使用 `getCheckpointEntriesForDebug` 作为前端 API 基础
- 应新增一个面向产品逻辑的稳定接口

### 8.6.6 前端 `Service.ts` 类型定义

建议新增：

```ts
export interface AgentProjectRootRequest {
	path: string;
	isDir: boolean;
}

export interface AgentProjectRootResponse {
	success: boolean;
	found?: boolean;
	projectRoot?: string;
	title?: string;
	message?: string;
}
```

```ts
export interface AgentSessionRecord {
	id: number;
	scopeType: "project";
	scopePath: string;
	title: string;
	readonly: boolean;
	status: "IDLE" | "RUNNING" | "DONE" | "FAILED";
	currentTaskId?: number;
}

export interface AgentMessageRecord {
	id: number;
	taskId?: number;
	role: "user" | "assistant" | "system";
	kind: "text" | "summary" | "error";
	content: string;
}

export interface AgentStepFile {
	path: string;
	op: "write" | "create" | "delete";
}

export interface AgentStepRecord {
	id: number;
	step: number;
	tool: string;
	reason: string;
	params: Record<string, unknown>;
	result?: Record<string, unknown>;
	checkpointId?: number;
	checkpointSeq?: number;
	files?: AgentStepFile[];
	status: "PENDING" | "RUNNING" | "DONE" | "FAILED";
}

export interface AgentCheckpointDiffFile {
	path: string;
	op: "write" | "create" | "delete";
	beforeExists: boolean;
	afterExists: boolean;
	beforeContent: string;
	afterContent: string;
}
```

建议 `Service.ts` 新增方法：

```ts
export const agentProjectRoot = (req: AgentProjectRootRequest) => post<AgentProjectRootResponse>("/agent/project-root", req);
export const agentSessionCreate = (...) => post(...);
export const agentSessionGet = (...) => post(...);
export const agentSessionSend = (...) => post(...);
export const agentTaskStatus = (...) => post(...);
export const agentTaskStop = (...) => post(...);
export const agentCheckpointList = (...) => post(...);
export const agentCheckpointDiff = (...) => post(...);
export const agentCheckpointRollback = (...) => post(...);
```

### 8.6.7 前端交互时序

#### 左键点击目录节点

```text
FileTree.onSelect(dir)
  -> Service.agentProjectRoot({ path: dir.key, isDir: true })
    -> found ? open/reuse Agent session(projectRoot) : keep normal folder behavior
```

#### 右键文件节点选择 `Dora!`

```text
FileTree.onMenuClick("Dora!", file)
  -> Service.agentProjectRoot({ path: file.key, isDir: false })
    -> found ? open/reuse Agent session(projectRoot) : show alert("当前文件未归属一个项目中")
```

#### 发送一条 Agent 消息

```text
AgentComposer.submit(prompt)
  -> Service.agentSessionSend(...)
  -> poll Service.agentTaskStatus(taskId)
  -> update step list / streaming summary
  -> task finished
```

#### 点击 checkpoint diff

```text
AgentStepList.openDiff(checkpointId)
  -> Service.agentCheckpointDiff({ checkpointId })
  -> AgentFileDiff.render(beforeContent, afterContent)
```

#### 点击 rollback

```text
AgentStepList.rollback(checkpointSeq)
  -> Service.agentCheckpointRollback({ sessionId, taskId, targetSeq })
  -> reload session state
  -> refresh editor/tree if needed
```

## 8.5 安全与约束

### 内置资源

若作用域位于内置资源目录：

- 允许 `read_file`
- 允许 `search_dora_api`
- 允许 `search_files`
- 禁止 `edit_file`
- 禁止 `delete_file`

### 只读标签

若当前文件在 Web IDE 中被判定为只读：

- session 标记 `readonly = true`
- 后端执行前再次检查，避免仅依赖前端

### 路径约束

继续复用 `Agent.Tools.ts` 中已有 workspace 路径校验逻辑，不新增第二套规则。

### checkpoint 与 diff 约束

- 只有产生文件修改的 `edit_file` 步骤才展示 checkpoint 区块。
- `read_file`、`search_files`、`run_ts_build` 等步骤不展示 checkpoint 徽标。
- diff 数据来源必须是 checkpoint 的 `before_content` / `after_content`。
- rollback 粒度保持为 checkpoint 级，不做行级回退。

## 9. 前端设计

## 9.1 新增组件

建议新增：

- `Tools/dora-dora/src/AgentPanel.tsx`
- `Tools/dora-dora/src/AgentMessageList.tsx`
- `Tools/dora-dora/src/AgentComposer.tsx`
- `Tools/dora-dora/src/AgentCheckpointPanel.tsx`
- `Tools/dora-dora/src/AgentStepList.tsx`
- `Tools/dora-dora/src/AgentFileDiff.tsx`

## 9.2 `App.tsx` 集成方式

新增状态建议：

```ts
type AgentScope = {
	scopeType: "project";
	scopePath: string;
	title: string;
	readonly: boolean;
};
```

```ts
const [agentSessions, setAgentSessions] = useState<Record<string, number>>({});
const [activeAgentSessionId, setActiveAgentSessionId] = useState<number | null>(null);
const [activeAgentScope, setActiveAgentScope] = useState<AgentScope | null>(null);
```

键建议使用：

- `project:/abs/path/to/project`

这样可以对单个项目复用会话。

## 9.3 资源树集成

在 `FileTree.tsx` 中新增菜单项：

- `Dora!`

触发后由 `App.tsx` 执行：

1. 根据节点类型构造 scope
2. 创建或复用 session
3. 在主工作区切换到 Agent 标签页

具体规则：

1. 左键单击目录节点：
- 先检查该目录下是否存在名为 `init` 的文件，后缀不限
- 若是项目根目录，则直接切换到该项目作用域的 Agent 标签页
- 将该项目根目录记录为后续 Agent 任务的工作目录
- 若不是项目根目录，则保持现有普通目录行为，不进入 Agent

2. 左键单击文件节点：
- 保持现有打开文件行为

3. 右键点击目录节点并选择 `Dora!`：
- 仅当该目录为项目根目录时，进入该项目作用域的 Agent 标签页
- 否则提示当前目录不是项目根目录

4. 右键点击文件节点并选择 `Dora!`：
- 不创建独立文件 scope
- 从该文件所在目录开始向上搜索最近的项目根目录
- 找到后，以该项目根目录作为 scope 打开 Agent
- 找不到则提示“当前文件未归属一个项目中”

## 9.4 Agent 标签页

Agent 标签页建议与普通文件标签并列，但不是文件型标签。

可选实现：

- 方案 A：把 Agent 作为特殊 `EditingFile`
- 方案 B：新增独立的 `WorkspaceView`

建议采用方案 A 的轻量变体：

- 在 tab 数据中增加一个特殊类型，例如 `kind: "file" | "agent"`
- 与现有标签栏机制兼容，改动面最小

## 9.5 当前编辑内容注入

对于由文件进入项目 Agent 的场景，发送消息时可选择是否附加当前文件的未保存内容。

建议默认行为：

- 若入口来源于某个文件，且该文件已在编辑器打开并存在未保存修改，则优先发送未保存内容摘要或完整内容
- 若入口来源于目录或文件未打开，则按磁盘内容处理

第一阶段为降低复杂度，可以先只传：

- 触发入口文件路径
- 当前文件是否有未保存修改
- 是否建议 Agent 先读该文件

第二阶段再支持直接传入当前 buffer 内容。

## 10. 持久化设计

## 10.1 会话持久化

建议使用 DB 表而不是 `editingInfo` 直接存大块消息。

原因：

- `editingInfo` 适合轻量 UI 状态
- Agent 会话消息可能持续增长

建议新增表：

- `AgentSession`
- `AgentSessionMessage`

## 10.2 UI 状态持久化

`editingInfo` 可扩展保存：

- 当前激活的 Agent sessionId
- 已打开的 Agent 标签页列表

只保存 UI 恢复需要的信息，不保存大消息文本。

## 11. 实施计划

## 阶段一：可用版本

目标：

- 能从资源树发起 Agent 对话
- 能看到任务完成结果
- 能停止任务
- 能回滚本轮修改

工作项：

1. 新建 `WebIDEAgentSession.ts`
2. 增加 `/agent/session/*` 与 `/agent/task/*` 接口
3. `Service.ts` 增加对应 API
4. `FileTree.tsx` 增加 `Dora!` 入口，并接入项目根目录判定逻辑
5. `App.tsx` 增加 Agent 标签页容器
6. 新建 `AgentPanel.tsx`
7. 改造 `CodingAgent.ts`，向外输出步骤事件、checkpoint 事件和最终总结流式事件
8. 打通 session 创建、发送消息、轮询状态、展示结果
9. 打通 checkpoint 列表、diff 与 rollback

## 阶段二：体验增强

目标：

- 会话历史更完整
- 消息展示更自然
- 上下文更强

工作项：

1. 会话消息持久化
2. 预置 prompt chips
3. 当前编辑 buffer 注入
4. 任务步骤展示优化
5. 错误态与只读态优化

## 阶段三：高级能力

目标：

- 提升响应体验
- 增强调试能力

工作项：

1. WebSocket 推送任务事件
2. 流式输出
3. 更细粒度的工具执行日志
4. 多会话管理
5. Agent 结果与编辑器差异展示

## 12. 风险

## 12.1 会话与任务模型不一致

风险：

- `CodingAgent` 是任务式
- Web UI 是对话式

控制措施：

- 增设 session 包装层
- 不直接侵入 `CodingAgent` 主执行流

## 12.2 修改风险

风险：

- Agent 可编辑文件，可能影响用户当前工作

控制措施：

- 强制走 checkpoint
- 提供 rollback
- 内置资源和只读文件禁止写

## 12.3 UI 集成复杂度

风险：

- 现有 `App.tsx` 已较大

控制措施：

- 采用新增独立组件的方式
- 将 Agent UI 尽量封装在 `AgentPanel.tsx`
- `App.tsx` 只负责会话切换与布局挂载

## 12.4 流式方案调试成本

风险：

- 若首版就做流式和 WS 事件协议，调试成本高

控制措施：

- 首版先做轮询
- 稳定后再升级为 WS 事件流

## 13. 建议的首版范围

建议严格控制首版范围如下：

- 项目根目录作用域优先
- 左键项目根目录直达 Agent
- 从资源树右键 `Dora!` 打开 Agent
- 单轮输入触发一次 Agent 任务
- 工具步骤离散展示
- 展示最终答复
- 展示任务状态
- 支持停止
- `edit_file` 步骤展示 checkpoint 标记
- 支持 checkpoint 回滚
- 支持文件级 diff 展示
- 文件右键进入时支持向上搜索所属项目根目录
- 找不到所属项目时给出明确提示

不建议首版就做：

- 多标签共享 Agent 会话
- 全工具流式 token
- 自动接管当前编辑 buffer
- 大规模 UI 重构

## 14. 结论

这项功能适合按“Web IDE 会话层 + `CodingAgent` 执行层”的结构落地。

最稳妥的实现路径是：

- 不改变资源树单击行为
- 左键目录节点直接进入 Agent
- 左键目录节点先校验是否为项目根目录
- 在资源树上下文中增加 `Dora!`
- 在主工作区中新增 Agent 标签页
- 后端新增 session 与 task API
- 复用现有 `Agent.Tools` 的任务和回滚能力
- 将 checkpoint 绑定到 `edit_file` 步骤，并以文件 diff 形式展示修改内容

这样可以在现有项目结构上以较小的侵入成本完成第一版，并为后续流式输出、多轮对话和更强上下文支持留出清晰扩展路径。
