-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
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
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
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
local isRecord, isArray, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, isToolAllowedForRole, getFinishMessage, normalizeCompletionText, normalizeCompletionTextList, getCompletionReport, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, ensureToolCallId, hasXMLParam, inferToolNameFromXMLParams, parseDSMLAttribute, extractDSMLReason, parseDSMLToolCallObjectFromText, parseXMLToolCallObjectFromText, parseDecisionObject, getDecisionPath, validateDecisionForShared, clampIntegerParam, parseReadLineParam, validateDecision, validateCompletionForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, tryParseAndValidateDecision, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, COMPLETION_TEXT_MAX_CHARS, COMPLETION_LIST_MAX_ITEMS, COMPLETION_EVIDENCE_MAX_ITEMS, EditFileAction -- 1
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
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 14
local normalizeQuestionnaire = ____AgentQuestionnaire.normalizeQuestionnaire -- 14
function isRecord(value) -- 17
	return type(value) == "table" -- 18
end -- 18
function isArray(value) -- 21
	return __TS__ArrayIsArray(value) -- 22
end -- 22
function emitAgentEvent(shared, event) -- 445
	if shared.onEvent then -- 445
		do -- 445
			local function ____catch(____error) -- 445
				Log( -- 450
					"Error", -- 450
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 450
				) -- 450
			end -- 450
			local ____try, ____hasReturned = pcall(function() -- 450
				shared:onEvent(event) -- 448
			end) -- 448
			if not ____try then -- 448
				____catch(____hasReturned) -- 448
			end -- 448
		end -- 448
	end -- 448
end -- 448
function getCancelledReason(shared) -- 619
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 619
		return shared.stopToken.reason -- 620
	end -- 620
	return shared.useChineseResponse and "已取消" or "cancelled" -- 621
end -- 621
function ____exports.normalizePolicyPath(path) -- 683
	return AgentRuntimePolicy.normalizeAgentPath(path) -- 684
end -- 683
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 692
	return AgentRuntimePolicy.isMainAgentMemoryPath(path) -- 693
end -- 692
function truncateText(text, maxLen) -- 857
	if #text <= maxLen then -- 857
		return text -- 858
	end -- 858
	local nextPos = utf8.offset(text, maxLen + 1) -- 859
	if nextPos == nil then -- 859
		return text -- 860
	end -- 860
	return string.sub(text, 1, nextPos - 1) .. "..." -- 861
end -- 861
function utf8TakeHead(text, maxChars) -- 864
	if maxChars <= 0 or text == "" then -- 864
		return "" -- 865
	end -- 865
	local nextPos = utf8.offset(text, maxChars + 1) -- 866
	if nextPos == nil then -- 866
		return text -- 867
	end -- 867
	return string.sub(text, 1, nextPos - 1) -- 868
end -- 868
function getReplyLanguageDirective(shared) -- 871
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 872
end -- 872
function replacePromptVars(template, vars) -- 877
	local output = template -- 878
	for key in pairs(vars) do -- 879
		output = table.concat( -- 880
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 880
			vars[key] or "" or "," -- 880
		) -- 880
	end -- 880
	return output -- 882
end -- 882
function limitReadContentForHistory(content, tool) -- 885
	local lines = __TS__StringSplit(content, "\n") -- 886
	local overLineLimit = #lines > AgentConfig.AGENT_LIMITS.historyReadFileMaxLines -- 887
	local limitedByLines = overLineLimit and table.concat( -- 888
		__TS__ArraySlice(lines, 0, AgentConfig.AGENT_LIMITS.historyReadFileMaxLines), -- 889
		"\n" -- 889
	) or content -- 889
	if #limitedByLines <= AgentConfig.AGENT_LIMITS.historyReadFileMaxChars and not overLineLimit then -- 889
		return content -- 892
	end -- 892
	local limited = #limitedByLines > AgentConfig.AGENT_LIMITS.historyReadFileMaxChars and utf8TakeHead(limitedByLines, AgentConfig.AGENT_LIMITS.historyReadFileMaxChars) or limitedByLines -- 894
	local reasons = {} -- 897
	if #content > AgentConfig.AGENT_LIMITS.historyReadFileMaxChars then -- 897
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 898
	end -- 898
	if #lines > AgentConfig.AGENT_LIMITS.historyReadFileMaxLines then -- 898
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 899
	end -- 899
	local hint = "Narrow the requested line range." -- 900
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 901
end -- 901
function sanitizeReadResultForHistory(tool, result) -- 916
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 916
		return result -- 918
	end -- 918
	local clone = {} -- 920
	for key in pairs(result) do -- 921
		clone[key] = result[key] -- 922
	end -- 922
	clone.content = limitReadContentForHistory(result.content, tool) -- 924
	return clone -- 925
end -- 925
function sanitizeSearchMatchesForHistory(items, maxItems) -- 928
	local shown = math.min(#items, maxItems) -- 932
	local out = {} -- 933
	do -- 933
		local i = 0 -- 934
		while i < shown do -- 934
			local row = items[i + 1] -- 935
			out[#out + 1] = { -- 936
				file = row.file, -- 937
				line = row.line, -- 938
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 939
			} -- 939
			i = i + 1 -- 934
		end -- 934
	end -- 934
	return out -- 944
end -- 944
function sanitizeSearchResultForHistory(tool, result) -- 947
	if result.success ~= true or not isArray(result.results) then -- 947
		return result -- 951
	end -- 951
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 951
		return result -- 952
	end -- 952
	local clone = {} -- 953
	for key in pairs(result) do -- 954
		clone[key] = result[key] -- 955
	end -- 955
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 957
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 958
	if tool == "grep_files" and isArray(result.groupedResults) then -- 958
		local grouped = result.groupedResults -- 963
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 964
		local sanitizedGroups = {} -- 965
		do -- 965
			local i = 0 -- 966
			while i < shown do -- 966
				local row = grouped[i + 1] -- 967
				sanitizedGroups[#sanitizedGroups + 1] = { -- 968
					file = row.file, -- 969
					totalMatches = row.totalMatches, -- 970
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 971
				} -- 971
				i = i + 1 -- 966
			end -- 966
		end -- 966
		clone.groupedResults = sanitizedGroups -- 976
	end -- 976
	return clone -- 978
end -- 978
function sanitizeListFilesResultForHistory(result) -- 981
	if result.success ~= true or not isArray(result.files) then -- 981
		return result -- 982
	end -- 982
	local clone = {} -- 983
	for key in pairs(result) do -- 984
		clone[key] = result[key] -- 985
	end -- 985
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 987
	return clone -- 988
end -- 988
function sanitizeBuildResultForHistory(result) -- 991
	if not isArray(result.messages) then -- 991
		return result -- 992
	end -- 992
	local clone = {} -- 993
	for key in pairs(result) do -- 994
		clone[key] = result[key] -- 995
	end -- 995
	local messages = result.messages -- 997
	local ordered = __TS__ArraySort( -- 998
		__TS__ArraySlice(messages), -- 998
		function(____, a, b) -- 998
			local aFailed = a.success ~= true -- 999
			local bFailed = b.success ~= true -- 1000
			if aFailed == bFailed then -- 1000
				return 0 -- 1001
			end -- 1001
			return aFailed and -1 or 1 -- 1002
		end -- 998
	) -- 998
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1004
	local sanitized = {} -- 1005
	do -- 1005
		local i = 0 -- 1006
		while i < shown do -- 1006
			local item = ordered[i + 1] -- 1007
			local next = {} -- 1008
			for key in pairs(item) do -- 1009
				local value = item[key] -- 1010
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1011
			end -- 1011
			sanitized[#sanitized + 1] = next -- 1015
			i = i + 1 -- 1006
		end -- 1006
	end -- 1006
	clone.messages = sanitized -- 1017
	if #ordered > shown then -- 1017
		clone.truncatedMessages = #ordered - shown -- 1019
	end -- 1019
	return clone -- 1021
end -- 1021
function ____exports.getDecisionDisabledAgentTools(shared) -- 1039
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1043
end -- 1039
function getDecisionToolDefinitions(shared) -- 1046
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1047
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1048
	local base = shared.promptPack.toolDefinitionsDetailed -- 1051
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1052
	if usesDefaultToolPrompts then -- 1052
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1055
			shared.role, -- 1055
			{ -- 1055
				includeFinish = true, -- 1056
				includeXmlRules = true, -- 1057
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1058
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1059
				workMode = shared.workMode -- 1060
			} -- 1060
		) -- 1060
		return replacePromptVars(definitions, params) -- 1062
	end -- 1062
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1064
	if (shared and shared.decisionMode) ~= "xml" then -- 1064
		return withRole -- 1069
	end -- 1069
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1071
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1072
end -- 1072
function isToolAllowedForRole(shared, tool) -- 1086
	return __TS__ArrayIndexOf( -- 1087
		AgentToolRegistry.getAllowedToolsForRole( -- 1087
			shared.role, -- 1087
			{ -- 1087
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1088
				workMode = shared.workMode -- 1089
			} -- 1089
		), -- 1089
		tool -- 1090
	) >= 0 -- 1090
end -- 1090
function getFinishMessage(params, fallback) -- 1504
	if fallback == nil then -- 1504
		fallback = "" -- 1504
	end -- 1504
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1504
		return __TS__StringTrim(params.message) -- 1506
	end -- 1506
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1506
		return __TS__StringTrim(params.response) -- 1509
	end -- 1509
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1509
		return __TS__StringTrim(params.summary) -- 1512
	end -- 1512
	return __TS__StringTrim(fallback) -- 1514
end -- 1514
function normalizeCompletionText(value) -- 1521
	if type(value) ~= "string" then -- 1521
		return "" -- 1522
	end -- 1522
	return __TS__StringSlice( -- 1523
		__TS__StringTrim(sanitizeUTF8(value)), -- 1523
		0, -- 1523
		COMPLETION_TEXT_MAX_CHARS -- 1523
	) -- 1523
end -- 1523
function normalizeCompletionTextList(value, maxItems) -- 1526
	if maxItems == nil then -- 1526
		maxItems = COMPLETION_LIST_MAX_ITEMS -- 1526
	end -- 1526
	if not isArray(value) then -- 1526
		return {} -- 1527
	end -- 1527
	local items = {} -- 1528
	do -- 1528
		local i = 0 -- 1529
		while i < #value and #items < maxItems do -- 1529
			local item = normalizeCompletionText(value[i + 1]) -- 1530
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 1530
				items[#items + 1] = item -- 1531
			end -- 1531
			i = i + 1 -- 1529
		end -- 1529
	end -- 1529
	return items -- 1533
end -- 1533
function ____exports.normalizeAgentCompletionReport(value) -- 1536
	local row = value and not isArray(value) and isRecord(value) and value or ({}) -- 1537
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 1538
	local validation = {} -- 1541
	if isArray(row.validation) then -- 1541
		do -- 1541
			local i = 0 -- 1543
			while i < #row.validation and #validation < COMPLETION_LIST_MAX_ITEMS do -- 1543
				do -- 1543
					local raw = row.validation[i + 1] -- 1544
					if not raw or isArray(raw) or not isRecord(raw) then -- 1544
						goto __continue224 -- 1545
					end -- 1545
					local kind = (raw.kind == "runtime" or raw.kind == "manual") and raw.kind or (raw.kind == "build" and "build" or nil) -- 1546
					local result = (raw.result == "passed" or raw.result == "failed" or raw.result == "not_run") and raw.result or nil -- 1547
					if kind == nil or result == nil then -- 1547
						goto __continue224 -- 1548
					end -- 1548
					validation[#validation + 1] = { -- 1549
						kind = kind, -- 1550
						result = result, -- 1551
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS) -- 1552
					} -- 1552
				end -- 1552
				::__continue224:: -- 1552
				i = i + 1 -- 1543
			end -- 1543
		end -- 1543
	end -- 1543
	local learningCandidates = {} -- 1556
	if isArray(row.learningCandidates) then -- 1556
		do -- 1556
			local i = 0 -- 1558
			while i < #row.learningCandidates and #learningCandidates < COMPLETION_LIST_MAX_ITEMS do -- 1558
				do -- 1558
					local raw = row.learningCandidates[i + 1] -- 1559
					if not raw or isArray(raw) or not isRecord(raw) then -- 1559
						goto __continue229 -- 1560
					end -- 1560
					local claim = normalizeCompletionText(raw.claim) -- 1561
					if claim == "" then -- 1561
						goto __continue229 -- 1562
					end -- 1562
					learningCandidates[#learningCandidates + 1] = { -- 1563
						claim = claim, -- 1564
						scope = (raw.scope == "file" or raw.scope == "engine") and raw.scope or "project", -- 1565
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS), -- 1566
						confidence = raw.confidence == "inferred" and "inferred" or "observed" -- 1567
					} -- 1567
				end -- 1567
				::__continue229:: -- 1567
				i = i + 1 -- 1558
			end -- 1558
		end -- 1558
	end -- 1558
	return { -- 1571
		outcome = outcome, -- 1572
		validation = validation, -- 1573
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 1574
		assumptions = normalizeCompletionTextList(row.assumptions), -- 1575
		learningCandidates = learningCandidates -- 1576
	} -- 1576
end -- 1536
function getCompletionReport(params) -- 1580
	return ____exports.normalizeAgentCompletionReport(params) -- 1581
end -- 1581
function persistHistoryState(shared) -- 1584
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1585
end -- 1585
function getActiveConversationMessages(shared) -- 1592
	local activeMessages = {} -- 1593
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1593
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1600
	end -- 1600
	do -- 1600
		local i = shared.lastConsolidatedIndex -- 1604
		while i < #shared.messages do -- 1604
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1605
			i = i + 1 -- 1604
		end -- 1604
	end -- 1604
	return activeMessages -- 1607
end -- 1607
function getActiveRealMessageCount(shared) -- 1610
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1611
end -- 1611
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1614
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1620
	local previousActiveStart = shared.lastConsolidatedIndex -- 1621
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1622
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1623
	if type(carryMessageIndex) == "number" then -- 1623
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1623
		else -- 1623
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1631
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1634
		end -- 1634
	else -- 1634
		shared.carryMessageIndex = nil -- 1639
	end -- 1639
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1639
		shared.carryMessageIndex = nil -- 1649
	end -- 1649
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1657
	shared.resumeCheckpointPending = true -- 1658
	shared.resumeRequiredTool = nil -- 1659
	shared.resumeNarrowReadMode = true -- 1660
	if shared.unbuiltEdits == true then -- 1660
		shared.resumeRequiredTool = "build" -- 1668
	end -- 1668
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1677
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1677
		local marker = "**Next tool**:" -- 1688
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1689
		if markerIndex >= 0 then -- 1689
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1691
			local toolNames = { -- 1692
				"read_file", -- 1693
				"edit_file", -- 1693
				"delete_file", -- 1693
				"grep_files", -- 1693
				"search_dora_api", -- 1693
				"glob_files", -- 1694
				"build", -- 1694
				"fetch_url", -- 1694
				"execute_command", -- 1694
				"list_sub_agents", -- 1694
				"spawn_sub_agent", -- 1695
				"finish" -- 1695
			} -- 1695
			do -- 1695
				local i = 0 -- 1697
				while i < #toolNames do -- 1697
					local tool = toolNames[i + 1] -- 1698
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1698
						shared.resumeRequiredTool = tool -- 1700
						break -- 1701
					end -- 1701
					i = i + 1 -- 1697
				end -- 1697
			end -- 1697
		end -- 1697
	end -- 1697
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1697
		shared.resumeRequiredTool = nil -- 1707
	end -- 1707
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1707
		shared.resumeRequiredTool = nil -- 1710
	end -- 1710
end -- 1710
function ensureToolCallId(toolCallId) -- 1725
	if toolCallId and toolCallId ~= "" then -- 1725
		return toolCallId -- 1726
	end -- 1726
	return createLocalToolCallId() -- 1727
end -- 1727
function hasXMLParam(params, name) -- 1760
	return params[name] ~= nil -- 1761
end -- 1761
function inferToolNameFromXMLParams(params) -- 1764
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1764
		return "edit_file" -- 1766
	end -- 1766
	if hasXMLParam(params, "target_file") then -- 1766
		return "delete_file" -- 1769
	end -- 1769
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1769
		if hasXMLParam(params, "path") then -- 1769
			return "read_file" -- 1772
		end -- 1772
		return nil -- 1773
	end -- 1773
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1773
		if hasXMLParam(params, "pattern") then -- 1773
			return "search_dora_api" -- 1776
		end -- 1776
		return nil -- 1777
	end -- 1777
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1777
		if hasXMLParam(params, "pattern") then -- 1777
			return "grep_files" -- 1780
		end -- 1780
		return nil -- 1781
	end -- 1781
	if hasXMLParam(params, "globs") then -- 1781
		if hasXMLParam(params, "pattern") then -- 1781
			return "grep_files" -- 1784
		end -- 1784
		return "glob_files" -- 1785
	end -- 1785
	if hasXMLParam(params, "maxEntries") then -- 1785
		return "glob_files" -- 1788
	end -- 1788
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1788
		return "finish" -- 1791
	end -- 1791
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1791
		return "spawn_sub_agent" -- 1794
	end -- 1794
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1794
		return "list_sub_agents" -- 1797
	end -- 1797
	return nil -- 1799
end -- 1799
function parseDSMLAttribute(source, offset, name) -- 1802
	local attrOpen = name .. "=\"" -- 1803
	local attrStart = (string.find( -- 1804
		source, -- 1804
		attrOpen, -- 1804
		math.max(offset + 1, 1), -- 1804
		true -- 1804
	) or 0) - 1 -- 1804
	if attrStart < 0 then -- 1804
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1805
	end -- 1805
	local valueStart = attrStart + #attrOpen -- 1806
	local valueEnd = (string.find( -- 1807
		source, -- 1807
		"\"", -- 1807
		math.max(valueStart + 1, 1), -- 1807
		true -- 1807
	) or 0) - 1 -- 1807
	if valueEnd < 0 then -- 1807
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1808
	end -- 1808
	return { -- 1809
		success = true, -- 1810
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1811
		next = valueEnd + 1 -- 1812
	} -- 1812
end -- 1812
function extractDSMLReason(text, invokeStart, tool) -- 1816
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1817
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1818
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1818
		return before -- 1821
	end -- 1821
	if tool == "finish" then -- 1821
		return "" -- 1822
	end -- 1822
	return "Converted provider-native tool call syntax to XML." -- 1823
end -- 1823
function parseDSMLToolCallObjectFromText(text) -- 1826
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1827
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1828
	if invokeStart < 0 then -- 1828
		return {success = false, message = "missing DSML invoke"} -- 1829
	end -- 1829
	local nameStart = invokeStart + #invokeOpen -- 1830
	local nameEnd = (string.find( -- 1831
		text, -- 1831
		"\"", -- 1831
		math.max(nameStart + 1, 1), -- 1831
		true -- 1831
	) or 0) - 1 -- 1831
	if nameEnd < 0 then -- 1831
		return {success = false, message = "unterminated DSML invoke name"} -- 1832
	end -- 1832
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1833
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1833
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1835
	end -- 1835
	local invokeOpenEnd = (string.find( -- 1837
		text, -- 1837
		">", -- 1837
		math.max(nameEnd + 1, 1), -- 1837
		true -- 1837
	) or 0) - 1 -- 1837
	if invokeOpenEnd < 0 then -- 1837
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1838
	end -- 1838
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1839
	local invokeEnd = (string.find( -- 1840
		text, -- 1840
		invokeClose, -- 1840
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1840
		true -- 1840
	) or 0) - 1 -- 1840
	if invokeEnd < 0 then -- 1840
		return {success = false, message = "missing DSML invoke close tag"} -- 1841
	end -- 1841
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1843
	local params = {} -- 1844
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1845
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1846
	local pos = 0 -- 1847
	while pos < #body do -- 1847
		local start = (string.find( -- 1849
			body, -- 1849
			paramOpen, -- 1849
			math.max(pos + 1, 1), -- 1849
			true -- 1849
		) or 0) - 1 -- 1849
		if start < 0 then -- 1849
			break -- 1850
		end -- 1850
		local openEnd = (string.find( -- 1851
			body, -- 1851
			">", -- 1851
			math.max(start + #paramOpen + 1, 1), -- 1851
			true -- 1851
		) or 0) - 1 -- 1851
		if openEnd < 0 then -- 1851
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1852
		end -- 1852
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1853
		if not name.success then -- 1853
			return name -- 1854
		end -- 1854
		local close = (string.find( -- 1855
			body, -- 1855
			paramClose, -- 1855
			math.max(openEnd + 1 + 1, 1), -- 1855
			true -- 1855
		) or 0) - 1 -- 1855
		if close < 0 then -- 1855
			return {success = false, message = "missing DSML parameter close tag"} -- 1856
		end -- 1856
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1857
		pos = close + #paramClose -- 1858
	end -- 1858
	return { -- 1860
		success = true, -- 1861
		obj = { -- 1862
			tool = toolName, -- 1863
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1864
			params = params -- 1865
		} -- 1865
	} -- 1865
end -- 1865
function parseXMLToolCallObjectFromText(text) -- 1870
	local children = parseXMLObjectFromText(text, "tool_call") -- 1871
	local rawObj -- 1872
	if children.success then -- 1872
		rawObj = children.obj -- 1874
	else -- 1874
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1876
		if dsml.success then -- 1876
			return dsml -- 1877
		end -- 1877
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1878
		local paramsCloseToken = "</params>" -- 1879
		if toolStart >= 0 then -- 1879
			local paramsClose = (string.find( -- 1881
				text, -- 1881
				paramsCloseToken, -- 1881
				math.max(toolStart + 1, 1), -- 1881
				true -- 1881
			) or 0) - 1 -- 1881
			if paramsClose >= toolStart then -- 1881
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1883
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1884
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1884
					rawObj = bare.obj -- 1886
				end -- 1886
			end -- 1886
		end -- 1886
		if rawObj == nil then -- 1886
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1891
			if paramsOpen < 0 then -- 1891
				return children -- 1892
			end -- 1892
			local paramsCloseOnly = (string.find( -- 1893
				text, -- 1893
				paramsCloseToken, -- 1893
				math.max(paramsOpen + 1, 1), -- 1893
				true -- 1893
			) or 0) - 1 -- 1893
			if paramsCloseOnly < paramsOpen then -- 1893
				return children -- 1894
			end -- 1894
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1895
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1896
			if not paramsOnly.success then -- 1896
				return children -- 1897
			end -- 1897
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1898
			if inferredTool == nil then -- 1898
				return children -- 1899
			end -- 1899
			local ____temp_52 -- 1904
			if inferredTool == "finish" then -- 1904
				____temp_52 = nil -- 1904
			else -- 1904
				____temp_52 = "Inferred tool from XML params." -- 1904
			end -- 1904
			return {success = true, obj = {tool = inferredTool, reason = ____temp_52, params = paramsOnly.obj}} -- 1900
		end -- 1900
	end -- 1900
	if rawObj == nil then -- 1900
		return children -- 1910
	end -- 1910
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1911
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1912
	if not params.success then -- 1912
		return {success = false, message = params.message} -- 1916
	end -- 1916
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1918
end -- 1918
function parseDecisionObject(rawObj) -- 2014
	if type(rawObj.tool) ~= "string" then -- 2014
		return {success = false, message = "missing tool"} -- 2015
	end -- 2015
	local tool = rawObj.tool -- 2016
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2016
		return {success = false, message = "unknown tool: " .. tool} -- 2018
	end -- 2018
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2020
	if tool ~= "finish" and (not reason or reason == "") then -- 2020
		return {success = false, message = tool .. " requires top-level reason"} -- 2024
	end -- 2024
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2026
	return {success = true, tool = tool, params = params, reason = reason} -- 2027
end -- 2027
function getDecisionPath(params) -- 2149
	if type(params.path) == "string" then -- 2149
		return __TS__StringTrim(params.path) -- 2150
	end -- 2150
	if type(params.target_file) == "string" then -- 2150
		return __TS__StringTrim(params.target_file) -- 2151
	end -- 2151
	return "" -- 2152
end -- 2152
function validateDecisionForShared(shared, tool, params) -- 2155
	if not isToolAllowedForRole(shared, tool) then -- 2155
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2161
	end -- 2161
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2161
		local path = getDecisionPath(params) -- 2164
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2164
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2166
		end -- 2166
	end -- 2166
	if tool == "delete_file" then -- 2166
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2170
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2170
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2172
		end -- 2172
	end -- 2172
	return {success = true} -- 2175
end -- 2175
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2178
	local num = __TS__Number(value) -- 2179
	if not __TS__NumberIsFinite(num) then -- 2179
		num = fallback -- 2180
	end -- 2180
	num = math.floor(num) -- 2181
	if num < minValue then -- 2181
		num = minValue -- 2182
	end -- 2182
	if maxValue ~= nil and num > maxValue then -- 2182
		num = maxValue -- 2183
	end -- 2183
	return num -- 2184
end -- 2184
function parseReadLineParam(value, fallback, paramName) -- 2187
	local num = __TS__Number(value) -- 2192
	if not __TS__NumberIsFinite(num) then -- 2192
		num = fallback -- 2193
	end -- 2193
	num = math.floor(num) -- 2194
	if num == 0 then -- 2194
		return {success = false, message = paramName .. " cannot be 0"} -- 2196
	end -- 2196
	return {success = true, value = num} -- 2198
end -- 2198
function validateDecision(tool, params) -- 2201
	if tool == "finish" then -- 2201
		local message = getFinishMessage(params) -- 2206
		if message == "" then -- 2206
			return {success = false, message = "finish requires params.message"} -- 2207
		end -- 2207
		params.message = message -- 2208
		local completion = getCompletionReport(params) -- 2209
		params.outcome = completion.outcome -- 2210
		params.validation = completion.validation -- 2211
		params.knownIssues = completion.knownIssues -- 2212
		params.assumptions = completion.assumptions -- 2213
		params.learningCandidates = completion.learningCandidates -- 2214
		return {success = true, params = params} -- 2215
	end -- 2215
	if tool == "ask_user" then -- 2215
		local normalized = normalizeQuestionnaire(params) -- 2219
		if not normalized.success then -- 2219
			return normalized -- 2220
		end -- 2220
		return {success = true, params = normalized.schema} -- 2221
	end -- 2221
	if tool == "read_file" then -- 2221
		local path = getDecisionPath(params) -- 2225
		if path == "" then -- 2225
			return {success = false, message = "read_file requires path"} -- 2226
		end -- 2226
		params.path = path -- 2227
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2228
		if not startLineRes.success then -- 2228
			return startLineRes -- 2229
		end -- 2229
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2230
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2231
		if not endLineRes.success then -- 2231
			return endLineRes -- 2232
		end -- 2232
		params.startLine = startLineRes.value -- 2233
		params.endLine = endLineRes.value -- 2234
		return {success = true, params = params} -- 2235
	end -- 2235
	if tool == "edit_file" then -- 2235
		local path = getDecisionPath(params) -- 2239
		if path == "" then -- 2239
			return {success = false, message = "edit_file requires path"} -- 2240
		end -- 2240
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2241
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2242
		params.path = path -- 2243
		params.old_str = oldStr -- 2244
		params.new_str = newStr -- 2245
		return {success = true, params = params} -- 2246
	end -- 2246
	if tool == "delete_file" then -- 2246
		local targetFile = getDecisionPath(params) -- 2250
		if targetFile == "" then -- 2250
			return {success = false, message = "delete_file requires target_file"} -- 2251
		end -- 2251
		params.target_file = targetFile -- 2252
		return {success = true, params = params} -- 2253
	end -- 2253
	if tool == "grep_files" then -- 2253
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2257
		if pattern == "" then -- 2257
			return {success = false, message = "grep_files requires pattern"} -- 2258
		end -- 2258
		params.pattern = pattern -- 2259
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2260
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2261
		return {success = true, params = params} -- 2262
	end -- 2262
	if tool == "search_dora_api" then -- 2262
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2266
		if pattern == "" then -- 2266
			return {success = false, message = "search_dora_api requires pattern"} -- 2267
		end -- 2267
		params.pattern = pattern -- 2268
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2269
		return {success = true, params = params} -- 2270
	end -- 2270
	if tool == "glob_files" then -- 2270
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2274
		return {success = true, params = params} -- 2275
	end -- 2275
	if tool == "build" then -- 2275
		local path = getDecisionPath(params) -- 2279
		if path ~= "" then -- 2279
			params.path = path -- 2281
		end -- 2281
		return {success = true, params = params} -- 2283
	end -- 2283
	if tool == "list_sub_agents" then -- 2283
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2287
		if status ~= "" then -- 2287
			params.status = status -- 2289
		end -- 2289
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2291
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2292
		if type(params.query) == "string" then -- 2292
			params.query = __TS__StringTrim(params.query) -- 2294
		end -- 2294
		return {success = true, params = params} -- 2296
	end -- 2296
	if tool == "spawn_sub_agent" then -- 2296
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2300
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2301
		if prompt == "" then -- 2301
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2302
		end -- 2302
		if title == "" then -- 2302
			return {success = false, message = "spawn_sub_agent requires title"} -- 2303
		end -- 2303
		params.prompt = prompt -- 2304
		params.title = title -- 2305
		if type(params.expectedOutput) == "string" then -- 2305
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2307
		end -- 2307
		if isArray(params.filesHint) then -- 2307
			params.filesHint = __TS__ArrayMap( -- 2310
				__TS__ArrayFilter( -- 2310
					params.filesHint, -- 2310
					function(____, item) return type(item) == "string" end -- 2311
				), -- 2311
				function(____, item) return sanitizeUTF8(item) end -- 2312
			) -- 2312
		end -- 2312
		return {success = true, params = params} -- 2314
	end -- 2314
	return {success = true, params = params} -- 2317
end -- 2317
function validateCompletionForRole(role, tool, params) -- 2320
	if role ~= "sub" or tool ~= "finish" then -- 2320
		return {success = true} -- 2325
	end -- 2325
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2325
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2327
	end -- 2327
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2329
	do -- 2329
		local i = 0 -- 2330
		while i < #requiredArrays do -- 2330
			local name = requiredArrays[i + 1] -- 2331
			if not isArray(params[name]) then -- 2331
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2333
			end -- 2333
			i = i + 1 -- 2330
		end -- 2330
	end -- 2330
	return {success = true} -- 2336
end -- 2336
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2339
	if includeToolDefinitions == nil then -- 2339
		includeToolDefinitions = false -- 2339
	end -- 2339
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2340
	local sections = { -- 2343
		shared.promptPack.agentIdentityPrompt, -- 2344
		rolePrompt, -- 2345
		getReplyLanguageDirective(shared) -- 2346
	} -- 2346
	if shared.role == "main" then -- 2346
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2349
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2350
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2350
			sections[#sections + 1] = table.concat( -- 2352
				{ -- 2352
					"# Current Living Development Plan", -- 2353
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2354
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2354
						sanitizeUTF8(Content:load(planPath)), -- 2355
						12000 -- 2355
					), -- 2355
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2355
						sanitizeUTF8(Content:load(progressPath)), -- 2356
						12000 -- 2356
					) -- 2356
				}, -- 2356
				"\n\n" -- 2357
			) -- 2357
		end -- 2357
	end -- 2357
	if shared.decisionMode == "tool_calling" then -- 2357
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2361
	end -- 2361
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2363
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2364
	if memoryContext ~= "" then -- 2364
		sections[#sections + 1] = memoryContext -- 2366
	end -- 2366
	local skillsSection = buildSkillsSection(shared) -- 2368
	if skillsSection ~= "" then -- 2368
		sections[#sections + 1] = skillsSection -- 2370
	end -- 2370
	if includeToolDefinitions then -- 2370
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2373
		if shared.decisionMode == "xml" then -- 2373
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2375
		end -- 2375
	end -- 2375
	return table.concat(sections, "\n\n") -- 2378
end -- 2378
function buildSkillsSection(shared) -- 2381
	local ____opt_71 = shared.skills -- 2381
	if not (____opt_71 and ____opt_71.loader) then -- 2381
		return "" -- 2383
	end -- 2383
	return shared.skills.loader:buildSkillsPromptSection() -- 2385
end -- 2385
function buildXmlDecisionInstruction(shared, feedback) -- 2528
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2529
end -- 2529
function tryParseAndValidateDecision(rawText, shared) -- 2613
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2614
	if not parsed.success then -- 2614
		return {success = false, message = parsed.message, raw = rawText} -- 2616
	end -- 2616
	local decision = parseDecisionObject(parsed.obj) -- 2618
	if not decision.success then -- 2618
		return {success = false, message = decision.message, raw = rawText} -- 2620
	end -- 2620
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2622
	if not completionValidation.success then -- 2622
		return {success = false, message = completionValidation.message, raw = rawText} -- 2624
	end -- 2624
	local validation = validateDecision(decision.tool, decision.params) -- 2626
	if not validation.success then -- 2626
		return {success = false, message = validation.message, raw = rawText} -- 2628
	end -- 2628
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params) -- 2630
	if not sharedValidation.success then -- 2630
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2632
	end -- 2632
	decision.params = validation.params -- 2634
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2635
	return decision -- 2636
end -- 2636
function executeToolAction(shared, action) -- 3962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3962
		if shared.stopToken.stopped then -- 3962
			return ____awaiter_resolve( -- 3962
				nil, -- 3962
				{ -- 3964
					success = false, -- 3964
					message = getCancelledReason(shared) -- 3964
				} -- 3964
			) -- 3964
		end -- 3964
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 3964
			shared.resumeRequiredTool = nil -- 3967
			shared.resumeCheckpointPending = false -- 3968
		end -- 3968
		local params = action.params -- 3970
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 3971
		if not sharedValidation.success then -- 3971
			return ____awaiter_resolve(nil, sharedValidation) -- 3971
		end -- 3971
		if action.tool == "read_file" then -- 3971
			local ____params_startLine_146 = params.startLine -- 3974
			if ____params_startLine_146 == nil then -- 3974
				____params_startLine_146 = 1 -- 3974
			end -- 3974
			local startLine = __TS__Number(____params_startLine_146) -- 3974
			local ____params_endLine_147 = params.endLine -- 3975
			if ____params_endLine_147 == nil then -- 3975
				____params_endLine_147 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3975
			end -- 3975
			local endLine = __TS__Number(____params_endLine_147) -- 3975
			local clippedAfterCompression = false -- 3976
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 3976
				endLine = startLine + 159 -- 3983
				clippedAfterCompression = true -- 3984
			end -- 3984
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3986
			if __TS__StringTrim(path) == "" then -- 3986
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3986
			end -- 3986
			local result = Tools.readFile( -- 3990
				shared.workingDir, -- 3991
				path, -- 3992
				startLine, -- 3993
				endLine, -- 3994
				shared.useChineseResponse and "zh" or "en" -- 3995
			) -- 3995
			if clippedAfterCompression and result.success == true then -- 3995
				result.clipped = true -- 3998
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 3999
			end -- 3999
			return ____awaiter_resolve(nil, result) -- 3999
		end -- 3999
		if action.tool ~= "build" then -- 3999
			shared.resumeNarrowReadMode = false -- 4009
		end -- 4009
		if action.tool == "grep_files" then -- 4009
			local searchPath = params.path or "" -- 4011
			local searchGlobs = params.globs -- 4012
			local ____Tools_searchFiles_161 = Tools.searchFiles -- 4013
			local ____shared_workingDir_154 = shared.workingDir -- 4014
			local ____temp_155 = params.pattern or "" -- 4016
			local ____params_globs_156 = params.globs -- 4017
			local ____params_useRegex_157 = params.useRegex -- 4018
			local ____params_caseSensitive_158 = params.caseSensitive -- 4019
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_159 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4021
			local ____math_max_150 = math.max -- 4022
			local ____math_floor_149 = math.floor -- 4022
			local ____params_limit_148 = params.limit -- 4022
			if ____params_limit_148 == nil then -- 4022
				____params_limit_148 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4022
			end -- 4022
			local ____math_max_150_result_160 = ____math_max_150( -- 4022
				1, -- 4022
				____math_floor_149(__TS__Number(____params_limit_148)) -- 4022
			) -- 4022
			local ____math_max_153 = math.max -- 4023
			local ____math_floor_152 = math.floor -- 4023
			local ____params_offset_151 = params.offset -- 4023
			if ____params_offset_151 == nil then -- 4023
				____params_offset_151 = 0 -- 4023
			end -- 4023
			local result = __TS__Await(____Tools_searchFiles_161({ -- 4013
				workDir = ____shared_workingDir_154, -- 4014
				path = searchPath, -- 4015
				pattern = ____temp_155, -- 4016
				globs = ____params_globs_156, -- 4017
				useRegex = ____params_useRegex_157, -- 4018
				caseSensitive = ____params_caseSensitive_158, -- 4019
				includeContent = true, -- 4020
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_159, -- 4021
				limit = ____math_max_150_result_160, -- 4022
				offset = ____math_max_153( -- 4023
					0, -- 4023
					____math_floor_152(__TS__Number(____params_offset_151)) -- 4023
				), -- 4023
				groupByFile = params.groupByFile == true -- 4024
			})) -- 4024
			return ____awaiter_resolve(nil, result) -- 4024
		end -- 4024
		if action.tool == "search_dora_api" then -- 4024
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4029
			local ____Tools_searchDoraAPI_170 = Tools.searchDoraAPI -- 4030
			local ____temp_166 = params.pattern or "" -- 4031
			local ____temp_167 = params.docSource or "api" -- 4032
			local ____temp_168 = shared.useChineseResponse and "zh" or "en" -- 4033
			local ____temp_169 = params.programmingLanguage or "ts" -- 4034
			local ____math_min_165 = math.min -- 4035
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_164 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4035
			local ____math_max_163 = math.max -- 4035
			local ____params_limit_162 = params.limit -- 4035
			if ____params_limit_162 == nil then -- 4035
				____params_limit_162 = 8 -- 4035
			end -- 4035
			local result = __TS__Await(____Tools_searchDoraAPI_170({ -- 4030
				pattern = ____temp_166, -- 4031
				docSource = ____temp_167, -- 4032
				docLanguage = ____temp_168, -- 4033
				programmingLanguage = ____temp_169, -- 4034
				limit = ____math_min_165( -- 4035
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_164, -- 4035
					____math_max_163( -- 4035
						1, -- 4035
						__TS__Number(____params_limit_162) -- 4035
					) -- 4035
				), -- 4035
				useRegex = params.useRegex, -- 4036
				caseSensitive = false, -- 4037
				includeContent = true, -- 4038
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4039
			})) -- 4039
			return ____awaiter_resolve(nil, result) -- 4039
		end -- 4039
		if action.tool == "glob_files" then -- 4039
			local ____Tools_listFiles_177 = Tools.listFiles -- 4044
			local ____shared_workingDir_174 = shared.workingDir -- 4045
			local ____temp_175 = params.path or "" -- 4046
			local ____params_globs_176 = params.globs -- 4047
			local ____math_max_173 = math.max -- 4048
			local ____math_floor_172 = math.floor -- 4048
			local ____params_maxEntries_171 = params.maxEntries -- 4048
			if ____params_maxEntries_171 == nil then -- 4048
				____params_maxEntries_171 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4048
			end -- 4048
			local result = ____Tools_listFiles_177({ -- 4044
				workDir = ____shared_workingDir_174, -- 4045
				path = ____temp_175, -- 4046
				globs = ____params_globs_176, -- 4047
				maxEntries = ____math_max_173( -- 4048
					1, -- 4048
					____math_floor_172(__TS__Number(____params_maxEntries_171)) -- 4048
				) -- 4048
			}) -- 4048
			return ____awaiter_resolve(nil, result) -- 4048
		end -- 4048
		if action.tool == "ask_user" then -- 4048
			if not shared.publishQuestionnaire then -- 4048
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4048
			end -- 4048
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4048
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4048
			end -- 4048
			local normalized = normalizeQuestionnaire(params) -- 4055
			if not normalized.success then -- 4055
				return ____awaiter_resolve(nil, normalized) -- 4055
			end -- 4055
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4057
			if not result.success then -- 4057
				return ____awaiter_resolve(nil, result) -- 4057
			end -- 4057
			shared.waitingQuestionnaireId = result.questionnaireId -- 4064
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4064
		end -- 4064
		if action.tool == "delete_file" then -- 4064
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4068
			if __TS__StringTrim(targetFile) == "" then -- 4068
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4068
			end -- 4068
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4072
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4073
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4073
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4073
			end -- 4073
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4077
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4078
			if not result.success then -- 4078
				return ____awaiter_resolve(nil, result) -- 4078
			end -- 4078
			if not isInternalDocumentEdit then -- 4078
				shared.unbuiltEdits = true -- 4086
				shared.lastBuildSucceeded = false -- 4087
				if shared.failedTestNeedsBuild == true then -- 4087
					shared.failedTestHasSourceEdit = true -- 4088
				end -- 4088
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4088
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4089
				end -- 4089
				shared.editedPathsSinceBuild = editedPaths -- 4090
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4091
			end -- 4091
			return ____awaiter_resolve(nil, { -- 4091
				success = true, -- 4094
				changed = true, -- 4095
				mode = "delete", -- 4096
				checkpointId = result.checkpointId, -- 4097
				checkpointSeq = result.checkpointSeq, -- 4098
				files = {{path = targetFile, op = "delete"}} -- 4099
			}) -- 4099
		end -- 4099
		if action.tool == "build" then -- 4099
			local buildPath = params.path or "" -- 4103
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4104
			shared.unbuiltEdits = false -- 4108
			shared.editsSinceBuild = 0 -- 4109
			shared.editedPathsSinceBuild = {} -- 4110
			shared.hasBuilt = true -- 4111
			shared.lastBuildSucceeded = result.success -- 4112
			if result.success and shared.freshProjectBuildPending == true then -- 4112
				shared.freshProjectBuildPending = false -- 4118
			end -- 4118
			shared.apiSearchesSinceBuild = 0 -- 4120
			shared.buildRepairPending = false -- 4121
			if not result.success and result.messages ~= nil then -- 4121
				do -- 4121
					local i = 0 -- 4123
					while i < #result.messages do -- 4123
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4123
							shared.buildRepairPending = true -- 4125
							break -- 4126
						end -- 4126
						i = i + 1 -- 4123
					end -- 4123
				end -- 4123
			end -- 4123
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4123
				shared.failedTestNeedsBuild = false -- 4131
				shared.failedTestHasSourceEdit = false -- 4132
			end -- 4132
			return ____awaiter_resolve(nil, result) -- 4132
		end -- 4132
		if action.tool == "fetch_url" then -- 4132
			local result = __TS__Await(Tools.fetchUrl({ -- 4137
				workDir = shared.workingDir, -- 4138
				url = type(params.url) == "string" and params.url or "", -- 4139
				target = type(params.target) == "string" and params.target or "", -- 4140
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4141
				onProgress = function(____, progress) -- 4142
					emitAgentEvent( -- 4143
						shared, -- 4143
						{ -- 4143
							type = "tool_progress", -- 4144
							sessionId = shared.sessionId, -- 4145
							taskId = shared.taskId, -- 4146
							step = action.step, -- 4147
							tool = action.tool, -- 4148
							result = __TS__ObjectAssign({success = false}, progress) -- 4149
						} -- 4149
					) -- 4149
				end -- 4142
			})) -- 4142
			return ____awaiter_resolve(nil, result) -- 4142
		end -- 4142
		if action.tool == "execute_command" then -- 4142
			local mode = type(params.mode) == "string" and params.mode or "" -- 4159
			local result = __TS__Await(Tools.executeCommand({ -- 4160
				workDir = shared.workingDir, -- 4161
				mode = mode, -- 4162
				code = type(params.code) == "string" and params.code or nil, -- 4163
				command = type(params.command) == "string" and params.command or nil, -- 4164
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4165
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4166
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4167
				onProgress = function(____, progress) -- 4168
					emitAgentEvent( -- 4169
						shared, -- 4169
						{ -- 4169
							type = "tool_progress", -- 4170
							sessionId = shared.sessionId, -- 4171
							taskId = shared.taskId, -- 4172
							step = action.step, -- 4173
							tool = action.tool, -- 4174
							result = __TS__ObjectAssign({success = false}, progress) -- 4175
						} -- 4175
					) -- 4175
				end -- 4168
			})) -- 4168
			if result.success and mode == "lua" then -- 4168
				local deterministicFailure = false -- 4183
				local deterministicPass = false -- 4184
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4185
				do -- 4185
					local i = 0 -- 4186
					while i < #outputLines and not deterministicFailure do -- 4186
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4187
						if line == "passed" then -- 4187
							deterministicPass = true -- 4188
						end -- 4188
						if line == "failed" then -- 4188
							deterministicFailure = true -- 4190
							break -- 4191
						end -- 4191
						local searchFrom = 0 -- 4193
						while searchFrom < #line do -- 4193
							local failedIndex = (string.find( -- 4195
								line, -- 4195
								"failed", -- 4195
								math.max(searchFrom + 1, 1), -- 4195
								true -- 4195
							) or 0) - 1 -- 4195
							if failedIndex < 0 then -- 4195
								break -- 4196
							end -- 4196
							local after = failedIndex + #"failed" -- 4197
							while after < #line do -- 4197
								local ch = __TS__StringSlice(line, after, after + 1) -- 4199
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4199
									break -- 4200
								end -- 4200
								after = after + 1 -- 4201
							end -- 4201
							local afterEnd = after -- 4203
							while afterEnd < #line do -- 4203
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4205
								if ch < "0" or ch > "9" then -- 4205
									break -- 4206
								end -- 4206
								afterEnd = afterEnd + 1 -- 4207
							end -- 4207
							local count -- 4209
							if afterEnd > after then -- 4209
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4211
							else -- 4211
								local before = failedIndex - 1 -- 4213
								while before >= 0 do -- 4213
									local ch = __TS__StringSlice(line, before, before + 1) -- 4215
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4215
										break -- 4216
									end -- 4216
									before = before - 1 -- 4217
								end -- 4217
								local beforeEnd = before + 1 -- 4219
								while before >= 0 do -- 4219
									local ch = __TS__StringSlice(line, before, before + 1) -- 4221
									if ch < "0" or ch > "9" then -- 4221
										break -- 4222
									end -- 4222
									before = before - 1 -- 4223
								end -- 4223
								if beforeEnd > before + 1 then -- 4223
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4225
								end -- 4225
							end -- 4225
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4225
								deterministicFailure = true -- 4228
								break -- 4229
							end -- 4229
							searchFrom = failedIndex + #"failed" -- 4231
						end -- 4231
						i = i + 1 -- 4186
					end -- 4186
				end -- 4186
				if deterministicFailure then -- 4186
					shared.failedTestNeedsBuild = true -- 4235
					shared.failedTestHasSourceEdit = false -- 4236
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4237
				elseif deterministicPass then -- 4237
					shared.deterministicTestFailureCount = 0 -- 4239
				end -- 4239
			end -- 4239
			return ____awaiter_resolve(nil, result) -- 4239
		end -- 4239
		if action.tool == "spawn_sub_agent" then -- 4239
			if not shared.spawnSubAgent then -- 4239
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4239
			end -- 4239
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4239
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4239
			end -- 4239
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4251
				params.filesHint, -- 4252
				function(____, item) return type(item) == "string" end -- 4252
			) or nil -- 4252
			local result = __TS__Await(shared.spawnSubAgent({ -- 4254
				parentSessionId = shared.sessionId, -- 4255
				projectRoot = shared.workingDir, -- 4256
				title = type(params.title) == "string" and params.title or "Sub", -- 4257
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4258
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4259
				filesHint = filesHint, -- 4260
				disabledAgentTools = shared.disabledAgentTools -- 4261
			})) -- 4261
			if not result.success then -- 4261
				return ____awaiter_resolve(nil, result) -- 4261
			end -- 4261
			shared.hasSpawnedSubAgentThisTask = true -- 4266
			return ____awaiter_resolve(nil, { -- 4266
				success = true, -- 4268
				sessionId = result.sessionId, -- 4269
				taskId = result.taskId, -- 4270
				title = result.title, -- 4271
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4272
			}) -- 4272
		end -- 4272
		if action.tool == "list_sub_agents" then -- 4272
			if not shared.listSubAgents then -- 4272
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4272
			end -- 4272
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4272
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4272
			end -- 4272
			local result = __TS__Await(shared.listSubAgents({ -- 4282
				sessionId = shared.sessionId, -- 4283
				projectRoot = shared.workingDir, -- 4284
				status = type(params.status) == "string" and params.status or nil, -- 4285
				limit = type(params.limit) == "number" and params.limit or nil, -- 4286
				offset = type(params.offset) == "number" and params.offset or nil, -- 4287
				query = type(params.query) == "string" and params.query or nil -- 4288
			})) -- 4288
			return ____awaiter_resolve(nil, result) -- 4288
		end -- 4288
		if action.tool == "edit_file" then -- 4288
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4293
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4296
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4297
			if __TS__StringTrim(path) == "" then -- 4297
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4297
			end -- 4297
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4299
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4300
			if not isInternalDocumentEdit then -- 4300
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4302
				if preflightIssue ~= nil then -- 4302
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4304
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4305
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4305
				end -- 4305
			end -- 4305
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4311
			local result = __TS__Await(actionNode:exec({ -- 4312
				path = path, -- 4313
				oldStr = oldStr, -- 4314
				newStr = newStr, -- 4315
				taskId = shared.taskId, -- 4316
				workDir = shared.workingDir -- 4317
			})) -- 4317
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4317
				if params.partialStreamRecovery ~= true then -- 4317
					shared.truncatedToolOverwritePath = nil -- 4321
				end -- 4321
				shared.unbuiltEdits = true -- 4323
				shared.lastBuildSucceeded = false -- 4324
				if shared.failedTestNeedsBuild == true then -- 4324
					shared.failedTestHasSourceEdit = true -- 4325
				end -- 4325
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4326
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4326
					editedPaths[#editedPaths + 1] = normalizedPath -- 4327
				end -- 4327
				shared.editedPathsSinceBuild = editedPaths -- 4328
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4329
			end -- 4329
			return ____awaiter_resolve(nil, result) -- 4329
		end -- 4329
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4329
	end) -- 4329
end -- 4329
function sanitizeToolActionResultForHistory(action, result) -- 4336
	if action.tool == "read_file" then -- 4336
		return sanitizeReadResultForHistory(action.tool, result) -- 4338
	end -- 4338
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4338
		return sanitizeSearchResultForHistory(action.tool, result) -- 4341
	end -- 4341
	if action.tool == "glob_files" then -- 4341
		return sanitizeListFilesResultForHistory(result) -- 4344
	end -- 4344
	if action.tool == "build" then -- 4344
		return sanitizeBuildResultForHistory(result) -- 4347
	end -- 4347
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4347
		if result.success ~= true then -- 4347
			return result -- 4350
		end -- 4350
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4350
			return result -- 4351
		end -- 4351
		if isArray(result.fileContext) then -- 4351
			return result -- 4352
		end -- 4352
		local contextLimits = { -- 4354
			fullContentChars = 12000, -- 4355
			previewChars = 4000, -- 4356
			diffChars = 8000, -- 4357
			totalChars = 24000, -- 4358
			maxFiles = 8 -- 4359
		} -- 4359
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4361
			if maxChars <= 0 then -- 4361
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4362
			end -- 4362
			if #sourceText <= maxChars then -- 4362
				return sourceText -- 4363
			end -- 4363
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4364
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4365
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4366
		end -- 4361
		local function countLines(sourceText) -- 4368
			if sourceText == "" then -- 4368
				return 0 -- 4369
			end -- 4369
			return #__TS__StringSplit(sourceText, "\n") -- 4370
		end -- 4368
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4372
			if beforeContent == afterContent then -- 4372
				return "" -- 4373
			end -- 4373
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4374
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4375
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4377
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4377
				firstChangedLine = firstChangedLine + 1 -- 4383
			end -- 4383
			local lastChangedBeforeLine = #beforeLines - 1 -- 4385
			local lastChangedAfterLine = #afterLines - 1 -- 4386
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4386
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4392
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4393
			end -- 4393
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4395
			local previewEndLine = math.max( -- 4396
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4397
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4398
			) -- 4398
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4400
			do -- 4400
				local lineIndex = previewStartLine -- 4401
				while lineIndex <= previewEndLine do -- 4401
					do -- 4401
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4402
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4403
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4404
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4405
						if not beforeChanged and not afterChanged then -- 4405
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4407
							if contextLine ~= nil then -- 4407
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4408
							end -- 4408
							goto __continue723 -- 4409
						end -- 4409
						if beforeChanged and beforeLine ~= nil then -- 4409
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4411
						end -- 4411
						if afterChanged and afterLine ~= nil then -- 4411
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4412
						end -- 4412
					end -- 4412
					::__continue723:: -- 4412
					lineIndex = lineIndex + 1 -- 4401
				end -- 4401
			end -- 4401
			return truncateContextSnippet( -- 4414
				table.concat(unifiedDiffLines, "\n"), -- 4414
				maxChars, -- 4414
				"diff" -- 4414
			) -- 4414
		end -- 4372
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4417
		if not checkpointDiff.success then -- 4417
			return result -- 4418
		end -- 4418
		local remainingContextBudget = contextLimits.totalChars -- 4419
		local fileContextItems = {} -- 4420
		local changedFiles = checkpointDiff.files -- 4421
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4422
		do -- 4422
			local fileIndex = 0 -- 4423
			while fileIndex < maxContextFiles do -- 4423
				if remainingContextBudget <= 0 then -- 4423
					break -- 4424
				end -- 4424
				local changedFile = changedFiles[fileIndex + 1] -- 4425
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4426
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4427
				local contextItem = { -- 4428
					path = changedFile.path, -- 4429
					op = changedFile.op, -- 4430
					checkpointId = result.checkpointId, -- 4431
					checkpointSeq = result.checkpointSeq, -- 4432
					beforeExists = changedFile.beforeExists, -- 4433
					afterExists = changedFile.afterExists, -- 4434
					beforeBytes = #beforeContent, -- 4435
					afterBytes = #afterContent, -- 4436
					diffPreview = "", -- 4437
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4438
					contentTruncated = false, -- 4439
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4440
				} -- 4440
				if changedFile.afterExists then -- 4440
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4440
						contextItem.afterContent = afterContent -- 4444
						remainingContextBudget = remainingContextBudget - #afterContent -- 4445
					else -- 4445
						contextItem.afterContentPreview = truncateContextSnippet( -- 4447
							afterContent, -- 4448
							math.min( -- 4449
								contextLimits.previewChars, -- 4449
								math.max(400, remainingContextBudget) -- 4449
							), -- 4449
							"afterContent" -- 4450
						) -- 4450
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4452
						contextItem.contentTruncated = true -- 4453
					end -- 4453
				end -- 4453
				local diffPreview = buildUnifiedDiffPreview( -- 4456
					changedFile.path, -- 4457
					beforeContent, -- 4458
					afterContent, -- 4459
					math.min( -- 4460
						contextLimits.diffChars, -- 4460
						math.max(400, remainingContextBudget) -- 4460
					) -- 4460
				) -- 4460
				contextItem.diffPreview = diffPreview -- 4462
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4463
				if not changedFile.afterExists and beforeContent ~= "" then -- 4463
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4465
						beforeContent, -- 4466
						math.min( -- 4467
							contextLimits.previewChars, -- 4467
							math.max(400, remainingContextBudget) -- 4467
						), -- 4467
						"beforeContent" -- 4468
					) -- 4468
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4470
					if #beforeContent > contextLimits.previewChars then -- 4470
						contextItem.contentTruncated = true -- 4471
					end -- 4471
				end -- 4471
				fileContextItems[#fileContextItems + 1] = contextItem -- 4473
				fileIndex = fileIndex + 1 -- 4423
			end -- 4423
		end -- 4423
		if #fileContextItems == 0 then -- 4423
			return result -- 4475
		end -- 4475
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4476
	end -- 4476
	return result -- 4483
end -- 4483
function emitAgentTaskFinishEvent(shared, success, message) -- 4680
	local completion = shared.completion or ____exports.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4681
	local result = success and ({ -- 4685
		success = true, -- 4687
		taskId = shared.taskId, -- 4688
		message = message, -- 4689
		steps = shared.step, -- 4690
		completion = completion -- 4691
	}) or ({ -- 4691
		success = false, -- 4694
		taskId = shared.taskId, -- 4695
		message = message, -- 4696
		steps = shared.step, -- 4697
		completion = completion -- 4698
	}) -- 4698
	emitAgentEvent(shared, { -- 4700
		type = "task_finished", -- 4701
		sessionId = shared.sessionId, -- 4702
		taskId = shared.taskId, -- 4703
		success = result.success, -- 4704
		message = result.message, -- 4705
		steps = result.steps, -- 4706
		completion = result.completion -- 4707
	}) -- 4707
	return result -- 4709
end -- 4709
local function buildLLMOptions(llmConfig, overrides) -- 304
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 305
	if llmConfig.reasoningEffort then -- 305
		options.reasoning_effort = llmConfig.reasoningEffort -- 310
	end -- 310
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 312
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 312
		__TS__Delete(merged, "reasoning_effort") -- 317
	else -- 317
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 319
	end -- 319
	__TS__Delete(merged, "tool_choice") -- 324
	return merged -- 325
end -- 304
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 455
	local messagesTokens = 0 -- 462
	do -- 462
		local i = 0 -- 463
		while i < #messages do -- 463
			local message = messages[i + 1] -- 464
			messagesTokens = messagesTokens + 8 -- 465
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 466
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 467
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 468
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 469
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 470
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 471
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 472
			i = i + 1 -- 463
		end -- 463
	end -- 463
	local toolDefinitionsTokens = 0 -- 475
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 475
		local toolsText = safeJsonEncode(options.tools) -- 477
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 478
	end -- 478
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 481
	__TS__Delete(optionsWithoutTools, "tools") -- 482
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 483
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 484
	local contextWindow = shared.llmConfig.contextWindow > 0 and math.floor(shared.llmConfig.contextWindow) or 64000 -- 485
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 488
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 493
		1024, -- 495
		math.floor(contextWindow * 0.2) -- 495
	) -- 495
	local structuralOverhead = math.max(256, #messages * 16) -- 496
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 498
	local maxTokens = contextWindow -- 499
	emitAgentEvent( -- 500
		shared, -- 500
		{ -- 500
			type = "metrics_updated", -- 501
			sessionId = shared.sessionId, -- 502
			taskId = shared.taskId, -- 503
			step = step, -- 504
			metrics = {context = { -- 505
				usedTokens = usedTokens, -- 507
				maxTokens = maxTokens, -- 508
				ratio = math.max( -- 509
					0, -- 509
					math.min(1, usedTokens / maxTokens) -- 509
				), -- 509
				messagesTokens = messagesTokens, -- 510
				optionsTokens = optionsTokens, -- 511
				toolDefinitionsTokens = toolDefinitionsTokens, -- 512
				reservedOutputTokens = reservedOutputTokens, -- 513
				structuralOverhead = structuralOverhead, -- 514
				contextWindow = contextWindow, -- 515
				source = "llm_input_estimate", -- 516
				updatedAt = os.time(), -- 517
				phase = phase, -- 518
				step = step -- 519
			}} -- 519
		} -- 519
	) -- 519
end -- 455
local function recordLLMTokenUsage(shared, step, phase, usage) -- 525
	if not usage then -- 525
		return -- 526
	end -- 526
	local current = shared.tokenUsage -- 527
	local cachedReported = usage.cachedInputTokens ~= nil -- 528
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 529
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 530
	local next = { -- 531
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 532
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 533
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 534
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 535
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 538
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 541
		requestCount = (current and current.requestCount or 0) + 1, -- 544
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 545
		model = shared.llmConfig.model, -- 548
		phase = phase, -- 549
		step = step, -- 550
		updatedAt = os.time() -- 551
	} -- 551
	shared.tokenUsage = next -- 553
	emitAgentEvent(shared, { -- 554
		type = "metrics_updated", -- 555
		sessionId = shared.sessionId, -- 556
		taskId = shared.taskId, -- 557
		step = step, -- 558
		metrics = {usage = next} -- 559
	}) -- 559
end -- 525
local function emitAgentStartEvent(shared, action) -- 563
	emitAgentEvent(shared, { -- 564
		type = "tool_started", -- 565
		sessionId = shared.sessionId, -- 566
		taskId = shared.taskId, -- 567
		step = action.step, -- 568
		tool = action.tool -- 569
	}) -- 569
end -- 563
local function emitAgentFinishEvent(shared, action) -- 573
	emitAgentEvent(shared, { -- 574
		type = "tool_finished", -- 575
		sessionId = shared.sessionId, -- 576
		taskId = shared.taskId, -- 577
		step = action.step, -- 578
		tool = action.tool, -- 579
		result = action.result or ({}) -- 580
	}) -- 580
end -- 573
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 584
	emitAgentEvent(shared, { -- 585
		type = "assistant_message_updated", -- 586
		sessionId = shared.sessionId, -- 587
		taskId = shared.taskId, -- 588
		step = shared.step + 1, -- 589
		content = content, -- 590
		reasoningContent = reasoningContent -- 591
	}) -- 591
end -- 584
local function getMemoryCompressionStartReason(shared) -- 595
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 596
end -- 595
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 601
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 602
end -- 601
local function getMemoryCompressionFailureReason(shared, ____error) -- 607
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 608
end -- 607
local function summarizeHistoryEntryPreview(text, maxChars) -- 613
	if maxChars == nil then -- 613
		maxChars = 180 -- 613
	end -- 613
	local trimmed = __TS__StringTrim(text) -- 614
	if trimmed == "" then -- 614
		return "" -- 615
	end -- 615
	return truncateText(trimmed, maxChars) -- 616
end -- 613
local function getMaxStepsReachedReason(shared) -- 624
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 625
end -- 624
local function getFailureSummaryFallback(shared, ____error) -- 630
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 631
end -- 630
local function finalizeAgentFailure(shared, ____error) -- 636
	if shared.stopToken.stopped then -- 636
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 638
		return emitAgentTaskFinishEvent( -- 639
			shared, -- 639
			false, -- 639
			getCancelledReason(shared) -- 639
		) -- 639
	end -- 639
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 641
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 642
end -- 636
local function getPromptCommand(prompt) -- 645
	local trimmed = __TS__StringTrim(prompt) -- 646
	if trimmed == "/compact" then -- 646
		return "compact" -- 647
	end -- 647
	if trimmed == "/clear" then -- 647
		return "clear" -- 648
	end -- 648
	return nil -- 649
end -- 645
function ____exports.truncateAgentUserPrompt(prompt) -- 652
	if not prompt then -- 652
		return "" -- 653
	end -- 653
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 653
		return prompt -- 654
	end -- 654
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 655
	if offset == nil then -- 655
		return prompt -- 656
	end -- 656
	return string.sub(prompt, 1, offset - 1) -- 657
end -- 652
local function canWriteStepLLMDebug(shared, stepId) -- 660
	if stepId == nil then -- 660
		stepId = shared.step + 1 -- 660
	end -- 660
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 661
end -- 660
local function ensureDirRecursive(dir) -- 668
	if not dir then -- 668
		return false -- 669
	end -- 669
	if Content:exist(dir) then -- 669
		return Content:isdir(dir) -- 670
	end -- 670
	local parent = Path:getPath(dir) -- 671
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 671
		return false -- 673
	end -- 673
	return Content:mkdir(dir) -- 675
end -- 668
local function encodeDebugJSON(value) -- 678
	local text, err = safeJsonEncode(value) -- 679
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 680
end -- 678
function ____exports.isAgentPlanPath(path) -- 696
	return AgentRuntimePolicy.isAgentPlanPath(path) -- 697
end -- 696
local FRESH_PROJECT_CODE_GLOBS = { -- 700
	"**/*.ts", -- 701
	"**/*.tsx", -- 702
	"**/*.lua", -- 703
	"**/*.yue", -- 704
	"**/*.tl", -- 705
	"**/*.yarn", -- 706
	"**/*.xml", -- 707
	"!**/*.d.ts" -- 708
} -- 708
local function inspectFreshProject(workDir) -- 711
	local result = Tools.listFiles({workDir = workDir, path = "", globs = FRESH_PROJECT_CODE_GLOBS, maxEntries = 2}) -- 712
	if not result.success then -- 712
		return {fresh = false} -- 718
	end -- 718
	local totalEntries = result.totalEntries or #result.files -- 719
	if totalEntries > 1 then -- 719
		return {fresh = false} -- 720
	end -- 720
	if totalEntries == 0 then -- 720
		return {fresh = true} -- 721
	end -- 721
	if #result.files ~= 1 then -- 721
		return {fresh = false} -- 722
	end -- 722
	local path = result.files[1] -- 723
	local loaded = Tools.readFileRaw(workDir, path) -- 724
	if not loaded.success or loaded.content == nil then -- 724
		return {fresh = false} -- 725
	end -- 725
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 726
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 729
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 730
end -- 711
local function getStepLLMDebugDir(shared) -- 733
	return Path( -- 734
		shared.workingDir, -- 735
		".agent", -- 736
		tostring(shared.sessionId), -- 737
		tostring(shared.taskId) -- 738
	) -- 738
end -- 733
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 742
	return Path( -- 743
		getStepLLMDebugDir(shared), -- 743
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 743
	) -- 743
end -- 742
local function getLatestStepLLMDebugSeq(shared, stepId) -- 746
	if not canWriteStepLLMDebug(shared, stepId) then -- 746
		return 0 -- 747
	end -- 747
	local dir = getStepLLMDebugDir(shared) -- 748
	if not Content:exist(dir) or not Content:isdir(dir) then -- 748
		return 0 -- 749
	end -- 749
	local latest = 0 -- 750
	for ____, file in ipairs(Content:getFiles(dir)) do -- 751
		do -- 751
			local name = Path:getFilename(file) -- 752
			local seqText = string.match( -- 753
				name, -- 753
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 753
			) -- 753
			if seqText ~= nil then -- 753
				latest = math.max( -- 755
					latest, -- 755
					tonumber(seqText) -- 755
				) -- 755
				goto __continue59 -- 756
			end -- 756
			local legacyMatch = string.match( -- 758
				name, -- 758
				("^" .. tostring(stepId)) .. "_in%.md$" -- 758
			) -- 758
			if legacyMatch ~= nil then -- 758
				latest = math.max(latest, 1) -- 760
			end -- 760
		end -- 760
		::__continue59:: -- 760
	end -- 760
	return latest -- 763
end -- 746
local function writeStepLLMDebugFile(path, content) -- 766
	if not Content:save(path, content) then -- 766
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 768
		return false -- 769
	end -- 769
	return true -- 771
end -- 766
local function createStepLLMDebugPair(shared, stepId, inContent) -- 774
	if not canWriteStepLLMDebug(shared, stepId) then -- 774
		return 0 -- 775
	end -- 775
	local dir = getStepLLMDebugDir(shared) -- 776
	if not ensureDirRecursive(dir) then -- 776
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 778
		return 0 -- 779
	end -- 779
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 781
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 782
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 783
	if not writeStepLLMDebugFile(inPath, inContent) then -- 783
		return 0 -- 785
	end -- 785
	writeStepLLMDebugFile(outPath, "") -- 787
	return seq -- 788
end -- 774
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 791
	if not canWriteStepLLMDebug(shared, stepId) then -- 791
		return -- 792
	end -- 792
	local dir = getStepLLMDebugDir(shared) -- 793
	if not ensureDirRecursive(dir) then -- 793
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 795
		return -- 796
	end -- 796
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 798
	if latestSeq <= 0 then -- 798
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 800
		writeStepLLMDebugFile(outPath, content) -- 801
		return -- 802
	end -- 802
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 804
	writeStepLLMDebugFile(outPath, content) -- 805
end -- 791
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 808
	if not canWriteStepLLMDebug(shared, stepId) then -- 808
		return -- 809
	end -- 809
	local sections = { -- 810
		"# LLM Input", -- 811
		"session_id: " .. tostring(shared.sessionId), -- 812
		"task_id: " .. tostring(shared.taskId), -- 813
		"step_id: " .. tostring(stepId), -- 814
		"phase: " .. phase, -- 815
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 816
		"## Options", -- 817
		"```json", -- 818
		encodeDebugJSON(options), -- 819
		"```" -- 820
	} -- 820
	local firstMessage = #messages > 0 and messages[1] or nil -- 822
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 822
		sections[#sections + 1] = "# System Prompt" -- 824
		sections[#sections + 1] = firstMessage.content -- 825
	end -- 825
	do -- 825
		local i = 0 -- 827
		while i < #messages do -- 827
			local message = messages[i + 1] -- 828
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 829
			sections[#sections + 1] = encodeDebugJSON(message) -- 830
			i = i + 1 -- 827
		end -- 827
	end -- 827
	createStepLLMDebugPair( -- 832
		shared, -- 832
		stepId, -- 832
		table.concat(sections, "\n") -- 832
	) -- 832
end -- 808
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 835
	if not canWriteStepLLMDebug(shared, stepId) then -- 835
		return -- 836
	end -- 836
	local ____array_24 = __TS__SparseArrayNew( -- 836
		"# LLM Output", -- 838
		"session_id: " .. tostring(shared.sessionId), -- 839
		"task_id: " .. tostring(shared.taskId), -- 840
		"step_id: " .. tostring(stepId), -- 841
		"phase: " .. phase, -- 842
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 843
		table.unpack(meta and ({ -- 844
			"## Meta", -- 844
			"```json", -- 844
			encodeDebugJSON(meta), -- 844
			"```" -- 844
		}) or ({})) -- 844
	) -- 844
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 844
	local sections = {__TS__SparseArraySpread(____array_24)} -- 837
	updateLatestStepLLMDebugOutput( -- 848
		shared, -- 848
		stepId, -- 848
		table.concat(sections, "\n") -- 848
	) -- 848
end -- 835
local function toJson(value, emptyAsArray) -- 851
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 852
	if text ~= nil then -- 852
		return text -- 853
	end -- 853
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 854
end -- 851
local function summarizeEditTextParamForHistory(value, key) -- 904
	if type(value) ~= "string" then -- 904
		return nil -- 905
	end -- 905
	local text = value -- 906
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 907
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 908
end -- 904
local function sanitizeActionParamsForHistory(tool, params) -- 1024
	if tool ~= "edit_file" then -- 1024
		return params -- 1025
	end -- 1025
	local clone = {} -- 1026
	for key in pairs(params) do -- 1027
		if key == "old_str" then -- 1027
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1029
		elseif key == "new_str" then -- 1029
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1031
		else -- 1031
			clone[key] = params[key] -- 1033
		end -- 1033
	end -- 1033
	return clone -- 1036
end -- 1024
local function getDecisionToolSchemaText(shared) -- 1078
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1079
		shared.role, -- 1079
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1079
		{ -- 1079
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1080
			workMode = shared.workMode -- 1081
		} -- 1081
	)) -- 1081
	return toolsText or "" -- 1083
end -- 1078
local function clearPreExecutedResults(shared) -- 1093
	shared.preExecutedResults = nil -- 1094
end -- 1093
local function startPreExecutedToolAction(shared, action) -- 1097
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1097
		local ____hasReturned, ____returnValue -- 1097
		local ____try = __TS__AsyncAwaiter(function() -- 1097
			____hasReturned = true -- 1099
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1099
			return -- 1099
		end) -- 1099
		____try = ____try.catch( -- 1099
			____try, -- 1099
			function(____, err) -- 1099
				return __TS__AsyncAwaiter(function() -- 1099
					local message = tostring(err) -- 1101
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1102
					____hasReturned = true -- 1103
					____returnValue = {success = false, message = message} -- 1103
					return -- 1103
				end) -- 1103
			end -- 1103
		) -- 1103
		__TS__Await(____try) -- 1098
		if ____hasReturned then -- 1098
			return ____awaiter_resolve(nil, ____returnValue) -- 1098
		end -- 1098
	end) -- 1098
end -- 1097
local function createPreExecutedToolResult(shared, action) -- 1107
	local cloneParamValue -- 1108
	cloneParamValue = function(value) -- 1108
		if value == nil then -- 1108
			return value -- 1109
		end -- 1109
		if isArray(value) then -- 1109
			return __TS__ArrayMap( -- 1111
				value, -- 1111
				function(____, item) return cloneParamValue(item) end -- 1111
			) -- 1111
		end -- 1111
		if type(value) == "table" then -- 1111
			local clone = {} -- 1114
			for key in pairs(value) do -- 1115
				clone[key] = cloneParamValue(value[key]) -- 1116
			end -- 1116
			return clone -- 1118
		end -- 1118
		return value -- 1120
	end -- 1108
	local params = cloneParamValue(action.params) -- 1122
	local areParamValuesEqual -- 1123
	areParamValuesEqual = function(left, right) -- 1123
		if left == right then -- 1123
			return true -- 1124
		end -- 1124
		if left == nil or right == nil then -- 1124
			return false -- 1125
		end -- 1125
		if isArray(left) or isArray(right) then -- 1125
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1125
				return false -- 1127
			end -- 1127
			do -- 1127
				local i = 0 -- 1128
				while i < #left do -- 1128
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1128
						return false -- 1129
					end -- 1129
					i = i + 1 -- 1128
				end -- 1128
			end -- 1128
			return true -- 1131
		end -- 1131
		if type(left) == "table" and type(right) == "table" then -- 1131
			local leftCount = 0 -- 1134
			for key in pairs(left) do -- 1135
				leftCount = leftCount + 1 -- 1136
				if not areParamValuesEqual(left[key], right[key]) then -- 1136
					return false -- 1141
				end -- 1141
			end -- 1141
			local rightCount = 0 -- 1144
			for key in pairs(right) do -- 1145
				rightCount = rightCount + 1 -- 1146
			end -- 1146
			return leftCount == rightCount -- 1148
		end -- 1148
		return false -- 1150
	end -- 1123
	return { -- 1152
		action = action, -- 1153
		matches = function(self, nextAction) -- 1154
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1155
		end, -- 1154
		promise = startPreExecutedToolAction(shared, action) -- 1157
	} -- 1157
end -- 1107
local function executeToolActionWithPreExecution(shared, action) -- 1161
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1161
		local ____opt_27 = shared.preExecutedResults -- 1161
		local preResult = ____opt_27 and ____opt_27:get(action.toolCallId) -- 1162
		local result -- 1163
		if preResult then -- 1163
			local ____opt_29 = shared.preExecutedResults -- 1163
			if ____opt_29 ~= nil then -- 1163
				____opt_29:delete(action.toolCallId) -- 1165
			end -- 1165
			if preResult:matches(action) then -- 1165
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1167
				result = __TS__Await(preResult.promise) -- 1168
			else -- 1168
				Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1170
				result = __TS__Await(executeToolAction(shared, action)) -- 1171
			end -- 1171
		else -- 1171
			result = __TS__Await(executeToolAction(shared, action)) -- 1174
		end -- 1174
		local guidance = {} -- 1176
		if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1176
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1182
		end -- 1182
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1182
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1185
		end -- 1185
		if shared.failedTestNeedsBuild == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1185
			guidance[#guidance + 1] = "A deterministic test previously failed. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1188
		end -- 1188
		if action.tool == "search_dora_api" then -- 1188
			if shared.unbuiltEdits == true then -- 1188
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1192
			end -- 1192
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1192
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1195
			end -- 1195
		end -- 1195
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1195
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1203
		end -- 1203
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 1203
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1206
			if oldStr == "" then -- 1206
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1208
			end -- 1208
		end -- 1208
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1208
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1212
		end -- 1212
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1212
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1215
		end -- 1215
		if shared.buildRepairPending == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1215
			guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1220
		end -- 1220
		if shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true then -- 1220
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1223
		end -- 1223
		if #guidance > 0 then -- 1223
			result.guidance = table.concat(guidance, "\n") -- 1226
		end -- 1226
		return ____awaiter_resolve(nil, result) -- 1226
	end) -- 1226
end -- 1161
local function maybeCompressHistory(shared, forceAtTurnBoundary, pendingUserPrompt) -- 1231
	if forceAtTurnBoundary == nil then -- 1231
		forceAtTurnBoundary = false -- 1233
	end -- 1233
	if pendingUserPrompt == nil then -- 1233
		pendingUserPrompt = "" -- 1234
	end -- 1234
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1234
		local ____shared_31 = shared -- 1236
		local memory = ____shared_31.memory -- 1236
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1237
		local changed = false -- 1238
		do -- 1238
			local round = 0 -- 1239
			while round < maxRounds do -- 1239
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1240
				local activeMessages = getActiveConversationMessages(shared) -- 1241
				local uncoveredMessages = AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex) -- 1246
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1252
				local thresholdReached = memory.compressor:shouldCompress(uncoveredMessages, systemPrompt, toolDefinitions) -- 1255
				local activeTokens = 0 -- 1260
				if forceAtTurnBoundary and shared.role == "main" then -- 1260
					local ____temp_35 = estimateTextTokens(systemPrompt) + estimateTextTokens(toolDefinitions) + AgentRuntimePolicy.estimateConversationTokens(uncoveredMessages) + estimateTextTokens(pendingUserPrompt) -- 1262
					local ____math_max_34 = math.max -- 1266
					local ____math_floor_33 = math.floor -- 1266
					local ____shared_llmOptions_max_tokens_32 = shared.llmOptions.max_tokens -- 1266
					if ____shared_llmOptions_max_tokens_32 == nil then -- 1266
						____shared_llmOptions_max_tokens_32 = AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1266
					end -- 1266
					activeTokens = ____temp_35 + ____math_max_34( -- 1262
						0, -- 1266
						____math_floor_33(__TS__Number(____shared_llmOptions_max_tokens_32)) -- 1266
					) -- 1266
				end -- 1266
				local turnBoundaryThreshold = AgentConfig.getTurnBoundaryCompressionThreshold(shared.llmConfig.contextWindow) -- 1268
				local turnBoundaryReached = forceAtTurnBoundary and shared.role == "main" and #uncoveredMessages > 0 and activeTokens >= turnBoundaryThreshold -- 1271
				if not thresholdReached and not turnBoundaryReached then -- 1271
					if changed then -- 1271
						persistHistoryState(shared) -- 1277
					end -- 1277
					return ____awaiter_resolve(nil) -- 1277
				end -- 1277
				local compressionRound = round + 1 -- 1281
				shared.step = shared.step + 1 -- 1282
				local stepId = shared.step -- 1283
				local pendingMessages = #activeMessages -- 1284
				emitAgentEvent( -- 1285
					shared, -- 1285
					{ -- 1285
						type = "memory_compression_started", -- 1286
						sessionId = shared.sessionId, -- 1287
						taskId = shared.taskId, -- 1288
						step = stepId, -- 1289
						tool = "compress_memory", -- 1290
						reason = getMemoryCompressionStartReason(shared), -- 1291
						params = { -- 1292
							round = compressionRound, -- 1293
							maxRounds = maxRounds, -- 1294
							pendingMessages = pendingMessages, -- 1295
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1296
							uncoveredMessages = #uncoveredMessages -- 1297
						} -- 1297
					} -- 1297
				) -- 1297
				local result = __TS__Await(memory.compressor:compress( -- 1300
					activeMessages, -- 1301
					shared.llmOptions, -- 1302
					shared.llmMaxTry, -- 1303
					shared.decisionMode, -- 1304
					{ -- 1305
						onInput = function(____, phase, messages, options) -- 1306
							saveStepLLMDebugInput( -- 1307
								shared, -- 1307
								stepId, -- 1307
								phase, -- 1307
								messages, -- 1307
								options -- 1307
							) -- 1307
						end, -- 1306
						onOutput = function(____, phase, text, meta) -- 1309
							saveStepLLMDebugOutput( -- 1310
								shared, -- 1310
								stepId, -- 1310
								phase, -- 1310
								text, -- 1310
								meta -- 1310
							) -- 1310
						end, -- 1309
						onUsage = function(____, phase, usage) -- 1312
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1313
						end -- 1312
					}, -- 1312
					"default", -- 1316
					systemPrompt, -- 1317
					toolDefinitions -- 1318
				)) -- 1318
				if not (result and result.success and result.compressedCount > 0) then -- 1318
					emitAgentEvent( -- 1321
						shared, -- 1321
						{ -- 1321
							type = "memory_compression_finished", -- 1322
							sessionId = shared.sessionId, -- 1323
							taskId = shared.taskId, -- 1324
							step = stepId, -- 1325
							tool = "compress_memory", -- 1326
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1327
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1331
						} -- 1331
					) -- 1331
					if changed then -- 1331
						persistHistoryState(shared) -- 1339
					end -- 1339
					return ____awaiter_resolve(nil) -- 1339
				end -- 1339
				local effectiveCompressedCount = math.max( -- 1343
					0, -- 1344
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1345
				) -- 1345
				if effectiveCompressedCount <= 0 then -- 1345
					if changed then -- 1345
						persistHistoryState(shared) -- 1349
					end -- 1349
					return ____awaiter_resolve(nil) -- 1349
				end -- 1349
				emitAgentEvent( -- 1353
					shared, -- 1353
					{ -- 1353
						type = "memory_compression_finished", -- 1354
						sessionId = shared.sessionId, -- 1355
						taskId = shared.taskId, -- 1356
						step = stepId, -- 1357
						tool = "compress_memory", -- 1358
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1359
						result = { -- 1360
							success = true, -- 1361
							round = compressionRound, -- 1362
							compressedCount = effectiveCompressedCount, -- 1363
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1364
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1365
						} -- 1365
					} -- 1365
				) -- 1365
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1368
				changed = true -- 1369
				Log( -- 1370
					"Info", -- 1370
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1370
				) -- 1370
				round = round + 1 -- 1239
			end -- 1239
		end -- 1239
		if changed then -- 1239
			persistHistoryState(shared) -- 1373
		end -- 1373
	end) -- 1373
end -- 1231
local function compactAllHistory(shared) -- 1377
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1377
		local ____shared_42 = shared -- 1378
		local memory = ____shared_42.memory -- 1378
		local rounds = 0 -- 1379
		local totalCompressed = 0 -- 1380
		while getActiveRealMessageCount(shared) > 0 do -- 1380
			if shared.stopToken.stopped then -- 1380
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1383
				return ____awaiter_resolve( -- 1383
					nil, -- 1383
					emitAgentTaskFinishEvent( -- 1384
						shared, -- 1384
						false, -- 1384
						getCancelledReason(shared) -- 1384
					) -- 1384
				) -- 1384
			end -- 1384
			rounds = rounds + 1 -- 1386
			shared.step = shared.step + 1 -- 1387
			local stepId = shared.step -- 1388
			local activeMessages = getActiveConversationMessages(shared) -- 1389
			local pendingMessages = #activeMessages -- 1390
			emitAgentEvent( -- 1391
				shared, -- 1391
				{ -- 1391
					type = "memory_compression_started", -- 1392
					sessionId = shared.sessionId, -- 1393
					taskId = shared.taskId, -- 1394
					step = stepId, -- 1395
					tool = "compress_memory", -- 1396
					reason = getMemoryCompressionStartReason(shared), -- 1397
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1398
				} -- 1398
			) -- 1398
			local result = __TS__Await(memory.compressor:compress( -- 1405
				activeMessages, -- 1406
				shared.llmOptions, -- 1407
				shared.llmMaxTry, -- 1408
				shared.decisionMode, -- 1409
				{ -- 1410
					onInput = function(____, phase, messages, options) -- 1411
						saveStepLLMDebugInput( -- 1412
							shared, -- 1412
							stepId, -- 1412
							phase, -- 1412
							messages, -- 1412
							options -- 1412
						) -- 1412
					end, -- 1411
					onOutput = function(____, phase, text, meta) -- 1414
						saveStepLLMDebugOutput( -- 1415
							shared, -- 1415
							stepId, -- 1415
							phase, -- 1415
							text, -- 1415
							meta -- 1415
						) -- 1415
					end, -- 1414
					onUsage = function(____, phase, usage) -- 1417
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1418
					end -- 1417
				}, -- 1417
				"budget_max" -- 1421
			)) -- 1421
			if not (result and result.success and result.compressedCount > 0) then -- 1421
				emitAgentEvent( -- 1424
					shared, -- 1424
					{ -- 1424
						type = "memory_compression_finished", -- 1425
						sessionId = shared.sessionId, -- 1426
						taskId = shared.taskId, -- 1427
						step = stepId, -- 1428
						tool = "compress_memory", -- 1429
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1430
						result = { -- 1434
							success = false, -- 1435
							rounds = rounds, -- 1436
							error = result and result.error or "compression returned no changes", -- 1437
							compressedCount = result and result.compressedCount or 0, -- 1438
							fullCompaction = true -- 1439
						} -- 1439
					} -- 1439
				) -- 1439
				return ____awaiter_resolve( -- 1439
					nil, -- 1439
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1442
				) -- 1442
			end -- 1442
			local effectiveCompressedCount = math.max( -- 1447
				0, -- 1448
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1449
			) -- 1449
			if effectiveCompressedCount <= 0 then -- 1449
				return ____awaiter_resolve( -- 1449
					nil, -- 1449
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1452
				) -- 1452
			end -- 1452
			emitAgentEvent( -- 1459
				shared, -- 1459
				{ -- 1459
					type = "memory_compression_finished", -- 1460
					sessionId = shared.sessionId, -- 1461
					taskId = shared.taskId, -- 1462
					step = stepId, -- 1463
					tool = "compress_memory", -- 1464
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1465
					result = { -- 1466
						success = true, -- 1467
						round = rounds, -- 1468
						compressedCount = effectiveCompressedCount, -- 1469
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1470
						fullCompaction = true -- 1471
					} -- 1471
				} -- 1471
			) -- 1471
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1474
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1475
			persistHistoryState(shared) -- 1476
			Log( -- 1477
				"Info", -- 1477
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1477
			) -- 1477
		end -- 1477
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1479
		return ____awaiter_resolve( -- 1479
			nil, -- 1479
			emitAgentTaskFinishEvent( -- 1480
				shared, -- 1481
				true, -- 1482
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1483
			) -- 1483
		) -- 1483
	end) -- 1483
end -- 1377
local function clearSessionHistory(shared) -- 1489
	shared.messages = {} -- 1490
	shared.lastConsolidatedIndex = 0 -- 1491
	shared.carryMessageIndex = nil -- 1492
	persistHistoryState(shared) -- 1493
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1494
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1495
end -- 1489
COMPLETION_TEXT_MAX_CHARS = 800 -- 1517
COMPLETION_LIST_MAX_ITEMS = 12 -- 1518
COMPLETION_EVIDENCE_MAX_ITEMS = 8 -- 1519
local function appendConversationMessage(shared, message) -- 1714
	local ____shared_messages_51 = shared.messages -- 1714
	____shared_messages_51[#____shared_messages_51 + 1] = __TS__ObjectAssign( -- 1715
		{}, -- 1715
		message, -- 1716
		{ -- 1715
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1717
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1718
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1719
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1720
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1721
		} -- 1721
	) -- 1721
end -- 1714
local function appendToolResultMessage(shared, action) -- 1730
	appendConversationMessage( -- 1731
		shared, -- 1731
		{ -- 1731
			role = "tool", -- 1732
			tool_call_id = action.toolCallId, -- 1733
			name = action.tool, -- 1734
			content = action.result and toJson(action.result, false) or "" -- 1735
		} -- 1735
	) -- 1735
end -- 1730
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1739
	appendConversationMessage( -- 1745
		shared, -- 1745
		{ -- 1745
			role = "assistant", -- 1746
			content = content or "", -- 1747
			reasoning_content = reasoningContent, -- 1748
			tool_calls = __TS__ArrayMap( -- 1749
				actions, -- 1749
				function(____, action) return { -- 1749
					id = action.toolCallId, -- 1750
					type = "function", -- 1751
					["function"] = { -- 1752
						name = action.tool, -- 1753
						arguments = toJson(action.params, false) -- 1754
					} -- 1754
				} end -- 1754
			) -- 1754
		} -- 1754
	) -- 1754
end -- 1739
local function llm(shared, messages, phase) -- 1938
	if phase == nil then -- 1938
		phase = "decision_xml" -- 1941
	end -- 1941
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1941
		local stepId = shared.step + 1 -- 1943
		emitLLMContextMetrics( -- 1944
			shared, -- 1944
			stepId, -- 1944
			phase, -- 1944
			messages, -- 1944
			shared.llmOptions -- 1944
		) -- 1944
		saveStepLLMDebugInput( -- 1945
			shared, -- 1945
			stepId, -- 1945
			phase, -- 1945
			messages, -- 1945
			shared.llmOptions -- 1945
		) -- 1945
		local lastStreamReasoning = "" -- 1946
		local res = __TS__Await(callLLMStreamAggregated( -- 1947
			messages, -- 1948
			shared.llmOptions, -- 1949
			shared.stopToken, -- 1950
			shared.llmConfig, -- 1951
			function(response) -- 1952
				local ____opt_55 = response.choices -- 1952
				local ____opt_53 = ____opt_55 and ____opt_55[1] -- 1952
				local streamMessage = ____opt_53 and ____opt_53.message -- 1953
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1954
				if nextContent == "" then -- 1954
					return -- 1957
				end -- 1957
				if nextContent == lastStreamReasoning then -- 1957
					return -- 1958
				end -- 1958
				lastStreamReasoning = nextContent -- 1959
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1960
			end -- 1952
		)) -- 1952
		if res.success then -- 1952
			local usage = res.tokenUsage -- 1964
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1965
			local ____opt_61 = res.response.choices -- 1965
			local ____opt_59 = ____opt_61 and ____opt_61[1] -- 1965
			local message = ____opt_59 and ____opt_59.message -- 1966
			local text = message and message.content -- 1967
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1968
			if text then -- 1968
				local parsed = tryParseAndValidateDecision(text, shared) -- 1972
				if parsed.success then -- 1972
					local reason = parsed.reason or "" -- 1974
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1975
				end -- 1975
				saveStepLLMDebugOutput( -- 1977
					shared, -- 1977
					stepId, -- 1977
					phase, -- 1977
					text, -- 1977
					{success = true, usage = usage} -- 1977
				) -- 1977
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1977
			else -- 1977
				saveStepLLMDebugOutput( -- 1980
					shared, -- 1980
					stepId, -- 1980
					phase, -- 1980
					"empty LLM response", -- 1980
					{success = false, usage = usage} -- 1980
				) -- 1980
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1980
			end -- 1980
		else -- 1980
			local usage = res.tokenUsage -- 1984
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1985
			saveStepLLMDebugOutput( -- 1986
				shared, -- 1986
				stepId, -- 1986
				phase, -- 1986
				res.raw or res.message, -- 1986
				{success = false, usage = usage} -- 1986
			) -- 1986
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1986
		end -- 1986
	end) -- 1986
end -- 1938
local function isDecisionBatchSuccess(result) -- 2010
	return result.kind == "batch" -- 2011
end -- 2010
local function parseDecisionToolCall(functionName, rawObj) -- 2035
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2035
		return {success = false, message = "unknown tool: " .. functionName} -- 2037
	end -- 2037
	if rawObj == nil then -- 2037
		return {success = true, tool = functionName, params = {}} -- 2040
	end -- 2040
	if not isRecord(rawObj) then -- 2040
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2043
	end -- 2043
	return {success = true, tool = functionName, params = rawObj} -- 2045
end -- 2035
local function parseToolCallArguments(functionName, argsText) -- 2052
	local trimmedArgs = __TS__StringTrim(argsText) -- 2053
	if trimmedArgs == "" then -- 2053
		return {} -- 2055
	end -- 2055
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 2057
	if err ~= nil or rawObj == nil then -- 2057
		return { -- 2059
			success = false, -- 2060
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2061
			raw = argsText -- 2062
		} -- 2062
	end -- 2062
	local encodedRaw = safeJsonEncode(rawObj) -- 2065
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2065
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2067
	end -- 2067
	return rawObj -- 2073
end -- 2052
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2076
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2084
	if isRecord(rawArgs) and rawArgs.success == false then -- 2084
		return rawArgs -- 2086
	end -- 2086
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2088
	if not decision.success then -- 2088
		return {success = false, message = decision.message, raw = argsText} -- 2090
	end -- 2090
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2096
	if not completionValidation.success then -- 2096
		return {success = false, message = completionValidation.message, raw = argsText} -- 2098
	end -- 2098
	local validation = validateDecision(decision.tool, decision.params) -- 2104
	if not validation.success then -- 2104
		return {success = false, message = validation.message, raw = argsText} -- 2106
	end -- 2106
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params) -- 2112
	if not sharedValidation.success then -- 2112
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2114
	end -- 2114
	decision.params = validation.params -- 2120
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2121
	decision.reason = reason -- 2122
	decision.reasoningContent = reasoningContent -- 2123
	return decision -- 2124
end -- 2076
local function createPreExecutableActionFromStream(shared, toolCall) -- 2127
	local ____opt_67 = toolCall["function"] -- 2127
	local functionName = ____opt_67 and ____opt_67.name -- 2128
	local ____opt_69 = toolCall["function"] -- 2128
	local argsText = ____opt_69 and ____opt_69.arguments or "" -- 2129
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2130
	if not functionName or not toolCallId then -- 2130
		return nil -- 2131
	end -- 2131
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2132
	if isRecord(rawArgs) and rawArgs.success == false then -- 2132
		return nil -- 2133
	end -- 2133
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2134
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2134
		return nil -- 2135
	end -- 2135
	local validation = validateDecision(decision.tool, decision.params) -- 2136
	if not validation.success then -- 2136
		return nil -- 2137
	end -- 2137
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2137
		return nil -- 2138
	end -- 2138
	return { -- 2139
		step = shared.step + 1, -- 2140
		toolCallId = toolCallId, -- 2141
		tool = decision.tool, -- 2142
		reason = "", -- 2143
		params = validation.params, -- 2144
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2145
	} -- 2145
end -- 2127
local function sanitizeMessagesForLLMInput(messages) -- 2388
	local sanitized = {} -- 2389
	local droppedAssistantToolCalls = 0 -- 2390
	local droppedToolResults = 0 -- 2391
	do -- 2391
		local i = 0 -- 2392
		while i < #messages do -- 2392
			do -- 2392
				local message = messages[i + 1] -- 2393
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2393
					local requiredIds = {} -- 2395
					do -- 2395
						local j = 0 -- 2396
						while j < #message.tool_calls do -- 2396
							local toolCall = message.tool_calls[j + 1] -- 2397
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2398
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2398
								requiredIds[#requiredIds + 1] = id -- 2400
							end -- 2400
							j = j + 1 -- 2396
						end -- 2396
					end -- 2396
					if #requiredIds == 0 then -- 2396
						sanitized[#sanitized + 1] = message -- 2404
						goto __continue404 -- 2405
					end -- 2405
					local matchedIds = {} -- 2407
					local matchedTools = {} -- 2408
					local j = i + 1 -- 2409
					while j < #messages do -- 2409
						local toolMessage = messages[j + 1] -- 2411
						if toolMessage.role ~= "tool" then -- 2411
							break -- 2412
						end -- 2412
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2413
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2413
							matchedIds[toolCallId] = true -- 2415
							matchedTools[#matchedTools + 1] = toolMessage -- 2416
						else -- 2416
							droppedToolResults = droppedToolResults + 1 -- 2418
						end -- 2418
						j = j + 1 -- 2420
					end -- 2420
					local complete = true -- 2422
					do -- 2422
						local j = 0 -- 2423
						while j < #requiredIds do -- 2423
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2423
								complete = false -- 2425
								break -- 2426
							end -- 2426
							j = j + 1 -- 2423
						end -- 2423
					end -- 2423
					if complete then -- 2423
						__TS__ArrayPush( -- 2430
							sanitized, -- 2430
							message, -- 2430
							table.unpack(matchedTools) -- 2430
						) -- 2430
					else -- 2430
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2432
						droppedToolResults = droppedToolResults + #matchedTools -- 2433
					end -- 2433
					i = j - 1 -- 2435
					goto __continue404 -- 2436
				end -- 2436
				if message.role == "tool" then -- 2436
					droppedToolResults = droppedToolResults + 1 -- 2439
					goto __continue404 -- 2440
				end -- 2440
				sanitized[#sanitized + 1] = message -- 2442
			end -- 2442
			::__continue404:: -- 2442
			i = i + 1 -- 2392
		end -- 2392
	end -- 2392
	return sanitized -- 2444
end -- 2388
local function getUnconsolidatedMessages(shared) -- 2447
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2448
end -- 2447
local function getFinalDecisionTurnPrompt(shared) -- 2451
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2452
end -- 2451
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2457
	if attempt == nil then -- 2457
		attempt = 1 -- 2460
	end -- 2460
	if decisionMode == nil then -- 2460
		decisionMode = shared.decisionMode -- 2462
	end -- 2462
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2464
	local tailSections = {} -- 2465
	if shared.resumeCheckpointPending == true then -- 2465
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2467
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2470
	end -- 2470
	if shared.truncatedToolOverwritePath ~= nil then -- 2470
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2473
	end -- 2473
	shared.resumeCheckpointPending = false -- 2475
	local messages = { -- 2476
		{role = "system", content = systemPrompt}, -- 2477
		table.unpack(getUnconsolidatedMessages(shared)) -- 2478
	} -- 2478
	if shared.step + 1 >= shared.maxSteps then -- 2478
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2481
	end -- 2481
	if lastError and lastError ~= "" then -- 2481
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2484
		if decisionMode == "xml" then -- 2484
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2488
		end -- 2488
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2488
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2491
		end -- 2491
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2491
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2494
		end -- 2494
		messages[#messages + 1] = { -- 2496
			role = "user", -- 2497
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2498
		} -- 2498
	end -- 2498
	tailSections[#tailSections + 1] = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2505
		role = shared.role, -- 2506
		workMode = shared.workMode, -- 2507
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2508
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2509
		resumeRequiredTool = shared.resumeRequiredTool, -- 2510
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2511
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2512
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2513
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2514
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2515
		buildRepairPending = shared.buildRepairPending, -- 2516
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2517
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2518
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2519
	}) -- 2519
	messages[#messages + 1] = { -- 2521
		role = "user", -- 2522
		content = table.concat(tailSections, "\n\n") -- 2523
	} -- 2523
	return messages -- 2525
end -- 2457
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2532
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2541
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2542
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2550
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2551
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2552
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2560
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2568
		shared.role, -- 2568
		{ -- 2568
			includeFinish = true, -- 2569
			includeXmlRules = true, -- 2570
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2571
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2572
			workMode = shared.workMode -- 2573
		} -- 2573
	) -- 2573
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2575
	local repairPrompt = replacePromptVars( -- 2578
		shared.promptPack.xmlDecisionRepairPrompt, -- 2578
		{ -- 2578
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2579
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2580
			CANDIDATE_SECTION = candidateSection, -- 2581
			LAST_ERROR = lastError, -- 2582
			ATTEMPT = tostring(attempt) -- 2583
		} -- 2583
	) -- 2583
	local availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2585
		role = shared.role, -- 2586
		workMode = shared.workMode, -- 2587
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2588
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2589
		resumeRequiredTool = shared.resumeRequiredTool, -- 2590
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2591
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2592
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2593
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2594
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2595
		buildRepairPending = shared.buildRepairPending, -- 2596
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2597
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2598
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2599
	}) -- 2599
	return {{role = "system", content = systemPrompt}, {role = "user", content = (repairPrompt .. "\n\n") .. availabilityPrompt}} -- 2601
end -- 2532
local function replaceFirst(text, oldStr, newStr) -- 2639
	if oldStr == "" then -- 2639
		return text -- 2640
	end -- 2640
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2641
	if idx < 0 then -- 2641
		return text -- 2642
	end -- 2642
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2643
end -- 2639
local function splitLines(text) -- 2646
	return __TS__StringSplit(text, "\n") -- 2647
end -- 2646
local function getLeadingWhitespace(text) -- 2650
	local i = 0 -- 2651
	while i < #text do -- 2651
		local ch = __TS__StringAccess(text, i) -- 2653
		if ch ~= " " and ch ~= "\t" then -- 2653
			break -- 2654
		end -- 2654
		i = i + 1 -- 2655
	end -- 2655
	return __TS__StringSubstring(text, 0, i) -- 2657
end -- 2650
local function getCommonIndentPrefix(lines) -- 2660
	local common -- 2661
	do -- 2661
		local i = 0 -- 2662
		while i < #lines do -- 2662
			do -- 2662
				local line = lines[i + 1] -- 2663
				if __TS__StringTrim(line) == "" then -- 2663
					goto __continue447 -- 2664
				end -- 2664
				local indent = getLeadingWhitespace(line) -- 2665
				if common == nil then -- 2665
					common = indent -- 2667
					goto __continue447 -- 2668
				end -- 2668
				local j = 0 -- 2670
				local maxLen = math.min(#common, #indent) -- 2671
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2671
					j = j + 1 -- 2673
				end -- 2673
				common = __TS__StringSubstring(common, 0, j) -- 2675
				if common == "" then -- 2675
					break -- 2676
				end -- 2676
			end -- 2676
			::__continue447:: -- 2676
			i = i + 1 -- 2662
		end -- 2662
	end -- 2662
	return common or "" -- 2678
end -- 2660
local function removeIndentPrefix(line, indent) -- 2681
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2681
		return __TS__StringSubstring(line, #indent) -- 2683
	end -- 2683
	local lineIndent = getLeadingWhitespace(line) -- 2685
	local j = 0 -- 2686
	local maxLen = math.min(#lineIndent, #indent) -- 2687
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2687
		j = j + 1 -- 2689
	end -- 2689
	return __TS__StringSubstring(line, j) -- 2691
end -- 2681
local function dedentLines(lines) -- 2694
	local indent = getCommonIndentPrefix(lines) -- 2695
	return { -- 2696
		indent = indent, -- 2697
		lines = __TS__ArrayMap( -- 2698
			lines, -- 2698
			function(____, line) return removeIndentPrefix(line, indent) end -- 2698
		) -- 2698
	} -- 2698
end -- 2694
local function joinLines(lines) -- 2702
	return table.concat(lines, "\n") -- 2703
end -- 2702
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2706
	local function findWhitespaceTolerantReplacement() -- 2711
		local function foldWhitespace(text, withMap) -- 2713
			local parts = {} -- 2714
			local map = {} -- 2715
			local i = 0 -- 2716
			while i < #text do -- 2716
				local ch = __TS__StringAccess(text, i) -- 2718
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2718
					local start = i -- 2720
					while i < #text do -- 2720
						local next = __TS__StringAccess(text, i) -- 2722
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2722
							break -- 2723
						end -- 2723
						i = i + 1 -- 2724
					end -- 2724
					parts[#parts + 1] = " " -- 2726
					if withMap then -- 2726
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2727
					end -- 2727
				else -- 2727
					parts[#parts + 1] = ch -- 2729
					if withMap then -- 2729
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2730
					end -- 2730
					i = i + 1 -- 2731
				end -- 2731
			end -- 2731
			return { -- 2734
				text = table.concat(parts, ""), -- 2734
				map = map -- 2734
			} -- 2734
		end -- 2713
		local foldedContent = foldWhitespace(content, true) -- 2736
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2737
		if foldedOld == "" then -- 2737
			return {success = false, message = "old_str not found in file"} -- 2739
		end -- 2739
		local matches = {} -- 2741
		local pos = 0 -- 2742
		while true do -- 2742
			local idx = (string.find( -- 2744
				foldedContent.text, -- 2744
				foldedOld, -- 2744
				math.max(pos + 1, 1), -- 2744
				true -- 2744
			) or 0) - 1 -- 2744
			if idx < 0 then -- 2744
				break -- 2745
			end -- 2745
			local lastIdx = idx + #foldedOld - 1 -- 2746
			local startMap = foldedContent.map[idx + 1] -- 2747
			local endMap = foldedContent.map[lastIdx + 1] -- 2748
			if startMap ~= nil and endMap ~= nil then -- 2748
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2750
			end -- 2750
			pos = idx + #foldedOld -- 2752
		end -- 2752
		if #matches == 0 then -- 2752
			return {success = false, message = "old_str not found in file"} -- 2755
		end -- 2755
		if #matches > 1 then -- 2755
			return { -- 2758
				success = false, -- 2759
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2760
			} -- 2760
		end -- 2760
		local match = matches[1] -- 2763
		return { -- 2764
			success = true, -- 2765
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2766
		} -- 2766
	end -- 2711
	local contentLines = splitLines(content) -- 2769
	local oldLines = splitLines(oldStr) -- 2770
	if #oldLines == 0 then -- 2770
		return {success = false, message = "old_str not found in file"} -- 2772
	end -- 2772
	local dedentedOld = dedentLines(oldLines) -- 2774
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2775
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2776
	local matches = {} -- 2777
	do -- 2777
		local start = 0 -- 2778
		while start <= #contentLines - #oldLines do -- 2778
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2779
			local dedentedCandidate = dedentLines(candidateLines) -- 2780
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2780
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2782
			end -- 2782
			start = start + 1 -- 2778
		end -- 2778
	end -- 2778
	if #matches == 0 then -- 2778
		return findWhitespaceTolerantReplacement() -- 2790
	end -- 2790
	if #matches > 1 then -- 2790
		return { -- 2793
			success = false, -- 2794
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2795
		} -- 2795
	end -- 2795
	local match = matches[1] -- 2798
	local rebuiltNewLines = __TS__ArrayMap( -- 2799
		dedentedNew.lines, -- 2799
		function(____, line) return line == "" and "" or match.indent .. line end -- 2799
	) -- 2799
	local ____array_75 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2799
	__TS__SparseArrayPush( -- 2799
		____array_75, -- 2799
		table.unpack(rebuiltNewLines) -- 2802
	) -- 2802
	__TS__SparseArrayPush( -- 2802
		____array_75, -- 2802
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2803
	) -- 2803
	local nextLines = {__TS__SparseArraySpread(____array_75)} -- 2800
	return { -- 2805
		success = true, -- 2805
		content = joinLines(nextLines) -- 2805
	} -- 2805
end -- 2706
local MainDecisionAgent = __TS__Class() -- 2808
MainDecisionAgent.name = "MainDecisionAgent" -- 2808
__TS__ClassExtends(MainDecisionAgent, Node) -- 2808
function MainDecisionAgent.prototype.prep(self, shared) -- 2809
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2809
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2809
			return ____awaiter_resolve(nil, {shared = shared}) -- 2809
		end -- 2809
		__TS__Await(maybeCompressHistory(shared)) -- 2814
		return ____awaiter_resolve(nil, {shared = shared}) -- 2814
	end) -- 2814
end -- 2809
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2819
	local preExecuted = shared.preExecutedResults -- 2820
	if not preExecuted or preExecuted.size == 0 then -- 2820
		return nil -- 2821
	end -- 2821
	local decisions = {} -- 2822
	preExecuted:forEach(function(____, preResult) -- 2823
		local action = preResult.action -- 2824
		decisions[#decisions + 1] = { -- 2825
			success = true, -- 2826
			tool = action.tool, -- 2827
			params = action.params, -- 2828
			toolCallId = action.toolCallId, -- 2829
			reason = action.reason, -- 2830
			reasoningContent = action.reasoningContent -- 2831
		} -- 2831
	end) -- 2823
	if #decisions == 0 then -- 2823
		return nil -- 2834
	end -- 2834
	Log( -- 2835
		"Warn", -- 2835
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2835
			__TS__ArrayMap( -- 2835
				decisions, -- 2835
				function(____, decision) return decision.tool end -- 2835
			), -- 2835
			"," -- 2835
		) -- 2835
	) -- 2835
	if #decisions == 1 then -- 2835
		return decisions[1] -- 2837
	end -- 2837
	return {success = true, kind = "batch", decisions = decisions} -- 2839
end -- 2819
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2846
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2851
	if not recovery then -- 2851
		return nil -- 2852
	end -- 2852
	shared.truncatedToolOverwritePath = recovery.target -- 2853
	Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2854
	return { -- 2855
		success = true, -- 2856
		tool = "edit_file", -- 2857
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2858
		toolCallId = createLocalToolCallId(), -- 2864
		reason = recovery.reason, -- 2865
		reasoningContent = reasoningContent -- 2866
	} -- 2866
end -- 2846
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2870
	if attempt == nil then -- 2870
		attempt = 1 -- 2873
	end -- 2873
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2873
		if shared.stopToken.stopped then -- 2873
			return ____awaiter_resolve( -- 2873
				nil, -- 2873
				{ -- 2877
					success = false, -- 2877
					message = getCancelledReason(shared) -- 2877
				} -- 2877
			) -- 2877
		end -- 2877
		Log( -- 2879
			"Info", -- 2879
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2879
		) -- 2879
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2880
			shared.role, -- 2880
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2880
			{ -- 2880
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2881
				workMode = shared.workMode -- 2882
			} -- 2882
		) -- 2882
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2884
		local stepId = shared.step + 1 -- 2885
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2886
			string.lower(shared.llmConfig.model), -- 2886
			"glm-5.2" -- 2886
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2886
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2889
		emitLLMContextMetrics( -- 2894
			shared, -- 2894
			stepId, -- 2894
			"decision_tool_calling", -- 2894
			messages, -- 2894
			llmOptions -- 2894
		) -- 2894
		saveStepLLMDebugInput( -- 2895
			shared, -- 2895
			stepId, -- 2895
			"decision_tool_calling", -- 2895
			messages, -- 2895
			llmOptions -- 2895
		) -- 2895
		local lastStreamContent = "" -- 2896
		local lastStreamReasoning = "" -- 2897
		local preExecutedResults = __TS__New(Map) -- 2898
		shared.preExecutedResults = preExecutedResults -- 2899
		local res = __TS__Await(callLLMStreamAggregated( -- 2900
			messages, -- 2901
			llmOptions, -- 2902
			shared.stopToken, -- 2903
			shared.llmConfig, -- 2904
			function(response) -- 2905
				local ____opt_78 = response.choices -- 2905
				local ____opt_76 = ____opt_78 and ____opt_78[1] -- 2905
				local streamMessage = ____opt_76 and ____opt_76.message -- 2906
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2907
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2910
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2910
					return -- 2914
				end -- 2914
				lastStreamContent = nextContent -- 2916
				lastStreamReasoning = nextReasoning -- 2917
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2918
			end, -- 2905
			function(tc) -- 2920
				if shared.stopToken.stopped then -- 2920
					return -- 2921
				end -- 2921
				local action = createPreExecutableActionFromStream(shared, tc) -- 2922
				if not action or preExecutedResults:has(action.toolCallId) then -- 2922
					return -- 2923
				end -- 2923
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2924
				preExecutedResults:set( -- 2925
					action.toolCallId, -- 2925
					createPreExecutedToolResult(shared, action) -- 2925
				) -- 2925
			end -- 2920
		)) -- 2920
		if shared.stopToken.stopped then -- 2920
			clearPreExecutedResults(shared) -- 2929
			return ____awaiter_resolve( -- 2929
				nil, -- 2929
				{ -- 2930
					success = false, -- 2930
					message = getCancelledReason(shared) -- 2930
				} -- 2930
			) -- 2930
		end -- 2930
		if not res.success then -- 2930
			local usage = res.tokenUsage -- 2933
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2934
			saveStepLLMDebugOutput( -- 2935
				shared, -- 2935
				stepId, -- 2935
				"decision_tool_calling", -- 2935
				res.raw or res.message, -- 2935
				{success = false, usage = usage} -- 2935
			) -- 2935
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2936
			local committed = self:commitPreExecutedDecision(shared) -- 2937
			if committed then -- 2937
				return ____awaiter_resolve(nil, committed) -- 2937
			end -- 2937
			local ____opt_86 = res.response -- 2937
			local ____opt_84 = ____opt_86 and ____opt_86.choices -- 2937
			local partialChoice = ____opt_84 and ____opt_84[1] -- 2939
			local ____self_preserveTruncatedEditDecision_98 = self.preserveTruncatedEditDecision -- 2940
			local ____shared_96 = shared -- 2941
			local ____opt_88 = partialChoice and partialChoice.message -- 2941
			local ____temp_97 = ____opt_88 and ____opt_88.tool_calls -- 2942
			local ____opt_92 = partialChoice and partialChoice.message -- 2942
			local partialDraft = ____self_preserveTruncatedEditDecision_98(self, ____shared_96, ____temp_97, ____opt_92 and ____opt_92.reasoning_content) -- 2940
			if partialDraft then -- 2940
				return ____awaiter_resolve(nil, partialDraft) -- 2940
			end -- 2940
			clearPreExecutedResults(shared) -- 2946
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2946
		end -- 2946
		local usage = res.tokenUsage -- 2949
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2950
		saveStepLLMDebugOutput( -- 2951
			shared, -- 2951
			stepId, -- 2951
			"decision_tool_calling", -- 2951
			encodeDebugJSON(res.response), -- 2951
			{success = true, usage = usage} -- 2951
		) -- 2951
		local choice = res.response.choices and res.response.choices[1] -- 2952
		local message = choice and choice.message -- 2953
		local toolCalls = message and message.tool_calls -- 2954
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2955
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2958
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2961
		Log( -- 2964
			"Info", -- 2964
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2964
		) -- 2964
		if finishReason == "length" then -- 2964
			local committed = self:commitPreExecutedDecision(shared) -- 2966
			if committed then -- 2966
				return ____awaiter_resolve(nil, committed) -- 2966
			end -- 2966
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 2968
			if partialDraft then -- 2968
				return ____awaiter_resolve(nil, partialDraft) -- 2968
			end -- 2968
			Log( -- 2970
				"Error", -- 2970
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2970
			) -- 2970
			clearPreExecutedResults(shared) -- 2971
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 2971
		end -- 2971
		if not toolCalls or #toolCalls == 0 then -- 2971
			if messageContent and messageContent ~= "" then -- 2971
				if shared.role == "sub" then -- 2971
					Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 2981
					clearPreExecutedResults(shared) -- 2982
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 2982
				end -- 2982
				Log( -- 2989
					"Info", -- 2989
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2989
				) -- 2989
				clearPreExecutedResults(shared) -- 2990
				return ____awaiter_resolve(nil, { -- 2990
					success = true, -- 2992
					tool = "finish", -- 2993
					params = {}, -- 2994
					reason = messageContent, -- 2995
					reasoningContent = reasoningContent, -- 2996
					directSummary = messageContent -- 2997
				}) -- 2997
			end -- 2997
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3000
			clearPreExecutedResults(shared) -- 3001
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3001
		end -- 3001
		local decisions = {} -- 3008
		do -- 3008
			local i = 0 -- 3009
			while i < #toolCalls do -- 3009
				local toolCall = toolCalls[i + 1] -- 3010
				local fn = toolCall ~= nil and toolCall["function"] -- 3011
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3011
					Log( -- 3013
						"Error", -- 3013
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3013
					) -- 3013
					clearPreExecutedResults(shared) -- 3014
					return ____awaiter_resolve( -- 3014
						nil, -- 3014
						{ -- 3015
							success = false, -- 3016
							message = "missing function name for tool call " .. tostring(i + 1), -- 3017
							raw = messageContent -- 3018
						} -- 3018
					) -- 3018
				end -- 3018
				local functionName = fn.name -- 3021
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3022
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3023
				Log( -- 3026
					"Info", -- 3026
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3026
				) -- 3026
				local decision = parseAndValidateToolCallDecision( -- 3027
					shared, -- 3028
					functionName, -- 3029
					argsText, -- 3030
					toolCallId, -- 3031
					messageContent, -- 3032
					reasoningContent -- 3033
				) -- 3033
				if not decision.success then -- 3033
					Log( -- 3036
						"Error", -- 3036
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3036
					) -- 3036
					clearPreExecutedResults(shared) -- 3037
					return ____awaiter_resolve(nil, decision) -- 3037
				end -- 3037
				decisions[#decisions + 1] = decision -- 3040
				i = i + 1 -- 3009
			end -- 3009
		end -- 3009
		if #decisions == 1 then -- 3009
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3043
			return ____awaiter_resolve(nil, decisions[1]) -- 3043
		end -- 3043
		do -- 3043
			local i = 0 -- 3046
			while i < #decisions do -- 3046
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3046
					clearPreExecutedResults(shared) -- 3048
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3048
				end -- 3048
				i = i + 1 -- 3046
			end -- 3046
		end -- 3046
		Log( -- 3056
			"Info", -- 3056
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3056
				__TS__ArrayMap( -- 3056
					decisions, -- 3056
					function(____, decision) return decision.tool end -- 3056
				), -- 3056
				"," -- 3056
			) -- 3056
		) -- 3056
		return ____awaiter_resolve(nil, { -- 3056
			success = true, -- 3058
			kind = "batch", -- 3059
			decisions = decisions, -- 3060
			content = messageContent, -- 3061
			reasoningContent = reasoningContent -- 3062
		}) -- 3062
	end) -- 3062
end -- 2870
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3066
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3066
		Log( -- 3072
			"Info", -- 3072
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3072
		) -- 3072
		local lastError = initialError -- 3073
		local candidateRaw = "" -- 3074
		local candidateReasoning = nil -- 3075
		do -- 3075
			local attempt = 0 -- 3076
			while attempt < shared.llmMaxTry do -- 3076
				do -- 3076
					Log( -- 3077
						"Info", -- 3077
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3077
					) -- 3077
					local messages = buildXmlRepairMessages( -- 3078
						shared, -- 3079
						originalRaw, -- 3080
						originalReasoning, -- 3081
						candidateRaw, -- 3082
						candidateReasoning, -- 3083
						lastError, -- 3084
						attempt + 1 -- 3085
					) -- 3085
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3087
					if shared.stopToken.stopped then -- 3087
						return ____awaiter_resolve( -- 3087
							nil, -- 3087
							{ -- 3089
								success = false, -- 3089
								message = getCancelledReason(shared) -- 3089
							} -- 3089
						) -- 3089
					end -- 3089
					if not llmRes.success then -- 3089
						lastError = llmRes.message -- 3092
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3093
						goto __continue519 -- 3094
					end -- 3094
					candidateRaw = llmRes.text -- 3096
					candidateReasoning = llmRes.reasoningContent -- 3097
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3098
					if decision.success then -- 3098
						decision.reasoningContent = llmRes.reasoningContent -- 3100
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3101
						return ____awaiter_resolve(nil, decision) -- 3101
					end -- 3101
					lastError = decision.message -- 3104
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3105
				end -- 3105
				::__continue519:: -- 3105
				attempt = attempt + 1 -- 3076
			end -- 3076
		end -- 3076
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3107
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3107
	end) -- 3107
end -- 3066
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3115
	if attempt == nil then -- 3115
		attempt = 1 -- 3118
	end -- 3118
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3118
		local messages = buildDecisionMessages( -- 3121
			shared, -- 3122
			lastError, -- 3123
			attempt, -- 3124
			lastRaw, -- 3125
			"xml" -- 3126
		) -- 3126
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3128
		if shared.stopToken.stopped then -- 3128
			return ____awaiter_resolve( -- 3128
				nil, -- 3128
				{ -- 3130
					success = false, -- 3130
					message = getCancelledReason(shared) -- 3130
				} -- 3130
			) -- 3130
		end -- 3130
		if not llmRes.success then -- 3130
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3130
		end -- 3130
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3139
		if decision.success then -- 3139
			decision.reasoningContent = llmRes.reasoningContent -- 3141
			return ____awaiter_resolve(nil, decision) -- 3141
		end -- 3141
		return ____awaiter_resolve( -- 3141
			nil, -- 3141
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3144
		) -- 3144
	end) -- 3144
end -- 3115
function MainDecisionAgent.prototype.exec(self, input) -- 3147
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3147
		local shared = input.shared -- 3148
		if shared.stopToken.stopped then -- 3148
			return ____awaiter_resolve( -- 3148
				nil, -- 3148
				{ -- 3150
					success = false, -- 3150
					message = getCancelledReason(shared) -- 3150
				} -- 3150
			) -- 3150
		end -- 3150
		if shared.step >= shared.maxSteps then -- 3150
			Log( -- 3153
				"Warn", -- 3153
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3153
			) -- 3153
			return ____awaiter_resolve( -- 3153
				nil, -- 3153
				{ -- 3154
					success = false, -- 3154
					message = getMaxStepsReachedReason(shared) -- 3154
				} -- 3154
			) -- 3154
		end -- 3154
		if shared.decisionMode == "tool_calling" then -- 3154
			Log( -- 3158
				"Info", -- 3158
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3158
			) -- 3158
			local lastError = "tool calling validation failed" -- 3159
			local lastRaw = "" -- 3160
			local shouldFallbackToXml = false -- 3161
			do -- 3161
				local attempt = 0 -- 3162
				while attempt < shared.llmMaxTry do -- 3162
					Log( -- 3163
						"Info", -- 3163
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3163
					) -- 3163
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3164
					if shared.stopToken.stopped then -- 3164
						return ____awaiter_resolve( -- 3164
							nil, -- 3164
							{ -- 3171
								success = false, -- 3171
								message = getCancelledReason(shared) -- 3171
							} -- 3171
						) -- 3171
					end -- 3171
					if decision.success then -- 3171
						return ____awaiter_resolve(nil, decision) -- 3171
					end -- 3171
					lastError = decision.message -- 3176
					lastRaw = decision.raw or "" -- 3177
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3178
					if lastError == "missing tool call" then -- 3178
						shouldFallbackToXml = true -- 3180
						break -- 3181
					end -- 3181
					attempt = attempt + 1 -- 3162
				end -- 3162
			end -- 3162
			if shouldFallbackToXml then -- 3162
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3185
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3186
				do -- 3186
					local attempt = 0 -- 3187
					while attempt < shared.llmMaxTry do -- 3187
						Log( -- 3188
							"Info", -- 3188
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3188
						) -- 3188
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3189
						if shared.stopToken.stopped then -- 3189
							return ____awaiter_resolve( -- 3189
								nil, -- 3189
								{ -- 3196
									success = false, -- 3196
									message = getCancelledReason(shared) -- 3196
								} -- 3196
							) -- 3196
						end -- 3196
						if decision.success then -- 3196
							return ____awaiter_resolve(nil, decision) -- 3196
						end -- 3196
						lastError = decision.message -- 3201
						lastRaw = decision.raw or "" -- 3202
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3203
						attempt = attempt + 1 -- 3187
					end -- 3187
				end -- 3187
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3205
				return ____awaiter_resolve( -- 3205
					nil, -- 3205
					{ -- 3206
						success = false, -- 3206
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3206
					} -- 3206
				) -- 3206
			end -- 3206
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3208
			return ____awaiter_resolve( -- 3208
				nil, -- 3208
				{ -- 3209
					success = false, -- 3209
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3209
				} -- 3209
			) -- 3209
		end -- 3209
		local lastError = "xml validation failed" -- 3212
		local lastRaw = "" -- 3213
		do -- 3213
			local attempt = 0 -- 3214
			while attempt < shared.llmMaxTry do -- 3214
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3215
				if shared.stopToken.stopped then -- 3215
					return ____awaiter_resolve( -- 3215
						nil, -- 3215
						{ -- 3224
							success = false, -- 3224
							message = getCancelledReason(shared) -- 3224
						} -- 3224
					) -- 3224
				end -- 3224
				if decision.success then -- 3224
					return ____awaiter_resolve(nil, decision) -- 3224
				end -- 3224
				lastError = decision.message -- 3229
				lastRaw = decision.raw or "" -- 3230
				attempt = attempt + 1 -- 3214
			end -- 3214
		end -- 3214
		return ____awaiter_resolve( -- 3214
			nil, -- 3214
			{ -- 3232
				success = false, -- 3232
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3232
			} -- 3232
		) -- 3232
	end) -- 3232
end -- 3147
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3235
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3235
		local result = execRes -- 3236
		if not result.success then -- 3236
			if shared.stopToken.stopped then -- 3236
				shared.error = getCancelledReason(shared) -- 3239
				shared.done = true -- 3240
				return ____awaiter_resolve(nil, "done") -- 3240
			end -- 3240
			shared.error = result.message -- 3243
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3244
			shared.done = true -- 3245
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3246
			persistHistoryState(shared) -- 3250
			return ____awaiter_resolve(nil, "done") -- 3250
		end -- 3250
		if isDecisionBatchSuccess(result) then -- 3250
			local startStep = shared.step -- 3254
			local actions = {} -- 3255
			do -- 3255
				local i = 0 -- 3256
				while i < #result.decisions do -- 3256
					local decision = result.decisions[i + 1] -- 3257
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3258
					local step = startStep + i + 1 -- 3259
					local ____temp_99 -- 3260
					if i == 0 then -- 3260
						____temp_99 = decision.reason -- 3260
					else -- 3260
						____temp_99 = "" -- 3260
					end -- 3260
					local actionReason = ____temp_99 -- 3260
					local ____temp_100 -- 3261
					if i == 0 then -- 3261
						____temp_100 = decision.reasoningContent -- 3261
					else -- 3261
						____temp_100 = nil -- 3261
					end -- 3261
					local actionReasoningContent = ____temp_100 -- 3261
					emitAgentEvent(shared, { -- 3262
						type = "decision_made", -- 3263
						sessionId = shared.sessionId, -- 3264
						taskId = shared.taskId, -- 3265
						step = step, -- 3266
						tool = decision.tool, -- 3267
						reason = actionReason, -- 3268
						reasoningContent = actionReasoningContent, -- 3269
						params = decision.params -- 3270
					}) -- 3270
					local action = { -- 3272
						step = step, -- 3273
						toolCallId = toolCallId, -- 3274
						tool = decision.tool, -- 3275
						reason = actionReason or "", -- 3276
						reasoningContent = actionReasoningContent, -- 3277
						params = decision.params, -- 3278
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3279
					} -- 3279
					local ____shared_history_101 = shared.history -- 3279
					____shared_history_101[#____shared_history_101 + 1] = action -- 3281
					actions[#actions + 1] = action -- 3282
					i = i + 1 -- 3256
				end -- 3256
			end -- 3256
			shared.step = startStep + #actions -- 3284
			shared.pendingToolActions = actions -- 3285
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3286
			persistHistoryState(shared) -- 3292
			return ____awaiter_resolve(nil, "batch_tools") -- 3292
		end -- 3292
		if result.directSummary and result.directSummary ~= "" then -- 3292
			shared.response = result.directSummary -- 3296
			shared.completion = ____exports.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3297
			shared.done = true -- 3301
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3302
			persistHistoryState(shared) -- 3307
			return ____awaiter_resolve(nil, "done") -- 3307
		end -- 3307
		if result.tool == "finish" then -- 3307
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3311
			shared.response = finalMessage -- 3312
			shared.completion = getCompletionReport(result.params) -- 3313
			shared.done = true -- 3314
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3315
			persistHistoryState(shared) -- 3320
			return ____awaiter_resolve(nil, "done") -- 3320
		end -- 3320
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3323
		shared.step = shared.step + 1 -- 3324
		local step = shared.step -- 3325
		emitAgentEvent(shared, { -- 3326
			type = "decision_made", -- 3327
			sessionId = shared.sessionId, -- 3328
			taskId = shared.taskId, -- 3329
			step = step, -- 3330
			tool = result.tool, -- 3331
			reason = result.reason, -- 3332
			reasoningContent = result.reasoningContent, -- 3333
			params = result.params -- 3334
		}) -- 3334
		local ____shared_history_102 = shared.history -- 3334
		____shared_history_102[#____shared_history_102 + 1] = { -- 3336
			step = step, -- 3337
			toolCallId = toolCallId, -- 3338
			tool = result.tool, -- 3339
			reason = result.reason or "", -- 3340
			reasoningContent = result.reasoningContent, -- 3341
			params = result.params, -- 3342
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3343
		} -- 3343
		local action = shared.history[#shared.history] -- 3345
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3346
		shared.pendingToolActions = {action} -- 3349
		persistHistoryState(shared) -- 3350
		return ____awaiter_resolve(nil, "batch_tools") -- 3350
	end) -- 3350
end -- 3235
local ReadFileAction = __TS__Class() -- 3355
ReadFileAction.name = "ReadFileAction" -- 3355
__TS__ClassExtends(ReadFileAction, Node) -- 3355
function ReadFileAction.prototype.prep(self, shared) -- 3356
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3356
		local last = shared.history[#shared.history] -- 3357
		if not last then -- 3357
			error( -- 3358
				__TS__New(Error, "no history"), -- 3358
				0 -- 3358
			) -- 3358
		end -- 3358
		emitAgentStartEvent(shared, last) -- 3359
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3360
		if __TS__StringTrim(path) == "" then -- 3360
			error( -- 3363
				__TS__New(Error, "missing path"), -- 3363
				0 -- 3363
			) -- 3363
		end -- 3363
		local ____path_105 = path -- 3365
		local ____shared_workingDir_106 = shared.workingDir -- 3367
		local ____temp_107 = shared.useChineseResponse and "zh" or "en" -- 3368
		local ____last_params_startLine_103 = last.params.startLine -- 3369
		if ____last_params_startLine_103 == nil then -- 3369
			____last_params_startLine_103 = 1 -- 3369
		end -- 3369
		local ____TS__Number_result_108 = __TS__Number(____last_params_startLine_103) -- 3369
		local ____last_params_endLine_104 = last.params.endLine -- 3370
		if ____last_params_endLine_104 == nil then -- 3370
			____last_params_endLine_104 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3370
		end -- 3370
		return ____awaiter_resolve( -- 3370
			nil, -- 3370
			{ -- 3364
				path = ____path_105, -- 3365
				tool = "read_file", -- 3366
				workDir = ____shared_workingDir_106, -- 3367
				docLanguage = ____temp_107, -- 3368
				startLine = ____TS__Number_result_108, -- 3369
				endLine = __TS__Number(____last_params_endLine_104) -- 3370
			} -- 3370
		) -- 3370
	end) -- 3370
end -- 3356
function ReadFileAction.prototype.exec(self, input) -- 3374
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3374
		return ____awaiter_resolve( -- 3374
			nil, -- 3374
			Tools.readFile( -- 3375
				input.workDir, -- 3376
				input.path, -- 3377
				__TS__Number(input.startLine or 1), -- 3378
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3379
				input.docLanguage -- 3380
			) -- 3380
		) -- 3380
	end) -- 3380
end -- 3374
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3384
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3384
		local result = execRes -- 3385
		local last = shared.history[#shared.history] -- 3386
		if last ~= nil then -- 3386
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3388
			appendToolResultMessage(shared, last) -- 3389
			emitAgentFinishEvent(shared, last) -- 3390
		end -- 3390
		persistHistoryState(shared) -- 3392
		__TS__Await(maybeCompressHistory(shared)) -- 3393
		persistHistoryState(shared) -- 3394
		return ____awaiter_resolve(nil, "main") -- 3394
	end) -- 3394
end -- 3384
local SearchFilesAction = __TS__Class() -- 3399
SearchFilesAction.name = "SearchFilesAction" -- 3399
__TS__ClassExtends(SearchFilesAction, Node) -- 3399
function SearchFilesAction.prototype.prep(self, shared) -- 3400
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
function SearchFilesAction.prototype.exec(self, input) -- 3407
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3407
		local params = input.params -- 3408
		local ____Tools_searchFiles_123 = Tools.searchFiles -- 3409
		local ____input_workDir_115 = input.workDir -- 3410
		local ____temp_116 = params.path or "" -- 3411
		local ____temp_117 = params.pattern or "" -- 3412
		local ____params_globs_118 = params.globs -- 3413
		local ____params_useRegex_119 = params.useRegex -- 3414
		local ____params_caseSensitive_120 = params.caseSensitive -- 3415
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_121 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3417
		local ____math_max_111 = math.max -- 3418
		local ____math_floor_110 = math.floor -- 3418
		local ____params_limit_109 = params.limit -- 3418
		if ____params_limit_109 == nil then -- 3418
			____params_limit_109 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3418
		end -- 3418
		local ____math_max_111_result_122 = ____math_max_111( -- 3418
			1, -- 3418
			____math_floor_110(__TS__Number(____params_limit_109)) -- 3418
		) -- 3418
		local ____math_max_114 = math.max -- 3419
		local ____math_floor_113 = math.floor -- 3419
		local ____params_offset_112 = params.offset -- 3419
		if ____params_offset_112 == nil then -- 3419
			____params_offset_112 = 0 -- 3419
		end -- 3419
		local result = __TS__Await(____Tools_searchFiles_123({ -- 3409
			workDir = ____input_workDir_115, -- 3410
			path = ____temp_116, -- 3411
			pattern = ____temp_117, -- 3412
			globs = ____params_globs_118, -- 3413
			useRegex = ____params_useRegex_119, -- 3414
			caseSensitive = ____params_caseSensitive_120, -- 3415
			includeContent = true, -- 3416
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_121, -- 3417
			limit = ____math_max_111_result_122, -- 3418
			offset = ____math_max_114( -- 3419
				0, -- 3419
				____math_floor_113(__TS__Number(____params_offset_112)) -- 3419
			), -- 3419
			groupByFile = params.groupByFile == true -- 3420
		})) -- 3420
		return ____awaiter_resolve(nil, result) -- 3420
	end) -- 3420
end -- 3407
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3425
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3425
		local last = shared.history[#shared.history] -- 3426
		if last ~= nil then -- 3426
			local result = execRes -- 3428
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3429
			appendToolResultMessage(shared, last) -- 3430
			emitAgentFinishEvent(shared, last) -- 3431
		end -- 3431
		persistHistoryState(shared) -- 3433
		__TS__Await(maybeCompressHistory(shared)) -- 3434
		persistHistoryState(shared) -- 3435
		return ____awaiter_resolve(nil, "main") -- 3435
	end) -- 3435
end -- 3425
local SearchDoraAPIAction = __TS__Class() -- 3440
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3440
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3440
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3441
		local last = shared.history[#shared.history] -- 3442
		if not last then -- 3442
			error( -- 3443
				__TS__New(Error, "no history"), -- 3443
				0 -- 3443
			) -- 3443
		end -- 3443
		emitAgentStartEvent(shared, last) -- 3444
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3444
	end) -- 3444
end -- 3441
function SearchDoraAPIAction.prototype.exec(self, input) -- 3448
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3448
		local params = input.params -- 3449
		local ____Tools_searchDoraAPI_132 = Tools.searchDoraAPI -- 3450
		local ____temp_128 = params.pattern or "" -- 3451
		local ____temp_129 = params.docSource or "api" -- 3452
		local ____temp_130 = input.useChineseResponse and "zh" or "en" -- 3453
		local ____temp_131 = params.programmingLanguage or "ts" -- 3454
		local ____math_min_127 = math.min -- 3455
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_126 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3455
		local ____math_max_125 = math.max -- 3455
		local ____params_limit_124 = params.limit -- 3455
		if ____params_limit_124 == nil then -- 3455
			____params_limit_124 = 8 -- 3455
		end -- 3455
		local result = __TS__Await(____Tools_searchDoraAPI_132({ -- 3450
			pattern = ____temp_128, -- 3451
			docSource = ____temp_129, -- 3452
			docLanguage = ____temp_130, -- 3453
			programmingLanguage = ____temp_131, -- 3454
			limit = ____math_min_127( -- 3455
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_126, -- 3455
				____math_max_125( -- 3455
					1, -- 3455
					__TS__Number(____params_limit_124) -- 3455
				) -- 3455
			), -- 3455
			useRegex = params.useRegex, -- 3456
			caseSensitive = false, -- 3457
			includeContent = true, -- 3458
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3459
		})) -- 3459
		return ____awaiter_resolve(nil, result) -- 3459
	end) -- 3459
end -- 3448
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3464
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3464
		local last = shared.history[#shared.history] -- 3465
		if last ~= nil then -- 3465
			local result = execRes -- 3467
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3468
			appendToolResultMessage(shared, last) -- 3469
			emitAgentFinishEvent(shared, last) -- 3470
		end -- 3470
		persistHistoryState(shared) -- 3472
		__TS__Await(maybeCompressHistory(shared)) -- 3473
		persistHistoryState(shared) -- 3474
		return ____awaiter_resolve(nil, "main") -- 3474
	end) -- 3474
end -- 3464
local ListFilesAction = __TS__Class() -- 3479
ListFilesAction.name = "ListFilesAction" -- 3479
__TS__ClassExtends(ListFilesAction, Node) -- 3479
function ListFilesAction.prototype.prep(self, shared) -- 3480
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3480
		local last = shared.history[#shared.history] -- 3481
		if not last then -- 3481
			error( -- 3482
				__TS__New(Error, "no history"), -- 3482
				0 -- 3482
			) -- 3482
		end -- 3482
		emitAgentStartEvent(shared, last) -- 3483
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3483
	end) -- 3483
end -- 3480
function ListFilesAction.prototype.exec(self, input) -- 3487
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3487
		local params = input.params -- 3488
		local ____Tools_listFiles_139 = Tools.listFiles -- 3489
		local ____input_workDir_136 = input.workDir -- 3490
		local ____temp_137 = params.path or "" -- 3491
		local ____params_globs_138 = params.globs -- 3492
		local ____math_max_135 = math.max -- 3493
		local ____math_floor_134 = math.floor -- 3493
		local ____params_maxEntries_133 = params.maxEntries -- 3493
		if ____params_maxEntries_133 == nil then -- 3493
			____params_maxEntries_133 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3493
		end -- 3493
		local result = ____Tools_listFiles_139({ -- 3489
			workDir = ____input_workDir_136, -- 3490
			path = ____temp_137, -- 3491
			globs = ____params_globs_138, -- 3492
			maxEntries = ____math_max_135( -- 3493
				1, -- 3493
				____math_floor_134(__TS__Number(____params_maxEntries_133)) -- 3493
			) -- 3493
		}) -- 3493
		return ____awaiter_resolve(nil, result) -- 3493
	end) -- 3493
end -- 3487
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3498
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3498
		local last = shared.history[#shared.history] -- 3499
		if last ~= nil then -- 3499
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3501
			appendToolResultMessage(shared, last) -- 3502
			emitAgentFinishEvent(shared, last) -- 3503
		end -- 3503
		persistHistoryState(shared) -- 3505
		__TS__Await(maybeCompressHistory(shared)) -- 3506
		persistHistoryState(shared) -- 3507
		return ____awaiter_resolve(nil, "main") -- 3507
	end) -- 3507
end -- 3498
local DeleteFileAction = __TS__Class() -- 3512
DeleteFileAction.name = "DeleteFileAction" -- 3512
__TS__ClassExtends(DeleteFileAction, Node) -- 3512
function DeleteFileAction.prototype.prep(self, shared) -- 3513
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3513
		local last = shared.history[#shared.history] -- 3514
		if not last then -- 3514
			error( -- 3515
				__TS__New(Error, "no history"), -- 3515
				0 -- 3515
			) -- 3515
		end -- 3515
		emitAgentStartEvent(shared, last) -- 3516
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3517
		if __TS__StringTrim(targetFile) == "" then -- 3517
			error( -- 3520
				__TS__New(Error, "missing target_file"), -- 3520
				0 -- 3520
			) -- 3520
		end -- 3520
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3520
	end) -- 3520
end -- 3513
function DeleteFileAction.prototype.exec(self, input) -- 3524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3524
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3525
		if not result.success then -- 3525
			return ____awaiter_resolve(nil, result) -- 3525
		end -- 3525
		return ____awaiter_resolve(nil, { -- 3525
			success = true, -- 3533
			changed = true, -- 3534
			mode = "delete", -- 3535
			checkpointId = result.checkpointId, -- 3536
			checkpointSeq = result.checkpointSeq, -- 3537
			files = {{path = input.targetFile, op = "delete"}} -- 3538
		}) -- 3538
	end) -- 3538
end -- 3524
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3542
		local last = shared.history[#shared.history] -- 3543
		if last ~= nil then -- 3543
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3545
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3546
			appendToolResultMessage(shared, last) -- 3547
			emitAgentFinishEvent(shared, last) -- 3548
			local result = last.result -- 3549
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3549
				emitAgentEvent(shared, { -- 3554
					type = "checkpoint_created", -- 3555
					sessionId = shared.sessionId, -- 3556
					taskId = shared.taskId, -- 3557
					step = last.step, -- 3558
					tool = "delete_file", -- 3559
					checkpointId = result.checkpointId, -- 3560
					checkpointSeq = result.checkpointSeq, -- 3561
					files = result.files -- 3562
				}) -- 3562
			end -- 3562
		end -- 3562
		persistHistoryState(shared) -- 3569
		__TS__Await(maybeCompressHistory(shared)) -- 3570
		persistHistoryState(shared) -- 3571
		return ____awaiter_resolve(nil, "main") -- 3571
	end) -- 3571
end -- 3542
local BuildAction = __TS__Class() -- 3576
BuildAction.name = "BuildAction" -- 3576
__TS__ClassExtends(BuildAction, Node) -- 3576
function BuildAction.prototype.prep(self, shared) -- 3577
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3577
		local last = shared.history[#shared.history] -- 3578
		if not last then -- 3578
			error( -- 3579
				__TS__New(Error, "no history"), -- 3579
				0 -- 3579
			) -- 3579
		end -- 3579
		emitAgentStartEvent(shared, last) -- 3580
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3580
	end) -- 3580
end -- 3577
function BuildAction.prototype.exec(self, input) -- 3584
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3584
		local params = input.params -- 3585
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3586
		return ____awaiter_resolve(nil, result) -- 3586
	end) -- 3586
end -- 3584
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3593
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3593
		local last = shared.history[#shared.history] -- 3594
		if last ~= nil then -- 3594
			last.result = sanitizeBuildResultForHistory(execRes) -- 3596
			appendToolResultMessage(shared, last) -- 3597
			emitAgentFinishEvent(shared, last) -- 3598
		end -- 3598
		persistHistoryState(shared) -- 3600
		__TS__Await(maybeCompressHistory(shared)) -- 3601
		persistHistoryState(shared) -- 3602
		return ____awaiter_resolve(nil, "main") -- 3602
	end) -- 3602
end -- 3593
local SpawnSubAgentAction = __TS__Class() -- 3607
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3607
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3607
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3608
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3608
		local last = shared.history[#shared.history] -- 3618
		if not last then -- 3618
			error( -- 3619
				__TS__New(Error, "no history"), -- 3619
				0 -- 3619
			) -- 3619
		end -- 3619
		emitAgentStartEvent(shared, last) -- 3620
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3621
			last.params.filesHint, -- 3622
			function(____, item) return type(item) == "string" end -- 3622
		) or nil -- 3622
		return ____awaiter_resolve( -- 3622
			nil, -- 3622
			{ -- 3624
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3625
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3626
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3627
				filesHint = filesHint, -- 3628
				sessionId = shared.sessionId, -- 3629
				projectRoot = shared.workingDir, -- 3630
				spawnSubAgent = shared.spawnSubAgent, -- 3631
				disabledAgentTools = shared.disabledAgentTools -- 3632
			} -- 3632
		) -- 3632
	end) -- 3632
end -- 3608
function SpawnSubAgentAction.prototype.exec(self, input) -- 3636
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3636
		if not input.spawnSubAgent then -- 3636
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3636
		end -- 3636
		if input.sessionId == nil or input.sessionId <= 0 then -- 3636
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3636
		end -- 3636
		local ____Log_145 = Log -- 3652
		local ____temp_142 = #input.title -- 3652
		local ____temp_143 = #input.prompt -- 3652
		local ____temp_144 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3652
		local ____opt_140 = input.filesHint -- 3652
		____Log_145( -- 3652
			"Info", -- 3652
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_142)) .. " prompt_len=") .. tostring(____temp_143)) .. " expected_len=") .. tostring(____temp_144)) .. " files_hint_count=") .. tostring(____opt_140 and #____opt_140 or 0) -- 3652
		) -- 3652
		local result = __TS__Await(input.spawnSubAgent({ -- 3653
			parentSessionId = input.sessionId, -- 3654
			projectRoot = input.projectRoot, -- 3655
			title = input.title, -- 3656
			prompt = input.prompt, -- 3657
			expectedOutput = input.expectedOutput, -- 3658
			filesHint = input.filesHint, -- 3659
			disabledAgentTools = input.disabledAgentTools -- 3660
		})) -- 3660
		if not result.success then -- 3660
			return ____awaiter_resolve(nil, result) -- 3660
		end -- 3660
		return ____awaiter_resolve(nil, { -- 3660
			success = true, -- 3666
			sessionId = result.sessionId, -- 3667
			taskId = result.taskId, -- 3668
			title = result.title, -- 3669
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3670
		}) -- 3670
	end) -- 3670
end -- 3636
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3674
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3674
		local last = shared.history[#shared.history] -- 3675
		if last ~= nil then -- 3675
			last.result = execRes -- 3677
			if execRes.success == true then -- 3677
				shared.hasSpawnedSubAgentThisTask = true -- 3679
			end -- 3679
			appendToolResultMessage(shared, last) -- 3681
			emitAgentFinishEvent(shared, last) -- 3682
		end -- 3682
		persistHistoryState(shared) -- 3684
		__TS__Await(maybeCompressHistory(shared)) -- 3685
		persistHistoryState(shared) -- 3686
		return ____awaiter_resolve(nil, "main") -- 3686
	end) -- 3686
end -- 3674
local ListSubAgentsAction = __TS__Class() -- 3691
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3691
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3691
function ListSubAgentsAction.prototype.prep(self, shared) -- 3692
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3692
		local last = shared.history[#shared.history] -- 3702
		if not last then -- 3702
			error( -- 3703
				__TS__New(Error, "no history"), -- 3703
				0 -- 3703
			) -- 3703
		end -- 3703
		emitAgentStartEvent(shared, last) -- 3704
		return ____awaiter_resolve( -- 3704
			nil, -- 3704
			{ -- 3705
				sessionId = shared.sessionId, -- 3706
				projectRoot = shared.workingDir, -- 3707
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3708
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3709
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3710
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3711
				listSubAgents = shared.listSubAgents, -- 3712
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3713
			} -- 3713
		) -- 3713
	end) -- 3713
end -- 3692
function ListSubAgentsAction.prototype.exec(self, input) -- 3717
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3717
		if not input.listSubAgents then -- 3717
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3717
		end -- 3717
		if input.sessionId == nil or input.sessionId <= 0 then -- 3717
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3717
		end -- 3717
		local result = __TS__Await(input.listSubAgents({ -- 3733
			sessionId = input.sessionId, -- 3734
			projectRoot = input.projectRoot, -- 3735
			status = input.status, -- 3736
			limit = input.limit, -- 3737
			offset = input.offset, -- 3738
			query = input.query -- 3739
		})) -- 3739
		return ____awaiter_resolve( -- 3739
			nil, -- 3739
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3741
		) -- 3741
	end) -- 3741
end -- 3717
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3749
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3749
		local last = shared.history[#shared.history] -- 3750
		if last ~= nil then -- 3750
			last.result = execRes -- 3752
			appendToolResultMessage(shared, last) -- 3753
			emitAgentFinishEvent(shared, last) -- 3754
		end -- 3754
		persistHistoryState(shared) -- 3756
		__TS__Await(maybeCompressHistory(shared)) -- 3757
		persistHistoryState(shared) -- 3758
		return ____awaiter_resolve(nil, "main") -- 3758
	end) -- 3758
end -- 3749
EditFileAction = __TS__Class() -- 3763
EditFileAction.name = "EditFileAction" -- 3763
__TS__ClassExtends(EditFileAction, Node) -- 3763
function EditFileAction.prototype.prep(self, shared) -- 3764
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3764
		local last = shared.history[#shared.history] -- 3765
		if not last then -- 3765
			error( -- 3766
				__TS__New(Error, "no history"), -- 3766
				0 -- 3766
			) -- 3766
		end -- 3766
		emitAgentStartEvent(shared, last) -- 3767
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3768
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3771
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3772
		if __TS__StringTrim(path) == "" then -- 3772
			error( -- 3773
				__TS__New(Error, "missing path"), -- 3773
				0 -- 3773
			) -- 3773
		end -- 3773
		return ____awaiter_resolve(nil, { -- 3773
			path = path, -- 3774
			oldStr = oldStr, -- 3774
			newStr = newStr, -- 3774
			taskId = shared.taskId, -- 3774
			workDir = shared.workingDir -- 3774
		}) -- 3774
	end) -- 3774
end -- 3764
function EditFileAction.prototype.exec(self, input) -- 3777
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3777
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3778
		if not readRes.success then -- 3778
			if input.oldStr ~= "" then -- 3778
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3778
			end -- 3778
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3783
			if not createRes.success then -- 3783
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3783
			end -- 3783
			return ____awaiter_resolve( -- 3783
				nil, -- 3783
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3790
					success = true, -- 3791
					changed = true, -- 3792
					mode = "create", -- 3793
					checkpointId = createRes.checkpointId, -- 3794
					checkpointSeq = createRes.checkpointSeq, -- 3795
					files = {{path = input.path, op = "create"}} -- 3796
				}) -- 3796
			) -- 3796
		end -- 3796
		if input.oldStr == "" then -- 3796
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3796
				return ____awaiter_resolve( -- 3796
					nil, -- 3796
					{ -- 3801
						success = false, -- 3802
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3803
						actualSaved = false, -- 3804
						actualSavedCharacters = 0, -- 3805
						currentFileExists = true, -- 3806
						currentCharacters = #readRes.content, -- 3807
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3808
					} -- 3808
				) -- 3808
			end -- 3808
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3811
			if not overwriteRes.success then -- 3811
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3811
			end -- 3811
			return ____awaiter_resolve( -- 3811
				nil, -- 3811
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3818
					success = true, -- 3819
					changed = true, -- 3820
					mode = "overwrite", -- 3821
					checkpointId = overwriteRes.checkpointId, -- 3822
					checkpointSeq = overwriteRes.checkpointSeq, -- 3823
					files = {{path = input.path, op = "write"}} -- 3824
				}) -- 3824
			) -- 3824
		end -- 3824
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3829
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3830
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3831
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3834
		if occurrences == 0 then -- 3834
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3836
			if not indentTolerant.success then -- 3836
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3836
			end -- 3836
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3840
			if not applyRes.success then -- 3840
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3840
			end -- 3840
			return ____awaiter_resolve( -- 3840
				nil, -- 3840
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3847
					success = true, -- 3848
					changed = true, -- 3849
					mode = "replace_indent_tolerant", -- 3850
					checkpointId = applyRes.checkpointId, -- 3851
					checkpointSeq = applyRes.checkpointSeq, -- 3852
					files = {{path = input.path, op = "write"}} -- 3853
				}) -- 3853
			) -- 3853
		end -- 3853
		if occurrences > 1 then -- 3853
			return ____awaiter_resolve( -- 3853
				nil, -- 3853
				{ -- 3857
					success = false, -- 3857
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3857
				} -- 3857
			) -- 3857
		end -- 3857
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3861
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3862
		if not applyRes.success then -- 3862
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3862
		end -- 3862
		return ____awaiter_resolve( -- 3862
			nil, -- 3862
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3869
				success = true, -- 3870
				changed = true, -- 3871
				mode = "replace", -- 3872
				checkpointId = applyRes.checkpointId, -- 3873
				checkpointSeq = applyRes.checkpointSeq, -- 3874
				files = {{path = input.path, op = "write"}} -- 3875
			}) -- 3875
		) -- 3875
	end) -- 3875
end -- 3777
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3879
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3879
		local last = shared.history[#shared.history] -- 3880
		if last ~= nil then -- 3880
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3882
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3883
			appendToolResultMessage(shared, last) -- 3884
			emitAgentFinishEvent(shared, last) -- 3885
			local result = last.result -- 3886
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3886
				emitAgentEvent(shared, { -- 3891
					type = "checkpoint_created", -- 3892
					sessionId = shared.sessionId, -- 3893
					taskId = shared.taskId, -- 3894
					step = last.step, -- 3895
					tool = last.tool, -- 3896
					checkpointId = result.checkpointId, -- 3897
					checkpointSeq = result.checkpointSeq, -- 3898
					files = result.files -- 3899
				}) -- 3899
			end -- 3899
		end -- 3899
		persistHistoryState(shared) -- 3906
		__TS__Await(maybeCompressHistory(shared)) -- 3907
		persistHistoryState(shared) -- 3908
		return ____awaiter_resolve(nil, "main") -- 3908
	end) -- 3908
end -- 3879
local FetchUrlAction = __TS__Class() -- 3913
FetchUrlAction.name = "FetchUrlAction" -- 3913
__TS__ClassExtends(FetchUrlAction, Node) -- 3913
function FetchUrlAction.prototype.prep(self, shared) -- 3914
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3914
		local last = shared.history[#shared.history] -- 3915
		if not last then -- 3915
			error( -- 3916
				__TS__New(Error, "no history"), -- 3916
				0 -- 3916
			) -- 3916
		end -- 3916
		emitAgentStartEvent(shared, last) -- 3917
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3917
	end) -- 3917
end -- 3914
function FetchUrlAction.prototype.exec(self, input) -- 3921
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3921
		return ____awaiter_resolve( -- 3921
			nil, -- 3921
			executeToolAction(input.shared, input.action) -- 3922
		) -- 3922
	end) -- 3922
end -- 3921
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3925
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3925
		local last = shared.history[#shared.history] -- 3926
		if last ~= nil then -- 3926
			last.result = execRes -- 3928
			appendToolResultMessage(shared, last) -- 3929
			emitAgentFinishEvent(shared, last) -- 3930
		end -- 3930
		persistHistoryState(shared) -- 3932
		__TS__Await(maybeCompressHistory(shared)) -- 3933
		persistHistoryState(shared) -- 3934
		return ____awaiter_resolve(nil, "main") -- 3934
	end) -- 3934
end -- 3925
local function emitCheckpointEventForAction(shared, action) -- 3939
	local result = action.result -- 3940
	if not result then -- 3940
		return -- 3941
	end -- 3941
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3941
		emitAgentEvent(shared, { -- 3946
			type = "checkpoint_created", -- 3947
			sessionId = shared.sessionId, -- 3948
			taskId = shared.taskId, -- 3949
			step = action.step, -- 3950
			tool = action.tool, -- 3951
			checkpointId = result.checkpointId, -- 3952
			checkpointSeq = result.checkpointSeq, -- 3953
			files = result.files -- 3954
		}) -- 3954
	end -- 3954
end -- 3939
local function canRunBatchActionInParallel(self, action) -- 4486
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4487
end -- 4486
local function partitionToolCalls(actions) -- 4495
	local batches = {} -- 4496
	do -- 4496
		local i = 0 -- 4497
		while i < #actions do -- 4497
			local action = actions[i + 1] -- 4498
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4499
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4500
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4500
				local ____lastBatch_actions_178 = lastBatch.actions -- 4500
				____lastBatch_actions_178[#____lastBatch_actions_178 + 1] = action -- 4502
			else -- 4502
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4504
			end -- 4504
			i = i + 1 -- 4497
		end -- 4497
	end -- 4497
	return batches -- 4507
end -- 4495
local function completeStoppedToolAction(shared, action) -- 4510
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4511
	if not action.result then -- 4511
		action.result = { -- 4513
			success = false, -- 4513
			message = getCancelledReason(shared) -- 4513
		} -- 4513
	end -- 4513
	appendToolResultMessage(shared, action) -- 4515
	emitAgentFinishEvent(shared, action) -- 4516
	emitCheckpointEventForAction(shared, action) -- 4517
end -- 4510
local BatchToolAction = __TS__Class() -- 4520
BatchToolAction.name = "BatchToolAction" -- 4520
__TS__ClassExtends(BatchToolAction, Node) -- 4520
function BatchToolAction.prototype.prep(self, shared) -- 4521
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4521
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4521
	end) -- 4521
end -- 4521
function BatchToolAction.prototype.exec(self, input) -- 4525
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4525
		local shared = input.shared -- 4526
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4527
		local preExecuted = shared.preExecutedResults -- 4528
		local batches = partitionToolCalls(input.actions) -- 4529
		local parallelBatchCount = #__TS__ArrayFilter( -- 4530
			batches, -- 4530
			function(____, b) return b.isConcurrencySafe end -- 4530
		) -- 4530
		local serialBatchCount = #__TS__ArrayFilter( -- 4531
			batches, -- 4531
			function(____, b) return not b.isConcurrencySafe end -- 4531
		) -- 4531
		Log( -- 4532
			"Info", -- 4532
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4532
		) -- 4532
		do -- 4532
			local batchIdx = 0 -- 4534
			while batchIdx < #batches do -- 4534
				do -- 4534
					local batch = batches[batchIdx + 1] -- 4535
					if shared.stopToken.stopped then -- 4535
						for ____, action in ipairs(batch.actions) do -- 4537
							completeStoppedToolAction(shared, action) -- 4538
						end -- 4538
						goto __continue751 -- 4540
					end -- 4540
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4540
						local preExecCount = #__TS__ArrayFilter( -- 4544
							batch.actions, -- 4544
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4544
						) -- 4544
						Log( -- 4545
							"Info", -- 4545
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4545
						) -- 4545
						do -- 4545
							local i = 0 -- 4546
							while i < #batch.actions do -- 4546
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4547
								i = i + 1 -- 4546
							end -- 4546
						end -- 4546
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4549
							batch.actions, -- 4549
							function(____, action) -- 4549
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4549
									if shared.stopToken.stopped then -- 4549
										action.result = { -- 4551
											success = false, -- 4551
											message = getCancelledReason(shared) -- 4551
										} -- 4551
										return ____awaiter_resolve(nil, action) -- 4551
									end -- 4551
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4554
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4555
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4556
									return ____awaiter_resolve(nil, action) -- 4556
								end) -- 4556
							end -- 4549
						))) -- 4549
						do -- 4549
							local i = 0 -- 4559
							while i < #batch.actions do -- 4559
								local action = batch.actions[i + 1] -- 4560
								if not action.result then -- 4560
									action.result = {success = false, message = "tool did not produce a result"} -- 4562
								end -- 4562
								appendToolResultMessage(shared, action) -- 4564
								emitAgentFinishEvent(shared, action) -- 4565
								emitCheckpointEventForAction(shared, action) -- 4566
								i = i + 1 -- 4559
							end -- 4559
						end -- 4559
					else -- 4559
						Log( -- 4569
							"Info", -- 4569
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4569
						) -- 4569
						do -- 4569
							local i = 0 -- 4570
							while i < #batch.actions do -- 4570
								local action = batch.actions[i + 1] -- 4571
								emitAgentStartEvent(shared, action) -- 4572
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4573
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4574
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4575
								appendToolResultMessage(shared, action) -- 4576
								emitAgentFinishEvent(shared, action) -- 4577
								emitCheckpointEventForAction(shared, action) -- 4578
								persistHistoryState(shared) -- 4579
								if shared.stopToken.stopped then -- 4579
									do -- 4579
										local j = i + 1 -- 4581
										while j < #batch.actions do -- 4581
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4582
											j = j + 1 -- 4581
										end -- 4581
									end -- 4581
									break -- 4584
								end -- 4584
								i = i + 1 -- 4570
							end -- 4570
						end -- 4570
					end -- 4570
				end -- 4570
				::__continue751:: -- 4570
				batchIdx = batchIdx + 1 -- 4534
			end -- 4534
		end -- 4534
		local spawnSeen = spawnedBeforeBatch -- 4589
		local didDelegatedForegroundWork = false -- 4590
		do -- 4590
			local i = 0 -- 4591
			while i < #input.actions do -- 4591
				do -- 4591
					local action = input.actions[i + 1] -- 4592
					if action.tool == "spawn_sub_agent" then -- 4592
						local ____opt_181 = action.result -- 4592
						if (____opt_181 and ____opt_181.success) == true then -- 4592
							spawnSeen = true -- 4594
						end -- 4594
						goto __continue771 -- 4595
					end -- 4595
					if spawnSeen and action.tool ~= "finish" then -- 4595
						didDelegatedForegroundWork = true -- 4598
					end -- 4598
				end -- 4598
				::__continue771:: -- 4598
				i = i + 1 -- 4591
			end -- 4591
		end -- 4591
		if didDelegatedForegroundWork then -- 4591
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4602
		end -- 4602
		persistHistoryState(shared) -- 4604
		return ____awaiter_resolve(nil, input.actions) -- 4604
	end) -- 4604
end -- 4525
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4608
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4608
		shared.pendingToolActions = nil -- 4609
		shared.preExecutedResults = nil -- 4610
		persistHistoryState(shared) -- 4611
		__TS__Await(maybeCompressHistory(shared)) -- 4612
		persistHistoryState(shared) -- 4613
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4613
	end) -- 4613
end -- 4608
local EndNode = __TS__Class() -- 4618
EndNode.name = "EndNode" -- 4618
__TS__ClassExtends(EndNode, Node) -- 4618
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4619
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4619
		return ____awaiter_resolve(nil, nil) -- 4619
	end) -- 4619
end -- 4619
local CodingAgentFlow = __TS__Class() -- 4624
CodingAgentFlow.name = "CodingAgentFlow" -- 4624
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4624
function CodingAgentFlow.prototype.____constructor(self, role) -- 4625
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4626
	local read = __TS__New(ReadFileAction, 1, 0) -- 4627
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4628
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4629
	local list = __TS__New(ListFilesAction, 1, 0) -- 4630
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4631
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4632
	local build = __TS__New(BuildAction, 1, 0) -- 4633
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4634
	local edit = __TS__New(EditFileAction, 1, 0) -- 4635
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4636
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4637
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4638
	local done = __TS__New(EndNode, 1, 0) -- 4639
	main:on("batch_tools", batch) -- 4641
	main:on("grep_files", search) -- 4642
	main:on("search_dora_api", searchDora) -- 4643
	main:on("glob_files", list) -- 4644
	main:on("fetch_url", fetch) -- 4645
	main:on("execute_command", exec) -- 4646
	if role == "main" then -- 4646
		main:on("read_file", read) -- 4648
		main:on("delete_file", del) -- 4649
		main:on("build", build) -- 4650
		main:on("edit_file", edit) -- 4651
		main:on("list_sub_agents", listSub) -- 4652
		main:on("spawn_sub_agent", spawn) -- 4653
	else -- 4653
		main:on("read_file", read) -- 4655
		main:on("delete_file", del) -- 4656
		main:on("build", build) -- 4657
		main:on("edit_file", edit) -- 4658
	end -- 4658
	main:on("done", done) -- 4660
	search:on("main", main) -- 4662
	searchDora:on("main", main) -- 4663
	list:on("main", main) -- 4664
	listSub:on("main", main) -- 4665
	spawn:on("main", main) -- 4666
	batch:on("main", main) -- 4667
	batch:on("done", done) -- 4668
	read:on("main", main) -- 4669
	del:on("main", main) -- 4670
	build:on("main", main) -- 4671
	edit:on("main", main) -- 4672
	fetch:on("main", main) -- 4673
	exec:on("main", main) -- 4674
	Flow.prototype.____constructor(self, main) -- 4676
end -- 4625
local function runCodingAgentAsync(options) -- 4712
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4712
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4712
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4712
		end -- 4712
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4716
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4717
		if not llmConfigRes.success then -- 4717
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4717
		end -- 4717
		local llmConfig = llmConfigRes.config -- 4723
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4724
		if not taskRes.success then -- 4724
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4724
		end -- 4724
		local compressor = __TS__New(MemoryCompressor, { -- 4731
			compressionThreshold = 0.8, -- 4732
			compressionTargetThreshold = 0.5, -- 4733
			maxCompressionRounds = 3, -- 4734
			projectDir = options.workDir, -- 4735
			llmConfig = llmConfig, -- 4736
			promptPack = options.promptPack, -- 4737
			scope = options.memoryScope -- 4738
		}) -- 4738
		local persistedSession = compressor:getStorage():readSessionState() -- 4740
		local effectiveUserQuery = normalizedPrompt -- 4741
		if options.resumeConversation == true then -- 4741
			do -- 4741
				local i = #persistedSession.messages - 1 -- 4743
				while i >= 0 do -- 4743
					local message = persistedSession.messages[i + 1] -- 4744
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4744
						effectiveUserQuery = message.content -- 4746
						break -- 4747
					end -- 4747
					i = i - 1 -- 4743
				end -- 4743
			end -- 4743
		end -- 4743
		local promptPack = compressor:getPromptPack() -- 4751
		local freshProject = inspectFreshProject(options.workDir) -- 4752
		local freshProjectBuildPending = freshProject.fresh -- 4753
		local freshProjectCodeFile = freshProject.codeFile -- 4754
		local shared = { -- 4756
			sessionId = options.sessionId, -- 4757
			taskId = taskRes.taskId, -- 4758
			role = options.role or "main", -- 4759
			maxSteps = math.max( -- 4760
				1, -- 4760
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4760
			), -- 4760
			llmMaxTry = math.max( -- 4761
				1, -- 4761
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4761
			), -- 4761
			step = 0, -- 4762
			done = false, -- 4763
			stopToken = options.stopToken or ({stopped = false}), -- 4764
			response = "", -- 4765
			userQuery = effectiveUserQuery, -- 4766
			workingDir = options.workDir, -- 4767
			useChineseResponse = options.useChineseResponse == true, -- 4768
			workMode = options.workMode or "code", -- 4769
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4770
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4773
			llmConfig = llmConfig, -- 4774
			onEvent = options.onEvent, -- 4775
			promptPack = promptPack, -- 4776
			history = {}, -- 4777
			messages = persistedSession.messages, -- 4778
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4779
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4780
			memory = {compressor = compressor}, -- 4782
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4786
				projectDir = options.workDir, -- 4788
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4789
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4790
			})}, -- 4790
			spawnSubAgent = options.spawnSubAgent, -- 4796
			listSubAgents = options.listSubAgents, -- 4797
			publishQuestionnaire = options.publishQuestionnaire, -- 4798
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4799
			freshProjectBuildPending = freshProjectBuildPending, -- 4800
			freshProjectCodeFile = freshProjectCodeFile, -- 4801
			hasSpawnedSubAgentThisTask = false, -- 4802
			delegatedForegroundBatches = 0 -- 4803
		} -- 4803
		local ____hasReturned, ____returnValue -- 4803
		local ____try = __TS__AsyncAwaiter(function() -- 4803
			if shared.workMode == "plan" then -- 4803
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4808
				if not planDocuments.success then -- 4808
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4810
					____hasReturned = true -- 4811
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4811
					return -- 4811
				end -- 4811
			end -- 4811
			emitAgentEvent(shared, { -- 4814
				type = "task_started", -- 4815
				sessionId = shared.sessionId, -- 4816
				taskId = shared.taskId, -- 4817
				prompt = shared.userQuery, -- 4818
				workDir = shared.workingDir, -- 4819
				maxSteps = shared.maxSteps -- 4820
			}) -- 4820
			if shared.stopToken.stopped then -- 4820
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4823
				____hasReturned = true -- 4824
				____returnValue = emitAgentTaskFinishEvent( -- 4824
					shared, -- 4824
					false, -- 4824
					getCancelledReason(shared) -- 4824
				) -- 4824
				return -- 4824
			end -- 4824
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4826
			local ____temp_183 -- 4827
			if options.resumeConversation == true then -- 4827
				____temp_183 = nil -- 4827
			else -- 4827
				____temp_183 = getPromptCommand(shared.userQuery) -- 4827
			end -- 4827
			local promptCommand = ____temp_183 -- 4827
			if promptCommand == "clear" then -- 4827
				____hasReturned = true -- 4829
				____returnValue = clearSessionHistory(shared) -- 4829
				return -- 4829
			end -- 4829
			if promptCommand == "compact" then -- 4829
				if shared.role == "sub" then -- 4829
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4833
					____hasReturned = true -- 4834
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4834
					return -- 4834
				end -- 4834
				____hasReturned = true -- 4842
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4842
				return -- 4842
			end -- 4842
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4844
			if shared.stopToken.stopped then -- 4844
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4846
				____hasReturned = true -- 4847
				____returnValue = emitAgentTaskFinishEvent( -- 4847
					shared, -- 4847
					false, -- 4847
					getCancelledReason(shared) -- 4847
				) -- 4847
				return -- 4847
			end -- 4847
			if options.resumeConversation ~= true then -- 4847
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4850
				persistHistoryState(shared) -- 4854
			end -- 4854
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4856
			__TS__Await(flow:run(shared)) -- 4857
			if shared.stopToken.stopped then -- 4857
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4859
				____hasReturned = true -- 4860
				____returnValue = emitAgentTaskFinishEvent( -- 4860
					shared, -- 4860
					false, -- 4860
					getCancelledReason(shared) -- 4860
				) -- 4860
				return -- 4860
			end -- 4860
			if shared.error then -- 4860
				____hasReturned = true -- 4863
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4863
				return -- 4863
			end -- 4863
			if shared.waitingQuestionnaireId ~= nil then -- 4863
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4867
				emitAgentEvent(shared, { -- 4868
					type = "task_waiting_for_user", -- 4869
					sessionId = shared.sessionId, -- 4870
					taskId = shared.taskId, -- 4871
					step = shared.step, -- 4872
					questionnaireId = shared.waitingQuestionnaireId -- 4873
				}) -- 4873
				____hasReturned = true -- 4875
				____returnValue = { -- 4875
					success = true, -- 4876
					taskId = shared.taskId, -- 4877
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4878
					steps = shared.step, -- 4879
					waitingForUser = true, -- 4880
					questionnaireId = shared.waitingQuestionnaireId -- 4881
				} -- 4881
				return -- 4875
			end -- 4875
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4884
			____hasReturned = true -- 4885
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4885
			return -- 4885
		end) -- 4885
		____try = ____try.catch( -- 4885
			____try, -- 4885
			function(____, e) -- 4885
				return __TS__AsyncAwaiter(function() -- 4885
					____hasReturned = true -- 4888
					____returnValue = finalizeAgentFailure( -- 4888
						shared, -- 4888
						tostring(e) -- 4888
					) -- 4888
					return -- 4888
				end) -- 4888
			end -- 4888
		) -- 4888
		__TS__Await(____try) -- 4806
		if ____hasReturned then -- 4806
			return ____awaiter_resolve(nil, ____returnValue) -- 4806
		end -- 4806
	end) -- 4806
end -- 4712
function ____exports.runCodingAgent(options, callback) -- 4892
	local ____self_184 = runCodingAgentAsync(options) -- 4892
	____self_184["then"]( -- 4892
		____self_184, -- 4892
		function(____, result) return callback(result) end -- 4893
	) -- 4893
end -- 4892
return ____exports -- 4892