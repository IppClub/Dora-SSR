// @preview-file off clear
// Shared-prefix tool checkpoints and durable development-call recovery.
import { Content, Path, json } from 'Dora';
import { safeJsonDecode, safeJsonEncode, type Message, type ToolCall } from 'Agent/Utils';

export const HANDOFF_TOOL = {
	type: 'function' as const,
	function: {
		name: 'context_handoff',
		description: 'Record a checkpoint for the next model. Preserve current constraints, verified evidence, failures and every open next action. This does not execute development work.',
		parameters: {
			type: 'object',
			properties: {
				goal_constraints: { type: 'string' },
				progress_evidence: { type: 'string' },
				open_work_next_action: { type: 'string' },
			},
			required: ['goal_constraints', 'progress_evidence', 'open_work_next_action'],
			additionalProperties: false,
		},
	},
};

export interface ParsedHandoff {
	summary?: string;
	calls: ToolCall[];
	error?: string;
	complete: boolean;
}

export function parseToolHandoff(finishReason: string, message: Message): ParsedHandoff {
	const calls = message.tool_calls ?? [];
	const result: ParsedHandoff = { calls: [], complete: false };
	// Development calls may accompany the checkpoint in a complete response.
	if (finishReason !== 'stop' && finishReason !== 'tool_calls') {
		result.error = 'Incomplete provider response';
		return result;
	}
	const ids: string[] = [];
	for (const call of calls) {
		if (!call.id || ids.includes(call.id)) {
			result.error = 'Missing or duplicate tool call id';
			return result;
		}
		ids.push(call.id);
	}
	result.complete = true;
	const handoffs = calls.filter(call => call.function?.name === 'context_handoff');
	result.calls = calls.filter(call => call.function?.name !== 'context_handoff');
	if (handoffs.length === 1) {
		const [value, error] = safeJsonDecode(handoffs[0].function?.arguments ?? '');
		if (!error && value && typeof value === 'object') {
			const fields = value as Record<string, unknown>;
			const required = ['goal_constraints', 'progress_evidence', 'open_work_next_action'];
			if (required.every(field => typeof fields[field] === 'string' && (fields[field] as string).trim() !== '')) {
				result.summary = `## Goal and constraints\n${fields.goal_constraints}\n## Progress and evidence\n${fields.progress_evidence}\n## Open work and next action\n${fields.open_work_next_action}`;
			}
		}
	}
	if (!result.summary) result.error = 'Checkpoint fields missing; development calls are retained';
	return result;
}

function encode(value: unknown): string {
	const [encoded, error] = safeJsonEncode(value as object);
	if (error || !encoded) throw new Error(error ?? 'Cannot encode journal');
	return encoded;
}

function canonical(value: unknown): string {
	if (Array.isArray(value)) return '[' + value.map(item => canonical(item)).join(',') + ']';
	if (value !== undefined && value !== json.null && typeof value === 'object') {
		const object = value as Record<string, unknown>;
		return '{' + Object.keys(object).sort().map(key => encode(key) + ':' + canonical(object[key])).join(',') + '}';
	}
	return encode(value);
}

interface RecoveryReceipt {
	id: string;
	status: 'started' | 'done';
	output?: Record<string, unknown>;
}
interface RecoveryLedgerState {
	operations: Record<string, RecoveryReceipt>;
	ids: Record<string, string>;
}

// One journal covers every round of a compaction. Recovery actions execute
// serially so separate receipts cannot overwrite each other's persisted state.
export class HandoffRecoveryLedger {
	private path: string;
	private state: RecoveryLedgerState;

	constructor(dir: string) {
		Content.mkdir(dir);
		this.path = Path(dir, 'recovery-operations.json');
		if (Content.exist(this.path)) {
			const [value, error] = safeJsonDecode(Content.load(this.path) as string);
			if (error || !value) throw new Error(error ?? 'Invalid ledger');
			this.state = value as RecoveryLedgerState;
		} else {
			this.state = { operations: {}, ids: {} };
			this.save();
		}
	}

	private save(): void {
		if (!Content.save(this.path, encode(this.state))) throw new Error('Failed to persist recovery operation ledger');
	}

	async execute(call: ToolCall, handler: (call: ToolCall) => Promise<Record<string, unknown>>): Promise<Record<string, unknown>> {
		const [args, error] = safeJsonDecode(call.function?.arguments ?? '');
		if (error || !call.id || !call.function?.name) {
			return { success: false, code: 'INVALID_TOOL_ARGUMENTS', message: error ?? 'Missing call identity' };
		}
		const key = call.function.name + ':' + canonical(args);
		const previousKey = this.state.ids[call.id];
		if (previousKey !== undefined && previousKey !== key) {
			return { success: false, code: 'RECOVERY_CALL_ID_CONFLICT', message: 'The same call id was reused for different arguments' };
		}
		const receipt = this.state.operations[key];
		if (receipt !== undefined) {
			this.state.ids[call.id] = key;
			this.save();
			if (receipt.status !== 'done') {
				return { success: false, code: 'RECOVERY_RECONCILIATION_REQUIRED', message: 'Prior execution status uncertain; do not replay automatically' };
			}
			return { ...receipt.output, recoveryReplay: true, originalToolCallId: receipt.id };
		}
		this.state.ids[call.id] = key;
		this.state.operations[key] = { id: call.id, status: 'started' };
		this.save();
		const output = await handler(call);
		this.state.operations[key] = { id: call.id, status: 'done', output };
		this.save();
		return output;
	}
}
