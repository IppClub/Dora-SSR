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
			local toolNames = { -- 1923
				"read_file", -- 1924
				"edit_file", -- 1924
				"delete_file", -- 1924
				"grep_files", -- 1924
				"search_dora_api", -- 1924
				"glob_files", -- 1925
				"build", -- 1925
				"fetch_url", -- 1925
				"execute_command", -- 1925
				"list_sub_agents", -- 1925
				"spawn_sub_agent", -- 1926
				"finish" -- 1926
			} -- 1926
			do -- 1926
				local i = 0 -- 1928
				while i < #toolNames do -- 1928
					local tool = toolNames[i + 1] -- 1929
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1929
						shared.resumeRequiredTool = tool -- 1931
						break -- 1932
					end -- 1932
					i = i + 1 -- 1928
				end -- 1928
			end -- 1928
		end -- 1928
	end -- 1928
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1928
		shared.resumeRequiredTool = nil -- 1938
	end -- 1938
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1938
		shared.resumeRequiredTool = nil -- 1941
	end -- 1941
end -- 1941
function ensureToolCallId(toolCallId) -- 1956
	if toolCallId and toolCallId ~= "" then -- 1956
		return toolCallId -- 1957
	end -- 1957
	return AgentUtils.createLocalToolCallId() -- 1958
end -- 1958
function hasXMLParam(params, name) -- 1991
	return params[name] ~= nil -- 1992
end -- 1992
function inferToolNameFromXMLParams(params) -- 1995
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1995
		return "edit_file" -- 1997
	end -- 1997
	if hasXMLParam(params, "target_file") then -- 1997
		return "delete_file" -- 2000
	end -- 2000
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 2000
		if hasXMLParam(params, "path") then -- 2000
			return "read_file" -- 2003
		end -- 2003
		return nil -- 2004
	end -- 2004
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 2004
		if hasXMLParam(params, "pattern") then -- 2004
			return "search_dora_api" -- 2007
		end -- 2007
		return nil -- 2008
	end -- 2008
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 2008
		if hasXMLParam(params, "pattern") then -- 2008
			return "grep_files" -- 2011
		end -- 2011
		return nil -- 2012
	end -- 2012
	if hasXMLParam(params, "globs") then -- 2012
		if hasXMLParam(params, "pattern") then -- 2012
			return "grep_files" -- 2015
		end -- 2015
		return "glob_files" -- 2016
	end -- 2016
	if hasXMLParam(params, "maxEntries") then -- 2016
		return "glob_files" -- 2019
	end -- 2019
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2019
		return "finish" -- 2022
	end -- 2022
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 2022
		return "spawn_sub_agent" -- 2025
	end -- 2025
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 2025
		return "list_sub_agents" -- 2028
	end -- 2028
	return nil -- 2030
end -- 2030
function parseDSMLAttribute(source, offset, name) -- 2033
	local attrOpen = name .. "=\"" -- 2034
	local attrStart = (string.find( -- 2035
		source, -- 2035
		attrOpen, -- 2035
		math.max(offset + 1, 1), -- 2035
		true -- 2035
	) or 0) - 1 -- 2035
	if attrStart < 0 then -- 2035
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 2036
	end -- 2036
	local valueStart = attrStart + #attrOpen -- 2037
	local valueEnd = (string.find( -- 2038
		source, -- 2038
		"\"", -- 2038
		math.max(valueStart + 1, 1), -- 2038
		true -- 2038
	) or 0) - 1 -- 2038
	if valueEnd < 0 then -- 2038
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 2039
	end -- 2039
	return { -- 2040
		success = true, -- 2041
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 2042
		next = valueEnd + 1 -- 2043
	} -- 2043
end -- 2043
function extractDSMLReason(text, invokeStart, tool) -- 2047
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2048
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2049
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2049
		return before -- 2052
	end -- 2052
	if tool == "finish" then -- 2052
		return "" -- 2053
	end -- 2053
	return "Converted provider-native tool call syntax to XML." -- 2054
end -- 2054
function parseDSMLToolCallObjectFromText(text) -- 2057
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2058
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2059
	if invokeStart < 0 then -- 2059
		return {success = false, message = "missing DSML invoke"} -- 2060
	end -- 2060
	local nameStart = invokeStart + #invokeOpen -- 2061
	local nameEnd = (string.find( -- 2062
		text, -- 2062
		"\"", -- 2062
		math.max(nameStart + 1, 1), -- 2062
		true -- 2062
	) or 0) - 1 -- 2062
	if nameEnd < 0 then -- 2062
		return {success = false, message = "unterminated DSML invoke name"} -- 2063
	end -- 2063
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2064
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2064
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2066
	end -- 2066
	local invokeOpenEnd = (string.find( -- 2068
		text, -- 2068
		">", -- 2068
		math.max(nameEnd + 1, 1), -- 2068
		true -- 2068
	) or 0) - 1 -- 2068
	if invokeOpenEnd < 0 then -- 2068
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2069
	end -- 2069
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2070
	local invokeEnd = (string.find( -- 2071
		text, -- 2071
		invokeClose, -- 2071
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2071
		true -- 2071
	) or 0) - 1 -- 2071
	if invokeEnd < 0 then -- 2071
		return {success = false, message = "missing DSML invoke close tag"} -- 2072
	end -- 2072
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2074
	local params = {} -- 2075
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2076
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2077
	local pos = 0 -- 2078
	while pos < #body do -- 2078
		local start = (string.find( -- 2080
			body, -- 2080
			paramOpen, -- 2080
			math.max(pos + 1, 1), -- 2080
			true -- 2080
		) or 0) - 1 -- 2080
		if start < 0 then -- 2080
			break -- 2081
		end -- 2081
		local openEnd = (string.find( -- 2082
			body, -- 2082
			">", -- 2082
			math.max(start + #paramOpen + 1, 1), -- 2082
			true -- 2082
		) or 0) - 1 -- 2082
		if openEnd < 0 then -- 2082
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2083
		end -- 2083
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2084
		if not name.success then -- 2084
			return name -- 2085
		end -- 2085
		local close = (string.find( -- 2086
			body, -- 2086
			paramClose, -- 2086
			math.max(openEnd + 1 + 1, 1), -- 2086
			true -- 2086
		) or 0) - 1 -- 2086
		if close < 0 then -- 2086
			return {success = false, message = "missing DSML parameter close tag"} -- 2087
		end -- 2087
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2088
		pos = close + #paramClose -- 2089
	end -- 2089
	return { -- 2091
		success = true, -- 2092
		obj = { -- 2093
			tool = toolName, -- 2094
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2095
			params = params -- 2096
		} -- 2096
	} -- 2096
end -- 2096
function parseXMLToolCallObjectFromText(text) -- 2101
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2102
	local rawObj -- 2103
	if children.success then -- 2103
		rawObj = children.obj -- 2105
	else -- 2105
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2107
		if dsml.success then -- 2107
			return dsml -- 2108
		end -- 2108
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2109
		local paramsCloseToken = "</params>" -- 2110
		if toolStart >= 0 then -- 2110
			local paramsClose = (string.find( -- 2112
				text, -- 2112
				paramsCloseToken, -- 2112
				math.max(toolStart + 1, 1), -- 2112
				true -- 2112
			) or 0) - 1 -- 2112
			if paramsClose >= toolStart then -- 2112
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2114
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2115
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2115
					rawObj = bare.obj -- 2117
				end -- 2117
			end -- 2117
		end -- 2117
		if rawObj == nil then -- 2117
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2122
			if paramsOpen < 0 then -- 2122
				return children -- 2123
			end -- 2123
			local paramsCloseOnly = (string.find( -- 2124
				text, -- 2124
				paramsCloseToken, -- 2124
				math.max(paramsOpen + 1, 1), -- 2124
				true -- 2124
			) or 0) - 1 -- 2124
			if paramsCloseOnly < paramsOpen then -- 2124
				return children -- 2125
			end -- 2125
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2126
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2127
			if not paramsOnly.success then -- 2127
				return children -- 2128
			end -- 2128
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2129
			if inferredTool == nil then -- 2129
				return children -- 2130
			end -- 2130
			local ____temp_50 -- 2135
			if inferredTool == "finish" then -- 2135
				____temp_50 = nil -- 2135
			else -- 2135
				____temp_50 = "Inferred tool from XML params." -- 2135
			end -- 2135
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2131
		end -- 2131
	end -- 2131
	if rawObj == nil then -- 2131
		return children -- 2141
	end -- 2141
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2142
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2143
	if not params.success then -- 2143
		return {success = false, message = params.message} -- 2147
	end -- 2147
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2149
end -- 2149
function parseDecisionObject(rawObj) -- 2245
	if type(rawObj.tool) ~= "string" then -- 2245
		return {success = false, message = "missing tool"} -- 2246
	end -- 2246
	local tool = rawObj.tool -- 2247
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2247
		return {success = false, message = "unknown tool: " .. tool} -- 2249
	end -- 2249
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2251
	if tool ~= "finish" and (not reason or reason == "") then -- 2251
		return {success = false, message = tool .. " requires top-level reason"} -- 2255
	end -- 2255
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2257
	return {success = true, tool = tool, params = params, reason = reason} -- 2258
end -- 2258
function getDecisionPath(params) -- 2380
	if type(params.path) == "string" then -- 2380
		return __TS__StringTrim(params.path) -- 2381
	end -- 2381
	if type(params.target_file) == "string" then -- 2381
		return __TS__StringTrim(params.target_file) -- 2382
	end -- 2382
	return "" -- 2383
end -- 2383
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2386
	if enforceFinalTurn == nil then -- 2386
		enforceFinalTurn = false -- 2390
	end -- 2390
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2390
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2393
	end -- 2393
	if not isToolAllowedForRole(shared, tool) then -- 2393
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2396
	end -- 2396
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2396
		local path = getDecisionPath(params) -- 2399
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2399
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2401
		end -- 2401
	end -- 2401
	if tool == "delete_file" then -- 2401
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2405
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2405
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2407
		end -- 2407
	end -- 2407
	return {success = true} -- 2410
end -- 2410
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2413
	local num = __TS__Number(value) -- 2414
	if not __TS__NumberIsFinite(num) then -- 2414
		num = fallback -- 2415
	end -- 2415
	num = math.floor(num) -- 2416
	if num < minValue then -- 2416
		num = minValue -- 2417
	end -- 2417
	if maxValue ~= nil and num > maxValue then -- 2417
		num = maxValue -- 2418
	end -- 2418
	return num -- 2419
end -- 2419
function parseReadLineParam(value, fallback, paramName) -- 2422
	local num = __TS__Number(value) -- 2427
	if not __TS__NumberIsFinite(num) then -- 2427
		num = fallback -- 2428
	end -- 2428
	num = math.floor(num) -- 2429
	if num == 0 then -- 2429
		return {success = false, message = paramName .. " cannot be 0"} -- 2431
	end -- 2431
	return {success = true, value = num} -- 2433
end -- 2433
function validateDecision(tool, params) -- 2436
	if tool == "finish" then -- 2436
		local message = getFinishMessage(params) -- 2441
		if message == "" then -- 2441
			return {success = false, message = "finish requires params.message"} -- 2442
		end -- 2442
		params.message = message -- 2443
		local completion = getCompletionReport(params) -- 2444
		params.outcome = completion.outcome -- 2445
		params.validation = completion.validation -- 2446
		params.knownIssues = completion.knownIssues -- 2447
		params.assumptions = completion.assumptions -- 2448
		params.learningCandidates = completion.learningCandidates -- 2449
		return {success = true, params = params} -- 2450
	end -- 2450
	if tool == "ask_user" then -- 2450
		local normalized = normalizeQuestionnaire(params) -- 2454
		if not normalized.success then -- 2454
			return normalized -- 2455
		end -- 2455
		return {success = true, params = normalized.schema} -- 2456
	end -- 2456
	if tool == "read_file" then -- 2456
		local path = getDecisionPath(params) -- 2460
		if path == "" then -- 2460
			return {success = false, message = "read_file requires path"} -- 2461
		end -- 2461
		params.path = path -- 2462
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2463
		if not startLineRes.success then -- 2463
			return startLineRes -- 2464
		end -- 2464
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2465
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2466
		if not endLineRes.success then -- 2466
			return endLineRes -- 2467
		end -- 2467
		params.startLine = startLineRes.value -- 2468
		params.endLine = endLineRes.value -- 2469
		return {success = true, params = params} -- 2470
	end -- 2470
	if tool == "edit_file" then -- 2470
		local path = getDecisionPath(params) -- 2474
		if path == "" then -- 2474
			return {success = false, message = "edit_file requires path"} -- 2475
		end -- 2475
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2476
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2477
		params.path = path -- 2478
		params.old_str = oldStr -- 2479
		params.new_str = newStr -- 2480
		return {success = true, params = params} -- 2481
	end -- 2481
	if tool == "delete_file" then -- 2481
		local targetFile = getDecisionPath(params) -- 2485
		if targetFile == "" then -- 2485
			return {success = false, message = "delete_file requires target_file"} -- 2486
		end -- 2486
		params.target_file = targetFile -- 2487
		return {success = true, params = params} -- 2488
	end -- 2488
	if tool == "grep_files" then -- 2488
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2492
		if pattern == "" then -- 2492
			return {success = false, message = "grep_files requires pattern"} -- 2493
		end -- 2493
		params.pattern = pattern -- 2494
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2495
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2496
		return {success = true, params = params} -- 2497
	end -- 2497
	if tool == "search_dora_api" then -- 2497
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2501
		if pattern == "" then -- 2501
			return {success = false, message = "search_dora_api requires pattern"} -- 2502
		end -- 2502
		params.pattern = pattern -- 2503
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2504
		return {success = true, params = params} -- 2505
	end -- 2505
	if tool == "glob_files" then -- 2505
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2509
		return {success = true, params = params} -- 2510
	end -- 2510
	if tool == "build" then -- 2510
		local path = getDecisionPath(params) -- 2514
		if path ~= "" then -- 2514
			params.path = path -- 2516
		end -- 2516
		return {success = true, params = params} -- 2518
	end -- 2518
	if tool == "list_sub_agents" then -- 2518
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2522
		if status ~= "" then -- 2522
			params.status = status -- 2524
		end -- 2524
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2526
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2527
		if type(params.query) == "string" then -- 2527
			params.query = __TS__StringTrim(params.query) -- 2529
		end -- 2529
		return {success = true, params = params} -- 2531
	end -- 2531
	if tool == "spawn_sub_agent" then -- 2531
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2535
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2536
		if prompt == "" then -- 2536
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2537
		end -- 2537
		if title == "" then -- 2537
			return {success = false, message = "spawn_sub_agent requires title"} -- 2538
		end -- 2538
		params.prompt = prompt -- 2539
		params.title = title -- 2540
		if type(params.expectedOutput) == "string" then -- 2540
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2542
		end -- 2542
		if isArray(params.filesHint) then -- 2542
			params.filesHint = __TS__ArrayMap( -- 2545
				__TS__ArrayFilter( -- 2545
					params.filesHint, -- 2545
					function(____, item) return type(item) == "string" end -- 2546
				), -- 2546
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2547
			) -- 2547
		end -- 2547
		return {success = true, params = params} -- 2549
	end -- 2549
	return {success = true, params = params} -- 2552
end -- 2552
function validateCompletionForRole(role, tool, params) -- 2555
	if role ~= "sub" or tool ~= "finish" then -- 2555
		return {success = true} -- 2560
	end -- 2560
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2560
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2562
	end -- 2562
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2564
	do -- 2564
		local i = 0 -- 2565
		while i < #requiredArrays do -- 2565
			local name = requiredArrays[i + 1] -- 2566
			if not isArray(params[name]) then -- 2566
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2568
			end -- 2568
			i = i + 1 -- 2565
		end -- 2565
	end -- 2565
	return {success = true} -- 2571
end -- 2571
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2574
	if includeToolDefinitions == nil then -- 2574
		includeToolDefinitions = false -- 2574
	end -- 2574
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2575
	local sections = { -- 2578
		shared.promptPack.agentIdentityPrompt, -- 2579
		rolePrompt, -- 2580
		getReplyLanguageDirective(shared) -- 2581
	} -- 2581
	if shared.role == "main" then -- 2581
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2584
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2585
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2585
			sections[#sections + 1] = table.concat( -- 2587
				{ -- 2587
					"# Current Living Development Plan", -- 2588
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2589
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2589
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2590
						12000 -- 2590
					), -- 2590
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2590
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2591
						12000 -- 2591
					) -- 2591
				}, -- 2591
				"\n\n" -- 2592
			) -- 2592
		end -- 2592
	end -- 2592
	if shared.decisionMode == "tool_calling" then -- 2592
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2596
	end -- 2596
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2598
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2599
	if memoryContext ~= "" then -- 2599
		sections[#sections + 1] = memoryContext -- 2601
	end -- 2601
	local skillsSection = buildSkillsSection(shared) -- 2603
	if skillsSection ~= "" then -- 2603
		sections[#sections + 1] = skillsSection -- 2605
	end -- 2605
	if includeToolDefinitions then -- 2605
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2608
		if shared.decisionMode == "xml" then -- 2608
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2610
		end -- 2610
	end -- 2610
	return table.concat(sections, "\n\n") -- 2613
end -- 2613
function buildSkillsSection(shared) -- 2616
	local ____opt_69 = shared.skills -- 2616
	if not (____opt_69 and ____opt_69.loader) then -- 2616
		return "" -- 2618
	end -- 2618
	return shared.skills.loader:buildSkillsPromptSection() -- 2620
end -- 2620
function sanitizeMessagesForLLMInput(messages) -- 2623
	local sanitized = {} -- 2624
	local droppedAssistantToolCalls = 0 -- 2625
	local droppedToolResults = 0 -- 2626
	do -- 2626
		local i = 0 -- 2627
		while i < #messages do -- 2627
			do -- 2627
				local message = messages[i + 1] -- 2628
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2628
					local requiredIds = {} -- 2630
					do -- 2630
						local j = 0 -- 2631
						while j < #message.tool_calls do -- 2631
							local toolCall = message.tool_calls[j + 1] -- 2632
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2633
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2633
								requiredIds[#requiredIds + 1] = id -- 2635
							end -- 2635
							j = j + 1 -- 2631
						end -- 2631
					end -- 2631
					if #requiredIds == 0 then -- 2631
						sanitized[#sanitized + 1] = message -- 2639
						goto __continue453 -- 2640
					end -- 2640
					local matchedIds = {} -- 2642
					local matchedTools = {} -- 2643
					local j = i + 1 -- 2644
					while j < #messages do -- 2644
						local toolMessage = messages[j + 1] -- 2646
						if toolMessage.role ~= "tool" then -- 2646
							break -- 2647
						end -- 2647
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2648
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2648
							matchedIds[toolCallId] = true -- 2650
							matchedTools[#matchedTools + 1] = toolMessage -- 2651
						else -- 2651
							droppedToolResults = droppedToolResults + 1 -- 2653
						end -- 2653
						j = j + 1 -- 2655
					end -- 2655
					local complete = true -- 2657
					do -- 2657
						local j = 0 -- 2658
						while j < #requiredIds do -- 2658
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2658
								complete = false -- 2660
								break -- 2661
							end -- 2661
							j = j + 1 -- 2658
						end -- 2658
					end -- 2658
					if complete then -- 2658
						__TS__ArrayPush( -- 2665
							sanitized, -- 2665
							message, -- 2665
							table.unpack(matchedTools) -- 2665
						) -- 2665
					else -- 2665
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2667
						droppedToolResults = droppedToolResults + #matchedTools -- 2668
					end -- 2668
					i = j - 1 -- 2670
					goto __continue453 -- 2671
				end -- 2671
				if message.role == "tool" then -- 2671
					droppedToolResults = droppedToolResults + 1 -- 2674
					goto __continue453 -- 2675
				end -- 2675
				sanitized[#sanitized + 1] = message -- 2677
			end -- 2677
			::__continue453:: -- 2677
			i = i + 1 -- 2627
		end -- 2627
	end -- 2627
	return sanitized -- 2679
end -- 2679
function getUnconsolidatedMessages(shared) -- 2682
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2683
end -- 2683
function isFinalDecisionTurn(shared) -- 2688
	return shared.agentStepCount + 1 >= shared.maxSteps -- 2689
end -- 2689
function getFinalDecisionTurnPrompt(shared) -- 2692
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2693
end -- 2693
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2698
	if attempt == nil then -- 2698
		attempt = 1 -- 2701
	end -- 2701
	if decisionMode == nil then -- 2701
		decisionMode = shared.decisionMode -- 2703
	end -- 2703
	if consumeResumeCheckpoint == nil then -- 2703
		consumeResumeCheckpoint = true -- 2704
	end -- 2704
	if pendingUserPrompt == nil then -- 2704
		pendingUserPrompt = "" -- 2705
	end -- 2705
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2707
	local tailSections = {} -- 2708
	if shared.resumeCheckpointPending == true then -- 2708
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2714
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2718
	end -- 2718
	if shared.truncatedToolOverwritePath ~= nil then -- 2718
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2721
	end -- 2721
	if consumeResumeCheckpoint then -- 2721
		shared.resumeCheckpointPending = false -- 2723
	end -- 2723
	local messages = { -- 2724
		{role = "system", content = systemPrompt}, -- 2725
		table.unpack(getUnconsolidatedMessages(shared)) -- 2726
	} -- 2726
	if pendingUserPrompt ~= "" then -- 2726
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2729
	end -- 2729
	if isFinalDecisionTurn(shared) then -- 2729
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2732
	end -- 2732
	if lastError and lastError ~= "" then -- 2732
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2735
		if decisionMode == "xml" then -- 2735
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2739
		end -- 2739
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2739
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2742
		end -- 2742
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2742
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2745
		end -- 2745
		messages[#messages + 1] = { -- 2747
			role = "user", -- 2748
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2749
		} -- 2749
	end -- 2749
	if #tailSections > 0 then -- 2749
		messages[#messages + 1] = { -- 2757
			role = "user", -- 2758
			content = table.concat(tailSections, "\n\n") -- 2759
		} -- 2759
	end -- 2759
	return messages -- 2762
end -- 2762
function buildXmlDecisionInstruction(shared, feedback) -- 2765
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2766
end -- 2766
function tryParseAndValidateDecision(rawText, shared) -- 2834
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2835
	if not parsed.success then -- 2835
		return {success = false, message = parsed.message, raw = rawText} -- 2837
	end -- 2837
	local decision = parseDecisionObject(parsed.obj) -- 2839
	if not decision.success then -- 2839
		return {success = false, message = decision.message, raw = rawText} -- 2841
	end -- 2841
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2843
	if not completionValidation.success then -- 2843
		return {success = false, message = completionValidation.message, raw = rawText} -- 2845
	end -- 2845
	local validation = validateDecision(decision.tool, decision.params) -- 2847
	if not validation.success then -- 2847
		return {success = false, message = validation.message, raw = rawText} -- 2849
	end -- 2849
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2851
	if not sharedValidation.success then -- 2851
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2853
	end -- 2853
	decision.params = validation.params -- 2855
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2856
	return decision -- 2857
end -- 2857
function executeToolAction(shared, action) -- 4028
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4028
		if shared.stopToken.stopped then -- 4028
			return ____awaiter_resolve( -- 4028
				nil, -- 4028
				{ -- 4030
					success = false, -- 4030
					message = getCancelledReason(shared) -- 4030
				} -- 4030
			) -- 4030
		end -- 4030
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4030
			shared.resumeRequiredTool = nil -- 4033
			shared.resumeCheckpointPending = false -- 4034
		end -- 4034
		local params = action.params -- 4036
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4037
		if not sharedValidation.success then -- 4037
			return ____awaiter_resolve(nil, sharedValidation) -- 4037
		end -- 4037
		if action.tool == "read_file" then -- 4037
			local ____params_startLine_149 = params.startLine -- 4040
			if ____params_startLine_149 == nil then -- 4040
				____params_startLine_149 = 1 -- 4040
			end -- 4040
			local startLine = __TS__Number(____params_startLine_149) -- 4040
			local ____params_endLine_150 = params.endLine -- 4041
			if ____params_endLine_150 == nil then -- 4041
				____params_endLine_150 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4041
			end -- 4041
			local endLine = __TS__Number(____params_endLine_150) -- 4041
			local clippedAfterCompression = false -- 4042
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4042
				endLine = startLine + 159 -- 4049
				clippedAfterCompression = true -- 4050
			end -- 4050
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4052
			if __TS__StringTrim(path) == "" then -- 4052
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4052
			end -- 4052
			local result = Tools.readFile( -- 4056
				shared.workingDir, -- 4057
				path, -- 4058
				startLine, -- 4059
				endLine, -- 4060
				shared.useChineseResponse and "zh" or "en" -- 4061
			) -- 4061
			if clippedAfterCompression and result.success == true then -- 4061
				result.clipped = true -- 4064
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4065
			end -- 4065
			return ____awaiter_resolve(nil, result) -- 4065
		end -- 4065
		if action.tool == "grep_files" then -- 4065
			local searchPath = params.path or "" -- 4072
			local searchGlobs = params.globs -- 4073
			local ____Tools_searchFiles_164 = Tools.searchFiles -- 4074
			local ____shared_workingDir_157 = shared.workingDir -- 4075
			local ____temp_158 = params.pattern or "" -- 4077
			local ____params_globs_159 = params.globs -- 4078
			local ____params_useRegex_160 = params.useRegex -- 4079
			local ____params_caseSensitive_161 = params.caseSensitive -- 4080
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4082
			local ____math_max_153 = math.max -- 4083
			local ____math_floor_152 = math.floor -- 4083
			local ____params_limit_151 = params.limit -- 4083
			if ____params_limit_151 == nil then -- 4083
				____params_limit_151 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4083
			end -- 4083
			local ____math_max_153_result_163 = ____math_max_153( -- 4083
				1, -- 4083
				____math_floor_152(__TS__Number(____params_limit_151)) -- 4083
			) -- 4083
			local ____math_max_156 = math.max -- 4084
			local ____math_floor_155 = math.floor -- 4084
			local ____params_offset_154 = params.offset -- 4084
			if ____params_offset_154 == nil then -- 4084
				____params_offset_154 = 0 -- 4084
			end -- 4084
			local result = __TS__Await(____Tools_searchFiles_164({ -- 4074
				workDir = ____shared_workingDir_157, -- 4075
				path = searchPath, -- 4076
				pattern = ____temp_158, -- 4077
				globs = ____params_globs_159, -- 4078
				useRegex = ____params_useRegex_160, -- 4079
				caseSensitive = ____params_caseSensitive_161, -- 4080
				includeContent = true, -- 4081
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162, -- 4082
				limit = ____math_max_153_result_163, -- 4083
				offset = ____math_max_156( -- 4084
					0, -- 4084
					____math_floor_155(__TS__Number(____params_offset_154)) -- 4084
				), -- 4084
				groupByFile = params.groupByFile == true -- 4085
			})) -- 4085
			return ____awaiter_resolve(nil, result) -- 4085
		end -- 4085
		if action.tool == "search_dora_api" then -- 4085
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4090
			local ____Tools_searchDoraAPI_173 = Tools.searchDoraAPI -- 4091
			local ____temp_169 = params.pattern or "" -- 4092
			local ____temp_170 = params.docSource or "api" -- 4093
			local ____temp_171 = shared.useChineseResponse and "zh" or "en" -- 4094
			local ____temp_172 = params.programmingLanguage or "ts" -- 4095
			local ____math_min_168 = math.min -- 4096
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4096
			local ____math_max_166 = math.max -- 4096
			local ____params_limit_165 = params.limit -- 4096
			if ____params_limit_165 == nil then -- 4096
				____params_limit_165 = 8 -- 4096
			end -- 4096
			local result = __TS__Await(____Tools_searchDoraAPI_173({ -- 4091
				pattern = ____temp_169, -- 4092
				docSource = ____temp_170, -- 4093
				docLanguage = ____temp_171, -- 4094
				programmingLanguage = ____temp_172, -- 4095
				limit = ____math_min_168( -- 4096
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167, -- 4096
					____math_max_166( -- 4096
						1, -- 4096
						__TS__Number(____params_limit_165) -- 4096
					) -- 4096
				), -- 4096
				useRegex = params.useRegex, -- 4097
				caseSensitive = false, -- 4098
				includeContent = true, -- 4099
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4100
			})) -- 4100
			return ____awaiter_resolve(nil, result) -- 4100
		end -- 4100
		if action.tool == "glob_files" then -- 4100
			local ____Tools_listFiles_180 = Tools.listFiles -- 4105
			local ____shared_workingDir_177 = shared.workingDir -- 4106
			local ____temp_178 = params.path or "" -- 4107
			local ____params_globs_179 = params.globs -- 4108
			local ____math_max_176 = math.max -- 4109
			local ____math_floor_175 = math.floor -- 4109
			local ____params_maxEntries_174 = params.maxEntries -- 4109
			if ____params_maxEntries_174 == nil then -- 4109
				____params_maxEntries_174 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4109
			end -- 4109
			local result = ____Tools_listFiles_180({ -- 4105
				workDir = ____shared_workingDir_177, -- 4106
				path = ____temp_178, -- 4107
				globs = ____params_globs_179, -- 4108
				maxEntries = ____math_max_176( -- 4109
					1, -- 4109
					____math_floor_175(__TS__Number(____params_maxEntries_174)) -- 4109
				) -- 4109
			}) -- 4109
			return ____awaiter_resolve(nil, result) -- 4109
		end -- 4109
		if action.tool == "ask_user" then -- 4109
			if not shared.publishQuestionnaire then -- 4109
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4109
			end -- 4109
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4109
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4109
			end -- 4109
			local normalized = normalizeQuestionnaire(params) -- 4116
			if not normalized.success then -- 4116
				return ____awaiter_resolve(nil, normalized) -- 4116
			end -- 4116
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4118
			if not result.success then -- 4118
				return ____awaiter_resolve(nil, result) -- 4118
			end -- 4118
			shared.waitingQuestionnaireId = result.questionnaireId -- 4125
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4125
		end -- 4125
		if action.tool == "delete_file" then -- 4125
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4129
			if __TS__StringTrim(targetFile) == "" then -- 4129
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4129
			end -- 4129
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4133
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4134
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4134
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4134
			end -- 4134
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4138
			local result = Tools.deleteFile(shared.taskId, shared.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4139
			if not result.success then -- 4139
				return ____awaiter_resolve(nil, result) -- 4139
			end -- 4139
			if not isInternalDocumentEdit then -- 4139
				shared.unbuiltEdits = true -- 4147
				shared.lastBuildSucceeded = false -- 4148
				if shared.failedTestNeedsBuild == true then -- 4148
					shared.failedTestHasSourceEdit = true -- 4149
				end -- 4149
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4149
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4150
				end -- 4150
				shared.editedPathsSinceBuild = editedPaths -- 4151
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4152
			end -- 4152
			local ____result_checkpointed_182 = result.checkpointed -- 4158
			local ____result_reversible_183 = result.reversible -- 4159
			local ____result_binary_184 = result.binary -- 4160
			local ____temp_185 = result.checkpointed and result.checkpointId or nil -- 4161
			local ____temp_186 = result.checkpointed and result.checkpointSeq or nil -- 4162
			local ____result_checkpointed_181 -- 4163
			if result.checkpointed then -- 4163
				____result_checkpointed_181 = nil -- 4163
			else -- 4163
				____result_checkpointed_181 = result.message -- 4163
			end -- 4163
			return ____awaiter_resolve(nil, { -- 4163
				success = true, -- 4155
				changed = true, -- 4156
				mode = "delete", -- 4157
				checkpointed = ____result_checkpointed_182, -- 4158
				reversible = ____result_reversible_183, -- 4159
				binary = ____result_binary_184, -- 4160
				checkpointId = ____temp_185, -- 4161
				checkpointSeq = ____temp_186, -- 4162
				message = ____result_checkpointed_181, -- 4163
				files = {{path = targetFile, op = "delete"}} -- 4164
			}) -- 4164
		end -- 4164
		if action.tool == "build" then -- 4164
			local buildPath = params.path or "" -- 4168
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4169
			shared.unbuiltEdits = false -- 4173
			shared.editsSinceBuild = 0 -- 4174
			shared.editedPathsSinceBuild = {} -- 4175
			shared.hasBuilt = true -- 4176
			shared.lastBuildSucceeded = result.success -- 4177
			if result.success and shared.freshProjectBuildPending == true then -- 4177
				shared.freshProjectBuildPending = false -- 4183
			end -- 4183
			shared.apiSearchesSinceBuild = 0 -- 4185
			shared.buildRepairPending = false -- 4186
			if not result.success and result.messages ~= nil then -- 4186
				do -- 4186
					local i = 0 -- 4188
					while i < #result.messages do -- 4188
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4188
							shared.buildRepairPending = true -- 4190
							break -- 4191
						end -- 4191
						i = i + 1 -- 4188
					end -- 4188
				end -- 4188
			end -- 4188
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4188
				shared.failedTestNeedsBuild = false -- 4196
				shared.failedTestHasSourceEdit = false -- 4197
			end -- 4197
			return ____awaiter_resolve(nil, result) -- 4197
		end -- 4197
		if action.tool == "fetch_url" then -- 4197
			local result = __TS__Await(Tools.fetchUrl({ -- 4202
				workDir = shared.workingDir, -- 4203
				url = type(params.url) == "string" and params.url or "", -- 4204
				target = type(params.target) == "string" and params.target or "", -- 4205
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4206
				onProgress = function(____, progress) -- 4207
					emitAgentEvent( -- 4208
						shared, -- 4208
						{ -- 4208
							type = "tool_progress", -- 4209
							sessionId = shared.sessionId, -- 4210
							taskId = shared.taskId, -- 4211
							step = action.step, -- 4212
							tool = action.tool, -- 4213
							result = __TS__ObjectAssign({success = false}, progress) -- 4214
						} -- 4214
					) -- 4214
				end -- 4207
			})) -- 4207
			return ____awaiter_resolve(nil, result) -- 4207
		end -- 4207
		if action.tool == "execute_command" then -- 4207
			local mode = type(params.mode) == "string" and params.mode or "" -- 4224
			local result = __TS__Await(Tools.executeCommand({ -- 4225
				workDir = shared.workingDir, -- 4226
				mode = mode, -- 4227
				code = type(params.code) == "string" and params.code or nil, -- 4228
				command = type(params.command) == "string" and params.command or nil, -- 4229
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4230
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4231
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4232
				onProgress = function(____, progress) -- 4233
					emitAgentEvent( -- 4234
						shared, -- 4234
						{ -- 4234
							type = "tool_progress", -- 4235
							sessionId = shared.sessionId, -- 4236
							taskId = shared.taskId, -- 4237
							step = action.step, -- 4238
							tool = action.tool, -- 4239
							result = __TS__ObjectAssign({success = false}, progress) -- 4240
						} -- 4240
					) -- 4240
				end -- 4233
			})) -- 4233
			if result.success and mode == "lua" then -- 4233
				local deterministicFailure = false -- 4248
				local deterministicPass = false -- 4249
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4250
				do -- 4250
					local i = 0 -- 4251
					while i < #outputLines and not deterministicFailure do -- 4251
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4252
						if line == "passed" then -- 4252
							deterministicPass = true -- 4253
						end -- 4253
						if line == "failed" then -- 4253
							deterministicFailure = true -- 4255
							break -- 4256
						end -- 4256
						local searchFrom = 0 -- 4258
						while searchFrom < #line do -- 4258
							local failedIndex = (string.find( -- 4260
								line, -- 4260
								"failed", -- 4260
								math.max(searchFrom + 1, 1), -- 4260
								true -- 4260
							) or 0) - 1 -- 4260
							if failedIndex < 0 then -- 4260
								break -- 4261
							end -- 4261
							local after = failedIndex + #"failed" -- 4262
							while after < #line do -- 4262
								local ch = __TS__StringSlice(line, after, after + 1) -- 4264
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4264
									break -- 4265
								end -- 4265
								after = after + 1 -- 4266
							end -- 4266
							local afterEnd = after -- 4268
							while afterEnd < #line do -- 4268
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4270
								if ch < "0" or ch > "9" then -- 4270
									break -- 4271
								end -- 4271
								afterEnd = afterEnd + 1 -- 4272
							end -- 4272
							local count -- 4274
							if afterEnd > after then -- 4274
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4276
							else -- 4276
								local before = failedIndex - 1 -- 4278
								while before >= 0 do -- 4278
									local ch = __TS__StringSlice(line, before, before + 1) -- 4280
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4280
										break -- 4281
									end -- 4281
									before = before - 1 -- 4282
								end -- 4282
								local beforeEnd = before + 1 -- 4284
								while before >= 0 do -- 4284
									local ch = __TS__StringSlice(line, before, before + 1) -- 4286
									if ch < "0" or ch > "9" then -- 4286
										break -- 4287
									end -- 4287
									before = before - 1 -- 4288
								end -- 4288
								if beforeEnd > before + 1 then -- 4288
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4290
								end -- 4290
							end -- 4290
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4290
								deterministicFailure = true -- 4293
								break -- 4294
							end -- 4294
							searchFrom = failedIndex + #"failed" -- 4296
						end -- 4296
						i = i + 1 -- 4251
					end -- 4251
				end -- 4251
				if deterministicFailure then -- 4251
					shared.failedTestNeedsBuild = true -- 4300
					shared.failedTestHasSourceEdit = false -- 4301
				elseif deterministicPass then -- 4301
					shared.failedTestNeedsBuild = false -- 4303
					shared.failedTestHasSourceEdit = false -- 4304
				end -- 4304
			end -- 4304
			return ____awaiter_resolve(nil, result) -- 4304
		end -- 4304
		if action.tool == "spawn_sub_agent" then -- 4304
			if not shared.spawnSubAgent then -- 4304
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4304
			end -- 4304
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4304
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4304
			end -- 4304
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4316
				params.filesHint, -- 4317
				function(____, item) return type(item) == "string" end -- 4317
			) or nil -- 4317
			local result = __TS__Await(shared.spawnSubAgent({ -- 4319
				parentSessionId = shared.sessionId, -- 4320
				projectRoot = shared.workingDir, -- 4321
				title = type(params.title) == "string" and params.title or "Sub", -- 4322
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4323
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4324
				filesHint = filesHint, -- 4325
				disabledAgentTools = shared.disabledAgentTools -- 4326
			})) -- 4326
			if not result.success then -- 4326
				return ____awaiter_resolve(nil, result) -- 4326
			end -- 4326
			shared.hasSpawnedSubAgentThisTask = true -- 4331
			return ____awaiter_resolve(nil, { -- 4331
				success = true, -- 4333
				sessionId = result.sessionId, -- 4334
				taskId = result.taskId, -- 4335
				title = result.title, -- 4336
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4337
			}) -- 4337
		end -- 4337
		if action.tool == "list_sub_agents" then -- 4337
			if not shared.listSubAgents then -- 4337
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4337
			end -- 4337
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4337
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4337
			end -- 4337
			local result = __TS__Await(shared.listSubAgents({ -- 4347
				sessionId = shared.sessionId, -- 4348
				projectRoot = shared.workingDir, -- 4349
				status = type(params.status) == "string" and params.status or nil, -- 4350
				limit = type(params.limit) == "number" and params.limit or nil, -- 4351
				offset = type(params.offset) == "number" and params.offset or nil, -- 4352
				query = type(params.query) == "string" and params.query or nil -- 4353
			})) -- 4353
			return ____awaiter_resolve(nil, result) -- 4353
		end -- 4353
		if action.tool == "edit_file" then -- 4353
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4358
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4361
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4362
			if __TS__StringTrim(path) == "" then -- 4362
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4362
			end -- 4362
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4364
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4365
			if not isInternalDocumentEdit then -- 4365
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4367
				if preflightIssue ~= nil then -- 4367
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4369
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4370
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4370
				end -- 4370
			end -- 4370
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4376
			local result = __TS__Await(actionNode:exec({ -- 4377
				path = path, -- 4378
				oldStr = oldStr, -- 4379
				newStr = newStr, -- 4380
				taskId = shared.taskId, -- 4381
				workDir = shared.workingDir -- 4382
			})) -- 4382
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4382
				if params.partialStreamRecovery ~= true then -- 4382
					shared.truncatedToolOverwritePath = nil -- 4386
				end -- 4386
				shared.unbuiltEdits = true -- 4388
				shared.lastBuildSucceeded = false -- 4389
				if shared.failedTestNeedsBuild == true then -- 4389
					shared.failedTestHasSourceEdit = true -- 4390
				end -- 4390
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4391
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4391
					editedPaths[#editedPaths + 1] = normalizedPath -- 4392
				end -- 4392
				shared.editedPathsSinceBuild = editedPaths -- 4393
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4394
			end -- 4394
			return ____awaiter_resolve(nil, result) -- 4394
		end -- 4394
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4394
	end) -- 4394
end -- 4394
function sanitizeToolActionResultForHistory(action, result) -- 4401
	if action.tool == "read_file" then -- 4401
		return sanitizeReadResultForHistory(action.tool, result) -- 4403
	end -- 4403
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4403
		return sanitizeSearchResultForHistory(action.tool, result) -- 4406
	end -- 4406
	if action.tool == "glob_files" then -- 4406
		return sanitizeListFilesResultForHistory(result) -- 4409
	end -- 4409
	if action.tool == "build" then -- 4409
		return sanitizeBuildResultForHistory(result) -- 4412
	end -- 4412
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4412
		if result.success ~= true then -- 4412
			return result -- 4415
		end -- 4415
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4415
			return result -- 4416
		end -- 4416
		if isArray(result.fileContext) then -- 4416
			return result -- 4417
		end -- 4417
		local contextLimits = { -- 4419
			fullContentChars = 12000, -- 4420
			previewChars = 4000, -- 4421
			diffChars = 8000, -- 4422
			totalChars = 24000, -- 4423
			maxFiles = 8 -- 4424
		} -- 4424
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4426
			if maxChars <= 0 then -- 4426
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4427
			end -- 4427
			if #sourceText <= maxChars then -- 4427
				return sourceText -- 4428
			end -- 4428
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4429
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4430
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4431
		end -- 4426
		local function countLines(sourceText) -- 4433
			if sourceText == "" then -- 4433
				return 0 -- 4434
			end -- 4434
			return #__TS__StringSplit(sourceText, "\n") -- 4435
		end -- 4433
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4437
			if beforeContent == afterContent then -- 4437
				return "" -- 4438
			end -- 4438
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4439
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4440
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4442
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4442
				firstChangedLine = firstChangedLine + 1 -- 4448
			end -- 4448
			local lastChangedBeforeLine = #beforeLines - 1 -- 4450
			local lastChangedAfterLine = #afterLines - 1 -- 4451
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4451
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4457
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4458
			end -- 4458
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4460
			local previewEndLine = math.max( -- 4461
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4462
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4463
			) -- 4463
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4465
			do -- 4465
				local lineIndex = previewStartLine -- 4466
				while lineIndex <= previewEndLine do -- 4466
					do -- 4466
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4467
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4468
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4469
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4470
						if not beforeChanged and not afterChanged then -- 4470
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4472
							if contextLine ~= nil then -- 4472
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4473
							end -- 4473
							goto __continue733 -- 4474
						end -- 4474
						if beforeChanged and beforeLine ~= nil then -- 4474
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4476
						end -- 4476
						if afterChanged and afterLine ~= nil then -- 4476
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4477
						end -- 4477
					end -- 4477
					::__continue733:: -- 4477
					lineIndex = lineIndex + 1 -- 4466
				end -- 4466
			end -- 4466
			return truncateContextSnippet( -- 4479
				table.concat(unifiedDiffLines, "\n"), -- 4479
				maxChars, -- 4479
				"diff" -- 4479
			) -- 4479
		end -- 4437
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4482
		if not checkpointDiff.success then -- 4482
			return result -- 4483
		end -- 4483
		local remainingContextBudget = contextLimits.totalChars -- 4484
		local fileContextItems = {} -- 4485
		local changedFiles = checkpointDiff.files -- 4486
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4487
		do -- 4487
			local fileIndex = 0 -- 4488
			while fileIndex < maxContextFiles do -- 4488
				if remainingContextBudget <= 0 then -- 4488
					break -- 4489
				end -- 4489
				local changedFile = changedFiles[fileIndex + 1] -- 4490
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4491
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4492
				local contextItem = { -- 4493
					path = changedFile.path, -- 4494
					op = changedFile.op, -- 4495
					checkpointId = result.checkpointId, -- 4496
					checkpointSeq = result.checkpointSeq, -- 4497
					beforeExists = changedFile.beforeExists, -- 4498
					afterExists = changedFile.afterExists, -- 4499
					beforeBytes = #beforeContent, -- 4500
					afterBytes = #afterContent, -- 4501
					diffPreview = "", -- 4502
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4503
					contentTruncated = false, -- 4504
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4505
				} -- 4505
				if changedFile.afterExists then -- 4505
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4505
						contextItem.afterContent = afterContent -- 4509
						remainingContextBudget = remainingContextBudget - #afterContent -- 4510
					else -- 4510
						contextItem.afterContentPreview = truncateContextSnippet( -- 4512
							afterContent, -- 4513
							math.min( -- 4514
								contextLimits.previewChars, -- 4514
								math.max(400, remainingContextBudget) -- 4514
							), -- 4514
							"afterContent" -- 4515
						) -- 4515
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4517
						contextItem.contentTruncated = true -- 4518
					end -- 4518
				end -- 4518
				local diffPreview = buildUnifiedDiffPreview( -- 4521
					changedFile.path, -- 4522
					beforeContent, -- 4523
					afterContent, -- 4524
					math.min( -- 4525
						contextLimits.diffChars, -- 4525
						math.max(400, remainingContextBudget) -- 4525
					) -- 4525
				) -- 4525
				contextItem.diffPreview = diffPreview -- 4527
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4528
				if not changedFile.afterExists and beforeContent ~= "" then -- 4528
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4530
						beforeContent, -- 4531
						math.min( -- 4532
							contextLimits.previewChars, -- 4532
							math.max(400, remainingContextBudget) -- 4532
						), -- 4532
						"beforeContent" -- 4533
					) -- 4533
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4535
					if #beforeContent > contextLimits.previewChars then -- 4535
						contextItem.contentTruncated = true -- 4536
					end -- 4536
				end -- 4536
				fileContextItems[#fileContextItems + 1] = contextItem -- 4538
				fileIndex = fileIndex + 1 -- 4488
			end -- 4488
		end -- 4488
		if #fileContextItems == 0 then -- 4488
			return result -- 4540
		end -- 4540
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4541
	end -- 4541
	return result -- 4548
end -- 4548
function emitAgentTaskFinishEvent(shared, success, message) -- 4749
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4750
	local result = success and ({ -- 4754
		success = true, -- 4756
		taskId = shared.taskId, -- 4757
		message = message, -- 4758
		steps = shared.step, -- 4759
		completion = completion -- 4760
	}) or ({ -- 4760
		success = false, -- 4763
		taskId = shared.taskId, -- 4764
		message = message, -- 4765
		steps = shared.step, -- 4766
		completion = completion -- 4767
	}) -- 4767
	emitAgentEvent(shared, { -- 4769
		type = "task_finished", -- 4770
		sessionId = shared.sessionId, -- 4771
		taskId = shared.taskId, -- 4772
		success = result.success, -- 4773
		message = result.message, -- 4774
		steps = result.steps, -- 4775
		completion = result.completion -- 4776
	}) -- 4776
	return result -- 4778
end -- 4778
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
	Tools.sendWebIDEFileUpdate(path, true, content) -- 750
	return true -- 751
end -- 745
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
local function appendConversationMessage(shared, message) -- 1945
	local ____shared_messages_49 = shared.messages -- 1945
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1946
		{}, -- 1946
		message, -- 1947
		{ -- 1946
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1948
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1949
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1950
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1951
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1952
		} -- 1952
	) -- 1952
end -- 1945
local function appendToolResultMessage(shared, action) -- 1961
	appendConversationMessage( -- 1962
		shared, -- 1962
		{ -- 1962
			role = "tool", -- 1963
			tool_call_id = action.toolCallId, -- 1964
			name = action.tool, -- 1965
			content = action.result and toJson(action.result, false) or "" -- 1966
		} -- 1966
	) -- 1966
end -- 1961
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1970
	appendConversationMessage( -- 1976
		shared, -- 1976
		{ -- 1976
			role = "assistant", -- 1977
			content = content or "", -- 1978
			reasoning_content = reasoningContent, -- 1979
			tool_calls = __TS__ArrayMap( -- 1980
				actions, -- 1980
				function(____, action) return { -- 1980
					id = action.toolCallId, -- 1981
					type = "function", -- 1982
					["function"] = { -- 1983
						name = action.tool, -- 1984
						arguments = toJson(action.params, false) -- 1985
					} -- 1985
				} end -- 1985
			) -- 1985
		} -- 1985
	) -- 1985
end -- 1970
local function llm(shared, messages, phase) -- 2169
	if phase == nil then -- 2169
		phase = "decision_xml" -- 2172
	end -- 2172
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2172
		local stepId = shared.step + 1 -- 2174
		emitLLMContextMetrics( -- 2175
			shared, -- 2175
			stepId, -- 2175
			phase, -- 2175
			messages, -- 2175
			shared.llmOptions -- 2175
		) -- 2175
		saveStepLLMDebugInput( -- 2176
			shared, -- 2176
			stepId, -- 2176
			phase, -- 2176
			messages, -- 2176
			shared.llmOptions -- 2176
		) -- 2176
		local lastStreamReasoning = "" -- 2177
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2178
			messages, -- 2179
			shared.llmOptions, -- 2180
			shared.stopToken, -- 2181
			shared.llmConfig, -- 2182
			function(response) -- 2183
				local ____opt_53 = response.choices -- 2183
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2183
				local streamMessage = ____opt_51 and ____opt_51.message -- 2184
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2185
				if nextContent == "" then -- 2185
					return -- 2188
				end -- 2188
				if nextContent == lastStreamReasoning then -- 2188
					return -- 2189
				end -- 2189
				lastStreamReasoning = nextContent -- 2190
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2191
			end -- 2183
		)) -- 2183
		if res.success then -- 2183
			local usage = res.tokenUsage -- 2195
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2196
			local ____opt_59 = res.response.choices -- 2196
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2196
			local message = ____opt_57 and ____opt_57.message -- 2197
			local text = message and message.content -- 2198
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2199
			if text then -- 2199
				local parsed = tryParseAndValidateDecision(text, shared) -- 2203
				if parsed.success then -- 2203
					local reason = parsed.reason or "" -- 2205
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2206
				end -- 2206
				saveStepLLMDebugOutput( -- 2208
					shared, -- 2208
					stepId, -- 2208
					phase, -- 2208
					text, -- 2208
					{success = true, usage = usage} -- 2208
				) -- 2208
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2208
			else -- 2208
				saveStepLLMDebugOutput( -- 2211
					shared, -- 2211
					stepId, -- 2211
					phase, -- 2211
					"empty LLM response", -- 2211
					{success = false, usage = usage} -- 2211
				) -- 2211
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2211
			end -- 2211
		else -- 2211
			local usage = res.tokenUsage -- 2215
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2216
			saveStepLLMDebugOutput( -- 2217
				shared, -- 2217
				stepId, -- 2217
				phase, -- 2217
				res.raw or res.message, -- 2217
				{success = false, usage = usage} -- 2217
			) -- 2217
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2217
		end -- 2217
	end) -- 2217
end -- 2169
local function isDecisionBatchSuccess(result) -- 2241
	return result.kind == "batch" -- 2242
end -- 2241
local function parseDecisionToolCall(functionName, rawObj) -- 2266
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2266
		return {success = false, message = "unknown tool: " .. functionName} -- 2268
	end -- 2268
	if rawObj == nil then -- 2268
		return {success = true, tool = functionName, params = {}} -- 2271
	end -- 2271
	if not isRecord(rawObj) then -- 2271
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2274
	end -- 2274
	return {success = true, tool = functionName, params = rawObj} -- 2276
end -- 2266
local function parseToolCallArguments(functionName, argsText) -- 2283
	local trimmedArgs = __TS__StringTrim(argsText) -- 2284
	if trimmedArgs == "" then -- 2284
		return {} -- 2286
	end -- 2286
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2288
	if err ~= nil or rawObj == nil then -- 2288
		return { -- 2290
			success = false, -- 2291
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2292
			raw = argsText -- 2293
		} -- 2293
	end -- 2293
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2296
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2296
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2298
	end -- 2298
	return rawObj -- 2304
end -- 2283
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2307
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2315
	if isRecord(rawArgs) and rawArgs.success == false then -- 2315
		return rawArgs -- 2317
	end -- 2317
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2319
	if not decision.success then -- 2319
		return {success = false, message = decision.message, raw = argsText} -- 2321
	end -- 2321
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2327
	if not completionValidation.success then -- 2327
		return {success = false, message = completionValidation.message, raw = argsText} -- 2329
	end -- 2329
	local validation = validateDecision(decision.tool, decision.params) -- 2335
	if not validation.success then -- 2335
		return {success = false, message = validation.message, raw = argsText} -- 2337
	end -- 2337
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2343
	if not sharedValidation.success then -- 2343
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2345
	end -- 2345
	decision.params = validation.params -- 2351
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2352
	decision.reason = reason -- 2353
	decision.reasoningContent = reasoningContent -- 2354
	return decision -- 2355
end -- 2307
local function createPreExecutableActionFromStream(shared, toolCall) -- 2358
	local ____opt_65 = toolCall["function"] -- 2358
	local functionName = ____opt_65 and ____opt_65.name -- 2359
	local ____opt_67 = toolCall["function"] -- 2359
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2360
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2361
	if not functionName or not toolCallId then -- 2361
		return nil -- 2362
	end -- 2362
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2363
	if isRecord(rawArgs) and rawArgs.success == false then -- 2363
		return nil -- 2364
	end -- 2364
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2365
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2365
		return nil -- 2366
	end -- 2366
	local validation = validateDecision(decision.tool, decision.params) -- 2367
	if not validation.success then -- 2367
		return nil -- 2368
	end -- 2368
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2368
		return nil -- 2369
	end -- 2369
	return { -- 2370
		step = shared.step + 1, -- 2371
		toolCallId = toolCallId, -- 2372
		tool = decision.tool, -- 2373
		reason = "", -- 2374
		params = validation.params, -- 2375
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2376
	} -- 2376
end -- 2358
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2769
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2778
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2779
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2787
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2788
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2789
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2797
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2805
		shared.role, -- 2805
		{ -- 2805
			includeFinish = true, -- 2806
			includeXmlRules = true, -- 2807
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2808
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2809
			workMode = shared.workMode -- 2810
		} -- 2810
	) -- 2810
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2812
	local repairPrompt = replacePromptVars( -- 2815
		shared.promptPack.xmlDecisionRepairPrompt, -- 2815
		{ -- 2815
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2816
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2817
			CANDIDATE_SECTION = candidateSection, -- 2818
			LAST_ERROR = lastError, -- 2819
			ATTEMPT = tostring(attempt) -- 2820
		} -- 2820
	) -- 2820
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2822
end -- 2769
local MainDecisionAgent = __TS__Class() -- 2860
MainDecisionAgent.name = "MainDecisionAgent" -- 2860
__TS__ClassExtends(MainDecisionAgent, Node) -- 2860
function MainDecisionAgent.prototype.prep(self, shared) -- 2861
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2861
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2861
			return ____awaiter_resolve(nil, {shared = shared}) -- 2861
		end -- 2861
		__TS__Await(maybeCompressHistory(shared)) -- 2866
		return ____awaiter_resolve(nil, {shared = shared}) -- 2866
	end) -- 2866
end -- 2861
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2871
	local preExecuted = shared.preExecutedResults -- 2872
	if not preExecuted or preExecuted.size == 0 then -- 2872
		return nil -- 2873
	end -- 2873
	local decisions = {} -- 2874
	preExecuted:forEach(function(____, preResult) -- 2875
		local action = preResult.action -- 2876
		decisions[#decisions + 1] = { -- 2877
			success = true, -- 2878
			tool = action.tool, -- 2879
			params = action.params, -- 2880
			toolCallId = action.toolCallId, -- 2881
			reason = action.reason, -- 2882
			reasoningContent = action.reasoningContent -- 2883
		} -- 2883
	end) -- 2875
	if #decisions == 0 then -- 2875
		return nil -- 2886
	end -- 2886
	AgentUtils.Log( -- 2887
		"Warn", -- 2887
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2887
			__TS__ArrayMap( -- 2887
				decisions, -- 2887
				function(____, decision) return decision.tool end -- 2887
			), -- 2887
			"," -- 2887
		) -- 2887
	) -- 2887
	if #decisions == 1 then -- 2887
		return decisions[1] -- 2889
	end -- 2889
	return {success = true, kind = "batch", decisions = decisions} -- 2891
end -- 2871
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2898
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2903
	if not recovery then -- 2903
		return nil -- 2904
	end -- 2904
	shared.truncatedToolOverwritePath = recovery.target -- 2905
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2906
	return { -- 2907
		success = true, -- 2908
		tool = "edit_file", -- 2909
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2910
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2916
		reason = recovery.reason, -- 2917
		reasoningContent = reasoningContent -- 2918
	} -- 2918
end -- 2898
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2922
	if attempt == nil then -- 2922
		attempt = 1 -- 2925
	end -- 2925
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2925
		if shared.stopToken.stopped then -- 2925
			return ____awaiter_resolve( -- 2925
				nil, -- 2925
				{ -- 2929
					success = false, -- 2929
					message = getCancelledReason(shared) -- 2929
				} -- 2929
			) -- 2929
		end -- 2929
		AgentUtils.Log( -- 2931
			"Info", -- 2931
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2931
		) -- 2931
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2932
			shared.role, -- 2932
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2932
			{ -- 2932
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2933
				workMode = shared.workMode -- 2934
			} -- 2934
		) -- 2934
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2936
		local stepId = shared.step + 1 -- 2937
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2938
			string.lower(shared.llmConfig.model), -- 2938
			"glm-5.2" -- 2938
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2938
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2941
		emitLLMContextMetrics( -- 2946
			shared, -- 2946
			stepId, -- 2946
			"decision_tool_calling", -- 2946
			messages, -- 2946
			llmOptions -- 2946
		) -- 2946
		saveStepLLMDebugInput( -- 2947
			shared, -- 2947
			stepId, -- 2947
			"decision_tool_calling", -- 2947
			messages, -- 2947
			llmOptions -- 2947
		) -- 2947
		local lastStreamContent = "" -- 2948
		local lastStreamReasoning = "" -- 2949
		local preExecutedResults = __TS__New(Map) -- 2950
		shared.preExecutedResults = preExecutedResults -- 2951
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2952
			messages, -- 2953
			llmOptions, -- 2954
			shared.stopToken, -- 2955
			shared.llmConfig, -- 2956
			function(response) -- 2957
				local ____opt_75 = response.choices -- 2957
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2957
				local streamMessage = ____opt_73 and ____opt_73.message -- 2958
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2959
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2962
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2962
					return -- 2966
				end -- 2966
				lastStreamContent = nextContent -- 2968
				lastStreamReasoning = nextReasoning -- 2969
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2970
			end, -- 2957
			function(tc) -- 2972
				if shared.stopToken.stopped then -- 2972
					return -- 2973
				end -- 2973
				local action = createPreExecutableActionFromStream(shared, tc) -- 2974
				if not action or preExecutedResults:has(action.toolCallId) then -- 2974
					return -- 2975
				end -- 2975
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2976
				preExecutedResults:set( -- 2977
					action.toolCallId, -- 2977
					createPreExecutedToolResult(shared, action) -- 2977
				) -- 2977
			end -- 2972
		)) -- 2972
		if shared.stopToken.stopped then -- 2972
			clearPreExecutedResults(shared) -- 2981
			return ____awaiter_resolve( -- 2981
				nil, -- 2981
				{ -- 2982
					success = false, -- 2982
					message = getCancelledReason(shared) -- 2982
				} -- 2982
			) -- 2982
		end -- 2982
		if not res.success then -- 2982
			local usage = res.tokenUsage -- 2985
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2986
			saveStepLLMDebugOutput( -- 2987
				shared, -- 2987
				stepId, -- 2987
				"decision_tool_calling", -- 2987
				res.raw or res.message, -- 2987
				{success = false, usage = usage} -- 2987
			) -- 2987
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2988
			local committed = self:commitPreExecutedDecision(shared) -- 2989
			if committed then -- 2989
				return ____awaiter_resolve(nil, committed) -- 2989
			end -- 2989
			local ____opt_83 = res.response -- 2989
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2989
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2991
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 2992
			local ____shared_93 = shared -- 2993
			local ____opt_85 = partialChoice and partialChoice.message -- 2993
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 2994
			local ____opt_89 = partialChoice and partialChoice.message -- 2994
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 2992
			if partialDraft then -- 2992
				return ____awaiter_resolve(nil, partialDraft) -- 2992
			end -- 2992
			clearPreExecutedResults(shared) -- 2998
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2998
		end -- 2998
		local usage = res.tokenUsage -- 3001
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3002
		saveStepLLMDebugOutput( -- 3003
			shared, -- 3003
			stepId, -- 3003
			"decision_tool_calling", -- 3003
			encodeDebugJSON(res.response), -- 3003
			{success = true, usage = usage} -- 3003
		) -- 3003
		local choice = res.response.choices and res.response.choices[1] -- 3004
		local message = choice and choice.message -- 3005
		local toolCalls = message and message.tool_calls -- 3006
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3007
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3010
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3013
		AgentUtils.Log( -- 3016
			"Info", -- 3016
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3016
		) -- 3016
		if finishReason == "length" then -- 3016
			local committed = self:commitPreExecutedDecision(shared) -- 3018
			if committed then -- 3018
				return ____awaiter_resolve(nil, committed) -- 3018
			end -- 3018
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3020
			if partialDraft then -- 3020
				return ____awaiter_resolve(nil, partialDraft) -- 3020
			end -- 3020
			AgentUtils.Log( -- 3022
				"Error", -- 3022
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3022
			) -- 3022
			clearPreExecutedResults(shared) -- 3023
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3023
		end -- 3023
		if not toolCalls or #toolCalls == 0 then -- 3023
			if messageContent and messageContent ~= "" then -- 3023
				if isFinalDecisionTurn(shared) then -- 3023
					clearPreExecutedResults(shared) -- 3033
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3033
				end -- 3033
				if shared.role == "sub" then -- 3033
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3041
					clearPreExecutedResults(shared) -- 3042
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3042
				end -- 3042
				AgentUtils.Log( -- 3049
					"Info", -- 3049
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3049
				) -- 3049
				clearPreExecutedResults(shared) -- 3050
				return ____awaiter_resolve(nil, { -- 3050
					success = true, -- 3052
					tool = "finish", -- 3053
					params = {}, -- 3054
					reason = messageContent, -- 3055
					reasoningContent = reasoningContent, -- 3056
					directSummary = messageContent -- 3057
				}) -- 3057
			end -- 3057
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3060
			clearPreExecutedResults(shared) -- 3061
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3061
		end -- 3061
		local decisions = {} -- 3068
		do -- 3068
			local i = 0 -- 3069
			while i < #toolCalls do -- 3069
				local toolCall = toolCalls[i + 1] -- 3070
				local fn = toolCall ~= nil and toolCall["function"] -- 3071
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3071
					AgentUtils.Log( -- 3073
						"Error", -- 3073
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3073
					) -- 3073
					clearPreExecutedResults(shared) -- 3074
					return ____awaiter_resolve( -- 3074
						nil, -- 3074
						{ -- 3075
							success = false, -- 3076
							message = "missing function name for tool call " .. tostring(i + 1), -- 3077
							raw = messageContent -- 3078
						} -- 3078
					) -- 3078
				end -- 3078
				local functionName = fn.name -- 3081
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3082
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3083
				AgentUtils.Log( -- 3086
					"Info", -- 3086
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3086
				) -- 3086
				local decision = parseAndValidateToolCallDecision( -- 3087
					shared, -- 3088
					functionName, -- 3089
					argsText, -- 3090
					toolCallId, -- 3091
					messageContent, -- 3092
					reasoningContent -- 3093
				) -- 3093
				if not decision.success then -- 3093
					AgentUtils.Log( -- 3096
						"Error", -- 3096
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3096
					) -- 3096
					clearPreExecutedResults(shared) -- 3097
					return ____awaiter_resolve(nil, decision) -- 3097
				end -- 3097
				decisions[#decisions + 1] = decision -- 3100
				i = i + 1 -- 3069
			end -- 3069
		end -- 3069
		if #decisions == 1 then -- 3069
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3103
			return ____awaiter_resolve(nil, decisions[1]) -- 3103
		end -- 3103
		do -- 3103
			local i = 0 -- 3106
			while i < #decisions do -- 3106
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3106
					clearPreExecutedResults(shared) -- 3108
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3108
				end -- 3108
				i = i + 1 -- 3106
			end -- 3106
		end -- 3106
		AgentUtils.Log( -- 3116
			"Info", -- 3116
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3116
				__TS__ArrayMap( -- 3116
					decisions, -- 3116
					function(____, decision) return decision.tool end -- 3116
				), -- 3116
				"," -- 3116
			) -- 3116
		) -- 3116
		return ____awaiter_resolve(nil, { -- 3116
			success = true, -- 3118
			kind = "batch", -- 3119
			decisions = decisions, -- 3120
			content = messageContent, -- 3121
			reasoningContent = reasoningContent -- 3122
		}) -- 3122
	end) -- 3122
end -- 2922
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3126
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3126
		AgentUtils.Log( -- 3132
			"Info", -- 3132
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3132
		) -- 3132
		local lastError = initialError -- 3133
		local candidateRaw = "" -- 3134
		local candidateReasoning = nil -- 3135
		do -- 3135
			local attempt = 0 -- 3136
			while attempt < shared.llmMaxTry do -- 3136
				do -- 3136
					AgentUtils.Log( -- 3137
						"Info", -- 3137
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3137
					) -- 3137
					local messages = buildXmlRepairMessages( -- 3138
						shared, -- 3139
						originalRaw, -- 3140
						originalReasoning, -- 3141
						candidateRaw, -- 3142
						candidateReasoning, -- 3143
						lastError, -- 3144
						attempt + 1 -- 3145
					) -- 3145
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3147
					if shared.stopToken.stopped then -- 3147
						return ____awaiter_resolve( -- 3147
							nil, -- 3147
							{ -- 3149
								success = false, -- 3149
								message = getCancelledReason(shared) -- 3149
							} -- 3149
						) -- 3149
					end -- 3149
					if not llmRes.success then -- 3149
						lastError = llmRes.message -- 3152
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3153
						goto __continue530 -- 3154
					end -- 3154
					candidateRaw = llmRes.text -- 3156
					candidateReasoning = llmRes.reasoningContent -- 3157
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3158
					if decision.success then -- 3158
						decision.reasoningContent = llmRes.reasoningContent -- 3160
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3161
						return ____awaiter_resolve(nil, decision) -- 3161
					end -- 3161
					lastError = decision.message -- 3164
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3165
				end -- 3165
				::__continue530:: -- 3165
				attempt = attempt + 1 -- 3136
			end -- 3136
		end -- 3136
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3167
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3167
	end) -- 3167
end -- 3126
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3175
	if attempt == nil then -- 3175
		attempt = 1 -- 3178
	end -- 3178
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3178
		local messages = buildDecisionMessages( -- 3181
			shared, -- 3182
			lastError, -- 3183
			attempt, -- 3184
			lastRaw, -- 3185
			"xml" -- 3186
		) -- 3186
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3188
		if shared.stopToken.stopped then -- 3188
			return ____awaiter_resolve( -- 3188
				nil, -- 3188
				{ -- 3190
					success = false, -- 3190
					message = getCancelledReason(shared) -- 3190
				} -- 3190
			) -- 3190
		end -- 3190
		if not llmRes.success then -- 3190
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3190
		end -- 3190
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3199
		if decision.success then -- 3199
			decision.reasoningContent = llmRes.reasoningContent -- 3201
			return ____awaiter_resolve(nil, decision) -- 3201
		end -- 3201
		return ____awaiter_resolve( -- 3201
			nil, -- 3201
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3204
		) -- 3204
	end) -- 3204
end -- 3175
function MainDecisionAgent.prototype.exec(self, input) -- 3207
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3207
		local shared = input.shared -- 3208
		if shared.stopToken.stopped then -- 3208
			return ____awaiter_resolve( -- 3208
				nil, -- 3208
				{ -- 3210
					success = false, -- 3210
					message = getCancelledReason(shared) -- 3210
				} -- 3210
			) -- 3210
		end -- 3210
		if shared.agentStepCount >= shared.maxSteps then -- 3210
			AgentUtils.Log( -- 3213
				"Warn", -- 3213
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3213
			) -- 3213
			return ____awaiter_resolve( -- 3213
				nil, -- 3213
				{ -- 3214
					success = false, -- 3214
					message = getMaxStepsReachedReason(shared) -- 3214
				} -- 3214
			) -- 3214
		end -- 3214
		if shared.decisionMode == "tool_calling" then -- 3214
			AgentUtils.Log( -- 3218
				"Info", -- 3218
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3218
			) -- 3218
			local lastError = "tool calling validation failed" -- 3219
			local lastRaw = "" -- 3220
			local shouldFallbackToXml = false -- 3221
			do -- 3221
				local attempt = 0 -- 3222
				while attempt < shared.llmMaxTry do -- 3222
					AgentUtils.Log( -- 3223
						"Info", -- 3223
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3223
					) -- 3223
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3224
					if shared.stopToken.stopped then -- 3224
						return ____awaiter_resolve( -- 3224
							nil, -- 3224
							{ -- 3231
								success = false, -- 3231
								message = getCancelledReason(shared) -- 3231
							} -- 3231
						) -- 3231
					end -- 3231
					if decision.success then -- 3231
						return ____awaiter_resolve(nil, decision) -- 3231
					end -- 3231
					lastError = decision.message -- 3236
					lastRaw = decision.raw or "" -- 3237
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3238
					if lastError == "missing tool call" then -- 3238
						shouldFallbackToXml = true -- 3240
						break -- 3241
					end -- 3241
					attempt = attempt + 1 -- 3222
				end -- 3222
			end -- 3222
			if shouldFallbackToXml then -- 3222
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3245
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3246
				do -- 3246
					local attempt = 0 -- 3247
					while attempt < shared.llmMaxTry do -- 3247
						AgentUtils.Log( -- 3248
							"Info", -- 3248
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3248
						) -- 3248
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3249
						if shared.stopToken.stopped then -- 3249
							return ____awaiter_resolve( -- 3249
								nil, -- 3249
								{ -- 3256
									success = false, -- 3256
									message = getCancelledReason(shared) -- 3256
								} -- 3256
							) -- 3256
						end -- 3256
						if decision.success then -- 3256
							return ____awaiter_resolve(nil, decision) -- 3256
						end -- 3256
						lastError = decision.message -- 3261
						lastRaw = decision.raw or "" -- 3262
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3263
						attempt = attempt + 1 -- 3247
					end -- 3247
				end -- 3247
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3265
				return ____awaiter_resolve( -- 3265
					nil, -- 3265
					{ -- 3266
						success = false, -- 3266
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3266
					} -- 3266
				) -- 3266
			end -- 3266
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3268
			return ____awaiter_resolve( -- 3268
				nil, -- 3268
				{ -- 3269
					success = false, -- 3269
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3269
				} -- 3269
			) -- 3269
		end -- 3269
		local lastError = "xml validation failed" -- 3272
		local lastRaw = "" -- 3273
		do -- 3273
			local attempt = 0 -- 3274
			while attempt < shared.llmMaxTry do -- 3274
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3275
				if shared.stopToken.stopped then -- 3275
					return ____awaiter_resolve( -- 3275
						nil, -- 3275
						{ -- 3284
							success = false, -- 3284
							message = getCancelledReason(shared) -- 3284
						} -- 3284
					) -- 3284
				end -- 3284
				if decision.success then -- 3284
					return ____awaiter_resolve(nil, decision) -- 3284
				end -- 3284
				lastError = decision.message -- 3289
				lastRaw = decision.raw or "" -- 3290
				attempt = attempt + 1 -- 3274
			end -- 3274
		end -- 3274
		return ____awaiter_resolve( -- 3274
			nil, -- 3274
			{ -- 3292
				success = false, -- 3292
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3292
			} -- 3292
		) -- 3292
	end) -- 3292
end -- 3207
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3295
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3295
		local result = execRes -- 3296
		if not result.success then -- 3296
			if shared.stopToken.stopped then -- 3296
				shared.error = getCancelledReason(shared) -- 3299
				shared.done = true -- 3300
				return ____awaiter_resolve(nil, "done") -- 3300
			end -- 3300
			shared.error = result.message -- 3303
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3304
			shared.done = true -- 3305
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3306
			persistHistoryState(shared) -- 3310
			return ____awaiter_resolve(nil, "done") -- 3310
		end -- 3310
		if isDecisionBatchSuccess(result) then -- 3310
			local startStep = shared.step -- 3314
			local actions = {} -- 3315
			do -- 3315
				local i = 0 -- 3316
				while i < #result.decisions do -- 3316
					local decision = result.decisions[i + 1] -- 3317
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3318
					local step = startStep + i + 1 -- 3319
					local ____temp_96 -- 3320
					if i == 0 then -- 3320
						____temp_96 = decision.reason -- 3320
					else -- 3320
						____temp_96 = "" -- 3320
					end -- 3320
					local actionReason = ____temp_96 -- 3320
					local ____temp_97 -- 3321
					if i == 0 then -- 3321
						____temp_97 = decision.reasoningContent -- 3321
					else -- 3321
						____temp_97 = nil -- 3321
					end -- 3321
					local actionReasoningContent = ____temp_97 -- 3321
					emitAgentEvent(shared, { -- 3322
						type = "decision_made", -- 3323
						sessionId = shared.sessionId, -- 3324
						taskId = shared.taskId, -- 3325
						step = step, -- 3326
						tool = decision.tool, -- 3327
						reason = actionReason, -- 3328
						reasoningContent = actionReasoningContent, -- 3329
						params = decision.params -- 3330
					}) -- 3330
					local action = { -- 3332
						step = step, -- 3333
						toolCallId = toolCallId, -- 3334
						tool = decision.tool, -- 3335
						reason = actionReason or "", -- 3336
						reasoningContent = actionReasoningContent, -- 3337
						params = decision.params, -- 3338
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3339
					} -- 3339
					local ____shared_history_98 = shared.history -- 3339
					____shared_history_98[#____shared_history_98 + 1] = action -- 3341
					actions[#actions + 1] = action -- 3342
					i = i + 1 -- 3316
				end -- 3316
			end -- 3316
			shared.step = startStep + #actions -- 3344
			shared.agentStepCount = shared.agentStepCount + #actions -- 3345
			shared.pendingToolActions = actions -- 3346
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3347
			persistHistoryState(shared) -- 3353
			return ____awaiter_resolve(nil, "batch_tools") -- 3353
		end -- 3353
		if result.directSummary and result.directSummary ~= "" then -- 3353
			shared.response = result.directSummary -- 3357
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3358
			shared.done = true -- 3362
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3363
			persistHistoryState(shared) -- 3368
			return ____awaiter_resolve(nil, "done") -- 3368
		end -- 3368
		if result.tool == "finish" then -- 3368
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3372
			shared.response = finalMessage -- 3373
			shared.completion = getCompletionReport(result.params) -- 3374
			shared.done = true -- 3375
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3376
			persistHistoryState(shared) -- 3381
			return ____awaiter_resolve(nil, "done") -- 3381
		end -- 3381
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3384
		shared.step = shared.step + 1 -- 3385
		shared.agentStepCount = shared.agentStepCount + 1 -- 3386
		local step = shared.step -- 3387
		emitAgentEvent(shared, { -- 3388
			type = "decision_made", -- 3389
			sessionId = shared.sessionId, -- 3390
			taskId = shared.taskId, -- 3391
			step = step, -- 3392
			tool = result.tool, -- 3393
			reason = result.reason, -- 3394
			reasoningContent = result.reasoningContent, -- 3395
			params = result.params -- 3396
		}) -- 3396
		local ____shared_history_99 = shared.history -- 3396
		____shared_history_99[#____shared_history_99 + 1] = { -- 3398
			step = step, -- 3399
			toolCallId = toolCallId, -- 3400
			tool = result.tool, -- 3401
			reason = result.reason or "", -- 3402
			reasoningContent = result.reasoningContent, -- 3403
			params = result.params, -- 3404
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3405
		} -- 3405
		local action = shared.history[#shared.history] -- 3407
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3408
		shared.pendingToolActions = {action} -- 3411
		persistHistoryState(shared) -- 3412
		return ____awaiter_resolve(nil, "batch_tools") -- 3412
	end) -- 3412
end -- 3295
local ReadFileAction = __TS__Class() -- 3417
ReadFileAction.name = "ReadFileAction" -- 3417
__TS__ClassExtends(ReadFileAction, Node) -- 3417
function ReadFileAction.prototype.prep(self, shared) -- 3418
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3418
		local last = shared.history[#shared.history] -- 3419
		if not last then -- 3419
			error( -- 3420
				__TS__New(Error, "no history"), -- 3420
				0 -- 3420
			) -- 3420
		end -- 3420
		emitAgentStartEvent(shared, last) -- 3421
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3422
		if __TS__StringTrim(path) == "" then -- 3422
			error( -- 3425
				__TS__New(Error, "missing path"), -- 3425
				0 -- 3425
			) -- 3425
		end -- 3425
		local ____path_102 = path -- 3427
		local ____shared_workingDir_103 = shared.workingDir -- 3429
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3430
		local ____last_params_startLine_100 = last.params.startLine -- 3431
		if ____last_params_startLine_100 == nil then -- 3431
			____last_params_startLine_100 = 1 -- 3431
		end -- 3431
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3431
		local ____last_params_endLine_101 = last.params.endLine -- 3432
		if ____last_params_endLine_101 == nil then -- 3432
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3432
		end -- 3432
		return ____awaiter_resolve( -- 3432
			nil, -- 3432
			{ -- 3426
				path = ____path_102, -- 3427
				tool = "read_file", -- 3428
				workDir = ____shared_workingDir_103, -- 3429
				docLanguage = ____temp_104, -- 3430
				startLine = ____TS__Number_result_105, -- 3431
				endLine = __TS__Number(____last_params_endLine_101) -- 3432
			} -- 3432
		) -- 3432
	end) -- 3432
end -- 3418
function ReadFileAction.prototype.exec(self, input) -- 3436
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3436
		return ____awaiter_resolve( -- 3436
			nil, -- 3436
			Tools.readFile( -- 3437
				input.workDir, -- 3438
				input.path, -- 3439
				__TS__Number(input.startLine or 1), -- 3440
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3441
				input.docLanguage -- 3442
			) -- 3442
		) -- 3442
	end) -- 3442
end -- 3436
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3446
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3446
		local result = execRes -- 3447
		local last = shared.history[#shared.history] -- 3448
		if last ~= nil then -- 3448
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3450
			appendToolResultMessage(shared, last) -- 3451
			emitAgentFinishEvent(shared, last) -- 3452
		end -- 3452
		persistHistoryState(shared) -- 3454
		__TS__Await(maybeCompressHistory(shared)) -- 3455
		persistHistoryState(shared) -- 3456
		return ____awaiter_resolve(nil, "main") -- 3456
	end) -- 3456
end -- 3446
local SearchFilesAction = __TS__Class() -- 3461
SearchFilesAction.name = "SearchFilesAction" -- 3461
__TS__ClassExtends(SearchFilesAction, Node) -- 3461
function SearchFilesAction.prototype.prep(self, shared) -- 3462
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3462
		local last = shared.history[#shared.history] -- 3463
		if not last then -- 3463
			error( -- 3464
				__TS__New(Error, "no history"), -- 3464
				0 -- 3464
			) -- 3464
		end -- 3464
		emitAgentStartEvent(shared, last) -- 3465
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3465
	end) -- 3465
end -- 3462
function SearchFilesAction.prototype.exec(self, input) -- 3469
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3469
		local params = input.params -- 3470
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3471
		local ____input_workDir_112 = input.workDir -- 3472
		local ____temp_113 = params.path or "" -- 3473
		local ____temp_114 = params.pattern or "" -- 3474
		local ____params_globs_115 = params.globs -- 3475
		local ____params_useRegex_116 = params.useRegex -- 3476
		local ____params_caseSensitive_117 = params.caseSensitive -- 3477
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3479
		local ____math_max_108 = math.max -- 3480
		local ____math_floor_107 = math.floor -- 3480
		local ____params_limit_106 = params.limit -- 3480
		if ____params_limit_106 == nil then -- 3480
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3480
		end -- 3480
		local ____math_max_108_result_119 = ____math_max_108( -- 3480
			1, -- 3480
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3480
		) -- 3480
		local ____math_max_111 = math.max -- 3481
		local ____math_floor_110 = math.floor -- 3481
		local ____params_offset_109 = params.offset -- 3481
		if ____params_offset_109 == nil then -- 3481
			____params_offset_109 = 0 -- 3481
		end -- 3481
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3471
			workDir = ____input_workDir_112, -- 3472
			path = ____temp_113, -- 3473
			pattern = ____temp_114, -- 3474
			globs = ____params_globs_115, -- 3475
			useRegex = ____params_useRegex_116, -- 3476
			caseSensitive = ____params_caseSensitive_117, -- 3477
			includeContent = true, -- 3478
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3479
			limit = ____math_max_108_result_119, -- 3480
			offset = ____math_max_111( -- 3481
				0, -- 3481
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3481
			), -- 3481
			groupByFile = params.groupByFile == true -- 3482
		})) -- 3482
		return ____awaiter_resolve(nil, result) -- 3482
	end) -- 3482
end -- 3469
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3487
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3487
		local last = shared.history[#shared.history] -- 3488
		if last ~= nil then -- 3488
			local result = execRes -- 3490
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3491
			appendToolResultMessage(shared, last) -- 3492
			emitAgentFinishEvent(shared, last) -- 3493
		end -- 3493
		persistHistoryState(shared) -- 3495
		__TS__Await(maybeCompressHistory(shared)) -- 3496
		persistHistoryState(shared) -- 3497
		return ____awaiter_resolve(nil, "main") -- 3497
	end) -- 3497
end -- 3487
local SearchDoraAPIAction = __TS__Class() -- 3502
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3502
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3502
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3503
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3503
		local last = shared.history[#shared.history] -- 3504
		if not last then -- 3504
			error( -- 3505
				__TS__New(Error, "no history"), -- 3505
				0 -- 3505
			) -- 3505
		end -- 3505
		emitAgentStartEvent(shared, last) -- 3506
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3506
	end) -- 3506
end -- 3503
function SearchDoraAPIAction.prototype.exec(self, input) -- 3510
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3510
		local params = input.params -- 3511
		local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3512
		local ____temp_125 = params.pattern or "" -- 3513
		local ____temp_126 = params.docSource or "api" -- 3514
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3515
		local ____temp_128 = params.programmingLanguage or "ts" -- 3516
		local ____math_min_124 = math.min -- 3517
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3517
		local ____math_max_122 = math.max -- 3517
		local ____params_limit_121 = params.limit -- 3517
		if ____params_limit_121 == nil then -- 3517
			____params_limit_121 = 8 -- 3517
		end -- 3517
		local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3512
			pattern = ____temp_125, -- 3513
			docSource = ____temp_126, -- 3514
			docLanguage = ____temp_127, -- 3515
			programmingLanguage = ____temp_128, -- 3516
			limit = ____math_min_124( -- 3517
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123, -- 3517
				____math_max_122( -- 3517
					1, -- 3517
					__TS__Number(____params_limit_121) -- 3517
				) -- 3517
			), -- 3517
			useRegex = params.useRegex, -- 3518
			caseSensitive = false, -- 3519
			includeContent = true, -- 3520
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3521
		})) -- 3521
		return ____awaiter_resolve(nil, result) -- 3521
	end) -- 3521
end -- 3510
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3526
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3526
		local last = shared.history[#shared.history] -- 3527
		if last ~= nil then -- 3527
			local result = execRes -- 3529
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3530
			appendToolResultMessage(shared, last) -- 3531
			emitAgentFinishEvent(shared, last) -- 3532
		end -- 3532
		persistHistoryState(shared) -- 3534
		__TS__Await(maybeCompressHistory(shared)) -- 3535
		persistHistoryState(shared) -- 3536
		return ____awaiter_resolve(nil, "main") -- 3536
	end) -- 3536
end -- 3526
local ListFilesAction = __TS__Class() -- 3541
ListFilesAction.name = "ListFilesAction" -- 3541
__TS__ClassExtends(ListFilesAction, Node) -- 3541
function ListFilesAction.prototype.prep(self, shared) -- 3542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3542
		local last = shared.history[#shared.history] -- 3543
		if not last then -- 3543
			error( -- 3544
				__TS__New(Error, "no history"), -- 3544
				0 -- 3544
			) -- 3544
		end -- 3544
		emitAgentStartEvent(shared, last) -- 3545
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3545
	end) -- 3545
end -- 3542
function ListFilesAction.prototype.exec(self, input) -- 3549
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3549
		local params = input.params -- 3550
		local ____Tools_listFiles_136 = Tools.listFiles -- 3551
		local ____input_workDir_133 = input.workDir -- 3552
		local ____temp_134 = params.path or "" -- 3553
		local ____params_globs_135 = params.globs -- 3554
		local ____math_max_132 = math.max -- 3555
		local ____math_floor_131 = math.floor -- 3555
		local ____params_maxEntries_130 = params.maxEntries -- 3555
		if ____params_maxEntries_130 == nil then -- 3555
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3555
		end -- 3555
		local result = ____Tools_listFiles_136({ -- 3551
			workDir = ____input_workDir_133, -- 3552
			path = ____temp_134, -- 3553
			globs = ____params_globs_135, -- 3554
			maxEntries = ____math_max_132( -- 3555
				1, -- 3555
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3555
			) -- 3555
		}) -- 3555
		return ____awaiter_resolve(nil, result) -- 3555
	end) -- 3555
end -- 3549
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3560
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3560
		local last = shared.history[#shared.history] -- 3561
		if last ~= nil then -- 3561
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3563
			appendToolResultMessage(shared, last) -- 3564
			emitAgentFinishEvent(shared, last) -- 3565
		end -- 3565
		persistHistoryState(shared) -- 3567
		__TS__Await(maybeCompressHistory(shared)) -- 3568
		persistHistoryState(shared) -- 3569
		return ____awaiter_resolve(nil, "main") -- 3569
	end) -- 3569
end -- 3560
local DeleteFileAction = __TS__Class() -- 3574
DeleteFileAction.name = "DeleteFileAction" -- 3574
__TS__ClassExtends(DeleteFileAction, Node) -- 3574
function DeleteFileAction.prototype.prep(self, shared) -- 3575
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3575
		local last = shared.history[#shared.history] -- 3576
		if not last then -- 3576
			error( -- 3577
				__TS__New(Error, "no history"), -- 3577
				0 -- 3577
			) -- 3577
		end -- 3577
		emitAgentStartEvent(shared, last) -- 3578
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3579
		if __TS__StringTrim(targetFile) == "" then -- 3579
			error( -- 3582
				__TS__New(Error, "missing target_file"), -- 3582
				0 -- 3582
			) -- 3582
		end -- 3582
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3582
	end) -- 3582
end -- 3575
function DeleteFileAction.prototype.exec(self, input) -- 3586
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3586
		local result = Tools.deleteFile(input.taskId, input.workDir, input.targetFile, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3587
		if not result.success then -- 3587
			return ____awaiter_resolve(nil, result) -- 3587
		end -- 3587
		local ____result_checkpointed_138 = result.checkpointed -- 3598
		local ____result_reversible_139 = result.reversible -- 3599
		local ____result_binary_140 = result.binary -- 3600
		local ____temp_141 = result.checkpointed and result.checkpointId or nil -- 3601
		local ____temp_142 = result.checkpointed and result.checkpointSeq or nil -- 3602
		local ____result_checkpointed_137 -- 3603
		if result.checkpointed then -- 3603
			____result_checkpointed_137 = nil -- 3603
		else -- 3603
			____result_checkpointed_137 = result.message -- 3603
		end -- 3603
		return ____awaiter_resolve(nil, { -- 3603
			success = true, -- 3595
			changed = true, -- 3596
			mode = "delete", -- 3597
			checkpointed = ____result_checkpointed_138, -- 3598
			reversible = ____result_reversible_139, -- 3599
			binary = ____result_binary_140, -- 3600
			checkpointId = ____temp_141, -- 3601
			checkpointSeq = ____temp_142, -- 3602
			message = ____result_checkpointed_137, -- 3603
			files = {{path = input.targetFile, op = "delete"}} -- 3604
		}) -- 3604
	end) -- 3604
end -- 3586
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3608
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3608
		local last = shared.history[#shared.history] -- 3609
		if last ~= nil then -- 3609
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3611
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3612
			appendToolResultMessage(shared, last) -- 3613
			emitAgentFinishEvent(shared, last) -- 3614
			local result = last.result -- 3615
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3615
				emitAgentEvent(shared, { -- 3620
					type = "checkpoint_created", -- 3621
					sessionId = shared.sessionId, -- 3622
					taskId = shared.taskId, -- 3623
					step = last.step, -- 3624
					tool = "delete_file", -- 3625
					checkpointId = result.checkpointId, -- 3626
					checkpointSeq = result.checkpointSeq, -- 3627
					files = result.files -- 3628
				}) -- 3628
			end -- 3628
		end -- 3628
		persistHistoryState(shared) -- 3635
		__TS__Await(maybeCompressHistory(shared)) -- 3636
		persistHistoryState(shared) -- 3637
		return ____awaiter_resolve(nil, "main") -- 3637
	end) -- 3637
end -- 3608
local BuildAction = __TS__Class() -- 3642
BuildAction.name = "BuildAction" -- 3642
__TS__ClassExtends(BuildAction, Node) -- 3642
function BuildAction.prototype.prep(self, shared) -- 3643
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3643
		local last = shared.history[#shared.history] -- 3644
		if not last then -- 3644
			error( -- 3645
				__TS__New(Error, "no history"), -- 3645
				0 -- 3645
			) -- 3645
		end -- 3645
		emitAgentStartEvent(shared, last) -- 3646
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3646
	end) -- 3646
end -- 3643
function BuildAction.prototype.exec(self, input) -- 3650
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3650
		local params = input.params -- 3651
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3652
		return ____awaiter_resolve(nil, result) -- 3652
	end) -- 3652
end -- 3650
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3659
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3659
		local last = shared.history[#shared.history] -- 3660
		if last ~= nil then -- 3660
			last.result = sanitizeBuildResultForHistory(execRes) -- 3662
			appendToolResultMessage(shared, last) -- 3663
			emitAgentFinishEvent(shared, last) -- 3664
		end -- 3664
		persistHistoryState(shared) -- 3666
		__TS__Await(maybeCompressHistory(shared)) -- 3667
		persistHistoryState(shared) -- 3668
		return ____awaiter_resolve(nil, "main") -- 3668
	end) -- 3668
end -- 3659
local SpawnSubAgentAction = __TS__Class() -- 3673
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3673
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3673
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3674
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3674
		local last = shared.history[#shared.history] -- 3684
		if not last then -- 3684
			error( -- 3685
				__TS__New(Error, "no history"), -- 3685
				0 -- 3685
			) -- 3685
		end -- 3685
		emitAgentStartEvent(shared, last) -- 3686
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3687
			last.params.filesHint, -- 3688
			function(____, item) return type(item) == "string" end -- 3688
		) or nil -- 3688
		return ____awaiter_resolve( -- 3688
			nil, -- 3688
			{ -- 3690
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3691
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3692
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3693
				filesHint = filesHint, -- 3694
				sessionId = shared.sessionId, -- 3695
				projectRoot = shared.workingDir, -- 3696
				spawnSubAgent = shared.spawnSubAgent, -- 3697
				disabledAgentTools = shared.disabledAgentTools -- 3698
			} -- 3698
		) -- 3698
	end) -- 3698
end -- 3674
function SpawnSubAgentAction.prototype.exec(self, input) -- 3702
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3702
		if not input.spawnSubAgent then -- 3702
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3702
		end -- 3702
		if input.sessionId == nil or input.sessionId <= 0 then -- 3702
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3702
		end -- 3702
		local ____AgentUtils_Log_148 = AgentUtils.Log -- 3718
		local ____temp_145 = #input.title -- 3718
		local ____temp_146 = #input.prompt -- 3718
		local ____temp_147 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3718
		local ____opt_143 = input.filesHint -- 3718
		____AgentUtils_Log_148( -- 3718
			"Info", -- 3718
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_145)) .. " prompt_len=") .. tostring(____temp_146)) .. " expected_len=") .. tostring(____temp_147)) .. " files_hint_count=") .. tostring(____opt_143 and #____opt_143 or 0) -- 3718
		) -- 3718
		local result = __TS__Await(input.spawnSubAgent({ -- 3719
			parentSessionId = input.sessionId, -- 3720
			projectRoot = input.projectRoot, -- 3721
			title = input.title, -- 3722
			prompt = input.prompt, -- 3723
			expectedOutput = input.expectedOutput, -- 3724
			filesHint = input.filesHint, -- 3725
			disabledAgentTools = input.disabledAgentTools -- 3726
		})) -- 3726
		if not result.success then -- 3726
			return ____awaiter_resolve(nil, result) -- 3726
		end -- 3726
		return ____awaiter_resolve(nil, { -- 3726
			success = true, -- 3732
			sessionId = result.sessionId, -- 3733
			taskId = result.taskId, -- 3734
			title = result.title, -- 3735
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3736
		}) -- 3736
	end) -- 3736
end -- 3702
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3740
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3740
		local last = shared.history[#shared.history] -- 3741
		if last ~= nil then -- 3741
			last.result = execRes -- 3743
			if execRes.success == true then -- 3743
				shared.hasSpawnedSubAgentThisTask = true -- 3745
			end -- 3745
			appendToolResultMessage(shared, last) -- 3747
			emitAgentFinishEvent(shared, last) -- 3748
		end -- 3748
		persistHistoryState(shared) -- 3750
		__TS__Await(maybeCompressHistory(shared)) -- 3751
		persistHistoryState(shared) -- 3752
		return ____awaiter_resolve(nil, "main") -- 3752
	end) -- 3752
end -- 3740
local ListSubAgentsAction = __TS__Class() -- 3757
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3757
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3757
function ListSubAgentsAction.prototype.prep(self, shared) -- 3758
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3758
		local last = shared.history[#shared.history] -- 3768
		if not last then -- 3768
			error( -- 3769
				__TS__New(Error, "no history"), -- 3769
				0 -- 3769
			) -- 3769
		end -- 3769
		emitAgentStartEvent(shared, last) -- 3770
		return ____awaiter_resolve( -- 3770
			nil, -- 3770
			{ -- 3771
				sessionId = shared.sessionId, -- 3772
				projectRoot = shared.workingDir, -- 3773
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3774
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3775
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3776
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3777
				listSubAgents = shared.listSubAgents, -- 3778
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3779
			} -- 3779
		) -- 3779
	end) -- 3779
end -- 3758
function ListSubAgentsAction.prototype.exec(self, input) -- 3783
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3783
		if not input.listSubAgents then -- 3783
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3783
		end -- 3783
		if input.sessionId == nil or input.sessionId <= 0 then -- 3783
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3783
		end -- 3783
		local result = __TS__Await(input.listSubAgents({ -- 3799
			sessionId = input.sessionId, -- 3800
			projectRoot = input.projectRoot, -- 3801
			status = input.status, -- 3802
			limit = input.limit, -- 3803
			offset = input.offset, -- 3804
			query = input.query -- 3805
		})) -- 3805
		return ____awaiter_resolve( -- 3805
			nil, -- 3805
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3807
		) -- 3807
	end) -- 3807
end -- 3783
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3815
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3815
		local last = shared.history[#shared.history] -- 3816
		if last ~= nil then -- 3816
			last.result = execRes -- 3818
			appendToolResultMessage(shared, last) -- 3819
			emitAgentFinishEvent(shared, last) -- 3820
		end -- 3820
		persistHistoryState(shared) -- 3822
		__TS__Await(maybeCompressHistory(shared)) -- 3823
		persistHistoryState(shared) -- 3824
		return ____awaiter_resolve(nil, "main") -- 3824
	end) -- 3824
end -- 3815
EditFileAction = __TS__Class() -- 3829
EditFileAction.name = "EditFileAction" -- 3829
__TS__ClassExtends(EditFileAction, Node) -- 3829
function EditFileAction.prototype.prep(self, shared) -- 3830
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3830
		local last = shared.history[#shared.history] -- 3831
		if not last then -- 3831
			error( -- 3832
				__TS__New(Error, "no history"), -- 3832
				0 -- 3832
			) -- 3832
		end -- 3832
		emitAgentStartEvent(shared, last) -- 3833
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3834
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3837
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3838
		if __TS__StringTrim(path) == "" then -- 3838
			error( -- 3839
				__TS__New(Error, "missing path"), -- 3839
				0 -- 3839
			) -- 3839
		end -- 3839
		return ____awaiter_resolve(nil, { -- 3839
			path = path, -- 3840
			oldStr = oldStr, -- 3840
			newStr = newStr, -- 3840
			taskId = shared.taskId, -- 3840
			workDir = shared.workingDir -- 3840
		}) -- 3840
	end) -- 3840
end -- 3830
function EditFileAction.prototype.exec(self, input) -- 3843
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3843
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3844
		if not readRes.success then -- 3844
			if input.oldStr ~= "" then -- 3844
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3844
			end -- 3844
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3849
			if not createRes.success then -- 3849
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3849
			end -- 3849
			return ____awaiter_resolve( -- 3849
				nil, -- 3849
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3856
					success = true, -- 3857
					changed = true, -- 3858
					mode = "create", -- 3859
					checkpointId = createRes.checkpointId, -- 3860
					checkpointSeq = createRes.checkpointSeq, -- 3861
					files = {{path = input.path, op = "create"}} -- 3862
				}) -- 3862
			) -- 3862
		end -- 3862
		if input.oldStr == "" then -- 3862
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3862
				return ____awaiter_resolve( -- 3862
					nil, -- 3862
					{ -- 3867
						success = false, -- 3868
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3869
						actualSaved = false, -- 3870
						actualSavedCharacters = 0, -- 3871
						currentFileExists = true, -- 3872
						currentCharacters = #readRes.content, -- 3873
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3874
					} -- 3874
				) -- 3874
			end -- 3874
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3877
			if not overwriteRes.success then -- 3877
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3877
			end -- 3877
			return ____awaiter_resolve( -- 3877
				nil, -- 3877
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3884
					success = true, -- 3885
					changed = true, -- 3886
					mode = "overwrite", -- 3887
					checkpointId = overwriteRes.checkpointId, -- 3888
					checkpointSeq = overwriteRes.checkpointSeq, -- 3889
					files = {{path = input.path, op = "write"}} -- 3890
				}) -- 3890
			) -- 3890
		end -- 3890
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3895
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3896
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3897
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3900
		if occurrences == 0 then -- 3900
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3902
			if not indentTolerant.success then -- 3902
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3902
			end -- 3902
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3906
			if not applyRes.success then -- 3906
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3906
			end -- 3906
			return ____awaiter_resolve( -- 3906
				nil, -- 3906
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3913
					success = true, -- 3914
					changed = true, -- 3915
					mode = "replace_indent_tolerant", -- 3916
					checkpointId = applyRes.checkpointId, -- 3917
					checkpointSeq = applyRes.checkpointSeq, -- 3918
					files = {{path = input.path, op = "write"}} -- 3919
				}) -- 3919
			) -- 3919
		end -- 3919
		if occurrences > 1 then -- 3919
			return ____awaiter_resolve( -- 3919
				nil, -- 3919
				{ -- 3923
					success = false, -- 3923
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3923
				} -- 3923
			) -- 3923
		end -- 3923
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3927
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3928
		if not applyRes.success then -- 3928
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3928
		end -- 3928
		return ____awaiter_resolve( -- 3928
			nil, -- 3928
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3935
				success = true, -- 3936
				changed = true, -- 3937
				mode = "replace", -- 3938
				checkpointId = applyRes.checkpointId, -- 3939
				checkpointSeq = applyRes.checkpointSeq, -- 3940
				files = {{path = input.path, op = "write"}} -- 3941
			}) -- 3941
		) -- 3941
	end) -- 3941
end -- 3843
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3945
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3945
		local last = shared.history[#shared.history] -- 3946
		if last ~= nil then -- 3946
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3948
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3949
			appendToolResultMessage(shared, last) -- 3950
			emitAgentFinishEvent(shared, last) -- 3951
			local result = last.result -- 3952
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3952
				emitAgentEvent(shared, { -- 3957
					type = "checkpoint_created", -- 3958
					sessionId = shared.sessionId, -- 3959
					taskId = shared.taskId, -- 3960
					step = last.step, -- 3961
					tool = last.tool, -- 3962
					checkpointId = result.checkpointId, -- 3963
					checkpointSeq = result.checkpointSeq, -- 3964
					files = result.files -- 3965
				}) -- 3965
			end -- 3965
		end -- 3965
		persistHistoryState(shared) -- 3972
		__TS__Await(maybeCompressHistory(shared)) -- 3973
		persistHistoryState(shared) -- 3974
		return ____awaiter_resolve(nil, "main") -- 3974
	end) -- 3974
end -- 3945
local FetchUrlAction = __TS__Class() -- 3979
FetchUrlAction.name = "FetchUrlAction" -- 3979
__TS__ClassExtends(FetchUrlAction, Node) -- 3979
function FetchUrlAction.prototype.prep(self, shared) -- 3980
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3980
		local last = shared.history[#shared.history] -- 3981
		if not last then -- 3981
			error( -- 3982
				__TS__New(Error, "no history"), -- 3982
				0 -- 3982
			) -- 3982
		end -- 3982
		emitAgentStartEvent(shared, last) -- 3983
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3983
	end) -- 3983
end -- 3980
function FetchUrlAction.prototype.exec(self, input) -- 3987
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3987
		return ____awaiter_resolve( -- 3987
			nil, -- 3987
			executeToolAction(input.shared, input.action) -- 3988
		) -- 3988
	end) -- 3988
end -- 3987
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3991
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3991
		local last = shared.history[#shared.history] -- 3992
		if last ~= nil then -- 3992
			last.result = execRes -- 3994
			appendToolResultMessage(shared, last) -- 3995
			emitAgentFinishEvent(shared, last) -- 3996
		end -- 3996
		persistHistoryState(shared) -- 3998
		__TS__Await(maybeCompressHistory(shared)) -- 3999
		persistHistoryState(shared) -- 4000
		return ____awaiter_resolve(nil, "main") -- 4000
	end) -- 4000
end -- 3991
local function emitCheckpointEventForAction(shared, action) -- 4005
	local result = action.result -- 4006
	if not result then -- 4006
		return -- 4007
	end -- 4007
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4007
		emitAgentEvent(shared, { -- 4012
			type = "checkpoint_created", -- 4013
			sessionId = shared.sessionId, -- 4014
			taskId = shared.taskId, -- 4015
			step = action.step, -- 4016
			tool = action.tool, -- 4017
			checkpointId = result.checkpointId, -- 4018
			checkpointSeq = result.checkpointSeq, -- 4019
			files = result.files -- 4020
		}) -- 4020
	end -- 4020
end -- 4005
local function canRunBatchActionInParallel(self, action) -- 4551
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4552
end -- 4551
local function partitionToolCalls(actions) -- 4560
	local batches = {} -- 4561
	do -- 4561
		local i = 0 -- 4562
		while i < #actions do -- 4562
			local action = actions[i + 1] -- 4563
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4564
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4565
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4565
				local ____lastBatch_actions_187 = lastBatch.actions -- 4565
				____lastBatch_actions_187[#____lastBatch_actions_187 + 1] = action -- 4567
			else -- 4567
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4569
			end -- 4569
			i = i + 1 -- 4562
		end -- 4562
	end -- 4562
	return batches -- 4572
end -- 4560
local function completeStoppedToolAction(shared, action) -- 4575
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4576
	if not action.result then -- 4576
		action.result = { -- 4578
			success = false, -- 4578
			message = getCancelledReason(shared) -- 4578
		} -- 4578
	end -- 4578
	appendToolResultMessage(shared, action) -- 4580
	emitAgentFinishEvent(shared, action) -- 4581
	emitCheckpointEventForAction(shared, action) -- 4582
end -- 4575
local BatchToolAction = __TS__Class() -- 4585
BatchToolAction.name = "BatchToolAction" -- 4585
__TS__ClassExtends(BatchToolAction, Node) -- 4585
function BatchToolAction.prototype.prep(self, shared) -- 4586
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4586
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4586
	end) -- 4586
end -- 4586
function BatchToolAction.prototype.exec(self, input) -- 4590
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4590
		local shared = input.shared -- 4591
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4592
		local preExecuted = shared.preExecutedResults -- 4593
		local batches = partitionToolCalls(input.actions) -- 4594
		local parallelBatchCount = #__TS__ArrayFilter( -- 4595
			batches, -- 4595
			function(____, b) return b.isConcurrencySafe end -- 4595
		) -- 4595
		local serialBatchCount = #__TS__ArrayFilter( -- 4596
			batches, -- 4596
			function(____, b) return not b.isConcurrencySafe end -- 4596
		) -- 4596
		AgentUtils.Log( -- 4597
			"Info", -- 4597
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4597
		) -- 4597
		do -- 4597
			local batchIdx = 0 -- 4599
			while batchIdx < #batches do -- 4599
				do -- 4599
					local batch = batches[batchIdx + 1] -- 4600
					if shared.stopToken.stopped then -- 4600
						for ____, action in ipairs(batch.actions) do -- 4602
							completeStoppedToolAction(shared, action) -- 4603
						end -- 4603
						goto __continue761 -- 4605
					end -- 4605
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4605
						local preExecCount = #__TS__ArrayFilter( -- 4609
							batch.actions, -- 4609
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4609
						) -- 4609
						AgentUtils.Log( -- 4610
							"Info", -- 4610
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4610
						) -- 4610
						do -- 4610
							local i = 0 -- 4611
							while i < #batch.actions do -- 4611
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4612
								i = i + 1 -- 4611
							end -- 4611
						end -- 4611
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4614
							batch.actions, -- 4614
							function(____, action) -- 4614
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4614
									if shared.stopToken.stopped then -- 4614
										action.result = { -- 4616
											success = false, -- 4616
											message = getCancelledReason(shared) -- 4616
										} -- 4616
										return ____awaiter_resolve(nil, action) -- 4616
									end -- 4616
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4619
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4620
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4621
									return ____awaiter_resolve(nil, action) -- 4621
								end) -- 4621
							end -- 4614
						))) -- 4614
						do -- 4614
							local i = 0 -- 4624
							while i < #batch.actions do -- 4624
								local action = batch.actions[i + 1] -- 4625
								if not action.result then -- 4625
									action.result = {success = false, message = "tool did not produce a result"} -- 4627
								end -- 4627
								appendToolResultMessage(shared, action) -- 4629
								emitAgentFinishEvent(shared, action) -- 4630
								emitCheckpointEventForAction(shared, action) -- 4631
								i = i + 1 -- 4624
							end -- 4624
						end -- 4624
					else -- 4624
						AgentUtils.Log( -- 4634
							"Info", -- 4634
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4634
						) -- 4634
						do -- 4634
							local i = 0 -- 4635
							while i < #batch.actions do -- 4635
								local action = batch.actions[i + 1] -- 4636
								emitAgentStartEvent(shared, action) -- 4637
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4638
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4639
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4640
								appendToolResultMessage(shared, action) -- 4641
								emitAgentFinishEvent(shared, action) -- 4642
								emitCheckpointEventForAction(shared, action) -- 4643
								persistHistoryState(shared) -- 4644
								if shared.stopToken.stopped then -- 4644
									do -- 4644
										local j = i + 1 -- 4646
										while j < #batch.actions do -- 4646
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4647
											j = j + 1 -- 4646
										end -- 4646
									end -- 4646
									break -- 4649
								end -- 4649
								i = i + 1 -- 4635
							end -- 4635
						end -- 4635
					end -- 4635
				end -- 4635
				::__continue761:: -- 4635
				batchIdx = batchIdx + 1 -- 4599
			end -- 4599
		end -- 4599
		local spawnSeen = spawnedBeforeBatch -- 4654
		local didDelegatedForegroundWork = false -- 4655
		do -- 4655
			local i = 0 -- 4656
			while i < #input.actions do -- 4656
				do -- 4656
					local action = input.actions[i + 1] -- 4657
					if action.tool == "spawn_sub_agent" then -- 4657
						local ____opt_190 = action.result -- 4657
						if (____opt_190 and ____opt_190.success) == true then -- 4657
							spawnSeen = true -- 4659
						end -- 4659
						goto __continue781 -- 4660
					end -- 4660
					if spawnSeen and action.tool ~= "finish" then -- 4660
						didDelegatedForegroundWork = true -- 4663
					end -- 4663
				end -- 4663
				::__continue781:: -- 4663
				i = i + 1 -- 4656
			end -- 4656
		end -- 4656
		if didDelegatedForegroundWork then -- 4656
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4667
		end -- 4667
		persistHistoryState(shared) -- 4669
		return ____awaiter_resolve(nil, input.actions) -- 4669
	end) -- 4669
end -- 4590
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4673
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4673
		shared.pendingToolActions = nil -- 4674
		shared.preExecutedResults = nil -- 4675
		persistHistoryState(shared) -- 4676
		if shared.waitingQuestionnaireId == nil then -- 4676
			__TS__Await(maybeCompressHistory(shared)) -- 4680
			persistHistoryState(shared) -- 4681
		end -- 4681
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4681
	end) -- 4681
end -- 4673
local EndNode = __TS__Class() -- 4687
EndNode.name = "EndNode" -- 4687
__TS__ClassExtends(EndNode, Node) -- 4687
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4688
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4688
		return ____awaiter_resolve(nil, nil) -- 4688
	end) -- 4688
end -- 4688
local CodingAgentFlow = __TS__Class() -- 4693
CodingAgentFlow.name = "CodingAgentFlow" -- 4693
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4693
function CodingAgentFlow.prototype.____constructor(self, role) -- 4694
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4695
	local read = __TS__New(ReadFileAction, 1, 0) -- 4696
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4697
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4698
	local list = __TS__New(ListFilesAction, 1, 0) -- 4699
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4700
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4701
	local build = __TS__New(BuildAction, 1, 0) -- 4702
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4703
	local edit = __TS__New(EditFileAction, 1, 0) -- 4704
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4705
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4706
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4707
	local done = __TS__New(EndNode, 1, 0) -- 4708
	main:on("batch_tools", batch) -- 4710
	main:on("grep_files", search) -- 4711
	main:on("search_dora_api", searchDora) -- 4712
	main:on("glob_files", list) -- 4713
	main:on("fetch_url", fetch) -- 4714
	main:on("execute_command", exec) -- 4715
	if role == "main" then -- 4715
		main:on("read_file", read) -- 4717
		main:on("delete_file", del) -- 4718
		main:on("build", build) -- 4719
		main:on("edit_file", edit) -- 4720
		main:on("list_sub_agents", listSub) -- 4721
		main:on("spawn_sub_agent", spawn) -- 4722
	else -- 4722
		main:on("read_file", read) -- 4724
		main:on("delete_file", del) -- 4725
		main:on("build", build) -- 4726
		main:on("edit_file", edit) -- 4727
	end -- 4727
	main:on("done", done) -- 4729
	search:on("main", main) -- 4731
	searchDora:on("main", main) -- 4732
	list:on("main", main) -- 4733
	listSub:on("main", main) -- 4734
	spawn:on("main", main) -- 4735
	batch:on("main", main) -- 4736
	batch:on("done", done) -- 4737
	read:on("main", main) -- 4738
	del:on("main", main) -- 4739
	build:on("main", main) -- 4740
	edit:on("main", main) -- 4741
	fetch:on("main", main) -- 4742
	exec:on("main", main) -- 4743
	Flow.prototype.____constructor(self, main) -- 4745
end -- 4694
local function runCodingAgentAsync(options) -- 4781
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4781
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4781
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4781
		end -- 4781
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4785
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4786
		if not llmConfigRes.success then -- 4786
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4786
		end -- 4786
		local llmConfig = llmConfigRes.config -- 4792
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4793
		if not taskRes.success then -- 4793
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4793
		end -- 4793
		local compressor = __TS__New(MemoryCompressor, { -- 4800
			compressionTargetThreshold = 0.5, -- 4801
			maxCompressionRounds = 3, -- 4802
			projectDir = options.workDir, -- 4803
			llmConfig = llmConfig, -- 4804
			promptPack = options.promptPack, -- 4805
			scope = options.memoryScope -- 4806
		}) -- 4806
		local persistedSession = compressor:getStorage():readSessionState() -- 4808
		local effectiveUserQuery = normalizedPrompt -- 4809
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4809
			do -- 4809
				local i = #persistedSession.messages - 1 -- 4811
				while i >= 0 do -- 4811
					local message = persistedSession.messages[i + 1] -- 4812
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4812
						effectiveUserQuery = message.content -- 4814
						break -- 4815
					end -- 4815
					i = i - 1 -- 4811
				end -- 4811
			end -- 4811
		end -- 4811
		local promptPack = compressor:getPromptPack() -- 4819
		local freshProject = inspectFreshProject(options.workDir) -- 4820
		local freshProjectBuildPending = freshProject.fresh -- 4821
		local freshProjectCodeFile = freshProject.codeFile -- 4822
		local shared = { -- 4824
			sessionId = options.sessionId, -- 4825
			taskId = taskRes.taskId, -- 4826
			role = options.role or "main", -- 4827
			maxSteps = math.max( -- 4828
				1, -- 4828
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4828
			), -- 4828
			llmMaxTry = math.max( -- 4829
				1, -- 4829
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4829
			), -- 4829
			step = math.max( -- 4830
				0, -- 4830
				math.floor(options.initialStep or 0) -- 4830
			), -- 4830
			agentStepCount = math.max( -- 4831
				0, -- 4831
				math.floor(options.initialAgentStepCount or 0) -- 4831
			), -- 4831
			done = false, -- 4832
			stopToken = options.stopToken or ({stopped = false}), -- 4833
			response = "", -- 4834
			userQuery = effectiveUserQuery, -- 4835
			workingDir = options.workDir, -- 4836
			useChineseResponse = options.useChineseResponse == true, -- 4837
			workMode = options.workMode or "code", -- 4838
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4839
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4842
			llmConfig = llmConfig, -- 4843
			onEvent = options.onEvent, -- 4844
			promptPack = promptPack, -- 4845
			history = {}, -- 4846
			messages = persistedSession.messages, -- 4847
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4848
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4849
			memory = {compressor = compressor}, -- 4851
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4855
				projectDir = options.workDir, -- 4857
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4858
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4859
			})}, -- 4859
			spawnSubAgent = options.spawnSubAgent, -- 4865
			listSubAgents = options.listSubAgents, -- 4866
			publishQuestionnaire = options.publishQuestionnaire, -- 4867
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4868
			freshProjectBuildPending = freshProjectBuildPending, -- 4869
			freshProjectCodeFile = freshProjectCodeFile, -- 4870
			hasSpawnedSubAgentThisTask = false, -- 4871
			delegatedForegroundBatches = 0, -- 4872
			tokenUsage = options.initialTokenUsage -- 4873
		} -- 4873
		local ____hasReturned, ____returnValue -- 4873
		local ____try = __TS__AsyncAwaiter(function() -- 4873
			if shared.workMode == "plan" then -- 4873
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4878
				if not planDocuments.success then -- 4878
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4880
					____hasReturned = true -- 4881
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4881
					return -- 4881
				end -- 4881
			end -- 4881
			emitAgentEvent(shared, { -- 4884
				type = "task_started", -- 4885
				sessionId = shared.sessionId, -- 4886
				taskId = shared.taskId, -- 4887
				prompt = shared.userQuery, -- 4888
				workDir = shared.workingDir, -- 4889
				maxSteps = shared.maxSteps, -- 4890
				resumed = options.resumeTask == true -- 4891
			}) -- 4891
			if shared.stopToken.stopped then -- 4891
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4894
				____hasReturned = true -- 4895
				____returnValue = emitAgentTaskFinishEvent( -- 4895
					shared, -- 4895
					false, -- 4895
					getCancelledReason(shared) -- 4895
				) -- 4895
				return -- 4895
			end -- 4895
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4897
			local ____temp_192 -- 4898
			if options.resumeConversation == true then -- 4898
				____temp_192 = nil -- 4898
			else -- 4898
				____temp_192 = getPromptCommand(shared.userQuery) -- 4898
			end -- 4898
			local promptCommand = ____temp_192 -- 4898
			if promptCommand == "clear" then -- 4898
				____hasReturned = true -- 4900
				____returnValue = clearSessionHistory(shared) -- 4900
				return -- 4900
			end -- 4900
			if promptCommand == "compact" then -- 4900
				if shared.role == "sub" then -- 4900
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4904
					____hasReturned = true -- 4905
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4905
					return -- 4905
				end -- 4905
				____hasReturned = true -- 4913
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4913
				return -- 4913
			end -- 4913
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4915
			if shared.stopToken.stopped then -- 4915
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4917
				____hasReturned = true -- 4918
				____returnValue = emitAgentTaskFinishEvent( -- 4918
					shared, -- 4918
					false, -- 4918
					getCancelledReason(shared) -- 4918
				) -- 4918
				return -- 4918
			end -- 4918
			if options.resumeConversation ~= true then -- 4918
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4921
				persistHistoryState(shared) -- 4925
			end -- 4925
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4927
			__TS__Await(flow:run(shared)) -- 4928
			if shared.stopToken.stopped then -- 4928
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4930
				____hasReturned = true -- 4931
				____returnValue = emitAgentTaskFinishEvent( -- 4931
					shared, -- 4931
					false, -- 4931
					getCancelledReason(shared) -- 4931
				) -- 4931
				return -- 4931
			end -- 4931
			if shared.error then -- 4931
				____hasReturned = true -- 4934
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4934
				return -- 4934
			end -- 4934
			if shared.waitingQuestionnaireId ~= nil then -- 4934
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4938
				emitAgentEvent(shared, { -- 4939
					type = "task_waiting_for_user", -- 4940
					sessionId = shared.sessionId, -- 4941
					taskId = shared.taskId, -- 4942
					step = shared.step, -- 4943
					questionnaireId = shared.waitingQuestionnaireId -- 4944
				}) -- 4944
				____hasReturned = true -- 4946
				____returnValue = { -- 4946
					success = true, -- 4947
					taskId = shared.taskId, -- 4948
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4949
					steps = shared.step, -- 4950
					waitingForUser = true, -- 4951
					questionnaireId = shared.waitingQuestionnaireId -- 4952
				} -- 4952
				return -- 4946
			end -- 4946
			local ____isFinalDecisionTurn_result_195 = isFinalDecisionTurn(shared) -- 4955
			if ____isFinalDecisionTurn_result_195 then -- 4955
				local ____opt_193 = shared.completion -- 4955
				____isFinalDecisionTurn_result_195 = (____opt_193 and ____opt_193.outcome) == "partial" -- 4955
			end -- 4955
			if ____isFinalDecisionTurn_result_195 then -- 4955
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4956
				____hasReturned = true -- 4957
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4957
				return -- 4957
			end -- 4957
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4960
			____hasReturned = true -- 4961
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4961
			return -- 4961
		end) -- 4961
		____try = ____try.catch( -- 4961
			____try, -- 4961
			function(____, e) -- 4961
				return __TS__AsyncAwaiter(function() -- 4961
					____hasReturned = true -- 4964
					____returnValue = finalizeAgentFailure( -- 4964
						shared, -- 4964
						tostring(e) -- 4964
					) -- 4964
					return -- 4964
				end) -- 4964
			end -- 4964
		) -- 4964
		__TS__Await(____try) -- 4876
		if ____hasReturned then -- 4876
			return ____awaiter_resolve(nil, ____returnValue) -- 4876
		end -- 4876
	end) -- 4876
end -- 4781
function ____exports.runCodingAgent(options, callback) -- 4968
	local ____self_196 = runCodingAgentAsync(options) -- 4968
	____self_196["then"]( -- 4968
		____self_196, -- 4968
		function(____, result) return callback(result) end -- 4969
	) -- 4969
end -- 4968
return ____exports -- 4968