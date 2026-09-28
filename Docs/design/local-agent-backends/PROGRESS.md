# Dora Agent 本地第三方 Agent 支持开发进度

关联设计：[README.md](./README.md)

创建：2026-09-28；最后更新：2026-09-28

## 1. 当前结论

**功能设计基线已经形成，Dora CLI Tool Bridge、Agent preview FIFO 和 Agent 抢占用户游戏的本地基础实现已经写入当前工作树；第三方 Agent 配置、进程运行、消息反显、Skill 安装和 external session 管理尚未实现。**

产品边界：本功能只属于 Dora SSR 本地引擎的 Dora Agent / Web IDE，与 Dora Studio 产品和云端 Agent 路线无关。测试、实现和验收应位于 `Assets/Script` 与 `Tools/dora-dora` 范围；不得为了本功能修改或依赖 `Studio/`。

当前实现仍是未提交工作树变更。已有 Node 契约测试覆盖 `dora cli agent` 的 JSON 协议、EntryRunQueue FIFO/容量/取消以及 EntryLease 的 Agent 优先规则；跨 Windows/Linux 的真实 CLI、真实第三方 Agent、真实 session resume 和完整 UI 尚无验收证据。

本表是实现与验收跟踪，不自动启动开发，也不代替 Git 历史或发布记录。

2026-09-28 当前本地验证（macOS）：

- `cd Tools/dora-dora && npm run test:entry-run-queue`：通过。
- `cd Tools/dora-dora && npm run test:entry-lease`：通过。
- `cd Tools/dora-dora && npm run test:cli-agent`：通过；使用 macOS Debug Dora 可执行文件连接 mock HTTP 服务，验证 CLI 参数和单 JSON协议，不等于真实 `/agent/preview` 引擎验收。
- `git diff --check`：通过。

## 2. 状态与证据规则

| 状态 | 含义 |
| --- | --- |
| 未开始 | 尚未实现 |
| 进行中 | 已有实现，但交付范围尚未闭合 |
| 已实现待验证 | 源码已存在，缺对应层级的完整验收 |
| 已完成（本地） | 实现和明确列出的本地自动化/运行验证通过，不外推其他平台 |
| 已完成 | 全部目标平台与验收门槛通过 |
| 阻塞 | 存在具体外部条件，必须记录解除动作 |
| 暂缓 | 不属于当前首版 |

证据级别分别记录为：文档检查、源码核对、契约/单元测试、构建、真实 Dora 引擎、真实第三方 CLI、跨平台、人工 UI。较低层级不能替代较高层级。

## 3. 阶段概览

| 阶段 | 范围 | 状态 | 完成门槛 |
| --- | --- | --- | --- |
| D0 | 设计、边界与验收基线 | 已完成（本地） | 设计文档和进度表形成并互相链接 |
| P0 | Dora CLI Tool Bridge 与 Entry 运行权 | 进行中 | 当前本地测试通过；补真实引擎回归和三桌面平台验证 |
| P1 | 本地 Agent 配置、检测与验证 | 未开始 | 配置 CRUD、检测、真实最小调用和可用状态闭环 |
| P2 | Adapter 与进程生命周期 | 未开始 | 四类 Agent fresh/stop/输出解析可用 |
| P3 | 消息反显与 Composer 后端切换 | 未开始 | 本地输出进入 Step List，Dora LLM 路径不回归 |
| P4 | 项目级 Dora Skill | 未开始 | 按 Agent 安装、调用、升级和用户修改保护通过 |
| P5 | external session 管理 | 未开始 | 默认 resume、新建/弃用、丢失重建和持久化恢复通过 |
| P6 | 真实游戏开发与跨平台验收 | 未开始 | Windows/macOS/Linux 与真实第三方 Agent 验收通过 |

## 4. D0：设计基线

| ID | 任务 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- |
| D0-01 | 固定单向依赖和无递归边界 | 已完成（本地） | Dora 只启动/观察第三方 CLI；`dora cli agent` 不启动 Agent | [设计 2.1](./README.md#21-单向依赖) |
| D0-02 | 固定执行后端、UI 和数据模型 | 已完成（本地） | LLM 与 local backend 分型，不伪造 LLMConfig | [设计 2.2](./README.md#22-执行后端而非伪模型)、[设计 12](./README.md#12-ui-行为) |
| D0-03 | 固定消息反显方案 | 已完成（本地） | 第三方事件复用 Step patch，批量更新且不调用 Dora LLM 总结 | [设计 10](./README.md#10-消息流与-step-list) |
| D0-04 | 固定 Skill 和 session 方案 | 已完成（本地） | 项目级 Skill、resumeId、新建/弃用和丢失重建有明确边界 | [设计 8](./README.md#8-项目级-dora-engine-skill)、[设计 9](./README.md#9-第三方-session-管理) |
| D0-05 | 记录 ai4kanban 参考与取舍 | 已完成（本地） | 只借鉴 harness/Skill/session，不引入看板调度 | [设计 16](./README.md#16-ai4kanban-参考与取舍)；源码核对 `/Users/Jin/Workspace/ai4kanban/cli/src/lib/agent/` |

## 5. P0：Dora CLI Tool Bridge 与 Entry 运行权

| ID | 任务 | 依赖 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- | --- |
| P0-01 | 增加 `dora cli agent status` | — | 已完成（本地） | stdout 单 JSON；成功/失败退出码稳定 | `Assets/Script/Dev/cli.lua`；`Tools/dora-dora/scripts/test-cli-agent.mjs` 于 2026-09-28 通过 mock HTTP 契约 |
| P0-02 | 增加 `dora cli agent preview` | P0-01 | 已完成（本地） | project/entry/capture/queue 参数传递，stdout 单 JSON | `Assets/Script/Dev/cli.lua`、`Assets/Script/Dev/WebServer.yue`；mock HTTP 契约覆盖；真实引擎回归仍缺 |
| P0-03 | 增加 `dora cli agent log` | P0-01 | 已完成（本地） | 正整数行数校验和 JSON 输出 | `Assets/Script/Dev/cli.lua`；mock HTTP 契约覆盖 |
| P0-04 | EntryRunQueue FIFO | P0-02 | 已完成（本地） | 顺序、容量、重复、取消、release 行为通过 | `Assets/Script/Lib/Agent/Tool/EntryRunQueue.ts/.lua`；`Tools/dora-dora/scripts/test-entry-run-queue.mjs` |
| P0-05 | Agent preview 排队与超时 | P0-04 | 已实现待验证 | WebServer 排队，超时返回位置并可靠释放 | `/agent/preview` 已实现；缺多请求真实引擎并发/超时验证 |
| P0-06 | Agent 抢占用户游戏 | P0-02 | 已完成（本地） | 无 Agent owner 的运行被停止；Agent owner 不能互抢；返回 interruptedUserRun | `EntryLease.ts/.lua`、`CommandPreview.ts/.lua`；`Tools/dora-dora/scripts/test-entry-lease.mjs` |
| P0-07 | WebServer Agent 依赖延迟加载 | P0-02 | 已实现待验证 | WebServer 启动不预加载 Queue/Operation/CommandPreview；首次路由可用 | `WebServer.yue/.lua` 的 import/require 位于 `/agent/preview` handler；缺启动期模块加载回归测试 |
| P0-08 | 生成 Lua 与本地 Web IDE 测试同步 | P0-04、P0-06 | 进行中 | TS/Yue 源与生成 Lua 一致，Agent-only build 与 `Tools/dora-dora` 测试通过 | 当前工作树包含同步 Lua；测试直接读取 Agent TS 源，不依赖 Studio contracts；需要在最终改动后重跑构建 |
| P0-09 | 三桌面平台 CLI/Entry 验收 | P0-01—P0-08 | 未开始 | Windows、macOS、Linux 上真实 status/preview/log、抢占、队列和清理通过 | 当前无跨平台证据 |

## 6. P1：本地 Agent 配置、检测与验证

| ID | 任务 | 依赖 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- | --- |
| P1-01 | 建立 LocalAgentConfig 存储和 CRUD | D0-02 | 未开始 | 与 LLMConfig 分表，增删改查和迁移测试通过 | 无实现 |
| P1-02 | 建立 Adapter 注册表 | P1-01 | 未开始 | Codex、Claude Code、OpenCode、ZCode 由独立 Adapter 注册 | 无实现 |
| P1-03 | 处理 GUI PATH 与显式 executable | P1-02 | 未开始 | 检测结果与实际运行使用同一路径；路径含空格可用 | 无实现 |
| P1-04 | 实现登录/版本探针 | P1-02 | 未开始 | 不只依赖退出码；登录状态和版本可区分 | 无实现；实现时需核对各 CLI 当前版本 |
| P1-05 | 实现真实最小验证 | P1-03、P1-04 | 未开始 | 临时目录中用正式参数完成最小 Prompt，输出可解析 | 无实现；UI 需提示可能产生用量 |
| P1-06 | Agent 配置窗口双页签 | P1-01、P1-05 | 未开始 | LLM API 和本地 Agent 独立管理；只有已验证配置可选 | 当前只有 `LLMConfigDialog.tsx` |
| P1-07 | 桌面平台门禁 | P1-06 | 未开始 | 移动端/Web 不展示本地 Agent 配置和选择 | 无实现 |

## 7. P2：Adapter 与进程生命周期

| ID | 任务 | 依赖 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- | --- |
| P2-01 | 安全 SpawnSpec 与环境处理 | P1-02 | 未开始 | shell=false、参数数组、cwd=projectRoot、stdout/stderr pipe | 无实现 |
| P2-02 | Codex fresh/resume/JSONL Adapter | P2-01 | 未开始 | thread.started 捕获 ID，fresh、resume、stop fixture 通过 | 无实现 |
| P2-03 | Claude Code fresh/resume/stream-json Adapter | P2-01 | 未开始 | session-id/resume 互斥，流解析和 stop fixture 通过 | 无实现 |
| P2-04 | OpenCode fresh/resume/JSON Adapter | P2-01 | 未开始 | `--dir` 与 `--session` 正确，流解析 fixture 通过 | 无实现 |
| P2-05 | ZCode session 协议 Adapter | P2-01 | 未开始 | fresh/resume、输出、stop fixture 通过 | 无实现 |
| P2-06 | 完整权限和非交互默认参数 | P2-02—P2-05 | 未开始 | 支持的 Agent 无审批阻塞，UI 明确显示权限 | 无实现 |
| P2-07 | 停止和进程树清理 | P2-01 | 未开始 | 正常中断、宽限、强制终止；Windows 子进程无残留 | 无实现 |
| P2-08 | 静默超时和输出上限 | P2-01 | 未开始 | 有字节活动不误杀；完全静默可恢复；内存有界 | 无实现 |

## 8. P3：Composer 与消息反显

| ID | 任务 | 依赖 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- | --- |
| P3-01 | Composer 改为 backend ID | P1-01 | 未开始 | 支持 `llm:<id>`/`local:<id>`；旧数字迁移为 LLM | 共享 Composer 已接受 string/number；Dora wrapper 仍强制 Number |
| P3-02 | LLM/local 发送分流 | P2-01、P3-01 | 未开始 | local 路径不解析 LLMConfig、不调用 Dora LLM | 当前 `AgentPanel.tsx` 发送前必须解析 llmConfigId |
| P3-03 | 本地模式控件状态 | P3-01 | 未开始 | 隐藏计划/网络/命令/上下文环，显示完整权限和 session | 无实现 |
| P3-04 | LocalAgentEvent 归一化 | P2-02—P2-05 | 未开始 | assistant/activity/command/stderr/status 可稳定映射 | 无实现 |
| P3-05 | Step 持久化与 patch 合并 | P3-04 | 未开始 | 连续 chunk 合并，50—100ms 批量更新，无逐 token Step | 现有 AgentSessionStep 可扩展；无 local renderer |
| P3-06 | Step List 本地消息渲染 | P3-05 | 未开始 | 消息、命令、stderr、状态和错误清晰显示 | 无实现 |
| P3-07 | 停止按钮接入 Runner | P2-07、P3-02 | 未开始 | UI 状态最终为 STOPPED，保留已收输出和 resumeId | 无实现 |
| P3-08 | 无 LLM 配置时允许 local backend | P3-02 | 未开始 | 已验证本地 Agent 可独立使用，不显示 LLM 阻塞卡 | 无实现 |

## 9. P4：项目级 Dora Skill

| ID | 任务 | 依赖 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- | --- |
| P4-01 | 编写第三方 Agent 专用 Dora Skill | P0 | 未开始 | 不引用 Dora Agent 内部 tool 名；覆盖 Dora runtime 与 CLI | 可参考现有 `Assets/Doc/skills/dora-engine-coding/SKILL.md`，不能直接复制 |
| P4-02 | 实现 Agent 目录映射 | P4-01、P1-02 | 未开始 | Claude 写 `.claude/skills`；其余目标写 `.agents/skills` | 无实现 |
| P4-03 | 实现幂等安装和版本 stamp | P4-02 | 未开始 | 缺失创建、已知旧版升级、原子写入 | 无实现 |
| P4-04 | 保护用户修改 | P4-03 | 未开始 | hash 不匹配不覆盖；UI 显示自定义 Skill | 无实现 |
| P4-05 | Fresh Prompt 调用对应 Skill | P4-03、P2-02—P2-05 | 未开始 | Codex `$`、Claude `/`、其他自然语言调用正确 | 无实现 |
| P4-06 | Skill 驱动真实 Dora 开发闭环 | P4-05、P3 | 未开始 | 第三方 Agent 查文档、改代码、build、preview 并解释证据 | 无真实第三方 Agent 证据 |

## 10. P5：external session 管理

| ID | 任务 | 依赖 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- | --- |
| P5-01 | 建立 ExternalAgentSession 存储 | D0-04、P1-01 | 未开始 | 每个 Dora session 最多一个 active external session | 无实现 |
| P5-02 | 输出流即时保存 resumeId | P2、P5-01 | 未开始 | 首个可靠事件后即持久化，异常退出后仍可恢复 | 无实现 |
| P5-03 | 默认继续同一 session | P5-02 | 未开始 | 连续多轮使用同一个 external resumeId | 无实现 |
| P5-04 | 用户新建并弃用旧 session | P5-01、P3-03 | 未开始 | running 时禁用；下一 Prompt fresh；旧历史可见但不可恢复 | 无实现 |
| P5-05 | 后端切换建立新 session | P5-04 | 未开始 | 只在切换后的实际发送时弃用，不因浏览下拉立即破坏状态 | 无实现 |
| P5-06 | session missing 自动重建一次 | P5-03、P4-05 | 未开始 | 仅明确 missing 触发；带 Skill Prompt；不会无限重试 | 无实现 |
| P5-07 | 重启 Dora 后恢复映射 | P5-01—P5-06 | 未开始 | 重开项目/对话后下一轮能 resume | 无实现 |
| P5-08 | Session UI 和分隔事件 | P5-04、P3-06 | 未开始 | 显示短 ID、新建/复制、自动重建/切换事件 | 无实现 |

## 11. P6：验收与回归

| ID | 任务 | 依赖 | 状态 | 验收标准 | 当前证据 / 缺口 |
| --- | --- | --- | --- | --- | --- |
| P6-01 | 证明 local 模式无 Dora LLM 请求 | P3 | 未开始 | 网络与服务日志显示本轮零 Dora LLM 请求 | 无证据 |
| P6-02 | 消息流性能与长输出 | P3-05 | 未开始 | 长日志不卡 UI、Step 数有界、重开历史一致 | 无证据 |
| P6-03 | Session 状态链 | P5 | 未开始 | fresh→resume→stop→resume→new→fresh 全链通过 | 无证据 |
| P6-04 | Skill 冲突和升级矩阵 | P4 | 未开始 | 缺失、旧版、当前版、用户修改、只读目录行为通过 | 无证据 |
| P6-05 | 真实 Codex 游戏开发 | P4-06、P5 | 未开始 | 真实项目修改、build、preview、续接和新 session 通过 | 无证据 |
| P6-06 | 真实 Claude Code 游戏开发 | P4-06、P5 | 未开始 | 同上 | 无证据 |
| P6-07 | 真实 OpenCode 游戏开发 | P4-06、P5 | 未开始 | 同上 | 无证据 |
| P6-08 | 真实 ZCode 游戏开发 | P4-06、P5 | 未开始 | 同上 | 无证据 |
| P6-09 | macOS 验收 | P0—P5 | 未开始 | 配置、运行、停止、resume、Skill、preview、UI 全链 | 当前仅 CLI/队列局部本地证据 |
| P6-10 | Windows 验收 | P0—P5 | 未开始 | 同上，额外验证进程树终止和路径/编码 | 无证据 |
| P6-11 | Linux 验收 | P0—P5 | 未开始 | 同上，覆盖发行包环境和 GUI PATH | 无证据 |
| P6-12 | Dora LLM Agent 回归 | P3、P5 | 未开始 | 模型选择、计划、工具、Step、checkpoint 无回归 | 无证据 |
| P6-13 | 产品边界隔离 | P1-07、P3 | 未开始 | 非桌面 Dora 环境不暴露本地模式；Dora Studio 无代码、接口、数据或构建依赖变化 | 已迁移当前基础测试到 `Tools/dora-dora` 并撤销为测试新增的 Studio contract/package 改动；完整功能实现后需持续审计 |

## 12. 当前建议实施顺序

| 顺序 | 工作项 | 任务 | 下一验收点 |
| --- | --- | --- | --- |
| 1 | 收口并回归当前 CLI/队列基础 | P0-05、P0-07—P0-09 | Agent-only build、真实 macOS preview 队列/抢占，随后补 Windows/Linux |
| 2 | 建立最小 Adapter/Runner 垂直切片 | P1-01—P2-02 | 先以 Codex 完成检测、验证、fresh、stop 和 JSONL fixture |
| 3 | 接通 Composer 与 Step List | P3-01—P3-08 | 选择 Codex 后无 Dora LLM 请求，消息实时反显 |
| 4 | 加入项目 Skill | P4-01—P4-05 | Codex 能发现 Skill 并正确使用 `dora cli` |
| 5 | 加入 external session | P5-01—P5-08 | Codex 多轮续接、新建/弃用和 session missing 重建 |
| 6 | 扩展其他 Agent 和平台 | P2-03—P2-08、P6 | Claude/OpenCode/ZCode 与 Windows/Linux 实测 |

## 13. 当前自动化命令

在当前实现落盘并生成共享契约后执行：

```bash
cd Tools/dora-dora
npm run test:entry-run-queue
npm run test:entry-lease
npm run test:cli-agent
```

这些测试只证明当前列出的 Node/CLI 契约，不证明真实第三方 Agent、真实模型服务、真实 Dora preview、多平台 GUI PATH 或完整 UI。

## 14. 最近更新

| 日期 | 变化 | 证据边界 |
| --- | --- | --- |
| 2026-09-28 | 建立本地第三方 Agent 支持设计与开发进度基线 | 文档完成，不等于未实现功能已交付 |
| 2026-09-28 | 当前工作树已有 `dora cli agent status/preview/log`、EntryRunQueue、Agent 抢占用户游戏和 WebServer 延迟加载 | 已有源码与局部契约测试；跨平台、真实引擎并发和真实第三方 Agent 尚未验收 |
| 2026-09-28 | 明确功能与 Dora Studio 无关；将为本功能新增的基础测试从 `Studio/` 迁到 `Tools/dora-dora/`，撤销 Queue 的 Studio contract 导出和 Studio scripts | 测试承载位置与产品边界已修正；迁移后三组测试全部通过 |

## 15. 维护规则

- 状态变化时更新现有任务行，不通过新增重复任务掩盖旧状态。
- “已完成”必须同时有实现和对应目标平台/层级的验收证据。
- 源码核对不能替代构建；mock HTTP 不能替代真实引擎；真实 CLI 单次成功不能替代 session、停止和失败矩阵。
- 每条验收证据记录日期、平台、Agent/版本、命令或测试入口和结果；不得保存凭据。
- 设计变化更新 `README.md`，工程状态和证据更新本文件。
