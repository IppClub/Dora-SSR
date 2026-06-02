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
	local spawnTool = "\n\n10. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n11. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1278
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
function getFinishMessage(params, fallback) -- 1662
	if fallback == nil then -- 1662
		fallback = "" -- 1662
	end -- 1662
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1662
		return __TS__StringTrim(params.message) -- 1664
	end -- 1664
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1664
		return __TS__StringTrim(params.response) -- 1667
	end -- 1667
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1667
		return __TS__StringTrim(params.summary) -- 1670
	end -- 1670
	return __TS__StringTrim(fallback) -- 1672
end -- 1672
function persistHistoryState(shared) -- 1675
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1676
end -- 1676
function getActiveConversationMessages(shared) -- 1683
	local activeMessages = {} -- 1684
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1684
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1691
	end -- 1691
	do -- 1691
		local i = shared.lastConsolidatedIndex -- 1695
		while i < #shared.messages do -- 1695
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1696
			i = i + 1 -- 1695
		end -- 1695
	end -- 1695
	return activeMessages -- 1698
end -- 1698
function getActiveRealMessageCount(shared) -- 1701
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1702
end -- 1702
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1705
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1710
	local previousActiveStart = shared.lastConsolidatedIndex -- 1711
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1712
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1713
	if type(carryMessageIndex) == "number" then -- 1713
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1713
		else -- 1713
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1721
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1724
		end -- 1724
	else -- 1724
		shared.carryMessageIndex = nil -- 1729
	end -- 1729
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1729
		shared.carryMessageIndex = nil -- 1739
	end -- 1739
end -- 1739
function getDecisionPath(params) -- 1997
	if type(params.path) == "string" then -- 1997
		return __TS__StringTrim(params.path) -- 1998
	end -- 1998
	if type(params.target_file) == "string" then -- 1998
		return __TS__StringTrim(params.target_file) -- 1999
	end -- 1999
	return "" -- 2000
end -- 2000
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2003
	local num = __TS__Number(value) -- 2004
	if not __TS__NumberIsFinite(num) then -- 2004
		num = fallback -- 2005
	end -- 2005
	num = math.floor(num) -- 2006
	if num < minValue then -- 2006
		num = minValue -- 2007
	end -- 2007
	if maxValue ~= nil and num > maxValue then -- 2007
		num = maxValue -- 2008
	end -- 2008
	return num -- 2009
end -- 2009
function parseReadLineParam(value, fallback, paramName) -- 2012
	local num = __TS__Number(value) -- 2017
	if not __TS__NumberIsFinite(num) then -- 2017
		num = fallback -- 2018
	end -- 2018
	num = math.floor(num) -- 2019
	if num == 0 then -- 2019
		return {success = false, message = paramName .. " cannot be 0"} -- 2021
	end -- 2021
	return {success = true, value = num} -- 2023
end -- 2023
function validateDecision(tool, params) -- 2026
	if tool == "finish" then -- 2026
		local message = getFinishMessage(params) -- 2031
		if message == "" then -- 2031
			return {success = false, message = "finish requires params.message"} -- 2032
		end -- 2032
		params.message = message -- 2033
		return {success = true, params = params} -- 2034
	end -- 2034
	if tool == "read_file" then -- 2034
		local path = getDecisionPath(params) -- 2038
		if path == "" then -- 2038
			return {success = false, message = "read_file requires path"} -- 2039
		end -- 2039
		params.path = path -- 2040
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2041
		if not startLineRes.success then -- 2041
			return startLineRes -- 2042
		end -- 2042
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 2043
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2044
		if not endLineRes.success then -- 2044
			return endLineRes -- 2045
		end -- 2045
		params.startLine = startLineRes.value -- 2046
		params.endLine = endLineRes.value -- 2047
		return {success = true, params = params} -- 2048
	end -- 2048
	if tool == "edit_file" then -- 2048
		local path = getDecisionPath(params) -- 2052
		if path == "" then -- 2052
			return {success = false, message = "edit_file requires path"} -- 2053
		end -- 2053
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2054
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2055
		params.path = path -- 2056
		params.old_str = oldStr -- 2057
		params.new_str = newStr -- 2058
		return {success = true, params = params} -- 2059
	end -- 2059
	if tool == "delete_file" then -- 2059
		local targetFile = getDecisionPath(params) -- 2063
		if targetFile == "" then -- 2063
			return {success = false, message = "delete_file requires target_file"} -- 2064
		end -- 2064
		params.target_file = targetFile -- 2065
		return {success = true, params = params} -- 2066
	end -- 2066
	if tool == "grep_files" then -- 2066
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2070
		if pattern == "" then -- 2070
			return {success = false, message = "grep_files requires pattern"} -- 2071
		end -- 2071
		params.pattern = pattern -- 2072
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2073
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2074
		return {success = true, params = params} -- 2075
	end -- 2075
	if tool == "search_dora_api" then -- 2075
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2079
		if pattern == "" then -- 2079
			return {success = false, message = "search_dora_api requires pattern"} -- 2080
		end -- 2080
		params.pattern = pattern -- 2081
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2082
		return {success = true, params = params} -- 2083
	end -- 2083
	if tool == "glob_files" then -- 2083
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2087
		return {success = true, params = params} -- 2088
	end -- 2088
	if tool == "build" then -- 2088
		local path = getDecisionPath(params) -- 2092
		if path ~= "" then -- 2092
			params.path = path -- 2094
		end -- 2094
		return {success = true, params = params} -- 2096
	end -- 2096
	if tool == "list_sub_agents" then -- 2096
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2100
		if status ~= "" then -- 2100
			params.status = status -- 2102
		end -- 2102
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2104
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2105
		if type(params.query) == "string" then -- 2105
			params.query = __TS__StringTrim(params.query) -- 2107
		end -- 2107
		return {success = true, params = params} -- 2109
	end -- 2109
	if tool == "spawn_sub_agent" then -- 2109
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2113
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2114
		if prompt == "" then -- 2114
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2115
		end -- 2115
		if title == "" then -- 2115
			return {success = false, message = "spawn_sub_agent requires title"} -- 2116
		end -- 2116
		params.prompt = prompt -- 2117
		params.title = title -- 2118
		if type(params.expectedOutput) == "string" then -- 2118
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2120
		end -- 2120
		if isArray(params.filesHint) then -- 2120
			params.filesHint = __TS__ArrayMap( -- 2123
				__TS__ArrayFilter( -- 2123
					params.filesHint, -- 2123
					function(____, item) return type(item) == "string" end -- 2124
				), -- 2124
				function(____, item) return sanitizeUTF8(item) end -- 2125
			) -- 2125
		end -- 2125
		return {success = true, params = params} -- 2127
	end -- 2127
	return {success = true, params = params} -- 2130
end -- 2130
function getAllowedToolsForRole(role) -- 2156
	return role == "main" and ({ -- 2157
		"read_file", -- 2158
		"edit_file", -- 2158
		"delete_file", -- 2158
		"grep_files", -- 2158
		"search_dora_api", -- 2158
		"glob_files", -- 2158
		"build", -- 2158
		"list_sub_agents", -- 2158
		"spawn_sub_agent", -- 2158
		"finish" -- 2158
	}) or ({ -- 2158
		"read_file", -- 2159
		"edit_file", -- 2159
		"delete_file", -- 2159
		"grep_files", -- 2159
		"search_dora_api", -- 2159
		"glob_files", -- 2159
		"build", -- 2159
		"finish" -- 2159
	}) -- 2159
end -- 2159
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2265
	if includeToolDefinitions == nil then -- 2265
		includeToolDefinitions = false -- 2265
	end -- 2265
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2266
	local sections = { -- 2269
		shared.promptPack.agentIdentityPrompt, -- 2270
		rolePrompt, -- 2271
		getReplyLanguageDirective(shared) -- 2272
	} -- 2272
	if shared.decisionMode == "tool_calling" then -- 2272
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2275
	end -- 2275
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2277
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2278
	if memoryContext ~= "" then -- 2278
		sections[#sections + 1] = memoryContext -- 2280
	end -- 2280
	if includeToolDefinitions then -- 2280
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2283
		if shared.decisionMode == "xml" then -- 2283
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2285
		end -- 2285
	end -- 2285
	local skillsSection = buildSkillsSection(shared) -- 2289
	if skillsSection ~= "" then -- 2289
		sections[#sections + 1] = skillsSection -- 2291
	end -- 2291
	return table.concat(sections, "\n\n") -- 2293
end -- 2293
function buildSkillsSection(shared) -- 2296
	local ____opt_42 = shared.skills -- 2296
	if not (____opt_42 and ____opt_42.loader) then -- 2296
		return "" -- 2298
	end -- 2298
	return shared.skills.loader:buildSkillsPromptSection() -- 2300
end -- 2300
function buildXmlDecisionInstruction(shared, feedback) -- 2421
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2422
end -- 2422
function executeToolAction(shared, action) -- 3760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3760
		if shared.stopToken.stopped then -- 3760
			return ____awaiter_resolve( -- 3760
				nil, -- 3760
				{ -- 3762
					success = false, -- 3762
					message = getCancelledReason(shared) -- 3762
				} -- 3762
			) -- 3762
		end -- 3762
		local params = action.params -- 3764
		if action.tool == "read_file" then -- 3764
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3766
			if __TS__StringTrim(path) == "" then -- 3766
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3766
			end -- 3766
			local ____Tools_readFile_106 = Tools.readFile -- 3770
			local ____shared_workingDir_104 = shared.workingDir -- 3771
			local ____params_startLine_102 = params.startLine -- 3773
			if ____params_startLine_102 == nil then -- 3773
				____params_startLine_102 = 1 -- 3773
			end -- 3773
			local ____TS__Number_result_105 = __TS__Number(____params_startLine_102) -- 3773
			local ____params_endLine_103 = params.endLine -- 3774
			if ____params_endLine_103 == nil then -- 3774
				____params_endLine_103 = READ_FILE_DEFAULT_LIMIT -- 3774
			end -- 3774
			return ____awaiter_resolve( -- 3774
				nil, -- 3774
				____Tools_readFile_106( -- 3770
					____shared_workingDir_104, -- 3771
					path, -- 3772
					____TS__Number_result_105, -- 3773
					__TS__Number(____params_endLine_103), -- 3774
					shared.useChineseResponse and "zh" or "en" -- 3775
				) -- 3775
			) -- 3775
		end -- 3775
		if action.tool == "grep_files" then -- 3775
			local ____Tools_searchFiles_120 = Tools.searchFiles -- 3779
			local ____shared_workingDir_113 = shared.workingDir -- 3780
			local ____temp_114 = params.path or "" -- 3781
			local ____temp_115 = params.pattern or "" -- 3782
			local ____params_globs_116 = params.globs -- 3783
			local ____params_useRegex_117 = params.useRegex -- 3784
			local ____params_caseSensitive_118 = params.caseSensitive -- 3785
			local ____math_max_109 = math.max -- 3788
			local ____math_floor_108 = math.floor -- 3788
			local ____params_limit_107 = params.limit -- 3788
			if ____params_limit_107 == nil then -- 3788
				____params_limit_107 = SEARCH_FILES_LIMIT_DEFAULT -- 3788
			end -- 3788
			local ____math_max_109_result_119 = ____math_max_109( -- 3788
				1, -- 3788
				____math_floor_108(__TS__Number(____params_limit_107)) -- 3788
			) -- 3788
			local ____math_max_112 = math.max -- 3789
			local ____math_floor_111 = math.floor -- 3789
			local ____params_offset_110 = params.offset -- 3789
			if ____params_offset_110 == nil then -- 3789
				____params_offset_110 = 0 -- 3789
			end -- 3789
			local result = __TS__Await(____Tools_searchFiles_120({ -- 3779
				workDir = ____shared_workingDir_113, -- 3780
				path = ____temp_114, -- 3781
				pattern = ____temp_115, -- 3782
				globs = ____params_globs_116, -- 3783
				useRegex = ____params_useRegex_117, -- 3784
				caseSensitive = ____params_caseSensitive_118, -- 3785
				includeContent = true, -- 3786
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3787
				limit = ____math_max_109_result_119, -- 3788
				offset = ____math_max_112( -- 3789
					0, -- 3789
					____math_floor_111(__TS__Number(____params_offset_110)) -- 3789
				), -- 3789
				groupByFile = params.groupByFile == true -- 3790
			})) -- 3790
			return ____awaiter_resolve(nil, result) -- 3790
		end -- 3790
		if action.tool == "search_dora_api" then -- 3790
			local ____Tools_searchDoraAPI_128 = Tools.searchDoraAPI -- 3795
			local ____temp_124 = params.pattern or "" -- 3796
			local ____temp_125 = params.docSource or "api" -- 3797
			local ____temp_126 = shared.useChineseResponse and "zh" or "en" -- 3798
			local ____temp_127 = params.programmingLanguage or "ts" -- 3799
			local ____math_min_123 = math.min -- 3800
			local ____math_max_122 = math.max -- 3800
			local ____params_limit_121 = params.limit -- 3800
			if ____params_limit_121 == nil then -- 3800
				____params_limit_121 = 8 -- 3800
			end -- 3800
			local result = __TS__Await(____Tools_searchDoraAPI_128({ -- 3795
				pattern = ____temp_124, -- 3796
				docSource = ____temp_125, -- 3797
				docLanguage = ____temp_126, -- 3798
				programmingLanguage = ____temp_127, -- 3799
				limit = ____math_min_123( -- 3800
					SEARCH_DORA_API_LIMIT_MAX, -- 3800
					____math_max_122( -- 3800
						1, -- 3800
						__TS__Number(____params_limit_121) -- 3800
					) -- 3800
				), -- 3800
				useRegex = params.useRegex, -- 3801
				caseSensitive = false, -- 3802
				includeContent = true, -- 3803
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3804
			})) -- 3804
			return ____awaiter_resolve(nil, result) -- 3804
		end -- 3804
		if action.tool == "glob_files" then -- 3804
			local ____Tools_listFiles_135 = Tools.listFiles -- 3809
			local ____shared_workingDir_132 = shared.workingDir -- 3810
			local ____temp_133 = params.path or "" -- 3811
			local ____params_globs_134 = params.globs -- 3812
			local ____math_max_131 = math.max -- 3813
			local ____math_floor_130 = math.floor -- 3813
			local ____params_maxEntries_129 = params.maxEntries -- 3813
			if ____params_maxEntries_129 == nil then -- 3813
				____params_maxEntries_129 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3813
			end -- 3813
			local result = ____Tools_listFiles_135({ -- 3809
				workDir = ____shared_workingDir_132, -- 3810
				path = ____temp_133, -- 3811
				globs = ____params_globs_134, -- 3812
				maxEntries = ____math_max_131( -- 3813
					1, -- 3813
					____math_floor_130(__TS__Number(____params_maxEntries_129)) -- 3813
				) -- 3813
			}) -- 3813
			return ____awaiter_resolve(nil, result) -- 3813
		end -- 3813
		if action.tool == "delete_file" then -- 3813
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3818
			if __TS__StringTrim(targetFile) == "" then -- 3818
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3818
			end -- 3818
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3822
			if not result.success then -- 3822
				return ____awaiter_resolve(nil, result) -- 3822
			end -- 3822
			return ____awaiter_resolve(nil, { -- 3822
				success = true, -- 3830
				changed = true, -- 3831
				mode = "delete", -- 3832
				checkpointId = result.checkpointId, -- 3833
				checkpointSeq = result.checkpointSeq, -- 3834
				files = {{path = targetFile, op = "delete"}} -- 3835
			}) -- 3835
		end -- 3835
		if action.tool == "build" then -- 3835
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3839
			return ____awaiter_resolve(nil, result) -- 3839
		end -- 3839
		if action.tool == "spawn_sub_agent" then -- 3839
			if not shared.spawnSubAgent then -- 3839
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3839
			end -- 3839
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3839
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3839
			end -- 3839
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3852
				params.filesHint, -- 3853
				function(____, item) return type(item) == "string" end -- 3853
			) or nil -- 3853
			local result = __TS__Await(shared.spawnSubAgent({ -- 3855
				parentSessionId = shared.sessionId, -- 3856
				projectRoot = shared.workingDir, -- 3857
				title = type(params.title) == "string" and params.title or "Sub", -- 3858
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3859
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3860
				filesHint = filesHint -- 3861
			})) -- 3861
			if not result.success then -- 3861
				return ____awaiter_resolve(nil, result) -- 3861
			end -- 3861
			return ____awaiter_resolve(nil, { -- 3861
				success = true, -- 3867
				sessionId = result.sessionId, -- 3868
				taskId = result.taskId, -- 3869
				title = result.title, -- 3870
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3871
			}) -- 3871
		end -- 3871
		if action.tool == "list_sub_agents" then -- 3871
			if not shared.listSubAgents then -- 3871
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3871
			end -- 3871
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3871
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3871
			end -- 3871
			local result = __TS__Await(shared.listSubAgents({ -- 3881
				sessionId = shared.sessionId, -- 3882
				projectRoot = shared.workingDir, -- 3883
				status = type(params.status) == "string" and params.status or nil, -- 3884
				limit = type(params.limit) == "number" and params.limit or nil, -- 3885
				offset = type(params.offset) == "number" and params.offset or nil, -- 3886
				query = type(params.query) == "string" and params.query or nil -- 3887
			})) -- 3887
			return ____awaiter_resolve(nil, result) -- 3887
		end -- 3887
		if action.tool == "edit_file" then -- 3887
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3892
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3895
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3896
			if __TS__StringTrim(path) == "" then -- 3896
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3896
			end -- 3896
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3898
			return ____awaiter_resolve( -- 3898
				nil, -- 3898
				actionNode:exec({ -- 3899
					path = path, -- 3900
					oldStr = oldStr, -- 3901
					newStr = newStr, -- 3902
					taskId = shared.taskId, -- 3903
					workDir = shared.workingDir -- 3904
				}) -- 3904
			) -- 3904
		end -- 3904
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3904
	end) -- 3904
end -- 3904
function sanitizeToolActionResultForHistory(action, result) -- 3910
	if action.tool == "read_file" then -- 3910
		return sanitizeReadResultForHistory(action.tool, result) -- 3912
	end -- 3912
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3912
		return sanitizeSearchResultForHistory(action.tool, result) -- 3915
	end -- 3915
	if action.tool == "glob_files" then -- 3915
		return sanitizeListFilesResultForHistory(result) -- 3918
	end -- 3918
	if action.tool == "build" then -- 3918
		return sanitizeBuildResultForHistory(result) -- 3921
	end -- 3921
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3921
		if result.success ~= true then -- 3921
			return result -- 3924
		end -- 3924
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3924
			return result -- 3925
		end -- 3925
		if isArray(result.fileContext) then -- 3925
			return result -- 3926
		end -- 3926
		local contextLimits = { -- 3928
			fullContentChars = 12000, -- 3929
			previewChars = 4000, -- 3930
			diffChars = 8000, -- 3931
			totalChars = 24000, -- 3932
			maxFiles = 8 -- 3933
		} -- 3933
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3935
			if maxChars <= 0 then -- 3935
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3936
			end -- 3936
			if #sourceText <= maxChars then -- 3936
				return sourceText -- 3937
			end -- 3937
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3938
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3939
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3940
		end -- 3935
		local function countLines(sourceText) -- 3942
			if sourceText == "" then -- 3942
				return 0 -- 3943
			end -- 3943
			return #__TS__StringSplit(sourceText, "\n") -- 3944
		end -- 3942
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3946
			if beforeContent == afterContent then -- 3946
				return "" -- 3947
			end -- 3947
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3948
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3949
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3951
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3951
				firstChangedLine = firstChangedLine + 1 -- 3957
			end -- 3957
			local lastChangedBeforeLine = #beforeLines - 1 -- 3959
			local lastChangedAfterLine = #afterLines - 1 -- 3960
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3960
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3966
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3967
			end -- 3967
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3969
			local previewEndLine = math.max( -- 3970
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3971
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3972
			) -- 3972
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3974
			do -- 3974
				local lineIndex = previewStartLine -- 3975
				while lineIndex <= previewEndLine do -- 3975
					do -- 3975
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3976
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3977
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3978
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3979
						if not beforeChanged and not afterChanged then -- 3979
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3981
							if contextLine ~= nil then -- 3981
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3982
							end -- 3982
							goto __continue632 -- 3983
						end -- 3983
						if beforeChanged and beforeLine ~= nil then -- 3983
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3985
						end -- 3985
						if afterChanged and afterLine ~= nil then -- 3985
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3986
						end -- 3986
					end -- 3986
					::__continue632:: -- 3986
					lineIndex = lineIndex + 1 -- 3975
				end -- 3975
			end -- 3975
			return truncateContextSnippet( -- 3988
				table.concat(unifiedDiffLines, "\n"), -- 3988
				maxChars, -- 3988
				"diff" -- 3988
			) -- 3988
		end -- 3946
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3991
		if not checkpointDiff.success then -- 3991
			return result -- 3992
		end -- 3992
		local remainingContextBudget = contextLimits.totalChars -- 3993
		local fileContextItems = {} -- 3994
		local changedFiles = checkpointDiff.files -- 3995
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3996
		do -- 3996
			local fileIndex = 0 -- 3997
			while fileIndex < maxContextFiles do -- 3997
				if remainingContextBudget <= 0 then -- 3997
					break -- 3998
				end -- 3998
				local changedFile = changedFiles[fileIndex + 1] -- 3999
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4000
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4001
				local contextItem = { -- 4002
					path = changedFile.path, -- 4003
					op = changedFile.op, -- 4004
					checkpointId = result.checkpointId, -- 4005
					checkpointSeq = result.checkpointSeq, -- 4006
					beforeExists = changedFile.beforeExists, -- 4007
					afterExists = changedFile.afterExists, -- 4008
					beforeBytes = #beforeContent, -- 4009
					afterBytes = #afterContent, -- 4010
					diffPreview = "", -- 4011
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4012
					contentTruncated = false, -- 4013
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4014
				} -- 4014
				if changedFile.afterExists then -- 4014
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4014
						contextItem.afterContent = afterContent -- 4018
						remainingContextBudget = remainingContextBudget - #afterContent -- 4019
					else -- 4019
						contextItem.afterContentPreview = truncateContextSnippet( -- 4021
							afterContent, -- 4022
							math.min( -- 4023
								contextLimits.previewChars, -- 4023
								math.max(400, remainingContextBudget) -- 4023
							), -- 4023
							"afterContent" -- 4024
						) -- 4024
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4026
						contextItem.contentTruncated = true -- 4027
					end -- 4027
				end -- 4027
				local diffPreview = buildUnifiedDiffPreview( -- 4030
					changedFile.path, -- 4031
					beforeContent, -- 4032
					afterContent, -- 4033
					math.min( -- 4034
						contextLimits.diffChars, -- 4034
						math.max(400, remainingContextBudget) -- 4034
					) -- 4034
				) -- 4034
				contextItem.diffPreview = diffPreview -- 4036
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4037
				if not changedFile.afterExists and beforeContent ~= "" then -- 4037
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4039
						beforeContent, -- 4040
						math.min( -- 4041
							contextLimits.previewChars, -- 4041
							math.max(400, remainingContextBudget) -- 4041
						), -- 4041
						"beforeContent" -- 4042
					) -- 4042
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4044
					if #beforeContent > contextLimits.previewChars then -- 4044
						contextItem.contentTruncated = true -- 4045
					end -- 4045
				end -- 4045
				fileContextItems[#fileContextItems + 1] = contextItem -- 4047
				fileIndex = fileIndex + 1 -- 3997
			end -- 3997
		end -- 3997
		if #fileContextItems == 0 then -- 3997
			return result -- 4049
		end -- 4049
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4050
	end -- 4050
	return result -- 4057
end -- 4057
function emitAgentTaskFinishEvent(shared, success, message) -- 4224
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 4225
	emitAgentEvent(shared, { -- 4231
		type = "task_finished", -- 4232
		sessionId = shared.sessionId, -- 4233
		taskId = shared.taskId, -- 4234
		success = result.success, -- 4235
		message = result.message, -- 4236
		steps = result.steps -- 4237
	}) -- 4237
	return result -- 4239
end -- 4239
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
local function toJson(value, emptyAsArray) -- 1091
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 1092
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
local function canPreExecuteTool(tool) -- 1327
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1328
end -- 1327
local function clearPreExecutedResults(shared) -- 1331
	shared.preExecutedResults = nil -- 1332
end -- 1331
local function startPreExecutedToolAction(shared, action) -- 1335
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1335
		local ____hasReturned, ____returnValue -- 1335
		local ____try = __TS__AsyncAwaiter(function() -- 1335
			____hasReturned = true -- 1337
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1337
			return -- 1337
		end) -- 1337
		____try = ____try.catch( -- 1337
			____try, -- 1337
			function(____, err) -- 1337
				return __TS__AsyncAwaiter(function() -- 1337
					local message = tostring(err) -- 1339
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1340
					____hasReturned = true -- 1341
					____returnValue = {success = false, message = message} -- 1341
					return -- 1341
				end) -- 1341
			end -- 1341
		) -- 1341
		__TS__Await(____try) -- 1336
		if ____hasReturned then -- 1336
			return ____awaiter_resolve(nil, ____returnValue) -- 1336
		end -- 1336
	end) -- 1336
end -- 1335
local function createPreExecutedToolResult(shared, action) -- 1345
	local cloneParamValue -- 1346
	cloneParamValue = function(value) -- 1346
		if value == nil then -- 1346
			return value -- 1347
		end -- 1347
		if isArray(value) then -- 1347
			return __TS__ArrayMap( -- 1349
				value, -- 1349
				function(____, item) return cloneParamValue(item) end -- 1349
			) -- 1349
		end -- 1349
		if type(value) == "table" then -- 1349
			local clone = {} -- 1352
			for key in pairs(value) do -- 1353
				clone[key] = cloneParamValue(value[key]) -- 1354
			end -- 1354
			return clone -- 1356
		end -- 1356
		return value -- 1358
	end -- 1346
	local params = cloneParamValue(action.params) -- 1360
	local areParamValuesEqual -- 1361
	areParamValuesEqual = function(left, right) -- 1361
		if left == right then -- 1361
			return true -- 1362
		end -- 1362
		if left == nil or right == nil then -- 1362
			return false -- 1363
		end -- 1363
		if isArray(left) or isArray(right) then -- 1363
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1363
				return false -- 1365
			end -- 1365
			do -- 1365
				local i = 0 -- 1366
				while i < #left do -- 1366
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1366
						return false -- 1367
					end -- 1367
					i = i + 1 -- 1366
				end -- 1366
			end -- 1366
			return true -- 1369
		end -- 1369
		if type(left) == "table" and type(right) == "table" then -- 1369
			local leftCount = 0 -- 1372
			for key in pairs(left) do -- 1373
				leftCount = leftCount + 1 -- 1374
				if not areParamValuesEqual(left[key], right[key]) then -- 1374
					return false -- 1379
				end -- 1379
			end -- 1379
			local rightCount = 0 -- 1382
			for key in pairs(right) do -- 1383
				rightCount = rightCount + 1 -- 1384
			end -- 1384
			return leftCount == rightCount -- 1386
		end -- 1386
		return false -- 1388
	end -- 1361
	return { -- 1390
		action = action, -- 1391
		matches = function(self, nextAction) -- 1392
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1393
		end, -- 1392
		promise = startPreExecutedToolAction(shared, action) -- 1395
	} -- 1395
end -- 1345
local function executeToolActionWithPreExecution(shared, action) -- 1399
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1399
		local ____opt_9 = shared.preExecutedResults -- 1399
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1400
		if preResult then -- 1400
			local ____opt_11 = shared.preExecutedResults -- 1400
			if ____opt_11 ~= nil then -- 1400
				____opt_11:delete(action.toolCallId) -- 1402
			end -- 1402
			if preResult:matches(action) then -- 1402
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1404
				return ____awaiter_resolve( -- 1404
					nil, -- 1404
					__TS__Await(preResult.promise) -- 1405
				) -- 1405
			end -- 1405
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1407
		end -- 1407
		return ____awaiter_resolve( -- 1407
			nil, -- 1407
			executeToolAction(shared, action) -- 1409
		) -- 1409
	end) -- 1409
end -- 1399
local function maybeCompressHistory(shared) -- 1412
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1412
		local ____shared_13 = shared -- 1413
		local memory = ____shared_13.memory -- 1413
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1414
		local changed = false -- 1415
		do -- 1415
			local round = 0 -- 1416
			while round < maxRounds do -- 1416
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1417
				local activeMessages = getActiveConversationMessages(shared) -- 1418
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1422
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1422
					if changed then -- 1422
						persistHistoryState(shared) -- 1431
					end -- 1431
					return ____awaiter_resolve(nil) -- 1431
				end -- 1431
				local compressionRound = round + 1 -- 1435
				shared.step = shared.step + 1 -- 1436
				local stepId = shared.step -- 1437
				local pendingMessages = #activeMessages -- 1438
				emitAgentEvent( -- 1439
					shared, -- 1439
					{ -- 1439
						type = "memory_compression_started", -- 1440
						sessionId = shared.sessionId, -- 1441
						taskId = shared.taskId, -- 1442
						step = stepId, -- 1443
						tool = "compress_memory", -- 1444
						reason = getMemoryCompressionStartReason(shared), -- 1445
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1446
					} -- 1446
				) -- 1446
				local result = __TS__Await(memory.compressor:compress( -- 1452
					activeMessages, -- 1453
					shared.llmOptions, -- 1454
					shared.llmMaxTry, -- 1455
					shared.decisionMode, -- 1456
					{ -- 1457
						onInput = function(____, phase, messages, options) -- 1458
							saveStepLLMDebugInput( -- 1459
								shared, -- 1459
								stepId, -- 1459
								phase, -- 1459
								messages, -- 1459
								options -- 1459
							) -- 1459
						end, -- 1458
						onOutput = function(____, phase, text, meta) -- 1461
							saveStepLLMDebugOutput( -- 1462
								shared, -- 1462
								stepId, -- 1462
								phase, -- 1462
								text, -- 1462
								meta -- 1462
							) -- 1462
						end -- 1461
					}, -- 1461
					"default", -- 1465
					systemPrompt, -- 1466
					toolDefinitions -- 1467
				)) -- 1467
				if not (result and result.success and result.compressedCount > 0) then -- 1467
					emitAgentEvent( -- 1470
						shared, -- 1470
						{ -- 1470
							type = "memory_compression_finished", -- 1471
							sessionId = shared.sessionId, -- 1472
							taskId = shared.taskId, -- 1473
							step = stepId, -- 1474
							tool = "compress_memory", -- 1475
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1476
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1480
						} -- 1480
					) -- 1480
					if changed then -- 1480
						persistHistoryState(shared) -- 1488
					end -- 1488
					return ____awaiter_resolve(nil) -- 1488
				end -- 1488
				local effectiveCompressedCount = math.max( -- 1492
					0, -- 1493
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1494
				) -- 1494
				if effectiveCompressedCount <= 0 then -- 1494
					if changed then -- 1494
						persistHistoryState(shared) -- 1498
					end -- 1498
					return ____awaiter_resolve(nil) -- 1498
				end -- 1498
				emitAgentEvent( -- 1502
					shared, -- 1502
					{ -- 1502
						type = "memory_compression_finished", -- 1503
						sessionId = shared.sessionId, -- 1504
						taskId = shared.taskId, -- 1505
						step = stepId, -- 1506
						tool = "compress_memory", -- 1507
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1508
						result = { -- 1509
							success = true, -- 1510
							round = compressionRound, -- 1511
							compressedCount = effectiveCompressedCount, -- 1512
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1513
						} -- 1513
					} -- 1513
				) -- 1513
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1516
				changed = true -- 1517
				Log( -- 1518
					"Info", -- 1518
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1518
				) -- 1518
				round = round + 1 -- 1416
			end -- 1416
		end -- 1416
		if changed then -- 1416
			persistHistoryState(shared) -- 1521
		end -- 1521
	end) -- 1521
end -- 1412
local function compactAllHistory(shared) -- 1525
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1525
		local ____shared_20 = shared -- 1526
		local memory = ____shared_20.memory -- 1526
		local rounds = 0 -- 1527
		local totalCompressed = 0 -- 1528
		while getActiveRealMessageCount(shared) > 0 do -- 1528
			if shared.stopToken.stopped then -- 1528
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1531
				return ____awaiter_resolve( -- 1531
					nil, -- 1531
					emitAgentTaskFinishEvent( -- 1532
						shared, -- 1532
						false, -- 1532
						getCancelledReason(shared) -- 1532
					) -- 1532
				) -- 1532
			end -- 1532
			rounds = rounds + 1 -- 1534
			shared.step = shared.step + 1 -- 1535
			local stepId = shared.step -- 1536
			local activeMessages = getActiveConversationMessages(shared) -- 1537
			local pendingMessages = #activeMessages -- 1538
			emitAgentEvent( -- 1539
				shared, -- 1539
				{ -- 1539
					type = "memory_compression_started", -- 1540
					sessionId = shared.sessionId, -- 1541
					taskId = shared.taskId, -- 1542
					step = stepId, -- 1543
					tool = "compress_memory", -- 1544
					reason = getMemoryCompressionStartReason(shared), -- 1545
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1546
				} -- 1546
			) -- 1546
			local result = __TS__Await(memory.compressor:compress( -- 1553
				activeMessages, -- 1554
				shared.llmOptions, -- 1555
				shared.llmMaxTry, -- 1556
				shared.decisionMode, -- 1557
				{ -- 1558
					onInput = function(____, phase, messages, options) -- 1559
						saveStepLLMDebugInput( -- 1560
							shared, -- 1560
							stepId, -- 1560
							phase, -- 1560
							messages, -- 1560
							options -- 1560
						) -- 1560
					end, -- 1559
					onOutput = function(____, phase, text, meta) -- 1562
						saveStepLLMDebugOutput( -- 1563
							shared, -- 1563
							stepId, -- 1563
							phase, -- 1563
							text, -- 1563
							meta -- 1563
						) -- 1563
					end -- 1562
				}, -- 1562
				"budget_max" -- 1566
			)) -- 1566
			if not (result and result.success and result.compressedCount > 0) then -- 1566
				emitAgentEvent( -- 1569
					shared, -- 1569
					{ -- 1569
						type = "memory_compression_finished", -- 1570
						sessionId = shared.sessionId, -- 1571
						taskId = shared.taskId, -- 1572
						step = stepId, -- 1573
						tool = "compress_memory", -- 1574
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1575
						result = { -- 1579
							success = false, -- 1580
							rounds = rounds, -- 1581
							error = result and result.error or "compression returned no changes", -- 1582
							compressedCount = result and result.compressedCount or 0, -- 1583
							fullCompaction = true -- 1584
						} -- 1584
					} -- 1584
				) -- 1584
				return ____awaiter_resolve( -- 1584
					nil, -- 1584
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1587
				) -- 1587
			end -- 1587
			local effectiveCompressedCount = math.max( -- 1592
				0, -- 1593
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1594
			) -- 1594
			if effectiveCompressedCount <= 0 then -- 1594
				return ____awaiter_resolve( -- 1594
					nil, -- 1594
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1597
				) -- 1597
			end -- 1597
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
						round = rounds, -- 1613
						compressedCount = effectiveCompressedCount, -- 1614
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1615
						fullCompaction = true -- 1616
					} -- 1616
				} -- 1616
			) -- 1616
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1619
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1620
			persistHistoryState(shared) -- 1621
			Log( -- 1622
				"Info", -- 1622
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1622
			) -- 1622
		end -- 1622
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1624
		return ____awaiter_resolve( -- 1624
			nil, -- 1624
			emitAgentTaskFinishEvent( -- 1625
				shared, -- 1626
				true, -- 1627
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1628
			) -- 1628
		) -- 1628
	end) -- 1628
end -- 1525
local function clearSessionHistory(shared) -- 1634
	shared.messages = {} -- 1635
	shared.lastConsolidatedIndex = 0 -- 1636
	shared.carryMessageIndex = nil -- 1637
	persistHistoryState(shared) -- 1638
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1639
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1640
end -- 1634
local function isKnownToolName(name) -- 1649
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1650
end -- 1649
local function appendConversationMessage(shared, message) -- 1743
	local ____shared_messages_29 = shared.messages -- 1743
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1744
		{}, -- 1744
		message, -- 1745
		{ -- 1744
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1746
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1747
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1748
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1749
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1750
		} -- 1750
	) -- 1750
end -- 1743
local function ensureToolCallId(toolCallId) -- 1754
	if toolCallId and toolCallId ~= "" then -- 1754
		return toolCallId -- 1755
	end -- 1755
	return createLocalToolCallId() -- 1756
end -- 1754
local function appendToolResultMessage(shared, action) -- 1759
	appendConversationMessage( -- 1760
		shared, -- 1760
		{ -- 1760
			role = "tool", -- 1761
			tool_call_id = action.toolCallId, -- 1762
			name = action.tool, -- 1763
			content = action.result and toJson(action.result, false) or "" -- 1764
		} -- 1764
	) -- 1764
end -- 1759
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1768
	appendConversationMessage( -- 1774
		shared, -- 1774
		{ -- 1774
			role = "assistant", -- 1775
			content = content or "", -- 1776
			reasoning_content = reasoningContent, -- 1777
			tool_calls = __TS__ArrayMap( -- 1778
				actions, -- 1778
				function(____, action) return { -- 1778
					id = action.toolCallId, -- 1779
					type = "function", -- 1780
					["function"] = { -- 1781
						name = action.tool, -- 1782
						arguments = toJson(action.params, false) -- 1783
					} -- 1783
				} end -- 1783
			) -- 1783
		} -- 1783
	) -- 1783
end -- 1768
local function parseXMLToolCallObjectFromText(text) -- 1789
	local children = parseXMLObjectFromText(text, "tool_call") -- 1790
	if not children.success then -- 1790
		return children -- 1791
	end -- 1791
	local rawObj = children.obj -- 1792
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1793
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1794
	if not params.success then -- 1794
		return {success = false, message = params.message} -- 1798
	end -- 1798
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1800
end -- 1789
local function llm(shared, messages, phase) -- 1820
	if phase == nil then -- 1820
		phase = "decision_xml" -- 1823
	end -- 1823
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1823
		local stepId = shared.step + 1 -- 1825
		emitLLMContextMetrics( -- 1826
			shared, -- 1826
			stepId, -- 1826
			phase, -- 1826
			messages, -- 1826
			shared.llmOptions -- 1826
		) -- 1826
		saveStepLLMDebugInput( -- 1827
			shared, -- 1827
			stepId, -- 1827
			phase, -- 1827
			messages, -- 1827
			shared.llmOptions -- 1827
		) -- 1827
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1828
		if res.success then -- 1828
			local ____opt_32 = res.response.choices -- 1828
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1828
			local message = ____opt_30 and ____opt_30.message -- 1830
			local text = message and message.content -- 1831
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1832
			if text then -- 1832
				saveStepLLMDebugOutput( -- 1836
					shared, -- 1836
					stepId, -- 1836
					phase, -- 1836
					text, -- 1836
					{success = true} -- 1836
				) -- 1836
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1836
			else -- 1836
				saveStepLLMDebugOutput( -- 1839
					shared, -- 1839
					stepId, -- 1839
					phase, -- 1839
					"empty LLM response", -- 1839
					{success = false} -- 1839
				) -- 1839
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1839
			end -- 1839
		else -- 1839
			saveStepLLMDebugOutput( -- 1843
				shared, -- 1843
				stepId, -- 1843
				phase, -- 1843
				res.raw or res.message, -- 1843
				{success = false} -- 1843
			) -- 1843
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1843
		end -- 1843
	end) -- 1843
end -- 1820
local function isDecisionBatchSuccess(result) -- 1867
	return result.kind == "batch" -- 1868
end -- 1867
local function parseDecisionObject(rawObj) -- 1871
	if type(rawObj.tool) ~= "string" then -- 1871
		return {success = false, message = "missing tool"} -- 1872
	end -- 1872
	local tool = rawObj.tool -- 1873
	if not isKnownToolName(tool) then -- 1873
		return {success = false, message = "unknown tool: " .. tool} -- 1875
	end -- 1875
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1877
	if tool ~= "finish" and (not reason or reason == "") then -- 1877
		return {success = false, message = tool .. " requires top-level reason"} -- 1881
	end -- 1881
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1883
	return {success = true, tool = tool, params = params, reason = reason} -- 1884
end -- 1871
local function parseDecisionToolCall(functionName, rawObj) -- 1892
	if not isKnownToolName(functionName) then -- 1892
		return {success = false, message = "unknown tool: " .. functionName} -- 1894
	end -- 1894
	if rawObj == nil then -- 1894
		return {success = true, tool = functionName, params = {}} -- 1897
	end -- 1897
	if not isRecord(rawObj) then -- 1897
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1900
	end -- 1900
	return {success = true, tool = functionName, params = rawObj} -- 1902
end -- 1892
local function parseToolCallArguments(functionName, argsText) -- 1909
	local trimmedArgs = __TS__StringTrim(argsText) -- 1910
	if trimmedArgs == "" then -- 1910
		return {} -- 1912
	end -- 1912
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1914
	if err ~= nil or rawObj == nil then -- 1914
		return { -- 1916
			success = false, -- 1917
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1918
			raw = argsText -- 1919
		} -- 1919
	end -- 1919
	local encodedRaw = safeJsonEncode(rawObj) -- 1922
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1922
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1924
	end -- 1924
	return rawObj -- 1930
end -- 1909
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1933
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1941
	if isRecord(rawArgs) and rawArgs.success == false then -- 1941
		return rawArgs -- 1943
	end -- 1943
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1945
	if not decision.success then -- 1945
		return {success = false, message = decision.message, raw = argsText} -- 1947
	end -- 1947
	local validation = validateDecision(decision.tool, decision.params) -- 1953
	if not validation.success then -- 1953
		return {success = false, message = validation.message, raw = argsText} -- 1955
	end -- 1955
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1955
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1962
	end -- 1962
	decision.params = validation.params -- 1968
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1969
	decision.reason = reason -- 1970
	decision.reasoningContent = reasoningContent -- 1971
	return decision -- 1972
end -- 1933
local function createPreExecutableActionFromStream(shared, toolCall) -- 1975
	local ____opt_38 = toolCall["function"] -- 1975
	local functionName = ____opt_38 and ____opt_38.name -- 1976
	local ____opt_40 = toolCall["function"] -- 1976
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1977
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1978
	if not functionName or not toolCallId then -- 1978
		return nil -- 1979
	end -- 1979
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1980
	if isRecord(rawArgs) and rawArgs.success == false then -- 1980
		return nil -- 1981
	end -- 1981
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1982
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1982
		return nil -- 1983
	end -- 1983
	local validation = validateDecision(decision.tool, decision.params) -- 1984
	if not validation.success then -- 1984
		return nil -- 1985
	end -- 1985
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1985
		return nil -- 1986
	end -- 1986
	return { -- 1987
		step = shared.step + 1, -- 1988
		toolCallId = toolCallId, -- 1989
		tool = decision.tool, -- 1990
		reason = "", -- 1991
		params = validation.params, -- 1992
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1993
	} -- 1993
end -- 1975
local function createFunctionToolSchema(name, description, properties, required) -- 2133
	if required == nil then -- 2133
		required = {} -- 2137
	end -- 2137
	local parameters = {type = "object", properties = properties} -- 2139
	if #required > 0 then -- 2139
		parameters.required = required -- 2144
	end -- 2144
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2146
end -- 2133
local function buildDecisionToolSchema(shared) -- 2162
	local allowed = getAllowedToolsForRole(shared.role) -- 2163
	local tools = { -- 2164
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2165
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2175
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2185
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2193
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2197
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2198
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2199
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2200
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2201
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2202
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2203
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2204
		}, {"pattern"}), -- 2204
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2208
		createFunctionToolSchema( -- 2217
			"search_dora_api", -- 2218
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2218
			{ -- 2220
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2221
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2222
				programmingLanguage = {type = "string", enum = { -- 2223
					"ts", -- 2225
					"tsx", -- 2225
					"lua", -- 2225
					"yue", -- 2225
					"teal", -- 2225
					"tl", -- 2225
					"wa" -- 2225
				}, description = "Preferred language variant to search."}, -- 2225
				limit = { -- 2228
					type = "number", -- 2228
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2228
				}, -- 2228
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2229
			}, -- 2229
			{"pattern"} -- 2231
		), -- 2231
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2233
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2240
			"active_or_recent", -- 2244
			"running", -- 2244
			"done", -- 2244
			"failed", -- 2244
			"all" -- 2244
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2244
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2250
	} -- 2250
	return __TS__ArrayFilter( -- 2262
		tools, -- 2262
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2262
	) -- 2262
end -- 2162
local function sanitizeMessagesForLLMInput(messages) -- 2303
	local sanitized = {} -- 2304
	local droppedAssistantToolCalls = 0 -- 2305
	local droppedToolResults = 0 -- 2306
	do -- 2306
		local i = 0 -- 2307
		while i < #messages do -- 2307
			do -- 2307
				local message = messages[i + 1] -- 2308
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2308
					local requiredIds = {} -- 2310
					do -- 2310
						local j = 0 -- 2311
						while j < #message.tool_calls do -- 2311
							local toolCall = message.tool_calls[j + 1] -- 2312
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2313
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2313
								requiredIds[#requiredIds + 1] = id -- 2315
							end -- 2315
							j = j + 1 -- 2311
						end -- 2311
					end -- 2311
					if #requiredIds == 0 then -- 2311
						sanitized[#sanitized + 1] = message -- 2319
						goto __continue363 -- 2320
					end -- 2320
					local matchedIds = {} -- 2322
					local matchedTools = {} -- 2323
					local j = i + 1 -- 2324
					while j < #messages do -- 2324
						local toolMessage = messages[j + 1] -- 2326
						if toolMessage.role ~= "tool" then -- 2326
							break -- 2327
						end -- 2327
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2328
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2328
							matchedIds[toolCallId] = true -- 2330
							matchedTools[#matchedTools + 1] = toolMessage -- 2331
						else -- 2331
							droppedToolResults = droppedToolResults + 1 -- 2333
						end -- 2333
						j = j + 1 -- 2335
					end -- 2335
					local complete = true -- 2337
					do -- 2337
						local j = 0 -- 2338
						while j < #requiredIds do -- 2338
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2338
								complete = false -- 2340
								break -- 2341
							end -- 2341
							j = j + 1 -- 2338
						end -- 2338
					end -- 2338
					if complete then -- 2338
						__TS__ArrayPush( -- 2345
							sanitized, -- 2345
							message, -- 2345
							table.unpack(matchedTools) -- 2345
						) -- 2345
					else -- 2345
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2347
						droppedToolResults = droppedToolResults + #matchedTools -- 2348
					end -- 2348
					i = j - 1 -- 2350
					goto __continue363 -- 2351
				end -- 2351
				if message.role == "tool" then -- 2351
					droppedToolResults = droppedToolResults + 1 -- 2354
					goto __continue363 -- 2355
				end -- 2355
				sanitized[#sanitized + 1] = message -- 2357
			end -- 2357
			::__continue363:: -- 2357
			i = i + 1 -- 2307
		end -- 2307
	end -- 2307
	return sanitized -- 2359
end -- 2303
local function getUnconsolidatedMessages(shared) -- 2362
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2363
end -- 2362
local function getFinalDecisionTurnPrompt(shared) -- 2366
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2367
end -- 2366
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2372
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2372
		return messages -- 2373
	end -- 2373
	local next = __TS__ArrayMap( -- 2374
		messages, -- 2374
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2374
	) -- 2374
	do -- 2374
		local i = #next - 1 -- 2375
		while i >= 0 do -- 2375
			do -- 2375
				local message = next[i + 1] -- 2376
				if message.role ~= "assistant" and message.role ~= "user" then -- 2376
					goto __continue385 -- 2377
				end -- 2377
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2378
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2379
				return next -- 2382
			end -- 2382
			::__continue385:: -- 2382
			i = i - 1 -- 2375
		end -- 2375
	end -- 2375
	next[#next + 1] = {role = "user", content = prompt} -- 2384
	return next -- 2385
end -- 2372
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2388
	if attempt == nil then -- 2388
		attempt = 1 -- 2391
	end -- 2391
	if decisionMode == nil then -- 2391
		decisionMode = shared.decisionMode -- 2393
	end -- 2393
	local messages = { -- 2395
		{ -- 2396
			role = "system", -- 2396
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2396
		}, -- 2396
		table.unpack(getUnconsolidatedMessages(shared)) -- 2397
	} -- 2397
	if shared.step + 1 >= shared.maxSteps then -- 2397
		messages = appendPromptToLatestDecisionMessage( -- 2400
			messages, -- 2400
			getFinalDecisionTurnPrompt(shared) -- 2400
		) -- 2400
	end -- 2400
	if lastError and lastError ~= "" then -- 2400
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2403
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2403
			retryHeader = retryHeader .. "\nYour previous response spent the token budget on reasoning and ended before any tool call. Do not continue that reasoning. Immediately emit one valid function tool call with compact arguments." -- 2407
		end -- 2407
		messages[#messages + 1] = { -- 2409
			role = "user", -- 2410
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2411
		} -- 2411
	end -- 2411
	return messages -- 2418
end -- 2388
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2425
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2432
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2433
	local repairPrompt = replacePromptVars( -- 2441
		shared.promptPack.xmlDecisionRepairPrompt, -- 2441
		{ -- 2441
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2442
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2443
			CANDIDATE_SECTION = candidateSection, -- 2444
			LAST_ERROR = lastError, -- 2445
			ATTEMPT = tostring(attempt) -- 2446
		} -- 2446
	) -- 2446
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2448
end -- 2425
local function tryParseAndValidateDecision(rawText) -- 2460
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2461
	if not parsed.success then -- 2461
		return {success = false, message = parsed.message, raw = rawText} -- 2463
	end -- 2463
	local decision = parseDecisionObject(parsed.obj) -- 2465
	if not decision.success then -- 2465
		return {success = false, message = decision.message, raw = rawText} -- 2467
	end -- 2467
	local validation = validateDecision(decision.tool, decision.params) -- 2469
	if not validation.success then -- 2469
		return {success = false, message = validation.message, raw = rawText} -- 2471
	end -- 2471
	decision.params = validation.params -- 2473
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2474
	return decision -- 2475
end -- 2460
local function normalizeLineEndings(text) -- 2478
	local res = string.gsub(text, "\r\n", "\n") -- 2479
	res = string.gsub(res, "\r", "\n") -- 2480
	return res -- 2481
end -- 2478
local function countOccurrences(text, searchStr) -- 2484
	if searchStr == "" then -- 2484
		return 0 -- 2485
	end -- 2485
	local count = 0 -- 2486
	local pos = 0 -- 2487
	while true do -- 2487
		local idx = (string.find( -- 2489
			text, -- 2489
			searchStr, -- 2489
			math.max(pos + 1, 1), -- 2489
			true -- 2489
		) or 0) - 1 -- 2489
		if idx < 0 then -- 2489
			break -- 2490
		end -- 2490
		count = count + 1 -- 2491
		pos = idx + #searchStr -- 2492
	end -- 2492
	return count -- 2494
end -- 2484
local function replaceFirst(text, oldStr, newStr) -- 2497
	if oldStr == "" then -- 2497
		return text -- 2498
	end -- 2498
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2499
	if idx < 0 then -- 2499
		return text -- 2500
	end -- 2500
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2501
end -- 2497
local function splitLines(text) -- 2504
	return __TS__StringSplit(text, "\n") -- 2505
end -- 2504
local function getLeadingWhitespace(text) -- 2508
	local i = 0 -- 2509
	while i < #text do -- 2509
		local ch = __TS__StringAccess(text, i) -- 2511
		if ch ~= " " and ch ~= "\t" then -- 2511
			break -- 2512
		end -- 2512
		i = i + 1 -- 2513
	end -- 2513
	return __TS__StringSubstring(text, 0, i) -- 2515
end -- 2508
local function getCommonIndentPrefix(lines) -- 2518
	local common -- 2519
	do -- 2519
		local i = 0 -- 2520
		while i < #lines do -- 2520
			do -- 2520
				local line = lines[i + 1] -- 2521
				if __TS__StringTrim(line) == "" then -- 2521
					goto __continue411 -- 2522
				end -- 2522
				local indent = getLeadingWhitespace(line) -- 2523
				if common == nil then -- 2523
					common = indent -- 2525
					goto __continue411 -- 2526
				end -- 2526
				local j = 0 -- 2528
				local maxLen = math.min(#common, #indent) -- 2529
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2529
					j = j + 1 -- 2531
				end -- 2531
				common = __TS__StringSubstring(common, 0, j) -- 2533
				if common == "" then -- 2533
					break -- 2534
				end -- 2534
			end -- 2534
			::__continue411:: -- 2534
			i = i + 1 -- 2520
		end -- 2520
	end -- 2520
	return common or "" -- 2536
end -- 2518
local function removeIndentPrefix(line, indent) -- 2539
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2539
		return __TS__StringSubstring(line, #indent) -- 2541
	end -- 2541
	local lineIndent = getLeadingWhitespace(line) -- 2543
	local j = 0 -- 2544
	local maxLen = math.min(#lineIndent, #indent) -- 2545
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2545
		j = j + 1 -- 2547
	end -- 2547
	return __TS__StringSubstring(line, j) -- 2549
end -- 2539
local function dedentLines(lines) -- 2552
	local indent = getCommonIndentPrefix(lines) -- 2553
	return { -- 2554
		indent = indent, -- 2555
		lines = __TS__ArrayMap( -- 2556
			lines, -- 2556
			function(____, line) return removeIndentPrefix(line, indent) end -- 2556
		) -- 2556
	} -- 2556
end -- 2552
local function joinLines(lines) -- 2560
	return table.concat(lines, "\n") -- 2561
end -- 2560
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2564
	local function findWhitespaceTolerantReplacement() -- 2569
		local function foldWhitespace(text, withMap) -- 2571
			local parts = {} -- 2572
			local map = {} -- 2573
			local i = 0 -- 2574
			while i < #text do -- 2574
				local ch = __TS__StringAccess(text, i) -- 2576
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2576
					local start = i -- 2578
					while i < #text do -- 2578
						local next = __TS__StringAccess(text, i) -- 2580
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2580
							break -- 2581
						end -- 2581
						i = i + 1 -- 2582
					end -- 2582
					parts[#parts + 1] = " " -- 2584
					if withMap then -- 2584
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2585
					end -- 2585
				else -- 2585
					parts[#parts + 1] = ch -- 2587
					if withMap then -- 2587
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2588
					end -- 2588
					i = i + 1 -- 2589
				end -- 2589
			end -- 2589
			return { -- 2592
				text = table.concat(parts, ""), -- 2592
				map = map -- 2592
			} -- 2592
		end -- 2571
		local foldedContent = foldWhitespace(content, true) -- 2594
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2595
		if foldedOld == "" then -- 2595
			return {success = false, message = "old_str not found in file"} -- 2597
		end -- 2597
		local matches = {} -- 2599
		local pos = 0 -- 2600
		while true do -- 2600
			local idx = (string.find( -- 2602
				foldedContent.text, -- 2602
				foldedOld, -- 2602
				math.max(pos + 1, 1), -- 2602
				true -- 2602
			) or 0) - 1 -- 2602
			if idx < 0 then -- 2602
				break -- 2603
			end -- 2603
			local lastIdx = idx + #foldedOld - 1 -- 2604
			local startMap = foldedContent.map[idx + 1] -- 2605
			local endMap = foldedContent.map[lastIdx + 1] -- 2606
			if startMap ~= nil and endMap ~= nil then -- 2606
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2608
			end -- 2608
			pos = idx + #foldedOld -- 2610
		end -- 2610
		if #matches == 0 then -- 2610
			return {success = false, message = "old_str not found in file"} -- 2613
		end -- 2613
		if #matches > 1 then -- 2613
			return { -- 2616
				success = false, -- 2617
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2618
			} -- 2618
		end -- 2618
		local match = matches[1] -- 2621
		return { -- 2622
			success = true, -- 2623
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2624
		} -- 2624
	end -- 2569
	local contentLines = splitLines(content) -- 2627
	local oldLines = splitLines(oldStr) -- 2628
	if #oldLines == 0 then -- 2628
		return {success = false, message = "old_str not found in file"} -- 2630
	end -- 2630
	local dedentedOld = dedentLines(oldLines) -- 2632
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2633
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2634
	local matches = {} -- 2635
	do -- 2635
		local start = 0 -- 2636
		while start <= #contentLines - #oldLines do -- 2636
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2637
			local dedentedCandidate = dedentLines(candidateLines) -- 2638
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2638
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2640
			end -- 2640
			start = start + 1 -- 2636
		end -- 2636
	end -- 2636
	if #matches == 0 then -- 2636
		return findWhitespaceTolerantReplacement() -- 2648
	end -- 2648
	if #matches > 1 then -- 2648
		return { -- 2651
			success = false, -- 2652
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2653
		} -- 2653
	end -- 2653
	local match = matches[1] -- 2656
	local rebuiltNewLines = __TS__ArrayMap( -- 2657
		dedentedNew.lines, -- 2657
		function(____, line) return line == "" and "" or match.indent .. line end -- 2657
	) -- 2657
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2657
	__TS__SparseArrayPush( -- 2657
		____array_46, -- 2657
		table.unpack(rebuiltNewLines) -- 2660
	) -- 2660
	__TS__SparseArrayPush( -- 2660
		____array_46, -- 2660
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2661
	) -- 2661
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2658
	return { -- 2663
		success = true, -- 2663
		content = joinLines(nextLines) -- 2663
	} -- 2663
end -- 2564
local MainDecisionAgent = __TS__Class() -- 2666
MainDecisionAgent.name = "MainDecisionAgent" -- 2666
__TS__ClassExtends(MainDecisionAgent, Node) -- 2666
function MainDecisionAgent.prototype.prep(self, shared) -- 2667
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2667
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2667
			return ____awaiter_resolve(nil, {shared = shared}) -- 2667
		end -- 2667
		__TS__Await(maybeCompressHistory(shared)) -- 2672
		return ____awaiter_resolve(nil, {shared = shared}) -- 2672
	end) -- 2672
end -- 2667
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2677
	local preExecuted = shared.preExecutedResults -- 2678
	if not preExecuted or preExecuted.size == 0 then -- 2678
		return nil -- 2679
	end -- 2679
	local decisions = {} -- 2680
	preExecuted:forEach(function(____, preResult) -- 2681
		local action = preResult.action -- 2682
		decisions[#decisions + 1] = { -- 2683
			success = true, -- 2684
			tool = action.tool, -- 2685
			params = action.params, -- 2686
			toolCallId = action.toolCallId, -- 2687
			reason = action.reason, -- 2688
			reasoningContent = action.reasoningContent -- 2689
		} -- 2689
	end) -- 2681
	if #decisions == 0 then -- 2681
		return nil -- 2692
	end -- 2692
	Log( -- 2693
		"Warn", -- 2693
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2693
			__TS__ArrayMap( -- 2693
				decisions, -- 2693
				function(____, decision) return decision.tool end -- 2693
			), -- 2693
			"," -- 2693
		) -- 2693
	) -- 2693
	if #decisions == 1 then -- 2693
		return decisions[1] -- 2695
	end -- 2695
	return {success = true, kind = "batch", decisions = decisions} -- 2697
end -- 2677
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2704
	if attempt == nil then -- 2704
		attempt = 1 -- 2707
	end -- 2707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2707
		if shared.stopToken.stopped then -- 2707
			return ____awaiter_resolve( -- 2707
				nil, -- 2707
				{ -- 2711
					success = false, -- 2711
					message = getCancelledReason(shared) -- 2711
				} -- 2711
			) -- 2711
		end -- 2711
		Log( -- 2713
			"Info", -- 2713
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2713
		) -- 2713
		local tools = buildDecisionToolSchema(shared) -- 2714
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2715
		local stepId = shared.step + 1 -- 2716
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2717
		emitLLMContextMetrics( -- 2721
			shared, -- 2721
			stepId, -- 2721
			"decision_tool_calling", -- 2721
			messages, -- 2721
			llmOptions -- 2721
		) -- 2721
		saveStepLLMDebugInput( -- 2722
			shared, -- 2722
			stepId, -- 2722
			"decision_tool_calling", -- 2722
			messages, -- 2722
			llmOptions -- 2722
		) -- 2722
		local lastStreamContent = "" -- 2723
		local lastStreamReasoning = "" -- 2724
		local preExecutedResults = __TS__New(Map) -- 2725
		shared.preExecutedResults = preExecutedResults -- 2726
		local res = __TS__Await(callLLMStreamAggregated( -- 2727
			messages, -- 2728
			llmOptions, -- 2729
			shared.stopToken, -- 2730
			shared.llmConfig, -- 2731
			function(response) -- 2732
				local ____opt_49 = response.choices -- 2732
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2732
				local streamMessage = ____opt_47 and ____opt_47.message -- 2733
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2734
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2737
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2737
					return -- 2741
				end -- 2741
				lastStreamContent = nextContent -- 2743
				lastStreamReasoning = nextReasoning -- 2744
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2745
			end, -- 2732
			function(tc) -- 2747
				if shared.stopToken.stopped then -- 2747
					return -- 2748
				end -- 2748
				local action = createPreExecutableActionFromStream(shared, tc) -- 2749
				if not action or preExecutedResults:has(action.toolCallId) then -- 2749
					return -- 2750
				end -- 2750
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2751
				preExecutedResults:set( -- 2752
					action.toolCallId, -- 2752
					createPreExecutedToolResult(shared, action) -- 2752
				) -- 2752
			end -- 2747
		)) -- 2747
		if shared.stopToken.stopped then -- 2747
			clearPreExecutedResults(shared) -- 2756
			return ____awaiter_resolve( -- 2756
				nil, -- 2756
				{ -- 2757
					success = false, -- 2757
					message = getCancelledReason(shared) -- 2757
				} -- 2757
			) -- 2757
		end -- 2757
		if not res.success then -- 2757
			saveStepLLMDebugOutput( -- 2760
				shared, -- 2760
				stepId, -- 2760
				"decision_tool_calling", -- 2760
				res.raw or res.message, -- 2760
				{success = false} -- 2760
			) -- 2760
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2761
			if (string.find(res.message, "stream incomplete:", nil, true) or 0) - 1 >= 0 then -- 2761
				local ____opt_55 = res.response -- 2761
				local partialChoice = ____opt_55 and ____opt_55.choices and res.response.choices[1] -- 2763
				local partialMessage = partialChoice and partialChoice.message -- 2764
				local partialToolCalls = partialMessage and partialMessage.tool_calls -- 2765
				if partialToolCalls and #partialToolCalls > 0 then -- 2765
					local partialReasoningContent = partialMessage and type(partialMessage.reasoning_content) == "string" and partialMessage.reasoning_content or nil -- 2767
					local partialMessageContent = partialMessage and type(partialMessage.content) == "string" and __TS__StringTrim(partialMessage.content) or nil -- 2770
					local partialDecisions = {} -- 2773
					local partialFailure -- 2774
					do -- 2774
						local i = 0 -- 2775
						while i < #partialToolCalls do -- 2775
							local toolCall = partialToolCalls[i + 1] -- 2776
							local fn = toolCall and toolCall["function"] -- 2777
							if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2777
								partialFailure = { -- 2779
									success = false, -- 2780
									message = "missing function name for partial tool call " .. tostring(i + 1), -- 2781
									raw = partialMessageContent -- 2782
								} -- 2782
								break -- 2784
							end -- 2784
							local decision = parseAndValidateToolCallDecision( -- 2786
								shared, -- 2787
								fn.name, -- 2788
								type(fn.arguments) == "string" and fn.arguments or "", -- 2789
								toolCall and type(toolCall.id) == "string" and toolCall.id or nil, -- 2790
								partialMessageContent, -- 2791
								partialReasoningContent -- 2792
							) -- 2792
							if not decision.success then -- 2792
								partialFailure = decision -- 2795
								break -- 2796
							end -- 2796
							partialDecisions[#partialDecisions + 1] = decision -- 2798
							i = i + 1 -- 2775
						end -- 2775
					end -- 2775
					if not partialFailure and #partialDecisions > 0 then -- 2775
						Log( -- 2801
							"Warn", -- 2801
							"[CodingAgent] committing partial tool calls after incomplete stream tools=" .. table.concat( -- 2801
								__TS__ArrayMap( -- 2801
									partialDecisions, -- 2801
									function(____, decision) return decision.tool end -- 2801
								), -- 2801
								"," -- 2801
							) -- 2801
						) -- 2801
						if #partialDecisions == 1 then -- 2801
							return ____awaiter_resolve(nil, partialDecisions[1]) -- 2801
						end -- 2801
						return ____awaiter_resolve(nil, { -- 2801
							success = true, -- 2806
							kind = "batch", -- 2807
							decisions = partialDecisions, -- 2808
							content = partialMessageContent, -- 2809
							reasoningContent = partialReasoningContent -- 2810
						}) -- 2810
					end -- 2810
					Log("Warn", "[CodingAgent] partial tool calls not commit-ready after incomplete stream: " .. (partialFailure and partialFailure.message or "empty decisions")) -- 2813
				end -- 2813
				local committedDecision = self:commitPreExecutedDecision(shared) -- 2815
				if committedDecision then -- 2815
					return ____awaiter_resolve(nil, committedDecision) -- 2815
				end -- 2815
			end -- 2815
			clearPreExecutedResults(shared) -- 2820
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2820
		end -- 2820
		saveStepLLMDebugOutput( -- 2823
			shared, -- 2823
			stepId, -- 2823
			"decision_tool_calling", -- 2823
			encodeDebugJSON(res.response), -- 2823
			{success = true} -- 2823
		) -- 2823
		local choice = res.response.choices and res.response.choices[1] -- 2824
		local message = choice and choice.message -- 2825
		local toolCalls = message and message.tool_calls -- 2826
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2827
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2830
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2833
		Log( -- 2836
			"Info", -- 2836
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2836
		) -- 2836
		if not toolCalls or #toolCalls == 0 then -- 2836
			if finishReason == "length" then -- 2836
				Log( -- 2839
					"Error", -- 2839
					"[CodingAgent] tool-calling output truncated before tool call reasoning_len=" .. tostring(reasoningContent and #reasoningContent or 0) -- 2839
				) -- 2839
				clearPreExecutedResults(shared) -- 2840
				return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens before producing a tool call. Retry immediately with a valid tool call and keep reasoning minimal.", raw = reasoningContent or messageContent or ""}) -- 2840
			end -- 2840
			if messageContent and messageContent ~= "" then -- 2840
				Log( -- 2848
					"Info", -- 2848
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2848
				) -- 2848
				clearPreExecutedResults(shared) -- 2849
				return ____awaiter_resolve(nil, { -- 2849
					success = true, -- 2851
					tool = "finish", -- 2852
					params = {}, -- 2853
					reason = messageContent, -- 2854
					reasoningContent = reasoningContent, -- 2855
					directSummary = messageContent -- 2856
				}) -- 2856
			end -- 2856
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2859
			clearPreExecutedResults(shared) -- 2860
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2860
		end -- 2860
		local decisions = {} -- 2867
		do -- 2867
			local i = 0 -- 2868
			while i < #toolCalls do -- 2868
				local toolCall = toolCalls[i + 1] -- 2869
				local fn = toolCall and toolCall["function"] -- 2870
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2870
					Log( -- 2872
						"Error", -- 2872
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2872
					) -- 2872
					clearPreExecutedResults(shared) -- 2873
					return ____awaiter_resolve( -- 2873
						nil, -- 2873
						{ -- 2874
							success = false, -- 2875
							message = "missing function name for tool call " .. tostring(i + 1), -- 2876
							raw = messageContent -- 2877
						} -- 2877
					) -- 2877
				end -- 2877
				local functionName = fn.name -- 2880
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2881
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2882
				Log( -- 2885
					"Info", -- 2885
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2885
				) -- 2885
				local decision = parseAndValidateToolCallDecision( -- 2886
					shared, -- 2887
					functionName, -- 2888
					argsText, -- 2889
					toolCallId, -- 2890
					messageContent, -- 2891
					reasoningContent -- 2892
				) -- 2892
				if not decision.success then -- 2892
					Log( -- 2895
						"Error", -- 2895
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2895
					) -- 2895
					clearPreExecutedResults(shared) -- 2896
					return ____awaiter_resolve(nil, decision) -- 2896
				end -- 2896
				decisions[#decisions + 1] = decision -- 2899
				i = i + 1 -- 2868
			end -- 2868
		end -- 2868
		if #decisions == 1 then -- 2868
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2902
			return ____awaiter_resolve(nil, decisions[1]) -- 2902
		end -- 2902
		do -- 2902
			local i = 0 -- 2905
			while i < #decisions do -- 2905
				if decisions[i + 1].tool == "finish" then -- 2905
					clearPreExecutedResults(shared) -- 2907
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2907
				end -- 2907
				i = i + 1 -- 2905
			end -- 2905
		end -- 2905
		Log( -- 2915
			"Info", -- 2915
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2915
				__TS__ArrayMap( -- 2915
					decisions, -- 2915
					function(____, decision) return decision.tool end -- 2915
				), -- 2915
				"," -- 2915
			) -- 2915
		) -- 2915
		return ____awaiter_resolve(nil, { -- 2915
			success = true, -- 2917
			kind = "batch", -- 2918
			decisions = decisions, -- 2919
			content = messageContent, -- 2920
			reasoningContent = reasoningContent -- 2921
		}) -- 2921
	end) -- 2921
end -- 2704
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2925
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2925
		Log( -- 2930
			"Info", -- 2930
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2930
		) -- 2930
		local lastError = initialError -- 2931
		local candidateRaw = "" -- 2932
		do -- 2932
			local attempt = 0 -- 2933
			while attempt < shared.llmMaxTry do -- 2933
				do -- 2933
					Log( -- 2934
						"Info", -- 2934
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2934
					) -- 2934
					local messages = buildXmlRepairMessages( -- 2935
						shared, -- 2936
						originalRaw, -- 2937
						candidateRaw, -- 2938
						lastError, -- 2939
						attempt + 1 -- 2940
					) -- 2940
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2942
					if shared.stopToken.stopped then -- 2942
						return ____awaiter_resolve( -- 2942
							nil, -- 2942
							{ -- 2944
								success = false, -- 2944
								message = getCancelledReason(shared) -- 2944
							} -- 2944
						) -- 2944
					end -- 2944
					if not llmRes.success then -- 2944
						lastError = llmRes.message -- 2947
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2948
						goto __continue486 -- 2949
					end -- 2949
					candidateRaw = llmRes.text -- 2951
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2952
					if decision.success then -- 2952
						decision.reasoningContent = llmRes.reasoningContent -- 2954
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2955
						return ____awaiter_resolve(nil, decision) -- 2955
					end -- 2955
					lastError = decision.message -- 2958
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2959
				end -- 2959
				::__continue486:: -- 2959
				attempt = attempt + 1 -- 2933
			end -- 2933
		end -- 2933
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2961
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2961
	end) -- 2961
end -- 2925
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2969
	if attempt == nil then -- 2969
		attempt = 1 -- 2972
	end -- 2972
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2972
		local messages = buildDecisionMessages( -- 2975
			shared, -- 2976
			lastError, -- 2977
			attempt, -- 2978
			lastRaw, -- 2979
			"xml" -- 2980
		) -- 2980
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2982
		if shared.stopToken.stopped then -- 2982
			return ____awaiter_resolve( -- 2982
				nil, -- 2982
				{ -- 2984
					success = false, -- 2984
					message = getCancelledReason(shared) -- 2984
				} -- 2984
			) -- 2984
		end -- 2984
		if not llmRes.success then -- 2984
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2984
		end -- 2984
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2993
		if decision.success then -- 2993
			decision.reasoningContent = llmRes.reasoningContent -- 2995
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2995
				return ____awaiter_resolve( -- 2995
					nil, -- 2995
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2997
				) -- 2997
			end -- 2997
			return ____awaiter_resolve(nil, decision) -- 2997
		end -- 2997
		return ____awaiter_resolve( -- 2997
			nil, -- 2997
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 3005
		) -- 3005
	end) -- 3005
end -- 2969
function MainDecisionAgent.prototype.exec(self, input) -- 3008
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3008
		local shared = input.shared -- 3009
		if shared.stopToken.stopped then -- 3009
			return ____awaiter_resolve( -- 3009
				nil, -- 3009
				{ -- 3011
					success = false, -- 3011
					message = getCancelledReason(shared) -- 3011
				} -- 3011
			) -- 3011
		end -- 3011
		if shared.step >= shared.maxSteps then -- 3011
			Log( -- 3014
				"Warn", -- 3014
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3014
			) -- 3014
			return ____awaiter_resolve( -- 3014
				nil, -- 3014
				{ -- 3015
					success = false, -- 3015
					message = getMaxStepsReachedReason(shared) -- 3015
				} -- 3015
			) -- 3015
		end -- 3015
		if shared.decisionMode == "tool_calling" then -- 3015
			Log( -- 3019
				"Info", -- 3019
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3019
			) -- 3019
			local lastError = "tool calling validation failed" -- 3020
			local lastRaw = "" -- 3021
			local shouldFallbackToXml = false -- 3022
			do -- 3022
				local attempt = 0 -- 3023
				while attempt < shared.llmMaxTry do -- 3023
					Log( -- 3024
						"Info", -- 3024
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3024
					) -- 3024
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3025
					if shared.stopToken.stopped then -- 3025
						return ____awaiter_resolve( -- 3025
							nil, -- 3025
							{ -- 3032
								success = false, -- 3032
								message = getCancelledReason(shared) -- 3032
							} -- 3032
						) -- 3032
					end -- 3032
					if decision.success then -- 3032
						return ____awaiter_resolve(nil, decision) -- 3032
					end -- 3032
					lastError = decision.message -- 3037
					lastRaw = decision.raw or "" -- 3038
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3039
					if lastError == "missing tool call" then -- 3039
						shouldFallbackToXml = true -- 3041
						break -- 3042
					end -- 3042
					attempt = attempt + 1 -- 3023
				end -- 3023
			end -- 3023
			if shouldFallbackToXml then -- 3023
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3046
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3047
				do -- 3047
					local attempt = 0 -- 3048
					while attempt < shared.llmMaxTry do -- 3048
						Log( -- 3049
							"Info", -- 3049
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3049
						) -- 3049
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3050
						if shared.stopToken.stopped then -- 3050
							return ____awaiter_resolve( -- 3050
								nil, -- 3050
								{ -- 3057
									success = false, -- 3057
									message = getCancelledReason(shared) -- 3057
								} -- 3057
							) -- 3057
						end -- 3057
						if decision.success then -- 3057
							return ____awaiter_resolve(nil, decision) -- 3057
						end -- 3057
						lastError = decision.message -- 3062
						lastRaw = decision.raw or "" -- 3063
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3064
						attempt = attempt + 1 -- 3048
					end -- 3048
				end -- 3048
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3066
				return ____awaiter_resolve( -- 3066
					nil, -- 3066
					{ -- 3067
						success = false, -- 3067
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3067
					} -- 3067
				) -- 3067
			end -- 3067
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3069
			return ____awaiter_resolve( -- 3069
				nil, -- 3069
				{ -- 3070
					success = false, -- 3070
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3070
				} -- 3070
			) -- 3070
		end -- 3070
		local lastError = "xml validation failed" -- 3073
		local lastRaw = "" -- 3074
		do -- 3074
			local attempt = 0 -- 3075
			while attempt < shared.llmMaxTry do -- 3075
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3076
				if shared.stopToken.stopped then -- 3076
					return ____awaiter_resolve( -- 3076
						nil, -- 3076
						{ -- 3085
							success = false, -- 3085
							message = getCancelledReason(shared) -- 3085
						} -- 3085
					) -- 3085
				end -- 3085
				if decision.success then -- 3085
					return ____awaiter_resolve(nil, decision) -- 3085
				end -- 3085
				lastError = decision.message -- 3090
				lastRaw = decision.raw or "" -- 3091
				attempt = attempt + 1 -- 3075
			end -- 3075
		end -- 3075
		return ____awaiter_resolve( -- 3075
			nil, -- 3075
			{ -- 3093
				success = false, -- 3093
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3093
			} -- 3093
		) -- 3093
	end) -- 3093
end -- 3008
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3096
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3096
		local result = execRes -- 3097
		if not result.success then -- 3097
			if shared.stopToken.stopped then -- 3097
				shared.error = getCancelledReason(shared) -- 3100
				shared.done = true -- 3101
				return ____awaiter_resolve(nil, "done") -- 3101
			end -- 3101
			shared.error = result.message -- 3104
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3105
			shared.done = true -- 3106
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3107
			persistHistoryState(shared) -- 3111
			return ____awaiter_resolve(nil, "done") -- 3111
		end -- 3111
		if isDecisionBatchSuccess(result) then -- 3111
			local startStep = shared.step -- 3115
			local actions = {} -- 3116
			do -- 3116
				local i = 0 -- 3117
				while i < #result.decisions do -- 3117
					local decision = result.decisions[i + 1] -- 3118
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3119
					local step = startStep + i + 1 -- 3120
					local ____temp_57 -- 3121
					if i == 0 then -- 3121
						____temp_57 = decision.reason -- 3121
					else -- 3121
						____temp_57 = "" -- 3121
					end -- 3121
					local actionReason = ____temp_57 -- 3121
					local ____temp_58 -- 3122
					if i == 0 then -- 3122
						____temp_58 = decision.reasoningContent -- 3122
					else -- 3122
						____temp_58 = nil -- 3122
					end -- 3122
					local actionReasoningContent = ____temp_58 -- 3122
					emitAgentEvent(shared, { -- 3123
						type = "decision_made", -- 3124
						sessionId = shared.sessionId, -- 3125
						taskId = shared.taskId, -- 3126
						step = step, -- 3127
						tool = decision.tool, -- 3128
						reason = actionReason, -- 3129
						reasoningContent = actionReasoningContent, -- 3130
						params = decision.params -- 3131
					}) -- 3131
					local action = { -- 3133
						step = step, -- 3134
						toolCallId = toolCallId, -- 3135
						tool = decision.tool, -- 3136
						reason = actionReason or "", -- 3137
						reasoningContent = actionReasoningContent, -- 3138
						params = decision.params, -- 3139
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3140
					} -- 3140
					local ____shared_history_59 = shared.history -- 3140
					____shared_history_59[#____shared_history_59 + 1] = action -- 3142
					actions[#actions + 1] = action -- 3143
					i = i + 1 -- 3117
				end -- 3117
			end -- 3117
			shared.step = startStep + #actions -- 3145
			shared.pendingToolActions = actions -- 3146
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3147
			persistHistoryState(shared) -- 3153
			return ____awaiter_resolve(nil, "batch_tools") -- 3153
		end -- 3153
		if result.directSummary and result.directSummary ~= "" then -- 3153
			shared.response = result.directSummary -- 3157
			shared.done = true -- 3158
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3159
			persistHistoryState(shared) -- 3164
			return ____awaiter_resolve(nil, "done") -- 3164
		end -- 3164
		if result.tool == "finish" then -- 3164
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3168
			shared.response = finalMessage -- 3169
			shared.done = true -- 3170
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3171
			persistHistoryState(shared) -- 3176
			return ____awaiter_resolve(nil, "done") -- 3176
		end -- 3176
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3179
		shared.step = shared.step + 1 -- 3180
		local step = shared.step -- 3181
		emitAgentEvent(shared, { -- 3182
			type = "decision_made", -- 3183
			sessionId = shared.sessionId, -- 3184
			taskId = shared.taskId, -- 3185
			step = step, -- 3186
			tool = result.tool, -- 3187
			reason = result.reason, -- 3188
			reasoningContent = result.reasoningContent, -- 3189
			params = result.params -- 3190
		}) -- 3190
		local ____shared_history_60 = shared.history -- 3190
		____shared_history_60[#____shared_history_60 + 1] = { -- 3192
			step = step, -- 3193
			toolCallId = toolCallId, -- 3194
			tool = result.tool, -- 3195
			reason = result.reason or "", -- 3196
			reasoningContent = result.reasoningContent, -- 3197
			params = result.params, -- 3198
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3199
		} -- 3199
		local action = shared.history[#shared.history] -- 3201
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3202
		if canPreExecuteTool(action.tool) then -- 3202
			shared.pendingToolActions = {action} -- 3204
			persistHistoryState(shared) -- 3205
			return ____awaiter_resolve(nil, "batch_tools") -- 3205
		end -- 3205
		clearPreExecutedResults(shared) -- 3208
		persistHistoryState(shared) -- 3209
		return ____awaiter_resolve(nil, result.tool) -- 3209
	end) -- 3209
end -- 3096
local ReadFileAction = __TS__Class() -- 3214
ReadFileAction.name = "ReadFileAction" -- 3214
__TS__ClassExtends(ReadFileAction, Node) -- 3214
function ReadFileAction.prototype.prep(self, shared) -- 3215
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3215
		local last = shared.history[#shared.history] -- 3216
		if not last then -- 3216
			error( -- 3217
				__TS__New(Error, "no history"), -- 3217
				0 -- 3217
			) -- 3217
		end -- 3217
		emitAgentStartEvent(shared, last) -- 3218
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3219
		if __TS__StringTrim(path) == "" then -- 3219
			error( -- 3222
				__TS__New(Error, "missing path"), -- 3222
				0 -- 3222
			) -- 3222
		end -- 3222
		local ____path_63 = path -- 3224
		local ____shared_workingDir_64 = shared.workingDir -- 3226
		local ____temp_65 = shared.useChineseResponse and "zh" or "en" -- 3227
		local ____last_params_startLine_61 = last.params.startLine -- 3228
		if ____last_params_startLine_61 == nil then -- 3228
			____last_params_startLine_61 = 1 -- 3228
		end -- 3228
		local ____TS__Number_result_66 = __TS__Number(____last_params_startLine_61) -- 3228
		local ____last_params_endLine_62 = last.params.endLine -- 3229
		if ____last_params_endLine_62 == nil then -- 3229
			____last_params_endLine_62 = READ_FILE_DEFAULT_LIMIT -- 3229
		end -- 3229
		return ____awaiter_resolve( -- 3229
			nil, -- 3229
			{ -- 3223
				path = ____path_63, -- 3224
				tool = "read_file", -- 3225
				workDir = ____shared_workingDir_64, -- 3226
				docLanguage = ____temp_65, -- 3227
				startLine = ____TS__Number_result_66, -- 3228
				endLine = __TS__Number(____last_params_endLine_62) -- 3229
			} -- 3229
		) -- 3229
	end) -- 3229
end -- 3215
function ReadFileAction.prototype.exec(self, input) -- 3233
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3233
		return ____awaiter_resolve( -- 3233
			nil, -- 3233
			Tools.readFile( -- 3234
				input.workDir, -- 3235
				input.path, -- 3236
				__TS__Number(input.startLine or 1), -- 3237
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3238
				input.docLanguage -- 3239
			) -- 3239
		) -- 3239
	end) -- 3239
end -- 3233
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3243
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3243
		local result = execRes -- 3244
		local last = shared.history[#shared.history] -- 3245
		if last ~= nil then -- 3245
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3247
			appendToolResultMessage(shared, last) -- 3248
			emitAgentFinishEvent(shared, last) -- 3249
		end -- 3249
		persistHistoryState(shared) -- 3251
		__TS__Await(maybeCompressHistory(shared)) -- 3252
		persistHistoryState(shared) -- 3253
		return ____awaiter_resolve(nil, "main") -- 3253
	end) -- 3253
end -- 3243
local SearchFilesAction = __TS__Class() -- 3258
SearchFilesAction.name = "SearchFilesAction" -- 3258
__TS__ClassExtends(SearchFilesAction, Node) -- 3258
function SearchFilesAction.prototype.prep(self, shared) -- 3259
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3259
		local last = shared.history[#shared.history] -- 3260
		if not last then -- 3260
			error( -- 3261
				__TS__New(Error, "no history"), -- 3261
				0 -- 3261
			) -- 3261
		end -- 3261
		emitAgentStartEvent(shared, last) -- 3262
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3262
	end) -- 3262
end -- 3259
function SearchFilesAction.prototype.exec(self, input) -- 3266
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3266
		local params = input.params -- 3267
		local ____Tools_searchFiles_80 = Tools.searchFiles -- 3268
		local ____input_workDir_73 = input.workDir -- 3269
		local ____temp_74 = params.path or "" -- 3270
		local ____temp_75 = params.pattern or "" -- 3271
		local ____params_globs_76 = params.globs -- 3272
		local ____params_useRegex_77 = params.useRegex -- 3273
		local ____params_caseSensitive_78 = params.caseSensitive -- 3274
		local ____math_max_69 = math.max -- 3277
		local ____math_floor_68 = math.floor -- 3277
		local ____params_limit_67 = params.limit -- 3277
		if ____params_limit_67 == nil then -- 3277
			____params_limit_67 = SEARCH_FILES_LIMIT_DEFAULT -- 3277
		end -- 3277
		local ____math_max_69_result_79 = ____math_max_69( -- 3277
			1, -- 3277
			____math_floor_68(__TS__Number(____params_limit_67)) -- 3277
		) -- 3277
		local ____math_max_72 = math.max -- 3278
		local ____math_floor_71 = math.floor -- 3278
		local ____params_offset_70 = params.offset -- 3278
		if ____params_offset_70 == nil then -- 3278
			____params_offset_70 = 0 -- 3278
		end -- 3278
		local result = __TS__Await(____Tools_searchFiles_80({ -- 3268
			workDir = ____input_workDir_73, -- 3269
			path = ____temp_74, -- 3270
			pattern = ____temp_75, -- 3271
			globs = ____params_globs_76, -- 3272
			useRegex = ____params_useRegex_77, -- 3273
			caseSensitive = ____params_caseSensitive_78, -- 3274
			includeContent = true, -- 3275
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3276
			limit = ____math_max_69_result_79, -- 3277
			offset = ____math_max_72( -- 3278
				0, -- 3278
				____math_floor_71(__TS__Number(____params_offset_70)) -- 3278
			), -- 3278
			groupByFile = params.groupByFile == true -- 3279
		})) -- 3279
		return ____awaiter_resolve(nil, result) -- 3279
	end) -- 3279
end -- 3266
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3284
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3284
		local last = shared.history[#shared.history] -- 3285
		if last ~= nil then -- 3285
			local result = execRes -- 3287
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3288
			appendToolResultMessage(shared, last) -- 3289
			emitAgentFinishEvent(shared, last) -- 3290
		end -- 3290
		persistHistoryState(shared) -- 3292
		__TS__Await(maybeCompressHistory(shared)) -- 3293
		persistHistoryState(shared) -- 3294
		return ____awaiter_resolve(nil, "main") -- 3294
	end) -- 3294
end -- 3284
local SearchDoraAPIAction = __TS__Class() -- 3299
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3299
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3299
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3300
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3300
		local last = shared.history[#shared.history] -- 3301
		if not last then -- 3301
			error( -- 3302
				__TS__New(Error, "no history"), -- 3302
				0 -- 3302
			) -- 3302
		end -- 3302
		emitAgentStartEvent(shared, last) -- 3303
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3303
	end) -- 3303
end -- 3300
function SearchDoraAPIAction.prototype.exec(self, input) -- 3307
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3307
		local params = input.params -- 3308
		local ____Tools_searchDoraAPI_88 = Tools.searchDoraAPI -- 3309
		local ____temp_84 = params.pattern or "" -- 3310
		local ____temp_85 = params.docSource or "api" -- 3311
		local ____temp_86 = input.useChineseResponse and "zh" or "en" -- 3312
		local ____temp_87 = params.programmingLanguage or "ts" -- 3313
		local ____math_min_83 = math.min -- 3314
		local ____math_max_82 = math.max -- 3314
		local ____params_limit_81 = params.limit -- 3314
		if ____params_limit_81 == nil then -- 3314
			____params_limit_81 = 8 -- 3314
		end -- 3314
		local result = __TS__Await(____Tools_searchDoraAPI_88({ -- 3309
			pattern = ____temp_84, -- 3310
			docSource = ____temp_85, -- 3311
			docLanguage = ____temp_86, -- 3312
			programmingLanguage = ____temp_87, -- 3313
			limit = ____math_min_83( -- 3314
				SEARCH_DORA_API_LIMIT_MAX, -- 3314
				____math_max_82( -- 3314
					1, -- 3314
					__TS__Number(____params_limit_81) -- 3314
				) -- 3314
			), -- 3314
			useRegex = params.useRegex, -- 3315
			caseSensitive = false, -- 3316
			includeContent = true, -- 3317
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3318
		})) -- 3318
		return ____awaiter_resolve(nil, result) -- 3318
	end) -- 3318
end -- 3307
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3323
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3323
		local last = shared.history[#shared.history] -- 3324
		if last ~= nil then -- 3324
			local result = execRes -- 3326
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3327
			appendToolResultMessage(shared, last) -- 3328
			emitAgentFinishEvent(shared, last) -- 3329
		end -- 3329
		persistHistoryState(shared) -- 3331
		__TS__Await(maybeCompressHistory(shared)) -- 3332
		persistHistoryState(shared) -- 3333
		return ____awaiter_resolve(nil, "main") -- 3333
	end) -- 3333
end -- 3323
local ListFilesAction = __TS__Class() -- 3338
ListFilesAction.name = "ListFilesAction" -- 3338
__TS__ClassExtends(ListFilesAction, Node) -- 3338
function ListFilesAction.prototype.prep(self, shared) -- 3339
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3339
		local last = shared.history[#shared.history] -- 3340
		if not last then -- 3340
			error( -- 3341
				__TS__New(Error, "no history"), -- 3341
				0 -- 3341
			) -- 3341
		end -- 3341
		emitAgentStartEvent(shared, last) -- 3342
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3342
	end) -- 3342
end -- 3339
function ListFilesAction.prototype.exec(self, input) -- 3346
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3346
		local params = input.params -- 3347
		local ____Tools_listFiles_95 = Tools.listFiles -- 3348
		local ____input_workDir_92 = input.workDir -- 3349
		local ____temp_93 = params.path or "" -- 3350
		local ____params_globs_94 = params.globs -- 3351
		local ____math_max_91 = math.max -- 3352
		local ____math_floor_90 = math.floor -- 3352
		local ____params_maxEntries_89 = params.maxEntries -- 3352
		if ____params_maxEntries_89 == nil then -- 3352
			____params_maxEntries_89 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3352
		end -- 3352
		local result = ____Tools_listFiles_95({ -- 3348
			workDir = ____input_workDir_92, -- 3349
			path = ____temp_93, -- 3350
			globs = ____params_globs_94, -- 3351
			maxEntries = ____math_max_91( -- 3352
				1, -- 3352
				____math_floor_90(__TS__Number(____params_maxEntries_89)) -- 3352
			) -- 3352
		}) -- 3352
		return ____awaiter_resolve(nil, result) -- 3352
	end) -- 3352
end -- 3346
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3357
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3357
		local last = shared.history[#shared.history] -- 3358
		if last ~= nil then -- 3358
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3360
			appendToolResultMessage(shared, last) -- 3361
			emitAgentFinishEvent(shared, last) -- 3362
		end -- 3362
		persistHistoryState(shared) -- 3364
		__TS__Await(maybeCompressHistory(shared)) -- 3365
		persistHistoryState(shared) -- 3366
		return ____awaiter_resolve(nil, "main") -- 3366
	end) -- 3366
end -- 3357
local DeleteFileAction = __TS__Class() -- 3371
DeleteFileAction.name = "DeleteFileAction" -- 3371
__TS__ClassExtends(DeleteFileAction, Node) -- 3371
function DeleteFileAction.prototype.prep(self, shared) -- 3372
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3372
		local last = shared.history[#shared.history] -- 3373
		if not last then -- 3373
			error( -- 3374
				__TS__New(Error, "no history"), -- 3374
				0 -- 3374
			) -- 3374
		end -- 3374
		emitAgentStartEvent(shared, last) -- 3375
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3376
		if __TS__StringTrim(targetFile) == "" then -- 3376
			error( -- 3379
				__TS__New(Error, "missing target_file"), -- 3379
				0 -- 3379
			) -- 3379
		end -- 3379
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3379
	end) -- 3379
end -- 3372
function DeleteFileAction.prototype.exec(self, input) -- 3383
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3383
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3384
		if not result.success then -- 3384
			return ____awaiter_resolve(nil, result) -- 3384
		end -- 3384
		return ____awaiter_resolve(nil, { -- 3384
			success = true, -- 3392
			changed = true, -- 3393
			mode = "delete", -- 3394
			checkpointId = result.checkpointId, -- 3395
			checkpointSeq = result.checkpointSeq, -- 3396
			files = {{path = input.targetFile, op = "delete"}} -- 3397
		}) -- 3397
	end) -- 3397
end -- 3383
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3401
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3401
		local last = shared.history[#shared.history] -- 3402
		if last ~= nil then -- 3402
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3404
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3405
			appendToolResultMessage(shared, last) -- 3406
			emitAgentFinishEvent(shared, last) -- 3407
			local result = last.result -- 3408
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3408
				emitAgentEvent(shared, { -- 3413
					type = "checkpoint_created", -- 3414
					sessionId = shared.sessionId, -- 3415
					taskId = shared.taskId, -- 3416
					step = last.step, -- 3417
					tool = "delete_file", -- 3418
					checkpointId = result.checkpointId, -- 3419
					checkpointSeq = result.checkpointSeq, -- 3420
					files = result.files -- 3421
				}) -- 3421
			end -- 3421
		end -- 3421
		persistHistoryState(shared) -- 3425
		__TS__Await(maybeCompressHistory(shared)) -- 3426
		persistHistoryState(shared) -- 3427
		return ____awaiter_resolve(nil, "main") -- 3427
	end) -- 3427
end -- 3401
local BuildAction = __TS__Class() -- 3432
BuildAction.name = "BuildAction" -- 3432
__TS__ClassExtends(BuildAction, Node) -- 3432
function BuildAction.prototype.prep(self, shared) -- 3433
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3433
		local last = shared.history[#shared.history] -- 3434
		if not last then -- 3434
			error( -- 3435
				__TS__New(Error, "no history"), -- 3435
				0 -- 3435
			) -- 3435
		end -- 3435
		emitAgentStartEvent(shared, last) -- 3436
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3436
	end) -- 3436
end -- 3433
function BuildAction.prototype.exec(self, input) -- 3440
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3440
		local params = input.params -- 3441
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3442
		return ____awaiter_resolve(nil, result) -- 3442
	end) -- 3442
end -- 3440
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3449
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3449
		local last = shared.history[#shared.history] -- 3450
		if last ~= nil then -- 3450
			last.result = sanitizeBuildResultForHistory(execRes) -- 3452
			appendToolResultMessage(shared, last) -- 3453
			emitAgentFinishEvent(shared, last) -- 3454
		end -- 3454
		persistHistoryState(shared) -- 3456
		__TS__Await(maybeCompressHistory(shared)) -- 3457
		persistHistoryState(shared) -- 3458
		return ____awaiter_resolve(nil, "main") -- 3458
	end) -- 3458
end -- 3449
local SpawnSubAgentAction = __TS__Class() -- 3463
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3463
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3463
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3464
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3464
		local last = shared.history[#shared.history] -- 3473
		if not last then -- 3473
			error( -- 3474
				__TS__New(Error, "no history"), -- 3474
				0 -- 3474
			) -- 3474
		end -- 3474
		emitAgentStartEvent(shared, last) -- 3475
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3476
			last.params.filesHint, -- 3477
			function(____, item) return type(item) == "string" end -- 3477
		) or nil -- 3477
		return ____awaiter_resolve( -- 3477
			nil, -- 3477
			{ -- 3479
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3480
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3481
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3482
				filesHint = filesHint, -- 3483
				sessionId = shared.sessionId, -- 3484
				projectRoot = shared.workingDir, -- 3485
				spawnSubAgent = shared.spawnSubAgent -- 3486
			} -- 3486
		) -- 3486
	end) -- 3486
end -- 3464
function SpawnSubAgentAction.prototype.exec(self, input) -- 3490
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3490
		if not input.spawnSubAgent then -- 3490
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3490
		end -- 3490
		if input.sessionId == nil or input.sessionId <= 0 then -- 3490
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3490
		end -- 3490
		local ____Log_101 = Log -- 3505
		local ____temp_98 = #input.title -- 3505
		local ____temp_99 = #input.prompt -- 3505
		local ____temp_100 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3505
		local ____opt_96 = input.filesHint -- 3505
		____Log_101( -- 3505
			"Info", -- 3505
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_98)) .. " prompt_len=") .. tostring(____temp_99)) .. " expected_len=") .. tostring(____temp_100)) .. " files_hint_count=") .. tostring(____opt_96 and #____opt_96 or 0) -- 3505
		) -- 3505
		local result = __TS__Await(input.spawnSubAgent({ -- 3506
			parentSessionId = input.sessionId, -- 3507
			projectRoot = input.projectRoot, -- 3508
			title = input.title, -- 3509
			prompt = input.prompt, -- 3510
			expectedOutput = input.expectedOutput, -- 3511
			filesHint = input.filesHint -- 3512
		})) -- 3512
		if not result.success then -- 3512
			return ____awaiter_resolve(nil, result) -- 3512
		end -- 3512
		return ____awaiter_resolve(nil, { -- 3512
			success = true, -- 3518
			sessionId = result.sessionId, -- 3519
			taskId = result.taskId, -- 3520
			title = result.title, -- 3521
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3522
		}) -- 3522
	end) -- 3522
end -- 3490
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3526
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3526
		local last = shared.history[#shared.history] -- 3527
		if last ~= nil then -- 3527
			last.result = execRes -- 3529
			appendToolResultMessage(shared, last) -- 3530
			emitAgentFinishEvent(shared, last) -- 3531
		end -- 3531
		persistHistoryState(shared) -- 3533
		__TS__Await(maybeCompressHistory(shared)) -- 3534
		persistHistoryState(shared) -- 3535
		return ____awaiter_resolve(nil, "main") -- 3535
	end) -- 3535
end -- 3526
local ListSubAgentsAction = __TS__Class() -- 3540
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3540
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3540
function ListSubAgentsAction.prototype.prep(self, shared) -- 3541
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3541
		local last = shared.history[#shared.history] -- 3550
		if not last then -- 3550
			error( -- 3551
				__TS__New(Error, "no history"), -- 3551
				0 -- 3551
			) -- 3551
		end -- 3551
		emitAgentStartEvent(shared, last) -- 3552
		return ____awaiter_resolve( -- 3552
			nil, -- 3552
			{ -- 3553
				sessionId = shared.sessionId, -- 3554
				projectRoot = shared.workingDir, -- 3555
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3556
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3557
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3558
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3559
				listSubAgents = shared.listSubAgents -- 3560
			} -- 3560
		) -- 3560
	end) -- 3560
end -- 3541
function ListSubAgentsAction.prototype.exec(self, input) -- 3564
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3564
		if not input.listSubAgents then -- 3564
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3564
		end -- 3564
		if input.sessionId == nil or input.sessionId <= 0 then -- 3564
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3564
		end -- 3564
		local result = __TS__Await(input.listSubAgents({ -- 3579
			sessionId = input.sessionId, -- 3580
			projectRoot = input.projectRoot, -- 3581
			status = input.status, -- 3582
			limit = input.limit, -- 3583
			offset = input.offset, -- 3584
			query = input.query -- 3585
		})) -- 3585
		return ____awaiter_resolve(nil, result) -- 3585
	end) -- 3585
end -- 3564
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3590
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3590
		local last = shared.history[#shared.history] -- 3591
		if last ~= nil then -- 3591
			last.result = execRes -- 3593
			appendToolResultMessage(shared, last) -- 3594
			emitAgentFinishEvent(shared, last) -- 3595
		end -- 3595
		persistHistoryState(shared) -- 3597
		__TS__Await(maybeCompressHistory(shared)) -- 3598
		persistHistoryState(shared) -- 3599
		return ____awaiter_resolve(nil, "main") -- 3599
	end) -- 3599
end -- 3590
EditFileAction = __TS__Class() -- 3604
EditFileAction.name = "EditFileAction" -- 3604
__TS__ClassExtends(EditFileAction, Node) -- 3604
function EditFileAction.prototype.prep(self, shared) -- 3605
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3605
		local last = shared.history[#shared.history] -- 3606
		if not last then -- 3606
			error( -- 3607
				__TS__New(Error, "no history"), -- 3607
				0 -- 3607
			) -- 3607
		end -- 3607
		emitAgentStartEvent(shared, last) -- 3608
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3609
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3612
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3613
		if __TS__StringTrim(path) == "" then -- 3613
			error( -- 3614
				__TS__New(Error, "missing path"), -- 3614
				0 -- 3614
			) -- 3614
		end -- 3614
		return ____awaiter_resolve(nil, { -- 3614
			path = path, -- 3615
			oldStr = oldStr, -- 3615
			newStr = newStr, -- 3615
			taskId = shared.taskId, -- 3615
			workDir = shared.workingDir -- 3615
		}) -- 3615
	end) -- 3615
end -- 3605
function EditFileAction.prototype.exec(self, input) -- 3618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3618
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3619
		if not readRes.success then -- 3619
			if input.oldStr ~= "" then -- 3619
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3619
			end -- 3619
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3624
			if not createRes.success then -- 3624
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3624
			end -- 3624
			return ____awaiter_resolve(nil, { -- 3624
				success = true, -- 3632
				changed = true, -- 3633
				mode = "create", -- 3634
				checkpointId = createRes.checkpointId, -- 3635
				checkpointSeq = createRes.checkpointSeq, -- 3636
				files = {{path = input.path, op = "create"}} -- 3637
			}) -- 3637
		end -- 3637
		if input.oldStr == "" then -- 3637
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3641
			if not overwriteRes.success then -- 3641
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3641
			end -- 3641
			return ____awaiter_resolve(nil, { -- 3641
				success = true, -- 3649
				changed = true, -- 3650
				mode = "overwrite", -- 3651
				checkpointId = overwriteRes.checkpointId, -- 3652
				checkpointSeq = overwriteRes.checkpointSeq, -- 3653
				files = {{path = input.path, op = "write"}} -- 3654
			}) -- 3654
		end -- 3654
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3659
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3660
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3661
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3664
		if occurrences == 0 then -- 3664
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3666
			if not indentTolerant.success then -- 3666
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3666
			end -- 3666
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3670
			if not applyRes.success then -- 3670
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3670
			end -- 3670
			return ____awaiter_resolve(nil, { -- 3670
				success = true, -- 3678
				changed = true, -- 3679
				mode = "replace_indent_tolerant", -- 3680
				checkpointId = applyRes.checkpointId, -- 3681
				checkpointSeq = applyRes.checkpointSeq, -- 3682
				files = {{path = input.path, op = "write"}} -- 3683
			}) -- 3683
		end -- 3683
		if occurrences > 1 then -- 3683
			return ____awaiter_resolve( -- 3683
				nil, -- 3683
				{ -- 3687
					success = false, -- 3687
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3687
				} -- 3687
			) -- 3687
		end -- 3687
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3691
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3692
		if not applyRes.success then -- 3692
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3692
		end -- 3692
		return ____awaiter_resolve(nil, { -- 3692
			success = true, -- 3700
			changed = true, -- 3701
			mode = "replace", -- 3702
			checkpointId = applyRes.checkpointId, -- 3703
			checkpointSeq = applyRes.checkpointSeq, -- 3704
			files = {{path = input.path, op = "write"}} -- 3705
		}) -- 3705
	end) -- 3705
end -- 3618
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3709
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3709
		local last = shared.history[#shared.history] -- 3710
		if last ~= nil then -- 3710
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3712
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3713
			appendToolResultMessage(shared, last) -- 3714
			emitAgentFinishEvent(shared, last) -- 3715
			local result = last.result -- 3716
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3716
				emitAgentEvent(shared, { -- 3721
					type = "checkpoint_created", -- 3722
					sessionId = shared.sessionId, -- 3723
					taskId = shared.taskId, -- 3724
					step = last.step, -- 3725
					tool = last.tool, -- 3726
					checkpointId = result.checkpointId, -- 3727
					checkpointSeq = result.checkpointSeq, -- 3728
					files = result.files -- 3729
				}) -- 3729
			end -- 3729
		end -- 3729
		persistHistoryState(shared) -- 3733
		__TS__Await(maybeCompressHistory(shared)) -- 3734
		persistHistoryState(shared) -- 3735
		return ____awaiter_resolve(nil, "main") -- 3735
	end) -- 3735
end -- 3709
local function emitCheckpointEventForAction(shared, action) -- 3740
	local result = action.result -- 3741
	if not result then -- 3741
		return -- 3742
	end -- 3742
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3742
		emitAgentEvent(shared, { -- 3747
			type = "checkpoint_created", -- 3748
			sessionId = shared.sessionId, -- 3749
			taskId = shared.taskId, -- 3750
			step = action.step, -- 3751
			tool = action.tool, -- 3752
			checkpointId = result.checkpointId, -- 3753
			checkpointSeq = result.checkpointSeq, -- 3754
			files = result.files -- 3755
		}) -- 3755
	end -- 3755
end -- 3740
local function canRunBatchActionInParallel(self, action) -- 4060
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 4061
end -- 4060
local function partitionToolCalls(actions) -- 4073
	local batches = {} -- 4074
	do -- 4074
		local i = 0 -- 4075
		while i < #actions do -- 4075
			local action = actions[i + 1] -- 4076
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4077
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4078
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4078
				local ____lastBatch_actions_136 = lastBatch.actions -- 4078
				____lastBatch_actions_136[#____lastBatch_actions_136 + 1] = action -- 4080
			else -- 4080
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4082
			end -- 4082
			i = i + 1 -- 4075
		end -- 4075
	end -- 4075
	return batches -- 4085
end -- 4073
local BatchToolAction = __TS__Class() -- 4088
BatchToolAction.name = "BatchToolAction" -- 4088
__TS__ClassExtends(BatchToolAction, Node) -- 4088
function BatchToolAction.prototype.prep(self, shared) -- 4089
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4089
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4089
	end) -- 4089
end -- 4089
function BatchToolAction.prototype.exec(self, input) -- 4093
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4093
		local shared = input.shared -- 4094
		local preExecuted = shared.preExecutedResults -- 4095
		local batches = partitionToolCalls(input.actions) -- 4096
		local parallelBatchCount = #__TS__ArrayFilter( -- 4097
			batches, -- 4097
			function(____, b) return b.isConcurrencySafe end -- 4097
		) -- 4097
		local serialBatchCount = #__TS__ArrayFilter( -- 4098
			batches, -- 4098
			function(____, b) return not b.isConcurrencySafe end -- 4098
		) -- 4098
		Log( -- 4099
			"Info", -- 4099
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4099
		) -- 4099
		do -- 4099
			local batchIdx = 0 -- 4101
			while batchIdx < #batches do -- 4101
				do -- 4101
					local batch = batches[batchIdx + 1] -- 4102
					if shared.stopToken.stopped then -- 4102
						for ____, action in ipairs(batch.actions) do -- 4104
							if not action.result then -- 4104
								action.result = { -- 4106
									success = false, -- 4106
									message = getCancelledReason(shared) -- 4106
								} -- 4106
							end -- 4106
						end -- 4106
						goto __continue658 -- 4109
					end -- 4109
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4109
						local preExecCount = #__TS__ArrayFilter( -- 4113
							batch.actions, -- 4113
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4113
						) -- 4113
						Log( -- 4114
							"Info", -- 4114
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4114
						) -- 4114
						do -- 4114
							local i = 0 -- 4115
							while i < #batch.actions do -- 4115
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4116
								i = i + 1 -- 4115
							end -- 4115
						end -- 4115
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4118
							batch.actions, -- 4118
							function(____, action) -- 4118
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4118
									if shared.stopToken.stopped then -- 4118
										action.result = { -- 4120
											success = false, -- 4120
											message = getCancelledReason(shared) -- 4120
										} -- 4120
										return ____awaiter_resolve(nil, action) -- 4120
									end -- 4120
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4123
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4124
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4125
									return ____awaiter_resolve(nil, action) -- 4125
								end) -- 4125
							end -- 4118
						))) -- 4118
						do -- 4118
							local i = 0 -- 4128
							while i < #batch.actions do -- 4128
								local action = batch.actions[i + 1] -- 4129
								if not action.result then -- 4129
									action.result = {success = false, message = "tool did not produce a result"} -- 4131
								end -- 4131
								appendToolResultMessage(shared, action) -- 4133
								emitAgentFinishEvent(shared, action) -- 4134
								emitCheckpointEventForAction(shared, action) -- 4135
								i = i + 1 -- 4128
							end -- 4128
						end -- 4128
					else -- 4128
						Log( -- 4138
							"Info", -- 4138
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4138
						) -- 4138
						do -- 4138
							local i = 0 -- 4139
							while i < #batch.actions do -- 4139
								local action = batch.actions[i + 1] -- 4140
								emitAgentStartEvent(shared, action) -- 4141
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4142
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4143
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4144
								appendToolResultMessage(shared, action) -- 4145
								emitAgentFinishEvent(shared, action) -- 4146
								emitCheckpointEventForAction(shared, action) -- 4147
								persistHistoryState(shared) -- 4148
								if shared.stopToken.stopped then -- 4148
									break -- 4150
								end -- 4150
								i = i + 1 -- 4139
							end -- 4139
						end -- 4139
					end -- 4139
				end -- 4139
				::__continue658:: -- 4139
				batchIdx = batchIdx + 1 -- 4101
			end -- 4101
		end -- 4101
		persistHistoryState(shared) -- 4155
		return ____awaiter_resolve(nil, input.actions) -- 4155
	end) -- 4155
end -- 4093
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4159
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4159
		shared.pendingToolActions = nil -- 4160
		shared.preExecutedResults = nil -- 4161
		persistHistoryState(shared) -- 4162
		__TS__Await(maybeCompressHistory(shared)) -- 4163
		persistHistoryState(shared) -- 4164
		return ____awaiter_resolve(nil, "main") -- 4164
	end) -- 4164
end -- 4159
local EndNode = __TS__Class() -- 4169
EndNode.name = "EndNode" -- 4169
__TS__ClassExtends(EndNode, Node) -- 4169
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4170
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4170
		return ____awaiter_resolve(nil, nil) -- 4170
	end) -- 4170
end -- 4170
local CodingAgentFlow = __TS__Class() -- 4175
CodingAgentFlow.name = "CodingAgentFlow" -- 4175
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4175
function CodingAgentFlow.prototype.____constructor(self, role) -- 4176
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4177
	local read = __TS__New(ReadFileAction, 1, 0) -- 4178
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4179
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4180
	local list = __TS__New(ListFilesAction, 1, 0) -- 4181
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4182
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4183
	local build = __TS__New(BuildAction, 1, 0) -- 4184
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4185
	local edit = __TS__New(EditFileAction, 1, 0) -- 4186
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4187
	local done = __TS__New(EndNode, 1, 0) -- 4188
	main:on("batch_tools", batch) -- 4190
	main:on("grep_files", search) -- 4191
	main:on("search_dora_api", searchDora) -- 4192
	main:on("glob_files", list) -- 4193
	if role == "main" then -- 4193
		main:on("read_file", read) -- 4195
		main:on("delete_file", del) -- 4196
		main:on("build", build) -- 4197
		main:on("edit_file", edit) -- 4198
		main:on("list_sub_agents", listSub) -- 4199
		main:on("spawn_sub_agent", spawn) -- 4200
	else -- 4200
		main:on("read_file", read) -- 4202
		main:on("delete_file", del) -- 4203
		main:on("build", build) -- 4204
		main:on("edit_file", edit) -- 4205
	end -- 4205
	main:on("done", done) -- 4207
	search:on("main", main) -- 4209
	searchDora:on("main", main) -- 4210
	list:on("main", main) -- 4211
	listSub:on("main", main) -- 4212
	spawn:on("main", main) -- 4213
	batch:on("main", main) -- 4214
	read:on("main", main) -- 4215
	del:on("main", main) -- 4216
	build:on("main", main) -- 4217
	edit:on("main", main) -- 4218
	Flow.prototype.____constructor(self, main) -- 4220
end -- 4176
local function runCodingAgentAsync(options) -- 4242
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4242
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4242
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4242
		end -- 4242
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4246
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4247
		if not llmConfigRes.success then -- 4247
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4247
		end -- 4247
		local llmConfig = llmConfigRes.config -- 4253
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4254
		if not taskRes.success then -- 4254
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4254
		end -- 4254
		local compressor = __TS__New(MemoryCompressor, { -- 4261
			compressionThreshold = 0.8, -- 4262
			compressionTargetThreshold = 0.5, -- 4263
			maxCompressionRounds = 3, -- 4264
			projectDir = options.workDir, -- 4265
			llmConfig = llmConfig, -- 4266
			promptPack = options.promptPack, -- 4267
			scope = options.memoryScope -- 4268
		}) -- 4268
		local persistedSession = compressor:getStorage():readSessionState() -- 4270
		local promptPack = compressor:getPromptPack() -- 4271
		local shared = { -- 4273
			sessionId = options.sessionId, -- 4274
			taskId = taskRes.taskId, -- 4275
			role = options.role or "main", -- 4276
			maxSteps = math.max( -- 4277
				1, -- 4277
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4277
			), -- 4277
			llmMaxTry = math.max( -- 4278
				1, -- 4278
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4278
			), -- 4278
			step = 0, -- 4279
			done = false, -- 4280
			stopToken = options.stopToken or ({stopped = false}), -- 4281
			response = "", -- 4282
			userQuery = normalizedPrompt, -- 4283
			workingDir = options.workDir, -- 4284
			useChineseResponse = options.useChineseResponse == true, -- 4285
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4286
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4289
			llmConfig = llmConfig, -- 4290
			onEvent = options.onEvent, -- 4291
			promptPack = promptPack, -- 4292
			history = {}, -- 4293
			messages = persistedSession.messages, -- 4294
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4295
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4296
			memory = {compressor = compressor}, -- 4298
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4302
			spawnSubAgent = options.spawnSubAgent, -- 4307
			listSubAgents = options.listSubAgents -- 4308
		} -- 4308
		local ____hasReturned, ____returnValue -- 4308
		local ____try = __TS__AsyncAwaiter(function() -- 4308
			emitAgentEvent(shared, { -- 4312
				type = "task_started", -- 4313
				sessionId = shared.sessionId, -- 4314
				taskId = shared.taskId, -- 4315
				prompt = shared.userQuery, -- 4316
				workDir = shared.workingDir, -- 4317
				maxSteps = shared.maxSteps -- 4318
			}) -- 4318
			if shared.stopToken.stopped then -- 4318
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4321
				____hasReturned = true -- 4322
				____returnValue = emitAgentTaskFinishEvent( -- 4322
					shared, -- 4322
					false, -- 4322
					getCancelledReason(shared) -- 4322
				) -- 4322
				return -- 4322
			end -- 4322
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4324
			local promptCommand = getPromptCommand(shared.userQuery) -- 4325
			if promptCommand == "clear" then -- 4325
				____hasReturned = true -- 4327
				____returnValue = clearSessionHistory(shared) -- 4327
				return -- 4327
			end -- 4327
			if promptCommand == "compact" then -- 4327
				if shared.role == "sub" then -- 4327
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4331
					____hasReturned = true -- 4332
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4332
					return -- 4332
				end -- 4332
				____hasReturned = true -- 4340
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4340
				return -- 4340
			end -- 4340
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4342
			persistHistoryState(shared) -- 4346
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4347
			__TS__Await(flow:run(shared)) -- 4348
			if shared.stopToken.stopped then -- 4348
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4350
				____hasReturned = true -- 4351
				____returnValue = emitAgentTaskFinishEvent( -- 4351
					shared, -- 4351
					false, -- 4351
					getCancelledReason(shared) -- 4351
				) -- 4351
				return -- 4351
			end -- 4351
			if shared.error then -- 4351
				____hasReturned = true -- 4354
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4354
				return -- 4354
			end -- 4354
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4357
			____hasReturned = true -- 4358
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4358
			return -- 4358
		end) -- 4358
		____try = ____try.catch( -- 4358
			____try, -- 4358
			function(____, e) -- 4358
				return __TS__AsyncAwaiter(function() -- 4358
					____hasReturned = true -- 4361
					____returnValue = finalizeAgentFailure( -- 4361
						shared, -- 4361
						tostring(e) -- 4361
					) -- 4361
					return -- 4361
				end) -- 4361
			end -- 4361
		) -- 4361
		__TS__Await(____try) -- 4311
		if ____hasReturned then -- 4311
			return ____awaiter_resolve(nil, ____returnValue) -- 4311
		end -- 4311
	end) -- 4311
end -- 4242
function ____exports.runCodingAgent(options, callback) -- 4365
	local ____self_139 = runCodingAgentAsync(options) -- 4365
	____self_139["then"]( -- 4365
		____self_139, -- 4365
		function(____, result) return callback(result) end -- 4366
	) -- 4366
end -- 4365
return ____exports -- 4365