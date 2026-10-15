-- [ts]: VisionBudget.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local DB = ____Dora.DB -- 2
local ____Database = require("Agent.Storage.Database") -- 3
local TABLE_STEP = ____Database.TABLE_STEP -- 3
local ____VisionResponse = require("Agent.Tool.VisionResponse") -- 4
local normalizeVisionUsage = ____VisionResponse.normalizeVisionUsage -- 4
local ____Utils = require("Agent.Utils") -- 5
local safeJsonDecode = ____Utils.safeJsonDecode -- 5
____exports.VISION_MAX_CAPTURE_BATCHES = 3 -- 7
____exports.VISION_MAX_CAPTURE_FRAMES = 6 -- 8
____exports.VISION_MAX_ANALYSIS_REQUESTS = 3 -- 9
____exports.VISION_MAX_REPORTED_TOKENS = 60000 -- 10
function ____exports.createEmptyVisionTaskUsage() -- 37
	return { -- 38
		captureBatchCount = 0, -- 39
		captureFrameCount = 0, -- 40
		requestCount = 0, -- 41
		reportedRequests = 0, -- 42
		inputTokens = 0, -- 43
		outputTokens = 0, -- 44
		totalTokens = 0 -- 45
	} -- 45
end -- 37
local function nonNegativeInteger(value) -- 49
	return type(value) == "number" and __TS__NumberIsFinite(value) and math.max( -- 50
		0, -- 51
		math.floor(value) -- 51
	) or 0 -- 51
end -- 49
--- Rebuild the task budget from persisted tool results, including command-hosted captures.
function ____exports.getVisionTaskUsage(taskId) -- 56
	local usage = ____exports.createEmptyVisionTaskUsage() -- 57
	if taskId <= 0 then -- 57
		return usage -- 58
	end -- 58
	local rows = DB:query(("SELECT tool, result_json FROM " .. TABLE_STEP) .. " WHERE task_id=? AND tool IN ('execute_command','analyze_image')", {taskId}) -- 59
	if not rows then -- 59
		error("Unable to read persisted vision task budget") -- 63
	end -- 63
	for ____, row in ipairs(rows or ({})) do -- 64
		do -- 64
			local tool = type(row[1]) == "string" and row[1] or "" -- 65
			local decoded = safeJsonDecode(type(row[2]) == "string" and row[2] or "") -- 66
			if type(decoded) ~= "table" then -- 66
				goto __continue7 -- 67
			end -- 67
			local result = decoded -- 68
			if tool == "execute_command" then -- 68
				local ____usage_3, ____captureBatchCount_4 = usage, "captureBatchCount" -- 68
				local ____nonNegativeInteger_2 = nonNegativeInteger -- 74
				local ____opt_0 = result.visionCapture -- 74
				____usage_3[____captureBatchCount_4] = ____usage_3[____captureBatchCount_4] + ____nonNegativeInteger_2(____opt_0 and ____opt_0.batchCount) -- 74
				local ____usage_8, ____captureFrameCount_9 = usage, "captureFrameCount" -- 74
				local ____nonNegativeInteger_7 = nonNegativeInteger -- 75
				local ____opt_5 = result.visionCapture -- 75
				____usage_8[____captureFrameCount_9] = ____usage_8[____captureFrameCount_9] + ____nonNegativeInteger_7(____opt_5 and ____opt_5.frameCount) -- 75
				goto __continue7 -- 76
			end -- 76
			if tool ~= "analyze_image" or result.requestIssued ~= true then -- 76
				goto __continue7 -- 78
			end -- 78
			usage.requestCount = usage.requestCount + 1 -- 79
			local tokens = normalizeVisionUsage(result.usage) -- 80
			if not tokens then -- 80
				goto __continue7 -- 81
			end -- 81
			usage.reportedRequests = usage.reportedRequests + 1 -- 82
			usage.inputTokens = usage.inputTokens + math.max(0, tokens.prompt_tokens) -- 83
			usage.outputTokens = usage.outputTokens + math.max(0, tokens.completion_tokens) -- 84
			usage.totalTokens = usage.totalTokens + math.max(0, tokens.total_tokens or tokens.prompt_tokens + tokens.completion_tokens) -- 85
		end -- 85
		::__continue7:: -- 85
	end -- 85
	return usage -- 87
end -- 56
function ____exports.getVisionBudgetState(usage) -- 90
	return __TS__ObjectAssign( -- 91
		{}, -- 91
		usage, -- 92
		{ -- 91
			limits = {captureBatches = ____exports.VISION_MAX_CAPTURE_BATCHES, captureFrames = ____exports.VISION_MAX_CAPTURE_FRAMES, analysisRequests = ____exports.VISION_MAX_ANALYSIS_REQUESTS, reportedTokens = ____exports.VISION_MAX_REPORTED_TOKENS}, -- 93
			remaining = { -- 99
				captureBatches = math.max(0, ____exports.VISION_MAX_CAPTURE_BATCHES - usage.captureBatchCount), -- 100
				captureFrames = math.max(0, ____exports.VISION_MAX_CAPTURE_FRAMES - usage.captureFrameCount), -- 101
				analysisRequests = math.max(0, ____exports.VISION_MAX_ANALYSIS_REQUESTS - usage.requestCount), -- 102
				reportedTokens = math.max(0, ____exports.VISION_MAX_REPORTED_TOKENS - usage.totalTokens) -- 103
			} -- 103
		} -- 103
	) -- 103
end -- 90
return ____exports -- 90