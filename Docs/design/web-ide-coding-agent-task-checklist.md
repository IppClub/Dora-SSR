# Web IDE CodingAgent 开发任务记录清单

## 1. 使用说明

本清单用于后续 Agent 执行开发任务时进行记录、打勾和同步进度。

建议使用方式：

- 每完成一项子任务后，直接更新状态
- 每个开发包尽量独立提交
- 若某项依赖未满足，不提前开始
- 若设计变更，先更新设计文档，再更新本清单

状态约定：

- `[ ]` 未开始
- `[~]` 进行中
- `[x]` 已完成
- `[!]` 阻塞

## 2. 总目标

- [ ] 基于项目根目录识别规则接入 Web IDE Agent
- [x] `CodingAgent` 向外输出结构化工作流事件
- [x] `edit_file` 步骤展示 checkpoint 与文件 diff
- [ ] Web IDE 支持 `Dora!` 入口、Agent 标签页、回滚与差异查看

## 3. 前置确认

- [x] 设计文档已确认，以 [web-ide-coding-agent.md](/Users/Jin/Workspace/Dora-SSR/Docs/design/web-ide-coding-agent.md) 为准
- [x] 后端修改以 [WebServer.yue](/Users/Jin/Workspace/Dora-SSR/Assets/Script/Dev/WebServer.yue) 为主
- [x] 项目根目录识别规则确认：
  - 目录下存在名为 `init` 的文件，后缀不限
- [x] Agent 工作单位确认：
  - 只使用 `project` scope
- [x] 流式策略确认：
  - 仅最终总结阶段流式
- [x] checkpoint 展示策略确认：
  - 仅绑定到 `edit_file` 步骤

## 4. 开发包 A：`CodingAgent.ts` 事件化改造

目标：

- 将 [CodingAgent.ts](/Users/Jin/Workspace/Dora-SSR/Assets/Script/Lib/Agent/CodingAgent.ts) 改造成可观测执行引擎

任务：

- [x] 给 `CodingAgentRunOptions` 增加 `onEvent`
- [x] 给 `CodingAgentRunOptions` 增加 `sessionId`
- [x] 定义 `CodingAgentEvent` 类型
- [x] 增加 `task_started` 事件
- [x] 增加 `decision_made` 事件
- [x] 增加 `tool_started` 事件
- [x] 增加 `tool_finished` 事件
- [x] 增加 `checkpoint_created` 事件
- [x] 增加 `summary_stream` 事件
- [x] 增加 `task_finished` 事件
- [x] 在 `runCodingAgentAsync` 中发任务开始/结束事件
- [x] 在 `MainDecisionAgent.post` 中发 `decision_made`
- [x] 在各 Action 执行前后发工具事件
- [x] 在 `EditFileAction` 中补充 `files: [{ path, op }]`
- [x] 在 `EditFileAction.post` 中发 `checkpoint_created`
- [x] 在 `FormatResponseNode` 中透出流式文本增量

验收记录：

- [ ] 不传 `onEvent` 时原行为不变
- [~] 传 `onEvent` 时事件顺序正确
- [x] `edit_file` 步骤能拿到 checkpointId/checkpointSeq/files
- [x] 仅最终总结阶段有流式事件

备注：

- 提交记录：
- 问题记录：

## 5. 开发包 B：`Agent.Tools.ts` checkpoint/diff 能力

目标：

- 将 checkpoint 内容查询从调试能力升级为稳定能力

任务：

- [x] 在 [Tools.ts](/Users/Jin/Workspace/Dora-SSR/Assets/Script/Lib/Agent/Tools.ts) 增加 `getCheckpointDiff`
- [x] 定义 `CheckpointDiffFile` 类型
- [x] 支持 `write` 类型文件 diff
- [x] 支持 `create` 类型文件 diff
- [x] 支持 `delete` 类型文件 diff
- [ ] 如有必要增加 checkpoint 文件列表辅助接口
- [x] 保持 rollback 与 checkpoint 查询的一致性

验收记录：

- [~] 给定 checkpointId 能返回 before/after 内容
- [x] 新建文件 diff 可用
- [x] 删除文件 diff 可用
- [x] 不再依赖 `getCheckpointEntriesForDebug` 作为前端正式接口

备注：

- 提交记录：
- 问题记录：

## 6. 开发包 C：`WebIDEAgentSession` 与 `WebServer.yue`

目标：

- 建立 Web IDE Agent 的会话层与后端 API

任务：

- [x] 新建 [WebIDEAgentSession.ts](/Users/Jin/Workspace/Dora-SSR/Assets/Script/Lib/Agent/WebIDEAgentSession.ts)
- [x] 设计并创建 `AgentSession` 表
- [x] 设计并创建 `AgentSessionMessage` 表
- [x] 设计并创建 `AgentSessionStep` 表
- [x] 增加 session 读写接口
- [x] 增加 step upsert 能力
- [x] 增加 message 追加能力
- [x] 增加 taskId 到 stopToken 的映射管理

`WebServer.yue` 接口任务：

- [x] 增加 `/agent/project-root`
- [x] 增加 `/agent/session/create`
- [x] 增加 `/agent/session/get`
- [x] 增加 `/agent/session/send`
- [x] 增加 `/agent/task/status`
- [x] 增加 `/agent/task/stop`
- [x] 增加 `/agent/checkpoint/list`
- [x] 增加 `/agent/checkpoint/diff`
- [x] 增加 `/agent/checkpoint/rollback`

项目根目录识别任务：

- [x] 抽取或复用 `getProjectDirFromFile`
- [x] 增加目录本身是否为项目根目录的判断
- [x] 文件节点支持向上搜索项目根目录
- [x] 找不到项目时返回明确错误消息

事件接入任务：

- [x] `session/send` 调用 `runCodingAgent(..., onEvent)`
- [x] 将 `CodingAgentEvent` 落地为 session step
- [x] 将 `summary_stream` 写入流式 assistant 内容
- [x] 将 `task_finished` 写回 session 状态

验收记录：

- [ ] 可通过项目目录创建 session
- [ ] 可发送 prompt 并得到 taskId
- [ ] status 能返回 step 列表
- [~] diff 接口可返回 checkpoint 文件内容
- [ ] rollback 可回退到目标 seq

备注：

- 提交记录：
- 问题记录：

## 7. 开发包 D：前端 `Service.ts` 与入口接入

目标：

- 打通前端 API 封装和入口交互

任务：

- [x] 在 [Service.ts](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/Service.ts) 增加 `agentProjectRoot`
- [x] 增加 `agentSessionCreate`
- [x] 增加 `agentSessionGet`
- [x] 增加 `agentSessionSend`
- [x] 增加 `agentTaskStatus`
- [x] 增加 `agentTaskStop`
- [x] 增加 `agentCheckpointList`
- [x] 增加 `agentCheckpointDiff`
- [x] 增加 `agentCheckpointRollback`
- [x] 增加相关 TypeScript 类型定义

入口接入任务：

- [x] 在 [FileTree.tsx](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/FileTree.tsx) 增加菜单项 `Dora!`
- [x] 在 [App.tsx](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/App.tsx) 接入左键目录判定逻辑
- [x] 左键项目根目录直达 Agent
- [x] 左键普通目录保持原行为
- [x] 左键文件保持原行为
- [x] 右键目录 `Dora!` 仅对项目根目录生效
- [x] 右键文件 `Dora!` 时向上搜索项目根目录
- [x] 找不到项目时显示提示

状态接入任务：

- [x] 增加 `activeAgentSessionId`
- [x] 增加 `activeAgentScope`
- [x] 增加 Agent tab 打开/复用逻辑

验收记录：

- [ ] 左键项目根目录能进入 Agent
- [ ] 左键非项目目录不误触发
- [ ] 右键文件 `Dora!` 能进入所属项目
- [ ] 无项目归属时提示正确

备注：

- 提交记录：
- 问题记录：

## 8. 开发包 E：Agent UI

目标：

- 提供消息、步骤、diff、rollback 的完整 UI

任务：

- [x] 新建 [AgentPanel.tsx](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/AgentPanel.tsx)
- [x] 新建 [AgentMessageList.tsx](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/AgentMessageList.tsx)
- [x] 新建 [AgentComposer.tsx](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/AgentComposer.tsx)
- [x] 新建 [AgentStepList.tsx](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/AgentStepList.tsx)
- [x] 新建 [AgentFileDiff.tsx](/Users/Jin/Workspace/Dora-SSR/Tools/dora-dora/src/AgentFileDiff.tsx)

展示任务：

- [x] 显示当前项目标题
- [x] 显示当前任务状态
- [x] 显示消息列表
- [x] 显示最终总结流式文本
- [x] 显示离散步骤列表
- [x] 对 `edit_file` 步骤展示 checkpoint 标记
- [x] 展示关联文件名
- [x] 提供 diff 查看入口
- [x] 提供 rollback 入口

交互任务：

- [x] 发送 prompt
- [x] 轮询 task status
- [x] 打开 checkpoint diff
- [x] rollback 后刷新 session 状态
- [~] rollback 后必要时刷新编辑器和资源树

验收记录：

- [x] 能看到工具步骤
- [x] 能看到最终总结流式输出
- [x] `edit_file` 步骤可展开 diff
- [x] rollback 后界面状态正确刷新

备注：

- 提交记录：
- 问题记录：

## 9. 联调清单

- [ ] `CodingAgentEvent` 事件顺序联调
- [ ] `/agent/project-root` 联调
- [ ] `/agent/session/send` 到 `task/status` 联调
- [ ] `summary_stream` 前端显示联调
- [ ] `checkpoint/diff` 联调
- [ ] `checkpoint/rollback` 联调
- [ ] 左键目录入口联调
- [ ] 右键 `Dora!` 入口联调

## 10. 测试清单

项目识别：

- [ ] 目录下存在 `init.yue` 时识别为项目根目录
- [ ] 目录下存在 `init.lua` 时识别为项目根目录
- [ ] 目录下存在 `init.ts` 时识别为项目根目录
- [ ] 普通目录不识别为项目根目录
- [ ] 文件节点可向上搜索最近项目根目录

Agent 工作流：

- [ ] 纯读操作任务可正常完成
- [ ] 含 `edit_file` 的任务可创建 checkpoint
- [ ] 多步任务 step 顺序正确
- [ ] stop 可中断任务
- [ ] task 失败时状态正确

diff/rollback：

- [ ] 修改单文件 diff 正确
- [ ] 创建文件 diff 正确
- [ ] 删除文件 diff 正确
- [ ] rollback 到 `targetSeq=0` 正确
- [ ] rollback 到中间 checkpoint 正确

前端入口：

- [ ] 左键项目根目录打开 Agent
- [ ] 左键普通目录不打开 Agent
- [ ] 右键目录 `Dora!` 正确
- [ ] 右键文件 `Dora!` 正确
- [ ] 无项目归属提示正确

## 11. 提交建议

- [ ] 提交 1：`CodingAgent.ts` 事件化
- [ ] 提交 2：`Agent.Tools.ts` checkpoint diff
- [ ] 提交 3：`WebIDEAgentSession.ts` + `WebServer.yue`
- [ ] 提交 4：`Service.ts` + 入口接入
- [ ] 提交 5：Agent UI

## 12. 风险/阻塞记录

- [ ] 无

记录区：

- 风险 1：
- 风险 2：
- 阻塞 1：
- 阻塞 2：
