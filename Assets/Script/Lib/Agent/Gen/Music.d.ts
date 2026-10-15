export type MusicStyle = "chiptune" | "adventure" | "calm" | "tense" | "victory" | "hiphop" | "jazz_hop" | "random";
export type MusicMode = "auto" | "major" | "minor" | "pentatonic" | "harmonic_minor" | "dorian" | "phrygian" | "chromatic";
export type MusicInstrument = "auto" | "square" | "pulse" | "saw" | "triangle" | "sine" | "organ" | "piano" | "bell" | "pluck" | "fm" | "pad" | "sub" | "guitar" | "strings";
export type MusicBuiltinDrumKit = "auto" | "acoustic" | "electronic" | "lofi" | "brush";
export type MusicScoreInstrument = Exclude<MusicInstrument, "auto"> | "noise";
export type MusicStinger = "none" | "victory" | "failure" | "both";
export type MusicStem = "melody" | "bass" | "harmony" | "drums";
/** Selects a preset by its bank and General MIDI program in the active SoundFont. */
export interface MusicPreset {
    bank: number;
    program: number;
}
export interface MusicSynth {
    /** Optional SF2 or SF3 resource filename. Required only when a track or instrument uses a preset. */
    file?: string;
    sampleRate?: number;
    polyphony?: number;
}
export interface MusicNote {
    /** MIDI note number or scientific pitch notation such as C4, F#4, or Bb3. */
    pitch: number | string;
    /** Start position in beats from the beginning of the score. */
    start: number;
    /** Note duration in beats. */
    duration: number;
    /** Linear note gain from 0 to 1. Defaults to 0.8. */
    velocity?: number;
}
export interface MusicPedal {
    /** Pedal-down position in beats. */
    start: number;
    /** Pedal duration in beats. */
    duration: number;
}
export interface MusicTempoChange {
    /** Beat position where the new tempo begins. */
    beat: number;
    /** Tempo from this beat onward. */
    bpm: number;
}
export interface MusicTrackBase {
    notes: MusicNote[];
    volume?: number;
    pan?: number;
    /** Stem used when exports.stems is enabled. Inferred from track order when omitted. */
    role?: MusicStem;
    /** Sustain-pedal intervals for expressive piano scores. */
    pedal?: MusicPedal[];
}
export type MusicBuiltinTrack = MusicTrackBase & {
    preset?: never;
    percussion?: never;
} & ({
    instrument: MusicScoreInstrument;
    drumKit?: never;
} | {
    instrument: "drums";
    drumKit?: Exclude<MusicBuiltinDrumKit, "auto">;
});
export interface MusicSoundFontTrack extends MusicTrackBase {
    instrument?: never;
    drumKit?: never;
    /** Exact preset coordinates in the selected SoundFont. */
    preset: MusicPreset;
    /** Uses the percussion channel. Percussion presets use actual SoundFont banks 128..255. */
    percussion?: boolean;
}
export interface MusicScoreBase {
    bpm: number;
    beatsPerBar?: number;
    /** Beat-note denominator. Defaults to 4; use 8 with beatsPerBar 9 for 9/8. */
    beatUnit?: 2 | 4 | 8 | 16;
    bars?: number;
    /** Optional tempo map. Beat 0 uses bpm unless overridden here. */
    tempoChanges?: MusicTempoChange[];
}
export interface MusicScore extends MusicScoreBase {
    tracks: Array<MusicBuiltinTrack | MusicSoundFontTrack>;
}
export interface MusicAudio {
    /** Linear adjustment around the automatic -14 LUFS target. 1 is neutral; 0.5 is about 6 dB quieter and 2 is about 6 dB louder. */
    volume?: number;
    stereo?: boolean;
    reverb?: number;
    delay?: number;
    chorus?: number;
    distortion?: number;
    bitCrush?: number;
    lowPass?: number;
}
export interface MusicComposition {
    style: MusicStyle;
    seed?: number;
    /** Requested duration in seconds. The rendered loop is quantized to complete bars. */
    duration?: number;
    tempo?: number;
    key?: string;
    mode?: MusicMode;
    progression?: string[];
    structure?: string[];
}
export interface MusicInstruments {
    /** Built-in instrument name, or a melodic SoundFont preset with bank and program in 0..127. */
    lead?: MusicInstrument | MusicPreset;
    /** Built-in instrument name, or a melodic SoundFont preset with bank and program in 0..127. */
    bass?: MusicInstrument | MusicPreset;
    /** Built-in instrument name, or a melodic SoundFont preset with bank and program in 0..127. */
    harmony?: MusicInstrument | MusicPreset;
    /** Built-in drum-kit name, or a SoundFont percussion preset using bank 128..255. */
    drums?: MusicBuiltinDrumKit | MusicPreset;
}
export interface MusicDefinitionBase {
    /** Project-relative output path. Use .wav for short assets or .ogg for compressed music. */
    output: string;
    arrangement?: {
        intensity?: number;
        barsPerSection?: number;
        melodyComplexity?: number;
        rhythmComplexity?: number;
        variation?: number;
        /** Linear gain for the procedural drum bus from 0 to 8. */
        drumGain?: number;
    };
    effects?: MusicAudio;
    /** Alias retained for exact-score definitions authored against the earlier API. */
    audio?: MusicAudio;
    exports?: {
        stems?: boolean;
        introBars?: number;
        outroBars?: number;
        stinger?: MusicStinger;
        midi?: boolean;
    };
    /** Seed used by exact-score rendering. Procedural compositions use composition.seed. */
    seed?: number;
}
export type MusicDefinition = MusicDefinitionBase & ({
    synth: MusicSynth;
    score: MusicScore;
    composition?: never;
    instruments?: never;
} | {
    synth: MusicSynth;
    composition: MusicComposition;
    score?: never;
    instruments?: MusicInstruments;
});
export interface MusicProgress {
    stage: "compose" | "synth" | "write";
    progress: number;
    message: string;
}
export interface MusicHooks {
    onProgress?: (this: void, progress: MusicProgress) => void;
}
export type MusicResult = {
    success: true;
    path: string;
    files: string[];
    midiPath?: string;
    bytesWritten: number;
    durationSeconds: number;
    sampleRate: number;
    channels: number;
    /** Maximum true-peak amplitude after automatic loudness normalization. */
    peak: number;
    /** Number of generated samples that exceeded the output range before clamping. */
    clippingSamples: number;
    /** Integrated loudness of the main output after normalization, in LUFS. */
    loudnessLufs: number;
    /** Gain applied by automatic loudness normalization. */
    normalizationGain: number;
    seed: number;
    style: string;
    bpm: number;
    bars: number;
    key: string;
    mode: string;
    description: string;
} | {
    success: false;
    path?: string;
    message: string;
};
/**
 * Returns a music definition unchanged so authored definitions remain type-checked and reusable.
 */
export declare function defineMusic(definition: MusicDefinition): MusicDefinition;
/**
 * Generates the requested WAV or Ogg file and any companion assets.
 *
 * Call this function from a yieldable Dora coroutine. Output paths are resolved relative to
 * `projectDir`. SoundFont filenames are resolved through the engine content search paths.
 * Inspect `result.success` before using the generated files.
 *
 * @param projectDir The project directory where generated files are saved.
 * @param definition The exact score or procedural composition and its output options.
 * @param hooks Optional progress reporting callback.
 * @returns A success result containing generated project-relative paths, or a failure result with a message.
 */
export declare function generateMusicAsync(projectDir: string, definition: MusicDefinition, hooks?: MusicHooks): MusicResult;
