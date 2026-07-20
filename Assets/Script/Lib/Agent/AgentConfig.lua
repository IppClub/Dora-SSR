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
	searchDoraApiLimitMax = 20, -- 22
	searchFilesLimitDefault = 20, -- 23
	listFilesMaxEntriesDefault = 200, -- 24
	searchPreviewContext = 80 -- 25
} -- 25
function ____exports.getTurnBoundaryCompressionThreshold(contextWindow) -- 28
	local normalizedContextWindow = math.max( -- 29
		1, -- 29
		math.floor(contextWindow) -- 29
	) -- 29
	return math.floor(normalizedContextWindow * ____exports.AGENT_DEFAULTS.turnBoundaryCompressionRatio) -- 30
end -- 28
return ____exports -- 28