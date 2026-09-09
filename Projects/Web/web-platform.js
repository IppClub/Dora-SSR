/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

(function installDoraWebPlatform(global) {
	"use strict";

	const module = global.Module = global.Module || {};
	const canvas = module.canvas || global.document?.getElementById("canvas");
	const listeners = [];
	const pressedKeys = new Map();
	const activePointers = new Map();
	const pendingInputs = new Set();
	let active = true;
	let suspended = false;
	let audioUnlocked = false;

	function listen(target, type, handler, options) {
		if (!target?.addEventListener) return;
		target.addEventListener(type, handler, options);
		listeners.push(() => target.removeEventListener(type, handler, options));
	}

	function audioContext() {
		return module.SDL2?.audioContext || null;
	}

	function cancelAudioCallback() {
		const node = module.SDL2?.audio?.scriptProcessorNode;
		if (!node) return false;
		node.onaudioprocess = () => {};
		try {
			node.disconnect();
		} catch (_) {
			// The SDL close path may already have disconnected the node.
		}
		return true;
	}

	async function unlockAudio() {
		if (!active) return {supported: false, state: "disposed"};
		const context = audioContext();
		if (!context) return {supported: false, state: "unavailable"};
		try {
			if (context.state !== "running") await context.resume();
			audioUnlocked = context.state === "running";
			return {supported: true, state: context.state, unlocked: audioUnlocked};
		} catch (error) {
			return {supported: true, state: context.state, unlocked: false, error: String(error)};
		}
	}

	function syntheticKeyUp(entry) {
		const event = new KeyboardEvent("keyup", {
			key: entry.key,
			code: entry.code,
			location: entry.location,
			bubbles: true,
			cancelable: true,
		});
		Object.defineProperty(event, "doraSyntheticRelease", {value: true});
		Object.defineProperty(event, "keyCode", {value: entry.keyCode || entry.which || 0});
		Object.defineProperty(event, "which", {value: entry.which || entry.keyCode || 0});
		(global.window || global).dispatchEvent(event);
	}

	function releaseInput(reason = "blur") {
		for (const entry of pressedKeys.values()) syntheticKeyUp(entry);
		pressedKeys.clear();
		for (const [pointerId, entry] of activePointers) {
			if (canvas?.hasPointerCapture?.(pointerId)) canvas.releasePointerCapture(pointerId);
			const event = new PointerEvent("pointercancel", {
				pointerId,
				pointerType: entry.pointerType,
				clientX: entry.clientX,
				clientY: entry.clientY,
				bubbles: true,
				cancelable: true,
			});
			Object.defineProperty(event, "doraSyntheticRelease", {value: true});
			(canvas || global).dispatchEvent(event);
		}
		activePointers.clear();
		module.ccall?.("dora_web_release_input", null, [], []);
		global.dispatchEvent?.(new CustomEvent("dora-inputrelease", {detail: {reason}}));
	}

	async function setSuspended(value, reason = "host") {
		if (!active) return {suspended: true, audioState: "disposed"};
		const next = Boolean(value);
		if (next === suspended) {
			const engineFrame = module.ccall?.("dora_web_set_suspended", "number", ["number"], [next ? 1 : 0]);
			return {suspended, audioState: audioContext()?.state || "unavailable", engineFrame};
		}
		if (next) releaseInput(reason);
		suspended = next;
		const engineFrame = module.ccall?.("dora_web_set_suspended", "number", ["number"], [suspended ? 1 : 0]);
		const context = audioContext();
		if (context) {
			try {
				if (suspended && context.state === "running") await context.suspend();
				else if (!suspended && audioUnlocked && context.state !== "running") await context.resume();
			} catch (_) {
				// The browser may reject audio state changes while the page is backgrounded.
			}
		}
		global.dispatchEvent?.(new CustomEvent("dora-visibilitychange", {
			detail: {suspended, reason, audioState: context?.state || "unavailable", engineFrame},
		}));
		return {suspended, audioState: context?.state || "unavailable", engineFrame};
	}

	function fallbackFileInput(options) {
		return new Promise((resolve) => {
			const input = global.document.createElement("input");
			input.type = "file";
			input.accept = options.accept || "";
			input.multiple = Boolean(options.multiple);
			input.hidden = true;
			let settled = false;
			const finish = (files) => {
				if (settled) return;
				settled = true;
				pendingInputs.delete(cancel);
				input.remove();
				resolve(files);
			};
			const cancel = () => finish([]);
			input.addEventListener("change", () => finish(Array.from(input.files || [])), {once: true});
			input.addEventListener("cancel", cancel, {once: true});
			pendingInputs.add(cancel);
			global.document.body.appendChild(input);
			input.click();
		});
	}

	async function pickFiles(options = {}) {
		if (!active) return [];
		if (options.preferNative !== false && typeof global.showOpenFilePicker === "function") {
			try {
				const handles = await global.showOpenFilePicker({
					multiple: Boolean(options.multiple),
					types: options.types,
					excludeAcceptAllOption: Boolean(options.excludeAcceptAllOption),
				});
				return Promise.all(handles.map((handle) => handle.getFile()));
			} catch (error) {
				if (error?.name === "AbortError") return [];
				if (options.fallback === false) throw error;
			}
		}
		return fallbackFileInput(options);
	}

	async function writeClipboard(text) {
		if (!global.navigator?.clipboard?.writeText) throw new Error("clipboard write is unsupported");
		await global.navigator.clipboard.writeText(String(text));
	}

	async function readClipboard() {
		if (!global.navigator?.clipboard?.readText) throw new Error("clipboard read is unsupported");
		return global.navigator.clipboard.readText();
	}

	async function requestPointerLock(options) {
		if (!canvas?.requestPointerLock) return false;
		await canvas.requestPointerLock(options);
		return global.document.pointerLockElement === canvas;
	}

	function dispose() {
		if (!active) return false;
		active = false;
		releaseInput("dispose");
		for (const remove of listeners.splice(0)) remove();
		for (const cancel of [...pendingInputs]) cancel();
		cancelAudioCallback();
		const context = audioContext();
		if (context?.state === "running") context.suspend().catch(() => {});
		return true;
	}

	listen(global, "keydown", (event) => {
		if (!event.doraSyntheticRelease) pressedKeys.set(event.code || event.key, {
			key: event.key,
			code: event.code,
			location: event.location,
			keyCode: event.keyCode,
			which: event.which,
		});
		void unlockAudio();
	}, true);
	listen(global, "keyup", (event) => pressedKeys.delete(event.code || event.key), true);
	listen(canvas, "pointerdown", (event) => {
		activePointers.set(event.pointerId, {
			pointerType: event.pointerType,
			clientX: event.clientX,
			clientY: event.clientY,
		});
		void unlockAudio();
	}, true);
	listen(canvas, "pointermove", (event) => {
		if (activePointers.has(event.pointerId)) activePointers.set(event.pointerId, {
			pointerType: event.pointerType,
			clientX: event.clientX,
			clientY: event.clientY,
		});
	}, true);
	listen(canvas, "pointerup", (event) => activePointers.delete(event.pointerId), true);
	listen(canvas, "pointercancel", (event) => activePointers.delete(event.pointerId), true);
	listen(global, "blur", () => releaseInput("blur"));
	listen(global.document, "visibilitychange", () => void setSuspended(global.document.hidden, "visibility"));

	const probe = global.document?.createElement("audio");
	const capabilities = Object.freeze({
		keyboard: true,
		mouse: true,
		touch: "PointerEvent" in global,
		gamepad: typeof global.navigator?.getGamepads === "function",
		fileSystemAccess: typeof global.showOpenFilePicker === "function",
		fileInput: Boolean(global.document?.createElement),
		clipboardRead: Boolean(global.navigator?.clipboard?.readText),
		clipboardWrite: Boolean(global.navigator?.clipboard?.writeText),
		pointerLock: Boolean(canvas?.requestPointerLock),
		virtualKeyboard: Boolean(global.navigator?.virtualKeyboard),
		ime: "CompositionEvent" in global,
		wav: Boolean(probe?.canPlayType?.("audio/wav")),
		ogg: Boolean(probe?.canPlayType?.('audio/ogg; codecs="vorbis"')),
	});

	const api = Object.freeze({
		capabilities,
		features: global.DoraWebFeatures,
		unlockAudio,
		setSuspended,
		releaseInput,
		pickFiles,
		writeClipboard,
		readClipboard,
		requestPointerLock,
		cancelAudioCallback,
		dispose,
		get state() {
			return Object.freeze({
				active,
				suspended,
				audioUnlocked,
				audioState: audioContext()?.state || "unavailable",
				pressedKeys: pressedKeys.size,
				activePointers: activePointers.size,
			});
		},
	});
	global.DoraWebPlatform = api;
	module.doraWebPlatform = api;
})(globalThis);
