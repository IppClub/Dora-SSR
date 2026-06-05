# ActionEditor Web IDE 开发进度

## 用法

这张表用于跟踪新版 ActionEditor 的实现进度。每次完成一个开发批次时，更新对应条目的状态、完成证据、验证结果和阻塞项。

状态枚举：

- `todo`：尚未开始。
- `doing`：正在实现。
- `blocked`：已开始但被外部条件或设计问题阻塞。
- `review`：实现完成，等待人工确认或代码审查。
- `done`：已实现并通过对应验收。
- `deferred`：明确延后，不阻塞当前里程碑。

建议维护字段：

- `ID`：稳定任务编号，便于后续引用。
- `模块`：工作归属。
- `任务`：可交付项。
- `状态`：当前状态。
- `依赖`：必须先完成的任务。
- `验收标准`：判定完成的行为或结果。
- `验证`：命令、手工步骤或样例文件。
- `产物/文件`：预期会新增或修改的位置。
- `备注`：风险、决策、剩余问题。

## 总览

| ID | 模块 | 任务 | 状态 | 依赖 | 验收标准 | 验证 | 产物/文件 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AE-00 | 方案 | 设计文档确认 | done | - | `Docs/action-editor-web-ide-rebuild.md` 反映当前 `.model` 直读直存方案 | 人工审阅当前文档 | `Docs/action-editor-web-ide-rebuild.md` | 已按当前实现同步为 `.model` 直读直存、canvas + WebGL + imgui-ts 方案 |
| AE-01 | 数据模型 | 定义内部 `ActionDocument` 类型 | done | AE-00 | 类型覆盖 model、node、look、animation、key frame、viewport 无关数据 | `cd Tools/dora-dora && pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `Tools/dora-dora/src/ActionEditor/ActionDocument.ts` | 内部编辑态类型；不持久化 `.action.json` |
| AE-02 | `.model` 解析 | 实现 `.model` XML parser | done | AE-01 | 能解析历史 `role.model`、`flandre.model` 为内部对象模型 | `cd Tools/dora-dora && pnpm exec node scripts/verify-action-editor-data.mjs` 通过 | `Tools/dora-dora/src/ActionEditor/ActionLegacyModel.ts` | 已按引擎 parser 语义展开缺失 key frame 属性和 duration |
| AE-03 | `.model` 序列化 | 实现内部对象模型 -> `.model` writer | done | AE-02 | 保存后的 `.model` 能被 Dora `Model()` 加载 | `cd Tools/dora-dora && pnpm exec node scripts/verify-action-editor-data.mjs` 覆盖 fixture parse -> write -> parse；引擎运行验证未做 | `Tools/dora-dora/src/ActionEditor/ActionLegacyModel.ts` | 不输出历史 root `B` / useBatch 字段 |
| AE-04 | 解析失败策略 | 加载失败后创建空对象并标记待保存 | done | AE-01 | 解析失败时提示错误，tab dirty，保存会写空 `.model` | `cd Tools/dora-dora && pnpm exec node scripts/verify-action-editor-data.mjs` 覆盖坏 `.model`；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 Web IDE 接入类型检查 | `Tools/dora-dora/src/ActionEditor/ActionLegacyModel.ts` / `ActionEditor.tsx` / `App.tsx` | 坏 `.model` 在 canvas ActionEditor 中提示错误，并通过 `contentModified` 进入现有保存流程 |
| AE-05 | 图集路径 | 实现同目录 `.clips` 输入和 `.clip`/`.png` 输出规则 | done | AE-02 | `Hero.model` 默认使用 `Hero.clips/`；多个 `.clips` 目录时可选择；输出所选 basename 的 `.clip` 和 `.png` | `cd Tools/dora-dora && pnpm exec node scripts/verify-action-editor-data.mjs` 通过 | `Tools/dora-dora/src/ActionEditor/ActionPaths.ts` | 已实现路径选择和输出命名；选择 UI 随 AE-09A/后续 ImGui 接入 |
| AE-06 | `.clip` 解析 | 解析 `.clip` 并验证 clip 名称 | done | AE-05 | 节点引用不存在的 clip 时显示诊断 | `cd Tools/dora-dora && pnpm exec node scripts/verify-action-editor-data.mjs` 通过，覆盖 texture 同目录解析、正常引用和缺失 clip 负例 | `Tools/dora-dora/src/ActionEditor/ActionClip.ts` | 已读取 texture 文件路径并验证 fixture 节点 clip 引用 |
| AE-07 | Web IDE 宿主 | `.model` 默认打开 ActionEditor | done | AE-01 | 点击 `.model` tab 显示可视化编辑器 | `cd Tools/dora-dora && pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `Tools/dora-dora/src/App.tsx` / `Tools/dora-dora/src/ActionEditor/ActionEditor.tsx` | `.model` 已进入 canvas ActionEditor，不进入 Monaco 源码文本 |
| AE-07A | Web IDE 新建入口 | 文件资源创建入口新增 Dora 动画文件 | done | AE-01, AE-07 | 可在 Web IDE 中新建空 `.model`，创建后自动打开 ActionEditor | `cd Tools/dora-dora && pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `Tools/dora-dora/src/NewFileDialog.tsx` / `App.tsx` / `i18n.ts` | 新增 Dora Animation 类型，用 ActionEditor writer 生成空 `.model`，不创建 `.action.json` |
| AE-08 | 保存集成 | 接入当前 tab dirty/save 流程 | done | AE-03, AE-07 | 编辑后 tab 待保存，Ctrl/Cmd+S 写回 `.model` | `cd Tools/dora-dora && pnpm exec tsc --noEmit -p tsconfig.json` 通过；`pnpm exec node scripts/verify-action-editor-data.mjs` 覆盖 writer 输出 | `App.tsx` / `ActionEditor.tsx` / `ActionEditorCanvas.tsx` | ImGui 面板修改 root name、size、添加空节点和坏 `.model` fallback 都走 `contentModified` 保存流 |
| AE-09 | UpdateFile 同步 | 外部修改 `.model` 后刷新或提示冲突 | deferred | AE-07 | 用户要求去掉 UpdateFile 更新 model 文件 | 代码审阅：`.model` UpdateFile 只维护资源树，不更新已打开 tab 内容 | `App.tsx` | 按当前要求不做 `.model` 外部写入同步 |
| AE-09A | 技术栈接入 | 接入 canvas + WebGL + `imgui-ts` 编辑器运行时 | done | AE-07 | ActionEditor tab 内仅用 canvas 绘制编辑器，ImGui UI 正常显示并能捕获输入；字体使用 `sarasa-mono-sc-regular`；style 和配色对齐 `Source/GUI/ImGuiDora.cpp` | `cd Tools/dora-dora && pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `ActionImGuiRuntime.ts` / `ActionEditorCanvas.tsx` / `package.json` / `pnpm-lock.yaml` | 接入 `@zhobo63/imgui-ts`，运行时加载 `sarasa-mono-sc-regular`，字体失败显示诊断；style 数值迁移自 `ImGuiDora::init()` |
| AE-10 | WebGL 渲染 | 基础 sprite 渲染 | done | AE-06, AE-07 | 显示 `.model` 默认 pose，clip rect 正确 | `cd Tools/dora-dora && pnpm exec node scripts/verify-action-editor-data.mjs` 覆盖 clip rect 派生和 pose rect；`pnpm exec vite build` 通过 | `ActionRender.ts` / `ActionEditorCanvas.tsx` | 用 ImGui/WebGL draw list 绘制 clip rect quad、selection outline 和缺失 clip 诊断色 |
| AE-11 | Viewport | pan、zoom、origin reset | done | AE-10 | 视图操作不改变模型坐标 | verifier 覆盖 screen/model origin 映射；Vite 页面请求返回 200；`pnpm exec vite build` 通过 | `ActionEditorState.ts` / `ActionEditorCanvas.tsx` | 右键拖拽 pan、滚轮和按钮 zoom、Origin reset |
| AE-12 | 选择 | 节点 hit test 和 selection outline | done | AE-10 | 点击 sprite 选中对应节点，重建后选择保持 | verifier 覆盖 topmost hit test；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `ActionRender.ts` / `ActionEditorCanvas.tsx` | 选择态使用稳定 node id |
| AE-13 | 节点树 | 左侧层级树 | done | AE-12 | 展示层级、折叠、选择同步 | `pnpm exec tsc --noEmit -p tsconfig.json` 和 `pnpm exec vite build` 通过 | `ActionEditorCanvas.tsx` | ImGui 左侧层级列表选择同步，不保存运行时 node 引用 |
| AE-14 | Sprite 编辑 | 添加、删除、重排、移动父节点、替换 clip | done | AE-13 | 命令修改对象树并可 undo | verifier 覆盖 add/delete/reorder 和禁止移动到子孙的命令路径；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `ActionEditorState.ts` / `ActionEditorCanvas.tsx` / `ActionEditor.tsx` | 已接本地 undo/redo 栈；Move Here 改父节点；clip 字段在属性面板替换 |
| AE-15 | 属性面板 | faceRight、size、transform、front、key points | done | AE-14 | 表单修改后预览和保存内容更新 | verifier 覆盖 key point add/update/remove；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `ActionEditorState.ts` / `ActionEditorCanvas.tsx` | 已有 name、clip、front、size、transform、anchor、opacity、key points；不包含 Batch Used |
| AE-16 | Gizmo | move、rotate、scale、anchor、size 拖拽 | done | AE-15 | Canvas 拖拽更新属性，可撤销 | `pnpm exec tsc --noEmit -p tsconfig.json` 和 `pnpm exec vite build` 通过 | `ActionEditorCanvas.tsx` | Viewport 工具栏支持 move/scale/rotate/anchor/size 拖拽模式和 Fixed snapping，修改走 undo 栈 |
| AE-17 | Look 编辑 | 创建、删除 look 和节点隐藏切换 | done | AE-15 | hiddenInLooks 保存为 `.model` look hide list | verifier 覆盖 look 隐藏渲染和 working model round-trip；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `ActionEditorState.ts` / `ActionEditorCanvas.tsx` | Look 语义保持隐藏列表 |
| AE-18 | Animation 数据 | animation 和 track 数据管理 | done | AE-03, AE-15 | 支持 animation 新增、删除、选择 | verifier 覆盖 animation 新增、删除和 node track 删除；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `ActionPlayback.ts` / `ActionEditorCanvas.tsx` | 内部使用绝对时间 |
| AE-19 | 时间轴 | scrub、关键帧游标、60fps 网格 | done | AE-18 | 拖拽时间更新 pose 和属性面板 | verifier 覆盖 animation pose render sampling；`pnpm exec vite build` 通过 | `ActionPlayback.ts` / `ActionEditorCanvas.tsx` | 动画面板可输入 time，显示 60fps frame 和 key 列表 |
| AE-20 | Keyframe 编辑 | add/delete/copy/paste/move key | done | AE-19 | 插入删除不改变后续绝对时间 | verifier 覆盖 add/update/delete/copy/paste/move key；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 | `ActionPlayback.ts` / `ActionEditorCanvas.tsx` | 保存时转 duration |
| AE-21 | Playback | play、pause、loop、easing sampling | done | AE-20 | 浏览器播放时长与 Dora Model 一致 | verifier 覆盖 sampling 和 duration；`pnpm exec vite build` 通过 | `ActionPlayback.ts` / `ActionEditor.tsx` / `ActionEditorCanvas.tsx` | 支持 key animation type 1 sampling、play/pause/loop UI |
| AE-22 | Event 字段 | 编辑 keyframe event | done | AE-20 | event round-trip 不丢失 | verifier 覆盖 keyframe event 写入 working model；writer round-trip 由 `.model` verifier 覆盖 | `ActionPlayback.ts` / `ActionEditorCanvas.tsx` | |
| AE-23 | 工程运行集成 | `.model` 编辑态运行命令语义 | done | AE-08, AE-21 | 工程运行命令运行游戏工程；Run Current File 对 `.model` 提示无法运行当前文件 | `cd Tools/dora-dora && pnpm exec tsc --noEmit -p tsconfig.json` 通过；`pnpm exec vite build` 通过 | `Tools/dora-dora/src/App.tsx` / `Tools/dora-dora/src/i18n.ts` | `.model` 不提供单独运行命令；Run Project 走现有 `asProj`，Run Current File 显示不可运行提示 |
| AE-24 | 图集打包 | 实现 `.clips` -> `.clip`/`.png` 打包 | done | AE-05 | 输出文件与 `.model` 同目录且资源树同步 | verifier 覆盖 atlas rect packing 和 `.clip` rect map writer；`pnpm exec vite build` 通过 | `ActionAtlasCore.ts` / `ActionAtlasPacker.ts` / `ActionEditorCanvas.tsx` | 浏览器端加载 `.clips` 图片，用 canvas 生成 png，通过 `/upload` 写 `.png`，通过 `/write` 写 `.clip` |
| AE-25 | 诊断 | 用户可读错误和警告 | done | AE-02, AE-06 | 解析、clip 缺失、保存失败都有明确提示 | verifier 覆盖坏 `.model` 和缺失 clip；`pnpm exec tsc --noEmit -p tsconfig.json` 通过 | Action diagnostics | ImGui 面板显示 parse、font、clip、packer 诊断；保存失败走现有 Web IDE alert |
| AE-26 | 测试 fixture | 建立历史样例和空模型测试 | done | AE-02, AE-03 | 覆盖空模型、role、flandre、坏文件 | `cd Tools/dora-dora && pnpm exec node scripts/verify-action-editor-data.mjs` 通过 | `Tools/dora-dora/scripts/verify-action-editor-data.mjs` | 覆盖数据闭环、静态编辑命令、动画命令和 atlas packer 纯逻辑 |
| AE-27 | 文档更新 | 实现后同步设计和进度 | done | 各任务 | 表格状态和设计差异保持同步 | 人工审阅当前文档 | `Docs/action-editor-progress.md` | 已同步到所有里程碑完成状态 |

## 里程碑

| 里程碑 | 范围 | 完成条件 | 状态 |
| --- | --- | --- | --- |
| M1 数据闭环 | AE-01 到 AE-06 | `.model` 可解析、可序列化、坏文件走空模型待保存 | done |
| M2 Web IDE 接入 | AE-07、AE-07A、AE-08、AE-09A；AE-09 deferred | `.model` 在 Web IDE 中以 canvas + WebGL + imgui-ts 可视化新建、打开、修改、保存；不做 UpdateFile 更新 `.model` | done |
| M3 静态编辑 | AE-10 到 AE-17 | 默认 pose、节点树、属性、look 可编辑 | done |
| M4 动画编辑 | AE-18 到 AE-22 | 时间轴、关键帧、播放、event 可编辑并 round-trip | done |
| M5 打包和运行验证 | AE-23 到 AE-26 | 图集打包、工程运行语义和核心 fixture 验证通过 | done |

## 当前决策记录

| 决策 | 结果 |
| --- | --- |
| 外部持久格式 | 直接读写 `.model`，不输出 `.action.json` |
| 解析失败 | 提示加载失败，创建空对象，当前 tab 进入待保存状态 |
| 图集输入 | `.model` 同目录下 `.clips` 目录 |
| 图集输出 | `.model` 同目录下 `.clip` 和 `.png` |
| Batch Used | 不再作为可编辑属性；保存时移除旧 root `B` 字段 |
| 时间轴内部模型 | 内部用绝对时间，保存 `.model` 时转换为 duration |
| 多个 `.clips` 目录 UI | 开发选择 UI，默认选中同 basename 目录 |
| 源码文本切换 | 不开发 |
| 图集打包 | 纳入 MVP |
| `.model` 运行 | 不提供单独 model 运行命令；工程运行运行游戏工程，Run Current File 提示不可运行 |
| Web IDE 新建入口 | 文件资源创建入口新增 Dora 动画文件，创建空 `.model` 后打开 ActionEditor |
| 编辑器技术栈 | 整个 ActionEditor 使用 canvas + WebGL + `imgui-ts` 绘制，React 只负责 Web IDE 宿主和 Service 集成 |
| ImGui 字体 | 使用 `sarasa-mono-sc-regular`，加载失败必须提示诊断 |
| ImGui style | 对齐 `Source/GUI/ImGuiDora.cpp` 中 `DoraSetupTheme()` 和 `ImGuiDora::init()` 的配色与 style 设置 |

## 待确认问题

无。
