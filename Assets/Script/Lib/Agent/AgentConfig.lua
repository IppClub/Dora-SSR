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
	executeCommandMaxObjectGrowth = 50000, -- 14
	executeCommandMaxLuaRefGrowth = 10000, -- 15
	historyReadFileMaxChars = 12000, -- 16
	historyReadFileMaxLines = 300, -- 17
	readFileDefaultLimit = 300, -- 18
	historySearchFilesMaxMatches = 20, -- 19
	historySearchDoraApiMaxMatches = 12, -- 20
	historyListFilesMaxEntries = 200, -- 21
	historyBuildMaxMessages = 50, -- 22
	historyBuildMessageMaxChars = 1200, -- 23
	llmHistoryEditResultMessageMaxChars = 4000, -- 24
	llmHistoryBuildMaxMessages = 12, -- 25
	llmHistoryCommandOutputMaxChars = 8000, -- 26
	llmHistoryToolResultMaxChars = 12000, -- 27
	searchDoraApiLimitMax = 20, -- 28
	searchFilesLimitDefault = 20, -- 29
	listFilesMaxEntriesDefault = 200, -- 30
	searchPreviewContext = 80, -- 31
	completionTextMaxChars = 800, -- 32
	completionListMaxItems = 12, -- 33
	completionEvidenceMaxItems = 8 -- 34
} -- 34
____exports.AGENT_FILE_PATTERNS = {freshProjectCodeGlobs = { -- 37
	"**/*.ts", -- 39
	"**/*.tsx", -- 40
	"**/*.lua", -- 41
	"**/*.yue", -- 42
	"**/*.tl", -- 43
	"**/*.yarn", -- 44
	"**/*.xml", -- 45
	"!**/*.d.ts" -- 46
}} -- 46
return ____exports -- 46