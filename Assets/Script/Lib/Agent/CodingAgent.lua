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
function emitAgentEvent(shared, event) -- 437
	if shared.onEvent then -- 437
		do -- 437
			local function ____catch(____error) -- 437
				AgentUtils.Log( -- 442
					"Error", -- 442
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 442
				) -- 442
			end -- 442
			local ____try, ____hasReturned = pcall(function() -- 442
				shared:onEvent(event) -- 440
			end) -- 440
			if not ____try then -- 440
				____catch(____hasReturned) -- 440
			end -- 440
		end -- 440
	end -- 440
end -- 440
function getCancelledReason(shared) -- 602
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 602
		return shared.stopToken.reason -- 603
	end -- 603
	return shared.useChineseResponse and "已取消" or "cancelled" -- 604
end -- 604
function ____exports.normalizePolicyPath(path) -- 666
	return AgentRuntimePolicy.normalizeAgentPath(path) -- 667
end -- 666
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 675
	return AgentRuntimePolicy.isMainAgentMemoryPath(path) -- 676
end -- 675
function toJson(value, emptyAsArray) -- 823
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 824
	if text ~= nil then -- 824
		return text -- 825
	end -- 825
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 826
end -- 826
function truncateText(text, maxLen) -- 829
	if #text <= maxLen then -- 829
		return text -- 830
	end -- 830
	local nextPos = utf8.offset(text, maxLen + 1) -- 831
	if nextPos == nil then -- 831
		return text -- 832
	end -- 832
	return string.sub(text, 1, nextPos - 1) .. "..." -- 833
end -- 833
function utf8TakeHead(text, maxChars) -- 836
	if maxChars <= 0 or text == "" then -- 836
		return "" -- 837
	end -- 837
	local nextPos = utf8.offset(text, maxChars + 1) -- 838
	if nextPos == nil then -- 838
		return text -- 839
	end -- 839
	return string.sub(text, 1, nextPos - 1) -- 840
end -- 840
function utf8TakeTail(text, maxChars) -- 843
	if maxChars <= 0 or text == "" then -- 843
		return "" -- 844
	end -- 844
	local charLength = utf8.len(text) -- 845
	if charLength == nil or charLength <= maxChars then -- 845
		return text -- 846
	end -- 846
	local startPos = utf8.offset( -- 847
		text, -- 847
		math.max(1, charLength - maxChars + 1) -- 847
	) -- 847
	if startPos == nil then -- 847
		return text -- 848
	end -- 848
	return string.sub(text, startPos) -- 849
end -- 849
function truncateHistoryText(text, maxChars, label) -- 852
	if maxChars <= 0 or text == "" then -- 852
		return "" -- 853
	end -- 853
	if #text <= maxChars then -- 853
		return text -- 854
	end -- 854
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 855
	local remaining = math.max(0, maxChars - #marker) -- 856
	local headChars = math.floor(remaining * 0.6) -- 857
	local tailChars = remaining - headChars -- 858
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 859
end -- 859
function getReplyLanguageDirective(shared) -- 862
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 863
end -- 863
function replacePromptVars(template, vars) -- 868
	local output = template -- 869
	for key in pairs(vars) do -- 870
		output = table.concat( -- 871
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 871
			vars[key] or "" or "," -- 871
		) -- 871
	end -- 871
	return output -- 873
end -- 873
function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 876
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 892
	local contentLines = __TS__StringSplit(content, "\n") -- 893
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 894
	if #content <= maxChars and availableSourceLines <= maxLines then -- 894
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 896
	end -- 896
	local contentBudget = math.max(0, maxChars - 240) -- 907
	local candidateLines = math.min(availableSourceLines, maxLines) -- 908
	local retainedLines = {} -- 909
	local retainedChars = 0 -- 910
	do -- 910
		local i = 0 -- 911
		while i < candidateLines do -- 911
			local line = contentLines[i + 1] -- 912
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 913
			if nextChars > contentBudget then -- 913
				break -- 914
			end -- 914
			retainedLines[#retainedLines + 1] = line -- 915
			retainedChars = nextChars -- 916
			i = i + 1 -- 911
		end -- 911
	end -- 911
	local retainedEndLine = startLine + #retainedLines - 1 -- 919
	local partialLine -- 920
	local retainedContent = table.concat(retainedLines, "\n") -- 921
	if #retainedLines == 0 and candidateLines > 0 then -- 921
		partialLine = startLine -- 923
		retainedEndLine = startLine - 1 -- 924
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 925
	end -- 925
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 927
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 928
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 933
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 936
	return { -- 937
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 938
		truncated = true, -- 939
		retainedStartLine = startLine, -- 940
		retainedEndLine = retainedEndLine, -- 941
		nextStartLine = nextStartLine, -- 942
		partialLine = partialLine -- 943
	} -- 943
end -- 943
function sanitizeReadResultForHistory(tool, result) -- 959
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 959
		return result -- 961
	end -- 961
	local clone = {} -- 963
	for key in pairs(result) do -- 964
		clone[key] = result[key] -- 965
	end -- 965
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 967
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 968
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 969
	local limited = limitReadContentForHistory( -- 970
		result.content, -- 971
		startLine, -- 972
		endLine, -- 973
		totalLines, -- 974
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 975
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 976
		"read_file history" -- 977
	) -- 977
	clone.content = limited.content -- 979
	if limited.truncated then -- 979
		clone.historyContentTruncated = true -- 981
		clone.historyRetainedStartLine = limited.retainedStartLine -- 982
		clone.historyRetainedEndLine = limited.retainedEndLine -- 983
		if limited.nextStartLine ~= nil then -- 983
			clone.historyNextStartLine = limited.nextStartLine -- 984
		end -- 984
		if limited.partialLine ~= nil then -- 984
			clone.historyPartialLine = limited.partialLine -- 985
		end -- 985
	end -- 985
	return clone -- 987
end -- 987
function sanitizeSearchMatchesForHistory(items, maxItems) -- 990
	local shown = math.min(#items, maxItems) -- 994
	local out = {} -- 995
	do -- 995
		local i = 0 -- 996
		while i < shown do -- 996
			local row = items[i + 1] -- 997
			out[#out + 1] = { -- 998
				file = row.file, -- 999
				line = row.line, -- 1000
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1001
			} -- 1001
			i = i + 1 -- 996
		end -- 996
	end -- 996
	return out -- 1006
end -- 1006
function sanitizeSearchResultForHistory(tool, result) -- 1009
	if result.success ~= true or not isArray(result.results) then -- 1009
		return result -- 1013
	end -- 1013
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1013
		return result -- 1014
	end -- 1014
	local clone = {} -- 1015
	for key in pairs(result) do -- 1016
		clone[key] = result[key] -- 1017
	end -- 1017
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 1019
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1020
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1020
		local grouped = result.groupedResults -- 1025
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 1026
		local sanitizedGroups = {} -- 1027
		do -- 1027
			local i = 0 -- 1028
			while i < shown do -- 1028
				local row = grouped[i + 1] -- 1029
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1030
					file = row.file, -- 1031
					totalMatches = row.totalMatches, -- 1032
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1033
				} -- 1033
				i = i + 1 -- 1028
			end -- 1028
		end -- 1028
		clone.groupedResults = sanitizedGroups -- 1038
	end -- 1038
	return clone -- 1040
end -- 1040
function sanitizeListFilesResultForHistory(result) -- 1043
	if result.success ~= true or not isArray(result.files) then -- 1043
		return result -- 1044
	end -- 1044
	local clone = {} -- 1045
	for key in pairs(result) do -- 1046
		clone[key] = result[key] -- 1047
	end -- 1047
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 1049
	return clone -- 1050
end -- 1050
function sanitizeBuildResultForHistory(result) -- 1053
	if not isArray(result.messages) then -- 1053
		return result -- 1054
	end -- 1054
	local clone = {} -- 1055
	for key in pairs(result) do -- 1056
		clone[key] = result[key] -- 1057
	end -- 1057
	local messages = result.messages -- 1059
	local ordered = __TS__ArraySort( -- 1060
		__TS__ArraySlice(messages), -- 1060
		function(____, a, b) -- 1060
			local aFailed = a.success ~= true -- 1061
			local bFailed = b.success ~= true -- 1062
			if aFailed == bFailed then -- 1062
				return 0 -- 1063
			end -- 1063
			return aFailed and -1 or 1 -- 1064
		end -- 1060
	) -- 1060
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1066
	local sanitized = {} -- 1067
	do -- 1067
		local i = 0 -- 1068
		while i < shown do -- 1068
			local item = ordered[i + 1] -- 1069
			local next = {} -- 1070
			for key in pairs(item) do -- 1071
				local value = item[key] -- 1072
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1073
			end -- 1073
			sanitized[#sanitized + 1] = next -- 1077
			i = i + 1 -- 1068
		end -- 1068
	end -- 1068
	clone.messages = sanitized -- 1079
	if #ordered > shown then -- 1079
		clone.truncatedMessages = #ordered - shown -- 1081
	end -- 1081
	return clone -- 1083
end -- 1083
function projectEditResultForLLM(result) -- 1101
	if result.success ~= true then -- 1101
		local failed = {} -- 1103
		for key in pairs(result) do -- 1104
			local value = result[key] -- 1105
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 1106
		end -- 1106
		return failed -- 1110
	end -- 1110
	local projected = {} -- 1112
	local scalarKeys = { -- 1113
		"success", -- 1114
		"changed", -- 1114
		"mode", -- 1114
		"checkpointId", -- 1114
		"checkpointSeq", -- 1114
		"actualSaved", -- 1115
		"actualSavedCharacters", -- 1115
		"currentFileExists", -- 1115
		"currentCharacters", -- 1115
		"currentState" -- 1115
	} -- 1115
	do -- 1115
		local i = 0 -- 1117
		while i < #scalarKeys do -- 1117
			local key = scalarKeys[i + 1] -- 1118
			if result[key] ~= nil then -- 1118
				projected[key] = result[key] -- 1119
			end -- 1119
			i = i + 1 -- 1117
		end -- 1117
	end -- 1117
	if isArray(result.files) then -- 1117
		projected.files = result.files -- 1121
	end -- 1121
	if type(result.message) == "string" then -- 1121
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1123
	end -- 1123
	if type(result.guidance) == "string" then -- 1123
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1130
	end -- 1130
	if isArray(result.fileContext) then -- 1130
		local summaries = {} -- 1137
		do -- 1137
			local i = 0 -- 1138
			while i < #result.fileContext do -- 1138
				do -- 1138
					local item = result.fileContext[i + 1] -- 1139
					if not isRecord(item) or isArray(item) then -- 1139
						goto __continue157 -- 1140
					end -- 1140
					local summary = {} -- 1141
					local keys = { -- 1142
						"path", -- 1143
						"op", -- 1143
						"beforeExists", -- 1143
						"afterExists", -- 1143
						"beforeBytes", -- 1143
						"afterBytes", -- 1143
						"lineCount", -- 1144
						"contentTruncated", -- 1144
						"fileListTruncated" -- 1144
					} -- 1144
					do -- 1144
						local j = 0 -- 1146
						while j < #keys do -- 1146
							local key = keys[j + 1] -- 1147
							if item[key] ~= nil then -- 1147
								summary[key] = item[key] -- 1148
							end -- 1148
							j = j + 1 -- 1146
						end -- 1146
					end -- 1146
					summaries[#summaries + 1] = summary -- 1150
				end -- 1150
				::__continue157:: -- 1150
				i = i + 1 -- 1138
			end -- 1138
		end -- 1138
		if #summaries > 0 then -- 1138
			projected.fileSummary = summaries -- 1152
		end -- 1152
	end -- 1152
	if type(result.truncatedFileContextItems) == "number" then -- 1152
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1155
	end -- 1155
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1157
	return projected -- 1158
end -- 1158
function projectBuildResultForLLM(result) -- 1161
	if not isArray(result.messages) then -- 1161
		return result -- 1162
	end -- 1162
	local projected = {} -- 1163
	for key in pairs(result) do -- 1164
		if key ~= "messages" then -- 1164
			projected[key] = result[key] -- 1165
		end -- 1165
	end -- 1165
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1167
	local shown = math.min(#result.messages, maxMessages) -- 1168
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1169
	if #result.messages > shown then -- 1169
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1171
	end -- 1171
	return projected -- 1173
end -- 1173
function projectCommandResultForLLM(result) -- 1176
	local projected = {} -- 1177
	for key in pairs(result) do -- 1178
		local value = result[key] -- 1179
		if key == "output" and type(value) == "string" then -- 1179
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1181
		elseif key == "message" and type(value) == "string" then -- 1181
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1187
		else -- 1187
			projected[key] = value -- 1193
		end -- 1193
	end -- 1193
	return projected -- 1196
end -- 1196
function projectToolResultContentForLLM(tool, content) -- 1199
	local decoded = AgentUtils.safeJsonDecode(content) -- 1200
	if not isRecord(decoded) or isArray(decoded) then -- 1200
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1202
	end -- 1202
	local projected = decoded -- 1208
	if tool == "edit_file" or tool == "delete_file" then -- 1208
		projected = projectEditResultForLLM(decoded) -- 1210
	elseif tool == "build" then -- 1210
		projected = projectBuildResultForLLM(decoded) -- 1212
	elseif tool == "execute_command" then -- 1212
		projected = projectCommandResultForLLM(decoded) -- 1214
	end -- 1214
	local encoded = toJson(projected, false) -- 1216
	if tool == "read_file" then -- 1216
		return encoded -- 1219
	end -- 1219
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1219
		return encoded -- 1220
	end -- 1220
	local fallback = { -- 1221
		success = projected.success, -- 1222
		llmHistoryTruncated = true, -- 1223
		originalChars = #encoded, -- 1224
		preview = truncateHistoryText( -- 1225
			encoded, -- 1226
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1227
			tool .. " result" -- 1228
		) -- 1228
	} -- 1228
	return toJson(fallback, false) -- 1231
end -- 1231
function projectMessagesForLLMContext(messages) -- 1234
	local projected = {} -- 1238
	do -- 1238
		local i = 0 -- 1239
		while i < #messages do -- 1239
			local message = messages[i + 1] -- 1240
			local next = __TS__ObjectAssign({}, message) -- 1241
			if message.role == "tool" and type(message.content) == "string" then -- 1241
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1243
			end -- 1243
			projected[#projected + 1] = next -- 1245
			i = i + 1 -- 1239
		end -- 1239
	end -- 1239
	return projected -- 1247
end -- 1247
function ____exports.getDecisionDisabledAgentTools(shared) -- 1275
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1279
end -- 1275
function getDecisionToolDefinitions(shared) -- 1282
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1283
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1284
	local base = shared.promptPack.toolDefinitionsDetailed -- 1287
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1288
	if usesDefaultToolPrompts then -- 1288
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1291
			shared.role, -- 1291
			{ -- 1291
				includeFinish = true, -- 1292
				includeXmlRules = true, -- 1293
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1294
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1295
				workMode = shared.workMode -- 1296
			} -- 1296
		) -- 1296
		return replacePromptVars(definitions, params) -- 1298
	end -- 1298
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1300
	if (shared and shared.decisionMode) ~= "xml" then -- 1300
		return withRole -- 1305
	end -- 1305
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1307
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1308
end -- 1308
function isToolAllowedForRole(shared, tool) -- 1322
	return __TS__ArrayIndexOf( -- 1323
		AgentToolRegistry.getAllowedToolsForRole( -- 1323
			shared.role, -- 1323
			{ -- 1323
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1324
				workMode = shared.workMode -- 1325
			} -- 1325
		), -- 1325
		tool -- 1326
	) >= 0 -- 1326
end -- 1326
function getFinishMessage(params, fallback) -- 1754
	if fallback == nil then -- 1754
		fallback = "" -- 1754
	end -- 1754
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1754
		return __TS__StringTrim(params.message) -- 1756
	end -- 1756
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1756
		return __TS__StringTrim(params.response) -- 1759
	end -- 1759
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1759
		return __TS__StringTrim(params.summary) -- 1762
	end -- 1762
	return __TS__StringTrim(fallback) -- 1764
end -- 1764
function getCompletionReport(params) -- 1767
	return AgentUtils.normalizeAgentCompletionReport(params) -- 1768
end -- 1768
function persistHistoryState(shared) -- 1771
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1772
end -- 1772
function getActiveConversationMessages(shared) -- 1779
	local activeMessages = {} -- 1780
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1780
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1787
	end -- 1787
	do -- 1787
		local i = shared.lastConsolidatedIndex -- 1791
		while i < #shared.messages do -- 1791
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1792
			i = i + 1 -- 1791
		end -- 1791
	end -- 1791
	return activeMessages -- 1794
end -- 1794
function getActiveRealMessageCount(shared) -- 1797
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1798
end -- 1798
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1801
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1807
	local previousActiveStart = shared.lastConsolidatedIndex -- 1808
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1809
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1810
	if type(carryMessageIndex) == "number" then -- 1810
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1810
		else -- 1810
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1818
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1821
		end -- 1821
	else -- 1821
		shared.carryMessageIndex = nil -- 1826
	end -- 1826
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1826
		shared.carryMessageIndex = nil -- 1836
	end -- 1836
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1844
	shared.resumeCheckpointPending = true -- 1845
	shared.resumeRequiredTool = nil -- 1846
	shared.resumeNarrowReadMode = true -- 1847
	if shared.unbuiltEdits == true then -- 1847
		shared.resumeRequiredTool = "build" -- 1855
	end -- 1855
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1864
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1864
		local marker = "**Next tool**:" -- 1875
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1876
		if markerIndex >= 0 then -- 1876
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1878
			local toolNames = { -- 1879
				"read_file", -- 1880
				"edit_file", -- 1880
				"delete_file", -- 1880
				"grep_files", -- 1880
				"search_dora_api", -- 1880
				"glob_files", -- 1881
				"build", -- 1881
				"fetch_url", -- 1881
				"execute_command", -- 1881
				"list_sub_agents", -- 1881
				"spawn_sub_agent", -- 1882
				"finish" -- 1882
			} -- 1882
			do -- 1882
				local i = 0 -- 1884
				while i < #toolNames do -- 1884
					local tool = toolNames[i + 1] -- 1885
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1885
						shared.resumeRequiredTool = tool -- 1887
						break -- 1888
					end -- 1888
					i = i + 1 -- 1884
				end -- 1884
			end -- 1884
		end -- 1884
	end -- 1884
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1884
		shared.resumeRequiredTool = nil -- 1894
	end -- 1894
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1894
		shared.resumeRequiredTool = nil -- 1897
	end -- 1897
end -- 1897
function ensureToolCallId(toolCallId) -- 1912
	if toolCallId and toolCallId ~= "" then -- 1912
		return toolCallId -- 1913
	end -- 1913
	return AgentUtils.createLocalToolCallId() -- 1914
end -- 1914
function hasXMLParam(params, name) -- 1947
	return params[name] ~= nil -- 1948
end -- 1948
function inferToolNameFromXMLParams(params) -- 1951
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1951
		return "edit_file" -- 1953
	end -- 1953
	if hasXMLParam(params, "target_file") then -- 1953
		return "delete_file" -- 1956
	end -- 1956
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1956
		if hasXMLParam(params, "path") then -- 1956
			return "read_file" -- 1959
		end -- 1959
		return nil -- 1960
	end -- 1960
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1960
		if hasXMLParam(params, "pattern") then -- 1960
			return "search_dora_api" -- 1963
		end -- 1963
		return nil -- 1964
	end -- 1964
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1964
		if hasXMLParam(params, "pattern") then -- 1964
			return "grep_files" -- 1967
		end -- 1967
		return nil -- 1968
	end -- 1968
	if hasXMLParam(params, "globs") then -- 1968
		if hasXMLParam(params, "pattern") then -- 1968
			return "grep_files" -- 1971
		end -- 1971
		return "glob_files" -- 1972
	end -- 1972
	if hasXMLParam(params, "maxEntries") then -- 1972
		return "glob_files" -- 1975
	end -- 1975
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1975
		return "finish" -- 1978
	end -- 1978
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1978
		return "spawn_sub_agent" -- 1981
	end -- 1981
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1981
		return "list_sub_agents" -- 1984
	end -- 1984
	return nil -- 1986
end -- 1986
function parseDSMLAttribute(source, offset, name) -- 1989
	local attrOpen = name .. "=\"" -- 1990
	local attrStart = (string.find( -- 1991
		source, -- 1991
		attrOpen, -- 1991
		math.max(offset + 1, 1), -- 1991
		true -- 1991
	) or 0) - 1 -- 1991
	if attrStart < 0 then -- 1991
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1992
	end -- 1992
	local valueStart = attrStart + #attrOpen -- 1993
	local valueEnd = (string.find( -- 1994
		source, -- 1994
		"\"", -- 1994
		math.max(valueStart + 1, 1), -- 1994
		true -- 1994
	) or 0) - 1 -- 1994
	if valueEnd < 0 then -- 1994
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1995
	end -- 1995
	return { -- 1996
		success = true, -- 1997
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1998
		next = valueEnd + 1 -- 1999
	} -- 1999
end -- 1999
function extractDSMLReason(text, invokeStart, tool) -- 2003
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2004
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2005
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2005
		return before -- 2008
	end -- 2008
	if tool == "finish" then -- 2008
		return "" -- 2009
	end -- 2009
	return "Converted provider-native tool call syntax to XML." -- 2010
end -- 2010
function parseDSMLToolCallObjectFromText(text) -- 2013
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2014
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2015
	if invokeStart < 0 then -- 2015
		return {success = false, message = "missing DSML invoke"} -- 2016
	end -- 2016
	local nameStart = invokeStart + #invokeOpen -- 2017
	local nameEnd = (string.find( -- 2018
		text, -- 2018
		"\"", -- 2018
		math.max(nameStart + 1, 1), -- 2018
		true -- 2018
	) or 0) - 1 -- 2018
	if nameEnd < 0 then -- 2018
		return {success = false, message = "unterminated DSML invoke name"} -- 2019
	end -- 2019
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2020
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2020
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2022
	end -- 2022
	local invokeOpenEnd = (string.find( -- 2024
		text, -- 2024
		">", -- 2024
		math.max(nameEnd + 1, 1), -- 2024
		true -- 2024
	) or 0) - 1 -- 2024
	if invokeOpenEnd < 0 then -- 2024
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2025
	end -- 2025
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2026
	local invokeEnd = (string.find( -- 2027
		text, -- 2027
		invokeClose, -- 2027
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2027
		true -- 2027
	) or 0) - 1 -- 2027
	if invokeEnd < 0 then -- 2027
		return {success = false, message = "missing DSML invoke close tag"} -- 2028
	end -- 2028
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2030
	local params = {} -- 2031
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2032
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2033
	local pos = 0 -- 2034
	while pos < #body do -- 2034
		local start = (string.find( -- 2036
			body, -- 2036
			paramOpen, -- 2036
			math.max(pos + 1, 1), -- 2036
			true -- 2036
		) or 0) - 1 -- 2036
		if start < 0 then -- 2036
			break -- 2037
		end -- 2037
		local openEnd = (string.find( -- 2038
			body, -- 2038
			">", -- 2038
			math.max(start + #paramOpen + 1, 1), -- 2038
			true -- 2038
		) or 0) - 1 -- 2038
		if openEnd < 0 then -- 2038
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2039
		end -- 2039
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2040
		if not name.success then -- 2040
			return name -- 2041
		end -- 2041
		local close = (string.find( -- 2042
			body, -- 2042
			paramClose, -- 2042
			math.max(openEnd + 1 + 1, 1), -- 2042
			true -- 2042
		) or 0) - 1 -- 2042
		if close < 0 then -- 2042
			return {success = false, message = "missing DSML parameter close tag"} -- 2043
		end -- 2043
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2044
		pos = close + #paramClose -- 2045
	end -- 2045
	return { -- 2047
		success = true, -- 2048
		obj = { -- 2049
			tool = toolName, -- 2050
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2051
			params = params -- 2052
		} -- 2052
	} -- 2052
end -- 2052
function parseXMLToolCallObjectFromText(text) -- 2057
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2058
	local rawObj -- 2059
	if children.success then -- 2059
		rawObj = children.obj -- 2061
	else -- 2061
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2063
		if dsml.success then -- 2063
			return dsml -- 2064
		end -- 2064
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2065
		local paramsCloseToken = "</params>" -- 2066
		if toolStart >= 0 then -- 2066
			local paramsClose = (string.find( -- 2068
				text, -- 2068
				paramsCloseToken, -- 2068
				math.max(toolStart + 1, 1), -- 2068
				true -- 2068
			) or 0) - 1 -- 2068
			if paramsClose >= toolStart then -- 2068
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2070
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2071
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2071
					rawObj = bare.obj -- 2073
				end -- 2073
			end -- 2073
		end -- 2073
		if rawObj == nil then -- 2073
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2078
			if paramsOpen < 0 then -- 2078
				return children -- 2079
			end -- 2079
			local paramsCloseOnly = (string.find( -- 2080
				text, -- 2080
				paramsCloseToken, -- 2080
				math.max(paramsOpen + 1, 1), -- 2080
				true -- 2080
			) or 0) - 1 -- 2080
			if paramsCloseOnly < paramsOpen then -- 2080
				return children -- 2081
			end -- 2081
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2082
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2083
			if not paramsOnly.success then -- 2083
				return children -- 2084
			end -- 2084
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2085
			if inferredTool == nil then -- 2085
				return children -- 2086
			end -- 2086
			local ____temp_50 -- 2091
			if inferredTool == "finish" then -- 2091
				____temp_50 = nil -- 2091
			else -- 2091
				____temp_50 = "Inferred tool from XML params." -- 2091
			end -- 2091
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2087
		end -- 2087
	end -- 2087
	if rawObj == nil then -- 2087
		return children -- 2097
	end -- 2097
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2098
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2099
	if not params.success then -- 2099
		return {success = false, message = params.message} -- 2103
	end -- 2103
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2105
end -- 2105
function parseDecisionObject(rawObj) -- 2201
	if type(rawObj.tool) ~= "string" then -- 2201
		return {success = false, message = "missing tool"} -- 2202
	end -- 2202
	local tool = rawObj.tool -- 2203
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2203
		return {success = false, message = "unknown tool: " .. tool} -- 2205
	end -- 2205
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2207
	if tool ~= "finish" and (not reason or reason == "") then -- 2207
		return {success = false, message = tool .. " requires top-level reason"} -- 2211
	end -- 2211
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2213
	return {success = true, tool = tool, params = params, reason = reason} -- 2214
end -- 2214
function getDecisionPath(params) -- 2336
	if type(params.path) == "string" then -- 2336
		return __TS__StringTrim(params.path) -- 2337
	end -- 2337
	if type(params.target_file) == "string" then -- 2337
		return __TS__StringTrim(params.target_file) -- 2338
	end -- 2338
	return "" -- 2339
end -- 2339
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2342
	if enforceFinalTurn == nil then -- 2342
		enforceFinalTurn = false -- 2346
	end -- 2346
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2346
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2349
	end -- 2349
	if not isToolAllowedForRole(shared, tool) then -- 2349
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2352
	end -- 2352
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2352
		local path = getDecisionPath(params) -- 2355
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2355
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2357
		end -- 2357
	end -- 2357
	if tool == "delete_file" then -- 2357
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2361
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2361
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2363
		end -- 2363
	end -- 2363
	return {success = true} -- 2366
end -- 2366
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2369
	local num = __TS__Number(value) -- 2370
	if not __TS__NumberIsFinite(num) then -- 2370
		num = fallback -- 2371
	end -- 2371
	num = math.floor(num) -- 2372
	if num < minValue then -- 2372
		num = minValue -- 2373
	end -- 2373
	if maxValue ~= nil and num > maxValue then -- 2373
		num = maxValue -- 2374
	end -- 2374
	return num -- 2375
end -- 2375
function parseReadLineParam(value, fallback, paramName) -- 2378
	local num = __TS__Number(value) -- 2383
	if not __TS__NumberIsFinite(num) then -- 2383
		num = fallback -- 2384
	end -- 2384
	num = math.floor(num) -- 2385
	if num == 0 then -- 2385
		return {success = false, message = paramName .. " cannot be 0"} -- 2387
	end -- 2387
	return {success = true, value = num} -- 2389
end -- 2389
function validateDecision(tool, params) -- 2392
	if tool == "finish" then -- 2392
		local message = getFinishMessage(params) -- 2397
		if message == "" then -- 2397
			return {success = false, message = "finish requires params.message"} -- 2398
		end -- 2398
		params.message = message -- 2399
		local completion = getCompletionReport(params) -- 2400
		params.outcome = completion.outcome -- 2401
		params.validation = completion.validation -- 2402
		params.knownIssues = completion.knownIssues -- 2403
		params.assumptions = completion.assumptions -- 2404
		params.learningCandidates = completion.learningCandidates -- 2405
		return {success = true, params = params} -- 2406
	end -- 2406
	if tool == "ask_user" then -- 2406
		local normalized = normalizeQuestionnaire(params) -- 2410
		if not normalized.success then -- 2410
			return normalized -- 2411
		end -- 2411
		return {success = true, params = normalized.schema} -- 2412
	end -- 2412
	if tool == "read_file" then -- 2412
		local path = getDecisionPath(params) -- 2416
		if path == "" then -- 2416
			return {success = false, message = "read_file requires path"} -- 2417
		end -- 2417
		params.path = path -- 2418
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2419
		if not startLineRes.success then -- 2419
			return startLineRes -- 2420
		end -- 2420
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2421
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2422
		if not endLineRes.success then -- 2422
			return endLineRes -- 2423
		end -- 2423
		params.startLine = startLineRes.value -- 2424
		params.endLine = endLineRes.value -- 2425
		return {success = true, params = params} -- 2426
	end -- 2426
	if tool == "edit_file" then -- 2426
		local path = getDecisionPath(params) -- 2430
		if path == "" then -- 2430
			return {success = false, message = "edit_file requires path"} -- 2431
		end -- 2431
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2432
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2433
		params.path = path -- 2434
		params.old_str = oldStr -- 2435
		params.new_str = newStr -- 2436
		return {success = true, params = params} -- 2437
	end -- 2437
	if tool == "delete_file" then -- 2437
		local targetFile = getDecisionPath(params) -- 2441
		if targetFile == "" then -- 2441
			return {success = false, message = "delete_file requires target_file"} -- 2442
		end -- 2442
		params.target_file = targetFile -- 2443
		return {success = true, params = params} -- 2444
	end -- 2444
	if tool == "grep_files" then -- 2444
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2448
		if pattern == "" then -- 2448
			return {success = false, message = "grep_files requires pattern"} -- 2449
		end -- 2449
		params.pattern = pattern -- 2450
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2451
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2452
		return {success = true, params = params} -- 2453
	end -- 2453
	if tool == "search_dora_api" then -- 2453
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2457
		if pattern == "" then -- 2457
			return {success = false, message = "search_dora_api requires pattern"} -- 2458
		end -- 2458
		params.pattern = pattern -- 2459
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2460
		return {success = true, params = params} -- 2461
	end -- 2461
	if tool == "glob_files" then -- 2461
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2465
		return {success = true, params = params} -- 2466
	end -- 2466
	if tool == "build" then -- 2466
		local path = getDecisionPath(params) -- 2470
		if path ~= "" then -- 2470
			params.path = path -- 2472
		end -- 2472
		return {success = true, params = params} -- 2474
	end -- 2474
	if tool == "list_sub_agents" then -- 2474
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2478
		if status ~= "" then -- 2478
			params.status = status -- 2480
		end -- 2480
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2482
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2483
		if type(params.query) == "string" then -- 2483
			params.query = __TS__StringTrim(params.query) -- 2485
		end -- 2485
		return {success = true, params = params} -- 2487
	end -- 2487
	if tool == "spawn_sub_agent" then -- 2487
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2491
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2492
		if prompt == "" then -- 2492
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2493
		end -- 2493
		if title == "" then -- 2493
			return {success = false, message = "spawn_sub_agent requires title"} -- 2494
		end -- 2494
		params.prompt = prompt -- 2495
		params.title = title -- 2496
		if type(params.expectedOutput) == "string" then -- 2496
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2498
		end -- 2498
		if isArray(params.filesHint) then -- 2498
			params.filesHint = __TS__ArrayMap( -- 2501
				__TS__ArrayFilter( -- 2501
					params.filesHint, -- 2501
					function(____, item) return type(item) == "string" end -- 2502
				), -- 2502
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2503
			) -- 2503
		end -- 2503
		return {success = true, params = params} -- 2505
	end -- 2505
	return {success = true, params = params} -- 2508
end -- 2508
function validateCompletionForRole(role, tool, params) -- 2511
	if role ~= "sub" or tool ~= "finish" then -- 2511
		return {success = true} -- 2516
	end -- 2516
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2516
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2518
	end -- 2518
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2520
	do -- 2520
		local i = 0 -- 2521
		while i < #requiredArrays do -- 2521
			local name = requiredArrays[i + 1] -- 2522
			if not isArray(params[name]) then -- 2522
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2524
			end -- 2524
			i = i + 1 -- 2521
		end -- 2521
	end -- 2521
	return {success = true} -- 2527
end -- 2527
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2530
	if includeToolDefinitions == nil then -- 2530
		includeToolDefinitions = false -- 2530
	end -- 2530
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2531
	local sections = { -- 2534
		shared.promptPack.agentIdentityPrompt, -- 2535
		rolePrompt, -- 2536
		getReplyLanguageDirective(shared) -- 2537
	} -- 2537
	if shared.role == "main" then -- 2537
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2540
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2541
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2541
			sections[#sections + 1] = table.concat( -- 2543
				{ -- 2543
					"# Current Living Development Plan", -- 2544
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2545
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2545
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2546
						12000 -- 2546
					), -- 2546
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2546
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2547
						12000 -- 2547
					) -- 2547
				}, -- 2547
				"\n\n" -- 2548
			) -- 2548
		end -- 2548
	end -- 2548
	if shared.decisionMode == "tool_calling" then -- 2548
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2552
	end -- 2552
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2554
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2555
	if memoryContext ~= "" then -- 2555
		sections[#sections + 1] = memoryContext -- 2557
	end -- 2557
	local skillsSection = buildSkillsSection(shared) -- 2559
	if skillsSection ~= "" then -- 2559
		sections[#sections + 1] = skillsSection -- 2561
	end -- 2561
	if includeToolDefinitions then -- 2561
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2564
		if shared.decisionMode == "xml" then -- 2564
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2566
		end -- 2566
	end -- 2566
	return table.concat(sections, "\n\n") -- 2569
end -- 2569
function buildSkillsSection(shared) -- 2572
	local ____opt_69 = shared.skills -- 2572
	if not (____opt_69 and ____opt_69.loader) then -- 2572
		return "" -- 2574
	end -- 2574
	return shared.skills.loader:buildSkillsPromptSection() -- 2576
end -- 2576
function sanitizeMessagesForLLMInput(messages) -- 2579
	local sanitized = {} -- 2580
	local droppedAssistantToolCalls = 0 -- 2581
	local droppedToolResults = 0 -- 2582
	do -- 2582
		local i = 0 -- 2583
		while i < #messages do -- 2583
			do -- 2583
				local message = messages[i + 1] -- 2584
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2584
					local requiredIds = {} -- 2586
					do -- 2586
						local j = 0 -- 2587
						while j < #message.tool_calls do -- 2587
							local toolCall = message.tool_calls[j + 1] -- 2588
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2589
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2589
								requiredIds[#requiredIds + 1] = id -- 2591
							end -- 2591
							j = j + 1 -- 2587
						end -- 2587
					end -- 2587
					if #requiredIds == 0 then -- 2587
						sanitized[#sanitized + 1] = message -- 2595
						goto __continue446 -- 2596
					end -- 2596
					local matchedIds = {} -- 2598
					local matchedTools = {} -- 2599
					local j = i + 1 -- 2600
					while j < #messages do -- 2600
						local toolMessage = messages[j + 1] -- 2602
						if toolMessage.role ~= "tool" then -- 2602
							break -- 2603
						end -- 2603
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2604
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2604
							matchedIds[toolCallId] = true -- 2606
							matchedTools[#matchedTools + 1] = toolMessage -- 2607
						else -- 2607
							droppedToolResults = droppedToolResults + 1 -- 2609
						end -- 2609
						j = j + 1 -- 2611
					end -- 2611
					local complete = true -- 2613
					do -- 2613
						local j = 0 -- 2614
						while j < #requiredIds do -- 2614
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2614
								complete = false -- 2616
								break -- 2617
							end -- 2617
							j = j + 1 -- 2614
						end -- 2614
					end -- 2614
					if complete then -- 2614
						__TS__ArrayPush( -- 2621
							sanitized, -- 2621
							message, -- 2621
							table.unpack(matchedTools) -- 2621
						) -- 2621
					else -- 2621
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2623
						droppedToolResults = droppedToolResults + #matchedTools -- 2624
					end -- 2624
					i = j - 1 -- 2626
					goto __continue446 -- 2627
				end -- 2627
				if message.role == "tool" then -- 2627
					droppedToolResults = droppedToolResults + 1 -- 2630
					goto __continue446 -- 2631
				end -- 2631
				sanitized[#sanitized + 1] = message -- 2633
			end -- 2633
			::__continue446:: -- 2633
			i = i + 1 -- 2583
		end -- 2583
	end -- 2583
	return sanitized -- 2635
end -- 2635
function getUnconsolidatedMessages(shared) -- 2638
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2639
end -- 2639
function isFinalDecisionTurn(shared) -- 2644
	return shared.step + 1 >= shared.maxSteps -- 2645
end -- 2645
function getFinalDecisionTurnPrompt(shared) -- 2648
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2649
end -- 2649
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2654
	if attempt == nil then -- 2654
		attempt = 1 -- 2657
	end -- 2657
	if decisionMode == nil then -- 2657
		decisionMode = shared.decisionMode -- 2659
	end -- 2659
	if consumeResumeCheckpoint == nil then -- 2659
		consumeResumeCheckpoint = true -- 2660
	end -- 2660
	if pendingUserPrompt == nil then -- 2660
		pendingUserPrompt = "" -- 2661
	end -- 2661
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2663
	local tailSections = {} -- 2664
	if shared.resumeCheckpointPending == true then -- 2664
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2666
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2669
	end -- 2669
	if shared.truncatedToolOverwritePath ~= nil then -- 2669
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2672
	end -- 2672
	if consumeResumeCheckpoint then -- 2672
		shared.resumeCheckpointPending = false -- 2674
	end -- 2674
	local messages = { -- 2675
		{role = "system", content = systemPrompt}, -- 2676
		table.unpack(getUnconsolidatedMessages(shared)) -- 2677
	} -- 2677
	if pendingUserPrompt ~= "" then -- 2677
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2680
	end -- 2680
	if isFinalDecisionTurn(shared) then -- 2680
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2683
	end -- 2683
	if lastError and lastError ~= "" then -- 2683
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2686
		if decisionMode == "xml" then -- 2686
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2690
		end -- 2690
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2690
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2693
		end -- 2693
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2693
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2696
		end -- 2696
		messages[#messages + 1] = { -- 2698
			role = "user", -- 2699
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2700
		} -- 2700
	end -- 2700
	tailSections[#tailSections + 1] = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2707
		role = shared.role, -- 2708
		workMode = shared.workMode, -- 2709
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2710
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2711
		resumeRequiredTool = shared.resumeRequiredTool, -- 2712
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2713
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2714
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2715
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2716
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2717
		buildRepairPending = shared.buildRepairPending, -- 2718
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2719
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2720
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2721
	}) -- 2721
	messages[#messages + 1] = { -- 2723
		role = "user", -- 2724
		content = table.concat(tailSections, "\n\n") -- 2725
	} -- 2725
	return messages -- 2727
end -- 2727
function buildXmlDecisionInstruction(shared, feedback) -- 2730
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2731
end -- 2731
function tryParseAndValidateDecision(rawText, shared) -- 2815
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2816
	if not parsed.success then -- 2816
		return {success = false, message = parsed.message, raw = rawText} -- 2818
	end -- 2818
	local decision = parseDecisionObject(parsed.obj) -- 2820
	if not decision.success then -- 2820
		return {success = false, message = decision.message, raw = rawText} -- 2822
	end -- 2822
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2824
	if not completionValidation.success then -- 2824
		return {success = false, message = completionValidation.message, raw = rawText} -- 2826
	end -- 2826
	local validation = validateDecision(decision.tool, decision.params) -- 2828
	if not validation.success then -- 2828
		return {success = false, message = validation.message, raw = rawText} -- 2830
	end -- 2830
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2832
	if not sharedValidation.success then -- 2832
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2834
	end -- 2834
	decision.params = validation.params -- 2836
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2837
	return decision -- 2838
end -- 2838
function executeToolAction(shared, action) -- 4003
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4003
		if shared.stopToken.stopped then -- 4003
			return ____awaiter_resolve( -- 4003
				nil, -- 4003
				{ -- 4005
					success = false, -- 4005
					message = getCancelledReason(shared) -- 4005
				} -- 4005
			) -- 4005
		end -- 4005
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4005
			shared.resumeRequiredTool = nil -- 4008
			shared.resumeCheckpointPending = false -- 4009
		end -- 4009
		local params = action.params -- 4011
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4012
		if not sharedValidation.success then -- 4012
			return ____awaiter_resolve(nil, sharedValidation) -- 4012
		end -- 4012
		if action.tool == "read_file" then -- 4012
			local ____params_startLine_143 = params.startLine -- 4015
			if ____params_startLine_143 == nil then -- 4015
				____params_startLine_143 = 1 -- 4015
			end -- 4015
			local startLine = __TS__Number(____params_startLine_143) -- 4015
			local ____params_endLine_144 = params.endLine -- 4016
			if ____params_endLine_144 == nil then -- 4016
				____params_endLine_144 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4016
			end -- 4016
			local endLine = __TS__Number(____params_endLine_144) -- 4016
			local clippedAfterCompression = false -- 4017
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4017
				endLine = startLine + 159 -- 4024
				clippedAfterCompression = true -- 4025
			end -- 4025
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4027
			if __TS__StringTrim(path) == "" then -- 4027
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4027
			end -- 4027
			local result = Tools.readFile( -- 4031
				shared.workingDir, -- 4032
				path, -- 4033
				startLine, -- 4034
				endLine, -- 4035
				shared.useChineseResponse and "zh" or "en" -- 4036
			) -- 4036
			if clippedAfterCompression and result.success == true then -- 4036
				result.clipped = true -- 4039
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4040
			end -- 4040
			return ____awaiter_resolve(nil, result) -- 4040
		end -- 4040
		if action.tool ~= "build" then -- 4040
			shared.resumeNarrowReadMode = false -- 4050
		end -- 4050
		if action.tool == "grep_files" then -- 4050
			local searchPath = params.path or "" -- 4052
			local searchGlobs = params.globs -- 4053
			local ____Tools_searchFiles_158 = Tools.searchFiles -- 4054
			local ____shared_workingDir_151 = shared.workingDir -- 4055
			local ____temp_152 = params.pattern or "" -- 4057
			local ____params_globs_153 = params.globs -- 4058
			local ____params_useRegex_154 = params.useRegex -- 4059
			local ____params_caseSensitive_155 = params.caseSensitive -- 4060
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4062
			local ____math_max_147 = math.max -- 4063
			local ____math_floor_146 = math.floor -- 4063
			local ____params_limit_145 = params.limit -- 4063
			if ____params_limit_145 == nil then -- 4063
				____params_limit_145 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4063
			end -- 4063
			local ____math_max_147_result_157 = ____math_max_147( -- 4063
				1, -- 4063
				____math_floor_146(__TS__Number(____params_limit_145)) -- 4063
			) -- 4063
			local ____math_max_150 = math.max -- 4064
			local ____math_floor_149 = math.floor -- 4064
			local ____params_offset_148 = params.offset -- 4064
			if ____params_offset_148 == nil then -- 4064
				____params_offset_148 = 0 -- 4064
			end -- 4064
			local result = __TS__Await(____Tools_searchFiles_158({ -- 4054
				workDir = ____shared_workingDir_151, -- 4055
				path = searchPath, -- 4056
				pattern = ____temp_152, -- 4057
				globs = ____params_globs_153, -- 4058
				useRegex = ____params_useRegex_154, -- 4059
				caseSensitive = ____params_caseSensitive_155, -- 4060
				includeContent = true, -- 4061
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156, -- 4062
				limit = ____math_max_147_result_157, -- 4063
				offset = ____math_max_150( -- 4064
					0, -- 4064
					____math_floor_149(__TS__Number(____params_offset_148)) -- 4064
				), -- 4064
				groupByFile = params.groupByFile == true -- 4065
			})) -- 4065
			return ____awaiter_resolve(nil, result) -- 4065
		end -- 4065
		if action.tool == "search_dora_api" then -- 4065
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4070
			local ____Tools_searchDoraAPI_167 = Tools.searchDoraAPI -- 4071
			local ____temp_163 = params.pattern or "" -- 4072
			local ____temp_164 = params.docSource or "api" -- 4073
			local ____temp_165 = shared.useChineseResponse and "zh" or "en" -- 4074
			local ____temp_166 = params.programmingLanguage or "ts" -- 4075
			local ____math_min_162 = math.min -- 4076
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4076
			local ____math_max_160 = math.max -- 4076
			local ____params_limit_159 = params.limit -- 4076
			if ____params_limit_159 == nil then -- 4076
				____params_limit_159 = 8 -- 4076
			end -- 4076
			local result = __TS__Await(____Tools_searchDoraAPI_167({ -- 4071
				pattern = ____temp_163, -- 4072
				docSource = ____temp_164, -- 4073
				docLanguage = ____temp_165, -- 4074
				programmingLanguage = ____temp_166, -- 4075
				limit = ____math_min_162( -- 4076
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161, -- 4076
					____math_max_160( -- 4076
						1, -- 4076
						__TS__Number(____params_limit_159) -- 4076
					) -- 4076
				), -- 4076
				useRegex = params.useRegex, -- 4077
				caseSensitive = false, -- 4078
				includeContent = true, -- 4079
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4080
			})) -- 4080
			return ____awaiter_resolve(nil, result) -- 4080
		end -- 4080
		if action.tool == "glob_files" then -- 4080
			local ____Tools_listFiles_174 = Tools.listFiles -- 4085
			local ____shared_workingDir_171 = shared.workingDir -- 4086
			local ____temp_172 = params.path or "" -- 4087
			local ____params_globs_173 = params.globs -- 4088
			local ____math_max_170 = math.max -- 4089
			local ____math_floor_169 = math.floor -- 4089
			local ____params_maxEntries_168 = params.maxEntries -- 4089
			if ____params_maxEntries_168 == nil then -- 4089
				____params_maxEntries_168 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4089
			end -- 4089
			local result = ____Tools_listFiles_174({ -- 4085
				workDir = ____shared_workingDir_171, -- 4086
				path = ____temp_172, -- 4087
				globs = ____params_globs_173, -- 4088
				maxEntries = ____math_max_170( -- 4089
					1, -- 4089
					____math_floor_169(__TS__Number(____params_maxEntries_168)) -- 4089
				) -- 4089
			}) -- 4089
			return ____awaiter_resolve(nil, result) -- 4089
		end -- 4089
		if action.tool == "ask_user" then -- 4089
			if not shared.publishQuestionnaire then -- 4089
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4089
			end -- 4089
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4089
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4089
			end -- 4089
			local normalized = normalizeQuestionnaire(params) -- 4096
			if not normalized.success then -- 4096
				return ____awaiter_resolve(nil, normalized) -- 4096
			end -- 4096
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4098
			if not result.success then -- 4098
				return ____awaiter_resolve(nil, result) -- 4098
			end -- 4098
			shared.waitingQuestionnaireId = result.questionnaireId -- 4105
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4105
		end -- 4105
		if action.tool == "delete_file" then -- 4105
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4109
			if __TS__StringTrim(targetFile) == "" then -- 4109
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4109
			end -- 4109
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4113
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4114
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4114
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4114
			end -- 4114
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4118
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4119
			if not result.success then -- 4119
				return ____awaiter_resolve(nil, result) -- 4119
			end -- 4119
			if not isInternalDocumentEdit then -- 4119
				shared.unbuiltEdits = true -- 4127
				shared.lastBuildSucceeded = false -- 4128
				if shared.failedTestNeedsBuild == true then -- 4128
					shared.failedTestHasSourceEdit = true -- 4129
				end -- 4129
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4129
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4130
				end -- 4130
				shared.editedPathsSinceBuild = editedPaths -- 4131
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4132
			end -- 4132
			return ____awaiter_resolve(nil, { -- 4132
				success = true, -- 4135
				changed = true, -- 4136
				mode = "delete", -- 4137
				checkpointId = result.checkpointId, -- 4138
				checkpointSeq = result.checkpointSeq, -- 4139
				files = {{path = targetFile, op = "delete"}} -- 4140
			}) -- 4140
		end -- 4140
		if action.tool == "build" then -- 4140
			local buildPath = params.path or "" -- 4144
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4145
			shared.unbuiltEdits = false -- 4149
			shared.editsSinceBuild = 0 -- 4150
			shared.editedPathsSinceBuild = {} -- 4151
			shared.hasBuilt = true -- 4152
			shared.lastBuildSucceeded = result.success -- 4153
			if result.success and shared.freshProjectBuildPending == true then -- 4153
				shared.freshProjectBuildPending = false -- 4159
			end -- 4159
			shared.apiSearchesSinceBuild = 0 -- 4161
			shared.buildRepairPending = false -- 4162
			if not result.success and result.messages ~= nil then -- 4162
				do -- 4162
					local i = 0 -- 4164
					while i < #result.messages do -- 4164
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4164
							shared.buildRepairPending = true -- 4166
							break -- 4167
						end -- 4167
						i = i + 1 -- 4164
					end -- 4164
				end -- 4164
			end -- 4164
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4164
				shared.failedTestNeedsBuild = false -- 4172
				shared.failedTestHasSourceEdit = false -- 4173
			end -- 4173
			return ____awaiter_resolve(nil, result) -- 4173
		end -- 4173
		if action.tool == "fetch_url" then -- 4173
			local result = __TS__Await(Tools.fetchUrl({ -- 4178
				workDir = shared.workingDir, -- 4179
				url = type(params.url) == "string" and params.url or "", -- 4180
				target = type(params.target) == "string" and params.target or "", -- 4181
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4182
				onProgress = function(____, progress) -- 4183
					emitAgentEvent( -- 4184
						shared, -- 4184
						{ -- 4184
							type = "tool_progress", -- 4185
							sessionId = shared.sessionId, -- 4186
							taskId = shared.taskId, -- 4187
							step = action.step, -- 4188
							tool = action.tool, -- 4189
							result = __TS__ObjectAssign({success = false}, progress) -- 4190
						} -- 4190
					) -- 4190
				end -- 4183
			})) -- 4183
			return ____awaiter_resolve(nil, result) -- 4183
		end -- 4183
		if action.tool == "execute_command" then -- 4183
			local mode = type(params.mode) == "string" and params.mode or "" -- 4200
			local result = __TS__Await(Tools.executeCommand({ -- 4201
				workDir = shared.workingDir, -- 4202
				mode = mode, -- 4203
				code = type(params.code) == "string" and params.code or nil, -- 4204
				command = type(params.command) == "string" and params.command or nil, -- 4205
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4206
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4207
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4208
				onProgress = function(____, progress) -- 4209
					emitAgentEvent( -- 4210
						shared, -- 4210
						{ -- 4210
							type = "tool_progress", -- 4211
							sessionId = shared.sessionId, -- 4212
							taskId = shared.taskId, -- 4213
							step = action.step, -- 4214
							tool = action.tool, -- 4215
							result = __TS__ObjectAssign({success = false}, progress) -- 4216
						} -- 4216
					) -- 4216
				end -- 4209
			})) -- 4209
			if result.success and mode == "lua" then -- 4209
				local deterministicFailure = false -- 4224
				local deterministicPass = false -- 4225
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4226
				do -- 4226
					local i = 0 -- 4227
					while i < #outputLines and not deterministicFailure do -- 4227
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4228
						if line == "passed" then -- 4228
							deterministicPass = true -- 4229
						end -- 4229
						if line == "failed" then -- 4229
							deterministicFailure = true -- 4231
							break -- 4232
						end -- 4232
						local searchFrom = 0 -- 4234
						while searchFrom < #line do -- 4234
							local failedIndex = (string.find( -- 4236
								line, -- 4236
								"failed", -- 4236
								math.max(searchFrom + 1, 1), -- 4236
								true -- 4236
							) or 0) - 1 -- 4236
							if failedIndex < 0 then -- 4236
								break -- 4237
							end -- 4237
							local after = failedIndex + #"failed" -- 4238
							while after < #line do -- 4238
								local ch = __TS__StringSlice(line, after, after + 1) -- 4240
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4240
									break -- 4241
								end -- 4241
								after = after + 1 -- 4242
							end -- 4242
							local afterEnd = after -- 4244
							while afterEnd < #line do -- 4244
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4246
								if ch < "0" or ch > "9" then -- 4246
									break -- 4247
								end -- 4247
								afterEnd = afterEnd + 1 -- 4248
							end -- 4248
							local count -- 4250
							if afterEnd > after then -- 4250
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4252
							else -- 4252
								local before = failedIndex - 1 -- 4254
								while before >= 0 do -- 4254
									local ch = __TS__StringSlice(line, before, before + 1) -- 4256
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4256
										break -- 4257
									end -- 4257
									before = before - 1 -- 4258
								end -- 4258
								local beforeEnd = before + 1 -- 4260
								while before >= 0 do -- 4260
									local ch = __TS__StringSlice(line, before, before + 1) -- 4262
									if ch < "0" or ch > "9" then -- 4262
										break -- 4263
									end -- 4263
									before = before - 1 -- 4264
								end -- 4264
								if beforeEnd > before + 1 then -- 4264
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4266
								end -- 4266
							end -- 4266
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4266
								deterministicFailure = true -- 4269
								break -- 4270
							end -- 4270
							searchFrom = failedIndex + #"failed" -- 4272
						end -- 4272
						i = i + 1 -- 4227
					end -- 4227
				end -- 4227
				if deterministicFailure then -- 4227
					shared.failedTestNeedsBuild = true -- 4276
					shared.failedTestHasSourceEdit = false -- 4277
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4278
				elseif deterministicPass then -- 4278
					shared.deterministicTestFailureCount = 0 -- 4280
				end -- 4280
			end -- 4280
			return ____awaiter_resolve(nil, result) -- 4280
		end -- 4280
		if action.tool == "spawn_sub_agent" then -- 4280
			if not shared.spawnSubAgent then -- 4280
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4280
			end -- 4280
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4280
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4280
			end -- 4280
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4292
				params.filesHint, -- 4293
				function(____, item) return type(item) == "string" end -- 4293
			) or nil -- 4293
			local result = __TS__Await(shared.spawnSubAgent({ -- 4295
				parentSessionId = shared.sessionId, -- 4296
				projectRoot = shared.workingDir, -- 4297
				title = type(params.title) == "string" and params.title or "Sub", -- 4298
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4299
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4300
				filesHint = filesHint, -- 4301
				disabledAgentTools = shared.disabledAgentTools -- 4302
			})) -- 4302
			if not result.success then -- 4302
				return ____awaiter_resolve(nil, result) -- 4302
			end -- 4302
			shared.hasSpawnedSubAgentThisTask = true -- 4307
			return ____awaiter_resolve(nil, { -- 4307
				success = true, -- 4309
				sessionId = result.sessionId, -- 4310
				taskId = result.taskId, -- 4311
				title = result.title, -- 4312
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4313
			}) -- 4313
		end -- 4313
		if action.tool == "list_sub_agents" then -- 4313
			if not shared.listSubAgents then -- 4313
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4313
			end -- 4313
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4313
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4313
			end -- 4313
			local result = __TS__Await(shared.listSubAgents({ -- 4323
				sessionId = shared.sessionId, -- 4324
				projectRoot = shared.workingDir, -- 4325
				status = type(params.status) == "string" and params.status or nil, -- 4326
				limit = type(params.limit) == "number" and params.limit or nil, -- 4327
				offset = type(params.offset) == "number" and params.offset or nil, -- 4328
				query = type(params.query) == "string" and params.query or nil -- 4329
			})) -- 4329
			return ____awaiter_resolve(nil, result) -- 4329
		end -- 4329
		if action.tool == "edit_file" then -- 4329
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4334
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4337
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4338
			if __TS__StringTrim(path) == "" then -- 4338
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4338
			end -- 4338
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4340
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4341
			if not isInternalDocumentEdit then -- 4341
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4343
				if preflightIssue ~= nil then -- 4343
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4345
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4346
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4346
				end -- 4346
			end -- 4346
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4352
			local result = __TS__Await(actionNode:exec({ -- 4353
				path = path, -- 4354
				oldStr = oldStr, -- 4355
				newStr = newStr, -- 4356
				taskId = shared.taskId, -- 4357
				workDir = shared.workingDir -- 4358
			})) -- 4358
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4358
				if params.partialStreamRecovery ~= true then -- 4358
					shared.truncatedToolOverwritePath = nil -- 4362
				end -- 4362
				shared.unbuiltEdits = true -- 4364
				shared.lastBuildSucceeded = false -- 4365
				if shared.failedTestNeedsBuild == true then -- 4365
					shared.failedTestHasSourceEdit = true -- 4366
				end -- 4366
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4367
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4367
					editedPaths[#editedPaths + 1] = normalizedPath -- 4368
				end -- 4368
				shared.editedPathsSinceBuild = editedPaths -- 4369
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4370
			end -- 4370
			return ____awaiter_resolve(nil, result) -- 4370
		end -- 4370
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4370
	end) -- 4370
end -- 4370
function sanitizeToolActionResultForHistory(action, result) -- 4377
	if action.tool == "read_file" then -- 4377
		return sanitizeReadResultForHistory(action.tool, result) -- 4379
	end -- 4379
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4379
		return sanitizeSearchResultForHistory(action.tool, result) -- 4382
	end -- 4382
	if action.tool == "glob_files" then -- 4382
		return sanitizeListFilesResultForHistory(result) -- 4385
	end -- 4385
	if action.tool == "build" then -- 4385
		return sanitizeBuildResultForHistory(result) -- 4388
	end -- 4388
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4388
		if result.success ~= true then -- 4388
			return result -- 4391
		end -- 4391
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4391
			return result -- 4392
		end -- 4392
		if isArray(result.fileContext) then -- 4392
			return result -- 4393
		end -- 4393
		local contextLimits = { -- 4395
			fullContentChars = 12000, -- 4396
			previewChars = 4000, -- 4397
			diffChars = 8000, -- 4398
			totalChars = 24000, -- 4399
			maxFiles = 8 -- 4400
		} -- 4400
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4402
			if maxChars <= 0 then -- 4402
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4403
			end -- 4403
			if #sourceText <= maxChars then -- 4403
				return sourceText -- 4404
			end -- 4404
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4405
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4406
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4407
		end -- 4402
		local function countLines(sourceText) -- 4409
			if sourceText == "" then -- 4409
				return 0 -- 4410
			end -- 4410
			return #__TS__StringSplit(sourceText, "\n") -- 4411
		end -- 4409
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4413
			if beforeContent == afterContent then -- 4413
				return "" -- 4414
			end -- 4414
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4415
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4416
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4418
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4418
				firstChangedLine = firstChangedLine + 1 -- 4424
			end -- 4424
			local lastChangedBeforeLine = #beforeLines - 1 -- 4426
			local lastChangedAfterLine = #afterLines - 1 -- 4427
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4427
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4433
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4434
			end -- 4434
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4436
			local previewEndLine = math.max( -- 4437
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4438
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4439
			) -- 4439
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4441
			do -- 4441
				local lineIndex = previewStartLine -- 4442
				while lineIndex <= previewEndLine do -- 4442
					do -- 4442
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4443
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4444
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4445
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4446
						if not beforeChanged and not afterChanged then -- 4446
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4448
							if contextLine ~= nil then -- 4448
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4449
							end -- 4449
							goto __continue726 -- 4450
						end -- 4450
						if beforeChanged and beforeLine ~= nil then -- 4450
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4452
						end -- 4452
						if afterChanged and afterLine ~= nil then -- 4452
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4453
						end -- 4453
					end -- 4453
					::__continue726:: -- 4453
					lineIndex = lineIndex + 1 -- 4442
				end -- 4442
			end -- 4442
			return truncateContextSnippet( -- 4455
				table.concat(unifiedDiffLines, "\n"), -- 4455
				maxChars, -- 4455
				"diff" -- 4455
			) -- 4455
		end -- 4413
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4458
		if not checkpointDiff.success then -- 4458
			return result -- 4459
		end -- 4459
		local remainingContextBudget = contextLimits.totalChars -- 4460
		local fileContextItems = {} -- 4461
		local changedFiles = checkpointDiff.files -- 4462
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4463
		do -- 4463
			local fileIndex = 0 -- 4464
			while fileIndex < maxContextFiles do -- 4464
				if remainingContextBudget <= 0 then -- 4464
					break -- 4465
				end -- 4465
				local changedFile = changedFiles[fileIndex + 1] -- 4466
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4467
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4468
				local contextItem = { -- 4469
					path = changedFile.path, -- 4470
					op = changedFile.op, -- 4471
					checkpointId = result.checkpointId, -- 4472
					checkpointSeq = result.checkpointSeq, -- 4473
					beforeExists = changedFile.beforeExists, -- 4474
					afterExists = changedFile.afterExists, -- 4475
					beforeBytes = #beforeContent, -- 4476
					afterBytes = #afterContent, -- 4477
					diffPreview = "", -- 4478
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4479
					contentTruncated = false, -- 4480
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4481
				} -- 4481
				if changedFile.afterExists then -- 4481
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4481
						contextItem.afterContent = afterContent -- 4485
						remainingContextBudget = remainingContextBudget - #afterContent -- 4486
					else -- 4486
						contextItem.afterContentPreview = truncateContextSnippet( -- 4488
							afterContent, -- 4489
							math.min( -- 4490
								contextLimits.previewChars, -- 4490
								math.max(400, remainingContextBudget) -- 4490
							), -- 4490
							"afterContent" -- 4491
						) -- 4491
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4493
						contextItem.contentTruncated = true -- 4494
					end -- 4494
				end -- 4494
				local diffPreview = buildUnifiedDiffPreview( -- 4497
					changedFile.path, -- 4498
					beforeContent, -- 4499
					afterContent, -- 4500
					math.min( -- 4501
						contextLimits.diffChars, -- 4501
						math.max(400, remainingContextBudget) -- 4501
					) -- 4501
				) -- 4501
				contextItem.diffPreview = diffPreview -- 4503
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4504
				if not changedFile.afterExists and beforeContent ~= "" then -- 4504
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4506
						beforeContent, -- 4507
						math.min( -- 4508
							contextLimits.previewChars, -- 4508
							math.max(400, remainingContextBudget) -- 4508
						), -- 4508
						"beforeContent" -- 4509
					) -- 4509
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4511
					if #beforeContent > contextLimits.previewChars then -- 4511
						contextItem.contentTruncated = true -- 4512
					end -- 4512
				end -- 4512
				fileContextItems[#fileContextItems + 1] = contextItem -- 4514
				fileIndex = fileIndex + 1 -- 4464
			end -- 4464
		end -- 4464
		if #fileContextItems == 0 then -- 4464
			return result -- 4516
		end -- 4516
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4517
	end -- 4517
	return result -- 4524
end -- 4524
function emitAgentTaskFinishEvent(shared, success, message) -- 4721
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4722
	local result = success and ({ -- 4726
		success = true, -- 4728
		taskId = shared.taskId, -- 4729
		message = message, -- 4730
		steps = shared.step, -- 4731
		completion = completion -- 4732
	}) or ({ -- 4732
		success = false, -- 4735
		taskId = shared.taskId, -- 4736
		message = message, -- 4737
		steps = shared.step, -- 4738
		completion = completion -- 4739
	}) -- 4739
	emitAgentEvent(shared, { -- 4741
		type = "task_finished", -- 4742
		sessionId = shared.sessionId, -- 4743
		taskId = shared.taskId, -- 4744
		success = result.success, -- 4745
		message = result.message, -- 4746
		steps = result.steps, -- 4747
		completion = result.completion -- 4748
	}) -- 4748
	return result -- 4750
end -- 4750
local function buildLLMOptions(llmConfig, overrides) -- 296
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 297
	if llmConfig.reasoningEffort then -- 297
		options.reasoning_effort = llmConfig.reasoningEffort -- 302
	end -- 302
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 304
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 304
		__TS__Delete(merged, "reasoning_effort") -- 309
	else -- 309
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 311
	end -- 311
	__TS__Delete(merged, "tool_choice") -- 316
	return merged -- 317
end -- 296
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 447
	local fitted = AgentUtils.fitMessagesToContext(messages, options, shared.llmConfig) -- 454
	local messagesTokens = fitted.originalTokens -- 455
	local toolDefinitionsTokens = 0 -- 457
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 457
		local toolsText = AgentUtils.safeJsonEncode(options.tools) -- 459
		toolDefinitionsTokens = toolsText and AgentUtils.estimateTextTokens(toolsText) or 0 -- 460
	end -- 460
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 463
	__TS__Delete(optionsWithoutTools, "tools") -- 464
	local optionsText = AgentUtils.safeJsonEncode(optionsWithoutTools) -- 465
	local optionsTokens = optionsText and AgentUtils.estimateTextTokens(optionsText) or 0 -- 466
	local contextWindow = shared.llmConfig.contextWindow > 0 and math.floor(shared.llmConfig.contextWindow) or 64000 -- 467
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 470
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 475
		1024, -- 477
		math.floor(contextWindow * 0.2) -- 477
	) -- 477
	local structuralOverhead = math.max(256, #messages * 16) -- 478
	local usedTokens = messagesTokens -- 481
	local maxTokens = fitted.budgetTokens -- 482
	emitAgentEvent( -- 483
		shared, -- 483
		{ -- 483
			type = "metrics_updated", -- 484
			sessionId = shared.sessionId, -- 485
			taskId = shared.taskId, -- 486
			step = step, -- 487
			metrics = {context = { -- 488
				usedTokens = usedTokens, -- 490
				maxTokens = maxTokens, -- 491
				ratio = math.max( -- 492
					0, -- 492
					math.min(1, usedTokens / maxTokens) -- 492
				), -- 492
				messagesTokens = messagesTokens, -- 493
				optionsTokens = optionsTokens, -- 494
				toolDefinitionsTokens = toolDefinitionsTokens, -- 495
				reservedOutputTokens = reservedOutputTokens, -- 496
				structuralOverhead = structuralOverhead, -- 497
				contextWindow = contextWindow, -- 498
				source = "llm_input_estimate", -- 499
				updatedAt = os.time(), -- 500
				phase = phase, -- 501
				step = step -- 502
			}} -- 502
		} -- 502
	) -- 502
end -- 447
local function recordLLMTokenUsage(shared, step, phase, usage) -- 508
	if not usage then -- 508
		return -- 509
	end -- 509
	local current = shared.tokenUsage -- 510
	local cachedReported = usage.cachedInputTokens ~= nil -- 511
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 512
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 513
	local next = { -- 514
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 515
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 516
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 517
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 518
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 521
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 524
		requestCount = (current and current.requestCount or 0) + 1, -- 527
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 528
		model = shared.llmConfig.model, -- 531
		phase = phase, -- 532
		step = step, -- 533
		updatedAt = os.time() -- 534
	} -- 534
	shared.tokenUsage = next -- 536
	emitAgentEvent(shared, { -- 537
		type = "metrics_updated", -- 538
		sessionId = shared.sessionId, -- 539
		taskId = shared.taskId, -- 540
		step = step, -- 541
		metrics = {usage = next} -- 542
	}) -- 542
end -- 508
local function emitAgentStartEvent(shared, action) -- 546
	emitAgentEvent(shared, { -- 547
		type = "tool_started", -- 548
		sessionId = shared.sessionId, -- 549
		taskId = shared.taskId, -- 550
		step = action.step, -- 551
		tool = action.tool -- 552
	}) -- 552
end -- 546
local function emitAgentFinishEvent(shared, action) -- 556
	emitAgentEvent(shared, { -- 557
		type = "tool_finished", -- 558
		sessionId = shared.sessionId, -- 559
		taskId = shared.taskId, -- 560
		step = action.step, -- 561
		tool = action.tool, -- 562
		result = action.result or ({}) -- 563
	}) -- 563
end -- 556
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 567
	emitAgentEvent(shared, { -- 568
		type = "assistant_message_updated", -- 569
		sessionId = shared.sessionId, -- 570
		taskId = shared.taskId, -- 571
		step = shared.step + 1, -- 572
		content = content, -- 573
		reasoningContent = reasoningContent -- 574
	}) -- 574
end -- 567
local function getMemoryCompressionStartReason(shared) -- 578
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 579
end -- 578
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 584
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 585
end -- 584
local function getMemoryCompressionFailureReason(shared, ____error) -- 590
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 591
end -- 590
local function summarizeHistoryEntryPreview(text, maxChars) -- 596
	if maxChars == nil then -- 596
		maxChars = 180 -- 596
	end -- 596
	local trimmed = __TS__StringTrim(text) -- 597
	if trimmed == "" then -- 597
		return "" -- 598
	end -- 598
	return truncateText(trimmed, maxChars) -- 599
end -- 596
local function getMaxStepsReachedReason(shared) -- 607
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 608
end -- 607
local function getFailureSummaryFallback(shared, ____error) -- 613
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 614
end -- 613
local function finalizeAgentFailure(shared, ____error) -- 619
	if shared.stopToken.stopped then -- 619
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 621
		return emitAgentTaskFinishEvent( -- 622
			shared, -- 622
			false, -- 622
			getCancelledReason(shared) -- 622
		) -- 622
	end -- 622
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 624
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 625
end -- 619
local function getPromptCommand(prompt) -- 628
	local trimmed = __TS__StringTrim(prompt) -- 629
	if trimmed == "/compact" then -- 629
		return "compact" -- 630
	end -- 630
	if trimmed == "/clear" then -- 630
		return "clear" -- 631
	end -- 631
	return nil -- 632
end -- 628
function ____exports.truncateAgentUserPrompt(prompt) -- 635
	if not prompt then -- 635
		return "" -- 636
	end -- 636
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 636
		return prompt -- 637
	end -- 637
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 638
	if offset == nil then -- 638
		return prompt -- 639
	end -- 639
	return string.sub(prompt, 1, offset - 1) -- 640
end -- 635
local function canWriteStepLLMDebug(shared, stepId) -- 643
	if stepId == nil then -- 643
		stepId = shared.step + 1 -- 643
	end -- 643
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 644
end -- 643
local function ensureDirRecursive(dir) -- 651
	if not dir then -- 651
		return false -- 652
	end -- 652
	if Content:exist(dir) then -- 652
		return Content:isdir(dir) -- 653
	end -- 653
	local parent = Path:getPath(dir) -- 654
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 654
		return false -- 656
	end -- 656
	return Content:mkdir(dir) -- 658
end -- 651
local function encodeDebugJSON(value) -- 661
	local text, err = AgentUtils.safeJsonEncode(value) -- 662
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 663
end -- 661
function ____exports.isAgentPlanPath(path) -- 679
	return AgentRuntimePolicy.isAgentPlanPath(path) -- 680
end -- 679
local function inspectFreshProject(workDir) -- 683
	local result = Tools.listFiles({workDir = workDir, path = "", globs = AgentConfig.AGENT_FILE_PATTERNS.freshProjectCodeGlobs, maxEntries = 2}) -- 684
	if not result.success then -- 684
		return {fresh = false} -- 690
	end -- 690
	local totalEntries = result.totalEntries or #result.files -- 691
	if totalEntries > 1 then -- 691
		return {fresh = false} -- 692
	end -- 692
	if totalEntries == 0 then -- 692
		return {fresh = true} -- 693
	end -- 693
	if #result.files ~= 1 then -- 693
		return {fresh = false} -- 694
	end -- 694
	local path = result.files[1] -- 695
	local loaded = Tools.readFileRaw(workDir, path) -- 696
	if not loaded.success or loaded.content == nil then -- 696
		return {fresh = false} -- 697
	end -- 697
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 698
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 701
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 702
end -- 683
local function getStepLLMDebugDir(shared) -- 705
	return Path( -- 706
		shared.workingDir, -- 707
		".agent", -- 708
		tostring(shared.sessionId), -- 709
		tostring(shared.taskId) -- 710
	) -- 710
end -- 705
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 714
	return Path( -- 715
		getStepLLMDebugDir(shared), -- 715
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 715
	) -- 715
end -- 714
local function getLatestStepLLMDebugSeq(shared, stepId) -- 718
	if not canWriteStepLLMDebug(shared, stepId) then -- 718
		return 0 -- 719
	end -- 719
	local dir = getStepLLMDebugDir(shared) -- 720
	if not Content:exist(dir) or not Content:isdir(dir) then -- 720
		return 0 -- 721
	end -- 721
	local latest = 0 -- 722
	for ____, file in ipairs(Content:getFiles(dir)) do -- 723
		do -- 723
			local name = Path:getFilename(file) -- 724
			local seqText = string.match( -- 725
				name, -- 725
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 725
			) -- 725
			if seqText ~= nil then -- 725
				latest = math.max( -- 727
					latest, -- 727
					tonumber(seqText) -- 727
				) -- 727
				goto __continue57 -- 728
			end -- 728
			local legacyMatch = string.match( -- 730
				name, -- 730
				("^" .. tostring(stepId)) .. "_in%.md$" -- 730
			) -- 730
			if legacyMatch ~= nil then -- 730
				latest = math.max(latest, 1) -- 732
			end -- 732
		end -- 732
		::__continue57:: -- 732
	end -- 732
	return latest -- 735
end -- 718
local function writeStepLLMDebugFile(path, content) -- 738
	if not Content:save(path, content) then -- 738
		AgentUtils.Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 740
		return false -- 741
	end -- 741
	return true -- 743
end -- 738
local function createStepLLMDebugPair(shared, stepId, inContent) -- 746
	if not canWriteStepLLMDebug(shared, stepId) then -- 746
		return 0 -- 747
	end -- 747
	local dir = getStepLLMDebugDir(shared) -- 748
	if not ensureDirRecursive(dir) then -- 748
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 750
		return 0 -- 751
	end -- 751
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 753
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 754
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 755
	if not writeStepLLMDebugFile(inPath, inContent) then -- 755
		return 0 -- 757
	end -- 757
	writeStepLLMDebugFile(outPath, "") -- 759
	return seq -- 760
end -- 746
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 763
	if not canWriteStepLLMDebug(shared, stepId) then -- 763
		return -- 764
	end -- 764
	local dir = getStepLLMDebugDir(shared) -- 765
	if not ensureDirRecursive(dir) then -- 765
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 767
		return -- 768
	end -- 768
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 770
	if latestSeq <= 0 then -- 770
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 772
		writeStepLLMDebugFile(outPath, content) -- 773
		return -- 774
	end -- 774
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 776
	writeStepLLMDebugFile(outPath, content) -- 777
end -- 763
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 780
	if not canWriteStepLLMDebug(shared, stepId) then -- 780
		return -- 781
	end -- 781
	local sections = { -- 782
		"# LLM Input", -- 783
		"session_id: " .. tostring(shared.sessionId), -- 784
		"task_id: " .. tostring(shared.taskId), -- 785
		"step_id: " .. tostring(stepId), -- 786
		"phase: " .. phase, -- 787
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 788
		"## Options", -- 789
		"```json", -- 790
		encodeDebugJSON(options), -- 791
		"```" -- 792
	} -- 792
	local firstMessage = #messages > 0 and messages[1] or nil -- 794
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 794
		sections[#sections + 1] = "# System Prompt" -- 796
		sections[#sections + 1] = firstMessage.content -- 797
	end -- 797
	do -- 797
		local i = 0 -- 799
		while i < #messages do -- 799
			local message = messages[i + 1] -- 800
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 801
			sections[#sections + 1] = encodeDebugJSON(message) -- 802
			i = i + 1 -- 799
		end -- 799
	end -- 799
	createStepLLMDebugPair( -- 804
		shared, -- 804
		stepId, -- 804
		table.concat(sections, "\n") -- 804
	) -- 804
end -- 780
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 807
	if not canWriteStepLLMDebug(shared, stepId) then -- 807
		return -- 808
	end -- 808
	local ____array_24 = __TS__SparseArrayNew( -- 808
		"# LLM Output", -- 810
		"session_id: " .. tostring(shared.sessionId), -- 811
		"task_id: " .. tostring(shared.taskId), -- 812
		"step_id: " .. tostring(stepId), -- 813
		"phase: " .. phase, -- 814
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 815
		table.unpack(meta and ({ -- 816
			"## Meta", -- 816
			"```json", -- 816
			encodeDebugJSON(meta), -- 816
			"```" -- 816
		}) or ({})) -- 816
	) -- 816
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 816
	local sections = {__TS__SparseArraySpread(____array_24)} -- 809
	updateLatestStepLLMDebugOutput( -- 820
		shared, -- 820
		stepId, -- 820
		table.concat(sections, "\n") -- 820
	) -- 820
end -- 807
local function summarizeEditTextParamForHistory(value, key) -- 947
	if type(value) ~= "string" then -- 947
		return nil -- 948
	end -- 948
	local text = value -- 949
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 950
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 951
end -- 947
local function sanitizeActionParamsForHistory(tool, params) -- 1086
	if tool ~= "edit_file" then -- 1086
		return params -- 1087
	end -- 1087
	local clone = {} -- 1088
	for key in pairs(params) do -- 1089
		if key == "old_str" then -- 1089
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1091
		elseif key == "new_str" then -- 1091
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1093
		else -- 1093
			clone[key] = params[key] -- 1095
		end -- 1095
	end -- 1095
	return clone -- 1098
end -- 1086
local function projectMessagesForCompression(messages) -- 1250
	local projected = projectMessagesForLLMContext(messages) -- 1251
	do -- 1251
		local i = 0 -- 1252
		while i < #projected do -- 1252
			do -- 1252
				local message = projected[i + 1] -- 1253
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1253
					goto __continue189 -- 1254
				end -- 1254
				local changed = false -- 1255
				local toolCalls = __TS__ArrayMap( -- 1256
					message.tool_calls, -- 1256
					function(____, toolCall) -- 1256
						local fn = toolCall["function"] -- 1257
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1257
							return toolCall -- 1258
						end -- 1258
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 1259
						if not isRecord(decoded) or isArray(decoded) then -- 1259
							return toolCall -- 1260
						end -- 1260
						changed = true -- 1261
						return __TS__ObjectAssign( -- 1262
							{}, -- 1262
							toolCall, -- 1263
							{["function"] = __TS__ObjectAssign( -- 1262
								{}, -- 1264
								fn, -- 1265
								{arguments = toJson( -- 1264
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1266
									false -- 1266
								)} -- 1266
							)} -- 1266
						) -- 1266
					end -- 1256
				) -- 1256
				if changed then -- 1256
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1270
				end -- 1270
			end -- 1270
			::__continue189:: -- 1270
			i = i + 1 -- 1252
		end -- 1252
	end -- 1252
	return projected -- 1272
end -- 1250
local function getDecisionToolSchemaText(shared) -- 1314
	local toolsText = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1315
		shared.role, -- 1315
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1315
		{ -- 1315
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1316
			workMode = shared.workMode -- 1317
		} -- 1317
	)) -- 1317
	return toolsText or "" -- 1319
end -- 1314
local function clearPreExecutedResults(shared) -- 1329
	shared.preExecutedResults = nil -- 1330
end -- 1329
local function startPreExecutedToolAction(shared, action) -- 1333
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1333
		local ____hasReturned, ____returnValue -- 1333
		local ____try = __TS__AsyncAwaiter(function() -- 1333
			____hasReturned = true -- 1335
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1335
			return -- 1335
		end) -- 1335
		____try = ____try.catch( -- 1335
			____try, -- 1335
			function(____, err) -- 1335
				return __TS__AsyncAwaiter(function() -- 1335
					local message = tostring(err) -- 1337
					AgentUtils.Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1338
					____hasReturned = true -- 1339
					____returnValue = {success = false, message = message} -- 1339
					return -- 1339
				end) -- 1339
			end -- 1339
		) -- 1339
		__TS__Await(____try) -- 1334
		if ____hasReturned then -- 1334
			return ____awaiter_resolve(nil, ____returnValue) -- 1334
		end -- 1334
	end) -- 1334
end -- 1333
local function createPreExecutedToolResult(shared, action) -- 1343
	local cloneParamValue -- 1344
	cloneParamValue = function(value) -- 1344
		if value == nil then -- 1344
			return value -- 1345
		end -- 1345
		if isArray(value) then -- 1345
			return __TS__ArrayMap( -- 1347
				value, -- 1347
				function(____, item) return cloneParamValue(item) end -- 1347
			) -- 1347
		end -- 1347
		if type(value) == "table" then -- 1347
			local clone = {} -- 1350
			for key in pairs(value) do -- 1351
				clone[key] = cloneParamValue(value[key]) -- 1352
			end -- 1352
			return clone -- 1354
		end -- 1354
		return value -- 1356
	end -- 1344
	local params = cloneParamValue(action.params) -- 1358
	local areParamValuesEqual -- 1359
	areParamValuesEqual = function(left, right) -- 1359
		if left == right then -- 1359
			return true -- 1360
		end -- 1360
		if left == nil or right == nil then -- 1360
			return false -- 1361
		end -- 1361
		if isArray(left) or isArray(right) then -- 1361
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1361
				return false -- 1363
			end -- 1363
			do -- 1363
				local i = 0 -- 1364
				while i < #left do -- 1364
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1364
						return false -- 1365
					end -- 1365
					i = i + 1 -- 1364
				end -- 1364
			end -- 1364
			return true -- 1367
		end -- 1367
		if type(left) == "table" and type(right) == "table" then -- 1367
			local leftCount = 0 -- 1370
			for key in pairs(left) do -- 1371
				leftCount = leftCount + 1 -- 1372
				if not areParamValuesEqual(left[key], right[key]) then -- 1372
					return false -- 1377
				end -- 1377
			end -- 1377
			local rightCount = 0 -- 1380
			for key in pairs(right) do -- 1381
				rightCount = rightCount + 1 -- 1382
			end -- 1382
			return leftCount == rightCount -- 1384
		end -- 1384
		return false -- 1386
	end -- 1359
	return { -- 1388
		action = action, -- 1389
		matches = function(self, nextAction) -- 1390
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1391
		end, -- 1390
		promise = startPreExecutedToolAction(shared, action) -- 1393
	} -- 1393
end -- 1343
local function executeToolActionWithPreExecution(shared, action) -- 1397
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1397
		local ____opt_29 = shared.preExecutedResults -- 1397
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1398
		local result -- 1399
		if preResult then -- 1399
			local ____opt_31 = shared.preExecutedResults -- 1399
			if ____opt_31 ~= nil then -- 1399
				____opt_31:delete(action.toolCallId) -- 1401
			end -- 1401
			if preResult:matches(action) then -- 1401
				AgentUtils.Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1403
				result = __TS__Await(preResult.promise) -- 1404
			else -- 1404
				AgentUtils.Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1406
				result = __TS__Await(executeToolAction(shared, action)) -- 1407
			end -- 1407
		else -- 1407
			result = __TS__Await(executeToolAction(shared, action)) -- 1410
		end -- 1410
		local guidance = {} -- 1412
		if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1412
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1418
		end -- 1418
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1418
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1421
		end -- 1421
		if shared.failedTestNeedsBuild == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1421
			guidance[#guidance + 1] = "A deterministic test previously failed. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1424
		end -- 1424
		if action.tool == "search_dora_api" then -- 1424
			if shared.unbuiltEdits == true then -- 1424
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1428
			end -- 1428
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1428
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1431
			end -- 1431
		end -- 1431
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1431
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1439
		end -- 1439
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 1439
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1442
			if oldStr == "" then -- 1442
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1444
			end -- 1444
		end -- 1444
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1444
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1448
		end -- 1448
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1448
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1451
		end -- 1451
		if shared.buildRepairPending == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1451
			guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1456
		end -- 1456
		if shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true then -- 1456
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1459
		end -- 1459
		if #guidance > 0 then -- 1459
			result.guidance = table.concat(guidance, "\n") -- 1462
		end -- 1462
		return ____awaiter_resolve(nil, result) -- 1462
	end) -- 1462
end -- 1397
local function maybeCompressHistory(shared, includePendingUserPrompt, pendingUserPrompt) -- 1467
	if includePendingUserPrompt == nil then -- 1467
		includePendingUserPrompt = false -- 1469
	end -- 1469
	if pendingUserPrompt == nil then -- 1469
		pendingUserPrompt = "" -- 1470
	end -- 1470
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1470
		local ____shared_33 = shared -- 1472
		local memory = ____shared_33.memory -- 1472
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1473
		local changed = false -- 1474
		do -- 1474
			local round = 0 -- 1475
			while round < maxRounds do -- 1475
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1476
				local normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1477
				local decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages) -- 1478
				local activeMessages = projectMessagesForCompression(normalizedActiveMessages) -- 1479
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1482
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1490
				local triggerMessages = buildDecisionMessages( -- 1493
					shared, -- 1494
					nil, -- 1495
					1, -- 1496
					nil, -- 1497
					shared.decisionMode, -- 1498
					false, -- 1499
					includePendingUserPrompt and pendingUserPrompt or "" -- 1500
				) -- 1500
				local triggerOptions = shared.decisionMode == "tool_calling" and __TS__ObjectAssign( -- 1502
					{}, -- 1503
					shared.llmOptions, -- 1504
					__TS__StringIncludes( -- 1505
						string.lower(shared.llmConfig.model), -- 1505
						"glm-5.2" -- 1505
					) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") and ({reasoning_effort = "minimal"}) or ({}), -- 1505
					{tools = AgentToolRegistry.buildDecisionToolSchema( -- 1503
						shared.role, -- 1510
						AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1510
						{ -- 1510
							disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1511
							workMode = shared.workMode -- 1512
						} -- 1512
					)} -- 1512
				) or shared.llmOptions -- 1512
				local fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig) -- 1516
				local thresholdReached = getActiveRealMessageCount(shared) > 0 and fitted.originalTokens >= fitted.budgetTokens -- 1519
				if not thresholdReached then -- 1519
					if changed then -- 1519
						persistHistoryState(shared) -- 1523
					end -- 1523
					return ____awaiter_resolve(nil) -- 1523
				end -- 1523
				local compressionRound = round + 1 -- 1527
				AgentUtils.Log( -- 1528
					"Info", -- 1528
					(((("[Memory] Effective input budget reached tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " round=") .. tostring(compressionRound) -- 1528
				) -- 1528
				shared.step = shared.step + 1 -- 1529
				local stepId = shared.step -- 1530
				local pendingMessages = #activeMessages -- 1531
				emitAgentEvent( -- 1532
					shared, -- 1532
					{ -- 1532
						type = "memory_compression_started", -- 1533
						sessionId = shared.sessionId, -- 1534
						taskId = shared.taskId, -- 1535
						step = stepId, -- 1536
						tool = "compress_memory", -- 1537
						reason = getMemoryCompressionStartReason(shared), -- 1538
						params = { -- 1539
							round = compressionRound, -- 1540
							maxRounds = maxRounds, -- 1541
							pendingMessages = pendingMessages, -- 1542
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1543
							uncoveredMessages = #uncoveredMessages, -- 1544
							inputTokens = fitted.originalTokens, -- 1545
							inputBudgetTokens = fitted.budgetTokens -- 1546
						} -- 1546
					} -- 1546
				) -- 1546
				local result = __TS__Await(memory.compressor:compress( -- 1549
					activeMessages, -- 1550
					shared.llmOptions, -- 1551
					shared.llmMaxTry, -- 1552
					shared.decisionMode, -- 1553
					{ -- 1554
						onInput = function(____, phase, messages, options) -- 1555
							saveStepLLMDebugInput( -- 1556
								shared, -- 1556
								stepId, -- 1556
								phase, -- 1556
								messages, -- 1556
								options -- 1556
							) -- 1556
						end, -- 1555
						onOutput = function(____, phase, text, meta) -- 1558
							saveStepLLMDebugOutput( -- 1559
								shared, -- 1559
								stepId, -- 1559
								phase, -- 1559
								text, -- 1559
								meta -- 1559
							) -- 1559
						end, -- 1558
						onUsage = function(____, phase, usage) -- 1561
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1562
						end -- 1561
					}, -- 1561
					"default", -- 1565
					systemPrompt, -- 1566
					toolDefinitions, -- 1567
					decisionActiveMessages -- 1568
				)) -- 1568
				if not (result and result.success and result.compressedCount > 0) then -- 1568
					emitAgentEvent( -- 1571
						shared, -- 1571
						{ -- 1571
							type = "memory_compression_finished", -- 1572
							sessionId = shared.sessionId, -- 1573
							taskId = shared.taskId, -- 1574
							step = stepId, -- 1575
							tool = "compress_memory", -- 1576
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1577
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1581
						} -- 1581
					) -- 1581
					if changed then -- 1581
						persistHistoryState(shared) -- 1589
					end -- 1589
					return ____awaiter_resolve(nil) -- 1589
				end -- 1589
				local effectiveCompressedCount = math.max( -- 1593
					0, -- 1594
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1595
				) -- 1595
				if effectiveCompressedCount <= 0 then -- 1595
					if changed then -- 1595
						persistHistoryState(shared) -- 1599
					end -- 1599
					return ____awaiter_resolve(nil) -- 1599
				end -- 1599
				emitAgentEvent( -- 1603
					shared, -- 1603
					{ -- 1603
						type = "memory_compression_finished", -- 1604
						sessionId = shared.sessionId, -- 1605
						taskId = shared.taskId, -- 1606
						step = stepId, -- 1607
						tool = "compress_memory", -- 1608
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1609
						result = { -- 1610
							success = true, -- 1611
							round = compressionRound, -- 1612
							compressedCount = effectiveCompressedCount, -- 1613
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1614
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1615
						} -- 1615
					} -- 1615
				) -- 1615
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1618
				changed = true -- 1619
				AgentUtils.Log( -- 1620
					"Info", -- 1620
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1620
				) -- 1620
				round = round + 1 -- 1475
			end -- 1475
		end -- 1475
		if changed then -- 1475
			persistHistoryState(shared) -- 1623
		end -- 1623
	end) -- 1623
end -- 1467
local function compactAllHistory(shared) -- 1627
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1627
		local ____shared_40 = shared -- 1628
		local memory = ____shared_40.memory -- 1628
		local rounds = 0 -- 1629
		local totalCompressed = 0 -- 1630
		while getActiveRealMessageCount(shared) > 0 do -- 1630
			if shared.stopToken.stopped then -- 1630
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1633
				return ____awaiter_resolve( -- 1633
					nil, -- 1633
					emitAgentTaskFinishEvent( -- 1634
						shared, -- 1634
						false, -- 1634
						getCancelledReason(shared) -- 1634
					) -- 1634
				) -- 1634
			end -- 1634
			rounds = rounds + 1 -- 1636
			shared.step = shared.step + 1 -- 1637
			local stepId = shared.step -- 1638
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1639
			local pendingMessages = #activeMessages -- 1640
			emitAgentEvent( -- 1641
				shared, -- 1641
				{ -- 1641
					type = "memory_compression_started", -- 1642
					sessionId = shared.sessionId, -- 1643
					taskId = shared.taskId, -- 1644
					step = stepId, -- 1645
					tool = "compress_memory", -- 1646
					reason = getMemoryCompressionStartReason(shared), -- 1647
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1648
				} -- 1648
			) -- 1648
			local result = __TS__Await(memory.compressor:compress( -- 1655
				activeMessages, -- 1656
				shared.llmOptions, -- 1657
				shared.llmMaxTry, -- 1658
				shared.decisionMode, -- 1659
				{ -- 1660
					onInput = function(____, phase, messages, options) -- 1661
						saveStepLLMDebugInput( -- 1662
							shared, -- 1662
							stepId, -- 1662
							phase, -- 1662
							messages, -- 1662
							options -- 1662
						) -- 1662
					end, -- 1661
					onOutput = function(____, phase, text, meta) -- 1664
						saveStepLLMDebugOutput( -- 1665
							shared, -- 1665
							stepId, -- 1665
							phase, -- 1665
							text, -- 1665
							meta -- 1665
						) -- 1665
					end, -- 1664
					onUsage = function(____, phase, usage) -- 1667
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1668
					end -- 1667
				}, -- 1667
				"budget_max" -- 1671
			)) -- 1671
			if not (result and result.success and result.compressedCount > 0) then -- 1671
				emitAgentEvent( -- 1674
					shared, -- 1674
					{ -- 1674
						type = "memory_compression_finished", -- 1675
						sessionId = shared.sessionId, -- 1676
						taskId = shared.taskId, -- 1677
						step = stepId, -- 1678
						tool = "compress_memory", -- 1679
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1680
						result = { -- 1684
							success = false, -- 1685
							rounds = rounds, -- 1686
							error = result and result.error or "compression returned no changes", -- 1687
							compressedCount = result and result.compressedCount or 0, -- 1688
							fullCompaction = true -- 1689
						} -- 1689
					} -- 1689
				) -- 1689
				return ____awaiter_resolve( -- 1689
					nil, -- 1689
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1692
				) -- 1692
			end -- 1692
			local effectiveCompressedCount = math.max( -- 1697
				0, -- 1698
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1699
			) -- 1699
			if effectiveCompressedCount <= 0 then -- 1699
				return ____awaiter_resolve( -- 1699
					nil, -- 1699
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1702
				) -- 1702
			end -- 1702
			emitAgentEvent( -- 1709
				shared, -- 1709
				{ -- 1709
					type = "memory_compression_finished", -- 1710
					sessionId = shared.sessionId, -- 1711
					taskId = shared.taskId, -- 1712
					step = stepId, -- 1713
					tool = "compress_memory", -- 1714
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1715
					result = { -- 1716
						success = true, -- 1717
						round = rounds, -- 1718
						compressedCount = effectiveCompressedCount, -- 1719
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1720
						fullCompaction = true -- 1721
					} -- 1721
				} -- 1721
			) -- 1721
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1724
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1725
			persistHistoryState(shared) -- 1726
			AgentUtils.Log( -- 1727
				"Info", -- 1727
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1727
			) -- 1727
		end -- 1727
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1729
		return ____awaiter_resolve( -- 1729
			nil, -- 1729
			emitAgentTaskFinishEvent( -- 1730
				shared, -- 1731
				true, -- 1732
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1733
			) -- 1733
		) -- 1733
	end) -- 1733
end -- 1627
local function clearSessionHistory(shared) -- 1739
	shared.messages = {} -- 1740
	shared.lastConsolidatedIndex = 0 -- 1741
	shared.carryMessageIndex = nil -- 1742
	persistHistoryState(shared) -- 1743
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1744
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1745
end -- 1739
local function appendConversationMessage(shared, message) -- 1901
	local ____shared_messages_49 = shared.messages -- 1901
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1902
		{}, -- 1902
		message, -- 1903
		{ -- 1902
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1904
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1905
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1906
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1907
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1908
		} -- 1908
	) -- 1908
end -- 1901
local function appendToolResultMessage(shared, action) -- 1917
	appendConversationMessage( -- 1918
		shared, -- 1918
		{ -- 1918
			role = "tool", -- 1919
			tool_call_id = action.toolCallId, -- 1920
			name = action.tool, -- 1921
			content = action.result and toJson(action.result, false) or "" -- 1922
		} -- 1922
	) -- 1922
end -- 1917
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1926
	appendConversationMessage( -- 1932
		shared, -- 1932
		{ -- 1932
			role = "assistant", -- 1933
			content = content or "", -- 1934
			reasoning_content = reasoningContent, -- 1935
			tool_calls = __TS__ArrayMap( -- 1936
				actions, -- 1936
				function(____, action) return { -- 1936
					id = action.toolCallId, -- 1937
					type = "function", -- 1938
					["function"] = { -- 1939
						name = action.tool, -- 1940
						arguments = toJson(action.params, false) -- 1941
					} -- 1941
				} end -- 1941
			) -- 1941
		} -- 1941
	) -- 1941
end -- 1926
local function llm(shared, messages, phase) -- 2125
	if phase == nil then -- 2125
		phase = "decision_xml" -- 2128
	end -- 2128
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2128
		local stepId = shared.step + 1 -- 2130
		emitLLMContextMetrics( -- 2131
			shared, -- 2131
			stepId, -- 2131
			phase, -- 2131
			messages, -- 2131
			shared.llmOptions -- 2131
		) -- 2131
		saveStepLLMDebugInput( -- 2132
			shared, -- 2132
			stepId, -- 2132
			phase, -- 2132
			messages, -- 2132
			shared.llmOptions -- 2132
		) -- 2132
		local lastStreamReasoning = "" -- 2133
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2134
			messages, -- 2135
			shared.llmOptions, -- 2136
			shared.stopToken, -- 2137
			shared.llmConfig, -- 2138
			function(response) -- 2139
				local ____opt_53 = response.choices -- 2139
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2139
				local streamMessage = ____opt_51 and ____opt_51.message -- 2140
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2141
				if nextContent == "" then -- 2141
					return -- 2144
				end -- 2144
				if nextContent == lastStreamReasoning then -- 2144
					return -- 2145
				end -- 2145
				lastStreamReasoning = nextContent -- 2146
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2147
			end -- 2139
		)) -- 2139
		if res.success then -- 2139
			local usage = res.tokenUsage -- 2151
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2152
			local ____opt_59 = res.response.choices -- 2152
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2152
			local message = ____opt_57 and ____opt_57.message -- 2153
			local text = message and message.content -- 2154
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2155
			if text then -- 2155
				local parsed = tryParseAndValidateDecision(text, shared) -- 2159
				if parsed.success then -- 2159
					local reason = parsed.reason or "" -- 2161
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2162
				end -- 2162
				saveStepLLMDebugOutput( -- 2164
					shared, -- 2164
					stepId, -- 2164
					phase, -- 2164
					text, -- 2164
					{success = true, usage = usage} -- 2164
				) -- 2164
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2164
			else -- 2164
				saveStepLLMDebugOutput( -- 2167
					shared, -- 2167
					stepId, -- 2167
					phase, -- 2167
					"empty LLM response", -- 2167
					{success = false, usage = usage} -- 2167
				) -- 2167
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2167
			end -- 2167
		else -- 2167
			local usage = res.tokenUsage -- 2171
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2172
			saveStepLLMDebugOutput( -- 2173
				shared, -- 2173
				stepId, -- 2173
				phase, -- 2173
				res.raw or res.message, -- 2173
				{success = false, usage = usage} -- 2173
			) -- 2173
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2173
		end -- 2173
	end) -- 2173
end -- 2125
local function isDecisionBatchSuccess(result) -- 2197
	return result.kind == "batch" -- 2198
end -- 2197
local function parseDecisionToolCall(functionName, rawObj) -- 2222
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2222
		return {success = false, message = "unknown tool: " .. functionName} -- 2224
	end -- 2224
	if rawObj == nil then -- 2224
		return {success = true, tool = functionName, params = {}} -- 2227
	end -- 2227
	if not isRecord(rawObj) then -- 2227
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2230
	end -- 2230
	return {success = true, tool = functionName, params = rawObj} -- 2232
end -- 2222
local function parseToolCallArguments(functionName, argsText) -- 2239
	local trimmedArgs = __TS__StringTrim(argsText) -- 2240
	if trimmedArgs == "" then -- 2240
		return {} -- 2242
	end -- 2242
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2244
	if err ~= nil or rawObj == nil then -- 2244
		return { -- 2246
			success = false, -- 2247
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2248
			raw = argsText -- 2249
		} -- 2249
	end -- 2249
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2252
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2252
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2254
	end -- 2254
	return rawObj -- 2260
end -- 2239
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2263
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2271
	if isRecord(rawArgs) and rawArgs.success == false then -- 2271
		return rawArgs -- 2273
	end -- 2273
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2275
	if not decision.success then -- 2275
		return {success = false, message = decision.message, raw = argsText} -- 2277
	end -- 2277
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2283
	if not completionValidation.success then -- 2283
		return {success = false, message = completionValidation.message, raw = argsText} -- 2285
	end -- 2285
	local validation = validateDecision(decision.tool, decision.params) -- 2291
	if not validation.success then -- 2291
		return {success = false, message = validation.message, raw = argsText} -- 2293
	end -- 2293
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2299
	if not sharedValidation.success then -- 2299
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2301
	end -- 2301
	decision.params = validation.params -- 2307
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2308
	decision.reason = reason -- 2309
	decision.reasoningContent = reasoningContent -- 2310
	return decision -- 2311
end -- 2263
local function createPreExecutableActionFromStream(shared, toolCall) -- 2314
	local ____opt_65 = toolCall["function"] -- 2314
	local functionName = ____opt_65 and ____opt_65.name -- 2315
	local ____opt_67 = toolCall["function"] -- 2315
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2316
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2317
	if not functionName or not toolCallId then -- 2317
		return nil -- 2318
	end -- 2318
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2319
	if isRecord(rawArgs) and rawArgs.success == false then -- 2319
		return nil -- 2320
	end -- 2320
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2321
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2321
		return nil -- 2322
	end -- 2322
	local validation = validateDecision(decision.tool, decision.params) -- 2323
	if not validation.success then -- 2323
		return nil -- 2324
	end -- 2324
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2324
		return nil -- 2325
	end -- 2325
	return { -- 2326
		step = shared.step + 1, -- 2327
		toolCallId = toolCallId, -- 2328
		tool = decision.tool, -- 2329
		reason = "", -- 2330
		params = validation.params, -- 2331
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2332
	} -- 2332
end -- 2314
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2734
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2743
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2744
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2752
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2753
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2754
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2762
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2770
		shared.role, -- 2770
		{ -- 2770
			includeFinish = true, -- 2771
			includeXmlRules = true, -- 2772
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2773
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2774
			workMode = shared.workMode -- 2775
		} -- 2775
	) -- 2775
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2777
	local repairPrompt = replacePromptVars( -- 2780
		shared.promptPack.xmlDecisionRepairPrompt, -- 2780
		{ -- 2780
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2781
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2782
			CANDIDATE_SECTION = candidateSection, -- 2783
			LAST_ERROR = lastError, -- 2784
			ATTEMPT = tostring(attempt) -- 2785
		} -- 2785
	) -- 2785
	local availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2787
		role = shared.role, -- 2788
		workMode = shared.workMode, -- 2789
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2790
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2791
		resumeRequiredTool = shared.resumeRequiredTool, -- 2792
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2793
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2794
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2795
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2796
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2797
		buildRepairPending = shared.buildRepairPending, -- 2798
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2799
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2800
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2801
	}) -- 2801
	return {{role = "system", content = systemPrompt}, {role = "user", content = (repairPrompt .. "\n\n") .. availabilityPrompt}} -- 2803
end -- 2734
local MainDecisionAgent = __TS__Class() -- 2841
MainDecisionAgent.name = "MainDecisionAgent" -- 2841
__TS__ClassExtends(MainDecisionAgent, Node) -- 2841
function MainDecisionAgent.prototype.prep(self, shared) -- 2842
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2842
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2842
			return ____awaiter_resolve(nil, {shared = shared}) -- 2842
		end -- 2842
		__TS__Await(maybeCompressHistory(shared)) -- 2847
		return ____awaiter_resolve(nil, {shared = shared}) -- 2847
	end) -- 2847
end -- 2842
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2852
	local preExecuted = shared.preExecutedResults -- 2853
	if not preExecuted or preExecuted.size == 0 then -- 2853
		return nil -- 2854
	end -- 2854
	local decisions = {} -- 2855
	preExecuted:forEach(function(____, preResult) -- 2856
		local action = preResult.action -- 2857
		decisions[#decisions + 1] = { -- 2858
			success = true, -- 2859
			tool = action.tool, -- 2860
			params = action.params, -- 2861
			toolCallId = action.toolCallId, -- 2862
			reason = action.reason, -- 2863
			reasoningContent = action.reasoningContent -- 2864
		} -- 2864
	end) -- 2856
	if #decisions == 0 then -- 2856
		return nil -- 2867
	end -- 2867
	AgentUtils.Log( -- 2868
		"Warn", -- 2868
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2868
			__TS__ArrayMap( -- 2868
				decisions, -- 2868
				function(____, decision) return decision.tool end -- 2868
			), -- 2868
			"," -- 2868
		) -- 2868
	) -- 2868
	if #decisions == 1 then -- 2868
		return decisions[1] -- 2870
	end -- 2870
	return {success = true, kind = "batch", decisions = decisions} -- 2872
end -- 2852
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2879
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2884
	if not recovery then -- 2884
		return nil -- 2885
	end -- 2885
	shared.truncatedToolOverwritePath = recovery.target -- 2886
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2887
	return { -- 2888
		success = true, -- 2889
		tool = "edit_file", -- 2890
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2891
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2897
		reason = recovery.reason, -- 2898
		reasoningContent = reasoningContent -- 2899
	} -- 2899
end -- 2879
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2903
	if attempt == nil then -- 2903
		attempt = 1 -- 2906
	end -- 2906
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2906
		if shared.stopToken.stopped then -- 2906
			return ____awaiter_resolve( -- 2906
				nil, -- 2906
				{ -- 2910
					success = false, -- 2910
					message = getCancelledReason(shared) -- 2910
				} -- 2910
			) -- 2910
		end -- 2910
		AgentUtils.Log( -- 2912
			"Info", -- 2912
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2912
		) -- 2912
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2913
			shared.role, -- 2913
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2913
			{ -- 2913
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2914
				workMode = shared.workMode -- 2915
			} -- 2915
		) -- 2915
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2917
		local stepId = shared.step + 1 -- 2918
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2919
			string.lower(shared.llmConfig.model), -- 2919
			"glm-5.2" -- 2919
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2919
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2922
		emitLLMContextMetrics( -- 2927
			shared, -- 2927
			stepId, -- 2927
			"decision_tool_calling", -- 2927
			messages, -- 2927
			llmOptions -- 2927
		) -- 2927
		saveStepLLMDebugInput( -- 2928
			shared, -- 2928
			stepId, -- 2928
			"decision_tool_calling", -- 2928
			messages, -- 2928
			llmOptions -- 2928
		) -- 2928
		local lastStreamContent = "" -- 2929
		local lastStreamReasoning = "" -- 2930
		local preExecutedResults = __TS__New(Map) -- 2931
		shared.preExecutedResults = preExecutedResults -- 2932
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2933
			messages, -- 2934
			llmOptions, -- 2935
			shared.stopToken, -- 2936
			shared.llmConfig, -- 2937
			function(response) -- 2938
				local ____opt_75 = response.choices -- 2938
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2938
				local streamMessage = ____opt_73 and ____opt_73.message -- 2939
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2940
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2943
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2943
					return -- 2947
				end -- 2947
				lastStreamContent = nextContent -- 2949
				lastStreamReasoning = nextReasoning -- 2950
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2951
			end, -- 2938
			function(tc) -- 2953
				if shared.stopToken.stopped then -- 2953
					return -- 2954
				end -- 2954
				local action = createPreExecutableActionFromStream(shared, tc) -- 2955
				if not action or preExecutedResults:has(action.toolCallId) then -- 2955
					return -- 2956
				end -- 2956
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2957
				preExecutedResults:set( -- 2958
					action.toolCallId, -- 2958
					createPreExecutedToolResult(shared, action) -- 2958
				) -- 2958
			end -- 2953
		)) -- 2953
		if shared.stopToken.stopped then -- 2953
			clearPreExecutedResults(shared) -- 2962
			return ____awaiter_resolve( -- 2962
				nil, -- 2962
				{ -- 2963
					success = false, -- 2963
					message = getCancelledReason(shared) -- 2963
				} -- 2963
			) -- 2963
		end -- 2963
		if not res.success then -- 2963
			local usage = res.tokenUsage -- 2966
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2967
			saveStepLLMDebugOutput( -- 2968
				shared, -- 2968
				stepId, -- 2968
				"decision_tool_calling", -- 2968
				res.raw or res.message, -- 2968
				{success = false, usage = usage} -- 2968
			) -- 2968
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2969
			local committed = self:commitPreExecutedDecision(shared) -- 2970
			if committed then -- 2970
				return ____awaiter_resolve(nil, committed) -- 2970
			end -- 2970
			local ____opt_83 = res.response -- 2970
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2970
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2972
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 2973
			local ____shared_93 = shared -- 2974
			local ____opt_85 = partialChoice and partialChoice.message -- 2974
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 2975
			local ____opt_89 = partialChoice and partialChoice.message -- 2975
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 2973
			if partialDraft then -- 2973
				return ____awaiter_resolve(nil, partialDraft) -- 2973
			end -- 2973
			clearPreExecutedResults(shared) -- 2979
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2979
		end -- 2979
		local usage = res.tokenUsage -- 2982
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2983
		saveStepLLMDebugOutput( -- 2984
			shared, -- 2984
			stepId, -- 2984
			"decision_tool_calling", -- 2984
			encodeDebugJSON(res.response), -- 2984
			{success = true, usage = usage} -- 2984
		) -- 2984
		local choice = res.response.choices and res.response.choices[1] -- 2985
		local message = choice and choice.message -- 2986
		local toolCalls = message and message.tool_calls -- 2987
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2988
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2991
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2994
		AgentUtils.Log( -- 2997
			"Info", -- 2997
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2997
		) -- 2997
		if finishReason == "length" then -- 2997
			local committed = self:commitPreExecutedDecision(shared) -- 2999
			if committed then -- 2999
				return ____awaiter_resolve(nil, committed) -- 2999
			end -- 2999
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3001
			if partialDraft then -- 3001
				return ____awaiter_resolve(nil, partialDraft) -- 3001
			end -- 3001
			AgentUtils.Log( -- 3003
				"Error", -- 3003
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3003
			) -- 3003
			clearPreExecutedResults(shared) -- 3004
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3004
		end -- 3004
		if not toolCalls or #toolCalls == 0 then -- 3004
			if messageContent and messageContent ~= "" then -- 3004
				if isFinalDecisionTurn(shared) then -- 3004
					clearPreExecutedResults(shared) -- 3014
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3014
				end -- 3014
				if shared.role == "sub" then -- 3014
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3022
					clearPreExecutedResults(shared) -- 3023
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3023
				end -- 3023
				AgentUtils.Log( -- 3030
					"Info", -- 3030
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3030
				) -- 3030
				clearPreExecutedResults(shared) -- 3031
				return ____awaiter_resolve(nil, { -- 3031
					success = true, -- 3033
					tool = "finish", -- 3034
					params = {}, -- 3035
					reason = messageContent, -- 3036
					reasoningContent = reasoningContent, -- 3037
					directSummary = messageContent -- 3038
				}) -- 3038
			end -- 3038
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3041
			clearPreExecutedResults(shared) -- 3042
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3042
		end -- 3042
		local decisions = {} -- 3049
		do -- 3049
			local i = 0 -- 3050
			while i < #toolCalls do -- 3050
				local toolCall = toolCalls[i + 1] -- 3051
				local fn = toolCall ~= nil and toolCall["function"] -- 3052
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3052
					AgentUtils.Log( -- 3054
						"Error", -- 3054
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3054
					) -- 3054
					clearPreExecutedResults(shared) -- 3055
					return ____awaiter_resolve( -- 3055
						nil, -- 3055
						{ -- 3056
							success = false, -- 3057
							message = "missing function name for tool call " .. tostring(i + 1), -- 3058
							raw = messageContent -- 3059
						} -- 3059
					) -- 3059
				end -- 3059
				local functionName = fn.name -- 3062
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3063
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3064
				AgentUtils.Log( -- 3067
					"Info", -- 3067
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3067
				) -- 3067
				local decision = parseAndValidateToolCallDecision( -- 3068
					shared, -- 3069
					functionName, -- 3070
					argsText, -- 3071
					toolCallId, -- 3072
					messageContent, -- 3073
					reasoningContent -- 3074
				) -- 3074
				if not decision.success then -- 3074
					AgentUtils.Log( -- 3077
						"Error", -- 3077
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3077
					) -- 3077
					clearPreExecutedResults(shared) -- 3078
					return ____awaiter_resolve(nil, decision) -- 3078
				end -- 3078
				decisions[#decisions + 1] = decision -- 3081
				i = i + 1 -- 3050
			end -- 3050
		end -- 3050
		if #decisions == 1 then -- 3050
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3084
			return ____awaiter_resolve(nil, decisions[1]) -- 3084
		end -- 3084
		do -- 3084
			local i = 0 -- 3087
			while i < #decisions do -- 3087
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3087
					clearPreExecutedResults(shared) -- 3089
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3089
				end -- 3089
				i = i + 1 -- 3087
			end -- 3087
		end -- 3087
		AgentUtils.Log( -- 3097
			"Info", -- 3097
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3097
				__TS__ArrayMap( -- 3097
					decisions, -- 3097
					function(____, decision) return decision.tool end -- 3097
				), -- 3097
				"," -- 3097
			) -- 3097
		) -- 3097
		return ____awaiter_resolve(nil, { -- 3097
			success = true, -- 3099
			kind = "batch", -- 3100
			decisions = decisions, -- 3101
			content = messageContent, -- 3102
			reasoningContent = reasoningContent -- 3103
		}) -- 3103
	end) -- 3103
end -- 2903
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3107
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3107
		AgentUtils.Log( -- 3113
			"Info", -- 3113
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3113
		) -- 3113
		local lastError = initialError -- 3114
		local candidateRaw = "" -- 3115
		local candidateReasoning = nil -- 3116
		do -- 3116
			local attempt = 0 -- 3117
			while attempt < shared.llmMaxTry do -- 3117
				do -- 3117
					AgentUtils.Log( -- 3118
						"Info", -- 3118
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3118
					) -- 3118
					local messages = buildXmlRepairMessages( -- 3119
						shared, -- 3120
						originalRaw, -- 3121
						originalReasoning, -- 3122
						candidateRaw, -- 3123
						candidateReasoning, -- 3124
						lastError, -- 3125
						attempt + 1 -- 3126
					) -- 3126
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3128
					if shared.stopToken.stopped then -- 3128
						return ____awaiter_resolve( -- 3128
							nil, -- 3128
							{ -- 3130
								success = false, -- 3130
								message = getCancelledReason(shared) -- 3130
							} -- 3130
						) -- 3130
					end -- 3130
					if not llmRes.success then -- 3130
						lastError = llmRes.message -- 3133
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3134
						goto __continue522 -- 3135
					end -- 3135
					candidateRaw = llmRes.text -- 3137
					candidateReasoning = llmRes.reasoningContent -- 3138
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3139
					if decision.success then -- 3139
						decision.reasoningContent = llmRes.reasoningContent -- 3141
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3142
						return ____awaiter_resolve(nil, decision) -- 3142
					end -- 3142
					lastError = decision.message -- 3145
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3146
				end -- 3146
				::__continue522:: -- 3146
				attempt = attempt + 1 -- 3117
			end -- 3117
		end -- 3117
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3148
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3148
	end) -- 3148
end -- 3107
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3156
	if attempt == nil then -- 3156
		attempt = 1 -- 3159
	end -- 3159
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3159
		local messages = buildDecisionMessages( -- 3162
			shared, -- 3163
			lastError, -- 3164
			attempt, -- 3165
			lastRaw, -- 3166
			"xml" -- 3167
		) -- 3167
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3169
		if shared.stopToken.stopped then -- 3169
			return ____awaiter_resolve( -- 3169
				nil, -- 3169
				{ -- 3171
					success = false, -- 3171
					message = getCancelledReason(shared) -- 3171
				} -- 3171
			) -- 3171
		end -- 3171
		if not llmRes.success then -- 3171
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3171
		end -- 3171
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3180
		if decision.success then -- 3180
			decision.reasoningContent = llmRes.reasoningContent -- 3182
			return ____awaiter_resolve(nil, decision) -- 3182
		end -- 3182
		return ____awaiter_resolve( -- 3182
			nil, -- 3182
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3185
		) -- 3185
	end) -- 3185
end -- 3156
function MainDecisionAgent.prototype.exec(self, input) -- 3188
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3188
		local shared = input.shared -- 3189
		if shared.stopToken.stopped then -- 3189
			return ____awaiter_resolve( -- 3189
				nil, -- 3189
				{ -- 3191
					success = false, -- 3191
					message = getCancelledReason(shared) -- 3191
				} -- 3191
			) -- 3191
		end -- 3191
		if shared.step >= shared.maxSteps then -- 3191
			AgentUtils.Log( -- 3194
				"Warn", -- 3194
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3194
			) -- 3194
			return ____awaiter_resolve( -- 3194
				nil, -- 3194
				{ -- 3195
					success = false, -- 3195
					message = getMaxStepsReachedReason(shared) -- 3195
				} -- 3195
			) -- 3195
		end -- 3195
		if shared.decisionMode == "tool_calling" then -- 3195
			AgentUtils.Log( -- 3199
				"Info", -- 3199
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3199
			) -- 3199
			local lastError = "tool calling validation failed" -- 3200
			local lastRaw = "" -- 3201
			local shouldFallbackToXml = false -- 3202
			do -- 3202
				local attempt = 0 -- 3203
				while attempt < shared.llmMaxTry do -- 3203
					AgentUtils.Log( -- 3204
						"Info", -- 3204
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3204
					) -- 3204
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3205
					if shared.stopToken.stopped then -- 3205
						return ____awaiter_resolve( -- 3205
							nil, -- 3205
							{ -- 3212
								success = false, -- 3212
								message = getCancelledReason(shared) -- 3212
							} -- 3212
						) -- 3212
					end -- 3212
					if decision.success then -- 3212
						return ____awaiter_resolve(nil, decision) -- 3212
					end -- 3212
					lastError = decision.message -- 3217
					lastRaw = decision.raw or "" -- 3218
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3219
					if lastError == "missing tool call" then -- 3219
						shouldFallbackToXml = true -- 3221
						break -- 3222
					end -- 3222
					attempt = attempt + 1 -- 3203
				end -- 3203
			end -- 3203
			if shouldFallbackToXml then -- 3203
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3226
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3227
				do -- 3227
					local attempt = 0 -- 3228
					while attempt < shared.llmMaxTry do -- 3228
						AgentUtils.Log( -- 3229
							"Info", -- 3229
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3229
						) -- 3229
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3230
						if shared.stopToken.stopped then -- 3230
							return ____awaiter_resolve( -- 3230
								nil, -- 3230
								{ -- 3237
									success = false, -- 3237
									message = getCancelledReason(shared) -- 3237
								} -- 3237
							) -- 3237
						end -- 3237
						if decision.success then -- 3237
							return ____awaiter_resolve(nil, decision) -- 3237
						end -- 3237
						lastError = decision.message -- 3242
						lastRaw = decision.raw or "" -- 3243
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3244
						attempt = attempt + 1 -- 3228
					end -- 3228
				end -- 3228
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3246
				return ____awaiter_resolve( -- 3246
					nil, -- 3246
					{ -- 3247
						success = false, -- 3247
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3247
					} -- 3247
				) -- 3247
			end -- 3247
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3249
			return ____awaiter_resolve( -- 3249
				nil, -- 3249
				{ -- 3250
					success = false, -- 3250
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3250
				} -- 3250
			) -- 3250
		end -- 3250
		local lastError = "xml validation failed" -- 3253
		local lastRaw = "" -- 3254
		do -- 3254
			local attempt = 0 -- 3255
			while attempt < shared.llmMaxTry do -- 3255
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3256
				if shared.stopToken.stopped then -- 3256
					return ____awaiter_resolve( -- 3256
						nil, -- 3256
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
				attempt = attempt + 1 -- 3255
			end -- 3255
		end -- 3255
		return ____awaiter_resolve( -- 3255
			nil, -- 3255
			{ -- 3273
				success = false, -- 3273
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3273
			} -- 3273
		) -- 3273
	end) -- 3273
end -- 3188
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3276
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3276
		local result = execRes -- 3277
		if not result.success then -- 3277
			if shared.stopToken.stopped then -- 3277
				shared.error = getCancelledReason(shared) -- 3280
				shared.done = true -- 3281
				return ____awaiter_resolve(nil, "done") -- 3281
			end -- 3281
			shared.error = result.message -- 3284
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3285
			shared.done = true -- 3286
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3287
			persistHistoryState(shared) -- 3291
			return ____awaiter_resolve(nil, "done") -- 3291
		end -- 3291
		if isDecisionBatchSuccess(result) then -- 3291
			local startStep = shared.step -- 3295
			local actions = {} -- 3296
			do -- 3296
				local i = 0 -- 3297
				while i < #result.decisions do -- 3297
					local decision = result.decisions[i + 1] -- 3298
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3299
					local step = startStep + i + 1 -- 3300
					local ____temp_96 -- 3301
					if i == 0 then -- 3301
						____temp_96 = decision.reason -- 3301
					else -- 3301
						____temp_96 = "" -- 3301
					end -- 3301
					local actionReason = ____temp_96 -- 3301
					local ____temp_97 -- 3302
					if i == 0 then -- 3302
						____temp_97 = decision.reasoningContent -- 3302
					else -- 3302
						____temp_97 = nil -- 3302
					end -- 3302
					local actionReasoningContent = ____temp_97 -- 3302
					emitAgentEvent(shared, { -- 3303
						type = "decision_made", -- 3304
						sessionId = shared.sessionId, -- 3305
						taskId = shared.taskId, -- 3306
						step = step, -- 3307
						tool = decision.tool, -- 3308
						reason = actionReason, -- 3309
						reasoningContent = actionReasoningContent, -- 3310
						params = decision.params -- 3311
					}) -- 3311
					local action = { -- 3313
						step = step, -- 3314
						toolCallId = toolCallId, -- 3315
						tool = decision.tool, -- 3316
						reason = actionReason or "", -- 3317
						reasoningContent = actionReasoningContent, -- 3318
						params = decision.params, -- 3319
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3320
					} -- 3320
					local ____shared_history_98 = shared.history -- 3320
					____shared_history_98[#____shared_history_98 + 1] = action -- 3322
					actions[#actions + 1] = action -- 3323
					i = i + 1 -- 3297
				end -- 3297
			end -- 3297
			shared.step = startStep + #actions -- 3325
			shared.pendingToolActions = actions -- 3326
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3327
			persistHistoryState(shared) -- 3333
			return ____awaiter_resolve(nil, "batch_tools") -- 3333
		end -- 3333
		if result.directSummary and result.directSummary ~= "" then -- 3333
			shared.response = result.directSummary -- 3337
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3338
			shared.done = true -- 3342
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3343
			persistHistoryState(shared) -- 3348
			return ____awaiter_resolve(nil, "done") -- 3348
		end -- 3348
		if result.tool == "finish" then -- 3348
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3352
			shared.response = finalMessage -- 3353
			shared.completion = getCompletionReport(result.params) -- 3354
			shared.done = true -- 3355
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3356
			persistHistoryState(shared) -- 3361
			return ____awaiter_resolve(nil, "done") -- 3361
		end -- 3361
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3364
		shared.step = shared.step + 1 -- 3365
		local step = shared.step -- 3366
		emitAgentEvent(shared, { -- 3367
			type = "decision_made", -- 3368
			sessionId = shared.sessionId, -- 3369
			taskId = shared.taskId, -- 3370
			step = step, -- 3371
			tool = result.tool, -- 3372
			reason = result.reason, -- 3373
			reasoningContent = result.reasoningContent, -- 3374
			params = result.params -- 3375
		}) -- 3375
		local ____shared_history_99 = shared.history -- 3375
		____shared_history_99[#____shared_history_99 + 1] = { -- 3377
			step = step, -- 3378
			toolCallId = toolCallId, -- 3379
			tool = result.tool, -- 3380
			reason = result.reason or "", -- 3381
			reasoningContent = result.reasoningContent, -- 3382
			params = result.params, -- 3383
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3384
		} -- 3384
		local action = shared.history[#shared.history] -- 3386
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3387
		shared.pendingToolActions = {action} -- 3390
		persistHistoryState(shared) -- 3391
		return ____awaiter_resolve(nil, "batch_tools") -- 3391
	end) -- 3391
end -- 3276
local ReadFileAction = __TS__Class() -- 3396
ReadFileAction.name = "ReadFileAction" -- 3396
__TS__ClassExtends(ReadFileAction, Node) -- 3396
function ReadFileAction.prototype.prep(self, shared) -- 3397
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3397
		local last = shared.history[#shared.history] -- 3398
		if not last then -- 3398
			error( -- 3399
				__TS__New(Error, "no history"), -- 3399
				0 -- 3399
			) -- 3399
		end -- 3399
		emitAgentStartEvent(shared, last) -- 3400
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3401
		if __TS__StringTrim(path) == "" then -- 3401
			error( -- 3404
				__TS__New(Error, "missing path"), -- 3404
				0 -- 3404
			) -- 3404
		end -- 3404
		local ____path_102 = path -- 3406
		local ____shared_workingDir_103 = shared.workingDir -- 3408
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3409
		local ____last_params_startLine_100 = last.params.startLine -- 3410
		if ____last_params_startLine_100 == nil then -- 3410
			____last_params_startLine_100 = 1 -- 3410
		end -- 3410
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3410
		local ____last_params_endLine_101 = last.params.endLine -- 3411
		if ____last_params_endLine_101 == nil then -- 3411
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3411
		end -- 3411
		return ____awaiter_resolve( -- 3411
			nil, -- 3411
			{ -- 3405
				path = ____path_102, -- 3406
				tool = "read_file", -- 3407
				workDir = ____shared_workingDir_103, -- 3408
				docLanguage = ____temp_104, -- 3409
				startLine = ____TS__Number_result_105, -- 3410
				endLine = __TS__Number(____last_params_endLine_101) -- 3411
			} -- 3411
		) -- 3411
	end) -- 3411
end -- 3397
function ReadFileAction.prototype.exec(self, input) -- 3415
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3415
		return ____awaiter_resolve( -- 3415
			nil, -- 3415
			Tools.readFile( -- 3416
				input.workDir, -- 3417
				input.path, -- 3418
				__TS__Number(input.startLine or 1), -- 3419
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3420
				input.docLanguage -- 3421
			) -- 3421
		) -- 3421
	end) -- 3421
end -- 3415
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3425
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3425
		local result = execRes -- 3426
		local last = shared.history[#shared.history] -- 3427
		if last ~= nil then -- 3427
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3429
			appendToolResultMessage(shared, last) -- 3430
			emitAgentFinishEvent(shared, last) -- 3431
		end -- 3431
		persistHistoryState(shared) -- 3433
		__TS__Await(maybeCompressHistory(shared)) -- 3434
		persistHistoryState(shared) -- 3435
		return ____awaiter_resolve(nil, "main") -- 3435
	end) -- 3435
end -- 3425
local SearchFilesAction = __TS__Class() -- 3440
SearchFilesAction.name = "SearchFilesAction" -- 3440
__TS__ClassExtends(SearchFilesAction, Node) -- 3440
function SearchFilesAction.prototype.prep(self, shared) -- 3441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3441
		local last = shared.history[#shared.history] -- 3442
		if not last then -- 3442
			error( -- 3443
				__TS__New(Error, "no history"), -- 3443
				0 -- 3443
			) -- 3443
		end -- 3443
		emitAgentStartEvent(shared, last) -- 3444
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3444
	end) -- 3444
end -- 3441
function SearchFilesAction.prototype.exec(self, input) -- 3448
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3448
		local params = input.params -- 3449
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3450
		local ____input_workDir_112 = input.workDir -- 3451
		local ____temp_113 = params.path or "" -- 3452
		local ____temp_114 = params.pattern or "" -- 3453
		local ____params_globs_115 = params.globs -- 3454
		local ____params_useRegex_116 = params.useRegex -- 3455
		local ____params_caseSensitive_117 = params.caseSensitive -- 3456
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3458
		local ____math_max_108 = math.max -- 3459
		local ____math_floor_107 = math.floor -- 3459
		local ____params_limit_106 = params.limit -- 3459
		if ____params_limit_106 == nil then -- 3459
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3459
		end -- 3459
		local ____math_max_108_result_119 = ____math_max_108( -- 3459
			1, -- 3459
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3459
		) -- 3459
		local ____math_max_111 = math.max -- 3460
		local ____math_floor_110 = math.floor -- 3460
		local ____params_offset_109 = params.offset -- 3460
		if ____params_offset_109 == nil then -- 3460
			____params_offset_109 = 0 -- 3460
		end -- 3460
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3450
			workDir = ____input_workDir_112, -- 3451
			path = ____temp_113, -- 3452
			pattern = ____temp_114, -- 3453
			globs = ____params_globs_115, -- 3454
			useRegex = ____params_useRegex_116, -- 3455
			caseSensitive = ____params_caseSensitive_117, -- 3456
			includeContent = true, -- 3457
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3458
			limit = ____math_max_108_result_119, -- 3459
			offset = ____math_max_111( -- 3460
				0, -- 3460
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3460
			), -- 3460
			groupByFile = params.groupByFile == true -- 3461
		})) -- 3461
		return ____awaiter_resolve(nil, result) -- 3461
	end) -- 3461
end -- 3448
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3466
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3466
		local last = shared.history[#shared.history] -- 3467
		if last ~= nil then -- 3467
			local result = execRes -- 3469
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3470
			appendToolResultMessage(shared, last) -- 3471
			emitAgentFinishEvent(shared, last) -- 3472
		end -- 3472
		persistHistoryState(shared) -- 3474
		__TS__Await(maybeCompressHistory(shared)) -- 3475
		persistHistoryState(shared) -- 3476
		return ____awaiter_resolve(nil, "main") -- 3476
	end) -- 3476
end -- 3466
local SearchDoraAPIAction = __TS__Class() -- 3481
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3481
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3481
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3482
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3482
		local last = shared.history[#shared.history] -- 3483
		if not last then -- 3483
			error( -- 3484
				__TS__New(Error, "no history"), -- 3484
				0 -- 3484
			) -- 3484
		end -- 3484
		emitAgentStartEvent(shared, last) -- 3485
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3485
	end) -- 3485
end -- 3482
function SearchDoraAPIAction.prototype.exec(self, input) -- 3489
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3489
		local params = input.params -- 3490
		local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3491
		local ____temp_125 = params.pattern or "" -- 3492
		local ____temp_126 = params.docSource or "api" -- 3493
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3494
		local ____temp_128 = params.programmingLanguage or "ts" -- 3495
		local ____math_min_124 = math.min -- 3496
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3496
		local ____math_max_122 = math.max -- 3496
		local ____params_limit_121 = params.limit -- 3496
		if ____params_limit_121 == nil then -- 3496
			____params_limit_121 = 8 -- 3496
		end -- 3496
		local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3491
			pattern = ____temp_125, -- 3492
			docSource = ____temp_126, -- 3493
			docLanguage = ____temp_127, -- 3494
			programmingLanguage = ____temp_128, -- 3495
			limit = ____math_min_124( -- 3496
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123, -- 3496
				____math_max_122( -- 3496
					1, -- 3496
					__TS__Number(____params_limit_121) -- 3496
				) -- 3496
			), -- 3496
			useRegex = params.useRegex, -- 3497
			caseSensitive = false, -- 3498
			includeContent = true, -- 3499
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3500
		})) -- 3500
		return ____awaiter_resolve(nil, result) -- 3500
	end) -- 3500
end -- 3489
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3505
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3505
		local last = shared.history[#shared.history] -- 3506
		if last ~= nil then -- 3506
			local result = execRes -- 3508
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3509
			appendToolResultMessage(shared, last) -- 3510
			emitAgentFinishEvent(shared, last) -- 3511
		end -- 3511
		persistHistoryState(shared) -- 3513
		__TS__Await(maybeCompressHistory(shared)) -- 3514
		persistHistoryState(shared) -- 3515
		return ____awaiter_resolve(nil, "main") -- 3515
	end) -- 3515
end -- 3505
local ListFilesAction = __TS__Class() -- 3520
ListFilesAction.name = "ListFilesAction" -- 3520
__TS__ClassExtends(ListFilesAction, Node) -- 3520
function ListFilesAction.prototype.prep(self, shared) -- 3521
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3521
		local last = shared.history[#shared.history] -- 3522
		if not last then -- 3522
			error( -- 3523
				__TS__New(Error, "no history"), -- 3523
				0 -- 3523
			) -- 3523
		end -- 3523
		emitAgentStartEvent(shared, last) -- 3524
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3524
	end) -- 3524
end -- 3521
function ListFilesAction.prototype.exec(self, input) -- 3528
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3528
		local params = input.params -- 3529
		local ____Tools_listFiles_136 = Tools.listFiles -- 3530
		local ____input_workDir_133 = input.workDir -- 3531
		local ____temp_134 = params.path or "" -- 3532
		local ____params_globs_135 = params.globs -- 3533
		local ____math_max_132 = math.max -- 3534
		local ____math_floor_131 = math.floor -- 3534
		local ____params_maxEntries_130 = params.maxEntries -- 3534
		if ____params_maxEntries_130 == nil then -- 3534
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3534
		end -- 3534
		local result = ____Tools_listFiles_136({ -- 3530
			workDir = ____input_workDir_133, -- 3531
			path = ____temp_134, -- 3532
			globs = ____params_globs_135, -- 3533
			maxEntries = ____math_max_132( -- 3534
				1, -- 3534
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3534
			) -- 3534
		}) -- 3534
		return ____awaiter_resolve(nil, result) -- 3534
	end) -- 3534
end -- 3528
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3539
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3539
		local last = shared.history[#shared.history] -- 3540
		if last ~= nil then -- 3540
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3542
			appendToolResultMessage(shared, last) -- 3543
			emitAgentFinishEvent(shared, last) -- 3544
		end -- 3544
		persistHistoryState(shared) -- 3546
		__TS__Await(maybeCompressHistory(shared)) -- 3547
		persistHistoryState(shared) -- 3548
		return ____awaiter_resolve(nil, "main") -- 3548
	end) -- 3548
end -- 3539
local DeleteFileAction = __TS__Class() -- 3553
DeleteFileAction.name = "DeleteFileAction" -- 3553
__TS__ClassExtends(DeleteFileAction, Node) -- 3553
function DeleteFileAction.prototype.prep(self, shared) -- 3554
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3554
		local last = shared.history[#shared.history] -- 3555
		if not last then -- 3555
			error( -- 3556
				__TS__New(Error, "no history"), -- 3556
				0 -- 3556
			) -- 3556
		end -- 3556
		emitAgentStartEvent(shared, last) -- 3557
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3558
		if __TS__StringTrim(targetFile) == "" then -- 3558
			error( -- 3561
				__TS__New(Error, "missing target_file"), -- 3561
				0 -- 3561
			) -- 3561
		end -- 3561
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3561
	end) -- 3561
end -- 3554
function DeleteFileAction.prototype.exec(self, input) -- 3565
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3565
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3566
		if not result.success then -- 3566
			return ____awaiter_resolve(nil, result) -- 3566
		end -- 3566
		return ____awaiter_resolve(nil, { -- 3566
			success = true, -- 3574
			changed = true, -- 3575
			mode = "delete", -- 3576
			checkpointId = result.checkpointId, -- 3577
			checkpointSeq = result.checkpointSeq, -- 3578
			files = {{path = input.targetFile, op = "delete"}} -- 3579
		}) -- 3579
	end) -- 3579
end -- 3565
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3583
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3583
		local last = shared.history[#shared.history] -- 3584
		if last ~= nil then -- 3584
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3586
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3587
			appendToolResultMessage(shared, last) -- 3588
			emitAgentFinishEvent(shared, last) -- 3589
			local result = last.result -- 3590
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3590
				emitAgentEvent(shared, { -- 3595
					type = "checkpoint_created", -- 3596
					sessionId = shared.sessionId, -- 3597
					taskId = shared.taskId, -- 3598
					step = last.step, -- 3599
					tool = "delete_file", -- 3600
					checkpointId = result.checkpointId, -- 3601
					checkpointSeq = result.checkpointSeq, -- 3602
					files = result.files -- 3603
				}) -- 3603
			end -- 3603
		end -- 3603
		persistHistoryState(shared) -- 3610
		__TS__Await(maybeCompressHistory(shared)) -- 3611
		persistHistoryState(shared) -- 3612
		return ____awaiter_resolve(nil, "main") -- 3612
	end) -- 3612
end -- 3583
local BuildAction = __TS__Class() -- 3617
BuildAction.name = "BuildAction" -- 3617
__TS__ClassExtends(BuildAction, Node) -- 3617
function BuildAction.prototype.prep(self, shared) -- 3618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3618
		local last = shared.history[#shared.history] -- 3619
		if not last then -- 3619
			error( -- 3620
				__TS__New(Error, "no history"), -- 3620
				0 -- 3620
			) -- 3620
		end -- 3620
		emitAgentStartEvent(shared, last) -- 3621
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3621
	end) -- 3621
end -- 3618
function BuildAction.prototype.exec(self, input) -- 3625
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3625
		local params = input.params -- 3626
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3627
		return ____awaiter_resolve(nil, result) -- 3627
	end) -- 3627
end -- 3625
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3634
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3634
		local last = shared.history[#shared.history] -- 3635
		if last ~= nil then -- 3635
			last.result = sanitizeBuildResultForHistory(execRes) -- 3637
			appendToolResultMessage(shared, last) -- 3638
			emitAgentFinishEvent(shared, last) -- 3639
		end -- 3639
		persistHistoryState(shared) -- 3641
		__TS__Await(maybeCompressHistory(shared)) -- 3642
		persistHistoryState(shared) -- 3643
		return ____awaiter_resolve(nil, "main") -- 3643
	end) -- 3643
end -- 3634
local SpawnSubAgentAction = __TS__Class() -- 3648
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3648
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3648
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3649
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3649
		local last = shared.history[#shared.history] -- 3659
		if not last then -- 3659
			error( -- 3660
				__TS__New(Error, "no history"), -- 3660
				0 -- 3660
			) -- 3660
		end -- 3660
		emitAgentStartEvent(shared, last) -- 3661
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3662
			last.params.filesHint, -- 3663
			function(____, item) return type(item) == "string" end -- 3663
		) or nil -- 3663
		return ____awaiter_resolve( -- 3663
			nil, -- 3663
			{ -- 3665
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3666
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3667
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3668
				filesHint = filesHint, -- 3669
				sessionId = shared.sessionId, -- 3670
				projectRoot = shared.workingDir, -- 3671
				spawnSubAgent = shared.spawnSubAgent, -- 3672
				disabledAgentTools = shared.disabledAgentTools -- 3673
			} -- 3673
		) -- 3673
	end) -- 3673
end -- 3649
function SpawnSubAgentAction.prototype.exec(self, input) -- 3677
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3677
		if not input.spawnSubAgent then -- 3677
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3677
		end -- 3677
		if input.sessionId == nil or input.sessionId <= 0 then -- 3677
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3677
		end -- 3677
		local ____AgentUtils_Log_142 = AgentUtils.Log -- 3693
		local ____temp_139 = #input.title -- 3693
		local ____temp_140 = #input.prompt -- 3693
		local ____temp_141 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3693
		local ____opt_137 = input.filesHint -- 3693
		____AgentUtils_Log_142( -- 3693
			"Info", -- 3693
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_139)) .. " prompt_len=") .. tostring(____temp_140)) .. " expected_len=") .. tostring(____temp_141)) .. " files_hint_count=") .. tostring(____opt_137 and #____opt_137 or 0) -- 3693
		) -- 3693
		local result = __TS__Await(input.spawnSubAgent({ -- 3694
			parentSessionId = input.sessionId, -- 3695
			projectRoot = input.projectRoot, -- 3696
			title = input.title, -- 3697
			prompt = input.prompt, -- 3698
			expectedOutput = input.expectedOutput, -- 3699
			filesHint = input.filesHint, -- 3700
			disabledAgentTools = input.disabledAgentTools -- 3701
		})) -- 3701
		if not result.success then -- 3701
			return ____awaiter_resolve(nil, result) -- 3701
		end -- 3701
		return ____awaiter_resolve(nil, { -- 3701
			success = true, -- 3707
			sessionId = result.sessionId, -- 3708
			taskId = result.taskId, -- 3709
			title = result.title, -- 3710
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3711
		}) -- 3711
	end) -- 3711
end -- 3677
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3715
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3715
		local last = shared.history[#shared.history] -- 3716
		if last ~= nil then -- 3716
			last.result = execRes -- 3718
			if execRes.success == true then -- 3718
				shared.hasSpawnedSubAgentThisTask = true -- 3720
			end -- 3720
			appendToolResultMessage(shared, last) -- 3722
			emitAgentFinishEvent(shared, last) -- 3723
		end -- 3723
		persistHistoryState(shared) -- 3725
		__TS__Await(maybeCompressHistory(shared)) -- 3726
		persistHistoryState(shared) -- 3727
		return ____awaiter_resolve(nil, "main") -- 3727
	end) -- 3727
end -- 3715
local ListSubAgentsAction = __TS__Class() -- 3732
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3732
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3732
function ListSubAgentsAction.prototype.prep(self, shared) -- 3733
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3733
		local last = shared.history[#shared.history] -- 3743
		if not last then -- 3743
			error( -- 3744
				__TS__New(Error, "no history"), -- 3744
				0 -- 3744
			) -- 3744
		end -- 3744
		emitAgentStartEvent(shared, last) -- 3745
		return ____awaiter_resolve( -- 3745
			nil, -- 3745
			{ -- 3746
				sessionId = shared.sessionId, -- 3747
				projectRoot = shared.workingDir, -- 3748
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3749
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3750
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3751
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3752
				listSubAgents = shared.listSubAgents, -- 3753
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3754
			} -- 3754
		) -- 3754
	end) -- 3754
end -- 3733
function ListSubAgentsAction.prototype.exec(self, input) -- 3758
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3758
		if not input.listSubAgents then -- 3758
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3758
		end -- 3758
		if input.sessionId == nil or input.sessionId <= 0 then -- 3758
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3758
		end -- 3758
		local result = __TS__Await(input.listSubAgents({ -- 3774
			sessionId = input.sessionId, -- 3775
			projectRoot = input.projectRoot, -- 3776
			status = input.status, -- 3777
			limit = input.limit, -- 3778
			offset = input.offset, -- 3779
			query = input.query -- 3780
		})) -- 3780
		return ____awaiter_resolve( -- 3780
			nil, -- 3780
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3782
		) -- 3782
	end) -- 3782
end -- 3758
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3790
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3790
		local last = shared.history[#shared.history] -- 3791
		if last ~= nil then -- 3791
			last.result = execRes -- 3793
			appendToolResultMessage(shared, last) -- 3794
			emitAgentFinishEvent(shared, last) -- 3795
		end -- 3795
		persistHistoryState(shared) -- 3797
		__TS__Await(maybeCompressHistory(shared)) -- 3798
		persistHistoryState(shared) -- 3799
		return ____awaiter_resolve(nil, "main") -- 3799
	end) -- 3799
end -- 3790
EditFileAction = __TS__Class() -- 3804
EditFileAction.name = "EditFileAction" -- 3804
__TS__ClassExtends(EditFileAction, Node) -- 3804
function EditFileAction.prototype.prep(self, shared) -- 3805
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3805
		local last = shared.history[#shared.history] -- 3806
		if not last then -- 3806
			error( -- 3807
				__TS__New(Error, "no history"), -- 3807
				0 -- 3807
			) -- 3807
		end -- 3807
		emitAgentStartEvent(shared, last) -- 3808
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3809
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3812
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3813
		if __TS__StringTrim(path) == "" then -- 3813
			error( -- 3814
				__TS__New(Error, "missing path"), -- 3814
				0 -- 3814
			) -- 3814
		end -- 3814
		return ____awaiter_resolve(nil, { -- 3814
			path = path, -- 3815
			oldStr = oldStr, -- 3815
			newStr = newStr, -- 3815
			taskId = shared.taskId, -- 3815
			workDir = shared.workingDir -- 3815
		}) -- 3815
	end) -- 3815
end -- 3805
function EditFileAction.prototype.exec(self, input) -- 3818
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3818
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3819
		if not readRes.success then -- 3819
			if input.oldStr ~= "" then -- 3819
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3819
			end -- 3819
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3824
			if not createRes.success then -- 3824
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3824
			end -- 3824
			return ____awaiter_resolve( -- 3824
				nil, -- 3824
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3831
					success = true, -- 3832
					changed = true, -- 3833
					mode = "create", -- 3834
					checkpointId = createRes.checkpointId, -- 3835
					checkpointSeq = createRes.checkpointSeq, -- 3836
					files = {{path = input.path, op = "create"}} -- 3837
				}) -- 3837
			) -- 3837
		end -- 3837
		if input.oldStr == "" then -- 3837
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3837
				return ____awaiter_resolve( -- 3837
					nil, -- 3837
					{ -- 3842
						success = false, -- 3843
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3844
						actualSaved = false, -- 3845
						actualSavedCharacters = 0, -- 3846
						currentFileExists = true, -- 3847
						currentCharacters = #readRes.content, -- 3848
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3849
					} -- 3849
				) -- 3849
			end -- 3849
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3852
			if not overwriteRes.success then -- 3852
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3852
			end -- 3852
			return ____awaiter_resolve( -- 3852
				nil, -- 3852
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3859
					success = true, -- 3860
					changed = true, -- 3861
					mode = "overwrite", -- 3862
					checkpointId = overwriteRes.checkpointId, -- 3863
					checkpointSeq = overwriteRes.checkpointSeq, -- 3864
					files = {{path = input.path, op = "write"}} -- 3865
				}) -- 3865
			) -- 3865
		end -- 3865
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3870
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3871
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3872
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3875
		if occurrences == 0 then -- 3875
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3877
			if not indentTolerant.success then -- 3877
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3877
			end -- 3877
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3881
			if not applyRes.success then -- 3881
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3881
			end -- 3881
			return ____awaiter_resolve( -- 3881
				nil, -- 3881
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3888
					success = true, -- 3889
					changed = true, -- 3890
					mode = "replace_indent_tolerant", -- 3891
					checkpointId = applyRes.checkpointId, -- 3892
					checkpointSeq = applyRes.checkpointSeq, -- 3893
					files = {{path = input.path, op = "write"}} -- 3894
				}) -- 3894
			) -- 3894
		end -- 3894
		if occurrences > 1 then -- 3894
			return ____awaiter_resolve( -- 3894
				nil, -- 3894
				{ -- 3898
					success = false, -- 3898
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3898
				} -- 3898
			) -- 3898
		end -- 3898
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3902
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3903
		if not applyRes.success then -- 3903
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3903
		end -- 3903
		return ____awaiter_resolve( -- 3903
			nil, -- 3903
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3910
				success = true, -- 3911
				changed = true, -- 3912
				mode = "replace", -- 3913
				checkpointId = applyRes.checkpointId, -- 3914
				checkpointSeq = applyRes.checkpointSeq, -- 3915
				files = {{path = input.path, op = "write"}} -- 3916
			}) -- 3916
		) -- 3916
	end) -- 3916
end -- 3818
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3920
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3920
		local last = shared.history[#shared.history] -- 3921
		if last ~= nil then -- 3921
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3923
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3924
			appendToolResultMessage(shared, last) -- 3925
			emitAgentFinishEvent(shared, last) -- 3926
			local result = last.result -- 3927
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3927
				emitAgentEvent(shared, { -- 3932
					type = "checkpoint_created", -- 3933
					sessionId = shared.sessionId, -- 3934
					taskId = shared.taskId, -- 3935
					step = last.step, -- 3936
					tool = last.tool, -- 3937
					checkpointId = result.checkpointId, -- 3938
					checkpointSeq = result.checkpointSeq, -- 3939
					files = result.files -- 3940
				}) -- 3940
			end -- 3940
		end -- 3940
		persistHistoryState(shared) -- 3947
		__TS__Await(maybeCompressHistory(shared)) -- 3948
		persistHistoryState(shared) -- 3949
		return ____awaiter_resolve(nil, "main") -- 3949
	end) -- 3949
end -- 3920
local FetchUrlAction = __TS__Class() -- 3954
FetchUrlAction.name = "FetchUrlAction" -- 3954
__TS__ClassExtends(FetchUrlAction, Node) -- 3954
function FetchUrlAction.prototype.prep(self, shared) -- 3955
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3955
		local last = shared.history[#shared.history] -- 3956
		if not last then -- 3956
			error( -- 3957
				__TS__New(Error, "no history"), -- 3957
				0 -- 3957
			) -- 3957
		end -- 3957
		emitAgentStartEvent(shared, last) -- 3958
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3958
	end) -- 3958
end -- 3955
function FetchUrlAction.prototype.exec(self, input) -- 3962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3962
		return ____awaiter_resolve( -- 3962
			nil, -- 3962
			executeToolAction(input.shared, input.action) -- 3963
		) -- 3963
	end) -- 3963
end -- 3962
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3966
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3966
		local last = shared.history[#shared.history] -- 3967
		if last ~= nil then -- 3967
			last.result = execRes -- 3969
			appendToolResultMessage(shared, last) -- 3970
			emitAgentFinishEvent(shared, last) -- 3971
		end -- 3971
		persistHistoryState(shared) -- 3973
		__TS__Await(maybeCompressHistory(shared)) -- 3974
		persistHistoryState(shared) -- 3975
		return ____awaiter_resolve(nil, "main") -- 3975
	end) -- 3975
end -- 3966
local function emitCheckpointEventForAction(shared, action) -- 3980
	local result = action.result -- 3981
	if not result then -- 3981
		return -- 3982
	end -- 3982
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3982
		emitAgentEvent(shared, { -- 3987
			type = "checkpoint_created", -- 3988
			sessionId = shared.sessionId, -- 3989
			taskId = shared.taskId, -- 3990
			step = action.step, -- 3991
			tool = action.tool, -- 3992
			checkpointId = result.checkpointId, -- 3993
			checkpointSeq = result.checkpointSeq, -- 3994
			files = result.files -- 3995
		}) -- 3995
	end -- 3995
end -- 3980
local function canRunBatchActionInParallel(self, action) -- 4527
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4528
end -- 4527
local function partitionToolCalls(actions) -- 4536
	local batches = {} -- 4537
	do -- 4537
		local i = 0 -- 4538
		while i < #actions do -- 4538
			local action = actions[i + 1] -- 4539
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4540
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4541
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4541
				local ____lastBatch_actions_175 = lastBatch.actions -- 4541
				____lastBatch_actions_175[#____lastBatch_actions_175 + 1] = action -- 4543
			else -- 4543
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4545
			end -- 4545
			i = i + 1 -- 4538
		end -- 4538
	end -- 4538
	return batches -- 4548
end -- 4536
local function completeStoppedToolAction(shared, action) -- 4551
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4552
	if not action.result then -- 4552
		action.result = { -- 4554
			success = false, -- 4554
			message = getCancelledReason(shared) -- 4554
		} -- 4554
	end -- 4554
	appendToolResultMessage(shared, action) -- 4556
	emitAgentFinishEvent(shared, action) -- 4557
	emitCheckpointEventForAction(shared, action) -- 4558
end -- 4551
local BatchToolAction = __TS__Class() -- 4561
BatchToolAction.name = "BatchToolAction" -- 4561
__TS__ClassExtends(BatchToolAction, Node) -- 4561
function BatchToolAction.prototype.prep(self, shared) -- 4562
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4562
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4562
	end) -- 4562
end -- 4562
function BatchToolAction.prototype.exec(self, input) -- 4566
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4566
		local shared = input.shared -- 4567
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4568
		local preExecuted = shared.preExecutedResults -- 4569
		local batches = partitionToolCalls(input.actions) -- 4570
		local parallelBatchCount = #__TS__ArrayFilter( -- 4571
			batches, -- 4571
			function(____, b) return b.isConcurrencySafe end -- 4571
		) -- 4571
		local serialBatchCount = #__TS__ArrayFilter( -- 4572
			batches, -- 4572
			function(____, b) return not b.isConcurrencySafe end -- 4572
		) -- 4572
		AgentUtils.Log( -- 4573
			"Info", -- 4573
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4573
		) -- 4573
		do -- 4573
			local batchIdx = 0 -- 4575
			while batchIdx < #batches do -- 4575
				do -- 4575
					local batch = batches[batchIdx + 1] -- 4576
					if shared.stopToken.stopped then -- 4576
						for ____, action in ipairs(batch.actions) do -- 4578
							completeStoppedToolAction(shared, action) -- 4579
						end -- 4579
						goto __continue754 -- 4581
					end -- 4581
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4581
						local preExecCount = #__TS__ArrayFilter( -- 4585
							batch.actions, -- 4585
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4585
						) -- 4585
						AgentUtils.Log( -- 4586
							"Info", -- 4586
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4586
						) -- 4586
						do -- 4586
							local i = 0 -- 4587
							while i < #batch.actions do -- 4587
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4588
								i = i + 1 -- 4587
							end -- 4587
						end -- 4587
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4590
							batch.actions, -- 4590
							function(____, action) -- 4590
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4590
									if shared.stopToken.stopped then -- 4590
										action.result = { -- 4592
											success = false, -- 4592
											message = getCancelledReason(shared) -- 4592
										} -- 4592
										return ____awaiter_resolve(nil, action) -- 4592
									end -- 4592
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4595
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4596
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4597
									return ____awaiter_resolve(nil, action) -- 4597
								end) -- 4597
							end -- 4590
						))) -- 4590
						do -- 4590
							local i = 0 -- 4600
							while i < #batch.actions do -- 4600
								local action = batch.actions[i + 1] -- 4601
								if not action.result then -- 4601
									action.result = {success = false, message = "tool did not produce a result"} -- 4603
								end -- 4603
								appendToolResultMessage(shared, action) -- 4605
								emitAgentFinishEvent(shared, action) -- 4606
								emitCheckpointEventForAction(shared, action) -- 4607
								i = i + 1 -- 4600
							end -- 4600
						end -- 4600
					else -- 4600
						AgentUtils.Log( -- 4610
							"Info", -- 4610
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4610
						) -- 4610
						do -- 4610
							local i = 0 -- 4611
							while i < #batch.actions do -- 4611
								local action = batch.actions[i + 1] -- 4612
								emitAgentStartEvent(shared, action) -- 4613
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4614
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4615
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4616
								appendToolResultMessage(shared, action) -- 4617
								emitAgentFinishEvent(shared, action) -- 4618
								emitCheckpointEventForAction(shared, action) -- 4619
								persistHistoryState(shared) -- 4620
								if shared.stopToken.stopped then -- 4620
									do -- 4620
										local j = i + 1 -- 4622
										while j < #batch.actions do -- 4622
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4623
											j = j + 1 -- 4622
										end -- 4622
									end -- 4622
									break -- 4625
								end -- 4625
								i = i + 1 -- 4611
							end -- 4611
						end -- 4611
					end -- 4611
				end -- 4611
				::__continue754:: -- 4611
				batchIdx = batchIdx + 1 -- 4575
			end -- 4575
		end -- 4575
		local spawnSeen = spawnedBeforeBatch -- 4630
		local didDelegatedForegroundWork = false -- 4631
		do -- 4631
			local i = 0 -- 4632
			while i < #input.actions do -- 4632
				do -- 4632
					local action = input.actions[i + 1] -- 4633
					if action.tool == "spawn_sub_agent" then -- 4633
						local ____opt_178 = action.result -- 4633
						if (____opt_178 and ____opt_178.success) == true then -- 4633
							spawnSeen = true -- 4635
						end -- 4635
						goto __continue774 -- 4636
					end -- 4636
					if spawnSeen and action.tool ~= "finish" then -- 4636
						didDelegatedForegroundWork = true -- 4639
					end -- 4639
				end -- 4639
				::__continue774:: -- 4639
				i = i + 1 -- 4632
			end -- 4632
		end -- 4632
		if didDelegatedForegroundWork then -- 4632
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4643
		end -- 4643
		persistHistoryState(shared) -- 4645
		return ____awaiter_resolve(nil, input.actions) -- 4645
	end) -- 4645
end -- 4566
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4649
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4649
		shared.pendingToolActions = nil -- 4650
		shared.preExecutedResults = nil -- 4651
		persistHistoryState(shared) -- 4652
		__TS__Await(maybeCompressHistory(shared)) -- 4653
		persistHistoryState(shared) -- 4654
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4654
	end) -- 4654
end -- 4649
local EndNode = __TS__Class() -- 4659
EndNode.name = "EndNode" -- 4659
__TS__ClassExtends(EndNode, Node) -- 4659
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4660
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4660
		return ____awaiter_resolve(nil, nil) -- 4660
	end) -- 4660
end -- 4660
local CodingAgentFlow = __TS__Class() -- 4665
CodingAgentFlow.name = "CodingAgentFlow" -- 4665
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4665
function CodingAgentFlow.prototype.____constructor(self, role) -- 4666
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4667
	local read = __TS__New(ReadFileAction, 1, 0) -- 4668
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4669
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4670
	local list = __TS__New(ListFilesAction, 1, 0) -- 4671
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4672
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4673
	local build = __TS__New(BuildAction, 1, 0) -- 4674
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4675
	local edit = __TS__New(EditFileAction, 1, 0) -- 4676
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4677
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4678
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4679
	local done = __TS__New(EndNode, 1, 0) -- 4680
	main:on("batch_tools", batch) -- 4682
	main:on("grep_files", search) -- 4683
	main:on("search_dora_api", searchDora) -- 4684
	main:on("glob_files", list) -- 4685
	main:on("fetch_url", fetch) -- 4686
	main:on("execute_command", exec) -- 4687
	if role == "main" then -- 4687
		main:on("read_file", read) -- 4689
		main:on("delete_file", del) -- 4690
		main:on("build", build) -- 4691
		main:on("edit_file", edit) -- 4692
		main:on("list_sub_agents", listSub) -- 4693
		main:on("spawn_sub_agent", spawn) -- 4694
	else -- 4694
		main:on("read_file", read) -- 4696
		main:on("delete_file", del) -- 4697
		main:on("build", build) -- 4698
		main:on("edit_file", edit) -- 4699
	end -- 4699
	main:on("done", done) -- 4701
	search:on("main", main) -- 4703
	searchDora:on("main", main) -- 4704
	list:on("main", main) -- 4705
	listSub:on("main", main) -- 4706
	spawn:on("main", main) -- 4707
	batch:on("main", main) -- 4708
	batch:on("done", done) -- 4709
	read:on("main", main) -- 4710
	del:on("main", main) -- 4711
	build:on("main", main) -- 4712
	edit:on("main", main) -- 4713
	fetch:on("main", main) -- 4714
	exec:on("main", main) -- 4715
	Flow.prototype.____constructor(self, main) -- 4717
end -- 4666
local function runCodingAgentAsync(options) -- 4753
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4753
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4753
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4753
		end -- 4753
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4757
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4758
		if not llmConfigRes.success then -- 4758
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4758
		end -- 4758
		local llmConfig = llmConfigRes.config -- 4764
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4765
		if not taskRes.success then -- 4765
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4765
		end -- 4765
		local compressor = __TS__New(MemoryCompressor, { -- 4772
			compressionTargetThreshold = 0.5, -- 4773
			maxCompressionRounds = 3, -- 4774
			projectDir = options.workDir, -- 4775
			llmConfig = llmConfig, -- 4776
			promptPack = options.promptPack, -- 4777
			scope = options.memoryScope -- 4778
		}) -- 4778
		local persistedSession = compressor:getStorage():readSessionState() -- 4780
		local effectiveUserQuery = normalizedPrompt -- 4781
		if options.resumeConversation == true then -- 4781
			do -- 4781
				local i = #persistedSession.messages - 1 -- 4783
				while i >= 0 do -- 4783
					local message = persistedSession.messages[i + 1] -- 4784
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4784
						effectiveUserQuery = message.content -- 4786
						break -- 4787
					end -- 4787
					i = i - 1 -- 4783
				end -- 4783
			end -- 4783
		end -- 4783
		local promptPack = compressor:getPromptPack() -- 4791
		local freshProject = inspectFreshProject(options.workDir) -- 4792
		local freshProjectBuildPending = freshProject.fresh -- 4793
		local freshProjectCodeFile = freshProject.codeFile -- 4794
		local shared = { -- 4796
			sessionId = options.sessionId, -- 4797
			taskId = taskRes.taskId, -- 4798
			role = options.role or "main", -- 4799
			maxSteps = math.max( -- 4800
				1, -- 4800
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4800
			), -- 4800
			llmMaxTry = math.max( -- 4801
				1, -- 4801
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4801
			), -- 4801
			step = 0, -- 4802
			done = false, -- 4803
			stopToken = options.stopToken or ({stopped = false}), -- 4804
			response = "", -- 4805
			userQuery = effectiveUserQuery, -- 4806
			workingDir = options.workDir, -- 4807
			useChineseResponse = options.useChineseResponse == true, -- 4808
			workMode = options.workMode or "code", -- 4809
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4810
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4813
			llmConfig = llmConfig, -- 4814
			onEvent = options.onEvent, -- 4815
			promptPack = promptPack, -- 4816
			history = {}, -- 4817
			messages = persistedSession.messages, -- 4818
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4819
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4820
			memory = {compressor = compressor}, -- 4822
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4826
				projectDir = options.workDir, -- 4828
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4829
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4830
			})}, -- 4830
			spawnSubAgent = options.spawnSubAgent, -- 4836
			listSubAgents = options.listSubAgents, -- 4837
			publishQuestionnaire = options.publishQuestionnaire, -- 4838
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4839
			freshProjectBuildPending = freshProjectBuildPending, -- 4840
			freshProjectCodeFile = freshProjectCodeFile, -- 4841
			hasSpawnedSubAgentThisTask = false, -- 4842
			delegatedForegroundBatches = 0 -- 4843
		} -- 4843
		local ____hasReturned, ____returnValue -- 4843
		local ____try = __TS__AsyncAwaiter(function() -- 4843
			if shared.workMode == "plan" then -- 4843
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4848
				if not planDocuments.success then -- 4848
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4850
					____hasReturned = true -- 4851
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4851
					return -- 4851
				end -- 4851
			end -- 4851
			emitAgentEvent(shared, { -- 4854
				type = "task_started", -- 4855
				sessionId = shared.sessionId, -- 4856
				taskId = shared.taskId, -- 4857
				prompt = shared.userQuery, -- 4858
				workDir = shared.workingDir, -- 4859
				maxSteps = shared.maxSteps -- 4860
			}) -- 4860
			if shared.stopToken.stopped then -- 4860
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4863
				____hasReturned = true -- 4864
				____returnValue = emitAgentTaskFinishEvent( -- 4864
					shared, -- 4864
					false, -- 4864
					getCancelledReason(shared) -- 4864
				) -- 4864
				return -- 4864
			end -- 4864
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4866
			local ____temp_180 -- 4867
			if options.resumeConversation == true then -- 4867
				____temp_180 = nil -- 4867
			else -- 4867
				____temp_180 = getPromptCommand(shared.userQuery) -- 4867
			end -- 4867
			local promptCommand = ____temp_180 -- 4867
			if promptCommand == "clear" then -- 4867
				____hasReturned = true -- 4869
				____returnValue = clearSessionHistory(shared) -- 4869
				return -- 4869
			end -- 4869
			if promptCommand == "compact" then -- 4869
				if shared.role == "sub" then -- 4869
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4873
					____hasReturned = true -- 4874
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4874
					return -- 4874
				end -- 4874
				____hasReturned = true -- 4882
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4882
				return -- 4882
			end -- 4882
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4884
			if shared.stopToken.stopped then -- 4884
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4886
				____hasReturned = true -- 4887
				____returnValue = emitAgentTaskFinishEvent( -- 4887
					shared, -- 4887
					false, -- 4887
					getCancelledReason(shared) -- 4887
				) -- 4887
				return -- 4887
			end -- 4887
			if options.resumeConversation ~= true then -- 4887
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4890
				persistHistoryState(shared) -- 4894
			end -- 4894
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4896
			__TS__Await(flow:run(shared)) -- 4897
			if shared.stopToken.stopped then -- 4897
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4899
				____hasReturned = true -- 4900
				____returnValue = emitAgentTaskFinishEvent( -- 4900
					shared, -- 4900
					false, -- 4900
					getCancelledReason(shared) -- 4900
				) -- 4900
				return -- 4900
			end -- 4900
			if shared.error then -- 4900
				____hasReturned = true -- 4903
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4903
				return -- 4903
			end -- 4903
			if shared.waitingQuestionnaireId ~= nil then -- 4903
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4907
				emitAgentEvent(shared, { -- 4908
					type = "task_waiting_for_user", -- 4909
					sessionId = shared.sessionId, -- 4910
					taskId = shared.taskId, -- 4911
					step = shared.step, -- 4912
					questionnaireId = shared.waitingQuestionnaireId -- 4913
				}) -- 4913
				____hasReturned = true -- 4915
				____returnValue = { -- 4915
					success = true, -- 4916
					taskId = shared.taskId, -- 4917
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4918
					steps = shared.step, -- 4919
					waitingForUser = true, -- 4920
					questionnaireId = shared.waitingQuestionnaireId -- 4921
				} -- 4921
				return -- 4915
			end -- 4915
			local ____isFinalDecisionTurn_result_183 = isFinalDecisionTurn(shared) -- 4924
			if ____isFinalDecisionTurn_result_183 then -- 4924
				local ____opt_181 = shared.completion -- 4924
				____isFinalDecisionTurn_result_183 = (____opt_181 and ____opt_181.outcome) == "partial" -- 4924
			end -- 4924
			if ____isFinalDecisionTurn_result_183 then -- 4924
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4925
				____hasReturned = true -- 4926
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4926
				return -- 4926
			end -- 4926
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4929
			____hasReturned = true -- 4930
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4930
			return -- 4930
		end) -- 4930
		____try = ____try.catch( -- 4930
			____try, -- 4930
			function(____, e) -- 4930
				return __TS__AsyncAwaiter(function() -- 4930
					____hasReturned = true -- 4933
					____returnValue = finalizeAgentFailure( -- 4933
						shared, -- 4933
						tostring(e) -- 4933
					) -- 4933
					return -- 4933
				end) -- 4933
			end -- 4933
		) -- 4933
		__TS__Await(____try) -- 4846
		if ____hasReturned then -- 4846
			return ____awaiter_resolve(nil, ____returnValue) -- 4846
		end -- 4846
	end) -- 4846
end -- 4753
function ____exports.runCodingAgent(options, callback) -- 4937
	local ____self_184 = runCodingAgentAsync(options) -- 4937
	____self_184["then"]( -- 4937
		____self_184, -- 4937
		function(____, result) return callback(result) end -- 4938
	) -- 4938
end -- 4937
return ____exports -- 4937