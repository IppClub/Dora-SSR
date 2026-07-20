// @preview-file off clear
import { Content, Path } from "Dora";
import type { Message } from "Agent/Utils";
import { estimateTextTokens, safeJsonEncode, sanitizeUTF8 } from "Agent/Utils";
import * as Tools from "Agent/Tools";

export const AGENT_PLAN_DIR = ".agent/plan";
export const AGENT_PLAN_FILE = ".agent/plan/PLAN.md";
export const AGENT_PROGRESS_FILE = ".agent/plan/PROGRESS.md";

const DEFAULT_PLAN_DOCUMENT = `# 开发方案

## 目标

## 背景与当前实现

## 范围

### 包含

### 不包含

## 已确认决策

## 待确认问题

无

## 技术方案

## 实施步骤

| ID | 工作项 | 依赖 | 验收条件 |
| --- | --- | --- | --- |

## 风险与回退方案

## 验证计划

## 变更记录
`;

const DEFAULT_PROGRESS_DOCUMENT = `# 开发进度

## 当前工作

## 步骤进度

| ID | 状态 | 最新结果 | 下一步 |
| --- | --- | --- | --- |

## 修改记录

## 验证证据

## 阻塞问题

## 进度日志
`;

function trimText(value: string): string {
	const [trimmed] = string.match(value, "^%s*(.-)%s*$");
	return trimmed ?? "";
}

export function normalizeAgentPath(path: string): string {
	let normalized = trimText(path).split("\\").join("/");
	while (normalized.startsWith("./")) normalized = normalized.slice(2);
	return normalized;
}

export function isMainAgentMemoryPath(path: string): boolean {
	const normalized = normalizeAgentPath(path);
	return normalized === ".agent/main" || normalized.startsWith(".agent/main/");
}

export function isAgentPlanPath(path: string): boolean {
	const normalized = normalizeAgentPath(path);
	return normalized === AGENT_PLAN_DIR || normalized.startsWith(`${AGENT_PLAN_DIR}/`);
}

export function isAgentInternalDocumentPath(path: string): boolean {
	return isMainAgentMemoryPath(path) || isAgentPlanPath(path);
}

function ensureDirectory(dir: string): boolean {
	if (Content.exist(dir)) return Content.isdir(dir);
	const parent = Path.getPath(dir);
	if (parent !== "" && parent !== dir && !Content.exist(parent) && !ensureDirectory(parent)) return false;
	return Content.mkdir(dir);
}

export function ensureAgentPlanDocuments(workDir: string): { success: true; created: string[] } | { success: false; message: string } {
	const dir = Path(workDir, AGENT_PLAN_DIR);
	if (!ensureDirectory(dir)) return { success: false, message: `failed to create ${AGENT_PLAN_DIR}` };
	const created: string[] = [];
	const documents: Array<[string, string]> = [
		[AGENT_PLAN_FILE, DEFAULT_PLAN_DOCUMENT],
		[AGENT_PROGRESS_FILE, DEFAULT_PROGRESS_DOCUMENT],
	];
	for (let i = 0; i < documents.length; i++) {
		const [relative, content] = documents[i];
		const path = Path(workDir, relative);
		if (Content.exist(path)) continue;
		if (!Content.save(path, content)) return { success: false, message: `failed to create ${relative}` };
		Tools.sendWebIDEFileUpdate(path, true, content);
		created.push(relative);
	}
	return { success: true, created };
}

export interface EditBudgetState {
	freshProjectBuildPending?: boolean;
	freshProjectCodeFile?: string;
	hasBuilt?: boolean;
	unbuiltEdits?: boolean;
	editsSinceBuild?: number;
}

export function isEditBudgetExhausted(state: EditBudgetState): boolean {
	const mustCreateFreshEntry = state.freshProjectBuildPending === true
		&& state.freshProjectCodeFile === undefined
		&& state.hasBuilt !== true;
	return state.unbuiltEdits === true
		&& (state.editsSinceBuild ?? 0) >= 3
		&& !mustCreateFreshEntry;
}

export function getUncoveredConversationMessages(messages: Message[], lastConsolidatedIndex: number): Message[] {
	return messages.slice(lastConsolidatedIndex);
}

export function estimateConversationTokens(messages: Message[]): number {
	let tokens = 0;
	for (let i = 0; i < messages.length; i++) {
		const message = messages[i];
		tokens += 8;
		tokens += estimateTextTokens(message.role ?? "");
		tokens += estimateTextTokens(message.content ?? "");
		tokens += estimateTextTokens(message.name ?? "");
		tokens += estimateTextTokens(message.tool_call_id ?? "");
		tokens += estimateTextTokens(message.reasoning_content ?? "");
		const [toolCallsText] = safeJsonEncode((message.tool_calls ?? []) as object);
		tokens += estimateTextTokens(toolCallsText ?? "");
	}
	return tokens;
}

export function normalizeLineEndings(text: string): string {
	return text.split("\r\n").join("\n").split("\r").join("\n");
}

export function countOccurrences(text: string, needle: string): number {
	if (needle === "") return 0;
	let count = 0;
	let start = 0;
	while (start <= text.length - needle.length) {
		const index = text.indexOf(needle, start);
		if (index < 0) break;
		count++;
		start = index + needle.length;
	}
	return count;
}

export function containsWholeFileDuplicate(existing: string, replacement: string): boolean {
	const normalizedExisting = normalizeLineEndings(existing);
	const normalizedReplacement = normalizeLineEndings(replacement);
	if (normalizedExisting.length < 16 || normalizedReplacement.length <= normalizedExisting.length) return false;
	return countOccurrences(normalizedReplacement, normalizedExisting) > 1;
}

export function successfulEditResult(
	workDir: string,
	path: string,
	base: Record<string, unknown>
): Record<string, unknown> {
	const current = Tools.readFileRaw(workDir, path);
	const currentCharacters = current.success && typeof current.content === "string" ? current.content.length : 0;
	return {
		...base,
		actualSaved: current.success,
		actualSavedCharacters: currentCharacters,
		currentFileExists: current.success,
		currentCharacters,
		currentState: current.success
			? `saved ${currentCharacters} characters to ${path}`
			: `file state unavailable after edit: ${sanitizeUTF8(current.message)}`,
	};
}
