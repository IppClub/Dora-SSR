// @preview-file off clear
import * as Dora from 'Dora';
import { Content, Path, Director, once, App } from 'Dora';
import * as AgentConfig from 'Agent/Config';
import { Log } from 'Agent/Utils';
import type { ExecuteCommandMode, ExecuteCommandProgress, ExecuteCommandResult } from 'Agent/Tool/CommandTypes';
export type { ExecuteCommandMode, ExecuteCommandProgress, ExecuteCommandResult } from 'Agent/Tool/CommandTypes';
import { toCommandString as toStr, truncateCommandOutput, truncateCommandError } from 'Agent/Tool/CommandShared';
import { executeGitCommand } from 'Agent/Tool/GitCommand';
import { createOperationId } from 'Agent/Tool/Operation';
import { refreshWorkspaceTree } from 'Agent/Tool/WebIDESync';
import {
	isValidWorkspacePath,
	resolveWorkspaceFilePath,
	inspectReadableFile,
} from 'Agent/Tool/Workspace';

import { acquireEntryLease, recordEntryLeaseRun, ownsEntryLease, releaseEntryLease, type DevEntryModule } from 'Agent/Tool/EntryLease';
import { createPreviewGameInjection, type CommandPreviewGameResult } from 'Agent/Tool/CommandPreview';
import {
	getVisionBudgetState,
	getVisionTaskUsage,
	type VisionTaskUsage,
	VISION_MAX_CAPTURE_BATCHES,
	VISION_MAX_CAPTURE_FRAMES,
} from 'Agent/Tool/VisionBudget';
interface AgentEntryDescriptor { entryName?: string; fileName?: string; }

const LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30;


function executeLuaCommand(req: {
	workDir: string;
	code: string;
	timeoutSeconds: number;
	operationId: string;
	taskId: number;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult> {
	const code = (req.code ?? "").trim();
	if (code === "") {
		return Promise.resolve({ success: false, mode: "lua", output: "", message: "missing code", phase: "validate" });
	}
	const output: string[] = [];
	const entry = require("Script.Dev.Entry") as DevEntryModule;
	let ownsEntryRuntime = false;
	let contentAccessed = false;
	let refreshTreeCalled = false;
	let entryObjectBaseline = 0;
	let entryLuaRefBaseline = 0;
	let persistedVisionUsage: VisionTaskUsage | undefined;
	let capturedBatches = 0;
	let capturedFrames = 0;
	let lastPreviewResult: CommandPreviewGameResult | undefined;
	const currentVisionUsage = () => {
		persistedVisionUsage ??= getVisionTaskUsage(req.taskId);
		return {
			...persistedVisionUsage,
			captureBatchCount: persistedVisionUsage.captureBatchCount + capturedBatches,
			captureFrameCount: persistedVisionUsage.captureFrameCount + capturedFrames,
		};
	};
	const reserveCapture = (frameCount: number) => {
		const current = currentVisionUsage();
		if (current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES || current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES) {
			return {
				success: false,
				message: `Vision capture budget exhausted: ${current.captureBatchCount} batches and ${current.captureFrameCount} frames already reserved`,
				budget: getVisionBudgetState(current),
			};
		}
		capturedBatches++;
		capturedFrames += frameCount;
		return {success: true, budget: getVisionBudgetState(currentVisionUsage())};
	};
	const acquireEntryRuntime = () => {
		acquireEntryLease(req.operationId, entry);
		ownsEntryRuntime = true;
	};
	const stopOwnedEntry = (): string | undefined => {
		if (!ownsEntryRuntime) return undefined;
		ownsEntryRuntime = false;
		return releaseEntryLease(req.operationId, entry);
	};
	const startEntryWatchdog = () => {
		entryObjectBaseline = Dora.Object.count;
		entryLuaRefBaseline = Dora.Object.luaRefCount;
	};
	const checkEntryWatchdog = (): string | undefined => {
		if (!ownsEntryRuntime) return undefined;
		const objectCount = Dora.Object.count;
		const luaRefCount = Dora.Object.luaRefCount;
		const objectGrowth = math.max(0, objectCount - entryObjectBaseline);
		const luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline);
		const exceededTotal =
			objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth ||
			luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth;
		if (!exceededTotal) return undefined;
		return `Entry watchdog stopped the test and cleaned up after abnormal object growth: ` +
			`live objects +${tostring(objectGrowth)}, Lua references +${tostring(luaRefGrowth)}. ` +
			`Use a bounded test with a strict entity limit and only a few fixed simulation steps.`;
	};
	const normalizeEntryFile = (value: unknown): { fileName: string; entryName: string } => {
		if (!value || type(value) !== "table") {
			error("enterEntryAsync expects a table with an optional project-relative fileName");
		}
		const descriptor = value as AgentEntryDescriptor;
		let relativeFile = typeof descriptor.fileName === "string" ? descriptor.fileName.trim() : "";
		if (relativeFile === "") relativeFile = "init";
		if (!isValidWorkspacePath(relativeFile)) {
			error("enterEntryAsync fileName must be a project-relative path without '..'");
		}
		let fileName = Path(req.workDir, relativeFile);
		const ext = Path.getExt(fileName);
		if (ext !== "") fileName = Path.replaceExt(fileName, "");
		const luaFile = Path.replaceExt(fileName, "lua");
		if (!Content.exist(luaFile)) {
			error(`Agent test entry was not built: ${luaFile}`);
		}
		const requestedName = typeof descriptor.entryName === "string" ? descriptor.entryName.trim() : "";
		return {
			fileName,
			entryName: requestedName !== "" ? requestedName : Path.getName(fileName),
		};
	};
	const capturePrint = (...values: unknown[]) => {
		const parts: string[] = [];
		for (let i = 0; i < values.length; i++) {
			parts.push(tostring(values[i]));
		}
		output.push(parts.join("\t"));
	};
	const refreshTree = (path?: unknown) => {
		refreshTreeCalled = true;
		if (path === undefined) {
			return refreshWorkspaceTree(req.workDir);
		}
		if (typeof path !== "string") {
			error("refreshTree expects a project-relative file path string or no argument");
		}
		return refreshWorkspaceTree(req.workDir, path as string);
	};
	const resolveLuaContentPath = (first: unknown, second?: unknown): string => {
		const value = typeof second === "string" ? second : first;
		if (typeof value !== "string") {
			error("Content path must be a project-relative string");
		}
		const fullPath = resolveWorkspaceFilePath(req.workDir, value as string);
		if (!fullPath) {
			error("Content path must stay inside projectDir");
		}
		return fullPath;
	};
	const scopedContent = {
		exist: (first: unknown, second?: unknown) => Content.exist(resolveLuaContentPath(first, second)),
		isdir: (first: unknown, second?: unknown) => Content.isdir(resolveLuaContentPath(first, second)),
		getAttr: (first: unknown, second?: unknown) => Content.getAttr(resolveLuaContentPath(first, second)),
		load: (first: unknown, second?: unknown) => {
			const fullPath = resolveLuaContentPath(first, second);
			const inspected = inspectReadableFile(fullPath);
			if (!inspected.success) error(inspected.message ?? "file is not readable");
			return Content.load(fullPath);
		},
	};
	const blockedDoraGlobals: Record<string, boolean> = {
		Content: true,
		DB: true,
		HttpClient: true,
		HttpServer: true,
	};
	const env = setmetatable({
		projectDir: req.workDir,
		previewGame: createPreviewGameInjection({
			workDir: req.workDir,
			operationId: req.operationId,
			isCancelled: req.isCancelled,
			print: line => capturePrint(line),
			reserveCapture,
			onResult: result => {
				lastPreviewResult = result;
			},
		}, entry),
		requireProjectModule: (moduleNameValue: unknown, reloadModulesValue?: unknown): unknown => {
			if (typeof moduleNameValue !== "string") {
				error("requireProjectModule expects a project module name string");
			}
			const moduleName = (moduleNameValue as string).trim();
			if (moduleName === "" || moduleName.indexOf("..") >= 0 || moduleName.indexOf("/") === 0) {
				error("requireProjectModule expects a non-empty project module name without '..' or an absolute path");
			}
			const reloadModules: string[] = [moduleName];
			if (reloadModulesValue !== undefined) {
				if (!Array.isArray(reloadModulesValue)) {
					error("requireProjectModule reloadModules must be an array of module names");
				}
				const items = reloadModulesValue as unknown[];
				for (let i = 0; i < items.length; i++) {
					const item = items[i];
					if (typeof item !== "string" || item.trim() === "" || item.indexOf("..") >= 0) {
						error("requireProjectModule reloadModules contains an invalid module name");
					}
					if (reloadModules.indexOf(item) < 0) reloadModules.push(item);
				}
			}
			const luaPackage = _G["package"] as unknown as {
				path: string;
				loaded: Record<string, unknown>;
			};
			const previousPath = luaPackage.path;
			const previousSearchPaths = Content.searchPaths;
			const scopedSearchPaths: string[] = [req.workDir];
			for (let i = 0; i < previousSearchPaths.length; i++) {
				const searchPath = previousSearchPaths[i];
				if (searchPath !== req.workDir) scopedSearchPaths.push(searchPath);
			}
			luaPackage.path = `${Path(req.workDir, "?.lua")};${Path(req.workDir, "?", "init.lua")};${previousPath}`;
			Content.searchPaths = scopedSearchPaths;
			try {
				for (let i = 0; i < reloadModules.length; i++) {
					const reloadName = reloadModules[i];
					luaPackage.loaded[reloadName] = undefined;
					luaPackage.loaded[reloadName.split("/").join(".")] = undefined;
					luaPackage.loaded[reloadName.split(".").join("/")] = undefined;
				}
				return require(moduleName.split("/").join("."));
			} finally {
				Content.searchPaths = previousSearchPaths;
				luaPackage.path = previousPath;
			}
		},
		print: capturePrint,
		getEntryStatus: () => entry.getCurrentEntryStatus(),
		enterEntryAsync: (value: unknown): LuaMultiReturn<[boolean, string | undefined]> => {
			const normalized = normalizeEntryFile(value);
			acquireEntryRuntime();
			entry.allClear();
			startEntryWatchdog();
			recordEntryLeaseRun(req.operationId, entry);
			const [success, message] = entry.enterEntryAsync({
				entryName: normalized.entryName,
				fileName: normalized.fileName,
				workDir: req.workDir,
				projectRoot: req.workDir,
				runKind: "agent_test",
			});
			return $multi(success, message);
		},
		stopEntry: () => {
			if (!ownsEntryRuntime || !ownsEntryLease(req.operationId, entry)) return false;
			return entry.stop();
		},
		reportProgress: (value: unknown, callbackValue?: unknown) => {
			const actualValue = callbackValue ?? value;
			if (!req.onProgress || !actualValue || type(actualValue) !== "table") return;
			const progress = actualValue as Record<string, unknown>;
			const amount = typeof progress.progress === "number"
				? math.min(1, math.max(0, progress.progress))
				: undefined;
			req.onProgress({
				state: "running",
				mode: "lua",
				operationId: req.operationId,
				progress: amount,
				stage: typeof progress.stage === "string" ? progress.stage : "lua",
				message: typeof progress.message === "string" ? progress.message : "Lua command running",
			});
		},
	}, {
		__index: (_table: unknown, key: unknown) => {
			if (key === "Content") {
				contentAccessed = true;
				return scopedContent;
			}
			if (key === "refreshTree") {
				return refreshTree;
			}
			const name = tostring(key);
			if (blockedDoraGlobals[name]) return undefined;
			return (Dora as unknown as Record<string, unknown>)[name];
		},
	});
	const [fn, compileErr] = load(code, "=(agent_command)", "t", env);
	if (!fn) {
		return Promise.resolve({
			success: false,
			mode: "lua",
			output: truncateCommandOutput(output.join("\n")),
			message: truncateCommandError(toStr(compileErr)),
			phase: "compile",
		});
	}
	return new Promise(resolve => {
		let settled = false;
		let commandRoutine: Dora.Job | undefined;
		const startedAt = App.runningTime;
		const onProgress = req.onProgress;
		const isCancelled = req.isCancelled;
		const finish = (result: ExecuteCommandResult) => {
			if (settled) return;
			settled = true;
			let cleanupError: string | undefined;
			if (!result.success && (result.interrupted === true || result.phase === "timeout")) {
				try {
					entry.allClear();
				} catch (e) {
					cleanupError = `failed to clear interrupted Lua command runtime: ${tostring(e)}`;
				}
			}
			const entryCleanupError = stopOwnedEntry();
			cleanupError ??= entryCleanupError;
			if (contentAccessed && !refreshTreeCalled && !refreshWorkspaceTree(req.workDir)) {
				Log("Warn", `[execute_command] failed to refresh Web IDE tree after Lua command workDir=${req.workDir}`);
			}
			const previewGame = lastPreviewResult ? {
				success: lastPreviewResult.success,
				message: lastPreviewResult.message,
				files: lastPreviewResult.files,
				frameCount: lastPreviewResult.frames?.length,
			} : undefined;
			const visionFields = {
				...(previewGame ? {previewGame} : {}),
				...(capturedBatches > 0 ? {
					visionCapture: {batchCount: capturedBatches, frameCount: capturedFrames},
					visionBudget: getVisionBudgetState(currentVisionUsage()) as unknown as Record<string, unknown>,
				} : {}),
			};
			if (!result.success && cleanupError !== undefined) {
				result.cleanupError = cleanupError;
			} else if (result.success && cleanupError !== undefined) {
				resolve({
					success: false,
					mode: "lua",
					output: result.output,
					message: cleanupError,
					phase: "execute",
					cleanupError,
					...visionFields,
				});
				return;
			}
			if (result.success && lastPreviewResult && !lastPreviewResult.success) {
				resolve({
					success: false,
					mode: "lua",
					output: result.output,
					message: `previewGame failed: ${lastPreviewResult.message ?? "unknown error"}`,
					phase: "execute",
					...visionFields,
				});
				return;
			}
			resolve({
				...result,
				...visionFields,
			});
		};
		if (onProgress) {
			onProgress({
				state: "pending",
				mode: "lua",
				operationId: req.operationId,
				stage: "lua",
				message: "Lua command pending",
			});
		}
		commandRoutine = once(() => {
			if (settled) return;
			if (onProgress) {
				onProgress({
					state: "running",
					mode: "lua",
					operationId: req.operationId,
					stage: "lua",
					message: "Lua command running",
				});
			}
			const previousGlobalPrint = _G["print"];
			const [previousHook, previousHookMask, previousHookCount] = debug.gethook();
			let frameTimedOut = false, watchdogMessage: string | undefined;
			_G["print"] = capturePrint;
			debug.sethook(() => {
				watchdogMessage ??= checkEntryWatchdog();
				if (watchdogMessage !== undefined) error(watchdogMessage);
				if (App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds) {
					frameTimedOut = true;
					error(`Lua command exceeded ${tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)} seconds in one game frame`);
				}
			}, "", AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount);
			const [ok, runtimeErr] = pcall(fn);
			if (previousHook !== undefined && previousHookMask !== undefined && previousHookCount !== undefined) {
				debug.sethook(
					previousHook as (event: "call" | "tail call" | "return" | "line" | "count", line?: number) => unknown,
					previousHookMask,
					previousHookCount,
				);
			} else {
				debug.sethook();
			}
			_G["print"] = previousGlobalPrint;
			if (!ok) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: watchdogMessage ?? (frameTimedOut ? `Lua command exceeded ${tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)} seconds in one game frame` : truncateCommandError(toStr(runtimeErr))),
					phase: frameTimedOut ? "timeout" : "execute",
					interrupted: watchdogMessage !== undefined || frameTimedOut ? true : undefined,
				});
				return;
			}
			finish({ success: true, mode: "lua", output: truncateCommandOutput(output.join("\n")) });
		});
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			const watchdogMessage = checkEntryWatchdog();
			if (watchdogMessage !== undefined) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: watchdogMessage,
					phase: "execute",
					interrupted: true,
				});
				return true;
			}
			if (isCancelled && isCancelled()) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: "Lua command canceled",
					phase: "execute",
					interrupted: true,
				});
				return true;
			}
			if (App.runningTime - startedAt >= req.timeoutSeconds) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: `Lua command timed out after ${tostring(req.timeoutSeconds)} seconds`,
					phase: "timeout",
				});
				return true;
			}
			if (commandRoutine === undefined) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: "Lua command coroutine is unavailable",
					phase: "execute",
				});
				return true;
			}
			const [resumeSuccess, resumeResult] = coroutine.resume(commandRoutine);
			if (!resumeSuccess) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: truncateCommandError(toStr(resumeResult)),
					phase: "execute",
				});
				return true;
			}
			return settled || resumeResult === true;
		});
	});
}

export async function executeCommand(req: {
	workDir: string;
	mode: ExecuteCommandMode;
	code?: string;
	command?: string;
	cwd?: string;
	timeoutSeconds?: number;
	taskId?: number;
	onProgress?: (progress: ExecuteCommandProgress) => void;
	isCancelled?: () => boolean;
}): Promise<ExecuteCommandResult> {
	const mode = req.mode;
	if (mode !== "lua" && mode !== "git") {
		return { success: false, message: "mode must be lua or git", phase: "validate" };
	}
	if (mode === "lua") {
		return executeLuaCommand({
			workDir: req.workDir,
			code: req.code ?? "",
			timeoutSeconds: math.max(1, math.floor(Number(req.timeoutSeconds ?? LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS))),
			operationId: createOperationId(),
			taskId: req.taskId ?? 0,
			onProgress: req.onProgress,
			isCancelled: req.isCancelled,
		});
	}
	const operationId = createOperationId();
	return executeGitCommand({
		workDir: req.workDir,
		command: req.command ?? "",
		cwd: req.cwd,
		timeoutSeconds: math.max(1, math.floor(Number(req.timeoutSeconds ?? 600))),
		operationId,
		onProgress: req.onProgress,
		isCancelled: req.isCancelled,
	});
}
