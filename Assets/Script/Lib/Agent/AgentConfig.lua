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
	executeCommandHookInstructionCount = 10000, -- 13
	executeCommandFrameTimeoutSeconds = 5, -- 14
	executeCommandMaxObjectGrowth = 50000, -- 15
	executeCommandMaxLuaRefGrowth = 10000, -- 16
	historyReadFileMaxChars = 12000, -- 17
	historyReadFileMaxLines = 300, -- 18
	readFileDefaultLimit = 300, -- 19
	historySearchFilesMaxMatches = 20, -- 20
	historySearchDoraApiMaxMatches = 12, -- 21
	historyListFilesMaxEntries = 200, -- 22
	historyBuildMaxMessages = 50, -- 23
	historyBuildMessageMaxChars = 1200, -- 24
	llmHistoryEditResultMessageMaxChars = 4000, -- 25
	llmHistoryBuildMaxMessages = 12, -- 26
	llmHistoryCommandOutputMaxChars = 8000, -- 27
	llmHistoryToolResultMaxChars = 12000, -- 28
	searchDoraApiLimitMax = 20, -- 29
	searchFilesLimitDefault = 20, -- 30
	listFilesMaxEntriesDefault = 200, -- 31
	searchPreviewContext = 80, -- 32
	completionTextMaxChars = 800, -- 33
	completionListMaxItems = 12, -- 34
	completionEvidenceMaxItems = 8 -- 35
} -- 35
____exports.AGENT_FILE_PATTERNS = {freshProjectCodeGlobs = { -- 38
	"**/*.ts", -- 40
	"**/*.tsx", -- 41
	"**/*.lua", -- 42
	"**/*.yue", -- 43
	"**/*.tl", -- 44
	"**/*.yarn", -- 45
	"**/*.xml", -- 46
	"!**/*.d.ts" -- 47
}} -- 47
return ____exports -- 47