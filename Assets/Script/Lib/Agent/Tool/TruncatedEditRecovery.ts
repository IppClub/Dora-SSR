// @preview-file off clear
import { safeJsonDecode } from 'Agent/Utils';
import type { ToolCall } from 'Agent/Utils';

export interface TruncatedEditRecoveryNotice {
	targets: string[];
	operationCount: number;
	recoveredNewStrCharacters: number;
	incompleteStringCount: number;
}

export interface TruncatedEditRecoveryPlan extends TruncatedEditRecoveryNotice {
	params: Record<string, unknown>;
}

function recoverJsonStringProperty(text: string, key: string): { value: string; complete: boolean } | undefined {
	const marker = `"${key}"`;
	const markerIndex = text.indexOf(marker);
	if (markerIndex < 0) return undefined;
	const colonIndex = text.indexOf(":", markerIndex + marker.length);
	if (colonIndex < 0) return undefined;
	let quoteIndex = colonIndex + 1;
	while (quoteIndex < text.length) {
		const code = text.charCodeAt(quoteIndex);
		if (code !== 32 && code !== 9 && code !== 10 && code !== 13) break;
		quoteIndex++;
	}
	if (quoteIndex >= text.length || text.charCodeAt(quoteIndex) !== 34) return undefined;
	let escaped = false;
	for (let i = quoteIndex + 1; i < text.length; i++) {
		const code = text.charCodeAt(i);
		if (escaped) {
			escaped = false;
			continue;
		}
		if (code === 92) {
			escaped = true;
			continue;
		}
		if (code === 34) {
			const [decoded] = safeJsonDecode(`{"value":${text.slice(quoteIndex, i + 1)}}`);
			if (decoded && type(decoded) === "table" && typeof (decoded as Record<string, unknown>).value === "string") {
				return { value: (decoded as Record<string, unknown>).value as string, complete: true };
			}
			return undefined;
		}
	}
	const fragment = text.slice(quoteIndex);
	for (let trim = 0; trim <= 6 && trim <= fragment.length - 1; trim++) {
		const [decoded] = safeJsonDecode(`{"value":${fragment.slice(0, fragment.length - trim)}"}`);
		if (decoded && type(decoded) === "table" && typeof (decoded as Record<string, unknown>).value === "string") {
			return { value: (decoded as Record<string, unknown>).value as string, complete: false };
		}
	}
	return undefined;
}

interface RecoveredEditObject {
	start: number;
	path: string;
	oldStr: string;
	newStr: string;
	newStrComplete: boolean;
}

function recoverDirectEditObject(fragment: string, start: number, completeObject: boolean): RecoveredEditObject | undefined {
	if (completeObject) {
		const [decoded] = safeJsonDecode(fragment);
		if (!decoded || type(decoded) !== "table") return undefined;
		const obj = decoded as Record<string, unknown>;
		if (typeof obj.path !== "string" || typeof obj.old_str !== "string" || typeof obj.new_str !== "string") return undefined;
		return { start, path: obj.path, oldStr: obj.old_str, newStr: obj.new_str, newStrComplete: true };
	}
	const pathMarker = fragment.indexOf('"path"');
	const editsMarker = fragment.indexOf('"edits"');
	if (pathMarker < 0 || (editsMarker >= 0 && editsMarker < pathMarker)) return undefined;
	const path = recoverJsonStringProperty(fragment, "path");
	const oldStr = recoverJsonStringProperty(fragment, "old_str");
	const newStr = recoverJsonStringProperty(fragment, "new_str");
	if (!path?.complete || !oldStr?.complete || !newStr) return undefined;
	if (!newStr.complete && newStr.value.length === 0) return undefined;
	return {
		start,
		path: path.value,
		oldStr: oldStr.value,
		newStr: newStr.value,
		newStrComplete: newStr.complete,
	};
}

function recoverEditObjects(argumentsText: string): RecoveredEditObject[] {
	const starts: number[] = [];
	const recovered: RecoveredEditObject[] = [];
	let quote = false;
	let escaped = false;
	for (let i = 0; i < argumentsText.length; i++) {
		const code = argumentsText.charCodeAt(i);
		if (quote) {
			if (escaped) escaped = false;
			else if (code === 92) escaped = true;
			else if (code === 34) quote = false;
			continue;
		}
		if (code === 34) {
			quote = true;
			continue;
		}
		if (code === 123) {
			starts.push(i);
			continue;
		}
		if (code === 125 && starts.length > 0) {
			const start = starts.pop()!;
			const edit = recoverDirectEditObject(argumentsText.slice(start, i + 1), start, true);
			if (edit) recovered.push(edit);
		}
	}
	for (let i = starts.length - 1; i >= 0; i--) {
		const start = starts[i];
		const edit = recoverDirectEditObject(argumentsText.slice(start), start, false);
		if (edit) {
			recovered.push(edit);
			break;
		}
	}
	recovered.sort((left, right) => left.start - right.start);
	return recovered;
}

/** Recover only edit objects whose path, old string, and generated new-string
 * prefix are independently decodable. Unattributed trailing fragments are
 * deliberately discarded instead of guessing their target. */
export function planTruncatedEditRecovery(
	toolCalls: ToolCall[] | undefined
): TruncatedEditRecoveryPlan | undefined {
	if (!toolCalls || toolCalls.length === 0) return undefined;
	for (let i = toolCalls.length - 1; i >= 0; i--) {
		const fn = toolCalls[i]?.function;
		if (!fn || fn.name !== "edit_file" || typeof fn.arguments !== "string") continue;
		const edits = recoverEditObjects(fn.arguments);
		if (edits.length === 0) continue;
		const targets: string[] = [];
		let recoveredNewStrCharacters = 0;
		let incompleteStringCount = 0;
		for (const edit of edits) {
			if (targets.indexOf(edit.path) < 0) targets.push(edit.path);
			recoveredNewStrCharacters += edit.newStr.length;
			if (!edit.newStrComplete) incompleteStringCount++;
		}
		const useLegacyForm = edits.length === 1
			&& fn.arguments.trim().startsWith("{")
			&& fn.arguments.indexOf('"edits"') < 0;
		const params: Record<string, unknown> = useLegacyForm ? {
			path: edits[0].path,
			old_str: edits[0].oldStr,
			new_str: edits[0].newStr,
		} : {
			edits: edits.map(edit => ({ path: edit.path, old_str: edit.oldStr, new_str: edit.newStr })),
		};
		return {
			params,
			targets,
			operationCount: edits.length,
			recoveredNewStrCharacters,
			incompleteStringCount,
		};
	}
	return undefined;
}
