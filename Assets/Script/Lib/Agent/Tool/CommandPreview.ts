// @preview-file off clear
import { App, Content, Director, Object as DoraObject, Path, sleep } from 'Dora';
import * as Config from 'Agent/Config';
import { acquireEntryLease, recordEntryLeaseRun, ownsEntryLease, releaseEntryLease, type DevEntryModule } from 'Agent/Tool/EntryLease';
import { createOperationId } from 'Agent/Tool/Operation';
import { isValidWorkspacePath, ensureDirPath } from 'Agent/Tool/Workspace';
import { PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS, PREVIEW_GAME_TIMEOUT_SECONDS } from 'Agent/Tool/ToolBudgets';
import { safeJsonEncode } from 'Agent/Utils';
import type { VisionBudgetState } from 'Agent/Tool/VisionBudget';

export interface CommandPreviewFrame {
	path: string;
	width: number;
	height: number;
	elapsedSeconds: number;
}

export interface CommandPreviewGameResult {
	success: boolean;
	files?: string[];
	frames?: CommandPreviewFrame[];
	message?: string;
	visionBudget?: VisionBudgetState;
}

export const COMMAND_VISION_DIR = ".agent/vision";

const PREVIEW_ENTRY_EXTENSIONS = ["", "lua", "ts", "tsx", "yue", "tl", "xml"];

/** Captures kept per project; oldest files roll out first. */
export const COMMAND_VISION_MAX_FILES = 60;

/**
 * Keep only the newest COMMAND_VISION_MAX_FILES capture files. Only files
 * named like <timestamp>-<random>.png (this feature's own output) are ever
 * removed; user-placed images in the same directory are untouched. Delete
 * failures are ignored: pruning must never break a capture.
 */
export function pruneVisionCaptures(dir: string, keep = COMMAND_VISION_MAX_FILES): void {
	if (!Content.exist(dir)) return;
	const names: string[] = [];
	for (const file of Content.getFiles(dir)) {
		if (string.match(file, "^%d+%-%d+%.png$")[0] !== undefined) names.push(file);
	}
	if (names.length <= keep) return;
	// Capture IDs start with os.time(), so name order is creation order.
	names.sort((a, b) => a < b ? 1 : a > b ? -1 : 0);
	for (let i = keep; i < names.length; i++) {
		Content.remove(Path(dir, names[i]));
	}
}

/**
 * The previewGame function injected into execute_command's Lua sandbox.
 * It owns the game exclusively, captures 1-3 frames at the requested
 * seconds after startup, saves them under .agent/vision in the project
 * and returns the project-relative paths. Runs synchronously on the
 * command coroutine; frame callbacks are awaited with sleep() polling.
 */
export function createPreviewGameInjection(req: {
	workDir: string;
	operationId: string;
	isCancelled?: (this: void) => boolean;
	print: (this: void, line: string) => void;
	reserveCapture?: (this: void, frameCount: number) => {success: boolean; message?: string; budget: VisionBudgetState};
	onResult?: (this: void, result: CommandPreviewGameResult) => void;
}, entry: DevEntryModule): (this: void, opts?: unknown) => CommandPreviewGameResult {
	return (opts) => {
		const o = type(opts) === "table" ? opts as Record<string, unknown> : {};
		const file = typeof o.entry === "string" && o.entry.trim() !== "" ? o.entry.trim() : "init.lua";
		const complete = (result: CommandPreviewGameResult): CommandPreviewGameResult => {
			const [encoded] = safeJsonEncode(result);
			if (encoded) req.print(encoded);
			req.onResult?.(result);
			return result;
		};
		const requestedTimes = o.captureAtSeconds;
		if (requestedTimes !== undefined && !Array.isArray(requestedTimes)) {
			return complete({success: false, message: "captureAtSeconds needs 1-3 increasing times between 0 and 10"});
		}
		const rawTimes = requestedTimes as unknown[] | undefined ?? [0.5];
		const times: number[] = [];
		for (const value of rawTimes) {
			if (typeof value !== "number" || !Number.isFinite(value)) {
				return complete({success: false, message: "captureAtSeconds needs 1-3 increasing times between 0 and 10"});
			}
			times.push(value);
		}
		const sourceExt = Path.getExt(file).toLowerCase();
		if (!isValidWorkspacePath(file) || PREVIEW_ENTRY_EXTENSIONS.indexOf(sourceExt) < 0) {
			return complete({success: false, message: "previewGame entry must be a built project-relative Lua, TypeScript, YueScript, Teal, or XML entry"});
		}
		if (times.length < 1 || times.length > 3 || times.some((t, i) => t < 0 || t > 10 || (i > 0 && t <= times[i - 1]))) {
			return complete({success: false, message: "captureAtSeconds needs 1-3 increasing times between 0 and 10"});
		}
		const full = Path.replaceExt(Path(req.workDir, file), "lua");
		if (!Content.exist(full)) {
			return complete({success: false, message: `Build the entry before previewGame; generated Lua was not found at ${full}`});
		}
		if (Director.beginGameCapture === undefined || Director.captureGameAsync === undefined || Director.endGameCapture === undefined) {
			return complete({success: false, message: "This engine build does not support game capture; update Dora SSR"});
		}
		const visionDir = Path(req.workDir, ".agent", "vision");
		if (!ensureDirPath(visionDir)) {
			return complete({success: false, message: "failed to create the .agent/vision directory"});
		}
		// Read the callback first so TypeScript-to-Lua does not emit a method call
		// that passes req as an unexpected first argument.
		const reserveCapture = req.reserveCapture;
		const reservation = reserveCapture ? reserveCapture(times.length) : undefined;
		if (reservation && !reservation.success) {
			return complete({success: false, message: reservation.message ?? "Vision capture budget exhausted", visionBudget: reservation.budget});
		}
		const cancelled = () => req.isCancelled?.() === true;
		const start = App.runningTime;
		let scope = false;
		let leased = false;
		const files: string[] = [];
		const frames: CommandPreviewFrame[] = [];
		let result: CommandPreviewGameResult = {success: false, message: "previewGame did not complete"};
		const check = () => {
			if (cancelled()) error("previewGame cancelled");
			if (!ownsEntryLease(req.operationId, entry)) error("previewGame lost ownership of the running game");
			if (App.runningTime - start > PREVIEW_GAME_TIMEOUT_SECONDS) error("previewGame timed out");
		};
		try {
			acquireEntryLease(req.operationId, entry);
			leased = true;
			entry.allClear();
			scope = Director.beginGameCapture();
			if (!scope) error("Game capture is unavailable or busy");
			const objects = DoraObject.count;
			const refs = DoraObject.luaRefCount;
			recordEntryLeaseRun(req.operationId, entry);
			const [previousHook, previousMask, previousCount] = debug.gethook();
			try {
				debug.sethook(() => {
					if (cancelled()) error("previewGame cancelled during startup");
					if (App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds) error("previewGame startup exceeded the game frame time budget");
					if (App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS) error("previewGame startup exceeded the startup time budget");
					if (DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth || DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth) error("previewGame startup exceeded the game object budget");
				}, "", Config.AGENT_LIMITS.executeCommandHookInstructionCount);
				const [ok, message] = entry.enterEntryAsync({
					entryName: Path.getName(full),
					fileName: Path.replaceExt(full, ""),
					workDir: req.workDir,
					projectRoot: req.workDir,
					runKind: "agent_test",
				});
				if (!ok) error(message ?? "Game entry failed");
			} finally {
				if (previousHook !== undefined && previousMask !== undefined && previousCount !== undefined) {
					debug.sethook(previousHook as (event: "call" | "tail call" | "return" | "line" | "count", line?: number) => unknown, previousMask, previousCount);
				} else {
					debug.sethook();
				}
			}
			const started = App.runningTime;
			for (const time of times) {
				while (App.runningTime - started < time) {
					check();
					sleep();
				}
				check();
				const assetId = createOperationId();
				const absPath = Path(visionDir, `${assetId}.png`);
				let done = false;
				let saved = false;
				let capturedAt = 0;
				let width = 0;
				let height = 0;
				if (!Director.captureGameAsync(absPath, (success, frameTime, sourceSize) => {
					saved = success;
					capturedAt = frameTime;
					width = sourceSize.width;
					height = sourceSize.height;
					done = true;
				})) error("Capture request was rejected");
				while (!done) {
					check();
					sleep();
				}
				check();
				if (!saved) error("Game capture could not be saved");
				const relative = `${COMMAND_VISION_DIR}/${assetId}.png`;
				files.push(relative);
				frames.push({path: relative, width, height, elapsedSeconds: capturedAt - started});
			}
			pruneVisionCaptures(visionDir);
			const cleanupError = releaseEntryLease(req.operationId, entry);
			leased = false;
			if (cleanupError) error(cleanupError);
			result = {success: true, files, frames, visionBudget: reservation?.budget};
		} catch (e) {
			result = {success: false, files, message: tostring(e), visionBudget: reservation?.budget};
		} finally {
			if (scope) Director.endGameCapture();
			if (leased) {
				const cleanupError = releaseEntryLease(req.operationId, entry);
				if (cleanupError !== undefined) {
					result = result.success
						? {success: false, files, message: cleanupError}
						: {success: false, files, message: `${result.message ?? "previewGame failed"}; ${cleanupError}`};
				}
			}
		}
		return complete(result);
	};
}
