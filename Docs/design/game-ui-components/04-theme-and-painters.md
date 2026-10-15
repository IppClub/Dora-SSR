# UIX Theme and Painters

本文定义 UIX 的主题 token、painter 输入输出、绘制原语和状态映射。目标是让所有组件共用同一套视觉语言，同时保持 nvg 直接绘制路径轻量。

## Theme 结构

```ts
type Theme = {
  name: string;
  colors: ThemeColors;
  space: ThemeSpace;
  radius: ThemeRadius;
  stroke: ThemeStroke;
  font: ThemeFont;
  size: ThemeSize;
  motion: ThemeMotion;
  painter: ThemePainterOptions;
};
```

## Token 命名

Token 使用点分命名，代码里用嵌套对象表达。

```ts
type ThemeColors = {
  surface: {
    base: number;
    raised: number;
    sunken: number;
    overlay: number;
  };
  line: {
    subtle: number;
    normal: number;
    strong: number;
  };
  accent: {
    primary: number;
    secondary: number;
    warm: number;
  };
  state: {
    danger: number;
    mana: number;
    shield: number;
    success: number;
    warning: number;
  };
  text: {
    primary: number;
    secondary: number;
    disabled: number;
    inverse: number;
  };
  focus: {
    ring: number;
    glow: number;
  };
};
```

颜色统一使用 Dora 可接受的 `0xrrggbbaa` number。painter 内需要 alpha 变化时使用 helper 合成，不直接散落魔法数字。

## 默认 Dora Prism Token

```ts
const doraPrismTheme: Theme = {
  name: "Dora Prism",
  colors: {
    surface: {
      base: 0x11161dff,
      raised: 0x1b2430f0,
      sunken: 0x080b10cc,
      overlay: 0x05070acc,
    },
    line: {
      subtle: 0x2a3542aa,
      normal: 0x405062cc,
      strong: 0xb9c7d8dd,
    },
    accent: {
      primary: 0x35d0ffff,
      secondary: 0x4d7cffff,
      warm: 0xffc15aff,
    },
    state: {
      danger: 0xff4f5eff,
      mana: 0x4d7cffff,
      shield: 0x70e0ffff,
      success: 0x56d68aff,
      warning: 0xff9c3dff,
    },
    text: {
      primary: 0xf4f8ffff,
      secondary: 0x9eacbdff,
      disabled: 0x637080aa,
      inverse: 0x071017ff,
    },
    focus: {
      ring: 0x35d0ffff,
      glow: 0x35d0ff66,
    },
  },
  space: { xxs: 2, xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32 },
  radius: { xs: 3, sm: 4, md: 8, lg: 12, xl: 16 },
  stroke: { hairline: 1, normal: 2, strong: 3, focus: 3 },
  font: {
    name: "sarasa-mono-sc-regular",
    sdf: true,
    size: { xs: 11, sm: 13, md: 16, lg: 20, xl: 26 },
  },
  size: {
    control: { sm: 32, md: 44, lg: 56 },
    icon: { sm: 16, md: 22, lg: 30 },
  },
  motion: { fast: 0.08, normal: 0.14, slow: 0.22 },
  painter: {
    shadowAlpha: 0.28,
    bevelAlpha: 0.32,
    disabledAlpha: 0.42,
  },
};
```

## Painter Context

```ts
type Rect = {
  x: number;
  y: number;
  width: number;
  height: number;
};

type PaintContext = {
  width: number;
  height: number;
  theme: Theme;
  pixelRatio: number;
  opacity: number;
  state: InteractionState;
  time: number;
  data?: unknown;
};

type Painter = (this: void, ctx: PaintContext) => void;
```

约定：

- 坐标原点是组件左上角。
- `ctx.width` / `ctx.height` 是布局尺寸，不是纹理尺寸。
- painter 不返回值。
- painter 不修改 Dora 节点树。
- painter 内禁止加载资源、创建长期对象或触发 signal 写入。

## nvg 绘制边界

允许使用：

- `BeginPath`、`RoundedRect`、`RoundedRectVarying`、`Rectangle`、`Circle`、`Arc`、`Fill`、`Stroke`。
- `FillColor`、`StrokeColor`、`LinearGradient`、`BoxGradient`、`RadialGradient`。
- `Save`、`Restore`、`Translate`、`Scale`、`Scissor`、`ResetScissor`。
- `Text`、`TextBounds`、`FontSize`、`FontFace`、`TextAlign`，仅用于短文本。

避免使用：

- 每帧 `CreateImage` / `CreateFont`。
- 每个普通控件创建 `VGNode`。
- 复杂路径动画驱动 Yoga reflow。
- 大段长文本每帧测量。

## 状态到视觉映射

| 状态 | 背景 | 边线 | 文本/Icon | 额外效果 |
| --- | --- | --- | --- | --- |
| idle | `surface.raised` | `line.normal` | `text.primary` | 顶部高光 |
| hovered | raised + accent overlay | `accent.primary` 低 alpha | `text.primary` | 轻微亮度 |
| pressed | `surface.sunken` | `line.strong` | `text.primary` | 内容偏移 |
| focused | idle/hovered | `focus.ring` | `text.primary` | 焦点环最后绘制 |
| selected | accent tinted | `accent.primary` | `text.primary` | 内发光 |
| disabled | `surface.sunken` | `line.subtle` | `text.disabled` | alpha 降低 |
| loading | idle | `accent.primary` | `text.secondary` | spinner 或脉冲 |

状态优先级：

```text
disabled > loading > pressed > selected > hovered > focused > idle
```

`focused` 不应被完全覆盖，因为手柄/键盘导航需要持续可见。

## 绘制原语

### roundedPanel

```ts
function roundedPanel(ctx: PaintContext, rect: Rect, options: {
  variant: "default" | "glass" | "solid";
  radius?: number;
  elevated?: boolean;
}): void;
```

绘制顺序：

1. 可选阴影。
2. 背景填充。
3. 顶部高光。
4. 边线。
5. 可选角装饰。

### buttonSurface

```ts
function buttonSurface(ctx: PaintContext, rect: Rect, options: {
  variant: UiVariant;
  radius?: number;
}): void;
```

规则：

- `primary` 使用 `accent.primary` 作为边线和轻微渐变。
- `danger` 使用 `state.danger`。
- `ghost` 背景透明，只绘制 hover/pressed/focused。
- disabled 由 `ctx.state.disabled` 统一降 alpha。

### progressTrack / progressFill

```ts
function progressTrack(ctx: PaintContext, rect: Rect): void;
function progressFill(ctx: PaintContext, rect: Rect, progress: number, variant: ProgressVariant): void;
```

规则：

- `progress` 必须预先 clamp 到 `[0, 1]`。
- fill 宽度至少在 progress > 0 时显示 1px，避免极小值不可见。
- danger/health/mana/shield 使用不同 token，但形状一致。

### cooldownWedge

```ts
function cooldownWedge(ctx: PaintContext, rect: Rect, progress: number): void;
```

规则：

- `progress = cooldown / maxCooldown`。
- 首版可以用半透明矩形从上到下裁剪；扇形路径作为后续增强。
- 数字层不在 primitive 中绘制，由 `CooldownButton` 组合 `Text`。

### focusRing

```ts
function focusRing(ctx: PaintContext, rect: Rect, options?: {
  inset?: number;
  radius?: number;
  color?: number;
}): void;
```

规则：

- 必须最后绘制。
- 默认向外扩 2px，避免压住内容。
- disabled 时不绘制。

## Icon Painter

内置 icon painter 签名：

```ts
type IconPainter = (this: void, ctx: PaintContext, rect: Rect, color: number) => void;
```

首版内置图标：

| 名称 | 用途 |
| --- | --- |
| `play` | 开始、播放 |
| `close` | 关闭 |
| `gear` | 设置 |
| `coin` | 货币 |
| `heart` | 生命 |
| `mana` | 法力 |
| `lock` | 锁定 |
| `check` | 确认 |
| `warning` | 警告 |
| `arrow` | 导航 |

图标约束：

- 视图盒为 `0..1` 单位，调用方缩放到目标 rect。
- `drawIcon` 入口负责把内置 nvg 图标适配到 UI 坐标方向，单个 icon painter 不再自行翻转 y 轴。
- 不使用文字作为图标。
- 不依赖外部图片。

## 文本规范

| 用途 | 实现 |
| --- | --- |
| 按钮文字 | `Text`，内部使用 nvg text |
| 资源数字 | `Text`，内部使用 nvg text |
| 冷却数字 | 短 nvg text |
| 长说明 | 后续 `RichText`，首版不做 |
| Tooltip 正文 | 短文本用 `Text wrap`，长富文本后续交给 `RichText` |

文本颜色按状态选择，disabled 不只降低 alpha，也使用 `text.disabled`。

## 主题扩展

主题扩展必须只改 token 和 painter option，不改组件结构。建议后续提供：

- `doraPrismFantasyTheme`
- `doraPrismSciFiTheme`
- `doraPrismMinimalTheme`

首版只实现默认主题，但 painter API 必须允许传入这些 variant。
