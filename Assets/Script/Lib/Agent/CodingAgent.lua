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
local ____AgentStepBudget = require("Agent.AgentStepBudget") -- 14
local getRemainingAgentWorkSteps = ____AgentStepBudget.getRemainingAgentWorkSteps -- 14
local isFinalAgentDecisionTurn = ____AgentStepBudget.isFinalAgentDecisionTurn -- 14
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
function toJson(value, emptyAsArray) -- 832
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 833
	if text ~= nil then -- 833
		return text -- 834
	end -- 834
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 835
end -- 835
function truncateText(text, maxLen) -- 838
	if #text <= maxLen then -- 838
		return text -- 839
	end -- 839
	local nextPos = utf8.offset(text, maxLen + 1) -- 840
	if nextPos == nil then -- 840
		return text -- 841
	end -- 841
	return string.sub(text, 1, nextPos - 1) .. "..." -- 842
end -- 842
function utf8TakeHead(text, maxChars) -- 845
	if maxChars <= 0 or text == "" then -- 845
		return "" -- 846
	end -- 846
	local nextPos = utf8.offset(text, maxChars + 1) -- 847
	if nextPos == nil then -- 847
		return text -- 848
	end -- 848
	return string.sub(text, 1, nextPos - 1) -- 849
end -- 849
function utf8TakeTail(text, maxChars) -- 852
	if maxChars <= 0 or text == "" then -- 852
		return "" -- 853
	end -- 853
	local charLength = utf8.len(text) -- 854
	if charLength == nil or charLength <= maxChars then -- 854
		return text -- 855
	end -- 855
	local startPos = utf8.offset( -- 856
		text, -- 856
		math.max(1, charLength - maxChars + 1) -- 856
	) -- 856
	if startPos == nil then -- 856
		return text -- 857
	end -- 857
	return string.sub(text, startPos) -- 858
end -- 858
function truncateHistoryText(text, maxChars, label) -- 861
	if maxChars <= 0 or text == "" then -- 861
		return "" -- 862
	end -- 862
	if #text <= maxChars then -- 862
		return text -- 863
	end -- 863
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 864
	local remaining = math.max(0, maxChars - #marker) -- 865
	local headChars = math.floor(remaining * 0.6) -- 866
	local tailChars = remaining - headChars -- 867
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 868
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
function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 885
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 901
	local contentLines = __TS__StringSplit(content, "\n") -- 902
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 903
	if #content <= maxChars and availableSourceLines <= maxLines then -- 903
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 905
	end -- 905
	local contentBudget = math.max(0, maxChars - 240) -- 916
	local candidateLines = math.min(availableSourceLines, maxLines) -- 917
	local retainedLines = {} -- 918
	local retainedChars = 0 -- 919
	do -- 919
		local i = 0 -- 920
		while i < candidateLines do -- 920
			local line = contentLines[i + 1] -- 921
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 922
			if nextChars > contentBudget then -- 922
				break -- 923
			end -- 923
			retainedLines[#retainedLines + 1] = line -- 924
			retainedChars = nextChars -- 925
			i = i + 1 -- 920
		end -- 920
	end -- 920
	local retainedEndLine = startLine + #retainedLines - 1 -- 928
	local partialLine -- 929
	local retainedContent = table.concat(retainedLines, "\n") -- 930
	if #retainedLines == 0 and candidateLines > 0 then -- 930
		partialLine = startLine -- 932
		retainedEndLine = startLine - 1 -- 933
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 934
	end -- 934
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 936
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 937
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 942
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 945
	return { -- 946
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 947
		truncated = true, -- 948
		retainedStartLine = startLine, -- 949
		retainedEndLine = retainedEndLine, -- 950
		nextStartLine = nextStartLine, -- 951
		partialLine = partialLine -- 952
	} -- 952
end -- 952
function sanitizeReadResultForHistory(tool, result) -- 968
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 968
		return result -- 970
	end -- 970
	local clone = {} -- 972
	for key in pairs(result) do -- 973
		clone[key] = result[key] -- 974
	end -- 974
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 976
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 977
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 978
	local limited = limitReadContentForHistory( -- 979
		result.content, -- 980
		startLine, -- 981
		endLine, -- 982
		totalLines, -- 983
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 984
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 985
		"read_file history" -- 986
	) -- 986
	clone.content = limited.content -- 988
	if limited.truncated then -- 988
		clone.historyContentTruncated = true -- 990
		clone.historyRetainedStartLine = limited.retainedStartLine -- 991
		clone.historyRetainedEndLine = limited.retainedEndLine -- 992
		if limited.nextStartLine ~= nil then -- 992
			clone.historyNextStartLine = limited.nextStartLine -- 993
		end -- 993
		if limited.partialLine ~= nil then -- 993
			clone.historyPartialLine = limited.partialLine -- 994
		end -- 994
	end -- 994
	return clone -- 996
end -- 996
function sanitizeSearchMatchesForHistory(items, maxItems) -- 999
	local shown = math.min(#items, maxItems) -- 1003
	local out = {} -- 1004
	do -- 1004
		local i = 0 -- 1005
		while i < shown do -- 1005
			local row = items[i + 1] -- 1006
			out[#out + 1] = { -- 1007
				file = row.file, -- 1008
				line = row.line, -- 1009
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1010
			} -- 1010
			i = i + 1 -- 1005
		end -- 1005
	end -- 1005
	return out -- 1015
end -- 1015
function sanitizeSearchResultForHistory(tool, result) -- 1018
	if result.success ~= true or not isArray(result.results) then -- 1018
		return result -- 1022
	end -- 1022
	if tool ~= "grep_files" and tool ~= "search_dora_doc" then -- 1022
		return result -- 1023
	end -- 1023
	local clone = {} -- 1024
	for key in pairs(result) do -- 1025
		clone[key] = result[key] -- 1026
	end -- 1026
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 1028
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1029
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1029
		local grouped = result.groupedResults -- 1034
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 1035
		local sanitizedGroups = {} -- 1036
		do -- 1036
			local i = 0 -- 1037
			while i < shown do -- 1037
				local row = grouped[i + 1] -- 1038
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1039
					file = row.file, -- 1040
					totalMatches = row.totalMatches, -- 1041
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1042
				} -- 1042
				i = i + 1 -- 1037
			end -- 1037
		end -- 1037
		clone.groupedResults = sanitizedGroups -- 1047
	end -- 1047
	return clone -- 1049
end -- 1049
function sanitizeListFilesResultForHistory(result) -- 1052
	if result.success ~= true or not isArray(result.files) then -- 1052
		return result -- 1053
	end -- 1053
	local clone = {} -- 1054
	for key in pairs(result) do -- 1055
		clone[key] = result[key] -- 1056
	end -- 1056
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 1058
	return clone -- 1059
end -- 1059
function sanitizeBuildResultForHistory(result) -- 1062
	if not isArray(result.messages) then -- 1062
		return result -- 1063
	end -- 1063
	local clone = {} -- 1064
	for key in pairs(result) do -- 1065
		clone[key] = result[key] -- 1066
	end -- 1066
	local messages = result.messages -- 1068
	local ordered = __TS__ArraySort( -- 1069
		__TS__ArraySlice(messages), -- 1069
		function(____, a, b) -- 1069
			local aFailed = a.success ~= true -- 1070
			local bFailed = b.success ~= true -- 1071
			if aFailed == bFailed then -- 1071
				return 0 -- 1072
			end -- 1072
			return aFailed and -1 or 1 -- 1073
		end -- 1069
	) -- 1069
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1075
	local sanitized = {} -- 1076
	do -- 1076
		local i = 0 -- 1077
		while i < shown do -- 1077
			local item = ordered[i + 1] -- 1078
			local next = {} -- 1079
			for key in pairs(item) do -- 1080
				local value = item[key] -- 1081
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1082
			end -- 1082
			sanitized[#sanitized + 1] = next -- 1086
			i = i + 1 -- 1077
		end -- 1077
	end -- 1077
	clone.messages = sanitized -- 1088
	if #ordered > shown then -- 1088
		clone.truncatedMessages = #ordered - shown -- 1090
	end -- 1090
	return clone -- 1092
end -- 1092
function projectEditResultForLLM(result) -- 1110
	if result.success ~= true then -- 1110
		local failed = {} -- 1112
		for key in pairs(result) do -- 1113
			local value = result[key] -- 1114
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 1115
		end -- 1115
		return failed -- 1119
	end -- 1119
	local projected = {} -- 1121
	local scalarKeys = { -- 1122
		"success", -- 1123
		"changed", -- 1123
		"mode", -- 1123
		"checkpointId", -- 1123
		"checkpointSeq", -- 1123
		"checkpointed", -- 1124
		"reversible", -- 1124
		"binary", -- 1124
		"actualSaved", -- 1125
		"actualSavedCharacters", -- 1125
		"currentFileExists", -- 1125
		"currentCharacters", -- 1125
		"currentState" -- 1125
	} -- 1125
	do -- 1125
		local i = 0 -- 1127
		while i < #scalarKeys do -- 1127
			local key = scalarKeys[i + 1] -- 1128
			if result[key] ~= nil then -- 1128
				projected[key] = result[key] -- 1129
			end -- 1129
			i = i + 1 -- 1127
		end -- 1127
	end -- 1127
	if isArray(result.files) then -- 1127
		projected.files = result.files -- 1131
	end -- 1131
	if type(result.message) == "string" then -- 1131
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1133
	end -- 1133
	if type(result.guidance) == "string" then -- 1133
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1140
	end -- 1140
	if isArray(result.fileContext) then -- 1140
		local summaries = {} -- 1147
		do -- 1147
			local i = 0 -- 1148
			while i < #result.fileContext do -- 1148
				do -- 1148
					local item = result.fileContext[i + 1] -- 1149
					if not isRecord(item) or isArray(item) then -- 1149
						goto __continue157 -- 1150
					end -- 1150
					local summary = {} -- 1151
					local keys = { -- 1152
						"path", -- 1153
						"op", -- 1153
						"beforeExists", -- 1153
						"afterExists", -- 1153
						"beforeBytes", -- 1153
						"afterBytes", -- 1153
						"lineCount", -- 1154
						"contentTruncated", -- 1154
						"fileListTruncated" -- 1154
					} -- 1154
					do -- 1154
						local j = 0 -- 1156
						while j < #keys do -- 1156
							local key = keys[j + 1] -- 1157
							if item[key] ~= nil then -- 1157
								summary[key] = item[key] -- 1158
							end -- 1158
							j = j + 1 -- 1156
						end -- 1156
					end -- 1156
					summaries[#summaries + 1] = summary -- 1160
				end -- 1160
				::__continue157:: -- 1160
				i = i + 1 -- 1148
			end -- 1148
		end -- 1148
		if #summaries > 0 then -- 1148
			projected.fileSummary = summaries -- 1162
		end -- 1162
	end -- 1162
	if type(result.truncatedFileContextItems) == "number" then -- 1162
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1165
	end -- 1165
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1167
	return projected -- 1168
end -- 1168
function projectBuildResultForLLM(result) -- 1171
	if not isArray(result.messages) then -- 1171
		return result -- 1172
	end -- 1172
	local projected = {} -- 1173
	for key in pairs(result) do -- 1174
		if key ~= "messages" then -- 1174
			projected[key] = result[key] -- 1175
		end -- 1175
	end -- 1175
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1177
	local shown = math.min(#result.messages, maxMessages) -- 1178
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1179
	if #result.messages > shown then -- 1179
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1181
	end -- 1181
	return projected -- 1183
end -- 1183
function projectCommandResultForLLM(result) -- 1186
	local projected = {} -- 1187
	for key in pairs(result) do -- 1188
		local value = result[key] -- 1189
		if key == "output" and type(value) == "string" then -- 1189
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1191
		elseif key == "message" and type(value) == "string" then -- 1191
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1197
		else -- 1197
			projected[key] = value -- 1203
		end -- 1203
	end -- 1203
	return projected -- 1206
end -- 1206
function projectToolResultContentForLLM(tool, content) -- 1209
	local decoded = AgentUtils.safeJsonDecode(content) -- 1210
	if not isRecord(decoded) or isArray(decoded) then -- 1210
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1212
	end -- 1212
	local projected = decoded -- 1218
	if tool == "edit_file" or tool == "delete_file" then -- 1218
		projected = projectEditResultForLLM(decoded) -- 1220
	elseif tool == "build" then -- 1220
		projected = projectBuildResultForLLM(decoded) -- 1222
	elseif tool == "execute_command" then -- 1222
		projected = projectCommandResultForLLM(decoded) -- 1224
	end -- 1224
	local encoded = toJson(projected, false) -- 1226
	if tool == "read_file" then -- 1226
		return encoded -- 1229
	end -- 1229
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1229
		return encoded -- 1230
	end -- 1230
	local fallback = { -- 1231
		success = projected.success, -- 1232
		llmHistoryTruncated = true, -- 1233
		originalChars = #encoded, -- 1234
		preview = truncateHistoryText( -- 1235
			encoded, -- 1236
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1237
			tool .. " result" -- 1238
		) -- 1238
	} -- 1238
	return toJson(fallback, false) -- 1241
end -- 1241
function projectMessagesForLLMContext(messages) -- 1244
	local projected = {} -- 1248
	do -- 1248
		local i = 0 -- 1249
		while i < #messages do -- 1249
			local message = messages[i + 1] -- 1250
			local next = __TS__ObjectAssign({}, message) -- 1251
			if message.role == "tool" and type(message.content) == "string" then -- 1251
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1253
			end -- 1253
			projected[#projected + 1] = next -- 1255
			i = i + 1 -- 1249
		end -- 1249
	end -- 1249
	return projected -- 1257
end -- 1257
function ____exports.getDecisionDisabledAgentTools(shared) -- 1285
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1289
end -- 1285
function getDecisionToolDefinitions(shared) -- 1292
	local params = {SEARCH_DORA_DOC_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax)} -- 1293
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1294
	local base = shared.promptPack.toolDefinitionsDetailed -- 1297
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1298
	if usesDefaultToolPrompts then -- 1298
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1301
			shared.role, -- 1301
			{ -- 1301
				includeFinish = true, -- 1302
				includeXmlRules = true, -- 1303
				context = {searchDoraDocLimitMax = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax}, -- 1304
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1305
				workMode = shared.workMode -- 1306
			} -- 1306
		) -- 1306
		return replacePromptVars(definitions, params) -- 1308
	end -- 1308
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1310
	if (shared and shared.decisionMode) ~= "xml" then -- 1310
		return withRole -- 1315
	end -- 1315
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1317
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1318
end -- 1318
function isToolAllowedForRole(shared, tool) -- 1332
	return __TS__ArrayIndexOf( -- 1333
		AgentToolRegistry.getAllowedToolsForRole( -- 1333
			shared.role, -- 1333
			{ -- 1333
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1334
				workMode = shared.workMode -- 1335
			} -- 1335
		), -- 1335
		tool -- 1336
	) >= 0 -- 1336
end -- 1336
function getFinishMessage(params, fallback) -- 1799
	if fallback == nil then -- 1799
		fallback = "" -- 1799
	end -- 1799
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1799
		return __TS__StringTrim(params.message) -- 1801
	end -- 1801
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1801
		return __TS__StringTrim(params.response) -- 1804
	end -- 1804
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1804
		return __TS__StringTrim(params.summary) -- 1807
	end -- 1807
	return __TS__StringTrim(fallback) -- 1809
end -- 1809
function getCompletionReport(params) -- 1812
	return AgentUtils.normalizeAgentCompletionReport(params) -- 1813
end -- 1813
function persistHistoryState(shared) -- 1816
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1817
end -- 1817
function getActiveConversationMessages(shared) -- 1824
	local activeMessages = {} -- 1825
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1825
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1832
	end -- 1832
	do -- 1832
		local i = shared.lastConsolidatedIndex -- 1836
		while i < #shared.messages do -- 1836
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1837
			i = i + 1 -- 1836
		end -- 1836
	end -- 1836
	return activeMessages -- 1839
end -- 1839
function getActiveRealMessageCount(shared) -- 1842
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1843
end -- 1843
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1846
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1852
	local previousActiveStart = shared.lastConsolidatedIndex -- 1853
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1854
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1855
	if type(carryMessageIndex) == "number" then -- 1855
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1855
		else -- 1855
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1863
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1866
		end -- 1866
	else -- 1866
		shared.carryMessageIndex = nil -- 1871
	end -- 1871
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1871
		shared.carryMessageIndex = nil -- 1881
	end -- 1881
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1889
	shared.resumeCheckpointPending = true -- 1890
	shared.resumeRequiredTool = nil -- 1891
	shared.resumeNarrowReadMode = true -- 1892
	if shared.unbuiltEdits == true then -- 1892
		shared.resumeRequiredTool = "build" -- 1900
	end -- 1900
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 -- 1909
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1909
		local marker = "**Next tool**:" -- 1920
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1921
		if markerIndex >= 0 then -- 1921
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1923
			local toolNames = { -- 1924
				"read_file", -- 1925
				"edit_file", -- 1925
				"delete_file", -- 1925
				"grep_files", -- 1925
				"search_dora_doc", -- 1925
				"glob_files", -- 1926
				"build", -- 1926
				"fetch_url", -- 1926
				"execute_command", -- 1926
				"list_sub_agents", -- 1926
				"spawn_sub_agent", -- 1927
				"finish" -- 1927
			} -- 1927
			do -- 1927
				local i = 0 -- 1929
				while i < #toolNames do -- 1929
					local tool = toolNames[i + 1] -- 1930
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1930
						shared.resumeRequiredTool = tool -- 1932
						break -- 1933
					end -- 1933
					i = i + 1 -- 1929
				end -- 1929
			end -- 1929
		end -- 1929
	end -- 1929
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1929
		shared.resumeRequiredTool = nil -- 1939
	end -- 1939
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1939
		shared.resumeRequiredTool = nil -- 1942
	end -- 1942
end -- 1942
function ensureToolCallId(toolCallId) -- 1957
	if toolCallId and toolCallId ~= "" then -- 1957
		return toolCallId -- 1958
	end -- 1958
	return AgentUtils.createLocalToolCallId() -- 1959
end -- 1959
function hasXMLParam(params, name) -- 1992
	return params[name] ~= nil -- 1993
end -- 1993
function inferToolNameFromXMLParams(params) -- 1996
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1996
		return "edit_file" -- 1998
	end -- 1998
	if hasXMLParam(params, "target_file") then -- 1998
		return "delete_file" -- 2001
	end -- 2001
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 2001
		if hasXMLParam(params, "path") then -- 2001
			return "read_file" -- 2004
		end -- 2004
		return nil -- 2005
	end -- 2005
	if hasXMLParam(params, "docType") or hasXMLParam(params, "programmingLanguage") then -- 2005
		if hasXMLParam(params, "pattern") then -- 2005
			return "search_dora_doc" -- 2008
		end -- 2008
		return nil -- 2009
	end -- 2009
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 2009
		if hasXMLParam(params, "pattern") then -- 2009
			return "grep_files" -- 2012
		end -- 2012
		return nil -- 2013
	end -- 2013
	if hasXMLParam(params, "globs") then -- 2013
		if hasXMLParam(params, "pattern") then -- 2013
			return "grep_files" -- 2016
		end -- 2016
		return "glob_files" -- 2017
	end -- 2017
	if hasXMLParam(params, "maxEntries") then -- 2017
		return "glob_files" -- 2020
	end -- 2020
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2020
		return "finish" -- 2023
	end -- 2023
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 2023
		return "spawn_sub_agent" -- 2026
	end -- 2026
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 2026
		return "list_sub_agents" -- 2029
	end -- 2029
	return nil -- 2031
end -- 2031
function parseDSMLAttribute(source, offset, name) -- 2034
	local attrOpen = name .. "=\"" -- 2035
	local attrStart = (string.find( -- 2036
		source, -- 2036
		attrOpen, -- 2036
		math.max(offset + 1, 1), -- 2036
		true -- 2036
	) or 0) - 1 -- 2036
	if attrStart < 0 then -- 2036
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 2037
	end -- 2037
	local valueStart = attrStart + #attrOpen -- 2038
	local valueEnd = (string.find( -- 2039
		source, -- 2039
		"\"", -- 2039
		math.max(valueStart + 1, 1), -- 2039
		true -- 2039
	) or 0) - 1 -- 2039
	if valueEnd < 0 then -- 2039
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 2040
	end -- 2040
	return { -- 2041
		success = true, -- 2042
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 2043
		next = valueEnd + 1 -- 2044
	} -- 2044
end -- 2044
function extractDSMLReason(text, invokeStart, tool) -- 2048
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2049
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2050
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2050
		return before -- 2053
	end -- 2053
	if tool == "finish" then -- 2053
		return "" -- 2054
	end -- 2054
	return "Converted provider-native tool call syntax to XML." -- 2055
end -- 2055
function parseDSMLToolCallObjectFromText(text) -- 2058
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2059
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2060
	if invokeStart < 0 then -- 2060
		return {success = false, message = "missing DSML invoke"} -- 2061
	end -- 2061
	local nameStart = invokeStart + #invokeOpen -- 2062
	local nameEnd = (string.find( -- 2063
		text, -- 2063
		"\"", -- 2063
		math.max(nameStart + 1, 1), -- 2063
		true -- 2063
	) or 0) - 1 -- 2063
	if nameEnd < 0 then -- 2063
		return {success = false, message = "unterminated DSML invoke name"} -- 2064
	end -- 2064
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2065
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2065
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2067
	end -- 2067
	local invokeOpenEnd = (string.find( -- 2069
		text, -- 2069
		">", -- 2069
		math.max(nameEnd + 1, 1), -- 2069
		true -- 2069
	) or 0) - 1 -- 2069
	if invokeOpenEnd < 0 then -- 2069
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2070
	end -- 2070
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2071
	local invokeEnd = (string.find( -- 2072
		text, -- 2072
		invokeClose, -- 2072
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2072
		true -- 2072
	) or 0) - 1 -- 2072
	if invokeEnd < 0 then -- 2072
		return {success = false, message = "missing DSML invoke close tag"} -- 2073
	end -- 2073
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2075
	local params = {} -- 2076
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2077
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2078
	local pos = 0 -- 2079
	while pos < #body do -- 2079
		local start = (string.find( -- 2081
			body, -- 2081
			paramOpen, -- 2081
			math.max(pos + 1, 1), -- 2081
			true -- 2081
		) or 0) - 1 -- 2081
		if start < 0 then -- 2081
			break -- 2082
		end -- 2082
		local openEnd = (string.find( -- 2083
			body, -- 2083
			">", -- 2083
			math.max(start + #paramOpen + 1, 1), -- 2083
			true -- 2083
		) or 0) - 1 -- 2083
		if openEnd < 0 then -- 2083
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2084
		end -- 2084
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2085
		if not name.success then -- 2085
			return name -- 2086
		end -- 2086
		local close = (string.find( -- 2087
			body, -- 2087
			paramClose, -- 2087
			math.max(openEnd + 1 + 1, 1), -- 2087
			true -- 2087
		) or 0) - 1 -- 2087
		if close < 0 then -- 2087
			return {success = false, message = "missing DSML parameter close tag"} -- 2088
		end -- 2088
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2089
		pos = close + #paramClose -- 2090
	end -- 2090
	return { -- 2092
		success = true, -- 2093
		obj = { -- 2094
			tool = toolName, -- 2095
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2096
			params = params -- 2097
		} -- 2097
	} -- 2097
end -- 2097
function parseXMLToolCallObjectFromText(text) -- 2102
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2103
	local rawObj -- 2104
	if children.success then -- 2104
		rawObj = children.obj -- 2106
	else -- 2106
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2108
		if dsml.success then -- 2108
			return dsml -- 2109
		end -- 2109
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2110
		local paramsCloseToken = "</params>" -- 2111
		if toolStart >= 0 then -- 2111
			local paramsClose = (string.find( -- 2113
				text, -- 2113
				paramsCloseToken, -- 2113
				math.max(toolStart + 1, 1), -- 2113
				true -- 2113
			) or 0) - 1 -- 2113
			if paramsClose >= toolStart then -- 2113
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2115
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2116
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2116
					rawObj = bare.obj -- 2118
				end -- 2118
			end -- 2118
		end -- 2118
		if rawObj == nil then -- 2118
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2123
			if paramsOpen < 0 then -- 2123
				return children -- 2124
			end -- 2124
			local paramsCloseOnly = (string.find( -- 2125
				text, -- 2125
				paramsCloseToken, -- 2125
				math.max(paramsOpen + 1, 1), -- 2125
				true -- 2125
			) or 0) - 1 -- 2125
			if paramsCloseOnly < paramsOpen then -- 2125
				return children -- 2126
			end -- 2126
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2127
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2128
			if not paramsOnly.success then -- 2128
				return children -- 2129
			end -- 2129
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2130
			if inferredTool == nil then -- 2130
				return children -- 2131
			end -- 2131
			local ____temp_50 -- 2136
			if inferredTool == "finish" then -- 2136
				____temp_50 = nil -- 2136
			else -- 2136
				____temp_50 = "Inferred tool from XML params." -- 2136
			end -- 2136
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2132
		end -- 2132
	end -- 2132
	if rawObj == nil then -- 2132
		return children -- 2142
	end -- 2142
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2143
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2144
	if not params.success then -- 2144
		return {success = false, message = params.message} -- 2148
	end -- 2148
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2150
end -- 2150
function parseDecisionObject(rawObj) -- 2246
	if type(rawObj.tool) ~= "string" then -- 2246
		return {success = false, message = "missing tool"} -- 2247
	end -- 2247
	local tool = rawObj.tool -- 2248
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2248
		return {success = false, message = "unknown tool: " .. tool} -- 2250
	end -- 2250
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2252
	if tool ~= "finish" and (not reason or reason == "") then -- 2252
		return {success = false, message = tool .. " requires top-level reason"} -- 2256
	end -- 2256
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2258
	return {success = true, tool = tool, params = params, reason = reason} -- 2259
end -- 2259
function getDecisionPath(params) -- 2381
	if type(params.path) == "string" then -- 2381
		return __TS__StringTrim(params.path) -- 2382
	end -- 2382
	if type(params.target_file) == "string" then -- 2382
		return __TS__StringTrim(params.target_file) -- 2383
	end -- 2383
	return "" -- 2384
end -- 2384
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2387
	if enforceFinalTurn == nil then -- 2387
		enforceFinalTurn = false -- 2391
	end -- 2391
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2391
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2394
	end -- 2394
	if not isToolAllowedForRole(shared, tool) then -- 2394
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2397
	end -- 2397
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2397
		local path = getDecisionPath(params) -- 2400
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2400
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2402
		end -- 2402
	end -- 2402
	if tool == "delete_file" then -- 2402
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2406
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2406
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2408
		end -- 2408
	end -- 2408
	return {success = true} -- 2411
end -- 2411
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2414
	local num = __TS__Number(value) -- 2415
	if not __TS__NumberIsFinite(num) then -- 2415
		num = fallback -- 2416
	end -- 2416
	num = math.floor(num) -- 2417
	if num < minValue then -- 2417
		num = minValue -- 2418
	end -- 2418
	if maxValue ~= nil and num > maxValue then -- 2418
		num = maxValue -- 2419
	end -- 2419
	return num -- 2420
end -- 2420
function parseReadLineParam(value, fallback, paramName) -- 2423
	local num = __TS__Number(value) -- 2428
	if not __TS__NumberIsFinite(num) then -- 2428
		num = fallback -- 2429
	end -- 2429
	num = math.floor(num) -- 2430
	if num == 0 then -- 2430
		return {success = false, message = paramName .. " cannot be 0"} -- 2432
	end -- 2432
	return {success = true, value = num} -- 2434
end -- 2434
function validateDecision(tool, params) -- 2437
	if tool == "finish" then -- 2437
		local message = getFinishMessage(params) -- 2442
		if message == "" then -- 2442
			return {success = false, message = "finish requires params.message"} -- 2443
		end -- 2443
		params.message = message -- 2444
		local completion = getCompletionReport(params) -- 2445
		params.outcome = completion.outcome -- 2446
		params.validation = completion.validation -- 2447
		params.knownIssues = completion.knownIssues -- 2448
		params.assumptions = completion.assumptions -- 2449
		params.learningCandidates = completion.learningCandidates -- 2450
		return {success = true, params = params} -- 2451
	end -- 2451
	if tool == "ask_user" then -- 2451
		local normalized = normalizeQuestionnaire(params) -- 2455
		if not normalized.success then -- 2455
			return normalized -- 2456
		end -- 2456
		return {success = true, params = normalized.schema} -- 2457
	end -- 2457
	if tool == "read_file" then -- 2457
		local path = getDecisionPath(params) -- 2461
		if path == "" then -- 2461
			return {success = false, message = "read_file requires path"} -- 2462
		end -- 2462
		params.path = path -- 2463
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2464
		if not startLineRes.success then -- 2464
			return startLineRes -- 2465
		end -- 2465
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2466
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2467
		if not endLineRes.success then -- 2467
			return endLineRes -- 2468
		end -- 2468
		params.startLine = startLineRes.value -- 2469
		params.endLine = endLineRes.value -- 2470
		return {success = true, params = params} -- 2471
	end -- 2471
	if tool == "edit_file" then -- 2471
		local path = getDecisionPath(params) -- 2475
		if path == "" then -- 2475
			return {success = false, message = "edit_file requires path"} -- 2476
		end -- 2476
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2477
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2478
		params.path = path -- 2479
		params.old_str = oldStr -- 2480
		params.new_str = newStr -- 2481
		return {success = true, params = params} -- 2482
	end -- 2482
	if tool == "delete_file" then -- 2482
		local targetFile = getDecisionPath(params) -- 2486
		if targetFile == "" then -- 2486
			return {success = false, message = "delete_file requires target_file"} -- 2487
		end -- 2487
		params.target_file = targetFile -- 2488
		return {success = true, params = params} -- 2489
	end -- 2489
	if tool == "grep_files" then -- 2489
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2493
		if pattern == "" then -- 2493
			return {success = false, message = "grep_files requires pattern"} -- 2494
		end -- 2494
		params.pattern = pattern -- 2495
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2496
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2497
		return {success = true, params = params} -- 2498
	end -- 2498
	if tool == "search_dora_doc" then -- 2498
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2502
		if pattern == "" then -- 2502
			return {success = false, message = "search_dora_doc requires pattern"} -- 2503
		end -- 2503
		local docType = type(params.docType) == "string" and params.docType or "dora-api" -- 2504
		if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 2504
			return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 2506
		end -- 2506
		params.pattern = pattern -- 2508
		params.docType = docType -- 2509
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 2510
		return {success = true, params = params} -- 2511
	end -- 2511
	if tool == "glob_files" then -- 2511
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2515
		return {success = true, params = params} -- 2516
	end -- 2516
	if tool == "build" then -- 2516
		local path = getDecisionPath(params) -- 2520
		if path ~= "" then -- 2520
			params.path = path -- 2522
		end -- 2522
		return {success = true, params = params} -- 2524
	end -- 2524
	if tool == "list_sub_agents" then -- 2524
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2528
		if status ~= "" then -- 2528
			params.status = status -- 2530
		end -- 2530
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2532
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2533
		if type(params.query) == "string" then -- 2533
			params.query = __TS__StringTrim(params.query) -- 2535
		end -- 2535
		return {success = true, params = params} -- 2537
	end -- 2537
	if tool == "spawn_sub_agent" then -- 2537
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2541
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2542
		if prompt == "" then -- 2542
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2543
		end -- 2543
		if title == "" then -- 2543
			return {success = false, message = "spawn_sub_agent requires title"} -- 2544
		end -- 2544
		params.prompt = prompt -- 2545
		params.title = title -- 2546
		if type(params.expectedOutput) == "string" then -- 2546
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2548
		end -- 2548
		if isArray(params.filesHint) then -- 2548
			params.filesHint = __TS__ArrayMap( -- 2551
				__TS__ArrayFilter( -- 2551
					params.filesHint, -- 2551
					function(____, item) return type(item) == "string" end -- 2552
				), -- 2552
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2553
			) -- 2553
		end -- 2553
		return {success = true, params = params} -- 2555
	end -- 2555
	return {success = true, params = params} -- 2558
end -- 2558
function validateCompletionForRole(role, tool, params) -- 2561
	if role ~= "sub" or tool ~= "finish" then -- 2561
		return {success = true} -- 2566
	end -- 2566
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2566
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2568
	end -- 2568
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2570
	do -- 2570
		local i = 0 -- 2571
		while i < #requiredArrays do -- 2571
			local name = requiredArrays[i + 1] -- 2572
			if not isArray(params[name]) then -- 2572
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2574
			end -- 2574
			i = i + 1 -- 2571
		end -- 2571
	end -- 2571
	return {success = true} -- 2577
end -- 2577
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2580
	if includeToolDefinitions == nil then -- 2580
		includeToolDefinitions = false -- 2580
	end -- 2580
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2581
	local sections = { -- 2584
		shared.promptPack.agentIdentityPrompt, -- 2585
		rolePrompt, -- 2586
		getReplyLanguageDirective(shared) -- 2587
	} -- 2587
	if shared.role == "main" then -- 2587
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2590
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2591
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2591
			sections[#sections + 1] = table.concat( -- 2593
				{ -- 2593
					"# Current Living Development Plan", -- 2594
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2595
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2595
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2596
						12000 -- 2596
					), -- 2596
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2596
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2597
						12000 -- 2597
					) -- 2597
				}, -- 2597
				"\n\n" -- 2598
			) -- 2598
		end -- 2598
	end -- 2598
	if shared.decisionMode == "tool_calling" then -- 2598
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2602
	end -- 2602
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2604
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2605
	if memoryContext ~= "" then -- 2605
		sections[#sections + 1] = memoryContext -- 2607
	end -- 2607
	local skillsSection = buildSkillsSection(shared) -- 2609
	if skillsSection ~= "" then -- 2609
		sections[#sections + 1] = skillsSection -- 2611
	end -- 2611
	if includeToolDefinitions then -- 2611
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2614
		if shared.decisionMode == "xml" then -- 2614
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2616
		end -- 2616
	end -- 2616
	return table.concat(sections, "\n\n") -- 2619
end -- 2619
function buildSkillsSection(shared) -- 2622
	local ____opt_69 = shared.skills -- 2622
	if not (____opt_69 and ____opt_69.loader) then -- 2622
		return "" -- 2624
	end -- 2624
	return shared.skills.loader:buildSkillsPromptSection() -- 2626
end -- 2626
function sanitizeMessagesForLLMInput(messages) -- 2629
	local sanitized = {} -- 2630
	local droppedAssistantToolCalls = 0 -- 2631
	local droppedToolResults = 0 -- 2632
	do -- 2632
		local i = 0 -- 2633
		while i < #messages do -- 2633
			do -- 2633
				local message = messages[i + 1] -- 2634
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2634
					local requiredIds = {} -- 2636
					do -- 2636
						local j = 0 -- 2637
						while j < #message.tool_calls do -- 2637
							local toolCall = message.tool_calls[j + 1] -- 2638
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2639
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2639
								requiredIds[#requiredIds + 1] = id -- 2641
							end -- 2641
							j = j + 1 -- 2637
						end -- 2637
					end -- 2637
					if #requiredIds == 0 then -- 2637
						sanitized[#sanitized + 1] = message -- 2645
						goto __continue454 -- 2646
					end -- 2646
					local matchedIds = {} -- 2648
					local matchedTools = {} -- 2649
					local j = i + 1 -- 2650
					while j < #messages do -- 2650
						local toolMessage = messages[j + 1] -- 2652
						if toolMessage.role ~= "tool" then -- 2652
							break -- 2653
						end -- 2653
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2654
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2654
							matchedIds[toolCallId] = true -- 2656
							matchedTools[#matchedTools + 1] = toolMessage -- 2657
						else -- 2657
							droppedToolResults = droppedToolResults + 1 -- 2659
						end -- 2659
						j = j + 1 -- 2661
					end -- 2661
					local complete = true -- 2663
					do -- 2663
						local j = 0 -- 2664
						while j < #requiredIds do -- 2664
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2664
								complete = false -- 2666
								break -- 2667
							end -- 2667
							j = j + 1 -- 2664
						end -- 2664
					end -- 2664
					if complete then -- 2664
						__TS__ArrayPush( -- 2671
							sanitized, -- 2671
							message, -- 2671
							table.unpack(matchedTools) -- 2671
						) -- 2671
					else -- 2671
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2673
						droppedToolResults = droppedToolResults + #matchedTools -- 2674
					end -- 2674
					i = j - 1 -- 2676
					goto __continue454 -- 2677
				end -- 2677
				if message.role == "tool" then -- 2677
					droppedToolResults = droppedToolResults + 1 -- 2680
					goto __continue454 -- 2681
				end -- 2681
				sanitized[#sanitized + 1] = message -- 2683
			end -- 2683
			::__continue454:: -- 2683
			i = i + 1 -- 2633
		end -- 2633
	end -- 2633
	return sanitized -- 2685
end -- 2685
function getUnconsolidatedMessages(shared) -- 2688
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2689
end -- 2689
function isFinalDecisionTurn(shared) -- 2694
	return isFinalAgentDecisionTurn(shared.agentStepCount, shared.maxSteps) -- 2695
end -- 2695
function getFinalDecisionTurnPrompt(shared) -- 2698
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2699
end -- 2699
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2704
	if attempt == nil then -- 2704
		attempt = 1 -- 2707
	end -- 2707
	if decisionMode == nil then -- 2707
		decisionMode = shared.decisionMode -- 2709
	end -- 2709
	if consumeResumeCheckpoint == nil then -- 2709
		consumeResumeCheckpoint = true -- 2710
	end -- 2710
	if pendingUserPrompt == nil then -- 2710
		pendingUserPrompt = "" -- 2711
	end -- 2711
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2713
	local tailSections = {} -- 2714
	if shared.resumeCheckpointPending == true then -- 2714
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2720
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2724
	end -- 2724
	if shared.truncatedToolOverwritePath ~= nil then -- 2724
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2727
	end -- 2727
	if consumeResumeCheckpoint then -- 2727
		shared.resumeCheckpointPending = false -- 2729
	end -- 2729
	local messages = { -- 2730
		{role = "system", content = systemPrompt}, -- 2731
		table.unpack(getUnconsolidatedMessages(shared)) -- 2732
	} -- 2732
	if pendingUserPrompt ~= "" then -- 2732
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2735
	end -- 2735
	if isFinalDecisionTurn(shared) then -- 2735
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2738
	end -- 2738
	if lastError and lastError ~= "" then -- 2738
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2741
		if decisionMode == "xml" then -- 2741
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2745
		end -- 2745
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2745
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2748
		end -- 2748
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2748
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2751
		end -- 2751
		messages[#messages + 1] = { -- 2753
			role = "user", -- 2754
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2755
		} -- 2755
	end -- 2755
	if #tailSections > 0 then -- 2755
		messages[#messages + 1] = { -- 2763
			role = "user", -- 2764
			content = table.concat(tailSections, "\n\n") -- 2765
		} -- 2765
	end -- 2765
	return messages -- 2768
end -- 2768
function buildXmlDecisionInstruction(shared, feedback) -- 2771
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2772
end -- 2772
function tryParseAndValidateDecision(rawText, shared) -- 2840
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2841
	if not parsed.success then -- 2841
		return {success = false, message = parsed.message, raw = rawText} -- 2843
	end -- 2843
	local decision = parseDecisionObject(parsed.obj) -- 2845
	if not decision.success then -- 2845
		return {success = false, message = decision.message, raw = rawText} -- 2847
	end -- 2847
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2849
	if not completionValidation.success then -- 2849
		return {success = false, message = completionValidation.message, raw = rawText} -- 2851
	end -- 2851
	local validation = validateDecision(decision.tool, decision.params) -- 2853
	if not validation.success then -- 2853
		return {success = false, message = validation.message, raw = rawText} -- 2855
	end -- 2855
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2857
	if not sharedValidation.success then -- 2857
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2859
	end -- 2859
	decision.params = validation.params -- 2861
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2862
	return decision -- 2863
end -- 2863
function executeToolAction(shared, action) -- 4048
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4048
		if shared.stopToken.stopped then -- 4048
			return ____awaiter_resolve( -- 4048
				nil, -- 4048
				{ -- 4050
					success = false, -- 4050
					message = getCancelledReason(shared) -- 4050
				} -- 4050
			) -- 4050
		end -- 4050
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4050
			shared.resumeRequiredTool = nil -- 4053
			shared.resumeCheckpointPending = false -- 4054
		end -- 4054
		local params = action.params -- 4056
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4057
		if not sharedValidation.success then -- 4057
			return ____awaiter_resolve(nil, sharedValidation) -- 4057
		end -- 4057
		if action.tool == "read_file" then -- 4057
			local ____params_startLine_149 = params.startLine -- 4060
			if ____params_startLine_149 == nil then -- 4060
				____params_startLine_149 = 1 -- 4060
			end -- 4060
			local startLine = __TS__Number(____params_startLine_149) -- 4060
			local ____params_endLine_150 = params.endLine -- 4061
			if ____params_endLine_150 == nil then -- 4061
				____params_endLine_150 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4061
			end -- 4061
			local endLine = __TS__Number(____params_endLine_150) -- 4061
			local clippedAfterCompression = false -- 4062
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4062
				endLine = startLine + 159 -- 4069
				clippedAfterCompression = true -- 4070
			end -- 4070
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4072
			if __TS__StringTrim(path) == "" then -- 4072
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4072
			end -- 4072
			local result = Tools.readFile( -- 4076
				shared.workingDir, -- 4077
				path, -- 4078
				startLine, -- 4079
				endLine, -- 4080
				shared.useChineseResponse and "zh" or "en" -- 4081
			) -- 4081
			if clippedAfterCompression and result.success == true then -- 4081
				result.clipped = true -- 4084
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4085
			end -- 4085
			return ____awaiter_resolve(nil, result) -- 4085
		end -- 4085
		if action.tool == "grep_files" then -- 4085
			local searchPath = params.path or "" -- 4092
			local searchGlobs = params.globs -- 4093
			local ____Tools_searchFiles_164 = Tools.searchFiles -- 4094
			local ____shared_workingDir_157 = shared.workingDir -- 4095
			local ____temp_158 = params.pattern or "" -- 4097
			local ____params_globs_159 = params.globs -- 4098
			local ____params_useRegex_160 = params.useRegex -- 4099
			local ____params_caseSensitive_161 = params.caseSensitive -- 4100
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4102
			local ____math_max_153 = math.max -- 4103
			local ____math_floor_152 = math.floor -- 4103
			local ____params_limit_151 = params.limit -- 4103
			if ____params_limit_151 == nil then -- 4103
				____params_limit_151 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4103
			end -- 4103
			local ____math_max_153_result_163 = ____math_max_153( -- 4103
				1, -- 4103
				____math_floor_152(__TS__Number(____params_limit_151)) -- 4103
			) -- 4103
			local ____math_max_156 = math.max -- 4104
			local ____math_floor_155 = math.floor -- 4104
			local ____params_offset_154 = params.offset -- 4104
			if ____params_offset_154 == nil then -- 4104
				____params_offset_154 = 0 -- 4104
			end -- 4104
			local result = __TS__Await(____Tools_searchFiles_164({ -- 4094
				workDir = ____shared_workingDir_157, -- 4095
				path = searchPath, -- 4096
				pattern = ____temp_158, -- 4097
				globs = ____params_globs_159, -- 4098
				useRegex = ____params_useRegex_160, -- 4099
				caseSensitive = ____params_caseSensitive_161, -- 4100
				includeContent = true, -- 4101
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162, -- 4102
				limit = ____math_max_153_result_163, -- 4103
				offset = ____math_max_156( -- 4104
					0, -- 4104
					____math_floor_155(__TS__Number(____params_offset_154)) -- 4104
				), -- 4104
				groupByFile = params.groupByFile == true -- 4105
			})) -- 4105
			return ____awaiter_resolve(nil, result) -- 4105
		end -- 4105
		if action.tool == "search_dora_doc" then -- 4105
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4110
			local ____Tools_searchDoraDoc_173 = Tools.searchDoraDoc -- 4111
			local ____temp_169 = params.pattern or "" -- 4112
			local ____temp_170 = params.docType or "dora-api" -- 4113
			local ____temp_171 = shared.useChineseResponse and "zh" or "en" -- 4114
			local ____temp_172 = params.programmingLanguage or "ts" -- 4115
			local ____math_min_168 = math.min -- 4116
			local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_167 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 4116
			local ____math_max_166 = math.max -- 4116
			local ____params_limit_165 = params.limit -- 4116
			if ____params_limit_165 == nil then -- 4116
				____params_limit_165 = 8 -- 4116
			end -- 4116
			local result = __TS__Await(____Tools_searchDoraDoc_173({ -- 4111
				pattern = ____temp_169, -- 4112
				docType = ____temp_170, -- 4113
				docLanguage = ____temp_171, -- 4114
				programmingLanguage = ____temp_172, -- 4115
				limit = ____math_min_168( -- 4116
					____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_167, -- 4116
					____math_max_166( -- 4116
						1, -- 4116
						__TS__Number(____params_limit_165) -- 4116
					) -- 4116
				), -- 4116
				useRegex = params.useRegex, -- 4117
				caseSensitive = false, -- 4118
				includeContent = true, -- 4119
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4120
			})) -- 4120
			return ____awaiter_resolve(nil, result) -- 4120
		end -- 4120
		if action.tool == "glob_files" then -- 4120
			local ____Tools_listFiles_180 = Tools.listFiles -- 4125
			local ____shared_workingDir_177 = shared.workingDir -- 4126
			local ____temp_178 = params.path or "" -- 4127
			local ____params_globs_179 = params.globs -- 4128
			local ____math_max_176 = math.max -- 4129
			local ____math_floor_175 = math.floor -- 4129
			local ____params_maxEntries_174 = params.maxEntries -- 4129
			if ____params_maxEntries_174 == nil then -- 4129
				____params_maxEntries_174 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4129
			end -- 4129
			local result = ____Tools_listFiles_180({ -- 4125
				workDir = ____shared_workingDir_177, -- 4126
				path = ____temp_178, -- 4127
				globs = ____params_globs_179, -- 4128
				maxEntries = ____math_max_176( -- 4129
					1, -- 4129
					____math_floor_175(__TS__Number(____params_maxEntries_174)) -- 4129
				) -- 4129
			}) -- 4129
			return ____awaiter_resolve(nil, result) -- 4129
		end -- 4129
		if action.tool == "ask_user" then -- 4129
			if not shared.publishQuestionnaire then -- 4129
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4129
			end -- 4129
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4129
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4129
			end -- 4129
			local normalized = normalizeQuestionnaire(params) -- 4136
			if not normalized.success then -- 4136
				return ____awaiter_resolve(nil, normalized) -- 4136
			end -- 4136
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4138
			if not result.success then -- 4138
				return ____awaiter_resolve(nil, result) -- 4138
			end -- 4138
			shared.waitingQuestionnaireId = result.questionnaireId -- 4145
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4145
		end -- 4145
		if action.tool == "delete_file" then -- 4145
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4149
			if __TS__StringTrim(targetFile) == "" then -- 4149
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4149
			end -- 4149
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4153
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4154
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4154
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4154
			end -- 4154
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4158
			local result = Tools.deleteFile(shared.taskId, shared.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4159
			if not result.success then -- 4159
				return ____awaiter_resolve(nil, result) -- 4159
			end -- 4159
			if not isInternalDocumentEdit then -- 4159
				shared.unbuiltEdits = true -- 4167
				shared.lastBuildSucceeded = false -- 4168
				if shared.failedTestNeedsBuild == true then -- 4168
					shared.failedTestHasSourceEdit = true -- 4169
				end -- 4169
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4169
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4170
				end -- 4170
				shared.editedPathsSinceBuild = editedPaths -- 4171
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4172
			end -- 4172
			local ____result_checkpointed_182 = result.checkpointed -- 4178
			local ____result_reversible_183 = result.reversible -- 4179
			local ____result_binary_184 = result.binary -- 4180
			local ____temp_185 = result.checkpointed and result.checkpointId or nil -- 4181
			local ____temp_186 = result.checkpointed and result.checkpointSeq or nil -- 4182
			local ____result_checkpointed_181 -- 4183
			if result.checkpointed then -- 4183
				____result_checkpointed_181 = nil -- 4183
			else -- 4183
				____result_checkpointed_181 = result.message -- 4183
			end -- 4183
			return ____awaiter_resolve(nil, { -- 4183
				success = true, -- 4175
				changed = true, -- 4176
				mode = "delete", -- 4177
				checkpointed = ____result_checkpointed_182, -- 4178
				reversible = ____result_reversible_183, -- 4179
				binary = ____result_binary_184, -- 4180
				checkpointId = ____temp_185, -- 4181
				checkpointSeq = ____temp_186, -- 4182
				message = ____result_checkpointed_181, -- 4183
				files = {{path = targetFile, op = "delete"}} -- 4184
			}) -- 4184
		end -- 4184
		if action.tool == "build" then -- 4184
			local buildPath = params.path or "" -- 4188
			local result = __TS__Await(Tools.build({ -- 4189
				workDir = shared.workingDir, -- 4190
				path = buildPath, -- 4191
				isCancelled = function() return shared.stopToken.stopped end -- 4192
			})) -- 4192
			shared.unbuiltEdits = false -- 4194
			shared.editsSinceBuild = 0 -- 4195
			shared.editedPathsSinceBuild = {} -- 4196
			shared.hasBuilt = true -- 4197
			shared.lastBuildSucceeded = result.success -- 4198
			if result.success and shared.freshProjectBuildPending == true then -- 4198
				shared.freshProjectBuildPending = false -- 4204
			end -- 4204
			shared.apiSearchesSinceBuild = 0 -- 4206
			shared.buildRepairPending = false -- 4207
			if not result.success and result.messages ~= nil then -- 4207
				do -- 4207
					local i = 0 -- 4209
					while i < #result.messages do -- 4209
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4209
							shared.buildRepairPending = true -- 4211
							break -- 4212
						end -- 4212
						i = i + 1 -- 4209
					end -- 4209
				end -- 4209
			end -- 4209
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4209
				shared.failedTestNeedsBuild = false -- 4217
				shared.failedTestHasSourceEdit = false -- 4218
			end -- 4218
			return ____awaiter_resolve(nil, result) -- 4218
		end -- 4218
		if action.tool == "fetch_url" then -- 4218
			local result = __TS__Await(Tools.fetchUrl({ -- 4223
				workDir = shared.workingDir, -- 4224
				url = type(params.url) == "string" and params.url or "", -- 4225
				target = type(params.target) == "string" and params.target or "", -- 4226
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4227
				onProgress = function(____, progress) -- 4228
					emitAgentEvent( -- 4229
						shared, -- 4229
						{ -- 4229
							type = "tool_progress", -- 4230
							sessionId = shared.sessionId, -- 4231
							taskId = shared.taskId, -- 4232
							step = action.step, -- 4233
							tool = action.tool, -- 4234
							result = __TS__ObjectAssign({success = false}, progress) -- 4235
						} -- 4235
					) -- 4235
				end -- 4228
			})) -- 4228
			return ____awaiter_resolve(nil, result) -- 4228
		end -- 4228
		if action.tool == "execute_command" then -- 4228
			local mode = type(params.mode) == "string" and params.mode or "" -- 4245
			local result = __TS__Await(Tools.executeCommand({ -- 4246
				workDir = shared.workingDir, -- 4247
				mode = mode, -- 4248
				code = type(params.code) == "string" and params.code or nil, -- 4249
				command = type(params.command) == "string" and params.command or nil, -- 4250
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4251
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4252
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4253
				onProgress = function(____, progress) -- 4254
					emitAgentEvent( -- 4255
						shared, -- 4255
						{ -- 4255
							type = "tool_progress", -- 4256
							sessionId = shared.sessionId, -- 4257
							taskId = shared.taskId, -- 4258
							step = action.step, -- 4259
							tool = action.tool, -- 4260
							result = __TS__ObjectAssign({success = false}, progress) -- 4261
						} -- 4261
					) -- 4261
				end -- 4254
			})) -- 4254
			if result.success and mode == "lua" then -- 4254
				local deterministicFailure = false -- 4269
				local deterministicPass = false -- 4270
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4271
				do -- 4271
					local i = 0 -- 4272
					while i < #outputLines and not deterministicFailure do -- 4272
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4273
						if line == "passed" then -- 4273
							deterministicPass = true -- 4274
						end -- 4274
						if line == "failed" then -- 4274
							deterministicFailure = true -- 4276
							break -- 4277
						end -- 4277
						local searchFrom = 0 -- 4279
						while searchFrom < #line do -- 4279
							local failedIndex = (string.find( -- 4281
								line, -- 4281
								"failed", -- 4281
								math.max(searchFrom + 1, 1), -- 4281
								true -- 4281
							) or 0) - 1 -- 4281
							if failedIndex < 0 then -- 4281
								break -- 4282
							end -- 4282
							local after = failedIndex + #"failed" -- 4283
							while after < #line do -- 4283
								local ch = __TS__StringSlice(line, after, after + 1) -- 4285
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4285
									break -- 4286
								end -- 4286
								after = after + 1 -- 4287
							end -- 4287
							local afterEnd = after -- 4289
							while afterEnd < #line do -- 4289
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4291
								if ch < "0" or ch > "9" then -- 4291
									break -- 4292
								end -- 4292
								afterEnd = afterEnd + 1 -- 4293
							end -- 4293
							local count -- 4295
							if afterEnd > after then -- 4295
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4297
							else -- 4297
								local before = failedIndex - 1 -- 4299
								while before >= 0 do -- 4299
									local ch = __TS__StringSlice(line, before, before + 1) -- 4301
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4301
										break -- 4302
									end -- 4302
									before = before - 1 -- 4303
								end -- 4303
								local beforeEnd = before + 1 -- 4305
								while before >= 0 do -- 4305
									local ch = __TS__StringSlice(line, before, before + 1) -- 4307
									if ch < "0" or ch > "9" then -- 4307
										break -- 4308
									end -- 4308
									before = before - 1 -- 4309
								end -- 4309
								if beforeEnd > before + 1 then -- 4309
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4311
								end -- 4311
							end -- 4311
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4311
								deterministicFailure = true -- 4314
								break -- 4315
							end -- 4315
							searchFrom = failedIndex + #"failed" -- 4317
						end -- 4317
						i = i + 1 -- 4272
					end -- 4272
				end -- 4272
				if deterministicFailure then -- 4272
					shared.failedTestNeedsBuild = true -- 4321
					shared.failedTestHasSourceEdit = false -- 4322
				elseif deterministicPass then -- 4322
					shared.failedTestNeedsBuild = false -- 4324
					shared.failedTestHasSourceEdit = false -- 4325
				end -- 4325
			end -- 4325
			return ____awaiter_resolve(nil, result) -- 4325
		end -- 4325
		if action.tool == "spawn_sub_agent" then -- 4325
			if not shared.spawnSubAgent then -- 4325
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4325
			end -- 4325
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4325
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4325
			end -- 4325
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4337
				params.filesHint, -- 4338
				function(____, item) return type(item) == "string" end -- 4338
			) or nil -- 4338
			local result = __TS__Await(shared.spawnSubAgent({ -- 4340
				parentSessionId = shared.sessionId, -- 4341
				projectRoot = shared.workingDir, -- 4342
				title = type(params.title) == "string" and params.title or "Sub", -- 4343
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4344
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4345
				filesHint = filesHint, -- 4346
				disabledAgentTools = shared.disabledAgentTools -- 4347
			})) -- 4347
			if not result.success then -- 4347
				return ____awaiter_resolve(nil, result) -- 4347
			end -- 4347
			shared.hasSpawnedSubAgentThisTask = true -- 4352
			return ____awaiter_resolve(nil, { -- 4352
				success = true, -- 4354
				sessionId = result.sessionId, -- 4355
				taskId = result.taskId, -- 4356
				title = result.title, -- 4357
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4358
			}) -- 4358
		end -- 4358
		if action.tool == "list_sub_agents" then -- 4358
			if not shared.listSubAgents then -- 4358
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4358
			end -- 4358
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4358
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4358
			end -- 4358
			local result = __TS__Await(shared.listSubAgents({ -- 4368
				sessionId = shared.sessionId, -- 4369
				projectRoot = shared.workingDir, -- 4370
				status = type(params.status) == "string" and params.status or nil, -- 4371
				limit = type(params.limit) == "number" and params.limit or nil, -- 4372
				offset = type(params.offset) == "number" and params.offset or nil, -- 4373
				query = type(params.query) == "string" and params.query or nil -- 4374
			})) -- 4374
			return ____awaiter_resolve(nil, result) -- 4374
		end -- 4374
		if action.tool == "edit_file" then -- 4374
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4379
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4382
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4383
			if __TS__StringTrim(path) == "" then -- 4383
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4383
			end -- 4383
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4385
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4386
			if not isInternalDocumentEdit then -- 4386
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4388
				if preflightIssue ~= nil then -- 4388
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4390
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4391
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4391
				end -- 4391
			end -- 4391
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4397
			local result = __TS__Await(actionNode:exec({ -- 4398
				path = path, -- 4399
				oldStr = oldStr, -- 4400
				newStr = newStr, -- 4401
				taskId = shared.taskId, -- 4402
				workDir = shared.workingDir -- 4403
			})) -- 4403
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4403
				if params.partialStreamRecovery ~= true then -- 4403
					shared.truncatedToolOverwritePath = nil -- 4407
				end -- 4407
				shared.unbuiltEdits = true -- 4409
				shared.lastBuildSucceeded = false -- 4410
				if shared.failedTestNeedsBuild == true then -- 4410
					shared.failedTestHasSourceEdit = true -- 4411
				end -- 4411
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4412
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4412
					editedPaths[#editedPaths + 1] = normalizedPath -- 4413
				end -- 4413
				shared.editedPathsSinceBuild = editedPaths -- 4414
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4415
			end -- 4415
			return ____awaiter_resolve(nil, result) -- 4415
		end -- 4415
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4415
	end) -- 4415
end -- 4415
function sanitizeToolActionResultForHistory(action, result) -- 4422
	if action.tool == "read_file" then -- 4422
		return sanitizeReadResultForHistory(action.tool, result) -- 4424
	end -- 4424
	if action.tool == "grep_files" or action.tool == "search_dora_doc" then -- 4424
		return sanitizeSearchResultForHistory(action.tool, result) -- 4427
	end -- 4427
	if action.tool == "glob_files" then -- 4427
		return sanitizeListFilesResultForHistory(result) -- 4430
	end -- 4430
	if action.tool == "build" then -- 4430
		return sanitizeBuildResultForHistory(result) -- 4433
	end -- 4433
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4433
		if result.success ~= true then -- 4433
			return result -- 4436
		end -- 4436
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4436
			return result -- 4437
		end -- 4437
		if isArray(result.fileContext) then -- 4437
			return result -- 4438
		end -- 4438
		local contextLimits = { -- 4440
			fullContentChars = 12000, -- 4441
			previewChars = 4000, -- 4442
			diffChars = 8000, -- 4443
			totalChars = 24000, -- 4444
			maxFiles = 8 -- 4445
		} -- 4445
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4447
			if maxChars <= 0 then -- 4447
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4448
			end -- 4448
			if #sourceText <= maxChars then -- 4448
				return sourceText -- 4449
			end -- 4449
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4450
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4451
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4452
		end -- 4447
		local function countLines(sourceText) -- 4454
			if sourceText == "" then -- 4454
				return 0 -- 4455
			end -- 4455
			return #__TS__StringSplit(sourceText, "\n") -- 4456
		end -- 4454
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4458
			if beforeContent == afterContent then -- 4458
				return "" -- 4459
			end -- 4459
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4460
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4461
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4463
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4463
				firstChangedLine = firstChangedLine + 1 -- 4469
			end -- 4469
			local lastChangedBeforeLine = #beforeLines - 1 -- 4471
			local lastChangedAfterLine = #afterLines - 1 -- 4472
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4472
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4478
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4479
			end -- 4479
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4481
			local previewEndLine = math.max( -- 4482
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4483
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4484
			) -- 4484
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4486
			do -- 4486
				local lineIndex = previewStartLine -- 4487
				while lineIndex <= previewEndLine do -- 4487
					do -- 4487
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4488
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4489
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4490
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4491
						if not beforeChanged and not afterChanged then -- 4491
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4493
							if contextLine ~= nil then -- 4493
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4494
							end -- 4494
							goto __continue739 -- 4495
						end -- 4495
						if beforeChanged and beforeLine ~= nil then -- 4495
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4497
						end -- 4497
						if afterChanged and afterLine ~= nil then -- 4497
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4498
						end -- 4498
					end -- 4498
					::__continue739:: -- 4498
					lineIndex = lineIndex + 1 -- 4487
				end -- 4487
			end -- 4487
			return truncateContextSnippet( -- 4500
				table.concat(unifiedDiffLines, "\n"), -- 4500
				maxChars, -- 4500
				"diff" -- 4500
			) -- 4500
		end -- 4458
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4503
		if not checkpointDiff.success then -- 4503
			return result -- 4504
		end -- 4504
		local remainingContextBudget = contextLimits.totalChars -- 4505
		local fileContextItems = {} -- 4506
		local changedFiles = checkpointDiff.files -- 4507
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4508
		do -- 4508
			local fileIndex = 0 -- 4509
			while fileIndex < maxContextFiles do -- 4509
				if remainingContextBudget <= 0 then -- 4509
					break -- 4510
				end -- 4510
				local changedFile = changedFiles[fileIndex + 1] -- 4511
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4512
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4513
				local contextItem = { -- 4514
					path = changedFile.path, -- 4515
					op = changedFile.op, -- 4516
					checkpointId = result.checkpointId, -- 4517
					checkpointSeq = result.checkpointSeq, -- 4518
					beforeExists = changedFile.beforeExists, -- 4519
					afterExists = changedFile.afterExists, -- 4520
					beforeBytes = #beforeContent, -- 4521
					afterBytes = #afterContent, -- 4522
					diffPreview = "", -- 4523
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4524
					contentTruncated = false, -- 4525
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4526
				} -- 4526
				if changedFile.afterExists then -- 4526
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4526
						contextItem.afterContent = afterContent -- 4530
						remainingContextBudget = remainingContextBudget - #afterContent -- 4531
					else -- 4531
						contextItem.afterContentPreview = truncateContextSnippet( -- 4533
							afterContent, -- 4534
							math.min( -- 4535
								contextLimits.previewChars, -- 4535
								math.max(400, remainingContextBudget) -- 4535
							), -- 4535
							"afterContent" -- 4536
						) -- 4536
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4538
						contextItem.contentTruncated = true -- 4539
					end -- 4539
				end -- 4539
				local diffPreview = buildUnifiedDiffPreview( -- 4542
					changedFile.path, -- 4543
					beforeContent, -- 4544
					afterContent, -- 4545
					math.min( -- 4546
						contextLimits.diffChars, -- 4546
						math.max(400, remainingContextBudget) -- 4546
					) -- 4546
				) -- 4546
				contextItem.diffPreview = diffPreview -- 4548
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4549
				if not changedFile.afterExists and beforeContent ~= "" then -- 4549
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4551
						beforeContent, -- 4552
						math.min( -- 4553
							contextLimits.previewChars, -- 4553
							math.max(400, remainingContextBudget) -- 4553
						), -- 4553
						"beforeContent" -- 4554
					) -- 4554
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4556
					if #beforeContent > contextLimits.previewChars then -- 4556
						contextItem.contentTruncated = true -- 4557
					end -- 4557
				end -- 4557
				fileContextItems[#fileContextItems + 1] = contextItem -- 4559
				fileIndex = fileIndex + 1 -- 4509
			end -- 4509
		end -- 4509
		if #fileContextItems == 0 then -- 4509
			return result -- 4561
		end -- 4561
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4562
	end -- 4562
	return result -- 4569
end -- 4569
function emitAgentTaskFinishEvent(shared, success, message) -- 4770
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4771
	local result = success and ({ -- 4775
		success = true, -- 4777
		taskId = shared.taskId, -- 4778
		message = message, -- 4779
		steps = shared.step, -- 4780
		completion = completion -- 4781
	}) or ({ -- 4781
		success = false, -- 4784
		taskId = shared.taskId, -- 4785
		message = message, -- 4786
		steps = shared.step, -- 4787
		completion = completion -- 4788
	}) -- 4788
	emitAgentEvent(shared, { -- 4790
		type = "task_finished", -- 4791
		sessionId = shared.sessionId, -- 4792
		taskId = shared.taskId, -- 4793
		success = result.success, -- 4794
		message = result.message, -- 4795
		steps = result.steps, -- 4796
		completion = result.completion -- 4797
	}) -- 4797
	return result -- 4799
end -- 4799
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
	Tools.sendWebIDEFileUpdate(path, true, content) -- 751
	return true -- 752
end -- 746
local function createStepLLMDebugPair(shared, stepId, inContent) -- 755
	if not canWriteStepLLMDebug(shared, stepId) then -- 755
		return 0 -- 756
	end -- 756
	local dir = getStepLLMDebugDir(shared) -- 757
	if not ensureDirRecursive(dir) then -- 757
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 759
		return 0 -- 760
	end -- 760
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 762
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 763
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 764
	if not writeStepLLMDebugFile(inPath, inContent) then -- 764
		return 0 -- 766
	end -- 766
	writeStepLLMDebugFile(outPath, "") -- 768
	return seq -- 769
end -- 755
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 772
	if not canWriteStepLLMDebug(shared, stepId) then -- 772
		return -- 773
	end -- 773
	local dir = getStepLLMDebugDir(shared) -- 774
	if not ensureDirRecursive(dir) then -- 774
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 776
		return -- 777
	end -- 777
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 779
	if latestSeq <= 0 then -- 779
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 781
		writeStepLLMDebugFile(outPath, content) -- 782
		return -- 783
	end -- 783
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 785
	writeStepLLMDebugFile(outPath, content) -- 786
end -- 772
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 789
	if not canWriteStepLLMDebug(shared, stepId) then -- 789
		return -- 790
	end -- 790
	local sections = { -- 791
		"# LLM Input", -- 792
		"session_id: " .. tostring(shared.sessionId), -- 793
		"task_id: " .. tostring(shared.taskId), -- 794
		"step_id: " .. tostring(stepId), -- 795
		"phase: " .. phase, -- 796
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 797
		"## Options", -- 798
		"```json", -- 799
		encodeDebugJSON(options), -- 800
		"```" -- 801
	} -- 801
	local firstMessage = #messages > 0 and messages[1] or nil -- 803
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 803
		sections[#sections + 1] = "# System Prompt" -- 805
		sections[#sections + 1] = firstMessage.content -- 806
	end -- 806
	do -- 806
		local i = 0 -- 808
		while i < #messages do -- 808
			local message = messages[i + 1] -- 809
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 810
			sections[#sections + 1] = encodeDebugJSON(message) -- 811
			i = i + 1 -- 808
		end -- 808
	end -- 808
	createStepLLMDebugPair( -- 813
		shared, -- 813
		stepId, -- 813
		table.concat(sections, "\n") -- 813
	) -- 813
end -- 789
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 816
	if not canWriteStepLLMDebug(shared, stepId) then -- 816
		return -- 817
	end -- 817
	local ____array_24 = __TS__SparseArrayNew( -- 817
		"# LLM Output", -- 819
		"session_id: " .. tostring(shared.sessionId), -- 820
		"task_id: " .. tostring(shared.taskId), -- 821
		"step_id: " .. tostring(stepId), -- 822
		"phase: " .. phase, -- 823
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 824
		table.unpack(meta and ({ -- 825
			"## Meta", -- 825
			"```json", -- 825
			encodeDebugJSON(meta), -- 825
			"```" -- 825
		}) or ({})) -- 825
	) -- 825
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 825
	local sections = {__TS__SparseArraySpread(____array_24)} -- 818
	updateLatestStepLLMDebugOutput( -- 829
		shared, -- 829
		stepId, -- 829
		table.concat(sections, "\n") -- 829
	) -- 829
end -- 816
local function summarizeEditTextParamForHistory(value, key) -- 956
	if type(value) ~= "string" then -- 956
		return nil -- 957
	end -- 957
	local text = value -- 958
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 959
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 960
end -- 956
local function sanitizeActionParamsForHistory(tool, params) -- 1095
	if tool ~= "edit_file" then -- 1095
		return params -- 1096
	end -- 1096
	local clone = {} -- 1097
	for key in pairs(params) do -- 1098
		if key == "old_str" then -- 1098
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1100
		elseif key == "new_str" then -- 1100
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1102
		else -- 1102
			clone[key] = params[key] -- 1104
		end -- 1104
	end -- 1104
	return clone -- 1107
end -- 1095
local function projectMessagesForCompression(messages) -- 1260
	local projected = projectMessagesForLLMContext(messages) -- 1261
	do -- 1261
		local i = 0 -- 1262
		while i < #projected do -- 1262
			do -- 1262
				local message = projected[i + 1] -- 1263
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1263
					goto __continue189 -- 1264
				end -- 1264
				local changed = false -- 1265
				local toolCalls = __TS__ArrayMap( -- 1266
					message.tool_calls, -- 1266
					function(____, toolCall) -- 1266
						local fn = toolCall["function"] -- 1267
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1267
							return toolCall -- 1268
						end -- 1268
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 1269
						if not isRecord(decoded) or isArray(decoded) then -- 1269
							return toolCall -- 1270
						end -- 1270
						changed = true -- 1271
						return __TS__ObjectAssign( -- 1272
							{}, -- 1272
							toolCall, -- 1273
							{["function"] = __TS__ObjectAssign( -- 1272
								{}, -- 1274
								fn, -- 1275
								{arguments = toJson( -- 1274
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1276
									false -- 1276
								)} -- 1276
							)} -- 1276
						) -- 1276
					end -- 1266
				) -- 1266
				if changed then -- 1266
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1280
				end -- 1280
			end -- 1280
			::__continue189:: -- 1280
			i = i + 1 -- 1262
		end -- 1262
	end -- 1262
	return projected -- 1282
end -- 1260
local function getDecisionToolSchemaText(shared) -- 1324
	local toolsText = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1325
		shared.role, -- 1325
		AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 1325
		{ -- 1325
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1326
			workMode = shared.workMode -- 1327
		} -- 1327
	)) -- 1327
	return toolsText or "" -- 1329
end -- 1324
local function clearPreExecutedResults(shared) -- 1339
	shared.preExecutedResults = nil -- 1340
end -- 1339
local function startPreExecutedToolAction(shared, action) -- 1343
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1343
		local ____hasReturned, ____returnValue -- 1343
		local ____try = __TS__AsyncAwaiter(function() -- 1343
			____hasReturned = true -- 1345
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1345
			return -- 1345
		end) -- 1345
		____try = ____try.catch( -- 1345
			____try, -- 1345
			function(____, err) -- 1345
				return __TS__AsyncAwaiter(function() -- 1345
					local message = tostring(err) -- 1347
					AgentUtils.Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1348
					____hasReturned = true -- 1349
					____returnValue = {success = false, message = message} -- 1349
					return -- 1349
				end) -- 1349
			end -- 1349
		) -- 1349
		__TS__Await(____try) -- 1344
		if ____hasReturned then -- 1344
			return ____awaiter_resolve(nil, ____returnValue) -- 1344
		end -- 1344
	end) -- 1344
end -- 1343
local function createPreExecutedToolResult(shared, action) -- 1353
	local cloneParamValue -- 1354
	cloneParamValue = function(value) -- 1354
		if value == nil then -- 1354
			return value -- 1355
		end -- 1355
		if isArray(value) then -- 1355
			return __TS__ArrayMap( -- 1357
				value, -- 1357
				function(____, item) return cloneParamValue(item) end -- 1357
			) -- 1357
		end -- 1357
		if type(value) == "table" then -- 1357
			local clone = {} -- 1360
			for key in pairs(value) do -- 1361
				clone[key] = cloneParamValue(value[key]) -- 1362
			end -- 1362
			return clone -- 1364
		end -- 1364
		return value -- 1366
	end -- 1354
	local params = cloneParamValue(action.params) -- 1368
	local areParamValuesEqual -- 1369
	areParamValuesEqual = function(left, right) -- 1369
		if left == right then -- 1369
			return true -- 1370
		end -- 1370
		if left == nil or right == nil then -- 1370
			return false -- 1371
		end -- 1371
		if isArray(left) or isArray(right) then -- 1371
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1371
				return false -- 1373
			end -- 1373
			do -- 1373
				local i = 0 -- 1374
				while i < #left do -- 1374
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1374
						return false -- 1375
					end -- 1375
					i = i + 1 -- 1374
				end -- 1374
			end -- 1374
			return true -- 1377
		end -- 1377
		if type(left) == "table" and type(right) == "table" then -- 1377
			local leftCount = 0 -- 1380
			for key in pairs(left) do -- 1381
				leftCount = leftCount + 1 -- 1382
				if not areParamValuesEqual(left[key], right[key]) then -- 1382
					return false -- 1387
				end -- 1387
			end -- 1387
			local rightCount = 0 -- 1390
			for key in pairs(right) do -- 1391
				rightCount = rightCount + 1 -- 1392
			end -- 1392
			return leftCount == rightCount -- 1394
		end -- 1394
		return false -- 1396
	end -- 1369
	return { -- 1398
		action = action, -- 1399
		matches = function(self, nextAction) -- 1400
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1401
		end, -- 1400
		promise = startPreExecutedToolAction(shared, action) -- 1403
	} -- 1403
end -- 1353
local function executeToolActionWithPreExecution(shared, action) -- 1407
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1407
		local wasResumeNarrowReadMode = shared.resumeNarrowReadMode == true -- 1408
		local ____opt_29 = shared.preExecutedResults -- 1408
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1409
		local result -- 1410
		if preResult then -- 1410
			local ____opt_31 = shared.preExecutedResults -- 1410
			if ____opt_31 ~= nil then -- 1410
				____opt_31:delete(action.toolCallId) -- 1412
			end -- 1412
			if preResult:matches(action) then -- 1412
				AgentUtils.Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1414
				result = __TS__Await(preResult.promise) -- 1415
			else -- 1415
				AgentUtils.Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1417
				result = __TS__Await(executeToolAction(shared, action)) -- 1418
			end -- 1418
		else -- 1418
			result = __TS__Await(executeToolAction(shared, action)) -- 1421
		end -- 1421
		local guidance = {} -- 1423
		if type(result.guidance) == "string" and __TS__StringTrim(result.guidance) ~= "" then -- 1423
			guidance[#guidance + 1] = result.guidance -- 1425
		end -- 1425
		guidance[#guidance + 1] = AgentToolRegistry.buildCurrentToolAvailabilityGuidance() -- 1427
		if shared.hasSpawnedSubAgentThisTask == true and (shared.delegatedForegroundBatches or 0) + 1 >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1427
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1434
		end -- 1434
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1434
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1437
		end -- 1437
		if shared.failedTestNeedsBuild == true then -- 1437
			if action.tool == "build" and result.success == true and shared.failedTestHasSourceEdit ~= true then -- 1437
				guidance[#guidance + 1] = "The build passed, but no authored source change has addressed the deterministic test failure. Make a narrow source fix before rebuilding or retesting." -- 1441
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1441
				guidance[#guidance + 1] = "Source changed after a deterministic test failure. Build the authored changes before running more tests." -- 1447
			elseif action.tool ~= "build" then -- 1447
				guidance[#guidance + 1] = "A deterministic test failure remains unresolved. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1449
			end -- 1449
		end -- 1449
		if action.tool == "search_dora_doc" then -- 1449
			if shared.unbuiltEdits == true then -- 1449
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1454
			end -- 1454
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1454
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1457
			end -- 1457
		end -- 1457
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1457
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1465
		end -- 1465
		if action.tool == "edit_file" and wasResumeNarrowReadMode then -- 1465
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1468
			if oldStr == "" then -- 1468
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1470
			end -- 1470
		end -- 1470
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1470
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1474
		end -- 1474
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1474
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1477
		end -- 1477
		if shared.buildRepairPending == true then -- 1477
			if action.tool == "build" then -- 1477
				guidance[#guidance + 1] = "This build reported authored-file diagnostics. Make a narrow source repair before building again." -- 1483
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1483
				guidance[#guidance + 1] = "A source repair was applied after build diagnostics. Build again before broadening the investigation." -- 1489
			else -- 1489
				guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1491
			end -- 1491
		end -- 1491
		if action.tool == "build" and shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true and shared.failedTestNeedsBuild ~= true then -- 1491
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1500
		end -- 1500
		result.guidance = table.concat(guidance, "\n") -- 1502
		if action.tool ~= "build" and action.tool ~= "read_file" then -- 1502
			shared.resumeNarrowReadMode = false -- 1507
		end -- 1507
		return ____awaiter_resolve(nil, result) -- 1507
	end) -- 1507
end -- 1407
local function maybeCompressHistory(shared, includePendingUserPrompt, pendingUserPrompt) -- 1512
	if includePendingUserPrompt == nil then -- 1512
		includePendingUserPrompt = false -- 1514
	end -- 1514
	if pendingUserPrompt == nil then -- 1514
		pendingUserPrompt = "" -- 1515
	end -- 1515
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1515
		local ____shared_33 = shared -- 1517
		local memory = ____shared_33.memory -- 1517
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1518
		local changed = false -- 1519
		do -- 1519
			local round = 0 -- 1520
			while round < maxRounds do -- 1520
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1521
				local normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1522
				local decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages) -- 1523
				local activeMessages = projectMessagesForCompression(normalizedActiveMessages) -- 1524
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1527
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1535
				local triggerMessages = buildDecisionMessages( -- 1538
					shared, -- 1539
					nil, -- 1540
					1, -- 1541
					nil, -- 1542
					shared.decisionMode, -- 1543
					false, -- 1544
					includePendingUserPrompt and pendingUserPrompt or "" -- 1545
				) -- 1545
				local triggerOptions = shared.decisionMode == "tool_calling" and __TS__ObjectAssign( -- 1547
					{}, -- 1548
					shared.llmOptions, -- 1549
					__TS__StringIncludes( -- 1550
						string.lower(shared.llmConfig.model), -- 1550
						"glm-5.2" -- 1550
					) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") and ({reasoning_effort = "minimal"}) or ({}), -- 1550
					{tools = AgentToolRegistry.buildDecisionToolSchema( -- 1548
						shared.role, -- 1555
						AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 1555
						{ -- 1555
							disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1556
							workMode = shared.workMode -- 1557
						} -- 1557
					)} -- 1557
				) or shared.llmOptions -- 1557
				local fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig) -- 1561
				local thresholdReached = getActiveRealMessageCount(shared) > 0 and fitted.originalTokens >= fitted.budgetTokens -- 1564
				if not thresholdReached then -- 1564
					if changed then -- 1564
						persistHistoryState(shared) -- 1568
					end -- 1568
					return ____awaiter_resolve(nil) -- 1568
				end -- 1568
				local compressionRound = round + 1 -- 1572
				AgentUtils.Log( -- 1573
					"Info", -- 1573
					(((("[Memory] Effective input budget reached tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " round=") .. tostring(compressionRound) -- 1573
				) -- 1573
				shared.step = shared.step + 1 -- 1574
				local stepId = shared.step -- 1575
				local pendingMessages = #activeMessages -- 1576
				emitAgentEvent( -- 1577
					shared, -- 1577
					{ -- 1577
						type = "memory_compression_started", -- 1578
						sessionId = shared.sessionId, -- 1579
						taskId = shared.taskId, -- 1580
						step = stepId, -- 1581
						tool = "compress_memory", -- 1582
						reason = getMemoryCompressionStartReason(shared), -- 1583
						params = { -- 1584
							round = compressionRound, -- 1585
							maxRounds = maxRounds, -- 1586
							pendingMessages = pendingMessages, -- 1587
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1588
							uncoveredMessages = #uncoveredMessages, -- 1589
							inputTokens = fitted.originalTokens, -- 1590
							inputBudgetTokens = fitted.budgetTokens -- 1591
						} -- 1591
					} -- 1591
				) -- 1591
				local result = __TS__Await(memory.compressor:compress( -- 1594
					activeMessages, -- 1595
					shared.llmOptions, -- 1596
					shared.llmMaxTry, -- 1597
					shared.decisionMode, -- 1598
					{ -- 1599
						onInput = function(____, phase, messages, options) -- 1600
							saveStepLLMDebugInput( -- 1601
								shared, -- 1601
								stepId, -- 1601
								phase, -- 1601
								messages, -- 1601
								options -- 1601
							) -- 1601
						end, -- 1600
						onOutput = function(____, phase, text, meta) -- 1603
							saveStepLLMDebugOutput( -- 1604
								shared, -- 1604
								stepId, -- 1604
								phase, -- 1604
								text, -- 1604
								meta -- 1604
							) -- 1604
						end, -- 1603
						onUsage = function(____, phase, usage) -- 1606
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1607
						end -- 1606
					}, -- 1606
					"default", -- 1610
					systemPrompt, -- 1611
					toolDefinitions, -- 1612
					decisionActiveMessages -- 1613
				)) -- 1613
				if not (result and result.success and result.compressedCount > 0) then -- 1613
					emitAgentEvent( -- 1616
						shared, -- 1616
						{ -- 1616
							type = "memory_compression_finished", -- 1617
							sessionId = shared.sessionId, -- 1618
							taskId = shared.taskId, -- 1619
							step = stepId, -- 1620
							tool = "compress_memory", -- 1621
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1622
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1626
						} -- 1626
					) -- 1626
					if changed then -- 1626
						persistHistoryState(shared) -- 1634
					end -- 1634
					return ____awaiter_resolve(nil) -- 1634
				end -- 1634
				local effectiveCompressedCount = math.max( -- 1638
					0, -- 1639
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1640
				) -- 1640
				if effectiveCompressedCount <= 0 then -- 1640
					if changed then -- 1640
						persistHistoryState(shared) -- 1644
					end -- 1644
					return ____awaiter_resolve(nil) -- 1644
				end -- 1644
				emitAgentEvent( -- 1648
					shared, -- 1648
					{ -- 1648
						type = "memory_compression_finished", -- 1649
						sessionId = shared.sessionId, -- 1650
						taskId = shared.taskId, -- 1651
						step = stepId, -- 1652
						tool = "compress_memory", -- 1653
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1654
						result = { -- 1655
							success = true, -- 1656
							round = compressionRound, -- 1657
							compressedCount = effectiveCompressedCount, -- 1658
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1659
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1660
						} -- 1660
					} -- 1660
				) -- 1660
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1663
				changed = true -- 1664
				AgentUtils.Log( -- 1665
					"Info", -- 1665
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1665
				) -- 1665
				round = round + 1 -- 1520
			end -- 1520
		end -- 1520
		if changed then -- 1520
			persistHistoryState(shared) -- 1668
		end -- 1668
	end) -- 1668
end -- 1512
local function compactAllHistory(shared) -- 1672
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1672
		local ____shared_40 = shared -- 1673
		local memory = ____shared_40.memory -- 1673
		local rounds = 0 -- 1674
		local totalCompressed = 0 -- 1675
		while getActiveRealMessageCount(shared) > 0 do -- 1675
			if shared.stopToken.stopped then -- 1675
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1678
				return ____awaiter_resolve( -- 1678
					nil, -- 1678
					emitAgentTaskFinishEvent( -- 1679
						shared, -- 1679
						false, -- 1679
						getCancelledReason(shared) -- 1679
					) -- 1679
				) -- 1679
			end -- 1679
			rounds = rounds + 1 -- 1681
			shared.step = shared.step + 1 -- 1682
			local stepId = shared.step -- 1683
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1684
			local pendingMessages = #activeMessages -- 1685
			emitAgentEvent( -- 1686
				shared, -- 1686
				{ -- 1686
					type = "memory_compression_started", -- 1687
					sessionId = shared.sessionId, -- 1688
					taskId = shared.taskId, -- 1689
					step = stepId, -- 1690
					tool = "compress_memory", -- 1691
					reason = getMemoryCompressionStartReason(shared), -- 1692
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1693
				} -- 1693
			) -- 1693
			local result = __TS__Await(memory.compressor:compress( -- 1700
				activeMessages, -- 1701
				shared.llmOptions, -- 1702
				shared.llmMaxTry, -- 1703
				shared.decisionMode, -- 1704
				{ -- 1705
					onInput = function(____, phase, messages, options) -- 1706
						saveStepLLMDebugInput( -- 1707
							shared, -- 1707
							stepId, -- 1707
							phase, -- 1707
							messages, -- 1707
							options -- 1707
						) -- 1707
					end, -- 1706
					onOutput = function(____, phase, text, meta) -- 1709
						saveStepLLMDebugOutput( -- 1710
							shared, -- 1710
							stepId, -- 1710
							phase, -- 1710
							text, -- 1710
							meta -- 1710
						) -- 1710
					end, -- 1709
					onUsage = function(____, phase, usage) -- 1712
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1713
					end -- 1712
				}, -- 1712
				"budget_max" -- 1716
			)) -- 1716
			if not (result and result.success and result.compressedCount > 0) then -- 1716
				emitAgentEvent( -- 1719
					shared, -- 1719
					{ -- 1719
						type = "memory_compression_finished", -- 1720
						sessionId = shared.sessionId, -- 1721
						taskId = shared.taskId, -- 1722
						step = stepId, -- 1723
						tool = "compress_memory", -- 1724
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1725
						result = { -- 1729
							success = false, -- 1730
							rounds = rounds, -- 1731
							error = result and result.error or "compression returned no changes", -- 1732
							compressedCount = result and result.compressedCount or 0, -- 1733
							fullCompaction = true -- 1734
						} -- 1734
					} -- 1734
				) -- 1734
				return ____awaiter_resolve( -- 1734
					nil, -- 1734
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1737
				) -- 1737
			end -- 1737
			local effectiveCompressedCount = math.max( -- 1742
				0, -- 1743
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1744
			) -- 1744
			if effectiveCompressedCount <= 0 then -- 1744
				return ____awaiter_resolve( -- 1744
					nil, -- 1744
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1747
				) -- 1747
			end -- 1747
			emitAgentEvent( -- 1754
				shared, -- 1754
				{ -- 1754
					type = "memory_compression_finished", -- 1755
					sessionId = shared.sessionId, -- 1756
					taskId = shared.taskId, -- 1757
					step = stepId, -- 1758
					tool = "compress_memory", -- 1759
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1760
					result = { -- 1761
						success = true, -- 1762
						round = rounds, -- 1763
						compressedCount = effectiveCompressedCount, -- 1764
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1765
						fullCompaction = true -- 1766
					} -- 1766
				} -- 1766
			) -- 1766
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1769
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1770
			persistHistoryState(shared) -- 1771
			AgentUtils.Log( -- 1772
				"Info", -- 1772
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1772
			) -- 1772
		end -- 1772
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1774
		return ____awaiter_resolve( -- 1774
			nil, -- 1774
			emitAgentTaskFinishEvent( -- 1775
				shared, -- 1776
				true, -- 1777
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1778
			) -- 1778
		) -- 1778
	end) -- 1778
end -- 1672
local function clearSessionHistory(shared) -- 1784
	shared.messages = {} -- 1785
	shared.lastConsolidatedIndex = 0 -- 1786
	shared.carryMessageIndex = nil -- 1787
	persistHistoryState(shared) -- 1788
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1789
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1790
end -- 1784
local function appendConversationMessage(shared, message) -- 1946
	local ____shared_messages_49 = shared.messages -- 1946
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1947
		{}, -- 1947
		message, -- 1948
		{ -- 1947
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1949
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1950
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1951
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1952
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1953
		} -- 1953
	) -- 1953
end -- 1946
local function appendToolResultMessage(shared, action) -- 1962
	appendConversationMessage( -- 1963
		shared, -- 1963
		{ -- 1963
			role = "tool", -- 1964
			tool_call_id = action.toolCallId, -- 1965
			name = action.tool, -- 1966
			content = action.result and toJson(action.result, false) or "" -- 1967
		} -- 1967
	) -- 1967
end -- 1962
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1971
	appendConversationMessage( -- 1977
		shared, -- 1977
		{ -- 1977
			role = "assistant", -- 1978
			content = content or "", -- 1979
			reasoning_content = reasoningContent, -- 1980
			tool_calls = __TS__ArrayMap( -- 1981
				actions, -- 1981
				function(____, action) return { -- 1981
					id = action.toolCallId, -- 1982
					type = "function", -- 1983
					["function"] = { -- 1984
						name = action.tool, -- 1985
						arguments = toJson(action.params, false) -- 1986
					} -- 1986
				} end -- 1986
			) -- 1986
		} -- 1986
	) -- 1986
end -- 1971
local function llm(shared, messages, phase) -- 2170
	if phase == nil then -- 2170
		phase = "decision_xml" -- 2173
	end -- 2173
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2173
		local stepId = shared.step + 1 -- 2175
		emitLLMContextMetrics( -- 2176
			shared, -- 2176
			stepId, -- 2176
			phase, -- 2176
			messages, -- 2176
			shared.llmOptions -- 2176
		) -- 2176
		saveStepLLMDebugInput( -- 2177
			shared, -- 2177
			stepId, -- 2177
			phase, -- 2177
			messages, -- 2177
			shared.llmOptions -- 2177
		) -- 2177
		local lastStreamReasoning = "" -- 2178
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2179
			messages, -- 2180
			shared.llmOptions, -- 2181
			shared.stopToken, -- 2182
			shared.llmConfig, -- 2183
			function(response) -- 2184
				local ____opt_53 = response.choices -- 2184
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2184
				local streamMessage = ____opt_51 and ____opt_51.message -- 2185
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2186
				if nextContent == "" then -- 2186
					return -- 2189
				end -- 2189
				if nextContent == lastStreamReasoning then -- 2189
					return -- 2190
				end -- 2190
				lastStreamReasoning = nextContent -- 2191
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2192
			end -- 2184
		)) -- 2184
		if res.success then -- 2184
			local usage = res.tokenUsage -- 2196
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2197
			local ____opt_59 = res.response.choices -- 2197
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2197
			local message = ____opt_57 and ____opt_57.message -- 2198
			local text = message and message.content -- 2199
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2200
			if text then -- 2200
				local parsed = tryParseAndValidateDecision(text, shared) -- 2204
				if parsed.success then -- 2204
					local reason = parsed.reason or "" -- 2206
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2207
				end -- 2207
				saveStepLLMDebugOutput( -- 2209
					shared, -- 2209
					stepId, -- 2209
					phase, -- 2209
					text, -- 2209
					{success = true, usage = usage} -- 2209
				) -- 2209
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2209
			else -- 2209
				saveStepLLMDebugOutput( -- 2212
					shared, -- 2212
					stepId, -- 2212
					phase, -- 2212
					"empty LLM response", -- 2212
					{success = false, usage = usage} -- 2212
				) -- 2212
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2212
			end -- 2212
		else -- 2212
			local usage = res.tokenUsage -- 2216
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2217
			saveStepLLMDebugOutput( -- 2218
				shared, -- 2218
				stepId, -- 2218
				phase, -- 2218
				res.raw or res.message, -- 2218
				{success = false, usage = usage} -- 2218
			) -- 2218
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2218
		end -- 2218
	end) -- 2218
end -- 2170
local function isDecisionBatchSuccess(result) -- 2242
	return result.kind == "batch" -- 2243
end -- 2242
local function parseDecisionToolCall(functionName, rawObj) -- 2267
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2267
		return {success = false, message = "unknown tool: " .. functionName} -- 2269
	end -- 2269
	if rawObj == nil then -- 2269
		return {success = true, tool = functionName, params = {}} -- 2272
	end -- 2272
	if not isRecord(rawObj) then -- 2272
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2275
	end -- 2275
	return {success = true, tool = functionName, params = rawObj} -- 2277
end -- 2267
local function parseToolCallArguments(functionName, argsText) -- 2284
	local trimmedArgs = __TS__StringTrim(argsText) -- 2285
	if trimmedArgs == "" then -- 2285
		return {} -- 2287
	end -- 2287
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2289
	if err ~= nil or rawObj == nil then -- 2289
		return { -- 2291
			success = false, -- 2292
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2293
			raw = argsText -- 2294
		} -- 2294
	end -- 2294
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2297
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2297
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2299
	end -- 2299
	return rawObj -- 2305
end -- 2284
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2308
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2316
	if isRecord(rawArgs) and rawArgs.success == false then -- 2316
		return rawArgs -- 2318
	end -- 2318
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2320
	if not decision.success then -- 2320
		return {success = false, message = decision.message, raw = argsText} -- 2322
	end -- 2322
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2328
	if not completionValidation.success then -- 2328
		return {success = false, message = completionValidation.message, raw = argsText} -- 2330
	end -- 2330
	local validation = validateDecision(decision.tool, decision.params) -- 2336
	if not validation.success then -- 2336
		return {success = false, message = validation.message, raw = argsText} -- 2338
	end -- 2338
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2344
	if not sharedValidation.success then -- 2344
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2346
	end -- 2346
	decision.params = validation.params -- 2352
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2353
	decision.reason = reason -- 2354
	decision.reasoningContent = reasoningContent -- 2355
	return decision -- 2356
end -- 2308
local function createPreExecutableActionFromStream(shared, toolCall) -- 2359
	local ____opt_65 = toolCall["function"] -- 2359
	local functionName = ____opt_65 and ____opt_65.name -- 2360
	local ____opt_67 = toolCall["function"] -- 2360
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2361
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2362
	if not functionName or not toolCallId then -- 2362
		return nil -- 2363
	end -- 2363
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2364
	if isRecord(rawArgs) and rawArgs.success == false then -- 2364
		return nil -- 2365
	end -- 2365
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2366
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2366
		return nil -- 2367
	end -- 2367
	local validation = validateDecision(decision.tool, decision.params) -- 2368
	if not validation.success then -- 2368
		return nil -- 2369
	end -- 2369
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2369
		return nil -- 2370
	end -- 2370
	return { -- 2371
		step = shared.step + 1, -- 2372
		toolCallId = toolCallId, -- 2373
		tool = decision.tool, -- 2374
		reason = "", -- 2375
		params = validation.params, -- 2376
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2377
	} -- 2377
end -- 2359
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2775
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2784
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2785
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2793
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2794
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2795
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2803
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2811
		shared.role, -- 2811
		{ -- 2811
			includeFinish = true, -- 2812
			includeXmlRules = true, -- 2813
			context = {searchDoraDocLimitMax = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax}, -- 2814
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2815
			workMode = shared.workMode -- 2816
		} -- 2816
	) -- 2816
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2818
	local repairPrompt = replacePromptVars( -- 2821
		shared.promptPack.xmlDecisionRepairPrompt, -- 2821
		{ -- 2821
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2822
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2823
			CANDIDATE_SECTION = candidateSection, -- 2824
			LAST_ERROR = lastError, -- 2825
			ATTEMPT = tostring(attempt) -- 2826
		} -- 2826
	) -- 2826
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2828
end -- 2775
local MainDecisionAgent = __TS__Class() -- 2866
MainDecisionAgent.name = "MainDecisionAgent" -- 2866
__TS__ClassExtends(MainDecisionAgent, Node) -- 2866
function MainDecisionAgent.prototype.prep(self, shared) -- 2867
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2867
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2867
			return ____awaiter_resolve(nil, {shared = shared}) -- 2867
		end -- 2867
		__TS__Await(maybeCompressHistory(shared)) -- 2872
		return ____awaiter_resolve(nil, {shared = shared}) -- 2872
	end) -- 2872
end -- 2867
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2877
	local preExecuted = shared.preExecutedResults -- 2878
	if not preExecuted or preExecuted.size == 0 then -- 2878
		return nil -- 2879
	end -- 2879
	local decisions = {} -- 2880
	preExecuted:forEach(function(____, preResult) -- 2881
		local action = preResult.action -- 2882
		decisions[#decisions + 1] = { -- 2883
			success = true, -- 2884
			tool = action.tool, -- 2885
			params = action.params, -- 2886
			toolCallId = action.toolCallId, -- 2887
			reason = action.reason, -- 2888
			reasoningContent = action.reasoningContent -- 2889
		} -- 2889
	end) -- 2881
	if #decisions == 0 then -- 2881
		return nil -- 2892
	end -- 2892
	AgentUtils.Log( -- 2893
		"Warn", -- 2893
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2893
			__TS__ArrayMap( -- 2893
				decisions, -- 2893
				function(____, decision) return decision.tool end -- 2893
			), -- 2893
			"," -- 2893
		) -- 2893
	) -- 2893
	if #decisions == 1 then -- 2893
		return decisions[1] -- 2895
	end -- 2895
	return {success = true, kind = "batch", decisions = decisions} -- 2897
end -- 2877
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2904
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2909
	if not recovery then -- 2909
		return nil -- 2910
	end -- 2910
	shared.truncatedToolOverwritePath = recovery.target -- 2911
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2912
	return { -- 2913
		success = true, -- 2914
		tool = "edit_file", -- 2915
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2916
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2922
		reason = recovery.reason, -- 2923
		reasoningContent = reasoningContent -- 2924
	} -- 2924
end -- 2904
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2928
	if attempt == nil then -- 2928
		attempt = 1 -- 2931
	end -- 2931
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2931
		if shared.stopToken.stopped then -- 2931
			return ____awaiter_resolve( -- 2931
				nil, -- 2931
				{ -- 2935
					success = false, -- 2935
					message = getCancelledReason(shared) -- 2935
				} -- 2935
			) -- 2935
		end -- 2935
		AgentUtils.Log( -- 2937
			"Info", -- 2937
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2937
		) -- 2937
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2938
			shared.role, -- 2938
			AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 2938
			{ -- 2938
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2939
				workMode = shared.workMode -- 2940
			} -- 2940
		) -- 2940
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2942
		local stepId = shared.step + 1 -- 2943
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2944
			string.lower(shared.llmConfig.model), -- 2944
			"glm-5.2" -- 2944
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2944
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2947
		emitLLMContextMetrics( -- 2952
			shared, -- 2952
			stepId, -- 2952
			"decision_tool_calling", -- 2952
			messages, -- 2952
			llmOptions -- 2952
		) -- 2952
		saveStepLLMDebugInput( -- 2953
			shared, -- 2953
			stepId, -- 2953
			"decision_tool_calling", -- 2953
			messages, -- 2953
			llmOptions -- 2953
		) -- 2953
		local lastStreamContent = "" -- 2954
		local lastStreamReasoning = "" -- 2955
		local preExecutedResults = __TS__New(Map) -- 2956
		shared.preExecutedResults = preExecutedResults -- 2957
		local remainingWorkSteps = getRemainingAgentWorkSteps(shared.agentStepCount, shared.maxSteps) -- 2958
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2959
			messages, -- 2960
			llmOptions, -- 2961
			shared.stopToken, -- 2962
			shared.llmConfig, -- 2963
			function(response) -- 2964
				local ____opt_75 = response.choices -- 2964
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2964
				local streamMessage = ____opt_73 and ____opt_73.message -- 2965
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2966
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2969
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2969
					return -- 2973
				end -- 2973
				lastStreamContent = nextContent -- 2975
				lastStreamReasoning = nextReasoning -- 2976
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2977
			end, -- 2964
			function(tc) -- 2979
				if shared.stopToken.stopped then -- 2979
					return -- 2980
				end -- 2980
				if preExecutedResults.size >= remainingWorkSteps then -- 2980
					return -- 2981
				end -- 2981
				local action = createPreExecutableActionFromStream(shared, tc) -- 2982
				if not action or preExecutedResults:has(action.toolCallId) then -- 2982
					return -- 2983
				end -- 2983
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2984
				preExecutedResults:set( -- 2985
					action.toolCallId, -- 2985
					createPreExecutedToolResult(shared, action) -- 2985
				) -- 2985
			end -- 2979
		)) -- 2979
		if shared.stopToken.stopped then -- 2979
			clearPreExecutedResults(shared) -- 2989
			return ____awaiter_resolve( -- 2989
				nil, -- 2989
				{ -- 2990
					success = false, -- 2990
					message = getCancelledReason(shared) -- 2990
				} -- 2990
			) -- 2990
		end -- 2990
		if not res.success then -- 2990
			local usage = res.tokenUsage -- 2993
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2994
			saveStepLLMDebugOutput( -- 2995
				shared, -- 2995
				stepId, -- 2995
				"decision_tool_calling", -- 2995
				res.raw or res.message, -- 2995
				{success = false, usage = usage} -- 2995
			) -- 2995
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2996
			local committed = self:commitPreExecutedDecision(shared) -- 2997
			if committed then -- 2997
				return ____awaiter_resolve(nil, committed) -- 2997
			end -- 2997
			local ____opt_83 = res.response -- 2997
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2997
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2999
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 3000
			local ____shared_93 = shared -- 3001
			local ____opt_85 = partialChoice and partialChoice.message -- 3001
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 3002
			local ____opt_89 = partialChoice and partialChoice.message -- 3002
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 3000
			if partialDraft then -- 3000
				return ____awaiter_resolve(nil, partialDraft) -- 3000
			end -- 3000
			clearPreExecutedResults(shared) -- 3006
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 3006
		end -- 3006
		local usage = res.tokenUsage -- 3009
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3010
		saveStepLLMDebugOutput( -- 3011
			shared, -- 3011
			stepId, -- 3011
			"decision_tool_calling", -- 3011
			encodeDebugJSON(res.response), -- 3011
			{success = true, usage = usage} -- 3011
		) -- 3011
		local choice = res.response.choices and res.response.choices[1] -- 3012
		local message = choice and choice.message -- 3013
		local toolCalls = message and message.tool_calls -- 3014
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3015
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3018
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3021
		AgentUtils.Log( -- 3024
			"Info", -- 3024
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3024
		) -- 3024
		if finishReason == "length" then -- 3024
			local committed = self:commitPreExecutedDecision(shared) -- 3026
			if committed then -- 3026
				return ____awaiter_resolve(nil, committed) -- 3026
			end -- 3026
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3028
			if partialDraft then -- 3028
				return ____awaiter_resolve(nil, partialDraft) -- 3028
			end -- 3028
			AgentUtils.Log( -- 3030
				"Error", -- 3030
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3030
			) -- 3030
			clearPreExecutedResults(shared) -- 3031
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3031
		end -- 3031
		if not toolCalls or #toolCalls == 0 then -- 3031
			if messageContent and messageContent ~= "" then -- 3031
				if isFinalDecisionTurn(shared) then -- 3031
					clearPreExecutedResults(shared) -- 3041
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3041
				end -- 3041
				if shared.role == "sub" then -- 3041
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3049
					clearPreExecutedResults(shared) -- 3050
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3050
				end -- 3050
				AgentUtils.Log( -- 3057
					"Info", -- 3057
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3057
				) -- 3057
				clearPreExecutedResults(shared) -- 3058
				return ____awaiter_resolve(nil, { -- 3058
					success = true, -- 3060
					tool = "finish", -- 3061
					params = {}, -- 3062
					reason = messageContent, -- 3063
					reasoningContent = reasoningContent, -- 3064
					directSummary = messageContent -- 3065
				}) -- 3065
			end -- 3065
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3068
			clearPreExecutedResults(shared) -- 3069
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3069
		end -- 3069
		if #toolCalls > 1 and #toolCalls > remainingWorkSteps then -- 3069
			AgentUtils.Log( -- 3077
				"Warn", -- 3077
				(("[CodingAgent] parallel tool batch exceeds remaining step budget calls=" .. tostring(#toolCalls)) .. " remaining=") .. tostring(remainingWorkSteps) -- 3077
			) -- 3077
			local committed = self:commitPreExecutedDecision(shared) -- 3078
			if committed then -- 3078
				return ____awaiter_resolve(nil, committed) -- 3078
			end -- 3078
			clearPreExecutedResults(shared) -- 3080
			return ____awaiter_resolve( -- 3080
				nil, -- 3080
				{ -- 3081
					success = false, -- 3082
					message = ("parallel tool call batch exceeds the remaining task step budget (" .. tostring(remainingWorkSteps)) .. ")", -- 3083
					raw = messageContent -- 3084
				} -- 3084
			) -- 3084
		end -- 3084
		local decisions = {} -- 3087
		do -- 3087
			local i = 0 -- 3088
			while i < #toolCalls do -- 3088
				local toolCall = toolCalls[i + 1] -- 3089
				local fn = toolCall ~= nil and toolCall["function"] -- 3090
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3090
					AgentUtils.Log( -- 3092
						"Error", -- 3092
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3092
					) -- 3092
					clearPreExecutedResults(shared) -- 3093
					return ____awaiter_resolve( -- 3093
						nil, -- 3093
						{ -- 3094
							success = false, -- 3095
							message = "missing function name for tool call " .. tostring(i + 1), -- 3096
							raw = messageContent -- 3097
						} -- 3097
					) -- 3097
				end -- 3097
				local functionName = fn.name -- 3100
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3101
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3102
				AgentUtils.Log( -- 3105
					"Info", -- 3105
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3105
				) -- 3105
				local decision = parseAndValidateToolCallDecision( -- 3106
					shared, -- 3107
					functionName, -- 3108
					argsText, -- 3109
					toolCallId, -- 3110
					messageContent, -- 3111
					reasoningContent -- 3112
				) -- 3112
				if not decision.success then -- 3112
					AgentUtils.Log( -- 3115
						"Error", -- 3115
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3115
					) -- 3115
					clearPreExecutedResults(shared) -- 3116
					return ____awaiter_resolve(nil, decision) -- 3116
				end -- 3116
				decisions[#decisions + 1] = decision -- 3119
				i = i + 1 -- 3088
			end -- 3088
		end -- 3088
		if #decisions == 1 then -- 3088
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3122
			return ____awaiter_resolve(nil, decisions[1]) -- 3122
		end -- 3122
		do -- 3122
			local i = 0 -- 3125
			while i < #decisions do -- 3125
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3125
					clearPreExecutedResults(shared) -- 3127
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3127
				end -- 3127
				i = i + 1 -- 3125
			end -- 3125
		end -- 3125
		AgentUtils.Log( -- 3135
			"Info", -- 3135
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3135
				__TS__ArrayMap( -- 3135
					decisions, -- 3135
					function(____, decision) return decision.tool end -- 3135
				), -- 3135
				"," -- 3135
			) -- 3135
		) -- 3135
		return ____awaiter_resolve(nil, { -- 3135
			success = true, -- 3137
			kind = "batch", -- 3138
			decisions = decisions, -- 3139
			content = messageContent, -- 3140
			reasoningContent = reasoningContent -- 3141
		}) -- 3141
	end) -- 3141
end -- 2928
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3145
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3145
		AgentUtils.Log( -- 3151
			"Info", -- 3151
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3151
		) -- 3151
		local lastError = initialError -- 3152
		local candidateRaw = "" -- 3153
		local candidateReasoning = nil -- 3154
		do -- 3154
			local attempt = 0 -- 3155
			while attempt < shared.llmMaxTry do -- 3155
				do -- 3155
					AgentUtils.Log( -- 3156
						"Info", -- 3156
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3156
					) -- 3156
					local messages = buildXmlRepairMessages( -- 3157
						shared, -- 3158
						originalRaw, -- 3159
						originalReasoning, -- 3160
						candidateRaw, -- 3161
						candidateReasoning, -- 3162
						lastError, -- 3163
						attempt + 1 -- 3164
					) -- 3164
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3166
					if shared.stopToken.stopped then -- 3166
						return ____awaiter_resolve( -- 3166
							nil, -- 3166
							{ -- 3168
								success = false, -- 3168
								message = getCancelledReason(shared) -- 3168
							} -- 3168
						) -- 3168
					end -- 3168
					if not llmRes.success then -- 3168
						lastError = llmRes.message -- 3171
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3172
						goto __continue534 -- 3173
					end -- 3173
					candidateRaw = llmRes.text -- 3175
					candidateReasoning = llmRes.reasoningContent -- 3176
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3177
					if decision.success then -- 3177
						decision.reasoningContent = llmRes.reasoningContent -- 3179
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3180
						return ____awaiter_resolve(nil, decision) -- 3180
					end -- 3180
					lastError = decision.message -- 3183
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3184
				end -- 3184
				::__continue534:: -- 3184
				attempt = attempt + 1 -- 3155
			end -- 3155
		end -- 3155
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3186
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3186
	end) -- 3186
end -- 3145
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3194
	if attempt == nil then -- 3194
		attempt = 1 -- 3197
	end -- 3197
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3197
		local messages = buildDecisionMessages( -- 3200
			shared, -- 3201
			lastError, -- 3202
			attempt, -- 3203
			lastRaw, -- 3204
			"xml" -- 3205
		) -- 3205
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3207
		if shared.stopToken.stopped then -- 3207
			return ____awaiter_resolve( -- 3207
				nil, -- 3207
				{ -- 3209
					success = false, -- 3209
					message = getCancelledReason(shared) -- 3209
				} -- 3209
			) -- 3209
		end -- 3209
		if not llmRes.success then -- 3209
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3209
		end -- 3209
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3218
		if decision.success then -- 3218
			decision.reasoningContent = llmRes.reasoningContent -- 3220
			return ____awaiter_resolve(nil, decision) -- 3220
		end -- 3220
		return ____awaiter_resolve( -- 3220
			nil, -- 3220
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3223
		) -- 3223
	end) -- 3223
end -- 3194
function MainDecisionAgent.prototype.exec(self, input) -- 3226
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3226
		local shared = input.shared -- 3227
		if shared.stopToken.stopped then -- 3227
			return ____awaiter_resolve( -- 3227
				nil, -- 3227
				{ -- 3229
					success = false, -- 3229
					message = getCancelledReason(shared) -- 3229
				} -- 3229
			) -- 3229
		end -- 3229
		if shared.agentStepCount >= shared.maxSteps then -- 3229
			AgentUtils.Log( -- 3232
				"Warn", -- 3232
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3232
			) -- 3232
			return ____awaiter_resolve( -- 3232
				nil, -- 3232
				{ -- 3233
					success = false, -- 3233
					message = getMaxStepsReachedReason(shared) -- 3233
				} -- 3233
			) -- 3233
		end -- 3233
		if shared.decisionMode == "tool_calling" then -- 3233
			AgentUtils.Log( -- 3237
				"Info", -- 3237
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3237
			) -- 3237
			local lastError = "tool calling validation failed" -- 3238
			local lastRaw = "" -- 3239
			local shouldFallbackToXml = false -- 3240
			do -- 3240
				local attempt = 0 -- 3241
				while attempt < shared.llmMaxTry do -- 3241
					AgentUtils.Log( -- 3242
						"Info", -- 3242
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3242
					) -- 3242
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3243
					if shared.stopToken.stopped then -- 3243
						return ____awaiter_resolve( -- 3243
							nil, -- 3243
							{ -- 3250
								success = false, -- 3250
								message = getCancelledReason(shared) -- 3250
							} -- 3250
						) -- 3250
					end -- 3250
					if decision.success then -- 3250
						return ____awaiter_resolve(nil, decision) -- 3250
					end -- 3250
					lastError = decision.message -- 3255
					lastRaw = decision.raw or "" -- 3256
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3257
					if lastError == "missing tool call" then -- 3257
						shouldFallbackToXml = true -- 3259
						break -- 3260
					end -- 3260
					attempt = attempt + 1 -- 3241
				end -- 3241
			end -- 3241
			if shouldFallbackToXml then -- 3241
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3264
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3265
				do -- 3265
					local attempt = 0 -- 3266
					while attempt < shared.llmMaxTry do -- 3266
						AgentUtils.Log( -- 3267
							"Info", -- 3267
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3267
						) -- 3267
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3268
						if shared.stopToken.stopped then -- 3268
							return ____awaiter_resolve( -- 3268
								nil, -- 3268
								{ -- 3275
									success = false, -- 3275
									message = getCancelledReason(shared) -- 3275
								} -- 3275
							) -- 3275
						end -- 3275
						if decision.success then -- 3275
							return ____awaiter_resolve(nil, decision) -- 3275
						end -- 3275
						lastError = decision.message -- 3280
						lastRaw = decision.raw or "" -- 3281
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3282
						attempt = attempt + 1 -- 3266
					end -- 3266
				end -- 3266
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3284
				return ____awaiter_resolve( -- 3284
					nil, -- 3284
					{ -- 3285
						success = false, -- 3285
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3285
					} -- 3285
				) -- 3285
			end -- 3285
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3287
			return ____awaiter_resolve( -- 3287
				nil, -- 3287
				{ -- 3288
					success = false, -- 3288
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3288
				} -- 3288
			) -- 3288
		end -- 3288
		local lastError = "xml validation failed" -- 3291
		local lastRaw = "" -- 3292
		do -- 3292
			local attempt = 0 -- 3293
			while attempt < shared.llmMaxTry do -- 3293
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3294
				if shared.stopToken.stopped then -- 3294
					return ____awaiter_resolve( -- 3294
						nil, -- 3294
						{ -- 3303
							success = false, -- 3303
							message = getCancelledReason(shared) -- 3303
						} -- 3303
					) -- 3303
				end -- 3303
				if decision.success then -- 3303
					return ____awaiter_resolve(nil, decision) -- 3303
				end -- 3303
				lastError = decision.message -- 3308
				lastRaw = decision.raw or "" -- 3309
				attempt = attempt + 1 -- 3293
			end -- 3293
		end -- 3293
		return ____awaiter_resolve( -- 3293
			nil, -- 3293
			{ -- 3311
				success = false, -- 3311
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3311
			} -- 3311
		) -- 3311
	end) -- 3311
end -- 3226
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3314
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3314
		local result = execRes -- 3315
		if not result.success then -- 3315
			if shared.stopToken.stopped then -- 3315
				shared.error = getCancelledReason(shared) -- 3318
				shared.done = true -- 3319
				return ____awaiter_resolve(nil, "done") -- 3319
			end -- 3319
			shared.error = result.message -- 3322
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3323
			shared.done = true -- 3324
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3325
			persistHistoryState(shared) -- 3329
			return ____awaiter_resolve(nil, "done") -- 3329
		end -- 3329
		if isDecisionBatchSuccess(result) then -- 3329
			local startStep = shared.step -- 3333
			local actions = {} -- 3334
			do -- 3334
				local i = 0 -- 3335
				while i < #result.decisions do -- 3335
					local decision = result.decisions[i + 1] -- 3336
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3337
					local step = startStep + i + 1 -- 3338
					local ____temp_96 -- 3339
					if i == 0 then -- 3339
						____temp_96 = decision.reason -- 3339
					else -- 3339
						____temp_96 = "" -- 3339
					end -- 3339
					local actionReason = ____temp_96 -- 3339
					local ____temp_97 -- 3340
					if i == 0 then -- 3340
						____temp_97 = decision.reasoningContent -- 3340
					else -- 3340
						____temp_97 = nil -- 3340
					end -- 3340
					local actionReasoningContent = ____temp_97 -- 3340
					emitAgentEvent(shared, { -- 3341
						type = "decision_made", -- 3342
						sessionId = shared.sessionId, -- 3343
						taskId = shared.taskId, -- 3344
						step = step, -- 3345
						tool = decision.tool, -- 3346
						reason = actionReason, -- 3347
						reasoningContent = actionReasoningContent, -- 3348
						params = decision.params -- 3349
					}) -- 3349
					local action = { -- 3351
						step = step, -- 3352
						toolCallId = toolCallId, -- 3353
						tool = decision.tool, -- 3354
						reason = actionReason or "", -- 3355
						reasoningContent = actionReasoningContent, -- 3356
						params = decision.params, -- 3357
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3358
					} -- 3358
					local ____shared_history_98 = shared.history -- 3358
					____shared_history_98[#____shared_history_98 + 1] = action -- 3360
					actions[#actions + 1] = action -- 3361
					i = i + 1 -- 3335
				end -- 3335
			end -- 3335
			shared.step = startStep + #actions -- 3363
			shared.agentStepCount = shared.agentStepCount + #actions -- 3364
			shared.pendingToolActions = actions -- 3365
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3366
			persistHistoryState(shared) -- 3372
			return ____awaiter_resolve(nil, "batch_tools") -- 3372
		end -- 3372
		if result.directSummary and result.directSummary ~= "" then -- 3372
			shared.response = result.directSummary -- 3376
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3377
			shared.done = true -- 3381
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3382
			persistHistoryState(shared) -- 3387
			return ____awaiter_resolve(nil, "done") -- 3387
		end -- 3387
		if result.tool == "finish" then -- 3387
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3391
			shared.response = finalMessage -- 3392
			shared.completion = getCompletionReport(result.params) -- 3393
			shared.done = true -- 3394
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3395
			persistHistoryState(shared) -- 3400
			return ____awaiter_resolve(nil, "done") -- 3400
		end -- 3400
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3403
		shared.step = shared.step + 1 -- 3404
		shared.agentStepCount = shared.agentStepCount + 1 -- 3405
		local step = shared.step -- 3406
		emitAgentEvent(shared, { -- 3407
			type = "decision_made", -- 3408
			sessionId = shared.sessionId, -- 3409
			taskId = shared.taskId, -- 3410
			step = step, -- 3411
			tool = result.tool, -- 3412
			reason = result.reason, -- 3413
			reasoningContent = result.reasoningContent, -- 3414
			params = result.params -- 3415
		}) -- 3415
		local ____shared_history_99 = shared.history -- 3415
		____shared_history_99[#____shared_history_99 + 1] = { -- 3417
			step = step, -- 3418
			toolCallId = toolCallId, -- 3419
			tool = result.tool, -- 3420
			reason = result.reason or "", -- 3421
			reasoningContent = result.reasoningContent, -- 3422
			params = result.params, -- 3423
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3424
		} -- 3424
		local action = shared.history[#shared.history] -- 3426
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3427
		shared.pendingToolActions = {action} -- 3430
		persistHistoryState(shared) -- 3431
		return ____awaiter_resolve(nil, "batch_tools") -- 3431
	end) -- 3431
end -- 3314
local ReadFileAction = __TS__Class() -- 3436
ReadFileAction.name = "ReadFileAction" -- 3436
__TS__ClassExtends(ReadFileAction, Node) -- 3436
function ReadFileAction.prototype.prep(self, shared) -- 3437
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3437
		local last = shared.history[#shared.history] -- 3438
		if not last then -- 3438
			error( -- 3439
				__TS__New(Error, "no history"), -- 3439
				0 -- 3439
			) -- 3439
		end -- 3439
		emitAgentStartEvent(shared, last) -- 3440
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3441
		if __TS__StringTrim(path) == "" then -- 3441
			error( -- 3444
				__TS__New(Error, "missing path"), -- 3444
				0 -- 3444
			) -- 3444
		end -- 3444
		local ____path_102 = path -- 3446
		local ____shared_workingDir_103 = shared.workingDir -- 3448
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3449
		local ____last_params_startLine_100 = last.params.startLine -- 3450
		if ____last_params_startLine_100 == nil then -- 3450
			____last_params_startLine_100 = 1 -- 3450
		end -- 3450
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3450
		local ____last_params_endLine_101 = last.params.endLine -- 3451
		if ____last_params_endLine_101 == nil then -- 3451
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3451
		end -- 3451
		return ____awaiter_resolve( -- 3451
			nil, -- 3451
			{ -- 3445
				path = ____path_102, -- 3446
				tool = "read_file", -- 3447
				workDir = ____shared_workingDir_103, -- 3448
				docLanguage = ____temp_104, -- 3449
				startLine = ____TS__Number_result_105, -- 3450
				endLine = __TS__Number(____last_params_endLine_101) -- 3451
			} -- 3451
		) -- 3451
	end) -- 3451
end -- 3437
function ReadFileAction.prototype.exec(self, input) -- 3455
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3455
		return ____awaiter_resolve( -- 3455
			nil, -- 3455
			Tools.readFile( -- 3456
				input.workDir, -- 3457
				input.path, -- 3458
				__TS__Number(input.startLine or 1), -- 3459
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3460
				input.docLanguage -- 3461
			) -- 3461
		) -- 3461
	end) -- 3461
end -- 3455
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3465
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3465
		local result = execRes -- 3466
		local last = shared.history[#shared.history] -- 3467
		if last ~= nil then -- 3467
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3469
			appendToolResultMessage(shared, last) -- 3470
			emitAgentFinishEvent(shared, last) -- 3471
		end -- 3471
		persistHistoryState(shared) -- 3473
		__TS__Await(maybeCompressHistory(shared)) -- 3474
		persistHistoryState(shared) -- 3475
		return ____awaiter_resolve(nil, "main") -- 3475
	end) -- 3475
end -- 3465
local SearchFilesAction = __TS__Class() -- 3480
SearchFilesAction.name = "SearchFilesAction" -- 3480
__TS__ClassExtends(SearchFilesAction, Node) -- 3480
function SearchFilesAction.prototype.prep(self, shared) -- 3481
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3481
		local last = shared.history[#shared.history] -- 3482
		if not last then -- 3482
			error( -- 3483
				__TS__New(Error, "no history"), -- 3483
				0 -- 3483
			) -- 3483
		end -- 3483
		emitAgentStartEvent(shared, last) -- 3484
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3484
	end) -- 3484
end -- 3481
function SearchFilesAction.prototype.exec(self, input) -- 3488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3488
		local params = input.params -- 3489
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3490
		local ____input_workDir_112 = input.workDir -- 3491
		local ____temp_113 = params.path or "" -- 3492
		local ____temp_114 = params.pattern or "" -- 3493
		local ____params_globs_115 = params.globs -- 3494
		local ____params_useRegex_116 = params.useRegex -- 3495
		local ____params_caseSensitive_117 = params.caseSensitive -- 3496
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3498
		local ____math_max_108 = math.max -- 3499
		local ____math_floor_107 = math.floor -- 3499
		local ____params_limit_106 = params.limit -- 3499
		if ____params_limit_106 == nil then -- 3499
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3499
		end -- 3499
		local ____math_max_108_result_119 = ____math_max_108( -- 3499
			1, -- 3499
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3499
		) -- 3499
		local ____math_max_111 = math.max -- 3500
		local ____math_floor_110 = math.floor -- 3500
		local ____params_offset_109 = params.offset -- 3500
		if ____params_offset_109 == nil then -- 3500
			____params_offset_109 = 0 -- 3500
		end -- 3500
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3490
			workDir = ____input_workDir_112, -- 3491
			path = ____temp_113, -- 3492
			pattern = ____temp_114, -- 3493
			globs = ____params_globs_115, -- 3494
			useRegex = ____params_useRegex_116, -- 3495
			caseSensitive = ____params_caseSensitive_117, -- 3496
			includeContent = true, -- 3497
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3498
			limit = ____math_max_108_result_119, -- 3499
			offset = ____math_max_111( -- 3500
				0, -- 3500
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3500
			), -- 3500
			groupByFile = params.groupByFile == true -- 3501
		})) -- 3501
		return ____awaiter_resolve(nil, result) -- 3501
	end) -- 3501
end -- 3488
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3506
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3506
		local last = shared.history[#shared.history] -- 3507
		if last ~= nil then -- 3507
			local result = execRes -- 3509
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3510
			appendToolResultMessage(shared, last) -- 3511
			emitAgentFinishEvent(shared, last) -- 3512
		end -- 3512
		persistHistoryState(shared) -- 3514
		__TS__Await(maybeCompressHistory(shared)) -- 3515
		persistHistoryState(shared) -- 3516
		return ____awaiter_resolve(nil, "main") -- 3516
	end) -- 3516
end -- 3506
local SearchDoraDocAction = __TS__Class() -- 3521
SearchDoraDocAction.name = "SearchDoraDocAction" -- 3521
__TS__ClassExtends(SearchDoraDocAction, Node) -- 3521
function SearchDoraDocAction.prototype.prep(self, shared) -- 3522
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3522
		local last = shared.history[#shared.history] -- 3523
		if not last then -- 3523
			error( -- 3524
				__TS__New(Error, "no history"), -- 3524
				0 -- 3524
			) -- 3524
		end -- 3524
		emitAgentStartEvent(shared, last) -- 3525
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3525
	end) -- 3525
end -- 3522
function SearchDoraDocAction.prototype.exec(self, input) -- 3529
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3529
		local params = input.params -- 3530
		local ____Tools_searchDoraDoc_129 = Tools.searchDoraDoc -- 3531
		local ____temp_125 = params.pattern or "" -- 3532
		local ____temp_126 = params.docType or "dora-api" -- 3533
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3534
		local ____temp_128 = params.programmingLanguage or "ts" -- 3535
		local ____math_min_124 = math.min -- 3536
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 3536
		local ____math_max_122 = math.max -- 3536
		local ____params_limit_121 = params.limit -- 3536
		if ____params_limit_121 == nil then -- 3536
			____params_limit_121 = 8 -- 3536
		end -- 3536
		local result = __TS__Await(____Tools_searchDoraDoc_129({ -- 3531
			pattern = ____temp_125, -- 3532
			docType = ____temp_126, -- 3533
			docLanguage = ____temp_127, -- 3534
			programmingLanguage = ____temp_128, -- 3535
			limit = ____math_min_124( -- 3536
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_123, -- 3536
				____math_max_122( -- 3536
					1, -- 3536
					__TS__Number(____params_limit_121) -- 3536
				) -- 3536
			), -- 3536
			useRegex = params.useRegex, -- 3537
			caseSensitive = false, -- 3538
			includeContent = true, -- 3539
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3540
		})) -- 3540
		return ____awaiter_resolve(nil, result) -- 3540
	end) -- 3540
end -- 3529
function SearchDoraDocAction.prototype.post(self, shared, _prepRes, execRes) -- 3545
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3545
		local last = shared.history[#shared.history] -- 3546
		if last ~= nil then -- 3546
			local result = execRes -- 3548
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3549
			appendToolResultMessage(shared, last) -- 3550
			emitAgentFinishEvent(shared, last) -- 3551
		end -- 3551
		persistHistoryState(shared) -- 3553
		__TS__Await(maybeCompressHistory(shared)) -- 3554
		persistHistoryState(shared) -- 3555
		return ____awaiter_resolve(nil, "main") -- 3555
	end) -- 3555
end -- 3545
local ListFilesAction = __TS__Class() -- 3560
ListFilesAction.name = "ListFilesAction" -- 3560
__TS__ClassExtends(ListFilesAction, Node) -- 3560
function ListFilesAction.prototype.prep(self, shared) -- 3561
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3561
		local last = shared.history[#shared.history] -- 3562
		if not last then -- 3562
			error( -- 3563
				__TS__New(Error, "no history"), -- 3563
				0 -- 3563
			) -- 3563
		end -- 3563
		emitAgentStartEvent(shared, last) -- 3564
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3564
	end) -- 3564
end -- 3561
function ListFilesAction.prototype.exec(self, input) -- 3568
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3568
		local params = input.params -- 3569
		local ____Tools_listFiles_136 = Tools.listFiles -- 3570
		local ____input_workDir_133 = input.workDir -- 3571
		local ____temp_134 = params.path or "" -- 3572
		local ____params_globs_135 = params.globs -- 3573
		local ____math_max_132 = math.max -- 3574
		local ____math_floor_131 = math.floor -- 3574
		local ____params_maxEntries_130 = params.maxEntries -- 3574
		if ____params_maxEntries_130 == nil then -- 3574
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3574
		end -- 3574
		local result = ____Tools_listFiles_136({ -- 3570
			workDir = ____input_workDir_133, -- 3571
			path = ____temp_134, -- 3572
			globs = ____params_globs_135, -- 3573
			maxEntries = ____math_max_132( -- 3574
				1, -- 3574
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3574
			) -- 3574
		}) -- 3574
		return ____awaiter_resolve(nil, result) -- 3574
	end) -- 3574
end -- 3568
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3579
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3579
		local last = shared.history[#shared.history] -- 3580
		if last ~= nil then -- 3580
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3582
			appendToolResultMessage(shared, last) -- 3583
			emitAgentFinishEvent(shared, last) -- 3584
		end -- 3584
		persistHistoryState(shared) -- 3586
		__TS__Await(maybeCompressHistory(shared)) -- 3587
		persistHistoryState(shared) -- 3588
		return ____awaiter_resolve(nil, "main") -- 3588
	end) -- 3588
end -- 3579
local DeleteFileAction = __TS__Class() -- 3593
DeleteFileAction.name = "DeleteFileAction" -- 3593
__TS__ClassExtends(DeleteFileAction, Node) -- 3593
function DeleteFileAction.prototype.prep(self, shared) -- 3594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3594
		local last = shared.history[#shared.history] -- 3595
		if not last then -- 3595
			error( -- 3596
				__TS__New(Error, "no history"), -- 3596
				0 -- 3596
			) -- 3596
		end -- 3596
		emitAgentStartEvent(shared, last) -- 3597
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3598
		if __TS__StringTrim(targetFile) == "" then -- 3598
			error( -- 3601
				__TS__New(Error, "missing target_file"), -- 3601
				0 -- 3601
			) -- 3601
		end -- 3601
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3601
	end) -- 3601
end -- 3594
function DeleteFileAction.prototype.exec(self, input) -- 3605
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3605
		local result = Tools.deleteFile(input.taskId, input.workDir, input.targetFile, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3606
		if not result.success then -- 3606
			return ____awaiter_resolve(nil, result) -- 3606
		end -- 3606
		local ____result_checkpointed_138 = result.checkpointed -- 3617
		local ____result_reversible_139 = result.reversible -- 3618
		local ____result_binary_140 = result.binary -- 3619
		local ____temp_141 = result.checkpointed and result.checkpointId or nil -- 3620
		local ____temp_142 = result.checkpointed and result.checkpointSeq or nil -- 3621
		local ____result_checkpointed_137 -- 3622
		if result.checkpointed then -- 3622
			____result_checkpointed_137 = nil -- 3622
		else -- 3622
			____result_checkpointed_137 = result.message -- 3622
		end -- 3622
		return ____awaiter_resolve(nil, { -- 3622
			success = true, -- 3614
			changed = true, -- 3615
			mode = "delete", -- 3616
			checkpointed = ____result_checkpointed_138, -- 3617
			reversible = ____result_reversible_139, -- 3618
			binary = ____result_binary_140, -- 3619
			checkpointId = ____temp_141, -- 3620
			checkpointSeq = ____temp_142, -- 3621
			message = ____result_checkpointed_137, -- 3622
			files = {{path = input.targetFile, op = "delete"}} -- 3623
		}) -- 3623
	end) -- 3623
end -- 3605
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3627
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3627
		local last = shared.history[#shared.history] -- 3628
		if last ~= nil then -- 3628
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3630
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3631
			appendToolResultMessage(shared, last) -- 3632
			emitAgentFinishEvent(shared, last) -- 3633
			local result = last.result -- 3634
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3634
				emitAgentEvent(shared, { -- 3639
					type = "checkpoint_created", -- 3640
					sessionId = shared.sessionId, -- 3641
					taskId = shared.taskId, -- 3642
					step = last.step, -- 3643
					tool = "delete_file", -- 3644
					checkpointId = result.checkpointId, -- 3645
					checkpointSeq = result.checkpointSeq, -- 3646
					files = result.files -- 3647
				}) -- 3647
			end -- 3647
		end -- 3647
		persistHistoryState(shared) -- 3654
		__TS__Await(maybeCompressHistory(shared)) -- 3655
		persistHistoryState(shared) -- 3656
		return ____awaiter_resolve(nil, "main") -- 3656
	end) -- 3656
end -- 3627
local BuildAction = __TS__Class() -- 3661
BuildAction.name = "BuildAction" -- 3661
__TS__ClassExtends(BuildAction, Node) -- 3661
function BuildAction.prototype.prep(self, shared) -- 3662
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3662
		local last = shared.history[#shared.history] -- 3663
		if not last then -- 3663
			error( -- 3664
				__TS__New(Error, "no history"), -- 3664
				0 -- 3664
			) -- 3664
		end -- 3664
		emitAgentStartEvent(shared, last) -- 3665
		return ____awaiter_resolve( -- 3665
			nil, -- 3665
			{ -- 3666
				params = last.params, -- 3666
				workDir = shared.workingDir, -- 3666
				isCancelled = function() return shared.stopToken.stopped end -- 3666
			} -- 3666
		) -- 3666
	end) -- 3666
end -- 3662
function BuildAction.prototype.exec(self, input) -- 3669
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3669
		local params = input.params -- 3670
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or "", isCancelled = input.isCancelled})) -- 3671
		return ____awaiter_resolve(nil, result) -- 3671
	end) -- 3671
end -- 3669
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3679
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3679
		local last = shared.history[#shared.history] -- 3680
		if last ~= nil then -- 3680
			last.result = sanitizeBuildResultForHistory(execRes) -- 3682
			appendToolResultMessage(shared, last) -- 3683
			emitAgentFinishEvent(shared, last) -- 3684
		end -- 3684
		persistHistoryState(shared) -- 3686
		__TS__Await(maybeCompressHistory(shared)) -- 3687
		persistHistoryState(shared) -- 3688
		return ____awaiter_resolve(nil, "main") -- 3688
	end) -- 3688
end -- 3679
local SpawnSubAgentAction = __TS__Class() -- 3693
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3693
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3693
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3694
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3694
		local last = shared.history[#shared.history] -- 3704
		if not last then -- 3704
			error( -- 3705
				__TS__New(Error, "no history"), -- 3705
				0 -- 3705
			) -- 3705
		end -- 3705
		emitAgentStartEvent(shared, last) -- 3706
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3707
			last.params.filesHint, -- 3708
			function(____, item) return type(item) == "string" end -- 3708
		) or nil -- 3708
		return ____awaiter_resolve( -- 3708
			nil, -- 3708
			{ -- 3710
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3711
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3712
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3713
				filesHint = filesHint, -- 3714
				sessionId = shared.sessionId, -- 3715
				projectRoot = shared.workingDir, -- 3716
				spawnSubAgent = shared.spawnSubAgent, -- 3717
				disabledAgentTools = shared.disabledAgentTools -- 3718
			} -- 3718
		) -- 3718
	end) -- 3718
end -- 3694
function SpawnSubAgentAction.prototype.exec(self, input) -- 3722
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3722
		if not input.spawnSubAgent then -- 3722
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3722
		end -- 3722
		if input.sessionId == nil or input.sessionId <= 0 then -- 3722
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3722
		end -- 3722
		local ____AgentUtils_Log_148 = AgentUtils.Log -- 3738
		local ____temp_145 = #input.title -- 3738
		local ____temp_146 = #input.prompt -- 3738
		local ____temp_147 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3738
		local ____opt_143 = input.filesHint -- 3738
		____AgentUtils_Log_148( -- 3738
			"Info", -- 3738
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_145)) .. " prompt_len=") .. tostring(____temp_146)) .. " expected_len=") .. tostring(____temp_147)) .. " files_hint_count=") .. tostring(____opt_143 and #____opt_143 or 0) -- 3738
		) -- 3738
		local result = __TS__Await(input.spawnSubAgent({ -- 3739
			parentSessionId = input.sessionId, -- 3740
			projectRoot = input.projectRoot, -- 3741
			title = input.title, -- 3742
			prompt = input.prompt, -- 3743
			expectedOutput = input.expectedOutput, -- 3744
			filesHint = input.filesHint, -- 3745
			disabledAgentTools = input.disabledAgentTools -- 3746
		})) -- 3746
		if not result.success then -- 3746
			return ____awaiter_resolve(nil, result) -- 3746
		end -- 3746
		return ____awaiter_resolve(nil, { -- 3746
			success = true, -- 3752
			sessionId = result.sessionId, -- 3753
			taskId = result.taskId, -- 3754
			title = result.title, -- 3755
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3756
		}) -- 3756
	end) -- 3756
end -- 3722
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3760
		local last = shared.history[#shared.history] -- 3761
		if last ~= nil then -- 3761
			last.result = execRes -- 3763
			if execRes.success == true then -- 3763
				shared.hasSpawnedSubAgentThisTask = true -- 3765
			end -- 3765
			appendToolResultMessage(shared, last) -- 3767
			emitAgentFinishEvent(shared, last) -- 3768
		end -- 3768
		persistHistoryState(shared) -- 3770
		__TS__Await(maybeCompressHistory(shared)) -- 3771
		persistHistoryState(shared) -- 3772
		return ____awaiter_resolve(nil, "main") -- 3772
	end) -- 3772
end -- 3760
local ListSubAgentsAction = __TS__Class() -- 3777
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3777
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3777
function ListSubAgentsAction.prototype.prep(self, shared) -- 3778
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3778
		local last = shared.history[#shared.history] -- 3788
		if not last then -- 3788
			error( -- 3789
				__TS__New(Error, "no history"), -- 3789
				0 -- 3789
			) -- 3789
		end -- 3789
		emitAgentStartEvent(shared, last) -- 3790
		return ____awaiter_resolve( -- 3790
			nil, -- 3790
			{ -- 3791
				sessionId = shared.sessionId, -- 3792
				projectRoot = shared.workingDir, -- 3793
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3794
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3795
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3796
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3797
				listSubAgents = shared.listSubAgents, -- 3798
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3799
			} -- 3799
		) -- 3799
	end) -- 3799
end -- 3778
function ListSubAgentsAction.prototype.exec(self, input) -- 3803
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3803
		if not input.listSubAgents then -- 3803
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3803
		end -- 3803
		if input.sessionId == nil or input.sessionId <= 0 then -- 3803
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3803
		end -- 3803
		local result = __TS__Await(input.listSubAgents({ -- 3819
			sessionId = input.sessionId, -- 3820
			projectRoot = input.projectRoot, -- 3821
			status = input.status, -- 3822
			limit = input.limit, -- 3823
			offset = input.offset, -- 3824
			query = input.query -- 3825
		})) -- 3825
		return ____awaiter_resolve( -- 3825
			nil, -- 3825
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3827
		) -- 3827
	end) -- 3827
end -- 3803
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3835
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3835
		local last = shared.history[#shared.history] -- 3836
		if last ~= nil then -- 3836
			last.result = execRes -- 3838
			appendToolResultMessage(shared, last) -- 3839
			emitAgentFinishEvent(shared, last) -- 3840
		end -- 3840
		persistHistoryState(shared) -- 3842
		__TS__Await(maybeCompressHistory(shared)) -- 3843
		persistHistoryState(shared) -- 3844
		return ____awaiter_resolve(nil, "main") -- 3844
	end) -- 3844
end -- 3835
EditFileAction = __TS__Class() -- 3849
EditFileAction.name = "EditFileAction" -- 3849
__TS__ClassExtends(EditFileAction, Node) -- 3849
function EditFileAction.prototype.prep(self, shared) -- 3850
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3850
		local last = shared.history[#shared.history] -- 3851
		if not last then -- 3851
			error( -- 3852
				__TS__New(Error, "no history"), -- 3852
				0 -- 3852
			) -- 3852
		end -- 3852
		emitAgentStartEvent(shared, last) -- 3853
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3854
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3857
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3858
		if __TS__StringTrim(path) == "" then -- 3858
			error( -- 3859
				__TS__New(Error, "missing path"), -- 3859
				0 -- 3859
			) -- 3859
		end -- 3859
		return ____awaiter_resolve(nil, { -- 3859
			path = path, -- 3860
			oldStr = oldStr, -- 3860
			newStr = newStr, -- 3860
			taskId = shared.taskId, -- 3860
			workDir = shared.workingDir -- 3860
		}) -- 3860
	end) -- 3860
end -- 3850
function EditFileAction.prototype.exec(self, input) -- 3863
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3863
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3864
		if not readRes.success then -- 3864
			if input.oldStr ~= "" then -- 3864
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3864
			end -- 3864
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3869
			if not createRes.success then -- 3869
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3869
			end -- 3869
			return ____awaiter_resolve( -- 3869
				nil, -- 3869
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3876
					success = true, -- 3877
					changed = true, -- 3878
					mode = "create", -- 3879
					checkpointId = createRes.checkpointId, -- 3880
					checkpointSeq = createRes.checkpointSeq, -- 3881
					files = {{path = input.path, op = "create"}} -- 3882
				}) -- 3882
			) -- 3882
		end -- 3882
		if input.oldStr == "" then -- 3882
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3882
				return ____awaiter_resolve( -- 3882
					nil, -- 3882
					{ -- 3887
						success = false, -- 3888
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3889
						actualSaved = false, -- 3890
						actualSavedCharacters = 0, -- 3891
						currentFileExists = true, -- 3892
						currentCharacters = #readRes.content, -- 3893
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3894
					} -- 3894
				) -- 3894
			end -- 3894
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3897
			if not overwriteRes.success then -- 3897
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3897
			end -- 3897
			return ____awaiter_resolve( -- 3897
				nil, -- 3897
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3904
					success = true, -- 3905
					changed = true, -- 3906
					mode = "overwrite", -- 3907
					checkpointId = overwriteRes.checkpointId, -- 3908
					checkpointSeq = overwriteRes.checkpointSeq, -- 3909
					files = {{path = input.path, op = "write"}} -- 3910
				}) -- 3910
			) -- 3910
		end -- 3910
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3915
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3916
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3917
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3920
		if occurrences == 0 then -- 3920
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3922
			if not indentTolerant.success then -- 3922
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3922
			end -- 3922
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3926
			if not applyRes.success then -- 3926
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3926
			end -- 3926
			return ____awaiter_resolve( -- 3926
				nil, -- 3926
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3933
					success = true, -- 3934
					changed = true, -- 3935
					mode = "replace_indent_tolerant", -- 3936
					checkpointId = applyRes.checkpointId, -- 3937
					checkpointSeq = applyRes.checkpointSeq, -- 3938
					files = {{path = input.path, op = "write"}} -- 3939
				}) -- 3939
			) -- 3939
		end -- 3939
		if occurrences > 1 then -- 3939
			return ____awaiter_resolve( -- 3939
				nil, -- 3939
				{ -- 3943
					success = false, -- 3943
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3943
				} -- 3943
			) -- 3943
		end -- 3943
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3947
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3948
		if not applyRes.success then -- 3948
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3948
		end -- 3948
		return ____awaiter_resolve( -- 3948
			nil, -- 3948
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3955
				success = true, -- 3956
				changed = true, -- 3957
				mode = "replace", -- 3958
				checkpointId = applyRes.checkpointId, -- 3959
				checkpointSeq = applyRes.checkpointSeq, -- 3960
				files = {{path = input.path, op = "write"}} -- 3961
			}) -- 3961
		) -- 3961
	end) -- 3961
end -- 3863
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3965
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3965
		local last = shared.history[#shared.history] -- 3966
		if last ~= nil then -- 3966
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3968
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3969
			appendToolResultMessage(shared, last) -- 3970
			emitAgentFinishEvent(shared, last) -- 3971
			local result = last.result -- 3972
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3972
				emitAgentEvent(shared, { -- 3977
					type = "checkpoint_created", -- 3978
					sessionId = shared.sessionId, -- 3979
					taskId = shared.taskId, -- 3980
					step = last.step, -- 3981
					tool = last.tool, -- 3982
					checkpointId = result.checkpointId, -- 3983
					checkpointSeq = result.checkpointSeq, -- 3984
					files = result.files -- 3985
				}) -- 3985
			end -- 3985
		end -- 3985
		persistHistoryState(shared) -- 3992
		__TS__Await(maybeCompressHistory(shared)) -- 3993
		persistHistoryState(shared) -- 3994
		return ____awaiter_resolve(nil, "main") -- 3994
	end) -- 3994
end -- 3965
local FetchUrlAction = __TS__Class() -- 3999
FetchUrlAction.name = "FetchUrlAction" -- 3999
__TS__ClassExtends(FetchUrlAction, Node) -- 3999
function FetchUrlAction.prototype.prep(self, shared) -- 4000
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4000
		local last = shared.history[#shared.history] -- 4001
		if not last then -- 4001
			error( -- 4002
				__TS__New(Error, "no history"), -- 4002
				0 -- 4002
			) -- 4002
		end -- 4002
		emitAgentStartEvent(shared, last) -- 4003
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 4003
	end) -- 4003
end -- 4000
function FetchUrlAction.prototype.exec(self, input) -- 4007
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4007
		return ____awaiter_resolve( -- 4007
			nil, -- 4007
			executeToolAction(input.shared, input.action) -- 4008
		) -- 4008
	end) -- 4008
end -- 4007
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 4011
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4011
		local last = shared.history[#shared.history] -- 4012
		if last ~= nil then -- 4012
			last.result = execRes -- 4014
			appendToolResultMessage(shared, last) -- 4015
			emitAgentFinishEvent(shared, last) -- 4016
		end -- 4016
		persistHistoryState(shared) -- 4018
		__TS__Await(maybeCompressHistory(shared)) -- 4019
		persistHistoryState(shared) -- 4020
		return ____awaiter_resolve(nil, "main") -- 4020
	end) -- 4020
end -- 4011
local function emitCheckpointEventForAction(shared, action) -- 4025
	local result = action.result -- 4026
	if not result then -- 4026
		return -- 4027
	end -- 4027
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4027
		emitAgentEvent(shared, { -- 4032
			type = "checkpoint_created", -- 4033
			sessionId = shared.sessionId, -- 4034
			taskId = shared.taskId, -- 4035
			step = action.step, -- 4036
			tool = action.tool, -- 4037
			checkpointId = result.checkpointId, -- 4038
			checkpointSeq = result.checkpointSeq, -- 4039
			files = result.files -- 4040
		}) -- 4040
	end -- 4040
end -- 4025
local function canRunBatchActionInParallel(self, action) -- 4572
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4573
end -- 4572
local function partitionToolCalls(actions) -- 4581
	local batches = {} -- 4582
	do -- 4582
		local i = 0 -- 4583
		while i < #actions do -- 4583
			local action = actions[i + 1] -- 4584
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4585
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4586
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4586
				local ____lastBatch_actions_187 = lastBatch.actions -- 4586
				____lastBatch_actions_187[#____lastBatch_actions_187 + 1] = action -- 4588
			else -- 4588
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4590
			end -- 4590
			i = i + 1 -- 4583
		end -- 4583
	end -- 4583
	return batches -- 4593
end -- 4581
local function completeStoppedToolAction(shared, action) -- 4596
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4597
	if not action.result then -- 4597
		action.result = { -- 4599
			success = false, -- 4599
			message = getCancelledReason(shared) -- 4599
		} -- 4599
	end -- 4599
	appendToolResultMessage(shared, action) -- 4601
	emitAgentFinishEvent(shared, action) -- 4602
	emitCheckpointEventForAction(shared, action) -- 4603
end -- 4596
local BatchToolAction = __TS__Class() -- 4606
BatchToolAction.name = "BatchToolAction" -- 4606
__TS__ClassExtends(BatchToolAction, Node) -- 4606
function BatchToolAction.prototype.prep(self, shared) -- 4607
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4607
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4607
	end) -- 4607
end -- 4607
function BatchToolAction.prototype.exec(self, input) -- 4611
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4611
		local shared = input.shared -- 4612
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4613
		local preExecuted = shared.preExecutedResults -- 4614
		local batches = partitionToolCalls(input.actions) -- 4615
		local parallelBatchCount = #__TS__ArrayFilter( -- 4616
			batches, -- 4616
			function(____, b) return b.isConcurrencySafe end -- 4616
		) -- 4616
		local serialBatchCount = #__TS__ArrayFilter( -- 4617
			batches, -- 4617
			function(____, b) return not b.isConcurrencySafe end -- 4617
		) -- 4617
		AgentUtils.Log( -- 4618
			"Info", -- 4618
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4618
		) -- 4618
		do -- 4618
			local batchIdx = 0 -- 4620
			while batchIdx < #batches do -- 4620
				do -- 4620
					local batch = batches[batchIdx + 1] -- 4621
					if shared.stopToken.stopped then -- 4621
						for ____, action in ipairs(batch.actions) do -- 4623
							completeStoppedToolAction(shared, action) -- 4624
						end -- 4624
						goto __continue767 -- 4626
					end -- 4626
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4626
						local preExecCount = #__TS__ArrayFilter( -- 4630
							batch.actions, -- 4630
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4630
						) -- 4630
						AgentUtils.Log( -- 4631
							"Info", -- 4631
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4631
						) -- 4631
						do -- 4631
							local i = 0 -- 4632
							while i < #batch.actions do -- 4632
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4633
								i = i + 1 -- 4632
							end -- 4632
						end -- 4632
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4635
							batch.actions, -- 4635
							function(____, action) -- 4635
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4635
									if shared.stopToken.stopped then -- 4635
										action.result = { -- 4637
											success = false, -- 4637
											message = getCancelledReason(shared) -- 4637
										} -- 4637
										return ____awaiter_resolve(nil, action) -- 4637
									end -- 4637
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4640
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4641
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4642
									return ____awaiter_resolve(nil, action) -- 4642
								end) -- 4642
							end -- 4635
						))) -- 4635
						do -- 4635
							local i = 0 -- 4645
							while i < #batch.actions do -- 4645
								local action = batch.actions[i + 1] -- 4646
								if not action.result then -- 4646
									action.result = {success = false, message = "tool did not produce a result"} -- 4648
								end -- 4648
								appendToolResultMessage(shared, action) -- 4650
								emitAgentFinishEvent(shared, action) -- 4651
								emitCheckpointEventForAction(shared, action) -- 4652
								i = i + 1 -- 4645
							end -- 4645
						end -- 4645
					else -- 4645
						AgentUtils.Log( -- 4655
							"Info", -- 4655
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4655
						) -- 4655
						do -- 4655
							local i = 0 -- 4656
							while i < #batch.actions do -- 4656
								local action = batch.actions[i + 1] -- 4657
								emitAgentStartEvent(shared, action) -- 4658
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4659
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4660
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4661
								appendToolResultMessage(shared, action) -- 4662
								emitAgentFinishEvent(shared, action) -- 4663
								emitCheckpointEventForAction(shared, action) -- 4664
								persistHistoryState(shared) -- 4665
								if shared.stopToken.stopped then -- 4665
									do -- 4665
										local j = i + 1 -- 4667
										while j < #batch.actions do -- 4667
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4668
											j = j + 1 -- 4667
										end -- 4667
									end -- 4667
									break -- 4670
								end -- 4670
								i = i + 1 -- 4656
							end -- 4656
						end -- 4656
					end -- 4656
				end -- 4656
				::__continue767:: -- 4656
				batchIdx = batchIdx + 1 -- 4620
			end -- 4620
		end -- 4620
		local spawnSeen = spawnedBeforeBatch -- 4675
		local didDelegatedForegroundWork = false -- 4676
		do -- 4676
			local i = 0 -- 4677
			while i < #input.actions do -- 4677
				do -- 4677
					local action = input.actions[i + 1] -- 4678
					if action.tool == "spawn_sub_agent" then -- 4678
						local ____opt_190 = action.result -- 4678
						if (____opt_190 and ____opt_190.success) == true then -- 4678
							spawnSeen = true -- 4680
						end -- 4680
						goto __continue787 -- 4681
					end -- 4681
					if spawnSeen and action.tool ~= "finish" then -- 4681
						didDelegatedForegroundWork = true -- 4684
					end -- 4684
				end -- 4684
				::__continue787:: -- 4684
				i = i + 1 -- 4677
			end -- 4677
		end -- 4677
		if didDelegatedForegroundWork then -- 4677
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4688
		end -- 4688
		persistHistoryState(shared) -- 4690
		return ____awaiter_resolve(nil, input.actions) -- 4690
	end) -- 4690
end -- 4611
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4694
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4694
		shared.pendingToolActions = nil -- 4695
		shared.preExecutedResults = nil -- 4696
		persistHistoryState(shared) -- 4697
		if shared.waitingQuestionnaireId == nil then -- 4697
			__TS__Await(maybeCompressHistory(shared)) -- 4701
			persistHistoryState(shared) -- 4702
		end -- 4702
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4702
	end) -- 4702
end -- 4694
local EndNode = __TS__Class() -- 4708
EndNode.name = "EndNode" -- 4708
__TS__ClassExtends(EndNode, Node) -- 4708
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4709
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4709
		return ____awaiter_resolve(nil, nil) -- 4709
	end) -- 4709
end -- 4709
local CodingAgentFlow = __TS__Class() -- 4714
CodingAgentFlow.name = "CodingAgentFlow" -- 4714
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4714
function CodingAgentFlow.prototype.____constructor(self, role) -- 4715
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4716
	local read = __TS__New(ReadFileAction, 1, 0) -- 4717
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4718
	local searchDora = __TS__New(SearchDoraDocAction, 1, 0) -- 4719
	local list = __TS__New(ListFilesAction, 1, 0) -- 4720
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4721
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4722
	local build = __TS__New(BuildAction, 1, 0) -- 4723
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4724
	local edit = __TS__New(EditFileAction, 1, 0) -- 4725
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4726
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4727
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4728
	local done = __TS__New(EndNode, 1, 0) -- 4729
	main:on("batch_tools", batch) -- 4731
	main:on("grep_files", search) -- 4732
	main:on("search_dora_doc", searchDora) -- 4733
	main:on("glob_files", list) -- 4734
	main:on("fetch_url", fetch) -- 4735
	main:on("execute_command", exec) -- 4736
	if role == "main" then -- 4736
		main:on("read_file", read) -- 4738
		main:on("delete_file", del) -- 4739
		main:on("build", build) -- 4740
		main:on("edit_file", edit) -- 4741
		main:on("list_sub_agents", listSub) -- 4742
		main:on("spawn_sub_agent", spawn) -- 4743
	else -- 4743
		main:on("read_file", read) -- 4745
		main:on("delete_file", del) -- 4746
		main:on("build", build) -- 4747
		main:on("edit_file", edit) -- 4748
	end -- 4748
	main:on("done", done) -- 4750
	search:on("main", main) -- 4752
	searchDora:on("main", main) -- 4753
	list:on("main", main) -- 4754
	listSub:on("main", main) -- 4755
	spawn:on("main", main) -- 4756
	batch:on("main", main) -- 4757
	batch:on("done", done) -- 4758
	read:on("main", main) -- 4759
	del:on("main", main) -- 4760
	build:on("main", main) -- 4761
	edit:on("main", main) -- 4762
	fetch:on("main", main) -- 4763
	exec:on("main", main) -- 4764
	Flow.prototype.____constructor(self, main) -- 4766
end -- 4715
local function runCodingAgentAsync(options) -- 4802
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4802
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4802
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4802
		end -- 4802
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4806
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4807
		if not llmConfigRes.success then -- 4807
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4807
		end -- 4807
		local llmConfig = llmConfigRes.config -- 4813
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4814
		if not taskRes.success then -- 4814
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4814
		end -- 4814
		local compressor = __TS__New(MemoryCompressor, { -- 4821
			compressionTargetThreshold = 0.5, -- 4822
			maxCompressionRounds = 3, -- 4823
			projectDir = options.workDir, -- 4824
			llmConfig = llmConfig, -- 4825
			promptPack = options.promptPack, -- 4826
			scope = options.memoryScope -- 4827
		}) -- 4827
		local persistedSession = compressor:getStorage():readSessionState() -- 4829
		local effectiveUserQuery = normalizedPrompt -- 4830
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4830
			do -- 4830
				local i = #persistedSession.messages - 1 -- 4832
				while i >= 0 do -- 4832
					local message = persistedSession.messages[i + 1] -- 4833
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4833
						effectiveUserQuery = message.content -- 4835
						break -- 4836
					end -- 4836
					i = i - 1 -- 4832
				end -- 4832
			end -- 4832
		end -- 4832
		local promptPack = compressor:getPromptPack() -- 4840
		local freshProject = inspectFreshProject(options.workDir) -- 4841
		local freshProjectBuildPending = freshProject.fresh -- 4842
		local freshProjectCodeFile = freshProject.codeFile -- 4843
		local shared = { -- 4845
			sessionId = options.sessionId, -- 4846
			taskId = taskRes.taskId, -- 4847
			role = options.role or "main", -- 4848
			maxSteps = math.max( -- 4849
				1, -- 4849
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4849
			), -- 4849
			llmMaxTry = math.max( -- 4850
				1, -- 4850
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4850
			), -- 4850
			step = math.max( -- 4851
				0, -- 4851
				math.floor(options.initialStep or 0) -- 4851
			), -- 4851
			agentStepCount = math.max( -- 4852
				0, -- 4852
				math.floor(options.initialAgentStepCount or 0) -- 4852
			), -- 4852
			done = false, -- 4853
			stopToken = options.stopToken or ({stopped = false}), -- 4854
			response = "", -- 4855
			userQuery = effectiveUserQuery, -- 4856
			workingDir = options.workDir, -- 4857
			useChineseResponse = options.useChineseResponse == true, -- 4858
			workMode = options.workMode or "code", -- 4859
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4860
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4863
			llmConfig = llmConfig, -- 4864
			onEvent = options.onEvent, -- 4865
			promptPack = promptPack, -- 4866
			history = {}, -- 4867
			messages = persistedSession.messages, -- 4868
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4869
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4870
			memory = {compressor = compressor}, -- 4872
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4876
				projectDir = options.workDir, -- 4878
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4879
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4880
			})}, -- 4880
			spawnSubAgent = options.spawnSubAgent, -- 4886
			listSubAgents = options.listSubAgents, -- 4887
			publishQuestionnaire = options.publishQuestionnaire, -- 4888
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4889
			freshProjectBuildPending = freshProjectBuildPending, -- 4890
			freshProjectCodeFile = freshProjectCodeFile, -- 4891
			hasSpawnedSubAgentThisTask = false, -- 4892
			delegatedForegroundBatches = 0, -- 4893
			tokenUsage = options.initialTokenUsage -- 4894
		} -- 4894
		local ____hasReturned, ____returnValue -- 4894
		local ____try = __TS__AsyncAwaiter(function() -- 4894
			if shared.workMode == "plan" then -- 4894
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4899
				if not planDocuments.success then -- 4899
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4901
					____hasReturned = true -- 4902
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4902
					return -- 4902
				end -- 4902
			end -- 4902
			emitAgentEvent(shared, { -- 4905
				type = "task_started", -- 4906
				sessionId = shared.sessionId, -- 4907
				taskId = shared.taskId, -- 4908
				prompt = shared.userQuery, -- 4909
				workDir = shared.workingDir, -- 4910
				maxSteps = shared.maxSteps, -- 4911
				resumed = options.resumeTask == true -- 4912
			}) -- 4912
			if shared.stopToken.stopped then -- 4912
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4915
				____hasReturned = true -- 4916
				____returnValue = emitAgentTaskFinishEvent( -- 4916
					shared, -- 4916
					false, -- 4916
					getCancelledReason(shared) -- 4916
				) -- 4916
				return -- 4916
			end -- 4916
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4918
			local ____temp_192 -- 4919
			if options.resumeConversation == true then -- 4919
				____temp_192 = nil -- 4919
			else -- 4919
				____temp_192 = getPromptCommand(shared.userQuery) -- 4919
			end -- 4919
			local promptCommand = ____temp_192 -- 4919
			if promptCommand == "clear" then -- 4919
				____hasReturned = true -- 4921
				____returnValue = clearSessionHistory(shared) -- 4921
				return -- 4921
			end -- 4921
			if promptCommand == "compact" then -- 4921
				if shared.role == "sub" then -- 4921
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4925
					____hasReturned = true -- 4926
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4926
					return -- 4926
				end -- 4926
				____hasReturned = true -- 4934
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4934
				return -- 4934
			end -- 4934
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4936
			if shared.stopToken.stopped then -- 4936
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4938
				____hasReturned = true -- 4939
				____returnValue = emitAgentTaskFinishEvent( -- 4939
					shared, -- 4939
					false, -- 4939
					getCancelledReason(shared) -- 4939
				) -- 4939
				return -- 4939
			end -- 4939
			if options.resumeConversation ~= true then -- 4939
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4942
				persistHistoryState(shared) -- 4946
			end -- 4946
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4948
			__TS__Await(flow:run(shared)) -- 4949
			if shared.stopToken.stopped then -- 4949
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4951
				____hasReturned = true -- 4952
				____returnValue = emitAgentTaskFinishEvent( -- 4952
					shared, -- 4952
					false, -- 4952
					getCancelledReason(shared) -- 4952
				) -- 4952
				return -- 4952
			end -- 4952
			if shared.error then -- 4952
				____hasReturned = true -- 4955
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4955
				return -- 4955
			end -- 4955
			if shared.waitingQuestionnaireId ~= nil then -- 4955
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4959
				emitAgentEvent(shared, { -- 4960
					type = "task_waiting_for_user", -- 4961
					sessionId = shared.sessionId, -- 4962
					taskId = shared.taskId, -- 4963
					step = shared.step, -- 4964
					questionnaireId = shared.waitingQuestionnaireId -- 4965
				}) -- 4965
				____hasReturned = true -- 4967
				____returnValue = { -- 4967
					success = true, -- 4968
					taskId = shared.taskId, -- 4969
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4970
					steps = shared.step, -- 4971
					waitingForUser = true, -- 4972
					questionnaireId = shared.waitingQuestionnaireId -- 4973
				} -- 4973
				return -- 4967
			end -- 4967
			local ____isFinalDecisionTurn_result_195 = isFinalDecisionTurn(shared) -- 4976
			if ____isFinalDecisionTurn_result_195 then -- 4976
				local ____opt_193 = shared.completion -- 4976
				____isFinalDecisionTurn_result_195 = (____opt_193 and ____opt_193.outcome) == "partial" -- 4976
			end -- 4976
			if ____isFinalDecisionTurn_result_195 then -- 4976
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4977
				____hasReturned = true -- 4978
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4978
				return -- 4978
			end -- 4978
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4981
			____hasReturned = true -- 4982
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4982
			return -- 4982
		end) -- 4982
		____try = ____try.catch( -- 4982
			____try, -- 4982
			function(____, e) -- 4982
				return __TS__AsyncAwaiter(function() -- 4982
					____hasReturned = true -- 4985
					____returnValue = finalizeAgentFailure( -- 4985
						shared, -- 4985
						tostring(e) -- 4985
					) -- 4985
					return -- 4985
				end) -- 4985
			end -- 4985
		) -- 4985
		__TS__Await(____try) -- 4897
		if ____hasReturned then -- 4897
			return ____awaiter_resolve(nil, ____returnValue) -- 4897
		end -- 4897
	end) -- 4897
end -- 4802
function ____exports.runCodingAgent(options, callback) -- 4989
	local ____self_196 = runCodingAgentAsync(options) -- 4989
	____self_196["then"]( -- 4989
		____self_196, -- 4989
		function(____, result) return callback(result) end -- 4990
	) -- 4990
end -- 4989
return ____exports -- 4989