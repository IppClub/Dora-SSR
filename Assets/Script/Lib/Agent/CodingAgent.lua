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
function emitAgentEvent(shared, event) -- 779
	if shared.onEvent then -- 779
		do -- 779
			local function ____catch(____error) -- 779
				Log( -- 784
					"Error", -- 784
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 784
				) -- 784
			end -- 784
			local ____try, ____hasReturned = pcall(function() -- 784
				shared:onEvent(event) -- 782
			end) -- 782
			if not ____try then -- 782
				____catch(____hasReturned) -- 782
			end -- 782
		end -- 782
	end -- 782
end -- 782
function getCancelledReason(shared) -- 913
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 913
		return shared.stopToken.reason -- 914
	end -- 914
	return shared.useChineseResponse and "已取消" or "cancelled" -- 915
end -- 915
function truncateText(text, maxLen) -- 1096
	if #text <= maxLen then -- 1096
		return text -- 1097
	end -- 1097
	local nextPos = utf8.offset(text, maxLen + 1) -- 1098
	if nextPos == nil then -- 1098
		return text -- 1099
	end -- 1099
	return string.sub(text, 1, nextPos - 1) .. "..." -- 1100
end -- 1100
function utf8TakeHead(text, maxChars) -- 1103
	if maxChars <= 0 or text == "" then -- 1103
		return "" -- 1104
	end -- 1104
	local nextPos = utf8.offset(text, maxChars + 1) -- 1105
	if nextPos == nil then -- 1105
		return text -- 1106
	end -- 1106
	return string.sub(text, 1, nextPos - 1) -- 1107
end -- 1107
function getReplyLanguageDirective(shared) -- 1110
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 1111
end -- 1111
function replacePromptVars(template, vars) -- 1116
	local output = template -- 1117
	for key in pairs(vars) do -- 1118
		output = table.concat( -- 1119
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1119
			vars[key] or "" or "," -- 1119
		) -- 1119
	end -- 1119
	return output -- 1121
end -- 1121
function limitReadContentForHistory(content, tool) -- 1124
	local lines = __TS__StringSplit(content, "\n") -- 1125
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1126
	local limitedByLines = overLineLimit and table.concat( -- 1127
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1128
		"\n" -- 1128
	) or content -- 1128
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1128
		return content -- 1131
	end -- 1131
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1133
	local reasons = {} -- 1136
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1136
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1137
	end -- 1137
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1137
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1138
	end -- 1138
	local hint = "Narrow the requested line range." -- 1139
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1140
end -- 1140
function sanitizeReadResultForHistory(tool, result) -- 1155
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1155
		return result -- 1157
	end -- 1157
	local clone = {} -- 1159
	for key in pairs(result) do -- 1160
		clone[key] = result[key] -- 1161
	end -- 1161
	clone.content = limitReadContentForHistory(result.content, tool) -- 1163
	return clone -- 1164
end -- 1164
function sanitizeSearchMatchesForHistory(items, maxItems) -- 1167
	local shown = math.min(#items, maxItems) -- 1171
	local out = {} -- 1172
	do -- 1172
		local i = 0 -- 1173
		while i < shown do -- 1173
			local row = items[i + 1] -- 1174
			out[#out + 1] = { -- 1175
				file = row.file, -- 1176
				line = row.line, -- 1177
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1178
			} -- 1178
			i = i + 1 -- 1173
		end -- 1173
	end -- 1173
	return out -- 1183
end -- 1183
function sanitizeSearchResultForHistory(tool, result) -- 1186
	if result.success ~= true or not isArray(result.results) then -- 1186
		return result -- 1190
	end -- 1190
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1190
		return result -- 1191
	end -- 1191
	local clone = {} -- 1192
	for key in pairs(result) do -- 1193
		clone[key] = result[key] -- 1194
	end -- 1194
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1196
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1197
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1197
		local grouped = result.groupedResults -- 1202
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1203
		local sanitizedGroups = {} -- 1204
		do -- 1204
			local i = 0 -- 1205
			while i < shown do -- 1205
				local row = grouped[i + 1] -- 1206
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1207
					file = row.file, -- 1208
					totalMatches = row.totalMatches, -- 1209
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1210
				} -- 1210
				i = i + 1 -- 1205
			end -- 1205
		end -- 1205
		clone.groupedResults = sanitizedGroups -- 1215
	end -- 1215
	return clone -- 1217
end -- 1217
function sanitizeListFilesResultForHistory(result) -- 1220
	if result.success ~= true or not isArray(result.files) then -- 1220
		return result -- 1221
	end -- 1221
	local clone = {} -- 1222
	for key in pairs(result) do -- 1223
		clone[key] = result[key] -- 1224
	end -- 1224
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1226
	return clone -- 1227
end -- 1227
function sanitizeBuildResultForHistory(result) -- 1230
	if not isArray(result.messages) then -- 1230
		return result -- 1231
	end -- 1231
	local clone = {} -- 1232
	for key in pairs(result) do -- 1233
		clone[key] = result[key] -- 1234
	end -- 1234
	local messages = result.messages -- 1236
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1237
	local sanitized = {} -- 1238
	do -- 1238
		local i = 0 -- 1239
		while i < shown do -- 1239
			local item = messages[i + 1] -- 1240
			local next = {} -- 1241
			for key in pairs(item) do -- 1242
				local value = item[key] -- 1243
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1244
			end -- 1244
			sanitized[#sanitized + 1] = next -- 1248
			i = i + 1 -- 1239
		end -- 1239
	end -- 1239
	clone.messages = sanitized -- 1250
	if #messages > shown then -- 1250
		clone.truncatedMessages = #messages - shown -- 1252
	end -- 1252
	return clone -- 1254
end -- 1254
function getDecisionToolDefinitions(shared) -- 1272
	local base = replacePromptVars( -- 1273
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1274
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1275
	) -- 1275
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1277
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1298
		getAllowedToolsForRole(shared.role), -- 1299
		", " -- 1299
	) or "" -- 1299
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1301
	if (shared and shared.decisionMode) ~= "xml" then -- 1301
		return withRole -- 1303
	end -- 1303
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1305
end -- 1305
function getFinishMessage(params, fallback) -- 1612
	if fallback == nil then -- 1612
		fallback = "" -- 1612
	end -- 1612
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1612
		return __TS__StringTrim(params.message) -- 1614
	end -- 1614
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1614
		return __TS__StringTrim(params.response) -- 1617
	end -- 1617
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1617
		return __TS__StringTrim(params.summary) -- 1620
	end -- 1620
	return __TS__StringTrim(fallback) -- 1622
end -- 1622
function persistHistoryState(shared) -- 1625
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1626
end -- 1626
function getActiveConversationMessages(shared) -- 1633
	local activeMessages = {} -- 1634
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1634
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1641
	end -- 1641
	do -- 1641
		local i = shared.lastConsolidatedIndex -- 1645
		while i < #shared.messages do -- 1645
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1646
			i = i + 1 -- 1645
		end -- 1645
	end -- 1645
	return activeMessages -- 1648
end -- 1648
function getActiveRealMessageCount(shared) -- 1651
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1652
end -- 1652
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1655
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1660
	local previousActiveStart = shared.lastConsolidatedIndex -- 1661
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1662
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1663
	if type(carryMessageIndex) == "number" then -- 1663
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1663
		else -- 1663
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1671
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1674
		end -- 1674
	else -- 1674
		shared.carryMessageIndex = nil -- 1679
	end -- 1679
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1679
		shared.carryMessageIndex = nil -- 1689
	end -- 1689
end -- 1689
function getDecisionPath(params) -- 1947
	if type(params.path) == "string" then -- 1947
		return __TS__StringTrim(params.path) -- 1948
	end -- 1948
	if type(params.target_file) == "string" then -- 1948
		return __TS__StringTrim(params.target_file) -- 1949
	end -- 1949
	return "" -- 1950
end -- 1950
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1953
	local num = __TS__Number(value) -- 1954
	if not __TS__NumberIsFinite(num) then -- 1954
		num = fallback -- 1955
	end -- 1955
	num = math.floor(num) -- 1956
	if num < minValue then -- 1956
		num = minValue -- 1957
	end -- 1957
	if maxValue ~= nil and num > maxValue then -- 1957
		num = maxValue -- 1958
	end -- 1958
	return num -- 1959
end -- 1959
function parseReadLineParam(value, fallback, paramName) -- 1962
	local num = __TS__Number(value) -- 1967
	if not __TS__NumberIsFinite(num) then -- 1967
		num = fallback -- 1968
	end -- 1968
	num = math.floor(num) -- 1969
	if num == 0 then -- 1969
		return {success = false, message = paramName .. " cannot be 0"} -- 1971
	end -- 1971
	return {success = true, value = num} -- 1973
end -- 1973
function validateDecision(tool, params) -- 1976
	if tool == "finish" then -- 1976
		local message = getFinishMessage(params) -- 1981
		if message == "" then -- 1981
			return {success = false, message = "finish requires params.message"} -- 1982
		end -- 1982
		params.message = message -- 1983
		return {success = true, params = params} -- 1984
	end -- 1984
	if tool == "read_file" then -- 1984
		local path = getDecisionPath(params) -- 1988
		if path == "" then -- 1988
			return {success = false, message = "read_file requires path"} -- 1989
		end -- 1989
		params.path = path -- 1990
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1991
		if not startLineRes.success then -- 1991
			return startLineRes -- 1992
		end -- 1992
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1993
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1994
		if not endLineRes.success then -- 1994
			return endLineRes -- 1995
		end -- 1995
		params.startLine = startLineRes.value -- 1996
		params.endLine = endLineRes.value -- 1997
		return {success = true, params = params} -- 1998
	end -- 1998
	if tool == "edit_file" then -- 1998
		local path = getDecisionPath(params) -- 2002
		if path == "" then -- 2002
			return {success = false, message = "edit_file requires path"} -- 2003
		end -- 2003
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2004
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2005
		params.path = path -- 2006
		params.old_str = oldStr -- 2007
		params.new_str = newStr -- 2008
		return {success = true, params = params} -- 2009
	end -- 2009
	if tool == "delete_file" then -- 2009
		local targetFile = getDecisionPath(params) -- 2013
		if targetFile == "" then -- 2013
			return {success = false, message = "delete_file requires target_file"} -- 2014
		end -- 2014
		params.target_file = targetFile -- 2015
		return {success = true, params = params} -- 2016
	end -- 2016
	if tool == "grep_files" then -- 2016
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2020
		if pattern == "" then -- 2020
			return {success = false, message = "grep_files requires pattern"} -- 2021
		end -- 2021
		params.pattern = pattern -- 2022
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2023
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2024
		return {success = true, params = params} -- 2025
	end -- 2025
	if tool == "search_dora_api" then -- 2025
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2029
		if pattern == "" then -- 2029
			return {success = false, message = "search_dora_api requires pattern"} -- 2030
		end -- 2030
		params.pattern = pattern -- 2031
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2032
		return {success = true, params = params} -- 2033
	end -- 2033
	if tool == "glob_files" then -- 2033
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2037
		return {success = true, params = params} -- 2038
	end -- 2038
	if tool == "build" then -- 2038
		local path = getDecisionPath(params) -- 2042
		if path ~= "" then -- 2042
			params.path = path -- 2044
		end -- 2044
		return {success = true, params = params} -- 2046
	end -- 2046
	if tool == "list_sub_agents" then -- 2046
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2050
		if status ~= "" then -- 2050
			params.status = status -- 2052
		end -- 2052
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2054
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2055
		if type(params.query) == "string" then -- 2055
			params.query = __TS__StringTrim(params.query) -- 2057
		end -- 2057
		return {success = true, params = params} -- 2059
	end -- 2059
	if tool == "spawn_sub_agent" then -- 2059
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2063
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2064
		if prompt == "" then -- 2064
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2065
		end -- 2065
		if title == "" then -- 2065
			return {success = false, message = "spawn_sub_agent requires title"} -- 2066
		end -- 2066
		params.prompt = prompt -- 2067
		params.title = title -- 2068
		if type(params.expectedOutput) == "string" then -- 2068
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2070
		end -- 2070
		if isArray(params.filesHint) then -- 2070
			params.filesHint = __TS__ArrayMap( -- 2073
				__TS__ArrayFilter( -- 2073
					params.filesHint, -- 2073
					function(____, item) return type(item) == "string" end -- 2074
				), -- 2074
				function(____, item) return sanitizeUTF8(item) end -- 2075
			) -- 2075
		end -- 2075
		return {success = true, params = params} -- 2077
	end -- 2077
	return {success = true, params = params} -- 2080
end -- 2080
function getAllowedToolsForRole(role) -- 2106
	return role == "main" and ({ -- 2107
		"read_file", -- 2108
		"edit_file", -- 2108
		"delete_file", -- 2108
		"grep_files", -- 2108
		"search_dora_api", -- 2108
		"glob_files", -- 2108
		"build", -- 2108
		"list_sub_agents", -- 2108
		"spawn_sub_agent", -- 2108
		"finish" -- 2108
	}) or ({ -- 2108
		"read_file", -- 2109
		"edit_file", -- 2109
		"delete_file", -- 2109
		"grep_files", -- 2109
		"search_dora_api", -- 2109
		"glob_files", -- 2109
		"build", -- 2109
		"finish" -- 2109
	}) -- 2109
end -- 2109
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2215
	if includeToolDefinitions == nil then -- 2215
		includeToolDefinitions = false -- 2215
	end -- 2215
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2216
	local sections = { -- 2219
		shared.promptPack.agentIdentityPrompt, -- 2220
		rolePrompt, -- 2221
		getReplyLanguageDirective(shared) -- 2222
	} -- 2222
	if shared.decisionMode == "tool_calling" then -- 2222
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2225
	end -- 2225
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2227
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2228
	if memoryContext ~= "" then -- 2228
		sections[#sections + 1] = memoryContext -- 2230
	end -- 2230
	if includeToolDefinitions then -- 2230
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2233
		if shared.decisionMode == "xml" then -- 2233
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2235
		end -- 2235
	end -- 2235
	local skillsSection = buildSkillsSection(shared) -- 2239
	if skillsSection ~= "" then -- 2239
		sections[#sections + 1] = skillsSection -- 2241
	end -- 2241
	return table.concat(sections, "\n\n") -- 2243
end -- 2243
function buildSkillsSection(shared) -- 2246
	local ____opt_42 = shared.skills -- 2246
	if not (____opt_42 and ____opt_42.loader) then -- 2246
		return "" -- 2248
	end -- 2248
	return shared.skills.loader:buildSkillsPromptSection() -- 2250
end -- 2250
function buildXmlDecisionInstruction(shared, feedback) -- 2368
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2369
end -- 2369
function executeToolAction(shared, action) -- 3555
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3555
		if shared.stopToken.stopped then -- 3555
			return ____awaiter_resolve( -- 3555
				nil, -- 3555
				{ -- 3557
					success = false, -- 3557
					message = getCancelledReason(shared) -- 3557
				} -- 3557
			) -- 3557
		end -- 3557
		local params = action.params -- 3559
		if action.tool == "read_file" then -- 3559
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3561
			if __TS__StringTrim(path) == "" then -- 3561
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3561
			end -- 3561
			local ____Tools_readFile_104 = Tools.readFile -- 3565
			local ____shared_workingDir_102 = shared.workingDir -- 3566
			local ____params_startLine_100 = params.startLine -- 3568
			if ____params_startLine_100 == nil then -- 3568
				____params_startLine_100 = 1 -- 3568
			end -- 3568
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3568
			local ____params_endLine_101 = params.endLine -- 3569
			if ____params_endLine_101 == nil then -- 3569
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3569
			end -- 3569
			return ____awaiter_resolve( -- 3569
				nil, -- 3569
				____Tools_readFile_104( -- 3565
					____shared_workingDir_102, -- 3566
					path, -- 3567
					____TS__Number_result_103, -- 3568
					__TS__Number(____params_endLine_101), -- 3569
					shared.useChineseResponse and "zh" or "en" -- 3570
				) -- 3570
			) -- 3570
		end -- 3570
		if action.tool == "grep_files" then -- 3570
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3574
			local ____shared_workingDir_111 = shared.workingDir -- 3575
			local ____temp_112 = params.path or "" -- 3576
			local ____temp_113 = params.pattern or "" -- 3577
			local ____params_globs_114 = params.globs -- 3578
			local ____params_useRegex_115 = params.useRegex -- 3579
			local ____params_caseSensitive_116 = params.caseSensitive -- 3580
			local ____math_max_107 = math.max -- 3583
			local ____math_floor_106 = math.floor -- 3583
			local ____params_limit_105 = params.limit -- 3583
			if ____params_limit_105 == nil then -- 3583
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3583
			end -- 3583
			local ____math_max_107_result_117 = ____math_max_107( -- 3583
				1, -- 3583
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3583
			) -- 3583
			local ____math_max_110 = math.max -- 3584
			local ____math_floor_109 = math.floor -- 3584
			local ____params_offset_108 = params.offset -- 3584
			if ____params_offset_108 == nil then -- 3584
				____params_offset_108 = 0 -- 3584
			end -- 3584
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3574
				workDir = ____shared_workingDir_111, -- 3575
				path = ____temp_112, -- 3576
				pattern = ____temp_113, -- 3577
				globs = ____params_globs_114, -- 3578
				useRegex = ____params_useRegex_115, -- 3579
				caseSensitive = ____params_caseSensitive_116, -- 3580
				includeContent = true, -- 3581
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3582
				limit = ____math_max_107_result_117, -- 3583
				offset = ____math_max_110( -- 3584
					0, -- 3584
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3584
				), -- 3584
				groupByFile = params.groupByFile == true -- 3585
			})) -- 3585
			return ____awaiter_resolve(nil, result) -- 3585
		end -- 3585
		if action.tool == "search_dora_api" then -- 3585
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3590
			local ____temp_122 = params.pattern or "" -- 3591
			local ____temp_123 = params.docSource or "api" -- 3592
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3593
			local ____temp_125 = params.programmingLanguage or "ts" -- 3594
			local ____math_min_121 = math.min -- 3595
			local ____math_max_120 = math.max -- 3595
			local ____params_limit_119 = params.limit -- 3595
			if ____params_limit_119 == nil then -- 3595
				____params_limit_119 = 8 -- 3595
			end -- 3595
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3590
				pattern = ____temp_122, -- 3591
				docSource = ____temp_123, -- 3592
				docLanguage = ____temp_124, -- 3593
				programmingLanguage = ____temp_125, -- 3594
				limit = ____math_min_121( -- 3595
					SEARCH_DORA_API_LIMIT_MAX, -- 3595
					____math_max_120( -- 3595
						1, -- 3595
						__TS__Number(____params_limit_119) -- 3595
					) -- 3595
				), -- 3595
				useRegex = params.useRegex, -- 3596
				caseSensitive = false, -- 3597
				includeContent = true, -- 3598
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3599
			})) -- 3599
			return ____awaiter_resolve(nil, result) -- 3599
		end -- 3599
		if action.tool == "glob_files" then -- 3599
			local ____Tools_listFiles_133 = Tools.listFiles -- 3604
			local ____shared_workingDir_130 = shared.workingDir -- 3605
			local ____temp_131 = params.path or "" -- 3606
			local ____params_globs_132 = params.globs -- 3607
			local ____math_max_129 = math.max -- 3608
			local ____math_floor_128 = math.floor -- 3608
			local ____params_maxEntries_127 = params.maxEntries -- 3608
			if ____params_maxEntries_127 == nil then -- 3608
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3608
			end -- 3608
			local result = ____Tools_listFiles_133({ -- 3604
				workDir = ____shared_workingDir_130, -- 3605
				path = ____temp_131, -- 3606
				globs = ____params_globs_132, -- 3607
				maxEntries = ____math_max_129( -- 3608
					1, -- 3608
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3608
				) -- 3608
			}) -- 3608
			return ____awaiter_resolve(nil, result) -- 3608
		end -- 3608
		if action.tool == "delete_file" then -- 3608
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3613
			if __TS__StringTrim(targetFile) == "" then -- 3613
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3613
			end -- 3613
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3617
			if not result.success then -- 3617
				return ____awaiter_resolve(nil, result) -- 3617
			end -- 3617
			return ____awaiter_resolve(nil, { -- 3617
				success = true, -- 3625
				changed = true, -- 3626
				mode = "delete", -- 3627
				checkpointId = result.checkpointId, -- 3628
				checkpointSeq = result.checkpointSeq, -- 3629
				files = {{path = targetFile, op = "delete"}} -- 3630
			}) -- 3630
		end -- 3630
		if action.tool == "build" then -- 3630
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3634
			return ____awaiter_resolve(nil, result) -- 3634
		end -- 3634
		if action.tool == "spawn_sub_agent" then -- 3634
			if not shared.spawnSubAgent then -- 3634
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3634
			end -- 3634
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3634
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3634
			end -- 3634
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3647
				params.filesHint, -- 3648
				function(____, item) return type(item) == "string" end -- 3648
			) or nil -- 3648
			local result = __TS__Await(shared.spawnSubAgent({ -- 3650
				parentSessionId = shared.sessionId, -- 3651
				projectRoot = shared.workingDir, -- 3652
				title = type(params.title) == "string" and params.title or "Sub", -- 3653
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3654
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3655
				filesHint = filesHint -- 3656
			})) -- 3656
			if not result.success then -- 3656
				return ____awaiter_resolve(nil, result) -- 3656
			end -- 3656
			return ____awaiter_resolve(nil, { -- 3656
				success = true, -- 3662
				sessionId = result.sessionId, -- 3663
				taskId = result.taskId, -- 3664
				title = result.title, -- 3665
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3666
			}) -- 3666
		end -- 3666
		if action.tool == "list_sub_agents" then -- 3666
			if not shared.listSubAgents then -- 3666
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3666
			end -- 3666
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3666
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3666
			end -- 3666
			local result = __TS__Await(shared.listSubAgents({ -- 3676
				sessionId = shared.sessionId, -- 3677
				projectRoot = shared.workingDir, -- 3678
				status = type(params.status) == "string" and params.status or nil, -- 3679
				limit = type(params.limit) == "number" and params.limit or nil, -- 3680
				offset = type(params.offset) == "number" and params.offset or nil, -- 3681
				query = type(params.query) == "string" and params.query or nil -- 3682
			})) -- 3682
			return ____awaiter_resolve(nil, result) -- 3682
		end -- 3682
		if action.tool == "edit_file" then -- 3682
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3687
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3690
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3691
			if __TS__StringTrim(path) == "" then -- 3691
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3691
			end -- 3691
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3693
			return ____awaiter_resolve( -- 3693
				nil, -- 3693
				actionNode:exec({ -- 3694
					path = path, -- 3695
					oldStr = oldStr, -- 3696
					newStr = newStr, -- 3697
					taskId = shared.taskId, -- 3698
					workDir = shared.workingDir -- 3699
				}) -- 3699
			) -- 3699
		end -- 3699
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3699
	end) -- 3699
end -- 3699
function sanitizeToolActionResultForHistory(action, result) -- 3705
	if action.tool == "read_file" then -- 3705
		return sanitizeReadResultForHistory(action.tool, result) -- 3707
	end -- 3707
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3707
		return sanitizeSearchResultForHistory(action.tool, result) -- 3710
	end -- 3710
	if action.tool == "glob_files" then -- 3710
		return sanitizeListFilesResultForHistory(result) -- 3713
	end -- 3713
	if action.tool == "build" then -- 3713
		return sanitizeBuildResultForHistory(result) -- 3716
	end -- 3716
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3716
		if result.success ~= true then -- 3716
			return result -- 3719
		end -- 3719
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3719
			return result -- 3720
		end -- 3720
		if isArray(result.fileContext) then -- 3720
			return result -- 3721
		end -- 3721
		local contextLimits = { -- 3723
			fullContentChars = 12000, -- 3724
			previewChars = 4000, -- 3725
			diffChars = 8000, -- 3726
			totalChars = 24000, -- 3727
			maxFiles = 8 -- 3728
		} -- 3728
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3730
			if maxChars <= 0 then -- 3730
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3731
			end -- 3731
			if #sourceText <= maxChars then -- 3731
				return sourceText -- 3732
			end -- 3732
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3733
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3734
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3735
		end -- 3730
		local function countLines(sourceText) -- 3737
			if sourceText == "" then -- 3737
				return 0 -- 3738
			end -- 3738
			return #__TS__StringSplit(sourceText, "\n") -- 3739
		end -- 3737
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3741
			if beforeContent == afterContent then -- 3741
				return "" -- 3742
			end -- 3742
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3743
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3744
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3746
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3746
				firstChangedLine = firstChangedLine + 1 -- 3752
			end -- 3752
			local lastChangedBeforeLine = #beforeLines - 1 -- 3754
			local lastChangedAfterLine = #afterLines - 1 -- 3755
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3755
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3761
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3762
			end -- 3762
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3764
			local previewEndLine = math.max( -- 3765
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3766
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3767
			) -- 3767
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3769
			do -- 3769
				local lineIndex = previewStartLine -- 3770
				while lineIndex <= previewEndLine do -- 3770
					do -- 3770
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3771
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3772
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3773
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3774
						if not beforeChanged and not afterChanged then -- 3774
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3776
							if contextLine ~= nil then -- 3776
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3777
							end -- 3777
							goto __continue577 -- 3778
						end -- 3778
						if beforeChanged and beforeLine ~= nil then -- 3778
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3780
						end -- 3780
						if afterChanged and afterLine ~= nil then -- 3780
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3781
						end -- 3781
					end -- 3781
					::__continue577:: -- 3781
					lineIndex = lineIndex + 1 -- 3770
				end -- 3770
			end -- 3770
			return truncateContextSnippet( -- 3783
				table.concat(unifiedDiffLines, "\n"), -- 3783
				maxChars, -- 3783
				"diff" -- 3783
			) -- 3783
		end -- 3741
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3786
		if not checkpointDiff.success then -- 3786
			return result -- 3787
		end -- 3787
		local remainingContextBudget = contextLimits.totalChars -- 3788
		local fileContextItems = {} -- 3789
		local changedFiles = checkpointDiff.files -- 3790
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3791
		do -- 3791
			local fileIndex = 0 -- 3792
			while fileIndex < maxContextFiles do -- 3792
				if remainingContextBudget <= 0 then -- 3792
					break -- 3793
				end -- 3793
				local changedFile = changedFiles[fileIndex + 1] -- 3794
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3795
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3796
				local contextItem = { -- 3797
					path = changedFile.path, -- 3798
					op = changedFile.op, -- 3799
					checkpointId = result.checkpointId, -- 3800
					checkpointSeq = result.checkpointSeq, -- 3801
					beforeExists = changedFile.beforeExists, -- 3802
					afterExists = changedFile.afterExists, -- 3803
					beforeBytes = #beforeContent, -- 3804
					afterBytes = #afterContent, -- 3805
					diffPreview = "", -- 3806
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3807
					contentTruncated = false, -- 3808
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3809
				} -- 3809
				if changedFile.afterExists then -- 3809
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3809
						contextItem.afterContent = afterContent -- 3813
						remainingContextBudget = remainingContextBudget - #afterContent -- 3814
					else -- 3814
						contextItem.afterContentPreview = truncateContextSnippet( -- 3816
							afterContent, -- 3817
							math.min( -- 3818
								contextLimits.previewChars, -- 3818
								math.max(400, remainingContextBudget) -- 3818
							), -- 3818
							"afterContent" -- 3819
						) -- 3819
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3821
						contextItem.contentTruncated = true -- 3822
					end -- 3822
				end -- 3822
				local diffPreview = buildUnifiedDiffPreview( -- 3825
					changedFile.path, -- 3826
					beforeContent, -- 3827
					afterContent, -- 3828
					math.min( -- 3829
						contextLimits.diffChars, -- 3829
						math.max(400, remainingContextBudget) -- 3829
					) -- 3829
				) -- 3829
				contextItem.diffPreview = diffPreview -- 3831
				remainingContextBudget = remainingContextBudget - #diffPreview -- 3832
				if not changedFile.afterExists and beforeContent ~= "" then -- 3832
					contextItem.beforeContentPreview = truncateContextSnippet( -- 3834
						beforeContent, -- 3835
						math.min( -- 3836
							contextLimits.previewChars, -- 3836
							math.max(400, remainingContextBudget) -- 3836
						), -- 3836
						"beforeContent" -- 3837
					) -- 3837
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 3839
					if #beforeContent > contextLimits.previewChars then -- 3839
						contextItem.contentTruncated = true -- 3840
					end -- 3840
				end -- 3840
				fileContextItems[#fileContextItems + 1] = contextItem -- 3842
				fileIndex = fileIndex + 1 -- 3792
			end -- 3792
		end -- 3792
		if #fileContextItems == 0 then -- 3792
			return result -- 3844
		end -- 3844
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 3845
	end -- 3845
	return result -- 3852
end -- 3852
function emitAgentTaskFinishEvent(shared, success, message) -- 4019
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 4020
	emitAgentEvent(shared, { -- 4026
		type = "task_finished", -- 4027
		sessionId = shared.sessionId, -- 4028
		taskId = shared.taskId, -- 4029
		success = result.success, -- 4030
		message = result.message, -- 4031
		steps = result.steps -- 4032
	}) -- 4032
	return result -- 4034
end -- 4034
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
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 789
	local messagesTokens = 0 -- 796
	do -- 796
		local i = 0 -- 797
		while i < #messages do -- 797
			local message = messages[i + 1] -- 798
			messagesTokens = messagesTokens + 8 -- 799
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 800
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 801
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 802
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 803
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 804
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 805
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 806
			i = i + 1 -- 797
		end -- 797
	end -- 797
	local toolDefinitionsTokens = 0 -- 809
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 809
		local toolsText = safeJsonEncode(options.tools) -- 811
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 812
	end -- 812
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 815
	__TS__Delete(optionsWithoutTools, "tools") -- 816
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 817
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 818
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 819
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 820
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 825
		1024, -- 827
		math.floor(contextWindow * 0.2) -- 827
	) -- 827
	local structuralOverhead = math.max(256, #messages * 16) -- 828
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 830
	local maxTokens = contextWindow -- 831
	emitAgentEvent( -- 832
		shared, -- 832
		{ -- 832
			type = "metrics_updated", -- 833
			sessionId = shared.sessionId, -- 834
			taskId = shared.taskId, -- 835
			step = step, -- 836
			metrics = {context = { -- 837
				usedTokens = usedTokens, -- 839
				maxTokens = maxTokens, -- 840
				ratio = math.max( -- 841
					0, -- 841
					math.min(1, usedTokens / maxTokens) -- 841
				), -- 841
				messagesTokens = messagesTokens, -- 842
				optionsTokens = optionsTokens, -- 843
				toolDefinitionsTokens = toolDefinitionsTokens, -- 844
				reservedOutputTokens = reservedOutputTokens, -- 845
				structuralOverhead = structuralOverhead, -- 846
				contextWindow = contextWindow, -- 847
				source = "llm_input_estimate", -- 848
				updatedAt = os.time(), -- 849
				phase = phase, -- 850
				step = step -- 851
			}} -- 851
		} -- 851
	) -- 851
end -- 789
local function emitAgentStartEvent(shared, action) -- 857
	emitAgentEvent(shared, { -- 858
		type = "tool_started", -- 859
		sessionId = shared.sessionId, -- 860
		taskId = shared.taskId, -- 861
		step = action.step, -- 862
		tool = action.tool -- 863
	}) -- 863
end -- 857
local function emitAgentFinishEvent(shared, action) -- 867
	emitAgentEvent(shared, { -- 868
		type = "tool_finished", -- 869
		sessionId = shared.sessionId, -- 870
		taskId = shared.taskId, -- 871
		step = action.step, -- 872
		tool = action.tool, -- 873
		result = action.result or ({}) -- 874
	}) -- 874
end -- 867
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 878
	emitAgentEvent(shared, { -- 879
		type = "assistant_message_updated", -- 880
		sessionId = shared.sessionId, -- 881
		taskId = shared.taskId, -- 882
		step = shared.step + 1, -- 883
		content = content, -- 884
		reasoningContent = reasoningContent -- 885
	}) -- 885
end -- 878
local function getMemoryCompressionStartReason(shared) -- 889
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 890
end -- 889
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 895
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 896
end -- 895
local function getMemoryCompressionFailureReason(shared, ____error) -- 901
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 902
end -- 901
local function summarizeHistoryEntryPreview(text, maxChars) -- 907
	if maxChars == nil then -- 907
		maxChars = 180 -- 907
	end -- 907
	local trimmed = __TS__StringTrim(text) -- 908
	if trimmed == "" then -- 908
		return "" -- 909
	end -- 909
	return truncateText(trimmed, maxChars) -- 910
end -- 907
local function getMaxStepsReachedReason(shared) -- 918
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 919
end -- 918
local function getFailureSummaryFallback(shared, ____error) -- 924
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 925
end -- 924
local function finalizeAgentFailure(shared, ____error) -- 930
	if shared.stopToken.stopped then -- 930
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 932
		return emitAgentTaskFinishEvent( -- 933
			shared, -- 933
			false, -- 933
			getCancelledReason(shared) -- 933
		) -- 933
	end -- 933
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 935
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 936
end -- 930
local function getPromptCommand(prompt) -- 939
	local trimmed = __TS__StringTrim(prompt) -- 940
	if trimmed == "/compact" then -- 940
		return "compact" -- 941
	end -- 941
	if trimmed == "/clear" then -- 941
		return "clear" -- 942
	end -- 942
	return nil -- 943
end -- 939
function ____exports.truncateAgentUserPrompt(prompt) -- 946
	if not prompt then -- 946
		return "" -- 947
	end -- 947
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 947
		return prompt -- 948
	end -- 948
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 949
	if offset == nil then -- 949
		return prompt -- 950
	end -- 950
	return string.sub(prompt, 1, offset - 1) -- 951
end -- 946
local function canWriteStepLLMDebug(shared, stepId) -- 954
	if stepId == nil then -- 954
		stepId = shared.step + 1 -- 954
	end -- 954
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 955
end -- 954
local function ensureDirRecursive(dir) -- 962
	if not dir then -- 962
		return false -- 963
	end -- 963
	if Content:exist(dir) then -- 963
		return Content:isdir(dir) -- 964
	end -- 964
	local parent = Path:getPath(dir) -- 965
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 965
		return false -- 967
	end -- 967
	return Content:mkdir(dir) -- 969
end -- 962
local function encodeDebugJSON(value) -- 972
	local text, err = safeJsonEncode(value) -- 973
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 974
end -- 972
local function getStepLLMDebugDir(shared) -- 977
	return Path( -- 978
		shared.workingDir, -- 979
		".agent", -- 980
		tostring(shared.sessionId), -- 981
		tostring(shared.taskId) -- 982
	) -- 982
end -- 977
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 986
	return Path( -- 987
		getStepLLMDebugDir(shared), -- 987
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 987
	) -- 987
end -- 986
local function getLatestStepLLMDebugSeq(shared, stepId) -- 990
	if not canWriteStepLLMDebug(shared, stepId) then -- 990
		return 0 -- 991
	end -- 991
	local dir = getStepLLMDebugDir(shared) -- 992
	if not Content:exist(dir) or not Content:isdir(dir) then -- 992
		return 0 -- 993
	end -- 993
	local latest = 0 -- 994
	for ____, file in ipairs(Content:getFiles(dir)) do -- 995
		do -- 995
			local name = Path:getFilename(file) -- 996
			local seqText = string.match( -- 997
				name, -- 997
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 997
			) -- 997
			if seqText ~= nil then -- 997
				latest = math.max( -- 999
					latest, -- 999
					tonumber(seqText) -- 999
				) -- 999
				goto __continue128 -- 1000
			end -- 1000
			local legacyMatch = string.match( -- 1002
				name, -- 1002
				("^" .. tostring(stepId)) .. "_in%.md$" -- 1002
			) -- 1002
			if legacyMatch ~= nil then -- 1002
				latest = math.max(latest, 1) -- 1004
			end -- 1004
		end -- 1004
		::__continue128:: -- 1004
	end -- 1004
	return latest -- 1007
end -- 990
local function writeStepLLMDebugFile(path, content) -- 1010
	if not Content:save(path, content) then -- 1010
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 1012
		return false -- 1013
	end -- 1013
	return true -- 1015
end -- 1010
local function createStepLLMDebugPair(shared, stepId, inContent) -- 1018
	if not canWriteStepLLMDebug(shared, stepId) then -- 1018
		return 0 -- 1019
	end -- 1019
	local dir = getStepLLMDebugDir(shared) -- 1020
	if not ensureDirRecursive(dir) then -- 1020
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1022
		return 0 -- 1023
	end -- 1023
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 1025
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 1026
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 1027
	if not writeStepLLMDebugFile(inPath, inContent) then -- 1027
		return 0 -- 1029
	end -- 1029
	writeStepLLMDebugFile(outPath, "") -- 1031
	return seq -- 1032
end -- 1018
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 1035
	if not canWriteStepLLMDebug(shared, stepId) then -- 1035
		return -- 1036
	end -- 1036
	local dir = getStepLLMDebugDir(shared) -- 1037
	if not ensureDirRecursive(dir) then -- 1037
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1039
		return -- 1040
	end -- 1040
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 1042
	if latestSeq <= 0 then -- 1042
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 1044
		writeStepLLMDebugFile(outPath, content) -- 1045
		return -- 1046
	end -- 1046
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 1048
	writeStepLLMDebugFile(outPath, content) -- 1049
end -- 1035
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 1052
	if not canWriteStepLLMDebug(shared, stepId) then -- 1052
		return -- 1053
	end -- 1053
	local sections = { -- 1054
		"# LLM Input", -- 1055
		"session_id: " .. tostring(shared.sessionId), -- 1056
		"task_id: " .. tostring(shared.taskId), -- 1057
		"step_id: " .. tostring(stepId), -- 1058
		"phase: " .. phase, -- 1059
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1060
		"## Options", -- 1061
		"```json", -- 1062
		encodeDebugJSON(options), -- 1063
		"```" -- 1064
	} -- 1064
	do -- 1064
		local i = 0 -- 1066
		while i < #messages do -- 1066
			local message = messages[i + 1] -- 1067
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 1068
			sections[#sections + 1] = encodeDebugJSON(message) -- 1069
			i = i + 1 -- 1066
		end -- 1066
	end -- 1066
	createStepLLMDebugPair( -- 1071
		shared, -- 1071
		stepId, -- 1071
		table.concat(sections, "\n") -- 1071
	) -- 1071
end -- 1052
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 1074
	if not canWriteStepLLMDebug(shared, stepId) then -- 1074
		return -- 1075
	end -- 1075
	local ____array_2 = __TS__SparseArrayNew( -- 1075
		"# LLM Output", -- 1077
		"session_id: " .. tostring(shared.sessionId), -- 1078
		"task_id: " .. tostring(shared.taskId), -- 1079
		"step_id: " .. tostring(stepId), -- 1080
		"phase: " .. phase, -- 1081
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1082
		table.unpack(meta and ({ -- 1083
			"## Meta", -- 1083
			"```json", -- 1083
			encodeDebugJSON(meta), -- 1083
			"```" -- 1083
		}) or ({})) -- 1083
	) -- 1083
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 1083
	local sections = {__TS__SparseArraySpread(____array_2)} -- 1076
	updateLatestStepLLMDebugOutput( -- 1087
		shared, -- 1087
		stepId, -- 1087
		table.concat(sections, "\n") -- 1087
	) -- 1087
end -- 1074
local function toJson(value) -- 1090
	local text, err = safeJsonEncode(value) -- 1091
	if text ~= nil then -- 1091
		return text -- 1092
	end -- 1092
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 1093
end -- 1090
local function summarizeEditTextParamForHistory(value, key) -- 1143
	if type(value) ~= "string" then -- 1143
		return nil -- 1144
	end -- 1144
	local text = value -- 1145
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1146
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1147
end -- 1143
local function sanitizeActionParamsForHistory(tool, params) -- 1257
	if tool ~= "edit_file" then -- 1257
		return params -- 1258
	end -- 1258
	local clone = {} -- 1259
	for key in pairs(params) do -- 1260
		if key == "old_str" then -- 1260
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1262
		elseif key == "new_str" then -- 1262
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1264
		else -- 1264
			clone[key] = params[key] -- 1266
		end -- 1266
	end -- 1266
	return clone -- 1269
end -- 1257
local function isToolAllowedForRole(role, tool) -- 1314
	return __TS__ArrayIndexOf( -- 1315
		getAllowedToolsForRole(role), -- 1315
		tool -- 1315
	) >= 0 -- 1315
end -- 1314
local PRE_EXEC_SAFE_TOOLS = { -- 1318
	"read_file", -- 1319
	"grep_files", -- 1320
	"search_dora_api", -- 1321
	"glob_files", -- 1322
	"list_sub_agents" -- 1323
} -- 1323
local function canPreExecuteTool(tool) -- 1326
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1327
end -- 1326
local function clearPreExecutedResults(shared) -- 1330
	shared.preExecutedResults = nil -- 1331
end -- 1330
local function getToolActionSignature(action) -- 1334
	return (action.tool .. ":") .. toJson(action.params) -- 1335
end -- 1334
local function startPreExecutedToolAction(shared, action) -- 1338
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1338
		local ____try = __TS__AsyncAwaiter(function() -- 1338
			return ____awaiter_resolve( -- 1338
				nil, -- 1338
				__TS__Await(executeToolAction(shared, action)) -- 1340
			) -- 1340
		end) -- 1340
		__TS__Await(____try.catch( -- 1339
			____try, -- 1339
			function(____, err) -- 1339
				local message = tostring(err) -- 1342
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1343
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1343
			end -- 1343
		)) -- 1343
	end) -- 1343
end -- 1338
local function executeToolActionWithPreExecution(shared, action) -- 1348
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1348
		local ____opt_9 = shared.preExecutedResults -- 1348
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1349
		if preResult then -- 1349
			local ____opt_11 = shared.preExecutedResults -- 1349
			if ____opt_11 ~= nil then -- 1349
				____opt_11:delete(action.toolCallId) -- 1351
			end -- 1351
			local signature = getToolActionSignature(action) -- 1352
			if preResult.signature == signature then -- 1352
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1354
				return ____awaiter_resolve( -- 1354
					nil, -- 1354
					__TS__Await(preResult.promise) -- 1355
				) -- 1355
			end -- 1355
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1357
		end -- 1357
		return ____awaiter_resolve( -- 1357
			nil, -- 1357
			executeToolAction(shared, action) -- 1359
		) -- 1359
	end) -- 1359
end -- 1348
local function maybeCompressHistory(shared) -- 1362
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1362
		local ____shared_13 = shared -- 1363
		local memory = ____shared_13.memory -- 1363
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1364
		local changed = false -- 1365
		do -- 1365
			local round = 0 -- 1366
			while round < maxRounds do -- 1366
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1367
				local activeMessages = getActiveConversationMessages(shared) -- 1368
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1372
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1372
					if changed then -- 1372
						persistHistoryState(shared) -- 1381
					end -- 1381
					return ____awaiter_resolve(nil) -- 1381
				end -- 1381
				local compressionRound = round + 1 -- 1385
				shared.step = shared.step + 1 -- 1386
				local stepId = shared.step -- 1387
				local pendingMessages = #activeMessages -- 1388
				emitAgentEvent( -- 1389
					shared, -- 1389
					{ -- 1389
						type = "memory_compression_started", -- 1390
						sessionId = shared.sessionId, -- 1391
						taskId = shared.taskId, -- 1392
						step = stepId, -- 1393
						tool = "compress_memory", -- 1394
						reason = getMemoryCompressionStartReason(shared), -- 1395
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1396
					} -- 1396
				) -- 1396
				local result = __TS__Await(memory.compressor:compress( -- 1402
					activeMessages, -- 1403
					shared.llmOptions, -- 1404
					shared.llmMaxTry, -- 1405
					shared.decisionMode, -- 1406
					{ -- 1407
						onInput = function(____, phase, messages, options) -- 1408
							saveStepLLMDebugInput( -- 1409
								shared, -- 1409
								stepId, -- 1409
								phase, -- 1409
								messages, -- 1409
								options -- 1409
							) -- 1409
						end, -- 1408
						onOutput = function(____, phase, text, meta) -- 1411
							saveStepLLMDebugOutput( -- 1412
								shared, -- 1412
								stepId, -- 1412
								phase, -- 1412
								text, -- 1412
								meta -- 1412
							) -- 1412
						end -- 1411
					}, -- 1411
					"default", -- 1415
					systemPrompt, -- 1416
					toolDefinitions -- 1417
				)) -- 1417
				if not (result and result.success and result.compressedCount > 0) then -- 1417
					emitAgentEvent( -- 1420
						shared, -- 1420
						{ -- 1420
							type = "memory_compression_finished", -- 1421
							sessionId = shared.sessionId, -- 1422
							taskId = shared.taskId, -- 1423
							step = stepId, -- 1424
							tool = "compress_memory", -- 1425
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1426
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1430
						} -- 1430
					) -- 1430
					if changed then -- 1430
						persistHistoryState(shared) -- 1438
					end -- 1438
					return ____awaiter_resolve(nil) -- 1438
				end -- 1438
				local effectiveCompressedCount = math.max( -- 1442
					0, -- 1443
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1444
				) -- 1444
				if effectiveCompressedCount <= 0 then -- 1444
					if changed then -- 1444
						persistHistoryState(shared) -- 1448
					end -- 1448
					return ____awaiter_resolve(nil) -- 1448
				end -- 1448
				emitAgentEvent( -- 1452
					shared, -- 1452
					{ -- 1452
						type = "memory_compression_finished", -- 1453
						sessionId = shared.sessionId, -- 1454
						taskId = shared.taskId, -- 1455
						step = stepId, -- 1456
						tool = "compress_memory", -- 1457
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1458
						result = { -- 1459
							success = true, -- 1460
							round = compressionRound, -- 1461
							compressedCount = effectiveCompressedCount, -- 1462
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1463
						} -- 1463
					} -- 1463
				) -- 1463
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1466
				changed = true -- 1467
				Log( -- 1468
					"Info", -- 1468
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1468
				) -- 1468
				round = round + 1 -- 1366
			end -- 1366
		end -- 1366
		if changed then -- 1366
			persistHistoryState(shared) -- 1471
		end -- 1471
	end) -- 1471
end -- 1362
local function compactAllHistory(shared) -- 1475
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1475
		local ____shared_20 = shared -- 1476
		local memory = ____shared_20.memory -- 1476
		local rounds = 0 -- 1477
		local totalCompressed = 0 -- 1478
		while getActiveRealMessageCount(shared) > 0 do -- 1478
			if shared.stopToken.stopped then -- 1478
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1481
				return ____awaiter_resolve( -- 1481
					nil, -- 1481
					emitAgentTaskFinishEvent( -- 1482
						shared, -- 1482
						false, -- 1482
						getCancelledReason(shared) -- 1482
					) -- 1482
				) -- 1482
			end -- 1482
			rounds = rounds + 1 -- 1484
			shared.step = shared.step + 1 -- 1485
			local stepId = shared.step -- 1486
			local activeMessages = getActiveConversationMessages(shared) -- 1487
			local pendingMessages = #activeMessages -- 1488
			emitAgentEvent( -- 1489
				shared, -- 1489
				{ -- 1489
					type = "memory_compression_started", -- 1490
					sessionId = shared.sessionId, -- 1491
					taskId = shared.taskId, -- 1492
					step = stepId, -- 1493
					tool = "compress_memory", -- 1494
					reason = getMemoryCompressionStartReason(shared), -- 1495
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1496
				} -- 1496
			) -- 1496
			local result = __TS__Await(memory.compressor:compress( -- 1503
				activeMessages, -- 1504
				shared.llmOptions, -- 1505
				shared.llmMaxTry, -- 1506
				shared.decisionMode, -- 1507
				{ -- 1508
					onInput = function(____, phase, messages, options) -- 1509
						saveStepLLMDebugInput( -- 1510
							shared, -- 1510
							stepId, -- 1510
							phase, -- 1510
							messages, -- 1510
							options -- 1510
						) -- 1510
					end, -- 1509
					onOutput = function(____, phase, text, meta) -- 1512
						saveStepLLMDebugOutput( -- 1513
							shared, -- 1513
							stepId, -- 1513
							phase, -- 1513
							text, -- 1513
							meta -- 1513
						) -- 1513
					end -- 1512
				}, -- 1512
				"budget_max" -- 1516
			)) -- 1516
			if not (result and result.success and result.compressedCount > 0) then -- 1516
				emitAgentEvent( -- 1519
					shared, -- 1519
					{ -- 1519
						type = "memory_compression_finished", -- 1520
						sessionId = shared.sessionId, -- 1521
						taskId = shared.taskId, -- 1522
						step = stepId, -- 1523
						tool = "compress_memory", -- 1524
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1525
						result = { -- 1529
							success = false, -- 1530
							rounds = rounds, -- 1531
							error = result and result.error or "compression returned no changes", -- 1532
							compressedCount = result and result.compressedCount or 0, -- 1533
							fullCompaction = true -- 1534
						} -- 1534
					} -- 1534
				) -- 1534
				return ____awaiter_resolve( -- 1534
					nil, -- 1534
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1537
				) -- 1537
			end -- 1537
			local effectiveCompressedCount = math.max( -- 1542
				0, -- 1543
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1544
			) -- 1544
			if effectiveCompressedCount <= 0 then -- 1544
				return ____awaiter_resolve( -- 1544
					nil, -- 1544
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1547
				) -- 1547
			end -- 1547
			emitAgentEvent( -- 1554
				shared, -- 1554
				{ -- 1554
					type = "memory_compression_finished", -- 1555
					sessionId = shared.sessionId, -- 1556
					taskId = shared.taskId, -- 1557
					step = stepId, -- 1558
					tool = "compress_memory", -- 1559
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1560
					result = { -- 1561
						success = true, -- 1562
						round = rounds, -- 1563
						compressedCount = effectiveCompressedCount, -- 1564
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1565
						fullCompaction = true -- 1566
					} -- 1566
				} -- 1566
			) -- 1566
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1569
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1570
			persistHistoryState(shared) -- 1571
			Log( -- 1572
				"Info", -- 1572
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1572
			) -- 1572
		end -- 1572
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1574
		return ____awaiter_resolve( -- 1574
			nil, -- 1574
			emitAgentTaskFinishEvent( -- 1575
				shared, -- 1576
				true, -- 1577
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1578
			) -- 1578
		) -- 1578
	end) -- 1578
end -- 1475
local function clearSessionHistory(shared) -- 1584
	shared.messages = {} -- 1585
	shared.lastConsolidatedIndex = 0 -- 1586
	shared.carryMessageIndex = nil -- 1587
	persistHistoryState(shared) -- 1588
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1589
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1590
end -- 1584
local function isKnownToolName(name) -- 1599
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1600
end -- 1599
local function appendConversationMessage(shared, message) -- 1693
	local ____shared_messages_29 = shared.messages -- 1693
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1694
		{}, -- 1694
		message, -- 1695
		{ -- 1694
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1696
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1697
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1698
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1699
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1700
		} -- 1700
	) -- 1700
end -- 1693
local function ensureToolCallId(toolCallId) -- 1704
	if toolCallId and toolCallId ~= "" then -- 1704
		return toolCallId -- 1705
	end -- 1705
	return createLocalToolCallId() -- 1706
end -- 1704
local function appendToolResultMessage(shared, action) -- 1709
	appendConversationMessage( -- 1710
		shared, -- 1710
		{ -- 1710
			role = "tool", -- 1711
			tool_call_id = action.toolCallId, -- 1712
			name = action.tool, -- 1713
			content = action.result and toJson(action.result) or "" -- 1714
		} -- 1714
	) -- 1714
end -- 1709
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1718
	appendConversationMessage( -- 1724
		shared, -- 1724
		{ -- 1724
			role = "assistant", -- 1725
			content = content or "", -- 1726
			reasoning_content = reasoningContent, -- 1727
			tool_calls = __TS__ArrayMap( -- 1728
				actions, -- 1728
				function(____, action) return { -- 1728
					id = action.toolCallId, -- 1729
					type = "function", -- 1730
					["function"] = { -- 1731
						name = action.tool, -- 1732
						arguments = toJson(action.params) -- 1733
					} -- 1733
				} end -- 1733
			) -- 1733
		} -- 1733
	) -- 1733
end -- 1718
local function parseXMLToolCallObjectFromText(text) -- 1739
	local children = parseXMLObjectFromText(text, "tool_call") -- 1740
	if not children.success then -- 1740
		return children -- 1741
	end -- 1741
	local rawObj = children.obj -- 1742
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1743
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1744
	if not params.success then -- 1744
		return {success = false, message = params.message} -- 1748
	end -- 1748
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1750
end -- 1739
local function llm(shared, messages, phase) -- 1770
	if phase == nil then -- 1770
		phase = "decision_xml" -- 1773
	end -- 1773
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1773
		local stepId = shared.step + 1 -- 1775
		emitLLMContextMetrics( -- 1776
			shared, -- 1776
			stepId, -- 1776
			phase, -- 1776
			messages, -- 1776
			shared.llmOptions -- 1776
		) -- 1776
		saveStepLLMDebugInput( -- 1777
			shared, -- 1777
			stepId, -- 1777
			phase, -- 1777
			messages, -- 1777
			shared.llmOptions -- 1777
		) -- 1777
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1778
		if res.success then -- 1778
			local ____opt_32 = res.response.choices -- 1778
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1778
			local message = ____opt_30 and ____opt_30.message -- 1780
			local text = message and message.content -- 1781
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1782
			if text then -- 1782
				saveStepLLMDebugOutput( -- 1786
					shared, -- 1786
					stepId, -- 1786
					phase, -- 1786
					text, -- 1786
					{success = true} -- 1786
				) -- 1786
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1786
			else -- 1786
				saveStepLLMDebugOutput( -- 1789
					shared, -- 1789
					stepId, -- 1789
					phase, -- 1789
					"empty LLM response", -- 1789
					{success = false} -- 1789
				) -- 1789
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1789
			end -- 1789
		else -- 1789
			saveStepLLMDebugOutput( -- 1793
				shared, -- 1793
				stepId, -- 1793
				phase, -- 1793
				res.raw or res.message, -- 1793
				{success = false} -- 1793
			) -- 1793
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1793
		end -- 1793
	end) -- 1793
end -- 1770
local function isDecisionBatchSuccess(result) -- 1817
	return result.kind == "batch" -- 1818
end -- 1817
local function parseDecisionObject(rawObj) -- 1821
	if type(rawObj.tool) ~= "string" then -- 1821
		return {success = false, message = "missing tool"} -- 1822
	end -- 1822
	local tool = rawObj.tool -- 1823
	if not isKnownToolName(tool) then -- 1823
		return {success = false, message = "unknown tool: " .. tool} -- 1825
	end -- 1825
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1827
	if tool ~= "finish" and (not reason or reason == "") then -- 1827
		return {success = false, message = tool .. " requires top-level reason"} -- 1831
	end -- 1831
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1833
	return {success = true, tool = tool, params = params, reason = reason} -- 1834
end -- 1821
local function parseDecisionToolCall(functionName, rawObj) -- 1842
	if not isKnownToolName(functionName) then -- 1842
		return {success = false, message = "unknown tool: " .. functionName} -- 1844
	end -- 1844
	if rawObj == nil or rawObj == nil then -- 1844
		return {success = true, tool = functionName, params = {}} -- 1847
	end -- 1847
	if not isRecord(rawObj) then -- 1847
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1850
	end -- 1850
	return {success = true, tool = functionName, params = rawObj} -- 1852
end -- 1842
local function parseToolCallArguments(functionName, argsText) -- 1859
	local trimmedArgs = __TS__StringTrim(argsText) -- 1860
	if trimmedArgs == "" then -- 1860
		return {} -- 1862
	end -- 1862
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1864
	if err ~= nil or rawObj == nil then -- 1864
		return { -- 1866
			success = false, -- 1867
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1868
			raw = argsText -- 1869
		} -- 1869
	end -- 1869
	local encodedRaw = safeJsonEncode(rawObj) -- 1872
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1872
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1874
	end -- 1874
	return rawObj -- 1880
end -- 1859
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1883
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1891
	if isRecord(rawArgs) and rawArgs.success == false then -- 1891
		return rawArgs -- 1893
	end -- 1893
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1895
	if not decision.success then -- 1895
		return {success = false, message = decision.message, raw = argsText} -- 1897
	end -- 1897
	local validation = validateDecision(decision.tool, decision.params) -- 1903
	if not validation.success then -- 1903
		return {success = false, message = validation.message, raw = argsText} -- 1905
	end -- 1905
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1905
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1912
	end -- 1912
	decision.params = validation.params -- 1918
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1919
	decision.reason = reason -- 1920
	decision.reasoningContent = reasoningContent -- 1921
	return decision -- 1922
end -- 1883
local function createPreExecutableActionFromStream(shared, toolCall) -- 1925
	local ____opt_38 = toolCall["function"] -- 1925
	local functionName = ____opt_38 and ____opt_38.name -- 1926
	local ____opt_40 = toolCall["function"] -- 1926
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1927
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1928
	if not functionName or not toolCallId then -- 1928
		return nil -- 1929
	end -- 1929
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1930
	if isRecord(rawArgs) and rawArgs.success == false then -- 1930
		return nil -- 1931
	end -- 1931
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1932
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1932
		return nil -- 1933
	end -- 1933
	local validation = validateDecision(decision.tool, decision.params) -- 1934
	if not validation.success then -- 1934
		return nil -- 1935
	end -- 1935
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1935
		return nil -- 1936
	end -- 1936
	return { -- 1937
		step = shared.step + 1, -- 1938
		toolCallId = toolCallId, -- 1939
		tool = decision.tool, -- 1940
		reason = "", -- 1941
		params = validation.params, -- 1942
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1943
	} -- 1943
end -- 1925
local function createFunctionToolSchema(name, description, properties, required) -- 2083
	if required == nil then -- 2083
		required = {} -- 2087
	end -- 2087
	local parameters = {type = "object", properties = properties} -- 2089
	if #required > 0 then -- 2089
		parameters.required = required -- 2094
	end -- 2094
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2096
end -- 2083
local function buildDecisionToolSchema(shared) -- 2112
	local allowed = getAllowedToolsForRole(shared.role) -- 2113
	local tools = { -- 2114
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2115
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2125
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2135
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2143
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2147
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2148
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2149
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2150
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2151
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2152
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2153
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2154
		}, {"pattern"}), -- 2154
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2158
		createFunctionToolSchema( -- 2167
			"search_dora_api", -- 2168
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2168
			{ -- 2170
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2171
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2172
				programmingLanguage = {type = "string", enum = { -- 2173
					"ts", -- 2175
					"tsx", -- 2175
					"lua", -- 2175
					"yue", -- 2175
					"teal", -- 2175
					"tl", -- 2175
					"wa" -- 2175
				}, description = "Preferred language variant to search."}, -- 2175
				limit = { -- 2178
					type = "number", -- 2178
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2178
				}, -- 2178
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2179
			}, -- 2179
			{"pattern"} -- 2181
		), -- 2181
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2183
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2190
			"active_or_recent", -- 2194
			"running", -- 2194
			"done", -- 2194
			"failed", -- 2194
			"all" -- 2194
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2194
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2200
	} -- 2200
	return __TS__ArrayFilter( -- 2212
		tools, -- 2212
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2212
	) -- 2212
end -- 2112
local function sanitizeMessagesForLLMInput(messages) -- 2253
	local sanitized = {} -- 2254
	local droppedAssistantToolCalls = 0 -- 2255
	local droppedToolResults = 0 -- 2256
	do -- 2256
		local i = 0 -- 2257
		while i < #messages do -- 2257
			do -- 2257
				local message = messages[i + 1] -- 2258
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2258
					local requiredIds = {} -- 2260
					do -- 2260
						local j = 0 -- 2261
						while j < #message.tool_calls do -- 2261
							local toolCall = message.tool_calls[j + 1] -- 2262
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2263
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2263
								requiredIds[#requiredIds + 1] = id -- 2265
							end -- 2265
							j = j + 1 -- 2261
						end -- 2261
					end -- 2261
					if #requiredIds == 0 then -- 2261
						sanitized[#sanitized + 1] = message -- 2269
						goto __continue341 -- 2270
					end -- 2270
					local matchedIds = {} -- 2272
					local matchedTools = {} -- 2273
					local j = i + 1 -- 2274
					while j < #messages do -- 2274
						local toolMessage = messages[j + 1] -- 2276
						if toolMessage.role ~= "tool" then -- 2276
							break -- 2277
						end -- 2277
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2278
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2278
							matchedIds[toolCallId] = true -- 2280
							matchedTools[#matchedTools + 1] = toolMessage -- 2281
						else -- 2281
							droppedToolResults = droppedToolResults + 1 -- 2283
						end -- 2283
						j = j + 1 -- 2285
					end -- 2285
					local complete = true -- 2287
					do -- 2287
						local j = 0 -- 2288
						while j < #requiredIds do -- 2288
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2288
								complete = false -- 2290
								break -- 2291
							end -- 2291
							j = j + 1 -- 2288
						end -- 2288
					end -- 2288
					if complete then -- 2288
						__TS__ArrayPush( -- 2295
							sanitized, -- 2295
							message, -- 2295
							table.unpack(matchedTools) -- 2295
						) -- 2295
					else -- 2295
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2297
						droppedToolResults = droppedToolResults + #matchedTools -- 2298
					end -- 2298
					i = j - 1 -- 2300
					goto __continue341 -- 2301
				end -- 2301
				if message.role == "tool" then -- 2301
					droppedToolResults = droppedToolResults + 1 -- 2304
					goto __continue341 -- 2305
				end -- 2305
				sanitized[#sanitized + 1] = message -- 2307
			end -- 2307
			::__continue341:: -- 2307
			i = i + 1 -- 2257
		end -- 2257
	end -- 2257
	return sanitized -- 2309
end -- 2253
local function getUnconsolidatedMessages(shared) -- 2312
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2313
end -- 2312
local function getFinalDecisionTurnPrompt(shared) -- 2316
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2317
end -- 2316
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2322
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2322
		return messages -- 2323
	end -- 2323
	local next = __TS__ArrayMap( -- 2324
		messages, -- 2324
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2324
	) -- 2324
	do -- 2324
		local i = #next - 1 -- 2325
		while i >= 0 do -- 2325
			do -- 2325
				local message = next[i + 1] -- 2326
				if message.role ~= "assistant" and message.role ~= "user" then -- 2326
					goto __continue363 -- 2327
				end -- 2327
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2328
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2329
				return next -- 2332
			end -- 2332
			::__continue363:: -- 2332
			i = i - 1 -- 2325
		end -- 2325
	end -- 2325
	next[#next + 1] = {role = "user", content = prompt} -- 2334
	return next -- 2335
end -- 2322
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2338
	if attempt == nil then -- 2338
		attempt = 1 -- 2341
	end -- 2341
	if decisionMode == nil then -- 2341
		decisionMode = shared.decisionMode -- 2343
	end -- 2343
	local messages = { -- 2345
		{ -- 2346
			role = "system", -- 2346
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2346
		}, -- 2346
		table.unpack(getUnconsolidatedMessages(shared)) -- 2347
	} -- 2347
	if shared.step + 1 >= shared.maxSteps then -- 2347
		messages = appendPromptToLatestDecisionMessage( -- 2350
			messages, -- 2350
			getFinalDecisionTurnPrompt(shared) -- 2350
		) -- 2350
	end -- 2350
	if lastError and lastError ~= "" then -- 2350
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2353
		messages[#messages + 1] = { -- 2356
			role = "user", -- 2357
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2358
		} -- 2358
	end -- 2358
	return messages -- 2365
end -- 2338
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2372
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2379
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2380
	local repairPrompt = replacePromptVars( -- 2388
		shared.promptPack.xmlDecisionRepairPrompt, -- 2388
		{ -- 2388
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2389
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2390
			CANDIDATE_SECTION = candidateSection, -- 2391
			LAST_ERROR = lastError, -- 2392
			ATTEMPT = tostring(attempt) -- 2393
		} -- 2393
	) -- 2393
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2395
end -- 2372
local function tryParseAndValidateDecision(rawText) -- 2407
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2408
	if not parsed.success then -- 2408
		return {success = false, message = parsed.message, raw = rawText} -- 2410
	end -- 2410
	local decision = parseDecisionObject(parsed.obj) -- 2412
	if not decision.success then -- 2412
		return {success = false, message = decision.message, raw = rawText} -- 2414
	end -- 2414
	local validation = validateDecision(decision.tool, decision.params) -- 2416
	if not validation.success then -- 2416
		return {success = false, message = validation.message, raw = rawText} -- 2418
	end -- 2418
	decision.params = validation.params -- 2420
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2421
	return decision -- 2422
end -- 2407
local function normalizeLineEndings(text) -- 2425
	local res = string.gsub(text, "\r\n", "\n") -- 2426
	res = string.gsub(res, "\r", "\n") -- 2427
	return res -- 2428
end -- 2425
local function countOccurrences(text, searchStr) -- 2431
	if searchStr == "" then -- 2431
		return 0 -- 2432
	end -- 2432
	local count = 0 -- 2433
	local pos = 0 -- 2434
	while true do -- 2434
		local idx = (string.find( -- 2436
			text, -- 2436
			searchStr, -- 2436
			math.max(pos + 1, 1), -- 2436
			true -- 2436
		) or 0) - 1 -- 2436
		if idx < 0 then -- 2436
			break -- 2437
		end -- 2437
		count = count + 1 -- 2438
		pos = idx + #searchStr -- 2439
	end -- 2439
	return count -- 2441
end -- 2431
local function replaceFirst(text, oldStr, newStr) -- 2444
	if oldStr == "" then -- 2444
		return text -- 2445
	end -- 2445
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2446
	if idx < 0 then -- 2446
		return text -- 2447
	end -- 2447
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2448
end -- 2444
local function splitLines(text) -- 2451
	return __TS__StringSplit(text, "\n") -- 2452
end -- 2451
local function getLeadingWhitespace(text) -- 2455
	local i = 0 -- 2456
	while i < #text do -- 2456
		local ch = __TS__StringAccess(text, i) -- 2458
		if ch ~= " " and ch ~= "\t" then -- 2458
			break -- 2459
		end -- 2459
		i = i + 1 -- 2460
	end -- 2460
	return __TS__StringSubstring(text, 0, i) -- 2462
end -- 2455
local function getCommonIndentPrefix(lines) -- 2465
	local common -- 2466
	do -- 2466
		local i = 0 -- 2467
		while i < #lines do -- 2467
			do -- 2467
				local line = lines[i + 1] -- 2468
				if __TS__StringTrim(line) == "" then -- 2468
					goto __continue388 -- 2469
				end -- 2469
				local indent = getLeadingWhitespace(line) -- 2470
				if common == nil then -- 2470
					common = indent -- 2472
					goto __continue388 -- 2473
				end -- 2473
				local j = 0 -- 2475
				local maxLen = math.min(#common, #indent) -- 2476
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2476
					j = j + 1 -- 2478
				end -- 2478
				common = __TS__StringSubstring(common, 0, j) -- 2480
				if common == "" then -- 2480
					break -- 2481
				end -- 2481
			end -- 2481
			::__continue388:: -- 2481
			i = i + 1 -- 2467
		end -- 2467
	end -- 2467
	return common or "" -- 2483
end -- 2465
local function removeIndentPrefix(line, indent) -- 2486
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2486
		return __TS__StringSubstring(line, #indent) -- 2488
	end -- 2488
	local lineIndent = getLeadingWhitespace(line) -- 2490
	local j = 0 -- 2491
	local maxLen = math.min(#lineIndent, #indent) -- 2492
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2492
		j = j + 1 -- 2494
	end -- 2494
	return __TS__StringSubstring(line, j) -- 2496
end -- 2486
local function dedentLines(lines) -- 2499
	local indent = getCommonIndentPrefix(lines) -- 2500
	return { -- 2501
		indent = indent, -- 2502
		lines = __TS__ArrayMap( -- 2503
			lines, -- 2503
			function(____, line) return removeIndentPrefix(line, indent) end -- 2503
		) -- 2503
	} -- 2503
end -- 2499
local function joinLines(lines) -- 2507
	return table.concat(lines, "\n") -- 2508
end -- 2507
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2511
	local contentLines = splitLines(content) -- 2516
	local oldLines = splitLines(oldStr) -- 2517
	if #oldLines == 0 then -- 2517
		return {success = false, message = "old_str not found in file"} -- 2519
	end -- 2519
	local dedentedOld = dedentLines(oldLines) -- 2521
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2522
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2523
	local matches = {} -- 2524
	do -- 2524
		local start = 0 -- 2525
		while start <= #contentLines - #oldLines do -- 2525
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2526
			local dedentedCandidate = dedentLines(candidateLines) -- 2527
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2527
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2529
			end -- 2529
			start = start + 1 -- 2525
		end -- 2525
	end -- 2525
	if #matches == 0 then -- 2525
		return {success = false, message = "old_str not found in file"} -- 2537
	end -- 2537
	if #matches > 1 then -- 2537
		return { -- 2540
			success = false, -- 2541
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2542
		} -- 2542
	end -- 2542
	local match = matches[1] -- 2545
	local rebuiltNewLines = __TS__ArrayMap( -- 2546
		dedentedNew.lines, -- 2546
		function(____, line) return line == "" and "" or match.indent .. line end -- 2546
	) -- 2546
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2546
	__TS__SparseArrayPush( -- 2546
		____array_46, -- 2546
		table.unpack(rebuiltNewLines) -- 2549
	) -- 2549
	__TS__SparseArrayPush( -- 2549
		____array_46, -- 2549
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2550
	) -- 2550
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2547
	return { -- 2552
		success = true, -- 2552
		content = joinLines(nextLines) -- 2552
	} -- 2552
end -- 2511
local MainDecisionAgent = __TS__Class() -- 2555
MainDecisionAgent.name = "MainDecisionAgent" -- 2555
__TS__ClassExtends(MainDecisionAgent, Node) -- 2555
function MainDecisionAgent.prototype.prep(self, shared) -- 2556
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2556
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2556
			return ____awaiter_resolve(nil, {shared = shared}) -- 2556
		end -- 2556
		__TS__Await(maybeCompressHistory(shared)) -- 2561
		return ____awaiter_resolve(nil, {shared = shared}) -- 2561
	end) -- 2561
end -- 2556
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2566
	if attempt == nil then -- 2566
		attempt = 1 -- 2569
	end -- 2569
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2569
		if shared.stopToken.stopped then -- 2569
			return ____awaiter_resolve( -- 2569
				nil, -- 2569
				{ -- 2573
					success = false, -- 2573
					message = getCancelledReason(shared) -- 2573
				} -- 2573
			) -- 2573
		end -- 2573
		Log( -- 2575
			"Info", -- 2575
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2575
		) -- 2575
		local tools = buildDecisionToolSchema(shared) -- 2576
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2577
		local stepId = shared.step + 1 -- 2578
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2579
		emitLLMContextMetrics( -- 2583
			shared, -- 2583
			stepId, -- 2583
			"decision_tool_calling", -- 2583
			messages, -- 2583
			llmOptions -- 2583
		) -- 2583
		saveStepLLMDebugInput( -- 2584
			shared, -- 2584
			stepId, -- 2584
			"decision_tool_calling", -- 2584
			messages, -- 2584
			llmOptions -- 2584
		) -- 2584
		local lastStreamContent = "" -- 2585
		local lastStreamReasoning = "" -- 2586
		local preExecutedResults = __TS__New(Map) -- 2587
		shared.preExecutedResults = preExecutedResults -- 2588
		local res = __TS__Await(callLLMStreamAggregated( -- 2589
			messages, -- 2590
			llmOptions, -- 2591
			shared.stopToken, -- 2592
			shared.llmConfig, -- 2593
			function(response) -- 2594
				local ____opt_49 = response.choices -- 2594
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2594
				local streamMessage = ____opt_47 and ____opt_47.message -- 2595
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2596
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2599
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2599
					return -- 2603
				end -- 2603
				lastStreamContent = nextContent -- 2605
				lastStreamReasoning = nextReasoning -- 2606
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2607
			end, -- 2594
			function(tc) -- 2609
				if shared.stopToken.stopped then -- 2609
					return -- 2610
				end -- 2610
				local action = createPreExecutableActionFromStream(shared, tc) -- 2611
				if not action or preExecutedResults:has(action.toolCallId) then -- 2611
					return -- 2612
				end -- 2612
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2613
				preExecutedResults:set( -- 2614
					action.toolCallId, -- 2614
					{ -- 2614
						signature = getToolActionSignature(action), -- 2615
						promise = startPreExecutedToolAction(shared, action) -- 2616
					} -- 2616
				) -- 2616
			end -- 2609
		)) -- 2609
		if shared.stopToken.stopped then -- 2609
			clearPreExecutedResults(shared) -- 2621
			return ____awaiter_resolve( -- 2621
				nil, -- 2621
				{ -- 2622
					success = false, -- 2622
					message = getCancelledReason(shared) -- 2622
				} -- 2622
			) -- 2622
		end -- 2622
		if not res.success then -- 2622
			saveStepLLMDebugOutput( -- 2625
				shared, -- 2625
				stepId, -- 2625
				"decision_tool_calling", -- 2625
				res.raw or res.message, -- 2625
				{success = false} -- 2625
			) -- 2625
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2626
			clearPreExecutedResults(shared) -- 2627
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2627
		end -- 2627
		saveStepLLMDebugOutput( -- 2630
			shared, -- 2630
			stepId, -- 2630
			"decision_tool_calling", -- 2630
			encodeDebugJSON(res.response), -- 2630
			{success = true} -- 2630
		) -- 2630
		local choice = res.response.choices and res.response.choices[1] -- 2631
		local message = choice and choice.message -- 2632
		local toolCalls = message and message.tool_calls -- 2633
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2634
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2637
		Log( -- 2640
			"Info", -- 2640
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2640
		) -- 2640
		if not toolCalls or #toolCalls == 0 then -- 2640
			if messageContent and messageContent ~= "" then -- 2640
				Log( -- 2643
					"Info", -- 2643
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2643
				) -- 2643
				clearPreExecutedResults(shared) -- 2644
				return ____awaiter_resolve(nil, { -- 2644
					success = true, -- 2646
					tool = "finish", -- 2647
					params = {}, -- 2648
					reason = messageContent, -- 2649
					reasoningContent = reasoningContent, -- 2650
					directSummary = messageContent -- 2651
				}) -- 2651
			end -- 2651
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2654
			clearPreExecutedResults(shared) -- 2655
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2655
		end -- 2655
		local decisions = {} -- 2662
		do -- 2662
			local i = 0 -- 2663
			while i < #toolCalls do -- 2663
				local toolCall = toolCalls[i + 1] -- 2664
				local fn = toolCall and toolCall["function"] -- 2665
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2665
					Log( -- 2667
						"Error", -- 2667
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2667
					) -- 2667
					clearPreExecutedResults(shared) -- 2668
					return ____awaiter_resolve( -- 2668
						nil, -- 2668
						{ -- 2669
							success = false, -- 2670
							message = "missing function name for tool call " .. tostring(i + 1), -- 2671
							raw = messageContent -- 2672
						} -- 2672
					) -- 2672
				end -- 2672
				local functionName = fn.name -- 2675
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2676
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2677
				Log( -- 2680
					"Info", -- 2680
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2680
				) -- 2680
				local decision = parseAndValidateToolCallDecision( -- 2681
					shared, -- 2682
					functionName, -- 2683
					argsText, -- 2684
					toolCallId, -- 2685
					messageContent, -- 2686
					reasoningContent -- 2687
				) -- 2687
				if not decision.success then -- 2687
					Log( -- 2690
						"Error", -- 2690
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2690
					) -- 2690
					clearPreExecutedResults(shared) -- 2691
					return ____awaiter_resolve(nil, decision) -- 2691
				end -- 2691
				decisions[#decisions + 1] = decision -- 2694
				i = i + 1 -- 2663
			end -- 2663
		end -- 2663
		if #decisions == 1 then -- 2663
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2697
			return ____awaiter_resolve(nil, decisions[1]) -- 2697
		end -- 2697
		do -- 2697
			local i = 0 -- 2700
			while i < #decisions do -- 2700
				if decisions[i + 1].tool == "finish" then -- 2700
					clearPreExecutedResults(shared) -- 2702
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2702
				end -- 2702
				i = i + 1 -- 2700
			end -- 2700
		end -- 2700
		Log( -- 2710
			"Info", -- 2710
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2710
				__TS__ArrayMap( -- 2710
					decisions, -- 2710
					function(____, decision) return decision.tool end -- 2710
				), -- 2710
				"," -- 2710
			) -- 2710
		) -- 2710
		return ____awaiter_resolve(nil, { -- 2710
			success = true, -- 2712
			kind = "batch", -- 2713
			decisions = decisions, -- 2714
			content = messageContent, -- 2715
			reasoningContent = reasoningContent -- 2716
		}) -- 2716
	end) -- 2716
end -- 2566
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2720
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2720
		Log( -- 2725
			"Info", -- 2725
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2725
		) -- 2725
		local lastError = initialError -- 2726
		local candidateRaw = "" -- 2727
		do -- 2727
			local attempt = 0 -- 2728
			while attempt < shared.llmMaxTry do -- 2728
				do -- 2728
					Log( -- 2729
						"Info", -- 2729
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2729
					) -- 2729
					local messages = buildXmlRepairMessages( -- 2730
						shared, -- 2731
						originalRaw, -- 2732
						candidateRaw, -- 2733
						lastError, -- 2734
						attempt + 1 -- 2735
					) -- 2735
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2737
					if shared.stopToken.stopped then -- 2737
						return ____awaiter_resolve( -- 2737
							nil, -- 2737
							{ -- 2739
								success = false, -- 2739
								message = getCancelledReason(shared) -- 2739
							} -- 2739
						) -- 2739
					end -- 2739
					if not llmRes.success then -- 2739
						lastError = llmRes.message -- 2742
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2743
						goto __continue431 -- 2744
					end -- 2744
					candidateRaw = llmRes.text -- 2746
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2747
					if decision.success then -- 2747
						decision.reasoningContent = llmRes.reasoningContent -- 2749
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2750
						return ____awaiter_resolve(nil, decision) -- 2750
					end -- 2750
					lastError = decision.message -- 2753
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2754
				end -- 2754
				::__continue431:: -- 2754
				attempt = attempt + 1 -- 2728
			end -- 2728
		end -- 2728
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2756
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2756
	end) -- 2756
end -- 2720
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2764
	if attempt == nil then -- 2764
		attempt = 1 -- 2767
	end -- 2767
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2767
		local messages = buildDecisionMessages( -- 2770
			shared, -- 2771
			lastError, -- 2772
			attempt, -- 2773
			lastRaw, -- 2774
			"xml" -- 2775
		) -- 2775
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2777
		if shared.stopToken.stopped then -- 2777
			return ____awaiter_resolve( -- 2777
				nil, -- 2777
				{ -- 2779
					success = false, -- 2779
					message = getCancelledReason(shared) -- 2779
				} -- 2779
			) -- 2779
		end -- 2779
		if not llmRes.success then -- 2779
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2779
		end -- 2779
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2788
		if decision.success then -- 2788
			decision.reasoningContent = llmRes.reasoningContent -- 2790
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2790
				return ____awaiter_resolve( -- 2790
					nil, -- 2790
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2792
				) -- 2792
			end -- 2792
			return ____awaiter_resolve(nil, decision) -- 2792
		end -- 2792
		return ____awaiter_resolve( -- 2792
			nil, -- 2792
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2800
		) -- 2800
	end) -- 2800
end -- 2764
function MainDecisionAgent.prototype.exec(self, input) -- 2803
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2803
		local shared = input.shared -- 2804
		if shared.stopToken.stopped then -- 2804
			return ____awaiter_resolve( -- 2804
				nil, -- 2804
				{ -- 2806
					success = false, -- 2806
					message = getCancelledReason(shared) -- 2806
				} -- 2806
			) -- 2806
		end -- 2806
		if shared.step >= shared.maxSteps then -- 2806
			Log( -- 2809
				"Warn", -- 2809
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2809
			) -- 2809
			return ____awaiter_resolve( -- 2809
				nil, -- 2809
				{ -- 2810
					success = false, -- 2810
					message = getMaxStepsReachedReason(shared) -- 2810
				} -- 2810
			) -- 2810
		end -- 2810
		if shared.decisionMode == "tool_calling" then -- 2810
			Log( -- 2814
				"Info", -- 2814
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2814
			) -- 2814
			local lastError = "tool calling validation failed" -- 2815
			local lastRaw = "" -- 2816
			local shouldFallbackToXml = false -- 2817
			do -- 2817
				local attempt = 0 -- 2818
				while attempt < shared.llmMaxTry do -- 2818
					Log( -- 2819
						"Info", -- 2819
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2819
					) -- 2819
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2820
					if shared.stopToken.stopped then -- 2820
						return ____awaiter_resolve( -- 2820
							nil, -- 2820
							{ -- 2827
								success = false, -- 2827
								message = getCancelledReason(shared) -- 2827
							} -- 2827
						) -- 2827
					end -- 2827
					if decision.success then -- 2827
						return ____awaiter_resolve(nil, decision) -- 2827
					end -- 2827
					lastError = decision.message -- 2832
					lastRaw = decision.raw or "" -- 2833
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2834
					if lastError == "missing tool call" then -- 2834
						shouldFallbackToXml = true -- 2836
						break -- 2837
					end -- 2837
					attempt = attempt + 1 -- 2818
				end -- 2818
			end -- 2818
			if shouldFallbackToXml then -- 2818
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2841
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2842
				do -- 2842
					local attempt = 0 -- 2843
					while attempt < shared.llmMaxTry do -- 2843
						Log( -- 2844
							"Info", -- 2844
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2844
						) -- 2844
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2845
						if shared.stopToken.stopped then -- 2845
							return ____awaiter_resolve( -- 2845
								nil, -- 2845
								{ -- 2852
									success = false, -- 2852
									message = getCancelledReason(shared) -- 2852
								} -- 2852
							) -- 2852
						end -- 2852
						if decision.success then -- 2852
							return ____awaiter_resolve(nil, decision) -- 2852
						end -- 2852
						lastError = decision.message -- 2857
						lastRaw = decision.raw or "" -- 2858
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2859
						attempt = attempt + 1 -- 2843
					end -- 2843
				end -- 2843
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2861
				return ____awaiter_resolve( -- 2861
					nil, -- 2861
					{ -- 2862
						success = false, -- 2862
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2862
					} -- 2862
				) -- 2862
			end -- 2862
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2864
			return ____awaiter_resolve( -- 2864
				nil, -- 2864
				{ -- 2865
					success = false, -- 2865
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2865
				} -- 2865
			) -- 2865
		end -- 2865
		local lastError = "xml validation failed" -- 2868
		local lastRaw = "" -- 2869
		do -- 2869
			local attempt = 0 -- 2870
			while attempt < shared.llmMaxTry do -- 2870
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2871
				if shared.stopToken.stopped then -- 2871
					return ____awaiter_resolve( -- 2871
						nil, -- 2871
						{ -- 2880
							success = false, -- 2880
							message = getCancelledReason(shared) -- 2880
						} -- 2880
					) -- 2880
				end -- 2880
				if decision.success then -- 2880
					return ____awaiter_resolve(nil, decision) -- 2880
				end -- 2880
				lastError = decision.message -- 2885
				lastRaw = decision.raw or "" -- 2886
				attempt = attempt + 1 -- 2870
			end -- 2870
		end -- 2870
		return ____awaiter_resolve( -- 2870
			nil, -- 2870
			{ -- 2888
				success = false, -- 2888
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2888
			} -- 2888
		) -- 2888
	end) -- 2888
end -- 2803
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2891
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2891
		local result = execRes -- 2892
		if not result.success then -- 2892
			if shared.stopToken.stopped then -- 2892
				shared.error = getCancelledReason(shared) -- 2895
				shared.done = true -- 2896
				return ____awaiter_resolve(nil, "done") -- 2896
			end -- 2896
			shared.error = result.message -- 2899
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2900
			shared.done = true -- 2901
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2902
			persistHistoryState(shared) -- 2906
			return ____awaiter_resolve(nil, "done") -- 2906
		end -- 2906
		if isDecisionBatchSuccess(result) then -- 2906
			local startStep = shared.step -- 2910
			local actions = {} -- 2911
			do -- 2911
				local i = 0 -- 2912
				while i < #result.decisions do -- 2912
					local decision = result.decisions[i + 1] -- 2913
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2914
					local step = startStep + i + 1 -- 2915
					local ____temp_55 -- 2916
					if i == 0 then -- 2916
						____temp_55 = decision.reason -- 2916
					else -- 2916
						____temp_55 = "" -- 2916
					end -- 2916
					local actionReason = ____temp_55 -- 2916
					local ____temp_56 -- 2917
					if i == 0 then -- 2917
						____temp_56 = decision.reasoningContent -- 2917
					else -- 2917
						____temp_56 = nil -- 2917
					end -- 2917
					local actionReasoningContent = ____temp_56 -- 2917
					emitAgentEvent(shared, { -- 2918
						type = "decision_made", -- 2919
						sessionId = shared.sessionId, -- 2920
						taskId = shared.taskId, -- 2921
						step = step, -- 2922
						tool = decision.tool, -- 2923
						reason = actionReason, -- 2924
						reasoningContent = actionReasoningContent, -- 2925
						params = decision.params -- 2926
					}) -- 2926
					local action = { -- 2928
						step = step, -- 2929
						toolCallId = toolCallId, -- 2930
						tool = decision.tool, -- 2931
						reason = actionReason or "", -- 2932
						reasoningContent = actionReasoningContent, -- 2933
						params = decision.params, -- 2934
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2935
					} -- 2935
					local ____shared_history_57 = shared.history -- 2935
					____shared_history_57[#____shared_history_57 + 1] = action -- 2937
					actions[#actions + 1] = action -- 2938
					i = i + 1 -- 2912
				end -- 2912
			end -- 2912
			shared.step = startStep + #actions -- 2940
			shared.pendingToolActions = actions -- 2941
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2942
			persistHistoryState(shared) -- 2948
			return ____awaiter_resolve(nil, "batch_tools") -- 2948
		end -- 2948
		if result.directSummary and result.directSummary ~= "" then -- 2948
			shared.response = result.directSummary -- 2952
			shared.done = true -- 2953
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2954
			persistHistoryState(shared) -- 2959
			return ____awaiter_resolve(nil, "done") -- 2959
		end -- 2959
		if result.tool == "finish" then -- 2959
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2963
			shared.response = finalMessage -- 2964
			shared.done = true -- 2965
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2966
			persistHistoryState(shared) -- 2971
			return ____awaiter_resolve(nil, "done") -- 2971
		end -- 2971
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2974
		shared.step = shared.step + 1 -- 2975
		local step = shared.step -- 2976
		emitAgentEvent(shared, { -- 2977
			type = "decision_made", -- 2978
			sessionId = shared.sessionId, -- 2979
			taskId = shared.taskId, -- 2980
			step = step, -- 2981
			tool = result.tool, -- 2982
			reason = result.reason, -- 2983
			reasoningContent = result.reasoningContent, -- 2984
			params = result.params -- 2985
		}) -- 2985
		local ____shared_history_58 = shared.history -- 2985
		____shared_history_58[#____shared_history_58 + 1] = { -- 2987
			step = step, -- 2988
			toolCallId = toolCallId, -- 2989
			tool = result.tool, -- 2990
			reason = result.reason or "", -- 2991
			reasoningContent = result.reasoningContent, -- 2992
			params = result.params, -- 2993
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2994
		} -- 2994
		local action = shared.history[#shared.history] -- 2996
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2997
		if canPreExecuteTool(action.tool) then -- 2997
			shared.pendingToolActions = {action} -- 2999
			persistHistoryState(shared) -- 3000
			return ____awaiter_resolve(nil, "batch_tools") -- 3000
		end -- 3000
		clearPreExecutedResults(shared) -- 3003
		persistHistoryState(shared) -- 3004
		return ____awaiter_resolve(nil, result.tool) -- 3004
	end) -- 3004
end -- 2891
local ReadFileAction = __TS__Class() -- 3009
ReadFileAction.name = "ReadFileAction" -- 3009
__TS__ClassExtends(ReadFileAction, Node) -- 3009
function ReadFileAction.prototype.prep(self, shared) -- 3010
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3010
		local last = shared.history[#shared.history] -- 3011
		if not last then -- 3011
			error( -- 3012
				__TS__New(Error, "no history"), -- 3012
				0 -- 3012
			) -- 3012
		end -- 3012
		emitAgentStartEvent(shared, last) -- 3013
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3014
		if __TS__StringTrim(path) == "" then -- 3014
			error( -- 3017
				__TS__New(Error, "missing path"), -- 3017
				0 -- 3017
			) -- 3017
		end -- 3017
		local ____path_61 = path -- 3019
		local ____shared_workingDir_62 = shared.workingDir -- 3021
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 3022
		local ____last_params_startLine_59 = last.params.startLine -- 3023
		if ____last_params_startLine_59 == nil then -- 3023
			____last_params_startLine_59 = 1 -- 3023
		end -- 3023
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 3023
		local ____last_params_endLine_60 = last.params.endLine -- 3024
		if ____last_params_endLine_60 == nil then -- 3024
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 3024
		end -- 3024
		return ____awaiter_resolve( -- 3024
			nil, -- 3024
			{ -- 3018
				path = ____path_61, -- 3019
				tool = "read_file", -- 3020
				workDir = ____shared_workingDir_62, -- 3021
				docLanguage = ____temp_63, -- 3022
				startLine = ____TS__Number_result_64, -- 3023
				endLine = __TS__Number(____last_params_endLine_60) -- 3024
			} -- 3024
		) -- 3024
	end) -- 3024
end -- 3010
function ReadFileAction.prototype.exec(self, input) -- 3028
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3028
		return ____awaiter_resolve( -- 3028
			nil, -- 3028
			Tools.readFile( -- 3029
				input.workDir, -- 3030
				input.path, -- 3031
				__TS__Number(input.startLine or 1), -- 3032
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3033
				input.docLanguage -- 3034
			) -- 3034
		) -- 3034
	end) -- 3034
end -- 3028
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3038
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3038
		local result = execRes -- 3039
		local last = shared.history[#shared.history] -- 3040
		if last ~= nil then -- 3040
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3042
			appendToolResultMessage(shared, last) -- 3043
			emitAgentFinishEvent(shared, last) -- 3044
		end -- 3044
		persistHistoryState(shared) -- 3046
		__TS__Await(maybeCompressHistory(shared)) -- 3047
		persistHistoryState(shared) -- 3048
		return ____awaiter_resolve(nil, "main") -- 3048
	end) -- 3048
end -- 3038
local SearchFilesAction = __TS__Class() -- 3053
SearchFilesAction.name = "SearchFilesAction" -- 3053
__TS__ClassExtends(SearchFilesAction, Node) -- 3053
function SearchFilesAction.prototype.prep(self, shared) -- 3054
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3054
		local last = shared.history[#shared.history] -- 3055
		if not last then -- 3055
			error( -- 3056
				__TS__New(Error, "no history"), -- 3056
				0 -- 3056
			) -- 3056
		end -- 3056
		emitAgentStartEvent(shared, last) -- 3057
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3057
	end) -- 3057
end -- 3054
function SearchFilesAction.prototype.exec(self, input) -- 3061
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3061
		local params = input.params -- 3062
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 3063
		local ____input_workDir_71 = input.workDir -- 3064
		local ____temp_72 = params.path or "" -- 3065
		local ____temp_73 = params.pattern or "" -- 3066
		local ____params_globs_74 = params.globs -- 3067
		local ____params_useRegex_75 = params.useRegex -- 3068
		local ____params_caseSensitive_76 = params.caseSensitive -- 3069
		local ____math_max_67 = math.max -- 3072
		local ____math_floor_66 = math.floor -- 3072
		local ____params_limit_65 = params.limit -- 3072
		if ____params_limit_65 == nil then -- 3072
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 3072
		end -- 3072
		local ____math_max_67_result_77 = ____math_max_67( -- 3072
			1, -- 3072
			____math_floor_66(__TS__Number(____params_limit_65)) -- 3072
		) -- 3072
		local ____math_max_70 = math.max -- 3073
		local ____math_floor_69 = math.floor -- 3073
		local ____params_offset_68 = params.offset -- 3073
		if ____params_offset_68 == nil then -- 3073
			____params_offset_68 = 0 -- 3073
		end -- 3073
		local result = __TS__Await(____Tools_searchFiles_78({ -- 3063
			workDir = ____input_workDir_71, -- 3064
			path = ____temp_72, -- 3065
			pattern = ____temp_73, -- 3066
			globs = ____params_globs_74, -- 3067
			useRegex = ____params_useRegex_75, -- 3068
			caseSensitive = ____params_caseSensitive_76, -- 3069
			includeContent = true, -- 3070
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3071
			limit = ____math_max_67_result_77, -- 3072
			offset = ____math_max_70( -- 3073
				0, -- 3073
				____math_floor_69(__TS__Number(____params_offset_68)) -- 3073
			), -- 3073
			groupByFile = params.groupByFile == true -- 3074
		})) -- 3074
		return ____awaiter_resolve(nil, result) -- 3074
	end) -- 3074
end -- 3061
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3079
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3079
		local last = shared.history[#shared.history] -- 3080
		if last ~= nil then -- 3080
			local result = execRes -- 3082
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3083
			appendToolResultMessage(shared, last) -- 3084
			emitAgentFinishEvent(shared, last) -- 3085
		end -- 3085
		persistHistoryState(shared) -- 3087
		__TS__Await(maybeCompressHistory(shared)) -- 3088
		persistHistoryState(shared) -- 3089
		return ____awaiter_resolve(nil, "main") -- 3089
	end) -- 3089
end -- 3079
local SearchDoraAPIAction = __TS__Class() -- 3094
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3094
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3094
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3095
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3095
		local last = shared.history[#shared.history] -- 3096
		if not last then -- 3096
			error( -- 3097
				__TS__New(Error, "no history"), -- 3097
				0 -- 3097
			) -- 3097
		end -- 3097
		emitAgentStartEvent(shared, last) -- 3098
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3098
	end) -- 3098
end -- 3095
function SearchDoraAPIAction.prototype.exec(self, input) -- 3102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3102
		local params = input.params -- 3103
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 3104
		local ____temp_82 = params.pattern or "" -- 3105
		local ____temp_83 = params.docSource or "api" -- 3106
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 3107
		local ____temp_85 = params.programmingLanguage or "ts" -- 3108
		local ____math_min_81 = math.min -- 3109
		local ____math_max_80 = math.max -- 3109
		local ____params_limit_79 = params.limit -- 3109
		if ____params_limit_79 == nil then -- 3109
			____params_limit_79 = 8 -- 3109
		end -- 3109
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 3104
			pattern = ____temp_82, -- 3105
			docSource = ____temp_83, -- 3106
			docLanguage = ____temp_84, -- 3107
			programmingLanguage = ____temp_85, -- 3108
			limit = ____math_min_81( -- 3109
				SEARCH_DORA_API_LIMIT_MAX, -- 3109
				____math_max_80( -- 3109
					1, -- 3109
					__TS__Number(____params_limit_79) -- 3109
				) -- 3109
			), -- 3109
			useRegex = params.useRegex, -- 3110
			caseSensitive = false, -- 3111
			includeContent = true, -- 3112
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3113
		})) -- 3113
		return ____awaiter_resolve(nil, result) -- 3113
	end) -- 3113
end -- 3102
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3118
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3118
		local last = shared.history[#shared.history] -- 3119
		if last ~= nil then -- 3119
			local result = execRes -- 3121
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3122
			appendToolResultMessage(shared, last) -- 3123
			emitAgentFinishEvent(shared, last) -- 3124
		end -- 3124
		persistHistoryState(shared) -- 3126
		__TS__Await(maybeCompressHistory(shared)) -- 3127
		persistHistoryState(shared) -- 3128
		return ____awaiter_resolve(nil, "main") -- 3128
	end) -- 3128
end -- 3118
local ListFilesAction = __TS__Class() -- 3133
ListFilesAction.name = "ListFilesAction" -- 3133
__TS__ClassExtends(ListFilesAction, Node) -- 3133
function ListFilesAction.prototype.prep(self, shared) -- 3134
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3134
		local last = shared.history[#shared.history] -- 3135
		if not last then -- 3135
			error( -- 3136
				__TS__New(Error, "no history"), -- 3136
				0 -- 3136
			) -- 3136
		end -- 3136
		emitAgentStartEvent(shared, last) -- 3137
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3137
	end) -- 3137
end -- 3134
function ListFilesAction.prototype.exec(self, input) -- 3141
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3141
		local params = input.params -- 3142
		local ____Tools_listFiles_93 = Tools.listFiles -- 3143
		local ____input_workDir_90 = input.workDir -- 3144
		local ____temp_91 = params.path or "" -- 3145
		local ____params_globs_92 = params.globs -- 3146
		local ____math_max_89 = math.max -- 3147
		local ____math_floor_88 = math.floor -- 3147
		local ____params_maxEntries_87 = params.maxEntries -- 3147
		if ____params_maxEntries_87 == nil then -- 3147
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3147
		end -- 3147
		local result = ____Tools_listFiles_93({ -- 3143
			workDir = ____input_workDir_90, -- 3144
			path = ____temp_91, -- 3145
			globs = ____params_globs_92, -- 3146
			maxEntries = ____math_max_89( -- 3147
				1, -- 3147
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3147
			) -- 3147
		}) -- 3147
		return ____awaiter_resolve(nil, result) -- 3147
	end) -- 3147
end -- 3141
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3152
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3152
		local last = shared.history[#shared.history] -- 3153
		if last ~= nil then -- 3153
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3155
			appendToolResultMessage(shared, last) -- 3156
			emitAgentFinishEvent(shared, last) -- 3157
		end -- 3157
		persistHistoryState(shared) -- 3159
		__TS__Await(maybeCompressHistory(shared)) -- 3160
		persistHistoryState(shared) -- 3161
		return ____awaiter_resolve(nil, "main") -- 3161
	end) -- 3161
end -- 3152
local DeleteFileAction = __TS__Class() -- 3166
DeleteFileAction.name = "DeleteFileAction" -- 3166
__TS__ClassExtends(DeleteFileAction, Node) -- 3166
function DeleteFileAction.prototype.prep(self, shared) -- 3167
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3167
		local last = shared.history[#shared.history] -- 3168
		if not last then -- 3168
			error( -- 3169
				__TS__New(Error, "no history"), -- 3169
				0 -- 3169
			) -- 3169
		end -- 3169
		emitAgentStartEvent(shared, last) -- 3170
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3171
		if __TS__StringTrim(targetFile) == "" then -- 3171
			error( -- 3174
				__TS__New(Error, "missing target_file"), -- 3174
				0 -- 3174
			) -- 3174
		end -- 3174
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3174
	end) -- 3174
end -- 3167
function DeleteFileAction.prototype.exec(self, input) -- 3178
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3178
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3179
		if not result.success then -- 3179
			return ____awaiter_resolve(nil, result) -- 3179
		end -- 3179
		return ____awaiter_resolve(nil, { -- 3179
			success = true, -- 3187
			changed = true, -- 3188
			mode = "delete", -- 3189
			checkpointId = result.checkpointId, -- 3190
			checkpointSeq = result.checkpointSeq, -- 3191
			files = {{path = input.targetFile, op = "delete"}} -- 3192
		}) -- 3192
	end) -- 3192
end -- 3178
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3196
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3196
		local last = shared.history[#shared.history] -- 3197
		if last ~= nil then -- 3197
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3199
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3200
			appendToolResultMessage(shared, last) -- 3201
			emitAgentFinishEvent(shared, last) -- 3202
			local result = last.result -- 3203
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3203
				emitAgentEvent(shared, { -- 3208
					type = "checkpoint_created", -- 3209
					sessionId = shared.sessionId, -- 3210
					taskId = shared.taskId, -- 3211
					step = last.step, -- 3212
					tool = "delete_file", -- 3213
					checkpointId = result.checkpointId, -- 3214
					checkpointSeq = result.checkpointSeq, -- 3215
					files = result.files -- 3216
				}) -- 3216
			end -- 3216
		end -- 3216
		persistHistoryState(shared) -- 3220
		__TS__Await(maybeCompressHistory(shared)) -- 3221
		persistHistoryState(shared) -- 3222
		return ____awaiter_resolve(nil, "main") -- 3222
	end) -- 3222
end -- 3196
local BuildAction = __TS__Class() -- 3227
BuildAction.name = "BuildAction" -- 3227
__TS__ClassExtends(BuildAction, Node) -- 3227
function BuildAction.prototype.prep(self, shared) -- 3228
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3228
		local last = shared.history[#shared.history] -- 3229
		if not last then -- 3229
			error( -- 3230
				__TS__New(Error, "no history"), -- 3230
				0 -- 3230
			) -- 3230
		end -- 3230
		emitAgentStartEvent(shared, last) -- 3231
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3231
	end) -- 3231
end -- 3228
function BuildAction.prototype.exec(self, input) -- 3235
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3235
		local params = input.params -- 3236
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3237
		return ____awaiter_resolve(nil, result) -- 3237
	end) -- 3237
end -- 3235
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3244
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3244
		local last = shared.history[#shared.history] -- 3245
		if last ~= nil then -- 3245
			last.result = sanitizeBuildResultForHistory(execRes) -- 3247
			appendToolResultMessage(shared, last) -- 3248
			emitAgentFinishEvent(shared, last) -- 3249
		end -- 3249
		persistHistoryState(shared) -- 3251
		__TS__Await(maybeCompressHistory(shared)) -- 3252
		persistHistoryState(shared) -- 3253
		return ____awaiter_resolve(nil, "main") -- 3253
	end) -- 3253
end -- 3244
local SpawnSubAgentAction = __TS__Class() -- 3258
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3258
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3258
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3259
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3259
		local last = shared.history[#shared.history] -- 3268
		if not last then -- 3268
			error( -- 3269
				__TS__New(Error, "no history"), -- 3269
				0 -- 3269
			) -- 3269
		end -- 3269
		emitAgentStartEvent(shared, last) -- 3270
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3271
			last.params.filesHint, -- 3272
			function(____, item) return type(item) == "string" end -- 3272
		) or nil -- 3272
		return ____awaiter_resolve( -- 3272
			nil, -- 3272
			{ -- 3274
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3275
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3276
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3277
				filesHint = filesHint, -- 3278
				sessionId = shared.sessionId, -- 3279
				projectRoot = shared.workingDir, -- 3280
				spawnSubAgent = shared.spawnSubAgent -- 3281
			} -- 3281
		) -- 3281
	end) -- 3281
end -- 3259
function SpawnSubAgentAction.prototype.exec(self, input) -- 3285
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3285
		if not input.spawnSubAgent then -- 3285
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3285
		end -- 3285
		if input.sessionId == nil or input.sessionId <= 0 then -- 3285
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3285
		end -- 3285
		local ____Log_99 = Log -- 3300
		local ____temp_96 = #input.title -- 3300
		local ____temp_97 = #input.prompt -- 3300
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3300
		local ____opt_94 = input.filesHint -- 3300
		____Log_99( -- 3300
			"Info", -- 3300
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3300
		) -- 3300
		local result = __TS__Await(input.spawnSubAgent({ -- 3301
			parentSessionId = input.sessionId, -- 3302
			projectRoot = input.projectRoot, -- 3303
			title = input.title, -- 3304
			prompt = input.prompt, -- 3305
			expectedOutput = input.expectedOutput, -- 3306
			filesHint = input.filesHint -- 3307
		})) -- 3307
		if not result.success then -- 3307
			return ____awaiter_resolve(nil, result) -- 3307
		end -- 3307
		return ____awaiter_resolve(nil, { -- 3307
			success = true, -- 3313
			sessionId = result.sessionId, -- 3314
			taskId = result.taskId, -- 3315
			title = result.title, -- 3316
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3317
		}) -- 3317
	end) -- 3317
end -- 3285
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3321
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3321
		local last = shared.history[#shared.history] -- 3322
		if last ~= nil then -- 3322
			last.result = execRes -- 3324
			appendToolResultMessage(shared, last) -- 3325
			emitAgentFinishEvent(shared, last) -- 3326
		end -- 3326
		persistHistoryState(shared) -- 3328
		__TS__Await(maybeCompressHistory(shared)) -- 3329
		persistHistoryState(shared) -- 3330
		return ____awaiter_resolve(nil, "main") -- 3330
	end) -- 3330
end -- 3321
local ListSubAgentsAction = __TS__Class() -- 3335
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3335
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3335
function ListSubAgentsAction.prototype.prep(self, shared) -- 3336
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3336
		local last = shared.history[#shared.history] -- 3345
		if not last then -- 3345
			error( -- 3346
				__TS__New(Error, "no history"), -- 3346
				0 -- 3346
			) -- 3346
		end -- 3346
		emitAgentStartEvent(shared, last) -- 3347
		return ____awaiter_resolve( -- 3347
			nil, -- 3347
			{ -- 3348
				sessionId = shared.sessionId, -- 3349
				projectRoot = shared.workingDir, -- 3350
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3351
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3352
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3353
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3354
				listSubAgents = shared.listSubAgents -- 3355
			} -- 3355
		) -- 3355
	end) -- 3355
end -- 3336
function ListSubAgentsAction.prototype.exec(self, input) -- 3359
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3359
		if not input.listSubAgents then -- 3359
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3359
		end -- 3359
		if input.sessionId == nil or input.sessionId <= 0 then -- 3359
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3359
		end -- 3359
		local result = __TS__Await(input.listSubAgents({ -- 3374
			sessionId = input.sessionId, -- 3375
			projectRoot = input.projectRoot, -- 3376
			status = input.status, -- 3377
			limit = input.limit, -- 3378
			offset = input.offset, -- 3379
			query = input.query -- 3380
		})) -- 3380
		return ____awaiter_resolve(nil, result) -- 3380
	end) -- 3380
end -- 3359
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3385
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3385
		local last = shared.history[#shared.history] -- 3386
		if last ~= nil then -- 3386
			last.result = execRes -- 3388
			appendToolResultMessage(shared, last) -- 3389
			emitAgentFinishEvent(shared, last) -- 3390
		end -- 3390
		persistHistoryState(shared) -- 3392
		__TS__Await(maybeCompressHistory(shared)) -- 3393
		persistHistoryState(shared) -- 3394
		return ____awaiter_resolve(nil, "main") -- 3394
	end) -- 3394
end -- 3385
EditFileAction = __TS__Class() -- 3399
EditFileAction.name = "EditFileAction" -- 3399
__TS__ClassExtends(EditFileAction, Node) -- 3399
function EditFileAction.prototype.prep(self, shared) -- 3400
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3400
		local last = shared.history[#shared.history] -- 3401
		if not last then -- 3401
			error( -- 3402
				__TS__New(Error, "no history"), -- 3402
				0 -- 3402
			) -- 3402
		end -- 3402
		emitAgentStartEvent(shared, last) -- 3403
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3404
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3407
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3408
		if __TS__StringTrim(path) == "" then -- 3408
			error( -- 3409
				__TS__New(Error, "missing path"), -- 3409
				0 -- 3409
			) -- 3409
		end -- 3409
		return ____awaiter_resolve(nil, { -- 3409
			path = path, -- 3410
			oldStr = oldStr, -- 3410
			newStr = newStr, -- 3410
			taskId = shared.taskId, -- 3410
			workDir = shared.workingDir -- 3410
		}) -- 3410
	end) -- 3410
end -- 3400
function EditFileAction.prototype.exec(self, input) -- 3413
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3413
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3414
		if not readRes.success then -- 3414
			if input.oldStr ~= "" then -- 3414
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3414
			end -- 3414
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3419
			if not createRes.success then -- 3419
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3419
			end -- 3419
			return ____awaiter_resolve(nil, { -- 3419
				success = true, -- 3427
				changed = true, -- 3428
				mode = "create", -- 3429
				checkpointId = createRes.checkpointId, -- 3430
				checkpointSeq = createRes.checkpointSeq, -- 3431
				files = {{path = input.path, op = "create"}} -- 3432
			}) -- 3432
		end -- 3432
		if input.oldStr == "" then -- 3432
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3436
			if not overwriteRes.success then -- 3436
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3436
			end -- 3436
			return ____awaiter_resolve(nil, { -- 3436
				success = true, -- 3444
				changed = true, -- 3445
				mode = "overwrite", -- 3446
				checkpointId = overwriteRes.checkpointId, -- 3447
				checkpointSeq = overwriteRes.checkpointSeq, -- 3448
				files = {{path = input.path, op = "write"}} -- 3449
			}) -- 3449
		end -- 3449
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3454
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3455
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3456
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3459
		if occurrences == 0 then -- 3459
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3461
			if not indentTolerant.success then -- 3461
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3461
			end -- 3461
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3465
			if not applyRes.success then -- 3465
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3465
			end -- 3465
			return ____awaiter_resolve(nil, { -- 3465
				success = true, -- 3473
				changed = true, -- 3474
				mode = "replace_indent_tolerant", -- 3475
				checkpointId = applyRes.checkpointId, -- 3476
				checkpointSeq = applyRes.checkpointSeq, -- 3477
				files = {{path = input.path, op = "write"}} -- 3478
			}) -- 3478
		end -- 3478
		if occurrences > 1 then -- 3478
			return ____awaiter_resolve( -- 3478
				nil, -- 3478
				{ -- 3482
					success = false, -- 3482
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3482
				} -- 3482
			) -- 3482
		end -- 3482
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3486
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3487
		if not applyRes.success then -- 3487
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3487
		end -- 3487
		return ____awaiter_resolve(nil, { -- 3487
			success = true, -- 3495
			changed = true, -- 3496
			mode = "replace", -- 3497
			checkpointId = applyRes.checkpointId, -- 3498
			checkpointSeq = applyRes.checkpointSeq, -- 3499
			files = {{path = input.path, op = "write"}} -- 3500
		}) -- 3500
	end) -- 3500
end -- 3413
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3504
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3504
		local last = shared.history[#shared.history] -- 3505
		if last ~= nil then -- 3505
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3507
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3508
			appendToolResultMessage(shared, last) -- 3509
			emitAgentFinishEvent(shared, last) -- 3510
			local result = last.result -- 3511
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3511
				emitAgentEvent(shared, { -- 3516
					type = "checkpoint_created", -- 3517
					sessionId = shared.sessionId, -- 3518
					taskId = shared.taskId, -- 3519
					step = last.step, -- 3520
					tool = last.tool, -- 3521
					checkpointId = result.checkpointId, -- 3522
					checkpointSeq = result.checkpointSeq, -- 3523
					files = result.files -- 3524
				}) -- 3524
			end -- 3524
		end -- 3524
		persistHistoryState(shared) -- 3528
		__TS__Await(maybeCompressHistory(shared)) -- 3529
		persistHistoryState(shared) -- 3530
		return ____awaiter_resolve(nil, "main") -- 3530
	end) -- 3530
end -- 3504
local function emitCheckpointEventForAction(shared, action) -- 3535
	local result = action.result -- 3536
	if not result then -- 3536
		return -- 3537
	end -- 3537
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3537
		emitAgentEvent(shared, { -- 3542
			type = "checkpoint_created", -- 3543
			sessionId = shared.sessionId, -- 3544
			taskId = shared.taskId, -- 3545
			step = action.step, -- 3546
			tool = action.tool, -- 3547
			checkpointId = result.checkpointId, -- 3548
			checkpointSeq = result.checkpointSeq, -- 3549
			files = result.files -- 3550
		}) -- 3550
	end -- 3550
end -- 3535
local function canRunBatchActionInParallel(self, action) -- 3855
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3856
end -- 3855
local function partitionToolCalls(actions) -- 3868
	local batches = {} -- 3869
	do -- 3869
		local i = 0 -- 3870
		while i < #actions do -- 3870
			local action = actions[i + 1] -- 3871
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3872
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3873
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3873
				local ____lastBatch_actions_134 = lastBatch.actions -- 3873
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3875
			else -- 3875
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3877
			end -- 3877
			i = i + 1 -- 3870
		end -- 3870
	end -- 3870
	return batches -- 3880
end -- 3868
local BatchToolAction = __TS__Class() -- 3883
BatchToolAction.name = "BatchToolAction" -- 3883
__TS__ClassExtends(BatchToolAction, Node) -- 3883
function BatchToolAction.prototype.prep(self, shared) -- 3884
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3884
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3884
	end) -- 3884
end -- 3884
function BatchToolAction.prototype.exec(self, input) -- 3888
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3888
		local shared = input.shared -- 3889
		local preExecuted = shared.preExecutedResults -- 3890
		local batches = partitionToolCalls(input.actions) -- 3891
		local parallelBatchCount = #__TS__ArrayFilter( -- 3892
			batches, -- 3892
			function(____, b) return b.isConcurrencySafe end -- 3892
		) -- 3892
		local serialBatchCount = #__TS__ArrayFilter( -- 3893
			batches, -- 3893
			function(____, b) return not b.isConcurrencySafe end -- 3893
		) -- 3893
		Log( -- 3894
			"Info", -- 3894
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3894
		) -- 3894
		do -- 3894
			local batchIdx = 0 -- 3896
			while batchIdx < #batches do -- 3896
				do -- 3896
					local batch = batches[batchIdx + 1] -- 3897
					if shared.stopToken.stopped then -- 3897
						for ____, action in ipairs(batch.actions) do -- 3899
							if not action.result then -- 3899
								action.result = { -- 3901
									success = false, -- 3901
									message = getCancelledReason(shared) -- 3901
								} -- 3901
							end -- 3901
						end -- 3901
						goto __continue603 -- 3904
					end -- 3904
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3904
						local preExecCount = #__TS__ArrayFilter( -- 3908
							batch.actions, -- 3908
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3908
						) -- 3908
						Log( -- 3909
							"Info", -- 3909
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3909
						) -- 3909
						do -- 3909
							local i = 0 -- 3910
							while i < #batch.actions do -- 3910
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3911
								i = i + 1 -- 3910
							end -- 3910
						end -- 3910
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3913
							batch.actions, -- 3913
							function(____, action) -- 3913
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3913
									if shared.stopToken.stopped then -- 3913
										action.result = { -- 3915
											success = false, -- 3915
											message = getCancelledReason(shared) -- 3915
										} -- 3915
										return ____awaiter_resolve(nil, action) -- 3915
									end -- 3915
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3918
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3919
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3920
									return ____awaiter_resolve(nil, action) -- 3920
								end) -- 3920
							end -- 3913
						))) -- 3913
						do -- 3913
							local i = 0 -- 3923
							while i < #batch.actions do -- 3923
								local action = batch.actions[i + 1] -- 3924
								if not action.result then -- 3924
									action.result = {success = false, message = "tool did not produce a result"} -- 3926
								end -- 3926
								appendToolResultMessage(shared, action) -- 3928
								emitAgentFinishEvent(shared, action) -- 3929
								emitCheckpointEventForAction(shared, action) -- 3930
								i = i + 1 -- 3923
							end -- 3923
						end -- 3923
					else -- 3923
						Log( -- 3933
							"Info", -- 3933
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3933
						) -- 3933
						do -- 3933
							local i = 0 -- 3934
							while i < #batch.actions do -- 3934
								local action = batch.actions[i + 1] -- 3935
								emitAgentStartEvent(shared, action) -- 3936
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3937
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3938
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3939
								appendToolResultMessage(shared, action) -- 3940
								emitAgentFinishEvent(shared, action) -- 3941
								emitCheckpointEventForAction(shared, action) -- 3942
								persistHistoryState(shared) -- 3943
								if shared.stopToken.stopped then -- 3943
									break -- 3945
								end -- 3945
								i = i + 1 -- 3934
							end -- 3934
						end -- 3934
					end -- 3934
				end -- 3934
				::__continue603:: -- 3934
				batchIdx = batchIdx + 1 -- 3896
			end -- 3896
		end -- 3896
		persistHistoryState(shared) -- 3950
		return ____awaiter_resolve(nil, input.actions) -- 3950
	end) -- 3950
end -- 3888
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3954
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3954
		shared.pendingToolActions = nil -- 3955
		shared.preExecutedResults = nil -- 3956
		persistHistoryState(shared) -- 3957
		__TS__Await(maybeCompressHistory(shared)) -- 3958
		persistHistoryState(shared) -- 3959
		return ____awaiter_resolve(nil, "main") -- 3959
	end) -- 3959
end -- 3954
local EndNode = __TS__Class() -- 3964
EndNode.name = "EndNode" -- 3964
__TS__ClassExtends(EndNode, Node) -- 3964
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3965
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3965
		return ____awaiter_resolve(nil, nil) -- 3965
	end) -- 3965
end -- 3965
local CodingAgentFlow = __TS__Class() -- 3970
CodingAgentFlow.name = "CodingAgentFlow" -- 3970
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3970
function CodingAgentFlow.prototype.____constructor(self, role) -- 3971
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3972
	local read = __TS__New(ReadFileAction, 1, 0) -- 3973
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3974
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3975
	local list = __TS__New(ListFilesAction, 1, 0) -- 3976
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3977
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3978
	local build = __TS__New(BuildAction, 1, 0) -- 3979
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3980
	local edit = __TS__New(EditFileAction, 1, 0) -- 3981
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3982
	local done = __TS__New(EndNode, 1, 0) -- 3983
	main:on("batch_tools", batch) -- 3985
	main:on("grep_files", search) -- 3986
	main:on("search_dora_api", searchDora) -- 3987
	main:on("glob_files", list) -- 3988
	if role == "main" then -- 3988
		main:on("read_file", read) -- 3990
		main:on("delete_file", del) -- 3991
		main:on("build", build) -- 3992
		main:on("edit_file", edit) -- 3993
		main:on("list_sub_agents", listSub) -- 3994
		main:on("spawn_sub_agent", spawn) -- 3995
	else -- 3995
		main:on("read_file", read) -- 3997
		main:on("delete_file", del) -- 3998
		main:on("build", build) -- 3999
		main:on("edit_file", edit) -- 4000
	end -- 4000
	main:on("done", done) -- 4002
	search:on("main", main) -- 4004
	searchDora:on("main", main) -- 4005
	list:on("main", main) -- 4006
	listSub:on("main", main) -- 4007
	spawn:on("main", main) -- 4008
	batch:on("main", main) -- 4009
	read:on("main", main) -- 4010
	del:on("main", main) -- 4011
	build:on("main", main) -- 4012
	edit:on("main", main) -- 4013
	Flow.prototype.____constructor(self, main) -- 4015
end -- 3971
local function runCodingAgentAsync(options) -- 4037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4037
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4037
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4037
		end -- 4037
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4041
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4042
		if not llmConfigRes.success then -- 4042
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4042
		end -- 4042
		local llmConfig = llmConfigRes.config -- 4048
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4049
		if not taskRes.success then -- 4049
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4049
		end -- 4049
		local compressor = __TS__New(MemoryCompressor, { -- 4056
			compressionThreshold = 0.8, -- 4057
			compressionTargetThreshold = 0.5, -- 4058
			maxCompressionRounds = 3, -- 4059
			projectDir = options.workDir, -- 4060
			llmConfig = llmConfig, -- 4061
			promptPack = options.promptPack, -- 4062
			scope = options.memoryScope -- 4063
		}) -- 4063
		local persistedSession = compressor:getStorage():readSessionState() -- 4065
		local promptPack = compressor:getPromptPack() -- 4066
		local shared = { -- 4068
			sessionId = options.sessionId, -- 4069
			taskId = taskRes.taskId, -- 4070
			role = options.role or "main", -- 4071
			maxSteps = math.max( -- 4072
				1, -- 4072
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4072
			), -- 4072
			llmMaxTry = math.max( -- 4073
				1, -- 4073
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4073
			), -- 4073
			step = 0, -- 4074
			done = false, -- 4075
			stopToken = options.stopToken or ({stopped = false}), -- 4076
			response = "", -- 4077
			userQuery = normalizedPrompt, -- 4078
			workingDir = options.workDir, -- 4079
			useChineseResponse = options.useChineseResponse == true, -- 4080
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4081
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4084
			llmConfig = llmConfig, -- 4085
			onEvent = options.onEvent, -- 4086
			promptPack = promptPack, -- 4087
			history = {}, -- 4088
			messages = persistedSession.messages, -- 4089
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4090
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4091
			memory = {compressor = compressor}, -- 4093
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4097
			spawnSubAgent = options.spawnSubAgent, -- 4102
			listSubAgents = options.listSubAgents -- 4103
		} -- 4103
		local ____try = __TS__AsyncAwaiter(function() -- 4103
			emitAgentEvent(shared, { -- 4107
				type = "task_started", -- 4108
				sessionId = shared.sessionId, -- 4109
				taskId = shared.taskId, -- 4110
				prompt = shared.userQuery, -- 4111
				workDir = shared.workingDir, -- 4112
				maxSteps = shared.maxSteps -- 4113
			}) -- 4113
			if shared.stopToken.stopped then -- 4113
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4116
				return ____awaiter_resolve( -- 4116
					nil, -- 4116
					emitAgentTaskFinishEvent( -- 4117
						shared, -- 4117
						false, -- 4117
						getCancelledReason(shared) -- 4117
					) -- 4117
				) -- 4117
			end -- 4117
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4119
			local promptCommand = getPromptCommand(shared.userQuery) -- 4120
			if promptCommand == "clear" then -- 4120
				return ____awaiter_resolve( -- 4120
					nil, -- 4120
					clearSessionHistory(shared) -- 4122
				) -- 4122
			end -- 4122
			if promptCommand == "compact" then -- 4122
				if shared.role == "sub" then -- 4122
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4126
					return ____awaiter_resolve( -- 4126
						nil, -- 4126
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4127
					) -- 4127
				end -- 4127
				return ____awaiter_resolve( -- 4127
					nil, -- 4127
					__TS__Await(compactAllHistory(shared)) -- 4135
				) -- 4135
			end -- 4135
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4137
			persistHistoryState(shared) -- 4141
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4142
			__TS__Await(flow:run(shared)) -- 4143
			if shared.stopToken.stopped then -- 4143
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4145
				return ____awaiter_resolve( -- 4145
					nil, -- 4145
					emitAgentTaskFinishEvent( -- 4146
						shared, -- 4146
						false, -- 4146
						getCancelledReason(shared) -- 4146
					) -- 4146
				) -- 4146
			end -- 4146
			if shared.error then -- 4146
				return ____awaiter_resolve( -- 4146
					nil, -- 4146
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4149
				) -- 4149
			end -- 4149
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4152
			return ____awaiter_resolve( -- 4152
				nil, -- 4152
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4153
			) -- 4153
		end) -- 4153
		__TS__Await(____try.catch( -- 4106
			____try, -- 4106
			function(____, e) -- 4106
				return ____awaiter_resolve( -- 4106
					nil, -- 4106
					finalizeAgentFailure( -- 4156
						shared, -- 4156
						tostring(e) -- 4156
					) -- 4156
				) -- 4156
			end -- 4156
		)) -- 4156
	end) -- 4156
end -- 4037
function ____exports.runCodingAgent(options, callback) -- 4160
	local ____self_137 = runCodingAgentAsync(options) -- 4160
	____self_137["then"]( -- 4160
		____self_137, -- 4160
		function(____, result) return callback(result) end -- 4161
	) -- 4161
end -- 4160
return ____exports -- 4160