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
		"checkpointed", -- 1122
		"reversible", -- 1122
		"binary", -- 1122
		"actualSaved", -- 1123
		"actualSavedCharacters", -- 1123
		"currentFileExists", -- 1123
		"currentCharacters", -- 1123
		"currentState" -- 1123
	} -- 1123
	do -- 1123
		local i = 0 -- 1125
		while i < #scalarKeys do -- 1125
			local key = scalarKeys[i + 1] -- 1126
			if result[key] ~= nil then -- 1126
				projected[key] = result[key] -- 1127
			end -- 1127
			i = i + 1 -- 1125
		end -- 1125
	end -- 1125
	if isArray(result.files) then -- 1125
		projected.files = result.files -- 1129
	end -- 1129
	if type(result.message) == "string" then -- 1129
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1131
	end -- 1131
	if type(result.guidance) == "string" then -- 1131
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1138
	end -- 1138
	if isArray(result.fileContext) then -- 1138
		local summaries = {} -- 1145
		do -- 1145
			local i = 0 -- 1146
			while i < #result.fileContext do -- 1146
				do -- 1146
					local item = result.fileContext[i + 1] -- 1147
					if not isRecord(item) or isArray(item) then -- 1147
						goto __continue157 -- 1148
					end -- 1148
					local summary = {} -- 1149
					local keys = { -- 1150
						"path", -- 1151
						"op", -- 1151
						"beforeExists", -- 1151
						"afterExists", -- 1151
						"beforeBytes", -- 1151
						"afterBytes", -- 1151
						"lineCount", -- 1152
						"contentTruncated", -- 1152
						"fileListTruncated" -- 1152
					} -- 1152
					do -- 1152
						local j = 0 -- 1154
						while j < #keys do -- 1154
							local key = keys[j + 1] -- 1155
							if item[key] ~= nil then -- 1155
								summary[key] = item[key] -- 1156
							end -- 1156
							j = j + 1 -- 1154
						end -- 1154
					end -- 1154
					summaries[#summaries + 1] = summary -- 1158
				end -- 1158
				::__continue157:: -- 1158
				i = i + 1 -- 1146
			end -- 1146
		end -- 1146
		if #summaries > 0 then -- 1146
			projected.fileSummary = summaries -- 1160
		end -- 1160
	end -- 1160
	if type(result.truncatedFileContextItems) == "number" then -- 1160
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1163
	end -- 1163
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1165
	return projected -- 1166
end -- 1166
function projectBuildResultForLLM(result) -- 1169
	if not isArray(result.messages) then -- 1169
		return result -- 1170
	end -- 1170
	local projected = {} -- 1171
	for key in pairs(result) do -- 1172
		if key ~= "messages" then -- 1172
			projected[key] = result[key] -- 1173
		end -- 1173
	end -- 1173
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1175
	local shown = math.min(#result.messages, maxMessages) -- 1176
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1177
	if #result.messages > shown then -- 1177
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1179
	end -- 1179
	return projected -- 1181
end -- 1181
function projectCommandResultForLLM(result) -- 1184
	local projected = {} -- 1185
	for key in pairs(result) do -- 1186
		local value = result[key] -- 1187
		if key == "output" and type(value) == "string" then -- 1187
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1189
		elseif key == "message" and type(value) == "string" then -- 1189
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1195
		else -- 1195
			projected[key] = value -- 1201
		end -- 1201
	end -- 1201
	return projected -- 1204
end -- 1204
function projectToolResultContentForLLM(tool, content) -- 1207
	local decoded = AgentUtils.safeJsonDecode(content) -- 1208
	if not isRecord(decoded) or isArray(decoded) then -- 1208
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1210
	end -- 1210
	local projected = decoded -- 1216
	if tool == "edit_file" or tool == "delete_file" then -- 1216
		projected = projectEditResultForLLM(decoded) -- 1218
	elseif tool == "build" then -- 1218
		projected = projectBuildResultForLLM(decoded) -- 1220
	elseif tool == "execute_command" then -- 1220
		projected = projectCommandResultForLLM(decoded) -- 1222
	end -- 1222
	local encoded = toJson(projected, false) -- 1224
	if tool == "read_file" then -- 1224
		return encoded -- 1227
	end -- 1227
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1227
		return encoded -- 1228
	end -- 1228
	local fallback = { -- 1229
		success = projected.success, -- 1230
		llmHistoryTruncated = true, -- 1231
		originalChars = #encoded, -- 1232
		preview = truncateHistoryText( -- 1233
			encoded, -- 1234
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1235
			tool .. " result" -- 1236
		) -- 1236
	} -- 1236
	return toJson(fallback, false) -- 1239
end -- 1239
function projectMessagesForLLMContext(messages) -- 1242
	local projected = {} -- 1246
	do -- 1246
		local i = 0 -- 1247
		while i < #messages do -- 1247
			local message = messages[i + 1] -- 1248
			local next = __TS__ObjectAssign({}, message) -- 1249
			if message.role == "tool" and type(message.content) == "string" then -- 1249
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1251
			end -- 1251
			projected[#projected + 1] = next -- 1253
			i = i + 1 -- 1247
		end -- 1247
	end -- 1247
	return projected -- 1255
end -- 1255
function ____exports.getDecisionDisabledAgentTools(shared) -- 1283
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1287
end -- 1283
function getDecisionToolDefinitions(shared) -- 1290
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1291
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1292
	local base = shared.promptPack.toolDefinitionsDetailed -- 1295
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1296
	if usesDefaultToolPrompts then -- 1296
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1299
			shared.role, -- 1299
			{ -- 1299
				includeFinish = true, -- 1300
				includeXmlRules = true, -- 1301
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1302
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1303
				workMode = shared.workMode -- 1304
			} -- 1304
		) -- 1304
		return replacePromptVars(definitions, params) -- 1306
	end -- 1306
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1308
	if (shared and shared.decisionMode) ~= "xml" then -- 1308
		return withRole -- 1313
	end -- 1313
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1315
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1316
end -- 1316
function isToolAllowedForRole(shared, tool) -- 1330
	return __TS__ArrayIndexOf( -- 1331
		AgentToolRegistry.getAllowedToolsForRole( -- 1331
			shared.role, -- 1331
			{ -- 1331
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1332
				workMode = shared.workMode -- 1333
			} -- 1333
		), -- 1333
		tool -- 1334
	) >= 0 -- 1334
end -- 1334
function getFinishMessage(params, fallback) -- 1797
	if fallback == nil then -- 1797
		fallback = "" -- 1797
	end -- 1797
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1797
		return __TS__StringTrim(params.message) -- 1799
	end -- 1799
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1799
		return __TS__StringTrim(params.response) -- 1802
	end -- 1802
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1802
		return __TS__StringTrim(params.summary) -- 1805
	end -- 1805
	return __TS__StringTrim(fallback) -- 1807
end -- 1807
function getCompletionReport(params) -- 1810
	return AgentUtils.normalizeAgentCompletionReport(params) -- 1811
end -- 1811
function persistHistoryState(shared) -- 1814
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1815
end -- 1815
function getActiveConversationMessages(shared) -- 1822
	local activeMessages = {} -- 1823
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1823
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1830
	end -- 1830
	do -- 1830
		local i = shared.lastConsolidatedIndex -- 1834
		while i < #shared.messages do -- 1834
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1835
			i = i + 1 -- 1834
		end -- 1834
	end -- 1834
	return activeMessages -- 1837
end -- 1837
function getActiveRealMessageCount(shared) -- 1840
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1841
end -- 1841
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1844
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1850
	local previousActiveStart = shared.lastConsolidatedIndex -- 1851
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1852
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1853
	if type(carryMessageIndex) == "number" then -- 1853
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1853
		else -- 1853
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1861
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1864
		end -- 1864
	else -- 1864
		shared.carryMessageIndex = nil -- 1869
	end -- 1869
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1869
		shared.carryMessageIndex = nil -- 1879
	end -- 1879
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1887
	shared.resumeCheckpointPending = true -- 1888
	shared.resumeRequiredTool = nil -- 1889
	shared.resumeNarrowReadMode = true -- 1890
	if shared.unbuiltEdits == true then -- 1890
		shared.resumeRequiredTool = "build" -- 1898
	end -- 1898
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 -- 1907
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1907
		local marker = "**Next tool**:" -- 1918
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1919
		if markerIndex >= 0 then -- 1919
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1921
			local toolNames = { -- 1922
				"read_file", -- 1923
				"edit_file", -- 1923
				"delete_file", -- 1923
				"grep_files", -- 1923
				"search_dora_api", -- 1923
				"glob_files", -- 1924
				"build", -- 1924
				"fetch_url", -- 1924
				"execute_command", -- 1924
				"list_sub_agents", -- 1924
				"spawn_sub_agent", -- 1925
				"finish" -- 1925
			} -- 1925
			do -- 1925
				local i = 0 -- 1927
				while i < #toolNames do -- 1927
					local tool = toolNames[i + 1] -- 1928
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1928
						shared.resumeRequiredTool = tool -- 1930
						break -- 1931
					end -- 1931
					i = i + 1 -- 1927
				end -- 1927
			end -- 1927
		end -- 1927
	end -- 1927
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1927
		shared.resumeRequiredTool = nil -- 1937
	end -- 1937
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1937
		shared.resumeRequiredTool = nil -- 1940
	end -- 1940
end -- 1940
function ensureToolCallId(toolCallId) -- 1955
	if toolCallId and toolCallId ~= "" then -- 1955
		return toolCallId -- 1956
	end -- 1956
	return AgentUtils.createLocalToolCallId() -- 1957
end -- 1957
function hasXMLParam(params, name) -- 1990
	return params[name] ~= nil -- 1991
end -- 1991
function inferToolNameFromXMLParams(params) -- 1994
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1994
		return "edit_file" -- 1996
	end -- 1996
	if hasXMLParam(params, "target_file") then -- 1996
		return "delete_file" -- 1999
	end -- 1999
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1999
		if hasXMLParam(params, "path") then -- 1999
			return "read_file" -- 2002
		end -- 2002
		return nil -- 2003
	end -- 2003
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 2003
		if hasXMLParam(params, "pattern") then -- 2003
			return "search_dora_api" -- 2006
		end -- 2006
		return nil -- 2007
	end -- 2007
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 2007
		if hasXMLParam(params, "pattern") then -- 2007
			return "grep_files" -- 2010
		end -- 2010
		return nil -- 2011
	end -- 2011
	if hasXMLParam(params, "globs") then -- 2011
		if hasXMLParam(params, "pattern") then -- 2011
			return "grep_files" -- 2014
		end -- 2014
		return "glob_files" -- 2015
	end -- 2015
	if hasXMLParam(params, "maxEntries") then -- 2015
		return "glob_files" -- 2018
	end -- 2018
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2018
		return "finish" -- 2021
	end -- 2021
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 2021
		return "spawn_sub_agent" -- 2024
	end -- 2024
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 2024
		return "list_sub_agents" -- 2027
	end -- 2027
	return nil -- 2029
end -- 2029
function parseDSMLAttribute(source, offset, name) -- 2032
	local attrOpen = name .. "=\"" -- 2033
	local attrStart = (string.find( -- 2034
		source, -- 2034
		attrOpen, -- 2034
		math.max(offset + 1, 1), -- 2034
		true -- 2034
	) or 0) - 1 -- 2034
	if attrStart < 0 then -- 2034
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 2035
	end -- 2035
	local valueStart = attrStart + #attrOpen -- 2036
	local valueEnd = (string.find( -- 2037
		source, -- 2037
		"\"", -- 2037
		math.max(valueStart + 1, 1), -- 2037
		true -- 2037
	) or 0) - 1 -- 2037
	if valueEnd < 0 then -- 2037
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 2038
	end -- 2038
	return { -- 2039
		success = true, -- 2040
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 2041
		next = valueEnd + 1 -- 2042
	} -- 2042
end -- 2042
function extractDSMLReason(text, invokeStart, tool) -- 2046
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2047
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2048
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2048
		return before -- 2051
	end -- 2051
	if tool == "finish" then -- 2051
		return "" -- 2052
	end -- 2052
	return "Converted provider-native tool call syntax to XML." -- 2053
end -- 2053
function parseDSMLToolCallObjectFromText(text) -- 2056
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2057
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2058
	if invokeStart < 0 then -- 2058
		return {success = false, message = "missing DSML invoke"} -- 2059
	end -- 2059
	local nameStart = invokeStart + #invokeOpen -- 2060
	local nameEnd = (string.find( -- 2061
		text, -- 2061
		"\"", -- 2061
		math.max(nameStart + 1, 1), -- 2061
		true -- 2061
	) or 0) - 1 -- 2061
	if nameEnd < 0 then -- 2061
		return {success = false, message = "unterminated DSML invoke name"} -- 2062
	end -- 2062
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2063
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2063
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2065
	end -- 2065
	local invokeOpenEnd = (string.find( -- 2067
		text, -- 2067
		">", -- 2067
		math.max(nameEnd + 1, 1), -- 2067
		true -- 2067
	) or 0) - 1 -- 2067
	if invokeOpenEnd < 0 then -- 2067
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2068
	end -- 2068
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2069
	local invokeEnd = (string.find( -- 2070
		text, -- 2070
		invokeClose, -- 2070
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2070
		true -- 2070
	) or 0) - 1 -- 2070
	if invokeEnd < 0 then -- 2070
		return {success = false, message = "missing DSML invoke close tag"} -- 2071
	end -- 2071
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2073
	local params = {} -- 2074
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2075
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2076
	local pos = 0 -- 2077
	while pos < #body do -- 2077
		local start = (string.find( -- 2079
			body, -- 2079
			paramOpen, -- 2079
			math.max(pos + 1, 1), -- 2079
			true -- 2079
		) or 0) - 1 -- 2079
		if start < 0 then -- 2079
			break -- 2080
		end -- 2080
		local openEnd = (string.find( -- 2081
			body, -- 2081
			">", -- 2081
			math.max(start + #paramOpen + 1, 1), -- 2081
			true -- 2081
		) or 0) - 1 -- 2081
		if openEnd < 0 then -- 2081
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2082
		end -- 2082
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2083
		if not name.success then -- 2083
			return name -- 2084
		end -- 2084
		local close = (string.find( -- 2085
			body, -- 2085
			paramClose, -- 2085
			math.max(openEnd + 1 + 1, 1), -- 2085
			true -- 2085
		) or 0) - 1 -- 2085
		if close < 0 then -- 2085
			return {success = false, message = "missing DSML parameter close tag"} -- 2086
		end -- 2086
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2087
		pos = close + #paramClose -- 2088
	end -- 2088
	return { -- 2090
		success = true, -- 2091
		obj = { -- 2092
			tool = toolName, -- 2093
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2094
			params = params -- 2095
		} -- 2095
	} -- 2095
end -- 2095
function parseXMLToolCallObjectFromText(text) -- 2100
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2101
	local rawObj -- 2102
	if children.success then -- 2102
		rawObj = children.obj -- 2104
	else -- 2104
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2106
		if dsml.success then -- 2106
			return dsml -- 2107
		end -- 2107
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2108
		local paramsCloseToken = "</params>" -- 2109
		if toolStart >= 0 then -- 2109
			local paramsClose = (string.find( -- 2111
				text, -- 2111
				paramsCloseToken, -- 2111
				math.max(toolStart + 1, 1), -- 2111
				true -- 2111
			) or 0) - 1 -- 2111
			if paramsClose >= toolStart then -- 2111
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2113
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2114
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2114
					rawObj = bare.obj -- 2116
				end -- 2116
			end -- 2116
		end -- 2116
		if rawObj == nil then -- 2116
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2121
			if paramsOpen < 0 then -- 2121
				return children -- 2122
			end -- 2122
			local paramsCloseOnly = (string.find( -- 2123
				text, -- 2123
				paramsCloseToken, -- 2123
				math.max(paramsOpen + 1, 1), -- 2123
				true -- 2123
			) or 0) - 1 -- 2123
			if paramsCloseOnly < paramsOpen then -- 2123
				return children -- 2124
			end -- 2124
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2125
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2126
			if not paramsOnly.success then -- 2126
				return children -- 2127
			end -- 2127
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2128
			if inferredTool == nil then -- 2128
				return children -- 2129
			end -- 2129
			local ____temp_50 -- 2134
			if inferredTool == "finish" then -- 2134
				____temp_50 = nil -- 2134
			else -- 2134
				____temp_50 = "Inferred tool from XML params." -- 2134
			end -- 2134
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2130
		end -- 2130
	end -- 2130
	if rawObj == nil then -- 2130
		return children -- 2140
	end -- 2140
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2141
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2142
	if not params.success then -- 2142
		return {success = false, message = params.message} -- 2146
	end -- 2146
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2148
end -- 2148
function parseDecisionObject(rawObj) -- 2244
	if type(rawObj.tool) ~= "string" then -- 2244
		return {success = false, message = "missing tool"} -- 2245
	end -- 2245
	local tool = rawObj.tool -- 2246
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2246
		return {success = false, message = "unknown tool: " .. tool} -- 2248
	end -- 2248
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2250
	if tool ~= "finish" and (not reason or reason == "") then -- 2250
		return {success = false, message = tool .. " requires top-level reason"} -- 2254
	end -- 2254
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2256
	return {success = true, tool = tool, params = params, reason = reason} -- 2257
end -- 2257
function getDecisionPath(params) -- 2379
	if type(params.path) == "string" then -- 2379
		return __TS__StringTrim(params.path) -- 2380
	end -- 2380
	if type(params.target_file) == "string" then -- 2380
		return __TS__StringTrim(params.target_file) -- 2381
	end -- 2381
	return "" -- 2382
end -- 2382
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2385
	if enforceFinalTurn == nil then -- 2385
		enforceFinalTurn = false -- 2389
	end -- 2389
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2389
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2392
	end -- 2392
	if not isToolAllowedForRole(shared, tool) then -- 2392
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2395
	end -- 2395
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2395
		local path = getDecisionPath(params) -- 2398
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2398
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2400
		end -- 2400
	end -- 2400
	if tool == "delete_file" then -- 2400
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2404
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2404
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2406
		end -- 2406
	end -- 2406
	return {success = true} -- 2409
end -- 2409
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2412
	local num = __TS__Number(value) -- 2413
	if not __TS__NumberIsFinite(num) then -- 2413
		num = fallback -- 2414
	end -- 2414
	num = math.floor(num) -- 2415
	if num < minValue then -- 2415
		num = minValue -- 2416
	end -- 2416
	if maxValue ~= nil and num > maxValue then -- 2416
		num = maxValue -- 2417
	end -- 2417
	return num -- 2418
end -- 2418
function parseReadLineParam(value, fallback, paramName) -- 2421
	local num = __TS__Number(value) -- 2426
	if not __TS__NumberIsFinite(num) then -- 2426
		num = fallback -- 2427
	end -- 2427
	num = math.floor(num) -- 2428
	if num == 0 then -- 2428
		return {success = false, message = paramName .. " cannot be 0"} -- 2430
	end -- 2430
	return {success = true, value = num} -- 2432
end -- 2432
function validateDecision(tool, params) -- 2435
	if tool == "finish" then -- 2435
		local message = getFinishMessage(params) -- 2440
		if message == "" then -- 2440
			return {success = false, message = "finish requires params.message"} -- 2441
		end -- 2441
		params.message = message -- 2442
		local completion = getCompletionReport(params) -- 2443
		params.outcome = completion.outcome -- 2444
		params.validation = completion.validation -- 2445
		params.knownIssues = completion.knownIssues -- 2446
		params.assumptions = completion.assumptions -- 2447
		params.learningCandidates = completion.learningCandidates -- 2448
		return {success = true, params = params} -- 2449
	end -- 2449
	if tool == "ask_user" then -- 2449
		local normalized = normalizeQuestionnaire(params) -- 2453
		if not normalized.success then -- 2453
			return normalized -- 2454
		end -- 2454
		return {success = true, params = normalized.schema} -- 2455
	end -- 2455
	if tool == "read_file" then -- 2455
		local path = getDecisionPath(params) -- 2459
		if path == "" then -- 2459
			return {success = false, message = "read_file requires path"} -- 2460
		end -- 2460
		params.path = path -- 2461
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2462
		if not startLineRes.success then -- 2462
			return startLineRes -- 2463
		end -- 2463
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2464
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2465
		if not endLineRes.success then -- 2465
			return endLineRes -- 2466
		end -- 2466
		params.startLine = startLineRes.value -- 2467
		params.endLine = endLineRes.value -- 2468
		return {success = true, params = params} -- 2469
	end -- 2469
	if tool == "edit_file" then -- 2469
		local path = getDecisionPath(params) -- 2473
		if path == "" then -- 2473
			return {success = false, message = "edit_file requires path"} -- 2474
		end -- 2474
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2475
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2476
		params.path = path -- 2477
		params.old_str = oldStr -- 2478
		params.new_str = newStr -- 2479
		return {success = true, params = params} -- 2480
	end -- 2480
	if tool == "delete_file" then -- 2480
		local targetFile = getDecisionPath(params) -- 2484
		if targetFile == "" then -- 2484
			return {success = false, message = "delete_file requires target_file"} -- 2485
		end -- 2485
		params.target_file = targetFile -- 2486
		return {success = true, params = params} -- 2487
	end -- 2487
	if tool == "grep_files" then -- 2487
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2491
		if pattern == "" then -- 2491
			return {success = false, message = "grep_files requires pattern"} -- 2492
		end -- 2492
		params.pattern = pattern -- 2493
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2494
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2495
		return {success = true, params = params} -- 2496
	end -- 2496
	if tool == "search_dora_api" then -- 2496
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2500
		if pattern == "" then -- 2500
			return {success = false, message = "search_dora_api requires pattern"} -- 2501
		end -- 2501
		params.pattern = pattern -- 2502
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2503
		return {success = true, params = params} -- 2504
	end -- 2504
	if tool == "glob_files" then -- 2504
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2508
		return {success = true, params = params} -- 2509
	end -- 2509
	if tool == "build" then -- 2509
		local path = getDecisionPath(params) -- 2513
		if path ~= "" then -- 2513
			params.path = path -- 2515
		end -- 2515
		return {success = true, params = params} -- 2517
	end -- 2517
	if tool == "list_sub_agents" then -- 2517
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2521
		if status ~= "" then -- 2521
			params.status = status -- 2523
		end -- 2523
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2525
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2526
		if type(params.query) == "string" then -- 2526
			params.query = __TS__StringTrim(params.query) -- 2528
		end -- 2528
		return {success = true, params = params} -- 2530
	end -- 2530
	if tool == "spawn_sub_agent" then -- 2530
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2534
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2535
		if prompt == "" then -- 2535
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2536
		end -- 2536
		if title == "" then -- 2536
			return {success = false, message = "spawn_sub_agent requires title"} -- 2537
		end -- 2537
		params.prompt = prompt -- 2538
		params.title = title -- 2539
		if type(params.expectedOutput) == "string" then -- 2539
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2541
		end -- 2541
		if isArray(params.filesHint) then -- 2541
			params.filesHint = __TS__ArrayMap( -- 2544
				__TS__ArrayFilter( -- 2544
					params.filesHint, -- 2544
					function(____, item) return type(item) == "string" end -- 2545
				), -- 2545
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2546
			) -- 2546
		end -- 2546
		return {success = true, params = params} -- 2548
	end -- 2548
	return {success = true, params = params} -- 2551
end -- 2551
function validateCompletionForRole(role, tool, params) -- 2554
	if role ~= "sub" or tool ~= "finish" then -- 2554
		return {success = true} -- 2559
	end -- 2559
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2559
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2561
	end -- 2561
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2563
	do -- 2563
		local i = 0 -- 2564
		while i < #requiredArrays do -- 2564
			local name = requiredArrays[i + 1] -- 2565
			if not isArray(params[name]) then -- 2565
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2567
			end -- 2567
			i = i + 1 -- 2564
		end -- 2564
	end -- 2564
	return {success = true} -- 2570
end -- 2570
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2573
	if includeToolDefinitions == nil then -- 2573
		includeToolDefinitions = false -- 2573
	end -- 2573
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2574
	local sections = { -- 2577
		shared.promptPack.agentIdentityPrompt, -- 2578
		rolePrompt, -- 2579
		getReplyLanguageDirective(shared) -- 2580
	} -- 2580
	if shared.role == "main" then -- 2580
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2583
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2584
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2584
			sections[#sections + 1] = table.concat( -- 2586
				{ -- 2586
					"# Current Living Development Plan", -- 2587
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2588
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2588
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2589
						12000 -- 2589
					), -- 2589
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2589
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2590
						12000 -- 2590
					) -- 2590
				}, -- 2590
				"\n\n" -- 2591
			) -- 2591
		end -- 2591
	end -- 2591
	if shared.decisionMode == "tool_calling" then -- 2591
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2595
	end -- 2595
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2597
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2598
	if memoryContext ~= "" then -- 2598
		sections[#sections + 1] = memoryContext -- 2600
	end -- 2600
	local skillsSection = buildSkillsSection(shared) -- 2602
	if skillsSection ~= "" then -- 2602
		sections[#sections + 1] = skillsSection -- 2604
	end -- 2604
	if includeToolDefinitions then -- 2604
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2607
		if shared.decisionMode == "xml" then -- 2607
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2609
		end -- 2609
	end -- 2609
	return table.concat(sections, "\n\n") -- 2612
end -- 2612
function buildSkillsSection(shared) -- 2615
	local ____opt_69 = shared.skills -- 2615
	if not (____opt_69 and ____opt_69.loader) then -- 2615
		return "" -- 2617
	end -- 2617
	return shared.skills.loader:buildSkillsPromptSection() -- 2619
end -- 2619
function sanitizeMessagesForLLMInput(messages) -- 2622
	local sanitized = {} -- 2623
	local droppedAssistantToolCalls = 0 -- 2624
	local droppedToolResults = 0 -- 2625
	do -- 2625
		local i = 0 -- 2626
		while i < #messages do -- 2626
			do -- 2626
				local message = messages[i + 1] -- 2627
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2627
					local requiredIds = {} -- 2629
					do -- 2629
						local j = 0 -- 2630
						while j < #message.tool_calls do -- 2630
							local toolCall = message.tool_calls[j + 1] -- 2631
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2632
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2632
								requiredIds[#requiredIds + 1] = id -- 2634
							end -- 2634
							j = j + 1 -- 2630
						end -- 2630
					end -- 2630
					if #requiredIds == 0 then -- 2630
						sanitized[#sanitized + 1] = message -- 2638
						goto __continue453 -- 2639
					end -- 2639
					local matchedIds = {} -- 2641
					local matchedTools = {} -- 2642
					local j = i + 1 -- 2643
					while j < #messages do -- 2643
						local toolMessage = messages[j + 1] -- 2645
						if toolMessage.role ~= "tool" then -- 2645
							break -- 2646
						end -- 2646
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2647
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2647
							matchedIds[toolCallId] = true -- 2649
							matchedTools[#matchedTools + 1] = toolMessage -- 2650
						else -- 2650
							droppedToolResults = droppedToolResults + 1 -- 2652
						end -- 2652
						j = j + 1 -- 2654
					end -- 2654
					local complete = true -- 2656
					do -- 2656
						local j = 0 -- 2657
						while j < #requiredIds do -- 2657
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2657
								complete = false -- 2659
								break -- 2660
							end -- 2660
							j = j + 1 -- 2657
						end -- 2657
					end -- 2657
					if complete then -- 2657
						__TS__ArrayPush( -- 2664
							sanitized, -- 2664
							message, -- 2664
							table.unpack(matchedTools) -- 2664
						) -- 2664
					else -- 2664
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2666
						droppedToolResults = droppedToolResults + #matchedTools -- 2667
					end -- 2667
					i = j - 1 -- 2669
					goto __continue453 -- 2670
				end -- 2670
				if message.role == "tool" then -- 2670
					droppedToolResults = droppedToolResults + 1 -- 2673
					goto __continue453 -- 2674
				end -- 2674
				sanitized[#sanitized + 1] = message -- 2676
			end -- 2676
			::__continue453:: -- 2676
			i = i + 1 -- 2626
		end -- 2626
	end -- 2626
	return sanitized -- 2678
end -- 2678
function getUnconsolidatedMessages(shared) -- 2681
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2682
end -- 2682
function isFinalDecisionTurn(shared) -- 2687
	return shared.agentStepCount + 1 >= shared.maxSteps -- 2688
end -- 2688
function getFinalDecisionTurnPrompt(shared) -- 2691
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2692
end -- 2692
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2697
	if attempt == nil then -- 2697
		attempt = 1 -- 2700
	end -- 2700
	if decisionMode == nil then -- 2700
		decisionMode = shared.decisionMode -- 2702
	end -- 2702
	if consumeResumeCheckpoint == nil then -- 2702
		consumeResumeCheckpoint = true -- 2703
	end -- 2703
	if pendingUserPrompt == nil then -- 2703
		pendingUserPrompt = "" -- 2704
	end -- 2704
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2706
	local tailSections = {} -- 2707
	if shared.resumeCheckpointPending == true then -- 2707
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2713
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2717
	end -- 2717
	if shared.truncatedToolOverwritePath ~= nil then -- 2717
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2720
	end -- 2720
	if consumeResumeCheckpoint then -- 2720
		shared.resumeCheckpointPending = false -- 2722
	end -- 2722
	local messages = { -- 2723
		{role = "system", content = systemPrompt}, -- 2724
		table.unpack(getUnconsolidatedMessages(shared)) -- 2725
	} -- 2725
	if pendingUserPrompt ~= "" then -- 2725
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2728
	end -- 2728
	if isFinalDecisionTurn(shared) then -- 2728
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2731
	end -- 2731
	if lastError and lastError ~= "" then -- 2731
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2734
		if decisionMode == "xml" then -- 2734
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2738
		end -- 2738
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2738
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2741
		end -- 2741
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2741
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2744
		end -- 2744
		messages[#messages + 1] = { -- 2746
			role = "user", -- 2747
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2748
		} -- 2748
	end -- 2748
	if #tailSections > 0 then -- 2748
		messages[#messages + 1] = { -- 2756
			role = "user", -- 2757
			content = table.concat(tailSections, "\n\n") -- 2758
		} -- 2758
	end -- 2758
	return messages -- 2761
end -- 2761
function buildXmlDecisionInstruction(shared, feedback) -- 2764
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2765
end -- 2765
function tryParseAndValidateDecision(rawText, shared) -- 2833
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2834
	if not parsed.success then -- 2834
		return {success = false, message = parsed.message, raw = rawText} -- 2836
	end -- 2836
	local decision = parseDecisionObject(parsed.obj) -- 2838
	if not decision.success then -- 2838
		return {success = false, message = decision.message, raw = rawText} -- 2840
	end -- 2840
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2842
	if not completionValidation.success then -- 2842
		return {success = false, message = completionValidation.message, raw = rawText} -- 2844
	end -- 2844
	local validation = validateDecision(decision.tool, decision.params) -- 2846
	if not validation.success then -- 2846
		return {success = false, message = validation.message, raw = rawText} -- 2848
	end -- 2848
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2850
	if not sharedValidation.success then -- 2850
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2852
	end -- 2852
	decision.params = validation.params -- 2854
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2855
	return decision -- 2856
end -- 2856
function executeToolAction(shared, action) -- 4027
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4027
		if shared.stopToken.stopped then -- 4027
			return ____awaiter_resolve( -- 4027
				nil, -- 4027
				{ -- 4029
					success = false, -- 4029
					message = getCancelledReason(shared) -- 4029
				} -- 4029
			) -- 4029
		end -- 4029
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4029
			shared.resumeRequiredTool = nil -- 4032
			shared.resumeCheckpointPending = false -- 4033
		end -- 4033
		local params = action.params -- 4035
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4036
		if not sharedValidation.success then -- 4036
			return ____awaiter_resolve(nil, sharedValidation) -- 4036
		end -- 4036
		if action.tool == "read_file" then -- 4036
			local ____params_startLine_149 = params.startLine -- 4039
			if ____params_startLine_149 == nil then -- 4039
				____params_startLine_149 = 1 -- 4039
			end -- 4039
			local startLine = __TS__Number(____params_startLine_149) -- 4039
			local ____params_endLine_150 = params.endLine -- 4040
			if ____params_endLine_150 == nil then -- 4040
				____params_endLine_150 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4040
			end -- 4040
			local endLine = __TS__Number(____params_endLine_150) -- 4040
			local clippedAfterCompression = false -- 4041
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4041
				endLine = startLine + 159 -- 4048
				clippedAfterCompression = true -- 4049
			end -- 4049
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4051
			if __TS__StringTrim(path) == "" then -- 4051
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4051
			end -- 4051
			local result = Tools.readFile( -- 4055
				shared.workingDir, -- 4056
				path, -- 4057
				startLine, -- 4058
				endLine, -- 4059
				shared.useChineseResponse and "zh" or "en" -- 4060
			) -- 4060
			if clippedAfterCompression and result.success == true then -- 4060
				result.clipped = true -- 4063
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4064
			end -- 4064
			return ____awaiter_resolve(nil, result) -- 4064
		end -- 4064
		if action.tool == "grep_files" then -- 4064
			local searchPath = params.path or "" -- 4071
			local searchGlobs = params.globs -- 4072
			local ____Tools_searchFiles_164 = Tools.searchFiles -- 4073
			local ____shared_workingDir_157 = shared.workingDir -- 4074
			local ____temp_158 = params.pattern or "" -- 4076
			local ____params_globs_159 = params.globs -- 4077
			local ____params_useRegex_160 = params.useRegex -- 4078
			local ____params_caseSensitive_161 = params.caseSensitive -- 4079
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4081
			local ____math_max_153 = math.max -- 4082
			local ____math_floor_152 = math.floor -- 4082
			local ____params_limit_151 = params.limit -- 4082
			if ____params_limit_151 == nil then -- 4082
				____params_limit_151 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4082
			end -- 4082
			local ____math_max_153_result_163 = ____math_max_153( -- 4082
				1, -- 4082
				____math_floor_152(__TS__Number(____params_limit_151)) -- 4082
			) -- 4082
			local ____math_max_156 = math.max -- 4083
			local ____math_floor_155 = math.floor -- 4083
			local ____params_offset_154 = params.offset -- 4083
			if ____params_offset_154 == nil then -- 4083
				____params_offset_154 = 0 -- 4083
			end -- 4083
			local result = __TS__Await(____Tools_searchFiles_164({ -- 4073
				workDir = ____shared_workingDir_157, -- 4074
				path = searchPath, -- 4075
				pattern = ____temp_158, -- 4076
				globs = ____params_globs_159, -- 4077
				useRegex = ____params_useRegex_160, -- 4078
				caseSensitive = ____params_caseSensitive_161, -- 4079
				includeContent = true, -- 4080
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162, -- 4081
				limit = ____math_max_153_result_163, -- 4082
				offset = ____math_max_156( -- 4083
					0, -- 4083
					____math_floor_155(__TS__Number(____params_offset_154)) -- 4083
				), -- 4083
				groupByFile = params.groupByFile == true -- 4084
			})) -- 4084
			return ____awaiter_resolve(nil, result) -- 4084
		end -- 4084
		if action.tool == "search_dora_api" then -- 4084
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4089
			local ____Tools_searchDoraAPI_173 = Tools.searchDoraAPI -- 4090
			local ____temp_169 = params.pattern or "" -- 4091
			local ____temp_170 = params.docSource or "api" -- 4092
			local ____temp_171 = shared.useChineseResponse and "zh" or "en" -- 4093
			local ____temp_172 = params.programmingLanguage or "ts" -- 4094
			local ____math_min_168 = math.min -- 4095
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4095
			local ____math_max_166 = math.max -- 4095
			local ____params_limit_165 = params.limit -- 4095
			if ____params_limit_165 == nil then -- 4095
				____params_limit_165 = 8 -- 4095
			end -- 4095
			local result = __TS__Await(____Tools_searchDoraAPI_173({ -- 4090
				pattern = ____temp_169, -- 4091
				docSource = ____temp_170, -- 4092
				docLanguage = ____temp_171, -- 4093
				programmingLanguage = ____temp_172, -- 4094
				limit = ____math_min_168( -- 4095
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167, -- 4095
					____math_max_166( -- 4095
						1, -- 4095
						__TS__Number(____params_limit_165) -- 4095
					) -- 4095
				), -- 4095
				useRegex = params.useRegex, -- 4096
				caseSensitive = false, -- 4097
				includeContent = true, -- 4098
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4099
			})) -- 4099
			return ____awaiter_resolve(nil, result) -- 4099
		end -- 4099
		if action.tool == "glob_files" then -- 4099
			local ____Tools_listFiles_180 = Tools.listFiles -- 4104
			local ____shared_workingDir_177 = shared.workingDir -- 4105
			local ____temp_178 = params.path or "" -- 4106
			local ____params_globs_179 = params.globs -- 4107
			local ____math_max_176 = math.max -- 4108
			local ____math_floor_175 = math.floor -- 4108
			local ____params_maxEntries_174 = params.maxEntries -- 4108
			if ____params_maxEntries_174 == nil then -- 4108
				____params_maxEntries_174 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4108
			end -- 4108
			local result = ____Tools_listFiles_180({ -- 4104
				workDir = ____shared_workingDir_177, -- 4105
				path = ____temp_178, -- 4106
				globs = ____params_globs_179, -- 4107
				maxEntries = ____math_max_176( -- 4108
					1, -- 4108
					____math_floor_175(__TS__Number(____params_maxEntries_174)) -- 4108
				) -- 4108
			}) -- 4108
			return ____awaiter_resolve(nil, result) -- 4108
		end -- 4108
		if action.tool == "ask_user" then -- 4108
			if not shared.publishQuestionnaire then -- 4108
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4108
			end -- 4108
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4108
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4108
			end -- 4108
			local normalized = normalizeQuestionnaire(params) -- 4115
			if not normalized.success then -- 4115
				return ____awaiter_resolve(nil, normalized) -- 4115
			end -- 4115
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4117
			if not result.success then -- 4117
				return ____awaiter_resolve(nil, result) -- 4117
			end -- 4117
			shared.waitingQuestionnaireId = result.questionnaireId -- 4124
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4124
		end -- 4124
		if action.tool == "delete_file" then -- 4124
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4128
			if __TS__StringTrim(targetFile) == "" then -- 4128
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4128
			end -- 4128
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4132
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4133
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4133
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4133
			end -- 4133
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4137
			local result = Tools.deleteFile(shared.taskId, shared.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4138
			if not result.success then -- 4138
				return ____awaiter_resolve(nil, result) -- 4138
			end -- 4138
			if not isInternalDocumentEdit then -- 4138
				shared.unbuiltEdits = true -- 4146
				shared.lastBuildSucceeded = false -- 4147
				if shared.failedTestNeedsBuild == true then -- 4147
					shared.failedTestHasSourceEdit = true -- 4148
				end -- 4148
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4148
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4149
				end -- 4149
				shared.editedPathsSinceBuild = editedPaths -- 4150
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4151
			end -- 4151
			local ____result_checkpointed_182 = result.checkpointed -- 4157
			local ____result_reversible_183 = result.reversible -- 4158
			local ____result_binary_184 = result.binary -- 4159
			local ____temp_185 = result.checkpointed and result.checkpointId or nil -- 4160
			local ____temp_186 = result.checkpointed and result.checkpointSeq or nil -- 4161
			local ____result_checkpointed_181 -- 4162
			if result.checkpointed then -- 4162
				____result_checkpointed_181 = nil -- 4162
			else -- 4162
				____result_checkpointed_181 = result.message -- 4162
			end -- 4162
			return ____awaiter_resolve(nil, { -- 4162
				success = true, -- 4154
				changed = true, -- 4155
				mode = "delete", -- 4156
				checkpointed = ____result_checkpointed_182, -- 4157
				reversible = ____result_reversible_183, -- 4158
				binary = ____result_binary_184, -- 4159
				checkpointId = ____temp_185, -- 4160
				checkpointSeq = ____temp_186, -- 4161
				message = ____result_checkpointed_181, -- 4162
				files = {{path = targetFile, op = "delete"}} -- 4163
			}) -- 4163
		end -- 4163
		if action.tool == "build" then -- 4163
			local buildPath = params.path or "" -- 4167
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4168
			shared.unbuiltEdits = false -- 4172
			shared.editsSinceBuild = 0 -- 4173
			shared.editedPathsSinceBuild = {} -- 4174
			shared.hasBuilt = true -- 4175
			shared.lastBuildSucceeded = result.success -- 4176
			if result.success and shared.freshProjectBuildPending == true then -- 4176
				shared.freshProjectBuildPending = false -- 4182
			end -- 4182
			shared.apiSearchesSinceBuild = 0 -- 4184
			shared.buildRepairPending = false -- 4185
			if not result.success and result.messages ~= nil then -- 4185
				do -- 4185
					local i = 0 -- 4187
					while i < #result.messages do -- 4187
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4187
							shared.buildRepairPending = true -- 4189
							break -- 4190
						end -- 4190
						i = i + 1 -- 4187
					end -- 4187
				end -- 4187
			end -- 4187
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4187
				shared.failedTestNeedsBuild = false -- 4195
				shared.failedTestHasSourceEdit = false -- 4196
			end -- 4196
			return ____awaiter_resolve(nil, result) -- 4196
		end -- 4196
		if action.tool == "fetch_url" then -- 4196
			local result = __TS__Await(Tools.fetchUrl({ -- 4201
				workDir = shared.workingDir, -- 4202
				url = type(params.url) == "string" and params.url or "", -- 4203
				target = type(params.target) == "string" and params.target or "", -- 4204
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4205
				onProgress = function(____, progress) -- 4206
					emitAgentEvent( -- 4207
						shared, -- 4207
						{ -- 4207
							type = "tool_progress", -- 4208
							sessionId = shared.sessionId, -- 4209
							taskId = shared.taskId, -- 4210
							step = action.step, -- 4211
							tool = action.tool, -- 4212
							result = __TS__ObjectAssign({success = false}, progress) -- 4213
						} -- 4213
					) -- 4213
				end -- 4206
			})) -- 4206
			return ____awaiter_resolve(nil, result) -- 4206
		end -- 4206
		if action.tool == "execute_command" then -- 4206
			local mode = type(params.mode) == "string" and params.mode or "" -- 4223
			local result = __TS__Await(Tools.executeCommand({ -- 4224
				workDir = shared.workingDir, -- 4225
				mode = mode, -- 4226
				code = type(params.code) == "string" and params.code or nil, -- 4227
				command = type(params.command) == "string" and params.command or nil, -- 4228
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4229
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4230
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4231
				onProgress = function(____, progress) -- 4232
					emitAgentEvent( -- 4233
						shared, -- 4233
						{ -- 4233
							type = "tool_progress", -- 4234
							sessionId = shared.sessionId, -- 4235
							taskId = shared.taskId, -- 4236
							step = action.step, -- 4237
							tool = action.tool, -- 4238
							result = __TS__ObjectAssign({success = false}, progress) -- 4239
						} -- 4239
					) -- 4239
				end -- 4232
			})) -- 4232
			if result.success and mode == "lua" then -- 4232
				local deterministicFailure = false -- 4247
				local deterministicPass = false -- 4248
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4249
				do -- 4249
					local i = 0 -- 4250
					while i < #outputLines and not deterministicFailure do -- 4250
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4251
						if line == "passed" then -- 4251
							deterministicPass = true -- 4252
						end -- 4252
						if line == "failed" then -- 4252
							deterministicFailure = true -- 4254
							break -- 4255
						end -- 4255
						local searchFrom = 0 -- 4257
						while searchFrom < #line do -- 4257
							local failedIndex = (string.find( -- 4259
								line, -- 4259
								"failed", -- 4259
								math.max(searchFrom + 1, 1), -- 4259
								true -- 4259
							) or 0) - 1 -- 4259
							if failedIndex < 0 then -- 4259
								break -- 4260
							end -- 4260
							local after = failedIndex + #"failed" -- 4261
							while after < #line do -- 4261
								local ch = __TS__StringSlice(line, after, after + 1) -- 4263
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4263
									break -- 4264
								end -- 4264
								after = after + 1 -- 4265
							end -- 4265
							local afterEnd = after -- 4267
							while afterEnd < #line do -- 4267
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4269
								if ch < "0" or ch > "9" then -- 4269
									break -- 4270
								end -- 4270
								afterEnd = afterEnd + 1 -- 4271
							end -- 4271
							local count -- 4273
							if afterEnd > after then -- 4273
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4275
							else -- 4275
								local before = failedIndex - 1 -- 4277
								while before >= 0 do -- 4277
									local ch = __TS__StringSlice(line, before, before + 1) -- 4279
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4279
										break -- 4280
									end -- 4280
									before = before - 1 -- 4281
								end -- 4281
								local beforeEnd = before + 1 -- 4283
								while before >= 0 do -- 4283
									local ch = __TS__StringSlice(line, before, before + 1) -- 4285
									if ch < "0" or ch > "9" then -- 4285
										break -- 4286
									end -- 4286
									before = before - 1 -- 4287
								end -- 4287
								if beforeEnd > before + 1 then -- 4287
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4289
								end -- 4289
							end -- 4289
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4289
								deterministicFailure = true -- 4292
								break -- 4293
							end -- 4293
							searchFrom = failedIndex + #"failed" -- 4295
						end -- 4295
						i = i + 1 -- 4250
					end -- 4250
				end -- 4250
				if deterministicFailure then -- 4250
					shared.failedTestNeedsBuild = true -- 4299
					shared.failedTestHasSourceEdit = false -- 4300
				elseif deterministicPass then -- 4300
					shared.failedTestNeedsBuild = false -- 4302
					shared.failedTestHasSourceEdit = false -- 4303
				end -- 4303
			end -- 4303
			return ____awaiter_resolve(nil, result) -- 4303
		end -- 4303
		if action.tool == "spawn_sub_agent" then -- 4303
			if not shared.spawnSubAgent then -- 4303
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4303
			end -- 4303
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4303
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4303
			end -- 4303
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4315
				params.filesHint, -- 4316
				function(____, item) return type(item) == "string" end -- 4316
			) or nil -- 4316
			local result = __TS__Await(shared.spawnSubAgent({ -- 4318
				parentSessionId = shared.sessionId, -- 4319
				projectRoot = shared.workingDir, -- 4320
				title = type(params.title) == "string" and params.title or "Sub", -- 4321
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4322
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4323
				filesHint = filesHint, -- 4324
				disabledAgentTools = shared.disabledAgentTools -- 4325
			})) -- 4325
			if not result.success then -- 4325
				return ____awaiter_resolve(nil, result) -- 4325
			end -- 4325
			shared.hasSpawnedSubAgentThisTask = true -- 4330
			return ____awaiter_resolve(nil, { -- 4330
				success = true, -- 4332
				sessionId = result.sessionId, -- 4333
				taskId = result.taskId, -- 4334
				title = result.title, -- 4335
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4336
			}) -- 4336
		end -- 4336
		if action.tool == "list_sub_agents" then -- 4336
			if not shared.listSubAgents then -- 4336
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4336
			end -- 4336
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4336
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4336
			end -- 4336
			local result = __TS__Await(shared.listSubAgents({ -- 4346
				sessionId = shared.sessionId, -- 4347
				projectRoot = shared.workingDir, -- 4348
				status = type(params.status) == "string" and params.status or nil, -- 4349
				limit = type(params.limit) == "number" and params.limit or nil, -- 4350
				offset = type(params.offset) == "number" and params.offset or nil, -- 4351
				query = type(params.query) == "string" and params.query or nil -- 4352
			})) -- 4352
			return ____awaiter_resolve(nil, result) -- 4352
		end -- 4352
		if action.tool == "edit_file" then -- 4352
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4357
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4360
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4361
			if __TS__StringTrim(path) == "" then -- 4361
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4361
			end -- 4361
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4363
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4364
			if not isInternalDocumentEdit then -- 4364
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4366
				if preflightIssue ~= nil then -- 4366
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4368
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4369
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4369
				end -- 4369
			end -- 4369
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4375
			local result = __TS__Await(actionNode:exec({ -- 4376
				path = path, -- 4377
				oldStr = oldStr, -- 4378
				newStr = newStr, -- 4379
				taskId = shared.taskId, -- 4380
				workDir = shared.workingDir -- 4381
			})) -- 4381
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4381
				if params.partialStreamRecovery ~= true then -- 4381
					shared.truncatedToolOverwritePath = nil -- 4385
				end -- 4385
				shared.unbuiltEdits = true -- 4387
				shared.lastBuildSucceeded = false -- 4388
				if shared.failedTestNeedsBuild == true then -- 4388
					shared.failedTestHasSourceEdit = true -- 4389
				end -- 4389
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4390
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4390
					editedPaths[#editedPaths + 1] = normalizedPath -- 4391
				end -- 4391
				shared.editedPathsSinceBuild = editedPaths -- 4392
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4393
			end -- 4393
			return ____awaiter_resolve(nil, result) -- 4393
		end -- 4393
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4393
	end) -- 4393
end -- 4393
function sanitizeToolActionResultForHistory(action, result) -- 4400
	if action.tool == "read_file" then -- 4400
		return sanitizeReadResultForHistory(action.tool, result) -- 4402
	end -- 4402
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4402
		return sanitizeSearchResultForHistory(action.tool, result) -- 4405
	end -- 4405
	if action.tool == "glob_files" then -- 4405
		return sanitizeListFilesResultForHistory(result) -- 4408
	end -- 4408
	if action.tool == "build" then -- 4408
		return sanitizeBuildResultForHistory(result) -- 4411
	end -- 4411
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4411
		if result.success ~= true then -- 4411
			return result -- 4414
		end -- 4414
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4414
			return result -- 4415
		end -- 4415
		if isArray(result.fileContext) then -- 4415
			return result -- 4416
		end -- 4416
		local contextLimits = { -- 4418
			fullContentChars = 12000, -- 4419
			previewChars = 4000, -- 4420
			diffChars = 8000, -- 4421
			totalChars = 24000, -- 4422
			maxFiles = 8 -- 4423
		} -- 4423
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4425
			if maxChars <= 0 then -- 4425
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4426
			end -- 4426
			if #sourceText <= maxChars then -- 4426
				return sourceText -- 4427
			end -- 4427
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4428
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4429
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4430
		end -- 4425
		local function countLines(sourceText) -- 4432
			if sourceText == "" then -- 4432
				return 0 -- 4433
			end -- 4433
			return #__TS__StringSplit(sourceText, "\n") -- 4434
		end -- 4432
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4436
			if beforeContent == afterContent then -- 4436
				return "" -- 4437
			end -- 4437
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4438
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4439
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4441
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4441
				firstChangedLine = firstChangedLine + 1 -- 4447
			end -- 4447
			local lastChangedBeforeLine = #beforeLines - 1 -- 4449
			local lastChangedAfterLine = #afterLines - 1 -- 4450
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4450
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4456
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4457
			end -- 4457
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4459
			local previewEndLine = math.max( -- 4460
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4461
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4462
			) -- 4462
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4464
			do -- 4464
				local lineIndex = previewStartLine -- 4465
				while lineIndex <= previewEndLine do -- 4465
					do -- 4465
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4466
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4467
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4468
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4469
						if not beforeChanged and not afterChanged then -- 4469
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4471
							if contextLine ~= nil then -- 4471
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4472
							end -- 4472
							goto __continue733 -- 4473
						end -- 4473
						if beforeChanged and beforeLine ~= nil then -- 4473
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4475
						end -- 4475
						if afterChanged and afterLine ~= nil then -- 4475
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4476
						end -- 4476
					end -- 4476
					::__continue733:: -- 4476
					lineIndex = lineIndex + 1 -- 4465
				end -- 4465
			end -- 4465
			return truncateContextSnippet( -- 4478
				table.concat(unifiedDiffLines, "\n"), -- 4478
				maxChars, -- 4478
				"diff" -- 4478
			) -- 4478
		end -- 4436
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4481
		if not checkpointDiff.success then -- 4481
			return result -- 4482
		end -- 4482
		local remainingContextBudget = contextLimits.totalChars -- 4483
		local fileContextItems = {} -- 4484
		local changedFiles = checkpointDiff.files -- 4485
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4486
		do -- 4486
			local fileIndex = 0 -- 4487
			while fileIndex < maxContextFiles do -- 4487
				if remainingContextBudget <= 0 then -- 4487
					break -- 4488
				end -- 4488
				local changedFile = changedFiles[fileIndex + 1] -- 4489
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4490
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4491
				local contextItem = { -- 4492
					path = changedFile.path, -- 4493
					op = changedFile.op, -- 4494
					checkpointId = result.checkpointId, -- 4495
					checkpointSeq = result.checkpointSeq, -- 4496
					beforeExists = changedFile.beforeExists, -- 4497
					afterExists = changedFile.afterExists, -- 4498
					beforeBytes = #beforeContent, -- 4499
					afterBytes = #afterContent, -- 4500
					diffPreview = "", -- 4501
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4502
					contentTruncated = false, -- 4503
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4504
				} -- 4504
				if changedFile.afterExists then -- 4504
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4504
						contextItem.afterContent = afterContent -- 4508
						remainingContextBudget = remainingContextBudget - #afterContent -- 4509
					else -- 4509
						contextItem.afterContentPreview = truncateContextSnippet( -- 4511
							afterContent, -- 4512
							math.min( -- 4513
								contextLimits.previewChars, -- 4513
								math.max(400, remainingContextBudget) -- 4513
							), -- 4513
							"afterContent" -- 4514
						) -- 4514
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4516
						contextItem.contentTruncated = true -- 4517
					end -- 4517
				end -- 4517
				local diffPreview = buildUnifiedDiffPreview( -- 4520
					changedFile.path, -- 4521
					beforeContent, -- 4522
					afterContent, -- 4523
					math.min( -- 4524
						contextLimits.diffChars, -- 4524
						math.max(400, remainingContextBudget) -- 4524
					) -- 4524
				) -- 4524
				contextItem.diffPreview = diffPreview -- 4526
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4527
				if not changedFile.afterExists and beforeContent ~= "" then -- 4527
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4529
						beforeContent, -- 4530
						math.min( -- 4531
							contextLimits.previewChars, -- 4531
							math.max(400, remainingContextBudget) -- 4531
						), -- 4531
						"beforeContent" -- 4532
					) -- 4532
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4534
					if #beforeContent > contextLimits.previewChars then -- 4534
						contextItem.contentTruncated = true -- 4535
					end -- 4535
				end -- 4535
				fileContextItems[#fileContextItems + 1] = contextItem -- 4537
				fileIndex = fileIndex + 1 -- 4487
			end -- 4487
		end -- 4487
		if #fileContextItems == 0 then -- 4487
			return result -- 4539
		end -- 4539
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4540
	end -- 4540
	return result -- 4547
end -- 4547
function emitAgentTaskFinishEvent(shared, success, message) -- 4748
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4749
	local result = success and ({ -- 4753
		success = true, -- 4755
		taskId = shared.taskId, -- 4756
		message = message, -- 4757
		steps = shared.step, -- 4758
		completion = completion -- 4759
	}) or ({ -- 4759
		success = false, -- 4762
		taskId = shared.taskId, -- 4763
		message = message, -- 4764
		steps = shared.step, -- 4765
		completion = completion -- 4766
	}) -- 4766
	emitAgentEvent(shared, { -- 4768
		type = "task_finished", -- 4769
		sessionId = shared.sessionId, -- 4770
		taskId = shared.taskId, -- 4771
		success = result.success, -- 4772
		message = result.message, -- 4773
		steps = result.steps, -- 4774
		completion = result.completion -- 4775
	}) -- 4775
	return result -- 4777
end -- 4777
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
local function projectMessagesForCompression(messages) -- 1258
	local projected = projectMessagesForLLMContext(messages) -- 1259
	do -- 1259
		local i = 0 -- 1260
		while i < #projected do -- 1260
			do -- 1260
				local message = projected[i + 1] -- 1261
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1261
					goto __continue189 -- 1262
				end -- 1262
				local changed = false -- 1263
				local toolCalls = __TS__ArrayMap( -- 1264
					message.tool_calls, -- 1264
					function(____, toolCall) -- 1264
						local fn = toolCall["function"] -- 1265
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1265
							return toolCall -- 1266
						end -- 1266
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 1267
						if not isRecord(decoded) or isArray(decoded) then -- 1267
							return toolCall -- 1268
						end -- 1268
						changed = true -- 1269
						return __TS__ObjectAssign( -- 1270
							{}, -- 1270
							toolCall, -- 1271
							{["function"] = __TS__ObjectAssign( -- 1270
								{}, -- 1272
								fn, -- 1273
								{arguments = toJson( -- 1272
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1274
									false -- 1274
								)} -- 1274
							)} -- 1274
						) -- 1274
					end -- 1264
				) -- 1264
				if changed then -- 1264
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1278
				end -- 1278
			end -- 1278
			::__continue189:: -- 1278
			i = i + 1 -- 1260
		end -- 1260
	end -- 1260
	return projected -- 1280
end -- 1258
local function getDecisionToolSchemaText(shared) -- 1322
	local toolsText = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1323
		shared.role, -- 1323
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1323
		{ -- 1323
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1324
			workMode = shared.workMode -- 1325
		} -- 1325
	)) -- 1325
	return toolsText or "" -- 1327
end -- 1322
local function clearPreExecutedResults(shared) -- 1337
	shared.preExecutedResults = nil -- 1338
end -- 1337
local function startPreExecutedToolAction(shared, action) -- 1341
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1341
		local ____hasReturned, ____returnValue -- 1341
		local ____try = __TS__AsyncAwaiter(function() -- 1341
			____hasReturned = true -- 1343
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1343
			return -- 1343
		end) -- 1343
		____try = ____try.catch( -- 1343
			____try, -- 1343
			function(____, err) -- 1343
				return __TS__AsyncAwaiter(function() -- 1343
					local message = tostring(err) -- 1345
					AgentUtils.Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1346
					____hasReturned = true -- 1347
					____returnValue = {success = false, message = message} -- 1347
					return -- 1347
				end) -- 1347
			end -- 1347
		) -- 1347
		__TS__Await(____try) -- 1342
		if ____hasReturned then -- 1342
			return ____awaiter_resolve(nil, ____returnValue) -- 1342
		end -- 1342
	end) -- 1342
end -- 1341
local function createPreExecutedToolResult(shared, action) -- 1351
	local cloneParamValue -- 1352
	cloneParamValue = function(value) -- 1352
		if value == nil then -- 1352
			return value -- 1353
		end -- 1353
		if isArray(value) then -- 1353
			return __TS__ArrayMap( -- 1355
				value, -- 1355
				function(____, item) return cloneParamValue(item) end -- 1355
			) -- 1355
		end -- 1355
		if type(value) == "table" then -- 1355
			local clone = {} -- 1358
			for key in pairs(value) do -- 1359
				clone[key] = cloneParamValue(value[key]) -- 1360
			end -- 1360
			return clone -- 1362
		end -- 1362
		return value -- 1364
	end -- 1352
	local params = cloneParamValue(action.params) -- 1366
	local areParamValuesEqual -- 1367
	areParamValuesEqual = function(left, right) -- 1367
		if left == right then -- 1367
			return true -- 1368
		end -- 1368
		if left == nil or right == nil then -- 1368
			return false -- 1369
		end -- 1369
		if isArray(left) or isArray(right) then -- 1369
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1369
				return false -- 1371
			end -- 1371
			do -- 1371
				local i = 0 -- 1372
				while i < #left do -- 1372
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1372
						return false -- 1373
					end -- 1373
					i = i + 1 -- 1372
				end -- 1372
			end -- 1372
			return true -- 1375
		end -- 1375
		if type(left) == "table" and type(right) == "table" then -- 1375
			local leftCount = 0 -- 1378
			for key in pairs(left) do -- 1379
				leftCount = leftCount + 1 -- 1380
				if not areParamValuesEqual(left[key], right[key]) then -- 1380
					return false -- 1385
				end -- 1385
			end -- 1385
			local rightCount = 0 -- 1388
			for key in pairs(right) do -- 1389
				rightCount = rightCount + 1 -- 1390
			end -- 1390
			return leftCount == rightCount -- 1392
		end -- 1392
		return false -- 1394
	end -- 1367
	return { -- 1396
		action = action, -- 1397
		matches = function(self, nextAction) -- 1398
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1399
		end, -- 1398
		promise = startPreExecutedToolAction(shared, action) -- 1401
	} -- 1401
end -- 1351
local function executeToolActionWithPreExecution(shared, action) -- 1405
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1405
		local wasResumeNarrowReadMode = shared.resumeNarrowReadMode == true -- 1406
		local ____opt_29 = shared.preExecutedResults -- 1406
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1407
		local result -- 1408
		if preResult then -- 1408
			local ____opt_31 = shared.preExecutedResults -- 1408
			if ____opt_31 ~= nil then -- 1408
				____opt_31:delete(action.toolCallId) -- 1410
			end -- 1410
			if preResult:matches(action) then -- 1410
				AgentUtils.Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1412
				result = __TS__Await(preResult.promise) -- 1413
			else -- 1413
				AgentUtils.Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1415
				result = __TS__Await(executeToolAction(shared, action)) -- 1416
			end -- 1416
		else -- 1416
			result = __TS__Await(executeToolAction(shared, action)) -- 1419
		end -- 1419
		local guidance = {} -- 1421
		if type(result.guidance) == "string" and __TS__StringTrim(result.guidance) ~= "" then -- 1421
			guidance[#guidance + 1] = result.guidance -- 1423
		end -- 1423
		guidance[#guidance + 1] = AgentToolRegistry.buildCurrentToolAvailabilityGuidance() -- 1425
		if shared.hasSpawnedSubAgentThisTask == true and (shared.delegatedForegroundBatches or 0) + 1 >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1425
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1432
		end -- 1432
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1432
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1435
		end -- 1435
		if shared.failedTestNeedsBuild == true then -- 1435
			if action.tool == "build" and result.success == true and shared.failedTestHasSourceEdit ~= true then -- 1435
				guidance[#guidance + 1] = "The build passed, but no authored source change has addressed the deterministic test failure. Make a narrow source fix before rebuilding or retesting." -- 1439
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1439
				guidance[#guidance + 1] = "Source changed after a deterministic test failure. Build the authored changes before running more tests." -- 1445
			elseif action.tool ~= "build" then -- 1445
				guidance[#guidance + 1] = "A deterministic test failure remains unresolved. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1447
			end -- 1447
		end -- 1447
		if action.tool == "search_dora_api" then -- 1447
			if shared.unbuiltEdits == true then -- 1447
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1452
			end -- 1452
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1452
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1455
			end -- 1455
		end -- 1455
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1455
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1463
		end -- 1463
		if action.tool == "edit_file" and wasResumeNarrowReadMode then -- 1463
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1466
			if oldStr == "" then -- 1466
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1468
			end -- 1468
		end -- 1468
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1468
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1472
		end -- 1472
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1472
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1475
		end -- 1475
		if shared.buildRepairPending == true then -- 1475
			if action.tool == "build" then -- 1475
				guidance[#guidance + 1] = "This build reported authored-file diagnostics. Make a narrow source repair before building again." -- 1481
			elseif (action.tool == "edit_file" or action.tool == "delete_file") and result.success == true and result.changed ~= false then -- 1481
				guidance[#guidance + 1] = "A source repair was applied after build diagnostics. Build again before broadening the investigation." -- 1487
			else -- 1487
				guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1489
			end -- 1489
		end -- 1489
		if action.tool == "build" and shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true and shared.failedTestNeedsBuild ~= true then -- 1489
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1498
		end -- 1498
		result.guidance = table.concat(guidance, "\n") -- 1500
		if action.tool ~= "build" and action.tool ~= "read_file" then -- 1500
			shared.resumeNarrowReadMode = false -- 1505
		end -- 1505
		return ____awaiter_resolve(nil, result) -- 1505
	end) -- 1505
end -- 1405
local function maybeCompressHistory(shared, includePendingUserPrompt, pendingUserPrompt) -- 1510
	if includePendingUserPrompt == nil then -- 1510
		includePendingUserPrompt = false -- 1512
	end -- 1512
	if pendingUserPrompt == nil then -- 1512
		pendingUserPrompt = "" -- 1513
	end -- 1513
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1513
		local ____shared_33 = shared -- 1515
		local memory = ____shared_33.memory -- 1515
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1516
		local changed = false -- 1517
		do -- 1517
			local round = 0 -- 1518
			while round < maxRounds do -- 1518
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1519
				local normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1520
				local decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages) -- 1521
				local activeMessages = projectMessagesForCompression(normalizedActiveMessages) -- 1522
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1525
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1533
				local triggerMessages = buildDecisionMessages( -- 1536
					shared, -- 1537
					nil, -- 1538
					1, -- 1539
					nil, -- 1540
					shared.decisionMode, -- 1541
					false, -- 1542
					includePendingUserPrompt and pendingUserPrompt or "" -- 1543
				) -- 1543
				local triggerOptions = shared.decisionMode == "tool_calling" and __TS__ObjectAssign( -- 1545
					{}, -- 1546
					shared.llmOptions, -- 1547
					__TS__StringIncludes( -- 1548
						string.lower(shared.llmConfig.model), -- 1548
						"glm-5.2" -- 1548
					) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") and ({reasoning_effort = "minimal"}) or ({}), -- 1548
					{tools = AgentToolRegistry.buildDecisionToolSchema( -- 1546
						shared.role, -- 1553
						AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1553
						{ -- 1553
							disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1554
							workMode = shared.workMode -- 1555
						} -- 1555
					)} -- 1555
				) or shared.llmOptions -- 1555
				local fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig) -- 1559
				local thresholdReached = getActiveRealMessageCount(shared) > 0 and fitted.originalTokens >= fitted.budgetTokens -- 1562
				if not thresholdReached then -- 1562
					if changed then -- 1562
						persistHistoryState(shared) -- 1566
					end -- 1566
					return ____awaiter_resolve(nil) -- 1566
				end -- 1566
				local compressionRound = round + 1 -- 1570
				AgentUtils.Log( -- 1571
					"Info", -- 1571
					(((("[Memory] Effective input budget reached tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " round=") .. tostring(compressionRound) -- 1571
				) -- 1571
				shared.step = shared.step + 1 -- 1572
				local stepId = shared.step -- 1573
				local pendingMessages = #activeMessages -- 1574
				emitAgentEvent( -- 1575
					shared, -- 1575
					{ -- 1575
						type = "memory_compression_started", -- 1576
						sessionId = shared.sessionId, -- 1577
						taskId = shared.taskId, -- 1578
						step = stepId, -- 1579
						tool = "compress_memory", -- 1580
						reason = getMemoryCompressionStartReason(shared), -- 1581
						params = { -- 1582
							round = compressionRound, -- 1583
							maxRounds = maxRounds, -- 1584
							pendingMessages = pendingMessages, -- 1585
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1586
							uncoveredMessages = #uncoveredMessages, -- 1587
							inputTokens = fitted.originalTokens, -- 1588
							inputBudgetTokens = fitted.budgetTokens -- 1589
						} -- 1589
					} -- 1589
				) -- 1589
				local result = __TS__Await(memory.compressor:compress( -- 1592
					activeMessages, -- 1593
					shared.llmOptions, -- 1594
					shared.llmMaxTry, -- 1595
					shared.decisionMode, -- 1596
					{ -- 1597
						onInput = function(____, phase, messages, options) -- 1598
							saveStepLLMDebugInput( -- 1599
								shared, -- 1599
								stepId, -- 1599
								phase, -- 1599
								messages, -- 1599
								options -- 1599
							) -- 1599
						end, -- 1598
						onOutput = function(____, phase, text, meta) -- 1601
							saveStepLLMDebugOutput( -- 1602
								shared, -- 1602
								stepId, -- 1602
								phase, -- 1602
								text, -- 1602
								meta -- 1602
							) -- 1602
						end, -- 1601
						onUsage = function(____, phase, usage) -- 1604
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1605
						end -- 1604
					}, -- 1604
					"default", -- 1608
					systemPrompt, -- 1609
					toolDefinitions, -- 1610
					decisionActiveMessages -- 1611
				)) -- 1611
				if not (result and result.success and result.compressedCount > 0) then -- 1611
					emitAgentEvent( -- 1614
						shared, -- 1614
						{ -- 1614
							type = "memory_compression_finished", -- 1615
							sessionId = shared.sessionId, -- 1616
							taskId = shared.taskId, -- 1617
							step = stepId, -- 1618
							tool = "compress_memory", -- 1619
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1620
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1624
						} -- 1624
					) -- 1624
					if changed then -- 1624
						persistHistoryState(shared) -- 1632
					end -- 1632
					return ____awaiter_resolve(nil) -- 1632
				end -- 1632
				local effectiveCompressedCount = math.max( -- 1636
					0, -- 1637
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1638
				) -- 1638
				if effectiveCompressedCount <= 0 then -- 1638
					if changed then -- 1638
						persistHistoryState(shared) -- 1642
					end -- 1642
					return ____awaiter_resolve(nil) -- 1642
				end -- 1642
				emitAgentEvent( -- 1646
					shared, -- 1646
					{ -- 1646
						type = "memory_compression_finished", -- 1647
						sessionId = shared.sessionId, -- 1648
						taskId = shared.taskId, -- 1649
						step = stepId, -- 1650
						tool = "compress_memory", -- 1651
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1652
						result = { -- 1653
							success = true, -- 1654
							round = compressionRound, -- 1655
							compressedCount = effectiveCompressedCount, -- 1656
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1657
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1658
						} -- 1658
					} -- 1658
				) -- 1658
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1661
				changed = true -- 1662
				AgentUtils.Log( -- 1663
					"Info", -- 1663
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1663
				) -- 1663
				round = round + 1 -- 1518
			end -- 1518
		end -- 1518
		if changed then -- 1518
			persistHistoryState(shared) -- 1666
		end -- 1666
	end) -- 1666
end -- 1510
local function compactAllHistory(shared) -- 1670
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1670
		local ____shared_40 = shared -- 1671
		local memory = ____shared_40.memory -- 1671
		local rounds = 0 -- 1672
		local totalCompressed = 0 -- 1673
		while getActiveRealMessageCount(shared) > 0 do -- 1673
			if shared.stopToken.stopped then -- 1673
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1676
				return ____awaiter_resolve( -- 1676
					nil, -- 1676
					emitAgentTaskFinishEvent( -- 1677
						shared, -- 1677
						false, -- 1677
						getCancelledReason(shared) -- 1677
					) -- 1677
				) -- 1677
			end -- 1677
			rounds = rounds + 1 -- 1679
			shared.step = shared.step + 1 -- 1680
			local stepId = shared.step -- 1681
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1682
			local pendingMessages = #activeMessages -- 1683
			emitAgentEvent( -- 1684
				shared, -- 1684
				{ -- 1684
					type = "memory_compression_started", -- 1685
					sessionId = shared.sessionId, -- 1686
					taskId = shared.taskId, -- 1687
					step = stepId, -- 1688
					tool = "compress_memory", -- 1689
					reason = getMemoryCompressionStartReason(shared), -- 1690
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1691
				} -- 1691
			) -- 1691
			local result = __TS__Await(memory.compressor:compress( -- 1698
				activeMessages, -- 1699
				shared.llmOptions, -- 1700
				shared.llmMaxTry, -- 1701
				shared.decisionMode, -- 1702
				{ -- 1703
					onInput = function(____, phase, messages, options) -- 1704
						saveStepLLMDebugInput( -- 1705
							shared, -- 1705
							stepId, -- 1705
							phase, -- 1705
							messages, -- 1705
							options -- 1705
						) -- 1705
					end, -- 1704
					onOutput = function(____, phase, text, meta) -- 1707
						saveStepLLMDebugOutput( -- 1708
							shared, -- 1708
							stepId, -- 1708
							phase, -- 1708
							text, -- 1708
							meta -- 1708
						) -- 1708
					end, -- 1707
					onUsage = function(____, phase, usage) -- 1710
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1711
					end -- 1710
				}, -- 1710
				"budget_max" -- 1714
			)) -- 1714
			if not (result and result.success and result.compressedCount > 0) then -- 1714
				emitAgentEvent( -- 1717
					shared, -- 1717
					{ -- 1717
						type = "memory_compression_finished", -- 1718
						sessionId = shared.sessionId, -- 1719
						taskId = shared.taskId, -- 1720
						step = stepId, -- 1721
						tool = "compress_memory", -- 1722
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1723
						result = { -- 1727
							success = false, -- 1728
							rounds = rounds, -- 1729
							error = result and result.error or "compression returned no changes", -- 1730
							compressedCount = result and result.compressedCount or 0, -- 1731
							fullCompaction = true -- 1732
						} -- 1732
					} -- 1732
				) -- 1732
				return ____awaiter_resolve( -- 1732
					nil, -- 1732
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1735
				) -- 1735
			end -- 1735
			local effectiveCompressedCount = math.max( -- 1740
				0, -- 1741
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1742
			) -- 1742
			if effectiveCompressedCount <= 0 then -- 1742
				return ____awaiter_resolve( -- 1742
					nil, -- 1742
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1745
				) -- 1745
			end -- 1745
			emitAgentEvent( -- 1752
				shared, -- 1752
				{ -- 1752
					type = "memory_compression_finished", -- 1753
					sessionId = shared.sessionId, -- 1754
					taskId = shared.taskId, -- 1755
					step = stepId, -- 1756
					tool = "compress_memory", -- 1757
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1758
					result = { -- 1759
						success = true, -- 1760
						round = rounds, -- 1761
						compressedCount = effectiveCompressedCount, -- 1762
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1763
						fullCompaction = true -- 1764
					} -- 1764
				} -- 1764
			) -- 1764
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1767
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1768
			persistHistoryState(shared) -- 1769
			AgentUtils.Log( -- 1770
				"Info", -- 1770
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1770
			) -- 1770
		end -- 1770
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1772
		return ____awaiter_resolve( -- 1772
			nil, -- 1772
			emitAgentTaskFinishEvent( -- 1773
				shared, -- 1774
				true, -- 1775
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1776
			) -- 1776
		) -- 1776
	end) -- 1776
end -- 1670
local function clearSessionHistory(shared) -- 1782
	shared.messages = {} -- 1783
	shared.lastConsolidatedIndex = 0 -- 1784
	shared.carryMessageIndex = nil -- 1785
	persistHistoryState(shared) -- 1786
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1787
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1788
end -- 1782
local function appendConversationMessage(shared, message) -- 1944
	local ____shared_messages_49 = shared.messages -- 1944
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1945
		{}, -- 1945
		message, -- 1946
		{ -- 1945
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1947
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1948
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1949
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1950
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1951
		} -- 1951
	) -- 1951
end -- 1944
local function appendToolResultMessage(shared, action) -- 1960
	appendConversationMessage( -- 1961
		shared, -- 1961
		{ -- 1961
			role = "tool", -- 1962
			tool_call_id = action.toolCallId, -- 1963
			name = action.tool, -- 1964
			content = action.result and toJson(action.result, false) or "" -- 1965
		} -- 1965
	) -- 1965
end -- 1960
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1969
	appendConversationMessage( -- 1975
		shared, -- 1975
		{ -- 1975
			role = "assistant", -- 1976
			content = content or "", -- 1977
			reasoning_content = reasoningContent, -- 1978
			tool_calls = __TS__ArrayMap( -- 1979
				actions, -- 1979
				function(____, action) return { -- 1979
					id = action.toolCallId, -- 1980
					type = "function", -- 1981
					["function"] = { -- 1982
						name = action.tool, -- 1983
						arguments = toJson(action.params, false) -- 1984
					} -- 1984
				} end -- 1984
			) -- 1984
		} -- 1984
	) -- 1984
end -- 1969
local function llm(shared, messages, phase) -- 2168
	if phase == nil then -- 2168
		phase = "decision_xml" -- 2171
	end -- 2171
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2171
		local stepId = shared.step + 1 -- 2173
		emitLLMContextMetrics( -- 2174
			shared, -- 2174
			stepId, -- 2174
			phase, -- 2174
			messages, -- 2174
			shared.llmOptions -- 2174
		) -- 2174
		saveStepLLMDebugInput( -- 2175
			shared, -- 2175
			stepId, -- 2175
			phase, -- 2175
			messages, -- 2175
			shared.llmOptions -- 2175
		) -- 2175
		local lastStreamReasoning = "" -- 2176
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2177
			messages, -- 2178
			shared.llmOptions, -- 2179
			shared.stopToken, -- 2180
			shared.llmConfig, -- 2181
			function(response) -- 2182
				local ____opt_53 = response.choices -- 2182
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2182
				local streamMessage = ____opt_51 and ____opt_51.message -- 2183
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2184
				if nextContent == "" then -- 2184
					return -- 2187
				end -- 2187
				if nextContent == lastStreamReasoning then -- 2187
					return -- 2188
				end -- 2188
				lastStreamReasoning = nextContent -- 2189
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2190
			end -- 2182
		)) -- 2182
		if res.success then -- 2182
			local usage = res.tokenUsage -- 2194
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2195
			local ____opt_59 = res.response.choices -- 2195
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2195
			local message = ____opt_57 and ____opt_57.message -- 2196
			local text = message and message.content -- 2197
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2198
			if text then -- 2198
				local parsed = tryParseAndValidateDecision(text, shared) -- 2202
				if parsed.success then -- 2202
					local reason = parsed.reason or "" -- 2204
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2205
				end -- 2205
				saveStepLLMDebugOutput( -- 2207
					shared, -- 2207
					stepId, -- 2207
					phase, -- 2207
					text, -- 2207
					{success = true, usage = usage} -- 2207
				) -- 2207
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2207
			else -- 2207
				saveStepLLMDebugOutput( -- 2210
					shared, -- 2210
					stepId, -- 2210
					phase, -- 2210
					"empty LLM response", -- 2210
					{success = false, usage = usage} -- 2210
				) -- 2210
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2210
			end -- 2210
		else -- 2210
			local usage = res.tokenUsage -- 2214
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2215
			saveStepLLMDebugOutput( -- 2216
				shared, -- 2216
				stepId, -- 2216
				phase, -- 2216
				res.raw or res.message, -- 2216
				{success = false, usage = usage} -- 2216
			) -- 2216
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2216
		end -- 2216
	end) -- 2216
end -- 2168
local function isDecisionBatchSuccess(result) -- 2240
	return result.kind == "batch" -- 2241
end -- 2240
local function parseDecisionToolCall(functionName, rawObj) -- 2265
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2265
		return {success = false, message = "unknown tool: " .. functionName} -- 2267
	end -- 2267
	if rawObj == nil then -- 2267
		return {success = true, tool = functionName, params = {}} -- 2270
	end -- 2270
	if not isRecord(rawObj) then -- 2270
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2273
	end -- 2273
	return {success = true, tool = functionName, params = rawObj} -- 2275
end -- 2265
local function parseToolCallArguments(functionName, argsText) -- 2282
	local trimmedArgs = __TS__StringTrim(argsText) -- 2283
	if trimmedArgs == "" then -- 2283
		return {} -- 2285
	end -- 2285
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2287
	if err ~= nil or rawObj == nil then -- 2287
		return { -- 2289
			success = false, -- 2290
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2291
			raw = argsText -- 2292
		} -- 2292
	end -- 2292
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2295
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2295
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2297
	end -- 2297
	return rawObj -- 2303
end -- 2282
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2306
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2314
	if isRecord(rawArgs) and rawArgs.success == false then -- 2314
		return rawArgs -- 2316
	end -- 2316
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2318
	if not decision.success then -- 2318
		return {success = false, message = decision.message, raw = argsText} -- 2320
	end -- 2320
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2326
	if not completionValidation.success then -- 2326
		return {success = false, message = completionValidation.message, raw = argsText} -- 2328
	end -- 2328
	local validation = validateDecision(decision.tool, decision.params) -- 2334
	if not validation.success then -- 2334
		return {success = false, message = validation.message, raw = argsText} -- 2336
	end -- 2336
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2342
	if not sharedValidation.success then -- 2342
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2344
	end -- 2344
	decision.params = validation.params -- 2350
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2351
	decision.reason = reason -- 2352
	decision.reasoningContent = reasoningContent -- 2353
	return decision -- 2354
end -- 2306
local function createPreExecutableActionFromStream(shared, toolCall) -- 2357
	local ____opt_65 = toolCall["function"] -- 2357
	local functionName = ____opt_65 and ____opt_65.name -- 2358
	local ____opt_67 = toolCall["function"] -- 2358
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2359
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2360
	if not functionName or not toolCallId then -- 2360
		return nil -- 2361
	end -- 2361
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2362
	if isRecord(rawArgs) and rawArgs.success == false then -- 2362
		return nil -- 2363
	end -- 2363
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2364
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2364
		return nil -- 2365
	end -- 2365
	local validation = validateDecision(decision.tool, decision.params) -- 2366
	if not validation.success then -- 2366
		return nil -- 2367
	end -- 2367
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2367
		return nil -- 2368
	end -- 2368
	return { -- 2369
		step = shared.step + 1, -- 2370
		toolCallId = toolCallId, -- 2371
		tool = decision.tool, -- 2372
		reason = "", -- 2373
		params = validation.params, -- 2374
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2375
	} -- 2375
end -- 2357
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2768
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2777
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2778
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2786
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2787
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2788
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2796
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2804
		shared.role, -- 2804
		{ -- 2804
			includeFinish = true, -- 2805
			includeXmlRules = true, -- 2806
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2807
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2808
			workMode = shared.workMode -- 2809
		} -- 2809
	) -- 2809
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2811
	local repairPrompt = replacePromptVars( -- 2814
		shared.promptPack.xmlDecisionRepairPrompt, -- 2814
		{ -- 2814
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2815
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2816
			CANDIDATE_SECTION = candidateSection, -- 2817
			LAST_ERROR = lastError, -- 2818
			ATTEMPT = tostring(attempt) -- 2819
		} -- 2819
	) -- 2819
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2821
end -- 2768
local MainDecisionAgent = __TS__Class() -- 2859
MainDecisionAgent.name = "MainDecisionAgent" -- 2859
__TS__ClassExtends(MainDecisionAgent, Node) -- 2859
function MainDecisionAgent.prototype.prep(self, shared) -- 2860
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2860
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2860
			return ____awaiter_resolve(nil, {shared = shared}) -- 2860
		end -- 2860
		__TS__Await(maybeCompressHistory(shared)) -- 2865
		return ____awaiter_resolve(nil, {shared = shared}) -- 2865
	end) -- 2865
end -- 2860
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2870
	local preExecuted = shared.preExecutedResults -- 2871
	if not preExecuted or preExecuted.size == 0 then -- 2871
		return nil -- 2872
	end -- 2872
	local decisions = {} -- 2873
	preExecuted:forEach(function(____, preResult) -- 2874
		local action = preResult.action -- 2875
		decisions[#decisions + 1] = { -- 2876
			success = true, -- 2877
			tool = action.tool, -- 2878
			params = action.params, -- 2879
			toolCallId = action.toolCallId, -- 2880
			reason = action.reason, -- 2881
			reasoningContent = action.reasoningContent -- 2882
		} -- 2882
	end) -- 2874
	if #decisions == 0 then -- 2874
		return nil -- 2885
	end -- 2885
	AgentUtils.Log( -- 2886
		"Warn", -- 2886
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2886
			__TS__ArrayMap( -- 2886
				decisions, -- 2886
				function(____, decision) return decision.tool end -- 2886
			), -- 2886
			"," -- 2886
		) -- 2886
	) -- 2886
	if #decisions == 1 then -- 2886
		return decisions[1] -- 2888
	end -- 2888
	return {success = true, kind = "batch", decisions = decisions} -- 2890
end -- 2870
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2897
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2902
	if not recovery then -- 2902
		return nil -- 2903
	end -- 2903
	shared.truncatedToolOverwritePath = recovery.target -- 2904
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2905
	return { -- 2906
		success = true, -- 2907
		tool = "edit_file", -- 2908
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2909
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2915
		reason = recovery.reason, -- 2916
		reasoningContent = reasoningContent -- 2917
	} -- 2917
end -- 2897
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2921
	if attempt == nil then -- 2921
		attempt = 1 -- 2924
	end -- 2924
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2924
		if shared.stopToken.stopped then -- 2924
			return ____awaiter_resolve( -- 2924
				nil, -- 2924
				{ -- 2928
					success = false, -- 2928
					message = getCancelledReason(shared) -- 2928
				} -- 2928
			) -- 2928
		end -- 2928
		AgentUtils.Log( -- 2930
			"Info", -- 2930
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2930
		) -- 2930
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2931
			shared.role, -- 2931
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2931
			{ -- 2931
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2932
				workMode = shared.workMode -- 2933
			} -- 2933
		) -- 2933
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2935
		local stepId = shared.step + 1 -- 2936
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2937
			string.lower(shared.llmConfig.model), -- 2937
			"glm-5.2" -- 2937
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2937
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2940
		emitLLMContextMetrics( -- 2945
			shared, -- 2945
			stepId, -- 2945
			"decision_tool_calling", -- 2945
			messages, -- 2945
			llmOptions -- 2945
		) -- 2945
		saveStepLLMDebugInput( -- 2946
			shared, -- 2946
			stepId, -- 2946
			"decision_tool_calling", -- 2946
			messages, -- 2946
			llmOptions -- 2946
		) -- 2946
		local lastStreamContent = "" -- 2947
		local lastStreamReasoning = "" -- 2948
		local preExecutedResults = __TS__New(Map) -- 2949
		shared.preExecutedResults = preExecutedResults -- 2950
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2951
			messages, -- 2952
			llmOptions, -- 2953
			shared.stopToken, -- 2954
			shared.llmConfig, -- 2955
			function(response) -- 2956
				local ____opt_75 = response.choices -- 2956
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2956
				local streamMessage = ____opt_73 and ____opt_73.message -- 2957
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2958
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2961
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2961
					return -- 2965
				end -- 2965
				lastStreamContent = nextContent -- 2967
				lastStreamReasoning = nextReasoning -- 2968
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2969
			end, -- 2956
			function(tc) -- 2971
				if shared.stopToken.stopped then -- 2971
					return -- 2972
				end -- 2972
				local action = createPreExecutableActionFromStream(shared, tc) -- 2973
				if not action or preExecutedResults:has(action.toolCallId) then -- 2973
					return -- 2974
				end -- 2974
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2975
				preExecutedResults:set( -- 2976
					action.toolCallId, -- 2976
					createPreExecutedToolResult(shared, action) -- 2976
				) -- 2976
			end -- 2971
		)) -- 2971
		if shared.stopToken.stopped then -- 2971
			clearPreExecutedResults(shared) -- 2980
			return ____awaiter_resolve( -- 2980
				nil, -- 2980
				{ -- 2981
					success = false, -- 2981
					message = getCancelledReason(shared) -- 2981
				} -- 2981
			) -- 2981
		end -- 2981
		if not res.success then -- 2981
			local usage = res.tokenUsage -- 2984
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2985
			saveStepLLMDebugOutput( -- 2986
				shared, -- 2986
				stepId, -- 2986
				"decision_tool_calling", -- 2986
				res.raw or res.message, -- 2986
				{success = false, usage = usage} -- 2986
			) -- 2986
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2987
			local committed = self:commitPreExecutedDecision(shared) -- 2988
			if committed then -- 2988
				return ____awaiter_resolve(nil, committed) -- 2988
			end -- 2988
			local ____opt_83 = res.response -- 2988
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2988
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2990
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 2991
			local ____shared_93 = shared -- 2992
			local ____opt_85 = partialChoice and partialChoice.message -- 2992
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 2993
			local ____opt_89 = partialChoice and partialChoice.message -- 2993
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 2991
			if partialDraft then -- 2991
				return ____awaiter_resolve(nil, partialDraft) -- 2991
			end -- 2991
			clearPreExecutedResults(shared) -- 2997
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2997
		end -- 2997
		local usage = res.tokenUsage -- 3000
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3001
		saveStepLLMDebugOutput( -- 3002
			shared, -- 3002
			stepId, -- 3002
			"decision_tool_calling", -- 3002
			encodeDebugJSON(res.response), -- 3002
			{success = true, usage = usage} -- 3002
		) -- 3002
		local choice = res.response.choices and res.response.choices[1] -- 3003
		local message = choice and choice.message -- 3004
		local toolCalls = message and message.tool_calls -- 3005
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3006
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3009
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3012
		AgentUtils.Log( -- 3015
			"Info", -- 3015
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3015
		) -- 3015
		if finishReason == "length" then -- 3015
			local committed = self:commitPreExecutedDecision(shared) -- 3017
			if committed then -- 3017
				return ____awaiter_resolve(nil, committed) -- 3017
			end -- 3017
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3019
			if partialDraft then -- 3019
				return ____awaiter_resolve(nil, partialDraft) -- 3019
			end -- 3019
			AgentUtils.Log( -- 3021
				"Error", -- 3021
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3021
			) -- 3021
			clearPreExecutedResults(shared) -- 3022
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3022
		end -- 3022
		if not toolCalls or #toolCalls == 0 then -- 3022
			if messageContent and messageContent ~= "" then -- 3022
				if isFinalDecisionTurn(shared) then -- 3022
					clearPreExecutedResults(shared) -- 3032
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3032
				end -- 3032
				if shared.role == "sub" then -- 3032
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3040
					clearPreExecutedResults(shared) -- 3041
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3041
				end -- 3041
				AgentUtils.Log( -- 3048
					"Info", -- 3048
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3048
				) -- 3048
				clearPreExecutedResults(shared) -- 3049
				return ____awaiter_resolve(nil, { -- 3049
					success = true, -- 3051
					tool = "finish", -- 3052
					params = {}, -- 3053
					reason = messageContent, -- 3054
					reasoningContent = reasoningContent, -- 3055
					directSummary = messageContent -- 3056
				}) -- 3056
			end -- 3056
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3059
			clearPreExecutedResults(shared) -- 3060
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3060
		end -- 3060
		local decisions = {} -- 3067
		do -- 3067
			local i = 0 -- 3068
			while i < #toolCalls do -- 3068
				local toolCall = toolCalls[i + 1] -- 3069
				local fn = toolCall ~= nil and toolCall["function"] -- 3070
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3070
					AgentUtils.Log( -- 3072
						"Error", -- 3072
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3072
					) -- 3072
					clearPreExecutedResults(shared) -- 3073
					return ____awaiter_resolve( -- 3073
						nil, -- 3073
						{ -- 3074
							success = false, -- 3075
							message = "missing function name for tool call " .. tostring(i + 1), -- 3076
							raw = messageContent -- 3077
						} -- 3077
					) -- 3077
				end -- 3077
				local functionName = fn.name -- 3080
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3081
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3082
				AgentUtils.Log( -- 3085
					"Info", -- 3085
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3085
				) -- 3085
				local decision = parseAndValidateToolCallDecision( -- 3086
					shared, -- 3087
					functionName, -- 3088
					argsText, -- 3089
					toolCallId, -- 3090
					messageContent, -- 3091
					reasoningContent -- 3092
				) -- 3092
				if not decision.success then -- 3092
					AgentUtils.Log( -- 3095
						"Error", -- 3095
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3095
					) -- 3095
					clearPreExecutedResults(shared) -- 3096
					return ____awaiter_resolve(nil, decision) -- 3096
				end -- 3096
				decisions[#decisions + 1] = decision -- 3099
				i = i + 1 -- 3068
			end -- 3068
		end -- 3068
		if #decisions == 1 then -- 3068
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3102
			return ____awaiter_resolve(nil, decisions[1]) -- 3102
		end -- 3102
		do -- 3102
			local i = 0 -- 3105
			while i < #decisions do -- 3105
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3105
					clearPreExecutedResults(shared) -- 3107
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3107
				end -- 3107
				i = i + 1 -- 3105
			end -- 3105
		end -- 3105
		AgentUtils.Log( -- 3115
			"Info", -- 3115
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3115
				__TS__ArrayMap( -- 3115
					decisions, -- 3115
					function(____, decision) return decision.tool end -- 3115
				), -- 3115
				"," -- 3115
			) -- 3115
		) -- 3115
		return ____awaiter_resolve(nil, { -- 3115
			success = true, -- 3117
			kind = "batch", -- 3118
			decisions = decisions, -- 3119
			content = messageContent, -- 3120
			reasoningContent = reasoningContent -- 3121
		}) -- 3121
	end) -- 3121
end -- 2921
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3125
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3125
		AgentUtils.Log( -- 3131
			"Info", -- 3131
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3131
		) -- 3131
		local lastError = initialError -- 3132
		local candidateRaw = "" -- 3133
		local candidateReasoning = nil -- 3134
		do -- 3134
			local attempt = 0 -- 3135
			while attempt < shared.llmMaxTry do -- 3135
				do -- 3135
					AgentUtils.Log( -- 3136
						"Info", -- 3136
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3136
					) -- 3136
					local messages = buildXmlRepairMessages( -- 3137
						shared, -- 3138
						originalRaw, -- 3139
						originalReasoning, -- 3140
						candidateRaw, -- 3141
						candidateReasoning, -- 3142
						lastError, -- 3143
						attempt + 1 -- 3144
					) -- 3144
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3146
					if shared.stopToken.stopped then -- 3146
						return ____awaiter_resolve( -- 3146
							nil, -- 3146
							{ -- 3148
								success = false, -- 3148
								message = getCancelledReason(shared) -- 3148
							} -- 3148
						) -- 3148
					end -- 3148
					if not llmRes.success then -- 3148
						lastError = llmRes.message -- 3151
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3152
						goto __continue530 -- 3153
					end -- 3153
					candidateRaw = llmRes.text -- 3155
					candidateReasoning = llmRes.reasoningContent -- 3156
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3157
					if decision.success then -- 3157
						decision.reasoningContent = llmRes.reasoningContent -- 3159
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3160
						return ____awaiter_resolve(nil, decision) -- 3160
					end -- 3160
					lastError = decision.message -- 3163
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3164
				end -- 3164
				::__continue530:: -- 3164
				attempt = attempt + 1 -- 3135
			end -- 3135
		end -- 3135
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3166
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3166
	end) -- 3166
end -- 3125
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3174
	if attempt == nil then -- 3174
		attempt = 1 -- 3177
	end -- 3177
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3177
		local messages = buildDecisionMessages( -- 3180
			shared, -- 3181
			lastError, -- 3182
			attempt, -- 3183
			lastRaw, -- 3184
			"xml" -- 3185
		) -- 3185
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3187
		if shared.stopToken.stopped then -- 3187
			return ____awaiter_resolve( -- 3187
				nil, -- 3187
				{ -- 3189
					success = false, -- 3189
					message = getCancelledReason(shared) -- 3189
				} -- 3189
			) -- 3189
		end -- 3189
		if not llmRes.success then -- 3189
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3189
		end -- 3189
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3198
		if decision.success then -- 3198
			decision.reasoningContent = llmRes.reasoningContent -- 3200
			return ____awaiter_resolve(nil, decision) -- 3200
		end -- 3200
		return ____awaiter_resolve( -- 3200
			nil, -- 3200
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3203
		) -- 3203
	end) -- 3203
end -- 3174
function MainDecisionAgent.prototype.exec(self, input) -- 3206
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3206
		local shared = input.shared -- 3207
		if shared.stopToken.stopped then -- 3207
			return ____awaiter_resolve( -- 3207
				nil, -- 3207
				{ -- 3209
					success = false, -- 3209
					message = getCancelledReason(shared) -- 3209
				} -- 3209
			) -- 3209
		end -- 3209
		if shared.agentStepCount >= shared.maxSteps then -- 3209
			AgentUtils.Log( -- 3212
				"Warn", -- 3212
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3212
			) -- 3212
			return ____awaiter_resolve( -- 3212
				nil, -- 3212
				{ -- 3213
					success = false, -- 3213
					message = getMaxStepsReachedReason(shared) -- 3213
				} -- 3213
			) -- 3213
		end -- 3213
		if shared.decisionMode == "tool_calling" then -- 3213
			AgentUtils.Log( -- 3217
				"Info", -- 3217
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3217
			) -- 3217
			local lastError = "tool calling validation failed" -- 3218
			local lastRaw = "" -- 3219
			local shouldFallbackToXml = false -- 3220
			do -- 3220
				local attempt = 0 -- 3221
				while attempt < shared.llmMaxTry do -- 3221
					AgentUtils.Log( -- 3222
						"Info", -- 3222
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3222
					) -- 3222
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3223
					if shared.stopToken.stopped then -- 3223
						return ____awaiter_resolve( -- 3223
							nil, -- 3223
							{ -- 3230
								success = false, -- 3230
								message = getCancelledReason(shared) -- 3230
							} -- 3230
						) -- 3230
					end -- 3230
					if decision.success then -- 3230
						return ____awaiter_resolve(nil, decision) -- 3230
					end -- 3230
					lastError = decision.message -- 3235
					lastRaw = decision.raw or "" -- 3236
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3237
					if lastError == "missing tool call" then -- 3237
						shouldFallbackToXml = true -- 3239
						break -- 3240
					end -- 3240
					attempt = attempt + 1 -- 3221
				end -- 3221
			end -- 3221
			if shouldFallbackToXml then -- 3221
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3244
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3245
				do -- 3245
					local attempt = 0 -- 3246
					while attempt < shared.llmMaxTry do -- 3246
						AgentUtils.Log( -- 3247
							"Info", -- 3247
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3247
						) -- 3247
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3248
						if shared.stopToken.stopped then -- 3248
							return ____awaiter_resolve( -- 3248
								nil, -- 3248
								{ -- 3255
									success = false, -- 3255
									message = getCancelledReason(shared) -- 3255
								} -- 3255
							) -- 3255
						end -- 3255
						if decision.success then -- 3255
							return ____awaiter_resolve(nil, decision) -- 3255
						end -- 3255
						lastError = decision.message -- 3260
						lastRaw = decision.raw or "" -- 3261
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3262
						attempt = attempt + 1 -- 3246
					end -- 3246
				end -- 3246
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3264
				return ____awaiter_resolve( -- 3264
					nil, -- 3264
					{ -- 3265
						success = false, -- 3265
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3265
					} -- 3265
				) -- 3265
			end -- 3265
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3267
			return ____awaiter_resolve( -- 3267
				nil, -- 3267
				{ -- 3268
					success = false, -- 3268
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3268
				} -- 3268
			) -- 3268
		end -- 3268
		local lastError = "xml validation failed" -- 3271
		local lastRaw = "" -- 3272
		do -- 3272
			local attempt = 0 -- 3273
			while attempt < shared.llmMaxTry do -- 3273
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3274
				if shared.stopToken.stopped then -- 3274
					return ____awaiter_resolve( -- 3274
						nil, -- 3274
						{ -- 3283
							success = false, -- 3283
							message = getCancelledReason(shared) -- 3283
						} -- 3283
					) -- 3283
				end -- 3283
				if decision.success then -- 3283
					return ____awaiter_resolve(nil, decision) -- 3283
				end -- 3283
				lastError = decision.message -- 3288
				lastRaw = decision.raw or "" -- 3289
				attempt = attempt + 1 -- 3273
			end -- 3273
		end -- 3273
		return ____awaiter_resolve( -- 3273
			nil, -- 3273
			{ -- 3291
				success = false, -- 3291
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3291
			} -- 3291
		) -- 3291
	end) -- 3291
end -- 3206
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3294
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3294
		local result = execRes -- 3295
		if not result.success then -- 3295
			if shared.stopToken.stopped then -- 3295
				shared.error = getCancelledReason(shared) -- 3298
				shared.done = true -- 3299
				return ____awaiter_resolve(nil, "done") -- 3299
			end -- 3299
			shared.error = result.message -- 3302
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3303
			shared.done = true -- 3304
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3305
			persistHistoryState(shared) -- 3309
			return ____awaiter_resolve(nil, "done") -- 3309
		end -- 3309
		if isDecisionBatchSuccess(result) then -- 3309
			local startStep = shared.step -- 3313
			local actions = {} -- 3314
			do -- 3314
				local i = 0 -- 3315
				while i < #result.decisions do -- 3315
					local decision = result.decisions[i + 1] -- 3316
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3317
					local step = startStep + i + 1 -- 3318
					local ____temp_96 -- 3319
					if i == 0 then -- 3319
						____temp_96 = decision.reason -- 3319
					else -- 3319
						____temp_96 = "" -- 3319
					end -- 3319
					local actionReason = ____temp_96 -- 3319
					local ____temp_97 -- 3320
					if i == 0 then -- 3320
						____temp_97 = decision.reasoningContent -- 3320
					else -- 3320
						____temp_97 = nil -- 3320
					end -- 3320
					local actionReasoningContent = ____temp_97 -- 3320
					emitAgentEvent(shared, { -- 3321
						type = "decision_made", -- 3322
						sessionId = shared.sessionId, -- 3323
						taskId = shared.taskId, -- 3324
						step = step, -- 3325
						tool = decision.tool, -- 3326
						reason = actionReason, -- 3327
						reasoningContent = actionReasoningContent, -- 3328
						params = decision.params -- 3329
					}) -- 3329
					local action = { -- 3331
						step = step, -- 3332
						toolCallId = toolCallId, -- 3333
						tool = decision.tool, -- 3334
						reason = actionReason or "", -- 3335
						reasoningContent = actionReasoningContent, -- 3336
						params = decision.params, -- 3337
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3338
					} -- 3338
					local ____shared_history_98 = shared.history -- 3338
					____shared_history_98[#____shared_history_98 + 1] = action -- 3340
					actions[#actions + 1] = action -- 3341
					i = i + 1 -- 3315
				end -- 3315
			end -- 3315
			shared.step = startStep + #actions -- 3343
			shared.agentStepCount = shared.agentStepCount + #actions -- 3344
			shared.pendingToolActions = actions -- 3345
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3346
			persistHistoryState(shared) -- 3352
			return ____awaiter_resolve(nil, "batch_tools") -- 3352
		end -- 3352
		if result.directSummary and result.directSummary ~= "" then -- 3352
			shared.response = result.directSummary -- 3356
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3357
			shared.done = true -- 3361
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3362
			persistHistoryState(shared) -- 3367
			return ____awaiter_resolve(nil, "done") -- 3367
		end -- 3367
		if result.tool == "finish" then -- 3367
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3371
			shared.response = finalMessage -- 3372
			shared.completion = getCompletionReport(result.params) -- 3373
			shared.done = true -- 3374
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3375
			persistHistoryState(shared) -- 3380
			return ____awaiter_resolve(nil, "done") -- 3380
		end -- 3380
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3383
		shared.step = shared.step + 1 -- 3384
		shared.agentStepCount = shared.agentStepCount + 1 -- 3385
		local step = shared.step -- 3386
		emitAgentEvent(shared, { -- 3387
			type = "decision_made", -- 3388
			sessionId = shared.sessionId, -- 3389
			taskId = shared.taskId, -- 3390
			step = step, -- 3391
			tool = result.tool, -- 3392
			reason = result.reason, -- 3393
			reasoningContent = result.reasoningContent, -- 3394
			params = result.params -- 3395
		}) -- 3395
		local ____shared_history_99 = shared.history -- 3395
		____shared_history_99[#____shared_history_99 + 1] = { -- 3397
			step = step, -- 3398
			toolCallId = toolCallId, -- 3399
			tool = result.tool, -- 3400
			reason = result.reason or "", -- 3401
			reasoningContent = result.reasoningContent, -- 3402
			params = result.params, -- 3403
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3404
		} -- 3404
		local action = shared.history[#shared.history] -- 3406
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3407
		shared.pendingToolActions = {action} -- 3410
		persistHistoryState(shared) -- 3411
		return ____awaiter_resolve(nil, "batch_tools") -- 3411
	end) -- 3411
end -- 3294
local ReadFileAction = __TS__Class() -- 3416
ReadFileAction.name = "ReadFileAction" -- 3416
__TS__ClassExtends(ReadFileAction, Node) -- 3416
function ReadFileAction.prototype.prep(self, shared) -- 3417
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3417
		local last = shared.history[#shared.history] -- 3418
		if not last then -- 3418
			error( -- 3419
				__TS__New(Error, "no history"), -- 3419
				0 -- 3419
			) -- 3419
		end -- 3419
		emitAgentStartEvent(shared, last) -- 3420
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3421
		if __TS__StringTrim(path) == "" then -- 3421
			error( -- 3424
				__TS__New(Error, "missing path"), -- 3424
				0 -- 3424
			) -- 3424
		end -- 3424
		local ____path_102 = path -- 3426
		local ____shared_workingDir_103 = shared.workingDir -- 3428
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3429
		local ____last_params_startLine_100 = last.params.startLine -- 3430
		if ____last_params_startLine_100 == nil then -- 3430
			____last_params_startLine_100 = 1 -- 3430
		end -- 3430
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3430
		local ____last_params_endLine_101 = last.params.endLine -- 3431
		if ____last_params_endLine_101 == nil then -- 3431
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3431
		end -- 3431
		return ____awaiter_resolve( -- 3431
			nil, -- 3431
			{ -- 3425
				path = ____path_102, -- 3426
				tool = "read_file", -- 3427
				workDir = ____shared_workingDir_103, -- 3428
				docLanguage = ____temp_104, -- 3429
				startLine = ____TS__Number_result_105, -- 3430
				endLine = __TS__Number(____last_params_endLine_101) -- 3431
			} -- 3431
		) -- 3431
	end) -- 3431
end -- 3417
function ReadFileAction.prototype.exec(self, input) -- 3435
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3435
		return ____awaiter_resolve( -- 3435
			nil, -- 3435
			Tools.readFile( -- 3436
				input.workDir, -- 3437
				input.path, -- 3438
				__TS__Number(input.startLine or 1), -- 3439
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3440
				input.docLanguage -- 3441
			) -- 3441
		) -- 3441
	end) -- 3441
end -- 3435
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3445
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3445
		local result = execRes -- 3446
		local last = shared.history[#shared.history] -- 3447
		if last ~= nil then -- 3447
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3449
			appendToolResultMessage(shared, last) -- 3450
			emitAgentFinishEvent(shared, last) -- 3451
		end -- 3451
		persistHistoryState(shared) -- 3453
		__TS__Await(maybeCompressHistory(shared)) -- 3454
		persistHistoryState(shared) -- 3455
		return ____awaiter_resolve(nil, "main") -- 3455
	end) -- 3455
end -- 3445
local SearchFilesAction = __TS__Class() -- 3460
SearchFilesAction.name = "SearchFilesAction" -- 3460
__TS__ClassExtends(SearchFilesAction, Node) -- 3460
function SearchFilesAction.prototype.prep(self, shared) -- 3461
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3461
		local last = shared.history[#shared.history] -- 3462
		if not last then -- 3462
			error( -- 3463
				__TS__New(Error, "no history"), -- 3463
				0 -- 3463
			) -- 3463
		end -- 3463
		emitAgentStartEvent(shared, last) -- 3464
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3464
	end) -- 3464
end -- 3461
function SearchFilesAction.prototype.exec(self, input) -- 3468
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3468
		local params = input.params -- 3469
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3470
		local ____input_workDir_112 = input.workDir -- 3471
		local ____temp_113 = params.path or "" -- 3472
		local ____temp_114 = params.pattern or "" -- 3473
		local ____params_globs_115 = params.globs -- 3474
		local ____params_useRegex_116 = params.useRegex -- 3475
		local ____params_caseSensitive_117 = params.caseSensitive -- 3476
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3478
		local ____math_max_108 = math.max -- 3479
		local ____math_floor_107 = math.floor -- 3479
		local ____params_limit_106 = params.limit -- 3479
		if ____params_limit_106 == nil then -- 3479
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3479
		end -- 3479
		local ____math_max_108_result_119 = ____math_max_108( -- 3479
			1, -- 3479
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3479
		) -- 3479
		local ____math_max_111 = math.max -- 3480
		local ____math_floor_110 = math.floor -- 3480
		local ____params_offset_109 = params.offset -- 3480
		if ____params_offset_109 == nil then -- 3480
			____params_offset_109 = 0 -- 3480
		end -- 3480
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3470
			workDir = ____input_workDir_112, -- 3471
			path = ____temp_113, -- 3472
			pattern = ____temp_114, -- 3473
			globs = ____params_globs_115, -- 3474
			useRegex = ____params_useRegex_116, -- 3475
			caseSensitive = ____params_caseSensitive_117, -- 3476
			includeContent = true, -- 3477
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3478
			limit = ____math_max_108_result_119, -- 3479
			offset = ____math_max_111( -- 3480
				0, -- 3480
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3480
			), -- 3480
			groupByFile = params.groupByFile == true -- 3481
		})) -- 3481
		return ____awaiter_resolve(nil, result) -- 3481
	end) -- 3481
end -- 3468
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3486
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3486
		local last = shared.history[#shared.history] -- 3487
		if last ~= nil then -- 3487
			local result = execRes -- 3489
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3490
			appendToolResultMessage(shared, last) -- 3491
			emitAgentFinishEvent(shared, last) -- 3492
		end -- 3492
		persistHistoryState(shared) -- 3494
		__TS__Await(maybeCompressHistory(shared)) -- 3495
		persistHistoryState(shared) -- 3496
		return ____awaiter_resolve(nil, "main") -- 3496
	end) -- 3496
end -- 3486
local SearchDoraAPIAction = __TS__Class() -- 3501
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3501
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3501
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3502
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3502
		local last = shared.history[#shared.history] -- 3503
		if not last then -- 3503
			error( -- 3504
				__TS__New(Error, "no history"), -- 3504
				0 -- 3504
			) -- 3504
		end -- 3504
		emitAgentStartEvent(shared, last) -- 3505
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3505
	end) -- 3505
end -- 3502
function SearchDoraAPIAction.prototype.exec(self, input) -- 3509
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3509
		local params = input.params -- 3510
		local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3511
		local ____temp_125 = params.pattern or "" -- 3512
		local ____temp_126 = params.docSource or "api" -- 3513
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3514
		local ____temp_128 = params.programmingLanguage or "ts" -- 3515
		local ____math_min_124 = math.min -- 3516
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3516
		local ____math_max_122 = math.max -- 3516
		local ____params_limit_121 = params.limit -- 3516
		if ____params_limit_121 == nil then -- 3516
			____params_limit_121 = 8 -- 3516
		end -- 3516
		local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3511
			pattern = ____temp_125, -- 3512
			docSource = ____temp_126, -- 3513
			docLanguage = ____temp_127, -- 3514
			programmingLanguage = ____temp_128, -- 3515
			limit = ____math_min_124( -- 3516
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123, -- 3516
				____math_max_122( -- 3516
					1, -- 3516
					__TS__Number(____params_limit_121) -- 3516
				) -- 3516
			), -- 3516
			useRegex = params.useRegex, -- 3517
			caseSensitive = false, -- 3518
			includeContent = true, -- 3519
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3520
		})) -- 3520
		return ____awaiter_resolve(nil, result) -- 3520
	end) -- 3520
end -- 3509
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3525
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3525
		local last = shared.history[#shared.history] -- 3526
		if last ~= nil then -- 3526
			local result = execRes -- 3528
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3529
			appendToolResultMessage(shared, last) -- 3530
			emitAgentFinishEvent(shared, last) -- 3531
		end -- 3531
		persistHistoryState(shared) -- 3533
		__TS__Await(maybeCompressHistory(shared)) -- 3534
		persistHistoryState(shared) -- 3535
		return ____awaiter_resolve(nil, "main") -- 3535
	end) -- 3535
end -- 3525
local ListFilesAction = __TS__Class() -- 3540
ListFilesAction.name = "ListFilesAction" -- 3540
__TS__ClassExtends(ListFilesAction, Node) -- 3540
function ListFilesAction.prototype.prep(self, shared) -- 3541
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3541
		local last = shared.history[#shared.history] -- 3542
		if not last then -- 3542
			error( -- 3543
				__TS__New(Error, "no history"), -- 3543
				0 -- 3543
			) -- 3543
		end -- 3543
		emitAgentStartEvent(shared, last) -- 3544
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3544
	end) -- 3544
end -- 3541
function ListFilesAction.prototype.exec(self, input) -- 3548
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3548
		local params = input.params -- 3549
		local ____Tools_listFiles_136 = Tools.listFiles -- 3550
		local ____input_workDir_133 = input.workDir -- 3551
		local ____temp_134 = params.path or "" -- 3552
		local ____params_globs_135 = params.globs -- 3553
		local ____math_max_132 = math.max -- 3554
		local ____math_floor_131 = math.floor -- 3554
		local ____params_maxEntries_130 = params.maxEntries -- 3554
		if ____params_maxEntries_130 == nil then -- 3554
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3554
		end -- 3554
		local result = ____Tools_listFiles_136({ -- 3550
			workDir = ____input_workDir_133, -- 3551
			path = ____temp_134, -- 3552
			globs = ____params_globs_135, -- 3553
			maxEntries = ____math_max_132( -- 3554
				1, -- 3554
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3554
			) -- 3554
		}) -- 3554
		return ____awaiter_resolve(nil, result) -- 3554
	end) -- 3554
end -- 3548
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3559
		local last = shared.history[#shared.history] -- 3560
		if last ~= nil then -- 3560
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3562
			appendToolResultMessage(shared, last) -- 3563
			emitAgentFinishEvent(shared, last) -- 3564
		end -- 3564
		persistHistoryState(shared) -- 3566
		__TS__Await(maybeCompressHistory(shared)) -- 3567
		persistHistoryState(shared) -- 3568
		return ____awaiter_resolve(nil, "main") -- 3568
	end) -- 3568
end -- 3559
local DeleteFileAction = __TS__Class() -- 3573
DeleteFileAction.name = "DeleteFileAction" -- 3573
__TS__ClassExtends(DeleteFileAction, Node) -- 3573
function DeleteFileAction.prototype.prep(self, shared) -- 3574
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3574
		local last = shared.history[#shared.history] -- 3575
		if not last then -- 3575
			error( -- 3576
				__TS__New(Error, "no history"), -- 3576
				0 -- 3576
			) -- 3576
		end -- 3576
		emitAgentStartEvent(shared, last) -- 3577
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3578
		if __TS__StringTrim(targetFile) == "" then -- 3578
			error( -- 3581
				__TS__New(Error, "missing target_file"), -- 3581
				0 -- 3581
			) -- 3581
		end -- 3581
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3581
	end) -- 3581
end -- 3574
function DeleteFileAction.prototype.exec(self, input) -- 3585
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3585
		local result = Tools.deleteFile(input.taskId, input.workDir, input.targetFile, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3586
		if not result.success then -- 3586
			return ____awaiter_resolve(nil, result) -- 3586
		end -- 3586
		local ____result_checkpointed_138 = result.checkpointed -- 3597
		local ____result_reversible_139 = result.reversible -- 3598
		local ____result_binary_140 = result.binary -- 3599
		local ____temp_141 = result.checkpointed and result.checkpointId or nil -- 3600
		local ____temp_142 = result.checkpointed and result.checkpointSeq or nil -- 3601
		local ____result_checkpointed_137 -- 3602
		if result.checkpointed then -- 3602
			____result_checkpointed_137 = nil -- 3602
		else -- 3602
			____result_checkpointed_137 = result.message -- 3602
		end -- 3602
		return ____awaiter_resolve(nil, { -- 3602
			success = true, -- 3594
			changed = true, -- 3595
			mode = "delete", -- 3596
			checkpointed = ____result_checkpointed_138, -- 3597
			reversible = ____result_reversible_139, -- 3598
			binary = ____result_binary_140, -- 3599
			checkpointId = ____temp_141, -- 3600
			checkpointSeq = ____temp_142, -- 3601
			message = ____result_checkpointed_137, -- 3602
			files = {{path = input.targetFile, op = "delete"}} -- 3603
		}) -- 3603
	end) -- 3603
end -- 3585
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3607
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3607
		local last = shared.history[#shared.history] -- 3608
		if last ~= nil then -- 3608
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3610
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3611
			appendToolResultMessage(shared, last) -- 3612
			emitAgentFinishEvent(shared, last) -- 3613
			local result = last.result -- 3614
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3614
				emitAgentEvent(shared, { -- 3619
					type = "checkpoint_created", -- 3620
					sessionId = shared.sessionId, -- 3621
					taskId = shared.taskId, -- 3622
					step = last.step, -- 3623
					tool = "delete_file", -- 3624
					checkpointId = result.checkpointId, -- 3625
					checkpointSeq = result.checkpointSeq, -- 3626
					files = result.files -- 3627
				}) -- 3627
			end -- 3627
		end -- 3627
		persistHistoryState(shared) -- 3634
		__TS__Await(maybeCompressHistory(shared)) -- 3635
		persistHistoryState(shared) -- 3636
		return ____awaiter_resolve(nil, "main") -- 3636
	end) -- 3636
end -- 3607
local BuildAction = __TS__Class() -- 3641
BuildAction.name = "BuildAction" -- 3641
__TS__ClassExtends(BuildAction, Node) -- 3641
function BuildAction.prototype.prep(self, shared) -- 3642
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3642
		local last = shared.history[#shared.history] -- 3643
		if not last then -- 3643
			error( -- 3644
				__TS__New(Error, "no history"), -- 3644
				0 -- 3644
			) -- 3644
		end -- 3644
		emitAgentStartEvent(shared, last) -- 3645
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3645
	end) -- 3645
end -- 3642
function BuildAction.prototype.exec(self, input) -- 3649
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3649
		local params = input.params -- 3650
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3651
		return ____awaiter_resolve(nil, result) -- 3651
	end) -- 3651
end -- 3649
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3658
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3658
		local last = shared.history[#shared.history] -- 3659
		if last ~= nil then -- 3659
			last.result = sanitizeBuildResultForHistory(execRes) -- 3661
			appendToolResultMessage(shared, last) -- 3662
			emitAgentFinishEvent(shared, last) -- 3663
		end -- 3663
		persistHistoryState(shared) -- 3665
		__TS__Await(maybeCompressHistory(shared)) -- 3666
		persistHistoryState(shared) -- 3667
		return ____awaiter_resolve(nil, "main") -- 3667
	end) -- 3667
end -- 3658
local SpawnSubAgentAction = __TS__Class() -- 3672
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3672
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3672
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3673
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3673
		local last = shared.history[#shared.history] -- 3683
		if not last then -- 3683
			error( -- 3684
				__TS__New(Error, "no history"), -- 3684
				0 -- 3684
			) -- 3684
		end -- 3684
		emitAgentStartEvent(shared, last) -- 3685
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3686
			last.params.filesHint, -- 3687
			function(____, item) return type(item) == "string" end -- 3687
		) or nil -- 3687
		return ____awaiter_resolve( -- 3687
			nil, -- 3687
			{ -- 3689
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3690
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3691
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3692
				filesHint = filesHint, -- 3693
				sessionId = shared.sessionId, -- 3694
				projectRoot = shared.workingDir, -- 3695
				spawnSubAgent = shared.spawnSubAgent, -- 3696
				disabledAgentTools = shared.disabledAgentTools -- 3697
			} -- 3697
		) -- 3697
	end) -- 3697
end -- 3673
function SpawnSubAgentAction.prototype.exec(self, input) -- 3701
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3701
		if not input.spawnSubAgent then -- 3701
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3701
		end -- 3701
		if input.sessionId == nil or input.sessionId <= 0 then -- 3701
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3701
		end -- 3701
		local ____AgentUtils_Log_148 = AgentUtils.Log -- 3717
		local ____temp_145 = #input.title -- 3717
		local ____temp_146 = #input.prompt -- 3717
		local ____temp_147 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3717
		local ____opt_143 = input.filesHint -- 3717
		____AgentUtils_Log_148( -- 3717
			"Info", -- 3717
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_145)) .. " prompt_len=") .. tostring(____temp_146)) .. " expected_len=") .. tostring(____temp_147)) .. " files_hint_count=") .. tostring(____opt_143 and #____opt_143 or 0) -- 3717
		) -- 3717
		local result = __TS__Await(input.spawnSubAgent({ -- 3718
			parentSessionId = input.sessionId, -- 3719
			projectRoot = input.projectRoot, -- 3720
			title = input.title, -- 3721
			prompt = input.prompt, -- 3722
			expectedOutput = input.expectedOutput, -- 3723
			filesHint = input.filesHint, -- 3724
			disabledAgentTools = input.disabledAgentTools -- 3725
		})) -- 3725
		if not result.success then -- 3725
			return ____awaiter_resolve(nil, result) -- 3725
		end -- 3725
		return ____awaiter_resolve(nil, { -- 3725
			success = true, -- 3731
			sessionId = result.sessionId, -- 3732
			taskId = result.taskId, -- 3733
			title = result.title, -- 3734
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3735
		}) -- 3735
	end) -- 3735
end -- 3701
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3739
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3739
		local last = shared.history[#shared.history] -- 3740
		if last ~= nil then -- 3740
			last.result = execRes -- 3742
			if execRes.success == true then -- 3742
				shared.hasSpawnedSubAgentThisTask = true -- 3744
			end -- 3744
			appendToolResultMessage(shared, last) -- 3746
			emitAgentFinishEvent(shared, last) -- 3747
		end -- 3747
		persistHistoryState(shared) -- 3749
		__TS__Await(maybeCompressHistory(shared)) -- 3750
		persistHistoryState(shared) -- 3751
		return ____awaiter_resolve(nil, "main") -- 3751
	end) -- 3751
end -- 3739
local ListSubAgentsAction = __TS__Class() -- 3756
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3756
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3756
function ListSubAgentsAction.prototype.prep(self, shared) -- 3757
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3757
		local last = shared.history[#shared.history] -- 3767
		if not last then -- 3767
			error( -- 3768
				__TS__New(Error, "no history"), -- 3768
				0 -- 3768
			) -- 3768
		end -- 3768
		emitAgentStartEvent(shared, last) -- 3769
		return ____awaiter_resolve( -- 3769
			nil, -- 3769
			{ -- 3770
				sessionId = shared.sessionId, -- 3771
				projectRoot = shared.workingDir, -- 3772
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3773
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3774
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3775
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3776
				listSubAgents = shared.listSubAgents, -- 3777
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3778
			} -- 3778
		) -- 3778
	end) -- 3778
end -- 3757
function ListSubAgentsAction.prototype.exec(self, input) -- 3782
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3782
		if not input.listSubAgents then -- 3782
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3782
		end -- 3782
		if input.sessionId == nil or input.sessionId <= 0 then -- 3782
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3782
		end -- 3782
		local result = __TS__Await(input.listSubAgents({ -- 3798
			sessionId = input.sessionId, -- 3799
			projectRoot = input.projectRoot, -- 3800
			status = input.status, -- 3801
			limit = input.limit, -- 3802
			offset = input.offset, -- 3803
			query = input.query -- 3804
		})) -- 3804
		return ____awaiter_resolve( -- 3804
			nil, -- 3804
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3806
		) -- 3806
	end) -- 3806
end -- 3782
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3814
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3814
		local last = shared.history[#shared.history] -- 3815
		if last ~= nil then -- 3815
			last.result = execRes -- 3817
			appendToolResultMessage(shared, last) -- 3818
			emitAgentFinishEvent(shared, last) -- 3819
		end -- 3819
		persistHistoryState(shared) -- 3821
		__TS__Await(maybeCompressHistory(shared)) -- 3822
		persistHistoryState(shared) -- 3823
		return ____awaiter_resolve(nil, "main") -- 3823
	end) -- 3823
end -- 3814
EditFileAction = __TS__Class() -- 3828
EditFileAction.name = "EditFileAction" -- 3828
__TS__ClassExtends(EditFileAction, Node) -- 3828
function EditFileAction.prototype.prep(self, shared) -- 3829
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3829
		local last = shared.history[#shared.history] -- 3830
		if not last then -- 3830
			error( -- 3831
				__TS__New(Error, "no history"), -- 3831
				0 -- 3831
			) -- 3831
		end -- 3831
		emitAgentStartEvent(shared, last) -- 3832
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3833
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3836
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3837
		if __TS__StringTrim(path) == "" then -- 3837
			error( -- 3838
				__TS__New(Error, "missing path"), -- 3838
				0 -- 3838
			) -- 3838
		end -- 3838
		return ____awaiter_resolve(nil, { -- 3838
			path = path, -- 3839
			oldStr = oldStr, -- 3839
			newStr = newStr, -- 3839
			taskId = shared.taskId, -- 3839
			workDir = shared.workingDir -- 3839
		}) -- 3839
	end) -- 3839
end -- 3829
function EditFileAction.prototype.exec(self, input) -- 3842
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3842
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3843
		if not readRes.success then -- 3843
			if input.oldStr ~= "" then -- 3843
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3843
			end -- 3843
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3848
			if not createRes.success then -- 3848
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3848
			end -- 3848
			return ____awaiter_resolve( -- 3848
				nil, -- 3848
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3855
					success = true, -- 3856
					changed = true, -- 3857
					mode = "create", -- 3858
					checkpointId = createRes.checkpointId, -- 3859
					checkpointSeq = createRes.checkpointSeq, -- 3860
					files = {{path = input.path, op = "create"}} -- 3861
				}) -- 3861
			) -- 3861
		end -- 3861
		if input.oldStr == "" then -- 3861
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3861
				return ____awaiter_resolve( -- 3861
					nil, -- 3861
					{ -- 3866
						success = false, -- 3867
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3868
						actualSaved = false, -- 3869
						actualSavedCharacters = 0, -- 3870
						currentFileExists = true, -- 3871
						currentCharacters = #readRes.content, -- 3872
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3873
					} -- 3873
				) -- 3873
			end -- 3873
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3876
			if not overwriteRes.success then -- 3876
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3876
			end -- 3876
			return ____awaiter_resolve( -- 3876
				nil, -- 3876
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3883
					success = true, -- 3884
					changed = true, -- 3885
					mode = "overwrite", -- 3886
					checkpointId = overwriteRes.checkpointId, -- 3887
					checkpointSeq = overwriteRes.checkpointSeq, -- 3888
					files = {{path = input.path, op = "write"}} -- 3889
				}) -- 3889
			) -- 3889
		end -- 3889
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3894
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3895
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3896
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3899
		if occurrences == 0 then -- 3899
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3901
			if not indentTolerant.success then -- 3901
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3901
			end -- 3901
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3905
			if not applyRes.success then -- 3905
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3905
			end -- 3905
			return ____awaiter_resolve( -- 3905
				nil, -- 3905
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3912
					success = true, -- 3913
					changed = true, -- 3914
					mode = "replace_indent_tolerant", -- 3915
					checkpointId = applyRes.checkpointId, -- 3916
					checkpointSeq = applyRes.checkpointSeq, -- 3917
					files = {{path = input.path, op = "write"}} -- 3918
				}) -- 3918
			) -- 3918
		end -- 3918
		if occurrences > 1 then -- 3918
			return ____awaiter_resolve( -- 3918
				nil, -- 3918
				{ -- 3922
					success = false, -- 3922
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3922
				} -- 3922
			) -- 3922
		end -- 3922
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3926
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3927
		if not applyRes.success then -- 3927
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3927
		end -- 3927
		return ____awaiter_resolve( -- 3927
			nil, -- 3927
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3934
				success = true, -- 3935
				changed = true, -- 3936
				mode = "replace", -- 3937
				checkpointId = applyRes.checkpointId, -- 3938
				checkpointSeq = applyRes.checkpointSeq, -- 3939
				files = {{path = input.path, op = "write"}} -- 3940
			}) -- 3940
		) -- 3940
	end) -- 3940
end -- 3842
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3944
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3944
		local last = shared.history[#shared.history] -- 3945
		if last ~= nil then -- 3945
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3947
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3948
			appendToolResultMessage(shared, last) -- 3949
			emitAgentFinishEvent(shared, last) -- 3950
			local result = last.result -- 3951
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3951
				emitAgentEvent(shared, { -- 3956
					type = "checkpoint_created", -- 3957
					sessionId = shared.sessionId, -- 3958
					taskId = shared.taskId, -- 3959
					step = last.step, -- 3960
					tool = last.tool, -- 3961
					checkpointId = result.checkpointId, -- 3962
					checkpointSeq = result.checkpointSeq, -- 3963
					files = result.files -- 3964
				}) -- 3964
			end -- 3964
		end -- 3964
		persistHistoryState(shared) -- 3971
		__TS__Await(maybeCompressHistory(shared)) -- 3972
		persistHistoryState(shared) -- 3973
		return ____awaiter_resolve(nil, "main") -- 3973
	end) -- 3973
end -- 3944
local FetchUrlAction = __TS__Class() -- 3978
FetchUrlAction.name = "FetchUrlAction" -- 3978
__TS__ClassExtends(FetchUrlAction, Node) -- 3978
function FetchUrlAction.prototype.prep(self, shared) -- 3979
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3979
		local last = shared.history[#shared.history] -- 3980
		if not last then -- 3980
			error( -- 3981
				__TS__New(Error, "no history"), -- 3981
				0 -- 3981
			) -- 3981
		end -- 3981
		emitAgentStartEvent(shared, last) -- 3982
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3982
	end) -- 3982
end -- 3979
function FetchUrlAction.prototype.exec(self, input) -- 3986
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3986
		return ____awaiter_resolve( -- 3986
			nil, -- 3986
			executeToolAction(input.shared, input.action) -- 3987
		) -- 3987
	end) -- 3987
end -- 3986
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3990
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3990
		local last = shared.history[#shared.history] -- 3991
		if last ~= nil then -- 3991
			last.result = execRes -- 3993
			appendToolResultMessage(shared, last) -- 3994
			emitAgentFinishEvent(shared, last) -- 3995
		end -- 3995
		persistHistoryState(shared) -- 3997
		__TS__Await(maybeCompressHistory(shared)) -- 3998
		persistHistoryState(shared) -- 3999
		return ____awaiter_resolve(nil, "main") -- 3999
	end) -- 3999
end -- 3990
local function emitCheckpointEventForAction(shared, action) -- 4004
	local result = action.result -- 4005
	if not result then -- 4005
		return -- 4006
	end -- 4006
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4006
		emitAgentEvent(shared, { -- 4011
			type = "checkpoint_created", -- 4012
			sessionId = shared.sessionId, -- 4013
			taskId = shared.taskId, -- 4014
			step = action.step, -- 4015
			tool = action.tool, -- 4016
			checkpointId = result.checkpointId, -- 4017
			checkpointSeq = result.checkpointSeq, -- 4018
			files = result.files -- 4019
		}) -- 4019
	end -- 4019
end -- 4004
local function canRunBatchActionInParallel(self, action) -- 4550
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4551
end -- 4550
local function partitionToolCalls(actions) -- 4559
	local batches = {} -- 4560
	do -- 4560
		local i = 0 -- 4561
		while i < #actions do -- 4561
			local action = actions[i + 1] -- 4562
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4563
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4564
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4564
				local ____lastBatch_actions_187 = lastBatch.actions -- 4564
				____lastBatch_actions_187[#____lastBatch_actions_187 + 1] = action -- 4566
			else -- 4566
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4568
			end -- 4568
			i = i + 1 -- 4561
		end -- 4561
	end -- 4561
	return batches -- 4571
end -- 4559
local function completeStoppedToolAction(shared, action) -- 4574
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4575
	if not action.result then -- 4575
		action.result = { -- 4577
			success = false, -- 4577
			message = getCancelledReason(shared) -- 4577
		} -- 4577
	end -- 4577
	appendToolResultMessage(shared, action) -- 4579
	emitAgentFinishEvent(shared, action) -- 4580
	emitCheckpointEventForAction(shared, action) -- 4581
end -- 4574
local BatchToolAction = __TS__Class() -- 4584
BatchToolAction.name = "BatchToolAction" -- 4584
__TS__ClassExtends(BatchToolAction, Node) -- 4584
function BatchToolAction.prototype.prep(self, shared) -- 4585
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4585
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4585
	end) -- 4585
end -- 4585
function BatchToolAction.prototype.exec(self, input) -- 4589
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4589
		local shared = input.shared -- 4590
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4591
		local preExecuted = shared.preExecutedResults -- 4592
		local batches = partitionToolCalls(input.actions) -- 4593
		local parallelBatchCount = #__TS__ArrayFilter( -- 4594
			batches, -- 4594
			function(____, b) return b.isConcurrencySafe end -- 4594
		) -- 4594
		local serialBatchCount = #__TS__ArrayFilter( -- 4595
			batches, -- 4595
			function(____, b) return not b.isConcurrencySafe end -- 4595
		) -- 4595
		AgentUtils.Log( -- 4596
			"Info", -- 4596
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4596
		) -- 4596
		do -- 4596
			local batchIdx = 0 -- 4598
			while batchIdx < #batches do -- 4598
				do -- 4598
					local batch = batches[batchIdx + 1] -- 4599
					if shared.stopToken.stopped then -- 4599
						for ____, action in ipairs(batch.actions) do -- 4601
							completeStoppedToolAction(shared, action) -- 4602
						end -- 4602
						goto __continue761 -- 4604
					end -- 4604
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4604
						local preExecCount = #__TS__ArrayFilter( -- 4608
							batch.actions, -- 4608
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4608
						) -- 4608
						AgentUtils.Log( -- 4609
							"Info", -- 4609
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4609
						) -- 4609
						do -- 4609
							local i = 0 -- 4610
							while i < #batch.actions do -- 4610
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4611
								i = i + 1 -- 4610
							end -- 4610
						end -- 4610
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4613
							batch.actions, -- 4613
							function(____, action) -- 4613
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4613
									if shared.stopToken.stopped then -- 4613
										action.result = { -- 4615
											success = false, -- 4615
											message = getCancelledReason(shared) -- 4615
										} -- 4615
										return ____awaiter_resolve(nil, action) -- 4615
									end -- 4615
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4618
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4619
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4620
									return ____awaiter_resolve(nil, action) -- 4620
								end) -- 4620
							end -- 4613
						))) -- 4613
						do -- 4613
							local i = 0 -- 4623
							while i < #batch.actions do -- 4623
								local action = batch.actions[i + 1] -- 4624
								if not action.result then -- 4624
									action.result = {success = false, message = "tool did not produce a result"} -- 4626
								end -- 4626
								appendToolResultMessage(shared, action) -- 4628
								emitAgentFinishEvent(shared, action) -- 4629
								emitCheckpointEventForAction(shared, action) -- 4630
								i = i + 1 -- 4623
							end -- 4623
						end -- 4623
					else -- 4623
						AgentUtils.Log( -- 4633
							"Info", -- 4633
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4633
						) -- 4633
						do -- 4633
							local i = 0 -- 4634
							while i < #batch.actions do -- 4634
								local action = batch.actions[i + 1] -- 4635
								emitAgentStartEvent(shared, action) -- 4636
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4637
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4638
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4639
								appendToolResultMessage(shared, action) -- 4640
								emitAgentFinishEvent(shared, action) -- 4641
								emitCheckpointEventForAction(shared, action) -- 4642
								persistHistoryState(shared) -- 4643
								if shared.stopToken.stopped then -- 4643
									do -- 4643
										local j = i + 1 -- 4645
										while j < #batch.actions do -- 4645
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4646
											j = j + 1 -- 4645
										end -- 4645
									end -- 4645
									break -- 4648
								end -- 4648
								i = i + 1 -- 4634
							end -- 4634
						end -- 4634
					end -- 4634
				end -- 4634
				::__continue761:: -- 4634
				batchIdx = batchIdx + 1 -- 4598
			end -- 4598
		end -- 4598
		local spawnSeen = spawnedBeforeBatch -- 4653
		local didDelegatedForegroundWork = false -- 4654
		do -- 4654
			local i = 0 -- 4655
			while i < #input.actions do -- 4655
				do -- 4655
					local action = input.actions[i + 1] -- 4656
					if action.tool == "spawn_sub_agent" then -- 4656
						local ____opt_190 = action.result -- 4656
						if (____opt_190 and ____opt_190.success) == true then -- 4656
							spawnSeen = true -- 4658
						end -- 4658
						goto __continue781 -- 4659
					end -- 4659
					if spawnSeen and action.tool ~= "finish" then -- 4659
						didDelegatedForegroundWork = true -- 4662
					end -- 4662
				end -- 4662
				::__continue781:: -- 4662
				i = i + 1 -- 4655
			end -- 4655
		end -- 4655
		if didDelegatedForegroundWork then -- 4655
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4666
		end -- 4666
		persistHistoryState(shared) -- 4668
		return ____awaiter_resolve(nil, input.actions) -- 4668
	end) -- 4668
end -- 4589
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4672
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4672
		shared.pendingToolActions = nil -- 4673
		shared.preExecutedResults = nil -- 4674
		persistHistoryState(shared) -- 4675
		if shared.waitingQuestionnaireId == nil then -- 4675
			__TS__Await(maybeCompressHistory(shared)) -- 4679
			persistHistoryState(shared) -- 4680
		end -- 4680
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4680
	end) -- 4680
end -- 4672
local EndNode = __TS__Class() -- 4686
EndNode.name = "EndNode" -- 4686
__TS__ClassExtends(EndNode, Node) -- 4686
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4687
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4687
		return ____awaiter_resolve(nil, nil) -- 4687
	end) -- 4687
end -- 4687
local CodingAgentFlow = __TS__Class() -- 4692
CodingAgentFlow.name = "CodingAgentFlow" -- 4692
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4692
function CodingAgentFlow.prototype.____constructor(self, role) -- 4693
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4694
	local read = __TS__New(ReadFileAction, 1, 0) -- 4695
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4696
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4697
	local list = __TS__New(ListFilesAction, 1, 0) -- 4698
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4699
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4700
	local build = __TS__New(BuildAction, 1, 0) -- 4701
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4702
	local edit = __TS__New(EditFileAction, 1, 0) -- 4703
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4704
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4705
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4706
	local done = __TS__New(EndNode, 1, 0) -- 4707
	main:on("batch_tools", batch) -- 4709
	main:on("grep_files", search) -- 4710
	main:on("search_dora_api", searchDora) -- 4711
	main:on("glob_files", list) -- 4712
	main:on("fetch_url", fetch) -- 4713
	main:on("execute_command", exec) -- 4714
	if role == "main" then -- 4714
		main:on("read_file", read) -- 4716
		main:on("delete_file", del) -- 4717
		main:on("build", build) -- 4718
		main:on("edit_file", edit) -- 4719
		main:on("list_sub_agents", listSub) -- 4720
		main:on("spawn_sub_agent", spawn) -- 4721
	else -- 4721
		main:on("read_file", read) -- 4723
		main:on("delete_file", del) -- 4724
		main:on("build", build) -- 4725
		main:on("edit_file", edit) -- 4726
	end -- 4726
	main:on("done", done) -- 4728
	search:on("main", main) -- 4730
	searchDora:on("main", main) -- 4731
	list:on("main", main) -- 4732
	listSub:on("main", main) -- 4733
	spawn:on("main", main) -- 4734
	batch:on("main", main) -- 4735
	batch:on("done", done) -- 4736
	read:on("main", main) -- 4737
	del:on("main", main) -- 4738
	build:on("main", main) -- 4739
	edit:on("main", main) -- 4740
	fetch:on("main", main) -- 4741
	exec:on("main", main) -- 4742
	Flow.prototype.____constructor(self, main) -- 4744
end -- 4693
local function runCodingAgentAsync(options) -- 4780
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4780
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4780
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4780
		end -- 4780
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4784
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4785
		if not llmConfigRes.success then -- 4785
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4785
		end -- 4785
		local llmConfig = llmConfigRes.config -- 4791
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4792
		if not taskRes.success then -- 4792
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4792
		end -- 4792
		local compressor = __TS__New(MemoryCompressor, { -- 4799
			compressionTargetThreshold = 0.5, -- 4800
			maxCompressionRounds = 3, -- 4801
			projectDir = options.workDir, -- 4802
			llmConfig = llmConfig, -- 4803
			promptPack = options.promptPack, -- 4804
			scope = options.memoryScope -- 4805
		}) -- 4805
		local persistedSession = compressor:getStorage():readSessionState() -- 4807
		local effectiveUserQuery = normalizedPrompt -- 4808
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4808
			do -- 4808
				local i = #persistedSession.messages - 1 -- 4810
				while i >= 0 do -- 4810
					local message = persistedSession.messages[i + 1] -- 4811
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4811
						effectiveUserQuery = message.content -- 4813
						break -- 4814
					end -- 4814
					i = i - 1 -- 4810
				end -- 4810
			end -- 4810
		end -- 4810
		local promptPack = compressor:getPromptPack() -- 4818
		local freshProject = inspectFreshProject(options.workDir) -- 4819
		local freshProjectBuildPending = freshProject.fresh -- 4820
		local freshProjectCodeFile = freshProject.codeFile -- 4821
		local shared = { -- 4823
			sessionId = options.sessionId, -- 4824
			taskId = taskRes.taskId, -- 4825
			role = options.role or "main", -- 4826
			maxSteps = math.max( -- 4827
				1, -- 4827
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4827
			), -- 4827
			llmMaxTry = math.max( -- 4828
				1, -- 4828
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4828
			), -- 4828
			step = math.max( -- 4829
				0, -- 4829
				math.floor(options.initialStep or 0) -- 4829
			), -- 4829
			agentStepCount = math.max( -- 4830
				0, -- 4830
				math.floor(options.initialAgentStepCount or 0) -- 4830
			), -- 4830
			done = false, -- 4831
			stopToken = options.stopToken or ({stopped = false}), -- 4832
			response = "", -- 4833
			userQuery = effectiveUserQuery, -- 4834
			workingDir = options.workDir, -- 4835
			useChineseResponse = options.useChineseResponse == true, -- 4836
			workMode = options.workMode or "code", -- 4837
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4838
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4841
			llmConfig = llmConfig, -- 4842
			onEvent = options.onEvent, -- 4843
			promptPack = promptPack, -- 4844
			history = {}, -- 4845
			messages = persistedSession.messages, -- 4846
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4847
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4848
			memory = {compressor = compressor}, -- 4850
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4854
				projectDir = options.workDir, -- 4856
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4857
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4858
			})}, -- 4858
			spawnSubAgent = options.spawnSubAgent, -- 4864
			listSubAgents = options.listSubAgents, -- 4865
			publishQuestionnaire = options.publishQuestionnaire, -- 4866
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4867
			freshProjectBuildPending = freshProjectBuildPending, -- 4868
			freshProjectCodeFile = freshProjectCodeFile, -- 4869
			hasSpawnedSubAgentThisTask = false, -- 4870
			delegatedForegroundBatches = 0, -- 4871
			tokenUsage = options.initialTokenUsage -- 4872
		} -- 4872
		local ____hasReturned, ____returnValue -- 4872
		local ____try = __TS__AsyncAwaiter(function() -- 4872
			if shared.workMode == "plan" then -- 4872
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4877
				if not planDocuments.success then -- 4877
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4879
					____hasReturned = true -- 4880
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4880
					return -- 4880
				end -- 4880
			end -- 4880
			emitAgentEvent(shared, { -- 4883
				type = "task_started", -- 4884
				sessionId = shared.sessionId, -- 4885
				taskId = shared.taskId, -- 4886
				prompt = shared.userQuery, -- 4887
				workDir = shared.workingDir, -- 4888
				maxSteps = shared.maxSteps, -- 4889
				resumed = options.resumeTask == true -- 4890
			}) -- 4890
			if shared.stopToken.stopped then -- 4890
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4893
				____hasReturned = true -- 4894
				____returnValue = emitAgentTaskFinishEvent( -- 4894
					shared, -- 4894
					false, -- 4894
					getCancelledReason(shared) -- 4894
				) -- 4894
				return -- 4894
			end -- 4894
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4896
			local ____temp_192 -- 4897
			if options.resumeConversation == true then -- 4897
				____temp_192 = nil -- 4897
			else -- 4897
				____temp_192 = getPromptCommand(shared.userQuery) -- 4897
			end -- 4897
			local promptCommand = ____temp_192 -- 4897
			if promptCommand == "clear" then -- 4897
				____hasReturned = true -- 4899
				____returnValue = clearSessionHistory(shared) -- 4899
				return -- 4899
			end -- 4899
			if promptCommand == "compact" then -- 4899
				if shared.role == "sub" then -- 4899
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4903
					____hasReturned = true -- 4904
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4904
					return -- 4904
				end -- 4904
				____hasReturned = true -- 4912
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4912
				return -- 4912
			end -- 4912
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4914
			if shared.stopToken.stopped then -- 4914
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4916
				____hasReturned = true -- 4917
				____returnValue = emitAgentTaskFinishEvent( -- 4917
					shared, -- 4917
					false, -- 4917
					getCancelledReason(shared) -- 4917
				) -- 4917
				return -- 4917
			end -- 4917
			if options.resumeConversation ~= true then -- 4917
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4920
				persistHistoryState(shared) -- 4924
			end -- 4924
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4926
			__TS__Await(flow:run(shared)) -- 4927
			if shared.stopToken.stopped then -- 4927
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4929
				____hasReturned = true -- 4930
				____returnValue = emitAgentTaskFinishEvent( -- 4930
					shared, -- 4930
					false, -- 4930
					getCancelledReason(shared) -- 4930
				) -- 4930
				return -- 4930
			end -- 4930
			if shared.error then -- 4930
				____hasReturned = true -- 4933
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4933
				return -- 4933
			end -- 4933
			if shared.waitingQuestionnaireId ~= nil then -- 4933
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4937
				emitAgentEvent(shared, { -- 4938
					type = "task_waiting_for_user", -- 4939
					sessionId = shared.sessionId, -- 4940
					taskId = shared.taskId, -- 4941
					step = shared.step, -- 4942
					questionnaireId = shared.waitingQuestionnaireId -- 4943
				}) -- 4943
				____hasReturned = true -- 4945
				____returnValue = { -- 4945
					success = true, -- 4946
					taskId = shared.taskId, -- 4947
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4948
					steps = shared.step, -- 4949
					waitingForUser = true, -- 4950
					questionnaireId = shared.waitingQuestionnaireId -- 4951
				} -- 4951
				return -- 4945
			end -- 4945
			local ____isFinalDecisionTurn_result_195 = isFinalDecisionTurn(shared) -- 4954
			if ____isFinalDecisionTurn_result_195 then -- 4954
				local ____opt_193 = shared.completion -- 4954
				____isFinalDecisionTurn_result_195 = (____opt_193 and ____opt_193.outcome) == "partial" -- 4954
			end -- 4954
			if ____isFinalDecisionTurn_result_195 then -- 4954
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4955
				____hasReturned = true -- 4956
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4956
				return -- 4956
			end -- 4956
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4959
			____hasReturned = true -- 4960
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4960
			return -- 4960
		end) -- 4960
		____try = ____try.catch( -- 4960
			____try, -- 4960
			function(____, e) -- 4960
				return __TS__AsyncAwaiter(function() -- 4960
					____hasReturned = true -- 4963
					____returnValue = finalizeAgentFailure( -- 4963
						shared, -- 4963
						tostring(e) -- 4963
					) -- 4963
					return -- 4963
				end) -- 4963
			end -- 4963
		) -- 4963
		__TS__Await(____try) -- 4875
		if ____hasReturned then -- 4875
			return ____awaiter_resolve(nil, ____returnValue) -- 4875
		end -- 4875
	end) -- 4875
end -- 4780
function ____exports.runCodingAgent(options, callback) -- 4967
	local ____self_196 = runCodingAgentAsync(options) -- 4967
	____self_196["then"]( -- 4967
		____self_196, -- 4967
		function(____, result) return callback(result) end -- 4968
	) -- 4968
end -- 4967
return ____exports -- 4967