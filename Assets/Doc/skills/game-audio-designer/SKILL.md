---
name: game-audio-designer
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

1. Read the game's genre and mood from GameConfig or the task description. If the project has an ASSETS.md, read it for existing audio choices.
2. Use the project file tools to find candidate audio files. Skip macOS metadata files named `._*`.
3. Listen to candidates when possible. If playback is unavailable, use pack and file names as cues and mark the selection as pending listening review.
4. Choose one loopable BGM track and two to five short, distinct sound effects. Record the chosen paths, levels, and rationale in ASSETS.md.

## Game Audio Rules

- Use `AudioSource` for these OGG files. Set `looping` for BGM and leave it false for one-shot sound effects. Set each source's `volume` before playback.
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

```

In the game entry or audio module, replace the placeholder paths with the selected project files:

```typescript
import { AudioSource, Director } from "Dora";
import { AUDIO_CONFIG } from "GameConfig";

const bgm = AudioSource(AUDIO_CONFIG.bgm.path, false);
if (bgm) {
    Director.entry.addChild(bgm);
    bgm.volume = AUDIO_CONFIG.bgm.volume;
    bgm.looping = AUDIO_CONFIG.bgm.loop;
    if (!bgm.playBackground()) bgm.removeFromParent();
}

export function playCue(cue: keyof typeof AUDIO_CONFIG.sfx) {
    const config = AUDIO_CONFIG.sfx[cue];
    const source = AudioSource(config.path);
    if (source) {
        Director.entry.addChild(source);
        source.volume = config.volume;
        if (!source.play()) source.removeFromParent();
    }
}
```

Stop the BGM and remove its node when the owning scene shuts down. Prefer attaching the sources to that scene's root when one is available.

## Verification

Build the project. Then verify each cue in the running game and listen for loop seams and volume balance. To check a selected file with a short Lua playback probe:

```lua
local Dora = require("Dora")
local source = assert(Dora.AudioSource("path/to/selected.ogg"), "Could not create audio source")
Dora.Director.entry:addChild(source)
source.volume = 0.4
if not source:play() then
    source:removeFromParent()
    error("Could not start audio playback")
end
```
