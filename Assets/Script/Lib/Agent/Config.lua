-- [ts]: Config.ts
local ____exports = {} -- 1
____exports.AGENT_DEFAULTS = { -- 3
	maxSteps = 999, -- 4
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
	compressionVisionReportMaxChars = 6000, -- 29
	searchDoraDocLimitMax = 20, -- 30
	searchFilesLimitDefault = 20, -- 31
	listFilesMaxEntriesDefault = 200, -- 32
	searchPreviewContext = 80, -- 33
	completionTextMaxChars = 800, -- 34
	completionListMaxItems = 12, -- 35
	completionEvidenceMaxItems = 8 -- 36
} -- 36
____exports.AGENT_FILE_PATTERNS = {freshProjectCodeGlobs = { -- 39
	"**/*.ts", -- 41
	"**/*.tsx", -- 42
	"**/*.lua", -- 43
	"**/*.yue", -- 44
	"**/*.tl", -- 45
	"**/*.yarn", -- 46
	"**/*.xml", -- 47
	"!**/*.d.ts" -- 48
}} -- 48
return ____exports -- 48