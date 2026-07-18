// @preview-file off clear
import type { Message } from "Agent/Utils";
import { estimateTextTokens, safeJsonEncode, sanitizeUTF8 } from "Agent/Utils";
import * as Tools from "Agent/Tools";

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
