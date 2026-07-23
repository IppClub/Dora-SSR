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
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2712
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2716
	end -- 2716
	if shared.truncatedToolOverwritePath ~= nil then -- 2716
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2719
	end -- 2719
	if consumeResumeCheckpoint then -- 2719
		shared.resumeCheckpointPending = false -- 2721
	end -- 2721
	local messages = { -- 2722
		{role = "system", content = systemPrompt}, -- 2723
		table.unpack(getUnconsolidatedMessages(shared)) -- 2724
	} -- 2724
	if pendingUserPrompt ~= "" then -- 2724
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2727
	end -- 2727
	if isFinalDecisionTurn(shared) then -- 2727
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2730
	end -- 2730
	if lastError and lastError ~= "" then -- 2730
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2733
		if decisionMode == "xml" then -- 2733
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2737
		end -- 2737
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2737
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2740
		end -- 2740
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2740
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2743
		end -- 2743
		messages[#messages + 1] = { -- 2745
			role = "user", -- 2746
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2747
		} -- 2747
	end -- 2747
	if #tailSections > 0 then -- 2747
		messages[#messages + 1] = { -- 2755
			role = "user", -- 2756
			content = table.concat(tailSections, "\n\n") -- 2757
		} -- 2757
	end -- 2757
	return messages -- 2760
end -- 2760
function buildXmlDecisionInstruction(shared, feedback) -- 2763
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2764
end -- 2764
function tryParseAndValidateDecision(rawText, shared) -- 2832
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2833
	if not parsed.success then -- 2833
		return {success = false, message = parsed.message, raw = rawText} -- 2835
	end -- 2835
	local decision = parseDecisionObject(parsed.obj) -- 2837
	if not decision.success then -- 2837
		return {success = false, message = decision.message, raw = rawText} -- 2839
	end -- 2839
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2841
	if not completionValidation.success then -- 2841
		return {success = false, message = completionValidation.message, raw = rawText} -- 2843
	end -- 2843
	local validation = validateDecision(decision.tool, decision.params) -- 2845
	if not validation.success then -- 2845
		return {success = false, message = validation.message, raw = rawText} -- 2847
	end -- 2847
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2849
	if not sharedValidation.success then -- 2849
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2851
	end -- 2851
	decision.params = validation.params -- 2853
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2854
	return decision -- 2855
end -- 2855
function executeToolAction(shared, action) -- 4022
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4022
		if shared.stopToken.stopped then -- 4022
			return ____awaiter_resolve( -- 4022
				nil, -- 4022
				{ -- 4024
					success = false, -- 4024
					message = getCancelledReason(shared) -- 4024
				} -- 4024
			) -- 4024
		end -- 4024
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4024
			shared.resumeRequiredTool = nil -- 4027
			shared.resumeCheckpointPending = false -- 4028
		end -- 4028
		local params = action.params -- 4030
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4031
		if not sharedValidation.success then -- 4031
			return ____awaiter_resolve(nil, sharedValidation) -- 4031
		end -- 4031
		if action.tool == "read_file" then -- 4031
			local ____params_startLine_143 = params.startLine -- 4034
			if ____params_startLine_143 == nil then -- 4034
				____params_startLine_143 = 1 -- 4034
			end -- 4034
			local startLine = __TS__Number(____params_startLine_143) -- 4034
			local ____params_endLine_144 = params.endLine -- 4035
			if ____params_endLine_144 == nil then -- 4035
				____params_endLine_144 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4035
			end -- 4035
			local endLine = __TS__Number(____params_endLine_144) -- 4035
			local clippedAfterCompression = false -- 4036
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4036
				endLine = startLine + 159 -- 4043
				clippedAfterCompression = true -- 4044
			end -- 4044
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4046
			if __TS__StringTrim(path) == "" then -- 4046
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4046
			end -- 4046
			local result = Tools.readFile( -- 4050
				shared.workingDir, -- 4051
				path, -- 4052
				startLine, -- 4053
				endLine, -- 4054
				shared.useChineseResponse and "zh" or "en" -- 4055
			) -- 4055
			if clippedAfterCompression and result.success == true then -- 4055
				result.clipped = true -- 4058
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4059
			end -- 4059
			return ____awaiter_resolve(nil, result) -- 4059
		end -- 4059
		if action.tool == "grep_files" then -- 4059
			local searchPath = params.path or "" -- 4066
			local searchGlobs = params.globs -- 4067
			local ____Tools_searchFiles_158 = Tools.searchFiles -- 4068
			local ____shared_workingDir_151 = shared.workingDir -- 4069
			local ____temp_152 = params.pattern or "" -- 4071
			local ____params_globs_153 = params.globs -- 4072
			local ____params_useRegex_154 = params.useRegex -- 4073
			local ____params_caseSensitive_155 = params.caseSensitive -- 4074
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4076
			local ____math_max_147 = math.max -- 4077
			local ____math_floor_146 = math.floor -- 4077
			local ____params_limit_145 = params.limit -- 4077
			if ____params_limit_145 == nil then -- 4077
				____params_limit_145 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4077
			end -- 4077
			local ____math_max_147_result_157 = ____math_max_147( -- 4077
				1, -- 4077
				____math_floor_146(__TS__Number(____params_limit_145)) -- 4077
			) -- 4077
			local ____math_max_150 = math.max -- 4078
			local ____math_floor_149 = math.floor -- 4078
			local ____params_offset_148 = params.offset -- 4078
			if ____params_offset_148 == nil then -- 4078
				____params_offset_148 = 0 -- 4078
			end -- 4078
			local result = __TS__Await(____Tools_searchFiles_158({ -- 4068
				workDir = ____shared_workingDir_151, -- 4069
				path = searchPath, -- 4070
				pattern = ____temp_152, -- 4071
				globs = ____params_globs_153, -- 4072
				useRegex = ____params_useRegex_154, -- 4073
				caseSensitive = ____params_caseSensitive_155, -- 4074
				includeContent = true, -- 4075
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156, -- 4076
				limit = ____math_max_147_result_157, -- 4077
				offset = ____math_max_150( -- 4078
					0, -- 4078
					____math_floor_149(__TS__Number(____params_offset_148)) -- 4078
				), -- 4078
				groupByFile = params.groupByFile == true -- 4079
			})) -- 4079
			return ____awaiter_resolve(nil, result) -- 4079
		end -- 4079
		if action.tool == "search_dora_api" then -- 4079
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4084
			local ____Tools_searchDoraAPI_167 = Tools.searchDoraAPI -- 4085
			local ____temp_163 = params.pattern or "" -- 4086
			local ____temp_164 = params.docSource or "api" -- 4087
			local ____temp_165 = shared.useChineseResponse and "zh" or "en" -- 4088
			local ____temp_166 = params.programmingLanguage or "ts" -- 4089
			local ____math_min_162 = math.min -- 4090
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4090
			local ____math_max_160 = math.max -- 4090
			local ____params_limit_159 = params.limit -- 4090
			if ____params_limit_159 == nil then -- 4090
				____params_limit_159 = 8 -- 4090
			end -- 4090
			local result = __TS__Await(____Tools_searchDoraAPI_167({ -- 4085
				pattern = ____temp_163, -- 4086
				docSource = ____temp_164, -- 4087
				docLanguage = ____temp_165, -- 4088
				programmingLanguage = ____temp_166, -- 4089
				limit = ____math_min_162( -- 4090
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161, -- 4090
					____math_max_160( -- 4090
						1, -- 4090
						__TS__Number(____params_limit_159) -- 4090
					) -- 4090
				), -- 4090
				useRegex = params.useRegex, -- 4091
				caseSensitive = false, -- 4092
				includeContent = true, -- 4093
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4094
			})) -- 4094
			return ____awaiter_resolve(nil, result) -- 4094
		end -- 4094
		if action.tool == "glob_files" then -- 4094
			local ____Tools_listFiles_174 = Tools.listFiles -- 4099
			local ____shared_workingDir_171 = shared.workingDir -- 4100
			local ____temp_172 = params.path or "" -- 4101
			local ____params_globs_173 = params.globs -- 4102
			local ____math_max_170 = math.max -- 4103
			local ____math_floor_169 = math.floor -- 4103
			local ____params_maxEntries_168 = params.maxEntries -- 4103
			if ____params_maxEntries_168 == nil then -- 4103
				____params_maxEntries_168 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4103
			end -- 4103
			local result = ____Tools_listFiles_174({ -- 4099
				workDir = ____shared_workingDir_171, -- 4100
				path = ____temp_172, -- 4101
				globs = ____params_globs_173, -- 4102
				maxEntries = ____math_max_170( -- 4103
					1, -- 4103
					____math_floor_169(__TS__Number(____params_maxEntries_168)) -- 4103
				) -- 4103
			}) -- 4103
			return ____awaiter_resolve(nil, result) -- 4103
		end -- 4103
		if action.tool == "ask_user" then -- 4103
			if not shared.publishQuestionnaire then -- 4103
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4103
			end -- 4103
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4103
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4103
			end -- 4103
			local normalized = normalizeQuestionnaire(params) -- 4110
			if not normalized.success then -- 4110
				return ____awaiter_resolve(nil, normalized) -- 4110
			end -- 4110
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4112
			if not result.success then -- 4112
				return ____awaiter_resolve(nil, result) -- 4112
			end -- 4112
			shared.waitingQuestionnaireId = result.questionnaireId -- 4119
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4119
		end -- 4119
		if action.tool == "delete_file" then -- 4119
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4123
			if __TS__StringTrim(targetFile) == "" then -- 4123
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4123
			end -- 4123
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4127
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4128
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4128
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4128
			end -- 4128
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4132
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4133
			if not result.success then -- 4133
				return ____awaiter_resolve(nil, result) -- 4133
			end -- 4133
			if not isInternalDocumentEdit then -- 4133
				shared.unbuiltEdits = true -- 4141
				shared.lastBuildSucceeded = false -- 4142
				if shared.failedTestNeedsBuild == true then -- 4142
					shared.failedTestHasSourceEdit = true -- 4143
				end -- 4143
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4143
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4144
				end -- 4144
				shared.editedPathsSinceBuild = editedPaths -- 4145
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4146
			end -- 4146
			return ____awaiter_resolve(nil, { -- 4146
				success = true, -- 4149
				changed = true, -- 4150
				mode = "delete", -- 4151
				checkpointId = result.checkpointId, -- 4152
				checkpointSeq = result.checkpointSeq, -- 4153
				files = {{path = targetFile, op = "delete"}} -- 4154
			}) -- 4154
		end -- 4154
		if action.tool == "build" then -- 4154
			local buildPath = params.path or "" -- 4158
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4159
			shared.unbuiltEdits = false -- 4163
			shared.editsSinceBuild = 0 -- 4164
			shared.editedPathsSinceBuild = {} -- 4165
			shared.hasBuilt = true -- 4166
			shared.lastBuildSucceeded = result.success -- 4167
			if result.success and shared.freshProjectBuildPending == true then -- 4167
				shared.freshProjectBuildPending = false -- 4173
			end -- 4173
			shared.apiSearchesSinceBuild = 0 -- 4175
			shared.buildRepairPending = false -- 4176
			if not result.success and result.messages ~= nil then -- 4176
				do -- 4176
					local i = 0 -- 4178
					while i < #result.messages do -- 4178
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4178
							shared.buildRepairPending = true -- 4180
							break -- 4181
						end -- 4181
						i = i + 1 -- 4178
					end -- 4178
				end -- 4178
			end -- 4178
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4178
				shared.failedTestNeedsBuild = false -- 4186
				shared.failedTestHasSourceEdit = false -- 4187
			end -- 4187
			return ____awaiter_resolve(nil, result) -- 4187
		end -- 4187
		if action.tool == "fetch_url" then -- 4187
			local result = __TS__Await(Tools.fetchUrl({ -- 4192
				workDir = shared.workingDir, -- 4193
				url = type(params.url) == "string" and params.url or "", -- 4194
				target = type(params.target) == "string" and params.target or "", -- 4195
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4196
				onProgress = function(____, progress) -- 4197
					emitAgentEvent( -- 4198
						shared, -- 4198
						{ -- 4198
							type = "tool_progress", -- 4199
							sessionId = shared.sessionId, -- 4200
							taskId = shared.taskId, -- 4201
							step = action.step, -- 4202
							tool = action.tool, -- 4203
							result = __TS__ObjectAssign({success = false}, progress) -- 4204
						} -- 4204
					) -- 4204
				end -- 4197
			})) -- 4197
			return ____awaiter_resolve(nil, result) -- 4197
		end -- 4197
		if action.tool == "execute_command" then -- 4197
			local mode = type(params.mode) == "string" and params.mode or "" -- 4214
			local result = __TS__Await(Tools.executeCommand({ -- 4215
				workDir = shared.workingDir, -- 4216
				mode = mode, -- 4217
				code = type(params.code) == "string" and params.code or nil, -- 4218
				command = type(params.command) == "string" and params.command or nil, -- 4219
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4220
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4221
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4222
				onProgress = function(____, progress) -- 4223
					emitAgentEvent( -- 4224
						shared, -- 4224
						{ -- 4224
							type = "tool_progress", -- 4225
							sessionId = shared.sessionId, -- 4226
							taskId = shared.taskId, -- 4227
							step = action.step, -- 4228
							tool = action.tool, -- 4229
							result = __TS__ObjectAssign({success = false}, progress) -- 4230
						} -- 4230
					) -- 4230
				end -- 4223
			})) -- 4223
			if result.success and mode == "lua" then -- 4223
				local deterministicFailure = false -- 4238
				local deterministicPass = false -- 4239
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4240
				do -- 4240
					local i = 0 -- 4241
					while i < #outputLines and not deterministicFailure do -- 4241
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4242
						if line == "passed" then -- 4242
							deterministicPass = true -- 4243
						end -- 4243
						if line == "failed" then -- 4243
							deterministicFailure = true -- 4245
							break -- 4246
						end -- 4246
						local searchFrom = 0 -- 4248
						while searchFrom < #line do -- 4248
							local failedIndex = (string.find( -- 4250
								line, -- 4250
								"failed", -- 4250
								math.max(searchFrom + 1, 1), -- 4250
								true -- 4250
							) or 0) - 1 -- 4250
							if failedIndex < 0 then -- 4250
								break -- 4251
							end -- 4251
							local after = failedIndex + #"failed" -- 4252
							while after < #line do -- 4252
								local ch = __TS__StringSlice(line, after, after + 1) -- 4254
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4254
									break -- 4255
								end -- 4255
								after = after + 1 -- 4256
							end -- 4256
							local afterEnd = after -- 4258
							while afterEnd < #line do -- 4258
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4260
								if ch < "0" or ch > "9" then -- 4260
									break -- 4261
								end -- 4261
								afterEnd = afterEnd + 1 -- 4262
							end -- 4262
							local count -- 4264
							if afterEnd > after then -- 4264
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4266
							else -- 4266
								local before = failedIndex - 1 -- 4268
								while before >= 0 do -- 4268
									local ch = __TS__StringSlice(line, before, before + 1) -- 4270
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4270
										break -- 4271
									end -- 4271
									before = before - 1 -- 4272
								end -- 4272
								local beforeEnd = before + 1 -- 4274
								while before >= 0 do -- 4274
									local ch = __TS__StringSlice(line, before, before + 1) -- 4276
									if ch < "0" or ch > "9" then -- 4276
										break -- 4277
									end -- 4277
									before = before - 1 -- 4278
								end -- 4278
								if beforeEnd > before + 1 then -- 4278
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4280
								end -- 4280
							end -- 4280
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4280
								deterministicFailure = true -- 4283
								break -- 4284
							end -- 4284
							searchFrom = failedIndex + #"failed" -- 4286
						end -- 4286
						i = i + 1 -- 4241
					end -- 4241
				end -- 4241
				if deterministicFailure then -- 4241
					shared.failedTestNeedsBuild = true -- 4290
					shared.failedTestHasSourceEdit = false -- 4291
				elseif deterministicPass then -- 4291
					shared.failedTestNeedsBuild = false -- 4293
					shared.failedTestHasSourceEdit = false -- 4294
				end -- 4294
			end -- 4294
			return ____awaiter_resolve(nil, result) -- 4294
		end -- 4294
		if action.tool == "spawn_sub_agent" then -- 4294
			if not shared.spawnSubAgent then -- 4294
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4294
			end -- 4294
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4294
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4294
			end -- 4294
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4306
				params.filesHint, -- 4307
				function(____, item) return type(item) == "string" end -- 4307
			) or nil -- 4307
			local result = __TS__Await(shared.spawnSubAgent({ -- 4309
				parentSessionId = shared.sessionId, -- 4310
				projectRoot = shared.workingDir, -- 4311
				title = type(params.title) == "string" and params.title or "Sub", -- 4312
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4313
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4314
				filesHint = filesHint, -- 4315
				disabledAgentTools = shared.disabledAgentTools -- 4316
			})) -- 4316
			if not result.success then -- 4316
				return ____awaiter_resolve(nil, result) -- 4316
			end -- 4316
			shared.hasSpawnedSubAgentThisTask = true -- 4321
			return ____awaiter_resolve(nil, { -- 4321
				success = true, -- 4323
				sessionId = result.sessionId, -- 4324
				taskId = result.taskId, -- 4325
				title = result.title, -- 4326
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4327
			}) -- 4327
		end -- 4327
		if action.tool == "list_sub_agents" then -- 4327
			if not shared.listSubAgents then -- 4327
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4327
			end -- 4327
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4327
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4327
			end -- 4327
			local result = __TS__Await(shared.listSubAgents({ -- 4337
				sessionId = shared.sessionId, -- 4338
				projectRoot = shared.workingDir, -- 4339
				status = type(params.status) == "string" and params.status or nil, -- 4340
				limit = type(params.limit) == "number" and params.limit or nil, -- 4341
				offset = type(params.offset) == "number" and params.offset or nil, -- 4342
				query = type(params.query) == "string" and params.query or nil -- 4343
			})) -- 4343
			return ____awaiter_resolve(nil, result) -- 4343
		end -- 4343
		if action.tool == "edit_file" then -- 4343
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4348
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4351
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4352
			if __TS__StringTrim(path) == "" then -- 4352
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4352
			end -- 4352
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4354
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4355
			if not isInternalDocumentEdit then -- 4355
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4357
				if preflightIssue ~= nil then -- 4357
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4359
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4360
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4360
				end -- 4360
			end -- 4360
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4366
			local result = __TS__Await(actionNode:exec({ -- 4367
				path = path, -- 4368
				oldStr = oldStr, -- 4369
				newStr = newStr, -- 4370
				taskId = shared.taskId, -- 4371
				workDir = shared.workingDir -- 4372
			})) -- 4372
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4372
				if params.partialStreamRecovery ~= true then -- 4372
					shared.truncatedToolOverwritePath = nil -- 4376
				end -- 4376
				shared.unbuiltEdits = true -- 4378
				shared.lastBuildSucceeded = false -- 4379
				if shared.failedTestNeedsBuild == true then -- 4379
					shared.failedTestHasSourceEdit = true -- 4380
				end -- 4380
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4381
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4381
					editedPaths[#editedPaths + 1] = normalizedPath -- 4382
				end -- 4382
				shared.editedPathsSinceBuild = editedPaths -- 4383
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4384
			end -- 4384
			return ____awaiter_resolve(nil, result) -- 4384
		end -- 4384
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4384
	end) -- 4384
end -- 4384
function sanitizeToolActionResultForHistory(action, result) -- 4391
	if action.tool == "read_file" then -- 4391
		return sanitizeReadResultForHistory(action.tool, result) -- 4393
	end -- 4393
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4393
		return sanitizeSearchResultForHistory(action.tool, result) -- 4396
	end -- 4396
	if action.tool == "glob_files" then -- 4396
		return sanitizeListFilesResultForHistory(result) -- 4399
	end -- 4399
	if action.tool == "build" then -- 4399
		return sanitizeBuildResultForHistory(result) -- 4402
	end -- 4402
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4402
		if result.success ~= true then -- 4402
			return result -- 4405
		end -- 4405
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4405
			return result -- 4406
		end -- 4406
		if isArray(result.fileContext) then -- 4406
			return result -- 4407
		end -- 4407
		local contextLimits = { -- 4409
			fullContentChars = 12000, -- 4410
			previewChars = 4000, -- 4411
			diffChars = 8000, -- 4412
			totalChars = 24000, -- 4413
			maxFiles = 8 -- 4414
		} -- 4414
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4416
			if maxChars <= 0 then -- 4416
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4417
			end -- 4417
			if #sourceText <= maxChars then -- 4417
				return sourceText -- 4418
			end -- 4418
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4419
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4420
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4421
		end -- 4416
		local function countLines(sourceText) -- 4423
			if sourceText == "" then -- 4423
				return 0 -- 4424
			end -- 4424
			return #__TS__StringSplit(sourceText, "\n") -- 4425
		end -- 4423
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4427
			if beforeContent == afterContent then -- 4427
				return "" -- 4428
			end -- 4428
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4429
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4430
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4432
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4432
				firstChangedLine = firstChangedLine + 1 -- 4438
			end -- 4438
			local lastChangedBeforeLine = #beforeLines - 1 -- 4440
			local lastChangedAfterLine = #afterLines - 1 -- 4441
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4441
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4447
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4448
			end -- 4448
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4450
			local previewEndLine = math.max( -- 4451
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4452
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4453
			) -- 4453
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4455
			do -- 4455
				local lineIndex = previewStartLine -- 4456
				while lineIndex <= previewEndLine do -- 4456
					do -- 4456
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4457
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4458
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4459
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4460
						if not beforeChanged and not afterChanged then -- 4460
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4462
							if contextLine ~= nil then -- 4462
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4463
							end -- 4463
							goto __continue733 -- 4464
						end -- 4464
						if beforeChanged and beforeLine ~= nil then -- 4464
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4466
						end -- 4466
						if afterChanged and afterLine ~= nil then -- 4466
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4467
						end -- 4467
					end -- 4467
					::__continue733:: -- 4467
					lineIndex = lineIndex + 1 -- 4456
				end -- 4456
			end -- 4456
			return truncateContextSnippet( -- 4469
				table.concat(unifiedDiffLines, "\n"), -- 4469
				maxChars, -- 4469
				"diff" -- 4469
			) -- 4469
		end -- 4427
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4472
		if not checkpointDiff.success then -- 4472
			return result -- 4473
		end -- 4473
		local remainingContextBudget = contextLimits.totalChars -- 4474
		local fileContextItems = {} -- 4475
		local changedFiles = checkpointDiff.files -- 4476
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4477
		do -- 4477
			local fileIndex = 0 -- 4478
			while fileIndex < maxContextFiles do -- 4478
				if remainingContextBudget <= 0 then -- 4478
					break -- 4479
				end -- 4479
				local changedFile = changedFiles[fileIndex + 1] -- 4480
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4481
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4482
				local contextItem = { -- 4483
					path = changedFile.path, -- 4484
					op = changedFile.op, -- 4485
					checkpointId = result.checkpointId, -- 4486
					checkpointSeq = result.checkpointSeq, -- 4487
					beforeExists = changedFile.beforeExists, -- 4488
					afterExists = changedFile.afterExists, -- 4489
					beforeBytes = #beforeContent, -- 4490
					afterBytes = #afterContent, -- 4491
					diffPreview = "", -- 4492
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4493
					contentTruncated = false, -- 4494
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4495
				} -- 4495
				if changedFile.afterExists then -- 4495
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4495
						contextItem.afterContent = afterContent -- 4499
						remainingContextBudget = remainingContextBudget - #afterContent -- 4500
					else -- 4500
						contextItem.afterContentPreview = truncateContextSnippet( -- 4502
							afterContent, -- 4503
							math.min( -- 4504
								contextLimits.previewChars, -- 4504
								math.max(400, remainingContextBudget) -- 4504
							), -- 4504
							"afterContent" -- 4505
						) -- 4505
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4507
						contextItem.contentTruncated = true -- 4508
					end -- 4508
				end -- 4508
				local diffPreview = buildUnifiedDiffPreview( -- 4511
					changedFile.path, -- 4512
					beforeContent, -- 4513
					afterContent, -- 4514
					math.min( -- 4515
						contextLimits.diffChars, -- 4515
						math.max(400, remainingContextBudget) -- 4515
					) -- 4515
				) -- 4515
				contextItem.diffPreview = diffPreview -- 4517
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4518
				if not changedFile.afterExists and beforeContent ~= "" then -- 4518
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4520
						beforeContent, -- 4521
						math.min( -- 4522
							contextLimits.previewChars, -- 4522
							math.max(400, remainingContextBudget) -- 4522
						), -- 4522
						"beforeContent" -- 4523
					) -- 4523
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4525
					if #beforeContent > contextLimits.previewChars then -- 4525
						contextItem.contentTruncated = true -- 4526
					end -- 4526
				end -- 4526
				fileContextItems[#fileContextItems + 1] = contextItem -- 4528
				fileIndex = fileIndex + 1 -- 4478
			end -- 4478
		end -- 4478
		if #fileContextItems == 0 then -- 4478
			return result -- 4530
		end -- 4530
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4531
	end -- 4531
	return result -- 4538
end -- 4538
function emitAgentTaskFinishEvent(shared, success, message) -- 4739
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4740
	local result = success and ({ -- 4744
		success = true, -- 4746
		taskId = shared.taskId, -- 4747
		message = message, -- 4748
		steps = shared.step, -- 4749
		completion = completion -- 4750
	}) or ({ -- 4750
		success = false, -- 4753
		taskId = shared.taskId, -- 4754
		message = message, -- 4755
		steps = shared.step, -- 4756
		completion = completion -- 4757
	}) -- 4757
	emitAgentEvent(shared, { -- 4759
		type = "task_finished", -- 4760
		sessionId = shared.sessionId, -- 4761
		taskId = shared.taskId, -- 4762
		success = result.success, -- 4763
		message = result.message, -- 4764
		steps = result.steps, -- 4765
		completion = result.completion -- 4766
	}) -- 4766
	return result -- 4768
end -- 4768
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
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2767
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2776
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2777
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2785
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2786
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2787
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2795
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2803
		shared.role, -- 2803
		{ -- 2803
			includeFinish = true, -- 2804
			includeXmlRules = true, -- 2805
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2806
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2807
			workMode = shared.workMode -- 2808
		} -- 2808
	) -- 2808
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2810
	local repairPrompt = replacePromptVars( -- 2813
		shared.promptPack.xmlDecisionRepairPrompt, -- 2813
		{ -- 2813
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2814
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2815
			CANDIDATE_SECTION = candidateSection, -- 2816
			LAST_ERROR = lastError, -- 2817
			ATTEMPT = tostring(attempt) -- 2818
		} -- 2818
	) -- 2818
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2820
end -- 2767
local MainDecisionAgent = __TS__Class() -- 2858
MainDecisionAgent.name = "MainDecisionAgent" -- 2858
__TS__ClassExtends(MainDecisionAgent, Node) -- 2858
function MainDecisionAgent.prototype.prep(self, shared) -- 2859
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2859
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2859
			return ____awaiter_resolve(nil, {shared = shared}) -- 2859
		end -- 2859
		__TS__Await(maybeCompressHistory(shared)) -- 2864
		return ____awaiter_resolve(nil, {shared = shared}) -- 2864
	end) -- 2864
end -- 2859
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2869
	local preExecuted = shared.preExecutedResults -- 2870
	if not preExecuted or preExecuted.size == 0 then -- 2870
		return nil -- 2871
	end -- 2871
	local decisions = {} -- 2872
	preExecuted:forEach(function(____, preResult) -- 2873
		local action = preResult.action -- 2874
		decisions[#decisions + 1] = { -- 2875
			success = true, -- 2876
			tool = action.tool, -- 2877
			params = action.params, -- 2878
			toolCallId = action.toolCallId, -- 2879
			reason = action.reason, -- 2880
			reasoningContent = action.reasoningContent -- 2881
		} -- 2881
	end) -- 2873
	if #decisions == 0 then -- 2873
		return nil -- 2884
	end -- 2884
	AgentUtils.Log( -- 2885
		"Warn", -- 2885
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2885
			__TS__ArrayMap( -- 2885
				decisions, -- 2885
				function(____, decision) return decision.tool end -- 2885
			), -- 2885
			"," -- 2885
		) -- 2885
	) -- 2885
	if #decisions == 1 then -- 2885
		return decisions[1] -- 2887
	end -- 2887
	return {success = true, kind = "batch", decisions = decisions} -- 2889
end -- 2869
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2896
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2901
	if not recovery then -- 2901
		return nil -- 2902
	end -- 2902
	shared.truncatedToolOverwritePath = recovery.target -- 2903
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2904
	return { -- 2905
		success = true, -- 2906
		tool = "edit_file", -- 2907
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2908
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2914
		reason = recovery.reason, -- 2915
		reasoningContent = reasoningContent -- 2916
	} -- 2916
end -- 2896
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2920
	if attempt == nil then -- 2920
		attempt = 1 -- 2923
	end -- 2923
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2923
		if shared.stopToken.stopped then -- 2923
			return ____awaiter_resolve( -- 2923
				nil, -- 2923
				{ -- 2927
					success = false, -- 2927
					message = getCancelledReason(shared) -- 2927
				} -- 2927
			) -- 2927
		end -- 2927
		AgentUtils.Log( -- 2929
			"Info", -- 2929
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2929
		) -- 2929
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2930
			shared.role, -- 2930
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2930
			{ -- 2930
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2931
				workMode = shared.workMode -- 2932
			} -- 2932
		) -- 2932
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2934
		local stepId = shared.step + 1 -- 2935
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2936
			string.lower(shared.llmConfig.model), -- 2936
			"glm-5.2" -- 2936
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2936
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2939
		emitLLMContextMetrics( -- 2944
			shared, -- 2944
			stepId, -- 2944
			"decision_tool_calling", -- 2944
			messages, -- 2944
			llmOptions -- 2944
		) -- 2944
		saveStepLLMDebugInput( -- 2945
			shared, -- 2945
			stepId, -- 2945
			"decision_tool_calling", -- 2945
			messages, -- 2945
			llmOptions -- 2945
		) -- 2945
		local lastStreamContent = "" -- 2946
		local lastStreamReasoning = "" -- 2947
		local preExecutedResults = __TS__New(Map) -- 2948
		shared.preExecutedResults = preExecutedResults -- 2949
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2950
			messages, -- 2951
			llmOptions, -- 2952
			shared.stopToken, -- 2953
			shared.llmConfig, -- 2954
			function(response) -- 2955
				local ____opt_75 = response.choices -- 2955
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2955
				local streamMessage = ____opt_73 and ____opt_73.message -- 2956
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2957
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2960
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2960
					return -- 2964
				end -- 2964
				lastStreamContent = nextContent -- 2966
				lastStreamReasoning = nextReasoning -- 2967
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2968
			end, -- 2955
			function(tc) -- 2970
				if shared.stopToken.stopped then -- 2970
					return -- 2971
				end -- 2971
				local action = createPreExecutableActionFromStream(shared, tc) -- 2972
				if not action or preExecutedResults:has(action.toolCallId) then -- 2972
					return -- 2973
				end -- 2973
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2974
				preExecutedResults:set( -- 2975
					action.toolCallId, -- 2975
					createPreExecutedToolResult(shared, action) -- 2975
				) -- 2975
			end -- 2970
		)) -- 2970
		if shared.stopToken.stopped then -- 2970
			clearPreExecutedResults(shared) -- 2979
			return ____awaiter_resolve( -- 2979
				nil, -- 2979
				{ -- 2980
					success = false, -- 2980
					message = getCancelledReason(shared) -- 2980
				} -- 2980
			) -- 2980
		end -- 2980
		if not res.success then -- 2980
			local usage = res.tokenUsage -- 2983
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2984
			saveStepLLMDebugOutput( -- 2985
				shared, -- 2985
				stepId, -- 2985
				"decision_tool_calling", -- 2985
				res.raw or res.message, -- 2985
				{success = false, usage = usage} -- 2985
			) -- 2985
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2986
			local committed = self:commitPreExecutedDecision(shared) -- 2987
			if committed then -- 2987
				return ____awaiter_resolve(nil, committed) -- 2987
			end -- 2987
			local ____opt_83 = res.response -- 2987
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2987
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2989
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 2990
			local ____shared_93 = shared -- 2991
			local ____opt_85 = partialChoice and partialChoice.message -- 2991
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 2992
			local ____opt_89 = partialChoice and partialChoice.message -- 2992
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 2990
			if partialDraft then -- 2990
				return ____awaiter_resolve(nil, partialDraft) -- 2990
			end -- 2990
			clearPreExecutedResults(shared) -- 2996
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2996
		end -- 2996
		local usage = res.tokenUsage -- 2999
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3000
		saveStepLLMDebugOutput( -- 3001
			shared, -- 3001
			stepId, -- 3001
			"decision_tool_calling", -- 3001
			encodeDebugJSON(res.response), -- 3001
			{success = true, usage = usage} -- 3001
		) -- 3001
		local choice = res.response.choices and res.response.choices[1] -- 3002
		local message = choice and choice.message -- 3003
		local toolCalls = message and message.tool_calls -- 3004
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3005
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3008
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3011
		AgentUtils.Log( -- 3014
			"Info", -- 3014
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3014
		) -- 3014
		if finishReason == "length" then -- 3014
			local committed = self:commitPreExecutedDecision(shared) -- 3016
			if committed then -- 3016
				return ____awaiter_resolve(nil, committed) -- 3016
			end -- 3016
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3018
			if partialDraft then -- 3018
				return ____awaiter_resolve(nil, partialDraft) -- 3018
			end -- 3018
			AgentUtils.Log( -- 3020
				"Error", -- 3020
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3020
			) -- 3020
			clearPreExecutedResults(shared) -- 3021
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3021
		end -- 3021
		if not toolCalls or #toolCalls == 0 then -- 3021
			if messageContent and messageContent ~= "" then -- 3021
				if isFinalDecisionTurn(shared) then -- 3021
					clearPreExecutedResults(shared) -- 3031
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3031
				end -- 3031
				if shared.role == "sub" then -- 3031
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3039
					clearPreExecutedResults(shared) -- 3040
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3040
				end -- 3040
				AgentUtils.Log( -- 3047
					"Info", -- 3047
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3047
				) -- 3047
				clearPreExecutedResults(shared) -- 3048
				return ____awaiter_resolve(nil, { -- 3048
					success = true, -- 3050
					tool = "finish", -- 3051
					params = {}, -- 3052
					reason = messageContent, -- 3053
					reasoningContent = reasoningContent, -- 3054
					directSummary = messageContent -- 3055
				}) -- 3055
			end -- 3055
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3058
			clearPreExecutedResults(shared) -- 3059
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3059
		end -- 3059
		local decisions = {} -- 3066
		do -- 3066
			local i = 0 -- 3067
			while i < #toolCalls do -- 3067
				local toolCall = toolCalls[i + 1] -- 3068
				local fn = toolCall ~= nil and toolCall["function"] -- 3069
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3069
					AgentUtils.Log( -- 3071
						"Error", -- 3071
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3071
					) -- 3071
					clearPreExecutedResults(shared) -- 3072
					return ____awaiter_resolve( -- 3072
						nil, -- 3072
						{ -- 3073
							success = false, -- 3074
							message = "missing function name for tool call " .. tostring(i + 1), -- 3075
							raw = messageContent -- 3076
						} -- 3076
					) -- 3076
				end -- 3076
				local functionName = fn.name -- 3079
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3080
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3081
				AgentUtils.Log( -- 3084
					"Info", -- 3084
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3084
				) -- 3084
				local decision = parseAndValidateToolCallDecision( -- 3085
					shared, -- 3086
					functionName, -- 3087
					argsText, -- 3088
					toolCallId, -- 3089
					messageContent, -- 3090
					reasoningContent -- 3091
				) -- 3091
				if not decision.success then -- 3091
					AgentUtils.Log( -- 3094
						"Error", -- 3094
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3094
					) -- 3094
					clearPreExecutedResults(shared) -- 3095
					return ____awaiter_resolve(nil, decision) -- 3095
				end -- 3095
				decisions[#decisions + 1] = decision -- 3098
				i = i + 1 -- 3067
			end -- 3067
		end -- 3067
		if #decisions == 1 then -- 3067
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3101
			return ____awaiter_resolve(nil, decisions[1]) -- 3101
		end -- 3101
		do -- 3101
			local i = 0 -- 3104
			while i < #decisions do -- 3104
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3104
					clearPreExecutedResults(shared) -- 3106
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3106
				end -- 3106
				i = i + 1 -- 3104
			end -- 3104
		end -- 3104
		AgentUtils.Log( -- 3114
			"Info", -- 3114
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3114
				__TS__ArrayMap( -- 3114
					decisions, -- 3114
					function(____, decision) return decision.tool end -- 3114
				), -- 3114
				"," -- 3114
			) -- 3114
		) -- 3114
		return ____awaiter_resolve(nil, { -- 3114
			success = true, -- 3116
			kind = "batch", -- 3117
			decisions = decisions, -- 3118
			content = messageContent, -- 3119
			reasoningContent = reasoningContent -- 3120
		}) -- 3120
	end) -- 3120
end -- 2920
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3124
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3124
		AgentUtils.Log( -- 3130
			"Info", -- 3130
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3130
		) -- 3130
		local lastError = initialError -- 3131
		local candidateRaw = "" -- 3132
		local candidateReasoning = nil -- 3133
		do -- 3133
			local attempt = 0 -- 3134
			while attempt < shared.llmMaxTry do -- 3134
				do -- 3134
					AgentUtils.Log( -- 3135
						"Info", -- 3135
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3135
					) -- 3135
					local messages = buildXmlRepairMessages( -- 3136
						shared, -- 3137
						originalRaw, -- 3138
						originalReasoning, -- 3139
						candidateRaw, -- 3140
						candidateReasoning, -- 3141
						lastError, -- 3142
						attempt + 1 -- 3143
					) -- 3143
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3145
					if shared.stopToken.stopped then -- 3145
						return ____awaiter_resolve( -- 3145
							nil, -- 3145
							{ -- 3147
								success = false, -- 3147
								message = getCancelledReason(shared) -- 3147
							} -- 3147
						) -- 3147
					end -- 3147
					if not llmRes.success then -- 3147
						lastError = llmRes.message -- 3150
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3151
						goto __continue530 -- 3152
					end -- 3152
					candidateRaw = llmRes.text -- 3154
					candidateReasoning = llmRes.reasoningContent -- 3155
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3156
					if decision.success then -- 3156
						decision.reasoningContent = llmRes.reasoningContent -- 3158
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3159
						return ____awaiter_resolve(nil, decision) -- 3159
					end -- 3159
					lastError = decision.message -- 3162
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3163
				end -- 3163
				::__continue530:: -- 3163
				attempt = attempt + 1 -- 3134
			end -- 3134
		end -- 3134
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3165
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3165
	end) -- 3165
end -- 3124
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3173
	if attempt == nil then -- 3173
		attempt = 1 -- 3176
	end -- 3176
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3176
		local messages = buildDecisionMessages( -- 3179
			shared, -- 3180
			lastError, -- 3181
			attempt, -- 3182
			lastRaw, -- 3183
			"xml" -- 3184
		) -- 3184
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3186
		if shared.stopToken.stopped then -- 3186
			return ____awaiter_resolve( -- 3186
				nil, -- 3186
				{ -- 3188
					success = false, -- 3188
					message = getCancelledReason(shared) -- 3188
				} -- 3188
			) -- 3188
		end -- 3188
		if not llmRes.success then -- 3188
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3188
		end -- 3188
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3197
		if decision.success then -- 3197
			decision.reasoningContent = llmRes.reasoningContent -- 3199
			return ____awaiter_resolve(nil, decision) -- 3199
		end -- 3199
		return ____awaiter_resolve( -- 3199
			nil, -- 3199
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3202
		) -- 3202
	end) -- 3202
end -- 3173
function MainDecisionAgent.prototype.exec(self, input) -- 3205
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3205
		local shared = input.shared -- 3206
		if shared.stopToken.stopped then -- 3206
			return ____awaiter_resolve( -- 3206
				nil, -- 3206
				{ -- 3208
					success = false, -- 3208
					message = getCancelledReason(shared) -- 3208
				} -- 3208
			) -- 3208
		end -- 3208
		if shared.agentStepCount >= shared.maxSteps then -- 3208
			AgentUtils.Log( -- 3211
				"Warn", -- 3211
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3211
			) -- 3211
			return ____awaiter_resolve( -- 3211
				nil, -- 3211
				{ -- 3212
					success = false, -- 3212
					message = getMaxStepsReachedReason(shared) -- 3212
				} -- 3212
			) -- 3212
		end -- 3212
		if shared.decisionMode == "tool_calling" then -- 3212
			AgentUtils.Log( -- 3216
				"Info", -- 3216
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3216
			) -- 3216
			local lastError = "tool calling validation failed" -- 3217
			local lastRaw = "" -- 3218
			local shouldFallbackToXml = false -- 3219
			do -- 3219
				local attempt = 0 -- 3220
				while attempt < shared.llmMaxTry do -- 3220
					AgentUtils.Log( -- 3221
						"Info", -- 3221
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3221
					) -- 3221
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3222
					if shared.stopToken.stopped then -- 3222
						return ____awaiter_resolve( -- 3222
							nil, -- 3222
							{ -- 3229
								success = false, -- 3229
								message = getCancelledReason(shared) -- 3229
							} -- 3229
						) -- 3229
					end -- 3229
					if decision.success then -- 3229
						return ____awaiter_resolve(nil, decision) -- 3229
					end -- 3229
					lastError = decision.message -- 3234
					lastRaw = decision.raw or "" -- 3235
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3236
					if lastError == "missing tool call" then -- 3236
						shouldFallbackToXml = true -- 3238
						break -- 3239
					end -- 3239
					attempt = attempt + 1 -- 3220
				end -- 3220
			end -- 3220
			if shouldFallbackToXml then -- 3220
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3243
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3244
				do -- 3244
					local attempt = 0 -- 3245
					while attempt < shared.llmMaxTry do -- 3245
						AgentUtils.Log( -- 3246
							"Info", -- 3246
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3246
						) -- 3246
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3247
						if shared.stopToken.stopped then -- 3247
							return ____awaiter_resolve( -- 3247
								nil, -- 3247
								{ -- 3254
									success = false, -- 3254
									message = getCancelledReason(shared) -- 3254
								} -- 3254
							) -- 3254
						end -- 3254
						if decision.success then -- 3254
							return ____awaiter_resolve(nil, decision) -- 3254
						end -- 3254
						lastError = decision.message -- 3259
						lastRaw = decision.raw or "" -- 3260
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3261
						attempt = attempt + 1 -- 3245
					end -- 3245
				end -- 3245
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3263
				return ____awaiter_resolve( -- 3263
					nil, -- 3263
					{ -- 3264
						success = false, -- 3264
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3264
					} -- 3264
				) -- 3264
			end -- 3264
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3266
			return ____awaiter_resolve( -- 3266
				nil, -- 3266
				{ -- 3267
					success = false, -- 3267
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3267
				} -- 3267
			) -- 3267
		end -- 3267
		local lastError = "xml validation failed" -- 3270
		local lastRaw = "" -- 3271
		do -- 3271
			local attempt = 0 -- 3272
			while attempt < shared.llmMaxTry do -- 3272
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3273
				if shared.stopToken.stopped then -- 3273
					return ____awaiter_resolve( -- 3273
						nil, -- 3273
						{ -- 3282
							success = false, -- 3282
							message = getCancelledReason(shared) -- 3282
						} -- 3282
					) -- 3282
				end -- 3282
				if decision.success then -- 3282
					return ____awaiter_resolve(nil, decision) -- 3282
				end -- 3282
				lastError = decision.message -- 3287
				lastRaw = decision.raw or "" -- 3288
				attempt = attempt + 1 -- 3272
			end -- 3272
		end -- 3272
		return ____awaiter_resolve( -- 3272
			nil, -- 3272
			{ -- 3290
				success = false, -- 3290
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3290
			} -- 3290
		) -- 3290
	end) -- 3290
end -- 3205
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3293
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3293
		local result = execRes -- 3294
		if not result.success then -- 3294
			if shared.stopToken.stopped then -- 3294
				shared.error = getCancelledReason(shared) -- 3297
				shared.done = true -- 3298
				return ____awaiter_resolve(nil, "done") -- 3298
			end -- 3298
			shared.error = result.message -- 3301
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3302
			shared.done = true -- 3303
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3304
			persistHistoryState(shared) -- 3308
			return ____awaiter_resolve(nil, "done") -- 3308
		end -- 3308
		if isDecisionBatchSuccess(result) then -- 3308
			local startStep = shared.step -- 3312
			local actions = {} -- 3313
			do -- 3313
				local i = 0 -- 3314
				while i < #result.decisions do -- 3314
					local decision = result.decisions[i + 1] -- 3315
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3316
					local step = startStep + i + 1 -- 3317
					local ____temp_96 -- 3318
					if i == 0 then -- 3318
						____temp_96 = decision.reason -- 3318
					else -- 3318
						____temp_96 = "" -- 3318
					end -- 3318
					local actionReason = ____temp_96 -- 3318
					local ____temp_97 -- 3319
					if i == 0 then -- 3319
						____temp_97 = decision.reasoningContent -- 3319
					else -- 3319
						____temp_97 = nil -- 3319
					end -- 3319
					local actionReasoningContent = ____temp_97 -- 3319
					emitAgentEvent(shared, { -- 3320
						type = "decision_made", -- 3321
						sessionId = shared.sessionId, -- 3322
						taskId = shared.taskId, -- 3323
						step = step, -- 3324
						tool = decision.tool, -- 3325
						reason = actionReason, -- 3326
						reasoningContent = actionReasoningContent, -- 3327
						params = decision.params -- 3328
					}) -- 3328
					local action = { -- 3330
						step = step, -- 3331
						toolCallId = toolCallId, -- 3332
						tool = decision.tool, -- 3333
						reason = actionReason or "", -- 3334
						reasoningContent = actionReasoningContent, -- 3335
						params = decision.params, -- 3336
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3337
					} -- 3337
					local ____shared_history_98 = shared.history -- 3337
					____shared_history_98[#____shared_history_98 + 1] = action -- 3339
					actions[#actions + 1] = action -- 3340
					i = i + 1 -- 3314
				end -- 3314
			end -- 3314
			shared.step = startStep + #actions -- 3342
			shared.agentStepCount = shared.agentStepCount + #actions -- 3343
			shared.pendingToolActions = actions -- 3344
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3345
			persistHistoryState(shared) -- 3351
			return ____awaiter_resolve(nil, "batch_tools") -- 3351
		end -- 3351
		if result.directSummary and result.directSummary ~= "" then -- 3351
			shared.response = result.directSummary -- 3355
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3356
			shared.done = true -- 3360
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3361
			persistHistoryState(shared) -- 3366
			return ____awaiter_resolve(nil, "done") -- 3366
		end -- 3366
		if result.tool == "finish" then -- 3366
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3370
			shared.response = finalMessage -- 3371
			shared.completion = getCompletionReport(result.params) -- 3372
			shared.done = true -- 3373
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3374
			persistHistoryState(shared) -- 3379
			return ____awaiter_resolve(nil, "done") -- 3379
		end -- 3379
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3382
		shared.step = shared.step + 1 -- 3383
		shared.agentStepCount = shared.agentStepCount + 1 -- 3384
		local step = shared.step -- 3385
		emitAgentEvent(shared, { -- 3386
			type = "decision_made", -- 3387
			sessionId = shared.sessionId, -- 3388
			taskId = shared.taskId, -- 3389
			step = step, -- 3390
			tool = result.tool, -- 3391
			reason = result.reason, -- 3392
			reasoningContent = result.reasoningContent, -- 3393
			params = result.params -- 3394
		}) -- 3394
		local ____shared_history_99 = shared.history -- 3394
		____shared_history_99[#____shared_history_99 + 1] = { -- 3396
			step = step, -- 3397
			toolCallId = toolCallId, -- 3398
			tool = result.tool, -- 3399
			reason = result.reason or "", -- 3400
			reasoningContent = result.reasoningContent, -- 3401
			params = result.params, -- 3402
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3403
		} -- 3403
		local action = shared.history[#shared.history] -- 3405
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3406
		shared.pendingToolActions = {action} -- 3409
		persistHistoryState(shared) -- 3410
		return ____awaiter_resolve(nil, "batch_tools") -- 3410
	end) -- 3410
end -- 3293
local ReadFileAction = __TS__Class() -- 3415
ReadFileAction.name = "ReadFileAction" -- 3415
__TS__ClassExtends(ReadFileAction, Node) -- 3415
function ReadFileAction.prototype.prep(self, shared) -- 3416
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3416
		local last = shared.history[#shared.history] -- 3417
		if not last then -- 3417
			error( -- 3418
				__TS__New(Error, "no history"), -- 3418
				0 -- 3418
			) -- 3418
		end -- 3418
		emitAgentStartEvent(shared, last) -- 3419
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3420
		if __TS__StringTrim(path) == "" then -- 3420
			error( -- 3423
				__TS__New(Error, "missing path"), -- 3423
				0 -- 3423
			) -- 3423
		end -- 3423
		local ____path_102 = path -- 3425
		local ____shared_workingDir_103 = shared.workingDir -- 3427
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3428
		local ____last_params_startLine_100 = last.params.startLine -- 3429
		if ____last_params_startLine_100 == nil then -- 3429
			____last_params_startLine_100 = 1 -- 3429
		end -- 3429
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3429
		local ____last_params_endLine_101 = last.params.endLine -- 3430
		if ____last_params_endLine_101 == nil then -- 3430
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3430
		end -- 3430
		return ____awaiter_resolve( -- 3430
			nil, -- 3430
			{ -- 3424
				path = ____path_102, -- 3425
				tool = "read_file", -- 3426
				workDir = ____shared_workingDir_103, -- 3427
				docLanguage = ____temp_104, -- 3428
				startLine = ____TS__Number_result_105, -- 3429
				endLine = __TS__Number(____last_params_endLine_101) -- 3430
			} -- 3430
		) -- 3430
	end) -- 3430
end -- 3416
function ReadFileAction.prototype.exec(self, input) -- 3434
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3434
		return ____awaiter_resolve( -- 3434
			nil, -- 3434
			Tools.readFile( -- 3435
				input.workDir, -- 3436
				input.path, -- 3437
				__TS__Number(input.startLine or 1), -- 3438
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3439
				input.docLanguage -- 3440
			) -- 3440
		) -- 3440
	end) -- 3440
end -- 3434
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3444
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3444
		local result = execRes -- 3445
		local last = shared.history[#shared.history] -- 3446
		if last ~= nil then -- 3446
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3448
			appendToolResultMessage(shared, last) -- 3449
			emitAgentFinishEvent(shared, last) -- 3450
		end -- 3450
		persistHistoryState(shared) -- 3452
		__TS__Await(maybeCompressHistory(shared)) -- 3453
		persistHistoryState(shared) -- 3454
		return ____awaiter_resolve(nil, "main") -- 3454
	end) -- 3454
end -- 3444
local SearchFilesAction = __TS__Class() -- 3459
SearchFilesAction.name = "SearchFilesAction" -- 3459
__TS__ClassExtends(SearchFilesAction, Node) -- 3459
function SearchFilesAction.prototype.prep(self, shared) -- 3460
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3460
		local last = shared.history[#shared.history] -- 3461
		if not last then -- 3461
			error( -- 3462
				__TS__New(Error, "no history"), -- 3462
				0 -- 3462
			) -- 3462
		end -- 3462
		emitAgentStartEvent(shared, last) -- 3463
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3463
	end) -- 3463
end -- 3460
function SearchFilesAction.prototype.exec(self, input) -- 3467
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3467
		local params = input.params -- 3468
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3469
		local ____input_workDir_112 = input.workDir -- 3470
		local ____temp_113 = params.path or "" -- 3471
		local ____temp_114 = params.pattern or "" -- 3472
		local ____params_globs_115 = params.globs -- 3473
		local ____params_useRegex_116 = params.useRegex -- 3474
		local ____params_caseSensitive_117 = params.caseSensitive -- 3475
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3477
		local ____math_max_108 = math.max -- 3478
		local ____math_floor_107 = math.floor -- 3478
		local ____params_limit_106 = params.limit -- 3478
		if ____params_limit_106 == nil then -- 3478
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3478
		end -- 3478
		local ____math_max_108_result_119 = ____math_max_108( -- 3478
			1, -- 3478
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3478
		) -- 3478
		local ____math_max_111 = math.max -- 3479
		local ____math_floor_110 = math.floor -- 3479
		local ____params_offset_109 = params.offset -- 3479
		if ____params_offset_109 == nil then -- 3479
			____params_offset_109 = 0 -- 3479
		end -- 3479
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3469
			workDir = ____input_workDir_112, -- 3470
			path = ____temp_113, -- 3471
			pattern = ____temp_114, -- 3472
			globs = ____params_globs_115, -- 3473
			useRegex = ____params_useRegex_116, -- 3474
			caseSensitive = ____params_caseSensitive_117, -- 3475
			includeContent = true, -- 3476
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3477
			limit = ____math_max_108_result_119, -- 3478
			offset = ____math_max_111( -- 3479
				0, -- 3479
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3479
			), -- 3479
			groupByFile = params.groupByFile == true -- 3480
		})) -- 3480
		return ____awaiter_resolve(nil, result) -- 3480
	end) -- 3480
end -- 3467
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3485
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3485
		local last = shared.history[#shared.history] -- 3486
		if last ~= nil then -- 3486
			local result = execRes -- 3488
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3489
			appendToolResultMessage(shared, last) -- 3490
			emitAgentFinishEvent(shared, last) -- 3491
		end -- 3491
		persistHistoryState(shared) -- 3493
		__TS__Await(maybeCompressHistory(shared)) -- 3494
		persistHistoryState(shared) -- 3495
		return ____awaiter_resolve(nil, "main") -- 3495
	end) -- 3495
end -- 3485
local SearchDoraAPIAction = __TS__Class() -- 3500
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3500
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3500
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3501
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3501
		local last = shared.history[#shared.history] -- 3502
		if not last then -- 3502
			error( -- 3503
				__TS__New(Error, "no history"), -- 3503
				0 -- 3503
			) -- 3503
		end -- 3503
		emitAgentStartEvent(shared, last) -- 3504
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3504
	end) -- 3504
end -- 3501
function SearchDoraAPIAction.prototype.exec(self, input) -- 3508
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3508
		local params = input.params -- 3509
		local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3510
		local ____temp_125 = params.pattern or "" -- 3511
		local ____temp_126 = params.docSource or "api" -- 3512
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3513
		local ____temp_128 = params.programmingLanguage or "ts" -- 3514
		local ____math_min_124 = math.min -- 3515
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3515
		local ____math_max_122 = math.max -- 3515
		local ____params_limit_121 = params.limit -- 3515
		if ____params_limit_121 == nil then -- 3515
			____params_limit_121 = 8 -- 3515
		end -- 3515
		local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3510
			pattern = ____temp_125, -- 3511
			docSource = ____temp_126, -- 3512
			docLanguage = ____temp_127, -- 3513
			programmingLanguage = ____temp_128, -- 3514
			limit = ____math_min_124( -- 3515
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123, -- 3515
				____math_max_122( -- 3515
					1, -- 3515
					__TS__Number(____params_limit_121) -- 3515
				) -- 3515
			), -- 3515
			useRegex = params.useRegex, -- 3516
			caseSensitive = false, -- 3517
			includeContent = true, -- 3518
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3519
		})) -- 3519
		return ____awaiter_resolve(nil, result) -- 3519
	end) -- 3519
end -- 3508
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3524
		local last = shared.history[#shared.history] -- 3525
		if last ~= nil then -- 3525
			local result = execRes -- 3527
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3528
			appendToolResultMessage(shared, last) -- 3529
			emitAgentFinishEvent(shared, last) -- 3530
		end -- 3530
		persistHistoryState(shared) -- 3532
		__TS__Await(maybeCompressHistory(shared)) -- 3533
		persistHistoryState(shared) -- 3534
		return ____awaiter_resolve(nil, "main") -- 3534
	end) -- 3534
end -- 3524
local ListFilesAction = __TS__Class() -- 3539
ListFilesAction.name = "ListFilesAction" -- 3539
__TS__ClassExtends(ListFilesAction, Node) -- 3539
function ListFilesAction.prototype.prep(self, shared) -- 3540
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3540
		local last = shared.history[#shared.history] -- 3541
		if not last then -- 3541
			error( -- 3542
				__TS__New(Error, "no history"), -- 3542
				0 -- 3542
			) -- 3542
		end -- 3542
		emitAgentStartEvent(shared, last) -- 3543
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3543
	end) -- 3543
end -- 3540
function ListFilesAction.prototype.exec(self, input) -- 3547
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3547
		local params = input.params -- 3548
		local ____Tools_listFiles_136 = Tools.listFiles -- 3549
		local ____input_workDir_133 = input.workDir -- 3550
		local ____temp_134 = params.path or "" -- 3551
		local ____params_globs_135 = params.globs -- 3552
		local ____math_max_132 = math.max -- 3553
		local ____math_floor_131 = math.floor -- 3553
		local ____params_maxEntries_130 = params.maxEntries -- 3553
		if ____params_maxEntries_130 == nil then -- 3553
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3553
		end -- 3553
		local result = ____Tools_listFiles_136({ -- 3549
			workDir = ____input_workDir_133, -- 3550
			path = ____temp_134, -- 3551
			globs = ____params_globs_135, -- 3552
			maxEntries = ____math_max_132( -- 3553
				1, -- 3553
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3553
			) -- 3553
		}) -- 3553
		return ____awaiter_resolve(nil, result) -- 3553
	end) -- 3553
end -- 3547
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3558
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3558
		local last = shared.history[#shared.history] -- 3559
		if last ~= nil then -- 3559
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3561
			appendToolResultMessage(shared, last) -- 3562
			emitAgentFinishEvent(shared, last) -- 3563
		end -- 3563
		persistHistoryState(shared) -- 3565
		__TS__Await(maybeCompressHistory(shared)) -- 3566
		persistHistoryState(shared) -- 3567
		return ____awaiter_resolve(nil, "main") -- 3567
	end) -- 3567
end -- 3558
local DeleteFileAction = __TS__Class() -- 3572
DeleteFileAction.name = "DeleteFileAction" -- 3572
__TS__ClassExtends(DeleteFileAction, Node) -- 3572
function DeleteFileAction.prototype.prep(self, shared) -- 3573
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3573
		local last = shared.history[#shared.history] -- 3574
		if not last then -- 3574
			error( -- 3575
				__TS__New(Error, "no history"), -- 3575
				0 -- 3575
			) -- 3575
		end -- 3575
		emitAgentStartEvent(shared, last) -- 3576
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3577
		if __TS__StringTrim(targetFile) == "" then -- 3577
			error( -- 3580
				__TS__New(Error, "missing target_file"), -- 3580
				0 -- 3580
			) -- 3580
		end -- 3580
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3580
	end) -- 3580
end -- 3573
function DeleteFileAction.prototype.exec(self, input) -- 3584
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3584
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3585
		if not result.success then -- 3585
			return ____awaiter_resolve(nil, result) -- 3585
		end -- 3585
		return ____awaiter_resolve(nil, { -- 3585
			success = true, -- 3593
			changed = true, -- 3594
			mode = "delete", -- 3595
			checkpointId = result.checkpointId, -- 3596
			checkpointSeq = result.checkpointSeq, -- 3597
			files = {{path = input.targetFile, op = "delete"}} -- 3598
		}) -- 3598
	end) -- 3598
end -- 3584
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3602
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3602
		local last = shared.history[#shared.history] -- 3603
		if last ~= nil then -- 3603
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3605
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3606
			appendToolResultMessage(shared, last) -- 3607
			emitAgentFinishEvent(shared, last) -- 3608
			local result = last.result -- 3609
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3609
				emitAgentEvent(shared, { -- 3614
					type = "checkpoint_created", -- 3615
					sessionId = shared.sessionId, -- 3616
					taskId = shared.taskId, -- 3617
					step = last.step, -- 3618
					tool = "delete_file", -- 3619
					checkpointId = result.checkpointId, -- 3620
					checkpointSeq = result.checkpointSeq, -- 3621
					files = result.files -- 3622
				}) -- 3622
			end -- 3622
		end -- 3622
		persistHistoryState(shared) -- 3629
		__TS__Await(maybeCompressHistory(shared)) -- 3630
		persistHistoryState(shared) -- 3631
		return ____awaiter_resolve(nil, "main") -- 3631
	end) -- 3631
end -- 3602
local BuildAction = __TS__Class() -- 3636
BuildAction.name = "BuildAction" -- 3636
__TS__ClassExtends(BuildAction, Node) -- 3636
function BuildAction.prototype.prep(self, shared) -- 3637
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3637
		local last = shared.history[#shared.history] -- 3638
		if not last then -- 3638
			error( -- 3639
				__TS__New(Error, "no history"), -- 3639
				0 -- 3639
			) -- 3639
		end -- 3639
		emitAgentStartEvent(shared, last) -- 3640
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3640
	end) -- 3640
end -- 3637
function BuildAction.prototype.exec(self, input) -- 3644
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3644
		local params = input.params -- 3645
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3646
		return ____awaiter_resolve(nil, result) -- 3646
	end) -- 3646
end -- 3644
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3653
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3653
		local last = shared.history[#shared.history] -- 3654
		if last ~= nil then -- 3654
			last.result = sanitizeBuildResultForHistory(execRes) -- 3656
			appendToolResultMessage(shared, last) -- 3657
			emitAgentFinishEvent(shared, last) -- 3658
		end -- 3658
		persistHistoryState(shared) -- 3660
		__TS__Await(maybeCompressHistory(shared)) -- 3661
		persistHistoryState(shared) -- 3662
		return ____awaiter_resolve(nil, "main") -- 3662
	end) -- 3662
end -- 3653
local SpawnSubAgentAction = __TS__Class() -- 3667
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3667
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3667
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3668
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3668
		local last = shared.history[#shared.history] -- 3678
		if not last then -- 3678
			error( -- 3679
				__TS__New(Error, "no history"), -- 3679
				0 -- 3679
			) -- 3679
		end -- 3679
		emitAgentStartEvent(shared, last) -- 3680
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3681
			last.params.filesHint, -- 3682
			function(____, item) return type(item) == "string" end -- 3682
		) or nil -- 3682
		return ____awaiter_resolve( -- 3682
			nil, -- 3682
			{ -- 3684
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3685
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3686
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3687
				filesHint = filesHint, -- 3688
				sessionId = shared.sessionId, -- 3689
				projectRoot = shared.workingDir, -- 3690
				spawnSubAgent = shared.spawnSubAgent, -- 3691
				disabledAgentTools = shared.disabledAgentTools -- 3692
			} -- 3692
		) -- 3692
	end) -- 3692
end -- 3668
function SpawnSubAgentAction.prototype.exec(self, input) -- 3696
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3696
		if not input.spawnSubAgent then -- 3696
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3696
		end -- 3696
		if input.sessionId == nil or input.sessionId <= 0 then -- 3696
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3696
		end -- 3696
		local ____AgentUtils_Log_142 = AgentUtils.Log -- 3712
		local ____temp_139 = #input.title -- 3712
		local ____temp_140 = #input.prompt -- 3712
		local ____temp_141 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3712
		local ____opt_137 = input.filesHint -- 3712
		____AgentUtils_Log_142( -- 3712
			"Info", -- 3712
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_139)) .. " prompt_len=") .. tostring(____temp_140)) .. " expected_len=") .. tostring(____temp_141)) .. " files_hint_count=") .. tostring(____opt_137 and #____opt_137 or 0) -- 3712
		) -- 3712
		local result = __TS__Await(input.spawnSubAgent({ -- 3713
			parentSessionId = input.sessionId, -- 3714
			projectRoot = input.projectRoot, -- 3715
			title = input.title, -- 3716
			prompt = input.prompt, -- 3717
			expectedOutput = input.expectedOutput, -- 3718
			filesHint = input.filesHint, -- 3719
			disabledAgentTools = input.disabledAgentTools -- 3720
		})) -- 3720
		if not result.success then -- 3720
			return ____awaiter_resolve(nil, result) -- 3720
		end -- 3720
		return ____awaiter_resolve(nil, { -- 3720
			success = true, -- 3726
			sessionId = result.sessionId, -- 3727
			taskId = result.taskId, -- 3728
			title = result.title, -- 3729
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3730
		}) -- 3730
	end) -- 3730
end -- 3696
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3734
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3734
		local last = shared.history[#shared.history] -- 3735
		if last ~= nil then -- 3735
			last.result = execRes -- 3737
			if execRes.success == true then -- 3737
				shared.hasSpawnedSubAgentThisTask = true -- 3739
			end -- 3739
			appendToolResultMessage(shared, last) -- 3741
			emitAgentFinishEvent(shared, last) -- 3742
		end -- 3742
		persistHistoryState(shared) -- 3744
		__TS__Await(maybeCompressHistory(shared)) -- 3745
		persistHistoryState(shared) -- 3746
		return ____awaiter_resolve(nil, "main") -- 3746
	end) -- 3746
end -- 3734
local ListSubAgentsAction = __TS__Class() -- 3751
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3751
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3751
function ListSubAgentsAction.prototype.prep(self, shared) -- 3752
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3752
		local last = shared.history[#shared.history] -- 3762
		if not last then -- 3762
			error( -- 3763
				__TS__New(Error, "no history"), -- 3763
				0 -- 3763
			) -- 3763
		end -- 3763
		emitAgentStartEvent(shared, last) -- 3764
		return ____awaiter_resolve( -- 3764
			nil, -- 3764
			{ -- 3765
				sessionId = shared.sessionId, -- 3766
				projectRoot = shared.workingDir, -- 3767
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3768
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3769
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3770
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3771
				listSubAgents = shared.listSubAgents, -- 3772
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3773
			} -- 3773
		) -- 3773
	end) -- 3773
end -- 3752
function ListSubAgentsAction.prototype.exec(self, input) -- 3777
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3777
		if not input.listSubAgents then -- 3777
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3777
		end -- 3777
		if input.sessionId == nil or input.sessionId <= 0 then -- 3777
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3777
		end -- 3777
		local result = __TS__Await(input.listSubAgents({ -- 3793
			sessionId = input.sessionId, -- 3794
			projectRoot = input.projectRoot, -- 3795
			status = input.status, -- 3796
			limit = input.limit, -- 3797
			offset = input.offset, -- 3798
			query = input.query -- 3799
		})) -- 3799
		return ____awaiter_resolve( -- 3799
			nil, -- 3799
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3801
		) -- 3801
	end) -- 3801
end -- 3777
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3809
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3809
		local last = shared.history[#shared.history] -- 3810
		if last ~= nil then -- 3810
			last.result = execRes -- 3812
			appendToolResultMessage(shared, last) -- 3813
			emitAgentFinishEvent(shared, last) -- 3814
		end -- 3814
		persistHistoryState(shared) -- 3816
		__TS__Await(maybeCompressHistory(shared)) -- 3817
		persistHistoryState(shared) -- 3818
		return ____awaiter_resolve(nil, "main") -- 3818
	end) -- 3818
end -- 3809
EditFileAction = __TS__Class() -- 3823
EditFileAction.name = "EditFileAction" -- 3823
__TS__ClassExtends(EditFileAction, Node) -- 3823
function EditFileAction.prototype.prep(self, shared) -- 3824
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3824
		local last = shared.history[#shared.history] -- 3825
		if not last then -- 3825
			error( -- 3826
				__TS__New(Error, "no history"), -- 3826
				0 -- 3826
			) -- 3826
		end -- 3826
		emitAgentStartEvent(shared, last) -- 3827
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3828
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3831
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3832
		if __TS__StringTrim(path) == "" then -- 3832
			error( -- 3833
				__TS__New(Error, "missing path"), -- 3833
				0 -- 3833
			) -- 3833
		end -- 3833
		return ____awaiter_resolve(nil, { -- 3833
			path = path, -- 3834
			oldStr = oldStr, -- 3834
			newStr = newStr, -- 3834
			taskId = shared.taskId, -- 3834
			workDir = shared.workingDir -- 3834
		}) -- 3834
	end) -- 3834
end -- 3824
function EditFileAction.prototype.exec(self, input) -- 3837
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3837
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3838
		if not readRes.success then -- 3838
			if input.oldStr ~= "" then -- 3838
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3838
			end -- 3838
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3843
			if not createRes.success then -- 3843
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3843
			end -- 3843
			return ____awaiter_resolve( -- 3843
				nil, -- 3843
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3850
					success = true, -- 3851
					changed = true, -- 3852
					mode = "create", -- 3853
					checkpointId = createRes.checkpointId, -- 3854
					checkpointSeq = createRes.checkpointSeq, -- 3855
					files = {{path = input.path, op = "create"}} -- 3856
				}) -- 3856
			) -- 3856
		end -- 3856
		if input.oldStr == "" then -- 3856
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3856
				return ____awaiter_resolve( -- 3856
					nil, -- 3856
					{ -- 3861
						success = false, -- 3862
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3863
						actualSaved = false, -- 3864
						actualSavedCharacters = 0, -- 3865
						currentFileExists = true, -- 3866
						currentCharacters = #readRes.content, -- 3867
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3868
					} -- 3868
				) -- 3868
			end -- 3868
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3871
			if not overwriteRes.success then -- 3871
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3871
			end -- 3871
			return ____awaiter_resolve( -- 3871
				nil, -- 3871
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3878
					success = true, -- 3879
					changed = true, -- 3880
					mode = "overwrite", -- 3881
					checkpointId = overwriteRes.checkpointId, -- 3882
					checkpointSeq = overwriteRes.checkpointSeq, -- 3883
					files = {{path = input.path, op = "write"}} -- 3884
				}) -- 3884
			) -- 3884
		end -- 3884
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3889
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3890
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3891
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3894
		if occurrences == 0 then -- 3894
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3896
			if not indentTolerant.success then -- 3896
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3896
			end -- 3896
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3900
			if not applyRes.success then -- 3900
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3900
			end -- 3900
			return ____awaiter_resolve( -- 3900
				nil, -- 3900
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3907
					success = true, -- 3908
					changed = true, -- 3909
					mode = "replace_indent_tolerant", -- 3910
					checkpointId = applyRes.checkpointId, -- 3911
					checkpointSeq = applyRes.checkpointSeq, -- 3912
					files = {{path = input.path, op = "write"}} -- 3913
				}) -- 3913
			) -- 3913
		end -- 3913
		if occurrences > 1 then -- 3913
			return ____awaiter_resolve( -- 3913
				nil, -- 3913
				{ -- 3917
					success = false, -- 3917
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3917
				} -- 3917
			) -- 3917
		end -- 3917
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3921
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3922
		if not applyRes.success then -- 3922
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3922
		end -- 3922
		return ____awaiter_resolve( -- 3922
			nil, -- 3922
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3929
				success = true, -- 3930
				changed = true, -- 3931
				mode = "replace", -- 3932
				checkpointId = applyRes.checkpointId, -- 3933
				checkpointSeq = applyRes.checkpointSeq, -- 3934
				files = {{path = input.path, op = "write"}} -- 3935
			}) -- 3935
		) -- 3935
	end) -- 3935
end -- 3837
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3939
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3939
		local last = shared.history[#shared.history] -- 3940
		if last ~= nil then -- 3940
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3942
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3943
			appendToolResultMessage(shared, last) -- 3944
			emitAgentFinishEvent(shared, last) -- 3945
			local result = last.result -- 3946
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3946
				emitAgentEvent(shared, { -- 3951
					type = "checkpoint_created", -- 3952
					sessionId = shared.sessionId, -- 3953
					taskId = shared.taskId, -- 3954
					step = last.step, -- 3955
					tool = last.tool, -- 3956
					checkpointId = result.checkpointId, -- 3957
					checkpointSeq = result.checkpointSeq, -- 3958
					files = result.files -- 3959
				}) -- 3959
			end -- 3959
		end -- 3959
		persistHistoryState(shared) -- 3966
		__TS__Await(maybeCompressHistory(shared)) -- 3967
		persistHistoryState(shared) -- 3968
		return ____awaiter_resolve(nil, "main") -- 3968
	end) -- 3968
end -- 3939
local FetchUrlAction = __TS__Class() -- 3973
FetchUrlAction.name = "FetchUrlAction" -- 3973
__TS__ClassExtends(FetchUrlAction, Node) -- 3973
function FetchUrlAction.prototype.prep(self, shared) -- 3974
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3974
		local last = shared.history[#shared.history] -- 3975
		if not last then -- 3975
			error( -- 3976
				__TS__New(Error, "no history"), -- 3976
				0 -- 3976
			) -- 3976
		end -- 3976
		emitAgentStartEvent(shared, last) -- 3977
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3977
	end) -- 3977
end -- 3974
function FetchUrlAction.prototype.exec(self, input) -- 3981
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3981
		return ____awaiter_resolve( -- 3981
			nil, -- 3981
			executeToolAction(input.shared, input.action) -- 3982
		) -- 3982
	end) -- 3982
end -- 3981
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3985
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3985
		local last = shared.history[#shared.history] -- 3986
		if last ~= nil then -- 3986
			last.result = execRes -- 3988
			appendToolResultMessage(shared, last) -- 3989
			emitAgentFinishEvent(shared, last) -- 3990
		end -- 3990
		persistHistoryState(shared) -- 3992
		__TS__Await(maybeCompressHistory(shared)) -- 3993
		persistHistoryState(shared) -- 3994
		return ____awaiter_resolve(nil, "main") -- 3994
	end) -- 3994
end -- 3985
local function emitCheckpointEventForAction(shared, action) -- 3999
	local result = action.result -- 4000
	if not result then -- 4000
		return -- 4001
	end -- 4001
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4001
		emitAgentEvent(shared, { -- 4006
			type = "checkpoint_created", -- 4007
			sessionId = shared.sessionId, -- 4008
			taskId = shared.taskId, -- 4009
			step = action.step, -- 4010
			tool = action.tool, -- 4011
			checkpointId = result.checkpointId, -- 4012
			checkpointSeq = result.checkpointSeq, -- 4013
			files = result.files -- 4014
		}) -- 4014
	end -- 4014
end -- 3999
local function canRunBatchActionInParallel(self, action) -- 4541
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4542
end -- 4541
local function partitionToolCalls(actions) -- 4550
	local batches = {} -- 4551
	do -- 4551
		local i = 0 -- 4552
		while i < #actions do -- 4552
			local action = actions[i + 1] -- 4553
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4554
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4555
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4555
				local ____lastBatch_actions_175 = lastBatch.actions -- 4555
				____lastBatch_actions_175[#____lastBatch_actions_175 + 1] = action -- 4557
			else -- 4557
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4559
			end -- 4559
			i = i + 1 -- 4552
		end -- 4552
	end -- 4552
	return batches -- 4562
end -- 4550
local function completeStoppedToolAction(shared, action) -- 4565
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4566
	if not action.result then -- 4566
		action.result = { -- 4568
			success = false, -- 4568
			message = getCancelledReason(shared) -- 4568
		} -- 4568
	end -- 4568
	appendToolResultMessage(shared, action) -- 4570
	emitAgentFinishEvent(shared, action) -- 4571
	emitCheckpointEventForAction(shared, action) -- 4572
end -- 4565
local BatchToolAction = __TS__Class() -- 4575
BatchToolAction.name = "BatchToolAction" -- 4575
__TS__ClassExtends(BatchToolAction, Node) -- 4575
function BatchToolAction.prototype.prep(self, shared) -- 4576
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4576
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4576
	end) -- 4576
end -- 4576
function BatchToolAction.prototype.exec(self, input) -- 4580
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4580
		local shared = input.shared -- 4581
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4582
		local preExecuted = shared.preExecutedResults -- 4583
		local batches = partitionToolCalls(input.actions) -- 4584
		local parallelBatchCount = #__TS__ArrayFilter( -- 4585
			batches, -- 4585
			function(____, b) return b.isConcurrencySafe end -- 4585
		) -- 4585
		local serialBatchCount = #__TS__ArrayFilter( -- 4586
			batches, -- 4586
			function(____, b) return not b.isConcurrencySafe end -- 4586
		) -- 4586
		AgentUtils.Log( -- 4587
			"Info", -- 4587
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4587
		) -- 4587
		do -- 4587
			local batchIdx = 0 -- 4589
			while batchIdx < #batches do -- 4589
				do -- 4589
					local batch = batches[batchIdx + 1] -- 4590
					if shared.stopToken.stopped then -- 4590
						for ____, action in ipairs(batch.actions) do -- 4592
							completeStoppedToolAction(shared, action) -- 4593
						end -- 4593
						goto __continue761 -- 4595
					end -- 4595
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4595
						local preExecCount = #__TS__ArrayFilter( -- 4599
							batch.actions, -- 4599
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4599
						) -- 4599
						AgentUtils.Log( -- 4600
							"Info", -- 4600
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4600
						) -- 4600
						do -- 4600
							local i = 0 -- 4601
							while i < #batch.actions do -- 4601
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4602
								i = i + 1 -- 4601
							end -- 4601
						end -- 4601
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4604
							batch.actions, -- 4604
							function(____, action) -- 4604
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4604
									if shared.stopToken.stopped then -- 4604
										action.result = { -- 4606
											success = false, -- 4606
											message = getCancelledReason(shared) -- 4606
										} -- 4606
										return ____awaiter_resolve(nil, action) -- 4606
									end -- 4606
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4609
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4610
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4611
									return ____awaiter_resolve(nil, action) -- 4611
								end) -- 4611
							end -- 4604
						))) -- 4604
						do -- 4604
							local i = 0 -- 4614
							while i < #batch.actions do -- 4614
								local action = batch.actions[i + 1] -- 4615
								if not action.result then -- 4615
									action.result = {success = false, message = "tool did not produce a result"} -- 4617
								end -- 4617
								appendToolResultMessage(shared, action) -- 4619
								emitAgentFinishEvent(shared, action) -- 4620
								emitCheckpointEventForAction(shared, action) -- 4621
								i = i + 1 -- 4614
							end -- 4614
						end -- 4614
					else -- 4614
						AgentUtils.Log( -- 4624
							"Info", -- 4624
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4624
						) -- 4624
						do -- 4624
							local i = 0 -- 4625
							while i < #batch.actions do -- 4625
								local action = batch.actions[i + 1] -- 4626
								emitAgentStartEvent(shared, action) -- 4627
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4628
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4629
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4630
								appendToolResultMessage(shared, action) -- 4631
								emitAgentFinishEvent(shared, action) -- 4632
								emitCheckpointEventForAction(shared, action) -- 4633
								persistHistoryState(shared) -- 4634
								if shared.stopToken.stopped then -- 4634
									do -- 4634
										local j = i + 1 -- 4636
										while j < #batch.actions do -- 4636
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4637
											j = j + 1 -- 4636
										end -- 4636
									end -- 4636
									break -- 4639
								end -- 4639
								i = i + 1 -- 4625
							end -- 4625
						end -- 4625
					end -- 4625
				end -- 4625
				::__continue761:: -- 4625
				batchIdx = batchIdx + 1 -- 4589
			end -- 4589
		end -- 4589
		local spawnSeen = spawnedBeforeBatch -- 4644
		local didDelegatedForegroundWork = false -- 4645
		do -- 4645
			local i = 0 -- 4646
			while i < #input.actions do -- 4646
				do -- 4646
					local action = input.actions[i + 1] -- 4647
					if action.tool == "spawn_sub_agent" then -- 4647
						local ____opt_178 = action.result -- 4647
						if (____opt_178 and ____opt_178.success) == true then -- 4647
							spawnSeen = true -- 4649
						end -- 4649
						goto __continue781 -- 4650
					end -- 4650
					if spawnSeen and action.tool ~= "finish" then -- 4650
						didDelegatedForegroundWork = true -- 4653
					end -- 4653
				end -- 4653
				::__continue781:: -- 4653
				i = i + 1 -- 4646
			end -- 4646
		end -- 4646
		if didDelegatedForegroundWork then -- 4646
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4657
		end -- 4657
		persistHistoryState(shared) -- 4659
		return ____awaiter_resolve(nil, input.actions) -- 4659
	end) -- 4659
end -- 4580
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4663
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4663
		shared.pendingToolActions = nil -- 4664
		shared.preExecutedResults = nil -- 4665
		persistHistoryState(shared) -- 4666
		if shared.waitingQuestionnaireId == nil then -- 4666
			__TS__Await(maybeCompressHistory(shared)) -- 4670
			persistHistoryState(shared) -- 4671
		end -- 4671
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4671
	end) -- 4671
end -- 4663
local EndNode = __TS__Class() -- 4677
EndNode.name = "EndNode" -- 4677
__TS__ClassExtends(EndNode, Node) -- 4677
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4678
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4678
		return ____awaiter_resolve(nil, nil) -- 4678
	end) -- 4678
end -- 4678
local CodingAgentFlow = __TS__Class() -- 4683
CodingAgentFlow.name = "CodingAgentFlow" -- 4683
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4683
function CodingAgentFlow.prototype.____constructor(self, role) -- 4684
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4685
	local read = __TS__New(ReadFileAction, 1, 0) -- 4686
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4687
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4688
	local list = __TS__New(ListFilesAction, 1, 0) -- 4689
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4690
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4691
	local build = __TS__New(BuildAction, 1, 0) -- 4692
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4693
	local edit = __TS__New(EditFileAction, 1, 0) -- 4694
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4695
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4696
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4697
	local done = __TS__New(EndNode, 1, 0) -- 4698
	main:on("batch_tools", batch) -- 4700
	main:on("grep_files", search) -- 4701
	main:on("search_dora_api", searchDora) -- 4702
	main:on("glob_files", list) -- 4703
	main:on("fetch_url", fetch) -- 4704
	main:on("execute_command", exec) -- 4705
	if role == "main" then -- 4705
		main:on("read_file", read) -- 4707
		main:on("delete_file", del) -- 4708
		main:on("build", build) -- 4709
		main:on("edit_file", edit) -- 4710
		main:on("list_sub_agents", listSub) -- 4711
		main:on("spawn_sub_agent", spawn) -- 4712
	else -- 4712
		main:on("read_file", read) -- 4714
		main:on("delete_file", del) -- 4715
		main:on("build", build) -- 4716
		main:on("edit_file", edit) -- 4717
	end -- 4717
	main:on("done", done) -- 4719
	search:on("main", main) -- 4721
	searchDora:on("main", main) -- 4722
	list:on("main", main) -- 4723
	listSub:on("main", main) -- 4724
	spawn:on("main", main) -- 4725
	batch:on("main", main) -- 4726
	batch:on("done", done) -- 4727
	read:on("main", main) -- 4728
	del:on("main", main) -- 4729
	build:on("main", main) -- 4730
	edit:on("main", main) -- 4731
	fetch:on("main", main) -- 4732
	exec:on("main", main) -- 4733
	Flow.prototype.____constructor(self, main) -- 4735
end -- 4684
local function runCodingAgentAsync(options) -- 4771
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4771
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4771
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4771
		end -- 4771
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4775
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4776
		if not llmConfigRes.success then -- 4776
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4776
		end -- 4776
		local llmConfig = llmConfigRes.config -- 4782
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4783
		if not taskRes.success then -- 4783
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4783
		end -- 4783
		local compressor = __TS__New(MemoryCompressor, { -- 4790
			compressionTargetThreshold = 0.5, -- 4791
			maxCompressionRounds = 3, -- 4792
			projectDir = options.workDir, -- 4793
			llmConfig = llmConfig, -- 4794
			promptPack = options.promptPack, -- 4795
			scope = options.memoryScope -- 4796
		}) -- 4796
		local persistedSession = compressor:getStorage():readSessionState() -- 4798
		local effectiveUserQuery = normalizedPrompt -- 4799
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4799
			do -- 4799
				local i = #persistedSession.messages - 1 -- 4801
				while i >= 0 do -- 4801
					local message = persistedSession.messages[i + 1] -- 4802
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4802
						effectiveUserQuery = message.content -- 4804
						break -- 4805
					end -- 4805
					i = i - 1 -- 4801
				end -- 4801
			end -- 4801
		end -- 4801
		local promptPack = compressor:getPromptPack() -- 4809
		local freshProject = inspectFreshProject(options.workDir) -- 4810
		local freshProjectBuildPending = freshProject.fresh -- 4811
		local freshProjectCodeFile = freshProject.codeFile -- 4812
		local shared = { -- 4814
			sessionId = options.sessionId, -- 4815
			taskId = taskRes.taskId, -- 4816
			role = options.role or "main", -- 4817
			maxSteps = math.max( -- 4818
				1, -- 4818
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4818
			), -- 4818
			llmMaxTry = math.max( -- 4819
				1, -- 4819
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4819
			), -- 4819
			step = math.max( -- 4820
				0, -- 4820
				math.floor(options.initialStep or 0) -- 4820
			), -- 4820
			agentStepCount = math.max( -- 4821
				0, -- 4821
				math.floor(options.initialAgentStepCount or 0) -- 4821
			), -- 4821
			done = false, -- 4822
			stopToken = options.stopToken or ({stopped = false}), -- 4823
			response = "", -- 4824
			userQuery = effectiveUserQuery, -- 4825
			workingDir = options.workDir, -- 4826
			useChineseResponse = options.useChineseResponse == true, -- 4827
			workMode = options.workMode or "code", -- 4828
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4829
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4832
			llmConfig = llmConfig, -- 4833
			onEvent = options.onEvent, -- 4834
			promptPack = promptPack, -- 4835
			history = {}, -- 4836
			messages = persistedSession.messages, -- 4837
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4838
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4839
			memory = {compressor = compressor}, -- 4841
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4845
				projectDir = options.workDir, -- 4847
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4848
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4849
			})}, -- 4849
			spawnSubAgent = options.spawnSubAgent, -- 4855
			listSubAgents = options.listSubAgents, -- 4856
			publishQuestionnaire = options.publishQuestionnaire, -- 4857
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4858
			freshProjectBuildPending = freshProjectBuildPending, -- 4859
			freshProjectCodeFile = freshProjectCodeFile, -- 4860
			hasSpawnedSubAgentThisTask = false, -- 4861
			delegatedForegroundBatches = 0, -- 4862
			tokenUsage = options.initialTokenUsage -- 4863
		} -- 4863
		local ____hasReturned, ____returnValue -- 4863
		local ____try = __TS__AsyncAwaiter(function() -- 4863
			if shared.workMode == "plan" then -- 4863
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4868
				if not planDocuments.success then -- 4868
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4870
					____hasReturned = true -- 4871
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4871
					return -- 4871
				end -- 4871
			end -- 4871
			emitAgentEvent(shared, { -- 4874
				type = "task_started", -- 4875
				sessionId = shared.sessionId, -- 4876
				taskId = shared.taskId, -- 4877
				prompt = shared.userQuery, -- 4878
				workDir = shared.workingDir, -- 4879
				maxSteps = shared.maxSteps, -- 4880
				resumed = options.resumeTask == true -- 4881
			}) -- 4881
			if shared.stopToken.stopped then -- 4881
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4884
				____hasReturned = true -- 4885
				____returnValue = emitAgentTaskFinishEvent( -- 4885
					shared, -- 4885
					false, -- 4885
					getCancelledReason(shared) -- 4885
				) -- 4885
				return -- 4885
			end -- 4885
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4887
			local ____temp_180 -- 4888
			if options.resumeConversation == true then -- 4888
				____temp_180 = nil -- 4888
			else -- 4888
				____temp_180 = getPromptCommand(shared.userQuery) -- 4888
			end -- 4888
			local promptCommand = ____temp_180 -- 4888
			if promptCommand == "clear" then -- 4888
				____hasReturned = true -- 4890
				____returnValue = clearSessionHistory(shared) -- 4890
				return -- 4890
			end -- 4890
			if promptCommand == "compact" then -- 4890
				if shared.role == "sub" then -- 4890
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4894
					____hasReturned = true -- 4895
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4895
					return -- 4895
				end -- 4895
				____hasReturned = true -- 4903
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4903
				return -- 4903
			end -- 4903
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4905
			if shared.stopToken.stopped then -- 4905
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4907
				____hasReturned = true -- 4908
				____returnValue = emitAgentTaskFinishEvent( -- 4908
					shared, -- 4908
					false, -- 4908
					getCancelledReason(shared) -- 4908
				) -- 4908
				return -- 4908
			end -- 4908
			if options.resumeConversation ~= true then -- 4908
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4911
				persistHistoryState(shared) -- 4915
			end -- 4915
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4917
			__TS__Await(flow:run(shared)) -- 4918
			if shared.stopToken.stopped then -- 4918
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4920
				____hasReturned = true -- 4921
				____returnValue = emitAgentTaskFinishEvent( -- 4921
					shared, -- 4921
					false, -- 4921
					getCancelledReason(shared) -- 4921
				) -- 4921
				return -- 4921
			end -- 4921
			if shared.error then -- 4921
				____hasReturned = true -- 4924
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4924
				return -- 4924
			end -- 4924
			if shared.waitingQuestionnaireId ~= nil then -- 4924
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4928
				emitAgentEvent(shared, { -- 4929
					type = "task_waiting_for_user", -- 4930
					sessionId = shared.sessionId, -- 4931
					taskId = shared.taskId, -- 4932
					step = shared.step, -- 4933
					questionnaireId = shared.waitingQuestionnaireId -- 4934
				}) -- 4934
				____hasReturned = true -- 4936
				____returnValue = { -- 4936
					success = true, -- 4937
					taskId = shared.taskId, -- 4938
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4939
					steps = shared.step, -- 4940
					waitingForUser = true, -- 4941
					questionnaireId = shared.waitingQuestionnaireId -- 4942
				} -- 4942
				return -- 4936
			end -- 4936
			local ____isFinalDecisionTurn_result_183 = isFinalDecisionTurn(shared) -- 4945
			if ____isFinalDecisionTurn_result_183 then -- 4945
				local ____opt_181 = shared.completion -- 4945
				____isFinalDecisionTurn_result_183 = (____opt_181 and ____opt_181.outcome) == "partial" -- 4945
			end -- 4945
			if ____isFinalDecisionTurn_result_183 then -- 4945
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4946
				____hasReturned = true -- 4947
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4947
				return -- 4947
			end -- 4947
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4950
			____hasReturned = true -- 4951
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4951
			return -- 4951
		end) -- 4951
		____try = ____try.catch( -- 4951
			____try, -- 4951
			function(____, e) -- 4951
				return __TS__AsyncAwaiter(function() -- 4951
					____hasReturned = true -- 4954
					____returnValue = finalizeAgentFailure( -- 4954
						shared, -- 4954
						tostring(e) -- 4954
					) -- 4954
					return -- 4954
				end) -- 4954
			end -- 4954
		) -- 4954
		__TS__Await(____try) -- 4866
		if ____hasReturned then -- 4866
			return ____awaiter_resolve(nil, ____returnValue) -- 4866
		end -- 4866
	end) -- 4866
end -- 4771
function ____exports.runCodingAgent(options, callback) -- 4958
	local ____self_184 = runCodingAgentAsync(options) -- 4958
	____self_184["then"]( -- 4958
		____self_184, -- 4958
		function(____, result) return callback(result) end -- 4959
	) -- 4959
end -- 4958
return ____exports -- 4958