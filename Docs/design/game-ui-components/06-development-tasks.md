# UIX Development Tasks

本文用于跟踪 `Assets/Script/Lib/UIX/` 首版开发进度。状态字段只使用：

- `todo`：尚未开始。
- `doing`：正在开发。
- `blocked`：被外部问题阻塞。
- `review`：实现完成，等待检查或调整。
- `done`：实现和验证都完成。

## 里程碑总览

| Milestone | 范围 | 状态 | 完成标准 |
| --- | --- | --- | --- |
| M0 | 前置确认和文档 | done | 设计、MVP、运行时、API、主题、验证和任务文档齐备 |
| M1 | UIX 基础设施 | done | `theme`、`context`、`PaintNode`、绘制原语可编译 |
| M2 | 布局和基础视觉 | done | `Box/Row/Column/Stack/Spacer/Panel/Text/Icon/FocusRing` 可用 |
| M3 | 首批控件 | done | `Button/IconButton/ProgressBar` 可用并覆盖基础状态 |
| M4 | 游戏组件 | done | `HealthBar/ResourceCounter/CooldownButton` 可用 |
| M5 | Demo 和验证 | done | HUD demo、marker 测试、runner 和文档示例通过 |
| M6 | 第二批通用控件 | done | `Toggle/Slider/Tabs` 可用，`SecondaryControlsTest` 通过 |
| M7 | 用户测试 demo | done | `UserTestDemo` 可编译，便捷启动脚本可用，UIX runner 通过 |
| M8 | 轻量 Overlay 组件 | done | `Tooltip/ToastStack/Modal` 可用，`OverlayComponentsTest` 通过 |
| M9 | 首版质量收尾 | done | 文档与实现同步，动态 key 警告清理，Tooltip/Modal 回归测试通过 |
| M10 | 固定背包网格组件 | done | `ItemSlot/InventoryGrid` 可用，`InventoryGridTest` 通过 |
| M11 | 基础滚动容器 | done | `ScrollView` 使用 nvg scissor 裁剪，`ScrollViewTest` 通过 |
| M12 | 表单类补充控件 | done | `Checkbox` 可用，`CheckboxControlTest` 通过 |

## 任务拆分

| ID | 任务 | 依赖 | 产物 | 验证 | 状态 |
| --- | --- | --- | --- | --- | --- |
| T00 | 固化 `UIX` 命名空间和首版范围 | 无 | `README.md`、`01-mvp-scope.md` | 文档审阅 | done |
| T01 | 确认 DoraX `align-node.style` patch | 无 | runtime 前置说明 | 检查 `DoraX.ts` 和 `DoraX.lua` | done |
| T02 | 创建 UIX 目录和导出入口 | T00 | `Assets/Script/Lib/UIX.ts`、`Assets/Script/Lib/UIX/index.ts` | `dora cli build -f Assets/Script/Lib/UIX.ts` | done |
| T03 | 实现 theme token | T02 | `theme.ts` | 单独编译 | done |
| T04 | 实现 UI context 基础 | T03 | `context.ts` | context 依赖组件编译 | done |
| T05 | 实现 painter 类型和颜色 helper | T03 | `types.ts`、`paint/color.ts` | 单独编译 | done |
| T06 | 实现 `PaintNode` | T04, T05 | `paint/PaintNode.tsx` | 简单 nvg rect demo | done |
| T07 | 实现绘制原语 | T06 | `paint/primitives.ts` | visual smoke demo | done |
| T08 | 实现内置 icon painter | T06 | `paint/icons.ts` | icon sheet demo | done |
| T09 | 实现布局组件 | T04 | `Box/Row/Column/Stack/Spacer` | layout demo 编译 | done |
| T10 | 实现 `Text` | T04 | `foundation/Text.tsx` | text demo 编译 | done |
| T11 | 实现 `Icon` | T08 | `foundation/Icon.tsx` | sprite + painter icon demo | done |
| T12 | 实现 `FocusRing` | T07 | `foundation/FocusRing.tsx` | focus visual demo | done |
| T13 | 实现 `Panel` | T07, T09, T10 | `layout/Panel.tsx` | panel resize demo | done |
| T14 | 实现 interaction state helper | T04 | `input/Interaction.ts` | state unit/demo test | done |
| T15 | 实现最小 `FocusManager` | T04, T12 | `input/FocusManager.ts` | focus order demo | done |
| T16 | 实现 `Button` | T10, T11, T12, T14, T15 | `controls/Button.tsx` | click/disabled/focus demo | done |
| T17 | 实现 `IconButton` | T16 | `controls/IconButton.tsx` | selected/disabled demo | done |
| T18 | 实现 `ProgressBar` | T07, T10 | `controls/ProgressBar.tsx` | progress signal demo | done |
| T19 | 实现 `HealthBar` | T18 | `game/HealthBar.tsx` | danger threshold demo | done |
| T20 | 实现 `ResourceCounter` | T10, T11 | `game/ResourceCounter.tsx` | value update demo | done |
| T21 | 实现 `CooldownButton` | T17, T10 | `game/CooldownButton.tsx` | cooldown signal demo | done |
| T22 | 编写 `HudDemo.tsx` | T13, T19, T20, T21 | `/Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/HudDemo.tsx` | 引擎内手动视觉 QA | done |
| T23 | 编写 `LayoutPatchTest.tsx` | T09, T13 | marker 测试 | marker `passed` | done |
| T24 | 编写 `InteractionStateTest.tsx` | T14, T16, T17, T21 | marker 测试 | marker `passed` | done |
| T25 | 编写 `UnmountCleanupTest.tsx` | T06, T15, T16 | marker 测试 | marker `passed` | done |
| T26 | 编写 `run-all.zsh` | T22-T25 | UIX test runner | 全部 marker passed | done |
| T27 | 更新使用示例和开发说明 | T22-T26 | README 示例校准 | 文档审阅 + diff check | done |
| T28 | 实现 `Toggle` | T07, T10, T12, T14 | `controls/Toggle.tsx` | tap 后 `onChange` 输出新 checked 值 | done |
| T29 | 实现 `Slider` | T06, T07 | `controls/Slider.tsx` | 编译通过，value/min/max/step 可控 | done |
| T30 | 实现 `Tabs` | T16 | `controls/Tabs.tsx` | keyed tab item 选择变更 | done |
| T31 | 编写 `SecondaryControlsTest.tsx` | T28-T30 | marker 测试 | marker `passed` | done |
| T32 | 更新二轮控件文档和进度表 | T28-T31 | API、范围、验证、任务文档 | 文档审阅 + diff check | done |
| T33 | 编写 `UserTestDemo.tsx` | T16-T31 | 手动用户测试 demo | demo 编译通过 | done |
| T34 | 编写 `run-user-demo.zsh` | T33 | demo 启动脚本 | 脚本可执行，entry 路径正确 | done |
| T35 | 更新用户测试文档 | T33-T34 | 验证计划和任务表 | 文档审阅 + runner 通过 | done |
| T36 | 实现 `Tooltip` | T06, T10, T13 | `overlay/Tooltip.tsx` | mount + 编译通过 | done |
| T37 | 实现 `ToastStack` | T10, T13 | `overlay/ToastStack.tsx` | keyed toast item 渲染 | done |
| T38 | 实现 `Modal` | T10, T13, T16 | `overlay/Modal.tsx` | backdrop close + action API 编译 | done |
| T39 | 编写 `OverlayComponentsTest.tsx` | T36-T38 | marker 测试 | marker `passed` | done |
| T40 | 集成用户测试 demo 和文档 | T36-T39 | `UserTestDemo` overlay 场景、API、验证、任务文档 | runner 通过 | done |
| T41 | 清理 nvg 文本、ARGB 颜色和 Label 层级的过时文档 | T40 | README、API、主题文档 | 文档审阅 + grep 检查 | done |
| T42 | 清理 `PaintNode` 重复默认 key 风险 | T06, T40 | `paint/PaintNode.tsx` | 点击触发重渲染后不再复用错误 painter | done |
| T43 | 增加 Tooltip wrap 与 Modal overlay 回归测试 | T36-T40 | `TextOverlayRegressionTest.tsx` | marker `passed` | done |
| T44 | 复跑 UIX runner 和用户 demo | T41-T43 | 生成 Lua、测试 marker、demo 启动 | runner passed + demo 可运行 | done |
| T45 | 实现 `ItemSlot` | T07, T10, T11, T14 | `game/ItemSlot.tsx` | 编译通过，empty/quality/count/cooldown 可渲染 | done |
| T46 | 实现 `InventoryGrid` | T45 | `game/InventoryGrid.tsx` | 固定行列、empty slot、selectedId | done |
| T47 | 编写 `InventoryGridTest.tsx` | T45-T46 | marker 测试 | marker `passed` | done |
| T48 | 集成 Bag 页 demo 和文档 | T45-T47 | `UserTestDemo` Bag 页、API、验证、任务文档 | runner 通过 | done |
| T49 | 实现 nvg 祖先裁剪注册 | T06 | `paint/clip.ts`、`PaintNode.tsx` | UIX lib build 通过 | done |
| T50 | 实现 `ScrollView` | T49 | `layout/ScrollView.tsx` | wheel/drag offset clamp，content y 偏移 | done |
| T51 | 编写 `ScrollViewTest.tsx` | T50 | marker 测试 | marker `passed` | done |
| T52 | 集成 Bag 页滚动 demo 和文档 | T50-T51 | `UserTestDemo` Bag 页、API、验证、任务文档 | runner 通过 | done |
| T53 | 增强 `Panel` 内容区滚动 | T50 | `layout/Panel.tsx`、`PanelScrollTest.tsx`、`UserTestDemo` | Panel 内外溢内容被裁剪并可滚动 | done |
| T54 | 实现 `Checkbox` | T07, T10, T12, T14 | `controls/Checkbox.tsx` | checked/indeterminate/disabled 可渲染 | done |
| T55 | 编写 `CheckboxControlTest.tsx` | T54 | marker 测试 | marker `passed` | done |
| T56 | 集成 Tune 页 demo 和文档 | T54-T55 | `UserTestDemo` Tune 页、API、任务文档 | runner 通过 | done |

## 执行顺序

第一批必须顺序完成：

1. T02 创建目录和入口。
2. T03-T05 建立 theme/context/painter 类型。
3. T06-T08 打通普通 `Node` nvg 绘制。
4. T09-T13 建立可布局可显示的基础组件。

第二批可以部分并行：

1. T14 interaction 和 T15 focus manager。
2. T16-T18 控件。
3. T19-T21 游戏组件。

第三批是验证闭环：

1. T22 demo。
2. T23-T25 marker 测试。
3. T26 runner。
4. T27 文档校准。

第四批是第二轮通用控件：

1. T28-T30 补齐 Toggle、Slider、Tabs。
2. T31 增加二轮控件 marker 测试。
3. T32 同步 API、验证计划和任务进度。

第五批是用户测试入口：

1. T33 组合首批和第二批控件成可交互 demo。
2. T34 提供一键启动脚本。
3. T35 记录手动测试范围和进度。

第六批是轻量 overlay：

1. T36-T38 补齐 Tooltip、ToastStack、Modal。
2. T39 增加 overlay marker 测试。
3. T40 集成 UserTestDemo 并同步文档。

第七批是首版质量收尾：

1. T41 清理文档中过时的 `Label`、RGBA 和渲染层描述。
2. T42-T43 固化动态 key 和 overlay/text wrap 回归测试。
3. T44 复跑 runner 和用户测试 demo。

第八批是固定背包网格：

1. T45 实现 `ItemSlot`。
2. T46 实现 `InventoryGrid`。
3. T47 增加 marker 测试。
4. T48 集成到 UserTestDemo 的 Bag 页并同步文档。

第九批是基础滚动容器：

1. T49 在 `PaintNode` 层接入 nvg scissor 祖先裁剪。
2. T50 实现固定 viewport 的垂直 `ScrollView`。
3. T51 增加 marker 测试。
4. T52 把 Bag 页接入滚动 demo 并同步文档。
5. T53 把滚动能力提升到 `Panel` 内容区，业务页不再自行猜测 Panel 可用高度。

第十批是表单类补充控件：

1. T54 实现 `Checkbox`，覆盖 checked、indeterminate、disabled 和 label。
2. T55 增加 Checkbox marker 测试。
3. T56 集成到 UserTestDemo 的 Tune 页并同步文档。

## 进度记录

| 日期 | 变更 | 任务 | 状态 |
| --- | --- | --- | --- |
| 2026-06-26 | 完成 UIX 设计文档集，确认命名空间和 DoraX style patch 前置 | T00, T01 | done |
| 2026-06-26 | 完成 UIX MVP 组件、Dora-Example demo、marker 测试和 runner | T02-T27 | done |
| 2026-06-26 | 完成 Toggle、Slider、Tabs 和 SecondaryControlsTest，二轮控件进入可验证状态 | T28-T32 | done |
| 2026-06-26 | 增加 UserTestDemo 和 run-user-demo.zsh，供手动用户测试 | T33-T35 | done |
| 2026-06-26 | 完成 Tooltip、ToastStack、Modal 和 OverlayComponentsTest | T36-T40 | done |
| 2026-06-26 | 完成首版质量收尾，补充 nvg 文本/ARGB 文档、移除 PaintNode 重复默认 key 风险并增加 overlay 回归测试，UIX runner 通过 | T41-T44 | done |
| 2026-06-26 | 完成 ItemSlot、InventoryGrid、InventoryGridTest，并把 Bag 页替换为固定背包网格 | T45-T48 | done |
| 2026-06-26 | 完成基于 nvg scissor 的 ScrollView、ScrollViewTest，并把 Bag 页改为可滚动背包 demo | T49-T52 | done |
| 2026-06-26 | 增强 Panel scroll 内容区，补充 ScrollView 透明输入层，并把 UserTestDemo 调整为固定 Tabs + 滚动 body | T53 | done |
| 2026-07-02 | 完成 Checkbox、CheckboxControlTest，并把 Tune 页补充为 Toggle + Checkbox + Select + Slider + TextInput 的表单测试面板 | T54-T56 | done |

## 阻塞项

当前无阻塞项。

潜在阻塞：

- Dora CLI 服务不可用时，先用 `dora cli doctor --fix` 恢复本地服务。
- 如果 `PaintNode` 直接 nvg 绘制需要额外坐标转换 helper，应先在 T06 内解决，避免污染后续组件。
- 如果 TSX provider 栈在 DoraX 动态 diff 下不稳定，T04 允许退化为根级模块 context。
