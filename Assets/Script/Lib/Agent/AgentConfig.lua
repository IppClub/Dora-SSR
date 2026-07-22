-- [ts]: AgentConfig.ts
local ____exports = {} -- 1
____exports.AGENT_DEFAULTS = { -- 3
	maxSteps = 100, -- 4
	llmMaxTry = 5, -- 5
	llmTemperature = 0.1, -- 6
	llmMaxTokens = 8192, -- 7
	delegatedForegroundBatchLimit = 3 -- 8
} -- 8
____exports.AGENT_LIMITS = { -- 11
	userPromptMaxChars = 12000, -- 12
	historyReadFileMaxChars = 12000, -- 13
	historyReadFileMaxLines = 300, -- 14
	readFileDefaultLimit = 300, -- 15
	historySearchFilesMaxMatches = 20, -- 16
	historySearchDoraApiMaxMatches = 12, -- 17
	historyListFilesMaxEntries = 200, -- 18
	historyBuildMaxMessages = 50, -- 19
	historyBuildMessageMaxChars = 1200, -- 20
	llmHistoryEditResultMessageMaxChars = 4000, -- 21
	llmHistoryBuildMaxMessages = 12, -- 22
	llmHistoryCommandOutputMaxChars = 8000, -- 23
	llmHistoryToolResultMaxChars = 12000, -- 24
	searchDoraApiLimitMax = 20, -- 25
	searchFilesLimitDefault = 20, -- 26
	listFilesMaxEntriesDefault = 200, -- 27
	searchPreviewContext = 80, -- 28
	completionTextMaxChars = 800, -- 29
	completionListMaxItems = 12, -- 30
	completionEvidenceMaxItems = 8 -- 31
} -- 31
____exports.AGENT_FILE_PATTERNS = {freshProjectCodeGlobs = { -- 34
	"**/*.ts", -- 36
	"**/*.tsx", -- 37
	"**/*.lua", -- 38
	"**/*.yue", -- 39
	"**/*.tl", -- 40
	"**/*.yarn", -- 41
	"**/*.xml", -- 42
	"!**/*.d.ts" -- 43
}} -- 43
return ____exports -- 43