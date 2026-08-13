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
function emitAgentEvent(shared, event) -- 453
	if shared.onEvent then -- 453
		do -- 453
			local function ____catch(____error) -- 453
				AgentUtils.Log( -- 458
					"Error", -- 458
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 458
				) -- 458
			end -- 458
			local ____try, ____hasReturned = pcall(function() -- 458
				shared:onEvent(event) -- 456
			end) -- 456
			if not ____try then -- 456
				____catch(____hasReturned) -- 456
			end -- 456
		end -- 456
	end -- 456
end -- 456
function getCancelledReason(shared) -- 640
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 640
		return shared.stopToken.reason -- 641
	end -- 641
	return shared.useChineseResponse and "已取消" or "cancelled" -- 642
end -- 642
function ____exports.normalizePolicyPath(path) -- 704
	return AgentRuntimePolicy.normalizeAgentPath(path) -- 705
end -- 704
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 713
	return AgentRuntimePolicy.isMainAgentMemoryPath(path) -- 714
end -- 713
function toJson(value, emptyAsArray) -- 862
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 863
	if text ~= nil then -- 863
		return text -- 864
	end -- 864
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 865
end -- 865
function truncateText(text, maxLen) -- 868
	if #text <= maxLen then -- 868
		return text -- 869
	end -- 869
	local nextPos = utf8.offset(text, maxLen + 1) -- 870
	if nextPos == nil then -- 870
		return text -- 871
	end -- 871
	return string.sub(text, 1, nextPos - 1) .. "..." -- 872
end -- 872
function utf8TakeHead(text, maxChars) -- 875
	if maxChars <= 0 or text == "" then -- 875
		return "" -- 876
	end -- 876
	local nextPos = utf8.offset(text, maxChars + 1) -- 877
	if nextPos == nil then -- 877
		return text -- 878
	end -- 878
	return string.sub(text, 1, nextPos - 1) -- 879
end -- 879
function utf8TakeTail(text, maxChars) -- 882
	if maxChars <= 0 or text == "" then -- 882
		return "" -- 883
	end -- 883
	local charLength = utf8.len(text) -- 884
	if charLength == nil or charLength <= maxChars then -- 884
		return text -- 885
	end -- 885
	local startPos = utf8.offset( -- 886
		text, -- 886
		math.max(1, charLength - maxChars + 1) -- 886
	) -- 886
	if startPos == nil then -- 886
		return text -- 887
	end -- 887
	return string.sub(text, startPos) -- 888
end -- 888
function truncateHistoryText(text, maxChars, label) -- 891
	if maxChars <= 0 or text == "" then -- 891
		return "" -- 892
	end -- 892
	if #text <= maxChars then -- 892
		return text -- 893
	end -- 893
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 894
	local remaining = math.max(0, maxChars - #marker) -- 895
	local headChars = math.floor(remaining * 0.6) -- 896
	local tailChars = remaining - headChars -- 897
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 898
end -- 898
function getReplyLanguageDirective(shared) -- 901
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 902
end -- 902
function replacePromptVars(template, vars) -- 907
	local output = template -- 908
	for key in pairs(vars) do -- 909
		output = table.concat( -- 910
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 910
			vars[key] or "" or "," -- 910
		) -- 910
	end -- 910
	return output -- 912
end -- 912
function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 915
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 931
	local contentLines = __TS__StringSplit(content, "\n") -- 932
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 933
	if #content <= maxChars and availableSourceLines <= maxLines then -- 933
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 935
	end -- 935
	local contentBudget = math.max(0, maxChars - 240) -- 946
	local candidateLines = math.min(availableSourceLines, maxLines) -- 947
	local retainedLines = {} -- 948
	local retainedChars = 0 -- 949
	do -- 949
		local i = 0 -- 950
		while i < candidateLines do -- 950
			local line = contentLines[i + 1] -- 951
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 952
			if nextChars > contentBudget then -- 952
				break -- 953
			end -- 953
			retainedLines[#retainedLines + 1] = line -- 954
			retainedChars = nextChars -- 955
			i = i + 1 -- 950
		end -- 950
	end -- 950
	local retainedEndLine = startLine + #retainedLines - 1 -- 958
	local partialLine -- 959
	local retainedContent = table.concat(retainedLines, "\n") -- 960
	if #retainedLines == 0 and candidateLines > 0 then -- 960
		partialLine = startLine -- 962
		retainedEndLine = startLine - 1 -- 963
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 964
	end -- 964
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 966
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 967
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 972
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 975
	return { -- 976
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 977
		truncated = true, -- 978
		retainedStartLine = startLine, -- 979
		retainedEndLine = retainedEndLine, -- 980
		nextStartLine = nextStartLine, -- 981
		partialLine = partialLine -- 982
	} -- 982
end -- 982
function sanitizeReadResultForHistory(tool, result) -- 998
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 998
		return result -- 1000
	end -- 1000
	local clone = {} -- 1002
	for key in pairs(result) do -- 1003
		clone[key] = result[key] -- 1004
	end -- 1004
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 1006
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 1007
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 1008
	local limited = limitReadContentForHistory( -- 1009
		result.content, -- 1010
		startLine, -- 1011
		endLine, -- 1012
		totalLines, -- 1013
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 1014
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 1015
		"read_file history" -- 1016
	) -- 1016
	clone.content = limited.content -- 1018
	if limited.truncated then -- 1018
		clone.historyContentTruncated = true -- 1020
		clone.historyRetainedStartLine = limited.retainedStartLine -- 1021
		clone.historyRetainedEndLine = limited.retainedEndLine -- 1022
		if limited.nextStartLine ~= nil then -- 1022
			clone.historyNextStartLine = limited.nextStartLine -- 1023
		end -- 1023
		if limited.partialLine ~= nil then -- 1023
			clone.historyPartialLine = limited.partialLine -- 1024
		end -- 1024
	end -- 1024
	return clone -- 1026
end -- 1026
function sanitizeSearchMatchesForHistory(items, maxItems) -- 1029
	local shown = math.min(#items, maxItems) -- 1033
	local out = {} -- 1034
	do -- 1034
		local i = 0 -- 1035
		while i < shown do -- 1035
			local row = items[i + 1] -- 1036
			out[#out + 1] = { -- 1037
				file = row.file, -- 1038
				line = row.line, -- 1039
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1040
			} -- 1040
			i = i + 1 -- 1035
		end -- 1035
	end -- 1035
	return out -- 1045
end -- 1045
function sanitizeSearchResultForHistory(tool, result) -- 1048
	if result.success ~= true or not isArray(result.results) then -- 1048
		return result -- 1052
	end -- 1052
	if tool ~= "grep_files" and tool ~= "search_dora_doc" then -- 1052
		return result -- 1053
	end -- 1053
	local clone = {} -- 1054
	for key in pairs(result) do -- 1055
		clone[key] = result[key] -- 1056
	end -- 1056
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 1058
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1059
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1059
		local grouped = result.groupedResults -- 1064
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 1065
		local sanitizedGroups = {} -- 1066
		do -- 1066
			local i = 0 -- 1067
			while i < shown do -- 1067
				local row = grouped[i + 1] -- 1068
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1069
					file = row.file, -- 1070
					totalMatches = row.totalMatches, -- 1071
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1072
				} -- 1072
				i = i + 1 -- 1067
			end -- 1067
		end -- 1067
		clone.groupedResults = sanitizedGroups -- 1077
	end -- 1077
	return clone -- 1079
end -- 1079
function sanitizeListFilesResultForHistory(result) -- 1082
	if result.success ~= true or not isArray(result.files) then -- 1082
		return result -- 1083
	end -- 1083
	local clone = {} -- 1084
	for key in pairs(result) do -- 1085
		clone[key] = result[key] -- 1086
	end -- 1086
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 1088
	return clone -- 1089
end -- 1089
function sanitizeBuildResultForHistory(result) -- 1092
	if not isArray(result.messages) then -- 1092
		return result -- 1093
	end -- 1093
	local clone = {} -- 1094
	for key in pairs(result) do -- 1095
		clone[key] = result[key] -- 1096
	end -- 1096
	local messages = result.messages -- 1098
	local ordered = __TS__ArraySort( -- 1099
		__TS__ArraySlice(messages), -- 1099
		function(____, a, b) -- 1099
			local aFailed = a.success ~= true -- 1100
			local bFailed = b.success ~= true -- 1101
			if aFailed == bFailed then -- 1101
				return 0 -- 1102
			end -- 1102
			return aFailed and -1 or 1 -- 1103
		end -- 1099
	) -- 1099
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1105
	local sanitized = {} -- 1106
	do -- 1106
		local i = 0 -- 1107
		while i < shown do -- 1107
			local item = ordered[i + 1] -- 1108
			local next = {} -- 1109
			for key in pairs(item) do -- 1110
				local value = item[key] -- 1111
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1112
			end -- 1112
			sanitized[#sanitized + 1] = next -- 1116
			i = i + 1 -- 1107
		end -- 1107
	end -- 1107
	clone.messages = sanitized -- 1118
	if #ordered > shown then -- 1118
		clone.truncatedMessages = #ordered - shown -- 1120
	end -- 1120
	return clone -- 1122
end -- 1122
function projectEditResultForLLM(result) -- 1140
	if result.success ~= true then -- 1140
		local failed = {} -- 1142
		for key in pairs(result) do -- 1143
			local value = result[key] -- 1144
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 1145
		end -- 1145
		return failed -- 1149
	end -- 1149
	local projected = {} -- 1151
	local scalarKeys = { -- 1152
		"success", -- 1153
		"changed", -- 1153
		"mode", -- 1153
		"checkpointId", -- 1153
		"checkpointSeq", -- 1153
		"checkpointed", -- 1154
		"reversible", -- 1154
		"binary", -- 1154
		"actualSaved", -- 1155
		"actualSavedCharacters", -- 1155
		"currentFileExists", -- 1155
		"currentCharacters", -- 1155
		"currentState" -- 1155
	} -- 1155
	do -- 1155
		local i = 0 -- 1157
		while i < #scalarKeys do -- 1157
			local key = scalarKeys[i + 1] -- 1158
			if result[key] ~= nil then -- 1158
				projected[key] = result[key] -- 1159
			end -- 1159
			i = i + 1 -- 1157
		end -- 1157
	end -- 1157
	if isArray(result.files) then -- 1157
		projected.files = result.files -- 1161
	end -- 1161
	if type(result.message) == "string" then -- 1161
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1163
	end -- 1163
	if type(result.guidance) == "string" then -- 1163
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1170
	end -- 1170
	if isArray(result.fileContext) then -- 1170
		local summaries = {} -- 1177
		do -- 1177
			local i = 0 -- 1178
			while i < #result.fileContext do -- 1178
				do -- 1178
					local item = result.fileContext[i + 1] -- 1179
					if not isRecord(item) or isArray(item) then -- 1179
						goto __continue158 -- 1180
					end -- 1180
					local summary = {} -- 1181
					local keys = { -- 1182
						"path", -- 1183
						"op", -- 1183
						"beforeExists", -- 1183
						"afterExists", -- 1183
						"beforeBytes", -- 1183
						"afterBytes", -- 1183
						"lineCount", -- 1184
						"contentTruncated", -- 1184
						"fileListTruncated" -- 1184
					} -- 1184
					do -- 1184
						local j = 0 -- 1186
						while j < #keys do -- 1186
							local key = keys[j + 1] -- 1187
							if item[key] ~= nil then -- 1187
								summary[key] = item[key] -- 1188
							end -- 1188
							j = j + 1 -- 1186
						end -- 1186
					end -- 1186
					summaries[#summaries + 1] = summary -- 1190
				end -- 1190
				::__continue158:: -- 1190
				i = i + 1 -- 1178
			end -- 1178
		end -- 1178
		if #summaries > 0 then -- 1178
			projected.fileSummary = summaries -- 1192
		end -- 1192
	end -- 1192
	if type(result.truncatedFileContextItems) == "number" then -- 1192
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1195
	end -- 1195
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1197
	return projected -- 1198
end -- 1198
function projectBuildResultForLLM(result) -- 1201
	if not isArray(result.messages) then -- 1201
		return result -- 1202
	end -- 1202
	local projected = {} -- 1203
	for key in pairs(result) do -- 1204
		if key ~= "messages" then -- 1204
			projected[key] = result[key] -- 1205
		end -- 1205
	end -- 1205
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1207
	local shown = math.min(#result.messages, maxMessages) -- 1208
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1209
	if #result.messages > shown then -- 1209
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1211
	end -- 1211
	return projected -- 1213
end -- 1213
function projectCommandResultForLLM(result) -- 1216
	local projected = {} -- 1217
	for key in pairs(result) do -- 1218
		local value = result[key] -- 1219
		if key == "output" and type(value) == "string" then -- 1219
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1221
		elseif key == "message" and type(value) == "string" then -- 1221
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1227
		else -- 1227
			projected[key] = value -- 1233
		end -- 1233
	end -- 1233
	return projected -- 1236
end -- 1236
function projectToolResultContentForLLM(tool, content) -- 1239
	local decoded = AgentUtils.safeJsonDecode(content) -- 1240
	if not isRecord(decoded) or isArray(decoded) then -- 1240
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1242
	end -- 1242
	local projected = decoded -- 1248
	if tool == "edit_file" or tool == "delete_file" then -- 1248
		projected = projectEditResultForLLM(decoded) -- 1250
	elseif tool == "build" then -- 1250
		projected = projectBuildResultForLLM(decoded) -- 1252
	elseif tool == "execute_command" then -- 1252
		projected = projectCommandResultForLLM(decoded) -- 1254
	end -- 1254
	local encoded = toJson(projected, false) -- 1256
	if tool == "read_file" then -- 1256
		return encoded -- 1259
	end -- 1259
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1259
		return encoded -- 1260
	end -- 1260
	local fallback = { -- 1261
		success = projected.success, -- 1262
		llmHistoryTruncated = true, -- 1263
		originalChars = #encoded, -- 1264
		preview = truncateHistoryText( -- 1265
			encoded, -- 1266
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1267
			tool .. " result" -- 1268
		) -- 1268
	} -- 1268
	return toJson(fallback, false) -- 1271
end -- 1271
function projectMessagesForLLMContext(messages) -- 1273
	local projected = {} -- 1277
	do -- 1277
		local i = 0 -- 1278
		while i < #messages do -- 1278
			local message = messages[i + 1] -- 1279
			local next = __TS__ObjectAssign({}, message) -- 1280
			if message.role == "assistant" and (not message.tool_calls or #message.tool_calls == 0) then -- 1280
				next.reasoning_content = nil -- 1281
			end -- 1281
			if message.role == "tool" and type(message.content) == "string" then -- 1281
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1283
			end -- 1283
			projected[#projected + 1] = next -- 1285
			i = i + 1 -- 1278
		end -- 1278
	end -- 1278
	return projected -- 1287
end -- 1287
function ____exports.getDecisionDisabledAgentTools(shared) -- 1315
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1319
end -- 1315
function getDecisionToolDefinitions(shared) -- 1322
	local params = {SEARCH_DORA_DOC_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax)} -- 1323
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1324
	local base = shared.promptPack.toolDefinitionsDetailed -- 1327
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1328
	if usesDefaultToolPrompts then -- 1328
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1331
			shared.role, -- 1331
			{ -- 1331
				includeFinish = true, -- 1332
				includeXmlRules = true, -- 1333
				context = {searchDoraDocLimitMax = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax}, -- 1334
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1335
				workMode = shared.workMode -- 1336
			} -- 1336
		) -- 1336
		return replacePromptVars(definitions, params) -- 1338
	end -- 1338
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1340
	if (shared and shared.decisionMode) ~= "xml" then -- 1340
		return withRole -- 1345
	end -- 1345
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1347
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1348
end -- 1348
function isToolAllowedForRole(shared, tool) -- 1362
	return __TS__ArrayIndexOf( -- 1363
		AgentToolRegistry.getAllowedToolsForRole( -- 1363
			shared.role, -- 1363
			{ -- 1363
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1364
				workMode = shared.workMode -- 1365
			} -- 1365
		), -- 1365
		tool -- 1366
	) >= 0 -- 1366
end -- 1366
function getFinishMessage(params, fallback) -- 1835
	if fallback == nil then -- 1835
		fallback = "" -- 1835
	end -- 1835
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1835
		return __TS__StringTrim(params.message) -- 1837
	end -- 1837
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1837
		return __TS__StringTrim(params.response) -- 1840
	end -- 1840
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1840
		return __TS__StringTrim(params.summary) -- 1843
	end -- 1843
	return __TS__StringTrim(fallback) -- 1845
end -- 1845
function getCompletionReport(params) -- 1848
	return AgentUtils.normalizeAgentCompletionReport(params) -- 1849
end -- 1849
function persistHistoryState(shared) -- 1852
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1853
end -- 1853
function getActiveConversationMessages(shared) -- 1860
	local activeMessages = {} -- 1861
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1861
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1868
	end -- 1868
	do -- 1868
		local i = shared.lastConsolidatedIndex -- 1872
		while i < #shared.messages do -- 1872
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1873
			i = i + 1 -- 1872
		end -- 1872
	end -- 1872
	return activeMessages -- 1875
end -- 1875
function getActiveRealMessageCount(shared) -- 1878
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1879
end -- 1879
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1882
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1888
	local previousActiveStart = shared.lastConsolidatedIndex -- 1889
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1890
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1891
	if type(carryMessageIndex) == "number" then -- 1891
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1891
		else -- 1891
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1899
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1902
		end -- 1902
	else -- 1902
		shared.carryMessageIndex = nil -- 1907
	end -- 1907
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1907
		shared.carryMessageIndex = nil -- 1917
	end -- 1917
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1925
	shared.resumeCheckpointPending = true -- 1926
	shared.resumeRequiredTool = nil -- 1927
	shared.resumeNarrowReadMode = true -- 1928
	if shared.unbuiltEdits == true then -- 1928
		shared.resumeRequiredTool = "build" -- 1936
	end -- 1936
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 -- 1945
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1945
		local marker = "**Next tool**:" -- 1956
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1957
		if markerIndex >= 0 then -- 1957
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1959
			local toolNames = { -- 1960
				"read_file", -- 1961
				"edit_file", -- 1961
				"delete_file", -- 1961
				"grep_files", -- 1961
				"search_dora_doc", -- 1961
				"glob_files", -- 1962
				"build", -- 1962
				"fetch_url", -- 1962
				"execute_command", -- 1962
				"list_sub_agents", -- 1962
				"spawn_sub_agent", -- 1963
				"finish" -- 1963
			} -- 1963
			do -- 1963
				local i = 0 -- 1965
				while i < #toolNames do -- 1965
					local tool = toolNames[i + 1] -- 1966
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1966
						shared.resumeRequiredTool = tool -- 1968
						break -- 1969
					end -- 1969
					i = i + 1 -- 1965
				end -- 1965
			end -- 1965
		end -- 1965
	end -- 1965
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1965
		shared.resumeRequiredTool = nil -- 1975
	end -- 1975
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1975
		shared.resumeRequiredTool = nil -- 1978
	end -- 1978
end -- 1978
function ensureToolCallId(toolCallId) -- 1993
	if toolCallId and toolCallId ~= "" then -- 1993
		return toolCallId -- 1994
	end -- 1994
	return AgentUtils.createLocalToolCallId() -- 1995
end -- 1995
function hasXMLParam(params, name) -- 2028
	return params[name] ~= nil -- 2029
end -- 2029
function inferToolNameFromXMLParams(params) -- 2032
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 2032
		return "edit_file" -- 2034
	end -- 2034
	if hasXMLParam(params, "target_file") then -- 2034
		return "delete_file" -- 2037
	end -- 2037
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 2037
		if hasXMLParam(params, "path") then -- 2037
			return "read_file" -- 2040
		end -- 2040
		return nil -- 2041
	end -- 2041
	if hasXMLParam(params, "docType") or hasXMLParam(params, "programmingLanguage") then -- 2041
		if hasXMLParam(params, "pattern") then -- 2041
			return "search_dora_doc" -- 2044
		end -- 2044
		return nil -- 2045
	end -- 2045
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 2045
		if hasXMLParam(params, "pattern") then -- 2045
			return "grep_files" -- 2048
		end -- 2048
		return nil -- 2049
	end -- 2049
	if hasXMLParam(params, "globs") then -- 2049
		if hasXMLParam(params, "pattern") then -- 2049
			return "grep_files" -- 2052
		end -- 2052
		return "glob_files" -- 2053
	end -- 2053
	if hasXMLParam(params, "maxEntries") then -- 2053
		return "glob_files" -- 2056
	end -- 2056
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2056
		return "finish" -- 2059
	end -- 2059
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 2059
		return "spawn_sub_agent" -- 2062
	end -- 2062
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 2062
		return "list_sub_agents" -- 2065
	end -- 2065
	return nil -- 2067
end -- 2067
function parseDSMLAttribute(source, offset, name) -- 2070
	local attrOpen = name .. "=\"" -- 2071
	local attrStart = (string.find( -- 2072
		source, -- 2072
		attrOpen, -- 2072
		math.max(offset + 1, 1), -- 2072
		true -- 2072
	) or 0) - 1 -- 2072
	if attrStart < 0 then -- 2072
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 2073
	end -- 2073
	local valueStart = attrStart + #attrOpen -- 2074
	local valueEnd = (string.find( -- 2075
		source, -- 2075
		"\"", -- 2075
		math.max(valueStart + 1, 1), -- 2075
		true -- 2075
	) or 0) - 1 -- 2075
	if valueEnd < 0 then -- 2075
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 2076
	end -- 2076
	return { -- 2077
		success = true, -- 2078
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 2079
		next = valueEnd + 1 -- 2080
	} -- 2080
end -- 2080
function extractDSMLReason(text, invokeStart, tool) -- 2084
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2085
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2086
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2086
		return before -- 2089
	end -- 2089
	if tool == "finish" then -- 2089
		return "" -- 2090
	end -- 2090
	return "Converted provider-native tool call syntax to XML." -- 2091
end -- 2091
function parseDSMLToolCallObjectFromText(text) -- 2094
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2095
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2096
	if invokeStart < 0 then -- 2096
		return {success = false, message = "missing DSML invoke"} -- 2097
	end -- 2097
	local nameStart = invokeStart + #invokeOpen -- 2098
	local nameEnd = (string.find( -- 2099
		text, -- 2099
		"\"", -- 2099
		math.max(nameStart + 1, 1), -- 2099
		true -- 2099
	) or 0) - 1 -- 2099
	if nameEnd < 0 then -- 2099
		return {success = false, message = "unterminated DSML invoke name"} -- 2100
	end -- 2100
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2101
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2101
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2103
	end -- 2103
	local invokeOpenEnd = (string.find( -- 2105
		text, -- 2105
		">", -- 2105
		math.max(nameEnd + 1, 1), -- 2105
		true -- 2105
	) or 0) - 1 -- 2105
	if invokeOpenEnd < 0 then -- 2105
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2106
	end -- 2106
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2107
	local invokeEnd = (string.find( -- 2108
		text, -- 2108
		invokeClose, -- 2108
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2108
		true -- 2108
	) or 0) - 1 -- 2108
	if invokeEnd < 0 then -- 2108
		return {success = false, message = "missing DSML invoke close tag"} -- 2109
	end -- 2109
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2111
	local params = {} -- 2112
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2113
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2114
	local pos = 0 -- 2115
	while pos < #body do -- 2115
		local start = (string.find( -- 2117
			body, -- 2117
			paramOpen, -- 2117
			math.max(pos + 1, 1), -- 2117
			true -- 2117
		) or 0) - 1 -- 2117
		if start < 0 then -- 2117
			break -- 2118
		end -- 2118
		local openEnd = (string.find( -- 2119
			body, -- 2119
			">", -- 2119
			math.max(start + #paramOpen + 1, 1), -- 2119
			true -- 2119
		) or 0) - 1 -- 2119
		if openEnd < 0 then -- 2119
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2120
		end -- 2120
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2121
		if not name.success then -- 2121
			return name -- 2122
		end -- 2122
		local close = (string.find( -- 2123
			body, -- 2123
			paramClose, -- 2123
			math.max(openEnd + 1 + 1, 1), -- 2123
			true -- 2123
		) or 0) - 1 -- 2123
		if close < 0 then -- 2123
			return {success = false, message = "missing DSML parameter close tag"} -- 2124
		end -- 2124
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2125
		pos = close + #paramClose -- 2126
	end -- 2126
	return { -- 2128
		success = true, -- 2129
		obj = { -- 2130
			tool = toolName, -- 2131
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2132
			params = params -- 2133
		} -- 2133
	} -- 2133
end -- 2133
function parseXMLToolCallObjectFromText(text) -- 2138
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2139
	local rawObj -- 2140
	if children.success then -- 2140
		rawObj = children.obj -- 2142
	else -- 2142
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2144
		if dsml.success then -- 2144
			return dsml -- 2145
		end -- 2145
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2146
		local paramsCloseToken = "</params>" -- 2147
		if toolStart >= 0 then -- 2147
			local paramsClose = (string.find( -- 2149
				text, -- 2149
				paramsCloseToken, -- 2149
				math.max(toolStart + 1, 1), -- 2149
				true -- 2149
			) or 0) - 1 -- 2149
			if paramsClose >= toolStart then -- 2149
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2151
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2152
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2152
					rawObj = bare.obj -- 2154
				end -- 2154
			end -- 2154
		end -- 2154
		if rawObj == nil then -- 2154
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2159
			if paramsOpen < 0 then -- 2159
				return children -- 2160
			end -- 2160
			local paramsCloseOnly = (string.find( -- 2161
				text, -- 2161
				paramsCloseToken, -- 2161
				math.max(paramsOpen + 1, 1), -- 2161
				true -- 2161
			) or 0) - 1 -- 2161
			if paramsCloseOnly < paramsOpen then -- 2161
				return children -- 2162
			end -- 2162
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2163
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2164
			if not paramsOnly.success then -- 2164
				return children -- 2165
			end -- 2165
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2166
			if inferredTool == nil then -- 2166
				return children -- 2167
			end -- 2167
			local ____temp_50 -- 2172
			if inferredTool == "finish" then -- 2172
				____temp_50 = nil -- 2172
			else -- 2172
				____temp_50 = "Inferred tool from XML params." -- 2172
			end -- 2172
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2168
		end -- 2168
	end -- 2168
	if rawObj == nil then -- 2168
		return children -- 2178
	end -- 2178
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2179
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2180
	if not params.success then -- 2180
		return {success = false, message = params.message} -- 2184
	end -- 2184
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2186
end -- 2186
function parseDecisionObject(rawObj) -- 2293
	if type(rawObj.tool) ~= "string" then -- 2293
		return {success = false, message = "missing tool"} -- 2294
	end -- 2294
	local tool = rawObj.tool -- 2295
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2295
		return {success = false, message = "unknown tool: " .. tool} -- 2297
	end -- 2297
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2299
	if tool ~= "finish" and (not reason or reason == "") then -- 2299
		return {success = false, message = tool .. " requires top-level reason"} -- 2303
	end -- 2303
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2305
	return {success = true, tool = tool, params = params, reason = reason} -- 2306
end -- 2306
function getDecisionPath(params) -- 2428
	if type(params.path) == "string" then -- 2428
		return __TS__StringTrim(params.path) -- 2429
	end -- 2429
	if type(params.target_file) == "string" then -- 2429
		return __TS__StringTrim(params.target_file) -- 2430
	end -- 2430
	return "" -- 2431
end -- 2431
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2434
	if enforceFinalTurn == nil then -- 2434
		enforceFinalTurn = false -- 2438
	end -- 2438
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2438
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2441
	end -- 2441
	if not isToolAllowedForRole(shared, tool) then -- 2441
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2444
	end -- 2444
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2444
		local path = getDecisionPath(params) -- 2447
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2447
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2449
		end -- 2449
	end -- 2449
	if tool == "delete_file" then -- 2449
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2453
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2453
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2455
		end -- 2455
	end -- 2455
	return {success = true} -- 2458
end -- 2458
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2461
	local num = __TS__Number(value) -- 2462
	if not __TS__NumberIsFinite(num) then -- 2462
		num = fallback -- 2463
	end -- 2463
	num = math.floor(num) -- 2464
	if num < minValue then -- 2464
		num = minValue -- 2465
	end -- 2465
	if maxValue ~= nil and num > maxValue then -- 2465
		num = maxValue -- 2466
	end -- 2466
	return num -- 2467
end -- 2467
function parseReadLineParam(value, fallback, paramName) -- 2470
	local num = __TS__Number(value) -- 2475
	if not __TS__NumberIsFinite(num) then -- 2475
		num = fallback -- 2476
	end -- 2476
	num = math.floor(num) -- 2477
	if num == 0 then -- 2477
		return {success = false, message = paramName .. " cannot be 0"} -- 2479
	end -- 2479
	return {success = true, value = num} -- 2481
end -- 2481
function validateDecision(tool, params) -- 2484
	if tool == "finish" then -- 2484
		local message = getFinishMessage(params) -- 2489
		if message == "" then -- 2489
			return {success = false, message = "finish requires params.message"} -- 2490
		end -- 2490
		params.message = message -- 2491
		local completion = getCompletionReport(params) -- 2492
		params.outcome = completion.outcome -- 2493
		params.validation = completion.validation -- 2494
		params.knownIssues = completion.knownIssues -- 2495
		params.assumptions = completion.assumptions -- 2496
		params.learningCandidates = completion.learningCandidates -- 2497
		return {success = true, params = params} -- 2498
	end -- 2498
	if tool == "ask_user" then -- 2498
		local normalized = normalizeQuestionnaire(params) -- 2502
		if not normalized.success then -- 2502
			return normalized -- 2503
		end -- 2503
		return {success = true, params = normalized.schema} -- 2504
	end -- 2504
	if tool == "read_file" then -- 2504
		local path = getDecisionPath(params) -- 2508
		if path == "" then -- 2508
			return {success = false, message = "read_file requires path"} -- 2509
		end -- 2509
		params.path = path -- 2510
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2511
		if not startLineRes.success then -- 2511
			return startLineRes -- 2512
		end -- 2512
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2513
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2514
		if not endLineRes.success then -- 2514
			return endLineRes -- 2515
		end -- 2515
		params.startLine = startLineRes.value -- 2516
		params.endLine = endLineRes.value -- 2517
		return {success = true, params = params} -- 2518
	end -- 2518
	if tool == "edit_file" then -- 2518
		local path = getDecisionPath(params) -- 2522
		if path == "" then -- 2522
			return {success = false, message = "edit_file requires path"} -- 2523
		end -- 2523
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2524
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2525
		params.path = path -- 2526
		params.old_str = oldStr -- 2527
		params.new_str = newStr -- 2528
		return {success = true, params = params} -- 2529
	end -- 2529
	if tool == "delete_file" then -- 2529
		local targetFile = getDecisionPath(params) -- 2533
		if targetFile == "" then -- 2533
			return {success = false, message = "delete_file requires target_file"} -- 2534
		end -- 2534
		params.target_file = targetFile -- 2535
		return {success = true, params = params} -- 2536
	end -- 2536
	if tool == "grep_files" then -- 2536
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2540
		if pattern == "" then -- 2540
			return {success = false, message = "grep_files requires pattern"} -- 2541
		end -- 2541
		params.pattern = pattern -- 2542
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2543
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2544
		return {success = true, params = params} -- 2545
	end -- 2545
	if tool == "search_dora_doc" then -- 2545
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2549
		if pattern == "" then -- 2549
			return {success = false, message = "search_dora_doc requires pattern"} -- 2550
		end -- 2550
		local docType = type(params.docType) == "string" and params.docType or "dora-api" -- 2551
		if docType ~= "dora-api" and docType ~= "dora-tutorial" and docType ~= "love-api" and docType ~= "tic80-api" then -- 2551
			return {success = false, message = "search_dora_doc requires docType: dora-tutorial, dora-api, love-api, or tic80-api"} -- 2553
		end -- 2553
		params.pattern = pattern -- 2555
		params.docType = docType -- 2556
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax) -- 2557
		return {success = true, params = params} -- 2558
	end -- 2558
	if tool == "glob_files" then -- 2558
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2562
		return {success = true, params = params} -- 2563
	end -- 2563
	if tool == "build" then -- 2563
		local path = getDecisionPath(params) -- 2567
		if path ~= "" then -- 2567
			params.path = path -- 2569
		end -- 2569
		return {success = true, params = params} -- 2571
	end -- 2571
	if tool == "list_sub_agents" then -- 2571
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2575
		if status ~= "" then -- 2575
			params.status = status -- 2577
		end -- 2577
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2579
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2580
		if type(params.query) == "string" then -- 2580
			params.query = __TS__StringTrim(params.query) -- 2582
		end -- 2582
		return {success = true, params = params} -- 2584
	end -- 2584
	if tool == "spawn_sub_agent" then -- 2584
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2588
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2589
		if prompt == "" then -- 2589
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2590
		end -- 2590
		if title == "" then -- 2590
			return {success = false, message = "spawn_sub_agent requires title"} -- 2591
		end -- 2591
		params.prompt = prompt -- 2592
		params.title = title -- 2593
		if type(params.expectedOutput) == "string" then -- 2593
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2595
		end -- 2595
		if isArray(params.filesHint) then -- 2595
			params.filesHint = __TS__ArrayMap( -- 2598
				__TS__ArrayFilter( -- 2598
					params.filesHint, -- 2598
					function(____, item) return type(item) == "string" end -- 2599
				), -- 2599
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2600
			) -- 2600
		end -- 2600
		return {success = true, params = params} -- 2602
	end -- 2602
	return {success = true, params = params} -- 2605
end -- 2605
function validateCompletionForRole(role, tool, params) -- 2608
	if role ~= "sub" or tool ~= "finish" then -- 2608
		return {success = true} -- 2613
	end -- 2613
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2613
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2615
	end -- 2615
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2617
	do -- 2617
		local i = 0 -- 2618
		while i < #requiredArrays do -- 2618
			local name = requiredArrays[i + 1] -- 2619
			if not isArray(params[name]) then -- 2619
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2621
			end -- 2621
			i = i + 1 -- 2618
		end -- 2618
	end -- 2618
	return {success = true} -- 2624
end -- 2624
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2627
	if includeToolDefinitions == nil then -- 2627
		includeToolDefinitions = false -- 2627
	end -- 2627
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2628
	local sections = { -- 2631
		shared.promptPack.agentIdentityPrompt, -- 2632
		rolePrompt, -- 2633
		getReplyLanguageDirective(shared) -- 2634
	} -- 2634
	if shared.role == "main" then -- 2634
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2637
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2638
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2638
			sections[#sections + 1] = table.concat( -- 2640
				{ -- 2640
					"# Current Living Development Plan", -- 2641
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2642
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2642
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2643
						12000 -- 2643
					), -- 2643
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2643
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2644
						12000 -- 2644
					) -- 2644
				}, -- 2644
				"\n\n" -- 2645
			) -- 2645
		end -- 2645
	end -- 2645
	if shared.decisionMode == "tool_calling" then -- 2645
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2649
	end -- 2649
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2651
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2652
	if memoryContext ~= "" then -- 2652
		sections[#sections + 1] = memoryContext -- 2654
	end -- 2654
	local skillsSection = buildSkillsSection(shared) -- 2656
	if skillsSection ~= "" then -- 2656
		sections[#sections + 1] = skillsSection -- 2658
	end -- 2658
	if includeToolDefinitions then -- 2658
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2661
		if shared.decisionMode == "xml" then -- 2661
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2663
		end -- 2663
	end -- 2663
	return table.concat(sections, "\n\n") -- 2666
end -- 2666
function buildSkillsSection(shared) -- 2669
	local ____opt_69 = shared.skills -- 2669
	if not (____opt_69 and ____opt_69.loader) then -- 2669
		return "" -- 2671
	end -- 2671
	return shared.skills.loader:buildSkillsPromptSection() -- 2673
end -- 2673
function sanitizeMessagesForLLMInput(messages) -- 2676
	local sanitized = {} -- 2677
	local droppedAssistantToolCalls = 0 -- 2678
	local droppedToolResults = 0 -- 2679
	do -- 2679
		local i = 0 -- 2680
		while i < #messages do -- 2680
			do -- 2680
				local message = messages[i + 1] -- 2681
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2681
					local requiredIds = {} -- 2683
					do -- 2683
						local j = 0 -- 2684
						while j < #message.tool_calls do -- 2684
							local toolCall = message.tool_calls[j + 1] -- 2685
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2686
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2686
								requiredIds[#requiredIds + 1] = id -- 2688
							end -- 2688
							j = j + 1 -- 2684
						end -- 2684
					end -- 2684
					if #requiredIds == 0 then -- 2684
						sanitized[#sanitized + 1] = message -- 2692
						goto __continue457 -- 2693
					end -- 2693
					local matchedIds = {} -- 2695
					local matchedTools = {} -- 2696
					local j = i + 1 -- 2697
					while j < #messages do -- 2697
						local toolMessage = messages[j + 1] -- 2699
						if toolMessage.role ~= "tool" then -- 2699
							break -- 2700
						end -- 2700
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2701
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2701
							matchedIds[toolCallId] = true -- 2703
							matchedTools[#matchedTools + 1] = toolMessage -- 2704
						else -- 2704
							droppedToolResults = droppedToolResults + 1 -- 2706
						end -- 2706
						j = j + 1 -- 2708
					end -- 2708
					local complete = true -- 2710
					do -- 2710
						local j = 0 -- 2711
						while j < #requiredIds do -- 2711
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2711
								complete = false -- 2713
								break -- 2714
							end -- 2714
							j = j + 1 -- 2711
						end -- 2711
					end -- 2711
					if complete then -- 2711
						__TS__ArrayPush( -- 2718
							sanitized, -- 2718
							message, -- 2718
							table.unpack(matchedTools) -- 2718
						) -- 2718
					else -- 2718
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2720
						droppedToolResults = droppedToolResults + #matchedTools -- 2721
					end -- 2721
					i = j - 1 -- 2723
					goto __continue457 -- 2724
				end -- 2724
				if message.role == "tool" then -- 2724
					droppedToolResults = droppedToolResults + 1 -- 2727
					goto __continue457 -- 2728
				end -- 2728
				sanitized[#sanitized + 1] = message -- 2730
			end -- 2730
			::__continue457:: -- 2730
			i = i + 1 -- 2680
		end -- 2680
	end -- 2680
	return sanitized -- 2732
end -- 2732
function getUnconsolidatedMessages(shared) -- 2735
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2736
end -- 2736
function isFinalDecisionTurn(shared) -- 2741
	return isFinalAgentDecisionTurn(shared.agentStepCount, shared.maxSteps) -- 2742
end -- 2742
function getFinalDecisionTurnPrompt(shared) -- 2745
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2746
end -- 2746
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2751
	if attempt == nil then -- 2751
		attempt = 1 -- 2754
	end -- 2754
	if decisionMode == nil then -- 2754
		decisionMode = shared.decisionMode -- 2756
	end -- 2756
	if consumeResumeCheckpoint == nil then -- 2756
		consumeResumeCheckpoint = true -- 2757
	end -- 2757
	if pendingUserPrompt == nil then -- 2757
		pendingUserPrompt = "" -- 2758
	end -- 2758
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2760
	local tailSections = {} -- 2761
	if shared.resumeCheckpointPending == true then -- 2761
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2767
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2771
	end -- 2771
	if shared.pendingTruncationRecovery == true then -- 2771
		tailSections[#tailSections + 1] = "The previous assistant response reached the output limit before producing a complete tool call. Its incomplete tool call was discarded. Continue now with exactly one complete tool call using bounded arguments and minimal reasoning. Do not repeat the truncated payload." -- 2774
	end -- 2774
	if consumeResumeCheckpoint then -- 2774
		shared.resumeCheckpointPending = false -- 2777
		shared.pendingTruncationRecovery = false -- 2778
	end -- 2778
	local messages = { -- 2780
		{role = "system", content = systemPrompt}, -- 2781
		table.unpack(getUnconsolidatedMessages(shared)) -- 2782
	} -- 2782
	if pendingUserPrompt ~= "" then -- 2782
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2785
	end -- 2785
	if isFinalDecisionTurn(shared) then -- 2785
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2788
	end -- 2788
	if lastError and lastError ~= "" then -- 2788
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2791
		if decisionMode == "xml" then -- 2791
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2795
		end -- 2795
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2795
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2798
		end -- 2798
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2798
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2801
		end -- 2801
		messages[#messages + 1] = { -- 2803
			role = "user", -- 2804
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2805
		} -- 2805
	end -- 2805
	if #tailSections > 0 then -- 2805
		messages[#messages + 1] = { -- 2813
			role = "user", -- 2814
			content = table.concat(tailSections, "\n\n") -- 2815
		} -- 2815
	end -- 2815
	return messages -- 2818
end -- 2818
function buildXmlDecisionInstruction(shared, feedback) -- 2821
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2822
end -- 2822
function tryParseAndValidateDecision(rawText, shared) -- 2890
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2891
	if not parsed.success then -- 2891
		return {success = false, message = parsed.message, raw = rawText} -- 2893
	end -- 2893
	local decision = parseDecisionObject(parsed.obj) -- 2895
	if not decision.success then -- 2895
		return {success = false, message = decision.message, raw = rawText} -- 2897
	end -- 2897
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2899
	if not completionValidation.success then -- 2899
		return {success = false, message = completionValidation.message, raw = rawText} -- 2901
	end -- 2901
	local validation = validateDecision(decision.tool, decision.params) -- 2903
	if not validation.success then -- 2903
		return {success = false, message = validation.message, raw = rawText} -- 2905
	end -- 2905
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2907
	if not sharedValidation.success then -- 2907
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2909
	end -- 2909
	decision.params = validation.params -- 2911
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2912
	return decision -- 2913
end -- 2913
function executeToolAction(shared, action) -- 4085
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4085
		if shared.stopToken.stopped then -- 4085
			return ____awaiter_resolve( -- 4085
				nil, -- 4085
				{ -- 4087
					success = false, -- 4087
					message = getCancelledReason(shared) -- 4087
				} -- 4087
			) -- 4087
		end -- 4087
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4087
			shared.resumeRequiredTool = nil -- 4090
			shared.resumeCheckpointPending = false -- 4091
		end -- 4091
		local params = action.params -- 4093
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4094
		if not sharedValidation.success then -- 4094
			return ____awaiter_resolve(nil, sharedValidation) -- 4094
		end -- 4094
		if action.tool == "read_file" then -- 4094
			local ____params_startLine_134 = params.startLine -- 4097
			if ____params_startLine_134 == nil then -- 4097
				____params_startLine_134 = 1 -- 4097
			end -- 4097
			local startLine = __TS__Number(____params_startLine_134) -- 4097
			local ____params_endLine_135 = params.endLine -- 4098
			if ____params_endLine_135 == nil then -- 4098
				____params_endLine_135 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4098
			end -- 4098
			local endLine = __TS__Number(____params_endLine_135) -- 4098
			local clippedAfterCompression = false -- 4099
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4099
				endLine = startLine + 159 -- 4106
				clippedAfterCompression = true -- 4107
			end -- 4107
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4109
			if __TS__StringTrim(path) == "" then -- 4109
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4109
			end -- 4109
			local result = Tools.readFile( -- 4113
				shared.workingDir, -- 4114
				path, -- 4115
				startLine, -- 4116
				endLine, -- 4117
				shared.useChineseResponse and "zh" or "en" -- 4118
			) -- 4118
			if clippedAfterCompression and result.success == true then -- 4118
				result.clipped = true -- 4121
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4122
			end -- 4122
			return ____awaiter_resolve(nil, result) -- 4122
		end -- 4122
		if action.tool == "grep_files" then -- 4122
			local searchPath = params.path or "" -- 4129
			local searchGlobs = params.globs -- 4130
			local ____Tools_searchFiles_149 = Tools.searchFiles -- 4131
			local ____shared_workingDir_142 = shared.workingDir -- 4132
			local ____temp_143 = params.pattern or "" -- 4134
			local ____params_globs_144 = params.globs -- 4135
			local ____params_useRegex_145 = params.useRegex -- 4136
			local ____params_caseSensitive_146 = params.caseSensitive -- 4137
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_147 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4139
			local ____math_max_138 = math.max -- 4140
			local ____math_floor_137 = math.floor -- 4140
			local ____params_limit_136 = params.limit -- 4140
			if ____params_limit_136 == nil then -- 4140
				____params_limit_136 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4140
			end -- 4140
			local ____math_max_138_result_148 = ____math_max_138( -- 4140
				1, -- 4140
				____math_floor_137(__TS__Number(____params_limit_136)) -- 4140
			) -- 4140
			local ____math_max_141 = math.max -- 4141
			local ____math_floor_140 = math.floor -- 4141
			local ____params_offset_139 = params.offset -- 4141
			if ____params_offset_139 == nil then -- 4141
				____params_offset_139 = 0 -- 4141
			end -- 4141
			local result = __TS__Await(____Tools_searchFiles_149({ -- 4131
				workDir = ____shared_workingDir_142, -- 4132
				path = searchPath, -- 4133
				pattern = ____temp_143, -- 4134
				globs = ____params_globs_144, -- 4135
				useRegex = ____params_useRegex_145, -- 4136
				caseSensitive = ____params_caseSensitive_146, -- 4137
				includeContent = true, -- 4138
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_147, -- 4139
				limit = ____math_max_138_result_148, -- 4140
				offset = ____math_max_141( -- 4141
					0, -- 4141
					____math_floor_140(__TS__Number(____params_offset_139)) -- 4141
				), -- 4141
				groupByFile = params.groupByFile == true -- 4142
			})) -- 4142
			return ____awaiter_resolve(nil, result) -- 4142
		end -- 4142
		if action.tool == "search_dora_doc" then -- 4142
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4147
			local ____Tools_searchDoraDoc_158 = Tools.searchDoraDoc -- 4148
			local ____temp_154 = params.pattern or "" -- 4149
			local ____temp_155 = params.docType or "dora-api" -- 4150
			local ____temp_156 = shared.useChineseResponse and "zh" or "en" -- 4151
			local ____temp_157 = params.programmingLanguage or "ts" -- 4152
			local ____math_min_153 = math.min -- 4153
			local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_152 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 4153
			local ____math_max_151 = math.max -- 4153
			local ____params_limit_150 = params.limit -- 4153
			if ____params_limit_150 == nil then -- 4153
				____params_limit_150 = 8 -- 4153
			end -- 4153
			local result = __TS__Await(____Tools_searchDoraDoc_158({ -- 4148
				pattern = ____temp_154, -- 4149
				docType = ____temp_155, -- 4150
				docLanguage = ____temp_156, -- 4151
				programmingLanguage = ____temp_157, -- 4152
				limit = ____math_min_153( -- 4153
					____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_152, -- 4153
					____math_max_151( -- 4153
						1, -- 4153
						__TS__Number(____params_limit_150) -- 4153
					) -- 4153
				), -- 4153
				useRegex = params.useRegex, -- 4154
				caseSensitive = false, -- 4155
				includeContent = true, -- 4156
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4157
			})) -- 4157
			return ____awaiter_resolve(nil, result) -- 4157
		end -- 4157
		if action.tool == "glob_files" then -- 4157
			local ____Tools_listFiles_165 = Tools.listFiles -- 4162
			local ____shared_workingDir_162 = shared.workingDir -- 4163
			local ____temp_163 = params.path or "" -- 4164
			local ____params_globs_164 = params.globs -- 4165
			local ____math_max_161 = math.max -- 4166
			local ____math_floor_160 = math.floor -- 4166
			local ____params_maxEntries_159 = params.maxEntries -- 4166
			if ____params_maxEntries_159 == nil then -- 4166
				____params_maxEntries_159 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4166
			end -- 4166
			local result = ____Tools_listFiles_165({ -- 4162
				workDir = ____shared_workingDir_162, -- 4163
				path = ____temp_163, -- 4164
				globs = ____params_globs_164, -- 4165
				maxEntries = ____math_max_161( -- 4166
					1, -- 4166
					____math_floor_160(__TS__Number(____params_maxEntries_159)) -- 4166
				) -- 4166
			}) -- 4166
			return ____awaiter_resolve(nil, result) -- 4166
		end -- 4166
		if action.tool == "ask_user" then -- 4166
			if not shared.publishQuestionnaire then -- 4166
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4166
			end -- 4166
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4166
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4166
			end -- 4166
			local normalized = normalizeQuestionnaire(params) -- 4173
			if not normalized.success then -- 4173
				return ____awaiter_resolve(nil, normalized) -- 4173
			end -- 4173
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4175
			if not result.success then -- 4175
				return ____awaiter_resolve(nil, result) -- 4175
			end -- 4175
			shared.waitingQuestionnaireId = result.questionnaireId -- 4182
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4182
		end -- 4182
		if action.tool == "delete_file" then -- 4182
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4186
			if __TS__StringTrim(targetFile) == "" then -- 4186
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4186
			end -- 4186
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4190
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4191
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4191
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4191
			end -- 4191
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4195
			local result = Tools.deleteFile(shared.taskId, shared.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4196
			if not result.success then -- 4196
				return ____awaiter_resolve(nil, result) -- 4196
			end -- 4196
			if not isInternalDocumentEdit then -- 4196
				shared.unbuiltEdits = true -- 4204
				shared.lastBuildSucceeded = false -- 4205
				if shared.failedTestNeedsBuild == true then -- 4205
					shared.failedTestHasSourceEdit = true -- 4206
				end -- 4206
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4206
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4207
				end -- 4207
				shared.editedPathsSinceBuild = editedPaths -- 4208
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4209
			end -- 4209
			local ____result_checkpointed_167 = result.checkpointed -- 4215
			local ____result_reversible_168 = result.reversible -- 4216
			local ____result_binary_169 = result.binary -- 4217
			local ____temp_170 = result.checkpointed and result.checkpointId or nil -- 4218
			local ____temp_171 = result.checkpointed and result.checkpointSeq or nil -- 4219
			local ____result_checkpointed_166 -- 4220
			if result.checkpointed then -- 4220
				____result_checkpointed_166 = nil -- 4220
			else -- 4220
				____result_checkpointed_166 = result.message -- 4220
			end -- 4220
			return ____awaiter_resolve(nil, { -- 4220
				success = true, -- 4212
				changed = true, -- 4213
				mode = "delete", -- 4214
				checkpointed = ____result_checkpointed_167, -- 4215
				reversible = ____result_reversible_168, -- 4216
				binary = ____result_binary_169, -- 4217
				checkpointId = ____temp_170, -- 4218
				checkpointSeq = ____temp_171, -- 4219
				message = ____result_checkpointed_166, -- 4220
				files = {{path = targetFile, op = "delete"}} -- 4221
			}) -- 4221
		end -- 4221
		if action.tool == "build" then -- 4221
			local buildPath = params.path or "" -- 4225
			local result = __TS__Await(Tools.build({ -- 4226
				workDir = shared.workingDir, -- 4227
				path = buildPath, -- 4228
				isCancelled = function() return shared.stopToken.stopped end -- 4229
			})) -- 4229
			shared.unbuiltEdits = false -- 4231
			shared.editsSinceBuild = 0 -- 4232
			shared.editedPathsSinceBuild = {} -- 4233
			shared.hasBuilt = true -- 4234
			shared.lastBuildSucceeded = result.success -- 4235
			if result.success and shared.freshProjectBuildPending == true then -- 4235
				shared.freshProjectBuildPending = false -- 4241
			end -- 4241
			shared.apiSearchesSinceBuild = 0 -- 4243
			shared.buildRepairPending = false -- 4244
			if not result.success and result.messages ~= nil then -- 4244
				do -- 4244
					local i = 0 -- 4246
					while i < #result.messages do -- 4246
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4246
							shared.buildRepairPending = true -- 4248
							break -- 4249
						end -- 4249
						i = i + 1 -- 4246
					end -- 4246
				end -- 4246
			end -- 4246
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4246
				shared.failedTestNeedsBuild = false -- 4254
				shared.failedTestHasSourceEdit = false -- 4255
			end -- 4255
			return ____awaiter_resolve(nil, result) -- 4255
		end -- 4255
		if action.tool == "fetch_url" then -- 4255
			local result = __TS__Await(Tools.fetchUrl({ -- 4260
				workDir = shared.workingDir, -- 4261
				url = type(params.url) == "string" and params.url or "", -- 4262
				target = type(params.target) == "string" and params.target or "", -- 4263
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4264
				onProgress = function(____, progress) -- 4265
					emitAgentEvent( -- 4266
						shared, -- 4266
						{ -- 4266
							type = "tool_progress", -- 4267
							sessionId = shared.sessionId, -- 4268
							taskId = shared.taskId, -- 4269
							step = action.step, -- 4270
							tool = action.tool, -- 4271
							result = __TS__ObjectAssign({success = false}, progress) -- 4272
						} -- 4272
					) -- 4272
				end -- 4265
			})) -- 4265
			return ____awaiter_resolve(nil, result) -- 4265
		end -- 4265
		if action.tool == "execute_command" then -- 4265
			local mode = type(params.mode) == "string" and params.mode or "" -- 4282
			local result = __TS__Await(Tools.executeCommand({ -- 4283
				workDir = shared.workingDir, -- 4284
				mode = mode, -- 4285
				code = type(params.code) == "string" and params.code or nil, -- 4286
				command = type(params.command) == "string" and params.command or nil, -- 4287
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4288
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4289
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4290
				onProgress = function(____, progress) -- 4291
					emitAgentEvent( -- 4292
						shared, -- 4292
						{ -- 4292
							type = "tool_progress", -- 4293
							sessionId = shared.sessionId, -- 4294
							taskId = shared.taskId, -- 4295
							step = action.step, -- 4296
							tool = action.tool, -- 4297
							result = __TS__ObjectAssign({success = false}, progress) -- 4298
						} -- 4298
					) -- 4298
				end -- 4291
			})) -- 4291
			if result.success and mode == "lua" then -- 4291
				local deterministicFailure = false -- 4306
				local deterministicPass = false -- 4307
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4308
				do -- 4308
					local i = 0 -- 4309
					while i < #outputLines and not deterministicFailure do -- 4309
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4310
						if line == "passed" then -- 4310
							deterministicPass = true -- 4311
						end -- 4311
						if line == "failed" then -- 4311
							deterministicFailure = true -- 4313
							break -- 4314
						end -- 4314
						local searchFrom = 0 -- 4316
						while searchFrom < #line do -- 4316
							local failedIndex = (string.find( -- 4318
								line, -- 4318
								"failed", -- 4318
								math.max(searchFrom + 1, 1), -- 4318
								true -- 4318
							) or 0) - 1 -- 4318
							if failedIndex < 0 then -- 4318
								break -- 4319
							end -- 4319
							local after = failedIndex + #"failed" -- 4320
							while after < #line do -- 4320
								local ch = __TS__StringSlice(line, after, after + 1) -- 4322
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4322
									break -- 4323
								end -- 4323
								after = after + 1 -- 4324
							end -- 4324
							local afterEnd = after -- 4326
							while afterEnd < #line do -- 4326
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4328
								if ch < "0" or ch > "9" then -- 4328
									break -- 4329
								end -- 4329
								afterEnd = afterEnd + 1 -- 4330
							end -- 4330
							local count -- 4332
							if afterEnd > after then -- 4332
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4334
							else -- 4334
								local before = failedIndex - 1 -- 4336
								while before >= 0 do -- 4336
									local ch = __TS__StringSlice(line, before, before + 1) -- 4338
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4338
										break -- 4339
									end -- 4339
									before = before - 1 -- 4340
								end -- 4340
								local beforeEnd = before + 1 -- 4342
								while before >= 0 do -- 4342
									local ch = __TS__StringSlice(line, before, before + 1) -- 4344
									if ch < "0" or ch > "9" then -- 4344
										break -- 4345
									end -- 4345
									before = before - 1 -- 4346
								end -- 4346
								if beforeEnd > before + 1 then -- 4346
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4348
								end -- 4348
							end -- 4348
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4348
								deterministicFailure = true -- 4351
								break -- 4352
							end -- 4352
							searchFrom = failedIndex + #"failed" -- 4354
						end -- 4354
						i = i + 1 -- 4309
					end -- 4309
				end -- 4309
				if deterministicFailure then -- 4309
					shared.failedTestNeedsBuild = true -- 4358
					shared.failedTestHasSourceEdit = false -- 4359
				elseif deterministicPass then -- 4359
					shared.failedTestNeedsBuild = false -- 4361
					shared.failedTestHasSourceEdit = false -- 4362
				end -- 4362
			end -- 4362
			return ____awaiter_resolve(nil, result) -- 4362
		end -- 4362
		if action.tool == "spawn_sub_agent" then -- 4362
			if not shared.spawnSubAgent then -- 4362
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4362
			end -- 4362
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4362
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4362
			end -- 4362
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4374
				params.filesHint, -- 4375
				function(____, item) return type(item) == "string" end -- 4375
			) or nil -- 4375
			local result = __TS__Await(shared.spawnSubAgent({ -- 4377
				parentSessionId = shared.sessionId, -- 4378
				projectRoot = shared.workingDir, -- 4379
				title = type(params.title) == "string" and params.title or "Sub", -- 4380
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4381
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4382
				filesHint = filesHint, -- 4383
				disabledAgentTools = shared.disabledAgentTools -- 4384
			})) -- 4384
			if not result.success then -- 4384
				return ____awaiter_resolve(nil, result) -- 4384
			end -- 4384
			shared.hasSpawnedSubAgentThisTask = true -- 4389
			return ____awaiter_resolve(nil, { -- 4389
				success = true, -- 4391
				sessionId = result.sessionId, -- 4392
				taskId = result.taskId, -- 4393
				title = result.title, -- 4394
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4395
			}) -- 4395
		end -- 4395
		if action.tool == "list_sub_agents" then -- 4395
			if not shared.listSubAgents then -- 4395
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4395
			end -- 4395
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4395
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4395
			end -- 4395
			local result = __TS__Await(shared.listSubAgents({ -- 4405
				sessionId = shared.sessionId, -- 4406
				projectRoot = shared.workingDir, -- 4407
				status = type(params.status) == "string" and params.status or nil, -- 4408
				limit = type(params.limit) == "number" and params.limit or nil, -- 4409
				offset = type(params.offset) == "number" and params.offset or nil, -- 4410
				query = type(params.query) == "string" and params.query or nil -- 4411
			})) -- 4411
			return ____awaiter_resolve(nil, result) -- 4411
		end -- 4411
		if action.tool == "edit_file" then -- 4411
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4416
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4419
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4420
			if __TS__StringTrim(path) == "" then -- 4420
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4420
			end -- 4420
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4422
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4423
			if not isInternalDocumentEdit then -- 4423
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4425
				if preflightIssue ~= nil then -- 4425
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4427
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4428
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4428
				end -- 4428
			end -- 4428
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4434
			local result = __TS__Await(actionNode:exec({ -- 4435
				path = path, -- 4436
				oldStr = oldStr, -- 4437
				newStr = newStr, -- 4438
				taskId = shared.taskId, -- 4439
				workDir = shared.workingDir -- 4440
			})) -- 4440
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4440
				shared.unbuiltEdits = true -- 4443
				shared.lastBuildSucceeded = false -- 4444
				if shared.failedTestNeedsBuild == true then -- 4444
					shared.failedTestHasSourceEdit = true -- 4445
				end -- 4445
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4446
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4446
					editedPaths[#editedPaths + 1] = normalizedPath -- 4447
				end -- 4447
				shared.editedPathsSinceBuild = editedPaths -- 4448
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4449
			end -- 4449
			return ____awaiter_resolve(nil, result) -- 4449
		end -- 4449
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4449
	end) -- 4449
end -- 4449
function sanitizeToolActionResultForHistory(action, result) -- 4456
	if action.tool == "read_file" then -- 4456
		return sanitizeReadResultForHistory(action.tool, result) -- 4458
	end -- 4458
	if action.tool == "grep_files" or action.tool == "search_dora_doc" then -- 4458
		return sanitizeSearchResultForHistory(action.tool, result) -- 4461
	end -- 4461
	if action.tool == "glob_files" then -- 4461
		return sanitizeListFilesResultForHistory(result) -- 4464
	end -- 4464
	if action.tool == "build" then -- 4464
		return sanitizeBuildResultForHistory(result) -- 4467
	end -- 4467
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4467
		if result.success ~= true then -- 4467
			return result -- 4470
		end -- 4470
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4470
			return result -- 4471
		end -- 4471
		if isArray(result.fileContext) then -- 4471
			return result -- 4472
		end -- 4472
		local contextLimits = { -- 4474
			fullContentChars = 12000, -- 4475
			previewChars = 4000, -- 4476
			diffChars = 8000, -- 4477
			totalChars = 24000, -- 4478
			maxFiles = 8 -- 4479
		} -- 4479
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4481
			if maxChars <= 0 then -- 4481
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4482
			end -- 4482
			if #sourceText <= maxChars then -- 4482
				return sourceText -- 4483
			end -- 4483
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4484
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4485
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4486
		end -- 4481
		local function countLines(sourceText) -- 4488
			if sourceText == "" then -- 4488
				return 0 -- 4489
			end -- 4489
			return #__TS__StringSplit(sourceText, "\n") -- 4490
		end -- 4488
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4492
			if beforeContent == afterContent then -- 4492
				return "" -- 4493
			end -- 4493
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4494
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4495
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4497
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4497
				firstChangedLine = firstChangedLine + 1 -- 4503
			end -- 4503
			local lastChangedBeforeLine = #beforeLines - 1 -- 4505
			local lastChangedAfterLine = #afterLines - 1 -- 4506
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4506
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4512
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4513
			end -- 4513
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4515
			local previewEndLine = math.max( -- 4516
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4517
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4518
			) -- 4518
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4520
			do -- 4520
				local lineIndex = previewStartLine -- 4521
				while lineIndex <= previewEndLine do -- 4521
					do -- 4521
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4522
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4523
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4524
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4525
						if not beforeChanged and not afterChanged then -- 4525
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4527
							if contextLine ~= nil then -- 4527
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4528
							end -- 4528
							goto __continue739 -- 4529
						end -- 4529
						if beforeChanged and beforeLine ~= nil then -- 4529
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4531
						end -- 4531
						if afterChanged and afterLine ~= nil then -- 4531
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4532
						end -- 4532
					end -- 4532
					::__continue739:: -- 4532
					lineIndex = lineIndex + 1 -- 4521
				end -- 4521
			end -- 4521
			return truncateContextSnippet( -- 4534
				table.concat(unifiedDiffLines, "\n"), -- 4534
				maxChars, -- 4534
				"diff" -- 4534
			) -- 4534
		end -- 4492
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4537
		if not checkpointDiff.success then -- 4537
			return result -- 4538
		end -- 4538
		local remainingContextBudget = contextLimits.totalChars -- 4539
		local fileContextItems = {} -- 4540
		local changedFiles = checkpointDiff.files -- 4541
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4542
		do -- 4542
			local fileIndex = 0 -- 4543
			while fileIndex < maxContextFiles do -- 4543
				if remainingContextBudget <= 0 then -- 4543
					break -- 4544
				end -- 4544
				local changedFile = changedFiles[fileIndex + 1] -- 4545
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4546
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4547
				local contextItem = { -- 4548
					path = changedFile.path, -- 4549
					op = changedFile.op, -- 4550
					checkpointId = result.checkpointId, -- 4551
					checkpointSeq = result.checkpointSeq, -- 4552
					beforeExists = changedFile.beforeExists, -- 4553
					afterExists = changedFile.afterExists, -- 4554
					beforeBytes = #beforeContent, -- 4555
					afterBytes = #afterContent, -- 4556
					diffPreview = "", -- 4557
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4558
					contentTruncated = false, -- 4559
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4560
				} -- 4560
				if changedFile.afterExists then -- 4560
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4560
						contextItem.afterContent = afterContent -- 4564
						remainingContextBudget = remainingContextBudget - #afterContent -- 4565
					else -- 4565
						contextItem.afterContentPreview = truncateContextSnippet( -- 4567
							afterContent, -- 4568
							math.min( -- 4569
								contextLimits.previewChars, -- 4569
								math.max(400, remainingContextBudget) -- 4569
							), -- 4569
							"afterContent" -- 4570
						) -- 4570
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4572
						contextItem.contentTruncated = true -- 4573
					end -- 4573
				end -- 4573
				local diffPreview = buildUnifiedDiffPreview( -- 4576
					changedFile.path, -- 4577
					beforeContent, -- 4578
					afterContent, -- 4579
					math.min( -- 4580
						contextLimits.diffChars, -- 4580
						math.max(400, remainingContextBudget) -- 4580
					) -- 4580
				) -- 4580
				contextItem.diffPreview = diffPreview -- 4582
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4583
				if not changedFile.afterExists and beforeContent ~= "" then -- 4583
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4585
						beforeContent, -- 4586
						math.min( -- 4587
							contextLimits.previewChars, -- 4587
							math.max(400, remainingContextBudget) -- 4587
						), -- 4587
						"beforeContent" -- 4588
					) -- 4588
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4590
					if #beforeContent > contextLimits.previewChars then -- 4590
						contextItem.contentTruncated = true -- 4591
					end -- 4591
				end -- 4591
				fileContextItems[#fileContextItems + 1] = contextItem -- 4593
				fileIndex = fileIndex + 1 -- 4543
			end -- 4543
		end -- 4543
		if #fileContextItems == 0 then -- 4543
			return result -- 4595
		end -- 4595
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4596
	end -- 4596
	return result -- 4603
end -- 4603
function emitAgentTaskFinishEvent(shared, success, message) -- 4805
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4806
	local result = success and ({ -- 4810
		success = true, -- 4812
		taskId = shared.taskId, -- 4813
		message = message, -- 4814
		steps = shared.step, -- 4815
		completion = completion -- 4816
	}) or ({ -- 4816
		success = false, -- 4819
		taskId = shared.taskId, -- 4820
		message = message, -- 4821
		steps = shared.step, -- 4822
		completion = completion -- 4823
	}) -- 4823
	emitAgentEvent(shared, { -- 4825
		type = "task_finished", -- 4826
		sessionId = shared.sessionId, -- 4827
		taskId = shared.taskId, -- 4828
		success = result.success, -- 4829
		message = result.message, -- 4830
		steps = result.steps, -- 4831
		completion = result.completion -- 4832
	}) -- 4832
	return result -- 4834
end -- 4834
local function buildLLMOptions(llmConfig, overrides) -- 311
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 312
	if llmConfig.reasoningEffort then -- 312
		options.reasoning_effort = llmConfig.reasoningEffort -- 317
	end -- 317
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 319
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 319
		__TS__Delete(merged, "reasoning_effort") -- 324
	else -- 324
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 326
	end -- 326
	__TS__Delete(merged, "tool_choice") -- 331
	return merged -- 332
end -- 311
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 463
	local fitted = AgentUtils.fitMessagesToContext(messages, options, shared.llmConfig) -- 470
	local messagesTokens = fitted.originalTokens -- 471
	local toolDefinitionsTokens = 0 -- 473
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 473
		local toolsText = AgentUtils.safeJsonEncode(options.tools) -- 475
		toolDefinitionsTokens = toolsText and AgentUtils.estimateTextTokens(toolsText) or 0 -- 476
	end -- 476
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 479
	__TS__Delete(optionsWithoutTools, "tools") -- 480
	local optionsText = AgentUtils.safeJsonEncode(optionsWithoutTools) -- 481
	local optionsTokens = optionsText and AgentUtils.estimateTextTokens(optionsText) or 0 -- 482
	local contextWindow = shared.llmConfig.contextWindow > 0 and math.floor(shared.llmConfig.contextWindow) or 64000 -- 483
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 486
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 491
		1024, -- 493
		math.floor(contextWindow * 0.2) -- 493
	) -- 493
	local structuralOverhead = math.max(256, #messages * 16) -- 494
	local usedTokens = messagesTokens + math.max(0, contextWindow - fitted.budgetTokens) -- 498
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
end -- 463
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
local function emitAssistantMessageFinished(shared, step, content, reasoningContent) -- 595
	emitAgentEvent(shared, { -- 601
		type = "assistant_message_finished", -- 602
		sessionId = shared.sessionId, -- 603
		taskId = shared.taskId, -- 604
		step = step, -- 605
		content = content, -- 606
		reasoningContent = reasoningContent, -- 607
		result = {success = false, recoverable = true, reason = "max_output_tokens"} -- 608
	}) -- 608
end -- 595
local function getMemoryCompressionStartReason(shared) -- 616
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 617
end -- 616
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 622
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 623
end -- 622
local function getMemoryCompressionFailureReason(shared, ____error) -- 628
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 629
end -- 628
local function summarizeHistoryEntryPreview(text, maxChars) -- 634
	if maxChars == nil then -- 634
		maxChars = 180 -- 634
	end -- 634
	local trimmed = __TS__StringTrim(text) -- 635
	if trimmed == "" then -- 635
		return "" -- 636
	end -- 636
	return truncateText(trimmed, maxChars) -- 637
end -- 634
local function getMaxStepsReachedReason(shared) -- 645
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 646
end -- 645
local function getFailureSummaryFallback(shared, ____error) -- 651
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 652
end -- 651
local function finalizeAgentFailure(shared, ____error) -- 657
	if shared.stopToken.stopped then -- 657
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 659
		return emitAgentTaskFinishEvent( -- 660
			shared, -- 660
			false, -- 660
			getCancelledReason(shared) -- 660
		) -- 660
	end -- 660
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 662
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 663
end -- 657
local function getPromptCommand(prompt) -- 666
	local trimmed = __TS__StringTrim(prompt) -- 667
	if trimmed == "/compact" then -- 667
		return "compact" -- 668
	end -- 668
	if trimmed == "/clear" then -- 668
		return "clear" -- 669
	end -- 669
	return nil -- 670
end -- 666
function ____exports.truncateAgentUserPrompt(prompt) -- 673
	if not prompt then -- 673
		return "" -- 674
	end -- 674
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 674
		return prompt -- 675
	end -- 675
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 676
	if offset == nil then -- 676
		return prompt -- 677
	end -- 677
	return string.sub(prompt, 1, offset - 1) -- 678
end -- 673
local function canWriteStepLLMDebug(shared, stepId) -- 681
	if stepId == nil then -- 681
		stepId = shared.step + 1 -- 681
	end -- 681
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 682
end -- 681
local function ensureDirRecursive(dir) -- 689
	if not dir then -- 689
		return false -- 690
	end -- 690
	if Content:exist(dir) then -- 690
		return Content:isdir(dir) -- 691
	end -- 691
	local parent = Path:getPath(dir) -- 692
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 692
		return false -- 694
	end -- 694
	return Content:mkdir(dir) -- 696
end -- 689
local function encodeDebugJSON(value) -- 699
	local text, err = AgentUtils.safeJsonEncode(value) -- 700
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 701
end -- 699
function ____exports.isAgentPlanPath(path) -- 717
	return AgentRuntimePolicy.isAgentPlanPath(path) -- 718
end -- 717
local function inspectFreshProject(workDir) -- 721
	local result = Tools.listFiles({workDir = workDir, path = "", globs = AgentConfig.AGENT_FILE_PATTERNS.freshProjectCodeGlobs, maxEntries = 2}) -- 722
	if not result.success then -- 722
		return {fresh = false} -- 728
	end -- 728
	local totalEntries = result.totalEntries or #result.files -- 729
	if totalEntries > 1 then -- 729
		return {fresh = false} -- 730
	end -- 730
	if totalEntries == 0 then -- 730
		return {fresh = true} -- 731
	end -- 731
	if #result.files ~= 1 then -- 731
		return {fresh = false} -- 732
	end -- 732
	local path = result.files[1] -- 733
	local loaded = Tools.readFileRaw(workDir, path) -- 734
	if not loaded.success or loaded.content == nil then -- 734
		return {fresh = false} -- 735
	end -- 735
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 736
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 739
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 740
end -- 721
local function getStepLLMDebugDir(shared) -- 743
	return Path( -- 744
		shared.workingDir, -- 745
		".agent", -- 746
		tostring(shared.sessionId), -- 747
		tostring(shared.taskId) -- 748
	) -- 748
end -- 743
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 752
	return Path( -- 753
		getStepLLMDebugDir(shared), -- 753
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 753
	) -- 753
end -- 752
local function getLatestStepLLMDebugSeq(shared, stepId) -- 756
	if not canWriteStepLLMDebug(shared, stepId) then -- 756
		return 0 -- 757
	end -- 757
	local dir = getStepLLMDebugDir(shared) -- 758
	if not Content:exist(dir) or not Content:isdir(dir) then -- 758
		return 0 -- 759
	end -- 759
	local latest = 0 -- 760
	for ____, file in ipairs(Content:getFiles(dir)) do -- 761
		do -- 761
			local name = Path:getFilename(file) -- 762
			local seqText = string.match( -- 763
				name, -- 763
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 763
			) -- 763
			if seqText ~= nil then -- 763
				latest = math.max( -- 765
					latest, -- 765
					tonumber(seqText) -- 765
				) -- 765
				goto __continue58 -- 766
			end -- 766
			local legacyMatch = string.match( -- 768
				name, -- 768
				("^" .. tostring(stepId)) .. "_in%.md$" -- 768
			) -- 768
			if legacyMatch ~= nil then -- 768
				latest = math.max(latest, 1) -- 770
			end -- 770
		end -- 770
		::__continue58:: -- 770
	end -- 770
	return latest -- 773
end -- 756
local function writeStepLLMDebugFile(path, content) -- 776
	if not Content:save(path, content) then -- 776
		AgentUtils.Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 778
		return false -- 779
	end -- 779
	Tools.sendWebIDEFileUpdate(path, true, content) -- 781
	return true -- 782
end -- 776
local function createStepLLMDebugPair(shared, stepId, inContent) -- 785
	if not canWriteStepLLMDebug(shared, stepId) then -- 785
		return 0 -- 786
	end -- 786
	local dir = getStepLLMDebugDir(shared) -- 787
	if not ensureDirRecursive(dir) then -- 787
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 789
		return 0 -- 790
	end -- 790
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 792
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 793
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 794
	if not writeStepLLMDebugFile(inPath, inContent) then -- 794
		return 0 -- 796
	end -- 796
	writeStepLLMDebugFile(outPath, "") -- 798
	return seq -- 799
end -- 785
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 802
	if not canWriteStepLLMDebug(shared, stepId) then -- 802
		return -- 803
	end -- 803
	local dir = getStepLLMDebugDir(shared) -- 804
	if not ensureDirRecursive(dir) then -- 804
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 806
		return -- 807
	end -- 807
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 809
	if latestSeq <= 0 then -- 809
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 811
		writeStepLLMDebugFile(outPath, content) -- 812
		return -- 813
	end -- 813
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 815
	writeStepLLMDebugFile(outPath, content) -- 816
end -- 802
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 819
	if not canWriteStepLLMDebug(shared, stepId) then -- 819
		return -- 820
	end -- 820
	local sections = { -- 821
		"# LLM Input", -- 822
		"session_id: " .. tostring(shared.sessionId), -- 823
		"task_id: " .. tostring(shared.taskId), -- 824
		"step_id: " .. tostring(stepId), -- 825
		"phase: " .. phase, -- 826
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 827
		"## Options", -- 828
		"```json", -- 829
		encodeDebugJSON(options), -- 830
		"```" -- 831
	} -- 831
	local firstMessage = #messages > 0 and messages[1] or nil -- 833
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 833
		sections[#sections + 1] = "# System Prompt" -- 835
		sections[#sections + 1] = firstMessage.content -- 836
	end -- 836
	do -- 836
		local i = 0 -- 838
		while i < #messages do -- 838
			local message = messages[i + 1] -- 839
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 840
			sections[#sections + 1] = encodeDebugJSON(message) -- 841
			i = i + 1 -- 838
		end -- 838
	end -- 838
	createStepLLMDebugPair( -- 843
		shared, -- 843
		stepId, -- 843
		table.concat(sections, "\n") -- 843
	) -- 843
end -- 819
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 846
	if not canWriteStepLLMDebug(shared, stepId) then -- 846
		return -- 847
	end -- 847
	local ____array_24 = __TS__SparseArrayNew( -- 847
		"# LLM Output", -- 849
		"session_id: " .. tostring(shared.sessionId), -- 850
		"task_id: " .. tostring(shared.taskId), -- 851
		"step_id: " .. tostring(stepId), -- 852
		"phase: " .. phase, -- 853
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 854
		table.unpack(meta and ({ -- 855
			"## Meta", -- 855
			"```json", -- 855
			encodeDebugJSON(meta), -- 855
			"```" -- 855
		}) or ({})) -- 855
	) -- 855
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 855
	local sections = {__TS__SparseArraySpread(____array_24)} -- 848
	updateLatestStepLLMDebugOutput( -- 859
		shared, -- 859
		stepId, -- 859
		table.concat(sections, "\n") -- 859
	) -- 859
end -- 846
local function summarizeEditTextParamForHistory(value, key) -- 986
	if type(value) ~= "string" then -- 986
		return nil -- 987
	end -- 987
	local text = value -- 988
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 989
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 990
end -- 986
local function sanitizeActionParamsForHistory(tool, params) -- 1125
	if tool ~= "edit_file" then -- 1125
		return params -- 1126
	end -- 1126
	local clone = {} -- 1127
	for key in pairs(params) do -- 1128
		if key == "old_str" then -- 1128
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1130
		elseif key == "new_str" then -- 1130
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1132
		else -- 1132
			clone[key] = params[key] -- 1134
		end -- 1134
	end -- 1134
	return clone -- 1137
end -- 1125
local function projectMessagesForCompression(messages) -- 1290
	local projected = projectMessagesForLLMContext(messages) -- 1291
	do -- 1291
		local i = 0 -- 1292
		while i < #projected do -- 1292
			do -- 1292
				local message = projected[i + 1] -- 1293
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1293
					goto __continue191 -- 1294
				end -- 1294
				local changed = false -- 1295
				local toolCalls = __TS__ArrayMap( -- 1296
					message.tool_calls, -- 1296
					function(____, toolCall) -- 1296
						local fn = toolCall["function"] -- 1297
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1297
							return toolCall -- 1298
						end -- 1298
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 1299
						if not isRecord(decoded) or isArray(decoded) then -- 1299
							return toolCall -- 1300
						end -- 1300
						changed = true -- 1301
						return __TS__ObjectAssign( -- 1302
							{}, -- 1302
							toolCall, -- 1303
							{["function"] = __TS__ObjectAssign( -- 1302
								{}, -- 1304
								fn, -- 1305
								{arguments = toJson( -- 1304
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1306
									false -- 1306
								)} -- 1306
							)} -- 1306
						) -- 1306
					end -- 1296
				) -- 1296
				if changed then -- 1296
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1310
				end -- 1310
			end -- 1310
			::__continue191:: -- 1310
			i = i + 1 -- 1292
		end -- 1292
	end -- 1292
	return projected -- 1312
end -- 1290
local function getDecisionToolSchemaText(shared) -- 1354
	local toolsText = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1355
		shared.role, -- 1355
		AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 1355
		{ -- 1355
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1356
			workMode = shared.workMode -- 1357
		} -- 1357
	)) -- 1357
	return toolsText or "" -- 1359
end -- 1354
local function clearPreExecutedResults(shared) -- 1369
	shared.preExecutedResults = nil -- 1370
end -- 1369
local function startPreExecutedToolAction(shared, action) -- 1373
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1373
		local ____hasReturned, ____returnValue -- 1373
		local ____try = __TS__AsyncAwaiter(function() -- 1373
			____hasReturned = true -- 1375
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1375
			return -- 1375
		end) -- 1375
		____try = ____try.catch( -- 1375
			____try, -- 1375
			function(____, err) -- 1375
				return __TS__AsyncAwaiter(function() -- 1375
					local message = tostring(err) -- 1377
					AgentUtils.Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1378
					____hasReturned = true -- 1379
					____returnValue = {success = false, message = message} -- 1379
					return -- 1379
				end) -- 1379
			end -- 1379
		) -- 1379
		__TS__Await(____try) -- 1374
		if ____hasReturned then -- 1374
			return ____awaiter_resolve(nil, ____returnValue) -- 1374
		end -- 1374
	end) -- 1374
end -- 1373
local function createPreExecutedToolResult(shared, action) -- 1383
	local cloneParamValue -- 1384
	cloneParamValue = function(value) -- 1384
		if value == nil then -- 1384
			return value -- 1385
		end -- 1385
		if isArray(value) then -- 1385
			return __TS__ArrayMap( -- 1387
				value, -- 1387
				function(____, item) return cloneParamValue(item) end -- 1387
			) -- 1387
		end -- 1387
		if type(value) == "table" then -- 1387
			local clone = {} -- 1390
			for key in pairs(value) do -- 1391
				clone[key] = cloneParamValue(value[key]) -- 1392
			end -- 1392
			return clone -- 1394
		end -- 1394
		return value -- 1396
	end -- 1384
	local params = cloneParamValue(action.params) -- 1398
	local areParamValuesEqual -- 1399
	areParamValuesEqual = function(left, right) -- 1399
		if left == right then -- 1399
			return true -- 1400
		end -- 1400
		if left == nil or right == nil then -- 1400
			return false -- 1401
		end -- 1401
		if isArray(left) or isArray(right) then -- 1401
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1401
				return false -- 1403
			end -- 1403
			do -- 1403
				local i = 0 -- 1404
				while i < #left do -- 1404
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1404
						return false -- 1405
					end -- 1405
					i = i + 1 -- 1404
				end -- 1404
			end -- 1404
			return true -- 1407
		end -- 1407
		if type(left) == "table" and type(right) == "table" then -- 1407
			local leftCount = 0 -- 1410
			for key in pairs(left) do -- 1411
				leftCount = leftCount + 1 -- 1412
				if not areParamValuesEqual(left[key], right[key]) then -- 1412
					return false -- 1417
				end -- 1417
			end -- 1417
			local rightCount = 0 -- 1420
			for key in pairs(right) do -- 1421
				rightCount = rightCount + 1 -- 1422
			end -- 1422
			return leftCount == rightCount -- 1424
		end -- 1424
		return false -- 1426
	end -- 1399
	return { -- 1428
		action = action, -- 1429
		matches = function(self, nextAction) -- 1430
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1431
		end, -- 1430
		promise = startPreExecutedToolAction(shared, action) -- 1433
	} -- 1433
end -- 1383
local function executeToolActionWithPreExecution(shared, action) -- 1437
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1437
		local wasResumeNarrowReadMode = shared.resumeNarrowReadMode == true -- 1438
		local ____opt_29 = shared.preExecutedResults -- 1438
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1439
		local result -- 1440
		if preResult then -- 1440
			local ____opt_31 = shared.preExecutedResults -- 1440
			if ____opt_31 ~= nil then -- 1440
				____opt_31:delete(action.toolCallId) -- 1442
			end -- 1442
			if preResult:matches(action) then -- 1442
				AgentUtils.Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1444
				result = __TS__Await(preResult.promise) -- 1445
			else -- 1445
				AgentUtils.Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1447
				result = __TS__Await(executeToolAction(shared, action)) -- 1448
			end -- 1448
		else -- 1448
			result = __TS__Await(executeToolAction(shared, action)) -- 1451
		end -- 1451
		local guidance = {} -- 1453
		if type(result.guidance) == "string" and __TS__StringTrim(result.guidance) ~= "" then -- 1453
			guidance[#guidance + 1] = result.guidance -- 1455
		end -- 1455
		guidance[#guidance + 1] = AgentToolRegistry.buildCurrentToolAvailabilityGuidance() -- 1457
		if shared.hasSpawnedSubAgentThisTask == true and (shared.delegatedForegroundBatches or 0) + 1 >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1457
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1464
		end -- 1464
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1464
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1467
		end -- 1467
		if shared.failedTestNeedsBuild == true then -- 1467
			if action.tool == "build" and result.success == true and shared.failedTestHasSourceEdit ~= true then -- 1467
				guidance[#guidance + 1] = "The build passed, but no authored source change has addressed the deterministic test failure. Make a narrow source fix before rebuilding or retesting." -- 1471
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1471
				guidance[#guidance + 1] = "Source changed after a deterministic test failure. Build the authored changes before running more tests." -- 1477
			elseif action.tool ~= "build" then -- 1477
				guidance[#guidance + 1] = "A deterministic test failure remains unresolved. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1479
			end -- 1479
		end -- 1479
		if action.tool == "search_dora_doc" then -- 1479
			if shared.unbuiltEdits == true then -- 1479
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1484
			end -- 1484
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1484
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1487
			end -- 1487
		end -- 1487
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1487
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1495
		end -- 1495
		if action.tool == "edit_file" and wasResumeNarrowReadMode then -- 1495
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1498
			if oldStr == "" then -- 1498
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1500
			end -- 1500
		end -- 1500
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1500
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1504
		end -- 1504
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1504
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1507
		end -- 1507
		if shared.buildRepairPending == true then -- 1507
			if action.tool == "build" then -- 1507
				guidance[#guidance + 1] = "This build reported authored-file diagnostics. Make a narrow source repair before building again." -- 1513
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1513
				guidance[#guidance + 1] = "A source repair was applied after build diagnostics. Build again before broadening the investigation." -- 1519
			else -- 1519
				guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1521
			end -- 1521
		end -- 1521
		if action.tool == "build" and shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true and shared.failedTestNeedsBuild ~= true then -- 1521
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1530
		end -- 1530
		result.guidance = table.concat(guidance, "\n") -- 1532
		if action.tool ~= "build" and action.tool ~= "read_file" then -- 1532
			shared.resumeNarrowReadMode = false -- 1537
		end -- 1537
		return ____awaiter_resolve(nil, result) -- 1537
	end) -- 1537
end -- 1437
local function maybeCompressHistory(shared, includePendingUserPrompt, pendingUserPrompt) -- 1542
	if includePendingUserPrompt == nil then -- 1542
		includePendingUserPrompt = false -- 1544
	end -- 1544
	if pendingUserPrompt == nil then -- 1544
		pendingUserPrompt = "" -- 1545
	end -- 1545
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1545
		local ____shared_33 = shared -- 1547
		local memory = ____shared_33.memory -- 1547
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1548
		local changed = false -- 1549
		do -- 1549
			local round = 0 -- 1550
			while round < maxRounds do -- 1550
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1551
				local normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1552
				local decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages) -- 1553
				local activeMessages = projectMessagesForCompression(normalizedActiveMessages) -- 1554
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1557
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1565
				local triggerMessages = buildDecisionMessages( -- 1568
					shared, -- 1569
					nil, -- 1570
					1, -- 1571
					nil, -- 1572
					shared.decisionMode, -- 1573
					false, -- 1574
					includePendingUserPrompt and pendingUserPrompt or "" -- 1575
				) -- 1575
				local triggerOptions = shared.decisionMode == "tool_calling" and __TS__ObjectAssign( -- 1577
					{}, -- 1578
					shared.llmOptions, -- 1579
					__TS__StringIncludes( -- 1580
						string.lower(shared.llmConfig.model), -- 1580
						"glm-5.2" -- 1580
					) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") and ({reasoning_effort = "minimal"}) or ({}), -- 1580
					{tools = AgentToolRegistry.buildDecisionToolSchema( -- 1578
						shared.role, -- 1585
						AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 1585
						{ -- 1585
							disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1586
							workMode = shared.workMode -- 1587
						} -- 1587
					)} -- 1587
				) or shared.llmOptions -- 1587
				local fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig) -- 1591
				local thresholdReached = getActiveRealMessageCount(shared) > 0 and fitted.originalTokens >= fitted.budgetTokens -- 1594
				if not thresholdReached then -- 1594
					if changed then -- 1594
						persistHistoryState(shared) -- 1598
					end -- 1598
					return ____awaiter_resolve(nil) -- 1598
				end -- 1598
				local compressionRound = round + 1 -- 1602
				AgentUtils.Log( -- 1603
					"Info", -- 1603
					(((("[Memory] Effective input budget reached tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " round=") .. tostring(compressionRound) -- 1603
				) -- 1603
				shared.step = shared.step + 1 -- 1604
				local stepId = shared.step -- 1605
				local pendingMessages = #activeMessages -- 1606
				emitAgentEvent( -- 1607
					shared, -- 1607
					{ -- 1607
						type = "memory_compression_started", -- 1608
						sessionId = shared.sessionId, -- 1609
						taskId = shared.taskId, -- 1610
						step = stepId, -- 1611
						tool = "compress_memory", -- 1612
						reason = getMemoryCompressionStartReason(shared), -- 1613
						params = { -- 1614
							round = compressionRound, -- 1615
							maxRounds = maxRounds, -- 1616
							pendingMessages = pendingMessages, -- 1617
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1618
							uncoveredMessages = #uncoveredMessages, -- 1619
							inputTokens = fitted.originalTokens, -- 1620
							inputBudgetTokens = fitted.budgetTokens -- 1621
						} -- 1621
					} -- 1621
				) -- 1621
				local result = __TS__Await(memory.compressor:compress( -- 1624
					activeMessages, -- 1625
					shared.llmOptions, -- 1626
					shared.llmMaxTry, -- 1627
					shared.decisionMode, -- 1628
					{ -- 1629
						onInput = function(____, phase, messages, options) -- 1630
							saveStepLLMDebugInput( -- 1631
								shared, -- 1631
								stepId, -- 1631
								phase, -- 1631
								messages, -- 1631
								options -- 1631
							) -- 1631
						end, -- 1630
						onOutput = function(____, phase, text, meta) -- 1633
							saveStepLLMDebugOutput( -- 1634
								shared, -- 1634
								stepId, -- 1634
								phase, -- 1634
								text, -- 1634
								meta -- 1634
							) -- 1634
						end, -- 1633
						onUsage = function(____, phase, usage) -- 1636
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1637
						end -- 1636
					}, -- 1636
					"default", -- 1640
					systemPrompt, -- 1641
					toolDefinitions, -- 1642
					decisionActiveMessages -- 1643
				)) -- 1643
				if not (result and result.success and result.compressedCount > 0) then -- 1643
					emitAgentEvent( -- 1646
						shared, -- 1646
						{ -- 1646
							type = "memory_compression_finished", -- 1647
							sessionId = shared.sessionId, -- 1648
							taskId = shared.taskId, -- 1649
							step = stepId, -- 1650
							tool = "compress_memory", -- 1651
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1652
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1656
						} -- 1656
					) -- 1656
					if changed then -- 1656
						persistHistoryState(shared) -- 1664
					end -- 1664
					return ____awaiter_resolve(nil) -- 1664
				end -- 1664
				local effectiveCompressedCount = math.max( -- 1668
					0, -- 1669
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1670
				) -- 1670
				if effectiveCompressedCount <= 0 then -- 1670
					if changed then -- 1670
						persistHistoryState(shared) -- 1674
					end -- 1674
					return ____awaiter_resolve(nil) -- 1674
				end -- 1674
				emitAgentEvent( -- 1678
					shared, -- 1678
					{ -- 1678
						type = "memory_compression_finished", -- 1679
						sessionId = shared.sessionId, -- 1680
						taskId = shared.taskId, -- 1681
						step = stepId, -- 1682
						tool = "compress_memory", -- 1683
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1684
						result = { -- 1685
							success = true, -- 1686
							round = compressionRound, -- 1687
							compressedCount = effectiveCompressedCount, -- 1688
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1689
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1690
							partialRecovered = result.partialRecovered == true, -- 1691
							recoveredFields = result.recoveredFields or ({}), -- 1692
							finishReason = result.finishReason -- 1693
						} -- 1693
					} -- 1693
				) -- 1693
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1696
				changed = true -- 1697
				AgentUtils.Log( -- 1698
					"Info", -- 1698
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1698
				) -- 1698
				round = round + 1 -- 1550
			end -- 1550
		end -- 1550
		if changed then -- 1550
			persistHistoryState(shared) -- 1701
		end -- 1701
	end) -- 1701
end -- 1542
local function compactAllHistory(shared) -- 1705
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1705
		local ____shared_40 = shared -- 1706
		local memory = ____shared_40.memory -- 1706
		local rounds = 0 -- 1707
		local totalCompressed = 0 -- 1708
		while getActiveRealMessageCount(shared) > 0 do -- 1708
			if shared.stopToken.stopped then -- 1708
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1711
				return ____awaiter_resolve( -- 1711
					nil, -- 1711
					emitAgentTaskFinishEvent( -- 1712
						shared, -- 1712
						false, -- 1712
						getCancelledReason(shared) -- 1712
					) -- 1712
				) -- 1712
			end -- 1712
			rounds = rounds + 1 -- 1714
			shared.step = shared.step + 1 -- 1715
			local stepId = shared.step -- 1716
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1717
			local pendingMessages = #activeMessages -- 1718
			emitAgentEvent( -- 1719
				shared, -- 1719
				{ -- 1719
					type = "memory_compression_started", -- 1720
					sessionId = shared.sessionId, -- 1721
					taskId = shared.taskId, -- 1722
					step = stepId, -- 1723
					tool = "compress_memory", -- 1724
					reason = getMemoryCompressionStartReason(shared), -- 1725
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1726
				} -- 1726
			) -- 1726
			local result = __TS__Await(memory.compressor:compress( -- 1733
				activeMessages, -- 1734
				shared.llmOptions, -- 1735
				shared.llmMaxTry, -- 1736
				shared.decisionMode, -- 1737
				{ -- 1738
					onInput = function(____, phase, messages, options) -- 1739
						saveStepLLMDebugInput( -- 1740
							shared, -- 1740
							stepId, -- 1740
							phase, -- 1740
							messages, -- 1740
							options -- 1740
						) -- 1740
					end, -- 1739
					onOutput = function(____, phase, text, meta) -- 1742
						saveStepLLMDebugOutput( -- 1743
							shared, -- 1743
							stepId, -- 1743
							phase, -- 1743
							text, -- 1743
							meta -- 1743
						) -- 1743
					end, -- 1742
					onUsage = function(____, phase, usage) -- 1745
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1746
					end -- 1745
				}, -- 1745
				"budget_max" -- 1749
			)) -- 1749
			if not (result and result.success and result.compressedCount > 0) then -- 1749
				emitAgentEvent( -- 1752
					shared, -- 1752
					{ -- 1752
						type = "memory_compression_finished", -- 1753
						sessionId = shared.sessionId, -- 1754
						taskId = shared.taskId, -- 1755
						step = stepId, -- 1756
						tool = "compress_memory", -- 1757
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1758
						result = { -- 1762
							success = false, -- 1763
							rounds = rounds, -- 1764
							error = result and result.error or "compression returned no changes", -- 1765
							compressedCount = result and result.compressedCount or 0, -- 1766
							fullCompaction = true -- 1767
						} -- 1767
					} -- 1767
				) -- 1767
				return ____awaiter_resolve( -- 1767
					nil, -- 1767
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1770
				) -- 1770
			end -- 1770
			local effectiveCompressedCount = math.max( -- 1775
				0, -- 1776
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1777
			) -- 1777
			if effectiveCompressedCount <= 0 then -- 1777
				return ____awaiter_resolve( -- 1777
					nil, -- 1777
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1780
				) -- 1780
			end -- 1780
			emitAgentEvent( -- 1787
				shared, -- 1787
				{ -- 1787
					type = "memory_compression_finished", -- 1788
					sessionId = shared.sessionId, -- 1789
					taskId = shared.taskId, -- 1790
					step = stepId, -- 1791
					tool = "compress_memory", -- 1792
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1793
					result = { -- 1794
						success = true, -- 1795
						round = rounds, -- 1796
						compressedCount = effectiveCompressedCount, -- 1797
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1798
						fullCompaction = true, -- 1799
						partialRecovered = result.partialRecovered == true, -- 1800
						recoveredFields = result.recoveredFields or ({}), -- 1801
						finishReason = result.finishReason -- 1802
					} -- 1802
				} -- 1802
			) -- 1802
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1805
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1806
			persistHistoryState(shared) -- 1807
			AgentUtils.Log( -- 1808
				"Info", -- 1808
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1808
			) -- 1808
		end -- 1808
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1810
		return ____awaiter_resolve( -- 1810
			nil, -- 1810
			emitAgentTaskFinishEvent( -- 1811
				shared, -- 1812
				true, -- 1813
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1814
			) -- 1814
		) -- 1814
	end) -- 1814
end -- 1705
local function clearSessionHistory(shared) -- 1820
	shared.messages = {} -- 1821
	shared.lastConsolidatedIndex = 0 -- 1822
	shared.carryMessageIndex = nil -- 1823
	persistHistoryState(shared) -- 1824
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1825
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1826
end -- 1820
local function appendConversationMessage(shared, message) -- 1982
	local ____shared_messages_49 = shared.messages -- 1982
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1983
		{}, -- 1983
		message, -- 1984
		{ -- 1983
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1985
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1986
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1987
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1988
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1989
		} -- 1989
	) -- 1989
end -- 1982
local function appendToolResultMessage(shared, action) -- 1998
	appendConversationMessage( -- 1999
		shared, -- 1999
		{ -- 1999
			role = "tool", -- 2000
			tool_call_id = action.toolCallId, -- 2001
			name = action.tool, -- 2002
			content = action.result and toJson(action.result, false) or "" -- 2003
		} -- 2003
	) -- 2003
end -- 1998
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 2007
	appendConversationMessage( -- 2013
		shared, -- 2013
		{ -- 2013
			role = "assistant", -- 2014
			content = content or "", -- 2015
			reasoning_content = reasoningContent, -- 2016
			tool_calls = __TS__ArrayMap( -- 2017
				actions, -- 2017
				function(____, action) return { -- 2017
					id = action.toolCallId, -- 2018
					type = "function", -- 2019
					["function"] = { -- 2020
						name = action.tool, -- 2021
						arguments = toJson(action.params, false) -- 2022
					} -- 2022
				} end -- 2022
			) -- 2022
		} -- 2022
	) -- 2022
end -- 2007
local function llm(shared, messages, phase) -- 2206
	if phase == nil then -- 2206
		phase = "decision_xml" -- 2209
	end -- 2209
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2209
		local stepId = shared.step + 1 -- 2211
		emitLLMContextMetrics( -- 2212
			shared, -- 2212
			stepId, -- 2212
			phase, -- 2212
			messages, -- 2212
			shared.llmOptions -- 2212
		) -- 2212
		saveStepLLMDebugInput( -- 2213
			shared, -- 2213
			stepId, -- 2213
			phase, -- 2213
			messages, -- 2213
			shared.llmOptions -- 2213
		) -- 2213
		local lastStreamReasoning = "" -- 2214
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2215
			messages, -- 2216
			shared.llmOptions, -- 2217
			shared.stopToken, -- 2218
			shared.llmConfig, -- 2219
			function(response) -- 2220
				local ____opt_53 = response.choices -- 2220
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2220
				local streamMessage = ____opt_51 and ____opt_51.message -- 2221
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2222
				if nextContent == "" then -- 2222
					return -- 2225
				end -- 2225
				if nextContent == lastStreamReasoning then -- 2225
					return -- 2226
				end -- 2226
				lastStreamReasoning = nextContent -- 2227
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2228
			end -- 2220
		)) -- 2220
		if res.success then -- 2220
			local usage = res.tokenUsage -- 2232
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2233
			local ____opt_59 = res.response.choices -- 2233
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2233
			local message = ____opt_57 and ____opt_57.message -- 2234
			local text = message and message.content -- 2235
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2236
			if text then -- 2236
				local parsed = tryParseAndValidateDecision(text, shared) -- 2240
				if parsed.success then -- 2240
					local reason = parsed.reason or "" -- 2242
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2243
				end -- 2243
				saveStepLLMDebugOutput( -- 2245
					shared, -- 2245
					stepId, -- 2245
					phase, -- 2245
					text, -- 2245
					{success = true, usage = usage} -- 2245
				) -- 2245
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2245
			else -- 2245
				saveStepLLMDebugOutput( -- 2248
					shared, -- 2248
					stepId, -- 2248
					phase, -- 2248
					"empty LLM response", -- 2248
					{success = false, usage = usage} -- 2248
				) -- 2248
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2248
			end -- 2248
		else -- 2248
			local usage = res.tokenUsage -- 2252
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2253
			saveStepLLMDebugOutput( -- 2254
				shared, -- 2254
				stepId, -- 2254
				phase, -- 2254
				res.raw or res.message, -- 2254
				{success = false, usage = usage} -- 2254
			) -- 2254
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2254
		end -- 2254
	end) -- 2254
end -- 2206
local function isDecisionBatchSuccess(result) -- 2285
	return result.kind == "batch" -- 2286
end -- 2285
local function isDecisionTruncated(result) -- 2289
	return result.success == false and result.recoverable == true -- 2290
end -- 2289
local function parseDecisionToolCall(functionName, rawObj) -- 2314
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2314
		return {success = false, message = "unknown tool: " .. functionName} -- 2316
	end -- 2316
	if rawObj == nil then -- 2316
		return {success = true, tool = functionName, params = {}} -- 2319
	end -- 2319
	if not isRecord(rawObj) then -- 2319
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2322
	end -- 2322
	return {success = true, tool = functionName, params = rawObj} -- 2324
end -- 2314
local function parseToolCallArguments(functionName, argsText) -- 2331
	local trimmedArgs = __TS__StringTrim(argsText) -- 2332
	if trimmedArgs == "" then -- 2332
		return {} -- 2334
	end -- 2334
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2336
	if err ~= nil or rawObj == nil then -- 2336
		return { -- 2338
			success = false, -- 2339
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2340
			raw = argsText -- 2341
		} -- 2341
	end -- 2341
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2344
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2344
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2346
	end -- 2346
	return rawObj -- 2352
end -- 2331
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2355
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2363
	if isRecord(rawArgs) and rawArgs.success == false then -- 2363
		return rawArgs -- 2365
	end -- 2365
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2367
	if not decision.success then -- 2367
		return {success = false, message = decision.message, raw = argsText} -- 2369
	end -- 2369
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2375
	if not completionValidation.success then -- 2375
		return {success = false, message = completionValidation.message, raw = argsText} -- 2377
	end -- 2377
	local validation = validateDecision(decision.tool, decision.params) -- 2383
	if not validation.success then -- 2383
		return {success = false, message = validation.message, raw = argsText} -- 2385
	end -- 2385
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2391
	if not sharedValidation.success then -- 2391
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2393
	end -- 2393
	decision.params = validation.params -- 2399
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2400
	decision.reason = reason -- 2401
	decision.reasoningContent = reasoningContent -- 2402
	return decision -- 2403
end -- 2355
local function createPreExecutableActionFromStream(shared, toolCall) -- 2406
	local ____opt_65 = toolCall["function"] -- 2406
	local functionName = ____opt_65 and ____opt_65.name -- 2407
	local ____opt_67 = toolCall["function"] -- 2407
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2408
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2409
	if not functionName or not toolCallId then -- 2409
		return nil -- 2410
	end -- 2410
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2411
	if isRecord(rawArgs) and rawArgs.success == false then -- 2411
		return nil -- 2412
	end -- 2412
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2413
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2413
		return nil -- 2414
	end -- 2414
	local validation = validateDecision(decision.tool, decision.params) -- 2415
	if not validation.success then -- 2415
		return nil -- 2416
	end -- 2416
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2416
		return nil -- 2417
	end -- 2417
	return { -- 2418
		step = shared.step + 1, -- 2419
		toolCallId = toolCallId, -- 2420
		tool = decision.tool, -- 2421
		reason = "", -- 2422
		params = validation.params, -- 2423
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2424
	} -- 2424
end -- 2406
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2825
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2834
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2835
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2843
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2844
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2845
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2853
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2861
		shared.role, -- 2861
		{ -- 2861
			includeFinish = true, -- 2862
			includeXmlRules = true, -- 2863
			context = {searchDoraDocLimitMax = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax}, -- 2864
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2865
			workMode = shared.workMode -- 2866
		} -- 2866
	) -- 2866
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2868
	local repairPrompt = replacePromptVars( -- 2871
		shared.promptPack.xmlDecisionRepairPrompt, -- 2871
		{ -- 2871
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2872
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2873
			CANDIDATE_SECTION = candidateSection, -- 2874
			LAST_ERROR = lastError, -- 2875
			ATTEMPT = tostring(attempt) -- 2876
		} -- 2876
	) -- 2876
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2878
end -- 2825
local MainDecisionAgent = __TS__Class() -- 2916
MainDecisionAgent.name = "MainDecisionAgent" -- 2916
__TS__ClassExtends(MainDecisionAgent, Node) -- 2916
function MainDecisionAgent.prototype.prep(self, shared) -- 2917
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2917
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2917
			return ____awaiter_resolve(nil, {shared = shared}) -- 2917
		end -- 2917
		__TS__Await(maybeCompressHistory(shared)) -- 2922
		return ____awaiter_resolve(nil, {shared = shared}) -- 2922
	end) -- 2922
end -- 2917
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2927
	local preExecuted = shared.preExecutedResults -- 2928
	if not preExecuted or preExecuted.size == 0 then -- 2928
		return nil -- 2929
	end -- 2929
	local decisions = {} -- 2930
	preExecuted:forEach(function(____, preResult) -- 2931
		local action = preResult.action -- 2932
		decisions[#decisions + 1] = { -- 2933
			success = true, -- 2934
			tool = action.tool, -- 2935
			params = action.params, -- 2936
			toolCallId = action.toolCallId, -- 2937
			reason = action.reason, -- 2938
			reasoningContent = action.reasoningContent -- 2939
		} -- 2939
	end) -- 2931
	if #decisions == 0 then -- 2931
		return nil -- 2942
	end -- 2942
	AgentUtils.Log( -- 2943
		"Warn", -- 2943
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2943
			__TS__ArrayMap( -- 2943
				decisions, -- 2943
				function(____, decision) return decision.tool end -- 2943
			), -- 2943
			"," -- 2943
		) -- 2943
	) -- 2943
	if #decisions == 1 then -- 2943
		return decisions[1] -- 2945
	end -- 2945
	return {success = true, kind = "batch", decisions = decisions} -- 2947
end -- 2927
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2954
	if attempt == nil then -- 2954
		attempt = 1 -- 2957
	end -- 2957
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2957
		if shared.stopToken.stopped then -- 2957
			return ____awaiter_resolve( -- 2957
				nil, -- 2957
				{ -- 2961
					success = false, -- 2961
					message = getCancelledReason(shared) -- 2961
				} -- 2961
			) -- 2961
		end -- 2961
		AgentUtils.Log( -- 2963
			"Info", -- 2963
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2963
		) -- 2963
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2964
			shared.role, -- 2964
			AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax, -- 2964
			{ -- 2964
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2965
				workMode = shared.workMode -- 2966
			} -- 2966
		) -- 2966
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2968
		local stepId = shared.step + 1 -- 2969
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2970
			string.lower(shared.llmConfig.model), -- 2970
			"glm-5.2" -- 2970
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2970
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2973
		emitLLMContextMetrics( -- 2978
			shared, -- 2978
			stepId, -- 2978
			"decision_tool_calling", -- 2978
			messages, -- 2978
			llmOptions -- 2978
		) -- 2978
		saveStepLLMDebugInput( -- 2979
			shared, -- 2979
			stepId, -- 2979
			"decision_tool_calling", -- 2979
			messages, -- 2979
			llmOptions -- 2979
		) -- 2979
		local lastStreamContent = "" -- 2980
		local lastStreamReasoning = "" -- 2981
		local preExecutedResults = __TS__New(Map) -- 2982
		shared.preExecutedResults = preExecutedResults -- 2983
		local remainingWorkSteps = getRemainingAgentWorkSteps(shared.agentStepCount, shared.maxSteps) -- 2984
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2985
			messages, -- 2986
			llmOptions, -- 2987
			shared.stopToken, -- 2988
			shared.llmConfig, -- 2989
			function(response) -- 2990
				local ____opt_75 = response.choices -- 2990
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2990
				local streamMessage = ____opt_73 and ____opt_73.message -- 2991
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2992
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2995
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2995
					return -- 2999
				end -- 2999
				lastStreamContent = nextContent -- 3001
				lastStreamReasoning = nextReasoning -- 3002
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 3003
			end, -- 2990
			function(tc) -- 3005
				if shared.stopToken.stopped then -- 3005
					return -- 3006
				end -- 3006
				if preExecutedResults.size >= remainingWorkSteps then -- 3006
					return -- 3007
				end -- 3007
				local action = createPreExecutableActionFromStream(shared, tc) -- 3008
				if not action or preExecutedResults:has(action.toolCallId) then -- 3008
					return -- 3009
				end -- 3009
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 3010
				preExecutedResults:set( -- 3011
					action.toolCallId, -- 3011
					createPreExecutedToolResult(shared, action) -- 3011
				) -- 3011
			end -- 3005
		)) -- 3005
		if shared.stopToken.stopped then -- 3005
			clearPreExecutedResults(shared) -- 3015
			return ____awaiter_resolve( -- 3015
				nil, -- 3015
				{ -- 3016
					success = false, -- 3016
					message = getCancelledReason(shared) -- 3016
				} -- 3016
			) -- 3016
		end -- 3016
		if not res.success then -- 3016
			local usage = res.tokenUsage -- 3019
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3020
			saveStepLLMDebugOutput( -- 3021
				shared, -- 3021
				stepId, -- 3021
				"decision_tool_calling", -- 3021
				res.raw or res.message, -- 3021
				{success = false, usage = usage} -- 3021
			) -- 3021
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 3022
			local committed = self:commitPreExecutedDecision(shared) -- 3023
			if committed then -- 3023
				return ____awaiter_resolve(nil, committed) -- 3023
			end -- 3023
			clearPreExecutedResults(shared) -- 3025
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 3025
		end -- 3025
		local usage = res.tokenUsage -- 3028
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3029
		saveStepLLMDebugOutput( -- 3030
			shared, -- 3030
			stepId, -- 3030
			"decision_tool_calling", -- 3030
			encodeDebugJSON(res.response), -- 3030
			{success = true, usage = usage} -- 3030
		) -- 3030
		local choice = res.response.choices and res.response.choices[1] -- 3031
		local message = choice and choice.message -- 3032
		local toolCalls = message and message.tool_calls -- 3033
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3034
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3037
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3040
		AgentUtils.Log( -- 3043
			"Info", -- 3043
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3043
		) -- 3043
		if finishReason == "length" then -- 3043
			local committed = self:commitPreExecutedDecision(shared) -- 3045
			if committed then -- 3045
				return ____awaiter_resolve(nil, committed) -- 3045
			end -- 3045
			AgentUtils.Log( -- 3047
				"Error", -- 3047
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3047
			) -- 3047
			clearPreExecutedResults(shared) -- 3048
			return ____awaiter_resolve(nil, { -- 3048
				success = false, -- 3050
				recoverable = true, -- 3051
				message = "tool-calling output was truncated by max tokens; the incomplete tool call was discarded", -- 3052
				content = messageContent, -- 3053
				reasoningContent = reasoningContent -- 3054
			}) -- 3054
		end -- 3054
		if not toolCalls or #toolCalls == 0 then -- 3054
			if messageContent and messageContent ~= "" then -- 3054
				if isFinalDecisionTurn(shared) then -- 3054
					clearPreExecutedResults(shared) -- 3060
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3060
				end -- 3060
				if shared.role == "sub" then -- 3060
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3068
					clearPreExecutedResults(shared) -- 3069
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3069
				end -- 3069
				AgentUtils.Log( -- 3076
					"Info", -- 3076
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3076
				) -- 3076
				clearPreExecutedResults(shared) -- 3077
				return ____awaiter_resolve(nil, { -- 3077
					success = true, -- 3079
					tool = "finish", -- 3080
					params = {}, -- 3081
					reason = messageContent, -- 3082
					reasoningContent = reasoningContent, -- 3083
					directSummary = messageContent -- 3084
				}) -- 3084
			end -- 3084
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3087
			clearPreExecutedResults(shared) -- 3088
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3088
		end -- 3088
		if #toolCalls > 1 and #toolCalls > remainingWorkSteps then -- 3088
			AgentUtils.Log( -- 3096
				"Warn", -- 3096
				(("[CodingAgent] parallel tool batch exceeds remaining step budget calls=" .. tostring(#toolCalls)) .. " remaining=") .. tostring(remainingWorkSteps) -- 3096
			) -- 3096
			local committed = self:commitPreExecutedDecision(shared) -- 3097
			if committed then -- 3097
				return ____awaiter_resolve(nil, committed) -- 3097
			end -- 3097
			clearPreExecutedResults(shared) -- 3099
			return ____awaiter_resolve( -- 3099
				nil, -- 3099
				{ -- 3100
					success = false, -- 3101
					message = ("parallel tool call batch exceeds the remaining task step budget (" .. tostring(remainingWorkSteps)) .. ")", -- 3102
					raw = messageContent -- 3103
				} -- 3103
			) -- 3103
		end -- 3103
		local decisions = {} -- 3106
		do -- 3106
			local i = 0 -- 3107
			while i < #toolCalls do -- 3107
				local toolCall = toolCalls[i + 1] -- 3108
				local fn = toolCall ~= nil and toolCall["function"] -- 3109
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3109
					AgentUtils.Log( -- 3111
						"Error", -- 3111
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3111
					) -- 3111
					clearPreExecutedResults(shared) -- 3112
					return ____awaiter_resolve( -- 3112
						nil, -- 3112
						{ -- 3113
							success = false, -- 3114
							message = "missing function name for tool call " .. tostring(i + 1), -- 3115
							raw = messageContent -- 3116
						} -- 3116
					) -- 3116
				end -- 3116
				local functionName = fn.name -- 3119
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3120
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3121
				AgentUtils.Log( -- 3124
					"Info", -- 3124
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3124
				) -- 3124
				local decision = parseAndValidateToolCallDecision( -- 3125
					shared, -- 3126
					functionName, -- 3127
					argsText, -- 3128
					toolCallId, -- 3129
					messageContent, -- 3130
					reasoningContent -- 3131
				) -- 3131
				if not decision.success then -- 3131
					AgentUtils.Log( -- 3134
						"Error", -- 3134
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3134
					) -- 3134
					clearPreExecutedResults(shared) -- 3135
					return ____awaiter_resolve(nil, decision) -- 3135
				end -- 3135
				decisions[#decisions + 1] = decision -- 3138
				i = i + 1 -- 3107
			end -- 3107
		end -- 3107
		if #decisions == 1 then -- 3107
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3141
			return ____awaiter_resolve(nil, decisions[1]) -- 3141
		end -- 3141
		do -- 3141
			local i = 0 -- 3144
			while i < #decisions do -- 3144
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3144
					clearPreExecutedResults(shared) -- 3146
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3146
				end -- 3146
				i = i + 1 -- 3144
			end -- 3144
		end -- 3144
		AgentUtils.Log( -- 3154
			"Info", -- 3154
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3154
				__TS__ArrayMap( -- 3154
					decisions, -- 3154
					function(____, decision) return decision.tool end -- 3154
				), -- 3154
				"," -- 3154
			) -- 3154
		) -- 3154
		return ____awaiter_resolve(nil, { -- 3154
			success = true, -- 3156
			kind = "batch", -- 3157
			decisions = decisions, -- 3158
			content = messageContent, -- 3159
			reasoningContent = reasoningContent -- 3160
		}) -- 3160
	end) -- 3160
end -- 2954
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3164
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3164
		AgentUtils.Log( -- 3170
			"Info", -- 3170
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3170
		) -- 3170
		local lastError = initialError -- 3171
		local candidateRaw = "" -- 3172
		local candidateReasoning = nil -- 3173
		do -- 3173
			local attempt = 0 -- 3174
			while attempt < shared.llmMaxTry do -- 3174
				do -- 3174
					AgentUtils.Log( -- 3175
						"Info", -- 3175
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3175
					) -- 3175
					local messages = buildXmlRepairMessages( -- 3176
						shared, -- 3177
						originalRaw, -- 3178
						originalReasoning, -- 3179
						candidateRaw, -- 3180
						candidateReasoning, -- 3181
						lastError, -- 3182
						attempt + 1 -- 3183
					) -- 3183
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3185
					if shared.stopToken.stopped then -- 3185
						return ____awaiter_resolve( -- 3185
							nil, -- 3185
							{ -- 3187
								success = false, -- 3187
								message = getCancelledReason(shared) -- 3187
							} -- 3187
						) -- 3187
					end -- 3187
					if not llmRes.success then -- 3187
						lastError = llmRes.message -- 3190
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3191
						goto __continue533 -- 3192
					end -- 3192
					candidateRaw = llmRes.text -- 3194
					candidateReasoning = llmRes.reasoningContent -- 3195
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3196
					if decision.success then -- 3196
						decision.reasoningContent = llmRes.reasoningContent -- 3198
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3199
						return ____awaiter_resolve(nil, decision) -- 3199
					end -- 3199
					lastError = decision.message -- 3202
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3203
				end -- 3203
				::__continue533:: -- 3203
				attempt = attempt + 1 -- 3174
			end -- 3174
		end -- 3174
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3205
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3205
	end) -- 3205
end -- 3164
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3213
	if attempt == nil then -- 3213
		attempt = 1 -- 3216
	end -- 3216
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3216
		local messages = buildDecisionMessages( -- 3219
			shared, -- 3220
			lastError, -- 3221
			attempt, -- 3222
			lastRaw, -- 3223
			"xml" -- 3224
		) -- 3224
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3226
		if shared.stopToken.stopped then -- 3226
			return ____awaiter_resolve( -- 3226
				nil, -- 3226
				{ -- 3228
					success = false, -- 3228
					message = getCancelledReason(shared) -- 3228
				} -- 3228
			) -- 3228
		end -- 3228
		if not llmRes.success then -- 3228
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3228
		end -- 3228
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3237
		if decision.success then -- 3237
			decision.reasoningContent = llmRes.reasoningContent -- 3239
			return ____awaiter_resolve(nil, decision) -- 3239
		end -- 3239
		return ____awaiter_resolve( -- 3239
			nil, -- 3239
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3242
		) -- 3242
	end) -- 3242
end -- 3213
function MainDecisionAgent.prototype.exec(self, input) -- 3245
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3245
		local shared = input.shared -- 3246
		if shared.stopToken.stopped then -- 3246
			return ____awaiter_resolve( -- 3246
				nil, -- 3246
				{ -- 3248
					success = false, -- 3248
					message = getCancelledReason(shared) -- 3248
				} -- 3248
			) -- 3248
		end -- 3248
		if shared.agentStepCount >= shared.maxSteps then -- 3248
			AgentUtils.Log( -- 3251
				"Warn", -- 3251
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3251
			) -- 3251
			return ____awaiter_resolve( -- 3251
				nil, -- 3251
				{ -- 3252
					success = false, -- 3252
					message = getMaxStepsReachedReason(shared) -- 3252
				} -- 3252
			) -- 3252
		end -- 3252
		if shared.decisionMode == "tool_calling" then -- 3252
			AgentUtils.Log( -- 3256
				"Info", -- 3256
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3256
			) -- 3256
			local lastError = "tool calling validation failed" -- 3257
			local lastRaw = "" -- 3258
			local shouldFallbackToXml = false -- 3259
			do -- 3259
				local attempt = 0 -- 3260
				while attempt < shared.llmMaxTry do -- 3260
					AgentUtils.Log( -- 3261
						"Info", -- 3261
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3261
					) -- 3261
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3262
					if shared.stopToken.stopped then -- 3262
						return ____awaiter_resolve( -- 3262
							nil, -- 3262
							{ -- 3269
								success = false, -- 3269
								message = getCancelledReason(shared) -- 3269
							} -- 3269
						) -- 3269
					end -- 3269
					if decision.success then -- 3269
						return ____awaiter_resolve(nil, decision) -- 3269
					end -- 3269
					if isDecisionTruncated(decision) then -- 3269
						AgentUtils.Log( -- 3275
							"Warn", -- 3275
							"[CodingAgent] preserving truncated assistant turn as recoverable step=" .. tostring(shared.step + 1) -- 3275
						) -- 3275
						return ____awaiter_resolve(nil, decision) -- 3275
					end -- 3275
					lastError = decision.message -- 3278
					lastRaw = decision.raw or "" -- 3279
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3280
					if lastError == "missing tool call" then -- 3280
						shouldFallbackToXml = true -- 3282
						break -- 3283
					end -- 3283
					attempt = attempt + 1 -- 3260
				end -- 3260
			end -- 3260
			if shouldFallbackToXml then -- 3260
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3287
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3288
				do -- 3288
					local attempt = 0 -- 3289
					while attempt < shared.llmMaxTry do -- 3289
						AgentUtils.Log( -- 3290
							"Info", -- 3290
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3290
						) -- 3290
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3291
						if shared.stopToken.stopped then -- 3291
							return ____awaiter_resolve( -- 3291
								nil, -- 3291
								{ -- 3298
									success = false, -- 3298
									message = getCancelledReason(shared) -- 3298
								} -- 3298
							) -- 3298
						end -- 3298
						if decision.success then -- 3298
							return ____awaiter_resolve(nil, decision) -- 3298
						end -- 3298
						lastError = decision.message -- 3303
						lastRaw = decision.raw or "" -- 3304
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3305
						attempt = attempt + 1 -- 3289
					end -- 3289
				end -- 3289
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3307
				return ____awaiter_resolve( -- 3307
					nil, -- 3307
					{ -- 3308
						success = false, -- 3308
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3308
					} -- 3308
				) -- 3308
			end -- 3308
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3310
			return ____awaiter_resolve( -- 3310
				nil, -- 3310
				{ -- 3311
					success = false, -- 3311
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3311
				} -- 3311
			) -- 3311
		end -- 3311
		local lastError = "xml validation failed" -- 3314
		local lastRaw = "" -- 3315
		do -- 3315
			local attempt = 0 -- 3316
			while attempt < shared.llmMaxTry do -- 3316
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3317
				if shared.stopToken.stopped then -- 3317
					return ____awaiter_resolve( -- 3317
						nil, -- 3317
						{ -- 3326
							success = false, -- 3326
							message = getCancelledReason(shared) -- 3326
						} -- 3326
					) -- 3326
				end -- 3326
				if decision.success then -- 3326
					return ____awaiter_resolve(nil, decision) -- 3326
				end -- 3326
				lastError = decision.message -- 3331
				lastRaw = decision.raw or "" -- 3332
				attempt = attempt + 1 -- 3316
			end -- 3316
		end -- 3316
		return ____awaiter_resolve( -- 3316
			nil, -- 3316
			{ -- 3334
				success = false, -- 3334
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3334
			} -- 3334
		) -- 3334
	end) -- 3334
end -- 3245
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3337
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3337
		local result = execRes -- 3338
		if not result.success then -- 3338
			if shared.stopToken.stopped then -- 3338
				shared.error = getCancelledReason(shared) -- 3341
				shared.done = true -- 3342
				return ____awaiter_resolve(nil, "done") -- 3342
			end -- 3342
			if isDecisionTruncated(result) then -- 3342
				shared.step = shared.step + 1 -- 3346
				shared.agentStepCount = shared.agentStepCount + 1 -- 3347
				local content = result.content or "" -- 3348
				appendConversationMessage(shared, {role = "assistant", content = content, reasoning_content = result.reasoningContent}) -- 3349
				shared.pendingTruncationRecovery = true -- 3354
				emitAssistantMessageFinished(shared, shared.step, content, result.reasoningContent) -- 3355
				persistHistoryState(shared) -- 3356
				return ____awaiter_resolve(nil, "main") -- 3356
			end -- 3356
			shared.error = result.message -- 3359
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3360
			shared.done = true -- 3361
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3362
			persistHistoryState(shared) -- 3366
			return ____awaiter_resolve(nil, "done") -- 3366
		end -- 3366
		if isDecisionBatchSuccess(result) then -- 3366
			local startStep = shared.step -- 3370
			local actions = {} -- 3371
			do -- 3371
				local i = 0 -- 3372
				while i < #result.decisions do -- 3372
					local decision = result.decisions[i + 1] -- 3373
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3374
					local step = startStep + i + 1 -- 3375
					local ____temp_81 -- 3376
					if i == 0 then -- 3376
						____temp_81 = decision.reason -- 3376
					else -- 3376
						____temp_81 = "" -- 3376
					end -- 3376
					local actionReason = ____temp_81 -- 3376
					local ____temp_82 -- 3377
					if i == 0 then -- 3377
						____temp_82 = decision.reasoningContent -- 3377
					else -- 3377
						____temp_82 = nil -- 3377
					end -- 3377
					local actionReasoningContent = ____temp_82 -- 3377
					emitAgentEvent(shared, { -- 3378
						type = "decision_made", -- 3379
						sessionId = shared.sessionId, -- 3380
						taskId = shared.taskId, -- 3381
						step = step, -- 3382
						tool = decision.tool, -- 3383
						reason = actionReason, -- 3384
						reasoningContent = actionReasoningContent, -- 3385
						params = decision.params -- 3386
					}) -- 3386
					local action = { -- 3388
						step = step, -- 3389
						toolCallId = toolCallId, -- 3390
						tool = decision.tool, -- 3391
						reason = actionReason or "", -- 3392
						reasoningContent = actionReasoningContent, -- 3393
						params = decision.params, -- 3394
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3395
					} -- 3395
					local ____shared_history_83 = shared.history -- 3395
					____shared_history_83[#____shared_history_83 + 1] = action -- 3397
					actions[#actions + 1] = action -- 3398
					i = i + 1 -- 3372
				end -- 3372
			end -- 3372
			shared.step = startStep + #actions -- 3400
			shared.agentStepCount = shared.agentStepCount + #actions -- 3401
			shared.pendingToolActions = actions -- 3402
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3403
			persistHistoryState(shared) -- 3409
			return ____awaiter_resolve(nil, "batch_tools") -- 3409
		end -- 3409
		if result.directSummary and result.directSummary ~= "" then -- 3409
			shared.response = result.directSummary -- 3413
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3414
			shared.done = true -- 3418
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3419
			persistHistoryState(shared) -- 3424
			return ____awaiter_resolve(nil, "done") -- 3424
		end -- 3424
		if result.tool == "finish" then -- 3424
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3428
			shared.response = finalMessage -- 3429
			shared.completion = getCompletionReport(result.params) -- 3430
			shared.done = true -- 3431
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3432
			persistHistoryState(shared) -- 3437
			return ____awaiter_resolve(nil, "done") -- 3437
		end -- 3437
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3440
		shared.step = shared.step + 1 -- 3441
		shared.agentStepCount = shared.agentStepCount + 1 -- 3442
		local step = shared.step -- 3443
		emitAgentEvent(shared, { -- 3444
			type = "decision_made", -- 3445
			sessionId = shared.sessionId, -- 3446
			taskId = shared.taskId, -- 3447
			step = step, -- 3448
			tool = result.tool, -- 3449
			reason = result.reason, -- 3450
			reasoningContent = result.reasoningContent, -- 3451
			params = result.params -- 3452
		}) -- 3452
		local ____shared_history_84 = shared.history -- 3452
		____shared_history_84[#____shared_history_84 + 1] = { -- 3454
			step = step, -- 3455
			toolCallId = toolCallId, -- 3456
			tool = result.tool, -- 3457
			reason = result.reason or "", -- 3458
			reasoningContent = result.reasoningContent, -- 3459
			params = result.params, -- 3460
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3461
		} -- 3461
		local action = shared.history[#shared.history] -- 3463
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3464
		shared.pendingToolActions = {action} -- 3467
		persistHistoryState(shared) -- 3468
		return ____awaiter_resolve(nil, "batch_tools") -- 3468
	end) -- 3468
end -- 3337
local ReadFileAction = __TS__Class() -- 3473
ReadFileAction.name = "ReadFileAction" -- 3473
__TS__ClassExtends(ReadFileAction, Node) -- 3473
function ReadFileAction.prototype.prep(self, shared) -- 3474
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3474
		local last = shared.history[#shared.history] -- 3475
		if not last then -- 3475
			error( -- 3476
				__TS__New(Error, "no history"), -- 3476
				0 -- 3476
			) -- 3476
		end -- 3476
		emitAgentStartEvent(shared, last) -- 3477
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3478
		if __TS__StringTrim(path) == "" then -- 3478
			error( -- 3481
				__TS__New(Error, "missing path"), -- 3481
				0 -- 3481
			) -- 3481
		end -- 3481
		local ____path_87 = path -- 3483
		local ____shared_workingDir_88 = shared.workingDir -- 3485
		local ____temp_89 = shared.useChineseResponse and "zh" or "en" -- 3486
		local ____last_params_startLine_85 = last.params.startLine -- 3487
		if ____last_params_startLine_85 == nil then -- 3487
			____last_params_startLine_85 = 1 -- 3487
		end -- 3487
		local ____TS__Number_result_90 = __TS__Number(____last_params_startLine_85) -- 3487
		local ____last_params_endLine_86 = last.params.endLine -- 3488
		if ____last_params_endLine_86 == nil then -- 3488
			____last_params_endLine_86 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3488
		end -- 3488
		return ____awaiter_resolve( -- 3488
			nil, -- 3488
			{ -- 3482
				path = ____path_87, -- 3483
				tool = "read_file", -- 3484
				workDir = ____shared_workingDir_88, -- 3485
				docLanguage = ____temp_89, -- 3486
				startLine = ____TS__Number_result_90, -- 3487
				endLine = __TS__Number(____last_params_endLine_86) -- 3488
			} -- 3488
		) -- 3488
	end) -- 3488
end -- 3474
function ReadFileAction.prototype.exec(self, input) -- 3492
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3492
		return ____awaiter_resolve( -- 3492
			nil, -- 3492
			Tools.readFile( -- 3493
				input.workDir, -- 3494
				input.path, -- 3495
				__TS__Number(input.startLine or 1), -- 3496
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3497
				input.docLanguage -- 3498
			) -- 3498
		) -- 3498
	end) -- 3498
end -- 3492
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3502
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3502
		local result = execRes -- 3503
		local last = shared.history[#shared.history] -- 3504
		if last ~= nil then -- 3504
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3506
			appendToolResultMessage(shared, last) -- 3507
			emitAgentFinishEvent(shared, last) -- 3508
		end -- 3508
		persistHistoryState(shared) -- 3510
		__TS__Await(maybeCompressHistory(shared)) -- 3511
		persistHistoryState(shared) -- 3512
		return ____awaiter_resolve(nil, "main") -- 3512
	end) -- 3512
end -- 3502
local SearchFilesAction = __TS__Class() -- 3517
SearchFilesAction.name = "SearchFilesAction" -- 3517
__TS__ClassExtends(SearchFilesAction, Node) -- 3517
function SearchFilesAction.prototype.prep(self, shared) -- 3518
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3518
		local last = shared.history[#shared.history] -- 3519
		if not last then -- 3519
			error( -- 3520
				__TS__New(Error, "no history"), -- 3520
				0 -- 3520
			) -- 3520
		end -- 3520
		emitAgentStartEvent(shared, last) -- 3521
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3521
	end) -- 3521
end -- 3518
function SearchFilesAction.prototype.exec(self, input) -- 3525
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3525
		local params = input.params -- 3526
		local ____Tools_searchFiles_105 = Tools.searchFiles -- 3527
		local ____input_workDir_97 = input.workDir -- 3528
		local ____temp_98 = params.path or "" -- 3529
		local ____temp_99 = params.pattern or "" -- 3530
		local ____params_globs_100 = params.globs -- 3531
		local ____params_useRegex_101 = params.useRegex -- 3532
		local ____params_caseSensitive_102 = params.caseSensitive -- 3533
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_103 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3535
		local ____math_max_93 = math.max -- 3536
		local ____math_floor_92 = math.floor -- 3536
		local ____params_limit_91 = params.limit -- 3536
		if ____params_limit_91 == nil then -- 3536
			____params_limit_91 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3536
		end -- 3536
		local ____math_max_93_result_104 = ____math_max_93( -- 3536
			1, -- 3536
			____math_floor_92(__TS__Number(____params_limit_91)) -- 3536
		) -- 3536
		local ____math_max_96 = math.max -- 3537
		local ____math_floor_95 = math.floor -- 3537
		local ____params_offset_94 = params.offset -- 3537
		if ____params_offset_94 == nil then -- 3537
			____params_offset_94 = 0 -- 3537
		end -- 3537
		local result = __TS__Await(____Tools_searchFiles_105({ -- 3527
			workDir = ____input_workDir_97, -- 3528
			path = ____temp_98, -- 3529
			pattern = ____temp_99, -- 3530
			globs = ____params_globs_100, -- 3531
			useRegex = ____params_useRegex_101, -- 3532
			caseSensitive = ____params_caseSensitive_102, -- 3533
			includeContent = true, -- 3534
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_103, -- 3535
			limit = ____math_max_93_result_104, -- 3536
			offset = ____math_max_96( -- 3537
				0, -- 3537
				____math_floor_95(__TS__Number(____params_offset_94)) -- 3537
			), -- 3537
			groupByFile = params.groupByFile == true -- 3538
		})) -- 3538
		return ____awaiter_resolve(nil, result) -- 3538
	end) -- 3538
end -- 3525
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3543
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3543
		local last = shared.history[#shared.history] -- 3544
		if last ~= nil then -- 3544
			local result = execRes -- 3546
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3547
			appendToolResultMessage(shared, last) -- 3548
			emitAgentFinishEvent(shared, last) -- 3549
		end -- 3549
		persistHistoryState(shared) -- 3551
		__TS__Await(maybeCompressHistory(shared)) -- 3552
		persistHistoryState(shared) -- 3553
		return ____awaiter_resolve(nil, "main") -- 3553
	end) -- 3553
end -- 3543
local SearchDoraDocAction = __TS__Class() -- 3558
SearchDoraDocAction.name = "SearchDoraDocAction" -- 3558
__TS__ClassExtends(SearchDoraDocAction, Node) -- 3558
function SearchDoraDocAction.prototype.prep(self, shared) -- 3559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3559
		local last = shared.history[#shared.history] -- 3560
		if not last then -- 3560
			error( -- 3561
				__TS__New(Error, "no history"), -- 3561
				0 -- 3561
			) -- 3561
		end -- 3561
		emitAgentStartEvent(shared, last) -- 3562
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3562
	end) -- 3562
end -- 3559
function SearchDoraDocAction.prototype.exec(self, input) -- 3566
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3566
		local params = input.params -- 3567
		local ____Tools_searchDoraDoc_114 = Tools.searchDoraDoc -- 3568
		local ____temp_110 = params.pattern or "" -- 3569
		local ____temp_111 = params.docType or "dora-api" -- 3570
		local ____temp_112 = input.useChineseResponse and "zh" or "en" -- 3571
		local ____temp_113 = params.programmingLanguage or "ts" -- 3572
		local ____math_min_109 = math.min -- 3573
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_108 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 3573
		local ____math_max_107 = math.max -- 3573
		local ____params_limit_106 = params.limit -- 3573
		if ____params_limit_106 == nil then -- 3573
			____params_limit_106 = 8 -- 3573
		end -- 3573
		local result = __TS__Await(____Tools_searchDoraDoc_114({ -- 3568
			pattern = ____temp_110, -- 3569
			docType = ____temp_111, -- 3570
			docLanguage = ____temp_112, -- 3571
			programmingLanguage = ____temp_113, -- 3572
			limit = ____math_min_109( -- 3573
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_108, -- 3573
				____math_max_107( -- 3573
					1, -- 3573
					__TS__Number(____params_limit_106) -- 3573
				) -- 3573
			), -- 3573
			useRegex = params.useRegex, -- 3574
			caseSensitive = false, -- 3575
			includeContent = true, -- 3576
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3577
		})) -- 3577
		return ____awaiter_resolve(nil, result) -- 3577
	end) -- 3577
end -- 3566
function SearchDoraDocAction.prototype.post(self, shared, _prepRes, execRes) -- 3582
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3582
		local last = shared.history[#shared.history] -- 3583
		if last ~= nil then -- 3583
			local result = execRes -- 3585
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3586
			appendToolResultMessage(shared, last) -- 3587
			emitAgentFinishEvent(shared, last) -- 3588
		end -- 3588
		persistHistoryState(shared) -- 3590
		__TS__Await(maybeCompressHistory(shared)) -- 3591
		persistHistoryState(shared) -- 3592
		return ____awaiter_resolve(nil, "main") -- 3592
	end) -- 3592
end -- 3582
local ListFilesAction = __TS__Class() -- 3597
ListFilesAction.name = "ListFilesAction" -- 3597
__TS__ClassExtends(ListFilesAction, Node) -- 3597
function ListFilesAction.prototype.prep(self, shared) -- 3598
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3598
		local last = shared.history[#shared.history] -- 3599
		if not last then -- 3599
			error( -- 3600
				__TS__New(Error, "no history"), -- 3600
				0 -- 3600
			) -- 3600
		end -- 3600
		emitAgentStartEvent(shared, last) -- 3601
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3601
	end) -- 3601
end -- 3598
function ListFilesAction.prototype.exec(self, input) -- 3605
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3605
		local params = input.params -- 3606
		local ____Tools_listFiles_121 = Tools.listFiles -- 3607
		local ____input_workDir_118 = input.workDir -- 3608
		local ____temp_119 = params.path or "" -- 3609
		local ____params_globs_120 = params.globs -- 3610
		local ____math_max_117 = math.max -- 3611
		local ____math_floor_116 = math.floor -- 3611
		local ____params_maxEntries_115 = params.maxEntries -- 3611
		if ____params_maxEntries_115 == nil then -- 3611
			____params_maxEntries_115 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3611
		end -- 3611
		local result = ____Tools_listFiles_121({ -- 3607
			workDir = ____input_workDir_118, -- 3608
			path = ____temp_119, -- 3609
			globs = ____params_globs_120, -- 3610
			maxEntries = ____math_max_117( -- 3611
				1, -- 3611
				____math_floor_116(__TS__Number(____params_maxEntries_115)) -- 3611
			) -- 3611
		}) -- 3611
		return ____awaiter_resolve(nil, result) -- 3611
	end) -- 3611
end -- 3605
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3616
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3616
		local last = shared.history[#shared.history] -- 3617
		if last ~= nil then -- 3617
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3619
			appendToolResultMessage(shared, last) -- 3620
			emitAgentFinishEvent(shared, last) -- 3621
		end -- 3621
		persistHistoryState(shared) -- 3623
		__TS__Await(maybeCompressHistory(shared)) -- 3624
		persistHistoryState(shared) -- 3625
		return ____awaiter_resolve(nil, "main") -- 3625
	end) -- 3625
end -- 3616
local DeleteFileAction = __TS__Class() -- 3630
DeleteFileAction.name = "DeleteFileAction" -- 3630
__TS__ClassExtends(DeleteFileAction, Node) -- 3630
function DeleteFileAction.prototype.prep(self, shared) -- 3631
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3631
		local last = shared.history[#shared.history] -- 3632
		if not last then -- 3632
			error( -- 3633
				__TS__New(Error, "no history"), -- 3633
				0 -- 3633
			) -- 3633
		end -- 3633
		emitAgentStartEvent(shared, last) -- 3634
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3635
		if __TS__StringTrim(targetFile) == "" then -- 3635
			error( -- 3638
				__TS__New(Error, "missing target_file"), -- 3638
				0 -- 3638
			) -- 3638
		end -- 3638
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3638
	end) -- 3638
end -- 3631
function DeleteFileAction.prototype.exec(self, input) -- 3642
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3642
		local result = Tools.deleteFile(input.taskId, input.workDir, input.targetFile, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3643
		if not result.success then -- 3643
			return ____awaiter_resolve(nil, result) -- 3643
		end -- 3643
		local ____result_checkpointed_123 = result.checkpointed -- 3654
		local ____result_reversible_124 = result.reversible -- 3655
		local ____result_binary_125 = result.binary -- 3656
		local ____temp_126 = result.checkpointed and result.checkpointId or nil -- 3657
		local ____temp_127 = result.checkpointed and result.checkpointSeq or nil -- 3658
		local ____result_checkpointed_122 -- 3659
		if result.checkpointed then -- 3659
			____result_checkpointed_122 = nil -- 3659
		else -- 3659
			____result_checkpointed_122 = result.message -- 3659
		end -- 3659
		return ____awaiter_resolve(nil, { -- 3659
			success = true, -- 3651
			changed = true, -- 3652
			mode = "delete", -- 3653
			checkpointed = ____result_checkpointed_123, -- 3654
			reversible = ____result_reversible_124, -- 3655
			binary = ____result_binary_125, -- 3656
			checkpointId = ____temp_126, -- 3657
			checkpointSeq = ____temp_127, -- 3658
			message = ____result_checkpointed_122, -- 3659
			files = {{path = input.targetFile, op = "delete"}} -- 3660
		}) -- 3660
	end) -- 3660
end -- 3642
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3664
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3664
		local last = shared.history[#shared.history] -- 3665
		if last ~= nil then -- 3665
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3667
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3668
			appendToolResultMessage(shared, last) -- 3669
			emitAgentFinishEvent(shared, last) -- 3670
			local result = last.result -- 3671
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3671
				emitAgentEvent(shared, { -- 3676
					type = "checkpoint_created", -- 3677
					sessionId = shared.sessionId, -- 3678
					taskId = shared.taskId, -- 3679
					step = last.step, -- 3680
					tool = "delete_file", -- 3681
					checkpointId = result.checkpointId, -- 3682
					checkpointSeq = result.checkpointSeq, -- 3683
					files = result.files -- 3684
				}) -- 3684
			end -- 3684
		end -- 3684
		persistHistoryState(shared) -- 3691
		__TS__Await(maybeCompressHistory(shared)) -- 3692
		persistHistoryState(shared) -- 3693
		return ____awaiter_resolve(nil, "main") -- 3693
	end) -- 3693
end -- 3664
local BuildAction = __TS__Class() -- 3698
BuildAction.name = "BuildAction" -- 3698
__TS__ClassExtends(BuildAction, Node) -- 3698
function BuildAction.prototype.prep(self, shared) -- 3699
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3699
		local last = shared.history[#shared.history] -- 3700
		if not last then -- 3700
			error( -- 3701
				__TS__New(Error, "no history"), -- 3701
				0 -- 3701
			) -- 3701
		end -- 3701
		emitAgentStartEvent(shared, last) -- 3702
		return ____awaiter_resolve( -- 3702
			nil, -- 3702
			{ -- 3703
				params = last.params, -- 3703
				workDir = shared.workingDir, -- 3703
				isCancelled = function() return shared.stopToken.stopped end -- 3703
			} -- 3703
		) -- 3703
	end) -- 3703
end -- 3699
function BuildAction.prototype.exec(self, input) -- 3706
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3706
		local params = input.params -- 3707
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or "", isCancelled = input.isCancelled})) -- 3708
		return ____awaiter_resolve(nil, result) -- 3708
	end) -- 3708
end -- 3706
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3716
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3716
		local last = shared.history[#shared.history] -- 3717
		if last ~= nil then -- 3717
			last.result = sanitizeBuildResultForHistory(execRes) -- 3719
			appendToolResultMessage(shared, last) -- 3720
			emitAgentFinishEvent(shared, last) -- 3721
		end -- 3721
		persistHistoryState(shared) -- 3723
		__TS__Await(maybeCompressHistory(shared)) -- 3724
		persistHistoryState(shared) -- 3725
		return ____awaiter_resolve(nil, "main") -- 3725
	end) -- 3725
end -- 3716
local SpawnSubAgentAction = __TS__Class() -- 3730
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3730
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3730
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3731
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3731
		local last = shared.history[#shared.history] -- 3741
		if not last then -- 3741
			error( -- 3742
				__TS__New(Error, "no history"), -- 3742
				0 -- 3742
			) -- 3742
		end -- 3742
		emitAgentStartEvent(shared, last) -- 3743
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3744
			last.params.filesHint, -- 3745
			function(____, item) return type(item) == "string" end -- 3745
		) or nil -- 3745
		return ____awaiter_resolve( -- 3745
			nil, -- 3745
			{ -- 3747
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3748
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3749
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3750
				filesHint = filesHint, -- 3751
				sessionId = shared.sessionId, -- 3752
				projectRoot = shared.workingDir, -- 3753
				spawnSubAgent = shared.spawnSubAgent, -- 3754
				disabledAgentTools = shared.disabledAgentTools -- 3755
			} -- 3755
		) -- 3755
	end) -- 3755
end -- 3731
function SpawnSubAgentAction.prototype.exec(self, input) -- 3759
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3759
		if not input.spawnSubAgent then -- 3759
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3759
		end -- 3759
		if input.sessionId == nil or input.sessionId <= 0 then -- 3759
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3759
		end -- 3759
		local ____AgentUtils_Log_133 = AgentUtils.Log -- 3775
		local ____temp_130 = #input.title -- 3775
		local ____temp_131 = #input.prompt -- 3775
		local ____temp_132 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3775
		local ____opt_128 = input.filesHint -- 3775
		____AgentUtils_Log_133( -- 3775
			"Info", -- 3775
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_130)) .. " prompt_len=") .. tostring(____temp_131)) .. " expected_len=") .. tostring(____temp_132)) .. " files_hint_count=") .. tostring(____opt_128 and #____opt_128 or 0) -- 3775
		) -- 3775
		local result = __TS__Await(input.spawnSubAgent({ -- 3776
			parentSessionId = input.sessionId, -- 3777
			projectRoot = input.projectRoot, -- 3778
			title = input.title, -- 3779
			prompt = input.prompt, -- 3780
			expectedOutput = input.expectedOutput, -- 3781
			filesHint = input.filesHint, -- 3782
			disabledAgentTools = input.disabledAgentTools -- 3783
		})) -- 3783
		if not result.success then -- 3783
			return ____awaiter_resolve(nil, result) -- 3783
		end -- 3783
		return ____awaiter_resolve(nil, { -- 3783
			success = true, -- 3789
			sessionId = result.sessionId, -- 3790
			taskId = result.taskId, -- 3791
			title = result.title, -- 3792
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3793
		}) -- 3793
	end) -- 3793
end -- 3759
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3797
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3797
		local last = shared.history[#shared.history] -- 3798
		if last ~= nil then -- 3798
			last.result = execRes -- 3800
			if execRes.success == true then -- 3800
				shared.hasSpawnedSubAgentThisTask = true -- 3802
			end -- 3802
			appendToolResultMessage(shared, last) -- 3804
			emitAgentFinishEvent(shared, last) -- 3805
		end -- 3805
		persistHistoryState(shared) -- 3807
		__TS__Await(maybeCompressHistory(shared)) -- 3808
		persistHistoryState(shared) -- 3809
		return ____awaiter_resolve(nil, "main") -- 3809
	end) -- 3809
end -- 3797
local ListSubAgentsAction = __TS__Class() -- 3814
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3814
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3814
function ListSubAgentsAction.prototype.prep(self, shared) -- 3815
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3815
		local last = shared.history[#shared.history] -- 3825
		if not last then -- 3825
			error( -- 3826
				__TS__New(Error, "no history"), -- 3826
				0 -- 3826
			) -- 3826
		end -- 3826
		emitAgentStartEvent(shared, last) -- 3827
		return ____awaiter_resolve( -- 3827
			nil, -- 3827
			{ -- 3828
				sessionId = shared.sessionId, -- 3829
				projectRoot = shared.workingDir, -- 3830
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3831
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3832
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3833
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3834
				listSubAgents = shared.listSubAgents, -- 3835
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3836
			} -- 3836
		) -- 3836
	end) -- 3836
end -- 3815
function ListSubAgentsAction.prototype.exec(self, input) -- 3840
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3840
		if not input.listSubAgents then -- 3840
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3840
		end -- 3840
		if input.sessionId == nil or input.sessionId <= 0 then -- 3840
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3840
		end -- 3840
		local result = __TS__Await(input.listSubAgents({ -- 3856
			sessionId = input.sessionId, -- 3857
			projectRoot = input.projectRoot, -- 3858
			status = input.status, -- 3859
			limit = input.limit, -- 3860
			offset = input.offset, -- 3861
			query = input.query -- 3862
		})) -- 3862
		return ____awaiter_resolve( -- 3862
			nil, -- 3862
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3864
		) -- 3864
	end) -- 3864
end -- 3840
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3872
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3872
		local last = shared.history[#shared.history] -- 3873
		if last ~= nil then -- 3873
			last.result = execRes -- 3875
			appendToolResultMessage(shared, last) -- 3876
			emitAgentFinishEvent(shared, last) -- 3877
		end -- 3877
		persistHistoryState(shared) -- 3879
		__TS__Await(maybeCompressHistory(shared)) -- 3880
		persistHistoryState(shared) -- 3881
		return ____awaiter_resolve(nil, "main") -- 3881
	end) -- 3881
end -- 3872
EditFileAction = __TS__Class() -- 3886
EditFileAction.name = "EditFileAction" -- 3886
__TS__ClassExtends(EditFileAction, Node) -- 3886
function EditFileAction.prototype.prep(self, shared) -- 3887
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3887
		local last = shared.history[#shared.history] -- 3888
		if not last then -- 3888
			error( -- 3889
				__TS__New(Error, "no history"), -- 3889
				0 -- 3889
			) -- 3889
		end -- 3889
		emitAgentStartEvent(shared, last) -- 3890
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3891
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3894
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3895
		if __TS__StringTrim(path) == "" then -- 3895
			error( -- 3896
				__TS__New(Error, "missing path"), -- 3896
				0 -- 3896
			) -- 3896
		end -- 3896
		return ____awaiter_resolve(nil, { -- 3896
			path = path, -- 3897
			oldStr = oldStr, -- 3897
			newStr = newStr, -- 3897
			taskId = shared.taskId, -- 3897
			workDir = shared.workingDir -- 3897
		}) -- 3897
	end) -- 3897
end -- 3887
function EditFileAction.prototype.exec(self, input) -- 3900
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3900
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3901
		if not readRes.success then -- 3901
			if input.oldStr ~= "" then -- 3901
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3901
			end -- 3901
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3906
			if not createRes.success then -- 3906
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3906
			end -- 3906
			return ____awaiter_resolve( -- 3906
				nil, -- 3906
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3913
					success = true, -- 3914
					changed = true, -- 3915
					mode = "create", -- 3916
					checkpointId = createRes.checkpointId, -- 3917
					checkpointSeq = createRes.checkpointSeq, -- 3918
					files = {{path = input.path, op = "create"}} -- 3919
				}) -- 3919
			) -- 3919
		end -- 3919
		if input.oldStr == "" then -- 3919
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3919
				return ____awaiter_resolve( -- 3919
					nil, -- 3919
					{ -- 3924
						success = false, -- 3925
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3926
						actualSaved = false, -- 3927
						actualSavedCharacters = 0, -- 3928
						currentFileExists = true, -- 3929
						currentCharacters = #readRes.content, -- 3930
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3931
					} -- 3931
				) -- 3931
			end -- 3931
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3934
			if not overwriteRes.success then -- 3934
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3934
			end -- 3934
			return ____awaiter_resolve( -- 3934
				nil, -- 3934
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3941
					success = true, -- 3942
					changed = true, -- 3943
					mode = "overwrite", -- 3944
					checkpointId = overwriteRes.checkpointId, -- 3945
					checkpointSeq = overwriteRes.checkpointSeq, -- 3946
					files = {{path = input.path, op = "write"}} -- 3947
				}) -- 3947
			) -- 3947
		end -- 3947
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3952
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3953
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3954
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3957
		if occurrences == 0 then -- 3957
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3959
			if not indentTolerant.success then -- 3959
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3959
			end -- 3959
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3963
			if not applyRes.success then -- 3963
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3963
			end -- 3963
			return ____awaiter_resolve( -- 3963
				nil, -- 3963
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3970
					success = true, -- 3971
					changed = true, -- 3972
					mode = "replace_indent_tolerant", -- 3973
					checkpointId = applyRes.checkpointId, -- 3974
					checkpointSeq = applyRes.checkpointSeq, -- 3975
					files = {{path = input.path, op = "write"}} -- 3976
				}) -- 3976
			) -- 3976
		end -- 3976
		if occurrences > 1 then -- 3976
			return ____awaiter_resolve( -- 3976
				nil, -- 3976
				{ -- 3980
					success = false, -- 3980
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3980
				} -- 3980
			) -- 3980
		end -- 3980
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3984
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3985
		if not applyRes.success then -- 3985
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3985
		end -- 3985
		return ____awaiter_resolve( -- 3985
			nil, -- 3985
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3992
				success = true, -- 3993
				changed = true, -- 3994
				mode = "replace", -- 3995
				checkpointId = applyRes.checkpointId, -- 3996
				checkpointSeq = applyRes.checkpointSeq, -- 3997
				files = {{path = input.path, op = "write"}} -- 3998
			}) -- 3998
		) -- 3998
	end) -- 3998
end -- 3900
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 4002
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4002
		local last = shared.history[#shared.history] -- 4003
		if last ~= nil then -- 4003
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 4005
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 4006
			appendToolResultMessage(shared, last) -- 4007
			emitAgentFinishEvent(shared, last) -- 4008
			local result = last.result -- 4009
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4009
				emitAgentEvent(shared, { -- 4014
					type = "checkpoint_created", -- 4015
					sessionId = shared.sessionId, -- 4016
					taskId = shared.taskId, -- 4017
					step = last.step, -- 4018
					tool = last.tool, -- 4019
					checkpointId = result.checkpointId, -- 4020
					checkpointSeq = result.checkpointSeq, -- 4021
					files = result.files -- 4022
				}) -- 4022
			end -- 4022
		end -- 4022
		persistHistoryState(shared) -- 4029
		__TS__Await(maybeCompressHistory(shared)) -- 4030
		persistHistoryState(shared) -- 4031
		return ____awaiter_resolve(nil, "main") -- 4031
	end) -- 4031
end -- 4002
local FetchUrlAction = __TS__Class() -- 4036
FetchUrlAction.name = "FetchUrlAction" -- 4036
__TS__ClassExtends(FetchUrlAction, Node) -- 4036
function FetchUrlAction.prototype.prep(self, shared) -- 4037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4037
		local last = shared.history[#shared.history] -- 4038
		if not last then -- 4038
			error( -- 4039
				__TS__New(Error, "no history"), -- 4039
				0 -- 4039
			) -- 4039
		end -- 4039
		emitAgentStartEvent(shared, last) -- 4040
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 4040
	end) -- 4040
end -- 4037
function FetchUrlAction.prototype.exec(self, input) -- 4044
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4044
		return ____awaiter_resolve( -- 4044
			nil, -- 4044
			executeToolAction(input.shared, input.action) -- 4045
		) -- 4045
	end) -- 4045
end -- 4044
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 4048
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4048
		local last = shared.history[#shared.history] -- 4049
		if last ~= nil then -- 4049
			last.result = execRes -- 4051
			appendToolResultMessage(shared, last) -- 4052
			emitAgentFinishEvent(shared, last) -- 4053
		end -- 4053
		persistHistoryState(shared) -- 4055
		__TS__Await(maybeCompressHistory(shared)) -- 4056
		persistHistoryState(shared) -- 4057
		return ____awaiter_resolve(nil, "main") -- 4057
	end) -- 4057
end -- 4048
local function emitCheckpointEventForAction(shared, action) -- 4062
	local result = action.result -- 4063
	if not result then -- 4063
		return -- 4064
	end -- 4064
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4064
		emitAgentEvent(shared, { -- 4069
			type = "checkpoint_created", -- 4070
			sessionId = shared.sessionId, -- 4071
			taskId = shared.taskId, -- 4072
			step = action.step, -- 4073
			tool = action.tool, -- 4074
			checkpointId = result.checkpointId, -- 4075
			checkpointSeq = result.checkpointSeq, -- 4076
			files = result.files -- 4077
		}) -- 4077
	end -- 4077
end -- 4062
local function canRunBatchActionInParallel(self, action) -- 4606
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4607
end -- 4606
local function partitionToolCalls(actions) -- 4615
	local batches = {} -- 4616
	do -- 4616
		local i = 0 -- 4617
		while i < #actions do -- 4617
			local action = actions[i + 1] -- 4618
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4619
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4620
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4620
				local ____lastBatch_actions_172 = lastBatch.actions -- 4620
				____lastBatch_actions_172[#____lastBatch_actions_172 + 1] = action -- 4622
			else -- 4622
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4624
			end -- 4624
			i = i + 1 -- 4617
		end -- 4617
	end -- 4617
	return batches -- 4627
end -- 4615
local function completeStoppedToolAction(shared, action) -- 4630
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4631
	if not action.result then -- 4631
		action.result = { -- 4633
			success = false, -- 4633
			message = getCancelledReason(shared) -- 4633
		} -- 4633
	end -- 4633
	appendToolResultMessage(shared, action) -- 4635
	emitAgentFinishEvent(shared, action) -- 4636
	emitCheckpointEventForAction(shared, action) -- 4637
end -- 4630
local BatchToolAction = __TS__Class() -- 4640
BatchToolAction.name = "BatchToolAction" -- 4640
__TS__ClassExtends(BatchToolAction, Node) -- 4640
function BatchToolAction.prototype.prep(self, shared) -- 4641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4641
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4641
	end) -- 4641
end -- 4641
function BatchToolAction.prototype.exec(self, input) -- 4645
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4645
		local shared = input.shared -- 4646
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4647
		local preExecuted = shared.preExecutedResults -- 4648
		local batches = partitionToolCalls(input.actions) -- 4649
		local parallelBatchCount = #__TS__ArrayFilter( -- 4650
			batches, -- 4650
			function(____, b) return b.isConcurrencySafe end -- 4650
		) -- 4650
		local serialBatchCount = #__TS__ArrayFilter( -- 4651
			batches, -- 4651
			function(____, b) return not b.isConcurrencySafe end -- 4651
		) -- 4651
		AgentUtils.Log( -- 4652
			"Info", -- 4652
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4652
		) -- 4652
		do -- 4652
			local batchIdx = 0 -- 4654
			while batchIdx < #batches do -- 4654
				do -- 4654
					local batch = batches[batchIdx + 1] -- 4655
					if shared.stopToken.stopped then -- 4655
						for ____, action in ipairs(batch.actions) do -- 4657
							completeStoppedToolAction(shared, action) -- 4658
						end -- 4658
						goto __continue767 -- 4660
					end -- 4660
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4660
						local preExecCount = #__TS__ArrayFilter( -- 4664
							batch.actions, -- 4664
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4664
						) -- 4664
						AgentUtils.Log( -- 4665
							"Info", -- 4665
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4665
						) -- 4665
						do -- 4665
							local i = 0 -- 4666
							while i < #batch.actions do -- 4666
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4667
								i = i + 1 -- 4666
							end -- 4666
						end -- 4666
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4669
							batch.actions, -- 4669
							function(____, action) -- 4669
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4669
									if shared.stopToken.stopped then -- 4669
										action.result = { -- 4671
											success = false, -- 4671
											message = getCancelledReason(shared) -- 4671
										} -- 4671
										return ____awaiter_resolve(nil, action) -- 4671
									end -- 4671
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4674
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4675
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4676
									return ____awaiter_resolve(nil, action) -- 4676
								end) -- 4676
							end -- 4669
						))) -- 4669
						do -- 4669
							local i = 0 -- 4679
							while i < #batch.actions do -- 4679
								local action = batch.actions[i + 1] -- 4680
								if not action.result then -- 4680
									action.result = {success = false, message = "tool did not produce a result"} -- 4682
								end -- 4682
								appendToolResultMessage(shared, action) -- 4684
								emitAgentFinishEvent(shared, action) -- 4685
								emitCheckpointEventForAction(shared, action) -- 4686
								i = i + 1 -- 4679
							end -- 4679
						end -- 4679
					else -- 4679
						AgentUtils.Log( -- 4689
							"Info", -- 4689
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4689
						) -- 4689
						do -- 4689
							local i = 0 -- 4690
							while i < #batch.actions do -- 4690
								local action = batch.actions[i + 1] -- 4691
								emitAgentStartEvent(shared, action) -- 4692
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4693
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4694
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4695
								appendToolResultMessage(shared, action) -- 4696
								emitAgentFinishEvent(shared, action) -- 4697
								emitCheckpointEventForAction(shared, action) -- 4698
								persistHistoryState(shared) -- 4699
								if shared.stopToken.stopped then -- 4699
									do -- 4699
										local j = i + 1 -- 4701
										while j < #batch.actions do -- 4701
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4702
											j = j + 1 -- 4701
										end -- 4701
									end -- 4701
									break -- 4704
								end -- 4704
								i = i + 1 -- 4690
							end -- 4690
						end -- 4690
					end -- 4690
				end -- 4690
				::__continue767:: -- 4690
				batchIdx = batchIdx + 1 -- 4654
			end -- 4654
		end -- 4654
		local spawnSeen = spawnedBeforeBatch -- 4709
		local didDelegatedForegroundWork = false -- 4710
		do -- 4710
			local i = 0 -- 4711
			while i < #input.actions do -- 4711
				do -- 4711
					local action = input.actions[i + 1] -- 4712
					if action.tool == "spawn_sub_agent" then -- 4712
						local ____opt_175 = action.result -- 4712
						if (____opt_175 and ____opt_175.success) == true then -- 4712
							spawnSeen = true -- 4714
						end -- 4714
						goto __continue787 -- 4715
					end -- 4715
					if spawnSeen and action.tool ~= "finish" then -- 4715
						didDelegatedForegroundWork = true -- 4718
					end -- 4718
				end -- 4718
				::__continue787:: -- 4718
				i = i + 1 -- 4711
			end -- 4711
		end -- 4711
		if didDelegatedForegroundWork then -- 4711
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4722
		end -- 4722
		persistHistoryState(shared) -- 4724
		return ____awaiter_resolve(nil, input.actions) -- 4724
	end) -- 4724
end -- 4645
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4728
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4728
		shared.pendingToolActions = nil -- 4729
		shared.preExecutedResults = nil -- 4730
		persistHistoryState(shared) -- 4731
		if shared.waitingQuestionnaireId == nil then -- 4731
			__TS__Await(maybeCompressHistory(shared)) -- 4735
			persistHistoryState(shared) -- 4736
		end -- 4736
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4736
	end) -- 4736
end -- 4728
local EndNode = __TS__Class() -- 4742
EndNode.name = "EndNode" -- 4742
__TS__ClassExtends(EndNode, Node) -- 4742
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4743
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4743
		return ____awaiter_resolve(nil, nil) -- 4743
	end) -- 4743
end -- 4743
local CodingAgentFlow = __TS__Class() -- 4748
CodingAgentFlow.name = "CodingAgentFlow" -- 4748
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4748
function CodingAgentFlow.prototype.____constructor(self, role) -- 4749
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4750
	local read = __TS__New(ReadFileAction, 1, 0) -- 4751
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4752
	local searchDora = __TS__New(SearchDoraDocAction, 1, 0) -- 4753
	local list = __TS__New(ListFilesAction, 1, 0) -- 4754
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4755
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4756
	local build = __TS__New(BuildAction, 1, 0) -- 4757
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4758
	local edit = __TS__New(EditFileAction, 1, 0) -- 4759
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4760
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4761
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4762
	local done = __TS__New(EndNode, 1, 0) -- 4763
	main:on("batch_tools", batch) -- 4765
	main:on("grep_files", search) -- 4766
	main:on("search_dora_doc", searchDora) -- 4767
	main:on("glob_files", list) -- 4768
	main:on("fetch_url", fetch) -- 4769
	main:on("execute_command", exec) -- 4770
	if role == "main" then -- 4770
		main:on("read_file", read) -- 4772
		main:on("delete_file", del) -- 4773
		main:on("build", build) -- 4774
		main:on("edit_file", edit) -- 4775
		main:on("list_sub_agents", listSub) -- 4776
		main:on("spawn_sub_agent", spawn) -- 4777
	else -- 4777
		main:on("read_file", read) -- 4779
		main:on("delete_file", del) -- 4780
		main:on("build", build) -- 4781
		main:on("edit_file", edit) -- 4782
	end -- 4782
	main:on("done", done) -- 4784
	main:on("main", main) -- 4785
	search:on("main", main) -- 4787
	searchDora:on("main", main) -- 4788
	list:on("main", main) -- 4789
	listSub:on("main", main) -- 4790
	spawn:on("main", main) -- 4791
	batch:on("main", main) -- 4792
	batch:on("done", done) -- 4793
	read:on("main", main) -- 4794
	del:on("main", main) -- 4795
	build:on("main", main) -- 4796
	edit:on("main", main) -- 4797
	fetch:on("main", main) -- 4798
	exec:on("main", main) -- 4799
	Flow.prototype.____constructor(self, main) -- 4801
end -- 4749
local function runCodingAgentAsync(options) -- 4837
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4837
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4837
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4837
		end -- 4837
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4841
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4842
		if not llmConfigRes.success then -- 4842
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4842
		end -- 4842
		local llmConfig = llmConfigRes.config -- 4848
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4849
		if not taskRes.success then -- 4849
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4849
		end -- 4849
		local compressor = __TS__New(MemoryCompressor, { -- 4856
			compressionTargetThreshold = 0.5, -- 4857
			maxCompressionRounds = 3, -- 4858
			projectDir = options.workDir, -- 4859
			llmConfig = llmConfig, -- 4860
			promptPack = options.promptPack, -- 4861
			scope = options.memoryScope -- 4862
		}) -- 4862
		local persistedSession = compressor:getStorage():readSessionState() -- 4864
		local effectiveUserQuery = normalizedPrompt -- 4865
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4865
			do -- 4865
				local i = #persistedSession.messages - 1 -- 4867
				while i >= 0 do -- 4867
					local message = persistedSession.messages[i + 1] -- 4868
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4868
						effectiveUserQuery = message.content -- 4870
						break -- 4871
					end -- 4871
					i = i - 1 -- 4867
				end -- 4867
			end -- 4867
		end -- 4867
		local promptPack = compressor:getPromptPack() -- 4875
		local freshProject = inspectFreshProject(options.workDir) -- 4876
		local freshProjectBuildPending = freshProject.fresh -- 4877
		local freshProjectCodeFile = freshProject.codeFile -- 4878
		local shared = { -- 4880
			sessionId = options.sessionId, -- 4881
			taskId = taskRes.taskId, -- 4882
			role = options.role or "main", -- 4883
			maxSteps = math.max( -- 4884
				1, -- 4884
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4884
			), -- 4884
			llmMaxTry = math.max( -- 4885
				1, -- 4885
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4885
			), -- 4885
			step = math.max( -- 4886
				0, -- 4886
				math.floor(options.initialStep or 0) -- 4886
			), -- 4886
			agentStepCount = math.max( -- 4887
				0, -- 4887
				math.floor(options.initialAgentStepCount or 0) -- 4887
			), -- 4887
			done = false, -- 4888
			stopToken = options.stopToken or ({stopped = false}), -- 4889
			response = "", -- 4890
			userQuery = effectiveUserQuery, -- 4891
			workingDir = options.workDir, -- 4892
			useChineseResponse = options.useChineseResponse == true, -- 4893
			workMode = options.workMode or "code", -- 4894
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4895
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4898
			llmConfig = llmConfig, -- 4899
			onEvent = options.onEvent, -- 4900
			promptPack = promptPack, -- 4901
			history = {}, -- 4902
			messages = persistedSession.messages, -- 4903
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4904
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4905
			memory = {compressor = compressor}, -- 4907
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4911
				projectDir = options.workDir, -- 4913
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4914
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4915
			})}, -- 4915
			spawnSubAgent = options.spawnSubAgent, -- 4921
			listSubAgents = options.listSubAgents, -- 4922
			publishQuestionnaire = options.publishQuestionnaire, -- 4923
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4924
			freshProjectBuildPending = freshProjectBuildPending, -- 4925
			freshProjectCodeFile = freshProjectCodeFile, -- 4926
			hasSpawnedSubAgentThisTask = false, -- 4927
			delegatedForegroundBatches = 0, -- 4928
			tokenUsage = options.initialTokenUsage -- 4929
		} -- 4929
		local ____hasReturned, ____returnValue -- 4929
		local ____try = __TS__AsyncAwaiter(function() -- 4929
			if shared.workMode == "plan" then -- 4929
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4934
				if not planDocuments.success then -- 4934
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4936
					____hasReturned = true -- 4937
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4937
					return -- 4937
				end -- 4937
			end -- 4937
			emitAgentEvent(shared, { -- 4940
				type = "task_started", -- 4941
				sessionId = shared.sessionId, -- 4942
				taskId = shared.taskId, -- 4943
				prompt = shared.userQuery, -- 4944
				workDir = shared.workingDir, -- 4945
				maxSteps = shared.maxSteps, -- 4946
				resumed = options.resumeTask == true -- 4947
			}) -- 4947
			if shared.stopToken.stopped then -- 4947
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4950
				____hasReturned = true -- 4951
				____returnValue = emitAgentTaskFinishEvent( -- 4951
					shared, -- 4951
					false, -- 4951
					getCancelledReason(shared) -- 4951
				) -- 4951
				return -- 4951
			end -- 4951
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4953
			local ____temp_177 -- 4954
			if options.resumeConversation == true then -- 4954
				____temp_177 = nil -- 4954
			else -- 4954
				____temp_177 = getPromptCommand(shared.userQuery) -- 4954
			end -- 4954
			local promptCommand = ____temp_177 -- 4954
			if promptCommand == "clear" then -- 4954
				____hasReturned = true -- 4956
				____returnValue = clearSessionHistory(shared) -- 4956
				return -- 4956
			end -- 4956
			if promptCommand == "compact" then -- 4956
				if shared.role == "sub" then -- 4956
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4960
					____hasReturned = true -- 4961
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4961
					return -- 4961
				end -- 4961
				____hasReturned = true -- 4969
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4969
				return -- 4969
			end -- 4969
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4971
			if shared.stopToken.stopped then -- 4971
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4973
				____hasReturned = true -- 4974
				____returnValue = emitAgentTaskFinishEvent( -- 4974
					shared, -- 4974
					false, -- 4974
					getCancelledReason(shared) -- 4974
				) -- 4974
				return -- 4974
			end -- 4974
			if options.resumeConversation ~= true then -- 4974
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4977
				persistHistoryState(shared) -- 4981
			end -- 4981
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4983
			__TS__Await(flow:run(shared)) -- 4984
			if shared.stopToken.stopped then -- 4984
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4986
				____hasReturned = true -- 4987
				____returnValue = emitAgentTaskFinishEvent( -- 4987
					shared, -- 4987
					false, -- 4987
					getCancelledReason(shared) -- 4987
				) -- 4987
				return -- 4987
			end -- 4987
			if shared.error then -- 4987
				____hasReturned = true -- 4990
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4990
				return -- 4990
			end -- 4990
			if shared.waitingQuestionnaireId ~= nil then -- 4990
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4994
				emitAgentEvent(shared, { -- 4995
					type = "task_waiting_for_user", -- 4996
					sessionId = shared.sessionId, -- 4997
					taskId = shared.taskId, -- 4998
					step = shared.step, -- 4999
					questionnaireId = shared.waitingQuestionnaireId -- 5000
				}) -- 5000
				____hasReturned = true -- 5002
				____returnValue = { -- 5002
					success = true, -- 5003
					taskId = shared.taskId, -- 5004
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 5005
					steps = shared.step, -- 5006
					waitingForUser = true, -- 5007
					questionnaireId = shared.waitingQuestionnaireId -- 5008
				} -- 5008
				return -- 5002
			end -- 5002
			local ____isFinalDecisionTurn_result_180 = isFinalDecisionTurn(shared) -- 5011
			if ____isFinalDecisionTurn_result_180 then -- 5011
				local ____opt_178 = shared.completion -- 5011
				____isFinalDecisionTurn_result_180 = (____opt_178 and ____opt_178.outcome) == "partial" -- 5011
			end -- 5011
			if ____isFinalDecisionTurn_result_180 then -- 5011
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 5012
				____hasReturned = true -- 5013
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 5013
				return -- 5013
			end -- 5013
			Tools.setTaskStatus(shared.taskId, "DONE") -- 5016
			____hasReturned = true -- 5017
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 5017
			return -- 5017
		end) -- 5017
		____try = ____try.catch( -- 5017
			____try, -- 5017
			function(____, e) -- 5017
				return __TS__AsyncAwaiter(function() -- 5017
					____hasReturned = true -- 5020
					____returnValue = finalizeAgentFailure( -- 5020
						shared, -- 5020
						tostring(e) -- 5020
					) -- 5020
					return -- 5020
				end) -- 5020
			end -- 5020
		) -- 5020
		__TS__Await(____try) -- 4932
		if ____hasReturned then -- 4932
			return ____awaiter_resolve(nil, ____returnValue) -- 4932
		end -- 4932
	end) -- 4932
end -- 4837
function ____exports.runCodingAgent(options, callback) -- 5024
	local ____self_181 = runCodingAgentAsync(options) -- 5024
	____self_181["then"]( -- 5024
		____self_181, -- 5024
		function(____, result) return callback(result) end -- 5025
	) -- 5025
end -- 5024
return ____exports -- 5024