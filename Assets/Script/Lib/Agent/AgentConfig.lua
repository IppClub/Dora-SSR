-- [ts]: AgentConfig.ts
local ____exports = {} -- 1
____exports.AGENT_DEFAULTS = { -- 3
	maxSteps = 100, -- 4
	llmMaxTry = 5, -- 5
	llmTemperature = 0.1, -- 6
	llmMaxTokens = 8192, -- 7
	delegatedForegroundBatchLimit = 3, -- 8
	turnBoundaryCompressionRatio = 0.85 -- 9
} -- 9
____exports.AGENT_LIMITS = { -- 12
	userPromptMaxChars = 12000, -- 13
	historyReadFileMaxChars = 12000, -- 14
	historyReadFileMaxLines = 300, -- 15
	readFileDefaultLimit = 300, -- 16
	historySearchFilesMaxMatches = 20, -- 17
	historySearchDoraApiMaxMatches = 12, -- 18
	historyListFilesMaxEntries = 200, -- 19
	historyBuildMaxMessages = 50, -- 20
	historyBuildMessageMaxChars = 1200, -- 21
	llmHistoryEditResultMessageMaxChars = 4000, -- 22
	llmHistoryBuildMaxMessages = 12, -- 23
	llmHistoryCommandOutputMaxChars = 8000, -- 24
	llmHistoryToolResultMaxChars = 12000, -- 25
	searchDoraApiLimitMax = 20, -- 26
	searchFilesLimitDefault = 20, -- 27
	listFilesMaxEntriesDefault = 200, -- 28
	searchPreviewContext = 80 -- 29
} -- 29
function ____exports.getTurnBoundaryCompressionThreshold(contextWindow) -- 32
	local normalizedContextWindow = math.max( -- 33
		1, -- 33
		math.floor(contextWindow) -- 33
	) -- 33
	return math.floor(normalizedContextWindow * ____exports.AGENT_DEFAULTS.turnBoundaryCompressionRatio) -- 34
end -- 32
return ____exports -- 32