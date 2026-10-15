# UIX Validation Plan

本文定义 UIX 开发过程中的验证范围、demo、命令和通过标准。UIX 属于动态 TSX + 引擎渲染路径，不能只做静态类型检查。

## 验证目标

- 组件库 TS/TSX 可以通过 Dora CLI 编译。
- demo 在 Dora 引擎内运行，能看到 nvg 直接绘制的 UI。
- DoraX `signal` 更新能驱动 UI diff。
- `align-node.style` 动态 patch 能触发布局更新。
- 普通组件默认不创建 `VGNode`。
- 输入、焦点、disabled 和 unmount 清理符合文档契约。

## 建议目录

```text
/Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/
  HudDemo.tsx
  UserTestDemo.tsx
  ConditionalPanelKeyTest.tsx
  LayoutPatchTest.tsx
  InteractionStateTest.tsx
  OverlayComponentsTest.tsx
  InventoryGridTest.tsx
  PanelScrollTest.tsx
  ScrollViewTest.tsx
  SecondaryControlsTest.tsx
  TextOverlayRegressionTest.tsx
  UnmountCleanupTest.tsx
  run-all.zsh
  run-user-demo.zsh
```

如果仓库后续恢复 `Test/DoraX/` 一类测试目录，也可以放到：

```text
Test/UIX/
```

本轮可运行 TSX demo 和 marker 测试放在 `/Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/`，方便作为示例项目运行。

## 编译验证

基础命令：

```bash
find /Users/Jin/Workspace/Dora-SSR/Assets/Script/Lib/UIX \
  -type f \( -name '*.ts' -o -name '*.tsx' \) \
  -exec dora cli build -f {} \;
dora cli build -f /Users/Jin/Workspace/Dora-SSR/Assets/Script/Lib/UIX.ts
```

demo 编译：

```bash
dora cli build -f /Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/HudDemo.tsx
```

通过标准：

- TSX 源保留为测试入口。
- 生成 Lua 只是运行产物，不作为手写测试源。
- 编译不能引入 UIX 外的循环依赖。

## 引擎内 Demo

### HudDemo

目的：

- 验证首版组件组合。
- 验证普通 `Node` + nvg painter 可见。
- 验证 signal 更新和用户输入。

画面：

- 顶部左侧 `HealthBar`。
- 顶部右侧 `ResourceCounter`。
- 底部右侧 `Panel` + 三个 `CooldownButton`。
- 中央 `Button` 控制设置面板开关。

交互：

- 点击按钮切换设置面板。
- 冷却按钮在 cooldown 为 0 时可触发计数。
- 每秒血量或资源变化一次。

通过标准：

- UI 非空白。
- 按钮 pressed 状态可见。
- 冷却遮罩随 signal 变化。
- 设置面板显示/隐藏不重建整个 root。
- 设置面板关闭后，`Skills` 面板仍保持原位置和原节点身份，不能被 patch 到 `Settings` 面板位置。

### UserTestDemo

目的：

- 提供给开发者和设计验收使用的手动交互 demo。
- 把首批和第二批控件放在同一屏，覆盖普通点击、受控值、tab 切换、条件面板、冷却状态和资源变化。

画面：

- 顶部 `HealthBar`、`ProgressBar`、`ResourceCounter`。
- 左侧 `Panel` 包含 `Tabs`，切换 Combat、Bag、Tune 三类内容。
- 左侧 `Panel` 的标题和 Tabs 固定，当前 tab body 使用 `ScrollView`，切换 tab 时 body scroll key 随 tab id 变化，避免继承上一个页签的滚动 offset。
- Combat 页覆盖 `CooldownButton`、伤害、治疗。
- Bag 页覆盖 `InventoryGrid`、资源数值和禁用按钮。
- Tune 页覆盖 `Toggle`、`Slider` 和动态 panel 宽度。
- 右下角 `Status` 面板显示最近操作。

运行：

```bash
/Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/run-user-demo.zsh
```

通过标准：

- demo 可编译并启动。
- 点击按钮、切换 tab、拖动 slider、切换 toggle 后 UI 状态同步变化。
- 条件面板开关不影响右下角状态面板位置。
- 冷却遮罩和数字只显示一套，不遮挡其他读数。
- Bag 页 item 选择、数量变化和 cooldown slot 视觉可读。
- Bag 页可以在 Panel 内滚动，滚动后切换 Combat/Bag/Tune 不应造成 Tabs 位置漂移或内容使用旧滚动 offset。

### ConditionalPanelKeyTest

目的：

- 验证条件兄弟节点关闭后，后续 keyed 面板不会被 DoraX 错误复用到前一个条件节点的位置。
- 固化 UIX demo 中 `settings-panel` / `skills-panel` 的 key 使用约定。

通过标准：

- 初始 `Settings` 和 `Skills` 面板都能 mount。
- 关闭 `Settings` 后，`settingsRef.current` 被清空。
- `skillsRef.current` 仍然等于关闭前的同一个节点。

### LayoutPatchTest

目的：

- 验证 `align-node.style` 动态 patch 会随 signal 触发 DoraX rerender。
- 验证动态 style 更新时复用原 `AlignNode`，不把节点重建成新实例。

场景：

- 一个 `align-node` 的 width 在 220 和 420 之间切换。
- signal 更新后检查 root render 计数增加。
- 检查 ref 指向同一个 `AlignNode` 实例。

通过标准：

- signal 更新后完成 rerender。
- 不触发 `align-node` host 重建，除非 `windowRoot` 改变。
- marker 文件记录 `passed`。

说明：CLI marker runner 不保证执行渲染 `visit()`，不能稳定读取 Yoga 布局后的 `width/height`。实际尺寸变化由 `HudDemo` 手动视觉 QA 覆盖。

### InteractionStateTest

目的：

- 验证 `Button` / `IconButton` / `CooldownButton` 的状态机。

场景：

- 调用组件暴露的内部测试 hook 或模拟 tap 回调。
- 依次切换 disabled、pressed、focused、selected。

通过标准：

- disabled 状态不触发 `onClick`。
- pressed 在结束或 unmount 后清除。
- focused 时 `FocusRing` active。

### SecondaryControlsTest

目的：

- 验证第二批通用控件 `Toggle`、`Slider`、`Tabs` 可以和 DoraX 动态 TSX root 组合。
- 验证受控组件事件只输出业务值，不在组件内部隐式持久化业务状态。

场景：

- `Toggle` 初始为 false，模拟 tap 后收到 true。
- `Tabs` 初始选中 `bag`，模拟点击第二个 tab 后收到 `gear`。
- `Slider` 以受控 value 渲染，编译和挂载通过；无触点输入时不改变业务值。

通过标准：

- marker 文件记录 `passed`。
- disabled 或无触点路径不产生错误事件。
- tab item 使用稳定 key，不依赖 sibling 位置复用。

### OverlayComponentsTest

目的：

- 验证轻量 overlay 组件 `Tooltip`、`ToastStack`、`Modal` 可以在同一 root 中组合。
- 验证 `Modal` 背景点击会发出关闭请求。

场景：

- 挂载一个 `Tooltip`。
- 挂载两个 toast item，检查列表子节点数量。
- 挂载打开状态的 `Modal`，模拟背景 tap。

通过标准：

- `Tooltip`、`ToastStack`、`Modal` 都能 mount。
- `ToastStack` 使用稳定 key 渲染两个 item。
- `Modal` 背景 tap 触发一次 `onClose`，并由调用者 signal 关闭。
- marker 文件记录 `passed`。

### InventoryGridTest

目的：

- 验证 `ItemSlot` 和 `InventoryGrid` 的固定网格、稳定 key、选择变更和 reorder 行为。

场景：

- 挂载 3 列 2 行网格。
- 点击第二个 item，检查 `selectedId` 更新。
- 删除第一个 item、插入新 item，并保留已选 item id。

通过标准：

- 网格渲染指定行列。
- item 使用稳定 id key，reorder 后不会错选或错位。
- marker 文件记录 `passed`。

### ScrollViewTest

目的：

- 验证 `ScrollView` 可以登记 nvg 裁剪区域，并通过 wheel 事件更新垂直 offset。

场景：

- 挂载固定宽高的 `ScrollView` 和超过 viewport 高度的文本内容。
- 模拟 mouse wheel，检查 `onScroll` 输出 offset。
- 再次模拟超大滚动，检查 offset clamp 到 `contentHeight - height`。

通过标准：

- `ScrollView` root 和 content wrapper 正常 mount。
- wheel 事件触发 offset 更新。
- offset 不超过最大滚动范围。
- marker 文件记录 `passed`。

### PanelScrollTest

目的：

- 验证 `Panel scroll=true` 会把内容区接入 `ScrollView`，并能转发滚动 offset。

场景：

- 挂载固定宽高的 `Panel`，启用 `scroll` 并设置 `scrollContentHeight`。
- 在 Panel 内容区放入超出高度的文本和按钮。
- 对 Panel 内部滚动节点模拟 mouse wheel。

通过标准：

- Panel、header 和滚动内容区正常 mount。
- wheel 事件触发 `onScroll`。
- marker 文件记录 `passed`。

### UnmountCleanupTest

目的：

- 验证 root unmount 清理。

场景：

- 挂载包含 `PaintNode` 的 UI root。
- 确认绘制节点完成 mount。
- `root.unmount()`。
- 再更新 signal。

通过标准：

- unmount 后 host children 被清空。
- signal 更新不再调度该 root。
- marker 文件记录 `passed`。

## Marker 文件约定

测试使用 `Content.save()` 写 marker：

```text
<writable>/uix/<test-name>.result
```

内容：

```text
running
passed
failed:<reason>
```

runner 等待 marker 从 `running` 变为 `passed` 或 `failed:*`。这比单纯 tail log 更稳定。

## run-all.zsh

runner 职责：

1. 清理旧 marker。
2. 编译每个 TSX 测试。
3. 在 Dora 中运行生成 Lua。
4. 等待 marker。
5. 输出通过/失败汇总。

伪命令：

```bash
#!/usr/bin/env zsh
set -euo pipefail

dora cli build -f "/Users/Jin/Workspace/Dora-SSR/Assets/Script/Lib/UIX.ts"
find /Users/Jin/Workspace/Dora-SSR/Assets/Script/Lib/UIX \
  -type f \( -name '*.ts' -o -name '*.tsx' \) \
  -exec dora cli build -f {} \;
dora cli build -f "$PWD/Test/UIX/HudDemo.tsx"
dora cli build -f "$PWD/Test/UIX/ConditionalPanelKeyTest.tsx"
dora cli build -f "$PWD/Test/UIX/LayoutPatchTest.tsx"
dora cli build -f "$PWD/Test/UIX/InteractionStateTest.tsx"
dora cli build -f "$PWD/Test/UIX/OverlayComponentsTest.tsx"
dora cli build -f "$PWD/Test/UIX/SecondaryControlsTest.tsx"
dora cli build -f "$PWD/Test/UIX/UnmountCleanupTest.tsx"
dora cli build -f "$PWD/Test/UIX/UserTestDemo.tsx"
```

实际 runner 位于 `/Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/run-all.zsh`，会检查 Dora 编译日志中的 `[error] Compiling error`，再逐个运行 marker 测试。

## 手动视觉 QA

每次首版 UI 变化至少检查：

- 720p、1080p、窗口 resize。
- 深色背景和明亮游戏背景上是否可读。
- 字体是否清晰。
- focus ring 是否在按钮、技能按钮、面板中不被遮挡。
- disabled 与 enabled 对比是否足够。
- `CooldownButton` 数字不溢出。

## 性能观察

首版不设硬性 FPS 指标，但需要观察：

- 30 个按钮同时显示时无明显卡顿。
- 30 个 `CooldownButton` 每帧更新时没有大量分配或节点重建。
- 没有因普通组件创建 `VGNode` 产生 framebuffer/texture 增长。

## 回归清单

每次改 `PaintNode`、`Interaction`、`FocusManager` 或 `theme` 后，至少跑：

- UIX lib build。
- `HudDemo`。
- `LayoutPatchTest`。
- `ScrollViewTest`。
- `UnmountCleanupTest`。

每次改 DoraX runtime 后，除了 UIX 测试，还应跑 DoraX 既有动态 TSX 回归测试，尤其是 signal、root unmount、action lifecycle 和 physics nodes。

## 交付标准

首版代码可以合并的最低标准：

- 文档中的 MVP 组件全部实现。
- `Test/UIX/run-all.zsh` 编译阶段通过。
- HUD demo 可运行且非空白。
- marker 测试全部 `passed`。
- 没有手写修改生成 Lua 作为源文件。
- `git diff --check` 通过。
