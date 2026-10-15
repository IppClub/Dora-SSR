// @preview-file off clear
import { safeJsonDecode, sanitizeUTF8 } from 'Agent/Utils';

export interface VisionProviderUsage {
	prompt_tokens: number;
	completion_tokens: number;
	total_tokens: number;
}

function tokenCount(value: unknown): value is number {
	return typeof value === "number" && value >= 0 && value < math.huge && value === math.floor(value);
}

export function normalizeVisionUsage(value: unknown): VisionProviderUsage | undefined {
	if (type(value) !== "table") return undefined;
	const usage = value as Record<string, unknown>;
	if (!tokenCount(usage.prompt_tokens) || !tokenCount(usage.completion_tokens)) return undefined;
	return {
		prompt_tokens: usage.prompt_tokens,
		completion_tokens: usage.completion_tokens,
		total_tokens: tokenCount(usage.total_tokens) ? usage.total_tokens : usage.prompt_tokens + usage.completion_tokens,
	};
}

/** Retain accounting even when a billed response is unusable; never retain reasoning or raw payloads. */
export function parseVisionResponse(raw: string, expectedModel: string): Record<string, unknown> {
	const [decoded] = safeJsonDecode(raw);
	if (type(decoded) !== "table") return {success: false, model: expectedModel, message: "Vision returned an invalid response"};
	const response = decoded as Record<string, unknown>;
	const usage = normalizeVisionUsage(response.usage);
	const accounting = {model: expectedModel, usage};
	if (response.model !== expectedModel) return {...accounting, success: false, message: "Vision response model is missing or differs from the registered binding"};
	const choices = type(response.choices) === "table" ? response.choices as unknown[] : [];
	const choice = type(choices[0]) === "table" ? choices[0] as Record<string, unknown> : undefined;
	const message = type(choice?.message) === "table" ? choice!.message as Record<string, unknown> : undefined;
	const report = message?.content;
	const finishReason = typeof choice?.finish_reason === "string" ? choice.finish_reason.slice(0, 32) : undefined;
	if (typeof report !== "string" || report.trim() === "" || finishReason !== "stop") {
		const message = finishReason === "length"
			? "Vision report was truncated by the provider output limit before completing (finish_reason=length); narrow the question or analyze fewer images"
			: "Vision returned no complete report";
		return {...accounting, success: false, finishReason, message};
	}
	return {...accounting, success: true, report: sanitizeUTF8(report.slice(0, 16000)), reportTruncated: report.length > 16000};
}
