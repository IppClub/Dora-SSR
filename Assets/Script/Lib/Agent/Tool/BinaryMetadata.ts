// @preview-file off clear
import { Content } from 'Dora';
import { safeJsonDecode } from 'Agent/Utils';

// Bound both returned bytes and decompression work: a tail probe is only
// attempted for small Ogg files (a ZIP/APK range may decode from byte zero).
const HEADER_BYTES = 64 * 1024;
const OGG_TAIL_MAX_FILE_BYTES = 16 * 1024 * 1024;

export interface BinaryResourceMetadata {
	kind: "image" | "audio" | "model";
	format: string;
	source: "header";
	width?: number;
	height?: number;
	channels?: number;
	sampleRate?: number;
	bitsPerSample?: number;
	durationSeconds?: number;
	codec?: string;
	version?: number;
	meshCount?: number;
	materialCount?: number;
	animationCount?: number;
}

export interface BinaryMetadataResult {
	metadata?: BinaryResourceMetadata;
	metadataMessage?: string;
}

// All offsets here are zero-based byte offsets, including on the Lua runtime.
function byte(data: string, offset: number): number {
	const value = string.byte(data, offset + 1);
	return value ?? 0;
}
function text(data: string, offset: number, length: number): string {
	return string.sub(data, offset + 1, offset + length);
}
function le(data: string, offset: number, length: number): number {
	let value = 0;
	for (let i = length - 1; i >= 0; i--) value = value * 256 + byte(data, offset + i);
	return value;
}
function be(data: string, offset: number, length: number): number {
	let value = 0;
	for (let i = 0; i < length; i++) value = value * 256 + byte(data, offset + i);
	return value;
}
function image(format: string, width: number, height: number): BinaryResourceMetadata | undefined {
	if (width <= 0 || height <= 0 || width > 0x7fffffff || height > 0x7fffffff) return undefined;
	return { kind: "image", format, source: "header", width, height };
}

function imageMetadata(data: string, size: number): BinaryResourceMetadata | undefined {
	if (data.length >= 33 && byte(data, 0) === 137 && text(data, 1, 7) === "PNG\r\n\x1a\n"
		&& be(data, 8, 4) === 13 && text(data, 12, 4) === "IHDR") {
		return image("png", be(data, 16, 4), be(data, 20, 4));
	}
	if (data.length >= 13 && (text(data, 0, 6) === "GIF87a" || text(data, 0, 6) === "GIF89a")) {
		return image("gif", le(data, 6, 2), le(data, 8, 2));
	}
	if (data.length >= 26 && text(data, 0, 2) === "BM") {
		const dibSize = le(data, 14, 4);
		if (dibSize === 12) return image("bmp", le(data, 18, 2), le(data, 20, 2));
		if (dibSize >= 40 && data.length >= 54) {
			const height = le(data, 22, 4);
			return image("bmp", le(data, 18, 4), height >= 0x80000000 ? 0x100000000 - height : height);
		}
	}
	if (data.length >= 4 && byte(data, 0) === 255 && byte(data, 1) === 216) {
		let offset = 2;
		for (let count = 0; count < 1024 && offset + 4 <= data.length; count++) {
			if (byte(data, offset) !== 255) break;
			while (offset < data.length && byte(data, offset) === 255) offset++;
			const marker = byte(data, offset++);
			if (marker === 217 || marker === 218) break;
			if (marker === 1 || (marker >= 208 && marker <= 215)) continue;
			const length = be(data, offset, 2);
			if (length < 2 || offset + length > data.length) break;
			if (marker >= 192 && marker <= 207 && marker !== 196 && marker !== 200 && marker !== 204 && length >= 8) {
				const channels = byte(data, offset + 7);
				if (channels > 0 && length >= 8 + 3 * channels) return image("jpeg", be(data, offset + 5, 2), be(data, offset + 3, 2));
			}
			offset += length;
		}
	}
	if (data.length >= 20 && text(data, 0, 4) === "RIFF" && text(data, 8, 4) === "WEBP") {
		const end = le(data, 4, 4) + 8;
		if (end > size) return undefined;
		for (let offset = 12; offset + 8 <= data.length;) {
			const tag = text(data, offset, 4), length = le(data, offset + 4, 4), payload = offset + 8;
			if (payload + length > end) break;
			if (tag === "VP8X" && length >= 10 && payload + 10 <= data.length) {
				return image("webp", le(data, payload + 4, 3) + 1, le(data, payload + 7, 3) + 1);
			}
			if (tag === "VP8L" && length >= 5 && payload + 5 <= data.length && byte(data, payload) === 47) {
				return image("webp", le(data, payload + 1, 2) % 16384 + 1,
					math.floor(le(data, payload + 2, 3) / 64) % 16384 + 1);
			}
			if (tag === "VP8 " && length >= 10 && payload + 10 <= data.length
				&& byte(data, payload + 3) === 157 && byte(data, payload + 4) === 1 && byte(data, payload + 5) === 42) {
				return image("webp", le(data, payload + 6, 2) % 16384, le(data, payload + 8, 2) % 16384);
			}
			offset = payload + length + length % 2;
		}
	}
	return undefined;
}

function wavMetadata(data: string, size: number): BinaryResourceMetadata | undefined {
	if (data.length < 12 || text(data, 0, 4) !== "RIFF" || text(data, 8, 4) !== "WAVE") return undefined;
	const end = le(data, 4, 4) + 8;
	if (end > size || end < 12) return undefined;
	const meta: BinaryResourceMetadata = { kind: "audio", format: "wav", source: "header" };
	let format = 0, blockAlign = 0, byteRate = 0, dataBytes: number | undefined;
	for (let offset = 12; offset + 8 <= data.length && offset + 8 <= end;) {
		const tag = text(data, offset, 4), length = le(data, offset + 4, 4), payload = offset + 8;
		if (length > end - payload) return undefined;
		if (tag === "fmt " && length >= 16 && payload + 16 <= data.length) {
			format = le(data, payload, 2);
			meta.channels = le(data, payload + 2, 2);
			meta.sampleRate = le(data, payload + 4, 4);
			byteRate = le(data, payload + 8, 4);
			blockAlign = le(data, payload + 12, 2);
			meta.bitsPerSample = le(data, payload + 14, 2);
			if (format === 65534 && length >= 40 && payload + 40 <= data.length) format = le(data, payload + 24, 2);
		} else if (tag === "data") dataBytes = length;
		offset = payload + length + length % 2;
	}
	if (meta.channels === undefined || meta.channels <= 0 || meta.sampleRate === undefined || meta.sampleRate <= 0) return undefined;
	if (format === 1 || format === 3) {
		meta.codec = format === 1 ? "pcm" : "ieee-float";
		const bits = meta.bitsPerSample ?? 0;
		const validBits = format === 1 ? bits === 8 || bits === 16 || bits === 24 || bits === 32 : bits === 32 || bits === 64;
		if (dataBytes !== undefined && validBits && blockAlign === meta.channels * bits / 8
			&& byteRate === meta.sampleRate * blockAlign && dataBytes % blockAlign === 0) {
			meta.durationSeconds = dataBytes / byteRate;
		}
	}
	return meta;
}

function flacMetadata(data: string): BinaryResourceMetadata | undefined {
	// RFC 9639: the mandatory first metadata block is the 34-byte STREAMINFO.
	if (data.length < 42 || text(data, 0, 4) !== "fLaC" || byte(data, 4) % 128 !== 0 || be(data, 5, 3) !== 34) return undefined;
	const sampleRate = be(data, 18, 3) / 16;
	const rate = math.floor(sampleRate);
	const bits = (byte(data, 20) % 2) * 16 + math.floor(byte(data, 21) / 16) + 1;
	if (rate <= 0 || bits < 4 || bits > 32) return undefined;
	const samples = (byte(data, 21) % 16) * 0x100000000 + be(data, 22, 4);
	return { kind: "audio", format: "flac", codec: "flac", source: "header", sampleRate: rate,
		channels: math.floor(byte(data, 20) / 2) % 8 + 1,
		bitsPerSample: bits,
		durationSeconds: samples > 0 ? samples / rate : undefined };
}

function oggMetadata(path: string, data: string, size: number): BinaryResourceMetadata | undefined {
	if (data.length < 28 || text(data, 0, 4) !== "OggS" || byte(data, 4) !== 0 || byte(data, 5) !== 2) return undefined;
	const segments = byte(data, 26), packet = 27 + segments;
	if (segments === 0 || packet + 19 > data.length) return undefined;
	let packetBytes = 0, complete = false;
	for (let i = 0; i < segments; i++) {
		const length = byte(data, 27 + i);
		packetBytes += length;
		if (length < 255) { complete = true; break; }
	}
	if (!complete || packet + packetBytes > data.length) return undefined;
	const meta: BinaryResourceMetadata = { kind: "audio", format: "ogg", source: "header" };
	let preSkip = 0;
	if (packetBytes === 30 && byte(data, packet) === 1 && text(data, packet + 1, 6) === "vorbis" && le(data, packet + 7, 4) === 0
		&& byte(data, packet + 29) % 2 === 1) {
		meta.codec = "vorbis";
		meta.channels = byte(data, packet + 11);
		meta.sampleRate = le(data, packet + 12, 4);
	} else if (packetBytes >= 19 && text(data, packet, 8) === "OpusHead" && byte(data, packet + 8) <= 15) {
		meta.codec = "opus";
		meta.channels = byte(data, packet + 9);
		meta.sampleRate = 48000; // Ogg Opus granules always use 48 kHz, not the original input rate.
		preSkip = le(data, packet + 10, 2);
	} else return undefined;
	if (meta.channels === undefined || meta.channels <= 0 || meta.sampleRate === undefined || meta.sampleRate <= 0) return undefined;
	if (size > OGG_TAIL_MAX_FILE_BYTES) return meta;
	const tail = size <= data.length ? data : Content.read(path, math.max(0, size - HEADER_BYTES), HEADER_BYTES);
	const serial = le(data, 14, 4);
	for (let offset = tail.length - 27; offset >= 0; offset--) {
		if (text(tail, offset, 4) !== "OggS" || byte(tail, offset + 4) !== 0
			|| math.floor(byte(tail, offset + 5) / 4) % 2 !== 1 || le(tail, offset + 14, 4) !== serial) continue;
		const count = byte(tail, offset + 26);
		let end = offset + 27 + count;
		if (end > tail.length) continue;
		for (let i = 0; i < count; i++) end += byte(tail, offset + 27 + i);
		const high = le(tail, offset + 10, 4);
		if (end !== tail.length || high > 0x1fffff) continue;
		const samples = high * 0x100000000 + le(tail, offset + 6, 4) - preSkip;
		if (samples >= 0) meta.durationSeconds = samples / meta.sampleRate;
		break;
	}
	return meta;
}

function glbMetadata(data: string, size: number): BinaryResourceMetadata | undefined {
	if (data.length < 20 || text(data, 0, 4) !== "glTF" || le(data, 4, 4) !== 2 || le(data, 8, 4) !== size) return undefined;
	const length = le(data, 12, 4);
	if (text(data, 16, 4) !== "JSON" || length > size - 20 || length % 4 !== 0) return undefined;
	const meta: BinaryResourceMetadata = { kind: "model", format: "glb", version: 2, source: "header" };
	if (20 + length <= data.length) {
		const [doc] = safeJsonDecode(text(data, 20, length));
		if (doc && typeof doc === "object") {
			const record = doc as Record<string, unknown>;
			if (Array.isArray(record.meshes)) meta.meshCount = record.meshes.length;
			if (Array.isArray(record.materials)) meta.materialCount = record.materials.length;
			if (Array.isArray(record.animations)) meta.animationCount = record.animations.length;
		}
	}
	return meta;
}

/** Header-derived facts only: never return raw bytes, tags, JSON bodies or decoded media. */
export function readBinaryResourceMetadata(path: string, size: number): BinaryMetadataResult {
	try {
		const data = Content.read(path, 0, math.min(size, HEADER_BYTES));
		if (data === "") return { metadataMessage: "Binary metadata could not be read." };
		const metadata = imageMetadata(data, size) ?? wavMetadata(data, size) ?? flacMetadata(data)
			?? oggMetadata(path, data, size) ?? glbMetadata(data, size);
		return metadata ? { metadata } : { metadataMessage: "Unsupported format, invalid header, or metadata beyond the bounded header scan." };
	} catch (_) {
		return { metadataMessage: "Binary metadata inspection failed; binary content remains unavailable." };
	}
}
