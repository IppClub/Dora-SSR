// @preview-file off clear
import { DB } from 'Dora';
import { TABLE_STEP } from 'Agent/Storage/Database';
import { normalizeVisionUsage } from 'Agent/Tool/VisionResponse';
import { safeJsonDecode } from 'Agent/Utils';

export const VISION_MAX_CAPTURE_BATCHES = 3;
export const VISION_MAX_CAPTURE_FRAMES = 6;
export const VISION_MAX_ANALYSIS_REQUESTS = 3;
export const VISION_MAX_REPORTED_TOKENS = 60000;

export interface VisionTaskUsage {
	captureBatchCount: number;
	captureFrameCount: number;
	requestCount: number;
	reportedRequests: number;
	inputTokens: number;
	outputTokens: number;
	totalTokens: number;
}

export interface VisionBudgetState extends VisionTaskUsage {
	limits: {
		captureBatches: number;
		captureFrames: number;
		analysisRequests: number;
		reportedTokens: number;
	};
	remaining: {
		captureBatches: number;
		captureFrames: number;
		analysisRequests: number;
		reportedTokens: number;
	};
}

export function createEmptyVisionTaskUsage(): VisionTaskUsage {
	return {
		captureBatchCount: 0,
		captureFrameCount: 0,
		requestCount: 0,
		reportedRequests: 0,
		inputTokens: 0,
		outputTokens: 0,
		totalTokens: 0,
	};
}

function nonNegativeInteger(value: unknown): number {
	return typeof value === "number" && Number.isFinite(value)
		? math.max(0, math.floor(value))
		: 0;
}

/** Rebuild the task budget from persisted tool results, including command-hosted captures. */
export function getVisionTaskUsage(taskId: number): VisionTaskUsage {
	const usage = createEmptyVisionTaskUsage();
	if (taskId <= 0) return usage;
	const rows = DB.query(
		`SELECT tool, result_json FROM ${TABLE_STEP} WHERE task_id=? AND tool IN ('execute_command','analyze_image')`,
		[taskId],
	);
	if (!rows) error("Unable to read persisted vision task budget");
	for (const row of rows ?? []) {
		const tool = typeof row[0] === "string" ? row[0] : "";
		const [decoded] = safeJsonDecode(typeof row[1] === "string" ? row[1] : "");
		if (type(decoded) !== "table") continue;
		const result = decoded as {
			requestIssued?: boolean;
			visionCapture?: {batchCount?: number; frameCount?: number};
			usage?: {prompt_tokens?: number; completion_tokens?: number; total_tokens?: number};
		};
		if (tool === "execute_command") {
			usage.captureBatchCount += nonNegativeInteger(result.visionCapture?.batchCount);
			usage.captureFrameCount += nonNegativeInteger(result.visionCapture?.frameCount);
			continue;
		}
		if (tool !== "analyze_image" || result.requestIssued !== true) continue;
		usage.requestCount++;
		const tokens = normalizeVisionUsage(result.usage);
		if (!tokens) continue;
		usage.reportedRequests++;
		usage.inputTokens += math.max(0, tokens.prompt_tokens);
		usage.outputTokens += math.max(0, tokens.completion_tokens);
		usage.totalTokens += math.max(0, tokens.total_tokens ?? (tokens.prompt_tokens + tokens.completion_tokens));
	}
	return usage;
}

export function getVisionBudgetState(usage: VisionTaskUsage): VisionBudgetState {
	return {
		...usage,
		limits: {
			captureBatches: VISION_MAX_CAPTURE_BATCHES,
			captureFrames: VISION_MAX_CAPTURE_FRAMES,
			analysisRequests: VISION_MAX_ANALYSIS_REQUESTS,
			reportedTokens: VISION_MAX_REPORTED_TOKENS,
		},
		remaining: {
			captureBatches: math.max(0, VISION_MAX_CAPTURE_BATCHES - usage.captureBatchCount),
			captureFrames: math.max(0, VISION_MAX_CAPTURE_FRAMES - usage.captureFrameCount),
			analysisRequests: math.max(0, VISION_MAX_ANALYSIS_REQUESTS - usage.requestCount),
			reportedTokens: math.max(0, VISION_MAX_REPORTED_TOKENS - usage.totalTokens),
		},
	};
}
