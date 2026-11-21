import { App } from "Dora";
import { safeJsonDecode, type LLMConfig } from "Agent/Utils";

type NativePhase = "opening" | "recording" | "transcribing" | "complete" | "error";
type VoicePhase = "idle" | "opening" | "waiting" | "recording" | "transcribing";
type VoiceIssue = "capture" | "silence" | "transcription";

interface NativeVoice {
	start(this: void): object;
	poll(this: void, handle: object): LuaMultiReturn<[NativePhase, string?]>;
	transcribe(this: void, handle: object, key: string, wav: string): void;
	cancel(this: void, handle: object): void;
}

const sampleRate = 16000;
const frameSeconds = 0.02;
const frameSamples = sampleRate * frameSeconds;
const frameBytes = frameSamples * 2;
const highPass = math.exp(-2 * math.pi * 85 / sampleRate);
const preRoll = 15;
const tail = 12;
const maxFrames = 60 / frameSeconds;
const [available, native] = pcall(() => require("dora.remix_voice") as NativeVoice);
const recorder = available && type((native as NativeVoice).start) === "function" ? native as NativeVoice : undefined;

export function remixVoiceKey(config: LLMConfig): string | undefined {
	if (!recorder || config.studioGateway) return undefined;
	const url = string.gsub(config.url.trim(), "/+$", "")[0];
	if (url !== "https://api.deepseek.com/chat/completions" && url !== "https://api.deepseek.com/v1/chat/completions") return undefined;
	const key = config.apiKey.trim();
	return key !== "" ? key : undefined;
}

export function createRemixVoice(
	onPhase: (this: void, phase: VoicePhase) => void,
	onText: (this: void, text: string) => void,
	onIssue: (this: void, issue: VoiceIssue) => void,
) {
	let phase: VoicePhase = "idle";
	let level = 0;
	let session: {
		handle: object;
		key: string;
		startedAt: number;
		lastAudioAt: number;
		carry: string;
		frames: string[];
		nextFrame: number;
		firstVoice: number;
		lastVoice: number;
		voicedRun: number;
		noise: number;
		previousSample: number;
		filteredSample: number;
	} | undefined;
	const changePhase = (next: VoicePhase) => {
		if (phase === next) return;
		phase = next;
		if (next === "idle" || next === "transcribing") level = 0;
		onPhase(next);
	};
	const cancel = () => {
		if (session) recorder?.cancel(session.handle);
		session = undefined;
		changePhase("idle");
	};
	const fail = (issue: VoiceIssue) => {
		cancel();
		onIssue(issue);
	};
	const finish = () => {
		const current = session;
		if (!current || !recorder || (phase !== "waiting" && phase !== "recording")) return;
		if (current.firstVoice < 0) { fail("silence"); return; }
		const pcm = table.concat(current.frames, "", current.firstVoice + 1, math.min(current.nextFrame, current.lastVoice + 1 + tail));
		const header = string.pack("<c4I4c8I4I2I2I4I4I2I2c4I4",
			"RIFF", 36 + pcm.length, "WAVEfmt ", 16, 1, 1, sampleRate, sampleRate * 2, 2, 16, "data", pcm.length);
		recorder.transcribe(current.handle, current.key, header + pcm);
		changePhase("transcribing");
	};
	return {
		start: (key: string) => {
			if (!recorder || session) return;
			const now = App.runningTime;
			session = { handle: recorder.start(), key, startedAt: now, lastAudioAt: now, carry: "", frames: [],
				nextFrame: 0, firstVoice: -1, lastVoice: 0, voicedRun: 0, noise: 0.002, previousSample: 0, filteredSample: 0 };
			changePhase("opening");
		},
		cancel,
		finish,
		phase: () => phase,
		level: () => level,
		tick: () => {
			const current = session;
			if (!current || !recorder) return;
			const [state, data] = recorder.poll(current.handle);
			if (state === "error") { fail(phase === "transcribing" ? "transcription" : "capture"); return; }
			if (state === "complete") {
				const value = (data && safeJsonDecode(data)[0]) as { text?: unknown } | undefined;
				if (!value || type(value) !== "table" || typeof value.text !== "string") { fail("transcription"); return; }
				const text = value.text.trim();
				if (text === "") { fail("silence"); return; }
				cancel();
				onText(text);
				return;
			}
			if (state !== "recording") return;
			const now = App.runningTime;
			if (phase === "opening") {
				current.startedAt = now;
				current.lastAudioAt = now;
				changePhase("waiting");
			}
			if (data) {
				current.lastAudioAt = now;
				const audio = current.carry + data;
				let peak = 0;
				let offset = 1;
				while (offset + frameBytes - 1 <= audio.length) {
					const index = current.nextFrame++;
					const frame = string.sub(audio, offset, offset + frameBytes - 1);
					current.frames.push(frame);
					let energy = 0;
					for (let at = 1; at <= frameBytes; at += 2) {
						const sample = (string.unpack("<i2", frame, at)[0] as number) / 32768;
						current.filteredSample = highPass * (current.filteredSample + sample - current.previousSample);
						current.previousSample = sample;
						energy += current.filteredSample * current.filteredSample;
					}
					const rms = math.sqrt(energy / frameSamples);
					peak = math.max(peak, rms);
					const waiting = current.firstVoice < 0;
					const voiced = rms > math.max(waiting ? 0.008 : 0.005, current.noise * (waiting ? 3 : 1.8));
					if (!voiced) current.noise = current.noise * 0.97 + rms * 0.03;
					current.voicedRun = voiced ? current.voicedRun + 1 : 0;
					if (waiting && current.voicedRun >= 6) {
						current.firstVoice = math.max(0, index - current.voicedRun + 1 - preRoll);
						current.lastVoice = index;
						changePhase("recording");
					}
					if (current.firstVoice >= 0 && current.voicedRun >= 2) current.lastVoice = index;
					if (index + 1 >= maxFrames || (current.firstVoice >= 0 && index - current.lastVoice >= 70)) { finish(); return; }
					offset += frameBytes;
				}
				current.carry = string.sub(audio, offset);
				level = math.min(1, peak * 12);
			}
			if (now - current.lastAudioAt >= 3) fail("capture");
			else if (current.firstVoice < 0 && now - current.startedAt >= 10) fail("silence");
			else if (now - current.startedAt >= 60) finish();
		},
	};
}
