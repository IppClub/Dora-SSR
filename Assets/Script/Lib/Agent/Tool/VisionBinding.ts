// @preview-file off clear
import type { LLMConfig } from 'Agent/Utils';

/** Increment when a fixed vision route or its request profile changes. */
export const VISION_PROFILE_VERSION = 6;

export interface VisionBinding {
	provider: "deepseek" | "glm-coding-cn";
	model: string;
	url: string;
	apiKey: string;
	studioGateway?: boolean;
}

/** Only exact, reviewed service endpoints may reuse the current credential. */
export function resolveVisionBinding(config: LLMConfig): VisionBinding | undefined {
	if (config.apiKey.trim() === "") return undefined;
	if (config.studioGateway === true) {
		const vision = config.studioVision;
		if (!vision || config.apiKey !== "studio-agent") return undefined;
		const expectedModel = vision.provider === "deepseek" ? "deepseek-flash"
			: vision.provider === "glm-coding-cn" ? "glm-5.3-flash" : undefined;
		if (!expectedModel || vision.model !== expectedModel) return undefined;
		const [url] = string.gsub(vision.url.trim(), "/+$", "");
		if (!url.startsWith("https://") || !url.includes("/agent-host/") || !url.includes("/vision/")) return undefined;
		return { provider: vision.provider, model: vision.model, url, apiKey: config.apiKey, studioGateway: true };
	}
	const [url] = string.gsub(config.url.trim().toLowerCase(), "/+$", "");
	if (url === "https://api.deepseek.com/chat/completions" || url === "https://api.deepseek.com/v1/chat/completions") {
		return { provider: "deepseek", model: "deepseek-flash", url: "https://api.deepseek.com/v1/chat/completions", apiKey: config.apiKey };
	}
	if (url === "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions") {
		return { provider: "glm-coding-cn", model: "glm-5.3-flash", url: "https://open.bigmodel.cn/api/paas/v4/chat/completions", apiKey: config.apiKey };
	}
	return undefined;
}
