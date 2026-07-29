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

function parseTonality(value: string | undefined): { key?: string; mode?: string; error?: string } {
	const text = (value ?? "auto").trim();
	if (text === "" || text.toLowerCase() === "auto") return {};
	const parts = text.split(" ").filter(part => part !== "");
	const key = parts[0]?.toUpperCase();
	const mode = parts.length > 1 ? parts.slice(1).join("_").toLowerCase() : undefined;
	const validKeys: string[] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
	const validModes: string[] = ["major", "minor", "pentatonic", "harmonic_minor", "dorian", "phrygian", "chromatic"];
	if (!key || validKeys.indexOf(key) < 0) return { error: `invalid tonality '${text}': expected a key such as D or F# dorian` };
	if (mode !== undefined && validModes.indexOf(mode) < 0) return { error: `invalid tonality '${text}': unknown mode '${mode}'` };
	return { key, mode };
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
			intensity: optionalNumberParam(params, "intensity"),
			variation: optionalNumberParam(params, "variation"),
			isCancelled: req.isCancelled,
			onProgress: req.onProgress,
		});
	}
	const tonality = parseTonality(optionalStringParam(params, "tonality"));
	const assetPack = optionalStringParam(params, "asset_pack") ?? "loop";
	if (tonality.error) return { success: false, path: stringParam(params, "path"), message: tonality.error };
	if (["loop", "adaptive", "cinematic", "full"].indexOf(assetPack) < 0) {
		return { success: false, path: stringParam(params, "path"), message: `invalid asset_pack '${assetPack}'` };
	}
	const cinematic = assetPack === "cinematic" || assetPack === "full";
	const adaptive = assetPack === "adaptive" || assetPack === "full";
	return AudioGenerator.generateMusic({
		workDir: req.workDir,
		path: stringParam(params, "path"),
		style: stringParam(params, "style"),
		seed: optionalNumberParam(params, "seed"),
		duration: optionalNumberParam(params, "duration"),
		bpm: optionalNumberParam(params, "bpm"),
		intensity: optionalNumberParam(params, "intensity"),
		key: tonality.key,
		mode: tonality.mode,
		stems: adaptive,
		introBars: cinematic ? 1 : 0,
		outroBars: cinematic ? 1 : 0,
		stinger: cinematic ? "both" : "none",
		exportMidi: assetPack === "full",
		isCancelled: req.isCancelled,
		onProgress: req.onProgress,
	});
}
