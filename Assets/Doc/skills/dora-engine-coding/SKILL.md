---
name: dora-engine-coding
description: Dora SSR coding rules for game/workspace projects; prevents browser DOM/Canvas/Node.js code in Dora engine scripts and forces Dora API lookup before using unfamiliar engine APIs.
always: true
---

# Dora Engine Coding Rules

These rules apply whenever writing, fixing or reviewing code for a Dora SSR workspace/game project.

## What Runtime This Is

- Dora runtime game code is executed by the Dora engine, not by a browser or Node.js.
- The normal runtime entry is the project-root `init.ts` or `init.lua`.
- TypeScript/TSX is source code and is transpiled to Lua. The engine executes the Lua output.
- Prefer editing `.ts`/`.tsx` source files. Do not hand-edit generated `.lua` unless the task is specifically about Lua output or the project is Lua-only.
- If a project contains web files (`index.html`, DOM Canvas code, etc.) and also has `init.ts`, treat `init.ts` as the Dora runtime entry unless the user explicitly asks for a browser/Web IDE frontend.

## Runtime vs Browser Decision

Before writing code, decide the target:

1. **Dora game/runtime script**: use Dora engine APIs and this skill.
2. **Web IDE/frontend page**: browser APIs may be valid, but only if the user explicitly asks for Web IDE/frontend/browser work.

For Dora runtime scripts, never generate:

- `document`, `window`, `HTMLElement`, `HTMLCanvasElement`, `CanvasRenderingContext2D`
- `requestAnimationFrame`, browser `alert`, DOM event listeners
- `setInterval`, `setTimeout`, `NodeJS.Timeout`
- npm-only packages, Node `fs/path/process`
- HTML `index.html` as the runtime game entry

If those APIs already exist in a Dora runtime project, treat them as incompatible code to rewrite.

## Hard Rule: Do Not Guess Dora APIs

Dora has its own TypeScript definitions such as `Dora.d.ts`. Do not invent names/signatures.

### Lookup protocol

Call `search_dora_doc` before using any Dora API not shown in the baseline or already in the project. Batch unfamiliar APIs into one call. Use `programmingLanguage: "ts"` and `docType: "dora-api"`. After lookup, use the exact module/export names returned.

## Module Import Rules

Use Dora runtime modules, not browser packages:

- Core engine APIs: `import { ... } from 'Dora';`
- JSX/DoraX UI syntax: use `.tsx` and import from `DoraX`. Use `toNode()` for one-shot scene creation, or `createRoot()` with `signal()` for dynamic TSX diff rendering.
- DoraX dynamic roots track the signals read during render. Use stable `key` values for dynamic sibling lists, and call `root.unmount()` when a dynamic root is no longer needed.
- Platformer framework: `import * as Platformer from 'Platformer';` or exact exports found by API search.
- ImGui tools/UI: `import * as ImGui from 'ImGui';` plus enum exports from `ImGui` when needed.
- Vector graphics: `import * as nvg from 'nvg';` when using `VGNode`/NanoVG APIs.
- Do not import React from npm for DoraX runtime code.

## TypeScript Hygiene

- Do not use `any` in Dora runtime TypeScript. Use concrete types, `unknown` with narrowing, generics, or exact unions/records.
- Do not use bare `null` in runtime code. Use `undefined`/omitted fields for absent Lua values.
- In `edit_file` content, indent with ordinary space characters. Never emit the two literal characters `\\t` at the beginning of a source line; they are not indentation and will make TypeScript parsing fail.
- Dora factory namespaces are values, not annotation types. Annotate instances with `Vec2.Type`, `Color.Type`, `Label.Type`, `DrawNode.Type`, and the corresponding `X.Type`; do not use bare `X` or `ReturnType<typeof X>`.
- The Dora TypeScript-to-Lua subset does not support `Math.hypot` or `Math.imul`. Use `Math.sqrt(x*x + y*y)` and ordinary bounded arithmetic.
- Lua arrays cannot represent `undefined`/`null` elements. Do not build arrays from optional factory results such as `Label(...)`; narrow each optional result before inserting it, or handle the labels individually.

## Coordinate System

- Dora uses a left-handed coordinate system, positive X is right and positive Y is up.
- `Director.entry`, `Director.ui`, and similar root nodes use screen-center origin: `(0, 0)` is the screen center.
- Do not use browser-style top-left coordinates unless explicitly converting from that space.
- For game screen adaptation, read `ts/adapting-to-screen.md` directly before designing responsive layout behavior.

### Parent and child local coordinates

- For a parent node with nonzero `width` and `height`, `anchor` selects which point of the parent's own rectangle is placed at the parent's `position`. It does not move the local origin used by the parent's children.
- A child is positioned in the parent's rectangular local space, whose `(0, 0)` is the rectangle's bottom-left corner. Even with the default `anchor = Vec2(0.5, 0.5)`, a child at `Vec2.zero` is at that bottom-left corner, not at the parent's center.
- To center a child in the parent rectangle, place it at `Vec2(parent.width / 2, parent.height / 2)`.
- To align a child with the parent's anchor point, place it at `Vec2(parent.width * parent.anchor.x, parent.height * parent.anchor.y)`.

Keep a full-screen drawing root unsized when its children should use screen-center coordinates:

```ts
const screen = Node();
screen.addTo(Director.entry); // unsized: child (0, 0) remains the screen center

const background = DrawNode();
const {width, height} = View.size;
background.drawPolygon([
	Vec2(-width / 2, -height / 2),
	Vec2(width / 2, -height / 2),
	Vec2(width / 2, height / 2),
	Vec2(-width / 2, height / 2),
], Color(20, 30, 50, 255));
background.addTo(screen);
```

For a sized parent, position children in its bottom-left-based local rectangle:

```ts
panel.size = Size(320, 180);
panel.position = Vec2.zero; // the panel's anchor point is at screen center
label.position = Vec2(panel.width / 2, panel.height / 2); // center inside panel
```

Inside that sized node's touch handler, `touch.location` uses the same bottom-left-based local space. Convert it before comparing against centered model coordinates:

```ts
const local = touch.location;
const centered = Vec2(
	local.x - panel.width * panel.anchor.x,
	local.y - panel.height * panel.anchor.y
);
```

Do not give a full-screen drawing root a `size` merely for adaptation. Add a separate sized input node when a real hit area is required, and deliberately use or convert its local coordinates as shown above.

### Input coordinate and enum baseline

These names come directly from the built-in `Dora.d.ts`; do not spend a search step rediscovering them:

- `touch.location`: position in the receiving node's local coordinate system.
- `touch.viewLocation`: position in the current view's logical coordinate system.
- `touch.worldLocation`: position in world coordinates. Prefer node-local handlers with `touchEnabled = true` and the node's real `size` over global manual hit testing.
- The return key is `KeyName.Return`, not `KeyName.Enter`. Number keys are `KeyName.Num0` through `KeyName.Num9`; letters and arrows use names such as `KeyName.W`, `KeyName.Left`, and `KeyName.Up`.
- Controller buttons use `ButtonName.A/B/X/Y`, `Back`, `Start`, `Up/Down/Left/Right`, `LeftShoulder/RightShoulder`, and `LeftStick/RightStick`. Axes use `AxisName.LeftX/LeftY/RightX/RightY/LeftTrigger/RightTrigger`.
- Controller calls are `Controller.isButtonDown/Up/Pressed(controllerId, ButtonName.X)` and `Controller.getAxis(controllerId, AxisName.LeftX)`.
- For a centered playfield of width `w` and height `h`, every model-space object and configured region must initially lie within `[-w/2,w/2] × [-h/2,h/2]`. With Dora's positive-Y-up convention, a bottom paddle has negative Y, bricks near the top have positive Y below `h/2`, launch-up velocity is positive Y, and falling velocity is negative Y. Check these signs and bounds before the first build.

## Scheduling Semantics

- A Dora `Node` has one schedule slot. Calling `node.schedule(...)` again replaces that node's previous scheduled callback; it does not add another concurrent callback.
- Put update and render work in one scheduled callback, or attach independent callbacks to distinct child nodes.
- Runtime probes must never add another schedule to the node whose game loop is being tested. Observe state from the existing callback or use a separate probe node, then remove the probe after validation.

## Baseline Dora APIs for Simple 2D Prototypes

For a tiny runtime prototype, this baseline is allowed without extra API search:

```ts
// @preview-file on clear
import { Color, Director, DrawNode, KeyName, Keyboard, Label, Node, Vec2, View } from 'Dora';

const root = Node();
root.addTo(Director.entry);

const draw = DrawNode();
draw.addTo(root);

const title = Label('sarasa-mono-sc-regular', 20);
if (title) {
	title.text = 'Dora Game';
	title.y = View.size.height / 2 - 40;
	title.addTo(root);
}

let x = 0;
root.schedule((dt) => {
	if (Keyboard.isKeyPressed(KeyName.Left)) x -= 240 * dt;
	if (Keyboard.isKeyPressed(KeyName.Right)) x += 240 * dt;
	draw.clear();
	draw.drawDot(Vec2(x, 0), 20, Color(80, 180, 255, 255));
	return false; // keep scheduling
});
```

Baseline mapping:

- Scene root: `Director.entry`, not HTML body/canvas.
- Main loop: `Node.schedule((dt) => false)` or `node.onUpdate`, not `requestAnimationFrame`.
- Timers: accumulate `dt` in scheduled updates, not `setInterval`/`setTimeout`.
- Primitive drawing: `DrawNode.drawCircle`, `drawRect`, `drawRoundedRect`, `drawEllipse`, `drawRing`, `drawSector`, `drawSegment`, `drawPolyline`, `drawArc`, `drawQuadraticBezier`, `drawCubicBezier`, and `drawPolygon`.
- `DrawNode.drawPolygon` accepts simple convex or concave polygons. Keep vertices in boundary order and do not pass self-intersecting outlines.
- Stroke radii (`drawSegment`, `drawPolyline`, `drawArc`) and polygon `borderWidth` are half widths. Polygon borders are centered on the outline. Open strokes have round caps, and long miter joins are beveled.
- `drawArc` uses degrees from +X toward +Y. Its signed sweep is limited to one revolution; full circles close without caps. Commands with non-finite coordinates or sizes are ignored; insufficient vertex capacity rejects the entire command.
- `drawRoundedRect(rect, cornerRadius, fillColor?, borderWidth?, borderColor?)` clamps the corner radius to half the smaller dimension. `drawRing(center, innerRadius, outerRadius, fillColor?, borderWidth?, borderColor?)` preserves its center hole and requires `0 <= innerRadius < outerRadius`. `drawSector(center, radius, startAngle, endAngle, fillColor?, borderWidth?, borderColor?)` uses the same angle conventions as `drawArc`.
- Bezier strokes use positional arguments: `drawQuadraticBezier(from, control, to, radius, color?)` and `drawCubicBezier(from, control1, control2, to, radius, color?)`. Radius is half the stroke width; subdivision is automatic (target error is the smaller of 0.25 local units and 1% of the control hull diagonal, at most 1024 segments).
- Text: `Label('sarasa-mono-sc-regular', size)` and guard because `Label(...)` may return `undefined`.
- Text anchoring uses the inherited `anchor = Vec2(x, y)` property. There is no `anchorX`. Do not assign string values such as `'Left'`, `'Center'`, or `'Right'` to `Label.alignment`.
- For safe screen-edge HUD text, use `View.size`, put left labels at `-View.size.width / 2 + margin` with `anchor = Vec2(0, 0.5)`, and right labels at `View.size.width / 2 - margin` with `anchor = Vec2(1, 0.5)`.
- If the playfield is scaled and draws a top wall/frame, derive HUD Y from the rendered field top rather than guessing from `View.size` alone. Put the label baseline below the rendered wall by at least the wall thickness plus one font line height, and set HUD labels to a foreground `z` above the field `DrawNode`s. Confirm the initial frame visually; a successful lifecycle check cannot detect clipped or covered text.
- Give title/subtitle or state/instruction label pairs distinct Y positions with at least one full line-height of separation; never leave both at `(0, 0)`.
- Check overlay text against the initial player/game objects as well as against its sibling labels. For a centered starting actor, place both title and instruction lines together above or below that actor with a full line-height/object-radius gap; separating the two labels is insufficient if one line then covers the actor.
- Keyboard hold state: `Keyboard.isKeyPressed(KeyName.Left)`.
- One-frame key down/up: `Keyboard.isKeyDown(...)` / `Keyboard.isKeyUp(...)`.
- For discrete menu/action/gameplay presses that must not be missed by a short physical key tap, prefer `node.onKeyDown((keyName) => { ... })`; it enables keyboard input on that node. Queue the resulting action and consume it in the existing scheduled game loop. Use per-frame keyboard polling only for genuinely continuous hold behavior.
- Screen size: `View.size.width`, `View.size.height`.
- Coordinates: direct children of `Director.entry`/`Director.ui` use screen-center origin, positive X right, and positive Y up. For child nodes or cameras, compute in that local space.

