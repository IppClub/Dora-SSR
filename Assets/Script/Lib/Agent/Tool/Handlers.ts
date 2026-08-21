// @preview-file off clear
import * as AgentConfig from 'Agent/Config';
import { normalizeQuestionnaire } from 'Agent/Questionnaire';
import * as AgentRuntimePolicy from 'Agent/Runtime/Policy';
import { getAgentFileEditPlanGuardDenial } from 'Agent/Tool/Guards';
import { getAgentFileEditInputs } from 'Agent/Tool/Validation';
import * as AgentUtils from 'Agent/Utils';
import * as Tools from 'Agent/Tools';
import type { AgentToolHandler, AgentToolName } from 'Agent/Tool/Types';

function readOneFile(context: Parameters<AgentToolHandler>[0], input: Record<string, unknown>): Record<string, unknown> {
	const startLine = Number(input.startLine ?? 1);
	let endLine = Number(input.endLine ?? AgentConfig.AGENT_LIMITS.readFileDefaultLimit);
	let clippedAfterCompression = false;
	if (
		context.workflow.resumeNarrowReadMode === true
		&& startLine > 0
		&& endLine >= startLine
		&& endLine - startLine + 1 > 160
	) {
		endLine = startLine + 159;
		clippedAfterCompression = true;
	}
	const path = typeof input.path === "string" ? input.path : "";
	if (path.trim() === "") {
		return { success: false, message: "missing path" };
	}
	const output = Tools.readFile(
		context.workingDir,
		path,
		startLine,
		endLine,
		context.useChineseResponse ? "zh" : "en"
	) as unknown as Record<string, unknown>;
	if (clippedAfterCompression && output.success === true) {
		output.clipped = true;
		output.message = context.useChineseResponse
			? `压缩恢复阶段已自动截取为第 ${startLine}-${endLine} 行（最多 160 行）。如仍需后续内容，请从第 ${endLine + 1} 行继续窄读。`
			: `The post-compression read was clipped to lines ${startLine}-${endLine} (160 lines maximum). Continue narrowly from line ${endLine + 1} only if needed.`;
	}
	return output;
}

const readFile: AgentToolHandler = async (context, input) => {
	if (Array.isArray(input.reads)) {
		const reads = input.reads as Record<string, unknown>[];
		const results: Record<string, unknown>[] = [];
		let succeeded = 0;
		for (let i = 0; i < reads.length; i++) {
			const item = reads[i];
			const output = readOneFile(context, item);
			if (output.success === true) succeeded++;
			results.push({ index: i, path: item.path, ...output });
		}
		return { output: {
			success: succeeded === results.length,
			partial: succeeded > 0 && succeeded < results.length,
			mode: "batch",
			readCount: results.length,
			succeededReadCount: succeeded,
			failedReadCount: results.length - succeeded,
			results,
		} };
	}
	return { output: readOneFile(context, input) };
};

const grepFiles: AgentToolHandler = async (context, input) => {
	const output = await Tools.searchFiles({
		workDir: context.workingDir,
		path: (input.path as string) ?? "",
		docLanguage: context.useChineseResponse ? "zh" : "en",
		pattern: (input.pattern as string) ?? "",
		globs: input.globs as string[] | undefined,
		useRegex: input.useRegex as boolean | undefined,
		caseSensitive: input.caseSensitive as boolean | undefined,
		includeContent: true,
		contentWindow: AgentConfig.AGENT_LIMITS.searchPreviewContext,
		limit: math.max(1, math.floor(Number(input.limit ?? AgentConfig.AGENT_LIMITS.searchFilesLimitDefault))),
		offset: math.max(0, math.floor(Number(input.offset ?? 0))),
		groupByFile: input.groupByFile === true,
	});
	return { output: output as unknown as Record<string, unknown> };
};

const globFiles: AgentToolHandler = async (context, input) => {
	const output = Tools.listFiles({
		workDir: context.workingDir,
		path: (input.path as string) ?? "",
		globs: input.globs as string[] | undefined,
		maxEntries: math.max(1, math.floor(Number(input.maxEntries ?? AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault))),
	});
	return { output: output as unknown as Record<string, unknown> };
};

const searchDoraDoc: AgentToolHandler = async (context, input) => {
	context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild ?? 0) + 1;
	const output = await Tools.searchDoraDoc({
		pattern: (input.pattern as string) ?? "",
		docType: ((input.docType as string) ?? "dora-api") as Tools.DoraDocSearchType,
		docLanguage: (context.useChineseResponse ? "zh" : "en") as Tools.DoraDocLanguage,
		programmingLanguage: ((input.programmingLanguage as string) ?? "ts") as Tools.DoraDocProgrammingLanguage,
		limit: math.min(AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, math.max(1, Number(input.limit ?? 8))),
		useRegex: input.useRegex as boolean | undefined,
		caseSensitive: false,
		includeContent: true,
		contentWindow: AgentConfig.AGENT_LIMITS.searchPreviewContext,
	});
	return { output: output as unknown as Record<string, unknown> };
};

const build: AgentToolHandler = async (context, input) => {
	const paths = input.paths as string[];
	const results: Record<string, unknown>[] = [];
	const rawResults: Record<string, unknown>[] = [];
	let succeeded = 0;
	for (let i = 0; i < paths.length; i++) {
		const result = await Tools.build({
			workDir: context.workingDir,
			path: paths[i],
			isCancelled: () => context.cancellation.isCancelled(),
		});
		const rawResult = result as unknown as Record<string, unknown>;
		if (result.success) succeeded++;
		rawResults.push(rawResult);
		results.push({ index: i, path: paths[i], ...rawResult });
		if (context.cancellation.isCancelled()) break;
	}
	const output: Record<string, unknown> = {
		success: succeeded === paths.length,
		partial: succeeded > 0 && succeeded < paths.length,
		mode: "batch",
		requestedBuildCount: paths.length,
		buildCount: results.length,
		succeededBuildCount: succeeded,
		failedBuildCount: results.length - succeeded,
		skippedBuildCount: paths.length - results.length,
		results,
	};
	context.workflow.unbuiltEdits = false;
	context.workflow.editsSinceBuild = 0;
	context.workflow.editedPathsSinceBuild = [];
	context.workflow.hasBuilt = true;
	context.workflow.lastBuildSucceeded = output.success === true;
	if (output.success === true && context.workflow.freshProjectBuildPending === true) {
		context.workflow.freshProjectBuildPending = false;
	}
	context.workflow.apiSearchesSinceBuild = 0;
	context.workflow.buildRepairPending = false;
	if (output.success !== true) {
		for (let r = 0; r < rawResults.length; r++) {
			const messages = rawResults[r].messages as Array<{ success: boolean; file: string }> | undefined;
			for (let i = 0; i < (messages?.length ?? 0); i++) {
				if (messages![i].success === false && messages![i].file !== "") {
					context.workflow.buildRepairPending = true;
					break;
				}
			}
		}
	}
	if (output.success === true && context.workflow.failedTestNeedsBuild === true && context.workflow.failedTestHasSourceEdit === true) {
		context.workflow.failedTestNeedsBuild = false;
		context.workflow.failedTestHasSourceEdit = false;
	}
	return { output: output as unknown as Record<string, unknown> };
};

const fetchUrl: AgentToolHandler = async (context, input) => {
	const output = await Tools.fetchUrl({
		workDir: context.workingDir,
		url: typeof input.url === "string" ? input.url : "",
		target: typeof input.target === "string" ? input.target : "",
		isCancelled: () => context.cancellation.isCancelled(),
		onProgress: progress => context.emitProgress({ success: false, ...progress }),
	});
	return { output: output as unknown as Record<string, unknown> };
};

function updateDeterministicTestState(context: Parameters<AgentToolHandler>[0], output: string): void {
	let deterministicFailure = false;
	let deterministicPass = false;
	const outputLines = output.split("\n");
	for (let i = 0; i < outputLines.length && !deterministicFailure; i++) {
		const line = outputLines[i].trim().toLowerCase();
		if (line === "passed") deterministicPass = true;
		if (line === "failed") {
			deterministicFailure = true;
			break;
		}
		let searchFrom = 0;
		while (searchFrom < line.length) {
			const failedIndex = line.indexOf("failed", searchFrom);
			if (failedIndex < 0) break;
			let after = failedIndex + "failed".length;
			while (after < line.length) {
				const ch = line.slice(after, after + 1);
				if (ch !== " " && ch !== "\t" && ch !== ":" && ch !== "=") break;
				after++;
			}
			let afterEnd = after;
			while (afterEnd < line.length) {
				const ch = line.slice(afterEnd, afterEnd + 1);
				if (ch < "0" || ch > "9") break;
				afterEnd++;
			}
			let count: number | undefined;
			if (afterEnd > after) {
				count = Number(line.slice(after, afterEnd));
			} else {
				let before = failedIndex - 1;
				while (before >= 0) {
					const ch = line.slice(before, before + 1);
					if (ch !== " " && ch !== "\t" && ch !== ":" && ch !== "=") break;
					before--;
				}
				const beforeEnd = before + 1;
				while (before >= 0) {
					const ch = line.slice(before, before + 1);
					if (ch < "0" || ch > "9") break;
					before--;
				}
				if (beforeEnd > before + 1) count = Number(line.slice(before + 1, beforeEnd));
			}
			if (count !== undefined && count > 0) {
				deterministicFailure = true;
				break;
			}
			searchFrom = failedIndex + "failed".length;
		}
	}
	if (deterministicFailure) {
		context.workflow.failedTestNeedsBuild = true;
		context.workflow.failedTestHasSourceEdit = false;
	} else if (deterministicPass) {
		context.workflow.failedTestNeedsBuild = false;
		context.workflow.failedTestHasSourceEdit = false;
	}
}

const executeCommand: AgentToolHandler = async (context, input) => {
	const mode = typeof input.mode === "string" ? input.mode : "";
	const output = await Tools.executeCommand({
		workDir: context.workingDir,
		mode: mode as Tools.ExecuteCommandMode,
		code: typeof input.code === "string" ? input.code : undefined,
		command: typeof input.command === "string" ? input.command : undefined,
		cwd: typeof input.cwd === "string" ? input.cwd : undefined,
		timeoutSeconds: typeof input.timeoutSeconds === "number" ? input.timeoutSeconds : undefined,
		isCancelled: () => context.cancellation.isCancelled(),
		onProgress: progress => context.emitProgress({ success: false, ...progress }),
	});
	if (output.success && mode === "lua") {
		updateDeterministicTestState(context, output.output);
	}
	return { output: output as unknown as Record<string, unknown> };
};

interface StagedFileEdit {
	path: string;
	initialExists: boolean;
	exists: boolean;
	content: string;
	changed: boolean;
}

interface BatchEditOperationResult {
	index: number;
	path: string;
	success: boolean;
	mode?: string;
	code?: string;
	message?: string;
}

const editFile: AgentToolHandler = async (context, input) => {
	const operations = getAgentFileEditInputs(input);
	const isBatch = Array.isArray(input.edits);
	if (operations.length === 0) return { output: { success: false, message: "missing edit operations" } };
	const staged: StagedFileEdit[] = [];
	const results: BatchEditOperationResult[] = [];
	const successfulOperations: typeof operations = [];
	function failOperation(index: number, path: string, code: string, message: string): void {
		results.push({ index, path, success: false, code, message });
	}

	for (let i = 0; i < operations.length; i++) {
		const operation = operations[i];
		const path = AgentRuntimePolicy.normalizeAgentPath(operation.path);
		if (path === "") {
			failOperation(i, path, "INVALID_EDIT", "path is required");
			continue;
		}
		if (operation.oldStr === operation.newStr) {
			failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ");
			continue;
		}
		let stagedIndex = -1;
		for (let j = 0; j < staged.length; j++) {
			if (staged[j].path === path) {
				stagedIndex = j;
				break;
			}
		}
		if (stagedIndex < 0) {
			const targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path);
			if (!targetState.success) {
				failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message);
				continue;
			}
			staged.push({
				path,
				initialExists: targetState.exists,
				exists: targetState.exists,
				content: targetState.content,
				changed: false,
			});
			stagedIndex = staged.length - 1;
		}
		const target = staged[stagedIndex];
		const guardDenial = getAgentFileEditPlanGuardDenial(context, operation);
		if (guardDenial !== undefined) {
			failOperation(i, path, guardDenial.code, guardDenial.message);
			continue;
		}
		let mode = "";
		if (operation.oldStr === "") {
			if (target.exists && AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr)) {
				failOperation(i, path, "DUPLICATE_WHOLE_FILE", `rewrite rejected: the complete current file appears more than once in the replacement for ${path}`);
				continue;
			}
			mode = target.exists ? "overwrite" : "create";
			target.exists = true;
			target.content = operation.newStr;
		} else {
			if (!target.exists) {
				failOperation(i, path, "FILE_NOT_FOUND", `read file failed: ${path} does not exist; use old_str="" to create it earlier in the batch`);
				continue;
			}
			const normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content);
			const normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr);
			const normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr);
			const occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr);
			if (occurrences === 0) {
				const indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr);
				if (!indentTolerant.success) {
					failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message);
					continue;
				}
				target.content = indentTolerant.content;
				mode = "replace_indent_tolerant";
			} else {
				if (occurrences > 1) {
					failOperation(i, path, "AMBIGUOUS_MATCH", `old_str appears ${occurrences} times in ${path}. Provide more context to identify one target.`);
					continue;
				}
				target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr);
				mode = "replace";
			}
		}
		target.changed = true;
		results.push({ index: i, path, success: true, mode });
		successfulOperations.push(operation);
	}

	const changedTargets = staged.filter(item => item.changed);
	if (changedTargets.length === 0) {
		const firstFailure = results[0];
		return {
			output: isBatch ? {
				success: false,
				changed: false,
				mode: "batch",
				operationCount: operations.length,
				succeededOperationCount: 0,
				failedOperationCount: results.length,
				results,
				actualSaved: false,
			} : {
				success: false,
				code: firstFailure?.code,
				message: firstFailure?.message ?? "edit failed",
				actualSaved: false,
			},
		};
	}

	const changes: Tools.FileChange[] = changedTargets.map(item => ({
		path: item.path,
		op: item.initialExists ? "write" : "create",
		content: item.content,
	}));
	const applyRes = Tools.applyFileChanges(context.taskId, context.workingDir, changes, {
		summary: isBatch
			? `batch edit ${successfulOperations.length}/${operations.length} operations across ${changedTargets.length} files via edit_file`
			: `${results[0].mode} ${changedTargets[0].path} via edit_file`,
		toolName: "edit_file",
	});
	if (!applyRes.success) {
		return { output: { success: false, message: `${isBatch ? "batch edit" : "write file"} failed: ${applyRes.message}`, actualSaved: false, ...(isBatch ? { results } : {}) } };
	}

	const files = changes.map(change => ({ path: change.path, op: change.op }));
	let output: Record<string, unknown>;
	if (!isBatch) {
		output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[0].path, {
			success: true,
			changed: true,
			mode: results[0].mode,
			checkpointId: applyRes.checkpointId,
			checkpointSeq: applyRes.checkpointSeq,
			files,
		});
	} else {
		let totalCharacters = 0;
		let actualSaved = true;
		for (const item of changedTargets) {
			const current = Tools.readFileRaw(context.workingDir, item.path);
			if (!current.success || current.content !== item.content) actualSaved = false;
			if (current.success) totalCharacters += current.content.length;
		}
		output = {
			success: true,
			changed: true,
			mode: "batch",
			operationCount: operations.length,
			succeededOperationCount: successfulOperations.length,
			failedOperationCount: operations.length - successfulOperations.length,
			partial: successfulOperations.length < operations.length,
			fileCount: changedTargets.length,
			checkpointId: applyRes.checkpointId,
			checkpointSeq: applyRes.checkpointSeq,
			files,
			results,
			actualSaved,
			actualSavedCharacters: totalCharacters,
			currentFileExists: actualSaved,
			currentCharacters: totalCharacters,
			currentState: actualSaved
				? `saved ${successfulOperations.length}/${operations.length} operations across ${changedTargets.length} files`
				: "one or more batch file states could not be verified after commit",
		};
	}

	let authoredOperations = 0;
	const editedPaths = context.workflow.editedPathsSinceBuild ?? [];
	for (const operation of successfulOperations) {
		const path = AgentRuntimePolicy.normalizeAgentPath(operation.path);
		if (AgentRuntimePolicy.isAgentInternalDocumentPath(path)) continue;
		authoredOperations++;
		if (editedPaths.indexOf(path) < 0) editedPaths.push(path);
	}
	if (authoredOperations > 0) {
		context.workflow.unbuiltEdits = true;
		context.workflow.lastBuildSucceeded = false;
		if (context.workflow.failedTestNeedsBuild === true) context.workflow.failedTestHasSourceEdit = true;
		context.workflow.editedPathsSinceBuild = editedPaths;
		context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild ?? 0) + authoredOperations;
	}
	return { output };
};

const deleteFile: AgentToolHandler = async (context, input) => {
	const targetFile = typeof input.target_file === "string" ? input.target_file : "";
	if (targetFile.trim() === "") return { output: { success: false, message: "missing target_file" } };
	const normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile);
	const isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile);
	const result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {
		summary: `delete_file: ${targetFile}`,
		toolName: "delete_file",
	});
	if (!result.success) return { output: result as unknown as Record<string, unknown> };
	if (!isInternalDocumentEdit) {
		context.workflow.unbuiltEdits = true;
		context.workflow.lastBuildSucceeded = false;
		if (context.workflow.failedTestNeedsBuild === true) context.workflow.failedTestHasSourceEdit = true;
		const editedPaths = context.workflow.editedPathsSinceBuild ?? [];
		if (editedPaths.indexOf(normalizedTargetFile) < 0) editedPaths.push(normalizedTargetFile);
		context.workflow.editedPathsSinceBuild = editedPaths;
		context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild ?? 0) + 1;
	}
	return {
		output: {
			success: true,
			changed: true,
			mode: "delete",
			checkpointed: result.checkpointed,
			reversible: result.reversible,
			binary: result.binary,
			checkpointId: result.checkpointed ? result.checkpointId : undefined,
			checkpointSeq: result.checkpointed ? result.checkpointSeq : undefined,
			message: result.checkpointed ? undefined : result.message,
			files: [{ path: targetFile, op: "delete" as const }],
		},
	};
};

const askUser: AgentToolHandler = async (context, input) => {
	if (context.services.publishQuestionnaire === undefined) {
		return { output: { success: false, message: "ask_user is not available in this runtime" } };
	}
	if (context.sessionId === undefined || context.sessionId <= 0) {
		return { output: { success: false, message: "ask_user requires a session" } };
	}
	const normalized = normalizeQuestionnaire(input);
	if (!normalized.success) return { output: normalized };
	const result = await context.services.publishQuestionnaire({
		sessionId: context.sessionId,
		taskId: context.taskId,
		step: context.step,
		schema: normalized.schema as unknown as Record<string, unknown>,
	});
	if (!result.success) return { output: result };
	context.workflow.waitingQuestionnaireId = result.questionnaireId;
	return {
		output: { success: true, waitingForUser: true, questionnaireId: result.questionnaireId },
		control: { waitForUser: true, questionnaireId: result.questionnaireId },
	};
};

const spawnSubAgent: AgentToolHandler = async (context, input) => {
	if (context.services.spawnSubAgent === undefined) {
		return { output: { success: false, message: "spawn_sub_agent is not available in this runtime" } };
	}
	if (context.sessionId === undefined || context.sessionId <= 0) {
		return { output: { success: false, message: "spawn_sub_agent requires a parent session" } };
	}
	const filesHint = Array.isArray(input.filesHint)
		? (input.filesHint as unknown[]).filter(item => typeof item === "string") as string[]
		: undefined;
	const result = await context.services.spawnSubAgent({
		parentSessionId: context.sessionId,
		projectRoot: context.workingDir,
		title: typeof input.title === "string" ? input.title : "Sub",
		prompt: typeof input.prompt === "string" ? input.prompt : "",
		expectedOutput: typeof input.expectedOutput === "string" ? input.expectedOutput : undefined,
		filesHint,
		disabledAgentTools: context.disabledAgentTools,
	});
	if (!result.success) return { output: result };
	context.workflow.hasSpawnedSubAgentThisTask = true;
	return {
		output: {
			success: true,
			sessionId: result.sessionId,
			taskId: result.taskId,
			title: result.title,
			hint: "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs.",
		},
		control: { spawnedSubAgent: true },
	};
};

const listSubAgents: AgentToolHandler = async (context, input) => {
	if (context.services.listSubAgents === undefined) {
		return { output: { success: false, message: "list_sub_agents is not available in this runtime" } };
	}
	if (context.sessionId === undefined || context.sessionId <= 0) {
		return { output: { success: false, message: "list_sub_agents requires a current session" } };
	}
	const result = await context.services.listSubAgents({
		sessionId: context.sessionId,
		projectRoot: context.workingDir,
		status: typeof input.status === "string" ? input.status : undefined,
		limit: typeof input.limit === "number" ? input.limit : undefined,
		offset: typeof input.offset === "number" ? input.offset : undefined,
		query: typeof input.query === "string" ? input.query : undefined,
	});
	return { output: result as unknown as Record<string, unknown> };
};

const finish: AgentToolHandler = async (_context, input) => {
	const message = typeof input.message === "string" ? input.message.trim() : "";
	return {
		output: { success: true, message },
		control: {
			concludeTask: true,
			finalMessage: message,
			completion: AgentUtils.normalizeAgentCompletionReport(input),
		},
	};
};

export const AGENT_TOOL_HANDLERS: Partial<Record<AgentToolName, AgentToolHandler>> = {
	read_file: readFile,
	grep_files: grepFiles,
	glob_files: globFiles,
	search_dora_doc: searchDoraDoc,
	build,
	fetch_url: fetchUrl,
	execute_command: executeCommand,
	edit_file: editFile,
	delete_file: deleteFile,
	ask_user: askUser,
	spawn_sub_agent: spawnSubAgent,
	list_sub_agents: listSubAgents,
	finish,
};
