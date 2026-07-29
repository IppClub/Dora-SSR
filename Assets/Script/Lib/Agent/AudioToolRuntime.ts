// @preview-file off clear
import * as AudioGenerator from 'Agent/AudioGenerator';

export type AudioAgentToolName =
	| "generate_sfx"
	| "generate_music"
	| "generate_music_variation";

export type AudioToolProgress = AudioGenerator.GenerateSfxProgress | AudioGenerator.GenerateMusicProgress;

export interface AudioToolExecutionRequest {
	tool: AudioAgentToolName;
	params: Record<string, unknown>;
	workDir: string;
	isCancelled?: () => boolean;
	onProgress?: (progress: AudioToolProgress) => void;
}

export function isAudioAgentToolName(tool: string): tool is AudioAgentToolName {
	return tool === "generate_sfx"
		|| tool === "generate_music"
		|| tool === "generate_music_variation";
}

function hasParam(params: Record<string, unknown>, name: string): boolean {
	return params[name] !== undefined;
}

export function inferAudioToolNameFromParams(params: Record<string, unknown>): AudioAgentToolName | undefined {
	if (hasParam(params, "project") && hasParam(params, "path")) return "generate_music_variation";
	if (hasParam(params, "style") && hasParam(params, "path")) return "generate_music";
	if (hasParam(params, "type") && hasParam(params, "path")) return "generate_sfx";
	return undefined;
}

function stringParam(params: Record<string, unknown>, name: string): string {
	return typeof params[name] === "string" ? params[name] as string : "";
}

function optionalStringParam(params: Record<string, unknown>, name: string): string | undefined {
	return typeof params[name] === "string" ? params[name] as string : undefined;
}

function optionalNumberParam(params: Record<string, unknown>, name: string): number | undefined {
	return typeof params[name] === "number" ? params[name] as number : undefined;
}

function optionalBooleanParam(params: Record<string, unknown>, name: string): boolean | undefined {
	return typeof params[name] === "boolean" ? params[name] as boolean : undefined;
}

export async function executeAudioTool(req: AudioToolExecutionRequest): Promise<AudioGenerator.GenerateSfxResult | AudioGenerator.GenerateMusicResult> {
	const params = req.params;
	if (req.tool === "generate_sfx") {
		return AudioGenerator.generateSfx({
			workDir: req.workDir,
			path: stringParam(params, "path"),
			type: stringParam(params, "type"),
			seed: optionalNumberParam(params, "seed"),
			volume: optionalNumberParam(params, "volume"),
			isCancelled: req.isCancelled,
			onProgress: req.onProgress,
		});
	}
	if (req.tool === "generate_music_variation") {
		return AudioGenerator.generateMusicVariation({
			workDir: req.workDir,
			project: stringParam(params, "project"),
			path: stringParam(params, "path"),
			seed: optionalNumberParam(params, "seed"),
			style: optionalStringParam(params, "style"),
			intensity: optionalNumberParam(params, "intensity"),
			variation: optionalNumberParam(params, "variation"),
			isCancelled: req.isCancelled,
			onProgress: req.onProgress,
		});
	}
	return AudioGenerator.generateMusic({
		workDir: req.workDir,
		path: stringParam(params, "path"),
		style: stringParam(params, "style"),
		seed: optionalNumberParam(params, "seed"),
		duration: optionalNumberParam(params, "duration"),
		bpm: optionalNumberParam(params, "bpm"),
		volume: optionalNumberParam(params, "volume"),
		intensity: optionalNumberParam(params, "intensity"),
		key: optionalStringParam(params, "key"),
		mode: optionalStringParam(params, "mode"),
		progression: optionalStringParam(params, "progression"),
		structure: optionalStringParam(params, "structure"),
		barsPerSection: optionalNumberParam(params, "bars_per_section"),
		melodyComplexity: optionalNumberParam(params, "melody_complexity"),
		rhythmComplexity: optionalNumberParam(params, "rhythm_complexity"),
		variation: optionalNumberParam(params, "variation"),
		leadInstrument: optionalStringParam(params, "lead_instrument"),
		bassInstrument: optionalStringParam(params, "bass_instrument"),
		harmonyInstrument: optionalStringParam(params, "harmony_instrument"),
		stereo: optionalBooleanParam(params, "stereo"),
		reverb: optionalNumberParam(params, "reverb"),
		delay: optionalNumberParam(params, "delay"),
		chorus: optionalNumberParam(params, "chorus"),
		distortion: optionalNumberParam(params, "distortion"),
		bitCrush: optionalNumberParam(params, "bit_crush"),
		lowPass: optionalNumberParam(params, "low_pass"),
		stems: optionalBooleanParam(params, "stems"),
		introBars: optionalNumberParam(params, "intro_bars"),
		outroBars: optionalNumberParam(params, "outro_bars"),
		stinger: optionalStringParam(params, "stinger"),
		exportMidi: optionalBooleanParam(params, "export_midi"),
		isCancelled: req.isCancelled,
		onProgress: req.onProgress,
	});
}
