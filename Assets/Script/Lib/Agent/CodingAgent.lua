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
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
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
function emitAgentEvent(shared, event) -- 342
	if shared.onEvent then -- 342
		do -- 342
			local function ____catch(____error) -- 342
				Log( -- 347
					"Error", -- 347
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 347
				) -- 347
			end -- 347
			local ____try, ____hasReturned = pcall(function() -- 347
				shared:onEvent(event) -- 345
			end) -- 345
			if not ____try then -- 345
				____catch(____hasReturned) -- 345
			end -- 345
		end -- 345
	end -- 345
end -- 345
function getCancelledReason(shared) -- 476
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 476
		return shared.stopToken.reason -- 477
	end -- 477
	return shared.useChineseResponse and "已取消" or "cancelled" -- 478
end -- 478
function truncateText(text, maxLen) -- 664
	if #text <= maxLen then -- 664
		return text -- 665
	end -- 665
	local nextPos = utf8.offset(text, maxLen + 1) -- 666
	if nextPos == nil then -- 666
		return text -- 667
	end -- 667
	return string.sub(text, 1, nextPos - 1) .. "..." -- 668
end -- 668
function utf8TakeHead(text, maxChars) -- 671
	if maxChars <= 0 or text == "" then -- 671
		return "" -- 672
	end -- 672
	local nextPos = utf8.offset(text, maxChars + 1) -- 673
	if nextPos == nil then -- 673
		return text -- 674
	end -- 674
	return string.sub(text, 1, nextPos - 1) -- 675
end -- 675
function getReplyLanguageDirective(shared) -- 678
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 679
end -- 679
function replacePromptVars(template, vars) -- 684
	local output = template -- 685
	for key in pairs(vars) do -- 686
		output = table.concat( -- 687
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 687
			vars[key] or "" or "," -- 687
		) -- 687
	end -- 687
	return output -- 689
end -- 689
function limitReadContentForHistory(content, tool) -- 692
	local lines = __TS__StringSplit(content, "\n") -- 693
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 694
	local limitedByLines = overLineLimit and table.concat( -- 695
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 696
		"\n" -- 696
	) or content -- 696
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 696
		return content -- 699
	end -- 699
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 701
	local reasons = {} -- 704
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 704
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 705
	end -- 705
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 705
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 706
	end -- 706
	local hint = "Narrow the requested line range." -- 707
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 708
end -- 708
function sanitizeReadResultForHistory(tool, result) -- 723
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 723
		return result -- 725
	end -- 725
	local clone = {} -- 727
	for key in pairs(result) do -- 728
		clone[key] = result[key] -- 729
	end -- 729
	clone.content = limitReadContentForHistory(result.content, tool) -- 731
	return clone -- 732
end -- 732
function sanitizeSearchMatchesForHistory(items, maxItems) -- 735
	local shown = math.min(#items, maxItems) -- 739
	local out = {} -- 740
	do -- 740
		local i = 0 -- 741
		while i < shown do -- 741
			local row = items[i + 1] -- 742
			out[#out + 1] = { -- 743
				file = row.file, -- 744
				line = row.line, -- 745
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 746
			} -- 746
			i = i + 1 -- 741
		end -- 741
	end -- 741
	return out -- 751
end -- 751
function sanitizeSearchResultForHistory(tool, result) -- 754
	if result.success ~= true or not isArray(result.results) then -- 754
		return result -- 758
	end -- 758
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 758
		return result -- 759
	end -- 759
	local clone = {} -- 760
	for key in pairs(result) do -- 761
		clone[key] = result[key] -- 762
	end -- 762
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 764
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 765
	if tool == "grep_files" and isArray(result.groupedResults) then -- 765
		local grouped = result.groupedResults -- 770
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 771
		local sanitizedGroups = {} -- 772
		do -- 772
			local i = 0 -- 773
			while i < shown do -- 773
				local row = grouped[i + 1] -- 774
				sanitizedGroups[#sanitizedGroups + 1] = { -- 775
					file = row.file, -- 776
					totalMatches = row.totalMatches, -- 777
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 778
				} -- 778
				i = i + 1 -- 773
			end -- 773
		end -- 773
		clone.groupedResults = sanitizedGroups -- 783
	end -- 783
	return clone -- 785
end -- 785
function sanitizeListFilesResultForHistory(result) -- 788
	if result.success ~= true or not isArray(result.files) then -- 788
		return result -- 789
	end -- 789
	local clone = {} -- 790
	for key in pairs(result) do -- 791
		clone[key] = result[key] -- 792
	end -- 792
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 794
	return clone -- 795
end -- 795
function sanitizeBuildResultForHistory(result) -- 798
	if not isArray(result.messages) then -- 798
		return result -- 799
	end -- 799
	local clone = {} -- 800
	for key in pairs(result) do -- 801
		clone[key] = result[key] -- 802
	end -- 802
	local messages = result.messages -- 804
	local ordered = __TS__ArraySort( -- 805
		__TS__ArraySlice(messages), -- 805
		function(____, a, b) -- 805
			local aFailed = a.success ~= true -- 806
			local bFailed = b.success ~= true -- 807
			if aFailed == bFailed then -- 807
				return 0 -- 808
			end -- 808
			return aFailed and -1 or 1 -- 809
		end -- 805
	) -- 805
	local shown = math.min(#ordered, HISTORY_BUILD_MAX_MESSAGES) -- 811
	local sanitized = {} -- 812
	do -- 812
		local i = 0 -- 813
		while i < shown do -- 813
			local item = ordered[i + 1] -- 814
			local next = {} -- 815
			for key in pairs(item) do -- 816
				local value = item[key] -- 817
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 818
			end -- 818
			sanitized[#sanitized + 1] = next -- 822
			i = i + 1 -- 813
		end -- 813
	end -- 813
	clone.messages = sanitized -- 824
	if #ordered > shown then -- 824
		clone.truncatedMessages = #ordered - shown -- 826
	end -- 826
	return clone -- 828
end -- 828
function getDecisionToolDefinitions(shared) -- 846
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 847
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 848
	local base = shared.promptPack.toolDefinitionsDetailed -- 851
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 852
	local availableTools = __TS__ArrayFilter( -- 854
		AgentToolRegistry.getAllowedToolsForRole(shared.role, {disabledAgentTools = shared.disabledAgentTools}), -- 854
		function(____, tool) return shared.decisionMode == "xml" or tool ~= "finish" end -- 857
	) -- 857
	local availability = (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat(availableTools, ", ") -- 858
	if usesDefaultToolPrompts then -- 858
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}, disabledAgentTools = shared.disabledAgentTools}) -- 864
		return replacePromptVars(definitions .. availability, params) -- 870
	end -- 870
	local withRole = replacePromptVars((base .. mainAgentTools) .. availability, params) -- 872
	if (shared and shared.decisionMode) ~= "xml" then -- 872
		return withRole -- 877
	end -- 877
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 879
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 880
end -- 880
function getFinishMessage(params, fallback) -- 1216
	if fallback == nil then -- 1216
		fallback = "" -- 1216
	end -- 1216
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1216
		return __TS__StringTrim(params.message) -- 1218
	end -- 1218
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1218
		return __TS__StringTrim(params.response) -- 1221
	end -- 1221
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1221
		return __TS__StringTrim(params.summary) -- 1224
	end -- 1224
	return __TS__StringTrim(fallback) -- 1226
end -- 1226
function persistHistoryState(shared) -- 1229
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1230
end -- 1230
function getActiveConversationMessages(shared) -- 1237
	local activeMessages = {} -- 1238
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1238
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1245
	end -- 1245
	do -- 1245
		local i = shared.lastConsolidatedIndex -- 1249
		while i < #shared.messages do -- 1249
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1250
			i = i + 1 -- 1249
		end -- 1249
	end -- 1249
	return activeMessages -- 1252
end -- 1252
function getActiveRealMessageCount(shared) -- 1255
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1256
end -- 1256
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1259
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1264
	local previousActiveStart = shared.lastConsolidatedIndex -- 1265
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1266
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1267
	if type(carryMessageIndex) == "number" then -- 1267
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1267
		else -- 1267
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1275
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1278
		end -- 1278
	else -- 1278
		shared.carryMessageIndex = nil -- 1283
	end -- 1283
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1283
		shared.carryMessageIndex = nil -- 1293
	end -- 1293
end -- 1293
function ensureToolCallId(toolCallId) -- 1308
	if toolCallId and toolCallId ~= "" then -- 1308
		return toolCallId -- 1309
	end -- 1309
	return createLocalToolCallId() -- 1310
end -- 1310
function hasXMLParam(params, name) -- 1343
	return params[name] ~= nil -- 1344
end -- 1344
function inferToolNameFromXMLParams(params) -- 1347
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1347
		return "edit_file" -- 1349
	end -- 1349
	if hasXMLParam(params, "target_file") then -- 1349
		return "delete_file" -- 1352
	end -- 1352
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1352
		if hasXMLParam(params, "path") then -- 1352
			return "read_file" -- 1355
		end -- 1355
		return nil -- 1356
	end -- 1356
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1356
		if hasXMLParam(params, "pattern") then -- 1356
			return "search_dora_api" -- 1359
		end -- 1359
		return nil -- 1360
	end -- 1360
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1360
		if hasXMLParam(params, "pattern") then -- 1360
			return "grep_files" -- 1363
		end -- 1363
		return nil -- 1364
	end -- 1364
	if hasXMLParam(params, "globs") then -- 1364
		if hasXMLParam(params, "pattern") then -- 1364
			return "grep_files" -- 1367
		end -- 1367
		return "glob_files" -- 1368
	end -- 1368
	if hasXMLParam(params, "maxEntries") then -- 1368
		return "glob_files" -- 1371
	end -- 1371
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1371
		return "finish" -- 1374
	end -- 1374
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1374
		return "spawn_sub_agent" -- 1377
	end -- 1377
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1377
		return "list_sub_agents" -- 1380
	end -- 1380
	return nil -- 1382
end -- 1382
function parseDSMLAttribute(source, offset, name) -- 1385
	local attrOpen = name .. "=\"" -- 1386
	local attrStart = (string.find( -- 1387
		source, -- 1387
		attrOpen, -- 1387
		math.max(offset + 1, 1), -- 1387
		true -- 1387
	) or 0) - 1 -- 1387
	if attrStart < 0 then -- 1387
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1388
	end -- 1388
	local valueStart = attrStart + #attrOpen -- 1389
	local valueEnd = (string.find( -- 1390
		source, -- 1390
		"\"", -- 1390
		math.max(valueStart + 1, 1), -- 1390
		true -- 1390
	) or 0) - 1 -- 1390
	if valueEnd < 0 then -- 1390
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1391
	end -- 1391
	return { -- 1392
		success = true, -- 1393
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1394
		next = valueEnd + 1 -- 1395
	} -- 1395
end -- 1395
function extractDSMLReason(text, invokeStart, tool) -- 1399
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1400
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1401
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1401
		return before -- 1404
	end -- 1404
	if tool == "finish" then -- 1404
		return "" -- 1405
	end -- 1405
	return "Converted provider-native tool call syntax to XML." -- 1406
end -- 1406
function parseDSMLToolCallObjectFromText(text) -- 1409
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1410
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1411
	if invokeStart < 0 then -- 1411
		return {success = false, message = "missing DSML invoke"} -- 1412
	end -- 1412
	local nameStart = invokeStart + #invokeOpen -- 1413
	local nameEnd = (string.find( -- 1414
		text, -- 1414
		"\"", -- 1414
		math.max(nameStart + 1, 1), -- 1414
		true -- 1414
	) or 0) - 1 -- 1414
	if nameEnd < 0 then -- 1414
		return {success = false, message = "unterminated DSML invoke name"} -- 1415
	end -- 1415
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1416
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1416
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1418
	end -- 1418
	local invokeOpenEnd = (string.find( -- 1420
		text, -- 1420
		">", -- 1420
		math.max(nameEnd + 1, 1), -- 1420
		true -- 1420
	) or 0) - 1 -- 1420
	if invokeOpenEnd < 0 then -- 1420
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1421
	end -- 1421
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1422
	local invokeEnd = (string.find( -- 1423
		text, -- 1423
		invokeClose, -- 1423
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1423
		true -- 1423
	) or 0) - 1 -- 1423
	if invokeEnd < 0 then -- 1423
		return {success = false, message = "missing DSML invoke close tag"} -- 1424
	end -- 1424
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1426
	local params = {} -- 1427
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1428
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1429
	local pos = 0 -- 1430
	while pos < #body do -- 1430
		local start = (string.find( -- 1432
			body, -- 1432
			paramOpen, -- 1432
			math.max(pos + 1, 1), -- 1432
			true -- 1432
		) or 0) - 1 -- 1432
		if start < 0 then -- 1432
			break -- 1433
		end -- 1433
		local openEnd = (string.find( -- 1434
			body, -- 1434
			">", -- 1434
			math.max(start + #paramOpen + 1, 1), -- 1434
			true -- 1434
		) or 0) - 1 -- 1434
		if openEnd < 0 then -- 1434
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1435
		end -- 1435
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1436
		if not name.success then -- 1436
			return name -- 1437
		end -- 1437
		local close = (string.find( -- 1438
			body, -- 1438
			paramClose, -- 1438
			math.max(openEnd + 1 + 1, 1), -- 1438
			true -- 1438
		) or 0) - 1 -- 1438
		if close < 0 then -- 1438
			return {success = false, message = "missing DSML parameter close tag"} -- 1439
		end -- 1439
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1440
		pos = close + #paramClose -- 1441
	end -- 1441
	return { -- 1443
		success = true, -- 1444
		obj = { -- 1445
			tool = toolName, -- 1446
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1447
			params = params -- 1448
		} -- 1448
	} -- 1448
end -- 1448
function parseXMLToolCallObjectFromText(text) -- 1453
	local children = parseXMLObjectFromText(text, "tool_call") -- 1454
	local rawObj -- 1455
	if children.success then -- 1455
		rawObj = children.obj -- 1457
	else -- 1457
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1459
		if dsml.success then -- 1459
			return dsml -- 1460
		end -- 1460
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1461
		local paramsCloseToken = "</params>" -- 1462
		if toolStart >= 0 then -- 1462
			local paramsClose = (string.find( -- 1464
				text, -- 1464
				paramsCloseToken, -- 1464
				math.max(toolStart + 1, 1), -- 1464
				true -- 1464
			) or 0) - 1 -- 1464
			if paramsClose >= toolStart then -- 1464
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1466
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1467
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1467
					rawObj = bare.obj -- 1469
				end -- 1469
			end -- 1469
		end -- 1469
		if rawObj == nil then -- 1469
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1474
			if paramsOpen < 0 then -- 1474
				return children -- 1475
			end -- 1475
			local paramsCloseOnly = (string.find( -- 1476
				text, -- 1476
				paramsCloseToken, -- 1476
				math.max(paramsOpen + 1, 1), -- 1476
				true -- 1476
			) or 0) - 1 -- 1476
			if paramsCloseOnly < paramsOpen then -- 1476
				return children -- 1477
			end -- 1477
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1478
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1479
			if not paramsOnly.success then -- 1479
				return children -- 1480
			end -- 1480
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1481
			if inferredTool == nil then -- 1481
				return children -- 1482
			end -- 1482
			local ____temp_24 -- 1487
			if inferredTool == "finish" then -- 1487
				____temp_24 = nil -- 1487
			else -- 1487
				____temp_24 = "Inferred tool from XML params." -- 1487
			end -- 1487
			return {success = true, obj = {tool = inferredTool, reason = ____temp_24, params = paramsOnly.obj}} -- 1483
		end -- 1483
	end -- 1483
	if rawObj == nil then -- 1483
		return children -- 1493
	end -- 1493
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1494
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1495
	if not params.success then -- 1495
		return {success = false, message = params.message} -- 1499
	end -- 1499
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1501
end -- 1501
function parseDecisionObject(rawObj) -- 1593
	if type(rawObj.tool) ~= "string" then -- 1593
		return {success = false, message = "missing tool"} -- 1594
	end -- 1594
	local tool = rawObj.tool -- 1595
	if not AgentToolRegistry.isKnownToolName(tool) then -- 1595
		return {success = false, message = "unknown tool: " .. tool} -- 1597
	end -- 1597
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1599
	if tool ~= "finish" and (not reason or reason == "") then -- 1599
		return {success = false, message = tool .. " requires top-level reason"} -- 1603
	end -- 1603
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1605
	return {success = true, tool = tool, params = params, reason = reason} -- 1606
end -- 1606
function getDecisionPath(params) -- 1719
	if type(params.path) == "string" then -- 1719
		return __TS__StringTrim(params.path) -- 1720
	end -- 1720
	if type(params.target_file) == "string" then -- 1720
		return __TS__StringTrim(params.target_file) -- 1721
	end -- 1721
	return "" -- 1722
end -- 1722
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1725
	local num = __TS__Number(value) -- 1726
	if not __TS__NumberIsFinite(num) then -- 1726
		num = fallback -- 1727
	end -- 1727
	num = math.floor(num) -- 1728
	if num < minValue then -- 1728
		num = minValue -- 1729
	end -- 1729
	if maxValue ~= nil and num > maxValue then -- 1729
		num = maxValue -- 1730
	end -- 1730
	return num -- 1731
end -- 1731
function parseReadLineParam(value, fallback, paramName) -- 1734
	local num = __TS__Number(value) -- 1739
	if not __TS__NumberIsFinite(num) then -- 1739
		num = fallback -- 1740
	end -- 1740
	num = math.floor(num) -- 1741
	if num == 0 then -- 1741
		return {success = false, message = paramName .. " cannot be 0"} -- 1743
	end -- 1743
	return {success = true, value = num} -- 1745
end -- 1745
function validateDecision(tool, params) -- 1748
	if tool == "finish" then -- 1748
		local message = getFinishMessage(params) -- 1753
		if message == "" then -- 1753
			return {success = false, message = "finish requires params.message"} -- 1754
		end -- 1754
		params.message = message -- 1755
		return {success = true, params = params} -- 1756
	end -- 1756
	if tool == "read_file" then -- 1756
		local path = getDecisionPath(params) -- 1760
		if path == "" then -- 1760
			return {success = false, message = "read_file requires path"} -- 1761
		end -- 1761
		params.path = path -- 1762
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1763
		if not startLineRes.success then -- 1763
			return startLineRes -- 1764
		end -- 1764
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1765
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1766
		if not endLineRes.success then -- 1766
			return endLineRes -- 1767
		end -- 1767
		params.startLine = startLineRes.value -- 1768
		params.endLine = endLineRes.value -- 1769
		return {success = true, params = params} -- 1770
	end -- 1770
	if tool == "edit_file" then -- 1770
		local path = getDecisionPath(params) -- 1774
		if path == "" then -- 1774
			return {success = false, message = "edit_file requires path"} -- 1775
		end -- 1775
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1776
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1777
		params.path = path -- 1778
		params.old_str = oldStr -- 1779
		params.new_str = newStr -- 1780
		return {success = true, params = params} -- 1781
	end -- 1781
	if tool == "delete_file" then -- 1781
		local targetFile = getDecisionPath(params) -- 1785
		if targetFile == "" then -- 1785
			return {success = false, message = "delete_file requires target_file"} -- 1786
		end -- 1786
		params.target_file = targetFile -- 1787
		return {success = true, params = params} -- 1788
	end -- 1788
	if tool == "grep_files" then -- 1788
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1792
		if pattern == "" then -- 1792
			return {success = false, message = "grep_files requires pattern"} -- 1793
		end -- 1793
		params.pattern = pattern -- 1794
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1795
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1796
		return {success = true, params = params} -- 1797
	end -- 1797
	if tool == "search_dora_api" then -- 1797
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1801
		if pattern == "" then -- 1801
			return {success = false, message = "search_dora_api requires pattern"} -- 1802
		end -- 1802
		params.pattern = pattern -- 1803
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1804
		return {success = true, params = params} -- 1805
	end -- 1805
	if tool == "glob_files" then -- 1805
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1809
		return {success = true, params = params} -- 1810
	end -- 1810
	if tool == "build" then -- 1810
		local path = getDecisionPath(params) -- 1814
		if path ~= "" then -- 1814
			params.path = path -- 1816
		end -- 1816
		return {success = true, params = params} -- 1818
	end -- 1818
	if tool == "list_sub_agents" then -- 1818
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1822
		if status ~= "" then -- 1822
			params.status = status -- 1824
		end -- 1824
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1826
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1827
		if type(params.query) == "string" then -- 1827
			params.query = __TS__StringTrim(params.query) -- 1829
		end -- 1829
		return {success = true, params = params} -- 1831
	end -- 1831
	if tool == "spawn_sub_agent" then -- 1831
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1835
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1836
		if prompt == "" then -- 1836
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1837
		end -- 1837
		if title == "" then -- 1837
			return {success = false, message = "spawn_sub_agent requires title"} -- 1838
		end -- 1838
		params.prompt = prompt -- 1839
		params.title = title -- 1840
		if type(params.expectedOutput) == "string" then -- 1840
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1842
		end -- 1842
		if isArray(params.filesHint) then -- 1842
			params.filesHint = __TS__ArrayMap( -- 1845
				__TS__ArrayFilter( -- 1845
					params.filesHint, -- 1845
					function(____, item) return type(item) == "string" end -- 1846
				), -- 1846
				function(____, item) return sanitizeUTF8(item) end -- 1847
			) -- 1847
		end -- 1847
		return {success = true, params = params} -- 1849
	end -- 1849
	return {success = true, params = params} -- 1852
end -- 1852
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1855
	if includeToolDefinitions == nil then -- 1855
		includeToolDefinitions = false -- 1855
	end -- 1855
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 1856
	local sections = { -- 1859
		shared.promptPack.agentIdentityPrompt, -- 1860
		rolePrompt, -- 1861
		getReplyLanguageDirective(shared) -- 1862
	} -- 1862
	if shared.decisionMode == "tool_calling" then -- 1862
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 1865
	end -- 1865
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 1867
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 1868
	if memoryContext ~= "" then -- 1868
		sections[#sections + 1] = memoryContext -- 1870
	end -- 1870
	local skillsSection = buildSkillsSection(shared) -- 1872
	if skillsSection ~= "" then -- 1872
		sections[#sections + 1] = skillsSection -- 1874
	end -- 1874
	if includeToolDefinitions then -- 1874
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1877
		if shared.decisionMode == "xml" then -- 1877
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1879
		end -- 1879
	end -- 1879
	return table.concat(sections, "\n\n") -- 1882
end -- 1882
function buildSkillsSection(shared) -- 1885
	local ____opt_43 = shared.skills -- 1885
	if not (____opt_43 and ____opt_43.loader) then -- 1885
		return "" -- 1887
	end -- 1887
	return shared.skills.loader:buildSkillsPromptSection() -- 1889
end -- 1889
function buildXmlDecisionInstruction(shared, feedback) -- 2016
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2017
end -- 2017
function tryParseAndValidateDecision(rawText) -- 2084
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2085
	if not parsed.success then -- 2085
		return {success = false, message = parsed.message, raw = rawText} -- 2087
	end -- 2087
	local decision = parseDecisionObject(parsed.obj) -- 2089
	if not decision.success then -- 2089
		return {success = false, message = decision.message, raw = rawText} -- 2091
	end -- 2091
	local validation = validateDecision(decision.tool, decision.params) -- 2093
	if not validation.success then -- 2093
		return {success = false, message = validation.message, raw = rawText} -- 2095
	end -- 2095
	decision.params = validation.params -- 2097
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2098
	return decision -- 2099
end -- 2099
function executeToolAction(shared, action) -- 3431
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3431
		if shared.stopToken.stopped then -- 3431
			return ____awaiter_resolve( -- 3431
				nil, -- 3431
				{ -- 3433
					success = false, -- 3433
					message = getCancelledReason(shared) -- 3433
				} -- 3433
			) -- 3433
		end -- 3433
		local params = action.params -- 3435
		if action.tool == "read_file" then -- 3435
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3437
			if __TS__StringTrim(path) == "" then -- 3437
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3437
			end -- 3437
			local ____Tools_readFile_107 = Tools.readFile -- 3441
			local ____shared_workingDir_105 = shared.workingDir -- 3442
			local ____params_startLine_103 = params.startLine -- 3444
			if ____params_startLine_103 == nil then -- 3444
				____params_startLine_103 = 1 -- 3444
			end -- 3444
			local ____TS__Number_result_106 = __TS__Number(____params_startLine_103) -- 3444
			local ____params_endLine_104 = params.endLine -- 3445
			if ____params_endLine_104 == nil then -- 3445
				____params_endLine_104 = READ_FILE_DEFAULT_LIMIT -- 3445
			end -- 3445
			return ____awaiter_resolve( -- 3445
				nil, -- 3445
				____Tools_readFile_107( -- 3441
					____shared_workingDir_105, -- 3442
					path, -- 3443
					____TS__Number_result_106, -- 3444
					__TS__Number(____params_endLine_104), -- 3445
					shared.useChineseResponse and "zh" or "en" -- 3446
				) -- 3446
			) -- 3446
		end -- 3446
		if action.tool == "grep_files" then -- 3446
			local ____Tools_searchFiles_121 = Tools.searchFiles -- 3450
			local ____shared_workingDir_114 = shared.workingDir -- 3451
			local ____temp_115 = params.path or "" -- 3452
			local ____temp_116 = params.pattern or "" -- 3453
			local ____params_globs_117 = params.globs -- 3454
			local ____params_useRegex_118 = params.useRegex -- 3455
			local ____params_caseSensitive_119 = params.caseSensitive -- 3456
			local ____math_max_110 = math.max -- 3459
			local ____math_floor_109 = math.floor -- 3459
			local ____params_limit_108 = params.limit -- 3459
			if ____params_limit_108 == nil then -- 3459
				____params_limit_108 = SEARCH_FILES_LIMIT_DEFAULT -- 3459
			end -- 3459
			local ____math_max_110_result_120 = ____math_max_110( -- 3459
				1, -- 3459
				____math_floor_109(__TS__Number(____params_limit_108)) -- 3459
			) -- 3459
			local ____math_max_113 = math.max -- 3460
			local ____math_floor_112 = math.floor -- 3460
			local ____params_offset_111 = params.offset -- 3460
			if ____params_offset_111 == nil then -- 3460
				____params_offset_111 = 0 -- 3460
			end -- 3460
			local result = __TS__Await(____Tools_searchFiles_121({ -- 3450
				workDir = ____shared_workingDir_114, -- 3451
				path = ____temp_115, -- 3452
				pattern = ____temp_116, -- 3453
				globs = ____params_globs_117, -- 3454
				useRegex = ____params_useRegex_118, -- 3455
				caseSensitive = ____params_caseSensitive_119, -- 3456
				includeContent = true, -- 3457
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3458
				limit = ____math_max_110_result_120, -- 3459
				offset = ____math_max_113( -- 3460
					0, -- 3460
					____math_floor_112(__TS__Number(____params_offset_111)) -- 3460
				), -- 3460
				groupByFile = params.groupByFile == true -- 3461
			})) -- 3461
			return ____awaiter_resolve(nil, result) -- 3461
		end -- 3461
		if action.tool == "search_dora_api" then -- 3461
			local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3466
			local ____temp_125 = params.pattern or "" -- 3467
			local ____temp_126 = params.docSource or "api" -- 3468
			local ____temp_127 = shared.useChineseResponse and "zh" or "en" -- 3469
			local ____temp_128 = params.programmingLanguage or "ts" -- 3470
			local ____math_min_124 = math.min -- 3471
			local ____math_max_123 = math.max -- 3471
			local ____params_limit_122 = params.limit -- 3471
			if ____params_limit_122 == nil then -- 3471
				____params_limit_122 = 8 -- 3471
			end -- 3471
			local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3466
				pattern = ____temp_125, -- 3467
				docSource = ____temp_126, -- 3468
				docLanguage = ____temp_127, -- 3469
				programmingLanguage = ____temp_128, -- 3470
				limit = ____math_min_124( -- 3471
					SEARCH_DORA_API_LIMIT_MAX, -- 3471
					____math_max_123( -- 3471
						1, -- 3471
						__TS__Number(____params_limit_122) -- 3471
					) -- 3471
				), -- 3471
				useRegex = params.useRegex, -- 3472
				caseSensitive = false, -- 3473
				includeContent = true, -- 3474
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3475
			})) -- 3475
			return ____awaiter_resolve(nil, result) -- 3475
		end -- 3475
		if action.tool == "glob_files" then -- 3475
			local ____Tools_listFiles_136 = Tools.listFiles -- 3480
			local ____shared_workingDir_133 = shared.workingDir -- 3481
			local ____temp_134 = params.path or "" -- 3482
			local ____params_globs_135 = params.globs -- 3483
			local ____math_max_132 = math.max -- 3484
			local ____math_floor_131 = math.floor -- 3484
			local ____params_maxEntries_130 = params.maxEntries -- 3484
			if ____params_maxEntries_130 == nil then -- 3484
				____params_maxEntries_130 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3484
			end -- 3484
			local result = ____Tools_listFiles_136({ -- 3480
				workDir = ____shared_workingDir_133, -- 3481
				path = ____temp_134, -- 3482
				globs = ____params_globs_135, -- 3483
				maxEntries = ____math_max_132( -- 3484
					1, -- 3484
					____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3484
				) -- 3484
			}) -- 3484
			return ____awaiter_resolve(nil, result) -- 3484
		end -- 3484
		if action.tool == "delete_file" then -- 3484
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3489
			if __TS__StringTrim(targetFile) == "" then -- 3489
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3489
			end -- 3489
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3493
			if not result.success then -- 3493
				return ____awaiter_resolve(nil, result) -- 3493
			end -- 3493
			return ____awaiter_resolve(nil, { -- 3493
				success = true, -- 3501
				changed = true, -- 3502
				mode = "delete", -- 3503
				checkpointId = result.checkpointId, -- 3504
				checkpointSeq = result.checkpointSeq, -- 3505
				files = {{path = targetFile, op = "delete"}} -- 3506
			}) -- 3506
		end -- 3506
		if action.tool == "build" then -- 3506
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3510
			return ____awaiter_resolve(nil, result) -- 3510
		end -- 3510
		if action.tool == "fetch_url" then -- 3510
			if __TS__ArrayIndexOf(shared.disabledAgentTools, "fetch_url") >= 0 then -- 3510
				return ____awaiter_resolve(nil, {success = false, state = "failed", message = "fetch_url is not enabled for this session"}) -- 3510
			end -- 3510
			local result = __TS__Await(Tools.fetchUrl({ -- 3520
				workDir = shared.workingDir, -- 3521
				url = type(params.url) == "string" and params.url or "", -- 3522
				target = type(params.target) == "string" and params.target or "", -- 3523
				isCancelled = function() return shared.stopToken.stopped == true end, -- 3524
				onProgress = function(____, progress) -- 3525
					emitAgentEvent( -- 3526
						shared, -- 3526
						{ -- 3526
							type = "tool_progress", -- 3527
							sessionId = shared.sessionId, -- 3528
							taskId = shared.taskId, -- 3529
							step = action.step, -- 3530
							tool = action.tool, -- 3531
							result = __TS__ObjectAssign({success = false}, progress) -- 3532
						} -- 3532
					) -- 3532
				end -- 3525
			})) -- 3525
			return ____awaiter_resolve(nil, result) -- 3525
		end -- 3525
		if action.tool == "execute_command" then -- 3525
			if __TS__ArrayIndexOf(shared.disabledAgentTools, "execute_command") >= 0 then -- 3525
				return ____awaiter_resolve(nil, {success = false, message = "execute_command is not enabled for this session"}) -- 3525
			end -- 3525
			local mode = type(params.mode) == "string" and params.mode or "" -- 3545
			local result = __TS__Await(Tools.executeCommand({ -- 3546
				workDir = shared.workingDir, -- 3547
				mode = mode, -- 3548
				code = type(params.code) == "string" and params.code or nil, -- 3549
				command = type(params.command) == "string" and params.command or nil, -- 3550
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 3551
				isCancelled = function() return shared.stopToken.stopped == true end, -- 3552
				onProgress = function(____, progress) -- 3553
					emitAgentEvent( -- 3554
						shared, -- 3554
						{ -- 3554
							type = "tool_progress", -- 3555
							sessionId = shared.sessionId, -- 3556
							taskId = shared.taskId, -- 3557
							step = action.step, -- 3558
							tool = action.tool, -- 3559
							result = __TS__ObjectAssign({success = false}, progress) -- 3560
						} -- 3560
					) -- 3560
				end -- 3553
			})) -- 3553
			return ____awaiter_resolve(nil, result) -- 3553
		end -- 3553
		if action.tool == "spawn_sub_agent" then -- 3553
			if not shared.spawnSubAgent then -- 3553
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3553
			end -- 3553
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3553
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3553
			end -- 3553
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3576
				params.filesHint, -- 3577
				function(____, item) return type(item) == "string" end -- 3577
			) or nil -- 3577
			local result = __TS__Await(shared.spawnSubAgent({ -- 3579
				parentSessionId = shared.sessionId, -- 3580
				projectRoot = shared.workingDir, -- 3581
				title = type(params.title) == "string" and params.title or "Sub", -- 3582
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3583
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3584
				filesHint = filesHint, -- 3585
				disabledAgentTools = shared.disabledAgentTools -- 3586
			})) -- 3586
			if not result.success then -- 3586
				return ____awaiter_resolve(nil, result) -- 3586
			end -- 3586
			return ____awaiter_resolve(nil, { -- 3586
				success = true, -- 3592
				sessionId = result.sessionId, -- 3593
				taskId = result.taskId, -- 3594
				title = result.title, -- 3595
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3596
			}) -- 3596
		end -- 3596
		if action.tool == "list_sub_agents" then -- 3596
			if not shared.listSubAgents then -- 3596
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3596
			end -- 3596
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3596
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3596
			end -- 3596
			local result = __TS__Await(shared.listSubAgents({ -- 3606
				sessionId = shared.sessionId, -- 3607
				projectRoot = shared.workingDir, -- 3608
				status = type(params.status) == "string" and params.status or nil, -- 3609
				limit = type(params.limit) == "number" and params.limit or nil, -- 3610
				offset = type(params.offset) == "number" and params.offset or nil, -- 3611
				query = type(params.query) == "string" and params.query or nil -- 3612
			})) -- 3612
			return ____awaiter_resolve(nil, result) -- 3612
		end -- 3612
		if action.tool == "edit_file" then -- 3612
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3617
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3620
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3621
			if __TS__StringTrim(path) == "" then -- 3621
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3621
			end -- 3621
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3623
			return ____awaiter_resolve( -- 3623
				nil, -- 3623
				actionNode:exec({ -- 3624
					path = path, -- 3625
					oldStr = oldStr, -- 3626
					newStr = newStr, -- 3627
					taskId = shared.taskId, -- 3628
					workDir = shared.workingDir -- 3629
				}) -- 3629
			) -- 3629
		end -- 3629
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3629
	end) -- 3629
end -- 3629
function sanitizeToolActionResultForHistory(action, result) -- 3635
	if action.tool == "read_file" then -- 3635
		return sanitizeReadResultForHistory(action.tool, result) -- 3637
	end -- 3637
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3637
		return sanitizeSearchResultForHistory(action.tool, result) -- 3640
	end -- 3640
	if action.tool == "glob_files" then -- 3640
		return sanitizeListFilesResultForHistory(result) -- 3643
	end -- 3643
	if action.tool == "build" then -- 3643
		return sanitizeBuildResultForHistory(result) -- 3646
	end -- 3646
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3646
		if result.success ~= true then -- 3646
			return result -- 3649
		end -- 3649
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3649
			return result -- 3650
		end -- 3650
		if isArray(result.fileContext) then -- 3650
			return result -- 3651
		end -- 3651
		local contextLimits = { -- 3653
			fullContentChars = 12000, -- 3654
			previewChars = 4000, -- 3655
			diffChars = 8000, -- 3656
			totalChars = 24000, -- 3657
			maxFiles = 8 -- 3658
		} -- 3658
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3660
			if maxChars <= 0 then -- 3660
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3661
			end -- 3661
			if #sourceText <= maxChars then -- 3661
				return sourceText -- 3662
			end -- 3662
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3663
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3664
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3665
		end -- 3660
		local function countLines(sourceText) -- 3667
			if sourceText == "" then -- 3667
				return 0 -- 3668
			end -- 3668
			return #__TS__StringSplit(sourceText, "\n") -- 3669
		end -- 3667
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3671
			if beforeContent == afterContent then -- 3671
				return "" -- 3672
			end -- 3672
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3673
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3674
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3676
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3676
				firstChangedLine = firstChangedLine + 1 -- 3682
			end -- 3682
			local lastChangedBeforeLine = #beforeLines - 1 -- 3684
			local lastChangedAfterLine = #afterLines - 1 -- 3685
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3685
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3691
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3692
			end -- 3692
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3694
			local previewEndLine = math.max( -- 3695
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3696
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3697
			) -- 3697
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3699
			do -- 3699
				local lineIndex = previewStartLine -- 3700
				while lineIndex <= previewEndLine do -- 3700
					do -- 3700
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3701
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3702
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3703
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3704
						if not beforeChanged and not afterChanged then -- 3704
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3706
							if contextLine ~= nil then -- 3706
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3707
							end -- 3707
							goto __continue614 -- 3708
						end -- 3708
						if beforeChanged and beforeLine ~= nil then -- 3708
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3710
						end -- 3710
						if afterChanged and afterLine ~= nil then -- 3710
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3711
						end -- 3711
					end -- 3711
					::__continue614:: -- 3711
					lineIndex = lineIndex + 1 -- 3700
				end -- 3700
			end -- 3700
			return truncateContextSnippet( -- 3713
				table.concat(unifiedDiffLines, "\n"), -- 3713
				maxChars, -- 3713
				"diff" -- 3713
			) -- 3713
		end -- 3671
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3716
		if not checkpointDiff.success then -- 3716
			return result -- 3717
		end -- 3717
		local remainingContextBudget = contextLimits.totalChars -- 3718
		local fileContextItems = {} -- 3719
		local changedFiles = checkpointDiff.files -- 3720
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3721
		do -- 3721
			local fileIndex = 0 -- 3722
			while fileIndex < maxContextFiles do -- 3722
				if remainingContextBudget <= 0 then -- 3722
					break -- 3723
				end -- 3723
				local changedFile = changedFiles[fileIndex + 1] -- 3724
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3725
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3726
				local contextItem = { -- 3727
					path = changedFile.path, -- 3728
					op = changedFile.op, -- 3729
					checkpointId = result.checkpointId, -- 3730
					checkpointSeq = result.checkpointSeq, -- 3731
					beforeExists = changedFile.beforeExists, -- 3732
					afterExists = changedFile.afterExists, -- 3733
					beforeBytes = #beforeContent, -- 3734
					afterBytes = #afterContent, -- 3735
					diffPreview = "", -- 3736
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3737
					contentTruncated = false, -- 3738
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3739
				} -- 3739
				if changedFile.afterExists then -- 3739
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3739
						contextItem.afterContent = afterContent -- 3743
						remainingContextBudget = remainingContextBudget - #afterContent -- 3744
					else -- 3744
						contextItem.afterContentPreview = truncateContextSnippet( -- 3746
							afterContent, -- 3747
							math.min( -- 3748
								contextLimits.previewChars, -- 3748
								math.max(400, remainingContextBudget) -- 3748
							), -- 3748
							"afterContent" -- 3749
						) -- 3749
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3751
						contextItem.contentTruncated = true -- 3752
					end -- 3752
				end -- 3752
				local diffPreview = buildUnifiedDiffPreview( -- 3755
					changedFile.path, -- 3756
					beforeContent, -- 3757
					afterContent, -- 3758
					math.min( -- 3759
						contextLimits.diffChars, -- 3759
						math.max(400, remainingContextBudget) -- 3759
					) -- 3759
				) -- 3759
				contextItem.diffPreview = diffPreview -- 3761
				remainingContextBudget = remainingContextBudget - #diffPreview -- 3762
				if not changedFile.afterExists and beforeContent ~= "" then -- 3762
					contextItem.beforeContentPreview = truncateContextSnippet( -- 3764
						beforeContent, -- 3765
						math.min( -- 3766
							contextLimits.previewChars, -- 3766
							math.max(400, remainingContextBudget) -- 3766
						), -- 3766
						"beforeContent" -- 3767
					) -- 3767
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 3769
					if #beforeContent > contextLimits.previewChars then -- 3769
						contextItem.contentTruncated = true -- 3770
					end -- 3770
				end -- 3770
				fileContextItems[#fileContextItems + 1] = contextItem -- 3772
				fileIndex = fileIndex + 1 -- 3722
			end -- 3722
		end -- 3722
		if #fileContextItems == 0 then -- 3722
			return result -- 3774
		end -- 3774
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 3775
	end -- 3775
	return result -- 3782
end -- 3782
function emitAgentTaskFinishEvent(shared, success, message) -- 3950
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3951
	emitAgentEvent(shared, { -- 3957
		type = "task_finished", -- 3958
		sessionId = shared.sessionId, -- 3959
		taskId = shared.taskId, -- 3960
		success = result.success, -- 3961
		message = result.message, -- 3962
		steps = result.steps -- 3963
	}) -- 3963
	return result -- 3965
end -- 3965
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 105
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 230
HISTORY_READ_FILE_MAX_LINES = 300 -- 231
READ_FILE_DEFAULT_LIMIT = 300 -- 232
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 233
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 234
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 235
HISTORY_BUILD_MAX_MESSAGES = 50 -- 236
HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 237
SEARCH_DORA_API_LIMIT_MAX = 20 -- 238
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 239
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 240
SEARCH_PREVIEW_CONTEXT = 80 -- 241
local AGENT_DEFAULT_MAX_STEPS = 100 -- 242
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 243
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 244
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 245
local function buildLLMOptions(llmConfig, overrides) -- 247
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 248
	if llmConfig.reasoningEffort then -- 248
		options.reasoning_effort = llmConfig.reasoningEffort -- 253
	end -- 253
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 255
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 255
		__TS__Delete(merged, "reasoning_effort") -- 260
	else -- 260
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 262
	end -- 262
	return merged -- 264
end -- 247
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 352
	local messagesTokens = 0 -- 359
	do -- 359
		local i = 0 -- 360
		while i < #messages do -- 360
			local message = messages[i + 1] -- 361
			messagesTokens = messagesTokens + 8 -- 362
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 363
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 364
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 365
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 366
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 367
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 368
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 369
			i = i + 1 -- 360
		end -- 360
	end -- 360
	local toolDefinitionsTokens = 0 -- 372
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 372
		local toolsText = safeJsonEncode(options.tools) -- 374
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 375
	end -- 375
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 378
	__TS__Delete(optionsWithoutTools, "tools") -- 379
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 380
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 381
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 382
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 383
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 388
		1024, -- 390
		math.floor(contextWindow * 0.2) -- 390
	) -- 390
	local structuralOverhead = math.max(256, #messages * 16) -- 391
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 393
	local maxTokens = contextWindow -- 394
	emitAgentEvent( -- 395
		shared, -- 395
		{ -- 395
			type = "metrics_updated", -- 396
			sessionId = shared.sessionId, -- 397
			taskId = shared.taskId, -- 398
			step = step, -- 399
			metrics = {context = { -- 400
				usedTokens = usedTokens, -- 402
				maxTokens = maxTokens, -- 403
				ratio = math.max( -- 404
					0, -- 404
					math.min(1, usedTokens / maxTokens) -- 404
				), -- 404
				messagesTokens = messagesTokens, -- 405
				optionsTokens = optionsTokens, -- 406
				toolDefinitionsTokens = toolDefinitionsTokens, -- 407
				reservedOutputTokens = reservedOutputTokens, -- 408
				structuralOverhead = structuralOverhead, -- 409
				contextWindow = contextWindow, -- 410
				source = "llm_input_estimate", -- 411
				updatedAt = os.time(), -- 412
				phase = phase, -- 413
				step = step -- 414
			}} -- 414
		} -- 414
	) -- 414
end -- 352
local function emitAgentStartEvent(shared, action) -- 420
	emitAgentEvent(shared, { -- 421
		type = "tool_started", -- 422
		sessionId = shared.sessionId, -- 423
		taskId = shared.taskId, -- 424
		step = action.step, -- 425
		tool = action.tool -- 426
	}) -- 426
end -- 420
local function emitAgentFinishEvent(shared, action) -- 430
	emitAgentEvent(shared, { -- 431
		type = "tool_finished", -- 432
		sessionId = shared.sessionId, -- 433
		taskId = shared.taskId, -- 434
		step = action.step, -- 435
		tool = action.tool, -- 436
		result = action.result or ({}) -- 437
	}) -- 437
end -- 430
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 441
	emitAgentEvent(shared, { -- 442
		type = "assistant_message_updated", -- 443
		sessionId = shared.sessionId, -- 444
		taskId = shared.taskId, -- 445
		step = shared.step + 1, -- 446
		content = content, -- 447
		reasoningContent = reasoningContent -- 448
	}) -- 448
end -- 441
local function getMemoryCompressionStartReason(shared) -- 452
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 453
end -- 452
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 458
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 459
end -- 458
local function getMemoryCompressionFailureReason(shared, ____error) -- 464
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 465
end -- 464
local function summarizeHistoryEntryPreview(text, maxChars) -- 470
	if maxChars == nil then -- 470
		maxChars = 180 -- 470
	end -- 470
	local trimmed = __TS__StringTrim(text) -- 471
	if trimmed == "" then -- 471
		return "" -- 472
	end -- 472
	return truncateText(trimmed, maxChars) -- 473
end -- 470
local function getMaxStepsReachedReason(shared) -- 481
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 482
end -- 481
local function getFailureSummaryFallback(shared, ____error) -- 487
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 488
end -- 487
local function finalizeAgentFailure(shared, ____error) -- 493
	if shared.stopToken.stopped then -- 493
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 495
		return emitAgentTaskFinishEvent( -- 496
			shared, -- 496
			false, -- 496
			getCancelledReason(shared) -- 496
		) -- 496
	end -- 496
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 498
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 499
end -- 493
local function getPromptCommand(prompt) -- 502
	local trimmed = __TS__StringTrim(prompt) -- 503
	if trimmed == "/compact" then -- 503
		return "compact" -- 504
	end -- 504
	if trimmed == "/clear" then -- 504
		return "clear" -- 505
	end -- 505
	return nil -- 506
end -- 502
function ____exports.truncateAgentUserPrompt(prompt) -- 509
	if not prompt then -- 509
		return "" -- 510
	end -- 510
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 510
		return prompt -- 511
	end -- 511
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 512
	if offset == nil then -- 512
		return prompt -- 513
	end -- 513
	return string.sub(prompt, 1, offset - 1) -- 514
end -- 509
local function canWriteStepLLMDebug(shared, stepId) -- 517
	if stepId == nil then -- 517
		stepId = shared.step + 1 -- 517
	end -- 517
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 518
end -- 517
local function ensureDirRecursive(dir) -- 525
	if not dir then -- 525
		return false -- 526
	end -- 526
	if Content:exist(dir) then -- 526
		return Content:isdir(dir) -- 527
	end -- 527
	local parent = Path:getPath(dir) -- 528
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 528
		return false -- 530
	end -- 530
	return Content:mkdir(dir) -- 532
end -- 525
local function encodeDebugJSON(value) -- 535
	local text, err = safeJsonEncode(value) -- 536
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 537
end -- 535
local function getStepLLMDebugDir(shared) -- 540
	return Path( -- 541
		shared.workingDir, -- 542
		".agent", -- 543
		tostring(shared.sessionId), -- 544
		tostring(shared.taskId) -- 545
	) -- 545
end -- 540
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 549
	return Path( -- 550
		getStepLLMDebugDir(shared), -- 550
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 550
	) -- 550
end -- 549
local function getLatestStepLLMDebugSeq(shared, stepId) -- 553
	if not canWriteStepLLMDebug(shared, stepId) then -- 553
		return 0 -- 554
	end -- 554
	local dir = getStepLLMDebugDir(shared) -- 555
	if not Content:exist(dir) or not Content:isdir(dir) then -- 555
		return 0 -- 556
	end -- 556
	local latest = 0 -- 557
	for ____, file in ipairs(Content:getFiles(dir)) do -- 558
		do -- 558
			local name = Path:getFilename(file) -- 559
			local seqText = string.match( -- 560
				name, -- 560
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 560
			) -- 560
			if seqText ~= nil then -- 560
				latest = math.max( -- 562
					latest, -- 562
					tonumber(seqText) -- 562
				) -- 562
				goto __continue48 -- 563
			end -- 563
			local legacyMatch = string.match( -- 565
				name, -- 565
				("^" .. tostring(stepId)) .. "_in%.md$" -- 565
			) -- 565
			if legacyMatch ~= nil then -- 565
				latest = math.max(latest, 1) -- 567
			end -- 567
		end -- 567
		::__continue48:: -- 567
	end -- 567
	return latest -- 570
end -- 553
local function writeStepLLMDebugFile(path, content) -- 573
	if not Content:save(path, content) then -- 573
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 575
		return false -- 576
	end -- 576
	return true -- 578
end -- 573
local function createStepLLMDebugPair(shared, stepId, inContent) -- 581
	if not canWriteStepLLMDebug(shared, stepId) then -- 581
		return 0 -- 582
	end -- 582
	local dir = getStepLLMDebugDir(shared) -- 583
	if not ensureDirRecursive(dir) then -- 583
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 585
		return 0 -- 586
	end -- 586
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 588
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 589
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 590
	if not writeStepLLMDebugFile(inPath, inContent) then -- 590
		return 0 -- 592
	end -- 592
	writeStepLLMDebugFile(outPath, "") -- 594
	return seq -- 595
end -- 581
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 598
	if not canWriteStepLLMDebug(shared, stepId) then -- 598
		return -- 599
	end -- 599
	local dir = getStepLLMDebugDir(shared) -- 600
	if not ensureDirRecursive(dir) then -- 600
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 602
		return -- 603
	end -- 603
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 605
	if latestSeq <= 0 then -- 605
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 607
		writeStepLLMDebugFile(outPath, content) -- 608
		return -- 609
	end -- 609
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 611
	writeStepLLMDebugFile(outPath, content) -- 612
end -- 598
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 615
	if not canWriteStepLLMDebug(shared, stepId) then -- 615
		return -- 616
	end -- 616
	local sections = { -- 617
		"# LLM Input", -- 618
		"session_id: " .. tostring(shared.sessionId), -- 619
		"task_id: " .. tostring(shared.taskId), -- 620
		"step_id: " .. tostring(stepId), -- 621
		"phase: " .. phase, -- 622
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 623
		"## Options", -- 624
		"```json", -- 625
		encodeDebugJSON(options), -- 626
		"```" -- 627
	} -- 627
	local firstMessage = #messages > 0 and messages[1] or nil -- 629
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 629
		sections[#sections + 1] = "# System Prompt" -- 631
		sections[#sections + 1] = firstMessage.content -- 632
	end -- 632
	do -- 632
		local i = 0 -- 634
		while i < #messages do -- 634
			local message = messages[i + 1] -- 635
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 636
			sections[#sections + 1] = encodeDebugJSON(message) -- 637
			i = i + 1 -- 634
		end -- 634
	end -- 634
	createStepLLMDebugPair( -- 639
		shared, -- 639
		stepId, -- 639
		table.concat(sections, "\n") -- 639
	) -- 639
end -- 615
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 642
	if not canWriteStepLLMDebug(shared, stepId) then -- 642
		return -- 643
	end -- 643
	local ____array_0 = __TS__SparseArrayNew( -- 643
		"# LLM Output", -- 645
		"session_id: " .. tostring(shared.sessionId), -- 646
		"task_id: " .. tostring(shared.taskId), -- 647
		"step_id: " .. tostring(stepId), -- 648
		"phase: " .. phase, -- 649
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 650
		table.unpack(meta and ({ -- 651
			"## Meta", -- 651
			"```json", -- 651
			encodeDebugJSON(meta), -- 651
			"```" -- 651
		}) or ({})) -- 651
	) -- 651
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 651
	local sections = {__TS__SparseArraySpread(____array_0)} -- 644
	updateLatestStepLLMDebugOutput( -- 655
		shared, -- 655
		stepId, -- 655
		table.concat(sections, "\n") -- 655
	) -- 655
end -- 642
local function toJson(value, emptyAsArray) -- 658
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 659
	if text ~= nil then -- 659
		return text -- 660
	end -- 660
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 661
end -- 658
local function summarizeEditTextParamForHistory(value, key) -- 711
	if type(value) ~= "string" then -- 711
		return nil -- 712
	end -- 712
	local text = value -- 713
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 714
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 715
end -- 711
local function sanitizeActionParamsForHistory(tool, params) -- 831
	if tool ~= "edit_file" then -- 831
		return params -- 832
	end -- 832
	local clone = {} -- 833
	for key in pairs(params) do -- 834
		if key == "old_str" then -- 834
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 836
		elseif key == "new_str" then -- 836
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 838
		else -- 838
			clone[key] = params[key] -- 840
		end -- 840
	end -- 840
	return clone -- 843
end -- 831
local function getDecisionToolSchemaText(shared) -- 886
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX, {disabledAgentTools = shared.disabledAgentTools})) -- 887
	return toolsText or "" -- 890
end -- 886
local function isToolAllowedForRole(shared, tool) -- 893
	return __TS__ArrayIndexOf( -- 894
		AgentToolRegistry.getAllowedToolsForRole(shared.role, {disabledAgentTools = shared.disabledAgentTools}), -- 894
		tool -- 896
	) >= 0 -- 896
end -- 893
local function clearPreExecutedResults(shared) -- 899
	shared.preExecutedResults = nil -- 900
end -- 899
local function startPreExecutedToolAction(shared, action) -- 903
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 903
		local ____hasReturned, ____returnValue -- 903
		local ____try = __TS__AsyncAwaiter(function() -- 903
			____hasReturned = true -- 905
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 905
			return -- 905
		end) -- 905
		____try = ____try.catch( -- 905
			____try, -- 905
			function(____, err) -- 905
				return __TS__AsyncAwaiter(function() -- 905
					local message = tostring(err) -- 907
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 908
					____hasReturned = true -- 909
					____returnValue = {success = false, message = message} -- 909
					return -- 909
				end) -- 909
			end -- 909
		) -- 909
		__TS__Await(____try) -- 904
		if ____hasReturned then -- 904
			return ____awaiter_resolve(nil, ____returnValue) -- 904
		end -- 904
	end) -- 904
end -- 903
local function createPreExecutedToolResult(shared, action) -- 913
	local cloneParamValue -- 914
	cloneParamValue = function(value) -- 914
		if value == nil then -- 914
			return value -- 915
		end -- 915
		if isArray(value) then -- 915
			return __TS__ArrayMap( -- 917
				value, -- 917
				function(____, item) return cloneParamValue(item) end -- 917
			) -- 917
		end -- 917
		if type(value) == "table" then -- 917
			local clone = {} -- 920
			for key in pairs(value) do -- 921
				clone[key] = cloneParamValue(value[key]) -- 922
			end -- 922
			return clone -- 924
		end -- 924
		return value -- 926
	end -- 914
	local params = cloneParamValue(action.params) -- 928
	local areParamValuesEqual -- 929
	areParamValuesEqual = function(left, right) -- 929
		if left == right then -- 929
			return true -- 930
		end -- 930
		if left == nil or right == nil then -- 930
			return false -- 931
		end -- 931
		if isArray(left) or isArray(right) then -- 931
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 931
				return false -- 933
			end -- 933
			do -- 933
				local i = 0 -- 934
				while i < #left do -- 934
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 934
						return false -- 935
					end -- 935
					i = i + 1 -- 934
				end -- 934
			end -- 934
			return true -- 937
		end -- 937
		if type(left) == "table" and type(right) == "table" then -- 937
			local leftCount = 0 -- 940
			for key in pairs(left) do -- 941
				leftCount = leftCount + 1 -- 942
				if not areParamValuesEqual(left[key], right[key]) then -- 942
					return false -- 947
				end -- 947
			end -- 947
			local rightCount = 0 -- 950
			for key in pairs(right) do -- 951
				rightCount = rightCount + 1 -- 952
			end -- 952
			return leftCount == rightCount -- 954
		end -- 954
		return false -- 956
	end -- 929
	return { -- 958
		action = action, -- 959
		matches = function(self, nextAction) -- 960
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 961
		end, -- 960
		promise = startPreExecutedToolAction(shared, action) -- 963
	} -- 963
end -- 913
local function executeToolActionWithPreExecution(shared, action) -- 967
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 967
		local ____opt_3 = shared.preExecutedResults -- 967
		local preResult = ____opt_3 and ____opt_3:get(action.toolCallId) -- 968
		if preResult then -- 968
			local ____opt_5 = shared.preExecutedResults -- 968
			if ____opt_5 ~= nil then -- 968
				____opt_5:delete(action.toolCallId) -- 970
			end -- 970
			if preResult:matches(action) then -- 970
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 972
				return ____awaiter_resolve( -- 972
					nil, -- 972
					__TS__Await(preResult.promise) -- 973
				) -- 973
			end -- 973
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 975
		end -- 975
		return ____awaiter_resolve( -- 975
			nil, -- 975
			executeToolAction(shared, action) -- 977
		) -- 977
	end) -- 977
end -- 967
local function maybeCompressHistory(shared) -- 980
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 980
		local ____shared_7 = shared -- 981
		local memory = ____shared_7.memory -- 981
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 982
		local changed = false -- 983
		do -- 983
			local round = 0 -- 984
			while round < maxRounds do -- 984
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 985
				local activeMessages = getActiveConversationMessages(shared) -- 986
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 989
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 989
					if changed then -- 989
						persistHistoryState(shared) -- 998
					end -- 998
					return ____awaiter_resolve(nil) -- 998
				end -- 998
				local compressionRound = round + 1 -- 1002
				shared.step = shared.step + 1 -- 1003
				local stepId = shared.step -- 1004
				local pendingMessages = #activeMessages -- 1005
				emitAgentEvent( -- 1006
					shared, -- 1006
					{ -- 1006
						type = "memory_compression_started", -- 1007
						sessionId = shared.sessionId, -- 1008
						taskId = shared.taskId, -- 1009
						step = stepId, -- 1010
						tool = "compress_memory", -- 1011
						reason = getMemoryCompressionStartReason(shared), -- 1012
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1013
					} -- 1013
				) -- 1013
				local result = __TS__Await(memory.compressor:compress( -- 1019
					activeMessages, -- 1020
					shared.llmOptions, -- 1021
					shared.llmMaxTry, -- 1022
					shared.decisionMode, -- 1023
					{ -- 1024
						onInput = function(____, phase, messages, options) -- 1025
							saveStepLLMDebugInput( -- 1026
								shared, -- 1026
								stepId, -- 1026
								phase, -- 1026
								messages, -- 1026
								options -- 1026
							) -- 1026
						end, -- 1025
						onOutput = function(____, phase, text, meta) -- 1028
							saveStepLLMDebugOutput( -- 1029
								shared, -- 1029
								stepId, -- 1029
								phase, -- 1029
								text, -- 1029
								meta -- 1029
							) -- 1029
						end -- 1028
					}, -- 1028
					"default", -- 1032
					systemPrompt, -- 1033
					toolDefinitions -- 1034
				)) -- 1034
				if not (result and result.success and result.compressedCount > 0) then -- 1034
					emitAgentEvent( -- 1037
						shared, -- 1037
						{ -- 1037
							type = "memory_compression_finished", -- 1038
							sessionId = shared.sessionId, -- 1039
							taskId = shared.taskId, -- 1040
							step = stepId, -- 1041
							tool = "compress_memory", -- 1042
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1043
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1047
						} -- 1047
					) -- 1047
					if changed then -- 1047
						persistHistoryState(shared) -- 1055
					end -- 1055
					return ____awaiter_resolve(nil) -- 1055
				end -- 1055
				local effectiveCompressedCount = math.max( -- 1059
					0, -- 1060
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1061
				) -- 1061
				if effectiveCompressedCount <= 0 then -- 1061
					if changed then -- 1061
						persistHistoryState(shared) -- 1065
					end -- 1065
					return ____awaiter_resolve(nil) -- 1065
				end -- 1065
				emitAgentEvent( -- 1069
					shared, -- 1069
					{ -- 1069
						type = "memory_compression_finished", -- 1070
						sessionId = shared.sessionId, -- 1071
						taskId = shared.taskId, -- 1072
						step = stepId, -- 1073
						tool = "compress_memory", -- 1074
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1075
						result = { -- 1076
							success = true, -- 1077
							round = compressionRound, -- 1078
							compressedCount = effectiveCompressedCount, -- 1079
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1080
						} -- 1080
					} -- 1080
				) -- 1080
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1083
				changed = true -- 1084
				Log( -- 1085
					"Info", -- 1085
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1085
				) -- 1085
				round = round + 1 -- 984
			end -- 984
		end -- 984
		if changed then -- 984
			persistHistoryState(shared) -- 1088
		end -- 1088
	end) -- 1088
end -- 980
local function compactAllHistory(shared) -- 1092
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1092
		local ____shared_14 = shared -- 1093
		local memory = ____shared_14.memory -- 1093
		local rounds = 0 -- 1094
		local totalCompressed = 0 -- 1095
		while getActiveRealMessageCount(shared) > 0 do -- 1095
			if shared.stopToken.stopped then -- 1095
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1098
				return ____awaiter_resolve( -- 1098
					nil, -- 1098
					emitAgentTaskFinishEvent( -- 1099
						shared, -- 1099
						false, -- 1099
						getCancelledReason(shared) -- 1099
					) -- 1099
				) -- 1099
			end -- 1099
			rounds = rounds + 1 -- 1101
			shared.step = shared.step + 1 -- 1102
			local stepId = shared.step -- 1103
			local activeMessages = getActiveConversationMessages(shared) -- 1104
			local pendingMessages = #activeMessages -- 1105
			emitAgentEvent( -- 1106
				shared, -- 1106
				{ -- 1106
					type = "memory_compression_started", -- 1107
					sessionId = shared.sessionId, -- 1108
					taskId = shared.taskId, -- 1109
					step = stepId, -- 1110
					tool = "compress_memory", -- 1111
					reason = getMemoryCompressionStartReason(shared), -- 1112
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1113
				} -- 1113
			) -- 1113
			local result = __TS__Await(memory.compressor:compress( -- 1120
				activeMessages, -- 1121
				shared.llmOptions, -- 1122
				shared.llmMaxTry, -- 1123
				shared.decisionMode, -- 1124
				{ -- 1125
					onInput = function(____, phase, messages, options) -- 1126
						saveStepLLMDebugInput( -- 1127
							shared, -- 1127
							stepId, -- 1127
							phase, -- 1127
							messages, -- 1127
							options -- 1127
						) -- 1127
					end, -- 1126
					onOutput = function(____, phase, text, meta) -- 1129
						saveStepLLMDebugOutput( -- 1130
							shared, -- 1130
							stepId, -- 1130
							phase, -- 1130
							text, -- 1130
							meta -- 1130
						) -- 1130
					end -- 1129
				}, -- 1129
				"budget_max" -- 1133
			)) -- 1133
			if not (result and result.success and result.compressedCount > 0) then -- 1133
				emitAgentEvent( -- 1136
					shared, -- 1136
					{ -- 1136
						type = "memory_compression_finished", -- 1137
						sessionId = shared.sessionId, -- 1138
						taskId = shared.taskId, -- 1139
						step = stepId, -- 1140
						tool = "compress_memory", -- 1141
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1142
						result = { -- 1146
							success = false, -- 1147
							rounds = rounds, -- 1148
							error = result and result.error or "compression returned no changes", -- 1149
							compressedCount = result and result.compressedCount or 0, -- 1150
							fullCompaction = true -- 1151
						} -- 1151
					} -- 1151
				) -- 1151
				return ____awaiter_resolve( -- 1151
					nil, -- 1151
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1154
				) -- 1154
			end -- 1154
			local effectiveCompressedCount = math.max( -- 1159
				0, -- 1160
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1161
			) -- 1161
			if effectiveCompressedCount <= 0 then -- 1161
				return ____awaiter_resolve( -- 1161
					nil, -- 1161
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1164
				) -- 1164
			end -- 1164
			emitAgentEvent( -- 1171
				shared, -- 1171
				{ -- 1171
					type = "memory_compression_finished", -- 1172
					sessionId = shared.sessionId, -- 1173
					taskId = shared.taskId, -- 1174
					step = stepId, -- 1175
					tool = "compress_memory", -- 1176
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1177
					result = { -- 1178
						success = true, -- 1179
						round = rounds, -- 1180
						compressedCount = effectiveCompressedCount, -- 1181
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1182
						fullCompaction = true -- 1183
					} -- 1183
				} -- 1183
			) -- 1183
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1186
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1187
			persistHistoryState(shared) -- 1188
			Log( -- 1189
				"Info", -- 1189
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1189
			) -- 1189
		end -- 1189
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1191
		return ____awaiter_resolve( -- 1191
			nil, -- 1191
			emitAgentTaskFinishEvent( -- 1192
				shared, -- 1193
				true, -- 1194
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1195
			) -- 1195
		) -- 1195
	end) -- 1195
end -- 1092
local function clearSessionHistory(shared) -- 1201
	shared.messages = {} -- 1202
	shared.lastConsolidatedIndex = 0 -- 1203
	shared.carryMessageIndex = nil -- 1204
	persistHistoryState(shared) -- 1205
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1206
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1207
end -- 1201
local function appendConversationMessage(shared, message) -- 1297
	local ____shared_messages_23 = shared.messages -- 1297
	____shared_messages_23[#____shared_messages_23 + 1] = __TS__ObjectAssign( -- 1298
		{}, -- 1298
		message, -- 1299
		{ -- 1298
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1300
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1301
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1302
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1303
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1304
		} -- 1304
	) -- 1304
end -- 1297
local function appendToolResultMessage(shared, action) -- 1313
	appendConversationMessage( -- 1314
		shared, -- 1314
		{ -- 1314
			role = "tool", -- 1315
			tool_call_id = action.toolCallId, -- 1316
			name = action.tool, -- 1317
			content = action.result and toJson(action.result, false) or "" -- 1318
		} -- 1318
	) -- 1318
end -- 1313
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1322
	appendConversationMessage( -- 1328
		shared, -- 1328
		{ -- 1328
			role = "assistant", -- 1329
			content = content or "", -- 1330
			reasoning_content = reasoningContent, -- 1331
			tool_calls = __TS__ArrayMap( -- 1332
				actions, -- 1332
				function(____, action) return { -- 1332
					id = action.toolCallId, -- 1333
					type = "function", -- 1334
					["function"] = { -- 1335
						name = action.tool, -- 1336
						arguments = toJson(action.params, false) -- 1337
					} -- 1337
				} end -- 1337
			) -- 1337
		} -- 1337
	) -- 1337
end -- 1322
local function llm(shared, messages, phase) -- 1521
	if phase == nil then -- 1521
		phase = "decision_xml" -- 1524
	end -- 1524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1524
		local stepId = shared.step + 1 -- 1526
		emitLLMContextMetrics( -- 1527
			shared, -- 1527
			stepId, -- 1527
			phase, -- 1527
			messages, -- 1527
			shared.llmOptions -- 1527
		) -- 1527
		saveStepLLMDebugInput( -- 1528
			shared, -- 1528
			stepId, -- 1528
			phase, -- 1528
			messages, -- 1528
			shared.llmOptions -- 1528
		) -- 1528
		local lastStreamReasoning = "" -- 1529
		local res = __TS__Await(callLLMStreamAggregated( -- 1530
			messages, -- 1531
			shared.llmOptions, -- 1532
			shared.stopToken, -- 1533
			shared.llmConfig, -- 1534
			function(response) -- 1535
				local ____opt_27 = response.choices -- 1535
				local ____opt_25 = ____opt_27 and ____opt_27[1] -- 1535
				local streamMessage = ____opt_25 and ____opt_25.message -- 1536
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1537
				if nextContent == "" then -- 1537
					return -- 1540
				end -- 1540
				if nextContent == lastStreamReasoning then -- 1540
					return -- 1541
				end -- 1541
				lastStreamReasoning = nextContent -- 1542
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1543
			end -- 1535
		)) -- 1535
		if res.success then -- 1535
			local ____opt_33 = res.response.choices -- 1535
			local ____opt_31 = ____opt_33 and ____opt_33[1] -- 1535
			local message = ____opt_31 and ____opt_31.message -- 1547
			local text = message and message.content -- 1548
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1549
			if text then -- 1549
				local parsed = tryParseAndValidateDecision(text) -- 1553
				if parsed.success then -- 1553
					local reason = parsed.reason or "" -- 1555
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1556
				end -- 1556
				saveStepLLMDebugOutput( -- 1558
					shared, -- 1558
					stepId, -- 1558
					phase, -- 1558
					text, -- 1558
					{success = true} -- 1558
				) -- 1558
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1558
			else -- 1558
				saveStepLLMDebugOutput( -- 1561
					shared, -- 1561
					stepId, -- 1561
					phase, -- 1561
					"empty LLM response", -- 1561
					{success = false} -- 1561
				) -- 1561
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1561
			end -- 1561
		else -- 1561
			saveStepLLMDebugOutput( -- 1565
				shared, -- 1565
				stepId, -- 1565
				phase, -- 1565
				res.raw or res.message, -- 1565
				{success = false} -- 1565
			) -- 1565
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1565
		end -- 1565
	end) -- 1565
end -- 1521
local function isDecisionBatchSuccess(result) -- 1589
	return result.kind == "batch" -- 1590
end -- 1589
local function parseDecisionToolCall(functionName, rawObj) -- 1614
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 1614
		return {success = false, message = "unknown tool: " .. functionName} -- 1616
	end -- 1616
	if rawObj == nil then -- 1616
		return {success = true, tool = functionName, params = {}} -- 1619
	end -- 1619
	if not isRecord(rawObj) then -- 1619
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1622
	end -- 1622
	return {success = true, tool = functionName, params = rawObj} -- 1624
end -- 1614
local function parseToolCallArguments(functionName, argsText) -- 1631
	local trimmedArgs = __TS__StringTrim(argsText) -- 1632
	if trimmedArgs == "" then -- 1632
		return {} -- 1634
	end -- 1634
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1636
	if err ~= nil or rawObj == nil then -- 1636
		return { -- 1638
			success = false, -- 1639
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1640
			raw = argsText -- 1641
		} -- 1641
	end -- 1641
	local encodedRaw = safeJsonEncode(rawObj) -- 1644
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1644
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1646
	end -- 1646
	return rawObj -- 1652
end -- 1631
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1655
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1663
	if isRecord(rawArgs) and rawArgs.success == false then -- 1663
		return rawArgs -- 1665
	end -- 1665
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1667
	if not decision.success then -- 1667
		return {success = false, message = decision.message, raw = argsText} -- 1669
	end -- 1669
	local validation = validateDecision(decision.tool, decision.params) -- 1675
	if not validation.success then -- 1675
		return {success = false, message = validation.message, raw = argsText} -- 1677
	end -- 1677
	if not isToolAllowedForRole(shared, decision.tool) then -- 1677
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1684
	end -- 1684
	decision.params = validation.params -- 1690
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1691
	decision.reason = reason -- 1692
	decision.reasoningContent = reasoningContent -- 1693
	return decision -- 1694
end -- 1655
local function createPreExecutableActionFromStream(shared, toolCall) -- 1697
	local ____opt_39 = toolCall["function"] -- 1697
	local functionName = ____opt_39 and ____opt_39.name -- 1698
	local ____opt_41 = toolCall["function"] -- 1698
	local argsText = ____opt_41 and ____opt_41.arguments or "" -- 1699
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1700
	if not functionName or not toolCallId then -- 1700
		return nil -- 1701
	end -- 1701
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1702
	if isRecord(rawArgs) and rawArgs.success == false then -- 1702
		return nil -- 1703
	end -- 1703
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1704
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 1704
		return nil -- 1705
	end -- 1705
	local validation = validateDecision(decision.tool, decision.params) -- 1706
	if not validation.success then -- 1706
		return nil -- 1707
	end -- 1707
	if not isToolAllowedForRole(shared, decision.tool) then -- 1707
		return nil -- 1708
	end -- 1708
	return { -- 1709
		step = shared.step + 1, -- 1710
		toolCallId = toolCallId, -- 1711
		tool = decision.tool, -- 1712
		reason = "", -- 1713
		params = validation.params, -- 1714
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1715
	} -- 1715
end -- 1697
local function sanitizeMessagesForLLMInput(messages) -- 1892
	local sanitized = {} -- 1893
	local droppedAssistantToolCalls = 0 -- 1894
	local droppedToolResults = 0 -- 1895
	do -- 1895
		local i = 0 -- 1896
		while i < #messages do -- 1896
			do -- 1896
				local message = messages[i + 1] -- 1897
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1897
					local requiredIds = {} -- 1899
					do -- 1899
						local j = 0 -- 1900
						while j < #message.tool_calls do -- 1900
							local toolCall = message.tool_calls[j + 1] -- 1901
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1902
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1902
								requiredIds[#requiredIds + 1] = id -- 1904
							end -- 1904
							j = j + 1 -- 1900
						end -- 1900
					end -- 1900
					if #requiredIds == 0 then -- 1900
						sanitized[#sanitized + 1] = message -- 1908
						goto __continue330 -- 1909
					end -- 1909
					local matchedIds = {} -- 1911
					local matchedTools = {} -- 1912
					local j = i + 1 -- 1913
					while j < #messages do -- 1913
						local toolMessage = messages[j + 1] -- 1915
						if toolMessage.role ~= "tool" then -- 1915
							break -- 1916
						end -- 1916
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1917
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1917
							matchedIds[toolCallId] = true -- 1919
							matchedTools[#matchedTools + 1] = toolMessage -- 1920
						else -- 1920
							droppedToolResults = droppedToolResults + 1 -- 1922
						end -- 1922
						j = j + 1 -- 1924
					end -- 1924
					local complete = true -- 1926
					do -- 1926
						local j = 0 -- 1927
						while j < #requiredIds do -- 1927
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1927
								complete = false -- 1929
								break -- 1930
							end -- 1930
							j = j + 1 -- 1927
						end -- 1927
					end -- 1927
					if complete then -- 1927
						__TS__ArrayPush( -- 1934
							sanitized, -- 1934
							message, -- 1934
							table.unpack(matchedTools) -- 1934
						) -- 1934
					else -- 1934
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1936
						droppedToolResults = droppedToolResults + #matchedTools -- 1937
					end -- 1937
					i = j - 1 -- 1939
					goto __continue330 -- 1940
				end -- 1940
				if message.role == "tool" then -- 1940
					droppedToolResults = droppedToolResults + 1 -- 1943
					goto __continue330 -- 1944
				end -- 1944
				sanitized[#sanitized + 1] = message -- 1946
			end -- 1946
			::__continue330:: -- 1946
			i = i + 1 -- 1896
		end -- 1896
	end -- 1896
	return sanitized -- 1948
end -- 1892
local function getUnconsolidatedMessages(shared) -- 1951
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1952
end -- 1951
local function getFinalDecisionTurnPrompt(shared) -- 1955
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 1956
end -- 1955
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 1961
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 1961
		return messages -- 1962
	end -- 1962
	local next = __TS__ArrayMap( -- 1963
		messages, -- 1963
		function(____, message) return __TS__ObjectAssign({}, message) end -- 1963
	) -- 1963
	do -- 1963
		local i = #next - 1 -- 1964
		while i >= 0 do -- 1964
			do -- 1964
				local message = next[i + 1] -- 1965
				if message.role ~= "assistant" and message.role ~= "user" then -- 1965
					goto __continue352 -- 1966
				end -- 1966
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 1967
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 1968
				return next -- 1971
			end -- 1971
			::__continue352:: -- 1971
			i = i - 1 -- 1964
		end -- 1964
	end -- 1964
	next[#next + 1] = {role = "user", content = prompt} -- 1973
	return next -- 1974
end -- 1961
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 1977
	if attempt == nil then -- 1977
		attempt = 1 -- 1980
	end -- 1980
	if decisionMode == nil then -- 1980
		decisionMode = shared.decisionMode -- 1982
	end -- 1982
	local messages = { -- 1984
		{ -- 1985
			role = "system", -- 1985
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 1985
		}, -- 1985
		table.unpack(getUnconsolidatedMessages(shared)) -- 1986
	} -- 1986
	if shared.step + 1 >= shared.maxSteps then -- 1986
		messages = appendPromptToLatestDecisionMessage( -- 1989
			messages, -- 1989
			getFinalDecisionTurnPrompt(shared) -- 1989
		) -- 1989
	end -- 1989
	if lastError and lastError ~= "" then -- 1989
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1992
		if decisionMode == "xml" then -- 1992
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 1996
		end -- 1996
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 1996
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 1999
		end -- 1999
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 1999
			retryHeader = retryHeader .. "\nYour previous response spent the token budget on reasoning and ended before any tool call. Do not continue that reasoning. Immediately emit one valid function tool call with compact arguments." -- 2002
		end -- 2002
		messages[#messages + 1] = { -- 2004
			role = "user", -- 2005
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2006
		} -- 2006
	end -- 2006
	return messages -- 2013
end -- 1977
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2020
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2029
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2030
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2038
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2039
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2040
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2048
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}, disabledAgentTools = shared.disabledAgentTools}) -- 2056
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2062
	local repairPrompt = replacePromptVars( -- 2065
		shared.promptPack.xmlDecisionRepairPrompt, -- 2065
		{ -- 2065
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2066
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2067
			CANDIDATE_SECTION = candidateSection, -- 2068
			LAST_ERROR = lastError, -- 2069
			ATTEMPT = tostring(attempt) -- 2070
		} -- 2070
	) -- 2070
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2072
end -- 2020
local function normalizeLineEndings(text) -- 2102
	local res = string.gsub(text, "\r\n", "\n") -- 2103
	res = string.gsub(res, "\r", "\n") -- 2104
	return res -- 2105
end -- 2102
local function countOccurrences(text, searchStr) -- 2108
	if searchStr == "" then -- 2108
		return 0 -- 2109
	end -- 2109
	local count = 0 -- 2110
	local pos = 0 -- 2111
	while true do -- 2111
		local idx = (string.find( -- 2113
			text, -- 2113
			searchStr, -- 2113
			math.max(pos + 1, 1), -- 2113
			true -- 2113
		) or 0) - 1 -- 2113
		if idx < 0 then -- 2113
			break -- 2114
		end -- 2114
		count = count + 1 -- 2115
		pos = idx + #searchStr -- 2116
	end -- 2116
	return count -- 2118
end -- 2108
local function replaceFirst(text, oldStr, newStr) -- 2121
	if oldStr == "" then -- 2121
		return text -- 2122
	end -- 2122
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2123
	if idx < 0 then -- 2123
		return text -- 2124
	end -- 2124
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2125
end -- 2121
local function splitLines(text) -- 2128
	return __TS__StringSplit(text, "\n") -- 2129
end -- 2128
local function getLeadingWhitespace(text) -- 2132
	local i = 0 -- 2133
	while i < #text do -- 2133
		local ch = __TS__StringAccess(text, i) -- 2135
		if ch ~= " " and ch ~= "\t" then -- 2135
			break -- 2136
		end -- 2136
		i = i + 1 -- 2137
	end -- 2137
	return __TS__StringSubstring(text, 0, i) -- 2139
end -- 2132
local function getCommonIndentPrefix(lines) -- 2142
	local common -- 2143
	do -- 2143
		local i = 0 -- 2144
		while i < #lines do -- 2144
			do -- 2144
				local line = lines[i + 1] -- 2145
				if __TS__StringTrim(line) == "" then -- 2145
					goto __continue380 -- 2146
				end -- 2146
				local indent = getLeadingWhitespace(line) -- 2147
				if common == nil then -- 2147
					common = indent -- 2149
					goto __continue380 -- 2150
				end -- 2150
				local j = 0 -- 2152
				local maxLen = math.min(#common, #indent) -- 2153
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2153
					j = j + 1 -- 2155
				end -- 2155
				common = __TS__StringSubstring(common, 0, j) -- 2157
				if common == "" then -- 2157
					break -- 2158
				end -- 2158
			end -- 2158
			::__continue380:: -- 2158
			i = i + 1 -- 2144
		end -- 2144
	end -- 2144
	return common or "" -- 2160
end -- 2142
local function removeIndentPrefix(line, indent) -- 2163
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2163
		return __TS__StringSubstring(line, #indent) -- 2165
	end -- 2165
	local lineIndent = getLeadingWhitespace(line) -- 2167
	local j = 0 -- 2168
	local maxLen = math.min(#lineIndent, #indent) -- 2169
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2169
		j = j + 1 -- 2171
	end -- 2171
	return __TS__StringSubstring(line, j) -- 2173
end -- 2163
local function dedentLines(lines) -- 2176
	local indent = getCommonIndentPrefix(lines) -- 2177
	return { -- 2178
		indent = indent, -- 2179
		lines = __TS__ArrayMap( -- 2180
			lines, -- 2180
			function(____, line) return removeIndentPrefix(line, indent) end -- 2180
		) -- 2180
	} -- 2180
end -- 2176
local function joinLines(lines) -- 2184
	return table.concat(lines, "\n") -- 2185
end -- 2184
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2188
	local function findWhitespaceTolerantReplacement() -- 2193
		local function foldWhitespace(text, withMap) -- 2195
			local parts = {} -- 2196
			local map = {} -- 2197
			local i = 0 -- 2198
			while i < #text do -- 2198
				local ch = __TS__StringAccess(text, i) -- 2200
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2200
					local start = i -- 2202
					while i < #text do -- 2202
						local next = __TS__StringAccess(text, i) -- 2204
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2204
							break -- 2205
						end -- 2205
						i = i + 1 -- 2206
					end -- 2206
					parts[#parts + 1] = " " -- 2208
					if withMap then -- 2208
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2209
					end -- 2209
				else -- 2209
					parts[#parts + 1] = ch -- 2211
					if withMap then -- 2211
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2212
					end -- 2212
					i = i + 1 -- 2213
				end -- 2213
			end -- 2213
			return { -- 2216
				text = table.concat(parts, ""), -- 2216
				map = map -- 2216
			} -- 2216
		end -- 2195
		local foldedContent = foldWhitespace(content, true) -- 2218
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2219
		if foldedOld == "" then -- 2219
			return {success = false, message = "old_str not found in file"} -- 2221
		end -- 2221
		local matches = {} -- 2223
		local pos = 0 -- 2224
		while true do -- 2224
			local idx = (string.find( -- 2226
				foldedContent.text, -- 2226
				foldedOld, -- 2226
				math.max(pos + 1, 1), -- 2226
				true -- 2226
			) or 0) - 1 -- 2226
			if idx < 0 then -- 2226
				break -- 2227
			end -- 2227
			local lastIdx = idx + #foldedOld - 1 -- 2228
			local startMap = foldedContent.map[idx + 1] -- 2229
			local endMap = foldedContent.map[lastIdx + 1] -- 2230
			if startMap ~= nil and endMap ~= nil then -- 2230
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2232
			end -- 2232
			pos = idx + #foldedOld -- 2234
		end -- 2234
		if #matches == 0 then -- 2234
			return {success = false, message = "old_str not found in file"} -- 2237
		end -- 2237
		if #matches > 1 then -- 2237
			return { -- 2240
				success = false, -- 2241
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2242
			} -- 2242
		end -- 2242
		local match = matches[1] -- 2245
		return { -- 2246
			success = true, -- 2247
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2248
		} -- 2248
	end -- 2193
	local contentLines = splitLines(content) -- 2251
	local oldLines = splitLines(oldStr) -- 2252
	if #oldLines == 0 then -- 2252
		return {success = false, message = "old_str not found in file"} -- 2254
	end -- 2254
	local dedentedOld = dedentLines(oldLines) -- 2256
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2257
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2258
	local matches = {} -- 2259
	do -- 2259
		local start = 0 -- 2260
		while start <= #contentLines - #oldLines do -- 2260
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2261
			local dedentedCandidate = dedentLines(candidateLines) -- 2262
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2262
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2264
			end -- 2264
			start = start + 1 -- 2260
		end -- 2260
	end -- 2260
	if #matches == 0 then -- 2260
		return findWhitespaceTolerantReplacement() -- 2272
	end -- 2272
	if #matches > 1 then -- 2272
		return { -- 2275
			success = false, -- 2276
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2277
		} -- 2277
	end -- 2277
	local match = matches[1] -- 2280
	local rebuiltNewLines = __TS__ArrayMap( -- 2281
		dedentedNew.lines, -- 2281
		function(____, line) return line == "" and "" or match.indent .. line end -- 2281
	) -- 2281
	local ____array_47 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2281
	__TS__SparseArrayPush( -- 2281
		____array_47, -- 2281
		table.unpack(rebuiltNewLines) -- 2284
	) -- 2284
	__TS__SparseArrayPush( -- 2284
		____array_47, -- 2284
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2285
	) -- 2285
	local nextLines = {__TS__SparseArraySpread(____array_47)} -- 2282
	return { -- 2287
		success = true, -- 2287
		content = joinLines(nextLines) -- 2287
	} -- 2287
end -- 2188
local MainDecisionAgent = __TS__Class() -- 2290
MainDecisionAgent.name = "MainDecisionAgent" -- 2290
__TS__ClassExtends(MainDecisionAgent, Node) -- 2290
function MainDecisionAgent.prototype.prep(self, shared) -- 2291
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2291
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2291
			return ____awaiter_resolve(nil, {shared = shared}) -- 2291
		end -- 2291
		__TS__Await(maybeCompressHistory(shared)) -- 2296
		return ____awaiter_resolve(nil, {shared = shared}) -- 2296
	end) -- 2296
end -- 2291
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2301
	local preExecuted = shared.preExecutedResults -- 2302
	if not preExecuted or preExecuted.size == 0 then -- 2302
		return nil -- 2303
	end -- 2303
	local decisions = {} -- 2304
	preExecuted:forEach(function(____, preResult) -- 2305
		local action = preResult.action -- 2306
		decisions[#decisions + 1] = { -- 2307
			success = true, -- 2308
			tool = action.tool, -- 2309
			params = action.params, -- 2310
			toolCallId = action.toolCallId, -- 2311
			reason = action.reason, -- 2312
			reasoningContent = action.reasoningContent -- 2313
		} -- 2313
	end) -- 2305
	if #decisions == 0 then -- 2305
		return nil -- 2316
	end -- 2316
	Log( -- 2317
		"Warn", -- 2317
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2317
			__TS__ArrayMap( -- 2317
				decisions, -- 2317
				function(____, decision) return decision.tool end -- 2317
			), -- 2317
			"," -- 2317
		) -- 2317
	) -- 2317
	if #decisions == 1 then -- 2317
		return decisions[1] -- 2319
	end -- 2319
	return {success = true, kind = "batch", decisions = decisions} -- 2321
end -- 2301
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2328
	if attempt == nil then -- 2328
		attempt = 1 -- 2331
	end -- 2331
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2331
		if shared.stopToken.stopped then -- 2331
			return ____awaiter_resolve( -- 2331
				nil, -- 2331
				{ -- 2335
					success = false, -- 2335
					message = getCancelledReason(shared) -- 2335
				} -- 2335
			) -- 2335
		end -- 2335
		Log( -- 2337
			"Info", -- 2337
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2337
		) -- 2337
		local tools = AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX, {disabledAgentTools = shared.disabledAgentTools}) -- 2338
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2341
		local stepId = shared.step + 1 -- 2342
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2343
		emitLLMContextMetrics( -- 2347
			shared, -- 2347
			stepId, -- 2347
			"decision_tool_calling", -- 2347
			messages, -- 2347
			llmOptions -- 2347
		) -- 2347
		saveStepLLMDebugInput( -- 2348
			shared, -- 2348
			stepId, -- 2348
			"decision_tool_calling", -- 2348
			messages, -- 2348
			llmOptions -- 2348
		) -- 2348
		local lastStreamContent = "" -- 2349
		local lastStreamReasoning = "" -- 2350
		local preExecutedResults = __TS__New(Map) -- 2351
		shared.preExecutedResults = preExecutedResults -- 2352
		local res = __TS__Await(callLLMStreamAggregated( -- 2353
			messages, -- 2354
			llmOptions, -- 2355
			shared.stopToken, -- 2356
			shared.llmConfig, -- 2357
			function(response) -- 2358
				local ____opt_50 = response.choices -- 2358
				local ____opt_48 = ____opt_50 and ____opt_50[1] -- 2358
				local streamMessage = ____opt_48 and ____opt_48.message -- 2359
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2360
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2363
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2363
					return -- 2367
				end -- 2367
				lastStreamContent = nextContent -- 2369
				lastStreamReasoning = nextReasoning -- 2370
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2371
			end, -- 2358
			function(tc) -- 2373
				if shared.stopToken.stopped then -- 2373
					return -- 2374
				end -- 2374
				local action = createPreExecutableActionFromStream(shared, tc) -- 2375
				if not action or preExecutedResults:has(action.toolCallId) then -- 2375
					return -- 2376
				end -- 2376
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2377
				preExecutedResults:set( -- 2378
					action.toolCallId, -- 2378
					createPreExecutedToolResult(shared, action) -- 2378
				) -- 2378
			end -- 2373
		)) -- 2373
		if shared.stopToken.stopped then -- 2373
			clearPreExecutedResults(shared) -- 2382
			return ____awaiter_resolve( -- 2382
				nil, -- 2382
				{ -- 2383
					success = false, -- 2383
					message = getCancelledReason(shared) -- 2383
				} -- 2383
			) -- 2383
		end -- 2383
		if not res.success then -- 2383
			saveStepLLMDebugOutput( -- 2386
				shared, -- 2386
				stepId, -- 2386
				"decision_tool_calling", -- 2386
				res.raw or res.message, -- 2386
				{success = false} -- 2386
			) -- 2386
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2387
			if (string.find(res.message, "stream incomplete:", nil, true) or 0) - 1 >= 0 then -- 2387
				local ____opt_56 = res.response -- 2387
				local partialChoice = ____opt_56 and ____opt_56.choices and res.response.choices[1] -- 2389
				local partialMessage = partialChoice and partialChoice.message -- 2390
				local partialToolCalls = partialMessage and partialMessage.tool_calls -- 2391
				if partialToolCalls and #partialToolCalls > 0 then -- 2391
					local partialReasoningContent = partialMessage ~= nil and type(partialMessage.reasoning_content) == "string" and partialMessage.reasoning_content or nil -- 2393
					local partialMessageContent = partialMessage ~= nil and type(partialMessage.content) == "string" and __TS__StringTrim(partialMessage.content) or nil -- 2396
					local partialDecisions = {} -- 2399
					local partialFailure -- 2400
					do -- 2400
						local i = 0 -- 2401
						while i < #partialToolCalls do -- 2401
							local toolCall = partialToolCalls[i + 1] -- 2402
							local fn = toolCall ~= nil and toolCall["function"] -- 2403
							if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2403
								partialFailure = { -- 2405
									success = false, -- 2406
									message = "missing function name for partial tool call " .. tostring(i + 1), -- 2407
									raw = partialMessageContent -- 2408
								} -- 2408
								break -- 2410
							end -- 2410
							local decision = parseAndValidateToolCallDecision( -- 2412
								shared, -- 2413
								fn.name, -- 2414
								type(fn.arguments) == "string" and fn.arguments or "", -- 2415
								toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil, -- 2416
								partialMessageContent, -- 2417
								partialReasoningContent -- 2418
							) -- 2418
							if not decision.success then -- 2418
								partialFailure = decision -- 2421
								break -- 2422
							end -- 2422
							partialDecisions[#partialDecisions + 1] = decision -- 2424
							i = i + 1 -- 2401
						end -- 2401
					end -- 2401
					if not partialFailure and #partialDecisions > 0 then -- 2401
						Log( -- 2427
							"Warn", -- 2427
							"[CodingAgent] committing partial tool calls after incomplete stream tools=" .. table.concat( -- 2427
								__TS__ArrayMap( -- 2427
									partialDecisions, -- 2427
									function(____, decision) return decision.tool end -- 2427
								), -- 2427
								"," -- 2427
							) -- 2427
						) -- 2427
						if #partialDecisions == 1 then -- 2427
							return ____awaiter_resolve(nil, partialDecisions[1]) -- 2427
						end -- 2427
						return ____awaiter_resolve(nil, { -- 2427
							success = true, -- 2432
							kind = "batch", -- 2433
							decisions = partialDecisions, -- 2434
							content = partialMessageContent, -- 2435
							reasoningContent = partialReasoningContent -- 2436
						}) -- 2436
					end -- 2436
					Log("Warn", "[CodingAgent] partial tool calls not commit-ready after incomplete stream: " .. (partialFailure and partialFailure.message or "empty decisions")) -- 2439
				end -- 2439
				local committedDecision = self:commitPreExecutedDecision(shared) -- 2441
				if committedDecision then -- 2441
					return ____awaiter_resolve(nil, committedDecision) -- 2441
				end -- 2441
			end -- 2441
			clearPreExecutedResults(shared) -- 2446
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2446
		end -- 2446
		saveStepLLMDebugOutput( -- 2449
			shared, -- 2449
			stepId, -- 2449
			"decision_tool_calling", -- 2449
			encodeDebugJSON(res.response), -- 2449
			{success = true} -- 2449
		) -- 2449
		local choice = res.response.choices and res.response.choices[1] -- 2450
		local message = choice and choice.message -- 2451
		local toolCalls = message and message.tool_calls -- 2452
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2453
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2456
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2459
		Log( -- 2462
			"Info", -- 2462
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2462
		) -- 2462
		if not toolCalls or #toolCalls == 0 then -- 2462
			if finishReason == "length" then -- 2462
				Log( -- 2465
					"Error", -- 2465
					"[CodingAgent] tool-calling output truncated before tool call reasoning_len=" .. tostring(reasoningContent and #reasoningContent or 0) -- 2465
				) -- 2465
				clearPreExecutedResults(shared) -- 2466
				return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens before producing a tool call. Retry immediately with a valid tool call and keep reasoning minimal.", raw = reasoningContent or messageContent or ""}) -- 2466
			end -- 2466
			if messageContent and messageContent ~= "" then -- 2466
				Log( -- 2474
					"Info", -- 2474
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2474
				) -- 2474
				clearPreExecutedResults(shared) -- 2475
				return ____awaiter_resolve(nil, { -- 2475
					success = true, -- 2477
					tool = "finish", -- 2478
					params = {}, -- 2479
					reason = messageContent, -- 2480
					reasoningContent = reasoningContent, -- 2481
					directSummary = messageContent -- 2482
				}) -- 2482
			end -- 2482
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2485
			clearPreExecutedResults(shared) -- 2486
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2486
		end -- 2486
		local decisions = {} -- 2493
		do -- 2493
			local i = 0 -- 2494
			while i < #toolCalls do -- 2494
				local toolCall = toolCalls[i + 1] -- 2495
				local fn = toolCall ~= nil and toolCall["function"] -- 2496
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2496
					Log( -- 2498
						"Error", -- 2498
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2498
					) -- 2498
					clearPreExecutedResults(shared) -- 2499
					return ____awaiter_resolve( -- 2499
						nil, -- 2499
						{ -- 2500
							success = false, -- 2501
							message = "missing function name for tool call " .. tostring(i + 1), -- 2502
							raw = messageContent -- 2503
						} -- 2503
					) -- 2503
				end -- 2503
				local functionName = fn.name -- 2506
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2507
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 2508
				Log( -- 2511
					"Info", -- 2511
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2511
				) -- 2511
				local decision = parseAndValidateToolCallDecision( -- 2512
					shared, -- 2513
					functionName, -- 2514
					argsText, -- 2515
					toolCallId, -- 2516
					messageContent, -- 2517
					reasoningContent -- 2518
				) -- 2518
				if not decision.success then -- 2518
					Log( -- 2521
						"Error", -- 2521
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2521
					) -- 2521
					clearPreExecutedResults(shared) -- 2522
					return ____awaiter_resolve(nil, decision) -- 2522
				end -- 2522
				decisions[#decisions + 1] = decision -- 2525
				i = i + 1 -- 2494
			end -- 2494
		end -- 2494
		if #decisions == 1 then -- 2494
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2528
			return ____awaiter_resolve(nil, decisions[1]) -- 2528
		end -- 2528
		do -- 2528
			local i = 0 -- 2531
			while i < #decisions do -- 2531
				if decisions[i + 1].tool == "finish" then -- 2531
					clearPreExecutedResults(shared) -- 2533
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2533
				end -- 2533
				i = i + 1 -- 2531
			end -- 2531
		end -- 2531
		Log( -- 2541
			"Info", -- 2541
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2541
				__TS__ArrayMap( -- 2541
					decisions, -- 2541
					function(____, decision) return decision.tool end -- 2541
				), -- 2541
				"," -- 2541
			) -- 2541
		) -- 2541
		return ____awaiter_resolve(nil, { -- 2541
			success = true, -- 2543
			kind = "batch", -- 2544
			decisions = decisions, -- 2545
			content = messageContent, -- 2546
			reasoningContent = reasoningContent -- 2547
		}) -- 2547
	end) -- 2547
end -- 2328
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 2551
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2551
		Log( -- 2557
			"Info", -- 2557
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2557
		) -- 2557
		local lastError = initialError -- 2558
		local candidateRaw = "" -- 2559
		local candidateReasoning = nil -- 2560
		do -- 2560
			local attempt = 0 -- 2561
			while attempt < shared.llmMaxTry do -- 2561
				do -- 2561
					Log( -- 2562
						"Info", -- 2562
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2562
					) -- 2562
					local messages = buildXmlRepairMessages( -- 2563
						shared, -- 2564
						originalRaw, -- 2565
						originalReasoning, -- 2566
						candidateRaw, -- 2567
						candidateReasoning, -- 2568
						lastError, -- 2569
						attempt + 1 -- 2570
					) -- 2570
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2572
					if shared.stopToken.stopped then -- 2572
						return ____awaiter_resolve( -- 2572
							nil, -- 2572
							{ -- 2574
								success = false, -- 2574
								message = getCancelledReason(shared) -- 2574
							} -- 2574
						) -- 2574
					end -- 2574
					if not llmRes.success then -- 2574
						lastError = llmRes.message -- 2577
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2578
						goto __continue455 -- 2579
					end -- 2579
					candidateRaw = llmRes.text -- 2581
					candidateReasoning = llmRes.reasoningContent -- 2582
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2583
					if decision.success then -- 2583
						decision.reasoningContent = llmRes.reasoningContent -- 2585
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2586
						return ____awaiter_resolve(nil, decision) -- 2586
					end -- 2586
					lastError = decision.message -- 2589
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2590
				end -- 2590
				::__continue455:: -- 2590
				attempt = attempt + 1 -- 2561
			end -- 2561
		end -- 2561
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2592
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2592
	end) -- 2592
end -- 2551
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2600
	if attempt == nil then -- 2600
		attempt = 1 -- 2603
	end -- 2603
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2603
		local messages = buildDecisionMessages( -- 2606
			shared, -- 2607
			lastError, -- 2608
			attempt, -- 2609
			lastRaw, -- 2610
			"xml" -- 2611
		) -- 2611
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2613
		if shared.stopToken.stopped then -- 2613
			return ____awaiter_resolve( -- 2613
				nil, -- 2613
				{ -- 2615
					success = false, -- 2615
					message = getCancelledReason(shared) -- 2615
				} -- 2615
			) -- 2615
		end -- 2615
		if not llmRes.success then -- 2615
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2615
		end -- 2615
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2624
		if decision.success then -- 2624
			decision.reasoningContent = llmRes.reasoningContent -- 2626
			if not isToolAllowedForRole(shared, decision.tool) then -- 2626
				return ____awaiter_resolve( -- 2626
					nil, -- 2626
					self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2628
				) -- 2628
			end -- 2628
			return ____awaiter_resolve(nil, decision) -- 2628
		end -- 2628
		return ____awaiter_resolve( -- 2628
			nil, -- 2628
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 2637
		) -- 2637
	end) -- 2637
end -- 2600
function MainDecisionAgent.prototype.exec(self, input) -- 2640
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2640
		local shared = input.shared -- 2641
		if shared.stopToken.stopped then -- 2641
			return ____awaiter_resolve( -- 2641
				nil, -- 2641
				{ -- 2643
					success = false, -- 2643
					message = getCancelledReason(shared) -- 2643
				} -- 2643
			) -- 2643
		end -- 2643
		if shared.step >= shared.maxSteps then -- 2643
			Log( -- 2646
				"Warn", -- 2646
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2646
			) -- 2646
			return ____awaiter_resolve( -- 2646
				nil, -- 2646
				{ -- 2647
					success = false, -- 2647
					message = getMaxStepsReachedReason(shared) -- 2647
				} -- 2647
			) -- 2647
		end -- 2647
		if shared.decisionMode == "tool_calling" then -- 2647
			Log( -- 2651
				"Info", -- 2651
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2651
			) -- 2651
			local lastError = "tool calling validation failed" -- 2652
			local lastRaw = "" -- 2653
			local shouldFallbackToXml = false -- 2654
			do -- 2654
				local attempt = 0 -- 2655
				while attempt < shared.llmMaxTry do -- 2655
					Log( -- 2656
						"Info", -- 2656
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2656
					) -- 2656
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2657
					if shared.stopToken.stopped then -- 2657
						return ____awaiter_resolve( -- 2657
							nil, -- 2657
							{ -- 2664
								success = false, -- 2664
								message = getCancelledReason(shared) -- 2664
							} -- 2664
						) -- 2664
					end -- 2664
					if decision.success then -- 2664
						return ____awaiter_resolve(nil, decision) -- 2664
					end -- 2664
					lastError = decision.message -- 2669
					lastRaw = decision.raw or "" -- 2670
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2671
					if lastError == "missing tool call" then -- 2671
						shouldFallbackToXml = true -- 2673
						break -- 2674
					end -- 2674
					attempt = attempt + 1 -- 2655
				end -- 2655
			end -- 2655
			if shouldFallbackToXml then -- 2655
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2678
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2679
				do -- 2679
					local attempt = 0 -- 2680
					while attempt < shared.llmMaxTry do -- 2680
						Log( -- 2681
							"Info", -- 2681
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2681
						) -- 2681
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2682
						if shared.stopToken.stopped then -- 2682
							return ____awaiter_resolve( -- 2682
								nil, -- 2682
								{ -- 2689
									success = false, -- 2689
									message = getCancelledReason(shared) -- 2689
								} -- 2689
							) -- 2689
						end -- 2689
						if decision.success then -- 2689
							return ____awaiter_resolve(nil, decision) -- 2689
						end -- 2689
						lastError = decision.message -- 2694
						lastRaw = decision.raw or "" -- 2695
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2696
						attempt = attempt + 1 -- 2680
					end -- 2680
				end -- 2680
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2698
				return ____awaiter_resolve( -- 2698
					nil, -- 2698
					{ -- 2699
						success = false, -- 2699
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2699
					} -- 2699
				) -- 2699
			end -- 2699
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2701
			return ____awaiter_resolve( -- 2701
				nil, -- 2701
				{ -- 2702
					success = false, -- 2702
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2702
				} -- 2702
			) -- 2702
		end -- 2702
		local lastError = "xml validation failed" -- 2705
		local lastRaw = "" -- 2706
		do -- 2706
			local attempt = 0 -- 2707
			while attempt < shared.llmMaxTry do -- 2707
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2708
				if shared.stopToken.stopped then -- 2708
					return ____awaiter_resolve( -- 2708
						nil, -- 2708
						{ -- 2717
							success = false, -- 2717
							message = getCancelledReason(shared) -- 2717
						} -- 2717
					) -- 2717
				end -- 2717
				if decision.success then -- 2717
					return ____awaiter_resolve(nil, decision) -- 2717
				end -- 2717
				lastError = decision.message -- 2722
				lastRaw = decision.raw or "" -- 2723
				attempt = attempt + 1 -- 2707
			end -- 2707
		end -- 2707
		return ____awaiter_resolve( -- 2707
			nil, -- 2707
			{ -- 2725
				success = false, -- 2725
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2725
			} -- 2725
		) -- 2725
	end) -- 2725
end -- 2640
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2728
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2728
		local result = execRes -- 2729
		if not result.success then -- 2729
			if shared.stopToken.stopped then -- 2729
				shared.error = getCancelledReason(shared) -- 2732
				shared.done = true -- 2733
				return ____awaiter_resolve(nil, "done") -- 2733
			end -- 2733
			shared.error = result.message -- 2736
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2737
			shared.done = true -- 2738
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2739
			persistHistoryState(shared) -- 2743
			return ____awaiter_resolve(nil, "done") -- 2743
		end -- 2743
		if isDecisionBatchSuccess(result) then -- 2743
			local startStep = shared.step -- 2747
			local actions = {} -- 2748
			do -- 2748
				local i = 0 -- 2749
				while i < #result.decisions do -- 2749
					local decision = result.decisions[i + 1] -- 2750
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2751
					local step = startStep + i + 1 -- 2752
					local ____temp_58 -- 2753
					if i == 0 then -- 2753
						____temp_58 = decision.reason -- 2753
					else -- 2753
						____temp_58 = "" -- 2753
					end -- 2753
					local actionReason = ____temp_58 -- 2753
					local ____temp_59 -- 2754
					if i == 0 then -- 2754
						____temp_59 = decision.reasoningContent -- 2754
					else -- 2754
						____temp_59 = nil -- 2754
					end -- 2754
					local actionReasoningContent = ____temp_59 -- 2754
					emitAgentEvent(shared, { -- 2755
						type = "decision_made", -- 2756
						sessionId = shared.sessionId, -- 2757
						taskId = shared.taskId, -- 2758
						step = step, -- 2759
						tool = decision.tool, -- 2760
						reason = actionReason, -- 2761
						reasoningContent = actionReasoningContent, -- 2762
						params = decision.params -- 2763
					}) -- 2763
					local action = { -- 2765
						step = step, -- 2766
						toolCallId = toolCallId, -- 2767
						tool = decision.tool, -- 2768
						reason = actionReason or "", -- 2769
						reasoningContent = actionReasoningContent, -- 2770
						params = decision.params, -- 2771
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2772
					} -- 2772
					local ____shared_history_60 = shared.history -- 2772
					____shared_history_60[#____shared_history_60 + 1] = action -- 2774
					actions[#actions + 1] = action -- 2775
					i = i + 1 -- 2749
				end -- 2749
			end -- 2749
			shared.step = startStep + #actions -- 2777
			shared.pendingToolActions = actions -- 2778
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2779
			persistHistoryState(shared) -- 2785
			return ____awaiter_resolve(nil, "batch_tools") -- 2785
		end -- 2785
		if result.directSummary and result.directSummary ~= "" then -- 2785
			shared.response = result.directSummary -- 2789
			shared.done = true -- 2790
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2791
			persistHistoryState(shared) -- 2796
			return ____awaiter_resolve(nil, "done") -- 2796
		end -- 2796
		if result.tool == "finish" then -- 2796
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2800
			shared.response = finalMessage -- 2801
			shared.done = true -- 2802
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2803
			persistHistoryState(shared) -- 2808
			return ____awaiter_resolve(nil, "done") -- 2808
		end -- 2808
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2811
		shared.step = shared.step + 1 -- 2812
		local step = shared.step -- 2813
		emitAgentEvent(shared, { -- 2814
			type = "decision_made", -- 2815
			sessionId = shared.sessionId, -- 2816
			taskId = shared.taskId, -- 2817
			step = step, -- 2818
			tool = result.tool, -- 2819
			reason = result.reason, -- 2820
			reasoningContent = result.reasoningContent, -- 2821
			params = result.params -- 2822
		}) -- 2822
		local ____shared_history_61 = shared.history -- 2822
		____shared_history_61[#____shared_history_61 + 1] = { -- 2824
			step = step, -- 2825
			toolCallId = toolCallId, -- 2826
			tool = result.tool, -- 2827
			reason = result.reason or "", -- 2828
			reasoningContent = result.reasoningContent, -- 2829
			params = result.params, -- 2830
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2831
		} -- 2831
		local action = shared.history[#shared.history] -- 2833
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2834
		if AgentToolRegistry.canPreExecuteTool(action.tool) then -- 2834
			shared.pendingToolActions = {action} -- 2836
			persistHistoryState(shared) -- 2837
			return ____awaiter_resolve(nil, "batch_tools") -- 2837
		end -- 2837
		clearPreExecutedResults(shared) -- 2840
		persistHistoryState(shared) -- 2841
		return ____awaiter_resolve(nil, result.tool) -- 2841
	end) -- 2841
end -- 2728
local ReadFileAction = __TS__Class() -- 2846
ReadFileAction.name = "ReadFileAction" -- 2846
__TS__ClassExtends(ReadFileAction, Node) -- 2846
function ReadFileAction.prototype.prep(self, shared) -- 2847
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2847
		local last = shared.history[#shared.history] -- 2848
		if not last then -- 2848
			error( -- 2849
				__TS__New(Error, "no history"), -- 2849
				0 -- 2849
			) -- 2849
		end -- 2849
		emitAgentStartEvent(shared, last) -- 2850
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2851
		if __TS__StringTrim(path) == "" then -- 2851
			error( -- 2854
				__TS__New(Error, "missing path"), -- 2854
				0 -- 2854
			) -- 2854
		end -- 2854
		local ____path_64 = path -- 2856
		local ____shared_workingDir_65 = shared.workingDir -- 2858
		local ____temp_66 = shared.useChineseResponse and "zh" or "en" -- 2859
		local ____last_params_startLine_62 = last.params.startLine -- 2860
		if ____last_params_startLine_62 == nil then -- 2860
			____last_params_startLine_62 = 1 -- 2860
		end -- 2860
		local ____TS__Number_result_67 = __TS__Number(____last_params_startLine_62) -- 2860
		local ____last_params_endLine_63 = last.params.endLine -- 2861
		if ____last_params_endLine_63 == nil then -- 2861
			____last_params_endLine_63 = READ_FILE_DEFAULT_LIMIT -- 2861
		end -- 2861
		return ____awaiter_resolve( -- 2861
			nil, -- 2861
			{ -- 2855
				path = ____path_64, -- 2856
				tool = "read_file", -- 2857
				workDir = ____shared_workingDir_65, -- 2858
				docLanguage = ____temp_66, -- 2859
				startLine = ____TS__Number_result_67, -- 2860
				endLine = __TS__Number(____last_params_endLine_63) -- 2861
			} -- 2861
		) -- 2861
	end) -- 2861
end -- 2847
function ReadFileAction.prototype.exec(self, input) -- 2865
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2865
		return ____awaiter_resolve( -- 2865
			nil, -- 2865
			Tools.readFile( -- 2866
				input.workDir, -- 2867
				input.path, -- 2868
				__TS__Number(input.startLine or 1), -- 2869
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2870
				input.docLanguage -- 2871
			) -- 2871
		) -- 2871
	end) -- 2871
end -- 2865
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2875
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2875
		local result = execRes -- 2876
		local last = shared.history[#shared.history] -- 2877
		if last ~= nil then -- 2877
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2879
			appendToolResultMessage(shared, last) -- 2880
			emitAgentFinishEvent(shared, last) -- 2881
		end -- 2881
		persistHistoryState(shared) -- 2883
		__TS__Await(maybeCompressHistory(shared)) -- 2884
		persistHistoryState(shared) -- 2885
		return ____awaiter_resolve(nil, "main") -- 2885
	end) -- 2885
end -- 2875
local SearchFilesAction = __TS__Class() -- 2890
SearchFilesAction.name = "SearchFilesAction" -- 2890
__TS__ClassExtends(SearchFilesAction, Node) -- 2890
function SearchFilesAction.prototype.prep(self, shared) -- 2891
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2891
		local last = shared.history[#shared.history] -- 2892
		if not last then -- 2892
			error( -- 2893
				__TS__New(Error, "no history"), -- 2893
				0 -- 2893
			) -- 2893
		end -- 2893
		emitAgentStartEvent(shared, last) -- 2894
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2894
	end) -- 2894
end -- 2891
function SearchFilesAction.prototype.exec(self, input) -- 2898
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2898
		local params = input.params -- 2899
		local ____Tools_searchFiles_81 = Tools.searchFiles -- 2900
		local ____input_workDir_74 = input.workDir -- 2901
		local ____temp_75 = params.path or "" -- 2902
		local ____temp_76 = params.pattern or "" -- 2903
		local ____params_globs_77 = params.globs -- 2904
		local ____params_useRegex_78 = params.useRegex -- 2905
		local ____params_caseSensitive_79 = params.caseSensitive -- 2906
		local ____math_max_70 = math.max -- 2909
		local ____math_floor_69 = math.floor -- 2909
		local ____params_limit_68 = params.limit -- 2909
		if ____params_limit_68 == nil then -- 2909
			____params_limit_68 = SEARCH_FILES_LIMIT_DEFAULT -- 2909
		end -- 2909
		local ____math_max_70_result_80 = ____math_max_70( -- 2909
			1, -- 2909
			____math_floor_69(__TS__Number(____params_limit_68)) -- 2909
		) -- 2909
		local ____math_max_73 = math.max -- 2910
		local ____math_floor_72 = math.floor -- 2910
		local ____params_offset_71 = params.offset -- 2910
		if ____params_offset_71 == nil then -- 2910
			____params_offset_71 = 0 -- 2910
		end -- 2910
		local result = __TS__Await(____Tools_searchFiles_81({ -- 2900
			workDir = ____input_workDir_74, -- 2901
			path = ____temp_75, -- 2902
			pattern = ____temp_76, -- 2903
			globs = ____params_globs_77, -- 2904
			useRegex = ____params_useRegex_78, -- 2905
			caseSensitive = ____params_caseSensitive_79, -- 2906
			includeContent = true, -- 2907
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2908
			limit = ____math_max_70_result_80, -- 2909
			offset = ____math_max_73( -- 2910
				0, -- 2910
				____math_floor_72(__TS__Number(____params_offset_71)) -- 2910
			), -- 2910
			groupByFile = params.groupByFile == true -- 2911
		})) -- 2911
		return ____awaiter_resolve(nil, result) -- 2911
	end) -- 2911
end -- 2898
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2916
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2916
		local last = shared.history[#shared.history] -- 2917
		if last ~= nil then -- 2917
			local result = execRes -- 2919
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2920
			appendToolResultMessage(shared, last) -- 2921
			emitAgentFinishEvent(shared, last) -- 2922
		end -- 2922
		persistHistoryState(shared) -- 2924
		__TS__Await(maybeCompressHistory(shared)) -- 2925
		persistHistoryState(shared) -- 2926
		return ____awaiter_resolve(nil, "main") -- 2926
	end) -- 2926
end -- 2916
local SearchDoraAPIAction = __TS__Class() -- 2931
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2931
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2931
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2932
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2932
		local last = shared.history[#shared.history] -- 2933
		if not last then -- 2933
			error( -- 2934
				__TS__New(Error, "no history"), -- 2934
				0 -- 2934
			) -- 2934
		end -- 2934
		emitAgentStartEvent(shared, last) -- 2935
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2935
	end) -- 2935
end -- 2932
function SearchDoraAPIAction.prototype.exec(self, input) -- 2939
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2939
		local params = input.params -- 2940
		local ____Tools_searchDoraAPI_89 = Tools.searchDoraAPI -- 2941
		local ____temp_85 = params.pattern or "" -- 2942
		local ____temp_86 = params.docSource or "api" -- 2943
		local ____temp_87 = input.useChineseResponse and "zh" or "en" -- 2944
		local ____temp_88 = params.programmingLanguage or "ts" -- 2945
		local ____math_min_84 = math.min -- 2946
		local ____math_max_83 = math.max -- 2946
		local ____params_limit_82 = params.limit -- 2946
		if ____params_limit_82 == nil then -- 2946
			____params_limit_82 = 8 -- 2946
		end -- 2946
		local result = __TS__Await(____Tools_searchDoraAPI_89({ -- 2941
			pattern = ____temp_85, -- 2942
			docSource = ____temp_86, -- 2943
			docLanguage = ____temp_87, -- 2944
			programmingLanguage = ____temp_88, -- 2945
			limit = ____math_min_84( -- 2946
				SEARCH_DORA_API_LIMIT_MAX, -- 2946
				____math_max_83( -- 2946
					1, -- 2946
					__TS__Number(____params_limit_82) -- 2946
				) -- 2946
			), -- 2946
			useRegex = params.useRegex, -- 2947
			caseSensitive = false, -- 2948
			includeContent = true, -- 2949
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2950
		})) -- 2950
		return ____awaiter_resolve(nil, result) -- 2950
	end) -- 2950
end -- 2939
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2955
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2955
		local last = shared.history[#shared.history] -- 2956
		if last ~= nil then -- 2956
			local result = execRes -- 2958
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2959
			appendToolResultMessage(shared, last) -- 2960
			emitAgentFinishEvent(shared, last) -- 2961
		end -- 2961
		persistHistoryState(shared) -- 2963
		__TS__Await(maybeCompressHistory(shared)) -- 2964
		persistHistoryState(shared) -- 2965
		return ____awaiter_resolve(nil, "main") -- 2965
	end) -- 2965
end -- 2955
local ListFilesAction = __TS__Class() -- 2970
ListFilesAction.name = "ListFilesAction" -- 2970
__TS__ClassExtends(ListFilesAction, Node) -- 2970
function ListFilesAction.prototype.prep(self, shared) -- 2971
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2971
		local last = shared.history[#shared.history] -- 2972
		if not last then -- 2972
			error( -- 2973
				__TS__New(Error, "no history"), -- 2973
				0 -- 2973
			) -- 2973
		end -- 2973
		emitAgentStartEvent(shared, last) -- 2974
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2974
	end) -- 2974
end -- 2971
function ListFilesAction.prototype.exec(self, input) -- 2978
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2978
		local params = input.params -- 2979
		local ____Tools_listFiles_96 = Tools.listFiles -- 2980
		local ____input_workDir_93 = input.workDir -- 2981
		local ____temp_94 = params.path or "" -- 2982
		local ____params_globs_95 = params.globs -- 2983
		local ____math_max_92 = math.max -- 2984
		local ____math_floor_91 = math.floor -- 2984
		local ____params_maxEntries_90 = params.maxEntries -- 2984
		if ____params_maxEntries_90 == nil then -- 2984
			____params_maxEntries_90 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2984
		end -- 2984
		local result = ____Tools_listFiles_96({ -- 2980
			workDir = ____input_workDir_93, -- 2981
			path = ____temp_94, -- 2982
			globs = ____params_globs_95, -- 2983
			maxEntries = ____math_max_92( -- 2984
				1, -- 2984
				____math_floor_91(__TS__Number(____params_maxEntries_90)) -- 2984
			) -- 2984
		}) -- 2984
		return ____awaiter_resolve(nil, result) -- 2984
	end) -- 2984
end -- 2978
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2989
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2989
		local last = shared.history[#shared.history] -- 2990
		if last ~= nil then -- 2990
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2992
			appendToolResultMessage(shared, last) -- 2993
			emitAgentFinishEvent(shared, last) -- 2994
		end -- 2994
		persistHistoryState(shared) -- 2996
		__TS__Await(maybeCompressHistory(shared)) -- 2997
		persistHistoryState(shared) -- 2998
		return ____awaiter_resolve(nil, "main") -- 2998
	end) -- 2998
end -- 2989
local DeleteFileAction = __TS__Class() -- 3003
DeleteFileAction.name = "DeleteFileAction" -- 3003
__TS__ClassExtends(DeleteFileAction, Node) -- 3003
function DeleteFileAction.prototype.prep(self, shared) -- 3004
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3004
		local last = shared.history[#shared.history] -- 3005
		if not last then -- 3005
			error( -- 3006
				__TS__New(Error, "no history"), -- 3006
				0 -- 3006
			) -- 3006
		end -- 3006
		emitAgentStartEvent(shared, last) -- 3007
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3008
		if __TS__StringTrim(targetFile) == "" then -- 3008
			error( -- 3011
				__TS__New(Error, "missing target_file"), -- 3011
				0 -- 3011
			) -- 3011
		end -- 3011
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3011
	end) -- 3011
end -- 3004
function DeleteFileAction.prototype.exec(self, input) -- 3015
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3015
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3016
		if not result.success then -- 3016
			return ____awaiter_resolve(nil, result) -- 3016
		end -- 3016
		return ____awaiter_resolve(nil, { -- 3016
			success = true, -- 3024
			changed = true, -- 3025
			mode = "delete", -- 3026
			checkpointId = result.checkpointId, -- 3027
			checkpointSeq = result.checkpointSeq, -- 3028
			files = {{path = input.targetFile, op = "delete"}} -- 3029
		}) -- 3029
	end) -- 3029
end -- 3015
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3033
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3033
		local last = shared.history[#shared.history] -- 3034
		if last ~= nil then -- 3034
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3036
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3037
			appendToolResultMessage(shared, last) -- 3038
			emitAgentFinishEvent(shared, last) -- 3039
			local result = last.result -- 3040
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3040
				emitAgentEvent(shared, { -- 3045
					type = "checkpoint_created", -- 3046
					sessionId = shared.sessionId, -- 3047
					taskId = shared.taskId, -- 3048
					step = last.step, -- 3049
					tool = "delete_file", -- 3050
					checkpointId = result.checkpointId, -- 3051
					checkpointSeq = result.checkpointSeq, -- 3052
					files = result.files -- 3053
				}) -- 3053
			end -- 3053
		end -- 3053
		persistHistoryState(shared) -- 3060
		__TS__Await(maybeCompressHistory(shared)) -- 3061
		persistHistoryState(shared) -- 3062
		return ____awaiter_resolve(nil, "main") -- 3062
	end) -- 3062
end -- 3033
local BuildAction = __TS__Class() -- 3067
BuildAction.name = "BuildAction" -- 3067
__TS__ClassExtends(BuildAction, Node) -- 3067
function BuildAction.prototype.prep(self, shared) -- 3068
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3068
		local last = shared.history[#shared.history] -- 3069
		if not last then -- 3069
			error( -- 3070
				__TS__New(Error, "no history"), -- 3070
				0 -- 3070
			) -- 3070
		end -- 3070
		emitAgentStartEvent(shared, last) -- 3071
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3071
	end) -- 3071
end -- 3068
function BuildAction.prototype.exec(self, input) -- 3075
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3075
		local params = input.params -- 3076
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3077
		return ____awaiter_resolve(nil, result) -- 3077
	end) -- 3077
end -- 3075
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3084
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3084
		local last = shared.history[#shared.history] -- 3085
		if last ~= nil then -- 3085
			last.result = sanitizeBuildResultForHistory(execRes) -- 3087
			appendToolResultMessage(shared, last) -- 3088
			emitAgentFinishEvent(shared, last) -- 3089
		end -- 3089
		persistHistoryState(shared) -- 3091
		__TS__Await(maybeCompressHistory(shared)) -- 3092
		persistHistoryState(shared) -- 3093
		return ____awaiter_resolve(nil, "main") -- 3093
	end) -- 3093
end -- 3084
local SpawnSubAgentAction = __TS__Class() -- 3098
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3098
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3098
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3099
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3099
		local last = shared.history[#shared.history] -- 3109
		if not last then -- 3109
			error( -- 3110
				__TS__New(Error, "no history"), -- 3110
				0 -- 3110
			) -- 3110
		end -- 3110
		emitAgentStartEvent(shared, last) -- 3111
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3112
			last.params.filesHint, -- 3113
			function(____, item) return type(item) == "string" end -- 3113
		) or nil -- 3113
		return ____awaiter_resolve( -- 3113
			nil, -- 3113
			{ -- 3115
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3116
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3117
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3118
				filesHint = filesHint, -- 3119
				sessionId = shared.sessionId, -- 3120
				projectRoot = shared.workingDir, -- 3121
				spawnSubAgent = shared.spawnSubAgent, -- 3122
				disabledAgentTools = shared.disabledAgentTools -- 3123
			} -- 3123
		) -- 3123
	end) -- 3123
end -- 3099
function SpawnSubAgentAction.prototype.exec(self, input) -- 3127
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3127
		if not input.spawnSubAgent then -- 3127
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3127
		end -- 3127
		if input.sessionId == nil or input.sessionId <= 0 then -- 3127
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3127
		end -- 3127
		local ____Log_102 = Log -- 3143
		local ____temp_99 = #input.title -- 3143
		local ____temp_100 = #input.prompt -- 3143
		local ____temp_101 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3143
		local ____opt_97 = input.filesHint -- 3143
		____Log_102( -- 3143
			"Info", -- 3143
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_99)) .. " prompt_len=") .. tostring(____temp_100)) .. " expected_len=") .. tostring(____temp_101)) .. " files_hint_count=") .. tostring(____opt_97 and #____opt_97 or 0) -- 3143
		) -- 3143
		local result = __TS__Await(input.spawnSubAgent({ -- 3144
			parentSessionId = input.sessionId, -- 3145
			projectRoot = input.projectRoot, -- 3146
			title = input.title, -- 3147
			prompt = input.prompt, -- 3148
			expectedOutput = input.expectedOutput, -- 3149
			filesHint = input.filesHint, -- 3150
			disabledAgentTools = input.disabledAgentTools -- 3151
		})) -- 3151
		if not result.success then -- 3151
			return ____awaiter_resolve(nil, result) -- 3151
		end -- 3151
		return ____awaiter_resolve(nil, { -- 3151
			success = true, -- 3157
			sessionId = result.sessionId, -- 3158
			taskId = result.taskId, -- 3159
			title = result.title, -- 3160
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3161
		}) -- 3161
	end) -- 3161
end -- 3127
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3165
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3165
		local last = shared.history[#shared.history] -- 3166
		if last ~= nil then -- 3166
			last.result = execRes -- 3168
			appendToolResultMessage(shared, last) -- 3169
			emitAgentFinishEvent(shared, last) -- 3170
		end -- 3170
		persistHistoryState(shared) -- 3172
		__TS__Await(maybeCompressHistory(shared)) -- 3173
		persistHistoryState(shared) -- 3174
		return ____awaiter_resolve(nil, "main") -- 3174
	end) -- 3174
end -- 3165
local ListSubAgentsAction = __TS__Class() -- 3179
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3179
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3179
function ListSubAgentsAction.prototype.prep(self, shared) -- 3180
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3180
		local last = shared.history[#shared.history] -- 3189
		if not last then -- 3189
			error( -- 3190
				__TS__New(Error, "no history"), -- 3190
				0 -- 3190
			) -- 3190
		end -- 3190
		emitAgentStartEvent(shared, last) -- 3191
		return ____awaiter_resolve( -- 3191
			nil, -- 3191
			{ -- 3192
				sessionId = shared.sessionId, -- 3193
				projectRoot = shared.workingDir, -- 3194
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3195
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3196
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3197
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3198
				listSubAgents = shared.listSubAgents -- 3199
			} -- 3199
		) -- 3199
	end) -- 3199
end -- 3180
function ListSubAgentsAction.prototype.exec(self, input) -- 3203
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3203
		if not input.listSubAgents then -- 3203
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3203
		end -- 3203
		if input.sessionId == nil or input.sessionId <= 0 then -- 3203
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3203
		end -- 3203
		local result = __TS__Await(input.listSubAgents({ -- 3218
			sessionId = input.sessionId, -- 3219
			projectRoot = input.projectRoot, -- 3220
			status = input.status, -- 3221
			limit = input.limit, -- 3222
			offset = input.offset, -- 3223
			query = input.query -- 3224
		})) -- 3224
		return ____awaiter_resolve(nil, result) -- 3224
	end) -- 3224
end -- 3203
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3229
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3229
		local last = shared.history[#shared.history] -- 3230
		if last ~= nil then -- 3230
			last.result = execRes -- 3232
			appendToolResultMessage(shared, last) -- 3233
			emitAgentFinishEvent(shared, last) -- 3234
		end -- 3234
		persistHistoryState(shared) -- 3236
		__TS__Await(maybeCompressHistory(shared)) -- 3237
		persistHistoryState(shared) -- 3238
		return ____awaiter_resolve(nil, "main") -- 3238
	end) -- 3238
end -- 3229
EditFileAction = __TS__Class() -- 3243
EditFileAction.name = "EditFileAction" -- 3243
__TS__ClassExtends(EditFileAction, Node) -- 3243
function EditFileAction.prototype.prep(self, shared) -- 3244
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3244
		local last = shared.history[#shared.history] -- 3245
		if not last then -- 3245
			error( -- 3246
				__TS__New(Error, "no history"), -- 3246
				0 -- 3246
			) -- 3246
		end -- 3246
		emitAgentStartEvent(shared, last) -- 3247
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3248
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3251
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3252
		if __TS__StringTrim(path) == "" then -- 3252
			error( -- 3253
				__TS__New(Error, "missing path"), -- 3253
				0 -- 3253
			) -- 3253
		end -- 3253
		return ____awaiter_resolve(nil, { -- 3253
			path = path, -- 3254
			oldStr = oldStr, -- 3254
			newStr = newStr, -- 3254
			taskId = shared.taskId, -- 3254
			workDir = shared.workingDir -- 3254
		}) -- 3254
	end) -- 3254
end -- 3244
function EditFileAction.prototype.exec(self, input) -- 3257
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3257
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3258
		if not readRes.success then -- 3258
			if input.oldStr ~= "" then -- 3258
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3258
			end -- 3258
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3263
			if not createRes.success then -- 3263
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3263
			end -- 3263
			return ____awaiter_resolve(nil, { -- 3263
				success = true, -- 3271
				changed = true, -- 3272
				mode = "create", -- 3273
				checkpointId = createRes.checkpointId, -- 3274
				checkpointSeq = createRes.checkpointSeq, -- 3275
				files = {{path = input.path, op = "create"}} -- 3276
			}) -- 3276
		end -- 3276
		if input.oldStr == "" then -- 3276
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3280
			if not overwriteRes.success then -- 3280
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3280
			end -- 3280
			return ____awaiter_resolve(nil, { -- 3280
				success = true, -- 3288
				changed = true, -- 3289
				mode = "overwrite", -- 3290
				checkpointId = overwriteRes.checkpointId, -- 3291
				checkpointSeq = overwriteRes.checkpointSeq, -- 3292
				files = {{path = input.path, op = "write"}} -- 3293
			}) -- 3293
		end -- 3293
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3298
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3299
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3300
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3303
		if occurrences == 0 then -- 3303
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3305
			if not indentTolerant.success then -- 3305
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3305
			end -- 3305
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3309
			if not applyRes.success then -- 3309
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3309
			end -- 3309
			return ____awaiter_resolve(nil, { -- 3309
				success = true, -- 3317
				changed = true, -- 3318
				mode = "replace_indent_tolerant", -- 3319
				checkpointId = applyRes.checkpointId, -- 3320
				checkpointSeq = applyRes.checkpointSeq, -- 3321
				files = {{path = input.path, op = "write"}} -- 3322
			}) -- 3322
		end -- 3322
		if occurrences > 1 then -- 3322
			return ____awaiter_resolve( -- 3322
				nil, -- 3322
				{ -- 3326
					success = false, -- 3326
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3326
				} -- 3326
			) -- 3326
		end -- 3326
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3330
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3331
		if not applyRes.success then -- 3331
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3331
		end -- 3331
		return ____awaiter_resolve(nil, { -- 3331
			success = true, -- 3339
			changed = true, -- 3340
			mode = "replace", -- 3341
			checkpointId = applyRes.checkpointId, -- 3342
			checkpointSeq = applyRes.checkpointSeq, -- 3343
			files = {{path = input.path, op = "write"}} -- 3344
		}) -- 3344
	end) -- 3344
end -- 3257
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3348
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3348
		local last = shared.history[#shared.history] -- 3349
		if last ~= nil then -- 3349
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3351
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3352
			appendToolResultMessage(shared, last) -- 3353
			emitAgentFinishEvent(shared, last) -- 3354
			local result = last.result -- 3355
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3355
				emitAgentEvent(shared, { -- 3360
					type = "checkpoint_created", -- 3361
					sessionId = shared.sessionId, -- 3362
					taskId = shared.taskId, -- 3363
					step = last.step, -- 3364
					tool = last.tool, -- 3365
					checkpointId = result.checkpointId, -- 3366
					checkpointSeq = result.checkpointSeq, -- 3367
					files = result.files -- 3368
				}) -- 3368
			end -- 3368
		end -- 3368
		persistHistoryState(shared) -- 3375
		__TS__Await(maybeCompressHistory(shared)) -- 3376
		persistHistoryState(shared) -- 3377
		return ____awaiter_resolve(nil, "main") -- 3377
	end) -- 3377
end -- 3348
local FetchUrlAction = __TS__Class() -- 3382
FetchUrlAction.name = "FetchUrlAction" -- 3382
__TS__ClassExtends(FetchUrlAction, Node) -- 3382
function FetchUrlAction.prototype.prep(self, shared) -- 3383
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3383
		local last = shared.history[#shared.history] -- 3384
		if not last then -- 3384
			error( -- 3385
				__TS__New(Error, "no history"), -- 3385
				0 -- 3385
			) -- 3385
		end -- 3385
		emitAgentStartEvent(shared, last) -- 3386
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3386
	end) -- 3386
end -- 3383
function FetchUrlAction.prototype.exec(self, input) -- 3390
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3390
		return ____awaiter_resolve( -- 3390
			nil, -- 3390
			executeToolAction(input.shared, input.action) -- 3391
		) -- 3391
	end) -- 3391
end -- 3390
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3394
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3394
		local last = shared.history[#shared.history] -- 3395
		if last ~= nil then -- 3395
			last.result = execRes -- 3397
			appendToolResultMessage(shared, last) -- 3398
			emitAgentFinishEvent(shared, last) -- 3399
		end -- 3399
		persistHistoryState(shared) -- 3401
		__TS__Await(maybeCompressHistory(shared)) -- 3402
		persistHistoryState(shared) -- 3403
		return ____awaiter_resolve(nil, "main") -- 3403
	end) -- 3403
end -- 3394
local function emitCheckpointEventForAction(shared, action) -- 3408
	local result = action.result -- 3409
	if not result then -- 3409
		return -- 3410
	end -- 3410
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3410
		emitAgentEvent(shared, { -- 3415
			type = "checkpoint_created", -- 3416
			sessionId = shared.sessionId, -- 3417
			taskId = shared.taskId, -- 3418
			step = action.step, -- 3419
			tool = action.tool, -- 3420
			checkpointId = result.checkpointId, -- 3421
			checkpointSeq = result.checkpointSeq, -- 3422
			files = result.files -- 3423
		}) -- 3423
	end -- 3423
end -- 3408
local function canRunBatchActionInParallel(self, action) -- 3785
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 3786
end -- 3785
local function partitionToolCalls(actions) -- 3794
	local batches = {} -- 3795
	do -- 3795
		local i = 0 -- 3796
		while i < #actions do -- 3796
			local action = actions[i + 1] -- 3797
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3798
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3799
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3799
				local ____lastBatch_actions_137 = lastBatch.actions -- 3799
				____lastBatch_actions_137[#____lastBatch_actions_137 + 1] = action -- 3801
			else -- 3801
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3803
			end -- 3803
			i = i + 1 -- 3796
		end -- 3796
	end -- 3796
	return batches -- 3806
end -- 3794
local BatchToolAction = __TS__Class() -- 3809
BatchToolAction.name = "BatchToolAction" -- 3809
__TS__ClassExtends(BatchToolAction, Node) -- 3809
function BatchToolAction.prototype.prep(self, shared) -- 3810
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3810
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3810
	end) -- 3810
end -- 3810
function BatchToolAction.prototype.exec(self, input) -- 3814
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3814
		local shared = input.shared -- 3815
		local preExecuted = shared.preExecutedResults -- 3816
		local batches = partitionToolCalls(input.actions) -- 3817
		local parallelBatchCount = #__TS__ArrayFilter( -- 3818
			batches, -- 3818
			function(____, b) return b.isConcurrencySafe end -- 3818
		) -- 3818
		local serialBatchCount = #__TS__ArrayFilter( -- 3819
			batches, -- 3819
			function(____, b) return not b.isConcurrencySafe end -- 3819
		) -- 3819
		Log( -- 3820
			"Info", -- 3820
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3820
		) -- 3820
		do -- 3820
			local batchIdx = 0 -- 3822
			while batchIdx < #batches do -- 3822
				do -- 3822
					local batch = batches[batchIdx + 1] -- 3823
					if shared.stopToken.stopped then -- 3823
						for ____, action in ipairs(batch.actions) do -- 3825
							if not action.result then -- 3825
								action.result = { -- 3827
									success = false, -- 3827
									message = getCancelledReason(shared) -- 3827
								} -- 3827
							end -- 3827
						end -- 3827
						goto __continue640 -- 3830
					end -- 3830
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3830
						local preExecCount = #__TS__ArrayFilter( -- 3834
							batch.actions, -- 3834
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3834
						) -- 3834
						Log( -- 3835
							"Info", -- 3835
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3835
						) -- 3835
						do -- 3835
							local i = 0 -- 3836
							while i < #batch.actions do -- 3836
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3837
								i = i + 1 -- 3836
							end -- 3836
						end -- 3836
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3839
							batch.actions, -- 3839
							function(____, action) -- 3839
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3839
									if shared.stopToken.stopped then -- 3839
										action.result = { -- 3841
											success = false, -- 3841
											message = getCancelledReason(shared) -- 3841
										} -- 3841
										return ____awaiter_resolve(nil, action) -- 3841
									end -- 3841
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3844
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3845
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3846
									return ____awaiter_resolve(nil, action) -- 3846
								end) -- 3846
							end -- 3839
						))) -- 3839
						do -- 3839
							local i = 0 -- 3849
							while i < #batch.actions do -- 3849
								local action = batch.actions[i + 1] -- 3850
								if not action.result then -- 3850
									action.result = {success = false, message = "tool did not produce a result"} -- 3852
								end -- 3852
								appendToolResultMessage(shared, action) -- 3854
								emitAgentFinishEvent(shared, action) -- 3855
								emitCheckpointEventForAction(shared, action) -- 3856
								i = i + 1 -- 3849
							end -- 3849
						end -- 3849
					else -- 3849
						Log( -- 3859
							"Info", -- 3859
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3859
						) -- 3859
						do -- 3859
							local i = 0 -- 3860
							while i < #batch.actions do -- 3860
								local action = batch.actions[i + 1] -- 3861
								emitAgentStartEvent(shared, action) -- 3862
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3863
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3864
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3865
								appendToolResultMessage(shared, action) -- 3866
								emitAgentFinishEvent(shared, action) -- 3867
								emitCheckpointEventForAction(shared, action) -- 3868
								persistHistoryState(shared) -- 3869
								if shared.stopToken.stopped then -- 3869
									break -- 3871
								end -- 3871
								i = i + 1 -- 3860
							end -- 3860
						end -- 3860
					end -- 3860
				end -- 3860
				::__continue640:: -- 3860
				batchIdx = batchIdx + 1 -- 3822
			end -- 3822
		end -- 3822
		persistHistoryState(shared) -- 3876
		return ____awaiter_resolve(nil, input.actions) -- 3876
	end) -- 3876
end -- 3814
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3880
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3880
		shared.pendingToolActions = nil -- 3881
		shared.preExecutedResults = nil -- 3882
		persistHistoryState(shared) -- 3883
		__TS__Await(maybeCompressHistory(shared)) -- 3884
		persistHistoryState(shared) -- 3885
		return ____awaiter_resolve(nil, "main") -- 3885
	end) -- 3885
end -- 3880
local EndNode = __TS__Class() -- 3890
EndNode.name = "EndNode" -- 3890
__TS__ClassExtends(EndNode, Node) -- 3890
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3891
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3891
		return ____awaiter_resolve(nil, nil) -- 3891
	end) -- 3891
end -- 3891
local CodingAgentFlow = __TS__Class() -- 3896
CodingAgentFlow.name = "CodingAgentFlow" -- 3896
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3896
function CodingAgentFlow.prototype.____constructor(self, role) -- 3897
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3898
	local read = __TS__New(ReadFileAction, 1, 0) -- 3899
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3900
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3901
	local list = __TS__New(ListFilesAction, 1, 0) -- 3902
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3903
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3904
	local build = __TS__New(BuildAction, 1, 0) -- 3905
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3906
	local edit = __TS__New(EditFileAction, 1, 0) -- 3907
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 3908
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 3909
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3910
	local done = __TS__New(EndNode, 1, 0) -- 3911
	main:on("batch_tools", batch) -- 3913
	main:on("grep_files", search) -- 3914
	main:on("search_dora_api", searchDora) -- 3915
	main:on("glob_files", list) -- 3916
	main:on("fetch_url", fetch) -- 3917
	main:on("execute_command", exec) -- 3918
	if role == "main" then -- 3918
		main:on("read_file", read) -- 3920
		main:on("delete_file", del) -- 3921
		main:on("build", build) -- 3922
		main:on("edit_file", edit) -- 3923
		main:on("list_sub_agents", listSub) -- 3924
		main:on("spawn_sub_agent", spawn) -- 3925
	else -- 3925
		main:on("read_file", read) -- 3927
		main:on("delete_file", del) -- 3928
		main:on("build", build) -- 3929
		main:on("edit_file", edit) -- 3930
	end -- 3930
	main:on("done", done) -- 3932
	search:on("main", main) -- 3934
	searchDora:on("main", main) -- 3935
	list:on("main", main) -- 3936
	listSub:on("main", main) -- 3937
	spawn:on("main", main) -- 3938
	batch:on("main", main) -- 3939
	read:on("main", main) -- 3940
	del:on("main", main) -- 3941
	build:on("main", main) -- 3942
	edit:on("main", main) -- 3943
	fetch:on("main", main) -- 3944
	Flow.prototype.____constructor(self, main) -- 3946
end -- 3897
local function runCodingAgentAsync(options) -- 3968
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3968
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3968
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3968
		end -- 3968
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3972
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3973
		if not llmConfigRes.success then -- 3973
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3973
		end -- 3973
		local llmConfig = llmConfigRes.config -- 3979
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3980
		if not taskRes.success then -- 3980
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3980
		end -- 3980
		local compressor = __TS__New(MemoryCompressor, { -- 3987
			compressionThreshold = 0.8, -- 3988
			compressionTargetThreshold = 0.5, -- 3989
			maxCompressionRounds = 3, -- 3990
			projectDir = options.workDir, -- 3991
			llmConfig = llmConfig, -- 3992
			promptPack = options.promptPack, -- 3993
			scope = options.memoryScope -- 3994
		}) -- 3994
		local persistedSession = compressor:getStorage():readSessionState() -- 3996
		local promptPack = compressor:getPromptPack() -- 3997
		local shared = { -- 3999
			sessionId = options.sessionId, -- 4000
			taskId = taskRes.taskId, -- 4001
			role = options.role or "main", -- 4002
			maxSteps = math.max( -- 4003
				1, -- 4003
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4003
			), -- 4003
			llmMaxTry = math.max( -- 4004
				1, -- 4004
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4004
			), -- 4004
			step = 0, -- 4005
			done = false, -- 4006
			stopToken = options.stopToken or ({stopped = false}), -- 4007
			response = "", -- 4008
			userQuery = normalizedPrompt, -- 4009
			workingDir = options.workDir, -- 4010
			useChineseResponse = options.useChineseResponse == true, -- 4011
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4012
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4015
			llmConfig = llmConfig, -- 4016
			onEvent = options.onEvent, -- 4017
			promptPack = promptPack, -- 4018
			history = {}, -- 4019
			messages = persistedSession.messages, -- 4020
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4021
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4022
			memory = {compressor = compressor}, -- 4024
			skills = {loader = AgentSkills.createSkillsLoader({projectDir = options.workDir})}, -- 4028
			spawnSubAgent = options.spawnSubAgent, -- 4033
			listSubAgents = options.listSubAgents, -- 4034
			disabledAgentTools = options.disabledAgentTools or ({}) -- 4035
		} -- 4035
		local ____hasReturned, ____returnValue -- 4035
		local ____try = __TS__AsyncAwaiter(function() -- 4035
			emitAgentEvent(shared, { -- 4039
				type = "task_started", -- 4040
				sessionId = shared.sessionId, -- 4041
				taskId = shared.taskId, -- 4042
				prompt = shared.userQuery, -- 4043
				workDir = shared.workingDir, -- 4044
				maxSteps = shared.maxSteps -- 4045
			}) -- 4045
			if shared.stopToken.stopped then -- 4045
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4048
				____hasReturned = true -- 4049
				____returnValue = emitAgentTaskFinishEvent( -- 4049
					shared, -- 4049
					false, -- 4049
					getCancelledReason(shared) -- 4049
				) -- 4049
				return -- 4049
			end -- 4049
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4051
			local promptCommand = getPromptCommand(shared.userQuery) -- 4052
			if promptCommand == "clear" then -- 4052
				____hasReturned = true -- 4054
				____returnValue = clearSessionHistory(shared) -- 4054
				return -- 4054
			end -- 4054
			if promptCommand == "compact" then -- 4054
				if shared.role == "sub" then -- 4054
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4058
					____hasReturned = true -- 4059
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4059
					return -- 4059
				end -- 4059
				____hasReturned = true -- 4067
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4067
				return -- 4067
			end -- 4067
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4069
			persistHistoryState(shared) -- 4073
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4074
			__TS__Await(flow:run(shared)) -- 4075
			if shared.stopToken.stopped then -- 4075
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4077
				____hasReturned = true -- 4078
				____returnValue = emitAgentTaskFinishEvent( -- 4078
					shared, -- 4078
					false, -- 4078
					getCancelledReason(shared) -- 4078
				) -- 4078
				return -- 4078
			end -- 4078
			if shared.error then -- 4078
				____hasReturned = true -- 4081
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4081
				return -- 4081
			end -- 4081
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4084
			____hasReturned = true -- 4085
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4085
			return -- 4085
		end) -- 4085
		____try = ____try.catch( -- 4085
			____try, -- 4085
			function(____, e) -- 4085
				return __TS__AsyncAwaiter(function() -- 4085
					____hasReturned = true -- 4088
					____returnValue = finalizeAgentFailure( -- 4088
						shared, -- 4088
						tostring(e) -- 4088
					) -- 4088
					return -- 4088
				end) -- 4088
			end -- 4088
		) -- 4088
		__TS__Await(____try) -- 4038
		if ____hasReturned then -- 4038
			return ____awaiter_resolve(nil, ____returnValue) -- 4038
		end -- 4038
	end) -- 4038
end -- 3968
function ____exports.runCodingAgent(options, callback) -- 4092
	local ____self_140 = runCodingAgentAsync(options) -- 4092
	____self_140["then"]( -- 4092
		____self_140, -- 4092
		function(____, result) return callback(result) end -- 4093
	) -- 4093
end -- 4092
return ____exports -- 4092