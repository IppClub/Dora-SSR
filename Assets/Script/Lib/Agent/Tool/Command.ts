// @preview-file off clear
import * as Dora from 'Dora';
import { Content, Path, Director, once, App, sleep } from 'Dora';
import * as AgentConfig from 'Agent/Config/Defaults';
import { Log, safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import type { ExecuteCommandMode, ExecuteCommandProgress, ExecuteCommandResult } from 'Agent/Tool/CommandTypes';
export type { ExecuteCommandMode, ExecuteCommandProgress, ExecuteCommandResult } from 'Agent/Tool/CommandTypes';
import { toCommandString as toStr, truncateCommandOutput, truncateCommandError } from 'Agent/Tool/CommandShared';
import { executeGitCommand } from 'Agent/Tool/GitCommand';
import { createOperationId } from 'Agent/Tool/Operation';
import { refreshWorkspaceTree } from 'Agent/Tool/WebIDESync';
import { isValidWorkspacePath, type DoraDocLanguage } from 'Agent/Tool/Workspace';
import { createGodotRuntimeSceneInjection, type GodotRuntimeSceneResult } from 'Agent/Tool/GodotRuntimeScene';
import { createGodotSceneInjection, type GodotSceneResult } from 'Agent/Tool/GodotScene';
import { createGodotImportInjection, type GodotImportBatchResult } from 'Agent/Tool/GodotImport';
import { fetchUrl } from 'Agent/Tool/Fetch';
import { WEB_REQUEST_TIMEOUT_SECONDS, readWebPage, searchWeb } from 'Agent/Tool/DeepSeekWeb';
import { createCommandContent } from 'Agent/Tool/CommandContent';

import { acquireEntryLease, canClearEntryAfterCommand, recordEntryLeaseRun, ownsEntryLease, releaseEntryLease, type DevEntryModule } from 'Agent/Tool/EntryLease';
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

// The dedicated Studio host has no game renderer. Normal Lua snippets are
// transported to an isolated Player, while previewGame keeps its specialized
// capture bridge below. Native Agent builds do not install these globals.
declare const _studio_agent_tool_begin: ((operation:string,file:string,content:string,projectRoot:string)=>string)|undefined;
declare const _studio_agent_tool_poll: ((requestId:string)=>{success:boolean;resultJSON?:string;message?:string}|undefined)|undefined;
declare const _studio_agent_tool_cancel: ((requestId:string)=>void)|undefined;

function executeStudioLuaCommand(req: {
	workDir:string;
	code:string;
	timeoutSeconds:number;
	operationId:string;
	onProgress?:(progress:ExecuteCommandProgress)=>void;
	isCancelled?:()=>boolean;
}):Promise<ExecuteCommandResult>|undefined {
	// Keep every previewGame call in the original Agent command sandbox. The
	// preview bridge lives there and forwards rendering to the isolated Player;
	// transporting wrapped calls to the generic Lua Player would make the
	// injected previewGame function disappear.
	const usesPreviewGame=string.match(req.code,"%f[%a_]previewGame%f[^%w_]%s*%(")[0]!==undefined;
	const usesGodotImport=string.match(req.code,"%f[%a_]importGodotAssets%f[^%w_]")[0]!==undefined;
	const usesNetworkCommand = ["fetch", "web_search", "read_url"].some(name =>
		string.match(req.code, `%f[%a_]${name}%f[^%w_]`)[0] !== undefined
	);
	if (typeof _studio_agent_tool_begin !== "function" || usesNetworkCommand || usesPreviewGame || usesGodotImport || (string.match(req.code,"%f[%a_]inspectGodotScene%f[^%w_]")[0]!==undefined || string.match(req.code,"%f[%a_]inspectGodotRuntimeScene%f[^%w_]")[0]!==undefined)) return undefined;
	const onProgress=req.onProgress;
	const isCancelled=req.isCancelled;
	return new Promise(resolve => {
		let requestId:string|undefined;
		let settled=false;
		const finish=(result:ExecuteCommandResult)=>{
			if(settled)return;
			settled=true;
			resolve(result);
		};
		onProgress?.({state:"pending",mode:"lua",operationId:req.operationId,stage:"player",message:"Lua command pending in isolated game Player"});
		const routine=once(()=>{
			try{
				const [options]=safeJsonEncode({code:req.code,timeoutSeconds:req.timeoutSeconds});
				if(!options)error("failed to encode Studio Agent Lua command");
				requestId=_studio_agent_tool_begin("execute-lua",Path(req.workDir,".agent","command.lua"),options,req.workDir);
				onProgress?.({state:"running",mode:"lua",operationId:req.operationId,stage:"player",message:"Lua command running in isolated game Player"});
				const deadline=App.runningTime+req.timeoutSeconds;
				let answer:{success:boolean;resultJSON?:string;message?:string}|undefined;
				while(!answer){
					if(isCancelled&&isCancelled())error("Lua command canceled");
					if(App.runningTime>=deadline)error(`Lua command timed out after ${tostring(req.timeoutSeconds)} seconds`);
					answer=_studio_agent_tool_poll?.(requestId);
					if(!answer)sleep();
				}
				requestId=undefined;
				if(!answer.success)error(answer.message??"Studio Agent Lua Player failed");
				const [decoded]=safeJsonDecode(answer.resultJSON??"");
				const value=decoded as {success?:unknown;output?:unknown;message?:unknown;phase?:unknown}|undefined;
				if(!value||typeof value.success!=="boolean"||typeof value.output!=="string"
					||(value.message!==undefined&&typeof value.message!=="string")
					||(value.phase!==undefined&&value.phase!=="compile"&&value.phase!=="execute"&&value.phase!=="timeout"&&value.phase!=="validate"))error("Invalid Studio Agent Lua Player result");
				if(value.success)finish({success:true,mode:"lua",output:truncateCommandOutput(value.output)});
				else finish({success:false,mode:"lua",output:truncateCommandOutput(value.output),message:truncateCommandError(value.message??"Lua command failed"),phase:value.phase??"execute"});
			}catch(e){
				if(requestId){_studio_agent_tool_cancel?.(requestId);requestId=undefined;}
				const message=truncateCommandError(toStr(e));
				finish({success:false,mode:"lua",output:"",message,phase:message.indexOf("timed out")>=0?"timeout":"execute",interrupted:message.indexOf("canceled")>=0?true:undefined});
			}
		});
		Director.systemScheduler.schedule(()=>{
			if(settled)return true;
			const [ok,result]=coroutine.resume(routine);
			if(!ok){finish({success:false,mode:"lua",output:"",message:truncateCommandError(toStr(result)),phase:"execute"});return true;}
			return settled||result===true;
		});
	});
}


type CommandPrint = (this: void, ...values: unknown[]) => void;

const entryPrintSinks: Array<{ print: CommandPrint; ownsRun: () => boolean }> = [];
let currentCommandPrint: CommandPrint | undefined;
let defaultPrint: CommandPrint | undefined;
const routeCommandPrint: CommandPrint = (...values) => {
	const sink = currentCommandPrint ?? entryPrintSinks.find(item => item.ownsRun())?.print ?? defaultPrint;
	sink?.(...values);
};

function captureRuntimePrint(print: CommandPrint, ownsRun: () => boolean): () => void {
	if (entryPrintSinks.length === 0) {
		defaultPrint = _G["print"] as CommandPrint;
		_G["print"] = routeCommandPrint;
	}
	const sink = { print, ownsRun };
	entryPrintSinks.push(sink);
	return () => {
		const index = entryPrintSinks.indexOf(sink);
		if (index >= 0) entryPrintSinks.splice(index, 1);
		if (entryPrintSinks.length === 0 && _G["print"] === routeCommandPrint && defaultPrint !== undefined) _G["print"] = defaultPrint;
	};
}

function executeLuaCommand(req: {
	workDir: string;
	docLanguage?: DoraDocLanguage;
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
	const studioResult=executeStudioLuaCommand({...req,code});
	if(studioResult)return studioResult;
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
	let commandClosed = false;
	const startedAt = App.runningTime;
	let deadline = startedAt + req.timeoutSeconds;
	let waitingForDownload = false;
	let downloadWaitSeconds = 0;
	const isNetworkCancelled = () => commandClosed || req.isCancelled?.() === true;
	const waitForNetwork = <T>(operation: Promise<T>, timeout?: number): T => {
		const waitingSince = App.runningTime;
		waitingForDownload = timeout === undefined;
		if (timeout !== undefined) {
			deadline = math.max(deadline, waitingSince + timeout + 5);
		}
		let result: { value: T } | undefined;
		let failed = false;
		operation.then(value => { result = { value }; }, () => { failed = true; });
		while (result === undefined && !failed && !isNetworkCancelled()) sleep();
		if (waitingForDownload) {
			// Download waiting has its own inactivity timer and does not spend the Lua time budget.
			waitingForDownload = false;
			const waited = App.runningTime - waitingSince;
			downloadWaitSeconds += waited;
			deadline += waited;
		}
		if (result === undefined) error("Network command failed or was cancelled");
		return result.value;
	};
	// Each command observes current compiled project dependencies, even when a
	// previous command or another project used the same Lua module aliases.
	const refreshedProjectModules: Record<string, boolean> = {};
	const godotSceneResults: GodotSceneResult[] = [];
	const godotRuntimeSceneResults: GodotRuntimeSceneResult[] = [];
	const godotImportResults: GodotImportBatchResult[] = [];
	let lastPreviewResult: CommandPreviewGameResult | undefined;
	let previewCleanup: (() => void) | undefined;
	let restorePrint: (() => void) | undefined;
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
		acquireEntryLease(req.operationId, entry, isNetworkCancelled);
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
	const blockedDoraGlobals: Record<string, boolean> = {
		DB: true,
		HttpClient: true,
		HttpServer: true,
	};
	const scopedContent = createCommandContent(req.workDir, req.docLanguage);
	const env = setmetatable({
		projectDir: req.workDir,
		fetch: (url: unknown, target: unknown) => waitForNetwork(fetchUrl({
			workDir: req.workDir,
			url: typeof url === "string" ? url : "",
			target: typeof target === "string" ? target : "",
			isCancelled: isNetworkCancelled,
			onProgress: progress => req.onProgress?.({ ...progress, mode: "lua", operationId: req.operationId, stage: "download" }),
		})),
		web_search: (query: unknown, count?: unknown) => waitForNetwork(searchWeb(query, count, isNetworkCancelled), WEB_REQUEST_TIMEOUT_SECONDS),
		read_url: (url: unknown) => waitForNetwork(readWebPage(url, isNetworkCancelled), WEB_REQUEST_TIMEOUT_SECONDS),
		inspectGodotRuntimeScene: createGodotRuntimeSceneInjection({
			workDir: req.workDir,
			isCancelled: () => commandClosed || req.isCancelled?.() === true,
			print: capturePrint,
			onResult: result => {godotRuntimeSceneResults.push(result);},
		}),
		inspectGodotScene: createGodotSceneInjection({
			workDir: req.workDir,
			isCancelled: () => commandClosed || req.isCancelled?.() === true,
			print: capturePrint,
			onResult: result => {godotSceneResults.push(result);},
		}),
		importGodotAssets: createGodotImportInjection({
			workDir: req.workDir,
			isCancelled: () => commandClosed || req.isCancelled?.() === true,
			print: capturePrint,
			onResult: result => {
				godotImportResults.push(result);
				if (result.importedCount > 0) contentAccessed = true;
			},
		}),

		previewGame: createPreviewGameInjection({
			workDir: req.workDir,
			operationId: req.operationId,
			isCancelled: isNetworkCancelled,
			print: line => capturePrint(line),
			reserveCapture,
			registerCleanup: cleanup => { previewCleanup = cleanup; },
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
				const refreshDependency = (name: string): void => {
					const canonical = name.split("/").join(".");
					if (refreshedProjectModules[canonical] || canonical.indexOf("..") >= 0 || name.indexOf("/") === 0) return;
					const relative = canonical.split(".").join("/");
					let file = Path(req.workDir, relative + ".lua");
					if (!Content.exist(file)) file = Path(req.workDir, relative, "init.lua");
					if (!Content.exist(file)) return; // Never invalidate engine/runtime modules outside this project.
					refreshedProjectModules[canonical] = true;
					luaPackage.loaded[canonical] = undefined;
					luaPackage.loaded[relative] = undefined;
					const source = Content.load(file) as string;
					for (const [dependency] of string.gmatch(source, "require%s*%(%s*[\"']([^\"']+)[\"']%s*%)")) refreshDependency(dependency);
				};
				for (const name of reloadModules) refreshDependency(name);
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
		const onProgress = req.onProgress;
		const isCancelled = req.isCancelled;
		const finish = (result: ExecuteCommandResult) => {
			if (settled) return;
			settled = true;
			commandClosed = true;
			let cleanupError: string | undefined;
			const cleanup = previewCleanup;
			previewCleanup = undefined;
			try { cleanup?.(); }
			catch (e) { cleanupError = `failed to release Agent preview: ${tostring(e)}`; }
			restorePrint?.();
			restorePrint = undefined;
			if (!result.success && (result.interrupted === true || result.phase === "timeout")
				&& canClearEntryAfterCommand(req.operationId, entry)) {
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
				...(godotRuntimeSceneResults.length > 0 ? {godotRuntimeScenes: godotRuntimeSceneResults} : {}),
				...(godotSceneResults.length > 0 ? {godotScenes: godotSceneResults} : {}),
				...(godotImportResults.length > 0 ? {godotImports: godotImportResults} : {}),
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
			if (result.success && godotRuntimeSceneResults.some(scene => !scene.success)) {
				resolve({success: false, mode: "lua", output: result.output,
					message: "inspectGodotRuntimeScene failed; inspect godotRuntimeScenes for diagnostics", phase: "execute", ...visionFields});
				return;
			}
			if (result.success && godotSceneResults.some(scene => !scene.success)) {
				resolve({success: false, mode: "lua", output: result.output,
					message: "inspectGodotScene failed; inspect godotScenes for diagnostics", phase: "execute", ...visionFields});
				return;
			}
			if (result.success && godotImportResults.some(batch => !batch.success)) {
				resolve({success: false, mode: "lua", output: result.output,
					message: "importGodotAssets failed; inspect godotImports for per-file results", phase: "execute", ...visionFields});
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
			restorePrint = captureRuntimePrint(capturePrint, () => ownsEntryLease(req.operationId, entry));
			const [previousHook, previousHookMask, previousHookCount] = debug.gethook();
			let frameTimedOut = false, watchdogMessage: string | undefined;
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
			if (!waitingForDownload && App.runningTime >= deadline) {
				finish({
					success: false,
					mode: "lua",
					output: truncateCommandOutput(output.join("\n")),
					message: `Lua command timed out after ${tostring(math.max(1, math.floor(deadline - startedAt - downloadWaitSeconds + 0.5)))} seconds`,
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
			const previousCommandPrint = currentCommandPrint;
			currentCommandPrint = capturePrint;
			const [resumeSuccess, resumeResult] = coroutine.resume(commandRoutine);
			currentCommandPrint = previousCommandPrint;
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
	docLanguage?: DoraDocLanguage;
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
			docLanguage: req.docLanguage,
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
