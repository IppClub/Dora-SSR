# Dora SSR Web IDE 性能优化实施进度

关联方案：[README.md](./README.md)

最后更新：2026-07-26

## 状态定义

| 状态 | 含义 |
| --- | --- |
| 待开始 | 尚未进入实现 |
| 进行中 | 正在实现或验证 |
| 已完成 | 实现与对应验收均通过 |
| 阻塞 | 存在需要决策、环境或外部依赖的阻塞 |
| 延后 | 明确不属于当前实施批次 |

## 总体进度

| 阶段 | 状态 | 目标 | 当前说明 |
| --- | --- | --- | --- |
| P0 基线与回归工具 | 已完成 | 建立可重复性能样本和预算 | 服务端、搜索、bundle 与无头 Chrome 三轮基线均已自动化；`?doraPerf=1` 提供 DOM、listener、Heap、重资源、Agent 行级计数和搜索输入指标 |
| P1 生命周期与高频渲染 | 已完成 | 停止隐藏面板和 Splitter 的无效工作 | Agent、BottomLog、Splitter、活动 Tab、Monaco 和重型视图生命周期均完成；Yarn/CodeWire 使用可恢复快照，TIC 使用干净回收/脏状态固定策略 |
| P2 Agent 与日志管线 | 已完成 | 长会话和持续输出保持流畅 | patch 批处理、长期规范化、轻量流式渲染、行级 memo、历史窗口和有界日志已完成；生产浏览器 30 秒、1,201 patch 压力预算通过 |
| P3 跳转文件搜索 | 已完成 | 大工作区搜索不阻塞输入 | Worker、Top 100、request ID、50 ms debounce 和增量索引已实现；空查询、键盘、关闭及真实新建/重命名/删除均通过浏览器验收 |
| P4 Git 按需数据 | 已完成 | 列表只取元数据，选中后取 Diff | 元数据、changed-files、Summary 渐进加载和 Go status 取消释放均已验收 |
| P5 首屏与动态加载 | 已完成 | 延后 Monaco、Worker 和隐藏面板模块 | Agent/Git/Upload、Monaco 主运行时和 TypeScript Worker 均已按需加载 |
| P6 资源树长期细化 | 延后 | 进一步降低大树更新成本 | 当前已有虚拟滚动，不是首要瓶颈 |

## 开发任务

| ID | 工作项 | 状态 | 依赖 | 完成标准 | 验证方式 | 结果/备注 |
| --- | --- | --- | --- | --- | --- | --- |
| PERF-00 | 编写性能方案和进度表 | 已完成 | - | 记录基线、预算、阶段、风险和任务 | 文档检查 | 本目录 |
| PERF-01 | 建立浏览器性能采样脚本 | 已完成 | PERF-00 | 可采集首屏、交互、DOM、监听器和 Heap | 连续运行三次结果稳定 | `pnpm perf:browser` 零额外依赖启动独立 Chrome；三轮冷启动 141.9–150.6 ms、搜索 P95 0.7–0.8 ms 且均返回 Top 100、Tab P95 44.2–48.2 ms，DOM/listener 增量均 0，GC 后 Heap 增长 1.15–1.29 MiB，预算全通过 |
| PERF-02 | 建立固定测试工作区和场景 | 已完成 | PERF-01 | 覆盖单文件、多 Tab、Agent、Git、日志、大文件树 | 样本说明进入本文件 | 下方“固定验收样本”记录可重复路径、规模、入口和通过条件 |
| PERF-03 | 建立 bundle 体积报告 | 已完成 | PERF-01 | 输出关键 chunk 原始/gzip 大小并可与基线比较 | `pnpm build` 后生成报告 | `pnpm perf:bundle`，列出 JS/CSS 总量和 Top 20 |
| PERF-04 | PC 与手机触屏首轮基线 | 阻塞 | PERF-01, PERF-02 | 两类设备均记录交互与稳定性结果 | 浏览器和真机检查 | PC 三轮基线、Chrome 横竖屏及同页旋转触控仿真、iOS Simulator Safari 纵屏检查均已记录；`xctrace` 仅发现 Mac 与模拟器，`adb devices -l` 为空，需连接物理手机后继续 |
| LIFE-01 | AgentPanel 增加 active 生命周期 | 已完成 | PERF-01 | 隐藏时无轮询、Observer、自动滚动和内容刷新 | 面板往返及监听器采样 | 隐藏时停止 patch 订阅、轮询、滚动监听、ResizeObserver 和 MutationObserver；激活后保留快照并刷新 |
| LIFE-02 | Agent session store 保存最后快照 | 已完成 | LIFE-01 | Agent 重挂载首帧直接显示已有会话，无空状态闪烁 | 文件/Git/Dora 往返检查 | 每个 session 保存最后完整快照，组件初始 state 同步恢复；24 个 session LRU 上限避免长期占用 |
| LIFE-03 | Git Job 轮询集中管理并清理 timer | 已完成 | PERF-01 | 切换项目或卸载面板不遗留组件 timer，后台状态仍可恢复 | store 自动测试、面板往返 | 每仓库一个模块级 timeout 轮询；隐藏时不回调已卸载组件，返回后可读取终态且只认领一次 |
| LIFE-04 | Splitter 使用原生 lazy 预览拖拽 | 已完成 | PERF-01 | 拖动期间不连续刷新 App 顶层状态 | 源码检查、浏览器拖拽 | Ant Splitter 拖动时仅更新预览手柄，松手后才提交尺寸 |
| LIFE-05 | Splitter 结束时单次 layout 和持久化 | 已完成 | LIFE-04 | 宽度准确保存，Monaco/滚动条不抖动 | 重启恢复与拖拽检查 | 实测 291 → 360 px，页面重载后恢复为 360 px |
| LIFE-06 | BottomLog 隐藏时取消 React 更新 | 已完成 | PERF-01 | 隐藏状态持续日志不触发 BottomLog render | 代码检查、面板开关检查 | 隐藏时解除日志和 DOM 事件订阅，重新打开时从 Service 快照同步 |
| LIFE-07 | 抽离活动 Tab 渲染容器 | 已完成 | LIFE-01, PERF-02 | App 不再为所有 Tab 构造完整视图 | 多 Tab DOM、listener、Heap 采样 | App 只构造活动 Tab 与最近 1 个 Tab；3 个混合 Tab 连续切换时 `main` 始终为 2，隐藏项目 Tab 的 Agent 明确收到 `active=false` |
| LIFE-08 | Monaco Model 与 Editor 实例生命周期拆分 | 已完成 | LIFE-07 | 未激活 Tab 保留内容但释放重型 Editor | 光标/撤销/诊断恢复检查 | `keepCurrentModel` 保留 Model，卸载保存 viewState 并清除 Editor 引用，重挂载不再无条件 `setValue`；文本/项目往返 Editor 1 → 0 → 1，未保存内容、光标位置和撤销栈均恢复，控制台无错误 |
| LIFE-09 | 重型编辑器 LRU 策略 | 已完成 | LIFE-07 | 最近视图可快速返回，超预算实例被释放 | 多类型 Tab 往返 | Yarn 使用带 revision 的异步文本快照，CodeWire 同步保存 visual script；两者未保存状态均通过 iframe 1→0→1 恢复。干净 TIC 为 1→0→1；发生指针输入后保持 iframe 1、`main` 3，成功保存且无新输入后才解除固定 |
| LIFE-10 | 窄屏资源树改为覆盖层 | 已完成 | LIFE-04 | 纵屏内容区不再被 Splitter 最小宽度挤压或裁切 | 双视口自动化、iOS Safari 检查 | `<490 px` 默认隐藏资源树，内容区保持 100% 宽；资源树以 82% 宽覆盖层开合并有显式关闭按钮；达到断点后恢复原 Splitter |
| AGENT-01 | Agent patch 进入批处理队列 | 已完成 | PERF-01 | 同一帧/50 ms 内 patch 合并提交 | 流式输出采样 | 默认 50 ms；停止、问卷、会话结束立即提交；5,000 patch 合并测试由 5,000 次提交模型降为 1 次 |
| AGENT-02 | 消息、步骤和 checkpoint 规范化存储 | 已完成 | AGENT-01 | 不再每个 patch 执行全数组查找和排序 | 单元测试、Profiler | 长期状态使用 `Map + orderedIds`；既有实体更新复用顺序与稳定实体引用，只有增删或排序字段变化才重建顺序；5,000 次同消息 patch 批量归并约 0.21 ms |
| AGENT-03 | AgentMessageRow/StepRow memo 化 | 已完成 | AGENT-02 | 更新最后消息不会重渲染稳定历史行 | 行级 render 计数、浏览器往返 | assistant 消息与工具步骤均为独立 memo 行；全量刷新复用未变化实体，外部打开文件/回滚动作使用稳定回调；生产构建往返 20 次后 11 条 assistant 行、32 条步骤行均 0 次额外 render |
| AGENT-04 | 流式消息轻量渲染，完成后 Markdown | 已完成 | AGENT-03 | 流式阶段不反复解析完整 Markdown | 长 Markdown 流式样本 | 运行中的最后一条 assistant 消息使用 pre-wrap 文本，任务结束后才挂载 Markdown |
| AGENT-05 | 自动滚动移除全树 MutationObserver | 已完成 | AGENT-01 | 每批 patch 最多一次滚动，离开底部后无滚动工作 | 自动/手动滚动检查 | 移除 subtree MutationObserver、嵌套 RAF 和 400 ms 循环；layout/ResizeObserver 合用单个 RAF |
| AGENT-06 | Agent 历史窗口化或分段挂载 | 已完成 | AGENT-03 | 长会话 DOM 数量保持有界 | 大会话样本、窗口单元测试 | 历史轮次保留最近 10 轮并可逐段展开；当前任务默认挂载最新 80 个工具步骤、每次向前展开最多 80 个；200 步契约测试确认初始仅返回末尾 80 步 |
| LOG-01 | 日志改为 chunk/ring buffer | 已完成 | LIFE-06 | 默认最多 10,000 行或 4 MB | 日志单元测试 | 合并 chunk 缓冲；30,000 行测试稳定为 9,840 行、16 chunks、约 500 KiB |
| LOG-02 | 日志事件只发送增量 | 已完成 | LOG-01 | 不再为每条日志复制完整字符串 | Heap/CPU 采样 | Service 日志事件签名由 `(chunk, allText)` 改为仅 `chunk`，完整文本按 UI 批次惰性 join |
| LOG-03 | 日志 UI 50–100 ms 批量刷新 | 已完成 | LOG-02 | 持续输出时输入和滚动可响应 | 30 秒压力测试 | LogView/BottomLog 共用 80 ms hook；30 秒、400 行/秒、12,000 行实测可输入且最新行可见 |
| LOG-04 | 日志截断提示和保存完整日志路径 | 已完成 | LOG-01 | 用户知道内存视图已截断，仍可保存服务端日志 | 功能检查 | 右上角固定“较早日志已截断”提示；`/log/save` 完整日志重载路径保留 |
| SEARCH-01 | `/assets/files` 使用 `Content.glob` 和排除规则 | 已完成 | - | 不遍历资源树构造跳转文件列表 | 41,752 文件样本 | 当前未提交工作区变更 |
| SEARCH-02 | 空查询不显示文件列表 | 已完成 | SEARCH-01 | 打开弹窗不渲染全量条目 | 浏览器交互检查 | 当前未提交工作区变更 |
| SEARCH-03 | 文件列表异步分块映射和缓存 | 已完成 | SEARCH-01 | 弹窗立即出现，映射过程不长时间独占主线程 | 大工作区浏览器检查 | 当前未提交工作区变更 |
| SEARCH-04 | 跳转文件 Web Worker 索引 | 已完成 | PERF-01, SEARCH-03 | 模糊匹配不在主线程执行 | 输入 P95 小于 16 ms | 模块级 Worker 和 Top 100 已完成；41,752 文件核心查询 13.67–32.57 ms 在 Worker 内执行；三轮页内输入 commit P95 为 1.10/1.10/1.00 ms，结果顺序和键盘选择通过 |
| SEARCH-05 | Worker request ID、取消和 debounce | 已完成 | SEARCH-04 | 过期查询不覆盖新结果 | 快速连续输入测试 | 50 ms debounce、递增 ID、旧 Promise 结束和迟到结果丢弃已实现；浏览器连续输入未出现旧结果覆盖 |
| SEARCH-06 | 文件变化增量更新 Worker 索引 | 已完成 | SEARCH-04 | 创建、删除、移动后无需整表重建 | UpdateFile/批量操作测试 | Worker 支持单文件更新、目录前缀删除和路径移动；App 新建、上传、删除、重命名、拖拽移动均增量同步；浏览器真实新建/重命名/删除通过 |
| SEARCH-07 | 评估服务端 Top N 搜索 | 延后 | SEARCH-04, PERF-04 | 仅当移动端 Worker 内存不达标时启用 | 真机内存样本 | - |
| GIT-01 | Git log 增加仅元数据模式 | 已完成 | PERF-01 | 100 条概要不执行每个 Commit 的 tree Diff | Go 测试、接口计时 | 新增 `--metadata-only`；真实仓库接口 1.30–1.80 s → 52–69 ms |
| GIT-02 | 增加按 Commit 获取 changed files 接口 | 已完成 | GIT-01 | 选中 Commit 后才加载文件列表 | API 与 GitPanel 检查 | 新增 `--changed-files` 与 `/git/commit-files`；14 文件样本 51–59 ms |
| GIT-03 | GitPanel 按需加载并缓存 Commit files | 已完成 | GIT-02 | 列表立即可见，详情切换正确 | 3,073 Commit 接口测试、小仓库 UI 回归 | 仅进入“变更”Tab 后加载，按完整 hash 缓存；DiffEditor 复用稳定 Monaco Model，连续切换提交无新增控制台错误 |
| GIT-04 | Git summary 分步并渐进显示 | 已完成 | GIT-01 | 快速仓库结构先显示，慢速 status 不阻塞概要 | 大仓库分步接口计时、浏览器往返 | 分支先显示，历史/远程/标签依次补充，status 最后后台加载；前四步单项 48–72 ms |
| GIT-05 | 保留并验证 100 条历史上限 | 已完成 | GIT-01 | 默认和外部请求均不无界返回历史 | `limit=1000` 接口测试 | 新接口实测仍返回 100，且全部不含 `files` |
| GIT-06 | Go status 支持取消并释放 Git worker | 已完成 | GIT-04 | 大仓库 status 超时或取消后不继续占用全局 Git worker，分支/历史和用户命令不被阻塞 | 单元测试、真实 status 取消后续任务 | `worktree.Status()` 包装为结果/context 二选一；running 时取消后 100 ms 内同仓库 branch 可入队并完成 |
| BUNDLE-01 | Agent/Git/Upload 改为动态 import | 已完成 | PERF-03 | 未进入对应面板前不加载模块 | 构建图、网络请求 | App 85.20 → 47.48 KiB gzip；独立 Dora/Git/Upload 分块 17.68/15.02/5.01 KiB gzip；浏览器逐一首次进入与返回通过 |
| BUNDLE-02 | 移除 Monaco 首屏强制 preload | 已完成 | PERF-03 | 非编辑器首屏不下载 Monaco 主包 | 冷启动网络检查 | 编辑器组件、Monaco 核心和语言贡献合并为按需运行时，声明文件延后到 TS/TSX；HTML 不再 preload Monaco/CSS；恢复隐藏文本 Tab 且当前为 Dora 时 Monaco=false、Editor=0 |
| BUNDLE-03 | TypeScript Worker 按语言启动 | 已完成 | BUNDLE-02 | 未打开 TS/TSX/JS 前不加载 TS Worker | 网络与 Worker 检查 | Dora 冷启动 TS Worker=false；打开 `RandomTest/testLua.lua` 后 Monaco=true、TS Worker=false；首次切换 `Vomfy/init.tsx` 后 TS Worker=true，内容正常且控制台无错误 |
| BUNDLE-04 | 统计并收敛双 UI 组件库增量 | 已完成 | PERF-03 | 新代码不继续无边界扩大首屏 MUI/Ant 依赖 | bundle diff | MUI 出现在 32 个源码模块、Ant 出现在 5 个；首屏分别约 109/310 KiB gzip；当前壳层与资源树/Splitter 均在使用，暂不做高风险迁移 |
| BUNDLE-05 | 远程重资源版本化和长缓存核查 | 已完成 | BUNDLE-02 | Monaco/Worker 使用不可变版本路径 | 部署资源头检查 | TypeScript、editor Worker、TS Worker 使用最终内容 12 位 SHA-256 文件名；HTML 直引 Worker，运行时通过 no-cache manifest 解析 TypeScript；哈希资源实测一年 immutable，HTML/manifest no-cache |
| TREE-01 | 内置资源目录服务端懒加载 | 延后 | PERF-01 | `/assets` 不递归返回全部内置子树 | 首屏与展开测试 | 当前收益低于 P1-P5 |
| TREE-02 | 资源树 key/parent 索引 | 延后 | TREE-01 | 更新单节点不全树查找 | 大树更新基准 | - |
| TREE-03 | 替换 title MutationObserver | 延后 | TREE-01 | 无全树属性观察且视觉行为不变 | 浏览器交互检查 | - |
| QA-01 | 20 次 Tab/面板往返稳定性 | 已完成 | LIFE-01, LIFE-07 | 监听器不增长，Heap 增长小于 10 MB | `?doraPerf=1` 浏览器采样 | 5 次预热后文件/Dora 往返 20 次并等待 15 秒：DOM 4,063 → 4,063，listener 652 → 634，Heap 108.7 → 71.7 MiB；11 条 assistant 行、32 条步骤行均无额外 render |
| QA-02 | 30 秒 Agent 流式压力测试 | 已完成 | AGENT-01-AGENT-05 | 输入响应、滚动和渲染预算达标 | 自动与浏览器采样 | `pnpm perf:agent:browser`：30.001 秒、1,201 patch、22,819 字符；frame P95 9.0 ms、max 10.3 ms、0 Long Task；probe 401 次提交（预算 ≤605），稳定消息/步骤 0 次额外 render，自动滚动距底 0，listener 增量 0 |
| QA-03 | 30 秒日志压力测试 | 已完成 | LOG-01-LOG-04 | 内存有界，UI 无明显卡顿 | 自动与浏览器采样 | `pnpm perf:log` 29.735 秒输出 12,000 行；压力期间输入可用、末行/截断提示可见、控制台无错误 |
| QA-04 | 4 万文件搜索验收 | 已完成 | SEARCH-04-SEARCH-06 | 输入 P95 小于 16 ms，结果顺序正确 | 自动和人工检查 | 41,752 文件核心/增量测试、空查询、快速输入、上下键/回车、首次 Esc、真实新建/重命名/删除均通过；三轮各 50 次页内输入 commit P95 为 1.10/1.10/1.00 ms |
| QA-05 | 3,000+ Commit 仓库验收 | 已完成 | GIT-01-GIT-04 | 概要快速出现，文件详情按需正确 | 接口计时和 UI 检查 | 3,073 Commit 仓库 history 52–69 ms；概要前四步 48–72 ms；按需 changed-files 51–59 ms，浏览器连续切换提交正确 |
| QA-06 | 首屏资源预算验收 | 已完成 | BUNDLE-01-BUNDLE-05 | 不含 Monaco gzip JS 小于 700 KB | 构建报告 | 当前 hydrated shell 递归静态依赖 19 个 JS、596.0 KiB gzip；HTML 无 Monaco 主包/CSS preload；`pnpm perf:bundle:check` 预算门禁通过 |
| QA-07 | 手机触屏完整验收 | 阻塞 | LIFE-04, SEARCH-04 | Splitter、搜索、Agent、Git 可用且无明显卡顿 | 自动触控仿真与真机检查 | Chrome 390×844 纵屏覆盖层、844×390 横屏拖拽/搜索及同页旋转均通过，0 控制台错误；iOS Simulator Safari 纵屏下既有 Agent 会话、文件、Git 和资源树开合通过；当前无物理 iOS/Android 设备，无法验证地址栏、系统手势冲突和真实触感 |

## 固定验收样本

| 场景 | 固定样本/入口 | 规模与操作 | 核心通过条件 |
| --- | --- | --- | --- |
| 无编辑器首屏 | 关闭全部 Tab 后重载 `/index.html` | 资源树可见、0 个编辑器 Tab | 无 Monaco DOM；页面可交互且无控制台错误 |
| 单文件/多 Tab | `/Users/Jin/Workspace/Dora/Vomfy/init.tsx`，另开项目、图片与文本 Tab | 单文件编辑；5 个混合 Tab 往返 | 光标/内容恢复，隐藏视图不持续工作 |
| Agent 长会话 | session `1`，`/Users/Jin/Workspace/Dora/AgentArcade/20260722-05-Abyssal-Tether` | 171 条历史消息；文件/Dora 往返、关闭后重开 | 首帧不显示空状态，历史窗口有界，无错误 |
| Git 大仓库 | `/Users/Jin/Workspace/Dora-SSR` | 3,073 Commit；history、概要、连续切换 Commit | 列表仅元数据，详情按需，接口和 UI 计时符合预算 |
| 持续日志 | `pnpm perf:log` | 30 秒、400 行/秒、共 12,000 行 | UI 可输入，最新行可见，内存视图有界并提示截断 |
| 大文件搜索 | `/Users/Jin/Workspace/Dora` `/assets/files` | 41,752 文件；空查询、快速输入、键盘选择、增量变化 | 主线程不执行全量匹配，Top 100、顺序和关闭行为正确 |

## 当前基线记录

| 日期 | 环境 | 场景 | 结果 | 备注 |
| --- | --- | --- | --- | --- |
| 2026-07-26 | macOS，本地 Vite 开发模式 | 恢复两个 Tab 和项目工作区 | 约 2,642 elements、5,636 nodes、2,978 listeners、180 MB heap | 开发模式方向性数据 |
| 2026-07-26 | macOS，本地 Vite 开发模式 | 文件/Git/Dora 面板往返 | 监听器峰值约 4,496，heap 约 205 MB | 未强制 GC |
| 2026-07-26 | 本地 WebServer | `/assets` | 118 KB，gzip 约 7.4 KB，约 52 ms | 约 891 个节点 |
| 2026-07-26 | `/Users/Jin/Workspace/Dora` | `/assets/files` | 41,752 文件；解压约 3.65 MB，gzip 约 174 KB，约 0.48 秒 | 已使用 `Content.glob` |
| 2026-07-26 | Node，同一文件列表 | `matchSorter` 短查询 | 约 16–56 ms/次 | 主线程风险 |
| 2026-07-26 | `/Users/Jin/Workspace/Dora-SSR` | `/git/history`，传入 limit 1000 | 实际返回 100 条，约 1.8 秒 | 仓库共 3,073 Commit |
| 2026-07-26 | 自动基线脚本，本地 WebServer | `/assets`、`/assets/files`、搜索、Git history | 891 节点/105 ms；41,752 文件/558 ms；搜索中位 40–53 ms；Git 约 1.30 s | `pnpm perf:baseline` 单次样本 |
| 2026-07-26 | 生产构建 | JS/CSS bundle | 68 文件，合计约 31.88 MiB raw / 7.95 MiB gzip | 含独立 Worker、TypeScript 和嵌套工具资源，详见 `pnpm perf:bundle` |
| 2026-07-26 | `/Users/Jin/Workspace/Dora-SSR` | 优化后 `/git/history`，请求 limit 1000 | 仍返回 100 条；52–69 ms；22.7 KB；不含 changed files | 优化前约 1.30–1.80 s / 229 KB |
| 2026-07-26 | `/Users/Jin/Workspace/Dora-SSR` | `/git/commit-files` | HEAD 的 14 个文件，51–59 ms，约 2 KB | 仅在 Commit“变更”Tab 按需请求 |
| 2026-07-26 | `/Users/Jin/Workspace/Dora-SSR` | 渐进 Git Summary 子步骤 | branches 48 ms；history 52 ms；remotes 72 ms；tags 67 ms | 约 240 ms 内已有仓库结构、100 条历史、远程与标签 |
| 2026-07-26 | `/Users/Jin/Workspace/Dora-SSR` | `/git/status-files` | 35.87 s，20 个变化文件 | 已放到渐进加载末尾并恢复 120 s 后台期限；取消时可立即释放 Git worker |
| 2026-07-26 | Node 合并基准 | 同一 assistant message 的 5,000 个 patch，200 条已有消息 | 旧逐 patch 查找/排序 20.91 ms；单批 Map 合并 0.38 ms；提交模型 5,000 → 1 | 单次本机方向性数据，实际 UI 按 50 ms 分批 |
| 2026-07-26 | 本地 Web IDE 生产构建 | 30 秒日志持续输出 | 400 行/秒、共 12,000 行、实际 29.735 秒 | 输入框保持响应，最新 `perf-log-12000` 与截断提示可见，控制台无错误 |
| 2026-07-26 | Node 固定样本 | 41,752 文件 Worker 搜索核心 | `sky` 32.57 ms；其余查询 13.67–17.30 ms；均最多 100 条 | 计算位于 Worker；主线程输入另由生产浏览器页内指标采样 |
| 2026-07-26 | 本地 Web IDE 生产构建 | 跳转文件输入到 React layout commit，三轮各 50 次 | P50 0.90/0.80/0.90 ms；P95 1.10/1.10/1.00 ms；max 1.20/1.10/1.40 ms | 每轮独立页面；结果不含自动化通信和 50 ms Worker debounce，三轮均低于 16 ms 预算 |
| 2026-07-26 | 生产构建 | 搜索诊断加入后的 hydrated IDE shell JS | 19 文件，595.4 KiB gzip | 相比诊断加入前 594.9 KiB 增加约 0.5 KiB，700 KiB 门禁通过 |
| 2026-07-26 | 生产构建 | Yarn/CodeWire 未保存快照加入后的 hydrated IDE shell JS | 19 文件，595.5 KiB gzip | 相比上一轮增加约 0.1 KiB，700 KiB 门禁通过 |
| 2026-07-26 | 生产构建 | 窄屏资源树覆盖层与双视口验收加入后的 hydrated IDE shell JS | 19 文件，596.0 KiB gzip | 比上一轮增加约 0.3 KiB；仍低于 700 KiB 门禁 |
| 2026-07-26 | macOS Chrome 无头模式，生产 Web IDE | `pnpm perf:browser` 三轮独立页面 | 冷启动 150.6/143.1/141.9 ms；搜索 P95 0.8/0.8/0.7 ms；Tab P95 45.6/44.2/48.2 ms | 每轮 50 次受信搜索输入、Top 100 结果和 21 次三 Tab 往返；`main` 峰值均 2；DOM/listener 增量均 0；强制可比 GC 后 Heap +1.29/+1.20/+1.15 MiB |
| 2026-07-26 | macOS Chrome 无头模式，生产 Web IDE | `pnpm perf:agent:browser` 30 秒 Agent patch 链路 | 1,201 patch、22,819 字符；frame P50/P95/max 8.3/9.0/10.3 ms；0 Long Task；probe render 401/605 | 使用已有 session 1 历史背景，经实际事件入口、50 ms 合并、React 行和自动滚动；稳定消息/步骤额外 render 均 0，距底 0，listener 增量 0，GC 后 Heap -0.11 MiB |
| 2026-07-26 | Chrome 移动横竖屏触控仿真 | `pnpm perf:mobile:browser` | 390×844 纵屏：初始资源树 0 px、内容区 390 px，覆盖层 319 px，开合成功；844×390 横屏：Splitter 触摸移动 40 px，搜索 P95 0.8 ms，41,294 候选中渲染 Top 100；同页旋转后资源树 370→0 px、内容区 390 px | 首次 Esc、资源树项目打开和方向切换自动收起成功，两个视口控制台均 0 错误；物理手机仍待补 |
| 2026-07-26 | iPhone 17 / iOS 26.5 Simulator Safari | 390×844 纵屏生产 Web IDE | 既有 Agent 会话首帧可见；资源树默认隐藏、82% 覆盖层可开关；Dora、文件、Git 三面板可切换 | 模拟器验证 WebKit 与纵屏布局，但不等同物理手机的地址栏、触感和系统手势验收 |
| 2026-07-26 | 生产构建 | 跳转文件 Worker 拆分 | App 约 302.76 KB raw / 85.20 KB gzip；Worker 8.42 KB | Worker 前 App 约 307.46 KB raw / 87.76 KB gzip |
| 2026-07-26 | 生产构建 | hydrated IDE shell JS（排除 Monaco 主包/语言 Worker） | 18 文件，约 1.91 MiB raw / 597.4 KiB gzip | 从入口、modulepreload 与 App 静态依赖递归计算；700 KiB 预算通过 |
| 2026-07-26 | 生产构建 | Monaco 壳层拆分后 hydrated IDE shell JS | 19 文件，594.9 KiB gzip | `index.html` 不再 preload Monaco 主包或 CSS；Monaco 按需块约 916.1 KiB gzip |
| 2026-07-26 | 本地 Web IDE 生产构建 | 3 个混合 Tab 的两实例 LRU，预热后再切换 21 次 | `main` 2 → 2；DOM 1,976 → 1,976；listener 441 → 441；Heap +1.97 MiB | 等待 15 秒后采样，未强制 GC；Monaco 仅在文本 Tab 活动时为 1 |

## 验收记录

| 日期 | 任务 | 结果 | 证据 |
| --- | --- | --- | --- |
| 2026-07-26 | PERF-00 方案首稿 | 通过 | 建立设计、预算、任务、风险和进度表 |
| 2026-07-26 | Git 历史限制核查 | 通过 | Go 默认 20、支持 `-n`；WebServer 和前端最多 100；热点为每 Commit 预计算 Diff |
| 2026-07-26 | 跳转文件性能核查 | 通过 | 41,752 文件、服务端 glob 和主线程 matchSorter 基准已记录 |
| 2026-07-26 | PERF-03 bundle 报告 | 通过 | `pnpm build` 后 `pnpm perf:bundle` 输出总量和 Top 20 原始/gzip 大小 |
| 2026-07-26 | LIFE-01/04/05/06 第一批生命周期 | 通过 | 生产构建通过；Splitter 291 → 360 px 且重载恢复；文件/Git/Dora 往返 10 轮 DOM 维持 3,009、无控制台错误 |
| 2026-07-26 | GIT-01～03、GIT-05 | 通过 | Go 单元测试覆盖 metadata/changed-files；真实仓库 100 条接口 52–69 ms；changed-files 51–59 ms；浏览器连续切换 3 个 Commit 并返回缓存条目，文件树与 Diff 正确且无新增控制台错误；`pnpm build` 通过 |
| 2026-07-26 | LIFE-03/GIT-04 | 通过 | `pnpm test:git-job-store` 验证隐藏期间继续单路轮询、终态恢复且只认领一次；浏览器文件/Git 往返 5 轮无新增控制台错误；大型仓库前四个概要步骤单项 48–72 ms，status 35.87 s 后补 |
| 2026-07-26 | GIT-06 | 通过 | Go context 取消单元测试通过；真实 35 秒级 status 在 running 时取消，100 ms 后同仓库 branch 成功入队并完成，status 终态为 canceled |
| 2026-07-26 | AGENT-01/04/05 第一批 | 通过 | 5,000 patch 合并测试 20.91 ms → 0.38 ms；lint/build 通过；文件/Dora 往返 10 轮无控制台错误；源码确认无 subtree MutationObserver |
| 2026-07-26 | LOG-01～04 / QA-03 | 通过 | 有界缓冲测试 30,000 行后保留 9,840 行/16 chunks；`pnpm perf:log` 30 秒输出 12,000 行，浏览器输入、末行、固定截断提示均正常且无控制台错误 |
| 2026-07-26 | SEARCH-04～06 核心实现 | 通过 | `pnpm test:file-search-index` 覆盖 41,752 文件、Top 100、新增、目录删除与嵌套目录移动；lint/build 通过；浏览器快速输入、上下键、首次关闭和真实新建/重命名/删除均通过 | QA-04 仍单独跟踪严格浏览器内帧 P95，不阻塞增量索引实现结项 |
| 2026-07-26 | LIFE-07 / LIFE-09 第二批 | 通过 / 部分通过 | 3 个混合 Tab 连续切换时最多 2 个 `main`；稳定态再切换 21 次后 DOM 和 listener 增量均为 0，Heap 增加 1.97 MiB；未修改 Yarn/CodeWire 均表现为 iframe 1 → 0 → 1 且控制台无错误 | LIFE-07 完成；LIFE-09 保留 TIC 与未保存可视化状态的安全例外 |
| 2026-07-26 | TIC iframe 监听生命周期 | 通过 | 关闭 TIC Tab 后 iframe 1 → 0，诊断中的顶层 `message` listener 1 → 0；重复 load 前会先移除旧 message/keydown 回调 | TIC 内部编辑状态尚未有可恢复快照，因此仍不参与非关闭场景的 LRU 淘汰 |
| 2026-07-26 | QA-04 严格输入延迟 | 通过 | `?doraPerf=1` 记录输入事件到对应 React layout commit，最多保留 200 个样本；三轮各 50 次输入 P95 为 1.10/1.10/1.00 ms，三轮均无控制台错误 | 旧 P95 19 ms 包含浏览器自动化通信，不再用于判断主线程 16 ms 预算 |
| 2026-07-26 | LIFE-09 未保存可视化状态 | 通过 / 部分通过 | CodeWire 新建未保存变量、Yarn 修改未保存节点正文后，各自越过两实例预算；iframe 均 1→0→1，返回后探针内容仍在、控制台无错误，磁盘原文件无探针 | Yarn/CodeWire 通过；TIC 因现有桥接只能触发实际写盘，继续作为安全例外 |
| 2026-07-26 | LIFE-09 TIC dirty-pin | 通过 | 未操作 TIC 越过两实例预算时 iframe 1→0，返回后 1；点击 canvas 后再越过预算时 iframe 保持 1、`main` 为 3，且无新增应用控制台错误 | 保存成功仅在 dirty revision 未变化时解除固定，避免保存期间的新输入被错误标记为干净 |
| 2026-07-26 | PERF-01 浏览器自动基线 | 通过 | `pnpm perf:browser` 连续三轮均通过：搜索 P95 0.7–0.8 ms 且每轮返回 Top 100，Tab P95 44.2–48.2 ms，`main` 峰值 2，DOM/listener 无增长，GC 后 Heap 增长 1.15–1.29 MiB |
| 2026-07-26 | QA-02 Agent 30 秒压力 | 通过 | `pnpm perf:agent:browser` 在生产构建通过实际 Agent patch 事件链路注入 1,201 patch；frame P95 9.0 ms、0 Long Task、稳定历史 0 render、listener 0 增长、自动滚动保持底部 |
| 2026-07-26 | PERF-04 / QA-07 自动触控与模拟器基线 | 通过 / 进行中 | Chrome 390×844 纵屏覆盖层、844×390 横屏 Splitter/搜索和同页横转纵自动收起均通过；iOS Simulator Safari 纵屏下既有 Agent 会话、资源树开合、文件和 Git 面板通过；自动化 0 控制台错误，物理手机验收未完成 |
| 2026-07-26 | 跳转文件冷索引竞态 | 通过 | 自动化在弹窗打开后立即输入，随后 41,294 项完整索引替换空索引；旧 ready waiter 会先被释放，查询按新 generation 重试并返回 Top 100；新增 mock Worker 回归覆盖“重建前查询不永久 pending” |

## 待决策

| 项目 | 建议 | 决策状态 |
| --- | --- | --- |
| Agent 数据 store 选型 | 先使用轻量模块级 external store 和 `useSyncExternalStore`，不急于引入大型状态库 | 待确认 |
| 非激活 Monaco Editor 保留数量 | Monaco Editor 只保留活动实例；顶部 Tab 内容容器保留活动项和最近 1 项 | 已按建议实施 |
| 日志内存预算 | 默认 10,000 行或 4 MB，任一达到即截断最旧内容 | 已按建议实施 |
| Agent patch 批次 | 默认 50 ms；停止、问卷和错误等控制事件立即提交 | 已按建议实施 |
| 文件搜索方案 | 优先 Worker，本地完整索引；移动端不达标时再做服务端 Top N | 建议采用 |
| Git 历史数量 | 保留 100，不做前端虚拟化；只优化元数据和按需详情 | 已确认 |
| 组件库策略 | 暂不全量迁移；动态拆包后再根据 bundle 数据决定 | 建议采用 |

## 进度日志

| 日期 | 任务 | 状态变更 | 实际工作 | 验证 | 遗留问题 |
| --- | --- | --- | --- | --- | --- |
| 2026-07-26 | PERF-00 | 待开始 → 已完成 | 新增性能优化方案和实施进度文档，记录页面、bundle、搜索和 Git 基线 | 文档人工检查 | 自动采样脚本尚未建立 |
| 2026-07-26 | SEARCH-01～03 | 已存在变更，登记为已完成 | 当前工作区已使用 `Content.glob`、空查询不列文件、异步分块映射和缓存 | 41,752 文件接口与浏览器检查 | 仍需 Worker 消除 16–56 ms 主线程匹配 |
| 2026-07-26 | Git 历史核查 | 分析完成 | 确认 WebServer 和前端上限均为 100；Go 默认 20 可由 `-n` 覆盖；100 条列表会提前计算 100 次 Commit changed files | `limit=1000` 实际只返回 100；当前仓库共 3,073 Commit | GIT-01～04 尚未实现 |
| 2026-07-26 | PERF-01/PERF-03 | 待开始 → 进行中/已完成 | 新增 `performance-baseline.mjs` 和 `report-performance.mjs`，并加入 pnpm 命令 | 41,752 文件样本和生产 bundle 报告均可重复运行 | 浏览器监听器、Heap 和真机采样尚未自动化 |
| 2026-07-26 | LIFE-01 | 待开始 → 已完成 | `AgentPanel` 增加 active 生命周期；隐藏时暂停数据和 DOM 高频工作，激活时用旧快照首帧并刷新 | 文件/Git/Dora 往返 10 轮，DOM 3,009 → 3,009，无控制台错误 | 仍需纳入 20 轮监听器/Heap 自动验收 |
| 2026-07-26 | LIFE-04～05 | 待开始 → 已完成 | 使用 Ant Splitter 原生 `lazy` 拖拽，只在结束时更新 App 状态和持久化 | 浏览器拖拽 291 → 360 px，重载后仍为 360 px | 手机触屏留到 QA-07 |
| 2026-07-26 | LIFE-06 | 待开始 → 已完成 | BottomLog 隐藏时解除 Service 日志与 DOM 事件订阅，打开时同步最新快照 | lint、生产构建和面板开关检查通过 | 环形日志缓冲与压力测试属于 LOG-01～03 |
| 2026-07-26 | GIT-01～03、GIT-05 | 待开始 → 已完成 | Go log 增加 metadata-only/changed-files 数据模式；WebServer 增加按 Commit 文件接口；GitPanel 仅在变更页加载并按 hash 缓存；本地变更与 Commit Diff 各复用一对稳定 Monaco Model | Go 测试通过；3,073 Commit 仓库核心 benchmark 约 5.3–7.7 ms vs 782–787 ms；端到端 history 52–69 ms；浏览器连续切换 3 个 Commit 并返回缓存条目，无新增控制台错误 | 大型仓库 status 不响应取消且占用队列的问题转入 GIT-06 |
| 2026-07-26 | LIFE-03/GIT-04 | 待开始 → 已完成 | GitPanel 不再调用整包 `/git/summary`；分支先建立可见面板，历史/远程/标签/status 顺序补齐；新增模块级 `GitJobStore`，每仓库仅一个后台轮询器并用 `useSyncExternalStore` 恢复任务快照 | store 自动测试通过；lint/build 通过；浏览器文件/Git 往返 5 轮无新增错误；大型仓库概要单项 48–72 ms，status 35.87 s 后补 | Go status 的取消释放问题已在随后 GIT-06 修复 |
| 2026-07-26 | GIT-06 | 待开始 → 已完成 | `worktree.Status()` 在独立 goroutine 执行，Git worker 等待结果或 context 取消；取消后丢弃迟到结果并立即释放仓库活动任务槽 | `TestWaitGitDataWithContextReturnsOnCancel` 通过；真实 running status 取消后 100 ms 内同仓库 branch 入队并完成 | go-git 扫描本身仍会在后台收尾，但不再占用 Git worker；后续可单独评估原生 status 算法性能 |
| 2026-07-26 | AGENT-01/02/04/05 | 待开始 → 已完成/进行中 | 新增 50 ms patch 队列与批次 Map 合并；控制事件立即提交；流式 assistant 使用轻量文本；移除全树 MutationObserver 与连续自动滚动循环 | `pnpm test:agent-patch-batch`、lint/build 通过；5,000 patch 20.91 ms → 0.38 ms；面板往返无浏览器错误 | AGENT-02 仍需长期 Map 状态；AGENT-03 仍需独立行组件和 React Profiler；真实 30 秒 Agent 流式 QA 待补 |
| 2026-07-26 | LOG-01～04 / QA-03 | 待开始 → 已完成 | 新增 10,000 行/4 MiB 合并 chunk 缓冲、增量事件、80 ms UI 批次和固定截断状态；增加可重复 30 秒压力脚本 | 单元压力 30,000 行后 9,840 行/16 chunks；浏览器 30 秒 12,000 行，输入可用、末行和截断提示可见、无控制台错误 | 后续浏览器 Heap 自动采样纳入 PERF-01，不阻塞本组完成 |
| 2026-07-26 | SEARCH-04～06 / QA-04 | 待开始 → 进行中 | 新增模块级文件索引 Worker、Top 100、request ID、50 ms debounce、迟到结果丢弃和 UpdateFile 增量更新；主线程 fallback 改为动态 import | 41,752 文件核心查询 13.67–32.57 ms；新增/目录删除测试、lint/build 通过；App gzip 约减少 2.56 KB | 下一轮完成浏览器 P95、快速输入、上下键和真实文件变化验收后再标完成 |
| 2026-07-26 | BUNDLE-01 / P5 首批 | 待开始 → 已完成/进行中 | ProjectWorkspacePanel 对 Dora、Git、Upload 使用 React.lazy；只加载当前视图，Dora 首次访问后保持挂载；同色空背景作为加载占位 | lint/build 通过；App 302.76 KB/85.20 KiB gzip → 158.41 KB/47.48 KiB gzip；独立分块 Dora 17.68、Git 15.02、Upload 5.01 KiB gzip；浏览器逐一首次进入与返回通过 | Monaco 仍由 App 顶层静态依赖触发自动 modulepreload |
| 2026-07-26 | SEARCH-04～05 / BUNDLE-01 浏览器验收 | 进行中 → 已完成 | 验证空查询、快速连续查询、Top N、上下键/回车、首次 Esc；文件/Git/Dora 动态面板依次首次进入并返回 | 41,752 文件索引；50 次输入 P50 14 ms/P95 19 ms（含自动化通信）；键盘首项打开 `sky.jpg`；三个面板均正确显示 | SEARCH-06 真实 UpdateFile、严格浏览器内帧 P95 和触屏留在 QA-04/07；点击遮罩关闭发现边缘问题并改为弹窗级 pointer 监听 |
| 2026-07-26 | BUNDLE-04～05 | 待开始 → 已完成 | 审计 MUI/Ant 使用边界；构建后按最终内容给 TypeScript 和两个 Monaco Worker 加 12 位 SHA-256 文件名；HTML 直引版本化 Worker，TypeScript loader 读取 manifest，避免改写 Vite 已哈希 JS 分块；HTTP 服务区分哈希资源与入口缓存策略 | `pnpm test:heavy-assets`、lint、Web 生产构建、macOS Debug 全量构建通过；最新产物重启后 GET 实测 TS/两个 Worker 均 `max-age=31536000, immutable`，HTML/manifest 为 `no-cache`；TSX 文件在浏览器成功打开 Monaco 且无控制台错误 | BUNDLE-02 的 Monaco 主包首屏静态依赖仍待拆分；缓存策略需在正式反向代理/CDN 环境复核是否保留源站头 |
| 2026-07-26 | LIFE-02 | 待开始 → 已完成 | 新增 Agent session 最后快照缓存；初次挂载同步恢复 session、消息、步骤、checkpoint、问卷与模式；切换会话优先复用快照，删除会话同步失效；缓存限制为最近 24 个 session | `pnpm test:agent-session-snapshot` 验证快照隔离与 LRU 淘汰；生产构建中对 171 条历史消息会话执行文件/Dora 往返 5 轮、关闭并重开项目，首帧均保留历史且无控制台错误 | - |
| 2026-07-26 | AGENT-03 第二批 | 进行中 | assistant 消息抽为独立 `React.memo` 行，流式更新仅改变当前行的 props；稳定历史 Markdown 与外层布局均跳过重渲染，并增加消息 DOM 标识供验收计数 | lint 与生产构建待随本批结束统一验证 | StepRow 仍需独立 memo，React Profiler 证据待补 |
| 2026-07-26 | QA-05～06 | 待开始 → 已完成 | 汇总 3,073 Commit 仓库端到端证据；bundle 报告新增 hydrated shell 静态依赖递归与 700 KiB gzip 失败门禁 | Git history 52–69 ms、changed-files 51–59 ms；`pnpm perf:bundle:check` 得到 597.4 KiB gzip 并通过 | Monaco 仍在首屏 preload，属于 BUNDLE-02 的独立下载量优化，不影响“不含 Monaco”的 QA-06 预算口径 |
| 2026-07-26 | PERF-02 | 待开始 → 已完成 | 固化无编辑器、单/多 Tab、171 消息 Agent、3,073 Commit Git、30 秒日志和 41,752 文件搜索六类验收样本 | 每类记录路径/入口、规模、操作和通过条件 | PC/手机实际设备矩阵仍属于 PERF-04/QA-07 |
| 2026-07-26 | SEARCH-06 | 进行中 → 已完成 | Worker 新增路径移动协议并在一次遍历中映射文件/目录前缀；App 的树新建、项目文件创建/上传、删除、重命名和拖拽移动均更新模块级索引，不触发整表重建 | 41,752 文件测试覆盖新增、目录删除和嵌套目录移动；生产浏览器在已初始化索引后真实创建 `__codex_search_probe_20260726.txt`，确认可搜，重命名后旧名 0 条/新名可见，删除后新名 0 条；测试文件已清理，控制台无错误 | QA-04 仅剩严格浏览器内帧 P95 证据；触屏属于 QA-07 |
| 2026-07-26 | AGENT-03 第二批验收 | 进行中 | assistant 完整消息行使用稳定 ID 和 `React.memo`，不随末条流式消息重建稳定外层布局 | lint、生产构建通过；171 消息会话当前挂载 22 个带 `data-agent-message-id` 的消息行，文件/Dora 往返 5 轮数量稳定且空状态不可见，控制台无错误 | StepRow 独立 memo 与 React Profiler 仍待补 |
| 2026-07-26 | AGENT-03 第三批 | 进行中 | 工具步骤拆为独立 `AgentStepRow`；每行拥有自己的构建结果/命令展开状态，父级仅向变化步骤传递新的实体引用，并增加稳定 DOM ID 供 Profiler/计数验收 | lint、生产构建和 `git diff --check` 通过 | 仍需用 React Profiler 证明流式更新时稳定 MessageRow/StepRow 的 commit 次数不增长 |
| 2026-07-26 | AGENT-06 | 待开始 → 已完成 | 历史会话保留最近 10 轮的分段加载；当前任务工具步骤增加尾部渲染窗口，默认最新 80 步并按每批最多 80 步向前展开，不影响完整步骤集合参与 changeset 与上下文计算 | `pnpm test:agent-render-window` 覆盖 200 → 80、分批展开、全部可见及 0 可见边界；lint、生产构建和 `git diff --check` 通过 | 当前固定会话只有 32 个当前步骤，未触发 80 步 UI 阈值；DOM 上界由 200 步自动契约测试保证 |
| 2026-07-26 | AGENT-02 | 进行中 → 已完成 | AgentPanel 的 message、step、checkpoint 长期状态改为 `Map + orderedIds`；既有实体流式更新只复制 Map，保持顺序数组与其他实体引用稳定，新增、删除或排序字段变化时才重排 | `pnpm test:agent-patch-batch` 验证结果顺序、checkpoint 替换语义、稳定顺序引用与 5,000 patch；规范化批次约 0.21 ms，lint、生产构建和 `git diff --check` 通过 | React commit 次数仍由 AGENT-03 的 Profiler 验收单独跟踪 |
| 2026-07-26 | AGENT-03 / QA-01 浏览器验收 | 进行中 → 已完成 / 进行中 | 增加 `?doraPerf=1` 行级 render 计数；修复全量会话刷新替换全部实体引用的问题，并稳定打开文件、Diff 与回滚动作回调 | 修复前 5 次往返使 11 条 assistant 行 1→6、32 条步骤行约 6→22；修复后生产构建 20 次文件/Dora 往返，11 条 assistant 行和 32 条步骤行均 0 次额外 render，DOM Elements 4,062 → 4,062 | AGENT-03 完成；QA-01 仍需监听器与自然 GC 后 Heap 自动采样 |
| 2026-07-26 | QA-01 listener/Heap 验收 | 进行中 → 已完成 | `?doraPerf=1` 在应用启动前追踪 listener add/remove/once/signal，并暴露按类型计数与 Heap；为 `mac-scrollbar@0.13.8` 增加 pnpm 补丁，使 `removeEventListener` 复用注册时的 capture options | 修复前 20 次往返稳定后 listener 644 → 664，全部来自 `mousemove` 29 → 49；修复后 5 次预热、20 次往返、15 秒等待：listener 652 → 634、`mousemove` 19 → 19、Heap 108.7 → 71.7 MiB、DOM 4,063 → 4,063 | Heap/DOM/listener 均无持续增长；诊断仅在查询参数显式开启 |
| 2026-07-26 | BUNDLE-02/03 | 进行中/待开始 → 已完成 | 将 Monaco Editor、核心和语言贡献移入首次文本编辑器的动态边界，三份 TypeScript 声明文件只在 TS/TSX 编辑器初始化；隐藏文本 Tab 在运行时尚未加载时不创建 Editor；移除会导致动态块被入口 preload 的 Monaco `manualChunks` | 生产 HTML 不含 Monaco JS/CSS preload；hydrated shell 594.9 KiB gzip；Dora 冷启动 Monaco=false、TS Worker=false、Editor=0；打开 Lua 后 Monaco=true/TS Worker=false；打开 `Vomfy/init.tsx` 后 TS Worker=true，内容正常且控制台无错误 | `?doraPerf=1` 新增 Monaco/TS Worker 加载标识，普通路径不启用诊断 |
| 2026-07-26 | LIFE-07/08 第一批 | 待开始 → 进行中/已完成 | 普通文本 Editor 仅在对应 Tab 活动且处于文本模式时挂载；Monaco Model 由 `keepCurrentModel` 保留；卸载保存 viewState、清理旧 Editor 引用，重挂载仅在 Model 内容确实不同时写入 | `init.tsx` → 项目工作区 → `init.tsx`：Monaco Editor 数量 1 → 0 → 1；粘贴未保存标记后往返，内容仍存在且一次撤销可移除；在同一光标处前后粘贴 `aa`/`bb`，重挂载后得到相邻 `aabb`，随后两次撤销清理；控制台无错误 | LIFE-08 完成；可视化编辑器未改，活动 Tab 容器整体抽离仍由 LIFE-07 继续跟踪 |
| 2026-07-26 | LIFE-07/09 第二批 | 进行中/待开始 → 已完成/进行中 | 顶部 Tab 改为活动项加最近 1 项的两实例 LRU；隐藏项目 Tab 将 Agent 置为 inactive；Yarn/CodeWire 卸载时清理旧 iframe API 引用 | 3 个混合 Tab 预热后再切换 21 次：`main` 2 → 2、DOM 1,976 → 1,976、listener 441 → 441、Heap +1.97 MiB；未修改 Yarn 与 CodeWire iframe 均 1 → 0 → 1 且无控制台错误 | LIFE-07 完成；LIFE-09 随后补齐 Yarn/CodeWire 未保存快照，TIC 状态协议仍待补 |
| 2026-07-26 | LIFE-09 TIC 前置清理 | 进行中 | TIC iframe 的 `load` 监听改为可替换 cleanup，卸载时同时移除顶层 message 与 iframe keydown 回调 | 关闭 TIC Tab 后 iframe 1 → 0、顶层 message listener 1 → 0；lint、生产构建和 `git diff --check` 通过 | 当前只消除生命周期泄漏风险，不改变 TIC 未保存编辑状态的保守固定策略 |
| 2026-07-26 | PERF-01 / QA-04 搜索页内诊断 | 进行中/进行中 → 进行中/已完成 | 跳转文件组件在诊断模式记录输入事件到 React layout commit 的有界样本，并暴露 count/P50/P95/max；普通路径不创建样本 | 三轮独立生产页面各 50 次输入：P95 1.10/1.10/1.00 ms，均低于 16 ms；搜索核心隔离复测 `sky` 30.31 ms、其余 13.88–18.05 ms，均在 Worker | QA-04 完成；PERF-01 仍需把首屏与 Tab 场景编排固化为仓库脚本 |
| 2026-07-26 | LIFE-09 未保存快照 | 进行中 | Yarn 变更后按 revision 异步获取 JSON 并转换为可重载文本，pending 期间才固定 iframe；CodeWire 每次变更和卸载同步保存 visual script；重载均使用 `contentModified ?? content` | 在真实 iframe 中添加 `codex_lru_probe_20260726` 变量、修改 Yarn 节点为 `codex_yarn_lru_probe_20260726`，越过 LRU 后两者均恢复；探针未写入磁盘；生产构建、lint 通过 | TIC 只有读盘/写盘桥接，尚不能在不保存用户文件的情况下导出内存 cart，因此 LIFE-09 保持进行中 |
| 2026-07-26 | LIFE-09 TIC dirty-pin | 进行中 → 已完成 | TIC iframe 记录键盘/指针 dirty revision；干净实例参与两实例 LRU，脏实例固定；写盘成功且 revision 未变化时解除固定；输入与顶层 message 监听统一清理 | 干净实例 iframe 1→0→1；点击 canvas 后切走两个 Tab，iframe 仍为 1、`main` 为 3；无新增应用控制台错误；生产构建、lint、完整前端测试和 bundle 门禁通过 | 现有 TIC 桥接无需新增自动写盘或高风险 WASM 内存导出 |
| 2026-07-26 | PERF-01 / PERF-04 PC 基线 | 进行中 → 已完成 / 待开始 → 进行中 | 新增无额外依赖的 Chrome CDP 编排脚本，自动采集冷启动、跳转文件页内输入、真实 Top 100 结果和三 Tab LRU 稳定性；为文件 Tab/搜索输入增加稳定诊断键，采样前后显式 GC 以消除自然 GC 时点噪声 | `pnpm perf:browser` 三轮全部通过：冷启动 141.9–150.6 ms、搜索 P95 0.7–0.8 ms、Tab P95 44.2–48.2 ms、DOM/listener 增量均 0、Heap +1.15–1.29 MiB | PERF-01 完成；PERF-04 仅剩手机触屏真机基线 |
| 2026-07-26 | SEARCH-04 冷打开竞态回归 | 已完成 → 已完成 | 修复空索引初始化尚未 ready 时被完整索引替换导致旧 `readyPromise` 永久等待；重新初始化前显式释放旧 waiter，新 generation 的 initialize/query 仍按 Worker 消息顺序执行 | mock Worker 复现“先查询、后用完整索引重建”，500 ms 门限内返回目标；真实生产浏览器冷打开立即输入后 41,294 项索引完成并返回 Top 100 | - |
| 2026-07-26 | QA-02 Agent 浏览器压力 | 进行中 → 已完成 | 新增仅在 `?doraPerf=1` 暴露的 Agent patch 诊断入口和 `perf:agent:browser`；复用固定长会话，以 25 ms 间隔持续 30 秒进入实际批处理、React 渲染和滚动链路，不写数据库、不调用模型 | 1,201 patch；frame P95 9.0 ms、max 10.3 ms；0 Long Task；probe 401/605；稳定消息/步骤 0 render；listener 增量 0；Heap -117,942 bytes | 真实模型端到端 smoke 需要外部模型调用，单独保留为人工/服务验收，不影响确定性渲染预算结项 |
| 2026-07-26 | PERF-04 / QA-07 触控仿真 | 待开始 → 进行中 | `perf:mobile:browser` 启用 Chrome 移动设备和 5 触点仿真，覆盖 390×844 纵屏资源树覆盖层、844×390 横屏 Splitter/搜索/首次 Esc/资源树，以及同页方向切换 | 纵屏内容区保持 390 px，覆盖层 319 px 且可触控开合；横屏 Splitter 触摸移动 40 px；41,294 候选仅渲染 Top 100；输入 P95 0.8 ms；横转纵后资源树 370→0 px、内容区 390 px；控制台 0 错误 | 物理手机上的浏览器地址栏、系统手势冲突与操作手感仍待真机验收 |
| 2026-07-26 | LIFE-10 / QA-07 纵屏修复 | 待开始 → 已完成 / 进行中 | 实测发现 390 px 纵屏无法同时满足资源树 170 px 与内容区 320 px；改为 `<490 px` 默认收起资源树、内容区全宽、资源树 82% 覆盖层，并增加显式关闭按钮 | Chrome 双视口自动化通过；iPhone 17 / iOS 26.5 Simulator Safari 中既有 Agent 会话首帧可见，覆盖层开合及 Dora/文件/Git 切换正常 | iOS 模拟器只验证 WebKit 和布局，不替代物理手机验收 |
| 2026-07-26 | PERF-04 / QA-07 物理设备复核 | 进行中 → 阻塞 | 再次枚举本机可用移动设备，明确外部验收的实际可执行条件 | `xcrun xctrace list devices` 的 Devices 仅有 MacBook Pro，其余均列在 Simulators；`adb devices -l` 无设备 | 连接并授权至少一台物理 iOS 或 Android 手机后，按 QA-07 样本检查地址栏占位、系统手势冲突、资源树拖拽/覆盖层、搜索、Agent 和 Git 手感即可解除 |

## 每轮实施约定

每轮开始前：

1. 选择一个任务或一组紧密依赖任务。
2. 将状态改为“进行中”。
3. 记录开始前的对应基线。
4. 不夹带与该性能路径无关的重构。

每轮结束前：

1. 将任务改为“已完成”“阻塞”或“延后”。
2. 在进度日志追加实际文件、测量结果和遗留问题。
3. 运行 `pnpm lint`、`pnpm build` 和 `git diff --check`。
4. 涉及 UI 时进行浏览器检查；涉及触屏时补真机检查。
5. 对照修改前基线，不能只报告“体感更快”。
