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
function emitAgentEvent(shared, event) -- 780
	if shared.onEvent then -- 780
		do -- 780
			local function ____catch(____error) -- 780
				Log( -- 785
					"Error", -- 785
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 785
				) -- 785
			end -- 785
			local ____try, ____hasReturned = pcall(function() -- 785
				shared:onEvent(event) -- 783
			end) -- 783
			if not ____try then -- 783
				____catch(____hasReturned) -- 783
			end -- 783
		end -- 783
	end -- 783
end -- 783
function getCancelledReason(shared) -- 914
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 914
		return shared.stopToken.reason -- 915
	end -- 915
	return shared.useChineseResponse and "已取消" or "cancelled" -- 916
end -- 916
function truncateText(text, maxLen) -- 1097
	if #text <= maxLen then -- 1097
		return text -- 1098
	end -- 1098
	local nextPos = utf8.offset(text, maxLen + 1) -- 1099
	if nextPos == nil then -- 1099
		return text -- 1100
	end -- 1100
	return string.sub(text, 1, nextPos - 1) .. "..." -- 1101
end -- 1101
function utf8TakeHead(text, maxChars) -- 1104
	if maxChars <= 0 or text == "" then -- 1104
		return "" -- 1105
	end -- 1105
	local nextPos = utf8.offset(text, maxChars + 1) -- 1106
	if nextPos == nil then -- 1106
		return text -- 1107
	end -- 1107
	return string.sub(text, 1, nextPos - 1) -- 1108
end -- 1108
function getReplyLanguageDirective(shared) -- 1111
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 1112
end -- 1112
function replacePromptVars(template, vars) -- 1117
	local output = template -- 1118
	for key in pairs(vars) do -- 1119
		output = table.concat( -- 1120
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1120
			vars[key] or "" or "," -- 1120
		) -- 1120
	end -- 1120
	return output -- 1122
end -- 1122
function limitReadContentForHistory(content, tool) -- 1125
	local lines = __TS__StringSplit(content, "\n") -- 1126
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1127
	local limitedByLines = overLineLimit and table.concat( -- 1128
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1129
		"\n" -- 1129
	) or content -- 1129
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1129
		return content -- 1132
	end -- 1132
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1134
	local reasons = {} -- 1137
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1137
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1138
	end -- 1138
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1138
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1139
	end -- 1139
	local hint = "Narrow the requested line range." -- 1140
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1141
end -- 1141
function sanitizeReadResultForHistory(tool, result) -- 1156
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1156
		return result -- 1158
	end -- 1158
	local clone = {} -- 1160
	for key in pairs(result) do -- 1161
		clone[key] = result[key] -- 1162
	end -- 1162
	clone.content = limitReadContentForHistory(result.content, tool) -- 1164
	return clone -- 1165
end -- 1165
function sanitizeSearchMatchesForHistory(items, maxItems) -- 1168
	local shown = math.min(#items, maxItems) -- 1172
	local out = {} -- 1173
	do -- 1173
		local i = 0 -- 1174
		while i < shown do -- 1174
			local row = items[i + 1] -- 1175
			out[#out + 1] = { -- 1176
				file = row.file, -- 1177
				line = row.line, -- 1178
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1179
			} -- 1179
			i = i + 1 -- 1174
		end -- 1174
	end -- 1174
	return out -- 1184
end -- 1184
function sanitizeSearchResultForHistory(tool, result) -- 1187
	if result.success ~= true or not isArray(result.results) then -- 1187
		return result -- 1191
	end -- 1191
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1191
		return result -- 1192
	end -- 1192
	local clone = {} -- 1193
	for key in pairs(result) do -- 1194
		clone[key] = result[key] -- 1195
	end -- 1195
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1197
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1198
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1198
		local grouped = result.groupedResults -- 1203
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1204
		local sanitizedGroups = {} -- 1205
		do -- 1205
			local i = 0 -- 1206
			while i < shown do -- 1206
				local row = grouped[i + 1] -- 1207
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1208
					file = row.file, -- 1209
					totalMatches = row.totalMatches, -- 1210
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1211
				} -- 1211
				i = i + 1 -- 1206
			end -- 1206
		end -- 1206
		clone.groupedResults = sanitizedGroups -- 1216
	end -- 1216
	return clone -- 1218
end -- 1218
function sanitizeListFilesResultForHistory(result) -- 1221
	if result.success ~= true or not isArray(result.files) then -- 1221
		return result -- 1222
	end -- 1222
	local clone = {} -- 1223
	for key in pairs(result) do -- 1224
		clone[key] = result[key] -- 1225
	end -- 1225
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1227
	return clone -- 1228
end -- 1228
function sanitizeBuildResultForHistory(result) -- 1231
	if not isArray(result.messages) then -- 1231
		return result -- 1232
	end -- 1232
	local clone = {} -- 1233
	for key in pairs(result) do -- 1234
		clone[key] = result[key] -- 1235
	end -- 1235
	local messages = result.messages -- 1237
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1238
	local sanitized = {} -- 1239
	do -- 1239
		local i = 0 -- 1240
		while i < shown do -- 1240
			local item = messages[i + 1] -- 1241
			local next = {} -- 1242
			for key in pairs(item) do -- 1243
				local value = item[key] -- 1244
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1245
			end -- 1245
			sanitized[#sanitized + 1] = next -- 1249
			i = i + 1 -- 1240
		end -- 1240
	end -- 1240
	clone.messages = sanitized -- 1251
	if #messages > shown then -- 1251
		clone.truncatedMessages = #messages - shown -- 1253
	end -- 1253
	return clone -- 1255
end -- 1255
function getDecisionToolDefinitions(shared) -- 1273
	local base = replacePromptVars( -- 1274
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1275
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1276
	) -- 1276
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1278
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1299
		getAllowedToolsForRole(shared.role), -- 1300
		", " -- 1300
	) or "" -- 1300
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1302
	if (shared and shared.decisionMode) ~= "xml" then -- 1302
		return withRole -- 1304
	end -- 1304
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1306
end -- 1306
function getFinishMessage(params, fallback) -- 1650
	if fallback == nil then -- 1650
		fallback = "" -- 1650
	end -- 1650
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1650
		return __TS__StringTrim(params.message) -- 1652
	end -- 1652
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1652
		return __TS__StringTrim(params.response) -- 1655
	end -- 1655
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1655
		return __TS__StringTrim(params.summary) -- 1658
	end -- 1658
	return __TS__StringTrim(fallback) -- 1660
end -- 1660
function persistHistoryState(shared) -- 1663
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1664
end -- 1664
function getActiveConversationMessages(shared) -- 1671
	local activeMessages = {} -- 1672
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1672
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1679
	end -- 1679
	do -- 1679
		local i = shared.lastConsolidatedIndex -- 1683
		while i < #shared.messages do -- 1683
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1684
			i = i + 1 -- 1683
		end -- 1683
	end -- 1683
	return activeMessages -- 1686
end -- 1686
function getActiveRealMessageCount(shared) -- 1689
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1690
end -- 1690
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1693
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1698
	local previousActiveStart = shared.lastConsolidatedIndex -- 1699
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1700
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1701
	if type(carryMessageIndex) == "number" then -- 1701
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1701
		else -- 1701
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1709
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1712
		end -- 1712
	else -- 1712
		shared.carryMessageIndex = nil -- 1717
	end -- 1717
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1717
		shared.carryMessageIndex = nil -- 1727
	end -- 1727
end -- 1727
function getDecisionPath(params) -- 1985
	if type(params.path) == "string" then -- 1985
		return __TS__StringTrim(params.path) -- 1986
	end -- 1986
	if type(params.target_file) == "string" then -- 1986
		return __TS__StringTrim(params.target_file) -- 1987
	end -- 1987
	return "" -- 1988
end -- 1988
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1991
	local num = __TS__Number(value) -- 1992
	if not __TS__NumberIsFinite(num) then -- 1992
		num = fallback -- 1993
	end -- 1993
	num = math.floor(num) -- 1994
	if num < minValue then -- 1994
		num = minValue -- 1995
	end -- 1995
	if maxValue ~= nil and num > maxValue then -- 1995
		num = maxValue -- 1996
	end -- 1996
	return num -- 1997
end -- 1997
function parseReadLineParam(value, fallback, paramName) -- 2000
	local num = __TS__Number(value) -- 2005
	if not __TS__NumberIsFinite(num) then -- 2005
		num = fallback -- 2006
	end -- 2006
	num = math.floor(num) -- 2007
	if num == 0 then -- 2007
		return {success = false, message = paramName .. " cannot be 0"} -- 2009
	end -- 2009
	return {success = true, value = num} -- 2011
end -- 2011
function validateDecision(tool, params) -- 2014
	if tool == "finish" then -- 2014
		local message = getFinishMessage(params) -- 2019
		if message == "" then -- 2019
			return {success = false, message = "finish requires params.message"} -- 2020
		end -- 2020
		params.message = message -- 2021
		return {success = true, params = params} -- 2022
	end -- 2022
	if tool == "read_file" then -- 2022
		local path = getDecisionPath(params) -- 2026
		if path == "" then -- 2026
			return {success = false, message = "read_file requires path"} -- 2027
		end -- 2027
		params.path = path -- 2028
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2029
		if not startLineRes.success then -- 2029
			return startLineRes -- 2030
		end -- 2030
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 2031
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2032
		if not endLineRes.success then -- 2032
			return endLineRes -- 2033
		end -- 2033
		params.startLine = startLineRes.value -- 2034
		params.endLine = endLineRes.value -- 2035
		return {success = true, params = params} -- 2036
	end -- 2036
	if tool == "edit_file" then -- 2036
		local path = getDecisionPath(params) -- 2040
		if path == "" then -- 2040
			return {success = false, message = "edit_file requires path"} -- 2041
		end -- 2041
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2042
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2043
		params.path = path -- 2044
		params.old_str = oldStr -- 2045
		params.new_str = newStr -- 2046
		return {success = true, params = params} -- 2047
	end -- 2047
	if tool == "delete_file" then -- 2047
		local targetFile = getDecisionPath(params) -- 2051
		if targetFile == "" then -- 2051
			return {success = false, message = "delete_file requires target_file"} -- 2052
		end -- 2052
		params.target_file = targetFile -- 2053
		return {success = true, params = params} -- 2054
	end -- 2054
	if tool == "grep_files" then -- 2054
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2058
		if pattern == "" then -- 2058
			return {success = false, message = "grep_files requires pattern"} -- 2059
		end -- 2059
		params.pattern = pattern -- 2060
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2061
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2062
		return {success = true, params = params} -- 2063
	end -- 2063
	if tool == "search_dora_api" then -- 2063
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2067
		if pattern == "" then -- 2067
			return {success = false, message = "search_dora_api requires pattern"} -- 2068
		end -- 2068
		params.pattern = pattern -- 2069
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2070
		return {success = true, params = params} -- 2071
	end -- 2071
	if tool == "glob_files" then -- 2071
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2075
		return {success = true, params = params} -- 2076
	end -- 2076
	if tool == "build" then -- 2076
		local path = getDecisionPath(params) -- 2080
		if path ~= "" then -- 2080
			params.path = path -- 2082
		end -- 2082
		return {success = true, params = params} -- 2084
	end -- 2084
	if tool == "list_sub_agents" then -- 2084
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2088
		if status ~= "" then -- 2088
			params.status = status -- 2090
		end -- 2090
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2092
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2093
		if type(params.query) == "string" then -- 2093
			params.query = __TS__StringTrim(params.query) -- 2095
		end -- 2095
		return {success = true, params = params} -- 2097
	end -- 2097
	if tool == "spawn_sub_agent" then -- 2097
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2101
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2102
		if prompt == "" then -- 2102
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2103
		end -- 2103
		if title == "" then -- 2103
			return {success = false, message = "spawn_sub_agent requires title"} -- 2104
		end -- 2104
		params.prompt = prompt -- 2105
		params.title = title -- 2106
		if type(params.expectedOutput) == "string" then -- 2106
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2108
		end -- 2108
		if isArray(params.filesHint) then -- 2108
			params.filesHint = __TS__ArrayMap( -- 2111
				__TS__ArrayFilter( -- 2111
					params.filesHint, -- 2111
					function(____, item) return type(item) == "string" end -- 2112
				), -- 2112
				function(____, item) return sanitizeUTF8(item) end -- 2113
			) -- 2113
		end -- 2113
		return {success = true, params = params} -- 2115
	end -- 2115
	return {success = true, params = params} -- 2118
end -- 2118
function getAllowedToolsForRole(role) -- 2144
	return role == "main" and ({ -- 2145
		"read_file", -- 2146
		"edit_file", -- 2146
		"delete_file", -- 2146
		"grep_files", -- 2146
		"search_dora_api", -- 2146
		"glob_files", -- 2146
		"build", -- 2146
		"list_sub_agents", -- 2146
		"spawn_sub_agent", -- 2146
		"finish" -- 2146
	}) or ({ -- 2146
		"read_file", -- 2147
		"edit_file", -- 2147
		"delete_file", -- 2147
		"grep_files", -- 2147
		"search_dora_api", -- 2147
		"glob_files", -- 2147
		"build", -- 2147
		"finish" -- 2147
	}) -- 2147
end -- 2147
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2253
	if includeToolDefinitions == nil then -- 2253
		includeToolDefinitions = false -- 2253
	end -- 2253
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2254
	local sections = { -- 2257
		shared.promptPack.agentIdentityPrompt, -- 2258
		rolePrompt, -- 2259
		getReplyLanguageDirective(shared) -- 2260
	} -- 2260
	if shared.decisionMode == "tool_calling" then -- 2260
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2263
	end -- 2263
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2265
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2266
	if memoryContext ~= "" then -- 2266
		sections[#sections + 1] = memoryContext -- 2268
	end -- 2268
	if includeToolDefinitions then -- 2268
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2271
		if shared.decisionMode == "xml" then -- 2271
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2273
		end -- 2273
	end -- 2273
	local skillsSection = buildSkillsSection(shared) -- 2277
	if skillsSection ~= "" then -- 2277
		sections[#sections + 1] = skillsSection -- 2279
	end -- 2279
	return table.concat(sections, "\n\n") -- 2281
end -- 2281
function buildSkillsSection(shared) -- 2284
	local ____opt_48 = shared.skills -- 2284
	if not (____opt_48 and ____opt_48.loader) then -- 2284
		return "" -- 2286
	end -- 2286
	return shared.skills.loader:buildSkillsPromptSection() -- 2288
end -- 2288
function buildXmlDecisionInstruction(shared, feedback) -- 2406
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2407
end -- 2407
function executeToolAction(shared, action) -- 3594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3594
		if shared.stopToken.stopped then -- 3594
			return ____awaiter_resolve( -- 3594
				nil, -- 3594
				{ -- 3596
					success = false, -- 3596
					message = getCancelledReason(shared) -- 3596
				} -- 3596
			) -- 3596
		end -- 3596
		local params = action.params -- 3598
		if action.tool == "read_file" then -- 3598
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3600
			if __TS__StringTrim(path) == "" then -- 3600
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3600
			end -- 3600
			local ____Tools_readFile_113 = Tools.readFile -- 3604
			local ____shared_workingDir_111 = shared.workingDir -- 3605
			local ____params_startLine_109 = params.startLine -- 3607
			if ____params_startLine_109 == nil then -- 3607
				____params_startLine_109 = 1 -- 3607
			end -- 3607
			local ____TS__Number_result_112 = __TS__Number(____params_startLine_109) -- 3607
			local ____params_endLine_110 = params.endLine -- 3608
			if ____params_endLine_110 == nil then -- 3608
				____params_endLine_110 = READ_FILE_DEFAULT_LIMIT -- 3608
			end -- 3608
			return ____awaiter_resolve( -- 3608
				nil, -- 3608
				____Tools_readFile_113( -- 3604
					____shared_workingDir_111, -- 3605
					path, -- 3606
					____TS__Number_result_112, -- 3607
					__TS__Number(____params_endLine_110), -- 3608
					shared.useChineseResponse and "zh" or "en" -- 3609
				) -- 3609
			) -- 3609
		end -- 3609
		if action.tool == "grep_files" then -- 3609
			local ____Tools_searchFiles_127 = Tools.searchFiles -- 3613
			local ____shared_workingDir_120 = shared.workingDir -- 3614
			local ____temp_121 = params.path or "" -- 3615
			local ____temp_122 = params.pattern or "" -- 3616
			local ____params_globs_123 = params.globs -- 3617
			local ____params_useRegex_124 = params.useRegex -- 3618
			local ____params_caseSensitive_125 = params.caseSensitive -- 3619
			local ____math_max_116 = math.max -- 3622
			local ____math_floor_115 = math.floor -- 3622
			local ____params_limit_114 = params.limit -- 3622
			if ____params_limit_114 == nil then -- 3622
				____params_limit_114 = SEARCH_FILES_LIMIT_DEFAULT -- 3622
			end -- 3622
			local ____math_max_116_result_126 = ____math_max_116( -- 3622
				1, -- 3622
				____math_floor_115(__TS__Number(____params_limit_114)) -- 3622
			) -- 3622
			local ____math_max_119 = math.max -- 3623
			local ____math_floor_118 = math.floor -- 3623
			local ____params_offset_117 = params.offset -- 3623
			if ____params_offset_117 == nil then -- 3623
				____params_offset_117 = 0 -- 3623
			end -- 3623
			local result = __TS__Await(____Tools_searchFiles_127({ -- 3613
				workDir = ____shared_workingDir_120, -- 3614
				path = ____temp_121, -- 3615
				pattern = ____temp_122, -- 3616
				globs = ____params_globs_123, -- 3617
				useRegex = ____params_useRegex_124, -- 3618
				caseSensitive = ____params_caseSensitive_125, -- 3619
				includeContent = true, -- 3620
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3621
				limit = ____math_max_116_result_126, -- 3622
				offset = ____math_max_119( -- 3623
					0, -- 3623
					____math_floor_118(__TS__Number(____params_offset_117)) -- 3623
				), -- 3623
				groupByFile = params.groupByFile == true -- 3624
			})) -- 3624
			return ____awaiter_resolve(nil, result) -- 3624
		end -- 3624
		if action.tool == "search_dora_api" then -- 3624
			local ____Tools_searchDoraAPI_135 = Tools.searchDoraAPI -- 3629
			local ____temp_131 = params.pattern or "" -- 3630
			local ____temp_132 = params.docSource or "api" -- 3631
			local ____temp_133 = shared.useChineseResponse and "zh" or "en" -- 3632
			local ____temp_134 = params.programmingLanguage or "ts" -- 3633
			local ____math_min_130 = math.min -- 3634
			local ____math_max_129 = math.max -- 3634
			local ____params_limit_128 = params.limit -- 3634
			if ____params_limit_128 == nil then -- 3634
				____params_limit_128 = 8 -- 3634
			end -- 3634
			local result = __TS__Await(____Tools_searchDoraAPI_135({ -- 3629
				pattern = ____temp_131, -- 3630
				docSource = ____temp_132, -- 3631
				docLanguage = ____temp_133, -- 3632
				programmingLanguage = ____temp_134, -- 3633
				limit = ____math_min_130( -- 3634
					SEARCH_DORA_API_LIMIT_MAX, -- 3634
					____math_max_129( -- 3634
						1, -- 3634
						__TS__Number(____params_limit_128) -- 3634
					) -- 3634
				), -- 3634
				useRegex = params.useRegex, -- 3635
				caseSensitive = false, -- 3636
				includeContent = true, -- 3637
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3638
			})) -- 3638
			return ____awaiter_resolve(nil, result) -- 3638
		end -- 3638
		if action.tool == "glob_files" then -- 3638
			local ____Tools_listFiles_142 = Tools.listFiles -- 3643
			local ____shared_workingDir_139 = shared.workingDir -- 3644
			local ____temp_140 = params.path or "" -- 3645
			local ____params_globs_141 = params.globs -- 3646
			local ____math_max_138 = math.max -- 3647
			local ____math_floor_137 = math.floor -- 3647
			local ____params_maxEntries_136 = params.maxEntries -- 3647
			if ____params_maxEntries_136 == nil then -- 3647
				____params_maxEntries_136 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3647
			end -- 3647
			local result = ____Tools_listFiles_142({ -- 3643
				workDir = ____shared_workingDir_139, -- 3644
				path = ____temp_140, -- 3645
				globs = ____params_globs_141, -- 3646
				maxEntries = ____math_max_138( -- 3647
					1, -- 3647
					____math_floor_137(__TS__Number(____params_maxEntries_136)) -- 3647
				) -- 3647
			}) -- 3647
			return ____awaiter_resolve(nil, result) -- 3647
		end -- 3647
		if action.tool == "delete_file" then -- 3647
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3652
			if __TS__StringTrim(targetFile) == "" then -- 3652
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3652
			end -- 3652
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3656
			if not result.success then -- 3656
				return ____awaiter_resolve(nil, result) -- 3656
			end -- 3656
			return ____awaiter_resolve(nil, { -- 3656
				success = true, -- 3664
				changed = true, -- 3665
				mode = "delete", -- 3666
				checkpointId = result.checkpointId, -- 3667
				checkpointSeq = result.checkpointSeq, -- 3668
				files = {{path = targetFile, op = "delete"}} -- 3669
			}) -- 3669
		end -- 3669
		if action.tool == "build" then -- 3669
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3673
			return ____awaiter_resolve(nil, result) -- 3673
		end -- 3673
		if action.tool == "spawn_sub_agent" then -- 3673
			if not shared.spawnSubAgent then -- 3673
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3673
			end -- 3673
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3673
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3673
			end -- 3673
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3686
				params.filesHint, -- 3687
				function(____, item) return type(item) == "string" end -- 3687
			) or nil -- 3687
			local result = __TS__Await(shared.spawnSubAgent({ -- 3689
				parentSessionId = shared.sessionId, -- 3690
				projectRoot = shared.workingDir, -- 3691
				title = type(params.title) == "string" and params.title or "Sub", -- 3692
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3693
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3694
				filesHint = filesHint -- 3695
			})) -- 3695
			if not result.success then -- 3695
				return ____awaiter_resolve(nil, result) -- 3695
			end -- 3695
			return ____awaiter_resolve(nil, { -- 3695
				success = true, -- 3701
				sessionId = result.sessionId, -- 3702
				taskId = result.taskId, -- 3703
				title = result.title, -- 3704
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3705
			}) -- 3705
		end -- 3705
		if action.tool == "list_sub_agents" then -- 3705
			if not shared.listSubAgents then -- 3705
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3705
			end -- 3705
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3705
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3705
			end -- 3705
			local result = __TS__Await(shared.listSubAgents({ -- 3715
				sessionId = shared.sessionId, -- 3716
				projectRoot = shared.workingDir, -- 3717
				status = type(params.status) == "string" and params.status or nil, -- 3718
				limit = type(params.limit) == "number" and params.limit or nil, -- 3719
				offset = type(params.offset) == "number" and params.offset or nil, -- 3720
				query = type(params.query) == "string" and params.query or nil -- 3721
			})) -- 3721
			return ____awaiter_resolve(nil, result) -- 3721
		end -- 3721
		if action.tool == "edit_file" then -- 3721
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3726
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3729
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3730
			if __TS__StringTrim(path) == "" then -- 3730
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3730
			end -- 3730
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3732
			return ____awaiter_resolve( -- 3732
				nil, -- 3732
				actionNode:exec({ -- 3733
					path = path, -- 3734
					oldStr = oldStr, -- 3735
					newStr = newStr, -- 3736
					taskId = shared.taskId, -- 3737
					workDir = shared.workingDir -- 3738
				}) -- 3738
			) -- 3738
		end -- 3738
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3738
	end) -- 3738
end -- 3738
function sanitizeToolActionResultForHistory(action, result) -- 3744
	if action.tool == "read_file" then -- 3744
		return sanitizeReadResultForHistory(action.tool, result) -- 3746
	end -- 3746
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3746
		return sanitizeSearchResultForHistory(action.tool, result) -- 3749
	end -- 3749
	if action.tool == "glob_files" then -- 3749
		return sanitizeListFilesResultForHistory(result) -- 3752
	end -- 3752
	if action.tool == "build" then -- 3752
		return sanitizeBuildResultForHistory(result) -- 3755
	end -- 3755
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3755
		if result.success ~= true then -- 3755
			return result -- 3758
		end -- 3758
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3758
			return result -- 3759
		end -- 3759
		if isArray(result.fileContext) then -- 3759
			return result -- 3760
		end -- 3760
		local contextLimits = { -- 3762
			fullContentChars = 12000, -- 3763
			previewChars = 4000, -- 3764
			diffChars = 8000, -- 3765
			totalChars = 24000, -- 3766
			maxFiles = 8 -- 3767
		} -- 3767
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3769
			if maxChars <= 0 then -- 3769
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3770
			end -- 3770
			if #sourceText <= maxChars then -- 3770
				return sourceText -- 3771
			end -- 3771
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3772
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3773
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3774
		end -- 3769
		local function countLines(sourceText) -- 3776
			if sourceText == "" then -- 3776
				return 0 -- 3777
			end -- 3777
			return #__TS__StringSplit(sourceText, "\n") -- 3778
		end -- 3776
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3780
			if beforeContent == afterContent then -- 3780
				return "" -- 3781
			end -- 3781
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3782
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3783
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3785
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3785
				firstChangedLine = firstChangedLine + 1 -- 3791
			end -- 3791
			local lastChangedBeforeLine = #beforeLines - 1 -- 3793
			local lastChangedAfterLine = #afterLines - 1 -- 3794
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3794
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3800
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3801
			end -- 3801
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3803
			local previewEndLine = math.max( -- 3804
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3805
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3806
			) -- 3806
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3808
			do -- 3808
				local lineIndex = previewStartLine -- 3809
				while lineIndex <= previewEndLine do -- 3809
					do -- 3809
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3810
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3811
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3812
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3813
						if not beforeChanged and not afterChanged then -- 3813
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3815
							if contextLine ~= nil then -- 3815
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3816
							end -- 3816
							goto __continue584 -- 3817
						end -- 3817
						if beforeChanged and beforeLine ~= nil then -- 3817
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3819
						end -- 3819
						if afterChanged and afterLine ~= nil then -- 3819
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3820
						end -- 3820
					end -- 3820
					::__continue584:: -- 3820
					lineIndex = lineIndex + 1 -- 3809
				end -- 3809
			end -- 3809
			return truncateContextSnippet( -- 3822
				table.concat(unifiedDiffLines, "\n"), -- 3822
				maxChars, -- 3822
				"diff" -- 3822
			) -- 3822
		end -- 3780
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3825
		if not checkpointDiff.success then -- 3825
			return result -- 3826
		end -- 3826
		local remainingContextBudget = contextLimits.totalChars -- 3827
		local fileContextItems = {} -- 3828
		local changedFiles = checkpointDiff.files -- 3829
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3830
		do -- 3830
			local fileIndex = 0 -- 3831
			while fileIndex < maxContextFiles do -- 3831
				if remainingContextBudget <= 0 then -- 3831
					break -- 3832
				end -- 3832
				local changedFile = changedFiles[fileIndex + 1] -- 3833
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3834
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3835
				local contextItem = { -- 3836
					path = changedFile.path, -- 3837
					op = changedFile.op, -- 3838
					checkpointId = result.checkpointId, -- 3839
					checkpointSeq = result.checkpointSeq, -- 3840
					beforeExists = changedFile.beforeExists, -- 3841
					afterExists = changedFile.afterExists, -- 3842
					beforeBytes = #beforeContent, -- 3843
					afterBytes = #afterContent, -- 3844
					diffPreview = "", -- 3845
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3846
					contentTruncated = false, -- 3847
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3848
				} -- 3848
				if changedFile.afterExists then -- 3848
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3848
						contextItem.afterContent = afterContent -- 3852
						remainingContextBudget = remainingContextBudget - #afterContent -- 3853
					else -- 3853
						contextItem.afterContentPreview = truncateContextSnippet( -- 3855
							afterContent, -- 3856
							math.min( -- 3857
								contextLimits.previewChars, -- 3857
								math.max(400, remainingContextBudget) -- 3857
							), -- 3857
							"afterContent" -- 3858
						) -- 3858
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 3860
						contextItem.contentTruncated = true -- 3861
					end -- 3861
				end -- 3861
				local diffPreview = buildUnifiedDiffPreview( -- 3864
					changedFile.path, -- 3865
					beforeContent, -- 3866
					afterContent, -- 3867
					math.min( -- 3868
						contextLimits.diffChars, -- 3868
						math.max(400, remainingContextBudget) -- 3868
					) -- 3868
				) -- 3868
				contextItem.diffPreview = diffPreview -- 3870
				remainingContextBudget = remainingContextBudget - #diffPreview -- 3871
				if not changedFile.afterExists and beforeContent ~= "" then -- 3871
					contextItem.beforeContentPreview = truncateContextSnippet( -- 3873
						beforeContent, -- 3874
						math.min( -- 3875
							contextLimits.previewChars, -- 3875
							math.max(400, remainingContextBudget) -- 3875
						), -- 3875
						"beforeContent" -- 3876
					) -- 3876
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 3878
					if #beforeContent > contextLimits.previewChars then -- 3878
						contextItem.contentTruncated = true -- 3879
					end -- 3879
				end -- 3879
				fileContextItems[#fileContextItems + 1] = contextItem -- 3881
				fileIndex = fileIndex + 1 -- 3831
			end -- 3831
		end -- 3831
		if #fileContextItems == 0 then -- 3831
			return result -- 3883
		end -- 3883
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 3884
	end -- 3884
	return result -- 3891
end -- 3891
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
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 790
	local messagesTokens = 0 -- 797
	do -- 797
		local i = 0 -- 798
		while i < #messages do -- 798
			local message = messages[i + 1] -- 799
			messagesTokens = messagesTokens + 8 -- 800
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 801
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 802
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 803
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 804
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 805
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 806
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 807
			i = i + 1 -- 798
		end -- 798
	end -- 798
	local toolDefinitionsTokens = 0 -- 810
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 810
		local toolsText = safeJsonEncode(options.tools) -- 812
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 813
	end -- 813
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 816
	__TS__Delete(optionsWithoutTools, "tools") -- 817
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 818
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 819
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 820
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 821
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 826
		1024, -- 828
		math.floor(contextWindow * 0.2) -- 828
	) -- 828
	local structuralOverhead = math.max(256, #messages * 16) -- 829
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 831
	local maxTokens = contextWindow -- 832
	emitAgentEvent( -- 833
		shared, -- 833
		{ -- 833
			type = "metrics_updated", -- 834
			sessionId = shared.sessionId, -- 835
			taskId = shared.taskId, -- 836
			step = step, -- 837
			metrics = {context = { -- 838
				usedTokens = usedTokens, -- 840
				maxTokens = maxTokens, -- 841
				ratio = math.max( -- 842
					0, -- 842
					math.min(1, usedTokens / maxTokens) -- 842
				), -- 842
				messagesTokens = messagesTokens, -- 843
				optionsTokens = optionsTokens, -- 844
				toolDefinitionsTokens = toolDefinitionsTokens, -- 845
				reservedOutputTokens = reservedOutputTokens, -- 846
				structuralOverhead = structuralOverhead, -- 847
				contextWindow = contextWindow, -- 848
				source = "llm_input_estimate", -- 849
				updatedAt = os.time(), -- 850
				phase = phase, -- 851
				step = step -- 852
			}} -- 852
		} -- 852
	) -- 852
end -- 790
local function emitAgentStartEvent(shared, action) -- 858
	emitAgentEvent(shared, { -- 859
		type = "tool_started", -- 860
		sessionId = shared.sessionId, -- 861
		taskId = shared.taskId, -- 862
		step = action.step, -- 863
		tool = action.tool -- 864
	}) -- 864
end -- 858
local function emitAgentFinishEvent(shared, action) -- 868
	emitAgentEvent(shared, { -- 869
		type = "tool_finished", -- 870
		sessionId = shared.sessionId, -- 871
		taskId = shared.taskId, -- 872
		step = action.step, -- 873
		tool = action.tool, -- 874
		result = action.result or ({}) -- 875
	}) -- 875
end -- 868
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 879
	emitAgentEvent(shared, { -- 880
		type = "assistant_message_updated", -- 881
		sessionId = shared.sessionId, -- 882
		taskId = shared.taskId, -- 883
		step = shared.step + 1, -- 884
		content = content, -- 885
		reasoningContent = reasoningContent -- 886
	}) -- 886
end -- 879
local function getMemoryCompressionStartReason(shared) -- 890
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 891
end -- 890
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 896
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 897
end -- 896
local function getMemoryCompressionFailureReason(shared, ____error) -- 902
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 903
end -- 902
local function summarizeHistoryEntryPreview(text, maxChars) -- 908
	if maxChars == nil then -- 908
		maxChars = 180 -- 908
	end -- 908
	local trimmed = __TS__StringTrim(text) -- 909
	if trimmed == "" then -- 909
		return "" -- 910
	end -- 910
	return truncateText(trimmed, maxChars) -- 911
end -- 908
local function getMaxStepsReachedReason(shared) -- 919
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 920
end -- 919
local function getFailureSummaryFallback(shared, ____error) -- 925
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 926
end -- 925
local function finalizeAgentFailure(shared, ____error) -- 931
	if shared.stopToken.stopped then -- 931
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 933
		return emitAgentTaskFinishEvent( -- 934
			shared, -- 934
			false, -- 934
			getCancelledReason(shared) -- 934
		) -- 934
	end -- 934
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 936
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 937
end -- 931
local function getPromptCommand(prompt) -- 940
	local trimmed = __TS__StringTrim(prompt) -- 941
	if trimmed == "/compact" then -- 941
		return "compact" -- 942
	end -- 942
	if trimmed == "/clear" then -- 942
		return "clear" -- 943
	end -- 943
	return nil -- 944
end -- 940
function ____exports.truncateAgentUserPrompt(prompt) -- 947
	if not prompt then -- 947
		return "" -- 948
	end -- 948
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 948
		return prompt -- 949
	end -- 949
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 950
	if offset == nil then -- 950
		return prompt -- 951
	end -- 951
	return string.sub(prompt, 1, offset - 1) -- 952
end -- 947
local function canWriteStepLLMDebug(shared, stepId) -- 955
	if stepId == nil then -- 955
		stepId = shared.step + 1 -- 955
	end -- 955
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 956
end -- 955
local function ensureDirRecursive(dir) -- 963
	if not dir then -- 963
		return false -- 964
	end -- 964
	if Content:exist(dir) then -- 964
		return Content:isdir(dir) -- 965
	end -- 965
	local parent = Path:getPath(dir) -- 966
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 966
		return false -- 968
	end -- 968
	return Content:mkdir(dir) -- 970
end -- 963
local function encodeDebugJSON(value) -- 973
	local text, err = safeJsonEncode(value) -- 974
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 975
end -- 973
local function getStepLLMDebugDir(shared) -- 978
	return Path( -- 979
		shared.workingDir, -- 980
		".agent", -- 981
		tostring(shared.sessionId), -- 982
		tostring(shared.taskId) -- 983
	) -- 983
end -- 978
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 987
	return Path( -- 988
		getStepLLMDebugDir(shared), -- 988
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 988
	) -- 988
end -- 987
local function getLatestStepLLMDebugSeq(shared, stepId) -- 991
	if not canWriteStepLLMDebug(shared, stepId) then -- 991
		return 0 -- 992
	end -- 992
	local dir = getStepLLMDebugDir(shared) -- 993
	if not Content:exist(dir) or not Content:isdir(dir) then -- 993
		return 0 -- 994
	end -- 994
	local latest = 0 -- 995
	for ____, file in ipairs(Content:getFiles(dir)) do -- 996
		do -- 996
			local name = Path:getFilename(file) -- 997
			local seqText = string.match( -- 998
				name, -- 998
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 998
			) -- 998
			if seqText ~= nil then -- 998
				latest = math.max( -- 1000
					latest, -- 1000
					tonumber(seqText) -- 1000
				) -- 1000
				goto __continue128 -- 1001
			end -- 1001
			local legacyMatch = string.match( -- 1003
				name, -- 1003
				("^" .. tostring(stepId)) .. "_in%.md$" -- 1003
			) -- 1003
			if legacyMatch ~= nil then -- 1003
				latest = math.max(latest, 1) -- 1005
			end -- 1005
		end -- 1005
		::__continue128:: -- 1005
	end -- 1005
	return latest -- 1008
end -- 991
local function writeStepLLMDebugFile(path, content) -- 1011
	if not Content:save(path, content) then -- 1011
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 1013
		return false -- 1014
	end -- 1014
	return true -- 1016
end -- 1011
local function createStepLLMDebugPair(shared, stepId, inContent) -- 1019
	if not canWriteStepLLMDebug(shared, stepId) then -- 1019
		return 0 -- 1020
	end -- 1020
	local dir = getStepLLMDebugDir(shared) -- 1021
	if not ensureDirRecursive(dir) then -- 1021
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1023
		return 0 -- 1024
	end -- 1024
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 1026
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 1027
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 1028
	if not writeStepLLMDebugFile(inPath, inContent) then -- 1028
		return 0 -- 1030
	end -- 1030
	writeStepLLMDebugFile(outPath, "") -- 1032
	return seq -- 1033
end -- 1019
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 1036
	if not canWriteStepLLMDebug(shared, stepId) then -- 1036
		return -- 1037
	end -- 1037
	local dir = getStepLLMDebugDir(shared) -- 1038
	if not ensureDirRecursive(dir) then -- 1038
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1040
		return -- 1041
	end -- 1041
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 1043
	if latestSeq <= 0 then -- 1043
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 1045
		writeStepLLMDebugFile(outPath, content) -- 1046
		return -- 1047
	end -- 1047
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 1049
	writeStepLLMDebugFile(outPath, content) -- 1050
end -- 1036
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 1053
	if not canWriteStepLLMDebug(shared, stepId) then -- 1053
		return -- 1054
	end -- 1054
	local sections = { -- 1055
		"# LLM Input", -- 1056
		"session_id: " .. tostring(shared.sessionId), -- 1057
		"task_id: " .. tostring(shared.taskId), -- 1058
		"step_id: " .. tostring(stepId), -- 1059
		"phase: " .. phase, -- 1060
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1061
		"## Options", -- 1062
		"```json", -- 1063
		encodeDebugJSON(options), -- 1064
		"```" -- 1065
	} -- 1065
	do -- 1065
		local i = 0 -- 1067
		while i < #messages do -- 1067
			local message = messages[i + 1] -- 1068
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 1069
			sections[#sections + 1] = encodeDebugJSON(message) -- 1070
			i = i + 1 -- 1067
		end -- 1067
	end -- 1067
	createStepLLMDebugPair( -- 1072
		shared, -- 1072
		stepId, -- 1072
		table.concat(sections, "\n") -- 1072
	) -- 1072
end -- 1053
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 1075
	if not canWriteStepLLMDebug(shared, stepId) then -- 1075
		return -- 1076
	end -- 1076
	local ____array_2 = __TS__SparseArrayNew( -- 1076
		"# LLM Output", -- 1078
		"session_id: " .. tostring(shared.sessionId), -- 1079
		"task_id: " .. tostring(shared.taskId), -- 1080
		"step_id: " .. tostring(stepId), -- 1081
		"phase: " .. phase, -- 1082
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1083
		table.unpack(meta and ({ -- 1084
			"## Meta", -- 1084
			"```json", -- 1084
			encodeDebugJSON(meta), -- 1084
			"```" -- 1084
		}) or ({})) -- 1084
	) -- 1084
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 1084
	local sections = {__TS__SparseArraySpread(____array_2)} -- 1077
	updateLatestStepLLMDebugOutput( -- 1088
		shared, -- 1088
		stepId, -- 1088
		table.concat(sections, "\n") -- 1088
	) -- 1088
end -- 1075
local function toJson(value) -- 1091
	local text, err = safeJsonEncode(value) -- 1092
	if text ~= nil then -- 1092
		return text -- 1093
	end -- 1093
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 1094
end -- 1091
local function summarizeEditTextParamForHistory(value, key) -- 1144
	if type(value) ~= "string" then -- 1144
		return nil -- 1145
	end -- 1145
	local text = value -- 1146
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1147
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1148
end -- 1144
local function sanitizeActionParamsForHistory(tool, params) -- 1258
	if tool ~= "edit_file" then -- 1258
		return params -- 1259
	end -- 1259
	local clone = {} -- 1260
	for key in pairs(params) do -- 1261
		if key == "old_str" then -- 1261
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1263
		elseif key == "new_str" then -- 1263
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1265
		else -- 1265
			clone[key] = params[key] -- 1267
		end -- 1267
	end -- 1267
	return clone -- 1270
end -- 1258
local function isToolAllowedForRole(role, tool) -- 1315
	return __TS__ArrayIndexOf( -- 1316
		getAllowedToolsForRole(role), -- 1316
		tool -- 1316
	) >= 0 -- 1316
end -- 1315
local PRE_EXEC_SAFE_TOOLS = { -- 1319
	"read_file", -- 1320
	"grep_files", -- 1321
	"search_dora_api", -- 1322
	"glob_files", -- 1323
	"list_sub_agents" -- 1324
} -- 1324
local CACHEABLE_TOOL_RESULTS = { -- 1327
	"read_file", -- 1328
	"grep_files", -- 1329
	"search_dora_api", -- 1330
	"glob_files", -- 1331
	"list_sub_agents" -- 1332
} -- 1332
local function canPreExecuteTool(tool) -- 1335
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1336
end -- 1335
local function canCacheToolResult(tool) -- 1339
	return __TS__ArrayIndexOf(CACHEABLE_TOOL_RESULTS, tool) >= 0 -- 1340
end -- 1339
local function clearPreExecutedResults(shared) -- 1343
	shared.preExecutedResults = nil -- 1344
end -- 1343
local function getToolActionSignature(action) -- 1347
	return (action.tool .. ":") .. toJson(action.params) -- 1348
end -- 1347
local function startPreExecutedToolAction(shared, action) -- 1351
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1351
		local ____try = __TS__AsyncAwaiter(function() -- 1351
			return ____awaiter_resolve( -- 1351
				nil, -- 1351
				__TS__Await(executeToolAction(shared, action)) -- 1353
			) -- 1353
		end) -- 1353
		__TS__Await(____try.catch( -- 1352
			____try, -- 1352
			function(____, err) -- 1352
				local message = tostring(err) -- 1355
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1356
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1356
			end -- 1356
		)) -- 1356
	end) -- 1356
end -- 1351
local function executeToolActionWithPreExecution(shared, action) -- 1361
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1361
		local ____opt_9 = shared.preExecutedResults -- 1361
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1362
		if preResult then -- 1362
			local ____opt_11 = shared.preExecutedResults -- 1362
			if ____opt_11 ~= nil then -- 1362
				____opt_11:delete(action.toolCallId) -- 1364
			end -- 1364
			local signature = getToolActionSignature(action) -- 1365
			if preResult.signature == signature then -- 1365
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1367
				return ____awaiter_resolve( -- 1367
					nil, -- 1367
					__TS__Await(preResult.promise) -- 1368
				) -- 1368
			end -- 1368
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1370
		end -- 1370
		return ____awaiter_resolve( -- 1370
			nil, -- 1370
			executeToolAction(shared, action) -- 1372
		) -- 1372
	end) -- 1372
end -- 1361
local function shouldClearToolResultCache(action) -- 1375
	return action.tool == "edit_file" or action.tool == "delete_file" or action.tool == "spawn_sub_agent" -- 1376
end -- 1375
local function executeToolActionWithCache(shared, action) -- 1381
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1381
		if canCacheToolResult(action.tool) then -- 1381
			local cacheKey = getToolActionSignature(action) -- 1383
			local ____opt_13 = shared.toolResultCache -- 1383
			local cached = ____opt_13 and ____opt_13:get(cacheKey) -- 1384
			if cached then -- 1384
				Log("Info", "[CodingAgent] using cached tool result tool=" .. action.tool) -- 1386
				return ____awaiter_resolve(nil, cached) -- 1386
			end -- 1386
			local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 1389
			local ____opt_15 = shared.toolResultCache -- 1389
			if ____opt_15 ~= nil then -- 1389
				____opt_15:set(cacheKey, result) -- 1390
			end -- 1390
			return ____awaiter_resolve(nil, result) -- 1390
		end -- 1390
		local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 1393
		if shouldClearToolResultCache(action) and result.success == true then -- 1393
			local ____opt_17 = shared.toolResultCache -- 1393
			if ____opt_17 ~= nil then -- 1393
				____opt_17:clear() -- 1395
			end -- 1395
		end -- 1395
		return ____awaiter_resolve(nil, result) -- 1395
	end) -- 1395
end -- 1381
local function maybeCompressHistory(shared) -- 1400
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1400
		local ____shared_19 = shared -- 1401
		local memory = ____shared_19.memory -- 1401
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1402
		local changed = false -- 1403
		do -- 1403
			local round = 0 -- 1404
			while round < maxRounds do -- 1404
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1405
				local activeMessages = getActiveConversationMessages(shared) -- 1406
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1410
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1410
					if changed then -- 1410
						persistHistoryState(shared) -- 1419
					end -- 1419
					return ____awaiter_resolve(nil) -- 1419
				end -- 1419
				local compressionRound = round + 1 -- 1423
				shared.step = shared.step + 1 -- 1424
				local stepId = shared.step -- 1425
				local pendingMessages = #activeMessages -- 1426
				emitAgentEvent( -- 1427
					shared, -- 1427
					{ -- 1427
						type = "memory_compression_started", -- 1428
						sessionId = shared.sessionId, -- 1429
						taskId = shared.taskId, -- 1430
						step = stepId, -- 1431
						tool = "compress_memory", -- 1432
						reason = getMemoryCompressionStartReason(shared), -- 1433
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1434
					} -- 1434
				) -- 1434
				local result = __TS__Await(memory.compressor:compress( -- 1440
					activeMessages, -- 1441
					shared.llmOptions, -- 1442
					shared.llmMaxTry, -- 1443
					shared.decisionMode, -- 1444
					{ -- 1445
						onInput = function(____, phase, messages, options) -- 1446
							saveStepLLMDebugInput( -- 1447
								shared, -- 1447
								stepId, -- 1447
								phase, -- 1447
								messages, -- 1447
								options -- 1447
							) -- 1447
						end, -- 1446
						onOutput = function(____, phase, text, meta) -- 1449
							saveStepLLMDebugOutput( -- 1450
								shared, -- 1450
								stepId, -- 1450
								phase, -- 1450
								text, -- 1450
								meta -- 1450
							) -- 1450
						end -- 1449
					}, -- 1449
					"default", -- 1453
					systemPrompt, -- 1454
					toolDefinitions -- 1455
				)) -- 1455
				if not (result and result.success and result.compressedCount > 0) then -- 1455
					emitAgentEvent( -- 1458
						shared, -- 1458
						{ -- 1458
							type = "memory_compression_finished", -- 1459
							sessionId = shared.sessionId, -- 1460
							taskId = shared.taskId, -- 1461
							step = stepId, -- 1462
							tool = "compress_memory", -- 1463
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1464
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1468
						} -- 1468
					) -- 1468
					if changed then -- 1468
						persistHistoryState(shared) -- 1476
					end -- 1476
					return ____awaiter_resolve(nil) -- 1476
				end -- 1476
				local effectiveCompressedCount = math.max( -- 1480
					0, -- 1481
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1482
				) -- 1482
				if effectiveCompressedCount <= 0 then -- 1482
					if changed then -- 1482
						persistHistoryState(shared) -- 1486
					end -- 1486
					return ____awaiter_resolve(nil) -- 1486
				end -- 1486
				emitAgentEvent( -- 1490
					shared, -- 1490
					{ -- 1490
						type = "memory_compression_finished", -- 1491
						sessionId = shared.sessionId, -- 1492
						taskId = shared.taskId, -- 1493
						step = stepId, -- 1494
						tool = "compress_memory", -- 1495
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1496
						result = { -- 1497
							success = true, -- 1498
							round = compressionRound, -- 1499
							compressedCount = effectiveCompressedCount, -- 1500
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1501
						} -- 1501
					} -- 1501
				) -- 1501
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1504
				changed = true -- 1505
				Log( -- 1506
					"Info", -- 1506
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1506
				) -- 1506
				round = round + 1 -- 1404
			end -- 1404
		end -- 1404
		if changed then -- 1404
			persistHistoryState(shared) -- 1509
		end -- 1509
	end) -- 1509
end -- 1400
local function compactAllHistory(shared) -- 1513
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1513
		local ____shared_26 = shared -- 1514
		local memory = ____shared_26.memory -- 1514
		local rounds = 0 -- 1515
		local totalCompressed = 0 -- 1516
		while getActiveRealMessageCount(shared) > 0 do -- 1516
			if shared.stopToken.stopped then -- 1516
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1519
				return ____awaiter_resolve( -- 1519
					nil, -- 1519
					emitAgentTaskFinishEvent( -- 1520
						shared, -- 1520
						false, -- 1520
						getCancelledReason(shared) -- 1520
					) -- 1520
				) -- 1520
			end -- 1520
			rounds = rounds + 1 -- 1522
			shared.step = shared.step + 1 -- 1523
			local stepId = shared.step -- 1524
			local activeMessages = getActiveConversationMessages(shared) -- 1525
			local pendingMessages = #activeMessages -- 1526
			emitAgentEvent( -- 1527
				shared, -- 1527
				{ -- 1527
					type = "memory_compression_started", -- 1528
					sessionId = shared.sessionId, -- 1529
					taskId = shared.taskId, -- 1530
					step = stepId, -- 1531
					tool = "compress_memory", -- 1532
					reason = getMemoryCompressionStartReason(shared), -- 1533
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1534
				} -- 1534
			) -- 1534
			local result = __TS__Await(memory.compressor:compress( -- 1541
				activeMessages, -- 1542
				shared.llmOptions, -- 1543
				shared.llmMaxTry, -- 1544
				shared.decisionMode, -- 1545
				{ -- 1546
					onInput = function(____, phase, messages, options) -- 1547
						saveStepLLMDebugInput( -- 1548
							shared, -- 1548
							stepId, -- 1548
							phase, -- 1548
							messages, -- 1548
							options -- 1548
						) -- 1548
					end, -- 1547
					onOutput = function(____, phase, text, meta) -- 1550
						saveStepLLMDebugOutput( -- 1551
							shared, -- 1551
							stepId, -- 1551
							phase, -- 1551
							text, -- 1551
							meta -- 1551
						) -- 1551
					end -- 1550
				}, -- 1550
				"budget_max" -- 1554
			)) -- 1554
			if not (result and result.success and result.compressedCount > 0) then -- 1554
				emitAgentEvent( -- 1557
					shared, -- 1557
					{ -- 1557
						type = "memory_compression_finished", -- 1558
						sessionId = shared.sessionId, -- 1559
						taskId = shared.taskId, -- 1560
						step = stepId, -- 1561
						tool = "compress_memory", -- 1562
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1563
						result = { -- 1567
							success = false, -- 1568
							rounds = rounds, -- 1569
							error = result and result.error or "compression returned no changes", -- 1570
							compressedCount = result and result.compressedCount or 0, -- 1571
							fullCompaction = true -- 1572
						} -- 1572
					} -- 1572
				) -- 1572
				return ____awaiter_resolve( -- 1572
					nil, -- 1572
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1575
				) -- 1575
			end -- 1575
			local effectiveCompressedCount = math.max( -- 1580
				0, -- 1581
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1582
			) -- 1582
			if effectiveCompressedCount <= 0 then -- 1582
				return ____awaiter_resolve( -- 1582
					nil, -- 1582
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1585
				) -- 1585
			end -- 1585
			emitAgentEvent( -- 1592
				shared, -- 1592
				{ -- 1592
					type = "memory_compression_finished", -- 1593
					sessionId = shared.sessionId, -- 1594
					taskId = shared.taskId, -- 1595
					step = stepId, -- 1596
					tool = "compress_memory", -- 1597
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1598
					result = { -- 1599
						success = true, -- 1600
						round = rounds, -- 1601
						compressedCount = effectiveCompressedCount, -- 1602
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1603
						fullCompaction = true -- 1604
					} -- 1604
				} -- 1604
			) -- 1604
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1607
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1608
			persistHistoryState(shared) -- 1609
			Log( -- 1610
				"Info", -- 1610
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1610
			) -- 1610
		end -- 1610
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1612
		return ____awaiter_resolve( -- 1612
			nil, -- 1612
			emitAgentTaskFinishEvent( -- 1613
				shared, -- 1614
				true, -- 1615
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1616
			) -- 1616
		) -- 1616
	end) -- 1616
end -- 1513
local function clearSessionHistory(shared) -- 1622
	shared.messages = {} -- 1623
	shared.lastConsolidatedIndex = 0 -- 1624
	shared.carryMessageIndex = nil -- 1625
	persistHistoryState(shared) -- 1626
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1627
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1628
end -- 1622
local function isKnownToolName(name) -- 1637
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1638
end -- 1637
local function appendConversationMessage(shared, message) -- 1731
	local ____shared_messages_35 = shared.messages -- 1731
	____shared_messages_35[#____shared_messages_35 + 1] = __TS__ObjectAssign( -- 1732
		{}, -- 1732
		message, -- 1733
		{ -- 1732
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1734
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1735
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1736
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1737
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1738
		} -- 1738
	) -- 1738
end -- 1731
local function ensureToolCallId(toolCallId) -- 1742
	if toolCallId and toolCallId ~= "" then -- 1742
		return toolCallId -- 1743
	end -- 1743
	return createLocalToolCallId() -- 1744
end -- 1742
local function appendToolResultMessage(shared, action) -- 1747
	appendConversationMessage( -- 1748
		shared, -- 1748
		{ -- 1748
			role = "tool", -- 1749
			tool_call_id = action.toolCallId, -- 1750
			name = action.tool, -- 1751
			content = action.result and toJson(action.result) or "" -- 1752
		} -- 1752
	) -- 1752
end -- 1747
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1756
	appendConversationMessage( -- 1762
		shared, -- 1762
		{ -- 1762
			role = "assistant", -- 1763
			content = content or "", -- 1764
			reasoning_content = reasoningContent, -- 1765
			tool_calls = __TS__ArrayMap( -- 1766
				actions, -- 1766
				function(____, action) return { -- 1766
					id = action.toolCallId, -- 1767
					type = "function", -- 1768
					["function"] = { -- 1769
						name = action.tool, -- 1770
						arguments = toJson(action.params) -- 1771
					} -- 1771
				} end -- 1771
			) -- 1771
		} -- 1771
	) -- 1771
end -- 1756
local function parseXMLToolCallObjectFromText(text) -- 1777
	local children = parseXMLObjectFromText(text, "tool_call") -- 1778
	if not children.success then -- 1778
		return children -- 1779
	end -- 1779
	local rawObj = children.obj -- 1780
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1781
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1782
	if not params.success then -- 1782
		return {success = false, message = params.message} -- 1786
	end -- 1786
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1788
end -- 1777
local function llm(shared, messages, phase) -- 1808
	if phase == nil then -- 1808
		phase = "decision_xml" -- 1811
	end -- 1811
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1811
		local stepId = shared.step + 1 -- 1813
		emitLLMContextMetrics( -- 1814
			shared, -- 1814
			stepId, -- 1814
			phase, -- 1814
			messages, -- 1814
			shared.llmOptions -- 1814
		) -- 1814
		saveStepLLMDebugInput( -- 1815
			shared, -- 1815
			stepId, -- 1815
			phase, -- 1815
			messages, -- 1815
			shared.llmOptions -- 1815
		) -- 1815
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1816
		if res.success then -- 1816
			local ____opt_38 = res.response.choices -- 1816
			local ____opt_36 = ____opt_38 and ____opt_38[1] -- 1816
			local message = ____opt_36 and ____opt_36.message -- 1818
			local text = message and message.content -- 1819
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1820
			if text then -- 1820
				saveStepLLMDebugOutput( -- 1824
					shared, -- 1824
					stepId, -- 1824
					phase, -- 1824
					text, -- 1824
					{success = true} -- 1824
				) -- 1824
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1824
			else -- 1824
				saveStepLLMDebugOutput( -- 1827
					shared, -- 1827
					stepId, -- 1827
					phase, -- 1827
					"empty LLM response", -- 1827
					{success = false} -- 1827
				) -- 1827
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1827
			end -- 1827
		else -- 1827
			saveStepLLMDebugOutput( -- 1831
				shared, -- 1831
				stepId, -- 1831
				phase, -- 1831
				res.raw or res.message, -- 1831
				{success = false} -- 1831
			) -- 1831
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1831
		end -- 1831
	end) -- 1831
end -- 1808
local function isDecisionBatchSuccess(result) -- 1855
	return result.kind == "batch" -- 1856
end -- 1855
local function parseDecisionObject(rawObj) -- 1859
	if type(rawObj.tool) ~= "string" then -- 1859
		return {success = false, message = "missing tool"} -- 1860
	end -- 1860
	local tool = rawObj.tool -- 1861
	if not isKnownToolName(tool) then -- 1861
		return {success = false, message = "unknown tool: " .. tool} -- 1863
	end -- 1863
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1865
	if tool ~= "finish" and (not reason or reason == "") then -- 1865
		return {success = false, message = tool .. " requires top-level reason"} -- 1869
	end -- 1869
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1871
	return {success = true, tool = tool, params = params, reason = reason} -- 1872
end -- 1859
local function parseDecisionToolCall(functionName, rawObj) -- 1880
	if not isKnownToolName(functionName) then -- 1880
		return {success = false, message = "unknown tool: " .. functionName} -- 1882
	end -- 1882
	if rawObj == nil or rawObj == nil then -- 1882
		return {success = true, tool = functionName, params = {}} -- 1885
	end -- 1885
	if not isRecord(rawObj) then -- 1885
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1888
	end -- 1888
	return {success = true, tool = functionName, params = rawObj} -- 1890
end -- 1880
local function parseToolCallArguments(functionName, argsText) -- 1897
	local trimmedArgs = __TS__StringTrim(argsText) -- 1898
	if trimmedArgs == "" then -- 1898
		return {} -- 1900
	end -- 1900
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1902
	if err ~= nil or rawObj == nil then -- 1902
		return { -- 1904
			success = false, -- 1905
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1906
			raw = argsText -- 1907
		} -- 1907
	end -- 1907
	local encodedRaw = safeJsonEncode(rawObj) -- 1910
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1910
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1912
	end -- 1912
	return rawObj -- 1918
end -- 1897
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1921
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1929
	if isRecord(rawArgs) and rawArgs.success == false then -- 1929
		return rawArgs -- 1931
	end -- 1931
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1933
	if not decision.success then -- 1933
		return {success = false, message = decision.message, raw = argsText} -- 1935
	end -- 1935
	local validation = validateDecision(decision.tool, decision.params) -- 1941
	if not validation.success then -- 1941
		return {success = false, message = validation.message, raw = argsText} -- 1943
	end -- 1943
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1943
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1950
	end -- 1950
	decision.params = validation.params -- 1956
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1957
	decision.reason = reason -- 1958
	decision.reasoningContent = reasoningContent -- 1959
	return decision -- 1960
end -- 1921
local function createPreExecutableActionFromStream(shared, toolCall) -- 1963
	local ____opt_44 = toolCall["function"] -- 1963
	local functionName = ____opt_44 and ____opt_44.name -- 1964
	local ____opt_46 = toolCall["function"] -- 1964
	local argsText = ____opt_46 and ____opt_46.arguments or "" -- 1965
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1966
	if not functionName or not toolCallId then -- 1966
		return nil -- 1967
	end -- 1967
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1968
	if isRecord(rawArgs) and rawArgs.success == false then -- 1968
		return nil -- 1969
	end -- 1969
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1970
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1970
		return nil -- 1971
	end -- 1971
	local validation = validateDecision(decision.tool, decision.params) -- 1972
	if not validation.success then -- 1972
		return nil -- 1973
	end -- 1973
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1973
		return nil -- 1974
	end -- 1974
	return { -- 1975
		step = shared.step + 1, -- 1976
		toolCallId = toolCallId, -- 1977
		tool = decision.tool, -- 1978
		reason = "", -- 1979
		params = validation.params, -- 1980
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1981
	} -- 1981
end -- 1963
local function createFunctionToolSchema(name, description, properties, required) -- 2121
	if required == nil then -- 2121
		required = {} -- 2125
	end -- 2125
	local parameters = {type = "object", properties = properties} -- 2127
	if #required > 0 then -- 2127
		parameters.required = required -- 2132
	end -- 2132
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2134
end -- 2121
local function buildDecisionToolSchema(shared) -- 2150
	local allowed = getAllowedToolsForRole(shared.role) -- 2151
	local tools = { -- 2152
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2153
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2163
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2173
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2181
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2185
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2186
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2187
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2188
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2189
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2190
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2191
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2192
		}, {"pattern"}), -- 2192
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2196
		createFunctionToolSchema( -- 2205
			"search_dora_api", -- 2206
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2206
			{ -- 2208
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2209
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2210
				programmingLanguage = {type = "string", enum = { -- 2211
					"ts", -- 2213
					"tsx", -- 2213
					"lua", -- 2213
					"yue", -- 2213
					"teal", -- 2213
					"tl", -- 2213
					"wa" -- 2213
				}, description = "Preferred language variant to search."}, -- 2213
				limit = { -- 2216
					type = "number", -- 2216
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2216
				}, -- 2216
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2217
			}, -- 2217
			{"pattern"} -- 2219
		), -- 2219
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2221
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2228
			"active_or_recent", -- 2232
			"running", -- 2232
			"done", -- 2232
			"failed", -- 2232
			"all" -- 2232
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2232
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2238
	} -- 2238
	return __TS__ArrayFilter( -- 2250
		tools, -- 2250
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2250
	) -- 2250
end -- 2150
local function sanitizeMessagesForLLMInput(messages) -- 2291
	local sanitized = {} -- 2292
	local droppedAssistantToolCalls = 0 -- 2293
	local droppedToolResults = 0 -- 2294
	do -- 2294
		local i = 0 -- 2295
		while i < #messages do -- 2295
			do -- 2295
				local message = messages[i + 1] -- 2296
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2296
					local requiredIds = {} -- 2298
					do -- 2298
						local j = 0 -- 2299
						while j < #message.tool_calls do -- 2299
							local toolCall = message.tool_calls[j + 1] -- 2300
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2301
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2301
								requiredIds[#requiredIds + 1] = id -- 2303
							end -- 2303
							j = j + 1 -- 2299
						end -- 2299
					end -- 2299
					if #requiredIds == 0 then -- 2299
						sanitized[#sanitized + 1] = message -- 2307
						goto __continue347 -- 2308
					end -- 2308
					local matchedIds = {} -- 2310
					local matchedTools = {} -- 2311
					local j = i + 1 -- 2312
					while j < #messages do -- 2312
						local toolMessage = messages[j + 1] -- 2314
						if toolMessage.role ~= "tool" then -- 2314
							break -- 2315
						end -- 2315
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2316
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2316
							matchedIds[toolCallId] = true -- 2318
							matchedTools[#matchedTools + 1] = toolMessage -- 2319
						else -- 2319
							droppedToolResults = droppedToolResults + 1 -- 2321
						end -- 2321
						j = j + 1 -- 2323
					end -- 2323
					local complete = true -- 2325
					do -- 2325
						local j = 0 -- 2326
						while j < #requiredIds do -- 2326
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2326
								complete = false -- 2328
								break -- 2329
							end -- 2329
							j = j + 1 -- 2326
						end -- 2326
					end -- 2326
					if complete then -- 2326
						__TS__ArrayPush( -- 2333
							sanitized, -- 2333
							message, -- 2333
							table.unpack(matchedTools) -- 2333
						) -- 2333
					else -- 2333
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2335
						droppedToolResults = droppedToolResults + #matchedTools -- 2336
					end -- 2336
					i = j - 1 -- 2338
					goto __continue347 -- 2339
				end -- 2339
				if message.role == "tool" then -- 2339
					droppedToolResults = droppedToolResults + 1 -- 2342
					goto __continue347 -- 2343
				end -- 2343
				sanitized[#sanitized + 1] = message -- 2345
			end -- 2345
			::__continue347:: -- 2345
			i = i + 1 -- 2295
		end -- 2295
	end -- 2295
	return sanitized -- 2347
end -- 2291
local function getUnconsolidatedMessages(shared) -- 2350
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2351
end -- 2350
local function getFinalDecisionTurnPrompt(shared) -- 2354
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2355
end -- 2354
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2360
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2360
		return messages -- 2361
	end -- 2361
	local next = __TS__ArrayMap( -- 2362
		messages, -- 2362
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2362
	) -- 2362
	do -- 2362
		local i = #next - 1 -- 2363
		while i >= 0 do -- 2363
			do -- 2363
				local message = next[i + 1] -- 2364
				if message.role ~= "assistant" and message.role ~= "user" then -- 2364
					goto __continue369 -- 2365
				end -- 2365
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2366
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2367
				return next -- 2370
			end -- 2370
			::__continue369:: -- 2370
			i = i - 1 -- 2363
		end -- 2363
	end -- 2363
	next[#next + 1] = {role = "user", content = prompt} -- 2372
	return next -- 2373
end -- 2360
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2376
	if attempt == nil then -- 2376
		attempt = 1 -- 2379
	end -- 2379
	if decisionMode == nil then -- 2379
		decisionMode = shared.decisionMode -- 2381
	end -- 2381
	local messages = { -- 2383
		{ -- 2384
			role = "system", -- 2384
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2384
		}, -- 2384
		table.unpack(getUnconsolidatedMessages(shared)) -- 2385
	} -- 2385
	if shared.step + 1 >= shared.maxSteps then -- 2385
		messages = appendPromptToLatestDecisionMessage( -- 2388
			messages, -- 2388
			getFinalDecisionTurnPrompt(shared) -- 2388
		) -- 2388
	end -- 2388
	if lastError and lastError ~= "" then -- 2388
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2391
		messages[#messages + 1] = { -- 2394
			role = "user", -- 2395
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2396
		} -- 2396
	end -- 2396
	return messages -- 2403
end -- 2376
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2410
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2417
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2418
	local repairPrompt = replacePromptVars( -- 2426
		shared.promptPack.xmlDecisionRepairPrompt, -- 2426
		{ -- 2426
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2427
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2428
			CANDIDATE_SECTION = candidateSection, -- 2429
			LAST_ERROR = lastError, -- 2430
			ATTEMPT = tostring(attempt) -- 2431
		} -- 2431
	) -- 2431
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2433
end -- 2410
local function tryParseAndValidateDecision(rawText) -- 2445
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2446
	if not parsed.success then -- 2446
		return {success = false, message = parsed.message, raw = rawText} -- 2448
	end -- 2448
	local decision = parseDecisionObject(parsed.obj) -- 2450
	if not decision.success then -- 2450
		return {success = false, message = decision.message, raw = rawText} -- 2452
	end -- 2452
	local validation = validateDecision(decision.tool, decision.params) -- 2454
	if not validation.success then -- 2454
		return {success = false, message = validation.message, raw = rawText} -- 2456
	end -- 2456
	decision.params = validation.params -- 2458
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2459
	return decision -- 2460
end -- 2445
local function normalizeLineEndings(text) -- 2463
	local res = string.gsub(text, "\r\n", "\n") -- 2464
	res = string.gsub(res, "\r", "\n") -- 2465
	return res -- 2466
end -- 2463
local function countOccurrences(text, searchStr) -- 2469
	if searchStr == "" then -- 2469
		return 0 -- 2470
	end -- 2470
	local count = 0 -- 2471
	local pos = 0 -- 2472
	while true do -- 2472
		local idx = (string.find( -- 2474
			text, -- 2474
			searchStr, -- 2474
			math.max(pos + 1, 1), -- 2474
			true -- 2474
		) or 0) - 1 -- 2474
		if idx < 0 then -- 2474
			break -- 2475
		end -- 2475
		count = count + 1 -- 2476
		pos = idx + #searchStr -- 2477
	end -- 2477
	return count -- 2479
end -- 2469
local function replaceFirst(text, oldStr, newStr) -- 2482
	if oldStr == "" then -- 2482
		return text -- 2483
	end -- 2483
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2484
	if idx < 0 then -- 2484
		return text -- 2485
	end -- 2485
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2486
end -- 2482
local function splitLines(text) -- 2489
	return __TS__StringSplit(text, "\n") -- 2490
end -- 2489
local function getLeadingWhitespace(text) -- 2493
	local i = 0 -- 2494
	while i < #text do -- 2494
		local ch = __TS__StringAccess(text, i) -- 2496
		if ch ~= " " and ch ~= "\t" then -- 2496
			break -- 2497
		end -- 2497
		i = i + 1 -- 2498
	end -- 2498
	return __TS__StringSubstring(text, 0, i) -- 2500
end -- 2493
local function getCommonIndentPrefix(lines) -- 2503
	local common -- 2504
	do -- 2504
		local i = 0 -- 2505
		while i < #lines do -- 2505
			do -- 2505
				local line = lines[i + 1] -- 2506
				if __TS__StringTrim(line) == "" then -- 2506
					goto __continue394 -- 2507
				end -- 2507
				local indent = getLeadingWhitespace(line) -- 2508
				if common == nil then -- 2508
					common = indent -- 2510
					goto __continue394 -- 2511
				end -- 2511
				local j = 0 -- 2513
				local maxLen = math.min(#common, #indent) -- 2514
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2514
					j = j + 1 -- 2516
				end -- 2516
				common = __TS__StringSubstring(common, 0, j) -- 2518
				if common == "" then -- 2518
					break -- 2519
				end -- 2519
			end -- 2519
			::__continue394:: -- 2519
			i = i + 1 -- 2505
		end -- 2505
	end -- 2505
	return common or "" -- 2521
end -- 2503
local function removeIndentPrefix(line, indent) -- 2524
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2524
		return __TS__StringSubstring(line, #indent) -- 2526
	end -- 2526
	local lineIndent = getLeadingWhitespace(line) -- 2528
	local j = 0 -- 2529
	local maxLen = math.min(#lineIndent, #indent) -- 2530
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2530
		j = j + 1 -- 2532
	end -- 2532
	return __TS__StringSubstring(line, j) -- 2534
end -- 2524
local function dedentLines(lines) -- 2537
	local indent = getCommonIndentPrefix(lines) -- 2538
	return { -- 2539
		indent = indent, -- 2540
		lines = __TS__ArrayMap( -- 2541
			lines, -- 2541
			function(____, line) return removeIndentPrefix(line, indent) end -- 2541
		) -- 2541
	} -- 2541
end -- 2537
local function joinLines(lines) -- 2545
	return table.concat(lines, "\n") -- 2546
end -- 2545
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2549
	local contentLines = splitLines(content) -- 2554
	local oldLines = splitLines(oldStr) -- 2555
	if #oldLines == 0 then -- 2555
		return {success = false, message = "old_str not found in file"} -- 2557
	end -- 2557
	local dedentedOld = dedentLines(oldLines) -- 2559
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2560
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2561
	local matches = {} -- 2562
	do -- 2562
		local start = 0 -- 2563
		while start <= #contentLines - #oldLines do -- 2563
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2564
			local dedentedCandidate = dedentLines(candidateLines) -- 2565
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2565
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2567
			end -- 2567
			start = start + 1 -- 2563
		end -- 2563
	end -- 2563
	if #matches == 0 then -- 2563
		return {success = false, message = "old_str not found in file"} -- 2575
	end -- 2575
	if #matches > 1 then -- 2575
		return { -- 2578
			success = false, -- 2579
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2580
		} -- 2580
	end -- 2580
	local match = matches[1] -- 2583
	local rebuiltNewLines = __TS__ArrayMap( -- 2584
		dedentedNew.lines, -- 2584
		function(____, line) return line == "" and "" or match.indent .. line end -- 2584
	) -- 2584
	local ____array_52 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2584
	__TS__SparseArrayPush( -- 2584
		____array_52, -- 2584
		table.unpack(rebuiltNewLines) -- 2587
	) -- 2587
	__TS__SparseArrayPush( -- 2587
		____array_52, -- 2587
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2588
	) -- 2588
	local nextLines = {__TS__SparseArraySpread(____array_52)} -- 2585
	return { -- 2590
		success = true, -- 2590
		content = joinLines(nextLines) -- 2590
	} -- 2590
end -- 2549
local MainDecisionAgent = __TS__Class() -- 2593
MainDecisionAgent.name = "MainDecisionAgent" -- 2593
__TS__ClassExtends(MainDecisionAgent, Node) -- 2593
function MainDecisionAgent.prototype.prep(self, shared) -- 2594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2594
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2594
			return ____awaiter_resolve(nil, {shared = shared}) -- 2594
		end -- 2594
		__TS__Await(maybeCompressHistory(shared)) -- 2599
		return ____awaiter_resolve(nil, {shared = shared}) -- 2599
	end) -- 2599
end -- 2594
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2604
	if attempt == nil then -- 2604
		attempt = 1 -- 2607
	end -- 2607
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2607
		if shared.stopToken.stopped then -- 2607
			return ____awaiter_resolve( -- 2607
				nil, -- 2607
				{ -- 2611
					success = false, -- 2611
					message = getCancelledReason(shared) -- 2611
				} -- 2611
			) -- 2611
		end -- 2611
		Log( -- 2613
			"Info", -- 2613
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2613
		) -- 2613
		local tools = buildDecisionToolSchema(shared) -- 2614
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2615
		local stepId = shared.step + 1 -- 2616
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2617
		emitLLMContextMetrics( -- 2621
			shared, -- 2621
			stepId, -- 2621
			"decision_tool_calling", -- 2621
			messages, -- 2621
			llmOptions -- 2621
		) -- 2621
		saveStepLLMDebugInput( -- 2622
			shared, -- 2622
			stepId, -- 2622
			"decision_tool_calling", -- 2622
			messages, -- 2622
			llmOptions -- 2622
		) -- 2622
		local lastStreamContent = "" -- 2623
		local lastStreamReasoning = "" -- 2624
		local preExecutedResults = __TS__New(Map) -- 2625
		shared.preExecutedResults = preExecutedResults -- 2626
		local res = __TS__Await(callLLMStreamAggregated( -- 2627
			messages, -- 2628
			llmOptions, -- 2629
			shared.stopToken, -- 2630
			shared.llmConfig, -- 2631
			function(response) -- 2632
				local ____opt_55 = response.choices -- 2632
				local ____opt_53 = ____opt_55 and ____opt_55[1] -- 2632
				local streamMessage = ____opt_53 and ____opt_53.message -- 2633
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2634
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2637
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2637
					return -- 2641
				end -- 2641
				lastStreamContent = nextContent -- 2643
				lastStreamReasoning = nextReasoning -- 2644
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2645
			end, -- 2632
			function(tc) -- 2647
				if shared.stopToken.stopped then -- 2647
					return -- 2648
				end -- 2648
				local action = createPreExecutableActionFromStream(shared, tc) -- 2649
				if not action or preExecutedResults:has(action.toolCallId) then -- 2649
					return -- 2650
				end -- 2650
				local ____canCacheToolResult_result_63 = canCacheToolResult(action.tool) -- 2651
				if ____canCacheToolResult_result_63 then -- 2651
					local ____opt_61 = shared.toolResultCache -- 2651
					____canCacheToolResult_result_63 = ____opt_61 and ____opt_61:has(getToolActionSignature(action)) -- 2651
				end -- 2651
				if ____canCacheToolResult_result_63 then -- 2651
					return -- 2651
				end -- 2651
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2652
				preExecutedResults:set( -- 2653
					action.toolCallId, -- 2653
					{ -- 2653
						signature = getToolActionSignature(action), -- 2654
						promise = startPreExecutedToolAction(shared, action) -- 2655
					} -- 2655
				) -- 2655
			end -- 2647
		)) -- 2647
		if shared.stopToken.stopped then -- 2647
			clearPreExecutedResults(shared) -- 2660
			return ____awaiter_resolve( -- 2660
				nil, -- 2660
				{ -- 2661
					success = false, -- 2661
					message = getCancelledReason(shared) -- 2661
				} -- 2661
			) -- 2661
		end -- 2661
		if not res.success then -- 2661
			saveStepLLMDebugOutput( -- 2664
				shared, -- 2664
				stepId, -- 2664
				"decision_tool_calling", -- 2664
				res.raw or res.message, -- 2664
				{success = false} -- 2664
			) -- 2664
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2665
			clearPreExecutedResults(shared) -- 2666
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2666
		end -- 2666
		saveStepLLMDebugOutput( -- 2669
			shared, -- 2669
			stepId, -- 2669
			"decision_tool_calling", -- 2669
			encodeDebugJSON(res.response), -- 2669
			{success = true} -- 2669
		) -- 2669
		local choice = res.response.choices and res.response.choices[1] -- 2670
		local message = choice and choice.message -- 2671
		local toolCalls = message and message.tool_calls -- 2672
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2673
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2676
		Log( -- 2679
			"Info", -- 2679
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2679
		) -- 2679
		if not toolCalls or #toolCalls == 0 then -- 2679
			if messageContent and messageContent ~= "" then -- 2679
				Log( -- 2682
					"Info", -- 2682
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2682
				) -- 2682
				clearPreExecutedResults(shared) -- 2683
				return ____awaiter_resolve(nil, { -- 2683
					success = true, -- 2685
					tool = "finish", -- 2686
					params = {}, -- 2687
					reason = messageContent, -- 2688
					reasoningContent = reasoningContent, -- 2689
					directSummary = messageContent -- 2690
				}) -- 2690
			end -- 2690
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2693
			clearPreExecutedResults(shared) -- 2694
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2694
		end -- 2694
		local decisions = {} -- 2701
		do -- 2701
			local i = 0 -- 2702
			while i < #toolCalls do -- 2702
				local toolCall = toolCalls[i + 1] -- 2703
				local fn = toolCall and toolCall["function"] -- 2704
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2704
					Log( -- 2706
						"Error", -- 2706
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2706
					) -- 2706
					clearPreExecutedResults(shared) -- 2707
					return ____awaiter_resolve( -- 2707
						nil, -- 2707
						{ -- 2708
							success = false, -- 2709
							message = "missing function name for tool call " .. tostring(i + 1), -- 2710
							raw = messageContent -- 2711
						} -- 2711
					) -- 2711
				end -- 2711
				local functionName = fn.name -- 2714
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2715
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2716
				Log( -- 2719
					"Info", -- 2719
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2719
				) -- 2719
				local decision = parseAndValidateToolCallDecision( -- 2720
					shared, -- 2721
					functionName, -- 2722
					argsText, -- 2723
					toolCallId, -- 2724
					messageContent, -- 2725
					reasoningContent -- 2726
				) -- 2726
				if not decision.success then -- 2726
					Log( -- 2729
						"Error", -- 2729
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2729
					) -- 2729
					clearPreExecutedResults(shared) -- 2730
					return ____awaiter_resolve(nil, decision) -- 2730
				end -- 2730
				decisions[#decisions + 1] = decision -- 2733
				i = i + 1 -- 2702
			end -- 2702
		end -- 2702
		if #decisions == 1 then -- 2702
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2736
			return ____awaiter_resolve(nil, decisions[1]) -- 2736
		end -- 2736
		do -- 2736
			local i = 0 -- 2739
			while i < #decisions do -- 2739
				if decisions[i + 1].tool == "finish" then -- 2739
					clearPreExecutedResults(shared) -- 2741
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2741
				end -- 2741
				i = i + 1 -- 2739
			end -- 2739
		end -- 2739
		Log( -- 2749
			"Info", -- 2749
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2749
				__TS__ArrayMap( -- 2749
					decisions, -- 2749
					function(____, decision) return decision.tool end -- 2749
				), -- 2749
				"," -- 2749
			) -- 2749
		) -- 2749
		return ____awaiter_resolve(nil, { -- 2749
			success = true, -- 2751
			kind = "batch", -- 2752
			decisions = decisions, -- 2753
			content = messageContent, -- 2754
			reasoningContent = reasoningContent -- 2755
		}) -- 2755
	end) -- 2755
end -- 2604
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2759
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2759
		Log( -- 2764
			"Info", -- 2764
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2764
		) -- 2764
		local lastError = initialError -- 2765
		local candidateRaw = "" -- 2766
		do -- 2766
			local attempt = 0 -- 2767
			while attempt < shared.llmMaxTry do -- 2767
				do -- 2767
					Log( -- 2768
						"Info", -- 2768
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2768
					) -- 2768
					local messages = buildXmlRepairMessages( -- 2769
						shared, -- 2770
						originalRaw, -- 2771
						candidateRaw, -- 2772
						lastError, -- 2773
						attempt + 1 -- 2774
					) -- 2774
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2776
					if shared.stopToken.stopped then -- 2776
						return ____awaiter_resolve( -- 2776
							nil, -- 2776
							{ -- 2778
								success = false, -- 2778
								message = getCancelledReason(shared) -- 2778
							} -- 2778
						) -- 2778
					end -- 2778
					if not llmRes.success then -- 2778
						lastError = llmRes.message -- 2781
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2782
						goto __continue438 -- 2783
					end -- 2783
					candidateRaw = llmRes.text -- 2785
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2786
					if decision.success then -- 2786
						decision.reasoningContent = llmRes.reasoningContent -- 2788
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2789
						return ____awaiter_resolve(nil, decision) -- 2789
					end -- 2789
					lastError = decision.message -- 2792
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2793
				end -- 2793
				::__continue438:: -- 2793
				attempt = attempt + 1 -- 2767
			end -- 2767
		end -- 2767
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2795
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2795
	end) -- 2795
end -- 2759
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2803
	if attempt == nil then -- 2803
		attempt = 1 -- 2806
	end -- 2806
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2806
		local messages = buildDecisionMessages( -- 2809
			shared, -- 2810
			lastError, -- 2811
			attempt, -- 2812
			lastRaw, -- 2813
			"xml" -- 2814
		) -- 2814
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2816
		if shared.stopToken.stopped then -- 2816
			return ____awaiter_resolve( -- 2816
				nil, -- 2816
				{ -- 2818
					success = false, -- 2818
					message = getCancelledReason(shared) -- 2818
				} -- 2818
			) -- 2818
		end -- 2818
		if not llmRes.success then -- 2818
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2818
		end -- 2818
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2827
		if decision.success then -- 2827
			decision.reasoningContent = llmRes.reasoningContent -- 2829
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2829
				return ____awaiter_resolve( -- 2829
					nil, -- 2829
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2831
				) -- 2831
			end -- 2831
			return ____awaiter_resolve(nil, decision) -- 2831
		end -- 2831
		return ____awaiter_resolve( -- 2831
			nil, -- 2831
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2839
		) -- 2839
	end) -- 2839
end -- 2803
function MainDecisionAgent.prototype.exec(self, input) -- 2842
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2842
		local shared = input.shared -- 2843
		if shared.stopToken.stopped then -- 2843
			return ____awaiter_resolve( -- 2843
				nil, -- 2843
				{ -- 2845
					success = false, -- 2845
					message = getCancelledReason(shared) -- 2845
				} -- 2845
			) -- 2845
		end -- 2845
		if shared.step >= shared.maxSteps then -- 2845
			Log( -- 2848
				"Warn", -- 2848
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2848
			) -- 2848
			return ____awaiter_resolve( -- 2848
				nil, -- 2848
				{ -- 2849
					success = false, -- 2849
					message = getMaxStepsReachedReason(shared) -- 2849
				} -- 2849
			) -- 2849
		end -- 2849
		if shared.decisionMode == "tool_calling" then -- 2849
			Log( -- 2853
				"Info", -- 2853
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2853
			) -- 2853
			local lastError = "tool calling validation failed" -- 2854
			local lastRaw = "" -- 2855
			local shouldFallbackToXml = false -- 2856
			do -- 2856
				local attempt = 0 -- 2857
				while attempt < shared.llmMaxTry do -- 2857
					Log( -- 2858
						"Info", -- 2858
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2858
					) -- 2858
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2859
					if shared.stopToken.stopped then -- 2859
						return ____awaiter_resolve( -- 2859
							nil, -- 2859
							{ -- 2866
								success = false, -- 2866
								message = getCancelledReason(shared) -- 2866
							} -- 2866
						) -- 2866
					end -- 2866
					if decision.success then -- 2866
						return ____awaiter_resolve(nil, decision) -- 2866
					end -- 2866
					lastError = decision.message -- 2871
					lastRaw = decision.raw or "" -- 2872
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2873
					if lastError == "missing tool call" then -- 2873
						shouldFallbackToXml = true -- 2875
						break -- 2876
					end -- 2876
					attempt = attempt + 1 -- 2857
				end -- 2857
			end -- 2857
			if shouldFallbackToXml then -- 2857
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2880
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2881
				do -- 2881
					local attempt = 0 -- 2882
					while attempt < shared.llmMaxTry do -- 2882
						Log( -- 2883
							"Info", -- 2883
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2883
						) -- 2883
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2884
						if shared.stopToken.stopped then -- 2884
							return ____awaiter_resolve( -- 2884
								nil, -- 2884
								{ -- 2891
									success = false, -- 2891
									message = getCancelledReason(shared) -- 2891
								} -- 2891
							) -- 2891
						end -- 2891
						if decision.success then -- 2891
							return ____awaiter_resolve(nil, decision) -- 2891
						end -- 2891
						lastError = decision.message -- 2896
						lastRaw = decision.raw or "" -- 2897
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2898
						attempt = attempt + 1 -- 2882
					end -- 2882
				end -- 2882
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2900
				return ____awaiter_resolve( -- 2900
					nil, -- 2900
					{ -- 2901
						success = false, -- 2901
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2901
					} -- 2901
				) -- 2901
			end -- 2901
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2903
			return ____awaiter_resolve( -- 2903
				nil, -- 2903
				{ -- 2904
					success = false, -- 2904
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2904
				} -- 2904
			) -- 2904
		end -- 2904
		local lastError = "xml validation failed" -- 2907
		local lastRaw = "" -- 2908
		do -- 2908
			local attempt = 0 -- 2909
			while attempt < shared.llmMaxTry do -- 2909
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2910
				if shared.stopToken.stopped then -- 2910
					return ____awaiter_resolve( -- 2910
						nil, -- 2910
						{ -- 2919
							success = false, -- 2919
							message = getCancelledReason(shared) -- 2919
						} -- 2919
					) -- 2919
				end -- 2919
				if decision.success then -- 2919
					return ____awaiter_resolve(nil, decision) -- 2919
				end -- 2919
				lastError = decision.message -- 2924
				lastRaw = decision.raw or "" -- 2925
				attempt = attempt + 1 -- 2909
			end -- 2909
		end -- 2909
		return ____awaiter_resolve( -- 2909
			nil, -- 2909
			{ -- 2927
				success = false, -- 2927
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2927
			} -- 2927
		) -- 2927
	end) -- 2927
end -- 2842
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2930
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2930
		local result = execRes -- 2931
		if not result.success then -- 2931
			if shared.stopToken.stopped then -- 2931
				shared.error = getCancelledReason(shared) -- 2934
				shared.done = true -- 2935
				return ____awaiter_resolve(nil, "done") -- 2935
			end -- 2935
			shared.error = result.message -- 2938
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2939
			shared.done = true -- 2940
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2941
			persistHistoryState(shared) -- 2945
			return ____awaiter_resolve(nil, "done") -- 2945
		end -- 2945
		if isDecisionBatchSuccess(result) then -- 2945
			local startStep = shared.step -- 2949
			local actions = {} -- 2950
			do -- 2950
				local i = 0 -- 2951
				while i < #result.decisions do -- 2951
					local decision = result.decisions[i + 1] -- 2952
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2953
					local step = startStep + i + 1 -- 2954
					local ____temp_64 -- 2955
					if i == 0 then -- 2955
						____temp_64 = decision.reason -- 2955
					else -- 2955
						____temp_64 = "" -- 2955
					end -- 2955
					local actionReason = ____temp_64 -- 2955
					local ____temp_65 -- 2956
					if i == 0 then -- 2956
						____temp_65 = decision.reasoningContent -- 2956
					else -- 2956
						____temp_65 = nil -- 2956
					end -- 2956
					local actionReasoningContent = ____temp_65 -- 2956
					emitAgentEvent(shared, { -- 2957
						type = "decision_made", -- 2958
						sessionId = shared.sessionId, -- 2959
						taskId = shared.taskId, -- 2960
						step = step, -- 2961
						tool = decision.tool, -- 2962
						reason = actionReason, -- 2963
						reasoningContent = actionReasoningContent, -- 2964
						params = decision.params -- 2965
					}) -- 2965
					local action = { -- 2967
						step = step, -- 2968
						toolCallId = toolCallId, -- 2969
						tool = decision.tool, -- 2970
						reason = actionReason or "", -- 2971
						reasoningContent = actionReasoningContent, -- 2972
						params = decision.params, -- 2973
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2974
					} -- 2974
					local ____shared_history_66 = shared.history -- 2974
					____shared_history_66[#____shared_history_66 + 1] = action -- 2976
					actions[#actions + 1] = action -- 2977
					i = i + 1 -- 2951
				end -- 2951
			end -- 2951
			shared.step = startStep + #actions -- 2979
			shared.pendingToolActions = actions -- 2980
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2981
			persistHistoryState(shared) -- 2987
			return ____awaiter_resolve(nil, "batch_tools") -- 2987
		end -- 2987
		if result.directSummary and result.directSummary ~= "" then -- 2987
			shared.response = result.directSummary -- 2991
			shared.done = true -- 2992
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2993
			persistHistoryState(shared) -- 2998
			return ____awaiter_resolve(nil, "done") -- 2998
		end -- 2998
		if result.tool == "finish" then -- 2998
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3002
			shared.response = finalMessage -- 3003
			shared.done = true -- 3004
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3005
			persistHistoryState(shared) -- 3010
			return ____awaiter_resolve(nil, "done") -- 3010
		end -- 3010
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3013
		shared.step = shared.step + 1 -- 3014
		local step = shared.step -- 3015
		emitAgentEvent(shared, { -- 3016
			type = "decision_made", -- 3017
			sessionId = shared.sessionId, -- 3018
			taskId = shared.taskId, -- 3019
			step = step, -- 3020
			tool = result.tool, -- 3021
			reason = result.reason, -- 3022
			reasoningContent = result.reasoningContent, -- 3023
			params = result.params -- 3024
		}) -- 3024
		local ____shared_history_67 = shared.history -- 3024
		____shared_history_67[#____shared_history_67 + 1] = { -- 3026
			step = step, -- 3027
			toolCallId = toolCallId, -- 3028
			tool = result.tool, -- 3029
			reason = result.reason or "", -- 3030
			reasoningContent = result.reasoningContent, -- 3031
			params = result.params, -- 3032
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3033
		} -- 3033
		local action = shared.history[#shared.history] -- 3035
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3036
		if canPreExecuteTool(action.tool) then -- 3036
			shared.pendingToolActions = {action} -- 3038
			persistHistoryState(shared) -- 3039
			return ____awaiter_resolve(nil, "batch_tools") -- 3039
		end -- 3039
		clearPreExecutedResults(shared) -- 3042
		persistHistoryState(shared) -- 3043
		return ____awaiter_resolve(nil, result.tool) -- 3043
	end) -- 3043
end -- 2930
local ReadFileAction = __TS__Class() -- 3048
ReadFileAction.name = "ReadFileAction" -- 3048
__TS__ClassExtends(ReadFileAction, Node) -- 3048
function ReadFileAction.prototype.prep(self, shared) -- 3049
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3049
		local last = shared.history[#shared.history] -- 3050
		if not last then -- 3050
			error( -- 3051
				__TS__New(Error, "no history"), -- 3051
				0 -- 3051
			) -- 3051
		end -- 3051
		emitAgentStartEvent(shared, last) -- 3052
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3053
		if __TS__StringTrim(path) == "" then -- 3053
			error( -- 3056
				__TS__New(Error, "missing path"), -- 3056
				0 -- 3056
			) -- 3056
		end -- 3056
		local ____path_70 = path -- 3058
		local ____shared_workingDir_71 = shared.workingDir -- 3060
		local ____temp_72 = shared.useChineseResponse and "zh" or "en" -- 3061
		local ____last_params_startLine_68 = last.params.startLine -- 3062
		if ____last_params_startLine_68 == nil then -- 3062
			____last_params_startLine_68 = 1 -- 3062
		end -- 3062
		local ____TS__Number_result_73 = __TS__Number(____last_params_startLine_68) -- 3062
		local ____last_params_endLine_69 = last.params.endLine -- 3063
		if ____last_params_endLine_69 == nil then -- 3063
			____last_params_endLine_69 = READ_FILE_DEFAULT_LIMIT -- 3063
		end -- 3063
		return ____awaiter_resolve( -- 3063
			nil, -- 3063
			{ -- 3057
				path = ____path_70, -- 3058
				tool = "read_file", -- 3059
				workDir = ____shared_workingDir_71, -- 3060
				docLanguage = ____temp_72, -- 3061
				startLine = ____TS__Number_result_73, -- 3062
				endLine = __TS__Number(____last_params_endLine_69) -- 3063
			} -- 3063
		) -- 3063
	end) -- 3063
end -- 3049
function ReadFileAction.prototype.exec(self, input) -- 3067
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3067
		return ____awaiter_resolve( -- 3067
			nil, -- 3067
			Tools.readFile( -- 3068
				input.workDir, -- 3069
				input.path, -- 3070
				__TS__Number(input.startLine or 1), -- 3071
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3072
				input.docLanguage -- 3073
			) -- 3073
		) -- 3073
	end) -- 3073
end -- 3067
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3077
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3077
		local result = execRes -- 3078
		local last = shared.history[#shared.history] -- 3079
		if last ~= nil then -- 3079
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3081
			appendToolResultMessage(shared, last) -- 3082
			emitAgentFinishEvent(shared, last) -- 3083
		end -- 3083
		persistHistoryState(shared) -- 3085
		__TS__Await(maybeCompressHistory(shared)) -- 3086
		persistHistoryState(shared) -- 3087
		return ____awaiter_resolve(nil, "main") -- 3087
	end) -- 3087
end -- 3077
local SearchFilesAction = __TS__Class() -- 3092
SearchFilesAction.name = "SearchFilesAction" -- 3092
__TS__ClassExtends(SearchFilesAction, Node) -- 3092
function SearchFilesAction.prototype.prep(self, shared) -- 3093
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3093
		local last = shared.history[#shared.history] -- 3094
		if not last then -- 3094
			error( -- 3095
				__TS__New(Error, "no history"), -- 3095
				0 -- 3095
			) -- 3095
		end -- 3095
		emitAgentStartEvent(shared, last) -- 3096
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3096
	end) -- 3096
end -- 3093
function SearchFilesAction.prototype.exec(self, input) -- 3100
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3100
		local params = input.params -- 3101
		local ____Tools_searchFiles_87 = Tools.searchFiles -- 3102
		local ____input_workDir_80 = input.workDir -- 3103
		local ____temp_81 = params.path or "" -- 3104
		local ____temp_82 = params.pattern or "" -- 3105
		local ____params_globs_83 = params.globs -- 3106
		local ____params_useRegex_84 = params.useRegex -- 3107
		local ____params_caseSensitive_85 = params.caseSensitive -- 3108
		local ____math_max_76 = math.max -- 3111
		local ____math_floor_75 = math.floor -- 3111
		local ____params_limit_74 = params.limit -- 3111
		if ____params_limit_74 == nil then -- 3111
			____params_limit_74 = SEARCH_FILES_LIMIT_DEFAULT -- 3111
		end -- 3111
		local ____math_max_76_result_86 = ____math_max_76( -- 3111
			1, -- 3111
			____math_floor_75(__TS__Number(____params_limit_74)) -- 3111
		) -- 3111
		local ____math_max_79 = math.max -- 3112
		local ____math_floor_78 = math.floor -- 3112
		local ____params_offset_77 = params.offset -- 3112
		if ____params_offset_77 == nil then -- 3112
			____params_offset_77 = 0 -- 3112
		end -- 3112
		local result = __TS__Await(____Tools_searchFiles_87({ -- 3102
			workDir = ____input_workDir_80, -- 3103
			path = ____temp_81, -- 3104
			pattern = ____temp_82, -- 3105
			globs = ____params_globs_83, -- 3106
			useRegex = ____params_useRegex_84, -- 3107
			caseSensitive = ____params_caseSensitive_85, -- 3108
			includeContent = true, -- 3109
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3110
			limit = ____math_max_76_result_86, -- 3111
			offset = ____math_max_79( -- 3112
				0, -- 3112
				____math_floor_78(__TS__Number(____params_offset_77)) -- 3112
			), -- 3112
			groupByFile = params.groupByFile == true -- 3113
		})) -- 3113
		return ____awaiter_resolve(nil, result) -- 3113
	end) -- 3113
end -- 3100
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3118
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
local SearchDoraAPIAction = __TS__Class() -- 3133
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3133
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3133
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3134
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3134
		local last = shared.history[#shared.history] -- 3135
		if not last then -- 3135
			error( -- 3136
				__TS__New(Error, "no history"), -- 3136
				0 -- 3136
			) -- 3136
		end -- 3136
		emitAgentStartEvent(shared, last) -- 3137
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3137
	end) -- 3137
end -- 3134
function SearchDoraAPIAction.prototype.exec(self, input) -- 3141
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3141
		local params = input.params -- 3142
		local ____Tools_searchDoraAPI_95 = Tools.searchDoraAPI -- 3143
		local ____temp_91 = params.pattern or "" -- 3144
		local ____temp_92 = params.docSource or "api" -- 3145
		local ____temp_93 = input.useChineseResponse and "zh" or "en" -- 3146
		local ____temp_94 = params.programmingLanguage or "ts" -- 3147
		local ____math_min_90 = math.min -- 3148
		local ____math_max_89 = math.max -- 3148
		local ____params_limit_88 = params.limit -- 3148
		if ____params_limit_88 == nil then -- 3148
			____params_limit_88 = 8 -- 3148
		end -- 3148
		local result = __TS__Await(____Tools_searchDoraAPI_95({ -- 3143
			pattern = ____temp_91, -- 3144
			docSource = ____temp_92, -- 3145
			docLanguage = ____temp_93, -- 3146
			programmingLanguage = ____temp_94, -- 3147
			limit = ____math_min_90( -- 3148
				SEARCH_DORA_API_LIMIT_MAX, -- 3148
				____math_max_89( -- 3148
					1, -- 3148
					__TS__Number(____params_limit_88) -- 3148
				) -- 3148
			), -- 3148
			useRegex = params.useRegex, -- 3149
			caseSensitive = false, -- 3150
			includeContent = true, -- 3151
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3152
		})) -- 3152
		return ____awaiter_resolve(nil, result) -- 3152
	end) -- 3152
end -- 3141
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3157
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3157
		local last = shared.history[#shared.history] -- 3158
		if last ~= nil then -- 3158
			local result = execRes -- 3160
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3161
			appendToolResultMessage(shared, last) -- 3162
			emitAgentFinishEvent(shared, last) -- 3163
		end -- 3163
		persistHistoryState(shared) -- 3165
		__TS__Await(maybeCompressHistory(shared)) -- 3166
		persistHistoryState(shared) -- 3167
		return ____awaiter_resolve(nil, "main") -- 3167
	end) -- 3167
end -- 3157
local ListFilesAction = __TS__Class() -- 3172
ListFilesAction.name = "ListFilesAction" -- 3172
__TS__ClassExtends(ListFilesAction, Node) -- 3172
function ListFilesAction.prototype.prep(self, shared) -- 3173
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3173
		local last = shared.history[#shared.history] -- 3174
		if not last then -- 3174
			error( -- 3175
				__TS__New(Error, "no history"), -- 3175
				0 -- 3175
			) -- 3175
		end -- 3175
		emitAgentStartEvent(shared, last) -- 3176
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3176
	end) -- 3176
end -- 3173
function ListFilesAction.prototype.exec(self, input) -- 3180
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3180
		local params = input.params -- 3181
		local ____Tools_listFiles_102 = Tools.listFiles -- 3182
		local ____input_workDir_99 = input.workDir -- 3183
		local ____temp_100 = params.path or "" -- 3184
		local ____params_globs_101 = params.globs -- 3185
		local ____math_max_98 = math.max -- 3186
		local ____math_floor_97 = math.floor -- 3186
		local ____params_maxEntries_96 = params.maxEntries -- 3186
		if ____params_maxEntries_96 == nil then -- 3186
			____params_maxEntries_96 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3186
		end -- 3186
		local result = ____Tools_listFiles_102({ -- 3182
			workDir = ____input_workDir_99, -- 3183
			path = ____temp_100, -- 3184
			globs = ____params_globs_101, -- 3185
			maxEntries = ____math_max_98( -- 3186
				1, -- 3186
				____math_floor_97(__TS__Number(____params_maxEntries_96)) -- 3186
			) -- 3186
		}) -- 3186
		return ____awaiter_resolve(nil, result) -- 3186
	end) -- 3186
end -- 3180
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3191
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3191
		local last = shared.history[#shared.history] -- 3192
		if last ~= nil then -- 3192
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3194
			appendToolResultMessage(shared, last) -- 3195
			emitAgentFinishEvent(shared, last) -- 3196
		end -- 3196
		persistHistoryState(shared) -- 3198
		__TS__Await(maybeCompressHistory(shared)) -- 3199
		persistHistoryState(shared) -- 3200
		return ____awaiter_resolve(nil, "main") -- 3200
	end) -- 3200
end -- 3191
local DeleteFileAction = __TS__Class() -- 3205
DeleteFileAction.name = "DeleteFileAction" -- 3205
__TS__ClassExtends(DeleteFileAction, Node) -- 3205
function DeleteFileAction.prototype.prep(self, shared) -- 3206
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3206
		local last = shared.history[#shared.history] -- 3207
		if not last then -- 3207
			error( -- 3208
				__TS__New(Error, "no history"), -- 3208
				0 -- 3208
			) -- 3208
		end -- 3208
		emitAgentStartEvent(shared, last) -- 3209
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3210
		if __TS__StringTrim(targetFile) == "" then -- 3210
			error( -- 3213
				__TS__New(Error, "missing target_file"), -- 3213
				0 -- 3213
			) -- 3213
		end -- 3213
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3213
	end) -- 3213
end -- 3206
function DeleteFileAction.prototype.exec(self, input) -- 3217
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3217
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3218
		if not result.success then -- 3218
			return ____awaiter_resolve(nil, result) -- 3218
		end -- 3218
		return ____awaiter_resolve(nil, { -- 3218
			success = true, -- 3226
			changed = true, -- 3227
			mode = "delete", -- 3228
			checkpointId = result.checkpointId, -- 3229
			checkpointSeq = result.checkpointSeq, -- 3230
			files = {{path = input.targetFile, op = "delete"}} -- 3231
		}) -- 3231
	end) -- 3231
end -- 3217
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3235
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3235
		local last = shared.history[#shared.history] -- 3236
		if last ~= nil then -- 3236
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3238
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3239
			appendToolResultMessage(shared, last) -- 3240
			emitAgentFinishEvent(shared, last) -- 3241
			local result = last.result -- 3242
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3242
				emitAgentEvent(shared, { -- 3247
					type = "checkpoint_created", -- 3248
					sessionId = shared.sessionId, -- 3249
					taskId = shared.taskId, -- 3250
					step = last.step, -- 3251
					tool = "delete_file", -- 3252
					checkpointId = result.checkpointId, -- 3253
					checkpointSeq = result.checkpointSeq, -- 3254
					files = result.files -- 3255
				}) -- 3255
			end -- 3255
		end -- 3255
		persistHistoryState(shared) -- 3259
		__TS__Await(maybeCompressHistory(shared)) -- 3260
		persistHistoryState(shared) -- 3261
		return ____awaiter_resolve(nil, "main") -- 3261
	end) -- 3261
end -- 3235
local BuildAction = __TS__Class() -- 3266
BuildAction.name = "BuildAction" -- 3266
__TS__ClassExtends(BuildAction, Node) -- 3266
function BuildAction.prototype.prep(self, shared) -- 3267
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3267
		local last = shared.history[#shared.history] -- 3268
		if not last then -- 3268
			error( -- 3269
				__TS__New(Error, "no history"), -- 3269
				0 -- 3269
			) -- 3269
		end -- 3269
		emitAgentStartEvent(shared, last) -- 3270
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3270
	end) -- 3270
end -- 3267
function BuildAction.prototype.exec(self, input) -- 3274
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3274
		local params = input.params -- 3275
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3276
		return ____awaiter_resolve(nil, result) -- 3276
	end) -- 3276
end -- 3274
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3283
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3283
		local last = shared.history[#shared.history] -- 3284
		if last ~= nil then -- 3284
			last.result = sanitizeBuildResultForHistory(execRes) -- 3286
			appendToolResultMessage(shared, last) -- 3287
			emitAgentFinishEvent(shared, last) -- 3288
		end -- 3288
		persistHistoryState(shared) -- 3290
		__TS__Await(maybeCompressHistory(shared)) -- 3291
		persistHistoryState(shared) -- 3292
		return ____awaiter_resolve(nil, "main") -- 3292
	end) -- 3292
end -- 3283
local SpawnSubAgentAction = __TS__Class() -- 3297
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3297
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3297
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3298
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3298
		local last = shared.history[#shared.history] -- 3307
		if not last then -- 3307
			error( -- 3308
				__TS__New(Error, "no history"), -- 3308
				0 -- 3308
			) -- 3308
		end -- 3308
		emitAgentStartEvent(shared, last) -- 3309
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3310
			last.params.filesHint, -- 3311
			function(____, item) return type(item) == "string" end -- 3311
		) or nil -- 3311
		return ____awaiter_resolve( -- 3311
			nil, -- 3311
			{ -- 3313
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3314
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3315
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3316
				filesHint = filesHint, -- 3317
				sessionId = shared.sessionId, -- 3318
				projectRoot = shared.workingDir, -- 3319
				spawnSubAgent = shared.spawnSubAgent -- 3320
			} -- 3320
		) -- 3320
	end) -- 3320
end -- 3298
function SpawnSubAgentAction.prototype.exec(self, input) -- 3324
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3324
		if not input.spawnSubAgent then -- 3324
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3324
		end -- 3324
		if input.sessionId == nil or input.sessionId <= 0 then -- 3324
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3324
		end -- 3324
		local ____Log_108 = Log -- 3339
		local ____temp_105 = #input.title -- 3339
		local ____temp_106 = #input.prompt -- 3339
		local ____temp_107 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3339
		local ____opt_103 = input.filesHint -- 3339
		____Log_108( -- 3339
			"Info", -- 3339
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_105)) .. " prompt_len=") .. tostring(____temp_106)) .. " expected_len=") .. tostring(____temp_107)) .. " files_hint_count=") .. tostring(____opt_103 and #____opt_103 or 0) -- 3339
		) -- 3339
		local result = __TS__Await(input.spawnSubAgent({ -- 3340
			parentSessionId = input.sessionId, -- 3341
			projectRoot = input.projectRoot, -- 3342
			title = input.title, -- 3343
			prompt = input.prompt, -- 3344
			expectedOutput = input.expectedOutput, -- 3345
			filesHint = input.filesHint -- 3346
		})) -- 3346
		if not result.success then -- 3346
			return ____awaiter_resolve(nil, result) -- 3346
		end -- 3346
		return ____awaiter_resolve(nil, { -- 3346
			success = true, -- 3352
			sessionId = result.sessionId, -- 3353
			taskId = result.taskId, -- 3354
			title = result.title, -- 3355
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3356
		}) -- 3356
	end) -- 3356
end -- 3324
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3360
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3360
		local last = shared.history[#shared.history] -- 3361
		if last ~= nil then -- 3361
			last.result = execRes -- 3363
			appendToolResultMessage(shared, last) -- 3364
			emitAgentFinishEvent(shared, last) -- 3365
		end -- 3365
		persistHistoryState(shared) -- 3367
		__TS__Await(maybeCompressHistory(shared)) -- 3368
		persistHistoryState(shared) -- 3369
		return ____awaiter_resolve(nil, "main") -- 3369
	end) -- 3369
end -- 3360
local ListSubAgentsAction = __TS__Class() -- 3374
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3374
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3374
function ListSubAgentsAction.prototype.prep(self, shared) -- 3375
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3375
		local last = shared.history[#shared.history] -- 3384
		if not last then -- 3384
			error( -- 3385
				__TS__New(Error, "no history"), -- 3385
				0 -- 3385
			) -- 3385
		end -- 3385
		emitAgentStartEvent(shared, last) -- 3386
		return ____awaiter_resolve( -- 3386
			nil, -- 3386
			{ -- 3387
				sessionId = shared.sessionId, -- 3388
				projectRoot = shared.workingDir, -- 3389
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3390
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3391
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3392
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3393
				listSubAgents = shared.listSubAgents -- 3394
			} -- 3394
		) -- 3394
	end) -- 3394
end -- 3375
function ListSubAgentsAction.prototype.exec(self, input) -- 3398
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3398
		if not input.listSubAgents then -- 3398
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3398
		end -- 3398
		if input.sessionId == nil or input.sessionId <= 0 then -- 3398
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3398
		end -- 3398
		local result = __TS__Await(input.listSubAgents({ -- 3413
			sessionId = input.sessionId, -- 3414
			projectRoot = input.projectRoot, -- 3415
			status = input.status, -- 3416
			limit = input.limit, -- 3417
			offset = input.offset, -- 3418
			query = input.query -- 3419
		})) -- 3419
		return ____awaiter_resolve(nil, result) -- 3419
	end) -- 3419
end -- 3398
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3424
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3424
		local last = shared.history[#shared.history] -- 3425
		if last ~= nil then -- 3425
			last.result = execRes -- 3427
			appendToolResultMessage(shared, last) -- 3428
			emitAgentFinishEvent(shared, last) -- 3429
		end -- 3429
		persistHistoryState(shared) -- 3431
		__TS__Await(maybeCompressHistory(shared)) -- 3432
		persistHistoryState(shared) -- 3433
		return ____awaiter_resolve(nil, "main") -- 3433
	end) -- 3433
end -- 3424
EditFileAction = __TS__Class() -- 3438
EditFileAction.name = "EditFileAction" -- 3438
__TS__ClassExtends(EditFileAction, Node) -- 3438
function EditFileAction.prototype.prep(self, shared) -- 3439
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3439
		local last = shared.history[#shared.history] -- 3440
		if not last then -- 3440
			error( -- 3441
				__TS__New(Error, "no history"), -- 3441
				0 -- 3441
			) -- 3441
		end -- 3441
		emitAgentStartEvent(shared, last) -- 3442
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3443
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3446
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3447
		if __TS__StringTrim(path) == "" then -- 3447
			error( -- 3448
				__TS__New(Error, "missing path"), -- 3448
				0 -- 3448
			) -- 3448
		end -- 3448
		return ____awaiter_resolve(nil, { -- 3448
			path = path, -- 3449
			oldStr = oldStr, -- 3449
			newStr = newStr, -- 3449
			taskId = shared.taskId, -- 3449
			workDir = shared.workingDir -- 3449
		}) -- 3449
	end) -- 3449
end -- 3439
function EditFileAction.prototype.exec(self, input) -- 3452
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3452
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3453
		if not readRes.success then -- 3453
			if input.oldStr ~= "" then -- 3453
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3453
			end -- 3453
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3458
			if not createRes.success then -- 3458
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3458
			end -- 3458
			return ____awaiter_resolve(nil, { -- 3458
				success = true, -- 3466
				changed = true, -- 3467
				mode = "create", -- 3468
				checkpointId = createRes.checkpointId, -- 3469
				checkpointSeq = createRes.checkpointSeq, -- 3470
				files = {{path = input.path, op = "create"}} -- 3471
			}) -- 3471
		end -- 3471
		if input.oldStr == "" then -- 3471
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3475
			if not overwriteRes.success then -- 3475
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3475
			end -- 3475
			return ____awaiter_resolve(nil, { -- 3475
				success = true, -- 3483
				changed = true, -- 3484
				mode = "overwrite", -- 3485
				checkpointId = overwriteRes.checkpointId, -- 3486
				checkpointSeq = overwriteRes.checkpointSeq, -- 3487
				files = {{path = input.path, op = "write"}} -- 3488
			}) -- 3488
		end -- 3488
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3493
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3494
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3495
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3498
		if occurrences == 0 then -- 3498
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3500
			if not indentTolerant.success then -- 3500
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3500
			end -- 3500
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3504
			if not applyRes.success then -- 3504
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3504
			end -- 3504
			return ____awaiter_resolve(nil, { -- 3504
				success = true, -- 3512
				changed = true, -- 3513
				mode = "replace_indent_tolerant", -- 3514
				checkpointId = applyRes.checkpointId, -- 3515
				checkpointSeq = applyRes.checkpointSeq, -- 3516
				files = {{path = input.path, op = "write"}} -- 3517
			}) -- 3517
		end -- 3517
		if occurrences > 1 then -- 3517
			return ____awaiter_resolve( -- 3517
				nil, -- 3517
				{ -- 3521
					success = false, -- 3521
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3521
				} -- 3521
			) -- 3521
		end -- 3521
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3525
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3526
		if not applyRes.success then -- 3526
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3526
		end -- 3526
		return ____awaiter_resolve(nil, { -- 3526
			success = true, -- 3534
			changed = true, -- 3535
			mode = "replace", -- 3536
			checkpointId = applyRes.checkpointId, -- 3537
			checkpointSeq = applyRes.checkpointSeq, -- 3538
			files = {{path = input.path, op = "write"}} -- 3539
		}) -- 3539
	end) -- 3539
end -- 3452
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3543
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3543
		local last = shared.history[#shared.history] -- 3544
		if last ~= nil then -- 3544
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3546
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3547
			appendToolResultMessage(shared, last) -- 3548
			emitAgentFinishEvent(shared, last) -- 3549
			local result = last.result -- 3550
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3550
				emitAgentEvent(shared, { -- 3555
					type = "checkpoint_created", -- 3556
					sessionId = shared.sessionId, -- 3557
					taskId = shared.taskId, -- 3558
					step = last.step, -- 3559
					tool = last.tool, -- 3560
					checkpointId = result.checkpointId, -- 3561
					checkpointSeq = result.checkpointSeq, -- 3562
					files = result.files -- 3563
				}) -- 3563
			end -- 3563
		end -- 3563
		persistHistoryState(shared) -- 3567
		__TS__Await(maybeCompressHistory(shared)) -- 3568
		persistHistoryState(shared) -- 3569
		return ____awaiter_resolve(nil, "main") -- 3569
	end) -- 3569
end -- 3543
local function emitCheckpointEventForAction(shared, action) -- 3574
	local result = action.result -- 3575
	if not result then -- 3575
		return -- 3576
	end -- 3576
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3576
		emitAgentEvent(shared, { -- 3581
			type = "checkpoint_created", -- 3582
			sessionId = shared.sessionId, -- 3583
			taskId = shared.taskId, -- 3584
			step = action.step, -- 3585
			tool = action.tool, -- 3586
			checkpointId = result.checkpointId, -- 3587
			checkpointSeq = result.checkpointSeq, -- 3588
			files = result.files -- 3589
		}) -- 3589
	end -- 3589
end -- 3574
local function canRunBatchActionInParallel(self, action) -- 3894
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3895
end -- 3894
local function partitionToolCalls(actions) -- 3907
	local batches = {} -- 3908
	do -- 3908
		local i = 0 -- 3909
		while i < #actions do -- 3909
			local action = actions[i + 1] -- 3910
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3911
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3912
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3912
				local ____lastBatch_actions_143 = lastBatch.actions -- 3912
				____lastBatch_actions_143[#____lastBatch_actions_143 + 1] = action -- 3914
			else -- 3914
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3916
			end -- 3916
			i = i + 1 -- 3909
		end -- 3909
	end -- 3909
	return batches -- 3919
end -- 3907
local BatchToolAction = __TS__Class() -- 3922
BatchToolAction.name = "BatchToolAction" -- 3922
__TS__ClassExtends(BatchToolAction, Node) -- 3922
function BatchToolAction.prototype.prep(self, shared) -- 3923
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3923
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3923
	end) -- 3923
end -- 3923
function BatchToolAction.prototype.exec(self, input) -- 3927
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3927
		local shared = input.shared -- 3928
		local preExecuted = shared.preExecutedResults -- 3929
		local batches = partitionToolCalls(input.actions) -- 3930
		local parallelBatchCount = #__TS__ArrayFilter( -- 3931
			batches, -- 3931
			function(____, b) return b.isConcurrencySafe end -- 3931
		) -- 3931
		local serialBatchCount = #__TS__ArrayFilter( -- 3932
			batches, -- 3932
			function(____, b) return not b.isConcurrencySafe end -- 3932
		) -- 3932
		Log( -- 3933
			"Info", -- 3933
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3933
		) -- 3933
		do -- 3933
			local batchIdx = 0 -- 3935
			while batchIdx < #batches do -- 3935
				do -- 3935
					local batch = batches[batchIdx + 1] -- 3936
					if shared.stopToken.stopped then -- 3936
						for ____, action in ipairs(batch.actions) do -- 3938
							if not action.result then -- 3938
								action.result = { -- 3940
									success = false, -- 3940
									message = getCancelledReason(shared) -- 3940
								} -- 3940
							end -- 3940
						end -- 3940
						goto __continue610 -- 3943
					end -- 3943
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3943
						local preExecCount = #__TS__ArrayFilter( -- 3947
							batch.actions, -- 3947
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3947
						) -- 3947
						Log( -- 3948
							"Info", -- 3948
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3948
						) -- 3948
						do -- 3948
							local i = 0 -- 3949
							while i < #batch.actions do -- 3949
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3950
								i = i + 1 -- 3949
							end -- 3949
						end -- 3949
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3952
							batch.actions, -- 3952
							function(____, action) -- 3952
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3952
									if shared.stopToken.stopped then -- 3952
										action.result = { -- 3954
											success = false, -- 3954
											message = getCancelledReason(shared) -- 3954
										} -- 3954
										return ____awaiter_resolve(nil, action) -- 3954
									end -- 3954
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3957
									local ____try = __TS__AsyncAwaiter(function() -- 3957
										local result = __TS__Await(executeToolActionWithCache(shared, action)) -- 3959
										action.result = sanitizeToolActionResultForHistory(action, result) -- 3960
									end) -- 3960
									__TS__Await(____try.catch( -- 3958
										____try, -- 3958
										function(____, err) -- 3958
											local message = tostring(err) -- 3962
											Log("Error", (((("[CodingAgent] batch tool failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 3963
											action.result = {success = false, message = message} -- 3964
										end -- 3964
									)) -- 3964
									return ____awaiter_resolve(nil, action) -- 3964
								end) -- 3964
							end -- 3952
						))) -- 3952
						do -- 3952
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
								local result = __TS__Await(executeToolActionWithCache(shared, action)) -- 3982
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
				::__continue610:: -- 3979
				batchIdx = batchIdx + 1 -- 3935
			end -- 3935
		end -- 3935
		persistHistoryState(shared) -- 3995
		return ____awaiter_resolve(nil, input.actions) -- 3995
	end) -- 3995
end -- 3927
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
			toolResultCache = __TS__New(Map), -- 4134
			messages = persistedSession.messages, -- 4135
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4136
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4137
			memory = {compressor = compressor}, -- 4139
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4143
			spawnSubAgent = options.spawnSubAgent, -- 4148
			listSubAgents = options.listSubAgents -- 4149
		} -- 4149
		local ____try = __TS__AsyncAwaiter(function() -- 4149
			emitAgentEvent(shared, { -- 4153
				type = "task_started", -- 4154
				sessionId = shared.sessionId, -- 4155
				taskId = shared.taskId, -- 4156
				prompt = shared.userQuery, -- 4157
				workDir = shared.workingDir, -- 4158
				maxSteps = shared.maxSteps -- 4159
			}) -- 4159
			if shared.stopToken.stopped then -- 4159
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4162
				return ____awaiter_resolve( -- 4162
					nil, -- 4162
					emitAgentTaskFinishEvent( -- 4163
						shared, -- 4163
						false, -- 4163
						getCancelledReason(shared) -- 4163
					) -- 4163
				) -- 4163
			end -- 4163
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4165
			local promptCommand = getPromptCommand(shared.userQuery) -- 4166
			if promptCommand == "clear" then -- 4166
				return ____awaiter_resolve( -- 4166
					nil, -- 4166
					clearSessionHistory(shared) -- 4168
				) -- 4168
			end -- 4168
			if promptCommand == "compact" then -- 4168
				if shared.role == "sub" then -- 4168
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4172
					return ____awaiter_resolve( -- 4172
						nil, -- 4172
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4173
					) -- 4173
				end -- 4173
				return ____awaiter_resolve( -- 4173
					nil, -- 4173
					__TS__Await(compactAllHistory(shared)) -- 4181
				) -- 4181
			end -- 4181
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4183
			persistHistoryState(shared) -- 4187
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4188
			__TS__Await(flow:run(shared)) -- 4189
			if shared.stopToken.stopped then -- 4189
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4191
				return ____awaiter_resolve( -- 4191
					nil, -- 4191
					emitAgentTaskFinishEvent( -- 4192
						shared, -- 4192
						false, -- 4192
						getCancelledReason(shared) -- 4192
					) -- 4192
				) -- 4192
			end -- 4192
			if shared.error then -- 4192
				return ____awaiter_resolve( -- 4192
					nil, -- 4192
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4195
				) -- 4195
			end -- 4195
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4198
			return ____awaiter_resolve( -- 4198
				nil, -- 4198
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4199
			) -- 4199
		end) -- 4199
		__TS__Await(____try.catch( -- 4152
			____try, -- 4152
			function(____, e) -- 4152
				return ____awaiter_resolve( -- 4152
					nil, -- 4152
					finalizeAgentFailure( -- 4202
						shared, -- 4202
						tostring(e) -- 4202
					) -- 4202
				) -- 4202
			end -- 4202
		)) -- 4202
	end) -- 4202
end -- 4082
function ____exports.runCodingAgent(options, callback) -- 4206
	local ____self_146 = runCodingAgentAsync(options) -- 4206
	____self_146["then"]( -- 4206
		____self_146, -- 4206
		function(____, result) return callback(result) end -- 4207
	) -- 4207
end -- 4206
return ____exports -- 4206