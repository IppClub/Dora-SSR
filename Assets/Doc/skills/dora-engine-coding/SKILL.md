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

Call `search_dora_api` before using any Dora API that is not shown in the baseline section below or not already used correctly in the project.

For implementation tasks, keep lookup bounded so it does not replace implementation:

- When the runtime reports a fresh project, start from the disclosed short code file or create the requested entry directly (default to `init.ts` for a Dora TypeScript task). Consult relevant tutorials or APIs when they help, and prefer an early build so subsequent work can use compiler feedback.
- If the requested game fits the baseline APIs below, do not search first. Inspect the entry, implement the smallest complete playable loop, then build.
- Before the first edit, use at most one batched `search_dora_api` call for all genuinely unfamiliar APIs. Do not issue separate searches for APIs already covered by the baseline.
- After that lookup, edit and build. Search again only for a concrete compiler or runtime error that cannot be resolved from the returned signature.
- Do not use runtime command tools for project discovery, file inspection, or API/type-definition lookup. Use the corresponding file/search tools.
- Prefer build diagnostics over speculative design research. Do not spend repeated Agent steps comparing optional architectures before a playable baseline exists.
- After editing source, build before another `search_dora_api` call. A later search is justified only by a concrete build/runtime diagnostic that requires an unfamiliar API.

Use:

- `programmingLanguage: "ts"` for `.ts` files.
- `programmingLanguage: "tsx"` for DoraX/JSX files.
- `docSource: "api"` for signatures/types.
- `docSource: "tutorial"` for usage examples when signatures alone are not enough.
- `docLanguage: "zh"` if the user is Chinese or Chinese docs are preferred; otherwise `"en"`.

After searching:

1. Read the returned signature/JSDoc carefully.
2. Use the exact module name, export name, parameter order, return type, and enum value.
3. If the result is incomplete, search narrower terms or read the referenced `.d.ts`/tutorial file.
4. If search fails, say the API was not found and implement a simpler baseline Dora version instead of guessing.

Search especially for:

- physics/collision: `PhysicsWorld`, `Body`, `BodyDef`, `FixtureDef`, `Sensor`
- ECS: `Entity`, `Group`, `Observer`, component queries
- UI/components/layout: `Button`, `Menu`, `AlignNode`, UI controls
- audio: `Audio`, `AudioSource`, buses/effects
- async/coroutines: `thread`, `threadLoop`, `sleep`, `once`, `loop`, scheduler jobs
- scene/camera: `Director`, `Camera`, `Director.ui`, `Director.entry`, scheduler APIs
- resources/files: `Content`, `Cache`, `Path`, asset loading/saving
- sprite/animation/actions: `Sprite`, `Model`, `Playable`, `Action`, `Move`, `Scale`, `Sequence`, animation slots
- particles/effects/video: `Particle`, `EffekNode`, `VideoNode`, `TIC80Node`
- tile maps: `TileNode`
- Platformer helpers: `Platformer`, `PlatformWorld`, platformer bodies/units
- vector graphics/custom rendering: `DrawNode`, `VGNode`, `nvg`
- input beyond simple keyboard: `Mouse`, touch, controller, IME, node slots

Example tool searches:

```text
search_dora_api pattern="PhysicsWorld|Body|FixtureDef" docSource="api" programmingLanguage="ts" limit=8
search_dora_api pattern="Button|Menu|AlignNode" docSource="api" programmingLanguage="ts" limit=8
search_dora_api pattern="AudioSource|Audio" docSource="api" programmingLanguage="ts" limit=8
search_dora_api pattern="thread|sleep|threadLoop" docSource="api" programmingLanguage="ts" limit=8
```

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
- The Dora TypeScript-to-Lua subset does not support `Math.hypot`, `Math.random`, or `Math.imul`. Use `Math.sqrt(x*x + y*y)`, inject randomness, and use ordinary bounded arithmetic.
- Lua arrays cannot represent `undefined`/`null` elements. Do not build arrays from optional factory results such as `Label(...)`; narrow each optional result before inserting it, or handle the labels individually.

## Coordinate System

- Dora uses a left-handed coordinate system, positive X is right and positive Y is up.
- `Director.entry`, `Director.ui`, and similar root nodes use screen-center origin: `(0, 0)` is the screen center.
- Do not use browser-style top-left coordinates unless explicitly converting from that space.
- For game screen adaptation, read `ts/adapting-to-screen.md` directly before designing responsive layout behavior.

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
- Primitive drawing: `DrawNode.drawDot`, `drawSegment`, `drawPolygon`.
- `DrawNode` has no `drawRect`; draw rectangles with four `Vec2` vertices passed to `drawPolygon`.
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

## Runtime API Coverage Map

Use this as a decision map. It is not a full API reference; exact signatures come from `search_dora_api`.

| Need | Likely start | Lookup rule |
| --- | --- | --- |
| Basic scene/game loop | `Director.entry`, `Node.schedule` | Baseline enough for tiny prototypes |
| Primitive drawing | `DrawNode`, `Vec2`, `Color` | Search for advanced vertices/VGNode |
| Sprites/assets | `Sprite`, `Content`, `Cache`, `Path` | Search before loading assets |
| Text/UI/layout | `Label`, `Menu`, `Button`, `AlignNode`, `DoraX` | Search before UI controls/layout |
| Keyboard/mouse/touch/controller | `Keyboard`, `KeyName`, `Mouse`, node slots | Search beyond simple keyboard |
| Actions/animation | `Action`, `Move`, `Scale`, `Sequence`, `Playable`, `Model` | Search exact signatures |
| Physics/collision | `PhysicsWorld`, `Body`, `BodyDef`, `FixtureDef`, `Sensor` | Always search first |
| ECS/game architecture | `Entity`, `Group`, components | Always search first |
| Audio | `Audio`, `AudioSource` | Always search first |
| Async/coroutines | `thread`, `threadLoop`, `sleep`, `once`, `loop` | Search when using coroutine/timing APIs |
| Tile maps | `TileNode` | Always search first |
| Particles/effects/video | `Particle`, `EffekNode`, `VideoNode`, `TIC80Node` | Always search first |
| Platformer framework | `Platformer`, `PlatformWorld` | Always search first |

## Implementation Workflow

1. Inspect project files and locate the real runtime entry (`init.ts`, `init.lua`, or an existing run script).
2. Identify source language: TS/TSX vs Lua. Prefer TS/TSX source edits when present.
3. Search Dora API before any non-baseline API use.
4. Keep entry wiring real: the entry must import/instantiate/start the game logic.
5. Avoid orphan modules: if creating classes/modules, export/import them correctly and ensure `init.ts` uses them.
6. When adding imports, choose Dora module names or project-root module paths from the init directory/search folders, not raw filesystem paths or `./`/`../` paths. TypeScript project imports use slash-separated paths such as `import { Game } from 'game/Game'`; Lua module cache names passed to `requireProjectModule` use dots such as `"game.Game"`.
7. For small prototypes, prefer one self-contained `init.ts` first; refactor into modules only when it is already running or the user asks.
8. Replace any `any` or bare `null` introduced during implementation before building.
9. Run `build` on the changed file/project when available.
10. Build success is not just the top-level `success` field. Inspect per-file `messages`; if any message reports failure or diagnostics, fix them before finishing.
11. If TS build says the Web IDE/transpile service is not connected, tell the user to open the Web IDE/keep Dora running, or use the existing project build path if available.
12. When a runtime validation tool is available, follow its active skill and tool description exactly; do not assume it is a general-purpose shell.
13. When several related fixes are in one authored file, combine them into one coherent edit when practical, then build immediately. Do not repeatedly edit one assertion at a time without rerunning the smallest relevant test.
14. Diagnose authored game logic and test fixtures before inspecting generated Lua. Check fixture preconditions, automatic state transitions, time-step clamping, and terminal-state resets first.
15. Files under `.agent/main` are the main Agent's persistent memory. You may edit them deliberately to record durable project knowledge, user decisions, or a precise active checkpoint. Keep the existing structure, avoid duplicating transient progress, and let later consolidation merge the update with newer evidence. Memory-only edits do not require a project build. When proactively updating one memory file, read it once and apply one coherent edit that updates every affected section; do not spend separate decisions editing its status, architecture, decisions, and known issues one section at a time.
16. The engine dynamically exposes tools according to the current coding phase. For authored project files, make at most three coherent `edit_file`/`delete_file` actions in one cycle, then build the affected project or files before expanding the change. If an edit tool is temporarily absent, follow the visible build action instead of restarting discovery; a successful build restores the next phase's applicable tools.
17. When a deterministic `runTests()` report starts with `failed`, read only the failing authored function and its fixture, make one minimal source/test batch, build, and rerun the same test. Do not instantiate compiled TypeScript classes from Lua, inspect generated Lua, or issue exploratory command probes. If more observability is necessary, add a bounded assertion or exported diagnostic to the authored TypeScript test, then build it.
18. If the model clamps each `step(dt)` to a maximum frame delta, never use one oversized `step(totalTime)` in a fixture to advance timers or trigger spawning unless the test is specifically checking the clamp. Use a bounded fixed-step helper that accumulates time, assert the expected state exists, then inspect it.
19. For terminal conditions such as filling a board, exhausting lives, reaching a score threshold, or consuming the last target, construct the smallest legal state immediately before the terminal transition and execute one action. Do not simulate the full gameplay history, derive a Hamiltonian route, or retry a long traversal fixture when a direct near-terminal state proves the same rule.

## Game Runtime Acceptance

For a playable game, `build` success and `running=true` are necessary but not sufficient.

1. When a runtime validation tool is available, prefer a pure TypeScript test module that exports a function returning a report whose first line is `passed` or `failed`. Follow the active runtime-tool skill for loading it. Do not create a test entry, schedule, or marker file unless the test specifically needs a running scene.
2. Treat a report whose first line is `failed` as a failed command even if the Lua call itself completed. Fix the smallest authored logic/fixture issue, rebuild, and call `requireProjectModule` again.
3. Keep failure reports bounded and useful: report at most 12 unique failures, never append the same assertion once per retry-loop iteration, and stop a fixture loop immediately when an iteration makes no progress.
4. When an active runtime tool provides entry lifecycle helpers, start the real `init` entry, verify it remains running across at least two observations, exercise at least one meaningful input/state transition when the harness can do so, then stop it and verify it is no longer running.
5. Treat runtime state checks as headless validation only. They do not prove that game objects are visible, correctly layered, legible, or pleasant to play.
6. Before claiming a game is complete, explicitly report visual/manual play status. If no visual inspection tool is available, mark visual validation as `not_run` and ask the caller to launch the game for visual acceptance; never silently equate `running=true` with a visually correct game.
7. When a visual inspection path is available, launch the real project, inspect the initial frame, trigger the primary input, inspect the changed frame, and stop cleanly. Confirm that the playfield, player-controlled object, hazards/targets, HUD, and overlays are visible in the intended z-order.

## Review Checklist Before Finish

- Runtime entry actually starts the game/app.
- No browser DOM/Canvas/Node-only APIs remain in runtime scripts.
- Code imports from Dora runtime modules (`Dora`, `DoraX`, `Platformer`, `ImGui`, `nvg`) as appropriate.
- TypeScript project imports use valid slash-separated Dora root/search-path module names (for example `game/Game`), with no `./`/`../` prefix or source/output file extension; `requireProjectModule` dependency cache names use dots (for example `game.Game`).
- No `any` or bare `null` was added to Dora runtime TypeScript.
- Non-baseline Dora APIs were confirmed with `search_dora_api` or existing correct project code.
- Game loop uses Dora scheduling and `dt`.
- Each node has at most one intended scheduled callback; validation probes do not replace the game loop.
- Rendering nodes are attached to `Director.entry` or an existing Dora node.
- Direct `Director.entry`/`Director.ui` coordinates use screen-center origin with positive X right and positive Y up.
- Input uses Dora input APIs and correct `KeyName` enums.
- Build/transpile was run when possible and per-file messages were checked.
- The actual game entry was launched; initial and post-input frames were visually checked, or visual validation was explicitly reported as not run.
- Opaque background nodes are behind gameplay nodes, and HUD/overlays are above them.
