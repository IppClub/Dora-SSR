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
local AudioToolRuntime = require("Agent.AudioToolRuntime") -- 11
local AgentSkills = require("Agent.AgentSkills") -- 12
local AgentConfig = require("Agent.AgentConfig") -- 13
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 14
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 23
local normalizeQuestionnaire = ____AgentQuestionnaire.normalizeQuestionnaire -- 23
function isRecord(value) -- 26
	return type(value) == "table" -- 27
end -- 27
function isArray(value) -- 30
	return __TS__ArrayIsArray(value) -- 31
end -- 31
function emitAgentEvent(shared, event) -- 444
	if shared.onEvent then -- 444
		do -- 444
			local function ____catch(____error) -- 444
				AgentUtils.Log( -- 449
					"Error", -- 449
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 449
				) -- 449
			end -- 449
			local ____try, ____hasReturned = pcall(function() -- 449
				shared:onEvent(event) -- 447
			end) -- 447
			if not ____try then -- 447
				____catch(____hasReturned) -- 447
			end -- 447
		end -- 447
	end -- 447
end -- 447
function getCancelledReason(shared) -- 610
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 610
		return shared.stopToken.reason -- 611
	end -- 611
	return shared.useChineseResponse and "已取消" or "cancelled" -- 612
end -- 612
function ____exports.normalizePolicyPath(path) -- 674
	return AgentRuntimePolicy.normalizeAgentPath(path) -- 675
end -- 674
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 683
	return AgentRuntimePolicy.isMainAgentMemoryPath(path) -- 684
end -- 683
function toJson(value, emptyAsArray) -- 831
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 832
	if text ~= nil then -- 832
		return text -- 833
	end -- 833
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 834
end -- 834
function truncateText(text, maxLen) -- 837
	if #text <= maxLen then -- 837
		return text -- 838
	end -- 838
	local nextPos = utf8.offset(text, maxLen + 1) -- 839
	if nextPos == nil then -- 839
		return text -- 840
	end -- 840
	return string.sub(text, 1, nextPos - 1) .. "..." -- 841
end -- 841
function utf8TakeHead(text, maxChars) -- 844
	if maxChars <= 0 or text == "" then -- 844
		return "" -- 845
	end -- 845
	local nextPos = utf8.offset(text, maxChars + 1) -- 846
	if nextPos == nil then -- 846
		return text -- 847
	end -- 847
	return string.sub(text, 1, nextPos - 1) -- 848
end -- 848
function utf8TakeTail(text, maxChars) -- 851
	if maxChars <= 0 or text == "" then -- 851
		return "" -- 852
	end -- 852
	local charLength = utf8.len(text) -- 853
	if charLength == nil or charLength <= maxChars then -- 853
		return text -- 854
	end -- 854
	local startPos = utf8.offset( -- 855
		text, -- 855
		math.max(1, charLength - maxChars + 1) -- 855
	) -- 855
	if startPos == nil then -- 855
		return text -- 856
	end -- 856
	return string.sub(text, startPos) -- 857
end -- 857
function truncateHistoryText(text, maxChars, label) -- 860
	if maxChars <= 0 or text == "" then -- 860
		return "" -- 861
	end -- 861
	if #text <= maxChars then -- 861
		return text -- 862
	end -- 862
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 863
	local remaining = math.max(0, maxChars - #marker) -- 864
	local headChars = math.floor(remaining * 0.6) -- 865
	local tailChars = remaining - headChars -- 866
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 867
end -- 867
function getReplyLanguageDirective(shared) -- 870
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 871
end -- 871
function replacePromptVars(template, vars) -- 876
	local output = template -- 877
	for key in pairs(vars) do -- 878
		output = table.concat( -- 879
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 879
			vars[key] or "" or "," -- 879
		) -- 879
	end -- 879
	return output -- 881
end -- 881
function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 884
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 900
	local contentLines = __TS__StringSplit(content, "\n") -- 901
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 902
	if #content <= maxChars and availableSourceLines <= maxLines then -- 902
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 904
	end -- 904
	local contentBudget = math.max(0, maxChars - 240) -- 915
	local candidateLines = math.min(availableSourceLines, maxLines) -- 916
	local retainedLines = {} -- 917
	local retainedChars = 0 -- 918
	do -- 918
		local i = 0 -- 919
		while i < candidateLines do -- 919
			local line = contentLines[i + 1] -- 920
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 921
			if nextChars > contentBudget then -- 921
				break -- 922
			end -- 922
			retainedLines[#retainedLines + 1] = line -- 923
			retainedChars = nextChars -- 924
			i = i + 1 -- 919
		end -- 919
	end -- 919
	local retainedEndLine = startLine + #retainedLines - 1 -- 927
	local partialLine -- 928
	local retainedContent = table.concat(retainedLines, "\n") -- 929
	if #retainedLines == 0 and candidateLines > 0 then -- 929
		partialLine = startLine -- 931
		retainedEndLine = startLine - 1 -- 932
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 933
	end -- 933
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 935
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 936
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 941
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 944
	return { -- 945
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 946
		truncated = true, -- 947
		retainedStartLine = startLine, -- 948
		retainedEndLine = retainedEndLine, -- 949
		nextStartLine = nextStartLine, -- 950
		partialLine = partialLine -- 951
	} -- 951
end -- 951
function sanitizeReadResultForHistory(tool, result) -- 967
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 967
		return result -- 969
	end -- 969
	local clone = {} -- 971
	for key in pairs(result) do -- 972
		clone[key] = result[key] -- 973
	end -- 973
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 975
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 976
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 977
	local limited = limitReadContentForHistory( -- 978
		result.content, -- 979
		startLine, -- 980
		endLine, -- 981
		totalLines, -- 982
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 983
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 984
		"read_file history" -- 985
	) -- 985
	clone.content = limited.content -- 987
	if limited.truncated then -- 987
		clone.historyContentTruncated = true -- 989
		clone.historyRetainedStartLine = limited.retainedStartLine -- 990
		clone.historyRetainedEndLine = limited.retainedEndLine -- 991
		if limited.nextStartLine ~= nil then -- 991
			clone.historyNextStartLine = limited.nextStartLine -- 992
		end -- 992
		if limited.partialLine ~= nil then -- 992
			clone.historyPartialLine = limited.partialLine -- 993
		end -- 993
	end -- 993
	return clone -- 995
end -- 995
function sanitizeSearchMatchesForHistory(items, maxItems) -- 998
	local shown = math.min(#items, maxItems) -- 1002
	local out = {} -- 1003
	do -- 1003
		local i = 0 -- 1004
		while i < shown do -- 1004
			local row = items[i + 1] -- 1005
			out[#out + 1] = { -- 1006
				file = row.file, -- 1007
				line = row.line, -- 1008
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1009
			} -- 1009
			i = i + 1 -- 1004
		end -- 1004
	end -- 1004
	return out -- 1014
end -- 1014
function sanitizeSearchResultForHistory(tool, result) -- 1017
	if result.success ~= true or not isArray(result.results) then -- 1017
		return result -- 1021
	end -- 1021
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1021
		return result -- 1022
	end -- 1022
	local clone = {} -- 1023
	for key in pairs(result) do -- 1024
		clone[key] = result[key] -- 1025
	end -- 1025
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 1027
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1028
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1028
		local grouped = result.groupedResults -- 1033
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 1034
		local sanitizedGroups = {} -- 1035
		do -- 1035
			local i = 0 -- 1036
			while i < shown do -- 1036
				local row = grouped[i + 1] -- 1037
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1038
					file = row.file, -- 1039
					totalMatches = row.totalMatches, -- 1040
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1041
				} -- 1041
				i = i + 1 -- 1036
			end -- 1036
		end -- 1036
		clone.groupedResults = sanitizedGroups -- 1046
	end -- 1046
	return clone -- 1048
end -- 1048
function sanitizeListFilesResultForHistory(result) -- 1051
	if result.success ~= true or not isArray(result.files) then -- 1051
		return result -- 1052
	end -- 1052
	local clone = {} -- 1053
	for key in pairs(result) do -- 1054
		clone[key] = result[key] -- 1055
	end -- 1055
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 1057
	return clone -- 1058
end -- 1058
function sanitizeBuildResultForHistory(result) -- 1061
	if not isArray(result.messages) then -- 1061
		return result -- 1062
	end -- 1062
	local clone = {} -- 1063
	for key in pairs(result) do -- 1064
		clone[key] = result[key] -- 1065
	end -- 1065
	local messages = result.messages -- 1067
	local ordered = __TS__ArraySort( -- 1068
		__TS__ArraySlice(messages), -- 1068
		function(____, a, b) -- 1068
			local aFailed = a.success ~= true -- 1069
			local bFailed = b.success ~= true -- 1070
			if aFailed == bFailed then -- 1070
				return 0 -- 1071
			end -- 1071
			return aFailed and -1 or 1 -- 1072
		end -- 1068
	) -- 1068
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1074
	local sanitized = {} -- 1075
	do -- 1075
		local i = 0 -- 1076
		while i < shown do -- 1076
			local item = ordered[i + 1] -- 1077
			local next = {} -- 1078
			for key in pairs(item) do -- 1079
				local value = item[key] -- 1080
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1081
			end -- 1081
			sanitized[#sanitized + 1] = next -- 1085
			i = i + 1 -- 1076
		end -- 1076
	end -- 1076
	clone.messages = sanitized -- 1087
	if #ordered > shown then -- 1087
		clone.truncatedMessages = #ordered - shown -- 1089
	end -- 1089
	return clone -- 1091
end -- 1091
function projectEditResultForLLM(result) -- 1109
	if result.success ~= true then -- 1109
		local failed = {} -- 1111
		for key in pairs(result) do -- 1112
			local value = result[key] -- 1113
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 1114
		end -- 1114
		return failed -- 1118
	end -- 1118
	local projected = {} -- 1120
	local scalarKeys = { -- 1121
		"success", -- 1122
		"changed", -- 1122
		"mode", -- 1122
		"checkpointId", -- 1122
		"checkpointSeq", -- 1122
		"checkpointed", -- 1123
		"reversible", -- 1123
		"binary", -- 1123
		"actualSaved", -- 1124
		"actualSavedCharacters", -- 1124
		"currentFileExists", -- 1124
		"currentCharacters", -- 1124
		"currentState" -- 1124
	} -- 1124
	do -- 1124
		local i = 0 -- 1126
		while i < #scalarKeys do -- 1126
			local key = scalarKeys[i + 1] -- 1127
			if result[key] ~= nil then -- 1127
				projected[key] = result[key] -- 1128
			end -- 1128
			i = i + 1 -- 1126
		end -- 1126
	end -- 1126
	if isArray(result.files) then -- 1126
		projected.files = result.files -- 1130
	end -- 1130
	if type(result.message) == "string" then -- 1130
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1132
	end -- 1132
	if type(result.guidance) == "string" then -- 1132
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1139
	end -- 1139
	if isArray(result.fileContext) then -- 1139
		local summaries = {} -- 1146
		do -- 1146
			local i = 0 -- 1147
			while i < #result.fileContext do -- 1147
				do -- 1147
					local item = result.fileContext[i + 1] -- 1148
					if not isRecord(item) or isArray(item) then -- 1148
						goto __continue157 -- 1149
					end -- 1149
					local summary = {} -- 1150
					local keys = { -- 1151
						"path", -- 1152
						"op", -- 1152
						"beforeExists", -- 1152
						"afterExists", -- 1152
						"beforeBytes", -- 1152
						"afterBytes", -- 1152
						"lineCount", -- 1153
						"contentTruncated", -- 1153
						"fileListTruncated" -- 1153
					} -- 1153
					do -- 1153
						local j = 0 -- 1155
						while j < #keys do -- 1155
							local key = keys[j + 1] -- 1156
							if item[key] ~= nil then -- 1156
								summary[key] = item[key] -- 1157
							end -- 1157
							j = j + 1 -- 1155
						end -- 1155
					end -- 1155
					summaries[#summaries + 1] = summary -- 1159
				end -- 1159
				::__continue157:: -- 1159
				i = i + 1 -- 1147
			end -- 1147
		end -- 1147
		if #summaries > 0 then -- 1147
			projected.fileSummary = summaries -- 1161
		end -- 1161
	end -- 1161
	if type(result.truncatedFileContextItems) == "number" then -- 1161
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1164
	end -- 1164
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1166
	return projected -- 1167
end -- 1167
function projectBuildResultForLLM(result) -- 1170
	if not isArray(result.messages) then -- 1170
		return result -- 1171
	end -- 1171
	local projected = {} -- 1172
	for key in pairs(result) do -- 1173
		if key ~= "messages" then -- 1173
			projected[key] = result[key] -- 1174
		end -- 1174
	end -- 1174
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1176
	local shown = math.min(#result.messages, maxMessages) -- 1177
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1178
	if #result.messages > shown then -- 1178
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1180
	end -- 1180
	return projected -- 1182
end -- 1182
function projectCommandResultForLLM(result) -- 1185
	local projected = {} -- 1186
	for key in pairs(result) do -- 1187
		local value = result[key] -- 1188
		if key == "output" and type(value) == "string" then -- 1188
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1190
		elseif key == "message" and type(value) == "string" then -- 1190
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1196
		else -- 1196
			projected[key] = value -- 1202
		end -- 1202
	end -- 1202
	return projected -- 1205
end -- 1205
function projectToolResultContentForLLM(tool, content) -- 1208
	local decoded = AgentUtils.safeJsonDecode(content) -- 1209
	if not isRecord(decoded) or isArray(decoded) then -- 1209
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1211
	end -- 1211
	local projected = decoded -- 1217
	if tool == "edit_file" or tool == "delete_file" then -- 1217
		projected = projectEditResultForLLM(decoded) -- 1219
	elseif tool == "build" then -- 1219
		projected = projectBuildResultForLLM(decoded) -- 1221
	elseif tool == "execute_command" then -- 1221
		projected = projectCommandResultForLLM(decoded) -- 1223
	end -- 1223
	local encoded = toJson(projected, false) -- 1225
	if tool == "read_file" then -- 1225
		return encoded -- 1228
	end -- 1228
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1228
		return encoded -- 1229
	end -- 1229
	local fallback = { -- 1230
		success = projected.success, -- 1231
		llmHistoryTruncated = true, -- 1232
		originalChars = #encoded, -- 1233
		preview = truncateHistoryText( -- 1234
			encoded, -- 1235
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1236
			tool .. " result" -- 1237
		) -- 1237
	} -- 1237
	return toJson(fallback, false) -- 1240
end -- 1240
function projectMessagesForLLMContext(messages) -- 1243
	local projected = {} -- 1247
	do -- 1247
		local i = 0 -- 1248
		while i < #messages do -- 1248
			local message = messages[i + 1] -- 1249
			local next = __TS__ObjectAssign({}, message) -- 1250
			if message.role == "tool" and type(message.content) == "string" then -- 1250
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1252
			end -- 1252
			projected[#projected + 1] = next -- 1254
			i = i + 1 -- 1248
		end -- 1248
	end -- 1248
	return projected -- 1256
end -- 1256
function ____exports.getDecisionDisabledAgentTools(shared) -- 1284
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1288
end -- 1284
function getDecisionToolDefinitions(shared) -- 1291
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1292
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1293
	local base = shared.promptPack.toolDefinitionsDetailed -- 1296
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1297
	if usesDefaultToolPrompts then -- 1297
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1300
			shared.role, -- 1300
			{ -- 1300
				includeFinish = true, -- 1301
				includeXmlRules = true, -- 1302
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1303
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1304
				workMode = shared.workMode -- 1305
			} -- 1305
		) -- 1305
		return replacePromptVars(definitions, params) -- 1307
	end -- 1307
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1309
	if (shared and shared.decisionMode) ~= "xml" then -- 1309
		return withRole -- 1314
	end -- 1314
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1316
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1317
end -- 1317
function isToolAllowedForRole(shared, tool) -- 1331
	return __TS__ArrayIndexOf( -- 1332
		AgentToolRegistry.getAllowedToolsForRole( -- 1332
			shared.role, -- 1332
			{ -- 1332
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1333
				workMode = shared.workMode -- 1334
			} -- 1334
		), -- 1334
		tool -- 1335
	) >= 0 -- 1335
end -- 1335
function getFinishMessage(params, fallback) -- 1798
	if fallback == nil then -- 1798
		fallback = "" -- 1798
	end -- 1798
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1798
		return __TS__StringTrim(params.message) -- 1800
	end -- 1800
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1800
		return __TS__StringTrim(params.response) -- 1803
	end -- 1803
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1803
		return __TS__StringTrim(params.summary) -- 1806
	end -- 1806
	return __TS__StringTrim(fallback) -- 1808
end -- 1808
function getCompletionReport(params) -- 1811
	return AgentUtils.normalizeAgentCompletionReport(params) -- 1812
end -- 1812
function persistHistoryState(shared) -- 1815
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1816
end -- 1816
function getActiveConversationMessages(shared) -- 1823
	local activeMessages = {} -- 1824
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1824
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1831
	end -- 1831
	do -- 1831
		local i = shared.lastConsolidatedIndex -- 1835
		while i < #shared.messages do -- 1835
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1836
			i = i + 1 -- 1835
		end -- 1835
	end -- 1835
	return activeMessages -- 1838
end -- 1838
function getActiveRealMessageCount(shared) -- 1841
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1842
end -- 1842
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1845
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1851
	local previousActiveStart = shared.lastConsolidatedIndex -- 1852
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1853
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1854
	if type(carryMessageIndex) == "number" then -- 1854
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1854
		else -- 1854
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1862
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1865
		end -- 1865
	else -- 1865
		shared.carryMessageIndex = nil -- 1870
	end -- 1870
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1870
		shared.carryMessageIndex = nil -- 1880
	end -- 1880
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1888
	shared.resumeCheckpointPending = true -- 1889
	shared.resumeRequiredTool = nil -- 1890
	shared.resumeNarrowReadMode = true -- 1891
	if shared.unbuiltEdits == true then -- 1891
		shared.resumeRequiredTool = "build" -- 1899
	end -- 1899
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 -- 1908
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1908
		local marker = "**Next tool**:" -- 1919
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1920
		if markerIndex >= 0 then -- 1920
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1922
			local toolNames = AgentToolRegistry.getBuiltInAgentToolNames() -- 1923
			do -- 1923
				local i = 0 -- 1924
				while i < #toolNames do -- 1924
					local tool = toolNames[i + 1] -- 1925
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1925
						shared.resumeRequiredTool = tool -- 1927
						break -- 1928
					end -- 1928
					i = i + 1 -- 1924
				end -- 1924
			end -- 1924
		end -- 1924
	end -- 1924
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1924
		shared.resumeRequiredTool = nil -- 1934
	end -- 1934
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1934
		shared.resumeRequiredTool = nil -- 1937
	end -- 1937
end -- 1937
function ensureToolCallId(toolCallId) -- 1952
	if toolCallId and toolCallId ~= "" then -- 1952
		return toolCallId -- 1953
	end -- 1953
	return AgentUtils.createLocalToolCallId() -- 1954
end -- 1954
function hasXMLParam(params, name) -- 1987
	return params[name] ~= nil -- 1988
end -- 1988
function inferToolNameFromXMLParams(params) -- 1991
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1991
		return "edit_file" -- 1993
	end -- 1993
	if hasXMLParam(params, "target_file") then -- 1993
		return "delete_file" -- 1996
	end -- 1996
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1996
		if hasXMLParam(params, "path") then -- 1996
			return "read_file" -- 1999
		end -- 1999
		return nil -- 2000
	end -- 2000
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 2000
		if hasXMLParam(params, "pattern") then -- 2000
			return "search_dora_api" -- 2003
		end -- 2003
		return nil -- 2004
	end -- 2004
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 2004
		if hasXMLParam(params, "pattern") then -- 2004
			return "grep_files" -- 2007
		end -- 2007
		return nil -- 2008
	end -- 2008
	if hasXMLParam(params, "globs") then -- 2008
		if hasXMLParam(params, "pattern") then -- 2008
			return "grep_files" -- 2011
		end -- 2011
		return "glob_files" -- 2012
	end -- 2012
	if hasXMLParam(params, "maxEntries") then -- 2012
		return "glob_files" -- 2015
	end -- 2015
	local audioTool = AudioToolRuntime.inferAudioToolNameFromParams(params) -- 2017
	if audioTool ~= nil then -- 2017
		return audioTool -- 2018
	end -- 2018
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2018
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
						goto __continue454 -- 2638
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
					goto __continue454 -- 2669
				end -- 2669
				if message.role == "tool" then -- 2669
					droppedToolResults = droppedToolResults + 1 -- 2672
					goto __continue454 -- 2673
				end -- 2673
				sanitized[#sanitized + 1] = message -- 2675
			end -- 2675
			::__continue454:: -- 2675
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
function executeToolAction(shared, action) -- 4026
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4026
		if shared.stopToken.stopped then -- 4026
			return ____awaiter_resolve( -- 4026
				nil, -- 4026
				{ -- 4028
					success = false, -- 4028
					message = getCancelledReason(shared) -- 4028
				} -- 4028
			) -- 4028
		end -- 4028
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4028
			shared.resumeRequiredTool = nil -- 4031
			shared.resumeCheckpointPending = false -- 4032
		end -- 4032
		local params = action.params -- 4034
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4035
		if not sharedValidation.success then -- 4035
			return ____awaiter_resolve(nil, sharedValidation) -- 4035
		end -- 4035
		if action.tool == "read_file" then -- 4035
			local ____params_startLine_149 = params.startLine -- 4038
			if ____params_startLine_149 == nil then -- 4038
				____params_startLine_149 = 1 -- 4038
			end -- 4038
			local startLine = __TS__Number(____params_startLine_149) -- 4038
			local ____params_endLine_150 = params.endLine -- 4039
			if ____params_endLine_150 == nil then -- 4039
				____params_endLine_150 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4039
			end -- 4039
			local endLine = __TS__Number(____params_endLine_150) -- 4039
			local clippedAfterCompression = false -- 4040
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4040
				endLine = startLine + 159 -- 4047
				clippedAfterCompression = true -- 4048
			end -- 4048
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4050
			if __TS__StringTrim(path) == "" then -- 4050
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4050
			end -- 4050
			local result = Tools.readFile( -- 4054
				shared.workingDir, -- 4055
				path, -- 4056
				startLine, -- 4057
				endLine, -- 4058
				shared.useChineseResponse and "zh" or "en" -- 4059
			) -- 4059
			if clippedAfterCompression and result.success == true then -- 4059
				result.clipped = true -- 4062
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4063
			end -- 4063
			return ____awaiter_resolve(nil, result) -- 4063
		end -- 4063
		if action.tool == "grep_files" then -- 4063
			local searchPath = params.path or "" -- 4070
			local searchGlobs = params.globs -- 4071
			local ____Tools_searchFiles_164 = Tools.searchFiles -- 4072
			local ____shared_workingDir_157 = shared.workingDir -- 4073
			local ____temp_158 = params.pattern or "" -- 4075
			local ____params_globs_159 = params.globs -- 4076
			local ____params_useRegex_160 = params.useRegex -- 4077
			local ____params_caseSensitive_161 = params.caseSensitive -- 4078
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4080
			local ____math_max_153 = math.max -- 4081
			local ____math_floor_152 = math.floor -- 4081
			local ____params_limit_151 = params.limit -- 4081
			if ____params_limit_151 == nil then -- 4081
				____params_limit_151 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4081
			end -- 4081
			local ____math_max_153_result_163 = ____math_max_153( -- 4081
				1, -- 4081
				____math_floor_152(__TS__Number(____params_limit_151)) -- 4081
			) -- 4081
			local ____math_max_156 = math.max -- 4082
			local ____math_floor_155 = math.floor -- 4082
			local ____params_offset_154 = params.offset -- 4082
			if ____params_offset_154 == nil then -- 4082
				____params_offset_154 = 0 -- 4082
			end -- 4082
			local result = __TS__Await(____Tools_searchFiles_164({ -- 4072
				workDir = ____shared_workingDir_157, -- 4073
				path = searchPath, -- 4074
				pattern = ____temp_158, -- 4075
				globs = ____params_globs_159, -- 4076
				useRegex = ____params_useRegex_160, -- 4077
				caseSensitive = ____params_caseSensitive_161, -- 4078
				includeContent = true, -- 4079
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162, -- 4080
				limit = ____math_max_153_result_163, -- 4081
				offset = ____math_max_156( -- 4082
					0, -- 4082
					____math_floor_155(__TS__Number(____params_offset_154)) -- 4082
				), -- 4082
				groupByFile = params.groupByFile == true -- 4083
			})) -- 4083
			return ____awaiter_resolve(nil, result) -- 4083
		end -- 4083
		if action.tool == "search_dora_api" then -- 4083
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4088
			local ____Tools_searchDoraAPI_173 = Tools.searchDoraAPI -- 4089
			local ____temp_169 = params.pattern or "" -- 4090
			local ____temp_170 = params.docSource or "api" -- 4091
			local ____temp_171 = shared.useChineseResponse and "zh" or "en" -- 4092
			local ____temp_172 = params.programmingLanguage or "ts" -- 4093
			local ____math_min_168 = math.min -- 4094
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4094
			local ____math_max_166 = math.max -- 4094
			local ____params_limit_165 = params.limit -- 4094
			if ____params_limit_165 == nil then -- 4094
				____params_limit_165 = 8 -- 4094
			end -- 4094
			local result = __TS__Await(____Tools_searchDoraAPI_173({ -- 4089
				pattern = ____temp_169, -- 4090
				docSource = ____temp_170, -- 4091
				docLanguage = ____temp_171, -- 4092
				programmingLanguage = ____temp_172, -- 4093
				limit = ____math_min_168( -- 4094
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167, -- 4094
					____math_max_166( -- 4094
						1, -- 4094
						__TS__Number(____params_limit_165) -- 4094
					) -- 4094
				), -- 4094
				useRegex = params.useRegex, -- 4095
				caseSensitive = false, -- 4096
				includeContent = true, -- 4097
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4098
			})) -- 4098
			return ____awaiter_resolve(nil, result) -- 4098
		end -- 4098
		if action.tool == "glob_files" then -- 4098
			local ____Tools_listFiles_180 = Tools.listFiles -- 4103
			local ____shared_workingDir_177 = shared.workingDir -- 4104
			local ____temp_178 = params.path or "" -- 4105
			local ____params_globs_179 = params.globs -- 4106
			local ____math_max_176 = math.max -- 4107
			local ____math_floor_175 = math.floor -- 4107
			local ____params_maxEntries_174 = params.maxEntries -- 4107
			if ____params_maxEntries_174 == nil then -- 4107
				____params_maxEntries_174 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4107
			end -- 4107
			local result = ____Tools_listFiles_180({ -- 4103
				workDir = ____shared_workingDir_177, -- 4104
				path = ____temp_178, -- 4105
				globs = ____params_globs_179, -- 4106
				maxEntries = ____math_max_176( -- 4107
					1, -- 4107
					____math_floor_175(__TS__Number(____params_maxEntries_174)) -- 4107
				) -- 4107
			}) -- 4107
			return ____awaiter_resolve(nil, result) -- 4107
		end -- 4107
		if action.tool == "ask_user" then -- 4107
			if not shared.publishQuestionnaire then -- 4107
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4107
			end -- 4107
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4107
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4107
			end -- 4107
			local normalized = normalizeQuestionnaire(params) -- 4114
			if not normalized.success then -- 4114
				return ____awaiter_resolve(nil, normalized) -- 4114
			end -- 4114
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4116
			if not result.success then -- 4116
				return ____awaiter_resolve(nil, result) -- 4116
			end -- 4116
			shared.waitingQuestionnaireId = result.questionnaireId -- 4123
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4123
		end -- 4123
		if action.tool == "delete_file" then -- 4123
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4127
			if __TS__StringTrim(targetFile) == "" then -- 4127
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4127
			end -- 4127
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4131
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4132
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4132
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4132
			end -- 4132
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4136
			local result = Tools.deleteFile(shared.taskId, shared.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4137
			if not result.success then -- 4137
				return ____awaiter_resolve(nil, result) -- 4137
			end -- 4137
			if not isInternalDocumentEdit then -- 4137
				shared.unbuiltEdits = true -- 4145
				shared.lastBuildSucceeded = false -- 4146
				if shared.failedTestNeedsBuild == true then -- 4146
					shared.failedTestHasSourceEdit = true -- 4147
				end -- 4147
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4147
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4148
				end -- 4148
				shared.editedPathsSinceBuild = editedPaths -- 4149
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4150
			end -- 4150
			local ____result_checkpointed_182 = result.checkpointed -- 4156
			local ____result_reversible_183 = result.reversible -- 4157
			local ____result_binary_184 = result.binary -- 4158
			local ____temp_185 = result.checkpointed and result.checkpointId or nil -- 4159
			local ____temp_186 = result.checkpointed and result.checkpointSeq or nil -- 4160
			local ____result_checkpointed_181 -- 4161
			if result.checkpointed then -- 4161
				____result_checkpointed_181 = nil -- 4161
			else -- 4161
				____result_checkpointed_181 = result.message -- 4161
			end -- 4161
			return ____awaiter_resolve(nil, { -- 4161
				success = true, -- 4153
				changed = true, -- 4154
				mode = "delete", -- 4155
				checkpointed = ____result_checkpointed_182, -- 4156
				reversible = ____result_reversible_183, -- 4157
				binary = ____result_binary_184, -- 4158
				checkpointId = ____temp_185, -- 4159
				checkpointSeq = ____temp_186, -- 4160
				message = ____result_checkpointed_181, -- 4161
				files = {{path = targetFile, op = "delete"}} -- 4162
			}) -- 4162
		end -- 4162
		if action.tool == "build" then -- 4162
			local buildPath = params.path or "" -- 4166
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4167
			shared.unbuiltEdits = false -- 4171
			shared.editsSinceBuild = 0 -- 4172
			shared.editedPathsSinceBuild = {} -- 4173
			shared.hasBuilt = true -- 4174
			shared.lastBuildSucceeded = result.success -- 4175
			if result.success and shared.freshProjectBuildPending == true then -- 4175
				shared.freshProjectBuildPending = false -- 4181
			end -- 4181
			shared.apiSearchesSinceBuild = 0 -- 4183
			shared.buildRepairPending = false -- 4184
			if not result.success and result.messages ~= nil then -- 4184
				do -- 4184
					local i = 0 -- 4186
					while i < #result.messages do -- 4186
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4186
							shared.buildRepairPending = true -- 4188
							break -- 4189
						end -- 4189
						i = i + 1 -- 4186
					end -- 4186
				end -- 4186
			end -- 4186
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4186
				shared.failedTestNeedsBuild = false -- 4194
				shared.failedTestHasSourceEdit = false -- 4195
			end -- 4195
			return ____awaiter_resolve(nil, result) -- 4195
		end -- 4195
		if action.tool == "fetch_url" then -- 4195
			local result = __TS__Await(Tools.fetchUrl({ -- 4200
				workDir = shared.workingDir, -- 4201
				url = type(params.url) == "string" and params.url or "", -- 4202
				target = type(params.target) == "string" and params.target or "", -- 4203
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4204
				onProgress = function(____, progress) -- 4205
					emitAgentEvent( -- 4206
						shared, -- 4206
						{ -- 4206
							type = "tool_progress", -- 4207
							sessionId = shared.sessionId, -- 4208
							taskId = shared.taskId, -- 4209
							step = action.step, -- 4210
							tool = action.tool, -- 4211
							result = __TS__ObjectAssign({success = false}, progress) -- 4212
						} -- 4212
					) -- 4212
				end -- 4205
			})) -- 4205
			return ____awaiter_resolve(nil, result) -- 4205
		end -- 4205
		if AudioToolRuntime.isAudioAgentToolName(action.tool) then -- 4205
			local result = __TS__Await(AudioToolRuntime.executeAudioTool({ -- 4222
				tool = action.tool, -- 4223
				params = params, -- 4224
				workDir = shared.workingDir, -- 4225
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4226
				onProgress = function(____, progress) -- 4227
					emitAgentEvent( -- 4228
						shared, -- 4228
						{ -- 4228
							type = "tool_progress", -- 4229
							sessionId = shared.sessionId, -- 4230
							taskId = shared.taskId, -- 4231
							step = action.step, -- 4232
							tool = action.tool, -- 4233
							result = __TS__ObjectAssign({success = false}, progress) -- 4234
						} -- 4234
					) -- 4234
				end -- 4227
			})) -- 4227
			return ____awaiter_resolve(nil, result) -- 4227
		end -- 4227
		if action.tool == "execute_command" then -- 4227
			local mode = type(params.mode) == "string" and params.mode or "" -- 4244
			local result = __TS__Await(Tools.executeCommand({ -- 4245
				workDir = shared.workingDir, -- 4246
				mode = mode, -- 4247
				code = type(params.code) == "string" and params.code or nil, -- 4248
				command = type(params.command) == "string" and params.command or nil, -- 4249
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4250
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4251
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4252
				onProgress = function(____, progress) -- 4253
					emitAgentEvent( -- 4254
						shared, -- 4254
						{ -- 4254
							type = "tool_progress", -- 4255
							sessionId = shared.sessionId, -- 4256
							taskId = shared.taskId, -- 4257
							step = action.step, -- 4258
							tool = action.tool, -- 4259
							result = __TS__ObjectAssign({success = false}, progress) -- 4260
						} -- 4260
					) -- 4260
				end -- 4253
			})) -- 4253
			if result.success and mode == "lua" then -- 4253
				local deterministicFailure = false -- 4268
				local deterministicPass = false -- 4269
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4270
				do -- 4270
					local i = 0 -- 4271
					while i < #outputLines and not deterministicFailure do -- 4271
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4272
						if line == "passed" then -- 4272
							deterministicPass = true -- 4273
						end -- 4273
						if line == "failed" then -- 4273
							deterministicFailure = true -- 4275
							break -- 4276
						end -- 4276
						local searchFrom = 0 -- 4278
						while searchFrom < #line do -- 4278
							local failedIndex = (string.find( -- 4280
								line, -- 4280
								"failed", -- 4280
								math.max(searchFrom + 1, 1), -- 4280
								true -- 4280
							) or 0) - 1 -- 4280
							if failedIndex < 0 then -- 4280
								break -- 4281
							end -- 4281
							local after = failedIndex + #"failed" -- 4282
							while after < #line do -- 4282
								local ch = __TS__StringSlice(line, after, after + 1) -- 4284
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4284
									break -- 4285
								end -- 4285
								after = after + 1 -- 4286
							end -- 4286
							local afterEnd = after -- 4288
							while afterEnd < #line do -- 4288
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4290
								if ch < "0" or ch > "9" then -- 4290
									break -- 4291
								end -- 4291
								afterEnd = afterEnd + 1 -- 4292
							end -- 4292
							local count -- 4294
							if afterEnd > after then -- 4294
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4296
							else -- 4296
								local before = failedIndex - 1 -- 4298
								while before >= 0 do -- 4298
									local ch = __TS__StringSlice(line, before, before + 1) -- 4300
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4300
										break -- 4301
									end -- 4301
									before = before - 1 -- 4302
								end -- 4302
								local beforeEnd = before + 1 -- 4304
								while before >= 0 do -- 4304
									local ch = __TS__StringSlice(line, before, before + 1) -- 4306
									if ch < "0" or ch > "9" then -- 4306
										break -- 4307
									end -- 4307
									before = before - 1 -- 4308
								end -- 4308
								if beforeEnd > before + 1 then -- 4308
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4310
								end -- 4310
							end -- 4310
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4310
								deterministicFailure = true -- 4313
								break -- 4314
							end -- 4314
							searchFrom = failedIndex + #"failed" -- 4316
						end -- 4316
						i = i + 1 -- 4271
					end -- 4271
				end -- 4271
				if deterministicFailure then -- 4271
					shared.failedTestNeedsBuild = true -- 4320
					shared.failedTestHasSourceEdit = false -- 4321
				elseif deterministicPass then -- 4321
					shared.failedTestNeedsBuild = false -- 4323
					shared.failedTestHasSourceEdit = false -- 4324
				end -- 4324
			end -- 4324
			return ____awaiter_resolve(nil, result) -- 4324
		end -- 4324
		if action.tool == "spawn_sub_agent" then -- 4324
			if not shared.spawnSubAgent then -- 4324
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4324
			end -- 4324
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4324
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4324
			end -- 4324
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4336
				params.filesHint, -- 4337
				function(____, item) return type(item) == "string" end -- 4337
			) or nil -- 4337
			local result = __TS__Await(shared.spawnSubAgent({ -- 4339
				parentSessionId = shared.sessionId, -- 4340
				projectRoot = shared.workingDir, -- 4341
				title = type(params.title) == "string" and params.title or "Sub", -- 4342
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4343
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4344
				filesHint = filesHint, -- 4345
				disabledAgentTools = shared.disabledAgentTools -- 4346
			})) -- 4346
			if not result.success then -- 4346
				return ____awaiter_resolve(nil, result) -- 4346
			end -- 4346
			shared.hasSpawnedSubAgentThisTask = true -- 4351
			return ____awaiter_resolve(nil, { -- 4351
				success = true, -- 4353
				sessionId = result.sessionId, -- 4354
				taskId = result.taskId, -- 4355
				title = result.title, -- 4356
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4357
			}) -- 4357
		end -- 4357
		if action.tool == "list_sub_agents" then -- 4357
			if not shared.listSubAgents then -- 4357
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4357
			end -- 4357
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4357
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4357
			end -- 4357
			local result = __TS__Await(shared.listSubAgents({ -- 4367
				sessionId = shared.sessionId, -- 4368
				projectRoot = shared.workingDir, -- 4369
				status = type(params.status) == "string" and params.status or nil, -- 4370
				limit = type(params.limit) == "number" and params.limit or nil, -- 4371
				offset = type(params.offset) == "number" and params.offset or nil, -- 4372
				query = type(params.query) == "string" and params.query or nil -- 4373
			})) -- 4373
			return ____awaiter_resolve(nil, result) -- 4373
		end -- 4373
		if action.tool == "edit_file" then -- 4373
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4378
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4381
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4382
			if __TS__StringTrim(path) == "" then -- 4382
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4382
			end -- 4382
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4384
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4385
			if not isInternalDocumentEdit then -- 4385
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4387
				if preflightIssue ~= nil then -- 4387
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4389
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4390
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4390
				end -- 4390
			end -- 4390
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4396
			local result = __TS__Await(actionNode:exec({ -- 4397
				path = path, -- 4398
				oldStr = oldStr, -- 4399
				newStr = newStr, -- 4400
				taskId = shared.taskId, -- 4401
				workDir = shared.workingDir -- 4402
			})) -- 4402
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4402
				if params.partialStreamRecovery ~= true then -- 4402
					shared.truncatedToolOverwritePath = nil -- 4406
				end -- 4406
				shared.unbuiltEdits = true -- 4408
				shared.lastBuildSucceeded = false -- 4409
				if shared.failedTestNeedsBuild == true then -- 4409
					shared.failedTestHasSourceEdit = true -- 4410
				end -- 4410
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4411
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4411
					editedPaths[#editedPaths + 1] = normalizedPath -- 4412
				end -- 4412
				shared.editedPathsSinceBuild = editedPaths -- 4413
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4414
			end -- 4414
			return ____awaiter_resolve(nil, result) -- 4414
		end -- 4414
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4414
	end) -- 4414
end -- 4414
function sanitizeToolActionResultForHistory(action, result) -- 4421
	if action.tool == "read_file" then -- 4421
		return sanitizeReadResultForHistory(action.tool, result) -- 4423
	end -- 4423
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4423
		return sanitizeSearchResultForHistory(action.tool, result) -- 4426
	end -- 4426
	if action.tool == "glob_files" then -- 4426
		return sanitizeListFilesResultForHistory(result) -- 4429
	end -- 4429
	if action.tool == "build" then -- 4429
		return sanitizeBuildResultForHistory(result) -- 4432
	end -- 4432
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4432
		if result.success ~= true then -- 4432
			return result -- 4435
		end -- 4435
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4435
			return result -- 4436
		end -- 4436
		if isArray(result.fileContext) then -- 4436
			return result -- 4437
		end -- 4437
		local contextLimits = { -- 4439
			fullContentChars = 12000, -- 4440
			previewChars = 4000, -- 4441
			diffChars = 8000, -- 4442
			totalChars = 24000, -- 4443
			maxFiles = 8 -- 4444
		} -- 4444
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4446
			if maxChars <= 0 then -- 4446
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4447
			end -- 4447
			if #sourceText <= maxChars then -- 4447
				return sourceText -- 4448
			end -- 4448
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4449
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4450
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4451
		end -- 4446
		local function countLines(sourceText) -- 4453
			if sourceText == "" then -- 4453
				return 0 -- 4454
			end -- 4454
			return #__TS__StringSplit(sourceText, "\n") -- 4455
		end -- 4453
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4457
			if beforeContent == afterContent then -- 4457
				return "" -- 4458
			end -- 4458
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4459
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4460
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4462
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4462
				firstChangedLine = firstChangedLine + 1 -- 4468
			end -- 4468
			local lastChangedBeforeLine = #beforeLines - 1 -- 4470
			local lastChangedAfterLine = #afterLines - 1 -- 4471
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4471
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4477
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4478
			end -- 4478
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4480
			local previewEndLine = math.max( -- 4481
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4482
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4483
			) -- 4483
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4485
			do -- 4485
				local lineIndex = previewStartLine -- 4486
				while lineIndex <= previewEndLine do -- 4486
					do -- 4486
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4487
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4488
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4489
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4490
						if not beforeChanged and not afterChanged then -- 4490
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4492
							if contextLine ~= nil then -- 4492
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4493
							end -- 4493
							goto __continue737 -- 4494
						end -- 4494
						if beforeChanged and beforeLine ~= nil then -- 4494
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4496
						end -- 4496
						if afterChanged and afterLine ~= nil then -- 4496
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4497
						end -- 4497
					end -- 4497
					::__continue737:: -- 4497
					lineIndex = lineIndex + 1 -- 4486
				end -- 4486
			end -- 4486
			return truncateContextSnippet( -- 4499
				table.concat(unifiedDiffLines, "\n"), -- 4499
				maxChars, -- 4499
				"diff" -- 4499
			) -- 4499
		end -- 4457
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4502
		if not checkpointDiff.success then -- 4502
			return result -- 4503
		end -- 4503
		local remainingContextBudget = contextLimits.totalChars -- 4504
		local fileContextItems = {} -- 4505
		local changedFiles = checkpointDiff.files -- 4506
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4507
		do -- 4507
			local fileIndex = 0 -- 4508
			while fileIndex < maxContextFiles do -- 4508
				if remainingContextBudget <= 0 then -- 4508
					break -- 4509
				end -- 4509
				local changedFile = changedFiles[fileIndex + 1] -- 4510
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4511
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4512
				local contextItem = { -- 4513
					path = changedFile.path, -- 4514
					op = changedFile.op, -- 4515
					checkpointId = result.checkpointId, -- 4516
					checkpointSeq = result.checkpointSeq, -- 4517
					beforeExists = changedFile.beforeExists, -- 4518
					afterExists = changedFile.afterExists, -- 4519
					beforeBytes = #beforeContent, -- 4520
					afterBytes = #afterContent, -- 4521
					diffPreview = "", -- 4522
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4523
					contentTruncated = false, -- 4524
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4525
				} -- 4525
				if changedFile.afterExists then -- 4525
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4525
						contextItem.afterContent = afterContent -- 4529
						remainingContextBudget = remainingContextBudget - #afterContent -- 4530
					else -- 4530
						contextItem.afterContentPreview = truncateContextSnippet( -- 4532
							afterContent, -- 4533
							math.min( -- 4534
								contextLimits.previewChars, -- 4534
								math.max(400, remainingContextBudget) -- 4534
							), -- 4534
							"afterContent" -- 4535
						) -- 4535
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4537
						contextItem.contentTruncated = true -- 4538
					end -- 4538
				end -- 4538
				local diffPreview = buildUnifiedDiffPreview( -- 4541
					changedFile.path, -- 4542
					beforeContent, -- 4543
					afterContent, -- 4544
					math.min( -- 4545
						contextLimits.diffChars, -- 4545
						math.max(400, remainingContextBudget) -- 4545
					) -- 4545
				) -- 4545
				contextItem.diffPreview = diffPreview -- 4547
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4548
				if not changedFile.afterExists and beforeContent ~= "" then -- 4548
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4550
						beforeContent, -- 4551
						math.min( -- 4552
							contextLimits.previewChars, -- 4552
							math.max(400, remainingContextBudget) -- 4552
						), -- 4552
						"beforeContent" -- 4553
					) -- 4553
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4555
					if #beforeContent > contextLimits.previewChars then -- 4555
						contextItem.contentTruncated = true -- 4556
					end -- 4556
				end -- 4556
				fileContextItems[#fileContextItems + 1] = contextItem -- 4558
				fileIndex = fileIndex + 1 -- 4508
			end -- 4508
		end -- 4508
		if #fileContextItems == 0 then -- 4508
			return result -- 4560
		end -- 4560
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4561
	end -- 4561
	return result -- 4568
end -- 4568
function emitAgentTaskFinishEvent(shared, success, message) -- 4769
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4770
	local result = success and ({ -- 4774
		success = true, -- 4776
		taskId = shared.taskId, -- 4777
		message = message, -- 4778
		steps = shared.step, -- 4779
		completion = completion -- 4780
	}) or ({ -- 4780
		success = false, -- 4783
		taskId = shared.taskId, -- 4784
		message = message, -- 4785
		steps = shared.step, -- 4786
		completion = completion -- 4787
	}) -- 4787
	emitAgentEvent(shared, { -- 4789
		type = "task_finished", -- 4790
		sessionId = shared.sessionId, -- 4791
		taskId = shared.taskId, -- 4792
		success = result.success, -- 4793
		message = result.message, -- 4794
		steps = result.steps, -- 4795
		completion = result.completion -- 4796
	}) -- 4796
	return result -- 4798
end -- 4798
local function buildLLMOptions(llmConfig, overrides) -- 302
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 303
	if llmConfig.reasoningEffort then -- 303
		options.reasoning_effort = llmConfig.reasoningEffort -- 308
	end -- 308
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 310
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 310
		__TS__Delete(merged, "reasoning_effort") -- 315
	else -- 315
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 317
	end -- 317
	__TS__Delete(merged, "tool_choice") -- 322
	return merged -- 323
end -- 302
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 454
	local fitted = AgentUtils.fitMessagesToContext(messages, options, shared.llmConfig) -- 461
	local messagesTokens = fitted.originalTokens -- 462
	local toolDefinitionsTokens = 0 -- 464
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 464
		local toolsText = AgentUtils.safeJsonEncode(options.tools) -- 466
		toolDefinitionsTokens = toolsText and AgentUtils.estimateTextTokens(toolsText) or 0 -- 467
	end -- 467
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 470
	__TS__Delete(optionsWithoutTools, "tools") -- 471
	local optionsText = AgentUtils.safeJsonEncode(optionsWithoutTools) -- 472
	local optionsTokens = optionsText and AgentUtils.estimateTextTokens(optionsText) or 0 -- 473
	local contextWindow = shared.llmConfig.contextWindow > 0 and math.floor(shared.llmConfig.contextWindow) or 64000 -- 474
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 477
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 482
		1024, -- 484
		math.floor(contextWindow * 0.2) -- 484
	) -- 484
	local structuralOverhead = math.max(256, #messages * 16) -- 485
	local usedTokens = messagesTokens + math.max(0, contextWindow - fitted.budgetTokens) -- 489
	local maxTokens = contextWindow -- 490
	emitAgentEvent( -- 491
		shared, -- 491
		{ -- 491
			type = "metrics_updated", -- 492
			sessionId = shared.sessionId, -- 493
			taskId = shared.taskId, -- 494
			step = step, -- 495
			metrics = {context = { -- 496
				usedTokens = usedTokens, -- 498
				maxTokens = maxTokens, -- 499
				ratio = math.max( -- 500
					0, -- 500
					math.min(1, usedTokens / maxTokens) -- 500
				), -- 500
				messagesTokens = messagesTokens, -- 501
				optionsTokens = optionsTokens, -- 502
				toolDefinitionsTokens = toolDefinitionsTokens, -- 503
				reservedOutputTokens = reservedOutputTokens, -- 504
				structuralOverhead = structuralOverhead, -- 505
				contextWindow = contextWindow, -- 506
				source = "llm_input_estimate", -- 507
				updatedAt = os.time(), -- 508
				phase = phase, -- 509
				step = step -- 510
			}} -- 510
		} -- 510
	) -- 510
end -- 454
local function recordLLMTokenUsage(shared, step, phase, usage) -- 516
	if not usage then -- 516
		return -- 517
	end -- 517
	local current = shared.tokenUsage -- 518
	local cachedReported = usage.cachedInputTokens ~= nil -- 519
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 520
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 521
	local next = { -- 522
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 523
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 524
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 525
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 526
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 529
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 532
		requestCount = (current and current.requestCount or 0) + 1, -- 535
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 536
		model = shared.llmConfig.model, -- 539
		phase = phase, -- 540
		step = step, -- 541
		updatedAt = os.time() -- 542
	} -- 542
	shared.tokenUsage = next -- 544
	emitAgentEvent(shared, { -- 545
		type = "metrics_updated", -- 546
		sessionId = shared.sessionId, -- 547
		taskId = shared.taskId, -- 548
		step = step, -- 549
		metrics = {usage = next} -- 550
	}) -- 550
end -- 516
local function emitAgentStartEvent(shared, action) -- 554
	emitAgentEvent(shared, { -- 555
		type = "tool_started", -- 556
		sessionId = shared.sessionId, -- 557
		taskId = shared.taskId, -- 558
		step = action.step, -- 559
		tool = action.tool -- 560
	}) -- 560
end -- 554
local function emitAgentFinishEvent(shared, action) -- 564
	emitAgentEvent(shared, { -- 565
		type = "tool_finished", -- 566
		sessionId = shared.sessionId, -- 567
		taskId = shared.taskId, -- 568
		step = action.step, -- 569
		tool = action.tool, -- 570
		result = action.result or ({}) -- 571
	}) -- 571
end -- 564
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 575
	emitAgentEvent(shared, { -- 576
		type = "assistant_message_updated", -- 577
		sessionId = shared.sessionId, -- 578
		taskId = shared.taskId, -- 579
		step = shared.step + 1, -- 580
		content = content, -- 581
		reasoningContent = reasoningContent -- 582
	}) -- 582
end -- 575
local function getMemoryCompressionStartReason(shared) -- 586
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 587
end -- 586
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 592
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 593
end -- 592
local function getMemoryCompressionFailureReason(shared, ____error) -- 598
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 599
end -- 598
local function summarizeHistoryEntryPreview(text, maxChars) -- 604
	if maxChars == nil then -- 604
		maxChars = 180 -- 604
	end -- 604
	local trimmed = __TS__StringTrim(text) -- 605
	if trimmed == "" then -- 605
		return "" -- 606
	end -- 606
	return truncateText(trimmed, maxChars) -- 607
end -- 604
local function getMaxStepsReachedReason(shared) -- 615
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 616
end -- 615
local function getFailureSummaryFallback(shared, ____error) -- 621
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 622
end -- 621
local function finalizeAgentFailure(shared, ____error) -- 627
	if shared.stopToken.stopped then -- 627
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 629
		return emitAgentTaskFinishEvent( -- 630
			shared, -- 630
			false, -- 630
			getCancelledReason(shared) -- 630
		) -- 630
	end -- 630
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 632
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 633
end -- 627
local function getPromptCommand(prompt) -- 636
	local trimmed = __TS__StringTrim(prompt) -- 637
	if trimmed == "/compact" then -- 637
		return "compact" -- 638
	end -- 638
	if trimmed == "/clear" then -- 638
		return "clear" -- 639
	end -- 639
	return nil -- 640
end -- 636
function ____exports.truncateAgentUserPrompt(prompt) -- 643
	if not prompt then -- 643
		return "" -- 644
	end -- 644
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 644
		return prompt -- 645
	end -- 645
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 646
	if offset == nil then -- 646
		return prompt -- 647
	end -- 647
	return string.sub(prompt, 1, offset - 1) -- 648
end -- 643
local function canWriteStepLLMDebug(shared, stepId) -- 651
	if stepId == nil then -- 651
		stepId = shared.step + 1 -- 651
	end -- 651
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 652
end -- 651
local function ensureDirRecursive(dir) -- 659
	if not dir then -- 659
		return false -- 660
	end -- 660
	if Content:exist(dir) then -- 660
		return Content:isdir(dir) -- 661
	end -- 661
	local parent = Path:getPath(dir) -- 662
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 662
		return false -- 664
	end -- 664
	return Content:mkdir(dir) -- 666
end -- 659
local function encodeDebugJSON(value) -- 669
	local text, err = AgentUtils.safeJsonEncode(value) -- 670
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 671
end -- 669
function ____exports.isAgentPlanPath(path) -- 687
	return AgentRuntimePolicy.isAgentPlanPath(path) -- 688
end -- 687
local function inspectFreshProject(workDir) -- 691
	local result = Tools.listFiles({workDir = workDir, path = "", globs = AgentConfig.AGENT_FILE_PATTERNS.freshProjectCodeGlobs, maxEntries = 2}) -- 692
	if not result.success then -- 692
		return {fresh = false} -- 698
	end -- 698
	local totalEntries = result.totalEntries or #result.files -- 699
	if totalEntries > 1 then -- 699
		return {fresh = false} -- 700
	end -- 700
	if totalEntries == 0 then -- 700
		return {fresh = true} -- 701
	end -- 701
	if #result.files ~= 1 then -- 701
		return {fresh = false} -- 702
	end -- 702
	local path = result.files[1] -- 703
	local loaded = Tools.readFileRaw(workDir, path) -- 704
	if not loaded.success or loaded.content == nil then -- 704
		return {fresh = false} -- 705
	end -- 705
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 706
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 709
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 710
end -- 691
local function getStepLLMDebugDir(shared) -- 713
	return Path( -- 714
		shared.workingDir, -- 715
		".agent", -- 716
		tostring(shared.sessionId), -- 717
		tostring(shared.taskId) -- 718
	) -- 718
end -- 713
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 722
	return Path( -- 723
		getStepLLMDebugDir(shared), -- 723
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 723
	) -- 723
end -- 722
local function getLatestStepLLMDebugSeq(shared, stepId) -- 726
	if not canWriteStepLLMDebug(shared, stepId) then -- 726
		return 0 -- 727
	end -- 727
	local dir = getStepLLMDebugDir(shared) -- 728
	if not Content:exist(dir) or not Content:isdir(dir) then -- 728
		return 0 -- 729
	end -- 729
	local latest = 0 -- 730
	for ____, file in ipairs(Content:getFiles(dir)) do -- 731
		do -- 731
			local name = Path:getFilename(file) -- 732
			local seqText = string.match( -- 733
				name, -- 733
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 733
			) -- 733
			if seqText ~= nil then -- 733
				latest = math.max( -- 735
					latest, -- 735
					tonumber(seqText) -- 735
				) -- 735
				goto __continue57 -- 736
			end -- 736
			local legacyMatch = string.match( -- 738
				name, -- 738
				("^" .. tostring(stepId)) .. "_in%.md$" -- 738
			) -- 738
			if legacyMatch ~= nil then -- 738
				latest = math.max(latest, 1) -- 740
			end -- 740
		end -- 740
		::__continue57:: -- 740
	end -- 740
	return latest -- 743
end -- 726
local function writeStepLLMDebugFile(path, content) -- 746
	if not Content:save(path, content) then -- 746
		AgentUtils.Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 748
		return false -- 749
	end -- 749
	return true -- 751
end -- 746
local function createStepLLMDebugPair(shared, stepId, inContent) -- 754
	if not canWriteStepLLMDebug(shared, stepId) then -- 754
		return 0 -- 755
	end -- 755
	local dir = getStepLLMDebugDir(shared) -- 756
	if not ensureDirRecursive(dir) then -- 756
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 758
		return 0 -- 759
	end -- 759
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 761
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 762
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 763
	if not writeStepLLMDebugFile(inPath, inContent) then -- 763
		return 0 -- 765
	end -- 765
	writeStepLLMDebugFile(outPath, "") -- 767
	return seq -- 768
end -- 754
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 771
	if not canWriteStepLLMDebug(shared, stepId) then -- 771
		return -- 772
	end -- 772
	local dir = getStepLLMDebugDir(shared) -- 773
	if not ensureDirRecursive(dir) then -- 773
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 775
		return -- 776
	end -- 776
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 778
	if latestSeq <= 0 then -- 778
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 780
		writeStepLLMDebugFile(outPath, content) -- 781
		return -- 782
	end -- 782
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 784
	writeStepLLMDebugFile(outPath, content) -- 785
end -- 771
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 788
	if not canWriteStepLLMDebug(shared, stepId) then -- 788
		return -- 789
	end -- 789
	local sections = { -- 790
		"# LLM Input", -- 791
		"session_id: " .. tostring(shared.sessionId), -- 792
		"task_id: " .. tostring(shared.taskId), -- 793
		"step_id: " .. tostring(stepId), -- 794
		"phase: " .. phase, -- 795
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 796
		"## Options", -- 797
		"```json", -- 798
		encodeDebugJSON(options), -- 799
		"```" -- 800
	} -- 800
	local firstMessage = #messages > 0 and messages[1] or nil -- 802
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 802
		sections[#sections + 1] = "# System Prompt" -- 804
		sections[#sections + 1] = firstMessage.content -- 805
	end -- 805
	do -- 805
		local i = 0 -- 807
		while i < #messages do -- 807
			local message = messages[i + 1] -- 808
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 809
			sections[#sections + 1] = encodeDebugJSON(message) -- 810
			i = i + 1 -- 807
		end -- 807
	end -- 807
	createStepLLMDebugPair( -- 812
		shared, -- 812
		stepId, -- 812
		table.concat(sections, "\n") -- 812
	) -- 812
end -- 788
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 815
	if not canWriteStepLLMDebug(shared, stepId) then -- 815
		return -- 816
	end -- 816
	local ____array_24 = __TS__SparseArrayNew( -- 816
		"# LLM Output", -- 818
		"session_id: " .. tostring(shared.sessionId), -- 819
		"task_id: " .. tostring(shared.taskId), -- 820
		"step_id: " .. tostring(stepId), -- 821
		"phase: " .. phase, -- 822
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 823
		table.unpack(meta and ({ -- 824
			"## Meta", -- 824
			"```json", -- 824
			encodeDebugJSON(meta), -- 824
			"```" -- 824
		}) or ({})) -- 824
	) -- 824
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 824
	local sections = {__TS__SparseArraySpread(____array_24)} -- 817
	updateLatestStepLLMDebugOutput( -- 828
		shared, -- 828
		stepId, -- 828
		table.concat(sections, "\n") -- 828
	) -- 828
end -- 815
local function summarizeEditTextParamForHistory(value, key) -- 955
	if type(value) ~= "string" then -- 955
		return nil -- 956
	end -- 956
	local text = value -- 957
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 958
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 959
end -- 955
local function sanitizeActionParamsForHistory(tool, params) -- 1094
	if tool ~= "edit_file" then -- 1094
		return params -- 1095
	end -- 1095
	local clone = {} -- 1096
	for key in pairs(params) do -- 1097
		if key == "old_str" then -- 1097
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1099
		elseif key == "new_str" then -- 1099
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1101
		else -- 1101
			clone[key] = params[key] -- 1103
		end -- 1103
	end -- 1103
	return clone -- 1106
end -- 1094
local function projectMessagesForCompression(messages) -- 1259
	local projected = projectMessagesForLLMContext(messages) -- 1260
	do -- 1260
		local i = 0 -- 1261
		while i < #projected do -- 1261
			do -- 1261
				local message = projected[i + 1] -- 1262
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1262
					goto __continue189 -- 1263
				end -- 1263
				local changed = false -- 1264
				local toolCalls = __TS__ArrayMap( -- 1265
					message.tool_calls, -- 1265
					function(____, toolCall) -- 1265
						local fn = toolCall["function"] -- 1266
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1266
							return toolCall -- 1267
						end -- 1267
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 1268
						if not isRecord(decoded) or isArray(decoded) then -- 1268
							return toolCall -- 1269
						end -- 1269
						changed = true -- 1270
						return __TS__ObjectAssign( -- 1271
							{}, -- 1271
							toolCall, -- 1272
							{["function"] = __TS__ObjectAssign( -- 1271
								{}, -- 1273
								fn, -- 1274
								{arguments = toJson( -- 1273
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1275
									false -- 1275
								)} -- 1275
							)} -- 1275
						) -- 1275
					end -- 1265
				) -- 1265
				if changed then -- 1265
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1279
				end -- 1279
			end -- 1279
			::__continue189:: -- 1279
			i = i + 1 -- 1261
		end -- 1261
	end -- 1261
	return projected -- 1281
end -- 1259
local function getDecisionToolSchemaText(shared) -- 1323
	local toolsText = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1324
		shared.role, -- 1324
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1324
		{ -- 1324
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1325
			workMode = shared.workMode -- 1326
		} -- 1326
	)) -- 1326
	return toolsText or "" -- 1328
end -- 1323
local function clearPreExecutedResults(shared) -- 1338
	shared.preExecutedResults = nil -- 1339
end -- 1338
local function startPreExecutedToolAction(shared, action) -- 1342
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1342
		local ____hasReturned, ____returnValue -- 1342
		local ____try = __TS__AsyncAwaiter(function() -- 1342
			____hasReturned = true -- 1344
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1344
			return -- 1344
		end) -- 1344
		____try = ____try.catch( -- 1344
			____try, -- 1344
			function(____, err) -- 1344
				return __TS__AsyncAwaiter(function() -- 1344
					local message = tostring(err) -- 1346
					AgentUtils.Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1347
					____hasReturned = true -- 1348
					____returnValue = {success = false, message = message} -- 1348
					return -- 1348
				end) -- 1348
			end -- 1348
		) -- 1348
		__TS__Await(____try) -- 1343
		if ____hasReturned then -- 1343
			return ____awaiter_resolve(nil, ____returnValue) -- 1343
		end -- 1343
	end) -- 1343
end -- 1342
local function createPreExecutedToolResult(shared, action) -- 1352
	local cloneParamValue -- 1353
	cloneParamValue = function(value) -- 1353
		if value == nil then -- 1353
			return value -- 1354
		end -- 1354
		if isArray(value) then -- 1354
			return __TS__ArrayMap( -- 1356
				value, -- 1356
				function(____, item) return cloneParamValue(item) end -- 1356
			) -- 1356
		end -- 1356
		if type(value) == "table" then -- 1356
			local clone = {} -- 1359
			for key in pairs(value) do -- 1360
				clone[key] = cloneParamValue(value[key]) -- 1361
			end -- 1361
			return clone -- 1363
		end -- 1363
		return value -- 1365
	end -- 1353
	local params = cloneParamValue(action.params) -- 1367
	local areParamValuesEqual -- 1368
	areParamValuesEqual = function(left, right) -- 1368
		if left == right then -- 1368
			return true -- 1369
		end -- 1369
		if left == nil or right == nil then -- 1369
			return false -- 1370
		end -- 1370
		if isArray(left) or isArray(right) then -- 1370
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1370
				return false -- 1372
			end -- 1372
			do -- 1372
				local i = 0 -- 1373
				while i < #left do -- 1373
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1373
						return false -- 1374
					end -- 1374
					i = i + 1 -- 1373
				end -- 1373
			end -- 1373
			return true -- 1376
		end -- 1376
		if type(left) == "table" and type(right) == "table" then -- 1376
			local leftCount = 0 -- 1379
			for key in pairs(left) do -- 1380
				leftCount = leftCount + 1 -- 1381
				if not areParamValuesEqual(left[key], right[key]) then -- 1381
					return false -- 1386
				end -- 1386
			end -- 1386
			local rightCount = 0 -- 1389
			for key in pairs(right) do -- 1390
				rightCount = rightCount + 1 -- 1391
			end -- 1391
			return leftCount == rightCount -- 1393
		end -- 1393
		return false -- 1395
	end -- 1368
	return { -- 1397
		action = action, -- 1398
		matches = function(self, nextAction) -- 1399
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1400
		end, -- 1399
		promise = startPreExecutedToolAction(shared, action) -- 1402
	} -- 1402
end -- 1352
local function executeToolActionWithPreExecution(shared, action) -- 1406
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1406
		local wasResumeNarrowReadMode = shared.resumeNarrowReadMode == true -- 1407
		local ____opt_29 = shared.preExecutedResults -- 1407
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1408
		local result -- 1409
		if preResult then -- 1409
			local ____opt_31 = shared.preExecutedResults -- 1409
			if ____opt_31 ~= nil then -- 1409
				____opt_31:delete(action.toolCallId) -- 1411
			end -- 1411
			if preResult:matches(action) then -- 1411
				AgentUtils.Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1413
				result = __TS__Await(preResult.promise) -- 1414
			else -- 1414
				AgentUtils.Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1416
				result = __TS__Await(executeToolAction(shared, action)) -- 1417
			end -- 1417
		else -- 1417
			result = __TS__Await(executeToolAction(shared, action)) -- 1420
		end -- 1420
		local guidance = {} -- 1422
		if type(result.guidance) == "string" and __TS__StringTrim(result.guidance) ~= "" then -- 1422
			guidance[#guidance + 1] = result.guidance -- 1424
		end -- 1424
		guidance[#guidance + 1] = AgentToolRegistry.buildCurrentToolAvailabilityGuidance() -- 1426
		if shared.hasSpawnedSubAgentThisTask == true and (shared.delegatedForegroundBatches or 0) + 1 >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1426
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1433
		end -- 1433
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1433
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1436
		end -- 1436
		if shared.failedTestNeedsBuild == true then -- 1436
			if action.tool == "build" and result.success == true and shared.failedTestHasSourceEdit ~= true then -- 1436
				guidance[#guidance + 1] = "The build passed, but no authored source change has addressed the deterministic test failure. Make a narrow source fix before rebuilding or retesting." -- 1440
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1440
				guidance[#guidance + 1] = "Source changed after a deterministic test failure. Build the authored changes before running more tests." -- 1446
			elseif action.tool ~= "build" then -- 1446
				guidance[#guidance + 1] = "A deterministic test failure remains unresolved. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1448
			end -- 1448
		end -- 1448
		if action.tool == "search_dora_api" then -- 1448
			if shared.unbuiltEdits == true then -- 1448
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1453
			end -- 1453
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1453
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1456
			end -- 1456
		end -- 1456
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1456
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1464
		end -- 1464
		if action.tool == "edit_file" and wasResumeNarrowReadMode then -- 1464
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1467
			if oldStr == "" then -- 1467
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1469
			end -- 1469
		end -- 1469
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1469
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1473
		end -- 1473
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1473
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1476
		end -- 1476
		if shared.buildRepairPending == true then -- 1476
			if action.tool == "build" then -- 1476
				guidance[#guidance + 1] = "This build reported authored-file diagnostics. Make a narrow source repair before building again." -- 1482
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1482
				guidance[#guidance + 1] = "A source repair was applied after build diagnostics. Build again before broadening the investigation." -- 1488
			else -- 1488
				guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1490
			end -- 1490
		end -- 1490
		if action.tool == "build" and shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true and shared.failedTestNeedsBuild ~= true then -- 1490
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1499
		end -- 1499
		result.guidance = table.concat(guidance, "\n") -- 1501
		if action.tool ~= "build" and action.tool ~= "read_file" then -- 1501
			shared.resumeNarrowReadMode = false -- 1506
		end -- 1506
		return ____awaiter_resolve(nil, result) -- 1506
	end) -- 1506
end -- 1406
local function maybeCompressHistory(shared, includePendingUserPrompt, pendingUserPrompt) -- 1511
	if includePendingUserPrompt == nil then -- 1511
		includePendingUserPrompt = false -- 1513
	end -- 1513
	if pendingUserPrompt == nil then -- 1513
		pendingUserPrompt = "" -- 1514
	end -- 1514
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1514
		local ____shared_33 = shared -- 1516
		local memory = ____shared_33.memory -- 1516
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1517
		local changed = false -- 1518
		do -- 1518
			local round = 0 -- 1519
			while round < maxRounds do -- 1519
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1520
				local normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1521
				local decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages) -- 1522
				local activeMessages = projectMessagesForCompression(normalizedActiveMessages) -- 1523
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1526
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1534
				local triggerMessages = buildDecisionMessages( -- 1537
					shared, -- 1538
					nil, -- 1539
					1, -- 1540
					nil, -- 1541
					shared.decisionMode, -- 1542
					false, -- 1543
					includePendingUserPrompt and pendingUserPrompt or "" -- 1544
				) -- 1544
				local triggerOptions = shared.decisionMode == "tool_calling" and __TS__ObjectAssign( -- 1546
					{}, -- 1547
					shared.llmOptions, -- 1548
					__TS__StringIncludes( -- 1549
						string.lower(shared.llmConfig.model), -- 1549
						"glm-5.2" -- 1549
					) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") and ({reasoning_effort = "minimal"}) or ({}), -- 1549
					{tools = AgentToolRegistry.buildDecisionToolSchema( -- 1547
						shared.role, -- 1554
						AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1554
						{ -- 1554
							disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1555
							workMode = shared.workMode -- 1556
						} -- 1556
					)} -- 1556
				) or shared.llmOptions -- 1556
				local fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig) -- 1560
				local thresholdReached = getActiveRealMessageCount(shared) > 0 and fitted.originalTokens >= fitted.budgetTokens -- 1563
				if not thresholdReached then -- 1563
					if changed then -- 1563
						persistHistoryState(shared) -- 1567
					end -- 1567
					return ____awaiter_resolve(nil) -- 1567
				end -- 1567
				local compressionRound = round + 1 -- 1571
				AgentUtils.Log( -- 1572
					"Info", -- 1572
					(((("[Memory] Effective input budget reached tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " round=") .. tostring(compressionRound) -- 1572
				) -- 1572
				shared.step = shared.step + 1 -- 1573
				local stepId = shared.step -- 1574
				local pendingMessages = #activeMessages -- 1575
				emitAgentEvent( -- 1576
					shared, -- 1576
					{ -- 1576
						type = "memory_compression_started", -- 1577
						sessionId = shared.sessionId, -- 1578
						taskId = shared.taskId, -- 1579
						step = stepId, -- 1580
						tool = "compress_memory", -- 1581
						reason = getMemoryCompressionStartReason(shared), -- 1582
						params = { -- 1583
							round = compressionRound, -- 1584
							maxRounds = maxRounds, -- 1585
							pendingMessages = pendingMessages, -- 1586
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1587
							uncoveredMessages = #uncoveredMessages, -- 1588
							inputTokens = fitted.originalTokens, -- 1589
							inputBudgetTokens = fitted.budgetTokens -- 1590
						} -- 1590
					} -- 1590
				) -- 1590
				local result = __TS__Await(memory.compressor:compress( -- 1593
					activeMessages, -- 1594
					shared.llmOptions, -- 1595
					shared.llmMaxTry, -- 1596
					shared.decisionMode, -- 1597
					{ -- 1598
						onInput = function(____, phase, messages, options) -- 1599
							saveStepLLMDebugInput( -- 1600
								shared, -- 1600
								stepId, -- 1600
								phase, -- 1600
								messages, -- 1600
								options -- 1600
							) -- 1600
						end, -- 1599
						onOutput = function(____, phase, text, meta) -- 1602
							saveStepLLMDebugOutput( -- 1603
								shared, -- 1603
								stepId, -- 1603
								phase, -- 1603
								text, -- 1603
								meta -- 1603
							) -- 1603
						end, -- 1602
						onUsage = function(____, phase, usage) -- 1605
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1606
						end -- 1605
					}, -- 1605
					"default", -- 1609
					systemPrompt, -- 1610
					toolDefinitions, -- 1611
					decisionActiveMessages -- 1612
				)) -- 1612
				if not (result and result.success and result.compressedCount > 0) then -- 1612
					emitAgentEvent( -- 1615
						shared, -- 1615
						{ -- 1615
							type = "memory_compression_finished", -- 1616
							sessionId = shared.sessionId, -- 1617
							taskId = shared.taskId, -- 1618
							step = stepId, -- 1619
							tool = "compress_memory", -- 1620
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1621
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1625
						} -- 1625
					) -- 1625
					if changed then -- 1625
						persistHistoryState(shared) -- 1633
					end -- 1633
					return ____awaiter_resolve(nil) -- 1633
				end -- 1633
				local effectiveCompressedCount = math.max( -- 1637
					0, -- 1638
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1639
				) -- 1639
				if effectiveCompressedCount <= 0 then -- 1639
					if changed then -- 1639
						persistHistoryState(shared) -- 1643
					end -- 1643
					return ____awaiter_resolve(nil) -- 1643
				end -- 1643
				emitAgentEvent( -- 1647
					shared, -- 1647
					{ -- 1647
						type = "memory_compression_finished", -- 1648
						sessionId = shared.sessionId, -- 1649
						taskId = shared.taskId, -- 1650
						step = stepId, -- 1651
						tool = "compress_memory", -- 1652
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1653
						result = { -- 1654
							success = true, -- 1655
							round = compressionRound, -- 1656
							compressedCount = effectiveCompressedCount, -- 1657
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1658
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1659
						} -- 1659
					} -- 1659
				) -- 1659
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1662
				changed = true -- 1663
				AgentUtils.Log( -- 1664
					"Info", -- 1664
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1664
				) -- 1664
				round = round + 1 -- 1519
			end -- 1519
		end -- 1519
		if changed then -- 1519
			persistHistoryState(shared) -- 1667
		end -- 1667
	end) -- 1667
end -- 1511
local function compactAllHistory(shared) -- 1671
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1671
		local ____shared_40 = shared -- 1672
		local memory = ____shared_40.memory -- 1672
		local rounds = 0 -- 1673
		local totalCompressed = 0 -- 1674
		while getActiveRealMessageCount(shared) > 0 do -- 1674
			if shared.stopToken.stopped then -- 1674
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1677
				return ____awaiter_resolve( -- 1677
					nil, -- 1677
					emitAgentTaskFinishEvent( -- 1678
						shared, -- 1678
						false, -- 1678
						getCancelledReason(shared) -- 1678
					) -- 1678
				) -- 1678
			end -- 1678
			rounds = rounds + 1 -- 1680
			shared.step = shared.step + 1 -- 1681
			local stepId = shared.step -- 1682
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1683
			local pendingMessages = #activeMessages -- 1684
			emitAgentEvent( -- 1685
				shared, -- 1685
				{ -- 1685
					type = "memory_compression_started", -- 1686
					sessionId = shared.sessionId, -- 1687
					taskId = shared.taskId, -- 1688
					step = stepId, -- 1689
					tool = "compress_memory", -- 1690
					reason = getMemoryCompressionStartReason(shared), -- 1691
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1692
				} -- 1692
			) -- 1692
			local result = __TS__Await(memory.compressor:compress( -- 1699
				activeMessages, -- 1700
				shared.llmOptions, -- 1701
				shared.llmMaxTry, -- 1702
				shared.decisionMode, -- 1703
				{ -- 1704
					onInput = function(____, phase, messages, options) -- 1705
						saveStepLLMDebugInput( -- 1706
							shared, -- 1706
							stepId, -- 1706
							phase, -- 1706
							messages, -- 1706
							options -- 1706
						) -- 1706
					end, -- 1705
					onOutput = function(____, phase, text, meta) -- 1708
						saveStepLLMDebugOutput( -- 1709
							shared, -- 1709
							stepId, -- 1709
							phase, -- 1709
							text, -- 1709
							meta -- 1709
						) -- 1709
					end, -- 1708
					onUsage = function(____, phase, usage) -- 1711
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1712
					end -- 1711
				}, -- 1711
				"budget_max" -- 1715
			)) -- 1715
			if not (result and result.success and result.compressedCount > 0) then -- 1715
				emitAgentEvent( -- 1718
					shared, -- 1718
					{ -- 1718
						type = "memory_compression_finished", -- 1719
						sessionId = shared.sessionId, -- 1720
						taskId = shared.taskId, -- 1721
						step = stepId, -- 1722
						tool = "compress_memory", -- 1723
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1724
						result = { -- 1728
							success = false, -- 1729
							rounds = rounds, -- 1730
							error = result and result.error or "compression returned no changes", -- 1731
							compressedCount = result and result.compressedCount or 0, -- 1732
							fullCompaction = true -- 1733
						} -- 1733
					} -- 1733
				) -- 1733
				return ____awaiter_resolve( -- 1733
					nil, -- 1733
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1736
				) -- 1736
			end -- 1736
			local effectiveCompressedCount = math.max( -- 1741
				0, -- 1742
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1743
			) -- 1743
			if effectiveCompressedCount <= 0 then -- 1743
				return ____awaiter_resolve( -- 1743
					nil, -- 1743
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1746
				) -- 1746
			end -- 1746
			emitAgentEvent( -- 1753
				shared, -- 1753
				{ -- 1753
					type = "memory_compression_finished", -- 1754
					sessionId = shared.sessionId, -- 1755
					taskId = shared.taskId, -- 1756
					step = stepId, -- 1757
					tool = "compress_memory", -- 1758
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1759
					result = { -- 1760
						success = true, -- 1761
						round = rounds, -- 1762
						compressedCount = effectiveCompressedCount, -- 1763
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1764
						fullCompaction = true -- 1765
					} -- 1765
				} -- 1765
			) -- 1765
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1768
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1769
			persistHistoryState(shared) -- 1770
			AgentUtils.Log( -- 1771
				"Info", -- 1771
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1771
			) -- 1771
		end -- 1771
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1773
		return ____awaiter_resolve( -- 1773
			nil, -- 1773
			emitAgentTaskFinishEvent( -- 1774
				shared, -- 1775
				true, -- 1776
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1777
			) -- 1777
		) -- 1777
	end) -- 1777
end -- 1671
local function clearSessionHistory(shared) -- 1783
	shared.messages = {} -- 1784
	shared.lastConsolidatedIndex = 0 -- 1785
	shared.carryMessageIndex = nil -- 1786
	persistHistoryState(shared) -- 1787
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1788
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1789
end -- 1783
local function appendConversationMessage(shared, message) -- 1941
	local ____shared_messages_49 = shared.messages -- 1941
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1942
		{}, -- 1942
		message, -- 1943
		{ -- 1942
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1944
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1945
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1946
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1947
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1948
		} -- 1948
	) -- 1948
end -- 1941
local function appendToolResultMessage(shared, action) -- 1957
	appendConversationMessage( -- 1958
		shared, -- 1958
		{ -- 1958
			role = "tool", -- 1959
			tool_call_id = action.toolCallId, -- 1960
			name = action.tool, -- 1961
			content = action.result and toJson(action.result, false) or "" -- 1962
		} -- 1962
	) -- 1962
end -- 1957
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1966
	appendConversationMessage( -- 1972
		shared, -- 1972
		{ -- 1972
			role = "assistant", -- 1973
			content = content or "", -- 1974
			reasoning_content = reasoningContent, -- 1975
			tool_calls = __TS__ArrayMap( -- 1976
				actions, -- 1976
				function(____, action) return { -- 1976
					id = action.toolCallId, -- 1977
					type = "function", -- 1978
					["function"] = { -- 1979
						name = action.tool, -- 1980
						arguments = toJson(action.params, false) -- 1981
					} -- 1981
				} end -- 1981
			) -- 1981
		} -- 1981
	) -- 1981
end -- 1966
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
						goto __continue531 -- 3152
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
				::__continue531:: -- 3163
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
		local result = Tools.deleteFile(input.taskId, input.workDir, input.targetFile, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3585
		if not result.success then -- 3585
			return ____awaiter_resolve(nil, result) -- 3585
		end -- 3585
		local ____result_checkpointed_138 = result.checkpointed -- 3596
		local ____result_reversible_139 = result.reversible -- 3597
		local ____result_binary_140 = result.binary -- 3598
		local ____temp_141 = result.checkpointed and result.checkpointId or nil -- 3599
		local ____temp_142 = result.checkpointed and result.checkpointSeq or nil -- 3600
		local ____result_checkpointed_137 -- 3601
		if result.checkpointed then -- 3601
			____result_checkpointed_137 = nil -- 3601
		else -- 3601
			____result_checkpointed_137 = result.message -- 3601
		end -- 3601
		return ____awaiter_resolve(nil, { -- 3601
			success = true, -- 3593
			changed = true, -- 3594
			mode = "delete", -- 3595
			checkpointed = ____result_checkpointed_138, -- 3596
			reversible = ____result_reversible_139, -- 3597
			binary = ____result_binary_140, -- 3598
			checkpointId = ____temp_141, -- 3599
			checkpointSeq = ____temp_142, -- 3600
			message = ____result_checkpointed_137, -- 3601
			files = {{path = input.targetFile, op = "delete"}} -- 3602
		}) -- 3602
	end) -- 3602
end -- 3584
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3606
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3606
		local last = shared.history[#shared.history] -- 3607
		if last ~= nil then -- 3607
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3609
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3610
			appendToolResultMessage(shared, last) -- 3611
			emitAgentFinishEvent(shared, last) -- 3612
			local result = last.result -- 3613
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3613
				emitAgentEvent(shared, { -- 3618
					type = "checkpoint_created", -- 3619
					sessionId = shared.sessionId, -- 3620
					taskId = shared.taskId, -- 3621
					step = last.step, -- 3622
					tool = "delete_file", -- 3623
					checkpointId = result.checkpointId, -- 3624
					checkpointSeq = result.checkpointSeq, -- 3625
					files = result.files -- 3626
				}) -- 3626
			end -- 3626
		end -- 3626
		persistHistoryState(shared) -- 3633
		__TS__Await(maybeCompressHistory(shared)) -- 3634
		persistHistoryState(shared) -- 3635
		return ____awaiter_resolve(nil, "main") -- 3635
	end) -- 3635
end -- 3606
local BuildAction = __TS__Class() -- 3640
BuildAction.name = "BuildAction" -- 3640
__TS__ClassExtends(BuildAction, Node) -- 3640
function BuildAction.prototype.prep(self, shared) -- 3641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3641
		local last = shared.history[#shared.history] -- 3642
		if not last then -- 3642
			error( -- 3643
				__TS__New(Error, "no history"), -- 3643
				0 -- 3643
			) -- 3643
		end -- 3643
		emitAgentStartEvent(shared, last) -- 3644
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3644
	end) -- 3644
end -- 3641
function BuildAction.prototype.exec(self, input) -- 3648
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3648
		local params = input.params -- 3649
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3650
		return ____awaiter_resolve(nil, result) -- 3650
	end) -- 3650
end -- 3648
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3657
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3657
		local last = shared.history[#shared.history] -- 3658
		if last ~= nil then -- 3658
			last.result = sanitizeBuildResultForHistory(execRes) -- 3660
			appendToolResultMessage(shared, last) -- 3661
			emitAgentFinishEvent(shared, last) -- 3662
		end -- 3662
		persistHistoryState(shared) -- 3664
		__TS__Await(maybeCompressHistory(shared)) -- 3665
		persistHistoryState(shared) -- 3666
		return ____awaiter_resolve(nil, "main") -- 3666
	end) -- 3666
end -- 3657
local SpawnSubAgentAction = __TS__Class() -- 3671
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3671
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3671
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3672
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3672
		local last = shared.history[#shared.history] -- 3682
		if not last then -- 3682
			error( -- 3683
				__TS__New(Error, "no history"), -- 3683
				0 -- 3683
			) -- 3683
		end -- 3683
		emitAgentStartEvent(shared, last) -- 3684
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3685
			last.params.filesHint, -- 3686
			function(____, item) return type(item) == "string" end -- 3686
		) or nil -- 3686
		return ____awaiter_resolve( -- 3686
			nil, -- 3686
			{ -- 3688
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3689
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3690
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3691
				filesHint = filesHint, -- 3692
				sessionId = shared.sessionId, -- 3693
				projectRoot = shared.workingDir, -- 3694
				spawnSubAgent = shared.spawnSubAgent, -- 3695
				disabledAgentTools = shared.disabledAgentTools -- 3696
			} -- 3696
		) -- 3696
	end) -- 3696
end -- 3672
function SpawnSubAgentAction.prototype.exec(self, input) -- 3700
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3700
		if not input.spawnSubAgent then -- 3700
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3700
		end -- 3700
		if input.sessionId == nil or input.sessionId <= 0 then -- 3700
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3700
		end -- 3700
		local ____AgentUtils_Log_148 = AgentUtils.Log -- 3716
		local ____temp_145 = #input.title -- 3716
		local ____temp_146 = #input.prompt -- 3716
		local ____temp_147 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3716
		local ____opt_143 = input.filesHint -- 3716
		____AgentUtils_Log_148( -- 3716
			"Info", -- 3716
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_145)) .. " prompt_len=") .. tostring(____temp_146)) .. " expected_len=") .. tostring(____temp_147)) .. " files_hint_count=") .. tostring(____opt_143 and #____opt_143 or 0) -- 3716
		) -- 3716
		local result = __TS__Await(input.spawnSubAgent({ -- 3717
			parentSessionId = input.sessionId, -- 3718
			projectRoot = input.projectRoot, -- 3719
			title = input.title, -- 3720
			prompt = input.prompt, -- 3721
			expectedOutput = input.expectedOutput, -- 3722
			filesHint = input.filesHint, -- 3723
			disabledAgentTools = input.disabledAgentTools -- 3724
		})) -- 3724
		if not result.success then -- 3724
			return ____awaiter_resolve(nil, result) -- 3724
		end -- 3724
		return ____awaiter_resolve(nil, { -- 3724
			success = true, -- 3730
			sessionId = result.sessionId, -- 3731
			taskId = result.taskId, -- 3732
			title = result.title, -- 3733
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3734
		}) -- 3734
	end) -- 3734
end -- 3700
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3738
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3738
		local last = shared.history[#shared.history] -- 3739
		if last ~= nil then -- 3739
			last.result = execRes -- 3741
			if execRes.success == true then -- 3741
				shared.hasSpawnedSubAgentThisTask = true -- 3743
			end -- 3743
			appendToolResultMessage(shared, last) -- 3745
			emitAgentFinishEvent(shared, last) -- 3746
		end -- 3746
		persistHistoryState(shared) -- 3748
		__TS__Await(maybeCompressHistory(shared)) -- 3749
		persistHistoryState(shared) -- 3750
		return ____awaiter_resolve(nil, "main") -- 3750
	end) -- 3750
end -- 3738
local ListSubAgentsAction = __TS__Class() -- 3755
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3755
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3755
function ListSubAgentsAction.prototype.prep(self, shared) -- 3756
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3756
		local last = shared.history[#shared.history] -- 3766
		if not last then -- 3766
			error( -- 3767
				__TS__New(Error, "no history"), -- 3767
				0 -- 3767
			) -- 3767
		end -- 3767
		emitAgentStartEvent(shared, last) -- 3768
		return ____awaiter_resolve( -- 3768
			nil, -- 3768
			{ -- 3769
				sessionId = shared.sessionId, -- 3770
				projectRoot = shared.workingDir, -- 3771
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3772
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3773
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3774
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3775
				listSubAgents = shared.listSubAgents, -- 3776
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3777
			} -- 3777
		) -- 3777
	end) -- 3777
end -- 3756
function ListSubAgentsAction.prototype.exec(self, input) -- 3781
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3781
		if not input.listSubAgents then -- 3781
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3781
		end -- 3781
		if input.sessionId == nil or input.sessionId <= 0 then -- 3781
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3781
		end -- 3781
		local result = __TS__Await(input.listSubAgents({ -- 3797
			sessionId = input.sessionId, -- 3798
			projectRoot = input.projectRoot, -- 3799
			status = input.status, -- 3800
			limit = input.limit, -- 3801
			offset = input.offset, -- 3802
			query = input.query -- 3803
		})) -- 3803
		return ____awaiter_resolve( -- 3803
			nil, -- 3803
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3805
		) -- 3805
	end) -- 3805
end -- 3781
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3813
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3813
		local last = shared.history[#shared.history] -- 3814
		if last ~= nil then -- 3814
			last.result = execRes -- 3816
			appendToolResultMessage(shared, last) -- 3817
			emitAgentFinishEvent(shared, last) -- 3818
		end -- 3818
		persistHistoryState(shared) -- 3820
		__TS__Await(maybeCompressHistory(shared)) -- 3821
		persistHistoryState(shared) -- 3822
		return ____awaiter_resolve(nil, "main") -- 3822
	end) -- 3822
end -- 3813
EditFileAction = __TS__Class() -- 3827
EditFileAction.name = "EditFileAction" -- 3827
__TS__ClassExtends(EditFileAction, Node) -- 3827
function EditFileAction.prototype.prep(self, shared) -- 3828
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3828
		local last = shared.history[#shared.history] -- 3829
		if not last then -- 3829
			error( -- 3830
				__TS__New(Error, "no history"), -- 3830
				0 -- 3830
			) -- 3830
		end -- 3830
		emitAgentStartEvent(shared, last) -- 3831
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3832
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3835
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3836
		if __TS__StringTrim(path) == "" then -- 3836
			error( -- 3837
				__TS__New(Error, "missing path"), -- 3837
				0 -- 3837
			) -- 3837
		end -- 3837
		return ____awaiter_resolve(nil, { -- 3837
			path = path, -- 3838
			oldStr = oldStr, -- 3838
			newStr = newStr, -- 3838
			taskId = shared.taskId, -- 3838
			workDir = shared.workingDir -- 3838
		}) -- 3838
	end) -- 3838
end -- 3828
function EditFileAction.prototype.exec(self, input) -- 3841
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3841
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3842
		if not readRes.success then -- 3842
			if input.oldStr ~= "" then -- 3842
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3842
			end -- 3842
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3847
			if not createRes.success then -- 3847
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3847
			end -- 3847
			return ____awaiter_resolve( -- 3847
				nil, -- 3847
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3854
					success = true, -- 3855
					changed = true, -- 3856
					mode = "create", -- 3857
					checkpointId = createRes.checkpointId, -- 3858
					checkpointSeq = createRes.checkpointSeq, -- 3859
					files = {{path = input.path, op = "create"}} -- 3860
				}) -- 3860
			) -- 3860
		end -- 3860
		if input.oldStr == "" then -- 3860
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3860
				return ____awaiter_resolve( -- 3860
					nil, -- 3860
					{ -- 3865
						success = false, -- 3866
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3867
						actualSaved = false, -- 3868
						actualSavedCharacters = 0, -- 3869
						currentFileExists = true, -- 3870
						currentCharacters = #readRes.content, -- 3871
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3872
					} -- 3872
				) -- 3872
			end -- 3872
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3875
			if not overwriteRes.success then -- 3875
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3875
			end -- 3875
			return ____awaiter_resolve( -- 3875
				nil, -- 3875
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3882
					success = true, -- 3883
					changed = true, -- 3884
					mode = "overwrite", -- 3885
					checkpointId = overwriteRes.checkpointId, -- 3886
					checkpointSeq = overwriteRes.checkpointSeq, -- 3887
					files = {{path = input.path, op = "write"}} -- 3888
				}) -- 3888
			) -- 3888
		end -- 3888
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3893
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3894
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3895
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3898
		if occurrences == 0 then -- 3898
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3900
			if not indentTolerant.success then -- 3900
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3900
			end -- 3900
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3904
			if not applyRes.success then -- 3904
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3904
			end -- 3904
			return ____awaiter_resolve( -- 3904
				nil, -- 3904
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3911
					success = true, -- 3912
					changed = true, -- 3913
					mode = "replace_indent_tolerant", -- 3914
					checkpointId = applyRes.checkpointId, -- 3915
					checkpointSeq = applyRes.checkpointSeq, -- 3916
					files = {{path = input.path, op = "write"}} -- 3917
				}) -- 3917
			) -- 3917
		end -- 3917
		if occurrences > 1 then -- 3917
			return ____awaiter_resolve( -- 3917
				nil, -- 3917
				{ -- 3921
					success = false, -- 3921
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3921
				} -- 3921
			) -- 3921
		end -- 3921
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3925
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3926
		if not applyRes.success then -- 3926
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3926
		end -- 3926
		return ____awaiter_resolve( -- 3926
			nil, -- 3926
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3933
				success = true, -- 3934
				changed = true, -- 3935
				mode = "replace", -- 3936
				checkpointId = applyRes.checkpointId, -- 3937
				checkpointSeq = applyRes.checkpointSeq, -- 3938
				files = {{path = input.path, op = "write"}} -- 3939
			}) -- 3939
		) -- 3939
	end) -- 3939
end -- 3841
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3943
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3943
		local last = shared.history[#shared.history] -- 3944
		if last ~= nil then -- 3944
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3946
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3947
			appendToolResultMessage(shared, last) -- 3948
			emitAgentFinishEvent(shared, last) -- 3949
			local result = last.result -- 3950
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3950
				emitAgentEvent(shared, { -- 3955
					type = "checkpoint_created", -- 3956
					sessionId = shared.sessionId, -- 3957
					taskId = shared.taskId, -- 3958
					step = last.step, -- 3959
					tool = last.tool, -- 3960
					checkpointId = result.checkpointId, -- 3961
					checkpointSeq = result.checkpointSeq, -- 3962
					files = result.files -- 3963
				}) -- 3963
			end -- 3963
		end -- 3963
		persistHistoryState(shared) -- 3970
		__TS__Await(maybeCompressHistory(shared)) -- 3971
		persistHistoryState(shared) -- 3972
		return ____awaiter_resolve(nil, "main") -- 3972
	end) -- 3972
end -- 3943
local FetchUrlAction = __TS__Class() -- 3977
FetchUrlAction.name = "FetchUrlAction" -- 3977
__TS__ClassExtends(FetchUrlAction, Node) -- 3977
function FetchUrlAction.prototype.prep(self, shared) -- 3978
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3978
		local last = shared.history[#shared.history] -- 3979
		if not last then -- 3979
			error( -- 3980
				__TS__New(Error, "no history"), -- 3980
				0 -- 3980
			) -- 3980
		end -- 3980
		emitAgentStartEvent(shared, last) -- 3981
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3981
	end) -- 3981
end -- 3978
function FetchUrlAction.prototype.exec(self, input) -- 3985
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3985
		return ____awaiter_resolve( -- 3985
			nil, -- 3985
			executeToolAction(input.shared, input.action) -- 3986
		) -- 3986
	end) -- 3986
end -- 3985
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3989
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3989
		local last = shared.history[#shared.history] -- 3990
		if last ~= nil then -- 3990
			last.result = execRes -- 3992
			appendToolResultMessage(shared, last) -- 3993
			emitAgentFinishEvent(shared, last) -- 3994
		end -- 3994
		persistHistoryState(shared) -- 3996
		__TS__Await(maybeCompressHistory(shared)) -- 3997
		persistHistoryState(shared) -- 3998
		return ____awaiter_resolve(nil, "main") -- 3998
	end) -- 3998
end -- 3989
local function emitCheckpointEventForAction(shared, action) -- 4003
	local result = action.result -- 4004
	if not result then -- 4004
		return -- 4005
	end -- 4005
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4005
		emitAgentEvent(shared, { -- 4010
			type = "checkpoint_created", -- 4011
			sessionId = shared.sessionId, -- 4012
			taskId = shared.taskId, -- 4013
			step = action.step, -- 4014
			tool = action.tool, -- 4015
			checkpointId = result.checkpointId, -- 4016
			checkpointSeq = result.checkpointSeq, -- 4017
			files = result.files -- 4018
		}) -- 4018
	end -- 4018
end -- 4003
local function canRunBatchActionInParallel(self, action) -- 4571
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4572
end -- 4571
local function partitionToolCalls(actions) -- 4580
	local batches = {} -- 4581
	do -- 4581
		local i = 0 -- 4582
		while i < #actions do -- 4582
			local action = actions[i + 1] -- 4583
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4584
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4585
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4585
				local ____lastBatch_actions_187 = lastBatch.actions -- 4585
				____lastBatch_actions_187[#____lastBatch_actions_187 + 1] = action -- 4587
			else -- 4587
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4589
			end -- 4589
			i = i + 1 -- 4582
		end -- 4582
	end -- 4582
	return batches -- 4592
end -- 4580
local function completeStoppedToolAction(shared, action) -- 4595
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4596
	if not action.result then -- 4596
		action.result = { -- 4598
			success = false, -- 4598
			message = getCancelledReason(shared) -- 4598
		} -- 4598
	end -- 4598
	appendToolResultMessage(shared, action) -- 4600
	emitAgentFinishEvent(shared, action) -- 4601
	emitCheckpointEventForAction(shared, action) -- 4602
end -- 4595
local BatchToolAction = __TS__Class() -- 4605
BatchToolAction.name = "BatchToolAction" -- 4605
__TS__ClassExtends(BatchToolAction, Node) -- 4605
function BatchToolAction.prototype.prep(self, shared) -- 4606
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4606
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4606
	end) -- 4606
end -- 4606
function BatchToolAction.prototype.exec(self, input) -- 4610
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4610
		local shared = input.shared -- 4611
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4612
		local preExecuted = shared.preExecutedResults -- 4613
		local batches = partitionToolCalls(input.actions) -- 4614
		local parallelBatchCount = #__TS__ArrayFilter( -- 4615
			batches, -- 4615
			function(____, b) return b.isConcurrencySafe end -- 4615
		) -- 4615
		local serialBatchCount = #__TS__ArrayFilter( -- 4616
			batches, -- 4616
			function(____, b) return not b.isConcurrencySafe end -- 4616
		) -- 4616
		AgentUtils.Log( -- 4617
			"Info", -- 4617
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4617
		) -- 4617
		do -- 4617
			local batchIdx = 0 -- 4619
			while batchIdx < #batches do -- 4619
				do -- 4619
					local batch = batches[batchIdx + 1] -- 4620
					if shared.stopToken.stopped then -- 4620
						for ____, action in ipairs(batch.actions) do -- 4622
							completeStoppedToolAction(shared, action) -- 4623
						end -- 4623
						goto __continue765 -- 4625
					end -- 4625
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4625
						local preExecCount = #__TS__ArrayFilter( -- 4629
							batch.actions, -- 4629
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4629
						) -- 4629
						AgentUtils.Log( -- 4630
							"Info", -- 4630
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4630
						) -- 4630
						do -- 4630
							local i = 0 -- 4631
							while i < #batch.actions do -- 4631
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4632
								i = i + 1 -- 4631
							end -- 4631
						end -- 4631
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4634
							batch.actions, -- 4634
							function(____, action) -- 4634
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4634
									if shared.stopToken.stopped then -- 4634
										action.result = { -- 4636
											success = false, -- 4636
											message = getCancelledReason(shared) -- 4636
										} -- 4636
										return ____awaiter_resolve(nil, action) -- 4636
									end -- 4636
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4639
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4640
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4641
									return ____awaiter_resolve(nil, action) -- 4641
								end) -- 4641
							end -- 4634
						))) -- 4634
						do -- 4634
							local i = 0 -- 4644
							while i < #batch.actions do -- 4644
								local action = batch.actions[i + 1] -- 4645
								if not action.result then -- 4645
									action.result = {success = false, message = "tool did not produce a result"} -- 4647
								end -- 4647
								appendToolResultMessage(shared, action) -- 4649
								emitAgentFinishEvent(shared, action) -- 4650
								emitCheckpointEventForAction(shared, action) -- 4651
								i = i + 1 -- 4644
							end -- 4644
						end -- 4644
					else -- 4644
						AgentUtils.Log( -- 4654
							"Info", -- 4654
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4654
						) -- 4654
						do -- 4654
							local i = 0 -- 4655
							while i < #batch.actions do -- 4655
								local action = batch.actions[i + 1] -- 4656
								emitAgentStartEvent(shared, action) -- 4657
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4658
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4659
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4660
								appendToolResultMessage(shared, action) -- 4661
								emitAgentFinishEvent(shared, action) -- 4662
								emitCheckpointEventForAction(shared, action) -- 4663
								persistHistoryState(shared) -- 4664
								if shared.stopToken.stopped then -- 4664
									do -- 4664
										local j = i + 1 -- 4666
										while j < #batch.actions do -- 4666
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4667
											j = j + 1 -- 4666
										end -- 4666
									end -- 4666
									break -- 4669
								end -- 4669
								i = i + 1 -- 4655
							end -- 4655
						end -- 4655
					end -- 4655
				end -- 4655
				::__continue765:: -- 4655
				batchIdx = batchIdx + 1 -- 4619
			end -- 4619
		end -- 4619
		local spawnSeen = spawnedBeforeBatch -- 4674
		local didDelegatedForegroundWork = false -- 4675
		do -- 4675
			local i = 0 -- 4676
			while i < #input.actions do -- 4676
				do -- 4676
					local action = input.actions[i + 1] -- 4677
					if action.tool == "spawn_sub_agent" then -- 4677
						local ____opt_190 = action.result -- 4677
						if (____opt_190 and ____opt_190.success) == true then -- 4677
							spawnSeen = true -- 4679
						end -- 4679
						goto __continue785 -- 4680
					end -- 4680
					if spawnSeen and action.tool ~= "finish" then -- 4680
						didDelegatedForegroundWork = true -- 4683
					end -- 4683
				end -- 4683
				::__continue785:: -- 4683
				i = i + 1 -- 4676
			end -- 4676
		end -- 4676
		if didDelegatedForegroundWork then -- 4676
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4687
		end -- 4687
		persistHistoryState(shared) -- 4689
		return ____awaiter_resolve(nil, input.actions) -- 4689
	end) -- 4689
end -- 4610
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4693
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4693
		shared.pendingToolActions = nil -- 4694
		shared.preExecutedResults = nil -- 4695
		persistHistoryState(shared) -- 4696
		if shared.waitingQuestionnaireId == nil then -- 4696
			__TS__Await(maybeCompressHistory(shared)) -- 4700
			persistHistoryState(shared) -- 4701
		end -- 4701
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4701
	end) -- 4701
end -- 4693
local EndNode = __TS__Class() -- 4707
EndNode.name = "EndNode" -- 4707
__TS__ClassExtends(EndNode, Node) -- 4707
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4708
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4708
		return ____awaiter_resolve(nil, nil) -- 4708
	end) -- 4708
end -- 4708
local CodingAgentFlow = __TS__Class() -- 4713
CodingAgentFlow.name = "CodingAgentFlow" -- 4713
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4713
function CodingAgentFlow.prototype.____constructor(self, role) -- 4714
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4715
	local read = __TS__New(ReadFileAction, 1, 0) -- 4716
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4717
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4718
	local list = __TS__New(ListFilesAction, 1, 0) -- 4719
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4720
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4721
	local build = __TS__New(BuildAction, 1, 0) -- 4722
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4723
	local edit = __TS__New(EditFileAction, 1, 0) -- 4724
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4725
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4726
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4727
	local done = __TS__New(EndNode, 1, 0) -- 4728
	main:on("batch_tools", batch) -- 4730
	main:on("grep_files", search) -- 4731
	main:on("search_dora_api", searchDora) -- 4732
	main:on("glob_files", list) -- 4733
	main:on("fetch_url", fetch) -- 4734
	main:on("execute_command", exec) -- 4735
	if role == "main" then -- 4735
		main:on("read_file", read) -- 4737
		main:on("delete_file", del) -- 4738
		main:on("build", build) -- 4739
		main:on("edit_file", edit) -- 4740
		main:on("list_sub_agents", listSub) -- 4741
		main:on("spawn_sub_agent", spawn) -- 4742
	else -- 4742
		main:on("read_file", read) -- 4744
		main:on("delete_file", del) -- 4745
		main:on("build", build) -- 4746
		main:on("edit_file", edit) -- 4747
	end -- 4747
	main:on("done", done) -- 4749
	search:on("main", main) -- 4751
	searchDora:on("main", main) -- 4752
	list:on("main", main) -- 4753
	listSub:on("main", main) -- 4754
	spawn:on("main", main) -- 4755
	batch:on("main", main) -- 4756
	batch:on("done", done) -- 4757
	read:on("main", main) -- 4758
	del:on("main", main) -- 4759
	build:on("main", main) -- 4760
	edit:on("main", main) -- 4761
	fetch:on("main", main) -- 4762
	exec:on("main", main) -- 4763
	Flow.prototype.____constructor(self, main) -- 4765
end -- 4714
local function runCodingAgentAsync(options) -- 4801
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4801
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4801
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4801
		end -- 4801
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4805
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4806
		if not llmConfigRes.success then -- 4806
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4806
		end -- 4806
		local llmConfig = llmConfigRes.config -- 4812
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4813
		if not taskRes.success then -- 4813
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4813
		end -- 4813
		local compressor = __TS__New(MemoryCompressor, { -- 4820
			compressionTargetThreshold = 0.5, -- 4821
			maxCompressionRounds = 3, -- 4822
			projectDir = options.workDir, -- 4823
			llmConfig = llmConfig, -- 4824
			promptPack = options.promptPack, -- 4825
			scope = options.memoryScope -- 4826
		}) -- 4826
		local persistedSession = compressor:getStorage():readSessionState() -- 4828
		local effectiveUserQuery = normalizedPrompt -- 4829
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4829
			do -- 4829
				local i = #persistedSession.messages - 1 -- 4831
				while i >= 0 do -- 4831
					local message = persistedSession.messages[i + 1] -- 4832
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4832
						effectiveUserQuery = message.content -- 4834
						break -- 4835
					end -- 4835
					i = i - 1 -- 4831
				end -- 4831
			end -- 4831
		end -- 4831
		local promptPack = compressor:getPromptPack() -- 4839
		local freshProject = inspectFreshProject(options.workDir) -- 4840
		local freshProjectBuildPending = freshProject.fresh -- 4841
		local freshProjectCodeFile = freshProject.codeFile -- 4842
		local shared = { -- 4844
			sessionId = options.sessionId, -- 4845
			taskId = taskRes.taskId, -- 4846
			role = options.role or "main", -- 4847
			maxSteps = math.max( -- 4848
				1, -- 4848
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4848
			), -- 4848
			llmMaxTry = math.max( -- 4849
				1, -- 4849
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4849
			), -- 4849
			step = math.max( -- 4850
				0, -- 4850
				math.floor(options.initialStep or 0) -- 4850
			), -- 4850
			agentStepCount = math.max( -- 4851
				0, -- 4851
				math.floor(options.initialAgentStepCount or 0) -- 4851
			), -- 4851
			done = false, -- 4852
			stopToken = options.stopToken or ({stopped = false}), -- 4853
			response = "", -- 4854
			userQuery = effectiveUserQuery, -- 4855
			workingDir = options.workDir, -- 4856
			useChineseResponse = options.useChineseResponse == true, -- 4857
			workMode = options.workMode or "code", -- 4858
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4859
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4862
			llmConfig = llmConfig, -- 4863
			onEvent = options.onEvent, -- 4864
			promptPack = promptPack, -- 4865
			history = {}, -- 4866
			messages = persistedSession.messages, -- 4867
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4868
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4869
			memory = {compressor = compressor}, -- 4871
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4875
				projectDir = options.workDir, -- 4877
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4878
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4879
			})}, -- 4879
			spawnSubAgent = options.spawnSubAgent, -- 4885
			listSubAgents = options.listSubAgents, -- 4886
			publishQuestionnaire = options.publishQuestionnaire, -- 4887
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4888
			freshProjectBuildPending = freshProjectBuildPending, -- 4889
			freshProjectCodeFile = freshProjectCodeFile, -- 4890
			hasSpawnedSubAgentThisTask = false, -- 4891
			delegatedForegroundBatches = 0, -- 4892
			tokenUsage = options.initialTokenUsage -- 4893
		} -- 4893
		local ____hasReturned, ____returnValue -- 4893
		local ____try = __TS__AsyncAwaiter(function() -- 4893
			if shared.workMode == "plan" then -- 4893
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4898
				if not planDocuments.success then -- 4898
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4900
					____hasReturned = true -- 4901
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4901
					return -- 4901
				end -- 4901
			end -- 4901
			emitAgentEvent(shared, { -- 4904
				type = "task_started", -- 4905
				sessionId = shared.sessionId, -- 4906
				taskId = shared.taskId, -- 4907
				prompt = shared.userQuery, -- 4908
				workDir = shared.workingDir, -- 4909
				maxSteps = shared.maxSteps, -- 4910
				resumed = options.resumeTask == true -- 4911
			}) -- 4911
			if shared.stopToken.stopped then -- 4911
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4914
				____hasReturned = true -- 4915
				____returnValue = emitAgentTaskFinishEvent( -- 4915
					shared, -- 4915
					false, -- 4915
					getCancelledReason(shared) -- 4915
				) -- 4915
				return -- 4915
			end -- 4915
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4917
			local ____temp_192 -- 4918
			if options.resumeConversation == true then -- 4918
				____temp_192 = nil -- 4918
			else -- 4918
				____temp_192 = getPromptCommand(shared.userQuery) -- 4918
			end -- 4918
			local promptCommand = ____temp_192 -- 4918
			if promptCommand == "clear" then -- 4918
				____hasReturned = true -- 4920
				____returnValue = clearSessionHistory(shared) -- 4920
				return -- 4920
			end -- 4920
			if promptCommand == "compact" then -- 4920
				if shared.role == "sub" then -- 4920
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4924
					____hasReturned = true -- 4925
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4925
					return -- 4925
				end -- 4925
				____hasReturned = true -- 4933
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4933
				return -- 4933
			end -- 4933
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4935
			if shared.stopToken.stopped then -- 4935
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4937
				____hasReturned = true -- 4938
				____returnValue = emitAgentTaskFinishEvent( -- 4938
					shared, -- 4938
					false, -- 4938
					getCancelledReason(shared) -- 4938
				) -- 4938
				return -- 4938
			end -- 4938
			if options.resumeConversation ~= true then -- 4938
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4941
				persistHistoryState(shared) -- 4945
			end -- 4945
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4947
			__TS__Await(flow:run(shared)) -- 4948
			if shared.stopToken.stopped then -- 4948
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4950
				____hasReturned = true -- 4951
				____returnValue = emitAgentTaskFinishEvent( -- 4951
					shared, -- 4951
					false, -- 4951
					getCancelledReason(shared) -- 4951
				) -- 4951
				return -- 4951
			end -- 4951
			if shared.error then -- 4951
				____hasReturned = true -- 4954
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4954
				return -- 4954
			end -- 4954
			if shared.waitingQuestionnaireId ~= nil then -- 4954
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4958
				emitAgentEvent(shared, { -- 4959
					type = "task_waiting_for_user", -- 4960
					sessionId = shared.sessionId, -- 4961
					taskId = shared.taskId, -- 4962
					step = shared.step, -- 4963
					questionnaireId = shared.waitingQuestionnaireId -- 4964
				}) -- 4964
				____hasReturned = true -- 4966
				____returnValue = { -- 4966
					success = true, -- 4967
					taskId = shared.taskId, -- 4968
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4969
					steps = shared.step, -- 4970
					waitingForUser = true, -- 4971
					questionnaireId = shared.waitingQuestionnaireId -- 4972
				} -- 4972
				return -- 4966
			end -- 4966
			local ____isFinalDecisionTurn_result_195 = isFinalDecisionTurn(shared) -- 4975
			if ____isFinalDecisionTurn_result_195 then -- 4975
				local ____opt_193 = shared.completion -- 4975
				____isFinalDecisionTurn_result_195 = (____opt_193 and ____opt_193.outcome) == "partial" -- 4975
			end -- 4975
			if ____isFinalDecisionTurn_result_195 then -- 4975
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4976
				____hasReturned = true -- 4977
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4977
				return -- 4977
			end -- 4977
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4980
			____hasReturned = true -- 4981
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4981
			return -- 4981
		end) -- 4981
		____try = ____try.catch( -- 4981
			____try, -- 4981
			function(____, e) -- 4981
				return __TS__AsyncAwaiter(function() -- 4981
					____hasReturned = true -- 4984
					____returnValue = finalizeAgentFailure( -- 4984
						shared, -- 4984
						tostring(e) -- 4984
					) -- 4984
					return -- 4984
				end) -- 4984
			end -- 4984
		) -- 4984
		__TS__Await(____try) -- 4896
		if ____hasReturned then -- 4896
			return ____awaiter_resolve(nil, ____returnValue) -- 4896
		end -- 4896
	end) -- 4896
end -- 4801
function ____exports.runCodingAgent(options, callback) -- 4988
	local ____self_196 = runCodingAgentAsync(options) -- 4988
	____self_196["then"]( -- 4988
		____self_196, -- 4988
		function(____, result) return callback(result) end -- 4989
	) -- 4989
end -- 4988
return ____exports -- 4988