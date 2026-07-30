// @preview-file off clear
import { Content, Path, Director, once, HttpServer, emit } from 'Dora';
import { Log, safeJsonDecode, safeJsonEncode } from 'Agent/Utils';

function isValidWorkspacePath(path: string): boolean {
	if (!path || path.length === 0) return false;
	if (Content.isAbsolutePath(path)) return false;
	if (path.includes("..")) return false;
	return true;
}

function isValidWorkDir(workDir: string): boolean {
	if (!workDir || workDir.length === 0) return false;
	if (!Content.isAbsolutePath(workDir)) return false;
	if (!Content.exist(workDir) || !Content.isdir(workDir)) return false;
	return true;
}

function resolveWorkspaceFilePath(workDir: string, path: string): string | undefined {
	if (!isValidWorkDir(workDir)) return undefined;
	if (!isValidWorkspacePath(path)) return undefined;
	return Path(workDir, path);
}

function ensureDirPath(dir: string): boolean {
	if (!dir || dir === "." || dir === "") return true;
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent !== dir && parent !== "." && parent !== "") {
		if (!ensureDirPath(parent)) return false;
	}
	return Content.mkdir(dir);
}

function ensureDirForFile(path: string): boolean {
	return ensureDirPath(Path.getPath(path));
}

let operationIdStep = 0;

function createOperationId(): string {
	operationIdStep += 1;
	const raw = tostring(os.time()) + "-" + tostring(operationIdStep) + "-" + tostring(math.floor(math.random() * 1000000000));
	const [safe] = string.gsub(raw, "[^%w%-_]", "-");
	return safe;
}

function sendWebIDEFileUpdate(file: string, exists: boolean, content: string): boolean {
	if (HttpServer.wsConnectionCount === 0) return true;
	const [payload] = safeJsonEncode({ name: "UpdateFile", file, exists, content });
	if (!payload) return false;
	emit("AppWS", "Send", payload);
	return true;
}

function syncGeneratedFileToWebIDE(file: string): boolean {
	let content = "";
	try {
		const [, isBinary] = Content.getAttr(file);
		if (!isBinary) {
			const loaded = Content.load(file);
			content = typeof loaded === "string" ? loaded : "";
		}
	} catch (e) {
		Log("Warn", "[Agent.AudioGenerator] failed to inspect generated file for Web IDE update file=" + file + ": " + tostring(e));
	}
	return sendWebIDEFileUpdate(file, true, content);
}

export type GenerateSfxProgress = {
	state: "pending" | "running";
	operationId: string;
	path: string;
	stage?: string;
	message?: string;
};

export type GenerateSfxResult = {
	success: true;
	path: string;
	bytesWritten: number;
	durationSeconds: number;
	sampleRate: number;
	seed: number;
	description: string;
} | {
	success: false;
	path?: string;
	message: string;
	interrupted?: boolean;
};

export type GenerateSfxPresetKind =
	| "jump"
	| "explosion"
	| "hit"
	| "pickup"
	| "laser"
	| "powerup"
	| "click"
	| "random";

const SFX_SAMPLE_RATE = 44100;
const SFX_MAX_SAMPLES = SFX_SAMPLE_RATE * 3;
const SFX_OVERSAMPLING = 8;
const SFX_NOISE_SIZE = 32;
const SFX_PHASER_SIZE = 1024;
const SFX_WAV_PACK_CHUNK = 1024;

interface SfxRng {
	next(): number;
}

/**
 * Park-Miller LCG. Math.random is not acceptable here: the same seed must
 * always reproduce the same sound, and ordinary double arithmetic keeps the
 * multiplication exact (state * 16807 stays below 2^53).
 */
function createSfxRng(seed: number): SfxRng {
	let state = math.floor(math.abs(seed)) % 2147483647;
	if (state <= 0) state = 1;
	return {
		next: (): number => {
			state = (state * 16807) % 2147483647;
			return (state - 1) / 2147483646;
		},
	};
}

interface SfxrParams {
	waveType: number;
	startFreq: number;
	minFreq: number;
	slide: number;
	deltaSlide: number;
	duty: number;
	dutySweep: number;
	vibDepth: number;
	vibSpeed: number;
	attack: number;
	sustain: number;
	decay: number;
	punch: number;
	changeAmount: number;
	changeSpeed: number;
	phaserOffset: number;
	phaserSweep: number;
	lpCutoff: number;
	lpCutoffSweep: number;
	lpResonance: number;
	hpCutoff: number;
	hpCutoffSweep: number;
	repeatSpeed: number;
}

function resetSfxrParams(): SfxrParams {
	return {
		waveType: 0,
		startFreq: 0.3,
		minFreq: 0.0,
		slide: 0.0,
		deltaSlide: 0.0,
		duty: 0.0,
		dutySweep: 0.0,
		vibDepth: 0.0,
		vibSpeed: 0.0,
		attack: 0.0,
		sustain: 0.3,
		decay: 0.4,
		punch: 0.0,
		changeAmount: 0.0,
		changeSpeed: 0.0,
		phaserOffset: 0.0,
		phaserSweep: 0.0,
		lpCutoff: 1.0,
		lpCutoffSweep: 0.0,
		lpResonance: 0.0,
		hpCutoff: 0.0,
		hpCutoffSweep: 0.0,
		repeatSpeed: 0.0,
	};
}

/**
 * Preset generators ported from the classic sfxr/as3sfxr randomizers.
 * Parameter names map: changeAmount = arp_mod, changeSpeed = arp_speed.
 */
function generateSfxrPreset(kind: GenerateSfxPresetKind, rng: SfxRng): SfxrParams {
	const rnd = (): number => rng.next();
	const frnd = (range: number): number => rnd() * range;
	const p = resetSfxrParams();
	switch (kind) {
		case "pickup": {
			p.waveType = math.floor(rnd() * 3);
			p.startFreq = 0.4 + frnd(0.5);
			p.attack = 0.0;
			p.sustain = frnd(0.1);
			p.decay = 0.1 + frnd(0.4);
			p.punch = 0.3 + frnd(0.3);
			if (rnd() < 0.5) {
				p.changeSpeed = 0.5 + frnd(0.2);
				p.changeAmount = 0.2 + frnd(0.4);
			}
			break;
		}
		case "laser": {
			p.waveType = math.floor(rnd() * 3);
			if (p.waveType === 2 && rnd() < 0.5) p.waveType = math.floor(rnd() * 2);
			p.startFreq = 0.5 + frnd(0.5);
			p.minFreq = p.startFreq - 0.2 - frnd(0.6);
			if (p.minFreq < 0.2) p.minFreq = 0.2;
			p.slide = -0.15 - frnd(0.2);
			if (rnd() < 0.33) {
				p.startFreq = 0.3 + frnd(0.6);
				p.minFreq = frnd(0.1);
				p.slide = -0.35 - frnd(0.3);
			}
			if (rnd() < 0.5) {
				p.duty = frnd(0.5);
				p.dutySweep = frnd(0.2);
			} else {
				p.duty = 0.4 + frnd(0.5);
				p.dutySweep = -frnd(0.7);
			}
			p.attack = 0.0;
			p.sustain = 0.1 + frnd(0.2);
			p.decay = frnd(0.4);
			if (rnd() < 0.5) p.punch = frnd(0.3);
			if (rnd() < 0.33) {
				p.phaserOffset = frnd(0.2);
				p.phaserSweep = -frnd(0.2);
			}
			if (rnd() < 0.5) p.hpCutoff = frnd(0.3);
			break;
		}
		case "explosion": {
			p.waveType = 3;
			p.startFreq = 0.1 + frnd(0.4);
			p.slide = -0.1 + frnd(0.4);
			p.attack = 0.0;
			p.sustain = 0.1 + frnd(0.2);
			p.decay = frnd(0.5);
			if (rnd() < 0.5) {
				p.phaserOffset = -0.3 + frnd(0.9);
				p.phaserSweep = -frnd(0.3);
			}
			if (rnd() < 0.33) {
				p.startFreq = 0.2 + frnd(0.7);
				p.slide = -0.2 - frnd(0.2);
			}
			if (rnd() < 0.5) p.punch = 0.2 + frnd(0.6);
			break;
		}
		case "powerup": {
			p.waveType = rnd() < 0.5 ? 0 : 1;
			p.startFreq = 0.2 + frnd(0.3);
			p.slide = 0.1 + frnd(0.2);
			p.changeAmount = 0.2 + frnd(0.4);
			p.changeSpeed = 0.6 + frnd(0.3);
			p.attack = 0.0;
			p.sustain = 0.2 + frnd(0.3);
			p.decay = frnd(0.2);
			p.punch = 0.2 + frnd(0.4);
			break;
		}
		case "hit": {
			p.waveType = math.floor(rnd() * 3);
			if (p.waveType === 2) p.waveType = 3;
			p.startFreq = 0.2 + frnd(0.6);
			p.slide = -0.3 - frnd(0.4);
			p.attack = 0.0;
			p.sustain = frnd(0.1);
			p.decay = 0.1 + frnd(0.2);
			if (rnd() < 0.5) p.hpCutoff = frnd(0.3);
			break;
		}
		case "jump": {
			p.waveType = 0;
			p.startFreq = 0.3 + frnd(0.3);
			p.slide = 0.1 + frnd(0.2);
			p.attack = 0.0;
			p.sustain = 0.1 + frnd(0.3);
			p.decay = 0.1 + frnd(0.2);
			if (rnd() < 0.5) {
				p.duty = frnd(0.6);
				p.dutySweep = frnd(0.2);
			}
			break;
		}
		case "click": {
			p.waveType = math.floor(rnd() * 2);
			p.startFreq = 0.2 + frnd(0.4);
			p.attack = 0.0;
			p.sustain = 0.05 + frnd(0.05);
			p.decay = 0.05 + frnd(0.15);
			p.hpCutoff = 0.1;
			break;
		}
		default: {
			const families: GenerateSfxPresetKind[] = ["jump", "explosion", "hit", "pickup", "laser", "powerup", "click"];
			return generateSfxrPreset(families[math.floor(rnd() * families.length)], rng);
		}
	}
	return p;
}

/**
 * Synthesize float samples in [-1, 1] from sfxr parameters. Port of the
 * classic sfxr sample generator: frequency slide, arpeggio, vibrato, square
 * duty sweep, ADSR envelope with punch, one-pole low/high pass filters, and a
 * phaser tap. Length is bounded by the envelope plus SFX_MAX_SAMPLES.
 */
function synthSfxr(p: SfxrParams, masterVolume: number, rng: SfxRng): number[] {
	const samples: number[] = [];
	const startPeriod = 100.0 / (p.startFreq * p.startFreq + 0.001);
	let fperiod = startPeriod;
	let period = math.floor(fperiod);
	const fmaxperiod = 100.0 / (p.minFreq * p.minFreq + 0.001);
	const startSlide = 1.0 - (p.slide ** 3.0) * 0.01;
	let fslide = startSlide;
	const fdslide = -(p.deltaSlide ** 3.0) * 0.000001;
	let squareDuty = 0.5 - p.duty * 0.5;
	const squareSlide = -p.dutySweep * 0.00005;
	const arpMod = p.changeAmount >= 0.0
		? 1.0 - (p.changeAmount ** 2.0) * 0.9
		: 1.0 + (p.changeAmount ** 2.0) * 10.0;
	let arpTime = 0;
	let arpLimit = math.floor(((1.0 - p.changeSpeed) ** 2.0) * 20000.0) + 32;
	if (p.changeSpeed >= 1.0) arpLimit = 0;
	let envStage = 0;
	let envTime = 0;
	const envLength = [
		math.max(1, math.floor(p.attack * p.attack * 100000.0)),
		math.max(1, math.floor(p.sustain * p.sustain * 100000.0)),
		math.max(1, math.floor(p.decay * p.decay * 100000.0)),
	];
	const phaserBuffer: number[] = [];
	for (let i = 0; i < SFX_PHASER_SIZE; i++) phaserBuffer.push(0);
	let fphase = (p.phaserOffset ** 2.0) * 1020.0;
	if (p.phaserOffset < 0.0) fphase = -fphase;
	const fdsweep = (p.phaserSweep ** 2.0) * (p.phaserSweep < 0.0 ? -1.0 : 1.0);
	let iphase = math.floor(math.abs(fphase));
	if (iphase > SFX_PHASER_SIZE - 1) iphase = SFX_PHASER_SIZE - 1;
	let ipp = 0;
	const phaserOn = p.phaserOffset !== 0.0 || p.phaserSweep !== 0.0;
	const noiseBuffer: number[] = [];
	for (let i = 0; i < SFX_NOISE_SIZE; i++) noiseBuffer.push(rng.next() * 2.0 - 1.0);
	let fltp = 0.0;
	let fltdp = 0.0;
	let fltw = (p.lpCutoff ** 3.0) * 0.1;
	const fltwD = 1.0 + p.lpCutoffSweep * 0.0001;
	const fltdmp = (5.0 / (1.0 + (p.lpResonance ** 2.0) * 20.0)) * (0.01 + fltw);
	let fltphp = 0.0;
	let flthp = (p.hpCutoff ** 2.0) * 0.1;
	const flthpD = 1.0 + p.hpCutoffSweep * 0.0003;
	let vibPhase = 0.0;
	const vibSpeed = (p.vibSpeed ** 2.0) * 0.01;
	const vibAmp = p.vibDepth * 0.5;
	let repeatTime = 0;
	const repeatLimit = p.repeatSpeed > 0.0
		? math.floor(((1.0 - p.repeatSpeed) ** 2.0) * 20000.0) + 32
		: 0;
	let phase = 0;
	let finished = false;
	while (!finished && samples.length < SFX_MAX_SAMPLES) {
		repeatTime++;
		if (repeatLimit > 0 && repeatTime >= repeatLimit) {
			repeatTime = 0;
			fperiod = startPeriod;
			fslide = startSlide;
		}
		arpTime++;
		if (arpLimit > 0 && arpTime >= arpLimit) {
			arpLimit = 0;
			fperiod *= arpMod;
		}
		fslide += fdslide;
		fperiod *= fslide;
		if (fperiod > fmaxperiod) {
			fperiod = fmaxperiod;
			if (p.minFreq > 0.0) finished = true;
		}
		let rfperiod = fperiod;
		if (vibAmp > 0.0) {
			vibPhase += vibSpeed;
			rfperiod = fperiod * (1.0 + math.sin(vibPhase) * vibAmp);
		}
		period = math.floor(rfperiod);
		if (period < SFX_OVERSAMPLING) period = SFX_OVERSAMPLING;
		squareDuty += squareSlide;
		if (squareDuty < 0.0) squareDuty = 0.0;
		if (squareDuty > 0.5) squareDuty = 0.5;
		envTime++;
		if (envStage === 0 && envTime >= envLength[0]) {
			envStage = 1;
			envTime = 0;
		} else if (envStage === 1 && envTime >= envLength[1]) {
			envStage = 2;
			envTime = 0;
		} else if (envStage === 2 && envTime >= envLength[2]) {
			finished = true;
		}
		let envVol = 0.0;
		if (envStage === 0) envVol = envTime / envLength[0];
		else if (envStage === 1) envVol = 1.0 + (1.0 - envTime / envLength[1]) * 2.0 * p.punch;
		else envVol = 1.0 - envTime / envLength[2];
		fphase += fdsweep;
		iphase = math.floor(math.abs(fphase));
		if (iphase > SFX_PHASER_SIZE - 1) iphase = SFX_PHASER_SIZE - 1;
		flthp *= flthpD;
		if (flthp < 0.0) flthp = 0.0;
		if (flthp > 0.1) flthp = 0.1;
		let sample = 0.0;
		for (let subSampleIndex = 0; subSampleIndex < SFX_OVERSAMPLING; subSampleIndex++) {
			phase++;
			if (phase >= period) {
				phase = phase % period;
				if (p.waveType === 3) {
					for (let i = 0; i < SFX_NOISE_SIZE; i++) noiseBuffer[i] = rng.next() * 2.0 - 1.0;
				}
			}
			const cyclePos = phase / period;
			let subSample = 0.0;
			if (p.waveType === 0) subSample = cyclePos < squareDuty ? 0.5 : -0.5;
			else if (p.waveType === 1) subSample = 1.0 - cyclePos * 2.0;
			else if (p.waveType === 2) subSample = math.sin(cyclePos * 2.0 * math.pi);
			else subSample = noiseBuffer[math.floor(cyclePos * SFX_NOISE_SIZE)];
			const prevFltp = fltp;
			fltw *= fltwD;
			if (fltw < 0.0) fltw = 0.0;
			if (fltw > 0.1) fltw = 0.1;
			if (p.lpCutoff >= 1.0) {
				fltp = subSample;
				fltdp = 0.0;
			} else {
				fltdp += (subSample - fltp) * fltw;
				fltdp -= fltdp * fltdmp;
				fltp += fltdp;
			}
			fltphp += fltp - prevFltp;
			fltphp -= fltphp * flthp;
			subSample = fltphp;
			if (phaserOn) {
				phaserBuffer[ipp] = subSample;
				subSample += phaserBuffer[(ipp - iphase + SFX_PHASER_SIZE) % SFX_PHASER_SIZE];
				ipp = (ipp + 1) % SFX_PHASER_SIZE;
			}
			sample += subSample * envVol;
		}
		sample = sample / SFX_OVERSAMPLING;
		if (sample > 1.0) sample = 1.0;
		if (sample < -1.0) sample = -1.0;
		samples.push(sample * masterVolume);
	}
	return samples;
}

function encodePcmWav(samples: number[], sampleRate: number, rightSamples?: number[]): string {
	const channels = rightSamples ? 2 : 1;
	const dataSize = samples.length * channels * 2;
	const parts: string[] = [];
	parts.push(string.pack("<c4I4c4", "RIFF", 36 + dataSize, "WAVE"));
	parts.push(string.pack("<c4I4I2I2I4I4I2I2", "fmt ", 16, 1, channels, sampleRate, sampleRate * channels * 2, channels * 2, 16));
	parts.push(string.pack("<c4I4", "data", dataSize));
	for (let start = 0; start < samples.length; start += SFX_WAV_PACK_CHUNK) {
		const end = math.min(start + SFX_WAV_PACK_CHUNK, samples.length);
		let fmt = "<";
		const values: number[] = [];
		for (let i = start; i < end; i++) {
			fmt += "i2";
			const left = samples[i];
			const leftRaw = left >= 0.0 ? math.floor(left * 32767.0 + 0.5) : math.ceil(left * 32768.0 - 0.5);
			values.push(math.max(-32768, math.min(32767, leftRaw)));
			if (rightSamples) {
				fmt += "i2";
				const right = rightSamples[i];
				const rightRaw = right >= 0.0 ? math.floor(right * 32767.0 + 0.5) : math.ceil(right * 32768.0 - 0.5);
				values.push(math.max(-32768, math.min(32767, rightRaw)));
			}
		}
		parts.push(string.pack(fmt, ...values));
	}
	return parts.join("");
}

let sfxAutoSeedStep = 0;

export async function generateSfx(req: {
	workDir: string;
	path: string;
	type: string;
	seed?: number;
	volume?: number;
	onProgress?: (progress: GenerateSfxProgress) => void;
	isCancelled?: () => boolean;
}): Promise<GenerateSfxResult> {
	const relPath = (req.path ?? "").trim();
	if (relPath === "") {
		return { success: false, message: "missing path" };
	}
	if (!relPath.toLowerCase().endsWith(".wav")) {
		return { success: false, path: relPath, message: "generate_sfx writes WAV files; path must end in .wav" };
	}
	const kind = (req.type ?? "").trim().toLowerCase() as GenerateSfxPresetKind;
	const validKinds: string[] = ["jump", "explosion", "hit", "pickup", "laser", "powerup", "click", "random"];
	if (validKinds.indexOf(kind) < 0) {
		return { success: false, path: relPath, message: `unknown type '${req.type}'; expected one of: ${validKinds.join(", ")}` };
	}
	const target = resolveWorkspaceFilePath(req.workDir, relPath);
	if (!target) {
		return { success: false, path: relPath, message: "invalid path" };
	}
	if (Content.exist(target) && Content.isdir(target)) {
		return { success: false, path: relPath, message: "target path is a directory" };
	}
	if (req.isCancelled?.() === true) {
		return { success: false, path: relPath, message: "canceled", interrupted: true };
	}
	sfxAutoSeedStep += 1;
	let seed = 0;
	if (typeof req.seed === "number" && req.seed === req.seed && math.abs(req.seed) < 2147483647) {
		seed = math.floor(req.seed);
	} else {
		seed = (os.time() % 1000000000) + sfxAutoSeedStep * 7919;
	}
	let volume = 0.8;
	if (typeof req.volume === "number" && req.volume === req.volume) {
		volume = math.min(1.0, math.max(0.0, req.volume));
	}
	const operationId = createOperationId();
	const rng = createSfxRng(seed);
	let presetKind = kind;
	if (presetKind === "random") {
		const families: GenerateSfxPresetKind[] = ["jump", "explosion", "hit", "pickup", "laser", "powerup", "click"];
		presetKind = families[math.floor(rng.next() * families.length)];
	}
	req.onProgress?.({
		state: "running",
		operationId,
		path: relPath,
		stage: "synth",
		message: `synthesizing ${presetKind}`,
	});
	const params = generateSfxrPreset(presetKind, rng);
	const samples = synthSfxr(params, volume, rng);
	if (samples.length === 0) {
		return { success: false, path: relPath, message: "synthesis produced no samples" };
	}
	if (req.isCancelled?.() === true) {
		return { success: false, path: relPath, message: "canceled", interrupted: true };
	}
	req.onProgress?.({
		state: "running",
		operationId,
		path: relPath,
		stage: "write",
		message: "writing WAV",
	});
	const wav = encodePcmWav(samples, SFX_SAMPLE_RATE);
	if (!ensureDirForFile(target)) {
		return { success: false, path: relPath, message: "failed to create target directory" };
	}
	if (!Content.save(target, wav)) {
		return { success: false, path: relPath, message: "failed to write WAV file" };
	}
	if (!syncGeneratedFileToWebIDE(target)) {
		Log("Warn", `[generate_sfx] failed to sync file update target=${target}`);
	}
	const durationSeconds = math.floor((samples.length / SFX_SAMPLE_RATE) * 100.0 + 0.5) / 100.0;
	Log("Info", `[generate_sfx] type=${presetKind} seed=${seed} path=${relPath} bytes=${wav.length} samples=${samples.length}`);
	return {
		success: true,
		path: relPath,
		bytesWritten: wav.length,
		durationSeconds,
		sampleRate: SFX_SAMPLE_RATE,
		seed,
		description: `Saved a ${presetKind} sound effect to ${relPath} (${wav.length} bytes, ${durationSeconds}s, mono 16-bit ${SFX_SAMPLE_RATE} Hz, seed ${seed}). Play it with Audio.play("${relPath}") or an audio-source node; regenerate with a new seed or reproduce it with the same seed.`,
	};
}

export type GenerateMusicProgress = {
	state: "pending" | "running";
	operationId: string;
	path: string;
	stage?: string;
	message?: string;
	percent?: number;
};

export type GenerateMusicResult = {
	success: true;
	path: string;
	files: string[];
	projectPath: string;
	midiPath?: string;
	bytesWritten: number;
	durationSeconds: number;
	sampleRate: number;
	channels: number;
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
	interrupted?: boolean;
};

export type GenerateMusicStyle = "chiptune" | "adventure" | "calm" | "tense" | "victory" | "random";
type MusicMode = "major" | "minor" | "pentatonic" | "harmonic_minor" | "dorian" | "phrygian" | "chromatic";
type MusicInstrument = "square" | "pulse" | "saw" | "triangle" | "sine" | "organ" | "bell" | "pluck" | "fm" | "pad" | "sub" | "guitar" | "strings";
type MusicStinger = "none" | "victory" | "failure" | "both";
type MusicRenderKind = "loop" | "intro" | "outro" | "stinger";

interface MusicStyleConfig {
	bpm: number;
	mode: MusicMode;
	progression: number[];
	melodyStepSpan: number;
	melodyDensity: number;
	leadInstrument: MusicInstrument;
	bassInstrument: MusicInstrument;
	harmonyInstrument: MusicInstrument;
	melodyMix: number;
	bassMix: number;
	harmonyMix: number;
	drumMix: number;
	hatStride: number;
	reverb: number;
	delay: number;
	chorus: number;
	distortion: number;
}

interface MusicResolvedOptions {
	style: Exclude<GenerateMusicStyle, "random">;
	seed: number;
	bpm: number;
	bars: number;
	duration: number;
	volume: number;
	intensity: number;
	rootPitchClass: number;
	key: string;
	mode: MusicMode;
	progression: number[];
	progressionText: string;
	structure: string[];
	barsPerSection: number;
	melodyComplexity: number;
	rhythmComplexity: number;
	variation: number;
	leadInstrument: MusicInstrument;
	bassInstrument: MusicInstrument;
	harmonyInstrument: MusicInstrument;
	stereo: boolean;
	reverb: number;
	delay: number;
	chorus: number;
	distortion: number;
	bitCrush: number;
	lowPass: number;
	stems: boolean;
	introBars: number;
	outroBars: number;
	stinger: MusicStinger;
	exportMidi: boolean;
}

interface MusicArrangement {
	melodyNotes: number[];
	melodyAges: number[];
	bassNotes: number[];
	bassAges: number[];
	arpNotes: number[];
	chordRoots: number[];
}

interface StereoSamples {
	left: number[];
	right?: number[];
}

interface MusicRender {
	mix: StereoSamples;
	peak: number;
	clippingSamples: number;
	stems?: {
		melody: StereoSamples;
		bass: StereoSamples;
		harmony: StereoSamples;
		drums: StereoSamples;
	};
}

const MUSIC_SAMPLE_RATE = 44100;
const MUSIC_STEPS_PER_BAR = 16;
const MUSIC_MIN_SECONDS = 4;
const MUSIC_MAX_SECONDS = 32;
const MUSIC_NOISE_SIZE = 2048;
const MUSIC_RENDER_CHUNK = 8192;
const MUSIC_KEY_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
const MUSIC_VALID_MODES: string[] = ["major", "minor", "pentatonic", "harmonic_minor", "dorian", "phrygian", "chromatic"];
const MUSIC_VALID_INSTRUMENTS: string[] = ["square", "pulse", "saw", "triangle", "sine", "organ", "bell", "pluck", "fm", "pad", "sub", "guitar", "strings"];

function clamp01(value: number): number {
	return math.min(1.0, math.max(0.0, value));
}

function getMusicStyleConfig(style: GenerateMusicStyle): MusicStyleConfig {
	switch (style) {
		case "adventure": return {
			bpm: 124, mode: "major", progression: [0, 3, 4, 0], melodyStepSpan: 2,
			melodyDensity: 0.82, leadInstrument: "strings", bassInstrument: "triangle", harmonyInstrument: "organ",
			melodyMix: 0.28, bassMix: 0.24, harmonyMix: 0.15, drumMix: 0.22, hatStride: 2,
			reverb: 0.16, delay: 0.10, chorus: 0.18, distortion: 0.04,
		};
		case "calm": return {
			bpm: 84, mode: "pentatonic", progression: [0, 4, 3, 4], melodyStepSpan: 4,
			melodyDensity: 0.72, leadInstrument: "bell", bassInstrument: "sub", harmonyInstrument: "pad",
			melodyMix: 0.30, bassMix: 0.20, harmonyMix: 0.18, drumMix: 0.10, hatStride: 4,
			reverb: 0.34, delay: 0.16, chorus: 0.28, distortion: 0.0,
		};
		case "tense": return {
			bpm: 152, mode: "minor", progression: [0, 5, 6, 4], melodyStepSpan: 2,
			melodyDensity: 0.88, leadInstrument: "saw", bassInstrument: "saw", harmonyInstrument: "pulse",
			melodyMix: 0.24, bassMix: 0.29, harmonyMix: 0.15, drumMix: 0.26, hatStride: 1,
			reverb: 0.10, delay: 0.08, chorus: 0.10, distortion: 0.20,
		};
		case "victory": return {
			bpm: 148, mode: "major", progression: [0, 3, 4, 0], melodyStepSpan: 2,
			melodyDensity: 0.92, leadInstrument: "square", bassInstrument: "triangle", harmonyInstrument: "organ",
			melodyMix: 0.31, bassMix: 0.22, harmonyMix: 0.18, drumMix: 0.24, hatStride: 2,
			reverb: 0.22, delay: 0.12, chorus: 0.16, distortion: 0.04,
		};
		default: return {
			bpm: 138, mode: "major", progression: [0, 4, 5, 3], melodyStepSpan: 2,
			melodyDensity: 0.86, leadInstrument: "square", bassInstrument: "saw", harmonyInstrument: "pulse",
			melodyMix: 0.28, bassMix: 0.25, harmonyMix: 0.16, drumMix: 0.22, hatStride: 2,
			reverb: 0.10, delay: 0.08, chorus: 0.12, distortion: 0.06,
		};
	}
}

function musicScale(mode: MusicMode): number[] {
	if (mode === "minor") return [0, 2, 3, 5, 7, 8, 10];
	if (mode === "pentatonic") return [0, 2, 4, 7, 9];
	if (mode === "harmonic_minor") return [0, 2, 3, 5, 7, 8, 11];
	if (mode === "dorian") return [0, 2, 3, 5, 7, 9, 10];
	if (mode === "phrygian") return [0, 1, 3, 5, 7, 8, 10];
	if (mode === "chromatic") return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
	return [0, 2, 4, 5, 7, 9, 11];
}

function musicScaleNote(root: number, scale: number[], degree: number): number {
	const octave = math.floor(degree / scale.length);
	const index = degree % scale.length;
	return root + octave * 12 + scale[index];
}

function parseRomanDegree(token: string): number | undefined {
	let normalized = token.trim();
	while (normalized.startsWith("b") || normalized.startsWith("#")) normalized = normalized.slice(1);
	normalized = normalized.toUpperCase();
	if (normalized === "I") return 0;
	if (normalized === "II") return 1;
	if (normalized === "III") return 2;
	if (normalized === "IV") return 3;
	if (normalized === "V") return 4;
	if (normalized === "VI") return 5;
	if (normalized === "VII") return 6;
	return undefined;
}

function parseMusicProgression(text: string | undefined, fallback: number[]): { degrees: number[]; text: string } {
	const normalized = (text ?? "").trim();
	if (normalized === "") return { degrees: fallback.slice(), text: fallback.map(value => tostring(value)).join(",") };
	const tokens = normalized.split(",");
	const degrees: number[] = [];
	for (let i = 0; i < tokens.length; i++) {
		const degree = parseRomanDegree(tokens[i]);
		if (degree === undefined) return { degrees: fallback.slice(), text: fallback.map(value => tostring(value)).join(",") };
		degrees.push(degree);
	}
	return degrees.length > 0 ? { degrees, text: normalized } : { degrees: fallback.slice(), text: fallback.map(value => tostring(value)).join(",") };
}

function parseMusicStructure(text: string | undefined): string[] {
	const tokens = (text ?? "A,A,B,A").split(",");
	const result: string[] = [];
	for (let i = 0; i < tokens.length && result.length < 8; i++) {
		const label = tokens[i].trim().toUpperCase();
		if (label !== "") result.push(label.slice(0, 8));
	}
	return result.length > 0 ? result : ["A"];
}

function resolveMusicInstrument(value: string | undefined, fallback: MusicInstrument): MusicInstrument {
	const normalized = (value ?? "auto").trim().toLowerCase();
	return MUSIC_VALID_INSTRUMENTS.indexOf(normalized) >= 0 ? normalized as MusicInstrument : fallback;
}

function fillMusicNote(notes: number[], ages: number[], start: number, span: number, note: number): void {
	const end = math.min(start + span, notes.length);
	for (let i = start; i < end; i++) {
		notes[i] = note;
		ages[i] = i - start;
	}
}

function sectionSeed(seed: number, label: string, barInSection: number, variation: number): number {
	let hash = 0;
	for (let i = 0; i < label.length; i++) hash = (hash * 31 + label.charCodeAt(i)) % 2147483647;
	return seed + hash * 131 + barInSection * 104729 + math.floor(variation * 10000.0) * 8191;
}

function createMusicArrangement(options: MusicResolvedOptions, bars: number, seedOffset = 0): MusicArrangement {
	const totalSteps = bars * MUSIC_STEPS_PER_BAR;
	const melodyNotes: number[] = [];
	const melodyAges: number[] = [];
	const bassNotes: number[] = [];
	const bassAges: number[] = [];
	const arpNotes: number[] = [];
	const chordRoots: number[] = [];
	const rootNote = 48 + options.rootPitchClass;
	for (let i = 0; i < totalSteps; i++) {
		melodyNotes.push(-1); melodyAges.push(0); bassNotes.push(-1); bassAges.push(0);
		arpNotes.push(-1); chordRoots.push(rootNote);
	}
	const scale = musicScale(options.mode);
	const styleConfig = getMusicStyleConfig(options.style);
	const chordToneChoices = [0, 2, 4, 7];
	const melodySpan = options.rhythmComplexity > 0.72 ? 1 : styleConfig.melodyStepSpan;
	const density = clamp01(styleConfig.melodyDensity * (0.55 + options.melodyComplexity * 0.65));
	for (let bar = 0; bar < bars; bar++) {
		const sectionIndex = math.floor(bar / options.barsPerSection) % options.structure.length;
		const sectionLabel = options.structure[sectionIndex];
		const barInSection = bar % options.barsPerSection;
		const localRng = createSfxRng(sectionSeed(options.seed + seedOffset, sectionLabel, barInSection, options.variation));
		const sectionOffset = math.max(0, sectionLabel.charCodeAt(0) - 65);
		const progressionIndex = (barInSection + sectionOffset) % options.progression.length;
		const chordDegree = options.progression[progressionIndex];
		const chordRoot = musicScaleNote(rootNote, scale, chordDegree);
		const barStart = bar * MUSIC_STEPS_PER_BAR;
		for (let localStep = 0; localStep < MUSIC_STEPS_PER_BAR; localStep++) {
			const step = barStart + localStep;
			chordRoots[step] = chordRoot;
			if (options.intensity > 0.25 || localStep % 2 === 0) {
				const arpTone = [0, 2, 4, 2][localStep % 4];
				arpNotes[step] = musicScaleNote(rootNote + 12, scale, chordDegree + arpTone);
			}
		}
		for (let localStep = 0; localStep < MUSIC_STEPS_PER_BAR; localStep += 4) {
			const step = barStart + localStep;
			const movingBass = options.intensity > 0.58 && localStep === 12;
			const bassDegree = chordDegree + (movingBass ? 4 : 0);
			fillMusicNote(bassNotes, bassAges, step, 4, musicScaleNote(rootNote - 12, scale, bassDegree));
		}
		for (let localStep = 0; localStep < MUSIC_STEPS_PER_BAR; localStep += melodySpan) {
			if (localRng.next() > density) continue;
			const step = barStart + localStep;
			let choice = chordToneChoices[math.floor(localRng.next() * chordToneChoices.length)];
			if (options.melodyComplexity > 0.65 && localRng.next() < options.melodyComplexity * 0.35) choice += 1;
			let note = musicScaleNote(rootNote + 12, scale, chordDegree + choice);
			if (localRng.next() < options.melodyComplexity * 0.30) note += 12;
			if (options.variation > 0.0 && sectionLabel !== "A" && localRng.next() < options.variation * 0.5) note += scale[1];
			fillMusicNote(melodyNotes, melodyAges, step, melodySpan, note);
		}
	}
	return { melodyNotes, melodyAges, bassNotes, bassAges, arpNotes, chordRoots };
}

function musicFrequency(note: number): number {
	return 440.0 * (2.0 ** ((note - 69) / 12.0));
}

function musicWave(phase: number, instrument: MusicInstrument): number {
	if (instrument === "square") return phase < 0.5 ? 0.7 : -0.7;
	if (instrument === "pulse") return phase < 0.25 ? 0.75 : -0.45;
	if (instrument === "saw") return 1.0 - phase * 2.0;
	if (instrument === "triangle" || instrument === "pluck") return phase < 0.5 ? phase * 4.0 - 1.0 : 3.0 - phase * 4.0;
	if (instrument === "organ") return math.sin(phase * 2.0 * math.pi) * 0.72 + math.sin(phase * 6.0 * math.pi) * 0.28;
	if (instrument === "bell") return math.sin(phase * 2.0 * math.pi) * 0.68 + math.sin(phase * 8.0 * math.pi) * 0.32;
	if (instrument === "fm") return math.sin(phase * 2.0 * math.pi + math.sin(phase * 6.0 * math.pi) * 2.2);
	if (instrument === "pad") return math.sin(phase * 2.0 * math.pi) * 0.65 + (phase < 0.5 ? phase * 4.0 - 1.0 : 3.0 - phase * 4.0) * 0.35;
	if (instrument === "sub") return math.sin(phase * 2.0 * math.pi) * 0.85 + math.sin(phase * 4.0 * math.pi) * 0.15;
	if (instrument === "guitar") return (phase < 0.5 ? phase * 4.0 - 1.0 : 3.0 - phase * 4.0) * 0.72 + math.sin(phase * 6.0 * math.pi) * 0.28;
	if (instrument === "strings") return (1.0 - phase * 2.0) * 0.55 + math.sin(phase * 2.0 * math.pi) * 0.45;
	return math.sin(phase * 2.0 * math.pi);
}

function musicEnvelope(time: number, length: number, attack: number, release: number, instrument?: MusicInstrument): number {
	if (time < 0.0 || time >= length) return 0.0;
	let value = 1.0;
	if (time < attack) value = time / attack;
	const remaining = length - time;
	if (remaining < release) value *= remaining / release;
	if (instrument === "pluck" || instrument === "bell" || instrument === "guitar") value *= 1.0 / (1.0 + time * (instrument === "bell" ? 3.5 : 8.0));
	return clamp01(value);
}

function createStereoSamples(stereo: boolean): StereoSamples {
	return stereo ? { left: [], right: [] } : { left: [] };
}

function pushStereo(samples: StereoSamples, left: number, right: number): void {
	if (samples.right) {
		samples.left.push(left);
		samples.right.push(right);
	} else {
		samples.left.push((left + right) * 0.5);
	}
}

function yieldMusicFrame(): Promise<void> {
	return new Promise<void>(resolve => {
		Director.systemScheduler.schedule(once(() => resolve()));
	});
}

async function synthMusic(
	options: MusicResolvedOptions,
	arrangement: MusicArrangement,
	bars: number,
	renderKind: MusicRenderKind,
	captureStems: boolean,
	onProgress?: (percent: number) => void,
	isCancelled?: () => boolean
): Promise<MusicRender | undefined> {
	const stepSeconds = 60.0 / options.bpm / 4.0;
	const durationSeconds = bars * MUSIC_STEPS_PER_BAR * stepSeconds;
	const totalSamples = math.floor(durationSeconds * MUSIC_SAMPLE_RATE);
	const mix = createStereoSamples(options.stereo);
	const stems = captureStems ? {
		melody: createStereoSamples(options.stereo), bass: createStereoSamples(options.stereo),
		harmony: createStereoSamples(options.stereo), drums: createStereoSamples(options.stereo),
	} : undefined;
	const noiseRng = createSfxRng(options.seed + bars * 65537 + (renderKind === "loop" ? 1 : 17));
	const noise: number[] = [];
	for (let i = 0; i < MUSIC_NOISE_SIZE; i++) noise.push(noiseRng.next() * 2.0 - 1.0);
	let melodyPhase = 0.0, bassPhase = 0.0, arpPhase = 0.0, padPhase = 0.0;
	let filteredLeft = 0.0, filteredRight = 0.0;
	let peak = 0.0, clippingSamples = 0;
	const fadeSamples = math.max(1, math.floor(MUSIC_SAMPLE_RATE * 0.008));
	const delayFrames = math.max(1, math.floor(MUSIC_SAMPLE_RATE * 60.0 / options.bpm * 0.5));
	const reverbFrames = math.max(1, math.floor(MUSIC_SAMPLE_RATE * 0.073));
	const delayLeft: number[] = [], delayRight: number[] = [], reverbLeft: number[] = [], reverbRight: number[] = [];
	for (let i = 0; i < delayFrames; i++) { delayLeft.push(0); delayRight.push(0); }
	for (let i = 0; i < reverbFrames; i++) { reverbLeft.push(0); reverbRight.push(0); }
	for (let sampleIndex = 0; sampleIndex < totalSamples; sampleIndex++) {
		if (sampleIndex % MUSIC_RENDER_CHUNK === 0) {
			if (isCancelled?.() === true) return undefined;
			onProgress?.(math.floor(sampleIndex / totalSamples * 100.0));
			if (sampleIndex > 0) await yieldMusicFrame();
		}
		const time = sampleIndex / MUSIC_SAMPLE_RATE;
		const stepFloat = time / stepSeconds;
		const stepIndex = math.min(arrangement.melodyNotes.length - 1, math.floor(stepFloat));
		const stepTime = (stepFloat - stepIndex) * stepSeconds;
		let melody = 0.0, bass = 0.0, harmony = 0.0, drums = 0.0;
		const melodyNote = arrangement.melodyNotes[stepIndex];
		if (melodyNote >= 0) {
			melodyPhase = (melodyPhase + musicFrequency(melodyNote) / MUSIC_SAMPLE_RATE) % 1.0;
			const noteTime = arrangement.melodyAges[stepIndex] * stepSeconds + stepTime;
			const span = options.rhythmComplexity > 0.72 ? 1 : getMusicStyleConfig(options.style).melodyStepSpan;
			const noteLength = span * stepSeconds * (0.72 + options.rhythmComplexity * 0.22);
			const env = musicEnvelope(noteTime, noteLength, 0.004, math.min(0.05, noteLength * 0.3), options.leadInstrument);
			melody = musicWave(melodyPhase, options.leadInstrument) * env * getMusicStyleConfig(options.style).melodyMix;
		}
		const bassNote = arrangement.bassNotes[stepIndex];
		if (bassNote >= 0) {
			bassPhase = (bassPhase + musicFrequency(bassNote) / MUSIC_SAMPLE_RATE) % 1.0;
			const noteTime = arrangement.bassAges[stepIndex] * stepSeconds + stepTime;
			const env = musicEnvelope(noteTime, stepSeconds * 3.75, 0.008, 0.08, options.bassInstrument);
			bass = musicWave(bassPhase, options.bassInstrument) * env * getMusicStyleConfig(options.style).bassMix;
		}
		const arpNote = arrangement.arpNotes[stepIndex];
		if (arpNote >= 0) {
			arpPhase = (arpPhase + musicFrequency(arpNote) / MUSIC_SAMPLE_RATE) % 1.0;
			const arpEnv = musicEnvelope(stepTime, stepSeconds * 0.72, 0.003, math.min(0.035, stepSeconds * 0.25), options.harmonyInstrument);
			harmony += musicWave(arpPhase, options.harmonyInstrument) * arpEnv * getMusicStyleConfig(options.style).harmonyMix;
		}
		const padNote = arrangement.chordRoots[stepIndex] + 12;
		padPhase = (padPhase + musicFrequency(padNote) / MUSIC_SAMPLE_RATE) % 1.0;
		harmony += musicWave(padPhase, options.harmonyInstrument) * (options.style === "calm" ? 0.10 : 0.035);
		const localStep = stepIndex % MUSIC_STEPS_PER_BAR;
		const noiseSample = noise[sampleIndex % MUSIC_NOISE_SIZE];
		const previousNoise = noise[(sampleIndex + MUSIC_NOISE_SIZE - 1) % MUSIC_NOISE_SIZE];
		const drumConfig = getMusicStyleConfig(options.style);
		const kickOn = options.intensity > 0.78 ? localStep % 4 === 0 : localStep === 0 || localStep === 8;
		let kickDecay = 0.0;
		if (kickOn) {
			const kickLength = math.min(stepSeconds, 0.16);
			if (stepTime < kickLength) {
				kickDecay = 1.0 - stepTime / kickLength;
				drums += math.sin(2.0 * math.pi * (58.0 + 82.0 * kickDecay) * stepTime) * kickDecay * kickDecay * drumConfig.drumMix;
			}
		}
		if (localStep === 4 || localStep === 12) {
			const snareLength = math.min(stepSeconds, 0.13);
			if (stepTime < snareLength) {
				const decay = 1.0 - stepTime / snareLength;
				drums += (noiseSample * 0.78 + math.sin(2.0 * math.pi * 180.0 * stepTime) * 0.22) * decay * drumConfig.drumMix * 0.68;
				if (options.intensity > 0.62) {
					const clapPhase = (stepTime * 38.0) % 1.0;
					drums += noiseSample * (clapPhase < 0.22 ? 1.0 : 0.0) * decay * drumConfig.drumMix * 0.24;
				}
			}
		}
		const hatStride = options.rhythmComplexity > 0.70 ? 1 : drumConfig.hatStride;
		if (localStep % hatStride === 0) {
			const hatLength = math.min(stepSeconds, 0.045);
			if (stepTime < hatLength) drums += (noiseSample - previousNoise) * (1.0 - stepTime / hatLength) * drumConfig.drumMix * 0.18;
		}
		if (localStep === 14 && options.intensity > 0.48) {
			const openHatLength = math.min(stepSeconds, 0.12);
			if (stepTime < openHatLength) drums += (noiseSample - previousNoise) * (1.0 - stepTime / openHatLength) * drumConfig.drumMix * 0.15;
		}
		if (localStep % 4 === 2 && options.intensity > 0.82) {
			const rideLength = math.min(stepSeconds, 0.08);
			if (stepTime < rideLength) drums += math.sin(2.0 * math.pi * 1800.0 * stepTime) * (1.0 - stepTime / rideLength) * drumConfig.drumMix * 0.09;
		}
		if (localStep >= 13 && options.rhythmComplexity > 0.68) {
			const tomLength = math.min(stepSeconds, 0.10);
			if (stepTime < tomLength) {
				const tomDecay = 1.0 - stepTime / tomLength;
				const tomFrequency = 150.0 - (localStep - 13) * 24.0;
				drums += math.sin(2.0 * math.pi * tomFrequency * stepTime) * tomDecay * drumConfig.drumMix * 0.26;
			}
		}
		const sectionStep = stepIndex % (options.barsPerSection * MUSIC_STEPS_PER_BAR);
		const sectionTime = sectionStep * stepSeconds + stepTime;
		if (sectionTime < 0.32 && options.intensity > 0.72) {
			drums += (noiseSample - previousNoise * 0.5) * (1.0 - sectionTime / 0.32) * drumConfig.drumMix * 0.16;
		}
		const duck = 1.0 - kickDecay * options.intensity * 0.24;
		melody *= duck * (0.72 + options.intensity * 0.42);
		bass *= 0.65 + options.intensity * 0.55;
		harmony *= duck * (0.50 + options.intensity * 0.62);
		drums *= 0.32 + options.intensity * 0.85;
		const chorusPan = math.sin(time * 2.0 * math.pi * 0.35) * options.chorus * 0.18;
		const melodyLeft = melody * (0.82 - chorusPan), melodyRight = melody * (1.18 + chorusPan);
		const bassLeft = bass, bassRight = bass;
		const harmonyLeft = harmony * (1.18 + chorusPan), harmonyRight = harmony * (0.82 - chorusPan);
		const drumsLeft = drums * 1.02, drumsRight = drums * 0.98;
		let left = melodyLeft + bassLeft + harmonyLeft + drumsLeft;
		let right = melodyRight + bassRight + harmonyRight + drumsRight;
		const delayPos = sampleIndex % delayFrames;
		const reverbPos = sampleIndex % reverbFrames;
		const delayedL = delayLeft[delayPos], delayedR = delayRight[delayPos];
		const reverbedL = reverbLeft[reverbPos], reverbedR = reverbRight[reverbPos];
		delayLeft[delayPos] = left + delayedR * 0.34;
		delayRight[delayPos] = right + delayedL * 0.34;
		reverbLeft[reverbPos] = left + reverbedR * 0.42;
		reverbRight[reverbPos] = right + reverbedL * 0.42;
		left += delayedL * options.delay + reverbedL * options.reverb * 0.45;
		right += delayedR * options.delay + reverbedR * options.reverb * 0.45;
		if (options.lowPass > 0.0) {
			const filterRate = 1.0 - options.lowPass * 0.94;
			filteredLeft += (left - filteredLeft) * filterRate;
			filteredRight += (right - filteredRight) * filterRate;
			left = filteredLeft;
			right = filteredRight;
		} else {
			filteredLeft = left;
			filteredRight = right;
		}
		const drive = 1.0 + options.distortion * 5.0;
		left = left * drive / (1.0 + math.abs(left) * drive * 0.58);
		right = right * drive / (1.0 + math.abs(right) * drive * 0.58);
		if (options.bitCrush > 0.0) {
			const bits = math.max(4, 16 - math.floor(options.bitCrush * 12.0));
			const levels = 2.0 ** (bits - 1);
			left = math.floor(left * levels + 0.5) / levels;
			right = math.floor(right * levels + 0.5) / levels;
		}
		let edgeFade = 1.0;
		if (sampleIndex < fadeSamples) edgeFade = sampleIndex / fadeSamples;
		if (sampleIndex >= totalSamples - fadeSamples) edgeFade = (totalSamples - 1 - sampleIndex) / fadeSamples;
		left *= options.volume * edgeFade * 0.72;
		right *= options.volume * edgeFade * 0.72;
		peak = math.max(peak, math.abs(left), math.abs(right));
		if (math.abs(left) > 1.0 || math.abs(right) > 1.0) clippingSamples++;
		left = math.max(-1.0, math.min(1.0, left));
		right = math.max(-1.0, math.min(1.0, right));
		pushStereo(mix, left, right);
		if (stems) {
			const stemGain = options.volume * edgeFade * 0.72;
			pushStereo(stems.melody, melodyLeft * stemGain, melodyRight * stemGain);
			pushStereo(stems.bass, bassLeft * stemGain, bassRight * stemGain);
			pushStereo(stems.harmony, harmonyLeft * stemGain, harmonyRight * stemGain);
			pushStereo(stems.drums, drumsLeft * stemGain, drumsRight * stemGain);
		}
	}
	onProgress?.(100);
	return { mix, peak, clippingSamples, stems };
}

function encodeMusicMidi(arrangement: MusicArrangement, options: MusicResolvedOptions): string {
	interface MidiEvent { tick: number; order: number; data: string; }
	const events: MidiEvent[] = [];
	const stepTicks = 120;
	const addNote = (tick: number, duration: number, channel: number, note: number, velocity: number) => {
		events.push({ tick, order: 1, data: string.char(0x90 + channel, note, velocity) });
		events.push({ tick: tick + duration, order: 0, data: string.char(0x80 + channel, note, 0) });
	};
	const addSustainedVoice = (notes: number[], ages: number[], channel: number, velocity: number) => {
		for (let step = 0; step < notes.length; step++) {
			if (notes[step] < 0 || ages[step] !== 0) continue;
			let span = 1;
			while (step + span < notes.length && notes[step + span] === notes[step] && ages[step + span] === span) span++;
			addNote(step * stepTicks, span * stepTicks, channel, notes[step], velocity);
		}
	};
	addSustainedVoice(arrangement.melodyNotes, arrangement.melodyAges, 0, 92);
	addSustainedVoice(arrangement.bassNotes, arrangement.bassAges, 1, 84);
	for (let step = 0; step < arrangement.arpNotes.length; step++) {
		if (arrangement.arpNotes[step] >= 0) addNote(step * stepTicks, math.floor(stepTicks * 0.72), 2, arrangement.arpNotes[step], 66);
		const localStep = step % MUSIC_STEPS_PER_BAR;
		if (localStep === 0 || localStep === 8) addNote(step * stepTicks, 60, 9, 36, 100);
		if (localStep === 4 || localStep === 12) {
			addNote(step * stepTicks, 60, 9, 38, 86);
			if (options.intensity > 0.62) addNote(step * stepTicks, 45, 9, 39, 62);
		}
		if (localStep % 2 === 0) addNote(step * stepTicks, 30, 9, 42, 54);
		if (localStep === 14 && options.intensity > 0.48) addNote(step * stepTicks, 90, 9, 46, 60);
		if (localStep % 4 === 2 && options.intensity > 0.82) addNote(step * stepTicks, 60, 9, 51, 48);
		if (localStep >= 13 && options.rhythmComplexity > 0.68) addNote(step * stepTicks, 70, 9, 45 - (localStep - 13) * 2, 70);
		if (step % (options.barsPerSection * MUSIC_STEPS_PER_BAR) === 0 && options.intensity > 0.72) addNote(step * stepTicks, 120, 9, 49, 72);
	}
	events.sort((a, b) => a.tick === b.tick ? a.order - b.order : a.tick - b.tick);
	const variableLength = (value: number): string => {
		const bytes: number[] = [value % 128];
		let rest = math.floor(value / 128);
		while (rest > 0) {
			bytes.push((rest % 128) + 128);
			rest = math.floor(rest / 128);
		}
		let result = "";
		for (let i = bytes.length - 1; i >= 0; i--) result += string.char(bytes[i]);
		return result;
	};
	const tempo = math.floor(60000000 / options.bpm);
	const parts: string[] = [string.char(0, 0xff, 0x51, 3, math.floor(tempo / 65536) % 256, math.floor(tempo / 256) % 256, tempo % 256)];
	parts.push(string.char(0, 0xff, 0x58, 4, 4, 2, 24, 8));
	let lastTick = 0;
	for (let i = 0; i < events.length; i++) {
		parts.push(variableLength(events[i].tick - lastTick) + events[i].data);
		lastTick = events[i].tick;
	}
	parts.push(string.char(0, 0xff, 0x2f, 0));
	const track = parts.join("");
	return string.pack(">c4I4I2I2I2", "MThd", 6, 0, 1, 480) + string.pack(">c4I4", "MTrk", track.length) + track;
}

function musicSiblingPath(path: string, suffix: string, extension = ".wav"): string {
	return path.slice(0, path.length - 4) + suffix + extension;
}

function saveGeneratedAsset(target: string, data: string, operationId: string): boolean {
	if (!ensureDirForFile(target)) return false;
	const temp = `${target}.${operationId}.tmp`;
	const backup = `${target}.${operationId}.bak`;
	Content.remove(temp);
	Content.remove(backup);
	if (!Content.save(temp, data)) return false;
	const hadTarget = Content.exist(target);
	if (hadTarget && !Content.move(target, backup)) {
		Content.remove(temp);
		return false;
	}
	if (!Content.move(temp, target)) {
		Content.remove(temp);
		if (hadTarget) Content.move(backup, target);
		return false;
	}
	Content.remove(backup);
	return true;
}

function musicFingerprint(options: MusicResolvedOptions): string {
	const raw = [
		options.style, tostring(options.seed), tostring(options.bpm), tostring(options.bars), tostring(options.volume),
		tostring(options.intensity), options.key, options.mode, options.progressionText, options.structure.join(","),
		tostring(options.barsPerSection), tostring(options.melodyComplexity), tostring(options.rhythmComplexity), tostring(options.variation),
		options.leadInstrument, options.bassInstrument, options.harmonyInstrument, tostring(options.stereo),
		tostring(options.reverb), tostring(options.delay), tostring(options.chorus), tostring(options.distortion), tostring(options.bitCrush),
		tostring(options.lowPass), tostring(options.stems), tostring(options.introBars), tostring(options.outroBars), options.stinger, tostring(options.exportMidi),
	].join("|");
	let hash = 2166136261;
	for (let i = 0; i < raw.length; i++) hash = (hash * 16777619 + raw.charCodeAt(i)) % 2147483647;
	return `music-v1-${math.floor(hash)}`;
}

function musicProjectObject(
	path: string,
	options: MusicResolvedOptions,
	files: string[],
	bytesWritten: number,
	durationSeconds: number,
	peak: number,
	clippingSamples: number,
	sourceProject?: string
): Record<string, unknown> {
	return {
		version: 1, generator: "Dora.CodingAgent.generate_music", fingerprint: musicFingerprint(options),
		path, files, bytesWritten, durationSeconds, peak, clippingSamples, sourceProject,
		params: {
			style: options.style, seed: options.seed, duration: options.duration, bpm: options.bpm, volume: options.volume,
			intensity: options.intensity, key: options.key, mode: options.mode, progression: options.progressionText,
			structure: options.structure.join(","), barsPerSection: options.barsPerSection,
			melodyComplexity: options.melodyComplexity, rhythmComplexity: options.rhythmComplexity, variation: options.variation,
			leadInstrument: options.leadInstrument, bassInstrument: options.bassInstrument, harmonyInstrument: options.harmonyInstrument,
			stereo: options.stereo, reverb: options.reverb, delay: options.delay, chorus: options.chorus,
			distortion: options.distortion, bitCrush: options.bitCrush, lowPass: options.lowPass, stems: options.stems,
			introBars: options.introBars, outroBars: options.outroBars, stinger: options.stinger, exportMidi: options.exportMidi,
		},
	};
}

function readCachedMusicResult(workDir: string, path: string, options: MusicResolvedOptions): GenerateMusicResult | undefined {
	const projectPath = musicSiblingPath(path, "", ".music.json");
	const target = resolveWorkspaceFilePath(workDir, path);
	const projectFull = resolveWorkspaceFilePath(workDir, projectPath);
	if (!target || !projectFull || !Content.exist(target) || !Content.exist(projectFull)) return undefined;
	const projectText = Content.load(projectFull);
	if (typeof projectText !== "string") return undefined;
	const [decoded] = safeJsonDecode(projectText);
	if (!decoded || type(decoded) !== "table") return undefined;
	const record = decoded as Record<string, unknown>;
	if (record.fingerprint !== musicFingerprint(options) || !Array.isArray(record.files)) return undefined;
	const files: string[] = [];
	for (let i = 0; i < record.files.length; i++) {
		if (typeof record.files[i] !== "string") return undefined;
		const relative = record.files[i] as string;
		const full = resolveWorkspaceFilePath(workDir, relative);
		if (!full || !Content.exist(full)) return undefined;
		files.push(relative);
	}
	if (files.indexOf(projectPath) < 0) files.push(projectPath);
	const durationSeconds = typeof record.durationSeconds === "number" ? record.durationSeconds : options.duration;
	const bytesWritten = typeof record.bytesWritten === "number" ? record.bytesWritten : 0;
	const midiPath = options.exportMidi ? musicSiblingPath(path, "", ".mid") : undefined;
	return {
		success: true, path, files, projectPath, midiPath, bytesWritten, durationSeconds,
		sampleRate: MUSIC_SAMPLE_RATE, channels: options.stereo ? 2 : 1, seed: options.seed,
		style: options.style, bpm: options.bpm, bars: options.bars, key: options.key, mode: options.mode,
		description: `Reused cached deterministic music assets for ${path} (${musicFingerprint(options)}).`,
	};
}

let musicAutoSeedStep = 0;

export async function generateMusic(req: {
	workDir: string; path: string; style: string; seed?: number; duration?: number; bpm?: number; volume?: number;
	intensity?: number; key?: string; mode?: string; progression?: string; structure?: string; barsPerSection?: number;
	melodyComplexity?: number; rhythmComplexity?: number; variation?: number;
	leadInstrument?: string; bassInstrument?: string; harmonyInstrument?: string;
	stereo?: boolean; reverb?: number; delay?: number; chorus?: number; distortion?: number; bitCrush?: number; lowPass?: number;
	stems?: boolean; introBars?: number; outroBars?: number; stinger?: string; exportMidi?: boolean;
	sourceProject?: string; onProgress?: (progress: GenerateMusicProgress) => void; isCancelled?: () => boolean;
}): Promise<GenerateMusicResult> {
	const relPath = (req.path ?? "").trim();
	if (relPath === "") return { success: false, message: "missing path" };
	if (!relPath.toLowerCase().endsWith(".wav")) return { success: false, path: relPath, message: "generate_music writes WAV files; path must end in .wav" };
	const requestedStyle = (req.style ?? "").trim().toLowerCase() as GenerateMusicStyle;
	const validStyles: string[] = ["chiptune", "adventure", "calm", "tense", "victory", "random"];
	if (validStyles.indexOf(requestedStyle) < 0) return { success: false, path: relPath, message: `unknown style '${req.style}'; expected one of: ${validStyles.join(", ")}` };
	const target = resolveWorkspaceFilePath(req.workDir, relPath);
	if (!target) return { success: false, path: relPath, message: "invalid path" };
	if (Content.exist(target) && Content.isdir(target)) return { success: false, path: relPath, message: "target path is a directory" };
	if (req.isCancelled?.() === true) return { success: false, path: relPath, message: "canceled", interrupted: true };
	musicAutoSeedStep += 1;
	let seed = typeof req.seed === "number" && req.seed === req.seed && math.abs(req.seed) < 2147483647
		? math.floor(req.seed) : (os.time() % 1000000000) + musicAutoSeedStep * 104729;
	const styleRng = createSfxRng(seed);
	let style = requestedStyle;
	if (style === "random") {
		const styles: GenerateMusicStyle[] = ["chiptune", "adventure", "calm", "tense", "victory"];
		style = styles[math.floor(styleRng.next() * styles.length)];
	}
	const styleConfig = getMusicStyleConfig(style);
	const bpm = typeof req.bpm === "number" && req.bpm === req.bpm ? math.floor(math.min(200, math.max(60, req.bpm))) : styleConfig.bpm;
	let requestedDuration = typeof req.duration === "number" && req.duration === req.duration ? req.duration : 16.0;
	requestedDuration = math.min(MUSIC_MAX_SECONDS, math.max(MUSIC_MIN_SECONDS, requestedDuration));
	const barSeconds = 240.0 / bpm;
	const minBars = math.max(1, math.ceil(MUSIC_MIN_SECONDS / barSeconds));
	const maxBars = math.max(minBars, math.floor(MUSIC_MAX_SECONDS / barSeconds));
	const bars = math.min(maxBars, math.max(minBars, math.floor(requestedDuration / barSeconds + 0.5)));
	const duration = bars * barSeconds;
	const requestedKey = (req.key ?? "random").trim().toUpperCase();
	let rootPitchClass = MUSIC_KEY_NAMES.indexOf(requestedKey);
	if (rootPitchClass < 0) rootPitchClass = math.floor(styleRng.next() * MUSIC_KEY_NAMES.length);
	const requestedMode = (req.mode ?? "auto").trim().toLowerCase();
	const mode = (MUSIC_VALID_MODES.indexOf(requestedMode) >= 0 ? requestedMode : styleConfig.mode) as MusicMode;
	const parsedProgression = parseMusicProgression(req.progression, styleConfig.progression);
	const options: MusicResolvedOptions = {
		style: style as Exclude<GenerateMusicStyle, "random">, seed, bpm, bars, duration,
		volume: typeof req.volume === "number" && req.volume === req.volume ? clamp01(req.volume) : 0.65,
		intensity: typeof req.intensity === "number" && req.intensity === req.intensity ? clamp01(req.intensity) : 0.6,
		rootPitchClass, key: MUSIC_KEY_NAMES[rootPitchClass], mode,
		progression: parsedProgression.degrees, progressionText: parsedProgression.text,
		structure: parseMusicStructure(req.structure),
		barsPerSection: typeof req.barsPerSection === "number" ? math.floor(math.min(8, math.max(1, req.barsPerSection))) : 2,
		melodyComplexity: typeof req.melodyComplexity === "number" ? clamp01(req.melodyComplexity) : 0.55,
		rhythmComplexity: typeof req.rhythmComplexity === "number" ? clamp01(req.rhythmComplexity) : 0.45,
		variation: typeof req.variation === "number" ? clamp01(req.variation) : 0.25,
		leadInstrument: resolveMusicInstrument(req.leadInstrument, styleConfig.leadInstrument),
		bassInstrument: resolveMusicInstrument(req.bassInstrument, styleConfig.bassInstrument),
		harmonyInstrument: resolveMusicInstrument(req.harmonyInstrument, styleConfig.harmonyInstrument),
		stereo: req.stereo !== false,
		reverb: typeof req.reverb === "number" ? clamp01(req.reverb) : styleConfig.reverb,
		delay: typeof req.delay === "number" ? clamp01(req.delay) : styleConfig.delay,
		chorus: typeof req.chorus === "number" ? clamp01(req.chorus) : styleConfig.chorus,
		distortion: typeof req.distortion === "number" ? clamp01(req.distortion) : styleConfig.distortion,
		bitCrush: typeof req.bitCrush === "number" ? clamp01(req.bitCrush) : 0.0,
		lowPass: typeof req.lowPass === "number" ? clamp01(req.lowPass) : 0.0,
		stems: req.stems === true,
		introBars: typeof req.introBars === "number" ? math.floor(math.min(8, math.max(0, req.introBars))) : 0,
		outroBars: typeof req.outroBars === "number" ? math.floor(math.min(8, math.max(0, req.outroBars))) : 0,
		stinger: (["victory", "failure", "both"].indexOf((req.stinger ?? "none").toLowerCase()) >= 0 ? (req.stinger ?? "none").toLowerCase() : "none") as MusicStinger,
		exportMidi: req.exportMidi === true,
	};
	const cached = readCachedMusicResult(req.workDir, relPath, options);
	if (cached) {
		req.onProgress?.({ state: "running", operationId: "cache", path: relPath, stage: "cache", percent: 100, message: "reusing matching deterministic music assets" });
		return cached;
	}
	const operationId = createOperationId();
	const files: string[] = [];
	let bytesWritten = 0;
	const saveAudio = (relative: string, render: MusicRender): boolean => {
		const full = resolveWorkspaceFilePath(req.workDir, relative);
		if (!full) return false;
		const wav = encodePcmWav(render.mix.left, MUSIC_SAMPLE_RATE, render.mix.right);
		if (!saveGeneratedAsset(full, wav, operationId)) return false;
		files.push(relative); bytesWritten += wav.length; syncGeneratedFileToWebIDE(full);
		return true;
	};
	req.onProgress?.({ state: "running", operationId, path: relPath, stage: "compose", percent: 0, message: `composing ${style} in ${options.key} ${mode} at ${bpm} BPM` });
	const arrangement = createMusicArrangement(options, bars);
	const render = await synthMusic(options, arrangement, bars, "loop", options.stems, percent => req.onProgress?.({
		state: "running", operationId, path: relPath, stage: "synth", percent, message: `synthesizing loop (${percent}%)`,
	}), req.isCancelled);
	if (!render) return { success: false, path: relPath, message: "canceled", interrupted: true };
	req.onProgress?.({ state: "running", operationId, path: relPath, stage: "write", percent: 100, message: "writing music assets" });
	if (!saveAudio(relPath, render)) return { success: false, path: relPath, message: "failed to write music WAV" };
	if (render.stems) {
		const stemNames: Array<keyof typeof render.stems> = ["melody", "bass", "harmony", "drums"];
		for (let i = 0; i < stemNames.length; i++) {
			const name = stemNames[i];
			const relative = musicSiblingPath(relPath, `_${name}`);
			const full = resolveWorkspaceFilePath(req.workDir, relative);
			if (!full) return { success: false, path: relPath, message: `invalid stem path: ${relative}` };
			const wav = encodePcmWav(render.stems[name].left, MUSIC_SAMPLE_RATE, render.stems[name].right);
			if (!saveGeneratedAsset(full, wav, operationId)) return { success: false, path: relPath, message: `failed to write ${name} stem` };
			files.push(relative); bytesWritten += wav.length; syncGeneratedFileToWebIDE(full);
			await yieldMusicFrame();
		}
	}
	const segmentSpecs: Array<{ suffix: string; bars: number; kind: MusicRenderKind; style?: GenerateMusicStyle; seedOffset: number }> = [];
	if (options.introBars > 0) segmentSpecs.push({ suffix: "_intro", bars: options.introBars, kind: "intro", seedOffset: 3001 });
	if (options.outroBars > 0) segmentSpecs.push({ suffix: "_outro", bars: options.outroBars, kind: "outro", seedOffset: 6007 });
	if (options.stinger === "victory" || options.stinger === "both") segmentSpecs.push({ suffix: "_victory", bars: 1, kind: "stinger", style: "victory", seedOffset: 9001 });
	if (options.stinger === "failure" || options.stinger === "both") segmentSpecs.push({ suffix: "_failure", bars: 1, kind: "stinger", style: "tense", seedOffset: 12007 });
	for (let i = 0; i < segmentSpecs.length; i++) {
		const spec = segmentSpecs[i];
		const segmentStyle = (spec.style ?? options.style) as Exclude<GenerateMusicStyle, "random">;
		const segmentConfig = getMusicStyleConfig(segmentStyle);
		const segmentOptions: MusicResolvedOptions = {
			...options,
			style: segmentStyle,
			seed: options.seed + spec.seedOffset,
			mode: spec.style ? segmentConfig.mode : options.mode,
			progression: spec.style ? segmentConfig.progression : options.progression,
			leadInstrument: spec.style ? segmentConfig.leadInstrument : options.leadInstrument,
			bassInstrument: spec.style ? segmentConfig.bassInstrument : options.bassInstrument,
			harmonyInstrument: spec.style ? segmentConfig.harmonyInstrument : options.harmonyInstrument,
			intensity: spec.style ? 0.9 : options.intensity,
			stems: false,
		};
		const segmentArrangement = createMusicArrangement(segmentOptions, spec.bars, spec.seedOffset);
		const segment = await synthMusic(segmentOptions, segmentArrangement, spec.bars, spec.kind, false, undefined, req.isCancelled);
		if (!segment) return { success: false, path: relPath, message: "canceled", interrupted: true };
		if (!saveAudio(musicSiblingPath(relPath, spec.suffix), segment)) return { success: false, path: relPath, message: `failed to write ${spec.suffix} segment` };
	}
	let midiPath: string | undefined;
	if (options.exportMidi) {
		midiPath = musicSiblingPath(relPath, "", ".mid");
		const midiFull = resolveWorkspaceFilePath(req.workDir, midiPath);
		const midi = encodeMusicMidi(arrangement, options);
		if (!midiFull || !saveGeneratedAsset(midiFull, midi, operationId)) return { success: false, path: relPath, message: "failed to write MIDI file" };
		files.push(midiPath); bytesWritten += midi.length; syncGeneratedFileToWebIDE(midiFull);
	}
	const actualDuration = math.floor((render.mix.left.length / MUSIC_SAMPLE_RATE) * 100.0 + 0.5) / 100.0;
	const projectPath = musicSiblingPath(relPath, "", ".music.json");
	const projectFull = resolveWorkspaceFilePath(req.workDir, projectPath);
	const [projectText] = safeJsonEncode(musicProjectObject(
		relPath, options, files.slice(), bytesWritten, actualDuration, render.peak, render.clippingSamples, req.sourceProject
	), true, false);
	if (!projectFull || !projectText || !saveGeneratedAsset(projectFull, projectText, operationId)) return { success: false, path: relPath, message: "failed to write music project file" };
	files.push(projectPath); bytesWritten += projectText.length; syncGeneratedFileToWebIDE(projectFull);
	if (render.clippingSamples > 0) Log("Warn", `[generate_music] limiter caught ${render.clippingSamples} clipping sample(s), pre-limit peak=${render.peak}`);
	Log("Info", `[generate_music] style=${style} seed=${seed} bpm=${bpm} bars=${bars} key=${options.key} ${mode} files=${files.length} bytes=${bytesWritten}`);
	return {
		success: true, path: relPath, files, projectPath, midiPath, bytesWritten, durationSeconds: actualDuration,
		sampleRate: MUSIC_SAMPLE_RATE, channels: options.stereo ? 2 : 1, seed, style, bpm, bars,
		key: options.key, mode,
		description: `Saved ${bars} bars of ${style} background music in ${options.key} ${mode} at ${bpm} BPM to ${relPath}, plus ${files.length - 1} companion asset(s). Stream the loop with Audio.playStream("${relPath}", true); use ${projectPath} to create compatible variations.`,
	};
}

export async function generateMusicVariation(req: {
	workDir: string; project: string; path: string; seed?: number; style?: string; intensity?: number; variation?: number;
	onProgress?: (progress: GenerateMusicProgress) => void; isCancelled?: () => boolean;
}): Promise<GenerateMusicResult> {
	const projectRel = (req.project ?? "").trim();
	if (!projectRel.toLowerCase().endsWith(".music.json")) return { success: false, path: req.path, message: "project must end in .music.json" };
	const projectFull = resolveWorkspaceFilePath(req.workDir, projectRel);
	if (!projectFull || !Content.exist(projectFull) || Content.isdir(projectFull)) return { success: false, path: req.path, message: "music project file not found" };
	const text = Content.load(projectFull);
	if (typeof text !== "string") return { success: false, path: req.path, message: "failed to read music project file" };
	const [decoded, decodeError] = safeJsonDecode(text);
	if (!decoded || type(decoded) !== "table") return { success: false, path: req.path, message: `invalid music project: ${tostring(decodeError)}` };
	const params = (decoded as Record<string, unknown>).params;
	if (!params || type(params) !== "table") return { success: false, path: req.path, message: "music project is missing params" };
	const p = params as Record<string, unknown>;
	const numberValue = (name: string): number | undefined => typeof p[name] === "number" ? p[name] as number : undefined;
	const stringValue = (name: string): string | undefined => typeof p[name] === "string" ? p[name] as string : undefined;
	const boolValue = (name: string): boolean | undefined => typeof p[name] === "boolean" ? p[name] as boolean : undefined;
	const oldSeed = numberValue("seed") ?? 1;
	return generateMusic({
		workDir: req.workDir, path: req.path, style: req.style ?? stringValue("style") ?? "chiptune",
		seed: req.seed ?? (oldSeed + 7919), duration: numberValue("duration"), bpm: numberValue("bpm"), volume: numberValue("volume"),
		intensity: req.intensity ?? numberValue("intensity"), key: stringValue("key"), mode: stringValue("mode"),
		progression: stringValue("progression"), structure: stringValue("structure"), barsPerSection: numberValue("barsPerSection"),
		melodyComplexity: numberValue("melodyComplexity"), rhythmComplexity: numberValue("rhythmComplexity"),
		variation: req.variation ?? numberValue("variation"), leadInstrument: stringValue("leadInstrument"),
		bassInstrument: stringValue("bassInstrument"), harmonyInstrument: stringValue("harmonyInstrument"), stereo: boolValue("stereo"),
		reverb: numberValue("reverb"), delay: numberValue("delay"), chorus: numberValue("chorus"), distortion: numberValue("distortion"),
		bitCrush: numberValue("bitCrush"), lowPass: numberValue("lowPass"), stems: boolValue("stems"), introBars: numberValue("introBars"), outroBars: numberValue("outroBars"),
		stinger: stringValue("stinger"), exportMidi: boolValue("exportMidi"), sourceProject: projectRel,
		onProgress: req.onProgress, isCancelled: req.isCancelled,
	});
}
