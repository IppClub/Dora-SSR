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
	if tool ~= "grep_files" and tool ~= "search_dora_doc" then -- 1021
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
	local params = {SEARCH_DORA_DOC_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax)} -- 1292
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1293
	local base = shared.promptPack.toolDefinitionsDetailed -- 1296
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1297
	if usesDefaultToolPrompts then -- 1297
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1300
			shared.role, -- 1300
			{ -- 1300
				includeFinish = true, -- 1301
				includeXmlRules = true, -- 1302
				context = {searchDoraDocLimitMax = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax}, -- 1303
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
				"search_dora_doc", -- 1924
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
	if hasXMLParam(params, "docType") or hasXMLParam(params, "programmingLanguage") then -- 2004
		if hasXMLParam(params, "pattern") then -- 2004
			return "search_dora_doc" -- 2007
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
	if tool == "search_dora_doc" then -- 2497
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2501
		if pattern == "" then -- 2501
			return {success = false, message = "search_dora_doc requires pattern"} -- 2502
		end -- 2502
		local docType = type(params.docType) == "string" and params.docType or "dora-api" -- 2503
		if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 2503
			return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 2505
		end -- 2505
		params.pattern = pattern -- 2507
		params.docType = docType -- 2508
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 2509
		return {success = true, params = params} -- 2510
	end -- 2510
	if tool == "glob_files" then -- 2510
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2514
		return {success = true, params = params} -- 2515
	end -- 2515
	if tool == "build" then -- 2515
		local path = getDecisionPath(params) -- 2519
		if path ~= "" then -- 2519
			params.path = path -- 2521
		end -- 2521
		return {success = true, params = params} -- 2523
	end -- 2523
	if tool == "list_sub_agents" then -- 2523
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2527
		if status ~= "" then -- 2527
			params.status = status -- 2529
		end -- 2529
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2531
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2532
		if type(params.query) == "string" then -- 2532
			params.query = __TS__StringTrim(params.query) -- 2534
		end -- 2534
		return {success = true, params = params} -- 2536
	end -- 2536
	if tool == "spawn_sub_agent" then -- 2536
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2540
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2541
		if prompt == "" then -- 2541
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2542
		end -- 2542
		if title == "" then -- 2542
			return {success = false, message = "spawn_sub_agent requires title"} -- 2543
		end -- 2543
		params.prompt = prompt -- 2544
		params.title = title -- 2545
		if type(params.expectedOutput) == "string" then -- 2545
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2547
		end -- 2547
		if isArray(params.filesHint) then -- 2547
			params.filesHint = __TS__ArrayMap( -- 2550
				__TS__ArrayFilter( -- 2550
					params.filesHint, -- 2550
					function(____, item) return type(item) == "string" end -- 2551
				), -- 2551
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2552
			) -- 2552
		end -- 2552
		return {success = true, params = params} -- 2554
	end -- 2554
	return {success = true, params = params} -- 2557
end -- 2557
function validateCompletionForRole(role, tool, params) -- 2560
	if role ~= "sub" or tool ~= "finish" then -- 2560
		return {success = true} -- 2565
	end -- 2565
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2565
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2567
	end -- 2567
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2569
	do -- 2569
		local i = 0 -- 2570
		while i < #requiredArrays do -- 2570
			local name = requiredArrays[i + 1] -- 2571
			if not isArray(params[name]) then -- 2571
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2573
			end -- 2573
			i = i + 1 -- 2570
		end -- 2570
	end -- 2570
	return {success = true} -- 2576
end -- 2576
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2579
	if includeToolDefinitions == nil then -- 2579
		includeToolDefinitions = false -- 2579
	end -- 2579
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2580
	local sections = { -- 2583
		shared.promptPack.agentIdentityPrompt, -- 2584
		rolePrompt, -- 2585
		getReplyLanguageDirective(shared) -- 2586
	} -- 2586
	if shared.role == "main" then -- 2586
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2589
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2590
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2590
			sections[#sections + 1] = table.concat( -- 2592
				{ -- 2592
					"# Current Living Development Plan", -- 2593
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2594
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2594
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2595
						12000 -- 2595
					), -- 2595
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2595
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2596
						12000 -- 2596
					) -- 2596
				}, -- 2596
				"\n\n" -- 2597
			) -- 2597
		end -- 2597
	end -- 2597
	if shared.decisionMode == "tool_calling" then -- 2597
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2601
	end -- 2601
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2603
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2604
	if memoryContext ~= "" then -- 2604
		sections[#sections + 1] = memoryContext -- 2606
	end -- 2606
	local skillsSection = buildSkillsSection(shared) -- 2608
	if skillsSection ~= "" then -- 2608
		sections[#sections + 1] = skillsSection -- 2610
	end -- 2610
	if includeToolDefinitions then -- 2610
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2613
		if shared.decisionMode == "xml" then -- 2613
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2615
		end -- 2615
	end -- 2615
	return table.concat(sections, "\n\n") -- 2618
end -- 2618
function buildSkillsSection(shared) -- 2621
	local ____opt_69 = shared.skills -- 2621
	if not (____opt_69 and ____opt_69.loader) then -- 2621
		return "" -- 2623
	end -- 2623
	return shared.skills.loader:buildSkillsPromptSection() -- 2625
end -- 2625
function sanitizeMessagesForLLMInput(messages) -- 2628
	local sanitized = {} -- 2629
	local droppedAssistantToolCalls = 0 -- 2630
	local droppedToolResults = 0 -- 2631
	do -- 2631
		local i = 0 -- 2632
		while i < #messages do -- 2632
			do -- 2632
				local message = messages[i + 1] -- 2633
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2633
					local requiredIds = {} -- 2635
					do -- 2635
						local j = 0 -- 2636
						while j < #message.tool_calls do -- 2636
							local toolCall = message.tool_calls[j + 1] -- 2637
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2638
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2638
								requiredIds[#requiredIds + 1] = id -- 2640
							end -- 2640
							j = j + 1 -- 2636
						end -- 2636
					end -- 2636
					if #requiredIds == 0 then -- 2636
						sanitized[#sanitized + 1] = message -- 2644
						goto __continue454 -- 2645
					end -- 2645
					local matchedIds = {} -- 2647
					local matchedTools = {} -- 2648
					local j = i + 1 -- 2649
					while j < #messages do -- 2649
						local toolMessage = messages[j + 1] -- 2651
						if toolMessage.role ~= "tool" then -- 2651
							break -- 2652
						end -- 2652
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2653
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2653
							matchedIds[toolCallId] = true -- 2655
							matchedTools[#matchedTools + 1] = toolMessage -- 2656
						else -- 2656
							droppedToolResults = droppedToolResults + 1 -- 2658
						end -- 2658
						j = j + 1 -- 2660
					end -- 2660
					local complete = true -- 2662
					do -- 2662
						local j = 0 -- 2663
						while j < #requiredIds do -- 2663
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2663
								complete = false -- 2665
								break -- 2666
							end -- 2666
							j = j + 1 -- 2663
						end -- 2663
					end -- 2663
					if complete then -- 2663
						__TS__ArrayPush( -- 2670
							sanitized, -- 2670
							message, -- 2670
							table.unpack(matchedTools) -- 2670
						) -- 2670
					else -- 2670
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2672
						droppedToolResults = droppedToolResults + #matchedTools -- 2673
					end -- 2673
					i = j - 1 -- 2675
					goto __continue454 -- 2676
				end -- 2676
				if message.role == "tool" then -- 2676
					droppedToolResults = droppedToolResults + 1 -- 2679
					goto __continue454 -- 2680
				end -- 2680
				sanitized[#sanitized + 1] = message -- 2682
			end -- 2682
			::__continue454:: -- 2682
			i = i + 1 -- 2632
		end -- 2632
	end -- 2632
	return sanitized -- 2684
end -- 2684
function getUnconsolidatedMessages(shared) -- 2687
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2688
end -- 2688
function isFinalDecisionTurn(shared) -- 2693
	return shared.agentStepCount + 1 >= shared.maxSteps -- 2694
end -- 2694
function getFinalDecisionTurnPrompt(shared) -- 2697
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2698
end -- 2698
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2703
	if attempt == nil then -- 2703
		attempt = 1 -- 2706
	end -- 2706
	if decisionMode == nil then -- 2706
		decisionMode = shared.decisionMode -- 2708
	end -- 2708
	if consumeResumeCheckpoint == nil then -- 2708
		consumeResumeCheckpoint = true -- 2709
	end -- 2709
	if pendingUserPrompt == nil then -- 2709
		pendingUserPrompt = "" -- 2710
	end -- 2710
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2712
	local tailSections = {} -- 2713
	if shared.resumeCheckpointPending == true then -- 2713
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2719
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2723
	end -- 2723
	if shared.truncatedToolOverwritePath ~= nil then -- 2723
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2726
	end -- 2726
	if consumeResumeCheckpoint then -- 2726
		shared.resumeCheckpointPending = false -- 2728
	end -- 2728
	local messages = { -- 2729
		{role = "system", content = systemPrompt}, -- 2730
		table.unpack(getUnconsolidatedMessages(shared)) -- 2731
	} -- 2731
	if pendingUserPrompt ~= "" then -- 2731
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2734
	end -- 2734
	if isFinalDecisionTurn(shared) then -- 2734
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2737
	end -- 2737
	if lastError and lastError ~= "" then -- 2737
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2740
		if decisionMode == "xml" then -- 2740
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2744
		end -- 2744
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2744
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2747
		end -- 2747
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2747
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2750
		end -- 2750
		messages[#messages + 1] = { -- 2752
			role = "user", -- 2753
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2754
		} -- 2754
	end -- 2754
	if #tailSections > 0 then -- 2754
		messages[#messages + 1] = { -- 2762
			role = "user", -- 2763
			content = table.concat(tailSections, "\n\n") -- 2764
		} -- 2764
	end -- 2764
	return messages -- 2767
end -- 2767
function buildXmlDecisionInstruction(shared, feedback) -- 2770
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2771
end -- 2771
function tryParseAndValidateDecision(rawText, shared) -- 2839
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2840
	if not parsed.success then -- 2840
		return {success = false, message = parsed.message, raw = rawText} -- 2842
	end -- 2842
	local decision = parseDecisionObject(parsed.obj) -- 2844
	if not decision.success then -- 2844
		return {success = false, message = decision.message, raw = rawText} -- 2846
	end -- 2846
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2848
	if not completionValidation.success then -- 2848
		return {success = false, message = completionValidation.message, raw = rawText} -- 2850
	end -- 2850
	local validation = validateDecision(decision.tool, decision.params) -- 2852
	if not validation.success then -- 2852
		return {success = false, message = validation.message, raw = rawText} -- 2854
	end -- 2854
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2856
	if not sharedValidation.success then -- 2856
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2858
	end -- 2858
	decision.params = validation.params -- 2860
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2861
	return decision -- 2862
end -- 2862
function executeToolAction(shared, action) -- 4033
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4033
		if shared.stopToken.stopped then -- 4033
			return ____awaiter_resolve( -- 4033
				nil, -- 4033
				{ -- 4035
					success = false, -- 4035
					message = getCancelledReason(shared) -- 4035
				} -- 4035
			) -- 4035
		end -- 4035
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4035
			shared.resumeRequiredTool = nil -- 4038
			shared.resumeCheckpointPending = false -- 4039
		end -- 4039
		local params = action.params -- 4041
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4042
		if not sharedValidation.success then -- 4042
			return ____awaiter_resolve(nil, sharedValidation) -- 4042
		end -- 4042
		if action.tool == "read_file" then -- 4042
			local ____params_startLine_149 = params.startLine -- 4045
			if ____params_startLine_149 == nil then -- 4045
				____params_startLine_149 = 1 -- 4045
			end -- 4045
			local startLine = __TS__Number(____params_startLine_149) -- 4045
			local ____params_endLine_150 = params.endLine -- 4046
			if ____params_endLine_150 == nil then -- 4046
				____params_endLine_150 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4046
			end -- 4046
			local endLine = __TS__Number(____params_endLine_150) -- 4046
			local clippedAfterCompression = false -- 4047
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4047
				endLine = startLine + 159 -- 4054
				clippedAfterCompression = true -- 4055
			end -- 4055
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4057
			if __TS__StringTrim(path) == "" then -- 4057
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4057
			end -- 4057
			local result = Tools.readFile( -- 4061
				shared.workingDir, -- 4062
				path, -- 4063
				startLine, -- 4064
				endLine, -- 4065
				shared.useChineseResponse and "zh" or "en" -- 4066
			) -- 4066
			if clippedAfterCompression and result.success == true then -- 4066
				result.clipped = true -- 4069
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4070
			end -- 4070
			return ____awaiter_resolve(nil, result) -- 4070
		end -- 4070
		if action.tool == "grep_files" then -- 4070
			local searchPath = params.path or "" -- 4077
			local searchGlobs = params.globs -- 4078
			local ____Tools_searchFiles_164 = Tools.searchFiles -- 4079
			local ____shared_workingDir_157 = shared.workingDir -- 4080
			local ____temp_158 = params.pattern or "" -- 4082
			local ____params_globs_159 = params.globs -- 4083
			local ____params_useRegex_160 = params.useRegex -- 4084
			local ____params_caseSensitive_161 = params.caseSensitive -- 4085
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4087
			local ____math_max_153 = math.max -- 4088
			local ____math_floor_152 = math.floor -- 4088
			local ____params_limit_151 = params.limit -- 4088
			if ____params_limit_151 == nil then -- 4088
				____params_limit_151 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4088
			end -- 4088
			local ____math_max_153_result_163 = ____math_max_153( -- 4088
				1, -- 4088
				____math_floor_152(__TS__Number(____params_limit_151)) -- 4088
			) -- 4088
			local ____math_max_156 = math.max -- 4089
			local ____math_floor_155 = math.floor -- 4089
			local ____params_offset_154 = params.offset -- 4089
			if ____params_offset_154 == nil then -- 4089
				____params_offset_154 = 0 -- 4089
			end -- 4089
			local result = __TS__Await(____Tools_searchFiles_164({ -- 4079
				workDir = ____shared_workingDir_157, -- 4080
				path = searchPath, -- 4081
				pattern = ____temp_158, -- 4082
				globs = ____params_globs_159, -- 4083
				useRegex = ____params_useRegex_160, -- 4084
				caseSensitive = ____params_caseSensitive_161, -- 4085
				includeContent = true, -- 4086
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162, -- 4087
				limit = ____math_max_153_result_163, -- 4088
				offset = ____math_max_156( -- 4089
					0, -- 4089
					____math_floor_155(__TS__Number(____params_offset_154)) -- 4089
				), -- 4089
				groupByFile = params.groupByFile == true -- 4090
			})) -- 4090
			return ____awaiter_resolve(nil, result) -- 4090
		end -- 4090
		if action.tool == "search_dora_doc" then -- 4090
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4095
			local ____Tools_searchDoraDoc_173 = Tools.searchDoraDoc -- 4096
			local ____temp_169 = params.pattern or "" -- 4097
			local ____temp_170 = params.docType or "dora-api" -- 4098
			local ____temp_171 = shared.useChineseResponse and "zh" or "en" -- 4099
			local ____temp_172 = params.programmingLanguage or "ts" -- 4100
			local ____math_min_168 = math.min -- 4101
			local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_167 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 4101
			local ____math_max_166 = math.max -- 4101
			local ____params_limit_165 = params.limit -- 4101
			if ____params_limit_165 == nil then -- 4101
				____params_limit_165 = 8 -- 4101
			end -- 4101
			local result = __TS__Await(____Tools_searchDoraDoc_173({ -- 4096
				pattern = ____temp_169, -- 4097
				docType = ____temp_170, -- 4098
				docLanguage = ____temp_171, -- 4099
				programmingLanguage = ____temp_172, -- 4100
				limit = ____math_min_168( -- 4101
					____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_167, -- 4101
					____math_max_166( -- 4101
						1, -- 4101
						__TS__Number(____params_limit_165) -- 4101
					) -- 4101
				), -- 4101
				useRegex = params.useRegex, -- 4102
				caseSensitive = false, -- 4103
				includeContent = true, -- 4104
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4105
			})) -- 4105
			return ____awaiter_resolve(nil, result) -- 4105
		end -- 4105
		if action.tool == "glob_files" then -- 4105
			local ____Tools_listFiles_180 = Tools.listFiles -- 4110
			local ____shared_workingDir_177 = shared.workingDir -- 4111
			local ____temp_178 = params.path or "" -- 4112
			local ____params_globs_179 = params.globs -- 4113
			local ____math_max_176 = math.max -- 4114
			local ____math_floor_175 = math.floor -- 4114
			local ____params_maxEntries_174 = params.maxEntries -- 4114
			if ____params_maxEntries_174 == nil then -- 4114
				____params_maxEntries_174 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4114
			end -- 4114
			local result = ____Tools_listFiles_180({ -- 4110
				workDir = ____shared_workingDir_177, -- 4111
				path = ____temp_178, -- 4112
				globs = ____params_globs_179, -- 4113
				maxEntries = ____math_max_176( -- 4114
					1, -- 4114
					____math_floor_175(__TS__Number(____params_maxEntries_174)) -- 4114
				) -- 4114
			}) -- 4114
			return ____awaiter_resolve(nil, result) -- 4114
		end -- 4114
		if action.tool == "ask_user" then -- 4114
			if not shared.publishQuestionnaire then -- 4114
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4114
			end -- 4114
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4114
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4114
			end -- 4114
			local normalized = normalizeQuestionnaire(params) -- 4121
			if not normalized.success then -- 4121
				return ____awaiter_resolve(nil, normalized) -- 4121
			end -- 4121
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4123
			if not result.success then -- 4123
				return ____awaiter_resolve(nil, result) -- 4123
			end -- 4123
			shared.waitingQuestionnaireId = result.questionnaireId -- 4130
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4130
		end -- 4130
		if action.tool == "delete_file" then -- 4130
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4134
			if __TS__StringTrim(targetFile) == "" then -- 4134
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4134
			end -- 4134
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4138
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4139
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4139
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4139
			end -- 4139
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4143
			local result = Tools.deleteFile(shared.taskId, shared.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4144
			if not result.success then -- 4144
				return ____awaiter_resolve(nil, result) -- 4144
			end -- 4144
			if not isInternalDocumentEdit then -- 4144
				shared.unbuiltEdits = true -- 4152
				shared.lastBuildSucceeded = false -- 4153
				if shared.failedTestNeedsBuild == true then -- 4153
					shared.failedTestHasSourceEdit = true -- 4154
				end -- 4154
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4154
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4155
				end -- 4155
				shared.editedPathsSinceBuild = editedPaths -- 4156
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4157
			end -- 4157
			local ____result_checkpointed_182 = result.checkpointed -- 4163
			local ____result_reversible_183 = result.reversible -- 4164
			local ____result_binary_184 = result.binary -- 4165
			local ____temp_185 = result.checkpointed and result.checkpointId or nil -- 4166
			local ____temp_186 = result.checkpointed and result.checkpointSeq or nil -- 4167
			local ____result_checkpointed_181 -- 4168
			if result.checkpointed then -- 4168
				____result_checkpointed_181 = nil -- 4168
			else -- 4168
				____result_checkpointed_181 = result.message -- 4168
			end -- 4168
			return ____awaiter_resolve(nil, { -- 4168
				success = true, -- 4160
				changed = true, -- 4161
				mode = "delete", -- 4162
				checkpointed = ____result_checkpointed_182, -- 4163
				reversible = ____result_reversible_183, -- 4164
				binary = ____result_binary_184, -- 4165
				checkpointId = ____temp_185, -- 4166
				checkpointSeq = ____temp_186, -- 4167
				message = ____result_checkpointed_181, -- 4168
				files = {{path = targetFile, op = "delete"}} -- 4169
			}) -- 4169
		end -- 4169
		if action.tool == "build" then -- 4169
			local buildPath = params.path or "" -- 4173
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4174
			shared.unbuiltEdits = false -- 4178
			shared.editsSinceBuild = 0 -- 4179
			shared.editedPathsSinceBuild = {} -- 4180
			shared.hasBuilt = true -- 4181
			shared.lastBuildSucceeded = result.success -- 4182
			if result.success and shared.freshProjectBuildPending == true then -- 4182
				shared.freshProjectBuildPending = false -- 4188
			end -- 4188
			shared.apiSearchesSinceBuild = 0 -- 4190
			shared.buildRepairPending = false -- 4191
			if not result.success and result.messages ~= nil then -- 4191
				do -- 4191
					local i = 0 -- 4193
					while i < #result.messages do -- 4193
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4193
							shared.buildRepairPending = true -- 4195
							break -- 4196
						end -- 4196
						i = i + 1 -- 4193
					end -- 4193
				end -- 4193
			end -- 4193
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4193
				shared.failedTestNeedsBuild = false -- 4201
				shared.failedTestHasSourceEdit = false -- 4202
			end -- 4202
			return ____awaiter_resolve(nil, result) -- 4202
		end -- 4202
		if action.tool == "fetch_url" then -- 4202
			local result = __TS__Await(Tools.fetchUrl({ -- 4207
				workDir = shared.workingDir, -- 4208
				url = type(params.url) == "string" and params.url or "", -- 4209
				target = type(params.target) == "string" and params.target or "", -- 4210
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4211
				onProgress = function(____, progress) -- 4212
					emitAgentEvent( -- 4213
						shared, -- 4213
						{ -- 4213
							type = "tool_progress", -- 4214
							sessionId = shared.sessionId, -- 4215
							taskId = shared.taskId, -- 4216
							step = action.step, -- 4217
							tool = action.tool, -- 4218
							result = __TS__ObjectAssign({success = false}, progress) -- 4219
						} -- 4219
					) -- 4219
				end -- 4212
			})) -- 4212
			return ____awaiter_resolve(nil, result) -- 4212
		end -- 4212
		if action.tool == "execute_command" then -- 4212
			local mode = type(params.mode) == "string" and params.mode or "" -- 4229
			local result = __TS__Await(Tools.executeCommand({ -- 4230
				workDir = shared.workingDir, -- 4231
				mode = mode, -- 4232
				code = type(params.code) == "string" and params.code or nil, -- 4233
				command = type(params.command) == "string" and params.command or nil, -- 4234
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4235
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4236
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4237
				onProgress = function(____, progress) -- 4238
					emitAgentEvent( -- 4239
						shared, -- 4239
						{ -- 4239
							type = "tool_progress", -- 4240
							sessionId = shared.sessionId, -- 4241
							taskId = shared.taskId, -- 4242
							step = action.step, -- 4243
							tool = action.tool, -- 4244
							result = __TS__ObjectAssign({success = false}, progress) -- 4245
						} -- 4245
					) -- 4245
				end -- 4238
			})) -- 4238
			if result.success and mode == "lua" then -- 4238
				local deterministicFailure = false -- 4253
				local deterministicPass = false -- 4254
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4255
				do -- 4255
					local i = 0 -- 4256
					while i < #outputLines and not deterministicFailure do -- 4256
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4257
						if line == "passed" then -- 4257
							deterministicPass = true -- 4258
						end -- 4258
						if line == "failed" then -- 4258
							deterministicFailure = true -- 4260
							break -- 4261
						end -- 4261
						local searchFrom = 0 -- 4263
						while searchFrom < #line do -- 4263
							local failedIndex = (string.find( -- 4265
								line, -- 4265
								"failed", -- 4265
								math.max(searchFrom + 1, 1), -- 4265
								true -- 4265
							) or 0) - 1 -- 4265
							if failedIndex < 0 then -- 4265
								break -- 4266
							end -- 4266
							local after = failedIndex + #"failed" -- 4267
							while after < #line do -- 4267
								local ch = __TS__StringSlice(line, after, after + 1) -- 4269
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4269
									break -- 4270
								end -- 4270
								after = after + 1 -- 4271
							end -- 4271
							local afterEnd = after -- 4273
							while afterEnd < #line do -- 4273
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4275
								if ch < "0" or ch > "9" then -- 4275
									break -- 4276
								end -- 4276
								afterEnd = afterEnd + 1 -- 4277
							end -- 4277
							local count -- 4279
							if afterEnd > after then -- 4279
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4281
							else -- 4281
								local before = failedIndex - 1 -- 4283
								while before >= 0 do -- 4283
									local ch = __TS__StringSlice(line, before, before + 1) -- 4285
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4285
										break -- 4286
									end -- 4286
									before = before - 1 -- 4287
								end -- 4287
								local beforeEnd = before + 1 -- 4289
								while before >= 0 do -- 4289
									local ch = __TS__StringSlice(line, before, before + 1) -- 4291
									if ch < "0" or ch > "9" then -- 4291
										break -- 4292
									end -- 4292
									before = before - 1 -- 4293
								end -- 4293
								if beforeEnd > before + 1 then -- 4293
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4295
								end -- 4295
							end -- 4295
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4295
								deterministicFailure = true -- 4298
								break -- 4299
							end -- 4299
							searchFrom = failedIndex + #"failed" -- 4301
						end -- 4301
						i = i + 1 -- 4256
					end -- 4256
				end -- 4256
				if deterministicFailure then -- 4256
					shared.failedTestNeedsBuild = true -- 4305
					shared.failedTestHasSourceEdit = false -- 4306
				elseif deterministicPass then -- 4306
					shared.failedTestNeedsBuild = false -- 4308
					shared.failedTestHasSourceEdit = false -- 4309
				end -- 4309
			end -- 4309
			return ____awaiter_resolve(nil, result) -- 4309
		end -- 4309
		if action.tool == "spawn_sub_agent" then -- 4309
			if not shared.spawnSubAgent then -- 4309
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4309
			end -- 4309
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4309
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4309
			end -- 4309
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4321
				params.filesHint, -- 4322
				function(____, item) return type(item) == "string" end -- 4322
			) or nil -- 4322
			local result = __TS__Await(shared.spawnSubAgent({ -- 4324
				parentSessionId = shared.sessionId, -- 4325
				projectRoot = shared.workingDir, -- 4326
				title = type(params.title) == "string" and params.title or "Sub", -- 4327
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4328
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4329
				filesHint = filesHint, -- 4330
				disabledAgentTools = shared.disabledAgentTools -- 4331
			})) -- 4331
			if not result.success then -- 4331
				return ____awaiter_resolve(nil, result) -- 4331
			end -- 4331
			shared.hasSpawnedSubAgentThisTask = true -- 4336
			return ____awaiter_resolve(nil, { -- 4336
				success = true, -- 4338
				sessionId = result.sessionId, -- 4339
				taskId = result.taskId, -- 4340
				title = result.title, -- 4341
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4342
			}) -- 4342
		end -- 4342
		if action.tool == "list_sub_agents" then -- 4342
			if not shared.listSubAgents then -- 4342
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4342
			end -- 4342
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4342
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4342
			end -- 4342
			local result = __TS__Await(shared.listSubAgents({ -- 4352
				sessionId = shared.sessionId, -- 4353
				projectRoot = shared.workingDir, -- 4354
				status = type(params.status) == "string" and params.status or nil, -- 4355
				limit = type(params.limit) == "number" and params.limit or nil, -- 4356
				offset = type(params.offset) == "number" and params.offset or nil, -- 4357
				query = type(params.query) == "string" and params.query or nil -- 4358
			})) -- 4358
			return ____awaiter_resolve(nil, result) -- 4358
		end -- 4358
		if action.tool == "edit_file" then -- 4358
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4363
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4366
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4367
			if __TS__StringTrim(path) == "" then -- 4367
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4367
			end -- 4367
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4369
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4370
			if not isInternalDocumentEdit then -- 4370
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4372
				if preflightIssue ~= nil then -- 4372
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4374
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4375
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4375
				end -- 4375
			end -- 4375
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4381
			local result = __TS__Await(actionNode:exec({ -- 4382
				path = path, -- 4383
				oldStr = oldStr, -- 4384
				newStr = newStr, -- 4385
				taskId = shared.taskId, -- 4386
				workDir = shared.workingDir -- 4387
			})) -- 4387
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4387
				if params.partialStreamRecovery ~= true then -- 4387
					shared.truncatedToolOverwritePath = nil -- 4391
				end -- 4391
				shared.unbuiltEdits = true -- 4393
				shared.lastBuildSucceeded = false -- 4394
				if shared.failedTestNeedsBuild == true then -- 4394
					shared.failedTestHasSourceEdit = true -- 4395
				end -- 4395
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4396
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4396
					editedPaths[#editedPaths + 1] = normalizedPath -- 4397
				end -- 4397
				shared.editedPathsSinceBuild = editedPaths -- 4398
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4399
			end -- 4399
			return ____awaiter_resolve(nil, result) -- 4399
		end -- 4399
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4399
	end) -- 4399
end -- 4399
function sanitizeToolActionResultForHistory(action, result) -- 4406
	if action.tool == "read_file" then -- 4406
		return sanitizeReadResultForHistory(action.tool, result) -- 4408
	end -- 4408
	if action.tool == "grep_files" or action.tool == "search_dora_doc" then -- 4408
		return sanitizeSearchResultForHistory(action.tool, result) -- 4411
	end -- 4411
	if action.tool == "glob_files" then -- 4411
		return sanitizeListFilesResultForHistory(result) -- 4414
	end -- 4414
	if action.tool == "build" then -- 4414
		return sanitizeBuildResultForHistory(result) -- 4417
	end -- 4417
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4417
		if result.success ~= true then -- 4417
			return result -- 4420
		end -- 4420
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4420
			return result -- 4421
		end -- 4421
		if isArray(result.fileContext) then -- 4421
			return result -- 4422
		end -- 4422
		local contextLimits = { -- 4424
			fullContentChars = 12000, -- 4425
			previewChars = 4000, -- 4426
			diffChars = 8000, -- 4427
			totalChars = 24000, -- 4428
			maxFiles = 8 -- 4429
		} -- 4429
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4431
			if maxChars <= 0 then -- 4431
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4432
			end -- 4432
			if #sourceText <= maxChars then -- 4432
				return sourceText -- 4433
			end -- 4433
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4434
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4435
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4436
		end -- 4431
		local function countLines(sourceText) -- 4438
			if sourceText == "" then -- 4438
				return 0 -- 4439
			end -- 4439
			return #__TS__StringSplit(sourceText, "\n") -- 4440
		end -- 4438
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4442
			if beforeContent == afterContent then -- 4442
				return "" -- 4443
			end -- 4443
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4444
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4445
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4447
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4447
				firstChangedLine = firstChangedLine + 1 -- 4453
			end -- 4453
			local lastChangedBeforeLine = #beforeLines - 1 -- 4455
			local lastChangedAfterLine = #afterLines - 1 -- 4456
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4456
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4462
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4463
			end -- 4463
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4465
			local previewEndLine = math.max( -- 4466
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4467
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4468
			) -- 4468
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4470
			do -- 4470
				local lineIndex = previewStartLine -- 4471
				while lineIndex <= previewEndLine do -- 4471
					do -- 4471
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4472
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4473
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4474
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4475
						if not beforeChanged and not afterChanged then -- 4475
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4477
							if contextLine ~= nil then -- 4477
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4478
							end -- 4478
							goto __continue734 -- 4479
						end -- 4479
						if beforeChanged and beforeLine ~= nil then -- 4479
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4481
						end -- 4481
						if afterChanged and afterLine ~= nil then -- 4481
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4482
						end -- 4482
					end -- 4482
					::__continue734:: -- 4482
					lineIndex = lineIndex + 1 -- 4471
				end -- 4471
			end -- 4471
			return truncateContextSnippet( -- 4484
				table.concat(unifiedDiffLines, "\n"), -- 4484
				maxChars, -- 4484
				"diff" -- 4484
			) -- 4484
		end -- 4442
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4487
		if not checkpointDiff.success then -- 4487
			return result -- 4488
		end -- 4488
		local remainingContextBudget = contextLimits.totalChars -- 4489
		local fileContextItems = {} -- 4490
		local changedFiles = checkpointDiff.files -- 4491
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4492
		do -- 4492
			local fileIndex = 0 -- 4493
			while fileIndex < maxContextFiles do -- 4493
				if remainingContextBudget <= 0 then -- 4493
					break -- 4494
				end -- 4494
				local changedFile = changedFiles[fileIndex + 1] -- 4495
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4496
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4497
				local contextItem = { -- 4498
					path = changedFile.path, -- 4499
					op = changedFile.op, -- 4500
					checkpointId = result.checkpointId, -- 4501
					checkpointSeq = result.checkpointSeq, -- 4502
					beforeExists = changedFile.beforeExists, -- 4503
					afterExists = changedFile.afterExists, -- 4504
					beforeBytes = #beforeContent, -- 4505
					afterBytes = #afterContent, -- 4506
					diffPreview = "", -- 4507
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4508
					contentTruncated = false, -- 4509
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4510
				} -- 4510
				if changedFile.afterExists then -- 4510
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4510
						contextItem.afterContent = afterContent -- 4514
						remainingContextBudget = remainingContextBudget - #afterContent -- 4515
					else -- 4515
						contextItem.afterContentPreview = truncateContextSnippet( -- 4517
							afterContent, -- 4518
							math.min( -- 4519
								contextLimits.previewChars, -- 4519
								math.max(400, remainingContextBudget) -- 4519
							), -- 4519
							"afterContent" -- 4520
						) -- 4520
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4522
						contextItem.contentTruncated = true -- 4523
					end -- 4523
				end -- 4523
				local diffPreview = buildUnifiedDiffPreview( -- 4526
					changedFile.path, -- 4527
					beforeContent, -- 4528
					afterContent, -- 4529
					math.min( -- 4530
						contextLimits.diffChars, -- 4530
						math.max(400, remainingContextBudget) -- 4530
					) -- 4530
				) -- 4530
				contextItem.diffPreview = diffPreview -- 4532
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4533
				if not changedFile.afterExists and beforeContent ~= "" then -- 4533
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4535
						beforeContent, -- 4536
						math.min( -- 4537
							contextLimits.previewChars, -- 4537
							math.max(400, remainingContextBudget) -- 4537
						), -- 4537
						"beforeContent" -- 4538
					) -- 4538
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4540
					if #beforeContent > contextLimits.previewChars then -- 4540
						contextItem.contentTruncated = true -- 4541
					end -- 4541
				end -- 4541
				fileContextItems[#fileContextItems + 1] = contextItem -- 4543
				fileIndex = fileIndex + 1 -- 4493
			end -- 4493
		end -- 4493
		if #fileContextItems == 0 then -- 4493
			return result -- 4545
		end -- 4545
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4546
	end -- 4546
	return result -- 4553
end -- 4553
function emitAgentTaskFinishEvent(shared, success, message) -- 4754
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4755
	local result = success and ({ -- 4759
		success = true, -- 4761
		taskId = shared.taskId, -- 4762
		message = message, -- 4763
		steps = shared.step, -- 4764
		completion = completion -- 4765
	}) or ({ -- 4765
		success = false, -- 4768
		taskId = shared.taskId, -- 4769
		message = message, -- 4770
		steps = shared.step, -- 4771
		completion = completion -- 4772
	}) -- 4772
	emitAgentEvent(shared, { -- 4774
		type = "task_finished", -- 4775
		sessionId = shared.sessionId, -- 4776
		taskId = shared.taskId, -- 4777
		success = result.success, -- 4778
		message = result.message, -- 4779
		steps = result.steps, -- 4780
		completion = result.completion -- 4781
	}) -- 4781
	return result -- 4783
end -- 4783
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
		AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 1324
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
		if action.tool == "search_dora_doc" then -- 1448
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
						AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 1554
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
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2774
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2783
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2784
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2792
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2793
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2794
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2802
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2810
		shared.role, -- 2810
		{ -- 2810
			includeFinish = true, -- 2811
			includeXmlRules = true, -- 2812
			context = {searchDoraDocLimitMax = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax}, -- 2813
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2814
			workMode = shared.workMode -- 2815
		} -- 2815
	) -- 2815
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2817
	local repairPrompt = replacePromptVars( -- 2820
		shared.promptPack.xmlDecisionRepairPrompt, -- 2820
		{ -- 2820
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2821
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2822
			CANDIDATE_SECTION = candidateSection, -- 2823
			LAST_ERROR = lastError, -- 2824
			ATTEMPT = tostring(attempt) -- 2825
		} -- 2825
	) -- 2825
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2827
end -- 2774
local MainDecisionAgent = __TS__Class() -- 2865
MainDecisionAgent.name = "MainDecisionAgent" -- 2865
__TS__ClassExtends(MainDecisionAgent, Node) -- 2865
function MainDecisionAgent.prototype.prep(self, shared) -- 2866
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2866
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2866
			return ____awaiter_resolve(nil, {shared = shared}) -- 2866
		end -- 2866
		__TS__Await(maybeCompressHistory(shared)) -- 2871
		return ____awaiter_resolve(nil, {shared = shared}) -- 2871
	end) -- 2871
end -- 2866
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2876
	local preExecuted = shared.preExecutedResults -- 2877
	if not preExecuted or preExecuted.size == 0 then -- 2877
		return nil -- 2878
	end -- 2878
	local decisions = {} -- 2879
	preExecuted:forEach(function(____, preResult) -- 2880
		local action = preResult.action -- 2881
		decisions[#decisions + 1] = { -- 2882
			success = true, -- 2883
			tool = action.tool, -- 2884
			params = action.params, -- 2885
			toolCallId = action.toolCallId, -- 2886
			reason = action.reason, -- 2887
			reasoningContent = action.reasoningContent -- 2888
		} -- 2888
	end) -- 2880
	if #decisions == 0 then -- 2880
		return nil -- 2891
	end -- 2891
	AgentUtils.Log( -- 2892
		"Warn", -- 2892
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2892
			__TS__ArrayMap( -- 2892
				decisions, -- 2892
				function(____, decision) return decision.tool end -- 2892
			), -- 2892
			"," -- 2892
		) -- 2892
	) -- 2892
	if #decisions == 1 then -- 2892
		return decisions[1] -- 2894
	end -- 2894
	return {success = true, kind = "batch", decisions = decisions} -- 2896
end -- 2876
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2903
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2908
	if not recovery then -- 2908
		return nil -- 2909
	end -- 2909
	shared.truncatedToolOverwritePath = recovery.target -- 2910
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2911
	return { -- 2912
		success = true, -- 2913
		tool = "edit_file", -- 2914
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2915
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2921
		reason = recovery.reason, -- 2922
		reasoningContent = reasoningContent -- 2923
	} -- 2923
end -- 2903
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2927
	if attempt == nil then -- 2927
		attempt = 1 -- 2930
	end -- 2930
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2930
		if shared.stopToken.stopped then -- 2930
			return ____awaiter_resolve( -- 2930
				nil, -- 2930
				{ -- 2934
					success = false, -- 2934
					message = getCancelledReason(shared) -- 2934
				} -- 2934
			) -- 2934
		end -- 2934
		AgentUtils.Log( -- 2936
			"Info", -- 2936
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2936
		) -- 2936
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2937
			shared.role, -- 2937
			AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 2937
			{ -- 2937
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2938
				workMode = shared.workMode -- 2939
			} -- 2939
		) -- 2939
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2941
		local stepId = shared.step + 1 -- 2942
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2943
			string.lower(shared.llmConfig.model), -- 2943
			"glm-5.2" -- 2943
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2943
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2946
		emitLLMContextMetrics( -- 2951
			shared, -- 2951
			stepId, -- 2951
			"decision_tool_calling", -- 2951
			messages, -- 2951
			llmOptions -- 2951
		) -- 2951
		saveStepLLMDebugInput( -- 2952
			shared, -- 2952
			stepId, -- 2952
			"decision_tool_calling", -- 2952
			messages, -- 2952
			llmOptions -- 2952
		) -- 2952
		local lastStreamContent = "" -- 2953
		local lastStreamReasoning = "" -- 2954
		local preExecutedResults = __TS__New(Map) -- 2955
		shared.preExecutedResults = preExecutedResults -- 2956
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2957
			messages, -- 2958
			llmOptions, -- 2959
			shared.stopToken, -- 2960
			shared.llmConfig, -- 2961
			function(response) -- 2962
				local ____opt_75 = response.choices -- 2962
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2962
				local streamMessage = ____opt_73 and ____opt_73.message -- 2963
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2964
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2967
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2967
					return -- 2971
				end -- 2971
				lastStreamContent = nextContent -- 2973
				lastStreamReasoning = nextReasoning -- 2974
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2975
			end, -- 2962
			function(tc) -- 2977
				if shared.stopToken.stopped then -- 2977
					return -- 2978
				end -- 2978
				local action = createPreExecutableActionFromStream(shared, tc) -- 2979
				if not action or preExecutedResults:has(action.toolCallId) then -- 2979
					return -- 2980
				end -- 2980
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2981
				preExecutedResults:set( -- 2982
					action.toolCallId, -- 2982
					createPreExecutedToolResult(shared, action) -- 2982
				) -- 2982
			end -- 2977
		)) -- 2977
		if shared.stopToken.stopped then -- 2977
			clearPreExecutedResults(shared) -- 2986
			return ____awaiter_resolve( -- 2986
				nil, -- 2986
				{ -- 2987
					success = false, -- 2987
					message = getCancelledReason(shared) -- 2987
				} -- 2987
			) -- 2987
		end -- 2987
		if not res.success then -- 2987
			local usage = res.tokenUsage -- 2990
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2991
			saveStepLLMDebugOutput( -- 2992
				shared, -- 2992
				stepId, -- 2992
				"decision_tool_calling", -- 2992
				res.raw or res.message, -- 2992
				{success = false, usage = usage} -- 2992
			) -- 2992
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2993
			local committed = self:commitPreExecutedDecision(shared) -- 2994
			if committed then -- 2994
				return ____awaiter_resolve(nil, committed) -- 2994
			end -- 2994
			local ____opt_83 = res.response -- 2994
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2994
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2996
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 2997
			local ____shared_93 = shared -- 2998
			local ____opt_85 = partialChoice and partialChoice.message -- 2998
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 2999
			local ____opt_89 = partialChoice and partialChoice.message -- 2999
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 2997
			if partialDraft then -- 2997
				return ____awaiter_resolve(nil, partialDraft) -- 2997
			end -- 2997
			clearPreExecutedResults(shared) -- 3003
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 3003
		end -- 3003
		local usage = res.tokenUsage -- 3006
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3007
		saveStepLLMDebugOutput( -- 3008
			shared, -- 3008
			stepId, -- 3008
			"decision_tool_calling", -- 3008
			encodeDebugJSON(res.response), -- 3008
			{success = true, usage = usage} -- 3008
		) -- 3008
		local choice = res.response.choices and res.response.choices[1] -- 3009
		local message = choice and choice.message -- 3010
		local toolCalls = message and message.tool_calls -- 3011
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3012
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3015
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3018
		AgentUtils.Log( -- 3021
			"Info", -- 3021
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3021
		) -- 3021
		if finishReason == "length" then -- 3021
			local committed = self:commitPreExecutedDecision(shared) -- 3023
			if committed then -- 3023
				return ____awaiter_resolve(nil, committed) -- 3023
			end -- 3023
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3025
			if partialDraft then -- 3025
				return ____awaiter_resolve(nil, partialDraft) -- 3025
			end -- 3025
			AgentUtils.Log( -- 3027
				"Error", -- 3027
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3027
			) -- 3027
			clearPreExecutedResults(shared) -- 3028
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3028
		end -- 3028
		if not toolCalls or #toolCalls == 0 then -- 3028
			if messageContent and messageContent ~= "" then -- 3028
				if isFinalDecisionTurn(shared) then -- 3028
					clearPreExecutedResults(shared) -- 3038
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3038
				end -- 3038
				if shared.role == "sub" then -- 3038
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3046
					clearPreExecutedResults(shared) -- 3047
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3047
				end -- 3047
				AgentUtils.Log( -- 3054
					"Info", -- 3054
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3054
				) -- 3054
				clearPreExecutedResults(shared) -- 3055
				return ____awaiter_resolve(nil, { -- 3055
					success = true, -- 3057
					tool = "finish", -- 3058
					params = {}, -- 3059
					reason = messageContent, -- 3060
					reasoningContent = reasoningContent, -- 3061
					directSummary = messageContent -- 3062
				}) -- 3062
			end -- 3062
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3065
			clearPreExecutedResults(shared) -- 3066
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3066
		end -- 3066
		local decisions = {} -- 3073
		do -- 3073
			local i = 0 -- 3074
			while i < #toolCalls do -- 3074
				local toolCall = toolCalls[i + 1] -- 3075
				local fn = toolCall ~= nil and toolCall["function"] -- 3076
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3076
					AgentUtils.Log( -- 3078
						"Error", -- 3078
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3078
					) -- 3078
					clearPreExecutedResults(shared) -- 3079
					return ____awaiter_resolve( -- 3079
						nil, -- 3079
						{ -- 3080
							success = false, -- 3081
							message = "missing function name for tool call " .. tostring(i + 1), -- 3082
							raw = messageContent -- 3083
						} -- 3083
					) -- 3083
				end -- 3083
				local functionName = fn.name -- 3086
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3087
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3088
				AgentUtils.Log( -- 3091
					"Info", -- 3091
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3091
				) -- 3091
				local decision = parseAndValidateToolCallDecision( -- 3092
					shared, -- 3093
					functionName, -- 3094
					argsText, -- 3095
					toolCallId, -- 3096
					messageContent, -- 3097
					reasoningContent -- 3098
				) -- 3098
				if not decision.success then -- 3098
					AgentUtils.Log( -- 3101
						"Error", -- 3101
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3101
					) -- 3101
					clearPreExecutedResults(shared) -- 3102
					return ____awaiter_resolve(nil, decision) -- 3102
				end -- 3102
				decisions[#decisions + 1] = decision -- 3105
				i = i + 1 -- 3074
			end -- 3074
		end -- 3074
		if #decisions == 1 then -- 3074
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3108
			return ____awaiter_resolve(nil, decisions[1]) -- 3108
		end -- 3108
		do -- 3108
			local i = 0 -- 3111
			while i < #decisions do -- 3111
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3111
					clearPreExecutedResults(shared) -- 3113
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3113
				end -- 3113
				i = i + 1 -- 3111
			end -- 3111
		end -- 3111
		AgentUtils.Log( -- 3121
			"Info", -- 3121
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3121
				__TS__ArrayMap( -- 3121
					decisions, -- 3121
					function(____, decision) return decision.tool end -- 3121
				), -- 3121
				"," -- 3121
			) -- 3121
		) -- 3121
		return ____awaiter_resolve(nil, { -- 3121
			success = true, -- 3123
			kind = "batch", -- 3124
			decisions = decisions, -- 3125
			content = messageContent, -- 3126
			reasoningContent = reasoningContent -- 3127
		}) -- 3127
	end) -- 3127
end -- 2927
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3131
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3131
		AgentUtils.Log( -- 3137
			"Info", -- 3137
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3137
		) -- 3137
		local lastError = initialError -- 3138
		local candidateRaw = "" -- 3139
		local candidateReasoning = nil -- 3140
		do -- 3140
			local attempt = 0 -- 3141
			while attempt < shared.llmMaxTry do -- 3141
				do -- 3141
					AgentUtils.Log( -- 3142
						"Info", -- 3142
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3142
					) -- 3142
					local messages = buildXmlRepairMessages( -- 3143
						shared, -- 3144
						originalRaw, -- 3145
						originalReasoning, -- 3146
						candidateRaw, -- 3147
						candidateReasoning, -- 3148
						lastError, -- 3149
						attempt + 1 -- 3150
					) -- 3150
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3152
					if shared.stopToken.stopped then -- 3152
						return ____awaiter_resolve( -- 3152
							nil, -- 3152
							{ -- 3154
								success = false, -- 3154
								message = getCancelledReason(shared) -- 3154
							} -- 3154
						) -- 3154
					end -- 3154
					if not llmRes.success then -- 3154
						lastError = llmRes.message -- 3157
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3158
						goto __continue531 -- 3159
					end -- 3159
					candidateRaw = llmRes.text -- 3161
					candidateReasoning = llmRes.reasoningContent -- 3162
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3163
					if decision.success then -- 3163
						decision.reasoningContent = llmRes.reasoningContent -- 3165
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3166
						return ____awaiter_resolve(nil, decision) -- 3166
					end -- 3166
					lastError = decision.message -- 3169
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3170
				end -- 3170
				::__continue531:: -- 3170
				attempt = attempt + 1 -- 3141
			end -- 3141
		end -- 3141
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3172
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3172
	end) -- 3172
end -- 3131
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3180
	if attempt == nil then -- 3180
		attempt = 1 -- 3183
	end -- 3183
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3183
		local messages = buildDecisionMessages( -- 3186
			shared, -- 3187
			lastError, -- 3188
			attempt, -- 3189
			lastRaw, -- 3190
			"xml" -- 3191
		) -- 3191
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3193
		if shared.stopToken.stopped then -- 3193
			return ____awaiter_resolve( -- 3193
				nil, -- 3193
				{ -- 3195
					success = false, -- 3195
					message = getCancelledReason(shared) -- 3195
				} -- 3195
			) -- 3195
		end -- 3195
		if not llmRes.success then -- 3195
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3195
		end -- 3195
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3204
		if decision.success then -- 3204
			decision.reasoningContent = llmRes.reasoningContent -- 3206
			return ____awaiter_resolve(nil, decision) -- 3206
		end -- 3206
		return ____awaiter_resolve( -- 3206
			nil, -- 3206
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3209
		) -- 3209
	end) -- 3209
end -- 3180
function MainDecisionAgent.prototype.exec(self, input) -- 3212
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3212
		local shared = input.shared -- 3213
		if shared.stopToken.stopped then -- 3213
			return ____awaiter_resolve( -- 3213
				nil, -- 3213
				{ -- 3215
					success = false, -- 3215
					message = getCancelledReason(shared) -- 3215
				} -- 3215
			) -- 3215
		end -- 3215
		if shared.agentStepCount >= shared.maxSteps then -- 3215
			AgentUtils.Log( -- 3218
				"Warn", -- 3218
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3218
			) -- 3218
			return ____awaiter_resolve( -- 3218
				nil, -- 3218
				{ -- 3219
					success = false, -- 3219
					message = getMaxStepsReachedReason(shared) -- 3219
				} -- 3219
			) -- 3219
		end -- 3219
		if shared.decisionMode == "tool_calling" then -- 3219
			AgentUtils.Log( -- 3223
				"Info", -- 3223
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3223
			) -- 3223
			local lastError = "tool calling validation failed" -- 3224
			local lastRaw = "" -- 3225
			local shouldFallbackToXml = false -- 3226
			do -- 3226
				local attempt = 0 -- 3227
				while attempt < shared.llmMaxTry do -- 3227
					AgentUtils.Log( -- 3228
						"Info", -- 3228
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3228
					) -- 3228
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3229
					if shared.stopToken.stopped then -- 3229
						return ____awaiter_resolve( -- 3229
							nil, -- 3229
							{ -- 3236
								success = false, -- 3236
								message = getCancelledReason(shared) -- 3236
							} -- 3236
						) -- 3236
					end -- 3236
					if decision.success then -- 3236
						return ____awaiter_resolve(nil, decision) -- 3236
					end -- 3236
					lastError = decision.message -- 3241
					lastRaw = decision.raw or "" -- 3242
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3243
					if lastError == "missing tool call" then -- 3243
						shouldFallbackToXml = true -- 3245
						break -- 3246
					end -- 3246
					attempt = attempt + 1 -- 3227
				end -- 3227
			end -- 3227
			if shouldFallbackToXml then -- 3227
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3250
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3251
				do -- 3251
					local attempt = 0 -- 3252
					while attempt < shared.llmMaxTry do -- 3252
						AgentUtils.Log( -- 3253
							"Info", -- 3253
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3253
						) -- 3253
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3254
						if shared.stopToken.stopped then -- 3254
							return ____awaiter_resolve( -- 3254
								nil, -- 3254
								{ -- 3261
									success = false, -- 3261
									message = getCancelledReason(shared) -- 3261
								} -- 3261
							) -- 3261
						end -- 3261
						if decision.success then -- 3261
							return ____awaiter_resolve(nil, decision) -- 3261
						end -- 3261
						lastError = decision.message -- 3266
						lastRaw = decision.raw or "" -- 3267
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3268
						attempt = attempt + 1 -- 3252
					end -- 3252
				end -- 3252
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3270
				return ____awaiter_resolve( -- 3270
					nil, -- 3270
					{ -- 3271
						success = false, -- 3271
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3271
					} -- 3271
				) -- 3271
			end -- 3271
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3273
			return ____awaiter_resolve( -- 3273
				nil, -- 3273
				{ -- 3274
					success = false, -- 3274
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3274
				} -- 3274
			) -- 3274
		end -- 3274
		local lastError = "xml validation failed" -- 3277
		local lastRaw = "" -- 3278
		do -- 3278
			local attempt = 0 -- 3279
			while attempt < shared.llmMaxTry do -- 3279
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3280
				if shared.stopToken.stopped then -- 3280
					return ____awaiter_resolve( -- 3280
						nil, -- 3280
						{ -- 3289
							success = false, -- 3289
							message = getCancelledReason(shared) -- 3289
						} -- 3289
					) -- 3289
				end -- 3289
				if decision.success then -- 3289
					return ____awaiter_resolve(nil, decision) -- 3289
				end -- 3289
				lastError = decision.message -- 3294
				lastRaw = decision.raw or "" -- 3295
				attempt = attempt + 1 -- 3279
			end -- 3279
		end -- 3279
		return ____awaiter_resolve( -- 3279
			nil, -- 3279
			{ -- 3297
				success = false, -- 3297
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3297
			} -- 3297
		) -- 3297
	end) -- 3297
end -- 3212
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3300
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3300
		local result = execRes -- 3301
		if not result.success then -- 3301
			if shared.stopToken.stopped then -- 3301
				shared.error = getCancelledReason(shared) -- 3304
				shared.done = true -- 3305
				return ____awaiter_resolve(nil, "done") -- 3305
			end -- 3305
			shared.error = result.message -- 3308
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3309
			shared.done = true -- 3310
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3311
			persistHistoryState(shared) -- 3315
			return ____awaiter_resolve(nil, "done") -- 3315
		end -- 3315
		if isDecisionBatchSuccess(result) then -- 3315
			local startStep = shared.step -- 3319
			local actions = {} -- 3320
			do -- 3320
				local i = 0 -- 3321
				while i < #result.decisions do -- 3321
					local decision = result.decisions[i + 1] -- 3322
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3323
					local step = startStep + i + 1 -- 3324
					local ____temp_96 -- 3325
					if i == 0 then -- 3325
						____temp_96 = decision.reason -- 3325
					else -- 3325
						____temp_96 = "" -- 3325
					end -- 3325
					local actionReason = ____temp_96 -- 3325
					local ____temp_97 -- 3326
					if i == 0 then -- 3326
						____temp_97 = decision.reasoningContent -- 3326
					else -- 3326
						____temp_97 = nil -- 3326
					end -- 3326
					local actionReasoningContent = ____temp_97 -- 3326
					emitAgentEvent(shared, { -- 3327
						type = "decision_made", -- 3328
						sessionId = shared.sessionId, -- 3329
						taskId = shared.taskId, -- 3330
						step = step, -- 3331
						tool = decision.tool, -- 3332
						reason = actionReason, -- 3333
						reasoningContent = actionReasoningContent, -- 3334
						params = decision.params -- 3335
					}) -- 3335
					local action = { -- 3337
						step = step, -- 3338
						toolCallId = toolCallId, -- 3339
						tool = decision.tool, -- 3340
						reason = actionReason or "", -- 3341
						reasoningContent = actionReasoningContent, -- 3342
						params = decision.params, -- 3343
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3344
					} -- 3344
					local ____shared_history_98 = shared.history -- 3344
					____shared_history_98[#____shared_history_98 + 1] = action -- 3346
					actions[#actions + 1] = action -- 3347
					i = i + 1 -- 3321
				end -- 3321
			end -- 3321
			shared.step = startStep + #actions -- 3349
			shared.agentStepCount = shared.agentStepCount + #actions -- 3350
			shared.pendingToolActions = actions -- 3351
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3352
			persistHistoryState(shared) -- 3358
			return ____awaiter_resolve(nil, "batch_tools") -- 3358
		end -- 3358
		if result.directSummary and result.directSummary ~= "" then -- 3358
			shared.response = result.directSummary -- 3362
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3363
			shared.done = true -- 3367
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3368
			persistHistoryState(shared) -- 3373
			return ____awaiter_resolve(nil, "done") -- 3373
		end -- 3373
		if result.tool == "finish" then -- 3373
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3377
			shared.response = finalMessage -- 3378
			shared.completion = getCompletionReport(result.params) -- 3379
			shared.done = true -- 3380
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3381
			persistHistoryState(shared) -- 3386
			return ____awaiter_resolve(nil, "done") -- 3386
		end -- 3386
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3389
		shared.step = shared.step + 1 -- 3390
		shared.agentStepCount = shared.agentStepCount + 1 -- 3391
		local step = shared.step -- 3392
		emitAgentEvent(shared, { -- 3393
			type = "decision_made", -- 3394
			sessionId = shared.sessionId, -- 3395
			taskId = shared.taskId, -- 3396
			step = step, -- 3397
			tool = result.tool, -- 3398
			reason = result.reason, -- 3399
			reasoningContent = result.reasoningContent, -- 3400
			params = result.params -- 3401
		}) -- 3401
		local ____shared_history_99 = shared.history -- 3401
		____shared_history_99[#____shared_history_99 + 1] = { -- 3403
			step = step, -- 3404
			toolCallId = toolCallId, -- 3405
			tool = result.tool, -- 3406
			reason = result.reason or "", -- 3407
			reasoningContent = result.reasoningContent, -- 3408
			params = result.params, -- 3409
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3410
		} -- 3410
		local action = shared.history[#shared.history] -- 3412
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3413
		shared.pendingToolActions = {action} -- 3416
		persistHistoryState(shared) -- 3417
		return ____awaiter_resolve(nil, "batch_tools") -- 3417
	end) -- 3417
end -- 3300
local ReadFileAction = __TS__Class() -- 3422
ReadFileAction.name = "ReadFileAction" -- 3422
__TS__ClassExtends(ReadFileAction, Node) -- 3422
function ReadFileAction.prototype.prep(self, shared) -- 3423
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3423
		local last = shared.history[#shared.history] -- 3424
		if not last then -- 3424
			error( -- 3425
				__TS__New(Error, "no history"), -- 3425
				0 -- 3425
			) -- 3425
		end -- 3425
		emitAgentStartEvent(shared, last) -- 3426
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3427
		if __TS__StringTrim(path) == "" then -- 3427
			error( -- 3430
				__TS__New(Error, "missing path"), -- 3430
				0 -- 3430
			) -- 3430
		end -- 3430
		local ____path_102 = path -- 3432
		local ____shared_workingDir_103 = shared.workingDir -- 3434
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3435
		local ____last_params_startLine_100 = last.params.startLine -- 3436
		if ____last_params_startLine_100 == nil then -- 3436
			____last_params_startLine_100 = 1 -- 3436
		end -- 3436
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3436
		local ____last_params_endLine_101 = last.params.endLine -- 3437
		if ____last_params_endLine_101 == nil then -- 3437
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3437
		end -- 3437
		return ____awaiter_resolve( -- 3437
			nil, -- 3437
			{ -- 3431
				path = ____path_102, -- 3432
				tool = "read_file", -- 3433
				workDir = ____shared_workingDir_103, -- 3434
				docLanguage = ____temp_104, -- 3435
				startLine = ____TS__Number_result_105, -- 3436
				endLine = __TS__Number(____last_params_endLine_101) -- 3437
			} -- 3437
		) -- 3437
	end) -- 3437
end -- 3423
function ReadFileAction.prototype.exec(self, input) -- 3441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3441
		return ____awaiter_resolve( -- 3441
			nil, -- 3441
			Tools.readFile( -- 3442
				input.workDir, -- 3443
				input.path, -- 3444
				__TS__Number(input.startLine or 1), -- 3445
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3446
				input.docLanguage -- 3447
			) -- 3447
		) -- 3447
	end) -- 3447
end -- 3441
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3451
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3451
		local result = execRes -- 3452
		local last = shared.history[#shared.history] -- 3453
		if last ~= nil then -- 3453
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3455
			appendToolResultMessage(shared, last) -- 3456
			emitAgentFinishEvent(shared, last) -- 3457
		end -- 3457
		persistHistoryState(shared) -- 3459
		__TS__Await(maybeCompressHistory(shared)) -- 3460
		persistHistoryState(shared) -- 3461
		return ____awaiter_resolve(nil, "main") -- 3461
	end) -- 3461
end -- 3451
local SearchFilesAction = __TS__Class() -- 3466
SearchFilesAction.name = "SearchFilesAction" -- 3466
__TS__ClassExtends(SearchFilesAction, Node) -- 3466
function SearchFilesAction.prototype.prep(self, shared) -- 3467
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3467
		local last = shared.history[#shared.history] -- 3468
		if not last then -- 3468
			error( -- 3469
				__TS__New(Error, "no history"), -- 3469
				0 -- 3469
			) -- 3469
		end -- 3469
		emitAgentStartEvent(shared, last) -- 3470
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3470
	end) -- 3470
end -- 3467
function SearchFilesAction.prototype.exec(self, input) -- 3474
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3474
		local params = input.params -- 3475
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3476
		local ____input_workDir_112 = input.workDir -- 3477
		local ____temp_113 = params.path or "" -- 3478
		local ____temp_114 = params.pattern or "" -- 3479
		local ____params_globs_115 = params.globs -- 3480
		local ____params_useRegex_116 = params.useRegex -- 3481
		local ____params_caseSensitive_117 = params.caseSensitive -- 3482
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3484
		local ____math_max_108 = math.max -- 3485
		local ____math_floor_107 = math.floor -- 3485
		local ____params_limit_106 = params.limit -- 3485
		if ____params_limit_106 == nil then -- 3485
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3485
		end -- 3485
		local ____math_max_108_result_119 = ____math_max_108( -- 3485
			1, -- 3485
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3485
		) -- 3485
		local ____math_max_111 = math.max -- 3486
		local ____math_floor_110 = math.floor -- 3486
		local ____params_offset_109 = params.offset -- 3486
		if ____params_offset_109 == nil then -- 3486
			____params_offset_109 = 0 -- 3486
		end -- 3486
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3476
			workDir = ____input_workDir_112, -- 3477
			path = ____temp_113, -- 3478
			pattern = ____temp_114, -- 3479
			globs = ____params_globs_115, -- 3480
			useRegex = ____params_useRegex_116, -- 3481
			caseSensitive = ____params_caseSensitive_117, -- 3482
			includeContent = true, -- 3483
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3484
			limit = ____math_max_108_result_119, -- 3485
			offset = ____math_max_111( -- 3486
				0, -- 3486
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3486
			), -- 3486
			groupByFile = params.groupByFile == true -- 3487
		})) -- 3487
		return ____awaiter_resolve(nil, result) -- 3487
	end) -- 3487
end -- 3474
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3492
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3492
		local last = shared.history[#shared.history] -- 3493
		if last ~= nil then -- 3493
			local result = execRes -- 3495
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3496
			appendToolResultMessage(shared, last) -- 3497
			emitAgentFinishEvent(shared, last) -- 3498
		end -- 3498
		persistHistoryState(shared) -- 3500
		__TS__Await(maybeCompressHistory(shared)) -- 3501
		persistHistoryState(shared) -- 3502
		return ____awaiter_resolve(nil, "main") -- 3502
	end) -- 3502
end -- 3492
local SearchDoraDocAction = __TS__Class() -- 3507
SearchDoraDocAction.name = "SearchDoraDocAction" -- 3507
__TS__ClassExtends(SearchDoraDocAction, Node) -- 3507
function SearchDoraDocAction.prototype.prep(self, shared) -- 3508
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3508
		local last = shared.history[#shared.history] -- 3509
		if not last then -- 3509
			error( -- 3510
				__TS__New(Error, "no history"), -- 3510
				0 -- 3510
			) -- 3510
		end -- 3510
		emitAgentStartEvent(shared, last) -- 3511
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3511
	end) -- 3511
end -- 3508
function SearchDoraDocAction.prototype.exec(self, input) -- 3515
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3515
		local params = input.params -- 3516
		local ____Tools_searchDoraDoc_129 = Tools.searchDoraDoc -- 3517
		local ____temp_125 = params.pattern or "" -- 3518
		local ____temp_126 = params.docType or "dora-api" -- 3519
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3520
		local ____temp_128 = params.programmingLanguage or "ts" -- 3521
		local ____math_min_124 = math.min -- 3522
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 3522
		local ____math_max_122 = math.max -- 3522
		local ____params_limit_121 = params.limit -- 3522
		if ____params_limit_121 == nil then -- 3522
			____params_limit_121 = 8 -- 3522
		end -- 3522
		local result = __TS__Await(____Tools_searchDoraDoc_129({ -- 3517
			pattern = ____temp_125, -- 3518
			docType = ____temp_126, -- 3519
			docLanguage = ____temp_127, -- 3520
			programmingLanguage = ____temp_128, -- 3521
			limit = ____math_min_124( -- 3522
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_123, -- 3522
				____math_max_122( -- 3522
					1, -- 3522
					__TS__Number(____params_limit_121) -- 3522
				) -- 3522
			), -- 3522
			useRegex = params.useRegex, -- 3523
			caseSensitive = false, -- 3524
			includeContent = true, -- 3525
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3526
		})) -- 3526
		return ____awaiter_resolve(nil, result) -- 3526
	end) -- 3526
end -- 3515
function SearchDoraDocAction.prototype.post(self, shared, _prepRes, execRes) -- 3531
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3531
		local last = shared.history[#shared.history] -- 3532
		if last ~= nil then -- 3532
			local result = execRes -- 3534
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3535
			appendToolResultMessage(shared, last) -- 3536
			emitAgentFinishEvent(shared, last) -- 3537
		end -- 3537
		persistHistoryState(shared) -- 3539
		__TS__Await(maybeCompressHistory(shared)) -- 3540
		persistHistoryState(shared) -- 3541
		return ____awaiter_resolve(nil, "main") -- 3541
	end) -- 3541
end -- 3531
local ListFilesAction = __TS__Class() -- 3546
ListFilesAction.name = "ListFilesAction" -- 3546
__TS__ClassExtends(ListFilesAction, Node) -- 3546
function ListFilesAction.prototype.prep(self, shared) -- 3547
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3547
		local last = shared.history[#shared.history] -- 3548
		if not last then -- 3548
			error( -- 3549
				__TS__New(Error, "no history"), -- 3549
				0 -- 3549
			) -- 3549
		end -- 3549
		emitAgentStartEvent(shared, last) -- 3550
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3550
	end) -- 3550
end -- 3547
function ListFilesAction.prototype.exec(self, input) -- 3554
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3554
		local params = input.params -- 3555
		local ____Tools_listFiles_136 = Tools.listFiles -- 3556
		local ____input_workDir_133 = input.workDir -- 3557
		local ____temp_134 = params.path or "" -- 3558
		local ____params_globs_135 = params.globs -- 3559
		local ____math_max_132 = math.max -- 3560
		local ____math_floor_131 = math.floor -- 3560
		local ____params_maxEntries_130 = params.maxEntries -- 3560
		if ____params_maxEntries_130 == nil then -- 3560
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3560
		end -- 3560
		local result = ____Tools_listFiles_136({ -- 3556
			workDir = ____input_workDir_133, -- 3557
			path = ____temp_134, -- 3558
			globs = ____params_globs_135, -- 3559
			maxEntries = ____math_max_132( -- 3560
				1, -- 3560
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3560
			) -- 3560
		}) -- 3560
		return ____awaiter_resolve(nil, result) -- 3560
	end) -- 3560
end -- 3554
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3565
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3565
		local last = shared.history[#shared.history] -- 3566
		if last ~= nil then -- 3566
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3568
			appendToolResultMessage(shared, last) -- 3569
			emitAgentFinishEvent(shared, last) -- 3570
		end -- 3570
		persistHistoryState(shared) -- 3572
		__TS__Await(maybeCompressHistory(shared)) -- 3573
		persistHistoryState(shared) -- 3574
		return ____awaiter_resolve(nil, "main") -- 3574
	end) -- 3574
end -- 3565
local DeleteFileAction = __TS__Class() -- 3579
DeleteFileAction.name = "DeleteFileAction" -- 3579
__TS__ClassExtends(DeleteFileAction, Node) -- 3579
function DeleteFileAction.prototype.prep(self, shared) -- 3580
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3580
		local last = shared.history[#shared.history] -- 3581
		if not last then -- 3581
			error( -- 3582
				__TS__New(Error, "no history"), -- 3582
				0 -- 3582
			) -- 3582
		end -- 3582
		emitAgentStartEvent(shared, last) -- 3583
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3584
		if __TS__StringTrim(targetFile) == "" then -- 3584
			error( -- 3587
				__TS__New(Error, "missing target_file"), -- 3587
				0 -- 3587
			) -- 3587
		end -- 3587
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3587
	end) -- 3587
end -- 3580
function DeleteFileAction.prototype.exec(self, input) -- 3591
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3591
		local result = Tools.deleteFile(input.taskId, input.workDir, input.targetFile, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3592
		if not result.success then -- 3592
			return ____awaiter_resolve(nil, result) -- 3592
		end -- 3592
		local ____result_checkpointed_138 = result.checkpointed -- 3603
		local ____result_reversible_139 = result.reversible -- 3604
		local ____result_binary_140 = result.binary -- 3605
		local ____temp_141 = result.checkpointed and result.checkpointId or nil -- 3606
		local ____temp_142 = result.checkpointed and result.checkpointSeq or nil -- 3607
		local ____result_checkpointed_137 -- 3608
		if result.checkpointed then -- 3608
			____result_checkpointed_137 = nil -- 3608
		else -- 3608
			____result_checkpointed_137 = result.message -- 3608
		end -- 3608
		return ____awaiter_resolve(nil, { -- 3608
			success = true, -- 3600
			changed = true, -- 3601
			mode = "delete", -- 3602
			checkpointed = ____result_checkpointed_138, -- 3603
			reversible = ____result_reversible_139, -- 3604
			binary = ____result_binary_140, -- 3605
			checkpointId = ____temp_141, -- 3606
			checkpointSeq = ____temp_142, -- 3607
			message = ____result_checkpointed_137, -- 3608
			files = {{path = input.targetFile, op = "delete"}} -- 3609
		}) -- 3609
	end) -- 3609
end -- 3591
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3613
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3613
		local last = shared.history[#shared.history] -- 3614
		if last ~= nil then -- 3614
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3616
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3617
			appendToolResultMessage(shared, last) -- 3618
			emitAgentFinishEvent(shared, last) -- 3619
			local result = last.result -- 3620
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3620
				emitAgentEvent(shared, { -- 3625
					type = "checkpoint_created", -- 3626
					sessionId = shared.sessionId, -- 3627
					taskId = shared.taskId, -- 3628
					step = last.step, -- 3629
					tool = "delete_file", -- 3630
					checkpointId = result.checkpointId, -- 3631
					checkpointSeq = result.checkpointSeq, -- 3632
					files = result.files -- 3633
				}) -- 3633
			end -- 3633
		end -- 3633
		persistHistoryState(shared) -- 3640
		__TS__Await(maybeCompressHistory(shared)) -- 3641
		persistHistoryState(shared) -- 3642
		return ____awaiter_resolve(nil, "main") -- 3642
	end) -- 3642
end -- 3613
local BuildAction = __TS__Class() -- 3647
BuildAction.name = "BuildAction" -- 3647
__TS__ClassExtends(BuildAction, Node) -- 3647
function BuildAction.prototype.prep(self, shared) -- 3648
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3648
		local last = shared.history[#shared.history] -- 3649
		if not last then -- 3649
			error( -- 3650
				__TS__New(Error, "no history"), -- 3650
				0 -- 3650
			) -- 3650
		end -- 3650
		emitAgentStartEvent(shared, last) -- 3651
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3651
	end) -- 3651
end -- 3648
function BuildAction.prototype.exec(self, input) -- 3655
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3655
		local params = input.params -- 3656
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3657
		return ____awaiter_resolve(nil, result) -- 3657
	end) -- 3657
end -- 3655
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3664
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3664
		local last = shared.history[#shared.history] -- 3665
		if last ~= nil then -- 3665
			last.result = sanitizeBuildResultForHistory(execRes) -- 3667
			appendToolResultMessage(shared, last) -- 3668
			emitAgentFinishEvent(shared, last) -- 3669
		end -- 3669
		persistHistoryState(shared) -- 3671
		__TS__Await(maybeCompressHistory(shared)) -- 3672
		persistHistoryState(shared) -- 3673
		return ____awaiter_resolve(nil, "main") -- 3673
	end) -- 3673
end -- 3664
local SpawnSubAgentAction = __TS__Class() -- 3678
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3678
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3678
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3679
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3679
		local last = shared.history[#shared.history] -- 3689
		if not last then -- 3689
			error( -- 3690
				__TS__New(Error, "no history"), -- 3690
				0 -- 3690
			) -- 3690
		end -- 3690
		emitAgentStartEvent(shared, last) -- 3691
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3692
			last.params.filesHint, -- 3693
			function(____, item) return type(item) == "string" end -- 3693
		) or nil -- 3693
		return ____awaiter_resolve( -- 3693
			nil, -- 3693
			{ -- 3695
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3696
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3697
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3698
				filesHint = filesHint, -- 3699
				sessionId = shared.sessionId, -- 3700
				projectRoot = shared.workingDir, -- 3701
				spawnSubAgent = shared.spawnSubAgent, -- 3702
				disabledAgentTools = shared.disabledAgentTools -- 3703
			} -- 3703
		) -- 3703
	end) -- 3703
end -- 3679
function SpawnSubAgentAction.prototype.exec(self, input) -- 3707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3707
		if not input.spawnSubAgent then -- 3707
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3707
		end -- 3707
		if input.sessionId == nil or input.sessionId <= 0 then -- 3707
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3707
		end -- 3707
		local ____AgentUtils_Log_148 = AgentUtils.Log -- 3723
		local ____temp_145 = #input.title -- 3723
		local ____temp_146 = #input.prompt -- 3723
		local ____temp_147 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3723
		local ____opt_143 = input.filesHint -- 3723
		____AgentUtils_Log_148( -- 3723
			"Info", -- 3723
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_145)) .. " prompt_len=") .. tostring(____temp_146)) .. " expected_len=") .. tostring(____temp_147)) .. " files_hint_count=") .. tostring(____opt_143 and #____opt_143 or 0) -- 3723
		) -- 3723
		local result = __TS__Await(input.spawnSubAgent({ -- 3724
			parentSessionId = input.sessionId, -- 3725
			projectRoot = input.projectRoot, -- 3726
			title = input.title, -- 3727
			prompt = input.prompt, -- 3728
			expectedOutput = input.expectedOutput, -- 3729
			filesHint = input.filesHint, -- 3730
			disabledAgentTools = input.disabledAgentTools -- 3731
		})) -- 3731
		if not result.success then -- 3731
			return ____awaiter_resolve(nil, result) -- 3731
		end -- 3731
		return ____awaiter_resolve(nil, { -- 3731
			success = true, -- 3737
			sessionId = result.sessionId, -- 3738
			taskId = result.taskId, -- 3739
			title = result.title, -- 3740
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3741
		}) -- 3741
	end) -- 3741
end -- 3707
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3745
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3745
		local last = shared.history[#shared.history] -- 3746
		if last ~= nil then -- 3746
			last.result = execRes -- 3748
			if execRes.success == true then -- 3748
				shared.hasSpawnedSubAgentThisTask = true -- 3750
			end -- 3750
			appendToolResultMessage(shared, last) -- 3752
			emitAgentFinishEvent(shared, last) -- 3753
		end -- 3753
		persistHistoryState(shared) -- 3755
		__TS__Await(maybeCompressHistory(shared)) -- 3756
		persistHistoryState(shared) -- 3757
		return ____awaiter_resolve(nil, "main") -- 3757
	end) -- 3757
end -- 3745
local ListSubAgentsAction = __TS__Class() -- 3762
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3762
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3762
function ListSubAgentsAction.prototype.prep(self, shared) -- 3763
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3763
		local last = shared.history[#shared.history] -- 3773
		if not last then -- 3773
			error( -- 3774
				__TS__New(Error, "no history"), -- 3774
				0 -- 3774
			) -- 3774
		end -- 3774
		emitAgentStartEvent(shared, last) -- 3775
		return ____awaiter_resolve( -- 3775
			nil, -- 3775
			{ -- 3776
				sessionId = shared.sessionId, -- 3777
				projectRoot = shared.workingDir, -- 3778
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3779
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3780
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3781
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3782
				listSubAgents = shared.listSubAgents, -- 3783
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3784
			} -- 3784
		) -- 3784
	end) -- 3784
end -- 3763
function ListSubAgentsAction.prototype.exec(self, input) -- 3788
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3788
		if not input.listSubAgents then -- 3788
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3788
		end -- 3788
		if input.sessionId == nil or input.sessionId <= 0 then -- 3788
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3788
		end -- 3788
		local result = __TS__Await(input.listSubAgents({ -- 3804
			sessionId = input.sessionId, -- 3805
			projectRoot = input.projectRoot, -- 3806
			status = input.status, -- 3807
			limit = input.limit, -- 3808
			offset = input.offset, -- 3809
			query = input.query -- 3810
		})) -- 3810
		return ____awaiter_resolve( -- 3810
			nil, -- 3810
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3812
		) -- 3812
	end) -- 3812
end -- 3788
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3820
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3820
		local last = shared.history[#shared.history] -- 3821
		if last ~= nil then -- 3821
			last.result = execRes -- 3823
			appendToolResultMessage(shared, last) -- 3824
			emitAgentFinishEvent(shared, last) -- 3825
		end -- 3825
		persistHistoryState(shared) -- 3827
		__TS__Await(maybeCompressHistory(shared)) -- 3828
		persistHistoryState(shared) -- 3829
		return ____awaiter_resolve(nil, "main") -- 3829
	end) -- 3829
end -- 3820
EditFileAction = __TS__Class() -- 3834
EditFileAction.name = "EditFileAction" -- 3834
__TS__ClassExtends(EditFileAction, Node) -- 3834
function EditFileAction.prototype.prep(self, shared) -- 3835
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3835
		local last = shared.history[#shared.history] -- 3836
		if not last then -- 3836
			error( -- 3837
				__TS__New(Error, "no history"), -- 3837
				0 -- 3837
			) -- 3837
		end -- 3837
		emitAgentStartEvent(shared, last) -- 3838
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3839
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3842
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3843
		if __TS__StringTrim(path) == "" then -- 3843
			error( -- 3844
				__TS__New(Error, "missing path"), -- 3844
				0 -- 3844
			) -- 3844
		end -- 3844
		return ____awaiter_resolve(nil, { -- 3844
			path = path, -- 3845
			oldStr = oldStr, -- 3845
			newStr = newStr, -- 3845
			taskId = shared.taskId, -- 3845
			workDir = shared.workingDir -- 3845
		}) -- 3845
	end) -- 3845
end -- 3835
function EditFileAction.prototype.exec(self, input) -- 3848
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3848
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3849
		if not readRes.success then -- 3849
			if input.oldStr ~= "" then -- 3849
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3849
			end -- 3849
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3854
			if not createRes.success then -- 3854
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3854
			end -- 3854
			return ____awaiter_resolve( -- 3854
				nil, -- 3854
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3861
					success = true, -- 3862
					changed = true, -- 3863
					mode = "create", -- 3864
					checkpointId = createRes.checkpointId, -- 3865
					checkpointSeq = createRes.checkpointSeq, -- 3866
					files = {{path = input.path, op = "create"}} -- 3867
				}) -- 3867
			) -- 3867
		end -- 3867
		if input.oldStr == "" then -- 3867
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3867
				return ____awaiter_resolve( -- 3867
					nil, -- 3867
					{ -- 3872
						success = false, -- 3873
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3874
						actualSaved = false, -- 3875
						actualSavedCharacters = 0, -- 3876
						currentFileExists = true, -- 3877
						currentCharacters = #readRes.content, -- 3878
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3879
					} -- 3879
				) -- 3879
			end -- 3879
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3882
			if not overwriteRes.success then -- 3882
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3882
			end -- 3882
			return ____awaiter_resolve( -- 3882
				nil, -- 3882
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3889
					success = true, -- 3890
					changed = true, -- 3891
					mode = "overwrite", -- 3892
					checkpointId = overwriteRes.checkpointId, -- 3893
					checkpointSeq = overwriteRes.checkpointSeq, -- 3894
					files = {{path = input.path, op = "write"}} -- 3895
				}) -- 3895
			) -- 3895
		end -- 3895
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3900
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3901
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3902
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3905
		if occurrences == 0 then -- 3905
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3907
			if not indentTolerant.success then -- 3907
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3907
			end -- 3907
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3911
			if not applyRes.success then -- 3911
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3911
			end -- 3911
			return ____awaiter_resolve( -- 3911
				nil, -- 3911
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3918
					success = true, -- 3919
					changed = true, -- 3920
					mode = "replace_indent_tolerant", -- 3921
					checkpointId = applyRes.checkpointId, -- 3922
					checkpointSeq = applyRes.checkpointSeq, -- 3923
					files = {{path = input.path, op = "write"}} -- 3924
				}) -- 3924
			) -- 3924
		end -- 3924
		if occurrences > 1 then -- 3924
			return ____awaiter_resolve( -- 3924
				nil, -- 3924
				{ -- 3928
					success = false, -- 3928
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3928
				} -- 3928
			) -- 3928
		end -- 3928
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3932
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3933
		if not applyRes.success then -- 3933
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3933
		end -- 3933
		return ____awaiter_resolve( -- 3933
			nil, -- 3933
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3940
				success = true, -- 3941
				changed = true, -- 3942
				mode = "replace", -- 3943
				checkpointId = applyRes.checkpointId, -- 3944
				checkpointSeq = applyRes.checkpointSeq, -- 3945
				files = {{path = input.path, op = "write"}} -- 3946
			}) -- 3946
		) -- 3946
	end) -- 3946
end -- 3848
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3950
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3950
		local last = shared.history[#shared.history] -- 3951
		if last ~= nil then -- 3951
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3953
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3954
			appendToolResultMessage(shared, last) -- 3955
			emitAgentFinishEvent(shared, last) -- 3956
			local result = last.result -- 3957
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3957
				emitAgentEvent(shared, { -- 3962
					type = "checkpoint_created", -- 3963
					sessionId = shared.sessionId, -- 3964
					taskId = shared.taskId, -- 3965
					step = last.step, -- 3966
					tool = last.tool, -- 3967
					checkpointId = result.checkpointId, -- 3968
					checkpointSeq = result.checkpointSeq, -- 3969
					files = result.files -- 3970
				}) -- 3970
			end -- 3970
		end -- 3970
		persistHistoryState(shared) -- 3977
		__TS__Await(maybeCompressHistory(shared)) -- 3978
		persistHistoryState(shared) -- 3979
		return ____awaiter_resolve(nil, "main") -- 3979
	end) -- 3979
end -- 3950
local FetchUrlAction = __TS__Class() -- 3984
FetchUrlAction.name = "FetchUrlAction" -- 3984
__TS__ClassExtends(FetchUrlAction, Node) -- 3984
function FetchUrlAction.prototype.prep(self, shared) -- 3985
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3985
		local last = shared.history[#shared.history] -- 3986
		if not last then -- 3986
			error( -- 3987
				__TS__New(Error, "no history"), -- 3987
				0 -- 3987
			) -- 3987
		end -- 3987
		emitAgentStartEvent(shared, last) -- 3988
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3988
	end) -- 3988
end -- 3985
function FetchUrlAction.prototype.exec(self, input) -- 3992
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3992
		return ____awaiter_resolve( -- 3992
			nil, -- 3992
			executeToolAction(input.shared, input.action) -- 3993
		) -- 3993
	end) -- 3993
end -- 3992
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3996
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3996
		local last = shared.history[#shared.history] -- 3997
		if last ~= nil then -- 3997
			last.result = execRes -- 3999
			appendToolResultMessage(shared, last) -- 4000
			emitAgentFinishEvent(shared, last) -- 4001
		end -- 4001
		persistHistoryState(shared) -- 4003
		__TS__Await(maybeCompressHistory(shared)) -- 4004
		persistHistoryState(shared) -- 4005
		return ____awaiter_resolve(nil, "main") -- 4005
	end) -- 4005
end -- 3996
local function emitCheckpointEventForAction(shared, action) -- 4010
	local result = action.result -- 4011
	if not result then -- 4011
		return -- 4012
	end -- 4012
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4012
		emitAgentEvent(shared, { -- 4017
			type = "checkpoint_created", -- 4018
			sessionId = shared.sessionId, -- 4019
			taskId = shared.taskId, -- 4020
			step = action.step, -- 4021
			tool = action.tool, -- 4022
			checkpointId = result.checkpointId, -- 4023
			checkpointSeq = result.checkpointSeq, -- 4024
			files = result.files -- 4025
		}) -- 4025
	end -- 4025
end -- 4010
local function canRunBatchActionInParallel(self, action) -- 4556
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4557
end -- 4556
local function partitionToolCalls(actions) -- 4565
	local batches = {} -- 4566
	do -- 4566
		local i = 0 -- 4567
		while i < #actions do -- 4567
			local action = actions[i + 1] -- 4568
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4569
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4570
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4570
				local ____lastBatch_actions_187 = lastBatch.actions -- 4570
				____lastBatch_actions_187[#____lastBatch_actions_187 + 1] = action -- 4572
			else -- 4572
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4574
			end -- 4574
			i = i + 1 -- 4567
		end -- 4567
	end -- 4567
	return batches -- 4577
end -- 4565
local function completeStoppedToolAction(shared, action) -- 4580
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4581
	if not action.result then -- 4581
		action.result = { -- 4583
			success = false, -- 4583
			message = getCancelledReason(shared) -- 4583
		} -- 4583
	end -- 4583
	appendToolResultMessage(shared, action) -- 4585
	emitAgentFinishEvent(shared, action) -- 4586
	emitCheckpointEventForAction(shared, action) -- 4587
end -- 4580
local BatchToolAction = __TS__Class() -- 4590
BatchToolAction.name = "BatchToolAction" -- 4590
__TS__ClassExtends(BatchToolAction, Node) -- 4590
function BatchToolAction.prototype.prep(self, shared) -- 4591
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4591
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4591
	end) -- 4591
end -- 4591
function BatchToolAction.prototype.exec(self, input) -- 4595
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4595
		local shared = input.shared -- 4596
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4597
		local preExecuted = shared.preExecutedResults -- 4598
		local batches = partitionToolCalls(input.actions) -- 4599
		local parallelBatchCount = #__TS__ArrayFilter( -- 4600
			batches, -- 4600
			function(____, b) return b.isConcurrencySafe end -- 4600
		) -- 4600
		local serialBatchCount = #__TS__ArrayFilter( -- 4601
			batches, -- 4601
			function(____, b) return not b.isConcurrencySafe end -- 4601
		) -- 4601
		AgentUtils.Log( -- 4602
			"Info", -- 4602
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4602
		) -- 4602
		do -- 4602
			local batchIdx = 0 -- 4604
			while batchIdx < #batches do -- 4604
				do -- 4604
					local batch = batches[batchIdx + 1] -- 4605
					if shared.stopToken.stopped then -- 4605
						for ____, action in ipairs(batch.actions) do -- 4607
							completeStoppedToolAction(shared, action) -- 4608
						end -- 4608
						goto __continue762 -- 4610
					end -- 4610
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4610
						local preExecCount = #__TS__ArrayFilter( -- 4614
							batch.actions, -- 4614
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4614
						) -- 4614
						AgentUtils.Log( -- 4615
							"Info", -- 4615
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4615
						) -- 4615
						do -- 4615
							local i = 0 -- 4616
							while i < #batch.actions do -- 4616
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4617
								i = i + 1 -- 4616
							end -- 4616
						end -- 4616
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4619
							batch.actions, -- 4619
							function(____, action) -- 4619
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4619
									if shared.stopToken.stopped then -- 4619
										action.result = { -- 4621
											success = false, -- 4621
											message = getCancelledReason(shared) -- 4621
										} -- 4621
										return ____awaiter_resolve(nil, action) -- 4621
									end -- 4621
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4624
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4625
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4626
									return ____awaiter_resolve(nil, action) -- 4626
								end) -- 4626
							end -- 4619
						))) -- 4619
						do -- 4619
							local i = 0 -- 4629
							while i < #batch.actions do -- 4629
								local action = batch.actions[i + 1] -- 4630
								if not action.result then -- 4630
									action.result = {success = false, message = "tool did not produce a result"} -- 4632
								end -- 4632
								appendToolResultMessage(shared, action) -- 4634
								emitAgentFinishEvent(shared, action) -- 4635
								emitCheckpointEventForAction(shared, action) -- 4636
								i = i + 1 -- 4629
							end -- 4629
						end -- 4629
					else -- 4629
						AgentUtils.Log( -- 4639
							"Info", -- 4639
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4639
						) -- 4639
						do -- 4639
							local i = 0 -- 4640
							while i < #batch.actions do -- 4640
								local action = batch.actions[i + 1] -- 4641
								emitAgentStartEvent(shared, action) -- 4642
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4643
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4644
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4645
								appendToolResultMessage(shared, action) -- 4646
								emitAgentFinishEvent(shared, action) -- 4647
								emitCheckpointEventForAction(shared, action) -- 4648
								persistHistoryState(shared) -- 4649
								if shared.stopToken.stopped then -- 4649
									do -- 4649
										local j = i + 1 -- 4651
										while j < #batch.actions do -- 4651
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4652
											j = j + 1 -- 4651
										end -- 4651
									end -- 4651
									break -- 4654
								end -- 4654
								i = i + 1 -- 4640
							end -- 4640
						end -- 4640
					end -- 4640
				end -- 4640
				::__continue762:: -- 4640
				batchIdx = batchIdx + 1 -- 4604
			end -- 4604
		end -- 4604
		local spawnSeen = spawnedBeforeBatch -- 4659
		local didDelegatedForegroundWork = false -- 4660
		do -- 4660
			local i = 0 -- 4661
			while i < #input.actions do -- 4661
				do -- 4661
					local action = input.actions[i + 1] -- 4662
					if action.tool == "spawn_sub_agent" then -- 4662
						local ____opt_190 = action.result -- 4662
						if (____opt_190 and ____opt_190.success) == true then -- 4662
							spawnSeen = true -- 4664
						end -- 4664
						goto __continue782 -- 4665
					end -- 4665
					if spawnSeen and action.tool ~= "finish" then -- 4665
						didDelegatedForegroundWork = true -- 4668
					end -- 4668
				end -- 4668
				::__continue782:: -- 4668
				i = i + 1 -- 4661
			end -- 4661
		end -- 4661
		if didDelegatedForegroundWork then -- 4661
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4672
		end -- 4672
		persistHistoryState(shared) -- 4674
		return ____awaiter_resolve(nil, input.actions) -- 4674
	end) -- 4674
end -- 4595
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4678
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4678
		shared.pendingToolActions = nil -- 4679
		shared.preExecutedResults = nil -- 4680
		persistHistoryState(shared) -- 4681
		if shared.waitingQuestionnaireId == nil then -- 4681
			__TS__Await(maybeCompressHistory(shared)) -- 4685
			persistHistoryState(shared) -- 4686
		end -- 4686
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4686
	end) -- 4686
end -- 4678
local EndNode = __TS__Class() -- 4692
EndNode.name = "EndNode" -- 4692
__TS__ClassExtends(EndNode, Node) -- 4692
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4693
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4693
		return ____awaiter_resolve(nil, nil) -- 4693
	end) -- 4693
end -- 4693
local CodingAgentFlow = __TS__Class() -- 4698
CodingAgentFlow.name = "CodingAgentFlow" -- 4698
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4698
function CodingAgentFlow.prototype.____constructor(self, role) -- 4699
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4700
	local read = __TS__New(ReadFileAction, 1, 0) -- 4701
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4702
	local searchDora = __TS__New(SearchDoraDocAction, 1, 0) -- 4703
	local list = __TS__New(ListFilesAction, 1, 0) -- 4704
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4705
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4706
	local build = __TS__New(BuildAction, 1, 0) -- 4707
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4708
	local edit = __TS__New(EditFileAction, 1, 0) -- 4709
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4710
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4711
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4712
	local done = __TS__New(EndNode, 1, 0) -- 4713
	main:on("batch_tools", batch) -- 4715
	main:on("grep_files", search) -- 4716
	main:on("search_dora_doc", searchDora) -- 4717
	main:on("glob_files", list) -- 4718
	main:on("fetch_url", fetch) -- 4719
	main:on("execute_command", exec) -- 4720
	if role == "main" then -- 4720
		main:on("read_file", read) -- 4722
		main:on("delete_file", del) -- 4723
		main:on("build", build) -- 4724
		main:on("edit_file", edit) -- 4725
		main:on("list_sub_agents", listSub) -- 4726
		main:on("spawn_sub_agent", spawn) -- 4727
	else -- 4727
		main:on("read_file", read) -- 4729
		main:on("delete_file", del) -- 4730
		main:on("build", build) -- 4731
		main:on("edit_file", edit) -- 4732
	end -- 4732
	main:on("done", done) -- 4734
	search:on("main", main) -- 4736
	searchDora:on("main", main) -- 4737
	list:on("main", main) -- 4738
	listSub:on("main", main) -- 4739
	spawn:on("main", main) -- 4740
	batch:on("main", main) -- 4741
	batch:on("done", done) -- 4742
	read:on("main", main) -- 4743
	del:on("main", main) -- 4744
	build:on("main", main) -- 4745
	edit:on("main", main) -- 4746
	fetch:on("main", main) -- 4747
	exec:on("main", main) -- 4748
	Flow.prototype.____constructor(self, main) -- 4750
end -- 4699
local function runCodingAgentAsync(options) -- 4786
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4786
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4786
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4786
		end -- 4786
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4790
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4791
		if not llmConfigRes.success then -- 4791
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4791
		end -- 4791
		local llmConfig = llmConfigRes.config -- 4797
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4798
		if not taskRes.success then -- 4798
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4798
		end -- 4798
		local compressor = __TS__New(MemoryCompressor, { -- 4805
			compressionTargetThreshold = 0.5, -- 4806
			maxCompressionRounds = 3, -- 4807
			projectDir = options.workDir, -- 4808
			llmConfig = llmConfig, -- 4809
			promptPack = options.promptPack, -- 4810
			scope = options.memoryScope -- 4811
		}) -- 4811
		local persistedSession = compressor:getStorage():readSessionState() -- 4813
		local effectiveUserQuery = normalizedPrompt -- 4814
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4814
			do -- 4814
				local i = #persistedSession.messages - 1 -- 4816
				while i >= 0 do -- 4816
					local message = persistedSession.messages[i + 1] -- 4817
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4817
						effectiveUserQuery = message.content -- 4819
						break -- 4820
					end -- 4820
					i = i - 1 -- 4816
				end -- 4816
			end -- 4816
		end -- 4816
		local promptPack = compressor:getPromptPack() -- 4824
		local freshProject = inspectFreshProject(options.workDir) -- 4825
		local freshProjectBuildPending = freshProject.fresh -- 4826
		local freshProjectCodeFile = freshProject.codeFile -- 4827
		local shared = { -- 4829
			sessionId = options.sessionId, -- 4830
			taskId = taskRes.taskId, -- 4831
			role = options.role or "main", -- 4832
			maxSteps = math.max( -- 4833
				1, -- 4833
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4833
			), -- 4833
			llmMaxTry = math.max( -- 4834
				1, -- 4834
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4834
			), -- 4834
			step = math.max( -- 4835
				0, -- 4835
				math.floor(options.initialStep or 0) -- 4835
			), -- 4835
			agentStepCount = math.max( -- 4836
				0, -- 4836
				math.floor(options.initialAgentStepCount or 0) -- 4836
			), -- 4836
			done = false, -- 4837
			stopToken = options.stopToken or ({stopped = false}), -- 4838
			response = "", -- 4839
			userQuery = effectiveUserQuery, -- 4840
			workingDir = options.workDir, -- 4841
			useChineseResponse = options.useChineseResponse == true, -- 4842
			workMode = options.workMode or "code", -- 4843
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4844
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4847
			llmConfig = llmConfig, -- 4848
			onEvent = options.onEvent, -- 4849
			promptPack = promptPack, -- 4850
			history = {}, -- 4851
			messages = persistedSession.messages, -- 4852
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4853
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4854
			memory = {compressor = compressor}, -- 4856
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4860
				projectDir = options.workDir, -- 4862
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4863
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4864
			})}, -- 4864
			spawnSubAgent = options.spawnSubAgent, -- 4870
			listSubAgents = options.listSubAgents, -- 4871
			publishQuestionnaire = options.publishQuestionnaire, -- 4872
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4873
			freshProjectBuildPending = freshProjectBuildPending, -- 4874
			freshProjectCodeFile = freshProjectCodeFile, -- 4875
			hasSpawnedSubAgentThisTask = false, -- 4876
			delegatedForegroundBatches = 0, -- 4877
			tokenUsage = options.initialTokenUsage -- 4878
		} -- 4878
		local ____hasReturned, ____returnValue -- 4878
		local ____try = __TS__AsyncAwaiter(function() -- 4878
			if shared.workMode == "plan" then -- 4878
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4883
				if not planDocuments.success then -- 4883
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4885
					____hasReturned = true -- 4886
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4886
					return -- 4886
				end -- 4886
			end -- 4886
			emitAgentEvent(shared, { -- 4889
				type = "task_started", -- 4890
				sessionId = shared.sessionId, -- 4891
				taskId = shared.taskId, -- 4892
				prompt = shared.userQuery, -- 4893
				workDir = shared.workingDir, -- 4894
				maxSteps = shared.maxSteps, -- 4895
				resumed = options.resumeTask == true -- 4896
			}) -- 4896
			if shared.stopToken.stopped then -- 4896
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4899
				____hasReturned = true -- 4900
				____returnValue = emitAgentTaskFinishEvent( -- 4900
					shared, -- 4900
					false, -- 4900
					getCancelledReason(shared) -- 4900
				) -- 4900
				return -- 4900
			end -- 4900
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4902
			local ____temp_192 -- 4903
			if options.resumeConversation == true then -- 4903
				____temp_192 = nil -- 4903
			else -- 4903
				____temp_192 = getPromptCommand(shared.userQuery) -- 4903
			end -- 4903
			local promptCommand = ____temp_192 -- 4903
			if promptCommand == "clear" then -- 4903
				____hasReturned = true -- 4905
				____returnValue = clearSessionHistory(shared) -- 4905
				return -- 4905
			end -- 4905
			if promptCommand == "compact" then -- 4905
				if shared.role == "sub" then -- 4905
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4909
					____hasReturned = true -- 4910
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4910
					return -- 4910
				end -- 4910
				____hasReturned = true -- 4918
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4918
				return -- 4918
			end -- 4918
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4920
			if shared.stopToken.stopped then -- 4920
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4922
				____hasReturned = true -- 4923
				____returnValue = emitAgentTaskFinishEvent( -- 4923
					shared, -- 4923
					false, -- 4923
					getCancelledReason(shared) -- 4923
				) -- 4923
				return -- 4923
			end -- 4923
			if options.resumeConversation ~= true then -- 4923
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4926
				persistHistoryState(shared) -- 4930
			end -- 4930
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4932
			__TS__Await(flow:run(shared)) -- 4933
			if shared.stopToken.stopped then -- 4933
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4935
				____hasReturned = true -- 4936
				____returnValue = emitAgentTaskFinishEvent( -- 4936
					shared, -- 4936
					false, -- 4936
					getCancelledReason(shared) -- 4936
				) -- 4936
				return -- 4936
			end -- 4936
			if shared.error then -- 4936
				____hasReturned = true -- 4939
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4939
				return -- 4939
			end -- 4939
			if shared.waitingQuestionnaireId ~= nil then -- 4939
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4943
				emitAgentEvent(shared, { -- 4944
					type = "task_waiting_for_user", -- 4945
					sessionId = shared.sessionId, -- 4946
					taskId = shared.taskId, -- 4947
					step = shared.step, -- 4948
					questionnaireId = shared.waitingQuestionnaireId -- 4949
				}) -- 4949
				____hasReturned = true -- 4951
				____returnValue = { -- 4951
					success = true, -- 4952
					taskId = shared.taskId, -- 4953
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4954
					steps = shared.step, -- 4955
					waitingForUser = true, -- 4956
					questionnaireId = shared.waitingQuestionnaireId -- 4957
				} -- 4957
				return -- 4951
			end -- 4951
			local ____isFinalDecisionTurn_result_195 = isFinalDecisionTurn(shared) -- 4960
			if ____isFinalDecisionTurn_result_195 then -- 4960
				local ____opt_193 = shared.completion -- 4960
				____isFinalDecisionTurn_result_195 = (____opt_193 and ____opt_193.outcome) == "partial" -- 4960
			end -- 4960
			if ____isFinalDecisionTurn_result_195 then -- 4960
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4961
				____hasReturned = true -- 4962
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4962
				return -- 4962
			end -- 4962
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4965
			____hasReturned = true -- 4966
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4966
			return -- 4966
		end) -- 4966
		____try = ____try.catch( -- 4966
			____try, -- 4966
			function(____, e) -- 4966
				return __TS__AsyncAwaiter(function() -- 4966
					____hasReturned = true -- 4969
					____returnValue = finalizeAgentFailure( -- 4969
						shared, -- 4969
						tostring(e) -- 4969
					) -- 4969
					return -- 4969
				end) -- 4969
			end -- 4969
		) -- 4969
		__TS__Await(____try) -- 4881
		if ____hasReturned then -- 4881
			return ____awaiter_resolve(nil, ____returnValue) -- 4881
		end -- 4881
	end) -- 4881
end -- 4786
function ____exports.runCodingAgent(options, callback) -- 4973
	local ____self_196 = runCodingAgentAsync(options) -- 4973
	____self_196["then"]( -- 4973
		____self_196, -- 4973
		function(____, result) return callback(result) end -- 4974
	) -- 4974
end -- 4973
return ____exports -- 4973