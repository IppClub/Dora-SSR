-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Map = ____lualib.Map -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local isRecord, isArray, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, getFinishMessage, normalizeCompletionText, normalizeCompletionTextList, getCompletionReport, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, ensureToolCallId, hasXMLParam, inferToolNameFromXMLParams, parseDSMLAttribute, extractDSMLReason, parseDSMLToolCallObjectFromText, parseXMLToolCallObjectFromText, parseDecisionObject, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, validateCompletionForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, tryParseAndValidateDecision, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, HISTORY_READ_FILE_MAX_CHARS, HISTORY_READ_FILE_MAX_LINES, READ_FILE_DEFAULT_LIMIT, HISTORY_SEARCH_FILES_MAX_MATCHES, HISTORY_SEARCH_DORA_API_MAX_MATCHES, HISTORY_LIST_FILES_MAX_ENTRIES, HISTORY_BUILD_MAX_MESSAGES, HISTORY_BUILD_MESSAGE_MAX_CHARS, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT, SEARCH_PREVIEW_CONTEXT, COMPLETION_TEXT_MAX_CHARS, COMPLETION_LIST_MAX_ITEMS, COMPLETION_EVIDENCE_MAX_ITEMS, EditFileAction -- 1
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
local AgentConfig = require("Agent.AgentConfig") -- 12
function isRecord(value) -- 14
	return type(value) == "table" -- 15
end -- 15
function isArray(value) -- 18
	return __TS__ArrayIsArray(value) -- 19
end -- 19
function emitAgentEvent(shared, event) -- 422
	if shared.onEvent then -- 422
		do -- 422
			local function ____catch(____error) -- 422
				Log( -- 427
					"Error", -- 427
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 427
				) -- 427
			end -- 427
			local ____try, ____hasReturned = pcall(function() -- 427
				shared:onEvent(event) -- 425
			end) -- 425
			if not ____try then -- 425
				____catch(____hasReturned) -- 425
			end -- 425
		end -- 425
	end -- 425
end -- 425
function getCancelledReason(shared) -- 594
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 594
		return shared.stopToken.reason -- 595
	end -- 595
	return shared.useChineseResponse and "已取消" or "cancelled" -- 596
end -- 596
function ____exports.normalizePolicyPath(path) -- 658
	local normalized = table.concat( -- 659
		__TS__StringSplit( -- 659
			__TS__StringTrim(path), -- 659
			"\\" -- 659
		), -- 659
		"/" -- 659
	) -- 659
	while __TS__StringStartsWith(normalized, "./") do -- 659
		normalized = string.sub(normalized, 3) -- 660
	end -- 660
	return normalized -- 661
end -- 658
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 669
	local normalized = ____exports.normalizePolicyPath(path) -- 670
	return normalized == ".agent/main" or __TS__StringStartsWith(normalized, ".agent/main/") -- 671
end -- 669
function truncateText(text, maxLen) -- 831
	if #text <= maxLen then -- 831
		return text -- 832
	end -- 832
	local nextPos = utf8.offset(text, maxLen + 1) -- 833
	if nextPos == nil then -- 833
		return text -- 834
	end -- 834
	return string.sub(text, 1, nextPos - 1) .. "..." -- 835
end -- 835
function utf8TakeHead(text, maxChars) -- 838
	if maxChars <= 0 or text == "" then -- 838
		return "" -- 839
	end -- 839
	local nextPos = utf8.offset(text, maxChars + 1) -- 840
	if nextPos == nil then -- 840
		return text -- 841
	end -- 841
	return string.sub(text, 1, nextPos - 1) -- 842
end -- 842
function getReplyLanguageDirective(shared) -- 845
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 846
end -- 846
function replacePromptVars(template, vars) -- 851
	local output = template -- 852
	for key in pairs(vars) do -- 853
		output = table.concat( -- 854
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 854
			vars[key] or "" or "," -- 854
		) -- 854
	end -- 854
	return output -- 856
end -- 856
function limitReadContentForHistory(content, tool) -- 859
	local lines = __TS__StringSplit(content, "\n") -- 860
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 861
	local limitedByLines = overLineLimit and table.concat( -- 862
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 863
		"\n" -- 863
	) or content -- 863
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 863
		return content -- 866
	end -- 866
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 868
	local reasons = {} -- 871
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 871
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 872
	end -- 872
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 872
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 873
	end -- 873
	local hint = "Narrow the requested line range." -- 874
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 875
end -- 875
function sanitizeReadResultForHistory(tool, result) -- 890
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 890
		return result -- 892
	end -- 892
	local clone = {} -- 894
	for key in pairs(result) do -- 895
		clone[key] = result[key] -- 896
	end -- 896
	clone.content = limitReadContentForHistory(result.content, tool) -- 898
	return clone -- 899
end -- 899
function sanitizeSearchMatchesForHistory(items, maxItems) -- 902
	local shown = math.min(#items, maxItems) -- 906
	local out = {} -- 907
	do -- 907
		local i = 0 -- 908
		while i < shown do -- 908
			local row = items[i + 1] -- 909
			out[#out + 1] = { -- 910
				file = row.file, -- 911
				line = row.line, -- 912
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 913
			} -- 913
			i = i + 1 -- 908
		end -- 908
	end -- 908
	return out -- 918
end -- 918
function sanitizeSearchResultForHistory(tool, result) -- 921
	if result.success ~= true or not isArray(result.results) then -- 921
		return result -- 925
	end -- 925
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 925
		return result -- 926
	end -- 926
	local clone = {} -- 927
	for key in pairs(result) do -- 928
		clone[key] = result[key] -- 929
	end -- 929
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 931
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 932
	if tool == "grep_files" and isArray(result.groupedResults) then -- 932
		local grouped = result.groupedResults -- 937
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 938
		local sanitizedGroups = {} -- 939
		do -- 939
			local i = 0 -- 940
			while i < shown do -- 940
				local row = grouped[i + 1] -- 941
				sanitizedGroups[#sanitizedGroups + 1] = { -- 942
					file = row.file, -- 943
					totalMatches = row.totalMatches, -- 944
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 945
				} -- 945
				i = i + 1 -- 940
			end -- 940
		end -- 940
		clone.groupedResults = sanitizedGroups -- 950
	end -- 950
	return clone -- 952
end -- 952
function sanitizeListFilesResultForHistory(result) -- 955
	if result.success ~= true or not isArray(result.files) then -- 955
		return result -- 956
	end -- 956
	local clone = {} -- 957
	for key in pairs(result) do -- 958
		clone[key] = result[key] -- 959
	end -- 959
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 961
	return clone -- 962
end -- 962
function sanitizeBuildResultForHistory(result) -- 965
	if not isArray(result.messages) then -- 965
		return result -- 966
	end -- 966
	local clone = {} -- 967
	for key in pairs(result) do -- 968
		clone[key] = result[key] -- 969
	end -- 969
	local messages = result.messages -- 971
	local ordered = __TS__ArraySort( -- 972
		__TS__ArraySlice(messages), -- 972
		function(____, a, b) -- 972
			local aFailed = a.success ~= true -- 973
			local bFailed = b.success ~= true -- 974
			if aFailed == bFailed then -- 974
				return 0 -- 975
			end -- 975
			return aFailed and -1 or 1 -- 976
		end -- 972
	) -- 972
	local shown = math.min(#ordered, HISTORY_BUILD_MAX_MESSAGES) -- 978
	local sanitized = {} -- 979
	do -- 979
		local i = 0 -- 980
		while i < shown do -- 980
			local item = ordered[i + 1] -- 981
			local next = {} -- 982
			for key in pairs(item) do -- 983
				local value = item[key] -- 984
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 985
			end -- 985
			sanitized[#sanitized + 1] = next -- 989
			i = i + 1 -- 980
		end -- 980
	end -- 980
	clone.messages = sanitized -- 991
	if #ordered > shown then -- 991
		clone.truncatedMessages = #ordered - shown -- 993
	end -- 993
	return clone -- 995
end -- 995
function getDecisionToolDefinitions(shared) -- 1084
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1085
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1086
	local base = shared.promptPack.toolDefinitionsDetailed -- 1089
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1090
	if usesDefaultToolPrompts then -- 1090
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}, disabledAgentTools = shared.disabledAgentTools}) -- 1093
		return replacePromptVars(definitions, params) -- 1099
	end -- 1099
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1101
	if (shared and shared.decisionMode) ~= "xml" then -- 1101
		return withRole -- 1106
	end -- 1106
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1108
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1109
end -- 1109
function getFinishMessage(params, fallback) -- 1470
	if fallback == nil then -- 1470
		fallback = "" -- 1470
	end -- 1470
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1470
		return __TS__StringTrim(params.message) -- 1472
	end -- 1472
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1472
		return __TS__StringTrim(params.response) -- 1475
	end -- 1475
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1475
		return __TS__StringTrim(params.summary) -- 1478
	end -- 1478
	return __TS__StringTrim(fallback) -- 1480
end -- 1480
function normalizeCompletionText(value) -- 1487
	if type(value) ~= "string" then -- 1487
		return "" -- 1488
	end -- 1488
	return __TS__StringSlice( -- 1489
		__TS__StringTrim(sanitizeUTF8(value)), -- 1489
		0, -- 1489
		COMPLETION_TEXT_MAX_CHARS -- 1489
	) -- 1489
end -- 1489
function normalizeCompletionTextList(value, maxItems) -- 1492
	if maxItems == nil then -- 1492
		maxItems = COMPLETION_LIST_MAX_ITEMS -- 1492
	end -- 1492
	if not isArray(value) then -- 1492
		return {} -- 1493
	end -- 1493
	local items = {} -- 1494
	do -- 1494
		local i = 0 -- 1495
		while i < #value and #items < maxItems do -- 1495
			local item = normalizeCompletionText(value[i + 1]) -- 1496
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 1496
				items[#items + 1] = item -- 1497
			end -- 1497
			i = i + 1 -- 1495
		end -- 1495
	end -- 1495
	return items -- 1499
end -- 1499
function ____exports.normalizeAgentCompletionReport(value) -- 1502
	local row = value and not isArray(value) and isRecord(value) and value or ({}) -- 1503
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 1504
	local validation = {} -- 1507
	if isArray(row.validation) then -- 1507
		do -- 1507
			local i = 0 -- 1509
			while i < #row.validation and #validation < COMPLETION_LIST_MAX_ITEMS do -- 1509
				do -- 1509
					local raw = row.validation[i + 1] -- 1510
					if not raw or isArray(raw) or not isRecord(raw) then -- 1510
						goto __continue229 -- 1511
					end -- 1511
					local kind = (raw.kind == "runtime" or raw.kind == "manual") and raw.kind or (raw.kind == "build" and "build" or nil) -- 1512
					local result = (raw.result == "passed" or raw.result == "failed" or raw.result == "not_run") and raw.result or nil -- 1513
					if kind == nil or result == nil then -- 1513
						goto __continue229 -- 1514
					end -- 1514
					validation[#validation + 1] = { -- 1515
						kind = kind, -- 1516
						result = result, -- 1517
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS) -- 1518
					} -- 1518
				end -- 1518
				::__continue229:: -- 1518
				i = i + 1 -- 1509
			end -- 1509
		end -- 1509
	end -- 1509
	local learningCandidates = {} -- 1522
	if isArray(row.learningCandidates) then -- 1522
		do -- 1522
			local i = 0 -- 1524
			while i < #row.learningCandidates and #learningCandidates < COMPLETION_LIST_MAX_ITEMS do -- 1524
				do -- 1524
					local raw = row.learningCandidates[i + 1] -- 1525
					if not raw or isArray(raw) or not isRecord(raw) then -- 1525
						goto __continue234 -- 1526
					end -- 1526
					local claim = normalizeCompletionText(raw.claim) -- 1527
					if claim == "" then -- 1527
						goto __continue234 -- 1528
					end -- 1528
					learningCandidates[#learningCandidates + 1] = { -- 1529
						claim = claim, -- 1530
						scope = (raw.scope == "file" or raw.scope == "engine") and raw.scope or "project", -- 1531
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS), -- 1532
						confidence = raw.confidence == "inferred" and "inferred" or "observed" -- 1533
					} -- 1533
				end -- 1533
				::__continue234:: -- 1533
				i = i + 1 -- 1524
			end -- 1524
		end -- 1524
	end -- 1524
	return { -- 1537
		outcome = outcome, -- 1538
		validation = validation, -- 1539
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 1540
		assumptions = normalizeCompletionTextList(row.assumptions), -- 1541
		learningCandidates = learningCandidates -- 1542
	} -- 1542
end -- 1502
function getCompletionReport(params) -- 1546
	return ____exports.normalizeAgentCompletionReport(params) -- 1547
end -- 1547
function persistHistoryState(shared) -- 1550
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1551
end -- 1551
function getActiveConversationMessages(shared) -- 1558
	local activeMessages = {} -- 1559
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1559
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1566
	end -- 1566
	do -- 1566
		local i = shared.lastConsolidatedIndex -- 1570
		while i < #shared.messages do -- 1570
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1571
			i = i + 1 -- 1570
		end -- 1570
	end -- 1570
	return activeMessages -- 1573
end -- 1573
function getActiveRealMessageCount(shared) -- 1576
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1577
end -- 1577
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1580
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1586
	local previousActiveStart = shared.lastConsolidatedIndex -- 1587
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1588
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1589
	if type(carryMessageIndex) == "number" then -- 1589
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1589
		else -- 1589
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1597
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1600
		end -- 1600
	else -- 1600
		shared.carryMessageIndex = nil -- 1605
	end -- 1605
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1605
		shared.carryMessageIndex = nil -- 1615
	end -- 1615
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1623
	shared.resumeCheckpointPending = true -- 1624
	shared.resumeRequiredTool = nil -- 1625
	shared.resumeNarrowReadMode = true -- 1626
	if shared.unbuiltEdits == true then -- 1626
		shared.resumeRequiredTool = "build" -- 1634
	end -- 1634
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1643
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1643
		local marker = "**Next tool**:" -- 1654
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1655
		if markerIndex >= 0 then -- 1655
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1657
			local toolNames = { -- 1658
				"read_file", -- 1659
				"edit_file", -- 1659
				"delete_file", -- 1659
				"grep_files", -- 1659
				"search_dora_api", -- 1659
				"glob_files", -- 1660
				"build", -- 1660
				"fetch_url", -- 1660
				"execute_command", -- 1660
				"list_sub_agents", -- 1660
				"spawn_sub_agent", -- 1661
				"finish" -- 1661
			} -- 1661
			do -- 1661
				local i = 0 -- 1663
				while i < #toolNames do -- 1663
					local tool = toolNames[i + 1] -- 1664
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1664
						shared.resumeRequiredTool = tool -- 1666
						break -- 1667
					end -- 1667
					i = i + 1 -- 1663
				end -- 1663
			end -- 1663
		end -- 1663
	end -- 1663
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1663
		shared.resumeRequiredTool = nil -- 1673
	end -- 1673
end -- 1673
function ensureToolCallId(toolCallId) -- 1688
	if toolCallId and toolCallId ~= "" then -- 1688
		return toolCallId -- 1689
	end -- 1689
	return createLocalToolCallId() -- 1690
end -- 1690
function hasXMLParam(params, name) -- 1723
	return params[name] ~= nil -- 1724
end -- 1724
function inferToolNameFromXMLParams(params) -- 1727
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1727
		return "edit_file" -- 1729
	end -- 1729
	if hasXMLParam(params, "target_file") then -- 1729
		return "delete_file" -- 1732
	end -- 1732
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1732
		if hasXMLParam(params, "path") then -- 1732
			return "read_file" -- 1735
		end -- 1735
		return nil -- 1736
	end -- 1736
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1736
		if hasXMLParam(params, "pattern") then -- 1736
			return "search_dora_api" -- 1739
		end -- 1739
		return nil -- 1740
	end -- 1740
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1740
		if hasXMLParam(params, "pattern") then -- 1740
			return "grep_files" -- 1743
		end -- 1743
		return nil -- 1744
	end -- 1744
	if hasXMLParam(params, "globs") then -- 1744
		if hasXMLParam(params, "pattern") then -- 1744
			return "grep_files" -- 1747
		end -- 1747
		return "glob_files" -- 1748
	end -- 1748
	if hasXMLParam(params, "maxEntries") then -- 1748
		return "glob_files" -- 1751
	end -- 1751
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1751
		return "finish" -- 1754
	end -- 1754
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1754
		return "spawn_sub_agent" -- 1757
	end -- 1757
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1757
		return "list_sub_agents" -- 1760
	end -- 1760
	return nil -- 1762
end -- 1762
function parseDSMLAttribute(source, offset, name) -- 1765
	local attrOpen = name .. "=\"" -- 1766
	local attrStart = (string.find( -- 1767
		source, -- 1767
		attrOpen, -- 1767
		math.max(offset + 1, 1), -- 1767
		true -- 1767
	) or 0) - 1 -- 1767
	if attrStart < 0 then -- 1767
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1768
	end -- 1768
	local valueStart = attrStart + #attrOpen -- 1769
	local valueEnd = (string.find( -- 1770
		source, -- 1770
		"\"", -- 1770
		math.max(valueStart + 1, 1), -- 1770
		true -- 1770
	) or 0) - 1 -- 1770
	if valueEnd < 0 then -- 1770
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1771
	end -- 1771
	return { -- 1772
		success = true, -- 1773
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1774
		next = valueEnd + 1 -- 1775
	} -- 1775
end -- 1775
function extractDSMLReason(text, invokeStart, tool) -- 1779
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1780
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1781
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1781
		return before -- 1784
	end -- 1784
	if tool == "finish" then -- 1784
		return "" -- 1785
	end -- 1785
	return "Converted provider-native tool call syntax to XML." -- 1786
end -- 1786
function parseDSMLToolCallObjectFromText(text) -- 1789
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1790
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1791
	if invokeStart < 0 then -- 1791
		return {success = false, message = "missing DSML invoke"} -- 1792
	end -- 1792
	local nameStart = invokeStart + #invokeOpen -- 1793
	local nameEnd = (string.find( -- 1794
		text, -- 1794
		"\"", -- 1794
		math.max(nameStart + 1, 1), -- 1794
		true -- 1794
	) or 0) - 1 -- 1794
	if nameEnd < 0 then -- 1794
		return {success = false, message = "unterminated DSML invoke name"} -- 1795
	end -- 1795
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1796
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1796
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1798
	end -- 1798
	local invokeOpenEnd = (string.find( -- 1800
		text, -- 1800
		">", -- 1800
		math.max(nameEnd + 1, 1), -- 1800
		true -- 1800
	) or 0) - 1 -- 1800
	if invokeOpenEnd < 0 then -- 1800
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1801
	end -- 1801
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1802
	local invokeEnd = (string.find( -- 1803
		text, -- 1803
		invokeClose, -- 1803
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1803
		true -- 1803
	) or 0) - 1 -- 1803
	if invokeEnd < 0 then -- 1803
		return {success = false, message = "missing DSML invoke close tag"} -- 1804
	end -- 1804
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1806
	local params = {} -- 1807
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1808
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1809
	local pos = 0 -- 1810
	while pos < #body do -- 1810
		local start = (string.find( -- 1812
			body, -- 1812
			paramOpen, -- 1812
			math.max(pos + 1, 1), -- 1812
			true -- 1812
		) or 0) - 1 -- 1812
		if start < 0 then -- 1812
			break -- 1813
		end -- 1813
		local openEnd = (string.find( -- 1814
			body, -- 1814
			">", -- 1814
			math.max(start + #paramOpen + 1, 1), -- 1814
			true -- 1814
		) or 0) - 1 -- 1814
		if openEnd < 0 then -- 1814
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1815
		end -- 1815
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1816
		if not name.success then -- 1816
			return name -- 1817
		end -- 1817
		local close = (string.find( -- 1818
			body, -- 1818
			paramClose, -- 1818
			math.max(openEnd + 1 + 1, 1), -- 1818
			true -- 1818
		) or 0) - 1 -- 1818
		if close < 0 then -- 1818
			return {success = false, message = "missing DSML parameter close tag"} -- 1819
		end -- 1819
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1820
		pos = close + #paramClose -- 1821
	end -- 1821
	return { -- 1823
		success = true, -- 1824
		obj = { -- 1825
			tool = toolName, -- 1826
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1827
			params = params -- 1828
		} -- 1828
	} -- 1828
end -- 1828
function parseXMLToolCallObjectFromText(text) -- 1833
	local children = parseXMLObjectFromText(text, "tool_call") -- 1834
	local rawObj -- 1835
	if children.success then -- 1835
		rawObj = children.obj -- 1837
	else -- 1837
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1839
		if dsml.success then -- 1839
			return dsml -- 1840
		end -- 1840
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1841
		local paramsCloseToken = "</params>" -- 1842
		if toolStart >= 0 then -- 1842
			local paramsClose = (string.find( -- 1844
				text, -- 1844
				paramsCloseToken, -- 1844
				math.max(toolStart + 1, 1), -- 1844
				true -- 1844
			) or 0) - 1 -- 1844
			if paramsClose >= toolStart then -- 1844
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1846
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1847
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1847
					rawObj = bare.obj -- 1849
				end -- 1849
			end -- 1849
		end -- 1849
		if rawObj == nil then -- 1849
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1854
			if paramsOpen < 0 then -- 1854
				return children -- 1855
			end -- 1855
			local paramsCloseOnly = (string.find( -- 1856
				text, -- 1856
				paramsCloseToken, -- 1856
				math.max(paramsOpen + 1, 1), -- 1856
				true -- 1856
			) or 0) - 1 -- 1856
			if paramsCloseOnly < paramsOpen then -- 1856
				return children -- 1857
			end -- 1857
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1858
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1859
			if not paramsOnly.success then -- 1859
				return children -- 1860
			end -- 1860
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1861
			if inferredTool == nil then -- 1861
				return children -- 1862
			end -- 1862
			local ____temp_48 -- 1867
			if inferredTool == "finish" then -- 1867
				____temp_48 = nil -- 1867
			else -- 1867
				____temp_48 = "Inferred tool from XML params." -- 1867
			end -- 1867
			return {success = true, obj = {tool = inferredTool, reason = ____temp_48, params = paramsOnly.obj}} -- 1863
		end -- 1863
	end -- 1863
	if rawObj == nil then -- 1863
		return children -- 1873
	end -- 1873
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1874
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1875
	if not params.success then -- 1875
		return {success = false, message = params.message} -- 1879
	end -- 1879
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1881
end -- 1881
function parseDecisionObject(rawObj) -- 1977
	if type(rawObj.tool) ~= "string" then -- 1977
		return {success = false, message = "missing tool"} -- 1978
	end -- 1978
	local tool = rawObj.tool -- 1979
	if not AgentToolRegistry.isKnownToolName(tool) then -- 1979
		return {success = false, message = "unknown tool: " .. tool} -- 1981
	end -- 1981
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1983
	if tool ~= "finish" and (not reason or reason == "") then -- 1983
		return {success = false, message = tool .. " requires top-level reason"} -- 1987
	end -- 1987
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1989
	return {success = true, tool = tool, params = params, reason = reason} -- 1990
end -- 1990
function getDecisionPath(params) -- 2111
	if type(params.path) == "string" then -- 2111
		return __TS__StringTrim(params.path) -- 2112
	end -- 2112
	if type(params.target_file) == "string" then -- 2112
		return __TS__StringTrim(params.target_file) -- 2113
	end -- 2113
	return "" -- 2114
end -- 2114
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2117
	local num = __TS__Number(value) -- 2118
	if not __TS__NumberIsFinite(num) then -- 2118
		num = fallback -- 2119
	end -- 2119
	num = math.floor(num) -- 2120
	if num < minValue then -- 2120
		num = minValue -- 2121
	end -- 2121
	if maxValue ~= nil and num > maxValue then -- 2121
		num = maxValue -- 2122
	end -- 2122
	return num -- 2123
end -- 2123
function parseReadLineParam(value, fallback, paramName) -- 2126
	local num = __TS__Number(value) -- 2131
	if not __TS__NumberIsFinite(num) then -- 2131
		num = fallback -- 2132
	end -- 2132
	num = math.floor(num) -- 2133
	if num == 0 then -- 2133
		return {success = false, message = paramName .. " cannot be 0"} -- 2135
	end -- 2135
	return {success = true, value = num} -- 2137
end -- 2137
function validateDecision(tool, params) -- 2140
	if tool == "finish" then -- 2140
		local message = getFinishMessage(params) -- 2145
		if message == "" then -- 2145
			return {success = false, message = "finish requires params.message"} -- 2146
		end -- 2146
		params.message = message -- 2147
		local completion = getCompletionReport(params) -- 2148
		params.outcome = completion.outcome -- 2149
		params.validation = completion.validation -- 2150
		params.knownIssues = completion.knownIssues -- 2151
		params.assumptions = completion.assumptions -- 2152
		params.learningCandidates = completion.learningCandidates -- 2153
		return {success = true, params = params} -- 2154
	end -- 2154
	if tool == "read_file" then -- 2154
		local path = getDecisionPath(params) -- 2158
		if path == "" then -- 2158
			return {success = false, message = "read_file requires path"} -- 2159
		end -- 2159
		params.path = path -- 2160
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2161
		if not startLineRes.success then -- 2161
			return startLineRes -- 2162
		end -- 2162
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 2163
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2164
		if not endLineRes.success then -- 2164
			return endLineRes -- 2165
		end -- 2165
		params.startLine = startLineRes.value -- 2166
		params.endLine = endLineRes.value -- 2167
		return {success = true, params = params} -- 2168
	end -- 2168
	if tool == "edit_file" then -- 2168
		local path = getDecisionPath(params) -- 2172
		if path == "" then -- 2172
			return {success = false, message = "edit_file requires path"} -- 2173
		end -- 2173
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2174
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2175
		params.path = path -- 2176
		params.old_str = oldStr -- 2177
		params.new_str = newStr -- 2178
		return {success = true, params = params} -- 2179
	end -- 2179
	if tool == "delete_file" then -- 2179
		local targetFile = getDecisionPath(params) -- 2183
		if targetFile == "" then -- 2183
			return {success = false, message = "delete_file requires target_file"} -- 2184
		end -- 2184
		params.target_file = targetFile -- 2185
		return {success = true, params = params} -- 2186
	end -- 2186
	if tool == "grep_files" then -- 2186
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2190
		if pattern == "" then -- 2190
			return {success = false, message = "grep_files requires pattern"} -- 2191
		end -- 2191
		params.pattern = pattern -- 2192
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2193
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2194
		return {success = true, params = params} -- 2195
	end -- 2195
	if tool == "search_dora_api" then -- 2195
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2199
		if pattern == "" then -- 2199
			return {success = false, message = "search_dora_api requires pattern"} -- 2200
		end -- 2200
		params.pattern = pattern -- 2201
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2202
		return {success = true, params = params} -- 2203
	end -- 2203
	if tool == "glob_files" then -- 2203
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2207
		return {success = true, params = params} -- 2208
	end -- 2208
	if tool == "build" then -- 2208
		local path = getDecisionPath(params) -- 2212
		if path ~= "" then -- 2212
			params.path = path -- 2214
		end -- 2214
		return {success = true, params = params} -- 2216
	end -- 2216
	if tool == "list_sub_agents" then -- 2216
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2220
		if status ~= "" then -- 2220
			params.status = status -- 2222
		end -- 2222
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2224
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2225
		if type(params.query) == "string" then -- 2225
			params.query = __TS__StringTrim(params.query) -- 2227
		end -- 2227
		return {success = true, params = params} -- 2229
	end -- 2229
	if tool == "spawn_sub_agent" then -- 2229
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2233
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2234
		if prompt == "" then -- 2234
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2235
		end -- 2235
		if title == "" then -- 2235
			return {success = false, message = "spawn_sub_agent requires title"} -- 2236
		end -- 2236
		params.prompt = prompt -- 2237
		params.title = title -- 2238
		if type(params.expectedOutput) == "string" then -- 2238
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2240
		end -- 2240
		if isArray(params.filesHint) then -- 2240
			params.filesHint = __TS__ArrayMap( -- 2243
				__TS__ArrayFilter( -- 2243
					params.filesHint, -- 2243
					function(____, item) return type(item) == "string" end -- 2244
				), -- 2244
				function(____, item) return sanitizeUTF8(item) end -- 2245
			) -- 2245
		end -- 2245
		return {success = true, params = params} -- 2247
	end -- 2247
	return {success = true, params = params} -- 2250
end -- 2250
function validateCompletionForRole(role, tool, params) -- 2253
	if role ~= "sub" or tool ~= "finish" then -- 2253
		return {success = true} -- 2258
	end -- 2258
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2258
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2260
	end -- 2260
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2262
	do -- 2262
		local i = 0 -- 2263
		while i < #requiredArrays do -- 2263
			local name = requiredArrays[i + 1] -- 2264
			if not isArray(params[name]) then -- 2264
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2266
			end -- 2266
			i = i + 1 -- 2263
		end -- 2263
	end -- 2263
	return {success = true} -- 2269
end -- 2269
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2272
	if includeToolDefinitions == nil then -- 2272
		includeToolDefinitions = false -- 2272
	end -- 2272
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2273
	local sections = { -- 2276
		shared.promptPack.agentIdentityPrompt, -- 2277
		rolePrompt, -- 2278
		getReplyLanguageDirective(shared) -- 2279
	} -- 2279
	if shared.decisionMode == "tool_calling" then -- 2279
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2282
	end -- 2282
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2284
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2285
	if memoryContext ~= "" then -- 2285
		sections[#sections + 1] = memoryContext -- 2287
	end -- 2287
	local skillsSection = buildSkillsSection(shared) -- 2289
	if skillsSection ~= "" then -- 2289
		sections[#sections + 1] = skillsSection -- 2291
	end -- 2291
	if includeToolDefinitions then -- 2291
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2294
		if shared.decisionMode == "xml" then -- 2294
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2296
		end -- 2296
	end -- 2296
	return table.concat(sections, "\n\n") -- 2299
end -- 2299
function buildSkillsSection(shared) -- 2302
	local ____opt_67 = shared.skills -- 2302
	if not (____opt_67 and ____opt_67.loader) then -- 2302
		return "" -- 2304
	end -- 2304
	return shared.skills.loader:buildSkillsPromptSection() -- 2306
end -- 2306
function buildXmlDecisionInstruction(shared, feedback) -- 2443
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2444
end -- 2444
function tryParseAndValidateDecision(rawText, role) -- 2524
	if role == nil then -- 2524
		role = "main" -- 2524
	end -- 2524
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2525
	if not parsed.success then -- 2525
		return {success = false, message = parsed.message, raw = rawText} -- 2527
	end -- 2527
	local decision = parseDecisionObject(parsed.obj) -- 2529
	if not decision.success then -- 2529
		return {success = false, message = decision.message, raw = rawText} -- 2531
	end -- 2531
	local completionValidation = validateCompletionForRole(role, decision.tool, decision.params) -- 2533
	if not completionValidation.success then -- 2533
		return {success = false, message = completionValidation.message, raw = rawText} -- 2535
	end -- 2535
	local validation = validateDecision(decision.tool, decision.params) -- 2537
	if not validation.success then -- 2537
		return {success = false, message = validation.message, raw = rawText} -- 2539
	end -- 2539
	decision.params = validation.params -- 2541
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2542
	return decision -- 2543
end -- 2543
function executeToolAction(shared, action) -- 3875
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3875
		if shared.stopToken.stopped then -- 3875
			return ____awaiter_resolve( -- 3875
				nil, -- 3875
				{ -- 3877
					success = false, -- 3877
					message = getCancelledReason(shared) -- 3877
				} -- 3877
			) -- 3877
		end -- 3877
		if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 3877
			return ____awaiter_resolve(nil, {success = false, message = "The bounded foreground work after delegation is complete. Dispatch another independent sub-agent if needed, or finish this turn now so the user can continue interacting."}) -- 3877
		end -- 3877
		if shared.resumeRequiredTool ~= nil then -- 3877
			if action.tool ~= shared.resumeRequiredTool then -- 3877
				return ____awaiter_resolve(nil, {success = false, message = ((("Compression checkpoint requires " .. shared.resumeRequiredTool) .. " next. Do not restart discovery or use ") .. action.tool) .. "."}) -- 3877
			end -- 3877
			shared.resumeRequiredTool = nil -- 3896
			shared.resumeCheckpointPending = false -- 3897
		end -- 3897
		local params = action.params -- 3899
		if action.tool == "read_file" then -- 3899
			local ____params_startLine_125 = params.startLine -- 3901
			if ____params_startLine_125 == nil then -- 3901
				____params_startLine_125 = 1 -- 3901
			end -- 3901
			local startLine = __TS__Number(____params_startLine_125) -- 3901
			local ____params_endLine_126 = params.endLine -- 3902
			if ____params_endLine_126 == nil then -- 3902
				____params_endLine_126 = READ_FILE_DEFAULT_LIMIT -- 3902
			end -- 3902
			local endLine = __TS__Number(____params_endLine_126) -- 3902
			local clippedAfterCompression = false -- 3903
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 3903
				endLine = startLine + 159 -- 3910
				clippedAfterCompression = true -- 3911
			end -- 3911
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3913
			if __TS__StringTrim(path) == "" then -- 3913
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3913
			end -- 3913
			if shared.failedTestNeedsBuild == true and string.sub( -- 3913
				string.lower(path), -- 3917
				-4 -- 3917
			) == ".lua" then -- 3917
				return ____awaiter_resolve(nil, {success = false, message = "The deterministic test report failed. Inspect and fix the authored source/test instead of reading generated Lua, then build successfully before testing again."}) -- 3917
			end -- 3917
			local result = Tools.readFile( -- 3923
				shared.workingDir, -- 3924
				path, -- 3925
				startLine, -- 3926
				endLine, -- 3927
				shared.useChineseResponse and "zh" or "en" -- 3928
			) -- 3928
			if clippedAfterCompression and result.success == true then -- 3928
				result.clipped = true -- 3931
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 3932
			end -- 3932
			return ____awaiter_resolve(nil, result) -- 3932
		end -- 3932
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 3932
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3939
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3942
			if __TS__StringTrim(path) ~= "" and oldStr == "" then -- 3942
				local existing = Tools.readFileRaw(shared.workingDir, path) -- 3944
				if existing.success then -- 3944
					return ____awaiter_resolve(nil, {success = false, message = "After compression, do not overwrite a complete existing file. Continue from the checkpoint with build, a narrow read, or a targeted old_str replacement."}) -- 3944
				end -- 3944
			end -- 3944
		end -- 3944
		if action.tool ~= "build" then -- 3944
			shared.resumeNarrowReadMode = false -- 3957
		end -- 3957
		if action.tool == "grep_files" then -- 3957
			local searchPath = params.path or "" -- 3959
			local searchGlobs = params.globs -- 3960
			local searchesGeneratedLua = string.sub( -- 3961
				string.lower(searchPath), -- 3961
				-4 -- 3961
			) == ".lua" -- 3961
			if not searchesGeneratedLua and searchGlobs ~= nil then -- 3961
				do -- 3961
					local i = 0 -- 3963
					while i < #searchGlobs do -- 3963
						if (string.find( -- 3963
							string.lower(searchGlobs[i + 1]), -- 3964
							".lua", -- 3964
							nil, -- 3964
							true -- 3964
						) or 0) - 1 >= 0 then -- 3964
							searchesGeneratedLua = true -- 3965
							break -- 3966
						end -- 3966
						i = i + 1 -- 3963
					end -- 3963
				end -- 3963
			end -- 3963
			if shared.failedTestNeedsBuild == true and searchesGeneratedLua then -- 3963
				return ____awaiter_resolve(nil, {success = false, message = "The deterministic test report failed. Search the authored source/test, not generated Lua, make the smallest source fix, and build successfully before testing again."}) -- 3963
			end -- 3963
			local ____Tools_searchFiles_139 = Tools.searchFiles -- 3976
			local ____shared_workingDir_133 = shared.workingDir -- 3977
			local ____temp_134 = params.pattern or "" -- 3979
			local ____params_globs_135 = params.globs -- 3980
			local ____params_useRegex_136 = params.useRegex -- 3981
			local ____params_caseSensitive_137 = params.caseSensitive -- 3982
			local ____math_max_129 = math.max -- 3985
			local ____math_floor_128 = math.floor -- 3985
			local ____params_limit_127 = params.limit -- 3985
			if ____params_limit_127 == nil then -- 3985
				____params_limit_127 = SEARCH_FILES_LIMIT_DEFAULT -- 3985
			end -- 3985
			local ____math_max_129_result_138 = ____math_max_129( -- 3985
				1, -- 3985
				____math_floor_128(__TS__Number(____params_limit_127)) -- 3985
			) -- 3985
			local ____math_max_132 = math.max -- 3986
			local ____math_floor_131 = math.floor -- 3986
			local ____params_offset_130 = params.offset -- 3986
			if ____params_offset_130 == nil then -- 3986
				____params_offset_130 = 0 -- 3986
			end -- 3986
			local result = __TS__Await(____Tools_searchFiles_139({ -- 3976
				workDir = ____shared_workingDir_133, -- 3977
				path = searchPath, -- 3978
				pattern = ____temp_134, -- 3979
				globs = ____params_globs_135, -- 3980
				useRegex = ____params_useRegex_136, -- 3981
				caseSensitive = ____params_caseSensitive_137, -- 3982
				includeContent = true, -- 3983
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3984
				limit = ____math_max_129_result_138, -- 3985
				offset = ____math_max_132( -- 3986
					0, -- 3986
					____math_floor_131(__TS__Number(____params_offset_130)) -- 3986
				), -- 3986
				groupByFile = params.groupByFile == true -- 3987
			})) -- 3987
			return ____awaiter_resolve(nil, result) -- 3987
		end -- 3987
		if action.tool == "search_dora_api" then -- 3987
			if shared.unbuiltEdits == true then -- 3987
				return ____awaiter_resolve(nil, {success = false, message = "Build the authored changes before another Dora API search. Search again only if the compiler or runtime diagnostics require an unfamiliar API."}) -- 3987
			end -- 3987
			if (shared.apiSearchesSinceBuild or 0) >= 1 then -- 3987
				return ____awaiter_resolve(nil, {success = false, message = "Only one Dora API lookup is allowed between builds. Apply the returned signature and build before searching again."}) -- 3987
			end -- 3987
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4004
			local ____Tools_searchDoraAPI_147 = Tools.searchDoraAPI -- 4005
			local ____temp_143 = params.pattern or "" -- 4006
			local ____temp_144 = params.docSource or "api" -- 4007
			local ____temp_145 = shared.useChineseResponse and "zh" or "en" -- 4008
			local ____temp_146 = params.programmingLanguage or "ts" -- 4009
			local ____math_min_142 = math.min -- 4010
			local ____math_max_141 = math.max -- 4010
			local ____params_limit_140 = params.limit -- 4010
			if ____params_limit_140 == nil then -- 4010
				____params_limit_140 = 8 -- 4010
			end -- 4010
			local result = __TS__Await(____Tools_searchDoraAPI_147({ -- 4005
				pattern = ____temp_143, -- 4006
				docSource = ____temp_144, -- 4007
				docLanguage = ____temp_145, -- 4008
				programmingLanguage = ____temp_146, -- 4009
				limit = ____math_min_142( -- 4010
					SEARCH_DORA_API_LIMIT_MAX, -- 4010
					____math_max_141( -- 4010
						1, -- 4010
						__TS__Number(____params_limit_140) -- 4010
					) -- 4010
				), -- 4010
				useRegex = params.useRegex, -- 4011
				caseSensitive = false, -- 4012
				includeContent = true, -- 4013
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 4014
			})) -- 4014
			return ____awaiter_resolve(nil, result) -- 4014
		end -- 4014
		if action.tool == "glob_files" then -- 4014
			local ____Tools_listFiles_154 = Tools.listFiles -- 4019
			local ____shared_workingDir_151 = shared.workingDir -- 4020
			local ____temp_152 = params.path or "" -- 4021
			local ____params_globs_153 = params.globs -- 4022
			local ____math_max_150 = math.max -- 4023
			local ____math_floor_149 = math.floor -- 4023
			local ____params_maxEntries_148 = params.maxEntries -- 4023
			if ____params_maxEntries_148 == nil then -- 4023
				____params_maxEntries_148 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 4023
			end -- 4023
			local result = ____Tools_listFiles_154({ -- 4019
				workDir = ____shared_workingDir_151, -- 4020
				path = ____temp_152, -- 4021
				globs = ____params_globs_153, -- 4022
				maxEntries = ____math_max_150( -- 4023
					1, -- 4023
					____math_floor_149(__TS__Number(____params_maxEntries_148)) -- 4023
				) -- 4023
			}) -- 4023
			return ____awaiter_resolve(nil, result) -- 4023
		end -- 4023
		if action.tool == "delete_file" then -- 4023
			local editLimit = 3 -- 4028
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4029
			if __TS__StringTrim(targetFile) == "" then -- 4029
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4029
			end -- 4029
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4033
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4034
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 and #editedPaths >= editLimit then -- 4034
				return ____awaiter_resolve(nil, {success = false, message = "Build the current authored changes now before editing a fourth source file. Multiple related replacements in the same source file count as one build-cycle edit."}) -- 4034
			end -- 4034
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4034
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4034
			end -- 4034
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4044
			if not result.success then -- 4044
				return ____awaiter_resolve(nil, result) -- 4044
			end -- 4044
			shared.unbuiltEdits = true -- 4051
			if shared.failedTestNeedsBuild == true then -- 4051
				shared.failedTestHasSourceEdit = true -- 4052
			end -- 4052
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4052
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4053
			end -- 4053
			shared.editedPathsSinceBuild = editedPaths -- 4054
			shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4055
			return ____awaiter_resolve(nil, { -- 4055
				success = true, -- 4057
				changed = true, -- 4058
				mode = "delete", -- 4059
				checkpointId = result.checkpointId, -- 4060
				checkpointSeq = result.checkpointSeq, -- 4061
				files = {{path = targetFile, op = "delete"}} -- 4062
			}) -- 4062
		end -- 4062
		if action.tool == "build" then -- 4062
			local buildPath = params.path or "" -- 4066
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4067
			shared.unbuiltEdits = false -- 4071
			shared.editsSinceBuild = 0 -- 4072
			shared.editedPathsSinceBuild = {} -- 4073
			shared.hasBuilt = true -- 4074
			local normalizedBuildPath = ____exports.normalizePolicyPath(buildPath) -- 4075
			local builtWholeProject = normalizedBuildPath == "" or normalizedBuildPath == "." -- 4076
			if result.success and builtWholeProject then -- 4076
				shared.freshProjectBuildPending = false -- 4077
			end -- 4077
			shared.apiSearchesSinceBuild = 0 -- 4078
			shared.buildRepairPending = false -- 4079
			if not result.success and result.messages ~= nil then -- 4079
				do -- 4079
					local i = 0 -- 4081
					while i < #result.messages do -- 4081
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4081
							shared.buildRepairPending = true -- 4083
							break -- 4084
						end -- 4084
						i = i + 1 -- 4081
					end -- 4081
				end -- 4081
			end -- 4081
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4081
				shared.failedTestNeedsBuild = false -- 4089
				shared.failedTestHasSourceEdit = false -- 4090
			end -- 4090
			return ____awaiter_resolve(nil, result) -- 4090
		end -- 4090
		if action.tool == "fetch_url" then -- 4090
			if __TS__ArrayIndexOf(shared.disabledAgentTools, "fetch_url") >= 0 then -- 4090
				return ____awaiter_resolve(nil, {success = false, state = "failed", message = "fetch_url is not enabled for this session"}) -- 4090
			end -- 4090
			local result = __TS__Await(Tools.fetchUrl({ -- 4098
				workDir = shared.workingDir, -- 4099
				url = type(params.url) == "string" and params.url or "", -- 4100
				target = type(params.target) == "string" and params.target or "", -- 4101
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4102
				onProgress = function(____, progress) -- 4103
					emitAgentEvent( -- 4104
						shared, -- 4104
						{ -- 4104
							type = "tool_progress", -- 4105
							sessionId = shared.sessionId, -- 4106
							taskId = shared.taskId, -- 4107
							step = action.step, -- 4108
							tool = action.tool, -- 4109
							result = __TS__ObjectAssign({success = false}, progress) -- 4110
						} -- 4110
					) -- 4110
				end -- 4103
			})) -- 4103
			return ____awaiter_resolve(nil, result) -- 4103
		end -- 4103
		if action.tool == "execute_command" then -- 4103
			if __TS__ArrayIndexOf(shared.disabledAgentTools, "execute_command") >= 0 then -- 4103
				return ____awaiter_resolve(nil, {success = false, message = "execute_command is not enabled for this session"}) -- 4103
			end -- 4103
			if shared.failedTestNeedsBuild == true then -- 4103
				return ____awaiter_resolve(nil, {success = false, message = "The deterministic test report failed. Read the authored source/test, make the smallest source fix, and build successfully before running another command. Do not probe generated Lua or instantiate compiled TypeScript classes from Lua."}) -- 4103
			end -- 4103
			local mode = type(params.mode) == "string" and params.mode or "" -- 4129
			local result = __TS__Await(Tools.executeCommand({ -- 4130
				workDir = shared.workingDir, -- 4131
				mode = mode, -- 4132
				code = type(params.code) == "string" and params.code or nil, -- 4133
				command = type(params.command) == "string" and params.command or nil, -- 4134
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4135
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4136
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4137
				onProgress = function(____, progress) -- 4138
					emitAgentEvent( -- 4139
						shared, -- 4139
						{ -- 4139
							type = "tool_progress", -- 4140
							sessionId = shared.sessionId, -- 4141
							taskId = shared.taskId, -- 4142
							step = action.step, -- 4143
							tool = action.tool, -- 4144
							result = __TS__ObjectAssign({success = false}, progress) -- 4145
						} -- 4145
					) -- 4145
				end -- 4138
			})) -- 4138
			if result.success and mode == "lua" then -- 4138
				local deterministicFailure = false -- 4153
				local deterministicPass = false -- 4154
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4155
				do -- 4155
					local i = 0 -- 4156
					while i < #outputLines and not deterministicFailure do -- 4156
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4157
						if line == "passed" then -- 4157
							deterministicPass = true -- 4158
						end -- 4158
						if line == "failed" then -- 4158
							deterministicFailure = true -- 4160
							break -- 4161
						end -- 4161
						local searchFrom = 0 -- 4163
						while searchFrom < #line do -- 4163
							local failedIndex = (string.find( -- 4165
								line, -- 4165
								"failed", -- 4165
								math.max(searchFrom + 1, 1), -- 4165
								true -- 4165
							) or 0) - 1 -- 4165
							if failedIndex < 0 then -- 4165
								break -- 4166
							end -- 4166
							local after = failedIndex + #"failed" -- 4167
							while after < #line do -- 4167
								local ch = __TS__StringSlice(line, after, after + 1) -- 4169
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4169
									break -- 4170
								end -- 4170
								after = after + 1 -- 4171
							end -- 4171
							local afterEnd = after -- 4173
							while afterEnd < #line do -- 4173
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4175
								if ch < "0" or ch > "9" then -- 4175
									break -- 4176
								end -- 4176
								afterEnd = afterEnd + 1 -- 4177
							end -- 4177
							local count -- 4179
							if afterEnd > after then -- 4179
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4181
							else -- 4181
								local before = failedIndex - 1 -- 4183
								while before >= 0 do -- 4183
									local ch = __TS__StringSlice(line, before, before + 1) -- 4185
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4185
										break -- 4186
									end -- 4186
									before = before - 1 -- 4187
								end -- 4187
								local beforeEnd = before + 1 -- 4189
								while before >= 0 do -- 4189
									local ch = __TS__StringSlice(line, before, before + 1) -- 4191
									if ch < "0" or ch > "9" then -- 4191
										break -- 4192
									end -- 4192
									before = before - 1 -- 4193
								end -- 4193
								if beforeEnd > before + 1 then -- 4193
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4195
								end -- 4195
							end -- 4195
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4195
								deterministicFailure = true -- 4198
								break -- 4199
							end -- 4199
							searchFrom = failedIndex + #"failed" -- 4201
						end -- 4201
						i = i + 1 -- 4156
					end -- 4156
				end -- 4156
				if deterministicFailure then -- 4156
					shared.failedTestNeedsBuild = true -- 4205
					shared.failedTestHasSourceEdit = false -- 4206
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4207
				elseif deterministicPass then -- 4207
					shared.deterministicTestFailureCount = 0 -- 4209
				end -- 4209
			end -- 4209
			return ____awaiter_resolve(nil, result) -- 4209
		end -- 4209
		if action.tool == "spawn_sub_agent" then -- 4209
			if not shared.spawnSubAgent then -- 4209
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4209
			end -- 4209
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4209
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4209
			end -- 4209
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4221
				params.filesHint, -- 4222
				function(____, item) return type(item) == "string" end -- 4222
			) or nil -- 4222
			local result = __TS__Await(shared.spawnSubAgent({ -- 4224
				parentSessionId = shared.sessionId, -- 4225
				projectRoot = shared.workingDir, -- 4226
				title = type(params.title) == "string" and params.title or "Sub", -- 4227
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4228
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4229
				filesHint = filesHint, -- 4230
				disabledAgentTools = shared.disabledAgentTools -- 4231
			})) -- 4231
			if not result.success then -- 4231
				return ____awaiter_resolve(nil, result) -- 4231
			end -- 4231
			shared.hasSpawnedSubAgentThisTask = true -- 4236
			return ____awaiter_resolve(nil, { -- 4236
				success = true, -- 4238
				sessionId = result.sessionId, -- 4239
				taskId = result.taskId, -- 4240
				title = result.title, -- 4241
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4242
			}) -- 4242
		end -- 4242
		if action.tool == "list_sub_agents" then -- 4242
			if shared.hasSpawnedSubAgentThisTask == true then -- 4242
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is unavailable after spawn_sub_agent in the current task. Finish this turn and let results arrive as asynchronous handoffs."}) -- 4242
			end -- 4242
			if not shared.listSubAgents then -- 4242
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4242
			end -- 4242
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4242
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4242
			end -- 4242
			local result = __TS__Await(shared.listSubAgents({ -- 4258
				sessionId = shared.sessionId, -- 4259
				projectRoot = shared.workingDir, -- 4260
				status = type(params.status) == "string" and params.status or nil, -- 4261
				limit = type(params.limit) == "number" and params.limit or nil, -- 4262
				offset = type(params.offset) == "number" and params.offset or nil, -- 4263
				query = type(params.query) == "string" and params.query or nil -- 4264
			})) -- 4264
			return ____awaiter_resolve(nil, result) -- 4264
		end -- 4264
		if action.tool == "edit_file" then -- 4264
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4269
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4272
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4273
			if __TS__StringTrim(path) == "" then -- 4273
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4273
			end -- 4273
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4275
			local isMemoryEdit = ____exports.isMainAgentMemoryPath(normalizedPath) -- 4276
			if not isMemoryEdit then -- 4276
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4278
				if preflightIssue ~= nil then -- 4278
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4280
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4281
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4281
				end -- 4281
			end -- 4281
			if not isMemoryEdit then -- 4281
				local editLimit = 3 -- 4288
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4289
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 and #editedPaths >= editLimit then -- 4289
					return ____awaiter_resolve(nil, {success = false, message = "Build the current authored changes now before editing a fourth source file. Multiple related replacements in the same source file count as one build-cycle edit."}) -- 4289
				end -- 4289
			end -- 4289
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4297
			local result = __TS__Await(actionNode:exec({ -- 4298
				path = path, -- 4299
				oldStr = oldStr, -- 4300
				newStr = newStr, -- 4301
				taskId = shared.taskId, -- 4302
				workDir = shared.workingDir -- 4303
			})) -- 4303
			if not isMemoryEdit and result.success == true and result.changed ~= false then -- 4303
				shared.unbuiltEdits = true -- 4306
				if shared.failedTestNeedsBuild == true then -- 4306
					shared.failedTestHasSourceEdit = true -- 4307
				end -- 4307
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4308
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4308
					editedPaths[#editedPaths + 1] = normalizedPath -- 4309
				end -- 4309
				shared.editedPathsSinceBuild = editedPaths -- 4310
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4311
			end -- 4311
			return ____awaiter_resolve(nil, result) -- 4311
		end -- 4311
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4311
	end) -- 4311
end -- 4311
function sanitizeToolActionResultForHistory(action, result) -- 4318
	if action.tool == "read_file" then -- 4318
		return sanitizeReadResultForHistory(action.tool, result) -- 4320
	end -- 4320
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4320
		return sanitizeSearchResultForHistory(action.tool, result) -- 4323
	end -- 4323
	if action.tool == "glob_files" then -- 4323
		return sanitizeListFilesResultForHistory(result) -- 4326
	end -- 4326
	if action.tool == "build" then -- 4326
		return sanitizeBuildResultForHistory(result) -- 4329
	end -- 4329
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4329
		if result.success ~= true then -- 4329
			return result -- 4332
		end -- 4332
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4332
			return result -- 4333
		end -- 4333
		if isArray(result.fileContext) then -- 4333
			return result -- 4334
		end -- 4334
		local contextLimits = { -- 4336
			fullContentChars = 12000, -- 4337
			previewChars = 4000, -- 4338
			diffChars = 8000, -- 4339
			totalChars = 24000, -- 4340
			maxFiles = 8 -- 4341
		} -- 4341
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4343
			if maxChars <= 0 then -- 4343
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4344
			end -- 4344
			if #sourceText <= maxChars then -- 4344
				return sourceText -- 4345
			end -- 4345
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4346
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4347
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4348
		end -- 4343
		local function countLines(sourceText) -- 4350
			if sourceText == "" then -- 4350
				return 0 -- 4351
			end -- 4351
			return #__TS__StringSplit(sourceText, "\n") -- 4352
		end -- 4350
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4354
			if beforeContent == afterContent then -- 4354
				return "" -- 4355
			end -- 4355
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4356
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4357
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4359
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4359
				firstChangedLine = firstChangedLine + 1 -- 4365
			end -- 4365
			local lastChangedBeforeLine = #beforeLines - 1 -- 4367
			local lastChangedAfterLine = #afterLines - 1 -- 4368
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4368
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4374
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4375
			end -- 4375
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4377
			local previewEndLine = math.max( -- 4378
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4379
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4380
			) -- 4380
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4382
			do -- 4382
				local lineIndex = previewStartLine -- 4383
				while lineIndex <= previewEndLine do -- 4383
					do -- 4383
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4384
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4385
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4386
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4387
						if not beforeChanged and not afterChanged then -- 4387
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4389
							if contextLine ~= nil then -- 4389
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4390
							end -- 4390
							goto __continue737 -- 4391
						end -- 4391
						if beforeChanged and beforeLine ~= nil then -- 4391
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4393
						end -- 4393
						if afterChanged and afterLine ~= nil then -- 4393
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4394
						end -- 4394
					end -- 4394
					::__continue737:: -- 4394
					lineIndex = lineIndex + 1 -- 4383
				end -- 4383
			end -- 4383
			return truncateContextSnippet( -- 4396
				table.concat(unifiedDiffLines, "\n"), -- 4396
				maxChars, -- 4396
				"diff" -- 4396
			) -- 4396
		end -- 4354
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4399
		if not checkpointDiff.success then -- 4399
			return result -- 4400
		end -- 4400
		local remainingContextBudget = contextLimits.totalChars -- 4401
		local fileContextItems = {} -- 4402
		local changedFiles = checkpointDiff.files -- 4403
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4404
		do -- 4404
			local fileIndex = 0 -- 4405
			while fileIndex < maxContextFiles do -- 4405
				if remainingContextBudget <= 0 then -- 4405
					break -- 4406
				end -- 4406
				local changedFile = changedFiles[fileIndex + 1] -- 4407
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4408
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4409
				local contextItem = { -- 4410
					path = changedFile.path, -- 4411
					op = changedFile.op, -- 4412
					checkpointId = result.checkpointId, -- 4413
					checkpointSeq = result.checkpointSeq, -- 4414
					beforeExists = changedFile.beforeExists, -- 4415
					afterExists = changedFile.afterExists, -- 4416
					beforeBytes = #beforeContent, -- 4417
					afterBytes = #afterContent, -- 4418
					diffPreview = "", -- 4419
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4420
					contentTruncated = false, -- 4421
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4422
				} -- 4422
				if changedFile.afterExists then -- 4422
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4422
						contextItem.afterContent = afterContent -- 4426
						remainingContextBudget = remainingContextBudget - #afterContent -- 4427
					else -- 4427
						contextItem.afterContentPreview = truncateContextSnippet( -- 4429
							afterContent, -- 4430
							math.min( -- 4431
								contextLimits.previewChars, -- 4431
								math.max(400, remainingContextBudget) -- 4431
							), -- 4431
							"afterContent" -- 4432
						) -- 4432
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4434
						contextItem.contentTruncated = true -- 4435
					end -- 4435
				end -- 4435
				local diffPreview = buildUnifiedDiffPreview( -- 4438
					changedFile.path, -- 4439
					beforeContent, -- 4440
					afterContent, -- 4441
					math.min( -- 4442
						contextLimits.diffChars, -- 4442
						math.max(400, remainingContextBudget) -- 4442
					) -- 4442
				) -- 4442
				contextItem.diffPreview = diffPreview -- 4444
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4445
				if not changedFile.afterExists and beforeContent ~= "" then -- 4445
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4447
						beforeContent, -- 4448
						math.min( -- 4449
							contextLimits.previewChars, -- 4449
							math.max(400, remainingContextBudget) -- 4449
						), -- 4449
						"beforeContent" -- 4450
					) -- 4450
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4452
					if #beforeContent > contextLimits.previewChars then -- 4452
						contextItem.contentTruncated = true -- 4453
					end -- 4453
				end -- 4453
				fileContextItems[#fileContextItems + 1] = contextItem -- 4455
				fileIndex = fileIndex + 1 -- 4405
			end -- 4405
		end -- 4405
		if #fileContextItems == 0 then -- 4405
			return result -- 4457
		end -- 4457
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4458
	end -- 4458
	return result -- 4465
end -- 4465
function emitAgentTaskFinishEvent(shared, success, message) -- 4650
	local completion = shared.completion or ____exports.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4651
	local result = success and ({ -- 4655
		success = true, -- 4657
		taskId = shared.taskId, -- 4658
		message = message, -- 4659
		steps = shared.step, -- 4660
		completion = completion -- 4661
	}) or ({ -- 4661
		success = false, -- 4664
		taskId = shared.taskId, -- 4665
		message = message, -- 4666
		steps = shared.step, -- 4667
		completion = completion -- 4668
	}) -- 4668
	emitAgentEvent(shared, { -- 4670
		type = "task_finished", -- 4671
		sessionId = shared.sessionId, -- 4672
		taskId = shared.taskId, -- 4673
		success = result.success, -- 4674
		message = result.message, -- 4675
		steps = result.steps, -- 4676
		completion = result.completion -- 4677
	}) -- 4677
	return result -- 4679
end -- 4679
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 133
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 275
HISTORY_READ_FILE_MAX_LINES = 300 -- 276
READ_FILE_DEFAULT_LIMIT = 300 -- 277
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 278
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 279
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 280
HISTORY_BUILD_MAX_MESSAGES = 50 -- 281
HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 282
SEARCH_DORA_API_LIMIT_MAX = 20 -- 283
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 284
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 285
SEARCH_PREVIEW_CONTEXT = 80 -- 286
local function buildLLMOptions(llmConfig, overrides) -- 288
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 289
	if llmConfig.reasoningEffort then -- 289
		options.reasoning_effort = llmConfig.reasoningEffort -- 294
	end -- 294
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 296
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 296
		__TS__Delete(merged, "reasoning_effort") -- 301
	else -- 301
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 303
	end -- 303
	__TS__Delete(merged, "tool_choice") -- 308
	return merged -- 309
end -- 288
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 432
	local messagesTokens = 0 -- 439
	do -- 439
		local i = 0 -- 440
		while i < #messages do -- 440
			local message = messages[i + 1] -- 441
			messagesTokens = messagesTokens + 8 -- 442
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 443
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 444
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 445
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 446
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 447
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 448
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 449
			i = i + 1 -- 440
		end -- 440
	end -- 440
	local toolDefinitionsTokens = 0 -- 452
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 452
		local toolsText = safeJsonEncode(options.tools) -- 454
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 455
	end -- 455
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 458
	__TS__Delete(optionsWithoutTools, "tools") -- 459
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 460
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 461
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 462
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 463
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 468
		1024, -- 470
		math.floor(contextWindow * 0.2) -- 470
	) -- 470
	local structuralOverhead = math.max(256, #messages * 16) -- 471
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 473
	local maxTokens = contextWindow -- 474
	emitAgentEvent( -- 475
		shared, -- 475
		{ -- 475
			type = "metrics_updated", -- 476
			sessionId = shared.sessionId, -- 477
			taskId = shared.taskId, -- 478
			step = step, -- 479
			metrics = {context = { -- 480
				usedTokens = usedTokens, -- 482
				maxTokens = maxTokens, -- 483
				ratio = math.max( -- 484
					0, -- 484
					math.min(1, usedTokens / maxTokens) -- 484
				), -- 484
				messagesTokens = messagesTokens, -- 485
				optionsTokens = optionsTokens, -- 486
				toolDefinitionsTokens = toolDefinitionsTokens, -- 487
				reservedOutputTokens = reservedOutputTokens, -- 488
				structuralOverhead = structuralOverhead, -- 489
				contextWindow = contextWindow, -- 490
				source = "llm_input_estimate", -- 491
				updatedAt = os.time(), -- 492
				phase = phase, -- 493
				step = step -- 494
			}} -- 494
		} -- 494
	) -- 494
end -- 432
local function recordLLMTokenUsage(shared, step, phase, usage) -- 500
	if not usage then -- 500
		return -- 501
	end -- 501
	local current = shared.tokenUsage -- 502
	local cachedReported = usage.cachedInputTokens ~= nil -- 503
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 504
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 505
	local next = { -- 506
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 507
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 508
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 509
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 510
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 513
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 516
		requestCount = (current and current.requestCount or 0) + 1, -- 519
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 520
		model = shared.llmConfig.model, -- 523
		phase = phase, -- 524
		step = step, -- 525
		updatedAt = os.time() -- 526
	} -- 526
	shared.tokenUsage = next -- 528
	emitAgentEvent(shared, { -- 529
		type = "metrics_updated", -- 530
		sessionId = shared.sessionId, -- 531
		taskId = shared.taskId, -- 532
		step = step, -- 533
		metrics = {usage = next} -- 534
	}) -- 534
end -- 500
local function emitAgentStartEvent(shared, action) -- 538
	emitAgentEvent(shared, { -- 539
		type = "tool_started", -- 540
		sessionId = shared.sessionId, -- 541
		taskId = shared.taskId, -- 542
		step = action.step, -- 543
		tool = action.tool -- 544
	}) -- 544
end -- 538
local function emitAgentFinishEvent(shared, action) -- 548
	emitAgentEvent(shared, { -- 549
		type = "tool_finished", -- 550
		sessionId = shared.sessionId, -- 551
		taskId = shared.taskId, -- 552
		step = action.step, -- 553
		tool = action.tool, -- 554
		result = action.result or ({}) -- 555
	}) -- 555
end -- 548
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 559
	emitAgentEvent(shared, { -- 560
		type = "assistant_message_updated", -- 561
		sessionId = shared.sessionId, -- 562
		taskId = shared.taskId, -- 563
		step = shared.step + 1, -- 564
		content = content, -- 565
		reasoningContent = reasoningContent -- 566
	}) -- 566
end -- 559
local function getMemoryCompressionStartReason(shared) -- 570
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 571
end -- 570
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 576
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 577
end -- 576
local function getMemoryCompressionFailureReason(shared, ____error) -- 582
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 583
end -- 582
local function summarizeHistoryEntryPreview(text, maxChars) -- 588
	if maxChars == nil then -- 588
		maxChars = 180 -- 588
	end -- 588
	local trimmed = __TS__StringTrim(text) -- 589
	if trimmed == "" then -- 589
		return "" -- 590
	end -- 590
	return truncateText(trimmed, maxChars) -- 591
end -- 588
local function getMaxStepsReachedReason(shared) -- 599
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 600
end -- 599
local function getFailureSummaryFallback(shared, ____error) -- 605
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 606
end -- 605
local function finalizeAgentFailure(shared, ____error) -- 611
	if shared.stopToken.stopped then -- 611
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 613
		return emitAgentTaskFinishEvent( -- 614
			shared, -- 614
			false, -- 614
			getCancelledReason(shared) -- 614
		) -- 614
	end -- 614
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 616
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 617
end -- 611
local function getPromptCommand(prompt) -- 620
	local trimmed = __TS__StringTrim(prompt) -- 621
	if trimmed == "/compact" then -- 621
		return "compact" -- 622
	end -- 622
	if trimmed == "/clear" then -- 622
		return "clear" -- 623
	end -- 623
	return nil -- 624
end -- 620
function ____exports.truncateAgentUserPrompt(prompt) -- 627
	if not prompt then -- 627
		return "" -- 628
	end -- 628
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 628
		return prompt -- 629
	end -- 629
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 630
	if offset == nil then -- 630
		return prompt -- 631
	end -- 631
	return string.sub(prompt, 1, offset - 1) -- 632
end -- 627
local function canWriteStepLLMDebug(shared, stepId) -- 635
	if stepId == nil then -- 635
		stepId = shared.step + 1 -- 635
	end -- 635
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 636
end -- 635
local function ensureDirRecursive(dir) -- 643
	if not dir then -- 643
		return false -- 644
	end -- 644
	if Content:exist(dir) then -- 644
		return Content:isdir(dir) -- 645
	end -- 645
	local parent = Path:getPath(dir) -- 646
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 646
		return false -- 648
	end -- 648
	return Content:mkdir(dir) -- 650
end -- 643
local function encodeDebugJSON(value) -- 653
	local text, err = safeJsonEncode(value) -- 654
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 655
end -- 653
local FRESH_PROJECT_CODE_GLOBS = { -- 674
	"**/*.ts", -- 675
	"**/*.tsx", -- 676
	"**/*.lua", -- 677
	"**/*.yue", -- 678
	"**/*.tl", -- 679
	"**/*.yarn", -- 680
	"**/*.xml", -- 681
	"!**/*.d.ts" -- 682
} -- 682
local function inspectFreshProject(workDir) -- 685
	local result = Tools.listFiles({workDir = workDir, path = "", globs = FRESH_PROJECT_CODE_GLOBS, maxEntries = 2}) -- 686
	if not result.success then -- 686
		return {fresh = false} -- 692
	end -- 692
	local totalEntries = result.totalEntries or #result.files -- 693
	if totalEntries > 1 then -- 693
		return {fresh = false} -- 694
	end -- 694
	if totalEntries == 0 then -- 694
		return {fresh = true} -- 695
	end -- 695
	if #result.files ~= 1 then -- 695
		return {fresh = false} -- 696
	end -- 696
	local path = result.files[1] -- 697
	local loaded = Tools.readFileRaw(workDir, path) -- 698
	if not loaded.success or loaded.content == nil then -- 698
		return {fresh = false} -- 699
	end -- 699
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 700
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 703
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 704
end -- 685
local function getStepLLMDebugDir(shared) -- 707
	return Path( -- 708
		shared.workingDir, -- 709
		".agent", -- 710
		tostring(shared.sessionId), -- 711
		tostring(shared.taskId) -- 712
	) -- 712
end -- 707
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 716
	return Path( -- 717
		getStepLLMDebugDir(shared), -- 717
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 717
	) -- 717
end -- 716
local function getLatestStepLLMDebugSeq(shared, stepId) -- 720
	if not canWriteStepLLMDebug(shared, stepId) then -- 720
		return 0 -- 721
	end -- 721
	local dir = getStepLLMDebugDir(shared) -- 722
	if not Content:exist(dir) or not Content:isdir(dir) then -- 722
		return 0 -- 723
	end -- 723
	local latest = 0 -- 724
	for ____, file in ipairs(Content:getFiles(dir)) do -- 725
		do -- 725
			local name = Path:getFilename(file) -- 726
			local seqText = string.match( -- 727
				name, -- 727
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 727
			) -- 727
			if seqText ~= nil then -- 727
				latest = math.max( -- 729
					latest, -- 729
					tonumber(seqText) -- 729
				) -- 729
				goto __continue59 -- 730
			end -- 730
			local legacyMatch = string.match( -- 732
				name, -- 732
				("^" .. tostring(stepId)) .. "_in%.md$" -- 732
			) -- 732
			if legacyMatch ~= nil then -- 732
				latest = math.max(latest, 1) -- 734
			end -- 734
		end -- 734
		::__continue59:: -- 734
	end -- 734
	return latest -- 737
end -- 720
local function writeStepLLMDebugFile(path, content) -- 740
	if not Content:save(path, content) then -- 740
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 742
		return false -- 743
	end -- 743
	return true -- 745
end -- 740
local function createStepLLMDebugPair(shared, stepId, inContent) -- 748
	if not canWriteStepLLMDebug(shared, stepId) then -- 748
		return 0 -- 749
	end -- 749
	local dir = getStepLLMDebugDir(shared) -- 750
	if not ensureDirRecursive(dir) then -- 750
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 752
		return 0 -- 753
	end -- 753
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 755
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 756
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 757
	if not writeStepLLMDebugFile(inPath, inContent) then -- 757
		return 0 -- 759
	end -- 759
	writeStepLLMDebugFile(outPath, "") -- 761
	return seq -- 762
end -- 748
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 765
	if not canWriteStepLLMDebug(shared, stepId) then -- 765
		return -- 766
	end -- 766
	local dir = getStepLLMDebugDir(shared) -- 767
	if not ensureDirRecursive(dir) then -- 767
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 769
		return -- 770
	end -- 770
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 772
	if latestSeq <= 0 then -- 772
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 774
		writeStepLLMDebugFile(outPath, content) -- 775
		return -- 776
	end -- 776
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 778
	writeStepLLMDebugFile(outPath, content) -- 779
end -- 765
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 782
	if not canWriteStepLLMDebug(shared, stepId) then -- 782
		return -- 783
	end -- 783
	local sections = { -- 784
		"# LLM Input", -- 785
		"session_id: " .. tostring(shared.sessionId), -- 786
		"task_id: " .. tostring(shared.taskId), -- 787
		"step_id: " .. tostring(stepId), -- 788
		"phase: " .. phase, -- 789
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 790
		"## Options", -- 791
		"```json", -- 792
		encodeDebugJSON(options), -- 793
		"```" -- 794
	} -- 794
	local firstMessage = #messages > 0 and messages[1] or nil -- 796
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 796
		sections[#sections + 1] = "# System Prompt" -- 798
		sections[#sections + 1] = firstMessage.content -- 799
	end -- 799
	do -- 799
		local i = 0 -- 801
		while i < #messages do -- 801
			local message = messages[i + 1] -- 802
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 803
			sections[#sections + 1] = encodeDebugJSON(message) -- 804
			i = i + 1 -- 801
		end -- 801
	end -- 801
	createStepLLMDebugPair( -- 806
		shared, -- 806
		stepId, -- 806
		table.concat(sections, "\n") -- 806
	) -- 806
end -- 782
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 809
	if not canWriteStepLLMDebug(shared, stepId) then -- 809
		return -- 810
	end -- 810
	local ____array_24 = __TS__SparseArrayNew( -- 810
		"# LLM Output", -- 812
		"session_id: " .. tostring(shared.sessionId), -- 813
		"task_id: " .. tostring(shared.taskId), -- 814
		"step_id: " .. tostring(stepId), -- 815
		"phase: " .. phase, -- 816
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 817
		table.unpack(meta and ({ -- 818
			"## Meta", -- 818
			"```json", -- 818
			encodeDebugJSON(meta), -- 818
			"```" -- 818
		}) or ({})) -- 818
	) -- 818
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 818
	local sections = {__TS__SparseArraySpread(____array_24)} -- 811
	updateLatestStepLLMDebugOutput( -- 822
		shared, -- 822
		stepId, -- 822
		table.concat(sections, "\n") -- 822
	) -- 822
end -- 809
local function toJson(value, emptyAsArray) -- 825
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 826
	if text ~= nil then -- 826
		return text -- 827
	end -- 827
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 828
end -- 825
local function summarizeEditTextParamForHistory(value, key) -- 878
	if type(value) ~= "string" then -- 878
		return nil -- 879
	end -- 879
	local text = value -- 880
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 881
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 882
end -- 878
local function sanitizeActionParamsForHistory(tool, params) -- 998
	if tool ~= "edit_file" then -- 998
		return params -- 999
	end -- 999
	local clone = {} -- 1000
	for key in pairs(params) do -- 1001
		if key == "old_str" then -- 1001
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1003
		elseif key == "new_str" then -- 1003
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1005
		else -- 1005
			clone[key] = params[key] -- 1007
		end -- 1007
	end -- 1007
	return clone -- 1010
end -- 998
function ____exports.getDecisionDisabledAgentTools(shared) -- 1013
	local disabled = __TS__ArraySlice(shared.disabledAgentTools) -- 1014
	if shared.freshProjectBuildPending == true then -- 1014
		local freshProjectDisabled = { -- 1020
			"read_file", -- 1021
			"glob_files", -- 1022
			"grep_files", -- 1023
			"search_dora_api", -- 1024
			"execute_command" -- 1025
		} -- 1025
		do -- 1025
			local i = 0 -- 1027
			while i < #freshProjectDisabled do -- 1027
				if __TS__ArrayIndexOf(disabled, freshProjectDisabled[i + 1]) < 0 then -- 1027
					disabled[#disabled + 1] = freshProjectDisabled[i + 1] -- 1028
				end -- 1028
				i = i + 1 -- 1027
			end -- 1027
		end -- 1027
	end -- 1027
	if ((shared.apiSearchesSinceBuild or 0) >= 1 or shared.unbuiltEdits == true) and __TS__ArrayIndexOf(disabled, "search_dora_api") < 0 then -- 1027
		disabled[#disabled + 1] = "search_dora_api" -- 1041
	end -- 1041
	if shared.buildRepairPending == true then -- 1041
		local repairDisabled = {"grep_files", "glob_files", "search_dora_api", "execute_command"} -- 1048
		do -- 1048
			local i = 0 -- 1054
			while i < #repairDisabled do -- 1054
				if __TS__ArrayIndexOf(disabled, repairDisabled[i + 1]) < 0 then -- 1054
					disabled[#disabled + 1] = repairDisabled[i + 1] -- 1055
				end -- 1055
				i = i + 1 -- 1054
			end -- 1054
		end -- 1054
	end -- 1054
	if shared.hasSpawnedSubAgentThisTask == true and __TS__ArrayIndexOf(disabled, "list_sub_agents") < 0 then -- 1054
		disabled[#disabled + 1] = "list_sub_agents" -- 1062
	end -- 1062
	if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit then -- 1062
		local foregroundDisabled = AgentToolRegistry.getAllowedToolsForRole(shared.role) -- 1065
		do -- 1065
			local i = 0 -- 1066
			while i < #foregroundDisabled do -- 1066
				do -- 1066
					local tool = foregroundDisabled[i + 1] -- 1067
					if tool == "spawn_sub_agent" or tool == "finish" then -- 1067
						goto __continue148 -- 1068
					end -- 1068
					if __TS__ArrayIndexOf(disabled, tool) < 0 then -- 1068
						disabled[#disabled + 1] = tool -- 1069
					end -- 1069
				end -- 1069
				::__continue148:: -- 1069
				i = i + 1 -- 1066
			end -- 1066
		end -- 1066
	end -- 1066
	if shared.unbuiltEdits == true and (shared.editsSinceBuild or 0) >= 3 then -- 1066
		local changesMustBuild = {"edit_file", "delete_file"} -- 1076
		do -- 1076
			local i = 0 -- 1077
			while i < #changesMustBuild do -- 1077
				if __TS__ArrayIndexOf(disabled, changesMustBuild[i + 1]) < 0 then -- 1077
					disabled[#disabled + 1] = changesMustBuild[i + 1] -- 1078
				end -- 1078
				i = i + 1 -- 1077
			end -- 1077
		end -- 1077
	end -- 1077
	return disabled -- 1081
end -- 1013
local function getDecisionToolSchemaText(shared) -- 1115
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX, {disabledAgentTools = shared.disabledAgentTools})) -- 1116
	return toolsText or "" -- 1119
end -- 1115
local function isToolAllowedForRole(shared, tool) -- 1122
	return __TS__ArrayIndexOf( -- 1123
		AgentToolRegistry.getAllowedToolsForRole( -- 1123
			shared.role, -- 1123
			{disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared)} -- 1123
		), -- 1123
		tool -- 1125
	) >= 0 -- 1125
end -- 1122
local function clearPreExecutedResults(shared) -- 1128
	shared.preExecutedResults = nil -- 1129
end -- 1128
local function startPreExecutedToolAction(shared, action) -- 1132
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1132
		local ____hasReturned, ____returnValue -- 1132
		local ____try = __TS__AsyncAwaiter(function() -- 1132
			____hasReturned = true -- 1134
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1134
			return -- 1134
		end) -- 1134
		____try = ____try.catch( -- 1134
			____try, -- 1134
			function(____, err) -- 1134
				return __TS__AsyncAwaiter(function() -- 1134
					local message = tostring(err) -- 1136
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1137
					____hasReturned = true -- 1138
					____returnValue = {success = false, message = message} -- 1138
					return -- 1138
				end) -- 1138
			end -- 1138
		) -- 1138
		__TS__Await(____try) -- 1133
		if ____hasReturned then -- 1133
			return ____awaiter_resolve(nil, ____returnValue) -- 1133
		end -- 1133
	end) -- 1133
end -- 1132
local function createPreExecutedToolResult(shared, action) -- 1142
	local cloneParamValue -- 1143
	cloneParamValue = function(value) -- 1143
		if value == nil then -- 1143
			return value -- 1144
		end -- 1144
		if isArray(value) then -- 1144
			return __TS__ArrayMap( -- 1146
				value, -- 1146
				function(____, item) return cloneParamValue(item) end -- 1146
			) -- 1146
		end -- 1146
		if type(value) == "table" then -- 1146
			local clone = {} -- 1149
			for key in pairs(value) do -- 1150
				clone[key] = cloneParamValue(value[key]) -- 1151
			end -- 1151
			return clone -- 1153
		end -- 1153
		return value -- 1155
	end -- 1143
	local params = cloneParamValue(action.params) -- 1157
	local areParamValuesEqual -- 1158
	areParamValuesEqual = function(left, right) -- 1158
		if left == right then -- 1158
			return true -- 1159
		end -- 1159
		if left == nil or right == nil then -- 1159
			return false -- 1160
		end -- 1160
		if isArray(left) or isArray(right) then -- 1160
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1160
				return false -- 1162
			end -- 1162
			do -- 1162
				local i = 0 -- 1163
				while i < #left do -- 1163
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1163
						return false -- 1164
					end -- 1164
					i = i + 1 -- 1163
				end -- 1163
			end -- 1163
			return true -- 1166
		end -- 1166
		if type(left) == "table" and type(right) == "table" then -- 1166
			local leftCount = 0 -- 1169
			for key in pairs(left) do -- 1170
				leftCount = leftCount + 1 -- 1171
				if not areParamValuesEqual(left[key], right[key]) then -- 1171
					return false -- 1176
				end -- 1176
			end -- 1176
			local rightCount = 0 -- 1179
			for key in pairs(right) do -- 1180
				rightCount = rightCount + 1 -- 1181
			end -- 1181
			return leftCount == rightCount -- 1183
		end -- 1183
		return false -- 1185
	end -- 1158
	return { -- 1187
		action = action, -- 1188
		matches = function(self, nextAction) -- 1189
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1190
		end, -- 1189
		promise = startPreExecutedToolAction(shared, action) -- 1192
	} -- 1192
end -- 1142
local function executeToolActionWithPreExecution(shared, action) -- 1196
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1196
		local ____opt_27 = shared.preExecutedResults -- 1196
		local preResult = ____opt_27 and ____opt_27:get(action.toolCallId) -- 1197
		if preResult then -- 1197
			local ____opt_29 = shared.preExecutedResults -- 1197
			if ____opt_29 ~= nil then -- 1197
				____opt_29:delete(action.toolCallId) -- 1199
			end -- 1199
			if preResult:matches(action) then -- 1199
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1201
				return ____awaiter_resolve( -- 1201
					nil, -- 1201
					__TS__Await(preResult.promise) -- 1202
				) -- 1202
			end -- 1202
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1204
		end -- 1204
		return ____awaiter_resolve( -- 1204
			nil, -- 1204
			executeToolAction(shared, action) -- 1206
		) -- 1206
	end) -- 1206
end -- 1196
local function maybeCompressHistory(shared, forceAtTurnBoundary) -- 1209
	if forceAtTurnBoundary == nil then -- 1209
		forceAtTurnBoundary = false -- 1209
	end -- 1209
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1209
		local ____shared_31 = shared -- 1210
		local memory = ____shared_31.memory -- 1210
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1211
		local changed = false -- 1212
		do -- 1212
			local round = 0 -- 1213
			while round < maxRounds do -- 1213
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1214
				local activeMessages = getActiveConversationMessages(shared) -- 1215
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1218
				local thresholdReached = memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) -- 1221
				local activeTokens = 0 -- 1226
				if forceAtTurnBoundary and shared.role == "main" then -- 1226
					do -- 1226
						local i = 0 -- 1228
						while i < #activeMessages do -- 1228
							local message = activeMessages[i + 1] -- 1229
							activeTokens = activeTokens + 8 -- 1230
							activeTokens = activeTokens + estimateTextTokens(message.role or "") -- 1231
							activeTokens = activeTokens + estimateTextTokens(message.content or "") -- 1232
							activeTokens = activeTokens + estimateTextTokens(message.name or "") -- 1233
							activeTokens = activeTokens + estimateTextTokens(message.tool_call_id or "") -- 1234
							activeTokens = activeTokens + estimateTextTokens(message.reasoning_content or "") -- 1235
							local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 1236
							activeTokens = activeTokens + estimateTextTokens(toolCallsText or "") -- 1237
							i = i + 1 -- 1228
						end -- 1228
					end -- 1228
				end -- 1228
				local activeRealMessages = getActiveRealMessageCount(shared) -- 1240
				local turnBoundaryReached = forceAtTurnBoundary and shared.role == "main" and (activeTokens >= 72000 or activeRealMessages >= 64 and activeTokens >= 48000) -- 1241
				if not thresholdReached and not turnBoundaryReached then -- 1241
					if changed then -- 1241
						persistHistoryState(shared) -- 1246
					end -- 1246
					return ____awaiter_resolve(nil) -- 1246
				end -- 1246
				local compressionRound = round + 1 -- 1250
				shared.step = shared.step + 1 -- 1251
				local stepId = shared.step -- 1252
				local pendingMessages = #activeMessages -- 1253
				emitAgentEvent( -- 1254
					shared, -- 1254
					{ -- 1254
						type = "memory_compression_started", -- 1255
						sessionId = shared.sessionId, -- 1256
						taskId = shared.taskId, -- 1257
						step = stepId, -- 1258
						tool = "compress_memory", -- 1259
						reason = getMemoryCompressionStartReason(shared), -- 1260
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1261
					} -- 1261
				) -- 1261
				local result = __TS__Await(memory.compressor:compress( -- 1267
					activeMessages, -- 1268
					shared.llmOptions, -- 1269
					shared.llmMaxTry, -- 1270
					shared.decisionMode, -- 1271
					{ -- 1272
						onInput = function(____, phase, messages, options) -- 1273
							saveStepLLMDebugInput( -- 1274
								shared, -- 1274
								stepId, -- 1274
								phase, -- 1274
								messages, -- 1274
								options -- 1274
							) -- 1274
						end, -- 1273
						onOutput = function(____, phase, text, meta) -- 1276
							saveStepLLMDebugOutput( -- 1277
								shared, -- 1277
								stepId, -- 1277
								phase, -- 1277
								text, -- 1277
								meta -- 1277
							) -- 1277
						end, -- 1276
						onUsage = function(____, phase, usage) -- 1279
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1280
						end -- 1279
					}, -- 1279
					"default", -- 1283
					systemPrompt, -- 1284
					toolDefinitions -- 1285
				)) -- 1285
				if not (result and result.success and result.compressedCount > 0) then -- 1285
					emitAgentEvent( -- 1288
						shared, -- 1288
						{ -- 1288
							type = "memory_compression_finished", -- 1289
							sessionId = shared.sessionId, -- 1290
							taskId = shared.taskId, -- 1291
							step = stepId, -- 1292
							tool = "compress_memory", -- 1293
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1294
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1298
						} -- 1298
					) -- 1298
					if changed then -- 1298
						persistHistoryState(shared) -- 1306
					end -- 1306
					return ____awaiter_resolve(nil) -- 1306
				end -- 1306
				local effectiveCompressedCount = math.max( -- 1310
					0, -- 1311
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1312
				) -- 1312
				if effectiveCompressedCount <= 0 then -- 1312
					if changed then -- 1312
						persistHistoryState(shared) -- 1316
					end -- 1316
					return ____awaiter_resolve(nil) -- 1316
				end -- 1316
				emitAgentEvent( -- 1320
					shared, -- 1320
					{ -- 1320
						type = "memory_compression_finished", -- 1321
						sessionId = shared.sessionId, -- 1322
						taskId = shared.taskId, -- 1323
						step = stepId, -- 1324
						tool = "compress_memory", -- 1325
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1326
						result = { -- 1327
							success = true, -- 1328
							round = compressionRound, -- 1329
							compressedCount = effectiveCompressedCount, -- 1330
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1331
						} -- 1331
					} -- 1331
				) -- 1331
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1334
				changed = true -- 1335
				Log( -- 1336
					"Info", -- 1336
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1336
				) -- 1336
				round = round + 1 -- 1213
			end -- 1213
		end -- 1213
		if changed then -- 1213
			persistHistoryState(shared) -- 1339
		end -- 1339
	end) -- 1339
end -- 1209
local function compactAllHistory(shared) -- 1343
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1343
		local ____shared_38 = shared -- 1344
		local memory = ____shared_38.memory -- 1344
		local rounds = 0 -- 1345
		local totalCompressed = 0 -- 1346
		while getActiveRealMessageCount(shared) > 0 do -- 1346
			if shared.stopToken.stopped then -- 1346
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1349
				return ____awaiter_resolve( -- 1349
					nil, -- 1349
					emitAgentTaskFinishEvent( -- 1350
						shared, -- 1350
						false, -- 1350
						getCancelledReason(shared) -- 1350
					) -- 1350
				) -- 1350
			end -- 1350
			rounds = rounds + 1 -- 1352
			shared.step = shared.step + 1 -- 1353
			local stepId = shared.step -- 1354
			local activeMessages = getActiveConversationMessages(shared) -- 1355
			local pendingMessages = #activeMessages -- 1356
			emitAgentEvent( -- 1357
				shared, -- 1357
				{ -- 1357
					type = "memory_compression_started", -- 1358
					sessionId = shared.sessionId, -- 1359
					taskId = shared.taskId, -- 1360
					step = stepId, -- 1361
					tool = "compress_memory", -- 1362
					reason = getMemoryCompressionStartReason(shared), -- 1363
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1364
				} -- 1364
			) -- 1364
			local result = __TS__Await(memory.compressor:compress( -- 1371
				activeMessages, -- 1372
				shared.llmOptions, -- 1373
				shared.llmMaxTry, -- 1374
				shared.decisionMode, -- 1375
				{ -- 1376
					onInput = function(____, phase, messages, options) -- 1377
						saveStepLLMDebugInput( -- 1378
							shared, -- 1378
							stepId, -- 1378
							phase, -- 1378
							messages, -- 1378
							options -- 1378
						) -- 1378
					end, -- 1377
					onOutput = function(____, phase, text, meta) -- 1380
						saveStepLLMDebugOutput( -- 1381
							shared, -- 1381
							stepId, -- 1381
							phase, -- 1381
							text, -- 1381
							meta -- 1381
						) -- 1381
					end, -- 1380
					onUsage = function(____, phase, usage) -- 1383
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1384
					end -- 1383
				}, -- 1383
				"budget_max" -- 1387
			)) -- 1387
			if not (result and result.success and result.compressedCount > 0) then -- 1387
				emitAgentEvent( -- 1390
					shared, -- 1390
					{ -- 1390
						type = "memory_compression_finished", -- 1391
						sessionId = shared.sessionId, -- 1392
						taskId = shared.taskId, -- 1393
						step = stepId, -- 1394
						tool = "compress_memory", -- 1395
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1396
						result = { -- 1400
							success = false, -- 1401
							rounds = rounds, -- 1402
							error = result and result.error or "compression returned no changes", -- 1403
							compressedCount = result and result.compressedCount or 0, -- 1404
							fullCompaction = true -- 1405
						} -- 1405
					} -- 1405
				) -- 1405
				return ____awaiter_resolve( -- 1405
					nil, -- 1405
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1408
				) -- 1408
			end -- 1408
			local effectiveCompressedCount = math.max( -- 1413
				0, -- 1414
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1415
			) -- 1415
			if effectiveCompressedCount <= 0 then -- 1415
				return ____awaiter_resolve( -- 1415
					nil, -- 1415
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1418
				) -- 1418
			end -- 1418
			emitAgentEvent( -- 1425
				shared, -- 1425
				{ -- 1425
					type = "memory_compression_finished", -- 1426
					sessionId = shared.sessionId, -- 1427
					taskId = shared.taskId, -- 1428
					step = stepId, -- 1429
					tool = "compress_memory", -- 1430
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1431
					result = { -- 1432
						success = true, -- 1433
						round = rounds, -- 1434
						compressedCount = effectiveCompressedCount, -- 1435
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1436
						fullCompaction = true -- 1437
					} -- 1437
				} -- 1437
			) -- 1437
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1440
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1441
			persistHistoryState(shared) -- 1442
			Log( -- 1443
				"Info", -- 1443
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1443
			) -- 1443
		end -- 1443
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1445
		return ____awaiter_resolve( -- 1445
			nil, -- 1445
			emitAgentTaskFinishEvent( -- 1446
				shared, -- 1447
				true, -- 1448
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1449
			) -- 1449
		) -- 1449
	end) -- 1449
end -- 1343
local function clearSessionHistory(shared) -- 1455
	shared.messages = {} -- 1456
	shared.lastConsolidatedIndex = 0 -- 1457
	shared.carryMessageIndex = nil -- 1458
	persistHistoryState(shared) -- 1459
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1460
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1461
end -- 1455
COMPLETION_TEXT_MAX_CHARS = 800 -- 1483
COMPLETION_LIST_MAX_ITEMS = 12 -- 1484
COMPLETION_EVIDENCE_MAX_ITEMS = 8 -- 1485
local function appendConversationMessage(shared, message) -- 1677
	local ____shared_messages_47 = shared.messages -- 1677
	____shared_messages_47[#____shared_messages_47 + 1] = __TS__ObjectAssign( -- 1678
		{}, -- 1678
		message, -- 1679
		{ -- 1678
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1680
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1681
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1682
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1683
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1684
		} -- 1684
	) -- 1684
end -- 1677
local function appendToolResultMessage(shared, action) -- 1693
	appendConversationMessage( -- 1694
		shared, -- 1694
		{ -- 1694
			role = "tool", -- 1695
			tool_call_id = action.toolCallId, -- 1696
			name = action.tool, -- 1697
			content = action.result and toJson(action.result, false) or "" -- 1698
		} -- 1698
	) -- 1698
end -- 1693
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1702
	appendConversationMessage( -- 1708
		shared, -- 1708
		{ -- 1708
			role = "assistant", -- 1709
			content = content or "", -- 1710
			reasoning_content = reasoningContent, -- 1711
			tool_calls = __TS__ArrayMap( -- 1712
				actions, -- 1712
				function(____, action) return { -- 1712
					id = action.toolCallId, -- 1713
					type = "function", -- 1714
					["function"] = { -- 1715
						name = action.tool, -- 1716
						arguments = toJson(action.params, false) -- 1717
					} -- 1717
				} end -- 1717
			) -- 1717
		} -- 1717
	) -- 1717
end -- 1702
local function llm(shared, messages, phase) -- 1901
	if phase == nil then -- 1901
		phase = "decision_xml" -- 1904
	end -- 1904
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1904
		local stepId = shared.step + 1 -- 1906
		emitLLMContextMetrics( -- 1907
			shared, -- 1907
			stepId, -- 1907
			phase, -- 1907
			messages, -- 1907
			shared.llmOptions -- 1907
		) -- 1907
		saveStepLLMDebugInput( -- 1908
			shared, -- 1908
			stepId, -- 1908
			phase, -- 1908
			messages, -- 1908
			shared.llmOptions -- 1908
		) -- 1908
		local lastStreamReasoning = "" -- 1909
		local res = __TS__Await(callLLMStreamAggregated( -- 1910
			messages, -- 1911
			shared.llmOptions, -- 1912
			shared.stopToken, -- 1913
			shared.llmConfig, -- 1914
			function(response) -- 1915
				local ____opt_51 = response.choices -- 1915
				local ____opt_49 = ____opt_51 and ____opt_51[1] -- 1915
				local streamMessage = ____opt_49 and ____opt_49.message -- 1916
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1917
				if nextContent == "" then -- 1917
					return -- 1920
				end -- 1920
				if nextContent == lastStreamReasoning then -- 1920
					return -- 1921
				end -- 1921
				lastStreamReasoning = nextContent -- 1922
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1923
			end -- 1915
		)) -- 1915
		if res.success then -- 1915
			local usage = res.tokenUsage -- 1927
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1928
			local ____opt_57 = res.response.choices -- 1928
			local ____opt_55 = ____opt_57 and ____opt_57[1] -- 1928
			local message = ____opt_55 and ____opt_55.message -- 1929
			local text = message and message.content -- 1930
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1931
			if text then -- 1931
				local parsed = tryParseAndValidateDecision(text, shared.role) -- 1935
				if parsed.success then -- 1935
					local reason = parsed.reason or "" -- 1937
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1938
				end -- 1938
				saveStepLLMDebugOutput( -- 1940
					shared, -- 1940
					stepId, -- 1940
					phase, -- 1940
					text, -- 1940
					{success = true, usage = usage} -- 1940
				) -- 1940
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1940
			else -- 1940
				saveStepLLMDebugOutput( -- 1943
					shared, -- 1943
					stepId, -- 1943
					phase, -- 1943
					"empty LLM response", -- 1943
					{success = false, usage = usage} -- 1943
				) -- 1943
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1943
			end -- 1943
		else -- 1943
			local usage = res.tokenUsage -- 1947
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1948
			saveStepLLMDebugOutput( -- 1949
				shared, -- 1949
				stepId, -- 1949
				phase, -- 1949
				res.raw or res.message, -- 1949
				{success = false, usage = usage} -- 1949
			) -- 1949
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1949
		end -- 1949
	end) -- 1949
end -- 1901
local function isDecisionBatchSuccess(result) -- 1973
	return result.kind == "batch" -- 1974
end -- 1973
local function parseDecisionToolCall(functionName, rawObj) -- 1998
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 1998
		return {success = false, message = "unknown tool: " .. functionName} -- 2000
	end -- 2000
	if rawObj == nil then -- 2000
		return {success = true, tool = functionName, params = {}} -- 2003
	end -- 2003
	if not isRecord(rawObj) then -- 2003
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2006
	end -- 2006
	return {success = true, tool = functionName, params = rawObj} -- 2008
end -- 1998
local function parseToolCallArguments(functionName, argsText) -- 2015
	local trimmedArgs = __TS__StringTrim(argsText) -- 2016
	if trimmedArgs == "" then -- 2016
		return {} -- 2018
	end -- 2018
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 2020
	if err ~= nil or rawObj == nil then -- 2020
		return { -- 2022
			success = false, -- 2023
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2024
			raw = argsText -- 2025
		} -- 2025
	end -- 2025
	local encodedRaw = safeJsonEncode(rawObj) -- 2028
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2028
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2030
	end -- 2030
	return rawObj -- 2036
end -- 2015
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2039
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2047
	if isRecord(rawArgs) and rawArgs.success == false then -- 2047
		return rawArgs -- 2049
	end -- 2049
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2051
	if not decision.success then -- 2051
		return {success = false, message = decision.message, raw = argsText} -- 2053
	end -- 2053
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2059
	if not completionValidation.success then -- 2059
		return {success = false, message = completionValidation.message, raw = argsText} -- 2061
	end -- 2061
	local validation = validateDecision(decision.tool, decision.params) -- 2067
	if not validation.success then -- 2067
		return {success = false, message = validation.message, raw = argsText} -- 2069
	end -- 2069
	if not isToolAllowedForRole(shared, decision.tool) then -- 2069
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 2076
	end -- 2076
	decision.params = validation.params -- 2082
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2083
	decision.reason = reason -- 2084
	decision.reasoningContent = reasoningContent -- 2085
	return decision -- 2086
end -- 2039
local function createPreExecutableActionFromStream(shared, toolCall) -- 2089
	local ____opt_63 = toolCall["function"] -- 2089
	local functionName = ____opt_63 and ____opt_63.name -- 2090
	local ____opt_65 = toolCall["function"] -- 2090
	local argsText = ____opt_65 and ____opt_65.arguments or "" -- 2091
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2092
	if not functionName or not toolCallId then -- 2092
		return nil -- 2093
	end -- 2093
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2094
	if isRecord(rawArgs) and rawArgs.success == false then -- 2094
		return nil -- 2095
	end -- 2095
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2096
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2096
		return nil -- 2097
	end -- 2097
	local validation = validateDecision(decision.tool, decision.params) -- 2098
	if not validation.success then -- 2098
		return nil -- 2099
	end -- 2099
	if not isToolAllowedForRole(shared, decision.tool) then -- 2099
		return nil -- 2100
	end -- 2100
	return { -- 2101
		step = shared.step + 1, -- 2102
		toolCallId = toolCallId, -- 2103
		tool = decision.tool, -- 2104
		reason = "", -- 2105
		params = validation.params, -- 2106
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2107
	} -- 2107
end -- 2089
local function sanitizeMessagesForLLMInput(messages) -- 2309
	local sanitized = {} -- 2310
	local droppedAssistantToolCalls = 0 -- 2311
	local droppedToolResults = 0 -- 2312
	do -- 2312
		local i = 0 -- 2313
		while i < #messages do -- 2313
			do -- 2313
				local message = messages[i + 1] -- 2314
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2314
					local requiredIds = {} -- 2316
					do -- 2316
						local j = 0 -- 2317
						while j < #message.tool_calls do -- 2317
							local toolCall = message.tool_calls[j + 1] -- 2318
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2319
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2319
								requiredIds[#requiredIds + 1] = id -- 2321
							end -- 2321
							j = j + 1 -- 2317
						end -- 2317
					end -- 2317
					if #requiredIds == 0 then -- 2317
						sanitized[#sanitized + 1] = message -- 2325
						goto __continue398 -- 2326
					end -- 2326
					local matchedIds = {} -- 2328
					local matchedTools = {} -- 2329
					local j = i + 1 -- 2330
					while j < #messages do -- 2330
						local toolMessage = messages[j + 1] -- 2332
						if toolMessage.role ~= "tool" then -- 2332
							break -- 2333
						end -- 2333
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2334
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2334
							matchedIds[toolCallId] = true -- 2336
							matchedTools[#matchedTools + 1] = toolMessage -- 2337
						else -- 2337
							droppedToolResults = droppedToolResults + 1 -- 2339
						end -- 2339
						j = j + 1 -- 2341
					end -- 2341
					local complete = true -- 2343
					do -- 2343
						local j = 0 -- 2344
						while j < #requiredIds do -- 2344
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2344
								complete = false -- 2346
								break -- 2347
							end -- 2347
							j = j + 1 -- 2344
						end -- 2344
					end -- 2344
					if complete then -- 2344
						__TS__ArrayPush( -- 2351
							sanitized, -- 2351
							message, -- 2351
							table.unpack(matchedTools) -- 2351
						) -- 2351
					else -- 2351
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2353
						droppedToolResults = droppedToolResults + #matchedTools -- 2354
					end -- 2354
					i = j - 1 -- 2356
					goto __continue398 -- 2357
				end -- 2357
				if message.role == "tool" then -- 2357
					droppedToolResults = droppedToolResults + 1 -- 2360
					goto __continue398 -- 2361
				end -- 2361
				sanitized[#sanitized + 1] = message -- 2363
			end -- 2363
			::__continue398:: -- 2363
			i = i + 1 -- 2313
		end -- 2313
	end -- 2313
	return sanitized -- 2365
end -- 2309
local function getUnconsolidatedMessages(shared) -- 2368
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2369
end -- 2368
local function getFinalDecisionTurnPrompt(shared) -- 2372
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2373
end -- 2372
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2378
	if attempt == nil then -- 2378
		attempt = 1 -- 2381
	end -- 2381
	if decisionMode == nil then -- 2381
		decisionMode = shared.decisionMode -- 2383
	end -- 2383
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2385
	local tailSections = {} -- 2386
	if shared.resumeCheckpointPending == true then -- 2386
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2388
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2391
	end -- 2391
	shared.resumeCheckpointPending = false -- 2393
	local messages = { -- 2394
		{role = "system", content = systemPrompt}, -- 2395
		table.unpack(getUnconsolidatedMessages(shared)) -- 2396
	} -- 2396
	if shared.step + 1 >= shared.maxSteps then -- 2396
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2399
	end -- 2399
	if lastError and lastError ~= "" then -- 2399
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2402
		if decisionMode == "xml" then -- 2402
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2406
		end -- 2406
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2406
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2409
		end -- 2409
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2409
			retryHeader = retryHeader .. "\nYour previous response spent the token budget on reasoning and ended before any tool call. Do not continue that reasoning. Immediately emit one valid function tool call with compact arguments." -- 2412
		end -- 2412
		messages[#messages + 1] = { -- 2414
			role = "user", -- 2415
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2416
		} -- 2416
	end -- 2416
	tailSections[#tailSections + 1] = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2423
		role = shared.role, -- 2424
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2425
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2426
		resumeRequiredTool = shared.resumeRequiredTool, -- 2427
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2428
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2429
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2430
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2431
		buildRepairPending = shared.buildRepairPending, -- 2432
		editBudgetExhausted = shared.unbuiltEdits == true and (shared.editsSinceBuild or 0) >= 3, -- 2433
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2434
	}) -- 2434
	messages[#messages + 1] = { -- 2436
		role = "user", -- 2437
		content = table.concat(tailSections, "\n\n") -- 2438
	} -- 2438
	return messages -- 2440
end -- 2378
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2447
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2456
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2457
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2465
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2466
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2467
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2475
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}, disabledAgentTools = shared.disabledAgentTools}) -- 2483
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2489
	local repairPrompt = replacePromptVars( -- 2492
		shared.promptPack.xmlDecisionRepairPrompt, -- 2492
		{ -- 2492
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2493
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2494
			CANDIDATE_SECTION = candidateSection, -- 2495
			LAST_ERROR = lastError, -- 2496
			ATTEMPT = tostring(attempt) -- 2497
		} -- 2497
	) -- 2497
	local availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2499
		role = shared.role, -- 2500
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2501
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2502
		resumeRequiredTool = shared.resumeRequiredTool, -- 2503
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2504
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2505
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2506
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2507
		buildRepairPending = shared.buildRepairPending, -- 2508
		editBudgetExhausted = shared.unbuiltEdits == true and (shared.editsSinceBuild or 0) >= 3, -- 2509
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2510
	}) -- 2510
	return {{role = "system", content = systemPrompt}, {role = "user", content = (repairPrompt .. "\n\n") .. availabilityPrompt}} -- 2512
end -- 2447
local function normalizeLineEndings(text) -- 2546
	local res = string.gsub(text, "\r\n", "\n") -- 2547
	res = string.gsub(res, "\r", "\n") -- 2548
	return res -- 2549
end -- 2546
local function countOccurrences(text, searchStr) -- 2552
	if searchStr == "" then -- 2552
		return 0 -- 2553
	end -- 2553
	local count = 0 -- 2554
	local pos = 0 -- 2555
	while true do -- 2555
		local idx = (string.find( -- 2557
			text, -- 2557
			searchStr, -- 2557
			math.max(pos + 1, 1), -- 2557
			true -- 2557
		) or 0) - 1 -- 2557
		if idx < 0 then -- 2557
			break -- 2558
		end -- 2558
		count = count + 1 -- 2559
		pos = idx + #searchStr -- 2560
	end -- 2560
	return count -- 2562
end -- 2552
local function replaceFirst(text, oldStr, newStr) -- 2565
	if oldStr == "" then -- 2565
		return text -- 2566
	end -- 2566
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2567
	if idx < 0 then -- 2567
		return text -- 2568
	end -- 2568
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2569
end -- 2565
local function splitLines(text) -- 2572
	return __TS__StringSplit(text, "\n") -- 2573
end -- 2572
local function getLeadingWhitespace(text) -- 2576
	local i = 0 -- 2577
	while i < #text do -- 2577
		local ch = __TS__StringAccess(text, i) -- 2579
		if ch ~= " " and ch ~= "\t" then -- 2579
			break -- 2580
		end -- 2580
		i = i + 1 -- 2581
	end -- 2581
	return __TS__StringSubstring(text, 0, i) -- 2583
end -- 2576
local function getCommonIndentPrefix(lines) -- 2586
	local common -- 2587
	do -- 2587
		local i = 0 -- 2588
		while i < #lines do -- 2588
			do -- 2588
				local line = lines[i + 1] -- 2589
				if __TS__StringTrim(line) == "" then -- 2589
					goto __continue444 -- 2590
				end -- 2590
				local indent = getLeadingWhitespace(line) -- 2591
				if common == nil then -- 2591
					common = indent -- 2593
					goto __continue444 -- 2594
				end -- 2594
				local j = 0 -- 2596
				local maxLen = math.min(#common, #indent) -- 2597
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2597
					j = j + 1 -- 2599
				end -- 2599
				common = __TS__StringSubstring(common, 0, j) -- 2601
				if common == "" then -- 2601
					break -- 2602
				end -- 2602
			end -- 2602
			::__continue444:: -- 2602
			i = i + 1 -- 2588
		end -- 2588
	end -- 2588
	return common or "" -- 2604
end -- 2586
local function removeIndentPrefix(line, indent) -- 2607
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2607
		return __TS__StringSubstring(line, #indent) -- 2609
	end -- 2609
	local lineIndent = getLeadingWhitespace(line) -- 2611
	local j = 0 -- 2612
	local maxLen = math.min(#lineIndent, #indent) -- 2613
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2613
		j = j + 1 -- 2615
	end -- 2615
	return __TS__StringSubstring(line, j) -- 2617
end -- 2607
local function dedentLines(lines) -- 2620
	local indent = getCommonIndentPrefix(lines) -- 2621
	return { -- 2622
		indent = indent, -- 2623
		lines = __TS__ArrayMap( -- 2624
			lines, -- 2624
			function(____, line) return removeIndentPrefix(line, indent) end -- 2624
		) -- 2624
	} -- 2624
end -- 2620
local function joinLines(lines) -- 2628
	return table.concat(lines, "\n") -- 2629
end -- 2628
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2632
	local function findWhitespaceTolerantReplacement() -- 2637
		local function foldWhitespace(text, withMap) -- 2639
			local parts = {} -- 2640
			local map = {} -- 2641
			local i = 0 -- 2642
			while i < #text do -- 2642
				local ch = __TS__StringAccess(text, i) -- 2644
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2644
					local start = i -- 2646
					while i < #text do -- 2646
						local next = __TS__StringAccess(text, i) -- 2648
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2648
							break -- 2649
						end -- 2649
						i = i + 1 -- 2650
					end -- 2650
					parts[#parts + 1] = " " -- 2652
					if withMap then -- 2652
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2653
					end -- 2653
				else -- 2653
					parts[#parts + 1] = ch -- 2655
					if withMap then -- 2655
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2656
					end -- 2656
					i = i + 1 -- 2657
				end -- 2657
			end -- 2657
			return { -- 2660
				text = table.concat(parts, ""), -- 2660
				map = map -- 2660
			} -- 2660
		end -- 2639
		local foldedContent = foldWhitespace(content, true) -- 2662
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2663
		if foldedOld == "" then -- 2663
			return {success = false, message = "old_str not found in file"} -- 2665
		end -- 2665
		local matches = {} -- 2667
		local pos = 0 -- 2668
		while true do -- 2668
			local idx = (string.find( -- 2670
				foldedContent.text, -- 2670
				foldedOld, -- 2670
				math.max(pos + 1, 1), -- 2670
				true -- 2670
			) or 0) - 1 -- 2670
			if idx < 0 then -- 2670
				break -- 2671
			end -- 2671
			local lastIdx = idx + #foldedOld - 1 -- 2672
			local startMap = foldedContent.map[idx + 1] -- 2673
			local endMap = foldedContent.map[lastIdx + 1] -- 2674
			if startMap ~= nil and endMap ~= nil then -- 2674
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2676
			end -- 2676
			pos = idx + #foldedOld -- 2678
		end -- 2678
		if #matches == 0 then -- 2678
			return {success = false, message = "old_str not found in file"} -- 2681
		end -- 2681
		if #matches > 1 then -- 2681
			return { -- 2684
				success = false, -- 2685
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2686
			} -- 2686
		end -- 2686
		local match = matches[1] -- 2689
		return { -- 2690
			success = true, -- 2691
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2692
		} -- 2692
	end -- 2637
	local contentLines = splitLines(content) -- 2695
	local oldLines = splitLines(oldStr) -- 2696
	if #oldLines == 0 then -- 2696
		return {success = false, message = "old_str not found in file"} -- 2698
	end -- 2698
	local dedentedOld = dedentLines(oldLines) -- 2700
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2701
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2702
	local matches = {} -- 2703
	do -- 2703
		local start = 0 -- 2704
		while start <= #contentLines - #oldLines do -- 2704
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2705
			local dedentedCandidate = dedentLines(candidateLines) -- 2706
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2706
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2708
			end -- 2708
			start = start + 1 -- 2704
		end -- 2704
	end -- 2704
	if #matches == 0 then -- 2704
		return findWhitespaceTolerantReplacement() -- 2716
	end -- 2716
	if #matches > 1 then -- 2716
		return { -- 2719
			success = false, -- 2720
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2721
		} -- 2721
	end -- 2721
	local match = matches[1] -- 2724
	local rebuiltNewLines = __TS__ArrayMap( -- 2725
		dedentedNew.lines, -- 2725
		function(____, line) return line == "" and "" or match.indent .. line end -- 2725
	) -- 2725
	local ____array_71 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2725
	__TS__SparseArrayPush( -- 2725
		____array_71, -- 2725
		table.unpack(rebuiltNewLines) -- 2728
	) -- 2728
	__TS__SparseArrayPush( -- 2728
		____array_71, -- 2728
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2729
	) -- 2729
	local nextLines = {__TS__SparseArraySpread(____array_71)} -- 2726
	return { -- 2731
		success = true, -- 2731
		content = joinLines(nextLines) -- 2731
	} -- 2731
end -- 2632
local MainDecisionAgent = __TS__Class() -- 2734
MainDecisionAgent.name = "MainDecisionAgent" -- 2734
__TS__ClassExtends(MainDecisionAgent, Node) -- 2734
function MainDecisionAgent.prototype.prep(self, shared) -- 2735
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2735
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2735
			return ____awaiter_resolve(nil, {shared = shared}) -- 2735
		end -- 2735
		__TS__Await(maybeCompressHistory(shared)) -- 2740
		return ____awaiter_resolve(nil, {shared = shared}) -- 2740
	end) -- 2740
end -- 2735
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2745
	local preExecuted = shared.preExecutedResults -- 2746
	if not preExecuted or preExecuted.size == 0 then -- 2746
		return nil -- 2747
	end -- 2747
	local decisions = {} -- 2748
	preExecuted:forEach(function(____, preResult) -- 2749
		local action = preResult.action -- 2750
		decisions[#decisions + 1] = { -- 2751
			success = true, -- 2752
			tool = action.tool, -- 2753
			params = action.params, -- 2754
			toolCallId = action.toolCallId, -- 2755
			reason = action.reason, -- 2756
			reasoningContent = action.reasoningContent -- 2757
		} -- 2757
	end) -- 2749
	if #decisions == 0 then -- 2749
		return nil -- 2760
	end -- 2760
	Log( -- 2761
		"Warn", -- 2761
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2761
			__TS__ArrayMap( -- 2761
				decisions, -- 2761
				function(____, decision) return decision.tool end -- 2761
			), -- 2761
			"," -- 2761
		) -- 2761
	) -- 2761
	if #decisions == 1 then -- 2761
		return decisions[1] -- 2763
	end -- 2763
	return {success = true, kind = "batch", decisions = decisions} -- 2765
end -- 2745
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2772
	if attempt == nil then -- 2772
		attempt = 1 -- 2775
	end -- 2775
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2775
		if shared.stopToken.stopped then -- 2775
			return ____awaiter_resolve( -- 2775
				nil, -- 2775
				{ -- 2779
					success = false, -- 2779
					message = getCancelledReason(shared) -- 2779
				} -- 2779
			) -- 2779
		end -- 2779
		Log( -- 2781
			"Info", -- 2781
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2781
		) -- 2781
		local tools = AgentToolRegistry.buildDecisionToolSchema(shared.role, SEARCH_DORA_API_LIMIT_MAX, {disabledAgentTools = shared.disabledAgentTools}) -- 2782
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2785
		local stepId = shared.step + 1 -- 2786
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2787
			string.lower(shared.llmConfig.model), -- 2787
			"glm-5.2" -- 2787
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2787
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2790
		emitLLMContextMetrics( -- 2795
			shared, -- 2795
			stepId, -- 2795
			"decision_tool_calling", -- 2795
			messages, -- 2795
			llmOptions -- 2795
		) -- 2795
		saveStepLLMDebugInput( -- 2796
			shared, -- 2796
			stepId, -- 2796
			"decision_tool_calling", -- 2796
			messages, -- 2796
			llmOptions -- 2796
		) -- 2796
		local lastStreamContent = "" -- 2797
		local lastStreamReasoning = "" -- 2798
		local preExecutedResults = __TS__New(Map) -- 2799
		shared.preExecutedResults = preExecutedResults -- 2800
		local res = __TS__Await(callLLMStreamAggregated( -- 2801
			messages, -- 2802
			llmOptions, -- 2803
			shared.stopToken, -- 2804
			shared.llmConfig, -- 2805
			function(response) -- 2806
				local ____opt_74 = response.choices -- 2806
				local ____opt_72 = ____opt_74 and ____opt_74[1] -- 2806
				local streamMessage = ____opt_72 and ____opt_72.message -- 2807
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2808
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2811
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2811
					return -- 2815
				end -- 2815
				lastStreamContent = nextContent -- 2817
				lastStreamReasoning = nextReasoning -- 2818
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2819
			end, -- 2806
			function(tc) -- 2821
				if shared.stopToken.stopped then -- 2821
					return -- 2822
				end -- 2822
				local action = createPreExecutableActionFromStream(shared, tc) -- 2823
				if not action or preExecutedResults:has(action.toolCallId) then -- 2823
					return -- 2824
				end -- 2824
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2825
				preExecutedResults:set( -- 2826
					action.toolCallId, -- 2826
					createPreExecutedToolResult(shared, action) -- 2826
				) -- 2826
			end -- 2821
		)) -- 2821
		if shared.stopToken.stopped then -- 2821
			clearPreExecutedResults(shared) -- 2830
			return ____awaiter_resolve( -- 2830
				nil, -- 2830
				{ -- 2831
					success = false, -- 2831
					message = getCancelledReason(shared) -- 2831
				} -- 2831
			) -- 2831
		end -- 2831
		if not res.success then -- 2831
			local usage = res.tokenUsage -- 2834
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2835
			saveStepLLMDebugOutput( -- 2836
				shared, -- 2836
				stepId, -- 2836
				"decision_tool_calling", -- 2836
				res.raw or res.message, -- 2836
				{success = false, usage = usage} -- 2836
			) -- 2836
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2837
			if (string.find(res.message, "stream incomplete:", nil, true) or 0) - 1 >= 0 then -- 2837
				Log("Warn", "[CodingAgent] discarding all partial tool calls after incomplete stream") -- 2839
			end -- 2839
			clearPreExecutedResults(shared) -- 2841
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2841
		end -- 2841
		local usage = res.tokenUsage -- 2844
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2845
		saveStepLLMDebugOutput( -- 2846
			shared, -- 2846
			stepId, -- 2846
			"decision_tool_calling", -- 2846
			encodeDebugJSON(res.response), -- 2846
			{success = true, usage = usage} -- 2846
		) -- 2846
		local choice = res.response.choices and res.response.choices[1] -- 2847
		local message = choice and choice.message -- 2848
		local toolCalls = message and message.tool_calls -- 2849
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2850
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2853
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2856
		Log( -- 2859
			"Info", -- 2859
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2859
		) -- 2859
		if finishReason == "length" then -- 2859
			Log( -- 2861
				"Error", -- 2861
				(("[CodingAgent] discarding truncated tool-calling output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2861
			) -- 2861
			clearPreExecutedResults(shared) -- 2862
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens. Do not continue the explanation. Retry immediately with one complete tool call and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 2862
		end -- 2862
		if not toolCalls or #toolCalls == 0 then -- 2862
			if messageContent and messageContent ~= "" then -- 2862
				if shared.role == "sub" then -- 2862
					Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 2872
					clearPreExecutedResults(shared) -- 2873
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 2873
				end -- 2873
				Log( -- 2880
					"Info", -- 2880
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2880
				) -- 2880
				clearPreExecutedResults(shared) -- 2881
				return ____awaiter_resolve(nil, { -- 2881
					success = true, -- 2883
					tool = "finish", -- 2884
					params = {}, -- 2885
					reason = messageContent, -- 2886
					reasoningContent = reasoningContent, -- 2887
					directSummary = messageContent -- 2888
				}) -- 2888
			end -- 2888
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2891
			clearPreExecutedResults(shared) -- 2892
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2892
		end -- 2892
		local decisions = {} -- 2899
		do -- 2899
			local i = 0 -- 2900
			while i < #toolCalls do -- 2900
				local toolCall = toolCalls[i + 1] -- 2901
				local fn = toolCall ~= nil and toolCall["function"] -- 2902
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2902
					Log( -- 2904
						"Error", -- 2904
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2904
					) -- 2904
					clearPreExecutedResults(shared) -- 2905
					return ____awaiter_resolve( -- 2905
						nil, -- 2905
						{ -- 2906
							success = false, -- 2907
							message = "missing function name for tool call " .. tostring(i + 1), -- 2908
							raw = messageContent -- 2909
						} -- 2909
					) -- 2909
				end -- 2909
				local functionName = fn.name -- 2912
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2913
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 2914
				Log( -- 2917
					"Info", -- 2917
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2917
				) -- 2917
				local decision = parseAndValidateToolCallDecision( -- 2918
					shared, -- 2919
					functionName, -- 2920
					argsText, -- 2921
					toolCallId, -- 2922
					messageContent, -- 2923
					reasoningContent -- 2924
				) -- 2924
				if not decision.success then -- 2924
					Log( -- 2927
						"Error", -- 2927
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2927
					) -- 2927
					clearPreExecutedResults(shared) -- 2928
					return ____awaiter_resolve(nil, decision) -- 2928
				end -- 2928
				decisions[#decisions + 1] = decision -- 2931
				i = i + 1 -- 2900
			end -- 2900
		end -- 2900
		if #decisions == 1 then -- 2900
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2934
			return ____awaiter_resolve(nil, decisions[1]) -- 2934
		end -- 2934
		do -- 2934
			local i = 0 -- 2937
			while i < #decisions do -- 2937
				if decisions[i + 1].tool == "finish" then -- 2937
					clearPreExecutedResults(shared) -- 2939
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2939
				end -- 2939
				i = i + 1 -- 2937
			end -- 2937
		end -- 2937
		Log( -- 2947
			"Info", -- 2947
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2947
				__TS__ArrayMap( -- 2947
					decisions, -- 2947
					function(____, decision) return decision.tool end -- 2947
				), -- 2947
				"," -- 2947
			) -- 2947
		) -- 2947
		return ____awaiter_resolve(nil, { -- 2947
			success = true, -- 2949
			kind = "batch", -- 2950
			decisions = decisions, -- 2951
			content = messageContent, -- 2952
			reasoningContent = reasoningContent -- 2953
		}) -- 2953
	end) -- 2953
end -- 2772
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 2957
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2957
		Log( -- 2963
			"Info", -- 2963
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2963
		) -- 2963
		local lastError = initialError -- 2964
		local candidateRaw = "" -- 2965
		local candidateReasoning = nil -- 2966
		do -- 2966
			local attempt = 0 -- 2967
			while attempt < shared.llmMaxTry do -- 2967
				do -- 2967
					Log( -- 2968
						"Info", -- 2968
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2968
					) -- 2968
					local messages = buildXmlRepairMessages( -- 2969
						shared, -- 2970
						originalRaw, -- 2971
						originalReasoning, -- 2972
						candidateRaw, -- 2973
						candidateReasoning, -- 2974
						lastError, -- 2975
						attempt + 1 -- 2976
					) -- 2976
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2978
					if shared.stopToken.stopped then -- 2978
						return ____awaiter_resolve( -- 2978
							nil, -- 2978
							{ -- 2980
								success = false, -- 2980
								message = getCancelledReason(shared) -- 2980
							} -- 2980
						) -- 2980
					end -- 2980
					if not llmRes.success then -- 2980
						lastError = llmRes.message -- 2983
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2984
						goto __continue511 -- 2985
					end -- 2985
					candidateRaw = llmRes.text -- 2987
					candidateReasoning = llmRes.reasoningContent -- 2988
					local decision = tryParseAndValidateDecision(candidateRaw, shared.role) -- 2989
					if decision.success then -- 2989
						decision.reasoningContent = llmRes.reasoningContent -- 2991
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2992
						return ____awaiter_resolve(nil, decision) -- 2992
					end -- 2992
					lastError = decision.message -- 2995
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2996
				end -- 2996
				::__continue511:: -- 2996
				attempt = attempt + 1 -- 2967
			end -- 2967
		end -- 2967
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2998
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2998
	end) -- 2998
end -- 2957
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3006
	if attempt == nil then -- 3006
		attempt = 1 -- 3009
	end -- 3009
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3009
		local messages = buildDecisionMessages( -- 3012
			shared, -- 3013
			lastError, -- 3014
			attempt, -- 3015
			lastRaw, -- 3016
			"xml" -- 3017
		) -- 3017
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3019
		if shared.stopToken.stopped then -- 3019
			return ____awaiter_resolve( -- 3019
				nil, -- 3019
				{ -- 3021
					success = false, -- 3021
					message = getCancelledReason(shared) -- 3021
				} -- 3021
			) -- 3021
		end -- 3021
		if not llmRes.success then -- 3021
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3021
		end -- 3021
		local decision = tryParseAndValidateDecision(llmRes.text, shared.role) -- 3030
		if decision.success then -- 3030
			decision.reasoningContent = llmRes.reasoningContent -- 3032
			if not isToolAllowedForRole(shared, decision.tool) then -- 3032
				return ____awaiter_resolve( -- 3032
					nil, -- 3032
					self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, (decision.tool .. " is not allowed for role ") .. shared.role) -- 3034
				) -- 3034
			end -- 3034
			return ____awaiter_resolve(nil, decision) -- 3034
		end -- 3034
		return ____awaiter_resolve( -- 3034
			nil, -- 3034
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3043
		) -- 3043
	end) -- 3043
end -- 3006
function MainDecisionAgent.prototype.exec(self, input) -- 3046
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3046
		local shared = input.shared -- 3047
		local function acceptResumeDecision(decision) -- 3048
			if shared.resumeRequiredTool == nil then -- 3048
				return true -- 3049
			end -- 3049
			local selectedTool -- 3050
			if isDecisionBatchSuccess(decision) then -- 3050
				selectedTool = #decision.decisions > 0 and decision.decisions[1].tool or nil -- 3052
			elseif decision.directSummary and decision.directSummary ~= "" then -- 3052
				selectedTool = "finish" -- 3054
			else -- 3054
				selectedTool = decision.tool -- 3056
			end -- 3056
			if selectedTool ~= shared.resumeRequiredTool then -- 3056
				return false -- 3058
			end -- 3058
			shared.resumeRequiredTool = nil -- 3059
			shared.resumeCheckpointPending = false -- 3060
			return true -- 3061
		end -- 3048
		if shared.stopToken.stopped then -- 3048
			return ____awaiter_resolve( -- 3048
				nil, -- 3048
				{ -- 3064
					success = false, -- 3064
					message = getCancelledReason(shared) -- 3064
				} -- 3064
			) -- 3064
		end -- 3064
		if shared.step >= shared.maxSteps then -- 3064
			Log( -- 3067
				"Warn", -- 3067
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3067
			) -- 3067
			return ____awaiter_resolve( -- 3067
				nil, -- 3067
				{ -- 3068
					success = false, -- 3068
					message = getMaxStepsReachedReason(shared) -- 3068
				} -- 3068
			) -- 3068
		end -- 3068
		if shared.decisionMode == "tool_calling" then -- 3068
			Log( -- 3072
				"Info", -- 3072
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3072
			) -- 3072
			local lastError = "tool calling validation failed" -- 3073
			local lastRaw = "" -- 3074
			local shouldFallbackToXml = false -- 3075
			do -- 3075
				local attempt = 0 -- 3076
				while attempt < shared.llmMaxTry do -- 3076
					do -- 3076
						Log( -- 3077
							"Info", -- 3077
							"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3077
						) -- 3077
						local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3078
						if shared.stopToken.stopped then -- 3078
							return ____awaiter_resolve( -- 3078
								nil, -- 3078
								{ -- 3085
									success = false, -- 3085
									message = getCancelledReason(shared) -- 3085
								} -- 3085
							) -- 3085
						end -- 3085
						if decision.success then -- 3085
							if acceptResumeDecision(decision) then -- 3085
								return ____awaiter_resolve(nil, decision) -- 3085
							end -- 3085
							lastError = ("Compression checkpoint requires " .. tostring(shared.resumeRequiredTool)) .. " as the next tool." -- 3089
							lastRaw = "" -- 3090
							goto __continue531 -- 3091
						end -- 3091
						lastError = decision.message -- 3093
						lastRaw = decision.raw or "" -- 3094
						Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3095
						if lastError == "missing tool call" then -- 3095
							shouldFallbackToXml = true -- 3097
							break -- 3098
						end -- 3098
					end -- 3098
					::__continue531:: -- 3098
					attempt = attempt + 1 -- 3076
				end -- 3076
			end -- 3076
			if shouldFallbackToXml then -- 3076
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3102
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3103
				do -- 3103
					local attempt = 0 -- 3104
					while attempt < shared.llmMaxTry do -- 3104
						do -- 3104
							Log( -- 3105
								"Info", -- 3105
								"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3105
							) -- 3105
							local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3106
							if shared.stopToken.stopped then -- 3106
								return ____awaiter_resolve( -- 3106
									nil, -- 3106
									{ -- 3113
										success = false, -- 3113
										message = getCancelledReason(shared) -- 3113
									} -- 3113
								) -- 3113
							end -- 3113
							if decision.success then -- 3113
								if acceptResumeDecision(decision) then -- 3113
									return ____awaiter_resolve(nil, decision) -- 3113
								end -- 3113
								lastError = ("Compression checkpoint requires " .. tostring(shared.resumeRequiredTool)) .. " as the next tool." -- 3117
								lastRaw = "" -- 3118
								goto __continue538 -- 3119
							end -- 3119
							lastError = decision.message -- 3121
							lastRaw = decision.raw or "" -- 3122
							Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3123
						end -- 3123
						::__continue538:: -- 3123
						attempt = attempt + 1 -- 3104
					end -- 3104
				end -- 3104
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3125
				return ____awaiter_resolve( -- 3125
					nil, -- 3125
					{ -- 3126
						success = false, -- 3126
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3126
					} -- 3126
				) -- 3126
			end -- 3126
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3128
			return ____awaiter_resolve( -- 3128
				nil, -- 3128
				{ -- 3129
					success = false, -- 3129
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3129
				} -- 3129
			) -- 3129
		end -- 3129
		local lastError = "xml validation failed" -- 3132
		local lastRaw = "" -- 3133
		do -- 3133
			local attempt = 0 -- 3134
			while attempt < shared.llmMaxTry do -- 3134
				do -- 3134
					local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3135
					if shared.stopToken.stopped then -- 3135
						return ____awaiter_resolve( -- 3135
							nil, -- 3135
							{ -- 3144
								success = false, -- 3144
								message = getCancelledReason(shared) -- 3144
							} -- 3144
						) -- 3144
					end -- 3144
					if decision.success then -- 3144
						if acceptResumeDecision(decision) then -- 3144
							return ____awaiter_resolve(nil, decision) -- 3144
						end -- 3144
						lastError = ("Compression checkpoint requires " .. tostring(shared.resumeRequiredTool)) .. " as the next tool." -- 3148
						lastRaw = "" -- 3149
						goto __continue543 -- 3150
					end -- 3150
					lastError = decision.message -- 3152
					lastRaw = decision.raw or "" -- 3153
				end -- 3153
				::__continue543:: -- 3153
				attempt = attempt + 1 -- 3134
			end -- 3134
		end -- 3134
		return ____awaiter_resolve( -- 3134
			nil, -- 3134
			{ -- 3155
				success = false, -- 3155
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3155
			} -- 3155
		) -- 3155
	end) -- 3155
end -- 3046
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3158
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3158
		local result = execRes -- 3159
		if not result.success then -- 3159
			if shared.stopToken.stopped then -- 3159
				shared.error = getCancelledReason(shared) -- 3162
				shared.done = true -- 3163
				return ____awaiter_resolve(nil, "done") -- 3163
			end -- 3163
			shared.error = result.message -- 3166
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3167
			shared.done = true -- 3168
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3169
			persistHistoryState(shared) -- 3173
			return ____awaiter_resolve(nil, "done") -- 3173
		end -- 3173
		if isDecisionBatchSuccess(result) then -- 3173
			local startStep = shared.step -- 3177
			local actions = {} -- 3178
			do -- 3178
				local i = 0 -- 3179
				while i < #result.decisions do -- 3179
					local decision = result.decisions[i + 1] -- 3180
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3181
					local step = startStep + i + 1 -- 3182
					local ____temp_80 -- 3183
					if i == 0 then -- 3183
						____temp_80 = decision.reason -- 3183
					else -- 3183
						____temp_80 = "" -- 3183
					end -- 3183
					local actionReason = ____temp_80 -- 3183
					local ____temp_81 -- 3184
					if i == 0 then -- 3184
						____temp_81 = decision.reasoningContent -- 3184
					else -- 3184
						____temp_81 = nil -- 3184
					end -- 3184
					local actionReasoningContent = ____temp_81 -- 3184
					emitAgentEvent(shared, { -- 3185
						type = "decision_made", -- 3186
						sessionId = shared.sessionId, -- 3187
						taskId = shared.taskId, -- 3188
						step = step, -- 3189
						tool = decision.tool, -- 3190
						reason = actionReason, -- 3191
						reasoningContent = actionReasoningContent, -- 3192
						params = decision.params -- 3193
					}) -- 3193
					local action = { -- 3195
						step = step, -- 3196
						toolCallId = toolCallId, -- 3197
						tool = decision.tool, -- 3198
						reason = actionReason or "", -- 3199
						reasoningContent = actionReasoningContent, -- 3200
						params = decision.params, -- 3201
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3202
					} -- 3202
					local ____shared_history_82 = shared.history -- 3202
					____shared_history_82[#____shared_history_82 + 1] = action -- 3204
					actions[#actions + 1] = action -- 3205
					i = i + 1 -- 3179
				end -- 3179
			end -- 3179
			shared.step = startStep + #actions -- 3207
			shared.pendingToolActions = actions -- 3208
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3209
			persistHistoryState(shared) -- 3215
			return ____awaiter_resolve(nil, "batch_tools") -- 3215
		end -- 3215
		if result.directSummary and result.directSummary ~= "" then -- 3215
			shared.response = result.directSummary -- 3219
			shared.completion = ____exports.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3220
			shared.done = true -- 3224
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3225
			persistHistoryState(shared) -- 3230
			return ____awaiter_resolve(nil, "done") -- 3230
		end -- 3230
		if result.tool == "finish" then -- 3230
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3234
			shared.response = finalMessage -- 3235
			shared.completion = getCompletionReport(result.params) -- 3236
			shared.done = true -- 3237
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3238
			persistHistoryState(shared) -- 3243
			return ____awaiter_resolve(nil, "done") -- 3243
		end -- 3243
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3246
		shared.step = shared.step + 1 -- 3247
		local step = shared.step -- 3248
		emitAgentEvent(shared, { -- 3249
			type = "decision_made", -- 3250
			sessionId = shared.sessionId, -- 3251
			taskId = shared.taskId, -- 3252
			step = step, -- 3253
			tool = result.tool, -- 3254
			reason = result.reason, -- 3255
			reasoningContent = result.reasoningContent, -- 3256
			params = result.params -- 3257
		}) -- 3257
		local ____shared_history_83 = shared.history -- 3257
		____shared_history_83[#____shared_history_83 + 1] = { -- 3259
			step = step, -- 3260
			toolCallId = toolCallId, -- 3261
			tool = result.tool, -- 3262
			reason = result.reason or "", -- 3263
			reasoningContent = result.reasoningContent, -- 3264
			params = result.params, -- 3265
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3266
		} -- 3266
		local action = shared.history[#shared.history] -- 3268
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3269
		shared.pendingToolActions = {action} -- 3272
		persistHistoryState(shared) -- 3273
		return ____awaiter_resolve(nil, "batch_tools") -- 3273
	end) -- 3273
end -- 3158
local ReadFileAction = __TS__Class() -- 3278
ReadFileAction.name = "ReadFileAction" -- 3278
__TS__ClassExtends(ReadFileAction, Node) -- 3278
function ReadFileAction.prototype.prep(self, shared) -- 3279
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3279
		local last = shared.history[#shared.history] -- 3280
		if not last then -- 3280
			error( -- 3281
				__TS__New(Error, "no history"), -- 3281
				0 -- 3281
			) -- 3281
		end -- 3281
		emitAgentStartEvent(shared, last) -- 3282
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3283
		if __TS__StringTrim(path) == "" then -- 3283
			error( -- 3286
				__TS__New(Error, "missing path"), -- 3286
				0 -- 3286
			) -- 3286
		end -- 3286
		local ____path_86 = path -- 3288
		local ____shared_workingDir_87 = shared.workingDir -- 3290
		local ____temp_88 = shared.useChineseResponse and "zh" or "en" -- 3291
		local ____last_params_startLine_84 = last.params.startLine -- 3292
		if ____last_params_startLine_84 == nil then -- 3292
			____last_params_startLine_84 = 1 -- 3292
		end -- 3292
		local ____TS__Number_result_89 = __TS__Number(____last_params_startLine_84) -- 3292
		local ____last_params_endLine_85 = last.params.endLine -- 3293
		if ____last_params_endLine_85 == nil then -- 3293
			____last_params_endLine_85 = READ_FILE_DEFAULT_LIMIT -- 3293
		end -- 3293
		return ____awaiter_resolve( -- 3293
			nil, -- 3293
			{ -- 3287
				path = ____path_86, -- 3288
				tool = "read_file", -- 3289
				workDir = ____shared_workingDir_87, -- 3290
				docLanguage = ____temp_88, -- 3291
				startLine = ____TS__Number_result_89, -- 3292
				endLine = __TS__Number(____last_params_endLine_85) -- 3293
			} -- 3293
		) -- 3293
	end) -- 3293
end -- 3279
function ReadFileAction.prototype.exec(self, input) -- 3297
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3297
		return ____awaiter_resolve( -- 3297
			nil, -- 3297
			Tools.readFile( -- 3298
				input.workDir, -- 3299
				input.path, -- 3300
				__TS__Number(input.startLine or 1), -- 3301
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3302
				input.docLanguage -- 3303
			) -- 3303
		) -- 3303
	end) -- 3303
end -- 3297
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3307
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3307
		local result = execRes -- 3308
		local last = shared.history[#shared.history] -- 3309
		if last ~= nil then -- 3309
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3311
			appendToolResultMessage(shared, last) -- 3312
			emitAgentFinishEvent(shared, last) -- 3313
		end -- 3313
		persistHistoryState(shared) -- 3315
		__TS__Await(maybeCompressHistory(shared)) -- 3316
		persistHistoryState(shared) -- 3317
		return ____awaiter_resolve(nil, "main") -- 3317
	end) -- 3317
end -- 3307
local SearchFilesAction = __TS__Class() -- 3322
SearchFilesAction.name = "SearchFilesAction" -- 3322
__TS__ClassExtends(SearchFilesAction, Node) -- 3322
function SearchFilesAction.prototype.prep(self, shared) -- 3323
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3323
		local last = shared.history[#shared.history] -- 3324
		if not last then -- 3324
			error( -- 3325
				__TS__New(Error, "no history"), -- 3325
				0 -- 3325
			) -- 3325
		end -- 3325
		emitAgentStartEvent(shared, last) -- 3326
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3326
	end) -- 3326
end -- 3323
function SearchFilesAction.prototype.exec(self, input) -- 3330
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3330
		local params = input.params -- 3331
		local ____Tools_searchFiles_103 = Tools.searchFiles -- 3332
		local ____input_workDir_96 = input.workDir -- 3333
		local ____temp_97 = params.path or "" -- 3334
		local ____temp_98 = params.pattern or "" -- 3335
		local ____params_globs_99 = params.globs -- 3336
		local ____params_useRegex_100 = params.useRegex -- 3337
		local ____params_caseSensitive_101 = params.caseSensitive -- 3338
		local ____math_max_92 = math.max -- 3341
		local ____math_floor_91 = math.floor -- 3341
		local ____params_limit_90 = params.limit -- 3341
		if ____params_limit_90 == nil then -- 3341
			____params_limit_90 = SEARCH_FILES_LIMIT_DEFAULT -- 3341
		end -- 3341
		local ____math_max_92_result_102 = ____math_max_92( -- 3341
			1, -- 3341
			____math_floor_91(__TS__Number(____params_limit_90)) -- 3341
		) -- 3341
		local ____math_max_95 = math.max -- 3342
		local ____math_floor_94 = math.floor -- 3342
		local ____params_offset_93 = params.offset -- 3342
		if ____params_offset_93 == nil then -- 3342
			____params_offset_93 = 0 -- 3342
		end -- 3342
		local result = __TS__Await(____Tools_searchFiles_103({ -- 3332
			workDir = ____input_workDir_96, -- 3333
			path = ____temp_97, -- 3334
			pattern = ____temp_98, -- 3335
			globs = ____params_globs_99, -- 3336
			useRegex = ____params_useRegex_100, -- 3337
			caseSensitive = ____params_caseSensitive_101, -- 3338
			includeContent = true, -- 3339
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3340
			limit = ____math_max_92_result_102, -- 3341
			offset = ____math_max_95( -- 3342
				0, -- 3342
				____math_floor_94(__TS__Number(____params_offset_93)) -- 3342
			), -- 3342
			groupByFile = params.groupByFile == true -- 3343
		})) -- 3343
		return ____awaiter_resolve(nil, result) -- 3343
	end) -- 3343
end -- 3330
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3348
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3348
		local last = shared.history[#shared.history] -- 3349
		if last ~= nil then -- 3349
			local result = execRes -- 3351
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3352
			appendToolResultMessage(shared, last) -- 3353
			emitAgentFinishEvent(shared, last) -- 3354
		end -- 3354
		persistHistoryState(shared) -- 3356
		__TS__Await(maybeCompressHistory(shared)) -- 3357
		persistHistoryState(shared) -- 3358
		return ____awaiter_resolve(nil, "main") -- 3358
	end) -- 3358
end -- 3348
local SearchDoraAPIAction = __TS__Class() -- 3363
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3363
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3363
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3364
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3364
		local last = shared.history[#shared.history] -- 3365
		if not last then -- 3365
			error( -- 3366
				__TS__New(Error, "no history"), -- 3366
				0 -- 3366
			) -- 3366
		end -- 3366
		emitAgentStartEvent(shared, last) -- 3367
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3367
	end) -- 3367
end -- 3364
function SearchDoraAPIAction.prototype.exec(self, input) -- 3371
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3371
		local params = input.params -- 3372
		local ____Tools_searchDoraAPI_111 = Tools.searchDoraAPI -- 3373
		local ____temp_107 = params.pattern or "" -- 3374
		local ____temp_108 = params.docSource or "api" -- 3375
		local ____temp_109 = input.useChineseResponse and "zh" or "en" -- 3376
		local ____temp_110 = params.programmingLanguage or "ts" -- 3377
		local ____math_min_106 = math.min -- 3378
		local ____math_max_105 = math.max -- 3378
		local ____params_limit_104 = params.limit -- 3378
		if ____params_limit_104 == nil then -- 3378
			____params_limit_104 = 8 -- 3378
		end -- 3378
		local result = __TS__Await(____Tools_searchDoraAPI_111({ -- 3373
			pattern = ____temp_107, -- 3374
			docSource = ____temp_108, -- 3375
			docLanguage = ____temp_109, -- 3376
			programmingLanguage = ____temp_110, -- 3377
			limit = ____math_min_106( -- 3378
				SEARCH_DORA_API_LIMIT_MAX, -- 3378
				____math_max_105( -- 3378
					1, -- 3378
					__TS__Number(____params_limit_104) -- 3378
				) -- 3378
			), -- 3378
			useRegex = params.useRegex, -- 3379
			caseSensitive = false, -- 3380
			includeContent = true, -- 3381
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3382
		})) -- 3382
		return ____awaiter_resolve(nil, result) -- 3382
	end) -- 3382
end -- 3371
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3387
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3387
		local last = shared.history[#shared.history] -- 3388
		if last ~= nil then -- 3388
			local result = execRes -- 3390
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3391
			appendToolResultMessage(shared, last) -- 3392
			emitAgentFinishEvent(shared, last) -- 3393
		end -- 3393
		persistHistoryState(shared) -- 3395
		__TS__Await(maybeCompressHistory(shared)) -- 3396
		persistHistoryState(shared) -- 3397
		return ____awaiter_resolve(nil, "main") -- 3397
	end) -- 3397
end -- 3387
local ListFilesAction = __TS__Class() -- 3402
ListFilesAction.name = "ListFilesAction" -- 3402
__TS__ClassExtends(ListFilesAction, Node) -- 3402
function ListFilesAction.prototype.prep(self, shared) -- 3403
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3403
		local last = shared.history[#shared.history] -- 3404
		if not last then -- 3404
			error( -- 3405
				__TS__New(Error, "no history"), -- 3405
				0 -- 3405
			) -- 3405
		end -- 3405
		emitAgentStartEvent(shared, last) -- 3406
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3406
	end) -- 3406
end -- 3403
function ListFilesAction.prototype.exec(self, input) -- 3410
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3410
		local params = input.params -- 3411
		local ____Tools_listFiles_118 = Tools.listFiles -- 3412
		local ____input_workDir_115 = input.workDir -- 3413
		local ____temp_116 = params.path or "" -- 3414
		local ____params_globs_117 = params.globs -- 3415
		local ____math_max_114 = math.max -- 3416
		local ____math_floor_113 = math.floor -- 3416
		local ____params_maxEntries_112 = params.maxEntries -- 3416
		if ____params_maxEntries_112 == nil then -- 3416
			____params_maxEntries_112 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3416
		end -- 3416
		local result = ____Tools_listFiles_118({ -- 3412
			workDir = ____input_workDir_115, -- 3413
			path = ____temp_116, -- 3414
			globs = ____params_globs_117, -- 3415
			maxEntries = ____math_max_114( -- 3416
				1, -- 3416
				____math_floor_113(__TS__Number(____params_maxEntries_112)) -- 3416
			) -- 3416
		}) -- 3416
		return ____awaiter_resolve(nil, result) -- 3416
	end) -- 3416
end -- 3410
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3421
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3421
		local last = shared.history[#shared.history] -- 3422
		if last ~= nil then -- 3422
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3424
			appendToolResultMessage(shared, last) -- 3425
			emitAgentFinishEvent(shared, last) -- 3426
		end -- 3426
		persistHistoryState(shared) -- 3428
		__TS__Await(maybeCompressHistory(shared)) -- 3429
		persistHistoryState(shared) -- 3430
		return ____awaiter_resolve(nil, "main") -- 3430
	end) -- 3430
end -- 3421
local DeleteFileAction = __TS__Class() -- 3435
DeleteFileAction.name = "DeleteFileAction" -- 3435
__TS__ClassExtends(DeleteFileAction, Node) -- 3435
function DeleteFileAction.prototype.prep(self, shared) -- 3436
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3436
		local last = shared.history[#shared.history] -- 3437
		if not last then -- 3437
			error( -- 3438
				__TS__New(Error, "no history"), -- 3438
				0 -- 3438
			) -- 3438
		end -- 3438
		emitAgentStartEvent(shared, last) -- 3439
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3440
		if __TS__StringTrim(targetFile) == "" then -- 3440
			error( -- 3443
				__TS__New(Error, "missing target_file"), -- 3443
				0 -- 3443
			) -- 3443
		end -- 3443
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3443
	end) -- 3443
end -- 3436
function DeleteFileAction.prototype.exec(self, input) -- 3447
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3447
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3448
		if not result.success then -- 3448
			return ____awaiter_resolve(nil, result) -- 3448
		end -- 3448
		return ____awaiter_resolve(nil, { -- 3448
			success = true, -- 3456
			changed = true, -- 3457
			mode = "delete", -- 3458
			checkpointId = result.checkpointId, -- 3459
			checkpointSeq = result.checkpointSeq, -- 3460
			files = {{path = input.targetFile, op = "delete"}} -- 3461
		}) -- 3461
	end) -- 3461
end -- 3447
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3465
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3465
		local last = shared.history[#shared.history] -- 3466
		if last ~= nil then -- 3466
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3468
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3469
			appendToolResultMessage(shared, last) -- 3470
			emitAgentFinishEvent(shared, last) -- 3471
			local result = last.result -- 3472
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3472
				emitAgentEvent(shared, { -- 3477
					type = "checkpoint_created", -- 3478
					sessionId = shared.sessionId, -- 3479
					taskId = shared.taskId, -- 3480
					step = last.step, -- 3481
					tool = "delete_file", -- 3482
					checkpointId = result.checkpointId, -- 3483
					checkpointSeq = result.checkpointSeq, -- 3484
					files = result.files -- 3485
				}) -- 3485
			end -- 3485
		end -- 3485
		persistHistoryState(shared) -- 3492
		__TS__Await(maybeCompressHistory(shared)) -- 3493
		persistHistoryState(shared) -- 3494
		return ____awaiter_resolve(nil, "main") -- 3494
	end) -- 3494
end -- 3465
local BuildAction = __TS__Class() -- 3499
BuildAction.name = "BuildAction" -- 3499
__TS__ClassExtends(BuildAction, Node) -- 3499
function BuildAction.prototype.prep(self, shared) -- 3500
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3500
		local last = shared.history[#shared.history] -- 3501
		if not last then -- 3501
			error( -- 3502
				__TS__New(Error, "no history"), -- 3502
				0 -- 3502
			) -- 3502
		end -- 3502
		emitAgentStartEvent(shared, last) -- 3503
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3503
	end) -- 3503
end -- 3500
function BuildAction.prototype.exec(self, input) -- 3507
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3507
		local params = input.params -- 3508
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3509
		return ____awaiter_resolve(nil, result) -- 3509
	end) -- 3509
end -- 3507
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3516
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3516
		local last = shared.history[#shared.history] -- 3517
		if last ~= nil then -- 3517
			last.result = sanitizeBuildResultForHistory(execRes) -- 3519
			appendToolResultMessage(shared, last) -- 3520
			emitAgentFinishEvent(shared, last) -- 3521
		end -- 3521
		persistHistoryState(shared) -- 3523
		__TS__Await(maybeCompressHistory(shared)) -- 3524
		persistHistoryState(shared) -- 3525
		return ____awaiter_resolve(nil, "main") -- 3525
	end) -- 3525
end -- 3516
local SpawnSubAgentAction = __TS__Class() -- 3530
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3530
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3530
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3531
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3531
		local last = shared.history[#shared.history] -- 3541
		if not last then -- 3541
			error( -- 3542
				__TS__New(Error, "no history"), -- 3542
				0 -- 3542
			) -- 3542
		end -- 3542
		emitAgentStartEvent(shared, last) -- 3543
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3544
			last.params.filesHint, -- 3545
			function(____, item) return type(item) == "string" end -- 3545
		) or nil -- 3545
		return ____awaiter_resolve( -- 3545
			nil, -- 3545
			{ -- 3547
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3548
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3549
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3550
				filesHint = filesHint, -- 3551
				sessionId = shared.sessionId, -- 3552
				projectRoot = shared.workingDir, -- 3553
				spawnSubAgent = shared.spawnSubAgent, -- 3554
				disabledAgentTools = shared.disabledAgentTools -- 3555
			} -- 3555
		) -- 3555
	end) -- 3555
end -- 3531
function SpawnSubAgentAction.prototype.exec(self, input) -- 3559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3559
		if not input.spawnSubAgent then -- 3559
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3559
		end -- 3559
		if input.sessionId == nil or input.sessionId <= 0 then -- 3559
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3559
		end -- 3559
		local ____Log_124 = Log -- 3575
		local ____temp_121 = #input.title -- 3575
		local ____temp_122 = #input.prompt -- 3575
		local ____temp_123 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3575
		local ____opt_119 = input.filesHint -- 3575
		____Log_124( -- 3575
			"Info", -- 3575
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_121)) .. " prompt_len=") .. tostring(____temp_122)) .. " expected_len=") .. tostring(____temp_123)) .. " files_hint_count=") .. tostring(____opt_119 and #____opt_119 or 0) -- 3575
		) -- 3575
		local result = __TS__Await(input.spawnSubAgent({ -- 3576
			parentSessionId = input.sessionId, -- 3577
			projectRoot = input.projectRoot, -- 3578
			title = input.title, -- 3579
			prompt = input.prompt, -- 3580
			expectedOutput = input.expectedOutput, -- 3581
			filesHint = input.filesHint, -- 3582
			disabledAgentTools = input.disabledAgentTools -- 3583
		})) -- 3583
		if not result.success then -- 3583
			return ____awaiter_resolve(nil, result) -- 3583
		end -- 3583
		return ____awaiter_resolve(nil, { -- 3583
			success = true, -- 3589
			sessionId = result.sessionId, -- 3590
			taskId = result.taskId, -- 3591
			title = result.title, -- 3592
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3593
		}) -- 3593
	end) -- 3593
end -- 3559
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3597
		local last = shared.history[#shared.history] -- 3598
		if last ~= nil then -- 3598
			last.result = execRes -- 3600
			if execRes.success == true then -- 3600
				shared.hasSpawnedSubAgentThisTask = true -- 3602
			end -- 3602
			appendToolResultMessage(shared, last) -- 3604
			emitAgentFinishEvent(shared, last) -- 3605
		end -- 3605
		persistHistoryState(shared) -- 3607
		__TS__Await(maybeCompressHistory(shared)) -- 3608
		persistHistoryState(shared) -- 3609
		return ____awaiter_resolve(nil, "main") -- 3609
	end) -- 3609
end -- 3597
local ListSubAgentsAction = __TS__Class() -- 3614
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3614
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3614
function ListSubAgentsAction.prototype.prep(self, shared) -- 3615
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3615
		local last = shared.history[#shared.history] -- 3625
		if not last then -- 3625
			error( -- 3626
				__TS__New(Error, "no history"), -- 3626
				0 -- 3626
			) -- 3626
		end -- 3626
		emitAgentStartEvent(shared, last) -- 3627
		return ____awaiter_resolve( -- 3627
			nil, -- 3627
			{ -- 3628
				sessionId = shared.sessionId, -- 3629
				projectRoot = shared.workingDir, -- 3630
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3631
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3632
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3633
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3634
				listSubAgents = shared.listSubAgents, -- 3635
				blockedByCurrentTaskSpawn = shared.hasSpawnedSubAgentThisTask == true -- 3636
			} -- 3636
		) -- 3636
	end) -- 3636
end -- 3615
function ListSubAgentsAction.prototype.exec(self, input) -- 3640
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3640
		if input.blockedByCurrentTaskSpawn then -- 3640
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is unavailable after spawn_sub_agent in the current task. Finish this turn and let results arrive as asynchronous handoffs."}) -- 3640
		end -- 3640
		if not input.listSubAgents then -- 3640
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3640
		end -- 3640
		if input.sessionId == nil or input.sessionId <= 0 then -- 3640
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3640
		end -- 3640
		local result = __TS__Await(input.listSubAgents({ -- 3662
			sessionId = input.sessionId, -- 3663
			projectRoot = input.projectRoot, -- 3664
			status = input.status, -- 3665
			limit = input.limit, -- 3666
			offset = input.offset, -- 3667
			query = input.query -- 3668
		})) -- 3668
		return ____awaiter_resolve(nil, result) -- 3668
	end) -- 3668
end -- 3640
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3673
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3673
		local last = shared.history[#shared.history] -- 3674
		if last ~= nil then -- 3674
			last.result = execRes -- 3676
			appendToolResultMessage(shared, last) -- 3677
			emitAgentFinishEvent(shared, last) -- 3678
		end -- 3678
		persistHistoryState(shared) -- 3680
		__TS__Await(maybeCompressHistory(shared)) -- 3681
		persistHistoryState(shared) -- 3682
		return ____awaiter_resolve(nil, "main") -- 3682
	end) -- 3682
end -- 3673
EditFileAction = __TS__Class() -- 3687
EditFileAction.name = "EditFileAction" -- 3687
__TS__ClassExtends(EditFileAction, Node) -- 3687
function EditFileAction.prototype.prep(self, shared) -- 3688
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3688
		local last = shared.history[#shared.history] -- 3689
		if not last then -- 3689
			error( -- 3690
				__TS__New(Error, "no history"), -- 3690
				0 -- 3690
			) -- 3690
		end -- 3690
		emitAgentStartEvent(shared, last) -- 3691
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3692
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3695
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3696
		if __TS__StringTrim(path) == "" then -- 3696
			error( -- 3697
				__TS__New(Error, "missing path"), -- 3697
				0 -- 3697
			) -- 3697
		end -- 3697
		return ____awaiter_resolve(nil, { -- 3697
			path = path, -- 3698
			oldStr = oldStr, -- 3698
			newStr = newStr, -- 3698
			taskId = shared.taskId, -- 3698
			workDir = shared.workingDir -- 3698
		}) -- 3698
	end) -- 3698
end -- 3688
function EditFileAction.prototype.exec(self, input) -- 3701
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3701
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3702
		if not readRes.success then -- 3702
			if input.oldStr ~= "" then -- 3702
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3702
			end -- 3702
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3707
			if not createRes.success then -- 3707
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3707
			end -- 3707
			return ____awaiter_resolve(nil, { -- 3707
				success = true, -- 3715
				changed = true, -- 3716
				mode = "create", -- 3717
				checkpointId = createRes.checkpointId, -- 3718
				checkpointSeq = createRes.checkpointSeq, -- 3719
				files = {{path = input.path, op = "create"}} -- 3720
			}) -- 3720
		end -- 3720
		if input.oldStr == "" then -- 3720
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3724
			if not overwriteRes.success then -- 3724
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3724
			end -- 3724
			return ____awaiter_resolve(nil, { -- 3724
				success = true, -- 3732
				changed = true, -- 3733
				mode = "overwrite", -- 3734
				checkpointId = overwriteRes.checkpointId, -- 3735
				checkpointSeq = overwriteRes.checkpointSeq, -- 3736
				files = {{path = input.path, op = "write"}} -- 3737
			}) -- 3737
		end -- 3737
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3742
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3743
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3744
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3747
		if occurrences == 0 then -- 3747
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3749
			if not indentTolerant.success then -- 3749
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3749
			end -- 3749
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3753
			if not applyRes.success then -- 3753
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3753
			end -- 3753
			return ____awaiter_resolve(nil, { -- 3753
				success = true, -- 3761
				changed = true, -- 3762
				mode = "replace_indent_tolerant", -- 3763
				checkpointId = applyRes.checkpointId, -- 3764
				checkpointSeq = applyRes.checkpointSeq, -- 3765
				files = {{path = input.path, op = "write"}} -- 3766
			}) -- 3766
		end -- 3766
		if occurrences > 1 then -- 3766
			return ____awaiter_resolve( -- 3766
				nil, -- 3766
				{ -- 3770
					success = false, -- 3770
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3770
				} -- 3770
			) -- 3770
		end -- 3770
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3774
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3775
		if not applyRes.success then -- 3775
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3775
		end -- 3775
		return ____awaiter_resolve(nil, { -- 3775
			success = true, -- 3783
			changed = true, -- 3784
			mode = "replace", -- 3785
			checkpointId = applyRes.checkpointId, -- 3786
			checkpointSeq = applyRes.checkpointSeq, -- 3787
			files = {{path = input.path, op = "write"}} -- 3788
		}) -- 3788
	end) -- 3788
end -- 3701
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3792
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3792
		local last = shared.history[#shared.history] -- 3793
		if last ~= nil then -- 3793
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3795
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3796
			appendToolResultMessage(shared, last) -- 3797
			emitAgentFinishEvent(shared, last) -- 3798
			local result = last.result -- 3799
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3799
				emitAgentEvent(shared, { -- 3804
					type = "checkpoint_created", -- 3805
					sessionId = shared.sessionId, -- 3806
					taskId = shared.taskId, -- 3807
					step = last.step, -- 3808
					tool = last.tool, -- 3809
					checkpointId = result.checkpointId, -- 3810
					checkpointSeq = result.checkpointSeq, -- 3811
					files = result.files -- 3812
				}) -- 3812
			end -- 3812
		end -- 3812
		persistHistoryState(shared) -- 3819
		__TS__Await(maybeCompressHistory(shared)) -- 3820
		persistHistoryState(shared) -- 3821
		return ____awaiter_resolve(nil, "main") -- 3821
	end) -- 3821
end -- 3792
local FetchUrlAction = __TS__Class() -- 3826
FetchUrlAction.name = "FetchUrlAction" -- 3826
__TS__ClassExtends(FetchUrlAction, Node) -- 3826
function FetchUrlAction.prototype.prep(self, shared) -- 3827
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3827
		local last = shared.history[#shared.history] -- 3828
		if not last then -- 3828
			error( -- 3829
				__TS__New(Error, "no history"), -- 3829
				0 -- 3829
			) -- 3829
		end -- 3829
		emitAgentStartEvent(shared, last) -- 3830
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3830
	end) -- 3830
end -- 3827
function FetchUrlAction.prototype.exec(self, input) -- 3834
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3834
		return ____awaiter_resolve( -- 3834
			nil, -- 3834
			executeToolAction(input.shared, input.action) -- 3835
		) -- 3835
	end) -- 3835
end -- 3834
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3838
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3838
		local last = shared.history[#shared.history] -- 3839
		if last ~= nil then -- 3839
			last.result = execRes -- 3841
			appendToolResultMessage(shared, last) -- 3842
			emitAgentFinishEvent(shared, last) -- 3843
		end -- 3843
		persistHistoryState(shared) -- 3845
		__TS__Await(maybeCompressHistory(shared)) -- 3846
		persistHistoryState(shared) -- 3847
		return ____awaiter_resolve(nil, "main") -- 3847
	end) -- 3847
end -- 3838
local function emitCheckpointEventForAction(shared, action) -- 3852
	local result = action.result -- 3853
	if not result then -- 3853
		return -- 3854
	end -- 3854
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3854
		emitAgentEvent(shared, { -- 3859
			type = "checkpoint_created", -- 3860
			sessionId = shared.sessionId, -- 3861
			taskId = shared.taskId, -- 3862
			step = action.step, -- 3863
			tool = action.tool, -- 3864
			checkpointId = result.checkpointId, -- 3865
			checkpointSeq = result.checkpointSeq, -- 3866
			files = result.files -- 3867
		}) -- 3867
	end -- 3867
end -- 3852
local function canRunBatchActionInParallel(self, action) -- 4468
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4469
end -- 4468
local function partitionToolCalls(actions) -- 4477
	local batches = {} -- 4478
	do -- 4478
		local i = 0 -- 4479
		while i < #actions do -- 4479
			local action = actions[i + 1] -- 4480
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4481
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4482
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4482
				local ____lastBatch_actions_155 = lastBatch.actions -- 4482
				____lastBatch_actions_155[#____lastBatch_actions_155 + 1] = action -- 4484
			else -- 4484
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4486
			end -- 4486
			i = i + 1 -- 4479
		end -- 4479
	end -- 4479
	return batches -- 4489
end -- 4477
local BatchToolAction = __TS__Class() -- 4492
BatchToolAction.name = "BatchToolAction" -- 4492
__TS__ClassExtends(BatchToolAction, Node) -- 4492
function BatchToolAction.prototype.prep(self, shared) -- 4493
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4493
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4493
	end) -- 4493
end -- 4493
function BatchToolAction.prototype.exec(self, input) -- 4497
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4497
		local shared = input.shared -- 4498
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4499
		local preExecuted = shared.preExecutedResults -- 4500
		local batches = partitionToolCalls(input.actions) -- 4501
		local parallelBatchCount = #__TS__ArrayFilter( -- 4502
			batches, -- 4502
			function(____, b) return b.isConcurrencySafe end -- 4502
		) -- 4502
		local serialBatchCount = #__TS__ArrayFilter( -- 4503
			batches, -- 4503
			function(____, b) return not b.isConcurrencySafe end -- 4503
		) -- 4503
		Log( -- 4504
			"Info", -- 4504
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4504
		) -- 4504
		do -- 4504
			local batchIdx = 0 -- 4506
			while batchIdx < #batches do -- 4506
				do -- 4506
					local batch = batches[batchIdx + 1] -- 4507
					if shared.stopToken.stopped then -- 4507
						for ____, action in ipairs(batch.actions) do -- 4509
							if not action.result then -- 4509
								action.result = { -- 4511
									success = false, -- 4511
									message = getCancelledReason(shared) -- 4511
								} -- 4511
							end -- 4511
						end -- 4511
						goto __continue763 -- 4514
					end -- 4514
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4514
						local preExecCount = #__TS__ArrayFilter( -- 4518
							batch.actions, -- 4518
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4518
						) -- 4518
						Log( -- 4519
							"Info", -- 4519
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4519
						) -- 4519
						do -- 4519
							local i = 0 -- 4520
							while i < #batch.actions do -- 4520
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4521
								i = i + 1 -- 4520
							end -- 4520
						end -- 4520
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4523
							batch.actions, -- 4523
							function(____, action) -- 4523
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4523
									if shared.stopToken.stopped then -- 4523
										action.result = { -- 4525
											success = false, -- 4525
											message = getCancelledReason(shared) -- 4525
										} -- 4525
										return ____awaiter_resolve(nil, action) -- 4525
									end -- 4525
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4528
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4529
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4530
									return ____awaiter_resolve(nil, action) -- 4530
								end) -- 4530
							end -- 4523
						))) -- 4523
						do -- 4523
							local i = 0 -- 4533
							while i < #batch.actions do -- 4533
								local action = batch.actions[i + 1] -- 4534
								if not action.result then -- 4534
									action.result = {success = false, message = "tool did not produce a result"} -- 4536
								end -- 4536
								appendToolResultMessage(shared, action) -- 4538
								emitAgentFinishEvent(shared, action) -- 4539
								emitCheckpointEventForAction(shared, action) -- 4540
								i = i + 1 -- 4533
							end -- 4533
						end -- 4533
					else -- 4533
						Log( -- 4543
							"Info", -- 4543
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4543
						) -- 4543
						do -- 4543
							local i = 0 -- 4544
							while i < #batch.actions do -- 4544
								local action = batch.actions[i + 1] -- 4545
								emitAgentStartEvent(shared, action) -- 4546
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4547
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4548
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4549
								appendToolResultMessage(shared, action) -- 4550
								emitAgentFinishEvent(shared, action) -- 4551
								emitCheckpointEventForAction(shared, action) -- 4552
								persistHistoryState(shared) -- 4553
								if shared.stopToken.stopped then -- 4553
									break -- 4555
								end -- 4555
								i = i + 1 -- 4544
							end -- 4544
						end -- 4544
					end -- 4544
				end -- 4544
				::__continue763:: -- 4544
				batchIdx = batchIdx + 1 -- 4506
			end -- 4506
		end -- 4506
		local spawnSeen = spawnedBeforeBatch -- 4560
		local didDelegatedForegroundWork = false -- 4561
		do -- 4561
			local i = 0 -- 4562
			while i < #input.actions do -- 4562
				do -- 4562
					local action = input.actions[i + 1] -- 4563
					if action.tool == "spawn_sub_agent" then -- 4563
						local ____opt_158 = action.result -- 4563
						if (____opt_158 and ____opt_158.success) == true then -- 4563
							spawnSeen = true -- 4565
						end -- 4565
						goto __continue782 -- 4566
					end -- 4566
					if spawnSeen and action.tool ~= "finish" then -- 4566
						didDelegatedForegroundWork = true -- 4569
					end -- 4569
				end -- 4569
				::__continue782:: -- 4569
				i = i + 1 -- 4562
			end -- 4562
		end -- 4562
		if didDelegatedForegroundWork then -- 4562
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4573
		end -- 4573
		persistHistoryState(shared) -- 4575
		return ____awaiter_resolve(nil, input.actions) -- 4575
	end) -- 4575
end -- 4497
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4579
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4579
		shared.pendingToolActions = nil -- 4580
		shared.preExecutedResults = nil -- 4581
		persistHistoryState(shared) -- 4582
		__TS__Await(maybeCompressHistory(shared)) -- 4583
		persistHistoryState(shared) -- 4584
		return ____awaiter_resolve(nil, "main") -- 4584
	end) -- 4584
end -- 4579
local EndNode = __TS__Class() -- 4589
EndNode.name = "EndNode" -- 4589
__TS__ClassExtends(EndNode, Node) -- 4589
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4590
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4590
		return ____awaiter_resolve(nil, nil) -- 4590
	end) -- 4590
end -- 4590
local CodingAgentFlow = __TS__Class() -- 4595
CodingAgentFlow.name = "CodingAgentFlow" -- 4595
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4595
function CodingAgentFlow.prototype.____constructor(self, role) -- 4596
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4597
	local read = __TS__New(ReadFileAction, 1, 0) -- 4598
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4599
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4600
	local list = __TS__New(ListFilesAction, 1, 0) -- 4601
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4602
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4603
	local build = __TS__New(BuildAction, 1, 0) -- 4604
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4605
	local edit = __TS__New(EditFileAction, 1, 0) -- 4606
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4607
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4608
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4609
	local done = __TS__New(EndNode, 1, 0) -- 4610
	main:on("batch_tools", batch) -- 4612
	main:on("grep_files", search) -- 4613
	main:on("search_dora_api", searchDora) -- 4614
	main:on("glob_files", list) -- 4615
	main:on("fetch_url", fetch) -- 4616
	main:on("execute_command", exec) -- 4617
	if role == "main" then -- 4617
		main:on("read_file", read) -- 4619
		main:on("delete_file", del) -- 4620
		main:on("build", build) -- 4621
		main:on("edit_file", edit) -- 4622
		main:on("list_sub_agents", listSub) -- 4623
		main:on("spawn_sub_agent", spawn) -- 4624
	else -- 4624
		main:on("read_file", read) -- 4626
		main:on("delete_file", del) -- 4627
		main:on("build", build) -- 4628
		main:on("edit_file", edit) -- 4629
	end -- 4629
	main:on("done", done) -- 4631
	search:on("main", main) -- 4633
	searchDora:on("main", main) -- 4634
	list:on("main", main) -- 4635
	listSub:on("main", main) -- 4636
	spawn:on("main", main) -- 4637
	batch:on("main", main) -- 4638
	read:on("main", main) -- 4639
	del:on("main", main) -- 4640
	build:on("main", main) -- 4641
	edit:on("main", main) -- 4642
	fetch:on("main", main) -- 4643
	exec:on("main", main) -- 4644
	Flow.prototype.____constructor(self, main) -- 4646
end -- 4596
local function runCodingAgentAsync(options) -- 4682
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4682
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4682
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4682
		end -- 4682
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4686
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4687
		if not llmConfigRes.success then -- 4687
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4687
		end -- 4687
		local llmConfig = llmConfigRes.config -- 4693
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4694
		if not taskRes.success then -- 4694
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4694
		end -- 4694
		local compressor = __TS__New(MemoryCompressor, { -- 4701
			compressionThreshold = 0.8, -- 4702
			compressionTargetThreshold = 0.5, -- 4703
			maxCompressionRounds = 3, -- 4704
			projectDir = options.workDir, -- 4705
			llmConfig = llmConfig, -- 4706
			promptPack = options.promptPack, -- 4707
			scope = options.memoryScope -- 4708
		}) -- 4708
		local persistedSession = compressor:getStorage():readSessionState() -- 4710
		local promptPack = compressor:getPromptPack() -- 4711
		local freshProject = inspectFreshProject(options.workDir) -- 4712
		local freshProjectBuildPending = freshProject.fresh -- 4713
		local freshProjectCodeFile = freshProject.codeFile -- 4714
		local shared = { -- 4716
			sessionId = options.sessionId, -- 4717
			taskId = taskRes.taskId, -- 4718
			role = options.role or "main", -- 4719
			maxSteps = math.max( -- 4720
				1, -- 4720
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4720
			), -- 4720
			llmMaxTry = math.max( -- 4721
				1, -- 4721
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4721
			), -- 4721
			step = 0, -- 4722
			done = false, -- 4723
			stopToken = options.stopToken or ({stopped = false}), -- 4724
			response = "", -- 4725
			userQuery = normalizedPrompt, -- 4726
			workingDir = options.workDir, -- 4727
			useChineseResponse = options.useChineseResponse == true, -- 4728
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4729
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4732
			llmConfig = llmConfig, -- 4733
			onEvent = options.onEvent, -- 4734
			promptPack = promptPack, -- 4735
			history = {}, -- 4736
			messages = persistedSession.messages, -- 4737
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4738
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4739
			memory = {compressor = compressor}, -- 4741
			skills = {loader = AgentSkills.createSkillsLoader({projectDir = options.workDir, disabledAgentTools = options.disabledAgentTools or ({})})}, -- 4745
			spawnSubAgent = options.spawnSubAgent, -- 4751
			listSubAgents = options.listSubAgents, -- 4752
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4753
			freshProjectBuildPending = freshProjectBuildPending, -- 4754
			freshProjectCodeFile = freshProjectCodeFile, -- 4755
			hasSpawnedSubAgentThisTask = false, -- 4756
			delegatedForegroundBatches = 0 -- 4757
		} -- 4757
		local ____hasReturned, ____returnValue -- 4757
		local ____try = __TS__AsyncAwaiter(function() -- 4757
			emitAgentEvent(shared, { -- 4761
				type = "task_started", -- 4762
				sessionId = shared.sessionId, -- 4763
				taskId = shared.taskId, -- 4764
				prompt = shared.userQuery, -- 4765
				workDir = shared.workingDir, -- 4766
				maxSteps = shared.maxSteps -- 4767
			}) -- 4767
			if shared.stopToken.stopped then -- 4767
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4770
				____hasReturned = true -- 4771
				____returnValue = emitAgentTaskFinishEvent( -- 4771
					shared, -- 4771
					false, -- 4771
					getCancelledReason(shared) -- 4771
				) -- 4771
				return -- 4771
			end -- 4771
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4773
			local promptCommand = getPromptCommand(shared.userQuery) -- 4774
			if promptCommand == "clear" then -- 4774
				____hasReturned = true -- 4776
				____returnValue = clearSessionHistory(shared) -- 4776
				return -- 4776
			end -- 4776
			if promptCommand == "compact" then -- 4776
				if shared.role == "sub" then -- 4776
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4780
					____hasReturned = true -- 4781
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4781
					return -- 4781
				end -- 4781
				____hasReturned = true -- 4789
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4789
				return -- 4789
			end -- 4789
			__TS__Await(maybeCompressHistory(shared, true)) -- 4791
			if shared.stopToken.stopped then -- 4791
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4793
				____hasReturned = true -- 4794
				____returnValue = emitAgentTaskFinishEvent( -- 4794
					shared, -- 4794
					false, -- 4794
					getCancelledReason(shared) -- 4794
				) -- 4794
				return -- 4794
			end -- 4794
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4796
			persistHistoryState(shared) -- 4800
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4801
			__TS__Await(flow:run(shared)) -- 4802
			if shared.stopToken.stopped then -- 4802
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4804
				____hasReturned = true -- 4805
				____returnValue = emitAgentTaskFinishEvent( -- 4805
					shared, -- 4805
					false, -- 4805
					getCancelledReason(shared) -- 4805
				) -- 4805
				return -- 4805
			end -- 4805
			if shared.error then -- 4805
				____hasReturned = true -- 4808
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4808
				return -- 4808
			end -- 4808
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4811
			____hasReturned = true -- 4812
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4812
			return -- 4812
		end) -- 4812
		____try = ____try.catch( -- 4812
			____try, -- 4812
			function(____, e) -- 4812
				return __TS__AsyncAwaiter(function() -- 4812
					____hasReturned = true -- 4815
					____returnValue = finalizeAgentFailure( -- 4815
						shared, -- 4815
						tostring(e) -- 4815
					) -- 4815
					return -- 4815
				end) -- 4815
			end -- 4815
		) -- 4815
		__TS__Await(____try) -- 4760
		if ____hasReturned then -- 4760
			return ____awaiter_resolve(nil, ____returnValue) -- 4760
		end -- 4760
	end) -- 4760
end -- 4682
function ____exports.runCodingAgent(options, callback) -- 4819
	local ____self_160 = runCodingAgentAsync(options) -- 4819
	____self_160["then"]( -- 4819
		____self_160, -- 4819
		function(____, result) return callback(result) end -- 4820
	) -- 4820
end -- 4819
return ____exports -- 4819