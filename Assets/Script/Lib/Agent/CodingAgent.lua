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
function buildXmlDecisionInstruction(shared, feedback) -- 2416
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2417
end -- 2417
function executeToolAction(shared, action) -- 3600
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3600
		if shared.stopToken.stopped then -- 3600
			return ____awaiter_resolve( -- 3600
				nil, -- 3600
				{ -- 3602
					success = false, -- 3602
					message = getCancelledReason(shared) -- 3602
				} -- 3602
			) -- 3602
		end -- 3602
		local params = action.params -- 3604
		if action.tool == "read_file" then -- 3604
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3606
			if __TS__StringTrim(path) == "" then -- 3606
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3606
			end -- 3606
			local ____Tools_readFile_104 = Tools.readFile -- 3610
			local ____shared_workingDir_102 = shared.workingDir -- 3611
			local ____params_startLine_100 = params.startLine -- 3613
			if ____params_startLine_100 == nil then -- 3613
				____params_startLine_100 = 1 -- 3613
			end -- 3613
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3613
			local ____params_endLine_101 = params.endLine -- 3614
			if ____params_endLine_101 == nil then -- 3614
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3614
			end -- 3614
			return ____awaiter_resolve( -- 3614
				nil, -- 3614
				____Tools_readFile_104( -- 3610
					____shared_workingDir_102, -- 3611
					path, -- 3612
					____TS__Number_result_103, -- 3613
					__TS__Number(____params_endLine_101), -- 3614
					shared.useChineseResponse and "zh" or "en" -- 3615
				) -- 3615
			) -- 3615
		end -- 3615
		if action.tool == "grep_files" then -- 3615
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3619
			local ____shared_workingDir_111 = shared.workingDir -- 3620
			local ____temp_112 = params.path or "" -- 3621
			local ____temp_113 = params.pattern or "" -- 3622
			local ____params_globs_114 = params.globs -- 3623
			local ____params_useRegex_115 = params.useRegex -- 3624
			local ____params_caseSensitive_116 = params.caseSensitive -- 3625
			local ____math_max_107 = math.max -- 3628
			local ____math_floor_106 = math.floor -- 3628
			local ____params_limit_105 = params.limit -- 3628
			if ____params_limit_105 == nil then -- 3628
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3628
			end -- 3628
			local ____math_max_107_result_117 = ____math_max_107( -- 3628
				1, -- 3628
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3628
			) -- 3628
			local ____math_max_110 = math.max -- 3629
			local ____math_floor_109 = math.floor -- 3629
			local ____params_offset_108 = params.offset -- 3629
			if ____params_offset_108 == nil then -- 3629
				____params_offset_108 = 0 -- 3629
			end -- 3629
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3619
				workDir = ____shared_workingDir_111, -- 3620
				path = ____temp_112, -- 3621
				pattern = ____temp_113, -- 3622
				globs = ____params_globs_114, -- 3623
				useRegex = ____params_useRegex_115, -- 3624
				caseSensitive = ____params_caseSensitive_116, -- 3625
				includeContent = true, -- 3626
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3627
				limit = ____math_max_107_result_117, -- 3628
				offset = ____math_max_110( -- 3629
					0, -- 3629
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3629
				), -- 3629
				groupByFile = params.groupByFile == true -- 3630
			})) -- 3630
			return ____awaiter_resolve(nil, result) -- 3630
		end -- 3630
		if action.tool == "search_dora_api" then -- 3630
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3635
			local ____temp_122 = params.pattern or "" -- 3636
			local ____temp_123 = params.docSource or "api" -- 3637
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3638
			local ____temp_125 = params.programmingLanguage or "ts" -- 3639
			local ____math_min_121 = math.min -- 3640
			local ____math_max_120 = math.max -- 3640
			local ____params_limit_119 = params.limit -- 3640
			if ____params_limit_119 == nil then -- 3640
				____params_limit_119 = 8 -- 3640
			end -- 3640
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3635
				pattern = ____temp_122, -- 3636
				docSource = ____temp_123, -- 3637
				docLanguage = ____temp_124, -- 3638
				programmingLanguage = ____temp_125, -- 3639
				limit = ____math_min_121( -- 3640
					SEARCH_DORA_API_LIMIT_MAX, -- 3640
					____math_max_120( -- 3640
						1, -- 3640
						__TS__Number(____params_limit_119) -- 3640
					) -- 3640
				), -- 3640
				useRegex = params.useRegex, -- 3641
				caseSensitive = false, -- 3642
				includeContent = true, -- 3643
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3644
			})) -- 3644
			return ____awaiter_resolve(nil, result) -- 3644
		end -- 3644
		if action.tool == "glob_files" then -- 3644
			local ____Tools_listFiles_133 = Tools.listFiles -- 3649
			local ____shared_workingDir_130 = shared.workingDir -- 3650
			local ____temp_131 = params.path or "" -- 3651
			local ____params_globs_132 = params.globs -- 3652
			local ____math_max_129 = math.max -- 3653
			local ____math_floor_128 = math.floor -- 3653
			local ____params_maxEntries_127 = params.maxEntries -- 3653
			if ____params_maxEntries_127 == nil then -- 3653
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3653
			end -- 3653
			local result = ____Tools_listFiles_133({ -- 3649
				workDir = ____shared_workingDir_130, -- 3650
				path = ____temp_131, -- 3651
				globs = ____params_globs_132, -- 3652
				maxEntries = ____math_max_129( -- 3653
					1, -- 3653
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3653
				) -- 3653
			}) -- 3653
			return ____awaiter_resolve(nil, result) -- 3653
		end -- 3653
		if action.tool == "delete_file" then -- 3653
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3658
			if __TS__StringTrim(targetFile) == "" then -- 3658
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3658
			end -- 3658
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3662
			if not result.success then -- 3662
				return ____awaiter_resolve(nil, result) -- 3662
			end -- 3662
			return ____awaiter_resolve(nil, { -- 3662
				success = true, -- 3670
				changed = true, -- 3671
				mode = "delete", -- 3672
				checkpointId = result.checkpointId, -- 3673
				checkpointSeq = result.checkpointSeq, -- 3674
				files = {{path = targetFile, op = "delete"}} -- 3675
			}) -- 3675
		end -- 3675
		if action.tool == "build" then -- 3675
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3679
			return ____awaiter_resolve(nil, result) -- 3679
		end -- 3679
		if action.tool == "spawn_sub_agent" then -- 3679
			if not shared.spawnSubAgent then -- 3679
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3679
			end -- 3679
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3679
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3679
			end -- 3679
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3692
				params.filesHint, -- 3693
				function(____, item) return type(item) == "string" end -- 3693
			) or nil -- 3693
			local result = __TS__Await(shared.spawnSubAgent({ -- 3695
				parentSessionId = shared.sessionId, -- 3696
				projectRoot = shared.workingDir, -- 3697
				title = type(params.title) == "string" and params.title or "Sub", -- 3698
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3699
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3700
				filesHint = filesHint -- 3701
			})) -- 3701
			if not result.success then -- 3701
				return ____awaiter_resolve(nil, result) -- 3701
			end -- 3701
			return ____awaiter_resolve(nil, { -- 3701
				success = true, -- 3707
				sessionId = result.sessionId, -- 3708
				taskId = result.taskId, -- 3709
				title = result.title, -- 3710
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3711
			}) -- 3711
		end -- 3711
		if action.tool == "list_sub_agents" then -- 3711
			if not shared.listSubAgents then -- 3711
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3711
			end -- 3711
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3711
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3711
			end -- 3711
			local result = __TS__Await(shared.listSubAgents({ -- 3721
				sessionId = shared.sessionId, -- 3722
				projectRoot = shared.workingDir, -- 3723
				status = type(params.status) == "string" and params.status or nil, -- 3724
				limit = type(params.limit) == "number" and params.limit or nil, -- 3725
				offset = type(params.offset) == "number" and params.offset or nil, -- 3726
				query = type(params.query) == "string" and params.query or nil -- 3727
			})) -- 3727
			return ____awaiter_resolve(nil, result) -- 3727
		end -- 3727
		if action.tool == "edit_file" then -- 3727
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3732
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3735
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3736
			if __TS__StringTrim(path) == "" then -- 3736
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3736
			end -- 3736
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3738
			return ____awaiter_resolve( -- 3738
				nil, -- 3738
				actionNode:exec({ -- 3739
					path = path, -- 3740
					oldStr = oldStr, -- 3741
					newStr = newStr, -- 3742
					taskId = shared.taskId, -- 3743
					workDir = shared.workingDir -- 3744
				}) -- 3744
			) -- 3744
		end -- 3744
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3744
	end) -- 3744
end -- 3744
function sanitizeToolActionResultForHistory(action, result) -- 3750
	if action.tool == "read_file" then -- 3750
		return sanitizeReadResultForHistory(action.tool, result) -- 3752
	end -- 3752
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3752
		return sanitizeSearchResultForHistory(action.tool, result) -- 3755
	end -- 3755
	if action.tool == "glob_files" then -- 3755
		return sanitizeListFilesResultForHistory(result) -- 3758
	end -- 3758
	if action.tool == "build" then -- 3758
		return sanitizeBuildResultForHistory(result) -- 3761
	end -- 3761
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3761
		if result.success ~= true then -- 3761
			return result -- 3764
		end -- 3764
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3764
			return result -- 3765
		end -- 3765
		if isArray(result.fileContext) then -- 3765
			return result -- 3766
		end -- 3766
		local contextLimits = { -- 3768
			fullContentChars = 12000, -- 3769
			previewChars = 4000, -- 3770
			diffChars = 8000, -- 3771
			totalChars = 24000, -- 3772
			maxFiles = 8 -- 3773
		} -- 3773
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3775
			if maxChars <= 0 then -- 3775
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3776
			end -- 3776
			if #sourceText <= maxChars then -- 3776
				return sourceText -- 3777
			end -- 3777
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3778
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3779
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3780
		end -- 3775
		local function countLines(sourceText) -- 3782
			if sourceText == "" then -- 3782
				return 0 -- 3783
			end -- 3783
			return #__TS__StringSplit(sourceText, "\n") -- 3784
		end -- 3782
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3786
			if beforeContent == afterContent then -- 3786
				return "" -- 3787
			end -- 3787
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3788
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3789
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3791
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3791
				firstChangedLine = firstChangedLine + 1 -- 3797
			end -- 3797
			local lastChangedBeforeLine = #beforeLines - 1 -- 3799
			local lastChangedAfterLine = #afterLines - 1 -- 3800
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3800
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3806
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3807
			end -- 3807
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3809
			local previewEndLine = math.max( -- 3810
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3811
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3812
			) -- 3812
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3814
			do -- 3814
				local lineIndex = previewStartLine -- 3815
				while lineIndex <= previewEndLine do -- 3815
					do -- 3815
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3816
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3817
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3818
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3819
						if not beforeChanged and not afterChanged then -- 3819
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3821
							if contextLine ~= nil then -- 3821
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3822
							end -- 3822
							goto __continue599 -- 3823
						end -- 3823
						if beforeChanged and beforeLine ~= nil then -- 3823
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3825
						end -- 3825
						if afterChanged and afterLine ~= nil then -- 3825
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3826
						end -- 3826
					end -- 3826
					::__continue599:: -- 3826
					lineIndex = lineIndex + 1 -- 3815
				end -- 3815
			end -- 3815
			return truncateContextSnippet( -- 3828
				table.concat(unifiedDiffLines, "\n"), -- 3828
				maxChars, -- 3828
				"diff" -- 3828
			) -- 3828
		end -- 3786
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3831
		if not checkpointDiff.success then -- 3831
			return result -- 3832
		end -- 3832
		local remainingContextBudget = contextLimits.totalChars -- 3833
		local fileContextItems = {} -- 3834
		local changedFiles = checkpointDiff.files -- 3835
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3836
		do -- 3836
			local fileIndex = 0 -- 3837
			while fileIndex < maxContextFiles do -- 3837
				if remainingContextBudget <= 0 then -- 3837
					break -- 3838
				end -- 3838
				local changedFile = changedFiles[fileIndex + 1] -- 3839
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3840
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3841
				local contextItem = { -- 3842
					path = changedFile.path, -- 3843
					op = changedFile.op, -- 3844
					checkpointId = result.checkpointId, -- 3845
					checkpointSeq = result.checkpointSeq, -- 3846
					beforeExists = changedFile.beforeExists, -- 3847
					afterExists = changedFile.afterExists, -- 3848
					beforeBytes = #beforeContent, -- 3849
					afterBytes = #afterContent, -- 3850
					diffPreview = "", -- 3851
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3852
					contentTruncated = false, -- 3853
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3854
				} -- 3854
				if changedFile.afterExists then -- 3854
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3854
						contextItem.afterContent = afterContent -- 3858
						remainingContextBudget = remainingContextBudget - #afterContent -- 3859
					else -- 3859
						contextItem.afterContentPreview = truncateContextSnippet( -- 3861
							afterContent, -- 3862
							math.min( -- 3863
								contextLimits.previewChars, -- 3863
								math.max(400, remainingContextBudget) -- 3863
							), -- 3863
							"afterContent" -- 3864
						) -- 3864
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3866
						contextItem.contentTruncated = true -- 3867
					end -- 3867
				end -- 3867
				local diffPreview = buildUnifiedDiffPreview( -- 3870
					changedFile.path, -- 3871
					beforeContent, -- 3872
					afterContent, -- 3873
					math.min( -- 3874
						contextLimits.diffChars, -- 3874
						math.max(400, remainingContextBudget) -- 3874
					) -- 3874
				) -- 3874
				contextItem.diffPreview = diffPreview -- 3876
				remainingContextBudget = remainingContextBudget - #diffPreview -- 3877
				if not changedFile.afterExists and beforeContent ~= "" then -- 3877
					contextItem.beforeContentPreview = truncateContextSnippet( -- 3879
						beforeContent, -- 3880
						math.min( -- 3881
							contextLimits.previewChars, -- 3881
							math.max(400, remainingContextBudget) -- 3881
						), -- 3881
						"beforeContent" -- 3882
					) -- 3882
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 3884
					if #beforeContent > contextLimits.previewChars then -- 3884
						contextItem.contentTruncated = true -- 3885
					end -- 3885
				end -- 3885
				fileContextItems[#fileContextItems + 1] = contextItem -- 3887
				fileIndex = fileIndex + 1 -- 3837
			end -- 3837
		end -- 3837
		if #fileContextItems == 0 then -- 3837
			return result -- 3889
		end -- 3889
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 3890
	end -- 3890
	return result -- 3897
end -- 3897
function emitAgentTaskFinishEvent(shared, success, message) -- 4064
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 4065
	emitAgentEvent(shared, { -- 4071
		type = "task_finished", -- 4072
		sessionId = shared.sessionId, -- 4073
		taskId = shared.taskId, -- 4074
		success = result.success, -- 4075
		message = result.message, -- 4076
		steps = result.steps -- 4077
	}) -- 4077
	return result -- 4079
end -- 4079
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
						arguments = toJson(action.params) -- 1781
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
	local sanitized = {} -- 2302
	local droppedAssistantToolCalls = 0 -- 2303
	local droppedToolResults = 0 -- 2304
	do -- 2304
		local i = 0 -- 2305
		while i < #messages do -- 2305
			do -- 2305
				local message = messages[i + 1] -- 2306
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2306
					local requiredIds = {} -- 2308
					do -- 2308
						local j = 0 -- 2309
						while j < #message.tool_calls do -- 2309
							local toolCall = message.tool_calls[j + 1] -- 2310
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2311
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2311
								requiredIds[#requiredIds + 1] = id -- 2313
							end -- 2313
							j = j + 1 -- 2309
						end -- 2309
					end -- 2309
					if #requiredIds == 0 then -- 2309
						sanitized[#sanitized + 1] = message -- 2317
						goto __continue363 -- 2318
					end -- 2318
					local matchedIds = {} -- 2320
					local matchedTools = {} -- 2321
					local j = i + 1 -- 2322
					while j < #messages do -- 2322
						local toolMessage = messages[j + 1] -- 2324
						if toolMessage.role ~= "tool" then -- 2324
							break -- 2325
						end -- 2325
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2326
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2326
							matchedIds[toolCallId] = true -- 2328
							matchedTools[#matchedTools + 1] = toolMessage -- 2329
						else -- 2329
							droppedToolResults = droppedToolResults + 1 -- 2331
						end -- 2331
						j = j + 1 -- 2333
					end -- 2333
					local complete = true -- 2335
					do -- 2335
						local j = 0 -- 2336
						while j < #requiredIds do -- 2336
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2336
								complete = false -- 2338
								break -- 2339
							end -- 2339
							j = j + 1 -- 2336
						end -- 2336
					end -- 2336
					if complete then -- 2336
						__TS__ArrayPush( -- 2343
							sanitized, -- 2343
							message, -- 2343
							table.unpack(matchedTools) -- 2343
						) -- 2343
					else -- 2343
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2345
						droppedToolResults = droppedToolResults + #matchedTools -- 2346
					end -- 2346
					i = j - 1 -- 2348
					goto __continue363 -- 2349
				end -- 2349
				if message.role == "tool" then -- 2349
					droppedToolResults = droppedToolResults + 1 -- 2352
					goto __continue363 -- 2353
				end -- 2353
				sanitized[#sanitized + 1] = message -- 2355
			end -- 2355
			::__continue363:: -- 2355
			i = i + 1 -- 2305
		end -- 2305
	end -- 2305
	return sanitized -- 2357
end -- 2301
local function getUnconsolidatedMessages(shared) -- 2360
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2361
end -- 2360
local function getFinalDecisionTurnPrompt(shared) -- 2364
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2365
end -- 2364
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2370
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2370
		return messages -- 2371
	end -- 2371
	local next = __TS__ArrayMap( -- 2372
		messages, -- 2372
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2372
	) -- 2372
	do -- 2372
		local i = #next - 1 -- 2373
		while i >= 0 do -- 2373
			do -- 2373
				local message = next[i + 1] -- 2374
				if message.role ~= "assistant" and message.role ~= "user" then -- 2374
					goto __continue385 -- 2375
				end -- 2375
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2376
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2377
				return next -- 2380
			end -- 2380
			::__continue385:: -- 2380
			i = i - 1 -- 2373
		end -- 2373
	end -- 2373
	next[#next + 1] = {role = "user", content = prompt} -- 2382
	return next -- 2383
end -- 2370
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2386
	if attempt == nil then -- 2386
		attempt = 1 -- 2389
	end -- 2389
	if decisionMode == nil then -- 2389
		decisionMode = shared.decisionMode -- 2391
	end -- 2391
	local messages = { -- 2393
		{ -- 2394
			role = "system", -- 2394
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2394
		}, -- 2394
		table.unpack(getUnconsolidatedMessages(shared)) -- 2395
	} -- 2395
	if shared.step + 1 >= shared.maxSteps then -- 2395
		messages = appendPromptToLatestDecisionMessage( -- 2398
			messages, -- 2398
			getFinalDecisionTurnPrompt(shared) -- 2398
		) -- 2398
	end -- 2398
	if lastError and lastError ~= "" then -- 2398
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2401
		messages[#messages + 1] = { -- 2404
			role = "user", -- 2405
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2406
		} -- 2406
	end -- 2406
	return messages -- 2413
end -- 2386
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2420
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2427
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2428
	local repairPrompt = replacePromptVars( -- 2436
		shared.promptPack.xmlDecisionRepairPrompt, -- 2436
		{ -- 2436
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2437
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2438
			CANDIDATE_SECTION = candidateSection, -- 2439
			LAST_ERROR = lastError, -- 2440
			ATTEMPT = tostring(attempt) -- 2441
		} -- 2441
	) -- 2441
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2443
end -- 2420
local function tryParseAndValidateDecision(rawText) -- 2455
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2456
	if not parsed.success then -- 2456
		return {success = false, message = parsed.message, raw = rawText} -- 2458
	end -- 2458
	local decision = parseDecisionObject(parsed.obj) -- 2460
	if not decision.success then -- 2460
		return {success = false, message = decision.message, raw = rawText} -- 2462
	end -- 2462
	local validation = validateDecision(decision.tool, decision.params) -- 2464
	if not validation.success then -- 2464
		return {success = false, message = validation.message, raw = rawText} -- 2466
	end -- 2466
	decision.params = validation.params -- 2468
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2469
	return decision -- 2470
end -- 2455
local function normalizeLineEndings(text) -- 2473
	local res = string.gsub(text, "\r\n", "\n") -- 2474
	res = string.gsub(res, "\r", "\n") -- 2475
	return res -- 2476
end -- 2473
local function countOccurrences(text, searchStr) -- 2479
	if searchStr == "" then -- 2479
		return 0 -- 2480
	end -- 2480
	local count = 0 -- 2481
	local pos = 0 -- 2482
	while true do -- 2482
		local idx = (string.find( -- 2484
			text, -- 2484
			searchStr, -- 2484
			math.max(pos + 1, 1), -- 2484
			true -- 2484
		) or 0) - 1 -- 2484
		if idx < 0 then -- 2484
			break -- 2485
		end -- 2485
		count = count + 1 -- 2486
		pos = idx + #searchStr -- 2487
	end -- 2487
	return count -- 2489
end -- 2479
local function replaceFirst(text, oldStr, newStr) -- 2492
	if oldStr == "" then -- 2492
		return text -- 2493
	end -- 2493
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2494
	if idx < 0 then -- 2494
		return text -- 2495
	end -- 2495
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2496
end -- 2492
local function splitLines(text) -- 2499
	return __TS__StringSplit(text, "\n") -- 2500
end -- 2499
local function getLeadingWhitespace(text) -- 2503
	local i = 0 -- 2504
	while i < #text do -- 2504
		local ch = __TS__StringAccess(text, i) -- 2506
		if ch ~= " " and ch ~= "\t" then -- 2506
			break -- 2507
		end -- 2507
		i = i + 1 -- 2508
	end -- 2508
	return __TS__StringSubstring(text, 0, i) -- 2510
end -- 2503
local function getCommonIndentPrefix(lines) -- 2513
	local common -- 2514
	do -- 2514
		local i = 0 -- 2515
		while i < #lines do -- 2515
			do -- 2515
				local line = lines[i + 1] -- 2516
				if __TS__StringTrim(line) == "" then -- 2516
					goto __continue410 -- 2517
				end -- 2517
				local indent = getLeadingWhitespace(line) -- 2518
				if common == nil then -- 2518
					common = indent -- 2520
					goto __continue410 -- 2521
				end -- 2521
				local j = 0 -- 2523
				local maxLen = math.min(#common, #indent) -- 2524
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2524
					j = j + 1 -- 2526
				end -- 2526
				common = __TS__StringSubstring(common, 0, j) -- 2528
				if common == "" then -- 2528
					break -- 2529
				end -- 2529
			end -- 2529
			::__continue410:: -- 2529
			i = i + 1 -- 2515
		end -- 2515
	end -- 2515
	return common or "" -- 2531
end -- 2513
local function removeIndentPrefix(line, indent) -- 2534
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2534
		return __TS__StringSubstring(line, #indent) -- 2536
	end -- 2536
	local lineIndent = getLeadingWhitespace(line) -- 2538
	local j = 0 -- 2539
	local maxLen = math.min(#lineIndent, #indent) -- 2540
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2540
		j = j + 1 -- 2542
	end -- 2542
	return __TS__StringSubstring(line, j) -- 2544
end -- 2534
local function dedentLines(lines) -- 2547
	local indent = getCommonIndentPrefix(lines) -- 2548
	return { -- 2549
		indent = indent, -- 2550
		lines = __TS__ArrayMap( -- 2551
			lines, -- 2551
			function(____, line) return removeIndentPrefix(line, indent) end -- 2551
		) -- 2551
	} -- 2551
end -- 2547
local function joinLines(lines) -- 2555
	return table.concat(lines, "\n") -- 2556
end -- 2555
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2559
	local contentLines = splitLines(content) -- 2564
	local oldLines = splitLines(oldStr) -- 2565
	if #oldLines == 0 then -- 2565
		return {success = false, message = "old_str not found in file"} -- 2567
	end -- 2567
	local dedentedOld = dedentLines(oldLines) -- 2569
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2570
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2571
	local matches = {} -- 2572
	do -- 2572
		local start = 0 -- 2573
		while start <= #contentLines - #oldLines do -- 2573
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2574
			local dedentedCandidate = dedentLines(candidateLines) -- 2575
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2575
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2577
			end -- 2577
			start = start + 1 -- 2573
		end -- 2573
	end -- 2573
	if #matches == 0 then -- 2573
		return {success = false, message = "old_str not found in file"} -- 2585
	end -- 2585
	if #matches > 1 then -- 2585
		return { -- 2588
			success = false, -- 2589
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2590
		} -- 2590
	end -- 2590
	local match = matches[1] -- 2593
	local rebuiltNewLines = __TS__ArrayMap( -- 2594
		dedentedNew.lines, -- 2594
		function(____, line) return line == "" and "" or match.indent .. line end -- 2594
	) -- 2594
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2594
	__TS__SparseArrayPush( -- 2594
		____array_46, -- 2594
		table.unpack(rebuiltNewLines) -- 2597
	) -- 2597
	__TS__SparseArrayPush( -- 2597
		____array_46, -- 2597
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2598
	) -- 2598
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2595
	return { -- 2600
		success = true, -- 2600
		content = joinLines(nextLines) -- 2600
	} -- 2600
end -- 2559
local MainDecisionAgent = __TS__Class() -- 2603
MainDecisionAgent.name = "MainDecisionAgent" -- 2603
__TS__ClassExtends(MainDecisionAgent, Node) -- 2603
function MainDecisionAgent.prototype.prep(self, shared) -- 2604
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2604
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2604
			return ____awaiter_resolve(nil, {shared = shared}) -- 2604
		end -- 2604
		__TS__Await(maybeCompressHistory(shared)) -- 2609
		return ____awaiter_resolve(nil, {shared = shared}) -- 2609
	end) -- 2609
end -- 2604
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2614
	if attempt == nil then -- 2614
		attempt = 1 -- 2617
	end -- 2617
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2617
		if shared.stopToken.stopped then -- 2617
			return ____awaiter_resolve( -- 2617
				nil, -- 2617
				{ -- 2621
					success = false, -- 2621
					message = getCancelledReason(shared) -- 2621
				} -- 2621
			) -- 2621
		end -- 2621
		Log( -- 2623
			"Info", -- 2623
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2623
		) -- 2623
		local tools = buildDecisionToolSchema(shared) -- 2624
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2625
		local stepId = shared.step + 1 -- 2626
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2627
		emitLLMContextMetrics( -- 2631
			shared, -- 2631
			stepId, -- 2631
			"decision_tool_calling", -- 2631
			messages, -- 2631
			llmOptions -- 2631
		) -- 2631
		saveStepLLMDebugInput( -- 2632
			shared, -- 2632
			stepId, -- 2632
			"decision_tool_calling", -- 2632
			messages, -- 2632
			llmOptions -- 2632
		) -- 2632
		local lastStreamContent = "" -- 2633
		local lastStreamReasoning = "" -- 2634
		local preExecutedResults = __TS__New(Map) -- 2635
		shared.preExecutedResults = preExecutedResults -- 2636
		local res = __TS__Await(callLLMStreamAggregated( -- 2637
			messages, -- 2638
			llmOptions, -- 2639
			shared.stopToken, -- 2640
			shared.llmConfig, -- 2641
			function(response) -- 2642
				local ____opt_49 = response.choices -- 2642
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2642
				local streamMessage = ____opt_47 and ____opt_47.message -- 2643
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2644
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2647
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2647
					return -- 2651
				end -- 2651
				lastStreamContent = nextContent -- 2653
				lastStreamReasoning = nextReasoning -- 2654
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2655
			end, -- 2642
			function(tc) -- 2657
				if shared.stopToken.stopped then -- 2657
					return -- 2658
				end -- 2658
				local action = createPreExecutableActionFromStream(shared, tc) -- 2659
				if not action or preExecutedResults:has(action.toolCallId) then -- 2659
					return -- 2660
				end -- 2660
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2661
				preExecutedResults:set( -- 2662
					action.toolCallId, -- 2662
					createPreExecutedToolResult(shared, action) -- 2662
				) -- 2662
			end -- 2657
		)) -- 2657
		if shared.stopToken.stopped then -- 2657
			clearPreExecutedResults(shared) -- 2666
			return ____awaiter_resolve( -- 2666
				nil, -- 2666
				{ -- 2667
					success = false, -- 2667
					message = getCancelledReason(shared) -- 2667
				} -- 2667
			) -- 2667
		end -- 2667
		if not res.success then -- 2667
			saveStepLLMDebugOutput( -- 2670
				shared, -- 2670
				stepId, -- 2670
				"decision_tool_calling", -- 2670
				res.raw or res.message, -- 2670
				{success = false} -- 2670
			) -- 2670
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2671
			clearPreExecutedResults(shared) -- 2672
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2672
		end -- 2672
		saveStepLLMDebugOutput( -- 2675
			shared, -- 2675
			stepId, -- 2675
			"decision_tool_calling", -- 2675
			encodeDebugJSON(res.response), -- 2675
			{success = true} -- 2675
		) -- 2675
		local choice = res.response.choices and res.response.choices[1] -- 2676
		local message = choice and choice.message -- 2677
		local toolCalls = message and message.tool_calls -- 2678
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2679
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2682
		Log( -- 2685
			"Info", -- 2685
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2685
		) -- 2685
		if not toolCalls or #toolCalls == 0 then -- 2685
			if messageContent and messageContent ~= "" then -- 2685
				Log( -- 2688
					"Info", -- 2688
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2688
				) -- 2688
				clearPreExecutedResults(shared) -- 2689
				return ____awaiter_resolve(nil, { -- 2689
					success = true, -- 2691
					tool = "finish", -- 2692
					params = {}, -- 2693
					reason = messageContent, -- 2694
					reasoningContent = reasoningContent, -- 2695
					directSummary = messageContent -- 2696
				}) -- 2696
			end -- 2696
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2699
			clearPreExecutedResults(shared) -- 2700
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2700
		end -- 2700
		local decisions = {} -- 2707
		do -- 2707
			local i = 0 -- 2708
			while i < #toolCalls do -- 2708
				local toolCall = toolCalls[i + 1] -- 2709
				local fn = toolCall and toolCall["function"] -- 2710
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2710
					Log( -- 2712
						"Error", -- 2712
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2712
					) -- 2712
					clearPreExecutedResults(shared) -- 2713
					return ____awaiter_resolve( -- 2713
						nil, -- 2713
						{ -- 2714
							success = false, -- 2715
							message = "missing function name for tool call " .. tostring(i + 1), -- 2716
							raw = messageContent -- 2717
						} -- 2717
					) -- 2717
				end -- 2717
				local functionName = fn.name -- 2720
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2721
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2722
				Log( -- 2725
					"Info", -- 2725
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2725
				) -- 2725
				local decision = parseAndValidateToolCallDecision( -- 2726
					shared, -- 2727
					functionName, -- 2728
					argsText, -- 2729
					toolCallId, -- 2730
					messageContent, -- 2731
					reasoningContent -- 2732
				) -- 2732
				if not decision.success then -- 2732
					Log( -- 2735
						"Error", -- 2735
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2735
					) -- 2735
					clearPreExecutedResults(shared) -- 2736
					return ____awaiter_resolve(nil, decision) -- 2736
				end -- 2736
				decisions[#decisions + 1] = decision -- 2739
				i = i + 1 -- 2708
			end -- 2708
		end -- 2708
		if #decisions == 1 then -- 2708
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2742
			return ____awaiter_resolve(nil, decisions[1]) -- 2742
		end -- 2742
		do -- 2742
			local i = 0 -- 2745
			while i < #decisions do -- 2745
				if decisions[i + 1].tool == "finish" then -- 2745
					clearPreExecutedResults(shared) -- 2747
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2747
				end -- 2747
				i = i + 1 -- 2745
			end -- 2745
		end -- 2745
		Log( -- 2755
			"Info", -- 2755
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2755
				__TS__ArrayMap( -- 2755
					decisions, -- 2755
					function(____, decision) return decision.tool end -- 2755
				), -- 2755
				"," -- 2755
			) -- 2755
		) -- 2755
		return ____awaiter_resolve(nil, { -- 2755
			success = true, -- 2757
			kind = "batch", -- 2758
			decisions = decisions, -- 2759
			content = messageContent, -- 2760
			reasoningContent = reasoningContent -- 2761
		}) -- 2761
	end) -- 2761
end -- 2614
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2765
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2765
		Log( -- 2770
			"Info", -- 2770
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2770
		) -- 2770
		local lastError = initialError -- 2771
		local candidateRaw = "" -- 2772
		do -- 2772
			local attempt = 0 -- 2773
			while attempt < shared.llmMaxTry do -- 2773
				do -- 2773
					Log( -- 2774
						"Info", -- 2774
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2774
					) -- 2774
					local messages = buildXmlRepairMessages( -- 2775
						shared, -- 2776
						originalRaw, -- 2777
						candidateRaw, -- 2778
						lastError, -- 2779
						attempt + 1 -- 2780
					) -- 2780
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2782
					if shared.stopToken.stopped then -- 2782
						return ____awaiter_resolve( -- 2782
							nil, -- 2782
							{ -- 2784
								success = false, -- 2784
								message = getCancelledReason(shared) -- 2784
							} -- 2784
						) -- 2784
					end -- 2784
					if not llmRes.success then -- 2784
						lastError = llmRes.message -- 2787
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2788
						goto __continue453 -- 2789
					end -- 2789
					candidateRaw = llmRes.text -- 2791
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2792
					if decision.success then -- 2792
						decision.reasoningContent = llmRes.reasoningContent -- 2794
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2795
						return ____awaiter_resolve(nil, decision) -- 2795
					end -- 2795
					lastError = decision.message -- 2798
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2799
				end -- 2799
				::__continue453:: -- 2799
				attempt = attempt + 1 -- 2773
			end -- 2773
		end -- 2773
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2801
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2801
	end) -- 2801
end -- 2765
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2809
	if attempt == nil then -- 2809
		attempt = 1 -- 2812
	end -- 2812
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2812
		local messages = buildDecisionMessages( -- 2815
			shared, -- 2816
			lastError, -- 2817
			attempt, -- 2818
			lastRaw, -- 2819
			"xml" -- 2820
		) -- 2820
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2822
		if shared.stopToken.stopped then -- 2822
			return ____awaiter_resolve( -- 2822
				nil, -- 2822
				{ -- 2824
					success = false, -- 2824
					message = getCancelledReason(shared) -- 2824
				} -- 2824
			) -- 2824
		end -- 2824
		if not llmRes.success then -- 2824
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2824
		end -- 2824
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2833
		if decision.success then -- 2833
			decision.reasoningContent = llmRes.reasoningContent -- 2835
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2835
				return ____awaiter_resolve( -- 2835
					nil, -- 2835
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2837
				) -- 2837
			end -- 2837
			return ____awaiter_resolve(nil, decision) -- 2837
		end -- 2837
		return ____awaiter_resolve( -- 2837
			nil, -- 2837
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2845
		) -- 2845
	end) -- 2845
end -- 2809
function MainDecisionAgent.prototype.exec(self, input) -- 2848
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2848
		local shared = input.shared -- 2849
		if shared.stopToken.stopped then -- 2849
			return ____awaiter_resolve( -- 2849
				nil, -- 2849
				{ -- 2851
					success = false, -- 2851
					message = getCancelledReason(shared) -- 2851
				} -- 2851
			) -- 2851
		end -- 2851
		if shared.step >= shared.maxSteps then -- 2851
			Log( -- 2854
				"Warn", -- 2854
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2854
			) -- 2854
			return ____awaiter_resolve( -- 2854
				nil, -- 2854
				{ -- 2855
					success = false, -- 2855
					message = getMaxStepsReachedReason(shared) -- 2855
				} -- 2855
			) -- 2855
		end -- 2855
		if shared.decisionMode == "tool_calling" then -- 2855
			Log( -- 2859
				"Info", -- 2859
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2859
			) -- 2859
			local lastError = "tool calling validation failed" -- 2860
			local lastRaw = "" -- 2861
			local shouldFallbackToXml = false -- 2862
			do -- 2862
				local attempt = 0 -- 2863
				while attempt < shared.llmMaxTry do -- 2863
					Log( -- 2864
						"Info", -- 2864
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2864
					) -- 2864
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2865
					if shared.stopToken.stopped then -- 2865
						return ____awaiter_resolve( -- 2865
							nil, -- 2865
							{ -- 2872
								success = false, -- 2872
								message = getCancelledReason(shared) -- 2872
							} -- 2872
						) -- 2872
					end -- 2872
					if decision.success then -- 2872
						return ____awaiter_resolve(nil, decision) -- 2872
					end -- 2872
					lastError = decision.message -- 2877
					lastRaw = decision.raw or "" -- 2878
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2879
					if lastError == "missing tool call" then -- 2879
						shouldFallbackToXml = true -- 2881
						break -- 2882
					end -- 2882
					attempt = attempt + 1 -- 2863
				end -- 2863
			end -- 2863
			if shouldFallbackToXml then -- 2863
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2886
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2887
				do -- 2887
					local attempt = 0 -- 2888
					while attempt < shared.llmMaxTry do -- 2888
						Log( -- 2889
							"Info", -- 2889
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2889
						) -- 2889
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2890
						if shared.stopToken.stopped then -- 2890
							return ____awaiter_resolve( -- 2890
								nil, -- 2890
								{ -- 2897
									success = false, -- 2897
									message = getCancelledReason(shared) -- 2897
								} -- 2897
							) -- 2897
						end -- 2897
						if decision.success then -- 2897
							return ____awaiter_resolve(nil, decision) -- 2897
						end -- 2897
						lastError = decision.message -- 2902
						lastRaw = decision.raw or "" -- 2903
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2904
						attempt = attempt + 1 -- 2888
					end -- 2888
				end -- 2888
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2906
				return ____awaiter_resolve( -- 2906
					nil, -- 2906
					{ -- 2907
						success = false, -- 2907
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2907
					} -- 2907
				) -- 2907
			end -- 2907
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2909
			return ____awaiter_resolve( -- 2909
				nil, -- 2909
				{ -- 2910
					success = false, -- 2910
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2910
				} -- 2910
			) -- 2910
		end -- 2910
		local lastError = "xml validation failed" -- 2913
		local lastRaw = "" -- 2914
		do -- 2914
			local attempt = 0 -- 2915
			while attempt < shared.llmMaxTry do -- 2915
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2916
				if shared.stopToken.stopped then -- 2916
					return ____awaiter_resolve( -- 2916
						nil, -- 2916
						{ -- 2925
							success = false, -- 2925
							message = getCancelledReason(shared) -- 2925
						} -- 2925
					) -- 2925
				end -- 2925
				if decision.success then -- 2925
					return ____awaiter_resolve(nil, decision) -- 2925
				end -- 2925
				lastError = decision.message -- 2930
				lastRaw = decision.raw or "" -- 2931
				attempt = attempt + 1 -- 2915
			end -- 2915
		end -- 2915
		return ____awaiter_resolve( -- 2915
			nil, -- 2915
			{ -- 2933
				success = false, -- 2933
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2933
			} -- 2933
		) -- 2933
	end) -- 2933
end -- 2848
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2936
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2936
		local result = execRes -- 2937
		if not result.success then -- 2937
			if shared.stopToken.stopped then -- 2937
				shared.error = getCancelledReason(shared) -- 2940
				shared.done = true -- 2941
				return ____awaiter_resolve(nil, "done") -- 2941
			end -- 2941
			shared.error = result.message -- 2944
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2945
			shared.done = true -- 2946
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2947
			persistHistoryState(shared) -- 2951
			return ____awaiter_resolve(nil, "done") -- 2951
		end -- 2951
		if isDecisionBatchSuccess(result) then -- 2951
			local startStep = shared.step -- 2955
			local actions = {} -- 2956
			do -- 2956
				local i = 0 -- 2957
				while i < #result.decisions do -- 2957
					local decision = result.decisions[i + 1] -- 2958
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2959
					local step = startStep + i + 1 -- 2960
					local ____temp_55 -- 2961
					if i == 0 then -- 2961
						____temp_55 = decision.reason -- 2961
					else -- 2961
						____temp_55 = "" -- 2961
					end -- 2961
					local actionReason = ____temp_55 -- 2961
					local ____temp_56 -- 2962
					if i == 0 then -- 2962
						____temp_56 = decision.reasoningContent -- 2962
					else -- 2962
						____temp_56 = nil -- 2962
					end -- 2962
					local actionReasoningContent = ____temp_56 -- 2962
					emitAgentEvent(shared, { -- 2963
						type = "decision_made", -- 2964
						sessionId = shared.sessionId, -- 2965
						taskId = shared.taskId, -- 2966
						step = step, -- 2967
						tool = decision.tool, -- 2968
						reason = actionReason, -- 2969
						reasoningContent = actionReasoningContent, -- 2970
						params = decision.params -- 2971
					}) -- 2971
					local action = { -- 2973
						step = step, -- 2974
						toolCallId = toolCallId, -- 2975
						tool = decision.tool, -- 2976
						reason = actionReason or "", -- 2977
						reasoningContent = actionReasoningContent, -- 2978
						params = decision.params, -- 2979
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2980
					} -- 2980
					local ____shared_history_57 = shared.history -- 2980
					____shared_history_57[#____shared_history_57 + 1] = action -- 2982
					actions[#actions + 1] = action -- 2983
					i = i + 1 -- 2957
				end -- 2957
			end -- 2957
			shared.step = startStep + #actions -- 2985
			shared.pendingToolActions = actions -- 2986
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2987
			persistHistoryState(shared) -- 2993
			return ____awaiter_resolve(nil, "batch_tools") -- 2993
		end -- 2993
		if result.directSummary and result.directSummary ~= "" then -- 2993
			shared.response = result.directSummary -- 2997
			shared.done = true -- 2998
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2999
			persistHistoryState(shared) -- 3004
			return ____awaiter_resolve(nil, "done") -- 3004
		end -- 3004
		if result.tool == "finish" then -- 3004
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3008
			shared.response = finalMessage -- 3009
			shared.done = true -- 3010
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3011
			persistHistoryState(shared) -- 3016
			return ____awaiter_resolve(nil, "done") -- 3016
		end -- 3016
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3019
		shared.step = shared.step + 1 -- 3020
		local step = shared.step -- 3021
		emitAgentEvent(shared, { -- 3022
			type = "decision_made", -- 3023
			sessionId = shared.sessionId, -- 3024
			taskId = shared.taskId, -- 3025
			step = step, -- 3026
			tool = result.tool, -- 3027
			reason = result.reason, -- 3028
			reasoningContent = result.reasoningContent, -- 3029
			params = result.params -- 3030
		}) -- 3030
		local ____shared_history_58 = shared.history -- 3030
		____shared_history_58[#____shared_history_58 + 1] = { -- 3032
			step = step, -- 3033
			toolCallId = toolCallId, -- 3034
			tool = result.tool, -- 3035
			reason = result.reason or "", -- 3036
			reasoningContent = result.reasoningContent, -- 3037
			params = result.params, -- 3038
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3039
		} -- 3039
		local action = shared.history[#shared.history] -- 3041
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3042
		if canPreExecuteTool(action.tool) then -- 3042
			shared.pendingToolActions = {action} -- 3044
			persistHistoryState(shared) -- 3045
			return ____awaiter_resolve(nil, "batch_tools") -- 3045
		end -- 3045
		clearPreExecutedResults(shared) -- 3048
		persistHistoryState(shared) -- 3049
		return ____awaiter_resolve(nil, result.tool) -- 3049
	end) -- 3049
end -- 2936
local ReadFileAction = __TS__Class() -- 3054
ReadFileAction.name = "ReadFileAction" -- 3054
__TS__ClassExtends(ReadFileAction, Node) -- 3054
function ReadFileAction.prototype.prep(self, shared) -- 3055
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3055
		local last = shared.history[#shared.history] -- 3056
		if not last then -- 3056
			error( -- 3057
				__TS__New(Error, "no history"), -- 3057
				0 -- 3057
			) -- 3057
		end -- 3057
		emitAgentStartEvent(shared, last) -- 3058
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3059
		if __TS__StringTrim(path) == "" then -- 3059
			error( -- 3062
				__TS__New(Error, "missing path"), -- 3062
				0 -- 3062
			) -- 3062
		end -- 3062
		local ____path_61 = path -- 3064
		local ____shared_workingDir_62 = shared.workingDir -- 3066
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 3067
		local ____last_params_startLine_59 = last.params.startLine -- 3068
		if ____last_params_startLine_59 == nil then -- 3068
			____last_params_startLine_59 = 1 -- 3068
		end -- 3068
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 3068
		local ____last_params_endLine_60 = last.params.endLine -- 3069
		if ____last_params_endLine_60 == nil then -- 3069
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 3069
		end -- 3069
		return ____awaiter_resolve( -- 3069
			nil, -- 3069
			{ -- 3063
				path = ____path_61, -- 3064
				tool = "read_file", -- 3065
				workDir = ____shared_workingDir_62, -- 3066
				docLanguage = ____temp_63, -- 3067
				startLine = ____TS__Number_result_64, -- 3068
				endLine = __TS__Number(____last_params_endLine_60) -- 3069
			} -- 3069
		) -- 3069
	end) -- 3069
end -- 3055
function ReadFileAction.prototype.exec(self, input) -- 3073
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3073
		return ____awaiter_resolve( -- 3073
			nil, -- 3073
			Tools.readFile( -- 3074
				input.workDir, -- 3075
				input.path, -- 3076
				__TS__Number(input.startLine or 1), -- 3077
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3078
				input.docLanguage -- 3079
			) -- 3079
		) -- 3079
	end) -- 3079
end -- 3073
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3083
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3083
		local result = execRes -- 3084
		local last = shared.history[#shared.history] -- 3085
		if last ~= nil then -- 3085
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3087
			appendToolResultMessage(shared, last) -- 3088
			emitAgentFinishEvent(shared, last) -- 3089
		end -- 3089
		persistHistoryState(shared) -- 3091
		__TS__Await(maybeCompressHistory(shared)) -- 3092
		persistHistoryState(shared) -- 3093
		return ____awaiter_resolve(nil, "main") -- 3093
	end) -- 3093
end -- 3083
local SearchFilesAction = __TS__Class() -- 3098
SearchFilesAction.name = "SearchFilesAction" -- 3098
__TS__ClassExtends(SearchFilesAction, Node) -- 3098
function SearchFilesAction.prototype.prep(self, shared) -- 3099
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3099
		local last = shared.history[#shared.history] -- 3100
		if not last then -- 3100
			error( -- 3101
				__TS__New(Error, "no history"), -- 3101
				0 -- 3101
			) -- 3101
		end -- 3101
		emitAgentStartEvent(shared, last) -- 3102
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3102
	end) -- 3102
end -- 3099
function SearchFilesAction.prototype.exec(self, input) -- 3106
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3106
		local params = input.params -- 3107
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 3108
		local ____input_workDir_71 = input.workDir -- 3109
		local ____temp_72 = params.path or "" -- 3110
		local ____temp_73 = params.pattern or "" -- 3111
		local ____params_globs_74 = params.globs -- 3112
		local ____params_useRegex_75 = params.useRegex -- 3113
		local ____params_caseSensitive_76 = params.caseSensitive -- 3114
		local ____math_max_67 = math.max -- 3117
		local ____math_floor_66 = math.floor -- 3117
		local ____params_limit_65 = params.limit -- 3117
		if ____params_limit_65 == nil then -- 3117
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 3117
		end -- 3117
		local ____math_max_67_result_77 = ____math_max_67( -- 3117
			1, -- 3117
			____math_floor_66(__TS__Number(____params_limit_65)) -- 3117
		) -- 3117
		local ____math_max_70 = math.max -- 3118
		local ____math_floor_69 = math.floor -- 3118
		local ____params_offset_68 = params.offset -- 3118
		if ____params_offset_68 == nil then -- 3118
			____params_offset_68 = 0 -- 3118
		end -- 3118
		local result = __TS__Await(____Tools_searchFiles_78({ -- 3108
			workDir = ____input_workDir_71, -- 3109
			path = ____temp_72, -- 3110
			pattern = ____temp_73, -- 3111
			globs = ____params_globs_74, -- 3112
			useRegex = ____params_useRegex_75, -- 3113
			caseSensitive = ____params_caseSensitive_76, -- 3114
			includeContent = true, -- 3115
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3116
			limit = ____math_max_67_result_77, -- 3117
			offset = ____math_max_70( -- 3118
				0, -- 3118
				____math_floor_69(__TS__Number(____params_offset_68)) -- 3118
			), -- 3118
			groupByFile = params.groupByFile == true -- 3119
		})) -- 3119
		return ____awaiter_resolve(nil, result) -- 3119
	end) -- 3119
end -- 3106
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3124
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3124
		local last = shared.history[#shared.history] -- 3125
		if last ~= nil then -- 3125
			local result = execRes -- 3127
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3128
			appendToolResultMessage(shared, last) -- 3129
			emitAgentFinishEvent(shared, last) -- 3130
		end -- 3130
		persistHistoryState(shared) -- 3132
		__TS__Await(maybeCompressHistory(shared)) -- 3133
		persistHistoryState(shared) -- 3134
		return ____awaiter_resolve(nil, "main") -- 3134
	end) -- 3134
end -- 3124
local SearchDoraAPIAction = __TS__Class() -- 3139
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3139
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3139
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3140
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3140
		local last = shared.history[#shared.history] -- 3141
		if not last then -- 3141
			error( -- 3142
				__TS__New(Error, "no history"), -- 3142
				0 -- 3142
			) -- 3142
		end -- 3142
		emitAgentStartEvent(shared, last) -- 3143
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3143
	end) -- 3143
end -- 3140
function SearchDoraAPIAction.prototype.exec(self, input) -- 3147
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3147
		local params = input.params -- 3148
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 3149
		local ____temp_82 = params.pattern or "" -- 3150
		local ____temp_83 = params.docSource or "api" -- 3151
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 3152
		local ____temp_85 = params.programmingLanguage or "ts" -- 3153
		local ____math_min_81 = math.min -- 3154
		local ____math_max_80 = math.max -- 3154
		local ____params_limit_79 = params.limit -- 3154
		if ____params_limit_79 == nil then -- 3154
			____params_limit_79 = 8 -- 3154
		end -- 3154
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 3149
			pattern = ____temp_82, -- 3150
			docSource = ____temp_83, -- 3151
			docLanguage = ____temp_84, -- 3152
			programmingLanguage = ____temp_85, -- 3153
			limit = ____math_min_81( -- 3154
				SEARCH_DORA_API_LIMIT_MAX, -- 3154
				____math_max_80( -- 3154
					1, -- 3154
					__TS__Number(____params_limit_79) -- 3154
				) -- 3154
			), -- 3154
			useRegex = params.useRegex, -- 3155
			caseSensitive = false, -- 3156
			includeContent = true, -- 3157
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3158
		})) -- 3158
		return ____awaiter_resolve(nil, result) -- 3158
	end) -- 3158
end -- 3147
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3163
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3163
		local last = shared.history[#shared.history] -- 3164
		if last ~= nil then -- 3164
			local result = execRes -- 3166
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3167
			appendToolResultMessage(shared, last) -- 3168
			emitAgentFinishEvent(shared, last) -- 3169
		end -- 3169
		persistHistoryState(shared) -- 3171
		__TS__Await(maybeCompressHistory(shared)) -- 3172
		persistHistoryState(shared) -- 3173
		return ____awaiter_resolve(nil, "main") -- 3173
	end) -- 3173
end -- 3163
local ListFilesAction = __TS__Class() -- 3178
ListFilesAction.name = "ListFilesAction" -- 3178
__TS__ClassExtends(ListFilesAction, Node) -- 3178
function ListFilesAction.prototype.prep(self, shared) -- 3179
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3179
		local last = shared.history[#shared.history] -- 3180
		if not last then -- 3180
			error( -- 3181
				__TS__New(Error, "no history"), -- 3181
				0 -- 3181
			) -- 3181
		end -- 3181
		emitAgentStartEvent(shared, last) -- 3182
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3182
	end) -- 3182
end -- 3179
function ListFilesAction.prototype.exec(self, input) -- 3186
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3186
		local params = input.params -- 3187
		local ____Tools_listFiles_93 = Tools.listFiles -- 3188
		local ____input_workDir_90 = input.workDir -- 3189
		local ____temp_91 = params.path or "" -- 3190
		local ____params_globs_92 = params.globs -- 3191
		local ____math_max_89 = math.max -- 3192
		local ____math_floor_88 = math.floor -- 3192
		local ____params_maxEntries_87 = params.maxEntries -- 3192
		if ____params_maxEntries_87 == nil then -- 3192
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3192
		end -- 3192
		local result = ____Tools_listFiles_93({ -- 3188
			workDir = ____input_workDir_90, -- 3189
			path = ____temp_91, -- 3190
			globs = ____params_globs_92, -- 3191
			maxEntries = ____math_max_89( -- 3192
				1, -- 3192
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3192
			) -- 3192
		}) -- 3192
		return ____awaiter_resolve(nil, result) -- 3192
	end) -- 3192
end -- 3186
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3197
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3197
		local last = shared.history[#shared.history] -- 3198
		if last ~= nil then -- 3198
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3200
			appendToolResultMessage(shared, last) -- 3201
			emitAgentFinishEvent(shared, last) -- 3202
		end -- 3202
		persistHistoryState(shared) -- 3204
		__TS__Await(maybeCompressHistory(shared)) -- 3205
		persistHistoryState(shared) -- 3206
		return ____awaiter_resolve(nil, "main") -- 3206
	end) -- 3206
end -- 3197
local DeleteFileAction = __TS__Class() -- 3211
DeleteFileAction.name = "DeleteFileAction" -- 3211
__TS__ClassExtends(DeleteFileAction, Node) -- 3211
function DeleteFileAction.prototype.prep(self, shared) -- 3212
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3212
		local last = shared.history[#shared.history] -- 3213
		if not last then -- 3213
			error( -- 3214
				__TS__New(Error, "no history"), -- 3214
				0 -- 3214
			) -- 3214
		end -- 3214
		emitAgentStartEvent(shared, last) -- 3215
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3216
		if __TS__StringTrim(targetFile) == "" then -- 3216
			error( -- 3219
				__TS__New(Error, "missing target_file"), -- 3219
				0 -- 3219
			) -- 3219
		end -- 3219
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3219
	end) -- 3219
end -- 3212
function DeleteFileAction.prototype.exec(self, input) -- 3223
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3223
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3224
		if not result.success then -- 3224
			return ____awaiter_resolve(nil, result) -- 3224
		end -- 3224
		return ____awaiter_resolve(nil, { -- 3224
			success = true, -- 3232
			changed = true, -- 3233
			mode = "delete", -- 3234
			checkpointId = result.checkpointId, -- 3235
			checkpointSeq = result.checkpointSeq, -- 3236
			files = {{path = input.targetFile, op = "delete"}} -- 3237
		}) -- 3237
	end) -- 3237
end -- 3223
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3241
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3241
		local last = shared.history[#shared.history] -- 3242
		if last ~= nil then -- 3242
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3244
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3245
			appendToolResultMessage(shared, last) -- 3246
			emitAgentFinishEvent(shared, last) -- 3247
			local result = last.result -- 3248
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3248
				emitAgentEvent(shared, { -- 3253
					type = "checkpoint_created", -- 3254
					sessionId = shared.sessionId, -- 3255
					taskId = shared.taskId, -- 3256
					step = last.step, -- 3257
					tool = "delete_file", -- 3258
					checkpointId = result.checkpointId, -- 3259
					checkpointSeq = result.checkpointSeq, -- 3260
					files = result.files -- 3261
				}) -- 3261
			end -- 3261
		end -- 3261
		persistHistoryState(shared) -- 3265
		__TS__Await(maybeCompressHistory(shared)) -- 3266
		persistHistoryState(shared) -- 3267
		return ____awaiter_resolve(nil, "main") -- 3267
	end) -- 3267
end -- 3241
local BuildAction = __TS__Class() -- 3272
BuildAction.name = "BuildAction" -- 3272
__TS__ClassExtends(BuildAction, Node) -- 3272
function BuildAction.prototype.prep(self, shared) -- 3273
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3273
		local last = shared.history[#shared.history] -- 3274
		if not last then -- 3274
			error( -- 3275
				__TS__New(Error, "no history"), -- 3275
				0 -- 3275
			) -- 3275
		end -- 3275
		emitAgentStartEvent(shared, last) -- 3276
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3276
	end) -- 3276
end -- 3273
function BuildAction.prototype.exec(self, input) -- 3280
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3280
		local params = input.params -- 3281
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3282
		return ____awaiter_resolve(nil, result) -- 3282
	end) -- 3282
end -- 3280
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3289
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3289
		local last = shared.history[#shared.history] -- 3290
		if last ~= nil then -- 3290
			last.result = sanitizeBuildResultForHistory(execRes) -- 3292
			appendToolResultMessage(shared, last) -- 3293
			emitAgentFinishEvent(shared, last) -- 3294
		end -- 3294
		persistHistoryState(shared) -- 3296
		__TS__Await(maybeCompressHistory(shared)) -- 3297
		persistHistoryState(shared) -- 3298
		return ____awaiter_resolve(nil, "main") -- 3298
	end) -- 3298
end -- 3289
local SpawnSubAgentAction = __TS__Class() -- 3303
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3303
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3303
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3304
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3304
		local last = shared.history[#shared.history] -- 3313
		if not last then -- 3313
			error( -- 3314
				__TS__New(Error, "no history"), -- 3314
				0 -- 3314
			) -- 3314
		end -- 3314
		emitAgentStartEvent(shared, last) -- 3315
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3316
			last.params.filesHint, -- 3317
			function(____, item) return type(item) == "string" end -- 3317
		) or nil -- 3317
		return ____awaiter_resolve( -- 3317
			nil, -- 3317
			{ -- 3319
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3320
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3321
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3322
				filesHint = filesHint, -- 3323
				sessionId = shared.sessionId, -- 3324
				projectRoot = shared.workingDir, -- 3325
				spawnSubAgent = shared.spawnSubAgent -- 3326
			} -- 3326
		) -- 3326
	end) -- 3326
end -- 3304
function SpawnSubAgentAction.prototype.exec(self, input) -- 3330
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3330
		if not input.spawnSubAgent then -- 3330
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3330
		end -- 3330
		if input.sessionId == nil or input.sessionId <= 0 then -- 3330
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3330
		end -- 3330
		local ____Log_99 = Log -- 3345
		local ____temp_96 = #input.title -- 3345
		local ____temp_97 = #input.prompt -- 3345
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3345
		local ____opt_94 = input.filesHint -- 3345
		____Log_99( -- 3345
			"Info", -- 3345
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3345
		) -- 3345
		local result = __TS__Await(input.spawnSubAgent({ -- 3346
			parentSessionId = input.sessionId, -- 3347
			projectRoot = input.projectRoot, -- 3348
			title = input.title, -- 3349
			prompt = input.prompt, -- 3350
			expectedOutput = input.expectedOutput, -- 3351
			filesHint = input.filesHint -- 3352
		})) -- 3352
		if not result.success then -- 3352
			return ____awaiter_resolve(nil, result) -- 3352
		end -- 3352
		return ____awaiter_resolve(nil, { -- 3352
			success = true, -- 3358
			sessionId = result.sessionId, -- 3359
			taskId = result.taskId, -- 3360
			title = result.title, -- 3361
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3362
		}) -- 3362
	end) -- 3362
end -- 3330
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3366
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3366
		local last = shared.history[#shared.history] -- 3367
		if last ~= nil then -- 3367
			last.result = execRes -- 3369
			appendToolResultMessage(shared, last) -- 3370
			emitAgentFinishEvent(shared, last) -- 3371
		end -- 3371
		persistHistoryState(shared) -- 3373
		__TS__Await(maybeCompressHistory(shared)) -- 3374
		persistHistoryState(shared) -- 3375
		return ____awaiter_resolve(nil, "main") -- 3375
	end) -- 3375
end -- 3366
local ListSubAgentsAction = __TS__Class() -- 3380
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3380
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3380
function ListSubAgentsAction.prototype.prep(self, shared) -- 3381
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3381
		local last = shared.history[#shared.history] -- 3390
		if not last then -- 3390
			error( -- 3391
				__TS__New(Error, "no history"), -- 3391
				0 -- 3391
			) -- 3391
		end -- 3391
		emitAgentStartEvent(shared, last) -- 3392
		return ____awaiter_resolve( -- 3392
			nil, -- 3392
			{ -- 3393
				sessionId = shared.sessionId, -- 3394
				projectRoot = shared.workingDir, -- 3395
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3396
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3397
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3398
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3399
				listSubAgents = shared.listSubAgents -- 3400
			} -- 3400
		) -- 3400
	end) -- 3400
end -- 3381
function ListSubAgentsAction.prototype.exec(self, input) -- 3404
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3404
		if not input.listSubAgents then -- 3404
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3404
		end -- 3404
		if input.sessionId == nil or input.sessionId <= 0 then -- 3404
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3404
		end -- 3404
		local result = __TS__Await(input.listSubAgents({ -- 3419
			sessionId = input.sessionId, -- 3420
			projectRoot = input.projectRoot, -- 3421
			status = input.status, -- 3422
			limit = input.limit, -- 3423
			offset = input.offset, -- 3424
			query = input.query -- 3425
		})) -- 3425
		return ____awaiter_resolve(nil, result) -- 3425
	end) -- 3425
end -- 3404
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3430
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3430
		local last = shared.history[#shared.history] -- 3431
		if last ~= nil then -- 3431
			last.result = execRes -- 3433
			appendToolResultMessage(shared, last) -- 3434
			emitAgentFinishEvent(shared, last) -- 3435
		end -- 3435
		persistHistoryState(shared) -- 3437
		__TS__Await(maybeCompressHistory(shared)) -- 3438
		persistHistoryState(shared) -- 3439
		return ____awaiter_resolve(nil, "main") -- 3439
	end) -- 3439
end -- 3430
EditFileAction = __TS__Class() -- 3444
EditFileAction.name = "EditFileAction" -- 3444
__TS__ClassExtends(EditFileAction, Node) -- 3444
function EditFileAction.prototype.prep(self, shared) -- 3445
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3445
		local last = shared.history[#shared.history] -- 3446
		if not last then -- 3446
			error( -- 3447
				__TS__New(Error, "no history"), -- 3447
				0 -- 3447
			) -- 3447
		end -- 3447
		emitAgentStartEvent(shared, last) -- 3448
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3449
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3452
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3453
		if __TS__StringTrim(path) == "" then -- 3453
			error( -- 3454
				__TS__New(Error, "missing path"), -- 3454
				0 -- 3454
			) -- 3454
		end -- 3454
		return ____awaiter_resolve(nil, { -- 3454
			path = path, -- 3455
			oldStr = oldStr, -- 3455
			newStr = newStr, -- 3455
			taskId = shared.taskId, -- 3455
			workDir = shared.workingDir -- 3455
		}) -- 3455
	end) -- 3455
end -- 3445
function EditFileAction.prototype.exec(self, input) -- 3458
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3458
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3459
		if not readRes.success then -- 3459
			if input.oldStr ~= "" then -- 3459
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3459
			end -- 3459
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3464
			if not createRes.success then -- 3464
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3464
			end -- 3464
			return ____awaiter_resolve(nil, { -- 3464
				success = true, -- 3472
				changed = true, -- 3473
				mode = "create", -- 3474
				checkpointId = createRes.checkpointId, -- 3475
				checkpointSeq = createRes.checkpointSeq, -- 3476
				files = {{path = input.path, op = "create"}} -- 3477
			}) -- 3477
		end -- 3477
		if input.oldStr == "" then -- 3477
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3481
			if not overwriteRes.success then -- 3481
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3481
			end -- 3481
			return ____awaiter_resolve(nil, { -- 3481
				success = true, -- 3489
				changed = true, -- 3490
				mode = "overwrite", -- 3491
				checkpointId = overwriteRes.checkpointId, -- 3492
				checkpointSeq = overwriteRes.checkpointSeq, -- 3493
				files = {{path = input.path, op = "write"}} -- 3494
			}) -- 3494
		end -- 3494
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3499
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3500
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3501
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3504
		if occurrences == 0 then -- 3504
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3506
			if not indentTolerant.success then -- 3506
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3506
			end -- 3506
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3510
			if not applyRes.success then -- 3510
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3510
			end -- 3510
			return ____awaiter_resolve(nil, { -- 3510
				success = true, -- 3518
				changed = true, -- 3519
				mode = "replace_indent_tolerant", -- 3520
				checkpointId = applyRes.checkpointId, -- 3521
				checkpointSeq = applyRes.checkpointSeq, -- 3522
				files = {{path = input.path, op = "write"}} -- 3523
			}) -- 3523
		end -- 3523
		if occurrences > 1 then -- 3523
			return ____awaiter_resolve( -- 3523
				nil, -- 3523
				{ -- 3527
					success = false, -- 3527
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3527
				} -- 3527
			) -- 3527
		end -- 3527
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3531
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3532
		if not applyRes.success then -- 3532
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3532
		end -- 3532
		return ____awaiter_resolve(nil, { -- 3532
			success = true, -- 3540
			changed = true, -- 3541
			mode = "replace", -- 3542
			checkpointId = applyRes.checkpointId, -- 3543
			checkpointSeq = applyRes.checkpointSeq, -- 3544
			files = {{path = input.path, op = "write"}} -- 3545
		}) -- 3545
	end) -- 3545
end -- 3458
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3549
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3549
		local last = shared.history[#shared.history] -- 3550
		if last ~= nil then -- 3550
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3552
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3553
			appendToolResultMessage(shared, last) -- 3554
			emitAgentFinishEvent(shared, last) -- 3555
			local result = last.result -- 3556
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3556
				emitAgentEvent(shared, { -- 3561
					type = "checkpoint_created", -- 3562
					sessionId = shared.sessionId, -- 3563
					taskId = shared.taskId, -- 3564
					step = last.step, -- 3565
					tool = last.tool, -- 3566
					checkpointId = result.checkpointId, -- 3567
					checkpointSeq = result.checkpointSeq, -- 3568
					files = result.files -- 3569
				}) -- 3569
			end -- 3569
		end -- 3569
		persistHistoryState(shared) -- 3573
		__TS__Await(maybeCompressHistory(shared)) -- 3574
		persistHistoryState(shared) -- 3575
		return ____awaiter_resolve(nil, "main") -- 3575
	end) -- 3575
end -- 3549
local function emitCheckpointEventForAction(shared, action) -- 3580
	local result = action.result -- 3581
	if not result then -- 3581
		return -- 3582
	end -- 3582
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3582
		emitAgentEvent(shared, { -- 3587
			type = "checkpoint_created", -- 3588
			sessionId = shared.sessionId, -- 3589
			taskId = shared.taskId, -- 3590
			step = action.step, -- 3591
			tool = action.tool, -- 3592
			checkpointId = result.checkpointId, -- 3593
			checkpointSeq = result.checkpointSeq, -- 3594
			files = result.files -- 3595
		}) -- 3595
	end -- 3595
end -- 3580
local function canRunBatchActionInParallel(self, action) -- 3900
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3901
end -- 3900
local function partitionToolCalls(actions) -- 3913
	local batches = {} -- 3914
	do -- 3914
		local i = 0 -- 3915
		while i < #actions do -- 3915
			local action = actions[i + 1] -- 3916
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3917
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3918
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3918
				local ____lastBatch_actions_134 = lastBatch.actions -- 3918
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3920
			else -- 3920
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3922
			end -- 3922
			i = i + 1 -- 3915
		end -- 3915
	end -- 3915
	return batches -- 3925
end -- 3913
local BatchToolAction = __TS__Class() -- 3928
BatchToolAction.name = "BatchToolAction" -- 3928
__TS__ClassExtends(BatchToolAction, Node) -- 3928
function BatchToolAction.prototype.prep(self, shared) -- 3929
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3929
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3929
	end) -- 3929
end -- 3929
function BatchToolAction.prototype.exec(self, input) -- 3933
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3933
		local shared = input.shared -- 3934
		local preExecuted = shared.preExecutedResults -- 3935
		local batches = partitionToolCalls(input.actions) -- 3936
		local parallelBatchCount = #__TS__ArrayFilter( -- 3937
			batches, -- 3937
			function(____, b) return b.isConcurrencySafe end -- 3937
		) -- 3937
		local serialBatchCount = #__TS__ArrayFilter( -- 3938
			batches, -- 3938
			function(____, b) return not b.isConcurrencySafe end -- 3938
		) -- 3938
		Log( -- 3939
			"Info", -- 3939
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3939
		) -- 3939
		do -- 3939
			local batchIdx = 0 -- 3941
			while batchIdx < #batches do -- 3941
				do -- 3941
					local batch = batches[batchIdx + 1] -- 3942
					if shared.stopToken.stopped then -- 3942
						for ____, action in ipairs(batch.actions) do -- 3944
							if not action.result then -- 3944
								action.result = { -- 3946
									success = false, -- 3946
									message = getCancelledReason(shared) -- 3946
								} -- 3946
							end -- 3946
						end -- 3946
						goto __continue625 -- 3949
					end -- 3949
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3949
						local preExecCount = #__TS__ArrayFilter( -- 3953
							batch.actions, -- 3953
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3953
						) -- 3953
						Log( -- 3954
							"Info", -- 3954
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3954
						) -- 3954
						do -- 3954
							local i = 0 -- 3955
							while i < #batch.actions do -- 3955
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3956
								i = i + 1 -- 3955
							end -- 3955
						end -- 3955
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3958
							batch.actions, -- 3958
							function(____, action) -- 3958
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3958
									if shared.stopToken.stopped then -- 3958
										action.result = { -- 3960
											success = false, -- 3960
											message = getCancelledReason(shared) -- 3960
										} -- 3960
										return ____awaiter_resolve(nil, action) -- 3960
									end -- 3960
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3963
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3964
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3965
									return ____awaiter_resolve(nil, action) -- 3965
								end) -- 3965
							end -- 3958
						))) -- 3958
						do -- 3958
							local i = 0 -- 3968
							while i < #batch.actions do -- 3968
								local action = batch.actions[i + 1] -- 3969
								if not action.result then -- 3969
									action.result = {success = false, message = "tool did not produce a result"} -- 3971
								end -- 3971
								appendToolResultMessage(shared, action) -- 3973
								emitAgentFinishEvent(shared, action) -- 3974
								emitCheckpointEventForAction(shared, action) -- 3975
								i = i + 1 -- 3968
							end -- 3968
						end -- 3968
					else -- 3968
						Log( -- 3978
							"Info", -- 3978
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3978
						) -- 3978
						do -- 3978
							local i = 0 -- 3979
							while i < #batch.actions do -- 3979
								local action = batch.actions[i + 1] -- 3980
								emitAgentStartEvent(shared, action) -- 3981
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3982
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3983
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3984
								appendToolResultMessage(shared, action) -- 3985
								emitAgentFinishEvent(shared, action) -- 3986
								emitCheckpointEventForAction(shared, action) -- 3987
								persistHistoryState(shared) -- 3988
								if shared.stopToken.stopped then -- 3988
									break -- 3990
								end -- 3990
								i = i + 1 -- 3979
							end -- 3979
						end -- 3979
					end -- 3979
				end -- 3979
				::__continue625:: -- 3979
				batchIdx = batchIdx + 1 -- 3941
			end -- 3941
		end -- 3941
		persistHistoryState(shared) -- 3995
		return ____awaiter_resolve(nil, input.actions) -- 3995
	end) -- 3995
end -- 3933
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3999
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3999
		shared.pendingToolActions = nil -- 4000
		shared.preExecutedResults = nil -- 4001
		persistHistoryState(shared) -- 4002
		__TS__Await(maybeCompressHistory(shared)) -- 4003
		persistHistoryState(shared) -- 4004
		return ____awaiter_resolve(nil, "main") -- 4004
	end) -- 4004
end -- 3999
local EndNode = __TS__Class() -- 4009
EndNode.name = "EndNode" -- 4009
__TS__ClassExtends(EndNode, Node) -- 4009
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4010
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4010
		return ____awaiter_resolve(nil, nil) -- 4010
	end) -- 4010
end -- 4010
local CodingAgentFlow = __TS__Class() -- 4015
CodingAgentFlow.name = "CodingAgentFlow" -- 4015
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4015
function CodingAgentFlow.prototype.____constructor(self, role) -- 4016
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4017
	local read = __TS__New(ReadFileAction, 1, 0) -- 4018
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4019
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4020
	local list = __TS__New(ListFilesAction, 1, 0) -- 4021
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4022
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4023
	local build = __TS__New(BuildAction, 1, 0) -- 4024
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4025
	local edit = __TS__New(EditFileAction, 1, 0) -- 4026
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4027
	local done = __TS__New(EndNode, 1, 0) -- 4028
	main:on("batch_tools", batch) -- 4030
	main:on("grep_files", search) -- 4031
	main:on("search_dora_api", searchDora) -- 4032
	main:on("glob_files", list) -- 4033
	if role == "main" then -- 4033
		main:on("read_file", read) -- 4035
		main:on("delete_file", del) -- 4036
		main:on("build", build) -- 4037
		main:on("edit_file", edit) -- 4038
		main:on("list_sub_agents", listSub) -- 4039
		main:on("spawn_sub_agent", spawn) -- 4040
	else -- 4040
		main:on("read_file", read) -- 4042
		main:on("delete_file", del) -- 4043
		main:on("build", build) -- 4044
		main:on("edit_file", edit) -- 4045
	end -- 4045
	main:on("done", done) -- 4047
	search:on("main", main) -- 4049
	searchDora:on("main", main) -- 4050
	list:on("main", main) -- 4051
	listSub:on("main", main) -- 4052
	spawn:on("main", main) -- 4053
	batch:on("main", main) -- 4054
	read:on("main", main) -- 4055
	del:on("main", main) -- 4056
	build:on("main", main) -- 4057
	edit:on("main", main) -- 4058
	Flow.prototype.____constructor(self, main) -- 4060
end -- 4016
local function runCodingAgentAsync(options) -- 4082
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4082
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4082
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4082
		end -- 4082
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4086
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4087
		if not llmConfigRes.success then -- 4087
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4087
		end -- 4087
		local llmConfig = llmConfigRes.config -- 4093
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4094
		if not taskRes.success then -- 4094
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4094
		end -- 4094
		local compressor = __TS__New(MemoryCompressor, { -- 4101
			compressionThreshold = 0.8, -- 4102
			compressionTargetThreshold = 0.5, -- 4103
			maxCompressionRounds = 3, -- 4104
			projectDir = options.workDir, -- 4105
			llmConfig = llmConfig, -- 4106
			promptPack = options.promptPack, -- 4107
			scope = options.memoryScope -- 4108
		}) -- 4108
		local persistedSession = compressor:getStorage():readSessionState() -- 4110
		local promptPack = compressor:getPromptPack() -- 4111
		local shared = { -- 4113
			sessionId = options.sessionId, -- 4114
			taskId = taskRes.taskId, -- 4115
			role = options.role or "main", -- 4116
			maxSteps = math.max( -- 4117
				1, -- 4117
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4117
			), -- 4117
			llmMaxTry = math.max( -- 4118
				1, -- 4118
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4118
			), -- 4118
			step = 0, -- 4119
			done = false, -- 4120
			stopToken = options.stopToken or ({stopped = false}), -- 4121
			response = "", -- 4122
			userQuery = normalizedPrompt, -- 4123
			workingDir = options.workDir, -- 4124
			useChineseResponse = options.useChineseResponse == true, -- 4125
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4126
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4129
			llmConfig = llmConfig, -- 4130
			onEvent = options.onEvent, -- 4131
			promptPack = promptPack, -- 4132
			history = {}, -- 4133
			messages = persistedSession.messages, -- 4134
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4135
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4136
			memory = {compressor = compressor}, -- 4138
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4142
			spawnSubAgent = options.spawnSubAgent, -- 4147
			listSubAgents = options.listSubAgents -- 4148
		} -- 4148
		local ____try = __TS__AsyncAwaiter(function() -- 4148
			emitAgentEvent(shared, { -- 4152
				type = "task_started", -- 4153
				sessionId = shared.sessionId, -- 4154
				taskId = shared.taskId, -- 4155
				prompt = shared.userQuery, -- 4156
				workDir = shared.workingDir, -- 4157
				maxSteps = shared.maxSteps -- 4158
			}) -- 4158
			if shared.stopToken.stopped then -- 4158
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4161
				return ____awaiter_resolve( -- 4161
					nil, -- 4161
					emitAgentTaskFinishEvent( -- 4162
						shared, -- 4162
						false, -- 4162
						getCancelledReason(shared) -- 4162
					) -- 4162
				) -- 4162
			end -- 4162
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4164
			local promptCommand = getPromptCommand(shared.userQuery) -- 4165
			if promptCommand == "clear" then -- 4165
				return ____awaiter_resolve( -- 4165
					nil, -- 4165
					clearSessionHistory(shared) -- 4167
				) -- 4167
			end -- 4167
			if promptCommand == "compact" then -- 4167
				if shared.role == "sub" then -- 4167
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4171
					return ____awaiter_resolve( -- 4171
						nil, -- 4171
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4172
					) -- 4172
				end -- 4172
				return ____awaiter_resolve( -- 4172
					nil, -- 4172
					__TS__Await(compactAllHistory(shared)) -- 4180
				) -- 4180
			end -- 4180
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4182
			persistHistoryState(shared) -- 4186
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4187
			__TS__Await(flow:run(shared)) -- 4188
			if shared.stopToken.stopped then -- 4188
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4190
				return ____awaiter_resolve( -- 4190
					nil, -- 4190
					emitAgentTaskFinishEvent( -- 4191
						shared, -- 4191
						false, -- 4191
						getCancelledReason(shared) -- 4191
					) -- 4191
				) -- 4191
			end -- 4191
			if shared.error then -- 4191
				return ____awaiter_resolve( -- 4191
					nil, -- 4191
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4194
				) -- 4194
			end -- 4194
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4197
			return ____awaiter_resolve( -- 4197
				nil, -- 4197
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4198
			) -- 4198
		end) -- 4198
		__TS__Await(____try.catch( -- 4151
			____try, -- 4151
			function(____, e) -- 4151
				return ____awaiter_resolve( -- 4151
					nil, -- 4151
					finalizeAgentFailure( -- 4201
						shared, -- 4201
						tostring(e) -- 4201
					) -- 4201
				) -- 4201
			end -- 4201
		)) -- 4201
	end) -- 4201
end -- 4082
function ____exports.runCodingAgent(options, callback) -- 4205
	local ____self_137 = runCodingAgentAsync(options) -- 4205
	____self_137["then"]( -- 4205
		____self_137, -- 4205
		function(____, result) return callback(result) end -- 4206
	) -- 4206
end -- 4205
return ____exports -- 4205