-- [ts]: Defaults.ts
local ____exports = {} -- 1
____exports.AGENT_DEFAULTS = { -- 3
	memorySharedPrefixHandoff = true, -- 5
	maxSteps = 999, -- 6
	llmMaxTry = 5, -- 7
	llmTemperature = 0.1, -- 8
	llmMaxTokens = 64000, -- 9
	delegatedForegroundBatchLimit = 3 -- 10
} -- 10
____exports.AGENT_LIMITS = { -- 13
	userPromptMaxChars = 12000, -- 14
	executeCommandHookInstructionCount = 10000, -- 15
	executeCommandFrameTimeoutSeconds = 5, -- 16
	executeCommandMaxObjectGrowth = 50000, -- 17
	executeCommandMaxLuaRefGrowth = 10000, -- 18
	historyReadFileMaxChars = 12000, -- 19
	historyReadFileMaxLines = 300, -- 20
	readFileDefaultLimit = 300, -- 21
	historySearchFilesMaxMatches = 20, -- 22
	historySearchDoraApiMaxMatches = 12, -- 23
	historyListFilesMaxEntries = 200, -- 24
	historyBuildMaxMessages = 50, -- 25
	historyBuildMessageMaxChars = 1200, -- 26
	llmHistoryEditResultMessageMaxChars = 4000, -- 27
	llmHistoryBuildMaxMessages = 12, -- 28
	llmHistoryCommandOutputMaxChars = 8000, -- 29
	llmHistoryToolResultMaxChars = 12000, -- 30
	compressionVisionReportMaxChars = 6000, -- 31
	searchDoraDocLimitMax = 20, -- 32
	searchFilesLimitDefault = 20, -- 33
	listFilesMaxEntriesDefault = 200, -- 34
	searchPreviewContext = 80, -- 35
	completionTextMaxChars = 800, -- 36
	completionListMaxItems = 12, -- 37
	completionEvidenceMaxItems = 8 -- 38
} -- 38
____exports.AGENT_FILE_PATTERNS = {freshProjectCodeGlobs = { -- 41
	"**/project.godot", -- 43
	"**/*.gd", -- 44
	"**/*.tscn", -- 45
	"**/*.tres", -- 46
	"**/*.gdshader", -- 47
	"**/*.ts", -- 48
	"**/*.tsx", -- 49
	"**/*.lua", -- 50
	"**/*.yue", -- 51
	"**/*.tl", -- 52
	"**/*.yarn", -- 53
	"**/*.xml", -- 54
	"!**/*.d.ts" -- 55
}} -- 55
return ____exports -- 55