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
function getCancelledReason(shared) -- 603
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 603
		return shared.stopToken.reason -- 604
	end -- 604
	return shared.useChineseResponse and "已取消" or "cancelled" -- 605
end -- 605
function ____exports.normalizePolicyPath(path) -- 667
	return AgentRuntimePolicy.normalizeAgentPath(path) -- 668
end -- 667
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 676
	return AgentRuntimePolicy.isMainAgentMemoryPath(path) -- 677
end -- 676
function toJson(value, emptyAsArray) -- 824
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray) -- 825
	if text ~= nil then -- 825
		return text -- 826
	end -- 826
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 827
end -- 827
function truncateText(text, maxLen) -- 830
	if #text <= maxLen then -- 830
		return text -- 831
	end -- 831
	local nextPos = utf8.offset(text, maxLen + 1) -- 832
	if nextPos == nil then -- 832
		return text -- 833
	end -- 833
	return string.sub(text, 1, nextPos - 1) .. "..." -- 834
end -- 834
function utf8TakeHead(text, maxChars) -- 837
	if maxChars <= 0 or text == "" then -- 837
		return "" -- 838
	end -- 838
	local nextPos = utf8.offset(text, maxChars + 1) -- 839
	if nextPos == nil then -- 839
		return text -- 840
	end -- 840
	return string.sub(text, 1, nextPos - 1) -- 841
end -- 841
function utf8TakeTail(text, maxChars) -- 844
	if maxChars <= 0 or text == "" then -- 844
		return "" -- 845
	end -- 845
	local charLength = utf8.len(text) -- 846
	if charLength == nil or charLength <= maxChars then -- 846
		return text -- 847
	end -- 847
	local startPos = utf8.offset( -- 848
		text, -- 848
		math.max(1, charLength - maxChars + 1) -- 848
	) -- 848
	if startPos == nil then -- 848
		return text -- 849
	end -- 849
	return string.sub(text, startPos) -- 850
end -- 850
function truncateHistoryText(text, maxChars, label) -- 853
	if maxChars <= 0 or text == "" then -- 853
		return "" -- 854
	end -- 854
	if #text <= maxChars then -- 854
		return text -- 855
	end -- 855
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n" -- 856
	local remaining = math.max(0, maxChars - #marker) -- 857
	local headChars = math.floor(remaining * 0.6) -- 858
	local tailChars = remaining - headChars -- 859
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars) -- 860
end -- 860
function getReplyLanguageDirective(shared) -- 863
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 864
end -- 864
function replacePromptVars(template, vars) -- 869
	local output = template -- 870
	for key in pairs(vars) do -- 871
		output = table.concat( -- 872
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 872
			vars[key] or "" or "," -- 872
		) -- 872
	end -- 872
	return output -- 874
end -- 874
function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label) -- 877
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0 -- 893
	local contentLines = __TS__StringSplit(content, "\n") -- 894
	local availableSourceLines = math.min(sourceLineCount, #contentLines) -- 895
	if #content <= maxChars and availableSourceLines <= maxLines then -- 895
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine} -- 897
	end -- 897
	local contentBudget = math.max(0, maxChars - 240) -- 908
	local candidateLines = math.min(availableSourceLines, maxLines) -- 909
	local retainedLines = {} -- 910
	local retainedChars = 0 -- 911
	do -- 911
		local i = 0 -- 912
		while i < candidateLines do -- 912
			local line = contentLines[i + 1] -- 913
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0) -- 914
			if nextChars > contentBudget then -- 914
				break -- 915
			end -- 915
			retainedLines[#retainedLines + 1] = line -- 916
			retainedChars = nextChars -- 917
			i = i + 1 -- 912
		end -- 912
	end -- 912
	local retainedEndLine = startLine + #retainedLines - 1 -- 920
	local partialLine -- 921
	local retainedContent = table.concat(retainedLines, "\n") -- 922
	if #retainedLines == 0 and candidateLines > 0 then -- 922
		partialLine = startLine -- 924
		retainedEndLine = startLine - 1 -- 925
		retainedContent = utf8TakeHead(contentLines[1], contentBudget) -- 926
	end -- 926
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil -- 928
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines") -- 929
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or "" -- 934
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]" -- 937
	return { -- 938
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker, -- 939
		truncated = true, -- 940
		retainedStartLine = startLine, -- 941
		retainedEndLine = retainedEndLine, -- 942
		nextStartLine = nextStartLine, -- 943
		partialLine = partialLine -- 944
	} -- 944
end -- 944
function sanitizeReadResultForHistory(tool, result) -- 960
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 960
		return result -- 962
	end -- 962
	local clone = {} -- 964
	for key in pairs(result) do -- 965
		clone[key] = result[key] -- 966
	end -- 966
	local startLine = type(result.startLine) == "number" and result.startLine or 1 -- 968
	local endLine = type(result.endLine) == "number" and result.endLine or startLine -- 969
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine -- 970
	local limited = limitReadContentForHistory( -- 971
		result.content, -- 972
		startLine, -- 973
		endLine, -- 974
		totalLines, -- 975
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars, -- 976
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines, -- 977
		"read_file history" -- 978
	) -- 978
	clone.content = limited.content -- 980
	if limited.truncated then -- 980
		clone.historyContentTruncated = true -- 982
		clone.historyRetainedStartLine = limited.retainedStartLine -- 983
		clone.historyRetainedEndLine = limited.retainedEndLine -- 984
		if limited.nextStartLine ~= nil then -- 984
			clone.historyNextStartLine = limited.nextStartLine -- 985
		end -- 985
		if limited.partialLine ~= nil then -- 985
			clone.historyPartialLine = limited.partialLine -- 986
		end -- 986
	end -- 986
	return clone -- 988
end -- 988
function sanitizeSearchMatchesForHistory(items, maxItems) -- 991
	local shown = math.min(#items, maxItems) -- 995
	local out = {} -- 996
	do -- 996
		local i = 0 -- 997
		while i < shown do -- 997
			local row = items[i + 1] -- 998
			out[#out + 1] = { -- 999
				file = row.file, -- 1000
				line = row.line, -- 1001
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1002
			} -- 1002
			i = i + 1 -- 997
		end -- 997
	end -- 997
	return out -- 1007
end -- 1007
function sanitizeSearchResultForHistory(tool, result) -- 1010
	if result.success ~= true or not isArray(result.results) then -- 1010
		return result -- 1014
	end -- 1014
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1014
		return result -- 1015
	end -- 1015
	local clone = {} -- 1016
	for key in pairs(result) do -- 1017
		clone[key] = result[key] -- 1018
	end -- 1018
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 1020
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1021
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1021
		local grouped = result.groupedResults -- 1026
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 1027
		local sanitizedGroups = {} -- 1028
		do -- 1028
			local i = 0 -- 1029
			while i < shown do -- 1029
				local row = grouped[i + 1] -- 1030
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1031
					file = row.file, -- 1032
					totalMatches = row.totalMatches, -- 1033
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1034
				} -- 1034
				i = i + 1 -- 1029
			end -- 1029
		end -- 1029
		clone.groupedResults = sanitizedGroups -- 1039
	end -- 1039
	return clone -- 1041
end -- 1041
function sanitizeListFilesResultForHistory(result) -- 1044
	if result.success ~= true or not isArray(result.files) then -- 1044
		return result -- 1045
	end -- 1045
	local clone = {} -- 1046
	for key in pairs(result) do -- 1047
		clone[key] = result[key] -- 1048
	end -- 1048
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 1050
	return clone -- 1051
end -- 1051
function sanitizeBuildResultForHistory(result) -- 1054
	if not isArray(result.messages) then -- 1054
		return result -- 1055
	end -- 1055
	local clone = {} -- 1056
	for key in pairs(result) do -- 1057
		clone[key] = result[key] -- 1058
	end -- 1058
	local messages = result.messages -- 1060
	local ordered = __TS__ArraySort( -- 1061
		__TS__ArraySlice(messages), -- 1061
		function(____, a, b) -- 1061
			local aFailed = a.success ~= true -- 1062
			local bFailed = b.success ~= true -- 1063
			if aFailed == bFailed then -- 1063
				return 0 -- 1064
			end -- 1064
			return aFailed and -1 or 1 -- 1065
		end -- 1061
	) -- 1061
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1067
	local sanitized = {} -- 1068
	do -- 1068
		local i = 0 -- 1069
		while i < shown do -- 1069
			local item = ordered[i + 1] -- 1070
			local next = {} -- 1071
			for key in pairs(item) do -- 1072
				local value = item[key] -- 1073
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1074
			end -- 1074
			sanitized[#sanitized + 1] = next -- 1078
			i = i + 1 -- 1069
		end -- 1069
	end -- 1069
	clone.messages = sanitized -- 1080
	if #ordered > shown then -- 1080
		clone.truncatedMessages = #ordered - shown -- 1082
	end -- 1082
	return clone -- 1084
end -- 1084
function projectEditResultForLLM(result) -- 1102
	if result.success ~= true then -- 1102
		local failed = {} -- 1104
		for key in pairs(result) do -- 1105
			local value = result[key] -- 1106
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value -- 1107
		end -- 1107
		return failed -- 1111
	end -- 1111
	local projected = {} -- 1113
	local scalarKeys = { -- 1114
		"success", -- 1115
		"changed", -- 1115
		"mode", -- 1115
		"checkpointId", -- 1115
		"checkpointSeq", -- 1115
		"actualSaved", -- 1116
		"actualSavedCharacters", -- 1116
		"currentFileExists", -- 1116
		"currentCharacters", -- 1116
		"currentState" -- 1116
	} -- 1116
	do -- 1116
		local i = 0 -- 1118
		while i < #scalarKeys do -- 1118
			local key = scalarKeys[i + 1] -- 1119
			if result[key] ~= nil then -- 1119
				projected[key] = result[key] -- 1120
			end -- 1120
			i = i + 1 -- 1118
		end -- 1118
	end -- 1118
	if isArray(result.files) then -- 1118
		projected.files = result.files -- 1122
	end -- 1122
	if type(result.message) == "string" then -- 1122
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message") -- 1124
	end -- 1124
	if type(result.guidance) == "string" then -- 1124
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance") -- 1131
	end -- 1131
	if isArray(result.fileContext) then -- 1131
		local summaries = {} -- 1138
		do -- 1138
			local i = 0 -- 1139
			while i < #result.fileContext do -- 1139
				do -- 1139
					local item = result.fileContext[i + 1] -- 1140
					if not isRecord(item) or isArray(item) then -- 1140
						goto __continue157 -- 1141
					end -- 1141
					local summary = {} -- 1142
					local keys = { -- 1143
						"path", -- 1144
						"op", -- 1144
						"beforeExists", -- 1144
						"afterExists", -- 1144
						"beforeBytes", -- 1144
						"afterBytes", -- 1144
						"lineCount", -- 1145
						"contentTruncated", -- 1145
						"fileListTruncated" -- 1145
					} -- 1145
					do -- 1145
						local j = 0 -- 1147
						while j < #keys do -- 1147
							local key = keys[j + 1] -- 1148
							if item[key] ~= nil then -- 1148
								summary[key] = item[key] -- 1149
							end -- 1149
							j = j + 1 -- 1147
						end -- 1147
					end -- 1147
					summaries[#summaries + 1] = summary -- 1151
				end -- 1151
				::__continue157:: -- 1151
				i = i + 1 -- 1139
			end -- 1139
		end -- 1139
		if #summaries > 0 then -- 1139
			projected.fileSummary = summaries -- 1153
		end -- 1153
	end -- 1153
	if type(result.truncatedFileContextItems) == "number" then -- 1153
		projected.truncatedFileContextItems = result.truncatedFileContextItems -- 1156
	end -- 1156
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed." -- 1158
	return projected -- 1159
end -- 1159
function projectBuildResultForLLM(result) -- 1162
	if not isArray(result.messages) then -- 1162
		return result -- 1163
	end -- 1163
	local projected = {} -- 1164
	for key in pairs(result) do -- 1165
		if key ~= "messages" then -- 1165
			projected[key] = result[key] -- 1166
		end -- 1166
	end -- 1166
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages -- 1168
	local shown = math.min(#result.messages, maxMessages) -- 1169
	projected.messages = __TS__ArraySlice(result.messages, 0, shown) -- 1170
	if #result.messages > shown then -- 1170
		projected.llmHistoryTruncatedMessages = #result.messages - shown -- 1172
	end -- 1172
	return projected -- 1174
end -- 1174
function projectCommandResultForLLM(result) -- 1177
	local projected = {} -- 1178
	for key in pairs(result) do -- 1179
		local value = result[key] -- 1180
		if key == "output" and type(value) == "string" then -- 1180
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output") -- 1182
		elseif key == "message" and type(value) == "string" then -- 1182
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message") -- 1188
		else -- 1188
			projected[key] = value -- 1194
		end -- 1194
	end -- 1194
	return projected -- 1197
end -- 1197
function projectToolResultContentForLLM(tool, content) -- 1200
	local decoded = AgentUtils.safeJsonDecode(content) -- 1201
	if not isRecord(decoded) or isArray(decoded) then -- 1201
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result") -- 1203
	end -- 1203
	local projected = decoded -- 1209
	if tool == "edit_file" or tool == "delete_file" then -- 1209
		projected = projectEditResultForLLM(decoded) -- 1211
	elseif tool == "build" then -- 1211
		projected = projectBuildResultForLLM(decoded) -- 1213
	elseif tool == "execute_command" then -- 1213
		projected = projectCommandResultForLLM(decoded) -- 1215
	end -- 1215
	local encoded = toJson(projected, false) -- 1217
	if tool == "read_file" then -- 1217
		return encoded -- 1220
	end -- 1220
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then -- 1220
		return encoded -- 1221
	end -- 1221
	local fallback = { -- 1222
		success = projected.success, -- 1223
		llmHistoryTruncated = true, -- 1224
		originalChars = #encoded, -- 1225
		preview = truncateHistoryText( -- 1226
			encoded, -- 1227
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45), -- 1228
			tool .. " result" -- 1229
		) -- 1229
	} -- 1229
	return toJson(fallback, false) -- 1232
end -- 1232
function projectMessagesForLLMContext(messages) -- 1235
	local projected = {} -- 1239
	do -- 1239
		local i = 0 -- 1240
		while i < #messages do -- 1240
			local message = messages[i + 1] -- 1241
			local next = __TS__ObjectAssign({}, message) -- 1242
			if message.role == "tool" and type(message.content) == "string" then -- 1242
				next.content = projectToolResultContentForLLM(message.name or "tool", message.content) -- 1244
			end -- 1244
			projected[#projected + 1] = next -- 1246
			i = i + 1 -- 1240
		end -- 1240
	end -- 1240
	return projected -- 1248
end -- 1248
function ____exports.getDecisionDisabledAgentTools(shared) -- 1276
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1280
end -- 1276
function getDecisionToolDefinitions(shared) -- 1283
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1284
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1285
	local base = shared.promptPack.toolDefinitionsDetailed -- 1288
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1289
	if usesDefaultToolPrompts then -- 1289
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1292
			shared.role, -- 1292
			{ -- 1292
				includeFinish = true, -- 1293
				includeXmlRules = true, -- 1294
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1295
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1296
				workMode = shared.workMode -- 1297
			} -- 1297
		) -- 1297
		return replacePromptVars(definitions, params) -- 1299
	end -- 1299
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1301
	if (shared and shared.decisionMode) ~= "xml" then -- 1301
		return withRole -- 1306
	end -- 1306
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1308
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1309
end -- 1309
function isToolAllowedForRole(shared, tool) -- 1323
	return __TS__ArrayIndexOf( -- 1324
		AgentToolRegistry.getAllowedToolsForRole( -- 1324
			shared.role, -- 1324
			{ -- 1324
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1325
				workMode = shared.workMode -- 1326
			} -- 1326
		), -- 1326
		tool -- 1327
	) >= 0 -- 1327
end -- 1327
function getFinishMessage(params, fallback) -- 1755
	if fallback == nil then -- 1755
		fallback = "" -- 1755
	end -- 1755
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1755
		return __TS__StringTrim(params.message) -- 1757
	end -- 1757
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1757
		return __TS__StringTrim(params.response) -- 1760
	end -- 1760
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1760
		return __TS__StringTrim(params.summary) -- 1763
	end -- 1763
	return __TS__StringTrim(fallback) -- 1765
end -- 1765
function getCompletionReport(params) -- 1768
	return AgentUtils.normalizeAgentCompletionReport(params) -- 1769
end -- 1769
function persistHistoryState(shared) -- 1772
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1773
end -- 1773
function getActiveConversationMessages(shared) -- 1780
	local activeMessages = {} -- 1781
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1781
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1788
	end -- 1788
	do -- 1788
		local i = shared.lastConsolidatedIndex -- 1792
		while i < #shared.messages do -- 1792
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1793
			i = i + 1 -- 1792
		end -- 1792
	end -- 1792
	return activeMessages -- 1795
end -- 1795
function getActiveRealMessageCount(shared) -- 1798
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1799
end -- 1799
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1802
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1808
	local previousActiveStart = shared.lastConsolidatedIndex -- 1809
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1810
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1811
	if type(carryMessageIndex) == "number" then -- 1811
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1811
		else -- 1811
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1819
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1822
		end -- 1822
	else -- 1822
		shared.carryMessageIndex = nil -- 1827
	end -- 1827
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1827
		shared.carryMessageIndex = nil -- 1837
	end -- 1837
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1845
	shared.resumeCheckpointPending = true -- 1846
	shared.resumeRequiredTool = nil -- 1847
	shared.resumeNarrowReadMode = true -- 1848
	if shared.unbuiltEdits == true then -- 1848
		shared.resumeRequiredTool = "build" -- 1856
	end -- 1856
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1865
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1865
		local marker = "**Next tool**:" -- 1876
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1877
		if markerIndex >= 0 then -- 1877
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1879
			local toolNames = { -- 1880
				"read_file", -- 1881
				"edit_file", -- 1881
				"delete_file", -- 1881
				"grep_files", -- 1881
				"search_dora_api", -- 1881
				"glob_files", -- 1882
				"build", -- 1882
				"fetch_url", -- 1882
				"execute_command", -- 1882
				"list_sub_agents", -- 1882
				"spawn_sub_agent", -- 1883
				"finish" -- 1883
			} -- 1883
			do -- 1883
				local i = 0 -- 1885
				while i < #toolNames do -- 1885
					local tool = toolNames[i + 1] -- 1886
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1886
						shared.resumeRequiredTool = tool -- 1888
						break -- 1889
					end -- 1889
					i = i + 1 -- 1885
				end -- 1885
			end -- 1885
		end -- 1885
	end -- 1885
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1885
		shared.resumeRequiredTool = nil -- 1895
	end -- 1895
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1895
		shared.resumeRequiredTool = nil -- 1898
	end -- 1898
end -- 1898
function ensureToolCallId(toolCallId) -- 1913
	if toolCallId and toolCallId ~= "" then -- 1913
		return toolCallId -- 1914
	end -- 1914
	return AgentUtils.createLocalToolCallId() -- 1915
end -- 1915
function hasXMLParam(params, name) -- 1948
	return params[name] ~= nil -- 1949
end -- 1949
function inferToolNameFromXMLParams(params) -- 1952
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1952
		return "edit_file" -- 1954
	end -- 1954
	if hasXMLParam(params, "target_file") then -- 1954
		return "delete_file" -- 1957
	end -- 1957
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1957
		if hasXMLParam(params, "path") then -- 1957
			return "read_file" -- 1960
		end -- 1960
		return nil -- 1961
	end -- 1961
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1961
		if hasXMLParam(params, "pattern") then -- 1961
			return "search_dora_api" -- 1964
		end -- 1964
		return nil -- 1965
	end -- 1965
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1965
		if hasXMLParam(params, "pattern") then -- 1965
			return "grep_files" -- 1968
		end -- 1968
		return nil -- 1969
	end -- 1969
	if hasXMLParam(params, "globs") then -- 1969
		if hasXMLParam(params, "pattern") then -- 1969
			return "grep_files" -- 1972
		end -- 1972
		return "glob_files" -- 1973
	end -- 1973
	if hasXMLParam(params, "maxEntries") then -- 1973
		return "glob_files" -- 1976
	end -- 1976
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1976
		return "finish" -- 1979
	end -- 1979
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1979
		return "spawn_sub_agent" -- 1982
	end -- 1982
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1982
		return "list_sub_agents" -- 1985
	end -- 1985
	return nil -- 1987
end -- 1987
function parseDSMLAttribute(source, offset, name) -- 1990
	local attrOpen = name .. "=\"" -- 1991
	local attrStart = (string.find( -- 1992
		source, -- 1992
		attrOpen, -- 1992
		math.max(offset + 1, 1), -- 1992
		true -- 1992
	) or 0) - 1 -- 1992
	if attrStart < 0 then -- 1992
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1993
	end -- 1993
	local valueStart = attrStart + #attrOpen -- 1994
	local valueEnd = (string.find( -- 1995
		source, -- 1995
		"\"", -- 1995
		math.max(valueStart + 1, 1), -- 1995
		true -- 1995
	) or 0) - 1 -- 1995
	if valueEnd < 0 then -- 1995
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1996
	end -- 1996
	return { -- 1997
		success = true, -- 1998
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1999
		next = valueEnd + 1 -- 2000
	} -- 2000
end -- 2000
function extractDSMLReason(text, invokeStart, tool) -- 2004
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 2005
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 2006
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 2006
		return before -- 2009
	end -- 2009
	if tool == "finish" then -- 2009
		return "" -- 2010
	end -- 2010
	return "Converted provider-native tool call syntax to XML." -- 2011
end -- 2011
function parseDSMLToolCallObjectFromText(text) -- 2014
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 2015
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 2016
	if invokeStart < 0 then -- 2016
		return {success = false, message = "missing DSML invoke"} -- 2017
	end -- 2017
	local nameStart = invokeStart + #invokeOpen -- 2018
	local nameEnd = (string.find( -- 2019
		text, -- 2019
		"\"", -- 2019
		math.max(nameStart + 1, 1), -- 2019
		true -- 2019
	) or 0) - 1 -- 2019
	if nameEnd < 0 then -- 2019
		return {success = false, message = "unterminated DSML invoke name"} -- 2020
	end -- 2020
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 2021
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 2021
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 2023
	end -- 2023
	local invokeOpenEnd = (string.find( -- 2025
		text, -- 2025
		">", -- 2025
		math.max(nameEnd + 1, 1), -- 2025
		true -- 2025
	) or 0) - 1 -- 2025
	if invokeOpenEnd < 0 then -- 2025
		return {success = false, message = "unterminated DSML invoke open tag"} -- 2026
	end -- 2026
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 2027
	local invokeEnd = (string.find( -- 2028
		text, -- 2028
		invokeClose, -- 2028
		math.max(invokeOpenEnd + 1 + 1, 1), -- 2028
		true -- 2028
	) or 0) - 1 -- 2028
	if invokeEnd < 0 then -- 2028
		return {success = false, message = "missing DSML invoke close tag"} -- 2029
	end -- 2029
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 2031
	local params = {} -- 2032
	local paramOpen = "<｜｜DSML｜｜parameter" -- 2033
	local paramClose = "</｜｜DSML｜｜parameter>" -- 2034
	local pos = 0 -- 2035
	while pos < #body do -- 2035
		local start = (string.find( -- 2037
			body, -- 2037
			paramOpen, -- 2037
			math.max(pos + 1, 1), -- 2037
			true -- 2037
		) or 0) - 1 -- 2037
		if start < 0 then -- 2037
			break -- 2038
		end -- 2038
		local openEnd = (string.find( -- 2039
			body, -- 2039
			">", -- 2039
			math.max(start + #paramOpen + 1, 1), -- 2039
			true -- 2039
		) or 0) - 1 -- 2039
		if openEnd < 0 then -- 2039
			return {success = false, message = "unterminated DSML parameter open tag"} -- 2040
		end -- 2040
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 2041
		if not name.success then -- 2041
			return name -- 2042
		end -- 2042
		local close = (string.find( -- 2043
			body, -- 2043
			paramClose, -- 2043
			math.max(openEnd + 1 + 1, 1), -- 2043
			true -- 2043
		) or 0) - 1 -- 2043
		if close < 0 then -- 2043
			return {success = false, message = "missing DSML parameter close tag"} -- 2044
		end -- 2044
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 2045
		pos = close + #paramClose -- 2046
	end -- 2046
	return { -- 2048
		success = true, -- 2049
		obj = { -- 2050
			tool = toolName, -- 2051
			reason = extractDSMLReason(text, invokeStart, toolName), -- 2052
			params = params -- 2053
		} -- 2053
	} -- 2053
end -- 2053
function parseXMLToolCallObjectFromText(text) -- 2058
	local children = AgentUtils.parseXMLObjectFromText(text, "tool_call") -- 2059
	local rawObj -- 2060
	if children.success then -- 2060
		rawObj = children.obj -- 2062
	else -- 2062
		local dsml = parseDSMLToolCallObjectFromText(text) -- 2064
		if dsml.success then -- 2064
			return dsml -- 2065
		end -- 2065
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 2066
		local paramsCloseToken = "</params>" -- 2067
		if toolStart >= 0 then -- 2067
			local paramsClose = (string.find( -- 2069
				text, -- 2069
				paramsCloseToken, -- 2069
				math.max(toolStart + 1, 1), -- 2069
				true -- 2069
			) or 0) - 1 -- 2069
			if paramsClose >= toolStart then -- 2069
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 2071
				local bare = AgentUtils.parseSimpleXMLChildren(bareCandidate) -- 2072
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 2072
					rawObj = bare.obj -- 2074
				end -- 2074
			end -- 2074
		end -- 2074
		if rawObj == nil then -- 2074
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 2079
			if paramsOpen < 0 then -- 2079
				return children -- 2080
			end -- 2080
			local paramsCloseOnly = (string.find( -- 2081
				text, -- 2081
				paramsCloseToken, -- 2081
				math.max(paramsOpen + 1, 1), -- 2081
				true -- 2081
			) or 0) - 1 -- 2081
			if paramsCloseOnly < paramsOpen then -- 2081
				return children -- 2082
			end -- 2082
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 2083
			local paramsOnly = AgentUtils.parseSimpleXMLChildren(paramsTextOnly) -- 2084
			if not paramsOnly.success then -- 2084
				return children -- 2085
			end -- 2085
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 2086
			if inferredTool == nil then -- 2086
				return children -- 2087
			end -- 2087
			local ____temp_50 -- 2092
			if inferredTool == "finish" then -- 2092
				____temp_50 = nil -- 2092
			else -- 2092
				____temp_50 = "Inferred tool from XML params." -- 2092
			end -- 2092
			return {success = true, obj = {tool = inferredTool, reason = ____temp_50, params = paramsOnly.obj}} -- 2088
		end -- 2088
	end -- 2088
	if rawObj == nil then -- 2088
		return children -- 2098
	end -- 2098
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 2099
	local params = paramsText ~= "" and AgentUtils.parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 2100
	if not params.success then -- 2100
		return {success = false, message = params.message} -- 2104
	end -- 2104
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 2106
end -- 2106
function parseDecisionObject(rawObj) -- 2202
	if type(rawObj.tool) ~= "string" then -- 2202
		return {success = false, message = "missing tool"} -- 2203
	end -- 2203
	local tool = rawObj.tool -- 2204
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2204
		return {success = false, message = "unknown tool: " .. tool} -- 2206
	end -- 2206
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2208
	if tool ~= "finish" and (not reason or reason == "") then -- 2208
		return {success = false, message = tool .. " requires top-level reason"} -- 2212
	end -- 2212
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2214
	return {success = true, tool = tool, params = params, reason = reason} -- 2215
end -- 2215
function getDecisionPath(params) -- 2337
	if type(params.path) == "string" then -- 2337
		return __TS__StringTrim(params.path) -- 2338
	end -- 2338
	if type(params.target_file) == "string" then -- 2338
		return __TS__StringTrim(params.target_file) -- 2339
	end -- 2339
	return "" -- 2340
end -- 2340
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2343
	if enforceFinalTurn == nil then -- 2343
		enforceFinalTurn = false -- 2347
	end -- 2347
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2347
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2350
	end -- 2350
	if not isToolAllowedForRole(shared, tool) then -- 2350
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2353
	end -- 2353
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2353
		local path = getDecisionPath(params) -- 2356
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2356
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2358
		end -- 2358
	end -- 2358
	if tool == "delete_file" then -- 2358
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2362
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2362
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2364
		end -- 2364
	end -- 2364
	return {success = true} -- 2367
end -- 2367
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2370
	local num = __TS__Number(value) -- 2371
	if not __TS__NumberIsFinite(num) then -- 2371
		num = fallback -- 2372
	end -- 2372
	num = math.floor(num) -- 2373
	if num < minValue then -- 2373
		num = minValue -- 2374
	end -- 2374
	if maxValue ~= nil and num > maxValue then -- 2374
		num = maxValue -- 2375
	end -- 2375
	return num -- 2376
end -- 2376
function parseReadLineParam(value, fallback, paramName) -- 2379
	local num = __TS__Number(value) -- 2384
	if not __TS__NumberIsFinite(num) then -- 2384
		num = fallback -- 2385
	end -- 2385
	num = math.floor(num) -- 2386
	if num == 0 then -- 2386
		return {success = false, message = paramName .. " cannot be 0"} -- 2388
	end -- 2388
	return {success = true, value = num} -- 2390
end -- 2390
function validateDecision(tool, params) -- 2393
	if tool == "finish" then -- 2393
		local message = getFinishMessage(params) -- 2398
		if message == "" then -- 2398
			return {success = false, message = "finish requires params.message"} -- 2399
		end -- 2399
		params.message = message -- 2400
		local completion = getCompletionReport(params) -- 2401
		params.outcome = completion.outcome -- 2402
		params.validation = completion.validation -- 2403
		params.knownIssues = completion.knownIssues -- 2404
		params.assumptions = completion.assumptions -- 2405
		params.learningCandidates = completion.learningCandidates -- 2406
		return {success = true, params = params} -- 2407
	end -- 2407
	if tool == "ask_user" then -- 2407
		local normalized = normalizeQuestionnaire(params) -- 2411
		if not normalized.success then -- 2411
			return normalized -- 2412
		end -- 2412
		return {success = true, params = normalized.schema} -- 2413
	end -- 2413
	if tool == "read_file" then -- 2413
		local path = getDecisionPath(params) -- 2417
		if path == "" then -- 2417
			return {success = false, message = "read_file requires path"} -- 2418
		end -- 2418
		params.path = path -- 2419
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2420
		if not startLineRes.success then -- 2420
			return startLineRes -- 2421
		end -- 2421
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2422
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2423
		if not endLineRes.success then -- 2423
			return endLineRes -- 2424
		end -- 2424
		params.startLine = startLineRes.value -- 2425
		params.endLine = endLineRes.value -- 2426
		return {success = true, params = params} -- 2427
	end -- 2427
	if tool == "edit_file" then -- 2427
		local path = getDecisionPath(params) -- 2431
		if path == "" then -- 2431
			return {success = false, message = "edit_file requires path"} -- 2432
		end -- 2432
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2433
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2434
		params.path = path -- 2435
		params.old_str = oldStr -- 2436
		params.new_str = newStr -- 2437
		return {success = true, params = params} -- 2438
	end -- 2438
	if tool == "delete_file" then -- 2438
		local targetFile = getDecisionPath(params) -- 2442
		if targetFile == "" then -- 2442
			return {success = false, message = "delete_file requires target_file"} -- 2443
		end -- 2443
		params.target_file = targetFile -- 2444
		return {success = true, params = params} -- 2445
	end -- 2445
	if tool == "grep_files" then -- 2445
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2449
		if pattern == "" then -- 2449
			return {success = false, message = "grep_files requires pattern"} -- 2450
		end -- 2450
		params.pattern = pattern -- 2451
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2452
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2453
		return {success = true, params = params} -- 2454
	end -- 2454
	if tool == "search_dora_api" then -- 2454
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2458
		if pattern == "" then -- 2458
			return {success = false, message = "search_dora_api requires pattern"} -- 2459
		end -- 2459
		params.pattern = pattern -- 2460
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2461
		return {success = true, params = params} -- 2462
	end -- 2462
	if tool == "glob_files" then -- 2462
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2466
		return {success = true, params = params} -- 2467
	end -- 2467
	if tool == "build" then -- 2467
		local path = getDecisionPath(params) -- 2471
		if path ~= "" then -- 2471
			params.path = path -- 2473
		end -- 2473
		return {success = true, params = params} -- 2475
	end -- 2475
	if tool == "list_sub_agents" then -- 2475
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2479
		if status ~= "" then -- 2479
			params.status = status -- 2481
		end -- 2481
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2483
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2484
		if type(params.query) == "string" then -- 2484
			params.query = __TS__StringTrim(params.query) -- 2486
		end -- 2486
		return {success = true, params = params} -- 2488
	end -- 2488
	if tool == "spawn_sub_agent" then -- 2488
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2492
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2493
		if prompt == "" then -- 2493
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2494
		end -- 2494
		if title == "" then -- 2494
			return {success = false, message = "spawn_sub_agent requires title"} -- 2495
		end -- 2495
		params.prompt = prompt -- 2496
		params.title = title -- 2497
		if type(params.expectedOutput) == "string" then -- 2497
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2499
		end -- 2499
		if isArray(params.filesHint) then -- 2499
			params.filesHint = __TS__ArrayMap( -- 2502
				__TS__ArrayFilter( -- 2502
					params.filesHint, -- 2502
					function(____, item) return type(item) == "string" end -- 2503
				), -- 2503
				function(____, item) return AgentUtils.sanitizeUTF8(item) end -- 2504
			) -- 2504
		end -- 2504
		return {success = true, params = params} -- 2506
	end -- 2506
	return {success = true, params = params} -- 2509
end -- 2509
function validateCompletionForRole(role, tool, params) -- 2512
	if role ~= "sub" or tool ~= "finish" then -- 2512
		return {success = true} -- 2517
	end -- 2517
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2517
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2519
	end -- 2519
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2521
	do -- 2521
		local i = 0 -- 2522
		while i < #requiredArrays do -- 2522
			local name = requiredArrays[i + 1] -- 2523
			if not isArray(params[name]) then -- 2523
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2525
			end -- 2525
			i = i + 1 -- 2522
		end -- 2522
	end -- 2522
	return {success = true} -- 2528
end -- 2528
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2531
	if includeToolDefinitions == nil then -- 2531
		includeToolDefinitions = false -- 2531
	end -- 2531
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2532
	local sections = { -- 2535
		shared.promptPack.agentIdentityPrompt, -- 2536
		rolePrompt, -- 2537
		getReplyLanguageDirective(shared) -- 2538
	} -- 2538
	if shared.role == "main" then -- 2538
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2541
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2542
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2542
			sections[#sections + 1] = table.concat( -- 2544
				{ -- 2544
					"# Current Living Development Plan", -- 2545
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2546
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2546
						AgentUtils.sanitizeUTF8(Content:load(planPath)), -- 2547
						12000 -- 2547
					), -- 2547
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2547
						AgentUtils.sanitizeUTF8(Content:load(progressPath)), -- 2548
						12000 -- 2548
					) -- 2548
				}, -- 2548
				"\n\n" -- 2549
			) -- 2549
		end -- 2549
	end -- 2549
	if shared.decisionMode == "tool_calling" then -- 2549
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2553
	end -- 2553
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2555
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2556
	if memoryContext ~= "" then -- 2556
		sections[#sections + 1] = memoryContext -- 2558
	end -- 2558
	local skillsSection = buildSkillsSection(shared) -- 2560
	if skillsSection ~= "" then -- 2560
		sections[#sections + 1] = skillsSection -- 2562
	end -- 2562
	if includeToolDefinitions then -- 2562
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2565
		if shared.decisionMode == "xml" then -- 2565
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2567
		end -- 2567
	end -- 2567
	return table.concat(sections, "\n\n") -- 2570
end -- 2570
function buildSkillsSection(shared) -- 2573
	local ____opt_69 = shared.skills -- 2573
	if not (____opt_69 and ____opt_69.loader) then -- 2573
		return "" -- 2575
	end -- 2575
	return shared.skills.loader:buildSkillsPromptSection() -- 2577
end -- 2577
function sanitizeMessagesForLLMInput(messages) -- 2580
	local sanitized = {} -- 2581
	local droppedAssistantToolCalls = 0 -- 2582
	local droppedToolResults = 0 -- 2583
	do -- 2583
		local i = 0 -- 2584
		while i < #messages do -- 2584
			do -- 2584
				local message = messages[i + 1] -- 2585
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2585
					local requiredIds = {} -- 2587
					do -- 2587
						local j = 0 -- 2588
						while j < #message.tool_calls do -- 2588
							local toolCall = message.tool_calls[j + 1] -- 2589
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2590
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2590
								requiredIds[#requiredIds + 1] = id -- 2592
							end -- 2592
							j = j + 1 -- 2588
						end -- 2588
					end -- 2588
					if #requiredIds == 0 then -- 2588
						sanitized[#sanitized + 1] = message -- 2596
						goto __continue446 -- 2597
					end -- 2597
					local matchedIds = {} -- 2599
					local matchedTools = {} -- 2600
					local j = i + 1 -- 2601
					while j < #messages do -- 2601
						local toolMessage = messages[j + 1] -- 2603
						if toolMessage.role ~= "tool" then -- 2603
							break -- 2604
						end -- 2604
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2605
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2605
							matchedIds[toolCallId] = true -- 2607
							matchedTools[#matchedTools + 1] = toolMessage -- 2608
						else -- 2608
							droppedToolResults = droppedToolResults + 1 -- 2610
						end -- 2610
						j = j + 1 -- 2612
					end -- 2612
					local complete = true -- 2614
					do -- 2614
						local j = 0 -- 2615
						while j < #requiredIds do -- 2615
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2615
								complete = false -- 2617
								break -- 2618
							end -- 2618
							j = j + 1 -- 2615
						end -- 2615
					end -- 2615
					if complete then -- 2615
						__TS__ArrayPush( -- 2622
							sanitized, -- 2622
							message, -- 2622
							table.unpack(matchedTools) -- 2622
						) -- 2622
					else -- 2622
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2624
						droppedToolResults = droppedToolResults + #matchedTools -- 2625
					end -- 2625
					i = j - 1 -- 2627
					goto __continue446 -- 2628
				end -- 2628
				if message.role == "tool" then -- 2628
					droppedToolResults = droppedToolResults + 1 -- 2631
					goto __continue446 -- 2632
				end -- 2632
				sanitized[#sanitized + 1] = message -- 2634
			end -- 2634
			::__continue446:: -- 2634
			i = i + 1 -- 2584
		end -- 2584
	end -- 2584
	return sanitized -- 2636
end -- 2636
function getUnconsolidatedMessages(shared) -- 2639
	return projectMessagesForLLMContext(sanitizeMessagesForLLMInput(getActiveConversationMessages(shared))) -- 2640
end -- 2640
function isFinalDecisionTurn(shared) -- 2645
	return shared.step + 1 >= shared.maxSteps -- 2646
end -- 2646
function getFinalDecisionTurnPrompt(shared) -- 2649
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2650
end -- 2650
function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode, consumeResumeCheckpoint, pendingUserPrompt) -- 2655
	if attempt == nil then -- 2655
		attempt = 1 -- 2658
	end -- 2658
	if decisionMode == nil then -- 2658
		decisionMode = shared.decisionMode -- 2660
	end -- 2660
	if consumeResumeCheckpoint == nil then -- 2660
		consumeResumeCheckpoint = true -- 2661
	end -- 2661
	if pendingUserPrompt == nil then -- 2661
		pendingUserPrompt = "" -- 2662
	end -- 2662
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2664
	local tailSections = {} -- 2665
	if shared.resumeCheckpointPending == true then -- 2665
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2667
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2670
	end -- 2670
	if shared.truncatedToolOverwritePath ~= nil then -- 2670
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2673
	end -- 2673
	if consumeResumeCheckpoint then -- 2673
		shared.resumeCheckpointPending = false -- 2675
	end -- 2675
	local messages = { -- 2676
		{role = "system", content = systemPrompt}, -- 2677
		table.unpack(getUnconsolidatedMessages(shared)) -- 2678
	} -- 2678
	if pendingUserPrompt ~= "" then -- 2678
		messages[#messages + 1] = {role = "user", content = pendingUserPrompt} -- 2681
	end -- 2681
	if isFinalDecisionTurn(shared) then -- 2681
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2684
	end -- 2684
	if lastError and lastError ~= "" then -- 2684
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2687
		if decisionMode == "xml" then -- 2687
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2691
		end -- 2691
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2691
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2694
		end -- 2694
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2694
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2697
		end -- 2697
		messages[#messages + 1] = { -- 2699
			role = "user", -- 2700
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2701
		} -- 2701
	end -- 2701
	tailSections[#tailSections + 1] = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2708
		role = shared.role, -- 2709
		workMode = shared.workMode, -- 2710
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2711
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2712
		resumeRequiredTool = shared.resumeRequiredTool, -- 2713
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2714
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2715
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2716
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2717
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2718
		buildRepairPending = shared.buildRepairPending, -- 2719
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2720
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2721
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2722
	}) -- 2722
	messages[#messages + 1] = { -- 2724
		role = "user", -- 2725
		content = table.concat(tailSections, "\n\n") -- 2726
	} -- 2726
	return messages -- 2728
end -- 2728
function buildXmlDecisionInstruction(shared, feedback) -- 2731
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2732
end -- 2732
function tryParseAndValidateDecision(rawText, shared) -- 2816
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2817
	if not parsed.success then -- 2817
		return {success = false, message = parsed.message, raw = rawText} -- 2819
	end -- 2819
	local decision = parseDecisionObject(parsed.obj) -- 2821
	if not decision.success then -- 2821
		return {success = false, message = decision.message, raw = rawText} -- 2823
	end -- 2823
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2825
	if not completionValidation.success then -- 2825
		return {success = false, message = completionValidation.message, raw = rawText} -- 2827
	end -- 2827
	local validation = validateDecision(decision.tool, decision.params) -- 2829
	if not validation.success then -- 2829
		return {success = false, message = validation.message, raw = rawText} -- 2831
	end -- 2831
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2833
	if not sharedValidation.success then -- 2833
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2835
	end -- 2835
	decision.params = validation.params -- 2837
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2838
	return decision -- 2839
end -- 2839
function executeToolAction(shared, action) -- 4004
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4004
		if shared.stopToken.stopped then -- 4004
			return ____awaiter_resolve( -- 4004
				nil, -- 4004
				{ -- 4006
					success = false, -- 4006
					message = getCancelledReason(shared) -- 4006
				} -- 4006
			) -- 4006
		end -- 4006
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 4006
			shared.resumeRequiredTool = nil -- 4009
			shared.resumeCheckpointPending = false -- 4010
		end -- 4010
		local params = action.params -- 4012
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 4013
		if not sharedValidation.success then -- 4013
			return ____awaiter_resolve(nil, sharedValidation) -- 4013
		end -- 4013
		if action.tool == "read_file" then -- 4013
			local ____params_startLine_143 = params.startLine -- 4016
			if ____params_startLine_143 == nil then -- 4016
				____params_startLine_143 = 1 -- 4016
			end -- 4016
			local startLine = __TS__Number(____params_startLine_143) -- 4016
			local ____params_endLine_144 = params.endLine -- 4017
			if ____params_endLine_144 == nil then -- 4017
				____params_endLine_144 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 4017
			end -- 4017
			local endLine = __TS__Number(____params_endLine_144) -- 4017
			local clippedAfterCompression = false -- 4018
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 4018
				endLine = startLine + 159 -- 4025
				clippedAfterCompression = true -- 4026
			end -- 4026
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4028
			if __TS__StringTrim(path) == "" then -- 4028
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4028
			end -- 4028
			local result = Tools.readFile( -- 4032
				shared.workingDir, -- 4033
				path, -- 4034
				startLine, -- 4035
				endLine, -- 4036
				shared.useChineseResponse and "zh" or "en" -- 4037
			) -- 4037
			if clippedAfterCompression and result.success == true then -- 4037
				result.clipped = true -- 4040
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4041
			end -- 4041
			return ____awaiter_resolve(nil, result) -- 4041
		end -- 4041
		if action.tool ~= "build" then -- 4041
			shared.resumeNarrowReadMode = false -- 4051
		end -- 4051
		if action.tool == "grep_files" then -- 4051
			local searchPath = params.path or "" -- 4053
			local searchGlobs = params.globs -- 4054
			local ____Tools_searchFiles_158 = Tools.searchFiles -- 4055
			local ____shared_workingDir_151 = shared.workingDir -- 4056
			local ____temp_152 = params.pattern or "" -- 4058
			local ____params_globs_153 = params.globs -- 4059
			local ____params_useRegex_154 = params.useRegex -- 4060
			local ____params_caseSensitive_155 = params.caseSensitive -- 4061
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4063
			local ____math_max_147 = math.max -- 4064
			local ____math_floor_146 = math.floor -- 4064
			local ____params_limit_145 = params.limit -- 4064
			if ____params_limit_145 == nil then -- 4064
				____params_limit_145 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4064
			end -- 4064
			local ____math_max_147_result_157 = ____math_max_147( -- 4064
				1, -- 4064
				____math_floor_146(__TS__Number(____params_limit_145)) -- 4064
			) -- 4064
			local ____math_max_150 = math.max -- 4065
			local ____math_floor_149 = math.floor -- 4065
			local ____params_offset_148 = params.offset -- 4065
			if ____params_offset_148 == nil then -- 4065
				____params_offset_148 = 0 -- 4065
			end -- 4065
			local result = __TS__Await(____Tools_searchFiles_158({ -- 4055
				workDir = ____shared_workingDir_151, -- 4056
				path = searchPath, -- 4057
				pattern = ____temp_152, -- 4058
				globs = ____params_globs_153, -- 4059
				useRegex = ____params_useRegex_154, -- 4060
				caseSensitive = ____params_caseSensitive_155, -- 4061
				includeContent = true, -- 4062
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_156, -- 4063
				limit = ____math_max_147_result_157, -- 4064
				offset = ____math_max_150( -- 4065
					0, -- 4065
					____math_floor_149(__TS__Number(____params_offset_148)) -- 4065
				), -- 4065
				groupByFile = params.groupByFile == true -- 4066
			})) -- 4066
			return ____awaiter_resolve(nil, result) -- 4066
		end -- 4066
		if action.tool == "search_dora_api" then -- 4066
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4071
			local ____Tools_searchDoraAPI_167 = Tools.searchDoraAPI -- 4072
			local ____temp_163 = params.pattern or "" -- 4073
			local ____temp_164 = params.docSource or "api" -- 4074
			local ____temp_165 = shared.useChineseResponse and "zh" or "en" -- 4075
			local ____temp_166 = params.programmingLanguage or "ts" -- 4076
			local ____math_min_162 = math.min -- 4077
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4077
			local ____math_max_160 = math.max -- 4077
			local ____params_limit_159 = params.limit -- 4077
			if ____params_limit_159 == nil then -- 4077
				____params_limit_159 = 8 -- 4077
			end -- 4077
			local result = __TS__Await(____Tools_searchDoraAPI_167({ -- 4072
				pattern = ____temp_163, -- 4073
				docSource = ____temp_164, -- 4074
				docLanguage = ____temp_165, -- 4075
				programmingLanguage = ____temp_166, -- 4076
				limit = ____math_min_162( -- 4077
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_161, -- 4077
					____math_max_160( -- 4077
						1, -- 4077
						__TS__Number(____params_limit_159) -- 4077
					) -- 4077
				), -- 4077
				useRegex = params.useRegex, -- 4078
				caseSensitive = false, -- 4079
				includeContent = true, -- 4080
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4081
			})) -- 4081
			return ____awaiter_resolve(nil, result) -- 4081
		end -- 4081
		if action.tool == "glob_files" then -- 4081
			local ____Tools_listFiles_174 = Tools.listFiles -- 4086
			local ____shared_workingDir_171 = shared.workingDir -- 4087
			local ____temp_172 = params.path or "" -- 4088
			local ____params_globs_173 = params.globs -- 4089
			local ____math_max_170 = math.max -- 4090
			local ____math_floor_169 = math.floor -- 4090
			local ____params_maxEntries_168 = params.maxEntries -- 4090
			if ____params_maxEntries_168 == nil then -- 4090
				____params_maxEntries_168 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4090
			end -- 4090
			local result = ____Tools_listFiles_174({ -- 4086
				workDir = ____shared_workingDir_171, -- 4087
				path = ____temp_172, -- 4088
				globs = ____params_globs_173, -- 4089
				maxEntries = ____math_max_170( -- 4090
					1, -- 4090
					____math_floor_169(__TS__Number(____params_maxEntries_168)) -- 4090
				) -- 4090
			}) -- 4090
			return ____awaiter_resolve(nil, result) -- 4090
		end -- 4090
		if action.tool == "ask_user" then -- 4090
			if not shared.publishQuestionnaire then -- 4090
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4090
			end -- 4090
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4090
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4090
			end -- 4090
			local normalized = normalizeQuestionnaire(params) -- 4097
			if not normalized.success then -- 4097
				return ____awaiter_resolve(nil, normalized) -- 4097
			end -- 4097
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4099
			if not result.success then -- 4099
				return ____awaiter_resolve(nil, result) -- 4099
			end -- 4099
			shared.waitingQuestionnaireId = result.questionnaireId -- 4106
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4106
		end -- 4106
		if action.tool == "delete_file" then -- 4106
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4110
			if __TS__StringTrim(targetFile) == "" then -- 4110
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4110
			end -- 4110
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4114
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4115
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4115
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4115
			end -- 4115
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4119
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4120
			if not result.success then -- 4120
				return ____awaiter_resolve(nil, result) -- 4120
			end -- 4120
			if not isInternalDocumentEdit then -- 4120
				shared.unbuiltEdits = true -- 4128
				shared.lastBuildSucceeded = false -- 4129
				if shared.failedTestNeedsBuild == true then -- 4129
					shared.failedTestHasSourceEdit = true -- 4130
				end -- 4130
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4130
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4131
				end -- 4131
				shared.editedPathsSinceBuild = editedPaths -- 4132
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4133
			end -- 4133
			return ____awaiter_resolve(nil, { -- 4133
				success = true, -- 4136
				changed = true, -- 4137
				mode = "delete", -- 4138
				checkpointId = result.checkpointId, -- 4139
				checkpointSeq = result.checkpointSeq, -- 4140
				files = {{path = targetFile, op = "delete"}} -- 4141
			}) -- 4141
		end -- 4141
		if action.tool == "build" then -- 4141
			local buildPath = params.path or "" -- 4145
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4146
			shared.unbuiltEdits = false -- 4150
			shared.editsSinceBuild = 0 -- 4151
			shared.editedPathsSinceBuild = {} -- 4152
			shared.hasBuilt = true -- 4153
			shared.lastBuildSucceeded = result.success -- 4154
			if result.success and shared.freshProjectBuildPending == true then -- 4154
				shared.freshProjectBuildPending = false -- 4160
			end -- 4160
			shared.apiSearchesSinceBuild = 0 -- 4162
			shared.buildRepairPending = false -- 4163
			if not result.success and result.messages ~= nil then -- 4163
				do -- 4163
					local i = 0 -- 4165
					while i < #result.messages do -- 4165
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4165
							shared.buildRepairPending = true -- 4167
							break -- 4168
						end -- 4168
						i = i + 1 -- 4165
					end -- 4165
				end -- 4165
			end -- 4165
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4165
				shared.failedTestNeedsBuild = false -- 4173
				shared.failedTestHasSourceEdit = false -- 4174
			end -- 4174
			return ____awaiter_resolve(nil, result) -- 4174
		end -- 4174
		if action.tool == "fetch_url" then -- 4174
			local result = __TS__Await(Tools.fetchUrl({ -- 4179
				workDir = shared.workingDir, -- 4180
				url = type(params.url) == "string" and params.url or "", -- 4181
				target = type(params.target) == "string" and params.target or "", -- 4182
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4183
				onProgress = function(____, progress) -- 4184
					emitAgentEvent( -- 4185
						shared, -- 4185
						{ -- 4185
							type = "tool_progress", -- 4186
							sessionId = shared.sessionId, -- 4187
							taskId = shared.taskId, -- 4188
							step = action.step, -- 4189
							tool = action.tool, -- 4190
							result = __TS__ObjectAssign({success = false}, progress) -- 4191
						} -- 4191
					) -- 4191
				end -- 4184
			})) -- 4184
			return ____awaiter_resolve(nil, result) -- 4184
		end -- 4184
		if action.tool == "execute_command" then -- 4184
			local mode = type(params.mode) == "string" and params.mode or "" -- 4201
			local result = __TS__Await(Tools.executeCommand({ -- 4202
				workDir = shared.workingDir, -- 4203
				mode = mode, -- 4204
				code = type(params.code) == "string" and params.code or nil, -- 4205
				command = type(params.command) == "string" and params.command or nil, -- 4206
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4207
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4208
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4209
				onProgress = function(____, progress) -- 4210
					emitAgentEvent( -- 4211
						shared, -- 4211
						{ -- 4211
							type = "tool_progress", -- 4212
							sessionId = shared.sessionId, -- 4213
							taskId = shared.taskId, -- 4214
							step = action.step, -- 4215
							tool = action.tool, -- 4216
							result = __TS__ObjectAssign({success = false}, progress) -- 4217
						} -- 4217
					) -- 4217
				end -- 4210
			})) -- 4210
			if result.success and mode == "lua" then -- 4210
				local deterministicFailure = false -- 4225
				local deterministicPass = false -- 4226
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4227
				do -- 4227
					local i = 0 -- 4228
					while i < #outputLines and not deterministicFailure do -- 4228
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4229
						if line == "passed" then -- 4229
							deterministicPass = true -- 4230
						end -- 4230
						if line == "failed" then -- 4230
							deterministicFailure = true -- 4232
							break -- 4233
						end -- 4233
						local searchFrom = 0 -- 4235
						while searchFrom < #line do -- 4235
							local failedIndex = (string.find( -- 4237
								line, -- 4237
								"failed", -- 4237
								math.max(searchFrom + 1, 1), -- 4237
								true -- 4237
							) or 0) - 1 -- 4237
							if failedIndex < 0 then -- 4237
								break -- 4238
							end -- 4238
							local after = failedIndex + #"failed" -- 4239
							while after < #line do -- 4239
								local ch = __TS__StringSlice(line, after, after + 1) -- 4241
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4241
									break -- 4242
								end -- 4242
								after = after + 1 -- 4243
							end -- 4243
							local afterEnd = after -- 4245
							while afterEnd < #line do -- 4245
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4247
								if ch < "0" or ch > "9" then -- 4247
									break -- 4248
								end -- 4248
								afterEnd = afterEnd + 1 -- 4249
							end -- 4249
							local count -- 4251
							if afterEnd > after then -- 4251
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4253
							else -- 4253
								local before = failedIndex - 1 -- 4255
								while before >= 0 do -- 4255
									local ch = __TS__StringSlice(line, before, before + 1) -- 4257
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4257
										break -- 4258
									end -- 4258
									before = before - 1 -- 4259
								end -- 4259
								local beforeEnd = before + 1 -- 4261
								while before >= 0 do -- 4261
									local ch = __TS__StringSlice(line, before, before + 1) -- 4263
									if ch < "0" or ch > "9" then -- 4263
										break -- 4264
									end -- 4264
									before = before - 1 -- 4265
								end -- 4265
								if beforeEnd > before + 1 then -- 4265
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4267
								end -- 4267
							end -- 4267
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4267
								deterministicFailure = true -- 4270
								break -- 4271
							end -- 4271
							searchFrom = failedIndex + #"failed" -- 4273
						end -- 4273
						i = i + 1 -- 4228
					end -- 4228
				end -- 4228
				if deterministicFailure then -- 4228
					shared.failedTestNeedsBuild = true -- 4277
					shared.failedTestHasSourceEdit = false -- 4278
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4279
				elseif deterministicPass then -- 4279
					shared.deterministicTestFailureCount = 0 -- 4281
				end -- 4281
			end -- 4281
			return ____awaiter_resolve(nil, result) -- 4281
		end -- 4281
		if action.tool == "spawn_sub_agent" then -- 4281
			if not shared.spawnSubAgent then -- 4281
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4281
			end -- 4281
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4281
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4281
			end -- 4281
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4293
				params.filesHint, -- 4294
				function(____, item) return type(item) == "string" end -- 4294
			) or nil -- 4294
			local result = __TS__Await(shared.spawnSubAgent({ -- 4296
				parentSessionId = shared.sessionId, -- 4297
				projectRoot = shared.workingDir, -- 4298
				title = type(params.title) == "string" and params.title or "Sub", -- 4299
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4300
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4301
				filesHint = filesHint, -- 4302
				disabledAgentTools = shared.disabledAgentTools -- 4303
			})) -- 4303
			if not result.success then -- 4303
				return ____awaiter_resolve(nil, result) -- 4303
			end -- 4303
			shared.hasSpawnedSubAgentThisTask = true -- 4308
			return ____awaiter_resolve(nil, { -- 4308
				success = true, -- 4310
				sessionId = result.sessionId, -- 4311
				taskId = result.taskId, -- 4312
				title = result.title, -- 4313
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4314
			}) -- 4314
		end -- 4314
		if action.tool == "list_sub_agents" then -- 4314
			if not shared.listSubAgents then -- 4314
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4314
			end -- 4314
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4314
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4314
			end -- 4314
			local result = __TS__Await(shared.listSubAgents({ -- 4324
				sessionId = shared.sessionId, -- 4325
				projectRoot = shared.workingDir, -- 4326
				status = type(params.status) == "string" and params.status or nil, -- 4327
				limit = type(params.limit) == "number" and params.limit or nil, -- 4328
				offset = type(params.offset) == "number" and params.offset or nil, -- 4329
				query = type(params.query) == "string" and params.query or nil -- 4330
			})) -- 4330
			return ____awaiter_resolve(nil, result) -- 4330
		end -- 4330
		if action.tool == "edit_file" then -- 4330
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4335
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4338
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4339
			if __TS__StringTrim(path) == "" then -- 4339
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4339
			end -- 4339
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4341
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4342
			if not isInternalDocumentEdit then -- 4342
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4344
				if preflightIssue ~= nil then -- 4344
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4346
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4347
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4347
				end -- 4347
			end -- 4347
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4353
			local result = __TS__Await(actionNode:exec({ -- 4354
				path = path, -- 4355
				oldStr = oldStr, -- 4356
				newStr = newStr, -- 4357
				taskId = shared.taskId, -- 4358
				workDir = shared.workingDir -- 4359
			})) -- 4359
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4359
				if params.partialStreamRecovery ~= true then -- 4359
					shared.truncatedToolOverwritePath = nil -- 4363
				end -- 4363
				shared.unbuiltEdits = true -- 4365
				shared.lastBuildSucceeded = false -- 4366
				if shared.failedTestNeedsBuild == true then -- 4366
					shared.failedTestHasSourceEdit = true -- 4367
				end -- 4367
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4368
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4368
					editedPaths[#editedPaths + 1] = normalizedPath -- 4369
				end -- 4369
				shared.editedPathsSinceBuild = editedPaths -- 4370
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4371
			end -- 4371
			return ____awaiter_resolve(nil, result) -- 4371
		end -- 4371
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4371
	end) -- 4371
end -- 4371
function sanitizeToolActionResultForHistory(action, result) -- 4378
	if action.tool == "read_file" then -- 4378
		return sanitizeReadResultForHistory(action.tool, result) -- 4380
	end -- 4380
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4380
		return sanitizeSearchResultForHistory(action.tool, result) -- 4383
	end -- 4383
	if action.tool == "glob_files" then -- 4383
		return sanitizeListFilesResultForHistory(result) -- 4386
	end -- 4386
	if action.tool == "build" then -- 4386
		return sanitizeBuildResultForHistory(result) -- 4389
	end -- 4389
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4389
		if result.success ~= true then -- 4389
			return result -- 4392
		end -- 4392
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4392
			return result -- 4393
		end -- 4393
		if isArray(result.fileContext) then -- 4393
			return result -- 4394
		end -- 4394
		local contextLimits = { -- 4396
			fullContentChars = 12000, -- 4397
			previewChars = 4000, -- 4398
			diffChars = 8000, -- 4399
			totalChars = 24000, -- 4400
			maxFiles = 8 -- 4401
		} -- 4401
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4403
			if maxChars <= 0 then -- 4403
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4404
			end -- 4404
			if #sourceText <= maxChars then -- 4404
				return sourceText -- 4405
			end -- 4405
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4406
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4407
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4408
		end -- 4403
		local function countLines(sourceText) -- 4410
			if sourceText == "" then -- 4410
				return 0 -- 4411
			end -- 4411
			return #__TS__StringSplit(sourceText, "\n") -- 4412
		end -- 4410
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4414
			if beforeContent == afterContent then -- 4414
				return "" -- 4415
			end -- 4415
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4416
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4417
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4419
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4419
				firstChangedLine = firstChangedLine + 1 -- 4425
			end -- 4425
			local lastChangedBeforeLine = #beforeLines - 1 -- 4427
			local lastChangedAfterLine = #afterLines - 1 -- 4428
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4428
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4434
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4435
			end -- 4435
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4437
			local previewEndLine = math.max( -- 4438
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4439
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4440
			) -- 4440
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4442
			do -- 4442
				local lineIndex = previewStartLine -- 4443
				while lineIndex <= previewEndLine do -- 4443
					do -- 4443
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4444
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4445
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4446
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4447
						if not beforeChanged and not afterChanged then -- 4447
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4449
							if contextLine ~= nil then -- 4449
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4450
							end -- 4450
							goto __continue726 -- 4451
						end -- 4451
						if beforeChanged and beforeLine ~= nil then -- 4451
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4453
						end -- 4453
						if afterChanged and afterLine ~= nil then -- 4453
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4454
						end -- 4454
					end -- 4454
					::__continue726:: -- 4454
					lineIndex = lineIndex + 1 -- 4443
				end -- 4443
			end -- 4443
			return truncateContextSnippet( -- 4456
				table.concat(unifiedDiffLines, "\n"), -- 4456
				maxChars, -- 4456
				"diff" -- 4456
			) -- 4456
		end -- 4414
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4459
		if not checkpointDiff.success then -- 4459
			return result -- 4460
		end -- 4460
		local remainingContextBudget = contextLimits.totalChars -- 4461
		local fileContextItems = {} -- 4462
		local changedFiles = checkpointDiff.files -- 4463
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4464
		do -- 4464
			local fileIndex = 0 -- 4465
			while fileIndex < maxContextFiles do -- 4465
				if remainingContextBudget <= 0 then -- 4465
					break -- 4466
				end -- 4466
				local changedFile = changedFiles[fileIndex + 1] -- 4467
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4468
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4469
				local contextItem = { -- 4470
					path = changedFile.path, -- 4471
					op = changedFile.op, -- 4472
					checkpointId = result.checkpointId, -- 4473
					checkpointSeq = result.checkpointSeq, -- 4474
					beforeExists = changedFile.beforeExists, -- 4475
					afterExists = changedFile.afterExists, -- 4476
					beforeBytes = #beforeContent, -- 4477
					afterBytes = #afterContent, -- 4478
					diffPreview = "", -- 4479
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4480
					contentTruncated = false, -- 4481
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4482
				} -- 4482
				if changedFile.afterExists then -- 4482
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4482
						contextItem.afterContent = afterContent -- 4486
						remainingContextBudget = remainingContextBudget - #afterContent -- 4487
					else -- 4487
						contextItem.afterContentPreview = truncateContextSnippet( -- 4489
							afterContent, -- 4490
							math.min( -- 4491
								contextLimits.previewChars, -- 4491
								math.max(400, remainingContextBudget) -- 4491
							), -- 4491
							"afterContent" -- 4492
						) -- 4492
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4494
						contextItem.contentTruncated = true -- 4495
					end -- 4495
				end -- 4495
				local diffPreview = buildUnifiedDiffPreview( -- 4498
					changedFile.path, -- 4499
					beforeContent, -- 4500
					afterContent, -- 4501
					math.min( -- 4502
						contextLimits.diffChars, -- 4502
						math.max(400, remainingContextBudget) -- 4502
					) -- 4502
				) -- 4502
				contextItem.diffPreview = diffPreview -- 4504
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4505
				if not changedFile.afterExists and beforeContent ~= "" then -- 4505
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4507
						beforeContent, -- 4508
						math.min( -- 4509
							contextLimits.previewChars, -- 4509
							math.max(400, remainingContextBudget) -- 4509
						), -- 4509
						"beforeContent" -- 4510
					) -- 4510
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4512
					if #beforeContent > contextLimits.previewChars then -- 4512
						contextItem.contentTruncated = true -- 4513
					end -- 4513
				end -- 4513
				fileContextItems[#fileContextItems + 1] = contextItem -- 4515
				fileIndex = fileIndex + 1 -- 4465
			end -- 4465
		end -- 4465
		if #fileContextItems == 0 then -- 4465
			return result -- 4517
		end -- 4517
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4518
	end -- 4518
	return result -- 4525
end -- 4525
function emitAgentTaskFinishEvent(shared, success, message) -- 4722
	local completion = shared.completion or AgentUtils.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4723
	local result = success and ({ -- 4727
		success = true, -- 4729
		taskId = shared.taskId, -- 4730
		message = message, -- 4731
		steps = shared.step, -- 4732
		completion = completion -- 4733
	}) or ({ -- 4733
		success = false, -- 4736
		taskId = shared.taskId, -- 4737
		message = message, -- 4738
		steps = shared.step, -- 4739
		completion = completion -- 4740
	}) -- 4740
	emitAgentEvent(shared, { -- 4742
		type = "task_finished", -- 4743
		sessionId = shared.sessionId, -- 4744
		taskId = shared.taskId, -- 4745
		success = result.success, -- 4746
		message = result.message, -- 4747
		steps = result.steps, -- 4748
		completion = result.completion -- 4749
	}) -- 4749
	return result -- 4751
end -- 4751
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
	local usedTokens = messagesTokens + math.max(0, contextWindow - fitted.budgetTokens) -- 482
	local maxTokens = contextWindow -- 483
	emitAgentEvent( -- 484
		shared, -- 484
		{ -- 484
			type = "metrics_updated", -- 485
			sessionId = shared.sessionId, -- 486
			taskId = shared.taskId, -- 487
			step = step, -- 488
			metrics = {context = { -- 489
				usedTokens = usedTokens, -- 491
				maxTokens = maxTokens, -- 492
				ratio = math.max( -- 493
					0, -- 493
					math.min(1, usedTokens / maxTokens) -- 493
				), -- 493
				messagesTokens = messagesTokens, -- 494
				optionsTokens = optionsTokens, -- 495
				toolDefinitionsTokens = toolDefinitionsTokens, -- 496
				reservedOutputTokens = reservedOutputTokens, -- 497
				structuralOverhead = structuralOverhead, -- 498
				contextWindow = contextWindow, -- 499
				source = "llm_input_estimate", -- 500
				updatedAt = os.time(), -- 501
				phase = phase, -- 502
				step = step -- 503
			}} -- 503
		} -- 503
	) -- 503
end -- 447
local function recordLLMTokenUsage(shared, step, phase, usage) -- 509
	if not usage then -- 509
		return -- 510
	end -- 510
	local current = shared.tokenUsage -- 511
	local cachedReported = usage.cachedInputTokens ~= nil -- 512
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 513
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 514
	local next = { -- 515
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 516
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 517
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 518
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 519
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 522
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 525
		requestCount = (current and current.requestCount or 0) + 1, -- 528
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 529
		model = shared.llmConfig.model, -- 532
		phase = phase, -- 533
		step = step, -- 534
		updatedAt = os.time() -- 535
	} -- 535
	shared.tokenUsage = next -- 537
	emitAgentEvent(shared, { -- 538
		type = "metrics_updated", -- 539
		sessionId = shared.sessionId, -- 540
		taskId = shared.taskId, -- 541
		step = step, -- 542
		metrics = {usage = next} -- 543
	}) -- 543
end -- 509
local function emitAgentStartEvent(shared, action) -- 547
	emitAgentEvent(shared, { -- 548
		type = "tool_started", -- 549
		sessionId = shared.sessionId, -- 550
		taskId = shared.taskId, -- 551
		step = action.step, -- 552
		tool = action.tool -- 553
	}) -- 553
end -- 547
local function emitAgentFinishEvent(shared, action) -- 557
	emitAgentEvent(shared, { -- 558
		type = "tool_finished", -- 559
		sessionId = shared.sessionId, -- 560
		taskId = shared.taskId, -- 561
		step = action.step, -- 562
		tool = action.tool, -- 563
		result = action.result or ({}) -- 564
	}) -- 564
end -- 557
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 568
	emitAgentEvent(shared, { -- 569
		type = "assistant_message_updated", -- 570
		sessionId = shared.sessionId, -- 571
		taskId = shared.taskId, -- 572
		step = shared.step + 1, -- 573
		content = content, -- 574
		reasoningContent = reasoningContent -- 575
	}) -- 575
end -- 568
local function getMemoryCompressionStartReason(shared) -- 579
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 580
end -- 579
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 585
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 586
end -- 585
local function getMemoryCompressionFailureReason(shared, ____error) -- 591
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 592
end -- 591
local function summarizeHistoryEntryPreview(text, maxChars) -- 597
	if maxChars == nil then -- 597
		maxChars = 180 -- 597
	end -- 597
	local trimmed = __TS__StringTrim(text) -- 598
	if trimmed == "" then -- 598
		return "" -- 599
	end -- 599
	return truncateText(trimmed, maxChars) -- 600
end -- 597
local function getMaxStepsReachedReason(shared) -- 608
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 609
end -- 608
local function getFailureSummaryFallback(shared, ____error) -- 614
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 615
end -- 614
local function finalizeAgentFailure(shared, ____error) -- 620
	if shared.stopToken.stopped then -- 620
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 622
		return emitAgentTaskFinishEvent( -- 623
			shared, -- 623
			false, -- 623
			getCancelledReason(shared) -- 623
		) -- 623
	end -- 623
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 625
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 626
end -- 620
local function getPromptCommand(prompt) -- 629
	local trimmed = __TS__StringTrim(prompt) -- 630
	if trimmed == "/compact" then -- 630
		return "compact" -- 631
	end -- 631
	if trimmed == "/clear" then -- 631
		return "clear" -- 632
	end -- 632
	return nil -- 633
end -- 629
function ____exports.truncateAgentUserPrompt(prompt) -- 636
	if not prompt then -- 636
		return "" -- 637
	end -- 637
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 637
		return prompt -- 638
	end -- 638
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 639
	if offset == nil then -- 639
		return prompt -- 640
	end -- 640
	return string.sub(prompt, 1, offset - 1) -- 641
end -- 636
local function canWriteStepLLMDebug(shared, stepId) -- 644
	if stepId == nil then -- 644
		stepId = shared.step + 1 -- 644
	end -- 644
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 645
end -- 644
local function ensureDirRecursive(dir) -- 652
	if not dir then -- 652
		return false -- 653
	end -- 653
	if Content:exist(dir) then -- 653
		return Content:isdir(dir) -- 654
	end -- 654
	local parent = Path:getPath(dir) -- 655
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 655
		return false -- 657
	end -- 657
	return Content:mkdir(dir) -- 659
end -- 652
local function encodeDebugJSON(value) -- 662
	local text, err = AgentUtils.safeJsonEncode(value) -- 663
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 664
end -- 662
function ____exports.isAgentPlanPath(path) -- 680
	return AgentRuntimePolicy.isAgentPlanPath(path) -- 681
end -- 680
local function inspectFreshProject(workDir) -- 684
	local result = Tools.listFiles({workDir = workDir, path = "", globs = AgentConfig.AGENT_FILE_PATTERNS.freshProjectCodeGlobs, maxEntries = 2}) -- 685
	if not result.success then -- 685
		return {fresh = false} -- 691
	end -- 691
	local totalEntries = result.totalEntries or #result.files -- 692
	if totalEntries > 1 then -- 692
		return {fresh = false} -- 693
	end -- 693
	if totalEntries == 0 then -- 693
		return {fresh = true} -- 694
	end -- 694
	if #result.files ~= 1 then -- 694
		return {fresh = false} -- 695
	end -- 695
	local path = result.files[1] -- 696
	local loaded = Tools.readFileRaw(workDir, path) -- 697
	if not loaded.success or loaded.content == nil then -- 697
		return {fresh = false} -- 698
	end -- 698
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 699
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 702
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 703
end -- 684
local function getStepLLMDebugDir(shared) -- 706
	return Path( -- 707
		shared.workingDir, -- 708
		".agent", -- 709
		tostring(shared.sessionId), -- 710
		tostring(shared.taskId) -- 711
	) -- 711
end -- 706
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 715
	return Path( -- 716
		getStepLLMDebugDir(shared), -- 716
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 716
	) -- 716
end -- 715
local function getLatestStepLLMDebugSeq(shared, stepId) -- 719
	if not canWriteStepLLMDebug(shared, stepId) then -- 719
		return 0 -- 720
	end -- 720
	local dir = getStepLLMDebugDir(shared) -- 721
	if not Content:exist(dir) or not Content:isdir(dir) then -- 721
		return 0 -- 722
	end -- 722
	local latest = 0 -- 723
	for ____, file in ipairs(Content:getFiles(dir)) do -- 724
		do -- 724
			local name = Path:getFilename(file) -- 725
			local seqText = string.match( -- 726
				name, -- 726
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 726
			) -- 726
			if seqText ~= nil then -- 726
				latest = math.max( -- 728
					latest, -- 728
					tonumber(seqText) -- 728
				) -- 728
				goto __continue57 -- 729
			end -- 729
			local legacyMatch = string.match( -- 731
				name, -- 731
				("^" .. tostring(stepId)) .. "_in%.md$" -- 731
			) -- 731
			if legacyMatch ~= nil then -- 731
				latest = math.max(latest, 1) -- 733
			end -- 733
		end -- 733
		::__continue57:: -- 733
	end -- 733
	return latest -- 736
end -- 719
local function writeStepLLMDebugFile(path, content) -- 739
	if not Content:save(path, content) then -- 739
		AgentUtils.Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 741
		return false -- 742
	end -- 742
	return true -- 744
end -- 739
local function createStepLLMDebugPair(shared, stepId, inContent) -- 747
	if not canWriteStepLLMDebug(shared, stepId) then -- 747
		return 0 -- 748
	end -- 748
	local dir = getStepLLMDebugDir(shared) -- 749
	if not ensureDirRecursive(dir) then -- 749
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 751
		return 0 -- 752
	end -- 752
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 754
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 755
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 756
	if not writeStepLLMDebugFile(inPath, inContent) then -- 756
		return 0 -- 758
	end -- 758
	writeStepLLMDebugFile(outPath, "") -- 760
	return seq -- 761
end -- 747
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 764
	if not canWriteStepLLMDebug(shared, stepId) then -- 764
		return -- 765
	end -- 765
	local dir = getStepLLMDebugDir(shared) -- 766
	if not ensureDirRecursive(dir) then -- 766
		AgentUtils.Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 768
		return -- 769
	end -- 769
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 771
	if latestSeq <= 0 then -- 771
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 773
		writeStepLLMDebugFile(outPath, content) -- 774
		return -- 775
	end -- 775
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 777
	writeStepLLMDebugFile(outPath, content) -- 778
end -- 764
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 781
	if not canWriteStepLLMDebug(shared, stepId) then -- 781
		return -- 782
	end -- 782
	local sections = { -- 783
		"# LLM Input", -- 784
		"session_id: " .. tostring(shared.sessionId), -- 785
		"task_id: " .. tostring(shared.taskId), -- 786
		"step_id: " .. tostring(stepId), -- 787
		"phase: " .. phase, -- 788
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 789
		"## Options", -- 790
		"```json", -- 791
		encodeDebugJSON(options), -- 792
		"```" -- 793
	} -- 793
	local firstMessage = #messages > 0 and messages[1] or nil -- 795
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 795
		sections[#sections + 1] = "# System Prompt" -- 797
		sections[#sections + 1] = firstMessage.content -- 798
	end -- 798
	do -- 798
		local i = 0 -- 800
		while i < #messages do -- 800
			local message = messages[i + 1] -- 801
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 802
			sections[#sections + 1] = encodeDebugJSON(message) -- 803
			i = i + 1 -- 800
		end -- 800
	end -- 800
	createStepLLMDebugPair( -- 805
		shared, -- 805
		stepId, -- 805
		table.concat(sections, "\n") -- 805
	) -- 805
end -- 781
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 808
	if not canWriteStepLLMDebug(shared, stepId) then -- 808
		return -- 809
	end -- 809
	local ____array_24 = __TS__SparseArrayNew( -- 809
		"# LLM Output", -- 811
		"session_id: " .. tostring(shared.sessionId), -- 812
		"task_id: " .. tostring(shared.taskId), -- 813
		"step_id: " .. tostring(stepId), -- 814
		"phase: " .. phase, -- 815
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 816
		table.unpack(meta and ({ -- 817
			"## Meta", -- 817
			"```json", -- 817
			encodeDebugJSON(meta), -- 817
			"```" -- 817
		}) or ({})) -- 817
	) -- 817
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 817
	local sections = {__TS__SparseArraySpread(____array_24)} -- 810
	updateLatestStepLLMDebugOutput( -- 821
		shared, -- 821
		stepId, -- 821
		table.concat(sections, "\n") -- 821
	) -- 821
end -- 808
local function summarizeEditTextParamForHistory(value, key) -- 948
	if type(value) ~= "string" then -- 948
		return nil -- 949
	end -- 949
	local text = value -- 950
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 951
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 952
end -- 948
local function sanitizeActionParamsForHistory(tool, params) -- 1087
	if tool ~= "edit_file" then -- 1087
		return params -- 1088
	end -- 1088
	local clone = {} -- 1089
	for key in pairs(params) do -- 1090
		if key == "old_str" then -- 1090
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1092
		elseif key == "new_str" then -- 1092
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1094
		else -- 1094
			clone[key] = params[key] -- 1096
		end -- 1096
	end -- 1096
	return clone -- 1099
end -- 1087
local function projectMessagesForCompression(messages) -- 1251
	local projected = projectMessagesForLLMContext(messages) -- 1252
	do -- 1252
		local i = 0 -- 1253
		while i < #projected do -- 1253
			do -- 1253
				local message = projected[i + 1] -- 1254
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then -- 1254
					goto __continue189 -- 1255
				end -- 1255
				local changed = false -- 1256
				local toolCalls = __TS__ArrayMap( -- 1257
					message.tool_calls, -- 1257
					function(____, toolCall) -- 1257
						local fn = toolCall["function"] -- 1258
						if (fn and fn.name) ~= "edit_file" or type(fn.arguments) ~= "string" then -- 1258
							return toolCall -- 1259
						end -- 1259
						local decoded = AgentUtils.safeJsonDecode(fn.arguments) -- 1260
						if not isRecord(decoded) or isArray(decoded) then -- 1260
							return toolCall -- 1261
						end -- 1261
						changed = true -- 1262
						return __TS__ObjectAssign( -- 1263
							{}, -- 1263
							toolCall, -- 1264
							{["function"] = __TS__ObjectAssign( -- 1263
								{}, -- 1265
								fn, -- 1266
								{arguments = toJson( -- 1265
									sanitizeActionParamsForHistory("edit_file", decoded), -- 1267
									false -- 1267
								)} -- 1267
							)} -- 1267
						) -- 1267
					end -- 1257
				) -- 1257
				if changed then -- 1257
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls}) -- 1271
				end -- 1271
			end -- 1271
			::__continue189:: -- 1271
			i = i + 1 -- 1253
		end -- 1253
	end -- 1253
	return projected -- 1273
end -- 1251
local function getDecisionToolSchemaText(shared) -- 1315
	local toolsText = AgentUtils.safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1316
		shared.role, -- 1316
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1316
		{ -- 1316
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1317
			workMode = shared.workMode -- 1318
		} -- 1318
	)) -- 1318
	return toolsText or "" -- 1320
end -- 1315
local function clearPreExecutedResults(shared) -- 1330
	shared.preExecutedResults = nil -- 1331
end -- 1330
local function startPreExecutedToolAction(shared, action) -- 1334
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1334
		local ____hasReturned, ____returnValue -- 1334
		local ____try = __TS__AsyncAwaiter(function() -- 1334
			____hasReturned = true -- 1336
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1336
			return -- 1336
		end) -- 1336
		____try = ____try.catch( -- 1336
			____try, -- 1336
			function(____, err) -- 1336
				return __TS__AsyncAwaiter(function() -- 1336
					local message = tostring(err) -- 1338
					AgentUtils.Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1339
					____hasReturned = true -- 1340
					____returnValue = {success = false, message = message} -- 1340
					return -- 1340
				end) -- 1340
			end -- 1340
		) -- 1340
		__TS__Await(____try) -- 1335
		if ____hasReturned then -- 1335
			return ____awaiter_resolve(nil, ____returnValue) -- 1335
		end -- 1335
	end) -- 1335
end -- 1334
local function createPreExecutedToolResult(shared, action) -- 1344
	local cloneParamValue -- 1345
	cloneParamValue = function(value) -- 1345
		if value == nil then -- 1345
			return value -- 1346
		end -- 1346
		if isArray(value) then -- 1346
			return __TS__ArrayMap( -- 1348
				value, -- 1348
				function(____, item) return cloneParamValue(item) end -- 1348
			) -- 1348
		end -- 1348
		if type(value) == "table" then -- 1348
			local clone = {} -- 1351
			for key in pairs(value) do -- 1352
				clone[key] = cloneParamValue(value[key]) -- 1353
			end -- 1353
			return clone -- 1355
		end -- 1355
		return value -- 1357
	end -- 1345
	local params = cloneParamValue(action.params) -- 1359
	local areParamValuesEqual -- 1360
	areParamValuesEqual = function(left, right) -- 1360
		if left == right then -- 1360
			return true -- 1361
		end -- 1361
		if left == nil or right == nil then -- 1361
			return false -- 1362
		end -- 1362
		if isArray(left) or isArray(right) then -- 1362
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1362
				return false -- 1364
			end -- 1364
			do -- 1364
				local i = 0 -- 1365
				while i < #left do -- 1365
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1365
						return false -- 1366
					end -- 1366
					i = i + 1 -- 1365
				end -- 1365
			end -- 1365
			return true -- 1368
		end -- 1368
		if type(left) == "table" and type(right) == "table" then -- 1368
			local leftCount = 0 -- 1371
			for key in pairs(left) do -- 1372
				leftCount = leftCount + 1 -- 1373
				if not areParamValuesEqual(left[key], right[key]) then -- 1373
					return false -- 1378
				end -- 1378
			end -- 1378
			local rightCount = 0 -- 1381
			for key in pairs(right) do -- 1382
				rightCount = rightCount + 1 -- 1383
			end -- 1383
			return leftCount == rightCount -- 1385
		end -- 1385
		return false -- 1387
	end -- 1360
	return { -- 1389
		action = action, -- 1390
		matches = function(self, nextAction) -- 1391
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1392
		end, -- 1391
		promise = startPreExecutedToolAction(shared, action) -- 1394
	} -- 1394
end -- 1344
local function executeToolActionWithPreExecution(shared, action) -- 1398
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1398
		local ____opt_29 = shared.preExecutedResults -- 1398
		local preResult = ____opt_29 and ____opt_29:get(action.toolCallId) -- 1399
		local result -- 1400
		if preResult then -- 1400
			local ____opt_31 = shared.preExecutedResults -- 1400
			if ____opt_31 ~= nil then -- 1400
				____opt_31:delete(action.toolCallId) -- 1402
			end -- 1402
			if preResult:matches(action) then -- 1402
				AgentUtils.Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1404
				result = __TS__Await(preResult.promise) -- 1405
			else -- 1405
				AgentUtils.Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1407
				result = __TS__Await(executeToolAction(shared, action)) -- 1408
			end -- 1408
		else -- 1408
			result = __TS__Await(executeToolAction(shared, action)) -- 1411
		end -- 1411
		local guidance = {} -- 1413
		if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1413
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1419
		end -- 1419
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1419
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1422
		end -- 1422
		if shared.failedTestNeedsBuild == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1422
			guidance[#guidance + 1] = "A deterministic test previously failed. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1425
		end -- 1425
		if action.tool == "search_dora_api" then -- 1425
			if shared.unbuiltEdits == true then -- 1425
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1429
			end -- 1429
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1429
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1432
			end -- 1432
		end -- 1432
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1432
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1440
		end -- 1440
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 1440
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1443
			if oldStr == "" then -- 1443
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1445
			end -- 1445
		end -- 1445
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1445
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1449
		end -- 1449
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1449
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1452
		end -- 1452
		if shared.buildRepairPending == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1452
			guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1457
		end -- 1457
		if shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true then -- 1457
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1460
		end -- 1460
		if #guidance > 0 then -- 1460
			result.guidance = table.concat(guidance, "\n") -- 1463
		end -- 1463
		return ____awaiter_resolve(nil, result) -- 1463
	end) -- 1463
end -- 1398
local function maybeCompressHistory(shared, includePendingUserPrompt, pendingUserPrompt) -- 1468
	if includePendingUserPrompt == nil then -- 1468
		includePendingUserPrompt = false -- 1470
	end -- 1470
	if pendingUserPrompt == nil then -- 1470
		pendingUserPrompt = "" -- 1471
	end -- 1471
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1471
		local ____shared_33 = shared -- 1473
		local memory = ____shared_33.memory -- 1473
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1474
		local changed = false -- 1475
		do -- 1475
			local round = 0 -- 1476
			while round < maxRounds do -- 1476
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1477
				local normalizedActiveMessages = sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 1478
				local decisionActiveMessages = projectMessagesForLLMContext(normalizedActiveMessages) -- 1479
				local activeMessages = projectMessagesForCompression(normalizedActiveMessages) -- 1480
				local uncoveredMessages = projectMessagesForCompression(AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex)) -- 1483
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1491
				local triggerMessages = buildDecisionMessages( -- 1494
					shared, -- 1495
					nil, -- 1496
					1, -- 1497
					nil, -- 1498
					shared.decisionMode, -- 1499
					false, -- 1500
					includePendingUserPrompt and pendingUserPrompt or "" -- 1501
				) -- 1501
				local triggerOptions = shared.decisionMode == "tool_calling" and __TS__ObjectAssign( -- 1503
					{}, -- 1504
					shared.llmOptions, -- 1505
					__TS__StringIncludes( -- 1506
						string.lower(shared.llmConfig.model), -- 1506
						"glm-5.2" -- 1506
					) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") and ({reasoning_effort = "minimal"}) or ({}), -- 1506
					{tools = AgentToolRegistry.buildDecisionToolSchema( -- 1504
						shared.role, -- 1511
						AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1511
						{ -- 1511
							disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1512
							workMode = shared.workMode -- 1513
						} -- 1513
					)} -- 1513
				) or shared.llmOptions -- 1513
				local fitted = AgentUtils.fitMessagesToContext(triggerMessages, triggerOptions, shared.llmConfig) -- 1517
				local thresholdReached = getActiveRealMessageCount(shared) > 0 and fitted.originalTokens >= fitted.budgetTokens -- 1520
				if not thresholdReached then -- 1520
					if changed then -- 1520
						persistHistoryState(shared) -- 1524
					end -- 1524
					return ____awaiter_resolve(nil) -- 1524
				end -- 1524
				local compressionRound = round + 1 -- 1528
				AgentUtils.Log( -- 1529
					"Info", -- 1529
					(((("[Memory] Effective input budget reached tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " round=") .. tostring(compressionRound) -- 1529
				) -- 1529
				shared.step = shared.step + 1 -- 1530
				local stepId = shared.step -- 1531
				local pendingMessages = #activeMessages -- 1532
				emitAgentEvent( -- 1533
					shared, -- 1533
					{ -- 1533
						type = "memory_compression_started", -- 1534
						sessionId = shared.sessionId, -- 1535
						taskId = shared.taskId, -- 1536
						step = stepId, -- 1537
						tool = "compress_memory", -- 1538
						reason = getMemoryCompressionStartReason(shared), -- 1539
						params = { -- 1540
							round = compressionRound, -- 1541
							maxRounds = maxRounds, -- 1542
							pendingMessages = pendingMessages, -- 1543
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1544
							uncoveredMessages = #uncoveredMessages, -- 1545
							inputTokens = fitted.originalTokens, -- 1546
							inputBudgetTokens = fitted.budgetTokens -- 1547
						} -- 1547
					} -- 1547
				) -- 1547
				local result = __TS__Await(memory.compressor:compress( -- 1550
					activeMessages, -- 1551
					shared.llmOptions, -- 1552
					shared.llmMaxTry, -- 1553
					shared.decisionMode, -- 1554
					{ -- 1555
						onInput = function(____, phase, messages, options) -- 1556
							saveStepLLMDebugInput( -- 1557
								shared, -- 1557
								stepId, -- 1557
								phase, -- 1557
								messages, -- 1557
								options -- 1557
							) -- 1557
						end, -- 1556
						onOutput = function(____, phase, text, meta) -- 1559
							saveStepLLMDebugOutput( -- 1560
								shared, -- 1560
								stepId, -- 1560
								phase, -- 1560
								text, -- 1560
								meta -- 1560
							) -- 1560
						end, -- 1559
						onUsage = function(____, phase, usage) -- 1562
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1563
						end -- 1562
					}, -- 1562
					"default", -- 1566
					systemPrompt, -- 1567
					toolDefinitions, -- 1568
					decisionActiveMessages -- 1569
				)) -- 1569
				if not (result and result.success and result.compressedCount > 0) then -- 1569
					emitAgentEvent( -- 1572
						shared, -- 1572
						{ -- 1572
							type = "memory_compression_finished", -- 1573
							sessionId = shared.sessionId, -- 1574
							taskId = shared.taskId, -- 1575
							step = stepId, -- 1576
							tool = "compress_memory", -- 1577
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1578
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1582
						} -- 1582
					) -- 1582
					if changed then -- 1582
						persistHistoryState(shared) -- 1590
					end -- 1590
					return ____awaiter_resolve(nil) -- 1590
				end -- 1590
				local effectiveCompressedCount = math.max( -- 1594
					0, -- 1595
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1596
				) -- 1596
				if effectiveCompressedCount <= 0 then -- 1596
					if changed then -- 1596
						persistHistoryState(shared) -- 1600
					end -- 1600
					return ____awaiter_resolve(nil) -- 1600
				end -- 1600
				emitAgentEvent( -- 1604
					shared, -- 1604
					{ -- 1604
						type = "memory_compression_finished", -- 1605
						sessionId = shared.sessionId, -- 1606
						taskId = shared.taskId, -- 1607
						step = stepId, -- 1608
						tool = "compress_memory", -- 1609
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1610
						result = { -- 1611
							success = true, -- 1612
							round = compressionRound, -- 1613
							compressedCount = effectiveCompressedCount, -- 1614
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1615
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1616
						} -- 1616
					} -- 1616
				) -- 1616
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1619
				changed = true -- 1620
				AgentUtils.Log( -- 1621
					"Info", -- 1621
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1621
				) -- 1621
				round = round + 1 -- 1476
			end -- 1476
		end -- 1476
		if changed then -- 1476
			persistHistoryState(shared) -- 1624
		end -- 1624
	end) -- 1624
end -- 1468
local function compactAllHistory(shared) -- 1628
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1628
		local ____shared_40 = shared -- 1629
		local memory = ____shared_40.memory -- 1629
		local rounds = 0 -- 1630
		local totalCompressed = 0 -- 1631
		while getActiveRealMessageCount(shared) > 0 do -- 1631
			if shared.stopToken.stopped then -- 1631
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1634
				return ____awaiter_resolve( -- 1634
					nil, -- 1634
					emitAgentTaskFinishEvent( -- 1635
						shared, -- 1635
						false, -- 1635
						getCancelledReason(shared) -- 1635
					) -- 1635
				) -- 1635
			end -- 1635
			rounds = rounds + 1 -- 1637
			shared.step = shared.step + 1 -- 1638
			local stepId = shared.step -- 1639
			local activeMessages = projectMessagesForCompression(getActiveConversationMessages(shared)) -- 1640
			local pendingMessages = #activeMessages -- 1641
			emitAgentEvent( -- 1642
				shared, -- 1642
				{ -- 1642
					type = "memory_compression_started", -- 1643
					sessionId = shared.sessionId, -- 1644
					taskId = shared.taskId, -- 1645
					step = stepId, -- 1646
					tool = "compress_memory", -- 1647
					reason = getMemoryCompressionStartReason(shared), -- 1648
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1649
				} -- 1649
			) -- 1649
			local result = __TS__Await(memory.compressor:compress( -- 1656
				activeMessages, -- 1657
				shared.llmOptions, -- 1658
				shared.llmMaxTry, -- 1659
				shared.decisionMode, -- 1660
				{ -- 1661
					onInput = function(____, phase, messages, options) -- 1662
						saveStepLLMDebugInput( -- 1663
							shared, -- 1663
							stepId, -- 1663
							phase, -- 1663
							messages, -- 1663
							options -- 1663
						) -- 1663
					end, -- 1662
					onOutput = function(____, phase, text, meta) -- 1665
						saveStepLLMDebugOutput( -- 1666
							shared, -- 1666
							stepId, -- 1666
							phase, -- 1666
							text, -- 1666
							meta -- 1666
						) -- 1666
					end, -- 1665
					onUsage = function(____, phase, usage) -- 1668
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1669
					end -- 1668
				}, -- 1668
				"budget_max" -- 1672
			)) -- 1672
			if not (result and result.success and result.compressedCount > 0) then -- 1672
				emitAgentEvent( -- 1675
					shared, -- 1675
					{ -- 1675
						type = "memory_compression_finished", -- 1676
						sessionId = shared.sessionId, -- 1677
						taskId = shared.taskId, -- 1678
						step = stepId, -- 1679
						tool = "compress_memory", -- 1680
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1681
						result = { -- 1685
							success = false, -- 1686
							rounds = rounds, -- 1687
							error = result and result.error or "compression returned no changes", -- 1688
							compressedCount = result and result.compressedCount or 0, -- 1689
							fullCompaction = true -- 1690
						} -- 1690
					} -- 1690
				) -- 1690
				return ____awaiter_resolve( -- 1690
					nil, -- 1690
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1693
				) -- 1693
			end -- 1693
			local effectiveCompressedCount = math.max( -- 1698
				0, -- 1699
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1700
			) -- 1700
			if effectiveCompressedCount <= 0 then -- 1700
				return ____awaiter_resolve( -- 1700
					nil, -- 1700
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1703
				) -- 1703
			end -- 1703
			emitAgentEvent( -- 1710
				shared, -- 1710
				{ -- 1710
					type = "memory_compression_finished", -- 1711
					sessionId = shared.sessionId, -- 1712
					taskId = shared.taskId, -- 1713
					step = stepId, -- 1714
					tool = "compress_memory", -- 1715
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1716
					result = { -- 1717
						success = true, -- 1718
						round = rounds, -- 1719
						compressedCount = effectiveCompressedCount, -- 1720
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1721
						fullCompaction = true -- 1722
					} -- 1722
				} -- 1722
			) -- 1722
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1725
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1726
			persistHistoryState(shared) -- 1727
			AgentUtils.Log( -- 1728
				"Info", -- 1728
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1728
			) -- 1728
		end -- 1728
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1730
		return ____awaiter_resolve( -- 1730
			nil, -- 1730
			emitAgentTaskFinishEvent( -- 1731
				shared, -- 1732
				true, -- 1733
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1734
			) -- 1734
		) -- 1734
	end) -- 1734
end -- 1628
local function clearSessionHistory(shared) -- 1740
	shared.messages = {} -- 1741
	shared.lastConsolidatedIndex = 0 -- 1742
	shared.carryMessageIndex = nil -- 1743
	persistHistoryState(shared) -- 1744
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1745
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1746
end -- 1740
local function appendConversationMessage(shared, message) -- 1902
	local ____shared_messages_49 = shared.messages -- 1902
	____shared_messages_49[#____shared_messages_49 + 1] = __TS__ObjectAssign( -- 1903
		{}, -- 1903
		message, -- 1904
		{ -- 1903
			content = message.content and AgentUtils.sanitizeUTF8(message.content) or message.content, -- 1905
			name = message.name and AgentUtils.sanitizeUTF8(message.name) or message.name, -- 1906
			tool_call_id = message.tool_call_id and AgentUtils.sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1907
			reasoning_content = message.reasoning_content and AgentUtils.sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1908
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1909
		} -- 1909
	) -- 1909
end -- 1902
local function appendToolResultMessage(shared, action) -- 1918
	appendConversationMessage( -- 1919
		shared, -- 1919
		{ -- 1919
			role = "tool", -- 1920
			tool_call_id = action.toolCallId, -- 1921
			name = action.tool, -- 1922
			content = action.result and toJson(action.result, false) or "" -- 1923
		} -- 1923
	) -- 1923
end -- 1918
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1927
	appendConversationMessage( -- 1933
		shared, -- 1933
		{ -- 1933
			role = "assistant", -- 1934
			content = content or "", -- 1935
			reasoning_content = reasoningContent, -- 1936
			tool_calls = __TS__ArrayMap( -- 1937
				actions, -- 1937
				function(____, action) return { -- 1937
					id = action.toolCallId, -- 1938
					type = "function", -- 1939
					["function"] = { -- 1940
						name = action.tool, -- 1941
						arguments = toJson(action.params, false) -- 1942
					} -- 1942
				} end -- 1942
			) -- 1942
		} -- 1942
	) -- 1942
end -- 1927
local function llm(shared, messages, phase) -- 2126
	if phase == nil then -- 2126
		phase = "decision_xml" -- 2129
	end -- 2129
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2129
		local stepId = shared.step + 1 -- 2131
		emitLLMContextMetrics( -- 2132
			shared, -- 2132
			stepId, -- 2132
			phase, -- 2132
			messages, -- 2132
			shared.llmOptions -- 2132
		) -- 2132
		saveStepLLMDebugInput( -- 2133
			shared, -- 2133
			stepId, -- 2133
			phase, -- 2133
			messages, -- 2133
			shared.llmOptions -- 2133
		) -- 2133
		local lastStreamReasoning = "" -- 2134
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2135
			messages, -- 2136
			shared.llmOptions, -- 2137
			shared.stopToken, -- 2138
			shared.llmConfig, -- 2139
			function(response) -- 2140
				local ____opt_53 = response.choices -- 2140
				local ____opt_51 = ____opt_53 and ____opt_53[1] -- 2140
				local streamMessage = ____opt_51 and ____opt_51.message -- 2141
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2142
				if nextContent == "" then -- 2142
					return -- 2145
				end -- 2145
				if nextContent == lastStreamReasoning then -- 2145
					return -- 2146
				end -- 2146
				lastStreamReasoning = nextContent -- 2147
				emitAssistantMessageUpdated(shared, "", nextContent) -- 2148
			end -- 2140
		)) -- 2140
		if res.success then -- 2140
			local usage = res.tokenUsage -- 2152
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2153
			local ____opt_59 = res.response.choices -- 2153
			local ____opt_57 = ____opt_59 and ____opt_59[1] -- 2153
			local message = ____opt_57 and ____opt_57.message -- 2154
			local text = message and message.content -- 2155
			local reasoningContent = type(message and message.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(message.reasoning_content) or nil -- 2156
			if text then -- 2156
				local parsed = tryParseAndValidateDecision(text, shared) -- 2160
				if parsed.success then -- 2160
					local reason = parsed.reason or "" -- 2162
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 2163
				end -- 2163
				saveStepLLMDebugOutput( -- 2165
					shared, -- 2165
					stepId, -- 2165
					phase, -- 2165
					text, -- 2165
					{success = true, usage = usage} -- 2165
				) -- 2165
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2165
			else -- 2165
				saveStepLLMDebugOutput( -- 2168
					shared, -- 2168
					stepId, -- 2168
					phase, -- 2168
					"empty LLM response", -- 2168
					{success = false, usage = usage} -- 2168
				) -- 2168
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2168
			end -- 2168
		else -- 2168
			local usage = res.tokenUsage -- 2172
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 2173
			saveStepLLMDebugOutput( -- 2174
				shared, -- 2174
				stepId, -- 2174
				phase, -- 2174
				res.raw or res.message, -- 2174
				{success = false, usage = usage} -- 2174
			) -- 2174
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2174
		end -- 2174
	end) -- 2174
end -- 2126
local function isDecisionBatchSuccess(result) -- 2198
	return result.kind == "batch" -- 2199
end -- 2198
local function parseDecisionToolCall(functionName, rawObj) -- 2223
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2223
		return {success = false, message = "unknown tool: " .. functionName} -- 2225
	end -- 2225
	if rawObj == nil then -- 2225
		return {success = true, tool = functionName, params = {}} -- 2228
	end -- 2228
	if not isRecord(rawObj) then -- 2228
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2231
	end -- 2231
	return {success = true, tool = functionName, params = rawObj} -- 2233
end -- 2223
local function parseToolCallArguments(functionName, argsText) -- 2240
	local trimmedArgs = __TS__StringTrim(argsText) -- 2241
	if trimmedArgs == "" then -- 2241
		return {} -- 2243
	end -- 2243
	local rawObj, err = AgentUtils.safeJsonDecode(trimmedArgs) -- 2245
	if err ~= nil or rawObj == nil then -- 2245
		return { -- 2247
			success = false, -- 2248
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2249
			raw = argsText -- 2250
		} -- 2250
	end -- 2250
	local encodedRaw = AgentUtils.safeJsonEncode(rawObj) -- 2253
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2253
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2255
	end -- 2255
	return rawObj -- 2261
end -- 2240
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2264
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2272
	if isRecord(rawArgs) and rawArgs.success == false then -- 2272
		return rawArgs -- 2274
	end -- 2274
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2276
	if not decision.success then -- 2276
		return {success = false, message = decision.message, raw = argsText} -- 2278
	end -- 2278
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2284
	if not completionValidation.success then -- 2284
		return {success = false, message = completionValidation.message, raw = argsText} -- 2286
	end -- 2286
	local validation = validateDecision(decision.tool, decision.params) -- 2292
	if not validation.success then -- 2292
		return {success = false, message = validation.message, raw = argsText} -- 2294
	end -- 2294
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2300
	if not sharedValidation.success then -- 2300
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2302
	end -- 2302
	decision.params = validation.params -- 2308
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2309
	decision.reason = reason -- 2310
	decision.reasoningContent = reasoningContent -- 2311
	return decision -- 2312
end -- 2264
local function createPreExecutableActionFromStream(shared, toolCall) -- 2315
	local ____opt_65 = toolCall["function"] -- 2315
	local functionName = ____opt_65 and ____opt_65.name -- 2316
	local ____opt_67 = toolCall["function"] -- 2316
	local argsText = ____opt_67 and ____opt_67.arguments or "" -- 2317
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2318
	if not functionName or not toolCallId then -- 2318
		return nil -- 2319
	end -- 2319
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2320
	if isRecord(rawArgs) and rawArgs.success == false then -- 2320
		return nil -- 2321
	end -- 2321
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2322
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2322
		return nil -- 2323
	end -- 2323
	local validation = validateDecision(decision.tool, decision.params) -- 2324
	if not validation.success then -- 2324
		return nil -- 2325
	end -- 2325
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2325
		return nil -- 2326
	end -- 2326
	return { -- 2327
		step = shared.step + 1, -- 2328
		toolCallId = toolCallId, -- 2329
		tool = decision.tool, -- 2330
		reason = "", -- 2331
		params = validation.params, -- 2332
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2333
	} -- 2333
end -- 2315
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2735
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2744
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2745
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2753
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2754
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2755
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2763
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2771
		shared.role, -- 2771
		{ -- 2771
			includeFinish = true, -- 2772
			includeXmlRules = true, -- 2773
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2774
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2775
			workMode = shared.workMode -- 2776
		} -- 2776
	) -- 2776
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2778
	local repairPrompt = replacePromptVars( -- 2781
		shared.promptPack.xmlDecisionRepairPrompt, -- 2781
		{ -- 2781
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2782
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2783
			CANDIDATE_SECTION = candidateSection, -- 2784
			LAST_ERROR = lastError, -- 2785
			ATTEMPT = tostring(attempt) -- 2786
		} -- 2786
	) -- 2786
	local availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2788
		role = shared.role, -- 2789
		workMode = shared.workMode, -- 2790
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2791
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2792
		resumeRequiredTool = shared.resumeRequiredTool, -- 2793
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2794
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2795
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2796
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2797
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2798
		buildRepairPending = shared.buildRepairPending, -- 2799
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2800
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2801
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2802
	}) -- 2802
	return {{role = "system", content = systemPrompt}, {role = "user", content = (repairPrompt .. "\n\n") .. availabilityPrompt}} -- 2804
end -- 2735
local MainDecisionAgent = __TS__Class() -- 2842
MainDecisionAgent.name = "MainDecisionAgent" -- 2842
__TS__ClassExtends(MainDecisionAgent, Node) -- 2842
function MainDecisionAgent.prototype.prep(self, shared) -- 2843
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2843
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2843
			return ____awaiter_resolve(nil, {shared = shared}) -- 2843
		end -- 2843
		__TS__Await(maybeCompressHistory(shared)) -- 2848
		return ____awaiter_resolve(nil, {shared = shared}) -- 2848
	end) -- 2848
end -- 2843
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2853
	local preExecuted = shared.preExecutedResults -- 2854
	if not preExecuted or preExecuted.size == 0 then -- 2854
		return nil -- 2855
	end -- 2855
	local decisions = {} -- 2856
	preExecuted:forEach(function(____, preResult) -- 2857
		local action = preResult.action -- 2858
		decisions[#decisions + 1] = { -- 2859
			success = true, -- 2860
			tool = action.tool, -- 2861
			params = action.params, -- 2862
			toolCallId = action.toolCallId, -- 2863
			reason = action.reason, -- 2864
			reasoningContent = action.reasoningContent -- 2865
		} -- 2865
	end) -- 2857
	if #decisions == 0 then -- 2857
		return nil -- 2868
	end -- 2868
	AgentUtils.Log( -- 2869
		"Warn", -- 2869
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2869
			__TS__ArrayMap( -- 2869
				decisions, -- 2869
				function(____, decision) return decision.tool end -- 2869
			), -- 2869
			"," -- 2869
		) -- 2869
	) -- 2869
	if #decisions == 1 then -- 2869
		return decisions[1] -- 2871
	end -- 2871
	return {success = true, kind = "batch", decisions = decisions} -- 2873
end -- 2853
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2880
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2885
	if not recovery then -- 2885
		return nil -- 2886
	end -- 2886
	shared.truncatedToolOverwritePath = recovery.target -- 2887
	AgentUtils.Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2888
	return { -- 2889
		success = true, -- 2890
		tool = "edit_file", -- 2891
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2892
		toolCallId = AgentUtils.createLocalToolCallId(), -- 2898
		reason = recovery.reason, -- 2899
		reasoningContent = reasoningContent -- 2900
	} -- 2900
end -- 2880
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2904
	if attempt == nil then -- 2904
		attempt = 1 -- 2907
	end -- 2907
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2907
		if shared.stopToken.stopped then -- 2907
			return ____awaiter_resolve( -- 2907
				nil, -- 2907
				{ -- 2911
					success = false, -- 2911
					message = getCancelledReason(shared) -- 2911
				} -- 2911
			) -- 2911
		end -- 2911
		AgentUtils.Log( -- 2913
			"Info", -- 2913
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2913
		) -- 2913
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2914
			shared.role, -- 2914
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2914
			{ -- 2914
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2915
				workMode = shared.workMode -- 2916
			} -- 2916
		) -- 2916
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2918
		local stepId = shared.step + 1 -- 2919
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2920
			string.lower(shared.llmConfig.model), -- 2920
			"glm-5.2" -- 2920
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2920
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2923
		emitLLMContextMetrics( -- 2928
			shared, -- 2928
			stepId, -- 2928
			"decision_tool_calling", -- 2928
			messages, -- 2928
			llmOptions -- 2928
		) -- 2928
		saveStepLLMDebugInput( -- 2929
			shared, -- 2929
			stepId, -- 2929
			"decision_tool_calling", -- 2929
			messages, -- 2929
			llmOptions -- 2929
		) -- 2929
		local lastStreamContent = "" -- 2930
		local lastStreamReasoning = "" -- 2931
		local preExecutedResults = __TS__New(Map) -- 2932
		shared.preExecutedResults = preExecutedResults -- 2933
		local res = __TS__Await(AgentUtils.callLLMStreamAggregated( -- 2934
			messages, -- 2935
			llmOptions, -- 2936
			shared.stopToken, -- 2937
			shared.llmConfig, -- 2938
			function(response) -- 2939
				local ____opt_75 = response.choices -- 2939
				local ____opt_73 = ____opt_75 and ____opt_75[1] -- 2939
				local streamMessage = ____opt_73 and ____opt_73.message -- 2940
				local nextContent = type(streamMessage and streamMessage.content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.content) or "" -- 2941
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and AgentUtils.sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2944
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2944
					return -- 2948
				end -- 2948
				lastStreamContent = nextContent -- 2950
				lastStreamReasoning = nextReasoning -- 2951
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2952
			end, -- 2939
			function(tc) -- 2954
				if shared.stopToken.stopped then -- 2954
					return -- 2955
				end -- 2955
				local action = createPreExecutableActionFromStream(shared, tc) -- 2956
				if not action or preExecutedResults:has(action.toolCallId) then -- 2956
					return -- 2957
				end -- 2957
				AgentUtils.Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2958
				preExecutedResults:set( -- 2959
					action.toolCallId, -- 2959
					createPreExecutedToolResult(shared, action) -- 2959
				) -- 2959
			end -- 2954
		)) -- 2954
		if shared.stopToken.stopped then -- 2954
			clearPreExecutedResults(shared) -- 2963
			return ____awaiter_resolve( -- 2963
				nil, -- 2963
				{ -- 2964
					success = false, -- 2964
					message = getCancelledReason(shared) -- 2964
				} -- 2964
			) -- 2964
		end -- 2964
		if not res.success then -- 2964
			local usage = res.tokenUsage -- 2967
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2968
			saveStepLLMDebugOutput( -- 2969
				shared, -- 2969
				stepId, -- 2969
				"decision_tool_calling", -- 2969
				res.raw or res.message, -- 2969
				{success = false, usage = usage} -- 2969
			) -- 2969
			AgentUtils.Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2970
			local committed = self:commitPreExecutedDecision(shared) -- 2971
			if committed then -- 2971
				return ____awaiter_resolve(nil, committed) -- 2971
			end -- 2971
			local ____opt_83 = res.response -- 2971
			local ____opt_81 = ____opt_83 and ____opt_83.choices -- 2971
			local partialChoice = ____opt_81 and ____opt_81[1] -- 2973
			local ____self_preserveTruncatedEditDecision_95 = self.preserveTruncatedEditDecision -- 2974
			local ____shared_93 = shared -- 2975
			local ____opt_85 = partialChoice and partialChoice.message -- 2975
			local ____temp_94 = ____opt_85 and ____opt_85.tool_calls -- 2976
			local ____opt_89 = partialChoice and partialChoice.message -- 2976
			local partialDraft = ____self_preserveTruncatedEditDecision_95(self, ____shared_93, ____temp_94, ____opt_89 and ____opt_89.reasoning_content) -- 2974
			if partialDraft then -- 2974
				return ____awaiter_resolve(nil, partialDraft) -- 2974
			end -- 2974
			clearPreExecutedResults(shared) -- 2980
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2980
		end -- 2980
		local usage = res.tokenUsage -- 2983
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2984
		saveStepLLMDebugOutput( -- 2985
			shared, -- 2985
			stepId, -- 2985
			"decision_tool_calling", -- 2985
			encodeDebugJSON(res.response), -- 2985
			{success = true, usage = usage} -- 2985
		) -- 2985
		local choice = res.response.choices and res.response.choices[1] -- 2986
		local message = choice and choice.message -- 2987
		local toolCalls = message and message.tool_calls -- 2988
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2989
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2992
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2995
		AgentUtils.Log( -- 2998
			"Info", -- 2998
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2998
		) -- 2998
		if finishReason == "length" then -- 2998
			local committed = self:commitPreExecutedDecision(shared) -- 3000
			if committed then -- 3000
				return ____awaiter_resolve(nil, committed) -- 3000
			end -- 3000
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 3002
			if partialDraft then -- 3002
				return ____awaiter_resolve(nil, partialDraft) -- 3002
			end -- 3002
			AgentUtils.Log( -- 3004
				"Error", -- 3004
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 3004
			) -- 3004
			clearPreExecutedResults(shared) -- 3005
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 3005
		end -- 3005
		if not toolCalls or #toolCalls == 0 then -- 3005
			if messageContent and messageContent ~= "" then -- 3005
				if isFinalDecisionTurn(shared) then -- 3005
					clearPreExecutedResults(shared) -- 3015
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 3015
				end -- 3015
				if shared.role == "sub" then -- 3015
					AgentUtils.Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 3023
					clearPreExecutedResults(shared) -- 3024
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 3024
				end -- 3024
				AgentUtils.Log( -- 3031
					"Info", -- 3031
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3031
				) -- 3031
				clearPreExecutedResults(shared) -- 3032
				return ____awaiter_resolve(nil, { -- 3032
					success = true, -- 3034
					tool = "finish", -- 3035
					params = {}, -- 3036
					reason = messageContent, -- 3037
					reasoningContent = reasoningContent, -- 3038
					directSummary = messageContent -- 3039
				}) -- 3039
			end -- 3039
			AgentUtils.Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3042
			clearPreExecutedResults(shared) -- 3043
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3043
		end -- 3043
		local decisions = {} -- 3050
		do -- 3050
			local i = 0 -- 3051
			while i < #toolCalls do -- 3051
				local toolCall = toolCalls[i + 1] -- 3052
				local fn = toolCall ~= nil and toolCall["function"] -- 3053
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3053
					AgentUtils.Log( -- 3055
						"Error", -- 3055
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3055
					) -- 3055
					clearPreExecutedResults(shared) -- 3056
					return ____awaiter_resolve( -- 3056
						nil, -- 3056
						{ -- 3057
							success = false, -- 3058
							message = "missing function name for tool call " .. tostring(i + 1), -- 3059
							raw = messageContent -- 3060
						} -- 3060
					) -- 3060
				end -- 3060
				local functionName = fn.name -- 3063
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3064
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3065
				AgentUtils.Log( -- 3068
					"Info", -- 3068
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3068
				) -- 3068
				local decision = parseAndValidateToolCallDecision( -- 3069
					shared, -- 3070
					functionName, -- 3071
					argsText, -- 3072
					toolCallId, -- 3073
					messageContent, -- 3074
					reasoningContent -- 3075
				) -- 3075
				if not decision.success then -- 3075
					AgentUtils.Log( -- 3078
						"Error", -- 3078
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3078
					) -- 3078
					clearPreExecutedResults(shared) -- 3079
					return ____awaiter_resolve(nil, decision) -- 3079
				end -- 3079
				decisions[#decisions + 1] = decision -- 3082
				i = i + 1 -- 3051
			end -- 3051
		end -- 3051
		if #decisions == 1 then -- 3051
			AgentUtils.Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3085
			return ____awaiter_resolve(nil, decisions[1]) -- 3085
		end -- 3085
		do -- 3085
			local i = 0 -- 3088
			while i < #decisions do -- 3088
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3088
					clearPreExecutedResults(shared) -- 3090
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3090
				end -- 3090
				i = i + 1 -- 3088
			end -- 3088
		end -- 3088
		AgentUtils.Log( -- 3098
			"Info", -- 3098
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3098
				__TS__ArrayMap( -- 3098
					decisions, -- 3098
					function(____, decision) return decision.tool end -- 3098
				), -- 3098
				"," -- 3098
			) -- 3098
		) -- 3098
		return ____awaiter_resolve(nil, { -- 3098
			success = true, -- 3100
			kind = "batch", -- 3101
			decisions = decisions, -- 3102
			content = messageContent, -- 3103
			reasoningContent = reasoningContent -- 3104
		}) -- 3104
	end) -- 3104
end -- 2904
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3108
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3108
		AgentUtils.Log( -- 3114
			"Info", -- 3114
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3114
		) -- 3114
		local lastError = initialError -- 3115
		local candidateRaw = "" -- 3116
		local candidateReasoning = nil -- 3117
		do -- 3117
			local attempt = 0 -- 3118
			while attempt < shared.llmMaxTry do -- 3118
				do -- 3118
					AgentUtils.Log( -- 3119
						"Info", -- 3119
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3119
					) -- 3119
					local messages = buildXmlRepairMessages( -- 3120
						shared, -- 3121
						originalRaw, -- 3122
						originalReasoning, -- 3123
						candidateRaw, -- 3124
						candidateReasoning, -- 3125
						lastError, -- 3126
						attempt + 1 -- 3127
					) -- 3127
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3129
					if shared.stopToken.stopped then -- 3129
						return ____awaiter_resolve( -- 3129
							nil, -- 3129
							{ -- 3131
								success = false, -- 3131
								message = getCancelledReason(shared) -- 3131
							} -- 3131
						) -- 3131
					end -- 3131
					if not llmRes.success then -- 3131
						lastError = llmRes.message -- 3134
						AgentUtils.Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3135
						goto __continue522 -- 3136
					end -- 3136
					candidateRaw = llmRes.text -- 3138
					candidateReasoning = llmRes.reasoningContent -- 3139
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3140
					if decision.success then -- 3140
						decision.reasoningContent = llmRes.reasoningContent -- 3142
						AgentUtils.Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3143
						return ____awaiter_resolve(nil, decision) -- 3143
					end -- 3143
					lastError = decision.message -- 3146
					AgentUtils.Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3147
				end -- 3147
				::__continue522:: -- 3147
				attempt = attempt + 1 -- 3118
			end -- 3118
		end -- 3118
		AgentUtils.Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3149
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3149
	end) -- 3149
end -- 3108
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3157
	if attempt == nil then -- 3157
		attempt = 1 -- 3160
	end -- 3160
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3160
		local messages = buildDecisionMessages( -- 3163
			shared, -- 3164
			lastError, -- 3165
			attempt, -- 3166
			lastRaw, -- 3167
			"xml" -- 3168
		) -- 3168
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3170
		if shared.stopToken.stopped then -- 3170
			return ____awaiter_resolve( -- 3170
				nil, -- 3170
				{ -- 3172
					success = false, -- 3172
					message = getCancelledReason(shared) -- 3172
				} -- 3172
			) -- 3172
		end -- 3172
		if not llmRes.success then -- 3172
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3172
		end -- 3172
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3181
		if decision.success then -- 3181
			decision.reasoningContent = llmRes.reasoningContent -- 3183
			return ____awaiter_resolve(nil, decision) -- 3183
		end -- 3183
		return ____awaiter_resolve( -- 3183
			nil, -- 3183
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3186
		) -- 3186
	end) -- 3186
end -- 3157
function MainDecisionAgent.prototype.exec(self, input) -- 3189
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3189
		local shared = input.shared -- 3190
		if shared.stopToken.stopped then -- 3190
			return ____awaiter_resolve( -- 3190
				nil, -- 3190
				{ -- 3192
					success = false, -- 3192
					message = getCancelledReason(shared) -- 3192
				} -- 3192
			) -- 3192
		end -- 3192
		if shared.step >= shared.maxSteps then -- 3192
			AgentUtils.Log( -- 3195
				"Warn", -- 3195
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3195
			) -- 3195
			return ____awaiter_resolve( -- 3195
				nil, -- 3195
				{ -- 3196
					success = false, -- 3196
					message = getMaxStepsReachedReason(shared) -- 3196
				} -- 3196
			) -- 3196
		end -- 3196
		if shared.decisionMode == "tool_calling" then -- 3196
			AgentUtils.Log( -- 3200
				"Info", -- 3200
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3200
			) -- 3200
			local lastError = "tool calling validation failed" -- 3201
			local lastRaw = "" -- 3202
			local shouldFallbackToXml = false -- 3203
			do -- 3203
				local attempt = 0 -- 3204
				while attempt < shared.llmMaxTry do -- 3204
					AgentUtils.Log( -- 3205
						"Info", -- 3205
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3205
					) -- 3205
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3206
					if shared.stopToken.stopped then -- 3206
						return ____awaiter_resolve( -- 3206
							nil, -- 3206
							{ -- 3213
								success = false, -- 3213
								message = getCancelledReason(shared) -- 3213
							} -- 3213
						) -- 3213
					end -- 3213
					if decision.success then -- 3213
						return ____awaiter_resolve(nil, decision) -- 3213
					end -- 3213
					lastError = decision.message -- 3218
					lastRaw = decision.raw or "" -- 3219
					AgentUtils.Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3220
					if lastError == "missing tool call" then -- 3220
						shouldFallbackToXml = true -- 3222
						break -- 3223
					end -- 3223
					attempt = attempt + 1 -- 3204
				end -- 3204
			end -- 3204
			if shouldFallbackToXml then -- 3204
				AgentUtils.Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3227
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3228
				do -- 3228
					local attempt = 0 -- 3229
					while attempt < shared.llmMaxTry do -- 3229
						AgentUtils.Log( -- 3230
							"Info", -- 3230
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3230
						) -- 3230
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3231
						if shared.stopToken.stopped then -- 3231
							return ____awaiter_resolve( -- 3231
								nil, -- 3231
								{ -- 3238
									success = false, -- 3238
									message = getCancelledReason(shared) -- 3238
								} -- 3238
							) -- 3238
						end -- 3238
						if decision.success then -- 3238
							return ____awaiter_resolve(nil, decision) -- 3238
						end -- 3238
						lastError = decision.message -- 3243
						lastRaw = decision.raw or "" -- 3244
						AgentUtils.Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3245
						attempt = attempt + 1 -- 3229
					end -- 3229
				end -- 3229
				AgentUtils.Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3247
				return ____awaiter_resolve( -- 3247
					nil, -- 3247
					{ -- 3248
						success = false, -- 3248
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3248
					} -- 3248
				) -- 3248
			end -- 3248
			AgentUtils.Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3250
			return ____awaiter_resolve( -- 3250
				nil, -- 3250
				{ -- 3251
					success = false, -- 3251
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3251
				} -- 3251
			) -- 3251
		end -- 3251
		local lastError = "xml validation failed" -- 3254
		local lastRaw = "" -- 3255
		do -- 3255
			local attempt = 0 -- 3256
			while attempt < shared.llmMaxTry do -- 3256
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3257
				if shared.stopToken.stopped then -- 3257
					return ____awaiter_resolve( -- 3257
						nil, -- 3257
						{ -- 3266
							success = false, -- 3266
							message = getCancelledReason(shared) -- 3266
						} -- 3266
					) -- 3266
				end -- 3266
				if decision.success then -- 3266
					return ____awaiter_resolve(nil, decision) -- 3266
				end -- 3266
				lastError = decision.message -- 3271
				lastRaw = decision.raw or "" -- 3272
				attempt = attempt + 1 -- 3256
			end -- 3256
		end -- 3256
		return ____awaiter_resolve( -- 3256
			nil, -- 3256
			{ -- 3274
				success = false, -- 3274
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3274
			} -- 3274
		) -- 3274
	end) -- 3274
end -- 3189
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3277
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3277
		local result = execRes -- 3278
		if not result.success then -- 3278
			if shared.stopToken.stopped then -- 3278
				shared.error = getCancelledReason(shared) -- 3281
				shared.done = true -- 3282
				return ____awaiter_resolve(nil, "done") -- 3282
			end -- 3282
			shared.error = result.message -- 3285
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3286
			shared.done = true -- 3287
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3288
			persistHistoryState(shared) -- 3292
			return ____awaiter_resolve(nil, "done") -- 3292
		end -- 3292
		if isDecisionBatchSuccess(result) then -- 3292
			local startStep = shared.step -- 3296
			local actions = {} -- 3297
			do -- 3297
				local i = 0 -- 3298
				while i < #result.decisions do -- 3298
					local decision = result.decisions[i + 1] -- 3299
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3300
					local step = startStep + i + 1 -- 3301
					local ____temp_96 -- 3302
					if i == 0 then -- 3302
						____temp_96 = decision.reason -- 3302
					else -- 3302
						____temp_96 = "" -- 3302
					end -- 3302
					local actionReason = ____temp_96 -- 3302
					local ____temp_97 -- 3303
					if i == 0 then -- 3303
						____temp_97 = decision.reasoningContent -- 3303
					else -- 3303
						____temp_97 = nil -- 3303
					end -- 3303
					local actionReasoningContent = ____temp_97 -- 3303
					emitAgentEvent(shared, { -- 3304
						type = "decision_made", -- 3305
						sessionId = shared.sessionId, -- 3306
						taskId = shared.taskId, -- 3307
						step = step, -- 3308
						tool = decision.tool, -- 3309
						reason = actionReason, -- 3310
						reasoningContent = actionReasoningContent, -- 3311
						params = decision.params -- 3312
					}) -- 3312
					local action = { -- 3314
						step = step, -- 3315
						toolCallId = toolCallId, -- 3316
						tool = decision.tool, -- 3317
						reason = actionReason or "", -- 3318
						reasoningContent = actionReasoningContent, -- 3319
						params = decision.params, -- 3320
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3321
					} -- 3321
					local ____shared_history_98 = shared.history -- 3321
					____shared_history_98[#____shared_history_98 + 1] = action -- 3323
					actions[#actions + 1] = action -- 3324
					i = i + 1 -- 3298
				end -- 3298
			end -- 3298
			shared.step = startStep + #actions -- 3326
			shared.pendingToolActions = actions -- 3327
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3328
			persistHistoryState(shared) -- 3334
			return ____awaiter_resolve(nil, "batch_tools") -- 3334
		end -- 3334
		if result.directSummary and result.directSummary ~= "" then -- 3334
			shared.response = result.directSummary -- 3338
			shared.completion = AgentUtils.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3339
			shared.done = true -- 3343
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3344
			persistHistoryState(shared) -- 3349
			return ____awaiter_resolve(nil, "done") -- 3349
		end -- 3349
		if result.tool == "finish" then -- 3349
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3353
			shared.response = finalMessage -- 3354
			shared.completion = getCompletionReport(result.params) -- 3355
			shared.done = true -- 3356
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3357
			persistHistoryState(shared) -- 3362
			return ____awaiter_resolve(nil, "done") -- 3362
		end -- 3362
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3365
		shared.step = shared.step + 1 -- 3366
		local step = shared.step -- 3367
		emitAgentEvent(shared, { -- 3368
			type = "decision_made", -- 3369
			sessionId = shared.sessionId, -- 3370
			taskId = shared.taskId, -- 3371
			step = step, -- 3372
			tool = result.tool, -- 3373
			reason = result.reason, -- 3374
			reasoningContent = result.reasoningContent, -- 3375
			params = result.params -- 3376
		}) -- 3376
		local ____shared_history_99 = shared.history -- 3376
		____shared_history_99[#____shared_history_99 + 1] = { -- 3378
			step = step, -- 3379
			toolCallId = toolCallId, -- 3380
			tool = result.tool, -- 3381
			reason = result.reason or "", -- 3382
			reasoningContent = result.reasoningContent, -- 3383
			params = result.params, -- 3384
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3385
		} -- 3385
		local action = shared.history[#shared.history] -- 3387
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3388
		shared.pendingToolActions = {action} -- 3391
		persistHistoryState(shared) -- 3392
		return ____awaiter_resolve(nil, "batch_tools") -- 3392
	end) -- 3392
end -- 3277
local ReadFileAction = __TS__Class() -- 3397
ReadFileAction.name = "ReadFileAction" -- 3397
__TS__ClassExtends(ReadFileAction, Node) -- 3397
function ReadFileAction.prototype.prep(self, shared) -- 3398
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3398
		local last = shared.history[#shared.history] -- 3399
		if not last then -- 3399
			error( -- 3400
				__TS__New(Error, "no history"), -- 3400
				0 -- 3400
			) -- 3400
		end -- 3400
		emitAgentStartEvent(shared, last) -- 3401
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3402
		if __TS__StringTrim(path) == "" then -- 3402
			error( -- 3405
				__TS__New(Error, "missing path"), -- 3405
				0 -- 3405
			) -- 3405
		end -- 3405
		local ____path_102 = path -- 3407
		local ____shared_workingDir_103 = shared.workingDir -- 3409
		local ____temp_104 = shared.useChineseResponse and "zh" or "en" -- 3410
		local ____last_params_startLine_100 = last.params.startLine -- 3411
		if ____last_params_startLine_100 == nil then -- 3411
			____last_params_startLine_100 = 1 -- 3411
		end -- 3411
		local ____TS__Number_result_105 = __TS__Number(____last_params_startLine_100) -- 3411
		local ____last_params_endLine_101 = last.params.endLine -- 3412
		if ____last_params_endLine_101 == nil then -- 3412
			____last_params_endLine_101 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3412
		end -- 3412
		return ____awaiter_resolve( -- 3412
			nil, -- 3412
			{ -- 3406
				path = ____path_102, -- 3407
				tool = "read_file", -- 3408
				workDir = ____shared_workingDir_103, -- 3409
				docLanguage = ____temp_104, -- 3410
				startLine = ____TS__Number_result_105, -- 3411
				endLine = __TS__Number(____last_params_endLine_101) -- 3412
			} -- 3412
		) -- 3412
	end) -- 3412
end -- 3398
function ReadFileAction.prototype.exec(self, input) -- 3416
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3416
		return ____awaiter_resolve( -- 3416
			nil, -- 3416
			Tools.readFile( -- 3417
				input.workDir, -- 3418
				input.path, -- 3419
				__TS__Number(input.startLine or 1), -- 3420
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3421
				input.docLanguage -- 3422
			) -- 3422
		) -- 3422
	end) -- 3422
end -- 3416
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3426
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3426
		local result = execRes -- 3427
		local last = shared.history[#shared.history] -- 3428
		if last ~= nil then -- 3428
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3430
			appendToolResultMessage(shared, last) -- 3431
			emitAgentFinishEvent(shared, last) -- 3432
		end -- 3432
		persistHistoryState(shared) -- 3434
		__TS__Await(maybeCompressHistory(shared)) -- 3435
		persistHistoryState(shared) -- 3436
		return ____awaiter_resolve(nil, "main") -- 3436
	end) -- 3436
end -- 3426
local SearchFilesAction = __TS__Class() -- 3441
SearchFilesAction.name = "SearchFilesAction" -- 3441
__TS__ClassExtends(SearchFilesAction, Node) -- 3441
function SearchFilesAction.prototype.prep(self, shared) -- 3442
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3442
		local last = shared.history[#shared.history] -- 3443
		if not last then -- 3443
			error( -- 3444
				__TS__New(Error, "no history"), -- 3444
				0 -- 3444
			) -- 3444
		end -- 3444
		emitAgentStartEvent(shared, last) -- 3445
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3445
	end) -- 3445
end -- 3442
function SearchFilesAction.prototype.exec(self, input) -- 3449
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3449
		local params = input.params -- 3450
		local ____Tools_searchFiles_120 = Tools.searchFiles -- 3451
		local ____input_workDir_112 = input.workDir -- 3452
		local ____temp_113 = params.path or "" -- 3453
		local ____temp_114 = params.pattern or "" -- 3454
		local ____params_globs_115 = params.globs -- 3455
		local ____params_useRegex_116 = params.useRegex -- 3456
		local ____params_caseSensitive_117 = params.caseSensitive -- 3457
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3459
		local ____math_max_108 = math.max -- 3460
		local ____math_floor_107 = math.floor -- 3460
		local ____params_limit_106 = params.limit -- 3460
		if ____params_limit_106 == nil then -- 3460
			____params_limit_106 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3460
		end -- 3460
		local ____math_max_108_result_119 = ____math_max_108( -- 3460
			1, -- 3460
			____math_floor_107(__TS__Number(____params_limit_106)) -- 3460
		) -- 3460
		local ____math_max_111 = math.max -- 3461
		local ____math_floor_110 = math.floor -- 3461
		local ____params_offset_109 = params.offset -- 3461
		if ____params_offset_109 == nil then -- 3461
			____params_offset_109 = 0 -- 3461
		end -- 3461
		local result = __TS__Await(____Tools_searchFiles_120({ -- 3451
			workDir = ____input_workDir_112, -- 3452
			path = ____temp_113, -- 3453
			pattern = ____temp_114, -- 3454
			globs = ____params_globs_115, -- 3455
			useRegex = ____params_useRegex_116, -- 3456
			caseSensitive = ____params_caseSensitive_117, -- 3457
			includeContent = true, -- 3458
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_118, -- 3459
			limit = ____math_max_108_result_119, -- 3460
			offset = ____math_max_111( -- 3461
				0, -- 3461
				____math_floor_110(__TS__Number(____params_offset_109)) -- 3461
			), -- 3461
			groupByFile = params.groupByFile == true -- 3462
		})) -- 3462
		return ____awaiter_resolve(nil, result) -- 3462
	end) -- 3462
end -- 3449
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3467
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3467
		local last = shared.history[#shared.history] -- 3468
		if last ~= nil then -- 3468
			local result = execRes -- 3470
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3471
			appendToolResultMessage(shared, last) -- 3472
			emitAgentFinishEvent(shared, last) -- 3473
		end -- 3473
		persistHistoryState(shared) -- 3475
		__TS__Await(maybeCompressHistory(shared)) -- 3476
		persistHistoryState(shared) -- 3477
		return ____awaiter_resolve(nil, "main") -- 3477
	end) -- 3477
end -- 3467
local SearchDoraAPIAction = __TS__Class() -- 3482
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3482
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3482
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3483
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3483
		local last = shared.history[#shared.history] -- 3484
		if not last then -- 3484
			error( -- 3485
				__TS__New(Error, "no history"), -- 3485
				0 -- 3485
			) -- 3485
		end -- 3485
		emitAgentStartEvent(shared, last) -- 3486
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3486
	end) -- 3486
end -- 3483
function SearchDoraAPIAction.prototype.exec(self, input) -- 3490
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3490
		local params = input.params -- 3491
		local ____Tools_searchDoraAPI_129 = Tools.searchDoraAPI -- 3492
		local ____temp_125 = params.pattern or "" -- 3493
		local ____temp_126 = params.docSource or "api" -- 3494
		local ____temp_127 = input.useChineseResponse and "zh" or "en" -- 3495
		local ____temp_128 = params.programmingLanguage or "ts" -- 3496
		local ____math_min_124 = math.min -- 3497
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3497
		local ____math_max_122 = math.max -- 3497
		local ____params_limit_121 = params.limit -- 3497
		if ____params_limit_121 == nil then -- 3497
			____params_limit_121 = 8 -- 3497
		end -- 3497
		local result = __TS__Await(____Tools_searchDoraAPI_129({ -- 3492
			pattern = ____temp_125, -- 3493
			docSource = ____temp_126, -- 3494
			docLanguage = ____temp_127, -- 3495
			programmingLanguage = ____temp_128, -- 3496
			limit = ____math_min_124( -- 3497
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_123, -- 3497
				____math_max_122( -- 3497
					1, -- 3497
					__TS__Number(____params_limit_121) -- 3497
				) -- 3497
			), -- 3497
			useRegex = params.useRegex, -- 3498
			caseSensitive = false, -- 3499
			includeContent = true, -- 3500
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3501
		})) -- 3501
		return ____awaiter_resolve(nil, result) -- 3501
	end) -- 3501
end -- 3490
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3506
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
local ListFilesAction = __TS__Class() -- 3521
ListFilesAction.name = "ListFilesAction" -- 3521
__TS__ClassExtends(ListFilesAction, Node) -- 3521
function ListFilesAction.prototype.prep(self, shared) -- 3522
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3522
		local last = shared.history[#shared.history] -- 3523
		if not last then -- 3523
			error( -- 3524
				__TS__New(Error, "no history"), -- 3524
				0 -- 3524
			) -- 3524
		end -- 3524
		emitAgentStartEvent(shared, last) -- 3525
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3525
	end) -- 3525
end -- 3522
function ListFilesAction.prototype.exec(self, input) -- 3529
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3529
		local params = input.params -- 3530
		local ____Tools_listFiles_136 = Tools.listFiles -- 3531
		local ____input_workDir_133 = input.workDir -- 3532
		local ____temp_134 = params.path or "" -- 3533
		local ____params_globs_135 = params.globs -- 3534
		local ____math_max_132 = math.max -- 3535
		local ____math_floor_131 = math.floor -- 3535
		local ____params_maxEntries_130 = params.maxEntries -- 3535
		if ____params_maxEntries_130 == nil then -- 3535
			____params_maxEntries_130 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3535
		end -- 3535
		local result = ____Tools_listFiles_136({ -- 3531
			workDir = ____input_workDir_133, -- 3532
			path = ____temp_134, -- 3533
			globs = ____params_globs_135, -- 3534
			maxEntries = ____math_max_132( -- 3535
				1, -- 3535
				____math_floor_131(__TS__Number(____params_maxEntries_130)) -- 3535
			) -- 3535
		}) -- 3535
		return ____awaiter_resolve(nil, result) -- 3535
	end) -- 3535
end -- 3529
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3540
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3540
		local last = shared.history[#shared.history] -- 3541
		if last ~= nil then -- 3541
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3543
			appendToolResultMessage(shared, last) -- 3544
			emitAgentFinishEvent(shared, last) -- 3545
		end -- 3545
		persistHistoryState(shared) -- 3547
		__TS__Await(maybeCompressHistory(shared)) -- 3548
		persistHistoryState(shared) -- 3549
		return ____awaiter_resolve(nil, "main") -- 3549
	end) -- 3549
end -- 3540
local DeleteFileAction = __TS__Class() -- 3554
DeleteFileAction.name = "DeleteFileAction" -- 3554
__TS__ClassExtends(DeleteFileAction, Node) -- 3554
function DeleteFileAction.prototype.prep(self, shared) -- 3555
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3555
		local last = shared.history[#shared.history] -- 3556
		if not last then -- 3556
			error( -- 3557
				__TS__New(Error, "no history"), -- 3557
				0 -- 3557
			) -- 3557
		end -- 3557
		emitAgentStartEvent(shared, last) -- 3558
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3559
		if __TS__StringTrim(targetFile) == "" then -- 3559
			error( -- 3562
				__TS__New(Error, "missing target_file"), -- 3562
				0 -- 3562
			) -- 3562
		end -- 3562
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3562
	end) -- 3562
end -- 3555
function DeleteFileAction.prototype.exec(self, input) -- 3566
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3566
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3567
		if not result.success then -- 3567
			return ____awaiter_resolve(nil, result) -- 3567
		end -- 3567
		return ____awaiter_resolve(nil, { -- 3567
			success = true, -- 3575
			changed = true, -- 3576
			mode = "delete", -- 3577
			checkpointId = result.checkpointId, -- 3578
			checkpointSeq = result.checkpointSeq, -- 3579
			files = {{path = input.targetFile, op = "delete"}} -- 3580
		}) -- 3580
	end) -- 3580
end -- 3566
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3584
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3584
		local last = shared.history[#shared.history] -- 3585
		if last ~= nil then -- 3585
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3587
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3588
			appendToolResultMessage(shared, last) -- 3589
			emitAgentFinishEvent(shared, last) -- 3590
			local result = last.result -- 3591
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3591
				emitAgentEvent(shared, { -- 3596
					type = "checkpoint_created", -- 3597
					sessionId = shared.sessionId, -- 3598
					taskId = shared.taskId, -- 3599
					step = last.step, -- 3600
					tool = "delete_file", -- 3601
					checkpointId = result.checkpointId, -- 3602
					checkpointSeq = result.checkpointSeq, -- 3603
					files = result.files -- 3604
				}) -- 3604
			end -- 3604
		end -- 3604
		persistHistoryState(shared) -- 3611
		__TS__Await(maybeCompressHistory(shared)) -- 3612
		persistHistoryState(shared) -- 3613
		return ____awaiter_resolve(nil, "main") -- 3613
	end) -- 3613
end -- 3584
local BuildAction = __TS__Class() -- 3618
BuildAction.name = "BuildAction" -- 3618
__TS__ClassExtends(BuildAction, Node) -- 3618
function BuildAction.prototype.prep(self, shared) -- 3619
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3619
		local last = shared.history[#shared.history] -- 3620
		if not last then -- 3620
			error( -- 3621
				__TS__New(Error, "no history"), -- 3621
				0 -- 3621
			) -- 3621
		end -- 3621
		emitAgentStartEvent(shared, last) -- 3622
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3622
	end) -- 3622
end -- 3619
function BuildAction.prototype.exec(self, input) -- 3626
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3626
		local params = input.params -- 3627
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3628
		return ____awaiter_resolve(nil, result) -- 3628
	end) -- 3628
end -- 3626
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3635
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3635
		local last = shared.history[#shared.history] -- 3636
		if last ~= nil then -- 3636
			last.result = sanitizeBuildResultForHistory(execRes) -- 3638
			appendToolResultMessage(shared, last) -- 3639
			emitAgentFinishEvent(shared, last) -- 3640
		end -- 3640
		persistHistoryState(shared) -- 3642
		__TS__Await(maybeCompressHistory(shared)) -- 3643
		persistHistoryState(shared) -- 3644
		return ____awaiter_resolve(nil, "main") -- 3644
	end) -- 3644
end -- 3635
local SpawnSubAgentAction = __TS__Class() -- 3649
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3649
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3649
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3650
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3650
		local last = shared.history[#shared.history] -- 3660
		if not last then -- 3660
			error( -- 3661
				__TS__New(Error, "no history"), -- 3661
				0 -- 3661
			) -- 3661
		end -- 3661
		emitAgentStartEvent(shared, last) -- 3662
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3663
			last.params.filesHint, -- 3664
			function(____, item) return type(item) == "string" end -- 3664
		) or nil -- 3664
		return ____awaiter_resolve( -- 3664
			nil, -- 3664
			{ -- 3666
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3667
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3668
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3669
				filesHint = filesHint, -- 3670
				sessionId = shared.sessionId, -- 3671
				projectRoot = shared.workingDir, -- 3672
				spawnSubAgent = shared.spawnSubAgent, -- 3673
				disabledAgentTools = shared.disabledAgentTools -- 3674
			} -- 3674
		) -- 3674
	end) -- 3674
end -- 3650
function SpawnSubAgentAction.prototype.exec(self, input) -- 3678
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3678
		if not input.spawnSubAgent then -- 3678
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3678
		end -- 3678
		if input.sessionId == nil or input.sessionId <= 0 then -- 3678
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3678
		end -- 3678
		local ____AgentUtils_Log_142 = AgentUtils.Log -- 3694
		local ____temp_139 = #input.title -- 3694
		local ____temp_140 = #input.prompt -- 3694
		local ____temp_141 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3694
		local ____opt_137 = input.filesHint -- 3694
		____AgentUtils_Log_142( -- 3694
			"Info", -- 3694
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_139)) .. " prompt_len=") .. tostring(____temp_140)) .. " expected_len=") .. tostring(____temp_141)) .. " files_hint_count=") .. tostring(____opt_137 and #____opt_137 or 0) -- 3694
		) -- 3694
		local result = __TS__Await(input.spawnSubAgent({ -- 3695
			parentSessionId = input.sessionId, -- 3696
			projectRoot = input.projectRoot, -- 3697
			title = input.title, -- 3698
			prompt = input.prompt, -- 3699
			expectedOutput = input.expectedOutput, -- 3700
			filesHint = input.filesHint, -- 3701
			disabledAgentTools = input.disabledAgentTools -- 3702
		})) -- 3702
		if not result.success then -- 3702
			return ____awaiter_resolve(nil, result) -- 3702
		end -- 3702
		return ____awaiter_resolve(nil, { -- 3702
			success = true, -- 3708
			sessionId = result.sessionId, -- 3709
			taskId = result.taskId, -- 3710
			title = result.title, -- 3711
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3712
		}) -- 3712
	end) -- 3712
end -- 3678
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3716
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3716
		local last = shared.history[#shared.history] -- 3717
		if last ~= nil then -- 3717
			last.result = execRes -- 3719
			if execRes.success == true then -- 3719
				shared.hasSpawnedSubAgentThisTask = true -- 3721
			end -- 3721
			appendToolResultMessage(shared, last) -- 3723
			emitAgentFinishEvent(shared, last) -- 3724
		end -- 3724
		persistHistoryState(shared) -- 3726
		__TS__Await(maybeCompressHistory(shared)) -- 3727
		persistHistoryState(shared) -- 3728
		return ____awaiter_resolve(nil, "main") -- 3728
	end) -- 3728
end -- 3716
local ListSubAgentsAction = __TS__Class() -- 3733
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3733
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3733
function ListSubAgentsAction.prototype.prep(self, shared) -- 3734
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3734
		local last = shared.history[#shared.history] -- 3744
		if not last then -- 3744
			error( -- 3745
				__TS__New(Error, "no history"), -- 3745
				0 -- 3745
			) -- 3745
		end -- 3745
		emitAgentStartEvent(shared, last) -- 3746
		return ____awaiter_resolve( -- 3746
			nil, -- 3746
			{ -- 3747
				sessionId = shared.sessionId, -- 3748
				projectRoot = shared.workingDir, -- 3749
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3750
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3751
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3752
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3753
				listSubAgents = shared.listSubAgents, -- 3754
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3755
			} -- 3755
		) -- 3755
	end) -- 3755
end -- 3734
function ListSubAgentsAction.prototype.exec(self, input) -- 3759
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3759
		if not input.listSubAgents then -- 3759
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3759
		end -- 3759
		if input.sessionId == nil or input.sessionId <= 0 then -- 3759
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3759
		end -- 3759
		local result = __TS__Await(input.listSubAgents({ -- 3775
			sessionId = input.sessionId, -- 3776
			projectRoot = input.projectRoot, -- 3777
			status = input.status, -- 3778
			limit = input.limit, -- 3779
			offset = input.offset, -- 3780
			query = input.query -- 3781
		})) -- 3781
		return ____awaiter_resolve( -- 3781
			nil, -- 3781
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3783
		) -- 3783
	end) -- 3783
end -- 3759
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3791
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3791
		local last = shared.history[#shared.history] -- 3792
		if last ~= nil then -- 3792
			last.result = execRes -- 3794
			appendToolResultMessage(shared, last) -- 3795
			emitAgentFinishEvent(shared, last) -- 3796
		end -- 3796
		persistHistoryState(shared) -- 3798
		__TS__Await(maybeCompressHistory(shared)) -- 3799
		persistHistoryState(shared) -- 3800
		return ____awaiter_resolve(nil, "main") -- 3800
	end) -- 3800
end -- 3791
EditFileAction = __TS__Class() -- 3805
EditFileAction.name = "EditFileAction" -- 3805
__TS__ClassExtends(EditFileAction, Node) -- 3805
function EditFileAction.prototype.prep(self, shared) -- 3806
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3806
		local last = shared.history[#shared.history] -- 3807
		if not last then -- 3807
			error( -- 3808
				__TS__New(Error, "no history"), -- 3808
				0 -- 3808
			) -- 3808
		end -- 3808
		emitAgentStartEvent(shared, last) -- 3809
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3810
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3813
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3814
		if __TS__StringTrim(path) == "" then -- 3814
			error( -- 3815
				__TS__New(Error, "missing path"), -- 3815
				0 -- 3815
			) -- 3815
		end -- 3815
		return ____awaiter_resolve(nil, { -- 3815
			path = path, -- 3816
			oldStr = oldStr, -- 3816
			newStr = newStr, -- 3816
			taskId = shared.taskId, -- 3816
			workDir = shared.workingDir -- 3816
		}) -- 3816
	end) -- 3816
end -- 3806
function EditFileAction.prototype.exec(self, input) -- 3819
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3819
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3820
		if not readRes.success then -- 3820
			if input.oldStr ~= "" then -- 3820
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3820
			end -- 3820
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3825
			if not createRes.success then -- 3825
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3825
			end -- 3825
			return ____awaiter_resolve( -- 3825
				nil, -- 3825
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3832
					success = true, -- 3833
					changed = true, -- 3834
					mode = "create", -- 3835
					checkpointId = createRes.checkpointId, -- 3836
					checkpointSeq = createRes.checkpointSeq, -- 3837
					files = {{path = input.path, op = "create"}} -- 3838
				}) -- 3838
			) -- 3838
		end -- 3838
		if input.oldStr == "" then -- 3838
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3838
				return ____awaiter_resolve( -- 3838
					nil, -- 3838
					{ -- 3843
						success = false, -- 3844
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3845
						actualSaved = false, -- 3846
						actualSavedCharacters = 0, -- 3847
						currentFileExists = true, -- 3848
						currentCharacters = #readRes.content, -- 3849
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3850
					} -- 3850
				) -- 3850
			end -- 3850
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3853
			if not overwriteRes.success then -- 3853
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3853
			end -- 3853
			return ____awaiter_resolve( -- 3853
				nil, -- 3853
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3860
					success = true, -- 3861
					changed = true, -- 3862
					mode = "overwrite", -- 3863
					checkpointId = overwriteRes.checkpointId, -- 3864
					checkpointSeq = overwriteRes.checkpointSeq, -- 3865
					files = {{path = input.path, op = "write"}} -- 3866
				}) -- 3866
			) -- 3866
		end -- 3866
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3871
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3872
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3873
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3876
		if occurrences == 0 then -- 3876
			local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3878
			if not indentTolerant.success then -- 3878
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3878
			end -- 3878
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3882
			if not applyRes.success then -- 3882
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3882
			end -- 3882
			return ____awaiter_resolve( -- 3882
				nil, -- 3882
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3889
					success = true, -- 3890
					changed = true, -- 3891
					mode = "replace_indent_tolerant", -- 3892
					checkpointId = applyRes.checkpointId, -- 3893
					checkpointSeq = applyRes.checkpointSeq, -- 3894
					files = {{path = input.path, op = "write"}} -- 3895
				}) -- 3895
			) -- 3895
		end -- 3895
		if occurrences > 1 then -- 3895
			return ____awaiter_resolve( -- 3895
				nil, -- 3895
				{ -- 3899
					success = false, -- 3899
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3899
				} -- 3899
			) -- 3899
		end -- 3899
		local newContent = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3903
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3904
		if not applyRes.success then -- 3904
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3904
		end -- 3904
		return ____awaiter_resolve( -- 3904
			nil, -- 3904
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3911
				success = true, -- 3912
				changed = true, -- 3913
				mode = "replace", -- 3914
				checkpointId = applyRes.checkpointId, -- 3915
				checkpointSeq = applyRes.checkpointSeq, -- 3916
				files = {{path = input.path, op = "write"}} -- 3917
			}) -- 3917
		) -- 3917
	end) -- 3917
end -- 3819
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3921
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3921
		local last = shared.history[#shared.history] -- 3922
		if last ~= nil then -- 3922
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3924
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3925
			appendToolResultMessage(shared, last) -- 3926
			emitAgentFinishEvent(shared, last) -- 3927
			local result = last.result -- 3928
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3928
				emitAgentEvent(shared, { -- 3933
					type = "checkpoint_created", -- 3934
					sessionId = shared.sessionId, -- 3935
					taskId = shared.taskId, -- 3936
					step = last.step, -- 3937
					tool = last.tool, -- 3938
					checkpointId = result.checkpointId, -- 3939
					checkpointSeq = result.checkpointSeq, -- 3940
					files = result.files -- 3941
				}) -- 3941
			end -- 3941
		end -- 3941
		persistHistoryState(shared) -- 3948
		__TS__Await(maybeCompressHistory(shared)) -- 3949
		persistHistoryState(shared) -- 3950
		return ____awaiter_resolve(nil, "main") -- 3950
	end) -- 3950
end -- 3921
local FetchUrlAction = __TS__Class() -- 3955
FetchUrlAction.name = "FetchUrlAction" -- 3955
__TS__ClassExtends(FetchUrlAction, Node) -- 3955
function FetchUrlAction.prototype.prep(self, shared) -- 3956
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3956
		local last = shared.history[#shared.history] -- 3957
		if not last then -- 3957
			error( -- 3958
				__TS__New(Error, "no history"), -- 3958
				0 -- 3958
			) -- 3958
		end -- 3958
		emitAgentStartEvent(shared, last) -- 3959
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3959
	end) -- 3959
end -- 3956
function FetchUrlAction.prototype.exec(self, input) -- 3963
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3963
		return ____awaiter_resolve( -- 3963
			nil, -- 3963
			executeToolAction(input.shared, input.action) -- 3964
		) -- 3964
	end) -- 3964
end -- 3963
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3967
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3967
		local last = shared.history[#shared.history] -- 3968
		if last ~= nil then -- 3968
			last.result = execRes -- 3970
			appendToolResultMessage(shared, last) -- 3971
			emitAgentFinishEvent(shared, last) -- 3972
		end -- 3972
		persistHistoryState(shared) -- 3974
		__TS__Await(maybeCompressHistory(shared)) -- 3975
		persistHistoryState(shared) -- 3976
		return ____awaiter_resolve(nil, "main") -- 3976
	end) -- 3976
end -- 3967
local function emitCheckpointEventForAction(shared, action) -- 3981
	local result = action.result -- 3982
	if not result then -- 3982
		return -- 3983
	end -- 3983
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3983
		emitAgentEvent(shared, { -- 3988
			type = "checkpoint_created", -- 3989
			sessionId = shared.sessionId, -- 3990
			taskId = shared.taskId, -- 3991
			step = action.step, -- 3992
			tool = action.tool, -- 3993
			checkpointId = result.checkpointId, -- 3994
			checkpointSeq = result.checkpointSeq, -- 3995
			files = result.files -- 3996
		}) -- 3996
	end -- 3996
end -- 3981
local function canRunBatchActionInParallel(self, action) -- 4528
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4529
end -- 4528
local function partitionToolCalls(actions) -- 4537
	local batches = {} -- 4538
	do -- 4538
		local i = 0 -- 4539
		while i < #actions do -- 4539
			local action = actions[i + 1] -- 4540
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4541
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4542
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4542
				local ____lastBatch_actions_175 = lastBatch.actions -- 4542
				____lastBatch_actions_175[#____lastBatch_actions_175 + 1] = action -- 4544
			else -- 4544
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4546
			end -- 4546
			i = i + 1 -- 4539
		end -- 4539
	end -- 4539
	return batches -- 4549
end -- 4537
local function completeStoppedToolAction(shared, action) -- 4552
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4553
	if not action.result then -- 4553
		action.result = { -- 4555
			success = false, -- 4555
			message = getCancelledReason(shared) -- 4555
		} -- 4555
	end -- 4555
	appendToolResultMessage(shared, action) -- 4557
	emitAgentFinishEvent(shared, action) -- 4558
	emitCheckpointEventForAction(shared, action) -- 4559
end -- 4552
local BatchToolAction = __TS__Class() -- 4562
BatchToolAction.name = "BatchToolAction" -- 4562
__TS__ClassExtends(BatchToolAction, Node) -- 4562
function BatchToolAction.prototype.prep(self, shared) -- 4563
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4563
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4563
	end) -- 4563
end -- 4563
function BatchToolAction.prototype.exec(self, input) -- 4567
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4567
		local shared = input.shared -- 4568
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4569
		local preExecuted = shared.preExecutedResults -- 4570
		local batches = partitionToolCalls(input.actions) -- 4571
		local parallelBatchCount = #__TS__ArrayFilter( -- 4572
			batches, -- 4572
			function(____, b) return b.isConcurrencySafe end -- 4572
		) -- 4572
		local serialBatchCount = #__TS__ArrayFilter( -- 4573
			batches, -- 4573
			function(____, b) return not b.isConcurrencySafe end -- 4573
		) -- 4573
		AgentUtils.Log( -- 4574
			"Info", -- 4574
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4574
		) -- 4574
		do -- 4574
			local batchIdx = 0 -- 4576
			while batchIdx < #batches do -- 4576
				do -- 4576
					local batch = batches[batchIdx + 1] -- 4577
					if shared.stopToken.stopped then -- 4577
						for ____, action in ipairs(batch.actions) do -- 4579
							completeStoppedToolAction(shared, action) -- 4580
						end -- 4580
						goto __continue754 -- 4582
					end -- 4582
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4582
						local preExecCount = #__TS__ArrayFilter( -- 4586
							batch.actions, -- 4586
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4586
						) -- 4586
						AgentUtils.Log( -- 4587
							"Info", -- 4587
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4587
						) -- 4587
						do -- 4587
							local i = 0 -- 4588
							while i < #batch.actions do -- 4588
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4589
								i = i + 1 -- 4588
							end -- 4588
						end -- 4588
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4591
							batch.actions, -- 4591
							function(____, action) -- 4591
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4591
									if shared.stopToken.stopped then -- 4591
										action.result = { -- 4593
											success = false, -- 4593
											message = getCancelledReason(shared) -- 4593
										} -- 4593
										return ____awaiter_resolve(nil, action) -- 4593
									end -- 4593
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4596
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4597
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4598
									return ____awaiter_resolve(nil, action) -- 4598
								end) -- 4598
							end -- 4591
						))) -- 4591
						do -- 4591
							local i = 0 -- 4601
							while i < #batch.actions do -- 4601
								local action = batch.actions[i + 1] -- 4602
								if not action.result then -- 4602
									action.result = {success = false, message = "tool did not produce a result"} -- 4604
								end -- 4604
								appendToolResultMessage(shared, action) -- 4606
								emitAgentFinishEvent(shared, action) -- 4607
								emitCheckpointEventForAction(shared, action) -- 4608
								i = i + 1 -- 4601
							end -- 4601
						end -- 4601
					else -- 4601
						AgentUtils.Log( -- 4611
							"Info", -- 4611
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4611
						) -- 4611
						do -- 4611
							local i = 0 -- 4612
							while i < #batch.actions do -- 4612
								local action = batch.actions[i + 1] -- 4613
								emitAgentStartEvent(shared, action) -- 4614
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4615
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4616
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4617
								appendToolResultMessage(shared, action) -- 4618
								emitAgentFinishEvent(shared, action) -- 4619
								emitCheckpointEventForAction(shared, action) -- 4620
								persistHistoryState(shared) -- 4621
								if shared.stopToken.stopped then -- 4621
									do -- 4621
										local j = i + 1 -- 4623
										while j < #batch.actions do -- 4623
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4624
											j = j + 1 -- 4623
										end -- 4623
									end -- 4623
									break -- 4626
								end -- 4626
								i = i + 1 -- 4612
							end -- 4612
						end -- 4612
					end -- 4612
				end -- 4612
				::__continue754:: -- 4612
				batchIdx = batchIdx + 1 -- 4576
			end -- 4576
		end -- 4576
		local spawnSeen = spawnedBeforeBatch -- 4631
		local didDelegatedForegroundWork = false -- 4632
		do -- 4632
			local i = 0 -- 4633
			while i < #input.actions do -- 4633
				do -- 4633
					local action = input.actions[i + 1] -- 4634
					if action.tool == "spawn_sub_agent" then -- 4634
						local ____opt_178 = action.result -- 4634
						if (____opt_178 and ____opt_178.success) == true then -- 4634
							spawnSeen = true -- 4636
						end -- 4636
						goto __continue774 -- 4637
					end -- 4637
					if spawnSeen and action.tool ~= "finish" then -- 4637
						didDelegatedForegroundWork = true -- 4640
					end -- 4640
				end -- 4640
				::__continue774:: -- 4640
				i = i + 1 -- 4633
			end -- 4633
		end -- 4633
		if didDelegatedForegroundWork then -- 4633
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4644
		end -- 4644
		persistHistoryState(shared) -- 4646
		return ____awaiter_resolve(nil, input.actions) -- 4646
	end) -- 4646
end -- 4567
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4650
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4650
		shared.pendingToolActions = nil -- 4651
		shared.preExecutedResults = nil -- 4652
		persistHistoryState(shared) -- 4653
		__TS__Await(maybeCompressHistory(shared)) -- 4654
		persistHistoryState(shared) -- 4655
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4655
	end) -- 4655
end -- 4650
local EndNode = __TS__Class() -- 4660
EndNode.name = "EndNode" -- 4660
__TS__ClassExtends(EndNode, Node) -- 4660
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4661
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4661
		return ____awaiter_resolve(nil, nil) -- 4661
	end) -- 4661
end -- 4661
local CodingAgentFlow = __TS__Class() -- 4666
CodingAgentFlow.name = "CodingAgentFlow" -- 4666
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4666
function CodingAgentFlow.prototype.____constructor(self, role) -- 4667
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4668
	local read = __TS__New(ReadFileAction, 1, 0) -- 4669
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4670
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4671
	local list = __TS__New(ListFilesAction, 1, 0) -- 4672
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4673
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4674
	local build = __TS__New(BuildAction, 1, 0) -- 4675
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4676
	local edit = __TS__New(EditFileAction, 1, 0) -- 4677
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4678
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4679
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4680
	local done = __TS__New(EndNode, 1, 0) -- 4681
	main:on("batch_tools", batch) -- 4683
	main:on("grep_files", search) -- 4684
	main:on("search_dora_api", searchDora) -- 4685
	main:on("glob_files", list) -- 4686
	main:on("fetch_url", fetch) -- 4687
	main:on("execute_command", exec) -- 4688
	if role == "main" then -- 4688
		main:on("read_file", read) -- 4690
		main:on("delete_file", del) -- 4691
		main:on("build", build) -- 4692
		main:on("edit_file", edit) -- 4693
		main:on("list_sub_agents", listSub) -- 4694
		main:on("spawn_sub_agent", spawn) -- 4695
	else -- 4695
		main:on("read_file", read) -- 4697
		main:on("delete_file", del) -- 4698
		main:on("build", build) -- 4699
		main:on("edit_file", edit) -- 4700
	end -- 4700
	main:on("done", done) -- 4702
	search:on("main", main) -- 4704
	searchDora:on("main", main) -- 4705
	list:on("main", main) -- 4706
	listSub:on("main", main) -- 4707
	spawn:on("main", main) -- 4708
	batch:on("main", main) -- 4709
	batch:on("done", done) -- 4710
	read:on("main", main) -- 4711
	del:on("main", main) -- 4712
	build:on("main", main) -- 4713
	edit:on("main", main) -- 4714
	fetch:on("main", main) -- 4715
	exec:on("main", main) -- 4716
	Flow.prototype.____constructor(self, main) -- 4718
end -- 4667
local function runCodingAgentAsync(options) -- 4754
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4754
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4754
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4754
		end -- 4754
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4758
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or AgentUtils.getActiveLLMConfig() -- 4759
		if not llmConfigRes.success then -- 4759
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4759
		end -- 4759
		local llmConfig = llmConfigRes.config -- 4765
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4766
		if not taskRes.success then -- 4766
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4766
		end -- 4766
		local compressor = __TS__New(MemoryCompressor, { -- 4773
			compressionTargetThreshold = 0.5, -- 4774
			maxCompressionRounds = 3, -- 4775
			projectDir = options.workDir, -- 4776
			llmConfig = llmConfig, -- 4777
			promptPack = options.promptPack, -- 4778
			scope = options.memoryScope -- 4779
		}) -- 4779
		local persistedSession = compressor:getStorage():readSessionState() -- 4781
		local effectiveUserQuery = normalizedPrompt -- 4782
		if options.resumeConversation == true then -- 4782
			do -- 4782
				local i = #persistedSession.messages - 1 -- 4784
				while i >= 0 do -- 4784
					local message = persistedSession.messages[i + 1] -- 4785
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4785
						effectiveUserQuery = message.content -- 4787
						break -- 4788
					end -- 4788
					i = i - 1 -- 4784
				end -- 4784
			end -- 4784
		end -- 4784
		local promptPack = compressor:getPromptPack() -- 4792
		local freshProject = inspectFreshProject(options.workDir) -- 4793
		local freshProjectBuildPending = freshProject.fresh -- 4794
		local freshProjectCodeFile = freshProject.codeFile -- 4795
		local shared = { -- 4797
			sessionId = options.sessionId, -- 4798
			taskId = taskRes.taskId, -- 4799
			role = options.role or "main", -- 4800
			maxSteps = math.max( -- 4801
				1, -- 4801
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4801
			), -- 4801
			llmMaxTry = math.max( -- 4802
				1, -- 4802
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4802
			), -- 4802
			step = 0, -- 4803
			done = false, -- 4804
			stopToken = options.stopToken or ({stopped = false}), -- 4805
			response = "", -- 4806
			userQuery = effectiveUserQuery, -- 4807
			workingDir = options.workDir, -- 4808
			useChineseResponse = options.useChineseResponse == true, -- 4809
			workMode = options.workMode or "code", -- 4810
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4811
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4814
			llmConfig = llmConfig, -- 4815
			onEvent = options.onEvent, -- 4816
			promptPack = promptPack, -- 4817
			history = {}, -- 4818
			messages = persistedSession.messages, -- 4819
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4820
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4821
			memory = {compressor = compressor}, -- 4823
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4827
				projectDir = options.workDir, -- 4829
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4830
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4831
			})}, -- 4831
			spawnSubAgent = options.spawnSubAgent, -- 4837
			listSubAgents = options.listSubAgents, -- 4838
			publishQuestionnaire = options.publishQuestionnaire, -- 4839
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4840
			freshProjectBuildPending = freshProjectBuildPending, -- 4841
			freshProjectCodeFile = freshProjectCodeFile, -- 4842
			hasSpawnedSubAgentThisTask = false, -- 4843
			delegatedForegroundBatches = 0 -- 4844
		} -- 4844
		local ____hasReturned, ____returnValue -- 4844
		local ____try = __TS__AsyncAwaiter(function() -- 4844
			if shared.workMode == "plan" then -- 4844
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4849
				if not planDocuments.success then -- 4849
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4851
					____hasReturned = true -- 4852
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4852
					return -- 4852
				end -- 4852
			end -- 4852
			emitAgentEvent(shared, { -- 4855
				type = "task_started", -- 4856
				sessionId = shared.sessionId, -- 4857
				taskId = shared.taskId, -- 4858
				prompt = shared.userQuery, -- 4859
				workDir = shared.workingDir, -- 4860
				maxSteps = shared.maxSteps -- 4861
			}) -- 4861
			if shared.stopToken.stopped then -- 4861
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4864
				____hasReturned = true -- 4865
				____returnValue = emitAgentTaskFinishEvent( -- 4865
					shared, -- 4865
					false, -- 4865
					getCancelledReason(shared) -- 4865
				) -- 4865
				return -- 4865
			end -- 4865
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4867
			local ____temp_180 -- 4868
			if options.resumeConversation == true then -- 4868
				____temp_180 = nil -- 4868
			else -- 4868
				____temp_180 = getPromptCommand(shared.userQuery) -- 4868
			end -- 4868
			local promptCommand = ____temp_180 -- 4868
			if promptCommand == "clear" then -- 4868
				____hasReturned = true -- 4870
				____returnValue = clearSessionHistory(shared) -- 4870
				return -- 4870
			end -- 4870
			if promptCommand == "compact" then -- 4870
				if shared.role == "sub" then -- 4870
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4874
					____hasReturned = true -- 4875
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4875
					return -- 4875
				end -- 4875
				____hasReturned = true -- 4883
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4883
				return -- 4883
			end -- 4883
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4885
			if shared.stopToken.stopped then -- 4885
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4887
				____hasReturned = true -- 4888
				____returnValue = emitAgentTaskFinishEvent( -- 4888
					shared, -- 4888
					false, -- 4888
					getCancelledReason(shared) -- 4888
				) -- 4888
				return -- 4888
			end -- 4888
			if options.resumeConversation ~= true then -- 4888
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4891
				persistHistoryState(shared) -- 4895
			end -- 4895
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4897
			__TS__Await(flow:run(shared)) -- 4898
			if shared.stopToken.stopped then -- 4898
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4900
				____hasReturned = true -- 4901
				____returnValue = emitAgentTaskFinishEvent( -- 4901
					shared, -- 4901
					false, -- 4901
					getCancelledReason(shared) -- 4901
				) -- 4901
				return -- 4901
			end -- 4901
			if shared.error then -- 4901
				____hasReturned = true -- 4904
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4904
				return -- 4904
			end -- 4904
			if shared.waitingQuestionnaireId ~= nil then -- 4904
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4908
				emitAgentEvent(shared, { -- 4909
					type = "task_waiting_for_user", -- 4910
					sessionId = shared.sessionId, -- 4911
					taskId = shared.taskId, -- 4912
					step = shared.step, -- 4913
					questionnaireId = shared.waitingQuestionnaireId -- 4914
				}) -- 4914
				____hasReturned = true -- 4916
				____returnValue = { -- 4916
					success = true, -- 4917
					taskId = shared.taskId, -- 4918
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4919
					steps = shared.step, -- 4920
					waitingForUser = true, -- 4921
					questionnaireId = shared.waitingQuestionnaireId -- 4922
				} -- 4922
				return -- 4916
			end -- 4916
			local ____isFinalDecisionTurn_result_183 = isFinalDecisionTurn(shared) -- 4925
			if ____isFinalDecisionTurn_result_183 then -- 4925
				local ____opt_181 = shared.completion -- 4925
				____isFinalDecisionTurn_result_183 = (____opt_181 and ____opt_181.outcome) == "partial" -- 4925
			end -- 4925
			if ____isFinalDecisionTurn_result_183 then -- 4925
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4926
				____hasReturned = true -- 4927
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4927
				return -- 4927
			end -- 4927
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4930
			____hasReturned = true -- 4931
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4931
			return -- 4931
		end) -- 4931
		____try = ____try.catch( -- 4931
			____try, -- 4931
			function(____, e) -- 4931
				return __TS__AsyncAwaiter(function() -- 4931
					____hasReturned = true -- 4934
					____returnValue = finalizeAgentFailure( -- 4934
						shared, -- 4934
						tostring(e) -- 4934
					) -- 4934
					return -- 4934
				end) -- 4934
			end -- 4934
		) -- 4934
		__TS__Await(____try) -- 4847
		if ____hasReturned then -- 4847
			return ____awaiter_resolve(nil, ____returnValue) -- 4847
		end -- 4847
	end) -- 4847
end -- 4754
function ____exports.runCodingAgent(options, callback) -- 4938
	local ____self_184 = runCodingAgentAsync(options) -- 4938
	____self_184["then"]( -- 4938
		____self_184, -- 4938
		function(____, result) return callback(result) end -- 4939
	) -- 4939
end -- 4938
return ____exports -- 4938