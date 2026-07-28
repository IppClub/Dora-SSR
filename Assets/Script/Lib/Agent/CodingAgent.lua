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
				"generate_sfx", -- 1924
				"generate_music", -- 1924
				"generate_music_variation", -- 1924
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
	if hasXMLParam(params, "project") and hasXMLParam(params, "path") then -- 2019
		return "generate_music_variation" -- 2022
	end -- 2022
	if hasXMLParam(params, "style") and hasXMLParam(params, "path") then -- 2022
		return "generate_music" -- 2025
	end -- 2025
	if hasXMLParam(params, "type") and hasXMLParam(params, "path") then -- 2025
		return "generate_sfx" -- 2028
	end -- 2028
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 2028
		return "finish" -- 2031
	end -- 2031
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 2031
		return "spawn_sub_agent" -- 2034
	end -- 2034
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 2034
		return "list_sub_agents" -- 2037
	end -- 2037
	return nil -- 2039
end -- 2039
function parseDSMLAttribute(source, offset, name) -- 2042
	local attrOpen = name .. "=\"" -- 2043
	local attrStart = (string.find( -- 2044
		source, -- 2044
		attrOpen, -- 2044
		math.max(offset + 1, 1), -- 2044
		true -- 2044
	) or 0) - 1 -- 2044
	if attrStart < 0 then -- 2044
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 2045
	end -- 2045
	local valueStart = attrStart + #attrOpen -- 2046
	local valueEnd = (string.find( -- 2047
		source, -- 2047
		"\"", -- 2047
		math.max(valueStart + 1, 1), -- 2047
		true -- 2047
	) or 0) - 1 -- 2047
	if valueEnd < 0 then -- 2047
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 2048
	end -- 2048
	return { -- 2049
		success = true, -- 2050
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 2051
		next = valueEnd + 1 -- 2052
	} -- 2052
end -- 2052
function extractDSMLReason(text, invokeStart, tool) -- 2056
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2057
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2058
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2058
		return before -- 2061
	end -- 2061
	if tool == "finish" then -- 2061
		return "" -- 2062
	end -- 2062
	return "Converted provider-native tool call syntax to XML." -- 2063
end -- 2063
function parseDSMLToolCallObjectFromText(text) -- 2066
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2067
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2068
	if invokeStart < 0 then -- 2068
		return {success = false, message = "missing DSML invoke"} -- 2069
	end -- 2069
	local nameStart = invokeStart + #invokeOpen -- 2070
	local nameEnd = (string.find( -- 2071
		text, -- 2071
		"\"", -- 2071
		math.max(nameStart + 1, 1), -- 2071
		true -- 2071
	) or 0) - 1 -- 2071
	if nameEnd < 0 then -- 2071
		return {success = false, message = "unterminated DSML invoke name"} -- 2072
	end -- 2072
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2073
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2073
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2075
	end -- 2075
	local invokeOpenEnd = (string.find( -- 2077
		text, -- 2077
		">", -- 2077
		math.max(nameEnd + 1, 1), -- 2077
		true -- 2077
	) or 0) - 1 -- 2077
	if invokeOpenEnd < 0 then -- 2077
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2078
	end -- 2078
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2079
	local invokeEnd = (string.find( -- 2080
		text, -- 2080
		invokeClose, -- 2080
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2080
		true -- 2080
	) or 0) - 1 -- 2080
	if invokeEnd < 0 then -- 2080
		return {success = false, message = "missing DSML invoke close tag"} -- 2081
	end -- 2081
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2083
	local params = {} -- 2084
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2085
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2086
	local pos = 0 -- 2087
	while pos < #body do -- 2087
		local start = (string.find( -- 2089
			body, -- 2089
			paramOpen, -- 2089
			math.max(pos + 1, 1), -- 2089
			true -- 2089
		) or 0) - 1 -- 2089
		if start < 0 then -- 2089
			break -- 2090
		end -- 2090
		local openEnd = (string.find( -- 2091
			body, -- 2091
			">", -- 2091
			math.max(start + #paramOpen + 1, 1), -- 2091
			true -- 2091
		) or 0) - 1 -- 2091
		if openEnd < 0 then -- 2091
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2092
		end -- 2092
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2093
		if not name.success then -- 2093
			return name -- 2094
		end -- 2094
		local close = (string.find( -- 2095
			body, -- 2095
			paramClose, -- 2095
			math.max(openEnd + 1 + 1, 1), -- 2095
			true -- 2095
		) or 0) - 1 -- 2095
		if close < 0 then -- 2095
			return {success = false, message = "missing DSML parameter close tag"} -- 2096
		end -- 2096
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2097
		pos = close + #paramClose -- 2098
	end -- 2098
	return { -- 2100
		success = true, -- 2101
		obj = { -- 2102
			tool = toolName, -- 2103
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2104
			params = params -- 2105
		} -- 2105
	} -- 2105
end -- 2105
function parseXMLToolCallObjectFromText(text) -- 2110
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2111
	local rawObj -- 2112
	if children.success then -- 2112
		rawObj = children.obj -- 2114
	else -- 2114
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2116
		if dsml.success then -- 2116
			return dsml -- 2117
		end -- 2117
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2118
		local paramsCloseToken = "</params>" -- 2119
		if toolStart >= 0 then -- 2119
			local paramsClose = (string.find( -- 2121
				text, -- 2121
				paramsCloseToken, -- 2121
				math.max(toolStart + 1, 1), -- 2121
				true -- 2121
			) or 0) - 1 -- 2121
			if paramsClose >= toolStart then -- 2121
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2123
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2124
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2124
					rawObj = bare.obj -- 2126
				end -- 2126
			end -- 2126
		end -- 2126
		if rawObj == nil then -- 2126
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2131
			if paramsOpen < 0 then -- 2131
				return children -- 2132
			end -- 2132
			local paramsCloseOnly = (string.find( -- 2133
				text, -- 2133
				paramsCloseToken, -- 2133
				math.max(paramsOpen + 1, 1), -- 2133
				true -- 2133
			) or 0) - 1 -- 2133
			if paramsCloseOnly < paramsOpen then -- 2133
				return children -- 2134
			end -- 2134
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2135
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2136
			if not paramsOnly.success then -- 2136
				return children -- 2137
			end -- 2137
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2138
			if inferredTool == nil then -- 2138
				return children -- 2139
			end -- 2139
			local ____temp_50 -- 2144
			if inferredTool == "finish" then -- 2144
				____temp_50 = nil -- 2144
			else -- 2144
				____temp_50 = "Inferred tool from XML params." -- 2144
			end -- 2144
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2140
		end -- 2140
	end -- 2140
	if rawObj == nil then -- 2140
		return children -- 2150
	end -- 2150
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2151
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2152
	if not params.success then -- 2152
		return {success = false, message = params.message} -- 2156
	end -- 2156
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2158
end -- 2158
function parseDecisionObject(rawObj) -- 2254
	if type(rawObj.tool) ~= "string" then -- 2254
		return {success = false, message = "missing tool"} -- 2255
	end -- 2255
	local tool = rawObj.tool -- 2256
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2256
		return {success = false, message = "unknown tool: " .. tool} -- 2258
	end -- 2258
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2260
	if tool ~= "finish" and (not reason or reason == "") then -- 2260
		return {success = false, message = tool .. " requires top-level reason"} -- 2264
	end -- 2264
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2266
	return {success = true, tool = tool, params = params, reason = reason} -- 2267
end -- 2267
function getDecisionPath(params) -- 2389
	if type(params.path) == "string" then -- 2389
		return __TS__StringTrim(params.path) -- 2390
	end -- 2390
	if type(params.target_file) == "string" then -- 2390
		return __TS__StringTrim(params.target_file) -- 2391
	end -- 2391
	return "" -- 2392
end -- 2392
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2395
	if enforceFinalTurn == nil then -- 2395
		enforceFinalTurn = false -- 2399
	end -- 2399
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2399
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2402
	end -- 2402
	if not isToolAllowedForRole(shared, tool) then -- 2402
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2405
	end -- 2405
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2405
		local path = getDecisionPath(params) -- 2408
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2408
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2410
		end -- 2410
	end -- 2410
	if tool == "delete_file" then -- 2410
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2414
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2414
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2416
		end -- 2416
	end -- 2416
	return {success = true} -- 2419
end -- 2419
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2422
	local num = __TS__Number(value) -- 2423
	if not __TS__NumberIsFinite(num) then -- 2423
		num = fallback -- 2424
	end -- 2424
	num = math.floor(num) -- 2425
	if num < minValue then -- 2425
		num = minValue -- 2426
	end -- 2426
	if maxValue ~= nil and num > maxValue then -- 2426
		num = maxValue -- 2427
	end -- 2427
	return num -- 2428
end -- 2428
function parseReadLineParam(value, fallback, paramName) -- 2431
	local num = __TS__Number(value) -- 2436
	if not __TS__NumberIsFinite(num) then -- 2436
		num = fallback -- 2437
	end -- 2437
	num = math.floor(num) -- 2438
	if num == 0 then -- 2438
		return {success = false, message = paramName .. " cannot be 0"} -- 2440
	end -- 2440
	return {success = true, value = num} -- 2442
end -- 2442
function validateDecision(tool, params) -- 2445
	if tool == "finish" then -- 2445
		local message = getFinishMessage(params) -- 2450
		if message == "" then -- 2450
			return {success = false, message = "finish requires params.message"} -- 2451
		end -- 2451
		params.message = message -- 2452
		local completion = getCompletionReport(params) -- 2453
		params.outcome = completion.outcome -- 2454
		params.validation = completion.validation -- 2455
		params.knownIssues = completion.knownIssues -- 2456
		params.assumptions = completion.assumptions -- 2457
		params.learningCandidates = completion.learningCandidates -- 2458
		return {success = true, params = params} -- 2459
	end -- 2459
	if tool == "ask_user" then -- 2459
		local normalized = normalizeQuestionnaire(params) -- 2463
		if not normalized.success then -- 2463
			return normalized -- 2464
		end -- 2464
		return {success = true, params = normalized.schema} -- 2465
	end -- 2465
	if tool == "read_file" then -- 2465
		local path = getDecisionPath(params) -- 2469
		if path == "" then -- 2469
			return {success = false, message = "read_file requires path"} -- 2470
		end -- 2470
		params.path = path -- 2471
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2472
		if not startLineRes.success then -- 2472
			return startLineRes -- 2473
		end -- 2473
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2474
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2475
		if not endLineRes.success then -- 2475
			return endLineRes -- 2476
		end -- 2476
		params.startLine = startLineRes.value -- 2477
		params.endLine = endLineRes.value -- 2478
		return {success = true, params = params} -- 2479
	end -- 2479
	if tool == "edit_file" then -- 2479
		local path = getDecisionPath(params) -- 2483
		if path == "" then -- 2483
			return {success = false, message = "edit_file requires path"} -- 2484
		end -- 2484
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2485
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2486
		params.path = path -- 2487
		params.old_str = oldStr -- 2488
		params.new_str = newStr -- 2489
		return {success = true, params = params} -- 2490
	end -- 2490
	if tool == "delete_file" then -- 2490
		local targetFile = getDecisionPath(params) -- 2494
		if targetFile == "" then -- 2494
			return {success = false, message = "delete_file requires target_file"} -- 2495
		end -- 2495
		params.target_file = targetFile -- 2496
		return {success = true, params = params} -- 2497
	end -- 2497
	if tool == "grep_files" then -- 2497
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2501
		if pattern == "" then -- 2501
			return {success = false, message = "grep_files requires pattern"} -- 2502
		end -- 2502
		params.pattern = pattern -- 2503
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2504
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2505
		return {success = true, params = params} -- 2506
	end -- 2506
	if tool == "search_dora_api" then -- 2506
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2510
		if pattern == "" then -- 2510
			return {success = false, message = "search_dora_api requires pattern"} -- 2511
		end -- 2511
		params.pattern = pattern -- 2512
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2513
		return {success = true, params = params} -- 2514
	end -- 2514
	if tool == "glob_files" then -- 2514
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2518
		return {success = true, params = params} -- 2519
	end -- 2519
	if tool == "build" then -- 2519
		local path = getDecisionPath(params) -- 2523
		if path ~= "" then -- 2523
			params.path = path -- 2525
		end -- 2525
		return {success = true, params = params} -- 2527
	end -- 2527
	if tool == "list_sub_agents" then -- 2527
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2531
		if status ~= "" then -- 2531
			params.status = status -- 2533
		end -- 2533
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2535
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2536
		if type(params.query) == "string" then -- 2536
			params.query = __TS__StringTrim(params.query) -- 2538
		end -- 2538
		return {success = true, params = params} -- 2540
	end -- 2540
	if tool == "spawn_sub_agent" then -- 2540
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2544
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2545
		if prompt == "" then -- 2545
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2546
		end -- 2546
		if title == "" then -- 2546
			return {success = false, message = "spawn_sub_agent requires title"} -- 2547
		end -- 2547
		params.prompt = prompt -- 2548
		params.title = title -- 2549
		if type(params.expectedOutput) == "string" then -- 2549
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2551
		end -- 2551
		if isArray(params.filesHint) then -- 2551
			params.filesHint = __TS__ArrayMap( -- 2554
				__TS__ArrayFilter( -- 2554
					params.filesHint, -- 2554
					function(____, item) return type(item) == "string" end -- 2555
				), -- 2555
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2556
			) -- 2556
		end -- 2556
		return {success = true, params = params} -- 2558
	end -- 2558
	return {success = true, params = params} -- 2561
end -- 2561
function validateCompletionForRole(role, tool, params) -- 2564
	if role ~= "sub" or tool ~= "finish" then -- 2564
		return {success = true} -- 2569
	end -- 2569
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2569
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2571
	end -- 2571
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2573
	do -- 2573
		local i = 0 -- 2574
		while i < #requiredArrays do -- 2574
			local name = requiredArrays[i + 1] -- 2575
			if not isArray(params[name]) then -- 2575
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2577
			end -- 2577
			i = i + 1 -- 2574
		end -- 2574
	end -- 2574
	return {success = true} -- 2580
end -- 2580
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2583
	if includeToolDefinitions == nil then -- 2583
		includeToolDefinitions = false -- 2583
	end -- 2583
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2584
	local sections = { -- 2587
		shared.promptPack.agentIdentityPrompt, -- 2588
		rolePrompt, -- 2589
		getReplyLanguageDirective(shared) -- 2590
	} -- 2590
	if shared.role == "main" then -- 2590
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2593
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2594
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2594
			sections[#sections + 1] = table.concat( -- 2596
				{ -- 2596
					"# Current Living Development Plan", -- 2597
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2598
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2598
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2599
						12000 -- 2599
					), -- 2599
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2599
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2600
						12000 -- 2600
					) -- 2600
				}, -- 2600
				"\n\n" -- 2601
			) -- 2601
		end -- 2601
	end -- 2601
	if shared.decisionMode == "tool_calling" then -- 2601
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2605
	end -- 2605
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2607
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2608
	if memoryContext ~= "" then -- 2608
		sections[#sections + 1] = memoryContext -- 2610
	end -- 2610
	local skillsSection = buildSkillsSection(shared) -- 2612
	if skillsSection ~= "" then -- 2612
		sections[#sections + 1] = skillsSection -- 2614
	end -- 2614
	if includeToolDefinitions then -- 2614
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2617
		if shared.decisionMode == "xml" then -- 2617
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2619
		end -- 2619
	end -- 2619
	return table.concat(sections, "\n\n") -- 2622
end -- 2622
function buildSkillsSection(shared) -- 2625
	local ____opt_69 = shared.skills -- 2625
	if not (____opt_69 and ____opt_69.loader) then -- 2625
		return "" -- 2627
	end -- 2627
	return shared.skills.loader:buildSkillsPromptSection() -- 2629
end -- 2629
function sanitizeMessagesForLLMInput(messages) -- 2632
	local sanitized = {} -- 2633
	local droppedAssistantToolCalls = 0 -- 2634
	local droppedToolResults = 0 -- 2635
	do -- 2635
		local i = 0 -- 2636
		while i < #messages do -- 2636
			do -- 2636
				local message = messages[i + 1] -- 2637
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2637
					local requiredIds = {} -- 2639
					do -- 2639
						local j = 0 -- 2640
						while j < #message.tool_calls do -- 2640
							local toolCall = message.tool_calls[j + 1] -- 2641
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2642
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2642
								requiredIds[#requiredIds + 1] = id -- 2644
							end -- 2644
							j = j + 1 -- 2640
						end -- 2640
					end -- 2640
					if #requiredIds == 0 then -- 2640
						sanitized[#sanitized + 1] = message -- 2648
						goto __continue456 -- 2649
					end -- 2649
					local matchedIds = {} -- 2651
					local matchedTools = {} -- 2652
					local j = i + 1 -- 2653
					while j < #messages do -- 2653
						local toolMessage = messages[j + 1] -- 2655
						if toolMessage.role ~= "tool" then -- 2655
							break -- 2656
						end -- 2656
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2657
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2657
							matchedIds[toolCallId] = true -- 2659
							matchedTools[#matchedTools + 1] = toolMessage -- 2660
						else -- 2660
							droppedToolResults = droppedToolResults + 1 -- 2662
						end -- 2662
						j = j + 1 -- 2664
					end -- 2664
					local complete = true -- 2666
					do -- 2666
						local j = 0 -- 2667
						while j < #requiredIds do -- 2667
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2667
								complete = false -- 2669
								break -- 2670
							end -- 2670
							j = j + 1 -- 2667
						end -- 2667
					end -- 2667
					if complete then -- 2667
						__TS__ArrayPush( -- 2674
							sanitized, -- 2674
							message, -- 2674
							table.unpack(matchedTools) -- 2674
						) -- 2674
					else -- 2674
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2676
						droppedToolResults = droppedToolResults + #matchedTools -- 2677
					end -- 2677
					i = j - 1 -- 2679
					goto __continue456 -- 2680
				end -- 2680
				if message.role == "tool" then -- 2680
					droppedToolResults = droppedToolResults + 1 -- 2683
					goto __continue456 -- 2684
				end -- 2684
				sanitized[#sanitized + 1] = message -- 2686
			end -- 2686
			::__continue456:: -- 2686
			i = i + 1 -- 2636
		end -- 2636
	end -- 2636
	return sanitized -- 2688
end -- 2688
function getUnconsolidatedMessages(shared) -- 2691
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2692
end -- 2692
function isFinalDecisionTurn(shared) -- 2697
	return shared.agentStepCount + 1 >= shared.maxSteps -- 2698
end -- 2698
function getFinalDecisionTurnPrompt(shared) -- 2701
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2702
end -- 2702
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2707
	if attempt == nil then -- 2707
		attempt = 1 -- 2710
	end -- 2710
	if decisionMode == nil then -- 2710
		decisionMode = shared.decisionMode -- 2712
	end -- 2712
	if consumeResumeCheckpoint == nil then -- 2712
		consumeResumeCheckpoint = true -- 2713
	end -- 2713
	if pendingUserPrompt == nil then -- 2713
		pendingUserPrompt = "" -- 2714
	end -- 2714
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2716
	local tailSections = {} -- 2717
	if shared.resumeCheckpointPending == true then -- 2717
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and shared.agentStepCount == 0 and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2723
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2727
	end -- 2727
	if shared.truncatedToolOverwritePath ~= nil then -- 2727
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2730
	end -- 2730
	if consumeResumeCheckpoint then -- 2730
		shared.resumeCheckpointPending = false -- 2732
	end -- 2732
	local messages = { -- 2733
		{role = "system", content = systemPrompt}, -- 2734
		table.unpack(getUnconsolidatedMessages(shared)) -- 2735
	} -- 2735
	if pendingUserPrompt ~= "" then -- 2735
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2738
	end -- 2738
	if isFinalDecisionTurn(shared) then -- 2738
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2741
	end -- 2741
	if lastError and lastError ~= "" then -- 2741
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2744
		if decisionMode == "xml" then -- 2744
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2748
		end -- 2748
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2748
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2751
		end -- 2751
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2751
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2754
		end -- 2754
		messages[#messages + 1] = { -- 2756
			role = "user", -- 2757
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2758
		} -- 2758
	end -- 2758
	if #tailSections > 0 then -- 2758
		messages[#messages + 1] = { -- 2766
			role = "user", -- 2767
			content = table.concat(tailSections, "\n\n") -- 2768
		} -- 2768
	end -- 2768
	return messages -- 2771
end -- 2771
function buildXmlDecisionInstruction(shared, feedback) -- 2774
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2775
end -- 2775
function tryParseAndValidateDecision(rawText, shared) -- 2843
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2844
	if not parsed.success then -- 2844
		return {success = false, message = parsed.message, raw = rawText} -- 2846
	end -- 2846
	local decision = parseDecisionObject(parsed.obj) -- 2848
	if not decision.success then -- 2848
		return {success = false, message = decision.message, raw = rawText} -- 2850
	end -- 2850
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2852
	if not completionValidation.success then -- 2852
		return {success = false, message = completionValidation.message, raw = rawText} -- 2854
	end -- 2854
	local validation = validateDecision(decision.tool, decision.params) -- 2856
	if not validation.success then -- 2856
		return {success = false, message = validation.message, raw = rawText} -- 2858
	end -- 2858
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2860
	if not sharedValidation.success then -- 2860
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2862
	end -- 2862
	decision.params = validation.params -- 2864
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2865
	return decision -- 2866
end -- 2866
function executeToolAction(shared, action) -- 4037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4037
		if shared.stopToken.stopped then -- 4037
			return ____awaiter_resolve( -- 4037
				nil, -- 4037
				{ -- 4039
					success = false, -- 4039
					message = getCancelledReason(shared) -- 4039
				} -- 4039
			) -- 4039
		end -- 4039
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4039
			shared.resumeRequiredTool = nil -- 4042
			shared.resumeCheckpointPending = false -- 4043
		end -- 4043
		local params = action.params -- 4045
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4046
		if not sharedValidation.success then -- 4046
			return ____awaiter_resolve(nil, sharedValidation) -- 4046
		end -- 4046
		if action.tool == "read_file" then -- 4046
			local ____params_startLine_149 = params.startLine -- 4049
			if ____params_startLine_149 == nil then -- 4049
				____params_startLine_149 = 1 -- 4049
			end -- 4049
			local startLine = __TS__Number(____params_startLine_149) -- 4049
			local ____params_endLine_150 = params.endLine -- 4050
			if ____params_endLine_150 == nil then -- 4050
				____params_endLine_150 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4050
			end -- 4050
			local endLine = __TS__Number(____params_endLine_150) -- 4050
			local clippedAfterCompression = false -- 4051
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4051
				endLine = startLine + 159 -- 4058
				clippedAfterCompression = true -- 4059
			end -- 4059
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4061
			if __TS__StringTrim(path) == "" then -- 4061
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4061
			end -- 4061
			local result = Tools.readFile( -- 4065
				shared.workingDir, -- 4066
				path, -- 4067
				startLine, -- 4068
				endLine, -- 4069
				shared.useChineseResponse and "zh" or "en" -- 4070
			) -- 4070
			if clippedAfterCompression and result.success == true then -- 4070
				result.clipped = true -- 4073
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4074
			end -- 4074
			return ____awaiter_resolve(nil, result) -- 4074
		end -- 4074
		if action.tool == "grep_files" then -- 4074
			local searchPath = params.path or "" -- 4081
			local searchGlobs = params.globs -- 4082
			local ____Tools_searchFiles_164 = Tools.searchFiles -- 4083
			local ____shared_workingDir_157 = shared.workingDir -- 4084
			local ____temp_158 = params.pattern or "" -- 4086
			local ____params_globs_159 = params.globs -- 4087
			local ____params_useRegex_160 = params.useRegex -- 4088
			local ____params_caseSensitive_161 = params.caseSensitive -- 4089
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4091
			local ____math_max_153 = math.max -- 4092
			local ____math_floor_152 = math.floor -- 4092
			local ____params_limit_151 = params.limit -- 4092
			if ____params_limit_151 == nil then -- 4092
				____params_limit_151 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4092
			end -- 4092
			local ____math_max_153_result_163 = ____math_max_153( -- 4092
				1, -- 4092
				____math_floor_152(__TS__Number(____params_limit_151)) -- 4092
			) -- 4092
			local ____math_max_156 = math.max -- 4093
			local ____math_floor_155 = math.floor -- 4093
			local ____params_offset_154 = params.offset -- 4093
			if ____params_offset_154 == nil then -- 4093
				____params_offset_154 = 0 -- 4093
			end -- 4093
			local result = __TS__Await(____Tools_searchFiles_164({ -- 4083
				workDir = ____shared_workingDir_157, -- 4084
				path = searchPath, -- 4085
				pattern = ____temp_158, -- 4086
				globs = ____params_globs_159, -- 4087
				useRegex = ____params_useRegex_160, -- 4088
				caseSensitive = ____params_caseSensitive_161, -- 4089
				includeContent = true, -- 4090
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_162, -- 4091
				limit = ____math_max_153_result_163, -- 4092
				offset = ____math_max_156( -- 4093
					0, -- 4093
					____math_floor_155(__TS__Number(____params_offset_154)) -- 4093
				), -- 4093
				groupByFile = params.groupByFile == true -- 4094
			})) -- 4094
			return ____awaiter_resolve(nil, result) -- 4094
		end -- 4094
		if action.tool == "search_dora_api" then -- 4094
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4099
			local ____Tools_searchDoraAPI_173 = Tools.searchDoraAPI -- 4100
			local ____temp_169 = params.pattern or "" -- 4101
			local ____temp_170 = params.docSource or "api" -- 4102
			local ____temp_171 = shared.useChineseResponse and "zh" or "en" -- 4103
			local ____temp_172 = params.programmingLanguage or "ts" -- 4104
			local ____math_min_168 = math.min -- 4105
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4105
			local ____math_max_166 = math.max -- 4105
			local ____params_limit_165 = params.limit -- 4105
			if ____params_limit_165 == nil then -- 4105
				____params_limit_165 = 8 -- 4105
			end -- 4105
			local result = __TS__Await(____Tools_searchDoraAPI_173({ -- 4100
				pattern = ____temp_169, -- 4101
				docSource = ____temp_170, -- 4102
				docLanguage = ____temp_171, -- 4103
				programmingLanguage = ____temp_172, -- 4104
				limit = ____math_min_168( -- 4105
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_167, -- 4105
					____math_max_166( -- 4105
						1, -- 4105
						__TS__Number(____params_limit_165) -- 4105
					) -- 4105
				), -- 4105
				useRegex = params.useRegex, -- 4106
				caseSensitive = false, -- 4107
				includeContent = true, -- 4108
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4109
			})) -- 4109
			return ____awaiter_resolve(nil, result) -- 4109
		end -- 4109
		if action.tool == "glob_files" then -- 4109
			local ____Tools_listFiles_180 = Tools.listFiles -- 4114
			local ____shared_workingDir_177 = shared.workingDir -- 4115
			local ____temp_178 = params.path or "" -- 4116
			local ____params_globs_179 = params.globs -- 4117
			local ____math_max_176 = math.max -- 4118
			local ____math_floor_175 = math.floor -- 4118
			local ____params_maxEntries_174 = params.maxEntries -- 4118
			if ____params_maxEntries_174 == nil then -- 4118
				____params_maxEntries_174 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4118
			end -- 4118
			local result = ____Tools_listFiles_180({ -- 4114
				workDir = ____shared_workingDir_177, -- 4115
				path = ____temp_178, -- 4116
				globs = ____params_globs_179, -- 4117
				maxEntries = ____math_max_176( -- 4118
					1, -- 4118
					____math_floor_175(__TS__Number(____params_maxEntries_174)) -- 4118
				) -- 4118
			}) -- 4118
			return ____awaiter_resolve(nil, result) -- 4118
		end -- 4118
		if action.tool == "ask_user" then -- 4118
			if not shared.publishQuestionnaire then -- 4118
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4118
			end -- 4118
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4118
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4118
			end -- 4118
			local normalized = normalizeQuestionnaire(params) -- 4125
			if not normalized.success then -- 4125
				return ____awaiter_resolve(nil, normalized) -- 4125
			end -- 4125
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4127
			if not result.success then -- 4127
				return ____awaiter_resolve(nil, result) -- 4127
			end -- 4127
			shared.waitingQuestionnaireId = result.questionnaireId -- 4134
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4134
		end -- 4134
		if action.tool == "delete_file" then -- 4134
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4138
			if __TS__StringTrim(targetFile) == "" then -- 4138
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4138
			end -- 4138
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4142
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4143
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4143
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4143
			end -- 4143
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4147
			local result = Tools.deleteFile(shared.taskId, shared.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4148
			if not result.success then -- 4148
				return ____awaiter_resolve(nil, result) -- 4148
			end -- 4148
			if not isInternalDocumentEdit then -- 4148
				shared.unbuiltEdits = true -- 4156
				shared.lastBuildSucceeded = false -- 4157
				if shared.failedTestNeedsBuild == true then -- 4157
					shared.failedTestHasSourceEdit = true -- 4158
				end -- 4158
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4158
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4159
				end -- 4159
				shared.editedPathsSinceBuild = editedPaths -- 4160
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4161
			end -- 4161
			local ____result_checkpointed_182 = result.checkpointed -- 4167
			local ____result_reversible_183 = result.reversible -- 4168
			local ____result_binary_184 = result.binary -- 4169
			local ____temp_185 = result.checkpointed and result.checkpointId or nil -- 4170
			local ____temp_186 = result.checkpointed and result.checkpointSeq or nil -- 4171
			local ____result_checkpointed_181 -- 4172
			if result.checkpointed then -- 4172
				____result_checkpointed_181 = nil -- 4172
			else -- 4172
				____result_checkpointed_181 = result.message -- 4172
			end -- 4172
			return ____awaiter_resolve(nil, { -- 4172
				success = true, -- 4164
				changed = true, -- 4165
				mode = "delete", -- 4166
				checkpointed = ____result_checkpointed_182, -- 4167
				reversible = ____result_reversible_183, -- 4168
				binary = ____result_binary_184, -- 4169
				checkpointId = ____temp_185, -- 4170
				checkpointSeq = ____temp_186, -- 4171
				message = ____result_checkpointed_181, -- 4172
				files = {{path = targetFile, op = "delete"}} -- 4173
			}) -- 4173
		end -- 4173
		if action.tool == "build" then -- 4173
			local buildPath = params.path or "" -- 4177
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4178
			shared.unbuiltEdits = false -- 4182
			shared.editsSinceBuild = 0 -- 4183
			shared.editedPathsSinceBuild = {} -- 4184
			shared.hasBuilt = true -- 4185
			shared.lastBuildSucceeded = result.success -- 4186
			if result.success and shared.freshProjectBuildPending == true then -- 4186
				shared.freshProjectBuildPending = false -- 4192
			end -- 4192
			shared.apiSearchesSinceBuild = 0 -- 4194
			shared.buildRepairPending = false -- 4195
			if not result.success and result.messages ~= nil then -- 4195
				do -- 4195
					local i = 0 -- 4197
					while i < #result.messages do -- 4197
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4197
							shared.buildRepairPending = true -- 4199
							break -- 4200
						end -- 4200
						i = i + 1 -- 4197
					end -- 4197
				end -- 4197
			end -- 4197
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4197
				shared.failedTestNeedsBuild = false -- 4205
				shared.failedTestHasSourceEdit = false -- 4206
			end -- 4206
			return ____awaiter_resolve(nil, result) -- 4206
		end -- 4206
		if action.tool == "fetch_url" then -- 4206
			local result = __TS__Await(Tools.fetchUrl({ -- 4211
				workDir = shared.workingDir, -- 4212
				url = type(params.url) == "string" and params.url or "", -- 4213
				target = type(params.target) == "string" and params.target or "", -- 4214
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4215
				onProgress = function(____, progress) -- 4216
					emitAgentEvent( -- 4217
						shared, -- 4217
						{ -- 4217
							type = "tool_progress", -- 4218
							sessionId = shared.sessionId, -- 4219
							taskId = shared.taskId, -- 4220
							step = action.step, -- 4221
							tool = action.tool, -- 4222
							result = __TS__ObjectAssign({success = false}, progress) -- 4223
						} -- 4223
					) -- 4223
				end -- 4216
			})) -- 4216
			return ____awaiter_resolve(nil, result) -- 4216
		end -- 4216
		if action.tool == "generate_sfx" then -- 4216
			local result = __TS__Await(Tools.generateSfx({ -- 4233
				workDir = shared.workingDir, -- 4234
				path = type(params.path) == "string" and params.path or "", -- 4235
				type = type(params.type) == "string" and params.type or "", -- 4236
				seed = type(params.seed) == "number" and params.seed or nil, -- 4237
				volume = type(params.volume) == "number" and params.volume or nil, -- 4238
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4239
				onProgress = function(____, progress) -- 4240
					emitAgentEvent( -- 4241
						shared, -- 4241
						{ -- 4241
							type = "tool_progress", -- 4242
							sessionId = shared.sessionId, -- 4243
							taskId = shared.taskId, -- 4244
							step = action.step, -- 4245
							tool = action.tool, -- 4246
							result = __TS__ObjectAssign({success = false}, progress) -- 4247
						} -- 4247
					) -- 4247
				end -- 4240
			})) -- 4240
			return ____awaiter_resolve(nil, result) -- 4240
		end -- 4240
		if action.tool == "generate_music" then -- 4240
			local ____Tools_generateMusic_218 = Tools.generateMusic -- 4257
			local ____shared_workingDir_190 = shared.workingDir -- 4258
			local ____temp_191 = type(params.path) == "string" and params.path or "" -- 4259
			local ____temp_192 = type(params.style) == "string" and params.style or "" -- 4260
			local ____temp_193 = type(params.seed) == "number" and params.seed or nil -- 4261
			local ____temp_194 = type(params.duration) == "number" and params.duration or nil -- 4262
			local ____temp_195 = type(params.bpm) == "number" and params.bpm or nil -- 4263
			local ____temp_196 = type(params.volume) == "number" and params.volume or nil -- 4264
			local ____temp_197 = type(params.intensity) == "number" and params.intensity or nil -- 4265
			local ____temp_198 = type(params.key) == "string" and params.key or nil -- 4266
			local ____temp_199 = type(params.mode) == "string" and params.mode or nil -- 4267
			local ____temp_200 = type(params.progression) == "string" and params.progression or nil -- 4268
			local ____temp_201 = type(params.structure) == "string" and params.structure or nil -- 4269
			local ____temp_202 = type(params.bars_per_section) == "number" and params.bars_per_section or nil -- 4270
			local ____temp_203 = type(params.melody_complexity) == "number" and params.melody_complexity or nil -- 4271
			local ____temp_204 = type(params.rhythm_complexity) == "number" and params.rhythm_complexity or nil -- 4272
			local ____temp_205 = type(params.variation) == "number" and params.variation or nil -- 4273
			local ____temp_206 = type(params.lead_instrument) == "string" and params.lead_instrument or nil -- 4274
			local ____temp_207 = type(params.bass_instrument) == "string" and params.bass_instrument or nil -- 4275
			local ____temp_208 = type(params.harmony_instrument) == "string" and params.harmony_instrument or nil -- 4276
			local ____temp_187 -- 4277
			if type(params.stereo) == "boolean" then -- 4277
				____temp_187 = params.stereo -- 4277
			else -- 4277
				____temp_187 = nil -- 4277
			end -- 4277
			local ____temp_209 = type(params.reverb) == "number" and params.reverb or nil -- 4278
			local ____temp_210 = type(params.delay) == "number" and params.delay or nil -- 4279
			local ____temp_211 = type(params.chorus) == "number" and params.chorus or nil -- 4280
			local ____temp_212 = type(params.distortion) == "number" and params.distortion or nil -- 4281
			local ____temp_213 = type(params.bit_crush) == "number" and params.bit_crush or nil -- 4282
			local ____temp_214 = type(params.low_pass) == "number" and params.low_pass or nil -- 4283
			local ____temp_188 -- 4284
			if type(params.stems) == "boolean" then -- 4284
				____temp_188 = params.stems -- 4284
			else -- 4284
				____temp_188 = nil -- 4284
			end -- 4284
			local ____temp_215 = type(params.intro_bars) == "number" and params.intro_bars or nil -- 4285
			local ____temp_216 = type(params.outro_bars) == "number" and params.outro_bars or nil -- 4286
			local ____temp_217 = type(params.stinger) == "string" and params.stinger or nil -- 4287
			local ____temp_189 -- 4288
			if type(params.export_midi) == "boolean" then -- 4288
				____temp_189 = params.export_midi -- 4288
			else -- 4288
				____temp_189 = nil -- 4288
			end -- 4288
			local result = __TS__Await(____Tools_generateMusic_218({ -- 4257
				workDir = ____shared_workingDir_190, -- 4258
				path = ____temp_191, -- 4259
				style = ____temp_192, -- 4260
				seed = ____temp_193, -- 4261
				duration = ____temp_194, -- 4262
				bpm = ____temp_195, -- 4263
				volume = ____temp_196, -- 4264
				intensity = ____temp_197, -- 4265
				key = ____temp_198, -- 4266
				mode = ____temp_199, -- 4267
				progression = ____temp_200, -- 4268
				structure = ____temp_201, -- 4269
				barsPerSection = ____temp_202, -- 4270
				melodyComplexity = ____temp_203, -- 4271
				rhythmComplexity = ____temp_204, -- 4272
				variation = ____temp_205, -- 4273
				leadInstrument = ____temp_206, -- 4274
				bassInstrument = ____temp_207, -- 4275
				harmonyInstrument = ____temp_208, -- 4276
				stereo = ____temp_187, -- 4277
				reverb = ____temp_209, -- 4278
				delay = ____temp_210, -- 4279
				chorus = ____temp_211, -- 4280
				distortion = ____temp_212, -- 4281
				bitCrush = ____temp_213, -- 4282
				lowPass = ____temp_214, -- 4283
				stems = ____temp_188, -- 4284
				introBars = ____temp_215, -- 4285
				outroBars = ____temp_216, -- 4286
				stinger = ____temp_217, -- 4287
				exportMidi = ____temp_189, -- 4288
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4289
				onProgress = function(____, progress) -- 4290
					emitAgentEvent( -- 4291
						shared, -- 4291
						{ -- 4291
							type = "tool_progress", -- 4292
							sessionId = shared.sessionId, -- 4293
							taskId = shared.taskId, -- 4294
							step = action.step, -- 4295
							tool = action.tool, -- 4296
							result = __TS__ObjectAssign({success = false}, progress) -- 4297
						} -- 4297
					) -- 4297
				end -- 4290
			})) -- 4290
			return ____awaiter_resolve(nil, result) -- 4290
		end -- 4290
		if action.tool == "generate_music_variation" then -- 4290
			local result = __TS__Await(Tools.generateMusicVariation({ -- 4307
				workDir = shared.workingDir, -- 4308
				project = type(params.project) == "string" and params.project or "", -- 4309
				path = type(params.path) == "string" and params.path or "", -- 4310
				seed = type(params.seed) == "number" and params.seed or nil, -- 4311
				style = type(params.style) == "string" and params.style or nil, -- 4312
				intensity = type(params.intensity) == "number" and params.intensity or nil, -- 4313
				variation = type(params.variation) == "number" and params.variation or nil, -- 4314
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4315
				onProgress = function(____, progress) -- 4316
					emitAgentEvent( -- 4317
						shared, -- 4317
						{ -- 4317
							type = "tool_progress", -- 4318
							sessionId = shared.sessionId, -- 4319
							taskId = shared.taskId, -- 4320
							step = action.step, -- 4321
							tool = action.tool, -- 4322
							result = __TS__ObjectAssign({success = false}, progress) -- 4323
						} -- 4323
					) -- 4323
				end -- 4316
			})) -- 4316
			return ____awaiter_resolve(nil, result) -- 4316
		end -- 4316
		if action.tool == "execute_command" then -- 4316
			local mode = type(params.mode) == "string" and params.mode or "" -- 4330
			local result = __TS__Await(Tools.executeCommand({ -- 4331
				workDir = shared.workingDir, -- 4332
				mode = mode, -- 4333
				code = type(params.code) == "string" and params.code or nil, -- 4334
				command = type(params.command) == "string" and params.command or nil, -- 4335
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4336
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4337
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4338
				onProgress = function(____, progress) -- 4339
					emitAgentEvent( -- 4340
						shared, -- 4340
						{ -- 4340
							type = "tool_progress", -- 4341
							sessionId = shared.sessionId, -- 4342
							taskId = shared.taskId, -- 4343
							step = action.step, -- 4344
							tool = action.tool, -- 4345
							result = __TS__ObjectAssign({success = false}, progress) -- 4346
						} -- 4346
					) -- 4346
				end -- 4339
			})) -- 4339
			if result.success and mode == "lua" then -- 4339
				local deterministicFailure = false -- 4354
				local deterministicPass = false -- 4355
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4356
				do -- 4356
					local i = 0 -- 4357
					while i < #outputLines and not deterministicFailure do -- 4357
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4358
						if line == "passed" then -- 4358
							deterministicPass = true -- 4359
						end -- 4359
						if line == "failed" then -- 4359
							deterministicFailure = true -- 4361
							break -- 4362
						end -- 4362
						local searchFrom = 0 -- 4364
						while searchFrom < #line do -- 4364
							local failedIndex = (string.find( -- 4366
								line, -- 4366
								"failed", -- 4366
								math.max(searchFrom + 1, 1), -- 4366
								true -- 4366
							) or 0) - 1 -- 4366
							if failedIndex < 0 then -- 4366
								break -- 4367
							end -- 4367
							local after = failedIndex + #"failed" -- 4368
							while after < #line do -- 4368
								local ch = __TS__StringSlice(line, after, after + 1) -- 4370
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4370
									break -- 4371
								end -- 4371
								after = after + 1 -- 4372
							end -- 4372
							local afterEnd = after -- 4374
							while afterEnd < #line do -- 4374
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4376
								if ch < "0" or ch > "9" then -- 4376
									break -- 4377
								end -- 4377
								afterEnd = afterEnd + 1 -- 4378
							end -- 4378
							local count -- 4380
							if afterEnd > after then -- 4380
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4382
							else -- 4382
								local before = failedIndex - 1 -- 4384
								while before >= 0 do -- 4384
									local ch = __TS__StringSlice(line, before, before + 1) -- 4386
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4386
										break -- 4387
									end -- 4387
									before = before - 1 -- 4388
								end -- 4388
								local beforeEnd = before + 1 -- 4390
								while before >= 0 do -- 4390
									local ch = __TS__StringSlice(line, before, before + 1) -- 4392
									if ch < "0" or ch > "9" then -- 4392
										break -- 4393
									end -- 4393
									before = before - 1 -- 4394
								end -- 4394
								if beforeEnd > before + 1 then -- 4394
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4396
								end -- 4396
							end -- 4396
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4396
								deterministicFailure = true -- 4399
								break -- 4400
							end -- 4400
							searchFrom = failedIndex + #"failed" -- 4402
						end -- 4402
						i = i + 1 -- 4357
					end -- 4357
				end -- 4357
				if deterministicFailure then -- 4357
					shared.failedTestNeedsBuild = true -- 4406
					shared.failedTestHasSourceEdit = false -- 4407
				elseif deterministicPass then -- 4407
					shared.failedTestNeedsBuild = false -- 4409
					shared.failedTestHasSourceEdit = false -- 4410
				end -- 4410
			end -- 4410
			return ____awaiter_resolve(nil, result) -- 4410
		end -- 4410
		if action.tool == "spawn_sub_agent" then -- 4410
			if not shared.spawnSubAgent then -- 4410
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4410
			end -- 4410
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4410
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4410
			end -- 4410
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4422
				params.filesHint, -- 4423
				function(____, item) return type(item) == "string" end -- 4423
			) or nil -- 4423
			local result = __TS__Await(shared.spawnSubAgent({ -- 4425
				parentSessionId = shared.sessionId, -- 4426
				projectRoot = shared.workingDir, -- 4427
				title = type(params.title) == "string" and params.title or "Sub", -- 4428
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4429
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4430
				filesHint = filesHint, -- 4431
				disabledAgentTools = shared.disabledAgentTools -- 4432
			})) -- 4432
			if not result.success then -- 4432
				return ____awaiter_resolve(nil, result) -- 4432
			end -- 4432
			shared.hasSpawnedSubAgentThisTask = true -- 4437
			return ____awaiter_resolve(nil, { -- 4437
				success = true, -- 4439
				sessionId = result.sessionId, -- 4440
				taskId = result.taskId, -- 4441
				title = result.title, -- 4442
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4443
			}) -- 4443
		end -- 4443
		if action.tool == "list_sub_agents" then -- 4443
			if not shared.listSubAgents then -- 4443
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4443
			end -- 4443
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4443
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4443
			end -- 4443
			local result = __TS__Await(shared.listSubAgents({ -- 4453
				sessionId = shared.sessionId, -- 4454
				projectRoot = shared.workingDir, -- 4455
				status = type(params.status) == "string" and params.status or nil, -- 4456
				limit = type(params.limit) == "number" and params.limit or nil, -- 4457
				offset = type(params.offset) == "number" and params.offset or nil, -- 4458
				query = type(params.query) == "string" and params.query or nil -- 4459
			})) -- 4459
			return ____awaiter_resolve(nil, result) -- 4459
		end -- 4459
		if action.tool == "edit_file" then -- 4459
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4464
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4467
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4468
			if __TS__StringTrim(path) == "" then -- 4468
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4468
			end -- 4468
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4470
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4471
			if not isInternalDocumentEdit then -- 4471
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4473
				if preflightIssue ~= nil then -- 4473
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4475
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4476
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4476
				end -- 4476
			end -- 4476
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4482
			local result = __TS__Await(actionNode:exec({ -- 4483
				path = path, -- 4484
				oldStr = oldStr, -- 4485
				newStr = newStr, -- 4486
				taskId = shared.taskId, -- 4487
				workDir = shared.workingDir -- 4488
			})) -- 4488
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4488
				if params.partialStreamRecovery ~= true then -- 4488
					shared.truncatedToolOverwritePath = nil -- 4492
				end -- 4492
				shared.unbuiltEdits = true -- 4494
				shared.lastBuildSucceeded = false -- 4495
				if shared.failedTestNeedsBuild == true then -- 4495
					shared.failedTestHasSourceEdit = true -- 4496
				end -- 4496
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4497
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4497
					editedPaths[#editedPaths + 1] = normalizedPath -- 4498
				end -- 4498
				shared.editedPathsSinceBuild = editedPaths -- 4499
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4500
			end -- 4500
			return ____awaiter_resolve(nil, result) -- 4500
		end -- 4500
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4500
	end) -- 4500
end -- 4500
function sanitizeToolActionResultForHistory(action, result) -- 4507
	if action.tool == "read_file" then -- 4507
		return sanitizeReadResultForHistory(action.tool, result) -- 4509
	end -- 4509
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4509
		return sanitizeSearchResultForHistory(action.tool, result) -- 4512
	end -- 4512
	if action.tool == "glob_files" then -- 4512
		return sanitizeListFilesResultForHistory(result) -- 4515
	end -- 4515
	if action.tool == "build" then -- 4515
		return sanitizeBuildResultForHistory(result) -- 4518
	end -- 4518
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4518
		if result.success ~= true then -- 4518
			return result -- 4521
		end -- 4521
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4521
			return result -- 4522
		end -- 4522
		if isArray(result.fileContext) then -- 4522
			return result -- 4523
		end -- 4523
		local contextLimits = { -- 4525
			fullContentChars = 12000, -- 4526
			previewChars = 4000, -- 4527
			diffChars = 8000, -- 4528
			totalChars = 24000, -- 4529
			maxFiles = 8 -- 4530
		} -- 4530
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4532
			if maxChars <= 0 then -- 4532
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4533
			end -- 4533
			if #sourceText <= maxChars then -- 4533
				return sourceText -- 4534
			end -- 4534
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4535
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4536
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4537
		end -- 4532
		local function countLines(sourceText) -- 4539
			if sourceText == "" then -- 4539
				return 0 -- 4540
			end -- 4540
			return #__TS__StringSplit(sourceText, "\n") -- 4541
		end -- 4539
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4543
			if beforeContent == afterContent then -- 4543
				return "" -- 4544
			end -- 4544
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4545
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4546
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4548
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4548
				firstChangedLine = firstChangedLine + 1 -- 4554
			end -- 4554
			local lastChangedBeforeLine = #beforeLines - 1 -- 4556
			local lastChangedAfterLine = #afterLines - 1 -- 4557
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4557
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4563
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4564
			end -- 4564
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4566
			local previewEndLine = math.max( -- 4567
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4568
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4569
			) -- 4569
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4571
			do -- 4571
				local lineIndex = previewStartLine -- 4572
				while lineIndex <= previewEndLine do -- 4572
					do -- 4572
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4573
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4574
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4575
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4576
						if not beforeChanged and not afterChanged then -- 4576
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4578
							if contextLine ~= nil then -- 4578
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4579
							end -- 4579
							goto __continue745 -- 4580
						end -- 4580
						if beforeChanged and beforeLine ~= nil then -- 4580
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4582
						end -- 4582
						if afterChanged and afterLine ~= nil then -- 4582
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4583
						end -- 4583
					end -- 4583
					::__continue745:: -- 4583
					lineIndex = lineIndex + 1 -- 4572
				end -- 4572
			end -- 4572
			return truncateContextSnippet( -- 4585
				table.concat(unifiedDiffLines, "\n"), -- 4585
				maxChars, -- 4585
				"diff" -- 4585
			) -- 4585
		end -- 4543
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4588
		if not checkpointDiff.success then -- 4588
			return result -- 4589
		end -- 4589
		local remainingContextBudget = contextLimits.totalChars -- 4590
		local fileContextItems = {} -- 4591
		local changedFiles = checkpointDiff.files -- 4592
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4593
		do -- 4593
			local fileIndex = 0 -- 4594
			while fileIndex < maxContextFiles do -- 4594
				if remainingContextBudget <= 0 then -- 4594
					break -- 4595
				end -- 4595
				local changedFile = changedFiles[fileIndex + 1] -- 4596
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4597
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4598
				local contextItem = { -- 4599
					path = changedFile.path, -- 4600
					op = changedFile.op, -- 4601
					checkpointId = result.checkpointId, -- 4602
					checkpointSeq = result.checkpointSeq, -- 4603
					beforeExists = changedFile.beforeExists, -- 4604
					afterExists = changedFile.afterExists, -- 4605
					beforeBytes = #beforeContent, -- 4606
					afterBytes = #afterContent, -- 4607
					diffPreview = "", -- 4608
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4609
					contentTruncated = false, -- 4610
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4611
				} -- 4611
				if changedFile.afterExists then -- 4611
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4611
						contextItem.afterContent = afterContent -- 4615
						remainingContextBudget = remainingContextBudget - #afterContent -- 4616
					else -- 4616
						contextItem.afterContentPreview = truncateContextSnippet( -- 4618
							afterContent, -- 4619
							math.min( -- 4620
								contextLimits.previewChars, -- 4620
								math.max(400, remainingContextBudget) -- 4620
							), -- 4620
							"afterContent" -- 4621
						) -- 4621
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4623
						contextItem.contentTruncated = true -- 4624
					end -- 4624
				end -- 4624
				local diffPreview = buildUnifiedDiffPreview( -- 4627
					changedFile.path, -- 4628
					beforeContent, -- 4629
					afterContent, -- 4630
					math.min( -- 4631
						contextLimits.diffChars, -- 4631
						math.max(400, remainingContextBudget) -- 4631
					) -- 4631
				) -- 4631
				contextItem.diffPreview = diffPreview -- 4633
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4634
				if not changedFile.afterExists and beforeContent ~= "" then -- 4634
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4636
						beforeContent, -- 4637
						math.min( -- 4638
							contextLimits.previewChars, -- 4638
							math.max(400, remainingContextBudget) -- 4638
						), -- 4638
						"beforeContent" -- 4639
					) -- 4639
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4641
					if #beforeContent > contextLimits.previewChars then -- 4641
						contextItem.contentTruncated = true -- 4642
					end -- 4642
				end -- 4642
				fileContextItems[#fileContextItems + 1] = contextItem -- 4644
				fileIndex = fileIndex + 1 -- 4594
			end -- 4594
		end -- 4594
		if #fileContextItems == 0 then -- 4594
			return result -- 4646
		end -- 4646
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4647
	end -- 4647
	return result -- 4654
end -- 4654
function emitAgentTaskFinishEvent(shared, success, message) -- 4855
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4856
	local result = success and ({ -- 4860
		success = true, -- 4862
		taskId = shared.taskId, -- 4863
		message = message, -- 4864
		steps = shared.step, -- 4865
		completion = completion -- 4866
	}) or ({ -- 4866
		success = false, -- 4869
		taskId = shared.taskId, -- 4870
		message = message, -- 4871
		steps = shared.step, -- 4872
		completion = completion -- 4873
	}) -- 4873
	emitAgentEvent(shared, { -- 4875
		type = "task_finished", -- 4876
		sessionId = shared.sessionId, -- 4877
		taskId = shared.taskId, -- 4878
		success = result.success, -- 4879
		message = result.message, -- 4880
		steps = result.steps, -- 4881
		completion = result.completion -- 4882
	}) -- 4882
	return result -- 4884
end -- 4884
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
local function llm(shared, messages, phase) -- 2178
	if phase == nil then -- 2178
		phase = "decision_xml" -- 2181
	end -- 2181
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2181
		local stepId = shared.step + 1 -- 2183
		emitLLMContextMetrics( -- 2184
			shared, -- 2184
			stepId, -- 2184
			phase, -- 2184
			messages, -- 2184
			shared.llmOptions -- 2184
		) -- 2184
		saveStepLLMDebugInput( -- 2185
			shared, -- 2185
			stepId, -- 2185
			phase, -- 2185
			messages, -- 2185
			shared.llmOptions -- 2185
		) -- 2185
		local lastStreamReasoning = "" -- 2186
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2187
			messages, -- 2188
			shared.llmOptions, -- 2189
			shared.stopToken, -- 2190
			shared.llmConfig, -- 2191
			function(response) -- 2192
				local ____opt_53 = response.choices -- 2192
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2192
				local streamMessage = ____opt_51 and ____opt_51.message -- 2193
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2194
				if nextContent == "" then -- 2194
					return -- 2197
				end -- 2197
				if nextContent == lastStreamReasoning then -- 2197
					return -- 2198
				end -- 2198
				lastStreamReasoning = nextContent -- 2199
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2200
			end -- 2192
		)) -- 2192
		if res.success then -- 2192
			local usage = res.tokenUsage -- 2204
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2205
			local ____opt_59 = res.response.choices -- 2205
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2205
			local message = ____opt_57 and ____opt_57.message -- 2206
			local text = message and message.content -- 2207
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2208
			if text then -- 2208
				local parsed = tryParseAndValidateDecision(text, shared) -- 2212
				if parsed.success then -- 2212
					local reason = parsed.reason or "" -- 2214
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2215
				end -- 2215
				saveStepLLMDebugOutput( -- 2217
					shared, -- 2217
					stepId, -- 2217
					phase, -- 2217
					text, -- 2217
					{success = true, usage = usage} -- 2217
				) -- 2217
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2217
			else -- 2217
				saveStepLLMDebugOutput( -- 2220
					shared, -- 2220
					stepId, -- 2220
					phase, -- 2220
					"empty LLM response", -- 2220
					{success = false, usage = usage} -- 2220
				) -- 2220
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2220
			end -- 2220
		else -- 2220
			local usage = res.tokenUsage -- 2224
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2225
			saveStepLLMDebugOutput( -- 2226
				shared, -- 2226
				stepId, -- 2226
				phase, -- 2226
				res.raw or res.message, -- 2226
				{success = false, usage = usage} -- 2226
			) -- 2226
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2226
		end -- 2226
	end) -- 2226
end -- 2178
local function isDecisionBatchSuccess(result) -- 2250
	return result.kind == "batch" -- 2251
end -- 2250
local function parseDecisionToolCall(functionName, rawObj) -- 2275
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2275
		return {success = false, message = "unknown tool: " .. functionName} -- 2277
	end -- 2277
	if rawObj == nil then -- 2277
		return {success = true, tool = functionName, params = {}} -- 2280
	end -- 2280
	if not isRecord(rawObj) then -- 2280
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2283
	end -- 2283
	return {success = true, tool = functionName, params = rawObj} -- 2285
end -- 2275
local function parseToolCallArguments(functionName, argsText) -- 2292
	local trimmedArgs = __TS__StringTrim(argsText) -- 2293
	if trimmedArgs == "" then -- 2293
		return {} -- 2295
	end -- 2295
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2297
	if err ~= nil or rawObj == nil then -- 2297
		return { -- 2299
			success = false, -- 2300
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2301
			raw = argsText -- 2302
		} -- 2302
	end -- 2302
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2305
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2305
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2307
	end -- 2307
	return rawObj -- 2313
end -- 2292
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2316
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2324
	if isRecord(rawArgs) and rawArgs.success == false then -- 2324
		return rawArgs -- 2326
	end -- 2326
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2328
	if not decision.success then -- 2328
		return {success = false, message = decision.message, raw = argsText} -- 2330
	end -- 2330
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2336
	if not completionValidation.success then -- 2336
		return {success = false, message = completionValidation.message, raw = argsText} -- 2338
	end -- 2338
	local validation = validateDecision(decision.tool, decision.params) -- 2344
	if not validation.success then -- 2344
		return {success = false, message = validation.message, raw = argsText} -- 2346
	end -- 2346
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2352
	if not sharedValidation.success then -- 2352
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2354
	end -- 2354
	decision.params = validation.params -- 2360
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2361
	decision.reason = reason -- 2362
	decision.reasoningContent = reasoningContent -- 2363
	return decision -- 2364
end -- 2316
local function createPreExecutableActionFromStream(shared, toolCall) -- 2367
	local ____opt_65 = toolCall["function"] -- 2367
	local functionName = ____opt_65 and ____opt_65.name -- 2368
	local ____opt_67 = toolCall["function"] -- 2368
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2369
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2370
	if not functionName or not toolCallId then -- 2370
		return nil -- 2371
	end -- 2371
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2372
	if isRecord(rawArgs) and rawArgs.success == false then -- 2372
		return nil -- 2373
	end -- 2373
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2374
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2374
		return nil -- 2375
	end -- 2375
	local validation = validateDecision(decision.tool, decision.params) -- 2376
	if not validation.success then -- 2376
		return nil -- 2377
	end -- 2377
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2377
		return nil -- 2378
	end -- 2378
	return { -- 2379
		step = shared.step + 1, -- 2380
		toolCallId = toolCallId, -- 2381
		tool = decision.tool, -- 2382
		reason = "", -- 2383
		params = validation.params, -- 2384
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2385
	} -- 2385
end -- 2367
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2778
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2787
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2788
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2796
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2797
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2798
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2806
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2814
		shared.role, -- 2814
		{ -- 2814
			includeFinish = true, -- 2815
			includeXmlRules = true, -- 2816
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2817
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2818
			workMode = shared.workMode -- 2819
		} -- 2819
	) -- 2819
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2821
	local repairPrompt = replacePromptVars( -- 2824
		shared.promptPack.xmlDecisionRepairPrompt, -- 2824
		{ -- 2824
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2825
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2826
			CANDIDATE_SECTION = candidateSection, -- 2827
			LAST_ERROR = lastError, -- 2828
			ATTEMPT = tostring(attempt) -- 2829
		} -- 2829
	) -- 2829
	return {{role = "system", content = systemPrompt}, {role = "user", content = repairPrompt}} -- 2831
end -- 2778
local MainDecisionAgent = __TS__Class() -- 2869
MainDecisionAgent.name = "MainDecisionAgent" -- 2869
__TS__ClassExtends(MainDecisionAgent, Node) -- 2869
function MainDecisionAgent.prototype.prep(self, shared) -- 2870
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2870
		if shared.stopToken.stopped or shared.agentStepCount >= shared.maxSteps then -- 2870
			return ____awaiter_resolve(nil, {shared = shared}) -- 2870
		end -- 2870
		__TS__Await(maybeCompressHistory(shared)) -- 2875
		return ____awaiter_resolve(nil, {shared = shared}) -- 2875
	end) -- 2875
end -- 2870
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2880
	local preExecuted = shared.preExecutedResults -- 2881
	if not preExecuted or preExecuted.size == 0 then -- 2881
		return nil -- 2882
	end -- 2882
	local decisions = {} -- 2883
	preExecuted:forEach(function(____, preResult) -- 2884
		local action = preResult.action -- 2885
		decisions[#decisions + 1] = { -- 2886
			success = true, -- 2887
			tool = action.tool, -- 2888
			params = action.params, -- 2889
			toolCallId = action.toolCallId, -- 2890
			reason = action.reason, -- 2891
			reasoningContent = action.reasoningContent -- 2892
		} -- 2892
	end) -- 2884
	if #decisions == 0 then -- 2884
		return nil -- 2895
	end -- 2895
	AgentUtils.Log( -- 2896
		"Warn", -- 2896
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2896
			__TS__ArrayMap( -- 2896
				decisions, -- 2896
				function(____, decision) return decision.tool end -- 2896
			), -- 2896
			"," -- 2896
		) -- 2896
	) -- 2896
	if #decisions == 1 then -- 2896
		return decisions[1] -- 2898
	end -- 2898
	return {success = true, kind = "batch", decisions = decisions} -- 2900
end -- 2880
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2907
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2912
	if not recovery then -- 2912
		return nil -- 2913
	end -- 2913
	shared.truncatedToolOverwritePath = recovery.target -- 2914
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2915
	return { -- 2916
		success = true, -- 2917
		tool = "edit_file", -- 2918
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2919
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2925
		reason = recovery.reason, -- 2926
		reasoningContent = reasoningContent -- 2927
	} -- 2927
end -- 2907
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2931
	if attempt == nil then -- 2931
		attempt = 1 -- 2934
	end -- 2934
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2934
		if shared.stopToken.stopped then -- 2934
			return ____awaiter_resolve( -- 2934
				nil, -- 2934
				{ -- 2938
					success = false, -- 2938
					message = getCancelledReason(shared) -- 2938
				} -- 2938
			) -- 2938
		end -- 2938
		AgentUtils.Log( -- 2940
			"Info", -- 2940
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2940
		) -- 2940
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2941
			shared.role, -- 2941
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2941
			{ -- 2941
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2942
				workMode = shared.workMode -- 2943
			} -- 2943
		) -- 2943
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2945
		local stepId = shared.step + 1 -- 2946
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2947
			string.lower(shared.llmConfig.model), -- 2947
			"glm-5.2" -- 2947
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2947
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2950
		emitLLMContextMetrics( -- 2955
			shared, -- 2955
			stepId, -- 2955
			"decision_tool_calling", -- 2955
			messages, -- 2955
			llmOptions -- 2955
		) -- 2955
		saveStepLLMDebugInput( -- 2956
			shared, -- 2956
			stepId, -- 2956
			"decision_tool_calling", -- 2956
			messages, -- 2956
			llmOptions -- 2956
		) -- 2956
		local lastStreamContent = "" -- 2957
		local lastStreamReasoning = "" -- 2958
		local preExecutedResults = __TS__New(Map) -- 2959
		shared.preExecutedResults = preExecutedResults -- 2960
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2961
			messages, -- 2962
			llmOptions, -- 2963
			shared.stopToken, -- 2964
			shared.llmConfig, -- 2965
			function(response) -- 2966
				local ____opt_75 = response.choices -- 2966
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2966
				local streamMessage = ____opt_73 and ____opt_73.message -- 2967
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2968
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2971
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2971
					return -- 2975
				end -- 2975
				lastStreamContent = nextContent -- 2977
				lastStreamReasoning = nextReasoning -- 2978
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2979
			end, -- 2966
			function(tc) -- 2981
				if shared.stopToken.stopped then -- 2981
					return -- 2982
				end -- 2982
				local action = createPreExecutableActionFromStream(shared, tc) -- 2983
				if not action or preExecutedResults:has(action.toolCallId) then -- 2983
					return -- 2984
				end -- 2984
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2985
				preExecutedResults:set( -- 2986
					action.toolCallId, -- 2986
					createPreExecutedToolResult(shared, action) -- 2986
				) -- 2986
			end -- 2981
		)) -- 2981
		if shared.stopToken.stopped then -- 2981
			clearPreExecutedResults(shared) -- 2990
			return ____awaiter_resolve( -- 2990
				nil, -- 2990
				{ -- 2991
					success = false, -- 2991
					message = getCancelledReason(shared) -- 2991
				} -- 2991
			) -- 2991
		end -- 2991
		if not res.success then -- 2991
			local usage = res.tokenUsage -- 2994
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2995
			saveStepLLMDebugOutput( -- 2996
				shared, -- 2996
				stepId, -- 2996
				"decision_tool_calling", -- 2996
				res.raw or res.message, -- 2996
				{success = false, usage = usage} -- 2996
			) -- 2996
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2997
			local committed = self:commitPreExecutedDecision(shared) -- 2998
			if committed then -- 2998
				return ____awaiter_resolve(nil, committed) -- 2998
			end -- 2998
			local ____opt_83 = res.response -- 2998
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2998
			local partialChoice = ____opt_81 and ____opt_81[1] -- 3000
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 3001
			local ____shared_93 = shared -- 3002
			local ____opt_85 = partialChoice and partialChoice.message -- 3002
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 3003
			local ____opt_89 = partialChoice and partialChoice.message -- 3003
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 3001
			if partialDraft then -- 3001
				return ____awaiter_resolve(nil, partialDraft) -- 3001
			end -- 3001
			clearPreExecutedResults(shared) -- 3007
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 3007
		end -- 3007
		local usage = res.tokenUsage -- 3010
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 3011
		saveStepLLMDebugOutput( -- 3012
			shared, -- 3012
			stepId, -- 3012
			"decision_tool_calling", -- 3012
			encodeDebugJSON(res.response), -- 3012
			{success = true, usage = usage} -- 3012
		) -- 3012
		local choice = res.response.choices and res.response.choices[1] -- 3013
		local message = choice and choice.message -- 3014
		local toolCalls = message and message.tool_calls -- 3015
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 3016
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 3019
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 3022
		AgentUtils.Log( -- 3025
			"Info", -- 3025
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3025
		) -- 3025
		if finishReason == "length" then -- 3025
			local committed = self:commitPreExecutedDecision(shared) -- 3027
			if committed then -- 3027
				return ____awaiter_resolve(nil, committed) -- 3027
			end -- 3027
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3029
			if partialDraft then -- 3029
				return ____awaiter_resolve(nil, partialDraft) -- 3029
			end -- 3029
			AgentUtils.Log( -- 3031
				"Error", -- 3031
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3031
			) -- 3031
			clearPreExecutedResults(shared) -- 3032
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3032
		end -- 3032
		if not toolCalls or #toolCalls == 0 then -- 3032
			if messageContent and messageContent ~= "" then -- 3032
				if isFinalDecisionTurn(shared) then -- 3032
					clearPreExecutedResults(shared) -- 3042
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3042
				end -- 3042
				if shared.role == "sub" then -- 3042
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3050
					clearPreExecutedResults(shared) -- 3051
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3051
				end -- 3051
				AgentUtils.Log( -- 3058
					"Info", -- 3058
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3058
				) -- 3058
				clearPreExecutedResults(shared) -- 3059
				return ____awaiter_resolve(nil, { -- 3059
					success = true, -- 3061
					tool = "finish", -- 3062
					params = {}, -- 3063
					reason = messageContent, -- 3064
					reasoningContent = reasoningContent, -- 3065
					directSummary = messageContent -- 3066
				}) -- 3066
			end -- 3066
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3069
			clearPreExecutedResults(shared) -- 3070
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3070
		end -- 3070
		local decisions = {} -- 3077
		do -- 3077
			local i = 0 -- 3078
			while i < #toolCalls do -- 3078
				local toolCall = toolCalls[i + 1] -- 3079
				local fn = toolCall ~= nil and toolCall["function"] -- 3080
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3080
					AgentUtils.Log( -- 3082
						"Error", -- 3082
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3082
					) -- 3082
					clearPreExecutedResults(shared) -- 3083
					return ____awaiter_resolve( -- 3083
						nil, -- 3083
						{ -- 3084
							success = false, -- 3085
							message = "missing function name for tool call " .. tostring(i + 1), -- 3086
							raw = messageContent -- 3087
						} -- 3087
					) -- 3087
				end -- 3087
				local functionName = fn.name -- 3090
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3091
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3092
				AgentUtils.Log( -- 3095
					"Info", -- 3095
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3095
				) -- 3095
				local decision = parseAndValidateToolCallDecision( -- 3096
					shared, -- 3097
					functionName, -- 3098
					argsText, -- 3099
					toolCallId, -- 3100
					messageContent, -- 3101
					reasoningContent -- 3102
				) -- 3102
				if not decision.success then -- 3102
					AgentUtils.Log( -- 3105
						"Error", -- 3105
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3105
					) -- 3105
					clearPreExecutedResults(shared) -- 3106
					return ____awaiter_resolve(nil, decision) -- 3106
				end -- 3106
				decisions[#decisions + 1] = decision -- 3109
				i = i + 1 -- 3078
			end -- 3078
		end -- 3078
		if #decisions == 1 then -- 3078
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3112
			return ____awaiter_resolve(nil, decisions[1]) -- 3112
		end -- 3112
		do -- 3112
			local i = 0 -- 3115
			while i < #decisions do -- 3115
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3115
					clearPreExecutedResults(shared) -- 3117
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3117
				end -- 3117
				i = i + 1 -- 3115
			end -- 3115
		end -- 3115
		AgentUtils.Log( -- 3125
			"Info", -- 3125
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3125
				__TS__ArrayMap( -- 3125
					decisions, -- 3125
					function(____, decision) return decision.tool end -- 3125
				), -- 3125
				"," -- 3125
			) -- 3125
		) -- 3125
		return ____awaiter_resolve(nil, { -- 3125
			success = true, -- 3127
			kind = "batch", -- 3128
			decisions = decisions, -- 3129
			content = messageContent, -- 3130
			reasoningContent = reasoningContent -- 3131
		}) -- 3131
	end) -- 3131
end -- 2931
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3135
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3135
		AgentUtils.Log( -- 3141
			"Info", -- 3141
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3141
		) -- 3141
		local lastError = initialError -- 3142
		local candidateRaw = "" -- 3143
		local candidateReasoning = nil -- 3144
		do -- 3144
			local attempt = 0 -- 3145
			while attempt < shared.llmMaxTry do -- 3145
				do -- 3145
					AgentUtils.Log( -- 3146
						"Info", -- 3146
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3146
					) -- 3146
					local messages = buildXmlRepairMessages( -- 3147
						shared, -- 3148
						originalRaw, -- 3149
						originalReasoning, -- 3150
						candidateRaw, -- 3151
						candidateReasoning, -- 3152
						lastError, -- 3153
						attempt + 1 -- 3154
					) -- 3154
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3156
					if shared.stopToken.stopped then -- 3156
						return ____awaiter_resolve( -- 3156
							nil, -- 3156
							{ -- 3158
								success = false, -- 3158
								message = getCancelledReason(shared) -- 3158
							} -- 3158
						) -- 3158
					end -- 3158
					if not llmRes.success then -- 3158
						lastError = llmRes.message -- 3161
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3162
						goto __continue533 -- 3163
					end -- 3163
					candidateRaw = llmRes.text -- 3165
					candidateReasoning = llmRes.reasoningContent -- 3166
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3167
					if decision.success then -- 3167
						decision.reasoningContent = llmRes.reasoningContent -- 3169
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3170
						return ____awaiter_resolve(nil, decision) -- 3170
					end -- 3170
					lastError = decision.message -- 3173
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3174
				end -- 3174
				::__continue533:: -- 3174
				attempt = attempt + 1 -- 3145
			end -- 3145
		end -- 3145
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3176
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3176
	end) -- 3176
end -- 3135
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3184
	if attempt == nil then -- 3184
		attempt = 1 -- 3187
	end -- 3187
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3187
		local messages = buildDecisionMessages( -- 3190
			shared, -- 3191
			lastError, -- 3192
			attempt, -- 3193
			lastRaw, -- 3194
			"xml" -- 3195
		) -- 3195
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3197
		if shared.stopToken.stopped then -- 3197
			return ____awaiter_resolve( -- 3197
				nil, -- 3197
				{ -- 3199
					success = false, -- 3199
					message = getCancelledReason(shared) -- 3199
				} -- 3199
			) -- 3199
		end -- 3199
		if not llmRes.success then -- 3199
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3199
		end -- 3199
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3208
		if decision.success then -- 3208
			decision.reasoningContent = llmRes.reasoningContent -- 3210
			return ____awaiter_resolve(nil, decision) -- 3210
		end -- 3210
		return ____awaiter_resolve( -- 3210
			nil, -- 3210
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3213
		) -- 3213
	end) -- 3213
end -- 3184
function MainDecisionAgent.prototype.exec(self, input) -- 3216
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3216
		local shared = input.shared -- 3217
		if shared.stopToken.stopped then -- 3217
			return ____awaiter_resolve( -- 3217
				nil, -- 3217
				{ -- 3219
					success = false, -- 3219
					message = getCancelledReason(shared) -- 3219
				} -- 3219
			) -- 3219
		end -- 3219
		if shared.agentStepCount >= shared.maxSteps then -- 3219
			AgentUtils.Log( -- 3222
				"Warn", -- 3222
				(((("[CodingAgent] maximum step limit reached agent_steps=" .. tostring(shared.agentStepCount)) .. " timeline_step=") .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3222
			) -- 3222
			return ____awaiter_resolve( -- 3222
				nil, -- 3222
				{ -- 3223
					success = false, -- 3223
					message = getMaxStepsReachedReason(shared) -- 3223
				} -- 3223
			) -- 3223
		end -- 3223
		if shared.decisionMode == "tool_calling" then -- 3223
			AgentUtils.Log( -- 3227
				"Info", -- 3227
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3227
			) -- 3227
			local lastError = "tool calling validation failed" -- 3228
			local lastRaw = "" -- 3229
			local shouldFallbackToXml = false -- 3230
			do -- 3230
				local attempt = 0 -- 3231
				while attempt < shared.llmMaxTry do -- 3231
					AgentUtils.Log( -- 3232
						"Info", -- 3232
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3232
					) -- 3232
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3233
					if shared.stopToken.stopped then -- 3233
						return ____awaiter_resolve( -- 3233
							nil, -- 3233
							{ -- 3240
								success = false, -- 3240
								message = getCancelledReason(shared) -- 3240
							} -- 3240
						) -- 3240
					end -- 3240
					if decision.success then -- 3240
						return ____awaiter_resolve(nil, decision) -- 3240
					end -- 3240
					lastError = decision.message -- 3245
					lastRaw = decision.raw or "" -- 3246
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3247
					if lastError == "missing tool call" then -- 3247
						shouldFallbackToXml = true -- 3249
						break -- 3250
					end -- 3250
					attempt = attempt + 1 -- 3231
				end -- 3231
			end -- 3231
			if shouldFallbackToXml then -- 3231
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3254
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3255
				do -- 3255
					local attempt = 0 -- 3256
					while attempt < shared.llmMaxTry do -- 3256
						AgentUtils.Log( -- 3257
							"Info", -- 3257
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3257
						) -- 3257
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3258
						if shared.stopToken.stopped then -- 3258
							return ____awaiter_resolve( -- 3258
								nil, -- 3258
								{ -- 3265
									success = false, -- 3265
									message = getCancelledReason(shared) -- 3265
								} -- 3265
							) -- 3265
						end -- 3265
						if decision.success then -- 3265
							return ____awaiter_resolve(nil, decision) -- 3265
						end -- 3265
						lastError = decision.message -- 3270
						lastRaw = decision.raw or "" -- 3271
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3272
						attempt = attempt + 1 -- 3256
					end -- 3256
				end -- 3256
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3274
				return ____awaiter_resolve( -- 3274
					nil, -- 3274
					{ -- 3275
						success = false, -- 3275
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3275
					} -- 3275
				) -- 3275
			end -- 3275
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3277
			return ____awaiter_resolve( -- 3277
				nil, -- 3277
				{ -- 3278
					success = false, -- 3278
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3278
				} -- 3278
			) -- 3278
		end -- 3278
		local lastError = "xml validation failed" -- 3281
		local lastRaw = "" -- 3282
		do -- 3282
			local attempt = 0 -- 3283
			while attempt < shared.llmMaxTry do -- 3283
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3284
				if shared.stopToken.stopped then -- 3284
					return ____awaiter_resolve( -- 3284
						nil, -- 3284
						{ -- 3293
							success = false, -- 3293
							message = getCancelledReason(shared) -- 3293
						} -- 3293
					) -- 3293
				end -- 3293
				if decision.success then -- 3293
					return ____awaiter_resolve(nil, decision) -- 3293
				end -- 3293
				lastError = decision.message -- 3298
				lastRaw = decision.raw or "" -- 3299
				attempt = attempt + 1 -- 3283
			end -- 3283
		end -- 3283
		return ____awaiter_resolve( -- 3283
			nil, -- 3283
			{ -- 3301
				success = false, -- 3301
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3301
			} -- 3301
		) -- 3301
	end) -- 3301
end -- 3216
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3304
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3304
		local result = execRes -- 3305
		if not result.success then -- 3305
			if shared.stopToken.stopped then -- 3305
				shared.error = getCancelledReason(shared) -- 3308
				shared.done = true -- 3309
				return ____awaiter_resolve(nil, "done") -- 3309
			end -- 3309
			shared.error = result.message -- 3312
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3313
			shared.done = true -- 3314
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3315
			persistHistoryState(shared) -- 3319
			return ____awaiter_resolve(nil, "done") -- 3319
		end -- 3319
		if isDecisionBatchSuccess(result) then -- 3319
			local startStep = shared.step -- 3323
			local actions = {} -- 3324
			do -- 3324
				local i = 0 -- 3325
				while i < #result.decisions do -- 3325
					local decision = result.decisions[i + 1] -- 3326
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3327
					local step = startStep + i + 1 -- 3328
					local ____temp_96 -- 3329
					if i == 0 then -- 3329
						____temp_96 = decision.reason -- 3329
					else -- 3329
						____temp_96 = "" -- 3329
					end -- 3329
					local actionReason = ____temp_96 -- 3329
					local ____temp_97 -- 3330
					if i == 0 then -- 3330
						____temp_97 = decision.reasoningContent -- 3330
					else -- 3330
						____temp_97 = nil -- 3330
					end -- 3330
					local actionReasoningContent = ____temp_97 -- 3330
					emitAgentEvent(shared, { -- 3331
						type = "decision_made", -- 3332
						sessionId = shared.sessionId, -- 3333
						taskId = shared.taskId, -- 3334
						step = step, -- 3335
						tool = decision.tool, -- 3336
						reason = actionReason, -- 3337
						reasoningContent = actionReasoningContent, -- 3338
						params = decision.params -- 3339
					}) -- 3339
					local action = { -- 3341
						step = step, -- 3342
						toolCallId = toolCallId, -- 3343
						tool = decision.tool, -- 3344
						reason = actionReason or "", -- 3345
						reasoningContent = actionReasoningContent, -- 3346
						params = decision.params, -- 3347
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3348
					} -- 3348
					local ____shared_history_98 = shared.history -- 3348
					____shared_history_98[#____shared_history_98 + 1] = action -- 3350
					actions[#actions + 1] = action -- 3351
					i = i + 1 -- 3325
				end -- 3325
			end -- 3325
			shared.step = startStep + #actions -- 3353
			shared.agentStepCount = shared.agentStepCount + #actions -- 3354
			shared.pendingToolActions = actions -- 3355
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3356
			persistHistoryState(shared) -- 3362
			return ____awaiter_resolve(nil, "batch_tools") -- 3362
		end -- 3362
		if result.directSummary and result.directSummary ~= "" then -- 3362
			shared.response = result.directSummary -- 3366
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3367
			shared.done = true -- 3371
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3372
			persistHistoryState(shared) -- 3377
			return ____awaiter_resolve(nil, "done") -- 3377
		end -- 3377
		if result.tool == "finish" then -- 3377
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3381
			shared.response = finalMessage -- 3382
			shared.completion = getCompletionReport(result.params) -- 3383
			shared.done = true -- 3384
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3385
			persistHistoryState(shared) -- 3390
			return ____awaiter_resolve(nil, "done") -- 3390
		end -- 3390
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3393
		shared.step = shared.step + 1 -- 3394
		shared.agentStepCount = shared.agentStepCount + 1 -- 3395
		local step = shared.step -- 3396
		emitAgentEvent(shared, { -- 3397
			type = "decision_made", -- 3398
			sessionId = shared.sessionId, -- 3399
			taskId = shared.taskId, -- 3400
			step = step, -- 3401
			tool = result.tool, -- 3402
			reason = result.reason, -- 3403
			reasoningContent = result.reasoningContent, -- 3404
			params = result.params -- 3405
		}) -- 3405
		local ____shared_history_99 = shared.history -- 3405
		____shared_history_99[#____shared_history_99 + 1] = { -- 3407
			step = step, -- 3408
			toolCallId = toolCallId, -- 3409
			tool = result.tool, -- 3410
			reason = result.reason or "", -- 3411
			reasoningContent = result.reasoningContent, -- 3412
			params = result.params, -- 3413
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3414
		} -- 3414
		local action = shared.history[#shared.history] -- 3416
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3417
		shared.pendingToolActions = {action} -- 3420
		persistHistoryState(shared) -- 3421
		return ____awaiter_resolve(nil, "batch_tools") -- 3421
	end) -- 3421
end -- 3304
local ReadFileAction = __TS__Class() -- 3426
ReadFileAction.name = "ReadFileAction" -- 3426
__TS__ClassExtends(ReadFileAction, Node) -- 3426
function ReadFileAction.prototype.prep(self, shared) -- 3427
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3427
		local last = shared.history[#shared.history] -- 3428
		if not last then -- 3428
			error( -- 3429
				__TS__New(Error, "no history"), -- 3429
				0 -- 3429
			) -- 3429
		end -- 3429
		emitAgentStartEvent(shared, last) -- 3430
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3431
		if __TS__StringTrim(path) == "" then -- 3431
			error( -- 3434
				__TS__New(Error, "missing path"), -- 3434
				0 -- 3434
			) -- 3434
		end -- 3434
		local ____path_102 = path -- 3436
		local ____shared_workingDir_103 = shared.workingDir -- 3438
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3439
		local ____last_params_startLine_100 = last.params.startLine -- 3440
		if ____last_params_startLine_100 == nil then -- 3440
			____last_params_startLine_100 = 1 -- 3440
		end -- 3440
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3440
		local ____last_params_endLine_101 = last.params.endLine -- 3441
		if ____last_params_endLine_101 == nil then -- 3441
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3441
		end -- 3441
		return ____awaiter_resolve( -- 3441
			nil, -- 3441
			{ -- 3435
				path = ____path_102, -- 3436
				tool = "read_file", -- 3437
				workDir = ____shared_workingDir_103, -- 3438
				docLanguage = ____temp_104, -- 3439
				startLine = ____TS__Number_result_105, -- 3440
				endLine = __TS__Number(____last_params_endLine_101) -- 3441
			} -- 3441
		) -- 3441
	end) -- 3441
end -- 3427
function ReadFileAction.prototype.exec(self, input) -- 3445
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3445
		return ____awaiter_resolve( -- 3445
			nil, -- 3445
			Tools.readFile( -- 3446
				input.workDir, -- 3447
				input.path, -- 3448
				__TS__Number(input.startLine or 1), -- 3449
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3450
				input.docLanguage -- 3451
			) -- 3451
		) -- 3451
	end) -- 3451
end -- 3445
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3455
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3455
		local result = execRes -- 3456
		local last = shared.history[#shared.history] -- 3457
		if last ~= nil then -- 3457
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3459
			appendToolResultMessage(shared, last) -- 3460
			emitAgentFinishEvent(shared, last) -- 3461
		end -- 3461
		persistHistoryState(shared) -- 3463
		__TS__Await(maybeCompressHistory(shared)) -- 3464
		persistHistoryState(shared) -- 3465
		return ____awaiter_resolve(nil, "main") -- 3465
	end) -- 3465
end -- 3455
local SearchFilesAction = __TS__Class() -- 3470
SearchFilesAction.name = "SearchFilesAction" -- 3470
__TS__ClassExtends(SearchFilesAction, Node) -- 3470
function SearchFilesAction.prototype.prep(self, shared) -- 3471
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3471
		local last = shared.history[#shared.history] -- 3472
		if not last then -- 3472
			error( -- 3473
				__TS__New(Error, "no history"), -- 3473
				0 -- 3473
			) -- 3473
		end -- 3473
		emitAgentStartEvent(shared, last) -- 3474
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3474
	end) -- 3474
end -- 3471
function SearchFilesAction.prototype.exec(self, input) -- 3478
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3478
		local params = input.params -- 3479
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3480
		local ____input_workDir_112 = input.workDir -- 3481
		local ____temp_113 = params.path or "" -- 3482
		local ____temp_114 = params.pattern or "" -- 3483
		local ____params_globs_115 = params.globs -- 3484
		local ____params_useRegex_116 = params.useRegex -- 3485
		local ____params_caseSensitive_117 = params.caseSensitive -- 3486
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3488
		local ____math_max_108 = math.max -- 3489
		local ____math_floor_107 = math.floor -- 3489
		local ____params_limit_106 = params.limit -- 3489
		if ____params_limit_106 == nil then -- 3489
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3489
		end -- 3489
		local ____math_max_108_result_119 = ____math_max_108( -- 3489
			1, -- 3489
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3489
		) -- 3489
		local ____math_max_111 = math.max -- 3490
		local ____math_floor_110 = math.floor -- 3490
		local ____params_offset_109 = params.offset -- 3490
		if ____params_offset_109 == nil then -- 3490
			____params_offset_109 = 0 -- 3490
		end -- 3490
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3480
			workDir = ____input_workDir_112, -- 3481
			path = ____temp_113, -- 3482
			pattern = ____temp_114, -- 3483
			globs = ____params_globs_115, -- 3484
			useRegex = ____params_useRegex_116, -- 3485
			caseSensitive = ____params_caseSensitive_117, -- 3486
			includeContent = true, -- 3487
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3488
			limit = ____math_max_108_result_119, -- 3489
			offset = ____math_max_111( -- 3490
				0, -- 3490
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3490
			), -- 3490
			groupByFile = params.groupByFile == true -- 3491
		})) -- 3491
		return ____awaiter_resolve(nil, result) -- 3491
	end) -- 3491
end -- 3478
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3496
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3496
		local last = shared.history[#shared.history] -- 3497
		if last ~= nil then -- 3497
			local result = execRes -- 3499
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3500
			appendToolResultMessage(shared, last) -- 3501
			emitAgentFinishEvent(shared, last) -- 3502
		end -- 3502
		persistHistoryState(shared) -- 3504
		__TS__Await(maybeCompressHistory(shared)) -- 3505
		persistHistoryState(shared) -- 3506
		return ____awaiter_resolve(nil, "main") -- 3506
	end) -- 3506
end -- 3496
local SearchDoraAPIAction = __TS__Class() -- 3511
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3511
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3511
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3512
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3512
		local last = shared.history[#shared.history] -- 3513
		if not last then -- 3513
			error( -- 3514
				__TS__New(Error, "no history"), -- 3514
				0 -- 3514
			) -- 3514
		end -- 3514
		emitAgentStartEvent(shared, last) -- 3515
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3515
	end) -- 3515
end -- 3512
function SearchDoraAPIAction.prototype.exec(self, input) -- 3519
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3519
		local params = input.params -- 3520
		local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3521
		local ____temp_125 = params.pattern or "" -- 3522
		local ____temp_126 = params.docSource or "api" -- 3523
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3524
		local ____temp_128 = params.programmingLanguage or "ts" -- 3525
		local ____math_min_124 = math.min -- 3526
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3526
		local ____math_max_122 = math.max -- 3526
		local ____params_limit_121 = params.limit -- 3526
		if ____params_limit_121 == nil then -- 3526
			____params_limit_121 = 8 -- 3526
		end -- 3526
		local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3521
			pattern = ____temp_125, -- 3522
			docSource = ____temp_126, -- 3523
			docLanguage = ____temp_127, -- 3524
			programmingLanguage = ____temp_128, -- 3525
			limit = ____math_min_124( -- 3526
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123, -- 3526
				____math_max_122( -- 3526
					1, -- 3526
					__TS__Number(____params_limit_121) -- 3526
				) -- 3526
			), -- 3526
			useRegex = params.useRegex, -- 3527
			caseSensitive = false, -- 3528
			includeContent = true, -- 3529
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3530
		})) -- 3530
		return ____awaiter_resolve(nil, result) -- 3530
	end) -- 3530
end -- 3519
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3535
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3535
		local last = shared.history[#shared.history] -- 3536
		if last ~= nil then -- 3536
			local result = execRes -- 3538
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3539
			appendToolResultMessage(shared, last) -- 3540
			emitAgentFinishEvent(shared, last) -- 3541
		end -- 3541
		persistHistoryState(shared) -- 3543
		__TS__Await(maybeCompressHistory(shared)) -- 3544
		persistHistoryState(shared) -- 3545
		return ____awaiter_resolve(nil, "main") -- 3545
	end) -- 3545
end -- 3535
local ListFilesAction = __TS__Class() -- 3550
ListFilesAction.name = "ListFilesAction" -- 3550
__TS__ClassExtends(ListFilesAction, Node) -- 3550
function ListFilesAction.prototype.prep(self, shared) -- 3551
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3551
		local last = shared.history[#shared.history] -- 3552
		if not last then -- 3552
			error( -- 3553
				__TS__New(Error, "no history"), -- 3553
				0 -- 3553
			) -- 3553
		end -- 3553
		emitAgentStartEvent(shared, last) -- 3554
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3554
	end) -- 3554
end -- 3551
function ListFilesAction.prototype.exec(self, input) -- 3558
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3558
		local params = input.params -- 3559
		local ____Tools_listFiles_136 = Tools.listFiles -- 3560
		local ____input_workDir_133 = input.workDir -- 3561
		local ____temp_134 = params.path or "" -- 3562
		local ____params_globs_135 = params.globs -- 3563
		local ____math_max_132 = math.max -- 3564
		local ____math_floor_131 = math.floor -- 3564
		local ____params_maxEntries_130 = params.maxEntries -- 3564
		if ____params_maxEntries_130 == nil then -- 3564
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3564
		end -- 3564
		local result = ____Tools_listFiles_136({ -- 3560
			workDir = ____input_workDir_133, -- 3561
			path = ____temp_134, -- 3562
			globs = ____params_globs_135, -- 3563
			maxEntries = ____math_max_132( -- 3564
				1, -- 3564
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3564
			) -- 3564
		}) -- 3564
		return ____awaiter_resolve(nil, result) -- 3564
	end) -- 3564
end -- 3558
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3569
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3569
		local last = shared.history[#shared.history] -- 3570
		if last ~= nil then -- 3570
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3572
			appendToolResultMessage(shared, last) -- 3573
			emitAgentFinishEvent(shared, last) -- 3574
		end -- 3574
		persistHistoryState(shared) -- 3576
		__TS__Await(maybeCompressHistory(shared)) -- 3577
		persistHistoryState(shared) -- 3578
		return ____awaiter_resolve(nil, "main") -- 3578
	end) -- 3578
end -- 3569
local DeleteFileAction = __TS__Class() -- 3583
DeleteFileAction.name = "DeleteFileAction" -- 3583
__TS__ClassExtends(DeleteFileAction, Node) -- 3583
function DeleteFileAction.prototype.prep(self, shared) -- 3584
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3584
		local last = shared.history[#shared.history] -- 3585
		if not last then -- 3585
			error( -- 3586
				__TS__New(Error, "no history"), -- 3586
				0 -- 3586
			) -- 3586
		end -- 3586
		emitAgentStartEvent(shared, last) -- 3587
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3588
		if __TS__StringTrim(targetFile) == "" then -- 3588
			error( -- 3591
				__TS__New(Error, "missing target_file"), -- 3591
				0 -- 3591
			) -- 3591
		end -- 3591
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3591
	end) -- 3591
end -- 3584
function DeleteFileAction.prototype.exec(self, input) -- 3595
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3595
		local result = Tools.deleteFile(input.taskId, input.workDir, input.targetFile, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3596
		if not result.success then -- 3596
			return ____awaiter_resolve(nil, result) -- 3596
		end -- 3596
		local ____result_checkpointed_138 = result.checkpointed -- 3607
		local ____result_reversible_139 = result.reversible -- 3608
		local ____result_binary_140 = result.binary -- 3609
		local ____temp_141 = result.checkpointed and result.checkpointId or nil -- 3610
		local ____temp_142 = result.checkpointed and result.checkpointSeq or nil -- 3611
		local ____result_checkpointed_137 -- 3612
		if result.checkpointed then -- 3612
			____result_checkpointed_137 = nil -- 3612
		else -- 3612
			____result_checkpointed_137 = result.message -- 3612
		end -- 3612
		return ____awaiter_resolve(nil, { -- 3612
			success = true, -- 3604
			changed = true, -- 3605
			mode = "delete", -- 3606
			checkpointed = ____result_checkpointed_138, -- 3607
			reversible = ____result_reversible_139, -- 3608
			binary = ____result_binary_140, -- 3609
			checkpointId = ____temp_141, -- 3610
			checkpointSeq = ____temp_142, -- 3611
			message = ____result_checkpointed_137, -- 3612
			files = {{path = input.targetFile, op = "delete"}} -- 3613
		}) -- 3613
	end) -- 3613
end -- 3595
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3617
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3617
		local last = shared.history[#shared.history] -- 3618
		if last ~= nil then -- 3618
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3620
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3621
			appendToolResultMessage(shared, last) -- 3622
			emitAgentFinishEvent(shared, last) -- 3623
			local result = last.result -- 3624
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3624
				emitAgentEvent(shared, { -- 3629
					type = "checkpoint_created", -- 3630
					sessionId = shared.sessionId, -- 3631
					taskId = shared.taskId, -- 3632
					step = last.step, -- 3633
					tool = "delete_file", -- 3634
					checkpointId = result.checkpointId, -- 3635
					checkpointSeq = result.checkpointSeq, -- 3636
					files = result.files -- 3637
				}) -- 3637
			end -- 3637
		end -- 3637
		persistHistoryState(shared) -- 3644
		__TS__Await(maybeCompressHistory(shared)) -- 3645
		persistHistoryState(shared) -- 3646
		return ____awaiter_resolve(nil, "main") -- 3646
	end) -- 3646
end -- 3617
local BuildAction = __TS__Class() -- 3651
BuildAction.name = "BuildAction" -- 3651
__TS__ClassExtends(BuildAction, Node) -- 3651
function BuildAction.prototype.prep(self, shared) -- 3652
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3652
		local last = shared.history[#shared.history] -- 3653
		if not last then -- 3653
			error( -- 3654
				__TS__New(Error, "no history"), -- 3654
				0 -- 3654
			) -- 3654
		end -- 3654
		emitAgentStartEvent(shared, last) -- 3655
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3655
	end) -- 3655
end -- 3652
function BuildAction.prototype.exec(self, input) -- 3659
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3659
		local params = input.params -- 3660
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3661
		return ____awaiter_resolve(nil, result) -- 3661
	end) -- 3661
end -- 3659
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3668
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3668
		local last = shared.history[#shared.history] -- 3669
		if last ~= nil then -- 3669
			last.result = sanitizeBuildResultForHistory(execRes) -- 3671
			appendToolResultMessage(shared, last) -- 3672
			emitAgentFinishEvent(shared, last) -- 3673
		end -- 3673
		persistHistoryState(shared) -- 3675
		__TS__Await(maybeCompressHistory(shared)) -- 3676
		persistHistoryState(shared) -- 3677
		return ____awaiter_resolve(nil, "main") -- 3677
	end) -- 3677
end -- 3668
local SpawnSubAgentAction = __TS__Class() -- 3682
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3682
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3682
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3683
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3683
		local last = shared.history[#shared.history] -- 3693
		if not last then -- 3693
			error( -- 3694
				__TS__New(Error, "no history"), -- 3694
				0 -- 3694
			) -- 3694
		end -- 3694
		emitAgentStartEvent(shared, last) -- 3695
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3696
			last.params.filesHint, -- 3697
			function(____, item) return type(item) == "string" end -- 3697
		) or nil -- 3697
		return ____awaiter_resolve( -- 3697
			nil, -- 3697
			{ -- 3699
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3700
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3701
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3702
				filesHint = filesHint, -- 3703
				sessionId = shared.sessionId, -- 3704
				projectRoot = shared.workingDir, -- 3705
				spawnSubAgent = shared.spawnSubAgent, -- 3706
				disabledAgentTools = shared.disabledAgentTools -- 3707
			} -- 3707
		) -- 3707
	end) -- 3707
end -- 3683
function SpawnSubAgentAction.prototype.exec(self, input) -- 3711
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3711
		if not input.spawnSubAgent then -- 3711
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3711
		end -- 3711
		if input.sessionId == nil or input.sessionId <= 0 then -- 3711
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3711
		end -- 3711
		local ____AgentUtils_Log_148 = AgentUtils.Log -- 3727
		local ____temp_145 = #input.title -- 3727
		local ____temp_146 = #input.prompt -- 3727
		local ____temp_147 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3727
		local ____opt_143 = input.filesHint -- 3727
		____AgentUtils_Log_148( -- 3727
			"Info", -- 3727
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_145)) .. " prompt_len=") .. tostring(____temp_146)) .. " expected_len=") .. tostring(____temp_147)) .. " files_hint_count=") .. tostring(____opt_143 and #____opt_143 or 0) -- 3727
		) -- 3727
		local result = __TS__Await(input.spawnSubAgent({ -- 3728
			parentSessionId = input.sessionId, -- 3729
			projectRoot = input.projectRoot, -- 3730
			title = input.title, -- 3731
			prompt = input.prompt, -- 3732
			expectedOutput = input.expectedOutput, -- 3733
			filesHint = input.filesHint, -- 3734
			disabledAgentTools = input.disabledAgentTools -- 3735
		})) -- 3735
		if not result.success then -- 3735
			return ____awaiter_resolve(nil, result) -- 3735
		end -- 3735
		return ____awaiter_resolve(nil, { -- 3735
			success = true, -- 3741
			sessionId = result.sessionId, -- 3742
			taskId = result.taskId, -- 3743
			title = result.title, -- 3744
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3745
		}) -- 3745
	end) -- 3745
end -- 3711
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3749
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3749
		local last = shared.history[#shared.history] -- 3750
		if last ~= nil then -- 3750
			last.result = execRes -- 3752
			if execRes.success == true then -- 3752
				shared.hasSpawnedSubAgentThisTask = true -- 3754
			end -- 3754
			appendToolResultMessage(shared, last) -- 3756
			emitAgentFinishEvent(shared, last) -- 3757
		end -- 3757
		persistHistoryState(shared) -- 3759
		__TS__Await(maybeCompressHistory(shared)) -- 3760
		persistHistoryState(shared) -- 3761
		return ____awaiter_resolve(nil, "main") -- 3761
	end) -- 3761
end -- 3749
local ListSubAgentsAction = __TS__Class() -- 3766
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3766
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3766
function ListSubAgentsAction.prototype.prep(self, shared) -- 3767
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3767
		local last = shared.history[#shared.history] -- 3777
		if not last then -- 3777
			error( -- 3778
				__TS__New(Error, "no history"), -- 3778
				0 -- 3778
			) -- 3778
		end -- 3778
		emitAgentStartEvent(shared, last) -- 3779
		return ____awaiter_resolve( -- 3779
			nil, -- 3779
			{ -- 3780
				sessionId = shared.sessionId, -- 3781
				projectRoot = shared.workingDir, -- 3782
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3783
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3784
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3785
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3786
				listSubAgents = shared.listSubAgents, -- 3787
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3788
			} -- 3788
		) -- 3788
	end) -- 3788
end -- 3767
function ListSubAgentsAction.prototype.exec(self, input) -- 3792
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3792
		if not input.listSubAgents then -- 3792
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3792
		end -- 3792
		if input.sessionId == nil or input.sessionId <= 0 then -- 3792
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3792
		end -- 3792
		local result = __TS__Await(input.listSubAgents({ -- 3808
			sessionId = input.sessionId, -- 3809
			projectRoot = input.projectRoot, -- 3810
			status = input.status, -- 3811
			limit = input.limit, -- 3812
			offset = input.offset, -- 3813
			query = input.query -- 3814
		})) -- 3814
		return ____awaiter_resolve( -- 3814
			nil, -- 3814
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3816
		) -- 3816
	end) -- 3816
end -- 3792
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3824
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3824
		local last = shared.history[#shared.history] -- 3825
		if last ~= nil then -- 3825
			last.result = execRes -- 3827
			appendToolResultMessage(shared, last) -- 3828
			emitAgentFinishEvent(shared, last) -- 3829
		end -- 3829
		persistHistoryState(shared) -- 3831
		__TS__Await(maybeCompressHistory(shared)) -- 3832
		persistHistoryState(shared) -- 3833
		return ____awaiter_resolve(nil, "main") -- 3833
	end) -- 3833
end -- 3824
EditFileAction = __TS__Class() -- 3838
EditFileAction.name = "EditFileAction" -- 3838
__TS__ClassExtends(EditFileAction, Node) -- 3838
function EditFileAction.prototype.prep(self, shared) -- 3839
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3839
		local last = shared.history[#shared.history] -- 3840
		if not last then -- 3840
			error( -- 3841
				__TS__New(Error, "no history"), -- 3841
				0 -- 3841
			) -- 3841
		end -- 3841
		emitAgentStartEvent(shared, last) -- 3842
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3843
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3846
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3847
		if __TS__StringTrim(path) == "" then -- 3847
			error( -- 3848
				__TS__New(Error, "missing path"), -- 3848
				0 -- 3848
			) -- 3848
		end -- 3848
		return ____awaiter_resolve(nil, { -- 3848
			path = path, -- 3849
			oldStr = oldStr, -- 3849
			newStr = newStr, -- 3849
			taskId = shared.taskId, -- 3849
			workDir = shared.workingDir -- 3849
		}) -- 3849
	end) -- 3849
end -- 3839
function EditFileAction.prototype.exec(self, input) -- 3852
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3852
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3853
		if not readRes.success then -- 3853
			if input.oldStr ~= "" then -- 3853
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3853
			end -- 3853
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3858
			if not createRes.success then -- 3858
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3858
			end -- 3858
			return ____awaiter_resolve( -- 3858
				nil, -- 3858
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3865
					success = true, -- 3866
					changed = true, -- 3867
					mode = "create", -- 3868
					checkpointId = createRes.checkpointId, -- 3869
					checkpointSeq = createRes.checkpointSeq, -- 3870
					files = {{path = input.path, op = "create"}} -- 3871
				}) -- 3871
			) -- 3871
		end -- 3871
		if input.oldStr == "" then -- 3871
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3871
				return ____awaiter_resolve( -- 3871
					nil, -- 3871
					{ -- 3876
						success = false, -- 3877
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3878
						actualSaved = false, -- 3879
						actualSavedCharacters = 0, -- 3880
						currentFileExists = true, -- 3881
						currentCharacters = #readRes.content, -- 3882
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3883
					} -- 3883
				) -- 3883
			end -- 3883
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3886
			if not overwriteRes.success then -- 3886
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3886
			end -- 3886
			return ____awaiter_resolve( -- 3886
				nil, -- 3886
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3893
					success = true, -- 3894
					changed = true, -- 3895
					mode = "overwrite", -- 3896
					checkpointId = overwriteRes.checkpointId, -- 3897
					checkpointSeq = overwriteRes.checkpointSeq, -- 3898
					files = {{path = input.path, op = "write"}} -- 3899
				}) -- 3899
			) -- 3899
		end -- 3899
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3904
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3905
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3906
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3909
		if occurrences == 0 then -- 3909
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3911
			if not indentTolerant.success then -- 3911
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3911
			end -- 3911
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3915
			if not applyRes.success then -- 3915
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3915
			end -- 3915
			return ____awaiter_resolve( -- 3915
				nil, -- 3915
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3922
					success = true, -- 3923
					changed = true, -- 3924
					mode = "replace_indent_tolerant", -- 3925
					checkpointId = applyRes.checkpointId, -- 3926
					checkpointSeq = applyRes.checkpointSeq, -- 3927
					files = {{path = input.path, op = "write"}} -- 3928
				}) -- 3928
			) -- 3928
		end -- 3928
		if occurrences > 1 then -- 3928
			return ____awaiter_resolve( -- 3928
				nil, -- 3928
				{ -- 3932
					success = false, -- 3932
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3932
				} -- 3932
			) -- 3932
		end -- 3932
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3936
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3937
		if not applyRes.success then -- 3937
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3937
		end -- 3937
		return ____awaiter_resolve( -- 3937
			nil, -- 3937
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3944
				success = true, -- 3945
				changed = true, -- 3946
				mode = "replace", -- 3947
				checkpointId = applyRes.checkpointId, -- 3948
				checkpointSeq = applyRes.checkpointSeq, -- 3949
				files = {{path = input.path, op = "write"}} -- 3950
			}) -- 3950
		) -- 3950
	end) -- 3950
end -- 3852
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3954
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3954
		local last = shared.history[#shared.history] -- 3955
		if last ~= nil then -- 3955
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3957
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3958
			appendToolResultMessage(shared, last) -- 3959
			emitAgentFinishEvent(shared, last) -- 3960
			local result = last.result -- 3961
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3961
				emitAgentEvent(shared, { -- 3966
					type = "checkpoint_created", -- 3967
					sessionId = shared.sessionId, -- 3968
					taskId = shared.taskId, -- 3969
					step = last.step, -- 3970
					tool = last.tool, -- 3971
					checkpointId = result.checkpointId, -- 3972
					checkpointSeq = result.checkpointSeq, -- 3973
					files = result.files -- 3974
				}) -- 3974
			end -- 3974
		end -- 3974
		persistHistoryState(shared) -- 3981
		__TS__Await(maybeCompressHistory(shared)) -- 3982
		persistHistoryState(shared) -- 3983
		return ____awaiter_resolve(nil, "main") -- 3983
	end) -- 3983
end -- 3954
local FetchUrlAction = __TS__Class() -- 3988
FetchUrlAction.name = "FetchUrlAction" -- 3988
__TS__ClassExtends(FetchUrlAction, Node) -- 3988
function FetchUrlAction.prototype.prep(self, shared) -- 3989
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3989
		local last = shared.history[#shared.history] -- 3990
		if not last then -- 3990
			error( -- 3991
				__TS__New(Error, "no history"), -- 3991
				0 -- 3991
			) -- 3991
		end -- 3991
		emitAgentStartEvent(shared, last) -- 3992
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3992
	end) -- 3992
end -- 3989
function FetchUrlAction.prototype.exec(self, input) -- 3996
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3996
		return ____awaiter_resolve( -- 3996
			nil, -- 3996
			executeToolAction(input.shared, input.action) -- 3997
		) -- 3997
	end) -- 3997
end -- 3996
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 4000
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4000
		local last = shared.history[#shared.history] -- 4001
		if last ~= nil then -- 4001
			last.result = execRes -- 4003
			appendToolResultMessage(shared, last) -- 4004
			emitAgentFinishEvent(shared, last) -- 4005
		end -- 4005
		persistHistoryState(shared) -- 4007
		__TS__Await(maybeCompressHistory(shared)) -- 4008
		persistHistoryState(shared) -- 4009
		return ____awaiter_resolve(nil, "main") -- 4009
	end) -- 4009
end -- 4000
local function emitCheckpointEventForAction(shared, action) -- 4014
	local result = action.result -- 4015
	if not result then -- 4015
		return -- 4016
	end -- 4016
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 4016
		emitAgentEvent(shared, { -- 4021
			type = "checkpoint_created", -- 4022
			sessionId = shared.sessionId, -- 4023
			taskId = shared.taskId, -- 4024
			step = action.step, -- 4025
			tool = action.tool, -- 4026
			checkpointId = result.checkpointId, -- 4027
			checkpointSeq = result.checkpointSeq, -- 4028
			files = result.files -- 4029
		}) -- 4029
	end -- 4029
end -- 4014
local function canRunBatchActionInParallel(self, action) -- 4657
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4658
end -- 4657
local function partitionToolCalls(actions) -- 4666
	local batches = {} -- 4667
	do -- 4667
		local i = 0 -- 4668
		while i < #actions do -- 4668
			local action = actions[i + 1] -- 4669
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4670
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4671
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4671
				local ____lastBatch_actions_219 = lastBatch.actions -- 4671
				____lastBatch_actions_219[#____lastBatch_actions_219 + 1] = action -- 4673
			else -- 4673
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4675
			end -- 4675
			i = i + 1 -- 4668
		end -- 4668
	end -- 4668
	return batches -- 4678
end -- 4666
local function completeStoppedToolAction(shared, action) -- 4681
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4682
	if not action.result then -- 4682
		action.result = { -- 4684
			success = false, -- 4684
			message = getCancelledReason(shared) -- 4684
		} -- 4684
	end -- 4684
	appendToolResultMessage(shared, action) -- 4686
	emitAgentFinishEvent(shared, action) -- 4687
	emitCheckpointEventForAction(shared, action) -- 4688
end -- 4681
local BatchToolAction = __TS__Class() -- 4691
BatchToolAction.name = "BatchToolAction" -- 4691
__TS__ClassExtends(BatchToolAction, Node) -- 4691
function BatchToolAction.prototype.prep(self, shared) -- 4692
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4692
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4692
	end) -- 4692
end -- 4692
function BatchToolAction.prototype.exec(self, input) -- 4696
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4696
		local shared = input.shared -- 4697
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4698
		local preExecuted = shared.preExecutedResults -- 4699
		local batches = partitionToolCalls(input.actions) -- 4700
		local parallelBatchCount = #__TS__ArrayFilter( -- 4701
			batches, -- 4701
			function(____, b) return b.isConcurrencySafe end -- 4701
		) -- 4701
		local serialBatchCount = #__TS__ArrayFilter( -- 4702
			batches, -- 4702
			function(____, b) return not b.isConcurrencySafe end -- 4702
		) -- 4702
		AgentUtils.Log( -- 4703
			"Info", -- 4703
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4703
		) -- 4703
		do -- 4703
			local batchIdx = 0 -- 4705
			while batchIdx < #batches do -- 4705
				do -- 4705
					local batch = batches[batchIdx + 1] -- 4706
					if shared.stopToken.stopped then -- 4706
						for ____, action in ipairs(batch.actions) do -- 4708
							completeStoppedToolAction(shared, action) -- 4709
						end -- 4709
						goto __continue773 -- 4711
					end -- 4711
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4711
						local preExecCount = #__TS__ArrayFilter( -- 4715
							batch.actions, -- 4715
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4715
						) -- 4715
						AgentUtils.Log( -- 4716
							"Info", -- 4716
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4716
						) -- 4716
						do -- 4716
							local i = 0 -- 4717
							while i < #batch.actions do -- 4717
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4718
								i = i + 1 -- 4717
							end -- 4717
						end -- 4717
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4720
							batch.actions, -- 4720
							function(____, action) -- 4720
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4720
									if shared.stopToken.stopped then -- 4720
										action.result = { -- 4722
											success = false, -- 4722
											message = getCancelledReason(shared) -- 4722
										} -- 4722
										return ____awaiter_resolve(nil, action) -- 4722
									end -- 4722
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4725
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4726
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4727
									return ____awaiter_resolve(nil, action) -- 4727
								end) -- 4727
							end -- 4720
						))) -- 4720
						do -- 4720
							local i = 0 -- 4730
							while i < #batch.actions do -- 4730
								local action = batch.actions[i + 1] -- 4731
								if not action.result then -- 4731
									action.result = {success = false, message = "tool did not produce a result"} -- 4733
								end -- 4733
								appendToolResultMessage(shared, action) -- 4735
								emitAgentFinishEvent(shared, action) -- 4736
								emitCheckpointEventForAction(shared, action) -- 4737
								i = i + 1 -- 4730
							end -- 4730
						end -- 4730
					else -- 4730
						AgentUtils.Log( -- 4740
							"Info", -- 4740
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4740
						) -- 4740
						do -- 4740
							local i = 0 -- 4741
							while i < #batch.actions do -- 4741
								local action = batch.actions[i + 1] -- 4742
								emitAgentStartEvent(shared, action) -- 4743
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4744
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4745
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4746
								appendToolResultMessage(shared, action) -- 4747
								emitAgentFinishEvent(shared, action) -- 4748
								emitCheckpointEventForAction(shared, action) -- 4749
								persistHistoryState(shared) -- 4750
								if shared.stopToken.stopped then -- 4750
									do -- 4750
										local j = i + 1 -- 4752
										while j < #batch.actions do -- 4752
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4753
											j = j + 1 -- 4752
										end -- 4752
									end -- 4752
									break -- 4755
								end -- 4755
								i = i + 1 -- 4741
							end -- 4741
						end -- 4741
					end -- 4741
				end -- 4741
				::__continue773:: -- 4741
				batchIdx = batchIdx + 1 -- 4705
			end -- 4705
		end -- 4705
		local spawnSeen = spawnedBeforeBatch -- 4760
		local didDelegatedForegroundWork = false -- 4761
		do -- 4761
			local i = 0 -- 4762
			while i < #input.actions do -- 4762
				do -- 4762
					local action = input.actions[i + 1] -- 4763
					if action.tool == "spawn_sub_agent" then -- 4763
						local ____opt_222 = action.result -- 4763
						if (____opt_222 and ____opt_222.success) == true then -- 4763
							spawnSeen = true -- 4765
						end -- 4765
						goto __continue793 -- 4766
					end -- 4766
					if spawnSeen and action.tool ~= "finish" then -- 4766
						didDelegatedForegroundWork = true -- 4769
					end -- 4769
				end -- 4769
				::__continue793:: -- 4769
				i = i + 1 -- 4762
			end -- 4762
		end -- 4762
		if didDelegatedForegroundWork then -- 4762
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4773
		end -- 4773
		persistHistoryState(shared) -- 4775
		return ____awaiter_resolve(nil, input.actions) -- 4775
	end) -- 4775
end -- 4696
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4779
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4779
		shared.pendingToolActions = nil -- 4780
		shared.preExecutedResults = nil -- 4781
		persistHistoryState(shared) -- 4782
		if shared.waitingQuestionnaireId == nil then -- 4782
			__TS__Await(maybeCompressHistory(shared)) -- 4786
			persistHistoryState(shared) -- 4787
		end -- 4787
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4787
	end) -- 4787
end -- 4779
local EndNode = __TS__Class() -- 4793
EndNode.name = "EndNode" -- 4793
__TS__ClassExtends(EndNode, Node) -- 4793
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4794
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4794
		return ____awaiter_resolve(nil, nil) -- 4794
	end) -- 4794
end -- 4794
local CodingAgentFlow = __TS__Class() -- 4799
CodingAgentFlow.name = "CodingAgentFlow" -- 4799
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4799
function CodingAgentFlow.prototype.____constructor(self, role) -- 4800
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4801
	local read = __TS__New(ReadFileAction, 1, 0) -- 4802
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4803
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4804
	local list = __TS__New(ListFilesAction, 1, 0) -- 4805
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4806
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4807
	local build = __TS__New(BuildAction, 1, 0) -- 4808
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4809
	local edit = __TS__New(EditFileAction, 1, 0) -- 4810
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4811
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4812
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4813
	local done = __TS__New(EndNode, 1, 0) -- 4814
	main:on("batch_tools", batch) -- 4816
	main:on("grep_files", search) -- 4817
	main:on("search_dora_api", searchDora) -- 4818
	main:on("glob_files", list) -- 4819
	main:on("fetch_url", fetch) -- 4820
	main:on("execute_command", exec) -- 4821
	if role == "main" then -- 4821
		main:on("read_file", read) -- 4823
		main:on("delete_file", del) -- 4824
		main:on("build", build) -- 4825
		main:on("edit_file", edit) -- 4826
		main:on("list_sub_agents", listSub) -- 4827
		main:on("spawn_sub_agent", spawn) -- 4828
	else -- 4828
		main:on("read_file", read) -- 4830
		main:on("delete_file", del) -- 4831
		main:on("build", build) -- 4832
		main:on("edit_file", edit) -- 4833
	end -- 4833
	main:on("done", done) -- 4835
	search:on("main", main) -- 4837
	searchDora:on("main", main) -- 4838
	list:on("main", main) -- 4839
	listSub:on("main", main) -- 4840
	spawn:on("main", main) -- 4841
	batch:on("main", main) -- 4842
	batch:on("done", done) -- 4843
	read:on("main", main) -- 4844
	del:on("main", main) -- 4845
	build:on("main", main) -- 4846
	edit:on("main", main) -- 4847
	fetch:on("main", main) -- 4848
	exec:on("main", main) -- 4849
	Flow.prototype.____constructor(self, main) -- 4851
end -- 4800
local function runCodingAgentAsync(options) -- 4887
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4887
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4887
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4887
		end -- 4887
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4891
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4892
		if not llmConfigRes.success then -- 4892
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4892
		end -- 4892
		local llmConfig = llmConfigRes.config -- 4898
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4899
		if not taskRes.success then -- 4899
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4899
		end -- 4899
		local compressor = __TS__New(MemoryCompressor, { -- 4906
			compressionTargetThreshold = 0.5, -- 4907
			maxCompressionRounds = 3, -- 4908
			projectDir = options.workDir, -- 4909
			llmConfig = llmConfig, -- 4910
			promptPack = options.promptPack, -- 4911
			scope = options.memoryScope -- 4912
		}) -- 4912
		local persistedSession = compressor:getStorage():readSessionState() -- 4914
		local effectiveUserQuery = normalizedPrompt -- 4915
		if options.resumeConversation == true and __TS__StringTrim(normalizedPrompt) == "" then -- 4915
			do -- 4915
				local i = #persistedSession.messages - 1 -- 4917
				while i >= 0 do -- 4917
					local message = persistedSession.messages[i + 1] -- 4918
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4918
						effectiveUserQuery = message.content -- 4920
						break -- 4921
					end -- 4921
					i = i - 1 -- 4917
				end -- 4917
			end -- 4917
		end -- 4917
		local promptPack = compressor:getPromptPack() -- 4925
		local freshProject = inspectFreshProject(options.workDir) -- 4926
		local freshProjectBuildPending = freshProject.fresh -- 4927
		local freshProjectCodeFile = freshProject.codeFile -- 4928
		local shared = { -- 4930
			sessionId = options.sessionId, -- 4931
			taskId = taskRes.taskId, -- 4932
			role = options.role or "main", -- 4933
			maxSteps = math.max( -- 4934
				1, -- 4934
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4934
			), -- 4934
			llmMaxTry = math.max( -- 4935
				1, -- 4935
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4935
			), -- 4935
			step = math.max( -- 4936
				0, -- 4936
				math.floor(options.initialStep or 0) -- 4936
			), -- 4936
			agentStepCount = math.max( -- 4937
				0, -- 4937
				math.floor(options.initialAgentStepCount or 0) -- 4937
			), -- 4937
			done = false, -- 4938
			stopToken = options.stopToken or ({stopped = false}), -- 4939
			response = "", -- 4940
			userQuery = effectiveUserQuery, -- 4941
			workingDir = options.workDir, -- 4942
			useChineseResponse = options.useChineseResponse == true, -- 4943
			workMode = options.workMode or "code", -- 4944
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4945
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4948
			llmConfig = llmConfig, -- 4949
			onEvent = options.onEvent, -- 4950
			promptPack = promptPack, -- 4951
			history = {}, -- 4952
			messages = persistedSession.messages, -- 4953
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4954
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4955
			memory = {compressor = compressor}, -- 4957
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4961
				projectDir = options.workDir, -- 4963
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4964
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4965
			})}, -- 4965
			spawnSubAgent = options.spawnSubAgent, -- 4971
			listSubAgents = options.listSubAgents, -- 4972
			publishQuestionnaire = options.publishQuestionnaire, -- 4973
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4974
			freshProjectBuildPending = freshProjectBuildPending, -- 4975
			freshProjectCodeFile = freshProjectCodeFile, -- 4976
			hasSpawnedSubAgentThisTask = false, -- 4977
			delegatedForegroundBatches = 0, -- 4978
			tokenUsage = options.initialTokenUsage -- 4979
		} -- 4979
		local ____hasReturned, ____returnValue -- 4979
		local ____try = __TS__AsyncAwaiter(function() -- 4979
			if shared.workMode == "plan" then -- 4979
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4984
				if not planDocuments.success then -- 4984
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4986
					____hasReturned = true -- 4987
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4987
					return -- 4987
				end -- 4987
			end -- 4987
			emitAgentEvent(shared, { -- 4990
				type = "task_started", -- 4991
				sessionId = shared.sessionId, -- 4992
				taskId = shared.taskId, -- 4993
				prompt = shared.userQuery, -- 4994
				workDir = shared.workingDir, -- 4995
				maxSteps = shared.maxSteps, -- 4996
				resumed = options.resumeTask == true -- 4997
			}) -- 4997
			if shared.stopToken.stopped then -- 4997
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 5000
				____hasReturned = true -- 5001
				____returnValue = emitAgentTaskFinishEvent( -- 5001
					shared, -- 5001
					false, -- 5001
					getCancelledReason(shared) -- 5001
				) -- 5001
				return -- 5001
			end -- 5001
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 5003
			local ____temp_224 -- 5004
			if options.resumeConversation == true then -- 5004
				____temp_224 = nil -- 5004
			else -- 5004
				____temp_224 = getPromptCommand(shared.userQuery) -- 5004
			end -- 5004
			local promptCommand = ____temp_224 -- 5004
			if promptCommand == "clear" then -- 5004
				____hasReturned = true -- 5006
				____returnValue = clearSessionHistory(shared) -- 5006
				return -- 5006
			end -- 5006
			if promptCommand == "compact" then -- 5006
				if shared.role == "sub" then -- 5006
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 5010
					____hasReturned = true -- 5011
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 5011
					return -- 5011
				end -- 5011
				____hasReturned = true -- 5019
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 5019
				return -- 5019
			end -- 5019
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 5021
			if shared.stopToken.stopped then -- 5021
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 5023
				____hasReturned = true -- 5024
				____returnValue = emitAgentTaskFinishEvent( -- 5024
					shared, -- 5024
					false, -- 5024
					getCancelledReason(shared) -- 5024
				) -- 5024
				return -- 5024
			end -- 5024
			if options.resumeConversation ~= true then -- 5024
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 5027
				persistHistoryState(shared) -- 5031
			end -- 5031
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 5033
			__TS__Await(flow:run(shared)) -- 5034
			if shared.stopToken.stopped then -- 5034
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 5036
				____hasReturned = true -- 5037
				____returnValue = emitAgentTaskFinishEvent( -- 5037
					shared, -- 5037
					false, -- 5037
					getCancelledReason(shared) -- 5037
				) -- 5037
				return -- 5037
			end -- 5037
			if shared.error then -- 5037
				____hasReturned = true -- 5040
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 5040
				return -- 5040
			end -- 5040
			if shared.waitingQuestionnaireId ~= nil then -- 5040
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 5044
				emitAgentEvent(shared, { -- 5045
					type = "task_waiting_for_user", -- 5046
					sessionId = shared.sessionId, -- 5047
					taskId = shared.taskId, -- 5048
					step = shared.step, -- 5049
					questionnaireId = shared.waitingQuestionnaireId -- 5050
				}) -- 5050
				____hasReturned = true -- 5052
				____returnValue = { -- 5052
					success = true, -- 5053
					taskId = shared.taskId, -- 5054
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 5055
					steps = shared.step, -- 5056
					waitingForUser = true, -- 5057
					questionnaireId = shared.waitingQuestionnaireId -- 5058
				} -- 5058
				return -- 5052
			end -- 5052
			local ____isFinalDecisionTurn_result_227 = isFinalDecisionTurn(shared) -- 5061
			if ____isFinalDecisionTurn_result_227 then -- 5061
				local ____opt_225 = shared.completion -- 5061
				____isFinalDecisionTurn_result_227 = (____opt_225 and ____opt_225.outcome) == "partial" -- 5061
			end -- 5061
			if ____isFinalDecisionTurn_result_227 then -- 5061
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 5062
				____hasReturned = true -- 5063
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 5063
				return -- 5063
			end -- 5063
			Tools.setTaskStatus(shared.taskId, "DONE") -- 5066
			____hasReturned = true -- 5067
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 5067
			return -- 5067
		end) -- 5067
		____try = ____try.catch( -- 5067
			____try, -- 5067
			function(____, e) -- 5067
				return __TS__AsyncAwaiter(function() -- 5067
					____hasReturned = true -- 5070
					____returnValue = finalizeAgentFailure( -- 5070
						shared, -- 5070
						tostring(e) -- 5070
					) -- 5070
					return -- 5070
				end) -- 5070
			end -- 5070
		) -- 5070
		__TS__Await(____try) -- 4982
		if ____hasReturned then -- 4982
			return ____awaiter_resolve(nil, ____returnValue) -- 4982
		end -- 4982
	end) -- 4982
end -- 4887
function ____exports.runCodingAgent(options, callback) -- 5074
	local ____self_228 = runCodingAgentAsync(options) -- 5074
	____self_228["then"]( -- 5074
		____self_228, -- 5074
		function(____, result) return callback(result) end -- 5075
	) -- 5075
end -- 5074
return ____exports -- 5074