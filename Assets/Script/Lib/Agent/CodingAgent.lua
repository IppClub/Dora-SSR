-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local isArray, stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, getFinishMessage, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, HISTORY_READ_FILE_MAX_CHARS, HISTORY_READ_FILE_MAX_LINES, READ_FILE_DEFAULT_LIMIT, HISTORY_SEARCH_FILES_MAX_MATCHES, HISTORY_SEARCH_DORA_API_MAX_MATCHES, HISTORY_LIST_FILES_MAX_ENTRIES, HISTORY_BUILD_MAX_MESSAGES, HISTORY_BUILD_MESSAGE_MAX_CHARS, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT, SEARCH_PREVIEW_CONTEXT, EditFileAction -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLM = ____Utils.callLLM -- 4
local callLLMStreamAggregated = ____Utils.callLLMStreamAggregated -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local createLocalToolCallId = ____Utils.createLocalToolCallId -- 4
local parseSimpleXMLChildren = ____Utils.parseSimpleXMLChildren -- 4
local parseXMLObjectFromText = ____Utils.parseXMLObjectFromText -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local estimateTextTokens = ____Utils.estimateTextTokens -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
function isArray(value) -- 14
	return __TS__ArrayIsArray(value) -- 15
end -- 15
function stripWrappingQuotes(value) -- 44
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 45
	result = string.gsub(result, "^'(.*)'$", "%1") -- 46
	return result -- 47
end -- 47
function parseSimpleYAML(text) -- 97
	if not text or __TS__StringTrim(text) == "" then -- 97
		return nil -- 99
	end -- 99
	local result = {} -- 102
	local lines = __TS__StringSplit(text, "\n") -- 103
	local currentKey = "" -- 104
	local currentArray = nil -- 105
	do -- 105
		local i = 0 -- 107
		while i < #lines do -- 107
			do -- 107
				local line = lines[i + 1] -- 108
				local trimmed = __TS__StringTrim(line) -- 109
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 109
					goto __continue16 -- 112
				end -- 112
				if __TS__StringStartsWith(trimmed, "- ") then -- 112
					if currentArray ~= nil and currentKey ~= "" then -- 112
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 117
						local cleaned = stripWrappingQuotes(value) -- 118
						currentArray[#currentArray + 1] = cleaned -- 119
					end -- 119
					goto __continue16 -- 121
				end -- 121
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 124
				if colonIndex > 0 then -- 124
					if currentArray ~= nil and currentKey ~= "" then -- 124
						result[currentKey] = currentArray -- 127
						currentArray = nil -- 128
					end -- 128
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 131
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 132
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 132
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 135
						local items = __TS__ArrayMap( -- 136
							__TS__StringSplit(arrayText, ","), -- 136
							function(____, item) -- 136
								local cleaned = stripWrappingQuotes(__TS__StringTrim(item)) -- 137
								return cleaned -- 138
							end -- 136
						) -- 136
						result[key] = items -- 140
						goto __continue16 -- 141
					end -- 141
					if value == "true" then -- 141
						result[key] = true -- 145
						goto __continue16 -- 146
					end -- 146
					if value == "false" then -- 146
						result[key] = false -- 149
						goto __continue16 -- 150
					end -- 150
					if value == "" then -- 150
						currentKey = key -- 154
						currentArray = {} -- 155
						if i + 1 < #lines then -- 155
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 157
							if not __TS__StringStartsWith(nextLine, "- ") then -- 157
								currentArray = nil -- 159
								result[key] = "" -- 160
							end -- 160
						else -- 160
							currentArray = nil -- 163
							result[key] = "" -- 164
						end -- 164
						goto __continue16 -- 166
					end -- 166
					local cleaned = stripWrappingQuotes(value) -- 169
					result[key] = cleaned -- 170
					currentKey = "" -- 171
					currentArray = nil -- 172
				end -- 172
			end -- 172
			::__continue16:: -- 172
			i = i + 1 -- 107
		end -- 107
	end -- 107
	if currentArray ~= nil and currentKey ~= "" then -- 107
		result[currentKey] = currentArray -- 177
	end -- 177
	return result -- 180
end -- 180
function emitAgentEvent(shared, event) -- 774
	if shared.onEvent then -- 774
		do -- 774
			local function ____catch(____error) -- 774
				Log( -- 779
					"Error", -- 779
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 779
				) -- 779
			end -- 779
			local ____try, ____hasReturned = pcall(function() -- 779
				shared:onEvent(event) -- 777
			end) -- 777
			if not ____try then -- 777
				____catch(____hasReturned) -- 777
			end -- 777
		end -- 777
	end -- 777
end -- 777
function getCancelledReason(shared) -- 908
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 908
		return shared.stopToken.reason -- 909
	end -- 909
	return shared.useChineseResponse and "已取消" or "cancelled" -- 910
end -- 910
function truncateText(text, maxLen) -- 1091
	if #text <= maxLen then -- 1091
		return text -- 1092
	end -- 1092
	local nextPos = utf8.offset(text, maxLen + 1) -- 1093
	if nextPos == nil then -- 1093
		return text -- 1094
	end -- 1094
	return string.sub(text, 1, nextPos - 1) .. "..." -- 1095
end -- 1095
function utf8TakeHead(text, maxChars) -- 1098
	if maxChars <= 0 or text == "" then -- 1098
		return "" -- 1099
	end -- 1099
	local nextPos = utf8.offset(text, maxChars + 1) -- 1100
	if nextPos == nil then -- 1100
		return text -- 1101
	end -- 1101
	return string.sub(text, 1, nextPos - 1) -- 1102
end -- 1102
function getReplyLanguageDirective(shared) -- 1105
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 1106
end -- 1106
function replacePromptVars(template, vars) -- 1111
	local output = template -- 1112
	for key in pairs(vars) do -- 1113
		output = table.concat( -- 1114
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1114
			vars[key] or "" or "," -- 1114
		) -- 1114
	end -- 1114
	return output -- 1116
end -- 1116
function limitReadContentForHistory(content, tool) -- 1119
	local lines = __TS__StringSplit(content, "\n") -- 1120
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1121
	local limitedByLines = overLineLimit and table.concat( -- 1122
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1123
		"\n" -- 1123
	) or content -- 1123
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1123
		return content -- 1126
	end -- 1126
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1128
	local reasons = {} -- 1131
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1131
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1132
	end -- 1132
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1132
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1133
	end -- 1133
	local hint = "Narrow the requested line range." -- 1134
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1135
end -- 1135
function sanitizeReadResultForHistory(tool, result) -- 1150
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1150
		return result -- 1152
	end -- 1152
	local clone = {} -- 1154
	for key in pairs(result) do -- 1155
		clone[key] = result[key] -- 1156
	end -- 1156
	clone.content = limitReadContentForHistory(result.content, tool) -- 1158
	return clone -- 1159
end -- 1159
function sanitizeSearchMatchesForHistory(items, maxItems) -- 1162
	local shown = math.min(#items, maxItems) -- 1166
	local out = {} -- 1167
	do -- 1167
		local i = 0 -- 1168
		while i < shown do -- 1168
			local row = items[i + 1] -- 1169
			out[#out + 1] = { -- 1170
				file = row.file, -- 1171
				line = row.line, -- 1172
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1173
			} -- 1173
			i = i + 1 -- 1168
		end -- 1168
	end -- 1168
	return out -- 1178
end -- 1178
function sanitizeSearchResultForHistory(tool, result) -- 1181
	if result.success ~= true or not isArray(result.results) then -- 1181
		return result -- 1185
	end -- 1185
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1185
		return result -- 1186
	end -- 1186
	local clone = {} -- 1187
	for key in pairs(result) do -- 1188
		clone[key] = result[key] -- 1189
	end -- 1189
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1191
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1192
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1192
		local grouped = result.groupedResults -- 1197
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1198
		local sanitizedGroups = {} -- 1199
		do -- 1199
			local i = 0 -- 1200
			while i < shown do -- 1200
				local row = grouped[i + 1] -- 1201
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1202
					file = row.file, -- 1203
					totalMatches = row.totalMatches, -- 1204
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1205
				} -- 1205
				i = i + 1 -- 1200
			end -- 1200
		end -- 1200
		clone.groupedResults = sanitizedGroups -- 1210
	end -- 1210
	return clone -- 1212
end -- 1212
function sanitizeListFilesResultForHistory(result) -- 1215
	if result.success ~= true or not isArray(result.files) then -- 1215
		return result -- 1216
	end -- 1216
	local clone = {} -- 1217
	for key in pairs(result) do -- 1218
		clone[key] = result[key] -- 1219
	end -- 1219
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1221
	return clone -- 1222
end -- 1222
function sanitizeBuildResultForHistory(result) -- 1225
	if not isArray(result.messages) then -- 1225
		return result -- 1226
	end -- 1226
	local clone = {} -- 1227
	for key in pairs(result) do -- 1228
		clone[key] = result[key] -- 1229
	end -- 1229
	local messages = result.messages -- 1231
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1232
	local sanitized = {} -- 1233
	do -- 1233
		local i = 0 -- 1234
		while i < shown do -- 1234
			local item = messages[i + 1] -- 1235
			local next = {} -- 1236
			for key in pairs(item) do -- 1237
				local value = item[key] -- 1238
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1239
			end -- 1239
			sanitized[#sanitized + 1] = next -- 1243
			i = i + 1 -- 1234
		end -- 1234
	end -- 1234
	clone.messages = sanitized -- 1245
	if #messages > shown then -- 1245
		clone.truncatedMessages = #messages - shown -- 1247
	end -- 1247
	return clone -- 1249
end -- 1249
function getDecisionToolDefinitions(shared) -- 1267
	local base = replacePromptVars( -- 1268
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1269
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1270
	) -- 1270
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1272
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1293
		getAllowedToolsForRole(shared.role), -- 1294
		", " -- 1294
	) or "" -- 1294
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1296
	if (shared and shared.decisionMode) ~= "xml" then -- 1296
		return withRole -- 1298
	end -- 1298
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1300
end -- 1300
function getFinishMessage(params, fallback) -- 1599
	if fallback == nil then -- 1599
		fallback = "" -- 1599
	end -- 1599
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1599
		return __TS__StringTrim(params.message) -- 1601
	end -- 1601
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1601
		return __TS__StringTrim(params.response) -- 1604
	end -- 1604
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1604
		return __TS__StringTrim(params.summary) -- 1607
	end -- 1607
	return __TS__StringTrim(fallback) -- 1609
end -- 1609
function persistHistoryState(shared) -- 1612
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1613
end -- 1613
function getActiveConversationMessages(shared) -- 1620
	local activeMessages = {} -- 1621
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1621
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1628
	end -- 1628
	do -- 1628
		local i = shared.lastConsolidatedIndex -- 1632
		while i < #shared.messages do -- 1632
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1633
			i = i + 1 -- 1632
		end -- 1632
	end -- 1632
	return activeMessages -- 1635
end -- 1635
function getActiveRealMessageCount(shared) -- 1638
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1639
end -- 1639
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1642
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1647
	local previousActiveStart = shared.lastConsolidatedIndex -- 1648
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1649
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1650
	if type(carryMessageIndex) == "number" then -- 1650
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1650
		else -- 1650
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1658
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1661
		end -- 1661
	else -- 1661
		shared.carryMessageIndex = nil -- 1666
	end -- 1666
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1666
		shared.carryMessageIndex = nil -- 1676
	end -- 1676
end -- 1676
function getDecisionPath(params) -- 1934
	if type(params.path) == "string" then -- 1934
		return __TS__StringTrim(params.path) -- 1935
	end -- 1935
	if type(params.target_file) == "string" then -- 1935
		return __TS__StringTrim(params.target_file) -- 1936
	end -- 1936
	return "" -- 1937
end -- 1937
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1940
	local num = __TS__Number(value) -- 1941
	if not __TS__NumberIsFinite(num) then -- 1941
		num = fallback -- 1942
	end -- 1942
	num = math.floor(num) -- 1943
	if num < minValue then -- 1943
		num = minValue -- 1944
	end -- 1944
	if maxValue ~= nil and num > maxValue then -- 1944
		num = maxValue -- 1945
	end -- 1945
	return num -- 1946
end -- 1946
function parseReadLineParam(value, fallback, paramName) -- 1949
	local num = __TS__Number(value) -- 1954
	if not __TS__NumberIsFinite(num) then -- 1954
		num = fallback -- 1955
	end -- 1955
	num = math.floor(num) -- 1956
	if num == 0 then -- 1956
		return {success = false, message = paramName .. " cannot be 0"} -- 1958
	end -- 1958
	return {success = true, value = num} -- 1960
end -- 1960
function validateDecision(tool, params) -- 1963
	if tool == "finish" then -- 1963
		local message = getFinishMessage(params) -- 1968
		if message == "" then -- 1968
			return {success = false, message = "finish requires params.message"} -- 1969
		end -- 1969
		params.message = message -- 1970
		return {success = true, params = params} -- 1971
	end -- 1971
	if tool == "read_file" then -- 1971
		local path = getDecisionPath(params) -- 1975
		if path == "" then -- 1975
			return {success = false, message = "read_file requires path"} -- 1976
		end -- 1976
		params.path = path -- 1977
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1978
		if not startLineRes.success then -- 1978
			return startLineRes -- 1979
		end -- 1979
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1980
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1981
		if not endLineRes.success then -- 1981
			return endLineRes -- 1982
		end -- 1982
		params.startLine = startLineRes.value -- 1983
		params.endLine = endLineRes.value -- 1984
		return {success = true, params = params} -- 1985
	end -- 1985
	if tool == "edit_file" then -- 1985
		local path = getDecisionPath(params) -- 1989
		if path == "" then -- 1989
			return {success = false, message = "edit_file requires path"} -- 1990
		end -- 1990
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1991
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1992
		params.path = path -- 1993
		params.old_str = oldStr -- 1994
		params.new_str = newStr -- 1995
		return {success = true, params = params} -- 1996
	end -- 1996
	if tool == "delete_file" then -- 1996
		local targetFile = getDecisionPath(params) -- 2000
		if targetFile == "" then -- 2000
			return {success = false, message = "delete_file requires target_file"} -- 2001
		end -- 2001
		params.target_file = targetFile -- 2002
		return {success = true, params = params} -- 2003
	end -- 2003
	if tool == "grep_files" then -- 2003
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2007
		if pattern == "" then -- 2007
			return {success = false, message = "grep_files requires pattern"} -- 2008
		end -- 2008
		params.pattern = pattern -- 2009
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2010
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2011
		return {success = true, params = params} -- 2012
	end -- 2012
	if tool == "search_dora_api" then -- 2012
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2016
		if pattern == "" then -- 2016
			return {success = false, message = "search_dora_api requires pattern"} -- 2017
		end -- 2017
		params.pattern = pattern -- 2018
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2019
		return {success = true, params = params} -- 2020
	end -- 2020
	if tool == "glob_files" then -- 2020
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2024
		return {success = true, params = params} -- 2025
	end -- 2025
	if tool == "build" then -- 2025
		local path = getDecisionPath(params) -- 2029
		if path ~= "" then -- 2029
			params.path = path -- 2031
		end -- 2031
		return {success = true, params = params} -- 2033
	end -- 2033
	if tool == "list_sub_agents" then -- 2033
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2037
		if status ~= "" then -- 2037
			params.status = status -- 2039
		end -- 2039
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2041
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2042
		if type(params.query) == "string" then -- 2042
			params.query = __TS__StringTrim(params.query) -- 2044
		end -- 2044
		return {success = true, params = params} -- 2046
	end -- 2046
	if tool == "spawn_sub_agent" then -- 2046
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2050
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2051
		if prompt == "" then -- 2051
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2052
		end -- 2052
		if title == "" then -- 2052
			return {success = false, message = "spawn_sub_agent requires title"} -- 2053
		end -- 2053
		params.prompt = prompt -- 2054
		params.title = title -- 2055
		if type(params.expectedOutput) == "string" then -- 2055
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2057
		end -- 2057
		if isArray(params.filesHint) then -- 2057
			params.filesHint = __TS__ArrayMap( -- 2060
				__TS__ArrayFilter( -- 2060
					params.filesHint, -- 2060
					function(____, item) return type(item) == "string" end -- 2061
				), -- 2061
				function(____, item) return sanitizeUTF8(item) end -- 2062
			) -- 2062
		end -- 2062
		return {success = true, params = params} -- 2064
	end -- 2064
	return {success = true, params = params} -- 2067
end -- 2067
function getAllowedToolsForRole(role) -- 2093
	return role == "main" and ({ -- 2094
		"read_file", -- 2095
		"edit_file", -- 2095
		"delete_file", -- 2095
		"grep_files", -- 2095
		"search_dora_api", -- 2095
		"glob_files", -- 2095
		"build", -- 2095
		"list_sub_agents", -- 2095
		"spawn_sub_agent", -- 2095
		"finish" -- 2095
	}) or ({ -- 2095
		"read_file", -- 2096
		"edit_file", -- 2096
		"delete_file", -- 2096
		"grep_files", -- 2096
		"search_dora_api", -- 2096
		"glob_files", -- 2096
		"build", -- 2096
		"finish" -- 2096
	}) -- 2096
end -- 2096
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2202
	if includeToolDefinitions == nil then -- 2202
		includeToolDefinitions = false -- 2202
	end -- 2202
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2203
	local sections = { -- 2206
		shared.promptPack.agentIdentityPrompt, -- 2207
		rolePrompt, -- 2208
		getReplyLanguageDirective(shared) -- 2209
	} -- 2209
	if shared.decisionMode == "tool_calling" then -- 2209
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2212
	end -- 2212
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2214
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2215
	if memoryContext ~= "" then -- 2215
		sections[#sections + 1] = memoryContext -- 2217
	end -- 2217
	if includeToolDefinitions then -- 2217
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2220
		if shared.decisionMode == "xml" then -- 2220
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2222
		end -- 2222
	end -- 2222
	local skillsSection = buildSkillsSection(shared) -- 2226
	if skillsSection ~= "" then -- 2226
		sections[#sections + 1] = skillsSection -- 2228
	end -- 2228
	return table.concat(sections, "\n\n") -- 2230
end -- 2230
function buildSkillsSection(shared) -- 2233
	local ____opt_42 = shared.skills -- 2233
	if not (____opt_42 and ____opt_42.loader) then -- 2233
		return "" -- 2235
	end -- 2235
	return shared.skills.loader:buildSkillsPromptSection() -- 2237
end -- 2237
function buildXmlDecisionInstruction(shared, feedback) -- 2355
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2356
end -- 2356
function executeToolAction(shared, action) -- 3539
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3539
		if shared.stopToken.stopped then -- 3539
			return ____awaiter_resolve( -- 3539
				nil, -- 3539
				{ -- 3541
					success = false, -- 3541
					message = getCancelledReason(shared) -- 3541
				} -- 3541
			) -- 3541
		end -- 3541
		local params = action.params -- 3543
		if action.tool == "read_file" then -- 3543
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3545
			if __TS__StringTrim(path) == "" then -- 3545
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3545
			end -- 3545
			local ____Tools_readFile_104 = Tools.readFile -- 3549
			local ____shared_workingDir_102 = shared.workingDir -- 3550
			local ____params_startLine_100 = params.startLine -- 3552
			if ____params_startLine_100 == nil then -- 3552
				____params_startLine_100 = 1 -- 3552
			end -- 3552
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3552
			local ____params_endLine_101 = params.endLine -- 3553
			if ____params_endLine_101 == nil then -- 3553
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3553
			end -- 3553
			return ____awaiter_resolve( -- 3553
				nil, -- 3553
				____Tools_readFile_104( -- 3549
					____shared_workingDir_102, -- 3550
					path, -- 3551
					____TS__Number_result_103, -- 3552
					__TS__Number(____params_endLine_101), -- 3553
					shared.useChineseResponse and "zh" or "en" -- 3554
				) -- 3554
			) -- 3554
		end -- 3554
		if action.tool == "grep_files" then -- 3554
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3558
			local ____shared_workingDir_111 = shared.workingDir -- 3559
			local ____temp_112 = params.path or "" -- 3560
			local ____temp_113 = params.pattern or "" -- 3561
			local ____params_globs_114 = params.globs -- 3562
			local ____params_useRegex_115 = params.useRegex -- 3563
			local ____params_caseSensitive_116 = params.caseSensitive -- 3564
			local ____math_max_107 = math.max -- 3567
			local ____math_floor_106 = math.floor -- 3567
			local ____params_limit_105 = params.limit -- 3567
			if ____params_limit_105 == nil then -- 3567
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3567
			end -- 3567
			local ____math_max_107_result_117 = ____math_max_107( -- 3567
				1, -- 3567
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3567
			) -- 3567
			local ____math_max_110 = math.max -- 3568
			local ____math_floor_109 = math.floor -- 3568
			local ____params_offset_108 = params.offset -- 3568
			if ____params_offset_108 == nil then -- 3568
				____params_offset_108 = 0 -- 3568
			end -- 3568
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3558
				workDir = ____shared_workingDir_111, -- 3559
				path = ____temp_112, -- 3560
				pattern = ____temp_113, -- 3561
				globs = ____params_globs_114, -- 3562
				useRegex = ____params_useRegex_115, -- 3563
				caseSensitive = ____params_caseSensitive_116, -- 3564
				includeContent = true, -- 3565
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3566
				limit = ____math_max_107_result_117, -- 3567
				offset = ____math_max_110( -- 3568
					0, -- 3568
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3568
				), -- 3568
				groupByFile = params.groupByFile == true -- 3569
			})) -- 3569
			return ____awaiter_resolve(nil, result) -- 3569
		end -- 3569
		if action.tool == "search_dora_api" then -- 3569
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3574
			local ____temp_122 = params.pattern or "" -- 3575
			local ____temp_123 = params.docSource or "api" -- 3576
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3577
			local ____temp_125 = params.programmingLanguage or "ts" -- 3578
			local ____math_min_121 = math.min -- 3579
			local ____math_max_120 = math.max -- 3579
			local ____params_limit_119 = params.limit -- 3579
			if ____params_limit_119 == nil then -- 3579
				____params_limit_119 = 8 -- 3579
			end -- 3579
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3574
				pattern = ____temp_122, -- 3575
				docSource = ____temp_123, -- 3576
				docLanguage = ____temp_124, -- 3577
				programmingLanguage = ____temp_125, -- 3578
				limit = ____math_min_121( -- 3579
					SEARCH_DORA_API_LIMIT_MAX, -- 3579
					____math_max_120( -- 3579
						1, -- 3579
						__TS__Number(____params_limit_119) -- 3579
					) -- 3579
				), -- 3579
				useRegex = params.useRegex, -- 3580
				caseSensitive = false, -- 3581
				includeContent = true, -- 3582
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3583
			})) -- 3583
			return ____awaiter_resolve(nil, result) -- 3583
		end -- 3583
		if action.tool == "glob_files" then -- 3583
			local ____Tools_listFiles_133 = Tools.listFiles -- 3588
			local ____shared_workingDir_130 = shared.workingDir -- 3589
			local ____temp_131 = params.path or "" -- 3590
			local ____params_globs_132 = params.globs -- 3591
			local ____math_max_129 = math.max -- 3592
			local ____math_floor_128 = math.floor -- 3592
			local ____params_maxEntries_127 = params.maxEntries -- 3592
			if ____params_maxEntries_127 == nil then -- 3592
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3592
			end -- 3592
			local result = ____Tools_listFiles_133({ -- 3588
				workDir = ____shared_workingDir_130, -- 3589
				path = ____temp_131, -- 3590
				globs = ____params_globs_132, -- 3591
				maxEntries = ____math_max_129( -- 3592
					1, -- 3592
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3592
				) -- 3592
			}) -- 3592
			return ____awaiter_resolve(nil, result) -- 3592
		end -- 3592
		if action.tool == "delete_file" then -- 3592
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3597
			if __TS__StringTrim(targetFile) == "" then -- 3597
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3597
			end -- 3597
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3601
			if not result.success then -- 3601
				return ____awaiter_resolve(nil, result) -- 3601
			end -- 3601
			return ____awaiter_resolve(nil, { -- 3601
				success = true, -- 3609
				changed = true, -- 3610
				mode = "delete", -- 3611
				checkpointId = result.checkpointId, -- 3612
				checkpointSeq = result.checkpointSeq, -- 3613
				files = {{path = targetFile, op = "delete"}} -- 3614
			}) -- 3614
		end -- 3614
		if action.tool == "build" then -- 3614
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3618
			return ____awaiter_resolve(nil, result) -- 3618
		end -- 3618
		if action.tool == "spawn_sub_agent" then -- 3618
			if not shared.spawnSubAgent then -- 3618
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3618
			end -- 3618
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3618
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3618
			end -- 3618
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3631
				params.filesHint, -- 3632
				function(____, item) return type(item) == "string" end -- 3632
			) or nil -- 3632
			local result = __TS__Await(shared.spawnSubAgent({ -- 3634
				parentSessionId = shared.sessionId, -- 3635
				projectRoot = shared.workingDir, -- 3636
				title = type(params.title) == "string" and params.title or "Sub", -- 3637
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3638
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3639
				filesHint = filesHint -- 3640
			})) -- 3640
			if not result.success then -- 3640
				return ____awaiter_resolve(nil, result) -- 3640
			end -- 3640
			return ____awaiter_resolve(nil, { -- 3640
				success = true, -- 3646
				sessionId = result.sessionId, -- 3647
				taskId = result.taskId, -- 3648
				title = result.title, -- 3649
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3650
			}) -- 3650
		end -- 3650
		if action.tool == "list_sub_agents" then -- 3650
			if not shared.listSubAgents then -- 3650
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3650
			end -- 3650
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3650
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3650
			end -- 3650
			local result = __TS__Await(shared.listSubAgents({ -- 3660
				sessionId = shared.sessionId, -- 3661
				projectRoot = shared.workingDir, -- 3662
				status = type(params.status) == "string" and params.status or nil, -- 3663
				limit = type(params.limit) == "number" and params.limit or nil, -- 3664
				offset = type(params.offset) == "number" and params.offset or nil, -- 3665
				query = type(params.query) == "string" and params.query or nil -- 3666
			})) -- 3666
			return ____awaiter_resolve(nil, result) -- 3666
		end -- 3666
		if action.tool == "edit_file" then -- 3666
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3671
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3674
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3675
			if __TS__StringTrim(path) == "" then -- 3675
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3675
			end -- 3675
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3677
			return ____awaiter_resolve( -- 3677
				nil, -- 3677
				actionNode:exec({ -- 3678
					path = path, -- 3679
					oldStr = oldStr, -- 3680
					newStr = newStr, -- 3681
					taskId = shared.taskId, -- 3682
					workDir = shared.workingDir -- 3683
				}) -- 3683
			) -- 3683
		end -- 3683
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3683
	end) -- 3683
end -- 3683
function sanitizeToolActionResultForHistory(action, result) -- 3689
	if action.tool == "read_file" then -- 3689
		return sanitizeReadResultForHistory(action.tool, result) -- 3691
	end -- 3691
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3691
		return sanitizeSearchResultForHistory(action.tool, result) -- 3694
	end -- 3694
	if action.tool == "glob_files" then -- 3694
		return sanitizeListFilesResultForHistory(result) -- 3697
	end -- 3697
	if action.tool == "build" then -- 3697
		return sanitizeBuildResultForHistory(result) -- 3700
	end -- 3700
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3700
		if result.success ~= true then -- 3700
			return result -- 3703
		end -- 3703
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3703
			return result -- 3704
		end -- 3704
		if isArray(result.fileContext) then -- 3704
			return result -- 3705
		end -- 3705
		local contextLimits = { -- 3707
			fullContentChars = 12000, -- 3708
			previewChars = 4000, -- 3709
			diffChars = 8000, -- 3710
			totalChars = 24000, -- 3711
			maxFiles = 8 -- 3712
		} -- 3712
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3714
			if maxChars <= 0 then -- 3714
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3715
			end -- 3715
			if #sourceText <= maxChars then -- 3715
				return sourceText -- 3716
			end -- 3716
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3717
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3718
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3719
		end -- 3714
		local function countLines(sourceText) -- 3721
			if sourceText == "" then -- 3721
				return 0 -- 3722
			end -- 3722
			return #__TS__StringSplit(sourceText, "\n") -- 3723
		end -- 3721
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3725
			if beforeContent == afterContent then -- 3725
				return "" -- 3726
			end -- 3726
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3727
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3728
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3730
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3730
				firstChangedLine = firstChangedLine + 1 -- 3736
			end -- 3736
			local lastChangedBeforeLine = #beforeLines - 1 -- 3738
			local lastChangedAfterLine = #afterLines - 1 -- 3739
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3739
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3745
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3746
			end -- 3746
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3748
			local previewEndLine = math.max( -- 3749
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3750
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3751
			) -- 3751
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3753
			do -- 3753
				local lineIndex = previewStartLine -- 3754
				while lineIndex <= previewEndLine do -- 3754
					do -- 3754
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3755
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3756
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3757
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3758
						if not beforeChanged and not afterChanged then -- 3758
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3760
							if contextLine ~= nil then -- 3760
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3761
							end -- 3761
							goto __continue575 -- 3762
						end -- 3762
						if beforeChanged and beforeLine ~= nil then -- 3762
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3764
						end -- 3764
						if afterChanged and afterLine ~= nil then -- 3764
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3765
						end -- 3765
					end -- 3765
					::__continue575:: -- 3765
					lineIndex = lineIndex + 1 -- 3754
				end -- 3754
			end -- 3754
			return truncateContextSnippet( -- 3767
				table.concat(unifiedDiffLines, "\n"), -- 3767
				maxChars, -- 3767
				"diff" -- 3767
			) -- 3767
		end -- 3725
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3770
		if not checkpointDiff.success then -- 3770
			return result -- 3771
		end -- 3771
		local remainingContextBudget = contextLimits.totalChars -- 3772
		local fileContextItems = {} -- 3773
		local changedFiles = checkpointDiff.files -- 3774
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3775
		do -- 3775
			local fileIndex = 0 -- 3776
			while fileIndex < maxContextFiles do -- 3776
				if remainingContextBudget <= 0 then -- 3776
					break -- 3777
				end -- 3777
				local changedFile = changedFiles[fileIndex + 1] -- 3778
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3779
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3780
				local contextItem = { -- 3781
					path = changedFile.path, -- 3782
					op = changedFile.op, -- 3783
					checkpointId = result.checkpointId, -- 3784
					checkpointSeq = result.checkpointSeq, -- 3785
					beforeExists = changedFile.beforeExists, -- 3786
					afterExists = changedFile.afterExists, -- 3787
					beforeBytes = #beforeContent, -- 3788
					afterBytes = #afterContent, -- 3789
					diffPreview = "", -- 3790
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3791
					contentTruncated = false, -- 3792
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3793
				} -- 3793
				if changedFile.afterExists then -- 3793
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3793
						contextItem.afterContent = afterContent -- 3797
						remainingContextBudget = remainingContextBudget - #afterContent -- 3798
					else -- 3798
						contextItem.afterContentPreview = truncateContextSnippet( -- 3800
							afterContent, -- 3801
							math.min( -- 3802
								contextLimits.previewChars, -- 3802
								math.max(400, remainingContextBudget) -- 3802
							), -- 3802
							"afterContent" -- 3803
						) -- 3803
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3805
						contextItem.contentTruncated = true -- 3806
					end -- 3806
				end -- 3806
				local diffPreview = buildUnifiedDiffPreview( -- 3809
					changedFile.path, -- 3810
					beforeContent, -- 3811
					afterContent, -- 3812
					math.min( -- 3813
						contextLimits.diffChars, -- 3813
						math.max(400, remainingContextBudget) -- 3813
					) -- 3813
				) -- 3813
				contextItem.diffPreview = diffPreview -- 3815
				remainingContextBudget = remainingContextBudget - #diffPreview -- 3816
				if not changedFile.afterExists and beforeContent ~= "" then -- 3816
					contextItem.beforeContentPreview = truncateContextSnippet( -- 3818
						beforeContent, -- 3819
						math.min( -- 3820
							contextLimits.previewChars, -- 3820
							math.max(400, remainingContextBudget) -- 3820
						), -- 3820
						"beforeContent" -- 3821
					) -- 3821
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 3823
					if #beforeContent > contextLimits.previewChars then -- 3823
						contextItem.contentTruncated = true -- 3824
					end -- 3824
				end -- 3824
				fileContextItems[#fileContextItems + 1] = contextItem -- 3826
				fileIndex = fileIndex + 1 -- 3776
			end -- 3776
		end -- 3776
		if #fileContextItems == 0 then -- 3776
			return result -- 3828
		end -- 3828
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 3829
	end -- 3829
	return result -- 3836
end -- 3836
function emitAgentTaskFinishEvent(shared, success, message) -- 4003
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 4004
	emitAgentEvent(shared, { -- 4010
		type = "task_finished", -- 4011
		sessionId = shared.sessionId, -- 4012
		taskId = shared.taskId, -- 4013
		success = result.success, -- 4014
		message = result.message, -- 4015
		steps = result.steps -- 4016
	}) -- 4016
	return result -- 4018
end -- 4018
local function isRecord(value) -- 10
	return type(value) == "table" -- 11
end -- 10
local SkillPriority = SkillPriority or ({}) -- 33
SkillPriority.BuiltIn = 0 -- 34
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 34
SkillPriority.User = 1 -- 35
SkillPriority[SkillPriority.User] = "User" -- 35
SkillPriority.Project = 2 -- 36
SkillPriority[SkillPriority.Project] = "Project" -- 36
local function escapeXMLText(text) -- 50
	local result = string.gsub(text, "&", "&amp;") -- 51
	result = string.gsub(result, "<", "&lt;") -- 52
	result = string.gsub(result, ">", "&gt;") -- 53
	result = string.gsub(result, "\"", "&quot;") -- 54
	result = string.gsub(result, "'", "&apos;") -- 55
	return result -- 56
end -- 50
local function parseYAMLFrontmatter(content) -- 59
	if not content or __TS__StringTrim(content) == "" then -- 59
		return {metadata = nil, body = "", error = "empty content"} -- 65
	end -- 65
	local trimmed = __TS__StringTrim(content) -- 68
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 70
	end -- 70
	local lines = __TS__StringSplit(trimmed, "\n") -- 73
	local endLine = -1 -- 74
	do -- 74
		local i = 1 -- 75
		while i < #lines do -- 75
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 77
				break -- 78
			end -- 78
			i = i + 1 -- 75
		end -- 75
	end -- 75
	if endLine < 0 then -- 75
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 83
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 86
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 87
	local metadata = parseSimpleYAML(frontmatterText) -- 89
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 91
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 92
	return {metadata = metadata, body = body} -- 94
end -- 59
local function validateSkillMetadata(metadata) -- 183
	if not metadata then -- 183
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 187
	end -- 187
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 196
	if name == "" then -- 196
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 198
	end -- 198
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 207
	local always = metadata.always == true -- 211
	return {metadata = {name = name, description = description, always = always}} -- 213
end -- 183
local SkillsLoader = __TS__Class() -- 222
SkillsLoader.name = "SkillsLoader" -- 222
function SkillsLoader.prototype.____constructor(self, config) -- 227
	self.skills = __TS__New(Map) -- 224
	self.loaded = false -- 225
	self.config = config -- 228
end -- 227
function SkillsLoader.prototype.load(self) -- 231
	self.skills:clear() -- 232
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 234
	local builtInParent = Content.assetPath -- 235
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 236
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 238
	local userParent = Content.writablePath -- 239
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 240
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 242
	local projectParent = self.config.projectDir -- 243
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 244
	self.loaded = true -- 246
	Log( -- 247
		"Info", -- 247
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 247
	) -- 247
end -- 231
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 250
	if not Content:exist(dir) or not Content:isdir(dir) then -- 250
		return -- 252
	end -- 252
	local subdirs = Content:getDirs(dir) -- 255
	if not subdirs or #subdirs == 0 then -- 255
		return -- 257
	end -- 257
	for ____, subdir in ipairs(subdirs) do -- 260
		do -- 260
			local skillPath = Path(dir, subdir, "SKILL.md") -- 261
			if not Content:exist(skillPath) then -- 261
				goto __continue39 -- 263
			end -- 263
			local skill = self:loadSkillFile(skillPath) -- 266
			if not skill then -- 266
				goto __continue39 -- 268
			end -- 268
			skill.location = Path:getRelative(skillPath, parent) -- 271
			local existing = self.skills:get(skill.name) -- 273
			if existing and existing.priority >= priority then -- 273
				goto __continue39 -- 275
			end -- 275
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 278
		end -- 278
		::__continue39:: -- 278
	end -- 278
end -- 250
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 282
	local content = Content:load(skillPath) -- 283
	if not content then -- 283
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 285
		return nil -- 286
	end -- 286
	local parsed = parseYAMLFrontmatter(content) -- 289
	local validated = validateSkillMetadata(parsed.metadata) -- 290
	if validated.error then -- 290
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 293
		return nil -- 294
	end -- 294
	local displayLocation = skillPath -- 297
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 297
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 299
	end -- 299
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 302
	return skill -- 308
end -- 282
function SkillsLoader.prototype.getAllSkills(self) -- 311
	if not self.loaded then -- 311
		self:load() -- 313
	end -- 313
	local result = {} -- 316
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 317
		result[#result + 1] = entry.skill -- 318
	end -- 318
	__TS__ArraySort( -- 321
		result, -- 321
		function(____, a, b) -- 321
			if a.name < b.name then -- 321
				return -1 -- 323
			end -- 323
			if a.name > b.name then -- 323
				return 1 -- 326
			end -- 326
			if a.location < b.location then -- 326
				return -1 -- 329
			end -- 329
			if a.location > b.location then -- 329
				return 1 -- 332
			end -- 332
			return 0 -- 334
		end -- 321
	) -- 321
	return result -- 337
end -- 311
function SkillsLoader.prototype.getSkill(self, name) -- 340
	if not self.loaded then -- 340
		self:load() -- 342
	end -- 342
	local ____opt_0 = self.skills:get(name) -- 342
	return ____opt_0 and ____opt_0.skill -- 345
end -- 340
function SkillsLoader.prototype.getAlwaysSkills(self) -- 348
	local all = self:getAllSkills() -- 349
	return __TS__ArrayFilter( -- 350
		all, -- 350
		function(____, skill) return skill.always == true end -- 350
	) -- 350
end -- 348
function SkillsLoader.prototype.getSummarySkills(self) -- 353
	local all = self:getAllSkills() -- 354
	return __TS__ArrayFilter( -- 355
		all, -- 355
		function(____, skill) return skill.always ~= true end -- 355
	) -- 355
end -- 353
function SkillsLoader.prototype.buildLevel1Summary(self) -- 358
	local skills = self:getSummarySkills() -- 359
	if #skills == 0 then -- 359
		return "" -- 362
	end -- 362
	local parts = {} -- 365
	for ____, skill in ipairs(skills) do -- 367
		local skillXML = "<skill>\n" -- 368
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 369
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 370
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 371
		skillXML = skillXML .. "</skill>" -- 372
		parts[#parts + 1] = skillXML -- 373
	end -- 373
	return table.concat(parts, "\n\n") -- 376
end -- 358
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 379
	local skills = self:getAlwaysSkills() -- 380
	if #skills == 0 then -- 380
		return "" -- 383
	end -- 383
	local parts = {} -- 386
	for ____, skill in ipairs(skills) do -- 388
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 389
		if skill.description ~= nil then -- 389
			parts[#parts + 1] = skill.description .. "\n" -- 391
		end -- 391
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 391
			parts[#parts + 1] = "\n" .. skill.body -- 394
		end -- 394
		parts[#parts + 1] = "" -- 396
	end -- 396
	return table.concat(parts, "\n") -- 399
end -- 379
function SkillsLoader.prototype.loadSkillContent(self, name) -- 402
	local skill = self:getSkill(name) -- 403
	if not skill then -- 403
		return nil -- 405
	end -- 405
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 405
		return skill.body -- 409
	end -- 409
	local content = Content:load(skill.location) -- 412
	if not content then -- 412
		return nil -- 414
	end -- 414
	local parsed = parseYAMLFrontmatter(content) -- 417
	return parsed.body or nil -- 418
end -- 402
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 421
	if not self.loaded then -- 421
		self:load() -- 423
	end -- 423
	local sections = {} -- 426
	local activeContent = self:buildActiveSkillsContent() -- 428
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 429
	local summary = self:buildLevel1Summary() -- 431
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 432
	return table.concat(sections, "\n\n---\n\n")
end -- 421
function SkillsLoader.prototype.escapeXML(self, text) -- 437
	return escapeXMLText(text) -- 438
end -- 437
function SkillsLoader.prototype.reload(self) -- 441
	self.loaded = false -- 442
	self:load() -- 443
end -- 441
function SkillsLoader.prototype.getSkillCount(self) -- 446
	if not self.loaded then -- 446
		self:load() -- 448
	end -- 448
	return self.skills.size -- 450
end -- 446
local function createSkillsLoader(config) -- 454
	return __TS__New(SkillsLoader, config) -- 455
end -- 454
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 539
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 669
HISTORY_READ_FILE_MAX_LINES = 300 -- 670
READ_FILE_DEFAULT_LIMIT = 300 -- 671
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 672
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 673
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 674
HISTORY_BUILD_MAX_MESSAGES = 50 -- 675
HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 676
SEARCH_DORA_API_LIMIT_MAX = 20 -- 677
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 678
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 679
SEARCH_PREVIEW_CONTEXT = 80 -- 680
local AGENT_DEFAULT_MAX_STEPS = 100 -- 681
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 682
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 683
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 684
local function buildLLMOptions(llmConfig, overrides) -- 686
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 687
	if llmConfig.reasoningEffort then -- 687
		options.reasoning_effort = llmConfig.reasoningEffort -- 692
	end -- 692
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 694
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 694
		__TS__Delete(merged, "reasoning_effort") -- 699
	else -- 699
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 701
	end -- 701
	return merged -- 703
end -- 686
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 784
	local messagesTokens = 0 -- 791
	do -- 791
		local i = 0 -- 792
		while i < #messages do -- 792
			local message = messages[i + 1] -- 793
			messagesTokens = messagesTokens + 8 -- 794
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 795
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 796
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 797
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 798
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 799
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 800
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 801
			i = i + 1 -- 792
		end -- 792
	end -- 792
	local toolDefinitionsTokens = 0 -- 804
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 804
		local toolsText = safeJsonEncode(options.tools) -- 806
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 807
	end -- 807
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 810
	__TS__Delete(optionsWithoutTools, "tools") -- 811
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 812
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 813
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 814
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 815
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 820
		1024, -- 822
		math.floor(contextWindow * 0.2) -- 822
	) -- 822
	local structuralOverhead = math.max(256, #messages * 16) -- 823
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 825
	local maxTokens = contextWindow -- 826
	emitAgentEvent( -- 827
		shared, -- 827
		{ -- 827
			type = "metrics_updated", -- 828
			sessionId = shared.sessionId, -- 829
			taskId = shared.taskId, -- 830
			step = step, -- 831
			metrics = {context = { -- 832
				usedTokens = usedTokens, -- 834
				maxTokens = maxTokens, -- 835
				ratio = math.max( -- 836
					0, -- 836
					math.min(1, usedTokens / maxTokens) -- 836
				), -- 836
				messagesTokens = messagesTokens, -- 837
				optionsTokens = optionsTokens, -- 838
				toolDefinitionsTokens = toolDefinitionsTokens, -- 839
				reservedOutputTokens = reservedOutputTokens, -- 840
				structuralOverhead = structuralOverhead, -- 841
				contextWindow = contextWindow, -- 842
				source = "llm_input_estimate", -- 843
				updatedAt = os.time(), -- 844
				phase = phase, -- 845
				step = step -- 846
			}} -- 846
		} -- 846
	) -- 846
end -- 784
local function emitAgentStartEvent(shared, action) -- 852
	emitAgentEvent(shared, { -- 853
		type = "tool_started", -- 854
		sessionId = shared.sessionId, -- 855
		taskId = shared.taskId, -- 856
		step = action.step, -- 857
		tool = action.tool -- 858
	}) -- 858
end -- 852
local function emitAgentFinishEvent(shared, action) -- 862
	emitAgentEvent(shared, { -- 863
		type = "tool_finished", -- 864
		sessionId = shared.sessionId, -- 865
		taskId = shared.taskId, -- 866
		step = action.step, -- 867
		tool = action.tool, -- 868
		result = action.result or ({}) -- 869
	}) -- 869
end -- 862
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 873
	emitAgentEvent(shared, { -- 874
		type = "assistant_message_updated", -- 875
		sessionId = shared.sessionId, -- 876
		taskId = shared.taskId, -- 877
		step = shared.step + 1, -- 878
		content = content, -- 879
		reasoningContent = reasoningContent -- 880
	}) -- 880
end -- 873
local function getMemoryCompressionStartReason(shared) -- 884
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 885
end -- 884
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 890
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 891
end -- 890
local function getMemoryCompressionFailureReason(shared, ____error) -- 896
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 897
end -- 896
local function summarizeHistoryEntryPreview(text, maxChars) -- 902
	if maxChars == nil then -- 902
		maxChars = 180 -- 902
	end -- 902
	local trimmed = __TS__StringTrim(text) -- 903
	if trimmed == "" then -- 903
		return "" -- 904
	end -- 904
	return truncateText(trimmed, maxChars) -- 905
end -- 902
local function getMaxStepsReachedReason(shared) -- 913
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 914
end -- 913
local function getFailureSummaryFallback(shared, ____error) -- 919
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 920
end -- 919
local function finalizeAgentFailure(shared, ____error) -- 925
	if shared.stopToken.stopped then -- 925
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 927
		return emitAgentTaskFinishEvent( -- 928
			shared, -- 928
			false, -- 928
			getCancelledReason(shared) -- 928
		) -- 928
	end -- 928
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 930
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 931
end -- 925
local function getPromptCommand(prompt) -- 934
	local trimmed = __TS__StringTrim(prompt) -- 935
	if trimmed == "/compact" then -- 935
		return "compact" -- 936
	end -- 936
	if trimmed == "/clear" then -- 936
		return "clear" -- 937
	end -- 937
	return nil -- 938
end -- 934
function ____exports.truncateAgentUserPrompt(prompt) -- 941
	if not prompt then -- 941
		return "" -- 942
	end -- 942
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 942
		return prompt -- 943
	end -- 943
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 944
	if offset == nil then -- 944
		return prompt -- 945
	end -- 945
	return string.sub(prompt, 1, offset - 1) -- 946
end -- 941
local function canWriteStepLLMDebug(shared, stepId) -- 949
	if stepId == nil then -- 949
		stepId = shared.step + 1 -- 949
	end -- 949
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 950
end -- 949
local function ensureDirRecursive(dir) -- 957
	if not dir then -- 957
		return false -- 958
	end -- 958
	if Content:exist(dir) then -- 958
		return Content:isdir(dir) -- 959
	end -- 959
	local parent = Path:getPath(dir) -- 960
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 960
		return false -- 962
	end -- 962
	return Content:mkdir(dir) -- 964
end -- 957
local function encodeDebugJSON(value) -- 967
	local text, err = safeJsonEncode(value) -- 968
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 969
end -- 967
local function getStepLLMDebugDir(shared) -- 972
	return Path( -- 973
		shared.workingDir, -- 974
		".agent", -- 975
		tostring(shared.sessionId), -- 976
		tostring(shared.taskId) -- 977
	) -- 977
end -- 972
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 981
	return Path( -- 982
		getStepLLMDebugDir(shared), -- 982
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 982
	) -- 982
end -- 981
local function getLatestStepLLMDebugSeq(shared, stepId) -- 985
	if not canWriteStepLLMDebug(shared, stepId) then -- 985
		return 0 -- 986
	end -- 986
	local dir = getStepLLMDebugDir(shared) -- 987
	if not Content:exist(dir) or not Content:isdir(dir) then -- 987
		return 0 -- 988
	end -- 988
	local latest = 0 -- 989
	for ____, file in ipairs(Content:getFiles(dir)) do -- 990
		do -- 990
			local name = Path:getFilename(file) -- 991
			local seqText = string.match( -- 992
				name, -- 992
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 992
			) -- 992
			if seqText ~= nil then -- 992
				latest = math.max( -- 994
					latest, -- 994
					tonumber(seqText) -- 994
				) -- 994
				goto __continue128 -- 995
			end -- 995
			local legacyMatch = string.match( -- 997
				name, -- 997
				("^" .. tostring(stepId)) .. "_in%.md$" -- 997
			) -- 997
			if legacyMatch ~= nil then -- 997
				latest = math.max(latest, 1) -- 999
			end -- 999
		end -- 999
		::__continue128:: -- 999
	end -- 999
	return latest -- 1002
end -- 985
local function writeStepLLMDebugFile(path, content) -- 1005
	if not Content:save(path, content) then -- 1005
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 1007
		return false -- 1008
	end -- 1008
	return true -- 1010
end -- 1005
local function createStepLLMDebugPair(shared, stepId, inContent) -- 1013
	if not canWriteStepLLMDebug(shared, stepId) then -- 1013
		return 0 -- 1014
	end -- 1014
	local dir = getStepLLMDebugDir(shared) -- 1015
	if not ensureDirRecursive(dir) then -- 1015
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1017
		return 0 -- 1018
	end -- 1018
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 1020
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 1021
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 1022
	if not writeStepLLMDebugFile(inPath, inContent) then -- 1022
		return 0 -- 1024
	end -- 1024
	writeStepLLMDebugFile(outPath, "") -- 1026
	return seq -- 1027
end -- 1013
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 1030
	if not canWriteStepLLMDebug(shared, stepId) then -- 1030
		return -- 1031
	end -- 1031
	local dir = getStepLLMDebugDir(shared) -- 1032
	if not ensureDirRecursive(dir) then -- 1032
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1034
		return -- 1035
	end -- 1035
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 1037
	if latestSeq <= 0 then -- 1037
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 1039
		writeStepLLMDebugFile(outPath, content) -- 1040
		return -- 1041
	end -- 1041
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 1043
	writeStepLLMDebugFile(outPath, content) -- 1044
end -- 1030
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 1047
	if not canWriteStepLLMDebug(shared, stepId) then -- 1047
		return -- 1048
	end -- 1048
	local sections = { -- 1049
		"# LLM Input", -- 1050
		"session_id: " .. tostring(shared.sessionId), -- 1051
		"task_id: " .. tostring(shared.taskId), -- 1052
		"step_id: " .. tostring(stepId), -- 1053
		"phase: " .. phase, -- 1054
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1055
		"## Options", -- 1056
		"```json", -- 1057
		encodeDebugJSON(options), -- 1058
		"```" -- 1059
	} -- 1059
	do -- 1059
		local i = 0 -- 1061
		while i < #messages do -- 1061
			local message = messages[i + 1] -- 1062
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 1063
			sections[#sections + 1] = encodeDebugJSON(message) -- 1064
			i = i + 1 -- 1061
		end -- 1061
	end -- 1061
	createStepLLMDebugPair( -- 1066
		shared, -- 1066
		stepId, -- 1066
		table.concat(sections, "\n") -- 1066
	) -- 1066
end -- 1047
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 1069
	if not canWriteStepLLMDebug(shared, stepId) then -- 1069
		return -- 1070
	end -- 1070
	local ____array_2 = __TS__SparseArrayNew( -- 1070
		"# LLM Output", -- 1072
		"session_id: " .. tostring(shared.sessionId), -- 1073
		"task_id: " .. tostring(shared.taskId), -- 1074
		"step_id: " .. tostring(stepId), -- 1075
		"phase: " .. phase, -- 1076
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1077
		table.unpack(meta and ({ -- 1078
			"## Meta", -- 1078
			"```json", -- 1078
			encodeDebugJSON(meta), -- 1078
			"```" -- 1078
		}) or ({})) -- 1078
	) -- 1078
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 1078
	local sections = {__TS__SparseArraySpread(____array_2)} -- 1071
	updateLatestStepLLMDebugOutput( -- 1082
		shared, -- 1082
		stepId, -- 1082
		table.concat(sections, "\n") -- 1082
	) -- 1082
end -- 1069
local function toJson(value) -- 1085
	local text, err = safeJsonEncode(value) -- 1086
	if text ~= nil then -- 1086
		return text -- 1087
	end -- 1087
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 1088
end -- 1085
local function summarizeEditTextParamForHistory(value, key) -- 1138
	if type(value) ~= "string" then -- 1138
		return nil -- 1139
	end -- 1139
	local text = value -- 1140
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1141
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1142
end -- 1138
local function sanitizeActionParamsForHistory(tool, params) -- 1252
	if tool ~= "edit_file" then -- 1252
		return params -- 1253
	end -- 1253
	local clone = {} -- 1254
	for key in pairs(params) do -- 1255
		if key == "old_str" then -- 1255
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1257
		elseif key == "new_str" then -- 1257
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1259
		else -- 1259
			clone[key] = params[key] -- 1261
		end -- 1261
	end -- 1261
	return clone -- 1264
end -- 1252
local function isToolAllowedForRole(role, tool) -- 1309
	return __TS__ArrayIndexOf( -- 1310
		getAllowedToolsForRole(role), -- 1310
		tool -- 1310
	) >= 0 -- 1310
end -- 1309
local PRE_EXEC_SAFE_TOOLS = { -- 1313
	"read_file", -- 1314
	"grep_files", -- 1315
	"search_dora_api", -- 1316
	"glob_files", -- 1317
	"list_sub_agents" -- 1318
} -- 1318
local function canPreExecuteTool(tool) -- 1321
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1322
end -- 1321
local function clearPreExecutedResults(shared) -- 1325
	shared.preExecutedResults = nil -- 1326
end -- 1325
local function startPreExecutedToolAction(shared, action) -- 1329
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1329
		local ____try = __TS__AsyncAwaiter(function() -- 1329
			return ____awaiter_resolve( -- 1329
				nil, -- 1329
				__TS__Await(executeToolAction(shared, action)) -- 1331
			) -- 1331
		end) -- 1331
		__TS__Await(____try.catch( -- 1330
			____try, -- 1330
			function(____, err) -- 1330
				local message = tostring(err) -- 1333
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1334
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1334
			end -- 1334
		)) -- 1334
	end) -- 1334
end -- 1329
local function executeToolActionWithPreExecution(shared, action) -- 1339
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1339
		local ____opt_9 = shared.preExecutedResults -- 1339
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1340
		if preResult then -- 1340
			Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1342
			local ____opt_11 = shared.preExecutedResults -- 1342
			if ____opt_11 ~= nil then -- 1342
				____opt_11:delete(action.toolCallId) -- 1343
			end -- 1343
			return ____awaiter_resolve( -- 1343
				nil, -- 1343
				__TS__Await(preResult) -- 1344
			) -- 1344
		end -- 1344
		return ____awaiter_resolve( -- 1344
			nil, -- 1344
			executeToolAction(shared, action) -- 1346
		) -- 1346
	end) -- 1346
end -- 1339
local function maybeCompressHistory(shared) -- 1349
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1349
		local ____shared_13 = shared -- 1350
		local memory = ____shared_13.memory -- 1350
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1351
		local changed = false -- 1352
		do -- 1352
			local round = 0 -- 1353
			while round < maxRounds do -- 1353
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1354
				local activeMessages = getActiveConversationMessages(shared) -- 1355
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1359
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1359
					if changed then -- 1359
						persistHistoryState(shared) -- 1368
					end -- 1368
					return ____awaiter_resolve(nil) -- 1368
				end -- 1368
				local compressionRound = round + 1 -- 1372
				shared.step = shared.step + 1 -- 1373
				local stepId = shared.step -- 1374
				local pendingMessages = #activeMessages -- 1375
				emitAgentEvent( -- 1376
					shared, -- 1376
					{ -- 1376
						type = "memory_compression_started", -- 1377
						sessionId = shared.sessionId, -- 1378
						taskId = shared.taskId, -- 1379
						step = stepId, -- 1380
						tool = "compress_memory", -- 1381
						reason = getMemoryCompressionStartReason(shared), -- 1382
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1383
					} -- 1383
				) -- 1383
				local result = __TS__Await(memory.compressor:compress( -- 1389
					activeMessages, -- 1390
					shared.llmOptions, -- 1391
					shared.llmMaxTry, -- 1392
					shared.decisionMode, -- 1393
					{ -- 1394
						onInput = function(____, phase, messages, options) -- 1395
							saveStepLLMDebugInput( -- 1396
								shared, -- 1396
								stepId, -- 1396
								phase, -- 1396
								messages, -- 1396
								options -- 1396
							) -- 1396
						end, -- 1395
						onOutput = function(____, phase, text, meta) -- 1398
							saveStepLLMDebugOutput( -- 1399
								shared, -- 1399
								stepId, -- 1399
								phase, -- 1399
								text, -- 1399
								meta -- 1399
							) -- 1399
						end -- 1398
					}, -- 1398
					"default", -- 1402
					systemPrompt, -- 1403
					toolDefinitions -- 1404
				)) -- 1404
				if not (result and result.success and result.compressedCount > 0) then -- 1404
					emitAgentEvent( -- 1407
						shared, -- 1407
						{ -- 1407
							type = "memory_compression_finished", -- 1408
							sessionId = shared.sessionId, -- 1409
							taskId = shared.taskId, -- 1410
							step = stepId, -- 1411
							tool = "compress_memory", -- 1412
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1413
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1417
						} -- 1417
					) -- 1417
					if changed then -- 1417
						persistHistoryState(shared) -- 1425
					end -- 1425
					return ____awaiter_resolve(nil) -- 1425
				end -- 1425
				local effectiveCompressedCount = math.max( -- 1429
					0, -- 1430
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1431
				) -- 1431
				if effectiveCompressedCount <= 0 then -- 1431
					if changed then -- 1431
						persistHistoryState(shared) -- 1435
					end -- 1435
					return ____awaiter_resolve(nil) -- 1435
				end -- 1435
				emitAgentEvent( -- 1439
					shared, -- 1439
					{ -- 1439
						type = "memory_compression_finished", -- 1440
						sessionId = shared.sessionId, -- 1441
						taskId = shared.taskId, -- 1442
						step = stepId, -- 1443
						tool = "compress_memory", -- 1444
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1445
						result = { -- 1446
							success = true, -- 1447
							round = compressionRound, -- 1448
							compressedCount = effectiveCompressedCount, -- 1449
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1450
						} -- 1450
					} -- 1450
				) -- 1450
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1453
				changed = true -- 1454
				Log( -- 1455
					"Info", -- 1455
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1455
				) -- 1455
				round = round + 1 -- 1353
			end -- 1353
		end -- 1353
		if changed then -- 1353
			persistHistoryState(shared) -- 1458
		end -- 1458
	end) -- 1458
end -- 1349
local function compactAllHistory(shared) -- 1462
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1462
		local ____shared_20 = shared -- 1463
		local memory = ____shared_20.memory -- 1463
		local rounds = 0 -- 1464
		local totalCompressed = 0 -- 1465
		while getActiveRealMessageCount(shared) > 0 do -- 1465
			if shared.stopToken.stopped then -- 1465
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1468
				return ____awaiter_resolve( -- 1468
					nil, -- 1468
					emitAgentTaskFinishEvent( -- 1469
						shared, -- 1469
						false, -- 1469
						getCancelledReason(shared) -- 1469
					) -- 1469
				) -- 1469
			end -- 1469
			rounds = rounds + 1 -- 1471
			shared.step = shared.step + 1 -- 1472
			local stepId = shared.step -- 1473
			local activeMessages = getActiveConversationMessages(shared) -- 1474
			local pendingMessages = #activeMessages -- 1475
			emitAgentEvent( -- 1476
				shared, -- 1476
				{ -- 1476
					type = "memory_compression_started", -- 1477
					sessionId = shared.sessionId, -- 1478
					taskId = shared.taskId, -- 1479
					step = stepId, -- 1480
					tool = "compress_memory", -- 1481
					reason = getMemoryCompressionStartReason(shared), -- 1482
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1483
				} -- 1483
			) -- 1483
			local result = __TS__Await(memory.compressor:compress( -- 1490
				activeMessages, -- 1491
				shared.llmOptions, -- 1492
				shared.llmMaxTry, -- 1493
				shared.decisionMode, -- 1494
				{ -- 1495
					onInput = function(____, phase, messages, options) -- 1496
						saveStepLLMDebugInput( -- 1497
							shared, -- 1497
							stepId, -- 1497
							phase, -- 1497
							messages, -- 1497
							options -- 1497
						) -- 1497
					end, -- 1496
					onOutput = function(____, phase, text, meta) -- 1499
						saveStepLLMDebugOutput( -- 1500
							shared, -- 1500
							stepId, -- 1500
							phase, -- 1500
							text, -- 1500
							meta -- 1500
						) -- 1500
					end -- 1499
				}, -- 1499
				"budget_max" -- 1503
			)) -- 1503
			if not (result and result.success and result.compressedCount > 0) then -- 1503
				emitAgentEvent( -- 1506
					shared, -- 1506
					{ -- 1506
						type = "memory_compression_finished", -- 1507
						sessionId = shared.sessionId, -- 1508
						taskId = shared.taskId, -- 1509
						step = stepId, -- 1510
						tool = "compress_memory", -- 1511
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1512
						result = { -- 1516
							success = false, -- 1517
							rounds = rounds, -- 1518
							error = result and result.error or "compression returned no changes", -- 1519
							compressedCount = result and result.compressedCount or 0, -- 1520
							fullCompaction = true -- 1521
						} -- 1521
					} -- 1521
				) -- 1521
				return ____awaiter_resolve( -- 1521
					nil, -- 1521
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1524
				) -- 1524
			end -- 1524
			local effectiveCompressedCount = math.max( -- 1529
				0, -- 1530
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1531
			) -- 1531
			if effectiveCompressedCount <= 0 then -- 1531
				return ____awaiter_resolve( -- 1531
					nil, -- 1531
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1534
				) -- 1534
			end -- 1534
			emitAgentEvent( -- 1541
				shared, -- 1541
				{ -- 1541
					type = "memory_compression_finished", -- 1542
					sessionId = shared.sessionId, -- 1543
					taskId = shared.taskId, -- 1544
					step = stepId, -- 1545
					tool = "compress_memory", -- 1546
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1547
					result = { -- 1548
						success = true, -- 1549
						round = rounds, -- 1550
						compressedCount = effectiveCompressedCount, -- 1551
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1552
						fullCompaction = true -- 1553
					} -- 1553
				} -- 1553
			) -- 1553
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1556
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1557
			persistHistoryState(shared) -- 1558
			Log( -- 1559
				"Info", -- 1559
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1559
			) -- 1559
		end -- 1559
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1561
		return ____awaiter_resolve( -- 1561
			nil, -- 1561
			emitAgentTaskFinishEvent( -- 1562
				shared, -- 1563
				true, -- 1564
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1565
			) -- 1565
		) -- 1565
	end) -- 1565
end -- 1462
local function clearSessionHistory(shared) -- 1571
	shared.messages = {} -- 1572
	shared.lastConsolidatedIndex = 0 -- 1573
	shared.carryMessageIndex = nil -- 1574
	persistHistoryState(shared) -- 1575
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1576
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1577
end -- 1571
local function isKnownToolName(name) -- 1586
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1587
end -- 1586
local function appendConversationMessage(shared, message) -- 1680
	local ____shared_messages_29 = shared.messages -- 1680
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1681
		{}, -- 1681
		message, -- 1682
		{ -- 1681
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1683
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1684
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1685
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1686
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1687
		} -- 1687
	) -- 1687
end -- 1680
local function ensureToolCallId(toolCallId) -- 1691
	if toolCallId and toolCallId ~= "" then -- 1691
		return toolCallId -- 1692
	end -- 1692
	return createLocalToolCallId() -- 1693
end -- 1691
local function appendToolResultMessage(shared, action) -- 1696
	appendConversationMessage( -- 1697
		shared, -- 1697
		{ -- 1697
			role = "tool", -- 1698
			tool_call_id = action.toolCallId, -- 1699
			name = action.tool, -- 1700
			content = action.result and toJson(action.result) or "" -- 1701
		} -- 1701
	) -- 1701
end -- 1696
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1705
	appendConversationMessage( -- 1711
		shared, -- 1711
		{ -- 1711
			role = "assistant", -- 1712
			content = content or "", -- 1713
			reasoning_content = reasoningContent, -- 1714
			tool_calls = __TS__ArrayMap( -- 1715
				actions, -- 1715
				function(____, action) return { -- 1715
					id = action.toolCallId, -- 1716
					type = "function", -- 1717
					["function"] = { -- 1718
						name = action.tool, -- 1719
						arguments = toJson(action.params) -- 1720
					} -- 1720
				} end -- 1720
			) -- 1720
		} -- 1720
	) -- 1720
end -- 1705
local function parseXMLToolCallObjectFromText(text) -- 1726
	local children = parseXMLObjectFromText(text, "tool_call") -- 1727
	if not children.success then -- 1727
		return children -- 1728
	end -- 1728
	local rawObj = children.obj -- 1729
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1730
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1731
	if not params.success then -- 1731
		return {success = false, message = params.message} -- 1735
	end -- 1735
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1737
end -- 1726
local function llm(shared, messages, phase) -- 1757
	if phase == nil then -- 1757
		phase = "decision_xml" -- 1760
	end -- 1760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1760
		local stepId = shared.step + 1 -- 1762
		emitLLMContextMetrics( -- 1763
			shared, -- 1763
			stepId, -- 1763
			phase, -- 1763
			messages, -- 1763
			shared.llmOptions -- 1763
		) -- 1763
		saveStepLLMDebugInput( -- 1764
			shared, -- 1764
			stepId, -- 1764
			phase, -- 1764
			messages, -- 1764
			shared.llmOptions -- 1764
		) -- 1764
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1765
		if res.success then -- 1765
			local ____opt_32 = res.response.choices -- 1765
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1765
			local message = ____opt_30 and ____opt_30.message -- 1767
			local text = message and message.content -- 1768
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1769
			if text then -- 1769
				saveStepLLMDebugOutput( -- 1773
					shared, -- 1773
					stepId, -- 1773
					phase, -- 1773
					text, -- 1773
					{success = true} -- 1773
				) -- 1773
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1773
			else -- 1773
				saveStepLLMDebugOutput( -- 1776
					shared, -- 1776
					stepId, -- 1776
					phase, -- 1776
					"empty LLM response", -- 1776
					{success = false} -- 1776
				) -- 1776
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1776
			end -- 1776
		else -- 1776
			saveStepLLMDebugOutput( -- 1780
				shared, -- 1780
				stepId, -- 1780
				phase, -- 1780
				res.raw or res.message, -- 1780
				{success = false} -- 1780
			) -- 1780
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1780
		end -- 1780
	end) -- 1780
end -- 1757
local function isDecisionBatchSuccess(result) -- 1804
	return result.kind == "batch" -- 1805
end -- 1804
local function parseDecisionObject(rawObj) -- 1808
	if type(rawObj.tool) ~= "string" then -- 1808
		return {success = false, message = "missing tool"} -- 1809
	end -- 1809
	local tool = rawObj.tool -- 1810
	if not isKnownToolName(tool) then -- 1810
		return {success = false, message = "unknown tool: " .. tool} -- 1812
	end -- 1812
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1814
	if tool ~= "finish" and (not reason or reason == "") then -- 1814
		return {success = false, message = tool .. " requires top-level reason"} -- 1818
	end -- 1818
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1820
	return {success = true, tool = tool, params = params, reason = reason} -- 1821
end -- 1808
local function parseDecisionToolCall(functionName, rawObj) -- 1829
	if not isKnownToolName(functionName) then -- 1829
		return {success = false, message = "unknown tool: " .. functionName} -- 1831
	end -- 1831
	if rawObj == nil or rawObj == nil then -- 1831
		return {success = true, tool = functionName, params = {}} -- 1834
	end -- 1834
	if not isRecord(rawObj) then -- 1834
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1837
	end -- 1837
	return {success = true, tool = functionName, params = rawObj} -- 1839
end -- 1829
local function parseToolCallArguments(functionName, argsText) -- 1846
	local trimmedArgs = __TS__StringTrim(argsText) -- 1847
	if trimmedArgs == "" then -- 1847
		return {} -- 1849
	end -- 1849
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1851
	if err ~= nil or rawObj == nil then -- 1851
		return { -- 1853
			success = false, -- 1854
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1855
			raw = argsText -- 1856
		} -- 1856
	end -- 1856
	local encodedRaw = safeJsonEncode(rawObj) -- 1859
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1859
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1861
	end -- 1861
	return rawObj -- 1867
end -- 1846
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1870
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1878
	if isRecord(rawArgs) and rawArgs.success == false then -- 1878
		return rawArgs -- 1880
	end -- 1880
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1882
	if not decision.success then -- 1882
		return {success = false, message = decision.message, raw = argsText} -- 1884
	end -- 1884
	local validation = validateDecision(decision.tool, decision.params) -- 1890
	if not validation.success then -- 1890
		return {success = false, message = validation.message, raw = argsText} -- 1892
	end -- 1892
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1892
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1899
	end -- 1899
	decision.params = validation.params -- 1905
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1906
	decision.reason = reason -- 1907
	decision.reasoningContent = reasoningContent -- 1908
	return decision -- 1909
end -- 1870
local function createPreExecutableActionFromStream(shared, toolCall) -- 1912
	local ____opt_38 = toolCall["function"] -- 1912
	local functionName = ____opt_38 and ____opt_38.name -- 1913
	local ____opt_40 = toolCall["function"] -- 1913
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1914
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1915
	if not functionName or not toolCallId then -- 1915
		return nil -- 1916
	end -- 1916
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1917
	if isRecord(rawArgs) and rawArgs.success == false then -- 1917
		return nil -- 1918
	end -- 1918
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1919
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1919
		return nil -- 1920
	end -- 1920
	local validation = validateDecision(decision.tool, decision.params) -- 1921
	if not validation.success then -- 1921
		return nil -- 1922
	end -- 1922
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1922
		return nil -- 1923
	end -- 1923
	return { -- 1924
		step = shared.step + 1, -- 1925
		toolCallId = toolCallId, -- 1926
		tool = decision.tool, -- 1927
		reason = "", -- 1928
		params = validation.params, -- 1929
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1930
	} -- 1930
end -- 1912
local function createFunctionToolSchema(name, description, properties, required) -- 2070
	if required == nil then -- 2070
		required = {} -- 2074
	end -- 2074
	local parameters = {type = "object", properties = properties} -- 2076
	if #required > 0 then -- 2076
		parameters.required = required -- 2081
	end -- 2081
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2083
end -- 2070
local function buildDecisionToolSchema(shared) -- 2099
	local allowed = getAllowedToolsForRole(shared.role) -- 2100
	local tools = { -- 2101
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2102
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2112
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2122
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2130
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2134
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2135
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2136
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2137
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2138
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2139
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2140
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2141
		}, {"pattern"}), -- 2141
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2145
		createFunctionToolSchema( -- 2154
			"search_dora_api", -- 2155
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2155
			{ -- 2157
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2158
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2159
				programmingLanguage = {type = "string", enum = { -- 2160
					"ts", -- 2162
					"tsx", -- 2162
					"lua", -- 2162
					"yue", -- 2162
					"teal", -- 2162
					"tl", -- 2162
					"wa" -- 2162
				}, description = "Preferred language variant to search."}, -- 2162
				limit = { -- 2165
					type = "number", -- 2165
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2165
				}, -- 2165
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2166
			}, -- 2166
			{"pattern"} -- 2168
		), -- 2168
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2170
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2177
			"active_or_recent", -- 2181
			"running", -- 2181
			"done", -- 2181
			"failed", -- 2181
			"all" -- 2181
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2181
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2187
	} -- 2187
	return __TS__ArrayFilter( -- 2199
		tools, -- 2199
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2199
	) -- 2199
end -- 2099
local function sanitizeMessagesForLLMInput(messages) -- 2240
	local sanitized = {} -- 2241
	local droppedAssistantToolCalls = 0 -- 2242
	local droppedToolResults = 0 -- 2243
	do -- 2243
		local i = 0 -- 2244
		while i < #messages do -- 2244
			do -- 2244
				local message = messages[i + 1] -- 2245
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2245
					local requiredIds = {} -- 2247
					do -- 2247
						local j = 0 -- 2248
						while j < #message.tool_calls do -- 2248
							local toolCall = message.tool_calls[j + 1] -- 2249
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2250
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2250
								requiredIds[#requiredIds + 1] = id -- 2252
							end -- 2252
							j = j + 1 -- 2248
						end -- 2248
					end -- 2248
					if #requiredIds == 0 then -- 2248
						sanitized[#sanitized + 1] = message -- 2256
						goto __continue339 -- 2257
					end -- 2257
					local matchedIds = {} -- 2259
					local matchedTools = {} -- 2260
					local j = i + 1 -- 2261
					while j < #messages do -- 2261
						local toolMessage = messages[j + 1] -- 2263
						if toolMessage.role ~= "tool" then -- 2263
							break -- 2264
						end -- 2264
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2265
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2265
							matchedIds[toolCallId] = true -- 2267
							matchedTools[#matchedTools + 1] = toolMessage -- 2268
						else -- 2268
							droppedToolResults = droppedToolResults + 1 -- 2270
						end -- 2270
						j = j + 1 -- 2272
					end -- 2272
					local complete = true -- 2274
					do -- 2274
						local j = 0 -- 2275
						while j < #requiredIds do -- 2275
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2275
								complete = false -- 2277
								break -- 2278
							end -- 2278
							j = j + 1 -- 2275
						end -- 2275
					end -- 2275
					if complete then -- 2275
						__TS__ArrayPush( -- 2282
							sanitized, -- 2282
							message, -- 2282
							table.unpack(matchedTools) -- 2282
						) -- 2282
					else -- 2282
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2284
						droppedToolResults = droppedToolResults + #matchedTools -- 2285
					end -- 2285
					i = j - 1 -- 2287
					goto __continue339 -- 2288
				end -- 2288
				if message.role == "tool" then -- 2288
					droppedToolResults = droppedToolResults + 1 -- 2291
					goto __continue339 -- 2292
				end -- 2292
				sanitized[#sanitized + 1] = message -- 2294
			end -- 2294
			::__continue339:: -- 2294
			i = i + 1 -- 2244
		end -- 2244
	end -- 2244
	return sanitized -- 2296
end -- 2240
local function getUnconsolidatedMessages(shared) -- 2299
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2300
end -- 2299
local function getFinalDecisionTurnPrompt(shared) -- 2303
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2304
end -- 2303
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2309
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2309
		return messages -- 2310
	end -- 2310
	local next = __TS__ArrayMap( -- 2311
		messages, -- 2311
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2311
	) -- 2311
	do -- 2311
		local i = #next - 1 -- 2312
		while i >= 0 do -- 2312
			do -- 2312
				local message = next[i + 1] -- 2313
				if message.role ~= "assistant" and message.role ~= "user" then -- 2313
					goto __continue361 -- 2314
				end -- 2314
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2315
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2316
				return next -- 2319
			end -- 2319
			::__continue361:: -- 2319
			i = i - 1 -- 2312
		end -- 2312
	end -- 2312
	next[#next + 1] = {role = "user", content = prompt} -- 2321
	return next -- 2322
end -- 2309
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2325
	if attempt == nil then -- 2325
		attempt = 1 -- 2328
	end -- 2328
	if decisionMode == nil then -- 2328
		decisionMode = shared.decisionMode -- 2330
	end -- 2330
	local messages = { -- 2332
		{ -- 2333
			role = "system", -- 2333
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2333
		}, -- 2333
		table.unpack(getUnconsolidatedMessages(shared)) -- 2334
	} -- 2334
	if shared.step + 1 >= shared.maxSteps then -- 2334
		messages = appendPromptToLatestDecisionMessage( -- 2337
			messages, -- 2337
			getFinalDecisionTurnPrompt(shared) -- 2337
		) -- 2337
	end -- 2337
	if lastError and lastError ~= "" then -- 2337
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2340
		messages[#messages + 1] = { -- 2343
			role = "user", -- 2344
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2345
		} -- 2345
	end -- 2345
	return messages -- 2352
end -- 2325
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2359
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2366
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2367
	local repairPrompt = replacePromptVars( -- 2375
		shared.promptPack.xmlDecisionRepairPrompt, -- 2375
		{ -- 2375
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2376
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2377
			CANDIDATE_SECTION = candidateSection, -- 2378
			LAST_ERROR = lastError, -- 2379
			ATTEMPT = tostring(attempt) -- 2380
		} -- 2380
	) -- 2380
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2382
end -- 2359
local function tryParseAndValidateDecision(rawText) -- 2394
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2395
	if not parsed.success then -- 2395
		return {success = false, message = parsed.message, raw = rawText} -- 2397
	end -- 2397
	local decision = parseDecisionObject(parsed.obj) -- 2399
	if not decision.success then -- 2399
		return {success = false, message = decision.message, raw = rawText} -- 2401
	end -- 2401
	local validation = validateDecision(decision.tool, decision.params) -- 2403
	if not validation.success then -- 2403
		return {success = false, message = validation.message, raw = rawText} -- 2405
	end -- 2405
	decision.params = validation.params -- 2407
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2408
	return decision -- 2409
end -- 2394
local function normalizeLineEndings(text) -- 2412
	local res = string.gsub(text, "\r\n", "\n") -- 2413
	res = string.gsub(res, "\r", "\n") -- 2414
	return res -- 2415
end -- 2412
local function countOccurrences(text, searchStr) -- 2418
	if searchStr == "" then -- 2418
		return 0 -- 2419
	end -- 2419
	local count = 0 -- 2420
	local pos = 0 -- 2421
	while true do -- 2421
		local idx = (string.find( -- 2423
			text, -- 2423
			searchStr, -- 2423
			math.max(pos + 1, 1), -- 2423
			true -- 2423
		) or 0) - 1 -- 2423
		if idx < 0 then -- 2423
			break -- 2424
		end -- 2424
		count = count + 1 -- 2425
		pos = idx + #searchStr -- 2426
	end -- 2426
	return count -- 2428
end -- 2418
local function replaceFirst(text, oldStr, newStr) -- 2431
	if oldStr == "" then -- 2431
		return text -- 2432
	end -- 2432
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2433
	if idx < 0 then -- 2433
		return text -- 2434
	end -- 2434
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2435
end -- 2431
local function splitLines(text) -- 2438
	return __TS__StringSplit(text, "\n") -- 2439
end -- 2438
local function getLeadingWhitespace(text) -- 2442
	local i = 0 -- 2443
	while i < #text do -- 2443
		local ch = __TS__StringAccess(text, i) -- 2445
		if ch ~= " " and ch ~= "\t" then -- 2445
			break -- 2446
		end -- 2446
		i = i + 1 -- 2447
	end -- 2447
	return __TS__StringSubstring(text, 0, i) -- 2449
end -- 2442
local function getCommonIndentPrefix(lines) -- 2452
	local common -- 2453
	do -- 2453
		local i = 0 -- 2454
		while i < #lines do -- 2454
			do -- 2454
				local line = lines[i + 1] -- 2455
				if __TS__StringTrim(line) == "" then -- 2455
					goto __continue386 -- 2456
				end -- 2456
				local indent = getLeadingWhitespace(line) -- 2457
				if common == nil then -- 2457
					common = indent -- 2459
					goto __continue386 -- 2460
				end -- 2460
				local j = 0 -- 2462
				local maxLen = math.min(#common, #indent) -- 2463
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2463
					j = j + 1 -- 2465
				end -- 2465
				common = __TS__StringSubstring(common, 0, j) -- 2467
				if common == "" then -- 2467
					break -- 2468
				end -- 2468
			end -- 2468
			::__continue386:: -- 2468
			i = i + 1 -- 2454
		end -- 2454
	end -- 2454
	return common or "" -- 2470
end -- 2452
local function removeIndentPrefix(line, indent) -- 2473
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2473
		return __TS__StringSubstring(line, #indent) -- 2475
	end -- 2475
	local lineIndent = getLeadingWhitespace(line) -- 2477
	local j = 0 -- 2478
	local maxLen = math.min(#lineIndent, #indent) -- 2479
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2479
		j = j + 1 -- 2481
	end -- 2481
	return __TS__StringSubstring(line, j) -- 2483
end -- 2473
local function dedentLines(lines) -- 2486
	local indent = getCommonIndentPrefix(lines) -- 2487
	return { -- 2488
		indent = indent, -- 2489
		lines = __TS__ArrayMap( -- 2490
			lines, -- 2490
			function(____, line) return removeIndentPrefix(line, indent) end -- 2490
		) -- 2490
	} -- 2490
end -- 2486
local function joinLines(lines) -- 2494
	return table.concat(lines, "\n") -- 2495
end -- 2494
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2498
	local contentLines = splitLines(content) -- 2503
	local oldLines = splitLines(oldStr) -- 2504
	if #oldLines == 0 then -- 2504
		return {success = false, message = "old_str not found in file"} -- 2506
	end -- 2506
	local dedentedOld = dedentLines(oldLines) -- 2508
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2509
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2510
	local matches = {} -- 2511
	do -- 2511
		local start = 0 -- 2512
		while start <= #contentLines - #oldLines do -- 2512
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2513
			local dedentedCandidate = dedentLines(candidateLines) -- 2514
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2514
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2516
			end -- 2516
			start = start + 1 -- 2512
		end -- 2512
	end -- 2512
	if #matches == 0 then -- 2512
		return {success = false, message = "old_str not found in file"} -- 2524
	end -- 2524
	if #matches > 1 then -- 2524
		return { -- 2527
			success = false, -- 2528
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2529
		} -- 2529
	end -- 2529
	local match = matches[1] -- 2532
	local rebuiltNewLines = __TS__ArrayMap( -- 2533
		dedentedNew.lines, -- 2533
		function(____, line) return line == "" and "" or match.indent .. line end -- 2533
	) -- 2533
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2533
	__TS__SparseArrayPush( -- 2533
		____array_46, -- 2533
		table.unpack(rebuiltNewLines) -- 2536
	) -- 2536
	__TS__SparseArrayPush( -- 2536
		____array_46, -- 2536
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2537
	) -- 2537
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2534
	return { -- 2539
		success = true, -- 2539
		content = joinLines(nextLines) -- 2539
	} -- 2539
end -- 2498
local MainDecisionAgent = __TS__Class() -- 2542
MainDecisionAgent.name = "MainDecisionAgent" -- 2542
__TS__ClassExtends(MainDecisionAgent, Node) -- 2542
function MainDecisionAgent.prototype.prep(self, shared) -- 2543
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2543
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2543
			return ____awaiter_resolve(nil, {shared = shared}) -- 2543
		end -- 2543
		__TS__Await(maybeCompressHistory(shared)) -- 2548
		return ____awaiter_resolve(nil, {shared = shared}) -- 2548
	end) -- 2548
end -- 2543
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2553
	if attempt == nil then -- 2553
		attempt = 1 -- 2556
	end -- 2556
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2556
		if shared.stopToken.stopped then -- 2556
			return ____awaiter_resolve( -- 2556
				nil, -- 2556
				{ -- 2560
					success = false, -- 2560
					message = getCancelledReason(shared) -- 2560
				} -- 2560
			) -- 2560
		end -- 2560
		Log( -- 2562
			"Info", -- 2562
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2562
		) -- 2562
		local tools = buildDecisionToolSchema(shared) -- 2563
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2564
		local stepId = shared.step + 1 -- 2565
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2566
		emitLLMContextMetrics( -- 2570
			shared, -- 2570
			stepId, -- 2570
			"decision_tool_calling", -- 2570
			messages, -- 2570
			llmOptions -- 2570
		) -- 2570
		saveStepLLMDebugInput( -- 2571
			shared, -- 2571
			stepId, -- 2571
			"decision_tool_calling", -- 2571
			messages, -- 2571
			llmOptions -- 2571
		) -- 2571
		local lastStreamContent = "" -- 2572
		local lastStreamReasoning = "" -- 2573
		local preExecutedResults = __TS__New(Map) -- 2574
		shared.preExecutedResults = preExecutedResults -- 2575
		local res = __TS__Await(callLLMStreamAggregated( -- 2576
			messages, -- 2577
			llmOptions, -- 2578
			shared.stopToken, -- 2579
			shared.llmConfig, -- 2580
			function(response) -- 2581
				local ____opt_49 = response.choices -- 2581
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2581
				local streamMessage = ____opt_47 and ____opt_47.message -- 2582
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2583
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2586
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2586
					return -- 2590
				end -- 2590
				lastStreamContent = nextContent -- 2592
				lastStreamReasoning = nextReasoning -- 2593
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2594
			end, -- 2581
			function(tc) -- 2596
				if shared.stopToken.stopped then -- 2596
					return -- 2597
				end -- 2597
				local action = createPreExecutableActionFromStream(shared, tc) -- 2598
				if not action or preExecutedResults:has(action.toolCallId) then -- 2598
					return -- 2599
				end -- 2599
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2600
				preExecutedResults:set( -- 2601
					action.toolCallId, -- 2601
					startPreExecutedToolAction(shared, action) -- 2601
				) -- 2601
			end -- 2596
		)) -- 2596
		if shared.stopToken.stopped then -- 2596
			clearPreExecutedResults(shared) -- 2605
			return ____awaiter_resolve( -- 2605
				nil, -- 2605
				{ -- 2606
					success = false, -- 2606
					message = getCancelledReason(shared) -- 2606
				} -- 2606
			) -- 2606
		end -- 2606
		if not res.success then -- 2606
			saveStepLLMDebugOutput( -- 2609
				shared, -- 2609
				stepId, -- 2609
				"decision_tool_calling", -- 2609
				res.raw or res.message, -- 2609
				{success = false} -- 2609
			) -- 2609
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2610
			clearPreExecutedResults(shared) -- 2611
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2611
		end -- 2611
		saveStepLLMDebugOutput( -- 2614
			shared, -- 2614
			stepId, -- 2614
			"decision_tool_calling", -- 2614
			encodeDebugJSON(res.response), -- 2614
			{success = true} -- 2614
		) -- 2614
		local choice = res.response.choices and res.response.choices[1] -- 2615
		local message = choice and choice.message -- 2616
		local toolCalls = message and message.tool_calls -- 2617
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2618
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2621
		Log( -- 2624
			"Info", -- 2624
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2624
		) -- 2624
		if not toolCalls or #toolCalls == 0 then -- 2624
			if messageContent and messageContent ~= "" then -- 2624
				Log( -- 2627
					"Info", -- 2627
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2627
				) -- 2627
				clearPreExecutedResults(shared) -- 2628
				return ____awaiter_resolve(nil, { -- 2628
					success = true, -- 2630
					tool = "finish", -- 2631
					params = {}, -- 2632
					reason = messageContent, -- 2633
					reasoningContent = reasoningContent, -- 2634
					directSummary = messageContent -- 2635
				}) -- 2635
			end -- 2635
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2638
			clearPreExecutedResults(shared) -- 2639
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2639
		end -- 2639
		local decisions = {} -- 2646
		do -- 2646
			local i = 0 -- 2647
			while i < #toolCalls do -- 2647
				local toolCall = toolCalls[i + 1] -- 2648
				local fn = toolCall and toolCall["function"] -- 2649
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2649
					Log( -- 2651
						"Error", -- 2651
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2651
					) -- 2651
					clearPreExecutedResults(shared) -- 2652
					return ____awaiter_resolve( -- 2652
						nil, -- 2652
						{ -- 2653
							success = false, -- 2654
							message = "missing function name for tool call " .. tostring(i + 1), -- 2655
							raw = messageContent -- 2656
						} -- 2656
					) -- 2656
				end -- 2656
				local functionName = fn.name -- 2659
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2660
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2661
				Log( -- 2664
					"Info", -- 2664
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2664
				) -- 2664
				local decision = parseAndValidateToolCallDecision( -- 2665
					shared, -- 2666
					functionName, -- 2667
					argsText, -- 2668
					toolCallId, -- 2669
					messageContent, -- 2670
					reasoningContent -- 2671
				) -- 2671
				if not decision.success then -- 2671
					Log( -- 2674
						"Error", -- 2674
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2674
					) -- 2674
					clearPreExecutedResults(shared) -- 2675
					return ____awaiter_resolve(nil, decision) -- 2675
				end -- 2675
				decisions[#decisions + 1] = decision -- 2678
				i = i + 1 -- 2647
			end -- 2647
		end -- 2647
		if #decisions == 1 then -- 2647
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2681
			return ____awaiter_resolve(nil, decisions[1]) -- 2681
		end -- 2681
		do -- 2681
			local i = 0 -- 2684
			while i < #decisions do -- 2684
				if decisions[i + 1].tool == "finish" then -- 2684
					clearPreExecutedResults(shared) -- 2686
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2686
				end -- 2686
				i = i + 1 -- 2684
			end -- 2684
		end -- 2684
		Log( -- 2694
			"Info", -- 2694
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2694
				__TS__ArrayMap( -- 2694
					decisions, -- 2694
					function(____, decision) return decision.tool end -- 2694
				), -- 2694
				"," -- 2694
			) -- 2694
		) -- 2694
		return ____awaiter_resolve(nil, { -- 2694
			success = true, -- 2696
			kind = "batch", -- 2697
			decisions = decisions, -- 2698
			content = messageContent, -- 2699
			reasoningContent = reasoningContent -- 2700
		}) -- 2700
	end) -- 2700
end -- 2553
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2704
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2704
		Log( -- 2709
			"Info", -- 2709
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2709
		) -- 2709
		local lastError = initialError -- 2710
		local candidateRaw = "" -- 2711
		do -- 2711
			local attempt = 0 -- 2712
			while attempt < shared.llmMaxTry do -- 2712
				do -- 2712
					Log( -- 2713
						"Info", -- 2713
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2713
					) -- 2713
					local messages = buildXmlRepairMessages( -- 2714
						shared, -- 2715
						originalRaw, -- 2716
						candidateRaw, -- 2717
						lastError, -- 2718
						attempt + 1 -- 2719
					) -- 2719
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2721
					if shared.stopToken.stopped then -- 2721
						return ____awaiter_resolve( -- 2721
							nil, -- 2721
							{ -- 2723
								success = false, -- 2723
								message = getCancelledReason(shared) -- 2723
							} -- 2723
						) -- 2723
					end -- 2723
					if not llmRes.success then -- 2723
						lastError = llmRes.message -- 2726
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2727
						goto __continue429 -- 2728
					end -- 2728
					candidateRaw = llmRes.text -- 2730
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2731
					if decision.success then -- 2731
						decision.reasoningContent = llmRes.reasoningContent -- 2733
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2734
						return ____awaiter_resolve(nil, decision) -- 2734
					end -- 2734
					lastError = decision.message -- 2737
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2738
				end -- 2738
				::__continue429:: -- 2738
				attempt = attempt + 1 -- 2712
			end -- 2712
		end -- 2712
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2740
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2740
	end) -- 2740
end -- 2704
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2748
	if attempt == nil then -- 2748
		attempt = 1 -- 2751
	end -- 2751
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2751
		local messages = buildDecisionMessages( -- 2754
			shared, -- 2755
			lastError, -- 2756
			attempt, -- 2757
			lastRaw, -- 2758
			"xml" -- 2759
		) -- 2759
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2761
		if shared.stopToken.stopped then -- 2761
			return ____awaiter_resolve( -- 2761
				nil, -- 2761
				{ -- 2763
					success = false, -- 2763
					message = getCancelledReason(shared) -- 2763
				} -- 2763
			) -- 2763
		end -- 2763
		if not llmRes.success then -- 2763
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2763
		end -- 2763
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2772
		if decision.success then -- 2772
			decision.reasoningContent = llmRes.reasoningContent -- 2774
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2774
				return ____awaiter_resolve( -- 2774
					nil, -- 2774
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2776
				) -- 2776
			end -- 2776
			return ____awaiter_resolve(nil, decision) -- 2776
		end -- 2776
		return ____awaiter_resolve( -- 2776
			nil, -- 2776
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2784
		) -- 2784
	end) -- 2784
end -- 2748
function MainDecisionAgent.prototype.exec(self, input) -- 2787
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2787
		local shared = input.shared -- 2788
		if shared.stopToken.stopped then -- 2788
			return ____awaiter_resolve( -- 2788
				nil, -- 2788
				{ -- 2790
					success = false, -- 2790
					message = getCancelledReason(shared) -- 2790
				} -- 2790
			) -- 2790
		end -- 2790
		if shared.step >= shared.maxSteps then -- 2790
			Log( -- 2793
				"Warn", -- 2793
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2793
			) -- 2793
			return ____awaiter_resolve( -- 2793
				nil, -- 2793
				{ -- 2794
					success = false, -- 2794
					message = getMaxStepsReachedReason(shared) -- 2794
				} -- 2794
			) -- 2794
		end -- 2794
		if shared.decisionMode == "tool_calling" then -- 2794
			Log( -- 2798
				"Info", -- 2798
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2798
			) -- 2798
			local lastError = "tool calling validation failed" -- 2799
			local lastRaw = "" -- 2800
			local shouldFallbackToXml = false -- 2801
			do -- 2801
				local attempt = 0 -- 2802
				while attempt < shared.llmMaxTry do -- 2802
					Log( -- 2803
						"Info", -- 2803
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2803
					) -- 2803
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2804
					if shared.stopToken.stopped then -- 2804
						return ____awaiter_resolve( -- 2804
							nil, -- 2804
							{ -- 2811
								success = false, -- 2811
								message = getCancelledReason(shared) -- 2811
							} -- 2811
						) -- 2811
					end -- 2811
					if decision.success then -- 2811
						return ____awaiter_resolve(nil, decision) -- 2811
					end -- 2811
					lastError = decision.message -- 2816
					lastRaw = decision.raw or "" -- 2817
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2818
					if lastError == "missing tool call" then -- 2818
						shouldFallbackToXml = true -- 2820
						break -- 2821
					end -- 2821
					attempt = attempt + 1 -- 2802
				end -- 2802
			end -- 2802
			if shouldFallbackToXml then -- 2802
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2825
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2826
				do -- 2826
					local attempt = 0 -- 2827
					while attempt < shared.llmMaxTry do -- 2827
						Log( -- 2828
							"Info", -- 2828
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2828
						) -- 2828
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2829
						if shared.stopToken.stopped then -- 2829
							return ____awaiter_resolve( -- 2829
								nil, -- 2829
								{ -- 2836
									success = false, -- 2836
									message = getCancelledReason(shared) -- 2836
								} -- 2836
							) -- 2836
						end -- 2836
						if decision.success then -- 2836
							return ____awaiter_resolve(nil, decision) -- 2836
						end -- 2836
						lastError = decision.message -- 2841
						lastRaw = decision.raw or "" -- 2842
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2843
						attempt = attempt + 1 -- 2827
					end -- 2827
				end -- 2827
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2845
				return ____awaiter_resolve( -- 2845
					nil, -- 2845
					{ -- 2846
						success = false, -- 2846
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2846
					} -- 2846
				) -- 2846
			end -- 2846
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2848
			return ____awaiter_resolve( -- 2848
				nil, -- 2848
				{ -- 2849
					success = false, -- 2849
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2849
				} -- 2849
			) -- 2849
		end -- 2849
		local lastError = "xml validation failed" -- 2852
		local lastRaw = "" -- 2853
		do -- 2853
			local attempt = 0 -- 2854
			while attempt < shared.llmMaxTry do -- 2854
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2855
				if shared.stopToken.stopped then -- 2855
					return ____awaiter_resolve( -- 2855
						nil, -- 2855
						{ -- 2864
							success = false, -- 2864
							message = getCancelledReason(shared) -- 2864
						} -- 2864
					) -- 2864
				end -- 2864
				if decision.success then -- 2864
					return ____awaiter_resolve(nil, decision) -- 2864
				end -- 2864
				lastError = decision.message -- 2869
				lastRaw = decision.raw or "" -- 2870
				attempt = attempt + 1 -- 2854
			end -- 2854
		end -- 2854
		return ____awaiter_resolve( -- 2854
			nil, -- 2854
			{ -- 2872
				success = false, -- 2872
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2872
			} -- 2872
		) -- 2872
	end) -- 2872
end -- 2787
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2875
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2875
		local result = execRes -- 2876
		if not result.success then -- 2876
			if shared.stopToken.stopped then -- 2876
				shared.error = getCancelledReason(shared) -- 2879
				shared.done = true -- 2880
				return ____awaiter_resolve(nil, "done") -- 2880
			end -- 2880
			shared.error = result.message -- 2883
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2884
			shared.done = true -- 2885
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2886
			persistHistoryState(shared) -- 2890
			return ____awaiter_resolve(nil, "done") -- 2890
		end -- 2890
		if isDecisionBatchSuccess(result) then -- 2890
			local startStep = shared.step -- 2894
			local actions = {} -- 2895
			do -- 2895
				local i = 0 -- 2896
				while i < #result.decisions do -- 2896
					local decision = result.decisions[i + 1] -- 2897
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2898
					local step = startStep + i + 1 -- 2899
					local ____temp_55 -- 2900
					if i == 0 then -- 2900
						____temp_55 = decision.reason -- 2900
					else -- 2900
						____temp_55 = "" -- 2900
					end -- 2900
					local actionReason = ____temp_55 -- 2900
					local ____temp_56 -- 2901
					if i == 0 then -- 2901
						____temp_56 = decision.reasoningContent -- 2901
					else -- 2901
						____temp_56 = nil -- 2901
					end -- 2901
					local actionReasoningContent = ____temp_56 -- 2901
					emitAgentEvent(shared, { -- 2902
						type = "decision_made", -- 2903
						sessionId = shared.sessionId, -- 2904
						taskId = shared.taskId, -- 2905
						step = step, -- 2906
						tool = decision.tool, -- 2907
						reason = actionReason, -- 2908
						reasoningContent = actionReasoningContent, -- 2909
						params = decision.params -- 2910
					}) -- 2910
					local action = { -- 2912
						step = step, -- 2913
						toolCallId = toolCallId, -- 2914
						tool = decision.tool, -- 2915
						reason = actionReason or "", -- 2916
						reasoningContent = actionReasoningContent, -- 2917
						params = decision.params, -- 2918
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2919
					} -- 2919
					local ____shared_history_57 = shared.history -- 2919
					____shared_history_57[#____shared_history_57 + 1] = action -- 2921
					actions[#actions + 1] = action -- 2922
					i = i + 1 -- 2896
				end -- 2896
			end -- 2896
			shared.step = startStep + #actions -- 2924
			shared.pendingToolActions = actions -- 2925
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2926
			persistHistoryState(shared) -- 2932
			return ____awaiter_resolve(nil, "batch_tools") -- 2932
		end -- 2932
		if result.directSummary and result.directSummary ~= "" then -- 2932
			shared.response = result.directSummary -- 2936
			shared.done = true -- 2937
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2938
			persistHistoryState(shared) -- 2943
			return ____awaiter_resolve(nil, "done") -- 2943
		end -- 2943
		if result.tool == "finish" then -- 2943
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2947
			shared.response = finalMessage -- 2948
			shared.done = true -- 2949
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2950
			persistHistoryState(shared) -- 2955
			return ____awaiter_resolve(nil, "done") -- 2955
		end -- 2955
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2958
		shared.step = shared.step + 1 -- 2959
		local step = shared.step -- 2960
		emitAgentEvent(shared, { -- 2961
			type = "decision_made", -- 2962
			sessionId = shared.sessionId, -- 2963
			taskId = shared.taskId, -- 2964
			step = step, -- 2965
			tool = result.tool, -- 2966
			reason = result.reason, -- 2967
			reasoningContent = result.reasoningContent, -- 2968
			params = result.params -- 2969
		}) -- 2969
		local ____shared_history_58 = shared.history -- 2969
		____shared_history_58[#____shared_history_58 + 1] = { -- 2971
			step = step, -- 2972
			toolCallId = toolCallId, -- 2973
			tool = result.tool, -- 2974
			reason = result.reason or "", -- 2975
			reasoningContent = result.reasoningContent, -- 2976
			params = result.params, -- 2977
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2978
		} -- 2978
		local action = shared.history[#shared.history] -- 2980
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2981
		if canPreExecuteTool(action.tool) then -- 2981
			shared.pendingToolActions = {action} -- 2983
			persistHistoryState(shared) -- 2984
			return ____awaiter_resolve(nil, "batch_tools") -- 2984
		end -- 2984
		clearPreExecutedResults(shared) -- 2987
		persistHistoryState(shared) -- 2988
		return ____awaiter_resolve(nil, result.tool) -- 2988
	end) -- 2988
end -- 2875
local ReadFileAction = __TS__Class() -- 2993
ReadFileAction.name = "ReadFileAction" -- 2993
__TS__ClassExtends(ReadFileAction, Node) -- 2993
function ReadFileAction.prototype.prep(self, shared) -- 2994
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2994
		local last = shared.history[#shared.history] -- 2995
		if not last then -- 2995
			error( -- 2996
				__TS__New(Error, "no history"), -- 2996
				0 -- 2996
			) -- 2996
		end -- 2996
		emitAgentStartEvent(shared, last) -- 2997
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2998
		if __TS__StringTrim(path) == "" then -- 2998
			error( -- 3001
				__TS__New(Error, "missing path"), -- 3001
				0 -- 3001
			) -- 3001
		end -- 3001
		local ____path_61 = path -- 3003
		local ____shared_workingDir_62 = shared.workingDir -- 3005
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 3006
		local ____last_params_startLine_59 = last.params.startLine -- 3007
		if ____last_params_startLine_59 == nil then -- 3007
			____last_params_startLine_59 = 1 -- 3007
		end -- 3007
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 3007
		local ____last_params_endLine_60 = last.params.endLine -- 3008
		if ____last_params_endLine_60 == nil then -- 3008
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 3008
		end -- 3008
		return ____awaiter_resolve( -- 3008
			nil, -- 3008
			{ -- 3002
				path = ____path_61, -- 3003
				tool = "read_file", -- 3004
				workDir = ____shared_workingDir_62, -- 3005
				docLanguage = ____temp_63, -- 3006
				startLine = ____TS__Number_result_64, -- 3007
				endLine = __TS__Number(____last_params_endLine_60) -- 3008
			} -- 3008
		) -- 3008
	end) -- 3008
end -- 2994
function ReadFileAction.prototype.exec(self, input) -- 3012
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3012
		return ____awaiter_resolve( -- 3012
			nil, -- 3012
			Tools.readFile( -- 3013
				input.workDir, -- 3014
				input.path, -- 3015
				__TS__Number(input.startLine or 1), -- 3016
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3017
				input.docLanguage -- 3018
			) -- 3018
		) -- 3018
	end) -- 3018
end -- 3012
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3022
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3022
		local result = execRes -- 3023
		local last = shared.history[#shared.history] -- 3024
		if last ~= nil then -- 3024
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3026
			appendToolResultMessage(shared, last) -- 3027
			emitAgentFinishEvent(shared, last) -- 3028
		end -- 3028
		persistHistoryState(shared) -- 3030
		__TS__Await(maybeCompressHistory(shared)) -- 3031
		persistHistoryState(shared) -- 3032
		return ____awaiter_resolve(nil, "main") -- 3032
	end) -- 3032
end -- 3022
local SearchFilesAction = __TS__Class() -- 3037
SearchFilesAction.name = "SearchFilesAction" -- 3037
__TS__ClassExtends(SearchFilesAction, Node) -- 3037
function SearchFilesAction.prototype.prep(self, shared) -- 3038
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3038
		local last = shared.history[#shared.history] -- 3039
		if not last then -- 3039
			error( -- 3040
				__TS__New(Error, "no history"), -- 3040
				0 -- 3040
			) -- 3040
		end -- 3040
		emitAgentStartEvent(shared, last) -- 3041
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3041
	end) -- 3041
end -- 3038
function SearchFilesAction.prototype.exec(self, input) -- 3045
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3045
		local params = input.params -- 3046
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 3047
		local ____input_workDir_71 = input.workDir -- 3048
		local ____temp_72 = params.path or "" -- 3049
		local ____temp_73 = params.pattern or "" -- 3050
		local ____params_globs_74 = params.globs -- 3051
		local ____params_useRegex_75 = params.useRegex -- 3052
		local ____params_caseSensitive_76 = params.caseSensitive -- 3053
		local ____math_max_67 = math.max -- 3056
		local ____math_floor_66 = math.floor -- 3056
		local ____params_limit_65 = params.limit -- 3056
		if ____params_limit_65 == nil then -- 3056
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 3056
		end -- 3056
		local ____math_max_67_result_77 = ____math_max_67( -- 3056
			1, -- 3056
			____math_floor_66(__TS__Number(____params_limit_65)) -- 3056
		) -- 3056
		local ____math_max_70 = math.max -- 3057
		local ____math_floor_69 = math.floor -- 3057
		local ____params_offset_68 = params.offset -- 3057
		if ____params_offset_68 == nil then -- 3057
			____params_offset_68 = 0 -- 3057
		end -- 3057
		local result = __TS__Await(____Tools_searchFiles_78({ -- 3047
			workDir = ____input_workDir_71, -- 3048
			path = ____temp_72, -- 3049
			pattern = ____temp_73, -- 3050
			globs = ____params_globs_74, -- 3051
			useRegex = ____params_useRegex_75, -- 3052
			caseSensitive = ____params_caseSensitive_76, -- 3053
			includeContent = true, -- 3054
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3055
			limit = ____math_max_67_result_77, -- 3056
			offset = ____math_max_70( -- 3057
				0, -- 3057
				____math_floor_69(__TS__Number(____params_offset_68)) -- 3057
			), -- 3057
			groupByFile = params.groupByFile == true -- 3058
		})) -- 3058
		return ____awaiter_resolve(nil, result) -- 3058
	end) -- 3058
end -- 3045
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3063
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3063
		local last = shared.history[#shared.history] -- 3064
		if last ~= nil then -- 3064
			local result = execRes -- 3066
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3067
			appendToolResultMessage(shared, last) -- 3068
			emitAgentFinishEvent(shared, last) -- 3069
		end -- 3069
		persistHistoryState(shared) -- 3071
		__TS__Await(maybeCompressHistory(shared)) -- 3072
		persistHistoryState(shared) -- 3073
		return ____awaiter_resolve(nil, "main") -- 3073
	end) -- 3073
end -- 3063
local SearchDoraAPIAction = __TS__Class() -- 3078
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3078
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3078
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3079
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3079
		local last = shared.history[#shared.history] -- 3080
		if not last then -- 3080
			error( -- 3081
				__TS__New(Error, "no history"), -- 3081
				0 -- 3081
			) -- 3081
		end -- 3081
		emitAgentStartEvent(shared, last) -- 3082
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3082
	end) -- 3082
end -- 3079
function SearchDoraAPIAction.prototype.exec(self, input) -- 3086
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3086
		local params = input.params -- 3087
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 3088
		local ____temp_82 = params.pattern or "" -- 3089
		local ____temp_83 = params.docSource or "api" -- 3090
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 3091
		local ____temp_85 = params.programmingLanguage or "ts" -- 3092
		local ____math_min_81 = math.min -- 3093
		local ____math_max_80 = math.max -- 3093
		local ____params_limit_79 = params.limit -- 3093
		if ____params_limit_79 == nil then -- 3093
			____params_limit_79 = 8 -- 3093
		end -- 3093
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 3088
			pattern = ____temp_82, -- 3089
			docSource = ____temp_83, -- 3090
			docLanguage = ____temp_84, -- 3091
			programmingLanguage = ____temp_85, -- 3092
			limit = ____math_min_81( -- 3093
				SEARCH_DORA_API_LIMIT_MAX, -- 3093
				____math_max_80( -- 3093
					1, -- 3093
					__TS__Number(____params_limit_79) -- 3093
				) -- 3093
			), -- 3093
			useRegex = params.useRegex, -- 3094
			caseSensitive = false, -- 3095
			includeContent = true, -- 3096
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3097
		})) -- 3097
		return ____awaiter_resolve(nil, result) -- 3097
	end) -- 3097
end -- 3086
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3102
		local last = shared.history[#shared.history] -- 3103
		if last ~= nil then -- 3103
			local result = execRes -- 3105
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3106
			appendToolResultMessage(shared, last) -- 3107
			emitAgentFinishEvent(shared, last) -- 3108
		end -- 3108
		persistHistoryState(shared) -- 3110
		__TS__Await(maybeCompressHistory(shared)) -- 3111
		persistHistoryState(shared) -- 3112
		return ____awaiter_resolve(nil, "main") -- 3112
	end) -- 3112
end -- 3102
local ListFilesAction = __TS__Class() -- 3117
ListFilesAction.name = "ListFilesAction" -- 3117
__TS__ClassExtends(ListFilesAction, Node) -- 3117
function ListFilesAction.prototype.prep(self, shared) -- 3118
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3118
		local last = shared.history[#shared.history] -- 3119
		if not last then -- 3119
			error( -- 3120
				__TS__New(Error, "no history"), -- 3120
				0 -- 3120
			) -- 3120
		end -- 3120
		emitAgentStartEvent(shared, last) -- 3121
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3121
	end) -- 3121
end -- 3118
function ListFilesAction.prototype.exec(self, input) -- 3125
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3125
		local params = input.params -- 3126
		local ____Tools_listFiles_93 = Tools.listFiles -- 3127
		local ____input_workDir_90 = input.workDir -- 3128
		local ____temp_91 = params.path or "" -- 3129
		local ____params_globs_92 = params.globs -- 3130
		local ____math_max_89 = math.max -- 3131
		local ____math_floor_88 = math.floor -- 3131
		local ____params_maxEntries_87 = params.maxEntries -- 3131
		if ____params_maxEntries_87 == nil then -- 3131
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3131
		end -- 3131
		local result = ____Tools_listFiles_93({ -- 3127
			workDir = ____input_workDir_90, -- 3128
			path = ____temp_91, -- 3129
			globs = ____params_globs_92, -- 3130
			maxEntries = ____math_max_89( -- 3131
				1, -- 3131
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3131
			) -- 3131
		}) -- 3131
		return ____awaiter_resolve(nil, result) -- 3131
	end) -- 3131
end -- 3125
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3136
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3136
		local last = shared.history[#shared.history] -- 3137
		if last ~= nil then -- 3137
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3139
			appendToolResultMessage(shared, last) -- 3140
			emitAgentFinishEvent(shared, last) -- 3141
		end -- 3141
		persistHistoryState(shared) -- 3143
		__TS__Await(maybeCompressHistory(shared)) -- 3144
		persistHistoryState(shared) -- 3145
		return ____awaiter_resolve(nil, "main") -- 3145
	end) -- 3145
end -- 3136
local DeleteFileAction = __TS__Class() -- 3150
DeleteFileAction.name = "DeleteFileAction" -- 3150
__TS__ClassExtends(DeleteFileAction, Node) -- 3150
function DeleteFileAction.prototype.prep(self, shared) -- 3151
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3151
		local last = shared.history[#shared.history] -- 3152
		if not last then -- 3152
			error( -- 3153
				__TS__New(Error, "no history"), -- 3153
				0 -- 3153
			) -- 3153
		end -- 3153
		emitAgentStartEvent(shared, last) -- 3154
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3155
		if __TS__StringTrim(targetFile) == "" then -- 3155
			error( -- 3158
				__TS__New(Error, "missing target_file"), -- 3158
				0 -- 3158
			) -- 3158
		end -- 3158
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3158
	end) -- 3158
end -- 3151
function DeleteFileAction.prototype.exec(self, input) -- 3162
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3162
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3163
		if not result.success then -- 3163
			return ____awaiter_resolve(nil, result) -- 3163
		end -- 3163
		return ____awaiter_resolve(nil, { -- 3163
			success = true, -- 3171
			changed = true, -- 3172
			mode = "delete", -- 3173
			checkpointId = result.checkpointId, -- 3174
			checkpointSeq = result.checkpointSeq, -- 3175
			files = {{path = input.targetFile, op = "delete"}} -- 3176
		}) -- 3176
	end) -- 3176
end -- 3162
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3180
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3180
		local last = shared.history[#shared.history] -- 3181
		if last ~= nil then -- 3181
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3183
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3184
			appendToolResultMessage(shared, last) -- 3185
			emitAgentFinishEvent(shared, last) -- 3186
			local result = last.result -- 3187
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3187
				emitAgentEvent(shared, { -- 3192
					type = "checkpoint_created", -- 3193
					sessionId = shared.sessionId, -- 3194
					taskId = shared.taskId, -- 3195
					step = last.step, -- 3196
					tool = "delete_file", -- 3197
					checkpointId = result.checkpointId, -- 3198
					checkpointSeq = result.checkpointSeq, -- 3199
					files = result.files -- 3200
				}) -- 3200
			end -- 3200
		end -- 3200
		persistHistoryState(shared) -- 3204
		__TS__Await(maybeCompressHistory(shared)) -- 3205
		persistHistoryState(shared) -- 3206
		return ____awaiter_resolve(nil, "main") -- 3206
	end) -- 3206
end -- 3180
local BuildAction = __TS__Class() -- 3211
BuildAction.name = "BuildAction" -- 3211
__TS__ClassExtends(BuildAction, Node) -- 3211
function BuildAction.prototype.prep(self, shared) -- 3212
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3212
		local last = shared.history[#shared.history] -- 3213
		if not last then -- 3213
			error( -- 3214
				__TS__New(Error, "no history"), -- 3214
				0 -- 3214
			) -- 3214
		end -- 3214
		emitAgentStartEvent(shared, last) -- 3215
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3215
	end) -- 3215
end -- 3212
function BuildAction.prototype.exec(self, input) -- 3219
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3219
		local params = input.params -- 3220
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3221
		return ____awaiter_resolve(nil, result) -- 3221
	end) -- 3221
end -- 3219
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3228
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3228
		local last = shared.history[#shared.history] -- 3229
		if last ~= nil then -- 3229
			last.result = sanitizeBuildResultForHistory(execRes) -- 3231
			appendToolResultMessage(shared, last) -- 3232
			emitAgentFinishEvent(shared, last) -- 3233
		end -- 3233
		persistHistoryState(shared) -- 3235
		__TS__Await(maybeCompressHistory(shared)) -- 3236
		persistHistoryState(shared) -- 3237
		return ____awaiter_resolve(nil, "main") -- 3237
	end) -- 3237
end -- 3228
local SpawnSubAgentAction = __TS__Class() -- 3242
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3242
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3242
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3243
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3243
		local last = shared.history[#shared.history] -- 3252
		if not last then -- 3252
			error( -- 3253
				__TS__New(Error, "no history"), -- 3253
				0 -- 3253
			) -- 3253
		end -- 3253
		emitAgentStartEvent(shared, last) -- 3254
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3255
			last.params.filesHint, -- 3256
			function(____, item) return type(item) == "string" end -- 3256
		) or nil -- 3256
		return ____awaiter_resolve( -- 3256
			nil, -- 3256
			{ -- 3258
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3259
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3260
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3261
				filesHint = filesHint, -- 3262
				sessionId = shared.sessionId, -- 3263
				projectRoot = shared.workingDir, -- 3264
				spawnSubAgent = shared.spawnSubAgent -- 3265
			} -- 3265
		) -- 3265
	end) -- 3265
end -- 3243
function SpawnSubAgentAction.prototype.exec(self, input) -- 3269
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3269
		if not input.spawnSubAgent then -- 3269
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3269
		end -- 3269
		if input.sessionId == nil or input.sessionId <= 0 then -- 3269
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3269
		end -- 3269
		local ____Log_99 = Log -- 3284
		local ____temp_96 = #input.title -- 3284
		local ____temp_97 = #input.prompt -- 3284
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3284
		local ____opt_94 = input.filesHint -- 3284
		____Log_99( -- 3284
			"Info", -- 3284
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3284
		) -- 3284
		local result = __TS__Await(input.spawnSubAgent({ -- 3285
			parentSessionId = input.sessionId, -- 3286
			projectRoot = input.projectRoot, -- 3287
			title = input.title, -- 3288
			prompt = input.prompt, -- 3289
			expectedOutput = input.expectedOutput, -- 3290
			filesHint = input.filesHint -- 3291
		})) -- 3291
		if not result.success then -- 3291
			return ____awaiter_resolve(nil, result) -- 3291
		end -- 3291
		return ____awaiter_resolve(nil, { -- 3291
			success = true, -- 3297
			sessionId = result.sessionId, -- 3298
			taskId = result.taskId, -- 3299
			title = result.title, -- 3300
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3301
		}) -- 3301
	end) -- 3301
end -- 3269
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3305
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3305
		local last = shared.history[#shared.history] -- 3306
		if last ~= nil then -- 3306
			last.result = execRes -- 3308
			appendToolResultMessage(shared, last) -- 3309
			emitAgentFinishEvent(shared, last) -- 3310
		end -- 3310
		persistHistoryState(shared) -- 3312
		__TS__Await(maybeCompressHistory(shared)) -- 3313
		persistHistoryState(shared) -- 3314
		return ____awaiter_resolve(nil, "main") -- 3314
	end) -- 3314
end -- 3305
local ListSubAgentsAction = __TS__Class() -- 3319
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3319
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3319
function ListSubAgentsAction.prototype.prep(self, shared) -- 3320
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3320
		local last = shared.history[#shared.history] -- 3329
		if not last then -- 3329
			error( -- 3330
				__TS__New(Error, "no history"), -- 3330
				0 -- 3330
			) -- 3330
		end -- 3330
		emitAgentStartEvent(shared, last) -- 3331
		return ____awaiter_resolve( -- 3331
			nil, -- 3331
			{ -- 3332
				sessionId = shared.sessionId, -- 3333
				projectRoot = shared.workingDir, -- 3334
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3335
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3336
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3337
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3338
				listSubAgents = shared.listSubAgents -- 3339
			} -- 3339
		) -- 3339
	end) -- 3339
end -- 3320
function ListSubAgentsAction.prototype.exec(self, input) -- 3343
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3343
		if not input.listSubAgents then -- 3343
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3343
		end -- 3343
		if input.sessionId == nil or input.sessionId <= 0 then -- 3343
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3343
		end -- 3343
		local result = __TS__Await(input.listSubAgents({ -- 3358
			sessionId = input.sessionId, -- 3359
			projectRoot = input.projectRoot, -- 3360
			status = input.status, -- 3361
			limit = input.limit, -- 3362
			offset = input.offset, -- 3363
			query = input.query -- 3364
		})) -- 3364
		return ____awaiter_resolve(nil, result) -- 3364
	end) -- 3364
end -- 3343
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3369
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3369
		local last = shared.history[#shared.history] -- 3370
		if last ~= nil then -- 3370
			last.result = execRes -- 3372
			appendToolResultMessage(shared, last) -- 3373
			emitAgentFinishEvent(shared, last) -- 3374
		end -- 3374
		persistHistoryState(shared) -- 3376
		__TS__Await(maybeCompressHistory(shared)) -- 3377
		persistHistoryState(shared) -- 3378
		return ____awaiter_resolve(nil, "main") -- 3378
	end) -- 3378
end -- 3369
EditFileAction = __TS__Class() -- 3383
EditFileAction.name = "EditFileAction" -- 3383
__TS__ClassExtends(EditFileAction, Node) -- 3383
function EditFileAction.prototype.prep(self, shared) -- 3384
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3384
		local last = shared.history[#shared.history] -- 3385
		if not last then -- 3385
			error( -- 3386
				__TS__New(Error, "no history"), -- 3386
				0 -- 3386
			) -- 3386
		end -- 3386
		emitAgentStartEvent(shared, last) -- 3387
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3388
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3391
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3392
		if __TS__StringTrim(path) == "" then -- 3392
			error( -- 3393
				__TS__New(Error, "missing path"), -- 3393
				0 -- 3393
			) -- 3393
		end -- 3393
		return ____awaiter_resolve(nil, { -- 3393
			path = path, -- 3394
			oldStr = oldStr, -- 3394
			newStr = newStr, -- 3394
			taskId = shared.taskId, -- 3394
			workDir = shared.workingDir -- 3394
		}) -- 3394
	end) -- 3394
end -- 3384
function EditFileAction.prototype.exec(self, input) -- 3397
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3397
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3398
		if not readRes.success then -- 3398
			if input.oldStr ~= "" then -- 3398
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3398
			end -- 3398
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3403
			if not createRes.success then -- 3403
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3403
			end -- 3403
			return ____awaiter_resolve(nil, { -- 3403
				success = true, -- 3411
				changed = true, -- 3412
				mode = "create", -- 3413
				checkpointId = createRes.checkpointId, -- 3414
				checkpointSeq = createRes.checkpointSeq, -- 3415
				files = {{path = input.path, op = "create"}} -- 3416
			}) -- 3416
		end -- 3416
		if input.oldStr == "" then -- 3416
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3420
			if not overwriteRes.success then -- 3420
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3420
			end -- 3420
			return ____awaiter_resolve(nil, { -- 3420
				success = true, -- 3428
				changed = true, -- 3429
				mode = "overwrite", -- 3430
				checkpointId = overwriteRes.checkpointId, -- 3431
				checkpointSeq = overwriteRes.checkpointSeq, -- 3432
				files = {{path = input.path, op = "write"}} -- 3433
			}) -- 3433
		end -- 3433
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3438
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3439
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3440
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3443
		if occurrences == 0 then -- 3443
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3445
			if not indentTolerant.success then -- 3445
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3445
			end -- 3445
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3449
			if not applyRes.success then -- 3449
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3449
			end -- 3449
			return ____awaiter_resolve(nil, { -- 3449
				success = true, -- 3457
				changed = true, -- 3458
				mode = "replace_indent_tolerant", -- 3459
				checkpointId = applyRes.checkpointId, -- 3460
				checkpointSeq = applyRes.checkpointSeq, -- 3461
				files = {{path = input.path, op = "write"}} -- 3462
			}) -- 3462
		end -- 3462
		if occurrences > 1 then -- 3462
			return ____awaiter_resolve( -- 3462
				nil, -- 3462
				{ -- 3466
					success = false, -- 3466
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3466
				} -- 3466
			) -- 3466
		end -- 3466
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3470
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3471
		if not applyRes.success then -- 3471
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3471
		end -- 3471
		return ____awaiter_resolve(nil, { -- 3471
			success = true, -- 3479
			changed = true, -- 3480
			mode = "replace", -- 3481
			checkpointId = applyRes.checkpointId, -- 3482
			checkpointSeq = applyRes.checkpointSeq, -- 3483
			files = {{path = input.path, op = "write"}} -- 3484
		}) -- 3484
	end) -- 3484
end -- 3397
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3488
		local last = shared.history[#shared.history] -- 3489
		if last ~= nil then -- 3489
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3491
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3492
			appendToolResultMessage(shared, last) -- 3493
			emitAgentFinishEvent(shared, last) -- 3494
			local result = last.result -- 3495
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3495
				emitAgentEvent(shared, { -- 3500
					type = "checkpoint_created", -- 3501
					sessionId = shared.sessionId, -- 3502
					taskId = shared.taskId, -- 3503
					step = last.step, -- 3504
					tool = last.tool, -- 3505
					checkpointId = result.checkpointId, -- 3506
					checkpointSeq = result.checkpointSeq, -- 3507
					files = result.files -- 3508
				}) -- 3508
			end -- 3508
		end -- 3508
		persistHistoryState(shared) -- 3512
		__TS__Await(maybeCompressHistory(shared)) -- 3513
		persistHistoryState(shared) -- 3514
		return ____awaiter_resolve(nil, "main") -- 3514
	end) -- 3514
end -- 3488
local function emitCheckpointEventForAction(shared, action) -- 3519
	local result = action.result -- 3520
	if not result then -- 3520
		return -- 3521
	end -- 3521
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3521
		emitAgentEvent(shared, { -- 3526
			type = "checkpoint_created", -- 3527
			sessionId = shared.sessionId, -- 3528
			taskId = shared.taskId, -- 3529
			step = action.step, -- 3530
			tool = action.tool, -- 3531
			checkpointId = result.checkpointId, -- 3532
			checkpointSeq = result.checkpointSeq, -- 3533
			files = result.files -- 3534
		}) -- 3534
	end -- 3534
end -- 3519
local function canRunBatchActionInParallel(self, action) -- 3839
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3840
end -- 3839
local function partitionToolCalls(actions) -- 3852
	local batches = {} -- 3853
	do -- 3853
		local i = 0 -- 3854
		while i < #actions do -- 3854
			local action = actions[i + 1] -- 3855
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3856
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3857
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3857
				local ____lastBatch_actions_134 = lastBatch.actions -- 3857
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3859
			else -- 3859
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3861
			end -- 3861
			i = i + 1 -- 3854
		end -- 3854
	end -- 3854
	return batches -- 3864
end -- 3852
local BatchToolAction = __TS__Class() -- 3867
BatchToolAction.name = "BatchToolAction" -- 3867
__TS__ClassExtends(BatchToolAction, Node) -- 3867
function BatchToolAction.prototype.prep(self, shared) -- 3868
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3868
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3868
	end) -- 3868
end -- 3868
function BatchToolAction.prototype.exec(self, input) -- 3872
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3872
		local shared = input.shared -- 3873
		local preExecuted = shared.preExecutedResults -- 3874
		local batches = partitionToolCalls(input.actions) -- 3875
		local parallelBatchCount = #__TS__ArrayFilter( -- 3876
			batches, -- 3876
			function(____, b) return b.isConcurrencySafe end -- 3876
		) -- 3876
		local serialBatchCount = #__TS__ArrayFilter( -- 3877
			batches, -- 3877
			function(____, b) return not b.isConcurrencySafe end -- 3877
		) -- 3877
		Log( -- 3878
			"Info", -- 3878
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3878
		) -- 3878
		do -- 3878
			local batchIdx = 0 -- 3880
			while batchIdx < #batches do -- 3880
				do -- 3880
					local batch = batches[batchIdx + 1] -- 3881
					if shared.stopToken.stopped then -- 3881
						for ____, action in ipairs(batch.actions) do -- 3883
							if not action.result then -- 3883
								action.result = { -- 3885
									success = false, -- 3885
									message = getCancelledReason(shared) -- 3885
								} -- 3885
							end -- 3885
						end -- 3885
						goto __continue601 -- 3888
					end -- 3888
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3888
						local preExecCount = #__TS__ArrayFilter( -- 3892
							batch.actions, -- 3892
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3892
						) -- 3892
						Log( -- 3893
							"Info", -- 3893
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3893
						) -- 3893
						do -- 3893
							local i = 0 -- 3894
							while i < #batch.actions do -- 3894
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3895
								i = i + 1 -- 3894
							end -- 3894
						end -- 3894
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3897
							batch.actions, -- 3897
							function(____, action) -- 3897
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3897
									if shared.stopToken.stopped then -- 3897
										action.result = { -- 3899
											success = false, -- 3899
											message = getCancelledReason(shared) -- 3899
										} -- 3899
										return ____awaiter_resolve(nil, action) -- 3899
									end -- 3899
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3902
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3903
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3904
									return ____awaiter_resolve(nil, action) -- 3904
								end) -- 3904
							end -- 3897
						))) -- 3897
						do -- 3897
							local i = 0 -- 3907
							while i < #batch.actions do -- 3907
								local action = batch.actions[i + 1] -- 3908
								if not action.result then -- 3908
									action.result = {success = false, message = "tool did not produce a result"} -- 3910
								end -- 3910
								appendToolResultMessage(shared, action) -- 3912
								emitAgentFinishEvent(shared, action) -- 3913
								emitCheckpointEventForAction(shared, action) -- 3914
								i = i + 1 -- 3907
							end -- 3907
						end -- 3907
					else -- 3907
						Log( -- 3917
							"Info", -- 3917
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3917
						) -- 3917
						do -- 3917
							local i = 0 -- 3918
							while i < #batch.actions do -- 3918
								local action = batch.actions[i + 1] -- 3919
								emitAgentStartEvent(shared, action) -- 3920
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3921
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3922
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3923
								appendToolResultMessage(shared, action) -- 3924
								emitAgentFinishEvent(shared, action) -- 3925
								emitCheckpointEventForAction(shared, action) -- 3926
								persistHistoryState(shared) -- 3927
								if shared.stopToken.stopped then -- 3927
									break -- 3929
								end -- 3929
								i = i + 1 -- 3918
							end -- 3918
						end -- 3918
					end -- 3918
				end -- 3918
				::__continue601:: -- 3918
				batchIdx = batchIdx + 1 -- 3880
			end -- 3880
		end -- 3880
		persistHistoryState(shared) -- 3934
		return ____awaiter_resolve(nil, input.actions) -- 3934
	end) -- 3934
end -- 3872
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3938
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3938
		shared.pendingToolActions = nil -- 3939
		shared.preExecutedResults = nil -- 3940
		persistHistoryState(shared) -- 3941
		__TS__Await(maybeCompressHistory(shared)) -- 3942
		persistHistoryState(shared) -- 3943
		return ____awaiter_resolve(nil, "main") -- 3943
	end) -- 3943
end -- 3938
local EndNode = __TS__Class() -- 3948
EndNode.name = "EndNode" -- 3948
__TS__ClassExtends(EndNode, Node) -- 3948
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3949
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3949
		return ____awaiter_resolve(nil, nil) -- 3949
	end) -- 3949
end -- 3949
local CodingAgentFlow = __TS__Class() -- 3954
CodingAgentFlow.name = "CodingAgentFlow" -- 3954
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3954
function CodingAgentFlow.prototype.____constructor(self, role) -- 3955
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3956
	local read = __TS__New(ReadFileAction, 1, 0) -- 3957
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3958
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3959
	local list = __TS__New(ListFilesAction, 1, 0) -- 3960
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3961
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3962
	local build = __TS__New(BuildAction, 1, 0) -- 3963
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3964
	local edit = __TS__New(EditFileAction, 1, 0) -- 3965
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3966
	local done = __TS__New(EndNode, 1, 0) -- 3967
	main:on("batch_tools", batch) -- 3969
	main:on("grep_files", search) -- 3970
	main:on("search_dora_api", searchDora) -- 3971
	main:on("glob_files", list) -- 3972
	if role == "main" then -- 3972
		main:on("read_file", read) -- 3974
		main:on("delete_file", del) -- 3975
		main:on("build", build) -- 3976
		main:on("edit_file", edit) -- 3977
		main:on("list_sub_agents", listSub) -- 3978
		main:on("spawn_sub_agent", spawn) -- 3979
	else -- 3979
		main:on("read_file", read) -- 3981
		main:on("delete_file", del) -- 3982
		main:on("build", build) -- 3983
		main:on("edit_file", edit) -- 3984
	end -- 3984
	main:on("done", done) -- 3986
	search:on("main", main) -- 3988
	searchDora:on("main", main) -- 3989
	list:on("main", main) -- 3990
	listSub:on("main", main) -- 3991
	spawn:on("main", main) -- 3992
	batch:on("main", main) -- 3993
	read:on("main", main) -- 3994
	del:on("main", main) -- 3995
	build:on("main", main) -- 3996
	edit:on("main", main) -- 3997
	Flow.prototype.____constructor(self, main) -- 3999
end -- 3955
local function runCodingAgentAsync(options) -- 4021
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4021
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4021
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4021
		end -- 4021
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4025
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4026
		if not llmConfigRes.success then -- 4026
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4026
		end -- 4026
		local llmConfig = llmConfigRes.config -- 4032
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4033
		if not taskRes.success then -- 4033
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4033
		end -- 4033
		local compressor = __TS__New(MemoryCompressor, { -- 4040
			compressionThreshold = 0.8, -- 4041
			compressionTargetThreshold = 0.5, -- 4042
			maxCompressionRounds = 3, -- 4043
			projectDir = options.workDir, -- 4044
			llmConfig = llmConfig, -- 4045
			promptPack = options.promptPack, -- 4046
			scope = options.memoryScope -- 4047
		}) -- 4047
		local persistedSession = compressor:getStorage():readSessionState() -- 4049
		local promptPack = compressor:getPromptPack() -- 4050
		local shared = { -- 4052
			sessionId = options.sessionId, -- 4053
			taskId = taskRes.taskId, -- 4054
			role = options.role or "main", -- 4055
			maxSteps = math.max( -- 4056
				1, -- 4056
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4056
			), -- 4056
			llmMaxTry = math.max( -- 4057
				1, -- 4057
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4057
			), -- 4057
			step = 0, -- 4058
			done = false, -- 4059
			stopToken = options.stopToken or ({stopped = false}), -- 4060
			response = "", -- 4061
			userQuery = normalizedPrompt, -- 4062
			workingDir = options.workDir, -- 4063
			useChineseResponse = options.useChineseResponse == true, -- 4064
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4065
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4068
			llmConfig = llmConfig, -- 4069
			onEvent = options.onEvent, -- 4070
			promptPack = promptPack, -- 4071
			history = {}, -- 4072
			messages = persistedSession.messages, -- 4073
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4074
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4075
			memory = {compressor = compressor}, -- 4077
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4081
			spawnSubAgent = options.spawnSubAgent, -- 4086
			listSubAgents = options.listSubAgents -- 4087
		} -- 4087
		local ____try = __TS__AsyncAwaiter(function() -- 4087
			emitAgentEvent(shared, { -- 4091
				type = "task_started", -- 4092
				sessionId = shared.sessionId, -- 4093
				taskId = shared.taskId, -- 4094
				prompt = shared.userQuery, -- 4095
				workDir = shared.workingDir, -- 4096
				maxSteps = shared.maxSteps -- 4097
			}) -- 4097
			if shared.stopToken.stopped then -- 4097
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4100
				return ____awaiter_resolve( -- 4100
					nil, -- 4100
					emitAgentTaskFinishEvent( -- 4101
						shared, -- 4101
						false, -- 4101
						getCancelledReason(shared) -- 4101
					) -- 4101
				) -- 4101
			end -- 4101
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4103
			local promptCommand = getPromptCommand(shared.userQuery) -- 4104
			if promptCommand == "clear" then -- 4104
				return ____awaiter_resolve( -- 4104
					nil, -- 4104
					clearSessionHistory(shared) -- 4106
				) -- 4106
			end -- 4106
			if promptCommand == "compact" then -- 4106
				if shared.role == "sub" then -- 4106
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4110
					return ____awaiter_resolve( -- 4110
						nil, -- 4110
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4111
					) -- 4111
				end -- 4111
				return ____awaiter_resolve( -- 4111
					nil, -- 4111
					__TS__Await(compactAllHistory(shared)) -- 4119
				) -- 4119
			end -- 4119
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4121
			persistHistoryState(shared) -- 4125
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4126
			__TS__Await(flow:run(shared)) -- 4127
			if shared.stopToken.stopped then -- 4127
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4129
				return ____awaiter_resolve( -- 4129
					nil, -- 4129
					emitAgentTaskFinishEvent( -- 4130
						shared, -- 4130
						false, -- 4130
						getCancelledReason(shared) -- 4130
					) -- 4130
				) -- 4130
			end -- 4130
			if shared.error then -- 4130
				return ____awaiter_resolve( -- 4130
					nil, -- 4130
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4133
				) -- 4133
			end -- 4133
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4136
			return ____awaiter_resolve( -- 4136
				nil, -- 4136
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4137
			) -- 4137
		end) -- 4137
		__TS__Await(____try.catch( -- 4090
			____try, -- 4090
			function(____, e) -- 4090
				return ____awaiter_resolve( -- 4090
					nil, -- 4090
					finalizeAgentFailure( -- 4140
						shared, -- 4140
						tostring(e) -- 4140
					) -- 4140
				) -- 4140
			end -- 4140
		)) -- 4140
	end) -- 4140
end -- 4021
function ____exports.runCodingAgent(options, callback) -- 4144
	local ____self_137 = runCodingAgentAsync(options) -- 4144
	____self_137["then"]( -- 4144
		____self_137, -- 4144
		function(____, result) return callback(result) end -- 4145
	) -- 4145
end -- 4144
return ____exports -- 4144