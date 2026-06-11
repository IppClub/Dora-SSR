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
	local ordered = __TS__ArraySort( -- 794
		__TS__ArraySlice(messages), -- 794
		function(____, a, b) -- 794
			local aFailed = a.success ~= true -- 795
			local bFailed = b.success ~= true -- 796
			if aFailed == bFailed then -- 796
				return 0 -- 797
			end -- 797
			return aFailed and -1 or 1 -- 798
		end -- 794
	) -- 794
	local shown = math.min(#ordered, HISTORY_BUILD_MAX_MESSAGES) -- 800
	local sanitized = {} -- 801
	do -- 801
		local i = 0 -- 802
		while i < shown do -- 802
			local item = ordered[i + 1] -- 803
			local next = {} -- 804
			for key in pairs(item) do -- 805
				local value = item[key] -- 806
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 807
			end -- 807
			sanitized[#sanitized + 1] = next -- 811
			i = i + 1 -- 802
		end -- 802
	end -- 802
	clone.messages = sanitized -- 813
	if #ordered > shown then -- 813
		clone.truncatedMessages = #ordered - shown -- 815
	end -- 815
	return clone -- 817
end -- 817
function getDecisionToolDefinitions(shared) -- 835
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 836
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 837
	local base = shared.promptPack.toolDefinitionsDetailed -- 840
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 841
	local availableTools = __TS__ArrayFilter( -- 843
		AgentToolRegistry.getAllowedToolsForRole(shared.role), -- 843
		function(____, tool) return shared.decisionMode == "xml" or tool ~= "finish" end -- 844
	) -- 844
	local availability = (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat(availableTools, ", ") -- 845
	if usesDefaultToolPrompts then -- 845
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}}) -- 851
		return replacePromptVars(definitions .. availability, params) -- 856
	end -- 856
	local withRole = replacePromptVars((base .. mainAgentTools) .. availability, params) -- 858
	if (shared and shared.decisionMode) ~= "xml" then -- 858
		return withRole -- 863
	end -- 863
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 865
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 866
end -- 866
function getFinishMessage(params, fallback) -- 1198
	if fallback == nil then -- 1198
		fallback = "" -- 1198
	end -- 1198
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1198
		return __TS__StringTrim(params.message) -- 1200
	end -- 1200
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1200
		return __TS__StringTrim(params.response) -- 1203
	end -- 1203
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1203
		return __TS__StringTrim(params.summary) -- 1206
	end -- 1206
	return __TS__StringTrim(fallback) -- 1208
end -- 1208
function persistHistoryState(shared) -- 1211
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1212
end -- 1212
function getActiveConversationMessages(shared) -- 1219
	local activeMessages = {} -- 1220
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1220
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1227
	end -- 1227
	do -- 1227
		local i = shared.lastConsolidatedIndex -- 1231
		while i < #shared.messages do -- 1231
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1232
			i = i + 1 -- 1231
		end -- 1231
	end -- 1231
	return activeMessages -- 1234
end -- 1234
function getActiveRealMessageCount(shared) -- 1237
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1238
end -- 1238
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1241
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1246
	local previousActiveStart = shared.lastConsolidatedIndex -- 1247
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1248
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1249
	if type(carryMessageIndex) == "number" then -- 1249
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1249
		else -- 1249
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1257
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1260
		end -- 1260
	else -- 1260
		shared.carryMessageIndex = nil -- 1265
	end -- 1265
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1265
		shared.carryMessageIndex = nil -- 1275
	end -- 1275
end -- 1275
function ensureToolCallId(toolCallId) -- 1290
	if toolCallId and toolCallId ~= "" then -- 1290
		return toolCallId -- 1291
	end -- 1291
	return createLocalToolCallId() -- 1292
end -- 1292
function hasXMLParam(params, name) -- 1325
	return params[name] ~= nil -- 1326
end -- 1326
function inferToolNameFromXMLParams(params) -- 1329
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1329
		return "edit_file" -- 1331
	end -- 1331
	if hasXMLParam(params, "target_file") then -- 1331
		return "delete_file" -- 1334
	end -- 1334
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1334
		if hasXMLParam(params, "path") then -- 1334
			return "read_file" -- 1337
		end -- 1337
		return nil -- 1338
	end -- 1338
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1338
		if hasXMLParam(params, "pattern") then -- 1338
			return "search_dora_api" -- 1341
		end -- 1341
		return nil -- 1342
	end -- 1342
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1342
		if hasXMLParam(params, "pattern") then -- 1342
			return "grep_files" -- 1345
		end -- 1345
		return nil -- 1346
	end -- 1346
	if hasXMLParam(params, "globs") then -- 1346
		if hasXMLParam(params, "pattern") then -- 1346
			return "grep_files" -- 1349
		end -- 1349
		return "glob_files" -- 1350
	end -- 1350
	if hasXMLParam(params, "maxEntries") then -- 1350
		return "glob_files" -- 1353
	end -- 1353
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1353
		return "finish" -- 1356
	end -- 1356
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1356
		return "spawn_sub_agent" -- 1359
	end -- 1359
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1359
		return "list_sub_agents" -- 1362
	end -- 1362
	return nil -- 1364
end -- 1364
function parseDSMLAttribute(source, offset, name) -- 1367
	local attrOpen = name .. "=\"" -- 1368
	local attrStart = (string.find( -- 1369
		source, -- 1369
		attrOpen, -- 1369
		math.max(offset + 1, 1), -- 1369
		true -- 1369
	) or 0) - 1 -- 1369
	if attrStart < 0 then -- 1369
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1370
	end -- 1370
	local valueStart = attrStart + #attrOpen -- 1371
	local valueEnd = (string.find( -- 1372
		source, -- 1372
		"\"", -- 1372
		math.max(valueStart + 1, 1), -- 1372
		true -- 1372
	) or 0) - 1 -- 1372
	if valueEnd < 0 then -- 1372
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1373
	end -- 1373
	return { -- 1374
		success = true, -- 1375
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1376
		next = valueEnd + 1 -- 1377
	} -- 1377
end -- 1377
function extractDSMLReason(text, invokeStart, tool) -- 1381
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1382
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1383
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1383
		return before -- 1386
	end -- 1386
	if tool == "finish" then -- 1386
		return "" -- 1387
	end -- 1387
	return "Converted provider-native tool call syntax to XML." -- 1388
end -- 1388
function parseDSMLToolCallObjectFromText(text) -- 1391
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1392
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1393
	if invokeStart < 0 then -- 1393
		return {success = false, message = "missing DSML invoke"} -- 1394
	end -- 1394
	local nameStart = invokeStart + #invokeOpen -- 1395
	local nameEnd = (string.find( -- 1396
		text, -- 1396
		"\"", -- 1396
		math.max(nameStart + 1, 1), -- 1396
		true -- 1396
	) or 0) - 1 -- 1396
	if nameEnd < 0 then -- 1396
		return {success = false, message = "unterminated DSML invoke name"} -- 1397
	end -- 1397
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1398
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1398
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1400
	end -- 1400
	local invokeOpenEnd = (string.find( -- 1402
		text, -- 1402
		">", -- 1402
		math.max(nameEnd + 1, 1), -- 1402
		true -- 1402
	) or 0) - 1 -- 1402
	if invokeOpenEnd < 0 then -- 1402
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1403
	end -- 1403
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1404
	local invokeEnd = (string.find( -- 1405
		text, -- 1405
		invokeClose, -- 1405
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1405
		true -- 1405
	) or 0) - 1 -- 1405
	if invokeEnd < 0 then -- 1405
		return {success = false, message = "missing DSML invoke close tag"} -- 1406
	end -- 1406
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1408
	local params = {} -- 1409
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1410
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1411
	local pos = 0 -- 1412
	while pos < #body do -- 1412
		local start = (string.find( -- 1414
			body, -- 1414
			paramOpen, -- 1414
			math.max(pos + 1, 1), -- 1414
			true -- 1414
		) or 0) - 1 -- 1414
		if start < 0 then -- 1414
			break -- 1415
		end -- 1415
		local openEnd = (string.find( -- 1416
			body, -- 1416
			">", -- 1416
			math.max(start + #paramOpen + 1, 1), -- 1416
			true -- 1416
		) or 0) - 1 -- 1416
		if openEnd < 0 then -- 1416
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1417
		end -- 1417
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1418
		if not name.success then -- 1418
			return name -- 1419
		end -- 1419
		local close = (string.find( -- 1420
			body, -- 1420
			paramClose, -- 1420
			math.max(openEnd + 1 + 1, 1), -- 1420
			true -- 1420
		) or 0) - 1 -- 1420
		if close < 0 then -- 1420
			return {success = false, message = "missing DSML parameter close tag"} -- 1421
		end -- 1421
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1422
		pos = close + #paramClose -- 1423
	end -- 1423
	return { -- 1425
		success = true, -- 1426
		obj = { -- 1427
			tool = toolName, -- 1428
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1429
			params = params -- 1430
		} -- 1430
	} -- 1430
end -- 1430
function parseXMLToolCallObjectFromText(text) -- 1435
	local children = parseXMLObjectFromText(text, "tool_call") -- 1436
	local rawObj -- 1437
	if children.success then -- 1437
		rawObj = children.obj -- 1439
	else -- 1439
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1441
		if dsml.success then -- 1441
			return dsml -- 1442
		end -- 1442
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1443
		local paramsCloseToken = "</params>" -- 1444
		if toolStart >= 0 then -- 1444
			local paramsClose = (string.find( -- 1446
				text, -- 1446
				paramsCloseToken, -- 1446
				math.max(toolStart + 1, 1), -- 1446
				true -- 1446
			) or 0) - 1 -- 1446
			if paramsClose >= toolStart then -- 1446
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1448
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1449
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1449
					rawObj = bare.obj -- 1451
				end -- 1451
			end -- 1451
		end -- 1451
		if rawObj == nil then -- 1451
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1456
			if paramsOpen < 0 then -- 1456
				return children -- 1457
			end -- 1457
			local paramsCloseOnly = (string.find( -- 1458
				text, -- 1458
				paramsCloseToken, -- 1458
				math.max(paramsOpen + 1, 1), -- 1458
				true -- 1458
			) or 0) - 1 -- 1458
			if paramsCloseOnly < paramsOpen then -- 1458
				return children -- 1459
			end -- 1459
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1460
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1461
			if not paramsOnly.success then -- 1461
				return children -- 1462
			end -- 1462
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1463
			if inferredTool == nil then -- 1463
				return children -- 1464
			end -- 1464
			local ____temp_24 -- 1469
			if inferredTool == "finish" then -- 1469
				____temp_24 = nil -- 1469
			else -- 1469
				____temp_24 = "Inferred tool from XML params." -- 1469
			end -- 1469
			return {success = true, obj = {tool = inferredTool, reason = ____temp_24, params = paramsOnly.obj}} -- 1465
		end -- 1465
	end -- 1465
	if rawObj == nil then -- 1465
		return children -- 1475
	end -- 1475
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1476
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1477
	if not params.success then -- 1477
		return {success = false, message = params.message} -- 1481
	end -- 1481
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1483
end -- 1483
function parseDecisionObject(rawObj) -- 1575
	if type(rawObj.tool) ~= "string" then -- 1575
		return {success = false, message = "missing tool"} -- 1576
	end -- 1576
	local tool = rawObj.tool -- 1577
	if not AgentToolRegistry.isKnownToolName(tool) then -- 1577
		return {success = false, message = "unknown tool: " .. tool} -- 1579
	end -- 1579
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1581
	if tool ~= "finish" and (not reason or reason == "") then -- 1581
		return {success = false, message = tool .. " requires top-level reason"} -- 1585
	end -- 1585
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1587
	return {success = true, tool = tool, params = params, reason = reason} -- 1588
end -- 1588
function getDecisionPath(params) -- 1701
	if type(params.path) == "string" then -- 1701
		return __TS__StringTrim(params.path) -- 1702
	end -- 1702
	if type(params.target_file) == "string" then -- 1702
		return __TS__StringTrim(params.target_file) -- 1703
	end -- 1703
	return "" -- 1704
end -- 1704
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1707
	local num = __TS__Number(value) -- 1708
	if not __TS__NumberIsFinite(num) then -- 1708
		num = fallback -- 1709
	end -- 1709
	num = math.floor(num) -- 1710
	if num < minValue then -- 1710
		num = minValue -- 1711
	end -- 1711
	if maxValue ~= nil and num > maxValue then -- 1711
		num = maxValue -- 1712
	end -- 1712
	return num -- 1713
end -- 1713
function parseReadLineParam(value, fallback, paramName) -- 1716
	local num = __TS__Number(value) -- 1721
	if not __TS__NumberIsFinite(num) then -- 1721
		num = fallback -- 1722
	end -- 1722
	num = math.floor(num) -- 1723
	if num == 0 then -- 1723
		return {success = false, message = paramName .. " cannot be 0"} -- 1725
	end -- 1725
	return {success = true, value = num} -- 1727
end -- 1727
function validateDecision(tool, params) -- 1730
	if tool == "finish" then -- 1730
		local message = getFinishMessage(params) -- 1735
		if message == "" then -- 1735
			return {success = false, message = "finish requires params.message"} -- 1736
		end -- 1736
		params.message = message -- 1737
		return {success = true, params = params} -- 1738
	end -- 1738
	if tool == "read_file" then -- 1738
		local path = getDecisionPath(params) -- 1742
		if path == "" then -- 1742
			return {success = false, message = "read_file requires path"} -- 1743
		end -- 1743
		params.path = path -- 1744
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1745
		if not startLineRes.success then -- 1745
			return startLineRes -- 1746
		end -- 1746
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1747
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1748
		if not endLineRes.success then -- 1748
			return endLineRes -- 1749
		end -- 1749
		params.startLine = startLineRes.value -- 1750
		params.endLine = endLineRes.value -- 1751
		return {success = true, params = params} -- 1752
	end -- 1752
	if tool == "edit_file" then -- 1752
		local path = getDecisionPath(params) -- 1756
		if path == "" then -- 1756
			return {success = false, message = "edit_file requires path"} -- 1757
		end -- 1757
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1758
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1759
		params.path = path -- 1760
		params.old_str = oldStr -- 1761
		params.new_str = newStr -- 1762
		return {success = true, params = params} -- 1763
	end -- 1763
	if tool == "delete_file" then -- 1763
		local targetFile = getDecisionPath(params) -- 1767
		if targetFile == "" then -- 1767
			return {success = false, message = "delete_file requires target_file"} -- 1768
		end -- 1768
		params.target_file = targetFile -- 1769
		return {success = true, params = params} -- 1770
	end -- 1770
	if tool == "grep_files" then -- 1770
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1774
		if pattern == "" then -- 1774
			return {success = false, message = "grep_files requires pattern"} -- 1775
		end -- 1775
		params.pattern = pattern -- 1776
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1777
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1778
		return {success = true, params = params} -- 1779
	end -- 1779
	if tool == "search_dora_api" then -- 1779
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1783
		if pattern == "" then -- 1783
			return {success = false, message = "search_dora_api requires pattern"} -- 1784
		end -- 1784
		params.pattern = pattern -- 1785
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1786
		return {success = true, params = params} -- 1787
	end -- 1787
	if tool == "glob_files" then -- 1787
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1791
		return {success = true, params = params} -- 1792
	end -- 1792
	if tool == "build" then -- 1792
		local path = getDecisionPath(params) -- 1796
		if path ~= "" then -- 1796
			params.path = path -- 1798
		end -- 1798
		return {success = true, params = params} -- 1800
	end -- 1800
	if tool == "list_sub_agents" then -- 1800
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1804
		if status ~= "" then -- 1804
			params.status = status -- 1806
		end -- 1806
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1808
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1809
		if type(params.query) == "string" then -- 1809
			params.query = __TS__StringTrim(params.query) -- 1811
		end -- 1811
		return {success = true, params = params} -- 1813
	end -- 1813
	if tool == "spawn_sub_agent" then -- 1813
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1817
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1818
		if prompt == "" then -- 1818
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1819
		end -- 1819
		if title == "" then -- 1819
			return {success = false, message = "spawn_sub_agent requires title"} -- 1820
		end -- 1820
		params.prompt = prompt -- 1821
		params.title = title -- 1822
		if type(params.expectedOutput) == "string" then -- 1822
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1824
		end -- 1824
		if isArray(params.filesHint) then -- 1824
			params.filesHint = __TS__ArrayMap( -- 1827
				__TS__ArrayFilter( -- 1827
					params.filesHint, -- 1827
					function(____, item) return type(item) == "string" end -- 1828
				), -- 1828
				function(____, item) return sanitizeUTF8(item) end -- 1829
			) -- 1829
		end -- 1829
		return {success = true, params = params} -- 1831
	end -- 1831
	return {success = true, params = params} -- 1834
end -- 1834
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1837
	if includeToolDefinitions == nil then -- 1837
		includeToolDefinitions = false -- 1837
	end -- 1837
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 1838
	local sections = { -- 1841
		shared.promptPack.agentIdentityPrompt, -- 1842
		rolePrompt, -- 1843
		getReplyLanguageDirective(shared) -- 1844
	} -- 1844
	if shared.decisionMode == "tool_calling" then -- 1844
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 1847
	end -- 1847
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 1849
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 1850
	if memoryContext ~= "" then -- 1850
		sections[#sections + 1] = memoryContext -- 1852
	end -- 1852
	local skillsSection = buildSkillsSection(shared) -- 1854
	if skillsSection ~= "" then -- 1854
		sections[#sections + 1] = skillsSection -- 1856
	end -- 1856
	if includeToolDefinitions then -- 1856
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 1859
		if shared.decisionMode == "xml" then -- 1859
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 1861
		end -- 1861
	end -- 1861
	return table.concat(sections, "\n\n") -- 1864
end -- 1864
function buildSkillsSection(shared) -- 1867
	local ____opt_43 = shared.skills -- 1867
	if not (____opt_43 and ____opt_43.loader) then -- 1867
		return "" -- 1869
	end -- 1869
	return shared.skills.loader:buildSkillsPromptSection() -- 1871
end -- 1871
function buildXmlDecisionInstruction(shared, feedback) -- 1998
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 1999
end -- 1999
function tryParseAndValidateDecision(rawText) -- 2065
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2066
	if not parsed.success then -- 2066
		return {success = false, message = parsed.message, raw = rawText} -- 2068
	end -- 2068
	local decision = parseDecisionObject(parsed.obj) -- 2070
	if not decision.success then -- 2070
		return {success = false, message = decision.message, raw = rawText} -- 2072
	end -- 2072
	local validation = validateDecision(decision.tool, decision.params) -- 2074
	if not validation.success then -- 2074
		return {success = false, message = validation.message, raw = rawText} -- 2076
	end -- 2076
	decision.params = validation.params -- 2078
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2079
	return decision -- 2080
end -- 2080
function executeToolAction(shared, action) -- 3380
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3380
		if shared.stopToken.stopped then -- 3380
			return ____awaiter_resolve( -- 3380
				nil, -- 3380
				{ -- 3382
					success = false, -- 3382
					message = getCancelledReason(shared) -- 3382
				} -- 3382
			) -- 3382
		end -- 3382
		local params = action.params -- 3384
		if action.tool == "read_file" then -- 3384
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3386
			if __TS__StringTrim(path) == "" then -- 3386
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3386
			end -- 3386
			local ____Tools_readFile_107 = Tools.readFile -- 3390
			local ____shared_workingDir_105 = shared.workingDir -- 3391
			local ____params_startLine_103 = params.startLine -- 3393
			if ____params_startLine_103 == nil then -- 3393
				____params_startLine_103 = 1 -- 3393
			end -- 3393
			local ____TS__Number_result_106 = __TS__Number(____params_startLine_103) -- 3393
			local ____params_endLine_104 = params.endLine -- 3394
			if ____params_endLine_104 == nil then -- 3394
				____params_endLine_104 = READ_FILE_DEFAULT_LIMIT -- 3394
			end -- 3394
			return ____awaiter_resolve( -- 3394
				nil, -- 3394
				____Tools_readFile_107( -- 3390
					____shared_workingDir_105, -- 3391
					path, -- 3392
					____TS__Number_result_106, -- 3393
					__TS__Number(____params_endLine_104), -- 3394
					shared.useChineseResponse and "zh" or "en" -- 3395
				) -- 3395
			) -- 3395
		end -- 3395
		if action.tool == "grep_files" then -- 3395
			local ____Tools_searchFiles_121 = Tools.searchFiles -- 3399
			local ____shared_workingDir_114 = shared.workingDir -- 3400
			local ____temp_115 = params.path or "" -- 3401
			local ____temp_116 = params.pattern or "" -- 3402
			local ____params_globs_117 = params.globs -- 3403
			local ____params_useRegex_118 = params.useRegex -- 3404
			local ____params_caseSensitive_119 = params.caseSensitive -- 3405
			local ____math_max_110 = math.max -- 3408
			local ____math_floor_109 = math.floor -- 3408
			local ____params_limit_108 = params.limit -- 3408
			if ____params_limit_108 == nil then -- 3408
				____params_limit_108 = SEARCH_FILES_LIMIT_DEFAULT -- 3408
			end -- 3408
			local ____math_max_110_result_120 = ____math_max_110( -- 3408
				1, -- 3408
				____math_floor_109(__TS__Number(____params_limit_108)) -- 3408
			) -- 3408
			local ____math_max_113 = math.max -- 3409
			local ____math_floor_112 = math.floor -- 3409
			local ____params_offset_111 = params.offset -- 3409
			if ____params_offset_111 == nil then -- 3409
				____params_offset_111 = 0 -- 3409
			end -- 3409
			local result = __TS__Await(____Tools_searchFiles_121({ -- 3399
				workDir = ____shared_workingDir_114, -- 3400
				path = ____temp_115, -- 3401
				pattern = ____temp_116, -- 3402
				globs = ____params_globs_117, -- 3403
				useRegex = ____params_useRegex_118, -- 3404
				caseSensitive = ____params_caseSensitive_119, -- 3405
				includeContent = true, -- 3406
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3407
				limit = ____math_max_110_result_120, -- 3408
				offset = ____math_max_113( -- 3409
					0, -- 3409
					____math_floor_112(__TS__Number(____params_offset_111)) -- 3409
				), -- 3409
				groupByFile = params.groupByFile == true -- 3410
			})) -- 3410
			return ____awaiter_resolve(nil, result) -- 3410
		end -- 3410
		if action.tool == "search_dora_api" then -- 3410
			local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3415
			local ____temp_125 = params.pattern or "" -- 3416
			local ____temp_126 = params.docSource or "api" -- 3417
			local ____temp_127 = shared.useChineseResponse and "zh" or "en" -- 3418
			local ____temp_128 = params.programmingLanguage or "ts" -- 3419
			local ____math_min_124 = math.min -- 3420
			local ____math_max_123 = math.max -- 3420
			local ____params_limit_122 = params.limit -- 3420
			if ____params_limit_122 == nil then -- 3420
				____params_limit_122 = 8 -- 3420
			end -- 3420
			local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3415
				pattern = ____temp_125, -- 3416
				docSource = ____temp_126, -- 3417
				docLanguage = ____temp_127, -- 3418
				programmingLanguage = ____temp_128, -- 3419
				limit = ____math_min_124( -- 3420
					SEARCH_DORA_API_LIMIT_MAX, -- 3420
					____math_max_123( -- 3420
						1, -- 3420
						__TS__Number(____params_limit_122) -- 3420
					) -- 3420
				), -- 3420
				useRegex = params.useRegex, -- 3421
				caseSensitive = false, -- 3422
				includeContent = true, -- 3423
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3424
			})) -- 3424
			return ____awaiter_resolve(nil, result) -- 3424
		end -- 3424
		if action.tool == "glob_files" then -- 3424
			local ____Tools_listFiles_136 = Tools.listFiles -- 3429
			local ____shared_workingDir_133 = shared.workingDir -- 3430
			local ____temp_134 = params.path or "" -- 3431
			local ____params_globs_135 = params.globs -- 3432
			local ____math_max_132 = math.max -- 3433
			local ____math_floor_131 = math.floor -- 3433
			local ____params_maxEntries_130 = params.maxEntries -- 3433
			if ____params_maxEntries_130 == nil then -- 3433
				____params_maxEntries_130 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3433
			end -- 3433
			local result = ____Tools_listFiles_136({ -- 3429
				workDir = ____shared_workingDir_133, -- 3430
				path = ____temp_134, -- 3431
				globs = ____params_globs_135, -- 3432
				maxEntries = ____math_max_132( -- 3433
					1, -- 3433
					____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3433
				) -- 3433
			}) -- 3433
			return ____awaiter_resolve(nil, result) -- 3433
		end -- 3433
		if action.tool == "delete_file" then -- 3433
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3438
			if __TS__StringTrim(targetFile) == "" then -- 3438
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3438
			end -- 3438
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3442
			if not result.success then -- 3442
				return ____awaiter_resolve(nil, result) -- 3442
			end -- 3442
			return ____awaiter_resolve(nil, { -- 3442
				success = true, -- 3450
				changed = true, -- 3451
				mode = "delete", -- 3452
				checkpointId = result.checkpointId, -- 3453
				checkpointSeq = result.checkpointSeq, -- 3454
				files = {{path = targetFile, op = "delete"}} -- 3455
			}) -- 3455
		end -- 3455
		if action.tool == "build" then -- 3455
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3459
			return ____awaiter_resolve(nil, result) -- 3459
		end -- 3459
		if action.tool == "spawn_sub_agent" then -- 3459
			if not shared.spawnSubAgent then -- 3459
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3459
			end -- 3459
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3459
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3459
			end -- 3459
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3472
				params.filesHint, -- 3473
				function(____, item) return type(item) == "string" end -- 3473
			) or nil -- 3473
			local result = __TS__Await(shared.spawnSubAgent({ -- 3475
				parentSessionId = shared.sessionId, -- 3476
				projectRoot = shared.workingDir, -- 3477
				title = type(params.title) == "string" and params.title or "Sub", -- 3478
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3479
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3480
				filesHint = filesHint -- 3481
			})) -- 3481
			if not result.success then -- 3481
				return ____awaiter_resolve(nil, result) -- 3481
			end -- 3481
			return ____awaiter_resolve(nil, { -- 3481
				success = true, -- 3487
				sessionId = result.sessionId, -- 3488
				taskId = result.taskId, -- 3489
				title = result.title, -- 3490
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3491
			}) -- 3491
		end -- 3491
		if action.tool == "list_sub_agents" then -- 3491
			if not shared.listSubAgents then -- 3491
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3491
			end -- 3491
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3491
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3491
			end -- 3491
			local result = __TS__Await(shared.listSubAgents({ -- 3501
				sessionId = shared.sessionId, -- 3502
				projectRoot = shared.workingDir, -- 3503
				status = type(params.status) == "string" and params.status or nil, -- 3504
				limit = type(params.limit) == "number" and params.limit or nil, -- 3505
				offset = type(params.offset) == "number" and params.offset or nil, -- 3506
				query = type(params.query) == "string" and params.query or nil -- 3507
			})) -- 3507
			return ____awaiter_resolve(nil, result) -- 3507
		end -- 3507
		if action.tool == "edit_file" then -- 3507
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3512
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3515
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3516
			if __TS__StringTrim(path) == "" then -- 3516
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3516
			end -- 3516
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3518
			return ____awaiter_resolve( -- 3518
				nil, -- 3518
				actionNode:exec({ -- 3519
					path = path, -- 3520
					oldStr = oldStr, -- 3521
					newStr = newStr, -- 3522
					taskId = shared.taskId, -- 3523
					workDir = shared.workingDir -- 3524
				}) -- 3524
			) -- 3524
		end -- 3524
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3524
	end) -- 3524
end -- 3524
function sanitizeToolActionResultForHistory(action, result) -- 3530
	if action.tool == "read_file" then -- 3530
		return sanitizeReadResultForHistory(action.tool, result) -- 3532
	end -- 3532
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3532
		return sanitizeSearchResultForHistory(action.tool, result) -- 3535
	end -- 3535
	if action.tool == "glob_files" then -- 3535
		return sanitizeListFilesResultForHistory(result) -- 3538
	end -- 3538
	if action.tool == "build" then -- 3538
		return sanitizeBuildResultForHistory(result) -- 3541
	end -- 3541
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3541
		if result.success ~= true then -- 3541
			return result -- 3544
		end -- 3544
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3544
			return result -- 3545
		end -- 3545
		if isArray(result.fileContext) then -- 3545
			return result -- 3546
		end -- 3546
		local contextLimits = { -- 3548
			fullContentChars = 12000, -- 3549
			previewChars = 4000, -- 3550
			diffChars = 8000, -- 3551
			totalChars = 24000, -- 3552
			maxFiles = 8 -- 3553
		} -- 3553
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3555
			if maxChars <= 0 then -- 3555
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3556
			end -- 3556
			if #sourceText <= maxChars then -- 3556
				return sourceText -- 3557
			end -- 3557
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3558
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3559
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3560
		end -- 3555
		local function countLines(sourceText) -- 3562
			if sourceText == "" then -- 3562
				return 0 -- 3563
			end -- 3563
			return #__TS__StringSplit(sourceText, "\n") -- 3564
		end -- 3562
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3566
			if beforeContent == afterContent then -- 3566
				return "" -- 3567
			end -- 3567
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3568
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3569
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3571
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3571
				firstChangedLine = firstChangedLine + 1 -- 3577
			end -- 3577
			local lastChangedBeforeLine = #beforeLines - 1 -- 3579
			local lastChangedAfterLine = #afterLines - 1 -- 3580
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3580
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3586
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3587
			end -- 3587
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3589
			local previewEndLine = math.max( -- 3590
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3591
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3592
			) -- 3592
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3594
			do -- 3594
				local lineIndex = previewStartLine -- 3595
				while lineIndex <= previewEndLine do -- 3595
					do -- 3595
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3596
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3597
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3598
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3599
						if not beforeChanged and not afterChanged then -- 3599
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3601
							if contextLine ~= nil then -- 3601
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3602
							end -- 3602
							goto __continue601 -- 3603
						end -- 3603
						if beforeChanged and beforeLine ~= nil then -- 3603
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3605
						end -- 3605
						if afterChanged and afterLine ~= nil then -- 3605
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3606
						end -- 3606
					end -- 3606
					::__continue601:: -- 3606
					lineIndex = lineIndex + 1 -- 3595
				end -- 3595
			end -- 3595
			return truncateContextSnippet( -- 3608
				table.concat(unifiedDiffLines, "\n"), -- 3608
				maxChars, -- 3608
				"diff" -- 3608
			) -- 3608
		end -- 3566
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3611
		if not checkpointDiff.success then -- 3611
			return result -- 3612
		end -- 3612
		local remainingContextBudget = contextLimits.totalChars -- 3613
		local fileContextItems = {} -- 3614
		local changedFiles = checkpointDiff.files -- 3615
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3616
		do -- 3616
			local fileIndex = 0 -- 3617
			while fileIndex < maxContextFiles do -- 3617
				if remainingContextBudget <= 0 then -- 3617
					break -- 3618
				end -- 3618
				local changedFile = changedFiles[fileIndex + 1] -- 3619
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3620
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3621
				local contextItem = { -- 3622
					path = changedFile.path, -- 3623
					op = changedFile.op, -- 3624
					checkpointId = result.checkpointId, -- 3625
					checkpointSeq = result.checkpointSeq, -- 3626
					beforeExists = changedFile.beforeExists, -- 3627
					afterExists = changedFile.afterExists, -- 3628
					beforeBytes = #beforeContent, -- 3629
					afterBytes = #afterContent, -- 3630
					diffPreview = "", -- 3631
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3632
					contentTruncated = false, -- 3633
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3634
				} -- 3634
				if changedFile.afterExists then -- 3634
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3634
						contextItem.afterContent = afterContent -- 3638
						remainingContextBudget = remainingContextBudget - #afterContent -- 3639
					else -- 3639
						contextItem.afterContentPreview = truncateContextSnippet( -- 3641
							afterContent, -- 3642
							math.min( -- 3643
								contextLimits.previewChars, -- 3643
								math.max(400, remainingContextBudget) -- 3643
							), -- 3643
							"afterContent" -- 3644
						) -- 3644
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3646
						contextItem.contentTruncated = true -- 3647
					end -- 3647
				end -- 3647
				local diffPreview = buildUnifiedDiffPreview( -- 3650
					changedFile.path, -- 3651
					beforeContent, -- 3652
					afterContent, -- 3653
					math.min( -- 3654
						contextLimits.diffChars, -- 3654
						math.max(400, remainingContextBudget) -- 3654
					) -- 3654
				) -- 3654
				contextItem.diffPreview = diffPreview -- 3656
				remainingContextBudget = remainingContextBudget - #diffPreview -- 3657
				if not changedFile.afterExists and beforeContent ~= "" then -- 3657
					contextItem.beforeContentPreview = truncateContextSnippet( -- 3659
						beforeContent, -- 3660
						math.min( -- 3661
							contextLimits.previewChars, -- 3661
							math.max(400, remainingContextBudget) -- 3661
						), -- 3661
						"beforeContent" -- 3662
					) -- 3662
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 3664
					if #beforeContent > contextLimits.previewChars then -- 3664
						contextItem.contentTruncated = true -- 3665
					end -- 3665
				end -- 3665
				fileContextItems[#fileContextItems + 1] = contextItem -- 3667
				fileIndex = fileIndex + 1 -- 3617
			end -- 3617
		end -- 3617
		if #fileContextItems == 0 then -- 3617
			return result -- 3669
		end -- 3669
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 3670
	end -- 3670
	return result -- 3677
end -- 3677
function emitAgentTaskFinishEvent(shared, success, message) -- 3840
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3841
	emitAgentEvent(shared, { -- 3847
		type = "task_finished", -- 3848
		sessionId = shared.sessionId, -- 3849
		taskId = shared.taskId, -- 3850
		success = result.success, -- 3851
		message = result.message, -- 3852
		steps = result.steps -- 3853
	}) -- 3853
	return result -- 3855
end -- 3855
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
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 517
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
local function sanitizeActionParamsForHistory(tool, params) -- 820
	if tool ~= "edit_file" then -- 820
		return params -- 821
	end -- 821
	local clone = {} -- 822
	for key in pairs(params) do -- 823
		if key == "old_str" then -- 823
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 825
		elseif key == "new_str" then -- 825
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 827
		else -- 827
			clone[key] = params[key] -- 829
		end -- 829
	end -- 829
	return clone -- 832
end -- 820
local function getDecisionToolSchemaText(shared) -- 872
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX)) -- 873
	return toolsText or "" -- 874
end -- 872
local function isToolAllowedForRole(role, tool) -- 877
	return __TS__ArrayIndexOf( -- 878
		AgentToolRegistry.getAllowedToolsForRole(role), -- 878
		tool -- 878
	) >= 0 -- 878
end -- 877
local function clearPreExecutedResults(shared) -- 881
	shared.preExecutedResults = nil -- 882
end -- 881
local function startPreExecutedToolAction(shared, action) -- 885
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 885
		local ____hasReturned, ____returnValue -- 885
		local ____try = __TS__AsyncAwaiter(function() -- 885
			____hasReturned = true -- 887
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 887
			return -- 887
		end) -- 887
		____try = ____try.catch( -- 887
			____try, -- 887
			function(____, err) -- 887
				return __TS__AsyncAwaiter(function() -- 887
					local message = tostring(err) -- 889
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 890
					____hasReturned = true -- 891
					____returnValue = {success = false, message = message} -- 891
					return -- 891
				end) -- 891
			end -- 891
		) -- 891
		__TS__Await(____try) -- 886
		if ____hasReturned then -- 886
			return ____awaiter_resolve(nil, ____returnValue) -- 886
		end -- 886
	end) -- 886
end -- 885
local function createPreExecutedToolResult(shared, action) -- 895
	local cloneParamValue -- 896
	cloneParamValue = function(value) -- 896
		if value == nil then -- 896
			return value -- 897
		end -- 897
		if isArray(value) then -- 897
			return __TS__ArrayMap( -- 899
				value, -- 899
				function(____, item) return cloneParamValue(item) end -- 899
			) -- 899
		end -- 899
		if type(value) == "table" then -- 899
			local clone = {} -- 902
			for key in pairs(value) do -- 903
				clone[key] = cloneParamValue(value[key]) -- 904
			end -- 904
			return clone -- 906
		end -- 906
		return value -- 908
	end -- 896
	local params = cloneParamValue(action.params) -- 910
	local areParamValuesEqual -- 911
	areParamValuesEqual = function(left, right) -- 911
		if left == right then -- 911
			return true -- 912
		end -- 912
		if left == nil or right == nil then -- 912
			return false -- 913
		end -- 913
		if isArray(left) or isArray(right) then -- 913
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 913
				return false -- 915
			end -- 915
			do -- 915
				local i = 0 -- 916
				while i < #left do -- 916
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 916
						return false -- 917
					end -- 917
					i = i + 1 -- 916
				end -- 916
			end -- 916
			return true -- 919
		end -- 919
		if type(left) == "table" and type(right) == "table" then -- 919
			local leftCount = 0 -- 922
			for key in pairs(left) do -- 923
				leftCount = leftCount + 1 -- 924
				if not areParamValuesEqual(left[key], right[key]) then -- 924
					return false -- 929
				end -- 929
			end -- 929
			local rightCount = 0 -- 932
			for key in pairs(right) do -- 933
				rightCount = rightCount + 1 -- 934
			end -- 934
			return leftCount == rightCount -- 936
		end -- 936
		return false -- 938
	end -- 911
	return { -- 940
		action = action, -- 941
		matches = function(self, nextAction) -- 942
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 943
		end, -- 942
		promise = startPreExecutedToolAction(shared, action) -- 945
	} -- 945
end -- 895
local function executeToolActionWithPreExecution(shared, action) -- 949
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 949
		local ____opt_3 = shared.preExecutedResults -- 949
		local preResult = ____opt_3 and ____opt_3:get(action.toolCallId) -- 950
		if preResult then -- 950
			local ____opt_5 = shared.preExecutedResults -- 950
			if ____opt_5 ~= nil then -- 950
				____opt_5:delete(action.toolCallId) -- 952
			end -- 952
			if preResult:matches(action) then -- 952
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 954
				return ____awaiter_resolve( -- 954
					nil, -- 954
					__TS__Await(preResult.promise) -- 955
				) -- 955
			end -- 955
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 957
		end -- 957
		return ____awaiter_resolve( -- 957
			nil, -- 957
			executeToolAction(shared, action) -- 959
		) -- 959
	end) -- 959
end -- 949
local function maybeCompressHistory(shared) -- 962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 962
		local ____shared_7 = shared -- 963
		local memory = ____shared_7.memory -- 963
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 964
		local changed = false -- 965
		do -- 965
			local round = 0 -- 966
			while round < maxRounds do -- 966
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 967
				local activeMessages = getActiveConversationMessages(shared) -- 968
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 971
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 971
					if changed then -- 971
						persistHistoryState(shared) -- 980
					end -- 980
					return ____awaiter_resolve(nil) -- 980
				end -- 980
				local compressionRound = round + 1 -- 984
				shared.step = shared.step + 1 -- 985
				local stepId = shared.step -- 986
				local pendingMessages = #activeMessages -- 987
				emitAgentEvent( -- 988
					shared, -- 988
					{ -- 988
						type = "memory_compression_started", -- 989
						sessionId = shared.sessionId, -- 990
						taskId = shared.taskId, -- 991
						step = stepId, -- 992
						tool = "compress_memory", -- 993
						reason = getMemoryCompressionStartReason(shared), -- 994
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 995
					} -- 995
				) -- 995
				local result = __TS__Await(memory.compressor:compress( -- 1001
					activeMessages, -- 1002
					shared.llmOptions, -- 1003
					shared.llmMaxTry, -- 1004
					shared.decisionMode, -- 1005
					{ -- 1006
						onInput = function(____, phase, messages, options) -- 1007
							saveStepLLMDebugInput( -- 1008
								shared, -- 1008
								stepId, -- 1008
								phase, -- 1008
								messages, -- 1008
								options -- 1008
							) -- 1008
						end, -- 1007
						onOutput = function(____, phase, text, meta) -- 1010
							saveStepLLMDebugOutput( -- 1011
								shared, -- 1011
								stepId, -- 1011
								phase, -- 1011
								text, -- 1011
								meta -- 1011
							) -- 1011
						end -- 1010
					}, -- 1010
					"default", -- 1014
					systemPrompt, -- 1015
					toolDefinitions -- 1016
				)) -- 1016
				if not (result and result.success and result.compressedCount > 0) then -- 1016
					emitAgentEvent( -- 1019
						shared, -- 1019
						{ -- 1019
							type = "memory_compression_finished", -- 1020
							sessionId = shared.sessionId, -- 1021
							taskId = shared.taskId, -- 1022
							step = stepId, -- 1023
							tool = "compress_memory", -- 1024
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1025
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1029
						} -- 1029
					) -- 1029
					if changed then -- 1029
						persistHistoryState(shared) -- 1037
					end -- 1037
					return ____awaiter_resolve(nil) -- 1037
				end -- 1037
				local effectiveCompressedCount = math.max( -- 1041
					0, -- 1042
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1043
				) -- 1043
				if effectiveCompressedCount <= 0 then -- 1043
					if changed then -- 1043
						persistHistoryState(shared) -- 1047
					end -- 1047
					return ____awaiter_resolve(nil) -- 1047
				end -- 1047
				emitAgentEvent( -- 1051
					shared, -- 1051
					{ -- 1051
						type = "memory_compression_finished", -- 1052
						sessionId = shared.sessionId, -- 1053
						taskId = shared.taskId, -- 1054
						step = stepId, -- 1055
						tool = "compress_memory", -- 1056
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1057
						result = { -- 1058
							success = true, -- 1059
							round = compressionRound, -- 1060
							compressedCount = effectiveCompressedCount, -- 1061
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1062
						} -- 1062
					} -- 1062
				) -- 1062
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1065
				changed = true -- 1066
				Log( -- 1067
					"Info", -- 1067
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1067
				) -- 1067
				round = round + 1 -- 966
			end -- 966
		end -- 966
		if changed then -- 966
			persistHistoryState(shared) -- 1070
		end -- 1070
	end) -- 1070
end -- 962
local function compactAllHistory(shared) -- 1074
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1074
		local ____shared_14 = shared -- 1075
		local memory = ____shared_14.memory -- 1075
		local rounds = 0 -- 1076
		local totalCompressed = 0 -- 1077
		while getActiveRealMessageCount(shared) > 0 do -- 1077
			if shared.stopToken.stopped then -- 1077
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1080
				return ____awaiter_resolve( -- 1080
					nil, -- 1080
					emitAgentTaskFinishEvent( -- 1081
						shared, -- 1081
						false, -- 1081
						getCancelledReason(shared) -- 1081
					) -- 1081
				) -- 1081
			end -- 1081
			rounds = rounds + 1 -- 1083
			shared.step = shared.step + 1 -- 1084
			local stepId = shared.step -- 1085
			local activeMessages = getActiveConversationMessages(shared) -- 1086
			local pendingMessages = #activeMessages -- 1087
			emitAgentEvent( -- 1088
				shared, -- 1088
				{ -- 1088
					type = "memory_compression_started", -- 1089
					sessionId = shared.sessionId, -- 1090
					taskId = shared.taskId, -- 1091
					step = stepId, -- 1092
					tool = "compress_memory", -- 1093
					reason = getMemoryCompressionStartReason(shared), -- 1094
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1095
				} -- 1095
			) -- 1095
			local result = __TS__Await(memory.compressor:compress( -- 1102
				activeMessages, -- 1103
				shared.llmOptions, -- 1104
				shared.llmMaxTry, -- 1105
				shared.decisionMode, -- 1106
				{ -- 1107
					onInput = function(____, phase, messages, options) -- 1108
						saveStepLLMDebugInput( -- 1109
							shared, -- 1109
							stepId, -- 1109
							phase, -- 1109
							messages, -- 1109
							options -- 1109
						) -- 1109
					end, -- 1108
					onOutput = function(____, phase, text, meta) -- 1111
						saveStepLLMDebugOutput( -- 1112
							shared, -- 1112
							stepId, -- 1112
							phase, -- 1112
							text, -- 1112
							meta -- 1112
						) -- 1112
					end -- 1111
				}, -- 1111
				"budget_max" -- 1115
			)) -- 1115
			if not (result and result.success and result.compressedCount > 0) then -- 1115
				emitAgentEvent( -- 1118
					shared, -- 1118
					{ -- 1118
						type = "memory_compression_finished", -- 1119
						sessionId = shared.sessionId, -- 1120
						taskId = shared.taskId, -- 1121
						step = stepId, -- 1122
						tool = "compress_memory", -- 1123
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1124
						result = { -- 1128
							success = false, -- 1129
							rounds = rounds, -- 1130
							error = result and result.error or "compression returned no changes", -- 1131
							compressedCount = result and result.compressedCount or 0, -- 1132
							fullCompaction = true -- 1133
						} -- 1133
					} -- 1133
				) -- 1133
				return ____awaiter_resolve( -- 1133
					nil, -- 1133
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1136
				) -- 1136
			end -- 1136
			local effectiveCompressedCount = math.max( -- 1141
				0, -- 1142
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1143
			) -- 1143
			if effectiveCompressedCount <= 0 then -- 1143
				return ____awaiter_resolve( -- 1143
					nil, -- 1143
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1146
				) -- 1146
			end -- 1146
			emitAgentEvent( -- 1153
				shared, -- 1153
				{ -- 1153
					type = "memory_compression_finished", -- 1154
					sessionId = shared.sessionId, -- 1155
					taskId = shared.taskId, -- 1156
					step = stepId, -- 1157
					tool = "compress_memory", -- 1158
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1159
					result = { -- 1160
						success = true, -- 1161
						round = rounds, -- 1162
						compressedCount = effectiveCompressedCount, -- 1163
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1164
						fullCompaction = true -- 1165
					} -- 1165
				} -- 1165
			) -- 1165
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1168
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1169
			persistHistoryState(shared) -- 1170
			Log( -- 1171
				"Info", -- 1171
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1171
			) -- 1171
		end -- 1171
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1173
		return ____awaiter_resolve( -- 1173
			nil, -- 1173
			emitAgentTaskFinishEvent( -- 1174
				shared, -- 1175
				true, -- 1176
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1177
			) -- 1177
		) -- 1177
	end) -- 1177
end -- 1074
local function clearSessionHistory(shared) -- 1183
	shared.messages = {} -- 1184
	shared.lastConsolidatedIndex = 0 -- 1185
	shared.carryMessageIndex = nil -- 1186
	persistHistoryState(shared) -- 1187
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1188
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1189
end -- 1183
local function appendConversationMessage(shared, message) -- 1279
	local ____shared_messages_23 = shared.messages -- 1279
	____shared_messages_23[#____shared_messages_23 + 1] = __TS__ObjectAssign( -- 1280
		{}, -- 1280
		message, -- 1281
		{ -- 1280
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1282
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1283
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1284
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1285
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1286
		} -- 1286
	) -- 1286
end -- 1279
local function appendToolResultMessage(shared, action) -- 1295
	appendConversationMessage( -- 1296
		shared, -- 1296
		{ -- 1296
			role = "tool", -- 1297
			tool_call_id = action.toolCallId, -- 1298
			name = action.tool, -- 1299
			content = action.result and toJson(action.result, false) or "" -- 1300
		} -- 1300
	) -- 1300
end -- 1295
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1304
	appendConversationMessage( -- 1310
		shared, -- 1310
		{ -- 1310
			role = "assistant", -- 1311
			content = content or "", -- 1312
			reasoning_content = reasoningContent, -- 1313
			tool_calls = __TS__ArrayMap( -- 1314
				actions, -- 1314
				function(____, action) return { -- 1314
					id = action.toolCallId, -- 1315
					type = "function", -- 1316
					["function"] = { -- 1317
						name = action.tool, -- 1318
						arguments = toJson(action.params, false) -- 1319
					} -- 1319
				} end -- 1319
			) -- 1319
		} -- 1319
	) -- 1319
end -- 1304
local function llm(shared, messages, phase) -- 1503
	if phase == nil then -- 1503
		phase = "decision_xml" -- 1506
	end -- 1506
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1506
		local stepId = shared.step + 1 -- 1508
		emitLLMContextMetrics( -- 1509
			shared, -- 1509
			stepId, -- 1509
			phase, -- 1509
			messages, -- 1509
			shared.llmOptions -- 1509
		) -- 1509
		saveStepLLMDebugInput( -- 1510
			shared, -- 1510
			stepId, -- 1510
			phase, -- 1510
			messages, -- 1510
			shared.llmOptions -- 1510
		) -- 1510
		local lastStreamReasoning = "" -- 1511
		local res = __TS__Await(callLLMStreamAggregated( -- 1512
			messages, -- 1513
			shared.llmOptions, -- 1514
			shared.stopToken, -- 1515
			shared.llmConfig, -- 1516
			function(response) -- 1517
				local ____opt_27 = response.choices -- 1517
				local ____opt_25 = ____opt_27 and ____opt_27[1] -- 1517
				local streamMessage = ____opt_25 and ____opt_25.message -- 1518
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1519
				if nextContent == "" then -- 1519
					return -- 1522
				end -- 1522
				if nextContent == lastStreamReasoning then -- 1522
					return -- 1523
				end -- 1523
				lastStreamReasoning = nextContent -- 1524
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1525
			end -- 1517
		)) -- 1517
		if res.success then -- 1517
			local ____opt_33 = res.response.choices -- 1517
			local ____opt_31 = ____opt_33 and ____opt_33[1] -- 1517
			local message = ____opt_31 and ____opt_31.message -- 1529
			local text = message and message.content -- 1530
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1531
			if text then -- 1531
				local parsed = tryParseAndValidateDecision(text) -- 1535
				if parsed.success then -- 1535
					local reason = parsed.reason or "" -- 1537
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1538
				end -- 1538
				saveStepLLMDebugOutput( -- 1540
					shared, -- 1540
					stepId, -- 1540
					phase, -- 1540
					text, -- 1540
					{success = true} -- 1540
				) -- 1540
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1540
			else -- 1540
				saveStepLLMDebugOutput( -- 1543
					shared, -- 1543
					stepId, -- 1543
					phase, -- 1543
					"empty LLM response", -- 1543
					{success = false} -- 1543
				) -- 1543
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1543
			end -- 1543
		else -- 1543
			saveStepLLMDebugOutput( -- 1547
				shared, -- 1547
				stepId, -- 1547
				phase, -- 1547
				res.raw or res.message, -- 1547
				{success = false} -- 1547
			) -- 1547
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1547
		end -- 1547
	end) -- 1547
end -- 1503
local function isDecisionBatchSuccess(result) -- 1571
	return result.kind == "batch" -- 1572
end -- 1571
local function parseDecisionToolCall(functionName, rawObj) -- 1596
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 1596
		return {success = false, message = "unknown tool: " .. functionName} -- 1598
	end -- 1598
	if rawObj == nil then -- 1598
		return {success = true, tool = functionName, params = {}} -- 1601
	end -- 1601
	if not isRecord(rawObj) then -- 1601
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1604
	end -- 1604
	return {success = true, tool = functionName, params = rawObj} -- 1606
end -- 1596
local function parseToolCallArguments(functionName, argsText) -- 1613
	local trimmedArgs = __TS__StringTrim(argsText) -- 1614
	if trimmedArgs == "" then -- 1614
		return {} -- 1616
	end -- 1616
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1618
	if err ~= nil or rawObj == nil then -- 1618
		return { -- 1620
			success = false, -- 1621
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1622
			raw = argsText -- 1623
		} -- 1623
	end -- 1623
	local encodedRaw = safeJsonEncode(rawObj) -- 1626
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1626
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1628
	end -- 1628
	return rawObj -- 1634
end -- 1613
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1637
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1645
	if isRecord(rawArgs) and rawArgs.success == false then -- 1645
		return rawArgs -- 1647
	end -- 1647
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1649
	if not decision.success then -- 1649
		return {success = false, message = decision.message, raw = argsText} -- 1651
	end -- 1651
	local validation = validateDecision(decision.tool, decision.params) -- 1657
	if not validation.success then -- 1657
		return {success = false, message = validation.message, raw = argsText} -- 1659
	end -- 1659
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1659
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1666
	end -- 1666
	decision.params = validation.params -- 1672
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1673
	decision.reason = reason -- 1674
	decision.reasoningContent = reasoningContent -- 1675
	return decision -- 1676
end -- 1637
local function createPreExecutableActionFromStream(shared, toolCall) -- 1679
	local ____opt_39 = toolCall["function"] -- 1679
	local functionName = ____opt_39 and ____opt_39.name -- 1680
	local ____opt_41 = toolCall["function"] -- 1680
	local argsText = ____opt_41 and ____opt_41.arguments or "" -- 1681
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1682
	if not functionName or not toolCallId then -- 1682
		return nil -- 1683
	end -- 1683
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1684
	if isRecord(rawArgs) and rawArgs.success == false then -- 1684
		return nil -- 1685
	end -- 1685
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1686
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 1686
		return nil -- 1687
	end -- 1687
	local validation = validateDecision(decision.tool, decision.params) -- 1688
	if not validation.success then -- 1688
		return nil -- 1689
	end -- 1689
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1689
		return nil -- 1690
	end -- 1690
	return { -- 1691
		step = shared.step + 1, -- 1692
		toolCallId = toolCallId, -- 1693
		tool = decision.tool, -- 1694
		reason = "", -- 1695
		params = validation.params, -- 1696
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1697
	} -- 1697
end -- 1679
local function sanitizeMessagesForLLMInput(messages) -- 1874
	local sanitized = {} -- 1875
	local droppedAssistantToolCalls = 0 -- 1876
	local droppedToolResults = 0 -- 1877
	do -- 1877
		local i = 0 -- 1878
		while i < #messages do -- 1878
			do -- 1878
				local message = messages[i + 1] -- 1879
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 1879
					local requiredIds = {} -- 1881
					do -- 1881
						local j = 0 -- 1882
						while j < #message.tool_calls do -- 1882
							local toolCall = message.tool_calls[j + 1] -- 1883
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 1884
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 1884
								requiredIds[#requiredIds + 1] = id -- 1886
							end -- 1886
							j = j + 1 -- 1882
						end -- 1882
					end -- 1882
					if #requiredIds == 0 then -- 1882
						sanitized[#sanitized + 1] = message -- 1890
						goto __continue330 -- 1891
					end -- 1891
					local matchedIds = {} -- 1893
					local matchedTools = {} -- 1894
					local j = i + 1 -- 1895
					while j < #messages do -- 1895
						local toolMessage = messages[j + 1] -- 1897
						if toolMessage.role ~= "tool" then -- 1897
							break -- 1898
						end -- 1898
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 1899
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 1899
							matchedIds[toolCallId] = true -- 1901
							matchedTools[#matchedTools + 1] = toolMessage -- 1902
						else -- 1902
							droppedToolResults = droppedToolResults + 1 -- 1904
						end -- 1904
						j = j + 1 -- 1906
					end -- 1906
					local complete = true -- 1908
					do -- 1908
						local j = 0 -- 1909
						while j < #requiredIds do -- 1909
							if matchedIds[requiredIds[j + 1]] ~= true then -- 1909
								complete = false -- 1911
								break -- 1912
							end -- 1912
							j = j + 1 -- 1909
						end -- 1909
					end -- 1909
					if complete then -- 1909
						__TS__ArrayPush( -- 1916
							sanitized, -- 1916
							message, -- 1916
							table.unpack(matchedTools) -- 1916
						) -- 1916
					else -- 1916
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 1918
						droppedToolResults = droppedToolResults + #matchedTools -- 1919
					end -- 1919
					i = j - 1 -- 1921
					goto __continue330 -- 1922
				end -- 1922
				if message.role == "tool" then -- 1922
					droppedToolResults = droppedToolResults + 1 -- 1925
					goto __continue330 -- 1926
				end -- 1926
				sanitized[#sanitized + 1] = message -- 1928
			end -- 1928
			::__continue330:: -- 1928
			i = i + 1 -- 1878
		end -- 1878
	end -- 1878
	return sanitized -- 1930
end -- 1874
local function getUnconsolidatedMessages(shared) -- 1933
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1934
end -- 1933
local function getFinalDecisionTurnPrompt(shared) -- 1937
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 1938
end -- 1937
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 1943
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 1943
		return messages -- 1944
	end -- 1944
	local next = __TS__ArrayMap( -- 1945
		messages, -- 1945
		function(____, message) return __TS__ObjectAssign({}, message) end -- 1945
	) -- 1945
	do -- 1945
		local i = #next - 1 -- 1946
		while i >= 0 do -- 1946
			do -- 1946
				local message = next[i + 1] -- 1947
				if message.role ~= "assistant" and message.role ~= "user" then -- 1947
					goto __continue352 -- 1948
				end -- 1948
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 1949
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 1950
				return next -- 1953
			end -- 1953
			::__continue352:: -- 1953
			i = i - 1 -- 1946
		end -- 1946
	end -- 1946
	next[#next + 1] = {role = "user", content = prompt} -- 1955
	return next -- 1956
end -- 1943
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 1959
	if attempt == nil then -- 1959
		attempt = 1 -- 1962
	end -- 1962
	if decisionMode == nil then -- 1962
		decisionMode = shared.decisionMode -- 1964
	end -- 1964
	local messages = { -- 1966
		{ -- 1967
			role = "system", -- 1967
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 1967
		}, -- 1967
		table.unpack(getUnconsolidatedMessages(shared)) -- 1968
	} -- 1968
	if shared.step + 1 >= shared.maxSteps then -- 1968
		messages = appendPromptToLatestDecisionMessage( -- 1971
			messages, -- 1971
			getFinalDecisionTurnPrompt(shared) -- 1971
		) -- 1971
	end -- 1971
	if lastError and lastError ~= "" then -- 1971
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 1974
		if decisionMode == "xml" then -- 1974
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 1978
		end -- 1978
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 1978
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 1981
		end -- 1981
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 1981
			retryHeader = retryHeader .. "\nYour previous response spent the token budget on reasoning and ended before any tool call. Do not continue that reasoning. Immediately emit one valid function tool call with compact arguments." -- 1984
		end -- 1984
		messages[#messages + 1] = { -- 1986
			role = "user", -- 1987
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 1988
		} -- 1988
	end -- 1988
	return messages -- 1995
end -- 1959
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2002
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2011
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2012
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2020
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2021
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2022
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2030
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}}) -- 2038
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2043
	local repairPrompt = replacePromptVars( -- 2046
		shared.promptPack.xmlDecisionRepairPrompt, -- 2046
		{ -- 2046
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2047
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2048
			CANDIDATE_SECTION = candidateSection, -- 2049
			LAST_ERROR = lastError, -- 2050
			ATTEMPT = tostring(attempt) -- 2051
		} -- 2051
	) -- 2051
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2053
end -- 2002
local function normalizeLineEndings(text) -- 2083
	local res = string.gsub(text, "\r\n", "\n") -- 2084
	res = string.gsub(res, "\r", "\n") -- 2085
	return res -- 2086
end -- 2083
local function countOccurrences(text, searchStr) -- 2089
	if searchStr == "" then -- 2089
		return 0 -- 2090
	end -- 2090
	local count = 0 -- 2091
	local pos = 0 -- 2092
	while true do -- 2092
		local idx = (string.find( -- 2094
			text, -- 2094
			searchStr, -- 2094
			math.max(pos + 1, 1), -- 2094
			true -- 2094
		) or 0) - 1 -- 2094
		if idx < 0 then -- 2094
			break -- 2095
		end -- 2095
		count = count + 1 -- 2096
		pos = idx + #searchStr -- 2097
	end -- 2097
	return count -- 2099
end -- 2089
local function replaceFirst(text, oldStr, newStr) -- 2102
	if oldStr == "" then -- 2102
		return text -- 2103
	end -- 2103
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2104
	if idx < 0 then -- 2104
		return text -- 2105
	end -- 2105
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2106
end -- 2102
local function splitLines(text) -- 2109
	return __TS__StringSplit(text, "\n") -- 2110
end -- 2109
local function getLeadingWhitespace(text) -- 2113
	local i = 0 -- 2114
	while i < #text do -- 2114
		local ch = __TS__StringAccess(text, i) -- 2116
		if ch ~= " " and ch ~= "\t" then -- 2116
			break -- 2117
		end -- 2117
		i = i + 1 -- 2118
	end -- 2118
	return __TS__StringSubstring(text, 0, i) -- 2120
end -- 2113
local function getCommonIndentPrefix(lines) -- 2123
	local common -- 2124
	do -- 2124
		local i = 0 -- 2125
		while i < #lines do -- 2125
			do -- 2125
				local line = lines[i + 1] -- 2126
				if __TS__StringTrim(line) == "" then -- 2126
					goto __continue380 -- 2127
				end -- 2127
				local indent = getLeadingWhitespace(line) -- 2128
				if common == nil then -- 2128
					common = indent -- 2130
					goto __continue380 -- 2131
				end -- 2131
				local j = 0 -- 2133
				local maxLen = math.min(#common, #indent) -- 2134
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2134
					j = j + 1 -- 2136
				end -- 2136
				common = __TS__StringSubstring(common, 0, j) -- 2138
				if common == "" then -- 2138
					break -- 2139
				end -- 2139
			end -- 2139
			::__continue380:: -- 2139
			i = i + 1 -- 2125
		end -- 2125
	end -- 2125
	return common or "" -- 2141
end -- 2123
local function removeIndentPrefix(line, indent) -- 2144
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2144
		return __TS__StringSubstring(line, #indent) -- 2146
	end -- 2146
	local lineIndent = getLeadingWhitespace(line) -- 2148
	local j = 0 -- 2149
	local maxLen = math.min(#lineIndent, #indent) -- 2150
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2150
		j = j + 1 -- 2152
	end -- 2152
	return __TS__StringSubstring(line, j) -- 2154
end -- 2144
local function dedentLines(lines) -- 2157
	local indent = getCommonIndentPrefix(lines) -- 2158
	return { -- 2159
		indent = indent, -- 2160
		lines = __TS__ArrayMap( -- 2161
			lines, -- 2161
			function(____, line) return removeIndentPrefix(line, indent) end -- 2161
		) -- 2161
	} -- 2161
end -- 2157
local function joinLines(lines) -- 2165
	return table.concat(lines, "\n") -- 2166
end -- 2165
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2169
	local function findWhitespaceTolerantReplacement() -- 2174
		local function foldWhitespace(text, withMap) -- 2176
			local parts = {} -- 2177
			local map = {} -- 2178
			local i = 0 -- 2179
			while i < #text do -- 2179
				local ch = __TS__StringAccess(text, i) -- 2181
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2181
					local start = i -- 2183
					while i < #text do -- 2183
						local next = __TS__StringAccess(text, i) -- 2185
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2185
							break -- 2186
						end -- 2186
						i = i + 1 -- 2187
					end -- 2187
					parts[#parts + 1] = " " -- 2189
					if withMap then -- 2189
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2190
					end -- 2190
				else -- 2190
					parts[#parts + 1] = ch -- 2192
					if withMap then -- 2192
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2193
					end -- 2193
					i = i + 1 -- 2194
				end -- 2194
			end -- 2194
			return { -- 2197
				text = table.concat(parts, ""), -- 2197
				map = map -- 2197
			} -- 2197
		end -- 2176
		local foldedContent = foldWhitespace(content, true) -- 2199
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2200
		if foldedOld == "" then -- 2200
			return {success = false, message = "old_str not found in file"} -- 2202
		end -- 2202
		local matches = {} -- 2204
		local pos = 0 -- 2205
		while true do -- 2205
			local idx = (string.find( -- 2207
				foldedContent.text, -- 2207
				foldedOld, -- 2207
				math.max(pos + 1, 1), -- 2207
				true -- 2207
			) or 0) - 1 -- 2207
			if idx < 0 then -- 2207
				break -- 2208
			end -- 2208
			local lastIdx = idx + #foldedOld - 1 -- 2209
			local startMap = foldedContent.map[idx + 1] -- 2210
			local endMap = foldedContent.map[lastIdx + 1] -- 2211
			if startMap ~= nil and endMap ~= nil then -- 2211
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2213
			end -- 2213
			pos = idx + #foldedOld -- 2215
		end -- 2215
		if #matches == 0 then -- 2215
			return {success = false, message = "old_str not found in file"} -- 2218
		end -- 2218
		if #matches > 1 then -- 2218
			return { -- 2221
				success = false, -- 2222
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2223
			} -- 2223
		end -- 2223
		local match = matches[1] -- 2226
		return { -- 2227
			success = true, -- 2228
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2229
		} -- 2229
	end -- 2174
	local contentLines = splitLines(content) -- 2232
	local oldLines = splitLines(oldStr) -- 2233
	if #oldLines == 0 then -- 2233
		return {success = false, message = "old_str not found in file"} -- 2235
	end -- 2235
	local dedentedOld = dedentLines(oldLines) -- 2237
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2238
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2239
	local matches = {} -- 2240
	do -- 2240
		local start = 0 -- 2241
		while start <= #contentLines - #oldLines do -- 2241
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2242
			local dedentedCandidate = dedentLines(candidateLines) -- 2243
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2243
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2245
			end -- 2245
			start = start + 1 -- 2241
		end -- 2241
	end -- 2241
	if #matches == 0 then -- 2241
		return findWhitespaceTolerantReplacement() -- 2253
	end -- 2253
	if #matches > 1 then -- 2253
		return { -- 2256
			success = false, -- 2257
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2258
		} -- 2258
	end -- 2258
	local match = matches[1] -- 2261
	local rebuiltNewLines = __TS__ArrayMap( -- 2262
		dedentedNew.lines, -- 2262
		function(____, line) return line == "" and "" or match.indent .. line end -- 2262
	) -- 2262
	local ____array_47 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2262
	__TS__SparseArrayPush( -- 2262
		____array_47, -- 2262
		table.unpack(rebuiltNewLines) -- 2265
	) -- 2265
	__TS__SparseArrayPush( -- 2265
		____array_47, -- 2265
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2266
	) -- 2266
	local nextLines = {__TS__SparseArraySpread(____array_47)} -- 2263
	return { -- 2268
		success = true, -- 2268
		content = joinLines(nextLines) -- 2268
	} -- 2268
end -- 2169
local MainDecisionAgent = __TS__Class() -- 2271
MainDecisionAgent.name = "MainDecisionAgent" -- 2271
__TS__ClassExtends(MainDecisionAgent, Node) -- 2271
function MainDecisionAgent.prototype.prep(self, shared) -- 2272
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2272
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2272
			return ____awaiter_resolve(nil, {shared = shared}) -- 2272
		end -- 2272
		__TS__Await(maybeCompressHistory(shared)) -- 2277
		return ____awaiter_resolve(nil, {shared = shared}) -- 2277
	end) -- 2277
end -- 2272
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2282
	local preExecuted = shared.preExecutedResults -- 2283
	if not preExecuted or preExecuted.size == 0 then -- 2283
		return nil -- 2284
	end -- 2284
	local decisions = {} -- 2285
	preExecuted:forEach(function(____, preResult) -- 2286
		local action = preResult.action -- 2287
		decisions[#decisions + 1] = { -- 2288
			success = true, -- 2289
			tool = action.tool, -- 2290
			params = action.params, -- 2291
			toolCallId = action.toolCallId, -- 2292
			reason = action.reason, -- 2293
			reasoningContent = action.reasoningContent -- 2294
		} -- 2294
	end) -- 2286
	if #decisions == 0 then -- 2286
		return nil -- 2297
	end -- 2297
	Log( -- 2298
		"Warn", -- 2298
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2298
			__TS__ArrayMap( -- 2298
				decisions, -- 2298
				function(____, decision) return decision.tool end -- 2298
			), -- 2298
			"," -- 2298
		) -- 2298
	) -- 2298
	if #decisions == 1 then -- 2298
		return decisions[1] -- 2300
	end -- 2300
	return {success = true, kind = "batch", decisions = decisions} -- 2302
end -- 2282
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2309
	if attempt == nil then -- 2309
		attempt = 1 -- 2312
	end -- 2312
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2312
		if shared.stopToken.stopped then -- 2312
			return ____awaiter_resolve( -- 2312
				nil, -- 2312
				{ -- 2316
					success = false, -- 2316
					message = getCancelledReason(shared) -- 2316
				} -- 2316
			) -- 2316
		end -- 2316
		Log( -- 2318
			"Info", -- 2318
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2318
		) -- 2318
		local tools = AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX) -- 2319
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2320
		local stepId = shared.step + 1 -- 2321
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2322
		emitLLMContextMetrics( -- 2326
			shared, -- 2326
			stepId, -- 2326
			"decision_tool_calling", -- 2326
			messages, -- 2326
			llmOptions -- 2326
		) -- 2326
		saveStepLLMDebugInput( -- 2327
			shared, -- 2327
			stepId, -- 2327
			"decision_tool_calling", -- 2327
			messages, -- 2327
			llmOptions -- 2327
		) -- 2327
		local lastStreamContent = "" -- 2328
		local lastStreamReasoning = "" -- 2329
		local preExecutedResults = __TS__New(Map) -- 2330
		shared.preExecutedResults = preExecutedResults -- 2331
		local res = __TS__Await(callLLMStreamAggregated( -- 2332
			messages, -- 2333
			llmOptions, -- 2334
			shared.stopToken, -- 2335
			shared.llmConfig, -- 2336
			function(response) -- 2337
				local ____opt_50 = response.choices -- 2337
				local ____opt_48 = ____opt_50 and ____opt_50[1] -- 2337
				local streamMessage = ____opt_48 and ____opt_48.message -- 2338
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2339
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2342
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2342
					return -- 2346
				end -- 2346
				lastStreamContent = nextContent -- 2348
				lastStreamReasoning = nextReasoning -- 2349
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2350
			end, -- 2337
			function(tc) -- 2352
				if shared.stopToken.stopped then -- 2352
					return -- 2353
				end -- 2353
				local action = createPreExecutableActionFromStream(shared, tc) -- 2354
				if not action or preExecutedResults:has(action.toolCallId) then -- 2354
					return -- 2355
				end -- 2355
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2356
				preExecutedResults:set( -- 2357
					action.toolCallId, -- 2357
					createPreExecutedToolResult(shared, action) -- 2357
				) -- 2357
			end -- 2352
		)) -- 2352
		if shared.stopToken.stopped then -- 2352
			clearPreExecutedResults(shared) -- 2361
			return ____awaiter_resolve( -- 2361
				nil, -- 2361
				{ -- 2362
					success = false, -- 2362
					message = getCancelledReason(shared) -- 2362
				} -- 2362
			) -- 2362
		end -- 2362
		if not res.success then -- 2362
			saveStepLLMDebugOutput( -- 2365
				shared, -- 2365
				stepId, -- 2365
				"decision_tool_calling", -- 2365
				res.raw or res.message, -- 2365
				{success = false} -- 2365
			) -- 2365
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2366
			if (string.find(res.message, "stream incomplete:", nil, true) or 0) - 1 >= 0 then -- 2366
				local ____opt_56 = res.response -- 2366
				local partialChoice = ____opt_56 and ____opt_56.choices and res.response.choices[1] -- 2368
				local partialMessage = partialChoice and partialChoice.message -- 2369
				local partialToolCalls = partialMessage and partialMessage.tool_calls -- 2370
				if partialToolCalls and #partialToolCalls > 0 then -- 2370
					local partialReasoningContent = partialMessage ~= nil and type(partialMessage.reasoning_content) == "string" and partialMessage.reasoning_content or nil -- 2372
					local partialMessageContent = partialMessage ~= nil and type(partialMessage.content) == "string" and __TS__StringTrim(partialMessage.content) or nil -- 2375
					local partialDecisions = {} -- 2378
					local partialFailure -- 2379
					do -- 2379
						local i = 0 -- 2380
						while i < #partialToolCalls do -- 2380
							local toolCall = partialToolCalls[i + 1] -- 2381
							local fn = toolCall ~= nil and toolCall["function"] -- 2382
							if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2382
								partialFailure = { -- 2384
									success = false, -- 2385
									message = "missing function name for partial tool call " .. tostring(i + 1), -- 2386
									raw = partialMessageContent -- 2387
								} -- 2387
								break -- 2389
							end -- 2389
							local decision = parseAndValidateToolCallDecision( -- 2391
								shared, -- 2392
								fn.name, -- 2393
								type(fn.arguments) == "string" and fn.arguments or "", -- 2394
								toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil, -- 2395
								partialMessageContent, -- 2396
								partialReasoningContent -- 2397
							) -- 2397
							if not decision.success then -- 2397
								partialFailure = decision -- 2400
								break -- 2401
							end -- 2401
							partialDecisions[#partialDecisions + 1] = decision -- 2403
							i = i + 1 -- 2380
						end -- 2380
					end -- 2380
					if not partialFailure and #partialDecisions > 0 then -- 2380
						Log( -- 2406
							"Warn", -- 2406
							"[CodingAgent] committing partial tool calls after incomplete stream tools=" .. table.concat( -- 2406
								__TS__ArrayMap( -- 2406
									partialDecisions, -- 2406
									function(____, decision) return decision.tool end -- 2406
								), -- 2406
								"," -- 2406
							) -- 2406
						) -- 2406
						if #partialDecisions == 1 then -- 2406
							return ____awaiter_resolve(nil, partialDecisions[1]) -- 2406
						end -- 2406
						return ____awaiter_resolve(nil, { -- 2406
							success = true, -- 2411
							kind = "batch", -- 2412
							decisions = partialDecisions, -- 2413
							content = partialMessageContent, -- 2414
							reasoningContent = partialReasoningContent -- 2415
						}) -- 2415
					end -- 2415
					Log("Warn", "[CodingAgent] partial tool calls not commit-ready after incomplete stream: " .. (partialFailure and partialFailure.message or "empty decisions")) -- 2418
				end -- 2418
				local committedDecision = self:commitPreExecutedDecision(shared) -- 2420
				if committedDecision then -- 2420
					return ____awaiter_resolve(nil, committedDecision) -- 2420
				end -- 2420
			end -- 2420
			clearPreExecutedResults(shared) -- 2425
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2425
		end -- 2425
		saveStepLLMDebugOutput( -- 2428
			shared, -- 2428
			stepId, -- 2428
			"decision_tool_calling", -- 2428
			encodeDebugJSON(res.response), -- 2428
			{success = true} -- 2428
		) -- 2428
		local choice = res.response.choices and res.response.choices[1] -- 2429
		local message = choice and choice.message -- 2430
		local toolCalls = message and message.tool_calls -- 2431
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2432
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2435
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2438
		Log( -- 2441
			"Info", -- 2441
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2441
		) -- 2441
		if not toolCalls or #toolCalls == 0 then -- 2441
			if finishReason == "length" then -- 2441
				Log( -- 2444
					"Error", -- 2444
					"[CodingAgent] tool-calling output truncated before tool call reasoning_len=" .. tostring(reasoningContent and #reasoningContent or 0) -- 2444
				) -- 2444
				clearPreExecutedResults(shared) -- 2445
				return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens before producing a tool call. Retry immediately with a valid tool call and keep reasoning minimal.", raw = reasoningContent or messageContent or ""}) -- 2445
			end -- 2445
			if messageContent and messageContent ~= "" then -- 2445
				Log( -- 2453
					"Info", -- 2453
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2453
				) -- 2453
				clearPreExecutedResults(shared) -- 2454
				return ____awaiter_resolve(nil, { -- 2454
					success = true, -- 2456
					tool = "finish", -- 2457
					params = {}, -- 2458
					reason = messageContent, -- 2459
					reasoningContent = reasoningContent, -- 2460
					directSummary = messageContent -- 2461
				}) -- 2461
			end -- 2461
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2464
			clearPreExecutedResults(shared) -- 2465
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2465
		end -- 2465
		local decisions = {} -- 2472
		do -- 2472
			local i = 0 -- 2473
			while i < #toolCalls do -- 2473
				local toolCall = toolCalls[i + 1] -- 2474
				local fn = toolCall ~= nil and toolCall["function"] -- 2475
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2475
					Log( -- 2477
						"Error", -- 2477
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2477
					) -- 2477
					clearPreExecutedResults(shared) -- 2478
					return ____awaiter_resolve( -- 2478
						nil, -- 2478
						{ -- 2479
							success = false, -- 2480
							message = "missing function name for tool call " .. tostring(i + 1), -- 2481
							raw = messageContent -- 2482
						} -- 2482
					) -- 2482
				end -- 2482
				local functionName = fn.name -- 2485
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2486
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 2487
				Log( -- 2490
					"Info", -- 2490
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2490
				) -- 2490
				local decision = parseAndValidateToolCallDecision( -- 2491
					shared, -- 2492
					functionName, -- 2493
					argsText, -- 2494
					toolCallId, -- 2495
					messageContent, -- 2496
					reasoningContent -- 2497
				) -- 2497
				if not decision.success then -- 2497
					Log( -- 2500
						"Error", -- 2500
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2500
					) -- 2500
					clearPreExecutedResults(shared) -- 2501
					return ____awaiter_resolve(nil, decision) -- 2501
				end -- 2501
				decisions[#decisions + 1] = decision -- 2504
				i = i + 1 -- 2473
			end -- 2473
		end -- 2473
		if #decisions == 1 then -- 2473
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2507
			return ____awaiter_resolve(nil, decisions[1]) -- 2507
		end -- 2507
		do -- 2507
			local i = 0 -- 2510
			while i < #decisions do -- 2510
				if decisions[i + 1].tool == "finish" then -- 2510
					clearPreExecutedResults(shared) -- 2512
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2512
				end -- 2512
				i = i + 1 -- 2510
			end -- 2510
		end -- 2510
		Log( -- 2520
			"Info", -- 2520
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2520
				__TS__ArrayMap( -- 2520
					decisions, -- 2520
					function(____, decision) return decision.tool end -- 2520
				), -- 2520
				"," -- 2520
			) -- 2520
		) -- 2520
		return ____awaiter_resolve(nil, { -- 2520
			success = true, -- 2522
			kind = "batch", -- 2523
			decisions = decisions, -- 2524
			content = messageContent, -- 2525
			reasoningContent = reasoningContent -- 2526
		}) -- 2526
	end) -- 2526
end -- 2309
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 2530
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2530
		Log( -- 2536
			"Info", -- 2536
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2536
		) -- 2536
		local lastError = initialError -- 2537
		local candidateRaw = "" -- 2538
		local candidateReasoning = nil -- 2539
		do -- 2539
			local attempt = 0 -- 2540
			while attempt < shared.llmMaxTry do -- 2540
				do -- 2540
					Log( -- 2541
						"Info", -- 2541
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2541
					) -- 2541
					local messages = buildXmlRepairMessages( -- 2542
						shared, -- 2543
						originalRaw, -- 2544
						originalReasoning, -- 2545
						candidateRaw, -- 2546
						candidateReasoning, -- 2547
						lastError, -- 2548
						attempt + 1 -- 2549
					) -- 2549
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2551
					if shared.stopToken.stopped then -- 2551
						return ____awaiter_resolve( -- 2551
							nil, -- 2551
							{ -- 2553
								success = false, -- 2553
								message = getCancelledReason(shared) -- 2553
							} -- 2553
						) -- 2553
					end -- 2553
					if not llmRes.success then -- 2553
						lastError = llmRes.message -- 2556
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2557
						goto __continue455 -- 2558
					end -- 2558
					candidateRaw = llmRes.text -- 2560
					candidateReasoning = llmRes.reasoningContent -- 2561
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2562
					if decision.success then -- 2562
						decision.reasoningContent = llmRes.reasoningContent -- 2564
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2565
						return ____awaiter_resolve(nil, decision) -- 2565
					end -- 2565
					lastError = decision.message -- 2568
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2569
				end -- 2569
				::__continue455:: -- 2569
				attempt = attempt + 1 -- 2540
			end -- 2540
		end -- 2540
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2571
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2571
	end) -- 2571
end -- 2530
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2579
	if attempt == nil then -- 2579
		attempt = 1 -- 2582
	end -- 2582
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2582
		local messages = buildDecisionMessages( -- 2585
			shared, -- 2586
			lastError, -- 2587
			attempt, -- 2588
			lastRaw, -- 2589
			"xml" -- 2590
		) -- 2590
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2592
		if shared.stopToken.stopped then -- 2592
			return ____awaiter_resolve( -- 2592
				nil, -- 2592
				{ -- 2594
					success = false, -- 2594
					message = getCancelledReason(shared) -- 2594
				} -- 2594
			) -- 2594
		end -- 2594
		if not llmRes.success then -- 2594
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2594
		end -- 2594
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2603
		if decision.success then -- 2603
			decision.reasoningContent = llmRes.reasoningContent -- 2605
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2605
				return ____awaiter_resolve( -- 2605
					nil, -- 2605
					self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2607
				) -- 2607
			end -- 2607
			return ____awaiter_resolve(nil, decision) -- 2607
		end -- 2607
		return ____awaiter_resolve( -- 2607
			nil, -- 2607
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 2616
		) -- 2616
	end) -- 2616
end -- 2579
function MainDecisionAgent.prototype.exec(self, input) -- 2619
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2619
		local shared = input.shared -- 2620
		if shared.stopToken.stopped then -- 2620
			return ____awaiter_resolve( -- 2620
				nil, -- 2620
				{ -- 2622
					success = false, -- 2622
					message = getCancelledReason(shared) -- 2622
				} -- 2622
			) -- 2622
		end -- 2622
		if shared.step >= shared.maxSteps then -- 2622
			Log( -- 2625
				"Warn", -- 2625
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2625
			) -- 2625
			return ____awaiter_resolve( -- 2625
				nil, -- 2625
				{ -- 2626
					success = false, -- 2626
					message = getMaxStepsReachedReason(shared) -- 2626
				} -- 2626
			) -- 2626
		end -- 2626
		if shared.decisionMode == "tool_calling" then -- 2626
			Log( -- 2630
				"Info", -- 2630
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2630
			) -- 2630
			local lastError = "tool calling validation failed" -- 2631
			local lastRaw = "" -- 2632
			local shouldFallbackToXml = false -- 2633
			do -- 2633
				local attempt = 0 -- 2634
				while attempt < shared.llmMaxTry do -- 2634
					Log( -- 2635
						"Info", -- 2635
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2635
					) -- 2635
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2636
					if shared.stopToken.stopped then -- 2636
						return ____awaiter_resolve( -- 2636
							nil, -- 2636
							{ -- 2643
								success = false, -- 2643
								message = getCancelledReason(shared) -- 2643
							} -- 2643
						) -- 2643
					end -- 2643
					if decision.success then -- 2643
						return ____awaiter_resolve(nil, decision) -- 2643
					end -- 2643
					lastError = decision.message -- 2648
					lastRaw = decision.raw or "" -- 2649
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2650
					if lastError == "missing tool call" then -- 2650
						shouldFallbackToXml = true -- 2652
						break -- 2653
					end -- 2653
					attempt = attempt + 1 -- 2634
				end -- 2634
			end -- 2634
			if shouldFallbackToXml then -- 2634
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2657
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2658
				do -- 2658
					local attempt = 0 -- 2659
					while attempt < shared.llmMaxTry do -- 2659
						Log( -- 2660
							"Info", -- 2660
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2660
						) -- 2660
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2661
						if shared.stopToken.stopped then -- 2661
							return ____awaiter_resolve( -- 2661
								nil, -- 2661
								{ -- 2668
									success = false, -- 2668
									message = getCancelledReason(shared) -- 2668
								} -- 2668
							) -- 2668
						end -- 2668
						if decision.success then -- 2668
							return ____awaiter_resolve(nil, decision) -- 2668
						end -- 2668
						lastError = decision.message -- 2673
						lastRaw = decision.raw or "" -- 2674
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2675
						attempt = attempt + 1 -- 2659
					end -- 2659
				end -- 2659
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2677
				return ____awaiter_resolve( -- 2677
					nil, -- 2677
					{ -- 2678
						success = false, -- 2678
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2678
					} -- 2678
				) -- 2678
			end -- 2678
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2680
			return ____awaiter_resolve( -- 2680
				nil, -- 2680
				{ -- 2681
					success = false, -- 2681
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2681
				} -- 2681
			) -- 2681
		end -- 2681
		local lastError = "xml validation failed" -- 2684
		local lastRaw = "" -- 2685
		do -- 2685
			local attempt = 0 -- 2686
			while attempt < shared.llmMaxTry do -- 2686
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2687
				if shared.stopToken.stopped then -- 2687
					return ____awaiter_resolve( -- 2687
						nil, -- 2687
						{ -- 2696
							success = false, -- 2696
							message = getCancelledReason(shared) -- 2696
						} -- 2696
					) -- 2696
				end -- 2696
				if decision.success then -- 2696
					return ____awaiter_resolve(nil, decision) -- 2696
				end -- 2696
				lastError = decision.message -- 2701
				lastRaw = decision.raw or "" -- 2702
				attempt = attempt + 1 -- 2686
			end -- 2686
		end -- 2686
		return ____awaiter_resolve( -- 2686
			nil, -- 2686
			{ -- 2704
				success = false, -- 2704
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2704
			} -- 2704
		) -- 2704
	end) -- 2704
end -- 2619
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2707
		local result = execRes -- 2708
		if not result.success then -- 2708
			if shared.stopToken.stopped then -- 2708
				shared.error = getCancelledReason(shared) -- 2711
				shared.done = true -- 2712
				return ____awaiter_resolve(nil, "done") -- 2712
			end -- 2712
			shared.error = result.message -- 2715
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2716
			shared.done = true -- 2717
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2718
			persistHistoryState(shared) -- 2722
			return ____awaiter_resolve(nil, "done") -- 2722
		end -- 2722
		if isDecisionBatchSuccess(result) then -- 2722
			local startStep = shared.step -- 2726
			local actions = {} -- 2727
			do -- 2727
				local i = 0 -- 2728
				while i < #result.decisions do -- 2728
					local decision = result.decisions[i + 1] -- 2729
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2730
					local step = startStep + i + 1 -- 2731
					local ____temp_58 -- 2732
					if i == 0 then -- 2732
						____temp_58 = decision.reason -- 2732
					else -- 2732
						____temp_58 = "" -- 2732
					end -- 2732
					local actionReason = ____temp_58 -- 2732
					local ____temp_59 -- 2733
					if i == 0 then -- 2733
						____temp_59 = decision.reasoningContent -- 2733
					else -- 2733
						____temp_59 = nil -- 2733
					end -- 2733
					local actionReasoningContent = ____temp_59 -- 2733
					emitAgentEvent(shared, { -- 2734
						type = "decision_made", -- 2735
						sessionId = shared.sessionId, -- 2736
						taskId = shared.taskId, -- 2737
						step = step, -- 2738
						tool = decision.tool, -- 2739
						reason = actionReason, -- 2740
						reasoningContent = actionReasoningContent, -- 2741
						params = decision.params -- 2742
					}) -- 2742
					local action = { -- 2744
						step = step, -- 2745
						toolCallId = toolCallId, -- 2746
						tool = decision.tool, -- 2747
						reason = actionReason or "", -- 2748
						reasoningContent = actionReasoningContent, -- 2749
						params = decision.params, -- 2750
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2751
					} -- 2751
					local ____shared_history_60 = shared.history -- 2751
					____shared_history_60[#____shared_history_60 + 1] = action -- 2753
					actions[#actions + 1] = action -- 2754
					i = i + 1 -- 2728
				end -- 2728
			end -- 2728
			shared.step = startStep + #actions -- 2756
			shared.pendingToolActions = actions -- 2757
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2758
			persistHistoryState(shared) -- 2764
			return ____awaiter_resolve(nil, "batch_tools") -- 2764
		end -- 2764
		if result.directSummary and result.directSummary ~= "" then -- 2764
			shared.response = result.directSummary -- 2768
			shared.done = true -- 2769
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2770
			persistHistoryState(shared) -- 2775
			return ____awaiter_resolve(nil, "done") -- 2775
		end -- 2775
		if result.tool == "finish" then -- 2775
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2779
			shared.response = finalMessage -- 2780
			shared.done = true -- 2781
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2782
			persistHistoryState(shared) -- 2787
			return ____awaiter_resolve(nil, "done") -- 2787
		end -- 2787
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2790
		shared.step = shared.step + 1 -- 2791
		local step = shared.step -- 2792
		emitAgentEvent(shared, { -- 2793
			type = "decision_made", -- 2794
			sessionId = shared.sessionId, -- 2795
			taskId = shared.taskId, -- 2796
			step = step, -- 2797
			tool = result.tool, -- 2798
			reason = result.reason, -- 2799
			reasoningContent = result.reasoningContent, -- 2800
			params = result.params -- 2801
		}) -- 2801
		local ____shared_history_61 = shared.history -- 2801
		____shared_history_61[#____shared_history_61 + 1] = { -- 2803
			step = step, -- 2804
			toolCallId = toolCallId, -- 2805
			tool = result.tool, -- 2806
			reason = result.reason or "", -- 2807
			reasoningContent = result.reasoningContent, -- 2808
			params = result.params, -- 2809
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2810
		} -- 2810
		local action = shared.history[#shared.history] -- 2812
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2813
		if AgentToolRegistry.canPreExecuteTool(action.tool) then -- 2813
			shared.pendingToolActions = {action} -- 2815
			persistHistoryState(shared) -- 2816
			return ____awaiter_resolve(nil, "batch_tools") -- 2816
		end -- 2816
		clearPreExecutedResults(shared) -- 2819
		persistHistoryState(shared) -- 2820
		return ____awaiter_resolve(nil, result.tool) -- 2820
	end) -- 2820
end -- 2707
local ReadFileAction = __TS__Class() -- 2825
ReadFileAction.name = "ReadFileAction" -- 2825
__TS__ClassExtends(ReadFileAction, Node) -- 2825
function ReadFileAction.prototype.prep(self, shared) -- 2826
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2826
		local last = shared.history[#shared.history] -- 2827
		if not last then -- 2827
			error( -- 2828
				__TS__New(Error, "no history"), -- 2828
				0 -- 2828
			) -- 2828
		end -- 2828
		emitAgentStartEvent(shared, last) -- 2829
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2830
		if __TS__StringTrim(path) == "" then -- 2830
			error( -- 2833
				__TS__New(Error, "missing path"), -- 2833
				0 -- 2833
			) -- 2833
		end -- 2833
		local ____path_64 = path -- 2835
		local ____shared_workingDir_65 = shared.workingDir -- 2837
		local ____temp_66 = shared.useChineseResponse and "zh" or "en" -- 2838
		local ____last_params_startLine_62 = last.params.startLine -- 2839
		if ____last_params_startLine_62 == nil then -- 2839
			____last_params_startLine_62 = 1 -- 2839
		end -- 2839
		local ____TS__Number_result_67 = __TS__Number(____last_params_startLine_62) -- 2839
		local ____last_params_endLine_63 = last.params.endLine -- 2840
		if ____last_params_endLine_63 == nil then -- 2840
			____last_params_endLine_63 = READ_FILE_DEFAULT_LIMIT -- 2840
		end -- 2840
		return ____awaiter_resolve( -- 2840
			nil, -- 2840
			{ -- 2834
				path = ____path_64, -- 2835
				tool = "read_file", -- 2836
				workDir = ____shared_workingDir_65, -- 2837
				docLanguage = ____temp_66, -- 2838
				startLine = ____TS__Number_result_67, -- 2839
				endLine = __TS__Number(____last_params_endLine_63) -- 2840
			} -- 2840
		) -- 2840
	end) -- 2840
end -- 2826
function ReadFileAction.prototype.exec(self, input) -- 2844
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2844
		return ____awaiter_resolve( -- 2844
			nil, -- 2844
			Tools.readFile( -- 2845
				input.workDir, -- 2846
				input.path, -- 2847
				__TS__Number(input.startLine or 1), -- 2848
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2849
				input.docLanguage -- 2850
			) -- 2850
		) -- 2850
	end) -- 2850
end -- 2844
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2854
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2854
		local result = execRes -- 2855
		local last = shared.history[#shared.history] -- 2856
		if last ~= nil then -- 2856
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2858
			appendToolResultMessage(shared, last) -- 2859
			emitAgentFinishEvent(shared, last) -- 2860
		end -- 2860
		persistHistoryState(shared) -- 2862
		__TS__Await(maybeCompressHistory(shared)) -- 2863
		persistHistoryState(shared) -- 2864
		return ____awaiter_resolve(nil, "main") -- 2864
	end) -- 2864
end -- 2854
local SearchFilesAction = __TS__Class() -- 2869
SearchFilesAction.name = "SearchFilesAction" -- 2869
__TS__ClassExtends(SearchFilesAction, Node) -- 2869
function SearchFilesAction.prototype.prep(self, shared) -- 2870
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2870
		local last = shared.history[#shared.history] -- 2871
		if not last then -- 2871
			error( -- 2872
				__TS__New(Error, "no history"), -- 2872
				0 -- 2872
			) -- 2872
		end -- 2872
		emitAgentStartEvent(shared, last) -- 2873
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2873
	end) -- 2873
end -- 2870
function SearchFilesAction.prototype.exec(self, input) -- 2877
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2877
		local params = input.params -- 2878
		local ____Tools_searchFiles_81 = Tools.searchFiles -- 2879
		local ____input_workDir_74 = input.workDir -- 2880
		local ____temp_75 = params.path or "" -- 2881
		local ____temp_76 = params.pattern or "" -- 2882
		local ____params_globs_77 = params.globs -- 2883
		local ____params_useRegex_78 = params.useRegex -- 2884
		local ____params_caseSensitive_79 = params.caseSensitive -- 2885
		local ____math_max_70 = math.max -- 2888
		local ____math_floor_69 = math.floor -- 2888
		local ____params_limit_68 = params.limit -- 2888
		if ____params_limit_68 == nil then -- 2888
			____params_limit_68 = SEARCH_FILES_LIMIT_DEFAULT -- 2888
		end -- 2888
		local ____math_max_70_result_80 = ____math_max_70( -- 2888
			1, -- 2888
			____math_floor_69(__TS__Number(____params_limit_68)) -- 2888
		) -- 2888
		local ____math_max_73 = math.max -- 2889
		local ____math_floor_72 = math.floor -- 2889
		local ____params_offset_71 = params.offset -- 2889
		if ____params_offset_71 == nil then -- 2889
			____params_offset_71 = 0 -- 2889
		end -- 2889
		local result = __TS__Await(____Tools_searchFiles_81({ -- 2879
			workDir = ____input_workDir_74, -- 2880
			path = ____temp_75, -- 2881
			pattern = ____temp_76, -- 2882
			globs = ____params_globs_77, -- 2883
			useRegex = ____params_useRegex_78, -- 2884
			caseSensitive = ____params_caseSensitive_79, -- 2885
			includeContent = true, -- 2886
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2887
			limit = ____math_max_70_result_80, -- 2888
			offset = ____math_max_73( -- 2889
				0, -- 2889
				____math_floor_72(__TS__Number(____params_offset_71)) -- 2889
			), -- 2889
			groupByFile = params.groupByFile == true -- 2890
		})) -- 2890
		return ____awaiter_resolve(nil, result) -- 2890
	end) -- 2890
end -- 2877
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2895
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2895
		local last = shared.history[#shared.history] -- 2896
		if last ~= nil then -- 2896
			local result = execRes -- 2898
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2899
			appendToolResultMessage(shared, last) -- 2900
			emitAgentFinishEvent(shared, last) -- 2901
		end -- 2901
		persistHistoryState(shared) -- 2903
		__TS__Await(maybeCompressHistory(shared)) -- 2904
		persistHistoryState(shared) -- 2905
		return ____awaiter_resolve(nil, "main") -- 2905
	end) -- 2905
end -- 2895
local SearchDoraAPIAction = __TS__Class() -- 2910
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2910
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2910
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2911
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2911
		local last = shared.history[#shared.history] -- 2912
		if not last then -- 2912
			error( -- 2913
				__TS__New(Error, "no history"), -- 2913
				0 -- 2913
			) -- 2913
		end -- 2913
		emitAgentStartEvent(shared, last) -- 2914
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2914
	end) -- 2914
end -- 2911
function SearchDoraAPIAction.prototype.exec(self, input) -- 2918
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2918
		local params = input.params -- 2919
		local ____Tools_searchDoraAPI_89 = Tools.searchDoraAPI -- 2920
		local ____temp_85 = params.pattern or "" -- 2921
		local ____temp_86 = params.docSource or "api" -- 2922
		local ____temp_87 = input.useChineseResponse and "zh" or "en" -- 2923
		local ____temp_88 = params.programmingLanguage or "ts" -- 2924
		local ____math_min_84 = math.min -- 2925
		local ____math_max_83 = math.max -- 2925
		local ____params_limit_82 = params.limit -- 2925
		if ____params_limit_82 == nil then -- 2925
			____params_limit_82 = 8 -- 2925
		end -- 2925
		local result = __TS__Await(____Tools_searchDoraAPI_89({ -- 2920
			pattern = ____temp_85, -- 2921
			docSource = ____temp_86, -- 2922
			docLanguage = ____temp_87, -- 2923
			programmingLanguage = ____temp_88, -- 2924
			limit = ____math_min_84( -- 2925
				SEARCH_DORA_API_LIMIT_MAX, -- 2925
				____math_max_83( -- 2925
					1, -- 2925
					__TS__Number(____params_limit_82) -- 2925
				) -- 2925
			), -- 2925
			useRegex = params.useRegex, -- 2926
			caseSensitive = false, -- 2927
			includeContent = true, -- 2928
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2929
		})) -- 2929
		return ____awaiter_resolve(nil, result) -- 2929
	end) -- 2929
end -- 2918
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2934
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2934
		local last = shared.history[#shared.history] -- 2935
		if last ~= nil then -- 2935
			local result = execRes -- 2937
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2938
			appendToolResultMessage(shared, last) -- 2939
			emitAgentFinishEvent(shared, last) -- 2940
		end -- 2940
		persistHistoryState(shared) -- 2942
		__TS__Await(maybeCompressHistory(shared)) -- 2943
		persistHistoryState(shared) -- 2944
		return ____awaiter_resolve(nil, "main") -- 2944
	end) -- 2944
end -- 2934
local ListFilesAction = __TS__Class() -- 2949
ListFilesAction.name = "ListFilesAction" -- 2949
__TS__ClassExtends(ListFilesAction, Node) -- 2949
function ListFilesAction.prototype.prep(self, shared) -- 2950
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2950
		local last = shared.history[#shared.history] -- 2951
		if not last then -- 2951
			error( -- 2952
				__TS__New(Error, "no history"), -- 2952
				0 -- 2952
			) -- 2952
		end -- 2952
		emitAgentStartEvent(shared, last) -- 2953
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2953
	end) -- 2953
end -- 2950
function ListFilesAction.prototype.exec(self, input) -- 2957
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2957
		local params = input.params -- 2958
		local ____Tools_listFiles_96 = Tools.listFiles -- 2959
		local ____input_workDir_93 = input.workDir -- 2960
		local ____temp_94 = params.path or "" -- 2961
		local ____params_globs_95 = params.globs -- 2962
		local ____math_max_92 = math.max -- 2963
		local ____math_floor_91 = math.floor -- 2963
		local ____params_maxEntries_90 = params.maxEntries -- 2963
		if ____params_maxEntries_90 == nil then -- 2963
			____params_maxEntries_90 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2963
		end -- 2963
		local result = ____Tools_listFiles_96({ -- 2959
			workDir = ____input_workDir_93, -- 2960
			path = ____temp_94, -- 2961
			globs = ____params_globs_95, -- 2962
			maxEntries = ____math_max_92( -- 2963
				1, -- 2963
				____math_floor_91(__TS__Number(____params_maxEntries_90)) -- 2963
			) -- 2963
		}) -- 2963
		return ____awaiter_resolve(nil, result) -- 2963
	end) -- 2963
end -- 2957
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2968
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2968
		local last = shared.history[#shared.history] -- 2969
		if last ~= nil then -- 2969
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2971
			appendToolResultMessage(shared, last) -- 2972
			emitAgentFinishEvent(shared, last) -- 2973
		end -- 2973
		persistHistoryState(shared) -- 2975
		__TS__Await(maybeCompressHistory(shared)) -- 2976
		persistHistoryState(shared) -- 2977
		return ____awaiter_resolve(nil, "main") -- 2977
	end) -- 2977
end -- 2968
local DeleteFileAction = __TS__Class() -- 2982
DeleteFileAction.name = "DeleteFileAction" -- 2982
__TS__ClassExtends(DeleteFileAction, Node) -- 2982
function DeleteFileAction.prototype.prep(self, shared) -- 2983
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2983
		local last = shared.history[#shared.history] -- 2984
		if not last then -- 2984
			error( -- 2985
				__TS__New(Error, "no history"), -- 2985
				0 -- 2985
			) -- 2985
		end -- 2985
		emitAgentStartEvent(shared, last) -- 2986
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2987
		if __TS__StringTrim(targetFile) == "" then -- 2987
			error( -- 2990
				__TS__New(Error, "missing target_file"), -- 2990
				0 -- 2990
			) -- 2990
		end -- 2990
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2990
	end) -- 2990
end -- 2983
function DeleteFileAction.prototype.exec(self, input) -- 2994
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2994
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2995
		if not result.success then -- 2995
			return ____awaiter_resolve(nil, result) -- 2995
		end -- 2995
		return ____awaiter_resolve(nil, { -- 2995
			success = true, -- 3003
			changed = true, -- 3004
			mode = "delete", -- 3005
			checkpointId = result.checkpointId, -- 3006
			checkpointSeq = result.checkpointSeq, -- 3007
			files = {{path = input.targetFile, op = "delete"}} -- 3008
		}) -- 3008
	end) -- 3008
end -- 2994
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3012
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3012
		local last = shared.history[#shared.history] -- 3013
		if last ~= nil then -- 3013
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3015
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3016
			appendToolResultMessage(shared, last) -- 3017
			emitAgentFinishEvent(shared, last) -- 3018
			local result = last.result -- 3019
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3019
				emitAgentEvent(shared, { -- 3024
					type = "checkpoint_created", -- 3025
					sessionId = shared.sessionId, -- 3026
					taskId = shared.taskId, -- 3027
					step = last.step, -- 3028
					tool = "delete_file", -- 3029
					checkpointId = result.checkpointId, -- 3030
					checkpointSeq = result.checkpointSeq, -- 3031
					files = result.files -- 3032
				}) -- 3032
			end -- 3032
		end -- 3032
		persistHistoryState(shared) -- 3039
		__TS__Await(maybeCompressHistory(shared)) -- 3040
		persistHistoryState(shared) -- 3041
		return ____awaiter_resolve(nil, "main") -- 3041
	end) -- 3041
end -- 3012
local BuildAction = __TS__Class() -- 3046
BuildAction.name = "BuildAction" -- 3046
__TS__ClassExtends(BuildAction, Node) -- 3046
function BuildAction.prototype.prep(self, shared) -- 3047
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3047
		local last = shared.history[#shared.history] -- 3048
		if not last then -- 3048
			error( -- 3049
				__TS__New(Error, "no history"), -- 3049
				0 -- 3049
			) -- 3049
		end -- 3049
		emitAgentStartEvent(shared, last) -- 3050
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3050
	end) -- 3050
end -- 3047
function BuildAction.prototype.exec(self, input) -- 3054
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3054
		local params = input.params -- 3055
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3056
		return ____awaiter_resolve(nil, result) -- 3056
	end) -- 3056
end -- 3054
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3063
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3063
		local last = shared.history[#shared.history] -- 3064
		if last ~= nil then -- 3064
			last.result = sanitizeBuildResultForHistory(execRes) -- 3066
			appendToolResultMessage(shared, last) -- 3067
			emitAgentFinishEvent(shared, last) -- 3068
		end -- 3068
		persistHistoryState(shared) -- 3070
		__TS__Await(maybeCompressHistory(shared)) -- 3071
		persistHistoryState(shared) -- 3072
		return ____awaiter_resolve(nil, "main") -- 3072
	end) -- 3072
end -- 3063
local SpawnSubAgentAction = __TS__Class() -- 3077
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3077
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3077
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3078
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3078
		local last = shared.history[#shared.history] -- 3087
		if not last then -- 3087
			error( -- 3088
				__TS__New(Error, "no history"), -- 3088
				0 -- 3088
			) -- 3088
		end -- 3088
		emitAgentStartEvent(shared, last) -- 3089
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3090
			last.params.filesHint, -- 3091
			function(____, item) return type(item) == "string" end -- 3091
		) or nil -- 3091
		return ____awaiter_resolve( -- 3091
			nil, -- 3091
			{ -- 3093
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3094
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3095
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3096
				filesHint = filesHint, -- 3097
				sessionId = shared.sessionId, -- 3098
				projectRoot = shared.workingDir, -- 3099
				spawnSubAgent = shared.spawnSubAgent -- 3100
			} -- 3100
		) -- 3100
	end) -- 3100
end -- 3078
function SpawnSubAgentAction.prototype.exec(self, input) -- 3104
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3104
		if not input.spawnSubAgent then -- 3104
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3104
		end -- 3104
		if input.sessionId == nil or input.sessionId <= 0 then -- 3104
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3104
		end -- 3104
		local ____Log_102 = Log -- 3119
		local ____temp_99 = #input.title -- 3119
		local ____temp_100 = #input.prompt -- 3119
		local ____temp_101 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3119
		local ____opt_97 = input.filesHint -- 3119
		____Log_102( -- 3119
			"Info", -- 3119
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_99)) .. " prompt_len=") .. tostring(____temp_100)) .. " expected_len=") .. tostring(____temp_101)) .. " files_hint_count=") .. tostring(____opt_97 and #____opt_97 or 0) -- 3119
		) -- 3119
		local result = __TS__Await(input.spawnSubAgent({ -- 3120
			parentSessionId = input.sessionId, -- 3121
			projectRoot = input.projectRoot, -- 3122
			title = input.title, -- 3123
			prompt = input.prompt, -- 3124
			expectedOutput = input.expectedOutput, -- 3125
			filesHint = input.filesHint -- 3126
		})) -- 3126
		if not result.success then -- 3126
			return ____awaiter_resolve(nil, result) -- 3126
		end -- 3126
		return ____awaiter_resolve(nil, { -- 3126
			success = true, -- 3132
			sessionId = result.sessionId, -- 3133
			taskId = result.taskId, -- 3134
			title = result.title, -- 3135
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3136
		}) -- 3136
	end) -- 3136
end -- 3104
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3140
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3140
		local last = shared.history[#shared.history] -- 3141
		if last ~= nil then -- 3141
			last.result = execRes -- 3143
			appendToolResultMessage(shared, last) -- 3144
			emitAgentFinishEvent(shared, last) -- 3145
		end -- 3145
		persistHistoryState(shared) -- 3147
		__TS__Await(maybeCompressHistory(shared)) -- 3148
		persistHistoryState(shared) -- 3149
		return ____awaiter_resolve(nil, "main") -- 3149
	end) -- 3149
end -- 3140
local ListSubAgentsAction = __TS__Class() -- 3154
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3154
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3154
function ListSubAgentsAction.prototype.prep(self, shared) -- 3155
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3155
		local last = shared.history[#shared.history] -- 3164
		if not last then -- 3164
			error( -- 3165
				__TS__New(Error, "no history"), -- 3165
				0 -- 3165
			) -- 3165
		end -- 3165
		emitAgentStartEvent(shared, last) -- 3166
		return ____awaiter_resolve( -- 3166
			nil, -- 3166
			{ -- 3167
				sessionId = shared.sessionId, -- 3168
				projectRoot = shared.workingDir, -- 3169
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3170
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3171
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3172
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3173
				listSubAgents = shared.listSubAgents -- 3174
			} -- 3174
		) -- 3174
	end) -- 3174
end -- 3155
function ListSubAgentsAction.prototype.exec(self, input) -- 3178
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3178
		if not input.listSubAgents then -- 3178
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3178
		end -- 3178
		if input.sessionId == nil or input.sessionId <= 0 then -- 3178
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3178
		end -- 3178
		local result = __TS__Await(input.listSubAgents({ -- 3193
			sessionId = input.sessionId, -- 3194
			projectRoot = input.projectRoot, -- 3195
			status = input.status, -- 3196
			limit = input.limit, -- 3197
			offset = input.offset, -- 3198
			query = input.query -- 3199
		})) -- 3199
		return ____awaiter_resolve(nil, result) -- 3199
	end) -- 3199
end -- 3178
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3204
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3204
		local last = shared.history[#shared.history] -- 3205
		if last ~= nil then -- 3205
			last.result = execRes -- 3207
			appendToolResultMessage(shared, last) -- 3208
			emitAgentFinishEvent(shared, last) -- 3209
		end -- 3209
		persistHistoryState(shared) -- 3211
		__TS__Await(maybeCompressHistory(shared)) -- 3212
		persistHistoryState(shared) -- 3213
		return ____awaiter_resolve(nil, "main") -- 3213
	end) -- 3213
end -- 3204
EditFileAction = __TS__Class() -- 3218
EditFileAction.name = "EditFileAction" -- 3218
__TS__ClassExtends(EditFileAction, Node) -- 3218
function EditFileAction.prototype.prep(self, shared) -- 3219
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3219
		local last = shared.history[#shared.history] -- 3220
		if not last then -- 3220
			error( -- 3221
				__TS__New(Error, "no history"), -- 3221
				0 -- 3221
			) -- 3221
		end -- 3221
		emitAgentStartEvent(shared, last) -- 3222
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3223
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3226
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3227
		if __TS__StringTrim(path) == "" then -- 3227
			error( -- 3228
				__TS__New(Error, "missing path"), -- 3228
				0 -- 3228
			) -- 3228
		end -- 3228
		return ____awaiter_resolve(nil, { -- 3228
			path = path, -- 3229
			oldStr = oldStr, -- 3229
			newStr = newStr, -- 3229
			taskId = shared.taskId, -- 3229
			workDir = shared.workingDir -- 3229
		}) -- 3229
	end) -- 3229
end -- 3219
function EditFileAction.prototype.exec(self, input) -- 3232
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3232
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3233
		if not readRes.success then -- 3233
			if input.oldStr ~= "" then -- 3233
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3233
			end -- 3233
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3238
			if not createRes.success then -- 3238
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3238
			end -- 3238
			return ____awaiter_resolve(nil, { -- 3238
				success = true, -- 3246
				changed = true, -- 3247
				mode = "create", -- 3248
				checkpointId = createRes.checkpointId, -- 3249
				checkpointSeq = createRes.checkpointSeq, -- 3250
				files = {{path = input.path, op = "create"}} -- 3251
			}) -- 3251
		end -- 3251
		if input.oldStr == "" then -- 3251
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3255
			if not overwriteRes.success then -- 3255
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3255
			end -- 3255
			return ____awaiter_resolve(nil, { -- 3255
				success = true, -- 3263
				changed = true, -- 3264
				mode = "overwrite", -- 3265
				checkpointId = overwriteRes.checkpointId, -- 3266
				checkpointSeq = overwriteRes.checkpointSeq, -- 3267
				files = {{path = input.path, op = "write"}} -- 3268
			}) -- 3268
		end -- 3268
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3273
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3274
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3275
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3278
		if occurrences == 0 then -- 3278
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3280
			if not indentTolerant.success then -- 3280
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3280
			end -- 3280
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3284
			if not applyRes.success then -- 3284
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3284
			end -- 3284
			return ____awaiter_resolve(nil, { -- 3284
				success = true, -- 3292
				changed = true, -- 3293
				mode = "replace_indent_tolerant", -- 3294
				checkpointId = applyRes.checkpointId, -- 3295
				checkpointSeq = applyRes.checkpointSeq, -- 3296
				files = {{path = input.path, op = "write"}} -- 3297
			}) -- 3297
		end -- 3297
		if occurrences > 1 then -- 3297
			return ____awaiter_resolve( -- 3297
				nil, -- 3297
				{ -- 3301
					success = false, -- 3301
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3301
				} -- 3301
			) -- 3301
		end -- 3301
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3305
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3306
		if not applyRes.success then -- 3306
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3306
		end -- 3306
		return ____awaiter_resolve(nil, { -- 3306
			success = true, -- 3314
			changed = true, -- 3315
			mode = "replace", -- 3316
			checkpointId = applyRes.checkpointId, -- 3317
			checkpointSeq = applyRes.checkpointSeq, -- 3318
			files = {{path = input.path, op = "write"}} -- 3319
		}) -- 3319
	end) -- 3319
end -- 3232
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3323
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3323
		local last = shared.history[#shared.history] -- 3324
		if last ~= nil then -- 3324
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3326
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3327
			appendToolResultMessage(shared, last) -- 3328
			emitAgentFinishEvent(shared, last) -- 3329
			local result = last.result -- 3330
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3330
				emitAgentEvent(shared, { -- 3335
					type = "checkpoint_created", -- 3336
					sessionId = shared.sessionId, -- 3337
					taskId = shared.taskId, -- 3338
					step = last.step, -- 3339
					tool = last.tool, -- 3340
					checkpointId = result.checkpointId, -- 3341
					checkpointSeq = result.checkpointSeq, -- 3342
					files = result.files -- 3343
				}) -- 3343
			end -- 3343
		end -- 3343
		persistHistoryState(shared) -- 3350
		__TS__Await(maybeCompressHistory(shared)) -- 3351
		persistHistoryState(shared) -- 3352
		return ____awaiter_resolve(nil, "main") -- 3352
	end) -- 3352
end -- 3323
local function emitCheckpointEventForAction(shared, action) -- 3357
	local result = action.result -- 3358
	if not result then -- 3358
		return -- 3359
	end -- 3359
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3359
		emitAgentEvent(shared, { -- 3364
			type = "checkpoint_created", -- 3365
			sessionId = shared.sessionId, -- 3366
			taskId = shared.taskId, -- 3367
			step = action.step, -- 3368
			tool = action.tool, -- 3369
			checkpointId = result.checkpointId, -- 3370
			checkpointSeq = result.checkpointSeq, -- 3371
			files = result.files -- 3372
		}) -- 3372
	end -- 3372
end -- 3357
local function canRunBatchActionInParallel(self, action) -- 3680
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 3681
end -- 3680
local function partitionToolCalls(actions) -- 3689
	local batches = {} -- 3690
	do -- 3690
		local i = 0 -- 3691
		while i < #actions do -- 3691
			local action = actions[i + 1] -- 3692
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3693
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3694
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3694
				local ____lastBatch_actions_137 = lastBatch.actions -- 3694
				____lastBatch_actions_137[#____lastBatch_actions_137 + 1] = action -- 3696
			else -- 3696
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3698
			end -- 3698
			i = i + 1 -- 3691
		end -- 3691
	end -- 3691
	return batches -- 3701
end -- 3689
local BatchToolAction = __TS__Class() -- 3704
BatchToolAction.name = "BatchToolAction" -- 3704
__TS__ClassExtends(BatchToolAction, Node) -- 3704
function BatchToolAction.prototype.prep(self, shared) -- 3705
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3705
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3705
	end) -- 3705
end -- 3705
function BatchToolAction.prototype.exec(self, input) -- 3709
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3709
		local shared = input.shared -- 3710
		local preExecuted = shared.preExecutedResults -- 3711
		local batches = partitionToolCalls(input.actions) -- 3712
		local parallelBatchCount = #__TS__ArrayFilter( -- 3713
			batches, -- 3713
			function(____, b) return b.isConcurrencySafe end -- 3713
		) -- 3713
		local serialBatchCount = #__TS__ArrayFilter( -- 3714
			batches, -- 3714
			function(____, b) return not b.isConcurrencySafe end -- 3714
		) -- 3714
		Log( -- 3715
			"Info", -- 3715
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3715
		) -- 3715
		do -- 3715
			local batchIdx = 0 -- 3717
			while batchIdx < #batches do -- 3717
				do -- 3717
					local batch = batches[batchIdx + 1] -- 3718
					if shared.stopToken.stopped then -- 3718
						for ____, action in ipairs(batch.actions) do -- 3720
							if not action.result then -- 3720
								action.result = { -- 3722
									success = false, -- 3722
									message = getCancelledReason(shared) -- 3722
								} -- 3722
							end -- 3722
						end -- 3722
						goto __continue627 -- 3725
					end -- 3725
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3725
						local preExecCount = #__TS__ArrayFilter( -- 3729
							batch.actions, -- 3729
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3729
						) -- 3729
						Log( -- 3730
							"Info", -- 3730
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3730
						) -- 3730
						do -- 3730
							local i = 0 -- 3731
							while i < #batch.actions do -- 3731
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3732
								i = i + 1 -- 3731
							end -- 3731
						end -- 3731
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3734
							batch.actions, -- 3734
							function(____, action) -- 3734
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3734
									if shared.stopToken.stopped then -- 3734
										action.result = { -- 3736
											success = false, -- 3736
											message = getCancelledReason(shared) -- 3736
										} -- 3736
										return ____awaiter_resolve(nil, action) -- 3736
									end -- 3736
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3739
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3740
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3741
									return ____awaiter_resolve(nil, action) -- 3741
								end) -- 3741
							end -- 3734
						))) -- 3734
						do -- 3734
							local i = 0 -- 3744
							while i < #batch.actions do -- 3744
								local action = batch.actions[i + 1] -- 3745
								if not action.result then -- 3745
									action.result = {success = false, message = "tool did not produce a result"} -- 3747
								end -- 3747
								appendToolResultMessage(shared, action) -- 3749
								emitAgentFinishEvent(shared, action) -- 3750
								emitCheckpointEventForAction(shared, action) -- 3751
								i = i + 1 -- 3744
							end -- 3744
						end -- 3744
					else -- 3744
						Log( -- 3754
							"Info", -- 3754
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3754
						) -- 3754
						do -- 3754
							local i = 0 -- 3755
							while i < #batch.actions do -- 3755
								local action = batch.actions[i + 1] -- 3756
								emitAgentStartEvent(shared, action) -- 3757
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3758
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3759
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3760
								appendToolResultMessage(shared, action) -- 3761
								emitAgentFinishEvent(shared, action) -- 3762
								emitCheckpointEventForAction(shared, action) -- 3763
								persistHistoryState(shared) -- 3764
								if shared.stopToken.stopped then -- 3764
									break -- 3766
								end -- 3766
								i = i + 1 -- 3755
							end -- 3755
						end -- 3755
					end -- 3755
				end -- 3755
				::__continue627:: -- 3755
				batchIdx = batchIdx + 1 -- 3717
			end -- 3717
		end -- 3717
		persistHistoryState(shared) -- 3771
		return ____awaiter_resolve(nil, input.actions) -- 3771
	end) -- 3771
end -- 3709
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3775
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3775
		shared.pendingToolActions = nil -- 3776
		shared.preExecutedResults = nil -- 3777
		persistHistoryState(shared) -- 3778
		__TS__Await(maybeCompressHistory(shared)) -- 3779
		persistHistoryState(shared) -- 3780
		return ____awaiter_resolve(nil, "main") -- 3780
	end) -- 3780
end -- 3775
local EndNode = __TS__Class() -- 3785
EndNode.name = "EndNode" -- 3785
__TS__ClassExtends(EndNode, Node) -- 3785
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3786
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3786
		return ____awaiter_resolve(nil, nil) -- 3786
	end) -- 3786
end -- 3786
local CodingAgentFlow = __TS__Class() -- 3791
CodingAgentFlow.name = "CodingAgentFlow" -- 3791
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3791
function CodingAgentFlow.prototype.____constructor(self, role) -- 3792
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3793
	local read = __TS__New(ReadFileAction, 1, 0) -- 3794
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3795
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3796
	local list = __TS__New(ListFilesAction, 1, 0) -- 3797
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3798
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3799
	local build = __TS__New(BuildAction, 1, 0) -- 3800
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3801
	local edit = __TS__New(EditFileAction, 1, 0) -- 3802
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3803
	local done = __TS__New(EndNode, 1, 0) -- 3804
	main:on("batch_tools", batch) -- 3806
	main:on("grep_files", search) -- 3807
	main:on("search_dora_api", searchDora) -- 3808
	main:on("glob_files", list) -- 3809
	if role == "main" then -- 3809
		main:on("read_file", read) -- 3811
		main:on("delete_file", del) -- 3812
		main:on("build", build) -- 3813
		main:on("edit_file", edit) -- 3814
		main:on("list_sub_agents", listSub) -- 3815
		main:on("spawn_sub_agent", spawn) -- 3816
	else -- 3816
		main:on("read_file", read) -- 3818
		main:on("delete_file", del) -- 3819
		main:on("build", build) -- 3820
		main:on("edit_file", edit) -- 3821
	end -- 3821
	main:on("done", done) -- 3823
	search:on("main", main) -- 3825
	searchDora:on("main", main) -- 3826
	list:on("main", main) -- 3827
	listSub:on("main", main) -- 3828
	spawn:on("main", main) -- 3829
	batch:on("main", main) -- 3830
	read:on("main", main) -- 3831
	del:on("main", main) -- 3832
	build:on("main", main) -- 3833
	edit:on("main", main) -- 3834
	Flow.prototype.____constructor(self, main) -- 3836
end -- 3792
local function runCodingAgentAsync(options) -- 3858
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3858
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3858
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3858
		end -- 3858
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3862
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3863
		if not llmConfigRes.success then -- 3863
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3863
		end -- 3863
		local llmConfig = llmConfigRes.config -- 3869
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3870
		if not taskRes.success then -- 3870
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3870
		end -- 3870
		local compressor = __TS__New(MemoryCompressor, { -- 3877
			compressionThreshold = 0.8, -- 3878
			compressionTargetThreshold = 0.5, -- 3879
			maxCompressionRounds = 3, -- 3880
			projectDir = options.workDir, -- 3881
			llmConfig = llmConfig, -- 3882
			promptPack = options.promptPack, -- 3883
			scope = options.memoryScope -- 3884
		}) -- 3884
		local persistedSession = compressor:getStorage():readSessionState() -- 3886
		local promptPack = compressor:getPromptPack() -- 3887
		local shared = { -- 3889
			sessionId = options.sessionId, -- 3890
			taskId = taskRes.taskId, -- 3891
			role = options.role or "main", -- 3892
			maxSteps = math.max( -- 3893
				1, -- 3893
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3893
			), -- 3893
			llmMaxTry = math.max( -- 3894
				1, -- 3894
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3894
			), -- 3894
			step = 0, -- 3895
			done = false, -- 3896
			stopToken = options.stopToken or ({stopped = false}), -- 3897
			response = "", -- 3898
			userQuery = normalizedPrompt, -- 3899
			workingDir = options.workDir, -- 3900
			useChineseResponse = options.useChineseResponse == true, -- 3901
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3902
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3905
			llmConfig = llmConfig, -- 3906
			onEvent = options.onEvent, -- 3907
			promptPack = promptPack, -- 3908
			history = {}, -- 3909
			messages = persistedSession.messages, -- 3910
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3911
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3912
			memory = {compressor = compressor}, -- 3914
			skills = {loader = AgentSkills.createSkillsLoader({projectDir = options.workDir})}, -- 3918
			spawnSubAgent = options.spawnSubAgent, -- 3923
			listSubAgents = options.listSubAgents -- 3924
		} -- 3924
		local ____hasReturned, ____returnValue -- 3924
		local ____try = __TS__AsyncAwaiter(function() -- 3924
			emitAgentEvent(shared, { -- 3928
				type = "task_started", -- 3929
				sessionId = shared.sessionId, -- 3930
				taskId = shared.taskId, -- 3931
				prompt = shared.userQuery, -- 3932
				workDir = shared.workingDir, -- 3933
				maxSteps = shared.maxSteps -- 3934
			}) -- 3934
			if shared.stopToken.stopped then -- 3934
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3937
				____hasReturned = true -- 3938
				____returnValue = emitAgentTaskFinishEvent( -- 3938
					shared, -- 3938
					false, -- 3938
					getCancelledReason(shared) -- 3938
				) -- 3938
				return -- 3938
			end -- 3938
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3940
			local promptCommand = getPromptCommand(shared.userQuery) -- 3941
			if promptCommand == "clear" then -- 3941
				____hasReturned = true -- 3943
				____returnValue = clearSessionHistory(shared) -- 3943
				return -- 3943
			end -- 3943
			if promptCommand == "compact" then -- 3943
				if shared.role == "sub" then -- 3943
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3947
					____hasReturned = true -- 3948
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3948
					return -- 3948
				end -- 3948
				____hasReturned = true -- 3956
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 3956
				return -- 3956
			end -- 3956
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3958
			persistHistoryState(shared) -- 3962
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3963
			__TS__Await(flow:run(shared)) -- 3964
			if shared.stopToken.stopped then -- 3964
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3966
				____hasReturned = true -- 3967
				____returnValue = emitAgentTaskFinishEvent( -- 3967
					shared, -- 3967
					false, -- 3967
					getCancelledReason(shared) -- 3967
				) -- 3967
				return -- 3967
			end -- 3967
			if shared.error then -- 3967
				____hasReturned = true -- 3970
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3970
				return -- 3970
			end -- 3970
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3973
			____hasReturned = true -- 3974
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3974
			return -- 3974
		end) -- 3974
		____try = ____try.catch( -- 3974
			____try, -- 3974
			function(____, e) -- 3974
				return __TS__AsyncAwaiter(function() -- 3974
					____hasReturned = true -- 3977
					____returnValue = finalizeAgentFailure( -- 3977
						shared, -- 3977
						tostring(e) -- 3977
					) -- 3977
					return -- 3977
				end) -- 3977
			end -- 3977
		) -- 3977
		__TS__Await(____try) -- 3927
		if ____hasReturned then -- 3927
			return ____awaiter_resolve(nil, ____returnValue) -- 3927
		end -- 3927
	end) -- 3927
end -- 3858
function ____exports.runCodingAgent(options, callback) -- 3981
	local ____self_140 = runCodingAgentAsync(options) -- 3981
	____self_140["then"]( -- 3981
		____self_140, -- 3981
		function(____, result) return callback(result) end -- 3982
	) -- 3982
end -- 3981
return ____exports -- 3981