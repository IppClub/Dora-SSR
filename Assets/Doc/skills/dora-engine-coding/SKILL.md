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
- JSX/DoraX UI syntax: `import { React, toNode } from 'DoraX';` and use `.tsx`.
- Platformer framework: `import * as Platformer from 'Platformer';` or exact exports found by API search.
- ImGui tools/UI: `import * as ImGui from 'ImGui';` plus enum exports from `ImGui` when needed.
- Vector graphics: `import * as nvg from 'nvg';` when using `VGNode`/NanoVG APIs.
- Do not import React from npm for DoraX runtime code.

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
- Text: `Label('sarasa-mono-sc-regular', size)` and guard because `Label(...)` may return `undefined`.
- Keyboard hold state: `Keyboard.isKeyPressed(KeyName.Left)`.
- One-frame key down/up: `Keyboard.isKeyDown(...)` / `Keyboard.isKeyUp(...)`.
- Screen size: `View.size.width`, `View.size.height`.
- Coordinates: for nodes attached directly to `Director.entry` without extra transforms, the visible world is commonly centered around `(0, 0)`, so screen bounds are often `±View.size.width / 2`, `±View.size.height / 2`. For child nodes or cameras, compute in that node/camera coordinate space instead of assuming DOM top-left coordinates.

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
6. For small prototypes, prefer one self-contained `init.ts` first; refactor into modules only when it is already running or the user asks.
7. Run `build` on the changed file/project when available.
8. Build success is not just the top-level `success` field. Inspect per-file `messages`; if any message reports failure or diagnostics, fix them before finishing.
9. If TS build says the Web IDE/transpile service is not connected, tell the user to open the Web IDE/keep Dora running, or use the existing project build path if available.

## Review Checklist Before Finish

- Runtime entry actually starts the game/app.
- No browser DOM/Canvas/Node-only APIs remain in runtime scripts.
- Code imports from Dora runtime modules (`Dora`, `DoraX`, `Platformer`, `ImGui`, `nvg`) as appropriate.
- Non-baseline Dora APIs were confirmed with `search_dora_api` or existing correct project code.
- Game loop uses Dora scheduling and `dt`.
- Rendering nodes are attached to `Director.entry` or an existing Dora node.
- Input uses Dora input APIs and correct `KeyName` enums.
- Build/transpile was run when possible and per-file messages were checked.
