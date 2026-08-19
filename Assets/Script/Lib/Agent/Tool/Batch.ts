// @preview-file off clear
import type { AgentToolName } from 'Agent/Tool/Types';

export interface AgentToolBatchItem {
	tool: AgentToolName;
	toolCallId: string;
	params: Record<string, unknown>;
}

export interface AgentToolDecisionItem {
	tool: AgentToolName;
	toolCallId?: string;
	params: Record<string, unknown>;
}

export interface AgentToolBatch<T extends AgentToolBatchItem> {
	isConcurrencySafe: boolean;
	actions: T[];
}

export function cloneAgentToolParams(value: Record<string, unknown>): Record<string, unknown> {
	function clone(item: unknown): unknown {
		if (item === undefined) return item;
		if (Array.isArray(item)) return item.map(child => clone(child));
		if (typeof item === "object") {
			const output: Record<string, unknown> = {};
			for (const key in item as Record<string, unknown>) output[key] = clone((item as Record<string, unknown>)[key]);
			return output;
		}
		return item;
	}
	return clone(value) as Record<string, unknown>;
}

export function areAgentToolParamsEqual(left: unknown, right: unknown): boolean {
	if (left === right) return true;
	if (left === undefined || right === undefined) return false;
	if (Array.isArray(left) || Array.isArray(right)) {
		if (!Array.isArray(left) || !Array.isArray(right) || left.length !== right.length) return false;
		for (let i = 0; i < left.length; i++) {
			if (!areAgentToolParamsEqual(left[i], right[i])) return false;
		}
		return true;
	}
	if (typeof left === "object" && typeof right === "object") {
		let leftCount = 0;
		for (const key in left as Record<string, unknown>) {
			leftCount++;
			if (!areAgentToolParamsEqual((left as Record<string, unknown>)[key], (right as Record<string, unknown>)[key])) return false;
		}
		let rightCount = 0;
		for (const _key in right as Record<string, unknown>) rightCount++;
		return leftCount === rightCount;
	}
	return false;
}

function getReadBatchItems(params: Record<string, unknown>): Record<string, unknown>[] | undefined {
	if (!Array.isArray(params.reads)) return undefined;
	return params.reads.map(item => cloneAgentToolParams(item as Record<string, unknown>));
}

function getBuildBatchPaths(params: Record<string, unknown>): string[] | undefined {
	return Array.isArray(params.paths) ? (params.paths as string[]).slice() : undefined;
}

/**
 * Normalize consecutive compatible calls from one model response into the
 * existing batch form. The first call id is retained because history records
 * the normalized assistant message, while the raw provider response remains
 * available in the per-step debug output.
 */
export function coalesceCompatibleAgentToolCalls<T extends AgentToolDecisionItem>(actions: T[]): T[] {
	const output: T[] = [];
	let index = 0;
	while (index < actions.length) {
		const first = actions[index];
		if (first.tool !== "read_file" && first.tool !== "build") {
			output.push(first);
			index++;
			continue;
		}
		let end = index;
		while (end + 1 < actions.length && actions[end + 1].tool === first.tool) end++;
		if (end === index) {
			output.push(first);
			index++;
			continue;
		}
		if (first.tool === "read_file") {
			const reads: Record<string, unknown>[] = [];
			let compatible = true;
			for (let i = index; i <= end; i++) {
				const items = getReadBatchItems(actions[i].params);
				if (items === undefined) { compatible = false; break; }
				reads.push(...items);
			}
			if (compatible) {
				output.push({ ...first, params: { reads } });
				index = end + 1;
				continue;
			}
		} else {
			const paths: string[] = [];
			let compatible = true;
			for (let i = index; i <= end; i++) {
				const items = getBuildBatchPaths(actions[i].params);
				if (items === undefined) { compatible = false; break; }
				paths.push(...items);
			}
			if (compatible) {
				output.push({ ...first, params: { paths } });
				index = end + 1;
				continue;
			}
		}
		for (let i = index; i <= end; i++) output.push(actions[i]);
		index = end + 1;
	}
	return output;
}

export function partitionAgentToolCalls<T extends AgentToolBatchItem>(
	actions: T[],
	isParallelSafe: (this: void, tool: AgentToolName) => boolean
): AgentToolBatch<T>[] {
	const batches: AgentToolBatch<T>[] = [];
	for (let i = 0; i < actions.length; i++) {
		const action = actions[i];
		const isSafe = isParallelSafe(action.tool);
		const last = batches.length > 0 ? batches[batches.length - 1] : undefined;
		if (isSafe && last?.isConcurrencySafe === true) last.actions.push(action);
		else batches.push({ isConcurrencySafe: isSafe, actions: [action] });
	}
	return batches;
}
