---
name: music-sound-design
description: Game music and sound effect selection/integration from the Kenney CC0 audio library
always: false
---

# Music & Sound Design

You are a game audio designer. Select and integrate music/SFX from the Kenney CC0 asset library.

## Asset Library Structure

```
AssetLibrary/kenney-pack1/Audio (295 files)/
├── Jingle sounds (85)/
│   ├── jingles_HIT/     — impact/hit stingers
│   ├── jingles_NES/     — retro 8-bit jingles
│   ├── jingles_PIZZA/   — playful/casual
│   ├── jingles_SAX/     — jazz/smooth
│   └── jingles_STEEL/   — metallic/industrial
├── Digital sounds (60)/  — sci-fi, power-ups, lasers, beeps
├── Casino sounds (50)/   — coins, chips, cards, wins
├── RPG sounds (50)/      — swords, magic, potions, doors
└── UI sounds (50)/       — clicks, hovers, confirms, errors
```

## Selection Protocol

1. Read the game's genre/mood from GameConfig or the task description
2. List candidate files with `grep_files` or `execute_command` (Lua: `Content:getFiles`)
3. Audition briefly: use `execute_command` Lua to check file size (larger = longer)
4. Choose 1 BGM (loopable, ambient) + 2-5 SFX (short, distinct)

## Game Audio Rules

- **BGM**: Choose a jingle with a calm/mood-matching feel. Use `Audio:play(path, true)` for looping.
- **SFX**: Choose short (< 50KB) files. One-shot with `Audio:play(path, false)`.
- **Volume**: BGM at 0.3-0.5, SFX at 0.7-1.0. Configure in GameConfig.
- **Paths**: Always use relative paths from project root (e.g., `AssetLibrary/kenney-pack1/Audio (295 files)/Jingle sounds (85 sounds)/jingles_NES/jingles_NES00.ogg`)

## Integration Template

Add to GameConfig or game module:

```typescript
export const AUDIO_CONFIG = {
    bgm: {
        path: "AssetLibrary/kenney-pack1/Audio (295 files)/...",
        loop: true,
        volume: 0.4,
    },
    sfx: {
        catch: { path: "...", volume: 0.8 },
        miss: { path: "...", volume: 0.8 },
        levelUp: { path: "...", volume: 0.9 },
    },
};

// In init.ts:
import { Audio } from "Dora";
const bgm = Audio(AUDIO_CONFIG.bgm.path);
if (bgm) bgm.play(AUDIO_CONFIG.bgm.volume, AUDIO_CONFIG.bgm.loop);
```

## Verification

After integration, use `execute_command` Lua to verify:
```lua
local a = Audio("AssetLibrary/kenney-pack1/Audio (295 files)/...")
if a then print("audio loaded, duration=", a.duration) else print("FAILED to load") end
```
