---
name: music-generation
description: Generate original game audio by authoring a typed exact score or procedural music definition, building it, and invoking the engine Async generator through execute_command.
requiredTools:
  - edit_file
  - build
  - execute_command
---

# Music Generation

Use this skill when a Dora project needs an original musical cue, melody, sound effect, background loop, adaptive stems, stinger, or alternate take.

Read `Agent/Gen/Music.d.ts` for the exact interfaces and enum values. Write a typed TypeScript module under the project's `Music` directory, build it, then call `generateMusicAsync` from `execute_command`.

Choose one generation mode:

- Use `score` for user-specified notes, recognizable melodies, precise rhythm, UI cues, and short musical effects.
- Use `composition` for mood/style-driven background music, procedural structure, intros/outros, and stingers.

Do not put both `score` and `composition` in one definition.

Choose synthesis per track or procedural instrument:

- Use an `instrument` name for resource-independent built-in synthesis.
- Use a `preset: { bank, program }` for SoundFont synthesis. Set `synth.file` to an SF2/SF3 resource whenever any preset is used. Built-in and SoundFont tracks may be mixed in the same definition.

## Exact Score

```ts
// Music/ConfirmCue.ts
import type { MusicDefinition } from "Agent/Gen/Music";

export const definition: MusicDefinition = {
	output: "Audio/confirm_cue.wav",
	synth: {},
	seed: 42,
	score: {
		bpm: 144,
		beatsPerBar: 4,
		bars: 1,
		tracks: [
			{
				instrument: "bell",
				role: "melody",
				notes: [
					{ pitch: "C5", start: 0, duration: 0.5, velocity: 0.9 },
					{ pitch: "E5", start: 0.5, duration: 0.5, velocity: 0.85 },
					{ pitch: "G5", start: 1, duration: 1.5, velocity: 1 },
				],
			},
			{
				instrument: "piano",
				role: "harmony",
				volume: 0.45,
				pedal: [{ start: 0, duration: 2.5 }],
				notes: [
					{ pitch: "C4", start: 0, duration: 2.5 },
					{ pitch: "E4", start: 0, duration: 2.5 },
					{ pitch: "G4", start: 0, duration: 2.5 },
				],
			},
		],
	},
	audio: { volume: 0.8, stereo: true, reverb: 0.12 },
};
```

Pitch accepts MIDI 0–127 or note names such as `C4`, `F#4`, and `Bb3`. Time is measured in beats. Set `beatUnit` to the beat-note denominator, such as `beatsPerBar: 9, beatUnit: 8` for 9/8. A score must last at least 1 second. Use `tempoChanges` for rubato and a piano track's `pedal` intervals for sustain. Set each track's `role` when stem routing matters. Exact scores support stems and MIDI, but not intros/outros or stingers.

The completed mix is automatically normalized to a consistent integrated loudness. `audio.volume` is a linear adjustment around the standard target: `1` is neutral, `0.5` is about 6 dB quieter, and `2` is about 6 dB louder. Peak protection may limit very large boosts. Inspect `loudnessLufs`, `peak`, and `clippingSamples` in the result when tuning output level.

Each exact-score track uses either `instrument` or `preset`, never both. Use `instrument: "drums"` with an optional `drumKit` for built-in percussion. For a SoundFont track, set `preset` and use `percussion: true` for a percussion preset. Rendering fails when a preset is used without `synth.file`, or when the selected SoundFont does not provide the requested bank/program.

For example, a SoundFont piano track starts with:

```ts
synth: { file: "Audio/GeneralUserGS.sf3" },
score: {
	bpm: 72,
	tracks: [{
		preset: { bank: 0, program: 0 },
		notes: [{ pitch: "C4", start: 0, duration: 2 }],
	}],
},
```

## Packaged SoundFont Resource: GeneralUser GS

The engine does not select a SoundFont automatically. To use the packaged resource, set
`synth.file` explicitly to `"Audio/GeneralUserGS.sf3"`. The filename is resolved using the
engine content search paths. Omit `file` when every track uses a built-in instrument.

Read or search the [complete GeneralUser GS preset catalog](Doc/skills/music-generation/GeneralUserGS-Presets.md) for every available
bank, program, and preset name. Use its Bank 128 entries with `percussion: true` for drum kits.

## Built-in Synthesis Presets

Built-in synthesis supports these resource-independent melodic names:

`square`, `pulse`, `saw`, `triangle`, `sine`, `organ`, `piano`, `bell`, `pluck`, `fm`, `pad`, `sub`, `guitar`, and `strings`.

Exact scores additionally support `noise` and `drums`. Built-in drum kits are `acoustic`, `electronic`, `lofi`, and `brush`. Procedural compositions may use `auto` for any built-in instrument; omitting a choice also selects the style default.

These names describe the engine's oscillator, additive, FM, envelope, or procedural-noise models. They are not aliases for GeneralUser GS presets.

## Procedural Music

```ts
// Music/Theme.ts
import type { MusicDefinition } from "Agent/Gen/Music";

export const definition: MusicDefinition = {
	output: "Audio/night_train_jazz_hop.ogg",
	synth: { file: "Audio/GeneralUserGS.sf3" },
	composition: {
		style: "jazz_hop",
		seed: 2407,
		duration: 24,
		tempo: 88,
		key: "C",
		mode: "dorian",
		progression: ["ii", "V", "I", "vi"],
		structure: ["A", "A", "B", "A"],
	},
	arrangement: {
		intensity: 0.84,
		barsPerSection: 2,
		melodyComplexity: 0.5,
		rhythmComplexity: 0.82,
		variation: 0.35,
		drumGain: 8,
	},
	instruments: {
		lead: { bank: 0, program: 26 },
		bass: "sub",
		harmony: { bank: 0, program: 0 },
		drums: { bank: 128, program: 16 },
	},
	effects: { volume: 0.72, stereo: true, reverb: 0.14, delay: 0.08 },
};
```

Use `hiphop` for a punchy swung beat with syncopated kick, layered snare, velocity-shaped hats, and sub bass. Use `jazz_hop` for a warm sample-break feel, heavier dusty drums, ghost notes, loose bass movement, and piano seventh-chord color; select it directly for jazz hip-hop, lo-fi jazz beats, or jazz-influenced boom-bap instead of approximating them with `calm`. Translate named music references into these concrete traits rather than promising an exact artist reproduction.

For a fully resource-independent version, omit the SoundFont file and use only built-in names:

```ts
synth: {},
instruments: { lead: "guitar", bass: "sub", harmony: "piano", drums: "lofi" },
```

SoundFont melodic preset banks are 0–127. Percussion preset banks are 128–255. Use `arrangement.drumGain` only when the requested drums need a different level, and check `peak` and `clippingSamples` after generation.

Procedural duration must be at least 4 seconds and is quantized to complete bars. A fixed seed makes output reproducible. To create another take, copy the TypeScript definition, change its output path, and adjust the seed or other parameters explicitly.

Choose the runtime format by asset type:

- Use a `.wav` output path for short sound effects, UI cues, and stingers.
- Use an `.ogg` output path for longer background music to reduce the packaged asset size.

The `output` extension selects the final mix format. Omit companion exports unless the user explicitly requests them:

- Set `stems: true` only for separate melody, bass, harmony, and drum tracks or adaptive mixing.
- Set `midi: true` only when MIDI is requested.
- Set `introBars`, `outroBars`, or `stinger` only when those separate procedural files are requested.

## Build and Execute

```text
build path="Music/Theme.ts"
```

```lua
local authored = requireProjectModule("Music.Theme")
local music = requireProjectModule("Agent.Gen.Music")
local result = music.generateMusicAsync(
	projectDir,
	authored.definition,
	{ onProgress = reportProgress }
)
assert(result.success, result.message)
print(result.description)
print(table.concat(result.files, "\n"))
```

Set `timeoutSeconds` high enough for the requested duration and companion files. The Async API yields the command coroutine across engine frames and returns `MusicResult` directly.

Use `Audio.playStream(path, true)` for a background loop. Start adaptive stems together and mix their volumes by game state. Do not hand-edit generated Lua.
