# Dora SSR Web IDE 性能优化方案

状态：实施完成待外部验收，P0～P5 已落地，物理手机验收因无连接设备而阻塞

最后更新：2026-07-26

进度跟踪：[PROGRESS.md](./PROGRESS.md)

## 1. 背景

Dora SSR Web IDE 已覆盖资源树、Monaco 编辑器、多类型可视化编辑器、Dora Agent、文件导入、Git 工作区、日志和性能分析等功能。随着功能增加，当前性能问题已经不再集中于单一组件，而是来自以下几类叠加：

1. 非激活 Tab 和隐藏面板仍保持完整 React 组件、事件监听和观察器。
2. Agent 流式消息、日志、Profiler 和 Splitter 拖拽等高频事件进入较大的 React 状态树。
3. Monaco、MUI、Ant Design 和部分业务模块构成较重的首屏加载与执行成本。
4. 跳转文件、Git 历史等大数据路径虽然限制了最终显示数量，但仍在主线程或后端提前完成大量不必要工作。
5. 当前缺少固定的性能基线、自动采样脚本和回归门槛，优化效果主要依赖主观感受。

本方案的目标是先减少隐藏工作和高频重渲染，再处理首屏资源和大数据查询，最后建立持续性能回归机制。

## 2. 范围与非目标

### 2.1 本期范围

- Web IDE 首次打开和恢复编辑状态。
- 顶部文件 Tab、资源树、Splitter 和状态栏。
- Dora Agent 会话加载、流式输出、历史消息和自动滚动。
- 日志、Profiler 和底部日志面板。
- 跳转文件搜索。
- Git 工作区和 Commit 历史。
- Monaco Editor、语言 Worker 和可视化编辑器的加载与生命周期。
- HTTP/WebSocket 数据批处理、缓存和取消。
- PC 浏览器和手机触屏设备上的交互稳定性。

### 2.2 非目标

- 不改变 Dora 引擎运行时、渲染器或游戏逻辑性能。
- 不为了性能重写现有 UI 视觉风格。
- 不一次性迁移所有 MUI 组件到 Ant Design。
- 不取消编辑状态恢复、Agent 会话缓存或后台任务通知。
- 不把所有计算都迁移到 Worker；只有经过测量的主线程热点才迁移。

## 3. 当前基线

以下数据来自 2026-07-26 的本地工作区和正在运行的 Web IDE。开发模式包含 HMR 和调试开销，DOM、监听器和 Heap 数值用于比较趋势，不作为生产环境绝对承诺。

### 3.1 页面运行时

| 指标 | 当前结果 | 说明 |
| --- | ---: | --- |
| DOM Elements | 约 2,642 | 恢复两个 Tab、资源树和一个项目工作区后 |
| DOM Nodes | 约 5,636 | Chrome Performance 指标 |
| JS Event Listeners | 约 2,978 | 完整界面稳定后 |
| JS Heap Used | 约 180 MB | 开发模式稳定后 |
| 面板切换后监听器峰值 | 约 4,496 | 文件、Git、Dora 往返后采样 |
| 面板切换后 Heap Used | 约 205 MB | 未强制 GC，主要用于观察增长趋势 |
| 文件面板首次可见 | 约 298 ms | 本地开发模式 |
| Git 面板首次可见 | 约 422 ms | 本地开发模式 |
| Dora 面板恢复可见 | 约 295 ms | Agent 视图保留挂载 |
| 跳转文件输入 React commit | 三轮 P95：1.10 / 1.10 / 1.00 ms | 生产构建、每轮独立页面各 50 次输入；不含 Worker 的 50 ms debounce |
| 自动 PC 冷启动 | 三轮 150.6 / 143.1 / 141.9 ms | 独立无头 Chrome 页面，资源树可用后采样 |
| 自动 PC 跳转文件输入 | 三轮 P95：0.8 / 0.8 / 0.7 ms | 每轮 50 次受信输入并等待实际 Top 100；覆盖冷索引完成路径 |
| 自动 PC 三 Tab 切换 | 三轮 P95：45.6 / 44.2 / 48.2 ms | 每轮预热后切换 21 次，`main` 峰值均为 2 |
| 自动 PC 稳定性 | 三轮 DOM/listener 增量均 0；Heap +1.29/+1.20/+1.15 MiB | 采样前后显式 GC，保证轮次可比 |
| 生产构建 Agent 面板往返 | 20 次后 11 条 assistant 行、32 条步骤行均 0 次额外 render | `?doraPerf=1` 行级计数；DOM Elements 4,062 → 4,062 |
| 生产构建稳定性复测 | 20 次后监听器 652 → 634、Heap 108.7 → 71.7 MiB、DOM Elements 4,063 → 4,063 | 5 次预热并等待 5 秒后取基线，操作完成后等待 15 秒自然回收 |
| 生产构建 Agent 30 秒流式压力 | 1,201 patch；frame P50/P95/max 8.3/9.0/10.3 ms；0 Long Task | 每 25 ms 注入实际 Agent session patch 事件，经 50 ms 批处理、React 行渲染和自动滚动完整链路；稳定历史行 0 次额外 render，listener 增量 0 |
| Chrome 移动触控仿真 | 390×844 纵屏内容区保持 390 px，资源树以 319 px 覆盖层开合；844×390 横屏 Splitter 触摸移动 40 px；搜索输入 P95 0.8 ms、Top 100 | DPR 3、5 个触点；覆盖窄屏资源树开合、横屏触摸拖动、跳转文件、首次 Esc、资源树项目打开，以及同页横屏转纵屏时资源树自动收起；控制台 0 错误 |
| iOS Simulator Safari | 390×844 纵屏 Agent、文件、Git 三面板可见且可切换 | 既有 Agent 会话首帧直接恢复；资源树默认收起并以 82% 宽覆盖层开合；无空状态闪烁或页面崩溃 |

### 3.2 构建资源

| 资源 | 原始大小 | gzip 约值 | 当前加载特征 |
| --- | ---: | ---: | --- |
| Monaco 主包（拆分前） | 4.28 MB | 1.08 MB | `index.html` modulepreload |
| Monaco 主包（拆分后） | 3.73 MB | 约 916 KB | 首次显示文本编辑器时按需加载；HTML 无 preload |
| TypeScript Worker | 6.90 MB | 1.48 MB | 首次 TS/TSX/JS 语言服务使用，Dora/文件/Git 首屏不加载 |
| Ant Design | 978 KB | 307 KB | 首屏 modulepreload |
| MUI/Emotion | 357 KB | 108 KB | 首屏 modulepreload |
| App 主模块（P5 拆分前） | 303 KB | 85.2 KB | 首屏业务入口 |
| App 主模块（P5 面板拆分后） | 163 KB | 49.0 KB | Dora/Git/Upload 已移出主模块；含仅诊断模式启用的性能探针 |
| Dora Agent 面板 | 70.2 KB | 19.2 KB | 首次进入 Dora 时加载，之后保持挂载；含行级渲染诊断 |
| Git 面板 | 54.6 KB | 15.0 KB | 首次进入 Git 时加载 |
| 文件导入面板 | 15.1 KB | 5.0 KB | 首次进入文件面板时加载 |
| LogView | 1.47 MB | 426 KB | 动态模块 |
| Blockly | 1.06 MB | 258 KB | 动态模块 |
| 完整 build 目录 | 约 35 MB | - | 包含 Worker 和独立编辑器资源 |

### 3.3 数据路径

| 路径 | 当前结果 | 判断 |
| --- | --- | --- |
| `/assets` | 118 KB JSON，gzip 约 7.4 KB，约 52 ms | 不是当前首要瓶颈 |
| 初始树节点 | 约 891 个带 `key` 节点 | 内置资源仍可继续懒加载 |
| 跳转文件索引 | 41,752 个文件 | 需要避免主线程全量模糊匹配 |
| `/assets/files` | 解压约 3.65 MB，gzip 约 174 KB，约 0.48 秒 | `Content.glob` 已避免读取完整资源树，但结果仍较大 |
| `matchSorter` | 单次短查询约 16–56 ms | 会阻塞输入帧 |
| Git Commit 数 | 仓库 3,073 个，接口最多返回 100 个 | 前端无需优先虚拟化 |
| Git 100 条历史（优化前） | 本地约 1.3–1.8 秒，响应约 229 KB | Go 层为每条 Commit 提前计算文件 Diff |
| Git 100 条历史（metadata-only） | 本地约 52–69 ms，响应约 22.7 KB | 列表不再包含 changed files；进入 Commit 变更页后按需加载 |

### 3.4 可重复采样命令

在 `Tools/dora-dora` 下执行：

```bash
pnpm perf:baseline
pnpm perf:browser
pnpm perf:agent:browser
pnpm perf:mobile:browser
pnpm perf:log
pnpm test:file-search-index
pnpm build
pnpm test:heavy-assets
pnpm perf:bundle
pnpm perf:bundle:check
```

- `perf:baseline` 自动测量 `/assets`、`/assets/files`、4 组 `matchSorter` 查询和 `/git/history`。默认从 `/assets` 返回值识别当前可写工作区，也可用 `DORA_PERF_BASE_URL`、`DORA_PERF_WORKSPACE` 和 `DORA_PERF_REPO` 覆盖。
- `perf:browser` 启动独立的无头 Chrome，以三轮独立页面采集生产 Web IDE
  冷启动、50 次跳转文件输入、21 次三 Tab 往返、DOM、活动 listener 和
  强制可比 GC 后 Heap。默认预算为搜索 P95 < 16 ms、Tab P95 < 100 ms、
  同时挂载 `main` 不超过 2、listener 增长不超过 5、Heap 增长不超过
  10 MiB；任一轮超限即以非零状态退出。可用 `DORA_PERF_BASE_URL`、
  `DORA_PERF_CHROME`、`DORA_PERF_RUNS`、`DORA_PERF_SAMPLE_FILE` 和
  `DORA_PERF_PROJECT_PATHS` 覆盖运行环境与样本。
- `perf:agent:browser` 使用已有长会话作为历史背景，在本地诊断模式通过实际
  `AgentSessionPatch` 事件入口持续 30 秒注入 patch，覆盖 50 ms 合并、React
  消息行、历史行稳定性、长任务、动画帧、自动滚动、listener 和 GC 后 Heap。
  它不调用模型、不写入会话数据库，因此结果可重复；真实模型端到端 smoke
  仍作为外部服务验收单独执行。
- `perf:mobile:browser` 使用 Chrome 的移动设备和触点仿真，依次验证 390×844
  纵屏和 844×390 横屏、DPR 3 环境。纵屏覆盖全宽内容区和资源树覆盖层开合；
  横屏覆盖 Splitter 触摸拖动、4 万文件 Top 100 搜索、首次 Esc 关闭、资源树
  项目打开；随后在同一页面切换为纵屏，确认资源树自动收起且内容区恢复全宽，
  并检查控制台错误。该命令验证浏览器触控事件路径，不能替代物理手机的最终
  手感、浏览器地址栏和系统手势冲突检查。
- `perf:log` 默认以每秒 400 行持续输出 30 秒；可通过 `DORA_LOG_DURATION` 和 `DORA_LOG_LINES_PER_SECOND` 调整。
- `test:file-search-index` 使用 41,752 文件的固定样本验证 Top 100、增量新增、目录删除、嵌套目录移动和 Worker 接线。
- `test:heavy-assets` 验证 TypeScript 与 Monaco Worker 的版本化引用、文件存在性和内容哈希。
- `perf:bundle` 对生产构建中的 JS/CSS 计算原始和 gzip 大小，并列出最大的 20 个文件。
- `perf:bundle:check` 从入口、modulepreload 与 App 静态依赖递归计算
  hydrated IDE shell，排除 Monaco 主包和语言 Worker 后执行 700 KiB gzip
  预算检查。
- 生产浏览器可通过 `?doraPerf=1` 对 Agent 消息/步骤行做直接渲染计数，
  并在隐藏诊断节点上暴露活动 DOM listener 总数、按事件类型计数、
  `usedJSHeapSize`、Monaco 与 TypeScript Worker 是否已加载，以及跳转文件输入事件
  到对应 React layout commit 的 count/P50/P95/max。输入样本最多保留 200 个，
  每次打开跳转文件组件重新开始采样；它反映主线程受控输入更新，不混入浏览器
  自动化控制通道和 Worker debounce。上述诊断默认关闭，不进入普通运行路径。
  自动触控仿真已由 `perf:mobile:browser` 覆盖；物理手机仍需最终验收，不能由
  CDP 仿真替代。

## 4. 性能目标与预算

### 4.1 交互目标

| 场景 | 目标 |
| --- | --- |
| 顶部 Tab 切换 | 已缓存视图 P95 小于 100 ms |
| Dora/文件/Git 面板切换 | 已加载面板 P95 小于 120 ms |
| Splitter 拖拽 | 无连续长任务，接近 60 FPS |
| Agent 流式输出 | 每秒最多提交 React 10–20 次，输入和滚动保持可响应 |
| 跳转文件输入 | 主线程单次处理 P95 小于 16 ms |
| 跳转文件首次结果 | 缓存命中小于 100 ms，冷启动小于 600 ms |
| 资源树展开 | 普通目录 P95 小于 100 ms |
| Git 工作区首次打开 | 中型仓库 P95 小于 800 ms，大型仓库先显示概要再增量加载 |

### 4.2 资源与稳定性目标

| 指标 | 目标 |
| --- | --- |
| 首屏 gzip JS | 不含 Monaco 控制在 700 KB 内 |
| Monaco/TS Worker | 未打开文本或 TS 文件前不加载对应重资源 |
| 隐藏面板更新 | 不触发 Observer、滚动同步和 React 内容更新 |
| 面板往返稳定性 | 连续切换 20 次后监听器数量不持续增长 |
| Heap 稳定性 | 连续切换 20 次并等待自然 GC 后增长不超过 10 MB |
| 日志内存 | 默认限制 10,000 行或 4 MB，达到上限后丢弃最旧内容 |
| Agent 历史 | 长会话只挂载可见窗口和必要上下文 |

## 5. 核心设计原则

### 5.1 状态保留不等于视图保留

Agent 会话、编辑文件内容和 Git 选择状态可以保存在 store、Monaco Model 或缓存对象中，但不可见页面不应继续保留完整 DOM、Observer、定时器和 Markdown 渲染。

### 5.2 高频数据不直接进入大组件

WebSocket patch、日志、Profiler、窗口 resize 和 Splitter resize 必须先合并、限频或局部消费，不能每个事件都刷新 App 顶层状态。

### 5.3 先返回概要，再按需返回详情

Git Commit 列表只需要元数据；文件 Diff 在选中 Commit 后请求。文件搜索只返回 Top N；历史消息只渲染当前窗口。

### 5.4 用测量决定 Worker 和虚拟化

资源树已经启用 Ant Design 虚拟滚动，且首屏 `/assets` 数据较小，不应优先重写。跳转文件匹配已达到 16–56 ms，适合进入 Worker。Git Commit 固定最多 100 条，不需要仅为数量引入虚拟化。

### 5.5 优化必须可回退

每一阶段都应保持独立开关或清晰提交边界。若生命周期优化造成编辑状态丢失、Agent 闪屏或滚动行为回归，应能单独回退该阶段。

## 6. 分阶段实施方案

## 阶段 P0：建立可重复基线

目标：先把当前主观卡顿转换成可重复的指标。

实施内容：

1. 增加本地性能采样脚本，记录首屏、DOM、监听器、Heap、资源大小和关键交互耗时。
2. 固定三个测试场景：
   - 空工作区和单文本文件。
   - 两个项目 Tab，其中一个包含 Agent 会话。
   - 运行项目并持续产生日志和 Agent 流式输出。
3. 为 20 次 Tab/面板切换、30 秒日志输出和 30 秒 Agent 流式输出建立稳定性检查。
4. 记录 PC 和手机触屏设备各一组基线。

交付物：

- 可重复运行的本地脚本。
- 首次基线记录。
- 后续任务共用的验收模板。

## 阶段 P1：隐藏生命周期和高频渲染

目标：消除当前最主要的无效工作。

### P1.1 项目面板生命周期

- 为 `ProjectWorkspacePanel`、`AgentPanel`、`GitPanel` 增加明确的 `active` 状态。
- Agent 不可见时暂停：
  - 三秒状态轮询。
  - ResizeObserver。
  - MutationObserver。
  - 自动滚动 RAF。
  - 非必要 Markdown 更新。
- 将 Agent 会话数据缓存移到按 `sessionId` 管理的 store，重新挂载时直接使用最后快照，避免空状态闪烁。
- Git 面板离开时取消仍在运行的 UI 轮询；后台 Git Job 状态由集中服务管理。

### P1.2 顶部文件 Tab 生命周期

- 已打开的 Tab 保留对应编辑器实例，切换时只隐藏、不自动卸载。
- 由用户根据设备性能决定同时打开多少 Tab；关闭 Tab 才结束对应组件生命周期。
- Monaco Model 与 Editor 实例均随已打开 Tab 保留，避免重挂载造成光标、选区、撤销栈或未保存内容丢失。
- Yarn、CodeWire、TIC 等编辑器仍保留可恢复快照和监听器清理能力，作为关闭、刷新和异常恢复的保护。

早期实现采用“活动 Tab + 最近 1 个 Tab”的两实例 LRU，以限制隐藏编辑器占用；实际使用中，
部分编辑器无法完整序列化内部交互状态，自动回收会让切回 Tab 的体验不可预测，因此已取消
程序侧硬性卸载。隐藏项目 Tab 的 Agent 子面板仍收到 `active=false`，暂停轮询、Observer 和
自动滚动等后台工作，但组件与会话界面状态继续保留。

### P1.3 Splitter 和窗口尺寸

- 拖拽期间只更新 CSS 变量或局部 DOM 宽度。
- 使用 `requestAnimationFrame` 合并宽度更新。
- `onResizeEnd` 才提交 React `drawerWidth` 和持久化配置。
- Monaco 在拖拽结束时执行一次 layout。
- 小于 490 px 时不再强行满足资源树 170 px 与内容区 320 px 的最小宽度：
  默认收起资源树，内容区保持 100% 宽；资源树打开时以 82% 宽覆盖层显示，并
  提供显式关闭按钮。达到 490 px 后恢复原 Splitter 行为和持久化宽度。

当前实现：桌面和横屏继续使用 Ant Splitter 的 `lazy` 拖拽，结束时才提交宽度；
窄屏使用固定覆盖层，不参与 Splitter 尺寸计算，避免竖屏内容区被挤压或裁切。

### P1.4 日志生命周期

- BottomLog 不可见时不订阅 React 日志更新。
- LogView 和 BottomLog 共享服务层缓冲，不各自复制完整字符串。
- 所有订阅、定时器和 Observer 在卸载或 inactive 时可验证地清理。

## 阶段 P2：Agent 流式输出和日志管线

目标：长会话和持续输出下保持输入、滚动和面板切换流畅。

### P2.1 Agent patch 合并

- WebSocket patch 进入按 `sessionId` 管理的队列。
- 每 50 ms 或每动画帧最多提交一次 React。
- 同一 message、step、checkpoint 在同一批次只保留最后版本。
- 数据结构改为 `Map<id, item> + orderedIds`，避免每个 patch 执行 `findIndex + sort`。

当前实现：patch 已按 50 ms 合并，相同实体在一次批次中仅更新一次；停止、问卷和会话结束保持立即提交。消息、步骤与 checkpoint 的组件长期状态已规范化为 `Map + orderedIds`：更新既有实体只复制 Map 并复用顺序，只有增删或排序字段变化时才重建顺序数组。

### P2.2 Agent 消息渲染

- 拆分 `AgentMessageRow`、`AgentStepRow` 并使用稳定 key 和 `memo`。
- 流式生成中的最后一条 assistant 消息先使用轻量文本渲染；完成后再解析 Markdown。
- 已完成消息仅在 `id`、`updatedAt` 或内容版本变化时更新。
- 历史轮次采用窗口化或分段挂载，保留“加载更早记录”语义。

当前实现：流式 assistant 消息使用轻量纯文本，结束后才切换 Markdown；assistant 消息和工具步骤已拆成独立 memo 行，稳定 Markdown 与历史行不随末条更新重建。历史轮次按最近轮次分段挂载，当前任务默认只挂载最新 80 个工具步骤，可按每批 80 个向前展开；React Profiler 证据仍在后续任务中。

### P2.3 自动滚动

- 取消对整棵内容树的 MutationObserver。
- 使用底部 sentinel、ResizeObserver 或提交后单次 layout effect 判断是否跟随底部。
- 每批 Agent patch 最多安排一次滚动。
- 用户离开底部后完全停止自动滚动工作。

当前实现：已移除全树 MutationObserver 和原先持续 400 ms 的 RAF 循环，layout/ResizeObserver 共用单个待执行 RAF；离开底部后不再调度。

### P2.4 日志缓冲

- 将无限字符串改为有界 chunk/ring buffer。
- 每条日志事件只传递增量 chunk。
- UI 以 50–100 ms 批量刷新。
- 超过行数或字节预算时删除最旧 chunk，并提供“日志已截断”提示。

当前实现：Service 使用最多 10,000 行或 4 MiB 的合并 chunk 缓冲，事件只广播增量；LogView 与 BottomLog 每 80 ms 读取一次快照。截断状态固定显示在视图右上角，服务端 `/log/save` 仍可恢复完整日志。

## 阶段 P3：跳转文件和大数据查询

目标：大工作区中输入不阻塞主线程。

### P3.1 文件索引

- 保留服务端 `Content.glob`，继续排除 `.git`、`node_modules`、构建和缓存目录。
- 文件列表首次获取后发送到专用 Web Worker。
- Worker 预计算小写文件名、路径、扩展名和必要的模糊搜索字段。
- 文件创建、删除、移动时增量更新索引，而不是整表重建。

当前实现：模块级 Worker 在弹窗关闭后继续复用索引；`UpdateFile` 事件以及 App 内的新建、上传、删除、重命名、拖拽移动会将单文件更新、目录前缀删除或路径移动直接发送到 Worker。浏览器不支持 Worker 时才动态加载 `match-sorter` 回退，不把该依赖留在主 App chunk。

### P3.2 搜索协议

- 主线程只向 Worker 发送 query 和递增 request ID。
- Worker 只返回 Top 100。
- 过期 request ID 的结果直接丢弃。
- 输入增加约 50 ms debounce；空查询不返回文件列表。
- Worker 不可用时保留当前主线程实现作为回退路径。

当前实现：输入采用 50 ms debounce，query 携带递增 request ID；发起新查询时立即结束旧 Promise，迟到结果按 ID 丢弃。Worker 只返回 Top 100，空查询保持弹层列表关闭，原有 MUI 上下键/Enter 选择语义不变。

### P3.3 后续可选服务端搜索

只有在移动设备内存仍不足时，才增加 `/assets/files/search`：

- 服务端维护按工作区失效的文件索引。
- 请求包含 query、limit 和 request ID。
- 默认只返回 Top 100。
- 避免每次输入重新执行完整 `Content.glob`。

## 阶段 P4：Git 后端按需化

目标：Git 工作区快速显示概要，不为未选中的 Commit 计算 Diff。

### P4.1 Commit 概要

- 保留当前最多 100 条的限制。
- Go `git log` 默认只返回：
  - hash
  - message
  - author
  - email
  - when
- 不在历史列表请求中执行 `parentTree.Diff(tree)`。

### P4.2 Commit 详情

- 增加按 commit hash 获取变更文件的命令或接口。
- 用户选中 Commit 后才请求 `files`。
- 按 `repoPath + commitHash` 缓存文件列表。
- Commit Diff 和单文件 Diff 使用独立请求并支持取消过期请求。

### P4.3 Summary 分步与渐进显示

- 先请求快速的 branch 并建立可交互面板，再依次补充 metadata-only log、remote 和 tag。
- 将大工作区可能耗时数十秒的 status 放在最后后台加载，不能让它阻塞分支和历史概要。
- 同一仓库的 go-git Job 当前由单 worker 串行执行，因此不盲目并发发起多个请求，避免后续请求直接被 `repo path is already used` 拒绝。
- Git Job 轮询由集中 manager 持有，组件卸载不遗留 timer，重新进入面板时从 store 恢复任务快照。
- `worktree.Status()` 本身没有 context 参数，因此在受控 goroutine 中运行；Git worker 等待结果或取消信号，取消后立即释放仓库任务槽并丢弃迟到结果，避免阻塞快速只读任务和用户命令。

## 阶段 P5：首屏包体和模块加载

目标：未使用的编辑器和面板不参与首屏下载、解析和执行。

### P5.1 模块边界

- `AgentPanel`、`GitPanel`、`DoraUpload` 使用动态 import。
- `ProjectWorkspacePanel` 只加载当前选中的面板模块。
- Dora 面板首次访问后继续保持挂载；加载期间只显示同色背景，避免空会话内容闪烁。
- LogView、LLMConfig、各类可视化编辑器继续保持或强化动态加载。

### P5.2 Monaco

- 移除 `index.html` 对 Monaco 主包的强制首屏 preload。
- 首次打开文本文件时加载 Monaco。
- TypeScript Worker 仅在 TS/TSX/JS 语言服务需要时启动。
- 非文本工作流不初始化 Monaco Model、自动类型和语言 Provider。

当前实现：编辑器组件、Monaco 核心和语言贡献已合并到首次文本编辑器的动态
边界，TypeScript 声明文件进一步延后到 TS/TSX 编辑器；当恢复状态里只有隐藏
文本 Tab 时，不创建 Editor。
同时移除了会把动态 Monaco 公共块重新并入入口依赖的 `manualChunks` 规则。
生产 HTML 已不再 preload Monaco JS/CSS；`?doraPerf=1` 验证 Dora 冷启动时
Monaco 与 TypeScript Worker 均未加载，首次进入 TSX 后才按需启动。

### P5.3 UI 依赖

- 统计 MUI 与 Ant Design 实际首屏使用模块。
- 新功能优先复用已确定的组件体系，避免继续扩大双组件库。
- 暂不进行高风险的一次性全量迁移。

### P5.4 远程重资源

- 保持设备端轻量入口。
- Monaco、Worker 和大编辑器资源使用版本化路径、长缓存和不可变文件名。
- Web IDE 资源与文档发布保持独立。

当前实现会在生产构建压缩完成后，根据最终文件内容为
`typescript.js`、Monaco editor Worker 和 TypeScript Worker 生成 12 位
SHA-256 文件名。构建脚本直接替换 HTML 中的 Monaco Worker 引用，并生成
`heavy-assets.json`，由 TypeScript 编译器和 JSX Worker 在运行时读取版本化
TypeScript URL；不再改写 Vite 已经生成内容哈希的 JS 分块。HTTP 服务仅对
`/assets/`、`/monacoeditorwork/` 和 `/typescript-*` 下已经带哈希的资源返回
`Cache-Control: public, max-age=31536000, immutable`；HTML 和未版本化资源
返回 `no-cache`，避免入口文件指向旧分块。

## 阶段 P6：资源树和长期细化

目标：在前述高收益任务完成后继续降低大工作区成本。

- 内置文档、程序库和字体目录改为 `/assets/children` 懒加载。
- 为资源树维护 `key -> node/parent` 索引，避免频繁全树查找。
- 更新单个节点时只复制祖先分支。
- 将去除 Ant Tree 原生 `title` 的全树 MutationObserver 替换为组件属性或更窄的处理。
- 继续保留虚拟滚动、受控展开、拖拽、右键菜单和自定义图标行为。

## 7. 预期代码边界

| 领域 | 主要文件 |
| --- | --- |
| App/Tab/Splitter 生命周期 | `Tools/dora-dora/src/App.tsx`, `Frame.tsx`, `FileTabBar.tsx` |
| 项目工作区 | `ProjectWorkspacePanel.tsx`, `AgentPanel.tsx`, `GitPanel.tsx`, `Upload.tsx` |
| Agent 数据与渲染 | `AgentPanel.tsx`, `AgentMessageList.tsx`, `AgentStepList.tsx`, `Service.ts` |
| 日志 | `Service.ts`, `BottomLog.tsx`, `LogView.tsx` |
| 跳转文件 | `FileFilter.tsx`, `App.tsx`, 新增 Worker，`WebServer.yue` |
| Git | `GitPanel.tsx`, `Service.ts`, `WebServer.yue`, `Source/3rdParty/Wa/Source/internal/gitjobs/gitrun.go` |
| Bundle/Worker | `vite.config.ts`, `monacoBase.ts`, `Editor.tsx` |
| 资源树 | `FileTree.tsx`, `App.tsx`, `WebServer.yue` |
| 性能基线 | `Tools/dora-dora/scripts/`、本目录验收记录 |

## 8. 验证策略

每个阶段至少执行：

1. `pnpm lint`
2. `pnpm build`
3. `git diff --check`
4. 浏览器关键路径检查
5. 对应的性能基线脚本

涉及不同层时补充：

- `WebServer.yue`：生成/同步 Lua 并验证真实 HTTP 请求。
- Go Git 实现：运行对应 Go 测试或最小仓库 smoke test。
- Agent：验证已有会话恢复、运行中 patch、停止、继续、问卷和子 Agent 切换。
- Monaco：验证文本、TS/TSX、Markdown、Yarn、Blockly 和视觉编辑器 Tab 往返。
- 移动端：验证 Splitter 触屏拖拽、面板切换和搜索输入。

性能结果必须记录测试环境、构建模式、样本仓库和基线日期，避免把开发模式数据当作生产承诺。

## 9. 风险与回退

| 风险 | 防护 |
| --- | --- |
| 卸载隐藏 Tab 后编辑状态丢失 | 先把内容和光标状态移入独立模型，再改变挂载策略 |
| Agent 面板重新出现空状态闪烁 | 以 session store 的最后快照同步首帧渲染 |
| patch 批处理延迟状态按钮 | 控制批次不超过 50 ms；停止和问卷等控制事件可立即提交 |
| 日志截断影响排障 | 明确显示截断提示，并保留保存完整日志的服务端能力 |
| Worker 搜索与文件树不同步 | UpdateFile/批量变更使用统一版本号；不一致时重建索引 |
| Git 概要不含 files 影响现有详情 | 先增加详情接口，再切换列表数据结构 |
| Monaco 延迟加载造成首次打开变慢 | 显示明确 skeleton，并在用户悬停/选择文本文件时预取 |
| 组件拆分引入视觉回归 | 每阶段保留截图和浏览器交互检查 |

## 10. 推荐执行顺序

1. P0 基线工具。
2. P1 Splitter、隐藏 Agent、BottomLog 生命周期。
3. P2 Agent patch 与日志缓冲。
4. P3 跳转文件 Worker。
5. P4 Git 元数据/详情拆分。
6. P5 Monaco 和面板动态加载。
7. P1 顶部 Tab 完整生命周期改造。
8. P6 资源树和组件库长期整理。

顶部 Tab 生命周期改造收益很高，但也最容易影响编辑状态恢复和重型编辑器，因此安排在基础指标、局部生命周期和动态加载稳定之后。

## 11. 完成定义

本轮性能优化只有同时满足以下条件才视为完成：

1. 所有 P0/P1 任务完成并通过功能回归。
2. 关键交互达到第 4 节预算，或记录无法达到的明确原因。
3. 连续 20 次面板/Tab 往返无监听器和 Heap 持续增长。
4. 长 Agent 会话、持续日志和大文件工作区均有固定样本。
5. PC 与至少一种手机触屏环境完成验收。
6. 性能基线脚本进入常规维护流程。
7. `PROGRESS.md` 包含实际测量结果、遗留问题和延期决策。
