-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local isRecord, isArray, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, getFinishMessage, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, ensureToolCallId, hasXMLParam, inferToolNameFromXMLParams, parseDSMLAttribute, extractDSMLReason, parseDSMLToolCallObjectFromText, parseXMLToolCallObjectFromText, parseDecisionObject, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, tryParseAndValidateDecision, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, HISTORY_READ_FILE_MAX_CHARS, HISTORY_READ_FILE_MAX_LINES, READ_FILE_DEFAULT_LIMIT, HISTORY_SEARCH_FILES_MAX_MATCHES, HISTORY_SEARCH_DORA_API_MAX_MATCHES, HISTORY_LIST_FILES_MAX_ENTRIES, HISTORY_BUILD_MAX_MESSAGES, HISTORY_BUILD_MESSAGE_MAX_CHARS, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT, SEARCH_PREVIEW_CONTEXT, EditFileAction -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLMStreamAggregated = ____Utils.callLLMStreamAggregated -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local createLocalToolCallId = ____Utils.createLocalToolCallId -- 4
local parseSimpleXMLChildren = ____Utils.parseSimpleXMLChildren -- 4
local parseXMLObjectFromText = ____Utils.parseXMLObjectFromText -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local estimateTextTokens = ____Utils.estimateTextTokens -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 9
local AgentSkills = require("Agent.AgentSkills") -- 11
function isRecord(value) -- 13
	return type(value) == "table" -- 14
end -- 14
function isArray(value) -- 17
	return __TS__ArrayIsArray(value) -- 18
end -- 18
function emitAgentEvent(shared, event) -- 331
	if shared.onEvent then -- 331
		do -- 331
			local function ____catch(____error) -- 331
				Log( -- 336
					"Error", -- 336
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 336
				) -- 336
			end -- 336
			local ____try, ____hasReturned = pcall(function() -- 336
				shared:onEvent(event) -- 334
			end) -- 334
			if not ____try then -- 334
				____catch(____hasReturned) -- 334
			end -- 334
		end -- 334
	end -- 334
end -- 334
function getCancelledReason(shared) -- 465
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 465
		return shared.stopToken.reason -- 466
	end -- 466
	return shared.useChineseResponse and "已取消" or "cancelled" -- 467
end -- 467
function truncateText(text, maxLen) -- 653
	if #text <= maxLen then -- 653
		return text -- 654
	end -- 654
	local nextPos = utf8.offset(text, maxLen + 1) -- 655
	if nextPos == nil then -- 655
		return text -- 656
	end -- 656
	return string.sub(text, 1, nextPos - 1) .. "..." -- 657
end -- 657
function utf8TakeHead(text, maxChars) -- 660
	if maxChars <= 0 or text == "" then -- 660
		return "" -- 661
	end -- 661
	local nextPos = utf8.offset(text, maxChars + 1) -- 662
	if nextPos == nil then -- 662
		return text -- 663
	end -- 663
	return string.sub(text, 1, nextPos - 1) -- 664
end -- 664
function getReplyLanguageDirective(shared) -- 667
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 668
end -- 668
function replacePromptVars(template, vars) -- 673
	local output = template -- 674
	for key in pairs(vars) do -- 675
		output = table.concat( -- 676
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 676
			vars[key] or "" or "," -- 676
		) -- 676
	end -- 676
	return output -- 678
end -- 678
function limitReadContentForHistory(content, tool) -- 681
	local lines = __TS__StringSplit(content, "\n") -- 682
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 683
	local limitedByLines = overLineLimit and table.concat( -- 684
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 685
		"\n" -- 685
	) or content -- 685
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 685
		return content -- 688
	end -- 688
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 690
	local reasons = {} -- 693
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 693
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 694
	end -- 694
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 694
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 695
	end -- 695
	local hint = "Narrow the requested line range." -- 696
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 697
end -- 697
function sanitizeReadResultForHistory(tool, result) -- 712
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 712
		return result -- 714
	end -- 714
	local clone = {} -- 716
	for key in pairs(result) do -- 717
		clone[key] = result[key] -- 718
	end -- 718
	clone.content = limitReadContentForHistory(result.content, tool) -- 720
	return clone -- 721
end -- 721
function sanitizeSearchMatchesForHistory(items, maxItems) -- 724
	local shown = math.min(#items, maxItems) -- 728
	local out = {} -- 729
	do -- 729
		local i = 0 -- 730
		while i < shown do -- 730
			local row = items[i + 1] -- 731
			out[#out + 1] = { -- 732
				file = row.file, -- 733
				line = row.line, -- 734
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 735
			} -- 735
			i = i + 1 -- 730
		end -- 730
	end -- 730
	return out -- 740
end -- 740
function sanitizeSearchResultForHistory(tool, result) -- 743
	if result.success ~= true or not isArray(result.results) then -- 743
		return result -- 747
	end -- 747
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 747
		return result -- 748
	end -- 748
	local clone = {} -- 749
	for key in pairs(result) do -- 750
		clone[key] = result[key] -- 751
	end -- 751
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 753
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 754
	if tool == "grep_files" and isArray(result.groupedResults) then -- 754
		local grouped = result.groupedResults -- 759
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 760
		local sanitizedGroups = {} -- 761
		do -- 761
			local i = 0 -- 762
			while i < shown do -- 762
				local row = grouped[i + 1] -- 763
				sanitizedGroups[#sanitizedGroups + 1] = { -- 764
					file = row.file, -- 765
					totalMatches = row.totalMatches, -- 766
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 767
				} -- 767
				i = i + 1 -- 762
			end -- 762
		end -- 762
		clone.groupedResults = sanitizedGroups -- 772
	end -- 772
	return clone -- 774
end -- 774
function sanitizeListFilesResultForHistory(result) -- 777
	if result.success ~= true or not isArray(result.files) then -- 777
		return result -- 778
	end -- 778
	local clone = {} -- 779
	for key in pairs(result) do -- 780
		clone[key] = result[key] -- 781
	end -- 781
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 783
	return clone -- 784
end -- 784
function sanitizeBuildResultForHistory(result) -- 787
	if not isArray(result.messages) then -- 787
		return result -- 788
	end -- 788
	local clone = {} -- 789
	for key in pairs(result) do -- 790
		clone[key] = result[key] -- 791
	end -- 791
	local messages = result.messages -- 793
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 794
	local sanitized = {} -- 795
	do -- 795
		local i = 0 -- 796
		while i < shown do -- 796
			local item = messages[i + 1] -- 797
			local next = {} -- 798
			for key in pairs(item) do -- 799
				local value = item[key] -- 800
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 801
			end -- 801
			sanitized[#sanitized + 1] = next -- 805
			i = i + 1 -- 796
		end -- 796
	end -- 796
	clone.messages = sanitized -- 807
	if #messages > shown then -- 807
		clone.truncatedMessages = #messages - shown -- 809
	end -- 809
	return clone -- 811
end -- 811
function getDecisionToolDefinitions(shared) -- 829
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 830
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 831
	local base = shared.promptPack.toolDefinitionsDetailed -- 834
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 835
	local availableTools = __TS__ArrayFilter( -- 837
		AgentToolRegistry.getAllowedToolsForRole(shared.role), -- 837
		function(____, tool) return shared.decisionMode == "xml" or tool ~= "finish" end -- 838
	) -- 838
	local availability = (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat(availableTools, ", ") -- 839
	if usesDefaultToolPrompts then -- 839
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}}) -- 845
		return replacePromptVars(definitions .. availability, params) -- 850
	end -- 850
	local withRole = replacePromptVars((base .. mainAgentTools) .. availability, params) -- 852
	if (shared and shared.decisionMode) ~= "xml" then -- 852
		return withRole -- 857
	end -- 857
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 859
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 860
end -- 860
function getFinishMessage(params, fallback) -- 1192
	if fallback == nil then -- 1192
		fallback = "" -- 1192
	end -- 1192
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1192
		return __TS__StringTrim(params.message) -- 1194
	end -- 1194
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1194
		return __TS__StringTrim(params.response) -- 1197
	end -- 1197
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1197
		return __TS__StringTrim(params.summary) -- 1200
	end -- 1200
	return __TS__StringTrim(fallback) -- 1202
end -- 1202
function persistHistoryState(shared) -- 1205
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1206
end -- 1206
function getActiveConversationMessages(shared) -- 1213
	local activeMessages = {} -- 1214
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1214
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1221
	end -- 1221
	do -- 1221
		local i = shared.lastConsolidatedIndex -- 1225
		while i < #shared.messages do -- 1225
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1226
			i = i + 1 -- 1225
		end -- 1225
	end -- 1225
	return activeMessages -- 1228
end -- 1228
function getActiveRealMessageCount(shared) -- 1231
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1232
end -- 1232
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1235
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1240
	local previousActiveStart = shared.lastConsolidatedIndex -- 1241
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1242
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1243
	if type(carryMessageIndex) == "number" then -- 1243
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1243
		else -- 1243
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1251
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1254
		end -- 1254
	else -- 1254
		shared.carryMessageIndex = nil -- 1259
	end -- 1259
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1259
		shared.carryMessageIndex = nil -- 1269
	end -- 1269
end -- 1269
function ensureToolCallId(toolCallId) -- 1284
	if toolCallId and toolCallId ~= "" then -- 1284
		return toolCallId -- 1285
	end -- 1285
	return createLocalToolCallId() -- 1286
end -- 1286
function hasXMLParam(params, name) -- 1319
	return params[name] ~= nil -- 1320
end -- 1320
function inferToolNameFromXMLParams(params) -- 1323
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1323
		return "edit_file" -- 1325
	end -- 1325
	if hasXMLParam(params, "target_file") then -- 1325
		return "delete_file" -- 1328
	end -- 1328
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1328
		if hasXMLParam(params, "path") then -- 1328
			return "read_file" -- 1331
		end -- 1331
		return nil -- 1332
	end -- 1332
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1332
		if hasXMLParam(params, "pattern") then -- 1332
			return "search_dora_api" -- 1335
		end -- 1335
		return nil -- 1336
	end -- 1336
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1336
		if hasXMLParam(params, "pattern") then -- 1336
			return "grep_files" -- 1339
		end -- 1339
		return nil -- 1340
	end -- 1340
	if hasXMLParam(params, "globs") then -- 1340
		if hasXMLParam(params, "pattern") then -- 1340
			return "grep_files" -- 1343
		end -- 1343
		return "glob_files" -- 1344
	end -- 1344
	if hasXMLParam(params, "maxEntries") then -- 1344
		return "glob_files" -- 1347
	end -- 1347
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1347
		return "finish" -- 1350
	end -- 1350
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1350
		return "spawn_sub_agent" -- 1353
	end -- 1353
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1353
		return "list_sub_agents" -- 1356
	end -- 1356
	return nil -- 1358
end -- 1358
function parseDSMLAttribute(source, offset, name) -- 1361
	local attrOpen = name .. "=\"" -- 1362
	local attrStart = (string.find( -- 1363
		source, -- 1363
		attrOpen, -- 1363
		math.max(offset + 1, 1), -- 1363
		true -- 1363
	) or 0) - 1 -- 1363
	if attrStart < 0 then -- 1363
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1364
	end -- 1364
	local valueStart = attrStart + #attrOpen -- 1365
	local valueEnd = (string.find( -- 1366
		source, -- 1366
		"\"", -- 1366
		math.max(valueStart + 1, 1), -- 1366
		true -- 1366
	) or 0) - 1 -- 1366
	if valueEnd < 0 then -- 1366
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1367
	end -- 1367
	return { -- 1368
		success = true, -- 1369
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1370
		next = valueEnd + 1 -- 1371
	} -- 1371
end -- 1371
function extractDSMLReason(text, invokeStart, tool) -- 1375
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1376
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1377
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1377
		return before -- 1380
	end -- 1380
	if tool == "finish" then -- 1380
		return "" -- 1381
	end -- 1381
	return "Converted provider-native tool call syntax to XML." -- 1382
end -- 1382
function parseDSMLToolCallObjectFromText(text) -- 1385
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1386
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1387
	if invokeStart < 0 then -- 1387
		return {success = false, message = "missing DSML invoke"} -- 1388
	end -- 1388
	local nameStart = invokeStart + #invokeOpen -- 1389
	local nameEnd = (string.find( -- 1390
		text, -- 1390
		"\"", -- 1390
		math.max(nameStart + 1, 1), -- 1390
		true -- 1390
	) or 0) - 1 -- 1390
	if nameEnd < 0 then -- 1390
		return {success = false, message = "unterminated DSML invoke name"} -- 1391
	end -- 1391
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1392
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1392
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1394
	end -- 1394
	local invokeOpenEnd = (string.find( -- 1396
		text, -- 1396
		">", -- 1396
		math.max(nameEnd + 1, 1), -- 1396
		true -- 1396
	) or 0) - 1 -- 1396
	if invokeOpenEnd < 0 then -- 1396
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1397
	end -- 1397
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1398
	local invokeEnd = (string.find( -- 1399
		text, -- 1399
		invokeClose, -- 1399
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1399
		true -- 1399
	) or 0) - 1 -- 1399
	if invokeEnd < 0 then -- 1399
		return {success = false, message = "missing DSML invoke close tag"} -- 1400
	end -- 1400
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1402
	local params = {} -- 1403
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1404
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1405
	local pos = 0 -- 1406
	while pos < #body do -- 1406
		local start = (string.find( -- 1408
			body, -- 1408
			paramOpen, -- 1408
			math.max(pos + 1, 1), -- 1408
			true -- 1408
		) or 0) - 1 -- 1408
		if start < 0 then -- 1408
			break -- 1409
		end -- 1409
		local openEnd = (string.find( -- 1410
			body, -- 1410
			">", -- 1410
			math.max(start + #paramOpen + 1, 1), -- 1410
			true -- 1410
		) or 0) - 1 -- 1410
		if openEnd < 0 then -- 1410
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1411
		end -- 1411
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1412
		if not name.success then -- 1412
			return name -- 1413
		end -- 1413
		local close = (string.find( -- 1414
			body, -- 1414
			paramClose, -- 1414
			math.max(openEnd + 1 + 1, 1), -- 1414
			true -- 1414
		) or 0) - 1 -- 1414
		if close < 0 then -- 1414
			return {success = false, message = "missing DSML parameter close tag"} -- 1415
		end -- 1415
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1416
		pos = close + #paramClose -- 1417
	end -- 1417
	return { -- 1419
		success = true, -- 1420
		obj = { -- 1421
			tool = toolName, -- 1422
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1423
			params = params -- 1424
		} -- 1424
	} -- 1424
end -- 1424
function parseXMLToolCallObjectFromText(text) -- 1429
	local children = parseXMLObjectFromText(text, "tool_call") -- 1430
	local rawObj -- 1431
	if children.success then -- 1431
		rawObj = children.obj -- 1433
	else -- 1433
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1435
		if dsml.success then -- 1435
			return dsml -- 1436
		end -- 1436
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1437
		local paramsCloseToken = "</params>" -- 1438
		if toolStart >= 0 then -- 1438
			local paramsClose = (string.find( -- 1440
				text, -- 1440
				paramsCloseToken, -- 1440
				math.max(toolStart + 1, 1), -- 1440
				true -- 1440
			) or 0) - 1 -- 1440
			if paramsClose >= toolStart then -- 1440
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1442
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1443
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1443
					rawObj = bare.obj -- 1445
				end -- 1445
			end -- 1445
		end -- 1445
		if rawObj == nil then -- 1445
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1450
			if paramsOpen < 0 then -- 1450
				return children -- 1451
			end -- 1451
			local paramsCloseOnly = (string.find( -- 1452
				text, -- 1452
				paramsCloseToken, -- 1452
				math.max(paramsOpen + 1, 1), -- 1452
				true -- 1452
			) or 0) - 1 -- 1452
			if paramsCloseOnly < paramsOpen then -- 1452
				return children -- 1453
			end -- 1453
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1454
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1455
			if not paramsOnly.success then -- 1455
				return children -- 1456
			end -- 1456
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1457
			if inferredTool == nil then -- 1457
				return children -- 1458
			end -- 1458
			local ____temp_24 -- 1463
			if inferredTool == "finish" then -- 1463
				____temp_24 = nil -- 1463
			else -- 1463
				____temp_24 = "Inferred tool from XML params." -- 1463
			end -- 1463
			return {success = true, obj = {tool = inferredTool, reason = ____temp_24, params = paramsOnly.obj}} -- 1459
		end -- 1459
	end -- 1459
	if rawObj == nil then -- 1459
		return children -- 1469
	end -- 1469
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1470
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1471
	if not params.success then -- 1471
		return {success = false, message = params.message} -- 1475
	end -- 1475
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1477
end -- 1477
function parseDecisionObject(rawObj) -- 1569
	if type(rawObj.tool) ~= "string" then -- 1569
		return {success = false, message = "missing tool"} -- 1570
	end -- 1570
	local tool = rawObj.tool -- 1571
	if not AgentToolRegistry.isKnownToolName(tool) then -- 1571
		return {success = false, message = "unknown tool: " .. tool} -- 1573
	end -- 1573
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1575
	if tool ~= "finish" and (not reason or reason == "") then -- 1575
		return {success = false, message = tool .. " requires top-level reason"} -- 1579
	end -- 1579
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1581
	return {success = true, tool = tool, params = params, reason = reason} -- 1582
end -- 1582
function getDecisionPath(params) -- 1695
	if type(params.path) == "string" then -- 1695
		return __TS__StringTrim(params.path) -- 1696
	end -- 1696
	if type(params.target_file) == "string" then -- 1696
		return __TS__StringTrim(params.target_file) -- 1697
	end -- 1697
	return "" -- 1698
end -- 1698
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1701
	local num = __TS__Number(value) -- 1702
	if not __TS__NumberIsFinite(num) then -- 1702
		num = fallback -- 1703
	end -- 1703
	num = math.floor(num) -- 1704
	if num < minValue then -- 1704
		num = minValue -- 1705
	end -- 1705
	if maxValue ~= nil and num > maxValue then -- 1705
		num = maxValue -- 1706
	end -- 1706
	return num -- 1707
end -- 1707
function parseReadLineParam(value, fallback, paramName) -- 1710
	local num = __TS__Number(value) -- 1715
	if not __TS__NumberIsFinite(num) then -- 1715
		num = fallback -- 1716
	end -- 1716
	num = math.floor(num) -- 1717
	if num == 0 then -- 1717
		return {success = false, message = paramName .. " cannot be 0"} -- 1719
	end -- 1719
	return {success = true, value = num} -- 1721
end -- 1721
function validateDecision(tool, params) -- 1724
	if tool == "finish" then -- 1724
		local message = getFinishMessage(params) -- 1729
		if message == "" then -- 1729
			return {success = false, message = "finish requires params.message"} -- 1730
		end -- 1730
		params.message = message -- 1731
		return {success = true, params = params} -- 1732
	end -- 1732
	if tool == "read_file" then -- 1732
		local path = getDecisionPath(params) -- 1736
		if path == "" then -- 1736
			return {success = false, message = "read_file requires path"} -- 1737
		end -- 1737
		params.path = path -- 1738
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1739
		if not startLineRes.success then -- 1739
			return startLineRes -- 1740
		end -- 1740
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1741
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1742
		if not endLineRes.success then -- 1742
			return endLineRes -- 1743
		end -- 1743
		params.startLine = startLineRes.value -- 1744
		params.endLine = endLineRes.value -- 1745
		return {success = true, params = params} -- 1746
	end -- 1746
	if tool == "edit_file" then -- 1746
		local path = getDecisionPath(params) -- 1750
		if path == "" then -- 1750
			return {success = false, message = "edit_file requires path"} -- 1751
		end -- 1751
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1752
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1753
		params.path = path -- 1754
		params.old_str = oldStr -- 1755
		params.new_str = newStr -- 1756
		return {success = true, params = params} -- 1757
	end -- 1757
	if tool == "delete_file" then -- 1757
		local targetFile = getDecisionPath(params) -- 1761
		if targetFile == "" then -- 1761
			return {success = false, message = "delete_file requires target_file"} -- 1762
		end -- 1762
		params.target_file = targetFile -- 1763
		return {success = true, params = params} -- 1764
	end -- 1764
	if tool == "grep_files" then -- 1764
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1768
		if pattern == "" then -- 1768
			return {success = false, message = "grep_files requires pattern"} -- 1769
		end -- 1769
		params.pattern = pattern -- 1770
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1771
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1772
		return {success = true, params = params} -- 1773
	end -- 1773
	if tool == "search_dora_api" then -- 1773
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1777
		if pattern == "" then -- 1777
			return {success = false, message = "search_dora_api requires pattern"} -- 1778
		end -- 1778
		params.pattern = pattern -- 1779
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1780
		return {success = true, params = params} -- 1781
	end -- 1781
	if tool == "glob_files" then -- 1781
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1785
		return {success = true, params = params} -- 1786
	end -- 1786
	if tool == "build" then -- 1786
		local path = getDecisionPath(params) -- 1790
		if path ~= "" then -- 1790
			params.path = path -- 1792
		end -- 1792
		return {success = true, params = params} -- 1794
	end -- 1794
	if tool == "list_sub_agents" then -- 1794
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1798
		if status ~= "" then -- 1798
			params.status = status -- 1800
		end -- 1800
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1802
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1803
		if type(params.query) == "string" then -- 1803
			params.query = __TS__StringTrim(params.query) -- 1805
		end -- 1805
		return {success = true, params = params} -- 1807
	end -- 1807
	if tool == "spawn_sub_agent" then -- 1807
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1811
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1812
		if prompt == "" then -- 1812
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1813
		end -- 1813
		if title == "" then -- 1813
			return {success = false, message = "spawn_sub_agent requires title"} -- 1814
		end -- 1814
		params.prompt = prompt -- 1815
		params.title = title -- 1816
		if type(params.expectedOutput) == "string" then -- 1816
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1818
		end -- 1818
		if isArray(params.filesHint) then -- 1818
			params.filesHint = __TS__ArrayMap( -- 1821
				__TS__ArrayFilter( -- 1821
					params.filesHint, -- 1821
					function(____, item) return type(item) == "string" end -- 1822
				), -- 1822
				function(____, item) return sanitizeUTF8(item) end -- 1823
			) -- 1823
		end -- 1823
		return {success = true, params = params} -- 1825
	end -- 1825
	return {success = true, params = params} -- 1828
end -- 1828
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1831
	if includeToolDefinitions == nil then -- 1831
		includeToolDefinitions = false -- 1831
	end -- 1831
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 1832
	local sections = { -- 1835
		shared.promptPack.agentIdentityPrompt, -- 1836
		rolePrompt, -- 1837
		getReplyLanguageDirective(shared) -- 1838
	} -- 1838
	if shared.decisionMode == "tool_calling" then -- 1838
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 1841
	end -- 1841
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 1843
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 1844
	if memoryContext ~= "" then -- 1844
		sections[#sections + 1] = memoryContext -- 1846
	end -- 1846
	local skillsSection = buildSkillsSection(shared) -- 1848
	if skillsSection ~= "" then -- 1848
		sections[#sections + 1] = skillsSection -- 1850
	end -- 1850
	if includeToolDefinitions then -- 1850
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1853
		if shared.decisionMode == "xml" then -- 1853
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1855
		end -- 1855
	end -- 1855
	return table.concat(sections, "\n\n") -- 1858
end -- 1858
function buildSkillsSection(shared) -- 1861
	local ____opt_43 = shared.skills -- 1861
	if not (____opt_43 and ____opt_43.loader) then -- 1861
		return "" -- 1863
	end -- 1863
	return shared.skills.loader:buildSkillsPromptSection() -- 1865
end -- 1865
function buildXmlDecisionInstruction(shared, feedback) -- 1992
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1993
end -- 1993
function tryParseAndValidateDecision(rawText) -- 2059
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2060
	if not parsed.success then -- 2060
		return {success = false, message = parsed.message, raw = rawText} -- 2062
	end -- 2062
	local decision = parseDecisionObject(parsed.obj) -- 2064
	if not decision.success then -- 2064
		return {success = false, message = decision.message, raw = rawText} -- 2066
	end -- 2066
	local validation = validateDecision(decision.tool, decision.params) -- 2068
	if not validation.success then -- 2068
		return {success = false, message = validation.message, raw = rawText} -- 2070
	end -- 2070
	decision.params = validation.params -- 2072
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2073
	return decision -- 2074
end -- 2074
function executeToolAction(shared, action) -- 3365
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3365
		if shared.stopToken.stopped then -- 3365
			return ____awaiter_resolve( -- 3365
				nil, -- 3365
				{ -- 3367
					success = false, -- 3367
					message = getCancelledReason(shared) -- 3367
				} -- 3367
			) -- 3367
		end -- 3367
		local params = action.params -- 3369
		if action.tool == "read_file" then -- 3369
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3371
			if __TS__StringTrim(path) == "" then -- 3371
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3371
			end -- 3371
			local ____Tools_readFile_107 = Tools.readFile -- 3375
			local ____shared_workingDir_105 = shared.workingDir -- 3376
			local ____params_startLine_103 = params.startLine -- 3378
			if ____params_startLine_103 == nil then -- 3378
				____params_startLine_103 = 1 -- 3378
			end -- 3378
			local ____TS__Number_result_106 = __TS__Number(____params_startLine_103) -- 3378
			local ____params_endLine_104 = params.endLine -- 3379
			if ____params_endLine_104 == nil then -- 3379
				____params_endLine_104 = READ_FILE_DEFAULT_LIMIT -- 3379
			end -- 3379
			return ____awaiter_resolve( -- 3379
				nil, -- 3379
				____Tools_readFile_107( -- 3375
					____shared_workingDir_105, -- 3376
					path, -- 3377
					____TS__Number_result_106, -- 3378
					__TS__Number(____params_endLine_104), -- 3379
					shared.useChineseResponse and "zh" or "en" -- 3380
				) -- 3380
			) -- 3380
		end -- 3380
		if action.tool == "grep_files" then -- 3380
			local ____Tools_searchFiles_121 = Tools.searchFiles -- 3384
			local ____shared_workingDir_114 = shared.workingDir -- 3385
			local ____temp_115 = params.path or "" -- 3386
			local ____temp_116 = params.pattern or "" -- 3387
			local ____params_globs_117 = params.globs -- 3388
			local ____params_useRegex_118 = params.useRegex -- 3389
			local ____params_caseSensitive_119 = params.caseSensitive -- 3390
			local ____math_max_110 = math.max -- 3393
			local ____math_floor_109 = math.floor -- 3393
			local ____params_limit_108 = params.limit -- 3393
			if ____params_limit_108 == nil then -- 3393
				____params_limit_108 = SEARCH_FILES_LIMIT_DEFAULT -- 3393
			end -- 3393
			local ____math_max_110_result_120 = ____math_max_110( -- 3393
				1, -- 3393
				____math_floor_109(__TS__Number(____params_limit_108)) -- 3393
			) -- 3393
			local ____math_max_113 = math.max -- 3394
			local ____math_floor_112 = math.floor -- 3394
			local ____params_offset_111 = params.offset -- 3394
			if ____params_offset_111 == nil then -- 3394
				____params_offset_111 = 0 -- 3394
			end -- 3394
			local result = __TS__Await(____Tools_searchFiles_121({ -- 3384
				workDir = ____shared_workingDir_114, -- 3385
				path = ____temp_115, -- 3386
				pattern = ____temp_116, -- 3387
				globs = ____params_globs_117, -- 3388
				useRegex = ____params_useRegex_118, -- 3389
				caseSensitive = ____params_caseSensitive_119, -- 3390
				includeContent = true, -- 3391
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3392
				limit = ____math_max_110_result_120, -- 3393
				offset = ____math_max_113( -- 3394
					0, -- 3394
					____math_floor_112(__TS__Number(____params_offset_111)) -- 3394
				), -- 3394
				groupByFile = params.groupByFile == true -- 3395
			})) -- 3395
			return ____awaiter_resolve(nil, result) -- 3395
		end -- 3395
		if action.tool == "search_dora_api" then -- 3395
			local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3400
			local ____temp_125 = params.pattern or "" -- 3401
			local ____temp_126 = params.docSource or "api" -- 3402
			local ____temp_127 = shared.useChineseResponse and "zh" or "en" -- 3403
			local ____temp_128 = params.programmingLanguage or "ts" -- 3404
			local ____math_min_124 = math.min -- 3405
			local ____math_max_123 = math.max -- 3405
			local ____params_limit_122 = params.limit -- 3405
			if ____params_limit_122 == nil then -- 3405
				____params_limit_122 = 8 -- 3405
			end -- 3405
			local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3400
				pattern = ____temp_125, -- 3401
				docSource = ____temp_126, -- 3402
				docLanguage = ____temp_127, -- 3403
				programmingLanguage = ____temp_128, -- 3404
				limit = ____math_min_124( -- 3405
					SEARCH_DORA_API_LIMIT_MAX, -- 3405
					____math_max_123( -- 3405
						1, -- 3405
						__TS__Number(____params_limit_122) -- 3405
					) -- 3405
				), -- 3405
				useRegex = params.useRegex, -- 3406
				caseSensitive = false, -- 3407
				includeContent = true, -- 3408
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3409
			})) -- 3409
			return ____awaiter_resolve(nil, result) -- 3409
		end -- 3409
		if action.tool == "glob_files" then -- 3409
			local ____Tools_listFiles_136 = Tools.listFiles -- 3414
			local ____shared_workingDir_133 = shared.workingDir -- 3415
			local ____temp_134 = params.path or "" -- 3416
			local ____params_globs_135 = params.globs -- 3417
			local ____math_max_132 = math.max -- 3418
			local ____math_floor_131 = math.floor -- 3418
			local ____params_maxEntries_130 = params.maxEntries -- 3418
			if ____params_maxEntries_130 == nil then -- 3418
				____params_maxEntries_130 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3418
			end -- 3418
			local result = ____Tools_listFiles_136({ -- 3414
				workDir = ____shared_workingDir_133, -- 3415
				path = ____temp_134, -- 3416
				globs = ____params_globs_135, -- 3417
				maxEntries = ____math_max_132( -- 3418
					1, -- 3418
					____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3418
				) -- 3418
			}) -- 3418
			return ____awaiter_resolve(nil, result) -- 3418
		end -- 3418
		if action.tool == "delete_file" then -- 3418
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3423
			if __TS__StringTrim(targetFile) == "" then -- 3423
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3423
			end -- 3423
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3427
			if not result.success then -- 3427
				return ____awaiter_resolve(nil, result) -- 3427
			end -- 3427
			return ____awaiter_resolve(nil, { -- 3427
				success = true, -- 3435
				changed = true, -- 3436
				mode = "delete", -- 3437
				checkpointId = result.checkpointId, -- 3438
				checkpointSeq = result.checkpointSeq, -- 3439
				files = {{path = targetFile, op = "delete"}} -- 3440
			}) -- 3440
		end -- 3440
		if action.tool == "build" then -- 3440
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3444
			return ____awaiter_resolve(nil, result) -- 3444
		end -- 3444
		if action.tool == "spawn_sub_agent" then -- 3444
			if not shared.spawnSubAgent then -- 3444
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3444
			end -- 3444
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3444
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3444
			end -- 3444
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3457
				params.filesHint, -- 3458
				function(____, item) return type(item) == "string" end -- 3458
			) or nil -- 3458
			local result = __TS__Await(shared.spawnSubAgent({ -- 3460
				parentSessionId = shared.sessionId, -- 3461
				projectRoot = shared.workingDir, -- 3462
				title = type(params.title) == "string" and params.title or "Sub", -- 3463
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3464
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3465
				filesHint = filesHint -- 3466
			})) -- 3466
			if not result.success then -- 3466
				return ____awaiter_resolve(nil, result) -- 3466
			end -- 3466
			return ____awaiter_resolve(nil, { -- 3466
				success = true, -- 3472
				sessionId = result.sessionId, -- 3473
				taskId = result.taskId, -- 3474
				title = result.title, -- 3475
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3476
			}) -- 3476
		end -- 3476
		if action.tool == "list_sub_agents" then -- 3476
			if not shared.listSubAgents then -- 3476
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3476
			end -- 3476
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3476
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3476
			end -- 3476
			local result = __TS__Await(shared.listSubAgents({ -- 3486
				sessionId = shared.sessionId, -- 3487
				projectRoot = shared.workingDir, -- 3488
				status = type(params.status) == "string" and params.status or nil, -- 3489
				limit = type(params.limit) == "number" and params.limit or nil, -- 3490
				offset = type(params.offset) == "number" and params.offset or nil, -- 3491
				query = type(params.query) == "string" and params.query or nil -- 3492
			})) -- 3492
			return ____awaiter_resolve(nil, result) -- 3492
		end -- 3492
		if action.tool == "edit_file" then -- 3492
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3497
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3500
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3501
			if __TS__StringTrim(path) == "" then -- 3501
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3501
			end -- 3501
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3503
			return ____awaiter_resolve( -- 3503
				nil, -- 3503
				actionNode:exec({ -- 3504
					path = path, -- 3505
					oldStr = oldStr, -- 3506
					newStr = newStr, -- 3507
					taskId = shared.taskId, -- 3508
					workDir = shared.workingDir -- 3509
				}) -- 3509
			) -- 3509
		end -- 3509
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3509
	end) -- 3509
end -- 3509
function sanitizeToolActionResultForHistory(action, result) -- 3515
	if action.tool == "read_file" then -- 3515
		return sanitizeReadResultForHistory(action.tool, result) -- 3517
	end -- 3517
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3517
		return sanitizeSearchResultForHistory(action.tool, result) -- 3520
	end -- 3520
	if action.tool == "glob_files" then -- 3520
		return sanitizeListFilesResultForHistory(result) -- 3523
	end -- 3523
	if action.tool == "build" then -- 3523
		return sanitizeBuildResultForHistory(result) -- 3526
	end -- 3526
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3526
		if result.success ~= true then -- 3526
			return result -- 3529
		end -- 3529
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3529
			return result -- 3530
		end -- 3530
		if isArray(result.fileContext) then -- 3530
			return result -- 3531
		end -- 3531
		local contextLimits = { -- 3533
			fullContentChars = 12000, -- 3534
			previewChars = 4000, -- 3535
			diffChars = 8000, -- 3536
			totalChars = 24000, -- 3537
			maxFiles = 8 -- 3538
		} -- 3538
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3540
			if maxChars <= 0 then -- 3540
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3541
			end -- 3541
			if #sourceText <= maxChars then -- 3541
				return sourceText -- 3542
			end -- 3542
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3543
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3544
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3545
		end -- 3540
		local function countLines(sourceText) -- 3547
			if sourceText == "" then -- 3547
				return 0 -- 3548
			end -- 3548
			return #__TS__StringSplit(sourceText, "\n") -- 3549
		end -- 3547
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3551
			if beforeContent == afterContent then -- 3551
				return "" -- 3552
			end -- 3552
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3553
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3554
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3556
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3556
				firstChangedLine = firstChangedLine + 1 -- 3562
			end -- 3562
			local lastChangedBeforeLine = #beforeLines - 1 -- 3564
			local lastChangedAfterLine = #afterLines - 1 -- 3565
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3565
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3571
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3572
			end -- 3572
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3574
			local previewEndLine = math.max( -- 3575
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3576
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3577
			) -- 3577
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3579
			do -- 3579
				local lineIndex = previewStartLine -- 3580
				while lineIndex <= previewEndLine do -- 3580
					do -- 3580
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3581
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3582
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3583
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3584
						if not beforeChanged and not afterChanged then -- 3584
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3586
							if contextLine ~= nil then -- 3586
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3587
							end -- 3587
							goto __continue599 -- 3588
						end -- 3588
						if beforeChanged and beforeLine ~= nil then -- 3588
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3590
						end -- 3590
						if afterChanged and afterLine ~= nil then -- 3590
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3591
						end -- 3591
					end -- 3591
					::__continue599:: -- 3591
					lineIndex = lineIndex + 1 -- 3580
				end -- 3580
			end -- 3580
			return truncateContextSnippet( -- 3593
				table.concat(unifiedDiffLines, "\n"), -- 3593
				maxChars, -- 3593
				"diff" -- 3593
			) -- 3593
		end -- 3551
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3596
		if not checkpointDiff.success then -- 3596
			return result -- 3597
		end -- 3597
		local remainingContextBudget = contextLimits.totalChars -- 3598
		local fileContextItems = {} -- 3599
		local changedFiles = checkpointDiff.files -- 3600
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3601
		do -- 3601
			local fileIndex = 0 -- 3602
			while fileIndex < maxContextFiles do -- 3602
				if remainingContextBudget <= 0 then -- 3602
					break -- 3603
				end -- 3603
				local changedFile = changedFiles[fileIndex + 1] -- 3604
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3605
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3606
				local contextItem = { -- 3607
					path = changedFile.path, -- 3608
					op = changedFile.op, -- 3609
					checkpointId = result.checkpointId, -- 3610
					checkpointSeq = result.checkpointSeq, -- 3611
					beforeExists = changedFile.beforeExists, -- 3612
					afterExists = changedFile.afterExists, -- 3613
					beforeBytes = #beforeContent, -- 3614
					afterBytes = #afterContent, -- 3615
					diffPreview = "", -- 3616
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3617
					contentTruncated = false, -- 3618
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3619
				} -- 3619
				if changedFile.afterExists then -- 3619
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3619
						contextItem.afterContent = afterContent -- 3623
						remainingContextBudget = remainingContextBudget - #afterContent -- 3624
					else -- 3624
						contextItem.afterContentPreview = truncateContextSnippet( -- 3626
							afterContent, -- 3627
							math.min( -- 3628
								contextLimits.previewChars, -- 3628
								math.max(400, remainingContextBudget) -- 3628
							), -- 3628
							"afterContent" -- 3629
						) -- 3629
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3631
						contextItem.contentTruncated = true -- 3632
					end -- 3632
				end -- 3632
				local diffPreview = buildUnifiedDiffPreview( -- 3635
					changedFile.path, -- 3636
					beforeContent, -- 3637
					afterContent, -- 3638
					math.min( -- 3639
						contextLimits.diffChars, -- 3639
						math.max(400, remainingContextBudget) -- 3639
					) -- 3639
				) -- 3639
				contextItem.diffPreview = diffPreview -- 3641
				remainingContextBudget = remainingContextBudget - #diffPreview -- 3642
				if not changedFile.afterExists and beforeContent ~= "" then -- 3642
					contextItem.beforeContentPreview = truncateContextSnippet( -- 3644
						beforeContent, -- 3645
						math.min( -- 3646
							contextLimits.previewChars, -- 3646
							math.max(400, remainingContextBudget) -- 3646
						), -- 3646
						"beforeContent" -- 3647
					) -- 3647
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 3649
					if #beforeContent > contextLimits.previewChars then -- 3649
						contextItem.contentTruncated = true -- 3650
					end -- 3650
				end -- 3650
				fileContextItems[#fileContextItems + 1] = contextItem -- 3652
				fileIndex = fileIndex + 1 -- 3602
			end -- 3602
		end -- 3602
		if #fileContextItems == 0 then -- 3602
			return result -- 3654
		end -- 3654
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 3655
	end -- 3655
	return result -- 3662
end -- 3662
function emitAgentTaskFinishEvent(shared, success, message) -- 3825
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3826
	emitAgentEvent(shared, { -- 3832
		type = "task_finished", -- 3833
		sessionId = shared.sessionId, -- 3834
		taskId = shared.taskId, -- 3835
		success = result.success, -- 3836
		message = result.message, -- 3837
		steps = result.steps -- 3838
	}) -- 3838
	return result -- 3840
end -- 3840
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 103
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 220
HISTORY_READ_FILE_MAX_LINES = 300 -- 221
READ_FILE_DEFAULT_LIMIT = 300 -- 222
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 223
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 224
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 225
HISTORY_BUILD_MAX_MESSAGES = 50 -- 226
HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 227
SEARCH_DORA_API_LIMIT_MAX = 20 -- 228
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 229
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 230
SEARCH_PREVIEW_CONTEXT = 80 -- 231
local AGENT_DEFAULT_MAX_STEPS = 100 -- 232
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 233
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 234
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 235
local function buildLLMOptions(llmConfig, overrides) -- 237
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 238
	if llmConfig.reasoningEffort then -- 238
		options.reasoning_effort = llmConfig.reasoningEffort -- 243
	end -- 243
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 245
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 245
		__TS__Delete(merged, "reasoning_effort") -- 250
	else -- 250
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 252
	end -- 252
	return merged -- 254
end -- 237
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 341
	local messagesTokens = 0 -- 348
	do -- 348
		local i = 0 -- 349
		while i < #messages do -- 349
			local message = messages[i + 1] -- 350
			messagesTokens = messagesTokens + 8 -- 351
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 352
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 353
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 354
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 355
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 356
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 357
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 358
			i = i + 1 -- 349
		end -- 349
	end -- 349
	local toolDefinitionsTokens = 0 -- 361
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 361
		local toolsText = safeJsonEncode(options.tools) -- 363
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 364
	end -- 364
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 367
	__TS__Delete(optionsWithoutTools, "tools") -- 368
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 369
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 370
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 371
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 372
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 377
		1024, -- 379
		math.floor(contextWindow * 0.2) -- 379
	) -- 379
	local structuralOverhead = math.max(256, #messages * 16) -- 380
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 382
	local maxTokens = contextWindow -- 383
	emitAgentEvent( -- 384
		shared, -- 384
		{ -- 384
			type = "metrics_updated", -- 385
			sessionId = shared.sessionId, -- 386
			taskId = shared.taskId, -- 387
			step = step, -- 388
			metrics = {context = { -- 389
				usedTokens = usedTokens, -- 391
				maxTokens = maxTokens, -- 392
				ratio = math.max( -- 393
					0, -- 393
					math.min(1, usedTokens / maxTokens) -- 393
				), -- 393
				messagesTokens = messagesTokens, -- 394
				optionsTokens = optionsTokens, -- 395
				toolDefinitionsTokens = toolDefinitionsTokens, -- 396
				reservedOutputTokens = reservedOutputTokens, -- 397
				structuralOverhead = structuralOverhead, -- 398
				contextWindow = contextWindow, -- 399
				source = "llm_input_estimate", -- 400
				updatedAt = os.time(), -- 401
				phase = phase, -- 402
				step = step -- 403
			}} -- 403
		} -- 403
	) -- 403
end -- 341
local function emitAgentStartEvent(shared, action) -- 409
	emitAgentEvent(shared, { -- 410
		type = "tool_started", -- 411
		sessionId = shared.sessionId, -- 412
		taskId = shared.taskId, -- 413
		step = action.step, -- 414
		tool = action.tool -- 415
	}) -- 415
end -- 409
local function emitAgentFinishEvent(shared, action) -- 419
	emitAgentEvent(shared, { -- 420
		type = "tool_finished", -- 421
		sessionId = shared.sessionId, -- 422
		taskId = shared.taskId, -- 423
		step = action.step, -- 424
		tool = action.tool, -- 425
		result = action.result or ({}) -- 426
	}) -- 426
end -- 419
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 430
	emitAgentEvent(shared, { -- 431
		type = "assistant_message_updated", -- 432
		sessionId = shared.sessionId, -- 433
		taskId = shared.taskId, -- 434
		step = shared.step + 1, -- 435
		content = content, -- 436
		reasoningContent = reasoningContent -- 437
	}) -- 437
end -- 430
local function getMemoryCompressionStartReason(shared) -- 441
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 442
end -- 441
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 447
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 448
end -- 447
local function getMemoryCompressionFailureReason(shared, ____error) -- 453
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 454
end -- 453
local function summarizeHistoryEntryPreview(text, maxChars) -- 459
	if maxChars == nil then -- 459
		maxChars = 180 -- 459
	end -- 459
	local trimmed = __TS__StringTrim(text) -- 460
	if trimmed == "" then -- 460
		return "" -- 461
	end -- 461
	return truncateText(trimmed, maxChars) -- 462
end -- 459
local function getMaxStepsReachedReason(shared) -- 470
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 471
end -- 470
local function getFailureSummaryFallback(shared, ____error) -- 476
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 477
end -- 476
local function finalizeAgentFailure(shared, ____error) -- 482
	if shared.stopToken.stopped then -- 482
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 484
		return emitAgentTaskFinishEvent( -- 485
			shared, -- 485
			false, -- 485
			getCancelledReason(shared) -- 485
		) -- 485
	end -- 485
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 487
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 488
end -- 482
local function getPromptCommand(prompt) -- 491
	local trimmed = __TS__StringTrim(prompt) -- 492
	if trimmed == "/compact" then -- 492
		return "compact" -- 493
	end -- 493
	if trimmed == "/clear" then -- 493
		return "clear" -- 494
	end -- 494
	return nil -- 495
end -- 491
function ____exports.truncateAgentUserPrompt(prompt) -- 498
	if not prompt then -- 498
		return "" -- 499
	end -- 499
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 499
		return prompt -- 500
	end -- 500
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 501
	if offset == nil then -- 501
		return prompt -- 502
	end -- 502
	return string.sub(prompt, 1, offset - 1) -- 503
end -- 498
local function canWriteStepLLMDebug(shared, stepId) -- 506
	if stepId == nil then -- 506
		stepId = shared.step + 1 -- 506
	end -- 506
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 507
end -- 506
local function ensureDirRecursive(dir) -- 514
	if not dir then -- 514
		return false -- 515
	end -- 515
	if Content:exist(dir) then -- 515
		return Content:isdir(dir) -- 516
	end -- 516
	local parent = Path:getPath(dir) -- 517
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 517
		return false -- 519
	end -- 519
	return Content:mkdir(dir) -- 521
end -- 514
local function encodeDebugJSON(value) -- 524
	local text, err = safeJsonEncode(value) -- 525
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 526
end -- 524
local function getStepLLMDebugDir(shared) -- 529
	return Path( -- 530
		shared.workingDir, -- 531
		".agent", -- 532
		tostring(shared.sessionId), -- 533
		tostring(shared.taskId) -- 534
	) -- 534
end -- 529
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 538
	return Path( -- 539
		getStepLLMDebugDir(shared), -- 539
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 539
	) -- 539
end -- 538
local function getLatestStepLLMDebugSeq(shared, stepId) -- 542
	if not canWriteStepLLMDebug(shared, stepId) then -- 542
		return 0 -- 543
	end -- 543
	local dir = getStepLLMDebugDir(shared) -- 544
	if not Content:exist(dir) or not Content:isdir(dir) then -- 544
		return 0 -- 545
	end -- 545
	local latest = 0 -- 546
	for ____, file in ipairs(Content:getFiles(dir)) do -- 547
		do -- 547
			local name = Path:getFilename(file) -- 548
			local seqText = string.match( -- 549
				name, -- 549
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 549
			) -- 549
			if seqText ~= nil then -- 549
				latest = math.max( -- 551
					latest, -- 551
					tonumber(seqText) -- 551
				) -- 551
				goto __continue48 -- 552
			end -- 552
			local legacyMatch = string.match( -- 554
				name, -- 554
				("^" .. tostring(stepId)) .. "_in%.md$" -- 554
			) -- 554
			if legacyMatch ~= nil then -- 554
				latest = math.max(latest, 1) -- 556
			end -- 556
		end -- 556
		::__continue48:: -- 556
	end -- 556
	return latest -- 559
end -- 542
local function writeStepLLMDebugFile(path, content) -- 562
	if not Content:save(path, content) then -- 562
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 564
		return false -- 565
	end -- 565
	return true -- 567
end -- 562
local function createStepLLMDebugPair(shared, stepId, inContent) -- 570
	if not canWriteStepLLMDebug(shared, stepId) then -- 570
		return 0 -- 571
	end -- 571
	local dir = getStepLLMDebugDir(shared) -- 572
	if not ensureDirRecursive(dir) then -- 572
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 574
		return 0 -- 575
	end -- 575
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 577
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 578
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 579
	if not writeStepLLMDebugFile(inPath, inContent) then -- 579
		return 0 -- 581
	end -- 581
	writeStepLLMDebugFile(outPath, "") -- 583
	return seq -- 584
end -- 570
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 587
	if not canWriteStepLLMDebug(shared, stepId) then -- 587
		return -- 588
	end -- 588
	local dir = getStepLLMDebugDir(shared) -- 589
	if not ensureDirRecursive(dir) then -- 589
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 591
		return -- 592
	end -- 592
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 594
	if latestSeq <= 0 then -- 594
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 596
		writeStepLLMDebugFile(outPath, content) -- 597
		return -- 598
	end -- 598
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 600
	writeStepLLMDebugFile(outPath, content) -- 601
end -- 587
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 604
	if not canWriteStepLLMDebug(shared, stepId) then -- 604
		return -- 605
	end -- 605
	local sections = { -- 606
		"# LLM Input", -- 607
		"session_id: " .. tostring(shared.sessionId), -- 608
		"task_id: " .. tostring(shared.taskId), -- 609
		"step_id: " .. tostring(stepId), -- 610
		"phase: " .. phase, -- 611
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 612
		"## Options", -- 613
		"```json", -- 614
		encodeDebugJSON(options), -- 615
		"```" -- 616
	} -- 616
	local firstMessage = #messages > 0 and messages[1] or nil -- 618
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 618
		sections[#sections + 1] = "# System Prompt" -- 620
		sections[#sections + 1] = firstMessage.content -- 621
	end -- 621
	do -- 621
		local i = 0 -- 623
		while i < #messages do -- 623
			local message = messages[i + 1] -- 624
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 625
			sections[#sections + 1] = encodeDebugJSON(message) -- 626
			i = i + 1 -- 623
		end -- 623
	end -- 623
	createStepLLMDebugPair( -- 628
		shared, -- 628
		stepId, -- 628
		table.concat(sections, "\n") -- 628
	) -- 628
end -- 604
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 631
	if not canWriteStepLLMDebug(shared, stepId) then -- 631
		return -- 632
	end -- 632
	local ____array_0 = __TS__SparseArrayNew( -- 632
		"# LLM Output", -- 634
		"session_id: " .. tostring(shared.sessionId), -- 635
		"task_id: " .. tostring(shared.taskId), -- 636
		"step_id: " .. tostring(stepId), -- 637
		"phase: " .. phase, -- 638
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 639
		table.unpack(meta and ({ -- 640
			"## Meta", -- 640
			"```json", -- 640
			encodeDebugJSON(meta), -- 640
			"```" -- 640
		}) or ({})) -- 640
	) -- 640
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 640
	local sections = {__TS__SparseArraySpread(____array_0)} -- 633
	updateLatestStepLLMDebugOutput( -- 644
		shared, -- 644
		stepId, -- 644
		table.concat(sections, "\n") -- 644
	) -- 644
end -- 631
local function toJson(value, emptyAsArray) -- 647
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 648
	if text ~= nil then -- 648
		return text -- 649
	end -- 649
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 650
end -- 647
local function summarizeEditTextParamForHistory(value, key) -- 700
	if type(value) ~= "string" then -- 700
		return nil -- 701
	end -- 701
	local text = value -- 702
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 703
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 704
end -- 700
local function sanitizeActionParamsForHistory(tool, params) -- 814
	if tool ~= "edit_file" then -- 814
		return params -- 815
	end -- 815
	local clone = {} -- 816
	for key in pairs(params) do -- 817
		if key == "old_str" then -- 817
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 819
		elseif key == "new_str" then -- 819
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 821
		else -- 821
			clone[key] = params[key] -- 823
		end -- 823
	end -- 823
	return clone -- 826
end -- 814
local function getDecisionToolSchemaText(shared) -- 866
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX)) -- 867
	return toolsText or "" -- 868
end -- 866
local function isToolAllowedForRole(role, tool) -- 871
	return __TS__ArrayIndexOf( -- 872
		AgentToolRegistry.getAllowedToolsForRole(role), -- 872
		tool -- 872
	) >= 0 -- 872
end -- 871
local function clearPreExecutedResults(shared) -- 875
	shared.preExecutedResults = nil -- 876
end -- 875
local function startPreExecutedToolAction(shared, action) -- 879
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 879
		local ____hasReturned, ____returnValue -- 879
		local ____try = __TS__AsyncAwaiter(function() -- 879
			____hasReturned = true -- 881
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 881
			return -- 881
		end) -- 881
		____try = ____try.catch( -- 881
			____try, -- 881
			function(____, err) -- 881
				return __TS__AsyncAwaiter(function() -- 881
					local message = tostring(err) -- 883
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 884
					____hasReturned = true -- 885
					____returnValue = {success = false, message = message} -- 885
					return -- 885
				end) -- 885
			end -- 885
		) -- 885
		__TS__Await(____try) -- 880
		if ____hasReturned then -- 880
			return ____awaiter_resolve(nil, ____returnValue) -- 880
		end -- 880
	end) -- 880
end -- 879
local function createPreExecutedToolResult(shared, action) -- 889
	local cloneParamValue -- 890
	cloneParamValue = function(value) -- 890
		if value == nil then -- 890
			return value -- 891
		end -- 891
		if isArray(value) then -- 891
			return __TS__ArrayMap( -- 893
				value, -- 893
				function(____, item) return cloneParamValue(item) end -- 893
			) -- 893
		end -- 893
		if type(value) == "table" then -- 893
			local clone = {} -- 896
			for key in pairs(value) do -- 897
				clone[key] = cloneParamValue(value[key]) -- 898
			end -- 898
			return clone -- 900
		end -- 900
		return value -- 902
	end -- 890
	local params = cloneParamValue(action.params) -- 904
	local areParamValuesEqual -- 905
	areParamValuesEqual = function(left, right) -- 905
		if left == right then -- 905
			return true -- 906
		end -- 906
		if left == nil or right == nil then -- 906
			return false -- 907
		end -- 907
		if isArray(left) or isArray(right) then -- 907
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 907
				return false -- 909
			end -- 909
			do -- 909
				local i = 0 -- 910
				while i < #left do -- 910
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 910
						return false -- 911
					end -- 911
					i = i + 1 -- 910
				end -- 910
			end -- 910
			return true -- 913
		end -- 913
		if type(left) == "table" and type(right) == "table" then -- 913
			local leftCount = 0 -- 916
			for key in pairs(left) do -- 917
				leftCount = leftCount + 1 -- 918
				if not areParamValuesEqual(left[key], right[key]) then -- 918
					return false -- 923
				end -- 923
			end -- 923
			local rightCount = 0 -- 926
			for key in pairs(right) do -- 927
				rightCount = rightCount + 1 -- 928
			end -- 928
			return leftCount == rightCount -- 930
		end -- 930
		return false -- 932
	end -- 905
	return { -- 934
		action = action, -- 935
		matches = function(self, nextAction) -- 936
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 937
		end, -- 936
		promise = startPreExecutedToolAction(shared, action) -- 939
	} -- 939
end -- 889
local function executeToolActionWithPreExecution(shared, action) -- 943
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 943
		local ____opt_3 = shared.preExecutedResults -- 943
		local preResult = ____opt_3 and ____opt_3:get(action.toolCallId) -- 944
		if preResult then -- 944
			local ____opt_5 = shared.preExecutedResults -- 944
			if ____opt_5 ~= nil then -- 944
				____opt_5:delete(action.toolCallId) -- 946
			end -- 946
			if preResult:matches(action) then -- 946
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 948
				return ____awaiter_resolve( -- 948
					nil, -- 948
					__TS__Await(preResult.promise) -- 949
				) -- 949
			end -- 949
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 951
		end -- 951
		return ____awaiter_resolve( -- 951
			nil, -- 951
			executeToolAction(shared, action) -- 953
		) -- 953
	end) -- 953
end -- 943
local function maybeCompressHistory(shared) -- 956
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 956
		local ____shared_7 = shared -- 957
		local memory = ____shared_7.memory -- 957
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 958
		local changed = false -- 959
		do -- 959
			local round = 0 -- 960
			while round < maxRounds do -- 960
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 961
				local activeMessages = getActiveConversationMessages(shared) -- 962
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 965
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 965
					if changed then -- 965
						persistHistoryState(shared) -- 974
					end -- 974
					return ____awaiter_resolve(nil) -- 974
				end -- 974
				local compressionRound = round + 1 -- 978
				shared.step = shared.step + 1 -- 979
				local stepId = shared.step -- 980
				local pendingMessages = #activeMessages -- 981
				emitAgentEvent( -- 982
					shared, -- 982
					{ -- 982
						type = "memory_compression_started", -- 983
						sessionId = shared.sessionId, -- 984
						taskId = shared.taskId, -- 985
						step = stepId, -- 986
						tool = "compress_memory", -- 987
						reason = getMemoryCompressionStartReason(shared), -- 988
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 989
					} -- 989
				) -- 989
				local result = __TS__Await(memory.compressor:compress( -- 995
					activeMessages, -- 996
					shared.llmOptions, -- 997
					shared.llmMaxTry, -- 998
					shared.decisionMode, -- 999
					{ -- 1000
						onInput = function(____, phase, messages, options) -- 1001
							saveStepLLMDebugInput( -- 1002
								shared, -- 1002
								stepId, -- 1002
								phase, -- 1002
								messages, -- 1002
								options -- 1002
							) -- 1002
						end, -- 1001
						onOutput = function(____, phase, text, meta) -- 1004
							saveStepLLMDebugOutput( -- 1005
								shared, -- 1005
								stepId, -- 1005
								phase, -- 1005
								text, -- 1005
								meta -- 1005
							) -- 1005
						end -- 1004
					}, -- 1004
					"default", -- 1008
					systemPrompt, -- 1009
					toolDefinitions -- 1010
				)) -- 1010
				if not (result and result.success and result.compressedCount > 0) then -- 1010
					emitAgentEvent( -- 1013
						shared, -- 1013
						{ -- 1013
							type = "memory_compression_finished", -- 1014
							sessionId = shared.sessionId, -- 1015
							taskId = shared.taskId, -- 1016
							step = stepId, -- 1017
							tool = "compress_memory", -- 1018
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1019
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1023
						} -- 1023
					) -- 1023
					if changed then -- 1023
						persistHistoryState(shared) -- 1031
					end -- 1031
					return ____awaiter_resolve(nil) -- 1031
				end -- 1031
				local effectiveCompressedCount = math.max( -- 1035
					0, -- 1036
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1037
				) -- 1037
				if effectiveCompressedCount <= 0 then -- 1037
					if changed then -- 1037
						persistHistoryState(shared) -- 1041
					end -- 1041
					return ____awaiter_resolve(nil) -- 1041
				end -- 1041
				emitAgentEvent( -- 1045
					shared, -- 1045
					{ -- 1045
						type = "memory_compression_finished", -- 1046
						sessionId = shared.sessionId, -- 1047
						taskId = shared.taskId, -- 1048
						step = stepId, -- 1049
						tool = "compress_memory", -- 1050
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1051
						result = { -- 1052
							success = true, -- 1053
							round = compressionRound, -- 1054
							compressedCount = effectiveCompressedCount, -- 1055
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1056
						} -- 1056
					} -- 1056
				) -- 1056
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1059
				changed = true -- 1060
				Log( -- 1061
					"Info", -- 1061
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1061
				) -- 1061
				round = round + 1 -- 960
			end -- 960
		end -- 960
		if changed then -- 960
			persistHistoryState(shared) -- 1064
		end -- 1064
	end) -- 1064
end -- 956
local function compactAllHistory(shared) -- 1068
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1068
		local ____shared_14 = shared -- 1069
		local memory = ____shared_14.memory -- 1069
		local rounds = 0 -- 1070
		local totalCompressed = 0 -- 1071
		while getActiveRealMessageCount(shared) > 0 do -- 1071
			if shared.stopToken.stopped then -- 1071
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1074
				return ____awaiter_resolve( -- 1074
					nil, -- 1074
					emitAgentTaskFinishEvent( -- 1075
						shared, -- 1075
						false, -- 1075
						getCancelledReason(shared) -- 1075
					) -- 1075
				) -- 1075
			end -- 1075
			rounds = rounds + 1 -- 1077
			shared.step = shared.step + 1 -- 1078
			local stepId = shared.step -- 1079
			local activeMessages = getActiveConversationMessages(shared) -- 1080
			local pendingMessages = #activeMessages -- 1081
			emitAgentEvent( -- 1082
				shared, -- 1082
				{ -- 1082
					type = "memory_compression_started", -- 1083
					sessionId = shared.sessionId, -- 1084
					taskId = shared.taskId, -- 1085
					step = stepId, -- 1086
					tool = "compress_memory", -- 1087
					reason = getMemoryCompressionStartReason(shared), -- 1088
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1089
				} -- 1089
			) -- 1089
			local result = __TS__Await(memory.compressor:compress( -- 1096
				activeMessages, -- 1097
				shared.llmOptions, -- 1098
				shared.llmMaxTry, -- 1099
				shared.decisionMode, -- 1100
				{ -- 1101
					onInput = function(____, phase, messages, options) -- 1102
						saveStepLLMDebugInput( -- 1103
							shared, -- 1103
							stepId, -- 1103
							phase, -- 1103
							messages, -- 1103
							options -- 1103
						) -- 1103
					end, -- 1102
					onOutput = function(____, phase, text, meta) -- 1105
						saveStepLLMDebugOutput( -- 1106
							shared, -- 1106
							stepId, -- 1106
							phase, -- 1106
							text, -- 1106
							meta -- 1106
						) -- 1106
					end -- 1105
				}, -- 1105
				"budget_max" -- 1109
			)) -- 1109
			if not (result and result.success and result.compressedCount > 0) then -- 1109
				emitAgentEvent( -- 1112
					shared, -- 1112
					{ -- 1112
						type = "memory_compression_finished", -- 1113
						sessionId = shared.sessionId, -- 1114
						taskId = shared.taskId, -- 1115
						step = stepId, -- 1116
						tool = "compress_memory", -- 1117
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1118
						result = { -- 1122
							success = false, -- 1123
							rounds = rounds, -- 1124
							error = result and result.error or "compression returned no changes", -- 1125
							compressedCount = result and result.compressedCount or 0, -- 1126
							fullCompaction = true -- 1127
						} -- 1127
					} -- 1127
				) -- 1127
				return ____awaiter_resolve( -- 1127
					nil, -- 1127
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1130
				) -- 1130
			end -- 1130
			local effectiveCompressedCount = math.max( -- 1135
				0, -- 1136
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1137
			) -- 1137
			if effectiveCompressedCount <= 0 then -- 1137
				return ____awaiter_resolve( -- 1137
					nil, -- 1137
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1140
				) -- 1140
			end -- 1140
			emitAgentEvent( -- 1147
				shared, -- 1147
				{ -- 1147
					type = "memory_compression_finished", -- 1148
					sessionId = shared.sessionId, -- 1149
					taskId = shared.taskId, -- 1150
					step = stepId, -- 1151
					tool = "compress_memory", -- 1152
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1153
					result = { -- 1154
						success = true, -- 1155
						round = rounds, -- 1156
						compressedCount = effectiveCompressedCount, -- 1157
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1158
						fullCompaction = true -- 1159
					} -- 1159
				} -- 1159
			) -- 1159
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1162
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1163
			persistHistoryState(shared) -- 1164
			Log( -- 1165
				"Info", -- 1165
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1165
			) -- 1165
		end -- 1165
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1167
		return ____awaiter_resolve( -- 1167
			nil, -- 1167
			emitAgentTaskFinishEvent( -- 1168
				shared, -- 1169
				true, -- 1170
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1171
			) -- 1171
		) -- 1171
	end) -- 1171
end -- 1068
local function clearSessionHistory(shared) -- 1177
	shared.messages = {} -- 1178
	shared.lastConsolidatedIndex = 0 -- 1179
	shared.carryMessageIndex = nil -- 1180
	persistHistoryState(shared) -- 1181
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1182
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1183
end -- 1177
local function appendConversationMessage(shared, message) -- 1273
	local ____shared_messages_23 = shared.messages -- 1273
	____shared_messages_23[#____shared_messages_23 + 1] = __TS__ObjectAssign( -- 1274
		{}, -- 1274
		message, -- 1275
		{ -- 1274
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1276
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1277
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1278
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1279
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1280
		} -- 1280
	) -- 1280
end -- 1273
local function appendToolResultMessage(shared, action) -- 1289
	appendConversationMessage( -- 1290
		shared, -- 1290
		{ -- 1290
			role = "tool", -- 1291
			tool_call_id = action.toolCallId, -- 1292
			name = action.tool, -- 1293
			content = action.result and toJson(action.result, false) or "" -- 1294
		} -- 1294
	) -- 1294
end -- 1289
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1298
	appendConversationMessage( -- 1304
		shared, -- 1304
		{ -- 1304
			role = "assistant", -- 1305
			content = content or "", -- 1306
			reasoning_content = reasoningContent, -- 1307
			tool_calls = __TS__ArrayMap( -- 1308
				actions, -- 1308
				function(____, action) return { -- 1308
					id = action.toolCallId, -- 1309
					type = "function", -- 1310
					["function"] = { -- 1311
						name = action.tool, -- 1312
						arguments = toJson(action.params, false) -- 1313
					} -- 1313
				} end -- 1313
			) -- 1313
		} -- 1313
	) -- 1313
end -- 1298
local function llm(shared, messages, phase) -- 1497
	if phase == nil then -- 1497
		phase = "decision_xml" -- 1500
	end -- 1500
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1500
		local stepId = shared.step + 1 -- 1502
		emitLLMContextMetrics( -- 1503
			shared, -- 1503
			stepId, -- 1503
			phase, -- 1503
			messages, -- 1503
			shared.llmOptions -- 1503
		) -- 1503
		saveStepLLMDebugInput( -- 1504
			shared, -- 1504
			stepId, -- 1504
			phase, -- 1504
			messages, -- 1504
			shared.llmOptions -- 1504
		) -- 1504
		local lastStreamReasoning = "" -- 1505
		local res = __TS__Await(callLLMStreamAggregated( -- 1506
			messages, -- 1507
			shared.llmOptions, -- 1508
			shared.stopToken, -- 1509
			shared.llmConfig, -- 1510
			function(response) -- 1511
				local ____opt_27 = response.choices -- 1511
				local ____opt_25 = ____opt_27 and ____opt_27[1] -- 1511
				local streamMessage = ____opt_25 and ____opt_25.message -- 1512
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1513
				if nextContent == "" then -- 1513
					return -- 1516
				end -- 1516
				if nextContent == lastStreamReasoning then -- 1516
					return -- 1517
				end -- 1517
				lastStreamReasoning = nextContent -- 1518
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1519
			end -- 1511
		)) -- 1511
		if res.success then -- 1511
			local ____opt_33 = res.response.choices -- 1511
			local ____opt_31 = ____opt_33 and ____opt_33[1] -- 1511
			local message = ____opt_31 and ____opt_31.message -- 1523
			local text = message and message.content -- 1524
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1525
			if text then -- 1525
				local parsed = tryParseAndValidateDecision(text) -- 1529
				if parsed.success then -- 1529
					local reason = parsed.reason or "" -- 1531
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1532
				end -- 1532
				saveStepLLMDebugOutput( -- 1534
					shared, -- 1534
					stepId, -- 1534
					phase, -- 1534
					text, -- 1534
					{success = true} -- 1534
				) -- 1534
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1534
			else -- 1534
				saveStepLLMDebugOutput( -- 1537
					shared, -- 1537
					stepId, -- 1537
					phase, -- 1537
					"empty LLM response", -- 1537
					{success = false} -- 1537
				) -- 1537
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1537
			end -- 1537
		else -- 1537
			saveStepLLMDebugOutput( -- 1541
				shared, -- 1541
				stepId, -- 1541
				phase, -- 1541
				res.raw or res.message, -- 1541
				{success = false} -- 1541
			) -- 1541
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1541
		end -- 1541
	end) -- 1541
end -- 1497
local function isDecisionBatchSuccess(result) -- 1565
	return result.kind == "batch" -- 1566
end -- 1565
local function parseDecisionToolCall(functionName, rawObj) -- 1590
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 1590
		return {success = false, message = "unknown tool: " .. functionName} -- 1592
	end -- 1592
	if rawObj == nil then -- 1592
		return {success = true, tool = functionName, params = {}} -- 1595
	end -- 1595
	if not isRecord(rawObj) then -- 1595
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1598
	end -- 1598
	return {success = true, tool = functionName, params = rawObj} -- 1600
end -- 1590
local function parseToolCallArguments(functionName, argsText) -- 1607
	local trimmedArgs = __TS__StringTrim(argsText) -- 1608
	if trimmedArgs == "" then -- 1608
		return {} -- 1610
	end -- 1610
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1612
	if err ~= nil or rawObj == nil then -- 1612
		return { -- 1614
			success = false, -- 1615
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1616
			raw = argsText -- 1617
		} -- 1617
	end -- 1617
	local encodedRaw = safeJsonEncode(rawObj) -- 1620
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1620
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1622
	end -- 1622
	return rawObj -- 1628
end -- 1607
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1631
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1639
	if isRecord(rawArgs) and rawArgs.success == false then -- 1639
		return rawArgs -- 1641
	end -- 1641
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1643
	if not decision.success then -- 1643
		return {success = false, message = decision.message, raw = argsText} -- 1645
	end -- 1645
	local validation = validateDecision(decision.tool, decision.params) -- 1651
	if not validation.success then -- 1651
		return {success = false, message = validation.message, raw = argsText} -- 1653
	end -- 1653
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1653
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1660
	end -- 1660
	decision.params = validation.params -- 1666
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1667
	decision.reason = reason -- 1668
	decision.reasoningContent = reasoningContent -- 1669
	return decision -- 1670
end -- 1631
local function createPreExecutableActionFromStream(shared, toolCall) -- 1673
	local ____opt_39 = toolCall["function"] -- 1673
	local functionName = ____opt_39 and ____opt_39.name -- 1674
	local ____opt_41 = toolCall["function"] -- 1674
	local argsText = ____opt_41 and ____opt_41.arguments or "" -- 1675
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1676
	if not functionName or not toolCallId then -- 1676
		return nil -- 1677
	end -- 1677
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1678
	if isRecord(rawArgs) and rawArgs.success == false then -- 1678
		return nil -- 1679
	end -- 1679
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1680
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 1680
		return nil -- 1681
	end -- 1681
	local validation = validateDecision(decision.tool, decision.params) -- 1682
	if not validation.success then -- 1682
		return nil -- 1683
	end -- 1683
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1683
		return nil -- 1684
	end -- 1684
	return { -- 1685
		step = shared.step + 1, -- 1686
		toolCallId = toolCallId, -- 1687
		tool = decision.tool, -- 1688
		reason = "", -- 1689
		params = validation.params, -- 1690
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1691
	} -- 1691
end -- 1673
local function sanitizeMessagesForLLMInput(messages) -- 1868
	local sanitized = {} -- 1869
	local droppedAssistantToolCalls = 0 -- 1870
	local droppedToolResults = 0 -- 1871
	do -- 1871
		local i = 0 -- 1872
		while i < #messages do -- 1872
			do -- 1872
				local message = messages[i + 1] -- 1873
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1873
					local requiredIds = {} -- 1875
					do -- 1875
						local j = 0 -- 1876
						while j < #message.tool_calls do -- 1876
							local toolCall = message.tool_calls[j + 1] -- 1877
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1878
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1878
								requiredIds[#requiredIds + 1] = id -- 1880
							end -- 1880
							j = j + 1 -- 1876
						end -- 1876
					end -- 1876
					if #requiredIds == 0 then -- 1876
						sanitized[#sanitized + 1] = message -- 1884
						goto __continue328 -- 1885
					end -- 1885
					local matchedIds = {} -- 1887
					local matchedTools = {} -- 1888
					local j = i + 1 -- 1889
					while j < #messages do -- 1889
						local toolMessage = messages[j + 1] -- 1891
						if toolMessage.role ~= "tool" then -- 1891
							break -- 1892
						end -- 1892
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1893
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1893
							matchedIds[toolCallId] = true -- 1895
							matchedTools[#matchedTools + 1] = toolMessage -- 1896
						else -- 1896
							droppedToolResults = droppedToolResults + 1 -- 1898
						end -- 1898
						j = j + 1 -- 1900
					end -- 1900
					local complete = true -- 1902
					do -- 1902
						local j = 0 -- 1903
						while j < #requiredIds do -- 1903
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1903
								complete = false -- 1905
								break -- 1906
							end -- 1906
							j = j + 1 -- 1903
						end -- 1903
					end -- 1903
					if complete then -- 1903
						__TS__ArrayPush( -- 1910
							sanitized, -- 1910
							message, -- 1910
							table.unpack(matchedTools) -- 1910
						) -- 1910
					else -- 1910
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1912
						droppedToolResults = droppedToolResults + #matchedTools -- 1913
					end -- 1913
					i = j - 1 -- 1915
					goto __continue328 -- 1916
				end -- 1916
				if message.role == "tool" then -- 1916
					droppedToolResults = droppedToolResults + 1 -- 1919
					goto __continue328 -- 1920
				end -- 1920
				sanitized[#sanitized + 1] = message -- 1922
			end -- 1922
			::__continue328:: -- 1922
			i = i + 1 -- 1872
		end -- 1872
	end -- 1872
	return sanitized -- 1924
end -- 1868
local function getUnconsolidatedMessages(shared) -- 1927
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1928
end -- 1927
local function getFinalDecisionTurnPrompt(shared) -- 1931
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 1932
end -- 1931
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 1937
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 1937
		return messages -- 1938
	end -- 1938
	local next = __TS__ArrayMap( -- 1939
		messages, -- 1939
		function(____, message) return __TS__ObjectAssign({}, message) end -- 1939
	) -- 1939
	do -- 1939
		local i = #next - 1 -- 1940
		while i >= 0 do -- 1940
			do -- 1940
				local message = next[i + 1] -- 1941
				if message.role ~= "assistant" and message.role ~= "user" then -- 1941
					goto __continue350 -- 1942
				end -- 1942
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 1943
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 1944
				return next -- 1947
			end -- 1947
			::__continue350:: -- 1947
			i = i - 1 -- 1940
		end -- 1940
	end -- 1940
	next[#next + 1] = {role = "user", content = prompt} -- 1949
	return next -- 1950
end -- 1937
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 1953
	if attempt == nil then -- 1953
		attempt = 1 -- 1956
	end -- 1956
	if decisionMode == nil then -- 1956
		decisionMode = shared.decisionMode -- 1958
	end -- 1958
	local messages = { -- 1960
		{ -- 1961
			role = "system", -- 1961
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 1961
		}, -- 1961
		table.unpack(getUnconsolidatedMessages(shared)) -- 1962
	} -- 1962
	if shared.step + 1 >= shared.maxSteps then -- 1962
		messages = appendPromptToLatestDecisionMessage( -- 1965
			messages, -- 1965
			getFinalDecisionTurnPrompt(shared) -- 1965
		) -- 1965
	end -- 1965
	if lastError and lastError ~= "" then -- 1965
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1968
		if decisionMode == "xml" then -- 1968
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 1972
		end -- 1972
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 1972
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 1975
		end -- 1975
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 1975
			retryHeader = retryHeader .. "\nYour previous response spent the token budget on reasoning and ended before any tool call. Do not continue that reasoning. Immediately emit one valid function tool call with compact arguments." -- 1978
		end -- 1978
		messages[#messages + 1] = { -- 1980
			role = "user", -- 1981
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1982
		} -- 1982
	end -- 1982
	return messages -- 1989
end -- 1953
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 1996
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2005
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2006
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2014
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2015
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2016
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2024
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}}) -- 2032
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2037
	local repairPrompt = replacePromptVars( -- 2040
		shared.promptPack.xmlDecisionRepairPrompt, -- 2040
		{ -- 2040
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2041
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2042
			CANDIDATE_SECTION = candidateSection, -- 2043
			LAST_ERROR = lastError, -- 2044
			ATTEMPT = tostring(attempt) -- 2045
		} -- 2045
	) -- 2045
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2047
end -- 1996
local function normalizeLineEndings(text) -- 2077
	local res = string.gsub(text, "\r\n", "\n") -- 2078
	res = string.gsub(res, "\r", "\n") -- 2079
	return res -- 2080
end -- 2077
local function countOccurrences(text, searchStr) -- 2083
	if searchStr == "" then -- 2083
		return 0 -- 2084
	end -- 2084
	local count = 0 -- 2085
	local pos = 0 -- 2086
	while true do -- 2086
		local idx = (string.find( -- 2088
			text, -- 2088
			searchStr, -- 2088
			math.max(pos + 1, 1), -- 2088
			true -- 2088
		) or 0) - 1 -- 2088
		if idx < 0 then -- 2088
			break -- 2089
		end -- 2089
		count = count + 1 -- 2090
		pos = idx + #searchStr -- 2091
	end -- 2091
	return count -- 2093
end -- 2083
local function replaceFirst(text, oldStr, newStr) -- 2096
	if oldStr == "" then -- 2096
		return text -- 2097
	end -- 2097
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2098
	if idx < 0 then -- 2098
		return text -- 2099
	end -- 2099
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2100
end -- 2096
local function splitLines(text) -- 2103
	return __TS__StringSplit(text, "\n") -- 2104
end -- 2103
local function getLeadingWhitespace(text) -- 2107
	local i = 0 -- 2108
	while i < #text do -- 2108
		local ch = __TS__StringAccess(text, i) -- 2110
		if ch ~= " " and ch ~= "\t" then -- 2110
			break -- 2111
		end -- 2111
		i = i + 1 -- 2112
	end -- 2112
	return __TS__StringSubstring(text, 0, i) -- 2114
end -- 2107
local function getCommonIndentPrefix(lines) -- 2117
	local common -- 2118
	do -- 2118
		local i = 0 -- 2119
		while i < #lines do -- 2119
			do -- 2119
				local line = lines[i + 1] -- 2120
				if __TS__StringTrim(line) == "" then -- 2120
					goto __continue378 -- 2121
				end -- 2121
				local indent = getLeadingWhitespace(line) -- 2122
				if common == nil then -- 2122
					common = indent -- 2124
					goto __continue378 -- 2125
				end -- 2125
				local j = 0 -- 2127
				local maxLen = math.min(#common, #indent) -- 2128
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2128
					j = j + 1 -- 2130
				end -- 2130
				common = __TS__StringSubstring(common, 0, j) -- 2132
				if common == "" then -- 2132
					break -- 2133
				end -- 2133
			end -- 2133
			::__continue378:: -- 2133
			i = i + 1 -- 2119
		end -- 2119
	end -- 2119
	return common or "" -- 2135
end -- 2117
local function removeIndentPrefix(line, indent) -- 2138
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2138
		return __TS__StringSubstring(line, #indent) -- 2140
	end -- 2140
	local lineIndent = getLeadingWhitespace(line) -- 2142
	local j = 0 -- 2143
	local maxLen = math.min(#lineIndent, #indent) -- 2144
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2144
		j = j + 1 -- 2146
	end -- 2146
	return __TS__StringSubstring(line, j) -- 2148
end -- 2138
local function dedentLines(lines) -- 2151
	local indent = getCommonIndentPrefix(lines) -- 2152
	return { -- 2153
		indent = indent, -- 2154
		lines = __TS__ArrayMap( -- 2155
			lines, -- 2155
			function(____, line) return removeIndentPrefix(line, indent) end -- 2155
		) -- 2155
	} -- 2155
end -- 2151
local function joinLines(lines) -- 2159
	return table.concat(lines, "\n") -- 2160
end -- 2159
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2163
	local function findWhitespaceTolerantReplacement() -- 2168
		local function foldWhitespace(text, withMap) -- 2170
			local parts = {} -- 2171
			local map = {} -- 2172
			local i = 0 -- 2173
			while i < #text do -- 2173
				local ch = __TS__StringAccess(text, i) -- 2175
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2175
					local start = i -- 2177
					while i < #text do -- 2177
						local next = __TS__StringAccess(text, i) -- 2179
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2179
							break -- 2180
						end -- 2180
						i = i + 1 -- 2181
					end -- 2181
					parts[#parts + 1] = " " -- 2183
					if withMap then -- 2183
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2184
					end -- 2184
				else -- 2184
					parts[#parts + 1] = ch -- 2186
					if withMap then -- 2186
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2187
					end -- 2187
					i = i + 1 -- 2188
				end -- 2188
			end -- 2188
			return { -- 2191
				text = table.concat(parts, ""), -- 2191
				map = map -- 2191
			} -- 2191
		end -- 2170
		local foldedContent = foldWhitespace(content, true) -- 2193
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2194
		if foldedOld == "" then -- 2194
			return {success = false, message = "old_str not found in file"} -- 2196
		end -- 2196
		local matches = {} -- 2198
		local pos = 0 -- 2199
		while true do -- 2199
			local idx = (string.find( -- 2201
				foldedContent.text, -- 2201
				foldedOld, -- 2201
				math.max(pos + 1, 1), -- 2201
				true -- 2201
			) or 0) - 1 -- 2201
			if idx < 0 then -- 2201
				break -- 2202
			end -- 2202
			local lastIdx = idx + #foldedOld - 1 -- 2203
			local startMap = foldedContent.map[idx + 1] -- 2204
			local endMap = foldedContent.map[lastIdx + 1] -- 2205
			if startMap ~= nil and endMap ~= nil then -- 2205
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2207
			end -- 2207
			pos = idx + #foldedOld -- 2209
		end -- 2209
		if #matches == 0 then -- 2209
			return {success = false, message = "old_str not found in file"} -- 2212
		end -- 2212
		if #matches > 1 then -- 2212
			return { -- 2215
				success = false, -- 2216
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2217
			} -- 2217
		end -- 2217
		local match = matches[1] -- 2220
		return { -- 2221
			success = true, -- 2222
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2223
		} -- 2223
	end -- 2168
	local contentLines = splitLines(content) -- 2226
	local oldLines = splitLines(oldStr) -- 2227
	if #oldLines == 0 then -- 2227
		return {success = false, message = "old_str not found in file"} -- 2229
	end -- 2229
	local dedentedOld = dedentLines(oldLines) -- 2231
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2232
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2233
	local matches = {} -- 2234
	do -- 2234
		local start = 0 -- 2235
		while start <= #contentLines - #oldLines do -- 2235
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2236
			local dedentedCandidate = dedentLines(candidateLines) -- 2237
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2237
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2239
			end -- 2239
			start = start + 1 -- 2235
		end -- 2235
	end -- 2235
	if #matches == 0 then -- 2235
		return findWhitespaceTolerantReplacement() -- 2247
	end -- 2247
	if #matches > 1 then -- 2247
		return { -- 2250
			success = false, -- 2251
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2252
		} -- 2252
	end -- 2252
	local match = matches[1] -- 2255
	local rebuiltNewLines = __TS__ArrayMap( -- 2256
		dedentedNew.lines, -- 2256
		function(____, line) return line == "" and "" or match.indent .. line end -- 2256
	) -- 2256
	local ____array_47 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2256
	__TS__SparseArrayPush( -- 2256
		____array_47, -- 2256
		table.unpack(rebuiltNewLines) -- 2259
	) -- 2259
	__TS__SparseArrayPush( -- 2259
		____array_47, -- 2259
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2260
	) -- 2260
	local nextLines = {__TS__SparseArraySpread(____array_47)} -- 2257
	return { -- 2262
		success = true, -- 2262
		content = joinLines(nextLines) -- 2262
	} -- 2262
end -- 2163
local MainDecisionAgent = __TS__Class() -- 2265
MainDecisionAgent.name = "MainDecisionAgent" -- 2265
__TS__ClassExtends(MainDecisionAgent, Node) -- 2265
function MainDecisionAgent.prototype.prep(self, shared) -- 2266
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2266
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2266
			return ____awaiter_resolve(nil, {shared = shared}) -- 2266
		end -- 2266
		__TS__Await(maybeCompressHistory(shared)) -- 2271
		return ____awaiter_resolve(nil, {shared = shared}) -- 2271
	end) -- 2271
end -- 2266
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2276
	local preExecuted = shared.preExecutedResults -- 2277
	if not preExecuted or preExecuted.size == 0 then -- 2277
		return nil -- 2278
	end -- 2278
	local decisions = {} -- 2279
	preExecuted:forEach(function(____, preResult) -- 2280
		local action = preResult.action -- 2281
		decisions[#decisions + 1] = { -- 2282
			success = true, -- 2283
			tool = action.tool, -- 2284
			params = action.params, -- 2285
			toolCallId = action.toolCallId, -- 2286
			reason = action.reason, -- 2287
			reasoningContent = action.reasoningContent -- 2288
		} -- 2288
	end) -- 2280
	if #decisions == 0 then -- 2280
		return nil -- 2291
	end -- 2291
	Log( -- 2292
		"Warn", -- 2292
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2292
			__TS__ArrayMap( -- 2292
				decisions, -- 2292
				function(____, decision) return decision.tool end -- 2292
			), -- 2292
			"," -- 2292
		) -- 2292
	) -- 2292
	if #decisions == 1 then -- 2292
		return decisions[1] -- 2294
	end -- 2294
	return {success = true, kind = "batch", decisions = decisions} -- 2296
end -- 2276
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2303
	if attempt == nil then -- 2303
		attempt = 1 -- 2306
	end -- 2306
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2306
		if shared.stopToken.stopped then -- 2306
			return ____awaiter_resolve( -- 2306
				nil, -- 2306
				{ -- 2310
					success = false, -- 2310
					message = getCancelledReason(shared) -- 2310
				} -- 2310
			) -- 2310
		end -- 2310
		Log( -- 2312
			"Info", -- 2312
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2312
		) -- 2312
		local tools = AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX) -- 2313
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2314
		local stepId = shared.step + 1 -- 2315
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2316
		emitLLMContextMetrics( -- 2320
			shared, -- 2320
			stepId, -- 2320
			"decision_tool_calling", -- 2320
			messages, -- 2320
			llmOptions -- 2320
		) -- 2320
		saveStepLLMDebugInput( -- 2321
			shared, -- 2321
			stepId, -- 2321
			"decision_tool_calling", -- 2321
			messages, -- 2321
			llmOptions -- 2321
		) -- 2321
		local lastStreamContent = "" -- 2322
		local lastStreamReasoning = "" -- 2323
		local preExecutedResults = __TS__New(Map) -- 2324
		shared.preExecutedResults = preExecutedResults -- 2325
		local res = __TS__Await(callLLMStreamAggregated( -- 2326
			messages, -- 2327
			llmOptions, -- 2328
			shared.stopToken, -- 2329
			shared.llmConfig, -- 2330
			function(response) -- 2331
				local ____opt_50 = response.choices -- 2331
				local ____opt_48 = ____opt_50 and ____opt_50[1] -- 2331
				local streamMessage = ____opt_48 and ____opt_48.message -- 2332
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2333
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2336
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2336
					return -- 2340
				end -- 2340
				lastStreamContent = nextContent -- 2342
				lastStreamReasoning = nextReasoning -- 2343
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2344
			end, -- 2331
			function(tc) -- 2346
				if shared.stopToken.stopped then -- 2346
					return -- 2347
				end -- 2347
				local action = createPreExecutableActionFromStream(shared, tc) -- 2348
				if not action or preExecutedResults:has(action.toolCallId) then -- 2348
					return -- 2349
				end -- 2349
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2350
				preExecutedResults:set( -- 2351
					action.toolCallId, -- 2351
					createPreExecutedToolResult(shared, action) -- 2351
				) -- 2351
			end -- 2346
		)) -- 2346
		if shared.stopToken.stopped then -- 2346
			clearPreExecutedResults(shared) -- 2355
			return ____awaiter_resolve( -- 2355
				nil, -- 2355
				{ -- 2356
					success = false, -- 2356
					message = getCancelledReason(shared) -- 2356
				} -- 2356
			) -- 2356
		end -- 2356
		if not res.success then -- 2356
			saveStepLLMDebugOutput( -- 2359
				shared, -- 2359
				stepId, -- 2359
				"decision_tool_calling", -- 2359
				res.raw or res.message, -- 2359
				{success = false} -- 2359
			) -- 2359
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2360
			if (string.find(res.message, "stream incomplete:", nil, true) or 0) - 1 >= 0 then -- 2360
				local ____opt_56 = res.response -- 2360
				local partialChoice = ____opt_56 and ____opt_56.choices and res.response.choices[1] -- 2362
				local partialMessage = partialChoice and partialChoice.message -- 2363
				local partialToolCalls = partialMessage and partialMessage.tool_calls -- 2364
				if partialToolCalls and #partialToolCalls > 0 then -- 2364
					local partialReasoningContent = partialMessage and type(partialMessage.reasoning_content) == "string" and partialMessage.reasoning_content or nil -- 2366
					local partialMessageContent = partialMessage and type(partialMessage.content) == "string" and __TS__StringTrim(partialMessage.content) or nil -- 2369
					local partialDecisions = {} -- 2372
					local partialFailure -- 2373
					do -- 2373
						local i = 0 -- 2374
						while i < #partialToolCalls do -- 2374
							local toolCall = partialToolCalls[i + 1] -- 2375
							local fn = toolCall and toolCall["function"] -- 2376
							if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2376
								partialFailure = { -- 2378
									success = false, -- 2379
									message = "missing function name for partial tool call " .. tostring(i + 1), -- 2380
									raw = partialMessageContent -- 2381
								} -- 2381
								break -- 2383
							end -- 2383
							local decision = parseAndValidateToolCallDecision( -- 2385
								shared, -- 2386
								fn.name, -- 2387
								type(fn.arguments) == "string" and fn.arguments or "", -- 2388
								toolCall and type(toolCall.id) == "string" and toolCall.id or nil, -- 2389
								partialMessageContent, -- 2390
								partialReasoningContent -- 2391
							) -- 2391
							if not decision.success then -- 2391
								partialFailure = decision -- 2394
								break -- 2395
							end -- 2395
							partialDecisions[#partialDecisions + 1] = decision -- 2397
							i = i + 1 -- 2374
						end -- 2374
					end -- 2374
					if not partialFailure and #partialDecisions > 0 then -- 2374
						Log( -- 2400
							"Warn", -- 2400
							"[CodingAgent] committing partial tool calls after incomplete stream tools=" .. table.concat( -- 2400
								__TS__ArrayMap( -- 2400
									partialDecisions, -- 2400
									function(____, decision) return decision.tool end -- 2400
								), -- 2400
								"," -- 2400
							) -- 2400
						) -- 2400
						if #partialDecisions == 1 then -- 2400
							return ____awaiter_resolve(nil, partialDecisions[1]) -- 2400
						end -- 2400
						return ____awaiter_resolve(nil, { -- 2400
							success = true, -- 2405
							kind = "batch", -- 2406
							decisions = partialDecisions, -- 2407
							content = partialMessageContent, -- 2408
							reasoningContent = partialReasoningContent -- 2409
						}) -- 2409
					end -- 2409
					Log("Warn", "[CodingAgent] partial tool calls not commit-ready after incomplete stream: " .. (partialFailure and partialFailure.message or "empty decisions")) -- 2412
				end -- 2412
				local committedDecision = self:commitPreExecutedDecision(shared) -- 2414
				if committedDecision then -- 2414
					return ____awaiter_resolve(nil, committedDecision) -- 2414
				end -- 2414
			end -- 2414
			clearPreExecutedResults(shared) -- 2419
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2419
		end -- 2419
		saveStepLLMDebugOutput( -- 2422
			shared, -- 2422
			stepId, -- 2422
			"decision_tool_calling", -- 2422
			encodeDebugJSON(res.response), -- 2422
			{success = true} -- 2422
		) -- 2422
		local choice = res.response.choices and res.response.choices[1] -- 2423
		local message = choice and choice.message -- 2424
		local toolCalls = message and message.tool_calls -- 2425
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2426
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2429
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2432
		Log( -- 2435
			"Info", -- 2435
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2435
		) -- 2435
		if not toolCalls or #toolCalls == 0 then -- 2435
			if finishReason == "length" then -- 2435
				Log( -- 2438
					"Error", -- 2438
					"[CodingAgent] tool-calling output truncated before tool call reasoning_len=" .. tostring(reasoningContent and #reasoningContent or 0) -- 2438
				) -- 2438
				clearPreExecutedResults(shared) -- 2439
				return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens before producing a tool call. Retry immediately with a valid tool call and keep reasoning minimal.", raw = reasoningContent or messageContent or ""}) -- 2439
			end -- 2439
			if messageContent and messageContent ~= "" then -- 2439
				Log( -- 2447
					"Info", -- 2447
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2447
				) -- 2447
				clearPreExecutedResults(shared) -- 2448
				return ____awaiter_resolve(nil, { -- 2448
					success = true, -- 2450
					tool = "finish", -- 2451
					params = {}, -- 2452
					reason = messageContent, -- 2453
					reasoningContent = reasoningContent, -- 2454
					directSummary = messageContent -- 2455
				}) -- 2455
			end -- 2455
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2458
			clearPreExecutedResults(shared) -- 2459
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2459
		end -- 2459
		local decisions = {} -- 2466
		do -- 2466
			local i = 0 -- 2467
			while i < #toolCalls do -- 2467
				local toolCall = toolCalls[i + 1] -- 2468
				local fn = toolCall and toolCall["function"] -- 2469
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2469
					Log( -- 2471
						"Error", -- 2471
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2471
					) -- 2471
					clearPreExecutedResults(shared) -- 2472
					return ____awaiter_resolve( -- 2472
						nil, -- 2472
						{ -- 2473
							success = false, -- 2474
							message = "missing function name for tool call " .. tostring(i + 1), -- 2475
							raw = messageContent -- 2476
						} -- 2476
					) -- 2476
				end -- 2476
				local functionName = fn.name -- 2479
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2480
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2481
				Log( -- 2484
					"Info", -- 2484
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2484
				) -- 2484
				local decision = parseAndValidateToolCallDecision( -- 2485
					shared, -- 2486
					functionName, -- 2487
					argsText, -- 2488
					toolCallId, -- 2489
					messageContent, -- 2490
					reasoningContent -- 2491
				) -- 2491
				if not decision.success then -- 2491
					Log( -- 2494
						"Error", -- 2494
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2494
					) -- 2494
					clearPreExecutedResults(shared) -- 2495
					return ____awaiter_resolve(nil, decision) -- 2495
				end -- 2495
				decisions[#decisions + 1] = decision -- 2498
				i = i + 1 -- 2467
			end -- 2467
		end -- 2467
		if #decisions == 1 then -- 2467
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2501
			return ____awaiter_resolve(nil, decisions[1]) -- 2501
		end -- 2501
		do -- 2501
			local i = 0 -- 2504
			while i < #decisions do -- 2504
				if decisions[i + 1].tool == "finish" then -- 2504
					clearPreExecutedResults(shared) -- 2506
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2506
				end -- 2506
				i = i + 1 -- 2504
			end -- 2504
		end -- 2504
		Log( -- 2514
			"Info", -- 2514
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2514
				__TS__ArrayMap( -- 2514
					decisions, -- 2514
					function(____, decision) return decision.tool end -- 2514
				), -- 2514
				"," -- 2514
			) -- 2514
		) -- 2514
		return ____awaiter_resolve(nil, { -- 2514
			success = true, -- 2516
			kind = "batch", -- 2517
			decisions = decisions, -- 2518
			content = messageContent, -- 2519
			reasoningContent = reasoningContent -- 2520
		}) -- 2520
	end) -- 2520
end -- 2303
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 2524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2524
		Log( -- 2530
			"Info", -- 2530
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2530
		) -- 2530
		local lastError = initialError -- 2531
		local candidateRaw = "" -- 2532
		local candidateReasoning = nil -- 2533
		do -- 2533
			local attempt = 0 -- 2534
			while attempt < shared.llmMaxTry do -- 2534
				do -- 2534
					Log( -- 2535
						"Info", -- 2535
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2535
					) -- 2535
					local messages = buildXmlRepairMessages( -- 2536
						shared, -- 2537
						originalRaw, -- 2538
						originalReasoning, -- 2539
						candidateRaw, -- 2540
						candidateReasoning, -- 2541
						lastError, -- 2542
						attempt + 1 -- 2543
					) -- 2543
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2545
					if shared.stopToken.stopped then -- 2545
						return ____awaiter_resolve( -- 2545
							nil, -- 2545
							{ -- 2547
								success = false, -- 2547
								message = getCancelledReason(shared) -- 2547
							} -- 2547
						) -- 2547
					end -- 2547
					if not llmRes.success then -- 2547
						lastError = llmRes.message -- 2550
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2551
						goto __continue453 -- 2552
					end -- 2552
					candidateRaw = llmRes.text -- 2554
					candidateReasoning = llmRes.reasoningContent -- 2555
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2556
					if decision.success then -- 2556
						decision.reasoningContent = llmRes.reasoningContent -- 2558
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2559
						return ____awaiter_resolve(nil, decision) -- 2559
					end -- 2559
					lastError = decision.message -- 2562
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2563
				end -- 2563
				::__continue453:: -- 2563
				attempt = attempt + 1 -- 2534
			end -- 2534
		end -- 2534
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2565
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2565
	end) -- 2565
end -- 2524
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2573
	if attempt == nil then -- 2573
		attempt = 1 -- 2576
	end -- 2576
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2576
		local messages = buildDecisionMessages( -- 2579
			shared, -- 2580
			lastError, -- 2581
			attempt, -- 2582
			lastRaw, -- 2583
			"xml" -- 2584
		) -- 2584
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2586
		if shared.stopToken.stopped then -- 2586
			return ____awaiter_resolve( -- 2586
				nil, -- 2586
				{ -- 2588
					success = false, -- 2588
					message = getCancelledReason(shared) -- 2588
				} -- 2588
			) -- 2588
		end -- 2588
		if not llmRes.success then -- 2588
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2588
		end -- 2588
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2597
		if decision.success then -- 2597
			decision.reasoningContent = llmRes.reasoningContent -- 2599
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2599
				return ____awaiter_resolve( -- 2599
					nil, -- 2599
					self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2601
				) -- 2601
			end -- 2601
			return ____awaiter_resolve(nil, decision) -- 2601
		end -- 2601
		return ____awaiter_resolve( -- 2601
			nil, -- 2601
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 2610
		) -- 2610
	end) -- 2610
end -- 2573
function MainDecisionAgent.prototype.exec(self, input) -- 2613
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2613
		local shared = input.shared -- 2614
		if shared.stopToken.stopped then -- 2614
			return ____awaiter_resolve( -- 2614
				nil, -- 2614
				{ -- 2616
					success = false, -- 2616
					message = getCancelledReason(shared) -- 2616
				} -- 2616
			) -- 2616
		end -- 2616
		if shared.step >= shared.maxSteps then -- 2616
			Log( -- 2619
				"Warn", -- 2619
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2619
			) -- 2619
			return ____awaiter_resolve( -- 2619
				nil, -- 2619
				{ -- 2620
					success = false, -- 2620
					message = getMaxStepsReachedReason(shared) -- 2620
				} -- 2620
			) -- 2620
		end -- 2620
		if shared.decisionMode == "tool_calling" then -- 2620
			Log( -- 2624
				"Info", -- 2624
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2624
			) -- 2624
			local lastError = "tool calling validation failed" -- 2625
			local lastRaw = "" -- 2626
			local shouldFallbackToXml = false -- 2627
			do -- 2627
				local attempt = 0 -- 2628
				while attempt < shared.llmMaxTry do -- 2628
					Log( -- 2629
						"Info", -- 2629
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2629
					) -- 2629
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2630
					if shared.stopToken.stopped then -- 2630
						return ____awaiter_resolve( -- 2630
							nil, -- 2630
							{ -- 2637
								success = false, -- 2637
								message = getCancelledReason(shared) -- 2637
							} -- 2637
						) -- 2637
					end -- 2637
					if decision.success then -- 2637
						return ____awaiter_resolve(nil, decision) -- 2637
					end -- 2637
					lastError = decision.message -- 2642
					lastRaw = decision.raw or "" -- 2643
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2644
					if lastError == "missing tool call" then -- 2644
						shouldFallbackToXml = true -- 2646
						break -- 2647
					end -- 2647
					attempt = attempt + 1 -- 2628
				end -- 2628
			end -- 2628
			if shouldFallbackToXml then -- 2628
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2651
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2652
				do -- 2652
					local attempt = 0 -- 2653
					while attempt < shared.llmMaxTry do -- 2653
						Log( -- 2654
							"Info", -- 2654
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2654
						) -- 2654
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2655
						if shared.stopToken.stopped then -- 2655
							return ____awaiter_resolve( -- 2655
								nil, -- 2655
								{ -- 2662
									success = false, -- 2662
									message = getCancelledReason(shared) -- 2662
								} -- 2662
							) -- 2662
						end -- 2662
						if decision.success then -- 2662
							return ____awaiter_resolve(nil, decision) -- 2662
						end -- 2662
						lastError = decision.message -- 2667
						lastRaw = decision.raw or "" -- 2668
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2669
						attempt = attempt + 1 -- 2653
					end -- 2653
				end -- 2653
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2671
				return ____awaiter_resolve( -- 2671
					nil, -- 2671
					{ -- 2672
						success = false, -- 2672
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2672
					} -- 2672
				) -- 2672
			end -- 2672
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2674
			return ____awaiter_resolve( -- 2674
				nil, -- 2674
				{ -- 2675
					success = false, -- 2675
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2675
				} -- 2675
			) -- 2675
		end -- 2675
		local lastError = "xml validation failed" -- 2678
		local lastRaw = "" -- 2679
		do -- 2679
			local attempt = 0 -- 2680
			while attempt < shared.llmMaxTry do -- 2680
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2681
				if shared.stopToken.stopped then -- 2681
					return ____awaiter_resolve( -- 2681
						nil, -- 2681
						{ -- 2690
							success = false, -- 2690
							message = getCancelledReason(shared) -- 2690
						} -- 2690
					) -- 2690
				end -- 2690
				if decision.success then -- 2690
					return ____awaiter_resolve(nil, decision) -- 2690
				end -- 2690
				lastError = decision.message -- 2695
				lastRaw = decision.raw or "" -- 2696
				attempt = attempt + 1 -- 2680
			end -- 2680
		end -- 2680
		return ____awaiter_resolve( -- 2680
			nil, -- 2680
			{ -- 2698
				success = false, -- 2698
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2698
			} -- 2698
		) -- 2698
	end) -- 2698
end -- 2613
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2701
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2701
		local result = execRes -- 2702
		if not result.success then -- 2702
			if shared.stopToken.stopped then -- 2702
				shared.error = getCancelledReason(shared) -- 2705
				shared.done = true -- 2706
				return ____awaiter_resolve(nil, "done") -- 2706
			end -- 2706
			shared.error = result.message -- 2709
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2710
			shared.done = true -- 2711
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2712
			persistHistoryState(shared) -- 2716
			return ____awaiter_resolve(nil, "done") -- 2716
		end -- 2716
		if isDecisionBatchSuccess(result) then -- 2716
			local startStep = shared.step -- 2720
			local actions = {} -- 2721
			do -- 2721
				local i = 0 -- 2722
				while i < #result.decisions do -- 2722
					local decision = result.decisions[i + 1] -- 2723
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2724
					local step = startStep + i + 1 -- 2725
					local ____temp_58 -- 2726
					if i == 0 then -- 2726
						____temp_58 = decision.reason -- 2726
					else -- 2726
						____temp_58 = "" -- 2726
					end -- 2726
					local actionReason = ____temp_58 -- 2726
					local ____temp_59 -- 2727
					if i == 0 then -- 2727
						____temp_59 = decision.reasoningContent -- 2727
					else -- 2727
						____temp_59 = nil -- 2727
					end -- 2727
					local actionReasoningContent = ____temp_59 -- 2727
					emitAgentEvent(shared, { -- 2728
						type = "decision_made", -- 2729
						sessionId = shared.sessionId, -- 2730
						taskId = shared.taskId, -- 2731
						step = step, -- 2732
						tool = decision.tool, -- 2733
						reason = actionReason, -- 2734
						reasoningContent = actionReasoningContent, -- 2735
						params = decision.params -- 2736
					}) -- 2736
					local action = { -- 2738
						step = step, -- 2739
						toolCallId = toolCallId, -- 2740
						tool = decision.tool, -- 2741
						reason = actionReason or "", -- 2742
						reasoningContent = actionReasoningContent, -- 2743
						params = decision.params, -- 2744
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2745
					} -- 2745
					local ____shared_history_60 = shared.history -- 2745
					____shared_history_60[#____shared_history_60 + 1] = action -- 2747
					actions[#actions + 1] = action -- 2748
					i = i + 1 -- 2722
				end -- 2722
			end -- 2722
			shared.step = startStep + #actions -- 2750
			shared.pendingToolActions = actions -- 2751
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2752
			persistHistoryState(shared) -- 2758
			return ____awaiter_resolve(nil, "batch_tools") -- 2758
		end -- 2758
		if result.directSummary and result.directSummary ~= "" then -- 2758
			shared.response = result.directSummary -- 2762
			shared.done = true -- 2763
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2764
			persistHistoryState(shared) -- 2769
			return ____awaiter_resolve(nil, "done") -- 2769
		end -- 2769
		if result.tool == "finish" then -- 2769
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2773
			shared.response = finalMessage -- 2774
			shared.done = true -- 2775
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2776
			persistHistoryState(shared) -- 2781
			return ____awaiter_resolve(nil, "done") -- 2781
		end -- 2781
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2784
		shared.step = shared.step + 1 -- 2785
		local step = shared.step -- 2786
		emitAgentEvent(shared, { -- 2787
			type = "decision_made", -- 2788
			sessionId = shared.sessionId, -- 2789
			taskId = shared.taskId, -- 2790
			step = step, -- 2791
			tool = result.tool, -- 2792
			reason = result.reason, -- 2793
			reasoningContent = result.reasoningContent, -- 2794
			params = result.params -- 2795
		}) -- 2795
		local ____shared_history_61 = shared.history -- 2795
		____shared_history_61[#____shared_history_61 + 1] = { -- 2797
			step = step, -- 2798
			toolCallId = toolCallId, -- 2799
			tool = result.tool, -- 2800
			reason = result.reason or "", -- 2801
			reasoningContent = result.reasoningContent, -- 2802
			params = result.params, -- 2803
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2804
		} -- 2804
		local action = shared.history[#shared.history] -- 2806
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2807
		if AgentToolRegistry.canPreExecuteTool(action.tool) then -- 2807
			shared.pendingToolActions = {action} -- 2809
			persistHistoryState(shared) -- 2810
			return ____awaiter_resolve(nil, "batch_tools") -- 2810
		end -- 2810
		clearPreExecutedResults(shared) -- 2813
		persistHistoryState(shared) -- 2814
		return ____awaiter_resolve(nil, result.tool) -- 2814
	end) -- 2814
end -- 2701
local ReadFileAction = __TS__Class() -- 2819
ReadFileAction.name = "ReadFileAction" -- 2819
__TS__ClassExtends(ReadFileAction, Node) -- 2819
function ReadFileAction.prototype.prep(self, shared) -- 2820
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2820
		local last = shared.history[#shared.history] -- 2821
		if not last then -- 2821
			error( -- 2822
				__TS__New(Error, "no history"), -- 2822
				0 -- 2822
			) -- 2822
		end -- 2822
		emitAgentStartEvent(shared, last) -- 2823
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2824
		if __TS__StringTrim(path) == "" then -- 2824
			error( -- 2827
				__TS__New(Error, "missing path"), -- 2827
				0 -- 2827
			) -- 2827
		end -- 2827
		local ____path_64 = path -- 2829
		local ____shared_workingDir_65 = shared.workingDir -- 2831
		local ____temp_66 = shared.useChineseResponse and "zh" or "en" -- 2832
		local ____last_params_startLine_62 = last.params.startLine -- 2833
		if ____last_params_startLine_62 == nil then -- 2833
			____last_params_startLine_62 = 1 -- 2833
		end -- 2833
		local ____TS__Number_result_67 = __TS__Number(____last_params_startLine_62) -- 2833
		local ____last_params_endLine_63 = last.params.endLine -- 2834
		if ____last_params_endLine_63 == nil then -- 2834
			____last_params_endLine_63 = READ_FILE_DEFAULT_LIMIT -- 2834
		end -- 2834
		return ____awaiter_resolve( -- 2834
			nil, -- 2834
			{ -- 2828
				path = ____path_64, -- 2829
				tool = "read_file", -- 2830
				workDir = ____shared_workingDir_65, -- 2831
				docLanguage = ____temp_66, -- 2832
				startLine = ____TS__Number_result_67, -- 2833
				endLine = __TS__Number(____last_params_endLine_63) -- 2834
			} -- 2834
		) -- 2834
	end) -- 2834
end -- 2820
function ReadFileAction.prototype.exec(self, input) -- 2838
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2838
		return ____awaiter_resolve( -- 2838
			nil, -- 2838
			Tools.readFile( -- 2839
				input.workDir, -- 2840
				input.path, -- 2841
				__TS__Number(input.startLine or 1), -- 2842
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2843
				input.docLanguage -- 2844
			) -- 2844
		) -- 2844
	end) -- 2844
end -- 2838
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2848
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2848
		local result = execRes -- 2849
		local last = shared.history[#shared.history] -- 2850
		if last ~= nil then -- 2850
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2852
			appendToolResultMessage(shared, last) -- 2853
			emitAgentFinishEvent(shared, last) -- 2854
		end -- 2854
		persistHistoryState(shared) -- 2856
		__TS__Await(maybeCompressHistory(shared)) -- 2857
		persistHistoryState(shared) -- 2858
		return ____awaiter_resolve(nil, "main") -- 2858
	end) -- 2858
end -- 2848
local SearchFilesAction = __TS__Class() -- 2863
SearchFilesAction.name = "SearchFilesAction" -- 2863
__TS__ClassExtends(SearchFilesAction, Node) -- 2863
function SearchFilesAction.prototype.prep(self, shared) -- 2864
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2864
		local last = shared.history[#shared.history] -- 2865
		if not last then -- 2865
			error( -- 2866
				__TS__New(Error, "no history"), -- 2866
				0 -- 2866
			) -- 2866
		end -- 2866
		emitAgentStartEvent(shared, last) -- 2867
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2867
	end) -- 2867
end -- 2864
function SearchFilesAction.prototype.exec(self, input) -- 2871
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2871
		local params = input.params -- 2872
		local ____Tools_searchFiles_81 = Tools.searchFiles -- 2873
		local ____input_workDir_74 = input.workDir -- 2874
		local ____temp_75 = params.path or "" -- 2875
		local ____temp_76 = params.pattern or "" -- 2876
		local ____params_globs_77 = params.globs -- 2877
		local ____params_useRegex_78 = params.useRegex -- 2878
		local ____params_caseSensitive_79 = params.caseSensitive -- 2879
		local ____math_max_70 = math.max -- 2882
		local ____math_floor_69 = math.floor -- 2882
		local ____params_limit_68 = params.limit -- 2882
		if ____params_limit_68 == nil then -- 2882
			____params_limit_68 = SEARCH_FILES_LIMIT_DEFAULT -- 2882
		end -- 2882
		local ____math_max_70_result_80 = ____math_max_70( -- 2882
			1, -- 2882
			____math_floor_69(__TS__Number(____params_limit_68)) -- 2882
		) -- 2882
		local ____math_max_73 = math.max -- 2883
		local ____math_floor_72 = math.floor -- 2883
		local ____params_offset_71 = params.offset -- 2883
		if ____params_offset_71 == nil then -- 2883
			____params_offset_71 = 0 -- 2883
		end -- 2883
		local result = __TS__Await(____Tools_searchFiles_81({ -- 2873
			workDir = ____input_workDir_74, -- 2874
			path = ____temp_75, -- 2875
			pattern = ____temp_76, -- 2876
			globs = ____params_globs_77, -- 2877
			useRegex = ____params_useRegex_78, -- 2878
			caseSensitive = ____params_caseSensitive_79, -- 2879
			includeContent = true, -- 2880
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2881
			limit = ____math_max_70_result_80, -- 2882
			offset = ____math_max_73( -- 2883
				0, -- 2883
				____math_floor_72(__TS__Number(____params_offset_71)) -- 2883
			), -- 2883
			groupByFile = params.groupByFile == true -- 2884
		})) -- 2884
		return ____awaiter_resolve(nil, result) -- 2884
	end) -- 2884
end -- 2871
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2889
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2889
		local last = shared.history[#shared.history] -- 2890
		if last ~= nil then -- 2890
			local result = execRes -- 2892
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2893
			appendToolResultMessage(shared, last) -- 2894
			emitAgentFinishEvent(shared, last) -- 2895
		end -- 2895
		persistHistoryState(shared) -- 2897
		__TS__Await(maybeCompressHistory(shared)) -- 2898
		persistHistoryState(shared) -- 2899
		return ____awaiter_resolve(nil, "main") -- 2899
	end) -- 2899
end -- 2889
local SearchDoraAPIAction = __TS__Class() -- 2904
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2904
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2904
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2905
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2905
		local last = shared.history[#shared.history] -- 2906
		if not last then -- 2906
			error( -- 2907
				__TS__New(Error, "no history"), -- 2907
				0 -- 2907
			) -- 2907
		end -- 2907
		emitAgentStartEvent(shared, last) -- 2908
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2908
	end) -- 2908
end -- 2905
function SearchDoraAPIAction.prototype.exec(self, input) -- 2912
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2912
		local params = input.params -- 2913
		local ____Tools_searchDoraAPI_89 = Tools.searchDoraAPI -- 2914
		local ____temp_85 = params.pattern or "" -- 2915
		local ____temp_86 = params.docSource or "api" -- 2916
		local ____temp_87 = input.useChineseResponse and "zh" or "en" -- 2917
		local ____temp_88 = params.programmingLanguage or "ts" -- 2918
		local ____math_min_84 = math.min -- 2919
		local ____math_max_83 = math.max -- 2919
		local ____params_limit_82 = params.limit -- 2919
		if ____params_limit_82 == nil then -- 2919
			____params_limit_82 = 8 -- 2919
		end -- 2919
		local result = __TS__Await(____Tools_searchDoraAPI_89({ -- 2914
			pattern = ____temp_85, -- 2915
			docSource = ____temp_86, -- 2916
			docLanguage = ____temp_87, -- 2917
			programmingLanguage = ____temp_88, -- 2918
			limit = ____math_min_84( -- 2919
				SEARCH_DORA_API_LIMIT_MAX, -- 2919
				____math_max_83( -- 2919
					1, -- 2919
					__TS__Number(____params_limit_82) -- 2919
				) -- 2919
			), -- 2919
			useRegex = params.useRegex, -- 2920
			caseSensitive = false, -- 2921
			includeContent = true, -- 2922
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2923
		})) -- 2923
		return ____awaiter_resolve(nil, result) -- 2923
	end) -- 2923
end -- 2912
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2928
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2928
		local last = shared.history[#shared.history] -- 2929
		if last ~= nil then -- 2929
			local result = execRes -- 2931
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2932
			appendToolResultMessage(shared, last) -- 2933
			emitAgentFinishEvent(shared, last) -- 2934
		end -- 2934
		persistHistoryState(shared) -- 2936
		__TS__Await(maybeCompressHistory(shared)) -- 2937
		persistHistoryState(shared) -- 2938
		return ____awaiter_resolve(nil, "main") -- 2938
	end) -- 2938
end -- 2928
local ListFilesAction = __TS__Class() -- 2943
ListFilesAction.name = "ListFilesAction" -- 2943
__TS__ClassExtends(ListFilesAction, Node) -- 2943
function ListFilesAction.prototype.prep(self, shared) -- 2944
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2944
		local last = shared.history[#shared.history] -- 2945
		if not last then -- 2945
			error( -- 2946
				__TS__New(Error, "no history"), -- 2946
				0 -- 2946
			) -- 2946
		end -- 2946
		emitAgentStartEvent(shared, last) -- 2947
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2947
	end) -- 2947
end -- 2944
function ListFilesAction.prototype.exec(self, input) -- 2951
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2951
		local params = input.params -- 2952
		local ____Tools_listFiles_96 = Tools.listFiles -- 2953
		local ____input_workDir_93 = input.workDir -- 2954
		local ____temp_94 = params.path or "" -- 2955
		local ____params_globs_95 = params.globs -- 2956
		local ____math_max_92 = math.max -- 2957
		local ____math_floor_91 = math.floor -- 2957
		local ____params_maxEntries_90 = params.maxEntries -- 2957
		if ____params_maxEntries_90 == nil then -- 2957
			____params_maxEntries_90 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2957
		end -- 2957
		local result = ____Tools_listFiles_96({ -- 2953
			workDir = ____input_workDir_93, -- 2954
			path = ____temp_94, -- 2955
			globs = ____params_globs_95, -- 2956
			maxEntries = ____math_max_92( -- 2957
				1, -- 2957
				____math_floor_91(__TS__Number(____params_maxEntries_90)) -- 2957
			) -- 2957
		}) -- 2957
		return ____awaiter_resolve(nil, result) -- 2957
	end) -- 2957
end -- 2951
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2962
		local last = shared.history[#shared.history] -- 2963
		if last ~= nil then -- 2963
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2965
			appendToolResultMessage(shared, last) -- 2966
			emitAgentFinishEvent(shared, last) -- 2967
		end -- 2967
		persistHistoryState(shared) -- 2969
		__TS__Await(maybeCompressHistory(shared)) -- 2970
		persistHistoryState(shared) -- 2971
		return ____awaiter_resolve(nil, "main") -- 2971
	end) -- 2971
end -- 2962
local DeleteFileAction = __TS__Class() -- 2976
DeleteFileAction.name = "DeleteFileAction" -- 2976
__TS__ClassExtends(DeleteFileAction, Node) -- 2976
function DeleteFileAction.prototype.prep(self, shared) -- 2977
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2977
		local last = shared.history[#shared.history] -- 2978
		if not last then -- 2978
			error( -- 2979
				__TS__New(Error, "no history"), -- 2979
				0 -- 2979
			) -- 2979
		end -- 2979
		emitAgentStartEvent(shared, last) -- 2980
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2981
		if __TS__StringTrim(targetFile) == "" then -- 2981
			error( -- 2984
				__TS__New(Error, "missing target_file"), -- 2984
				0 -- 2984
			) -- 2984
		end -- 2984
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2984
	end) -- 2984
end -- 2977
function DeleteFileAction.prototype.exec(self, input) -- 2988
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2988
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2989
		if not result.success then -- 2989
			return ____awaiter_resolve(nil, result) -- 2989
		end -- 2989
		return ____awaiter_resolve(nil, { -- 2989
			success = true, -- 2997
			changed = true, -- 2998
			mode = "delete", -- 2999
			checkpointId = result.checkpointId, -- 3000
			checkpointSeq = result.checkpointSeq, -- 3001
			files = {{path = input.targetFile, op = "delete"}} -- 3002
		}) -- 3002
	end) -- 3002
end -- 2988
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3006
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3006
		local last = shared.history[#shared.history] -- 3007
		if last ~= nil then -- 3007
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3009
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3010
			appendToolResultMessage(shared, last) -- 3011
			emitAgentFinishEvent(shared, last) -- 3012
			local result = last.result -- 3013
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3013
				emitAgentEvent(shared, { -- 3018
					type = "checkpoint_created", -- 3019
					sessionId = shared.sessionId, -- 3020
					taskId = shared.taskId, -- 3021
					step = last.step, -- 3022
					tool = "delete_file", -- 3023
					checkpointId = result.checkpointId, -- 3024
					checkpointSeq = result.checkpointSeq, -- 3025
					files = result.files -- 3026
				}) -- 3026
			end -- 3026
		end -- 3026
		persistHistoryState(shared) -- 3030
		__TS__Await(maybeCompressHistory(shared)) -- 3031
		persistHistoryState(shared) -- 3032
		return ____awaiter_resolve(nil, "main") -- 3032
	end) -- 3032
end -- 3006
local BuildAction = __TS__Class() -- 3037
BuildAction.name = "BuildAction" -- 3037
__TS__ClassExtends(BuildAction, Node) -- 3037
function BuildAction.prototype.prep(self, shared) -- 3038
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3038
		local last = shared.history[#shared.history] -- 3039
		if not last then -- 3039
			error( -- 3040
				__TS__New(Error, "no history"), -- 3040
				0 -- 3040
			) -- 3040
		end -- 3040
		emitAgentStartEvent(shared, last) -- 3041
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3041
	end) -- 3041
end -- 3038
function BuildAction.prototype.exec(self, input) -- 3045
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3045
		local params = input.params -- 3046
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3047
		return ____awaiter_resolve(nil, result) -- 3047
	end) -- 3047
end -- 3045
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3054
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3054
		local last = shared.history[#shared.history] -- 3055
		if last ~= nil then -- 3055
			last.result = sanitizeBuildResultForHistory(execRes) -- 3057
			appendToolResultMessage(shared, last) -- 3058
			emitAgentFinishEvent(shared, last) -- 3059
		end -- 3059
		persistHistoryState(shared) -- 3061
		__TS__Await(maybeCompressHistory(shared)) -- 3062
		persistHistoryState(shared) -- 3063
		return ____awaiter_resolve(nil, "main") -- 3063
	end) -- 3063
end -- 3054
local SpawnSubAgentAction = __TS__Class() -- 3068
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3068
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3068
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3069
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3069
		local last = shared.history[#shared.history] -- 3078
		if not last then -- 3078
			error( -- 3079
				__TS__New(Error, "no history"), -- 3079
				0 -- 3079
			) -- 3079
		end -- 3079
		emitAgentStartEvent(shared, last) -- 3080
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3081
			last.params.filesHint, -- 3082
			function(____, item) return type(item) == "string" end -- 3082
		) or nil -- 3082
		return ____awaiter_resolve( -- 3082
			nil, -- 3082
			{ -- 3084
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3085
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3086
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3087
				filesHint = filesHint, -- 3088
				sessionId = shared.sessionId, -- 3089
				projectRoot = shared.workingDir, -- 3090
				spawnSubAgent = shared.spawnSubAgent -- 3091
			} -- 3091
		) -- 3091
	end) -- 3091
end -- 3069
function SpawnSubAgentAction.prototype.exec(self, input) -- 3095
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3095
		if not input.spawnSubAgent then -- 3095
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3095
		end -- 3095
		if input.sessionId == nil or input.sessionId <= 0 then -- 3095
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3095
		end -- 3095
		local ____Log_102 = Log -- 3110
		local ____temp_99 = #input.title -- 3110
		local ____temp_100 = #input.prompt -- 3110
		local ____temp_101 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3110
		local ____opt_97 = input.filesHint -- 3110
		____Log_102( -- 3110
			"Info", -- 3110
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_99)) .. " prompt_len=") .. tostring(____temp_100)) .. " expected_len=") .. tostring(____temp_101)) .. " files_hint_count=") .. tostring(____opt_97 and #____opt_97 or 0) -- 3110
		) -- 3110
		local result = __TS__Await(input.spawnSubAgent({ -- 3111
			parentSessionId = input.sessionId, -- 3112
			projectRoot = input.projectRoot, -- 3113
			title = input.title, -- 3114
			prompt = input.prompt, -- 3115
			expectedOutput = input.expectedOutput, -- 3116
			filesHint = input.filesHint -- 3117
		})) -- 3117
		if not result.success then -- 3117
			return ____awaiter_resolve(nil, result) -- 3117
		end -- 3117
		return ____awaiter_resolve(nil, { -- 3117
			success = true, -- 3123
			sessionId = result.sessionId, -- 3124
			taskId = result.taskId, -- 3125
			title = result.title, -- 3126
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3127
		}) -- 3127
	end) -- 3127
end -- 3095
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3131
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3131
		local last = shared.history[#shared.history] -- 3132
		if last ~= nil then -- 3132
			last.result = execRes -- 3134
			appendToolResultMessage(shared, last) -- 3135
			emitAgentFinishEvent(shared, last) -- 3136
		end -- 3136
		persistHistoryState(shared) -- 3138
		__TS__Await(maybeCompressHistory(shared)) -- 3139
		persistHistoryState(shared) -- 3140
		return ____awaiter_resolve(nil, "main") -- 3140
	end) -- 3140
end -- 3131
local ListSubAgentsAction = __TS__Class() -- 3145
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3145
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3145
function ListSubAgentsAction.prototype.prep(self, shared) -- 3146
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3146
		local last = shared.history[#shared.history] -- 3155
		if not last then -- 3155
			error( -- 3156
				__TS__New(Error, "no history"), -- 3156
				0 -- 3156
			) -- 3156
		end -- 3156
		emitAgentStartEvent(shared, last) -- 3157
		return ____awaiter_resolve( -- 3157
			nil, -- 3157
			{ -- 3158
				sessionId = shared.sessionId, -- 3159
				projectRoot = shared.workingDir, -- 3160
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3161
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3162
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3163
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3164
				listSubAgents = shared.listSubAgents -- 3165
			} -- 3165
		) -- 3165
	end) -- 3165
end -- 3146
function ListSubAgentsAction.prototype.exec(self, input) -- 3169
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3169
		if not input.listSubAgents then -- 3169
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3169
		end -- 3169
		if input.sessionId == nil or input.sessionId <= 0 then -- 3169
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3169
		end -- 3169
		local result = __TS__Await(input.listSubAgents({ -- 3184
			sessionId = input.sessionId, -- 3185
			projectRoot = input.projectRoot, -- 3186
			status = input.status, -- 3187
			limit = input.limit, -- 3188
			offset = input.offset, -- 3189
			query = input.query -- 3190
		})) -- 3190
		return ____awaiter_resolve(nil, result) -- 3190
	end) -- 3190
end -- 3169
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3195
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3195
		local last = shared.history[#shared.history] -- 3196
		if last ~= nil then -- 3196
			last.result = execRes -- 3198
			appendToolResultMessage(shared, last) -- 3199
			emitAgentFinishEvent(shared, last) -- 3200
		end -- 3200
		persistHistoryState(shared) -- 3202
		__TS__Await(maybeCompressHistory(shared)) -- 3203
		persistHistoryState(shared) -- 3204
		return ____awaiter_resolve(nil, "main") -- 3204
	end) -- 3204
end -- 3195
EditFileAction = __TS__Class() -- 3209
EditFileAction.name = "EditFileAction" -- 3209
__TS__ClassExtends(EditFileAction, Node) -- 3209
function EditFileAction.prototype.prep(self, shared) -- 3210
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3210
		local last = shared.history[#shared.history] -- 3211
		if not last then -- 3211
			error( -- 3212
				__TS__New(Error, "no history"), -- 3212
				0 -- 3212
			) -- 3212
		end -- 3212
		emitAgentStartEvent(shared, last) -- 3213
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3214
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3217
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3218
		if __TS__StringTrim(path) == "" then -- 3218
			error( -- 3219
				__TS__New(Error, "missing path"), -- 3219
				0 -- 3219
			) -- 3219
		end -- 3219
		return ____awaiter_resolve(nil, { -- 3219
			path = path, -- 3220
			oldStr = oldStr, -- 3220
			newStr = newStr, -- 3220
			taskId = shared.taskId, -- 3220
			workDir = shared.workingDir -- 3220
		}) -- 3220
	end) -- 3220
end -- 3210
function EditFileAction.prototype.exec(self, input) -- 3223
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3223
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3224
		if not readRes.success then -- 3224
			if input.oldStr ~= "" then -- 3224
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3224
			end -- 3224
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3229
			if not createRes.success then -- 3229
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3229
			end -- 3229
			return ____awaiter_resolve(nil, { -- 3229
				success = true, -- 3237
				changed = true, -- 3238
				mode = "create", -- 3239
				checkpointId = createRes.checkpointId, -- 3240
				checkpointSeq = createRes.checkpointSeq, -- 3241
				files = {{path = input.path, op = "create"}} -- 3242
			}) -- 3242
		end -- 3242
		if input.oldStr == "" then -- 3242
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3246
			if not overwriteRes.success then -- 3246
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3246
			end -- 3246
			return ____awaiter_resolve(nil, { -- 3246
				success = true, -- 3254
				changed = true, -- 3255
				mode = "overwrite", -- 3256
				checkpointId = overwriteRes.checkpointId, -- 3257
				checkpointSeq = overwriteRes.checkpointSeq, -- 3258
				files = {{path = input.path, op = "write"}} -- 3259
			}) -- 3259
		end -- 3259
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3264
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3265
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3266
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3269
		if occurrences == 0 then -- 3269
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3271
			if not indentTolerant.success then -- 3271
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3271
			end -- 3271
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3275
			if not applyRes.success then -- 3275
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3275
			end -- 3275
			return ____awaiter_resolve(nil, { -- 3275
				success = true, -- 3283
				changed = true, -- 3284
				mode = "replace_indent_tolerant", -- 3285
				checkpointId = applyRes.checkpointId, -- 3286
				checkpointSeq = applyRes.checkpointSeq, -- 3287
				files = {{path = input.path, op = "write"}} -- 3288
			}) -- 3288
		end -- 3288
		if occurrences > 1 then -- 3288
			return ____awaiter_resolve( -- 3288
				nil, -- 3288
				{ -- 3292
					success = false, -- 3292
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3292
				} -- 3292
			) -- 3292
		end -- 3292
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3296
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3297
		if not applyRes.success then -- 3297
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3297
		end -- 3297
		return ____awaiter_resolve(nil, { -- 3297
			success = true, -- 3305
			changed = true, -- 3306
			mode = "replace", -- 3307
			checkpointId = applyRes.checkpointId, -- 3308
			checkpointSeq = applyRes.checkpointSeq, -- 3309
			files = {{path = input.path, op = "write"}} -- 3310
		}) -- 3310
	end) -- 3310
end -- 3223
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3314
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3314
		local last = shared.history[#shared.history] -- 3315
		if last ~= nil then -- 3315
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3317
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3318
			appendToolResultMessage(shared, last) -- 3319
			emitAgentFinishEvent(shared, last) -- 3320
			local result = last.result -- 3321
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3321
				emitAgentEvent(shared, { -- 3326
					type = "checkpoint_created", -- 3327
					sessionId = shared.sessionId, -- 3328
					taskId = shared.taskId, -- 3329
					step = last.step, -- 3330
					tool = last.tool, -- 3331
					checkpointId = result.checkpointId, -- 3332
					checkpointSeq = result.checkpointSeq, -- 3333
					files = result.files -- 3334
				}) -- 3334
			end -- 3334
		end -- 3334
		persistHistoryState(shared) -- 3338
		__TS__Await(maybeCompressHistory(shared)) -- 3339
		persistHistoryState(shared) -- 3340
		return ____awaiter_resolve(nil, "main") -- 3340
	end) -- 3340
end -- 3314
local function emitCheckpointEventForAction(shared, action) -- 3345
	local result = action.result -- 3346
	if not result then -- 3346
		return -- 3347
	end -- 3347
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3347
		emitAgentEvent(shared, { -- 3352
			type = "checkpoint_created", -- 3353
			sessionId = shared.sessionId, -- 3354
			taskId = shared.taskId, -- 3355
			step = action.step, -- 3356
			tool = action.tool, -- 3357
			checkpointId = result.checkpointId, -- 3358
			checkpointSeq = result.checkpointSeq, -- 3359
			files = result.files -- 3360
		}) -- 3360
	end -- 3360
end -- 3345
local function canRunBatchActionInParallel(self, action) -- 3665
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 3666
end -- 3665
local function partitionToolCalls(actions) -- 3674
	local batches = {} -- 3675
	do -- 3675
		local i = 0 -- 3676
		while i < #actions do -- 3676
			local action = actions[i + 1] -- 3677
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3678
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3679
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3679
				local ____lastBatch_actions_137 = lastBatch.actions -- 3679
				____lastBatch_actions_137[#____lastBatch_actions_137 + 1] = action -- 3681
			else -- 3681
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3683
			end -- 3683
			i = i + 1 -- 3676
		end -- 3676
	end -- 3676
	return batches -- 3686
end -- 3674
local BatchToolAction = __TS__Class() -- 3689
BatchToolAction.name = "BatchToolAction" -- 3689
__TS__ClassExtends(BatchToolAction, Node) -- 3689
function BatchToolAction.prototype.prep(self, shared) -- 3690
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3690
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3690
	end) -- 3690
end -- 3690
function BatchToolAction.prototype.exec(self, input) -- 3694
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3694
		local shared = input.shared -- 3695
		local preExecuted = shared.preExecutedResults -- 3696
		local batches = partitionToolCalls(input.actions) -- 3697
		local parallelBatchCount = #__TS__ArrayFilter( -- 3698
			batches, -- 3698
			function(____, b) return b.isConcurrencySafe end -- 3698
		) -- 3698
		local serialBatchCount = #__TS__ArrayFilter( -- 3699
			batches, -- 3699
			function(____, b) return not b.isConcurrencySafe end -- 3699
		) -- 3699
		Log( -- 3700
			"Info", -- 3700
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3700
		) -- 3700
		do -- 3700
			local batchIdx = 0 -- 3702
			while batchIdx < #batches do -- 3702
				do -- 3702
					local batch = batches[batchIdx + 1] -- 3703
					if shared.stopToken.stopped then -- 3703
						for ____, action in ipairs(batch.actions) do -- 3705
							if not action.result then -- 3705
								action.result = { -- 3707
									success = false, -- 3707
									message = getCancelledReason(shared) -- 3707
								} -- 3707
							end -- 3707
						end -- 3707
						goto __continue625 -- 3710
					end -- 3710
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3710
						local preExecCount = #__TS__ArrayFilter( -- 3714
							batch.actions, -- 3714
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3714
						) -- 3714
						Log( -- 3715
							"Info", -- 3715
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3715
						) -- 3715
						do -- 3715
							local i = 0 -- 3716
							while i < #batch.actions do -- 3716
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3717
								i = i + 1 -- 3716
							end -- 3716
						end -- 3716
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3719
							batch.actions, -- 3719
							function(____, action) -- 3719
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3719
									if shared.stopToken.stopped then -- 3719
										action.result = { -- 3721
											success = false, -- 3721
											message = getCancelledReason(shared) -- 3721
										} -- 3721
										return ____awaiter_resolve(nil, action) -- 3721
									end -- 3721
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3724
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3725
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3726
									return ____awaiter_resolve(nil, action) -- 3726
								end) -- 3726
							end -- 3719
						))) -- 3719
						do -- 3719
							local i = 0 -- 3729
							while i < #batch.actions do -- 3729
								local action = batch.actions[i + 1] -- 3730
								if not action.result then -- 3730
									action.result = {success = false, message = "tool did not produce a result"} -- 3732
								end -- 3732
								appendToolResultMessage(shared, action) -- 3734
								emitAgentFinishEvent(shared, action) -- 3735
								emitCheckpointEventForAction(shared, action) -- 3736
								i = i + 1 -- 3729
							end -- 3729
						end -- 3729
					else -- 3729
						Log( -- 3739
							"Info", -- 3739
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3739
						) -- 3739
						do -- 3739
							local i = 0 -- 3740
							while i < #batch.actions do -- 3740
								local action = batch.actions[i + 1] -- 3741
								emitAgentStartEvent(shared, action) -- 3742
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3743
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3744
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3745
								appendToolResultMessage(shared, action) -- 3746
								emitAgentFinishEvent(shared, action) -- 3747
								emitCheckpointEventForAction(shared, action) -- 3748
								persistHistoryState(shared) -- 3749
								if shared.stopToken.stopped then -- 3749
									break -- 3751
								end -- 3751
								i = i + 1 -- 3740
							end -- 3740
						end -- 3740
					end -- 3740
				end -- 3740
				::__continue625:: -- 3740
				batchIdx = batchIdx + 1 -- 3702
			end -- 3702
		end -- 3702
		persistHistoryState(shared) -- 3756
		return ____awaiter_resolve(nil, input.actions) -- 3756
	end) -- 3756
end -- 3694
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3760
		shared.pendingToolActions = nil -- 3761
		shared.preExecutedResults = nil -- 3762
		persistHistoryState(shared) -- 3763
		__TS__Await(maybeCompressHistory(shared)) -- 3764
		persistHistoryState(shared) -- 3765
		return ____awaiter_resolve(nil, "main") -- 3765
	end) -- 3765
end -- 3760
local EndNode = __TS__Class() -- 3770
EndNode.name = "EndNode" -- 3770
__TS__ClassExtends(EndNode, Node) -- 3770
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3771
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3771
		return ____awaiter_resolve(nil, nil) -- 3771
	end) -- 3771
end -- 3771
local CodingAgentFlow = __TS__Class() -- 3776
CodingAgentFlow.name = "CodingAgentFlow" -- 3776
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3776
function CodingAgentFlow.prototype.____constructor(self, role) -- 3777
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3778
	local read = __TS__New(ReadFileAction, 1, 0) -- 3779
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3780
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3781
	local list = __TS__New(ListFilesAction, 1, 0) -- 3782
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3783
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3784
	local build = __TS__New(BuildAction, 1, 0) -- 3785
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3786
	local edit = __TS__New(EditFileAction, 1, 0) -- 3787
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3788
	local done = __TS__New(EndNode, 1, 0) -- 3789
	main:on("batch_tools", batch) -- 3791
	main:on("grep_files", search) -- 3792
	main:on("search_dora_api", searchDora) -- 3793
	main:on("glob_files", list) -- 3794
	if role == "main" then -- 3794
		main:on("read_file", read) -- 3796
		main:on("delete_file", del) -- 3797
		main:on("build", build) -- 3798
		main:on("edit_file", edit) -- 3799
		main:on("list_sub_agents", listSub) -- 3800
		main:on("spawn_sub_agent", spawn) -- 3801
	else -- 3801
		main:on("read_file", read) -- 3803
		main:on("delete_file", del) -- 3804
		main:on("build", build) -- 3805
		main:on("edit_file", edit) -- 3806
	end -- 3806
	main:on("done", done) -- 3808
	search:on("main", main) -- 3810
	searchDora:on("main", main) -- 3811
	list:on("main", main) -- 3812
	listSub:on("main", main) -- 3813
	spawn:on("main", main) -- 3814
	batch:on("main", main) -- 3815
	read:on("main", main) -- 3816
	del:on("main", main) -- 3817
	build:on("main", main) -- 3818
	edit:on("main", main) -- 3819
	Flow.prototype.____constructor(self, main) -- 3821
end -- 3777
local function runCodingAgentAsync(options) -- 3843
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3843
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3843
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3843
		end -- 3843
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3847
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3848
		if not llmConfigRes.success then -- 3848
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3848
		end -- 3848
		local llmConfig = llmConfigRes.config -- 3854
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3855
		if not taskRes.success then -- 3855
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3855
		end -- 3855
		local compressor = __TS__New(MemoryCompressor, { -- 3862
			compressionThreshold = 0.8, -- 3863
			compressionTargetThreshold = 0.5, -- 3864
			maxCompressionRounds = 3, -- 3865
			projectDir = options.workDir, -- 3866
			llmConfig = llmConfig, -- 3867
			promptPack = options.promptPack, -- 3868
			scope = options.memoryScope -- 3869
		}) -- 3869
		local persistedSession = compressor:getStorage():readSessionState() -- 3871
		local promptPack = compressor:getPromptPack() -- 3872
		local shared = { -- 3874
			sessionId = options.sessionId, -- 3875
			taskId = taskRes.taskId, -- 3876
			role = options.role or "main", -- 3877
			maxSteps = math.max( -- 3878
				1, -- 3878
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3878
			), -- 3878
			llmMaxTry = math.max( -- 3879
				1, -- 3879
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3879
			), -- 3879
			step = 0, -- 3880
			done = false, -- 3881
			stopToken = options.stopToken or ({stopped = false}), -- 3882
			response = "", -- 3883
			userQuery = normalizedPrompt, -- 3884
			workingDir = options.workDir, -- 3885
			useChineseResponse = options.useChineseResponse == true, -- 3886
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3887
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3890
			llmConfig = llmConfig, -- 3891
			onEvent = options.onEvent, -- 3892
			promptPack = promptPack, -- 3893
			history = {}, -- 3894
			messages = persistedSession.messages, -- 3895
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3896
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3897
			memory = {compressor = compressor}, -- 3899
			skills = {loader = AgentSkills.createSkillsLoader({projectDir = options.workDir})}, -- 3903
			spawnSubAgent = options.spawnSubAgent, -- 3908
			listSubAgents = options.listSubAgents -- 3909
		} -- 3909
		local ____hasReturned, ____returnValue -- 3909
		local ____try = __TS__AsyncAwaiter(function() -- 3909
			emitAgentEvent(shared, { -- 3913
				type = "task_started", -- 3914
				sessionId = shared.sessionId, -- 3915
				taskId = shared.taskId, -- 3916
				prompt = shared.userQuery, -- 3917
				workDir = shared.workingDir, -- 3918
				maxSteps = shared.maxSteps -- 3919
			}) -- 3919
			if shared.stopToken.stopped then -- 3919
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3922
				____hasReturned = true -- 3923
				____returnValue = emitAgentTaskFinishEvent( -- 3923
					shared, -- 3923
					false, -- 3923
					getCancelledReason(shared) -- 3923
				) -- 3923
				return -- 3923
			end -- 3923
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3925
			local promptCommand = getPromptCommand(shared.userQuery) -- 3926
			if promptCommand == "clear" then -- 3926
				____hasReturned = true -- 3928
				____returnValue = clearSessionHistory(shared) -- 3928
				return -- 3928
			end -- 3928
			if promptCommand == "compact" then -- 3928
				if shared.role == "sub" then -- 3928
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3932
					____hasReturned = true -- 3933
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3933
					return -- 3933
				end -- 3933
				____hasReturned = true -- 3941
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 3941
				return -- 3941
			end -- 3941
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3943
			persistHistoryState(shared) -- 3947
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3948
			__TS__Await(flow:run(shared)) -- 3949
			if shared.stopToken.stopped then -- 3949
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3951
				____hasReturned = true -- 3952
				____returnValue = emitAgentTaskFinishEvent( -- 3952
					shared, -- 3952
					false, -- 3952
					getCancelledReason(shared) -- 3952
				) -- 3952
				return -- 3952
			end -- 3952
			if shared.error then -- 3952
				____hasReturned = true -- 3955
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3955
				return -- 3955
			end -- 3955
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3958
			____hasReturned = true -- 3959
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3959
			return -- 3959
		end) -- 3959
		____try = ____try.catch( -- 3959
			____try, -- 3959
			function(____, e) -- 3959
				return __TS__AsyncAwaiter(function() -- 3959
					____hasReturned = true -- 3962
					____returnValue = finalizeAgentFailure( -- 3962
						shared, -- 3962
						tostring(e) -- 3962
					) -- 3962
					return -- 3962
				end) -- 3962
			end -- 3962
		) -- 3962
		__TS__Await(____try) -- 3912
		if ____hasReturned then -- 3912
			return ____awaiter_resolve(nil, ____returnValue) -- 3912
		end -- 3912
	end) -- 3912
end -- 3843
function ____exports.runCodingAgent(options, callback) -- 3966
	local ____self_140 = runCodingAgentAsync(options) -- 3966
	____self_140["then"]( -- 3966
		____self_140, -- 3966
		function(____, result) return callback(result) end -- 3967
	) -- 3967
end -- 3966
return ____exports -- 3966