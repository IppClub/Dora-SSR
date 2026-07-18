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
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
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
local isRecord, isArray, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, getFinishMessage, normalizeCompletionText, normalizeCompletionTextList, getCompletionReport, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, ensureToolCallId, hasXMLParam, inferToolNameFromXMLParams, parseDSMLAttribute, extractDSMLReason, parseDSMLToolCallObjectFromText, parseXMLToolCallObjectFromText, parseDecisionObject, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, validateCompletionForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, tryParseAndValidateDecision, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, COMPLETION_TEXT_MAX_CHARS, COMPLETION_LIST_MAX_ITEMS, COMPLETION_EVIDENCE_MAX_ITEMS, EditFileAction -- 1
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
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 13
function isRecord(value) -- 15
	return type(value) == "table" -- 16
end -- 16
function isArray(value) -- 19
	return __TS__ArrayIsArray(value) -- 20
end -- 20
function emitAgentEvent(shared, event) -- 412
	if shared.onEvent then -- 412
		do -- 412
			local function ____catch(____error) -- 412
				Log( -- 417
					"Error", -- 417
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 417
				) -- 417
			end -- 417
			local ____try, ____hasReturned = pcall(function() -- 417
				shared:onEvent(event) -- 415
			end) -- 415
			if not ____try then -- 415
				____catch(____hasReturned) -- 415
			end -- 415
		end -- 415
	end -- 415
end -- 415
function getCancelledReason(shared) -- 586
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 586
		return shared.stopToken.reason -- 587
	end -- 587
	return shared.useChineseResponse and "已取消" or "cancelled" -- 588
end -- 588
function ____exports.normalizePolicyPath(path) -- 650
	local normalized = table.concat( -- 651
		__TS__StringSplit( -- 651
			__TS__StringTrim(path), -- 651
			"\\" -- 651
		), -- 651
		"/" -- 651
	) -- 651
	while __TS__StringStartsWith(normalized, "./") do -- 651
		normalized = string.sub(normalized, 3) -- 652
	end -- 652
	return normalized -- 653
end -- 650
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 661
	local normalized = ____exports.normalizePolicyPath(path) -- 662
	return normalized == ".agent/main" or __TS__StringStartsWith(normalized, ".agent/main/") -- 663
end -- 661
function truncateText(text, maxLen) -- 823
	if #text <= maxLen then -- 823
		return text -- 824
	end -- 824
	local nextPos = utf8.offset(text, maxLen + 1) -- 825
	if nextPos == nil then -- 825
		return text -- 826
	end -- 826
	return string.sub(text, 1, nextPos - 1) .. "..." -- 827
end -- 827
function utf8TakeHead(text, maxChars) -- 830
	if maxChars <= 0 or text == "" then -- 830
		return "" -- 831
	end -- 831
	local nextPos = utf8.offset(text, maxChars + 1) -- 832
	if nextPos == nil then -- 832
		return text -- 833
	end -- 833
	return string.sub(text, 1, nextPos - 1) -- 834
end -- 834
function getReplyLanguageDirective(shared) -- 837
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 838
end -- 838
function replacePromptVars(template, vars) -- 843
	local output = template -- 844
	for key in pairs(vars) do -- 845
		output = table.concat( -- 846
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 846
			vars[key] or "" or "," -- 846
		) -- 846
	end -- 846
	return output -- 848
end -- 848
function limitReadContentForHistory(content, tool) -- 851
	local lines = __TS__StringSplit(content, "\n") -- 852
	local overLineLimit = #lines > AgentConfig.AGENT_LIMITS.historyReadFileMaxLines -- 853
	local limitedByLines = overLineLimit and table.concat( -- 854
		__TS__ArraySlice(lines, 0, AgentConfig.AGENT_LIMITS.historyReadFileMaxLines), -- 855
		"\n" -- 855
	) or content -- 855
	if #limitedByLines <= AgentConfig.AGENT_LIMITS.historyReadFileMaxChars and not overLineLimit then -- 855
		return content -- 858
	end -- 858
	local limited = #limitedByLines > AgentConfig.AGENT_LIMITS.historyReadFileMaxChars and utf8TakeHead(limitedByLines, AgentConfig.AGENT_LIMITS.historyReadFileMaxChars) or limitedByLines -- 860
	local reasons = {} -- 863
	if #content > AgentConfig.AGENT_LIMITS.historyReadFileMaxChars then -- 863
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 864
	end -- 864
	if #lines > AgentConfig.AGENT_LIMITS.historyReadFileMaxLines then -- 864
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 865
	end -- 865
	local hint = "Narrow the requested line range." -- 866
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 867
end -- 867
function sanitizeReadResultForHistory(tool, result) -- 882
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 882
		return result -- 884
	end -- 884
	local clone = {} -- 886
	for key in pairs(result) do -- 887
		clone[key] = result[key] -- 888
	end -- 888
	clone.content = limitReadContentForHistory(result.content, tool) -- 890
	return clone -- 891
end -- 891
function sanitizeSearchMatchesForHistory(items, maxItems) -- 894
	local shown = math.min(#items, maxItems) -- 898
	local out = {} -- 899
	do -- 899
		local i = 0 -- 900
		while i < shown do -- 900
			local row = items[i + 1] -- 901
			out[#out + 1] = { -- 902
				file = row.file, -- 903
				line = row.line, -- 904
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 905
			} -- 905
			i = i + 1 -- 900
		end -- 900
	end -- 900
	return out -- 910
end -- 910
function sanitizeSearchResultForHistory(tool, result) -- 913
	if result.success ~= true or not isArray(result.results) then -- 913
		return result -- 917
	end -- 917
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 917
		return result -- 918
	end -- 918
	local clone = {} -- 919
	for key in pairs(result) do -- 920
		clone[key] = result[key] -- 921
	end -- 921
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 923
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 924
	if tool == "grep_files" and isArray(result.groupedResults) then -- 924
		local grouped = result.groupedResults -- 929
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 930
		local sanitizedGroups = {} -- 931
		do -- 931
			local i = 0 -- 932
			while i < shown do -- 932
				local row = grouped[i + 1] -- 933
				sanitizedGroups[#sanitizedGroups + 1] = { -- 934
					file = row.file, -- 935
					totalMatches = row.totalMatches, -- 936
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 937
				} -- 937
				i = i + 1 -- 932
			end -- 932
		end -- 932
		clone.groupedResults = sanitizedGroups -- 942
	end -- 942
	return clone -- 944
end -- 944
function sanitizeListFilesResultForHistory(result) -- 947
	if result.success ~= true or not isArray(result.files) then -- 947
		return result -- 948
	end -- 948
	local clone = {} -- 949
	for key in pairs(result) do -- 950
		clone[key] = result[key] -- 951
	end -- 951
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 953
	return clone -- 954
end -- 954
function sanitizeBuildResultForHistory(result) -- 957
	if not isArray(result.messages) then -- 957
		return result -- 958
	end -- 958
	local clone = {} -- 959
	for key in pairs(result) do -- 960
		clone[key] = result[key] -- 961
	end -- 961
	local messages = result.messages -- 963
	local ordered = __TS__ArraySort( -- 964
		__TS__ArraySlice(messages), -- 964
		function(____, a, b) -- 964
			local aFailed = a.success ~= true -- 965
			local bFailed = b.success ~= true -- 966
			if aFailed == bFailed then -- 966
				return 0 -- 967
			end -- 967
			return aFailed and -1 or 1 -- 968
		end -- 964
	) -- 964
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 970
	local sanitized = {} -- 971
	do -- 971
		local i = 0 -- 972
		while i < shown do -- 972
			local item = ordered[i + 1] -- 973
			local next = {} -- 974
			for key in pairs(item) do -- 975
				local value = item[key] -- 976
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 977
			end -- 977
			sanitized[#sanitized + 1] = next -- 981
			i = i + 1 -- 972
		end -- 972
	end -- 972
	clone.messages = sanitized -- 983
	if #ordered > shown then -- 983
		clone.truncatedMessages = #ordered - shown -- 985
	end -- 985
	return clone -- 987
end -- 987
function ____exports.getDecisionDisabledAgentTools(shared) -- 1005
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1009
end -- 1005
function getDecisionToolDefinitions(shared) -- 1012
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1013
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1014
	local base = shared.promptPack.toolDefinitionsDetailed -- 1017
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1018
	if usesDefaultToolPrompts then -- 1018
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1021
			shared.role, -- 1021
			{ -- 1021
				includeFinish = true, -- 1022
				includeXmlRules = true, -- 1023
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1024
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared) -- 1025
			} -- 1025
		) -- 1025
		return replacePromptVars(definitions, params) -- 1027
	end -- 1027
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1029
	if (shared and shared.decisionMode) ~= "xml" then -- 1029
		return withRole -- 1034
	end -- 1034
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1036
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1037
end -- 1037
function getFinishMessage(params, fallback) -- 1469
	if fallback == nil then -- 1469
		fallback = "" -- 1469
	end -- 1469
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1469
		return __TS__StringTrim(params.message) -- 1471
	end -- 1471
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1471
		return __TS__StringTrim(params.response) -- 1474
	end -- 1474
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1474
		return __TS__StringTrim(params.summary) -- 1477
	end -- 1477
	return __TS__StringTrim(fallback) -- 1479
end -- 1479
function normalizeCompletionText(value) -- 1486
	if type(value) ~= "string" then -- 1486
		return "" -- 1487
	end -- 1487
	return __TS__StringSlice( -- 1488
		__TS__StringTrim(sanitizeUTF8(value)), -- 1488
		0, -- 1488
		COMPLETION_TEXT_MAX_CHARS -- 1488
	) -- 1488
end -- 1488
function normalizeCompletionTextList(value, maxItems) -- 1491
	if maxItems == nil then -- 1491
		maxItems = COMPLETION_LIST_MAX_ITEMS -- 1491
	end -- 1491
	if not isArray(value) then -- 1491
		return {} -- 1492
	end -- 1492
	local items = {} -- 1493
	do -- 1493
		local i = 0 -- 1494
		while i < #value and #items < maxItems do -- 1494
			local item = normalizeCompletionText(value[i + 1]) -- 1495
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 1495
				items[#items + 1] = item -- 1496
			end -- 1496
			i = i + 1 -- 1494
		end -- 1494
	end -- 1494
	return items -- 1498
end -- 1498
function ____exports.normalizeAgentCompletionReport(value) -- 1501
	local row = value and not isArray(value) and isRecord(value) and value or ({}) -- 1502
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 1503
	local validation = {} -- 1506
	if isArray(row.validation) then -- 1506
		do -- 1506
			local i = 0 -- 1508
			while i < #row.validation and #validation < COMPLETION_LIST_MAX_ITEMS do -- 1508
				do -- 1508
					local raw = row.validation[i + 1] -- 1509
					if not raw or isArray(raw) or not isRecord(raw) then -- 1509
						goto __continue224 -- 1510
					end -- 1510
					local kind = (raw.kind == "runtime" or raw.kind == "manual") and raw.kind or (raw.kind == "build" and "build" or nil) -- 1511
					local result = (raw.result == "passed" or raw.result == "failed" or raw.result == "not_run") and raw.result or nil -- 1512
					if kind == nil or result == nil then -- 1512
						goto __continue224 -- 1513
					end -- 1513
					validation[#validation + 1] = { -- 1514
						kind = kind, -- 1515
						result = result, -- 1516
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS) -- 1517
					} -- 1517
				end -- 1517
				::__continue224:: -- 1517
				i = i + 1 -- 1508
			end -- 1508
		end -- 1508
	end -- 1508
	local learningCandidates = {} -- 1521
	if isArray(row.learningCandidates) then -- 1521
		do -- 1521
			local i = 0 -- 1523
			while i < #row.learningCandidates and #learningCandidates < COMPLETION_LIST_MAX_ITEMS do -- 1523
				do -- 1523
					local raw = row.learningCandidates[i + 1] -- 1524
					if not raw or isArray(raw) or not isRecord(raw) then -- 1524
						goto __continue229 -- 1525
					end -- 1525
					local claim = normalizeCompletionText(raw.claim) -- 1526
					if claim == "" then -- 1526
						goto __continue229 -- 1527
					end -- 1527
					learningCandidates[#learningCandidates + 1] = { -- 1528
						claim = claim, -- 1529
						scope = (raw.scope == "file" or raw.scope == "engine") and raw.scope or "project", -- 1530
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS), -- 1531
						confidence = raw.confidence == "inferred" and "inferred" or "observed" -- 1532
					} -- 1532
				end -- 1532
				::__continue229:: -- 1532
				i = i + 1 -- 1523
			end -- 1523
		end -- 1523
	end -- 1523
	return { -- 1536
		outcome = outcome, -- 1537
		validation = validation, -- 1538
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 1539
		assumptions = normalizeCompletionTextList(row.assumptions), -- 1540
		learningCandidates = learningCandidates -- 1541
	} -- 1541
end -- 1501
function getCompletionReport(params) -- 1545
	return ____exports.normalizeAgentCompletionReport(params) -- 1546
end -- 1546
function persistHistoryState(shared) -- 1549
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1550
end -- 1550
function getActiveConversationMessages(shared) -- 1557
	local activeMessages = {} -- 1558
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1558
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1565
	end -- 1565
	do -- 1565
		local i = shared.lastConsolidatedIndex -- 1569
		while i < #shared.messages do -- 1569
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1570
			i = i + 1 -- 1569
		end -- 1569
	end -- 1569
	return activeMessages -- 1572
end -- 1572
function getActiveRealMessageCount(shared) -- 1575
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1576
end -- 1576
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1579
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1585
	local previousActiveStart = shared.lastConsolidatedIndex -- 1586
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1587
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1588
	if type(carryMessageIndex) == "number" then -- 1588
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1588
		else -- 1588
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1596
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1599
		end -- 1599
	else -- 1599
		shared.carryMessageIndex = nil -- 1604
	end -- 1604
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1604
		shared.carryMessageIndex = nil -- 1614
	end -- 1614
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1622
	shared.resumeCheckpointPending = true -- 1623
	shared.resumeRequiredTool = nil -- 1624
	shared.resumeNarrowReadMode = true -- 1625
	if shared.unbuiltEdits == true then -- 1625
		shared.resumeRequiredTool = "build" -- 1633
	end -- 1633
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1642
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1642
		local marker = "**Next tool**:" -- 1653
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1654
		if markerIndex >= 0 then -- 1654
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1656
			local toolNames = { -- 1657
				"read_file", -- 1658
				"edit_file", -- 1658
				"delete_file", -- 1658
				"grep_files", -- 1658
				"search_dora_api", -- 1658
				"glob_files", -- 1659
				"build", -- 1659
				"fetch_url", -- 1659
				"execute_command", -- 1659
				"list_sub_agents", -- 1659
				"spawn_sub_agent", -- 1660
				"finish" -- 1660
			} -- 1660
			do -- 1660
				local i = 0 -- 1662
				while i < #toolNames do -- 1662
					local tool = toolNames[i + 1] -- 1663
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1663
						shared.resumeRequiredTool = tool -- 1665
						break -- 1666
					end -- 1666
					i = i + 1 -- 1662
				end -- 1662
			end -- 1662
		end -- 1662
	end -- 1662
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1662
		shared.resumeRequiredTool = nil -- 1672
	end -- 1672
end -- 1672
function ensureToolCallId(toolCallId) -- 1687
	if toolCallId and toolCallId ~= "" then -- 1687
		return toolCallId -- 1688
	end -- 1688
	return createLocalToolCallId() -- 1689
end -- 1689
function hasXMLParam(params, name) -- 1722
	return params[name] ~= nil -- 1723
end -- 1723
function inferToolNameFromXMLParams(params) -- 1726
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1726
		return "edit_file" -- 1728
	end -- 1728
	if hasXMLParam(params, "target_file") then -- 1728
		return "delete_file" -- 1731
	end -- 1731
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1731
		if hasXMLParam(params, "path") then -- 1731
			return "read_file" -- 1734
		end -- 1734
		return nil -- 1735
	end -- 1735
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1735
		if hasXMLParam(params, "pattern") then -- 1735
			return "search_dora_api" -- 1738
		end -- 1738
		return nil -- 1739
	end -- 1739
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1739
		if hasXMLParam(params, "pattern") then -- 1739
			return "grep_files" -- 1742
		end -- 1742
		return nil -- 1743
	end -- 1743
	if hasXMLParam(params, "globs") then -- 1743
		if hasXMLParam(params, "pattern") then -- 1743
			return "grep_files" -- 1746
		end -- 1746
		return "glob_files" -- 1747
	end -- 1747
	if hasXMLParam(params, "maxEntries") then -- 1747
		return "glob_files" -- 1750
	end -- 1750
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1750
		return "finish" -- 1753
	end -- 1753
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1753
		return "spawn_sub_agent" -- 1756
	end -- 1756
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1756
		return "list_sub_agents" -- 1759
	end -- 1759
	return nil -- 1761
end -- 1761
function parseDSMLAttribute(source, offset, name) -- 1764
	local attrOpen = name .. "=\"" -- 1765
	local attrStart = (string.find( -- 1766
		source, -- 1766
		attrOpen, -- 1766
		math.max(offset + 1, 1), -- 1766
		true -- 1766
	) or 0) - 1 -- 1766
	if attrStart < 0 then -- 1766
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1767
	end -- 1767
	local valueStart = attrStart + #attrOpen -- 1768
	local valueEnd = (string.find( -- 1769
		source, -- 1769
		"\"", -- 1769
		math.max(valueStart + 1, 1), -- 1769
		true -- 1769
	) or 0) - 1 -- 1769
	if valueEnd < 0 then -- 1769
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1770
	end -- 1770
	return { -- 1771
		success = true, -- 1772
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1773
		next = valueEnd + 1 -- 1774
	} -- 1774
end -- 1774
function extractDSMLReason(text, invokeStart, tool) -- 1778
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1779
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1780
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1780
		return before -- 1783
	end -- 1783
	if tool == "finish" then -- 1783
		return "" -- 1784
	end -- 1784
	return "Converted provider-native tool call syntax to XML." -- 1785
end -- 1785
function parseDSMLToolCallObjectFromText(text) -- 1788
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1789
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1790
	if invokeStart < 0 then -- 1790
		return {success = false, message = "missing DSML invoke"} -- 1791
	end -- 1791
	local nameStart = invokeStart + #invokeOpen -- 1792
	local nameEnd = (string.find( -- 1793
		text, -- 1793
		"\"", -- 1793
		math.max(nameStart + 1, 1), -- 1793
		true -- 1793
	) or 0) - 1 -- 1793
	if nameEnd < 0 then -- 1793
		return {success = false, message = "unterminated DSML invoke name"} -- 1794
	end -- 1794
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1795
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1795
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1797
	end -- 1797
	local invokeOpenEnd = (string.find( -- 1799
		text, -- 1799
		">", -- 1799
		math.max(nameEnd + 1, 1), -- 1799
		true -- 1799
	) or 0) - 1 -- 1799
	if invokeOpenEnd < 0 then -- 1799
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1800
	end -- 1800
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1801
	local invokeEnd = (string.find( -- 1802
		text, -- 1802
		invokeClose, -- 1802
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1802
		true -- 1802
	) or 0) - 1 -- 1802
	if invokeEnd < 0 then -- 1802
		return {success = false, message = "missing DSML invoke close tag"} -- 1803
	end -- 1803
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1805
	local params = {} -- 1806
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1807
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1808
	local pos = 0 -- 1809
	while pos < #body do -- 1809
		local start = (string.find( -- 1811
			body, -- 1811
			paramOpen, -- 1811
			math.max(pos + 1, 1), -- 1811
			true -- 1811
		) or 0) - 1 -- 1811
		if start < 0 then -- 1811
			break -- 1812
		end -- 1812
		local openEnd = (string.find( -- 1813
			body, -- 1813
			">", -- 1813
			math.max(start + #paramOpen + 1, 1), -- 1813
			true -- 1813
		) or 0) - 1 -- 1813
		if openEnd < 0 then -- 1813
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1814
		end -- 1814
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1815
		if not name.success then -- 1815
			return name -- 1816
		end -- 1816
		local close = (string.find( -- 1817
			body, -- 1817
			paramClose, -- 1817
			math.max(openEnd + 1 + 1, 1), -- 1817
			true -- 1817
		) or 0) - 1 -- 1817
		if close < 0 then -- 1817
			return {success = false, message = "missing DSML parameter close tag"} -- 1818
		end -- 1818
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1819
		pos = close + #paramClose -- 1820
	end -- 1820
	return { -- 1822
		success = true, -- 1823
		obj = { -- 1824
			tool = toolName, -- 1825
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1826
			params = params -- 1827
		} -- 1827
	} -- 1827
end -- 1827
function parseXMLToolCallObjectFromText(text) -- 1832
	local children = parseXMLObjectFromText(text, "tool_call") -- 1833
	local rawObj -- 1834
	if children.success then -- 1834
		rawObj = children.obj -- 1836
	else -- 1836
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1838
		if dsml.success then -- 1838
			return dsml -- 1839
		end -- 1839
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1840
		local paramsCloseToken = "</params>" -- 1841
		if toolStart >= 0 then -- 1841
			local paramsClose = (string.find( -- 1843
				text, -- 1843
				paramsCloseToken, -- 1843
				math.max(toolStart + 1, 1), -- 1843
				true -- 1843
			) or 0) - 1 -- 1843
			if paramsClose >= toolStart then -- 1843
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1845
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1846
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1846
					rawObj = bare.obj -- 1848
				end -- 1848
			end -- 1848
		end -- 1848
		if rawObj == nil then -- 1848
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1853
			if paramsOpen < 0 then -- 1853
				return children -- 1854
			end -- 1854
			local paramsCloseOnly = (string.find( -- 1855
				text, -- 1855
				paramsCloseToken, -- 1855
				math.max(paramsOpen + 1, 1), -- 1855
				true -- 1855
			) or 0) - 1 -- 1855
			if paramsCloseOnly < paramsOpen then -- 1855
				return children -- 1856
			end -- 1856
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1857
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1858
			if not paramsOnly.success then -- 1858
				return children -- 1859
			end -- 1859
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1860
			if inferredTool == nil then -- 1860
				return children -- 1861
			end -- 1861
			local ____temp_52 -- 1866
			if inferredTool == "finish" then -- 1866
				____temp_52 = nil -- 1866
			else -- 1866
				____temp_52 = "Inferred tool from XML params." -- 1866
			end -- 1866
			return {success = true, obj = {tool = inferredTool, reason = ____temp_52, params = paramsOnly.obj}} -- 1862
		end -- 1862
	end -- 1862
	if rawObj == nil then -- 1862
		return children -- 1872
	end -- 1872
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1873
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1874
	if not params.success then -- 1874
		return {success = false, message = params.message} -- 1878
	end -- 1878
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1880
end -- 1880
function parseDecisionObject(rawObj) -- 1976
	if type(rawObj.tool) ~= "string" then -- 1976
		return {success = false, message = "missing tool"} -- 1977
	end -- 1977
	local tool = rawObj.tool -- 1978
	if not AgentToolRegistry.isKnownToolName(tool) then -- 1978
		return {success = false, message = "unknown tool: " .. tool} -- 1980
	end -- 1980
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1982
	if tool ~= "finish" and (not reason or reason == "") then -- 1982
		return {success = false, message = tool .. " requires top-level reason"} -- 1986
	end -- 1986
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1988
	return {success = true, tool = tool, params = params, reason = reason} -- 1989
end -- 1989
function getDecisionPath(params) -- 2110
	if type(params.path) == "string" then -- 2110
		return __TS__StringTrim(params.path) -- 2111
	end -- 2111
	if type(params.target_file) == "string" then -- 2111
		return __TS__StringTrim(params.target_file) -- 2112
	end -- 2112
	return "" -- 2113
end -- 2113
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2116
	local num = __TS__Number(value) -- 2117
	if not __TS__NumberIsFinite(num) then -- 2117
		num = fallback -- 2118
	end -- 2118
	num = math.floor(num) -- 2119
	if num < minValue then -- 2119
		num = minValue -- 2120
	end -- 2120
	if maxValue ~= nil and num > maxValue then -- 2120
		num = maxValue -- 2121
	end -- 2121
	return num -- 2122
end -- 2122
function parseReadLineParam(value, fallback, paramName) -- 2125
	local num = __TS__Number(value) -- 2130
	if not __TS__NumberIsFinite(num) then -- 2130
		num = fallback -- 2131
	end -- 2131
	num = math.floor(num) -- 2132
	if num == 0 then -- 2132
		return {success = false, message = paramName .. " cannot be 0"} -- 2134
	end -- 2134
	return {success = true, value = num} -- 2136
end -- 2136
function validateDecision(tool, params) -- 2139
	if tool == "finish" then -- 2139
		local message = getFinishMessage(params) -- 2144
		if message == "" then -- 2144
			return {success = false, message = "finish requires params.message"} -- 2145
		end -- 2145
		params.message = message -- 2146
		local completion = getCompletionReport(params) -- 2147
		params.outcome = completion.outcome -- 2148
		params.validation = completion.validation -- 2149
		params.knownIssues = completion.knownIssues -- 2150
		params.assumptions = completion.assumptions -- 2151
		params.learningCandidates = completion.learningCandidates -- 2152
		return {success = true, params = params} -- 2153
	end -- 2153
	if tool == "read_file" then -- 2153
		local path = getDecisionPath(params) -- 2157
		if path == "" then -- 2157
			return {success = false, message = "read_file requires path"} -- 2158
		end -- 2158
		params.path = path -- 2159
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2160
		if not startLineRes.success then -- 2160
			return startLineRes -- 2161
		end -- 2161
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2162
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2163
		if not endLineRes.success then -- 2163
			return endLineRes -- 2164
		end -- 2164
		params.startLine = startLineRes.value -- 2165
		params.endLine = endLineRes.value -- 2166
		return {success = true, params = params} -- 2167
	end -- 2167
	if tool == "edit_file" then -- 2167
		local path = getDecisionPath(params) -- 2171
		if path == "" then -- 2171
			return {success = false, message = "edit_file requires path"} -- 2172
		end -- 2172
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2173
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2174
		params.path = path -- 2175
		params.old_str = oldStr -- 2176
		params.new_str = newStr -- 2177
		return {success = true, params = params} -- 2178
	end -- 2178
	if tool == "delete_file" then -- 2178
		local targetFile = getDecisionPath(params) -- 2182
		if targetFile == "" then -- 2182
			return {success = false, message = "delete_file requires target_file"} -- 2183
		end -- 2183
		params.target_file = targetFile -- 2184
		return {success = true, params = params} -- 2185
	end -- 2185
	if tool == "grep_files" then -- 2185
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2189
		if pattern == "" then -- 2189
			return {success = false, message = "grep_files requires pattern"} -- 2190
		end -- 2190
		params.pattern = pattern -- 2191
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2192
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2193
		return {success = true, params = params} -- 2194
	end -- 2194
	if tool == "search_dora_api" then -- 2194
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2198
		if pattern == "" then -- 2198
			return {success = false, message = "search_dora_api requires pattern"} -- 2199
		end -- 2199
		params.pattern = pattern -- 2200
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2201
		return {success = true, params = params} -- 2202
	end -- 2202
	if tool == "glob_files" then -- 2202
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2206
		return {success = true, params = params} -- 2207
	end -- 2207
	if tool == "build" then -- 2207
		local path = getDecisionPath(params) -- 2211
		if path ~= "" then -- 2211
			params.path = path -- 2213
		end -- 2213
		return {success = true, params = params} -- 2215
	end -- 2215
	if tool == "list_sub_agents" then -- 2215
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2219
		if status ~= "" then -- 2219
			params.status = status -- 2221
		end -- 2221
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2223
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2224
		if type(params.query) == "string" then -- 2224
			params.query = __TS__StringTrim(params.query) -- 2226
		end -- 2226
		return {success = true, params = params} -- 2228
	end -- 2228
	if tool == "spawn_sub_agent" then -- 2228
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2232
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2233
		if prompt == "" then -- 2233
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2234
		end -- 2234
		if title == "" then -- 2234
			return {success = false, message = "spawn_sub_agent requires title"} -- 2235
		end -- 2235
		params.prompt = prompt -- 2236
		params.title = title -- 2237
		if type(params.expectedOutput) == "string" then -- 2237
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2239
		end -- 2239
		if isArray(params.filesHint) then -- 2239
			params.filesHint = __TS__ArrayMap( -- 2242
				__TS__ArrayFilter( -- 2242
					params.filesHint, -- 2242
					function(____, item) return type(item) == "string" end -- 2243
				), -- 2243
				function(____, item) return sanitizeUTF8(item) end -- 2244
			) -- 2244
		end -- 2244
		return {success = true, params = params} -- 2246
	end -- 2246
	return {success = true, params = params} -- 2249
end -- 2249
function validateCompletionForRole(role, tool, params) -- 2252
	if role ~= "sub" or tool ~= "finish" then -- 2252
		return {success = true} -- 2257
	end -- 2257
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2257
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2259
	end -- 2259
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2261
	do -- 2261
		local i = 0 -- 2262
		while i < #requiredArrays do -- 2262
			local name = requiredArrays[i + 1] -- 2263
			if not isArray(params[name]) then -- 2263
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2265
			end -- 2265
			i = i + 1 -- 2262
		end -- 2262
	end -- 2262
	return {success = true} -- 2268
end -- 2268
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2271
	if includeToolDefinitions == nil then -- 2271
		includeToolDefinitions = false -- 2271
	end -- 2271
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2272
	local sections = { -- 2275
		shared.promptPack.agentIdentityPrompt, -- 2276
		rolePrompt, -- 2277
		getReplyLanguageDirective(shared) -- 2278
	} -- 2278
	if shared.decisionMode == "tool_calling" then -- 2278
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2281
	end -- 2281
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2283
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2284
	if memoryContext ~= "" then -- 2284
		sections[#sections + 1] = memoryContext -- 2286
	end -- 2286
	local skillsSection = buildSkillsSection(shared) -- 2288
	if skillsSection ~= "" then -- 2288
		sections[#sections + 1] = skillsSection -- 2290
	end -- 2290
	if includeToolDefinitions then -- 2290
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2293
		if shared.decisionMode == "xml" then -- 2293
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2295
		end -- 2295
	end -- 2295
	return table.concat(sections, "\n\n") -- 2298
end -- 2298
function buildSkillsSection(shared) -- 2301
	local ____opt_71 = shared.skills -- 2301
	if not (____opt_71 and ____opt_71.loader) then -- 2301
		return "" -- 2303
	end -- 2303
	return shared.skills.loader:buildSkillsPromptSection() -- 2305
end -- 2305
function buildXmlDecisionInstruction(shared, feedback) -- 2447
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2448
end -- 2448
function tryParseAndValidateDecision(rawText, role) -- 2530
	if role == nil then -- 2530
		role = "main" -- 2530
	end -- 2530
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2531
	if not parsed.success then -- 2531
		return {success = false, message = parsed.message, raw = rawText} -- 2533
	end -- 2533
	local decision = parseDecisionObject(parsed.obj) -- 2535
	if not decision.success then -- 2535
		return {success = false, message = decision.message, raw = rawText} -- 2537
	end -- 2537
	local completionValidation = validateCompletionForRole(role, decision.tool, decision.params) -- 2539
	if not completionValidation.success then -- 2539
		return {success = false, message = completionValidation.message, raw = rawText} -- 2541
	end -- 2541
	local validation = validateDecision(decision.tool, decision.params) -- 2543
	if not validation.success then -- 2543
		return {success = false, message = validation.message, raw = rawText} -- 2545
	end -- 2545
	decision.params = validation.params -- 2547
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2548
	return decision -- 2549
end -- 2549
function executeToolAction(shared, action) -- 3882
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3882
		if shared.stopToken.stopped then -- 3882
			return ____awaiter_resolve( -- 3882
				nil, -- 3882
				{ -- 3884
					success = false, -- 3884
					message = getCancelledReason(shared) -- 3884
				} -- 3884
			) -- 3884
		end -- 3884
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 3884
			shared.resumeRequiredTool = nil -- 3887
			shared.resumeCheckpointPending = false -- 3888
		end -- 3888
		local params = action.params -- 3890
		if action.tool == "read_file" then -- 3890
			local ____params_startLine_146 = params.startLine -- 3892
			if ____params_startLine_146 == nil then -- 3892
				____params_startLine_146 = 1 -- 3892
			end -- 3892
			local startLine = __TS__Number(____params_startLine_146) -- 3892
			local ____params_endLine_147 = params.endLine -- 3893
			if ____params_endLine_147 == nil then -- 3893
				____params_endLine_147 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3893
			end -- 3893
			local endLine = __TS__Number(____params_endLine_147) -- 3893
			local clippedAfterCompression = false -- 3894
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 3894
				endLine = startLine + 159 -- 3901
				clippedAfterCompression = true -- 3902
			end -- 3902
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3904
			if __TS__StringTrim(path) == "" then -- 3904
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3904
			end -- 3904
			local result = Tools.readFile( -- 3908
				shared.workingDir, -- 3909
				path, -- 3910
				startLine, -- 3911
				endLine, -- 3912
				shared.useChineseResponse and "zh" or "en" -- 3913
			) -- 3913
			if clippedAfterCompression and result.success == true then -- 3913
				result.clipped = true -- 3916
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 3917
			end -- 3917
			return ____awaiter_resolve(nil, result) -- 3917
		end -- 3917
		if action.tool ~= "build" then -- 3917
			shared.resumeNarrowReadMode = false -- 3927
		end -- 3927
		if action.tool == "grep_files" then -- 3927
			local searchPath = params.path or "" -- 3929
			local searchGlobs = params.globs -- 3930
			local ____Tools_searchFiles_161 = Tools.searchFiles -- 3931
			local ____shared_workingDir_154 = shared.workingDir -- 3932
			local ____temp_155 = params.pattern or "" -- 3934
			local ____params_globs_156 = params.globs -- 3935
			local ____params_useRegex_157 = params.useRegex -- 3936
			local ____params_caseSensitive_158 = params.caseSensitive -- 3937
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_159 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3939
			local ____math_max_150 = math.max -- 3940
			local ____math_floor_149 = math.floor -- 3940
			local ____params_limit_148 = params.limit -- 3940
			if ____params_limit_148 == nil then -- 3940
				____params_limit_148 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3940
			end -- 3940
			local ____math_max_150_result_160 = ____math_max_150( -- 3940
				1, -- 3940
				____math_floor_149(__TS__Number(____params_limit_148)) -- 3940
			) -- 3940
			local ____math_max_153 = math.max -- 3941
			local ____math_floor_152 = math.floor -- 3941
			local ____params_offset_151 = params.offset -- 3941
			if ____params_offset_151 == nil then -- 3941
				____params_offset_151 = 0 -- 3941
			end -- 3941
			local result = __TS__Await(____Tools_searchFiles_161({ -- 3931
				workDir = ____shared_workingDir_154, -- 3932
				path = searchPath, -- 3933
				pattern = ____temp_155, -- 3934
				globs = ____params_globs_156, -- 3935
				useRegex = ____params_useRegex_157, -- 3936
				caseSensitive = ____params_caseSensitive_158, -- 3937
				includeContent = true, -- 3938
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_159, -- 3939
				limit = ____math_max_150_result_160, -- 3940
				offset = ____math_max_153( -- 3941
					0, -- 3941
					____math_floor_152(__TS__Number(____params_offset_151)) -- 3941
				), -- 3941
				groupByFile = params.groupByFile == true -- 3942
			})) -- 3942
			return ____awaiter_resolve(nil, result) -- 3942
		end -- 3942
		if action.tool == "search_dora_api" then -- 3942
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 3947
			local ____Tools_searchDoraAPI_170 = Tools.searchDoraAPI -- 3948
			local ____temp_166 = params.pattern or "" -- 3949
			local ____temp_167 = params.docSource or "api" -- 3950
			local ____temp_168 = shared.useChineseResponse and "zh" or "en" -- 3951
			local ____temp_169 = params.programmingLanguage or "ts" -- 3952
			local ____math_min_165 = math.min -- 3953
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_164 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3953
			local ____math_max_163 = math.max -- 3953
			local ____params_limit_162 = params.limit -- 3953
			if ____params_limit_162 == nil then -- 3953
				____params_limit_162 = 8 -- 3953
			end -- 3953
			local result = __TS__Await(____Tools_searchDoraAPI_170({ -- 3948
				pattern = ____temp_166, -- 3949
				docSource = ____temp_167, -- 3950
				docLanguage = ____temp_168, -- 3951
				programmingLanguage = ____temp_169, -- 3952
				limit = ____math_min_165( -- 3953
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_164, -- 3953
					____math_max_163( -- 3953
						1, -- 3953
						__TS__Number(____params_limit_162) -- 3953
					) -- 3953
				), -- 3953
				useRegex = params.useRegex, -- 3954
				caseSensitive = false, -- 3955
				includeContent = true, -- 3956
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3957
			})) -- 3957
			return ____awaiter_resolve(nil, result) -- 3957
		end -- 3957
		if action.tool == "glob_files" then -- 3957
			local ____Tools_listFiles_177 = Tools.listFiles -- 3962
			local ____shared_workingDir_174 = shared.workingDir -- 3963
			local ____temp_175 = params.path or "" -- 3964
			local ____params_globs_176 = params.globs -- 3965
			local ____math_max_173 = math.max -- 3966
			local ____math_floor_172 = math.floor -- 3966
			local ____params_maxEntries_171 = params.maxEntries -- 3966
			if ____params_maxEntries_171 == nil then -- 3966
				____params_maxEntries_171 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3966
			end -- 3966
			local result = ____Tools_listFiles_177({ -- 3962
				workDir = ____shared_workingDir_174, -- 3963
				path = ____temp_175, -- 3964
				globs = ____params_globs_176, -- 3965
				maxEntries = ____math_max_173( -- 3966
					1, -- 3966
					____math_floor_172(__TS__Number(____params_maxEntries_171)) -- 3966
				) -- 3966
			}) -- 3966
			return ____awaiter_resolve(nil, result) -- 3966
		end -- 3966
		if action.tool == "delete_file" then -- 3966
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3971
			if __TS__StringTrim(targetFile) == "" then -- 3971
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3971
			end -- 3971
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 3975
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 3976
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 3976
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 3976
			end -- 3976
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3980
			if not result.success then -- 3980
				return ____awaiter_resolve(nil, result) -- 3980
			end -- 3980
			shared.unbuiltEdits = true -- 3987
			shared.lastBuildSucceeded = false -- 3988
			if shared.failedTestNeedsBuild == true then -- 3988
				shared.failedTestHasSourceEdit = true -- 3989
			end -- 3989
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 3989
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 3990
			end -- 3990
			shared.editedPathsSinceBuild = editedPaths -- 3991
			shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 3992
			return ____awaiter_resolve(nil, { -- 3992
				success = true, -- 3994
				changed = true, -- 3995
				mode = "delete", -- 3996
				checkpointId = result.checkpointId, -- 3997
				checkpointSeq = result.checkpointSeq, -- 3998
				files = {{path = targetFile, op = "delete"}} -- 3999
			}) -- 3999
		end -- 3999
		if action.tool == "build" then -- 3999
			local buildPath = params.path or "" -- 4003
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4004
			shared.unbuiltEdits = false -- 4008
			shared.editsSinceBuild = 0 -- 4009
			shared.editedPathsSinceBuild = {} -- 4010
			shared.hasBuilt = true -- 4011
			shared.lastBuildSucceeded = result.success -- 4012
			if result.success and shared.freshProjectBuildPending == true then -- 4012
				shared.freshProjectBuildPending = false -- 4018
			end -- 4018
			shared.apiSearchesSinceBuild = 0 -- 4020
			shared.buildRepairPending = false -- 4021
			if not result.success and result.messages ~= nil then -- 4021
				do -- 4021
					local i = 0 -- 4023
					while i < #result.messages do -- 4023
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4023
							shared.buildRepairPending = true -- 4025
							break -- 4026
						end -- 4026
						i = i + 1 -- 4023
					end -- 4023
				end -- 4023
			end -- 4023
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4023
				shared.failedTestNeedsBuild = false -- 4031
				shared.failedTestHasSourceEdit = false -- 4032
			end -- 4032
			return ____awaiter_resolve(nil, result) -- 4032
		end -- 4032
		if action.tool == "fetch_url" then -- 4032
			local result = __TS__Await(Tools.fetchUrl({ -- 4037
				workDir = shared.workingDir, -- 4038
				url = type(params.url) == "string" and params.url or "", -- 4039
				target = type(params.target) == "string" and params.target or "", -- 4040
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4041
				onProgress = function(____, progress) -- 4042
					emitAgentEvent( -- 4043
						shared, -- 4043
						{ -- 4043
							type = "tool_progress", -- 4044
							sessionId = shared.sessionId, -- 4045
							taskId = shared.taskId, -- 4046
							step = action.step, -- 4047
							tool = action.tool, -- 4048
							result = __TS__ObjectAssign({success = false}, progress) -- 4049
						} -- 4049
					) -- 4049
				end -- 4042
			})) -- 4042
			return ____awaiter_resolve(nil, result) -- 4042
		end -- 4042
		if action.tool == "execute_command" then -- 4042
			local mode = type(params.mode) == "string" and params.mode or "" -- 4059
			local result = __TS__Await(Tools.executeCommand({ -- 4060
				workDir = shared.workingDir, -- 4061
				mode = mode, -- 4062
				code = type(params.code) == "string" and params.code or nil, -- 4063
				command = type(params.command) == "string" and params.command or nil, -- 4064
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4065
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4066
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4067
				onProgress = function(____, progress) -- 4068
					emitAgentEvent( -- 4069
						shared, -- 4069
						{ -- 4069
							type = "tool_progress", -- 4070
							sessionId = shared.sessionId, -- 4071
							taskId = shared.taskId, -- 4072
							step = action.step, -- 4073
							tool = action.tool, -- 4074
							result = __TS__ObjectAssign({success = false}, progress) -- 4075
						} -- 4075
					) -- 4075
				end -- 4068
			})) -- 4068
			if result.success and mode == "lua" then -- 4068
				local deterministicFailure = false -- 4083
				local deterministicPass = false -- 4084
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4085
				do -- 4085
					local i = 0 -- 4086
					while i < #outputLines and not deterministicFailure do -- 4086
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4087
						if line == "passed" then -- 4087
							deterministicPass = true -- 4088
						end -- 4088
						if line == "failed" then -- 4088
							deterministicFailure = true -- 4090
							break -- 4091
						end -- 4091
						local searchFrom = 0 -- 4093
						while searchFrom < #line do -- 4093
							local failedIndex = (string.find( -- 4095
								line, -- 4095
								"failed", -- 4095
								math.max(searchFrom + 1, 1), -- 4095
								true -- 4095
							) or 0) - 1 -- 4095
							if failedIndex < 0 then -- 4095
								break -- 4096
							end -- 4096
							local after = failedIndex + #"failed" -- 4097
							while after < #line do -- 4097
								local ch = __TS__StringSlice(line, after, after + 1) -- 4099
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4099
									break -- 4100
								end -- 4100
								after = after + 1 -- 4101
							end -- 4101
							local afterEnd = after -- 4103
							while afterEnd < #line do -- 4103
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4105
								if ch < "0" or ch > "9" then -- 4105
									break -- 4106
								end -- 4106
								afterEnd = afterEnd + 1 -- 4107
							end -- 4107
							local count -- 4109
							if afterEnd > after then -- 4109
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4111
							else -- 4111
								local before = failedIndex - 1 -- 4113
								while before >= 0 do -- 4113
									local ch = __TS__StringSlice(line, before, before + 1) -- 4115
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4115
										break -- 4116
									end -- 4116
									before = before - 1 -- 4117
								end -- 4117
								local beforeEnd = before + 1 -- 4119
								while before >= 0 do -- 4119
									local ch = __TS__StringSlice(line, before, before + 1) -- 4121
									if ch < "0" or ch > "9" then -- 4121
										break -- 4122
									end -- 4122
									before = before - 1 -- 4123
								end -- 4123
								if beforeEnd > before + 1 then -- 4123
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4125
								end -- 4125
							end -- 4125
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4125
								deterministicFailure = true -- 4128
								break -- 4129
							end -- 4129
							searchFrom = failedIndex + #"failed" -- 4131
						end -- 4131
						i = i + 1 -- 4086
					end -- 4086
				end -- 4086
				if deterministicFailure then -- 4086
					shared.failedTestNeedsBuild = true -- 4135
					shared.failedTestHasSourceEdit = false -- 4136
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4137
				elseif deterministicPass then -- 4137
					shared.deterministicTestFailureCount = 0 -- 4139
				end -- 4139
			end -- 4139
			return ____awaiter_resolve(nil, result) -- 4139
		end -- 4139
		if action.tool == "spawn_sub_agent" then -- 4139
			if not shared.spawnSubAgent then -- 4139
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4139
			end -- 4139
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4139
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4139
			end -- 4139
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4151
				params.filesHint, -- 4152
				function(____, item) return type(item) == "string" end -- 4152
			) or nil -- 4152
			local result = __TS__Await(shared.spawnSubAgent({ -- 4154
				parentSessionId = shared.sessionId, -- 4155
				projectRoot = shared.workingDir, -- 4156
				title = type(params.title) == "string" and params.title or "Sub", -- 4157
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4158
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4159
				filesHint = filesHint, -- 4160
				disabledAgentTools = shared.disabledAgentTools -- 4161
			})) -- 4161
			if not result.success then -- 4161
				return ____awaiter_resolve(nil, result) -- 4161
			end -- 4161
			shared.hasSpawnedSubAgentThisTask = true -- 4166
			return ____awaiter_resolve(nil, { -- 4166
				success = true, -- 4168
				sessionId = result.sessionId, -- 4169
				taskId = result.taskId, -- 4170
				title = result.title, -- 4171
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4172
			}) -- 4172
		end -- 4172
		if action.tool == "list_sub_agents" then -- 4172
			if not shared.listSubAgents then -- 4172
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4172
			end -- 4172
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4172
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4172
			end -- 4172
			local result = __TS__Await(shared.listSubAgents({ -- 4182
				sessionId = shared.sessionId, -- 4183
				projectRoot = shared.workingDir, -- 4184
				status = type(params.status) == "string" and params.status or nil, -- 4185
				limit = type(params.limit) == "number" and params.limit or nil, -- 4186
				offset = type(params.offset) == "number" and params.offset or nil, -- 4187
				query = type(params.query) == "string" and params.query or nil -- 4188
			})) -- 4188
			return ____awaiter_resolve(nil, result) -- 4188
		end -- 4188
		if action.tool == "edit_file" then -- 4188
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4193
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4196
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4197
			if __TS__StringTrim(path) == "" then -- 4197
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4197
			end -- 4197
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4199
			local isMemoryEdit = ____exports.isMainAgentMemoryPath(normalizedPath) -- 4200
			if not isMemoryEdit then -- 4200
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4202
				if preflightIssue ~= nil then -- 4202
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4204
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4205
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4205
				end -- 4205
			end -- 4205
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4211
			local result = __TS__Await(actionNode:exec({ -- 4212
				path = path, -- 4213
				oldStr = oldStr, -- 4214
				newStr = newStr, -- 4215
				taskId = shared.taskId, -- 4216
				workDir = shared.workingDir -- 4217
			})) -- 4217
			if not isMemoryEdit and result.success == true and result.changed ~= false then -- 4217
				if params.partialStreamRecovery ~= true then -- 4217
					shared.truncatedToolOverwritePath = nil -- 4221
				end -- 4221
				shared.unbuiltEdits = true -- 4223
				shared.lastBuildSucceeded = false -- 4224
				if shared.failedTestNeedsBuild == true then -- 4224
					shared.failedTestHasSourceEdit = true -- 4225
				end -- 4225
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4226
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4226
					editedPaths[#editedPaths + 1] = normalizedPath -- 4227
				end -- 4227
				shared.editedPathsSinceBuild = editedPaths -- 4228
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4229
			end -- 4229
			return ____awaiter_resolve(nil, result) -- 4229
		end -- 4229
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4229
	end) -- 4229
end -- 4229
function sanitizeToolActionResultForHistory(action, result) -- 4236
	if action.tool == "read_file" then -- 4236
		return sanitizeReadResultForHistory(action.tool, result) -- 4238
	end -- 4238
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4238
		return sanitizeSearchResultForHistory(action.tool, result) -- 4241
	end -- 4241
	if action.tool == "glob_files" then -- 4241
		return sanitizeListFilesResultForHistory(result) -- 4244
	end -- 4244
	if action.tool == "build" then -- 4244
		return sanitizeBuildResultForHistory(result) -- 4247
	end -- 4247
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4247
		if result.success ~= true then -- 4247
			return result -- 4250
		end -- 4250
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4250
			return result -- 4251
		end -- 4251
		if isArray(result.fileContext) then -- 4251
			return result -- 4252
		end -- 4252
		local contextLimits = { -- 4254
			fullContentChars = 12000, -- 4255
			previewChars = 4000, -- 4256
			diffChars = 8000, -- 4257
			totalChars = 24000, -- 4258
			maxFiles = 8 -- 4259
		} -- 4259
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4261
			if maxChars <= 0 then -- 4261
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4262
			end -- 4262
			if #sourceText <= maxChars then -- 4262
				return sourceText -- 4263
			end -- 4263
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4264
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4265
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4266
		end -- 4261
		local function countLines(sourceText) -- 4268
			if sourceText == "" then -- 4268
				return 0 -- 4269
			end -- 4269
			return #__TS__StringSplit(sourceText, "\n") -- 4270
		end -- 4268
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4272
			if beforeContent == afterContent then -- 4272
				return "" -- 4273
			end -- 4273
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4274
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4275
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4277
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4277
				firstChangedLine = firstChangedLine + 1 -- 4283
			end -- 4283
			local lastChangedBeforeLine = #beforeLines - 1 -- 4285
			local lastChangedAfterLine = #afterLines - 1 -- 4286
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4286
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4292
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4293
			end -- 4293
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4295
			local previewEndLine = math.max( -- 4296
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4297
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4298
			) -- 4298
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4300
			do -- 4300
				local lineIndex = previewStartLine -- 4301
				while lineIndex <= previewEndLine do -- 4301
					do -- 4301
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4302
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4303
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4304
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4305
						if not beforeChanged and not afterChanged then -- 4305
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4307
							if contextLine ~= nil then -- 4307
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4308
							end -- 4308
							goto __continue705 -- 4309
						end -- 4309
						if beforeChanged and beforeLine ~= nil then -- 4309
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4311
						end -- 4311
						if afterChanged and afterLine ~= nil then -- 4311
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4312
						end -- 4312
					end -- 4312
					::__continue705:: -- 4312
					lineIndex = lineIndex + 1 -- 4301
				end -- 4301
			end -- 4301
			return truncateContextSnippet( -- 4314
				table.concat(unifiedDiffLines, "\n"), -- 4314
				maxChars, -- 4314
				"diff" -- 4314
			) -- 4314
		end -- 4272
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4317
		if not checkpointDiff.success then -- 4317
			return result -- 4318
		end -- 4318
		local remainingContextBudget = contextLimits.totalChars -- 4319
		local fileContextItems = {} -- 4320
		local changedFiles = checkpointDiff.files -- 4321
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4322
		do -- 4322
			local fileIndex = 0 -- 4323
			while fileIndex < maxContextFiles do -- 4323
				if remainingContextBudget <= 0 then -- 4323
					break -- 4324
				end -- 4324
				local changedFile = changedFiles[fileIndex + 1] -- 4325
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4326
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4327
				local contextItem = { -- 4328
					path = changedFile.path, -- 4329
					op = changedFile.op, -- 4330
					checkpointId = result.checkpointId, -- 4331
					checkpointSeq = result.checkpointSeq, -- 4332
					beforeExists = changedFile.beforeExists, -- 4333
					afterExists = changedFile.afterExists, -- 4334
					beforeBytes = #beforeContent, -- 4335
					afterBytes = #afterContent, -- 4336
					diffPreview = "", -- 4337
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4338
					contentTruncated = false, -- 4339
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4340
				} -- 4340
				if changedFile.afterExists then -- 4340
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4340
						contextItem.afterContent = afterContent -- 4344
						remainingContextBudget = remainingContextBudget - #afterContent -- 4345
					else -- 4345
						contextItem.afterContentPreview = truncateContextSnippet( -- 4347
							afterContent, -- 4348
							math.min( -- 4349
								contextLimits.previewChars, -- 4349
								math.max(400, remainingContextBudget) -- 4349
							), -- 4349
							"afterContent" -- 4350
						) -- 4350
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4352
						contextItem.contentTruncated = true -- 4353
					end -- 4353
				end -- 4353
				local diffPreview = buildUnifiedDiffPreview( -- 4356
					changedFile.path, -- 4357
					beforeContent, -- 4358
					afterContent, -- 4359
					math.min( -- 4360
						contextLimits.diffChars, -- 4360
						math.max(400, remainingContextBudget) -- 4360
					) -- 4360
				) -- 4360
				contextItem.diffPreview = diffPreview -- 4362
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4363
				if not changedFile.afterExists and beforeContent ~= "" then -- 4363
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4365
						beforeContent, -- 4366
						math.min( -- 4367
							contextLimits.previewChars, -- 4367
							math.max(400, remainingContextBudget) -- 4367
						), -- 4367
						"beforeContent" -- 4368
					) -- 4368
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4370
					if #beforeContent > contextLimits.previewChars then -- 4370
						contextItem.contentTruncated = true -- 4371
					end -- 4371
				end -- 4371
				fileContextItems[#fileContextItems + 1] = contextItem -- 4373
				fileIndex = fileIndex + 1 -- 4323
			end -- 4323
		end -- 4323
		if #fileContextItems == 0 then -- 4323
			return result -- 4375
		end -- 4375
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4376
	end -- 4376
	return result -- 4383
end -- 4383
function emitAgentTaskFinishEvent(shared, success, message) -- 4568
	local completion = shared.completion or ____exports.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4569
	local result = success and ({ -- 4573
		success = true, -- 4575
		taskId = shared.taskId, -- 4576
		message = message, -- 4577
		steps = shared.step, -- 4578
		completion = completion -- 4579
	}) or ({ -- 4579
		success = false, -- 4582
		taskId = shared.taskId, -- 4583
		message = message, -- 4584
		steps = shared.step, -- 4585
		completion = completion -- 4586
	}) -- 4586
	emitAgentEvent(shared, { -- 4588
		type = "task_finished", -- 4589
		sessionId = shared.sessionId, -- 4590
		taskId = shared.taskId, -- 4591
		success = result.success, -- 4592
		message = result.message, -- 4593
		steps = result.steps, -- 4594
		completion = result.completion -- 4595
	}) -- 4595
	return result -- 4597
end -- 4597
local function buildLLMOptions(llmConfig, overrides) -- 274
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 275
	if llmConfig.reasoningEffort then -- 275
		options.reasoning_effort = llmConfig.reasoningEffort -- 280
	end -- 280
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 282
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 282
		__TS__Delete(merged, "reasoning_effort") -- 287
	else -- 287
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 289
	end -- 289
	__TS__Delete(merged, "tool_choice") -- 294
	return merged -- 295
end -- 274
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 422
	local messagesTokens = 0 -- 429
	do -- 429
		local i = 0 -- 430
		while i < #messages do -- 430
			local message = messages[i + 1] -- 431
			messagesTokens = messagesTokens + 8 -- 432
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 433
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 434
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 435
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 436
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 437
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 438
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 439
			i = i + 1 -- 430
		end -- 430
	end -- 430
	local toolDefinitionsTokens = 0 -- 442
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 442
		local toolsText = safeJsonEncode(options.tools) -- 444
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 445
	end -- 445
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 448
	__TS__Delete(optionsWithoutTools, "tools") -- 449
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 450
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 451
	local contextWindow = shared.llmConfig.contextWindow > 0 and math.floor(shared.llmConfig.contextWindow) or 64000 -- 452
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 455
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 460
		1024, -- 462
		math.floor(contextWindow * 0.2) -- 462
	) -- 462
	local structuralOverhead = math.max(256, #messages * 16) -- 463
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 465
	local maxTokens = contextWindow -- 466
	emitAgentEvent( -- 467
		shared, -- 467
		{ -- 467
			type = "metrics_updated", -- 468
			sessionId = shared.sessionId, -- 469
			taskId = shared.taskId, -- 470
			step = step, -- 471
			metrics = {context = { -- 472
				usedTokens = usedTokens, -- 474
				maxTokens = maxTokens, -- 475
				ratio = math.max( -- 476
					0, -- 476
					math.min(1, usedTokens / maxTokens) -- 476
				), -- 476
				messagesTokens = messagesTokens, -- 477
				optionsTokens = optionsTokens, -- 478
				toolDefinitionsTokens = toolDefinitionsTokens, -- 479
				reservedOutputTokens = reservedOutputTokens, -- 480
				structuralOverhead = structuralOverhead, -- 481
				contextWindow = contextWindow, -- 482
				source = "llm_input_estimate", -- 483
				updatedAt = os.time(), -- 484
				phase = phase, -- 485
				step = step -- 486
			}} -- 486
		} -- 486
	) -- 486
end -- 422
local function recordLLMTokenUsage(shared, step, phase, usage) -- 492
	if not usage then -- 492
		return -- 493
	end -- 493
	local current = shared.tokenUsage -- 494
	local cachedReported = usage.cachedInputTokens ~= nil -- 495
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 496
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 497
	local next = { -- 498
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 499
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 500
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 501
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 502
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 505
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 508
		requestCount = (current and current.requestCount or 0) + 1, -- 511
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 512
		model = shared.llmConfig.model, -- 515
		phase = phase, -- 516
		step = step, -- 517
		updatedAt = os.time() -- 518
	} -- 518
	shared.tokenUsage = next -- 520
	emitAgentEvent(shared, { -- 521
		type = "metrics_updated", -- 522
		sessionId = shared.sessionId, -- 523
		taskId = shared.taskId, -- 524
		step = step, -- 525
		metrics = {usage = next} -- 526
	}) -- 526
end -- 492
local function emitAgentStartEvent(shared, action) -- 530
	emitAgentEvent(shared, { -- 531
		type = "tool_started", -- 532
		sessionId = shared.sessionId, -- 533
		taskId = shared.taskId, -- 534
		step = action.step, -- 535
		tool = action.tool -- 536
	}) -- 536
end -- 530
local function emitAgentFinishEvent(shared, action) -- 540
	emitAgentEvent(shared, { -- 541
		type = "tool_finished", -- 542
		sessionId = shared.sessionId, -- 543
		taskId = shared.taskId, -- 544
		step = action.step, -- 545
		tool = action.tool, -- 546
		result = action.result or ({}) -- 547
	}) -- 547
end -- 540
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 551
	emitAgentEvent(shared, { -- 552
		type = "assistant_message_updated", -- 553
		sessionId = shared.sessionId, -- 554
		taskId = shared.taskId, -- 555
		step = shared.step + 1, -- 556
		content = content, -- 557
		reasoningContent = reasoningContent -- 558
	}) -- 558
end -- 551
local function getMemoryCompressionStartReason(shared) -- 562
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 563
end -- 562
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 568
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 569
end -- 568
local function getMemoryCompressionFailureReason(shared, ____error) -- 574
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 575
end -- 574
local function summarizeHistoryEntryPreview(text, maxChars) -- 580
	if maxChars == nil then -- 580
		maxChars = 180 -- 580
	end -- 580
	local trimmed = __TS__StringTrim(text) -- 581
	if trimmed == "" then -- 581
		return "" -- 582
	end -- 582
	return truncateText(trimmed, maxChars) -- 583
end -- 580
local function getMaxStepsReachedReason(shared) -- 591
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 592
end -- 591
local function getFailureSummaryFallback(shared, ____error) -- 597
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 598
end -- 597
local function finalizeAgentFailure(shared, ____error) -- 603
	if shared.stopToken.stopped then -- 603
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 605
		return emitAgentTaskFinishEvent( -- 606
			shared, -- 606
			false, -- 606
			getCancelledReason(shared) -- 606
		) -- 606
	end -- 606
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 608
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 609
end -- 603
local function getPromptCommand(prompt) -- 612
	local trimmed = __TS__StringTrim(prompt) -- 613
	if trimmed == "/compact" then -- 613
		return "compact" -- 614
	end -- 614
	if trimmed == "/clear" then -- 614
		return "clear" -- 615
	end -- 615
	return nil -- 616
end -- 612
function ____exports.truncateAgentUserPrompt(prompt) -- 619
	if not prompt then -- 619
		return "" -- 620
	end -- 620
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 620
		return prompt -- 621
	end -- 621
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 622
	if offset == nil then -- 622
		return prompt -- 623
	end -- 623
	return string.sub(prompt, 1, offset - 1) -- 624
end -- 619
local function canWriteStepLLMDebug(shared, stepId) -- 627
	if stepId == nil then -- 627
		stepId = shared.step + 1 -- 627
	end -- 627
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 628
end -- 627
local function ensureDirRecursive(dir) -- 635
	if not dir then -- 635
		return false -- 636
	end -- 636
	if Content:exist(dir) then -- 636
		return Content:isdir(dir) -- 637
	end -- 637
	local parent = Path:getPath(dir) -- 638
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 638
		return false -- 640
	end -- 640
	return Content:mkdir(dir) -- 642
end -- 635
local function encodeDebugJSON(value) -- 645
	local text, err = safeJsonEncode(value) -- 646
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 647
end -- 645
local FRESH_PROJECT_CODE_GLOBS = { -- 666
	"**/*.ts", -- 667
	"**/*.tsx", -- 668
	"**/*.lua", -- 669
	"**/*.yue", -- 670
	"**/*.tl", -- 671
	"**/*.yarn", -- 672
	"**/*.xml", -- 673
	"!**/*.d.ts" -- 674
} -- 674
local function inspectFreshProject(workDir) -- 677
	local result = Tools.listFiles({workDir = workDir, path = "", globs = FRESH_PROJECT_CODE_GLOBS, maxEntries = 2}) -- 678
	if not result.success then -- 678
		return {fresh = false} -- 684
	end -- 684
	local totalEntries = result.totalEntries or #result.files -- 685
	if totalEntries > 1 then -- 685
		return {fresh = false} -- 686
	end -- 686
	if totalEntries == 0 then -- 686
		return {fresh = true} -- 687
	end -- 687
	if #result.files ~= 1 then -- 687
		return {fresh = false} -- 688
	end -- 688
	local path = result.files[1] -- 689
	local loaded = Tools.readFileRaw(workDir, path) -- 690
	if not loaded.success or loaded.content == nil then -- 690
		return {fresh = false} -- 691
	end -- 691
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 692
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 695
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 696
end -- 677
local function getStepLLMDebugDir(shared) -- 699
	return Path( -- 700
		shared.workingDir, -- 701
		".agent", -- 702
		tostring(shared.sessionId), -- 703
		tostring(shared.taskId) -- 704
	) -- 704
end -- 699
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 708
	return Path( -- 709
		getStepLLMDebugDir(shared), -- 709
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 709
	) -- 709
end -- 708
local function getLatestStepLLMDebugSeq(shared, stepId) -- 712
	if not canWriteStepLLMDebug(shared, stepId) then -- 712
		return 0 -- 713
	end -- 713
	local dir = getStepLLMDebugDir(shared) -- 714
	if not Content:exist(dir) or not Content:isdir(dir) then -- 714
		return 0 -- 715
	end -- 715
	local latest = 0 -- 716
	for ____, file in ipairs(Content:getFiles(dir)) do -- 717
		do -- 717
			local name = Path:getFilename(file) -- 718
			local seqText = string.match( -- 719
				name, -- 719
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 719
			) -- 719
			if seqText ~= nil then -- 719
				latest = math.max( -- 721
					latest, -- 721
					tonumber(seqText) -- 721
				) -- 721
				goto __continue59 -- 722
			end -- 722
			local legacyMatch = string.match( -- 724
				name, -- 724
				("^" .. tostring(stepId)) .. "_in%.md$" -- 724
			) -- 724
			if legacyMatch ~= nil then -- 724
				latest = math.max(latest, 1) -- 726
			end -- 726
		end -- 726
		::__continue59:: -- 726
	end -- 726
	return latest -- 729
end -- 712
local function writeStepLLMDebugFile(path, content) -- 732
	if not Content:save(path, content) then -- 732
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 734
		return false -- 735
	end -- 735
	return true -- 737
end -- 732
local function createStepLLMDebugPair(shared, stepId, inContent) -- 740
	if not canWriteStepLLMDebug(shared, stepId) then -- 740
		return 0 -- 741
	end -- 741
	local dir = getStepLLMDebugDir(shared) -- 742
	if not ensureDirRecursive(dir) then -- 742
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 744
		return 0 -- 745
	end -- 745
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 747
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 748
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 749
	if not writeStepLLMDebugFile(inPath, inContent) then -- 749
		return 0 -- 751
	end -- 751
	writeStepLLMDebugFile(outPath, "") -- 753
	return seq -- 754
end -- 740
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 757
	if not canWriteStepLLMDebug(shared, stepId) then -- 757
		return -- 758
	end -- 758
	local dir = getStepLLMDebugDir(shared) -- 759
	if not ensureDirRecursive(dir) then -- 759
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 761
		return -- 762
	end -- 762
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 764
	if latestSeq <= 0 then -- 764
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 766
		writeStepLLMDebugFile(outPath, content) -- 767
		return -- 768
	end -- 768
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 770
	writeStepLLMDebugFile(outPath, content) -- 771
end -- 757
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 774
	if not canWriteStepLLMDebug(shared, stepId) then -- 774
		return -- 775
	end -- 775
	local sections = { -- 776
		"# LLM Input", -- 777
		"session_id: " .. tostring(shared.sessionId), -- 778
		"task_id: " .. tostring(shared.taskId), -- 779
		"step_id: " .. tostring(stepId), -- 780
		"phase: " .. phase, -- 781
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 782
		"## Options", -- 783
		"```json", -- 784
		encodeDebugJSON(options), -- 785
		"```" -- 786
	} -- 786
	local firstMessage = #messages > 0 and messages[1] or nil -- 788
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 788
		sections[#sections + 1] = "# System Prompt" -- 790
		sections[#sections + 1] = firstMessage.content -- 791
	end -- 791
	do -- 791
		local i = 0 -- 793
		while i < #messages do -- 793
			local message = messages[i + 1] -- 794
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 795
			sections[#sections + 1] = encodeDebugJSON(message) -- 796
			i = i + 1 -- 793
		end -- 793
	end -- 793
	createStepLLMDebugPair( -- 798
		shared, -- 798
		stepId, -- 798
		table.concat(sections, "\n") -- 798
	) -- 798
end -- 774
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 801
	if not canWriteStepLLMDebug(shared, stepId) then -- 801
		return -- 802
	end -- 802
	local ____array_24 = __TS__SparseArrayNew( -- 802
		"# LLM Output", -- 804
		"session_id: " .. tostring(shared.sessionId), -- 805
		"task_id: " .. tostring(shared.taskId), -- 806
		"step_id: " .. tostring(stepId), -- 807
		"phase: " .. phase, -- 808
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 809
		table.unpack(meta and ({ -- 810
			"## Meta", -- 810
			"```json", -- 810
			encodeDebugJSON(meta), -- 810
			"```" -- 810
		}) or ({})) -- 810
	) -- 810
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 810
	local sections = {__TS__SparseArraySpread(____array_24)} -- 803
	updateLatestStepLLMDebugOutput( -- 814
		shared, -- 814
		stepId, -- 814
		table.concat(sections, "\n") -- 814
	) -- 814
end -- 801
local function toJson(value, emptyAsArray) -- 817
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 818
	if text ~= nil then -- 818
		return text -- 819
	end -- 819
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 820
end -- 817
local function summarizeEditTextParamForHistory(value, key) -- 870
	if type(value) ~= "string" then -- 870
		return nil -- 871
	end -- 871
	local text = value -- 872
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 873
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 874
end -- 870
local function sanitizeActionParamsForHistory(tool, params) -- 990
	if tool ~= "edit_file" then -- 990
		return params -- 991
	end -- 991
	local clone = {} -- 992
	for key in pairs(params) do -- 993
		if key == "old_str" then -- 993
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 995
		elseif key == "new_str" then -- 995
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 997
		else -- 997
			clone[key] = params[key] -- 999
		end -- 999
	end -- 999
	return clone -- 1002
end -- 990
local function getDecisionToolSchemaText(shared) -- 1043
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1044
		shared.role, -- 1044
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1044
		{disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared)} -- 1044
	)) -- 1044
	return toolsText or "" -- 1047
end -- 1043
local function isToolAllowedForRole(shared, tool) -- 1050
	return __TS__ArrayIndexOf( -- 1051
		AgentToolRegistry.getAllowedToolsForRole( -- 1051
			shared.role, -- 1051
			{disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared)} -- 1051
		), -- 1051
		tool -- 1053
	) >= 0 -- 1053
end -- 1050
local function clearPreExecutedResults(shared) -- 1056
	shared.preExecutedResults = nil -- 1057
end -- 1056
local function startPreExecutedToolAction(shared, action) -- 1060
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1060
		local ____hasReturned, ____returnValue -- 1060
		local ____try = __TS__AsyncAwaiter(function() -- 1060
			____hasReturned = true -- 1062
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1062
			return -- 1062
		end) -- 1062
		____try = ____try.catch( -- 1062
			____try, -- 1062
			function(____, err) -- 1062
				return __TS__AsyncAwaiter(function() -- 1062
					local message = tostring(err) -- 1064
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1065
					____hasReturned = true -- 1066
					____returnValue = {success = false, message = message} -- 1066
					return -- 1066
				end) -- 1066
			end -- 1066
		) -- 1066
		__TS__Await(____try) -- 1061
		if ____hasReturned then -- 1061
			return ____awaiter_resolve(nil, ____returnValue) -- 1061
		end -- 1061
	end) -- 1061
end -- 1060
local function createPreExecutedToolResult(shared, action) -- 1070
	local cloneParamValue -- 1071
	cloneParamValue = function(value) -- 1071
		if value == nil then -- 1071
			return value -- 1072
		end -- 1072
		if isArray(value) then -- 1072
			return __TS__ArrayMap( -- 1074
				value, -- 1074
				function(____, item) return cloneParamValue(item) end -- 1074
			) -- 1074
		end -- 1074
		if type(value) == "table" then -- 1074
			local clone = {} -- 1077
			for key in pairs(value) do -- 1078
				clone[key] = cloneParamValue(value[key]) -- 1079
			end -- 1079
			return clone -- 1081
		end -- 1081
		return value -- 1083
	end -- 1071
	local params = cloneParamValue(action.params) -- 1085
	local areParamValuesEqual -- 1086
	areParamValuesEqual = function(left, right) -- 1086
		if left == right then -- 1086
			return true -- 1087
		end -- 1087
		if left == nil or right == nil then -- 1087
			return false -- 1088
		end -- 1088
		if isArray(left) or isArray(right) then -- 1088
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1088
				return false -- 1090
			end -- 1090
			do -- 1090
				local i = 0 -- 1091
				while i < #left do -- 1091
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1091
						return false -- 1092
					end -- 1092
					i = i + 1 -- 1091
				end -- 1091
			end -- 1091
			return true -- 1094
		end -- 1094
		if type(left) == "table" and type(right) == "table" then -- 1094
			local leftCount = 0 -- 1097
			for key in pairs(left) do -- 1098
				leftCount = leftCount + 1 -- 1099
				if not areParamValuesEqual(left[key], right[key]) then -- 1099
					return false -- 1104
				end -- 1104
			end -- 1104
			local rightCount = 0 -- 1107
			for key in pairs(right) do -- 1108
				rightCount = rightCount + 1 -- 1109
			end -- 1109
			return leftCount == rightCount -- 1111
		end -- 1111
		return false -- 1113
	end -- 1086
	return { -- 1115
		action = action, -- 1116
		matches = function(self, nextAction) -- 1117
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1118
		end, -- 1117
		promise = startPreExecutedToolAction(shared, action) -- 1120
	} -- 1120
end -- 1070
local function executeToolActionWithPreExecution(shared, action) -- 1124
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1124
		local ____opt_27 = shared.preExecutedResults -- 1124
		local preResult = ____opt_27 and ____opt_27:get(action.toolCallId) -- 1125
		local result -- 1126
		if preResult then -- 1126
			local ____opt_29 = shared.preExecutedResults -- 1126
			if ____opt_29 ~= nil then -- 1126
				____opt_29:delete(action.toolCallId) -- 1128
			end -- 1128
			if preResult:matches(action) then -- 1128
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1130
				result = __TS__Await(preResult.promise) -- 1131
			else -- 1131
				Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1133
				result = __TS__Await(executeToolAction(shared, action)) -- 1134
			end -- 1134
		else -- 1134
			result = __TS__Await(executeToolAction(shared, action)) -- 1137
		end -- 1137
		local guidance = {} -- 1139
		if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1139
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1145
		end -- 1145
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1145
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1148
		end -- 1148
		if shared.failedTestNeedsBuild == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1148
			guidance[#guidance + 1] = "A deterministic test previously failed. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1151
		end -- 1151
		if action.tool == "search_dora_api" then -- 1151
			if shared.unbuiltEdits == true then -- 1151
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1155
			end -- 1155
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1155
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1158
			end -- 1158
		end -- 1158
		if (action.tool == "edit_file" or action.tool == "delete_file") and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1158
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1162
		end -- 1162
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 1162
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1165
			if oldStr == "" then -- 1165
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1167
			end -- 1167
		end -- 1167
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1167
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1171
		end -- 1171
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1171
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1174
		end -- 1174
		if shared.buildRepairPending == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1174
			guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1179
		end -- 1179
		if shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true then -- 1179
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1182
		end -- 1182
		if #guidance > 0 then -- 1182
			result.guidance = table.concat(guidance, "\n") -- 1185
		end -- 1185
		return ____awaiter_resolve(nil, result) -- 1185
	end) -- 1185
end -- 1124
local function maybeCompressHistory(shared, forceAtTurnBoundary, pendingUserPrompt) -- 1190
	if forceAtTurnBoundary == nil then -- 1190
		forceAtTurnBoundary = false -- 1192
	end -- 1192
	if pendingUserPrompt == nil then -- 1192
		pendingUserPrompt = "" -- 1193
	end -- 1193
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1193
		local ____shared_31 = shared -- 1195
		local memory = ____shared_31.memory -- 1195
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1196
		local changed = false -- 1197
		do -- 1197
			local round = 0 -- 1198
			while round < maxRounds do -- 1198
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1199
				local activeMessages = getActiveConversationMessages(shared) -- 1200
				local uncoveredMessages = AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex) -- 1205
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1211
				local thresholdReached = memory.compressor:shouldCompress(uncoveredMessages, systemPrompt, toolDefinitions) -- 1214
				local activeTokens = 0 -- 1219
				if forceAtTurnBoundary and shared.role == "main" then -- 1219
					local ____temp_35 = estimateTextTokens(systemPrompt) + estimateTextTokens(toolDefinitions) + AgentRuntimePolicy.estimateConversationTokens(uncoveredMessages) + estimateTextTokens(pendingUserPrompt) -- 1221
					local ____math_max_34 = math.max -- 1225
					local ____math_floor_33 = math.floor -- 1225
					local ____shared_llmOptions_max_tokens_32 = shared.llmOptions.max_tokens -- 1225
					if ____shared_llmOptions_max_tokens_32 == nil then -- 1225
						____shared_llmOptions_max_tokens_32 = AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1225
					end -- 1225
					activeTokens = ____temp_35 + ____math_max_34( -- 1221
						0, -- 1225
						____math_floor_33(__TS__Number(____shared_llmOptions_max_tokens_32)) -- 1225
					) -- 1225
				end -- 1225
				local activeRealMessages = getActiveRealMessageCount(shared) -- 1227
				local boundaryThresholds = AgentConfig.getTurnBoundaryCompressionThresholds(shared.llmConfig.contextWindow) -- 1228
				local turnBoundaryReached = forceAtTurnBoundary and shared.role == "main" and (activeTokens >= boundaryThresholds.defaultTokens or activeRealMessages >= AgentConfig.AGENT_DEFAULTS.turnBoundaryHighMessageCount and activeTokens >= boundaryThresholds.highMessageTokens) -- 1231
				if not thresholdReached and not turnBoundaryReached then -- 1231
					if changed then -- 1231
						persistHistoryState(shared) -- 1242
					end -- 1242
					return ____awaiter_resolve(nil) -- 1242
				end -- 1242
				local compressionRound = round + 1 -- 1246
				shared.step = shared.step + 1 -- 1247
				local stepId = shared.step -- 1248
				local pendingMessages = #activeMessages -- 1249
				emitAgentEvent( -- 1250
					shared, -- 1250
					{ -- 1250
						type = "memory_compression_started", -- 1251
						sessionId = shared.sessionId, -- 1252
						taskId = shared.taskId, -- 1253
						step = stepId, -- 1254
						tool = "compress_memory", -- 1255
						reason = getMemoryCompressionStartReason(shared), -- 1256
						params = { -- 1257
							round = compressionRound, -- 1258
							maxRounds = maxRounds, -- 1259
							pendingMessages = pendingMessages, -- 1260
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1261
							uncoveredMessages = #uncoveredMessages -- 1262
						} -- 1262
					} -- 1262
				) -- 1262
				local result = __TS__Await(memory.compressor:compress( -- 1265
					activeMessages, -- 1266
					shared.llmOptions, -- 1267
					shared.llmMaxTry, -- 1268
					shared.decisionMode, -- 1269
					{ -- 1270
						onInput = function(____, phase, messages, options) -- 1271
							saveStepLLMDebugInput( -- 1272
								shared, -- 1272
								stepId, -- 1272
								phase, -- 1272
								messages, -- 1272
								options -- 1272
							) -- 1272
						end, -- 1271
						onOutput = function(____, phase, text, meta) -- 1274
							saveStepLLMDebugOutput( -- 1275
								shared, -- 1275
								stepId, -- 1275
								phase, -- 1275
								text, -- 1275
								meta -- 1275
							) -- 1275
						end, -- 1274
						onUsage = function(____, phase, usage) -- 1277
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1278
						end -- 1277
					}, -- 1277
					"default", -- 1281
					systemPrompt, -- 1282
					toolDefinitions -- 1283
				)) -- 1283
				if not (result and result.success and result.compressedCount > 0) then -- 1283
					emitAgentEvent( -- 1286
						shared, -- 1286
						{ -- 1286
							type = "memory_compression_finished", -- 1287
							sessionId = shared.sessionId, -- 1288
							taskId = shared.taskId, -- 1289
							step = stepId, -- 1290
							tool = "compress_memory", -- 1291
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1292
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1296
						} -- 1296
					) -- 1296
					if changed then -- 1296
						persistHistoryState(shared) -- 1304
					end -- 1304
					return ____awaiter_resolve(nil) -- 1304
				end -- 1304
				local effectiveCompressedCount = math.max( -- 1308
					0, -- 1309
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1310
				) -- 1310
				if effectiveCompressedCount <= 0 then -- 1310
					if changed then -- 1310
						persistHistoryState(shared) -- 1314
					end -- 1314
					return ____awaiter_resolve(nil) -- 1314
				end -- 1314
				emitAgentEvent( -- 1318
					shared, -- 1318
					{ -- 1318
						type = "memory_compression_finished", -- 1319
						sessionId = shared.sessionId, -- 1320
						taskId = shared.taskId, -- 1321
						step = stepId, -- 1322
						tool = "compress_memory", -- 1323
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1324
						result = { -- 1325
							success = true, -- 1326
							round = compressionRound, -- 1327
							compressedCount = effectiveCompressedCount, -- 1328
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1329
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1330
						} -- 1330
					} -- 1330
				) -- 1330
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1333
				changed = true -- 1334
				Log( -- 1335
					"Info", -- 1335
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1335
				) -- 1335
				round = round + 1 -- 1198
			end -- 1198
		end -- 1198
		if changed then -- 1198
			persistHistoryState(shared) -- 1338
		end -- 1338
	end) -- 1338
end -- 1190
local function compactAllHistory(shared) -- 1342
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1342
		local ____shared_42 = shared -- 1343
		local memory = ____shared_42.memory -- 1343
		local rounds = 0 -- 1344
		local totalCompressed = 0 -- 1345
		while getActiveRealMessageCount(shared) > 0 do -- 1345
			if shared.stopToken.stopped then -- 1345
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1348
				return ____awaiter_resolve( -- 1348
					nil, -- 1348
					emitAgentTaskFinishEvent( -- 1349
						shared, -- 1349
						false, -- 1349
						getCancelledReason(shared) -- 1349
					) -- 1349
				) -- 1349
			end -- 1349
			rounds = rounds + 1 -- 1351
			shared.step = shared.step + 1 -- 1352
			local stepId = shared.step -- 1353
			local activeMessages = getActiveConversationMessages(shared) -- 1354
			local pendingMessages = #activeMessages -- 1355
			emitAgentEvent( -- 1356
				shared, -- 1356
				{ -- 1356
					type = "memory_compression_started", -- 1357
					sessionId = shared.sessionId, -- 1358
					taskId = shared.taskId, -- 1359
					step = stepId, -- 1360
					tool = "compress_memory", -- 1361
					reason = getMemoryCompressionStartReason(shared), -- 1362
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1363
				} -- 1363
			) -- 1363
			local result = __TS__Await(memory.compressor:compress( -- 1370
				activeMessages, -- 1371
				shared.llmOptions, -- 1372
				shared.llmMaxTry, -- 1373
				shared.decisionMode, -- 1374
				{ -- 1375
					onInput = function(____, phase, messages, options) -- 1376
						saveStepLLMDebugInput( -- 1377
							shared, -- 1377
							stepId, -- 1377
							phase, -- 1377
							messages, -- 1377
							options -- 1377
						) -- 1377
					end, -- 1376
					onOutput = function(____, phase, text, meta) -- 1379
						saveStepLLMDebugOutput( -- 1380
							shared, -- 1380
							stepId, -- 1380
							phase, -- 1380
							text, -- 1380
							meta -- 1380
						) -- 1380
					end, -- 1379
					onUsage = function(____, phase, usage) -- 1382
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1383
					end -- 1382
				}, -- 1382
				"budget_max" -- 1386
			)) -- 1386
			if not (result and result.success and result.compressedCount > 0) then -- 1386
				emitAgentEvent( -- 1389
					shared, -- 1389
					{ -- 1389
						type = "memory_compression_finished", -- 1390
						sessionId = shared.sessionId, -- 1391
						taskId = shared.taskId, -- 1392
						step = stepId, -- 1393
						tool = "compress_memory", -- 1394
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1395
						result = { -- 1399
							success = false, -- 1400
							rounds = rounds, -- 1401
							error = result and result.error or "compression returned no changes", -- 1402
							compressedCount = result and result.compressedCount or 0, -- 1403
							fullCompaction = true -- 1404
						} -- 1404
					} -- 1404
				) -- 1404
				return ____awaiter_resolve( -- 1404
					nil, -- 1404
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1407
				) -- 1407
			end -- 1407
			local effectiveCompressedCount = math.max( -- 1412
				0, -- 1413
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1414
			) -- 1414
			if effectiveCompressedCount <= 0 then -- 1414
				return ____awaiter_resolve( -- 1414
					nil, -- 1414
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1417
				) -- 1417
			end -- 1417
			emitAgentEvent( -- 1424
				shared, -- 1424
				{ -- 1424
					type = "memory_compression_finished", -- 1425
					sessionId = shared.sessionId, -- 1426
					taskId = shared.taskId, -- 1427
					step = stepId, -- 1428
					tool = "compress_memory", -- 1429
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1430
					result = { -- 1431
						success = true, -- 1432
						round = rounds, -- 1433
						compressedCount = effectiveCompressedCount, -- 1434
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1435
						fullCompaction = true -- 1436
					} -- 1436
				} -- 1436
			) -- 1436
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1439
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1440
			persistHistoryState(shared) -- 1441
			Log( -- 1442
				"Info", -- 1442
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1442
			) -- 1442
		end -- 1442
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1444
		return ____awaiter_resolve( -- 1444
			nil, -- 1444
			emitAgentTaskFinishEvent( -- 1445
				shared, -- 1446
				true, -- 1447
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1448
			) -- 1448
		) -- 1448
	end) -- 1448
end -- 1342
local function clearSessionHistory(shared) -- 1454
	shared.messages = {} -- 1455
	shared.lastConsolidatedIndex = 0 -- 1456
	shared.carryMessageIndex = nil -- 1457
	persistHistoryState(shared) -- 1458
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1459
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1460
end -- 1454
COMPLETION_TEXT_MAX_CHARS = 800 -- 1482
COMPLETION_LIST_MAX_ITEMS = 12 -- 1483
COMPLETION_EVIDENCE_MAX_ITEMS = 8 -- 1484
local function appendConversationMessage(shared, message) -- 1676
	local ____shared_messages_51 = shared.messages -- 1676
	____shared_messages_51[#____shared_messages_51 + 1] = __TS__ObjectAssign( -- 1677
		{}, -- 1677
		message, -- 1678
		{ -- 1677
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1679
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1680
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1681
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1682
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1683
		} -- 1683
	) -- 1683
end -- 1676
local function appendToolResultMessage(shared, action) -- 1692
	appendConversationMessage( -- 1693
		shared, -- 1693
		{ -- 1693
			role = "tool", -- 1694
			tool_call_id = action.toolCallId, -- 1695
			name = action.tool, -- 1696
			content = action.result and toJson(action.result, false) or "" -- 1697
		} -- 1697
	) -- 1697
end -- 1692
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1701
	appendConversationMessage( -- 1707
		shared, -- 1707
		{ -- 1707
			role = "assistant", -- 1708
			content = content or "", -- 1709
			reasoning_content = reasoningContent, -- 1710
			tool_calls = __TS__ArrayMap( -- 1711
				actions, -- 1711
				function(____, action) return { -- 1711
					id = action.toolCallId, -- 1712
					type = "function", -- 1713
					["function"] = { -- 1714
						name = action.tool, -- 1715
						arguments = toJson(action.params, false) -- 1716
					} -- 1716
				} end -- 1716
			) -- 1716
		} -- 1716
	) -- 1716
end -- 1701
local function llm(shared, messages, phase) -- 1900
	if phase == nil then -- 1900
		phase = "decision_xml" -- 1903
	end -- 1903
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1903
		local stepId = shared.step + 1 -- 1905
		emitLLMContextMetrics( -- 1906
			shared, -- 1906
			stepId, -- 1906
			phase, -- 1906
			messages, -- 1906
			shared.llmOptions -- 1906
		) -- 1906
		saveStepLLMDebugInput( -- 1907
			shared, -- 1907
			stepId, -- 1907
			phase, -- 1907
			messages, -- 1907
			shared.llmOptions -- 1907
		) -- 1907
		local lastStreamReasoning = "" -- 1908
		local res = __TS__Await(callLLMStreamAggregated( -- 1909
			messages, -- 1910
			shared.llmOptions, -- 1911
			shared.stopToken, -- 1912
			shared.llmConfig, -- 1913
			function(response) -- 1914
				local ____opt_55 = response.choices -- 1914
				local ____opt_53 = ____opt_55 and ____opt_55[1] -- 1914
				local streamMessage = ____opt_53 and ____opt_53.message -- 1915
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1916
				if nextContent == "" then -- 1916
					return -- 1919
				end -- 1919
				if nextContent == lastStreamReasoning then -- 1919
					return -- 1920
				end -- 1920
				lastStreamReasoning = nextContent -- 1921
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1922
			end -- 1914
		)) -- 1914
		if res.success then -- 1914
			local usage = res.tokenUsage -- 1926
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1927
			local ____opt_61 = res.response.choices -- 1927
			local ____opt_59 = ____opt_61 and ____opt_61[1] -- 1927
			local message = ____opt_59 and ____opt_59.message -- 1928
			local text = message and message.content -- 1929
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1930
			if text then -- 1930
				local parsed = tryParseAndValidateDecision(text, shared.role) -- 1934
				if parsed.success then -- 1934
					local reason = parsed.reason or "" -- 1936
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1937
				end -- 1937
				saveStepLLMDebugOutput( -- 1939
					shared, -- 1939
					stepId, -- 1939
					phase, -- 1939
					text, -- 1939
					{success = true, usage = usage} -- 1939
				) -- 1939
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1939
			else -- 1939
				saveStepLLMDebugOutput( -- 1942
					shared, -- 1942
					stepId, -- 1942
					phase, -- 1942
					"empty LLM response", -- 1942
					{success = false, usage = usage} -- 1942
				) -- 1942
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1942
			end -- 1942
		else -- 1942
			local usage = res.tokenUsage -- 1946
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1947
			saveStepLLMDebugOutput( -- 1948
				shared, -- 1948
				stepId, -- 1948
				phase, -- 1948
				res.raw or res.message, -- 1948
				{success = false, usage = usage} -- 1948
			) -- 1948
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1948
		end -- 1948
	end) -- 1948
end -- 1900
local function isDecisionBatchSuccess(result) -- 1972
	return result.kind == "batch" -- 1973
end -- 1972
local function parseDecisionToolCall(functionName, rawObj) -- 1997
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 1997
		return {success = false, message = "unknown tool: " .. functionName} -- 1999
	end -- 1999
	if rawObj == nil then -- 1999
		return {success = true, tool = functionName, params = {}} -- 2002
	end -- 2002
	if not isRecord(rawObj) then -- 2002
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2005
	end -- 2005
	return {success = true, tool = functionName, params = rawObj} -- 2007
end -- 1997
local function parseToolCallArguments(functionName, argsText) -- 2014
	local trimmedArgs = __TS__StringTrim(argsText) -- 2015
	if trimmedArgs == "" then -- 2015
		return {} -- 2017
	end -- 2017
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 2019
	if err ~= nil or rawObj == nil then -- 2019
		return { -- 2021
			success = false, -- 2022
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2023
			raw = argsText -- 2024
		} -- 2024
	end -- 2024
	local encodedRaw = safeJsonEncode(rawObj) -- 2027
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2027
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2029
	end -- 2029
	return rawObj -- 2035
end -- 2014
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2038
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2046
	if isRecord(rawArgs) and rawArgs.success == false then -- 2046
		return rawArgs -- 2048
	end -- 2048
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2050
	if not decision.success then -- 2050
		return {success = false, message = decision.message, raw = argsText} -- 2052
	end -- 2052
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2058
	if not completionValidation.success then -- 2058
		return {success = false, message = completionValidation.message, raw = argsText} -- 2060
	end -- 2060
	local validation = validateDecision(decision.tool, decision.params) -- 2066
	if not validation.success then -- 2066
		return {success = false, message = validation.message, raw = argsText} -- 2068
	end -- 2068
	if not isToolAllowedForRole(shared, decision.tool) then -- 2068
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 2075
	end -- 2075
	decision.params = validation.params -- 2081
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2082
	decision.reason = reason -- 2083
	decision.reasoningContent = reasoningContent -- 2084
	return decision -- 2085
end -- 2038
local function createPreExecutableActionFromStream(shared, toolCall) -- 2088
	local ____opt_67 = toolCall["function"] -- 2088
	local functionName = ____opt_67 and ____opt_67.name -- 2089
	local ____opt_69 = toolCall["function"] -- 2089
	local argsText = ____opt_69 and ____opt_69.arguments or "" -- 2090
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2091
	if not functionName or not toolCallId then -- 2091
		return nil -- 2092
	end -- 2092
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2093
	if isRecord(rawArgs) and rawArgs.success == false then -- 2093
		return nil -- 2094
	end -- 2094
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2095
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2095
		return nil -- 2096
	end -- 2096
	local validation = validateDecision(decision.tool, decision.params) -- 2097
	if not validation.success then -- 2097
		return nil -- 2098
	end -- 2098
	if not isToolAllowedForRole(shared, decision.tool) then -- 2098
		return nil -- 2099
	end -- 2099
	return { -- 2100
		step = shared.step + 1, -- 2101
		toolCallId = toolCallId, -- 2102
		tool = decision.tool, -- 2103
		reason = "", -- 2104
		params = validation.params, -- 2105
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2106
	} -- 2106
end -- 2088
local function sanitizeMessagesForLLMInput(messages) -- 2308
	local sanitized = {} -- 2309
	local droppedAssistantToolCalls = 0 -- 2310
	local droppedToolResults = 0 -- 2311
	do -- 2311
		local i = 0 -- 2312
		while i < #messages do -- 2312
			do -- 2312
				local message = messages[i + 1] -- 2313
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2313
					local requiredIds = {} -- 2315
					do -- 2315
						local j = 0 -- 2316
						while j < #message.tool_calls do -- 2316
							local toolCall = message.tool_calls[j + 1] -- 2317
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2318
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2318
								requiredIds[#requiredIds + 1] = id -- 2320
							end -- 2320
							j = j + 1 -- 2316
						end -- 2316
					end -- 2316
					if #requiredIds == 0 then -- 2316
						sanitized[#sanitized + 1] = message -- 2324
						goto __continue393 -- 2325
					end -- 2325
					local matchedIds = {} -- 2327
					local matchedTools = {} -- 2328
					local j = i + 1 -- 2329
					while j < #messages do -- 2329
						local toolMessage = messages[j + 1] -- 2331
						if toolMessage.role ~= "tool" then -- 2331
							break -- 2332
						end -- 2332
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2333
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2333
							matchedIds[toolCallId] = true -- 2335
							matchedTools[#matchedTools + 1] = toolMessage -- 2336
						else -- 2336
							droppedToolResults = droppedToolResults + 1 -- 2338
						end -- 2338
						j = j + 1 -- 2340
					end -- 2340
					local complete = true -- 2342
					do -- 2342
						local j = 0 -- 2343
						while j < #requiredIds do -- 2343
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2343
								complete = false -- 2345
								break -- 2346
							end -- 2346
							j = j + 1 -- 2343
						end -- 2343
					end -- 2343
					if complete then -- 2343
						__TS__ArrayPush( -- 2350
							sanitized, -- 2350
							message, -- 2350
							table.unpack(matchedTools) -- 2350
						) -- 2350
					else -- 2350
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2352
						droppedToolResults = droppedToolResults + #matchedTools -- 2353
					end -- 2353
					i = j - 1 -- 2355
					goto __continue393 -- 2356
				end -- 2356
				if message.role == "tool" then -- 2356
					droppedToolResults = droppedToolResults + 1 -- 2359
					goto __continue393 -- 2360
				end -- 2360
				sanitized[#sanitized + 1] = message -- 2362
			end -- 2362
			::__continue393:: -- 2362
			i = i + 1 -- 2312
		end -- 2312
	end -- 2312
	return sanitized -- 2364
end -- 2308
local function getUnconsolidatedMessages(shared) -- 2367
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2368
end -- 2367
local function getFinalDecisionTurnPrompt(shared) -- 2371
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2372
end -- 2371
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2377
	if attempt == nil then -- 2377
		attempt = 1 -- 2380
	end -- 2380
	if decisionMode == nil then -- 2380
		decisionMode = shared.decisionMode -- 2382
	end -- 2382
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2384
	local tailSections = {} -- 2385
	if shared.resumeCheckpointPending == true then -- 2385
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2387
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2390
	end -- 2390
	if shared.truncatedToolOverwritePath ~= nil then -- 2390
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2393
	end -- 2393
	shared.resumeCheckpointPending = false -- 2395
	local messages = { -- 2396
		{role = "system", content = systemPrompt}, -- 2397
		table.unpack(getUnconsolidatedMessages(shared)) -- 2398
	} -- 2398
	if shared.step + 1 >= shared.maxSteps then -- 2398
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2401
	end -- 2401
	if lastError and lastError ~= "" then -- 2401
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2404
		if decisionMode == "xml" then -- 2404
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2408
		end -- 2408
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2408
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2411
		end -- 2411
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2411
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2414
		end -- 2414
		messages[#messages + 1] = { -- 2416
			role = "user", -- 2417
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2418
		} -- 2418
	end -- 2418
	tailSections[#tailSections + 1] = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2425
		role = shared.role, -- 2426
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2427
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2428
		resumeRequiredTool = shared.resumeRequiredTool, -- 2429
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2430
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2431
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2432
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2433
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2434
		buildRepairPending = shared.buildRepairPending, -- 2435
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2436
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2437
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2438
	}) -- 2438
	messages[#messages + 1] = { -- 2440
		role = "user", -- 2441
		content = table.concat(tailSections, "\n\n") -- 2442
	} -- 2442
	return messages -- 2444
end -- 2377
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2451
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2460
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2461
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2469
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2470
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2471
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2479
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2487
		shared.role, -- 2487
		{ -- 2487
			includeFinish = true, -- 2488
			includeXmlRules = true, -- 2489
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2490
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared) -- 2491
		} -- 2491
	) -- 2491
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2493
	local repairPrompt = replacePromptVars( -- 2496
		shared.promptPack.xmlDecisionRepairPrompt, -- 2496
		{ -- 2496
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2497
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2498
			CANDIDATE_SECTION = candidateSection, -- 2499
			LAST_ERROR = lastError, -- 2500
			ATTEMPT = tostring(attempt) -- 2501
		} -- 2501
	) -- 2501
	local availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2503
		role = shared.role, -- 2504
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2505
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2506
		resumeRequiredTool = shared.resumeRequiredTool, -- 2507
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2508
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2509
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2510
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2511
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2512
		buildRepairPending = shared.buildRepairPending, -- 2513
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2514
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2515
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2516
	}) -- 2516
	return {{role = "system", content = systemPrompt}, {role = "user", content = (repairPrompt .. "\n\n") .. availabilityPrompt}} -- 2518
end -- 2451
local function replaceFirst(text, oldStr, newStr) -- 2552
	if oldStr == "" then -- 2552
		return text -- 2553
	end -- 2553
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2554
	if idx < 0 then -- 2554
		return text -- 2555
	end -- 2555
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2556
end -- 2552
local function splitLines(text) -- 2559
	return __TS__StringSplit(text, "\n") -- 2560
end -- 2559
local function getLeadingWhitespace(text) -- 2563
	local i = 0 -- 2564
	while i < #text do -- 2564
		local ch = __TS__StringAccess(text, i) -- 2566
		if ch ~= " " and ch ~= "\t" then -- 2566
			break -- 2567
		end -- 2567
		i = i + 1 -- 2568
	end -- 2568
	return __TS__StringSubstring(text, 0, i) -- 2570
end -- 2563
local function getCommonIndentPrefix(lines) -- 2573
	local common -- 2574
	do -- 2574
		local i = 0 -- 2575
		while i < #lines do -- 2575
			do -- 2575
				local line = lines[i + 1] -- 2576
				if __TS__StringTrim(line) == "" then -- 2576
					goto __continue435 -- 2577
				end -- 2577
				local indent = getLeadingWhitespace(line) -- 2578
				if common == nil then -- 2578
					common = indent -- 2580
					goto __continue435 -- 2581
				end -- 2581
				local j = 0 -- 2583
				local maxLen = math.min(#common, #indent) -- 2584
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2584
					j = j + 1 -- 2586
				end -- 2586
				common = __TS__StringSubstring(common, 0, j) -- 2588
				if common == "" then -- 2588
					break -- 2589
				end -- 2589
			end -- 2589
			::__continue435:: -- 2589
			i = i + 1 -- 2575
		end -- 2575
	end -- 2575
	return common or "" -- 2591
end -- 2573
local function removeIndentPrefix(line, indent) -- 2594
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2594
		return __TS__StringSubstring(line, #indent) -- 2596
	end -- 2596
	local lineIndent = getLeadingWhitespace(line) -- 2598
	local j = 0 -- 2599
	local maxLen = math.min(#lineIndent, #indent) -- 2600
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2600
		j = j + 1 -- 2602
	end -- 2602
	return __TS__StringSubstring(line, j) -- 2604
end -- 2594
local function dedentLines(lines) -- 2607
	local indent = getCommonIndentPrefix(lines) -- 2608
	return { -- 2609
		indent = indent, -- 2610
		lines = __TS__ArrayMap( -- 2611
			lines, -- 2611
			function(____, line) return removeIndentPrefix(line, indent) end -- 2611
		) -- 2611
	} -- 2611
end -- 2607
local function joinLines(lines) -- 2615
	return table.concat(lines, "\n") -- 2616
end -- 2615
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2619
	local function findWhitespaceTolerantReplacement() -- 2624
		local function foldWhitespace(text, withMap) -- 2626
			local parts = {} -- 2627
			local map = {} -- 2628
			local i = 0 -- 2629
			while i < #text do -- 2629
				local ch = __TS__StringAccess(text, i) -- 2631
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2631
					local start = i -- 2633
					while i < #text do -- 2633
						local next = __TS__StringAccess(text, i) -- 2635
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2635
							break -- 2636
						end -- 2636
						i = i + 1 -- 2637
					end -- 2637
					parts[#parts + 1] = " " -- 2639
					if withMap then -- 2639
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2640
					end -- 2640
				else -- 2640
					parts[#parts + 1] = ch -- 2642
					if withMap then -- 2642
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2643
					end -- 2643
					i = i + 1 -- 2644
				end -- 2644
			end -- 2644
			return { -- 2647
				text = table.concat(parts, ""), -- 2647
				map = map -- 2647
			} -- 2647
		end -- 2626
		local foldedContent = foldWhitespace(content, true) -- 2649
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2650
		if foldedOld == "" then -- 2650
			return {success = false, message = "old_str not found in file"} -- 2652
		end -- 2652
		local matches = {} -- 2654
		local pos = 0 -- 2655
		while true do -- 2655
			local idx = (string.find( -- 2657
				foldedContent.text, -- 2657
				foldedOld, -- 2657
				math.max(pos + 1, 1), -- 2657
				true -- 2657
			) or 0) - 1 -- 2657
			if idx < 0 then -- 2657
				break -- 2658
			end -- 2658
			local lastIdx = idx + #foldedOld - 1 -- 2659
			local startMap = foldedContent.map[idx + 1] -- 2660
			local endMap = foldedContent.map[lastIdx + 1] -- 2661
			if startMap ~= nil and endMap ~= nil then -- 2661
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2663
			end -- 2663
			pos = idx + #foldedOld -- 2665
		end -- 2665
		if #matches == 0 then -- 2665
			return {success = false, message = "old_str not found in file"} -- 2668
		end -- 2668
		if #matches > 1 then -- 2668
			return { -- 2671
				success = false, -- 2672
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2673
			} -- 2673
		end -- 2673
		local match = matches[1] -- 2676
		return { -- 2677
			success = true, -- 2678
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2679
		} -- 2679
	end -- 2624
	local contentLines = splitLines(content) -- 2682
	local oldLines = splitLines(oldStr) -- 2683
	if #oldLines == 0 then -- 2683
		return {success = false, message = "old_str not found in file"} -- 2685
	end -- 2685
	local dedentedOld = dedentLines(oldLines) -- 2687
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2688
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2689
	local matches = {} -- 2690
	do -- 2690
		local start = 0 -- 2691
		while start <= #contentLines - #oldLines do -- 2691
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2692
			local dedentedCandidate = dedentLines(candidateLines) -- 2693
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2693
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2695
			end -- 2695
			start = start + 1 -- 2691
		end -- 2691
	end -- 2691
	if #matches == 0 then -- 2691
		return findWhitespaceTolerantReplacement() -- 2703
	end -- 2703
	if #matches > 1 then -- 2703
		return { -- 2706
			success = false, -- 2707
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2708
		} -- 2708
	end -- 2708
	local match = matches[1] -- 2711
	local rebuiltNewLines = __TS__ArrayMap( -- 2712
		dedentedNew.lines, -- 2712
		function(____, line) return line == "" and "" or match.indent .. line end -- 2712
	) -- 2712
	local ____array_75 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2712
	__TS__SparseArrayPush( -- 2712
		____array_75, -- 2712
		table.unpack(rebuiltNewLines) -- 2715
	) -- 2715
	__TS__SparseArrayPush( -- 2715
		____array_75, -- 2715
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2716
	) -- 2716
	local nextLines = {__TS__SparseArraySpread(____array_75)} -- 2713
	return { -- 2718
		success = true, -- 2718
		content = joinLines(nextLines) -- 2718
	} -- 2718
end -- 2619
local MainDecisionAgent = __TS__Class() -- 2721
MainDecisionAgent.name = "MainDecisionAgent" -- 2721
__TS__ClassExtends(MainDecisionAgent, Node) -- 2721
function MainDecisionAgent.prototype.prep(self, shared) -- 2722
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2722
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2722
			return ____awaiter_resolve(nil, {shared = shared}) -- 2722
		end -- 2722
		__TS__Await(maybeCompressHistory(shared)) -- 2727
		return ____awaiter_resolve(nil, {shared = shared}) -- 2727
	end) -- 2727
end -- 2722
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2732
	local preExecuted = shared.preExecutedResults -- 2733
	if not preExecuted or preExecuted.size == 0 then -- 2733
		return nil -- 2734
	end -- 2734
	local decisions = {} -- 2735
	preExecuted:forEach(function(____, preResult) -- 2736
		local action = preResult.action -- 2737
		decisions[#decisions + 1] = { -- 2738
			success = true, -- 2739
			tool = action.tool, -- 2740
			params = action.params, -- 2741
			toolCallId = action.toolCallId, -- 2742
			reason = action.reason, -- 2743
			reasoningContent = action.reasoningContent -- 2744
		} -- 2744
	end) -- 2736
	if #decisions == 0 then -- 2736
		return nil -- 2747
	end -- 2747
	Log( -- 2748
		"Warn", -- 2748
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2748
			__TS__ArrayMap( -- 2748
				decisions, -- 2748
				function(____, decision) return decision.tool end -- 2748
			), -- 2748
			"," -- 2748
		) -- 2748
	) -- 2748
	if #decisions == 1 then -- 2748
		return decisions[1] -- 2750
	end -- 2750
	return {success = true, kind = "batch", decisions = decisions} -- 2752
end -- 2732
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2759
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2764
	if not recovery then -- 2764
		return nil -- 2765
	end -- 2765
	shared.truncatedToolOverwritePath = recovery.target -- 2766
	Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2767
	return { -- 2768
		success = true, -- 2769
		tool = "edit_file", -- 2770
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2771
		toolCallId = createLocalToolCallId(), -- 2777
		reason = recovery.reason, -- 2778
		reasoningContent = reasoningContent -- 2779
	} -- 2779
end -- 2759
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2783
	if attempt == nil then -- 2783
		attempt = 1 -- 2786
	end -- 2786
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2786
		if shared.stopToken.stopped then -- 2786
			return ____awaiter_resolve( -- 2786
				nil, -- 2786
				{ -- 2790
					success = false, -- 2790
					message = getCancelledReason(shared) -- 2790
				} -- 2790
			) -- 2790
		end -- 2790
		Log( -- 2792
			"Info", -- 2792
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2792
		) -- 2792
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2793
			shared.role, -- 2793
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2793
			{disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared)} -- 2793
		) -- 2793
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2796
		local stepId = shared.step + 1 -- 2797
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2798
			string.lower(shared.llmConfig.model), -- 2798
			"glm-5.2" -- 2798
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2798
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2801
		emitLLMContextMetrics( -- 2806
			shared, -- 2806
			stepId, -- 2806
			"decision_tool_calling", -- 2806
			messages, -- 2806
			llmOptions -- 2806
		) -- 2806
		saveStepLLMDebugInput( -- 2807
			shared, -- 2807
			stepId, -- 2807
			"decision_tool_calling", -- 2807
			messages, -- 2807
			llmOptions -- 2807
		) -- 2807
		local lastStreamContent = "" -- 2808
		local lastStreamReasoning = "" -- 2809
		local preExecutedResults = __TS__New(Map) -- 2810
		shared.preExecutedResults = preExecutedResults -- 2811
		local res = __TS__Await(callLLMStreamAggregated( -- 2812
			messages, -- 2813
			llmOptions, -- 2814
			shared.stopToken, -- 2815
			shared.llmConfig, -- 2816
			function(response) -- 2817
				local ____opt_78 = response.choices -- 2817
				local ____opt_76 = ____opt_78 and ____opt_78[1] -- 2817
				local streamMessage = ____opt_76 and ____opt_76.message -- 2818
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2819
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2822
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2822
					return -- 2826
				end -- 2826
				lastStreamContent = nextContent -- 2828
				lastStreamReasoning = nextReasoning -- 2829
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2830
			end, -- 2817
			function(tc) -- 2832
				if shared.stopToken.stopped then -- 2832
					return -- 2833
				end -- 2833
				local action = createPreExecutableActionFromStream(shared, tc) -- 2834
				if not action or preExecutedResults:has(action.toolCallId) then -- 2834
					return -- 2835
				end -- 2835
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2836
				preExecutedResults:set( -- 2837
					action.toolCallId, -- 2837
					createPreExecutedToolResult(shared, action) -- 2837
				) -- 2837
			end -- 2832
		)) -- 2832
		if shared.stopToken.stopped then -- 2832
			clearPreExecutedResults(shared) -- 2841
			return ____awaiter_resolve( -- 2841
				nil, -- 2841
				{ -- 2842
					success = false, -- 2842
					message = getCancelledReason(shared) -- 2842
				} -- 2842
			) -- 2842
		end -- 2842
		if not res.success then -- 2842
			local usage = res.tokenUsage -- 2845
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2846
			saveStepLLMDebugOutput( -- 2847
				shared, -- 2847
				stepId, -- 2847
				"decision_tool_calling", -- 2847
				res.raw or res.message, -- 2847
				{success = false, usage = usage} -- 2847
			) -- 2847
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2848
			local committed = self:commitPreExecutedDecision(shared) -- 2849
			if committed then -- 2849
				return ____awaiter_resolve(nil, committed) -- 2849
			end -- 2849
			local ____opt_86 = res.response -- 2849
			local ____opt_84 = ____opt_86 and ____opt_86.choices -- 2849
			local partialChoice = ____opt_84 and ____opt_84[1] -- 2851
			local ____self_preserveTruncatedEditDecision_98 = self.preserveTruncatedEditDecision -- 2852
			local ____shared_96 = shared -- 2853
			local ____opt_88 = partialChoice and partialChoice.message -- 2853
			local ____temp_97 = ____opt_88 and ____opt_88.tool_calls -- 2854
			local ____opt_92 = partialChoice and partialChoice.message -- 2854
			local partialDraft = ____self_preserveTruncatedEditDecision_98(self, ____shared_96, ____temp_97, ____opt_92 and ____opt_92.reasoning_content) -- 2852
			if partialDraft then -- 2852
				return ____awaiter_resolve(nil, partialDraft) -- 2852
			end -- 2852
			clearPreExecutedResults(shared) -- 2858
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2858
		end -- 2858
		local usage = res.tokenUsage -- 2861
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2862
		saveStepLLMDebugOutput( -- 2863
			shared, -- 2863
			stepId, -- 2863
			"decision_tool_calling", -- 2863
			encodeDebugJSON(res.response), -- 2863
			{success = true, usage = usage} -- 2863
		) -- 2863
		local choice = res.response.choices and res.response.choices[1] -- 2864
		local message = choice and choice.message -- 2865
		local toolCalls = message and message.tool_calls -- 2866
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2867
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2870
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2873
		Log( -- 2876
			"Info", -- 2876
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2876
		) -- 2876
		if finishReason == "length" then -- 2876
			local committed = self:commitPreExecutedDecision(shared) -- 2878
			if committed then -- 2878
				return ____awaiter_resolve(nil, committed) -- 2878
			end -- 2878
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 2880
			if partialDraft then -- 2880
				return ____awaiter_resolve(nil, partialDraft) -- 2880
			end -- 2880
			Log( -- 2882
				"Error", -- 2882
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2882
			) -- 2882
			clearPreExecutedResults(shared) -- 2883
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 2883
		end -- 2883
		if not toolCalls or #toolCalls == 0 then -- 2883
			if messageContent and messageContent ~= "" then -- 2883
				if shared.role == "sub" then -- 2883
					Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 2893
					clearPreExecutedResults(shared) -- 2894
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 2894
				end -- 2894
				Log( -- 2901
					"Info", -- 2901
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2901
				) -- 2901
				clearPreExecutedResults(shared) -- 2902
				return ____awaiter_resolve(nil, { -- 2902
					success = true, -- 2904
					tool = "finish", -- 2905
					params = {}, -- 2906
					reason = messageContent, -- 2907
					reasoningContent = reasoningContent, -- 2908
					directSummary = messageContent -- 2909
				}) -- 2909
			end -- 2909
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2912
			clearPreExecutedResults(shared) -- 2913
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2913
		end -- 2913
		local decisions = {} -- 2920
		do -- 2920
			local i = 0 -- 2921
			while i < #toolCalls do -- 2921
				local toolCall = toolCalls[i + 1] -- 2922
				local fn = toolCall ~= nil and toolCall["function"] -- 2923
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2923
					Log( -- 2925
						"Error", -- 2925
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2925
					) -- 2925
					clearPreExecutedResults(shared) -- 2926
					return ____awaiter_resolve( -- 2926
						nil, -- 2926
						{ -- 2927
							success = false, -- 2928
							message = "missing function name for tool call " .. tostring(i + 1), -- 2929
							raw = messageContent -- 2930
						} -- 2930
					) -- 2930
				end -- 2930
				local functionName = fn.name -- 2933
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2934
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 2935
				Log( -- 2938
					"Info", -- 2938
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2938
				) -- 2938
				local decision = parseAndValidateToolCallDecision( -- 2939
					shared, -- 2940
					functionName, -- 2941
					argsText, -- 2942
					toolCallId, -- 2943
					messageContent, -- 2944
					reasoningContent -- 2945
				) -- 2945
				if not decision.success then -- 2945
					Log( -- 2948
						"Error", -- 2948
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2948
					) -- 2948
					clearPreExecutedResults(shared) -- 2949
					return ____awaiter_resolve(nil, decision) -- 2949
				end -- 2949
				decisions[#decisions + 1] = decision -- 2952
				i = i + 1 -- 2921
			end -- 2921
		end -- 2921
		if #decisions == 1 then -- 2921
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2955
			return ____awaiter_resolve(nil, decisions[1]) -- 2955
		end -- 2955
		do -- 2955
			local i = 0 -- 2958
			while i < #decisions do -- 2958
				if decisions[i + 1].tool == "finish" then -- 2958
					clearPreExecutedResults(shared) -- 2960
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2960
				end -- 2960
				i = i + 1 -- 2958
			end -- 2958
		end -- 2958
		Log( -- 2968
			"Info", -- 2968
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2968
				__TS__ArrayMap( -- 2968
					decisions, -- 2968
					function(____, decision) return decision.tool end -- 2968
				), -- 2968
				"," -- 2968
			) -- 2968
		) -- 2968
		return ____awaiter_resolve(nil, { -- 2968
			success = true, -- 2970
			kind = "batch", -- 2971
			decisions = decisions, -- 2972
			content = messageContent, -- 2973
			reasoningContent = reasoningContent -- 2974
		}) -- 2974
	end) -- 2974
end -- 2783
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 2978
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2978
		Log( -- 2984
			"Info", -- 2984
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2984
		) -- 2984
		local lastError = initialError -- 2985
		local candidateRaw = "" -- 2986
		local candidateReasoning = nil -- 2987
		do -- 2987
			local attempt = 0 -- 2988
			while attempt < shared.llmMaxTry do -- 2988
				do -- 2988
					Log( -- 2989
						"Info", -- 2989
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2989
					) -- 2989
					local messages = buildXmlRepairMessages( -- 2990
						shared, -- 2991
						originalRaw, -- 2992
						originalReasoning, -- 2993
						candidateRaw, -- 2994
						candidateReasoning, -- 2995
						lastError, -- 2996
						attempt + 1 -- 2997
					) -- 2997
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2999
					if shared.stopToken.stopped then -- 2999
						return ____awaiter_resolve( -- 2999
							nil, -- 2999
							{ -- 3001
								success = false, -- 3001
								message = getCancelledReason(shared) -- 3001
							} -- 3001
						) -- 3001
					end -- 3001
					if not llmRes.success then -- 3001
						lastError = llmRes.message -- 3004
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3005
						goto __continue507 -- 3006
					end -- 3006
					candidateRaw = llmRes.text -- 3008
					candidateReasoning = llmRes.reasoningContent -- 3009
					local decision = tryParseAndValidateDecision(candidateRaw, shared.role) -- 3010
					if decision.success then -- 3010
						decision.reasoningContent = llmRes.reasoningContent -- 3012
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3013
						return ____awaiter_resolve(nil, decision) -- 3013
					end -- 3013
					lastError = decision.message -- 3016
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3017
				end -- 3017
				::__continue507:: -- 3017
				attempt = attempt + 1 -- 2988
			end -- 2988
		end -- 2988
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3019
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3019
	end) -- 3019
end -- 2978
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3027
	if attempt == nil then -- 3027
		attempt = 1 -- 3030
	end -- 3030
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3030
		local messages = buildDecisionMessages( -- 3033
			shared, -- 3034
			lastError, -- 3035
			attempt, -- 3036
			lastRaw, -- 3037
			"xml" -- 3038
		) -- 3038
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3040
		if shared.stopToken.stopped then -- 3040
			return ____awaiter_resolve( -- 3040
				nil, -- 3040
				{ -- 3042
					success = false, -- 3042
					message = getCancelledReason(shared) -- 3042
				} -- 3042
			) -- 3042
		end -- 3042
		if not llmRes.success then -- 3042
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3042
		end -- 3042
		local decision = tryParseAndValidateDecision(llmRes.text, shared.role) -- 3051
		if decision.success then -- 3051
			decision.reasoningContent = llmRes.reasoningContent -- 3053
			if not isToolAllowedForRole(shared, decision.tool) then -- 3053
				return ____awaiter_resolve( -- 3053
					nil, -- 3053
					self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, (decision.tool .. " is not allowed for role ") .. shared.role) -- 3055
				) -- 3055
			end -- 3055
			return ____awaiter_resolve(nil, decision) -- 3055
		end -- 3055
		return ____awaiter_resolve( -- 3055
			nil, -- 3055
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3064
		) -- 3064
	end) -- 3064
end -- 3027
function MainDecisionAgent.prototype.exec(self, input) -- 3067
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3067
		local shared = input.shared -- 3068
		if shared.stopToken.stopped then -- 3068
			return ____awaiter_resolve( -- 3068
				nil, -- 3068
				{ -- 3070
					success = false, -- 3070
					message = getCancelledReason(shared) -- 3070
				} -- 3070
			) -- 3070
		end -- 3070
		if shared.step >= shared.maxSteps then -- 3070
			Log( -- 3073
				"Warn", -- 3073
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3073
			) -- 3073
			return ____awaiter_resolve( -- 3073
				nil, -- 3073
				{ -- 3074
					success = false, -- 3074
					message = getMaxStepsReachedReason(shared) -- 3074
				} -- 3074
			) -- 3074
		end -- 3074
		if shared.decisionMode == "tool_calling" then -- 3074
			Log( -- 3078
				"Info", -- 3078
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3078
			) -- 3078
			local lastError = "tool calling validation failed" -- 3079
			local lastRaw = "" -- 3080
			local shouldFallbackToXml = false -- 3081
			do -- 3081
				local attempt = 0 -- 3082
				while attempt < shared.llmMaxTry do -- 3082
					Log( -- 3083
						"Info", -- 3083
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3083
					) -- 3083
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3084
					if shared.stopToken.stopped then -- 3084
						return ____awaiter_resolve( -- 3084
							nil, -- 3084
							{ -- 3091
								success = false, -- 3091
								message = getCancelledReason(shared) -- 3091
							} -- 3091
						) -- 3091
					end -- 3091
					if decision.success then -- 3091
						return ____awaiter_resolve(nil, decision) -- 3091
					end -- 3091
					lastError = decision.message -- 3096
					lastRaw = decision.raw or "" -- 3097
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3098
					if lastError == "missing tool call" then -- 3098
						shouldFallbackToXml = true -- 3100
						break -- 3101
					end -- 3101
					attempt = attempt + 1 -- 3082
				end -- 3082
			end -- 3082
			if shouldFallbackToXml then -- 3082
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3105
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3106
				do -- 3106
					local attempt = 0 -- 3107
					while attempt < shared.llmMaxTry do -- 3107
						Log( -- 3108
							"Info", -- 3108
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3108
						) -- 3108
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3109
						if shared.stopToken.stopped then -- 3109
							return ____awaiter_resolve( -- 3109
								nil, -- 3109
								{ -- 3116
									success = false, -- 3116
									message = getCancelledReason(shared) -- 3116
								} -- 3116
							) -- 3116
						end -- 3116
						if decision.success then -- 3116
							return ____awaiter_resolve(nil, decision) -- 3116
						end -- 3116
						lastError = decision.message -- 3121
						lastRaw = decision.raw or "" -- 3122
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3123
						attempt = attempt + 1 -- 3107
					end -- 3107
				end -- 3107
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
					return ____awaiter_resolve(nil, decision) -- 3144
				end -- 3144
				lastError = decision.message -- 3149
				lastRaw = decision.raw or "" -- 3150
				attempt = attempt + 1 -- 3134
			end -- 3134
		end -- 3134
		return ____awaiter_resolve( -- 3134
			nil, -- 3134
			{ -- 3152
				success = false, -- 3152
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3152
			} -- 3152
		) -- 3152
	end) -- 3152
end -- 3067
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3155
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3155
		local result = execRes -- 3156
		if not result.success then -- 3156
			if shared.stopToken.stopped then -- 3156
				shared.error = getCancelledReason(shared) -- 3159
				shared.done = true -- 3160
				return ____awaiter_resolve(nil, "done") -- 3160
			end -- 3160
			shared.error = result.message -- 3163
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3164
			shared.done = true -- 3165
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3166
			persistHistoryState(shared) -- 3170
			return ____awaiter_resolve(nil, "done") -- 3170
		end -- 3170
		if isDecisionBatchSuccess(result) then -- 3170
			local startStep = shared.step -- 3174
			local actions = {} -- 3175
			do -- 3175
				local i = 0 -- 3176
				while i < #result.decisions do -- 3176
					local decision = result.decisions[i + 1] -- 3177
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3178
					local step = startStep + i + 1 -- 3179
					local ____temp_99 -- 3180
					if i == 0 then -- 3180
						____temp_99 = decision.reason -- 3180
					else -- 3180
						____temp_99 = "" -- 3180
					end -- 3180
					local actionReason = ____temp_99 -- 3180
					local ____temp_100 -- 3181
					if i == 0 then -- 3181
						____temp_100 = decision.reasoningContent -- 3181
					else -- 3181
						____temp_100 = nil -- 3181
					end -- 3181
					local actionReasoningContent = ____temp_100 -- 3181
					emitAgentEvent(shared, { -- 3182
						type = "decision_made", -- 3183
						sessionId = shared.sessionId, -- 3184
						taskId = shared.taskId, -- 3185
						step = step, -- 3186
						tool = decision.tool, -- 3187
						reason = actionReason, -- 3188
						reasoningContent = actionReasoningContent, -- 3189
						params = decision.params -- 3190
					}) -- 3190
					local action = { -- 3192
						step = step, -- 3193
						toolCallId = toolCallId, -- 3194
						tool = decision.tool, -- 3195
						reason = actionReason or "", -- 3196
						reasoningContent = actionReasoningContent, -- 3197
						params = decision.params, -- 3198
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3199
					} -- 3199
					local ____shared_history_101 = shared.history -- 3199
					____shared_history_101[#____shared_history_101 + 1] = action -- 3201
					actions[#actions + 1] = action -- 3202
					i = i + 1 -- 3176
				end -- 3176
			end -- 3176
			shared.step = startStep + #actions -- 3204
			shared.pendingToolActions = actions -- 3205
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3206
			persistHistoryState(shared) -- 3212
			return ____awaiter_resolve(nil, "batch_tools") -- 3212
		end -- 3212
		if result.directSummary and result.directSummary ~= "" then -- 3212
			shared.response = result.directSummary -- 3216
			shared.completion = ____exports.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3217
			shared.done = true -- 3221
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3222
			persistHistoryState(shared) -- 3227
			return ____awaiter_resolve(nil, "done") -- 3227
		end -- 3227
		if result.tool == "finish" then -- 3227
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3231
			shared.response = finalMessage -- 3232
			shared.completion = getCompletionReport(result.params) -- 3233
			shared.done = true -- 3234
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3235
			persistHistoryState(shared) -- 3240
			return ____awaiter_resolve(nil, "done") -- 3240
		end -- 3240
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3243
		shared.step = shared.step + 1 -- 3244
		local step = shared.step -- 3245
		emitAgentEvent(shared, { -- 3246
			type = "decision_made", -- 3247
			sessionId = shared.sessionId, -- 3248
			taskId = shared.taskId, -- 3249
			step = step, -- 3250
			tool = result.tool, -- 3251
			reason = result.reason, -- 3252
			reasoningContent = result.reasoningContent, -- 3253
			params = result.params -- 3254
		}) -- 3254
		local ____shared_history_102 = shared.history -- 3254
		____shared_history_102[#____shared_history_102 + 1] = { -- 3256
			step = step, -- 3257
			toolCallId = toolCallId, -- 3258
			tool = result.tool, -- 3259
			reason = result.reason or "", -- 3260
			reasoningContent = result.reasoningContent, -- 3261
			params = result.params, -- 3262
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3263
		} -- 3263
		local action = shared.history[#shared.history] -- 3265
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3266
		shared.pendingToolActions = {action} -- 3269
		persistHistoryState(shared) -- 3270
		return ____awaiter_resolve(nil, "batch_tools") -- 3270
	end) -- 3270
end -- 3155
local ReadFileAction = __TS__Class() -- 3275
ReadFileAction.name = "ReadFileAction" -- 3275
__TS__ClassExtends(ReadFileAction, Node) -- 3275
function ReadFileAction.prototype.prep(self, shared) -- 3276
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3276
		local last = shared.history[#shared.history] -- 3277
		if not last then -- 3277
			error( -- 3278
				__TS__New(Error, "no history"), -- 3278
				0 -- 3278
			) -- 3278
		end -- 3278
		emitAgentStartEvent(shared, last) -- 3279
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3280
		if __TS__StringTrim(path) == "" then -- 3280
			error( -- 3283
				__TS__New(Error, "missing path"), -- 3283
				0 -- 3283
			) -- 3283
		end -- 3283
		local ____path_105 = path -- 3285
		local ____shared_workingDir_106 = shared.workingDir -- 3287
		local ____temp_107 = shared.useChineseResponse and "zh" or "en" -- 3288
		local ____last_params_startLine_103 = last.params.startLine -- 3289
		if ____last_params_startLine_103 == nil then -- 3289
			____last_params_startLine_103 = 1 -- 3289
		end -- 3289
		local ____TS__Number_result_108 = __TS__Number(____last_params_startLine_103) -- 3289
		local ____last_params_endLine_104 = last.params.endLine -- 3290
		if ____last_params_endLine_104 == nil then -- 3290
			____last_params_endLine_104 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3290
		end -- 3290
		return ____awaiter_resolve( -- 3290
			nil, -- 3290
			{ -- 3284
				path = ____path_105, -- 3285
				tool = "read_file", -- 3286
				workDir = ____shared_workingDir_106, -- 3287
				docLanguage = ____temp_107, -- 3288
				startLine = ____TS__Number_result_108, -- 3289
				endLine = __TS__Number(____last_params_endLine_104) -- 3290
			} -- 3290
		) -- 3290
	end) -- 3290
end -- 3276
function ReadFileAction.prototype.exec(self, input) -- 3294
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3294
		return ____awaiter_resolve( -- 3294
			nil, -- 3294
			Tools.readFile( -- 3295
				input.workDir, -- 3296
				input.path, -- 3297
				__TS__Number(input.startLine or 1), -- 3298
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3299
				input.docLanguage -- 3300
			) -- 3300
		) -- 3300
	end) -- 3300
end -- 3294
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3304
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3304
		local result = execRes -- 3305
		local last = shared.history[#shared.history] -- 3306
		if last ~= nil then -- 3306
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3308
			appendToolResultMessage(shared, last) -- 3309
			emitAgentFinishEvent(shared, last) -- 3310
		end -- 3310
		persistHistoryState(shared) -- 3312
		__TS__Await(maybeCompressHistory(shared)) -- 3313
		persistHistoryState(shared) -- 3314
		return ____awaiter_resolve(nil, "main") -- 3314
	end) -- 3314
end -- 3304
local SearchFilesAction = __TS__Class() -- 3319
SearchFilesAction.name = "SearchFilesAction" -- 3319
__TS__ClassExtends(SearchFilesAction, Node) -- 3319
function SearchFilesAction.prototype.prep(self, shared) -- 3320
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3320
		local last = shared.history[#shared.history] -- 3321
		if not last then -- 3321
			error( -- 3322
				__TS__New(Error, "no history"), -- 3322
				0 -- 3322
			) -- 3322
		end -- 3322
		emitAgentStartEvent(shared, last) -- 3323
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3323
	end) -- 3323
end -- 3320
function SearchFilesAction.prototype.exec(self, input) -- 3327
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3327
		local params = input.params -- 3328
		local ____Tools_searchFiles_123 = Tools.searchFiles -- 3329
		local ____input_workDir_115 = input.workDir -- 3330
		local ____temp_116 = params.path or "" -- 3331
		local ____temp_117 = params.pattern or "" -- 3332
		local ____params_globs_118 = params.globs -- 3333
		local ____params_useRegex_119 = params.useRegex -- 3334
		local ____params_caseSensitive_120 = params.caseSensitive -- 3335
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_121 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3337
		local ____math_max_111 = math.max -- 3338
		local ____math_floor_110 = math.floor -- 3338
		local ____params_limit_109 = params.limit -- 3338
		if ____params_limit_109 == nil then -- 3338
			____params_limit_109 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3338
		end -- 3338
		local ____math_max_111_result_122 = ____math_max_111( -- 3338
			1, -- 3338
			____math_floor_110(__TS__Number(____params_limit_109)) -- 3338
		) -- 3338
		local ____math_max_114 = math.max -- 3339
		local ____math_floor_113 = math.floor -- 3339
		local ____params_offset_112 = params.offset -- 3339
		if ____params_offset_112 == nil then -- 3339
			____params_offset_112 = 0 -- 3339
		end -- 3339
		local result = __TS__Await(____Tools_searchFiles_123({ -- 3329
			workDir = ____input_workDir_115, -- 3330
			path = ____temp_116, -- 3331
			pattern = ____temp_117, -- 3332
			globs = ____params_globs_118, -- 3333
			useRegex = ____params_useRegex_119, -- 3334
			caseSensitive = ____params_caseSensitive_120, -- 3335
			includeContent = true, -- 3336
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_121, -- 3337
			limit = ____math_max_111_result_122, -- 3338
			offset = ____math_max_114( -- 3339
				0, -- 3339
				____math_floor_113(__TS__Number(____params_offset_112)) -- 3339
			), -- 3339
			groupByFile = params.groupByFile == true -- 3340
		})) -- 3340
		return ____awaiter_resolve(nil, result) -- 3340
	end) -- 3340
end -- 3327
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3345
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3345
		local last = shared.history[#shared.history] -- 3346
		if last ~= nil then -- 3346
			local result = execRes -- 3348
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3349
			appendToolResultMessage(shared, last) -- 3350
			emitAgentFinishEvent(shared, last) -- 3351
		end -- 3351
		persistHistoryState(shared) -- 3353
		__TS__Await(maybeCompressHistory(shared)) -- 3354
		persistHistoryState(shared) -- 3355
		return ____awaiter_resolve(nil, "main") -- 3355
	end) -- 3355
end -- 3345
local SearchDoraAPIAction = __TS__Class() -- 3360
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3360
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3360
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3361
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3361
		local last = shared.history[#shared.history] -- 3362
		if not last then -- 3362
			error( -- 3363
				__TS__New(Error, "no history"), -- 3363
				0 -- 3363
			) -- 3363
		end -- 3363
		emitAgentStartEvent(shared, last) -- 3364
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3364
	end) -- 3364
end -- 3361
function SearchDoraAPIAction.prototype.exec(self, input) -- 3368
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3368
		local params = input.params -- 3369
		local ____Tools_searchDoraAPI_132 = Tools.searchDoraAPI -- 3370
		local ____temp_128 = params.pattern or "" -- 3371
		local ____temp_129 = params.docSource or "api" -- 3372
		local ____temp_130 = input.useChineseResponse and "zh" or "en" -- 3373
		local ____temp_131 = params.programmingLanguage or "ts" -- 3374
		local ____math_min_127 = math.min -- 3375
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_126 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3375
		local ____math_max_125 = math.max -- 3375
		local ____params_limit_124 = params.limit -- 3375
		if ____params_limit_124 == nil then -- 3375
			____params_limit_124 = 8 -- 3375
		end -- 3375
		local result = __TS__Await(____Tools_searchDoraAPI_132({ -- 3370
			pattern = ____temp_128, -- 3371
			docSource = ____temp_129, -- 3372
			docLanguage = ____temp_130, -- 3373
			programmingLanguage = ____temp_131, -- 3374
			limit = ____math_min_127( -- 3375
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_126, -- 3375
				____math_max_125( -- 3375
					1, -- 3375
					__TS__Number(____params_limit_124) -- 3375
				) -- 3375
			), -- 3375
			useRegex = params.useRegex, -- 3376
			caseSensitive = false, -- 3377
			includeContent = true, -- 3378
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3379
		})) -- 3379
		return ____awaiter_resolve(nil, result) -- 3379
	end) -- 3379
end -- 3368
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3384
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3384
		local last = shared.history[#shared.history] -- 3385
		if last ~= nil then -- 3385
			local result = execRes -- 3387
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3388
			appendToolResultMessage(shared, last) -- 3389
			emitAgentFinishEvent(shared, last) -- 3390
		end -- 3390
		persistHistoryState(shared) -- 3392
		__TS__Await(maybeCompressHistory(shared)) -- 3393
		persistHistoryState(shared) -- 3394
		return ____awaiter_resolve(nil, "main") -- 3394
	end) -- 3394
end -- 3384
local ListFilesAction = __TS__Class() -- 3399
ListFilesAction.name = "ListFilesAction" -- 3399
__TS__ClassExtends(ListFilesAction, Node) -- 3399
function ListFilesAction.prototype.prep(self, shared) -- 3400
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3400
		local last = shared.history[#shared.history] -- 3401
		if not last then -- 3401
			error( -- 3402
				__TS__New(Error, "no history"), -- 3402
				0 -- 3402
			) -- 3402
		end -- 3402
		emitAgentStartEvent(shared, last) -- 3403
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3403
	end) -- 3403
end -- 3400
function ListFilesAction.prototype.exec(self, input) -- 3407
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3407
		local params = input.params -- 3408
		local ____Tools_listFiles_139 = Tools.listFiles -- 3409
		local ____input_workDir_136 = input.workDir -- 3410
		local ____temp_137 = params.path or "" -- 3411
		local ____params_globs_138 = params.globs -- 3412
		local ____math_max_135 = math.max -- 3413
		local ____math_floor_134 = math.floor -- 3413
		local ____params_maxEntries_133 = params.maxEntries -- 3413
		if ____params_maxEntries_133 == nil then -- 3413
			____params_maxEntries_133 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3413
		end -- 3413
		local result = ____Tools_listFiles_139({ -- 3409
			workDir = ____input_workDir_136, -- 3410
			path = ____temp_137, -- 3411
			globs = ____params_globs_138, -- 3412
			maxEntries = ____math_max_135( -- 3413
				1, -- 3413
				____math_floor_134(__TS__Number(____params_maxEntries_133)) -- 3413
			) -- 3413
		}) -- 3413
		return ____awaiter_resolve(nil, result) -- 3413
	end) -- 3413
end -- 3407
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3418
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3418
		local last = shared.history[#shared.history] -- 3419
		if last ~= nil then -- 3419
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3421
			appendToolResultMessage(shared, last) -- 3422
			emitAgentFinishEvent(shared, last) -- 3423
		end -- 3423
		persistHistoryState(shared) -- 3425
		__TS__Await(maybeCompressHistory(shared)) -- 3426
		persistHistoryState(shared) -- 3427
		return ____awaiter_resolve(nil, "main") -- 3427
	end) -- 3427
end -- 3418
local DeleteFileAction = __TS__Class() -- 3432
DeleteFileAction.name = "DeleteFileAction" -- 3432
__TS__ClassExtends(DeleteFileAction, Node) -- 3432
function DeleteFileAction.prototype.prep(self, shared) -- 3433
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3433
		local last = shared.history[#shared.history] -- 3434
		if not last then -- 3434
			error( -- 3435
				__TS__New(Error, "no history"), -- 3435
				0 -- 3435
			) -- 3435
		end -- 3435
		emitAgentStartEvent(shared, last) -- 3436
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3437
		if __TS__StringTrim(targetFile) == "" then -- 3437
			error( -- 3440
				__TS__New(Error, "missing target_file"), -- 3440
				0 -- 3440
			) -- 3440
		end -- 3440
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3440
	end) -- 3440
end -- 3433
function DeleteFileAction.prototype.exec(self, input) -- 3444
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3444
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3445
		if not result.success then -- 3445
			return ____awaiter_resolve(nil, result) -- 3445
		end -- 3445
		return ____awaiter_resolve(nil, { -- 3445
			success = true, -- 3453
			changed = true, -- 3454
			mode = "delete", -- 3455
			checkpointId = result.checkpointId, -- 3456
			checkpointSeq = result.checkpointSeq, -- 3457
			files = {{path = input.targetFile, op = "delete"}} -- 3458
		}) -- 3458
	end) -- 3458
end -- 3444
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3462
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3462
		local last = shared.history[#shared.history] -- 3463
		if last ~= nil then -- 3463
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3465
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3466
			appendToolResultMessage(shared, last) -- 3467
			emitAgentFinishEvent(shared, last) -- 3468
			local result = last.result -- 3469
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3469
				emitAgentEvent(shared, { -- 3474
					type = "checkpoint_created", -- 3475
					sessionId = shared.sessionId, -- 3476
					taskId = shared.taskId, -- 3477
					step = last.step, -- 3478
					tool = "delete_file", -- 3479
					checkpointId = result.checkpointId, -- 3480
					checkpointSeq = result.checkpointSeq, -- 3481
					files = result.files -- 3482
				}) -- 3482
			end -- 3482
		end -- 3482
		persistHistoryState(shared) -- 3489
		__TS__Await(maybeCompressHistory(shared)) -- 3490
		persistHistoryState(shared) -- 3491
		return ____awaiter_resolve(nil, "main") -- 3491
	end) -- 3491
end -- 3462
local BuildAction = __TS__Class() -- 3496
BuildAction.name = "BuildAction" -- 3496
__TS__ClassExtends(BuildAction, Node) -- 3496
function BuildAction.prototype.prep(self, shared) -- 3497
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3497
		local last = shared.history[#shared.history] -- 3498
		if not last then -- 3498
			error( -- 3499
				__TS__New(Error, "no history"), -- 3499
				0 -- 3499
			) -- 3499
		end -- 3499
		emitAgentStartEvent(shared, last) -- 3500
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3500
	end) -- 3500
end -- 3497
function BuildAction.prototype.exec(self, input) -- 3504
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3504
		local params = input.params -- 3505
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3506
		return ____awaiter_resolve(nil, result) -- 3506
	end) -- 3506
end -- 3504
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3513
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3513
		local last = shared.history[#shared.history] -- 3514
		if last ~= nil then -- 3514
			last.result = sanitizeBuildResultForHistory(execRes) -- 3516
			appendToolResultMessage(shared, last) -- 3517
			emitAgentFinishEvent(shared, last) -- 3518
		end -- 3518
		persistHistoryState(shared) -- 3520
		__TS__Await(maybeCompressHistory(shared)) -- 3521
		persistHistoryState(shared) -- 3522
		return ____awaiter_resolve(nil, "main") -- 3522
	end) -- 3522
end -- 3513
local SpawnSubAgentAction = __TS__Class() -- 3527
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3527
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3527
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3528
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3528
		local last = shared.history[#shared.history] -- 3538
		if not last then -- 3538
			error( -- 3539
				__TS__New(Error, "no history"), -- 3539
				0 -- 3539
			) -- 3539
		end -- 3539
		emitAgentStartEvent(shared, last) -- 3540
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3541
			last.params.filesHint, -- 3542
			function(____, item) return type(item) == "string" end -- 3542
		) or nil -- 3542
		return ____awaiter_resolve( -- 3542
			nil, -- 3542
			{ -- 3544
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3545
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3546
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3547
				filesHint = filesHint, -- 3548
				sessionId = shared.sessionId, -- 3549
				projectRoot = shared.workingDir, -- 3550
				spawnSubAgent = shared.spawnSubAgent, -- 3551
				disabledAgentTools = shared.disabledAgentTools -- 3552
			} -- 3552
		) -- 3552
	end) -- 3552
end -- 3528
function SpawnSubAgentAction.prototype.exec(self, input) -- 3556
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3556
		if not input.spawnSubAgent then -- 3556
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3556
		end -- 3556
		if input.sessionId == nil or input.sessionId <= 0 then -- 3556
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3556
		end -- 3556
		local ____Log_145 = Log -- 3572
		local ____temp_142 = #input.title -- 3572
		local ____temp_143 = #input.prompt -- 3572
		local ____temp_144 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3572
		local ____opt_140 = input.filesHint -- 3572
		____Log_145( -- 3572
			"Info", -- 3572
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_142)) .. " prompt_len=") .. tostring(____temp_143)) .. " expected_len=") .. tostring(____temp_144)) .. " files_hint_count=") .. tostring(____opt_140 and #____opt_140 or 0) -- 3572
		) -- 3572
		local result = __TS__Await(input.spawnSubAgent({ -- 3573
			parentSessionId = input.sessionId, -- 3574
			projectRoot = input.projectRoot, -- 3575
			title = input.title, -- 3576
			prompt = input.prompt, -- 3577
			expectedOutput = input.expectedOutput, -- 3578
			filesHint = input.filesHint, -- 3579
			disabledAgentTools = input.disabledAgentTools -- 3580
		})) -- 3580
		if not result.success then -- 3580
			return ____awaiter_resolve(nil, result) -- 3580
		end -- 3580
		return ____awaiter_resolve(nil, { -- 3580
			success = true, -- 3586
			sessionId = result.sessionId, -- 3587
			taskId = result.taskId, -- 3588
			title = result.title, -- 3589
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3590
		}) -- 3590
	end) -- 3590
end -- 3556
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3594
		local last = shared.history[#shared.history] -- 3595
		if last ~= nil then -- 3595
			last.result = execRes -- 3597
			if execRes.success == true then -- 3597
				shared.hasSpawnedSubAgentThisTask = true -- 3599
			end -- 3599
			appendToolResultMessage(shared, last) -- 3601
			emitAgentFinishEvent(shared, last) -- 3602
		end -- 3602
		persistHistoryState(shared) -- 3604
		__TS__Await(maybeCompressHistory(shared)) -- 3605
		persistHistoryState(shared) -- 3606
		return ____awaiter_resolve(nil, "main") -- 3606
	end) -- 3606
end -- 3594
local ListSubAgentsAction = __TS__Class() -- 3611
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3611
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3611
function ListSubAgentsAction.prototype.prep(self, shared) -- 3612
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3612
		local last = shared.history[#shared.history] -- 3622
		if not last then -- 3622
			error( -- 3623
				__TS__New(Error, "no history"), -- 3623
				0 -- 3623
			) -- 3623
		end -- 3623
		emitAgentStartEvent(shared, last) -- 3624
		return ____awaiter_resolve( -- 3624
			nil, -- 3624
			{ -- 3625
				sessionId = shared.sessionId, -- 3626
				projectRoot = shared.workingDir, -- 3627
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3628
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3629
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3630
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3631
				listSubAgents = shared.listSubAgents, -- 3632
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3633
			} -- 3633
		) -- 3633
	end) -- 3633
end -- 3612
function ListSubAgentsAction.prototype.exec(self, input) -- 3637
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3637
		if not input.listSubAgents then -- 3637
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3637
		end -- 3637
		if input.sessionId == nil or input.sessionId <= 0 then -- 3637
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3637
		end -- 3637
		local result = __TS__Await(input.listSubAgents({ -- 3653
			sessionId = input.sessionId, -- 3654
			projectRoot = input.projectRoot, -- 3655
			status = input.status, -- 3656
			limit = input.limit, -- 3657
			offset = input.offset, -- 3658
			query = input.query -- 3659
		})) -- 3659
		return ____awaiter_resolve( -- 3659
			nil, -- 3659
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3661
		) -- 3661
	end) -- 3661
end -- 3637
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3669
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3669
		local last = shared.history[#shared.history] -- 3670
		if last ~= nil then -- 3670
			last.result = execRes -- 3672
			appendToolResultMessage(shared, last) -- 3673
			emitAgentFinishEvent(shared, last) -- 3674
		end -- 3674
		persistHistoryState(shared) -- 3676
		__TS__Await(maybeCompressHistory(shared)) -- 3677
		persistHistoryState(shared) -- 3678
		return ____awaiter_resolve(nil, "main") -- 3678
	end) -- 3678
end -- 3669
EditFileAction = __TS__Class() -- 3683
EditFileAction.name = "EditFileAction" -- 3683
__TS__ClassExtends(EditFileAction, Node) -- 3683
function EditFileAction.prototype.prep(self, shared) -- 3684
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3684
		local last = shared.history[#shared.history] -- 3685
		if not last then -- 3685
			error( -- 3686
				__TS__New(Error, "no history"), -- 3686
				0 -- 3686
			) -- 3686
		end -- 3686
		emitAgentStartEvent(shared, last) -- 3687
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3688
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3691
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3692
		if __TS__StringTrim(path) == "" then -- 3692
			error( -- 3693
				__TS__New(Error, "missing path"), -- 3693
				0 -- 3693
			) -- 3693
		end -- 3693
		return ____awaiter_resolve(nil, { -- 3693
			path = path, -- 3694
			oldStr = oldStr, -- 3694
			newStr = newStr, -- 3694
			taskId = shared.taskId, -- 3694
			workDir = shared.workingDir -- 3694
		}) -- 3694
	end) -- 3694
end -- 3684
function EditFileAction.prototype.exec(self, input) -- 3697
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3697
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3698
		if not readRes.success then -- 3698
			if input.oldStr ~= "" then -- 3698
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3698
			end -- 3698
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3703
			if not createRes.success then -- 3703
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3703
			end -- 3703
			return ____awaiter_resolve( -- 3703
				nil, -- 3703
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3710
					success = true, -- 3711
					changed = true, -- 3712
					mode = "create", -- 3713
					checkpointId = createRes.checkpointId, -- 3714
					checkpointSeq = createRes.checkpointSeq, -- 3715
					files = {{path = input.path, op = "create"}} -- 3716
				}) -- 3716
			) -- 3716
		end -- 3716
		if input.oldStr == "" then -- 3716
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3716
				return ____awaiter_resolve( -- 3716
					nil, -- 3716
					{ -- 3721
						success = false, -- 3722
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3723
						actualSaved = false, -- 3724
						actualSavedCharacters = 0, -- 3725
						currentFileExists = true, -- 3726
						currentCharacters = #readRes.content, -- 3727
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3728
					} -- 3728
				) -- 3728
			end -- 3728
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3731
			if not overwriteRes.success then -- 3731
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3731
			end -- 3731
			return ____awaiter_resolve( -- 3731
				nil, -- 3731
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3738
					success = true, -- 3739
					changed = true, -- 3740
					mode = "overwrite", -- 3741
					checkpointId = overwriteRes.checkpointId, -- 3742
					checkpointSeq = overwriteRes.checkpointSeq, -- 3743
					files = {{path = input.path, op = "write"}} -- 3744
				}) -- 3744
			) -- 3744
		end -- 3744
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3749
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3750
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3751
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3754
		if occurrences == 0 then -- 3754
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3756
			if not indentTolerant.success then -- 3756
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3756
			end -- 3756
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3760
			if not applyRes.success then -- 3760
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3760
			end -- 3760
			return ____awaiter_resolve( -- 3760
				nil, -- 3760
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3767
					success = true, -- 3768
					changed = true, -- 3769
					mode = "replace_indent_tolerant", -- 3770
					checkpointId = applyRes.checkpointId, -- 3771
					checkpointSeq = applyRes.checkpointSeq, -- 3772
					files = {{path = input.path, op = "write"}} -- 3773
				}) -- 3773
			) -- 3773
		end -- 3773
		if occurrences > 1 then -- 3773
			return ____awaiter_resolve( -- 3773
				nil, -- 3773
				{ -- 3777
					success = false, -- 3777
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3777
				} -- 3777
			) -- 3777
		end -- 3777
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3781
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3782
		if not applyRes.success then -- 3782
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3782
		end -- 3782
		return ____awaiter_resolve( -- 3782
			nil, -- 3782
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3789
				success = true, -- 3790
				changed = true, -- 3791
				mode = "replace", -- 3792
				checkpointId = applyRes.checkpointId, -- 3793
				checkpointSeq = applyRes.checkpointSeq, -- 3794
				files = {{path = input.path, op = "write"}} -- 3795
			}) -- 3795
		) -- 3795
	end) -- 3795
end -- 3697
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3799
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3799
		local last = shared.history[#shared.history] -- 3800
		if last ~= nil then -- 3800
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3802
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3803
			appendToolResultMessage(shared, last) -- 3804
			emitAgentFinishEvent(shared, last) -- 3805
			local result = last.result -- 3806
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3806
				emitAgentEvent(shared, { -- 3811
					type = "checkpoint_created", -- 3812
					sessionId = shared.sessionId, -- 3813
					taskId = shared.taskId, -- 3814
					step = last.step, -- 3815
					tool = last.tool, -- 3816
					checkpointId = result.checkpointId, -- 3817
					checkpointSeq = result.checkpointSeq, -- 3818
					files = result.files -- 3819
				}) -- 3819
			end -- 3819
		end -- 3819
		persistHistoryState(shared) -- 3826
		__TS__Await(maybeCompressHistory(shared)) -- 3827
		persistHistoryState(shared) -- 3828
		return ____awaiter_resolve(nil, "main") -- 3828
	end) -- 3828
end -- 3799
local FetchUrlAction = __TS__Class() -- 3833
FetchUrlAction.name = "FetchUrlAction" -- 3833
__TS__ClassExtends(FetchUrlAction, Node) -- 3833
function FetchUrlAction.prototype.prep(self, shared) -- 3834
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3834
		local last = shared.history[#shared.history] -- 3835
		if not last then -- 3835
			error( -- 3836
				__TS__New(Error, "no history"), -- 3836
				0 -- 3836
			) -- 3836
		end -- 3836
		emitAgentStartEvent(shared, last) -- 3837
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3837
	end) -- 3837
end -- 3834
function FetchUrlAction.prototype.exec(self, input) -- 3841
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3841
		return ____awaiter_resolve( -- 3841
			nil, -- 3841
			executeToolAction(input.shared, input.action) -- 3842
		) -- 3842
	end) -- 3842
end -- 3841
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3845
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3845
		local last = shared.history[#shared.history] -- 3846
		if last ~= nil then -- 3846
			last.result = execRes -- 3848
			appendToolResultMessage(shared, last) -- 3849
			emitAgentFinishEvent(shared, last) -- 3850
		end -- 3850
		persistHistoryState(shared) -- 3852
		__TS__Await(maybeCompressHistory(shared)) -- 3853
		persistHistoryState(shared) -- 3854
		return ____awaiter_resolve(nil, "main") -- 3854
	end) -- 3854
end -- 3845
local function emitCheckpointEventForAction(shared, action) -- 3859
	local result = action.result -- 3860
	if not result then -- 3860
		return -- 3861
	end -- 3861
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3861
		emitAgentEvent(shared, { -- 3866
			type = "checkpoint_created", -- 3867
			sessionId = shared.sessionId, -- 3868
			taskId = shared.taskId, -- 3869
			step = action.step, -- 3870
			tool = action.tool, -- 3871
			checkpointId = result.checkpointId, -- 3872
			checkpointSeq = result.checkpointSeq, -- 3873
			files = result.files -- 3874
		}) -- 3874
	end -- 3874
end -- 3859
local function canRunBatchActionInParallel(self, action) -- 4386
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4387
end -- 4386
local function partitionToolCalls(actions) -- 4395
	local batches = {} -- 4396
	do -- 4396
		local i = 0 -- 4397
		while i < #actions do -- 4397
			local action = actions[i + 1] -- 4398
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4399
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4400
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4400
				local ____lastBatch_actions_178 = lastBatch.actions -- 4400
				____lastBatch_actions_178[#____lastBatch_actions_178 + 1] = action -- 4402
			else -- 4402
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4404
			end -- 4404
			i = i + 1 -- 4397
		end -- 4397
	end -- 4397
	return batches -- 4407
end -- 4395
local BatchToolAction = __TS__Class() -- 4410
BatchToolAction.name = "BatchToolAction" -- 4410
__TS__ClassExtends(BatchToolAction, Node) -- 4410
function BatchToolAction.prototype.prep(self, shared) -- 4411
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4411
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4411
	end) -- 4411
end -- 4411
function BatchToolAction.prototype.exec(self, input) -- 4415
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4415
		local shared = input.shared -- 4416
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4417
		local preExecuted = shared.preExecutedResults -- 4418
		local batches = partitionToolCalls(input.actions) -- 4419
		local parallelBatchCount = #__TS__ArrayFilter( -- 4420
			batches, -- 4420
			function(____, b) return b.isConcurrencySafe end -- 4420
		) -- 4420
		local serialBatchCount = #__TS__ArrayFilter( -- 4421
			batches, -- 4421
			function(____, b) return not b.isConcurrencySafe end -- 4421
		) -- 4421
		Log( -- 4422
			"Info", -- 4422
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4422
		) -- 4422
		do -- 4422
			local batchIdx = 0 -- 4424
			while batchIdx < #batches do -- 4424
				do -- 4424
					local batch = batches[batchIdx + 1] -- 4425
					if shared.stopToken.stopped then -- 4425
						for ____, action in ipairs(batch.actions) do -- 4427
							if not action.result then -- 4427
								action.result = { -- 4429
									success = false, -- 4429
									message = getCancelledReason(shared) -- 4429
								} -- 4429
							end -- 4429
						end -- 4429
						goto __continue731 -- 4432
					end -- 4432
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4432
						local preExecCount = #__TS__ArrayFilter( -- 4436
							batch.actions, -- 4436
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4436
						) -- 4436
						Log( -- 4437
							"Info", -- 4437
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4437
						) -- 4437
						do -- 4437
							local i = 0 -- 4438
							while i < #batch.actions do -- 4438
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4439
								i = i + 1 -- 4438
							end -- 4438
						end -- 4438
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4441
							batch.actions, -- 4441
							function(____, action) -- 4441
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4441
									if shared.stopToken.stopped then -- 4441
										action.result = { -- 4443
											success = false, -- 4443
											message = getCancelledReason(shared) -- 4443
										} -- 4443
										return ____awaiter_resolve(nil, action) -- 4443
									end -- 4443
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4446
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4447
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4448
									return ____awaiter_resolve(nil, action) -- 4448
								end) -- 4448
							end -- 4441
						))) -- 4441
						do -- 4441
							local i = 0 -- 4451
							while i < #batch.actions do -- 4451
								local action = batch.actions[i + 1] -- 4452
								if not action.result then -- 4452
									action.result = {success = false, message = "tool did not produce a result"} -- 4454
								end -- 4454
								appendToolResultMessage(shared, action) -- 4456
								emitAgentFinishEvent(shared, action) -- 4457
								emitCheckpointEventForAction(shared, action) -- 4458
								i = i + 1 -- 4451
							end -- 4451
						end -- 4451
					else -- 4451
						Log( -- 4461
							"Info", -- 4461
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4461
						) -- 4461
						do -- 4461
							local i = 0 -- 4462
							while i < #batch.actions do -- 4462
								local action = batch.actions[i + 1] -- 4463
								emitAgentStartEvent(shared, action) -- 4464
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4465
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4466
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4467
								appendToolResultMessage(shared, action) -- 4468
								emitAgentFinishEvent(shared, action) -- 4469
								emitCheckpointEventForAction(shared, action) -- 4470
								persistHistoryState(shared) -- 4471
								if shared.stopToken.stopped then -- 4471
									break -- 4473
								end -- 4473
								i = i + 1 -- 4462
							end -- 4462
						end -- 4462
					end -- 4462
				end -- 4462
				::__continue731:: -- 4462
				batchIdx = batchIdx + 1 -- 4424
			end -- 4424
		end -- 4424
		local spawnSeen = spawnedBeforeBatch -- 4478
		local didDelegatedForegroundWork = false -- 4479
		do -- 4479
			local i = 0 -- 4480
			while i < #input.actions do -- 4480
				do -- 4480
					local action = input.actions[i + 1] -- 4481
					if action.tool == "spawn_sub_agent" then -- 4481
						local ____opt_181 = action.result -- 4481
						if (____opt_181 and ____opt_181.success) == true then -- 4481
							spawnSeen = true -- 4483
						end -- 4483
						goto __continue750 -- 4484
					end -- 4484
					if spawnSeen and action.tool ~= "finish" then -- 4484
						didDelegatedForegroundWork = true -- 4487
					end -- 4487
				end -- 4487
				::__continue750:: -- 4487
				i = i + 1 -- 4480
			end -- 4480
		end -- 4480
		if didDelegatedForegroundWork then -- 4480
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4491
		end -- 4491
		persistHistoryState(shared) -- 4493
		return ____awaiter_resolve(nil, input.actions) -- 4493
	end) -- 4493
end -- 4415
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4497
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4497
		shared.pendingToolActions = nil -- 4498
		shared.preExecutedResults = nil -- 4499
		persistHistoryState(shared) -- 4500
		__TS__Await(maybeCompressHistory(shared)) -- 4501
		persistHistoryState(shared) -- 4502
		return ____awaiter_resolve(nil, "main") -- 4502
	end) -- 4502
end -- 4497
local EndNode = __TS__Class() -- 4507
EndNode.name = "EndNode" -- 4507
__TS__ClassExtends(EndNode, Node) -- 4507
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4508
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4508
		return ____awaiter_resolve(nil, nil) -- 4508
	end) -- 4508
end -- 4508
local CodingAgentFlow = __TS__Class() -- 4513
CodingAgentFlow.name = "CodingAgentFlow" -- 4513
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4513
function CodingAgentFlow.prototype.____constructor(self, role) -- 4514
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4515
	local read = __TS__New(ReadFileAction, 1, 0) -- 4516
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4517
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4518
	local list = __TS__New(ListFilesAction, 1, 0) -- 4519
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4520
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4521
	local build = __TS__New(BuildAction, 1, 0) -- 4522
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4523
	local edit = __TS__New(EditFileAction, 1, 0) -- 4524
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4525
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4526
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4527
	local done = __TS__New(EndNode, 1, 0) -- 4528
	main:on("batch_tools", batch) -- 4530
	main:on("grep_files", search) -- 4531
	main:on("search_dora_api", searchDora) -- 4532
	main:on("glob_files", list) -- 4533
	main:on("fetch_url", fetch) -- 4534
	main:on("execute_command", exec) -- 4535
	if role == "main" then -- 4535
		main:on("read_file", read) -- 4537
		main:on("delete_file", del) -- 4538
		main:on("build", build) -- 4539
		main:on("edit_file", edit) -- 4540
		main:on("list_sub_agents", listSub) -- 4541
		main:on("spawn_sub_agent", spawn) -- 4542
	else -- 4542
		main:on("read_file", read) -- 4544
		main:on("delete_file", del) -- 4545
		main:on("build", build) -- 4546
		main:on("edit_file", edit) -- 4547
	end -- 4547
	main:on("done", done) -- 4549
	search:on("main", main) -- 4551
	searchDora:on("main", main) -- 4552
	list:on("main", main) -- 4553
	listSub:on("main", main) -- 4554
	spawn:on("main", main) -- 4555
	batch:on("main", main) -- 4556
	read:on("main", main) -- 4557
	del:on("main", main) -- 4558
	build:on("main", main) -- 4559
	edit:on("main", main) -- 4560
	fetch:on("main", main) -- 4561
	exec:on("main", main) -- 4562
	Flow.prototype.____constructor(self, main) -- 4564
end -- 4514
local function runCodingAgentAsync(options) -- 4600
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4600
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4600
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4600
		end -- 4600
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4604
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4605
		if not llmConfigRes.success then -- 4605
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4605
		end -- 4605
		local llmConfig = llmConfigRes.config -- 4611
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4612
		if not taskRes.success then -- 4612
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4612
		end -- 4612
		local compressor = __TS__New(MemoryCompressor, { -- 4619
			compressionThreshold = 0.8, -- 4620
			compressionTargetThreshold = 0.5, -- 4621
			maxCompressionRounds = 3, -- 4622
			projectDir = options.workDir, -- 4623
			llmConfig = llmConfig, -- 4624
			promptPack = options.promptPack, -- 4625
			scope = options.memoryScope -- 4626
		}) -- 4626
		local persistedSession = compressor:getStorage():readSessionState() -- 4628
		local promptPack = compressor:getPromptPack() -- 4629
		local freshProject = inspectFreshProject(options.workDir) -- 4630
		local freshProjectBuildPending = freshProject.fresh -- 4631
		local freshProjectCodeFile = freshProject.codeFile -- 4632
		local shared = { -- 4634
			sessionId = options.sessionId, -- 4635
			taskId = taskRes.taskId, -- 4636
			role = options.role or "main", -- 4637
			maxSteps = math.max( -- 4638
				1, -- 4638
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4638
			), -- 4638
			llmMaxTry = math.max( -- 4639
				1, -- 4639
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4639
			), -- 4639
			step = 0, -- 4640
			done = false, -- 4641
			stopToken = options.stopToken or ({stopped = false}), -- 4642
			response = "", -- 4643
			userQuery = normalizedPrompt, -- 4644
			workingDir = options.workDir, -- 4645
			useChineseResponse = options.useChineseResponse == true, -- 4646
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4647
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4650
			llmConfig = llmConfig, -- 4651
			onEvent = options.onEvent, -- 4652
			promptPack = promptPack, -- 4653
			history = {}, -- 4654
			messages = persistedSession.messages, -- 4655
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4656
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4657
			memory = {compressor = compressor}, -- 4659
			skills = {loader = AgentSkills.createSkillsLoader({projectDir = options.workDir, disabledAgentTools = options.disabledAgentTools or ({})})}, -- 4663
			spawnSubAgent = options.spawnSubAgent, -- 4669
			listSubAgents = options.listSubAgents, -- 4670
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4671
			freshProjectBuildPending = freshProjectBuildPending, -- 4672
			freshProjectCodeFile = freshProjectCodeFile, -- 4673
			hasSpawnedSubAgentThisTask = false, -- 4674
			delegatedForegroundBatches = 0 -- 4675
		} -- 4675
		local ____hasReturned, ____returnValue -- 4675
		local ____try = __TS__AsyncAwaiter(function() -- 4675
			emitAgentEvent(shared, { -- 4679
				type = "task_started", -- 4680
				sessionId = shared.sessionId, -- 4681
				taskId = shared.taskId, -- 4682
				prompt = shared.userQuery, -- 4683
				workDir = shared.workingDir, -- 4684
				maxSteps = shared.maxSteps -- 4685
			}) -- 4685
			if shared.stopToken.stopped then -- 4685
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4688
				____hasReturned = true -- 4689
				____returnValue = emitAgentTaskFinishEvent( -- 4689
					shared, -- 4689
					false, -- 4689
					getCancelledReason(shared) -- 4689
				) -- 4689
				return -- 4689
			end -- 4689
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4691
			local promptCommand = getPromptCommand(shared.userQuery) -- 4692
			if promptCommand == "clear" then -- 4692
				____hasReturned = true -- 4694
				____returnValue = clearSessionHistory(shared) -- 4694
				return -- 4694
			end -- 4694
			if promptCommand == "compact" then -- 4694
				if shared.role == "sub" then -- 4694
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4698
					____hasReturned = true -- 4699
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4699
					return -- 4699
				end -- 4699
				____hasReturned = true -- 4707
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4707
				return -- 4707
			end -- 4707
			__TS__Await(maybeCompressHistory(shared, true, normalizedPrompt)) -- 4709
			if shared.stopToken.stopped then -- 4709
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4711
				____hasReturned = true -- 4712
				____returnValue = emitAgentTaskFinishEvent( -- 4712
					shared, -- 4712
					false, -- 4712
					getCancelledReason(shared) -- 4712
				) -- 4712
				return -- 4712
			end -- 4712
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4714
			persistHistoryState(shared) -- 4718
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4719
			__TS__Await(flow:run(shared)) -- 4720
			if shared.stopToken.stopped then -- 4720
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4722
				____hasReturned = true -- 4723
				____returnValue = emitAgentTaskFinishEvent( -- 4723
					shared, -- 4723
					false, -- 4723
					getCancelledReason(shared) -- 4723
				) -- 4723
				return -- 4723
			end -- 4723
			if shared.error then -- 4723
				____hasReturned = true -- 4726
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4726
				return -- 4726
			end -- 4726
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4729
			____hasReturned = true -- 4730
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4730
			return -- 4730
		end) -- 4730
		____try = ____try.catch( -- 4730
			____try, -- 4730
			function(____, e) -- 4730
				return __TS__AsyncAwaiter(function() -- 4730
					____hasReturned = true -- 4733
					____returnValue = finalizeAgentFailure( -- 4733
						shared, -- 4733
						tostring(e) -- 4733
					) -- 4733
					return -- 4733
				end) -- 4733
			end -- 4733
		) -- 4733
		__TS__Await(____try) -- 4678
		if ____hasReturned then -- 4678
			return ____awaiter_resolve(nil, ____returnValue) -- 4678
		end -- 4678
	end) -- 4678
end -- 4600
function ____exports.runCodingAgent(options, callback) -- 4737
	local ____self_183 = runCodingAgentAsync(options) -- 4737
	____self_183["then"]( -- 4737
		____self_183, -- 4737
		function(____, result) return callback(result) end -- 4738
	) -- 4738
end -- 4737
return ____exports -- 4737