// @preview-file off clear
import type { LLMConfig } from 'Agent/Utils';

/** Increment when a fixed vision route or its request profile changes. */
export const VISION_PROFILE_VERSION = 8;

export const VISION_UNAVAILABLE_MESSAGE = "没有可用的视觉配置。请在 Agent 设置中填写当前配置的视觉模型，或保存受支持的官方 DeepSeek / GLM Coding Plan 配置。";

export interface VisionBinding {
	provider: "deepseek" | "glm-coding-cn" | "custom";
	model: string;
	url: string;
	apiKey: string;
	studioGateway?: boolean;
	customModel?: boolean;
}

/** Default routes stay fixed; an explicit model opts into the current configured endpoint. */
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
	const configuredModel = config.customOptions?.visionModel;
	const customModel = typeof configuredModel === "string" ? configuredModel.trim() : "";
	const [url] = string.gsub(config.url.trim().toLowerCase(), "/+$", "");
	if (url === "https://api.deepseek.com/chat/completions" || url === "https://api.deepseek.com/v1/chat/completions") {
		return { provider: "deepseek", model: customModel !== "" ? customModel : "deepseek-flash", url: "https://api.deepseek.com/v1/chat/completions", apiKey: config.apiKey, customModel: customModel !== "" };
	}
	if (url === "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions") {
		return { provider: "glm-coding-cn", model: customModel !== "" ? customModel : "glm-5.3-flash", url, apiKey: config.apiKey, customModel: customModel !== "" };
	}
	if (customModel !== "" && (url.startsWith("https://") || url.startsWith("http://"))) {
		return {provider: "custom", model: customModel, url: config.url.trim(), apiKey: config.apiKey, customModel: true};
	}
	return undefined;
}

export function resolveTaskVisionBinding(config: LLMConfig, getSavedConfigs: () => LLMConfig[]): VisionBinding | undefined {
	const current = resolveVisionBinding(config);
	const customModel = config.customOptions?.visionModel;
	if (current || config.studioGateway || (typeof customModel === "string" && customModel.trim() !== "")) {
		return current;
	}
	for (const candidate of getSavedConfigs()) {
		const binding = resolveVisionBinding(candidate);
		if (binding && binding.provider !== "custom") return binding;
	}
	return undefined;
}
