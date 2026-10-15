-- [ts]: DecisionParsing.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local ____exports = {} -- 1
local AgentUtils = require("Agent.Utils") -- 1
local AgentToolRegistry = require("Agent.Tool.Registry") -- 3
local ____Policy = require("Agent.Runtime.Policy") -- 5
local getAgentDecisionPath = ____Policy.getAgentDecisionPath -- 5
local function isRecord(value) -- 7
	return type(value) == "table" -- 8
end -- 7
local function isArray(value) -- 11
	return __TS__ArrayIsArray(value) -- 12
end -- 11
local function hasXMLParam(params, name) -- 15
	return params[name] ~= nil -- 16
end -- 15
local function inferToolNameFromXMLParams(params) -- 19
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 19
		return "edit_file" -- 21
	end -- 21
	if hasXMLParam(params, "target_file") then -- 21
		return "delete_file" -- 24
	end -- 24
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 24
		if hasXMLParam(params, "path") then -- 24
			return "read_file" -- 27
		end -- 27
		return nil -- 28
	end -- 28
	if hasXMLParam(params, "docType") or hasXMLParam(params, "programmingLanguage") then -- 28
		if hasXMLParam(params, "pattern") then -- 28
			return "search_dora_doc" -- 31
		end -- 31
		return nil -- 32
	end -- 32
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 32
		if hasXMLParam(params, "pattern") then -- 32
			return "grep_files" -- 35
		end -- 35
		return nil -- 36
	end -- 36
	if hasXMLParam(params, "globs") then -- 36
		if hasXMLParam(params, "pattern") then -- 36
			return "grep_files" -- 39
		end -- 39
		return "glob_files" -- 40
	end -- 40
	if hasXMLParam(params, "maxEntries") then -- 40
		return "glob_files" -- 43
	end -- 43
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 43
		return "finish" -- 46
	end -- 46
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 46
		return "spawn_sub_agent" -- 49
	end -- 49
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 49
		return "list_sub_agents" -- 52
	end -- 52
	return nil -- 54
end -- 19
function ____exports.parseDSMLAttribute(source, offset, name) -- 57
	local attrOpen = name .. "=\"" -- 58
	local attrStart = (string.find( -- 59
		source, -- 59
		attrOpen, -- 59
		math.max(offset + 1, 1), -- 59
		true -- 59
	) or 0) - 1 -- 59
	if attrStart < 0 then -- 59
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 60
	end -- 60
	local valueStart = attrStart + #attrOpen -- 61
	local valueEnd = (string.find( -- 62
		source, -- 62
		"\"", -- 62
		math.max(valueStart + 1, 1), -- 62
		true -- 62
	) or 0) - 1 -- 62
	if valueEnd < 0 then -- 62
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 63
	end -- 63
	return { -- 64
		success = true, -- 65
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 66
		next = valueEnd + 1 -- 67
	} -- 67
end -- 57
local function extractDSMLReason(text, invokeStart, tool) -- 71
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 72
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 73
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 73
		return before -- 76
	end -- 76
	if tool == "finish" then -- 76
		return "" -- 77
	end -- 77
	return "Converted provider-native tool call syntax to XML." -- 78
end -- 71
function ____exports.parseDSMLToolCallObjectFromText(text) -- 81
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 82
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 83
	if invokeStart < 0 then -- 83
		return {success = false, message = "missing DSML invoke"} -- 84
	end -- 84
	local nameStart = invokeStart + #invokeOpen -- 85
	local nameEnd = (string.find( -- 86
		text, -- 86
		"\"", -- 86
		math.max(nameStart + 1, 1), -- 86
		true -- 86
	) or 0) - 1 -- 86
	if nameEnd < 0 then -- 86
		return {success = false, message = "unterminated DSML invoke name"} -- 87
	end -- 87
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 88
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 88
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 90
	end -- 90
	local invokeOpenEnd = (string.find( -- 92
		text, -- 92
		">", -- 92
		math.max(nameEnd + 1, 1), -- 92
		true -- 92
	) or 0) - 1 -- 92
	if invokeOpenEnd < 0 then -- 92
		return {success = false, message = "unterminated DSML invoke open tag"} -- 93
	end -- 93
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 94
	local invokeEnd = (string.find( -- 95
		text, -- 95
		invokeClose, -- 95
		math.max(invokeOpenEnd + 1 + 1, 1), -- 95
		true -- 95
	) or 0) - 1 -- 95
	if invokeEnd < 0 then -- 95
		return {success = false, message = "missing DSML invoke close tag"} -- 96
	end -- 96
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 98
	local params = {} -- 99
	local paramOpen = "<｜｜DSML｜｜parameter" -- 100
	local paramClose = "</｜｜DSML｜｜parameter>" -- 101
	local pos = 0 -- 102
	while pos < #body do -- 102
		local start = (string.find( -- 104
			body, -- 104
			paramOpen, -- 104
			math.max(pos + 1, 1), -- 104
			true -- 104
		) or 0) - 1 -- 104
		if start < 0 then -- 104
			break -- 105
		end -- 105
		local openEnd = (string.find( -- 106
			body, -- 106
			">", -- 106
			math.max(start + #paramOpen + 1, 1), -- 106
			true -- 106
		) or 0) - 1 -- 106
		if openEnd < 0 then -- 106
			return {success = false, message = "unterminated DSML parameter open tag"} -- 107
		end -- 107
		local name = ____exports.parseDSMLAttribute(body, start + #paramOpen, "name") -- 108
		if not name.success then -- 108
			return name -- 109
		end -- 109
		local close = (string.find( -- 110
			body, -- 110
			paramClose, -- 110
			math.max(openEnd + 1 + 1, 1), -- 110
			true -- 110
		) or 0) - 1 -- 110
		if close < 0 then -- 110
			return {success = false, message = "missing DSML parameter close tag"} -- 111
		end -- 111
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 112
		pos = close + #paramClose -- 113
	end -- 113
	return { -- 115
		success = true, -- 116
		obj = { -- 117
			tool = toolName, -- 118
			reason = extractDSMLReason(text, invokeStart, toolName), -- 119
			params = params -- 120
		} -- 120
	} -- 120
end -- 81
function ____exports.parseXMLToolCallObjectFromText(text) -- 125
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 126
	local rawObj -- 127
	if children.success then -- 127
		rawObj = children.obj -- 129
	else -- 129
		local dsml = ____exports.parseDSMLToolCallObjectFromText(text) -- 131
		if dsml.success then -- 131
			return dsml -- 132
		end -- 132
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 133
		local paramsCloseToken = "</params>" -- 134
		if toolStart >= 0 then -- 134
			local paramsClose = (string.find( -- 136
				text, -- 136
				paramsCloseToken, -- 136
				math.max(toolStart + 1, 1), -- 136
				true -- 136
			) or 0) - 1 -- 136
			if paramsClose >= toolStart then -- 136
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 138
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 139
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 139
					rawObj = bare.obj -- 141
				end -- 141
			end -- 141
		end -- 141
		if rawObj == nil then -- 141
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 146
			if paramsOpen < 0 then -- 146
				return children -- 147
			end -- 147
			local paramsCloseOnly = (string.find( -- 148
				text, -- 148
				paramsCloseToken, -- 148
				math.max(paramsOpen + 1, 1), -- 148
				true -- 148
			) or 0) - 1 -- 148
			if paramsCloseOnly < paramsOpen then -- 148
				return children -- 149
			end -- 149
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 150
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 151
			if not paramsOnly.success then -- 151
				return children -- 152
			end -- 152
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 153
			if inferredTool == nil then -- 153
				return children -- 154
			end -- 154
			local ____temp_0 -- 159
			if inferredTool == "finish" then -- 159
				____temp_0 = nil -- 159
			else -- 159
				____temp_0 = "Inferred tool from XML params." -- 159
			end -- 159
			return {success = true, obj = {tool = inferredTool, reason = ____temp_0, params = paramsOnly.obj}} -- 155
		end -- 155
	end -- 155
	if rawObj == nil then -- 155
		return children -- 165
	end -- 165
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 166
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 167
	if not params.success then -- 167
		return {success = false, message = params.message} -- 171
	end -- 171
	local arrayField = rawObj.tool == "analyze_image" and "paths" or nil -- 175
	if arrayField ~= nil and type(params.obj[arrayField]) == "string" then -- 175
		local decoded = AgentUtils.safeJsonDecode(params.obj[arrayField]) -- 177
		if __TS__ArrayIsArray(decoded) then -- 177
			params.obj[arrayField] = decoded -- 178
		end -- 178
	end -- 178
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 180
end -- 125
--- A main-agent finish envelope is a final answer, never a request for new work.
function ____exports.parseMainXMLCompletion(role, raw) -- 226
	if role ~= "main" then -- 226
		return nil -- 227
	end -- 227
	local first = (string.find(raw, "<tool_call", nil, true) or 0) - 1 -- 228
	if first < 0 or (string.find( -- 228
		raw, -- 229
		"<tool_call", -- 229
		math.max(first + 1 + 1, 1), -- 229
		true -- 229
	) or 0) - 1 >= 0 then -- 229
		return nil -- 229
	end -- 229
	local parsed = ____exports.parseXMLToolCallObjectFromText(raw) -- 230
	if not parsed.success or parsed.obj.tool ~= "finish" or not isRecord(parsed.obj.params) then -- 230
		return nil -- 231
	end -- 231
	local message = parsed.obj.params.message -- 232
	if type(message) ~= "string" or __TS__StringTrim(message) == "" then -- 232
		return nil -- 233
	end -- 233
	return { -- 234
		success = true, -- 234
		kind = "plain_text_completion", -- 234
		content = __TS__StringTrim(message) -- 234
	} -- 234
end -- 226
function ____exports.preservesXMLRepairTool(original, candidate) -- 237
	local source = ____exports.parseXMLToolCallObjectFromText(original) -- 238
	if not source.success or type(source.obj.tool) ~= "string" then -- 238
		return true -- 239
	end -- 239
	local repaired = ____exports.parseXMLToolCallObjectFromText(candidate) -- 240
	return repaired.success and repaired.obj.tool == source.obj.tool -- 241
end -- 237
function ____exports.isDecisionBatchSuccess(result) -- 244
	return result.kind == "batch" -- 245
end -- 244
function ____exports.isDecisionLoopContinue(result) -- 248
	return result.success == true and result.kind == "continue" -- 249
end -- 248
function ____exports.isDecisionPlainTextCompletion(result) -- 252
	return result.success == true and result.kind == "plain_text_completion" -- 253
end -- 252
function ____exports.classifyToolCallingTurnWithoutCalls(role, finishReason, messageContent, reasoningContent) -- 256
	if finishReason == "length" then -- 256
		return { -- 263
			success = true, -- 264
			kind = "continue", -- 265
			reason = "length", -- 266
			content = messageContent, -- 267
			reasoningContent = reasoningContent -- 268
		} -- 268
	end -- 268
	local ____opt_1 = messageContent -- 268
	local content = ____opt_1 and __TS__StringTrim(messageContent) or "" -- 271
	if content == "" then -- 271
		return nil -- 272
	end -- 272
	if role == "sub" then -- 272
		return {success = false, message = "sub agents must call finish with structured completion metadata; plain-text completion is not accepted", raw = content} -- 274
	end -- 274
	return {success = true, kind = "plain_text_completion", content = content, reasoningContent = reasoningContent} -- 280
end -- 256
function ____exports.parseDecisionObject(rawObj) -- 288
	if type(rawObj.tool) ~= "string" then -- 288
		return {success = false, message = "missing tool"} -- 289
	end -- 289
	local tool = rawObj.tool -- 290
	if not AgentToolRegistry.isKnownToolName(tool) then -- 290
		return {success = false, message = "unknown tool: " .. tool} -- 292
	end -- 292
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 294
	if tool ~= "finish" and (not reason or reason == "") then -- 294
		return {success = false, message = tool .. " requires top-level reason"} -- 298
	end -- 298
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 300
	return {success = true, tool = tool, params = params, reason = reason} -- 301
end -- 288
function ____exports.parseDecisionToolCall(functionName, rawObj) -- 309
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 309
		return {success = false, message = "unknown tool: " .. functionName} -- 311
	end -- 311
	if rawObj == nil then -- 311
		return {success = true, tool = functionName, params = {}} -- 314
	end -- 314
	if not isRecord(rawObj) then -- 314
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 317
	end -- 317
	return {success = true, tool = functionName, params = rawObj} -- 319
end -- 309
function ____exports.parseToolCallArguments(functionName, argsText) -- 326
	local trimmedArgs = __TS__StringTrim(argsText) -- 327
	if trimmedArgs == "" then -- 327
		return {} -- 329
	end -- 329
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 331
	if err ~= nil or rawObj == nil then -- 331
		return { -- 333
			success = false, -- 334
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 335
			raw = argsText -- 336
		} -- 336
	end -- 336
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 339
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 339
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 341
	end -- 341
	return rawObj -- 347
end -- 326
____exports.getDecisionPath = getAgentDecisionPath -- 350
function ____exports.validateDecision(tool, params) -- 352
	local definition = AgentToolRegistry.getToolDefinition(tool) -- 356
	if definition == nil then -- 356
		return {success = false, message = "unknown tool: " .. tool} -- 357
	end -- 357
	local validateInput = definition.validateInput -- 358
	local validation = validateInput and validateInput(params) -- 359
	if validation == nil then -- 359
		return {success = true, params = params} -- 360
	end -- 360
	return validation.success and ({success = true, params = validation.value}) or validation -- 361
end -- 352
function ____exports.validateCompletionForRole(role, tool, params) -- 366
	if tool ~= "finish" then -- 366
		return {success = true} -- 371
	end -- 371
	if role ~= "sub" then -- 371
		return {success = false, message = "finish is reserved for sub agents"} -- 372
	end -- 372
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 372
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 374
	end -- 374
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 376
	do -- 376
		local i = 0 -- 377
		while i < #requiredArrays do -- 377
			local name = requiredArrays[i + 1] -- 378
			if not isArray(params[name]) then -- 378
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 380
			end -- 380
			i = i + 1 -- 377
		end -- 377
	end -- 377
	return {success = true} -- 383
end -- 366
return ____exports -- 366