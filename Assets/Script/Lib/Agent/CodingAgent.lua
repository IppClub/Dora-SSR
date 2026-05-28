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
function getFinishMessage(params, fallback) -- 1660
	if fallback == nil then -- 1660
		fallback = "" -- 1660
	end -- 1660
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1660
		return __TS__StringTrim(params.message) -- 1662
	end -- 1662
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1662
		return __TS__StringTrim(params.response) -- 1665
	end -- 1665
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1665
		return __TS__StringTrim(params.summary) -- 1668
	end -- 1668
	return __TS__StringTrim(fallback) -- 1670
end -- 1670
function persistHistoryState(shared) -- 1673
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1674
end -- 1674
function getActiveConversationMessages(shared) -- 1681
	local activeMessages = {} -- 1682
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1682
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1689
	end -- 1689
	do -- 1689
		local i = shared.lastConsolidatedIndex -- 1693
		while i < #shared.messages do -- 1693
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1694
			i = i + 1 -- 1693
		end -- 1693
	end -- 1693
	return activeMessages -- 1696
end -- 1696
function getActiveRealMessageCount(shared) -- 1699
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1700
end -- 1700
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1703
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1708
	local previousActiveStart = shared.lastConsolidatedIndex -- 1709
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1710
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1711
	if type(carryMessageIndex) == "number" then -- 1711
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1711
		else -- 1711
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1719
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1722
		end -- 1722
	else -- 1722
		shared.carryMessageIndex = nil -- 1727
	end -- 1727
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1727
		shared.carryMessageIndex = nil -- 1737
	end -- 1737
end -- 1737
function getDecisionPath(params) -- 1995
	if type(params.path) == "string" then -- 1995
		return __TS__StringTrim(params.path) -- 1996
	end -- 1996
	if type(params.target_file) == "string" then -- 1996
		return __TS__StringTrim(params.target_file) -- 1997
	end -- 1997
	return "" -- 1998
end -- 1998
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2001
	local num = __TS__Number(value) -- 2002
	if not __TS__NumberIsFinite(num) then -- 2002
		num = fallback -- 2003
	end -- 2003
	num = math.floor(num) -- 2004
	if num < minValue then -- 2004
		num = minValue -- 2005
	end -- 2005
	if maxValue ~= nil and num > maxValue then -- 2005
		num = maxValue -- 2006
	end -- 2006
	return num -- 2007
end -- 2007
function parseReadLineParam(value, fallback, paramName) -- 2010
	local num = __TS__Number(value) -- 2015
	if not __TS__NumberIsFinite(num) then -- 2015
		num = fallback -- 2016
	end -- 2016
	num = math.floor(num) -- 2017
	if num == 0 then -- 2017
		return {success = false, message = paramName .. " cannot be 0"} -- 2019
	end -- 2019
	return {success = true, value = num} -- 2021
end -- 2021
function validateDecision(tool, params) -- 2024
	if tool == "finish" then -- 2024
		local message = getFinishMessage(params) -- 2029
		if message == "" then -- 2029
			return {success = false, message = "finish requires params.message"} -- 2030
		end -- 2030
		params.message = message -- 2031
		return {success = true, params = params} -- 2032
	end -- 2032
	if tool == "read_file" then -- 2032
		local path = getDecisionPath(params) -- 2036
		if path == "" then -- 2036
			return {success = false, message = "read_file requires path"} -- 2037
		end -- 2037
		params.path = path -- 2038
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2039
		if not startLineRes.success then -- 2039
			return startLineRes -- 2040
		end -- 2040
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 2041
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2042
		if not endLineRes.success then -- 2042
			return endLineRes -- 2043
		end -- 2043
		params.startLine = startLineRes.value -- 2044
		params.endLine = endLineRes.value -- 2045
		return {success = true, params = params} -- 2046
	end -- 2046
	if tool == "edit_file" then -- 2046
		local path = getDecisionPath(params) -- 2050
		if path == "" then -- 2050
			return {success = false, message = "edit_file requires path"} -- 2051
		end -- 2051
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2052
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2053
		params.path = path -- 2054
		params.old_str = oldStr -- 2055
		params.new_str = newStr -- 2056
		return {success = true, params = params} -- 2057
	end -- 2057
	if tool == "delete_file" then -- 2057
		local targetFile = getDecisionPath(params) -- 2061
		if targetFile == "" then -- 2061
			return {success = false, message = "delete_file requires target_file"} -- 2062
		end -- 2062
		params.target_file = targetFile -- 2063
		return {success = true, params = params} -- 2064
	end -- 2064
	if tool == "grep_files" then -- 2064
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2068
		if pattern == "" then -- 2068
			return {success = false, message = "grep_files requires pattern"} -- 2069
		end -- 2069
		params.pattern = pattern -- 2070
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2071
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2072
		return {success = true, params = params} -- 2073
	end -- 2073
	if tool == "search_dora_api" then -- 2073
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2077
		if pattern == "" then -- 2077
			return {success = false, message = "search_dora_api requires pattern"} -- 2078
		end -- 2078
		params.pattern = pattern -- 2079
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2080
		return {success = true, params = params} -- 2081
	end -- 2081
	if tool == "glob_files" then -- 2081
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2085
		return {success = true, params = params} -- 2086
	end -- 2086
	if tool == "build" then -- 2086
		local path = getDecisionPath(params) -- 2090
		if path ~= "" then -- 2090
			params.path = path -- 2092
		end -- 2092
		return {success = true, params = params} -- 2094
	end -- 2094
	if tool == "list_sub_agents" then -- 2094
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2098
		if status ~= "" then -- 2098
			params.status = status -- 2100
		end -- 2100
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2102
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2103
		if type(params.query) == "string" then -- 2103
			params.query = __TS__StringTrim(params.query) -- 2105
		end -- 2105
		return {success = true, params = params} -- 2107
	end -- 2107
	if tool == "spawn_sub_agent" then -- 2107
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2111
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2112
		if prompt == "" then -- 2112
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2113
		end -- 2113
		if title == "" then -- 2113
			return {success = false, message = "spawn_sub_agent requires title"} -- 2114
		end -- 2114
		params.prompt = prompt -- 2115
		params.title = title -- 2116
		if type(params.expectedOutput) == "string" then -- 2116
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2118
		end -- 2118
		if isArray(params.filesHint) then -- 2118
			params.filesHint = __TS__ArrayMap( -- 2121
				__TS__ArrayFilter( -- 2121
					params.filesHint, -- 2121
					function(____, item) return type(item) == "string" end -- 2122
				), -- 2122
				function(____, item) return sanitizeUTF8(item) end -- 2123
			) -- 2123
		end -- 2123
		return {success = true, params = params} -- 2125
	end -- 2125
	return {success = true, params = params} -- 2128
end -- 2128
function getAllowedToolsForRole(role) -- 2154
	return role == "main" and ({ -- 2155
		"read_file", -- 2156
		"edit_file", -- 2156
		"delete_file", -- 2156
		"grep_files", -- 2156
		"search_dora_api", -- 2156
		"glob_files", -- 2156
		"build", -- 2156
		"list_sub_agents", -- 2156
		"spawn_sub_agent", -- 2156
		"finish" -- 2156
	}) or ({ -- 2156
		"read_file", -- 2157
		"edit_file", -- 2157
		"delete_file", -- 2157
		"grep_files", -- 2157
		"search_dora_api", -- 2157
		"glob_files", -- 2157
		"build", -- 2157
		"finish" -- 2157
	}) -- 2157
end -- 2157
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2263
	if includeToolDefinitions == nil then -- 2263
		includeToolDefinitions = false -- 2263
	end -- 2263
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2264
	local sections = { -- 2267
		shared.promptPack.agentIdentityPrompt, -- 2268
		rolePrompt, -- 2269
		getReplyLanguageDirective(shared) -- 2270
	} -- 2270
	if shared.decisionMode == "tool_calling" then -- 2270
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2273
	end -- 2273
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2275
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2276
	if memoryContext ~= "" then -- 2276
		sections[#sections + 1] = memoryContext -- 2278
	end -- 2278
	if includeToolDefinitions then -- 2278
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2281
		if shared.decisionMode == "xml" then -- 2281
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2283
		end -- 2283
	end -- 2283
	local skillsSection = buildSkillsSection(shared) -- 2287
	if skillsSection ~= "" then -- 2287
		sections[#sections + 1] = skillsSection -- 2289
	end -- 2289
	return table.concat(sections, "\n\n") -- 2291
end -- 2291
function buildSkillsSection(shared) -- 2294
	local ____opt_42 = shared.skills -- 2294
	if not (____opt_42 and ____opt_42.loader) then -- 2294
		return "" -- 2296
	end -- 2296
	return shared.skills.loader:buildSkillsPromptSection() -- 2298
end -- 2298
function buildXmlDecisionInstruction(shared, feedback) -- 2467
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2468
end -- 2468
function executeToolAction(shared, action) -- 3730
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3730
		if shared.stopToken.stopped then -- 3730
			return ____awaiter_resolve( -- 3730
				nil, -- 3730
				{ -- 3732
					success = false, -- 3732
					message = getCancelledReason(shared) -- 3732
				} -- 3732
			) -- 3732
		end -- 3732
		local params = action.params -- 3734
		if action.tool == "read_file" then -- 3734
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3736
			if __TS__StringTrim(path) == "" then -- 3736
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3736
			end -- 3736
			local ____Tools_readFile_104 = Tools.readFile -- 3740
			local ____shared_workingDir_102 = shared.workingDir -- 3741
			local ____params_startLine_100 = params.startLine -- 3743
			if ____params_startLine_100 == nil then -- 3743
				____params_startLine_100 = 1 -- 3743
			end -- 3743
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3743
			local ____params_endLine_101 = params.endLine -- 3744
			if ____params_endLine_101 == nil then -- 3744
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3744
			end -- 3744
			return ____awaiter_resolve( -- 3744
				nil, -- 3744
				____Tools_readFile_104( -- 3740
					____shared_workingDir_102, -- 3741
					path, -- 3742
					____TS__Number_result_103, -- 3743
					__TS__Number(____params_endLine_101), -- 3744
					shared.useChineseResponse and "zh" or "en" -- 3745
				) -- 3745
			) -- 3745
		end -- 3745
		if action.tool == "grep_files" then -- 3745
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3749
			local ____shared_workingDir_111 = shared.workingDir -- 3750
			local ____temp_112 = params.path or "" -- 3751
			local ____temp_113 = params.pattern or "" -- 3752
			local ____params_globs_114 = params.globs -- 3753
			local ____params_useRegex_115 = params.useRegex -- 3754
			local ____params_caseSensitive_116 = params.caseSensitive -- 3755
			local ____math_max_107 = math.max -- 3758
			local ____math_floor_106 = math.floor -- 3758
			local ____params_limit_105 = params.limit -- 3758
			if ____params_limit_105 == nil then -- 3758
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3758
			end -- 3758
			local ____math_max_107_result_117 = ____math_max_107( -- 3758
				1, -- 3758
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3758
			) -- 3758
			local ____math_max_110 = math.max -- 3759
			local ____math_floor_109 = math.floor -- 3759
			local ____params_offset_108 = params.offset -- 3759
			if ____params_offset_108 == nil then -- 3759
				____params_offset_108 = 0 -- 3759
			end -- 3759
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3749
				workDir = ____shared_workingDir_111, -- 3750
				path = ____temp_112, -- 3751
				pattern = ____temp_113, -- 3752
				globs = ____params_globs_114, -- 3753
				useRegex = ____params_useRegex_115, -- 3754
				caseSensitive = ____params_caseSensitive_116, -- 3755
				includeContent = true, -- 3756
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3757
				limit = ____math_max_107_result_117, -- 3758
				offset = ____math_max_110( -- 3759
					0, -- 3759
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3759
				), -- 3759
				groupByFile = params.groupByFile == true -- 3760
			})) -- 3760
			return ____awaiter_resolve(nil, result) -- 3760
		end -- 3760
		if action.tool == "search_dora_api" then -- 3760
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3765
			local ____temp_122 = params.pattern or "" -- 3766
			local ____temp_123 = params.docSource or "api" -- 3767
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3768
			local ____temp_125 = params.programmingLanguage or "ts" -- 3769
			local ____math_min_121 = math.min -- 3770
			local ____math_max_120 = math.max -- 3770
			local ____params_limit_119 = params.limit -- 3770
			if ____params_limit_119 == nil then -- 3770
				____params_limit_119 = 8 -- 3770
			end -- 3770
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3765
				pattern = ____temp_122, -- 3766
				docSource = ____temp_123, -- 3767
				docLanguage = ____temp_124, -- 3768
				programmingLanguage = ____temp_125, -- 3769
				limit = ____math_min_121( -- 3770
					SEARCH_DORA_API_LIMIT_MAX, -- 3770
					____math_max_120( -- 3770
						1, -- 3770
						__TS__Number(____params_limit_119) -- 3770
					) -- 3770
				), -- 3770
				useRegex = params.useRegex, -- 3771
				caseSensitive = false, -- 3772
				includeContent = true, -- 3773
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3774
			})) -- 3774
			return ____awaiter_resolve(nil, result) -- 3774
		end -- 3774
		if action.tool == "glob_files" then -- 3774
			local ____Tools_listFiles_133 = Tools.listFiles -- 3779
			local ____shared_workingDir_130 = shared.workingDir -- 3780
			local ____temp_131 = params.path or "" -- 3781
			local ____params_globs_132 = params.globs -- 3782
			local ____math_max_129 = math.max -- 3783
			local ____math_floor_128 = math.floor -- 3783
			local ____params_maxEntries_127 = params.maxEntries -- 3783
			if ____params_maxEntries_127 == nil then -- 3783
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3783
			end -- 3783
			local result = ____Tools_listFiles_133({ -- 3779
				workDir = ____shared_workingDir_130, -- 3780
				path = ____temp_131, -- 3781
				globs = ____params_globs_132, -- 3782
				maxEntries = ____math_max_129( -- 3783
					1, -- 3783
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3783
				) -- 3783
			}) -- 3783
			return ____awaiter_resolve(nil, result) -- 3783
		end -- 3783
		if action.tool == "delete_file" then -- 3783
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3788
			if __TS__StringTrim(targetFile) == "" then -- 3788
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3788
			end -- 3788
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3792
			if not result.success then -- 3792
				return ____awaiter_resolve(nil, result) -- 3792
			end -- 3792
			return ____awaiter_resolve(nil, { -- 3792
				success = true, -- 3800
				changed = true, -- 3801
				mode = "delete", -- 3802
				checkpointId = result.checkpointId, -- 3803
				checkpointSeq = result.checkpointSeq, -- 3804
				files = {{path = targetFile, op = "delete"}} -- 3805
			}) -- 3805
		end -- 3805
		if action.tool == "build" then -- 3805
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3809
			return ____awaiter_resolve(nil, result) -- 3809
		end -- 3809
		if action.tool == "spawn_sub_agent" then -- 3809
			if not shared.spawnSubAgent then -- 3809
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3809
			end -- 3809
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3809
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3809
			end -- 3809
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3822
				params.filesHint, -- 3823
				function(____, item) return type(item) == "string" end -- 3823
			) or nil -- 3823
			local result = __TS__Await(shared.spawnSubAgent({ -- 3825
				parentSessionId = shared.sessionId, -- 3826
				projectRoot = shared.workingDir, -- 3827
				title = type(params.title) == "string" and params.title or "Sub", -- 3828
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3829
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3830
				filesHint = filesHint -- 3831
			})) -- 3831
			if not result.success then -- 3831
				return ____awaiter_resolve(nil, result) -- 3831
			end -- 3831
			return ____awaiter_resolve(nil, { -- 3831
				success = true, -- 3837
				sessionId = result.sessionId, -- 3838
				taskId = result.taskId, -- 3839
				title = result.title, -- 3840
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3841
			}) -- 3841
		end -- 3841
		if action.tool == "list_sub_agents" then -- 3841
			if not shared.listSubAgents then -- 3841
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3841
			end -- 3841
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3841
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3841
			end -- 3841
			local result = __TS__Await(shared.listSubAgents({ -- 3851
				sessionId = shared.sessionId, -- 3852
				projectRoot = shared.workingDir, -- 3853
				status = type(params.status) == "string" and params.status or nil, -- 3854
				limit = type(params.limit) == "number" and params.limit or nil, -- 3855
				offset = type(params.offset) == "number" and params.offset or nil, -- 3856
				query = type(params.query) == "string" and params.query or nil -- 3857
			})) -- 3857
			return ____awaiter_resolve(nil, result) -- 3857
		end -- 3857
		if action.tool == "edit_file" then -- 3857
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3862
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3865
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3866
			if __TS__StringTrim(path) == "" then -- 3866
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3866
			end -- 3866
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3868
			return ____awaiter_resolve( -- 3868
				nil, -- 3868
				actionNode:exec({ -- 3869
					path = path, -- 3870
					oldStr = oldStr, -- 3871
					newStr = newStr, -- 3872
					taskId = shared.taskId, -- 3873
					workDir = shared.workingDir -- 3874
				}) -- 3874
			) -- 3874
		end -- 3874
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3874
	end) -- 3874
end -- 3874
function sanitizeToolActionResultForHistory(action, result) -- 3880
	if action.tool == "read_file" then -- 3880
		return sanitizeReadResultForHistory(action.tool, result) -- 3882
	end -- 3882
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3882
		return sanitizeSearchResultForHistory(action.tool, result) -- 3885
	end -- 3885
	if action.tool == "glob_files" then -- 3885
		return sanitizeListFilesResultForHistory(result) -- 3888
	end -- 3888
	if action.tool == "build" then -- 3888
		return sanitizeBuildResultForHistory(result) -- 3891
	end -- 3891
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3891
		if result.success ~= true then -- 3891
			return result -- 3894
		end -- 3894
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3894
			return result -- 3895
		end -- 3895
		if isArray(result.fileContext) then -- 3895
			return result -- 3896
		end -- 3896
		local contextLimits = { -- 3898
			fullContentChars = 12000, -- 3899
			previewChars = 4000, -- 3900
			diffChars = 8000, -- 3901
			totalChars = 24000, -- 3902
			maxFiles = 8 -- 3903
		} -- 3903
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3905
			if maxChars <= 0 then -- 3905
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3906
			end -- 3906
			if #sourceText <= maxChars then -- 3906
				return sourceText -- 3907
			end -- 3907
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3908
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3909
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3910
		end -- 3905
		local function countLines(sourceText) -- 3912
			if sourceText == "" then -- 3912
				return 0 -- 3913
			end -- 3913
			return #__TS__StringSplit(sourceText, "\n") -- 3914
		end -- 3912
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3916
			if beforeContent == afterContent then -- 3916
				return "" -- 3917
			end -- 3917
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3918
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3919
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3921
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3921
				firstChangedLine = firstChangedLine + 1 -- 3927
			end -- 3927
			local lastChangedBeforeLine = #beforeLines - 1 -- 3929
			local lastChangedAfterLine = #afterLines - 1 -- 3930
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3930
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3936
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3937
			end -- 3937
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3939
			local previewEndLine = math.max( -- 3940
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3941
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3942
			) -- 3942
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3944
			do -- 3944
				local lineIndex = previewStartLine -- 3945
				while lineIndex <= previewEndLine do -- 3945
					do -- 3945
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3946
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3947
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3948
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3949
						if not beforeChanged and not afterChanged then -- 3949
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3951
							if contextLine ~= nil then -- 3951
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3952
							end -- 3952
							goto __continue617 -- 3953
						end -- 3953
						if beforeChanged and beforeLine ~= nil then -- 3953
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3955
						end -- 3955
						if afterChanged and afterLine ~= nil then -- 3955
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3956
						end -- 3956
					end -- 3956
					::__continue617:: -- 3956
					lineIndex = lineIndex + 1 -- 3945
				end -- 3945
			end -- 3945
			return truncateContextSnippet( -- 3958
				table.concat(unifiedDiffLines, "\n"), -- 3958
				maxChars, -- 3958
				"diff" -- 3958
			) -- 3958
		end -- 3916
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3961
		if not checkpointDiff.success then -- 3961
			return result -- 3962
		end -- 3962
		local remainingContextBudget = contextLimits.totalChars -- 3963
		local fileContextItems = {} -- 3964
		local changedFiles = checkpointDiff.files -- 3965
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3966
		do -- 3966
			local fileIndex = 0 -- 3967
			while fileIndex < maxContextFiles do -- 3967
				if remainingContextBudget <= 0 then -- 3967
					break -- 3968
				end -- 3968
				local changedFile = changedFiles[fileIndex + 1] -- 3969
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3970
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3971
				local contextItem = { -- 3972
					path = changedFile.path, -- 3973
					op = changedFile.op, -- 3974
					checkpointId = result.checkpointId, -- 3975
					checkpointSeq = result.checkpointSeq, -- 3976
					beforeExists = changedFile.beforeExists, -- 3977
					afterExists = changedFile.afterExists, -- 3978
					beforeBytes = #beforeContent, -- 3979
					afterBytes = #afterContent, -- 3980
					diffPreview = "", -- 3981
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3982
					contentTruncated = false, -- 3983
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3984
				} -- 3984
				if changedFile.afterExists then -- 3984
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3984
						contextItem.afterContent = afterContent -- 3988
						remainingContextBudget = remainingContextBudget - #afterContent -- 3989
					else -- 3989
						contextItem.afterContentPreview = truncateContextSnippet( -- 3991
							afterContent, -- 3992
							math.min( -- 3993
								contextLimits.previewChars, -- 3993
								math.max(400, remainingContextBudget) -- 3993
							), -- 3993
							"afterContent" -- 3994
						) -- 3994
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3996
						contextItem.contentTruncated = true -- 3997
					end -- 3997
				end -- 3997
				local diffPreview = buildUnifiedDiffPreview( -- 4000
					changedFile.path, -- 4001
					beforeContent, -- 4002
					afterContent, -- 4003
					math.min( -- 4004
						contextLimits.diffChars, -- 4004
						math.max(400, remainingContextBudget) -- 4004
					) -- 4004
				) -- 4004
				contextItem.diffPreview = diffPreview -- 4006
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4007
				if not changedFile.afterExists and beforeContent ~= "" then -- 4007
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4009
						beforeContent, -- 4010
						math.min( -- 4011
							contextLimits.previewChars, -- 4011
							math.max(400, remainingContextBudget) -- 4011
						), -- 4011
						"beforeContent" -- 4012
					) -- 4012
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4014
					if #beforeContent > contextLimits.previewChars then -- 4014
						contextItem.contentTruncated = true -- 4015
					end -- 4015
				end -- 4015
				fileContextItems[#fileContextItems + 1] = contextItem -- 4017
				fileIndex = fileIndex + 1 -- 3967
			end -- 3967
		end -- 3967
		if #fileContextItems == 0 then -- 3967
			return result -- 4019
		end -- 4019
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4020
	end -- 4020
	return result -- 4027
end -- 4027
function emitAgentTaskFinishEvent(shared, success, message) -- 4194
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 4195
	emitAgentEvent(shared, { -- 4201
		type = "task_finished", -- 4202
		sessionId = shared.sessionId, -- 4203
		taskId = shared.taskId, -- 4204
		success = result.success, -- 4205
		message = result.message, -- 4206
		steps = result.steps -- 4207
	}) -- 4207
	return result -- 4209
end -- 4209
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
local function toJson(value, emptyAsArray) -- 1090
	if emptyAsArray == nil then -- 1090
		emptyAsArray = true -- 1090
	end -- 1090
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 1091
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
local function startPreExecutedToolAction(shared, action) -- 1334
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1334
		local ____try = __TS__AsyncAwaiter(function() -- 1334
			return ____awaiter_resolve( -- 1334
				nil, -- 1334
				__TS__Await(executeToolAction(shared, action)) -- 1336
			) -- 1336
		end) -- 1336
		__TS__Await(____try.catch( -- 1335
			____try, -- 1335
			function(____, err) -- 1335
				local message = tostring(err) -- 1338
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1339
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1339
			end -- 1339
		)) -- 1339
	end) -- 1339
end -- 1334
local function createPreExecutedToolResult(shared, action) -- 1344
	local cloneParamValue -- 1345
	cloneParamValue = function(value) -- 1345
		if value == nil or value == nil then -- 1345
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
		if left == nil or left == nil or right == nil or right == nil then -- 1361
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
		matches = function(self, nextAction) -- 1390
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1391
		end, -- 1390
		promise = startPreExecutedToolAction(shared, action) -- 1393
	} -- 1393
end -- 1344
local function executeToolActionWithPreExecution(shared, action) -- 1397
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1397
		local ____opt_9 = shared.preExecutedResults -- 1397
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1398
		if preResult then -- 1398
			local ____opt_11 = shared.preExecutedResults -- 1398
			if ____opt_11 ~= nil then -- 1398
				____opt_11:delete(action.toolCallId) -- 1400
			end -- 1400
			if preResult:matches(action) then -- 1400
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1402
				return ____awaiter_resolve( -- 1402
					nil, -- 1402
					__TS__Await(preResult.promise) -- 1403
				) -- 1403
			end -- 1403
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1405
		end -- 1405
		return ____awaiter_resolve( -- 1405
			nil, -- 1405
			executeToolAction(shared, action) -- 1407
		) -- 1407
	end) -- 1407
end -- 1397
local function maybeCompressHistory(shared) -- 1410
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1410
		local ____shared_13 = shared -- 1411
		local memory = ____shared_13.memory -- 1411
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1412
		local changed = false -- 1413
		do -- 1413
			local round = 0 -- 1414
			while round < maxRounds do -- 1414
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1415
				local activeMessages = getActiveConversationMessages(shared) -- 1416
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1420
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1420
					if changed then -- 1420
						persistHistoryState(shared) -- 1429
					end -- 1429
					return ____awaiter_resolve(nil) -- 1429
				end -- 1429
				local compressionRound = round + 1 -- 1433
				shared.step = shared.step + 1 -- 1434
				local stepId = shared.step -- 1435
				local pendingMessages = #activeMessages -- 1436
				emitAgentEvent( -- 1437
					shared, -- 1437
					{ -- 1437
						type = "memory_compression_started", -- 1438
						sessionId = shared.sessionId, -- 1439
						taskId = shared.taskId, -- 1440
						step = stepId, -- 1441
						tool = "compress_memory", -- 1442
						reason = getMemoryCompressionStartReason(shared), -- 1443
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1444
					} -- 1444
				) -- 1444
				local result = __TS__Await(memory.compressor:compress( -- 1450
					activeMessages, -- 1451
					shared.llmOptions, -- 1452
					shared.llmMaxTry, -- 1453
					shared.decisionMode, -- 1454
					{ -- 1455
						onInput = function(____, phase, messages, options) -- 1456
							saveStepLLMDebugInput( -- 1457
								shared, -- 1457
								stepId, -- 1457
								phase, -- 1457
								messages, -- 1457
								options -- 1457
							) -- 1457
						end, -- 1456
						onOutput = function(____, phase, text, meta) -- 1459
							saveStepLLMDebugOutput( -- 1460
								shared, -- 1460
								stepId, -- 1460
								phase, -- 1460
								text, -- 1460
								meta -- 1460
							) -- 1460
						end -- 1459
					}, -- 1459
					"default", -- 1463
					systemPrompt, -- 1464
					toolDefinitions -- 1465
				)) -- 1465
				if not (result and result.success and result.compressedCount > 0) then -- 1465
					emitAgentEvent( -- 1468
						shared, -- 1468
						{ -- 1468
							type = "memory_compression_finished", -- 1469
							sessionId = shared.sessionId, -- 1470
							taskId = shared.taskId, -- 1471
							step = stepId, -- 1472
							tool = "compress_memory", -- 1473
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1474
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1478
						} -- 1478
					) -- 1478
					if changed then -- 1478
						persistHistoryState(shared) -- 1486
					end -- 1486
					return ____awaiter_resolve(nil) -- 1486
				end -- 1486
				local effectiveCompressedCount = math.max( -- 1490
					0, -- 1491
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1492
				) -- 1492
				if effectiveCompressedCount <= 0 then -- 1492
					if changed then -- 1492
						persistHistoryState(shared) -- 1496
					end -- 1496
					return ____awaiter_resolve(nil) -- 1496
				end -- 1496
				emitAgentEvent( -- 1500
					shared, -- 1500
					{ -- 1500
						type = "memory_compression_finished", -- 1501
						sessionId = shared.sessionId, -- 1502
						taskId = shared.taskId, -- 1503
						step = stepId, -- 1504
						tool = "compress_memory", -- 1505
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1506
						result = { -- 1507
							success = true, -- 1508
							round = compressionRound, -- 1509
							compressedCount = effectiveCompressedCount, -- 1510
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1511
						} -- 1511
					} -- 1511
				) -- 1511
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1514
				changed = true -- 1515
				Log( -- 1516
					"Info", -- 1516
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1516
				) -- 1516
				round = round + 1 -- 1414
			end -- 1414
		end -- 1414
		if changed then -- 1414
			persistHistoryState(shared) -- 1519
		end -- 1519
	end) -- 1519
end -- 1410
local function compactAllHistory(shared) -- 1523
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1523
		local ____shared_20 = shared -- 1524
		local memory = ____shared_20.memory -- 1524
		local rounds = 0 -- 1525
		local totalCompressed = 0 -- 1526
		while getActiveRealMessageCount(shared) > 0 do -- 1526
			if shared.stopToken.stopped then -- 1526
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1529
				return ____awaiter_resolve( -- 1529
					nil, -- 1529
					emitAgentTaskFinishEvent( -- 1530
						shared, -- 1530
						false, -- 1530
						getCancelledReason(shared) -- 1530
					) -- 1530
				) -- 1530
			end -- 1530
			rounds = rounds + 1 -- 1532
			shared.step = shared.step + 1 -- 1533
			local stepId = shared.step -- 1534
			local activeMessages = getActiveConversationMessages(shared) -- 1535
			local pendingMessages = #activeMessages -- 1536
			emitAgentEvent( -- 1537
				shared, -- 1537
				{ -- 1537
					type = "memory_compression_started", -- 1538
					sessionId = shared.sessionId, -- 1539
					taskId = shared.taskId, -- 1540
					step = stepId, -- 1541
					tool = "compress_memory", -- 1542
					reason = getMemoryCompressionStartReason(shared), -- 1543
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1544
				} -- 1544
			) -- 1544
			local result = __TS__Await(memory.compressor:compress( -- 1551
				activeMessages, -- 1552
				shared.llmOptions, -- 1553
				shared.llmMaxTry, -- 1554
				shared.decisionMode, -- 1555
				{ -- 1556
					onInput = function(____, phase, messages, options) -- 1557
						saveStepLLMDebugInput( -- 1558
							shared, -- 1558
							stepId, -- 1558
							phase, -- 1558
							messages, -- 1558
							options -- 1558
						) -- 1558
					end, -- 1557
					onOutput = function(____, phase, text, meta) -- 1560
						saveStepLLMDebugOutput( -- 1561
							shared, -- 1561
							stepId, -- 1561
							phase, -- 1561
							text, -- 1561
							meta -- 1561
						) -- 1561
					end -- 1560
				}, -- 1560
				"budget_max" -- 1564
			)) -- 1564
			if not (result and result.success and result.compressedCount > 0) then -- 1564
				emitAgentEvent( -- 1567
					shared, -- 1567
					{ -- 1567
						type = "memory_compression_finished", -- 1568
						sessionId = shared.sessionId, -- 1569
						taskId = shared.taskId, -- 1570
						step = stepId, -- 1571
						tool = "compress_memory", -- 1572
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1573
						result = { -- 1577
							success = false, -- 1578
							rounds = rounds, -- 1579
							error = result and result.error or "compression returned no changes", -- 1580
							compressedCount = result and result.compressedCount or 0, -- 1581
							fullCompaction = true -- 1582
						} -- 1582
					} -- 1582
				) -- 1582
				return ____awaiter_resolve( -- 1582
					nil, -- 1582
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1585
				) -- 1585
			end -- 1585
			local effectiveCompressedCount = math.max( -- 1590
				0, -- 1591
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1592
			) -- 1592
			if effectiveCompressedCount <= 0 then -- 1592
				return ____awaiter_resolve( -- 1592
					nil, -- 1592
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1595
				) -- 1595
			end -- 1595
			emitAgentEvent( -- 1602
				shared, -- 1602
				{ -- 1602
					type = "memory_compression_finished", -- 1603
					sessionId = shared.sessionId, -- 1604
					taskId = shared.taskId, -- 1605
					step = stepId, -- 1606
					tool = "compress_memory", -- 1607
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1608
					result = { -- 1609
						success = true, -- 1610
						round = rounds, -- 1611
						compressedCount = effectiveCompressedCount, -- 1612
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1613
						fullCompaction = true -- 1614
					} -- 1614
				} -- 1614
			) -- 1614
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1617
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1618
			persistHistoryState(shared) -- 1619
			Log( -- 1620
				"Info", -- 1620
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1620
			) -- 1620
		end -- 1620
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1622
		return ____awaiter_resolve( -- 1622
			nil, -- 1622
			emitAgentTaskFinishEvent( -- 1623
				shared, -- 1624
				true, -- 1625
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1626
			) -- 1626
		) -- 1626
	end) -- 1626
end -- 1523
local function clearSessionHistory(shared) -- 1632
	shared.messages = {} -- 1633
	shared.lastConsolidatedIndex = 0 -- 1634
	shared.carryMessageIndex = nil -- 1635
	persistHistoryState(shared) -- 1636
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1637
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1638
end -- 1632
local function isKnownToolName(name) -- 1647
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1648
end -- 1647
local function appendConversationMessage(shared, message) -- 1741
	local ____shared_messages_29 = shared.messages -- 1741
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1742
		{}, -- 1742
		message, -- 1743
		{ -- 1742
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1744
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1745
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1746
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1747
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1748
		} -- 1748
	) -- 1748
end -- 1741
local function ensureToolCallId(toolCallId) -- 1752
	if toolCallId and toolCallId ~= "" then -- 1752
		return toolCallId -- 1753
	end -- 1753
	return createLocalToolCallId() -- 1754
end -- 1752
local function appendToolResultMessage(shared, action) -- 1757
	appendConversationMessage( -- 1758
		shared, -- 1758
		{ -- 1758
			role = "tool", -- 1759
			tool_call_id = action.toolCallId, -- 1760
			name = action.tool, -- 1761
			content = action.result and toJson(action.result) or "" -- 1762
		} -- 1762
	) -- 1762
end -- 1757
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1766
	appendConversationMessage( -- 1772
		shared, -- 1772
		{ -- 1772
			role = "assistant", -- 1773
			content = content or "", -- 1774
			reasoning_content = reasoningContent, -- 1775
			tool_calls = __TS__ArrayMap( -- 1776
				actions, -- 1776
				function(____, action) return { -- 1776
					id = action.toolCallId, -- 1777
					type = "function", -- 1778
					["function"] = { -- 1779
						name = action.tool, -- 1780
						arguments = toJson(action.params, false) -- 1781
					} -- 1781
				} end -- 1781
			) -- 1781
		} -- 1781
	) -- 1781
end -- 1766
local function parseXMLToolCallObjectFromText(text) -- 1787
	local children = parseXMLObjectFromText(text, "tool_call") -- 1788
	if not children.success then -- 1788
		return children -- 1789
	end -- 1789
	local rawObj = children.obj -- 1790
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1791
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1792
	if not params.success then -- 1792
		return {success = false, message = params.message} -- 1796
	end -- 1796
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1798
end -- 1787
local function llm(shared, messages, phase) -- 1818
	if phase == nil then -- 1818
		phase = "decision_xml" -- 1821
	end -- 1821
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1821
		local stepId = shared.step + 1 -- 1823
		emitLLMContextMetrics( -- 1824
			shared, -- 1824
			stepId, -- 1824
			phase, -- 1824
			messages, -- 1824
			shared.llmOptions -- 1824
		) -- 1824
		saveStepLLMDebugInput( -- 1825
			shared, -- 1825
			stepId, -- 1825
			phase, -- 1825
			messages, -- 1825
			shared.llmOptions -- 1825
		) -- 1825
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1826
		if res.success then -- 1826
			local ____opt_32 = res.response.choices -- 1826
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1826
			local message = ____opt_30 and ____opt_30.message -- 1828
			local text = message and message.content -- 1829
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1830
			if text then -- 1830
				saveStepLLMDebugOutput( -- 1834
					shared, -- 1834
					stepId, -- 1834
					phase, -- 1834
					text, -- 1834
					{success = true} -- 1834
				) -- 1834
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1834
			else -- 1834
				saveStepLLMDebugOutput( -- 1837
					shared, -- 1837
					stepId, -- 1837
					phase, -- 1837
					"empty LLM response", -- 1837
					{success = false} -- 1837
				) -- 1837
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1837
			end -- 1837
		else -- 1837
			saveStepLLMDebugOutput( -- 1841
				shared, -- 1841
				stepId, -- 1841
				phase, -- 1841
				res.raw or res.message, -- 1841
				{success = false} -- 1841
			) -- 1841
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1841
		end -- 1841
	end) -- 1841
end -- 1818
local function isDecisionBatchSuccess(result) -- 1865
	return result.kind == "batch" -- 1866
end -- 1865
local function parseDecisionObject(rawObj) -- 1869
	if type(rawObj.tool) ~= "string" then -- 1869
		return {success = false, message = "missing tool"} -- 1870
	end -- 1870
	local tool = rawObj.tool -- 1871
	if not isKnownToolName(tool) then -- 1871
		return {success = false, message = "unknown tool: " .. tool} -- 1873
	end -- 1873
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1875
	if tool ~= "finish" and (not reason or reason == "") then -- 1875
		return {success = false, message = tool .. " requires top-level reason"} -- 1879
	end -- 1879
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1881
	return {success = true, tool = tool, params = params, reason = reason} -- 1882
end -- 1869
local function parseDecisionToolCall(functionName, rawObj) -- 1890
	if not isKnownToolName(functionName) then -- 1890
		return {success = false, message = "unknown tool: " .. functionName} -- 1892
	end -- 1892
	if rawObj == nil or rawObj == nil then -- 1892
		return {success = true, tool = functionName, params = {}} -- 1895
	end -- 1895
	if not isRecord(rawObj) then -- 1895
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1898
	end -- 1898
	return {success = true, tool = functionName, params = rawObj} -- 1900
end -- 1890
local function parseToolCallArguments(functionName, argsText) -- 1907
	local trimmedArgs = __TS__StringTrim(argsText) -- 1908
	if trimmedArgs == "" then -- 1908
		return {} -- 1910
	end -- 1910
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1912
	if err ~= nil or rawObj == nil then -- 1912
		return { -- 1914
			success = false, -- 1915
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1916
			raw = argsText -- 1917
		} -- 1917
	end -- 1917
	local encodedRaw = safeJsonEncode(rawObj) -- 1920
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1920
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1922
	end -- 1922
	return rawObj -- 1928
end -- 1907
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1931
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1939
	if isRecord(rawArgs) and rawArgs.success == false then -- 1939
		return rawArgs -- 1941
	end -- 1941
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1943
	if not decision.success then -- 1943
		return {success = false, message = decision.message, raw = argsText} -- 1945
	end -- 1945
	local validation = validateDecision(decision.tool, decision.params) -- 1951
	if not validation.success then -- 1951
		return {success = false, message = validation.message, raw = argsText} -- 1953
	end -- 1953
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1953
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1960
	end -- 1960
	decision.params = validation.params -- 1966
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1967
	decision.reason = reason -- 1968
	decision.reasoningContent = reasoningContent -- 1969
	return decision -- 1970
end -- 1931
local function createPreExecutableActionFromStream(shared, toolCall) -- 1973
	local ____opt_38 = toolCall["function"] -- 1973
	local functionName = ____opt_38 and ____opt_38.name -- 1974
	local ____opt_40 = toolCall["function"] -- 1974
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1975
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1976
	if not functionName or not toolCallId then -- 1976
		return nil -- 1977
	end -- 1977
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1978
	if isRecord(rawArgs) and rawArgs.success == false then -- 1978
		return nil -- 1979
	end -- 1979
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1980
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1980
		return nil -- 1981
	end -- 1981
	local validation = validateDecision(decision.tool, decision.params) -- 1982
	if not validation.success then -- 1982
		return nil -- 1983
	end -- 1983
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1983
		return nil -- 1984
	end -- 1984
	return { -- 1985
		step = shared.step + 1, -- 1986
		toolCallId = toolCallId, -- 1987
		tool = decision.tool, -- 1988
		reason = "", -- 1989
		params = validation.params, -- 1990
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1991
	} -- 1991
end -- 1973
local function createFunctionToolSchema(name, description, properties, required) -- 2131
	if required == nil then -- 2131
		required = {} -- 2135
	end -- 2135
	local parameters = {type = "object", properties = properties} -- 2137
	if #required > 0 then -- 2137
		parameters.required = required -- 2142
	end -- 2142
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2144
end -- 2131
local function buildDecisionToolSchema(shared) -- 2160
	local allowed = getAllowedToolsForRole(shared.role) -- 2161
	local tools = { -- 2162
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2163
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2173
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2183
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2191
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2195
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2196
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2197
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2198
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2199
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2200
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2201
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2202
		}, {"pattern"}), -- 2202
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2206
		createFunctionToolSchema( -- 2215
			"search_dora_api", -- 2216
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2216
			{ -- 2218
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2219
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2220
				programmingLanguage = {type = "string", enum = { -- 2221
					"ts", -- 2223
					"tsx", -- 2223
					"lua", -- 2223
					"yue", -- 2223
					"teal", -- 2223
					"tl", -- 2223
					"wa" -- 2223
				}, description = "Preferred language variant to search."}, -- 2223
				limit = { -- 2226
					type = "number", -- 2226
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2226
				}, -- 2226
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2227
			}, -- 2227
			{"pattern"} -- 2229
		), -- 2229
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2231
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2238
			"active_or_recent", -- 2242
			"running", -- 2242
			"done", -- 2242
			"failed", -- 2242
			"all" -- 2242
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2242
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2248
	} -- 2248
	return __TS__ArrayFilter( -- 2260
		tools, -- 2260
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2260
	) -- 2260
end -- 2160
local function sanitizeMessagesForLLMInput(messages) -- 2301
	local function sanitizeAssistantToolCalls(message) -- 2302
		local toolCalls = message.tool_calls -- 2303
		if not toolCalls or #toolCalls == 0 then -- 2303
			return message -- 2304
		end -- 2304
		local changed = false -- 2305
		local sanitizedToolCalls = __TS__ArrayMap( -- 2306
			toolCalls, -- 2306
			function(____, toolCall) -- 2306
				local fn = toolCall["function"] or ({}) -- 2307
				local raw = type(fn.arguments) == "string" and __TS__StringTrim(fn.arguments) or "" -- 2308
				local safeArguments = "{}" -- 2309
				if raw ~= "" then -- 2309
					local decoded, err = safeJsonDecode(raw) -- 2311
					local encodedRaw = nil -- 2312
					if err == nil and decoded ~= nil then -- 2312
						encodedRaw = safeJsonEncode(decoded, false, false) -- 2314
					end -- 2314
					if encodedRaw ~= nil and encodedRaw ~= "null" and __TS__StringAccess(raw, 0) ~= "[" and not __TS__ArrayIsArray(decoded) and decoded ~= nil and type(decoded) == "table" then -- 2314
						safeArguments = encodedRaw -- 2324
					else -- 2324
						changed = true -- 2326
						Log("Warn", "[CodingAgent] replacing invalid historical tool-call arguments with {}") -- 2327
					end -- 2327
				end -- 2327
				if toolCall.type ~= "function" or toolCall["function"] == nil or fn.arguments ~= safeArguments then -- 2327
					changed = true -- 2335
				end -- 2335
				return __TS__ObjectAssign( -- 2337
					{}, -- 2337
					toolCall, -- 2338
					{ -- 2337
						type = "function", -- 2339
						["function"] = __TS__ObjectAssign({}, fn, {arguments = safeArguments}) -- 2340
					} -- 2340
				) -- 2340
			end -- 2306
		) -- 2306
		if not changed then -- 2306
			return message -- 2346
		end -- 2346
		return __TS__ObjectAssign({}, message, {tool_calls = sanitizedToolCalls}) -- 2347
	end -- 2302
	local sanitized = {} -- 2353
	local droppedAssistantToolCalls = 0 -- 2354
	local droppedToolResults = 0 -- 2355
	do -- 2355
		local i = 0 -- 2356
		while i < #messages do -- 2356
			do -- 2356
				local message = messages[i + 1] -- 2357
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2357
					local requiredIds = {} -- 2359
					do -- 2359
						local j = 0 -- 2360
						while j < #message.tool_calls do -- 2360
							local toolCall = message.tool_calls[j + 1] -- 2361
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2362
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2362
								requiredIds[#requiredIds + 1] = id -- 2364
							end -- 2364
							j = j + 1 -- 2360
						end -- 2360
					end -- 2360
					if #requiredIds == 0 then -- 2360
						sanitized[#sanitized + 1] = sanitizeAssistantToolCalls(message) -- 2368
						goto __continue372 -- 2369
					end -- 2369
					local matchedIds = {} -- 2371
					local matchedTools = {} -- 2372
					local j = i + 1 -- 2373
					while j < #messages do -- 2373
						local toolMessage = messages[j + 1] -- 2375
						if toolMessage.role ~= "tool" then -- 2375
							break -- 2376
						end -- 2376
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2377
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2377
							matchedIds[toolCallId] = true -- 2379
							matchedTools[#matchedTools + 1] = toolMessage -- 2380
						else -- 2380
							droppedToolResults = droppedToolResults + 1 -- 2382
						end -- 2382
						j = j + 1 -- 2384
					end -- 2384
					local complete = true -- 2386
					do -- 2386
						local j = 0 -- 2387
						while j < #requiredIds do -- 2387
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2387
								complete = false -- 2389
								break -- 2390
							end -- 2390
							j = j + 1 -- 2387
						end -- 2387
					end -- 2387
					if complete then -- 2387
						__TS__ArrayPush( -- 2394
							sanitized, -- 2394
							sanitizeAssistantToolCalls(message), -- 2394
							table.unpack(matchedTools) -- 2394
						) -- 2394
					else -- 2394
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2396
						droppedToolResults = droppedToolResults + #matchedTools -- 2397
					end -- 2397
					i = j - 1 -- 2399
					goto __continue372 -- 2400
				end -- 2400
				if message.role == "tool" then -- 2400
					droppedToolResults = droppedToolResults + 1 -- 2403
					goto __continue372 -- 2404
				end -- 2404
				sanitized[#sanitized + 1] = message -- 2406
			end -- 2406
			::__continue372:: -- 2406
			i = i + 1 -- 2356
		end -- 2356
	end -- 2356
	return sanitized -- 2408
end -- 2301
local function getUnconsolidatedMessages(shared) -- 2411
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2412
end -- 2411
local function getFinalDecisionTurnPrompt(shared) -- 2415
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2416
end -- 2415
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2421
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2421
		return messages -- 2422
	end -- 2422
	local next = __TS__ArrayMap( -- 2423
		messages, -- 2423
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2423
	) -- 2423
	do -- 2423
		local i = #next - 1 -- 2424
		while i >= 0 do -- 2424
			do -- 2424
				local message = next[i + 1] -- 2425
				if message.role ~= "assistant" and message.role ~= "user" then -- 2425
					goto __continue394 -- 2426
				end -- 2426
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2427
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2428
				return next -- 2431
			end -- 2431
			::__continue394:: -- 2431
			i = i - 1 -- 2424
		end -- 2424
	end -- 2424
	next[#next + 1] = {role = "user", content = prompt} -- 2433
	return next -- 2434
end -- 2421
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2437
	if attempt == nil then -- 2437
		attempt = 1 -- 2440
	end -- 2440
	if decisionMode == nil then -- 2440
		decisionMode = shared.decisionMode -- 2442
	end -- 2442
	local messages = { -- 2444
		{ -- 2445
			role = "system", -- 2445
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2445
		}, -- 2445
		table.unpack(getUnconsolidatedMessages(shared)) -- 2446
	} -- 2446
	if shared.step + 1 >= shared.maxSteps then -- 2446
		messages = appendPromptToLatestDecisionMessage( -- 2449
			messages, -- 2449
			getFinalDecisionTurnPrompt(shared) -- 2449
		) -- 2449
	end -- 2449
	if lastError and lastError ~= "" then -- 2449
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2452
		messages[#messages + 1] = { -- 2455
			role = "user", -- 2456
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2457
		} -- 2457
	end -- 2457
	return messages -- 2464
end -- 2437
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2471
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2478
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2479
	local repairPrompt = replacePromptVars( -- 2487
		shared.promptPack.xmlDecisionRepairPrompt, -- 2487
		{ -- 2487
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2488
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2489
			CANDIDATE_SECTION = candidateSection, -- 2490
			LAST_ERROR = lastError, -- 2491
			ATTEMPT = tostring(attempt) -- 2492
		} -- 2492
	) -- 2492
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2494
end -- 2471
local function tryParseAndValidateDecision(rawText) -- 2506
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2507
	if not parsed.success then -- 2507
		return {success = false, message = parsed.message, raw = rawText} -- 2509
	end -- 2509
	local decision = parseDecisionObject(parsed.obj) -- 2511
	if not decision.success then -- 2511
		return {success = false, message = decision.message, raw = rawText} -- 2513
	end -- 2513
	local validation = validateDecision(decision.tool, decision.params) -- 2515
	if not validation.success then -- 2515
		return {success = false, message = validation.message, raw = rawText} -- 2517
	end -- 2517
	decision.params = validation.params -- 2519
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2520
	return decision -- 2521
end -- 2506
local function normalizeLineEndings(text) -- 2524
	local res = string.gsub(text, "\r\n", "\n") -- 2525
	res = string.gsub(res, "\r", "\n") -- 2526
	return res -- 2527
end -- 2524
local function countOccurrences(text, searchStr) -- 2530
	if searchStr == "" then -- 2530
		return 0 -- 2531
	end -- 2531
	local count = 0 -- 2532
	local pos = 0 -- 2533
	while true do -- 2533
		local idx = (string.find( -- 2535
			text, -- 2535
			searchStr, -- 2535
			math.max(pos + 1, 1), -- 2535
			true -- 2535
		) or 0) - 1 -- 2535
		if idx < 0 then -- 2535
			break -- 2536
		end -- 2536
		count = count + 1 -- 2537
		pos = idx + #searchStr -- 2538
	end -- 2538
	return count -- 2540
end -- 2530
local function replaceFirst(text, oldStr, newStr) -- 2543
	if oldStr == "" then -- 2543
		return text -- 2544
	end -- 2544
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2545
	if idx < 0 then -- 2545
		return text -- 2546
	end -- 2546
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2547
end -- 2543
local function splitLines(text) -- 2550
	return __TS__StringSplit(text, "\n") -- 2551
end -- 2550
local function getLeadingWhitespace(text) -- 2554
	local i = 0 -- 2555
	while i < #text do -- 2555
		local ch = __TS__StringAccess(text, i) -- 2557
		if ch ~= " " and ch ~= "\t" then -- 2557
			break -- 2558
		end -- 2558
		i = i + 1 -- 2559
	end -- 2559
	return __TS__StringSubstring(text, 0, i) -- 2561
end -- 2554
local function getCommonIndentPrefix(lines) -- 2564
	local common -- 2565
	do -- 2565
		local i = 0 -- 2566
		while i < #lines do -- 2566
			do -- 2566
				local line = lines[i + 1] -- 2567
				if __TS__StringTrim(line) == "" then -- 2567
					goto __continue419 -- 2568
				end -- 2568
				local indent = getLeadingWhitespace(line) -- 2569
				if common == nil then -- 2569
					common = indent -- 2571
					goto __continue419 -- 2572
				end -- 2572
				local j = 0 -- 2574
				local maxLen = math.min(#common, #indent) -- 2575
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2575
					j = j + 1 -- 2577
				end -- 2577
				common = __TS__StringSubstring(common, 0, j) -- 2579
				if common == "" then -- 2579
					break -- 2580
				end -- 2580
			end -- 2580
			::__continue419:: -- 2580
			i = i + 1 -- 2566
		end -- 2566
	end -- 2566
	return common or "" -- 2582
end -- 2564
local function removeIndentPrefix(line, indent) -- 2585
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2585
		return __TS__StringSubstring(line, #indent) -- 2587
	end -- 2587
	local lineIndent = getLeadingWhitespace(line) -- 2589
	local j = 0 -- 2590
	local maxLen = math.min(#lineIndent, #indent) -- 2591
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2591
		j = j + 1 -- 2593
	end -- 2593
	return __TS__StringSubstring(line, j) -- 2595
end -- 2585
local function dedentLines(lines) -- 2598
	local indent = getCommonIndentPrefix(lines) -- 2599
	return { -- 2600
		indent = indent, -- 2601
		lines = __TS__ArrayMap( -- 2602
			lines, -- 2602
			function(____, line) return removeIndentPrefix(line, indent) end -- 2602
		) -- 2602
	} -- 2602
end -- 2598
local function joinLines(lines) -- 2606
	return table.concat(lines, "\n") -- 2607
end -- 2606
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2610
	local contentLines = splitLines(content) -- 2615
	local oldLines = splitLines(oldStr) -- 2616
	if #oldLines == 0 then -- 2616
		return {success = false, message = "old_str not found in file"} -- 2618
	end -- 2618
	local dedentedOld = dedentLines(oldLines) -- 2620
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2621
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2622
	local matches = {} -- 2623
	do -- 2623
		local start = 0 -- 2624
		while start <= #contentLines - #oldLines do -- 2624
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2625
			local dedentedCandidate = dedentLines(candidateLines) -- 2626
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2626
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2628
			end -- 2628
			start = start + 1 -- 2624
		end -- 2624
	end -- 2624
	if #matches == 0 then -- 2624
		return {success = false, message = "old_str not found in file"} -- 2636
	end -- 2636
	if #matches > 1 then -- 2636
		return { -- 2639
			success = false, -- 2640
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2641
		} -- 2641
	end -- 2641
	local match = matches[1] -- 2644
	local rebuiltNewLines = __TS__ArrayMap( -- 2645
		dedentedNew.lines, -- 2645
		function(____, line) return line == "" and "" or match.indent .. line end -- 2645
	) -- 2645
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2645
	__TS__SparseArrayPush( -- 2645
		____array_46, -- 2645
		table.unpack(rebuiltNewLines) -- 2648
	) -- 2648
	__TS__SparseArrayPush( -- 2648
		____array_46, -- 2648
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2649
	) -- 2649
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2646
	return { -- 2651
		success = true, -- 2651
		content = joinLines(nextLines) -- 2651
	} -- 2651
end -- 2610
local MainDecisionAgent = __TS__Class() -- 2654
MainDecisionAgent.name = "MainDecisionAgent" -- 2654
__TS__ClassExtends(MainDecisionAgent, Node) -- 2654
function MainDecisionAgent.prototype.prep(self, shared) -- 2655
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2655
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2655
			return ____awaiter_resolve(nil, {shared = shared}) -- 2655
		end -- 2655
		__TS__Await(maybeCompressHistory(shared)) -- 2660
		return ____awaiter_resolve(nil, {shared = shared}) -- 2660
	end) -- 2660
end -- 2655
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2665
	if attempt == nil then -- 2665
		attempt = 1 -- 2668
	end -- 2668
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2668
		if shared.stopToken.stopped then -- 2668
			return ____awaiter_resolve( -- 2668
				nil, -- 2668
				{ -- 2672
					success = false, -- 2672
					message = getCancelledReason(shared) -- 2672
				} -- 2672
			) -- 2672
		end -- 2672
		Log( -- 2674
			"Info", -- 2674
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2674
		) -- 2674
		local tools = buildDecisionToolSchema(shared) -- 2675
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2676
		local stepId = shared.step + 1 -- 2677
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2678
		emitLLMContextMetrics( -- 2682
			shared, -- 2682
			stepId, -- 2682
			"decision_tool_calling", -- 2682
			messages, -- 2682
			llmOptions -- 2682
		) -- 2682
		saveStepLLMDebugInput( -- 2683
			shared, -- 2683
			stepId, -- 2683
			"decision_tool_calling", -- 2683
			messages, -- 2683
			llmOptions -- 2683
		) -- 2683
		local lastStreamContent = "" -- 2684
		local lastStreamReasoning = "" -- 2685
		local preExecutedResults = __TS__New(Map) -- 2686
		shared.preExecutedResults = preExecutedResults -- 2687
		local res = __TS__Await(callLLMStreamAggregated( -- 2688
			messages, -- 2689
			llmOptions, -- 2690
			shared.stopToken, -- 2691
			shared.llmConfig, -- 2692
			function(response) -- 2693
				local ____opt_49 = response.choices -- 2693
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2693
				local streamMessage = ____opt_47 and ____opt_47.message -- 2694
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2695
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2698
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2698
					return -- 2702
				end -- 2702
				lastStreamContent = nextContent -- 2704
				lastStreamReasoning = nextReasoning -- 2705
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2706
			end, -- 2693
			function(tc) -- 2708
				if shared.stopToken.stopped then -- 2708
					return -- 2709
				end -- 2709
				local action = createPreExecutableActionFromStream(shared, tc) -- 2710
				if not action or preExecutedResults:has(action.toolCallId) then -- 2710
					return -- 2711
				end -- 2711
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2712
				preExecutedResults:set( -- 2713
					action.toolCallId, -- 2713
					createPreExecutedToolResult(shared, action) -- 2713
				) -- 2713
			end -- 2708
		)) -- 2708
		if shared.stopToken.stopped then -- 2708
			clearPreExecutedResults(shared) -- 2717
			return ____awaiter_resolve( -- 2717
				nil, -- 2717
				{ -- 2718
					success = false, -- 2718
					message = getCancelledReason(shared) -- 2718
				} -- 2718
			) -- 2718
		end -- 2718
		if not res.success then -- 2718
			saveStepLLMDebugOutput( -- 2721
				shared, -- 2721
				stepId, -- 2721
				"decision_tool_calling", -- 2721
				res.raw or res.message, -- 2721
				{success = false} -- 2721
			) -- 2721
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2722
			clearPreExecutedResults(shared) -- 2723
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2723
		end -- 2723
		saveStepLLMDebugOutput( -- 2726
			shared, -- 2726
			stepId, -- 2726
			"decision_tool_calling", -- 2726
			encodeDebugJSON(res.response), -- 2726
			{success = true} -- 2726
		) -- 2726
		local choice = res.response.choices and res.response.choices[1] -- 2727
		local message = choice and choice.message -- 2728
		local toolCalls = message and message.tool_calls -- 2729
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2730
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2733
		Log( -- 2736
			"Info", -- 2736
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2736
		) -- 2736
		if not toolCalls or #toolCalls == 0 then -- 2736
			if messageContent and messageContent ~= "" then -- 2736
				Log( -- 2739
					"Info", -- 2739
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2739
				) -- 2739
				clearPreExecutedResults(shared) -- 2740
				return ____awaiter_resolve(nil, { -- 2740
					success = true, -- 2742
					tool = "finish", -- 2743
					params = {}, -- 2744
					reason = messageContent, -- 2745
					reasoningContent = reasoningContent, -- 2746
					directSummary = messageContent -- 2747
				}) -- 2747
			end -- 2747
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2750
			clearPreExecutedResults(shared) -- 2751
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2751
		end -- 2751
		local decisions = {} -- 2758
		do -- 2758
			local i = 0 -- 2759
			while i < #toolCalls do -- 2759
				local toolCall = toolCalls[i + 1] -- 2760
				local fn = toolCall and toolCall["function"] -- 2761
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2761
					Log( -- 2763
						"Error", -- 2763
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2763
					) -- 2763
					clearPreExecutedResults(shared) -- 2764
					return ____awaiter_resolve( -- 2764
						nil, -- 2764
						{ -- 2765
							success = false, -- 2766
							message = "missing function name for tool call " .. tostring(i + 1), -- 2767
							raw = messageContent -- 2768
						} -- 2768
					) -- 2768
				end -- 2768
				local functionName = fn.name -- 2771
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2772
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2773
				Log( -- 2776
					"Info", -- 2776
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2776
				) -- 2776
				local decision = parseAndValidateToolCallDecision( -- 2777
					shared, -- 2778
					functionName, -- 2779
					argsText, -- 2780
					toolCallId, -- 2781
					messageContent, -- 2782
					reasoningContent -- 2783
				) -- 2783
				if not decision.success then -- 2783
					Log( -- 2786
						"Error", -- 2786
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2786
					) -- 2786
					clearPreExecutedResults(shared) -- 2787
					return ____awaiter_resolve(nil, decision) -- 2787
				end -- 2787
				decisions[#decisions + 1] = decision -- 2790
				i = i + 1 -- 2759
			end -- 2759
		end -- 2759
		if #decisions == 1 then -- 2759
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2793
			return ____awaiter_resolve(nil, decisions[1]) -- 2793
		end -- 2793
		do -- 2793
			local i = 0 -- 2796
			while i < #decisions do -- 2796
				if decisions[i + 1].tool == "finish" then -- 2796
					clearPreExecutedResults(shared) -- 2798
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2798
				end -- 2798
				i = i + 1 -- 2796
			end -- 2796
		end -- 2796
		Log( -- 2806
			"Info", -- 2806
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2806
				__TS__ArrayMap( -- 2806
					decisions, -- 2806
					function(____, decision) return decision.tool end -- 2806
				), -- 2806
				"," -- 2806
			) -- 2806
		) -- 2806
		return ____awaiter_resolve(nil, { -- 2806
			success = true, -- 2808
			kind = "batch", -- 2809
			decisions = decisions, -- 2810
			content = messageContent, -- 2811
			reasoningContent = reasoningContent -- 2812
		}) -- 2812
	end) -- 2812
end -- 2665
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2816
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2816
		Log( -- 2821
			"Info", -- 2821
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2821
		) -- 2821
		local lastError = initialError -- 2822
		local candidateRaw = "" -- 2823
		do -- 2823
			local attempt = 0 -- 2824
			while attempt < shared.llmMaxTry do -- 2824
				do -- 2824
					Log( -- 2825
						"Info", -- 2825
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2825
					) -- 2825
					local messages = buildXmlRepairMessages( -- 2826
						shared, -- 2827
						originalRaw, -- 2828
						candidateRaw, -- 2829
						lastError, -- 2830
						attempt + 1 -- 2831
					) -- 2831
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2833
					if shared.stopToken.stopped then -- 2833
						return ____awaiter_resolve( -- 2833
							nil, -- 2833
							{ -- 2835
								success = false, -- 2835
								message = getCancelledReason(shared) -- 2835
							} -- 2835
						) -- 2835
					end -- 2835
					if not llmRes.success then -- 2835
						lastError = llmRes.message -- 2838
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2839
						goto __continue462 -- 2840
					end -- 2840
					candidateRaw = llmRes.text -- 2842
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2843
					if decision.success then -- 2843
						decision.reasoningContent = llmRes.reasoningContent -- 2845
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2846
						return ____awaiter_resolve(nil, decision) -- 2846
					end -- 2846
					lastError = decision.message -- 2849
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2850
				end -- 2850
				::__continue462:: -- 2850
				attempt = attempt + 1 -- 2824
			end -- 2824
		end -- 2824
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2852
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2852
	end) -- 2852
end -- 2816
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2860
	if attempt == nil then -- 2860
		attempt = 1 -- 2863
	end -- 2863
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2863
		local messages = buildDecisionMessages( -- 2866
			shared, -- 2867
			lastError, -- 2868
			attempt, -- 2869
			lastRaw, -- 2870
			"xml" -- 2871
		) -- 2871
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2873
		if shared.stopToken.stopped then -- 2873
			return ____awaiter_resolve( -- 2873
				nil, -- 2873
				{ -- 2875
					success = false, -- 2875
					message = getCancelledReason(shared) -- 2875
				} -- 2875
			) -- 2875
		end -- 2875
		if not llmRes.success then -- 2875
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2875
		end -- 2875
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2884
		if decision.success then -- 2884
			decision.reasoningContent = llmRes.reasoningContent -- 2886
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2886
				return ____awaiter_resolve( -- 2886
					nil, -- 2886
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2888
				) -- 2888
			end -- 2888
			return ____awaiter_resolve(nil, decision) -- 2888
		end -- 2888
		return ____awaiter_resolve( -- 2888
			nil, -- 2888
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2896
		) -- 2896
	end) -- 2896
end -- 2860
function MainDecisionAgent.prototype.exec(self, input) -- 2899
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2899
		local shared = input.shared -- 2900
		if shared.stopToken.stopped then -- 2900
			return ____awaiter_resolve( -- 2900
				nil, -- 2900
				{ -- 2902
					success = false, -- 2902
					message = getCancelledReason(shared) -- 2902
				} -- 2902
			) -- 2902
		end -- 2902
		if shared.step >= shared.maxSteps then -- 2902
			Log( -- 2905
				"Warn", -- 2905
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2905
			) -- 2905
			return ____awaiter_resolve( -- 2905
				nil, -- 2905
				{ -- 2906
					success = false, -- 2906
					message = getMaxStepsReachedReason(shared) -- 2906
				} -- 2906
			) -- 2906
		end -- 2906
		if shared.decisionMode == "tool_calling" then -- 2906
			Log( -- 2910
				"Info", -- 2910
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2910
			) -- 2910
			local function containsAnyText(text, needles) -- 2911
				do -- 2911
					local i = 0 -- 2912
					while i < #needles do -- 2912
						if (string.find(text, needles[i + 1], nil, true) or 0) - 1 >= 0 then -- 2912
							return true -- 2913
						end -- 2913
						i = i + 1 -- 2912
					end -- 2912
				end -- 2912
				return false -- 2915
			end -- 2911
			local function shouldFallbackToolCallingToXml(message, raw) -- 2917
				local text = string.lower(((message or "") .. "\n") .. (raw or "")) -- 2918
				if (string.find(text, "missing tool call", nil, true) or 0) - 1 >= 0 then -- 2918
					return true -- 2919
				end -- 2919
				if containsAnyText(text, { -- 2919
					"cancelled", -- 2921
					"canceled", -- 2922
					"stopped", -- 2923
					"no active llm config", -- 2924
					"unauthorized", -- 2925
					"authentication", -- 2926
					"invalid api key", -- 2927
					"api key", -- 2928
					"forbidden", -- 2929
					"permission denied", -- 2930
					"insufficient_quota", -- 2931
					"quota", -- 2932
					"billing", -- 2933
					"balance", -- 2934
					"rate limit", -- 2935
					"too many requests", -- 2936
					"context length", -- 2937
					"context_length", -- 2938
					"maximum context", -- 2939
					"max context", -- 2940
					"token limit", -- 2941
					"too many tokens", -- 2942
					"input is too long", -- 2943
					"invalid model", -- 2944
					"model_not_found", -- 2945
					"model not found", -- 2946
					"not supported model" -- 2947
				}) then -- 2947
					return false -- 2949
				end -- 2949
				if (string.find(text, "can only get item pairs from a mapping", nil, true) or 0) - 1 >= 0 or (string.find(text, "item pairs from a mapping", nil, true) or 0) - 1 >= 0 then -- 2949
					return true -- 2955
				end -- 2955
				if containsAnyText(text, { -- 2955
					"tool_choice", -- 2958
					"tool_calls", -- 2959
					"tool call", -- 2960
					"function calling", -- 2961
					"function_call", -- 2962
					"parallel_tool_calls", -- 2963
					"unsupported tool", -- 2964
					"tools are not supported", -- 2965
					"does not support tools", -- 2966
					"doesn't support tools", -- 2967
					"does not support function", -- 2968
					"doesn't support function", -- 2969
					"unsupported parameter: tools", -- 2970
					"unsupported parameter: tool_choice", -- 2971
					"unknown parameter: tools", -- 2972
					"unknown parameter: tool_choice", -- 2973
					"unrecognized request argument supplied: tools", -- 2974
					"unrecognized request argument supplied: tool_choice" -- 2975
				}) then -- 2975
					return true -- 2977
				end -- 2977
				return containsAnyText(text, { -- 2979
					"llm returned no choices", -- 2980
					"internalservererror", -- 2981
					"internal server error", -- 2982
					"/500", -- 2983
					" 500" -- 2984
				}) -- 2984
			end -- 2917
			local lastError = "tool calling validation failed" -- 2987
			local lastRaw = "" -- 2988
			local shouldFallbackToXml = false -- 2989
			do -- 2989
				local attempt = 0 -- 2990
				while attempt < shared.llmMaxTry do -- 2990
					Log( -- 2991
						"Info", -- 2991
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2991
					) -- 2991
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2992
					if shared.stopToken.stopped then -- 2992
						return ____awaiter_resolve( -- 2992
							nil, -- 2992
							{ -- 2999
								success = false, -- 2999
								message = getCancelledReason(shared) -- 2999
							} -- 2999
						) -- 2999
					end -- 2999
					if decision.success then -- 2999
						return ____awaiter_resolve(nil, decision) -- 2999
					end -- 2999
					lastError = decision.message -- 3004
					lastRaw = decision.raw or "" -- 3005
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3006
					if shouldFallbackToolCallingToXml(lastError, lastRaw) then -- 3006
						shouldFallbackToXml = true -- 3008
						break -- 3009
					end -- 3009
					attempt = attempt + 1 -- 2990
				end -- 2990
			end -- 2990
			if shouldFallbackToXml then -- 2990
				local xmlFallbackPrompt = (string.find(lastError, "missing tool call", nil, true) or 0) - 1 >= 0 and "tool-calling returned no tool calls. Use XML decision format instead. Return exactly one valid XML tool_call block." or ("tool-calling provider/function-call format failed (" .. truncateText(lastError, 220)) .. "). Use XML decision format instead. Return exactly one valid XML tool_call block." -- 3013
				Log("Warn", "[CodingAgent] tool-calling fallback to XML decision format: " .. lastError) -- 3016
				lastError = xmlFallbackPrompt -- 3017
				do -- 3017
					local attempt = 0 -- 3018
					while attempt < shared.llmMaxTry do -- 3018
						Log( -- 3019
							"Info", -- 3019
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3019
						) -- 3019
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or xmlFallbackPrompt, attempt + 1, lastRaw)) -- 3020
						if shared.stopToken.stopped then -- 3020
							return ____awaiter_resolve( -- 3020
								nil, -- 3020
								{ -- 3027
									success = false, -- 3027
									message = getCancelledReason(shared) -- 3027
								} -- 3027
							) -- 3027
						end -- 3027
						if decision.success then -- 3027
							return ____awaiter_resolve(nil, decision) -- 3027
						end -- 3027
						lastError = decision.message -- 3032
						lastRaw = decision.raw or "" -- 3033
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3034
						attempt = attempt + 1 -- 3018
					end -- 3018
				end -- 3018
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3036
				return ____awaiter_resolve( -- 3036
					nil, -- 3036
					{ -- 3037
						success = false, -- 3037
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3037
					} -- 3037
				) -- 3037
			end -- 3037
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3039
			return ____awaiter_resolve( -- 3039
				nil, -- 3039
				{ -- 3040
					success = false, -- 3040
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3040
				} -- 3040
			) -- 3040
		end -- 3040
		local lastError = "xml validation failed" -- 3043
		local lastRaw = "" -- 3044
		do -- 3044
			local attempt = 0 -- 3045
			while attempt < shared.llmMaxTry do -- 3045
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3046
				if shared.stopToken.stopped then -- 3046
					return ____awaiter_resolve( -- 3046
						nil, -- 3046
						{ -- 3055
							success = false, -- 3055
							message = getCancelledReason(shared) -- 3055
						} -- 3055
					) -- 3055
				end -- 3055
				if decision.success then -- 3055
					return ____awaiter_resolve(nil, decision) -- 3055
				end -- 3055
				lastError = decision.message -- 3060
				lastRaw = decision.raw or "" -- 3061
				attempt = attempt + 1 -- 3045
			end -- 3045
		end -- 3045
		return ____awaiter_resolve( -- 3045
			nil, -- 3045
			{ -- 3063
				success = false, -- 3063
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3063
			} -- 3063
		) -- 3063
	end) -- 3063
end -- 2899
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3066
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3066
		local result = execRes -- 3067
		if not result.success then -- 3067
			if shared.stopToken.stopped then -- 3067
				shared.error = getCancelledReason(shared) -- 3070
				shared.done = true -- 3071
				return ____awaiter_resolve(nil, "done") -- 3071
			end -- 3071
			shared.error = result.message -- 3074
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3075
			shared.done = true -- 3076
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3077
			persistHistoryState(shared) -- 3081
			return ____awaiter_resolve(nil, "done") -- 3081
		end -- 3081
		if isDecisionBatchSuccess(result) then -- 3081
			local startStep = shared.step -- 3085
			local actions = {} -- 3086
			do -- 3086
				local i = 0 -- 3087
				while i < #result.decisions do -- 3087
					local decision = result.decisions[i + 1] -- 3088
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3089
					local step = startStep + i + 1 -- 3090
					local ____temp_55 -- 3091
					if i == 0 then -- 3091
						____temp_55 = decision.reason -- 3091
					else -- 3091
						____temp_55 = "" -- 3091
					end -- 3091
					local actionReason = ____temp_55 -- 3091
					local ____temp_56 -- 3092
					if i == 0 then -- 3092
						____temp_56 = decision.reasoningContent -- 3092
					else -- 3092
						____temp_56 = nil -- 3092
					end -- 3092
					local actionReasoningContent = ____temp_56 -- 3092
					emitAgentEvent(shared, { -- 3093
						type = "decision_made", -- 3094
						sessionId = shared.sessionId, -- 3095
						taskId = shared.taskId, -- 3096
						step = step, -- 3097
						tool = decision.tool, -- 3098
						reason = actionReason, -- 3099
						reasoningContent = actionReasoningContent, -- 3100
						params = decision.params -- 3101
					}) -- 3101
					local action = { -- 3103
						step = step, -- 3104
						toolCallId = toolCallId, -- 3105
						tool = decision.tool, -- 3106
						reason = actionReason or "", -- 3107
						reasoningContent = actionReasoningContent, -- 3108
						params = decision.params, -- 3109
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3110
					} -- 3110
					local ____shared_history_57 = shared.history -- 3110
					____shared_history_57[#____shared_history_57 + 1] = action -- 3112
					actions[#actions + 1] = action -- 3113
					i = i + 1 -- 3087
				end -- 3087
			end -- 3087
			shared.step = startStep + #actions -- 3115
			shared.pendingToolActions = actions -- 3116
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3117
			persistHistoryState(shared) -- 3123
			return ____awaiter_resolve(nil, "batch_tools") -- 3123
		end -- 3123
		if result.directSummary and result.directSummary ~= "" then -- 3123
			shared.response = result.directSummary -- 3127
			shared.done = true -- 3128
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3129
			persistHistoryState(shared) -- 3134
			return ____awaiter_resolve(nil, "done") -- 3134
		end -- 3134
		if result.tool == "finish" then -- 3134
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3138
			shared.response = finalMessage -- 3139
			shared.done = true -- 3140
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3141
			persistHistoryState(shared) -- 3146
			return ____awaiter_resolve(nil, "done") -- 3146
		end -- 3146
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3149
		shared.step = shared.step + 1 -- 3150
		local step = shared.step -- 3151
		emitAgentEvent(shared, { -- 3152
			type = "decision_made", -- 3153
			sessionId = shared.sessionId, -- 3154
			taskId = shared.taskId, -- 3155
			step = step, -- 3156
			tool = result.tool, -- 3157
			reason = result.reason, -- 3158
			reasoningContent = result.reasoningContent, -- 3159
			params = result.params -- 3160
		}) -- 3160
		local ____shared_history_58 = shared.history -- 3160
		____shared_history_58[#____shared_history_58 + 1] = { -- 3162
			step = step, -- 3163
			toolCallId = toolCallId, -- 3164
			tool = result.tool, -- 3165
			reason = result.reason or "", -- 3166
			reasoningContent = result.reasoningContent, -- 3167
			params = result.params, -- 3168
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3169
		} -- 3169
		local action = shared.history[#shared.history] -- 3171
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3172
		if canPreExecuteTool(action.tool) then -- 3172
			shared.pendingToolActions = {action} -- 3174
			persistHistoryState(shared) -- 3175
			return ____awaiter_resolve(nil, "batch_tools") -- 3175
		end -- 3175
		clearPreExecutedResults(shared) -- 3178
		persistHistoryState(shared) -- 3179
		return ____awaiter_resolve(nil, result.tool) -- 3179
	end) -- 3179
end -- 3066
local ReadFileAction = __TS__Class() -- 3184
ReadFileAction.name = "ReadFileAction" -- 3184
__TS__ClassExtends(ReadFileAction, Node) -- 3184
function ReadFileAction.prototype.prep(self, shared) -- 3185
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3185
		local last = shared.history[#shared.history] -- 3186
		if not last then -- 3186
			error( -- 3187
				__TS__New(Error, "no history"), -- 3187
				0 -- 3187
			) -- 3187
		end -- 3187
		emitAgentStartEvent(shared, last) -- 3188
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3189
		if __TS__StringTrim(path) == "" then -- 3189
			error( -- 3192
				__TS__New(Error, "missing path"), -- 3192
				0 -- 3192
			) -- 3192
		end -- 3192
		local ____path_61 = path -- 3194
		local ____shared_workingDir_62 = shared.workingDir -- 3196
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 3197
		local ____last_params_startLine_59 = last.params.startLine -- 3198
		if ____last_params_startLine_59 == nil then -- 3198
			____last_params_startLine_59 = 1 -- 3198
		end -- 3198
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 3198
		local ____last_params_endLine_60 = last.params.endLine -- 3199
		if ____last_params_endLine_60 == nil then -- 3199
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 3199
		end -- 3199
		return ____awaiter_resolve( -- 3199
			nil, -- 3199
			{ -- 3193
				path = ____path_61, -- 3194
				tool = "read_file", -- 3195
				workDir = ____shared_workingDir_62, -- 3196
				docLanguage = ____temp_63, -- 3197
				startLine = ____TS__Number_result_64, -- 3198
				endLine = __TS__Number(____last_params_endLine_60) -- 3199
			} -- 3199
		) -- 3199
	end) -- 3199
end -- 3185
function ReadFileAction.prototype.exec(self, input) -- 3203
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3203
		return ____awaiter_resolve( -- 3203
			nil, -- 3203
			Tools.readFile( -- 3204
				input.workDir, -- 3205
				input.path, -- 3206
				__TS__Number(input.startLine or 1), -- 3207
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3208
				input.docLanguage -- 3209
			) -- 3209
		) -- 3209
	end) -- 3209
end -- 3203
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3213
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3213
		local result = execRes -- 3214
		local last = shared.history[#shared.history] -- 3215
		if last ~= nil then -- 3215
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3217
			appendToolResultMessage(shared, last) -- 3218
			emitAgentFinishEvent(shared, last) -- 3219
		end -- 3219
		persistHistoryState(shared) -- 3221
		__TS__Await(maybeCompressHistory(shared)) -- 3222
		persistHistoryState(shared) -- 3223
		return ____awaiter_resolve(nil, "main") -- 3223
	end) -- 3223
end -- 3213
local SearchFilesAction = __TS__Class() -- 3228
SearchFilesAction.name = "SearchFilesAction" -- 3228
__TS__ClassExtends(SearchFilesAction, Node) -- 3228
function SearchFilesAction.prototype.prep(self, shared) -- 3229
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3229
		local last = shared.history[#shared.history] -- 3230
		if not last then -- 3230
			error( -- 3231
				__TS__New(Error, "no history"), -- 3231
				0 -- 3231
			) -- 3231
		end -- 3231
		emitAgentStartEvent(shared, last) -- 3232
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3232
	end) -- 3232
end -- 3229
function SearchFilesAction.prototype.exec(self, input) -- 3236
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3236
		local params = input.params -- 3237
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 3238
		local ____input_workDir_71 = input.workDir -- 3239
		local ____temp_72 = params.path or "" -- 3240
		local ____temp_73 = params.pattern or "" -- 3241
		local ____params_globs_74 = params.globs -- 3242
		local ____params_useRegex_75 = params.useRegex -- 3243
		local ____params_caseSensitive_76 = params.caseSensitive -- 3244
		local ____math_max_67 = math.max -- 3247
		local ____math_floor_66 = math.floor -- 3247
		local ____params_limit_65 = params.limit -- 3247
		if ____params_limit_65 == nil then -- 3247
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 3247
		end -- 3247
		local ____math_max_67_result_77 = ____math_max_67( -- 3247
			1, -- 3247
			____math_floor_66(__TS__Number(____params_limit_65)) -- 3247
		) -- 3247
		local ____math_max_70 = math.max -- 3248
		local ____math_floor_69 = math.floor -- 3248
		local ____params_offset_68 = params.offset -- 3248
		if ____params_offset_68 == nil then -- 3248
			____params_offset_68 = 0 -- 3248
		end -- 3248
		local result = __TS__Await(____Tools_searchFiles_78({ -- 3238
			workDir = ____input_workDir_71, -- 3239
			path = ____temp_72, -- 3240
			pattern = ____temp_73, -- 3241
			globs = ____params_globs_74, -- 3242
			useRegex = ____params_useRegex_75, -- 3243
			caseSensitive = ____params_caseSensitive_76, -- 3244
			includeContent = true, -- 3245
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3246
			limit = ____math_max_67_result_77, -- 3247
			offset = ____math_max_70( -- 3248
				0, -- 3248
				____math_floor_69(__TS__Number(____params_offset_68)) -- 3248
			), -- 3248
			groupByFile = params.groupByFile == true -- 3249
		})) -- 3249
		return ____awaiter_resolve(nil, result) -- 3249
	end) -- 3249
end -- 3236
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3254
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3254
		local last = shared.history[#shared.history] -- 3255
		if last ~= nil then -- 3255
			local result = execRes -- 3257
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3258
			appendToolResultMessage(shared, last) -- 3259
			emitAgentFinishEvent(shared, last) -- 3260
		end -- 3260
		persistHistoryState(shared) -- 3262
		__TS__Await(maybeCompressHistory(shared)) -- 3263
		persistHistoryState(shared) -- 3264
		return ____awaiter_resolve(nil, "main") -- 3264
	end) -- 3264
end -- 3254
local SearchDoraAPIAction = __TS__Class() -- 3269
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3269
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3269
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3270
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3270
		local last = shared.history[#shared.history] -- 3271
		if not last then -- 3271
			error( -- 3272
				__TS__New(Error, "no history"), -- 3272
				0 -- 3272
			) -- 3272
		end -- 3272
		emitAgentStartEvent(shared, last) -- 3273
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3273
	end) -- 3273
end -- 3270
function SearchDoraAPIAction.prototype.exec(self, input) -- 3277
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3277
		local params = input.params -- 3278
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 3279
		local ____temp_82 = params.pattern or "" -- 3280
		local ____temp_83 = params.docSource or "api" -- 3281
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 3282
		local ____temp_85 = params.programmingLanguage or "ts" -- 3283
		local ____math_min_81 = math.min -- 3284
		local ____math_max_80 = math.max -- 3284
		local ____params_limit_79 = params.limit -- 3284
		if ____params_limit_79 == nil then -- 3284
			____params_limit_79 = 8 -- 3284
		end -- 3284
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 3279
			pattern = ____temp_82, -- 3280
			docSource = ____temp_83, -- 3281
			docLanguage = ____temp_84, -- 3282
			programmingLanguage = ____temp_85, -- 3283
			limit = ____math_min_81( -- 3284
				SEARCH_DORA_API_LIMIT_MAX, -- 3284
				____math_max_80( -- 3284
					1, -- 3284
					__TS__Number(____params_limit_79) -- 3284
				) -- 3284
			), -- 3284
			useRegex = params.useRegex, -- 3285
			caseSensitive = false, -- 3286
			includeContent = true, -- 3287
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3288
		})) -- 3288
		return ____awaiter_resolve(nil, result) -- 3288
	end) -- 3288
end -- 3277
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3293
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3293
		local last = shared.history[#shared.history] -- 3294
		if last ~= nil then -- 3294
			local result = execRes -- 3296
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3297
			appendToolResultMessage(shared, last) -- 3298
			emitAgentFinishEvent(shared, last) -- 3299
		end -- 3299
		persistHistoryState(shared) -- 3301
		__TS__Await(maybeCompressHistory(shared)) -- 3302
		persistHistoryState(shared) -- 3303
		return ____awaiter_resolve(nil, "main") -- 3303
	end) -- 3303
end -- 3293
local ListFilesAction = __TS__Class() -- 3308
ListFilesAction.name = "ListFilesAction" -- 3308
__TS__ClassExtends(ListFilesAction, Node) -- 3308
function ListFilesAction.prototype.prep(self, shared) -- 3309
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3309
		local last = shared.history[#shared.history] -- 3310
		if not last then -- 3310
			error( -- 3311
				__TS__New(Error, "no history"), -- 3311
				0 -- 3311
			) -- 3311
		end -- 3311
		emitAgentStartEvent(shared, last) -- 3312
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3312
	end) -- 3312
end -- 3309
function ListFilesAction.prototype.exec(self, input) -- 3316
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3316
		local params = input.params -- 3317
		local ____Tools_listFiles_93 = Tools.listFiles -- 3318
		local ____input_workDir_90 = input.workDir -- 3319
		local ____temp_91 = params.path or "" -- 3320
		local ____params_globs_92 = params.globs -- 3321
		local ____math_max_89 = math.max -- 3322
		local ____math_floor_88 = math.floor -- 3322
		local ____params_maxEntries_87 = params.maxEntries -- 3322
		if ____params_maxEntries_87 == nil then -- 3322
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3322
		end -- 3322
		local result = ____Tools_listFiles_93({ -- 3318
			workDir = ____input_workDir_90, -- 3319
			path = ____temp_91, -- 3320
			globs = ____params_globs_92, -- 3321
			maxEntries = ____math_max_89( -- 3322
				1, -- 3322
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3322
			) -- 3322
		}) -- 3322
		return ____awaiter_resolve(nil, result) -- 3322
	end) -- 3322
end -- 3316
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3327
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3327
		local last = shared.history[#shared.history] -- 3328
		if last ~= nil then -- 3328
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3330
			appendToolResultMessage(shared, last) -- 3331
			emitAgentFinishEvent(shared, last) -- 3332
		end -- 3332
		persistHistoryState(shared) -- 3334
		__TS__Await(maybeCompressHistory(shared)) -- 3335
		persistHistoryState(shared) -- 3336
		return ____awaiter_resolve(nil, "main") -- 3336
	end) -- 3336
end -- 3327
local DeleteFileAction = __TS__Class() -- 3341
DeleteFileAction.name = "DeleteFileAction" -- 3341
__TS__ClassExtends(DeleteFileAction, Node) -- 3341
function DeleteFileAction.prototype.prep(self, shared) -- 3342
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3342
		local last = shared.history[#shared.history] -- 3343
		if not last then -- 3343
			error( -- 3344
				__TS__New(Error, "no history"), -- 3344
				0 -- 3344
			) -- 3344
		end -- 3344
		emitAgentStartEvent(shared, last) -- 3345
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3346
		if __TS__StringTrim(targetFile) == "" then -- 3346
			error( -- 3349
				__TS__New(Error, "missing target_file"), -- 3349
				0 -- 3349
			) -- 3349
		end -- 3349
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3349
	end) -- 3349
end -- 3342
function DeleteFileAction.prototype.exec(self, input) -- 3353
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3353
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3354
		if not result.success then -- 3354
			return ____awaiter_resolve(nil, result) -- 3354
		end -- 3354
		return ____awaiter_resolve(nil, { -- 3354
			success = true, -- 3362
			changed = true, -- 3363
			mode = "delete", -- 3364
			checkpointId = result.checkpointId, -- 3365
			checkpointSeq = result.checkpointSeq, -- 3366
			files = {{path = input.targetFile, op = "delete"}} -- 3367
		}) -- 3367
	end) -- 3367
end -- 3353
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3371
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3371
		local last = shared.history[#shared.history] -- 3372
		if last ~= nil then -- 3372
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3374
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3375
			appendToolResultMessage(shared, last) -- 3376
			emitAgentFinishEvent(shared, last) -- 3377
			local result = last.result -- 3378
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3378
				emitAgentEvent(shared, { -- 3383
					type = "checkpoint_created", -- 3384
					sessionId = shared.sessionId, -- 3385
					taskId = shared.taskId, -- 3386
					step = last.step, -- 3387
					tool = "delete_file", -- 3388
					checkpointId = result.checkpointId, -- 3389
					checkpointSeq = result.checkpointSeq, -- 3390
					files = result.files -- 3391
				}) -- 3391
			end -- 3391
		end -- 3391
		persistHistoryState(shared) -- 3395
		__TS__Await(maybeCompressHistory(shared)) -- 3396
		persistHistoryState(shared) -- 3397
		return ____awaiter_resolve(nil, "main") -- 3397
	end) -- 3397
end -- 3371
local BuildAction = __TS__Class() -- 3402
BuildAction.name = "BuildAction" -- 3402
__TS__ClassExtends(BuildAction, Node) -- 3402
function BuildAction.prototype.prep(self, shared) -- 3403
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3403
		local last = shared.history[#shared.history] -- 3404
		if not last then -- 3404
			error( -- 3405
				__TS__New(Error, "no history"), -- 3405
				0 -- 3405
			) -- 3405
		end -- 3405
		emitAgentStartEvent(shared, last) -- 3406
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3406
	end) -- 3406
end -- 3403
function BuildAction.prototype.exec(self, input) -- 3410
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3410
		local params = input.params -- 3411
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3412
		return ____awaiter_resolve(nil, result) -- 3412
	end) -- 3412
end -- 3410
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3419
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3419
		local last = shared.history[#shared.history] -- 3420
		if last ~= nil then -- 3420
			last.result = sanitizeBuildResultForHistory(execRes) -- 3422
			appendToolResultMessage(shared, last) -- 3423
			emitAgentFinishEvent(shared, last) -- 3424
		end -- 3424
		persistHistoryState(shared) -- 3426
		__TS__Await(maybeCompressHistory(shared)) -- 3427
		persistHistoryState(shared) -- 3428
		return ____awaiter_resolve(nil, "main") -- 3428
	end) -- 3428
end -- 3419
local SpawnSubAgentAction = __TS__Class() -- 3433
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3433
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3433
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3434
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3434
		local last = shared.history[#shared.history] -- 3443
		if not last then -- 3443
			error( -- 3444
				__TS__New(Error, "no history"), -- 3444
				0 -- 3444
			) -- 3444
		end -- 3444
		emitAgentStartEvent(shared, last) -- 3445
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3446
			last.params.filesHint, -- 3447
			function(____, item) return type(item) == "string" end -- 3447
		) or nil -- 3447
		return ____awaiter_resolve( -- 3447
			nil, -- 3447
			{ -- 3449
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3450
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3451
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3452
				filesHint = filesHint, -- 3453
				sessionId = shared.sessionId, -- 3454
				projectRoot = shared.workingDir, -- 3455
				spawnSubAgent = shared.spawnSubAgent -- 3456
			} -- 3456
		) -- 3456
	end) -- 3456
end -- 3434
function SpawnSubAgentAction.prototype.exec(self, input) -- 3460
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3460
		if not input.spawnSubAgent then -- 3460
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3460
		end -- 3460
		if input.sessionId == nil or input.sessionId <= 0 then -- 3460
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3460
		end -- 3460
		local ____Log_99 = Log -- 3475
		local ____temp_96 = #input.title -- 3475
		local ____temp_97 = #input.prompt -- 3475
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3475
		local ____opt_94 = input.filesHint -- 3475
		____Log_99( -- 3475
			"Info", -- 3475
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3475
		) -- 3475
		local result = __TS__Await(input.spawnSubAgent({ -- 3476
			parentSessionId = input.sessionId, -- 3477
			projectRoot = input.projectRoot, -- 3478
			title = input.title, -- 3479
			prompt = input.prompt, -- 3480
			expectedOutput = input.expectedOutput, -- 3481
			filesHint = input.filesHint -- 3482
		})) -- 3482
		if not result.success then -- 3482
			return ____awaiter_resolve(nil, result) -- 3482
		end -- 3482
		return ____awaiter_resolve(nil, { -- 3482
			success = true, -- 3488
			sessionId = result.sessionId, -- 3489
			taskId = result.taskId, -- 3490
			title = result.title, -- 3491
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3492
		}) -- 3492
	end) -- 3492
end -- 3460
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3496
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3496
		local last = shared.history[#shared.history] -- 3497
		if last ~= nil then -- 3497
			last.result = execRes -- 3499
			appendToolResultMessage(shared, last) -- 3500
			emitAgentFinishEvent(shared, last) -- 3501
		end -- 3501
		persistHistoryState(shared) -- 3503
		__TS__Await(maybeCompressHistory(shared)) -- 3504
		persistHistoryState(shared) -- 3505
		return ____awaiter_resolve(nil, "main") -- 3505
	end) -- 3505
end -- 3496
local ListSubAgentsAction = __TS__Class() -- 3510
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3510
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3510
function ListSubAgentsAction.prototype.prep(self, shared) -- 3511
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3511
		local last = shared.history[#shared.history] -- 3520
		if not last then -- 3520
			error( -- 3521
				__TS__New(Error, "no history"), -- 3521
				0 -- 3521
			) -- 3521
		end -- 3521
		emitAgentStartEvent(shared, last) -- 3522
		return ____awaiter_resolve( -- 3522
			nil, -- 3522
			{ -- 3523
				sessionId = shared.sessionId, -- 3524
				projectRoot = shared.workingDir, -- 3525
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3526
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3527
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3528
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3529
				listSubAgents = shared.listSubAgents -- 3530
			} -- 3530
		) -- 3530
	end) -- 3530
end -- 3511
function ListSubAgentsAction.prototype.exec(self, input) -- 3534
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3534
		if not input.listSubAgents then -- 3534
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3534
		end -- 3534
		if input.sessionId == nil or input.sessionId <= 0 then -- 3534
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3534
		end -- 3534
		local result = __TS__Await(input.listSubAgents({ -- 3549
			sessionId = input.sessionId, -- 3550
			projectRoot = input.projectRoot, -- 3551
			status = input.status, -- 3552
			limit = input.limit, -- 3553
			offset = input.offset, -- 3554
			query = input.query -- 3555
		})) -- 3555
		return ____awaiter_resolve(nil, result) -- 3555
	end) -- 3555
end -- 3534
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3560
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3560
		local last = shared.history[#shared.history] -- 3561
		if last ~= nil then -- 3561
			last.result = execRes -- 3563
			appendToolResultMessage(shared, last) -- 3564
			emitAgentFinishEvent(shared, last) -- 3565
		end -- 3565
		persistHistoryState(shared) -- 3567
		__TS__Await(maybeCompressHistory(shared)) -- 3568
		persistHistoryState(shared) -- 3569
		return ____awaiter_resolve(nil, "main") -- 3569
	end) -- 3569
end -- 3560
EditFileAction = __TS__Class() -- 3574
EditFileAction.name = "EditFileAction" -- 3574
__TS__ClassExtends(EditFileAction, Node) -- 3574
function EditFileAction.prototype.prep(self, shared) -- 3575
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3575
		local last = shared.history[#shared.history] -- 3576
		if not last then -- 3576
			error( -- 3577
				__TS__New(Error, "no history"), -- 3577
				0 -- 3577
			) -- 3577
		end -- 3577
		emitAgentStartEvent(shared, last) -- 3578
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3579
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3582
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3583
		if __TS__StringTrim(path) == "" then -- 3583
			error( -- 3584
				__TS__New(Error, "missing path"), -- 3584
				0 -- 3584
			) -- 3584
		end -- 3584
		return ____awaiter_resolve(nil, { -- 3584
			path = path, -- 3585
			oldStr = oldStr, -- 3585
			newStr = newStr, -- 3585
			taskId = shared.taskId, -- 3585
			workDir = shared.workingDir -- 3585
		}) -- 3585
	end) -- 3585
end -- 3575
function EditFileAction.prototype.exec(self, input) -- 3588
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3588
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3589
		if not readRes.success then -- 3589
			if input.oldStr ~= "" then -- 3589
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3589
			end -- 3589
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3594
			if not createRes.success then -- 3594
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3594
			end -- 3594
			return ____awaiter_resolve(nil, { -- 3594
				success = true, -- 3602
				changed = true, -- 3603
				mode = "create", -- 3604
				checkpointId = createRes.checkpointId, -- 3605
				checkpointSeq = createRes.checkpointSeq, -- 3606
				files = {{path = input.path, op = "create"}} -- 3607
			}) -- 3607
		end -- 3607
		if input.oldStr == "" then -- 3607
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3611
			if not overwriteRes.success then -- 3611
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3611
			end -- 3611
			return ____awaiter_resolve(nil, { -- 3611
				success = true, -- 3619
				changed = true, -- 3620
				mode = "overwrite", -- 3621
				checkpointId = overwriteRes.checkpointId, -- 3622
				checkpointSeq = overwriteRes.checkpointSeq, -- 3623
				files = {{path = input.path, op = "write"}} -- 3624
			}) -- 3624
		end -- 3624
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3629
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3630
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3631
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3634
		if occurrences == 0 then -- 3634
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3636
			if not indentTolerant.success then -- 3636
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3636
			end -- 3636
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3640
			if not applyRes.success then -- 3640
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3640
			end -- 3640
			return ____awaiter_resolve(nil, { -- 3640
				success = true, -- 3648
				changed = true, -- 3649
				mode = "replace_indent_tolerant", -- 3650
				checkpointId = applyRes.checkpointId, -- 3651
				checkpointSeq = applyRes.checkpointSeq, -- 3652
				files = {{path = input.path, op = "write"}} -- 3653
			}) -- 3653
		end -- 3653
		if occurrences > 1 then -- 3653
			return ____awaiter_resolve( -- 3653
				nil, -- 3653
				{ -- 3657
					success = false, -- 3657
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3657
				} -- 3657
			) -- 3657
		end -- 3657
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3661
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3662
		if not applyRes.success then -- 3662
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3662
		end -- 3662
		return ____awaiter_resolve(nil, { -- 3662
			success = true, -- 3670
			changed = true, -- 3671
			mode = "replace", -- 3672
			checkpointId = applyRes.checkpointId, -- 3673
			checkpointSeq = applyRes.checkpointSeq, -- 3674
			files = {{path = input.path, op = "write"}} -- 3675
		}) -- 3675
	end) -- 3675
end -- 3588
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3679
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3679
		local last = shared.history[#shared.history] -- 3680
		if last ~= nil then -- 3680
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3682
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3683
			appendToolResultMessage(shared, last) -- 3684
			emitAgentFinishEvent(shared, last) -- 3685
			local result = last.result -- 3686
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3686
				emitAgentEvent(shared, { -- 3691
					type = "checkpoint_created", -- 3692
					sessionId = shared.sessionId, -- 3693
					taskId = shared.taskId, -- 3694
					step = last.step, -- 3695
					tool = last.tool, -- 3696
					checkpointId = result.checkpointId, -- 3697
					checkpointSeq = result.checkpointSeq, -- 3698
					files = result.files -- 3699
				}) -- 3699
			end -- 3699
		end -- 3699
		persistHistoryState(shared) -- 3703
		__TS__Await(maybeCompressHistory(shared)) -- 3704
		persistHistoryState(shared) -- 3705
		return ____awaiter_resolve(nil, "main") -- 3705
	end) -- 3705
end -- 3679
local function emitCheckpointEventForAction(shared, action) -- 3710
	local result = action.result -- 3711
	if not result then -- 3711
		return -- 3712
	end -- 3712
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3712
		emitAgentEvent(shared, { -- 3717
			type = "checkpoint_created", -- 3718
			sessionId = shared.sessionId, -- 3719
			taskId = shared.taskId, -- 3720
			step = action.step, -- 3721
			tool = action.tool, -- 3722
			checkpointId = result.checkpointId, -- 3723
			checkpointSeq = result.checkpointSeq, -- 3724
			files = result.files -- 3725
		}) -- 3725
	end -- 3725
end -- 3710
local function canRunBatchActionInParallel(self, action) -- 4030
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 4031
end -- 4030
local function partitionToolCalls(actions) -- 4043
	local batches = {} -- 4044
	do -- 4044
		local i = 0 -- 4045
		while i < #actions do -- 4045
			local action = actions[i + 1] -- 4046
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4047
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4048
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4048
				local ____lastBatch_actions_134 = lastBatch.actions -- 4048
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 4050
			else -- 4050
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4052
			end -- 4052
			i = i + 1 -- 4045
		end -- 4045
	end -- 4045
	return batches -- 4055
end -- 4043
local BatchToolAction = __TS__Class() -- 4058
BatchToolAction.name = "BatchToolAction" -- 4058
__TS__ClassExtends(BatchToolAction, Node) -- 4058
function BatchToolAction.prototype.prep(self, shared) -- 4059
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4059
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4059
	end) -- 4059
end -- 4059
function BatchToolAction.prototype.exec(self, input) -- 4063
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4063
		local shared = input.shared -- 4064
		local preExecuted = shared.preExecutedResults -- 4065
		local batches = partitionToolCalls(input.actions) -- 4066
		local parallelBatchCount = #__TS__ArrayFilter( -- 4067
			batches, -- 4067
			function(____, b) return b.isConcurrencySafe end -- 4067
		) -- 4067
		local serialBatchCount = #__TS__ArrayFilter( -- 4068
			batches, -- 4068
			function(____, b) return not b.isConcurrencySafe end -- 4068
		) -- 4068
		Log( -- 4069
			"Info", -- 4069
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4069
		) -- 4069
		do -- 4069
			local batchIdx = 0 -- 4071
			while batchIdx < #batches do -- 4071
				do -- 4071
					local batch = batches[batchIdx + 1] -- 4072
					if shared.stopToken.stopped then -- 4072
						for ____, action in ipairs(batch.actions) do -- 4074
							if not action.result then -- 4074
								action.result = { -- 4076
									success = false, -- 4076
									message = getCancelledReason(shared) -- 4076
								} -- 4076
							end -- 4076
						end -- 4076
						goto __continue643 -- 4079
					end -- 4079
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4079
						local preExecCount = #__TS__ArrayFilter( -- 4083
							batch.actions, -- 4083
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4083
						) -- 4083
						Log( -- 4084
							"Info", -- 4084
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4084
						) -- 4084
						do -- 4084
							local i = 0 -- 4085
							while i < #batch.actions do -- 4085
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4086
								i = i + 1 -- 4085
							end -- 4085
						end -- 4085
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4088
							batch.actions, -- 4088
							function(____, action) -- 4088
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4088
									if shared.stopToken.stopped then -- 4088
										action.result = { -- 4090
											success = false, -- 4090
											message = getCancelledReason(shared) -- 4090
										} -- 4090
										return ____awaiter_resolve(nil, action) -- 4090
									end -- 4090
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4093
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4094
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4095
									return ____awaiter_resolve(nil, action) -- 4095
								end) -- 4095
							end -- 4088
						))) -- 4088
						do -- 4088
							local i = 0 -- 4098
							while i < #batch.actions do -- 4098
								local action = batch.actions[i + 1] -- 4099
								if not action.result then -- 4099
									action.result = {success = false, message = "tool did not produce a result"} -- 4101
								end -- 4101
								appendToolResultMessage(shared, action) -- 4103
								emitAgentFinishEvent(shared, action) -- 4104
								emitCheckpointEventForAction(shared, action) -- 4105
								i = i + 1 -- 4098
							end -- 4098
						end -- 4098
					else -- 4098
						Log( -- 4108
							"Info", -- 4108
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4108
						) -- 4108
						do -- 4108
							local i = 0 -- 4109
							while i < #batch.actions do -- 4109
								local action = batch.actions[i + 1] -- 4110
								emitAgentStartEvent(shared, action) -- 4111
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4112
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4113
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4114
								appendToolResultMessage(shared, action) -- 4115
								emitAgentFinishEvent(shared, action) -- 4116
								emitCheckpointEventForAction(shared, action) -- 4117
								persistHistoryState(shared) -- 4118
								if shared.stopToken.stopped then -- 4118
									break -- 4120
								end -- 4120
								i = i + 1 -- 4109
							end -- 4109
						end -- 4109
					end -- 4109
				end -- 4109
				::__continue643:: -- 4109
				batchIdx = batchIdx + 1 -- 4071
			end -- 4071
		end -- 4071
		persistHistoryState(shared) -- 4125
		return ____awaiter_resolve(nil, input.actions) -- 4125
	end) -- 4125
end -- 4063
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4129
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4129
		shared.pendingToolActions = nil -- 4130
		shared.preExecutedResults = nil -- 4131
		persistHistoryState(shared) -- 4132
		__TS__Await(maybeCompressHistory(shared)) -- 4133
		persistHistoryState(shared) -- 4134
		return ____awaiter_resolve(nil, "main") -- 4134
	end) -- 4134
end -- 4129
local EndNode = __TS__Class() -- 4139
EndNode.name = "EndNode" -- 4139
__TS__ClassExtends(EndNode, Node) -- 4139
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4140
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4140
		return ____awaiter_resolve(nil, nil) -- 4140
	end) -- 4140
end -- 4140
local CodingAgentFlow = __TS__Class() -- 4145
CodingAgentFlow.name = "CodingAgentFlow" -- 4145
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4145
function CodingAgentFlow.prototype.____constructor(self, role) -- 4146
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4147
	local read = __TS__New(ReadFileAction, 1, 0) -- 4148
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4149
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4150
	local list = __TS__New(ListFilesAction, 1, 0) -- 4151
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4152
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4153
	local build = __TS__New(BuildAction, 1, 0) -- 4154
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4155
	local edit = __TS__New(EditFileAction, 1, 0) -- 4156
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4157
	local done = __TS__New(EndNode, 1, 0) -- 4158
	main:on("batch_tools", batch) -- 4160
	main:on("grep_files", search) -- 4161
	main:on("search_dora_api", searchDora) -- 4162
	main:on("glob_files", list) -- 4163
	if role == "main" then -- 4163
		main:on("read_file", read) -- 4165
		main:on("delete_file", del) -- 4166
		main:on("build", build) -- 4167
		main:on("edit_file", edit) -- 4168
		main:on("list_sub_agents", listSub) -- 4169
		main:on("spawn_sub_agent", spawn) -- 4170
	else -- 4170
		main:on("read_file", read) -- 4172
		main:on("delete_file", del) -- 4173
		main:on("build", build) -- 4174
		main:on("edit_file", edit) -- 4175
	end -- 4175
	main:on("done", done) -- 4177
	search:on("main", main) -- 4179
	searchDora:on("main", main) -- 4180
	list:on("main", main) -- 4181
	listSub:on("main", main) -- 4182
	spawn:on("main", main) -- 4183
	batch:on("main", main) -- 4184
	read:on("main", main) -- 4185
	del:on("main", main) -- 4186
	build:on("main", main) -- 4187
	edit:on("main", main) -- 4188
	Flow.prototype.____constructor(self, main) -- 4190
end -- 4146
local function runCodingAgentAsync(options) -- 4212
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4212
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4212
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4212
		end -- 4212
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4216
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4217
		if not llmConfigRes.success then -- 4217
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4217
		end -- 4217
		local llmConfig = llmConfigRes.config -- 4223
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4224
		if not taskRes.success then -- 4224
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4224
		end -- 4224
		local compressor = __TS__New(MemoryCompressor, { -- 4231
			compressionThreshold = 0.8, -- 4232
			compressionTargetThreshold = 0.5, -- 4233
			maxCompressionRounds = 3, -- 4234
			projectDir = options.workDir, -- 4235
			llmConfig = llmConfig, -- 4236
			promptPack = options.promptPack, -- 4237
			scope = options.memoryScope -- 4238
		}) -- 4238
		local persistedSession = compressor:getStorage():readSessionState() -- 4240
		local promptPack = compressor:getPromptPack() -- 4241
		local shared = { -- 4243
			sessionId = options.sessionId, -- 4244
			taskId = taskRes.taskId, -- 4245
			role = options.role or "main", -- 4246
			maxSteps = math.max( -- 4247
				1, -- 4247
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4247
			), -- 4247
			llmMaxTry = math.max( -- 4248
				1, -- 4248
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4248
			), -- 4248
			step = 0, -- 4249
			done = false, -- 4250
			stopToken = options.stopToken or ({stopped = false}), -- 4251
			response = "", -- 4252
			userQuery = normalizedPrompt, -- 4253
			workingDir = options.workDir, -- 4254
			useChineseResponse = options.useChineseResponse == true, -- 4255
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4256
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4259
			llmConfig = llmConfig, -- 4260
			onEvent = options.onEvent, -- 4261
			promptPack = promptPack, -- 4262
			history = {}, -- 4263
			messages = persistedSession.messages, -- 4264
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4265
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4266
			memory = {compressor = compressor}, -- 4268
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4272
			spawnSubAgent = options.spawnSubAgent, -- 4277
			listSubAgents = options.listSubAgents -- 4278
		} -- 4278
		local ____try = __TS__AsyncAwaiter(function() -- 4278
			emitAgentEvent(shared, { -- 4282
				type = "task_started", -- 4283
				sessionId = shared.sessionId, -- 4284
				taskId = shared.taskId, -- 4285
				prompt = shared.userQuery, -- 4286
				workDir = shared.workingDir, -- 4287
				maxSteps = shared.maxSteps -- 4288
			}) -- 4288
			if shared.stopToken.stopped then -- 4288
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4291
				return ____awaiter_resolve( -- 4291
					nil, -- 4291
					emitAgentTaskFinishEvent( -- 4292
						shared, -- 4292
						false, -- 4292
						getCancelledReason(shared) -- 4292
					) -- 4292
				) -- 4292
			end -- 4292
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4294
			local promptCommand = getPromptCommand(shared.userQuery) -- 4295
			if promptCommand == "clear" then -- 4295
				return ____awaiter_resolve( -- 4295
					nil, -- 4295
					clearSessionHistory(shared) -- 4297
				) -- 4297
			end -- 4297
			if promptCommand == "compact" then -- 4297
				if shared.role == "sub" then -- 4297
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4301
					return ____awaiter_resolve( -- 4301
						nil, -- 4301
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4302
					) -- 4302
				end -- 4302
				return ____awaiter_resolve( -- 4302
					nil, -- 4302
					__TS__Await(compactAllHistory(shared)) -- 4310
				) -- 4310
			end -- 4310
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4312
			persistHistoryState(shared) -- 4316
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4317
			__TS__Await(flow:run(shared)) -- 4318
			if shared.stopToken.stopped then -- 4318
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4320
				return ____awaiter_resolve( -- 4320
					nil, -- 4320
					emitAgentTaskFinishEvent( -- 4321
						shared, -- 4321
						false, -- 4321
						getCancelledReason(shared) -- 4321
					) -- 4321
				) -- 4321
			end -- 4321
			if shared.error then -- 4321
				return ____awaiter_resolve( -- 4321
					nil, -- 4321
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4324
				) -- 4324
			end -- 4324
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4327
			return ____awaiter_resolve( -- 4327
				nil, -- 4327
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4328
			) -- 4328
		end) -- 4328
		__TS__Await(____try.catch( -- 4281
			____try, -- 4281
			function(____, e) -- 4281
				return ____awaiter_resolve( -- 4281
					nil, -- 4281
					finalizeAgentFailure( -- 4331
						shared, -- 4331
						tostring(e) -- 4331
					) -- 4331
				) -- 4331
			end -- 4331
		)) -- 4331
	end) -- 4331
end -- 4212
function ____exports.runCodingAgent(options, callback) -- 4335
	local ____self_137 = runCodingAgentAsync(options) -- 4335
	____self_137["then"]( -- 4335
		____self_137, -- 4335
		function(____, result) return callback(result) end -- 4336
	) -- 4336
end -- 4335
return ____exports -- 4335