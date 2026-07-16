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
function isRecord(value) -- 13
	return type(value) == "table" -- 14
end -- 14
function isArray(value) -- 17
	return __TS__ArrayIsArray(value) -- 18
end -- 18
function emitAgentEvent(shared, event) -- 403
	if shared.onEvent then -- 403
		do -- 403
			local function ____catch(____error) -- 403
				Log( -- 408
					"Error", -- 408
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 408
				) -- 408
			end -- 408
			local ____try, ____hasReturned = pcall(function() -- 408
				shared:onEvent(event) -- 406
			end) -- 406
			if not ____try then -- 406
				____catch(____hasReturned) -- 406
			end -- 406
		end -- 406
	end -- 406
end -- 406
function getCancelledReason(shared) -- 537
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 537
		return shared.stopToken.reason -- 538
	end -- 538
	return shared.useChineseResponse and "已取消" or "cancelled" -- 539
end -- 539
function ____exports.normalizePolicyPath(path) -- 601
	local normalized = table.concat( -- 602
		__TS__StringSplit( -- 602
			__TS__StringTrim(path), -- 602
			"\\" -- 602
		), -- 602
		"/" -- 602
	) -- 602
	while __TS__StringStartsWith(normalized, "./") do -- 602
		normalized = string.sub(normalized, 3) -- 603
	end -- 603
	return normalized -- 604
end -- 601
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 612
	local normalized = ____exports.normalizePolicyPath(path) -- 613
	return normalized == ".agent/main" or __TS__StringStartsWith(normalized, ".agent/main/") -- 614
end -- 612
function truncateText(text, maxLen) -- 774
	if #text <= maxLen then -- 774
		return text -- 775
	end -- 775
	local nextPos = utf8.offset(text, maxLen + 1) -- 776
	if nextPos == nil then -- 776
		return text -- 777
	end -- 777
	return string.sub(text, 1, nextPos - 1) .. "..." -- 778
end -- 778
function utf8TakeHead(text, maxChars) -- 781
	if maxChars <= 0 or text == "" then -- 781
		return "" -- 782
	end -- 782
	local nextPos = utf8.offset(text, maxChars + 1) -- 783
	if nextPos == nil then -- 783
		return text -- 784
	end -- 784
	return string.sub(text, 1, nextPos - 1) -- 785
end -- 785
function getReplyLanguageDirective(shared) -- 788
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 789
end -- 789
function replacePromptVars(template, vars) -- 794
	local output = template -- 795
	for key in pairs(vars) do -- 796
		output = table.concat( -- 797
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 797
			vars[key] or "" or "," -- 797
		) -- 797
	end -- 797
	return output -- 799
end -- 799
function limitReadContentForHistory(content, tool) -- 802
	local lines = __TS__StringSplit(content, "\n") -- 803
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 804
	local limitedByLines = overLineLimit and table.concat( -- 805
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 806
		"\n" -- 806
	) or content -- 806
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 806
		return content -- 809
	end -- 809
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 811
	local reasons = {} -- 814
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 814
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 815
	end -- 815
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 815
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 816
	end -- 816
	local hint = "Narrow the requested line range." -- 817
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 818
end -- 818
function sanitizeReadResultForHistory(tool, result) -- 833
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 833
		return result -- 835
	end -- 835
	local clone = {} -- 837
	for key in pairs(result) do -- 838
		clone[key] = result[key] -- 839
	end -- 839
	clone.content = limitReadContentForHistory(result.content, tool) -- 841
	return clone -- 842
end -- 842
function sanitizeSearchMatchesForHistory(items, maxItems) -- 845
	local shown = math.min(#items, maxItems) -- 849
	local out = {} -- 850
	do -- 850
		local i = 0 -- 851
		while i < shown do -- 851
			local row = items[i + 1] -- 852
			out[#out + 1] = { -- 853
				file = row.file, -- 854
				line = row.line, -- 855
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 856
			} -- 856
			i = i + 1 -- 851
		end -- 851
	end -- 851
	return out -- 861
end -- 861
function sanitizeSearchResultForHistory(tool, result) -- 864
	if result.success ~= true or not isArray(result.results) then -- 864
		return result -- 868
	end -- 868
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 868
		return result -- 869
	end -- 869
	local clone = {} -- 870
	for key in pairs(result) do -- 871
		clone[key] = result[key] -- 872
	end -- 872
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 874
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 875
	if tool == "grep_files" and isArray(result.groupedResults) then -- 875
		local grouped = result.groupedResults -- 880
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 881
		local sanitizedGroups = {} -- 882
		do -- 882
			local i = 0 -- 883
			while i < shown do -- 883
				local row = grouped[i + 1] -- 884
				sanitizedGroups[#sanitizedGroups + 1] = { -- 885
					file = row.file, -- 886
					totalMatches = row.totalMatches, -- 887
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 888
				} -- 888
				i = i + 1 -- 883
			end -- 883
		end -- 883
		clone.groupedResults = sanitizedGroups -- 893
	end -- 893
	return clone -- 895
end -- 895
function sanitizeListFilesResultForHistory(result) -- 898
	if result.success ~= true or not isArray(result.files) then -- 898
		return result -- 899
	end -- 899
	local clone = {} -- 900
	for key in pairs(result) do -- 901
		clone[key] = result[key] -- 902
	end -- 902
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 904
	return clone -- 905
end -- 905
function sanitizeBuildResultForHistory(result) -- 908
	if not isArray(result.messages) then -- 908
		return result -- 909
	end -- 909
	local clone = {} -- 910
	for key in pairs(result) do -- 911
		clone[key] = result[key] -- 912
	end -- 912
	local messages = result.messages -- 914
	local ordered = __TS__ArraySort( -- 915
		__TS__ArraySlice(messages), -- 915
		function(____, a, b) -- 915
			local aFailed = a.success ~= true -- 916
			local bFailed = b.success ~= true -- 917
			if aFailed == bFailed then -- 917
				return 0 -- 918
			end -- 918
			return aFailed and -1 or 1 -- 919
		end -- 915
	) -- 915
	local shown = math.min(#ordered, HISTORY_BUILD_MAX_MESSAGES) -- 921
	local sanitized = {} -- 922
	do -- 922
		local i = 0 -- 923
		while i < shown do -- 923
			local item = ordered[i + 1] -- 924
			local next = {} -- 925
			for key in pairs(item) do -- 926
				local value = item[key] -- 927
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 928
			end -- 928
			sanitized[#sanitized + 1] = next -- 932
			i = i + 1 -- 923
		end -- 923
	end -- 923
	clone.messages = sanitized -- 934
	if #ordered > shown then -- 934
		clone.truncatedMessages = #ordered - shown -- 936
	end -- 936
	return clone -- 938
end -- 938
function ____exports.getDecisionDisabledAgentTools(shared) -- 956
	local disabled = __TS__ArraySlice(shared.disabledAgentTools) -- 957
	if shared.freshProjectBuildPending == true then -- 957
		local freshProjectDisabled = { -- 963
			"read_file", -- 964
			"glob_files", -- 965
			"grep_files", -- 966
			"search_dora_api", -- 967
			"execute_command" -- 968
		} -- 968
		do -- 968
			local i = 0 -- 970
			while i < #freshProjectDisabled do -- 970
				if __TS__ArrayIndexOf(disabled, freshProjectDisabled[i + 1]) < 0 then -- 970
					disabled[#disabled + 1] = freshProjectDisabled[i + 1] -- 971
				end -- 971
				i = i + 1 -- 970
			end -- 970
		end -- 970
	end -- 970
	if ((shared.apiSearchesSinceBuild or 0) >= 1 or shared.unbuiltEdits == true) and __TS__ArrayIndexOf(disabled, "search_dora_api") < 0 then -- 970
		disabled[#disabled + 1] = "search_dora_api" -- 984
	end -- 984
	if shared.buildRepairPending == true then -- 984
		local repairDisabled = {"grep_files", "glob_files", "search_dora_api", "execute_command"} -- 991
		do -- 991
			local i = 0 -- 997
			while i < #repairDisabled do -- 997
				if __TS__ArrayIndexOf(disabled, repairDisabled[i + 1]) < 0 then -- 997
					disabled[#disabled + 1] = repairDisabled[i + 1] -- 998
				end -- 998
				i = i + 1 -- 997
			end -- 997
		end -- 997
	end -- 997
	if shared.unbuiltEdits == true and (shared.editsSinceBuild or 0) >= 3 then -- 997
		local changesMustBuild = {"edit_file", "delete_file"} -- 1005
		do -- 1005
			local i = 0 -- 1006
			while i < #changesMustBuild do -- 1006
				if __TS__ArrayIndexOf(disabled, changesMustBuild[i + 1]) < 0 then -- 1006
					disabled[#disabled + 1] = changesMustBuild[i + 1] -- 1007
				end -- 1007
				i = i + 1 -- 1006
			end -- 1006
		end -- 1006
	end -- 1006
	return disabled -- 1010
end -- 956
function getDecisionToolDefinitions(shared) -- 1013
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1014
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1015
	local base = shared.promptPack.toolDefinitionsDetailed -- 1018
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1019
	local decisionDisabledTools = ____exports.getDecisionDisabledAgentTools(shared) -- 1021
	local availableTools = AgentToolRegistry.getAllowedToolsForRole(shared.role, {disabledAgentTools = decisionDisabledTools}) -- 1022
	local freshProjectGuidance = shared.freshProjectBuildPending ~= true and "" or (shared.freshProjectCodeFile ~= nil and ("\n- fresh small project: the only buildable code file is `" .. shared.freshProjectCodeFile) .. "` and it has at most 3 lines; implement by coherently rewriting that file, then build before any discovery or command validation" or "\n- fresh empty project: there are no buildable code files; create the requested entry directly (default to `init.ts` for a Dora TypeScript task), then build before any discovery or command validation") -- 1025
	local availability = (((("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat(availableTools, ", ")) .. "\n- If the user requests a tool that is not in this allowed list, report that it is unavailable. Do not simulate it with repeated reads or unrelated discovery.") .. freshProjectGuidance -- 1030
	if usesDefaultToolPrompts then -- 1030
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed(shared.role, {includeFinish = true, includeXmlRules = true, context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}, disabledAgentTools = decisionDisabledTools}) -- 1037
		return replacePromptVars(definitions .. availability, params) -- 1043
	end -- 1043
	local withRole = replacePromptVars((base .. mainAgentTools) .. availability, params) -- 1045
	if (shared and shared.decisionMode) ~= "xml" then -- 1045
		return withRole -- 1050
	end -- 1050
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1052
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1053
end -- 1053
function getFinishMessage(params, fallback) -- 1408
	if fallback == nil then -- 1408
		fallback = "" -- 1408
	end -- 1408
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1408
		return __TS__StringTrim(params.message) -- 1410
	end -- 1410
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1410
		return __TS__StringTrim(params.response) -- 1413
	end -- 1413
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1413
		return __TS__StringTrim(params.summary) -- 1416
	end -- 1416
	return __TS__StringTrim(fallback) -- 1418
end -- 1418
function normalizeCompletionText(value) -- 1425
	if type(value) ~= "string" then -- 1425
		return "" -- 1426
	end -- 1426
	return __TS__StringSlice( -- 1427
		__TS__StringTrim(sanitizeUTF8(value)), -- 1427
		0, -- 1427
		COMPLETION_TEXT_MAX_CHARS -- 1427
	) -- 1427
end -- 1427
function normalizeCompletionTextList(value, maxItems) -- 1430
	if maxItems == nil then -- 1430
		maxItems = COMPLETION_LIST_MAX_ITEMS -- 1430
	end -- 1430
	if not isArray(value) then -- 1430
		return {} -- 1431
	end -- 1431
	local items = {} -- 1432
	do -- 1432
		local i = 0 -- 1433
		while i < #value and #items < maxItems do -- 1433
			local item = normalizeCompletionText(value[i + 1]) -- 1434
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 1434
				items[#items + 1] = item -- 1435
			end -- 1435
			i = i + 1 -- 1433
		end -- 1433
	end -- 1433
	return items -- 1437
end -- 1437
function ____exports.normalizeAgentCompletionReport(value) -- 1440
	local row = value and not isArray(value) and isRecord(value) and value or ({}) -- 1441
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 1442
	local validation = {} -- 1445
	if isArray(row.validation) then -- 1445
		do -- 1445
			local i = 0 -- 1447
			while i < #row.validation and #validation < COMPLETION_LIST_MAX_ITEMS do -- 1447
				do -- 1447
					local raw = row.validation[i + 1] -- 1448
					if not raw or isArray(raw) or not isRecord(raw) then -- 1448
						goto __continue219 -- 1449
					end -- 1449
					local kind = (raw.kind == "runtime" or raw.kind == "manual") and raw.kind or (raw.kind == "build" and "build" or nil) -- 1450
					local result = (raw.result == "passed" or raw.result == "failed" or raw.result == "not_run") and raw.result or nil -- 1451
					if kind == nil or result == nil then -- 1451
						goto __continue219 -- 1452
					end -- 1452
					validation[#validation + 1] = { -- 1453
						kind = kind, -- 1454
						result = result, -- 1455
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS) -- 1456
					} -- 1456
				end -- 1456
				::__continue219:: -- 1456
				i = i + 1 -- 1447
			end -- 1447
		end -- 1447
	end -- 1447
	local learningCandidates = {} -- 1460
	if isArray(row.learningCandidates) then -- 1460
		do -- 1460
			local i = 0 -- 1462
			while i < #row.learningCandidates and #learningCandidates < COMPLETION_LIST_MAX_ITEMS do -- 1462
				do -- 1462
					local raw = row.learningCandidates[i + 1] -- 1463
					if not raw or isArray(raw) or not isRecord(raw) then -- 1463
						goto __continue224 -- 1464
					end -- 1464
					local claim = normalizeCompletionText(raw.claim) -- 1465
					if claim == "" then -- 1465
						goto __continue224 -- 1466
					end -- 1466
					learningCandidates[#learningCandidates + 1] = { -- 1467
						claim = claim, -- 1468
						scope = (raw.scope == "file" or raw.scope == "engine") and raw.scope or "project", -- 1469
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS), -- 1470
						confidence = raw.confidence == "inferred" and "inferred" or "observed" -- 1471
					} -- 1471
				end -- 1471
				::__continue224:: -- 1471
				i = i + 1 -- 1462
			end -- 1462
		end -- 1462
	end -- 1462
	return { -- 1475
		outcome = outcome, -- 1476
		validation = validation, -- 1477
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 1478
		assumptions = normalizeCompletionTextList(row.assumptions), -- 1479
		learningCandidates = learningCandidates -- 1480
	} -- 1480
end -- 1440
function getCompletionReport(params) -- 1484
	return ____exports.normalizeAgentCompletionReport(params) -- 1485
end -- 1485
function persistHistoryState(shared) -- 1488
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1489
end -- 1489
function getActiveConversationMessages(shared) -- 1496
	local activeMessages = {} -- 1497
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1497
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1504
	end -- 1504
	do -- 1504
		local i = shared.lastConsolidatedIndex -- 1508
		while i < #shared.messages do -- 1508
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1509
			i = i + 1 -- 1508
		end -- 1508
	end -- 1508
	return activeMessages -- 1511
end -- 1511
function getActiveRealMessageCount(shared) -- 1514
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1515
end -- 1515
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1518
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1524
	local previousActiveStart = shared.lastConsolidatedIndex -- 1525
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1526
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1527
	if type(carryMessageIndex) == "number" then -- 1527
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1527
		else -- 1527
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1535
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1538
		end -- 1538
	else -- 1538
		shared.carryMessageIndex = nil -- 1543
	end -- 1543
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1543
		shared.carryMessageIndex = nil -- 1553
	end -- 1553
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1561
	shared.resumeCheckpointPending = true -- 1562
	shared.resumeRequiredTool = nil -- 1563
	shared.resumeNarrowReadMode = true -- 1564
	if shared.unbuiltEdits == true then -- 1564
		shared.resumeRequiredTool = "build" -- 1572
	end -- 1572
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1581
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1581
		local marker = "**Next tool**:" -- 1592
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1593
		if markerIndex >= 0 then -- 1593
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1595
			local toolNames = { -- 1596
				"read_file", -- 1597
				"edit_file", -- 1597
				"delete_file", -- 1597
				"grep_files", -- 1597
				"search_dora_api", -- 1597
				"glob_files", -- 1598
				"build", -- 1598
				"fetch_url", -- 1598
				"execute_command", -- 1598
				"list_sub_agents", -- 1598
				"spawn_sub_agent", -- 1599
				"finish" -- 1599
			} -- 1599
			do -- 1599
				local i = 0 -- 1601
				while i < #toolNames do -- 1601
					local tool = toolNames[i + 1] -- 1602
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1602
						shared.resumeRequiredTool = tool -- 1604
						break -- 1605
					end -- 1605
					i = i + 1 -- 1601
				end -- 1601
			end -- 1601
		end -- 1601
	end -- 1601
end -- 1601
function ensureToolCallId(toolCallId) -- 1623
	if toolCallId and toolCallId ~= "" then -- 1623
		return toolCallId -- 1624
	end -- 1624
	return createLocalToolCallId() -- 1625
end -- 1625
function hasXMLParam(params, name) -- 1658
	return params[name] ~= nil -- 1659
end -- 1659
function inferToolNameFromXMLParams(params) -- 1662
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1662
		return "edit_file" -- 1664
	end -- 1664
	if hasXMLParam(params, "target_file") then -- 1664
		return "delete_file" -- 1667
	end -- 1667
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1667
		if hasXMLParam(params, "path") then -- 1667
			return "read_file" -- 1670
		end -- 1670
		return nil -- 1671
	end -- 1671
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1671
		if hasXMLParam(params, "pattern") then -- 1671
			return "search_dora_api" -- 1674
		end -- 1674
		return nil -- 1675
	end -- 1675
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1675
		if hasXMLParam(params, "pattern") then -- 1675
			return "grep_files" -- 1678
		end -- 1678
		return nil -- 1679
	end -- 1679
	if hasXMLParam(params, "globs") then -- 1679
		if hasXMLParam(params, "pattern") then -- 1679
			return "grep_files" -- 1682
		end -- 1682
		return "glob_files" -- 1683
	end -- 1683
	if hasXMLParam(params, "maxEntries") then -- 1683
		return "glob_files" -- 1686
	end -- 1686
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1686
		return "finish" -- 1689
	end -- 1689
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1689
		return "spawn_sub_agent" -- 1692
	end -- 1692
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1692
		return "list_sub_agents" -- 1695
	end -- 1695
	return nil -- 1697
end -- 1697
function parseDSMLAttribute(source, offset, name) -- 1700
	local attrOpen = name .. "=\"" -- 1701
	local attrStart = (string.find( -- 1702
		source, -- 1702
		attrOpen, -- 1702
		math.max(offset + 1, 1), -- 1702
		true -- 1702
	) or 0) - 1 -- 1702
	if attrStart < 0 then -- 1702
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1703
	end -- 1703
	local valueStart = attrStart + #attrOpen -- 1704
	local valueEnd = (string.find( -- 1705
		source, -- 1705
		"\"", -- 1705
		math.max(valueStart + 1, 1), -- 1705
		true -- 1705
	) or 0) - 1 -- 1705
	if valueEnd < 0 then -- 1705
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1706
	end -- 1706
	return { -- 1707
		success = true, -- 1708
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1709
		next = valueEnd + 1 -- 1710
	} -- 1710
end -- 1710
function extractDSMLReason(text, invokeStart, tool) -- 1714
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1715
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1716
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1716
		return before -- 1719
	end -- 1719
	if tool == "finish" then -- 1719
		return "" -- 1720
	end -- 1720
	return "Converted provider-native tool call syntax to XML." -- 1721
end -- 1721
function parseDSMLToolCallObjectFromText(text) -- 1724
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1725
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1726
	if invokeStart < 0 then -- 1726
		return {success = false, message = "missing DSML invoke"} -- 1727
	end -- 1727
	local nameStart = invokeStart + #invokeOpen -- 1728
	local nameEnd = (string.find( -- 1729
		text, -- 1729
		"\"", -- 1729
		math.max(nameStart + 1, 1), -- 1729
		true -- 1729
	) or 0) - 1 -- 1729
	if nameEnd < 0 then -- 1729
		return {success = false, message = "unterminated DSML invoke name"} -- 1730
	end -- 1730
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1731
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1731
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1733
	end -- 1733
	local invokeOpenEnd = (string.find( -- 1735
		text, -- 1735
		">", -- 1735
		math.max(nameEnd + 1, 1), -- 1735
		true -- 1735
	) or 0) - 1 -- 1735
	if invokeOpenEnd < 0 then -- 1735
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1736
	end -- 1736
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1737
	local invokeEnd = (string.find( -- 1738
		text, -- 1738
		invokeClose, -- 1738
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1738
		true -- 1738
	) or 0) - 1 -- 1738
	if invokeEnd < 0 then -- 1738
		return {success = false, message = "missing DSML invoke close tag"} -- 1739
	end -- 1739
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1741
	local params = {} -- 1742
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1743
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1744
	local pos = 0 -- 1745
	while pos < #body do -- 1745
		local start = (string.find( -- 1747
			body, -- 1747
			paramOpen, -- 1747
			math.max(pos + 1, 1), -- 1747
			true -- 1747
		) or 0) - 1 -- 1747
		if start < 0 then -- 1747
			break -- 1748
		end -- 1748
		local openEnd = (string.find( -- 1749
			body, -- 1749
			">", -- 1749
			math.max(start + #paramOpen + 1, 1), -- 1749
			true -- 1749
		) or 0) - 1 -- 1749
		if openEnd < 0 then -- 1749
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1750
		end -- 1750
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1751
		if not name.success then -- 1751
			return name -- 1752
		end -- 1752
		local close = (string.find( -- 1753
			body, -- 1753
			paramClose, -- 1753
			math.max(openEnd + 1 + 1, 1), -- 1753
			true -- 1753
		) or 0) - 1 -- 1753
		if close < 0 then -- 1753
			return {success = false, message = "missing DSML parameter close tag"} -- 1754
		end -- 1754
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1755
		pos = close + #paramClose -- 1756
	end -- 1756
	return { -- 1758
		success = true, -- 1759
		obj = { -- 1760
			tool = toolName, -- 1761
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1762
			params = params -- 1763
		} -- 1763
	} -- 1763
end -- 1763
function parseXMLToolCallObjectFromText(text) -- 1768
	local children = parseXMLObjectFromText(text, "tool_call") -- 1769
	local rawObj -- 1770
	if children.success then -- 1770
		rawObj = children.obj -- 1772
	else -- 1772
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1774
		if dsml.success then -- 1774
			return dsml -- 1775
		end -- 1775
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1776
		local paramsCloseToken = "</params>" -- 1777
		if toolStart >= 0 then -- 1777
			local paramsClose = (string.find( -- 1779
				text, -- 1779
				paramsCloseToken, -- 1779
				math.max(toolStart + 1, 1), -- 1779
				true -- 1779
			) or 0) - 1 -- 1779
			if paramsClose >= toolStart then -- 1779
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1781
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1782
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1782
					rawObj = bare.obj -- 1784
				end -- 1784
			end -- 1784
		end -- 1784
		if rawObj == nil then -- 1784
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1789
			if paramsOpen < 0 then -- 1789
				return children -- 1790
			end -- 1790
			local paramsCloseOnly = (string.find( -- 1791
				text, -- 1791
				paramsCloseToken, -- 1791
				math.max(paramsOpen + 1, 1), -- 1791
				true -- 1791
			) or 0) - 1 -- 1791
			if paramsCloseOnly < paramsOpen then -- 1791
				return children -- 1792
			end -- 1792
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1793
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1794
			if not paramsOnly.success then -- 1794
				return children -- 1795
			end -- 1795
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1796
			if inferredTool == nil then -- 1796
				return children -- 1797
			end -- 1797
			local ____temp_24 -- 1802
			if inferredTool == "finish" then -- 1802
				____temp_24 = nil -- 1802
			else -- 1802
				____temp_24 = "Inferred tool from XML params." -- 1802
			end -- 1802
			return {success = true, obj = {tool = inferredTool, reason = ____temp_24, params = paramsOnly.obj}} -- 1798
		end -- 1798
	end -- 1798
	if rawObj == nil then -- 1798
		return children -- 1808
	end -- 1808
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1809
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1810
	if not params.success then -- 1810
		return {success = false, message = params.message} -- 1814
	end -- 1814
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1816
end -- 1816
function parseDecisionObject(rawObj) -- 1908
	if type(rawObj.tool) ~= "string" then -- 1908
		return {success = false, message = "missing tool"} -- 1909
	end -- 1909
	local tool = rawObj.tool -- 1910
	if not AgentToolRegistry.isKnownToolName(tool) then -- 1910
		return {success = false, message = "unknown tool: " .. tool} -- 1912
	end -- 1912
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1914
	if tool ~= "finish" and (not reason or reason == "") then -- 1914
		return {success = false, message = tool .. " requires top-level reason"} -- 1918
	end -- 1918
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1920
	return {success = true, tool = tool, params = params, reason = reason} -- 1921
end -- 1921
function getDecisionPath(params) -- 2042
	if type(params.path) == "string" then -- 2042
		return __TS__StringTrim(params.path) -- 2043
	end -- 2043
	if type(params.target_file) == "string" then -- 2043
		return __TS__StringTrim(params.target_file) -- 2044
	end -- 2044
	return "" -- 2045
end -- 2045
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2048
	local num = __TS__Number(value) -- 2049
	if not __TS__NumberIsFinite(num) then -- 2049
		num = fallback -- 2050
	end -- 2050
	num = math.floor(num) -- 2051
	if num < minValue then -- 2051
		num = minValue -- 2052
	end -- 2052
	if maxValue ~= nil and num > maxValue then -- 2052
		num = maxValue -- 2053
	end -- 2053
	return num -- 2054
end -- 2054
function parseReadLineParam(value, fallback, paramName) -- 2057
	local num = __TS__Number(value) -- 2062
	if not __TS__NumberIsFinite(num) then -- 2062
		num = fallback -- 2063
	end -- 2063
	num = math.floor(num) -- 2064
	if num == 0 then -- 2064
		return {success = false, message = paramName .. " cannot be 0"} -- 2066
	end -- 2066
	return {success = true, value = num} -- 2068
end -- 2068
function validateDecision(tool, params) -- 2071
	if tool == "finish" then -- 2071
		local message = getFinishMessage(params) -- 2076
		if message == "" then -- 2076
			return {success = false, message = "finish requires params.message"} -- 2077
		end -- 2077
		params.message = message -- 2078
		local completion = getCompletionReport(params) -- 2079
		params.outcome = completion.outcome -- 2080
		params.validation = completion.validation -- 2081
		params.knownIssues = completion.knownIssues -- 2082
		params.assumptions = completion.assumptions -- 2083
		params.learningCandidates = completion.learningCandidates -- 2084
		return {success = true, params = params} -- 2085
	end -- 2085
	if tool == "read_file" then -- 2085
		local path = getDecisionPath(params) -- 2089
		if path == "" then -- 2089
			return {success = false, message = "read_file requires path"} -- 2090
		end -- 2090
		params.path = path -- 2091
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2092
		if not startLineRes.success then -- 2092
			return startLineRes -- 2093
		end -- 2093
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 2094
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2095
		if not endLineRes.success then -- 2095
			return endLineRes -- 2096
		end -- 2096
		params.startLine = startLineRes.value -- 2097
		params.endLine = endLineRes.value -- 2098
		return {success = true, params = params} -- 2099
	end -- 2099
	if tool == "edit_file" then -- 2099
		local path = getDecisionPath(params) -- 2103
		if path == "" then -- 2103
			return {success = false, message = "edit_file requires path"} -- 2104
		end -- 2104
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2105
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2106
		params.path = path -- 2107
		params.old_str = oldStr -- 2108
		params.new_str = newStr -- 2109
		return {success = true, params = params} -- 2110
	end -- 2110
	if tool == "delete_file" then -- 2110
		local targetFile = getDecisionPath(params) -- 2114
		if targetFile == "" then -- 2114
			return {success = false, message = "delete_file requires target_file"} -- 2115
		end -- 2115
		params.target_file = targetFile -- 2116
		return {success = true, params = params} -- 2117
	end -- 2117
	if tool == "grep_files" then -- 2117
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2121
		if pattern == "" then -- 2121
			return {success = false, message = "grep_files requires pattern"} -- 2122
		end -- 2122
		params.pattern = pattern -- 2123
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2124
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2125
		return {success = true, params = params} -- 2126
	end -- 2126
	if tool == "search_dora_api" then -- 2126
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2130
		if pattern == "" then -- 2130
			return {success = false, message = "search_dora_api requires pattern"} -- 2131
		end -- 2131
		params.pattern = pattern -- 2132
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2133
		return {success = true, params = params} -- 2134
	end -- 2134
	if tool == "glob_files" then -- 2134
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2138
		return {success = true, params = params} -- 2139
	end -- 2139
	if tool == "build" then -- 2139
		local path = getDecisionPath(params) -- 2143
		if path ~= "" then -- 2143
			params.path = path -- 2145
		end -- 2145
		return {success = true, params = params} -- 2147
	end -- 2147
	if tool == "list_sub_agents" then -- 2147
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2151
		if status ~= "" then -- 2151
			params.status = status -- 2153
		end -- 2153
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2155
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2156
		if type(params.query) == "string" then -- 2156
			params.query = __TS__StringTrim(params.query) -- 2158
		end -- 2158
		return {success = true, params = params} -- 2160
	end -- 2160
	if tool == "spawn_sub_agent" then -- 2160
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2164
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2165
		if prompt == "" then -- 2165
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2166
		end -- 2166
		if title == "" then -- 2166
			return {success = false, message = "spawn_sub_agent requires title"} -- 2167
		end -- 2167
		params.prompt = prompt -- 2168
		params.title = title -- 2169
		if type(params.expectedOutput) == "string" then -- 2169
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2171
		end -- 2171
		if isArray(params.filesHint) then -- 2171
			params.filesHint = __TS__ArrayMap( -- 2174
				__TS__ArrayFilter( -- 2174
					params.filesHint, -- 2174
					function(____, item) return type(item) == "string" end -- 2175
				), -- 2175
				function(____, item) return sanitizeUTF8(item) end -- 2176
			) -- 2176
		end -- 2176
		return {success = true, params = params} -- 2178
	end -- 2178
	return {success = true, params = params} -- 2181
end -- 2181
function validateCompletionForRole(role, tool, params) -- 2184
	if role ~= "sub" or tool ~= "finish" then -- 2184
		return {success = true} -- 2189
	end -- 2189
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2189
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2191
	end -- 2191
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2193
	do -- 2193
		local i = 0 -- 2194
		while i < #requiredArrays do -- 2194
			local name = requiredArrays[i + 1] -- 2195
			if not isArray(params[name]) then -- 2195
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2197
			end -- 2197
			i = i + 1 -- 2194
		end -- 2194
	end -- 2194
	return {success = true} -- 2200
end -- 2200
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2203
	if includeToolDefinitions == nil then -- 2203
		includeToolDefinitions = false -- 2203
	end -- 2203
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2204
	local sections = { -- 2207
		shared.promptPack.agentIdentityPrompt, -- 2208
		rolePrompt, -- 2209
		getReplyLanguageDirective(shared) -- 2210
	} -- 2210
	if shared.decisionMode == "tool_calling" then -- 2210
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2213
	end -- 2213
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2215
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2216
	if memoryContext ~= "" then -- 2216
		sections[#sections + 1] = memoryContext -- 2218
	end -- 2218
	local skillsSection = buildSkillsSection(shared) -- 2220
	if skillsSection ~= "" then -- 2220
		sections[#sections + 1] = skillsSection -- 2222
	end -- 2222
	if shared.resumeCheckpointPending == true then -- 2222
		local requiredTool = shared.resumeRequiredTool ~= nil and (" The engine will accept only `" .. shared.resumeRequiredTool) .. "` as the next tool." or "" -- 2225
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence over any prior completion state. Execute that instruction now." or "" -- 2228
		sections[#sections + 1] = ((("### Resume After Compression\n\nContext was just compressed. Continue the in-progress work; do not restart it." .. activeUserInstruction) .. " Treat the Session Summary's Active Checkpoint as authoritative for completed work and execute its next unfinished action now.") .. requiredTool) .. " If its next tool is `finish`, call `finish` immediately: edits only under `.agent/main` do not invalidate completed build, test, or lifecycle evidence. Files listed as authored or changed already exist: do not regenerate, restate, or overwrite their complete contents. Use a narrow read or targeted replacement only when the checkpoint or active user instruction requires a source fix. Do not restart discovery, glob, rerun validation, or reread files already listed as read or changed unless required for that fix. Do not expand scope." -- 2231
	end -- 2231
	if shared.buildRepairPending == true then -- 2231
		sections[#sections + 1] = "### Compiler Repair Mode\n\nThe latest build already returned concrete authored-file diagnostics. Repair those diagnostics directly with a narrow read or targeted edit, then build again. Search, glob, Dora API lookup, and execute_command are temporarily unavailable because they cannot clarify an exact compiler error." -- 2236
	end -- 2236
	if (shared.deterministicTestFailureCount or 0) >= 2 then -- 2236
		sections[#sections + 1] = "### Repeated Deterministic Test Failure\n\nThe same deterministic validation path has failed repeatedly. Do not simulate a longer history, derive a traversal/path, or keep tuning the same fixture architecture. Construct the smallest legal state immediately before the failing transition, perform one action, and assert the result. Read only the failing authored test/function, make one coherent edit, build, and rerun once." -- 2241
	end -- 2241
	if includeToolDefinitions then -- 2241
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2246
		if shared.decisionMode == "xml" then -- 2246
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2248
		end -- 2248
	end -- 2248
	return table.concat(sections, "\n\n") -- 2251
end -- 2251
function buildSkillsSection(shared) -- 2254
	local ____opt_43 = shared.skills -- 2254
	if not (____opt_43 and ____opt_43.loader) then -- 2254
		return "" -- 2256
	end -- 2256
	return shared.skills.loader:buildSkillsPromptSection() -- 2258
end -- 2258
function buildXmlDecisionInstruction(shared, feedback) -- 2387
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2388
end -- 2388
function tryParseAndValidateDecision(rawText, role) -- 2455
	if role == nil then -- 2455
		role = "main" -- 2455
	end -- 2455
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2456
	if not parsed.success then -- 2456
		return {success = false, message = parsed.message, raw = rawText} -- 2458
	end -- 2458
	local decision = parseDecisionObject(parsed.obj) -- 2460
	if not decision.success then -- 2460
		return {success = false, message = decision.message, raw = rawText} -- 2462
	end -- 2462
	local completionValidation = validateCompletionForRole(role, decision.tool, decision.params) -- 2464
	if not completionValidation.success then -- 2464
		return {success = false, message = completionValidation.message, raw = rawText} -- 2466
	end -- 2466
	local validation = validateDecision(decision.tool, decision.params) -- 2468
	if not validation.success then -- 2468
		return {success = false, message = validation.message, raw = rawText} -- 2470
	end -- 2470
	decision.params = validation.params -- 2472
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2473
	return decision -- 2474
end -- 2474
function executeToolAction(shared, action) -- 3797
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3797
		if shared.stopToken.stopped then -- 3797
			return ____awaiter_resolve( -- 3797
				nil, -- 3797
				{ -- 3799
					success = false, -- 3799
					message = getCancelledReason(shared) -- 3799
				} -- 3799
			) -- 3799
		end -- 3799
		if shared.resumeRequiredTool ~= nil then -- 3799
			if action.tool ~= shared.resumeRequiredTool then -- 3799
				return ____awaiter_resolve(nil, {success = false, message = ((("Compression checkpoint requires " .. shared.resumeRequiredTool) .. " next. Do not restart discovery or use ") .. action.tool) .. "."}) -- 3799
			end -- 3799
			shared.resumeRequiredTool = nil -- 3808
			shared.resumeCheckpointPending = false -- 3809
		end -- 3809
		local params = action.params -- 3811
		if action.tool == "read_file" then -- 3811
			local ____params_startLine_101 = params.startLine -- 3813
			if ____params_startLine_101 == nil then -- 3813
				____params_startLine_101 = 1 -- 3813
			end -- 3813
			local startLine = __TS__Number(____params_startLine_101) -- 3813
			local ____params_endLine_102 = params.endLine -- 3814
			if ____params_endLine_102 == nil then -- 3814
				____params_endLine_102 = READ_FILE_DEFAULT_LIMIT -- 3814
			end -- 3814
			local endLine = __TS__Number(____params_endLine_102) -- 3814
			local clippedAfterCompression = false -- 3815
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 3815
				endLine = startLine + 159 -- 3822
				clippedAfterCompression = true -- 3823
			end -- 3823
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3825
			if __TS__StringTrim(path) == "" then -- 3825
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3825
			end -- 3825
			if shared.failedTestNeedsBuild == true and string.sub( -- 3825
				string.lower(path), -- 3829
				-4 -- 3829
			) == ".lua" then -- 3829
				return ____awaiter_resolve(nil, {success = false, message = "The deterministic test report failed. Inspect and fix the authored source/test instead of reading generated Lua, then build successfully before testing again."}) -- 3829
			end -- 3829
			local result = Tools.readFile( -- 3835
				shared.workingDir, -- 3836
				path, -- 3837
				startLine, -- 3838
				endLine, -- 3839
				shared.useChineseResponse and "zh" or "en" -- 3840
			) -- 3840
			if clippedAfterCompression and result.success == true then -- 3840
				result.clipped = true -- 3843
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 3844
			end -- 3844
			return ____awaiter_resolve(nil, result) -- 3844
		end -- 3844
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 3844
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3851
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3854
			if __TS__StringTrim(path) ~= "" and oldStr == "" then -- 3854
				local existing = Tools.readFileRaw(shared.workingDir, path) -- 3856
				if existing.success then -- 3856
					return ____awaiter_resolve(nil, {success = false, message = "After compression, do not overwrite a complete existing file. Continue from the checkpoint with build, a narrow read, or a targeted old_str replacement."}) -- 3856
				end -- 3856
			end -- 3856
		end -- 3856
		if action.tool ~= "build" then -- 3856
			shared.resumeNarrowReadMode = false -- 3869
		end -- 3869
		if action.tool == "grep_files" then -- 3869
			local searchPath = params.path or "" -- 3871
			local searchGlobs = params.globs -- 3872
			local searchesGeneratedLua = string.sub( -- 3873
				string.lower(searchPath), -- 3873
				-4 -- 3873
			) == ".lua" -- 3873
			if not searchesGeneratedLua and searchGlobs ~= nil then -- 3873
				do -- 3873
					local i = 0 -- 3875
					while i < #searchGlobs do -- 3875
						if (string.find( -- 3875
							string.lower(searchGlobs[i + 1]), -- 3876
							".lua", -- 3876
							nil, -- 3876
							true -- 3876
						) or 0) - 1 >= 0 then -- 3876
							searchesGeneratedLua = true -- 3877
							break -- 3878
						end -- 3878
						i = i + 1 -- 3875
					end -- 3875
				end -- 3875
			end -- 3875
			if shared.failedTestNeedsBuild == true and searchesGeneratedLua then -- 3875
				return ____awaiter_resolve(nil, {success = false, message = "The deterministic test report failed. Search the authored source/test, not generated Lua, make the smallest source fix, and build successfully before testing again."}) -- 3875
			end -- 3875
			local ____Tools_searchFiles_115 = Tools.searchFiles -- 3888
			local ____shared_workingDir_109 = shared.workingDir -- 3889
			local ____temp_110 = params.pattern or "" -- 3891
			local ____params_globs_111 = params.globs -- 3892
			local ____params_useRegex_112 = params.useRegex -- 3893
			local ____params_caseSensitive_113 = params.caseSensitive -- 3894
			local ____math_max_105 = math.max -- 3897
			local ____math_floor_104 = math.floor -- 3897
			local ____params_limit_103 = params.limit -- 3897
			if ____params_limit_103 == nil then -- 3897
				____params_limit_103 = SEARCH_FILES_LIMIT_DEFAULT -- 3897
			end -- 3897
			local ____math_max_105_result_114 = ____math_max_105( -- 3897
				1, -- 3897
				____math_floor_104(__TS__Number(____params_limit_103)) -- 3897
			) -- 3897
			local ____math_max_108 = math.max -- 3898
			local ____math_floor_107 = math.floor -- 3898
			local ____params_offset_106 = params.offset -- 3898
			if ____params_offset_106 == nil then -- 3898
				____params_offset_106 = 0 -- 3898
			end -- 3898
			local result = __TS__Await(____Tools_searchFiles_115({ -- 3888
				workDir = ____shared_workingDir_109, -- 3889
				path = searchPath, -- 3890
				pattern = ____temp_110, -- 3891
				globs = ____params_globs_111, -- 3892
				useRegex = ____params_useRegex_112, -- 3893
				caseSensitive = ____params_caseSensitive_113, -- 3894
				includeContent = true, -- 3895
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3896
				limit = ____math_max_105_result_114, -- 3897
				offset = ____math_max_108( -- 3898
					0, -- 3898
					____math_floor_107(__TS__Number(____params_offset_106)) -- 3898
				), -- 3898
				groupByFile = params.groupByFile == true -- 3899
			})) -- 3899
			return ____awaiter_resolve(nil, result) -- 3899
		end -- 3899
		if action.tool == "search_dora_api" then -- 3899
			if shared.unbuiltEdits == true then -- 3899
				return ____awaiter_resolve(nil, {success = false, message = "Build the authored changes before another Dora API search. Search again only if the compiler or runtime diagnostics require an unfamiliar API."}) -- 3899
			end -- 3899
			if (shared.apiSearchesSinceBuild or 0) >= 1 then -- 3899
				return ____awaiter_resolve(nil, {success = false, message = "Only one Dora API lookup is allowed between builds. Apply the returned signature and build before searching again."}) -- 3899
			end -- 3899
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 3916
			local ____Tools_searchDoraAPI_123 = Tools.searchDoraAPI -- 3917
			local ____temp_119 = params.pattern or "" -- 3918
			local ____temp_120 = params.docSource or "api" -- 3919
			local ____temp_121 = shared.useChineseResponse and "zh" or "en" -- 3920
			local ____temp_122 = params.programmingLanguage or "ts" -- 3921
			local ____math_min_118 = math.min -- 3922
			local ____math_max_117 = math.max -- 3922
			local ____params_limit_116 = params.limit -- 3922
			if ____params_limit_116 == nil then -- 3922
				____params_limit_116 = 8 -- 3922
			end -- 3922
			local result = __TS__Await(____Tools_searchDoraAPI_123({ -- 3917
				pattern = ____temp_119, -- 3918
				docSource = ____temp_120, -- 3919
				docLanguage = ____temp_121, -- 3920
				programmingLanguage = ____temp_122, -- 3921
				limit = ____math_min_118( -- 3922
					SEARCH_DORA_API_LIMIT_MAX, -- 3922
					____math_max_117( -- 3922
						1, -- 3922
						__TS__Number(____params_limit_116) -- 3922
					) -- 3922
				), -- 3922
				useRegex = params.useRegex, -- 3923
				caseSensitive = false, -- 3924
				includeContent = true, -- 3925
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3926
			})) -- 3926
			return ____awaiter_resolve(nil, result) -- 3926
		end -- 3926
		if action.tool == "glob_files" then -- 3926
			local ____Tools_listFiles_130 = Tools.listFiles -- 3931
			local ____shared_workingDir_127 = shared.workingDir -- 3932
			local ____temp_128 = params.path or "" -- 3933
			local ____params_globs_129 = params.globs -- 3934
			local ____math_max_126 = math.max -- 3935
			local ____math_floor_125 = math.floor -- 3935
			local ____params_maxEntries_124 = params.maxEntries -- 3935
			if ____params_maxEntries_124 == nil then -- 3935
				____params_maxEntries_124 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3935
			end -- 3935
			local result = ____Tools_listFiles_130({ -- 3931
				workDir = ____shared_workingDir_127, -- 3932
				path = ____temp_128, -- 3933
				globs = ____params_globs_129, -- 3934
				maxEntries = ____math_max_126( -- 3935
					1, -- 3935
					____math_floor_125(__TS__Number(____params_maxEntries_124)) -- 3935
				) -- 3935
			}) -- 3935
			return ____awaiter_resolve(nil, result) -- 3935
		end -- 3935
		if action.tool == "delete_file" then -- 3935
			local editLimit = 3 -- 3940
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3941
			if __TS__StringTrim(targetFile) == "" then -- 3941
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3941
			end -- 3941
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 3945
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 3946
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 and #editedPaths >= editLimit then -- 3946
				return ____awaiter_resolve(nil, {success = false, message = "Build the current authored changes now before editing a fourth source file. Multiple related replacements in the same source file count as one build-cycle edit."}) -- 3946
			end -- 3946
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 3946
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 3946
			end -- 3946
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3956
			if not result.success then -- 3956
				return ____awaiter_resolve(nil, result) -- 3956
			end -- 3956
			shared.unbuiltEdits = true -- 3963
			if shared.failedTestNeedsBuild == true then -- 3963
				shared.failedTestHasSourceEdit = true -- 3964
			end -- 3964
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 3964
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 3965
			end -- 3965
			shared.editedPathsSinceBuild = editedPaths -- 3966
			shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 3967
			return ____awaiter_resolve(nil, { -- 3967
				success = true, -- 3969
				changed = true, -- 3970
				mode = "delete", -- 3971
				checkpointId = result.checkpointId, -- 3972
				checkpointSeq = result.checkpointSeq, -- 3973
				files = {{path = targetFile, op = "delete"}} -- 3974
			}) -- 3974
		end -- 3974
		if action.tool == "build" then -- 3974
			local buildPath = params.path or "" -- 3978
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 3979
			shared.unbuiltEdits = false -- 3983
			shared.editsSinceBuild = 0 -- 3984
			shared.editedPathsSinceBuild = {} -- 3985
			shared.hasBuilt = true -- 3986
			local normalizedBuildPath = ____exports.normalizePolicyPath(buildPath) -- 3987
			local builtWholeProject = normalizedBuildPath == "" or normalizedBuildPath == "." -- 3988
			if result.success and builtWholeProject then -- 3988
				shared.freshProjectBuildPending = false -- 3989
			end -- 3989
			shared.apiSearchesSinceBuild = 0 -- 3990
			shared.buildRepairPending = false -- 3991
			if not result.success and result.messages ~= nil then -- 3991
				do -- 3991
					local i = 0 -- 3993
					while i < #result.messages do -- 3993
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 3993
							shared.buildRepairPending = true -- 3995
							break -- 3996
						end -- 3996
						i = i + 1 -- 3993
					end -- 3993
				end -- 3993
			end -- 3993
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 3993
				shared.failedTestNeedsBuild = false -- 4001
				shared.failedTestHasSourceEdit = false -- 4002
			end -- 4002
			return ____awaiter_resolve(nil, result) -- 4002
		end -- 4002
		if action.tool == "fetch_url" then -- 4002
			if __TS__ArrayIndexOf(shared.disabledAgentTools, "fetch_url") >= 0 then -- 4002
				return ____awaiter_resolve(nil, {success = false, state = "failed", message = "fetch_url is not enabled for this session"}) -- 4002
			end -- 4002
			local result = __TS__Await(Tools.fetchUrl({ -- 4010
				workDir = shared.workingDir, -- 4011
				url = type(params.url) == "string" and params.url or "", -- 4012
				target = type(params.target) == "string" and params.target or "", -- 4013
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4014
				onProgress = function(____, progress) -- 4015
					emitAgentEvent( -- 4016
						shared, -- 4016
						{ -- 4016
							type = "tool_progress", -- 4017
							sessionId = shared.sessionId, -- 4018
							taskId = shared.taskId, -- 4019
							step = action.step, -- 4020
							tool = action.tool, -- 4021
							result = __TS__ObjectAssign({success = false}, progress) -- 4022
						} -- 4022
					) -- 4022
				end -- 4015
			})) -- 4015
			return ____awaiter_resolve(nil, result) -- 4015
		end -- 4015
		if action.tool == "execute_command" then -- 4015
			if __TS__ArrayIndexOf(shared.disabledAgentTools, "execute_command") >= 0 then -- 4015
				return ____awaiter_resolve(nil, {success = false, message = "execute_command is not enabled for this session"}) -- 4015
			end -- 4015
			if shared.failedTestNeedsBuild == true then -- 4015
				return ____awaiter_resolve(nil, {success = false, message = "The deterministic test report failed. Read the authored source/test, make the smallest source fix, and build successfully before running another command. Do not probe generated Lua or instantiate compiled TypeScript classes from Lua."}) -- 4015
			end -- 4015
			local mode = type(params.mode) == "string" and params.mode or "" -- 4041
			local result = __TS__Await(Tools.executeCommand({ -- 4042
				workDir = shared.workingDir, -- 4043
				mode = mode, -- 4044
				code = type(params.code) == "string" and params.code or nil, -- 4045
				command = type(params.command) == "string" and params.command or nil, -- 4046
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4047
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4048
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4049
				onProgress = function(____, progress) -- 4050
					emitAgentEvent( -- 4051
						shared, -- 4051
						{ -- 4051
							type = "tool_progress", -- 4052
							sessionId = shared.sessionId, -- 4053
							taskId = shared.taskId, -- 4054
							step = action.step, -- 4055
							tool = action.tool, -- 4056
							result = __TS__ObjectAssign({success = false}, progress) -- 4057
						} -- 4057
					) -- 4057
				end -- 4050
			})) -- 4050
			if result.success and mode == "lua" then -- 4050
				local deterministicFailure = false -- 4065
				local deterministicPass = false -- 4066
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4067
				do -- 4067
					local i = 0 -- 4068
					while i < #outputLines and not deterministicFailure do -- 4068
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4069
						if line == "passed" then -- 4069
							deterministicPass = true -- 4070
						end -- 4070
						if line == "failed" then -- 4070
							deterministicFailure = true -- 4072
							break -- 4073
						end -- 4073
						local searchFrom = 0 -- 4075
						while searchFrom < #line do -- 4075
							local failedIndex = (string.find( -- 4077
								line, -- 4077
								"failed", -- 4077
								math.max(searchFrom + 1, 1), -- 4077
								true -- 4077
							) or 0) - 1 -- 4077
							if failedIndex < 0 then -- 4077
								break -- 4078
							end -- 4078
							local after = failedIndex + #"failed" -- 4079
							while after < #line do -- 4079
								local ch = __TS__StringSlice(line, after, after + 1) -- 4081
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4081
									break -- 4082
								end -- 4082
								after = after + 1 -- 4083
							end -- 4083
							local afterEnd = after -- 4085
							while afterEnd < #line do -- 4085
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4087
								if ch < "0" or ch > "9" then -- 4087
									break -- 4088
								end -- 4088
								afterEnd = afterEnd + 1 -- 4089
							end -- 4089
							local count -- 4091
							if afterEnd > after then -- 4091
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4093
							else -- 4093
								local before = failedIndex - 1 -- 4095
								while before >= 0 do -- 4095
									local ch = __TS__StringSlice(line, before, before + 1) -- 4097
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4097
										break -- 4098
									end -- 4098
									before = before - 1 -- 4099
								end -- 4099
								local beforeEnd = before + 1 -- 4101
								while before >= 0 do -- 4101
									local ch = __TS__StringSlice(line, before, before + 1) -- 4103
									if ch < "0" or ch > "9" then -- 4103
										break -- 4104
									end -- 4104
									before = before - 1 -- 4105
								end -- 4105
								if beforeEnd > before + 1 then -- 4105
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4107
								end -- 4107
							end -- 4107
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4107
								deterministicFailure = true -- 4110
								break -- 4111
							end -- 4111
							searchFrom = failedIndex + #"failed" -- 4113
						end -- 4113
						i = i + 1 -- 4068
					end -- 4068
				end -- 4068
				if deterministicFailure then -- 4068
					shared.failedTestNeedsBuild = true -- 4117
					shared.failedTestHasSourceEdit = false -- 4118
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4119
				elseif deterministicPass then -- 4119
					shared.deterministicTestFailureCount = 0 -- 4121
				end -- 4121
			end -- 4121
			return ____awaiter_resolve(nil, result) -- 4121
		end -- 4121
		if action.tool == "spawn_sub_agent" then -- 4121
			if not shared.spawnSubAgent then -- 4121
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4121
			end -- 4121
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4121
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4121
			end -- 4121
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4133
				params.filesHint, -- 4134
				function(____, item) return type(item) == "string" end -- 4134
			) or nil -- 4134
			local result = __TS__Await(shared.spawnSubAgent({ -- 4136
				parentSessionId = shared.sessionId, -- 4137
				projectRoot = shared.workingDir, -- 4138
				title = type(params.title) == "string" and params.title or "Sub", -- 4139
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4140
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4141
				filesHint = filesHint, -- 4142
				disabledAgentTools = shared.disabledAgentTools -- 4143
			})) -- 4143
			if not result.success then -- 4143
				return ____awaiter_resolve(nil, result) -- 4143
			end -- 4143
			return ____awaiter_resolve(nil, { -- 4143
				success = true, -- 4149
				sessionId = result.sessionId, -- 4150
				taskId = result.taskId, -- 4151
				title = result.title, -- 4152
				hint = "Continue useful foreground work after dispatching, but do not immediately poll newly spawned sub-agents. Their results arrive as asynchronous handoffs." -- 4153
			}) -- 4153
		end -- 4153
		if action.tool == "list_sub_agents" then -- 4153
			if not shared.listSubAgents then -- 4153
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4153
			end -- 4153
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4153
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4153
			end -- 4153
			local result = __TS__Await(shared.listSubAgents({ -- 4163
				sessionId = shared.sessionId, -- 4164
				projectRoot = shared.workingDir, -- 4165
				status = type(params.status) == "string" and params.status or nil, -- 4166
				limit = type(params.limit) == "number" and params.limit or nil, -- 4167
				offset = type(params.offset) == "number" and params.offset or nil, -- 4168
				query = type(params.query) == "string" and params.query or nil -- 4169
			})) -- 4169
			return ____awaiter_resolve(nil, result) -- 4169
		end -- 4169
		if action.tool == "edit_file" then -- 4169
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4174
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4177
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4178
			if __TS__StringTrim(path) == "" then -- 4178
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4178
			end -- 4178
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4180
			local isMemoryEdit = ____exports.isMainAgentMemoryPath(normalizedPath) -- 4181
			if not isMemoryEdit then -- 4181
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4183
				if preflightIssue ~= nil then -- 4183
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4185
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4186
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4186
				end -- 4186
			end -- 4186
			if not isMemoryEdit then -- 4186
				local editLimit = 3 -- 4193
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4194
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 and #editedPaths >= editLimit then -- 4194
					return ____awaiter_resolve(nil, {success = false, message = "Build the current authored changes now before editing a fourth source file. Multiple related replacements in the same source file count as one build-cycle edit."}) -- 4194
				end -- 4194
			end -- 4194
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4202
			local result = __TS__Await(actionNode:exec({ -- 4203
				path = path, -- 4204
				oldStr = oldStr, -- 4205
				newStr = newStr, -- 4206
				taskId = shared.taskId, -- 4207
				workDir = shared.workingDir -- 4208
			})) -- 4208
			if not isMemoryEdit and result.success == true and result.changed ~= false then -- 4208
				shared.unbuiltEdits = true -- 4211
				if shared.failedTestNeedsBuild == true then -- 4211
					shared.failedTestHasSourceEdit = true -- 4212
				end -- 4212
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4213
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4213
					editedPaths[#editedPaths + 1] = normalizedPath -- 4214
				end -- 4214
				shared.editedPathsSinceBuild = editedPaths -- 4215
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4216
			end -- 4216
			return ____awaiter_resolve(nil, result) -- 4216
		end -- 4216
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4216
	end) -- 4216
end -- 4216
function sanitizeToolActionResultForHistory(action, result) -- 4223
	if action.tool == "read_file" then -- 4223
		return sanitizeReadResultForHistory(action.tool, result) -- 4225
	end -- 4225
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4225
		return sanitizeSearchResultForHistory(action.tool, result) -- 4228
	end -- 4228
	if action.tool == "glob_files" then -- 4228
		return sanitizeListFilesResultForHistory(result) -- 4231
	end -- 4231
	if action.tool == "build" then -- 4231
		return sanitizeBuildResultForHistory(result) -- 4234
	end -- 4234
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4234
		if result.success ~= true then -- 4234
			return result -- 4237
		end -- 4237
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4237
			return result -- 4238
		end -- 4238
		if isArray(result.fileContext) then -- 4238
			return result -- 4239
		end -- 4239
		local contextLimits = { -- 4241
			fullContentChars = 12000, -- 4242
			previewChars = 4000, -- 4243
			diffChars = 8000, -- 4244
			totalChars = 24000, -- 4245
			maxFiles = 8 -- 4246
		} -- 4246
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4248
			if maxChars <= 0 then -- 4248
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4249
			end -- 4249
			if #sourceText <= maxChars then -- 4249
				return sourceText -- 4250
			end -- 4250
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4251
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4252
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4253
		end -- 4248
		local function countLines(sourceText) -- 4255
			if sourceText == "" then -- 4255
				return 0 -- 4256
			end -- 4256
			return #__TS__StringSplit(sourceText, "\n") -- 4257
		end -- 4255
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4259
			if beforeContent == afterContent then -- 4259
				return "" -- 4260
			end -- 4260
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4261
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4262
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4264
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4264
				firstChangedLine = firstChangedLine + 1 -- 4270
			end -- 4270
			local lastChangedBeforeLine = #beforeLines - 1 -- 4272
			local lastChangedAfterLine = #afterLines - 1 -- 4273
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4273
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4279
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4280
			end -- 4280
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4282
			local previewEndLine = math.max( -- 4283
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4284
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4285
			) -- 4285
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4287
			do -- 4287
				local lineIndex = previewStartLine -- 4288
				while lineIndex <= previewEndLine do -- 4288
					do -- 4288
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4289
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4290
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4291
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4292
						if not beforeChanged and not afterChanged then -- 4292
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4294
							if contextLine ~= nil then -- 4294
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4295
							end -- 4295
							goto __continue732 -- 4296
						end -- 4296
						if beforeChanged and beforeLine ~= nil then -- 4296
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4298
						end -- 4298
						if afterChanged and afterLine ~= nil then -- 4298
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4299
						end -- 4299
					end -- 4299
					::__continue732:: -- 4299
					lineIndex = lineIndex + 1 -- 4288
				end -- 4288
			end -- 4288
			return truncateContextSnippet( -- 4301
				table.concat(unifiedDiffLines, "\n"), -- 4301
				maxChars, -- 4301
				"diff" -- 4301
			) -- 4301
		end -- 4259
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4304
		if not checkpointDiff.success then -- 4304
			return result -- 4305
		end -- 4305
		local remainingContextBudget = contextLimits.totalChars -- 4306
		local fileContextItems = {} -- 4307
		local changedFiles = checkpointDiff.files -- 4308
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4309
		do -- 4309
			local fileIndex = 0 -- 4310
			while fileIndex < maxContextFiles do -- 4310
				if remainingContextBudget <= 0 then -- 4310
					break -- 4311
				end -- 4311
				local changedFile = changedFiles[fileIndex + 1] -- 4312
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4313
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4314
				local contextItem = { -- 4315
					path = changedFile.path, -- 4316
					op = changedFile.op, -- 4317
					checkpointId = result.checkpointId, -- 4318
					checkpointSeq = result.checkpointSeq, -- 4319
					beforeExists = changedFile.beforeExists, -- 4320
					afterExists = changedFile.afterExists, -- 4321
					beforeBytes = #beforeContent, -- 4322
					afterBytes = #afterContent, -- 4323
					diffPreview = "", -- 4324
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4325
					contentTruncated = false, -- 4326
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4327
				} -- 4327
				if changedFile.afterExists then -- 4327
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4327
						contextItem.afterContent = afterContent -- 4331
						remainingContextBudget = remainingContextBudget - #afterContent -- 4332
					else -- 4332
						contextItem.afterContentPreview = truncateContextSnippet( -- 4334
							afterContent, -- 4335
							math.min( -- 4336
								contextLimits.previewChars, -- 4336
								math.max(400, remainingContextBudget) -- 4336
							), -- 4336
							"afterContent" -- 4337
						) -- 4337
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4339
						contextItem.contentTruncated = true -- 4340
					end -- 4340
				end -- 4340
				local diffPreview = buildUnifiedDiffPreview( -- 4343
					changedFile.path, -- 4344
					beforeContent, -- 4345
					afterContent, -- 4346
					math.min( -- 4347
						contextLimits.diffChars, -- 4347
						math.max(400, remainingContextBudget) -- 4347
					) -- 4347
				) -- 4347
				contextItem.diffPreview = diffPreview -- 4349
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4350
				if not changedFile.afterExists and beforeContent ~= "" then -- 4350
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4352
						beforeContent, -- 4353
						math.min( -- 4354
							contextLimits.previewChars, -- 4354
							math.max(400, remainingContextBudget) -- 4354
						), -- 4354
						"beforeContent" -- 4355
					) -- 4355
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4357
					if #beforeContent > contextLimits.previewChars then -- 4357
						contextItem.contentTruncated = true -- 4358
					end -- 4358
				end -- 4358
				fileContextItems[#fileContextItems + 1] = contextItem -- 4360
				fileIndex = fileIndex + 1 -- 4310
			end -- 4310
		end -- 4310
		if #fileContextItems == 0 then -- 4310
			return result -- 4362
		end -- 4362
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4363
	end -- 4363
	return result -- 4370
end -- 4370
function emitAgentTaskFinishEvent(shared, success, message) -- 4539
	local completion = shared.completion or ____exports.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4540
	local result = success and ({ -- 4544
		success = true, -- 4546
		taskId = shared.taskId, -- 4547
		message = message, -- 4548
		steps = shared.step, -- 4549
		completion = completion -- 4550
	}) or ({ -- 4550
		success = false, -- 4553
		taskId = shared.taskId, -- 4554
		message = message, -- 4555
		steps = shared.step, -- 4556
		completion = completion -- 4557
	}) -- 4557
	emitAgentEvent(shared, { -- 4559
		type = "task_finished", -- 4560
		sessionId = shared.sessionId, -- 4561
		taskId = shared.taskId, -- 4562
		success = result.success, -- 4563
		message = result.message, -- 4564
		steps = result.steps, -- 4565
		completion = result.completion -- 4566
	}) -- 4566
	return result -- 4568
end -- 4568
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 132
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 258
HISTORY_READ_FILE_MAX_LINES = 300 -- 259
READ_FILE_DEFAULT_LIMIT = 300 -- 260
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 261
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 262
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 263
HISTORY_BUILD_MAX_MESSAGES = 50 -- 264
HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 265
SEARCH_DORA_API_LIMIT_MAX = 20 -- 266
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 267
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 268
SEARCH_PREVIEW_CONTEXT = 80 -- 269
local AGENT_DEFAULT_MAX_STEPS = 100 -- 270
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 271
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 272
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 273
local function buildLLMOptions(llmConfig, overrides) -- 275
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 276
	if llmConfig.reasoningEffort then -- 276
		options.reasoning_effort = llmConfig.reasoningEffort -- 281
	end -- 281
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 283
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 283
		__TS__Delete(merged, "reasoning_effort") -- 288
	else -- 288
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 290
	end -- 290
	__TS__Delete(merged, "tool_choice") -- 295
	return merged -- 296
end -- 275
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 413
	local messagesTokens = 0 -- 420
	do -- 420
		local i = 0 -- 421
		while i < #messages do -- 421
			local message = messages[i + 1] -- 422
			messagesTokens = messagesTokens + 8 -- 423
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 424
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 425
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 426
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 427
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 428
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 429
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 430
			i = i + 1 -- 421
		end -- 421
	end -- 421
	local toolDefinitionsTokens = 0 -- 433
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 433
		local toolsText = safeJsonEncode(options.tools) -- 435
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 436
	end -- 436
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 439
	__TS__Delete(optionsWithoutTools, "tools") -- 440
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 441
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 442
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 443
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 444
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 449
		1024, -- 451
		math.floor(contextWindow * 0.2) -- 451
	) -- 451
	local structuralOverhead = math.max(256, #messages * 16) -- 452
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 454
	local maxTokens = contextWindow -- 455
	emitAgentEvent( -- 456
		shared, -- 456
		{ -- 456
			type = "metrics_updated", -- 457
			sessionId = shared.sessionId, -- 458
			taskId = shared.taskId, -- 459
			step = step, -- 460
			metrics = {context = { -- 461
				usedTokens = usedTokens, -- 463
				maxTokens = maxTokens, -- 464
				ratio = math.max( -- 465
					0, -- 465
					math.min(1, usedTokens / maxTokens) -- 465
				), -- 465
				messagesTokens = messagesTokens, -- 466
				optionsTokens = optionsTokens, -- 467
				toolDefinitionsTokens = toolDefinitionsTokens, -- 468
				reservedOutputTokens = reservedOutputTokens, -- 469
				structuralOverhead = structuralOverhead, -- 470
				contextWindow = contextWindow, -- 471
				source = "llm_input_estimate", -- 472
				updatedAt = os.time(), -- 473
				phase = phase, -- 474
				step = step -- 475
			}} -- 475
		} -- 475
	) -- 475
end -- 413
local function emitAgentStartEvent(shared, action) -- 481
	emitAgentEvent(shared, { -- 482
		type = "tool_started", -- 483
		sessionId = shared.sessionId, -- 484
		taskId = shared.taskId, -- 485
		step = action.step, -- 486
		tool = action.tool -- 487
	}) -- 487
end -- 481
local function emitAgentFinishEvent(shared, action) -- 491
	emitAgentEvent(shared, { -- 492
		type = "tool_finished", -- 493
		sessionId = shared.sessionId, -- 494
		taskId = shared.taskId, -- 495
		step = action.step, -- 496
		tool = action.tool, -- 497
		result = action.result or ({}) -- 498
	}) -- 498
end -- 491
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 502
	emitAgentEvent(shared, { -- 503
		type = "assistant_message_updated", -- 504
		sessionId = shared.sessionId, -- 505
		taskId = shared.taskId, -- 506
		step = shared.step + 1, -- 507
		content = content, -- 508
		reasoningContent = reasoningContent -- 509
	}) -- 509
end -- 502
local function getMemoryCompressionStartReason(shared) -- 513
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 514
end -- 513
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 519
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 520
end -- 519
local function getMemoryCompressionFailureReason(shared, ____error) -- 525
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 526
end -- 525
local function summarizeHistoryEntryPreview(text, maxChars) -- 531
	if maxChars == nil then -- 531
		maxChars = 180 -- 531
	end -- 531
	local trimmed = __TS__StringTrim(text) -- 532
	if trimmed == "" then -- 532
		return "" -- 533
	end -- 533
	return truncateText(trimmed, maxChars) -- 534
end -- 531
local function getMaxStepsReachedReason(shared) -- 542
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 543
end -- 542
local function getFailureSummaryFallback(shared, ____error) -- 548
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 549
end -- 548
local function finalizeAgentFailure(shared, ____error) -- 554
	if shared.stopToken.stopped then -- 554
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 556
		return emitAgentTaskFinishEvent( -- 557
			shared, -- 557
			false, -- 557
			getCancelledReason(shared) -- 557
		) -- 557
	end -- 557
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 559
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 560
end -- 554
local function getPromptCommand(prompt) -- 563
	local trimmed = __TS__StringTrim(prompt) -- 564
	if trimmed == "/compact" then -- 564
		return "compact" -- 565
	end -- 565
	if trimmed == "/clear" then -- 565
		return "clear" -- 566
	end -- 566
	return nil -- 567
end -- 563
function ____exports.truncateAgentUserPrompt(prompt) -- 570
	if not prompt then -- 570
		return "" -- 571
	end -- 571
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 571
		return prompt -- 572
	end -- 572
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 573
	if offset == nil then -- 573
		return prompt -- 574
	end -- 574
	return string.sub(prompt, 1, offset - 1) -- 575
end -- 570
local function canWriteStepLLMDebug(shared, stepId) -- 578
	if stepId == nil then -- 578
		stepId = shared.step + 1 -- 578
	end -- 578
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 579
end -- 578
local function ensureDirRecursive(dir) -- 586
	if not dir then -- 586
		return false -- 587
	end -- 587
	if Content:exist(dir) then -- 587
		return Content:isdir(dir) -- 588
	end -- 588
	local parent = Path:getPath(dir) -- 589
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 589
		return false -- 591
	end -- 591
	return Content:mkdir(dir) -- 593
end -- 586
local function encodeDebugJSON(value) -- 596
	local text, err = safeJsonEncode(value) -- 597
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 598
end -- 596
local FRESH_PROJECT_CODE_GLOBS = { -- 617
	"**/*.ts", -- 618
	"**/*.tsx", -- 619
	"**/*.lua", -- 620
	"**/*.yue", -- 621
	"**/*.tl", -- 622
	"**/*.yarn", -- 623
	"**/*.xml", -- 624
	"!**/*.d.ts" -- 625
} -- 625
local function inspectFreshProject(workDir) -- 628
	local result = Tools.listFiles({workDir = workDir, path = "", globs = FRESH_PROJECT_CODE_GLOBS, maxEntries = 2}) -- 629
	if not result.success then -- 629
		return {fresh = false} -- 635
	end -- 635
	local totalEntries = result.totalEntries or #result.files -- 636
	if totalEntries > 1 then -- 636
		return {fresh = false} -- 637
	end -- 637
	if totalEntries == 0 then -- 637
		return {fresh = true} -- 638
	end -- 638
	if #result.files ~= 1 then -- 638
		return {fresh = false} -- 639
	end -- 639
	local path = result.files[1] -- 640
	local loaded = Tools.readFileRaw(workDir, path) -- 641
	if not loaded.success or loaded.content == nil then -- 641
		return {fresh = false} -- 642
	end -- 642
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 643
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 646
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 647
end -- 628
local function getStepLLMDebugDir(shared) -- 650
	return Path( -- 651
		shared.workingDir, -- 652
		".agent", -- 653
		tostring(shared.sessionId), -- 654
		tostring(shared.taskId) -- 655
	) -- 655
end -- 650
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 659
	return Path( -- 660
		getStepLLMDebugDir(shared), -- 660
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 660
	) -- 660
end -- 659
local function getLatestStepLLMDebugSeq(shared, stepId) -- 663
	if not canWriteStepLLMDebug(shared, stepId) then -- 663
		return 0 -- 664
	end -- 664
	local dir = getStepLLMDebugDir(shared) -- 665
	if not Content:exist(dir) or not Content:isdir(dir) then -- 665
		return 0 -- 666
	end -- 666
	local latest = 0 -- 667
	for ____, file in ipairs(Content:getFiles(dir)) do -- 668
		do -- 668
			local name = Path:getFilename(file) -- 669
			local seqText = string.match( -- 670
				name, -- 670
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 670
			) -- 670
			if seqText ~= nil then -- 670
				latest = math.max( -- 672
					latest, -- 672
					tonumber(seqText) -- 672
				) -- 672
				goto __continue57 -- 673
			end -- 673
			local legacyMatch = string.match( -- 675
				name, -- 675
				("^" .. tostring(stepId)) .. "_in%.md$" -- 675
			) -- 675
			if legacyMatch ~= nil then -- 675
				latest = math.max(latest, 1) -- 677
			end -- 677
		end -- 677
		::__continue57:: -- 677
	end -- 677
	return latest -- 680
end -- 663
local function writeStepLLMDebugFile(path, content) -- 683
	if not Content:save(path, content) then -- 683
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 685
		return false -- 686
	end -- 686
	return true -- 688
end -- 683
local function createStepLLMDebugPair(shared, stepId, inContent) -- 691
	if not canWriteStepLLMDebug(shared, stepId) then -- 691
		return 0 -- 692
	end -- 692
	local dir = getStepLLMDebugDir(shared) -- 693
	if not ensureDirRecursive(dir) then -- 693
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 695
		return 0 -- 696
	end -- 696
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 698
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 699
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 700
	if not writeStepLLMDebugFile(inPath, inContent) then -- 700
		return 0 -- 702
	end -- 702
	writeStepLLMDebugFile(outPath, "") -- 704
	return seq -- 705
end -- 691
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 708
	if not canWriteStepLLMDebug(shared, stepId) then -- 708
		return -- 709
	end -- 709
	local dir = getStepLLMDebugDir(shared) -- 710
	if not ensureDirRecursive(dir) then -- 710
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 712
		return -- 713
	end -- 713
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 715
	if latestSeq <= 0 then -- 715
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 717
		writeStepLLMDebugFile(outPath, content) -- 718
		return -- 719
	end -- 719
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 721
	writeStepLLMDebugFile(outPath, content) -- 722
end -- 708
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 725
	if not canWriteStepLLMDebug(shared, stepId) then -- 725
		return -- 726
	end -- 726
	local sections = { -- 727
		"# LLM Input", -- 728
		"session_id: " .. tostring(shared.sessionId), -- 729
		"task_id: " .. tostring(shared.taskId), -- 730
		"step_id: " .. tostring(stepId), -- 731
		"phase: " .. phase, -- 732
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 733
		"## Options", -- 734
		"```json", -- 735
		encodeDebugJSON(options), -- 736
		"```" -- 737
	} -- 737
	local firstMessage = #messages > 0 and messages[1] or nil -- 739
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 739
		sections[#sections + 1] = "# System Prompt" -- 741
		sections[#sections + 1] = firstMessage.content -- 742
	end -- 742
	do -- 742
		local i = 0 -- 744
		while i < #messages do -- 744
			local message = messages[i + 1] -- 745
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 746
			sections[#sections + 1] = encodeDebugJSON(message) -- 747
			i = i + 1 -- 744
		end -- 744
	end -- 744
	createStepLLMDebugPair( -- 749
		shared, -- 749
		stepId, -- 749
		table.concat(sections, "\n") -- 749
	) -- 749
end -- 725
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 752
	if not canWriteStepLLMDebug(shared, stepId) then -- 752
		return -- 753
	end -- 753
	local ____array_0 = __TS__SparseArrayNew( -- 753
		"# LLM Output", -- 755
		"session_id: " .. tostring(shared.sessionId), -- 756
		"task_id: " .. tostring(shared.taskId), -- 757
		"step_id: " .. tostring(stepId), -- 758
		"phase: " .. phase, -- 759
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 760
		table.unpack(meta and ({ -- 761
			"## Meta", -- 761
			"```json", -- 761
			encodeDebugJSON(meta), -- 761
			"```" -- 761
		}) or ({})) -- 761
	) -- 761
	__TS__SparseArrayPush(____array_0, "## Content", text) -- 761
	local sections = {__TS__SparseArraySpread(____array_0)} -- 754
	updateLatestStepLLMDebugOutput( -- 765
		shared, -- 765
		stepId, -- 765
		table.concat(sections, "\n") -- 765
	) -- 765
end -- 752
local function toJson(value, emptyAsArray) -- 768
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 769
	if text ~= nil then -- 769
		return text -- 770
	end -- 770
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 771
end -- 768
local function summarizeEditTextParamForHistory(value, key) -- 821
	if type(value) ~= "string" then -- 821
		return nil -- 822
	end -- 822
	local text = value -- 823
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 824
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 825
end -- 821
local function sanitizeActionParamsForHistory(tool, params) -- 941
	if tool ~= "edit_file" then -- 941
		return params -- 942
	end -- 942
	local clone = {} -- 943
	for key in pairs(params) do -- 944
		if key == "old_str" then -- 944
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 946
		elseif key == "new_str" then -- 946
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 948
		else -- 948
			clone[key] = params[key] -- 950
		end -- 950
	end -- 950
	return clone -- 953
end -- 941
local function getDecisionToolSchemaText(shared) -- 1059
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1060
		shared.role, -- 1060
		SEARCH_DORA_API_LIMIT_MAX, -- 1060
		{disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared)} -- 1060
	)) -- 1060
	return toolsText or "" -- 1063
end -- 1059
local function isToolAllowedForRole(shared, tool) -- 1066
	return __TS__ArrayIndexOf( -- 1067
		AgentToolRegistry.getAllowedToolsForRole( -- 1067
			shared.role, -- 1067
			{disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared)} -- 1067
		), -- 1067
		tool -- 1069
	) >= 0 -- 1069
end -- 1066
local function clearPreExecutedResults(shared) -- 1072
	shared.preExecutedResults = nil -- 1073
end -- 1072
local function startPreExecutedToolAction(shared, action) -- 1076
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1076
		local ____hasReturned, ____returnValue -- 1076
		local ____try = __TS__AsyncAwaiter(function() -- 1076
			____hasReturned = true -- 1078
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1078
			return -- 1078
		end) -- 1078
		____try = ____try.catch( -- 1078
			____try, -- 1078
			function(____, err) -- 1078
				return __TS__AsyncAwaiter(function() -- 1078
					local message = tostring(err) -- 1080
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1081
					____hasReturned = true -- 1082
					____returnValue = {success = false, message = message} -- 1082
					return -- 1082
				end) -- 1082
			end -- 1082
		) -- 1082
		__TS__Await(____try) -- 1077
		if ____hasReturned then -- 1077
			return ____awaiter_resolve(nil, ____returnValue) -- 1077
		end -- 1077
	end) -- 1077
end -- 1076
local function createPreExecutedToolResult(shared, action) -- 1086
	local cloneParamValue -- 1087
	cloneParamValue = function(value) -- 1087
		if value == nil then -- 1087
			return value -- 1088
		end -- 1088
		if isArray(value) then -- 1088
			return __TS__ArrayMap( -- 1090
				value, -- 1090
				function(____, item) return cloneParamValue(item) end -- 1090
			) -- 1090
		end -- 1090
		if type(value) == "table" then -- 1090
			local clone = {} -- 1093
			for key in pairs(value) do -- 1094
				clone[key] = cloneParamValue(value[key]) -- 1095
			end -- 1095
			return clone -- 1097
		end -- 1097
		return value -- 1099
	end -- 1087
	local params = cloneParamValue(action.params) -- 1101
	local areParamValuesEqual -- 1102
	areParamValuesEqual = function(left, right) -- 1102
		if left == right then -- 1102
			return true -- 1103
		end -- 1103
		if left == nil or right == nil then -- 1103
			return false -- 1104
		end -- 1104
		if isArray(left) or isArray(right) then -- 1104
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1104
				return false -- 1106
			end -- 1106
			do -- 1106
				local i = 0 -- 1107
				while i < #left do -- 1107
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1107
						return false -- 1108
					end -- 1108
					i = i + 1 -- 1107
				end -- 1107
			end -- 1107
			return true -- 1110
		end -- 1110
		if type(left) == "table" and type(right) == "table" then -- 1110
			local leftCount = 0 -- 1113
			for key in pairs(left) do -- 1114
				leftCount = leftCount + 1 -- 1115
				if not areParamValuesEqual(left[key], right[key]) then -- 1115
					return false -- 1120
				end -- 1120
			end -- 1120
			local rightCount = 0 -- 1123
			for key in pairs(right) do -- 1124
				rightCount = rightCount + 1 -- 1125
			end -- 1125
			return leftCount == rightCount -- 1127
		end -- 1127
		return false -- 1129
	end -- 1102
	return { -- 1131
		action = action, -- 1132
		matches = function(self, nextAction) -- 1133
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1134
		end, -- 1133
		promise = startPreExecutedToolAction(shared, action) -- 1136
	} -- 1136
end -- 1086
local function executeToolActionWithPreExecution(shared, action) -- 1140
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1140
		local ____opt_3 = shared.preExecutedResults -- 1140
		local preResult = ____opt_3 and ____opt_3:get(action.toolCallId) -- 1141
		if preResult then -- 1141
			local ____opt_5 = shared.preExecutedResults -- 1141
			if ____opt_5 ~= nil then -- 1141
				____opt_5:delete(action.toolCallId) -- 1143
			end -- 1143
			if preResult:matches(action) then -- 1143
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1145
				return ____awaiter_resolve( -- 1145
					nil, -- 1145
					__TS__Await(preResult.promise) -- 1146
				) -- 1146
			end -- 1146
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1148
		end -- 1148
		return ____awaiter_resolve( -- 1148
			nil, -- 1148
			executeToolAction(shared, action) -- 1150
		) -- 1150
	end) -- 1150
end -- 1140
local function maybeCompressHistory(shared, forceAtTurnBoundary) -- 1153
	if forceAtTurnBoundary == nil then -- 1153
		forceAtTurnBoundary = false -- 1153
	end -- 1153
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1153
		local ____shared_7 = shared -- 1154
		local memory = ____shared_7.memory -- 1154
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1155
		local changed = false -- 1156
		do -- 1156
			local round = 0 -- 1157
			while round < maxRounds do -- 1157
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1158
				local activeMessages = getActiveConversationMessages(shared) -- 1159
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1162
				local thresholdReached = memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) -- 1165
				local activeTokens = 0 -- 1170
				if forceAtTurnBoundary and shared.role == "main" then -- 1170
					do -- 1170
						local i = 0 -- 1172
						while i < #activeMessages do -- 1172
							local message = activeMessages[i + 1] -- 1173
							activeTokens = activeTokens + 8 -- 1174
							activeTokens = activeTokens + estimateTextTokens(message.role or "") -- 1175
							activeTokens = activeTokens + estimateTextTokens(message.content or "") -- 1176
							activeTokens = activeTokens + estimateTextTokens(message.name or "") -- 1177
							activeTokens = activeTokens + estimateTextTokens(message.tool_call_id or "") -- 1178
							activeTokens = activeTokens + estimateTextTokens(message.reasoning_content or "") -- 1179
							local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 1180
							activeTokens = activeTokens + estimateTextTokens(toolCallsText or "") -- 1181
							i = i + 1 -- 1172
						end -- 1172
					end -- 1172
				end -- 1172
				local activeRealMessages = getActiveRealMessageCount(shared) -- 1184
				local turnBoundaryReached = forceAtTurnBoundary and shared.role == "main" and (activeTokens >= 72000 or activeRealMessages >= 64 and activeTokens >= 48000) -- 1185
				if not thresholdReached and not turnBoundaryReached then -- 1185
					if changed then -- 1185
						persistHistoryState(shared) -- 1190
					end -- 1190
					return ____awaiter_resolve(nil) -- 1190
				end -- 1190
				local compressionRound = round + 1 -- 1194
				shared.step = shared.step + 1 -- 1195
				local stepId = shared.step -- 1196
				local pendingMessages = #activeMessages -- 1197
				emitAgentEvent( -- 1198
					shared, -- 1198
					{ -- 1198
						type = "memory_compression_started", -- 1199
						sessionId = shared.sessionId, -- 1200
						taskId = shared.taskId, -- 1201
						step = stepId, -- 1202
						tool = "compress_memory", -- 1203
						reason = getMemoryCompressionStartReason(shared), -- 1204
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1205
					} -- 1205
				) -- 1205
				local result = __TS__Await(memory.compressor:compress( -- 1211
					activeMessages, -- 1212
					shared.llmOptions, -- 1213
					shared.llmMaxTry, -- 1214
					shared.decisionMode, -- 1215
					{ -- 1216
						onInput = function(____, phase, messages, options) -- 1217
							saveStepLLMDebugInput( -- 1218
								shared, -- 1218
								stepId, -- 1218
								phase, -- 1218
								messages, -- 1218
								options -- 1218
							) -- 1218
						end, -- 1217
						onOutput = function(____, phase, text, meta) -- 1220
							saveStepLLMDebugOutput( -- 1221
								shared, -- 1221
								stepId, -- 1221
								phase, -- 1221
								text, -- 1221
								meta -- 1221
							) -- 1221
						end -- 1220
					}, -- 1220
					"default", -- 1224
					systemPrompt, -- 1225
					toolDefinitions -- 1226
				)) -- 1226
				if not (result and result.success and result.compressedCount > 0) then -- 1226
					emitAgentEvent( -- 1229
						shared, -- 1229
						{ -- 1229
							type = "memory_compression_finished", -- 1230
							sessionId = shared.sessionId, -- 1231
							taskId = shared.taskId, -- 1232
							step = stepId, -- 1233
							tool = "compress_memory", -- 1234
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1235
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1239
						} -- 1239
					) -- 1239
					if changed then -- 1239
						persistHistoryState(shared) -- 1247
					end -- 1247
					return ____awaiter_resolve(nil) -- 1247
				end -- 1247
				local effectiveCompressedCount = math.max( -- 1251
					0, -- 1252
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1253
				) -- 1253
				if effectiveCompressedCount <= 0 then -- 1253
					if changed then -- 1253
						persistHistoryState(shared) -- 1257
					end -- 1257
					return ____awaiter_resolve(nil) -- 1257
				end -- 1257
				emitAgentEvent( -- 1261
					shared, -- 1261
					{ -- 1261
						type = "memory_compression_finished", -- 1262
						sessionId = shared.sessionId, -- 1263
						taskId = shared.taskId, -- 1264
						step = stepId, -- 1265
						tool = "compress_memory", -- 1266
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1267
						result = { -- 1268
							success = true, -- 1269
							round = compressionRound, -- 1270
							compressedCount = effectiveCompressedCount, -- 1271
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1272
						} -- 1272
					} -- 1272
				) -- 1272
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1275
				changed = true -- 1276
				Log( -- 1277
					"Info", -- 1277
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1277
				) -- 1277
				round = round + 1 -- 1157
			end -- 1157
		end -- 1157
		if changed then -- 1157
			persistHistoryState(shared) -- 1280
		end -- 1280
	end) -- 1280
end -- 1153
local function compactAllHistory(shared) -- 1284
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1284
		local ____shared_14 = shared -- 1285
		local memory = ____shared_14.memory -- 1285
		local rounds = 0 -- 1286
		local totalCompressed = 0 -- 1287
		while getActiveRealMessageCount(shared) > 0 do -- 1287
			if shared.stopToken.stopped then -- 1287
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1290
				return ____awaiter_resolve( -- 1290
					nil, -- 1290
					emitAgentTaskFinishEvent( -- 1291
						shared, -- 1291
						false, -- 1291
						getCancelledReason(shared) -- 1291
					) -- 1291
				) -- 1291
			end -- 1291
			rounds = rounds + 1 -- 1293
			shared.step = shared.step + 1 -- 1294
			local stepId = shared.step -- 1295
			local activeMessages = getActiveConversationMessages(shared) -- 1296
			local pendingMessages = #activeMessages -- 1297
			emitAgentEvent( -- 1298
				shared, -- 1298
				{ -- 1298
					type = "memory_compression_started", -- 1299
					sessionId = shared.sessionId, -- 1300
					taskId = shared.taskId, -- 1301
					step = stepId, -- 1302
					tool = "compress_memory", -- 1303
					reason = getMemoryCompressionStartReason(shared), -- 1304
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1305
				} -- 1305
			) -- 1305
			local result = __TS__Await(memory.compressor:compress( -- 1312
				activeMessages, -- 1313
				shared.llmOptions, -- 1314
				shared.llmMaxTry, -- 1315
				shared.decisionMode, -- 1316
				{ -- 1317
					onInput = function(____, phase, messages, options) -- 1318
						saveStepLLMDebugInput( -- 1319
							shared, -- 1319
							stepId, -- 1319
							phase, -- 1319
							messages, -- 1319
							options -- 1319
						) -- 1319
					end, -- 1318
					onOutput = function(____, phase, text, meta) -- 1321
						saveStepLLMDebugOutput( -- 1322
							shared, -- 1322
							stepId, -- 1322
							phase, -- 1322
							text, -- 1322
							meta -- 1322
						) -- 1322
					end -- 1321
				}, -- 1321
				"budget_max" -- 1325
			)) -- 1325
			if not (result and result.success and result.compressedCount > 0) then -- 1325
				emitAgentEvent( -- 1328
					shared, -- 1328
					{ -- 1328
						type = "memory_compression_finished", -- 1329
						sessionId = shared.sessionId, -- 1330
						taskId = shared.taskId, -- 1331
						step = stepId, -- 1332
						tool = "compress_memory", -- 1333
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1334
						result = { -- 1338
							success = false, -- 1339
							rounds = rounds, -- 1340
							error = result and result.error or "compression returned no changes", -- 1341
							compressedCount = result and result.compressedCount or 0, -- 1342
							fullCompaction = true -- 1343
						} -- 1343
					} -- 1343
				) -- 1343
				return ____awaiter_resolve( -- 1343
					nil, -- 1343
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1346
				) -- 1346
			end -- 1346
			local effectiveCompressedCount = math.max( -- 1351
				0, -- 1352
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1353
			) -- 1353
			if effectiveCompressedCount <= 0 then -- 1353
				return ____awaiter_resolve( -- 1353
					nil, -- 1353
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1356
				) -- 1356
			end -- 1356
			emitAgentEvent( -- 1363
				shared, -- 1363
				{ -- 1363
					type = "memory_compression_finished", -- 1364
					sessionId = shared.sessionId, -- 1365
					taskId = shared.taskId, -- 1366
					step = stepId, -- 1367
					tool = "compress_memory", -- 1368
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1369
					result = { -- 1370
						success = true, -- 1371
						round = rounds, -- 1372
						compressedCount = effectiveCompressedCount, -- 1373
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1374
						fullCompaction = true -- 1375
					} -- 1375
				} -- 1375
			) -- 1375
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1378
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1379
			persistHistoryState(shared) -- 1380
			Log( -- 1381
				"Info", -- 1381
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1381
			) -- 1381
		end -- 1381
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1383
		return ____awaiter_resolve( -- 1383
			nil, -- 1383
			emitAgentTaskFinishEvent( -- 1384
				shared, -- 1385
				true, -- 1386
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1387
			) -- 1387
		) -- 1387
	end) -- 1387
end -- 1284
local function clearSessionHistory(shared) -- 1393
	shared.messages = {} -- 1394
	shared.lastConsolidatedIndex = 0 -- 1395
	shared.carryMessageIndex = nil -- 1396
	persistHistoryState(shared) -- 1397
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1398
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1399
end -- 1393
COMPLETION_TEXT_MAX_CHARS = 800 -- 1421
COMPLETION_LIST_MAX_ITEMS = 12 -- 1422
COMPLETION_EVIDENCE_MAX_ITEMS = 8 -- 1423
local function appendConversationMessage(shared, message) -- 1612
	local ____shared_messages_23 = shared.messages -- 1612
	____shared_messages_23[#____shared_messages_23 + 1] = __TS__ObjectAssign( -- 1613
		{}, -- 1613
		message, -- 1614
		{ -- 1613
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1615
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1616
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1617
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1618
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1619
		} -- 1619
	) -- 1619
end -- 1612
local function appendToolResultMessage(shared, action) -- 1628
	appendConversationMessage( -- 1629
		shared, -- 1629
		{ -- 1629
			role = "tool", -- 1630
			tool_call_id = action.toolCallId, -- 1631
			name = action.tool, -- 1632
			content = action.result and toJson(action.result, false) or "" -- 1633
		} -- 1633
	) -- 1633
end -- 1628
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1637
	appendConversationMessage( -- 1643
		shared, -- 1643
		{ -- 1643
			role = "assistant", -- 1644
			content = content or "", -- 1645
			reasoning_content = reasoningContent, -- 1646
			tool_calls = __TS__ArrayMap( -- 1647
				actions, -- 1647
				function(____, action) return { -- 1647
					id = action.toolCallId, -- 1648
					type = "function", -- 1649
					["function"] = { -- 1650
						name = action.tool, -- 1651
						arguments = toJson(action.params, false) -- 1652
					} -- 1652
				} end -- 1652
			) -- 1652
		} -- 1652
	) -- 1652
end -- 1637
local function llm(shared, messages, phase) -- 1836
	if phase == nil then -- 1836
		phase = "decision_xml" -- 1839
	end -- 1839
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1839
		local stepId = shared.step + 1 -- 1841
		emitLLMContextMetrics( -- 1842
			shared, -- 1842
			stepId, -- 1842
			phase, -- 1842
			messages, -- 1842
			shared.llmOptions -- 1842
		) -- 1842
		saveStepLLMDebugInput( -- 1843
			shared, -- 1843
			stepId, -- 1843
			phase, -- 1843
			messages, -- 1843
			shared.llmOptions -- 1843
		) -- 1843
		local lastStreamReasoning = "" -- 1844
		local res = __TS__Await(callLLMStreamAggregated( -- 1845
			messages, -- 1846
			shared.llmOptions, -- 1847
			shared.stopToken, -- 1848
			shared.llmConfig, -- 1849
			function(response) -- 1850
				local ____opt_27 = response.choices -- 1850
				local ____opt_25 = ____opt_27 and ____opt_27[1] -- 1850
				local streamMessage = ____opt_25 and ____opt_25.message -- 1851
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1852
				if nextContent == "" then -- 1852
					return -- 1855
				end -- 1855
				if nextContent == lastStreamReasoning then -- 1855
					return -- 1856
				end -- 1856
				lastStreamReasoning = nextContent -- 1857
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1858
			end -- 1850
		)) -- 1850
		if res.success then -- 1850
			local ____opt_33 = res.response.choices -- 1850
			local ____opt_31 = ____opt_33 and ____opt_33[1] -- 1850
			local message = ____opt_31 and ____opt_31.message -- 1862
			local text = message and message.content -- 1863
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1864
			if text then -- 1864
				local parsed = tryParseAndValidateDecision(text, shared.role) -- 1868
				if parsed.success then -- 1868
					local reason = parsed.reason or "" -- 1870
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1871
				end -- 1871
				saveStepLLMDebugOutput( -- 1873
					shared, -- 1873
					stepId, -- 1873
					phase, -- 1873
					text, -- 1873
					{success = true} -- 1873
				) -- 1873
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1873
			else -- 1873
				saveStepLLMDebugOutput( -- 1876
					shared, -- 1876
					stepId, -- 1876
					phase, -- 1876
					"empty LLM response", -- 1876
					{success = false} -- 1876
				) -- 1876
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1876
			end -- 1876
		else -- 1876
			saveStepLLMDebugOutput( -- 1880
				shared, -- 1880
				stepId, -- 1880
				phase, -- 1880
				res.raw or res.message, -- 1880
				{success = false} -- 1880
			) -- 1880
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1880
		end -- 1880
	end) -- 1880
end -- 1836
local function isDecisionBatchSuccess(result) -- 1904
	return result.kind == "batch" -- 1905
end -- 1904
local function parseDecisionToolCall(functionName, rawObj) -- 1929
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 1929
		return {success = false, message = "unknown tool: " .. functionName} -- 1931
	end -- 1931
	if rawObj == nil then -- 1931
		return {success = true, tool = functionName, params = {}} -- 1934
	end -- 1934
	if not isRecord(rawObj) then -- 1934
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1937
	end -- 1937
	return {success = true, tool = functionName, params = rawObj} -- 1939
end -- 1929
local function parseToolCallArguments(functionName, argsText) -- 1946
	local trimmedArgs = __TS__StringTrim(argsText) -- 1947
	if trimmedArgs == "" then -- 1947
		return {} -- 1949
	end -- 1949
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1951
	if err ~= nil or rawObj == nil then -- 1951
		return { -- 1953
			success = false, -- 1954
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1955
			raw = argsText -- 1956
		} -- 1956
	end -- 1956
	local encodedRaw = safeJsonEncode(rawObj) -- 1959
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1959
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1961
	end -- 1961
	return rawObj -- 1967
end -- 1946
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1970
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1978
	if isRecord(rawArgs) and rawArgs.success == false then -- 1978
		return rawArgs -- 1980
	end -- 1980
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1982
	if not decision.success then -- 1982
		return {success = false, message = decision.message, raw = argsText} -- 1984
	end -- 1984
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 1990
	if not completionValidation.success then -- 1990
		return {success = false, message = completionValidation.message, raw = argsText} -- 1992
	end -- 1992
	local validation = validateDecision(decision.tool, decision.params) -- 1998
	if not validation.success then -- 1998
		return {success = false, message = validation.message, raw = argsText} -- 2000
	end -- 2000
	if not isToolAllowedForRole(shared, decision.tool) then -- 2000
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 2007
	end -- 2007
	decision.params = validation.params -- 2013
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2014
	decision.reason = reason -- 2015
	decision.reasoningContent = reasoningContent -- 2016
	return decision -- 2017
end -- 1970
local function createPreExecutableActionFromStream(shared, toolCall) -- 2020
	local ____opt_39 = toolCall["function"] -- 2020
	local functionName = ____opt_39 and ____opt_39.name -- 2021
	local ____opt_41 = toolCall["function"] -- 2021
	local argsText = ____opt_41 and ____opt_41.arguments or "" -- 2022
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2023
	if not functionName or not toolCallId then -- 2023
		return nil -- 2024
	end -- 2024
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2025
	if isRecord(rawArgs) and rawArgs.success == false then -- 2025
		return nil -- 2026
	end -- 2026
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2027
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2027
		return nil -- 2028
	end -- 2028
	local validation = validateDecision(decision.tool, decision.params) -- 2029
	if not validation.success then -- 2029
		return nil -- 2030
	end -- 2030
	if not isToolAllowedForRole(shared, decision.tool) then -- 2030
		return nil -- 2031
	end -- 2031
	return { -- 2032
		step = shared.step + 1, -- 2033
		toolCallId = toolCallId, -- 2034
		tool = decision.tool, -- 2035
		reason = "", -- 2036
		params = validation.params, -- 2037
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2038
	} -- 2038
end -- 2020
local function sanitizeMessagesForLLMInput(messages) -- 2261
	local sanitized = {} -- 2262
	local droppedAssistantToolCalls = 0 -- 2263
	local droppedToolResults = 0 -- 2264
	do -- 2264
		local i = 0 -- 2265
		while i < #messages do -- 2265
			do -- 2265
				local message = messages[i + 1] -- 2266
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2266
					local requiredIds = {} -- 2268
					do -- 2268
						local j = 0 -- 2269
						while j < #message.tool_calls do -- 2269
							local toolCall = message.tool_calls[j + 1] -- 2270
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2271
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2271
								requiredIds[#requiredIds + 1] = id -- 2273
							end -- 2273
							j = j + 1 -- 2269
						end -- 2269
					end -- 2269
					if #requiredIds == 0 then -- 2269
						sanitized[#sanitized + 1] = message -- 2277
						goto __continue390 -- 2278
					end -- 2278
					local matchedIds = {} -- 2280
					local matchedTools = {} -- 2281
					local j = i + 1 -- 2282
					while j < #messages do -- 2282
						local toolMessage = messages[j + 1] -- 2284
						if toolMessage.role ~= "tool" then -- 2284
							break -- 2285
						end -- 2285
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2286
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2286
							matchedIds[toolCallId] = true -- 2288
							matchedTools[#matchedTools + 1] = toolMessage -- 2289
						else -- 2289
							droppedToolResults = droppedToolResults + 1 -- 2291
						end -- 2291
						j = j + 1 -- 2293
					end -- 2293
					local complete = true -- 2295
					do -- 2295
						local j = 0 -- 2296
						while j < #requiredIds do -- 2296
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2296
								complete = false -- 2298
								break -- 2299
							end -- 2299
							j = j + 1 -- 2296
						end -- 2296
					end -- 2296
					if complete then -- 2296
						__TS__ArrayPush( -- 2303
							sanitized, -- 2303
							message, -- 2303
							table.unpack(matchedTools) -- 2303
						) -- 2303
					else -- 2303
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2305
						droppedToolResults = droppedToolResults + #matchedTools -- 2306
					end -- 2306
					i = j - 1 -- 2308
					goto __continue390 -- 2309
				end -- 2309
				if message.role == "tool" then -- 2309
					droppedToolResults = droppedToolResults + 1 -- 2312
					goto __continue390 -- 2313
				end -- 2313
				sanitized[#sanitized + 1] = message -- 2315
			end -- 2315
			::__continue390:: -- 2315
			i = i + 1 -- 2265
		end -- 2265
	end -- 2265
	return sanitized -- 2317
end -- 2261
local function getUnconsolidatedMessages(shared) -- 2320
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2321
end -- 2320
local function getFinalDecisionTurnPrompt(shared) -- 2324
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2325
end -- 2324
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2330
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2330
		return messages -- 2331
	end -- 2331
	local next = __TS__ArrayMap( -- 2332
		messages, -- 2332
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2332
	) -- 2332
	do -- 2332
		local i = #next - 1 -- 2333
		while i >= 0 do -- 2333
			do -- 2333
				local message = next[i + 1] -- 2334
				if message.role ~= "assistant" and message.role ~= "user" then -- 2334
					goto __continue412 -- 2335
				end -- 2335
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2336
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2337
				return next -- 2340
			end -- 2340
			::__continue412:: -- 2340
			i = i - 1 -- 2333
		end -- 2333
	end -- 2333
	next[#next + 1] = {role = "user", content = prompt} -- 2342
	return next -- 2343
end -- 2330
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2346
	if attempt == nil then -- 2346
		attempt = 1 -- 2349
	end -- 2349
	if decisionMode == nil then -- 2349
		decisionMode = shared.decisionMode -- 2351
	end -- 2351
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2353
	shared.resumeCheckpointPending = false -- 2354
	local messages = { -- 2355
		{role = "system", content = systemPrompt}, -- 2356
		table.unpack(getUnconsolidatedMessages(shared)) -- 2357
	} -- 2357
	if shared.step + 1 >= shared.maxSteps then -- 2357
		messages = appendPromptToLatestDecisionMessage( -- 2360
			messages, -- 2360
			getFinalDecisionTurnPrompt(shared) -- 2360
		) -- 2360
	end -- 2360
	if lastError and lastError ~= "" then -- 2360
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2363
		if decisionMode == "xml" then -- 2363
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2367
		end -- 2367
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2367
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2370
		end -- 2370
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2370
			retryHeader = retryHeader .. "\nYour previous response spent the token budget on reasoning and ended before any tool call. Do not continue that reasoning. Immediately emit one valid function tool call with compact arguments." -- 2373
		end -- 2373
		messages[#messages + 1] = { -- 2375
			role = "user", -- 2376
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2377
		} -- 2377
	end -- 2377
	return messages -- 2384
end -- 2346
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2391
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2400
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2401
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2409
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2410
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2411
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2419
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2427
		shared.role, -- 2427
		{ -- 2427
			includeFinish = true, -- 2428
			includeXmlRules = true, -- 2429
			context = {searchDoraApiLimitMax = SEARCH_DORA_API_LIMIT_MAX}, -- 2430
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared) -- 2431
		} -- 2431
	) -- 2431
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2433
	local repairPrompt = replacePromptVars( -- 2436
		shared.promptPack.xmlDecisionRepairPrompt, -- 2436
		{ -- 2436
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2437
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2438
			CANDIDATE_SECTION = candidateSection, -- 2439
			LAST_ERROR = lastError, -- 2440
			ATTEMPT = tostring(attempt) -- 2441
		} -- 2441
	) -- 2441
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2443
end -- 2391
local function normalizeLineEndings(text) -- 2477
	local res = string.gsub(text, "\r\n", "\n") -- 2478
	res = string.gsub(res, "\r", "\n") -- 2479
	return res -- 2480
end -- 2477
local function countOccurrences(text, searchStr) -- 2483
	if searchStr == "" then -- 2483
		return 0 -- 2484
	end -- 2484
	local count = 0 -- 2485
	local pos = 0 -- 2486
	while true do -- 2486
		local idx = (string.find( -- 2488
			text, -- 2488
			searchStr, -- 2488
			math.max(pos + 1, 1), -- 2488
			true -- 2488
		) or 0) - 1 -- 2488
		if idx < 0 then -- 2488
			break -- 2489
		end -- 2489
		count = count + 1 -- 2490
		pos = idx + #searchStr -- 2491
	end -- 2491
	return count -- 2493
end -- 2483
local function replaceFirst(text, oldStr, newStr) -- 2496
	if oldStr == "" then -- 2496
		return text -- 2497
	end -- 2497
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2498
	if idx < 0 then -- 2498
		return text -- 2499
	end -- 2499
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2500
end -- 2496
local function splitLines(text) -- 2503
	return __TS__StringSplit(text, "\n") -- 2504
end -- 2503
local function getLeadingWhitespace(text) -- 2507
	local i = 0 -- 2508
	while i < #text do -- 2508
		local ch = __TS__StringAccess(text, i) -- 2510
		if ch ~= " " and ch ~= "\t" then -- 2510
			break -- 2511
		end -- 2511
		i = i + 1 -- 2512
	end -- 2512
	return __TS__StringSubstring(text, 0, i) -- 2514
end -- 2507
local function getCommonIndentPrefix(lines) -- 2517
	local common -- 2518
	do -- 2518
		local i = 0 -- 2519
		while i < #lines do -- 2519
			do -- 2519
				local line = lines[i + 1] -- 2520
				if __TS__StringTrim(line) == "" then -- 2520
					goto __continue441 -- 2521
				end -- 2521
				local indent = getLeadingWhitespace(line) -- 2522
				if common == nil then -- 2522
					common = indent -- 2524
					goto __continue441 -- 2525
				end -- 2525
				local j = 0 -- 2527
				local maxLen = math.min(#common, #indent) -- 2528
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2528
					j = j + 1 -- 2530
				end -- 2530
				common = __TS__StringSubstring(common, 0, j) -- 2532
				if common == "" then -- 2532
					break -- 2533
				end -- 2533
			end -- 2533
			::__continue441:: -- 2533
			i = i + 1 -- 2519
		end -- 2519
	end -- 2519
	return common or "" -- 2535
end -- 2517
local function removeIndentPrefix(line, indent) -- 2538
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2538
		return __TS__StringSubstring(line, #indent) -- 2540
	end -- 2540
	local lineIndent = getLeadingWhitespace(line) -- 2542
	local j = 0 -- 2543
	local maxLen = math.min(#lineIndent, #indent) -- 2544
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2544
		j = j + 1 -- 2546
	end -- 2546
	return __TS__StringSubstring(line, j) -- 2548
end -- 2538
local function dedentLines(lines) -- 2551
	local indent = getCommonIndentPrefix(lines) -- 2552
	return { -- 2553
		indent = indent, -- 2554
		lines = __TS__ArrayMap( -- 2555
			lines, -- 2555
			function(____, line) return removeIndentPrefix(line, indent) end -- 2555
		) -- 2555
	} -- 2555
end -- 2551
local function joinLines(lines) -- 2559
	return table.concat(lines, "\n") -- 2560
end -- 2559
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2563
	local function findWhitespaceTolerantReplacement() -- 2568
		local function foldWhitespace(text, withMap) -- 2570
			local parts = {} -- 2571
			local map = {} -- 2572
			local i = 0 -- 2573
			while i < #text do -- 2573
				local ch = __TS__StringAccess(text, i) -- 2575
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2575
					local start = i -- 2577
					while i < #text do -- 2577
						local next = __TS__StringAccess(text, i) -- 2579
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2579
							break -- 2580
						end -- 2580
						i = i + 1 -- 2581
					end -- 2581
					parts[#parts + 1] = " " -- 2583
					if withMap then -- 2583
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2584
					end -- 2584
				else -- 2584
					parts[#parts + 1] = ch -- 2586
					if withMap then -- 2586
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2587
					end -- 2587
					i = i + 1 -- 2588
				end -- 2588
			end -- 2588
			return { -- 2591
				text = table.concat(parts, ""), -- 2591
				map = map -- 2591
			} -- 2591
		end -- 2570
		local foldedContent = foldWhitespace(content, true) -- 2593
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2594
		if foldedOld == "" then -- 2594
			return {success = false, message = "old_str not found in file"} -- 2596
		end -- 2596
		local matches = {} -- 2598
		local pos = 0 -- 2599
		while true do -- 2599
			local idx = (string.find( -- 2601
				foldedContent.text, -- 2601
				foldedOld, -- 2601
				math.max(pos + 1, 1), -- 2601
				true -- 2601
			) or 0) - 1 -- 2601
			if idx < 0 then -- 2601
				break -- 2602
			end -- 2602
			local lastIdx = idx + #foldedOld - 1 -- 2603
			local startMap = foldedContent.map[idx + 1] -- 2604
			local endMap = foldedContent.map[lastIdx + 1] -- 2605
			if startMap ~= nil and endMap ~= nil then -- 2605
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2607
			end -- 2607
			pos = idx + #foldedOld -- 2609
		end -- 2609
		if #matches == 0 then -- 2609
			return {success = false, message = "old_str not found in file"} -- 2612
		end -- 2612
		if #matches > 1 then -- 2612
			return { -- 2615
				success = false, -- 2616
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2617
			} -- 2617
		end -- 2617
		local match = matches[1] -- 2620
		return { -- 2621
			success = true, -- 2622
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2623
		} -- 2623
	end -- 2568
	local contentLines = splitLines(content) -- 2626
	local oldLines = splitLines(oldStr) -- 2627
	if #oldLines == 0 then -- 2627
		return {success = false, message = "old_str not found in file"} -- 2629
	end -- 2629
	local dedentedOld = dedentLines(oldLines) -- 2631
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2632
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2633
	local matches = {} -- 2634
	do -- 2634
		local start = 0 -- 2635
		while start <= #contentLines - #oldLines do -- 2635
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2636
			local dedentedCandidate = dedentLines(candidateLines) -- 2637
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2637
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2639
			end -- 2639
			start = start + 1 -- 2635
		end -- 2635
	end -- 2635
	if #matches == 0 then -- 2635
		return findWhitespaceTolerantReplacement() -- 2647
	end -- 2647
	if #matches > 1 then -- 2647
		return { -- 2650
			success = false, -- 2651
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2652
		} -- 2652
	end -- 2652
	local match = matches[1] -- 2655
	local rebuiltNewLines = __TS__ArrayMap( -- 2656
		dedentedNew.lines, -- 2656
		function(____, line) return line == "" and "" or match.indent .. line end -- 2656
	) -- 2656
	local ____array_47 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2656
	__TS__SparseArrayPush( -- 2656
		____array_47, -- 2656
		table.unpack(rebuiltNewLines) -- 2659
	) -- 2659
	__TS__SparseArrayPush( -- 2659
		____array_47, -- 2659
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2660
	) -- 2660
	local nextLines = {__TS__SparseArraySpread(____array_47)} -- 2657
	return { -- 2662
		success = true, -- 2662
		content = joinLines(nextLines) -- 2662
	} -- 2662
end -- 2563
local MainDecisionAgent = __TS__Class() -- 2665
MainDecisionAgent.name = "MainDecisionAgent" -- 2665
__TS__ClassExtends(MainDecisionAgent, Node) -- 2665
function MainDecisionAgent.prototype.prep(self, shared) -- 2666
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2666
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2666
			return ____awaiter_resolve(nil, {shared = shared}) -- 2666
		end -- 2666
		__TS__Await(maybeCompressHistory(shared)) -- 2671
		return ____awaiter_resolve(nil, {shared = shared}) -- 2671
	end) -- 2671
end -- 2666
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2676
	local preExecuted = shared.preExecutedResults -- 2677
	if not preExecuted or preExecuted.size == 0 then -- 2677
		return nil -- 2678
	end -- 2678
	local decisions = {} -- 2679
	preExecuted:forEach(function(____, preResult) -- 2680
		local action = preResult.action -- 2681
		decisions[#decisions + 1] = { -- 2682
			success = true, -- 2683
			tool = action.tool, -- 2684
			params = action.params, -- 2685
			toolCallId = action.toolCallId, -- 2686
			reason = action.reason, -- 2687
			reasoningContent = action.reasoningContent -- 2688
		} -- 2688
	end) -- 2680
	if #decisions == 0 then -- 2680
		return nil -- 2691
	end -- 2691
	Log( -- 2692
		"Warn", -- 2692
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2692
			__TS__ArrayMap( -- 2692
				decisions, -- 2692
				function(____, decision) return decision.tool end -- 2692
			), -- 2692
			"," -- 2692
		) -- 2692
	) -- 2692
	if #decisions == 1 then -- 2692
		return decisions[1] -- 2694
	end -- 2694
	return {success = true, kind = "batch", decisions = decisions} -- 2696
end -- 2676
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2703
	if attempt == nil then -- 2703
		attempt = 1 -- 2706
	end -- 2706
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2706
		if shared.stopToken.stopped then -- 2706
			return ____awaiter_resolve( -- 2706
				nil, -- 2706
				{ -- 2710
					success = false, -- 2710
					message = getCancelledReason(shared) -- 2710
				} -- 2710
			) -- 2710
		end -- 2710
		Log( -- 2712
			"Info", -- 2712
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2712
		) -- 2712
		local availableTools = AgentToolRegistry.buildDecisionToolSchema( -- 2713
			shared.role, -- 2713
			SEARCH_DORA_API_LIMIT_MAX, -- 2713
			{disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared)} -- 2713
		) -- 2713
		local checkpointTools = shared.resumeRequiredTool == nil and availableTools or __TS__ArrayFilter( -- 2716
			availableTools, -- 2718
			function(____, tool) return tool["function"].name == shared.resumeRequiredTool end -- 2718
		) -- 2718
		local tools = #checkpointTools > 0 and checkpointTools or availableTools -- 2719
		if shared.resumeRequiredTool ~= nil and #checkpointTools == 0 then -- 2719
			Log("Warn", "[CodingAgent] checkpoint tool is unavailable tool=" .. shared.resumeRequiredTool) -- 2721
		end -- 2721
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2723
		local stepId = shared.step + 1 -- 2724
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2725
			string.lower(shared.llmConfig.model), -- 2725
			"glm-5.2" -- 2725
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2725
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2728
		emitLLMContextMetrics( -- 2733
			shared, -- 2733
			stepId, -- 2733
			"decision_tool_calling", -- 2733
			messages, -- 2733
			llmOptions -- 2733
		) -- 2733
		saveStepLLMDebugInput( -- 2734
			shared, -- 2734
			stepId, -- 2734
			"decision_tool_calling", -- 2734
			messages, -- 2734
			llmOptions -- 2734
		) -- 2734
		local lastStreamContent = "" -- 2735
		local lastStreamReasoning = "" -- 2736
		local preExecutedResults = __TS__New(Map) -- 2737
		shared.preExecutedResults = preExecutedResults -- 2738
		local res = __TS__Await(callLLMStreamAggregated( -- 2739
			messages, -- 2740
			llmOptions, -- 2741
			shared.stopToken, -- 2742
			shared.llmConfig, -- 2743
			function(response) -- 2744
				local ____opt_50 = response.choices -- 2744
				local ____opt_48 = ____opt_50 and ____opt_50[1] -- 2744
				local streamMessage = ____opt_48 and ____opt_48.message -- 2745
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2746
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2749
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2749
					return -- 2753
				end -- 2753
				lastStreamContent = nextContent -- 2755
				lastStreamReasoning = nextReasoning -- 2756
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2757
			end, -- 2744
			function(tc) -- 2759
				if shared.stopToken.stopped then -- 2759
					return -- 2760
				end -- 2760
				local action = createPreExecutableActionFromStream(shared, tc) -- 2761
				if not action or preExecutedResults:has(action.toolCallId) then -- 2761
					return -- 2762
				end -- 2762
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2763
				preExecutedResults:set( -- 2764
					action.toolCallId, -- 2764
					createPreExecutedToolResult(shared, action) -- 2764
				) -- 2764
			end -- 2759
		)) -- 2759
		if shared.stopToken.stopped then -- 2759
			clearPreExecutedResults(shared) -- 2768
			return ____awaiter_resolve( -- 2768
				nil, -- 2768
				{ -- 2769
					success = false, -- 2769
					message = getCancelledReason(shared) -- 2769
				} -- 2769
			) -- 2769
		end -- 2769
		if not res.success then -- 2769
			saveStepLLMDebugOutput( -- 2772
				shared, -- 2772
				stepId, -- 2772
				"decision_tool_calling", -- 2772
				res.raw or res.message, -- 2772
				{success = false} -- 2772
			) -- 2772
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2773
			if (string.find(res.message, "stream incomplete:", nil, true) or 0) - 1 >= 0 then -- 2773
				Log("Warn", "[CodingAgent] discarding all partial tool calls after incomplete stream") -- 2775
			end -- 2775
			clearPreExecutedResults(shared) -- 2777
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2777
		end -- 2777
		saveStepLLMDebugOutput( -- 2780
			shared, -- 2780
			stepId, -- 2780
			"decision_tool_calling", -- 2780
			encodeDebugJSON(res.response), -- 2780
			{success = true} -- 2780
		) -- 2780
		local choice = res.response.choices and res.response.choices[1] -- 2781
		local message = choice and choice.message -- 2782
		local toolCalls = message and message.tool_calls -- 2783
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2784
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2787
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2790
		Log( -- 2793
			"Info", -- 2793
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2793
		) -- 2793
		if finishReason == "length" then -- 2793
			Log( -- 2795
				"Error", -- 2795
				(("[CodingAgent] discarding truncated tool-calling output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2795
			) -- 2795
			clearPreExecutedResults(shared) -- 2796
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens. Do not continue the explanation. Retry immediately with one complete tool call and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 2796
		end -- 2796
		if not toolCalls or #toolCalls == 0 then -- 2796
			if messageContent and messageContent ~= "" then -- 2796
				if shared.role == "sub" then -- 2796
					Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 2806
					clearPreExecutedResults(shared) -- 2807
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 2807
				end -- 2807
				Log( -- 2814
					"Info", -- 2814
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2814
				) -- 2814
				clearPreExecutedResults(shared) -- 2815
				return ____awaiter_resolve(nil, { -- 2815
					success = true, -- 2817
					tool = "finish", -- 2818
					params = {}, -- 2819
					reason = messageContent, -- 2820
					reasoningContent = reasoningContent, -- 2821
					directSummary = messageContent -- 2822
				}) -- 2822
			end -- 2822
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2825
			clearPreExecutedResults(shared) -- 2826
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2826
		end -- 2826
		local decisions = {} -- 2833
		do -- 2833
			local i = 0 -- 2834
			while i < #toolCalls do -- 2834
				local toolCall = toolCalls[i + 1] -- 2835
				local fn = toolCall ~= nil and toolCall["function"] -- 2836
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2836
					Log( -- 2838
						"Error", -- 2838
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2838
					) -- 2838
					clearPreExecutedResults(shared) -- 2839
					return ____awaiter_resolve( -- 2839
						nil, -- 2839
						{ -- 2840
							success = false, -- 2841
							message = "missing function name for tool call " .. tostring(i + 1), -- 2842
							raw = messageContent -- 2843
						} -- 2843
					) -- 2843
				end -- 2843
				local functionName = fn.name -- 2846
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2847
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 2848
				Log( -- 2851
					"Info", -- 2851
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2851
				) -- 2851
				local decision = parseAndValidateToolCallDecision( -- 2852
					shared, -- 2853
					functionName, -- 2854
					argsText, -- 2855
					toolCallId, -- 2856
					messageContent, -- 2857
					reasoningContent -- 2858
				) -- 2858
				if not decision.success then -- 2858
					Log( -- 2861
						"Error", -- 2861
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2861
					) -- 2861
					clearPreExecutedResults(shared) -- 2862
					return ____awaiter_resolve(nil, decision) -- 2862
				end -- 2862
				decisions[#decisions + 1] = decision -- 2865
				i = i + 1 -- 2834
			end -- 2834
		end -- 2834
		if #decisions == 1 then -- 2834
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2868
			return ____awaiter_resolve(nil, decisions[1]) -- 2868
		end -- 2868
		do -- 2868
			local i = 0 -- 2871
			while i < #decisions do -- 2871
				if decisions[i + 1].tool == "finish" then -- 2871
					clearPreExecutedResults(shared) -- 2873
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2873
				end -- 2873
				i = i + 1 -- 2871
			end -- 2871
		end -- 2871
		Log( -- 2881
			"Info", -- 2881
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2881
				__TS__ArrayMap( -- 2881
					decisions, -- 2881
					function(____, decision) return decision.tool end -- 2881
				), -- 2881
				"," -- 2881
			) -- 2881
		) -- 2881
		return ____awaiter_resolve(nil, { -- 2881
			success = true, -- 2883
			kind = "batch", -- 2884
			decisions = decisions, -- 2885
			content = messageContent, -- 2886
			reasoningContent = reasoningContent -- 2887
		}) -- 2887
	end) -- 2887
end -- 2703
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 2891
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2891
		Log( -- 2897
			"Info", -- 2897
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2897
		) -- 2897
		local lastError = initialError -- 2898
		local candidateRaw = "" -- 2899
		local candidateReasoning = nil -- 2900
		do -- 2900
			local attempt = 0 -- 2901
			while attempt < shared.llmMaxTry do -- 2901
				do -- 2901
					Log( -- 2902
						"Info", -- 2902
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2902
					) -- 2902
					local messages = buildXmlRepairMessages( -- 2903
						shared, -- 2904
						originalRaw, -- 2905
						originalReasoning, -- 2906
						candidateRaw, -- 2907
						candidateReasoning, -- 2908
						lastError, -- 2909
						attempt + 1 -- 2910
					) -- 2910
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2912
					if shared.stopToken.stopped then -- 2912
						return ____awaiter_resolve( -- 2912
							nil, -- 2912
							{ -- 2914
								success = false, -- 2914
								message = getCancelledReason(shared) -- 2914
							} -- 2914
						) -- 2914
					end -- 2914
					if not llmRes.success then -- 2914
						lastError = llmRes.message -- 2917
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2918
						goto __continue510 -- 2919
					end -- 2919
					candidateRaw = llmRes.text -- 2921
					candidateReasoning = llmRes.reasoningContent -- 2922
					local decision = tryParseAndValidateDecision(candidateRaw, shared.role) -- 2923
					if decision.success then -- 2923
						decision.reasoningContent = llmRes.reasoningContent -- 2925
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2926
						return ____awaiter_resolve(nil, decision) -- 2926
					end -- 2926
					lastError = decision.message -- 2929
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2930
				end -- 2930
				::__continue510:: -- 2930
				attempt = attempt + 1 -- 2901
			end -- 2901
		end -- 2901
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2932
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2932
	end) -- 2932
end -- 2891
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2940
	if attempt == nil then -- 2940
		attempt = 1 -- 2943
	end -- 2943
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2943
		local messages = buildDecisionMessages( -- 2946
			shared, -- 2947
			lastError, -- 2948
			attempt, -- 2949
			lastRaw, -- 2950
			"xml" -- 2951
		) -- 2951
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2953
		if shared.stopToken.stopped then -- 2953
			return ____awaiter_resolve( -- 2953
				nil, -- 2953
				{ -- 2955
					success = false, -- 2955
					message = getCancelledReason(shared) -- 2955
				} -- 2955
			) -- 2955
		end -- 2955
		if not llmRes.success then -- 2955
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2955
		end -- 2955
		local decision = tryParseAndValidateDecision(llmRes.text, shared.role) -- 2964
		if decision.success then -- 2964
			decision.reasoningContent = llmRes.reasoningContent -- 2966
			if not isToolAllowedForRole(shared, decision.tool) then -- 2966
				return ____awaiter_resolve( -- 2966
					nil, -- 2966
					self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2968
				) -- 2968
			end -- 2968
			return ____awaiter_resolve(nil, decision) -- 2968
		end -- 2968
		return ____awaiter_resolve( -- 2968
			nil, -- 2968
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 2977
		) -- 2977
	end) -- 2977
end -- 2940
function MainDecisionAgent.prototype.exec(self, input) -- 2980
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2980
		local shared = input.shared -- 2981
		local function acceptResumeDecision(decision) -- 2982
			if shared.resumeRequiredTool == nil then -- 2982
				return true -- 2983
			end -- 2983
			local selectedTool -- 2984
			if isDecisionBatchSuccess(decision) then -- 2984
				selectedTool = #decision.decisions > 0 and decision.decisions[1].tool or nil -- 2986
			elseif decision.directSummary and decision.directSummary ~= "" then -- 2986
				selectedTool = "finish" -- 2988
			else -- 2988
				selectedTool = decision.tool -- 2990
			end -- 2990
			if selectedTool ~= shared.resumeRequiredTool then -- 2990
				return false -- 2992
			end -- 2992
			shared.resumeRequiredTool = nil -- 2993
			shared.resumeCheckpointPending = false -- 2994
			return true -- 2995
		end -- 2982
		if shared.stopToken.stopped then -- 2982
			return ____awaiter_resolve( -- 2982
				nil, -- 2982
				{ -- 2998
					success = false, -- 2998
					message = getCancelledReason(shared) -- 2998
				} -- 2998
			) -- 2998
		end -- 2998
		if shared.step >= shared.maxSteps then -- 2998
			Log( -- 3001
				"Warn", -- 3001
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3001
			) -- 3001
			return ____awaiter_resolve( -- 3001
				nil, -- 3001
				{ -- 3002
					success = false, -- 3002
					message = getMaxStepsReachedReason(shared) -- 3002
				} -- 3002
			) -- 3002
		end -- 3002
		if shared.decisionMode == "tool_calling" then -- 3002
			Log( -- 3006
				"Info", -- 3006
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3006
			) -- 3006
			local lastError = "tool calling validation failed" -- 3007
			local lastRaw = "" -- 3008
			local shouldFallbackToXml = false -- 3009
			do -- 3009
				local attempt = 0 -- 3010
				while attempt < shared.llmMaxTry do -- 3010
					do -- 3010
						Log( -- 3011
							"Info", -- 3011
							"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3011
						) -- 3011
						local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3012
						if shared.stopToken.stopped then -- 3012
							return ____awaiter_resolve( -- 3012
								nil, -- 3012
								{ -- 3019
									success = false, -- 3019
									message = getCancelledReason(shared) -- 3019
								} -- 3019
							) -- 3019
						end -- 3019
						if decision.success then -- 3019
							if acceptResumeDecision(decision) then -- 3019
								return ____awaiter_resolve(nil, decision) -- 3019
							end -- 3019
							lastError = ("Compression checkpoint requires " .. tostring(shared.resumeRequiredTool)) .. " as the next tool." -- 3023
							lastRaw = "" -- 3024
							goto __continue530 -- 3025
						end -- 3025
						lastError = decision.message -- 3027
						lastRaw = decision.raw or "" -- 3028
						Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3029
						if lastError == "missing tool call" then -- 3029
							shouldFallbackToXml = true -- 3031
							break -- 3032
						end -- 3032
					end -- 3032
					::__continue530:: -- 3032
					attempt = attempt + 1 -- 3010
				end -- 3010
			end -- 3010
			if shouldFallbackToXml then -- 3010
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3036
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3037
				do -- 3037
					local attempt = 0 -- 3038
					while attempt < shared.llmMaxTry do -- 3038
						do -- 3038
							Log( -- 3039
								"Info", -- 3039
								"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3039
							) -- 3039
							local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3040
							if shared.stopToken.stopped then -- 3040
								return ____awaiter_resolve( -- 3040
									nil, -- 3040
									{ -- 3047
										success = false, -- 3047
										message = getCancelledReason(shared) -- 3047
									} -- 3047
								) -- 3047
							end -- 3047
							if decision.success then -- 3047
								if acceptResumeDecision(decision) then -- 3047
									return ____awaiter_resolve(nil, decision) -- 3047
								end -- 3047
								lastError = ("Compression checkpoint requires " .. tostring(shared.resumeRequiredTool)) .. " as the next tool." -- 3051
								lastRaw = "" -- 3052
								goto __continue537 -- 3053
							end -- 3053
							lastError = decision.message -- 3055
							lastRaw = decision.raw or "" -- 3056
							Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3057
						end -- 3057
						::__continue537:: -- 3057
						attempt = attempt + 1 -- 3038
					end -- 3038
				end -- 3038
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3059
				return ____awaiter_resolve( -- 3059
					nil, -- 3059
					{ -- 3060
						success = false, -- 3060
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3060
					} -- 3060
				) -- 3060
			end -- 3060
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3062
			return ____awaiter_resolve( -- 3062
				nil, -- 3062
				{ -- 3063
					success = false, -- 3063
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3063
				} -- 3063
			) -- 3063
		end -- 3063
		local lastError = "xml validation failed" -- 3066
		local lastRaw = "" -- 3067
		do -- 3067
			local attempt = 0 -- 3068
			while attempt < shared.llmMaxTry do -- 3068
				do -- 3068
					local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3069
					if shared.stopToken.stopped then -- 3069
						return ____awaiter_resolve( -- 3069
							nil, -- 3069
							{ -- 3078
								success = false, -- 3078
								message = getCancelledReason(shared) -- 3078
							} -- 3078
						) -- 3078
					end -- 3078
					if decision.success then -- 3078
						if acceptResumeDecision(decision) then -- 3078
							return ____awaiter_resolve(nil, decision) -- 3078
						end -- 3078
						lastError = ("Compression checkpoint requires " .. tostring(shared.resumeRequiredTool)) .. " as the next tool." -- 3082
						lastRaw = "" -- 3083
						goto __continue542 -- 3084
					end -- 3084
					lastError = decision.message -- 3086
					lastRaw = decision.raw or "" -- 3087
				end -- 3087
				::__continue542:: -- 3087
				attempt = attempt + 1 -- 3068
			end -- 3068
		end -- 3068
		return ____awaiter_resolve( -- 3068
			nil, -- 3068
			{ -- 3089
				success = false, -- 3089
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3089
			} -- 3089
		) -- 3089
	end) -- 3089
end -- 2980
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3092
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3092
		local result = execRes -- 3093
		if not result.success then -- 3093
			if shared.stopToken.stopped then -- 3093
				shared.error = getCancelledReason(shared) -- 3096
				shared.done = true -- 3097
				return ____awaiter_resolve(nil, "done") -- 3097
			end -- 3097
			shared.error = result.message -- 3100
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3101
			shared.done = true -- 3102
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3103
			persistHistoryState(shared) -- 3107
			return ____awaiter_resolve(nil, "done") -- 3107
		end -- 3107
		if isDecisionBatchSuccess(result) then -- 3107
			local startStep = shared.step -- 3111
			local actions = {} -- 3112
			do -- 3112
				local i = 0 -- 3113
				while i < #result.decisions do -- 3113
					local decision = result.decisions[i + 1] -- 3114
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3115
					local step = startStep + i + 1 -- 3116
					local ____temp_56 -- 3117
					if i == 0 then -- 3117
						____temp_56 = decision.reason -- 3117
					else -- 3117
						____temp_56 = "" -- 3117
					end -- 3117
					local actionReason = ____temp_56 -- 3117
					local ____temp_57 -- 3118
					if i == 0 then -- 3118
						____temp_57 = decision.reasoningContent -- 3118
					else -- 3118
						____temp_57 = nil -- 3118
					end -- 3118
					local actionReasoningContent = ____temp_57 -- 3118
					emitAgentEvent(shared, { -- 3119
						type = "decision_made", -- 3120
						sessionId = shared.sessionId, -- 3121
						taskId = shared.taskId, -- 3122
						step = step, -- 3123
						tool = decision.tool, -- 3124
						reason = actionReason, -- 3125
						reasoningContent = actionReasoningContent, -- 3126
						params = decision.params -- 3127
					}) -- 3127
					local action = { -- 3129
						step = step, -- 3130
						toolCallId = toolCallId, -- 3131
						tool = decision.tool, -- 3132
						reason = actionReason or "", -- 3133
						reasoningContent = actionReasoningContent, -- 3134
						params = decision.params, -- 3135
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3136
					} -- 3136
					local ____shared_history_58 = shared.history -- 3136
					____shared_history_58[#____shared_history_58 + 1] = action -- 3138
					actions[#actions + 1] = action -- 3139
					i = i + 1 -- 3113
				end -- 3113
			end -- 3113
			shared.step = startStep + #actions -- 3141
			shared.pendingToolActions = actions -- 3142
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3143
			persistHistoryState(shared) -- 3149
			return ____awaiter_resolve(nil, "batch_tools") -- 3149
		end -- 3149
		if result.directSummary and result.directSummary ~= "" then -- 3149
			shared.response = result.directSummary -- 3153
			shared.completion = ____exports.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3154
			shared.done = true -- 3158
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3159
			persistHistoryState(shared) -- 3164
			return ____awaiter_resolve(nil, "done") -- 3164
		end -- 3164
		if result.tool == "finish" then -- 3164
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3168
			shared.response = finalMessage -- 3169
			shared.completion = getCompletionReport(result.params) -- 3170
			shared.done = true -- 3171
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3172
			persistHistoryState(shared) -- 3177
			return ____awaiter_resolve(nil, "done") -- 3177
		end -- 3177
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3180
		shared.step = shared.step + 1 -- 3181
		local step = shared.step -- 3182
		emitAgentEvent(shared, { -- 3183
			type = "decision_made", -- 3184
			sessionId = shared.sessionId, -- 3185
			taskId = shared.taskId, -- 3186
			step = step, -- 3187
			tool = result.tool, -- 3188
			reason = result.reason, -- 3189
			reasoningContent = result.reasoningContent, -- 3190
			params = result.params -- 3191
		}) -- 3191
		local ____shared_history_59 = shared.history -- 3191
		____shared_history_59[#____shared_history_59 + 1] = { -- 3193
			step = step, -- 3194
			toolCallId = toolCallId, -- 3195
			tool = result.tool, -- 3196
			reason = result.reason or "", -- 3197
			reasoningContent = result.reasoningContent, -- 3198
			params = result.params, -- 3199
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3200
		} -- 3200
		local action = shared.history[#shared.history] -- 3202
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3203
		shared.pendingToolActions = {action} -- 3206
		persistHistoryState(shared) -- 3207
		return ____awaiter_resolve(nil, "batch_tools") -- 3207
	end) -- 3207
end -- 3092
local ReadFileAction = __TS__Class() -- 3212
ReadFileAction.name = "ReadFileAction" -- 3212
__TS__ClassExtends(ReadFileAction, Node) -- 3212
function ReadFileAction.prototype.prep(self, shared) -- 3213
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3213
		local last = shared.history[#shared.history] -- 3214
		if not last then -- 3214
			error( -- 3215
				__TS__New(Error, "no history"), -- 3215
				0 -- 3215
			) -- 3215
		end -- 3215
		emitAgentStartEvent(shared, last) -- 3216
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3217
		if __TS__StringTrim(path) == "" then -- 3217
			error( -- 3220
				__TS__New(Error, "missing path"), -- 3220
				0 -- 3220
			) -- 3220
		end -- 3220
		local ____path_62 = path -- 3222
		local ____shared_workingDir_63 = shared.workingDir -- 3224
		local ____temp_64 = shared.useChineseResponse and "zh" or "en" -- 3225
		local ____last_params_startLine_60 = last.params.startLine -- 3226
		if ____last_params_startLine_60 == nil then -- 3226
			____last_params_startLine_60 = 1 -- 3226
		end -- 3226
		local ____TS__Number_result_65 = __TS__Number(____last_params_startLine_60) -- 3226
		local ____last_params_endLine_61 = last.params.endLine -- 3227
		if ____last_params_endLine_61 == nil then -- 3227
			____last_params_endLine_61 = READ_FILE_DEFAULT_LIMIT -- 3227
		end -- 3227
		return ____awaiter_resolve( -- 3227
			nil, -- 3227
			{ -- 3221
				path = ____path_62, -- 3222
				tool = "read_file", -- 3223
				workDir = ____shared_workingDir_63, -- 3224
				docLanguage = ____temp_64, -- 3225
				startLine = ____TS__Number_result_65, -- 3226
				endLine = __TS__Number(____last_params_endLine_61) -- 3227
			} -- 3227
		) -- 3227
	end) -- 3227
end -- 3213
function ReadFileAction.prototype.exec(self, input) -- 3231
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3231
		return ____awaiter_resolve( -- 3231
			nil, -- 3231
			Tools.readFile( -- 3232
				input.workDir, -- 3233
				input.path, -- 3234
				__TS__Number(input.startLine or 1), -- 3235
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3236
				input.docLanguage -- 3237
			) -- 3237
		) -- 3237
	end) -- 3237
end -- 3231
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3241
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3241
		local result = execRes -- 3242
		local last = shared.history[#shared.history] -- 3243
		if last ~= nil then -- 3243
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3245
			appendToolResultMessage(shared, last) -- 3246
			emitAgentFinishEvent(shared, last) -- 3247
		end -- 3247
		persistHistoryState(shared) -- 3249
		__TS__Await(maybeCompressHistory(shared)) -- 3250
		persistHistoryState(shared) -- 3251
		return ____awaiter_resolve(nil, "main") -- 3251
	end) -- 3251
end -- 3241
local SearchFilesAction = __TS__Class() -- 3256
SearchFilesAction.name = "SearchFilesAction" -- 3256
__TS__ClassExtends(SearchFilesAction, Node) -- 3256
function SearchFilesAction.prototype.prep(self, shared) -- 3257
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3257
		local last = shared.history[#shared.history] -- 3258
		if not last then -- 3258
			error( -- 3259
				__TS__New(Error, "no history"), -- 3259
				0 -- 3259
			) -- 3259
		end -- 3259
		emitAgentStartEvent(shared, last) -- 3260
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3260
	end) -- 3260
end -- 3257
function SearchFilesAction.prototype.exec(self, input) -- 3264
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3264
		local params = input.params -- 3265
		local ____Tools_searchFiles_79 = Tools.searchFiles -- 3266
		local ____input_workDir_72 = input.workDir -- 3267
		local ____temp_73 = params.path or "" -- 3268
		local ____temp_74 = params.pattern or "" -- 3269
		local ____params_globs_75 = params.globs -- 3270
		local ____params_useRegex_76 = params.useRegex -- 3271
		local ____params_caseSensitive_77 = params.caseSensitive -- 3272
		local ____math_max_68 = math.max -- 3275
		local ____math_floor_67 = math.floor -- 3275
		local ____params_limit_66 = params.limit -- 3275
		if ____params_limit_66 == nil then -- 3275
			____params_limit_66 = SEARCH_FILES_LIMIT_DEFAULT -- 3275
		end -- 3275
		local ____math_max_68_result_78 = ____math_max_68( -- 3275
			1, -- 3275
			____math_floor_67(__TS__Number(____params_limit_66)) -- 3275
		) -- 3275
		local ____math_max_71 = math.max -- 3276
		local ____math_floor_70 = math.floor -- 3276
		local ____params_offset_69 = params.offset -- 3276
		if ____params_offset_69 == nil then -- 3276
			____params_offset_69 = 0 -- 3276
		end -- 3276
		local result = __TS__Await(____Tools_searchFiles_79({ -- 3266
			workDir = ____input_workDir_72, -- 3267
			path = ____temp_73, -- 3268
			pattern = ____temp_74, -- 3269
			globs = ____params_globs_75, -- 3270
			useRegex = ____params_useRegex_76, -- 3271
			caseSensitive = ____params_caseSensitive_77, -- 3272
			includeContent = true, -- 3273
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3274
			limit = ____math_max_68_result_78, -- 3275
			offset = ____math_max_71( -- 3276
				0, -- 3276
				____math_floor_70(__TS__Number(____params_offset_69)) -- 3276
			), -- 3276
			groupByFile = params.groupByFile == true -- 3277
		})) -- 3277
		return ____awaiter_resolve(nil, result) -- 3277
	end) -- 3277
end -- 3264
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3282
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3282
		local last = shared.history[#shared.history] -- 3283
		if last ~= nil then -- 3283
			local result = execRes -- 3285
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3286
			appendToolResultMessage(shared, last) -- 3287
			emitAgentFinishEvent(shared, last) -- 3288
		end -- 3288
		persistHistoryState(shared) -- 3290
		__TS__Await(maybeCompressHistory(shared)) -- 3291
		persistHistoryState(shared) -- 3292
		return ____awaiter_resolve(nil, "main") -- 3292
	end) -- 3292
end -- 3282
local SearchDoraAPIAction = __TS__Class() -- 3297
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3297
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3297
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3298
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3298
		local last = shared.history[#shared.history] -- 3299
		if not last then -- 3299
			error( -- 3300
				__TS__New(Error, "no history"), -- 3300
				0 -- 3300
			) -- 3300
		end -- 3300
		emitAgentStartEvent(shared, last) -- 3301
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3301
	end) -- 3301
end -- 3298
function SearchDoraAPIAction.prototype.exec(self, input) -- 3305
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3305
		local params = input.params -- 3306
		local ____Tools_searchDoraAPI_87 = Tools.searchDoraAPI -- 3307
		local ____temp_83 = params.pattern or "" -- 3308
		local ____temp_84 = params.docSource or "api" -- 3309
		local ____temp_85 = input.useChineseResponse and "zh" or "en" -- 3310
		local ____temp_86 = params.programmingLanguage or "ts" -- 3311
		local ____math_min_82 = math.min -- 3312
		local ____math_max_81 = math.max -- 3312
		local ____params_limit_80 = params.limit -- 3312
		if ____params_limit_80 == nil then -- 3312
			____params_limit_80 = 8 -- 3312
		end -- 3312
		local result = __TS__Await(____Tools_searchDoraAPI_87({ -- 3307
			pattern = ____temp_83, -- 3308
			docSource = ____temp_84, -- 3309
			docLanguage = ____temp_85, -- 3310
			programmingLanguage = ____temp_86, -- 3311
			limit = ____math_min_82( -- 3312
				SEARCH_DORA_API_LIMIT_MAX, -- 3312
				____math_max_81( -- 3312
					1, -- 3312
					__TS__Number(____params_limit_80) -- 3312
				) -- 3312
			), -- 3312
			useRegex = params.useRegex, -- 3313
			caseSensitive = false, -- 3314
			includeContent = true, -- 3315
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3316
		})) -- 3316
		return ____awaiter_resolve(nil, result) -- 3316
	end) -- 3316
end -- 3305
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3321
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3321
		local last = shared.history[#shared.history] -- 3322
		if last ~= nil then -- 3322
			local result = execRes -- 3324
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3325
			appendToolResultMessage(shared, last) -- 3326
			emitAgentFinishEvent(shared, last) -- 3327
		end -- 3327
		persistHistoryState(shared) -- 3329
		__TS__Await(maybeCompressHistory(shared)) -- 3330
		persistHistoryState(shared) -- 3331
		return ____awaiter_resolve(nil, "main") -- 3331
	end) -- 3331
end -- 3321
local ListFilesAction = __TS__Class() -- 3336
ListFilesAction.name = "ListFilesAction" -- 3336
__TS__ClassExtends(ListFilesAction, Node) -- 3336
function ListFilesAction.prototype.prep(self, shared) -- 3337
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3337
		local last = shared.history[#shared.history] -- 3338
		if not last then -- 3338
			error( -- 3339
				__TS__New(Error, "no history"), -- 3339
				0 -- 3339
			) -- 3339
		end -- 3339
		emitAgentStartEvent(shared, last) -- 3340
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3340
	end) -- 3340
end -- 3337
function ListFilesAction.prototype.exec(self, input) -- 3344
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3344
		local params = input.params -- 3345
		local ____Tools_listFiles_94 = Tools.listFiles -- 3346
		local ____input_workDir_91 = input.workDir -- 3347
		local ____temp_92 = params.path or "" -- 3348
		local ____params_globs_93 = params.globs -- 3349
		local ____math_max_90 = math.max -- 3350
		local ____math_floor_89 = math.floor -- 3350
		local ____params_maxEntries_88 = params.maxEntries -- 3350
		if ____params_maxEntries_88 == nil then -- 3350
			____params_maxEntries_88 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3350
		end -- 3350
		local result = ____Tools_listFiles_94({ -- 3346
			workDir = ____input_workDir_91, -- 3347
			path = ____temp_92, -- 3348
			globs = ____params_globs_93, -- 3349
			maxEntries = ____math_max_90( -- 3350
				1, -- 3350
				____math_floor_89(__TS__Number(____params_maxEntries_88)) -- 3350
			) -- 3350
		}) -- 3350
		return ____awaiter_resolve(nil, result) -- 3350
	end) -- 3350
end -- 3344
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3355
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3355
		local last = shared.history[#shared.history] -- 3356
		if last ~= nil then -- 3356
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3358
			appendToolResultMessage(shared, last) -- 3359
			emitAgentFinishEvent(shared, last) -- 3360
		end -- 3360
		persistHistoryState(shared) -- 3362
		__TS__Await(maybeCompressHistory(shared)) -- 3363
		persistHistoryState(shared) -- 3364
		return ____awaiter_resolve(nil, "main") -- 3364
	end) -- 3364
end -- 3355
local DeleteFileAction = __TS__Class() -- 3369
DeleteFileAction.name = "DeleteFileAction" -- 3369
__TS__ClassExtends(DeleteFileAction, Node) -- 3369
function DeleteFileAction.prototype.prep(self, shared) -- 3370
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3370
		local last = shared.history[#shared.history] -- 3371
		if not last then -- 3371
			error( -- 3372
				__TS__New(Error, "no history"), -- 3372
				0 -- 3372
			) -- 3372
		end -- 3372
		emitAgentStartEvent(shared, last) -- 3373
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3374
		if __TS__StringTrim(targetFile) == "" then -- 3374
			error( -- 3377
				__TS__New(Error, "missing target_file"), -- 3377
				0 -- 3377
			) -- 3377
		end -- 3377
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3377
	end) -- 3377
end -- 3370
function DeleteFileAction.prototype.exec(self, input) -- 3381
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3381
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3382
		if not result.success then -- 3382
			return ____awaiter_resolve(nil, result) -- 3382
		end -- 3382
		return ____awaiter_resolve(nil, { -- 3382
			success = true, -- 3390
			changed = true, -- 3391
			mode = "delete", -- 3392
			checkpointId = result.checkpointId, -- 3393
			checkpointSeq = result.checkpointSeq, -- 3394
			files = {{path = input.targetFile, op = "delete"}} -- 3395
		}) -- 3395
	end) -- 3395
end -- 3381
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3399
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3399
		local last = shared.history[#shared.history] -- 3400
		if last ~= nil then -- 3400
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3402
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3403
			appendToolResultMessage(shared, last) -- 3404
			emitAgentFinishEvent(shared, last) -- 3405
			local result = last.result -- 3406
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3406
				emitAgentEvent(shared, { -- 3411
					type = "checkpoint_created", -- 3412
					sessionId = shared.sessionId, -- 3413
					taskId = shared.taskId, -- 3414
					step = last.step, -- 3415
					tool = "delete_file", -- 3416
					checkpointId = result.checkpointId, -- 3417
					checkpointSeq = result.checkpointSeq, -- 3418
					files = result.files -- 3419
				}) -- 3419
			end -- 3419
		end -- 3419
		persistHistoryState(shared) -- 3426
		__TS__Await(maybeCompressHistory(shared)) -- 3427
		persistHistoryState(shared) -- 3428
		return ____awaiter_resolve(nil, "main") -- 3428
	end) -- 3428
end -- 3399
local BuildAction = __TS__Class() -- 3433
BuildAction.name = "BuildAction" -- 3433
__TS__ClassExtends(BuildAction, Node) -- 3433
function BuildAction.prototype.prep(self, shared) -- 3434
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3434
		local last = shared.history[#shared.history] -- 3435
		if not last then -- 3435
			error( -- 3436
				__TS__New(Error, "no history"), -- 3436
				0 -- 3436
			) -- 3436
		end -- 3436
		emitAgentStartEvent(shared, last) -- 3437
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3437
	end) -- 3437
end -- 3434
function BuildAction.prototype.exec(self, input) -- 3441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3441
		local params = input.params -- 3442
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3443
		return ____awaiter_resolve(nil, result) -- 3443
	end) -- 3443
end -- 3441
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3450
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3450
		local last = shared.history[#shared.history] -- 3451
		if last ~= nil then -- 3451
			last.result = sanitizeBuildResultForHistory(execRes) -- 3453
			appendToolResultMessage(shared, last) -- 3454
			emitAgentFinishEvent(shared, last) -- 3455
		end -- 3455
		persistHistoryState(shared) -- 3457
		__TS__Await(maybeCompressHistory(shared)) -- 3458
		persistHistoryState(shared) -- 3459
		return ____awaiter_resolve(nil, "main") -- 3459
	end) -- 3459
end -- 3450
local SpawnSubAgentAction = __TS__Class() -- 3464
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3464
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3464
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3465
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3465
		local last = shared.history[#shared.history] -- 3475
		if not last then -- 3475
			error( -- 3476
				__TS__New(Error, "no history"), -- 3476
				0 -- 3476
			) -- 3476
		end -- 3476
		emitAgentStartEvent(shared, last) -- 3477
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3478
			last.params.filesHint, -- 3479
			function(____, item) return type(item) == "string" end -- 3479
		) or nil -- 3479
		return ____awaiter_resolve( -- 3479
			nil, -- 3479
			{ -- 3481
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3482
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3483
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3484
				filesHint = filesHint, -- 3485
				sessionId = shared.sessionId, -- 3486
				projectRoot = shared.workingDir, -- 3487
				spawnSubAgent = shared.spawnSubAgent, -- 3488
				disabledAgentTools = shared.disabledAgentTools -- 3489
			} -- 3489
		) -- 3489
	end) -- 3489
end -- 3465
function SpawnSubAgentAction.prototype.exec(self, input) -- 3493
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3493
		if not input.spawnSubAgent then -- 3493
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3493
		end -- 3493
		if input.sessionId == nil or input.sessionId <= 0 then -- 3493
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3493
		end -- 3493
		local ____Log_100 = Log -- 3509
		local ____temp_97 = #input.title -- 3509
		local ____temp_98 = #input.prompt -- 3509
		local ____temp_99 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3509
		local ____opt_95 = input.filesHint -- 3509
		____Log_100( -- 3509
			"Info", -- 3509
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_97)) .. " prompt_len=") .. tostring(____temp_98)) .. " expected_len=") .. tostring(____temp_99)) .. " files_hint_count=") .. tostring(____opt_95 and #____opt_95 or 0) -- 3509
		) -- 3509
		local result = __TS__Await(input.spawnSubAgent({ -- 3510
			parentSessionId = input.sessionId, -- 3511
			projectRoot = input.projectRoot, -- 3512
			title = input.title, -- 3513
			prompt = input.prompt, -- 3514
			expectedOutput = input.expectedOutput, -- 3515
			filesHint = input.filesHint, -- 3516
			disabledAgentTools = input.disabledAgentTools -- 3517
		})) -- 3517
		if not result.success then -- 3517
			return ____awaiter_resolve(nil, result) -- 3517
		end -- 3517
		return ____awaiter_resolve(nil, { -- 3517
			success = true, -- 3523
			sessionId = result.sessionId, -- 3524
			taskId = result.taskId, -- 3525
			title = result.title, -- 3526
			hint = "Continue useful foreground work after dispatching, but do not immediately poll newly spawned sub-agents. Their results arrive as asynchronous handoffs." -- 3527
		}) -- 3527
	end) -- 3527
end -- 3493
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3531
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3531
		local last = shared.history[#shared.history] -- 3532
		if last ~= nil then -- 3532
			last.result = execRes -- 3534
			appendToolResultMessage(shared, last) -- 3535
			emitAgentFinishEvent(shared, last) -- 3536
		end -- 3536
		persistHistoryState(shared) -- 3538
		__TS__Await(maybeCompressHistory(shared)) -- 3539
		persistHistoryState(shared) -- 3540
		return ____awaiter_resolve(nil, "main") -- 3540
	end) -- 3540
end -- 3531
local ListSubAgentsAction = __TS__Class() -- 3545
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3545
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3545
function ListSubAgentsAction.prototype.prep(self, shared) -- 3546
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3546
		local last = shared.history[#shared.history] -- 3555
		if not last then -- 3555
			error( -- 3556
				__TS__New(Error, "no history"), -- 3556
				0 -- 3556
			) -- 3556
		end -- 3556
		emitAgentStartEvent(shared, last) -- 3557
		return ____awaiter_resolve( -- 3557
			nil, -- 3557
			{ -- 3558
				sessionId = shared.sessionId, -- 3559
				projectRoot = shared.workingDir, -- 3560
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3561
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3562
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3563
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3564
				listSubAgents = shared.listSubAgents -- 3565
			} -- 3565
		) -- 3565
	end) -- 3565
end -- 3546
function ListSubAgentsAction.prototype.exec(self, input) -- 3569
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3569
		if not input.listSubAgents then -- 3569
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3569
		end -- 3569
		if input.sessionId == nil or input.sessionId <= 0 then -- 3569
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3569
		end -- 3569
		local result = __TS__Await(input.listSubAgents({ -- 3584
			sessionId = input.sessionId, -- 3585
			projectRoot = input.projectRoot, -- 3586
			status = input.status, -- 3587
			limit = input.limit, -- 3588
			offset = input.offset, -- 3589
			query = input.query -- 3590
		})) -- 3590
		return ____awaiter_resolve(nil, result) -- 3590
	end) -- 3590
end -- 3569
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3595
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3595
		local last = shared.history[#shared.history] -- 3596
		if last ~= nil then -- 3596
			last.result = execRes -- 3598
			appendToolResultMessage(shared, last) -- 3599
			emitAgentFinishEvent(shared, last) -- 3600
		end -- 3600
		persistHistoryState(shared) -- 3602
		__TS__Await(maybeCompressHistory(shared)) -- 3603
		persistHistoryState(shared) -- 3604
		return ____awaiter_resolve(nil, "main") -- 3604
	end) -- 3604
end -- 3595
EditFileAction = __TS__Class() -- 3609
EditFileAction.name = "EditFileAction" -- 3609
__TS__ClassExtends(EditFileAction, Node) -- 3609
function EditFileAction.prototype.prep(self, shared) -- 3610
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3610
		local last = shared.history[#shared.history] -- 3611
		if not last then -- 3611
			error( -- 3612
				__TS__New(Error, "no history"), -- 3612
				0 -- 3612
			) -- 3612
		end -- 3612
		emitAgentStartEvent(shared, last) -- 3613
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3614
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3617
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3618
		if __TS__StringTrim(path) == "" then -- 3618
			error( -- 3619
				__TS__New(Error, "missing path"), -- 3619
				0 -- 3619
			) -- 3619
		end -- 3619
		return ____awaiter_resolve(nil, { -- 3619
			path = path, -- 3620
			oldStr = oldStr, -- 3620
			newStr = newStr, -- 3620
			taskId = shared.taskId, -- 3620
			workDir = shared.workingDir -- 3620
		}) -- 3620
	end) -- 3620
end -- 3610
function EditFileAction.prototype.exec(self, input) -- 3623
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3623
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3624
		if not readRes.success then -- 3624
			if input.oldStr ~= "" then -- 3624
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3624
			end -- 3624
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3629
			if not createRes.success then -- 3629
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3629
			end -- 3629
			return ____awaiter_resolve(nil, { -- 3629
				success = true, -- 3637
				changed = true, -- 3638
				mode = "create", -- 3639
				checkpointId = createRes.checkpointId, -- 3640
				checkpointSeq = createRes.checkpointSeq, -- 3641
				files = {{path = input.path, op = "create"}} -- 3642
			}) -- 3642
		end -- 3642
		if input.oldStr == "" then -- 3642
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3646
			if not overwriteRes.success then -- 3646
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3646
			end -- 3646
			return ____awaiter_resolve(nil, { -- 3646
				success = true, -- 3654
				changed = true, -- 3655
				mode = "overwrite", -- 3656
				checkpointId = overwriteRes.checkpointId, -- 3657
				checkpointSeq = overwriteRes.checkpointSeq, -- 3658
				files = {{path = input.path, op = "write"}} -- 3659
			}) -- 3659
		end -- 3659
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3664
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3665
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3666
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3669
		if occurrences == 0 then -- 3669
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3671
			if not indentTolerant.success then -- 3671
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3671
			end -- 3671
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3675
			if not applyRes.success then -- 3675
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3675
			end -- 3675
			return ____awaiter_resolve(nil, { -- 3675
				success = true, -- 3683
				changed = true, -- 3684
				mode = "replace_indent_tolerant", -- 3685
				checkpointId = applyRes.checkpointId, -- 3686
				checkpointSeq = applyRes.checkpointSeq, -- 3687
				files = {{path = input.path, op = "write"}} -- 3688
			}) -- 3688
		end -- 3688
		if occurrences > 1 then -- 3688
			return ____awaiter_resolve( -- 3688
				nil, -- 3688
				{ -- 3692
					success = false, -- 3692
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3692
				} -- 3692
			) -- 3692
		end -- 3692
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3696
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3697
		if not applyRes.success then -- 3697
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3697
		end -- 3697
		return ____awaiter_resolve(nil, { -- 3697
			success = true, -- 3705
			changed = true, -- 3706
			mode = "replace", -- 3707
			checkpointId = applyRes.checkpointId, -- 3708
			checkpointSeq = applyRes.checkpointSeq, -- 3709
			files = {{path = input.path, op = "write"}} -- 3710
		}) -- 3710
	end) -- 3710
end -- 3623
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3714
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3714
		local last = shared.history[#shared.history] -- 3715
		if last ~= nil then -- 3715
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3717
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3718
			appendToolResultMessage(shared, last) -- 3719
			emitAgentFinishEvent(shared, last) -- 3720
			local result = last.result -- 3721
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3721
				emitAgentEvent(shared, { -- 3726
					type = "checkpoint_created", -- 3727
					sessionId = shared.sessionId, -- 3728
					taskId = shared.taskId, -- 3729
					step = last.step, -- 3730
					tool = last.tool, -- 3731
					checkpointId = result.checkpointId, -- 3732
					checkpointSeq = result.checkpointSeq, -- 3733
					files = result.files -- 3734
				}) -- 3734
			end -- 3734
		end -- 3734
		persistHistoryState(shared) -- 3741
		__TS__Await(maybeCompressHistory(shared)) -- 3742
		persistHistoryState(shared) -- 3743
		return ____awaiter_resolve(nil, "main") -- 3743
	end) -- 3743
end -- 3714
local FetchUrlAction = __TS__Class() -- 3748
FetchUrlAction.name = "FetchUrlAction" -- 3748
__TS__ClassExtends(FetchUrlAction, Node) -- 3748
function FetchUrlAction.prototype.prep(self, shared) -- 3749
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3749
		local last = shared.history[#shared.history] -- 3750
		if not last then -- 3750
			error( -- 3751
				__TS__New(Error, "no history"), -- 3751
				0 -- 3751
			) -- 3751
		end -- 3751
		emitAgentStartEvent(shared, last) -- 3752
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3752
	end) -- 3752
end -- 3749
function FetchUrlAction.prototype.exec(self, input) -- 3756
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3756
		return ____awaiter_resolve( -- 3756
			nil, -- 3756
			executeToolAction(input.shared, input.action) -- 3757
		) -- 3757
	end) -- 3757
end -- 3756
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3760
		local last = shared.history[#shared.history] -- 3761
		if last ~= nil then -- 3761
			last.result = execRes -- 3763
			appendToolResultMessage(shared, last) -- 3764
			emitAgentFinishEvent(shared, last) -- 3765
		end -- 3765
		persistHistoryState(shared) -- 3767
		__TS__Await(maybeCompressHistory(shared)) -- 3768
		persistHistoryState(shared) -- 3769
		return ____awaiter_resolve(nil, "main") -- 3769
	end) -- 3769
end -- 3760
local function emitCheckpointEventForAction(shared, action) -- 3774
	local result = action.result -- 3775
	if not result then -- 3775
		return -- 3776
	end -- 3776
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3776
		emitAgentEvent(shared, { -- 3781
			type = "checkpoint_created", -- 3782
			sessionId = shared.sessionId, -- 3783
			taskId = shared.taskId, -- 3784
			step = action.step, -- 3785
			tool = action.tool, -- 3786
			checkpointId = result.checkpointId, -- 3787
			checkpointSeq = result.checkpointSeq, -- 3788
			files = result.files -- 3789
		}) -- 3789
	end -- 3789
end -- 3774
local function canRunBatchActionInParallel(self, action) -- 4373
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4374
end -- 4373
local function partitionToolCalls(actions) -- 4382
	local batches = {} -- 4383
	do -- 4383
		local i = 0 -- 4384
		while i < #actions do -- 4384
			local action = actions[i + 1] -- 4385
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4386
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4387
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4387
				local ____lastBatch_actions_131 = lastBatch.actions -- 4387
				____lastBatch_actions_131[#____lastBatch_actions_131 + 1] = action -- 4389
			else -- 4389
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4391
			end -- 4391
			i = i + 1 -- 4384
		end -- 4384
	end -- 4384
	return batches -- 4394
end -- 4382
local BatchToolAction = __TS__Class() -- 4397
BatchToolAction.name = "BatchToolAction" -- 4397
__TS__ClassExtends(BatchToolAction, Node) -- 4397
function BatchToolAction.prototype.prep(self, shared) -- 4398
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4398
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4398
	end) -- 4398
end -- 4398
function BatchToolAction.prototype.exec(self, input) -- 4402
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4402
		local shared = input.shared -- 4403
		local preExecuted = shared.preExecutedResults -- 4404
		local batches = partitionToolCalls(input.actions) -- 4405
		local parallelBatchCount = #__TS__ArrayFilter( -- 4406
			batches, -- 4406
			function(____, b) return b.isConcurrencySafe end -- 4406
		) -- 4406
		local serialBatchCount = #__TS__ArrayFilter( -- 4407
			batches, -- 4407
			function(____, b) return not b.isConcurrencySafe end -- 4407
		) -- 4407
		Log( -- 4408
			"Info", -- 4408
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4408
		) -- 4408
		do -- 4408
			local batchIdx = 0 -- 4410
			while batchIdx < #batches do -- 4410
				do -- 4410
					local batch = batches[batchIdx + 1] -- 4411
					if shared.stopToken.stopped then -- 4411
						for ____, action in ipairs(batch.actions) do -- 4413
							if not action.result then -- 4413
								action.result = { -- 4415
									success = false, -- 4415
									message = getCancelledReason(shared) -- 4415
								} -- 4415
							end -- 4415
						end -- 4415
						goto __continue758 -- 4418
					end -- 4418
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4418
						local preExecCount = #__TS__ArrayFilter( -- 4422
							batch.actions, -- 4422
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4422
						) -- 4422
						Log( -- 4423
							"Info", -- 4423
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4423
						) -- 4423
						do -- 4423
							local i = 0 -- 4424
							while i < #batch.actions do -- 4424
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4425
								i = i + 1 -- 4424
							end -- 4424
						end -- 4424
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4427
							batch.actions, -- 4427
							function(____, action) -- 4427
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4427
									if shared.stopToken.stopped then -- 4427
										action.result = { -- 4429
											success = false, -- 4429
											message = getCancelledReason(shared) -- 4429
										} -- 4429
										return ____awaiter_resolve(nil, action) -- 4429
									end -- 4429
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4432
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4433
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4434
									return ____awaiter_resolve(nil, action) -- 4434
								end) -- 4434
							end -- 4427
						))) -- 4427
						do -- 4427
							local i = 0 -- 4437
							while i < #batch.actions do -- 4437
								local action = batch.actions[i + 1] -- 4438
								if not action.result then -- 4438
									action.result = {success = false, message = "tool did not produce a result"} -- 4440
								end -- 4440
								appendToolResultMessage(shared, action) -- 4442
								emitAgentFinishEvent(shared, action) -- 4443
								emitCheckpointEventForAction(shared, action) -- 4444
								i = i + 1 -- 4437
							end -- 4437
						end -- 4437
					else -- 4437
						Log( -- 4447
							"Info", -- 4447
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4447
						) -- 4447
						do -- 4447
							local i = 0 -- 4448
							while i < #batch.actions do -- 4448
								local action = batch.actions[i + 1] -- 4449
								emitAgentStartEvent(shared, action) -- 4450
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4451
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4452
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4453
								appendToolResultMessage(shared, action) -- 4454
								emitAgentFinishEvent(shared, action) -- 4455
								emitCheckpointEventForAction(shared, action) -- 4456
								persistHistoryState(shared) -- 4457
								if shared.stopToken.stopped then -- 4457
									break -- 4459
								end -- 4459
								i = i + 1 -- 4448
							end -- 4448
						end -- 4448
					end -- 4448
				end -- 4448
				::__continue758:: -- 4448
				batchIdx = batchIdx + 1 -- 4410
			end -- 4410
		end -- 4410
		persistHistoryState(shared) -- 4464
		return ____awaiter_resolve(nil, input.actions) -- 4464
	end) -- 4464
end -- 4402
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4468
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4468
		shared.pendingToolActions = nil -- 4469
		shared.preExecutedResults = nil -- 4470
		persistHistoryState(shared) -- 4471
		__TS__Await(maybeCompressHistory(shared)) -- 4472
		persistHistoryState(shared) -- 4473
		return ____awaiter_resolve(nil, "main") -- 4473
	end) -- 4473
end -- 4468
local EndNode = __TS__Class() -- 4478
EndNode.name = "EndNode" -- 4478
__TS__ClassExtends(EndNode, Node) -- 4478
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4479
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4479
		return ____awaiter_resolve(nil, nil) -- 4479
	end) -- 4479
end -- 4479
local CodingAgentFlow = __TS__Class() -- 4484
CodingAgentFlow.name = "CodingAgentFlow" -- 4484
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4484
function CodingAgentFlow.prototype.____constructor(self, role) -- 4485
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4486
	local read = __TS__New(ReadFileAction, 1, 0) -- 4487
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4488
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4489
	local list = __TS__New(ListFilesAction, 1, 0) -- 4490
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4491
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4492
	local build = __TS__New(BuildAction, 1, 0) -- 4493
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4494
	local edit = __TS__New(EditFileAction, 1, 0) -- 4495
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4496
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4497
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4498
	local done = __TS__New(EndNode, 1, 0) -- 4499
	main:on("batch_tools", batch) -- 4501
	main:on("grep_files", search) -- 4502
	main:on("search_dora_api", searchDora) -- 4503
	main:on("glob_files", list) -- 4504
	main:on("fetch_url", fetch) -- 4505
	main:on("execute_command", exec) -- 4506
	if role == "main" then -- 4506
		main:on("read_file", read) -- 4508
		main:on("delete_file", del) -- 4509
		main:on("build", build) -- 4510
		main:on("edit_file", edit) -- 4511
		main:on("list_sub_agents", listSub) -- 4512
		main:on("spawn_sub_agent", spawn) -- 4513
	else -- 4513
		main:on("read_file", read) -- 4515
		main:on("delete_file", del) -- 4516
		main:on("build", build) -- 4517
		main:on("edit_file", edit) -- 4518
	end -- 4518
	main:on("done", done) -- 4520
	search:on("main", main) -- 4522
	searchDora:on("main", main) -- 4523
	list:on("main", main) -- 4524
	listSub:on("main", main) -- 4525
	spawn:on("main", main) -- 4526
	batch:on("main", main) -- 4527
	read:on("main", main) -- 4528
	del:on("main", main) -- 4529
	build:on("main", main) -- 4530
	edit:on("main", main) -- 4531
	fetch:on("main", main) -- 4532
	exec:on("main", main) -- 4533
	Flow.prototype.____constructor(self, main) -- 4535
end -- 4485
local function runCodingAgentAsync(options) -- 4571
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4571
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4571
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4571
		end -- 4571
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4575
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4576
		if not llmConfigRes.success then -- 4576
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4576
		end -- 4576
		local llmConfig = llmConfigRes.config -- 4582
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4583
		if not taskRes.success then -- 4583
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4583
		end -- 4583
		local compressor = __TS__New(MemoryCompressor, { -- 4590
			compressionThreshold = 0.8, -- 4591
			compressionTargetThreshold = 0.5, -- 4592
			maxCompressionRounds = 3, -- 4593
			projectDir = options.workDir, -- 4594
			llmConfig = llmConfig, -- 4595
			promptPack = options.promptPack, -- 4596
			scope = options.memoryScope -- 4597
		}) -- 4597
		local persistedSession = compressor:getStorage():readSessionState() -- 4599
		local promptPack = compressor:getPromptPack() -- 4600
		local freshProject = inspectFreshProject(options.workDir) -- 4601
		local freshProjectBuildPending = freshProject.fresh -- 4602
		local freshProjectCodeFile = freshProject.codeFile -- 4603
		local shared = { -- 4605
			sessionId = options.sessionId, -- 4606
			taskId = taskRes.taskId, -- 4607
			role = options.role or "main", -- 4608
			maxSteps = math.max( -- 4609
				1, -- 4609
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4609
			), -- 4609
			llmMaxTry = math.max( -- 4610
				1, -- 4610
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4610
			), -- 4610
			step = 0, -- 4611
			done = false, -- 4612
			stopToken = options.stopToken or ({stopped = false}), -- 4613
			response = "", -- 4614
			userQuery = normalizedPrompt, -- 4615
			workingDir = options.workDir, -- 4616
			useChineseResponse = options.useChineseResponse == true, -- 4617
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4618
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4621
			llmConfig = llmConfig, -- 4622
			onEvent = options.onEvent, -- 4623
			promptPack = promptPack, -- 4624
			history = {}, -- 4625
			messages = persistedSession.messages, -- 4626
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4627
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4628
			memory = {compressor = compressor}, -- 4630
			skills = {loader = AgentSkills.createSkillsLoader({projectDir = options.workDir, disabledAgentTools = options.disabledAgentTools or ({})})}, -- 4634
			spawnSubAgent = options.spawnSubAgent, -- 4640
			listSubAgents = options.listSubAgents, -- 4641
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4642
			freshProjectBuildPending = freshProjectBuildPending, -- 4643
			freshProjectCodeFile = freshProjectCodeFile -- 4644
		} -- 4644
		local ____hasReturned, ____returnValue -- 4644
		local ____try = __TS__AsyncAwaiter(function() -- 4644
			emitAgentEvent(shared, { -- 4648
				type = "task_started", -- 4649
				sessionId = shared.sessionId, -- 4650
				taskId = shared.taskId, -- 4651
				prompt = shared.userQuery, -- 4652
				workDir = shared.workingDir, -- 4653
				maxSteps = shared.maxSteps -- 4654
			}) -- 4654
			if shared.stopToken.stopped then -- 4654
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4657
				____hasReturned = true -- 4658
				____returnValue = emitAgentTaskFinishEvent( -- 4658
					shared, -- 4658
					false, -- 4658
					getCancelledReason(shared) -- 4658
				) -- 4658
				return -- 4658
			end -- 4658
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4660
			local promptCommand = getPromptCommand(shared.userQuery) -- 4661
			if promptCommand == "clear" then -- 4661
				____hasReturned = true -- 4663
				____returnValue = clearSessionHistory(shared) -- 4663
				return -- 4663
			end -- 4663
			if promptCommand == "compact" then -- 4663
				if shared.role == "sub" then -- 4663
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4667
					____hasReturned = true -- 4668
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4668
					return -- 4668
				end -- 4668
				____hasReturned = true -- 4676
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4676
				return -- 4676
			end -- 4676
			__TS__Await(maybeCompressHistory(shared, true)) -- 4678
			if shared.stopToken.stopped then -- 4678
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4680
				____hasReturned = true -- 4681
				____returnValue = emitAgentTaskFinishEvent( -- 4681
					shared, -- 4681
					false, -- 4681
					getCancelledReason(shared) -- 4681
				) -- 4681
				return -- 4681
			end -- 4681
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4683
			persistHistoryState(shared) -- 4687
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4688
			__TS__Await(flow:run(shared)) -- 4689
			if shared.stopToken.stopped then -- 4689
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4691
				____hasReturned = true -- 4692
				____returnValue = emitAgentTaskFinishEvent( -- 4692
					shared, -- 4692
					false, -- 4692
					getCancelledReason(shared) -- 4692
				) -- 4692
				return -- 4692
			end -- 4692
			if shared.error then -- 4692
				____hasReturned = true -- 4695
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4695
				return -- 4695
			end -- 4695
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4698
			____hasReturned = true -- 4699
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4699
			return -- 4699
		end) -- 4699
		____try = ____try.catch( -- 4699
			____try, -- 4699
			function(____, e) -- 4699
				return __TS__AsyncAwaiter(function() -- 4699
					____hasReturned = true -- 4702
					____returnValue = finalizeAgentFailure( -- 4702
						shared, -- 4702
						tostring(e) -- 4702
					) -- 4702
					return -- 4702
				end) -- 4702
			end -- 4702
		) -- 4702
		__TS__Await(____try) -- 4647
		if ____hasReturned then -- 4647
			return ____awaiter_resolve(nil, ____returnValue) -- 4647
		end -- 4647
	end) -- 4647
end -- 4571
function ____exports.runCodingAgent(options, callback) -- 4706
	local ____self_134 = runCodingAgentAsync(options) -- 4706
	____self_134["then"]( -- 4706
		____self_134, -- 4706
		function(____, result) return callback(result) end -- 4707
	) -- 4707
end -- 4706
return ____exports -- 4706