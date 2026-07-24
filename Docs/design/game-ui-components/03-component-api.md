# UIX Component API

本文定义 `Assets/Script/Lib/UIX/` 首版组件的 API 契约。实现时优先保证这里列出的 props、默认值、事件和行为，不额外扩展复杂能力。

## 通用类型

```ts
import type * as Dora from "Dora";

type AlignStyle = JSX.AlignStyle;
type NodeRef<T extends Dora.Node.Type = Dora.Node.Type> = JSX.Ref<T>;

type UiSize = "sm" | "md" | "lg";
type UiVariant =
  | "default"
  | "primary"
  | "secondary"
  | "danger"
  | "ghost"
  | "glass";

type UiIcon =
  | string
  | {
      kind: "sprite";
      file: string;
    }
  | {
      kind: "painter";
      name: string;
    };

type UiChildren = JSX.Element | JSX.Element[] | string | number | undefined;
```

首版约定：

- `style` 只传给最外层 `align-node`。
- `className`、CSS selector、DOM event 名称不进入首版 API。
- 事件名使用游戏语义：`onClick`、`onSelect`、`onValueChange`、`onOpenChange`。
- 组件不接收任意 `AnyTable` 透传到底层 Dora 节点，避免 API 表面失控。

## 通用 Props

```ts
interface UiNodeProps {
  key?: string | number;
  ref?: NodeRef;
  style?: AlignStyle;
  visible?: boolean;
  opacity?: number;
  disabled?: boolean;
  testId?: string;
  children?: UiChildren;
}
```

规则：

- `key` 是动态 UI 身份，不是装饰字段。条件显示、插入、删除、排序的同级组件必须提供稳定 `key`。
- 同级中存在多个同类型组件时，如果其中一个会被条件移除，后续同类型兄弟节点也要加 `key`，避免 DoraX 按下标复用错误节点。
- `visible === false` 仍可保留布局，除非组件文档另写 `display: "none"`。
- `disabled` 会传递到交互状态，但不会自动传给所有子组件；容器类组件需要显式说明是否 cascade。
- `testId` 首版只用于调试和验证，不暴露给 Dora 原生节点 tag，除非验证工具需要。

## Context

首版不提供 JSX provider 组件，避免在 DoraX 动态 diff 下引入还没有验证过的栈式 context 生命周期。主题和输入模式由模块级 context 管理，组件默认读取当前 context。

```ts
function getUiContext(): UiContext;
function setUiTheme(theme: Theme): void;
function setInputMode(inputMode: InputMode): void;
function resetUiContext(): void;
```

默认值：

| 字段 | 默认 |
| --- | --- |
| `theme` | `defaultTheme` |
| `inputMode` | `"pointer"` |
| `focusManager` | `defaultFocusManager` |

行为：

- 不创建额外视觉节点。
- 适合首版全局 HUD 主题。
- `UiProvider` 和 `ThemeScope` 作为第二阶段 API 预留。

## Foundation

### PaintNode

```ts
interface PaintNodeProps extends UiNodeProps {
  width?: number;
  height?: number;
  painter: Painter;
  state?: Partial<InteractionState>;
  data?: unknown;
  onMountNode?: (this: void, node: Dora.Node.Type) => void;
}
```

行为：

- 创建普通 `Node`，不创建 `VGNode`。
- 使用 `onRender` 调用 `painter(ctx)`。
- `width` / `height` 未传入时由父组件通过 `onLayout` 同步。
- `disabled` 只影响 painter state，不自动关闭 render。
- `PaintNode` 不会自动生成默认 key。固定默认 key 会在同一父节点下产生重复 key，导致 DoraX keyed diff 把背景、文字、图标和焦点 painter 互相复用。只有条件显示、插入、删除或排序的同级绘制节点才应由组件作者传入业务稳定 key。

### Text

```ts
interface TextProps extends UiNodeProps {
  text?: string | number;
  fontName?: string;
  fontSize?: number;
  color?: number;
  alignment?: Dora.TextAlign;
  verticalAlign?: "top" | "center" | "bottom";
  wrap?: boolean;
  lineHeight?: number;
  sdf?: boolean;
  smoothLower?: number;
  smoothUpper?: number;
}
```

默认值：

| Prop | 默认 |
| --- | --- |
| `fontName` | theme font |
| `fontSize` | `theme.font.size.md` |
| `color` | `theme.colors.text.primary` |
| `alignment` | `Dora.TextAlign.Center` |
| `verticalAlign` | `"center"` |
| `wrap` | `false` |
| `lineHeight` | `fontSize * 1.25` |
| `sdf` | theme font sdf |

行为：

- UIX 内部文字统一使用 nvg 的 `CreateFont` / `FontFaceId` / `Text` 渲染，不使用 Dora `Label`。
- Dora `Label` 属于普通场景节点渲染层，而 nvg 在独立层渲染；组件背景、图标、文本必须在同一 nvg UI 层里才能保证按钮、面板和浮层的遮挡关系正确。
- `sdf`、`smoothLower`、`smoothUpper` 保留在 API 中用于后续字体策略兼容，但当前 nvg 文本路径不消费这些参数。
- `children` 为字符串或数字时拼到 `text` 后。
- `\n` 总是作为显式换行处理。TSX 字符串属性里的 `\n` 是字面量反斜杠字符；需要真实换行时使用表达式字符串，例如 `text={"A\nB"}`。
- `wrap=false` 时只按 `\n` 分行，不做自动宽度换行。
- `wrap=true` 时先按 `\n` 分段，再按当前节点宽度和 nvg 实测文字宽度进行短文本换行；这是 tooltip、按钮说明等短 UI 文案的换行能力，不替代后续富文本/长文本组件。
- 未显式设置高度时，默认高度会按显式换行行数估算；自动 wrap 后的最终行数仍以渲染时节点宽度为准，复杂长文本应由调用方提供稳定高度或放入滚动容器。

### Icon

```ts
interface IconProps extends UiNodeProps {
  icon: UiIcon;
  size?: number;
  color?: number;
  disabledColor?: number;
}
```

行为：

- `string` 默认按内置 nvg icon 名称查找。
- `{kind: "sprite"}` 使用 `sprite` 节点。
- `{kind: "painter"}` 使用 `PaintNode`。
- 找不到 icon 时绘制一个调试占位，不抛异常。

### FocusRing

```ts
interface FocusRingProps extends UiNodeProps {
  active: boolean;
  radius?: number;
  inset?: number;
  color?: number;
}
```

行为：

- 使用 `PaintNode` 绘制。
- `active === false` 时保留节点但不绘制，避免布局变化。

## Layout

### Box

```ts
interface BoxProps extends UiNodeProps {
  onLayout?: (this: void, width: number, height: number) => void;
}
```

行为：

- 渲染一个 `align-node`。
- `style` 原样传入；组件不合并默认 `width` / `height`。

### Row / Column

```ts
interface FlexProps extends BoxProps {
  gap?: number;
  align?: JSX.StyleAlign;
  justify?: JSX.StyleJustifyContent;
}
```

默认值：

| Component | 默认 style |
| --- | --- |
| `Row` | `flexDirection: "row"` |
| `Column` | `flexDirection: "column"` |

行为：

- `gap`、`align`、`justify` 会合并到 `style`。
- 用户传入 `style.flexDirection` 可以覆盖默认方向，但不推荐。

### Stack

```ts
interface StackProps extends BoxProps {
  clip?: boolean;
}
```

行为：

- 默认 `position: "relative"`。
- 子元素通常使用 absolute style。
- `clip` 是预留 API；当前不要依赖 Yoga/Node 级裁剪。需要裁剪 UIX nvg 绘制内容时使用 `ScrollView`。

### ScrollView

```ts
interface ScrollViewProps extends UiNodeProps {
  width?: number;
  height?: number;
  contentHeight: number;
  offsetY?: number;
  wheelSpeed?: number;
  inputOverlay?: boolean;
  onScroll?: (this: void, offsetY: number) => void;
}
```

默认值：

| Prop | 默认 |
| --- | --- |
| `width` | `style.width ?? 240` |
| `height` | `style.height ?? 160` |
| `wheelSpeed` | `24` |
| `inputOverlay` | `true` |

行为：

- 渲染固定 viewport 的 `align-node`，内部 content 通过 Dora 节点坐标 `y=offsetY` 滚动。不要把 DOM/CSS 的 `translateY(-offset)` 直觉套到 Dora UI 坐标上。
- 裁剪不使用 Node clip、Yoga `overflow` 或 `VGNode`；`ScrollView` 只登记 viewport，子级 UIX `PaintNode` 在自己的 `onRender` 中应用祖先 nvg scissor。
- 因为裁剪发生在 UIX `PaintNode` 的 nvg 绘制路径，`ScrollView` 只保证裁剪 UIX 矢量组件和 nvg 文本；普通 Dora `Label`、`Sprite` 或第三方节点不属于该裁剪契约。
- `offsetY` 传入时为受控模式；未传入时组件维护本地滚动值。
- wheel 和拖动都会 clamp 到 `[0, contentHeight - height]`，并通过 `onScroll` 输出当前 offset。
- mouse wheel 使用 Dora `MouseWheel` 的正 `delta.y` 增加 offset；拖拽使用按下时的初始 offset 和累计 y 位移，向上拖增加 offset，向下拖减少 offset。
- 默认会在 content 上方创建一个透明输入层接收实际 mouse wheel 和 drag，避免滚动事件只落到子按钮或道具格上导致父滚动容器收不到。
- `ScrollView` 会把 viewport 尺寸同步到根节点和透明输入层的 Dora `node.size`。真实 mouse wheel hit-test 使用的是 Dora Node size，不是 Yoga style size；不能只设置 `style.width/height`。
- content wrapper 会保留 AlignNode/Yoga 算出的横向位置，只在 Yoga 基准 `y` 上叠加滚动 offset，并同步 `size`。不要强制写入 `x=0`，否则会破坏 AlignNode 的横向布局。
- 当前版本只支持垂直滚动和固定 `contentHeight`；动态内容测量、滚动条、惯性和虚拟列表留给后续版本。

### Spacer

```ts
interface SpacerProps {
  flex?: number;
  width?: number;
  height?: number;
}
```

行为：

- 渲染一个无视觉 `align-node`。
- 默认 `flex: 1`。

### Panel

```ts
interface PanelProps extends UiNodeProps {
  title?: string;
  variant?: "default" | "glass" | "solid";
  padding?: number;
  headerHeight?: number;
  elevated?: boolean;
  scroll?: boolean;
  scrollContentHeight?: number;
  scrollWheelSpeed?: number;
  onScroll?: (this: void, offsetY: number) => void;
}
```

默认值：

| Prop | 默认 |
| --- | --- |
| `variant` | `"default"` |
| `padding` | `theme.space[4]` |
| `headerHeight` | `title ? 36 : 0` |
| `elevated` | `true` |
| `scroll` | `false` |

结构：

```text
AlignNode(panel)
  PaintNode(panel background)
  AlignNode(header optional)
    Text(title)
  AlignNode(content) or ScrollView(content-scroll)
    children
```

行为：

- `scroll=true` 时，Panel 内容区会使用 `ScrollView` 包裹 children，超出 content viewport 的 UIX nvg 内容被裁剪，并可用 wheel/drag 滚动。
- content viewport 从数值型 `style.width` / `style.height`、`padding` 和 `headerHeight` 计算。需要 Panel 滚动时应给 Panel 明确数值宽高。
- `scrollContentHeight` 描述 children 的内容高度；未传入时按 viewport 高度处理，不产生可滚动范围。
- `scroll=true` 会滚动整个 Panel content。若面板内有固定 `Tabs`、工具栏或页签导航，应将这些固定控件放在普通 Panel content 中，再由调用方对页签 body 单独使用 `ScrollView`，并用业务 key 在切换页签时重置滚动 offset。
- Panel 滚动仍然遵循 `ScrollView` 的裁剪限制：只保证裁剪 UIX `PaintNode`/nvg 文本路径，不裁剪普通 Dora `Label`、`Sprite` 或第三方节点。

## Controls

### Button

```ts
interface ButtonProps extends UiNodeProps {
  variant?: UiVariant;
  size?: UiSize;
  icon?: UiIcon;
  iconPosition?: "left" | "right";
  loading?: boolean;
  selected?: boolean;
  focusable?: boolean;
  swallowTouches?: boolean;
  onClick?: (this: void) => void;
}
```

默认值：

| Prop | 默认 |
| --- | --- |
| `variant` | `"primary"` |
| `size` | `"md"` |
| `iconPosition` | `"left"` |
| `loading` | `false` |
| `selected` | `false` |
| `focusable` | `true` |
| `swallowTouches` | `true` |

行为：

- `disabled || loading` 时不触发 `onClick`。
- `pressed` 只影响视觉和 1-2px 内容偏移，不改布局尺寸。
- `children` 为按钮文本；`children` 缺省且无 icon 时仍绘制最小按钮。
- 通过 `FocusManager.activate()` 触发同一套 `onClick`。

### IconButton

```ts
interface IconButtonProps extends Omit<ButtonProps, "children" | "iconPosition"> {
  icon: UiIcon;
  label?: string;
}
```

行为：

- `label` 用于 tooltip 或可访问名称，首版不直接显示。
- 默认宽高来自 size token，推荐正方形。

### ProgressBar

```ts
interface ProgressBarProps extends UiNodeProps {
  value: number;
  max?: number;
  min?: number;
  variant?: "health" | "mana" | "shield" | "neutral" | "warm";
  showValue?: boolean;
  animated?: boolean;
}
```

默认值：

| Prop | 默认 |
| --- | --- |
| `min` | `0` |
| `max` | `1` |
| `variant` | `"neutral"` |
| `showValue` | `false` |
| `animated` | `true` |

行为：

- progress = clamp((value - min) / (max - min), 0, 1)。
- `animated` 首版可以先只作为 painter 插值预留，实际可直接跳变。

### Toggle

```ts
interface ToggleProps extends UiNodeProps {
  checked: boolean;
  label?: string;
  focused?: boolean;
  onChange?: (this: void, checked: boolean) => void;
}
```

行为：

- `checked` 是受控值，组件不在内部持久化业务状态。
- tap 成功时触发 `onChange(!checked)`。
- `disabled` 时不触发 `onChange`，并降低轨道和旋钮对比。
- `label` 显示在开关右侧，不参与命中区域尺寸计算。

### Checkbox

```ts
interface CheckboxProps extends UiNodeProps {
  checked: boolean;
  indeterminate?: boolean;
  label?: string;
  focused?: boolean;
  onChange?: (this: void, checked: boolean) => void;
}
```

行为：

- `checked` 是受控值，组件不在内部持久化业务状态。
- `indeterminate` 只影响视觉，tap 成功时仍触发 `onChange(!checked)`。
- `disabled` 时不触发 `onChange`，并降低方框、勾选和文字对比。
- `label` 显示在方框右侧，不参与方框命中区域尺寸计算。

### Slider

```ts
interface SliderProps extends UiNodeProps {
  value: number;
  min?: number;
  max?: number;
  step?: number;
  showValue?: boolean;
  valueWidth?: number;
  onValueChange?: (this: void, value: number) => void;
}
```

默认值：

| Prop | 默认 |
| --- | --- |
| `min` | `0` |
| `max` | `1` |
| `showValue` | `false` |
| `valueWidth` | `showValue ? 42 : 0` |

行为：

- `value` 是受控值，显示前 clamp 到 `[min, max]`。
- tap/drag 根据触点 x 坐标换算新值，并通过 `onValueChange` 输出。
- `step > 0` 时按步长四舍五入。
- `showValue` 为 true 时，右侧预留 `valueWidth` 显示数值，滑块轨道和 knob 不进入数值区域。
- `disabled` 时不响应输入。

### Tabs

```ts
interface TabItem {
  id: string;
  label: string;
  disabled?: boolean;
}

interface TabsProps extends UiNodeProps {
  items: TabItem[];
  value: string;
  onValueChange?: (this: void, value: string) => void;
}
```

行为：

- `value` 是当前选中的 item id。
- 每个 tab item 必须使用稳定 `id`，组件内部把它作为 DoraX `key`。
- 点击未选中的可用 tab 时触发 `onValueChange(item.id)`。
- `props.disabled` 或 `item.disabled` 为 true 时，对应按钮不触发事件。

## Game Components

### HealthBar

```ts
interface HealthBarProps extends Omit<ProgressBarProps, "variant"> {
  dangerThreshold?: number;
  delayedValue?: number;
}
```

默认值：

| Prop | 默认 |
| --- | --- |
| `dangerThreshold` | `0.3` |
| `delayedValue` | `undefined` |

行为：

- progress 低于阈值时使用 danger token。
- `delayedValue` 用于后续扣血残影，首版可不实现动画。

### ResourceCounter

```ts
interface ResourceCounterProps extends UiNodeProps {
  icon?: UiIcon;
  value: number | string;
  prefix?: string;
  suffix?: string;
  variant?: "default" | "warm" | "success" | "danger";
}
```

行为：

- 只负责短数字展示。
- 数值格式化由调用者负责，组件只拼接 prefix/value/suffix。

### CooldownButton

```ts
interface CooldownButtonProps extends IconButtonProps {
  cooldown: number;
  maxCooldown: number;
  hotkey?: string;
  count?: number;
  onCast?: (this: void) => void;
}
```

行为：

- `cooldown > 0` 时使用 disabled 视觉和输入语义，并且默认不触发 `onCast`。
- 冷却遮罩 progress = clamp(cooldown / maxCooldown, 0, 1)。遮罩必须比 disabled 底色更亮，避免只显示成一块黑底。
- `hotkey` 绘制在右上或左下角，必须不影响按钮命中区域。
- `count` 绘制在右下角，0 或 undefined 时隐藏。

### ItemSlot

```ts
interface ItemSlotProps extends UiNodeProps {
  id?: string;
  icon?: UiIcon;
  quality?: "empty" | "common" | "rare" | "epic" | "legendary";
  count?: number;
  selected?: boolean;
  cooldown?: number;
  maxCooldown?: number;
  onClick?: (this: void, id?: string) => void;
}
```

行为：

- `icon` 为空时渲染 empty slot，不响应点击。
- `quality` 控制边框和内层 tint；empty/common/rare/epic/legendary 必须有可区分色。
- `count > 1` 时在右下角显示短数字。
- `selected` 使用主强调色边框，不改变 slot 尺寸。
- `cooldown/maxCooldown` 复用 `CooldownButton` 的亮色遮罩，但不负责技能释放逻辑。

### InventoryGrid

```ts
interface InventoryItem {
  id: string;
  icon?: UiIcon;
  quality?: ItemQuality;
  count?: number;
  disabled?: boolean;
  cooldown?: number;
  maxCooldown?: number;
}

interface InventoryGridProps extends UiNodeProps {
  items: InventoryItem[];
  columns: number;
  rows?: number;
  slotSize?: number;
  gap?: number;
  selectedId?: string;
  onSelect?: (this: void, id: string) => void;
}
```

行为：

- 首版为固定行列网格，不包含滚动和虚拟化。
- 每个 item 使用 `id` 作为稳定 key；空格子使用 `empty-index` key。
- `selectedId` 由调用者持有，组件只负责视觉和 `onSelect` 输出。
- 删除、插入或排序 item 后，已有 item 不应复用到错误 slot painter。

## Overlay Components

### Tooltip

```ts
interface TooltipProps extends UiNodeProps {
  title?: string;
  text?: string;
  width?: number;
}
```

行为：

- 用于短说明，不吞触摸，不负责 hover 触发逻辑。
- 正文 `text` 默认使用 `Text wrap` 并按内容估算面板高度，避免短说明溢出面板。
- 调用者通过 `visible`、条件渲染或 signal 控制显示。
- 默认绝对定位，位置由 `style.left/top/right/bottom` 决定。

### ToastStack

```ts
interface ToastItem {
  id: string | number;
  title?: string;
  message: string;
  variant?: UiVariant;
}

interface ToastStackProps extends UiNodeProps {
  items: ToastItem[];
  width?: number;
  maxVisible?: number;
}
```

行为：

- `items` 使用稳定 `id` 作为 key。
- 默认显示右上角，调用者可通过 `style` 改位置。
- 首版只渲染静态列表，不内置队列生命周期和自动消失计时器。

### Modal

```ts
interface ModalAction {
  id: string;
  label: string;
  variant?: "primary" | "secondary" | "danger" | "ghost";
  disabled?: boolean;
}

interface ModalProps extends UiNodeProps {
  open: boolean;
  title?: string;
  message?: string;
  width?: number;
  height?: number;
  backdropColor?: number;
  backdropOpacity?: number;
  closeOnBackdrop?: boolean;
  actions?: ModalAction[];
  onClose?: (this: void) => void;
  onAction?: (this: void, id: string) => void;
}
```

行为：

- `open=false` 时不渲染。
- 默认尺寸较紧凑，`width=320`、`height=188`；复杂内容由调用者显式传入更大尺寸。
- backdrop 是 modal 窗体背后的全屏黑色半透明屏幕遮罩 overlay，`backdropColor` / `backdropOpacity` 可覆盖。
- UIX 颜色数值使用 Dora 原生 `AARRGGBB` 格式；例如半透明黑色应由 `withAlpha(0xff000000, opacity)` 生成，而不是 `0x000000ff`。
- `Modal` 自身是 `windowRoot` overlay，应通过单独 root 直接渲染到 `Director.ui`，避免嵌套在其他 `windowRoot align-node` 内造成缩放异常。
- overlay 根和 backdrop 使用 `App.visualSize` 作为明确尺寸，不依赖百分比尺寸推断。
- backdrop 是 `Modal` root 下的第一个全屏 `PaintNode` 子节点，root 只负责 `windowRoot` 布局、输入吞噬和 backdrop close。不要把 backdrop 挂到业务界面 root 内，也不要让 Modal root 的 `onRender` 混入业务组件绘制链路。
- 内容区按 message、body、actions 三段固定高度排列，避免小尺寸弹窗里 body 和按钮互相挤压。
- 背景遮罩吞触摸，`closeOnBackdrop !== false` 时点击遮罩触发 `onClose`。
- 内容区域吞触摸，避免点击正文穿透到遮罩。
- action button 点击只触发 `onAction(id)`，关闭状态由调用者控制。

## 事件语义

| 事件 | 触发时机 |
| --- | --- |
| `onClick` | tap ended 且仍在可交互状态，或焦点 activate |
| `onCast` | `CooldownButton` 可释放时激活 |
| `onChange` | `Toggle` checked 值变更 |
| `onValueChange` | `Slider` 数值变更，或 `Tabs` 选中项变更；`ProgressBar` 不触发 |
| `onClose` | `Modal` 请求关闭 |
| `onAction` | `Modal` action button 被点击 |
| `onLayout` | 底层 `AlignNode` 布局更新 |

事件不得在 disabled 状态触发。组件内部事件更新 local signal 后，应让 DoraX 按 signal 调度刷新，不手动重建根节点。

## 导出

`index.ts` 首版导出：

```ts
export * from "./theme";
export * from "./context";
export * from "./paint/PaintNode";
export * from "./layout/Box";
export * from "./layout/Row";
export * from "./layout/Column";
export * from "./layout/Stack";
export * from "./layout/Spacer";
export * from "./layout/Panel";
export * from "./layout/ScrollView";
export * from "./foundation/Text";
export * from "./foundation/Icon";
export * from "./foundation/FocusRing";
export * from "./controls/Button";
export * from "./controls/IconButton";
export * from "./controls/ProgressBar";
export * from "./controls/Toggle";
export * from "./controls/Checkbox";
export * from "./controls/Slider";
export * from "./controls/Tabs";
export * from "./controls/Select";
export * from "./controls/TextInput";
export * from "./overlay/Tooltip";
export * from "./overlay/ToastStack";
export * from "./overlay/Modal";
export * from "./game/HealthBar";
export * from "./game/ResourceCounter";
export * from "./game/CooldownButton";
export * from "./game/ItemSlot";
export * from "./game/InventoryGrid";
```
