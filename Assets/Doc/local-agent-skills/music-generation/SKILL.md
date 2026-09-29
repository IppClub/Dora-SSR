---
name: music-generation
description: Create original Dora game music or sound effects from typed score or procedural definitions through the Dora CLI command bridge.
---
<!-- dora-managed-skill:music-generation:v1 -->

# Music Generation

Use this skill for an original cue, melody, sound effect, background loop, adaptive stems, stinger, or alternate take in a Dora project.

Read [Music.d.ts](references/Music.d.ts) for exact interfaces and enum values. For SoundFont patches, also read [GeneralUserGS-Presets.md](references/GeneralUserGS-Presets.md).

## Workflow

1. Author a typed module such as `Music/Theme.ts` exporting `definition: MusicDefinition`.
2. Choose exactly one mode: `score` for exact notes and rhythm, or `composition` for mood/style-driven procedural music.
3. Build it with `dora cli build -p <project> -f Music/Theme.ts`.
4. Write `.agent/music-command.json` and invoke it with `dora cli agent command -p <project> --input .agent/music-command.json`.
5. Inspect the JSON result, generated files, loudness, peak, and clipping evidence. Remove temporary request files when done.

Minimal exact score:

```ts
import type { MusicDefinition } from "Agent/Gen/Music";

export const definition: MusicDefinition = {
  output: "Audio/confirm.wav",
  synth: {},
  seed: 42,
  score: {
    bpm: 144,
    beatsPerBar: 4,
    bars: 1,
    tracks: [{
      instrument: "bell",
      role: "melody",
      notes: [
        {pitch: "C5", start: 0, duration: 0.5, velocity: 0.9},
        {pitch: "E5", start: 0.5, duration: 0.5, velocity: 0.85},
        {pitch: "G5", start: 1, duration: 1.5, velocity: 1}
      ]
    }]
  },
  audio: {volume: 0.8, stereo: true, reverb: 0.12}
};
```

Use a request like this after the module is built:

```json
{
  "mode": "lua",
  "code": "local authored = requireProjectModule('Music.Theme')\nlocal music = requireProjectModule('Agent.Gen.Music')\nlocal result = music.generateMusicAsync(projectDir, authored.definition, {onProgress = reportProgress})\nassert(result.success, result.message)\nprint(result.description)\nprint(table.concat(result.files, '\\n'))",
  "timeoutSeconds": 600
}
```

Use `.wav` for short cues and effects, `.ogg` for longer background music. Built-in instruments require no external resource. A SoundFont preset requires `synth.file`, for example `Audio/GeneralUserGS.sf3`; melodic banks are 0–127 and percussion banks are 128–255.

Exact scores can export stems and MIDI but not intros, outros, or stingers. Procedural compositions support structured sections and companion files. Request these only when needed. Use a fixed seed for reproducibility and a changed seed for an alternate take. Do not hand-edit generated Lua.
