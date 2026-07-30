// @preview-file off clear
import * as AudioGenerator from 'Agent/AudioGenerator';

export type MusicMode = "auto" | "major" | "minor" | "pentatonic" | "harmonic_minor" | "dorian" | "phrygian" | "chromatic";
export type MusicInstrument = "auto" | "square" | "pulse" | "saw" | "triangle" | "sine" | "organ" | "bell" | "pluck" | "fm" | "pad" | "sub" | "guitar" | "strings";
export type MusicStinger = "none" | "victory" | "failure" | "both";

export interface MusicJob {
	output: string;
	composition: {
		style: AudioGenerator.GenerateMusicStyle;
		seed?: number;
		duration?: number;
		tempo?: number;
		key?: string;
		mode?: MusicMode;
		progression?: string[];
		structure?: string[];
	};
	arrangement?: {
		intensity?: number;
		barsPerSection?: number;
		melodyComplexity?: number;
		rhythmComplexity?: number;
		variation?: number;
	};
	instruments?: {
		lead?: MusicInstrument;
		bass?: MusicInstrument;
		harmony?: MusicInstrument;
	};
	effects?: {
		volume?: number;
		stereo?: boolean;
		reverb?: number;
		delay?: number;
		chorus?: number;
		distortion?: number;
		bitCrush?: number;
		lowPass?: number;
	};
	exports?: {
		stems?: boolean;
		introBars?: number;
		outroBars?: number;
		stinger?: MusicStinger;
		midi?: boolean;
	};
}

export interface AudioJobHooks {
	isCancelled?: () => boolean;
	onProgress?: (progress: AudioGenerator.GenerateMusicProgress) => void;
}

const VALID_STYLES: string[] = ["chiptune", "adventure", "calm", "tense", "victory", "random"];
const VALID_MODES: string[] = ["auto", "major", "minor", "pentatonic", "harmonic_minor", "dorian", "phrygian", "chromatic"];
const VALID_INSTRUMENTS: string[] = ["auto", "square", "pulse", "saw", "triangle", "sine", "organ", "bell", "pluck", "fm", "pad", "sub", "guitar", "strings"];
const VALID_STINGERS: string[] = ["none", "victory", "failure", "both"];
const VALID_KEYS: string[] = ["random", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

export function defineMusic(job: MusicJob): MusicJob {
	return job;
}

function invalid(job: MusicJob, message: string): AudioGenerator.GenerateMusicResult {
	return { success: false, path: job.output, message: `invalid audio job: ${message}` };
}

function validateRange(value: number | undefined, name: string, min: number, max: number): string | undefined {
	if (value === undefined) return undefined;
	if (value !== value || value < min || value > max) return `${name} must be between ${tostring(min)} and ${tostring(max)}`;
	return undefined;
}

function validateStringList(values: string[] | undefined, name: string): string | undefined {
	if (values === undefined) return undefined;
	if (values.length === 0) return `${name} must not be empty`;
	for (let i = 0; i < values.length; i++) {
		if (typeof values[i] !== "string" || values[i].trim() === "") return `${name}[${tostring(i)}] must be a non-empty string`;
	}
	return undefined;
}

function validateJob(job: MusicJob): string | undefined {
	const output = (job.output ?? "").trim();
	if (output === "" || !output.toLowerCase().endsWith(".wav")) return "output must be a workspace-relative .wav path";
	if (output.indexOf("..") >= 0 || output.indexOf("/") === 0 || output.indexOf("\\") === 0) return "output must stay inside the project";
	if (!job.composition) return "composition is required";
	if (VALID_STYLES.indexOf(job.composition.style) < 0) return `unknown style '${tostring(job.composition.style)}'`;
	const durationError = validateRange(job.composition.duration, "composition.duration", 4, 32);
	if (durationError) return durationError;
	const tempoError = validateRange(job.composition.tempo, "composition.tempo", 60, 200);
	if (tempoError) return tempoError;
	if (job.composition.key !== undefined && VALID_KEYS.indexOf(job.composition.key) < 0) return `unknown key '${job.composition.key}'`;
	if (job.composition.mode !== undefined && VALID_MODES.indexOf(job.composition.mode) < 0) return `unknown mode '${job.composition.mode}'`;
	const progressionError = validateStringList(job.composition.progression, "composition.progression");
	if (progressionError) return progressionError;
	const structureError = validateStringList(job.composition.structure, "composition.structure");
	if (structureError) return structureError;
	const arrangement = job.arrangement;
	if (arrangement) {
		const intensityError = validateRange(arrangement.intensity, "arrangement.intensity", 0, 1);
		if (intensityError) return intensityError;
		const barsError = validateRange(arrangement.barsPerSection, "arrangement.barsPerSection", 1, 8);
		if (barsError) return barsError;
		const melodyError = validateRange(arrangement.melodyComplexity, "arrangement.melodyComplexity", 0, 1);
		if (melodyError) return melodyError;
		const rhythmError = validateRange(arrangement.rhythmComplexity, "arrangement.rhythmComplexity", 0, 1);
		if (rhythmError) return rhythmError;
		const variationError = validateRange(arrangement.variation, "arrangement.variation", 0, 1);
		if (variationError) return variationError;
	}
	const instruments = job.instruments;
	if (instruments) {
		if (instruments.lead !== undefined && VALID_INSTRUMENTS.indexOf(instruments.lead) < 0) return `unknown lead instrument '${instruments.lead}'`;
		if (instruments.bass !== undefined && VALID_INSTRUMENTS.indexOf(instruments.bass) < 0) return `unknown bass instrument '${instruments.bass}'`;
		if (instruments.harmony !== undefined && VALID_INSTRUMENTS.indexOf(instruments.harmony) < 0) return `unknown harmony instrument '${instruments.harmony}'`;
	}
	const effects = job.effects;
	if (effects) {
		const volumeError = validateRange(effects.volume, "effects.volume", 0, 1);
		if (volumeError) return volumeError;
		const reverbError = validateRange(effects.reverb, "effects.reverb", 0, 1);
		if (reverbError) return reverbError;
		const delayError = validateRange(effects.delay, "effects.delay", 0, 1);
		if (delayError) return delayError;
		const chorusError = validateRange(effects.chorus, "effects.chorus", 0, 1);
		if (chorusError) return chorusError;
		const distortionError = validateRange(effects.distortion, "effects.distortion", 0, 1);
		if (distortionError) return distortionError;
		const bitCrushError = validateRange(effects.bitCrush, "effects.bitCrush", 0, 1);
		if (bitCrushError) return bitCrushError;
		const lowPassError = validateRange(effects.lowPass, "effects.lowPass", 0, 1);
		if (lowPassError) return lowPassError;
	}
	const exports = job.exports;
	if (exports) {
		const introError = validateRange(exports.introBars, "exports.introBars", 0, 8);
		if (introError) return introError;
		const outroError = validateRange(exports.outroBars, "exports.outroBars", 0, 8);
		if (outroError) return outroError;
		if (exports.stinger !== undefined && VALID_STINGERS.indexOf(exports.stinger) < 0) return `unknown stinger '${exports.stinger}'`;
	}
	return undefined;
}

export function renderMusic(workDir: string, job: MusicJob, hooks?: AudioJobHooks): Promise<AudioGenerator.GenerateMusicResult> {
	const validationError = validateJob(job);
	if (validationError) return Promise.resolve(invalid(job, validationError));
	return AudioGenerator.generateMusic({
		workDir,
		path: job.output,
		style: job.composition.style,
		seed: job.composition.seed,
		duration: job.composition.duration,
		bpm: job.composition.tempo,
		key: job.composition.key,
		mode: job.composition.mode,
		progression: job.composition.progression?.join(","),
		structure: job.composition.structure?.join(","),
		intensity: job.arrangement?.intensity,
		barsPerSection: job.arrangement?.barsPerSection,
		melodyComplexity: job.arrangement?.melodyComplexity,
		rhythmComplexity: job.arrangement?.rhythmComplexity,
		variation: job.arrangement?.variation,
		leadInstrument: job.instruments?.lead,
		bassInstrument: job.instruments?.bass,
		harmonyInstrument: job.instruments?.harmony,
		volume: job.effects?.volume,
		stereo: job.effects?.stereo,
		reverb: job.effects?.reverb,
		delay: job.effects?.delay,
		chorus: job.effects?.chorus,
		distortion: job.effects?.distortion,
		bitCrush: job.effects?.bitCrush,
		lowPass: job.effects?.lowPass,
		stems: job.exports?.stems,
		introBars: job.exports?.introBars,
		outroBars: job.exports?.outroBars,
		stinger: job.exports?.stinger,
		exportMidi: job.exports?.midi,
		isCancelled: hooks?.isCancelled,
		onProgress: hooks?.onProgress,
	});
}
