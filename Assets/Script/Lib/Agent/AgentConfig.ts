// @preview-file off clear

export const AGENT_DEFAULTS = {
	maxSteps: 100,
	llmMaxTry: 5,
	llmTemperature: 0.1,
	llmMaxTokens: 8192,
	delegatedForegroundBatchLimit: 3,
};

export const AGENT_LIMITS = {
	userPromptMaxChars: 12000,
	executeCommandHookInstructionCount: 10000,
	executeCommandMaxObjectGrowth: 50000,
	executeCommandMaxLuaRefGrowth: 10000,
	historyReadFileMaxChars: 12000,
	historyReadFileMaxLines: 300,
	readFileDefaultLimit: 300,
	historySearchFilesMaxMatches: 20,
	historySearchDoraApiMaxMatches: 12,
	historyListFilesMaxEntries: 200,
	historyBuildMaxMessages: 50,
	historyBuildMessageMaxChars: 1200,
	llmHistoryEditResultMessageMaxChars: 4000,
	llmHistoryBuildMaxMessages: 12,
	llmHistoryCommandOutputMaxChars: 8000,
	llmHistoryToolResultMaxChars: 12000,
	searchDoraApiLimitMax: 20,
	searchFilesLimitDefault: 20,
	listFilesMaxEntriesDefault: 200,
	searchPreviewContext: 80,
	completionTextMaxChars: 800,
	completionListMaxItems: 12,
	completionEvidenceMaxItems: 8,
};

export const AGENT_FILE_PATTERNS = {
	freshProjectCodeGlobs: [
		"**/*.ts",
		"**/*.tsx",
		"**/*.lua",
		"**/*.yue",
		"**/*.tl",
		"**/*.yarn",
		"**/*.xml",
		"!**/*.d.ts",
	] as string[],
};
