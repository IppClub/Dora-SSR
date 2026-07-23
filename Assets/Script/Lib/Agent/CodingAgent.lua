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
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
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
local isRecord, isArray, emitAgentEvent, getCancelledReason, toJson, truncateText, utf8TakeHead, utf8TakeTail, truncateHistoryText, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, projectEditResultForLLM, projectBuildResultForLLM, projectCommandResultForLLM, projectToolResultContentForLLM, projectMessagesForLLMContext, getDecisionToolDefinitions, isToolAllowedForRole, getFinishMessage, getCompletionReport, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, ensureToolCallId, hasXMLParam, inferToolNameFromXMLParams, parseDSMLAttribute, extractDSMLReason, parseDSMLToolCallObjectFromText, parseXMLToolCallObjectFromText, parseDecisionObject, getDecisionPath, validateDecisionForShared, clampIntegerParam, parseReadLineParam, validateDecision, validateCompletionForRole, buildAgentSystemPrompt, buildSkillsSection, sanitizeMessagesForLLMInput, getUnconsolidatedMessages, isFinalDecisionTurn, getFinalDecisionTurnPrompt, buildDecisionMessages, buildXmlDecisionInstruction, tryParseAndValidateDecision, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, EditFileAction -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local AgentUtils = require("Agent.Utils") -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 9
local AgentSkills = require("Agent.AgentSkills") -- 11
local AgentConfig = require("Agent.AgentConfig") -- 12
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 13
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 22
local normalizeQuestionnaire = ____AgentQuestionnaire.normalizeQuestionnaire -- 22
function isRecord(value) -- 25
	return type(value) == "table" -- 26
end -- 26
function isArray(value) -- 29
	return __TS__ArrayIsArray(value) -- 30
end -- 30
function emitAgentEvent(shared, event) -- 443
	if shared.onEvent then -- 443
		do -- 443
			local function ____catch(____error) -- 443
				AgentUtils.Log( -- 448
					"Error", -- 448
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 448
				) -- 448
			end -- 448
			local ____try, ____hasReturned = pcall(function() -- 448
				shared:onEvent(event) -- 446
			end) -- 446
			if not ____try then -- 446
				____catch(____hasReturned) -- 446
			end -- 446
		end -- 446
	end -- 446
end -- 446
function getCancelledReason(shared) -- 609
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 609
		return shared.stopToken.reason -- 610
	end -- 610
	return shared.useChineseResponse and "已取消" or "cancelled" -- 611
end -- 611
function ____exports.normalizePolicyPath(path) -- 673
	return AgentRuntimePolicy.normalizeAgentPath(path) -- 674
end -- 673
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 682
	return AgentRuntimePolicy.isMainAgentMemoryPath(path) -- 683
end -- 682
function toJson(value, emptyAsArray) -- 830
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 831
	if text ~= nil then -- 831
		return text -- 832
	end -- 832
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 833
end -- 833
function truncateText(text, maxLen) -- 836
	if #text <= maxLen then -- 836
		return text -- 837
	end -- 837
	local nextPos = utf8.offset(text, maxLen + 1) -- 838
	if nextPos == nil then -- 838
		return text -- 839
	end -- 839
	return string.sub(text, 1, nextPos - 1) .. "..." -- 840
end -- 840
function utf8TakeHead(text, maxChars) -- 843
	if maxChars <= 0 or text == "" then -- 843
		return "" -- 844
	end -- 844
	local nextPos = utf8.offset(text, maxChars + 1) -- 845
	if nextPos == nil then -- 845
		return text -- 846
	end -- 846
	return string.sub(text, 1, nextPos - 1) -- 847
end -- 847
function utf8TakeTail(text, maxChars) -- 850
	if maxChars <= 0 or text == "" then -- 850
		return "" -- 851
	end -- 851
	local charLength = utf8.len(text) -- 852
	if charLength == nil or charLength <= maxChars then -- 852
		return text -- 853
	end -- 853
	local startPos = utf8.offset( -- 854
		text, -- 854
		math.max(1, charLength - maxChars + 1) -- 854
	) -- 854
	if startPos == nil then -- 854
		return text -- 855
	end -- 855
	return string.sub(text, startPos) -- 856
end -- 856
function truncateHistoryText(text, maxChars, label) -- 859
	if maxChars <= 0 or text == "" then -- 859
		return "" -- 860
	end -- 860
	if #text <= maxChars then -- 860
		return text -- 861
	end -- 861
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 862
	local remaining = math.max(0, maxChars - #marker) -- 863
	local headChars = math.floor(remaining * 0.6) -- 864
	local tailChars = remaining - headChars -- 865
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 866
end -- 866
function getReplyLanguageDirective(shared) -- 869
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 870
end -- 870
function replacePromptVars(template, vars) -- 875
	local output = template -- 876
	for key in pairs(vars) do -- 877
		output = table.concat( -- 878
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 878
			vars[key] or "" or "," -- 878
		) -- 878
	end -- 878
	return output -- 880
end -- 880
function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 883
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 899
	local contentLines = __TS__StringSplit(content, "\n") -- 900
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 901
	if #content <= maxChars and availableSourceLines <= maxLines then -- 901
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 903
	end -- 903
	local contentBudget = math.max(0, maxChars - 240) -- 914
	local candidateLines = math.min(availableSourceLines, maxLines) -- 915
	local retainedLines = {} -- 916
	local retainedChars = 0 -- 917
	do -- 917
		local i = 0 -- 918
		while i < candidateLines do -- 918
			local line = contentLines[i + 1] -- 919
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 920
			if nextChars > contentBudget then -- 920
				break -- 921
			end -- 921
			retainedLines[#retainedLines + 1] = line -- 922
			retainedChars = nextChars -- 923
			i = i + 1 -- 918
		end -- 918
	end -- 918
	local retainedEndLine = startLine + #retainedLines - 1 -- 926
	local partialLine -- 927
	local retainedContent = table.concat(retainedLines, "\n") -- 928
	if #retainedLines == 0 and candidateLines > 0 then -- 928
		partialLine = startLine -- 930
		retainedEndLine = startLine - 1 -- 931
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 932
	end -- 932
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 934
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 935
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 940
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 943
	return { -- 944
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 945
		truncated = true, -- 946
		retainedStartLine = startLine, -- 947
		retainedEndLine = retainedEndLine, -- 948
		nextStartLine = nextStartLine, -- 949
		partialLine = partialLine -- 950
	} -- 950
end -- 950
function sanitizeReadResultForHistory(tool, result) -- 966
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 966
		return result -- 968
	end -- 968
	local clone = {} -- 970
	for key in pairs(result) do -- 971
		clone[key] = result[key] -- 972
	end -- 972
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 974
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 975
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 976
	local limited = limitReadContentForHistory( -- 977
		result.content, -- 978
		startLine, -- 979
		endLine, -- 980
		totalLines, -- 981
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 982
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 983
		"read_file history" -- 984
	) -- 984
	clone.content = limited.content -- 986
	if limited.truncated then -- 986
		clone.historyContentTruncated = true -- 988
		clone.historyRetainedStartLine = limited.retainedStartLine -- 989
		clone.historyRetainedEndLine = limited.retainedEndLine -- 990
		if limited.nextStartLine ~= nil then -- 990
			clone.historyNextStartLine = limited.nextStartLine -- 991
		end -- 991
		if limited.partialLine ~= nil then -- 991
			clone.historyPartialLine = limited.partialLine -- 992
		end -- 992
	end -- 992
	return clone -- 994
end -- 994
function sanitizeSearchMatchesForHistory(items, maxItems) -- 997
	local shown = math.min(#items, maxItems) -- 1001
	local out = {} -- 1002
	do -- 1002
		local i = 0 -- 1003
		while i < shown do -- 1003
			local row = items[i + 1] -- 1004
			out[#out + 1] = { -- 1005
				file = row.file, -- 1006
				line = row.line, -- 1007
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1008
			} -- 1008
			i = i + 1 -- 1003
		end -- 1003
	end -- 1003
	return out -- 1013
end -- 1013
function sanitizeSearchResultForHistory(tool, result) -- 1016
	if result.success ~= true or not isArray(result.results) then -- 1016
		return result -- 1020
	end -- 1020
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1020
		return result -- 1021
	end -- 1021
	local clone = {} -- 1022
	for key in pairs(result) do -- 1023
		clone[key] = result[key] -- 1024
	end -- 1024
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 1026
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1027
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1027
		local grouped = result.groupedResults -- 1032
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 1033
		local sanitizedGroups = {} -- 1034
		do -- 1034
			local i = 0 -- 1035
			while i < shown do -- 1035
				local row = grouped[i + 1] -- 1036
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1037
					file = row.file, -- 1038
					totalMatches = row.totalMatches, -- 1039
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1040
				} -- 1040
				i = i + 1 -- 1035
			end -- 1035
		end -- 1035
		clone.groupedResults = sanitizedGroups -- 1045
	end -- 1045
	return clone -- 1047
end -- 1047
function sanitizeListFilesResultForHistory(result) -- 1050
	if result.success ~= true or not isArray(result.files) then -- 1050
		return result -- 1051
	end -- 1051
	local clone = {} -- 1052
	for key in pairs(result) do -- 1053
		clone[key] = result[key] -- 1054
	end -- 1054
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 1056
	return clone -- 1057
end -- 1057
function sanitizeBuildResultForHistory(result) -- 1060
	if not isArray(result.messages) then -- 1060
		return result -- 1061
	end -- 1061
	local clone = {} -- 1062
	for key in pairs(result) do -- 1063
		clone[key] = result[key] -- 1064
	end -- 1064
	local messages = result.messages -- 1066
	local ordered = __TS__ArraySort( -- 1067
		__TS__ArraySlice(messages), -- 1067
		function(____, a, b) -- 1067
			local aFailed = a.success ~= true -- 1068
			local bFailed = b.success ~= true -- 1069
			if aFailed == bFailed then -- 1069
				return 0 -- 1070
			end -- 1070
			return aFailed and -1 or 1 -- 1071
		end -- 1067
	) -- 1067
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1073
	local sanitized = {} -- 1074
	do -- 1074
		local i = 0 -- 1075
		while i < shown do -- 1075
			local item = ordered[i + 1] -- 1076
			local next = {} -- 1077
			for key in pairs(item) do -- 1078
				local value = item[key] -- 1079
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1080
			end -- 1080
			sanitized[#sanitized + 1] = next -- 1084
			i = i + 1 -- 1075
		end -- 1075
	end -- 1075
	clone.messages = sanitized -- 1086
	if #ordered > shown then -- 1086
		clone.truncatedMessages = #ordered - shown -- 1088
	end -- 1088
	return clone -- 1090
end -- 1090
function projectEditResultForLLM(result) -- 1108
	if result.success ~= true then -- 1108
		local failed = {} -- 1110
		for key in pairs(result) do -- 1111
			local value = result[key] -- 1112
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 1113
		end -- 1113
		return failed -- 1117
	end -- 1117
	local projected = {} -- 1119
	local scalarKeys = { -- 1120
		"success", -- 1121
		"changed", -- 1121
		"mode", -- 1121
		"checkpointId", -- 1121
		"checkpointSeq", -- 1121
		"actualSaved", -- 1122
		"actualSavedCharacters", -- 1122
		"currentFileExists", -- 1122
		"currentCharacters", -- 1122
		"currentState" -- 1122
	} -- 1122
	do -- 1122
		local i = 0 -- 1124
		while i < #scalarKeys do -- 1124
			local key = scalarKeys[i + 1] -- 1125
			if result[key] ~= nil then -- 1125
				projected[key] = result[key] -- 1126
			end -- 1126
			i = i + 1 -- 1124
		end -- 1124
	end -- 1124
	if isArray(result.files) then -- 1124
		projected.files = result.files -- 1128
	end -- 1128
	if type(result.message) == "string" then -- 1128
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1130
	end -- 1130
	if type(result.guidance) == "string" then -- 1130
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1137
	end -- 1137
	if isArray(result.fileContext) then -- 1137
		local summaries = {} -- 1144
		do -- 1144
			local i = 0 -- 1145
			while i < #result.fileContext do -- 1145
				do -- 1145
					local item = result.fileContext[i + 1] -- 1146
					if not isRecord(item) or isArray(item) then -- 1146
						goto __continue157 -- 1147
					end -- 1147
					local summary = {} -- 1148
					local keys = { -- 1149
						"path", -- 1150
						"op", -- 1150
						"beforeExists", -- 1150
						"afterExists", -- 1150
						"beforeBytes", -- 1150
						"afterBytes", -- 1150
						"lineCount", -- 1151
						"contentTruncated", -- 1151
						"fileListTruncated" -- 1151
					} -- 1151
					do -- 1151
						local j = 0 -- 1153
						while j < #keys do -- 1153
							local key = keys[j + 1] -- 1154
							if item[key] ~= nil then -- 1154
								summary[key] = item[key] -- 1155
							end -- 1155
							j = j + 1 -- 1153
						end -- 1153
					end -- 1153
					summaries[#summaries + 1] = summary -- 1157
				end -- 1157
				::__continue157:: -- 1157
				i = i + 1 -- 1145
			end -- 1145
		end -- 1145
		if #summaries > 0 then -- 1145
			projected.fileSummary = summaries -- 1159
		end -- 1159
	end -- 1159
	if type(result.truncatedFileContextItems) == "number" then -- 1159
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1162
	end -- 1162
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1164
	return projected -- 1165
end -- 1165
function projectBuildResultForLLM(result) -- 1168
	if not isArray(result.messages) then -- 1168
		return result -- 1169
	end -- 1169
	local projected = {} -- 1170
	for key in pairs(result) do -- 1171
		if key ~= "messages" then -- 1171
			projected[key] = result[key] -- 1172
		end -- 1172
	end -- 1172
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1174
	local shown = math.min(#result.messages, maxMessages) -- 1175
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1176
	if #result.messages > shown then -- 1176
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1178
	end -- 1178
	return projected -- 1180
end -- 1180
function projectCommandResultForLLM(result) -- 1183
	local projected = {} -- 1184
	for key in pairs(result) do -- 1185
		local value = result[key] -- 1186
		if key == "output" and type(value) == "string" then -- 1186
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1188
		elseif key == "message" and type(value) == "string" then -- 1188
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1194
		else -- 1194
			projected[key] = value -- 1200
		end -- 1200
	end -- 1200
	return projected -- 1203
end -- 1203
function projectToolResultContentForLLM(tool, content) -- 1206
	local decoded = AgentUtils.safeJsonDecode(content) -- 1207
	if not isRecord(decoded) or isArray(decoded) then -- 1207
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1209
	end -- 1209
	local projected = decoded -- 1215
	if tool == "edit_file" or tool == "delete_file" then -- 1215
		projected = projectEditResultForLLM(decoded) -- 1217
	elseif tool == "build" then -- 1217
		projected = projectBuildResultForLLM(decoded) -- 1219
	elseif tool == "execute_command" then -- 1219
		projected = projectCommandResultForLLM(decoded) -- 1221
	end -- 1221
	local encoded = toJson(projected, false) -- 1223
	if tool == "read_file" then -- 1223
		return encoded -- 1226
	end -- 1226
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1226
		return encoded -- 1227
	end -- 1227
	local fallback = { -- 1228
		success = projected.success, -- 1229
		llmHistoryTruncated = true, -- 1230
		originalChars = #encoded, -- 1231
		preview = truncateHistoryText( -- 1232
			encoded, -- 1233
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1234
			tool .. " result" -- 1235
		) -- 1235
	} -- 1235
	return toJson(fallback, false) -- 1238
end -- 1238
function projectMessagesForLLMContext(messages) -- 1241
	local projected = {} -- 1245
	do -- 1245
		local i = 0 -- 1246
		while i < #messages do -- 1246
			local message = messages[i + 1] -- 1247
			local next = __TS__ObjectAssign({}, message) -- 1248
			if message.role == "tool" and type(message.content) == "string" then -- 1248
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1250
			end -- 1250
			projected[#projected + 1] = next -- 1252
			i = i + 1 -- 1246
		end -- 1246
	end -- 1246
	return projected -- 1254
end -- 1254
function ____exports.getDecisionDisabledAgentTools(shared) -- 1282
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1286
end -- 1282
function getDecisionToolDefinitions(shared) -- 1289
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1290
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1291
	local base = shared.promptPack.toolDefinitionsDetailed -- 1294
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1295
	if usesDefaultToolPrompts then -- 1295
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1298
			shared.role, -- 1298
			{ -- 1298
				includeFinish = true, -- 1299
				includeXmlRules = true, -- 1300
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1301
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1302
				workMode = shared.workMode -- 1303
			} -- 1303
		) -- 1303
		return replacePromptVars(definitions, params) -- 1305
	end -- 1305
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1307
	if (shared and shared.decisionMode) ~= "xml" then -- 1307
		return withRole -- 1312
	end -- 1312
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1314
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1315
end -- 1315
function isToolAllowedForRole(shared, tool) -- 1329
	return __TS__ArrayIndexOf( -- 1330
		AgentToolRegistry.getAllowedToolsForRole( -- 1330
			shared.role, -- 1330
			{ -- 1330
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1331
				workMode = shared.workMode -- 1332
			} -- 1332
		), -- 1332
		tool -- 1333
	) >= 0 -- 1333
end -- 1333
function getFinishMessage(params, fallback) -- 1796
	if fallback == nil then -- 1796
		fallback = "" -- 1796
	end -- 1796
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1796
		return __TS__StringTrim(params.message) -- 1798
	end -- 1798
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1798
		return __TS__StringTrim(params.response) -- 1801
	end -- 1801
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1801
		return __TS__StringTrim(params.summary) -- 1804
	end -- 1804
	return __TS__StringTrim(fallback) -- 1806
end -- 1806
function getCompletionReport(params) -- 1809
	return AgentUtils.normalizeAgentCompletionReport(params) -- 1810
end -- 1810
function persistHistoryState(shared) -- 1813
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1814
end -- 1814
function getActiveConversationMessages(shared) -- 1821
	local activeMessages = {} -- 1822
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1822
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1829
	end -- 1829
	do -- 1829
		local i = shared.lastConsolidatedIndex -- 1833
		while i < #shared.messages do -- 1833
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1834
			i = i + 1 -- 1833
		end -- 1833
	end -- 1833
	return activeMessages -- 1836
end -- 1836
function getActiveRealMessageCount(shared) -- 1839
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1840
end -- 1840
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1843
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1849
	local previousActiveStart = shared.lastConsolidatedIndex -- 1850
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1851
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1852
	if type(carryMessageIndex) == "number" then -- 1852
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1852
		else -- 1852
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1860
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1863
		end -- 1863
	else -- 1863
		shared.carryMessageIndex = nil -- 1868
	end -- 1868
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1868
		shared.carryMessageIndex = nil -- 1878
	end -- 1878
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1886
	shared.resumeCheckpointPending = true -- 1887
	shared.resumeRequiredTool = nil -- 1888
	shared.resumeNarrowReadMode = true -- 1889
	if shared.unbuiltEdits == true then -- 1889
		shared.resumeRequiredTool = "build" -- 1897
	end -- 1897
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 -- 1906
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1906
		local marker = "**Next tool**:" -- 1917
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1918
		if markerIndex >= 0 then -- 1918
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1920
			local toolNames = { -- 1921
				"read_file", -- 1922
				"edit_file", -- 1922
				"delete_file", -- 1922
				"grep_files", -- 1922
				"search_dora_api", -- 1922
				"glob_files", -- 1923
				"build", -- 1923
				"fetch_url", -- 1923
				"execute_command", -- 1923
				"list_sub_agents", -- 1923
				"spawn_sub_agent", -- 1924
				"finish" -- 1924
			} -- 1924
			do -- 1924
				local i = 0 -- 1926
				while i < #toolNames do -- 1926
					local tool = toolNames[i + 1] -- 1927
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1927
						shared.resumeRequiredTool = tool -- 1929
						break -- 1930
					end -- 1930
					i = i + 1 -- 1926
				end -- 1926
			end -- 1926
		end -- 1926
	end -- 1926
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1926
		shared.resumeRequiredTool = nil -- 1936
	end -- 1936
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1936
		shared.resumeRequiredTool = nil -- 1939
	end -- 1939
end -- 1939
function ensureToolCallId(toolCallId) -- 1954
	if toolCallId and toolCallId ~= "" then -- 1954
		return toolCallId -- 1955
	end -- 1955
	return AgentUtils.createLocalToolCallId() -- 1956
end -- 1956
function hasXMLParam(params, name) -- 1989
	return params[name] ~= nil -- 1990
end -- 1990
function inferToolNameFromXMLParams(params) -- 1993
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1993
		return "edit_file" -- 1995
	end -- 1995
	if hasXMLParam(params, "target_file") then -- 1995
		return "delete_file" -- 1998
	end -- 1998
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1998
		if hasXMLParam(params, "path") then -- 1998
			return "read_file" -- 2001
		end -- 2001
		return nil -- 2002
	end -- 2002
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 2002
		if hasXMLParam(params, "pattern") then -- 2002
			return "search_dora_api" -- 2005
		end -- 2005
		return nil -- 2006
	end -- 2006
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 2006
		if hasXMLParam(params, "pattern") then -- 2006
			return "grep_files" -- 2009
		end -- 2009
		return nil -- 2010
	end -- 2010
	if hasXMLParam(params, "globs") then -- 2010
		if hasXMLParam(params, "pattern") then -- 2010
			return "grep_files" -- 2013
		end -- 2013
		return "glob_files" -- 2014
	end -- 2014
	if hasXMLParam(params, "maxEntries") then -- 2014
		return "glob_files" -- 2017
	end -- 2017
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2017
		return "finish" -- 2020
	end -- 2020
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 2020
		return "spawn_sub_agent" -- 2023
	end -- 2023
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 2023
		return "list_sub_agents" -- 2026
	end -- 2026
	return nil -- 2028
end -- 2028
function parseDSMLAttribute(source, offset, name) -- 2031
	local attrOpen = name .. "=\"" -- 2032
	local attrStart = (string.find( -- 2033
		source, -- 2033
		attrOpen, -- 2033
		math.max(offset + 1, 1), -- 2033
		true -- 2033
	) or 0) - 1 -- 2033
	if attrStart < 0 then -- 2033
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 2034
	end -- 2034
	local valueStart = attrStart + #attrOpen -- 2035
	local valueEnd = (string.find( -- 2036
		source, -- 2036
		"\"", -- 2036
		math.max(valueStart + 1, 1), -- 2036
		true -- 2036
	) or 0) - 1 -- 2036
	if valueEnd < 0 then -- 2036
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 2037
	end -- 2037
	return { -- 2038
		success = true, -- 2039
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 2040
		next = valueEnd + 1 -- 2041
	} -- 2041
end -- 2041
function extractDSMLReason(text, invokeStart, tool) -- 2045
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2046
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2047
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2047
		return before -- 2050
	end -- 2050
	if tool == "finish" then -- 2050
		return "" -- 2051
	end -- 2051
	return "Converted provider-native tool call syntax to XML." -- 2052
end -- 2052
function parseDSMLToolCallObjectFromText(text) -- 2055
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2056
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2057
	if invokeStart < 0 then -- 2057
		return {success = false, message = "missing DSML invoke"} -- 2058
	end -- 2058
	local nameStart = invokeStart + #invokeOpen -- 2059
	local nameEnd = (string.find( -- 2060
		text, -- 2060
		"\"", -- 2060
		math.max(nameStart + 1, 1), -- 2060
		true -- 2060
	) or 0) - 1 -- 2060
	if nameEnd < 0 then -- 2060
		return {success = false, message = "unterminated DSML invoke name"} -- 2061
	end -- 2061
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2062
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2062
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2064
	end -- 2064
	local invokeOpenEnd = (string.find( -- 2066
		text, -- 2066
		">", -- 2066
		math.max(nameEnd + 1, 1), -- 2066
		true -- 2066
	) or 0) - 1 -- 2066
	if invokeOpenEnd < 0 then -- 2066
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2067
	end -- 2067
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2068
	local invokeEnd = (string.find( -- 2069
		text, -- 2069
		invokeClose, -- 2069
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2069
		true -- 2069
	) or 0) - 1 -- 2069
	if invokeEnd < 0 then -- 2069
		return {success = false, message = "missing DSML invoke close tag"} -- 2070
	end -- 2070
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2072
	local params = {} -- 2073
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2074
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2075
	local pos = 0 -- 2076
	while pos < #body do -- 2076
		local start = (string.find( -- 2078
			body, -- 2078
			paramOpen, -- 2078
			math.max(pos + 1, 1), -- 2078
			true -- 2078
		) or 0) - 1 -- 2078
		if start < 0 then -- 2078
			break -- 2079
		end -- 2079
		local openEnd = (string.find( -- 2080
			body, -- 2080
			">", -- 2080
			math.max(start + #paramOpen + 1, 1), -- 2080
			true -- 2080
		) or 0) - 1 -- 2080
		if openEnd < 0 then -- 2080
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2081
		end -- 2081
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2082
		if not name.success then -- 2082
			return name -- 2083
		end -- 2083
		local close = (string.find( -- 2084
			body, -- 2084
			paramClose, -- 2084
			math.max(openEnd + 1 + 1, 1), -- 2084
			true -- 2084
		) or 0) - 1 -- 2084
		if close < 0 then -- 2084
			return {success = false, message = "missing DSML parameter close tag"} -- 2085
		end -- 2085
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2086
		pos = close + #paramClose -- 2087
	end -- 2087
	return { -- 2089
		success = true, -- 2090
		obj = { -- 2091
			tool = toolName, -- 2092
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2093
			params = params -- 2094
		} -- 2094
	} -- 2094
end -- 2094
function parseXMLToolCallObjectFromText(text) -- 2099
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2100
	local rawObj -- 2101
	if children.success then -- 2101
		rawObj = children.obj -- 2103
	else -- 2103
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2105
		if dsml.success then -- 2105
			return dsml -- 2106
		end -- 2106
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2107
		local paramsCloseToken = "</params>" -- 2108
		if toolStart >= 0 then -- 2108
			local paramsClose = (string.find( -- 2110
				text, -- 2110
				paramsCloseToken, -- 2110
				math.max(toolStart + 1, 1), -- 2110
				true -- 2110
			) or 0) - 1 -- 2110
			if paramsClose >= toolStart then -- 2110
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2112
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2113
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2113
					rawObj = bare.obj -- 2115
				end -- 2115
			end -- 2115
		end -- 2115
		if rawObj == nil then -- 2115
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2120
			if paramsOpen < 0 then -- 2120
				return children -- 2121
			end -- 2121
			local paramsCloseOnly = (string.find( -- 2122
				text, -- 2122
				paramsCloseToken, -- 2122
				math.max(paramsOpen + 1, 1), -- 2122
				true -- 2122
			) or 0) - 1 -- 2122
			if paramsCloseOnly < paramsOpen then -- 2122
				return children -- 2123
			end -- 2123
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2124
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2125
			if not paramsOnly.success then -- 2125
				return children -- 2126
			end -- 2126
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2127
			if inferredTool == nil then -- 2127
				return children -- 2128
			end -- 2128
			local ____temp_50 -- 2133
			if inferredTool == "finish" then -- 2133
				____temp_50 = nil -- 2133
			else -- 2133
				____temp_50 = "Inferred tool from XML params." -- 2133
			end -- 2133
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2129
		end -- 2129
	end -- 2129
	if rawObj == nil then -- 2129
		return children -- 2139
	end -- 2139
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2140
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2141
	if not params.success then -- 2141
		return {success = false, message = params.message} -- 2145
	end -- 2145
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2147
end -- 2147
function parseDecisionObject(rawObj) -- 2243
	if type(rawObj.tool) ~= "string" then -- 2243
		return {success = false, message = "missing tool"} -- 2244
	end -- 2244
	local tool = rawObj.tool -- 2245
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2245
		return {success = false, message = "unknown tool: " .. tool} -- 2247
	end -- 2247
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2249
	if tool ~= "finish" and (not reason or reason == "") then -- 2249
		return {success = false, message = tool .. " requires top-level reason"} -- 2253
	end -- 2253
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2255
	return {success = true, tool = tool, params = params, reason = reason} -- 2256
end -- 2256
function getDecisionPath(params) -- 2378
	if type(params.path) == "string" then -- 2378
		return __TS__StringTrim(params.path) -- 2379
	end -- 2379
	if type(params.target_file) == "string" then -- 2379
		return __TS__StringTrim(params.target_file) -- 2380
	end -- 2380
	return "" -- 2381
end -- 2381
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2384
	if enforceFinalTurn == nil then -- 2384
		enforceFinalTurn = false -- 2388
	end -- 2388
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2388
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2391
	end -- 2391
	if not isToolAllowedForRole(shared, tool) then -- 2391
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2394
	end -- 2394
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2394
		local path = getDecisionPath(params) -- 2397
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2397
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2399
		end -- 2399
	end -- 2399
	if tool == "delete_file" then -- 2399
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2403
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2403
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2405
		end -- 2405
	end -- 2405
	return {success = true} -- 2408
end -- 2408
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2411
	local num = __TS__Number(value) -- 2412
	if not __TS__NumberIsFinite(num) then -- 2412
		num = fallback -- 2413
	end -- 2413
	num = math.floor(num) -- 2414
	if num < minValue then -- 2414
		num = minValue -- 2415
	end -- 2415
	if maxValue ~= nil and num > maxValue then -- 2415
		num = maxValue -- 2416
	end -- 2416
	return num -- 2417
end -- 2417
function parseReadLineParam(value, fallback, paramName) -- 2420
	local num = __TS__Number(value) -- 2425
	if not __TS__NumberIsFinite(num) then -- 2425
		num = fallback -- 2426
	end -- 2426
	num = math.floor(num) -- 2427
	if num == 0 then -- 2427
		return {success = false, message = paramName .. " cannot be 0"} -- 2429
	end -- 2429
	return {success = true, value = num} -- 2431
end -- 2431
function validateDecision(tool, params) -- 2434
	if tool == "finish" then -- 2434
		local message = getFinishMessage(params) -- 2439
		if message == "" then -- 2439
			return {success = false, message = "finish requires params.message"} -- 2440
		end -- 2440
		params.message = message -- 2441
		local completion = getCompletionReport(params) -- 2442
		params.outcome = completion.outcome -- 2443
		params.validation = completion.validation -- 2444
		params.knownIssues = completion.knownIssues -- 2445
		params.assumptions = completion.assumptions -- 2446
		params.learningCandidates = completion.learningCandidates -- 2447
		return {success = true, params = params} -- 2448
	end -- 2448
	if tool == "ask_user" then -- 2448
		local normalized = normalizeQuestionnaire(params) -- 2452
		if not normalized.success then -- 2452
			return normalized -- 2453
		end -- 2453
		return {success = true, params = normalized.schema} -- 2454
	end -- 2454
	if tool == "read_file" then -- 2454
		local path = getDecisionPath(params) -- 2458
		if path == "" then -- 2458
			return {success = false, message = "read_file requires path"} -- 2459
		end -- 2459
		params.path = path -- 2460
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2461
		if not startLineRes.success then -- 2461
			return startLineRes -- 2462
		end -- 2462
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2463
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2464
		if not endLineRes.success then -- 2464
			return endLineRes -- 2465
		end -- 2465
		params.startLine = startLineRes.value -- 2466
		params.endLine = endLineRes.value -- 2467
		return {success = true, params = params} -- 2468
	end -- 2468
	if tool == "edit_file" then -- 2468
		local path = getDecisionPath(params) -- 2472
		if path == "" then -- 2472
			return {success = false, message = "edit_file requires path"} -- 2473
		end -- 2473
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2474
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2475
		params.path = path -- 2476
		params.old_str = oldStr -- 2477
		params.new_str = newStr -- 2478
		return {success = true, params = params} -- 2479
	end -- 2479
	if tool == "delete_file" then -- 2479
		local targetFile = getDecisionPath(params) -- 2483
		if targetFile == "" then -- 2483
			return {success = false, message = "delete_file requires target_file"} -- 2484
		end -- 2484
		params.target_file = targetFile -- 2485
		return {success = true, params = params} -- 2486
	end -- 2486
	if tool == "grep_files" then -- 2486
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2490
		if pattern == "" then -- 2490
			return {success = false, message = "grep_files requires pattern"} -- 2491
		end -- 2491
		params.pattern = pattern -- 2492
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2493
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2494
		return {success = true, params = params} -- 2495
	end -- 2495
	if tool == "search_dora_api" then -- 2495
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2499
		if pattern == "" then -- 2499
			return {success = false, message = "search_dora_api requires pattern"} -- 2500
		end -- 2500
		params.pattern = pattern -- 2501
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2502
		return {success = true, params = params} -- 2503
	end -- 2503
	if tool == "glob_files" then -- 2503
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2507
		return {success = true, params = params} -- 2508
	end -- 2508
	if tool == "build" then -- 2508
		local path = getDecisionPath(params) -- 2512
		if path ~= "" then -- 2512
			params.path = path -- 2514
		end -- 2514
		return {success = true, params = params} -- 2516
	end -- 2516
	if tool == "list_sub_agents" then -- 2516
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2520
		if status ~= "" then -- 2520
			params.status = status -- 2522
		end -- 2522
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2524
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2525
		if type(params.query) == "string" then -- 2525
			params.query = __TS__StringTrim(params.query) -- 2527
		end -- 2527
		return {success = true, params = params} -- 2529
	end -- 2529
	if tool == "spawn_sub_agent" then -- 2529
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2533
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2534
		if prompt == "" then -- 2534
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2535
		end -- 2535
		if title == "" then -- 2535
			return {success = false, message = "spawn_sub_agent requires title"} -- 2536
		end -- 2536
		params.prompt = prompt -- 2537
		params.title = title -- 2538
		if type(params.expectedOutput) == "string" then -- 2538
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2540
		end -- 2540
		if isArray(params.filesHint) then -- 2540
			params.filesHint = __TS__ArrayMap( -- 2543
				__TS__ArrayFilter( -- 2543
					params.filesHint, -- 2543
					function(____, item) return type(item) == "string" end -- 2544
				), -- 2544
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2545
			) -- 2545
		end -- 2545
		return {success = true, params = params} -- 2547
	end -- 2547
	return {success = true, params = params} -- 2550
end -- 2550
function validateCompletionForRole(role, tool, params) -- 2553
	if role ~= "sub" or tool ~= "finish" then -- 2553
		return {success = true} -- 2558
	end -- 2558
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2558
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2560
	end -- 2560
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2562
	do -- 2562
		local i = 0 -- 2563
		while i < #requiredArrays do -- 2563
			local name = requiredArrays[i + 1] -- 2564
			if not isArray(params[name]) then -- 2564
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2566
			end -- 2566
			i = i + 1 -- 2563
		end -- 2563
	end -- 2563
	return {success = true} -- 2569
end -- 2569
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2572
	if includeToolDefinitions == nil then -- 2572
		includeToolDefinitions = false -- 2572
	end -- 2572
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2573
	local sections = { -- 2576
		shared.promptPack.agentIdentityPrompt, -- 2577
		rolePrompt, -- 2578
		getReplyLanguageDirective(shared) -- 2579
	} -- 2579
	if shared.role == "main" then -- 2579
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2582
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2583
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2583
			sections[#sections + 1] = table.concat( -- 2585
				{ -- 2585
					"# Current Living Development Plan", -- 2586
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2587
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2587
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2588
						12000 -- 2588
					), -- 2588
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2588
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2589
						12000 -- 2589
					) -- 2589
				}, -- 2589
				"\n\n" -- 2590
			) -- 2590
		end -- 2590
	end -- 2590
	if shared.decisionMode == "tool_calling" then -- 2590
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2594
	end -- 2594
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2596
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2597
	if memoryContext ~= "" then -- 2597
		sections[#sections + 1] = memoryContext -- 2599
	end -- 2599
	local skillsSection = buildSkillsSection(shared) -- 2601
	if skillsSection ~= "" then -- 2601
		sections[#sections + 1] = skillsSection -- 2603
	end -- 2603
	if includeToolDefinitions then -- 2603
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2606
		if shared.decisionMode == "xml" then -- 2606
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2608
		end -- 2608
	end -- 2608
	return table.concat(sections, "\n\n") -- 2611
end -- 2611
function buildSkillsSection(shared) -- 2614
	local ____opt_69 = shared.skills -- 2614
	if not (____opt_69 and ____opt_69.loader) then -- 2614
		return "" -- 2616
	end -- 2616
	return shared.skills.loader:buildSkillsPromptSection() -- 2618
end -- 2618
function sanitizeMessagesForLLMInput(messages) -- 2621
	local sanitized = {} -- 2622
	local droppedAssistantToolCalls = 0 -- 2623
	local droppedToolResults = 0 -- 2624
	do -- 2624
		local i = 0 -- 2625
		while i < #messages do -- 2625
			do -- 2625
				local message = messages[i + 1] -- 2626
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2626
					local requiredIds = {} -- 2628
					do -- 2628
						local j = 0 -- 2629
						while j < #message.tool_calls do -- 2629
							local toolCall = message.tool_calls[j + 1] -- 2630
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2631
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2631
								requiredIds[#requiredIds + 1] = id -- 2633
							end -- 2633
							j = j + 1 -- 2629
						end -- 2629
					end -- 2629
					if #requiredIds == 0 then -- 2629
						sanitized[#sanitized + 1] = message -- 2637
						goto __continue453 -- 2638
					end -- 2638
					local matchedIds = {} -- 2640
					local matchedTools = {} -- 2641
					local j = i + 1 -- 2642
					while j < #messages do -- 2642
						local toolMessage = messages[j + 1] -- 2644
						if toolMessage.role ~= "tool" then -- 2644
							break -- 2645
						end -- 2645
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2646
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2646
							matchedIds[toolCallId] = true -- 2648
							matchedTools[#matchedTools + 1] = toolMessage -- 2649
						else -- 2649
							droppedToolResults = droppedToolResults + 1 -- 2651
						end -- 2651
						j = j + 1 -- 2653
					end -- 2653
					local complete = true -- 2655
					do -- 2655
						local j = 0 -- 2656
						while j < #requiredIds do -- 2656
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2656
								complete = false -- 2658
								break -- 2659
							end -- 2659
							j = j + 1 -- 2656
						end -- 2656
					end -- 2656
					if complete then -- 2656
						__TS__ArrayPush( -- 2663
							sanitized, -- 2663
							message, -- 2663
							table.unpack(matchedTools) -- 2663
						) -- 2663
					else -- 2663
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2665
						droppedToolResults = droppedToolResults + #matchedTools -- 2666
					end -- 2666
					i = j - 1 -- 2668
					goto __continue453 -- 2669
				end -- 2669
				if message.role == "tool" then -- 2669
					droppedToolResults = droppedToolResults + 1 -- 2672
					goto __continue453 -- 2673
				end -- 2673
				sanitized[#sanitized + 1] = message -- 2675
			end -- 2675
			::__continue453:: -- 2675
			i = i + 1 -- 2625
		end -- 2625
	end -- 2625
	return sanitized -- 2677
end -- 2677
function getUnconsolidatedMessages(shared) -- 2680
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2681
end -- 2681
function isFinalDecisionTurn(shared) -- 2686
	return shared.agentStepCount + 1 >= shared.maxSteps -- 2687
end -- 2687
function getFinalDecisionTurnPrompt(shared) -- 2690
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2691
end -- 2691
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2696
	if attempt == nil then -- 2696
		attempt = 1 -- 2699
	end -- 2699
	if decisionMode == nil then -- 2699
		decisionMode = shared.decisionMode -- 2701
	end -- 2701
	if consumeResumeCheckpoint == nil then -- 2701
		consumeResumeCheckpoint = true -- 2702
	end -- 2702
	if pendingUserPrompt == nil then -- 2702
		pendingUserPrompt = "" -- 2703
	end -- 2703
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2705
	local tailSections = {} -- 2706
	if shared.resumeCheckpointPending == true then -- 2706
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2708
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2711
	end -- 2711
	if shared.truncatedToolOverwritePath ~= nil then -- 2711
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2714
	end -- 2714
	if consumeResumeCheckpoint then -- 2714
		shared.resumeCheckpointPending = false -- 2716
	end -- 2716
	local messages = { -- 2717
		{role = "system", content = systemPrompt}, -- 2718
		table.unpack(getUnconsolidatedMessages(shared)) -- 2719
	} -- 2719
	if pendingUserPrompt ~= "" then -- 2719
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2722
	end -- 2722
	if isFinalDecisionTurn(shared) then -- 2722
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2725
	end -- 2725
	if lastError and lastError ~= "" then -- 2725
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2728
		if decisionMode == "xml" then -- 2728
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2732
		end -- 2732
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2732
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2735
		end -- 2735
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2735
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2738
		end -- 2738
		messages[#messages + 1] = { -- 2740
			role = "user", -- 2741
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2742
		} -- 2742
	end -- 2742
	if #tailSections > 0 then -- 2742
		messages[#messages + 1] = { -- 2750
			role = "user", -- 2751
			content = table.concat(tailSections, "\n\n") -- 2752
		} -- 2752
	end -- 2752
	return messages -- 2755
end -- 2755
function buildXmlDecisionInstruction(shared, feedback) -- 2758
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2759
end -- 2759
function tryParseAndValidateDecision(rawText, shared) -- 2827
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2828
	if not parsed.success then -- 2828
		return {success = false, message = parsed.message, raw = rawText} -- 2830
	end -- 2830
	local decision = parseDecisionObject(parsed.obj) -- 2832
	if not decision.success then -- 2832
		return {success = false, message = decision.message, raw = rawText} -- 2834
	end -- 2834
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2836
	if not completionValidation.success then -- 2836
		return {success = false, message = completionValidation.message, raw = rawText} -- 2838
	end -- 2838
	local validation = validateDecision(decision.tool, decision.params) -- 2840
	if not validation.success then -- 2840
		return {success = false, message = validation.message, raw = rawText} -- 2842
	end -- 2842
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2844
	if not sharedValidation.success then -- 2844
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2846
	end -- 2846
	decision.params = validation.params -- 2848
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2849
	return decision -- 2850
end -- 2850
function executeToolAction(shared, action) -- 4017
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4017
		if shared.stopToken.stopped then -- 4017
			return ____awaiter_resolve( -- 4017
				nil, -- 4017
				{ -- 4019
					success = false, -- 4019
					message = getCancelledReason(shared) -- 4019
				} -- 4019
			) -- 4019
		end -- 4019
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4019
			shared.resumeRequiredTool = nil -- 4022
			shared.resumeCheckpointPending = false -- 4023
		end -- 4023
		local params = action.params -- 4025
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4026
		if not sharedValidation.success then -- 4026
			return ____awaiter_resolve(nil, sharedValidation) -- 4026
		end -- 4026
		if action.tool == "read_file" then -- 4026
			local ____params_startLine_143 = params.startLine -- 4029
			if ____params_startLine_143 == nil then -- 4029
				____params_startLine_143 = 1 -- 4029
			end -- 4029
			local startLine = __TS__Number(____params_startLine_143) -- 4029
			local ____params_endLine_144 = params.endLine -- 4030
			if ____params_endLine_144 == nil then -- 4030
				____params_endLine_144 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4030
			end -- 4030
			local endLine = __TS__Number(____params_endLine_144) -- 4030
			local clippedAfterCompression = false -- 4031
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4031
				endLine = startLine + 159 -- 4038
				clippedAfterCompression = true -- 4039
			end -- 4039
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4041
			if __TS__StringTrim(path) == "" then -- 4041
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4041
			end -- 4041
			local result = Tools.readFile( -- 4045
				shared.workingDir, -- 4046
				path, -- 4047
				startLine, -- 4048
				endLine, -- 4049
				shared.useChineseResponse and "zh" or "en" -- 4050
			) -- 4050
			if clippedAfterCompression and result.success == true then -- 4050
				result.clipped = true -- 4053
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4054
			end -- 4054
			return ____awaiter_resolve(nil, result) -- 4054
		end -- 4054
		if action.tool == "grep_files" then -- 4054
			local searchPath = params.path or "" -- 4061
			local searchGlobs = params.globs -- 4062
			local ____Tools_searchFiles_158 = Tools.searchFiles -- 4063
			local ____shared_workingDir_151 = shared.workingDir -- 4064
			local ____temp_152 = params.pattern or "" -- 4066
			local ____params_globs_153 = params.globs -- 4067
			local ____params_useRegex_154 = params.useRegex -- 4068
			local ____params_caseSensitive_155 = params.caseSensitive -- 4069
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4071
			local ____math_max_147 = math.max -- 4072
			local ____math_floor_146 = math.floor -- 4072
			local ____params_limit_145 = params.limit -- 4072
			if ____params_limit_145 == nil then -- 4072
				____params_limit_145 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4072
			end -- 4072
			local ____math_max_147_result_157 = ____math_max_147( -- 4072
				1, -- 4072
				____math_floor_146(__TS__Number(____params_limit_145)) -- 4072
			) -- 4072
			local ____math_max_150 = math.max -- 4073
			local ____math_floor_149 = math.floor -- 4073
			local ____params_offset_148 = params.offset -- 4073
			if ____params_offset_148 == nil then -- 4073
				____params_offset_148 = 0 -- 4073
			end -- 4073
			local result = __TS__Await(____Tools_searchFiles_158({ -- 4063
				workDir = ____shared_workingDir_151, -- 4064
				path = searchPath, -- 4065
				pattern = ____temp_152, -- 4066
				globs = ____params_globs_153, -- 4067
				useRegex = ____params_useRegex_154, -- 4068
				caseSensitive = ____params_caseSensitive_155, -- 4069
				includeContent = true, -- 4070
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156, -- 4071
				limit = ____math_max_147_result_157, -- 4072
				offset = ____math_max_150( -- 4073
					0, -- 4073
					____math_floor_149(__TS__Number(____params_offset_148)) -- 4073
				), -- 4073
				groupByFile = params.groupByFile == true -- 4074
			})) -- 4074
			return ____awaiter_resolve(nil, result) -- 4074
		end -- 4074
		if action.tool == "search_dora_api" then -- 4074
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4079
			local ____Tools_searchDoraAPI_167 = Tools.searchDoraAPI -- 4080
			local ____temp_163 = params.pattern or "" -- 4081
			local ____temp_164 = params.docSource or "api" -- 4082
			local ____temp_165 = shared.useChineseResponse and "zh" or "en" -- 4083
			local ____temp_166 = params.programmingLanguage or "ts" -- 4084
			local ____math_min_162 = math.min -- 4085
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4085
			local ____math_max_160 = math.max -- 4085
			local ____params_limit_159 = params.limit -- 4085
			if ____params_limit_159 == nil then -- 4085
				____params_limit_159 = 8 -- 4085
			end -- 4085
			local result = __TS__Await(____Tools_searchDoraAPI_167({ -- 4080
				pattern = ____temp_163, -- 4081
				docSource = ____temp_164, -- 4082
				docLanguage = ____temp_165, -- 4083
				programmingLanguage = ____temp_166, -- 4084
				limit = ____math_min_162( -- 4085
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161, -- 4085
					____math_max_160( -- 4085
						1, -- 4085
						__TS__Number(____params_limit_159) -- 4085
					) -- 4085
				), -- 4085
				useRegex = params.useRegex, -- 4086
				caseSensitive = false, -- 4087
				includeContent = true, -- 4088
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4089
			})) -- 4089
			return ____awaiter_resolve(nil, result) -- 4089
		end -- 4089
		if action.tool == "glob_files" then -- 4089
			local ____Tools_listFiles_174 = Tools.listFiles -- 4094
			local ____shared_workingDir_171 = shared.workingDir -- 4095
			local ____temp_172 = params.path or "" -- 4096
			local ____params_globs_173 = params.globs -- 4097
			local ____math_max_170 = math.max -- 4098
			local ____math_floor_169 = math.floor -- 4098
			local ____params_maxEntries_168 = params.maxEntries -- 4098
			if ____params_maxEntries_168 == nil then -- 4098
				____params_maxEntries_168 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4098
			end -- 4098
			local result = ____Tools_listFiles_174({ -- 4094
				workDir = ____shared_workingDir_171, -- 4095
				path = ____temp_172, -- 4096
				globs = ____params_globs_173, -- 4097
				maxEntries = ____math_max_170( -- 4098
					1, -- 4098
					____math_floor_169(__TS__Number(____params_maxEntries_168)) -- 4098
				) -- 4098
			}) -- 4098
			return ____awaiter_resolve(nil, result) -- 4098
		end -- 4098
		if action.tool == "ask_user" then -- 4098
			if not shared.publishQuestionnaire then -- 4098
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4098
			end -- 4098
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4098
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4098
			end -- 4098
			local normalized = normalizeQuestionnaire(params) -- 4105
			if not normalized.success then -- 4105
				return ____awaiter_resolve(nil, normalized) -- 4105
			end -- 4105
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4107
			if not result.success then -- 4107
				return ____awaiter_resolve(nil, result) -- 4107
			end -- 4107
			shared.waitingQuestionnaireId = result.questionnaireId -- 4114
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4114
		end -- 4114
		if action.tool == "delete_file" then -- 4114
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4118
			if __TS__StringTrim(targetFile) == "" then -- 4118
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4118
			end -- 4118
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4122
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4123
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4123
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4123
			end -- 4123
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4127
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4128
			if not result.success then -- 4128
				return ____awaiter_resolve(nil, result) -- 4128
			end -- 4128
			if not isInternalDocumentEdit then -- 4128
				shared.unbuiltEdits = true -- 4136
				shared.lastBuildSucceeded = false -- 4137
				if shared.failedTestNeedsBuild == true then -- 4137
					shared.failedTestHasSourceEdit = true -- 4138
				end -- 4138
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4138
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4139
				end -- 4139
				shared.editedPathsSinceBuild = editedPaths -- 4140
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4141
			end -- 4141
			return ____awaiter_resolve(nil, { -- 4141
				success = true, -- 4144
				changed = true, -- 4145
				mode = "delete", -- 4146
				checkpointId = result.checkpointId, -- 4147
				checkpointSeq = result.checkpointSeq, -- 4148
				files = {{path = targetFile, op = "delete"}} -- 4149
			}) -- 4149
		end -- 4149
		if action.tool == "build" then -- 4149
			local buildPath = params.path or "" -- 4153
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4154
			shared.unbuiltEdits = false -- 4158
			shared.editsSinceBuild = 0 -- 4159
			shared.editedPathsSinceBuild = {} -- 4160
			shared.hasBuilt = true -- 4161
			shared.lastBuildSucceeded = result.success -- 4162
			if result.success and shared.freshProjectBuildPending == true then -- 4162
				shared.freshProjectBuildPending = false -- 4168
			end -- 4168
			shared.apiSearchesSinceBuild = 0 -- 4170
			shared.buildRepairPending = false -- 4171
			if not result.success and result.messages ~= nil then -- 4171
				do -- 4171
					local i = 0 -- 4173
					while i < #result.messages do -- 4173
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4173
							shared.buildRepairPending = true -- 4175
							break -- 4176
						end -- 4176
						i = i + 1 -- 4173
					end -- 4173
				end -- 4173
			end -- 4173
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4173
				shared.failedTestNeedsBuild = false -- 4181
				shared.failedTestHasSourceEdit = false -- 4182
			end -- 4182
			return ____awaiter_resolve(nil, result) -- 4182
		end -- 4182
		if action.tool == "fetch_url" then -- 4182
			local result = __TS__Await(Tools.fetchUrl({ -- 4187
				workDir = shared.workingDir, -- 4188
				url = type(params.url) == "string" and params.url or "", -- 4189
				target = type(params.target) == "string" and params.target or "", -- 4190
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4191
				onProgress = function(____, progress) -- 4192
					emitAgentEvent( -- 4193
						shared, -- 4193
						{ -- 4193
							type = "tool_progress", -- 4194
							sessionId = shared.sessionId, -- 4195
							taskId = shared.taskId, -- 4196
							step = action.step, -- 4197
							tool = action.tool, -- 4198
							result = __TS__ObjectAssign({success = false}, progress) -- 4199
						} -- 4199
					) -- 4199
				end -- 4192
			})) -- 4192
			return ____awaiter_resolve(nil, result) -- 4192
		end -- 4192
		if action.tool == "execute_command" then -- 4192
			local mode = type(params.mode) == "string" and params.mode or "" -- 4209
			local result = __TS__Await(Tools.executeCommand({ -- 4210
				workDir = shared.workingDir, -- 4211
				mode = mode, -- 4212
				code = type(params.code) == "string" and params.code or nil, -- 4213
				command = type(params.command) == "string" and params.command or nil, -- 4214
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4215
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4216
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4217
				onProgress = function(____, progress) -- 4218
					emitAgentEvent( -- 4219
						shared, -- 4219
						{ -- 4219
							type = "tool_progress", -- 4220
							sessionId = shared.sessionId, -- 4221
							taskId = shared.taskId, -- 4222
							step = action.step, -- 4223
							tool = action.tool, -- 4224
							result = __TS__ObjectAssign({success = false}, progress) -- 4225
						} -- 4225
					) -- 4225
				end -- 4218
			})) -- 4218
			if result.success and mode == "lua" then -- 4218
				local deterministicFailure = false -- 4233
				local deterministicPass = false -- 4234
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4235
				do -- 4235
					local i = 0 -- 4236
					while i < #outputLines and not deterministicFailure do -- 4236
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4237
						if line == "passed" then -- 4237
							deterministicPass = true -- 4238
						end -- 4238
						if line == "failed" then -- 4238
							deterministicFailure = true -- 4240
							break -- 4241
						end -- 4241
						local searchFrom = 0 -- 4243
						while searchFrom < #line do -- 4243
							local failedIndex = (string.find( -- 4245
								line, -- 4245
								"failed", -- 4245
								math.max(searchFrom + 1, 1), -- 4245
								true -- 4245
							) or 0) - 1 -- 4245
							if failedIndex < 0 then -- 4245
								break -- 4246
							end -- 4246
							local after = failedIndex + #"failed" -- 4247
							while after < #line do -- 4247
								local ch = __TS__StringSlice(line, after, after + 1) -- 4249
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4249
									break -- 4250
								end -- 4250
								after = after + 1 -- 4251
							end -- 4251
							local afterEnd = after -- 4253
							while afterEnd < #line do -- 4253
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4255
								if ch < "0" or ch > "9" then -- 4255
									break -- 4256
								end -- 4256
								afterEnd = afterEnd + 1 -- 4257
							end -- 4257
							local count -- 4259
							if afterEnd > after then -- 4259
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4261
							else -- 4261
								local before = failedIndex - 1 -- 4263
								while before >= 0 do -- 4263
									local ch = __TS__StringSlice(line, before, before + 1) -- 4265
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4265
										break -- 4266
									end -- 4266
									before = before - 1 -- 4267
								end -- 4267
								local beforeEnd = before + 1 -- 4269
								while before >= 0 do -- 4269
									local ch = __TS__StringSlice(line, before, before + 1) -- 4271
									if ch < "0" or ch > "9" then -- 4271
										break -- 4272
									end -- 4272
									before = before - 1 -- 4273
								end -- 4273
								if beforeEnd > before + 1 then -- 4273
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4275
								end -- 4275
							end -- 4275
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4275
								deterministicFailure = true -- 4278
								break -- 4279
							end -- 4279
							searchFrom = failedIndex + #"failed" -- 4281
						end -- 4281
						i = i + 1 -- 4236
					end -- 4236
				end -- 4236
				if deterministicFailure then -- 4236
					shared.failedTestNeedsBuild = true -- 4285
					shared.failedTestHasSourceEdit = false -- 4286
				elseif deterministicPass then -- 4286
					shared.failedTestNeedsBuild = false -- 4288
					shared.failedTestHasSourceEdit = false -- 4289
				end -- 4289
			end -- 4289
			return ____awaiter_resolve(nil, result) -- 4289
		end -- 4289
		if action.tool == "spawn_sub_agent" then -- 4289
			if not shared.spawnSubAgent then -- 4289
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4289
			end -- 4289
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4289
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4289
			end -- 4289
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4301
				params.filesHint, -- 4302
				function(____, item) return type(item) == "string" end -- 4302
			) or nil -- 4302
			local result = __TS__Await(shared.spawnSubAgent({ -- 4304
				parentSessionId = shared.sessionId, -- 4305
				projectRoot = shared.workingDir, -- 4306
				title = type(params.title) == "string" and params.title or "Sub", -- 4307
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4308
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4309
				filesHint = filesHint, -- 4310
				disabledAgentTools = shared.disabledAgentTools -- 4311
			})) -- 4311
			if not result.success then -- 4311
				return ____awaiter_resolve(nil, result) -- 4311
			end -- 4311
			shared.hasSpawnedSubAgentThisTask = true -- 4316
			return ____awaiter_resolve(nil, { -- 4316
				success = true, -- 4318
				sessionId = result.sessionId, -- 4319
				taskId = result.taskId, -- 4320
				title = result.title, -- 4321
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4322
			}) -- 4322
		end -- 4322
		if action.tool == "list_sub_agents" then -- 4322
			if not shared.listSubAgents then -- 4322
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4322
			end -- 4322
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4322
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4322
			end -- 4322
			local result = __TS__Await(shared.listSubAgents({ -- 4332
				sessionId = shared.sessionId, -- 4333
				projectRoot = shared.workingDir, -- 4334
				status = type(params.status) == "string" and params.status or nil, -- 4335
				limit = type(params.limit) == "number" and params.limit or nil, -- 4336
				offset = type(params.offset) == "number" and params.offset or nil, -- 4337
				query = type(params.query) == "string" and params.query or nil -- 4338
			})) -- 4338
			return ____awaiter_resolve(nil, result) -- 4338
		end -- 4338
		if action.tool == "edit_file" then -- 4338
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4343
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4346
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4347
			if __TS__StringTrim(path) == "" then -- 4347
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4347
			end -- 4347
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4349
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4350
			if not isInternalDocumentEdit then -- 4350
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4352
				if preflightIssue ~= nil then -- 4352
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4354
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4355
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4355
				end -- 4355
			end -- 4355
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4361
			local result = __TS__Await(actionNode:exec({ -- 4362
				path = path, -- 4363
				oldStr = oldStr, -- 4364
				newStr = newStr, -- 4365
				taskId = shared.taskId, -- 4366
				workDir = shared.workingDir -- 4367
			})) -- 4367
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4367
				if params.partialStreamRecovery ~= true then -- 4367
					shared.truncatedToolOverwritePath = nil -- 4371
				end -- 4371
				shared.unbuiltEdits = true -- 4373
				shared.lastBuildSucceeded = false -- 4374
				if shared.failedTestNeedsBuild == true then -- 4374
					shared.failedTestHasSourceEdit = true -- 4375
				end -- 4375
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4376
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4376
					editedPaths[#editedPaths + 1] = normalizedPath -- 4377
				end -- 4377
				shared.editedPathsSinceBuild = editedPaths -- 4378
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4379
			end -- 4379
			return ____awaiter_resolve(nil, result) -- 4379
		end -- 4379
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4379
	end) -- 4379
end -- 4379
function sanitizeToolActionResultForHistory(action, result) -- 4386
	if action.tool == "read_file" then -- 4386
		return sanitizeReadResultForHistory(action.tool, result) -- 4388
	end -- 4388
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4388
		return sanitizeSearchResultForHistory(action.tool, result) -- 4391
	end -- 4391
	if action.tool == "glob_files" then -- 4391
		return sanitizeListFilesResultForHistory(result) -- 4394
	end -- 4394
	if action.tool == "build" then -- 4394
		return sanitizeBuildResultForHistory(result) -- 4397
	end -- 4397
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4397
		if result.success ~= true then -- 4397
			return result -- 4400
		end -- 4400
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4400
			return result -- 4401
		end -- 4401
		if isArray(result.fileContext) then -- 4401
			return result -- 4402
		end -- 4402
		local contextLimits = { -- 4404
			fullContentChars = 12000, -- 4405
			previewChars = 4000, -- 4406
			diffChars = 8000, -- 4407
			totalChars = 24000, -- 4408
			maxFiles = 8 -- 4409
		} -- 4409
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4411
			if maxChars <= 0 then -- 4411
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4412
			end -- 4412
			if #sourceText <= maxChars then -- 4412
				return sourceText -- 4413
			end -- 4413
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4414
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4415
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4416
		end -- 4411
		local function countLines(sourceText) -- 4418
			if sourceText == "" then -- 4418
				return 0 -- 4419
			end -- 4419
			return #__TS__StringSplit(sourceText, "\n") -- 4420
		end -- 4418
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4422
			if beforeContent == afterContent then -- 4422
				return "" -- 4423
			end -- 4423
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4424
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4425
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4427
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4427
				firstChangedLine = firstChangedLine + 1 -- 4433
			end -- 4433
			local lastChangedBeforeLine = #beforeLines - 1 -- 4435
			local lastChangedAfterLine = #afterLines - 1 -- 4436
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4436
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4442
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4443
			end -- 4443
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4445
			local previewEndLine = math.max( -- 4446
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4447
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4448
			) -- 4448
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4450
			do -- 4450
				local lineIndex = previewStartLine -- 4451
				while lineIndex <= previewEndLine do -- 4451
					do -- 4451
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4452
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4453
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4454
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4455
						if not beforeChanged and not afterChanged then -- 4455
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4457
							if contextLine ~= nil then -- 4457
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4458
							end -- 4458
							goto __continue733 -- 4459
						end -- 4459
						if beforeChanged and beforeLine ~= nil then -- 4459
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4461
						end -- 4461
						if afterChanged and afterLine ~= nil then -- 4461
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4462
						end -- 4462
					end -- 4462
					::__continue733:: -- 4462
					lineIndex = lineIndex + 1 -- 4451
				end -- 4451
			end -- 4451
			return truncateContextSnippet( -- 4464
				table.concat(unifiedDiffLines, "\n"), -- 4464
				maxChars, -- 4464
				"diff" -- 4464
			) -- 4464
		end -- 4422
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4467
		if not checkpointDiff.success then -- 4467
			return result -- 4468
		end -- 4468
		local remainingContextBudget = contextLimits.totalChars -- 4469
		local fileContextItems = {} -- 4470
		local changedFiles = checkpointDiff.files -- 4471
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4472
		do -- 4472
			local fileIndex = 0 -- 4473
			while fileIndex < maxContextFiles do -- 4473
				if remainingContextBudget <= 0 then -- 4473
					break -- 4474
				end -- 4474
				local changedFile = changedFiles[fileIndex + 1] -- 4475
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4476
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4477
				local contextItem = { -- 4478
					path = changedFile.path, -- 4479
					op = changedFile.op, -- 4480
					checkpointId = result.checkpointId, -- 4481
					checkpointSeq = result.checkpointSeq, -- 4482
					beforeExists = changedFile.beforeExists, -- 4483
					afterExists = changedFile.afterExists, -- 4484
					beforeBytes = #beforeContent, -- 4485
					afterBytes = #afterContent, -- 4486
					diffPreview = "", -- 4487
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4488
					contentTruncated = false, -- 4489
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4490
				} -- 4490
				if changedFile.afterExists then -- 4490
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4490
						contextItem.afterContent = afterContent -- 4494
						remainingContextBudget = remainingContextBudget - #afterContent -- 4495
					else -- 4495
						contextItem.afterContentPreview = truncateContextSnippet( -- 4497
							afterContent, -- 4498
							math.min( -- 4499
								contextLimits.previewChars, -- 4499
								math.max(400, remainingContextBudget) -- 4499
							), -- 4499
							"afterContent" -- 4500
						) -- 4500
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4502
						contextItem.contentTruncated = true -- 4503
					end -- 4503
				end -- 4503
				local diffPreview = buildUnifiedDiffPreview( -- 4506
					changedFile.path, -- 4507
					beforeContent, -- 4508
					afterContent, -- 4509
					math.min( -- 4510
						contextLimits.diffChars, -- 4510
						math.max(400, remainingContextBudget) -- 4510
					) -- 4510
				) -- 4510
				contextItem.diffPreview = diffPreview -- 4512
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4513
				if not changedFile.afterExists and beforeContent ~= "" then -- 4513
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4515
						beforeContent, -- 4516
						math.min( -- 4517
							contextLimits.previewChars, -- 4517
							math.max(400, remainingContextBudget) -- 4517
						), -- 4517
						"beforeContent" -- 4518
					) -- 4518
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4520
					if #beforeContent > contextLimits.previewChars then -- 4520
						contextItem.contentTruncated = true -- 4521
					end -- 4521
				end -- 4521
				fileContextItems[#fileContextItems + 1] = contextItem -- 4523
				fileIndex = fileIndex + 1 -- 4473
			end -- 4473
		end -- 4473
		if #fileContextItems == 0 then -- 4473
			return result -- 4525
		end -- 4525
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4526
	end -- 4526
	return result -- 4533
end -- 4533
function emitAgentTaskFinishEvent(shared, success, message) -- 4734
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4735
	local result = success and ({ -- 4739
		success = true, -- 4741
		taskId = shared.taskId, -- 4742
		message = message, -- 4743
		steps = shared.step, -- 4744
		completion = completion -- 4745
	}) or ({ -- 4745
		success = false, -- 4748
		taskId = shared.taskId, -- 4749
		message = message, -- 4750
		steps = shared.step, -- 4751
		completion = completion -- 4752
	}) -- 4752
	emitAgentEvent(shared, { -- 4754
		type = "task_finished", -- 4755
		sessionId = shared.sessionId, -- 4756
		taskId = shared.taskId, -- 4757
		success = result.success, -- 4758
		message = result.message, -- 4759
		steps = result.steps, -- 4760
		completion = result.completion -- 4761
	}) -- 4761
	return result -- 4763
end -- 4763
local function buildLLMOptions(llmConfig, overrides) -- 301
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 302
	if llmConfig.reasoningEffort then -- 302
		options.reasoning_effort = llmConfig.reasoningEffort -- 307
	end -- 307
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 309
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 309
		__TS__Delete(merged, "reasoning_effort") -- 314
	else -- 314
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 316
	end -- 316
	__TS__Delete(merged, "tool_choice") -- 321
	return merged -- 322
end -- 301
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 453
	local fitted = AgentUtils.fitMessagesToContext(messages, options, shared.llmConfig) -- 460
	local messagesTokens = fitted.originalTokens -- 461
	local toolDefinitionsTokens = 0 -- 463
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 463
		local toolsText = AgentUtils.safeJsonEncode(options.tools) -- 465
		toolDefinitionsTokens = toolsText and AgentUtils.estimateTextTokens(toolsText) or 0 -- 466
	end -- 466
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 469
	__TS__Delete(optionsWithoutTools, "tools") -- 470
	local optionsText = AgentUtils.safeJsonEncode(optionsWithoutTools) -- 471
	local optionsTokens = optionsText and AgentUtils.estimateTextTokens(optionsText) or 0 -- 472
	local contextWindow = shared.llmConfig.contextWindow > 0 and math.floor(shared.llmConfig.contextWindow) or 64000 -- 473
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 476
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 481
		1024, -- 483
		math.floor(contextWindow * 0.2) -- 483
	) -- 483
	local structuralOverhead = math.max(256, #messages * 16) -- 484
	local usedTokens = messagesTokens + math.max(0, contextWindow - fitted.budgetTokens) -- 488
	local maxTokens = contextWindow -- 489
	emitAgentEvent( -- 490
		shared, -- 490
		{ -- 490
			type = "metrics_updated", -- 491
			sessionId = shared.sessionId, -- 492
			taskId = shared.taskId, -- 493
			step = step, -- 494
			metrics = {context = { -- 495
				usedTokens = usedTokens, -- 497
				maxTokens = maxTokens, -- 498
				ratio = math.max( -- 499
					0, -- 499
					math.min(1, usedTokens / maxTokens) -- 499
				), -- 499
				messagesTokens = messagesTokens, -- 500
				optionsTokens = optionsTokens, -- 501
				toolDefinitionsTokens = toolDefinitionsTokens, -- 502
				reservedOutputTokens = reservedOutputTokens, -- 503
				structuralOverhead = structuralOverhead, -- 504
				contextWindow = contextWindow, -- 505
				source = "llm_input_estimate", -- 506
				updatedAt = os.time(), -- 507
				phase = phase, -- 508
				step = step -- 509
			}} -- 509
		} -- 509
	) -- 509
end -- 453
local function recordLLMTokenUsage(shared, step, phase, usage) -- 515
	if not usage then -- 515
		return -- 516
	end -- 516
	local current = shared.tokenUsage -- 517
	local cachedReported = usage.cachedInputTokens ~= nil -- 518
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 519
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 520
	local next = { -- 521
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 522
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 523
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 524
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 525
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 528
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 531
		requestCount = (current and current.requestCount or 0) + 1, -- 534
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 535
		model = shared.llmConfig.model, -- 538
		phase = phase, -- 539
		step = step, -- 540
		updatedAt = os.time() -- 541
	} -- 541
	shared.tokenUsage = next -- 543
	emitAgentEvent(shared, { -- 544
		type = "metrics_updated", -- 545
		sessionId = shared.sessionId, -- 546
		taskId = shared.taskId, -- 547
		step = step, -- 548
		metrics = {usage = next} -- 549
	}) -- 549
end -- 515
local function emitAgentStartEvent(shared, action) -- 553
	emitAgentEvent(shared, { -- 554
		type = "tool_started", -- 555
		sessionId = shared.sessionId, -- 556
		taskId = shared.taskId, -- 557
		step = action.step, -- 558
		tool = action.tool -- 559
	}) -- 559
end -- 553
local function emitAgentFinishEvent(shared, action) -- 563
	emitAgentEvent(shared, { -- 564
		type = "tool_finished", -- 565
		sessionId = shared.sessionId, -- 566
		taskId = shared.taskId, -- 567
		step = action.step, -- 568
		tool = action.tool, -- 569
		result = action.result or ({}) -- 570
	}) -- 570
end -- 563
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 574
	emitAgentEvent(shared, { -- 575
		type = "assistant_message_updated", -- 576
		sessionId = shared.sessionId, -- 577
		taskId = shared.taskId, -- 578
		step = shared.step + 1, -- 579
		content = content, -- 580
		reasoningContent = reasoningContent -- 581
	}) -- 581
end -- 574
local function getMemoryCompressionStartReason(shared) -- 585
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 586
end -- 585
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 591
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 592
end -- 591
local function getMemoryCompressionFailureReason(shared, ____error) -- 597
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 598
end -- 597
local function summarizeHistoryEntryPreview(text, maxChars) -- 603
	if maxChars == nil then -- 603
		maxChars = 180 -- 603
	end -- 603
	local trimmed = __TS__StringTrim(text) -- 604
	if trimmed == "" then -- 604
		return "" -- 605
	end -- 605
	return truncateText(trimmed, maxChars) -- 606
end -- 603
local function getMaxStepsReachedReason(shared) -- 614
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 615
end -- 614
local function getFailureSummaryFallback(shared, ____error) -- 620
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 621
end -- 620
local function finalizeAgentFailure(shared, ____error) -- 626
	if shared.stopToken.stopped then -- 626
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 628
		return emitAgentTaskFinishEvent( -- 629
			shared, -- 629
			false, -- 629
			getCancelledReason(shared) -- 629
		) -- 629
	end -- 629
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 631
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 632
end -- 626
local function getPromptCommand(prompt) -- 635
	local trimmed = __TS__StringTrim(prompt) -- 636
	if trimmed == "/compact" then -- 636
		return "compact" -- 637
	end -- 637
	if trimmed == "/clear" then -- 637
		return "clear" -- 638
	end -- 638
	return nil -- 639
end -- 635
function ____exports.truncateAgentUserPrompt(prompt) -- 642
	if not prompt then -- 642
		return "" -- 643
	end -- 643
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 643
		return prompt -- 644
	end -- 644
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 645
	if offset == nil then -- 645
		return prompt -- 646
	end -- 646
	return string.sub(prompt, 1, offset - 1) -- 647
end -- 642
local function canWriteStepLLMDebug(shared, stepId) -- 650
	if stepId == nil then -- 650
		stepId = shared.step + 1 -- 650
	end -- 650
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 651
end -- 650
local function ensureDirRecursive(dir) -- 658
	if not dir then -- 658
		return false -- 659
	end -- 659
	if Content:exist(dir) then -- 659
		return Content:isdir(dir) -- 660
	end -- 660
	local parent = Path:getPath(dir) -- 661
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 661
		return false -- 663
	end -- 663
	return Content:mkdir(dir) -- 665
end -- 658
local function encodeDebugJSON(value) -- 668
	local text, err = AgentUtils.safeJsonEncode(value) -- 669
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 670
end -- 668
function ____exports.isAgentPlanPath(path) -- 686
	return AgentRuntimePolicy.isAgentPlanPath(path) -- 687
end -- 686
local function inspectFreshProject(workDir) -- 690
	local result = Tools.listFiles({workDir = workDir, path = "", globs = AgentConfig.AGENT_FILE_PATTERNS.freshProjectCodeGlobs, maxEntries = 2}) -- 691
	if not result.success then -- 691
		return {fresh = false} -- 697
	end -- 697
	local totalEntries = result.totalEntries or #result.files -- 698
	if totalEntries > 1 then -- 698
		return {fresh = false} -- 699
	end -- 699
	if totalEntries == 0 then -- 699
		return {fresh = true} -- 700
	end -- 700
	if #result.files ~= 1 then -- 700
		return {fresh = false} -- 701
	end -- 701
	local path = result.files[1] -- 702
	local loaded = Tools.readFileRaw(workDir, path) -- 703
	if not loaded.success or loaded.content == nil then -- 703
		return {fresh = false} -- 704
	end -- 704
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 705
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 708
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 709
end -- 690
local function getStepLLMDebugDir(shared) -- 712
	return Path( -- 713
		shared.workingDir, -- 714
		".agent", -- 715
		tostring(shared.sessionId), -- 716
		tostring(shared.taskId) -- 717
	) -- 717
end -- 712
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 721
	return Path( -- 722
		getStepLLMDebugDir(shared), -- 722
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 722
	) -- 722
end -- 721
local function getLatestStepLLMDebugSeq(shared, stepId) -- 725
	if not canWriteStepLLMDebug(shared, stepId) then -- 725
		return 0 -- 726
	end -- 726
	local dir = getStepLLMDebugDir(shared) -- 727
	if not Content:exist(dir) or not Content:isdir(dir) then -- 727
		return 0 -- 728
	end -- 728
	local latest = 0 -- 729
	for ____, file in ipairs(Content:getFiles(dir)) do -- 730
		do -- 730
			local name = Path:getFilename(file) -- 731
			local seqText = string.match( -- 732
				name, -- 732
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 732
			) -- 732
			if seqText ~= nil then -- 732
				latest = math.max( -- 734
					latest, -- 734
					tonumber(seqText) -- 734
				) -- 734
				goto __continue57 -- 735
			end -- 735
			local legacyMatch = string.match( -- 737
				name, -- 737
				("^" .. tostring(stepId)) .. "_in%.md$" -- 737
			) -- 737
			if legacyMatch ~= nil then -- 737
				latest = math.max(latest, 1) -- 739
			end -- 739
		end -- 739
		::__continue57:: -- 739
	end -- 739
	return latest -- 742
end -- 725
local function writeStepLLMDebugFile(path, content) -- 745
	if not Content:save(path, content) then -- 745
		AgentUtils.Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 747
		return false -- 748
	end -- 748
	return true -- 750
end -- 745
local function createStepLLMDebugPair(shared, stepId, inContent) -- 753
	if not canWriteStepLLMDebug(shared, stepId) then -- 753
		return 0 -- 754
	end -- 754
	local dir = getStepLLMDebugDir(shared) -- 755
	if not ensureDirRecursive(dir) then -- 755
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 757
		return 0 -- 758
	end -- 758
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 760
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 761
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 762
	if not writeStepLLMDebugFile(inPath, inContent) then -- 762
		return 0 -- 764
	end -- 764
	writeStepLLMDebugFile(outPath, "") -- 766
	return seq -- 767
end -- 753
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 770
	if not canWriteStepLLMDebug(shared, stepId) then -- 770
		return -- 771
	end -- 771
	local dir = getStepLLMDebugDir(shared) -- 772
	if not ensureDirRecursive(dir) then -- 772
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 774
		return -- 775
	end -- 775
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 777
	if latestSeq <= 0 then -- 777
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 779
		writeStepLLMDebugFile(outPath, content) -- 780
		return -- 781
	end -- 781
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 783
	writeStepLLMDebugFile(outPath, content) -- 784
end -- 770
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 787
	if not canWriteStepLLMDebug(shared, stepId) then -- 787
		return -- 788
	end -- 788
	local sections = { -- 789
		"# LLM Input", -- 790
		"session_id: " .. tostring(shared.sessionId), -- 791
		"task_id: " .. tostring(shared.taskId), -- 792
		"step_id: " .. tostring(stepId), -- 793
		"phase: " .. phase, -- 794
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 795
		"## Options", -- 796
		"```json", -- 797
		encodeDebugJSON(options), -- 798
		"```" -- 799
	} -- 799
	local firstMessage = #messages > 0 and messages[1] or nil -- 801
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 801
		sections[#sections + 1] = "# System Prompt" -- 803
		sections[#sections + 1] = firstMessage.content -- 804
	end -- 804
	do -- 804
		local i = 0 -- 806
		while i < #messages do -- 806
			local message = messages[i + 1] -- 807
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 808
			sections[#sections + 1] = encodeDebugJSON(message) -- 809
			i = i + 1 -- 806
		end -- 806
	end -- 806
	createStepLLMDebugPair( -- 811
		shared, -- 811
		stepId, -- 811
		table.concat(sections, "\n") -- 811
	) -- 811
end -- 787
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 814
	if not canWriteStepLLMDebug(shared, stepId) then -- 814
		return -- 815
	end -- 815
	local ____array_24 = __TS__SparseArrayNew( -- 815
		"# LLM Output", -- 817
		"session_id: " .. tostring(shared.sessionId), -- 818
		"task_id: " .. tostring(shared.taskId), -- 819
		"step_id: " .. tostring(stepId), -- 820
		"phase: " .. phase, -- 821
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 822
		table.unpack(meta and ({ -- 823
			"## Meta", -- 823
			"```json", -- 823
			encodeDebugJSON(meta), -- 823
			"```" -- 823
		}) or ({})) -- 823
	) -- 823
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 823
	local sections = {__TS__SparseArraySpread(____array_24)} -- 816
	updateLatestStepLLMDebugOutput( -- 827
		shared, -- 827
		stepId, -- 827
		table.concat(sections, "\n") -- 827
	) -- 827
end -- 814
local function summarizeEditTextParamForHistory(value, key) -- 954
	if type(value) ~= "string" then -- 954
		return nil -- 955
	end -- 955
	local text = value -- 956
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 957
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 958
end -- 954
local function sanitizeActionParamsForHistory(tool, params) -- 1093
	if tool ~= "edit_file" then -- 1093
		return params -- 1094
	end -- 1094
	local clone = {} -- 1095
	for key in pairs(params) do -- 1096
		if key == "old_str" then -- 1096
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1098
		elseif key == "new_str" then -- 1098
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1100
		else -- 1100
			clone[key] = params[key] -- 1102
		end -- 1102
	end -- 1102
	return clone -- 1105
end -- 1093
local function projectMessagesForCompression(messages) -- 1257
	local projected = projectMessagesForLLMContext(messages) -- 1258
	do -- 1258
		local i = 0 -- 1259
		while i < #projected do -- 1259
			do -- 1259
				local message = projected[i + 1] -- 1260
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1260
					goto __continue189 -- 1261
				end -- 1261
				local changed = false -- 1262
				local toolCalls = __TS__ArrayMap( -- 1263
					message.tool_calls, -- 1263
					function(____, toolCall) -- 1263
						local fn = toolCall["function"] -- 1264
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1264
							return toolCall -- 1265
						end -- 1265
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 1266
						if not isRecord(decoded) or isArray(decoded) then -- 1266
							return toolCall -- 1267
						end -- 1267
						changed = true -- 1268
						return __TS__ObjectAssign( -- 1269
							{}, -- 1269
							toolCall, -- 1270
							{["function"] = __TS__ObjectAssign( -- 1269
								{}, -- 1271
								fn, -- 1272
								{arguments = toJson( -- 1271
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1273
									false -- 1273
								)} -- 1273
							)} -- 1273
						) -- 1273
					end -- 1263
				) -- 1263
				if changed then -- 1263
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1277
				end -- 1277
			end -- 1277
			::__continue189:: -- 1277
			i = i + 1 -- 1259
		end -- 1259
	end -- 1259
	return projected -- 1279
end -- 1257
local function getDecisionToolSchemaText(shared) -- 1321
	local toolsText = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1322
		shared.role, -- 1322
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1322
		{ -- 1322
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1323
			workMode = shared.workMode -- 1324
		} -- 1324
	)) -- 1324
	return toolsText or "" -- 1326
end -- 1321
local function clearPreExecutedResults(shared) -- 1336
	shared.preExecutedResults = nil -- 1337
end -- 1336
local function startPreExecutedToolAction(shared, action) -- 1340
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1340
		local ____hasReturned, ____returnValue -- 1340
		local ____try = __TS__AsyncAwaiter(function() -- 1340
			____hasReturned = true -- 1342
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1342
			return -- 1342
		end) -- 1342
		____try = ____try.catch( -- 1342
			____try, -- 1342
			function(____, err) -- 1342
				return __TS__AsyncAwaiter(function() -- 1342
					local message = tostring(err) -- 1344
					AgentUtils.Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1345
					____hasReturned = true -- 1346
					____returnValue = {success = false, message = message} -- 1346
					return -- 1346
				end) -- 1346
			end -- 1346
		) -- 1346
		__TS__Await(____try) -- 1341
		if ____hasReturned then -- 1341
			return ____awaiter_resolve(nil, ____returnValue) -- 1341
		end -- 1341
	end) -- 1341
end -- 1340
local function createPreExecutedToolResult(shared, action) -- 1350
	local cloneParamValue -- 1351
	cloneParamValue = function(value) -- 1351
		if value == nil then -- 1351
			return value -- 1352
		end -- 1352
		if isArray(value) then -- 1352
			return __TS__ArrayMap( -- 1354
				value, -- 1354
				function(____, item) return cloneParamValue(item) end -- 1354
			) -- 1354
		end -- 1354
		if type(value) == "table" then -- 1354
			local clone = {} -- 1357
			for key in pairs(value) do -- 1358
				clone[key] = cloneParamValue(value[key]) -- 1359
			end -- 1359
			return clone -- 1361
		end -- 1361
		return value -- 1363
	end -- 1351
	local params = cloneParamValue(action.params) -- 1365
	local areParamValuesEqual -- 1366
	areParamValuesEqual = function(left, right) -- 1366
		if left == right then -- 1366
			return true -- 1367
		end -- 1367
		if left == nil or right == nil then -- 1367
			return false -- 1368
		end -- 1368
		if isArray(left) or isArray(right) then -- 1368
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1368
				return false -- 1370
			end -- 1370
			do -- 1370
				local i = 0 -- 1371
				while i < #left do -- 1371
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1371
						return false -- 1372
					end -- 1372
					i = i + 1 -- 1371
				end -- 1371
			end -- 1371
			return true -- 1374
		end -- 1374
		if type(left) == "table" and type(right) == "table" then -- 1374
			local leftCount = 0 -- 1377
			for key in pairs(left) do -- 1378
				leftCount = leftCount + 1 -- 1379
				if not areParamValuesEqual(left[key], right[key]) then -- 1379
					return false -- 1384
				end -- 1384
			end -- 1384
			local rightCount = 0 -- 1387
			for key in pairs(right) do -- 1388
				rightCount = rightCount + 1 -- 1389
			end -- 1389
			return leftCount == rightCount -- 1391
		end -- 1391
		return false -- 1393
	end -- 1366
	return { -- 1395
		action = action, -- 1396
		matches = function(self, nextAction) -- 1397
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1398
		end, -- 1397
		promise = startPreExecutedToolAction(shared, action) -- 1400
	} -- 1400
end -- 1350
local function executeToolActionWithPreExecution(shared, action) -- 1404
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1404
		local wasResumeNarrowReadMode = shared.resumeNarrowReadMode == true -- 1405
		local ____opt_29 = shared.preExecutedResults -- 1405
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1406
		local result -- 1407
		if preResult then -- 1407
			local ____opt_31 = shared.preExecutedResults -- 1407
			if ____opt_31 ~= nil then -- 1407
				____opt_31:delete(action.toolCallId) -- 1409
			end -- 1409
			if preResult:matches(action) then -- 1409
				AgentUtils.Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1411
				result = __TS__Await(preResult.promise) -- 1412
			else -- 1412
				AgentUtils.Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1414
				result = __TS__Await(executeToolAction(shared, action)) -- 1415
			end -- 1415
		else -- 1415
			result = __TS__Await(executeToolAction(shared, action)) -- 1418
		end -- 1418
		local guidance = {} -- 1420
		if type(result.guidance) == "string" and __TS__StringTrim(result.guidance) ~= "" then -- 1420
			guidance[#guidance + 1] = result.guidance -- 1422
		end -- 1422
		guidance[#guidance + 1] = AgentToolRegistry.buildCurrentToolAvailabilityGuidance() -- 1424
		if shared.hasSpawnedSubAgentThisTask == true and (shared.delegatedForegroundBatches or 0) + 1 >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1424
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1431
		end -- 1431
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1431
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1434
		end -- 1434
		if shared.failedTestNeedsBuild == true then -- 1434
			if action.tool == "build" and result.success == true and shared.failedTestHasSourceEdit ~= true then -- 1434
				guidance[#guidance + 1] = "The build passed, but no authored source change has addressed the deterministic test failure. Make a narrow source fix before rebuilding or retesting." -- 1438
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1438
				guidance[#guidance + 1] = "Source changed after a deterministic test failure. Build the authored changes before running more tests." -- 1444
			elseif action.tool ~= "build" then -- 1444
				guidance[#guidance + 1] = "A deterministic test failure remains unresolved. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1446
			end -- 1446
		end -- 1446
		if action.tool == "search_dora_api" then -- 1446
			if shared.unbuiltEdits == true then -- 1446
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1451
			end -- 1451
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1451
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1454
			end -- 1454
		end -- 1454
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1454
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1462
		end -- 1462
		if action.tool == "edit_file" and wasResumeNarrowReadMode then -- 1462
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1465
			if oldStr == "" then -- 1465
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1467
			end -- 1467
		end -- 1467
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1467
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1471
		end -- 1471
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1471
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1474
		end -- 1474
		if shared.buildRepairPending == true then -- 1474
			if action.tool == "build" then -- 1474
				guidance[#guidance + 1] = "This build reported authored-file diagnostics. Make a narrow source repair before building again." -- 1480
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1480
				guidance[#guidance + 1] = "A source repair was applied after build diagnostics. Build again before broadening the investigation." -- 1486
			else -- 1486
				guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1488
			end -- 1488
		end -- 1488
		if action.tool == "build" and shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true and shared.failedTestNeedsBuild ~= true then -- 1488
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1497
		end -- 1497
		result.guidance = table.concat(guidance, "\n") -- 1499
		if action.tool ~= "build" and action.tool ~= "read_file" then -- 1499
			shared.resumeNarrowReadMode = false -- 1504
		end -- 1504
		return ____awaiter_resolve(nil, result) -- 1504
	end) -- 1504
end -- 1404
local function maybeCompressHistory(shared, includePendingUserPrompt, pendingUserPrompt) -- 1509
	if includePendingUserPrompt == nil then -- 1509
		includePendingUserPrompt = false -- 1511
	end -- 1511
	if pendingUserPrompt == nil then -- 1511
		pendingUserPrompt = "" -- 1512
	end -- 1512
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1512
		local ____shared_33 = shared -- 1514
		local memory = ____shared_33.memory -- 1514
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1515
		local changed = false -- 1516
		do -- 1516
			local round = 0 -- 1517
			while round < maxRounds do -- 1517
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1518
				local normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1519
				local decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages) -- 1520
				local activeMessages = projectMessagesForCompression(normalizedActiveMessages) -- 1521
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1524
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1532
				local triggerMessages = buildDecisionMessages( -- 1535
					shared, -- 1536
					nil, -- 1537
					1, -- 1538
					nil, -- 1539
					shared.decisionMode, -- 1540
					false, -- 1541
					includePendingUserPrompt and pendingUserPrompt or "" -- 1542
				) -- 1542
				local triggerOptions = shared.decisionMode == "tool_calling" and __TS__ObjectAssign( -- 1544
					{}, -- 1545
					shared.llmOptions, -- 1546
					__TS__StringIncludes( -- 1547
						string.lower(shared.llmConfig.model), -- 1547
						"glm-5.2" -- 1547
					) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") and ({reasoning_effort = "minimal"}) or ({}), -- 1547
					{tools = AgentToolRegistry.buildDecisionToolSchema( -- 1545
						shared.role, -- 1552
						AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1552
						{ -- 1552
							disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1553
							workMode = shared.workMode -- 1554
						} -- 1554
					)} -- 1554
				) or shared.llmOptions -- 1554
				local fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig) -- 1558
				local thresholdReached = getActiveRealMessageCount(shared) > 0 and fitted.originalTokens >= fitted.budgetTokens -- 1561
				if not thresholdReached then -- 1561
					if changed then -- 1561
						persistHistoryState(shared) -- 1565
					end -- 1565
					return ____awaiter_resolve(nil) -- 1565
				end -- 1565
				local compressionRound = round + 1 -- 1569
				AgentUtils.Log( -- 1570
					"Info", -- 1570
					(((("[Memory] Effective input budget reached tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " round=") .. tostring(compressionRound) -- 1570
				) -- 1570
				shared.step = shared.step + 1 -- 1571
				local stepId = shared.step -- 1572
				local pendingMessages = #activeMessages -- 1573
				emitAgentEvent( -- 1574
					shared, -- 1574
					{ -- 1574
						type = "memory_compression_started", -- 1575
						sessionId = shared.sessionId, -- 1576
						taskId = shared.taskId, -- 1577
						step = stepId, -- 1578
						tool = "compress_memory", -- 1579
						reason = getMemoryCompressionStartReason(shared), -- 1580
						params = { -- 1581
							round = compressionRound, -- 1582
							maxRounds = maxRounds, -- 1583
							pendingMessages = pendingMessages, -- 1584
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1585
							uncoveredMessages = #uncoveredMessages, -- 1586
							inputTokens = fitted.originalTokens, -- 1587
							inputBudgetTokens = fitted.budgetTokens -- 1588
						} -- 1588
					} -- 1588
				) -- 1588
				local result = __TS__Await(memory.compressor:compress( -- 1591
					activeMessages, -- 1592
					shared.llmOptions, -- 1593
					shared.llmMaxTry, -- 1594
					shared.decisionMode, -- 1595
					{ -- 1596
						onInput = function(____, phase, messages, options) -- 1597
							saveStepLLMDebugInput( -- 1598
								shared, -- 1598
								stepId, -- 1598
								phase, -- 1598
								messages, -- 1598
								options -- 1598
							) -- 1598
						end, -- 1597
						onOutput = function(____, phase, text, meta) -- 1600
							saveStepLLMDebugOutput( -- 1601
								shared, -- 1601
								stepId, -- 1601
								phase, -- 1601
								text, -- 1601
								meta -- 1601
							) -- 1601
						end, -- 1600
						onUsage = function(____, phase, usage) -- 1603
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1604
						end -- 1603
					}, -- 1603
					"default", -- 1607
					systemPrompt, -- 1608
					toolDefinitions, -- 1609
					decisionActiveMessages -- 1610
				)) -- 1610
				if not (result and result.success and result.compressedCount > 0) then -- 1610
					emitAgentEvent( -- 1613
						shared, -- 1613
						{ -- 1613
							type = "memory_compression_finished", -- 1614
							sessionId = shared.sessionId, -- 1615
							taskId = shared.taskId, -- 1616
							step = stepId, -- 1617
							tool = "compress_memory", -- 1618
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1619
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1623
						} -- 1623
					) -- 1623
					if changed then -- 1623
						persistHistoryState(shared) -- 1631
					end -- 1631
					return ____awaiter_resolve(nil) -- 1631
				end -- 1631
				local effectiveCompressedCount = math.max( -- 1635
					0, -- 1636
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1637
				) -- 1637
				if effectiveCompressedCount <= 0 then -- 1637
					if changed then -- 1637
						persistHistoryState(shared) -- 1641
					end -- 1641
					return ____awaiter_resolve(nil) -- 1641
				end -- 1641
				emitAgentEvent( -- 1645
					shared, -- 1645
					{ -- 1645
						type = "memory_compression_finished", -- 1646
						sessionId = shared.sessionId, -- 1647
						taskId = shared.taskId, -- 1648
						step = stepId, -- 1649
						tool = "compress_memory", -- 1650
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1651
						result = { -- 1652
							success = true, -- 1653
							round = compressionRound, -- 1654
							compressedCount = effectiveCompressedCount, -- 1655
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1656
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1657
						} -- 1657
					} -- 1657
				) -- 1657
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1660
				changed = true -- 1661
				AgentUtils.Log( -- 1662
					"Info", -- 1662
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1662
				) -- 1662
				round = round + 1 -- 1517
			end -- 1517
		end -- 1517
		if changed then -- 1517
			persistHistoryState(shared) -- 1665
		end -- 1665
	end) -- 1665
end -- 1509
local function compactAllHistory(shared) -- 1669
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1669
		local ____shared_40 = shared -- 1670
		local memory = ____shared_40.memory -- 1670
		local rounds = 0 -- 1671
		local totalCompressed = 0 -- 1672
		while getActiveRealMessageCount(shared) > 0 do -- 1672
			if shared.stopToken.stopped then -- 1672
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1675
				return ____awaiter_resolve( -- 1675
					nil, -- 1675
					emitAgentTaskFinishEvent( -- 1676
						shared, -- 1676
						false, -- 1676
						getCancelledReason(shared) -- 1676
					) -- 1676
				) -- 1676
			end -- 1676
			rounds = rounds + 1 -- 1678
			shared.step = shared.step + 1 -- 1679
			local stepId = shared.step -- 1680
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1681
			local pendingMessages = #activeMessages -- 1682
			emitAgentEvent( -- 1683
				shared, -- 1683
				{ -- 1683
					type = "memory_compression_started", -- 1684
					sessionId = shared.sessionId, -- 1685
					taskId = shared.taskId, -- 1686
					step = stepId, -- 1687
					tool = "compress_memory", -- 1688
					reason = getMemoryCompressionStartReason(shared), -- 1689
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1690
				} -- 1690
			) -- 1690
			local result = __TS__Await(memory.compressor:compress( -- 1697
				activeMessages, -- 1698
				shared.llmOptions, -- 1699
				shared.llmMaxTry, -- 1700
				shared.decisionMode, -- 1701
				{ -- 1702
					onInput = function(____, phase, messages, options) -- 1703
						saveStepLLMDebugInput( -- 1704
							shared, -- 1704
							stepId, -- 1704
							phase, -- 1704
							messages, -- 1704
							options -- 1704
						) -- 1704
					end, -- 1703
					onOutput = function(____, phase, text, meta) -- 1706
						saveStepLLMDebugOutput( -- 1707
							shared, -- 1707
							stepId, -- 1707
							phase, -- 1707
							text, -- 1707
							meta -- 1707
						) -- 1707
					end, -- 1706
					onUsage = function(____, phase, usage) -- 1709
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1710
					end -- 1709
				}, -- 1709
				"budget_max" -- 1713
			)) -- 1713
			if not (result and result.success and result.compressedCount > 0) then -- 1713
				emitAgentEvent( -- 1716
					shared, -- 1716
					{ -- 1716
						type = "memory_compression_finished", -- 1717
						sessionId = shared.sessionId, -- 1718
						taskId = shared.taskId, -- 1719
						step = stepId, -- 1720
						tool = "compress_memory", -- 1721
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1722
						result = { -- 1726
							success = false, -- 1727
							rounds = rounds, -- 1728
							error = result and result.error or "compression returned no changes", -- 1729
							compressedCount = result and result.compressedCount or 0, -- 1730
							fullCompaction = true -- 1731
						} -- 1731
					} -- 1731
				) -- 1731
				return ____awaiter_resolve( -- 1731
					nil, -- 1731
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1734
				) -- 1734
			end -- 1734
			local effectiveCompressedCount = math.max( -- 1739
				0, -- 1740
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1741
			) -- 1741
			if effectiveCompressedCount <= 0 then -- 1741
				return ____awaiter_resolve( -- 1741
					nil, -- 1741
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1744
				) -- 1744
			end -- 1744
			emitAgentEvent( -- 1751
				shared, -- 1751
				{ -- 1751
					type = "memory_compression_finished", -- 1752
					sessionId = shared.sessionId, -- 1753
					taskId = shared.taskId, -- 1754
					step = stepId, -- 1755
					tool = "compress_memory", -- 1756
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1757
					result = { -- 1758
						success = true, -- 1759
						round = rounds, -- 1760
						compressedCount = effectiveCompressedCount, -- 1761
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1762
						fullCompaction = true -- 1763
					} -- 1763
				} -- 1763
			) -- 1763
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1766
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1767
			persistHistoryState(shared) -- 1768
			AgentUtils.Log( -- 1769
				"Info", -- 1769
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1769
			) -- 1769
		end -- 1769
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1771
		return ____awaiter_resolve( -- 1771
			nil, -- 1771
			emitAgentTaskFinishEvent( -- 1772
				shared, -- 1773
				true, -- 1774
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1775
			) -- 1775
		) -- 1775
	end) -- 1775
end -- 1669
local function clearSessionHistory(shared) -- 1781
	shared.messages = {} -- 1782
	shared.lastConsolidatedIndex = 0 -- 1783
	shared.carryMessageIndex = nil -- 1784
	persistHistoryState(shared) -- 1785
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1786
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1787
end -- 1781
local function appendConversationMessage(shared, message) -- 1943
	local ____shared_messages_49 = shared.messages -- 1943
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1944
		{}, -- 1944
		message, -- 1945
		{ -- 1944
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1946
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1947
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1948
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1949
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1950
		} -- 1950
	) -- 1950
end -- 1943
local function appendToolResultMessage(shared, action) -- 1959
	appendConversationMessage( -- 1960
		shared, -- 1960
		{ -- 1960
			role = "tool", -- 1961
			tool_call_id = action.toolCallId, -- 1962
			name = action.tool, -- 1963
			content = action.result and toJson(action.result, false) or "" -- 1964
		} -- 1964
	) -- 1964
end -- 1959
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1968
	appendConversationMessage( -- 1974
		shared, -- 1974
		{ -- 1974
			role = "assistant", -- 1975
			content = content or "", -- 1976
			reasoning_content = reasoningContent, -- 1977
			tool_calls = __TS__ArrayMap( -- 1978
				actions, -- 1978
				function(____, action) return { -- 1978
					id = action.toolCallId, -- 1979
					type = "function", -- 1980
					["function"] = { -- 1981
						name = action.tool, -- 1982
						arguments = toJson(action.params, false) -- 1983
					} -- 1983
				} end -- 1983
			) -- 1983
		} -- 1983
	) -- 1983
end -- 1968
local function llm(shared, messages, phase) -- 2167
	if phase == nil then -- 2167
		phase = "decision_xml" -- 2170
	end -- 2170
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2170
		local stepId = shared.step + 1 -- 2172
		emitLLMContextMetrics( -- 2173
			shared, -- 2173
			stepId, -- 2173
			phase, -- 2173
			messages, -- 2173
			shared.llmOptions -- 2173
		) -- 2173
		saveStepLLMDebugInput( -- 2174
			shared, -- 2174
			stepId, -- 2174
			phase, -- 2174
			messages, -- 2174
			shared.llmOptions -- 2174
		) -- 2174
		local lastStreamReasoning = "" -- 2175
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2176
			messages, -- 2177
			shared.llmOptions, -- 2178
			shared.stopToken, -- 2179
			shared.llmConfig, -- 2180
			function(response) -- 2181
				local ____opt_53 = response.choices -- 2181
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2181
				local streamMessage = ____opt_51 and ____opt_51.message -- 2182
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2183
				if nextContent == "" then -- 2183
					return -- 2186
				end -- 2186
				if nextContent == lastStreamReasoning then -- 2186
					return -- 2187
				end -- 2187
				lastStreamReasoning = nextContent -- 2188
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2189
			end -- 2181
		)) -- 2181
		if res.success then -- 2181
			local usage = res.tokenUsage -- 2193
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2194
			local ____opt_59 = res.response.choices -- 2194
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2194
			local message = ____opt_57 and ____opt_57.message -- 2195
			local text = message and message.content -- 2196
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2197
			if text then -- 2197
				local parsed = tryParseAndValidateDecision(text, shared) -- 2201
				if parsed.success then -- 2201
					local reason = parsed.reason or "" -- 2203
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2204
				end -- 2204
				saveStepLLMDebugOutput( -- 2206
					shared, -- 2206
					stepId, -- 2206
					phase, -- 2206
					text, -- 2206
					{success = true, usage = usage} -- 2206
				) -- 2206
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2206
			else -- 2206
				saveStepLLMDebugOutput( -- 2209
					shared, -- 2209
					stepId, -- 2209
					phase, -- 2209
					"empty LLM response", -- 2209
					{success = false, usage = usage} -- 2209
				) -- 2209
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2209
			end -- 2209
		else -- 2209
			local usage = res.tokenUsage -- 2213
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2214
			saveStepLLMDebugOutput( -- 2215
				shared, -- 2215
				stepId, -- 2215
				phase, -- 2215
				res.raw or res.message, -- 2215
				{success = false, usage = usage} -- 2215
			) -- 2215
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2215
		end -- 2215
	end) -- 2215
end -- 2167
local function isDecisionBatchSuccess(result) -- 2239
	return result.kind == "batch" -- 2240
end -- 2239
local function parseDecisionToolCall(functionName, rawObj) -- 2264
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2264
		return {success = false, message = "unknown tool: " .. functionName} -- 2266
	end -- 2266
	if rawObj == nil then -- 2266
		return {success = true, tool = functionName, params = {}} -- 2269
	end -- 2269
	if not isRecord(rawObj) then -- 2269
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2272
	end -- 2272
	return {success = true, tool = functionName, params = rawObj} -- 2274
end -- 2264
local function parseToolCallArguments(functionName, argsText) -- 2281
	local trimmedArgs = __TS__StringTrim(argsText) -- 2282
	if trimmedArgs == "" then -- 2282
		return {} -- 2284
	end -- 2284
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2286
	if err ~= nil or rawObj == nil then -- 2286
		return { -- 2288
			success = false, -- 2289
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2290
			raw = argsText -- 2291
		} -- 2291
	end -- 2291
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2294
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2294
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2296
	end -- 2296
	return rawObj -- 2302
end -- 2281
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2305
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2313
	if isRecord(rawArgs) and rawArgs.success == false then -- 2313
		return rawArgs -- 2315
	end -- 2315
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2317
	if not decision.success then -- 2317
		return {success = false, message = decision.message, raw = argsText} -- 2319
	end -- 2319
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2325
	if not completionValidation.success then -- 2325
		return {success = false, message = completionValidation.message, raw = argsText} -- 2327
	end -- 2327
	local validation = validateDecision(decision.tool, decision.params) -- 2333
	if not validation.success then -- 2333
		return {success = false, message = validation.message, raw = argsText} -- 2335
	end -- 2335
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2341
	if not sharedValidation.success then -- 2341
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2343
	end -- 2343
	decision.params = validation.params -- 2349
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2350
	decision.reason = reason -- 2351
	decision.reasoningContent = reasoningContent -- 2352
	return decision -- 2353
end -- 2305
local function createPreExecutableActionFromStream(shared, toolCall) -- 2356
	local ____opt_65 = toolCall["function"] -- 2356
	local functionName = ____opt_65 and ____opt_65.name -- 2357
	local ____opt_67 = toolCall["function"] -- 2357
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2358
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2359
	if not functionName or not toolCallId then -- 2359
		return nil -- 2360
	end -- 2360
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2361
	if isRecord(rawArgs) and rawArgs.success == false then -- 2361
		return nil -- 2362
	end -- 2362
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2363
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2363
		return nil -- 2364
	end -- 2364
	local validation = validateDecision(decision.tool, decision.params) -- 2365
	if not validation.success then -- 2365
		return nil -- 2366
	end -- 2366
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2366
		return nil -- 2367
	end -- 2367
	return { -- 2368
		step = shared.step + 1, -- 2369
		toolCallId = toolCallId, -- 2370
		tool = decision.tool, -- 2371
		reason = "", -- 2372
		params = validation.params, -- 2373
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2374
	} -- 2374
end -- 2356
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2762
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2771
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2772
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2780
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2781
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2782
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2790
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2798
		shared.role, -- 2798
		{ -- 2798
			includeFinish = true, -- 2799
			includeXmlRules = true, -- 2800
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2801
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2802
			workMode = shared.workMode -- 2803
		} -- 2803
	) -- 2803
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2805
	local repairPrompt = replacePromptVars( -- 2808
		shared.promptPack.xmlDecisionRepairPrompt, -- 2808
		{ -- 2808
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2809
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2810
			CANDIDATE_SECTION = candidateSection, -- 2811
			LAST_ERROR = lastError, -- 2812
			ATTEMPT = tostring(attempt) -- 2813
		} -- 2813
	) -- 2813
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2815
end -- 2762
local MainDecisionAgent = __TS__Class() -- 2853
MainDecisionAgent.name = "MainDecisionAgent" -- 2853
__TS__ClassExtends(MainDecisionAgent, Node) -- 2853
function MainDecisionAgent.prototype.prep(self, shared) -- 2854
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2854
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2854
			return ____awaiter_resolve(nil, {shared = shared}) -- 2854
		end -- 2854
		__TS__Await(maybeCompressHistory(shared)) -- 2859
		return ____awaiter_resolve(nil, {shared = shared}) -- 2859
	end) -- 2859
end -- 2854
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2864
	local preExecuted = shared.preExecutedResults -- 2865
	if not preExecuted or preExecuted.size == 0 then -- 2865
		return nil -- 2866
	end -- 2866
	local decisions = {} -- 2867
	preExecuted:forEach(function(____, preResult) -- 2868
		local action = preResult.action -- 2869
		decisions[#decisions + 1] = { -- 2870
			success = true, -- 2871
			tool = action.tool, -- 2872
			params = action.params, -- 2873
			toolCallId = action.toolCallId, -- 2874
			reason = action.reason, -- 2875
			reasoningContent = action.reasoningContent -- 2876
		} -- 2876
	end) -- 2868
	if #decisions == 0 then -- 2868
		return nil -- 2879
	end -- 2879
	AgentUtils.Log( -- 2880
		"Warn", -- 2880
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2880
			__TS__ArrayMap( -- 2880
				decisions, -- 2880
				function(____, decision) return decision.tool end -- 2880
			), -- 2880
			"," -- 2880
		) -- 2880
	) -- 2880
	if #decisions == 1 then -- 2880
		return decisions[1] -- 2882
	end -- 2882
	return {success = true, kind = "batch", decisions = decisions} -- 2884
end -- 2864
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2891
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2896
	if not recovery then -- 2896
		return nil -- 2897
	end -- 2897
	shared.truncatedToolOverwritePath = recovery.target -- 2898
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2899
	return { -- 2900
		success = true, -- 2901
		tool = "edit_file", -- 2902
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2903
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2909
		reason = recovery.reason, -- 2910
		reasoningContent = reasoningContent -- 2911
	} -- 2911
end -- 2891
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2915
	if attempt == nil then -- 2915
		attempt = 1 -- 2918
	end -- 2918
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2918
		if shared.stopToken.stopped then -- 2918
			return ____awaiter_resolve( -- 2918
				nil, -- 2918
				{ -- 2922
					success = false, -- 2922
					message = getCancelledReason(shared) -- 2922
				} -- 2922
			) -- 2922
		end -- 2922
		AgentUtils.Log( -- 2924
			"Info", -- 2924
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2924
		) -- 2924
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2925
			shared.role, -- 2925
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2925
			{ -- 2925
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2926
				workMode = shared.workMode -- 2927
			} -- 2927
		) -- 2927
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2929
		local stepId = shared.step + 1 -- 2930
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2931
			string.lower(shared.llmConfig.model), -- 2931
			"glm-5.2" -- 2931
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2931
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2934
		emitLLMContextMetrics( -- 2939
			shared, -- 2939
			stepId, -- 2939
			"decision_tool_calling", -- 2939
			messages, -- 2939
			llmOptions -- 2939
		) -- 2939
		saveStepLLMDebugInput( -- 2940
			shared, -- 2940
			stepId, -- 2940
			"decision_tool_calling", -- 2940
			messages, -- 2940
			llmOptions -- 2940
		) -- 2940
		local lastStreamContent = "" -- 2941
		local lastStreamReasoning = "" -- 2942
		local preExecutedResults = __TS__New(Map) -- 2943
		shared.preExecutedResults = preExecutedResults -- 2944
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2945
			messages, -- 2946
			llmOptions, -- 2947
			shared.stopToken, -- 2948
			shared.llmConfig, -- 2949
			function(response) -- 2950
				local ____opt_75 = response.choices -- 2950
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2950
				local streamMessage = ____opt_73 and ____opt_73.message -- 2951
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2952
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2955
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2955
					return -- 2959
				end -- 2959
				lastStreamContent = nextContent -- 2961
				lastStreamReasoning = nextReasoning -- 2962
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2963
			end, -- 2950
			function(tc) -- 2965
				if shared.stopToken.stopped then -- 2965
					return -- 2966
				end -- 2966
				local action = createPreExecutableActionFromStream(shared, tc) -- 2967
				if not action or preExecutedResults:has(action.toolCallId) then -- 2967
					return -- 2968
				end -- 2968
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2969
				preExecutedResults:set( -- 2970
					action.toolCallId, -- 2970
					createPreExecutedToolResult(shared, action) -- 2970
				) -- 2970
			end -- 2965
		)) -- 2965
		if shared.stopToken.stopped then -- 2965
			clearPreExecutedResults(shared) -- 2974
			return ____awaiter_resolve( -- 2974
				nil, -- 2974
				{ -- 2975
					success = false, -- 2975
					message = getCancelledReason(shared) -- 2975
				} -- 2975
			) -- 2975
		end -- 2975
		if not res.success then -- 2975
			local usage = res.tokenUsage -- 2978
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2979
			saveStepLLMDebugOutput( -- 2980
				shared, -- 2980
				stepId, -- 2980
				"decision_tool_calling", -- 2980
				res.raw or res.message, -- 2980
				{success = false, usage = usage} -- 2980
			) -- 2980
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2981
			local committed = self:commitPreExecutedDecision(shared) -- 2982
			if committed then -- 2982
				return ____awaiter_resolve(nil, committed) -- 2982
			end -- 2982
			local ____opt_83 = res.response -- 2982
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2982
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2984
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 2985
			local ____shared_93 = shared -- 2986
			local ____opt_85 = partialChoice and partialChoice.message -- 2986
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 2987
			local ____opt_89 = partialChoice and partialChoice.message -- 2987
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 2985
			if partialDraft then -- 2985
				return ____awaiter_resolve(nil, partialDraft) -- 2985
			end -- 2985
			clearPreExecutedResults(shared) -- 2991
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2991
		end -- 2991
		local usage = res.tokenUsage -- 2994
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2995
		saveStepLLMDebugOutput( -- 2996
			shared, -- 2996
			stepId, -- 2996
			"decision_tool_calling", -- 2996
			encodeDebugJSON(res.response), -- 2996
			{success = true, usage = usage} -- 2996
		) -- 2996
		local choice = res.response.choices and res.response.choices[1] -- 2997
		local message = choice and choice.message -- 2998
		local toolCalls = message and message.tool_calls -- 2999
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3000
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3003
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3006
		AgentUtils.Log( -- 3009
			"Info", -- 3009
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3009
		) -- 3009
		if finishReason == "length" then -- 3009
			local committed = self:commitPreExecutedDecision(shared) -- 3011
			if committed then -- 3011
				return ____awaiter_resolve(nil, committed) -- 3011
			end -- 3011
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3013
			if partialDraft then -- 3013
				return ____awaiter_resolve(nil, partialDraft) -- 3013
			end -- 3013
			AgentUtils.Log( -- 3015
				"Error", -- 3015
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3015
			) -- 3015
			clearPreExecutedResults(shared) -- 3016
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3016
		end -- 3016
		if not toolCalls or #toolCalls == 0 then -- 3016
			if messageContent and messageContent ~= "" then -- 3016
				if isFinalDecisionTurn(shared) then -- 3016
					clearPreExecutedResults(shared) -- 3026
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3026
				end -- 3026
				if shared.role == "sub" then -- 3026
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3034
					clearPreExecutedResults(shared) -- 3035
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3035
				end -- 3035
				AgentUtils.Log( -- 3042
					"Info", -- 3042
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3042
				) -- 3042
				clearPreExecutedResults(shared) -- 3043
				return ____awaiter_resolve(nil, { -- 3043
					success = true, -- 3045
					tool = "finish", -- 3046
					params = {}, -- 3047
					reason = messageContent, -- 3048
					reasoningContent = reasoningContent, -- 3049
					directSummary = messageContent -- 3050
				}) -- 3050
			end -- 3050
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3053
			clearPreExecutedResults(shared) -- 3054
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3054
		end -- 3054
		local decisions = {} -- 3061
		do -- 3061
			local i = 0 -- 3062
			while i < #toolCalls do -- 3062
				local toolCall = toolCalls[i + 1] -- 3063
				local fn = toolCall ~= nil and toolCall["function"] -- 3064
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3064
					AgentUtils.Log( -- 3066
						"Error", -- 3066
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3066
					) -- 3066
					clearPreExecutedResults(shared) -- 3067
					return ____awaiter_resolve( -- 3067
						nil, -- 3067
						{ -- 3068
							success = false, -- 3069
							message = "missing function name for tool call " .. tostring(i + 1), -- 3070
							raw = messageContent -- 3071
						} -- 3071
					) -- 3071
				end -- 3071
				local functionName = fn.name -- 3074
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3075
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3076
				AgentUtils.Log( -- 3079
					"Info", -- 3079
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3079
				) -- 3079
				local decision = parseAndValidateToolCallDecision( -- 3080
					shared, -- 3081
					functionName, -- 3082
					argsText, -- 3083
					toolCallId, -- 3084
					messageContent, -- 3085
					reasoningContent -- 3086
				) -- 3086
				if not decision.success then -- 3086
					AgentUtils.Log( -- 3089
						"Error", -- 3089
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3089
					) -- 3089
					clearPreExecutedResults(shared) -- 3090
					return ____awaiter_resolve(nil, decision) -- 3090
				end -- 3090
				decisions[#decisions + 1] = decision -- 3093
				i = i + 1 -- 3062
			end -- 3062
		end -- 3062
		if #decisions == 1 then -- 3062
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3096
			return ____awaiter_resolve(nil, decisions[1]) -- 3096
		end -- 3096
		do -- 3096
			local i = 0 -- 3099
			while i < #decisions do -- 3099
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3099
					clearPreExecutedResults(shared) -- 3101
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3101
				end -- 3101
				i = i + 1 -- 3099
			end -- 3099
		end -- 3099
		AgentUtils.Log( -- 3109
			"Info", -- 3109
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3109
				__TS__ArrayMap( -- 3109
					decisions, -- 3109
					function(____, decision) return decision.tool end -- 3109
				), -- 3109
				"," -- 3109
			) -- 3109
		) -- 3109
		return ____awaiter_resolve(nil, { -- 3109
			success = true, -- 3111
			kind = "batch", -- 3112
			decisions = decisions, -- 3113
			content = messageContent, -- 3114
			reasoningContent = reasoningContent -- 3115
		}) -- 3115
	end) -- 3115
end -- 2915
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3119
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3119
		AgentUtils.Log( -- 3125
			"Info", -- 3125
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3125
		) -- 3125
		local lastError = initialError -- 3126
		local candidateRaw = "" -- 3127
		local candidateReasoning = nil -- 3128
		do -- 3128
			local attempt = 0 -- 3129
			while attempt < shared.llmMaxTry do -- 3129
				do -- 3129
					AgentUtils.Log( -- 3130
						"Info", -- 3130
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3130
					) -- 3130
					local messages = buildXmlRepairMessages( -- 3131
						shared, -- 3132
						originalRaw, -- 3133
						originalReasoning, -- 3134
						candidateRaw, -- 3135
						candidateReasoning, -- 3136
						lastError, -- 3137
						attempt + 1 -- 3138
					) -- 3138
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3140
					if shared.stopToken.stopped then -- 3140
						return ____awaiter_resolve( -- 3140
							nil, -- 3140
							{ -- 3142
								success = false, -- 3142
								message = getCancelledReason(shared) -- 3142
							} -- 3142
						) -- 3142
					end -- 3142
					if not llmRes.success then -- 3142
						lastError = llmRes.message -- 3145
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3146
						goto __continue530 -- 3147
					end -- 3147
					candidateRaw = llmRes.text -- 3149
					candidateReasoning = llmRes.reasoningContent -- 3150
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3151
					if decision.success then -- 3151
						decision.reasoningContent = llmRes.reasoningContent -- 3153
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3154
						return ____awaiter_resolve(nil, decision) -- 3154
					end -- 3154
					lastError = decision.message -- 3157
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3158
				end -- 3158
				::__continue530:: -- 3158
				attempt = attempt + 1 -- 3129
			end -- 3129
		end -- 3129
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3160
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3160
	end) -- 3160
end -- 3119
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3168
	if attempt == nil then -- 3168
		attempt = 1 -- 3171
	end -- 3171
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3171
		local messages = buildDecisionMessages( -- 3174
			shared, -- 3175
			lastError, -- 3176
			attempt, -- 3177
			lastRaw, -- 3178
			"xml" -- 3179
		) -- 3179
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3181
		if shared.stopToken.stopped then -- 3181
			return ____awaiter_resolve( -- 3181
				nil, -- 3181
				{ -- 3183
					success = false, -- 3183
					message = getCancelledReason(shared) -- 3183
				} -- 3183
			) -- 3183
		end -- 3183
		if not llmRes.success then -- 3183
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3183
		end -- 3183
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3192
		if decision.success then -- 3192
			decision.reasoningContent = llmRes.reasoningContent -- 3194
			return ____awaiter_resolve(nil, decision) -- 3194
		end -- 3194
		return ____awaiter_resolve( -- 3194
			nil, -- 3194
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3197
		) -- 3197
	end) -- 3197
end -- 3168
function MainDecisionAgent.prototype.exec(self, input) -- 3200
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3200
		local shared = input.shared -- 3201
		if shared.stopToken.stopped then -- 3201
			return ____awaiter_resolve( -- 3201
				nil, -- 3201
				{ -- 3203
					success = false, -- 3203
					message = getCancelledReason(shared) -- 3203
				} -- 3203
			) -- 3203
		end -- 3203
		if shared.agentStepCount >= shared.maxSteps then -- 3203
			AgentUtils.Log( -- 3206
				"Warn", -- 3206
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3206
			) -- 3206
			return ____awaiter_resolve( -- 3206
				nil, -- 3206
				{ -- 3207
					success = false, -- 3207
					message = getMaxStepsReachedReason(shared) -- 3207
				} -- 3207
			) -- 3207
		end -- 3207
		if shared.decisionMode == "tool_calling" then -- 3207
			AgentUtils.Log( -- 3211
				"Info", -- 3211
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3211
			) -- 3211
			local lastError = "tool calling validation failed" -- 3212
			local lastRaw = "" -- 3213
			local shouldFallbackToXml = false -- 3214
			do -- 3214
				local attempt = 0 -- 3215
				while attempt < shared.llmMaxTry do -- 3215
					AgentUtils.Log( -- 3216
						"Info", -- 3216
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3216
					) -- 3216
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3217
					if shared.stopToken.stopped then -- 3217
						return ____awaiter_resolve( -- 3217
							nil, -- 3217
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
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3231
					if lastError == "missing tool call" then -- 3231
						shouldFallbackToXml = true -- 3233
						break -- 3234
					end -- 3234
					attempt = attempt + 1 -- 3215
				end -- 3215
			end -- 3215
			if shouldFallbackToXml then -- 3215
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3238
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3239
				do -- 3239
					local attempt = 0 -- 3240
					while attempt < shared.llmMaxTry do -- 3240
						AgentUtils.Log( -- 3241
							"Info", -- 3241
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3241
						) -- 3241
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3242
						if shared.stopToken.stopped then -- 3242
							return ____awaiter_resolve( -- 3242
								nil, -- 3242
								{ -- 3249
									success = false, -- 3249
									message = getCancelledReason(shared) -- 3249
								} -- 3249
							) -- 3249
						end -- 3249
						if decision.success then -- 3249
							return ____awaiter_resolve(nil, decision) -- 3249
						end -- 3249
						lastError = decision.message -- 3254
						lastRaw = decision.raw or "" -- 3255
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3256
						attempt = attempt + 1 -- 3240
					end -- 3240
				end -- 3240
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3258
				return ____awaiter_resolve( -- 3258
					nil, -- 3258
					{ -- 3259
						success = false, -- 3259
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3259
					} -- 3259
				) -- 3259
			end -- 3259
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3261
			return ____awaiter_resolve( -- 3261
				nil, -- 3261
				{ -- 3262
					success = false, -- 3262
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3262
				} -- 3262
			) -- 3262
		end -- 3262
		local lastError = "xml validation failed" -- 3265
		local lastRaw = "" -- 3266
		do -- 3266
			local attempt = 0 -- 3267
			while attempt < shared.llmMaxTry do -- 3267
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3268
				if shared.stopToken.stopped then -- 3268
					return ____awaiter_resolve( -- 3268
						nil, -- 3268
						{ -- 3277
							success = false, -- 3277
							message = getCancelledReason(shared) -- 3277
						} -- 3277
					) -- 3277
				end -- 3277
				if decision.success then -- 3277
					return ____awaiter_resolve(nil, decision) -- 3277
				end -- 3277
				lastError = decision.message -- 3282
				lastRaw = decision.raw or "" -- 3283
				attempt = attempt + 1 -- 3267
			end -- 3267
		end -- 3267
		return ____awaiter_resolve( -- 3267
			nil, -- 3267
			{ -- 3285
				success = false, -- 3285
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3285
			} -- 3285
		) -- 3285
	end) -- 3285
end -- 3200
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3288
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3288
		local result = execRes -- 3289
		if not result.success then -- 3289
			if shared.stopToken.stopped then -- 3289
				shared.error = getCancelledReason(shared) -- 3292
				shared.done = true -- 3293
				return ____awaiter_resolve(nil, "done") -- 3293
			end -- 3293
			shared.error = result.message -- 3296
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3297
			shared.done = true -- 3298
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3299
			persistHistoryState(shared) -- 3303
			return ____awaiter_resolve(nil, "done") -- 3303
		end -- 3303
		if isDecisionBatchSuccess(result) then -- 3303
			local startStep = shared.step -- 3307
			local actions = {} -- 3308
			do -- 3308
				local i = 0 -- 3309
				while i < #result.decisions do -- 3309
					local decision = result.decisions[i + 1] -- 3310
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3311
					local step = startStep + i + 1 -- 3312
					local ____temp_96 -- 3313
					if i == 0 then -- 3313
						____temp_96 = decision.reason -- 3313
					else -- 3313
						____temp_96 = "" -- 3313
					end -- 3313
					local actionReason = ____temp_96 -- 3313
					local ____temp_97 -- 3314
					if i == 0 then -- 3314
						____temp_97 = decision.reasoningContent -- 3314
					else -- 3314
						____temp_97 = nil -- 3314
					end -- 3314
					local actionReasoningContent = ____temp_97 -- 3314
					emitAgentEvent(shared, { -- 3315
						type = "decision_made", -- 3316
						sessionId = shared.sessionId, -- 3317
						taskId = shared.taskId, -- 3318
						step = step, -- 3319
						tool = decision.tool, -- 3320
						reason = actionReason, -- 3321
						reasoningContent = actionReasoningContent, -- 3322
						params = decision.params -- 3323
					}) -- 3323
					local action = { -- 3325
						step = step, -- 3326
						toolCallId = toolCallId, -- 3327
						tool = decision.tool, -- 3328
						reason = actionReason or "", -- 3329
						reasoningContent = actionReasoningContent, -- 3330
						params = decision.params, -- 3331
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3332
					} -- 3332
					local ____shared_history_98 = shared.history -- 3332
					____shared_history_98[#____shared_history_98 + 1] = action -- 3334
					actions[#actions + 1] = action -- 3335
					i = i + 1 -- 3309
				end -- 3309
			end -- 3309
			shared.step = startStep + #actions -- 3337
			shared.agentStepCount = shared.agentStepCount + #actions -- 3338
			shared.pendingToolActions = actions -- 3339
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3340
			persistHistoryState(shared) -- 3346
			return ____awaiter_resolve(nil, "batch_tools") -- 3346
		end -- 3346
		if result.directSummary and result.directSummary ~= "" then -- 3346
			shared.response = result.directSummary -- 3350
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3351
			shared.done = true -- 3355
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3356
			persistHistoryState(shared) -- 3361
			return ____awaiter_resolve(nil, "done") -- 3361
		end -- 3361
		if result.tool == "finish" then -- 3361
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3365
			shared.response = finalMessage -- 3366
			shared.completion = getCompletionReport(result.params) -- 3367
			shared.done = true -- 3368
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3369
			persistHistoryState(shared) -- 3374
			return ____awaiter_resolve(nil, "done") -- 3374
		end -- 3374
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3377
		shared.step = shared.step + 1 -- 3378
		shared.agentStepCount = shared.agentStepCount + 1 -- 3379
		local step = shared.step -- 3380
		emitAgentEvent(shared, { -- 3381
			type = "decision_made", -- 3382
			sessionId = shared.sessionId, -- 3383
			taskId = shared.taskId, -- 3384
			step = step, -- 3385
			tool = result.tool, -- 3386
			reason = result.reason, -- 3387
			reasoningContent = result.reasoningContent, -- 3388
			params = result.params -- 3389
		}) -- 3389
		local ____shared_history_99 = shared.history -- 3389
		____shared_history_99[#____shared_history_99 + 1] = { -- 3391
			step = step, -- 3392
			toolCallId = toolCallId, -- 3393
			tool = result.tool, -- 3394
			reason = result.reason or "", -- 3395
			reasoningContent = result.reasoningContent, -- 3396
			params = result.params, -- 3397
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3398
		} -- 3398
		local action = shared.history[#shared.history] -- 3400
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3401
		shared.pendingToolActions = {action} -- 3404
		persistHistoryState(shared) -- 3405
		return ____awaiter_resolve(nil, "batch_tools") -- 3405
	end) -- 3405
end -- 3288
local ReadFileAction = __TS__Class() -- 3410
ReadFileAction.name = "ReadFileAction" -- 3410
__TS__ClassExtends(ReadFileAction, Node) -- 3410
function ReadFileAction.prototype.prep(self, shared) -- 3411
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3411
		local last = shared.history[#shared.history] -- 3412
		if not last then -- 3412
			error( -- 3413
				__TS__New(Error, "no history"), -- 3413
				0 -- 3413
			) -- 3413
		end -- 3413
		emitAgentStartEvent(shared, last) -- 3414
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3415
		if __TS__StringTrim(path) == "" then -- 3415
			error( -- 3418
				__TS__New(Error, "missing path"), -- 3418
				0 -- 3418
			) -- 3418
		end -- 3418
		local ____path_102 = path -- 3420
		local ____shared_workingDir_103 = shared.workingDir -- 3422
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3423
		local ____last_params_startLine_100 = last.params.startLine -- 3424
		if ____last_params_startLine_100 == nil then -- 3424
			____last_params_startLine_100 = 1 -- 3424
		end -- 3424
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3424
		local ____last_params_endLine_101 = last.params.endLine -- 3425
		if ____last_params_endLine_101 == nil then -- 3425
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3425
		end -- 3425
		return ____awaiter_resolve( -- 3425
			nil, -- 3425
			{ -- 3419
				path = ____path_102, -- 3420
				tool = "read_file", -- 3421
				workDir = ____shared_workingDir_103, -- 3422
				docLanguage = ____temp_104, -- 3423
				startLine = ____TS__Number_result_105, -- 3424
				endLine = __TS__Number(____last_params_endLine_101) -- 3425
			} -- 3425
		) -- 3425
	end) -- 3425
end -- 3411
function ReadFileAction.prototype.exec(self, input) -- 3429
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3429
		return ____awaiter_resolve( -- 3429
			nil, -- 3429
			Tools.readFile( -- 3430
				input.workDir, -- 3431
				input.path, -- 3432
				__TS__Number(input.startLine or 1), -- 3433
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3434
				input.docLanguage -- 3435
			) -- 3435
		) -- 3435
	end) -- 3435
end -- 3429
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3439
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3439
		local result = execRes -- 3440
		local last = shared.history[#shared.history] -- 3441
		if last ~= nil then -- 3441
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3443
			appendToolResultMessage(shared, last) -- 3444
			emitAgentFinishEvent(shared, last) -- 3445
		end -- 3445
		persistHistoryState(shared) -- 3447
		__TS__Await(maybeCompressHistory(shared)) -- 3448
		persistHistoryState(shared) -- 3449
		return ____awaiter_resolve(nil, "main") -- 3449
	end) -- 3449
end -- 3439
local SearchFilesAction = __TS__Class() -- 3454
SearchFilesAction.name = "SearchFilesAction" -- 3454
__TS__ClassExtends(SearchFilesAction, Node) -- 3454
function SearchFilesAction.prototype.prep(self, shared) -- 3455
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3455
		local last = shared.history[#shared.history] -- 3456
		if not last then -- 3456
			error( -- 3457
				__TS__New(Error, "no history"), -- 3457
				0 -- 3457
			) -- 3457
		end -- 3457
		emitAgentStartEvent(shared, last) -- 3458
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3458
	end) -- 3458
end -- 3455
function SearchFilesAction.prototype.exec(self, input) -- 3462
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3462
		local params = input.params -- 3463
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3464
		local ____input_workDir_112 = input.workDir -- 3465
		local ____temp_113 = params.path or "" -- 3466
		local ____temp_114 = params.pattern or "" -- 3467
		local ____params_globs_115 = params.globs -- 3468
		local ____params_useRegex_116 = params.useRegex -- 3469
		local ____params_caseSensitive_117 = params.caseSensitive -- 3470
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3472
		local ____math_max_108 = math.max -- 3473
		local ____math_floor_107 = math.floor -- 3473
		local ____params_limit_106 = params.limit -- 3473
		if ____params_limit_106 == nil then -- 3473
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3473
		end -- 3473
		local ____math_max_108_result_119 = ____math_max_108( -- 3473
			1, -- 3473
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3473
		) -- 3473
		local ____math_max_111 = math.max -- 3474
		local ____math_floor_110 = math.floor -- 3474
		local ____params_offset_109 = params.offset -- 3474
		if ____params_offset_109 == nil then -- 3474
			____params_offset_109 = 0 -- 3474
		end -- 3474
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3464
			workDir = ____input_workDir_112, -- 3465
			path = ____temp_113, -- 3466
			pattern = ____temp_114, -- 3467
			globs = ____params_globs_115, -- 3468
			useRegex = ____params_useRegex_116, -- 3469
			caseSensitive = ____params_caseSensitive_117, -- 3470
			includeContent = true, -- 3471
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3472
			limit = ____math_max_108_result_119, -- 3473
			offset = ____math_max_111( -- 3474
				0, -- 3474
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3474
			), -- 3474
			groupByFile = params.groupByFile == true -- 3475
		})) -- 3475
		return ____awaiter_resolve(nil, result) -- 3475
	end) -- 3475
end -- 3462
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3480
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3480
		local last = shared.history[#shared.history] -- 3481
		if last ~= nil then -- 3481
			local result = execRes -- 3483
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3484
			appendToolResultMessage(shared, last) -- 3485
			emitAgentFinishEvent(shared, last) -- 3486
		end -- 3486
		persistHistoryState(shared) -- 3488
		__TS__Await(maybeCompressHistory(shared)) -- 3489
		persistHistoryState(shared) -- 3490
		return ____awaiter_resolve(nil, "main") -- 3490
	end) -- 3490
end -- 3480
local SearchDoraAPIAction = __TS__Class() -- 3495
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3495
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3495
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3496
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3496
		local last = shared.history[#shared.history] -- 3497
		if not last then -- 3497
			error( -- 3498
				__TS__New(Error, "no history"), -- 3498
				0 -- 3498
			) -- 3498
		end -- 3498
		emitAgentStartEvent(shared, last) -- 3499
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3499
	end) -- 3499
end -- 3496
function SearchDoraAPIAction.prototype.exec(self, input) -- 3503
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3503
		local params = input.params -- 3504
		local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3505
		local ____temp_125 = params.pattern or "" -- 3506
		local ____temp_126 = params.docSource or "api" -- 3507
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3508
		local ____temp_128 = params.programmingLanguage or "ts" -- 3509
		local ____math_min_124 = math.min -- 3510
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3510
		local ____math_max_122 = math.max -- 3510
		local ____params_limit_121 = params.limit -- 3510
		if ____params_limit_121 == nil then -- 3510
			____params_limit_121 = 8 -- 3510
		end -- 3510
		local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3505
			pattern = ____temp_125, -- 3506
			docSource = ____temp_126, -- 3507
			docLanguage = ____temp_127, -- 3508
			programmingLanguage = ____temp_128, -- 3509
			limit = ____math_min_124( -- 3510
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123, -- 3510
				____math_max_122( -- 3510
					1, -- 3510
					__TS__Number(____params_limit_121) -- 3510
				) -- 3510
			), -- 3510
			useRegex = params.useRegex, -- 3511
			caseSensitive = false, -- 3512
			includeContent = true, -- 3513
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3514
		})) -- 3514
		return ____awaiter_resolve(nil, result) -- 3514
	end) -- 3514
end -- 3503
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3519
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3519
		local last = shared.history[#shared.history] -- 3520
		if last ~= nil then -- 3520
			local result = execRes -- 3522
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3523
			appendToolResultMessage(shared, last) -- 3524
			emitAgentFinishEvent(shared, last) -- 3525
		end -- 3525
		persistHistoryState(shared) -- 3527
		__TS__Await(maybeCompressHistory(shared)) -- 3528
		persistHistoryState(shared) -- 3529
		return ____awaiter_resolve(nil, "main") -- 3529
	end) -- 3529
end -- 3519
local ListFilesAction = __TS__Class() -- 3534
ListFilesAction.name = "ListFilesAction" -- 3534
__TS__ClassExtends(ListFilesAction, Node) -- 3534
function ListFilesAction.prototype.prep(self, shared) -- 3535
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3535
		local last = shared.history[#shared.history] -- 3536
		if not last then -- 3536
			error( -- 3537
				__TS__New(Error, "no history"), -- 3537
				0 -- 3537
			) -- 3537
		end -- 3537
		emitAgentStartEvent(shared, last) -- 3538
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3538
	end) -- 3538
end -- 3535
function ListFilesAction.prototype.exec(self, input) -- 3542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3542
		local params = input.params -- 3543
		local ____Tools_listFiles_136 = Tools.listFiles -- 3544
		local ____input_workDir_133 = input.workDir -- 3545
		local ____temp_134 = params.path or "" -- 3546
		local ____params_globs_135 = params.globs -- 3547
		local ____math_max_132 = math.max -- 3548
		local ____math_floor_131 = math.floor -- 3548
		local ____params_maxEntries_130 = params.maxEntries -- 3548
		if ____params_maxEntries_130 == nil then -- 3548
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3548
		end -- 3548
		local result = ____Tools_listFiles_136({ -- 3544
			workDir = ____input_workDir_133, -- 3545
			path = ____temp_134, -- 3546
			globs = ____params_globs_135, -- 3547
			maxEntries = ____math_max_132( -- 3548
				1, -- 3548
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3548
			) -- 3548
		}) -- 3548
		return ____awaiter_resolve(nil, result) -- 3548
	end) -- 3548
end -- 3542
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3553
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3553
		local last = shared.history[#shared.history] -- 3554
		if last ~= nil then -- 3554
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3556
			appendToolResultMessage(shared, last) -- 3557
			emitAgentFinishEvent(shared, last) -- 3558
		end -- 3558
		persistHistoryState(shared) -- 3560
		__TS__Await(maybeCompressHistory(shared)) -- 3561
		persistHistoryState(shared) -- 3562
		return ____awaiter_resolve(nil, "main") -- 3562
	end) -- 3562
end -- 3553
local DeleteFileAction = __TS__Class() -- 3567
DeleteFileAction.name = "DeleteFileAction" -- 3567
__TS__ClassExtends(DeleteFileAction, Node) -- 3567
function DeleteFileAction.prototype.prep(self, shared) -- 3568
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3568
		local last = shared.history[#shared.history] -- 3569
		if not last then -- 3569
			error( -- 3570
				__TS__New(Error, "no history"), -- 3570
				0 -- 3570
			) -- 3570
		end -- 3570
		emitAgentStartEvent(shared, last) -- 3571
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3572
		if __TS__StringTrim(targetFile) == "" then -- 3572
			error( -- 3575
				__TS__New(Error, "missing target_file"), -- 3575
				0 -- 3575
			) -- 3575
		end -- 3575
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3575
	end) -- 3575
end -- 3568
function DeleteFileAction.prototype.exec(self, input) -- 3579
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3579
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3580
		if not result.success then -- 3580
			return ____awaiter_resolve(nil, result) -- 3580
		end -- 3580
		return ____awaiter_resolve(nil, { -- 3580
			success = true, -- 3588
			changed = true, -- 3589
			mode = "delete", -- 3590
			checkpointId = result.checkpointId, -- 3591
			checkpointSeq = result.checkpointSeq, -- 3592
			files = {{path = input.targetFile, op = "delete"}} -- 3593
		}) -- 3593
	end) -- 3593
end -- 3579
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3597
		local last = shared.history[#shared.history] -- 3598
		if last ~= nil then -- 3598
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3600
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3601
			appendToolResultMessage(shared, last) -- 3602
			emitAgentFinishEvent(shared, last) -- 3603
			local result = last.result -- 3604
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3604
				emitAgentEvent(shared, { -- 3609
					type = "checkpoint_created", -- 3610
					sessionId = shared.sessionId, -- 3611
					taskId = shared.taskId, -- 3612
					step = last.step, -- 3613
					tool = "delete_file", -- 3614
					checkpointId = result.checkpointId, -- 3615
					checkpointSeq = result.checkpointSeq, -- 3616
					files = result.files -- 3617
				}) -- 3617
			end -- 3617
		end -- 3617
		persistHistoryState(shared) -- 3624
		__TS__Await(maybeCompressHistory(shared)) -- 3625
		persistHistoryState(shared) -- 3626
		return ____awaiter_resolve(nil, "main") -- 3626
	end) -- 3626
end -- 3597
local BuildAction = __TS__Class() -- 3631
BuildAction.name = "BuildAction" -- 3631
__TS__ClassExtends(BuildAction, Node) -- 3631
function BuildAction.prototype.prep(self, shared) -- 3632
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3632
		local last = shared.history[#shared.history] -- 3633
		if not last then -- 3633
			error( -- 3634
				__TS__New(Error, "no history"), -- 3634
				0 -- 3634
			) -- 3634
		end -- 3634
		emitAgentStartEvent(shared, last) -- 3635
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3635
	end) -- 3635
end -- 3632
function BuildAction.prototype.exec(self, input) -- 3639
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3639
		local params = input.params -- 3640
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3641
		return ____awaiter_resolve(nil, result) -- 3641
	end) -- 3641
end -- 3639
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3648
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3648
		local last = shared.history[#shared.history] -- 3649
		if last ~= nil then -- 3649
			last.result = sanitizeBuildResultForHistory(execRes) -- 3651
			appendToolResultMessage(shared, last) -- 3652
			emitAgentFinishEvent(shared, last) -- 3653
		end -- 3653
		persistHistoryState(shared) -- 3655
		__TS__Await(maybeCompressHistory(shared)) -- 3656
		persistHistoryState(shared) -- 3657
		return ____awaiter_resolve(nil, "main") -- 3657
	end) -- 3657
end -- 3648
local SpawnSubAgentAction = __TS__Class() -- 3662
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3662
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3662
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3663
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3663
		local last = shared.history[#shared.history] -- 3673
		if not last then -- 3673
			error( -- 3674
				__TS__New(Error, "no history"), -- 3674
				0 -- 3674
			) -- 3674
		end -- 3674
		emitAgentStartEvent(shared, last) -- 3675
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3676
			last.params.filesHint, -- 3677
			function(____, item) return type(item) == "string" end -- 3677
		) or nil -- 3677
		return ____awaiter_resolve( -- 3677
			nil, -- 3677
			{ -- 3679
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3680
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3681
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3682
				filesHint = filesHint, -- 3683
				sessionId = shared.sessionId, -- 3684
				projectRoot = shared.workingDir, -- 3685
				spawnSubAgent = shared.spawnSubAgent, -- 3686
				disabledAgentTools = shared.disabledAgentTools -- 3687
			} -- 3687
		) -- 3687
	end) -- 3687
end -- 3663
function SpawnSubAgentAction.prototype.exec(self, input) -- 3691
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3691
		if not input.spawnSubAgent then -- 3691
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3691
		end -- 3691
		if input.sessionId == nil or input.sessionId <= 0 then -- 3691
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3691
		end -- 3691
		local ____AgentUtils_Log_142 = AgentUtils.Log -- 3707
		local ____temp_139 = #input.title -- 3707
		local ____temp_140 = #input.prompt -- 3707
		local ____temp_141 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3707
		local ____opt_137 = input.filesHint -- 3707
		____AgentUtils_Log_142( -- 3707
			"Info", -- 3707
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_139)) .. " prompt_len=") .. tostring(____temp_140)) .. " expected_len=") .. tostring(____temp_141)) .. " files_hint_count=") .. tostring(____opt_137 and #____opt_137 or 0) -- 3707
		) -- 3707
		local result = __TS__Await(input.spawnSubAgent({ -- 3708
			parentSessionId = input.sessionId, -- 3709
			projectRoot = input.projectRoot, -- 3710
			title = input.title, -- 3711
			prompt = input.prompt, -- 3712
			expectedOutput = input.expectedOutput, -- 3713
			filesHint = input.filesHint, -- 3714
			disabledAgentTools = input.disabledAgentTools -- 3715
		})) -- 3715
		if not result.success then -- 3715
			return ____awaiter_resolve(nil, result) -- 3715
		end -- 3715
		return ____awaiter_resolve(nil, { -- 3715
			success = true, -- 3721
			sessionId = result.sessionId, -- 3722
			taskId = result.taskId, -- 3723
			title = result.title, -- 3724
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3725
		}) -- 3725
	end) -- 3725
end -- 3691
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3729
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3729
		local last = shared.history[#shared.history] -- 3730
		if last ~= nil then -- 3730
			last.result = execRes -- 3732
			if execRes.success == true then -- 3732
				shared.hasSpawnedSubAgentThisTask = true -- 3734
			end -- 3734
			appendToolResultMessage(shared, last) -- 3736
			emitAgentFinishEvent(shared, last) -- 3737
		end -- 3737
		persistHistoryState(shared) -- 3739
		__TS__Await(maybeCompressHistory(shared)) -- 3740
		persistHistoryState(shared) -- 3741
		return ____awaiter_resolve(nil, "main") -- 3741
	end) -- 3741
end -- 3729
local ListSubAgentsAction = __TS__Class() -- 3746
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3746
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3746
function ListSubAgentsAction.prototype.prep(self, shared) -- 3747
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3747
		local last = shared.history[#shared.history] -- 3757
		if not last then -- 3757
			error( -- 3758
				__TS__New(Error, "no history"), -- 3758
				0 -- 3758
			) -- 3758
		end -- 3758
		emitAgentStartEvent(shared, last) -- 3759
		return ____awaiter_resolve( -- 3759
			nil, -- 3759
			{ -- 3760
				sessionId = shared.sessionId, -- 3761
				projectRoot = shared.workingDir, -- 3762
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3763
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3764
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3765
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3766
				listSubAgents = shared.listSubAgents, -- 3767
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3768
			} -- 3768
		) -- 3768
	end) -- 3768
end -- 3747
function ListSubAgentsAction.prototype.exec(self, input) -- 3772
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3772
		if not input.listSubAgents then -- 3772
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3772
		end -- 3772
		if input.sessionId == nil or input.sessionId <= 0 then -- 3772
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3772
		end -- 3772
		local result = __TS__Await(input.listSubAgents({ -- 3788
			sessionId = input.sessionId, -- 3789
			projectRoot = input.projectRoot, -- 3790
			status = input.status, -- 3791
			limit = input.limit, -- 3792
			offset = input.offset, -- 3793
			query = input.query -- 3794
		})) -- 3794
		return ____awaiter_resolve( -- 3794
			nil, -- 3794
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3796
		) -- 3796
	end) -- 3796
end -- 3772
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3804
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3804
		local last = shared.history[#shared.history] -- 3805
		if last ~= nil then -- 3805
			last.result = execRes -- 3807
			appendToolResultMessage(shared, last) -- 3808
			emitAgentFinishEvent(shared, last) -- 3809
		end -- 3809
		persistHistoryState(shared) -- 3811
		__TS__Await(maybeCompressHistory(shared)) -- 3812
		persistHistoryState(shared) -- 3813
		return ____awaiter_resolve(nil, "main") -- 3813
	end) -- 3813
end -- 3804
EditFileAction = __TS__Class() -- 3818
EditFileAction.name = "EditFileAction" -- 3818
__TS__ClassExtends(EditFileAction, Node) -- 3818
function EditFileAction.prototype.prep(self, shared) -- 3819
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3819
		local last = shared.history[#shared.history] -- 3820
		if not last then -- 3820
			error( -- 3821
				__TS__New(Error, "no history"), -- 3821
				0 -- 3821
			) -- 3821
		end -- 3821
		emitAgentStartEvent(shared, last) -- 3822
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3823
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3826
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3827
		if __TS__StringTrim(path) == "" then -- 3827
			error( -- 3828
				__TS__New(Error, "missing path"), -- 3828
				0 -- 3828
			) -- 3828
		end -- 3828
		return ____awaiter_resolve(nil, { -- 3828
			path = path, -- 3829
			oldStr = oldStr, -- 3829
			newStr = newStr, -- 3829
			taskId = shared.taskId, -- 3829
			workDir = shared.workingDir -- 3829
		}) -- 3829
	end) -- 3829
end -- 3819
function EditFileAction.prototype.exec(self, input) -- 3832
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3832
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3833
		if not readRes.success then -- 3833
			if input.oldStr ~= "" then -- 3833
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3833
			end -- 3833
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3838
			if not createRes.success then -- 3838
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3838
			end -- 3838
			return ____awaiter_resolve( -- 3838
				nil, -- 3838
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3845
					success = true, -- 3846
					changed = true, -- 3847
					mode = "create", -- 3848
					checkpointId = createRes.checkpointId, -- 3849
					checkpointSeq = createRes.checkpointSeq, -- 3850
					files = {{path = input.path, op = "create"}} -- 3851
				}) -- 3851
			) -- 3851
		end -- 3851
		if input.oldStr == "" then -- 3851
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3851
				return ____awaiter_resolve( -- 3851
					nil, -- 3851
					{ -- 3856
						success = false, -- 3857
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3858
						actualSaved = false, -- 3859
						actualSavedCharacters = 0, -- 3860
						currentFileExists = true, -- 3861
						currentCharacters = #readRes.content, -- 3862
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3863
					} -- 3863
				) -- 3863
			end -- 3863
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3866
			if not overwriteRes.success then -- 3866
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3866
			end -- 3866
			return ____awaiter_resolve( -- 3866
				nil, -- 3866
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3873
					success = true, -- 3874
					changed = true, -- 3875
					mode = "overwrite", -- 3876
					checkpointId = overwriteRes.checkpointId, -- 3877
					checkpointSeq = overwriteRes.checkpointSeq, -- 3878
					files = {{path = input.path, op = "write"}} -- 3879
				}) -- 3879
			) -- 3879
		end -- 3879
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3884
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3885
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3886
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3889
		if occurrences == 0 then -- 3889
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3891
			if not indentTolerant.success then -- 3891
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3891
			end -- 3891
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3895
			if not applyRes.success then -- 3895
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3895
			end -- 3895
			return ____awaiter_resolve( -- 3895
				nil, -- 3895
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3902
					success = true, -- 3903
					changed = true, -- 3904
					mode = "replace_indent_tolerant", -- 3905
					checkpointId = applyRes.checkpointId, -- 3906
					checkpointSeq = applyRes.checkpointSeq, -- 3907
					files = {{path = input.path, op = "write"}} -- 3908
				}) -- 3908
			) -- 3908
		end -- 3908
		if occurrences > 1 then -- 3908
			return ____awaiter_resolve( -- 3908
				nil, -- 3908
				{ -- 3912
					success = false, -- 3912
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3912
				} -- 3912
			) -- 3912
		end -- 3912
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3916
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3917
		if not applyRes.success then -- 3917
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3917
		end -- 3917
		return ____awaiter_resolve( -- 3917
			nil, -- 3917
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3924
				success = true, -- 3925
				changed = true, -- 3926
				mode = "replace", -- 3927
				checkpointId = applyRes.checkpointId, -- 3928
				checkpointSeq = applyRes.checkpointSeq, -- 3929
				files = {{path = input.path, op = "write"}} -- 3930
			}) -- 3930
		) -- 3930
	end) -- 3930
end -- 3832
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3934
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3934
		local last = shared.history[#shared.history] -- 3935
		if last ~= nil then -- 3935
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3937
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3938
			appendToolResultMessage(shared, last) -- 3939
			emitAgentFinishEvent(shared, last) -- 3940
			local result = last.result -- 3941
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3941
				emitAgentEvent(shared, { -- 3946
					type = "checkpoint_created", -- 3947
					sessionId = shared.sessionId, -- 3948
					taskId = shared.taskId, -- 3949
					step = last.step, -- 3950
					tool = last.tool, -- 3951
					checkpointId = result.checkpointId, -- 3952
					checkpointSeq = result.checkpointSeq, -- 3953
					files = result.files -- 3954
				}) -- 3954
			end -- 3954
		end -- 3954
		persistHistoryState(shared) -- 3961
		__TS__Await(maybeCompressHistory(shared)) -- 3962
		persistHistoryState(shared) -- 3963
		return ____awaiter_resolve(nil, "main") -- 3963
	end) -- 3963
end -- 3934
local FetchUrlAction = __TS__Class() -- 3968
FetchUrlAction.name = "FetchUrlAction" -- 3968
__TS__ClassExtends(FetchUrlAction, Node) -- 3968
function FetchUrlAction.prototype.prep(self, shared) -- 3969
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3969
		local last = shared.history[#shared.history] -- 3970
		if not last then -- 3970
			error( -- 3971
				__TS__New(Error, "no history"), -- 3971
				0 -- 3971
			) -- 3971
		end -- 3971
		emitAgentStartEvent(shared, last) -- 3972
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3972
	end) -- 3972
end -- 3969
function FetchUrlAction.prototype.exec(self, input) -- 3976
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3976
		return ____awaiter_resolve( -- 3976
			nil, -- 3976
			executeToolAction(input.shared, input.action) -- 3977
		) -- 3977
	end) -- 3977
end -- 3976
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3980
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3980
		local last = shared.history[#shared.history] -- 3981
		if last ~= nil then -- 3981
			last.result = execRes -- 3983
			appendToolResultMessage(shared, last) -- 3984
			emitAgentFinishEvent(shared, last) -- 3985
		end -- 3985
		persistHistoryState(shared) -- 3987
		__TS__Await(maybeCompressHistory(shared)) -- 3988
		persistHistoryState(shared) -- 3989
		return ____awaiter_resolve(nil, "main") -- 3989
	end) -- 3989
end -- 3980
local function emitCheckpointEventForAction(shared, action) -- 3994
	local result = action.result -- 3995
	if not result then -- 3995
		return -- 3996
	end -- 3996
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3996
		emitAgentEvent(shared, { -- 4001
			type = "checkpoint_created", -- 4002
			sessionId = shared.sessionId, -- 4003
			taskId = shared.taskId, -- 4004
			step = action.step, -- 4005
			tool = action.tool, -- 4006
			checkpointId = result.checkpointId, -- 4007
			checkpointSeq = result.checkpointSeq, -- 4008
			files = result.files -- 4009
		}) -- 4009
	end -- 4009
end -- 3994
local function canRunBatchActionInParallel(self, action) -- 4536
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4537
end -- 4536
local function partitionToolCalls(actions) -- 4545
	local batches = {} -- 4546
	do -- 4546
		local i = 0 -- 4547
		while i < #actions do -- 4547
			local action = actions[i + 1] -- 4548
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4549
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4550
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4550
				local ____lastBatch_actions_175 = lastBatch.actions -- 4550
				____lastBatch_actions_175[#____lastBatch_actions_175 + 1] = action -- 4552
			else -- 4552
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4554
			end -- 4554
			i = i + 1 -- 4547
		end -- 4547
	end -- 4547
	return batches -- 4557
end -- 4545
local function completeStoppedToolAction(shared, action) -- 4560
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4561
	if not action.result then -- 4561
		action.result = { -- 4563
			success = false, -- 4563
			message = getCancelledReason(shared) -- 4563
		} -- 4563
	end -- 4563
	appendToolResultMessage(shared, action) -- 4565
	emitAgentFinishEvent(shared, action) -- 4566
	emitCheckpointEventForAction(shared, action) -- 4567
end -- 4560
local BatchToolAction = __TS__Class() -- 4570
BatchToolAction.name = "BatchToolAction" -- 4570
__TS__ClassExtends(BatchToolAction, Node) -- 4570
function BatchToolAction.prototype.prep(self, shared) -- 4571
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4571
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4571
	end) -- 4571
end -- 4571
function BatchToolAction.prototype.exec(self, input) -- 4575
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4575
		local shared = input.shared -- 4576
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4577
		local preExecuted = shared.preExecutedResults -- 4578
		local batches = partitionToolCalls(input.actions) -- 4579
		local parallelBatchCount = #__TS__ArrayFilter( -- 4580
			batches, -- 4580
			function(____, b) return b.isConcurrencySafe end -- 4580
		) -- 4580
		local serialBatchCount = #__TS__ArrayFilter( -- 4581
			batches, -- 4581
			function(____, b) return not b.isConcurrencySafe end -- 4581
		) -- 4581
		AgentUtils.Log( -- 4582
			"Info", -- 4582
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4582
		) -- 4582
		do -- 4582
			local batchIdx = 0 -- 4584
			while batchIdx < #batches do -- 4584
				do -- 4584
					local batch = batches[batchIdx + 1] -- 4585
					if shared.stopToken.stopped then -- 4585
						for ____, action in ipairs(batch.actions) do -- 4587
							completeStoppedToolAction(shared, action) -- 4588
						end -- 4588
						goto __continue761 -- 4590
					end -- 4590
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4590
						local preExecCount = #__TS__ArrayFilter( -- 4594
							batch.actions, -- 4594
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4594
						) -- 4594
						AgentUtils.Log( -- 4595
							"Info", -- 4595
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4595
						) -- 4595
						do -- 4595
							local i = 0 -- 4596
							while i < #batch.actions do -- 4596
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4597
								i = i + 1 -- 4596
							end -- 4596
						end -- 4596
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4599
							batch.actions, -- 4599
							function(____, action) -- 4599
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4599
									if shared.stopToken.stopped then -- 4599
										action.result = { -- 4601
											success = false, -- 4601
											message = getCancelledReason(shared) -- 4601
										} -- 4601
										return ____awaiter_resolve(nil, action) -- 4601
									end -- 4601
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4604
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4605
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4606
									return ____awaiter_resolve(nil, action) -- 4606
								end) -- 4606
							end -- 4599
						))) -- 4599
						do -- 4599
							local i = 0 -- 4609
							while i < #batch.actions do -- 4609
								local action = batch.actions[i + 1] -- 4610
								if not action.result then -- 4610
									action.result = {success = false, message = "tool did not produce a result"} -- 4612
								end -- 4612
								appendToolResultMessage(shared, action) -- 4614
								emitAgentFinishEvent(shared, action) -- 4615
								emitCheckpointEventForAction(shared, action) -- 4616
								i = i + 1 -- 4609
							end -- 4609
						end -- 4609
					else -- 4609
						AgentUtils.Log( -- 4619
							"Info", -- 4619
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4619
						) -- 4619
						do -- 4619
							local i = 0 -- 4620
							while i < #batch.actions do -- 4620
								local action = batch.actions[i + 1] -- 4621
								emitAgentStartEvent(shared, action) -- 4622
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4623
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4624
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4625
								appendToolResultMessage(shared, action) -- 4626
								emitAgentFinishEvent(shared, action) -- 4627
								emitCheckpointEventForAction(shared, action) -- 4628
								persistHistoryState(shared) -- 4629
								if shared.stopToken.stopped then -- 4629
									do -- 4629
										local j = i + 1 -- 4631
										while j < #batch.actions do -- 4631
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4632
											j = j + 1 -- 4631
										end -- 4631
									end -- 4631
									break -- 4634
								end -- 4634
								i = i + 1 -- 4620
							end -- 4620
						end -- 4620
					end -- 4620
				end -- 4620
				::__continue761:: -- 4620
				batchIdx = batchIdx + 1 -- 4584
			end -- 4584
		end -- 4584
		local spawnSeen = spawnedBeforeBatch -- 4639
		local didDelegatedForegroundWork = false -- 4640
		do -- 4640
			local i = 0 -- 4641
			while i < #input.actions do -- 4641
				do -- 4641
					local action = input.actions[i + 1] -- 4642
					if action.tool == "spawn_sub_agent" then -- 4642
						local ____opt_178 = action.result -- 4642
						if (____opt_178 and ____opt_178.success) == true then -- 4642
							spawnSeen = true -- 4644
						end -- 4644
						goto __continue781 -- 4645
					end -- 4645
					if spawnSeen and action.tool ~= "finish" then -- 4645
						didDelegatedForegroundWork = true -- 4648
					end -- 4648
				end -- 4648
				::__continue781:: -- 4648
				i = i + 1 -- 4641
			end -- 4641
		end -- 4641
		if didDelegatedForegroundWork then -- 4641
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4652
		end -- 4652
		persistHistoryState(shared) -- 4654
		return ____awaiter_resolve(nil, input.actions) -- 4654
	end) -- 4654
end -- 4575
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4658
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4658
		shared.pendingToolActions = nil -- 4659
		shared.preExecutedResults = nil -- 4660
		persistHistoryState(shared) -- 4661
		if shared.waitingQuestionnaireId == nil then -- 4661
			__TS__Await(maybeCompressHistory(shared)) -- 4665
			persistHistoryState(shared) -- 4666
		end -- 4666
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4666
	end) -- 4666
end -- 4658
local EndNode = __TS__Class() -- 4672
EndNode.name = "EndNode" -- 4672
__TS__ClassExtends(EndNode, Node) -- 4672
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4673
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4673
		return ____awaiter_resolve(nil, nil) -- 4673
	end) -- 4673
end -- 4673
local CodingAgentFlow = __TS__Class() -- 4678
CodingAgentFlow.name = "CodingAgentFlow" -- 4678
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4678
function CodingAgentFlow.prototype.____constructor(self, role) -- 4679
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4680
	local read = __TS__New(ReadFileAction, 1, 0) -- 4681
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4682
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4683
	local list = __TS__New(ListFilesAction, 1, 0) -- 4684
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4685
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4686
	local build = __TS__New(BuildAction, 1, 0) -- 4687
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4688
	local edit = __TS__New(EditFileAction, 1, 0) -- 4689
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4690
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4691
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4692
	local done = __TS__New(EndNode, 1, 0) -- 4693
	main:on("batch_tools", batch) -- 4695
	main:on("grep_files", search) -- 4696
	main:on("search_dora_api", searchDora) -- 4697
	main:on("glob_files", list) -- 4698
	main:on("fetch_url", fetch) -- 4699
	main:on("execute_command", exec) -- 4700
	if role == "main" then -- 4700
		main:on("read_file", read) -- 4702
		main:on("delete_file", del) -- 4703
		main:on("build", build) -- 4704
		main:on("edit_file", edit) -- 4705
		main:on("list_sub_agents", listSub) -- 4706
		main:on("spawn_sub_agent", spawn) -- 4707
	else -- 4707
		main:on("read_file", read) -- 4709
		main:on("delete_file", del) -- 4710
		main:on("build", build) -- 4711
		main:on("edit_file", edit) -- 4712
	end -- 4712
	main:on("done", done) -- 4714
	search:on("main", main) -- 4716
	searchDora:on("main", main) -- 4717
	list:on("main", main) -- 4718
	listSub:on("main", main) -- 4719
	spawn:on("main", main) -- 4720
	batch:on("main", main) -- 4721
	batch:on("done", done) -- 4722
	read:on("main", main) -- 4723
	del:on("main", main) -- 4724
	build:on("main", main) -- 4725
	edit:on("main", main) -- 4726
	fetch:on("main", main) -- 4727
	exec:on("main", main) -- 4728
	Flow.prototype.____constructor(self, main) -- 4730
end -- 4679
local function runCodingAgentAsync(options) -- 4766
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4766
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4766
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4766
		end -- 4766
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4770
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4771
		if not llmConfigRes.success then -- 4771
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4771
		end -- 4771
		local llmConfig = llmConfigRes.config -- 4777
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4778
		if not taskRes.success then -- 4778
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4778
		end -- 4778
		local compressor = __TS__New(MemoryCompressor, { -- 4785
			compressionTargetThreshold = 0.5, -- 4786
			maxCompressionRounds = 3, -- 4787
			projectDir = options.workDir, -- 4788
			llmConfig = llmConfig, -- 4789
			promptPack = options.promptPack, -- 4790
			scope = options.memoryScope -- 4791
		}) -- 4791
		local persistedSession = compressor:getStorage():readSessionState() -- 4793
		local effectiveUserQuery = normalizedPrompt -- 4794
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4794
			do -- 4794
				local i = #persistedSession.messages - 1 -- 4796
				while i >= 0 do -- 4796
					local message = persistedSession.messages[i + 1] -- 4797
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4797
						effectiveUserQuery = message.content -- 4799
						break -- 4800
					end -- 4800
					i = i - 1 -- 4796
				end -- 4796
			end -- 4796
		end -- 4796
		local promptPack = compressor:getPromptPack() -- 4804
		local freshProject = inspectFreshProject(options.workDir) -- 4805
		local freshProjectBuildPending = freshProject.fresh -- 4806
		local freshProjectCodeFile = freshProject.codeFile -- 4807
		local shared = { -- 4809
			sessionId = options.sessionId, -- 4810
			taskId = taskRes.taskId, -- 4811
			role = options.role or "main", -- 4812
			maxSteps = math.max( -- 4813
				1, -- 4813
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4813
			), -- 4813
			llmMaxTry = math.max( -- 4814
				1, -- 4814
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4814
			), -- 4814
			step = math.max( -- 4815
				0, -- 4815
				math.floor(options.initialStep or 0) -- 4815
			), -- 4815
			agentStepCount = math.max( -- 4816
				0, -- 4816
				math.floor(options.initialAgentStepCount or 0) -- 4816
			), -- 4816
			done = false, -- 4817
			stopToken = options.stopToken or ({stopped = false}), -- 4818
			response = "", -- 4819
			userQuery = effectiveUserQuery, -- 4820
			workingDir = options.workDir, -- 4821
			useChineseResponse = options.useChineseResponse == true, -- 4822
			workMode = options.workMode or "code", -- 4823
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4824
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4827
			llmConfig = llmConfig, -- 4828
			onEvent = options.onEvent, -- 4829
			promptPack = promptPack, -- 4830
			history = {}, -- 4831
			messages = persistedSession.messages, -- 4832
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4833
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4834
			memory = {compressor = compressor}, -- 4836
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4840
				projectDir = options.workDir, -- 4842
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4843
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4844
			})}, -- 4844
			spawnSubAgent = options.spawnSubAgent, -- 4850
			listSubAgents = options.listSubAgents, -- 4851
			publishQuestionnaire = options.publishQuestionnaire, -- 4852
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4853
			freshProjectBuildPending = freshProjectBuildPending, -- 4854
			freshProjectCodeFile = freshProjectCodeFile, -- 4855
			hasSpawnedSubAgentThisTask = false, -- 4856
			delegatedForegroundBatches = 0, -- 4857
			tokenUsage = options.initialTokenUsage -- 4858
		} -- 4858
		local ____hasReturned, ____returnValue -- 4858
		local ____try = __TS__AsyncAwaiter(function() -- 4858
			if shared.workMode == "plan" then -- 4858
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4863
				if not planDocuments.success then -- 4863
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4865
					____hasReturned = true -- 4866
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4866
					return -- 4866
				end -- 4866
			end -- 4866
			emitAgentEvent(shared, { -- 4869
				type = "task_started", -- 4870
				sessionId = shared.sessionId, -- 4871
				taskId = shared.taskId, -- 4872
				prompt = shared.userQuery, -- 4873
				workDir = shared.workingDir, -- 4874
				maxSteps = shared.maxSteps, -- 4875
				resumed = options.resumeTask == true -- 4876
			}) -- 4876
			if shared.stopToken.stopped then -- 4876
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4879
				____hasReturned = true -- 4880
				____returnValue = emitAgentTaskFinishEvent( -- 4880
					shared, -- 4880
					false, -- 4880
					getCancelledReason(shared) -- 4880
				) -- 4880
				return -- 4880
			end -- 4880
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4882
			local ____temp_180 -- 4883
			if options.resumeConversation == true then -- 4883
				____temp_180 = nil -- 4883
			else -- 4883
				____temp_180 = getPromptCommand(shared.userQuery) -- 4883
			end -- 4883
			local promptCommand = ____temp_180 -- 4883
			if promptCommand == "clear" then -- 4883
				____hasReturned = true -- 4885
				____returnValue = clearSessionHistory(shared) -- 4885
				return -- 4885
			end -- 4885
			if promptCommand == "compact" then -- 4885
				if shared.role == "sub" then -- 4885
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4889
					____hasReturned = true -- 4890
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4890
					return -- 4890
				end -- 4890
				____hasReturned = true -- 4898
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4898
				return -- 4898
			end -- 4898
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4900
			if shared.stopToken.stopped then -- 4900
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4902
				____hasReturned = true -- 4903
				____returnValue = emitAgentTaskFinishEvent( -- 4903
					shared, -- 4903
					false, -- 4903
					getCancelledReason(shared) -- 4903
				) -- 4903
				return -- 4903
			end -- 4903
			if options.resumeConversation ~= true then -- 4903
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4906
				persistHistoryState(shared) -- 4910
			end -- 4910
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4912
			__TS__Await(flow:run(shared)) -- 4913
			if shared.stopToken.stopped then -- 4913
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4915
				____hasReturned = true -- 4916
				____returnValue = emitAgentTaskFinishEvent( -- 4916
					shared, -- 4916
					false, -- 4916
					getCancelledReason(shared) -- 4916
				) -- 4916
				return -- 4916
			end -- 4916
			if shared.error then -- 4916
				____hasReturned = true -- 4919
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4919
				return -- 4919
			end -- 4919
			if shared.waitingQuestionnaireId ~= nil then -- 4919
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4923
				emitAgentEvent(shared, { -- 4924
					type = "task_waiting_for_user", -- 4925
					sessionId = shared.sessionId, -- 4926
					taskId = shared.taskId, -- 4927
					step = shared.step, -- 4928
					questionnaireId = shared.waitingQuestionnaireId -- 4929
				}) -- 4929
				____hasReturned = true -- 4931
				____returnValue = { -- 4931
					success = true, -- 4932
					taskId = shared.taskId, -- 4933
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4934
					steps = shared.step, -- 4935
					waitingForUser = true, -- 4936
					questionnaireId = shared.waitingQuestionnaireId -- 4937
				} -- 4937
				return -- 4931
			end -- 4931
			local ____isFinalDecisionTurn_result_183 = isFinalDecisionTurn(shared) -- 4940
			if ____isFinalDecisionTurn_result_183 then -- 4940
				local ____opt_181 = shared.completion -- 4940
				____isFinalDecisionTurn_result_183 = (____opt_181 and ____opt_181.outcome) == "partial" -- 4940
			end -- 4940
			if ____isFinalDecisionTurn_result_183 then -- 4940
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4941
				____hasReturned = true -- 4942
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4942
				return -- 4942
			end -- 4942
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4945
			____hasReturned = true -- 4946
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4946
			return -- 4946
		end) -- 4946
		____try = ____try.catch( -- 4946
			____try, -- 4946
			function(____, e) -- 4946
				return __TS__AsyncAwaiter(function() -- 4946
					____hasReturned = true -- 4949
					____returnValue = finalizeAgentFailure( -- 4949
						shared, -- 4949
						tostring(e) -- 4949
					) -- 4949
					return -- 4949
				end) -- 4949
			end -- 4949
		) -- 4949
		__TS__Await(____try) -- 4861
		if ____hasReturned then -- 4861
			return ____awaiter_resolve(nil, ____returnValue) -- 4861
		end -- 4861
	end) -- 4861
end -- 4766
function ____exports.runCodingAgent(options, callback) -- 4953
	local ____self_184 = runCodingAgentAsync(options) -- 4953
	____self_184["then"]( -- 4953
		____self_184, -- 4953
		function(____, result) return callback(result) end -- 4954
	) -- 4954
end -- 4953
return ____exports -- 4953