# UIX MVP Scope

本文定义 `Assets/Script/Lib/UIX/` 的第一轮开发范围。目标是先做出一条可验证的动态 TSX 游戏 HUD 路径，而不是一次性铺完整组件库。

## 首版目标

- 建立 `UIX` 命名空间、目录结构和导出入口。
- 打通 `AlignNode layout -> PaintNode -> nvg painter -> interaction state` 的基础链路。
- 验证 DoraX 动态 root、signal、keyed diff、`align-node.style` patch 和普通 `Node` 直接 nvg 绘制可以稳定组合。
- 产出一个可以在引擎里运行的 HUD demo，覆盖布局、状态更新、输入反馈、焦点环和卸载清理。

## 首版组件

### Foundation

| 组件 | 首版能力 |
| --- | --- |
| `PaintNode` | 普通 `Node` render 回调直接调用 nvg painter |
| `Text` | 短文本 `Label` 封装 |
| `Icon` | 支持内置 nvg painter icon 和 Sprite icon 插槽 |
| `FocusRing` | 根据 focus/disabled 状态绘制焦点环 |

### Layout

| 组件 | 首版能力 |
| --- | --- |
| `Box` | `align-node` 薄封装，透传 `style` |
| `Row` | `flexDirection: "row"` |
| `Column` | `flexDirection: "column"` |
| `Stack` | 绝对定位叠层 |
| `Spacer` | `flexGrow` 占位 |
| `Panel` | 面板背景、标题、内容区域 |

### Controls

| 组件 | 首版能力 |
| --- | --- |
| `Button` | label/icon/loading/disabled，tap 输入，pressed/focused 状态 |
| `IconButton` | icon-only 按钮，selected 状态 |
| `ProgressBar` | value/max，水平进度和文本插槽 |

### Second Round Controls

| 组件 | 当前能力 |
| --- | --- |
| `Toggle` | checked/unchecked/disabled，tap 后通过 `onChange` 输出新值 |
| `Slider` | value/min/max/step，tap/drag 位置换算，`showValue` 文本 |
| `Tabs` | keyed item 渲染，selected/disabled item，选择变更 |

### Game

| 组件 | 首版能力 |
| --- | --- |
| `HealthBar` | value/max，危险阈值，延迟扣血视觉预留 |
| `ResourceCounter` | icon + 数值，短动画预留 |
| `CooldownButton` | icon、hotkey、cooldown/maxCooldown、禁用态 |
| `ItemSlot` | icon、品质边框、数量、selected/disabled/cooldown |
| `InventoryGrid` | 固定行列、empty slot、selectedId、稳定 item key |
| `ScrollView` | 固定 viewport、nvg scissor 裁剪、wheel/drag 滚动 |

## 明确不做

- 首版不做 `VirtualList`、拖放、复杂背包操作、`TextInput`、`Select`、`RadialMenu`。
- 首版不做完整图标库，只实现 8-12 个基础 nvg 图标：play、close、gear、coin、heart、mana、lock、check、warning、arrow。
- 首版不做多套完整主题，只实现默认 Dora Prism，并保留 Fantasy/SciFi token 扩展点。
- 首版不把 painter 自动缓存进 `VGNode`。
- 首版不做完整无障碍系统，只保证焦点环、disabled 对比和手柄/键盘最小导航接口。

## MVP Demo

建议 demo 文件：

```text
/Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/HudDemo.tsx
```

画面内容：

- 顶部左侧：`HealthBar` + `ResourceCounter`。
- 底部右侧：`Panel` 包裹三个 `CooldownButton`。
- 中央：一个 `Button` 打开/关闭设置 `Panel`。
- 右侧：一条简单 Toast 或状态文本，用于显示按钮点击次数。

动态行为：

- `signal` 每秒改变血量或冷却进度。
- 点击按钮切换设置面板显示，验证 DoraX diff 和 `key`。
- 动态修改一个 `Row` 或 `Panel` 的 `style.width`，验证 `align-node.style` patch。
- 组件 unmount 后不再响应输入、不再保留 render/update 回调。

## 验收标准

- `/Users/Jin/Workspace/Dora/Dora-Example/Test/UIX/run-all.zsh` 可以编译组件库、demo 和 marker 测试。
- demo TSX 可以编译并在引擎中运行。
- 运行时没有为普通按钮、进度条、焦点环创建 `VGNode`。
- 修改 signal 后 UI 更新，不重建整个根节点。
- `align-node.style` 动态变化会重新布局。
- `Button` 至少覆盖 idle、pressed、focused、disabled 四种视觉状态。
- `CooldownButton` 的遮罩和数字随时间变化。
- 移除 demo 根节点后，组件 render/update/input 回调清理干净。

## 后续扩展

第二轮已补齐 `Tabs`、`Slider`、`Toggle`，第三轮已补齐轻量 `Tooltip`、`ToastStack`、`Modal`，第四轮已补齐固定格子的 `ItemSlot`、`InventoryGrid`，第五轮补齐基于 nvg scissor 的基础 `ScrollView`。后续再加入 `UiProvider`、`ThemeScope`、`VirtualList`。这些组件依赖更完整的主题作用域、焦点管理和虚拟化行为，不适合压进 MVP。
