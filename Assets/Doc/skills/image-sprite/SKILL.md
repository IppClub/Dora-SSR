---
name: image-sprite
description: Use this skill when a Dora project contains .sprite.json image-sprite assets or when writing game code that plays AI-generated sprite sheets.
---

# Image Sprite Runtime Usage

Use this skill when the project contains files such as `*.sprite.json`, `*.idle_front.png`, `*.idle_back.png`, `*.idle_left.png`, or `*.idle_right.png`, or when the user asks to use generated character sprite assets in Dora runtime code.

## Asset Model

Image Sprite Editor produces three kinds of files in the same project folder:

```text
hero.sprite.json          # metadata for generated actions and frame rects
hero.portrait.png         # character identity reference image
hero.idle_front.png       # runtime sprite sheet image
hero.idle_back.png
hero.idle_left.png
hero.idle_right.png
```

The runtime image sheet is a horizontal, transparent-background PNG. Do not expect or preserve a green background in runtime code; green is only an internal generation/cropping aid.

Current editor default frame size is 128×128, but Dora runtime code should not hard-code 128 unless there is no metadata. Prefer reading the metadata or rely on Dora `Frame()` when the sheet is a horizontal square-frame sheet.

## Dora Runtime Rule

For simple horizontal sheets, use Dora `Frame` directly:

```ts
import { Director, Frame, Rect, Sprite, Texture2D, Vec2 } from "Dora";

const image = "hero.idle_front.png";
const texture = Texture2D(image);
if (texture !== undefined) {
	const player = Sprite(texture, Rect(0, 0, 128, 128));
	if (player !== undefined) {
		player.anchor = Vec2(0.5, 1);
		player.scaleX = player.scaleY = 3; // example preview scale; keep it uniform
		player.runAction(Frame(image, 0.5), true);
		Director.entry.addChild(player);
	}
}
```

Dora `Frame(clipStr, duration)` automatically divides a horizontal sheet by `image width / image height`. For example, a 512×128 sheet becomes 4 frames.

## Fix Runtime Proportions Before Playing

Do not create a sprite from a horizontal sheet and leave its content size as the whole sheet. A 512×128 sheet has a 4:1 aspect ratio. If the sprite is constructed from the full sheet, then later `Frame()` swaps 128×128 frame rects into that 512×128 content size, the character is stretched flat in Dora.

Use the `Texture2D + first-frame Rect` Sprite constructor before `runAction`:

```ts
import { Frame, Rect, Sprite, Texture2D, Vec2 } from "Dora";

const image = "hero.idle_front.png";
const firstFrame = { x: 0, y: 0, width: 128, height: 128 };
const texture = Texture2D(image);
if (texture !== undefined) {
	const player = Sprite(texture, Rect(firstFrame.x, firstFrame.y, firstFrame.width, firstFrame.height));
	if (player !== undefined) {
		player.anchor = Vec2(0.5, 1);
		player.scaleX = player.scaleY = 3; // preserve aspect ratio; only use uniform scale
		player.runAction(Frame(image, 0.5), true);
	}
}
```

Do not rely on this pattern for horizontal sheets:

```ts
const player = Sprite(image);
player.textureRect = Rect(0, 0, 128, 128); // not enough: content size may remain 512×128
```

When `.sprite.json` is available, use `action.frames[0].rect` instead of hard-coding `128`. When metadata is unavailable and the sheet is a horizontal square-frame sheet, compute `frameSize = imageHeight` and use `Rect(0, 0, frameSize, frameSize)`.

Only resize the character with uniform scale:

```ts
const scale = 1.5;
player.scaleX = player.scaleY = scale;
```

Never compensate by setting `scaleX` and `scaleY` to different values unless the user explicitly asks for a squash/stretch effect.

## Remove Green-Screen Edge Spill

If a character shows green pixels around the silhouette in Dora, fix the exported PNG rather than runtime code. Green edges usually come from green-screen cleanup or texture filtering sampling RGB values stored under transparent pixels.

Required export cleanup:

- Remove visible green-dominant fringe pixels adjacent to transparency.
- Despill remaining green edge pixels by reducing the green channel.
- Never leave transparent pixels as `rgba(0, 255, 0, 0)`.
- Bleed nearby foreground RGB into transparent pixels while keeping alpha `0`, so texture filtering does not sample green.

The image-sprite generator performs this cleanup during packing. For an existing sheet, run:

```sh
cd Tools/dora-dora
pnpm clean-image-sprite-edges /path/to/hero.idle_front.png /path/to/hero.idle_front.clean.png
```

Then update `.sprite.json` to point at the clean PNG, or replace the original after keeping a backup.

## Compute Duration From Metadata

When `.sprite.json` is available, compute total action duration as:

```text
durationSeconds = frames.length / fps
```

Example for 4 frames at 8 FPS:

```text
4 / 8 = 0.5 seconds
```

Use that value in `Frame(image, durationSeconds)`.

## Resource Paths

Use project-relative Dora asset paths. If files are in the project root:

```ts
Frame("hero.idle_front.png", 0.5)
```

If files are in a subfolder:

```ts
Frame("Characters/hero.idle_front.png", 0.5)
```

Do not use absolute filesystem paths in Dora runtime code.

## Recommended Helper Module

When more than one character/action is used, create a reusable helper instead of duplicating logic in `init.ts`:

```ts
import { Frame, Rect, Sprite, Texture2D, Vec2 } from "Dora";

export interface ImageSpriteActionSpec {
	image: string;
	fps: number;
	frames: Array<{
		rect: { x: number; y: number; width: number; height: number };
		pivotX?: number;
		pivotY?: number;
	}>;
}

export function createImageSpritePlayer(action: ImageSpriteActionSpec, uniformScale = 3) {
	const firstFrame = action.frames[0];
	if (firstFrame === undefined) return undefined;
	const texture = Texture2D(action.image);
	if (texture === undefined) return undefined;
	const rect = firstFrame.rect;
	const sprite = Sprite(texture, Rect(rect.x, rect.y, rect.width, rect.height));
	if (sprite === undefined) return undefined;
	sprite.anchor = Vec2(firstFrame.pivotX ?? 0.5, firstFrame.pivotY ?? 1);
	sprite.scaleX = sprite.scaleY = uniformScale;
	const duration = Math.max(1, action.frames.length) / Math.max(1, action.fps);
	sprite.runAction(Frame(action.image, duration), true);
	return sprite;
}
```

Then call it from scene code.

## When Writing Game Code

1. Search/read the relevant `.sprite.json` first.
2. Locate the selected action and its `image`, `fps`, and `frames`.
3. Run the image-sprite quality gate when creating, accepting, or debugging generated sheets.
4. Create `Texture2D(action.image)`, then `Sprite(texture, firstFrameRect)`, set a bottom-center anchor and uniform scale, then call `Frame(action.image, frames.length / fps)`.
5. Add the sprite to `Director.entry` or the scene root used by the project.
6. Keep generated code modular; avoid dumping all asset handling into `init.ts` if multiple sprites/actions exist.

## Quality Gate Before Accepting Generated Sheets

Generated characters should be usable immediately. Run the reusable evaluator before accepting a generated sprite sheet:

```sh
cd Tools/dora-dora
pnpm evaluate-image-sprite /path/to/hero.sprite.json
```

Exit codes:

- `0` / `pass`: accept the sheet.
- `2` / `fixable`: registration jitter is small; run with `--fix fixed.png` and use the aligned PNG, or regenerate.
- `3` / `fail`: regenerate the image sprite.

The evaluator checks metadata/image consistency, empty frames, foot/bottom jitter, lower-body anchor jitter, and temporal continuity. Temporal continuity compares every adjacent frame transition, including the last-to-first loop transition, so near-duplicate frames mixed with large jumps are rejected as visible stutter.

The dora-dora image-sprite generation panel runs the same quality gate immediately after generation and before uploading the sheet into the project. Failed sheets are not accepted into the project; the user should regenerate them.

Example auto-alignment for small jitter:

```sh
pnpm evaluate-image-sprite /path/to/hero.sprite.json --fix /path/to/hero.idle_right.fixed.png
pnpm evaluate-image-sprite /path/to/hero.sprite.json --image /path/to/hero.idle_right.fixed.png
```

Only use the fixed PNG if the second command passes. If it still reports `fixable` or `fail`, regenerate the sheet instead of compensating in runtime code.

Auto-alignment only fixes registration jitter. If the evaluator reports temporal issues such as `near-duplicate transition` or `temporal motion imbalance`, regenerate the sprite frames or add proper in-between frames; runtime code cannot make a discontinuous sheet look smooth.

## Avoid

- Do not use browser Canvas/DOM to play sprites in Dora runtime code.
- Do not hand-slice frames with custom timers if `Frame()` can play the horizontal sheet.
- Do not hard-code absolute paths.
- Do not use `Sprite("sheet.png")` plus later `textureRect` assignment for horizontal sprite sheets; construct with `Sprite(Texture2D("sheet.png"), firstFrameRect)` so content size is square from the start.
- Do not fix flattened characters with non-uniform `scaleX`/`scaleY`; fix the frame rect first, then apply uniform scale only.
- Do not assume green background should render; exported runtime sheets should be transparent.
- Do not accept generated sheets that fail the quality gate.
