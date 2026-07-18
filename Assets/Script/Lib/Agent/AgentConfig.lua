-- [ts]: AgentConfig.ts
local ____exports = {} -- 1
____exports.AGENT_DEFAULTS = { -- 3
	maxSteps = 100, -- 4
	llmMaxTry = 5, -- 5
	llmTemperature = 0.1, -- 6
	llmMaxTokens = 8192, -- 7
	delegatedForegroundBatchLimit = 3, -- 8
	turnBoundaryCompressionRatio = 0.6, -- 9
	turnBoundaryHighMessageCompressionRatio = 0.4, -- 10
	turnBoundaryHighMessageCount = 64 -- 11
} -- 11
____exports.AGENT_LIMITS = { -- 14
	userPromptMaxChars = 12000, -- 15
	historyReadFileMaxChars = 12000, -- 16
	historyReadFileMaxLines = 300, -- 17
	readFileDefaultLimit = 300, -- 18
	historySearchFilesMaxMatches = 20, -- 19
	historySearchDoraApiMaxMatches = 12, -- 20
	historyListFilesMaxEntries = 200, -- 21
	historyBuildMaxMessages = 50, -- 22
	historyBuildMessageMaxChars = 1200, -- 23
	searchDoraApiLimitMax = 20, -- 24
	searchFilesLimitDefault = 20, -- 25
	listFilesMaxEntriesDefault = 200, -- 26
	searchPreviewContext = 80 -- 27
} -- 27
function ____exports.getTurnBoundaryCompressionThresholds(contextWindow) -- 30
	local normalizedContextWindow = math.max( -- 34
		1, -- 34
		math.floor(contextWindow) -- 34
	) -- 34
	return { -- 35
		defaultTokens = math.floor(normalizedContextWindow * ____exports.AGENT_DEFAULTS.turnBoundaryCompressionRatio), -- 36
		highMessageTokens = math.floor(normalizedContextWindow * ____exports.AGENT_DEFAULTS.turnBoundaryHighMessageCompressionRatio) -- 37
	} -- 37
end -- 30
return ____exports -- 30