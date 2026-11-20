// @preview-file off clear
import { App, Director, HttpClient, once } from 'Dora';
import { clipTextToTokenBudget, safeJsonDecode, safeJsonEncode, getActiveLLMConfig, getLLMConfigRecords, type LLMConfig } from 'Agent/Utils';
import { isSafePublicHttpUrl } from 'Agent/Tool/NetworkSafety';

const DEEPSEEK_ORIGIN = "https://api.deepseek.com";
export const WEB_REQUEST_TIMEOUT_SECONDS = 30;

function isOfficialEndpoint(url: string): boolean {
	return url === DEEPSEEK_ORIGIN + "/chat/completions" || url === DEEPSEEK_ORIGIN + "/v1/chat/completions";
}

function resolveDeepSeekWebApiKey(config: LLMConfig): string | undefined {
	if (config.studioGateway) return undefined;
	const [url] = string.gsub(config.url.trim(), "/+$", "");
	if (!isOfficialEndpoint(url)) return undefined;
	const apiKey = config.apiKey.trim();
	return apiKey !== "" ? apiKey : undefined;
}

function findApiKey(): string | undefined {
	const active = getActiveLLMConfig();
	const activeKey = active.success ? resolveDeepSeekWebApiKey(active.config) : undefined;
	if (activeKey !== undefined) return activeKey;
	for (const record of getLLMConfigRecords()) {
		if (typeof record.url !== "string" || typeof record.api_key !== "string") continue;
		const [url] = string.gsub(record.url.trim(), "/+$", "");
		if (isOfficialEndpoint(url) && record.api_key.trim() !== "") return record.api_key.trim();
	}
	return undefined;
}

async function request(
	apiKey: string, isCancelled: () => boolean, endpoint: "search" | "fetch", payload: Record<string, unknown>
): Promise<Record<string, unknown> | undefined> {
	if (isCancelled()) return undefined;
	const [body] = safeJsonEncode(payload);
	if (body === undefined) return undefined;
	const headers = [`Authorization: Bearer ${apiKey}`, "Content-Type: application/json"];
	const start = App.runningTime;
	const raw = await new Promise<string | undefined>(resolve => {
		let requestId = 0;
		let finished = false;
		let responseReady = false;
		let response: string | undefined;
		Director.systemScheduler.schedule(() => {
			const cancelled = isCancelled() || App.runningTime - start >= WEB_REQUEST_TIMEOUT_SECONDS;
			if (!cancelled && !responseReady) return false;
			finished = true;
			if (cancelled && requestId !== 0 && !responseReady) HttpClient.cancel(requestId);
			resolve(cancelled ? undefined : response);
			return true;
		});
		Director.systemScheduler.schedule(once(() => {
			if (finished) return;
			if (isCancelled()) {
				responseReady = true;
				return;
			}
			requestId = HttpClient.post(`${DEEPSEEK_ORIGIN}/v1/tools/${endpoint}`, headers, body, WEB_REQUEST_TIMEOUT_SECONDS, data => {
				if (finished) return;
				// Resume the Lua promise on the engine scheduler, including in WebAssembly.
				response = data;
				responseReady = true;
			});
			if (requestId === 0) responseReady = true;
		}));
	});
	if (raw === undefined || raw.length > 2 * 1024 * 1024) return undefined;
	const [value] = safeJsonDecode(raw);
	return typeof value === "object" ? value as Record<string, unknown> : undefined;
}

function failure(message: string) {
	return { success: false, message };
}

const unavailable = "No official DeepSeek API configuration found. Add a DeepSeek configuration with an API key in Agent settings.";

export async function searchWeb(input: unknown, limit: unknown, isCancelled: () => boolean): Promise<Record<string, unknown>> {
	const apiKey = findApiKey();
	if (apiKey === undefined) return failure(unavailable);
	const query = typeof input === "string" ? input.trim() : "";
	const [length] = utf8.len(query);
	if (length === undefined || length < 1 || length > 128) return failure("query must contain 1–128 characters");
	const count = limit ?? 5;
	if (typeof count !== "number" || math.floor(count) !== count || count < 1 || count > 10) return failure("count must be between 1 and 10");
	const result = await request(apiKey, isCancelled, "search", { query, count });
	if (!result || !Array.isArray(result.results)) return failure("DeepSeek web search failed or returned an invalid response.");
	const results = (result.results as Record<string, unknown>[]).slice(0, count)
		.filter(item => typeof item === "object" && typeof item.url === "string")
		.map(item => ({
			title: item.title,
			url: item.url,
			summary: typeof item.summary === "string" ? clipTextToTokenBudget(item.summary, 350) : item.snippet,
			date: item.date,
			rerank_score: item.rerank_score,
		}));
	return { success: true, results };
}

export async function readWebPage(input: unknown, isCancelled: () => boolean): Promise<Record<string, unknown>> {
	const apiKey = findApiKey();
	if (apiKey === undefined) return failure(unavailable);
	const url = typeof input === "string" ? input.trim() : "";
	const [authority] = string.match(url, "^[Hh][Tt][Tt][Pp][Ss]?://([^/?#]+)");
	if (url.length > 8192 || authority === undefined || authority.includes("@") || !isSafePublicHttpUrl(url)) {
		return failure("url must be a public HTTP or HTTPS URL without credentials (up to 8192 bytes)");
	}
	const result = await request(apiKey, isCancelled, "fetch", { url });
	if (!result || typeof result.content !== "string" || result.content === "") {
		return failure("DeepSeek could not retrieve readable page content.");
	}
	const content = clipTextToTokenBudget(result.content, 4000);
	return { success: true, url, title: result.title, content, truncated: content !== result.content };
}
