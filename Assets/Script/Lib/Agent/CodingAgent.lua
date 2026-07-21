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
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
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
local isRecord, isArray, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, isToolAllowedForRole, getFinishMessage, normalizeCompletionText, normalizeCompletionTextList, getCompletionReport, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, ensureToolCallId, hasXMLParam, inferToolNameFromXMLParams, parseDSMLAttribute, extractDSMLReason, parseDSMLToolCallObjectFromText, parseXMLToolCallObjectFromText, parseDecisionObject, getDecisionPath, validateDecisionForShared, clampIntegerParam, parseReadLineParam, validateDecision, validateCompletionForRole, buildAgentSystemPrompt, buildSkillsSection, isFinalDecisionTurn, buildXmlDecisionInstruction, tryParseAndValidateDecision, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, COMPLETION_TEXT_MAX_CHARS, COMPLETION_LIST_MAX_ITEMS, COMPLETION_EVIDENCE_MAX_ITEMS, EditFileAction -- 1
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
function getReplyLanguageDirective(shared) -- 890
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 891
end -- 891
function replacePromptVars(template, vars) -- 896
	local output = template -- 897
	for key in pairs(vars) do -- 898
		output = table.concat( -- 899
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 899
			vars[key] or "" or "," -- 899
		) -- 899
	end -- 899
	return output -- 901
end -- 901
function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 904
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 920
	local contentLines = __TS__StringSplit(content, "\n") -- 921
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 922
	if #content <= maxChars and availableSourceLines <= maxLines then -- 922
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 924
	end -- 924
	local contentBudget = math.max(0, maxChars - 240) -- 935
	local candidateLines = math.min(availableSourceLines, maxLines) -- 936
	local retainedLines = {} -- 937
	local retainedChars = 0 -- 938
	do -- 938
		local i = 0 -- 939
		while i < candidateLines do -- 939
			local line = contentLines[i + 1] -- 940
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 941
			if nextChars > contentBudget then -- 941
				break -- 942
			end -- 942
			retainedLines[#retainedLines + 1] = line -- 943
			retainedChars = nextChars -- 944
			i = i + 1 -- 939
		end -- 939
	end -- 939
	local retainedEndLine = startLine + #retainedLines - 1 -- 947
	local partialLine -- 948
	local retainedContent = table.concat(retainedLines, "\n") -- 949
	if #retainedLines == 0 and candidateLines > 0 then -- 949
		partialLine = startLine -- 951
		retainedEndLine = startLine - 1 -- 952
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 953
	end -- 953
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 955
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 956
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 961
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 964
	return { -- 965
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 966
		truncated = true, -- 967
		retainedStartLine = startLine, -- 968
		retainedEndLine = retainedEndLine, -- 969
		nextStartLine = nextStartLine, -- 970
		partialLine = partialLine -- 971
	} -- 971
end -- 971
function sanitizeReadResultForHistory(tool, result) -- 987
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 987
		return result -- 989
	end -- 989
	local clone = {} -- 991
	for key in pairs(result) do -- 992
		clone[key] = result[key] -- 993
	end -- 993
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 995
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 996
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 997
	local limited = limitReadContentForHistory( -- 998
		result.content, -- 999
		startLine, -- 1000
		endLine, -- 1001
		totalLines, -- 1002
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 1003
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 1004
		"read_file history" -- 1005
	) -- 1005
	clone.content = limited.content -- 1007
	if limited.truncated then -- 1007
		clone.historyContentTruncated = true -- 1009
		clone.historyRetainedStartLine = limited.retainedStartLine -- 1010
		clone.historyRetainedEndLine = limited.retainedEndLine -- 1011
		if limited.nextStartLine ~= nil then -- 1011
			clone.historyNextStartLine = limited.nextStartLine -- 1012
		end -- 1012
		if limited.partialLine ~= nil then -- 1012
			clone.historyPartialLine = limited.partialLine -- 1013
		end -- 1013
	end -- 1013
	return clone -- 1015
end -- 1015
function sanitizeSearchMatchesForHistory(items, maxItems) -- 1018
	local shown = math.min(#items, maxItems) -- 1022
	local out = {} -- 1023
	do -- 1023
		local i = 0 -- 1024
		while i < shown do -- 1024
			local row = items[i + 1] -- 1025
			out[#out + 1] = { -- 1026
				file = row.file, -- 1027
				line = row.line, -- 1028
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1029
			} -- 1029
			i = i + 1 -- 1024
		end -- 1024
	end -- 1024
	return out -- 1034
end -- 1034
function sanitizeSearchResultForHistory(tool, result) -- 1037
	if result.success ~= true or not isArray(result.results) then -- 1037
		return result -- 1041
	end -- 1041
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1041
		return result -- 1042
	end -- 1042
	local clone = {} -- 1043
	for key in pairs(result) do -- 1044
		clone[key] = result[key] -- 1045
	end -- 1045
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 1047
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1048
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1048
		local grouped = result.groupedResults -- 1053
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 1054
		local sanitizedGroups = {} -- 1055
		do -- 1055
			local i = 0 -- 1056
			while i < shown do -- 1056
				local row = grouped[i + 1] -- 1057
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1058
					file = row.file, -- 1059
					totalMatches = row.totalMatches, -- 1060
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1061
				} -- 1061
				i = i + 1 -- 1056
			end -- 1056
		end -- 1056
		clone.groupedResults = sanitizedGroups -- 1066
	end -- 1066
	return clone -- 1068
end -- 1068
function sanitizeListFilesResultForHistory(result) -- 1071
	if result.success ~= true or not isArray(result.files) then -- 1071
		return result -- 1072
	end -- 1072
	local clone = {} -- 1073
	for key in pairs(result) do -- 1074
		clone[key] = result[key] -- 1075
	end -- 1075
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 1077
	return clone -- 1078
end -- 1078
function sanitizeBuildResultForHistory(result) -- 1081
	if not isArray(result.messages) then -- 1081
		return result -- 1082
	end -- 1082
	local clone = {} -- 1083
	for key in pairs(result) do -- 1084
		clone[key] = result[key] -- 1085
	end -- 1085
	local messages = result.messages -- 1087
	local ordered = __TS__ArraySort( -- 1088
		__TS__ArraySlice(messages), -- 1088
		function(____, a, b) -- 1088
			local aFailed = a.success ~= true -- 1089
			local bFailed = b.success ~= true -- 1090
			if aFailed == bFailed then -- 1090
				return 0 -- 1091
			end -- 1091
			return aFailed and -1 or 1 -- 1092
		end -- 1088
	) -- 1088
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1094
	local sanitized = {} -- 1095
	do -- 1095
		local i = 0 -- 1096
		while i < shown do -- 1096
			local item = ordered[i + 1] -- 1097
			local next = {} -- 1098
			for key in pairs(item) do -- 1099
				local value = item[key] -- 1100
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1101
			end -- 1101
			sanitized[#sanitized + 1] = next -- 1105
			i = i + 1 -- 1096
		end -- 1096
	end -- 1096
	clone.messages = sanitized -- 1107
	if #ordered > shown then -- 1107
		clone.truncatedMessages = #ordered - shown -- 1109
	end -- 1109
	return clone -- 1111
end -- 1111
function ____exports.getDecisionDisabledAgentTools(shared) -- 1303
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1307
end -- 1303
function getDecisionToolDefinitions(shared) -- 1310
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1311
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1312
	local base = shared.promptPack.toolDefinitionsDetailed -- 1315
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1316
	if usesDefaultToolPrompts then -- 1316
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1319
			shared.role, -- 1319
			{ -- 1319
				includeFinish = true, -- 1320
				includeXmlRules = true, -- 1321
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1322
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1323
				workMode = shared.workMode -- 1324
			} -- 1324
		) -- 1324
		return replacePromptVars(definitions, params) -- 1326
	end -- 1326
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1328
	if (shared and shared.decisionMode) ~= "xml" then -- 1328
		return withRole -- 1333
	end -- 1333
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1335
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1336
end -- 1336
function isToolAllowedForRole(shared, tool) -- 1350
	return __TS__ArrayIndexOf( -- 1351
		AgentToolRegistry.getAllowedToolsForRole( -- 1351
			shared.role, -- 1351
			{ -- 1351
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1352
				workMode = shared.workMode -- 1353
			} -- 1353
		), -- 1353
		tool -- 1354
	) >= 0 -- 1354
end -- 1354
function getFinishMessage(params, fallback) -- 1770
	if fallback == nil then -- 1770
		fallback = "" -- 1770
	end -- 1770
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1770
		return __TS__StringTrim(params.message) -- 1772
	end -- 1772
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1772
		return __TS__StringTrim(params.response) -- 1775
	end -- 1775
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1775
		return __TS__StringTrim(params.summary) -- 1778
	end -- 1778
	return __TS__StringTrim(fallback) -- 1780
end -- 1780
function normalizeCompletionText(value) -- 1787
	if type(value) ~= "string" then -- 1787
		return "" -- 1788
	end -- 1788
	return __TS__StringSlice( -- 1789
		__TS__StringTrim(sanitizeUTF8(value)), -- 1789
		0, -- 1789
		COMPLETION_TEXT_MAX_CHARS -- 1789
	) -- 1789
end -- 1789
function normalizeCompletionTextList(value, maxItems) -- 1792
	if maxItems == nil then -- 1792
		maxItems = COMPLETION_LIST_MAX_ITEMS -- 1792
	end -- 1792
	if not isArray(value) then -- 1792
		return {} -- 1793
	end -- 1793
	local items = {} -- 1794
	do -- 1794
		local i = 0 -- 1795
		while i < #value and #items < maxItems do -- 1795
			local item = normalizeCompletionText(value[i + 1]) -- 1796
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 1796
				items[#items + 1] = item -- 1797
			end -- 1797
			i = i + 1 -- 1795
		end -- 1795
	end -- 1795
	return items -- 1799
end -- 1799
function ____exports.normalizeAgentCompletionReport(value) -- 1802
	local row = value and not isArray(value) and isRecord(value) and value or ({}) -- 1803
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 1804
	local validation = {} -- 1807
	if isArray(row.validation) then -- 1807
		do -- 1807
			local i = 0 -- 1809
			while i < #row.validation and #validation < COMPLETION_LIST_MAX_ITEMS do -- 1809
				do -- 1809
					local raw = row.validation[i + 1] -- 1810
					if not raw or isArray(raw) or not isRecord(raw) then -- 1810
						goto __continue286 -- 1811
					end -- 1811
					local kind = (raw.kind == "runtime" or raw.kind == "manual") and raw.kind or (raw.kind == "build" and "build" or nil) -- 1812
					local result = (raw.result == "passed" or raw.result == "failed" or raw.result == "not_run") and raw.result or nil -- 1813
					if kind == nil or result == nil then -- 1813
						goto __continue286 -- 1814
					end -- 1814
					validation[#validation + 1] = { -- 1815
						kind = kind, -- 1816
						result = result, -- 1817
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS) -- 1818
					} -- 1818
				end -- 1818
				::__continue286:: -- 1818
				i = i + 1 -- 1809
			end -- 1809
		end -- 1809
	end -- 1809
	local learningCandidates = {} -- 1822
	if isArray(row.learningCandidates) then -- 1822
		do -- 1822
			local i = 0 -- 1824
			while i < #row.learningCandidates and #learningCandidates < COMPLETION_LIST_MAX_ITEMS do -- 1824
				do -- 1824
					local raw = row.learningCandidates[i + 1] -- 1825
					if not raw or isArray(raw) or not isRecord(raw) then -- 1825
						goto __continue291 -- 1826
					end -- 1826
					local claim = normalizeCompletionText(raw.claim) -- 1827
					if claim == "" then -- 1827
						goto __continue291 -- 1828
					end -- 1828
					learningCandidates[#learningCandidates + 1] = { -- 1829
						claim = claim, -- 1830
						scope = (raw.scope == "file" or raw.scope == "engine") and raw.scope or "project", -- 1831
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS), -- 1832
						confidence = raw.confidence == "inferred" and "inferred" or "observed" -- 1833
					} -- 1833
				end -- 1833
				::__continue291:: -- 1833
				i = i + 1 -- 1824
			end -- 1824
		end -- 1824
	end -- 1824
	return { -- 1837
		outcome = outcome, -- 1838
		validation = validation, -- 1839
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 1840
		assumptions = normalizeCompletionTextList(row.assumptions), -- 1841
		learningCandidates = learningCandidates -- 1842
	} -- 1842
end -- 1802
function getCompletionReport(params) -- 1846
	return ____exports.normalizeAgentCompletionReport(params) -- 1847
end -- 1847
function persistHistoryState(shared) -- 1850
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1851
end -- 1851
function getActiveConversationMessages(shared) -- 1858
	local activeMessages = {} -- 1859
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1859
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1866
	end -- 1866
	do -- 1866
		local i = shared.lastConsolidatedIndex -- 1870
		while i < #shared.messages do -- 1870
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1871
			i = i + 1 -- 1870
		end -- 1870
	end -- 1870
	return activeMessages -- 1873
end -- 1873
function getActiveRealMessageCount(shared) -- 1876
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1877
end -- 1877
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1880
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1886
	local previousActiveStart = shared.lastConsolidatedIndex -- 1887
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1888
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1889
	if type(carryMessageIndex) == "number" then -- 1889
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1889
		else -- 1889
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1897
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1900
		end -- 1900
	else -- 1900
		shared.carryMessageIndex = nil -- 1905
	end -- 1905
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1905
		shared.carryMessageIndex = nil -- 1915
	end -- 1915
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1923
	shared.resumeCheckpointPending = true -- 1924
	shared.resumeRequiredTool = nil -- 1925
	shared.resumeNarrowReadMode = true -- 1926
	if shared.unbuiltEdits == true then -- 1926
		shared.resumeRequiredTool = "build" -- 1934
	end -- 1934
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1943
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1943
		local marker = "**Next tool**:" -- 1954
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1955
		if markerIndex >= 0 then -- 1955
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1957
			local toolNames = { -- 1958
				"read_file", -- 1959
				"edit_file", -- 1959
				"delete_file", -- 1959
				"grep_files", -- 1959
				"search_dora_api", -- 1959
				"glob_files", -- 1960
				"build", -- 1960
				"fetch_url", -- 1960
				"execute_command", -- 1960
				"list_sub_agents", -- 1960
				"spawn_sub_agent", -- 1961
				"finish" -- 1961
			} -- 1961
			do -- 1961
				local i = 0 -- 1963
				while i < #toolNames do -- 1963
					local tool = toolNames[i + 1] -- 1964
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1964
						shared.resumeRequiredTool = tool -- 1966
						break -- 1967
					end -- 1967
					i = i + 1 -- 1963
				end -- 1963
			end -- 1963
		end -- 1963
	end -- 1963
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1963
		shared.resumeRequiredTool = nil -- 1973
	end -- 1973
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1973
		shared.resumeRequiredTool = nil -- 1976
	end -- 1976
end -- 1976
function ensureToolCallId(toolCallId) -- 1991
	if toolCallId and toolCallId ~= "" then -- 1991
		return toolCallId -- 1992
	end -- 1992
	return createLocalToolCallId() -- 1993
end -- 1993
function hasXMLParam(params, name) -- 2026
	return params[name] ~= nil -- 2027
end -- 2027
function inferToolNameFromXMLParams(params) -- 2030
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 2030
		return "edit_file" -- 2032
	end -- 2032
	if hasXMLParam(params, "target_file") then -- 2032
		return "delete_file" -- 2035
	end -- 2035
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 2035
		if hasXMLParam(params, "path") then -- 2035
			return "read_file" -- 2038
		end -- 2038
		return nil -- 2039
	end -- 2039
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 2039
		if hasXMLParam(params, "pattern") then -- 2039
			return "search_dora_api" -- 2042
		end -- 2042
		return nil -- 2043
	end -- 2043
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 2043
		if hasXMLParam(params, "pattern") then -- 2043
			return "grep_files" -- 2046
		end -- 2046
		return nil -- 2047
	end -- 2047
	if hasXMLParam(params, "globs") then -- 2047
		if hasXMLParam(params, "pattern") then -- 2047
			return "grep_files" -- 2050
		end -- 2050
		return "glob_files" -- 2051
	end -- 2051
	if hasXMLParam(params, "maxEntries") then -- 2051
		return "glob_files" -- 2054
	end -- 2054
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2054
		return "finish" -- 2057
	end -- 2057
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 2057
		return "spawn_sub_agent" -- 2060
	end -- 2060
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 2060
		return "list_sub_agents" -- 2063
	end -- 2063
	return nil -- 2065
end -- 2065
function parseDSMLAttribute(source, offset, name) -- 2068
	local attrOpen = name .. "=\"" -- 2069
	local attrStart = (string.find( -- 2070
		source, -- 2070
		attrOpen, -- 2070
		math.max(offset + 1, 1), -- 2070
		true -- 2070
	) or 0) - 1 -- 2070
	if attrStart < 0 then -- 2070
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 2071
	end -- 2071
	local valueStart = attrStart + #attrOpen -- 2072
	local valueEnd = (string.find( -- 2073
		source, -- 2073
		"\"", -- 2073
		math.max(valueStart + 1, 1), -- 2073
		true -- 2073
	) or 0) - 1 -- 2073
	if valueEnd < 0 then -- 2073
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 2074
	end -- 2074
	return { -- 2075
		success = true, -- 2076
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 2077
		next = valueEnd + 1 -- 2078
	} -- 2078
end -- 2078
function extractDSMLReason(text, invokeStart, tool) -- 2082
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2083
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2084
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2084
		return before -- 2087
	end -- 2087
	if tool == "finish" then -- 2087
		return "" -- 2088
	end -- 2088
	return "Converted provider-native tool call syntax to XML." -- 2089
end -- 2089
function parseDSMLToolCallObjectFromText(text) -- 2092
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2093
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2094
	if invokeStart < 0 then -- 2094
		return {success = false, message = "missing DSML invoke"} -- 2095
	end -- 2095
	local nameStart = invokeStart + #invokeOpen -- 2096
	local nameEnd = (string.find( -- 2097
		text, -- 2097
		"\"", -- 2097
		math.max(nameStart + 1, 1), -- 2097
		true -- 2097
	) or 0) - 1 -- 2097
	if nameEnd < 0 then -- 2097
		return {success = false, message = "unterminated DSML invoke name"} -- 2098
	end -- 2098
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2099
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2099
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2101
	end -- 2101
	local invokeOpenEnd = (string.find( -- 2103
		text, -- 2103
		">", -- 2103
		math.max(nameEnd + 1, 1), -- 2103
		true -- 2103
	) or 0) - 1 -- 2103
	if invokeOpenEnd < 0 then -- 2103
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2104
	end -- 2104
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2105
	local invokeEnd = (string.find( -- 2106
		text, -- 2106
		invokeClose, -- 2106
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2106
		true -- 2106
	) or 0) - 1 -- 2106
	if invokeEnd < 0 then -- 2106
		return {success = false, message = "missing DSML invoke close tag"} -- 2107
	end -- 2107
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2109
	local params = {} -- 2110
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2111
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2112
	local pos = 0 -- 2113
	while pos < #body do -- 2113
		local start = (string.find( -- 2115
			body, -- 2115
			paramOpen, -- 2115
			math.max(pos + 1, 1), -- 2115
			true -- 2115
		) or 0) - 1 -- 2115
		if start < 0 then -- 2115
			break -- 2116
		end -- 2116
		local openEnd = (string.find( -- 2117
			body, -- 2117
			">", -- 2117
			math.max(start + #paramOpen + 1, 1), -- 2117
			true -- 2117
		) or 0) - 1 -- 2117
		if openEnd < 0 then -- 2117
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2118
		end -- 2118
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2119
		if not name.success then -- 2119
			return name -- 2120
		end -- 2120
		local close = (string.find( -- 2121
			body, -- 2121
			paramClose, -- 2121
			math.max(openEnd + 1 + 1, 1), -- 2121
			true -- 2121
		) or 0) - 1 -- 2121
		if close < 0 then -- 2121
			return {success = false, message = "missing DSML parameter close tag"} -- 2122
		end -- 2122
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2123
		pos = close + #paramClose -- 2124
	end -- 2124
	return { -- 2126
		success = true, -- 2127
		obj = { -- 2128
			tool = toolName, -- 2129
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2130
			params = params -- 2131
		} -- 2131
	} -- 2131
end -- 2131
function parseXMLToolCallObjectFromText(text) -- 2136
	local children = parseXMLObjectFromText(text, "tool_call") -- 2137
	local rawObj -- 2138
	if children.success then -- 2138
		rawObj = children.obj -- 2140
	else -- 2140
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2142
		if dsml.success then -- 2142
			return dsml -- 2143
		end -- 2143
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2144
		local paramsCloseToken = "</params>" -- 2145
		if toolStart >= 0 then -- 2145
			local paramsClose = (string.find( -- 2147
				text, -- 2147
				paramsCloseToken, -- 2147
				math.max(toolStart + 1, 1), -- 2147
				true -- 2147
			) or 0) - 1 -- 2147
			if paramsClose >= toolStart then -- 2147
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2149
				local bare = parseSimpleXMLChildren(bareCandidate) -- 2150
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2150
					rawObj = bare.obj -- 2152
				end -- 2152
			end -- 2152
		end -- 2152
		if rawObj == nil then -- 2152
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2157
			if paramsOpen < 0 then -- 2157
				return children -- 2158
			end -- 2158
			local paramsCloseOnly = (string.find( -- 2159
				text, -- 2159
				paramsCloseToken, -- 2159
				math.max(paramsOpen + 1, 1), -- 2159
				true -- 2159
			) or 0) - 1 -- 2159
			if paramsCloseOnly < paramsOpen then -- 2159
				return children -- 2160
			end -- 2160
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2161
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 2162
			if not paramsOnly.success then -- 2162
				return children -- 2163
			end -- 2163
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2164
			if inferredTool == nil then -- 2164
				return children -- 2165
			end -- 2165
			local ____temp_54 -- 2170
			if inferredTool == "finish" then -- 2170
				____temp_54 = nil -- 2170
			else -- 2170
				____temp_54 = "Inferred tool from XML params." -- 2170
			end -- 2170
			return {success = true, obj = {tool = inferredTool, reason = ____temp_54, params = paramsOnly.obj}} -- 2166
		end -- 2166
	end -- 2166
	if rawObj == nil then -- 2166
		return children -- 2176
	end -- 2176
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2177
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2178
	if not params.success then -- 2178
		return {success = false, message = params.message} -- 2182
	end -- 2182
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2184
end -- 2184
function parseDecisionObject(rawObj) -- 2280
	if type(rawObj.tool) ~= "string" then -- 2280
		return {success = false, message = "missing tool"} -- 2281
	end -- 2281
	local tool = rawObj.tool -- 2282
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2282
		return {success = false, message = "unknown tool: " .. tool} -- 2284
	end -- 2284
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2286
	if tool ~= "finish" and (not reason or reason == "") then -- 2286
		return {success = false, message = tool .. " requires top-level reason"} -- 2290
	end -- 2290
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2292
	return {success = true, tool = tool, params = params, reason = reason} -- 2293
end -- 2293
function getDecisionPath(params) -- 2415
	if type(params.path) == "string" then -- 2415
		return __TS__StringTrim(params.path) -- 2416
	end -- 2416
	if type(params.target_file) == "string" then -- 2416
		return __TS__StringTrim(params.target_file) -- 2417
	end -- 2417
	return "" -- 2418
end -- 2418
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2421
	if enforceFinalTurn == nil then -- 2421
		enforceFinalTurn = false -- 2425
	end -- 2425
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2425
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2428
	end -- 2428
	if not isToolAllowedForRole(shared, tool) then -- 2428
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2431
	end -- 2431
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2431
		local path = getDecisionPath(params) -- 2434
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2434
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2436
		end -- 2436
	end -- 2436
	if tool == "delete_file" then -- 2436
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2440
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2440
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2442
		end -- 2442
	end -- 2442
	return {success = true} -- 2445
end -- 2445
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2448
	local num = __TS__Number(value) -- 2449
	if not __TS__NumberIsFinite(num) then -- 2449
		num = fallback -- 2450
	end -- 2450
	num = math.floor(num) -- 2451
	if num < minValue then -- 2451
		num = minValue -- 2452
	end -- 2452
	if maxValue ~= nil and num > maxValue then -- 2452
		num = maxValue -- 2453
	end -- 2453
	return num -- 2454
end -- 2454
function parseReadLineParam(value, fallback, paramName) -- 2457
	local num = __TS__Number(value) -- 2462
	if not __TS__NumberIsFinite(num) then -- 2462
		num = fallback -- 2463
	end -- 2463
	num = math.floor(num) -- 2464
	if num == 0 then -- 2464
		return {success = false, message = paramName .. " cannot be 0"} -- 2466
	end -- 2466
	return {success = true, value = num} -- 2468
end -- 2468
function validateDecision(tool, params) -- 2471
	if tool == "finish" then -- 2471
		local message = getFinishMessage(params) -- 2476
		if message == "" then -- 2476
			return {success = false, message = "finish requires params.message"} -- 2477
		end -- 2477
		params.message = message -- 2478
		local completion = getCompletionReport(params) -- 2479
		params.outcome = completion.outcome -- 2480
		params.validation = completion.validation -- 2481
		params.knownIssues = completion.knownIssues -- 2482
		params.assumptions = completion.assumptions -- 2483
		params.learningCandidates = completion.learningCandidates -- 2484
		return {success = true, params = params} -- 2485
	end -- 2485
	if tool == "ask_user" then -- 2485
		local normalized = normalizeQuestionnaire(params) -- 2489
		if not normalized.success then -- 2489
			return normalized -- 2490
		end -- 2490
		return {success = true, params = normalized.schema} -- 2491
	end -- 2491
	if tool == "read_file" then -- 2491
		local path = getDecisionPath(params) -- 2495
		if path == "" then -- 2495
			return {success = false, message = "read_file requires path"} -- 2496
		end -- 2496
		params.path = path -- 2497
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2498
		if not startLineRes.success then -- 2498
			return startLineRes -- 2499
		end -- 2499
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2500
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2501
		if not endLineRes.success then -- 2501
			return endLineRes -- 2502
		end -- 2502
		params.startLine = startLineRes.value -- 2503
		params.endLine = endLineRes.value -- 2504
		return {success = true, params = params} -- 2505
	end -- 2505
	if tool == "edit_file" then -- 2505
		local path = getDecisionPath(params) -- 2509
		if path == "" then -- 2509
			return {success = false, message = "edit_file requires path"} -- 2510
		end -- 2510
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2511
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2512
		params.path = path -- 2513
		params.old_str = oldStr -- 2514
		params.new_str = newStr -- 2515
		return {success = true, params = params} -- 2516
	end -- 2516
	if tool == "delete_file" then -- 2516
		local targetFile = getDecisionPath(params) -- 2520
		if targetFile == "" then -- 2520
			return {success = false, message = "delete_file requires target_file"} -- 2521
		end -- 2521
		params.target_file = targetFile -- 2522
		return {success = true, params = params} -- 2523
	end -- 2523
	if tool == "grep_files" then -- 2523
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2527
		if pattern == "" then -- 2527
			return {success = false, message = "grep_files requires pattern"} -- 2528
		end -- 2528
		params.pattern = pattern -- 2529
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2530
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2531
		return {success = true, params = params} -- 2532
	end -- 2532
	if tool == "search_dora_api" then -- 2532
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2536
		if pattern == "" then -- 2536
			return {success = false, message = "search_dora_api requires pattern"} -- 2537
		end -- 2537
		params.pattern = pattern -- 2538
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2539
		return {success = true, params = params} -- 2540
	end -- 2540
	if tool == "glob_files" then -- 2540
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2544
		return {success = true, params = params} -- 2545
	end -- 2545
	if tool == "build" then -- 2545
		local path = getDecisionPath(params) -- 2549
		if path ~= "" then -- 2549
			params.path = path -- 2551
		end -- 2551
		return {success = true, params = params} -- 2553
	end -- 2553
	if tool == "list_sub_agents" then -- 2553
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2557
		if status ~= "" then -- 2557
			params.status = status -- 2559
		end -- 2559
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2561
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2562
		if type(params.query) == "string" then -- 2562
			params.query = __TS__StringTrim(params.query) -- 2564
		end -- 2564
		return {success = true, params = params} -- 2566
	end -- 2566
	if tool == "spawn_sub_agent" then -- 2566
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2570
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2571
		if prompt == "" then -- 2571
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2572
		end -- 2572
		if title == "" then -- 2572
			return {success = false, message = "spawn_sub_agent requires title"} -- 2573
		end -- 2573
		params.prompt = prompt -- 2574
		params.title = title -- 2575
		if type(params.expectedOutput) == "string" then -- 2575
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2577
		end -- 2577
		if isArray(params.filesHint) then -- 2577
			params.filesHint = __TS__ArrayMap( -- 2580
				__TS__ArrayFilter( -- 2580
					params.filesHint, -- 2580
					function(____, item) return type(item) == "string" end -- 2581
				), -- 2581
				function(____, item) return sanitizeUTF8(item) end -- 2582
			) -- 2582
		end -- 2582
		return {success = true, params = params} -- 2584
	end -- 2584
	return {success = true, params = params} -- 2587
end -- 2587
function validateCompletionForRole(role, tool, params) -- 2590
	if role ~= "sub" or tool ~= "finish" then -- 2590
		return {success = true} -- 2595
	end -- 2595
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2595
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2597
	end -- 2597
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2599
	do -- 2599
		local i = 0 -- 2600
		while i < #requiredArrays do -- 2600
			local name = requiredArrays[i + 1] -- 2601
			if not isArray(params[name]) then -- 2601
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2603
			end -- 2603
			i = i + 1 -- 2600
		end -- 2600
	end -- 2600
	return {success = true} -- 2606
end -- 2606
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2609
	if includeToolDefinitions == nil then -- 2609
		includeToolDefinitions = false -- 2609
	end -- 2609
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2610
	local sections = { -- 2613
		shared.promptPack.agentIdentityPrompt, -- 2614
		rolePrompt, -- 2615
		getReplyLanguageDirective(shared) -- 2616
	} -- 2616
	if shared.role == "main" then -- 2616
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2619
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2620
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2620
			sections[#sections + 1] = table.concat( -- 2622
				{ -- 2622
					"# Current Living Development Plan", -- 2623
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2624
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2624
						sanitizeUTF8(Content:load(planPath)), -- 2625
						12000 -- 2625
					), -- 2625
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2625
						sanitizeUTF8(Content:load(progressPath)), -- 2626
						12000 -- 2626
					) -- 2626
				}, -- 2626
				"\n\n" -- 2627
			) -- 2627
		end -- 2627
	end -- 2627
	if shared.decisionMode == "tool_calling" then -- 2627
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2631
	end -- 2631
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2633
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2634
	if memoryContext ~= "" then -- 2634
		sections[#sections + 1] = memoryContext -- 2636
	end -- 2636
	local skillsSection = buildSkillsSection(shared) -- 2638
	if skillsSection ~= "" then -- 2638
		sections[#sections + 1] = skillsSection -- 2640
	end -- 2640
	if includeToolDefinitions then -- 2640
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2643
		if shared.decisionMode == "xml" then -- 2643
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2645
		end -- 2645
	end -- 2645
	return table.concat(sections, "\n\n") -- 2648
end -- 2648
function buildSkillsSection(shared) -- 2651
	local ____opt_73 = shared.skills -- 2651
	if not (____opt_73 and ____opt_73.loader) then -- 2651
		return "" -- 2653
	end -- 2653
	return shared.skills.loader:buildSkillsPromptSection() -- 2655
end -- 2655
function isFinalDecisionTurn(shared) -- 2723
	return shared.step + 1 >= shared.maxSteps -- 2724
end -- 2724
function buildXmlDecisionInstruction(shared, feedback) -- 2804
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2805
end -- 2805
function tryParseAndValidateDecision(rawText, shared) -- 2889
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2890
	if not parsed.success then -- 2890
		return {success = false, message = parsed.message, raw = rawText} -- 2892
	end -- 2892
	local decision = parseDecisionObject(parsed.obj) -- 2894
	if not decision.success then -- 2894
		return {success = false, message = decision.message, raw = rawText} -- 2896
	end -- 2896
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2898
	if not completionValidation.success then -- 2898
		return {success = false, message = completionValidation.message, raw = rawText} -- 2900
	end -- 2900
	local validation = validateDecision(decision.tool, decision.params) -- 2902
	if not validation.success then -- 2902
		return {success = false, message = validation.message, raw = rawText} -- 2904
	end -- 2904
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2906
	if not sharedValidation.success then -- 2906
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2908
	end -- 2908
	decision.params = validation.params -- 2910
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2911
	return decision -- 2912
end -- 2912
function executeToolAction(shared, action) -- 4246
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4246
		if shared.stopToken.stopped then -- 4246
			return ____awaiter_resolve( -- 4246
				nil, -- 4246
				{ -- 4248
					success = false, -- 4248
					message = getCancelledReason(shared) -- 4248
				} -- 4248
			) -- 4248
		end -- 4248
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4248
			shared.resumeRequiredTool = nil -- 4251
			shared.resumeCheckpointPending = false -- 4252
		end -- 4252
		local params = action.params -- 4254
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4255
		if not sharedValidation.success then -- 4255
			return ____awaiter_resolve(nil, sharedValidation) -- 4255
		end -- 4255
		if action.tool == "read_file" then -- 4255
			local ____params_startLine_148 = params.startLine -- 4258
			if ____params_startLine_148 == nil then -- 4258
				____params_startLine_148 = 1 -- 4258
			end -- 4258
			local startLine = __TS__Number(____params_startLine_148) -- 4258
			local ____params_endLine_149 = params.endLine -- 4259
			if ____params_endLine_149 == nil then -- 4259
				____params_endLine_149 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4259
			end -- 4259
			local endLine = __TS__Number(____params_endLine_149) -- 4259
			local clippedAfterCompression = false -- 4260
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4260
				endLine = startLine + 159 -- 4267
				clippedAfterCompression = true -- 4268
			end -- 4268
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4270
			if __TS__StringTrim(path) == "" then -- 4270
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4270
			end -- 4270
			local result = Tools.readFile( -- 4274
				shared.workingDir, -- 4275
				path, -- 4276
				startLine, -- 4277
				endLine, -- 4278
				shared.useChineseResponse and "zh" or "en" -- 4279
			) -- 4279
			if clippedAfterCompression and result.success == true then -- 4279
				result.clipped = true -- 4282
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4283
			end -- 4283
			return ____awaiter_resolve(nil, result) -- 4283
		end -- 4283
		if action.tool ~= "build" then -- 4283
			shared.resumeNarrowReadMode = false -- 4293
		end -- 4293
		if action.tool == "grep_files" then -- 4293
			local searchPath = params.path or "" -- 4295
			local searchGlobs = params.globs -- 4296
			local ____Tools_searchFiles_163 = Tools.searchFiles -- 4297
			local ____shared_workingDir_156 = shared.workingDir -- 4298
			local ____temp_157 = params.pattern or "" -- 4300
			local ____params_globs_158 = params.globs -- 4301
			local ____params_useRegex_159 = params.useRegex -- 4302
			local ____params_caseSensitive_160 = params.caseSensitive -- 4303
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_161 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4305
			local ____math_max_152 = math.max -- 4306
			local ____math_floor_151 = math.floor -- 4306
			local ____params_limit_150 = params.limit -- 4306
			if ____params_limit_150 == nil then -- 4306
				____params_limit_150 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4306
			end -- 4306
			local ____math_max_152_result_162 = ____math_max_152( -- 4306
				1, -- 4306
				____math_floor_151(__TS__Number(____params_limit_150)) -- 4306
			) -- 4306
			local ____math_max_155 = math.max -- 4307
			local ____math_floor_154 = math.floor -- 4307
			local ____params_offset_153 = params.offset -- 4307
			if ____params_offset_153 == nil then -- 4307
				____params_offset_153 = 0 -- 4307
			end -- 4307
			local result = __TS__Await(____Tools_searchFiles_163({ -- 4297
				workDir = ____shared_workingDir_156, -- 4298
				path = searchPath, -- 4299
				pattern = ____temp_157, -- 4300
				globs = ____params_globs_158, -- 4301
				useRegex = ____params_useRegex_159, -- 4302
				caseSensitive = ____params_caseSensitive_160, -- 4303
				includeContent = true, -- 4304
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_161, -- 4305
				limit = ____math_max_152_result_162, -- 4306
				offset = ____math_max_155( -- 4307
					0, -- 4307
					____math_floor_154(__TS__Number(____params_offset_153)) -- 4307
				), -- 4307
				groupByFile = params.groupByFile == true -- 4308
			})) -- 4308
			return ____awaiter_resolve(nil, result) -- 4308
		end -- 4308
		if action.tool == "search_dora_api" then -- 4308
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4313
			local ____Tools_searchDoraAPI_172 = Tools.searchDoraAPI -- 4314
			local ____temp_168 = params.pattern or "" -- 4315
			local ____temp_169 = params.docSource or "api" -- 4316
			local ____temp_170 = shared.useChineseResponse and "zh" or "en" -- 4317
			local ____temp_171 = params.programmingLanguage or "ts" -- 4318
			local ____math_min_167 = math.min -- 4319
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_166 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4319
			local ____math_max_165 = math.max -- 4319
			local ____params_limit_164 = params.limit -- 4319
			if ____params_limit_164 == nil then -- 4319
				____params_limit_164 = 8 -- 4319
			end -- 4319
			local result = __TS__Await(____Tools_searchDoraAPI_172({ -- 4314
				pattern = ____temp_168, -- 4315
				docSource = ____temp_169, -- 4316
				docLanguage = ____temp_170, -- 4317
				programmingLanguage = ____temp_171, -- 4318
				limit = ____math_min_167( -- 4319
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_166, -- 4319
					____math_max_165( -- 4319
						1, -- 4319
						__TS__Number(____params_limit_164) -- 4319
					) -- 4319
				), -- 4319
				useRegex = params.useRegex, -- 4320
				caseSensitive = false, -- 4321
				includeContent = true, -- 4322
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4323
			})) -- 4323
			return ____awaiter_resolve(nil, result) -- 4323
		end -- 4323
		if action.tool == "glob_files" then -- 4323
			local ____Tools_listFiles_179 = Tools.listFiles -- 4328
			local ____shared_workingDir_176 = shared.workingDir -- 4329
			local ____temp_177 = params.path or "" -- 4330
			local ____params_globs_178 = params.globs -- 4331
			local ____math_max_175 = math.max -- 4332
			local ____math_floor_174 = math.floor -- 4332
			local ____params_maxEntries_173 = params.maxEntries -- 4332
			if ____params_maxEntries_173 == nil then -- 4332
				____params_maxEntries_173 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4332
			end -- 4332
			local result = ____Tools_listFiles_179({ -- 4328
				workDir = ____shared_workingDir_176, -- 4329
				path = ____temp_177, -- 4330
				globs = ____params_globs_178, -- 4331
				maxEntries = ____math_max_175( -- 4332
					1, -- 4332
					____math_floor_174(__TS__Number(____params_maxEntries_173)) -- 4332
				) -- 4332
			}) -- 4332
			return ____awaiter_resolve(nil, result) -- 4332
		end -- 4332
		if action.tool == "ask_user" then -- 4332
			if not shared.publishQuestionnaire then -- 4332
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4332
			end -- 4332
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4332
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4332
			end -- 4332
			local normalized = normalizeQuestionnaire(params) -- 4339
			if not normalized.success then -- 4339
				return ____awaiter_resolve(nil, normalized) -- 4339
			end -- 4339
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4341
			if not result.success then -- 4341
				return ____awaiter_resolve(nil, result) -- 4341
			end -- 4341
			shared.waitingQuestionnaireId = result.questionnaireId -- 4348
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4348
		end -- 4348
		if action.tool == "delete_file" then -- 4348
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4352
			if __TS__StringTrim(targetFile) == "" then -- 4352
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4352
			end -- 4352
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4356
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4357
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4357
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4357
			end -- 4357
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4361
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4362
			if not result.success then -- 4362
				return ____awaiter_resolve(nil, result) -- 4362
			end -- 4362
			if not isInternalDocumentEdit then -- 4362
				shared.unbuiltEdits = true -- 4370
				shared.lastBuildSucceeded = false -- 4371
				if shared.failedTestNeedsBuild == true then -- 4371
					shared.failedTestHasSourceEdit = true -- 4372
				end -- 4372
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4372
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4373
				end -- 4373
				shared.editedPathsSinceBuild = editedPaths -- 4374
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4375
			end -- 4375
			return ____awaiter_resolve(nil, { -- 4375
				success = true, -- 4378
				changed = true, -- 4379
				mode = "delete", -- 4380
				checkpointId = result.checkpointId, -- 4381
				checkpointSeq = result.checkpointSeq, -- 4382
				files = {{path = targetFile, op = "delete"}} -- 4383
			}) -- 4383
		end -- 4383
		if action.tool == "build" then -- 4383
			local buildPath = params.path or "" -- 4387
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4388
			shared.unbuiltEdits = false -- 4392
			shared.editsSinceBuild = 0 -- 4393
			shared.editedPathsSinceBuild = {} -- 4394
			shared.hasBuilt = true -- 4395
			shared.lastBuildSucceeded = result.success -- 4396
			if result.success and shared.freshProjectBuildPending == true then -- 4396
				shared.freshProjectBuildPending = false -- 4402
			end -- 4402
			shared.apiSearchesSinceBuild = 0 -- 4404
			shared.buildRepairPending = false -- 4405
			if not result.success and result.messages ~= nil then -- 4405
				do -- 4405
					local i = 0 -- 4407
					while i < #result.messages do -- 4407
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4407
							shared.buildRepairPending = true -- 4409
							break -- 4410
						end -- 4410
						i = i + 1 -- 4407
					end -- 4407
				end -- 4407
			end -- 4407
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4407
				shared.failedTestNeedsBuild = false -- 4415
				shared.failedTestHasSourceEdit = false -- 4416
			end -- 4416
			return ____awaiter_resolve(nil, result) -- 4416
		end -- 4416
		if action.tool == "fetch_url" then -- 4416
			local result = __TS__Await(Tools.fetchUrl({ -- 4421
				workDir = shared.workingDir, -- 4422
				url = type(params.url) == "string" and params.url or "", -- 4423
				target = type(params.target) == "string" and params.target or "", -- 4424
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4425
				onProgress = function(____, progress) -- 4426
					emitAgentEvent( -- 4427
						shared, -- 4427
						{ -- 4427
							type = "tool_progress", -- 4428
							sessionId = shared.sessionId, -- 4429
							taskId = shared.taskId, -- 4430
							step = action.step, -- 4431
							tool = action.tool, -- 4432
							result = __TS__ObjectAssign({success = false}, progress) -- 4433
						} -- 4433
					) -- 4433
				end -- 4426
			})) -- 4426
			return ____awaiter_resolve(nil, result) -- 4426
		end -- 4426
		if action.tool == "execute_command" then -- 4426
			local mode = type(params.mode) == "string" and params.mode or "" -- 4443
			local result = __TS__Await(Tools.executeCommand({ -- 4444
				workDir = shared.workingDir, -- 4445
				mode = mode, -- 4446
				code = type(params.code) == "string" and params.code or nil, -- 4447
				command = type(params.command) == "string" and params.command or nil, -- 4448
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4449
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4450
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4451
				onProgress = function(____, progress) -- 4452
					emitAgentEvent( -- 4453
						shared, -- 4453
						{ -- 4453
							type = "tool_progress", -- 4454
							sessionId = shared.sessionId, -- 4455
							taskId = shared.taskId, -- 4456
							step = action.step, -- 4457
							tool = action.tool, -- 4458
							result = __TS__ObjectAssign({success = false}, progress) -- 4459
						} -- 4459
					) -- 4459
				end -- 4452
			})) -- 4452
			if result.success and mode == "lua" then -- 4452
				local deterministicFailure = false -- 4467
				local deterministicPass = false -- 4468
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4469
				do -- 4469
					local i = 0 -- 4470
					while i < #outputLines and not deterministicFailure do -- 4470
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4471
						if line == "passed" then -- 4471
							deterministicPass = true -- 4472
						end -- 4472
						if line == "failed" then -- 4472
							deterministicFailure = true -- 4474
							break -- 4475
						end -- 4475
						local searchFrom = 0 -- 4477
						while searchFrom < #line do -- 4477
							local failedIndex = (string.find( -- 4479
								line, -- 4479
								"failed", -- 4479
								math.max(searchFrom + 1, 1), -- 4479
								true -- 4479
							) or 0) - 1 -- 4479
							if failedIndex < 0 then -- 4479
								break -- 4480
							end -- 4480
							local after = failedIndex + #"failed" -- 4481
							while after < #line do -- 4481
								local ch = __TS__StringSlice(line, after, after + 1) -- 4483
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4483
									break -- 4484
								end -- 4484
								after = after + 1 -- 4485
							end -- 4485
							local afterEnd = after -- 4487
							while afterEnd < #line do -- 4487
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4489
								if ch < "0" or ch > "9" then -- 4489
									break -- 4490
								end -- 4490
								afterEnd = afterEnd + 1 -- 4491
							end -- 4491
							local count -- 4493
							if afterEnd > after then -- 4493
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4495
							else -- 4495
								local before = failedIndex - 1 -- 4497
								while before >= 0 do -- 4497
									local ch = __TS__StringSlice(line, before, before + 1) -- 4499
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4499
										break -- 4500
									end -- 4500
									before = before - 1 -- 4501
								end -- 4501
								local beforeEnd = before + 1 -- 4503
								while before >= 0 do -- 4503
									local ch = __TS__StringSlice(line, before, before + 1) -- 4505
									if ch < "0" or ch > "9" then -- 4505
										break -- 4506
									end -- 4506
									before = before - 1 -- 4507
								end -- 4507
								if beforeEnd > before + 1 then -- 4507
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4509
								end -- 4509
							end -- 4509
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4509
								deterministicFailure = true -- 4512
								break -- 4513
							end -- 4513
							searchFrom = failedIndex + #"failed" -- 4515
						end -- 4515
						i = i + 1 -- 4470
					end -- 4470
				end -- 4470
				if deterministicFailure then -- 4470
					shared.failedTestNeedsBuild = true -- 4519
					shared.failedTestHasSourceEdit = false -- 4520
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4521
				elseif deterministicPass then -- 4521
					shared.deterministicTestFailureCount = 0 -- 4523
				end -- 4523
			end -- 4523
			return ____awaiter_resolve(nil, result) -- 4523
		end -- 4523
		if action.tool == "spawn_sub_agent" then -- 4523
			if not shared.spawnSubAgent then -- 4523
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4523
			end -- 4523
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4523
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4523
			end -- 4523
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4535
				params.filesHint, -- 4536
				function(____, item) return type(item) == "string" end -- 4536
			) or nil -- 4536
			local result = __TS__Await(shared.spawnSubAgent({ -- 4538
				parentSessionId = shared.sessionId, -- 4539
				projectRoot = shared.workingDir, -- 4540
				title = type(params.title) == "string" and params.title or "Sub", -- 4541
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4542
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4543
				filesHint = filesHint, -- 4544
				disabledAgentTools = shared.disabledAgentTools -- 4545
			})) -- 4545
			if not result.success then -- 4545
				return ____awaiter_resolve(nil, result) -- 4545
			end -- 4545
			shared.hasSpawnedSubAgentThisTask = true -- 4550
			return ____awaiter_resolve(nil, { -- 4550
				success = true, -- 4552
				sessionId = result.sessionId, -- 4553
				taskId = result.taskId, -- 4554
				title = result.title, -- 4555
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4556
			}) -- 4556
		end -- 4556
		if action.tool == "list_sub_agents" then -- 4556
			if not shared.listSubAgents then -- 4556
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4556
			end -- 4556
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4556
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4556
			end -- 4556
			local result = __TS__Await(shared.listSubAgents({ -- 4566
				sessionId = shared.sessionId, -- 4567
				projectRoot = shared.workingDir, -- 4568
				status = type(params.status) == "string" and params.status or nil, -- 4569
				limit = type(params.limit) == "number" and params.limit or nil, -- 4570
				offset = type(params.offset) == "number" and params.offset or nil, -- 4571
				query = type(params.query) == "string" and params.query or nil -- 4572
			})) -- 4572
			return ____awaiter_resolve(nil, result) -- 4572
		end -- 4572
		if action.tool == "edit_file" then -- 4572
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4577
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4580
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4581
			if __TS__StringTrim(path) == "" then -- 4581
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4581
			end -- 4581
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4583
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4584
			if not isInternalDocumentEdit then -- 4584
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4586
				if preflightIssue ~= nil then -- 4586
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4588
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4589
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4589
				end -- 4589
			end -- 4589
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4595
			local result = __TS__Await(actionNode:exec({ -- 4596
				path = path, -- 4597
				oldStr = oldStr, -- 4598
				newStr = newStr, -- 4599
				taskId = shared.taskId, -- 4600
				workDir = shared.workingDir -- 4601
			})) -- 4601
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4601
				if params.partialStreamRecovery ~= true then -- 4601
					shared.truncatedToolOverwritePath = nil -- 4605
				end -- 4605
				shared.unbuiltEdits = true -- 4607
				shared.lastBuildSucceeded = false -- 4608
				if shared.failedTestNeedsBuild == true then -- 4608
					shared.failedTestHasSourceEdit = true -- 4609
				end -- 4609
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4610
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4610
					editedPaths[#editedPaths + 1] = normalizedPath -- 4611
				end -- 4611
				shared.editedPathsSinceBuild = editedPaths -- 4612
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4613
			end -- 4613
			return ____awaiter_resolve(nil, result) -- 4613
		end -- 4613
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4613
	end) -- 4613
end -- 4613
function sanitizeToolActionResultForHistory(action, result) -- 4620
	if action.tool == "read_file" then -- 4620
		return sanitizeReadResultForHistory(action.tool, result) -- 4622
	end -- 4622
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4622
		return sanitizeSearchResultForHistory(action.tool, result) -- 4625
	end -- 4625
	if action.tool == "glob_files" then -- 4625
		return sanitizeListFilesResultForHistory(result) -- 4628
	end -- 4628
	if action.tool == "build" then -- 4628
		return sanitizeBuildResultForHistory(result) -- 4631
	end -- 4631
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4631
		if result.success ~= true then -- 4631
			return result -- 4634
		end -- 4634
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4634
			return result -- 4635
		end -- 4635
		if isArray(result.fileContext) then -- 4635
			return result -- 4636
		end -- 4636
		local contextLimits = { -- 4638
			fullContentChars = 12000, -- 4639
			previewChars = 4000, -- 4640
			diffChars = 8000, -- 4641
			totalChars = 24000, -- 4642
			maxFiles = 8 -- 4643
		} -- 4643
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4645
			if maxChars <= 0 then -- 4645
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4646
			end -- 4646
			if #sourceText <= maxChars then -- 4646
				return sourceText -- 4647
			end -- 4647
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4648
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4649
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4650
		end -- 4645
		local function countLines(sourceText) -- 4652
			if sourceText == "" then -- 4652
				return 0 -- 4653
			end -- 4653
			return #__TS__StringSplit(sourceText, "\n") -- 4654
		end -- 4652
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4656
			if beforeContent == afterContent then -- 4656
				return "" -- 4657
			end -- 4657
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4658
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4659
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4661
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4661
				firstChangedLine = firstChangedLine + 1 -- 4667
			end -- 4667
			local lastChangedBeforeLine = #beforeLines - 1 -- 4669
			local lastChangedAfterLine = #afterLines - 1 -- 4670
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4670
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4676
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4677
			end -- 4677
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4679
			local previewEndLine = math.max( -- 4680
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4681
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4682
			) -- 4682
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4684
			do -- 4684
				local lineIndex = previewStartLine -- 4685
				while lineIndex <= previewEndLine do -- 4685
					do -- 4685
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4686
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4687
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4688
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4689
						if not beforeChanged and not afterChanged then -- 4689
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4691
							if contextLine ~= nil then -- 4691
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4692
							end -- 4692
							goto __continue788 -- 4693
						end -- 4693
						if beforeChanged and beforeLine ~= nil then -- 4693
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4695
						end -- 4695
						if afterChanged and afterLine ~= nil then -- 4695
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4696
						end -- 4696
					end -- 4696
					::__continue788:: -- 4696
					lineIndex = lineIndex + 1 -- 4685
				end -- 4685
			end -- 4685
			return truncateContextSnippet( -- 4698
				table.concat(unifiedDiffLines, "\n"), -- 4698
				maxChars, -- 4698
				"diff" -- 4698
			) -- 4698
		end -- 4656
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4701
		if not checkpointDiff.success then -- 4701
			return result -- 4702
		end -- 4702
		local remainingContextBudget = contextLimits.totalChars -- 4703
		local fileContextItems = {} -- 4704
		local changedFiles = checkpointDiff.files -- 4705
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4706
		do -- 4706
			local fileIndex = 0 -- 4707
			while fileIndex < maxContextFiles do -- 4707
				if remainingContextBudget <= 0 then -- 4707
					break -- 4708
				end -- 4708
				local changedFile = changedFiles[fileIndex + 1] -- 4709
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4710
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4711
				local contextItem = { -- 4712
					path = changedFile.path, -- 4713
					op = changedFile.op, -- 4714
					checkpointId = result.checkpointId, -- 4715
					checkpointSeq = result.checkpointSeq, -- 4716
					beforeExists = changedFile.beforeExists, -- 4717
					afterExists = changedFile.afterExists, -- 4718
					beforeBytes = #beforeContent, -- 4719
					afterBytes = #afterContent, -- 4720
					diffPreview = "", -- 4721
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4722
					contentTruncated = false, -- 4723
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4724
				} -- 4724
				if changedFile.afterExists then -- 4724
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4724
						contextItem.afterContent = afterContent -- 4728
						remainingContextBudget = remainingContextBudget - #afterContent -- 4729
					else -- 4729
						contextItem.afterContentPreview = truncateContextSnippet( -- 4731
							afterContent, -- 4732
							math.min( -- 4733
								contextLimits.previewChars, -- 4733
								math.max(400, remainingContextBudget) -- 4733
							), -- 4733
							"afterContent" -- 4734
						) -- 4734
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4736
						contextItem.contentTruncated = true -- 4737
					end -- 4737
				end -- 4737
				local diffPreview = buildUnifiedDiffPreview( -- 4740
					changedFile.path, -- 4741
					beforeContent, -- 4742
					afterContent, -- 4743
					math.min( -- 4744
						contextLimits.diffChars, -- 4744
						math.max(400, remainingContextBudget) -- 4744
					) -- 4744
				) -- 4744
				contextItem.diffPreview = diffPreview -- 4746
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4747
				if not changedFile.afterExists and beforeContent ~= "" then -- 4747
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4749
						beforeContent, -- 4750
						math.min( -- 4751
							contextLimits.previewChars, -- 4751
							math.max(400, remainingContextBudget) -- 4751
						), -- 4751
						"beforeContent" -- 4752
					) -- 4752
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4754
					if #beforeContent > contextLimits.previewChars then -- 4754
						contextItem.contentTruncated = true -- 4755
					end -- 4755
				end -- 4755
				fileContextItems[#fileContextItems + 1] = contextItem -- 4757
				fileIndex = fileIndex + 1 -- 4707
			end -- 4707
		end -- 4707
		if #fileContextItems == 0 then -- 4707
			return result -- 4759
		end -- 4759
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4760
	end -- 4760
	return result -- 4767
end -- 4767
function emitAgentTaskFinishEvent(shared, success, message) -- 4964
	local completion = shared.completion or ____exports.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4965
	local result = success and ({ -- 4969
		success = true, -- 4971
		taskId = shared.taskId, -- 4972
		message = message, -- 4973
		steps = shared.step, -- 4974
		completion = completion -- 4975
	}) or ({ -- 4975
		success = false, -- 4978
		taskId = shared.taskId, -- 4979
		message = message, -- 4980
		steps = shared.step, -- 4981
		completion = completion -- 4982
	}) -- 4982
	emitAgentEvent(shared, { -- 4984
		type = "task_finished", -- 4985
		sessionId = shared.sessionId, -- 4986
		taskId = shared.taskId, -- 4987
		success = result.success, -- 4988
		message = result.message, -- 4989
		steps = result.steps, -- 4990
		completion = result.completion -- 4991
	}) -- 4991
	return result -- 4993
end -- 4993
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
local function utf8TakeTail(text, maxChars) -- 871
	if maxChars <= 0 or text == "" then -- 871
		return "" -- 872
	end -- 872
	local charLength = utf8.len(text) -- 873
	if charLength == nil or charLength <= maxChars then -- 873
		return text -- 874
	end -- 874
	local startPos = utf8.offset( -- 875
		text, -- 875
		math.max(1, charLength - maxChars + 1) -- 875
	) -- 875
	if startPos == nil then -- 875
		return text -- 876
	end -- 876
	return string.sub(text, startPos) -- 877
end -- 871
local function truncateHistoryText(text, maxChars, label) -- 880
	if maxChars <= 0 or text == "" then -- 880
		return "" -- 881
	end -- 881
	if #text <= maxChars then -- 881
		return text -- 882
	end -- 882
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 883
	local remaining = math.max(0, maxChars - #marker) -- 884
	local headChars = math.floor(remaining * 0.6) -- 885
	local tailChars = remaining - headChars -- 886
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 887
end -- 880
local function summarizeEditTextParamForHistory(value, key) -- 975
	if type(value) ~= "string" then -- 975
		return nil -- 976
	end -- 976
	local text = value -- 977
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 978
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 979
end -- 975
local function sanitizeActionParamsForHistory(tool, params) -- 1114
	if tool ~= "edit_file" then -- 1114
		return params -- 1115
	end -- 1115
	local clone = {} -- 1116
	for key in pairs(params) do -- 1117
		if key == "old_str" then -- 1117
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1119
		elseif key == "new_str" then -- 1119
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1121
		else -- 1121
			clone[key] = params[key] -- 1123
		end -- 1123
	end -- 1123
	return clone -- 1126
end -- 1114
local function projectEditResultForLLM(result) -- 1129
	if result.success ~= true then -- 1129
		local failed = {} -- 1131
		for key in pairs(result) do -- 1132
			local value = result[key] -- 1133
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 1134
		end -- 1134
		return failed -- 1138
	end -- 1138
	local projected = {} -- 1140
	local scalarKeys = { -- 1141
		"success", -- 1142
		"changed", -- 1142
		"mode", -- 1142
		"checkpointId", -- 1142
		"checkpointSeq", -- 1142
		"actualSaved", -- 1143
		"actualSavedCharacters", -- 1143
		"currentFileExists", -- 1143
		"currentCharacters", -- 1143
		"currentState" -- 1143
	} -- 1143
	do -- 1143
		local i = 0 -- 1145
		while i < #scalarKeys do -- 1145
			local key = scalarKeys[i + 1] -- 1146
			if result[key] ~= nil then -- 1146
				projected[key] = result[key] -- 1147
			end -- 1147
			i = i + 1 -- 1145
		end -- 1145
	end -- 1145
	if isArray(result.files) then -- 1145
		projected.files = result.files -- 1149
	end -- 1149
	if type(result.message) == "string" then -- 1149
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1151
	end -- 1151
	if type(result.guidance) == "string" then -- 1151
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1158
	end -- 1158
	if isArray(result.fileContext) then -- 1158
		local summaries = {} -- 1165
		do -- 1165
			local i = 0 -- 1166
			while i < #result.fileContext do -- 1166
				do -- 1166
					local item = result.fileContext[i + 1] -- 1167
					if not isRecord(item) or isArray(item) then -- 1167
						goto __continue159 -- 1168
					end -- 1168
					local summary = {} -- 1169
					local keys = { -- 1170
						"path", -- 1171
						"op", -- 1171
						"beforeExists", -- 1171
						"afterExists", -- 1171
						"beforeBytes", -- 1171
						"afterBytes", -- 1171
						"lineCount", -- 1172
						"contentTruncated", -- 1172
						"fileListTruncated" -- 1172
					} -- 1172
					do -- 1172
						local j = 0 -- 1174
						while j < #keys do -- 1174
							local key = keys[j + 1] -- 1175
							if item[key] ~= nil then -- 1175
								summary[key] = item[key] -- 1176
							end -- 1176
							j = j + 1 -- 1174
						end -- 1174
					end -- 1174
					summaries[#summaries + 1] = summary -- 1178
				end -- 1178
				::__continue159:: -- 1178
				i = i + 1 -- 1166
			end -- 1166
		end -- 1166
		if #summaries > 0 then -- 1166
			projected.fileSummary = summaries -- 1180
		end -- 1180
	end -- 1180
	if type(result.truncatedFileContextItems) == "number" then -- 1180
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1183
	end -- 1183
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1185
	return projected -- 1186
end -- 1129
local function projectBuildResultForLLM(result) -- 1189
	if not isArray(result.messages) then -- 1189
		return result -- 1190
	end -- 1190
	local projected = {} -- 1191
	for key in pairs(result) do -- 1192
		if key ~= "messages" then -- 1192
			projected[key] = result[key] -- 1193
		end -- 1193
	end -- 1193
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1195
	local shown = math.min(#result.messages, maxMessages) -- 1196
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1197
	if #result.messages > shown then -- 1197
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1199
	end -- 1199
	return projected -- 1201
end -- 1189
local function projectCommandResultForLLM(result) -- 1204
	local projected = {} -- 1205
	for key in pairs(result) do -- 1206
		local value = result[key] -- 1207
		if key == "output" and type(value) == "string" then -- 1207
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1209
		elseif key == "message" and type(value) == "string" then -- 1209
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1215
		else -- 1215
			projected[key] = value -- 1221
		end -- 1221
	end -- 1221
	return projected -- 1224
end -- 1204
local function projectToolResultContentForLLM(tool, content) -- 1227
	local decoded = safeJsonDecode(content) -- 1228
	if not isRecord(decoded) or isArray(decoded) then -- 1228
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1230
	end -- 1230
	local projected = decoded -- 1236
	if tool == "edit_file" or tool == "delete_file" then -- 1236
		projected = projectEditResultForLLM(decoded) -- 1238
	elseif tool == "build" then -- 1238
		projected = projectBuildResultForLLM(decoded) -- 1240
	elseif tool == "execute_command" then -- 1240
		projected = projectCommandResultForLLM(decoded) -- 1242
	end -- 1242
	local encoded = toJson(projected, false) -- 1244
	if tool == "read_file" then -- 1244
		return encoded -- 1247
	end -- 1247
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1247
		return encoded -- 1248
	end -- 1248
	local fallback = { -- 1249
		success = projected.success, -- 1250
		llmHistoryTruncated = true, -- 1251
		originalChars = #encoded, -- 1252
		preview = truncateHistoryText( -- 1253
			encoded, -- 1254
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1255
			tool .. " result" -- 1256
		) -- 1256
	} -- 1256
	return toJson(fallback, false) -- 1259
end -- 1227
local function projectMessagesForLLMContext(messages) -- 1262
	local projected = {} -- 1266
	do -- 1266
		local i = 0 -- 1267
		while i < #messages do -- 1267
			local message = messages[i + 1] -- 1268
			local next = __TS__ObjectAssign({}, message) -- 1269
			if message.role == "tool" and type(message.content) == "string" then -- 1269
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1271
			end -- 1271
			projected[#projected + 1] = next -- 1273
			i = i + 1 -- 1267
		end -- 1267
	end -- 1267
	return projected -- 1275
end -- 1262
local function projectMessagesForCompression(messages) -- 1278
	local projected = projectMessagesForLLMContext(messages) -- 1279
	do -- 1279
		local i = 0 -- 1280
		while i < #projected do -- 1280
			do -- 1280
				local message = projected[i + 1] -- 1281
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1281
					goto __continue191 -- 1282
				end -- 1282
				local changed = false -- 1283
				local toolCalls = __TS__ArrayMap( -- 1284
					message.tool_calls, -- 1284
					function(____, toolCall) -- 1284
						local fn = toolCall["function"] -- 1285
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1285
							return toolCall -- 1286
						end -- 1286
						local decoded = safeJsonDecode(fn.arguments) -- 1287
						if not isRecord(decoded) or isArray(decoded) then -- 1287
							return toolCall -- 1288
						end -- 1288
						changed = true -- 1289
						return __TS__ObjectAssign( -- 1290
							{}, -- 1290
							toolCall, -- 1291
							{["function"] = __TS__ObjectAssign( -- 1290
								{}, -- 1292
								fn, -- 1293
								{arguments = toJson( -- 1292
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1294
									false -- 1294
								)} -- 1294
							)} -- 1294
						) -- 1294
					end -- 1284
				) -- 1284
				if changed then -- 1284
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1298
				end -- 1298
			end -- 1298
			::__continue191:: -- 1298
			i = i + 1 -- 1280
		end -- 1280
	end -- 1280
	return projected -- 1300
end -- 1278
local function getDecisionToolSchemaText(shared) -- 1342
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1343
		shared.role, -- 1343
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1343
		{ -- 1343
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1344
			workMode = shared.workMode -- 1345
		} -- 1345
	)) -- 1345
	return toolsText or "" -- 1347
end -- 1342
local function clearPreExecutedResults(shared) -- 1357
	shared.preExecutedResults = nil -- 1358
end -- 1357
local function startPreExecutedToolAction(shared, action) -- 1361
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1361
		local ____hasReturned, ____returnValue -- 1361
		local ____try = __TS__AsyncAwaiter(function() -- 1361
			____hasReturned = true -- 1363
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1363
			return -- 1363
		end) -- 1363
		____try = ____try.catch( -- 1363
			____try, -- 1363
			function(____, err) -- 1363
				return __TS__AsyncAwaiter(function() -- 1363
					local message = tostring(err) -- 1365
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1366
					____hasReturned = true -- 1367
					____returnValue = {success = false, message = message} -- 1367
					return -- 1367
				end) -- 1367
			end -- 1367
		) -- 1367
		__TS__Await(____try) -- 1362
		if ____hasReturned then -- 1362
			return ____awaiter_resolve(nil, ____returnValue) -- 1362
		end -- 1362
	end) -- 1362
end -- 1361
local function createPreExecutedToolResult(shared, action) -- 1371
	local cloneParamValue -- 1372
	cloneParamValue = function(value) -- 1372
		if value == nil then -- 1372
			return value -- 1373
		end -- 1373
		if isArray(value) then -- 1373
			return __TS__ArrayMap( -- 1375
				value, -- 1375
				function(____, item) return cloneParamValue(item) end -- 1375
			) -- 1375
		end -- 1375
		if type(value) == "table" then -- 1375
			local clone = {} -- 1378
			for key in pairs(value) do -- 1379
				clone[key] = cloneParamValue(value[key]) -- 1380
			end -- 1380
			return clone -- 1382
		end -- 1382
		return value -- 1384
	end -- 1372
	local params = cloneParamValue(action.params) -- 1386
	local areParamValuesEqual -- 1387
	areParamValuesEqual = function(left, right) -- 1387
		if left == right then -- 1387
			return true -- 1388
		end -- 1388
		if left == nil or right == nil then -- 1388
			return false -- 1389
		end -- 1389
		if isArray(left) or isArray(right) then -- 1389
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1389
				return false -- 1391
			end -- 1391
			do -- 1391
				local i = 0 -- 1392
				while i < #left do -- 1392
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1392
						return false -- 1393
					end -- 1393
					i = i + 1 -- 1392
				end -- 1392
			end -- 1392
			return true -- 1395
		end -- 1395
		if type(left) == "table" and type(right) == "table" then -- 1395
			local leftCount = 0 -- 1398
			for key in pairs(left) do -- 1399
				leftCount = leftCount + 1 -- 1400
				if not areParamValuesEqual(left[key], right[key]) then -- 1400
					return false -- 1405
				end -- 1405
			end -- 1405
			local rightCount = 0 -- 1408
			for key in pairs(right) do -- 1409
				rightCount = rightCount + 1 -- 1410
			end -- 1410
			return leftCount == rightCount -- 1412
		end -- 1412
		return false -- 1414
	end -- 1387
	return { -- 1416
		action = action, -- 1417
		matches = function(self, nextAction) -- 1418
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1419
		end, -- 1418
		promise = startPreExecutedToolAction(shared, action) -- 1421
	} -- 1421
end -- 1371
local function executeToolActionWithPreExecution(shared, action) -- 1425
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1425
		local ____opt_29 = shared.preExecutedResults -- 1425
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1426
		local result -- 1427
		if preResult then -- 1427
			local ____opt_31 = shared.preExecutedResults -- 1427
			if ____opt_31 ~= nil then -- 1427
				____opt_31:delete(action.toolCallId) -- 1429
			end -- 1429
			if preResult:matches(action) then -- 1429
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1431
				result = __TS__Await(preResult.promise) -- 1432
			else -- 1432
				Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1434
				result = __TS__Await(executeToolAction(shared, action)) -- 1435
			end -- 1435
		else -- 1435
			result = __TS__Await(executeToolAction(shared, action)) -- 1438
		end -- 1438
		local guidance = {} -- 1440
		if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1440
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1446
		end -- 1446
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1446
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1449
		end -- 1449
		if shared.failedTestNeedsBuild == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1449
			guidance[#guidance + 1] = "A deterministic test previously failed. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1452
		end -- 1452
		if action.tool == "search_dora_api" then -- 1452
			if shared.unbuiltEdits == true then -- 1452
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1456
			end -- 1456
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1456
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1459
			end -- 1459
		end -- 1459
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1459
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1467
		end -- 1467
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 1467
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1470
			if oldStr == "" then -- 1470
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1472
			end -- 1472
		end -- 1472
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1472
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1476
		end -- 1476
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1476
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1479
		end -- 1479
		if shared.buildRepairPending == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1479
			guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1484
		end -- 1484
		if shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true then -- 1484
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1487
		end -- 1487
		if #guidance > 0 then -- 1487
			result.guidance = table.concat(guidance, "\n") -- 1490
		end -- 1490
		return ____awaiter_resolve(nil, result) -- 1490
	end) -- 1490
end -- 1425
local function maybeCompressHistory(shared, forceAtTurnBoundary, pendingUserPrompt) -- 1495
	if forceAtTurnBoundary == nil then -- 1495
		forceAtTurnBoundary = false -- 1497
	end -- 1497
	if pendingUserPrompt == nil then -- 1497
		pendingUserPrompt = "" -- 1498
	end -- 1498
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1498
		local ____shared_33 = shared -- 1500
		local memory = ____shared_33.memory -- 1500
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1501
		local changed = false -- 1502
		do -- 1502
			local round = 0 -- 1503
			while round < maxRounds do -- 1503
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1504
				local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1505
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1510
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1518
				local thresholdReached = memory.compressor:shouldCompress(uncoveredMessages, systemPrompt, toolDefinitions) -- 1521
				local activeTokens = 0 -- 1526
				if forceAtTurnBoundary and shared.role == "main" then -- 1526
					local ____temp_37 = estimateTextTokens(systemPrompt) + estimateTextTokens(toolDefinitions) + AgentRuntimePolicy.estimateConversationTokens(uncoveredMessages) + estimateTextTokens(pendingUserPrompt) -- 1528
					local ____math_max_36 = math.max -- 1532
					local ____math_floor_35 = math.floor -- 1532
					local ____shared_llmOptions_max_tokens_34 = shared.llmOptions.max_tokens -- 1532
					if ____shared_llmOptions_max_tokens_34 == nil then -- 1532
						____shared_llmOptions_max_tokens_34 = AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1532
					end -- 1532
					activeTokens = ____temp_37 + ____math_max_36( -- 1528
						0, -- 1532
						____math_floor_35(__TS__Number(____shared_llmOptions_max_tokens_34)) -- 1532
					) -- 1532
				end -- 1532
				local turnBoundaryThreshold = AgentConfig.getTurnBoundaryCompressionThreshold(shared.llmConfig.contextWindow) -- 1534
				local turnBoundaryReached = forceAtTurnBoundary and shared.role == "main" and #uncoveredMessages > 0 and activeTokens >= turnBoundaryThreshold -- 1537
				if not thresholdReached and not turnBoundaryReached then -- 1537
					if changed then -- 1537
						persistHistoryState(shared) -- 1543
					end -- 1543
					return ____awaiter_resolve(nil) -- 1543
				end -- 1543
				local compressionRound = round + 1 -- 1547
				shared.step = shared.step + 1 -- 1548
				local stepId = shared.step -- 1549
				local pendingMessages = #activeMessages -- 1550
				emitAgentEvent( -- 1551
					shared, -- 1551
					{ -- 1551
						type = "memory_compression_started", -- 1552
						sessionId = shared.sessionId, -- 1553
						taskId = shared.taskId, -- 1554
						step = stepId, -- 1555
						tool = "compress_memory", -- 1556
						reason = getMemoryCompressionStartReason(shared), -- 1557
						params = { -- 1558
							round = compressionRound, -- 1559
							maxRounds = maxRounds, -- 1560
							pendingMessages = pendingMessages, -- 1561
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1562
							uncoveredMessages = #uncoveredMessages -- 1563
						} -- 1563
					} -- 1563
				) -- 1563
				local result = __TS__Await(memory.compressor:compress( -- 1566
					activeMessages, -- 1567
					shared.llmOptions, -- 1568
					shared.llmMaxTry, -- 1569
					shared.decisionMode, -- 1570
					{ -- 1571
						onInput = function(____, phase, messages, options) -- 1572
							saveStepLLMDebugInput( -- 1573
								shared, -- 1573
								stepId, -- 1573
								phase, -- 1573
								messages, -- 1573
								options -- 1573
							) -- 1573
						end, -- 1572
						onOutput = function(____, phase, text, meta) -- 1575
							saveStepLLMDebugOutput( -- 1576
								shared, -- 1576
								stepId, -- 1576
								phase, -- 1576
								text, -- 1576
								meta -- 1576
							) -- 1576
						end, -- 1575
						onUsage = function(____, phase, usage) -- 1578
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1579
						end -- 1578
					}, -- 1578
					"default", -- 1582
					systemPrompt, -- 1583
					toolDefinitions -- 1584
				)) -- 1584
				if not (result and result.success and result.compressedCount > 0) then -- 1584
					emitAgentEvent( -- 1587
						shared, -- 1587
						{ -- 1587
							type = "memory_compression_finished", -- 1588
							sessionId = shared.sessionId, -- 1589
							taskId = shared.taskId, -- 1590
							step = stepId, -- 1591
							tool = "compress_memory", -- 1592
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1593
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1597
						} -- 1597
					) -- 1597
					if changed then -- 1597
						persistHistoryState(shared) -- 1605
					end -- 1605
					return ____awaiter_resolve(nil) -- 1605
				end -- 1605
				local effectiveCompressedCount = math.max( -- 1609
					0, -- 1610
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1611
				) -- 1611
				if effectiveCompressedCount <= 0 then -- 1611
					if changed then -- 1611
						persistHistoryState(shared) -- 1615
					end -- 1615
					return ____awaiter_resolve(nil) -- 1615
				end -- 1615
				emitAgentEvent( -- 1619
					shared, -- 1619
					{ -- 1619
						type = "memory_compression_finished", -- 1620
						sessionId = shared.sessionId, -- 1621
						taskId = shared.taskId, -- 1622
						step = stepId, -- 1623
						tool = "compress_memory", -- 1624
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1625
						result = { -- 1626
							success = true, -- 1627
							round = compressionRound, -- 1628
							compressedCount = effectiveCompressedCount, -- 1629
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1630
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1631
						} -- 1631
					} -- 1631
				) -- 1631
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1634
				changed = true -- 1635
				Log( -- 1636
					"Info", -- 1636
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1636
				) -- 1636
				round = round + 1 -- 1503
			end -- 1503
		end -- 1503
		if changed then -- 1503
			persistHistoryState(shared) -- 1639
		end -- 1639
	end) -- 1639
end -- 1495
local function compactAllHistory(shared) -- 1643
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1643
		local ____shared_44 = shared -- 1644
		local memory = ____shared_44.memory -- 1644
		local rounds = 0 -- 1645
		local totalCompressed = 0 -- 1646
		while getActiveRealMessageCount(shared) > 0 do -- 1646
			if shared.stopToken.stopped then -- 1646
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1649
				return ____awaiter_resolve( -- 1649
					nil, -- 1649
					emitAgentTaskFinishEvent( -- 1650
						shared, -- 1650
						false, -- 1650
						getCancelledReason(shared) -- 1650
					) -- 1650
				) -- 1650
			end -- 1650
			rounds = rounds + 1 -- 1652
			shared.step = shared.step + 1 -- 1653
			local stepId = shared.step -- 1654
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1655
			local pendingMessages = #activeMessages -- 1656
			emitAgentEvent( -- 1657
				shared, -- 1657
				{ -- 1657
					type = "memory_compression_started", -- 1658
					sessionId = shared.sessionId, -- 1659
					taskId = shared.taskId, -- 1660
					step = stepId, -- 1661
					tool = "compress_memory", -- 1662
					reason = getMemoryCompressionStartReason(shared), -- 1663
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1664
				} -- 1664
			) -- 1664
			local result = __TS__Await(memory.compressor:compress( -- 1671
				activeMessages, -- 1672
				shared.llmOptions, -- 1673
				shared.llmMaxTry, -- 1674
				shared.decisionMode, -- 1675
				{ -- 1676
					onInput = function(____, phase, messages, options) -- 1677
						saveStepLLMDebugInput( -- 1678
							shared, -- 1678
							stepId, -- 1678
							phase, -- 1678
							messages, -- 1678
							options -- 1678
						) -- 1678
					end, -- 1677
					onOutput = function(____, phase, text, meta) -- 1680
						saveStepLLMDebugOutput( -- 1681
							shared, -- 1681
							stepId, -- 1681
							phase, -- 1681
							text, -- 1681
							meta -- 1681
						) -- 1681
					end, -- 1680
					onUsage = function(____, phase, usage) -- 1683
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1684
					end -- 1683
				}, -- 1683
				"budget_max" -- 1687
			)) -- 1687
			if not (result and result.success and result.compressedCount > 0) then -- 1687
				emitAgentEvent( -- 1690
					shared, -- 1690
					{ -- 1690
						type = "memory_compression_finished", -- 1691
						sessionId = shared.sessionId, -- 1692
						taskId = shared.taskId, -- 1693
						step = stepId, -- 1694
						tool = "compress_memory", -- 1695
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1696
						result = { -- 1700
							success = false, -- 1701
							rounds = rounds, -- 1702
							error = result and result.error or "compression returned no changes", -- 1703
							compressedCount = result and result.compressedCount or 0, -- 1704
							fullCompaction = true -- 1705
						} -- 1705
					} -- 1705
				) -- 1705
				return ____awaiter_resolve( -- 1705
					nil, -- 1705
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1708
				) -- 1708
			end -- 1708
			local effectiveCompressedCount = math.max( -- 1713
				0, -- 1714
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1715
			) -- 1715
			if effectiveCompressedCount <= 0 then -- 1715
				return ____awaiter_resolve( -- 1715
					nil, -- 1715
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1718
				) -- 1718
			end -- 1718
			emitAgentEvent( -- 1725
				shared, -- 1725
				{ -- 1725
					type = "memory_compression_finished", -- 1726
					sessionId = shared.sessionId, -- 1727
					taskId = shared.taskId, -- 1728
					step = stepId, -- 1729
					tool = "compress_memory", -- 1730
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1731
					result = { -- 1732
						success = true, -- 1733
						round = rounds, -- 1734
						compressedCount = effectiveCompressedCount, -- 1735
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1736
						fullCompaction = true -- 1737
					} -- 1737
				} -- 1737
			) -- 1737
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1740
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1741
			persistHistoryState(shared) -- 1742
			Log( -- 1743
				"Info", -- 1743
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1743
			) -- 1743
		end -- 1743
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1745
		return ____awaiter_resolve( -- 1745
			nil, -- 1745
			emitAgentTaskFinishEvent( -- 1746
				shared, -- 1747
				true, -- 1748
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1749
			) -- 1749
		) -- 1749
	end) -- 1749
end -- 1643
local function clearSessionHistory(shared) -- 1755
	shared.messages = {} -- 1756
	shared.lastConsolidatedIndex = 0 -- 1757
	shared.carryMessageIndex = nil -- 1758
	persistHistoryState(shared) -- 1759
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1760
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1761
end -- 1755
COMPLETION_TEXT_MAX_CHARS = 800 -- 1783
COMPLETION_LIST_MAX_ITEMS = 12 -- 1784
COMPLETION_EVIDENCE_MAX_ITEMS = 8 -- 1785
local function appendConversationMessage(shared, message) -- 1980
	local ____shared_messages_53 = shared.messages -- 1980
	____shared_messages_53[#____shared_messages_53 + 1] = __TS__ObjectAssign( -- 1981
		{}, -- 1981
		message, -- 1982
		{ -- 1981
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1983
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1984
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1985
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1986
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1987
		} -- 1987
	) -- 1987
end -- 1980
local function appendToolResultMessage(shared, action) -- 1996
	appendConversationMessage( -- 1997
		shared, -- 1997
		{ -- 1997
			role = "tool", -- 1998
			tool_call_id = action.toolCallId, -- 1999
			name = action.tool, -- 2000
			content = action.result and toJson(action.result, false) or "" -- 2001
		} -- 2001
	) -- 2001
end -- 1996
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 2005
	appendConversationMessage( -- 2011
		shared, -- 2011
		{ -- 2011
			role = "assistant", -- 2012
			content = content or "", -- 2013
			reasoning_content = reasoningContent, -- 2014
			tool_calls = __TS__ArrayMap( -- 2015
				actions, -- 2015
				function(____, action) return { -- 2015
					id = action.toolCallId, -- 2016
					type = "function", -- 2017
					["function"] = { -- 2018
						name = action.tool, -- 2019
						arguments = toJson(action.params, false) -- 2020
					} -- 2020
				} end -- 2020
			) -- 2020
		} -- 2020
	) -- 2020
end -- 2005
local function llm(shared, messages, phase) -- 2204
	if phase == nil then -- 2204
		phase = "decision_xml" -- 2207
	end -- 2207
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2207
		local stepId = shared.step + 1 -- 2209
		emitLLMContextMetrics( -- 2210
			shared, -- 2210
			stepId, -- 2210
			phase, -- 2210
			messages, -- 2210
			shared.llmOptions -- 2210
		) -- 2210
		saveStepLLMDebugInput( -- 2211
			shared, -- 2211
			stepId, -- 2211
			phase, -- 2211
			messages, -- 2211
			shared.llmOptions -- 2211
		) -- 2211
		local lastStreamReasoning = "" -- 2212
		local res = __TS__Await(callLLMStreamAggregated( -- 2213
			messages, -- 2214
			shared.llmOptions, -- 2215
			shared.stopToken, -- 2216
			shared.llmConfig, -- 2217
			function(response) -- 2218
				local ____opt_57 = response.choices -- 2218
				local ____opt_55 = ____opt_57 and ____opt_57[1] -- 2218
				local streamMessage = ____opt_55 and ____opt_55.message -- 2219
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2220
				if nextContent == "" then -- 2220
					return -- 2223
				end -- 2223
				if nextContent == lastStreamReasoning then -- 2223
					return -- 2224
				end -- 2224
				lastStreamReasoning = nextContent -- 2225
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2226
			end -- 2218
		)) -- 2218
		if res.success then -- 2218
			local usage = res.tokenUsage -- 2230
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2231
			local ____opt_63 = res.response.choices -- 2231
			local ____opt_61 = ____opt_63 and ____opt_63[1] -- 2231
			local message = ____opt_61 and ____opt_61.message -- 2232
			local text = message and message.content -- 2233
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 2234
			if text then -- 2234
				local parsed = tryParseAndValidateDecision(text, shared) -- 2238
				if parsed.success then -- 2238
					local reason = parsed.reason or "" -- 2240
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2241
				end -- 2241
				saveStepLLMDebugOutput( -- 2243
					shared, -- 2243
					stepId, -- 2243
					phase, -- 2243
					text, -- 2243
					{success = true, usage = usage} -- 2243
				) -- 2243
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2243
			else -- 2243
				saveStepLLMDebugOutput( -- 2246
					shared, -- 2246
					stepId, -- 2246
					phase, -- 2246
					"empty LLM response", -- 2246
					{success = false, usage = usage} -- 2246
				) -- 2246
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2246
			end -- 2246
		else -- 2246
			local usage = res.tokenUsage -- 2250
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2251
			saveStepLLMDebugOutput( -- 2252
				shared, -- 2252
				stepId, -- 2252
				phase, -- 2252
				res.raw or res.message, -- 2252
				{success = false, usage = usage} -- 2252
			) -- 2252
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2252
		end -- 2252
	end) -- 2252
end -- 2204
local function isDecisionBatchSuccess(result) -- 2276
	return result.kind == "batch" -- 2277
end -- 2276
local function parseDecisionToolCall(functionName, rawObj) -- 2301
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2301
		return {success = false, message = "unknown tool: " .. functionName} -- 2303
	end -- 2303
	if rawObj == nil then -- 2303
		return {success = true, tool = functionName, params = {}} -- 2306
	end -- 2306
	if not isRecord(rawObj) then -- 2306
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2309
	end -- 2309
	return {success = true, tool = functionName, params = rawObj} -- 2311
end -- 2301
local function parseToolCallArguments(functionName, argsText) -- 2318
	local trimmedArgs = __TS__StringTrim(argsText) -- 2319
	if trimmedArgs == "" then -- 2319
		return {} -- 2321
	end -- 2321
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 2323
	if err ~= nil or rawObj == nil then -- 2323
		return { -- 2325
			success = false, -- 2326
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2327
			raw = argsText -- 2328
		} -- 2328
	end -- 2328
	local encodedRaw = safeJsonEncode(rawObj) -- 2331
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2331
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2333
	end -- 2333
	return rawObj -- 2339
end -- 2318
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2342
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2350
	if isRecord(rawArgs) and rawArgs.success == false then -- 2350
		return rawArgs -- 2352
	end -- 2352
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2354
	if not decision.success then -- 2354
		return {success = false, message = decision.message, raw = argsText} -- 2356
	end -- 2356
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2362
	if not completionValidation.success then -- 2362
		return {success = false, message = completionValidation.message, raw = argsText} -- 2364
	end -- 2364
	local validation = validateDecision(decision.tool, decision.params) -- 2370
	if not validation.success then -- 2370
		return {success = false, message = validation.message, raw = argsText} -- 2372
	end -- 2372
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2378
	if not sharedValidation.success then -- 2378
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2380
	end -- 2380
	decision.params = validation.params -- 2386
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2387
	decision.reason = reason -- 2388
	decision.reasoningContent = reasoningContent -- 2389
	return decision -- 2390
end -- 2342
local function createPreExecutableActionFromStream(shared, toolCall) -- 2393
	local ____opt_69 = toolCall["function"] -- 2393
	local functionName = ____opt_69 and ____opt_69.name -- 2394
	local ____opt_71 = toolCall["function"] -- 2394
	local argsText = ____opt_71 and ____opt_71.arguments or "" -- 2395
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2396
	if not functionName or not toolCallId then -- 2396
		return nil -- 2397
	end -- 2397
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2398
	if isRecord(rawArgs) and rawArgs.success == false then -- 2398
		return nil -- 2399
	end -- 2399
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2400
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2400
		return nil -- 2401
	end -- 2401
	local validation = validateDecision(decision.tool, decision.params) -- 2402
	if not validation.success then -- 2402
		return nil -- 2403
	end -- 2403
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2403
		return nil -- 2404
	end -- 2404
	return { -- 2405
		step = shared.step + 1, -- 2406
		toolCallId = toolCallId, -- 2407
		tool = decision.tool, -- 2408
		reason = "", -- 2409
		params = validation.params, -- 2410
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2411
	} -- 2411
end -- 2393
local function sanitizeMessagesForLLMInput(messages) -- 2658
	local sanitized = {} -- 2659
	local droppedAssistantToolCalls = 0 -- 2660
	local droppedToolResults = 0 -- 2661
	do -- 2661
		local i = 0 -- 2662
		while i < #messages do -- 2662
			do -- 2662
				local message = messages[i + 1] -- 2663
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2663
					local requiredIds = {} -- 2665
					do -- 2665
						local j = 0 -- 2666
						while j < #message.tool_calls do -- 2666
							local toolCall = message.tool_calls[j + 1] -- 2667
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2668
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2668
								requiredIds[#requiredIds + 1] = id -- 2670
							end -- 2670
							j = j + 1 -- 2666
						end -- 2666
					end -- 2666
					if #requiredIds == 0 then -- 2666
						sanitized[#sanitized + 1] = message -- 2674
						goto __continue467 -- 2675
					end -- 2675
					local matchedIds = {} -- 2677
					local matchedTools = {} -- 2678
					local j = i + 1 -- 2679
					while j < #messages do -- 2679
						local toolMessage = messages[j + 1] -- 2681
						if toolMessage.role ~= "tool" then -- 2681
							break -- 2682
						end -- 2682
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2683
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2683
							matchedIds[toolCallId] = true -- 2685
							matchedTools[#matchedTools + 1] = toolMessage -- 2686
						else -- 2686
							droppedToolResults = droppedToolResults + 1 -- 2688
						end -- 2688
						j = j + 1 -- 2690
					end -- 2690
					local complete = true -- 2692
					do -- 2692
						local j = 0 -- 2693
						while j < #requiredIds do -- 2693
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2693
								complete = false -- 2695
								break -- 2696
							end -- 2696
							j = j + 1 -- 2693
						end -- 2693
					end -- 2693
					if complete then -- 2693
						__TS__ArrayPush( -- 2700
							sanitized, -- 2700
							message, -- 2700
							table.unpack(matchedTools) -- 2700
						) -- 2700
					else -- 2700
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2702
						droppedToolResults = droppedToolResults + #matchedTools -- 2703
					end -- 2703
					i = j - 1 -- 2705
					goto __continue467 -- 2706
				end -- 2706
				if message.role == "tool" then -- 2706
					droppedToolResults = droppedToolResults + 1 -- 2709
					goto __continue467 -- 2710
				end -- 2710
				sanitized[#sanitized + 1] = message -- 2712
			end -- 2712
			::__continue467:: -- 2712
			i = i + 1 -- 2662
		end -- 2662
	end -- 2662
	return sanitized -- 2714
end -- 2658
local function getUnconsolidatedMessages(shared) -- 2717
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2718
end -- 2717
local function getFinalDecisionTurnPrompt(shared) -- 2727
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2728
end -- 2727
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2733
	if attempt == nil then -- 2733
		attempt = 1 -- 2736
	end -- 2736
	if decisionMode == nil then -- 2736
		decisionMode = shared.decisionMode -- 2738
	end -- 2738
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2740
	local tailSections = {} -- 2741
	if shared.resumeCheckpointPending == true then -- 2741
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2743
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2746
	end -- 2746
	if shared.truncatedToolOverwritePath ~= nil then -- 2746
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2749
	end -- 2749
	shared.resumeCheckpointPending = false -- 2751
	local messages = { -- 2752
		{role = "system", content = systemPrompt}, -- 2753
		table.unpack(getUnconsolidatedMessages(shared)) -- 2754
	} -- 2754
	if isFinalDecisionTurn(shared) then -- 2754
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2757
	end -- 2757
	if lastError and lastError ~= "" then -- 2757
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2760
		if decisionMode == "xml" then -- 2760
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2764
		end -- 2764
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2764
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2767
		end -- 2767
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2767
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2770
		end -- 2770
		messages[#messages + 1] = { -- 2772
			role = "user", -- 2773
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2774
		} -- 2774
	end -- 2774
	tailSections[#tailSections + 1] = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2781
		role = shared.role, -- 2782
		workMode = shared.workMode, -- 2783
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2784
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2785
		resumeRequiredTool = shared.resumeRequiredTool, -- 2786
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2787
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2788
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2789
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2790
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2791
		buildRepairPending = shared.buildRepairPending, -- 2792
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2793
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2794
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2795
	}) -- 2795
	messages[#messages + 1] = { -- 2797
		role = "user", -- 2798
		content = table.concat(tailSections, "\n\n") -- 2799
	} -- 2799
	return messages -- 2801
end -- 2733
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2808
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2817
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2818
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2826
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2827
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2828
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2836
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2844
		shared.role, -- 2844
		{ -- 2844
			includeFinish = true, -- 2845
			includeXmlRules = true, -- 2846
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2847
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2848
			workMode = shared.workMode -- 2849
		} -- 2849
	) -- 2849
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2851
	local repairPrompt = replacePromptVars( -- 2854
		shared.promptPack.xmlDecisionRepairPrompt, -- 2854
		{ -- 2854
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2855
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2856
			CANDIDATE_SECTION = candidateSection, -- 2857
			LAST_ERROR = lastError, -- 2858
			ATTEMPT = tostring(attempt) -- 2859
		} -- 2859
	) -- 2859
	local availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2861
		role = shared.role, -- 2862
		workMode = shared.workMode, -- 2863
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2864
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2865
		resumeRequiredTool = shared.resumeRequiredTool, -- 2866
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2867
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2868
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2869
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2870
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2871
		buildRepairPending = shared.buildRepairPending, -- 2872
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2873
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2874
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2875
	}) -- 2875
	return {{role = "system", content = systemPrompt}, {role = "user", content = (repairPrompt .. "\n\n") .. availabilityPrompt}} -- 2877
end -- 2808
local function replaceFirst(text, oldStr, newStr) -- 2915
	if oldStr == "" then -- 2915
		return text -- 2916
	end -- 2916
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2917
	if idx < 0 then -- 2917
		return text -- 2918
	end -- 2918
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2919
end -- 2915
local function splitLines(text) -- 2922
	return __TS__StringSplit(text, "\n") -- 2923
end -- 2922
local function getLeadingWhitespace(text) -- 2926
	local i = 0 -- 2927
	while i < #text do -- 2927
		local ch = __TS__StringAccess(text, i) -- 2929
		if ch ~= " " and ch ~= "\t" then -- 2929
			break -- 2930
		end -- 2930
		i = i + 1 -- 2931
	end -- 2931
	return __TS__StringSubstring(text, 0, i) -- 2933
end -- 2926
local function getCommonIndentPrefix(lines) -- 2936
	local common -- 2937
	do -- 2937
		local i = 0 -- 2938
		while i < #lines do -- 2938
			do -- 2938
				local line = lines[i + 1] -- 2939
				if __TS__StringTrim(line) == "" then -- 2939
					goto __continue511 -- 2940
				end -- 2940
				local indent = getLeadingWhitespace(line) -- 2941
				if common == nil then -- 2941
					common = indent -- 2943
					goto __continue511 -- 2944
				end -- 2944
				local j = 0 -- 2946
				local maxLen = math.min(#common, #indent) -- 2947
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2947
					j = j + 1 -- 2949
				end -- 2949
				common = __TS__StringSubstring(common, 0, j) -- 2951
				if common == "" then -- 2951
					break -- 2952
				end -- 2952
			end -- 2952
			::__continue511:: -- 2952
			i = i + 1 -- 2938
		end -- 2938
	end -- 2938
	return common or "" -- 2954
end -- 2936
local function removeIndentPrefix(line, indent) -- 2957
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2957
		return __TS__StringSubstring(line, #indent) -- 2959
	end -- 2959
	local lineIndent = getLeadingWhitespace(line) -- 2961
	local j = 0 -- 2962
	local maxLen = math.min(#lineIndent, #indent) -- 2963
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2963
		j = j + 1 -- 2965
	end -- 2965
	return __TS__StringSubstring(line, j) -- 2967
end -- 2957
local function dedentLines(lines) -- 2970
	local indent = getCommonIndentPrefix(lines) -- 2971
	return { -- 2972
		indent = indent, -- 2973
		lines = __TS__ArrayMap( -- 2974
			lines, -- 2974
			function(____, line) return removeIndentPrefix(line, indent) end -- 2974
		) -- 2974
	} -- 2974
end -- 2970
local function joinLines(lines) -- 2978
	return table.concat(lines, "\n") -- 2979
end -- 2978
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2982
	local function findWhitespaceTolerantReplacement() -- 2987
		local function foldWhitespace(text, withMap) -- 2989
			local parts = {} -- 2990
			local map = {} -- 2991
			local i = 0 -- 2992
			while i < #text do -- 2992
				local ch = __TS__StringAccess(text, i) -- 2994
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2994
					local start = i -- 2996
					while i < #text do -- 2996
						local next = __TS__StringAccess(text, i) -- 2998
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2998
							break -- 2999
						end -- 2999
						i = i + 1 -- 3000
					end -- 3000
					parts[#parts + 1] = " " -- 3002
					if withMap then -- 3002
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 3003
					end -- 3003
				else -- 3003
					parts[#parts + 1] = ch -- 3005
					if withMap then -- 3005
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 3006
					end -- 3006
					i = i + 1 -- 3007
				end -- 3007
			end -- 3007
			return { -- 3010
				text = table.concat(parts, ""), -- 3010
				map = map -- 3010
			} -- 3010
		end -- 2989
		local foldedContent = foldWhitespace(content, true) -- 3012
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 3013
		if foldedOld == "" then -- 3013
			return {success = false, message = "old_str not found in file"} -- 3015
		end -- 3015
		local matches = {} -- 3017
		local pos = 0 -- 3018
		while true do -- 3018
			local idx = (string.find( -- 3020
				foldedContent.text, -- 3020
				foldedOld, -- 3020
				math.max(pos + 1, 1), -- 3020
				true -- 3020
			) or 0) - 1 -- 3020
			if idx < 0 then -- 3020
				break -- 3021
			end -- 3021
			local lastIdx = idx + #foldedOld - 1 -- 3022
			local startMap = foldedContent.map[idx + 1] -- 3023
			local endMap = foldedContent.map[lastIdx + 1] -- 3024
			if startMap ~= nil and endMap ~= nil then -- 3024
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 3026
			end -- 3026
			pos = idx + #foldedOld -- 3028
		end -- 3028
		if #matches == 0 then -- 3028
			return {success = false, message = "old_str not found in file"} -- 3031
		end -- 3031
		if #matches > 1 then -- 3031
			return { -- 3034
				success = false, -- 3035
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 3036
			} -- 3036
		end -- 3036
		local match = matches[1] -- 3039
		return { -- 3040
			success = true, -- 3041
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 3042
		} -- 3042
	end -- 2987
	local contentLines = splitLines(content) -- 3045
	local oldLines = splitLines(oldStr) -- 3046
	if #oldLines == 0 then -- 3046
		return {success = false, message = "old_str not found in file"} -- 3048
	end -- 3048
	local dedentedOld = dedentLines(oldLines) -- 3050
	local dedentedOldText = joinLines(dedentedOld.lines) -- 3051
	local dedentedNew = dedentLines(splitLines(newStr)) -- 3052
	local matches = {} -- 3053
	do -- 3053
		local start = 0 -- 3054
		while start <= #contentLines - #oldLines do -- 3054
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 3055
			local dedentedCandidate = dedentLines(candidateLines) -- 3056
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 3056
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 3058
			end -- 3058
			start = start + 1 -- 3054
		end -- 3054
	end -- 3054
	if #matches == 0 then -- 3054
		return findWhitespaceTolerantReplacement() -- 3066
	end -- 3066
	if #matches > 1 then -- 3066
		return { -- 3069
			success = false, -- 3070
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 3071
		} -- 3071
	end -- 3071
	local match = matches[1] -- 3074
	local rebuiltNewLines = __TS__ArrayMap( -- 3075
		dedentedNew.lines, -- 3075
		function(____, line) return line == "" and "" or match.indent .. line end -- 3075
	) -- 3075
	local ____array_77 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 3075
	__TS__SparseArrayPush( -- 3075
		____array_77, -- 3075
		table.unpack(rebuiltNewLines) -- 3078
	) -- 3078
	__TS__SparseArrayPush( -- 3078
		____array_77, -- 3078
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 3079
	) -- 3079
	local nextLines = {__TS__SparseArraySpread(____array_77)} -- 3076
	return { -- 3081
		success = true, -- 3081
		content = joinLines(nextLines) -- 3081
	} -- 3081
end -- 2982
local MainDecisionAgent = __TS__Class() -- 3084
MainDecisionAgent.name = "MainDecisionAgent" -- 3084
__TS__ClassExtends(MainDecisionAgent, Node) -- 3084
function MainDecisionAgent.prototype.prep(self, shared) -- 3085
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3085
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 3085
			return ____awaiter_resolve(nil, {shared = shared}) -- 3085
		end -- 3085
		__TS__Await(maybeCompressHistory(shared)) -- 3090
		return ____awaiter_resolve(nil, {shared = shared}) -- 3090
	end) -- 3090
end -- 3085
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 3095
	local preExecuted = shared.preExecutedResults -- 3096
	if not preExecuted or preExecuted.size == 0 then -- 3096
		return nil -- 3097
	end -- 3097
	local decisions = {} -- 3098
	preExecuted:forEach(function(____, preResult) -- 3099
		local action = preResult.action -- 3100
		decisions[#decisions + 1] = { -- 3101
			success = true, -- 3102
			tool = action.tool, -- 3103
			params = action.params, -- 3104
			toolCallId = action.toolCallId, -- 3105
			reason = action.reason, -- 3106
			reasoningContent = action.reasoningContent -- 3107
		} -- 3107
	end) -- 3099
	if #decisions == 0 then -- 3099
		return nil -- 3110
	end -- 3110
	Log( -- 3111
		"Warn", -- 3111
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 3111
			__TS__ArrayMap( -- 3111
				decisions, -- 3111
				function(____, decision) return decision.tool end -- 3111
			), -- 3111
			"," -- 3111
		) -- 3111
	) -- 3111
	if #decisions == 1 then -- 3111
		return decisions[1] -- 3113
	end -- 3113
	return {success = true, kind = "batch", decisions = decisions} -- 3115
end -- 3095
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 3122
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 3127
	if not recovery then -- 3127
		return nil -- 3128
	end -- 3128
	shared.truncatedToolOverwritePath = recovery.target -- 3129
	Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 3130
	return { -- 3131
		success = true, -- 3132
		tool = "edit_file", -- 3133
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 3134
		toolCallId = createLocalToolCallId(), -- 3140
		reason = recovery.reason, -- 3141
		reasoningContent = reasoningContent -- 3142
	} -- 3142
end -- 3122
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 3146
	if attempt == nil then -- 3146
		attempt = 1 -- 3149
	end -- 3149
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3149
		if shared.stopToken.stopped then -- 3149
			return ____awaiter_resolve( -- 3149
				nil, -- 3149
				{ -- 3153
					success = false, -- 3153
					message = getCancelledReason(shared) -- 3153
				} -- 3153
			) -- 3153
		end -- 3153
		Log( -- 3155
			"Info", -- 3155
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 3155
		) -- 3155
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 3156
			shared.role, -- 3156
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 3156
			{ -- 3156
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 3157
				workMode = shared.workMode -- 3158
			} -- 3158
		) -- 3158
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 3160
		local stepId = shared.step + 1 -- 3161
		local useFastGlmToolDecision = __TS__StringIncludes( -- 3162
			string.lower(shared.llmConfig.model), -- 3162
			"glm-5.2" -- 3162
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 3162
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 3165
		emitLLMContextMetrics( -- 3170
			shared, -- 3170
			stepId, -- 3170
			"decision_tool_calling", -- 3170
			messages, -- 3170
			llmOptions -- 3170
		) -- 3170
		saveStepLLMDebugInput( -- 3171
			shared, -- 3171
			stepId, -- 3171
			"decision_tool_calling", -- 3171
			messages, -- 3171
			llmOptions -- 3171
		) -- 3171
		local lastStreamContent = "" -- 3172
		local lastStreamReasoning = "" -- 3173
		local preExecutedResults = __TS__New(Map) -- 3174
		shared.preExecutedResults = preExecutedResults -- 3175
		local res = __TS__Await(callLLMStreamAggregated( -- 3176
			messages, -- 3177
			llmOptions, -- 3178
			shared.stopToken, -- 3179
			shared.llmConfig, -- 3180
			function(response) -- 3181
				local ____opt_80 = response.choices -- 3181
				local ____opt_78 = ____opt_80 and ____opt_80[1] -- 3181
				local streamMessage = ____opt_78 and ____opt_78.message -- 3182
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 3183
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 3186
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 3186
					return -- 3190
				end -- 3190
				lastStreamContent = nextContent -- 3192
				lastStreamReasoning = nextReasoning -- 3193
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 3194
			end, -- 3181
			function(tc) -- 3196
				if shared.stopToken.stopped then -- 3196
					return -- 3197
				end -- 3197
				local action = createPreExecutableActionFromStream(shared, tc) -- 3198
				if not action or preExecutedResults:has(action.toolCallId) then -- 3198
					return -- 3199
				end -- 3199
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 3200
				preExecutedResults:set( -- 3201
					action.toolCallId, -- 3201
					createPreExecutedToolResult(shared, action) -- 3201
				) -- 3201
			end -- 3196
		)) -- 3196
		if shared.stopToken.stopped then -- 3196
			clearPreExecutedResults(shared) -- 3205
			return ____awaiter_resolve( -- 3205
				nil, -- 3205
				{ -- 3206
					success = false, -- 3206
					message = getCancelledReason(shared) -- 3206
				} -- 3206
			) -- 3206
		end -- 3206
		if not res.success then -- 3206
			local usage = res.tokenUsage -- 3209
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3210
			saveStepLLMDebugOutput( -- 3211
				shared, -- 3211
				stepId, -- 3211
				"decision_tool_calling", -- 3211
				res.raw or res.message, -- 3211
				{success = false, usage = usage} -- 3211
			) -- 3211
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 3212
			local committed = self:commitPreExecutedDecision(shared) -- 3213
			if committed then -- 3213
				return ____awaiter_resolve(nil, committed) -- 3213
			end -- 3213
			local ____opt_88 = res.response -- 3213
			local ____opt_86 = ____opt_88 and ____opt_88.choices -- 3213
			local partialChoice = ____opt_86 and ____opt_86[1] -- 3215
			local ____self_preserveTruncatedEditDecision_100 = self.preserveTruncatedEditDecision -- 3216
			local ____shared_98 = shared -- 3217
			local ____opt_90 = partialChoice and partialChoice.message -- 3217
			local ____temp_99 = ____opt_90 and ____opt_90.tool_calls -- 3218
			local ____opt_94 = partialChoice and partialChoice.message -- 3218
			local partialDraft = ____self_preserveTruncatedEditDecision_100(self, ____shared_98, ____temp_99, ____opt_94 and ____opt_94.reasoning_content) -- 3216
			if partialDraft then -- 3216
				return ____awaiter_resolve(nil, partialDraft) -- 3216
			end -- 3216
			clearPreExecutedResults(shared) -- 3222
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 3222
		end -- 3222
		local usage = res.tokenUsage -- 3225
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3226
		saveStepLLMDebugOutput( -- 3227
			shared, -- 3227
			stepId, -- 3227
			"decision_tool_calling", -- 3227
			encodeDebugJSON(res.response), -- 3227
			{success = true, usage = usage} -- 3227
		) -- 3227
		local choice = res.response.choices and res.response.choices[1] -- 3228
		local message = choice and choice.message -- 3229
		local toolCalls = message and message.tool_calls -- 3230
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3231
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3234
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3237
		Log( -- 3240
			"Info", -- 3240
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3240
		) -- 3240
		if finishReason == "length" then -- 3240
			local committed = self:commitPreExecutedDecision(shared) -- 3242
			if committed then -- 3242
				return ____awaiter_resolve(nil, committed) -- 3242
			end -- 3242
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3244
			if partialDraft then -- 3244
				return ____awaiter_resolve(nil, partialDraft) -- 3244
			end -- 3244
			Log( -- 3246
				"Error", -- 3246
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3246
			) -- 3246
			clearPreExecutedResults(shared) -- 3247
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3247
		end -- 3247
		if not toolCalls or #toolCalls == 0 then -- 3247
			if messageContent and messageContent ~= "" then -- 3247
				if isFinalDecisionTurn(shared) then -- 3247
					clearPreExecutedResults(shared) -- 3257
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3257
				end -- 3257
				if shared.role == "sub" then -- 3257
					Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3265
					clearPreExecutedResults(shared) -- 3266
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3266
				end -- 3266
				Log( -- 3273
					"Info", -- 3273
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3273
				) -- 3273
				clearPreExecutedResults(shared) -- 3274
				return ____awaiter_resolve(nil, { -- 3274
					success = true, -- 3276
					tool = "finish", -- 3277
					params = {}, -- 3278
					reason = messageContent, -- 3279
					reasoningContent = reasoningContent, -- 3280
					directSummary = messageContent -- 3281
				}) -- 3281
			end -- 3281
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3284
			clearPreExecutedResults(shared) -- 3285
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3285
		end -- 3285
		local decisions = {} -- 3292
		do -- 3292
			local i = 0 -- 3293
			while i < #toolCalls do -- 3293
				local toolCall = toolCalls[i + 1] -- 3294
				local fn = toolCall ~= nil and toolCall["function"] -- 3295
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3295
					Log( -- 3297
						"Error", -- 3297
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3297
					) -- 3297
					clearPreExecutedResults(shared) -- 3298
					return ____awaiter_resolve( -- 3298
						nil, -- 3298
						{ -- 3299
							success = false, -- 3300
							message = "missing function name for tool call " .. tostring(i + 1), -- 3301
							raw = messageContent -- 3302
						} -- 3302
					) -- 3302
				end -- 3302
				local functionName = fn.name -- 3305
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3306
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3307
				Log( -- 3310
					"Info", -- 3310
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3310
				) -- 3310
				local decision = parseAndValidateToolCallDecision( -- 3311
					shared, -- 3312
					functionName, -- 3313
					argsText, -- 3314
					toolCallId, -- 3315
					messageContent, -- 3316
					reasoningContent -- 3317
				) -- 3317
				if not decision.success then -- 3317
					Log( -- 3320
						"Error", -- 3320
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3320
					) -- 3320
					clearPreExecutedResults(shared) -- 3321
					return ____awaiter_resolve(nil, decision) -- 3321
				end -- 3321
				decisions[#decisions + 1] = decision -- 3324
				i = i + 1 -- 3293
			end -- 3293
		end -- 3293
		if #decisions == 1 then -- 3293
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3327
			return ____awaiter_resolve(nil, decisions[1]) -- 3327
		end -- 3327
		do -- 3327
			local i = 0 -- 3330
			while i < #decisions do -- 3330
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3330
					clearPreExecutedResults(shared) -- 3332
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3332
				end -- 3332
				i = i + 1 -- 3330
			end -- 3330
		end -- 3330
		Log( -- 3340
			"Info", -- 3340
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3340
				__TS__ArrayMap( -- 3340
					decisions, -- 3340
					function(____, decision) return decision.tool end -- 3340
				), -- 3340
				"," -- 3340
			) -- 3340
		) -- 3340
		return ____awaiter_resolve(nil, { -- 3340
			success = true, -- 3342
			kind = "batch", -- 3343
			decisions = decisions, -- 3344
			content = messageContent, -- 3345
			reasoningContent = reasoningContent -- 3346
		}) -- 3346
	end) -- 3346
end -- 3146
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3350
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3350
		Log( -- 3356
			"Info", -- 3356
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3356
		) -- 3356
		local lastError = initialError -- 3357
		local candidateRaw = "" -- 3358
		local candidateReasoning = nil -- 3359
		do -- 3359
			local attempt = 0 -- 3360
			while attempt < shared.llmMaxTry do -- 3360
				do -- 3360
					Log( -- 3361
						"Info", -- 3361
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3361
					) -- 3361
					local messages = buildXmlRepairMessages( -- 3362
						shared, -- 3363
						originalRaw, -- 3364
						originalReasoning, -- 3365
						candidateRaw, -- 3366
						candidateReasoning, -- 3367
						lastError, -- 3368
						attempt + 1 -- 3369
					) -- 3369
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3371
					if shared.stopToken.stopped then -- 3371
						return ____awaiter_resolve( -- 3371
							nil, -- 3371
							{ -- 3373
								success = false, -- 3373
								message = getCancelledReason(shared) -- 3373
							} -- 3373
						) -- 3373
					end -- 3373
					if not llmRes.success then -- 3373
						lastError = llmRes.message -- 3376
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3377
						goto __continue584 -- 3378
					end -- 3378
					candidateRaw = llmRes.text -- 3380
					candidateReasoning = llmRes.reasoningContent -- 3381
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3382
					if decision.success then -- 3382
						decision.reasoningContent = llmRes.reasoningContent -- 3384
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3385
						return ____awaiter_resolve(nil, decision) -- 3385
					end -- 3385
					lastError = decision.message -- 3388
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3389
				end -- 3389
				::__continue584:: -- 3389
				attempt = attempt + 1 -- 3360
			end -- 3360
		end -- 3360
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3391
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3391
	end) -- 3391
end -- 3350
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3399
	if attempt == nil then -- 3399
		attempt = 1 -- 3402
	end -- 3402
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3402
		local messages = buildDecisionMessages( -- 3405
			shared, -- 3406
			lastError, -- 3407
			attempt, -- 3408
			lastRaw, -- 3409
			"xml" -- 3410
		) -- 3410
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3412
		if shared.stopToken.stopped then -- 3412
			return ____awaiter_resolve( -- 3412
				nil, -- 3412
				{ -- 3414
					success = false, -- 3414
					message = getCancelledReason(shared) -- 3414
				} -- 3414
			) -- 3414
		end -- 3414
		if not llmRes.success then -- 3414
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3414
		end -- 3414
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3423
		if decision.success then -- 3423
			decision.reasoningContent = llmRes.reasoningContent -- 3425
			return ____awaiter_resolve(nil, decision) -- 3425
		end -- 3425
		return ____awaiter_resolve( -- 3425
			nil, -- 3425
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3428
		) -- 3428
	end) -- 3428
end -- 3399
function MainDecisionAgent.prototype.exec(self, input) -- 3431
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3431
		local shared = input.shared -- 3432
		if shared.stopToken.stopped then -- 3432
			return ____awaiter_resolve( -- 3432
				nil, -- 3432
				{ -- 3434
					success = false, -- 3434
					message = getCancelledReason(shared) -- 3434
				} -- 3434
			) -- 3434
		end -- 3434
		if shared.step >= shared.maxSteps then -- 3434
			Log( -- 3437
				"Warn", -- 3437
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3437
			) -- 3437
			return ____awaiter_resolve( -- 3437
				nil, -- 3437
				{ -- 3438
					success = false, -- 3438
					message = getMaxStepsReachedReason(shared) -- 3438
				} -- 3438
			) -- 3438
		end -- 3438
		if shared.decisionMode == "tool_calling" then -- 3438
			Log( -- 3442
				"Info", -- 3442
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3442
			) -- 3442
			local lastError = "tool calling validation failed" -- 3443
			local lastRaw = "" -- 3444
			local shouldFallbackToXml = false -- 3445
			do -- 3445
				local attempt = 0 -- 3446
				while attempt < shared.llmMaxTry do -- 3446
					Log( -- 3447
						"Info", -- 3447
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3447
					) -- 3447
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3448
					if shared.stopToken.stopped then -- 3448
						return ____awaiter_resolve( -- 3448
							nil, -- 3448
							{ -- 3455
								success = false, -- 3455
								message = getCancelledReason(shared) -- 3455
							} -- 3455
						) -- 3455
					end -- 3455
					if decision.success then -- 3455
						return ____awaiter_resolve(nil, decision) -- 3455
					end -- 3455
					lastError = decision.message -- 3460
					lastRaw = decision.raw or "" -- 3461
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3462
					if lastError == "missing tool call" then -- 3462
						shouldFallbackToXml = true -- 3464
						break -- 3465
					end -- 3465
					attempt = attempt + 1 -- 3446
				end -- 3446
			end -- 3446
			if shouldFallbackToXml then -- 3446
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3469
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3470
				do -- 3470
					local attempt = 0 -- 3471
					while attempt < shared.llmMaxTry do -- 3471
						Log( -- 3472
							"Info", -- 3472
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3472
						) -- 3472
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3473
						if shared.stopToken.stopped then -- 3473
							return ____awaiter_resolve( -- 3473
								nil, -- 3473
								{ -- 3480
									success = false, -- 3480
									message = getCancelledReason(shared) -- 3480
								} -- 3480
							) -- 3480
						end -- 3480
						if decision.success then -- 3480
							return ____awaiter_resolve(nil, decision) -- 3480
						end -- 3480
						lastError = decision.message -- 3485
						lastRaw = decision.raw or "" -- 3486
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3487
						attempt = attempt + 1 -- 3471
					end -- 3471
				end -- 3471
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3489
				return ____awaiter_resolve( -- 3489
					nil, -- 3489
					{ -- 3490
						success = false, -- 3490
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3490
					} -- 3490
				) -- 3490
			end -- 3490
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3492
			return ____awaiter_resolve( -- 3492
				nil, -- 3492
				{ -- 3493
					success = false, -- 3493
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3493
				} -- 3493
			) -- 3493
		end -- 3493
		local lastError = "xml validation failed" -- 3496
		local lastRaw = "" -- 3497
		do -- 3497
			local attempt = 0 -- 3498
			while attempt < shared.llmMaxTry do -- 3498
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3499
				if shared.stopToken.stopped then -- 3499
					return ____awaiter_resolve( -- 3499
						nil, -- 3499
						{ -- 3508
							success = false, -- 3508
							message = getCancelledReason(shared) -- 3508
						} -- 3508
					) -- 3508
				end -- 3508
				if decision.success then -- 3508
					return ____awaiter_resolve(nil, decision) -- 3508
				end -- 3508
				lastError = decision.message -- 3513
				lastRaw = decision.raw or "" -- 3514
				attempt = attempt + 1 -- 3498
			end -- 3498
		end -- 3498
		return ____awaiter_resolve( -- 3498
			nil, -- 3498
			{ -- 3516
				success = false, -- 3516
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3516
			} -- 3516
		) -- 3516
	end) -- 3516
end -- 3431
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3519
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3519
		local result = execRes -- 3520
		if not result.success then -- 3520
			if shared.stopToken.stopped then -- 3520
				shared.error = getCancelledReason(shared) -- 3523
				shared.done = true -- 3524
				return ____awaiter_resolve(nil, "done") -- 3524
			end -- 3524
			shared.error = result.message -- 3527
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3528
			shared.done = true -- 3529
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3530
			persistHistoryState(shared) -- 3534
			return ____awaiter_resolve(nil, "done") -- 3534
		end -- 3534
		if isDecisionBatchSuccess(result) then -- 3534
			local startStep = shared.step -- 3538
			local actions = {} -- 3539
			do -- 3539
				local i = 0 -- 3540
				while i < #result.decisions do -- 3540
					local decision = result.decisions[i + 1] -- 3541
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3542
					local step = startStep + i + 1 -- 3543
					local ____temp_101 -- 3544
					if i == 0 then -- 3544
						____temp_101 = decision.reason -- 3544
					else -- 3544
						____temp_101 = "" -- 3544
					end -- 3544
					local actionReason = ____temp_101 -- 3544
					local ____temp_102 -- 3545
					if i == 0 then -- 3545
						____temp_102 = decision.reasoningContent -- 3545
					else -- 3545
						____temp_102 = nil -- 3545
					end -- 3545
					local actionReasoningContent = ____temp_102 -- 3545
					emitAgentEvent(shared, { -- 3546
						type = "decision_made", -- 3547
						sessionId = shared.sessionId, -- 3548
						taskId = shared.taskId, -- 3549
						step = step, -- 3550
						tool = decision.tool, -- 3551
						reason = actionReason, -- 3552
						reasoningContent = actionReasoningContent, -- 3553
						params = decision.params -- 3554
					}) -- 3554
					local action = { -- 3556
						step = step, -- 3557
						toolCallId = toolCallId, -- 3558
						tool = decision.tool, -- 3559
						reason = actionReason or "", -- 3560
						reasoningContent = actionReasoningContent, -- 3561
						params = decision.params, -- 3562
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3563
					} -- 3563
					local ____shared_history_103 = shared.history -- 3563
					____shared_history_103[#____shared_history_103 + 1] = action -- 3565
					actions[#actions + 1] = action -- 3566
					i = i + 1 -- 3540
				end -- 3540
			end -- 3540
			shared.step = startStep + #actions -- 3568
			shared.pendingToolActions = actions -- 3569
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3570
			persistHistoryState(shared) -- 3576
			return ____awaiter_resolve(nil, "batch_tools") -- 3576
		end -- 3576
		if result.directSummary and result.directSummary ~= "" then -- 3576
			shared.response = result.directSummary -- 3580
			shared.completion = ____exports.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3581
			shared.done = true -- 3585
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3586
			persistHistoryState(shared) -- 3591
			return ____awaiter_resolve(nil, "done") -- 3591
		end -- 3591
		if result.tool == "finish" then -- 3591
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3595
			shared.response = finalMessage -- 3596
			shared.completion = getCompletionReport(result.params) -- 3597
			shared.done = true -- 3598
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3599
			persistHistoryState(shared) -- 3604
			return ____awaiter_resolve(nil, "done") -- 3604
		end -- 3604
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3607
		shared.step = shared.step + 1 -- 3608
		local step = shared.step -- 3609
		emitAgentEvent(shared, { -- 3610
			type = "decision_made", -- 3611
			sessionId = shared.sessionId, -- 3612
			taskId = shared.taskId, -- 3613
			step = step, -- 3614
			tool = result.tool, -- 3615
			reason = result.reason, -- 3616
			reasoningContent = result.reasoningContent, -- 3617
			params = result.params -- 3618
		}) -- 3618
		local ____shared_history_104 = shared.history -- 3618
		____shared_history_104[#____shared_history_104 + 1] = { -- 3620
			step = step, -- 3621
			toolCallId = toolCallId, -- 3622
			tool = result.tool, -- 3623
			reason = result.reason or "", -- 3624
			reasoningContent = result.reasoningContent, -- 3625
			params = result.params, -- 3626
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3627
		} -- 3627
		local action = shared.history[#shared.history] -- 3629
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3630
		shared.pendingToolActions = {action} -- 3633
		persistHistoryState(shared) -- 3634
		return ____awaiter_resolve(nil, "batch_tools") -- 3634
	end) -- 3634
end -- 3519
local ReadFileAction = __TS__Class() -- 3639
ReadFileAction.name = "ReadFileAction" -- 3639
__TS__ClassExtends(ReadFileAction, Node) -- 3639
function ReadFileAction.prototype.prep(self, shared) -- 3640
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3640
		local last = shared.history[#shared.history] -- 3641
		if not last then -- 3641
			error( -- 3642
				__TS__New(Error, "no history"), -- 3642
				0 -- 3642
			) -- 3642
		end -- 3642
		emitAgentStartEvent(shared, last) -- 3643
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3644
		if __TS__StringTrim(path) == "" then -- 3644
			error( -- 3647
				__TS__New(Error, "missing path"), -- 3647
				0 -- 3647
			) -- 3647
		end -- 3647
		local ____path_107 = path -- 3649
		local ____shared_workingDir_108 = shared.workingDir -- 3651
		local ____temp_109 = shared.useChineseResponse and "zh" or "en" -- 3652
		local ____last_params_startLine_105 = last.params.startLine -- 3653
		if ____last_params_startLine_105 == nil then -- 3653
			____last_params_startLine_105 = 1 -- 3653
		end -- 3653
		local ____TS__Number_result_110 = __TS__Number(____last_params_startLine_105) -- 3653
		local ____last_params_endLine_106 = last.params.endLine -- 3654
		if ____last_params_endLine_106 == nil then -- 3654
			____last_params_endLine_106 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3654
		end -- 3654
		return ____awaiter_resolve( -- 3654
			nil, -- 3654
			{ -- 3648
				path = ____path_107, -- 3649
				tool = "read_file", -- 3650
				workDir = ____shared_workingDir_108, -- 3651
				docLanguage = ____temp_109, -- 3652
				startLine = ____TS__Number_result_110, -- 3653
				endLine = __TS__Number(____last_params_endLine_106) -- 3654
			} -- 3654
		) -- 3654
	end) -- 3654
end -- 3640
function ReadFileAction.prototype.exec(self, input) -- 3658
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3658
		return ____awaiter_resolve( -- 3658
			nil, -- 3658
			Tools.readFile( -- 3659
				input.workDir, -- 3660
				input.path, -- 3661
				__TS__Number(input.startLine or 1), -- 3662
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3663
				input.docLanguage -- 3664
			) -- 3664
		) -- 3664
	end) -- 3664
end -- 3658
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3668
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3668
		local result = execRes -- 3669
		local last = shared.history[#shared.history] -- 3670
		if last ~= nil then -- 3670
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3672
			appendToolResultMessage(shared, last) -- 3673
			emitAgentFinishEvent(shared, last) -- 3674
		end -- 3674
		persistHistoryState(shared) -- 3676
		__TS__Await(maybeCompressHistory(shared)) -- 3677
		persistHistoryState(shared) -- 3678
		return ____awaiter_resolve(nil, "main") -- 3678
	end) -- 3678
end -- 3668
local SearchFilesAction = __TS__Class() -- 3683
SearchFilesAction.name = "SearchFilesAction" -- 3683
__TS__ClassExtends(SearchFilesAction, Node) -- 3683
function SearchFilesAction.prototype.prep(self, shared) -- 3684
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3684
		local last = shared.history[#shared.history] -- 3685
		if not last then -- 3685
			error( -- 3686
				__TS__New(Error, "no history"), -- 3686
				0 -- 3686
			) -- 3686
		end -- 3686
		emitAgentStartEvent(shared, last) -- 3687
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3687
	end) -- 3687
end -- 3684
function SearchFilesAction.prototype.exec(self, input) -- 3691
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3691
		local params = input.params -- 3692
		local ____Tools_searchFiles_125 = Tools.searchFiles -- 3693
		local ____input_workDir_117 = input.workDir -- 3694
		local ____temp_118 = params.path or "" -- 3695
		local ____temp_119 = params.pattern or "" -- 3696
		local ____params_globs_120 = params.globs -- 3697
		local ____params_useRegex_121 = params.useRegex -- 3698
		local ____params_caseSensitive_122 = params.caseSensitive -- 3699
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_123 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3701
		local ____math_max_113 = math.max -- 3702
		local ____math_floor_112 = math.floor -- 3702
		local ____params_limit_111 = params.limit -- 3702
		if ____params_limit_111 == nil then -- 3702
			____params_limit_111 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3702
		end -- 3702
		local ____math_max_113_result_124 = ____math_max_113( -- 3702
			1, -- 3702
			____math_floor_112(__TS__Number(____params_limit_111)) -- 3702
		) -- 3702
		local ____math_max_116 = math.max -- 3703
		local ____math_floor_115 = math.floor -- 3703
		local ____params_offset_114 = params.offset -- 3703
		if ____params_offset_114 == nil then -- 3703
			____params_offset_114 = 0 -- 3703
		end -- 3703
		local result = __TS__Await(____Tools_searchFiles_125({ -- 3693
			workDir = ____input_workDir_117, -- 3694
			path = ____temp_118, -- 3695
			pattern = ____temp_119, -- 3696
			globs = ____params_globs_120, -- 3697
			useRegex = ____params_useRegex_121, -- 3698
			caseSensitive = ____params_caseSensitive_122, -- 3699
			includeContent = true, -- 3700
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_123, -- 3701
			limit = ____math_max_113_result_124, -- 3702
			offset = ____math_max_116( -- 3703
				0, -- 3703
				____math_floor_115(__TS__Number(____params_offset_114)) -- 3703
			), -- 3703
			groupByFile = params.groupByFile == true -- 3704
		})) -- 3704
		return ____awaiter_resolve(nil, result) -- 3704
	end) -- 3704
end -- 3691
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3709
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3709
		local last = shared.history[#shared.history] -- 3710
		if last ~= nil then -- 3710
			local result = execRes -- 3712
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3713
			appendToolResultMessage(shared, last) -- 3714
			emitAgentFinishEvent(shared, last) -- 3715
		end -- 3715
		persistHistoryState(shared) -- 3717
		__TS__Await(maybeCompressHistory(shared)) -- 3718
		persistHistoryState(shared) -- 3719
		return ____awaiter_resolve(nil, "main") -- 3719
	end) -- 3719
end -- 3709
local SearchDoraAPIAction = __TS__Class() -- 3724
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3724
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3724
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3725
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3725
		local last = shared.history[#shared.history] -- 3726
		if not last then -- 3726
			error( -- 3727
				__TS__New(Error, "no history"), -- 3727
				0 -- 3727
			) -- 3727
		end -- 3727
		emitAgentStartEvent(shared, last) -- 3728
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3728
	end) -- 3728
end -- 3725
function SearchDoraAPIAction.prototype.exec(self, input) -- 3732
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3732
		local params = input.params -- 3733
		local ____Tools_searchDoraAPI_134 = Tools.searchDoraAPI -- 3734
		local ____temp_130 = params.pattern or "" -- 3735
		local ____temp_131 = params.docSource or "api" -- 3736
		local ____temp_132 = input.useChineseResponse and "zh" or "en" -- 3737
		local ____temp_133 = params.programmingLanguage or "ts" -- 3738
		local ____math_min_129 = math.min -- 3739
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_128 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3739
		local ____math_max_127 = math.max -- 3739
		local ____params_limit_126 = params.limit -- 3739
		if ____params_limit_126 == nil then -- 3739
			____params_limit_126 = 8 -- 3739
		end -- 3739
		local result = __TS__Await(____Tools_searchDoraAPI_134({ -- 3734
			pattern = ____temp_130, -- 3735
			docSource = ____temp_131, -- 3736
			docLanguage = ____temp_132, -- 3737
			programmingLanguage = ____temp_133, -- 3738
			limit = ____math_min_129( -- 3739
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_128, -- 3739
				____math_max_127( -- 3739
					1, -- 3739
					__TS__Number(____params_limit_126) -- 3739
				) -- 3739
			), -- 3739
			useRegex = params.useRegex, -- 3740
			caseSensitive = false, -- 3741
			includeContent = true, -- 3742
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3743
		})) -- 3743
		return ____awaiter_resolve(nil, result) -- 3743
	end) -- 3743
end -- 3732
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3748
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3748
		local last = shared.history[#shared.history] -- 3749
		if last ~= nil then -- 3749
			local result = execRes -- 3751
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3752
			appendToolResultMessage(shared, last) -- 3753
			emitAgentFinishEvent(shared, last) -- 3754
		end -- 3754
		persistHistoryState(shared) -- 3756
		__TS__Await(maybeCompressHistory(shared)) -- 3757
		persistHistoryState(shared) -- 3758
		return ____awaiter_resolve(nil, "main") -- 3758
	end) -- 3758
end -- 3748
local ListFilesAction = __TS__Class() -- 3763
ListFilesAction.name = "ListFilesAction" -- 3763
__TS__ClassExtends(ListFilesAction, Node) -- 3763
function ListFilesAction.prototype.prep(self, shared) -- 3764
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3764
		local last = shared.history[#shared.history] -- 3765
		if not last then -- 3765
			error( -- 3766
				__TS__New(Error, "no history"), -- 3766
				0 -- 3766
			) -- 3766
		end -- 3766
		emitAgentStartEvent(shared, last) -- 3767
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3767
	end) -- 3767
end -- 3764
function ListFilesAction.prototype.exec(self, input) -- 3771
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3771
		local params = input.params -- 3772
		local ____Tools_listFiles_141 = Tools.listFiles -- 3773
		local ____input_workDir_138 = input.workDir -- 3774
		local ____temp_139 = params.path or "" -- 3775
		local ____params_globs_140 = params.globs -- 3776
		local ____math_max_137 = math.max -- 3777
		local ____math_floor_136 = math.floor -- 3777
		local ____params_maxEntries_135 = params.maxEntries -- 3777
		if ____params_maxEntries_135 == nil then -- 3777
			____params_maxEntries_135 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3777
		end -- 3777
		local result = ____Tools_listFiles_141({ -- 3773
			workDir = ____input_workDir_138, -- 3774
			path = ____temp_139, -- 3775
			globs = ____params_globs_140, -- 3776
			maxEntries = ____math_max_137( -- 3777
				1, -- 3777
				____math_floor_136(__TS__Number(____params_maxEntries_135)) -- 3777
			) -- 3777
		}) -- 3777
		return ____awaiter_resolve(nil, result) -- 3777
	end) -- 3777
end -- 3771
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3782
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3782
		local last = shared.history[#shared.history] -- 3783
		if last ~= nil then -- 3783
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3785
			appendToolResultMessage(shared, last) -- 3786
			emitAgentFinishEvent(shared, last) -- 3787
		end -- 3787
		persistHistoryState(shared) -- 3789
		__TS__Await(maybeCompressHistory(shared)) -- 3790
		persistHistoryState(shared) -- 3791
		return ____awaiter_resolve(nil, "main") -- 3791
	end) -- 3791
end -- 3782
local DeleteFileAction = __TS__Class() -- 3796
DeleteFileAction.name = "DeleteFileAction" -- 3796
__TS__ClassExtends(DeleteFileAction, Node) -- 3796
function DeleteFileAction.prototype.prep(self, shared) -- 3797
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3797
		local last = shared.history[#shared.history] -- 3798
		if not last then -- 3798
			error( -- 3799
				__TS__New(Error, "no history"), -- 3799
				0 -- 3799
			) -- 3799
		end -- 3799
		emitAgentStartEvent(shared, last) -- 3800
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3801
		if __TS__StringTrim(targetFile) == "" then -- 3801
			error( -- 3804
				__TS__New(Error, "missing target_file"), -- 3804
				0 -- 3804
			) -- 3804
		end -- 3804
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3804
	end) -- 3804
end -- 3797
function DeleteFileAction.prototype.exec(self, input) -- 3808
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3808
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3809
		if not result.success then -- 3809
			return ____awaiter_resolve(nil, result) -- 3809
		end -- 3809
		return ____awaiter_resolve(nil, { -- 3809
			success = true, -- 3817
			changed = true, -- 3818
			mode = "delete", -- 3819
			checkpointId = result.checkpointId, -- 3820
			checkpointSeq = result.checkpointSeq, -- 3821
			files = {{path = input.targetFile, op = "delete"}} -- 3822
		}) -- 3822
	end) -- 3822
end -- 3808
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3826
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3826
		local last = shared.history[#shared.history] -- 3827
		if last ~= nil then -- 3827
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3829
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3830
			appendToolResultMessage(shared, last) -- 3831
			emitAgentFinishEvent(shared, last) -- 3832
			local result = last.result -- 3833
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3833
				emitAgentEvent(shared, { -- 3838
					type = "checkpoint_created", -- 3839
					sessionId = shared.sessionId, -- 3840
					taskId = shared.taskId, -- 3841
					step = last.step, -- 3842
					tool = "delete_file", -- 3843
					checkpointId = result.checkpointId, -- 3844
					checkpointSeq = result.checkpointSeq, -- 3845
					files = result.files -- 3846
				}) -- 3846
			end -- 3846
		end -- 3846
		persistHistoryState(shared) -- 3853
		__TS__Await(maybeCompressHistory(shared)) -- 3854
		persistHistoryState(shared) -- 3855
		return ____awaiter_resolve(nil, "main") -- 3855
	end) -- 3855
end -- 3826
local BuildAction = __TS__Class() -- 3860
BuildAction.name = "BuildAction" -- 3860
__TS__ClassExtends(BuildAction, Node) -- 3860
function BuildAction.prototype.prep(self, shared) -- 3861
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3861
		local last = shared.history[#shared.history] -- 3862
		if not last then -- 3862
			error( -- 3863
				__TS__New(Error, "no history"), -- 3863
				0 -- 3863
			) -- 3863
		end -- 3863
		emitAgentStartEvent(shared, last) -- 3864
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3864
	end) -- 3864
end -- 3861
function BuildAction.prototype.exec(self, input) -- 3868
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3868
		local params = input.params -- 3869
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3870
		return ____awaiter_resolve(nil, result) -- 3870
	end) -- 3870
end -- 3868
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3877
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3877
		local last = shared.history[#shared.history] -- 3878
		if last ~= nil then -- 3878
			last.result = sanitizeBuildResultForHistory(execRes) -- 3880
			appendToolResultMessage(shared, last) -- 3881
			emitAgentFinishEvent(shared, last) -- 3882
		end -- 3882
		persistHistoryState(shared) -- 3884
		__TS__Await(maybeCompressHistory(shared)) -- 3885
		persistHistoryState(shared) -- 3886
		return ____awaiter_resolve(nil, "main") -- 3886
	end) -- 3886
end -- 3877
local SpawnSubAgentAction = __TS__Class() -- 3891
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3891
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3891
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3892
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3892
		local last = shared.history[#shared.history] -- 3902
		if not last then -- 3902
			error( -- 3903
				__TS__New(Error, "no history"), -- 3903
				0 -- 3903
			) -- 3903
		end -- 3903
		emitAgentStartEvent(shared, last) -- 3904
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3905
			last.params.filesHint, -- 3906
			function(____, item) return type(item) == "string" end -- 3906
		) or nil -- 3906
		return ____awaiter_resolve( -- 3906
			nil, -- 3906
			{ -- 3908
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3909
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3910
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3911
				filesHint = filesHint, -- 3912
				sessionId = shared.sessionId, -- 3913
				projectRoot = shared.workingDir, -- 3914
				spawnSubAgent = shared.spawnSubAgent, -- 3915
				disabledAgentTools = shared.disabledAgentTools -- 3916
			} -- 3916
		) -- 3916
	end) -- 3916
end -- 3892
function SpawnSubAgentAction.prototype.exec(self, input) -- 3920
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3920
		if not input.spawnSubAgent then -- 3920
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3920
		end -- 3920
		if input.sessionId == nil or input.sessionId <= 0 then -- 3920
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3920
		end -- 3920
		local ____Log_147 = Log -- 3936
		local ____temp_144 = #input.title -- 3936
		local ____temp_145 = #input.prompt -- 3936
		local ____temp_146 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3936
		local ____opt_142 = input.filesHint -- 3936
		____Log_147( -- 3936
			"Info", -- 3936
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_144)) .. " prompt_len=") .. tostring(____temp_145)) .. " expected_len=") .. tostring(____temp_146)) .. " files_hint_count=") .. tostring(____opt_142 and #____opt_142 or 0) -- 3936
		) -- 3936
		local result = __TS__Await(input.spawnSubAgent({ -- 3937
			parentSessionId = input.sessionId, -- 3938
			projectRoot = input.projectRoot, -- 3939
			title = input.title, -- 3940
			prompt = input.prompt, -- 3941
			expectedOutput = input.expectedOutput, -- 3942
			filesHint = input.filesHint, -- 3943
			disabledAgentTools = input.disabledAgentTools -- 3944
		})) -- 3944
		if not result.success then -- 3944
			return ____awaiter_resolve(nil, result) -- 3944
		end -- 3944
		return ____awaiter_resolve(nil, { -- 3944
			success = true, -- 3950
			sessionId = result.sessionId, -- 3951
			taskId = result.taskId, -- 3952
			title = result.title, -- 3953
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3954
		}) -- 3954
	end) -- 3954
end -- 3920
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3958
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3958
		local last = shared.history[#shared.history] -- 3959
		if last ~= nil then -- 3959
			last.result = execRes -- 3961
			if execRes.success == true then -- 3961
				shared.hasSpawnedSubAgentThisTask = true -- 3963
			end -- 3963
			appendToolResultMessage(shared, last) -- 3965
			emitAgentFinishEvent(shared, last) -- 3966
		end -- 3966
		persistHistoryState(shared) -- 3968
		__TS__Await(maybeCompressHistory(shared)) -- 3969
		persistHistoryState(shared) -- 3970
		return ____awaiter_resolve(nil, "main") -- 3970
	end) -- 3970
end -- 3958
local ListSubAgentsAction = __TS__Class() -- 3975
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3975
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3975
function ListSubAgentsAction.prototype.prep(self, shared) -- 3976
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3976
		local last = shared.history[#shared.history] -- 3986
		if not last then -- 3986
			error( -- 3987
				__TS__New(Error, "no history"), -- 3987
				0 -- 3987
			) -- 3987
		end -- 3987
		emitAgentStartEvent(shared, last) -- 3988
		return ____awaiter_resolve( -- 3988
			nil, -- 3988
			{ -- 3989
				sessionId = shared.sessionId, -- 3990
				projectRoot = shared.workingDir, -- 3991
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3992
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3993
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3994
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3995
				listSubAgents = shared.listSubAgents, -- 3996
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3997
			} -- 3997
		) -- 3997
	end) -- 3997
end -- 3976
function ListSubAgentsAction.prototype.exec(self, input) -- 4001
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4001
		if not input.listSubAgents then -- 4001
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4001
		end -- 4001
		if input.sessionId == nil or input.sessionId <= 0 then -- 4001
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4001
		end -- 4001
		local result = __TS__Await(input.listSubAgents({ -- 4017
			sessionId = input.sessionId, -- 4018
			projectRoot = input.projectRoot, -- 4019
			status = input.status, -- 4020
			limit = input.limit, -- 4021
			offset = input.offset, -- 4022
			query = input.query -- 4023
		})) -- 4023
		return ____awaiter_resolve( -- 4023
			nil, -- 4023
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 4025
		) -- 4025
	end) -- 4025
end -- 4001
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 4033
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4033
		local last = shared.history[#shared.history] -- 4034
		if last ~= nil then -- 4034
			last.result = execRes -- 4036
			appendToolResultMessage(shared, last) -- 4037
			emitAgentFinishEvent(shared, last) -- 4038
		end -- 4038
		persistHistoryState(shared) -- 4040
		__TS__Await(maybeCompressHistory(shared)) -- 4041
		persistHistoryState(shared) -- 4042
		return ____awaiter_resolve(nil, "main") -- 4042
	end) -- 4042
end -- 4033
EditFileAction = __TS__Class() -- 4047
EditFileAction.name = "EditFileAction" -- 4047
__TS__ClassExtends(EditFileAction, Node) -- 4047
function EditFileAction.prototype.prep(self, shared) -- 4048
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4048
		local last = shared.history[#shared.history] -- 4049
		if not last then -- 4049
			error( -- 4050
				__TS__New(Error, "no history"), -- 4050
				0 -- 4050
			) -- 4050
		end -- 4050
		emitAgentStartEvent(shared, last) -- 4051
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 4052
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 4055
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 4056
		if __TS__StringTrim(path) == "" then -- 4056
			error( -- 4057
				__TS__New(Error, "missing path"), -- 4057
				0 -- 4057
			) -- 4057
		end -- 4057
		return ____awaiter_resolve(nil, { -- 4057
			path = path, -- 4058
			oldStr = oldStr, -- 4058
			newStr = newStr, -- 4058
			taskId = shared.taskId, -- 4058
			workDir = shared.workingDir -- 4058
		}) -- 4058
	end) -- 4058
end -- 4048
function EditFileAction.prototype.exec(self, input) -- 4061
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4061
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 4062
		if not readRes.success then -- 4062
			if input.oldStr ~= "" then -- 4062
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 4062
			end -- 4062
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 4067
			if not createRes.success then -- 4067
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 4067
			end -- 4067
			return ____awaiter_resolve( -- 4067
				nil, -- 4067
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 4074
					success = true, -- 4075
					changed = true, -- 4076
					mode = "create", -- 4077
					checkpointId = createRes.checkpointId, -- 4078
					checkpointSeq = createRes.checkpointSeq, -- 4079
					files = {{path = input.path, op = "create"}} -- 4080
				}) -- 4080
			) -- 4080
		end -- 4080
		if input.oldStr == "" then -- 4080
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 4080
				return ____awaiter_resolve( -- 4080
					nil, -- 4080
					{ -- 4085
						success = false, -- 4086
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 4087
						actualSaved = false, -- 4088
						actualSavedCharacters = 0, -- 4089
						currentFileExists = true, -- 4090
						currentCharacters = #readRes.content, -- 4091
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 4092
					} -- 4092
				) -- 4092
			end -- 4092
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 4095
			if not overwriteRes.success then -- 4095
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 4095
			end -- 4095
			return ____awaiter_resolve( -- 4095
				nil, -- 4095
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 4102
					success = true, -- 4103
					changed = true, -- 4104
					mode = "overwrite", -- 4105
					checkpointId = overwriteRes.checkpointId, -- 4106
					checkpointSeq = overwriteRes.checkpointSeq, -- 4107
					files = {{path = input.path, op = "write"}} -- 4108
				}) -- 4108
			) -- 4108
		end -- 4108
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 4113
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 4114
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 4115
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 4118
		if occurrences == 0 then -- 4118
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 4120
			if not indentTolerant.success then -- 4120
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 4120
			end -- 4120
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 4124
			if not applyRes.success then -- 4124
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 4124
			end -- 4124
			return ____awaiter_resolve( -- 4124
				nil, -- 4124
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 4131
					success = true, -- 4132
					changed = true, -- 4133
					mode = "replace_indent_tolerant", -- 4134
					checkpointId = applyRes.checkpointId, -- 4135
					checkpointSeq = applyRes.checkpointSeq, -- 4136
					files = {{path = input.path, op = "write"}} -- 4137
				}) -- 4137
			) -- 4137
		end -- 4137
		if occurrences > 1 then -- 4137
			return ____awaiter_resolve( -- 4137
				nil, -- 4137
				{ -- 4141
					success = false, -- 4141
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 4141
				} -- 4141
			) -- 4141
		end -- 4141
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 4145
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 4146
		if not applyRes.success then -- 4146
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 4146
		end -- 4146
		return ____awaiter_resolve( -- 4146
			nil, -- 4146
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 4153
				success = true, -- 4154
				changed = true, -- 4155
				mode = "replace", -- 4156
				checkpointId = applyRes.checkpointId, -- 4157
				checkpointSeq = applyRes.checkpointSeq, -- 4158
				files = {{path = input.path, op = "write"}} -- 4159
			}) -- 4159
		) -- 4159
	end) -- 4159
end -- 4061
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 4163
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4163
		local last = shared.history[#shared.history] -- 4164
		if last ~= nil then -- 4164
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 4166
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 4167
			appendToolResultMessage(shared, last) -- 4168
			emitAgentFinishEvent(shared, last) -- 4169
			local result = last.result -- 4170
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4170
				emitAgentEvent(shared, { -- 4175
					type = "checkpoint_created", -- 4176
					sessionId = shared.sessionId, -- 4177
					taskId = shared.taskId, -- 4178
					step = last.step, -- 4179
					tool = last.tool, -- 4180
					checkpointId = result.checkpointId, -- 4181
					checkpointSeq = result.checkpointSeq, -- 4182
					files = result.files -- 4183
				}) -- 4183
			end -- 4183
		end -- 4183
		persistHistoryState(shared) -- 4190
		__TS__Await(maybeCompressHistory(shared)) -- 4191
		persistHistoryState(shared) -- 4192
		return ____awaiter_resolve(nil, "main") -- 4192
	end) -- 4192
end -- 4163
local FetchUrlAction = __TS__Class() -- 4197
FetchUrlAction.name = "FetchUrlAction" -- 4197
__TS__ClassExtends(FetchUrlAction, Node) -- 4197
function FetchUrlAction.prototype.prep(self, shared) -- 4198
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4198
		local last = shared.history[#shared.history] -- 4199
		if not last then -- 4199
			error( -- 4200
				__TS__New(Error, "no history"), -- 4200
				0 -- 4200
			) -- 4200
		end -- 4200
		emitAgentStartEvent(shared, last) -- 4201
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 4201
	end) -- 4201
end -- 4198
function FetchUrlAction.prototype.exec(self, input) -- 4205
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4205
		return ____awaiter_resolve( -- 4205
			nil, -- 4205
			executeToolAction(input.shared, input.action) -- 4206
		) -- 4206
	end) -- 4206
end -- 4205
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 4209
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4209
		local last = shared.history[#shared.history] -- 4210
		if last ~= nil then -- 4210
			last.result = execRes -- 4212
			appendToolResultMessage(shared, last) -- 4213
			emitAgentFinishEvent(shared, last) -- 4214
		end -- 4214
		persistHistoryState(shared) -- 4216
		__TS__Await(maybeCompressHistory(shared)) -- 4217
		persistHistoryState(shared) -- 4218
		return ____awaiter_resolve(nil, "main") -- 4218
	end) -- 4218
end -- 4209
local function emitCheckpointEventForAction(shared, action) -- 4223
	local result = action.result -- 4224
	if not result then -- 4224
		return -- 4225
	end -- 4225
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4225
		emitAgentEvent(shared, { -- 4230
			type = "checkpoint_created", -- 4231
			sessionId = shared.sessionId, -- 4232
			taskId = shared.taskId, -- 4233
			step = action.step, -- 4234
			tool = action.tool, -- 4235
			checkpointId = result.checkpointId, -- 4236
			checkpointSeq = result.checkpointSeq, -- 4237
			files = result.files -- 4238
		}) -- 4238
	end -- 4238
end -- 4223
local function canRunBatchActionInParallel(self, action) -- 4770
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4771
end -- 4770
local function partitionToolCalls(actions) -- 4779
	local batches = {} -- 4780
	do -- 4780
		local i = 0 -- 4781
		while i < #actions do -- 4781
			local action = actions[i + 1] -- 4782
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4783
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4784
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4784
				local ____lastBatch_actions_180 = lastBatch.actions -- 4784
				____lastBatch_actions_180[#____lastBatch_actions_180 + 1] = action -- 4786
			else -- 4786
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4788
			end -- 4788
			i = i + 1 -- 4781
		end -- 4781
	end -- 4781
	return batches -- 4791
end -- 4779
local function completeStoppedToolAction(shared, action) -- 4794
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4795
	if not action.result then -- 4795
		action.result = { -- 4797
			success = false, -- 4797
			message = getCancelledReason(shared) -- 4797
		} -- 4797
	end -- 4797
	appendToolResultMessage(shared, action) -- 4799
	emitAgentFinishEvent(shared, action) -- 4800
	emitCheckpointEventForAction(shared, action) -- 4801
end -- 4794
local BatchToolAction = __TS__Class() -- 4804
BatchToolAction.name = "BatchToolAction" -- 4804
__TS__ClassExtends(BatchToolAction, Node) -- 4804
function BatchToolAction.prototype.prep(self, shared) -- 4805
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4805
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4805
	end) -- 4805
end -- 4805
function BatchToolAction.prototype.exec(self, input) -- 4809
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4809
		local shared = input.shared -- 4810
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4811
		local preExecuted = shared.preExecutedResults -- 4812
		local batches = partitionToolCalls(input.actions) -- 4813
		local parallelBatchCount = #__TS__ArrayFilter( -- 4814
			batches, -- 4814
			function(____, b) return b.isConcurrencySafe end -- 4814
		) -- 4814
		local serialBatchCount = #__TS__ArrayFilter( -- 4815
			batches, -- 4815
			function(____, b) return not b.isConcurrencySafe end -- 4815
		) -- 4815
		Log( -- 4816
			"Info", -- 4816
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4816
		) -- 4816
		do -- 4816
			local batchIdx = 0 -- 4818
			while batchIdx < #batches do -- 4818
				do -- 4818
					local batch = batches[batchIdx + 1] -- 4819
					if shared.stopToken.stopped then -- 4819
						for ____, action in ipairs(batch.actions) do -- 4821
							completeStoppedToolAction(shared, action) -- 4822
						end -- 4822
						goto __continue816 -- 4824
					end -- 4824
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4824
						local preExecCount = #__TS__ArrayFilter( -- 4828
							batch.actions, -- 4828
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4828
						) -- 4828
						Log( -- 4829
							"Info", -- 4829
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4829
						) -- 4829
						do -- 4829
							local i = 0 -- 4830
							while i < #batch.actions do -- 4830
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4831
								i = i + 1 -- 4830
							end -- 4830
						end -- 4830
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4833
							batch.actions, -- 4833
							function(____, action) -- 4833
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4833
									if shared.stopToken.stopped then -- 4833
										action.result = { -- 4835
											success = false, -- 4835
											message = getCancelledReason(shared) -- 4835
										} -- 4835
										return ____awaiter_resolve(nil, action) -- 4835
									end -- 4835
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4838
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4839
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4840
									return ____awaiter_resolve(nil, action) -- 4840
								end) -- 4840
							end -- 4833
						))) -- 4833
						do -- 4833
							local i = 0 -- 4843
							while i < #batch.actions do -- 4843
								local action = batch.actions[i + 1] -- 4844
								if not action.result then -- 4844
									action.result = {success = false, message = "tool did not produce a result"} -- 4846
								end -- 4846
								appendToolResultMessage(shared, action) -- 4848
								emitAgentFinishEvent(shared, action) -- 4849
								emitCheckpointEventForAction(shared, action) -- 4850
								i = i + 1 -- 4843
							end -- 4843
						end -- 4843
					else -- 4843
						Log( -- 4853
							"Info", -- 4853
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4853
						) -- 4853
						do -- 4853
							local i = 0 -- 4854
							while i < #batch.actions do -- 4854
								local action = batch.actions[i + 1] -- 4855
								emitAgentStartEvent(shared, action) -- 4856
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4857
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4858
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4859
								appendToolResultMessage(shared, action) -- 4860
								emitAgentFinishEvent(shared, action) -- 4861
								emitCheckpointEventForAction(shared, action) -- 4862
								persistHistoryState(shared) -- 4863
								if shared.stopToken.stopped then -- 4863
									do -- 4863
										local j = i + 1 -- 4865
										while j < #batch.actions do -- 4865
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4866
											j = j + 1 -- 4865
										end -- 4865
									end -- 4865
									break -- 4868
								end -- 4868
								i = i + 1 -- 4854
							end -- 4854
						end -- 4854
					end -- 4854
				end -- 4854
				::__continue816:: -- 4854
				batchIdx = batchIdx + 1 -- 4818
			end -- 4818
		end -- 4818
		local spawnSeen = spawnedBeforeBatch -- 4873
		local didDelegatedForegroundWork = false -- 4874
		do -- 4874
			local i = 0 -- 4875
			while i < #input.actions do -- 4875
				do -- 4875
					local action = input.actions[i + 1] -- 4876
					if action.tool == "spawn_sub_agent" then -- 4876
						local ____opt_183 = action.result -- 4876
						if (____opt_183 and ____opt_183.success) == true then -- 4876
							spawnSeen = true -- 4878
						end -- 4878
						goto __continue836 -- 4879
					end -- 4879
					if spawnSeen and action.tool ~= "finish" then -- 4879
						didDelegatedForegroundWork = true -- 4882
					end -- 4882
				end -- 4882
				::__continue836:: -- 4882
				i = i + 1 -- 4875
			end -- 4875
		end -- 4875
		if didDelegatedForegroundWork then -- 4875
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4886
		end -- 4886
		persistHistoryState(shared) -- 4888
		return ____awaiter_resolve(nil, input.actions) -- 4888
	end) -- 4888
end -- 4809
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4892
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4892
		shared.pendingToolActions = nil -- 4893
		shared.preExecutedResults = nil -- 4894
		persistHistoryState(shared) -- 4895
		__TS__Await(maybeCompressHistory(shared)) -- 4896
		persistHistoryState(shared) -- 4897
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4897
	end) -- 4897
end -- 4892
local EndNode = __TS__Class() -- 4902
EndNode.name = "EndNode" -- 4902
__TS__ClassExtends(EndNode, Node) -- 4902
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4903
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4903
		return ____awaiter_resolve(nil, nil) -- 4903
	end) -- 4903
end -- 4903
local CodingAgentFlow = __TS__Class() -- 4908
CodingAgentFlow.name = "CodingAgentFlow" -- 4908
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4908
function CodingAgentFlow.prototype.____constructor(self, role) -- 4909
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4910
	local read = __TS__New(ReadFileAction, 1, 0) -- 4911
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4912
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4913
	local list = __TS__New(ListFilesAction, 1, 0) -- 4914
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4915
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4916
	local build = __TS__New(BuildAction, 1, 0) -- 4917
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4918
	local edit = __TS__New(EditFileAction, 1, 0) -- 4919
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4920
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4921
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4922
	local done = __TS__New(EndNode, 1, 0) -- 4923
	main:on("batch_tools", batch) -- 4925
	main:on("grep_files", search) -- 4926
	main:on("search_dora_api", searchDora) -- 4927
	main:on("glob_files", list) -- 4928
	main:on("fetch_url", fetch) -- 4929
	main:on("execute_command", exec) -- 4930
	if role == "main" then -- 4930
		main:on("read_file", read) -- 4932
		main:on("delete_file", del) -- 4933
		main:on("build", build) -- 4934
		main:on("edit_file", edit) -- 4935
		main:on("list_sub_agents", listSub) -- 4936
		main:on("spawn_sub_agent", spawn) -- 4937
	else -- 4937
		main:on("read_file", read) -- 4939
		main:on("delete_file", del) -- 4940
		main:on("build", build) -- 4941
		main:on("edit_file", edit) -- 4942
	end -- 4942
	main:on("done", done) -- 4944
	search:on("main", main) -- 4946
	searchDora:on("main", main) -- 4947
	list:on("main", main) -- 4948
	listSub:on("main", main) -- 4949
	spawn:on("main", main) -- 4950
	batch:on("main", main) -- 4951
	batch:on("done", done) -- 4952
	read:on("main", main) -- 4953
	del:on("main", main) -- 4954
	build:on("main", main) -- 4955
	edit:on("main", main) -- 4956
	fetch:on("main", main) -- 4957
	exec:on("main", main) -- 4958
	Flow.prototype.____constructor(self, main) -- 4960
end -- 4909
local function runCodingAgentAsync(options) -- 4996
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4996
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4996
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4996
		end -- 4996
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 5000
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 5001
		if not llmConfigRes.success then -- 5001
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 5001
		end -- 5001
		local llmConfig = llmConfigRes.config -- 5007
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 5008
		if not taskRes.success then -- 5008
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 5008
		end -- 5008
		local compressor = __TS__New(MemoryCompressor, { -- 5015
			compressionThreshold = 0.8, -- 5016
			compressionTargetThreshold = 0.5, -- 5017
			maxCompressionRounds = 3, -- 5018
			projectDir = options.workDir, -- 5019
			llmConfig = llmConfig, -- 5020
			promptPack = options.promptPack, -- 5021
			scope = options.memoryScope -- 5022
		}) -- 5022
		local persistedSession = compressor:getStorage():readSessionState() -- 5024
		local effectiveUserQuery = normalizedPrompt -- 5025
		if options.resumeConversation == true then -- 5025
			do -- 5025
				local i = #persistedSession.messages - 1 -- 5027
				while i >= 0 do -- 5027
					local message = persistedSession.messages[i + 1] -- 5028
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 5028
						effectiveUserQuery = message.content -- 5030
						break -- 5031
					end -- 5031
					i = i - 1 -- 5027
				end -- 5027
			end -- 5027
		end -- 5027
		local promptPack = compressor:getPromptPack() -- 5035
		local freshProject = inspectFreshProject(options.workDir) -- 5036
		local freshProjectBuildPending = freshProject.fresh -- 5037
		local freshProjectCodeFile = freshProject.codeFile -- 5038
		local shared = { -- 5040
			sessionId = options.sessionId, -- 5041
			taskId = taskRes.taskId, -- 5042
			role = options.role or "main", -- 5043
			maxSteps = math.max( -- 5044
				1, -- 5044
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 5044
			), -- 5044
			llmMaxTry = math.max( -- 5045
				1, -- 5045
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 5045
			), -- 5045
			step = 0, -- 5046
			done = false, -- 5047
			stopToken = options.stopToken or ({stopped = false}), -- 5048
			response = "", -- 5049
			userQuery = effectiveUserQuery, -- 5050
			workingDir = options.workDir, -- 5051
			useChineseResponse = options.useChineseResponse == true, -- 5052
			workMode = options.workMode or "code", -- 5053
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 5054
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 5057
			llmConfig = llmConfig, -- 5058
			onEvent = options.onEvent, -- 5059
			promptPack = promptPack, -- 5060
			history = {}, -- 5061
			messages = persistedSession.messages, -- 5062
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 5063
			carryMessageIndex = persistedSession.carryMessageIndex, -- 5064
			memory = {compressor = compressor}, -- 5066
			skills = {loader = AgentSkills.createSkillsLoader({ -- 5070
				projectDir = options.workDir, -- 5072
				disabledAgentTools = options.disabledAgentTools or ({}), -- 5073
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 5074
			})}, -- 5074
			spawnSubAgent = options.spawnSubAgent, -- 5080
			listSubAgents = options.listSubAgents, -- 5081
			publishQuestionnaire = options.publishQuestionnaire, -- 5082
			disabledAgentTools = options.disabledAgentTools or ({}), -- 5083
			freshProjectBuildPending = freshProjectBuildPending, -- 5084
			freshProjectCodeFile = freshProjectCodeFile, -- 5085
			hasSpawnedSubAgentThisTask = false, -- 5086
			delegatedForegroundBatches = 0 -- 5087
		} -- 5087
		local ____hasReturned, ____returnValue -- 5087
		local ____try = __TS__AsyncAwaiter(function() -- 5087
			if shared.workMode == "plan" then -- 5087
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 5092
				if not planDocuments.success then -- 5092
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 5094
					____hasReturned = true -- 5095
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 5095
					return -- 5095
				end -- 5095
			end -- 5095
			emitAgentEvent(shared, { -- 5098
				type = "task_started", -- 5099
				sessionId = shared.sessionId, -- 5100
				taskId = shared.taskId, -- 5101
				prompt = shared.userQuery, -- 5102
				workDir = shared.workingDir, -- 5103
				maxSteps = shared.maxSteps -- 5104
			}) -- 5104
			if shared.stopToken.stopped then -- 5104
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 5107
				____hasReturned = true -- 5108
				____returnValue = emitAgentTaskFinishEvent( -- 5108
					shared, -- 5108
					false, -- 5108
					getCancelledReason(shared) -- 5108
				) -- 5108
				return -- 5108
			end -- 5108
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 5110
			local ____temp_185 -- 5111
			if options.resumeConversation == true then -- 5111
				____temp_185 = nil -- 5111
			else -- 5111
				____temp_185 = getPromptCommand(shared.userQuery) -- 5111
			end -- 5111
			local promptCommand = ____temp_185 -- 5111
			if promptCommand == "clear" then -- 5111
				____hasReturned = true -- 5113
				____returnValue = clearSessionHistory(shared) -- 5113
				return -- 5113
			end -- 5113
			if promptCommand == "compact" then -- 5113
				if shared.role == "sub" then -- 5113
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 5117
					____hasReturned = true -- 5118
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 5118
					return -- 5118
				end -- 5118
				____hasReturned = true -- 5126
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 5126
				return -- 5126
			end -- 5126
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 5128
			if shared.stopToken.stopped then -- 5128
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 5130
				____hasReturned = true -- 5131
				____returnValue = emitAgentTaskFinishEvent( -- 5131
					shared, -- 5131
					false, -- 5131
					getCancelledReason(shared) -- 5131
				) -- 5131
				return -- 5131
			end -- 5131
			if options.resumeConversation ~= true then -- 5131
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 5134
				persistHistoryState(shared) -- 5138
			end -- 5138
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 5140
			__TS__Await(flow:run(shared)) -- 5141
			if shared.stopToken.stopped then -- 5141
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 5143
				____hasReturned = true -- 5144
				____returnValue = emitAgentTaskFinishEvent( -- 5144
					shared, -- 5144
					false, -- 5144
					getCancelledReason(shared) -- 5144
				) -- 5144
				return -- 5144
			end -- 5144
			if shared.error then -- 5144
				____hasReturned = true -- 5147
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 5147
				return -- 5147
			end -- 5147
			if shared.waitingQuestionnaireId ~= nil then -- 5147
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 5151
				emitAgentEvent(shared, { -- 5152
					type = "task_waiting_for_user", -- 5153
					sessionId = shared.sessionId, -- 5154
					taskId = shared.taskId, -- 5155
					step = shared.step, -- 5156
					questionnaireId = shared.waitingQuestionnaireId -- 5157
				}) -- 5157
				____hasReturned = true -- 5159
				____returnValue = { -- 5159
					success = true, -- 5160
					taskId = shared.taskId, -- 5161
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 5162
					steps = shared.step, -- 5163
					waitingForUser = true, -- 5164
					questionnaireId = shared.waitingQuestionnaireId -- 5165
				} -- 5165
				return -- 5159
			end -- 5159
			local ____isFinalDecisionTurn_result_188 = isFinalDecisionTurn(shared) -- 5168
			if ____isFinalDecisionTurn_result_188 then -- 5168
				local ____opt_186 = shared.completion -- 5168
				____isFinalDecisionTurn_result_188 = (____opt_186 and ____opt_186.outcome) == "partial" -- 5168
			end -- 5168
			if ____isFinalDecisionTurn_result_188 then -- 5168
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 5169
				____hasReturned = true -- 5170
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 5170
				return -- 5170
			end -- 5170
			Tools.setTaskStatus(shared.taskId, "DONE") -- 5173
			____hasReturned = true -- 5174
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 5174
			return -- 5174
		end) -- 5174
		____try = ____try.catch( -- 5174
			____try, -- 5174
			function(____, e) -- 5174
				return __TS__AsyncAwaiter(function() -- 5174
					____hasReturned = true -- 5177
					____returnValue = finalizeAgentFailure( -- 5177
						shared, -- 5177
						tostring(e) -- 5177
					) -- 5177
					return -- 5177
				end) -- 5177
			end -- 5177
		) -- 5177
		__TS__Await(____try) -- 5090
		if ____hasReturned then -- 5090
			return ____awaiter_resolve(nil, ____returnValue) -- 5090
		end -- 5090
	end) -- 5090
end -- 4996
function ____exports.runCodingAgent(options, callback) -- 5181
	local ____self_189 = runCodingAgentAsync(options) -- 5181
	____self_189["then"]( -- 5181
		____self_189, -- 5181
		function(____, result) return callback(result) end -- 5182
	) -- 5182
end -- 5181
return ____exports -- 5181