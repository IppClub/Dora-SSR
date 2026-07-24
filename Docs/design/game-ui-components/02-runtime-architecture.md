# UIX Runtime Architecture

本文定义 `UIX` 的实现级运行时契约。首版实现应按这里的边界落地，避免组件之间各自处理布局、绘制、输入和状态。

## 模块边界

```text
Assets/Script/Lib/UIX/
  index.ts
  theme.ts
  context.ts
  paint/
    PaintNode.tsx
    color.ts
    primitives.ts
    icons.ts
  layout/
  controls/
  game/
  input/
```

`UIX` 是新的动态 TSX 组件命名空间，不并入现有 `Assets/Script/Lib/UI/`。旧 `UI` 模块继续服务现有 Yue/Lua 控件，`UIX` 面向 DoraX 动态 TSX 和 nvg painter。

## 核心节点结构

每个有视觉背景的组件推荐结构：

```text
AlignNode(layout, onLayout)
  PaintNode(ordinary Node, onRender)
  content nodes(Label/Sprite/AlignNode...)
  FocusRing(optional PaintNode)
```

职责划分：

- `AlignNode` 只负责布局盒、尺寸、padding、gap、position 和 resize。
- `PaintNode` 是普通 `Node`，在 render 回调里直接调用 nvg 画到当前 UI 层表面。
- `Text` 组件使用 nvg 自己的字体和文字绘制接口，不使用 Dora `Label`，避免文字层和 nvg 背景/图标层互相穿插。
- `Sprite` 负责外部图片 icon 或头像。
- `VGNode` 不在普通组件默认路径中使用，只作为显式缓存或离屏合成优化。

## PaintNode 契约

```ts
type InteractionVisualState =
  | "idle"
  | "hovered"
  | "pressed"
  | "focused"
  | "selected"
  | "disabled"
  | "loading";

type PaintContext = {
  width: number;
  height: number;
  theme: Theme;
  pixelRatio: number;
  opacity: number;
  state: InteractionState;
  time: number;
};

type Painter = (this: void, ctx: PaintContext) => void;
```

实现要求：

- `PaintNode` 由 `custom-node` 创建普通 `Node`。
- `PaintNode` 的 render 回调每帧只读取已有状态，不在热路径创建字体、加载图片或构造大型临时表。
- `PaintNode` 的尺寸来自父级 `AlignNode.onLayout(width, height)`，不要从视觉内容反推布局。
- painter 坐标使用左上角为 `(0, 0)`、宽高为 `ctx.width/ctx.height` 的本地坐标约定；封装层负责必要的 nvg transform。
- painter 不直接读业务 signal；组件把 signal 值转成 props/state 后传入。
- `PaintNode` 在调用 painter 前会检查祖先节点是否注册了 nvg 裁剪区域，并在自身 transform 后用 `nvg.Scissor` / `nvg.IntersectScissor` 应用裁剪。

## nvg 裁剪契约

当前 UIX 不依赖 Node clip、Yoga `overflow` 或 `VGNode` 纹理表面来做通用裁剪。原因是 UIX 视觉内容主要走普通 `Node.onRender()` 中的 nvg 绘制，裁剪必须发生在同一个 nvg 绘制上下文里。

实现规则：

- `ScrollView` 这样的容器只登记自己的 viewport 尺寸。
- 每个子级 `PaintNode` 渲染时向上查找已登记的裁剪祖先，把祖先 viewport 从世界坐标转换到当前绘制节点本地坐标。
- 第一个裁剪区域使用 `nvg.Scissor`，嵌套裁剪继续使用 `nvg.IntersectScissor`。
- 裁剪只覆盖 UIX `PaintNode` 路径，也就是 UIX 背景、图标和 nvg 文本；普通 Dora `Label`、`Sprite` 或业务自定义节点需要自己的绘制/裁剪策略。

## AlignNode style patch

`UIX` 依赖 DoraX runtime 支持 `align-node.style` 动态 patch。当前 runtime 已满足：

- `Assets/Script/Lib/DoraX.ts` 中 `patchAlignNodeProps()` 会在 `style` 引用变化时调用 `css(getAlignStyleText(style))`。
- 生成的 `Assets/Script/Lib/DoraX.lua` 也包含同等逻辑。

组件开发约定：

- 低频布局变化可以直接更新 `style` 对象。
- 高频动画不要驱动 Yoga style；应改变 painter 状态或普通 Node transform。
- 如果 style 对象原地修改但引用不变，DoraX 不会识别变化。组件示例必须使用新对象。

## 状态和更新

状态来源分三层：

| 来源 | 示例 | 规则 |
| --- | --- | --- |
| props | `disabled`, `value`, `variant` | 由上层传入，组件不修改 |
| local signal | pressed, hovered, focused | 组件内部交互状态 |
| module context | theme, inputMode, focusManager | `context.ts` 提供默认上下文和 setter |

首版避免引入全局 store。组件内部状态使用 `useSignal()` 或封装 helper。业务状态由游戏逻辑层通过 props 传入。

## Dynamic Children 和 key

DoraX 的动态 children diff 采用和 React 类似的身份规则：

- 有 `key` 的同级元素按 `key` 匹配和复用。
- 没有 `key` 的同级元素按当前位置下标匹配和复用。
- 类型和 `key` 都相同的节点会复用原有 Dora 节点并 patch props。

因此，UIX demo 和业务界面中只要出现“条件显示/隐藏、插入、删除、排序”的同级动态节点，就必须给这些节点稳定 `key`。尤其是两个同类型组件相邻时：

```tsx
{open.value ? <Panel key="settings-panel" title="Settings" /> : undefined}
<Panel key="skills-panel" title="Skills" />
```

不要写成无 key 的条件兄弟节点：

```tsx
{open.value ? <Panel title="Settings" /> : undefined}
<Panel title="Skills" />
```

后一种写法在关闭 `Settings` 时会让 `Skills` 从第二个可见 `Panel` 变为第一个可见 `Panel`。无 key diff 会按下标复用旧节点，可能把 `Skills` patch 到原 `Settings` 节点的位置。

## 输入处理

可交互组件统一通过 `Interaction.ts` 处理：

```ts
type InteractionState = {
  hovered: boolean;
  pressed: boolean;
  focused: boolean;
  selected: boolean;
  disabled: boolean;
  loading: boolean;
};
```

输入约定：

- `disabled` 时不触发 `onClick` / `onSelect` / `onChange`。
- `touchEnabled` 由可交互组件默认开启。
- `swallowTouches` 默认为 `true`，overlay 组件可覆写。
- pressed 在 `onTapBegan` 设置，在 `onTapEnded` / `onUnmount` 清除。
- 首版 hover 可先只作为鼠标平台扩展，不阻塞触屏功能。

## 焦点管理

首版 `FocusManager` 提供最小接口：

```ts
type FocusHandle = {
  id: string;
  node: Dora.Node.Type;
  disabled: () => boolean;
  focus: () => void;
  blur: () => void;
  activate: () => void;
};
```

规则：

- `Button`、`IconButton`、`CooldownButton` 默认可聚焦。
- 焦点进入时绘制 `FocusRing`，不能只改文字或背景颜色。
- 显式方向导航以后再做；首版可按注册顺序切换焦点。
- 手柄按钮和键盘确认键都映射到 `activate()`。

## 主题访问

首版使用模块级 UI context，组件通过 helper 读取：

```ts
type UiContext = {
  theme: Theme;
  inputMode: "pointer" | "keyboard" | "controller";
  focusManager: FocusManager;
};
```

后续如果需要局部换肤，再在此基础上增加 `UiProvider` / `ThemeScope`。在 DoraX 动态 diff 下，provider 需要单独验证栈式 context 是否能稳定跟随 mount/update/unmount。

## 绘制原语

`paint/primitives.ts` 提供可复用 nvg 画法：

- `roundedPanel(ctx, rect, variant)`
- `buttonSurface(ctx, rect, variant, state)`
- `progressFill(ctx, rect, value, variant)`
- `focusRing(ctx, rect, state)`
- `cooldownWedge(ctx, rect, progress)`
- `badge(ctx, rect, textOrIcon)`

组件不得直接复制大段 nvg 面板代码。新组件如果需要新画法，先抽 primitive 或 painter variant。

## 资源和字体

- 字体名从 theme 读取，组件不硬编码项目字体。
- nvg icon painter 不加载图片。
- Sprite icon 由调用者提供资源名，`Icon` 只负责尺寸和状态 tint。
- `VGNode` 缓存资源必须显式持有和释放，不能隐藏在普通组件默认构造中。

## 清理

所有组件必须遵循：

- `onUnmount` 清除 pressed/hover/focus 注册。
- `PaintNode` unmount 时清除 render 回调。
- `FocusManager` unregister 对应 handle。
- 动画或调度任务在 unmount 时停止。

## 最小开发顺序

1. `theme.ts` 和 `context.ts`。
2. `PaintNode.tsx` 和基础 painter primitives。
3. `Box`、`Row`、`Column`、`Stack`。
4. `Text`、`Icon`、`FocusRing`。
5. `Button`、`Panel`、`ProgressBar`。
6. `HealthBar`、`ResourceCounter`、`CooldownButton`。
7. HUD demo 和 in-engine 验证。
