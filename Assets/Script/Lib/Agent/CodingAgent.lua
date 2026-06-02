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
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1274
	local base = shared.promptPack.toolDefinitionsDetailed -- 1275
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1276
	local availableTools = __TS__ArrayFilter( -- 1278
		getAllowedToolsForRole(shared.role), -- 1278
		function(____, tool) return shared.decisionMode == "xml" or tool ~= "finish" end -- 1279
	) -- 1279
	local availability = (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat(availableTools, ", ") -- 1280
	local withRole = replacePromptVars((base .. mainAgentTools) .. availability, params) -- 1285
	if (shared and shared.decisionMode) ~= "xml" then -- 1285
		return withRole -- 1290
	end -- 1290
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1292
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1293
end -- 1293
function getFinishMessage(params, fallback) -- 1646
	if fallback == nil then -- 1646
		fallback = "" -- 1646
	end -- 1646
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1646
		return __TS__StringTrim(params.message) -- 1648
	end -- 1648
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1648
		return __TS__StringTrim(params.response) -- 1651
	end -- 1651
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1651
		return __TS__StringTrim(params.summary) -- 1654
	end -- 1654
	return __TS__StringTrim(fallback) -- 1656
end -- 1656
function persistHistoryState(shared) -- 1659
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1660
end -- 1660
function getActiveConversationMessages(shared) -- 1667
	local activeMessages = {} -- 1668
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1668
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1675
	end -- 1675
	do -- 1675
		local i = shared.lastConsolidatedIndex -- 1679
		while i < #shared.messages do -- 1679
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1680
			i = i + 1 -- 1679
		end -- 1679
	end -- 1679
	return activeMessages -- 1682
end -- 1682
function getActiveRealMessageCount(shared) -- 1685
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1686
end -- 1686
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1689
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1694
	local previousActiveStart = shared.lastConsolidatedIndex -- 1695
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1696
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1697
	if type(carryMessageIndex) == "number" then -- 1697
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1697
		else -- 1697
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1705
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1708
		end -- 1708
	else -- 1708
		shared.carryMessageIndex = nil -- 1713
	end -- 1713
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1713
		shared.carryMessageIndex = nil -- 1723
	end -- 1723
end -- 1723
function getDecisionPath(params) -- 1981
	if type(params.path) == "string" then -- 1981
		return __TS__StringTrim(params.path) -- 1982
	end -- 1982
	if type(params.target_file) == "string" then -- 1982
		return __TS__StringTrim(params.target_file) -- 1983
	end -- 1983
	return "" -- 1984
end -- 1984
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1987
	local num = __TS__Number(value) -- 1988
	if not __TS__NumberIsFinite(num) then -- 1988
		num = fallback -- 1989
	end -- 1989
	num = math.floor(num) -- 1990
	if num < minValue then -- 1990
		num = minValue -- 1991
	end -- 1991
	if maxValue ~= nil and num > maxValue then -- 1991
		num = maxValue -- 1992
	end -- 1992
	return num -- 1993
end -- 1993
function parseReadLineParam(value, fallback, paramName) -- 1996
	local num = __TS__Number(value) -- 2001
	if not __TS__NumberIsFinite(num) then -- 2001
		num = fallback -- 2002
	end -- 2002
	num = math.floor(num) -- 2003
	if num == 0 then -- 2003
		return {success = false, message = paramName .. " cannot be 0"} -- 2005
	end -- 2005
	return {success = true, value = num} -- 2007
end -- 2007
function validateDecision(tool, params) -- 2010
	if tool == "finish" then -- 2010
		local message = getFinishMessage(params) -- 2015
		if message == "" then -- 2015
			return {success = false, message = "finish requires params.message"} -- 2016
		end -- 2016
		params.message = message -- 2017
		return {success = true, params = params} -- 2018
	end -- 2018
	if tool == "read_file" then -- 2018
		local path = getDecisionPath(params) -- 2022
		if path == "" then -- 2022
			return {success = false, message = "read_file requires path"} -- 2023
		end -- 2023
		params.path = path -- 2024
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2025
		if not startLineRes.success then -- 2025
			return startLineRes -- 2026
		end -- 2026
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 2027
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2028
		if not endLineRes.success then -- 2028
			return endLineRes -- 2029
		end -- 2029
		params.startLine = startLineRes.value -- 2030
		params.endLine = endLineRes.value -- 2031
		return {success = true, params = params} -- 2032
	end -- 2032
	if tool == "edit_file" then -- 2032
		local path = getDecisionPath(params) -- 2036
		if path == "" then -- 2036
			return {success = false, message = "edit_file requires path"} -- 2037
		end -- 2037
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2038
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2039
		params.path = path -- 2040
		params.old_str = oldStr -- 2041
		params.new_str = newStr -- 2042
		return {success = true, params = params} -- 2043
	end -- 2043
	if tool == "delete_file" then -- 2043
		local targetFile = getDecisionPath(params) -- 2047
		if targetFile == "" then -- 2047
			return {success = false, message = "delete_file requires target_file"} -- 2048
		end -- 2048
		params.target_file = targetFile -- 2049
		return {success = true, params = params} -- 2050
	end -- 2050
	if tool == "grep_files" then -- 2050
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2054
		if pattern == "" then -- 2054
			return {success = false, message = "grep_files requires pattern"} -- 2055
		end -- 2055
		params.pattern = pattern -- 2056
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2057
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2058
		return {success = true, params = params} -- 2059
	end -- 2059
	if tool == "search_dora_api" then -- 2059
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2063
		if pattern == "" then -- 2063
			return {success = false, message = "search_dora_api requires pattern"} -- 2064
		end -- 2064
		params.pattern = pattern -- 2065
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2066
		return {success = true, params = params} -- 2067
	end -- 2067
	if tool == "glob_files" then -- 2067
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2071
		return {success = true, params = params} -- 2072
	end -- 2072
	if tool == "build" then -- 2072
		local path = getDecisionPath(params) -- 2076
		if path ~= "" then -- 2076
			params.path = path -- 2078
		end -- 2078
		return {success = true, params = params} -- 2080
	end -- 2080
	if tool == "list_sub_agents" then -- 2080
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2084
		if status ~= "" then -- 2084
			params.status = status -- 2086
		end -- 2086
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2088
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2089
		if type(params.query) == "string" then -- 2089
			params.query = __TS__StringTrim(params.query) -- 2091
		end -- 2091
		return {success = true, params = params} -- 2093
	end -- 2093
	if tool == "spawn_sub_agent" then -- 2093
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2097
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2098
		if prompt == "" then -- 2098
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2099
		end -- 2099
		if title == "" then -- 2099
			return {success = false, message = "spawn_sub_agent requires title"} -- 2100
		end -- 2100
		params.prompt = prompt -- 2101
		params.title = title -- 2102
		if type(params.expectedOutput) == "string" then -- 2102
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2104
		end -- 2104
		if isArray(params.filesHint) then -- 2104
			params.filesHint = __TS__ArrayMap( -- 2107
				__TS__ArrayFilter( -- 2107
					params.filesHint, -- 2107
					function(____, item) return type(item) == "string" end -- 2108
				), -- 2108
				function(____, item) return sanitizeUTF8(item) end -- 2109
			) -- 2109
		end -- 2109
		return {success = true, params = params} -- 2111
	end -- 2111
	return {success = true, params = params} -- 2114
end -- 2114
function getAllowedToolsForRole(role) -- 2140
	return role == "main" and ({ -- 2141
		"read_file", -- 2142
		"edit_file", -- 2142
		"delete_file", -- 2142
		"grep_files", -- 2142
		"search_dora_api", -- 2142
		"glob_files", -- 2142
		"build", -- 2142
		"list_sub_agents", -- 2142
		"spawn_sub_agent", -- 2142
		"finish" -- 2142
	}) or ({ -- 2142
		"read_file", -- 2143
		"edit_file", -- 2143
		"delete_file", -- 2143
		"grep_files", -- 2143
		"search_dora_api", -- 2143
		"glob_files", -- 2143
		"build", -- 2143
		"finish" -- 2143
	}) -- 2143
end -- 2143
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2249
	if includeToolDefinitions == nil then -- 2249
		includeToolDefinitions = false -- 2249
	end -- 2249
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2250
	local sections = { -- 2253
		shared.promptPack.agentIdentityPrompt, -- 2254
		rolePrompt, -- 2255
		getReplyLanguageDirective(shared) -- 2256
	} -- 2256
	if shared.decisionMode == "tool_calling" then -- 2256
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2259
	end -- 2259
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2261
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2262
	if memoryContext ~= "" then -- 2262
		sections[#sections + 1] = memoryContext -- 2264
	end -- 2264
	if includeToolDefinitions then -- 2264
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2267
		if shared.decisionMode == "xml" then -- 2267
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2269
		end -- 2269
	end -- 2269
	local skillsSection = buildSkillsSection(shared) -- 2273
	if skillsSection ~= "" then -- 2273
		sections[#sections + 1] = skillsSection -- 2275
	end -- 2275
	return table.concat(sections, "\n\n") -- 2277
end -- 2277
function buildSkillsSection(shared) -- 2280
	local ____opt_38 = shared.skills -- 2280
	if not (____opt_38 and ____opt_38.loader) then -- 2280
		return "" -- 2282
	end -- 2282
	return shared.skills.loader:buildSkillsPromptSection() -- 2284
end -- 2284
function buildXmlDecisionInstruction(shared, feedback) -- 2405
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2406
end -- 2406
function executeToolAction(shared, action) -- 3744
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3744
		if shared.stopToken.stopped then -- 3744
			return ____awaiter_resolve( -- 3744
				nil, -- 3744
				{ -- 3746
					success = false, -- 3746
					message = getCancelledReason(shared) -- 3746
				} -- 3746
			) -- 3746
		end -- 3746
		local params = action.params -- 3748
		if action.tool == "read_file" then -- 3748
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3750
			if __TS__StringTrim(path) == "" then -- 3750
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3750
			end -- 3750
			local ____Tools_readFile_102 = Tools.readFile -- 3754
			local ____shared_workingDir_100 = shared.workingDir -- 3755
			local ____params_startLine_98 = params.startLine -- 3757
			if ____params_startLine_98 == nil then -- 3757
				____params_startLine_98 = 1 -- 3757
			end -- 3757
			local ____TS__Number_result_101 = __TS__Number(____params_startLine_98) -- 3757
			local ____params_endLine_99 = params.endLine -- 3758
			if ____params_endLine_99 == nil then -- 3758
				____params_endLine_99 = READ_FILE_DEFAULT_LIMIT -- 3758
			end -- 3758
			return ____awaiter_resolve( -- 3758
				nil, -- 3758
				____Tools_readFile_102( -- 3754
					____shared_workingDir_100, -- 3755
					path, -- 3756
					____TS__Number_result_101, -- 3757
					__TS__Number(____params_endLine_99), -- 3758
					shared.useChineseResponse and "zh" or "en" -- 3759
				) -- 3759
			) -- 3759
		end -- 3759
		if action.tool == "grep_files" then -- 3759
			local ____Tools_searchFiles_116 = Tools.searchFiles -- 3763
			local ____shared_workingDir_109 = shared.workingDir -- 3764
			local ____temp_110 = params.path or "" -- 3765
			local ____temp_111 = params.pattern or "" -- 3766
			local ____params_globs_112 = params.globs -- 3767
			local ____params_useRegex_113 = params.useRegex -- 3768
			local ____params_caseSensitive_114 = params.caseSensitive -- 3769
			local ____math_max_105 = math.max -- 3772
			local ____math_floor_104 = math.floor -- 3772
			local ____params_limit_103 = params.limit -- 3772
			if ____params_limit_103 == nil then -- 3772
				____params_limit_103 = SEARCH_FILES_LIMIT_DEFAULT -- 3772
			end -- 3772
			local ____math_max_105_result_115 = ____math_max_105( -- 3772
				1, -- 3772
				____math_floor_104(__TS__Number(____params_limit_103)) -- 3772
			) -- 3772
			local ____math_max_108 = math.max -- 3773
			local ____math_floor_107 = math.floor -- 3773
			local ____params_offset_106 = params.offset -- 3773
			if ____params_offset_106 == nil then -- 3773
				____params_offset_106 = 0 -- 3773
			end -- 3773
			local result = __TS__Await(____Tools_searchFiles_116({ -- 3763
				workDir = ____shared_workingDir_109, -- 3764
				path = ____temp_110, -- 3765
				pattern = ____temp_111, -- 3766
				globs = ____params_globs_112, -- 3767
				useRegex = ____params_useRegex_113, -- 3768
				caseSensitive = ____params_caseSensitive_114, -- 3769
				includeContent = true, -- 3770
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3771
				limit = ____math_max_105_result_115, -- 3772
				offset = ____math_max_108( -- 3773
					0, -- 3773
					____math_floor_107(__TS__Number(____params_offset_106)) -- 3773
				), -- 3773
				groupByFile = params.groupByFile == true -- 3774
			})) -- 3774
			return ____awaiter_resolve(nil, result) -- 3774
		end -- 3774
		if action.tool == "search_dora_api" then -- 3774
			local ____Tools_searchDoraAPI_124 = Tools.searchDoraAPI -- 3779
			local ____temp_120 = params.pattern or "" -- 3780
			local ____temp_121 = params.docSource or "api" -- 3781
			local ____temp_122 = shared.useChineseResponse and "zh" or "en" -- 3782
			local ____temp_123 = params.programmingLanguage or "ts" -- 3783
			local ____math_min_119 = math.min -- 3784
			local ____math_max_118 = math.max -- 3784
			local ____params_limit_117 = params.limit -- 3784
			if ____params_limit_117 == nil then -- 3784
				____params_limit_117 = 8 -- 3784
			end -- 3784
			local result = __TS__Await(____Tools_searchDoraAPI_124({ -- 3779
				pattern = ____temp_120, -- 3780
				docSource = ____temp_121, -- 3781
				docLanguage = ____temp_122, -- 3782
				programmingLanguage = ____temp_123, -- 3783
				limit = ____math_min_119( -- 3784
					SEARCH_DORA_API_LIMIT_MAX, -- 3784
					____math_max_118( -- 3784
						1, -- 3784
						__TS__Number(____params_limit_117) -- 3784
					) -- 3784
				), -- 3784
				useRegex = params.useRegex, -- 3785
				caseSensitive = false, -- 3786
				includeContent = true, -- 3787
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3788
			})) -- 3788
			return ____awaiter_resolve(nil, result) -- 3788
		end -- 3788
		if action.tool == "glob_files" then -- 3788
			local ____Tools_listFiles_131 = Tools.listFiles -- 3793
			local ____shared_workingDir_128 = shared.workingDir -- 3794
			local ____temp_129 = params.path or "" -- 3795
			local ____params_globs_130 = params.globs -- 3796
			local ____math_max_127 = math.max -- 3797
			local ____math_floor_126 = math.floor -- 3797
			local ____params_maxEntries_125 = params.maxEntries -- 3797
			if ____params_maxEntries_125 == nil then -- 3797
				____params_maxEntries_125 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3797
			end -- 3797
			local result = ____Tools_listFiles_131({ -- 3793
				workDir = ____shared_workingDir_128, -- 3794
				path = ____temp_129, -- 3795
				globs = ____params_globs_130, -- 3796
				maxEntries = ____math_max_127( -- 3797
					1, -- 3797
					____math_floor_126(__TS__Number(____params_maxEntries_125)) -- 3797
				) -- 3797
			}) -- 3797
			return ____awaiter_resolve(nil, result) -- 3797
		end -- 3797
		if action.tool == "delete_file" then -- 3797
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3802
			if __TS__StringTrim(targetFile) == "" then -- 3802
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3802
			end -- 3802
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3806
			if not result.success then -- 3806
				return ____awaiter_resolve(nil, result) -- 3806
			end -- 3806
			return ____awaiter_resolve(nil, { -- 3806
				success = true, -- 3814
				changed = true, -- 3815
				mode = "delete", -- 3816
				checkpointId = result.checkpointId, -- 3817
				checkpointSeq = result.checkpointSeq, -- 3818
				files = {{path = targetFile, op = "delete"}} -- 3819
			}) -- 3819
		end -- 3819
		if action.tool == "build" then -- 3819
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3823
			return ____awaiter_resolve(nil, result) -- 3823
		end -- 3823
		if action.tool == "spawn_sub_agent" then -- 3823
			if not shared.spawnSubAgent then -- 3823
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3823
			end -- 3823
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3823
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3823
			end -- 3823
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3836
				params.filesHint, -- 3837
				function(____, item) return type(item) == "string" end -- 3837
			) or nil -- 3837
			local result = __TS__Await(shared.spawnSubAgent({ -- 3839
				parentSessionId = shared.sessionId, -- 3840
				projectRoot = shared.workingDir, -- 3841
				title = type(params.title) == "string" and params.title or "Sub", -- 3842
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3843
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3844
				filesHint = filesHint -- 3845
			})) -- 3845
			if not result.success then -- 3845
				return ____awaiter_resolve(nil, result) -- 3845
			end -- 3845
			return ____awaiter_resolve(nil, { -- 3845
				success = true, -- 3851
				sessionId = result.sessionId, -- 3852
				taskId = result.taskId, -- 3853
				title = result.title, -- 3854
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3855
			}) -- 3855
		end -- 3855
		if action.tool == "list_sub_agents" then -- 3855
			if not shared.listSubAgents then -- 3855
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3855
			end -- 3855
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3855
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3855
			end -- 3855
			local result = __TS__Await(shared.listSubAgents({ -- 3865
				sessionId = shared.sessionId, -- 3866
				projectRoot = shared.workingDir, -- 3867
				status = type(params.status) == "string" and params.status or nil, -- 3868
				limit = type(params.limit) == "number" and params.limit or nil, -- 3869
				offset = type(params.offset) == "number" and params.offset or nil, -- 3870
				query = type(params.query) == "string" and params.query or nil -- 3871
			})) -- 3871
			return ____awaiter_resolve(nil, result) -- 3871
		end -- 3871
		if action.tool == "edit_file" then -- 3871
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3876
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3879
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3880
			if __TS__StringTrim(path) == "" then -- 3880
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3880
			end -- 3880
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3882
			return ____awaiter_resolve( -- 3882
				nil, -- 3882
				actionNode:exec({ -- 3883
					path = path, -- 3884
					oldStr = oldStr, -- 3885
					newStr = newStr, -- 3886
					taskId = shared.taskId, -- 3887
					workDir = shared.workingDir -- 3888
				}) -- 3888
			) -- 3888
		end -- 3888
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3888
	end) -- 3888
end -- 3888
function sanitizeToolActionResultForHistory(action, result) -- 3894
	if action.tool == "read_file" then -- 3894
		return sanitizeReadResultForHistory(action.tool, result) -- 3896
	end -- 3896
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3896
		return sanitizeSearchResultForHistory(action.tool, result) -- 3899
	end -- 3899
	if action.tool == "glob_files" then -- 3899
		return sanitizeListFilesResultForHistory(result) -- 3902
	end -- 3902
	if action.tool == "build" then -- 3902
		return sanitizeBuildResultForHistory(result) -- 3905
	end -- 3905
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 3905
		if result.success ~= true then -- 3905
			return result -- 3908
		end -- 3908
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 3908
			return result -- 3909
		end -- 3909
		if isArray(result.fileContext) then -- 3909
			return result -- 3910
		end -- 3910
		local contextLimits = { -- 3912
			fullContentChars = 12000, -- 3913
			previewChars = 4000, -- 3914
			diffChars = 8000, -- 3915
			totalChars = 24000, -- 3916
			maxFiles = 8 -- 3917
		} -- 3917
		local function truncateContextSnippet(sourceText, maxChars, label) -- 3919
			if maxChars <= 0 then -- 3919
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 3920
			end -- 3920
			if #sourceText <= maxChars then -- 3920
				return sourceText -- 3921
			end -- 3921
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 3922
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 3923
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 3924
		end -- 3919
		local function countLines(sourceText) -- 3926
			if sourceText == "" then -- 3926
				return 0 -- 3927
			end -- 3927
			return #__TS__StringSplit(sourceText, "\n") -- 3928
		end -- 3926
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 3930
			if beforeContent == afterContent then -- 3930
				return "" -- 3931
			end -- 3931
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 3932
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 3933
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 3935
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 3935
				firstChangedLine = firstChangedLine + 1 -- 3941
			end -- 3941
			local lastChangedBeforeLine = #beforeLines - 1 -- 3943
			local lastChangedAfterLine = #afterLines - 1 -- 3944
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 3944
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 3950
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 3951
			end -- 3951
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 3953
			local previewEndLine = math.max( -- 3954
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 3955
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 3956
			) -- 3956
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 3958
			do -- 3958
				local lineIndex = previewStartLine -- 3959
				while lineIndex <= previewEndLine do -- 3959
					do -- 3959
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 3960
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 3961
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 3962
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 3963
						if not beforeChanged and not afterChanged then -- 3963
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 3965
							if contextLine ~= nil then -- 3965
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 3966
							end -- 3966
							goto __continue633 -- 3967
						end -- 3967
						if beforeChanged and beforeLine ~= nil then -- 3967
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 3969
						end -- 3969
						if afterChanged and afterLine ~= nil then -- 3969
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 3970
						end -- 3970
					end -- 3970
					::__continue633:: -- 3970
					lineIndex = lineIndex + 1 -- 3959
				end -- 3959
			end -- 3959
			return truncateContextSnippet( -- 3972
				table.concat(unifiedDiffLines, "\n"), -- 3972
				maxChars, -- 3972
				"diff" -- 3972
			) -- 3972
		end -- 3930
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 3975
		if not checkpointDiff.success then -- 3975
			return result -- 3976
		end -- 3976
		local remainingContextBudget = contextLimits.totalChars -- 3977
		local fileContextItems = {} -- 3978
		local changedFiles = checkpointDiff.files -- 3979
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 3980
		do -- 3980
			local fileIndex = 0 -- 3981
			while fileIndex < maxContextFiles do -- 3981
				if remainingContextBudget <= 0 then -- 3981
					break -- 3982
				end -- 3982
				local changedFile = changedFiles[fileIndex + 1] -- 3983
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 3984
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 3985
				local contextItem = { -- 3986
					path = changedFile.path, -- 3987
					op = changedFile.op, -- 3988
					checkpointId = result.checkpointId, -- 3989
					checkpointSeq = result.checkpointSeq, -- 3990
					beforeExists = changedFile.beforeExists, -- 3991
					afterExists = changedFile.afterExists, -- 3992
					beforeBytes = #beforeContent, -- 3993
					afterBytes = #afterContent, -- 3994
					diffPreview = "", -- 3995
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 3996
					contentTruncated = false, -- 3997
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 3998
				} -- 3998
				if changedFile.afterExists then -- 3998
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 3998
						contextItem.afterContent = afterContent -- 4002
						remainingContextBudget = remainingContextBudget - #afterContent -- 4003
					else -- 4003
						contextItem.afterContentPreview = truncateContextSnippet( -- 4005
							afterContent, -- 4006
							math.min( -- 4007
								contextLimits.previewChars, -- 4007
								math.max(400, remainingContextBudget) -- 4007
							), -- 4007
							"afterContent" -- 4008
						) -- 4008
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4010
						contextItem.contentTruncated = true -- 4011
					end -- 4011
				end -- 4011
				local diffPreview = buildUnifiedDiffPreview( -- 4014
					changedFile.path, -- 4015
					beforeContent, -- 4016
					afterContent, -- 4017
					math.min( -- 4018
						contextLimits.diffChars, -- 4018
						math.max(400, remainingContextBudget) -- 4018
					) -- 4018
				) -- 4018
				contextItem.diffPreview = diffPreview -- 4020
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4021
				if not changedFile.afterExists and beforeContent ~= "" then -- 4021
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4023
						beforeContent, -- 4024
						math.min( -- 4025
							contextLimits.previewChars, -- 4025
							math.max(400, remainingContextBudget) -- 4025
						), -- 4025
						"beforeContent" -- 4026
					) -- 4026
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4028
					if #beforeContent > contextLimits.previewChars then -- 4028
						contextItem.contentTruncated = true -- 4029
					end -- 4029
				end -- 4029
				fileContextItems[#fileContextItems + 1] = contextItem -- 4031
				fileIndex = fileIndex + 1 -- 3981
			end -- 3981
		end -- 3981
		if #fileContextItems == 0 then -- 3981
			return result -- 4033
		end -- 4033
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4034
	end -- 4034
	return result -- 4041
end -- 4041
function emitAgentTaskFinishEvent(shared, success, message) -- 4208
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 4209
	emitAgentEvent(shared, { -- 4215
		type = "task_finished", -- 4216
		sessionId = shared.sessionId, -- 4217
		taskId = shared.taskId, -- 4218
		success = result.success, -- 4219
		message = result.message, -- 4220
		steps = result.steps -- 4221
	}) -- 4221
	return result -- 4223
end -- 4223
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
local function isToolAllowedForRole(role, tool) -- 1299
	return __TS__ArrayIndexOf( -- 1300
		getAllowedToolsForRole(role), -- 1300
		tool -- 1300
	) >= 0 -- 1300
end -- 1299
local PRE_EXEC_SAFE_TOOLS = { -- 1303
	"read_file", -- 1304
	"grep_files", -- 1305
	"search_dora_api", -- 1306
	"glob_files", -- 1307
	"list_sub_agents" -- 1308
} -- 1308
local function canPreExecuteTool(tool) -- 1311
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1312
end -- 1311
local function clearPreExecutedResults(shared) -- 1315
	shared.preExecutedResults = nil -- 1316
end -- 1315
local function startPreExecutedToolAction(shared, action) -- 1319
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1319
		local ____hasReturned, ____returnValue -- 1319
		local ____try = __TS__AsyncAwaiter(function() -- 1319
			____hasReturned = true -- 1321
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1321
			return -- 1321
		end) -- 1321
		____try = ____try.catch( -- 1321
			____try, -- 1321
			function(____, err) -- 1321
				return __TS__AsyncAwaiter(function() -- 1321
					local message = tostring(err) -- 1323
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1324
					____hasReturned = true -- 1325
					____returnValue = {success = false, message = message} -- 1325
					return -- 1325
				end) -- 1325
			end -- 1325
		) -- 1325
		__TS__Await(____try) -- 1320
		if ____hasReturned then -- 1320
			return ____awaiter_resolve(nil, ____returnValue) -- 1320
		end -- 1320
	end) -- 1320
end -- 1319
local function createPreExecutedToolResult(shared, action) -- 1329
	local cloneParamValue -- 1330
	cloneParamValue = function(value) -- 1330
		if value == nil then -- 1330
			return value -- 1331
		end -- 1331
		if isArray(value) then -- 1331
			return __TS__ArrayMap( -- 1333
				value, -- 1333
				function(____, item) return cloneParamValue(item) end -- 1333
			) -- 1333
		end -- 1333
		if type(value) == "table" then -- 1333
			local clone = {} -- 1336
			for key in pairs(value) do -- 1337
				clone[key] = cloneParamValue(value[key]) -- 1338
			end -- 1338
			return clone -- 1340
		end -- 1340
		return value -- 1342
	end -- 1330
	local params = cloneParamValue(action.params) -- 1344
	local areParamValuesEqual -- 1345
	areParamValuesEqual = function(left, right) -- 1345
		if left == right then -- 1345
			return true -- 1346
		end -- 1346
		if left == nil or right == nil then -- 1346
			return false -- 1347
		end -- 1347
		if isArray(left) or isArray(right) then -- 1347
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1347
				return false -- 1349
			end -- 1349
			do -- 1349
				local i = 0 -- 1350
				while i < #left do -- 1350
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1350
						return false -- 1351
					end -- 1351
					i = i + 1 -- 1350
				end -- 1350
			end -- 1350
			return true -- 1353
		end -- 1353
		if type(left) == "table" and type(right) == "table" then -- 1353
			local leftCount = 0 -- 1356
			for key in pairs(left) do -- 1357
				leftCount = leftCount + 1 -- 1358
				if not areParamValuesEqual(left[key], right[key]) then -- 1358
					return false -- 1363
				end -- 1363
			end -- 1363
			local rightCount = 0 -- 1366
			for key in pairs(right) do -- 1367
				rightCount = rightCount + 1 -- 1368
			end -- 1368
			return leftCount == rightCount -- 1370
		end -- 1370
		return false -- 1372
	end -- 1345
	return { -- 1374
		action = action, -- 1375
		matches = function(self, nextAction) -- 1376
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1377
		end, -- 1376
		promise = startPreExecutedToolAction(shared, action) -- 1379
	} -- 1379
end -- 1329
local function executeToolActionWithPreExecution(shared, action) -- 1383
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1383
		local ____opt_5 = shared.preExecutedResults -- 1383
		local preResult = ____opt_5 and ____opt_5:get(action.toolCallId) -- 1384
		if preResult then -- 1384
			local ____opt_7 = shared.preExecutedResults -- 1384
			if ____opt_7 ~= nil then -- 1384
				____opt_7:delete(action.toolCallId) -- 1386
			end -- 1386
			if preResult:matches(action) then -- 1386
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1388
				return ____awaiter_resolve( -- 1388
					nil, -- 1388
					__TS__Await(preResult.promise) -- 1389
				) -- 1389
			end -- 1389
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1391
		end -- 1391
		return ____awaiter_resolve( -- 1391
			nil, -- 1391
			executeToolAction(shared, action) -- 1393
		) -- 1393
	end) -- 1393
end -- 1383
local function maybeCompressHistory(shared) -- 1396
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1396
		local ____shared_9 = shared -- 1397
		local memory = ____shared_9.memory -- 1397
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1398
		local changed = false -- 1399
		do -- 1399
			local round = 0 -- 1400
			while round < maxRounds do -- 1400
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1401
				local activeMessages = getActiveConversationMessages(shared) -- 1402
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1406
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1406
					if changed then -- 1406
						persistHistoryState(shared) -- 1415
					end -- 1415
					return ____awaiter_resolve(nil) -- 1415
				end -- 1415
				local compressionRound = round + 1 -- 1419
				shared.step = shared.step + 1 -- 1420
				local stepId = shared.step -- 1421
				local pendingMessages = #activeMessages -- 1422
				emitAgentEvent( -- 1423
					shared, -- 1423
					{ -- 1423
						type = "memory_compression_started", -- 1424
						sessionId = shared.sessionId, -- 1425
						taskId = shared.taskId, -- 1426
						step = stepId, -- 1427
						tool = "compress_memory", -- 1428
						reason = getMemoryCompressionStartReason(shared), -- 1429
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1430
					} -- 1430
				) -- 1430
				local result = __TS__Await(memory.compressor:compress( -- 1436
					activeMessages, -- 1437
					shared.llmOptions, -- 1438
					shared.llmMaxTry, -- 1439
					shared.decisionMode, -- 1440
					{ -- 1441
						onInput = function(____, phase, messages, options) -- 1442
							saveStepLLMDebugInput( -- 1443
								shared, -- 1443
								stepId, -- 1443
								phase, -- 1443
								messages, -- 1443
								options -- 1443
							) -- 1443
						end, -- 1442
						onOutput = function(____, phase, text, meta) -- 1445
							saveStepLLMDebugOutput( -- 1446
								shared, -- 1446
								stepId, -- 1446
								phase, -- 1446
								text, -- 1446
								meta -- 1446
							) -- 1446
						end -- 1445
					}, -- 1445
					"default", -- 1449
					systemPrompt, -- 1450
					toolDefinitions -- 1451
				)) -- 1451
				if not (result and result.success and result.compressedCount > 0) then -- 1451
					emitAgentEvent( -- 1454
						shared, -- 1454
						{ -- 1454
							type = "memory_compression_finished", -- 1455
							sessionId = shared.sessionId, -- 1456
							taskId = shared.taskId, -- 1457
							step = stepId, -- 1458
							tool = "compress_memory", -- 1459
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1460
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1464
						} -- 1464
					) -- 1464
					if changed then -- 1464
						persistHistoryState(shared) -- 1472
					end -- 1472
					return ____awaiter_resolve(nil) -- 1472
				end -- 1472
				local effectiveCompressedCount = math.max( -- 1476
					0, -- 1477
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1478
				) -- 1478
				if effectiveCompressedCount <= 0 then -- 1478
					if changed then -- 1478
						persistHistoryState(shared) -- 1482
					end -- 1482
					return ____awaiter_resolve(nil) -- 1482
				end -- 1482
				emitAgentEvent( -- 1486
					shared, -- 1486
					{ -- 1486
						type = "memory_compression_finished", -- 1487
						sessionId = shared.sessionId, -- 1488
						taskId = shared.taskId, -- 1489
						step = stepId, -- 1490
						tool = "compress_memory", -- 1491
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1492
						result = { -- 1493
							success = true, -- 1494
							round = compressionRound, -- 1495
							compressedCount = effectiveCompressedCount, -- 1496
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1497
						} -- 1497
					} -- 1497
				) -- 1497
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1500
				changed = true -- 1501
				Log( -- 1502
					"Info", -- 1502
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1502
				) -- 1502
				round = round + 1 -- 1400
			end -- 1400
		end -- 1400
		if changed then -- 1400
			persistHistoryState(shared) -- 1505
		end -- 1505
	end) -- 1505
end -- 1396
local function compactAllHistory(shared) -- 1509
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1509
		local ____shared_16 = shared -- 1510
		local memory = ____shared_16.memory -- 1510
		local rounds = 0 -- 1511
		local totalCompressed = 0 -- 1512
		while getActiveRealMessageCount(shared) > 0 do -- 1512
			if shared.stopToken.stopped then -- 1512
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1515
				return ____awaiter_resolve( -- 1515
					nil, -- 1515
					emitAgentTaskFinishEvent( -- 1516
						shared, -- 1516
						false, -- 1516
						getCancelledReason(shared) -- 1516
					) -- 1516
				) -- 1516
			end -- 1516
			rounds = rounds + 1 -- 1518
			shared.step = shared.step + 1 -- 1519
			local stepId = shared.step -- 1520
			local activeMessages = getActiveConversationMessages(shared) -- 1521
			local pendingMessages = #activeMessages -- 1522
			emitAgentEvent( -- 1523
				shared, -- 1523
				{ -- 1523
					type = "memory_compression_started", -- 1524
					sessionId = shared.sessionId, -- 1525
					taskId = shared.taskId, -- 1526
					step = stepId, -- 1527
					tool = "compress_memory", -- 1528
					reason = getMemoryCompressionStartReason(shared), -- 1529
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1530
				} -- 1530
			) -- 1530
			local result = __TS__Await(memory.compressor:compress( -- 1537
				activeMessages, -- 1538
				shared.llmOptions, -- 1539
				shared.llmMaxTry, -- 1540
				shared.decisionMode, -- 1541
				{ -- 1542
					onInput = function(____, phase, messages, options) -- 1543
						saveStepLLMDebugInput( -- 1544
							shared, -- 1544
							stepId, -- 1544
							phase, -- 1544
							messages, -- 1544
							options -- 1544
						) -- 1544
					end, -- 1543
					onOutput = function(____, phase, text, meta) -- 1546
						saveStepLLMDebugOutput( -- 1547
							shared, -- 1547
							stepId, -- 1547
							phase, -- 1547
							text, -- 1547
							meta -- 1547
						) -- 1547
					end -- 1546
				}, -- 1546
				"budget_max" -- 1550
			)) -- 1550
			if not (result and result.success and result.compressedCount > 0) then -- 1550
				emitAgentEvent( -- 1553
					shared, -- 1553
					{ -- 1553
						type = "memory_compression_finished", -- 1554
						sessionId = shared.sessionId, -- 1555
						taskId = shared.taskId, -- 1556
						step = stepId, -- 1557
						tool = "compress_memory", -- 1558
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1559
						result = { -- 1563
							success = false, -- 1564
							rounds = rounds, -- 1565
							error = result and result.error or "compression returned no changes", -- 1566
							compressedCount = result and result.compressedCount or 0, -- 1567
							fullCompaction = true -- 1568
						} -- 1568
					} -- 1568
				) -- 1568
				return ____awaiter_resolve( -- 1568
					nil, -- 1568
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1571
				) -- 1571
			end -- 1571
			local effectiveCompressedCount = math.max( -- 1576
				0, -- 1577
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1578
			) -- 1578
			if effectiveCompressedCount <= 0 then -- 1578
				return ____awaiter_resolve( -- 1578
					nil, -- 1578
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1581
				) -- 1581
			end -- 1581
			emitAgentEvent( -- 1588
				shared, -- 1588
				{ -- 1588
					type = "memory_compression_finished", -- 1589
					sessionId = shared.sessionId, -- 1590
					taskId = shared.taskId, -- 1591
					step = stepId, -- 1592
					tool = "compress_memory", -- 1593
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1594
					result = { -- 1595
						success = true, -- 1596
						round = rounds, -- 1597
						compressedCount = effectiveCompressedCount, -- 1598
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1599
						fullCompaction = true -- 1600
					} -- 1600
				} -- 1600
			) -- 1600
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1603
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1604
			persistHistoryState(shared) -- 1605
			Log( -- 1606
				"Info", -- 1606
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1606
			) -- 1606
		end -- 1606
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1608
		return ____awaiter_resolve( -- 1608
			nil, -- 1608
			emitAgentTaskFinishEvent( -- 1609
				shared, -- 1610
				true, -- 1611
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1612
			) -- 1612
		) -- 1612
	end) -- 1612
end -- 1509
local function clearSessionHistory(shared) -- 1618
	shared.messages = {} -- 1619
	shared.lastConsolidatedIndex = 0 -- 1620
	shared.carryMessageIndex = nil -- 1621
	persistHistoryState(shared) -- 1622
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1623
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1624
end -- 1618
local function isKnownToolName(name) -- 1633
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1634
end -- 1633
local function appendConversationMessage(shared, message) -- 1727
	local ____shared_messages_25 = shared.messages -- 1727
	____shared_messages_25[#____shared_messages_25 + 1] = __TS__ObjectAssign( -- 1728
		{}, -- 1728
		message, -- 1729
		{ -- 1728
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1730
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1731
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1732
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1733
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1734
		} -- 1734
	) -- 1734
end -- 1727
local function ensureToolCallId(toolCallId) -- 1738
	if toolCallId and toolCallId ~= "" then -- 1738
		return toolCallId -- 1739
	end -- 1739
	return createLocalToolCallId() -- 1740
end -- 1738
local function appendToolResultMessage(shared, action) -- 1743
	appendConversationMessage( -- 1744
		shared, -- 1744
		{ -- 1744
			role = "tool", -- 1745
			tool_call_id = action.toolCallId, -- 1746
			name = action.tool, -- 1747
			content = action.result and toJson(action.result, false) or "" -- 1748
		} -- 1748
	) -- 1748
end -- 1743
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1752
	appendConversationMessage( -- 1758
		shared, -- 1758
		{ -- 1758
			role = "assistant", -- 1759
			content = content or "", -- 1760
			reasoning_content = reasoningContent, -- 1761
			tool_calls = __TS__ArrayMap( -- 1762
				actions, -- 1762
				function(____, action) return { -- 1762
					id = action.toolCallId, -- 1763
					type = "function", -- 1764
					["function"] = { -- 1765
						name = action.tool, -- 1766
						arguments = toJson(action.params, false) -- 1767
					} -- 1767
				} end -- 1767
			) -- 1767
		} -- 1767
	) -- 1767
end -- 1752
local function parseXMLToolCallObjectFromText(text) -- 1773
	local children = parseXMLObjectFromText(text, "tool_call") -- 1774
	if not children.success then -- 1774
		return children -- 1775
	end -- 1775
	local rawObj = children.obj -- 1776
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1777
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1778
	if not params.success then -- 1778
		return {success = false, message = params.message} -- 1782
	end -- 1782
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1784
end -- 1773
local function llm(shared, messages, phase) -- 1804
	if phase == nil then -- 1804
		phase = "decision_xml" -- 1807
	end -- 1807
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1807
		local stepId = shared.step + 1 -- 1809
		emitLLMContextMetrics( -- 1810
			shared, -- 1810
			stepId, -- 1810
			phase, -- 1810
			messages, -- 1810
			shared.llmOptions -- 1810
		) -- 1810
		saveStepLLMDebugInput( -- 1811
			shared, -- 1811
			stepId, -- 1811
			phase, -- 1811
			messages, -- 1811
			shared.llmOptions -- 1811
		) -- 1811
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1812
		if res.success then -- 1812
			local ____opt_28 = res.response.choices -- 1812
			local ____opt_26 = ____opt_28 and ____opt_28[1] -- 1812
			local message = ____opt_26 and ____opt_26.message -- 1814
			local text = message and message.content -- 1815
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1816
			if text then -- 1816
				saveStepLLMDebugOutput( -- 1820
					shared, -- 1820
					stepId, -- 1820
					phase, -- 1820
					text, -- 1820
					{success = true} -- 1820
				) -- 1820
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1820
			else -- 1820
				saveStepLLMDebugOutput( -- 1823
					shared, -- 1823
					stepId, -- 1823
					phase, -- 1823
					"empty LLM response", -- 1823
					{success = false} -- 1823
				) -- 1823
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1823
			end -- 1823
		else -- 1823
			saveStepLLMDebugOutput( -- 1827
				shared, -- 1827
				stepId, -- 1827
				phase, -- 1827
				res.raw or res.message, -- 1827
				{success = false} -- 1827
			) -- 1827
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1827
		end -- 1827
	end) -- 1827
end -- 1804
local function isDecisionBatchSuccess(result) -- 1851
	return result.kind == "batch" -- 1852
end -- 1851
local function parseDecisionObject(rawObj) -- 1855
	if type(rawObj.tool) ~= "string" then -- 1855
		return {success = false, message = "missing tool"} -- 1856
	end -- 1856
	local tool = rawObj.tool -- 1857
	if not isKnownToolName(tool) then -- 1857
		return {success = false, message = "unknown tool: " .. tool} -- 1859
	end -- 1859
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1861
	if tool ~= "finish" and (not reason or reason == "") then -- 1861
		return {success = false, message = tool .. " requires top-level reason"} -- 1865
	end -- 1865
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1867
	return {success = true, tool = tool, params = params, reason = reason} -- 1868
end -- 1855
local function parseDecisionToolCall(functionName, rawObj) -- 1876
	if not isKnownToolName(functionName) then -- 1876
		return {success = false, message = "unknown tool: " .. functionName} -- 1878
	end -- 1878
	if rawObj == nil then -- 1878
		return {success = true, tool = functionName, params = {}} -- 1881
	end -- 1881
	if not isRecord(rawObj) then -- 1881
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1884
	end -- 1884
	return {success = true, tool = functionName, params = rawObj} -- 1886
end -- 1876
local function parseToolCallArguments(functionName, argsText) -- 1893
	local trimmedArgs = __TS__StringTrim(argsText) -- 1894
	if trimmedArgs == "" then -- 1894
		return {} -- 1896
	end -- 1896
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1898
	if err ~= nil or rawObj == nil then -- 1898
		return { -- 1900
			success = false, -- 1901
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1902
			raw = argsText -- 1903
		} -- 1903
	end -- 1903
	local encodedRaw = safeJsonEncode(rawObj) -- 1906
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1906
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1908
	end -- 1908
	return rawObj -- 1914
end -- 1893
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1917
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1925
	if isRecord(rawArgs) and rawArgs.success == false then -- 1925
		return rawArgs -- 1927
	end -- 1927
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1929
	if not decision.success then -- 1929
		return {success = false, message = decision.message, raw = argsText} -- 1931
	end -- 1931
	local validation = validateDecision(decision.tool, decision.params) -- 1937
	if not validation.success then -- 1937
		return {success = false, message = validation.message, raw = argsText} -- 1939
	end -- 1939
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1939
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1946
	end -- 1946
	decision.params = validation.params -- 1952
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1953
	decision.reason = reason -- 1954
	decision.reasoningContent = reasoningContent -- 1955
	return decision -- 1956
end -- 1917
local function createPreExecutableActionFromStream(shared, toolCall) -- 1959
	local ____opt_34 = toolCall["function"] -- 1959
	local functionName = ____opt_34 and ____opt_34.name -- 1960
	local ____opt_36 = toolCall["function"] -- 1960
	local argsText = ____opt_36 and ____opt_36.arguments or "" -- 1961
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1962
	if not functionName or not toolCallId then -- 1962
		return nil -- 1963
	end -- 1963
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1964
	if isRecord(rawArgs) and rawArgs.success == false then -- 1964
		return nil -- 1965
	end -- 1965
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1966
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1966
		return nil -- 1967
	end -- 1967
	local validation = validateDecision(decision.tool, decision.params) -- 1968
	if not validation.success then -- 1968
		return nil -- 1969
	end -- 1969
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1969
		return nil -- 1970
	end -- 1970
	return { -- 1971
		step = shared.step + 1, -- 1972
		toolCallId = toolCallId, -- 1973
		tool = decision.tool, -- 1974
		reason = "", -- 1975
		params = validation.params, -- 1976
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1977
	} -- 1977
end -- 1959
local function createFunctionToolSchema(name, description, properties, required) -- 2117
	if required == nil then -- 2117
		required = {} -- 2121
	end -- 2121
	local parameters = {type = "object", properties = properties} -- 2123
	if #required > 0 then -- 2123
		parameters.required = required -- 2128
	end -- 2128
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2130
end -- 2117
local function buildDecisionToolSchema(shared) -- 2146
	local allowed = getAllowedToolsForRole(shared.role) -- 2147
	local tools = { -- 2148
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2149
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2159
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2169
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2177
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2181
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2182
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2183
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2184
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2185
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2186
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2187
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2188
		}, {"pattern"}), -- 2188
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2192
		createFunctionToolSchema( -- 2201
			"search_dora_api", -- 2202
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2202
			{ -- 2204
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2205
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2206
				programmingLanguage = {type = "string", enum = { -- 2207
					"ts", -- 2209
					"tsx", -- 2209
					"lua", -- 2209
					"yue", -- 2209
					"teal", -- 2209
					"tl", -- 2209
					"wa" -- 2209
				}, description = "Preferred language variant to search."}, -- 2209
				limit = { -- 2212
					type = "number", -- 2212
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2212
				}, -- 2212
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2213
			}, -- 2213
			{"pattern"} -- 2215
		), -- 2215
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2217
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2224
			"active_or_recent", -- 2228
			"running", -- 2228
			"done", -- 2228
			"failed", -- 2228
			"all" -- 2228
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2228
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2234
	} -- 2234
	return __TS__ArrayFilter( -- 2246
		tools, -- 2246
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2246
	) -- 2246
end -- 2146
local function sanitizeMessagesForLLMInput(messages) -- 2287
	local sanitized = {} -- 2288
	local droppedAssistantToolCalls = 0 -- 2289
	local droppedToolResults = 0 -- 2290
	do -- 2290
		local i = 0 -- 2291
		while i < #messages do -- 2291
			do -- 2291
				local message = messages[i + 1] -- 2292
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2292
					local requiredIds = {} -- 2294
					do -- 2294
						local j = 0 -- 2295
						while j < #message.tool_calls do -- 2295
							local toolCall = message.tool_calls[j + 1] -- 2296
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2297
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2297
								requiredIds[#requiredIds + 1] = id -- 2299
							end -- 2299
							j = j + 1 -- 2295
						end -- 2295
					end -- 2295
					if #requiredIds == 0 then -- 2295
						sanitized[#sanitized + 1] = message -- 2303
						goto __continue364 -- 2304
					end -- 2304
					local matchedIds = {} -- 2306
					local matchedTools = {} -- 2307
					local j = i + 1 -- 2308
					while j < #messages do -- 2308
						local toolMessage = messages[j + 1] -- 2310
						if toolMessage.role ~= "tool" then -- 2310
							break -- 2311
						end -- 2311
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2312
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2312
							matchedIds[toolCallId] = true -- 2314
							matchedTools[#matchedTools + 1] = toolMessage -- 2315
						else -- 2315
							droppedToolResults = droppedToolResults + 1 -- 2317
						end -- 2317
						j = j + 1 -- 2319
					end -- 2319
					local complete = true -- 2321
					do -- 2321
						local j = 0 -- 2322
						while j < #requiredIds do -- 2322
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2322
								complete = false -- 2324
								break -- 2325
							end -- 2325
							j = j + 1 -- 2322
						end -- 2322
					end -- 2322
					if complete then -- 2322
						__TS__ArrayPush( -- 2329
							sanitized, -- 2329
							message, -- 2329
							table.unpack(matchedTools) -- 2329
						) -- 2329
					else -- 2329
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2331
						droppedToolResults = droppedToolResults + #matchedTools -- 2332
					end -- 2332
					i = j - 1 -- 2334
					goto __continue364 -- 2335
				end -- 2335
				if message.role == "tool" then -- 2335
					droppedToolResults = droppedToolResults + 1 -- 2338
					goto __continue364 -- 2339
				end -- 2339
				sanitized[#sanitized + 1] = message -- 2341
			end -- 2341
			::__continue364:: -- 2341
			i = i + 1 -- 2291
		end -- 2291
	end -- 2291
	return sanitized -- 2343
end -- 2287
local function getUnconsolidatedMessages(shared) -- 2346
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2347
end -- 2346
local function getFinalDecisionTurnPrompt(shared) -- 2350
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2351
end -- 2350
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2356
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2356
		return messages -- 2357
	end -- 2357
	local next = __TS__ArrayMap( -- 2358
		messages, -- 2358
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2358
	) -- 2358
	do -- 2358
		local i = #next - 1 -- 2359
		while i >= 0 do -- 2359
			do -- 2359
				local message = next[i + 1] -- 2360
				if message.role ~= "assistant" and message.role ~= "user" then -- 2360
					goto __continue386 -- 2361
				end -- 2361
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2362
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2363
				return next -- 2366
			end -- 2366
			::__continue386:: -- 2366
			i = i - 1 -- 2359
		end -- 2359
	end -- 2359
	next[#next + 1] = {role = "user", content = prompt} -- 2368
	return next -- 2369
end -- 2356
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2372
	if attempt == nil then -- 2372
		attempt = 1 -- 2375
	end -- 2375
	if decisionMode == nil then -- 2375
		decisionMode = shared.decisionMode -- 2377
	end -- 2377
	local messages = { -- 2379
		{ -- 2380
			role = "system", -- 2380
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2380
		}, -- 2380
		table.unpack(getUnconsolidatedMessages(shared)) -- 2381
	} -- 2381
	if shared.step + 1 >= shared.maxSteps then -- 2381
		messages = appendPromptToLatestDecisionMessage( -- 2384
			messages, -- 2384
			getFinalDecisionTurnPrompt(shared) -- 2384
		) -- 2384
	end -- 2384
	if lastError and lastError ~= "" then -- 2384
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2387
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2387
			retryHeader = retryHeader .. "\nYour previous response spent the token budget on reasoning and ended before any tool call. Do not continue that reasoning. Immediately emit one valid function tool call with compact arguments." -- 2391
		end -- 2391
		messages[#messages + 1] = { -- 2393
			role = "user", -- 2394
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2395
		} -- 2395
	end -- 2395
	return messages -- 2402
end -- 2372
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2409
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2416
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2417
	local repairPrompt = replacePromptVars( -- 2425
		shared.promptPack.xmlDecisionRepairPrompt, -- 2425
		{ -- 2425
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2426
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2427
			CANDIDATE_SECTION = candidateSection, -- 2428
			LAST_ERROR = lastError, -- 2429
			ATTEMPT = tostring(attempt) -- 2430
		} -- 2430
	) -- 2430
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2432
end -- 2409
local function tryParseAndValidateDecision(rawText) -- 2444
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2445
	if not parsed.success then -- 2445
		return {success = false, message = parsed.message, raw = rawText} -- 2447
	end -- 2447
	local decision = parseDecisionObject(parsed.obj) -- 2449
	if not decision.success then -- 2449
		return {success = false, message = decision.message, raw = rawText} -- 2451
	end -- 2451
	local validation = validateDecision(decision.tool, decision.params) -- 2453
	if not validation.success then -- 2453
		return {success = false, message = validation.message, raw = rawText} -- 2455
	end -- 2455
	decision.params = validation.params -- 2457
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2458
	return decision -- 2459
end -- 2444
local function normalizeLineEndings(text) -- 2462
	local res = string.gsub(text, "\r\n", "\n") -- 2463
	res = string.gsub(res, "\r", "\n") -- 2464
	return res -- 2465
end -- 2462
local function countOccurrences(text, searchStr) -- 2468
	if searchStr == "" then -- 2468
		return 0 -- 2469
	end -- 2469
	local count = 0 -- 2470
	local pos = 0 -- 2471
	while true do -- 2471
		local idx = (string.find( -- 2473
			text, -- 2473
			searchStr, -- 2473
			math.max(pos + 1, 1), -- 2473
			true -- 2473
		) or 0) - 1 -- 2473
		if idx < 0 then -- 2473
			break -- 2474
		end -- 2474
		count = count + 1 -- 2475
		pos = idx + #searchStr -- 2476
	end -- 2476
	return count -- 2478
end -- 2468
local function replaceFirst(text, oldStr, newStr) -- 2481
	if oldStr == "" then -- 2481
		return text -- 2482
	end -- 2482
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2483
	if idx < 0 then -- 2483
		return text -- 2484
	end -- 2484
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2485
end -- 2481
local function splitLines(text) -- 2488
	return __TS__StringSplit(text, "\n") -- 2489
end -- 2488
local function getLeadingWhitespace(text) -- 2492
	local i = 0 -- 2493
	while i < #text do -- 2493
		local ch = __TS__StringAccess(text, i) -- 2495
		if ch ~= " " and ch ~= "\t" then -- 2495
			break -- 2496
		end -- 2496
		i = i + 1 -- 2497
	end -- 2497
	return __TS__StringSubstring(text, 0, i) -- 2499
end -- 2492
local function getCommonIndentPrefix(lines) -- 2502
	local common -- 2503
	do -- 2503
		local i = 0 -- 2504
		while i < #lines do -- 2504
			do -- 2504
				local line = lines[i + 1] -- 2505
				if __TS__StringTrim(line) == "" then -- 2505
					goto __continue412 -- 2506
				end -- 2506
				local indent = getLeadingWhitespace(line) -- 2507
				if common == nil then -- 2507
					common = indent -- 2509
					goto __continue412 -- 2510
				end -- 2510
				local j = 0 -- 2512
				local maxLen = math.min(#common, #indent) -- 2513
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2513
					j = j + 1 -- 2515
				end -- 2515
				common = __TS__StringSubstring(common, 0, j) -- 2517
				if common == "" then -- 2517
					break -- 2518
				end -- 2518
			end -- 2518
			::__continue412:: -- 2518
			i = i + 1 -- 2504
		end -- 2504
	end -- 2504
	return common or "" -- 2520
end -- 2502
local function removeIndentPrefix(line, indent) -- 2523
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2523
		return __TS__StringSubstring(line, #indent) -- 2525
	end -- 2525
	local lineIndent = getLeadingWhitespace(line) -- 2527
	local j = 0 -- 2528
	local maxLen = math.min(#lineIndent, #indent) -- 2529
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2529
		j = j + 1 -- 2531
	end -- 2531
	return __TS__StringSubstring(line, j) -- 2533
end -- 2523
local function dedentLines(lines) -- 2536
	local indent = getCommonIndentPrefix(lines) -- 2537
	return { -- 2538
		indent = indent, -- 2539
		lines = __TS__ArrayMap( -- 2540
			lines, -- 2540
			function(____, line) return removeIndentPrefix(line, indent) end -- 2540
		) -- 2540
	} -- 2540
end -- 2536
local function joinLines(lines) -- 2544
	return table.concat(lines, "\n") -- 2545
end -- 2544
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2548
	local function findWhitespaceTolerantReplacement() -- 2553
		local function foldWhitespace(text, withMap) -- 2555
			local parts = {} -- 2556
			local map = {} -- 2557
			local i = 0 -- 2558
			while i < #text do -- 2558
				local ch = __TS__StringAccess(text, i) -- 2560
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2560
					local start = i -- 2562
					while i < #text do -- 2562
						local next = __TS__StringAccess(text, i) -- 2564
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2564
							break -- 2565
						end -- 2565
						i = i + 1 -- 2566
					end -- 2566
					parts[#parts + 1] = " " -- 2568
					if withMap then -- 2568
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2569
					end -- 2569
				else -- 2569
					parts[#parts + 1] = ch -- 2571
					if withMap then -- 2571
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2572
					end -- 2572
					i = i + 1 -- 2573
				end -- 2573
			end -- 2573
			return { -- 2576
				text = table.concat(parts, ""), -- 2576
				map = map -- 2576
			} -- 2576
		end -- 2555
		local foldedContent = foldWhitespace(content, true) -- 2578
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2579
		if foldedOld == "" then -- 2579
			return {success = false, message = "old_str not found in file"} -- 2581
		end -- 2581
		local matches = {} -- 2583
		local pos = 0 -- 2584
		while true do -- 2584
			local idx = (string.find( -- 2586
				foldedContent.text, -- 2586
				foldedOld, -- 2586
				math.max(pos + 1, 1), -- 2586
				true -- 2586
			) or 0) - 1 -- 2586
			if idx < 0 then -- 2586
				break -- 2587
			end -- 2587
			local lastIdx = idx + #foldedOld - 1 -- 2588
			local startMap = foldedContent.map[idx + 1] -- 2589
			local endMap = foldedContent.map[lastIdx + 1] -- 2590
			if startMap ~= nil and endMap ~= nil then -- 2590
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2592
			end -- 2592
			pos = idx + #foldedOld -- 2594
		end -- 2594
		if #matches == 0 then -- 2594
			return {success = false, message = "old_str not found in file"} -- 2597
		end -- 2597
		if #matches > 1 then -- 2597
			return { -- 2600
				success = false, -- 2601
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2602
			} -- 2602
		end -- 2602
		local match = matches[1] -- 2605
		return { -- 2606
			success = true, -- 2607
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2608
		} -- 2608
	end -- 2553
	local contentLines = splitLines(content) -- 2611
	local oldLines = splitLines(oldStr) -- 2612
	if #oldLines == 0 then -- 2612
		return {success = false, message = "old_str not found in file"} -- 2614
	end -- 2614
	local dedentedOld = dedentLines(oldLines) -- 2616
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2617
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2618
	local matches = {} -- 2619
	do -- 2619
		local start = 0 -- 2620
		while start <= #contentLines - #oldLines do -- 2620
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2621
			local dedentedCandidate = dedentLines(candidateLines) -- 2622
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2622
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2624
			end -- 2624
			start = start + 1 -- 2620
		end -- 2620
	end -- 2620
	if #matches == 0 then -- 2620
		return findWhitespaceTolerantReplacement() -- 2632
	end -- 2632
	if #matches > 1 then -- 2632
		return { -- 2635
			success = false, -- 2636
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2637
		} -- 2637
	end -- 2637
	local match = matches[1] -- 2640
	local rebuiltNewLines = __TS__ArrayMap( -- 2641
		dedentedNew.lines, -- 2641
		function(____, line) return line == "" and "" or match.indent .. line end -- 2641
	) -- 2641
	local ____array_42 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2641
	__TS__SparseArrayPush( -- 2641
		____array_42, -- 2641
		table.unpack(rebuiltNewLines) -- 2644
	) -- 2644
	__TS__SparseArrayPush( -- 2644
		____array_42, -- 2644
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2645
	) -- 2645
	local nextLines = {__TS__SparseArraySpread(____array_42)} -- 2642
	return { -- 2647
		success = true, -- 2647
		content = joinLines(nextLines) -- 2647
	} -- 2647
end -- 2548
local MainDecisionAgent = __TS__Class() -- 2650
MainDecisionAgent.name = "MainDecisionAgent" -- 2650
__TS__ClassExtends(MainDecisionAgent, Node) -- 2650
function MainDecisionAgent.prototype.prep(self, shared) -- 2651
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2651
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2651
			return ____awaiter_resolve(nil, {shared = shared}) -- 2651
		end -- 2651
		__TS__Await(maybeCompressHistory(shared)) -- 2656
		return ____awaiter_resolve(nil, {shared = shared}) -- 2656
	end) -- 2656
end -- 2651
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2661
	local preExecuted = shared.preExecutedResults -- 2662
	if not preExecuted or preExecuted.size == 0 then -- 2662
		return nil -- 2663
	end -- 2663
	local decisions = {} -- 2664
	preExecuted:forEach(function(____, preResult) -- 2665
		local action = preResult.action -- 2666
		decisions[#decisions + 1] = { -- 2667
			success = true, -- 2668
			tool = action.tool, -- 2669
			params = action.params, -- 2670
			toolCallId = action.toolCallId, -- 2671
			reason = action.reason, -- 2672
			reasoningContent = action.reasoningContent -- 2673
		} -- 2673
	end) -- 2665
	if #decisions == 0 then -- 2665
		return nil -- 2676
	end -- 2676
	Log( -- 2677
		"Warn", -- 2677
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2677
			__TS__ArrayMap( -- 2677
				decisions, -- 2677
				function(____, decision) return decision.tool end -- 2677
			), -- 2677
			"," -- 2677
		) -- 2677
	) -- 2677
	if #decisions == 1 then -- 2677
		return decisions[1] -- 2679
	end -- 2679
	return {success = true, kind = "batch", decisions = decisions} -- 2681
end -- 2661
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2688
	if attempt == nil then -- 2688
		attempt = 1 -- 2691
	end -- 2691
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2691
		if shared.stopToken.stopped then -- 2691
			return ____awaiter_resolve( -- 2691
				nil, -- 2691
				{ -- 2695
					success = false, -- 2695
					message = getCancelledReason(shared) -- 2695
				} -- 2695
			) -- 2695
		end -- 2695
		Log( -- 2697
			"Info", -- 2697
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2697
		) -- 2697
		local tools = buildDecisionToolSchema(shared) -- 2698
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2699
		local stepId = shared.step + 1 -- 2700
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2701
		emitLLMContextMetrics( -- 2705
			shared, -- 2705
			stepId, -- 2705
			"decision_tool_calling", -- 2705
			messages, -- 2705
			llmOptions -- 2705
		) -- 2705
		saveStepLLMDebugInput( -- 2706
			shared, -- 2706
			stepId, -- 2706
			"decision_tool_calling", -- 2706
			messages, -- 2706
			llmOptions -- 2706
		) -- 2706
		local lastStreamContent = "" -- 2707
		local lastStreamReasoning = "" -- 2708
		local preExecutedResults = __TS__New(Map) -- 2709
		shared.preExecutedResults = preExecutedResults -- 2710
		local res = __TS__Await(callLLMStreamAggregated( -- 2711
			messages, -- 2712
			llmOptions, -- 2713
			shared.stopToken, -- 2714
			shared.llmConfig, -- 2715
			function(response) -- 2716
				local ____opt_45 = response.choices -- 2716
				local ____opt_43 = ____opt_45 and ____opt_45[1] -- 2716
				local streamMessage = ____opt_43 and ____opt_43.message -- 2717
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2718
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2721
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2721
					return -- 2725
				end -- 2725
				lastStreamContent = nextContent -- 2727
				lastStreamReasoning = nextReasoning -- 2728
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2729
			end, -- 2716
			function(tc) -- 2731
				if shared.stopToken.stopped then -- 2731
					return -- 2732
				end -- 2732
				local action = createPreExecutableActionFromStream(shared, tc) -- 2733
				if not action or preExecutedResults:has(action.toolCallId) then -- 2733
					return -- 2734
				end -- 2734
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2735
				preExecutedResults:set( -- 2736
					action.toolCallId, -- 2736
					createPreExecutedToolResult(shared, action) -- 2736
				) -- 2736
			end -- 2731
		)) -- 2731
		if shared.stopToken.stopped then -- 2731
			clearPreExecutedResults(shared) -- 2740
			return ____awaiter_resolve( -- 2740
				nil, -- 2740
				{ -- 2741
					success = false, -- 2741
					message = getCancelledReason(shared) -- 2741
				} -- 2741
			) -- 2741
		end -- 2741
		if not res.success then -- 2741
			saveStepLLMDebugOutput( -- 2744
				shared, -- 2744
				stepId, -- 2744
				"decision_tool_calling", -- 2744
				res.raw or res.message, -- 2744
				{success = false} -- 2744
			) -- 2744
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2745
			if (string.find(res.message, "stream incomplete:", nil, true) or 0) - 1 >= 0 then -- 2745
				local ____opt_51 = res.response -- 2745
				local partialChoice = ____opt_51 and ____opt_51.choices and res.response.choices[1] -- 2747
				local partialMessage = partialChoice and partialChoice.message -- 2748
				local partialToolCalls = partialMessage and partialMessage.tool_calls -- 2749
				if partialToolCalls and #partialToolCalls > 0 then -- 2749
					local partialReasoningContent = partialMessage and type(partialMessage.reasoning_content) == "string" and partialMessage.reasoning_content or nil -- 2751
					local partialMessageContent = partialMessage and type(partialMessage.content) == "string" and __TS__StringTrim(partialMessage.content) or nil -- 2754
					local partialDecisions = {} -- 2757
					local partialFailure -- 2758
					do -- 2758
						local i = 0 -- 2759
						while i < #partialToolCalls do -- 2759
							local toolCall = partialToolCalls[i + 1] -- 2760
							local fn = toolCall and toolCall["function"] -- 2761
							if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2761
								partialFailure = { -- 2763
									success = false, -- 2764
									message = "missing function name for partial tool call " .. tostring(i + 1), -- 2765
									raw = partialMessageContent -- 2766
								} -- 2766
								break -- 2768
							end -- 2768
							local decision = parseAndValidateToolCallDecision( -- 2770
								shared, -- 2771
								fn.name, -- 2772
								type(fn.arguments) == "string" and fn.arguments or "", -- 2773
								toolCall and type(toolCall.id) == "string" and toolCall.id or nil, -- 2774
								partialMessageContent, -- 2775
								partialReasoningContent -- 2776
							) -- 2776
							if not decision.success then -- 2776
								partialFailure = decision -- 2779
								break -- 2780
							end -- 2780
							partialDecisions[#partialDecisions + 1] = decision -- 2782
							i = i + 1 -- 2759
						end -- 2759
					end -- 2759
					if not partialFailure and #partialDecisions > 0 then -- 2759
						Log( -- 2785
							"Warn", -- 2785
							"[CodingAgent] committing partial tool calls after incomplete stream tools=" .. table.concat( -- 2785
								__TS__ArrayMap( -- 2785
									partialDecisions, -- 2785
									function(____, decision) return decision.tool end -- 2785
								), -- 2785
								"," -- 2785
							) -- 2785
						) -- 2785
						if #partialDecisions == 1 then -- 2785
							return ____awaiter_resolve(nil, partialDecisions[1]) -- 2785
						end -- 2785
						return ____awaiter_resolve(nil, { -- 2785
							success = true, -- 2790
							kind = "batch", -- 2791
							decisions = partialDecisions, -- 2792
							content = partialMessageContent, -- 2793
							reasoningContent = partialReasoningContent -- 2794
						}) -- 2794
					end -- 2794
					Log("Warn", "[CodingAgent] partial tool calls not commit-ready after incomplete stream: " .. (partialFailure and partialFailure.message or "empty decisions")) -- 2797
				end -- 2797
				local committedDecision = self:commitPreExecutedDecision(shared) -- 2799
				if committedDecision then -- 2799
					return ____awaiter_resolve(nil, committedDecision) -- 2799
				end -- 2799
			end -- 2799
			clearPreExecutedResults(shared) -- 2804
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2804
		end -- 2804
		saveStepLLMDebugOutput( -- 2807
			shared, -- 2807
			stepId, -- 2807
			"decision_tool_calling", -- 2807
			encodeDebugJSON(res.response), -- 2807
			{success = true} -- 2807
		) -- 2807
		local choice = res.response.choices and res.response.choices[1] -- 2808
		local message = choice and choice.message -- 2809
		local toolCalls = message and message.tool_calls -- 2810
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2811
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2814
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2817
		Log( -- 2820
			"Info", -- 2820
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2820
		) -- 2820
		if not toolCalls or #toolCalls == 0 then -- 2820
			if finishReason == "length" then -- 2820
				Log( -- 2823
					"Error", -- 2823
					"[CodingAgent] tool-calling output truncated before tool call reasoning_len=" .. tostring(reasoningContent and #reasoningContent or 0) -- 2823
				) -- 2823
				clearPreExecutedResults(shared) -- 2824
				return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens before producing a tool call. Retry immediately with a valid tool call and keep reasoning minimal.", raw = reasoningContent or messageContent or ""}) -- 2824
			end -- 2824
			if messageContent and messageContent ~= "" then -- 2824
				Log( -- 2832
					"Info", -- 2832
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2832
				) -- 2832
				clearPreExecutedResults(shared) -- 2833
				return ____awaiter_resolve(nil, { -- 2833
					success = true, -- 2835
					tool = "finish", -- 2836
					params = {}, -- 2837
					reason = messageContent, -- 2838
					reasoningContent = reasoningContent, -- 2839
					directSummary = messageContent -- 2840
				}) -- 2840
			end -- 2840
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2843
			clearPreExecutedResults(shared) -- 2844
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2844
		end -- 2844
		local decisions = {} -- 2851
		do -- 2851
			local i = 0 -- 2852
			while i < #toolCalls do -- 2852
				local toolCall = toolCalls[i + 1] -- 2853
				local fn = toolCall and toolCall["function"] -- 2854
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2854
					Log( -- 2856
						"Error", -- 2856
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2856
					) -- 2856
					clearPreExecutedResults(shared) -- 2857
					return ____awaiter_resolve( -- 2857
						nil, -- 2857
						{ -- 2858
							success = false, -- 2859
							message = "missing function name for tool call " .. tostring(i + 1), -- 2860
							raw = messageContent -- 2861
						} -- 2861
					) -- 2861
				end -- 2861
				local functionName = fn.name -- 2864
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2865
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2866
				Log( -- 2869
					"Info", -- 2869
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2869
				) -- 2869
				local decision = parseAndValidateToolCallDecision( -- 2870
					shared, -- 2871
					functionName, -- 2872
					argsText, -- 2873
					toolCallId, -- 2874
					messageContent, -- 2875
					reasoningContent -- 2876
				) -- 2876
				if not decision.success then -- 2876
					Log( -- 2879
						"Error", -- 2879
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2879
					) -- 2879
					clearPreExecutedResults(shared) -- 2880
					return ____awaiter_resolve(nil, decision) -- 2880
				end -- 2880
				decisions[#decisions + 1] = decision -- 2883
				i = i + 1 -- 2852
			end -- 2852
		end -- 2852
		if #decisions == 1 then -- 2852
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2886
			return ____awaiter_resolve(nil, decisions[1]) -- 2886
		end -- 2886
		do -- 2886
			local i = 0 -- 2889
			while i < #decisions do -- 2889
				if decisions[i + 1].tool == "finish" then -- 2889
					clearPreExecutedResults(shared) -- 2891
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2891
				end -- 2891
				i = i + 1 -- 2889
			end -- 2889
		end -- 2889
		Log( -- 2899
			"Info", -- 2899
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2899
				__TS__ArrayMap( -- 2899
					decisions, -- 2899
					function(____, decision) return decision.tool end -- 2899
				), -- 2899
				"," -- 2899
			) -- 2899
		) -- 2899
		return ____awaiter_resolve(nil, { -- 2899
			success = true, -- 2901
			kind = "batch", -- 2902
			decisions = decisions, -- 2903
			content = messageContent, -- 2904
			reasoningContent = reasoningContent -- 2905
		}) -- 2905
	end) -- 2905
end -- 2688
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2909
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2909
		Log( -- 2914
			"Info", -- 2914
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2914
		) -- 2914
		local lastError = initialError -- 2915
		local candidateRaw = "" -- 2916
		do -- 2916
			local attempt = 0 -- 2917
			while attempt < shared.llmMaxTry do -- 2917
				do -- 2917
					Log( -- 2918
						"Info", -- 2918
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2918
					) -- 2918
					local messages = buildXmlRepairMessages( -- 2919
						shared, -- 2920
						originalRaw, -- 2921
						candidateRaw, -- 2922
						lastError, -- 2923
						attempt + 1 -- 2924
					) -- 2924
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2926
					if shared.stopToken.stopped then -- 2926
						return ____awaiter_resolve( -- 2926
							nil, -- 2926
							{ -- 2928
								success = false, -- 2928
								message = getCancelledReason(shared) -- 2928
							} -- 2928
						) -- 2928
					end -- 2928
					if not llmRes.success then -- 2928
						lastError = llmRes.message -- 2931
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2932
						goto __continue487 -- 2933
					end -- 2933
					candidateRaw = llmRes.text -- 2935
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2936
					if decision.success then -- 2936
						decision.reasoningContent = llmRes.reasoningContent -- 2938
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2939
						return ____awaiter_resolve(nil, decision) -- 2939
					end -- 2939
					lastError = decision.message -- 2942
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2943
				end -- 2943
				::__continue487:: -- 2943
				attempt = attempt + 1 -- 2917
			end -- 2917
		end -- 2917
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2945
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2945
	end) -- 2945
end -- 2909
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2953
	if attempt == nil then -- 2953
		attempt = 1 -- 2956
	end -- 2956
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2956
		local messages = buildDecisionMessages( -- 2959
			shared, -- 2960
			lastError, -- 2961
			attempt, -- 2962
			lastRaw, -- 2963
			"xml" -- 2964
		) -- 2964
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2966
		if shared.stopToken.stopped then -- 2966
			return ____awaiter_resolve( -- 2966
				nil, -- 2966
				{ -- 2968
					success = false, -- 2968
					message = getCancelledReason(shared) -- 2968
				} -- 2968
			) -- 2968
		end -- 2968
		if not llmRes.success then -- 2968
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2968
		end -- 2968
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2977
		if decision.success then -- 2977
			decision.reasoningContent = llmRes.reasoningContent -- 2979
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2979
				return ____awaiter_resolve( -- 2979
					nil, -- 2979
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2981
				) -- 2981
			end -- 2981
			return ____awaiter_resolve(nil, decision) -- 2981
		end -- 2981
		return ____awaiter_resolve( -- 2981
			nil, -- 2981
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2989
		) -- 2989
	end) -- 2989
end -- 2953
function MainDecisionAgent.prototype.exec(self, input) -- 2992
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2992
		local shared = input.shared -- 2993
		if shared.stopToken.stopped then -- 2993
			return ____awaiter_resolve( -- 2993
				nil, -- 2993
				{ -- 2995
					success = false, -- 2995
					message = getCancelledReason(shared) -- 2995
				} -- 2995
			) -- 2995
		end -- 2995
		if shared.step >= shared.maxSteps then -- 2995
			Log( -- 2998
				"Warn", -- 2998
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2998
			) -- 2998
			return ____awaiter_resolve( -- 2998
				nil, -- 2998
				{ -- 2999
					success = false, -- 2999
					message = getMaxStepsReachedReason(shared) -- 2999
				} -- 2999
			) -- 2999
		end -- 2999
		if shared.decisionMode == "tool_calling" then -- 2999
			Log( -- 3003
				"Info", -- 3003
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3003
			) -- 3003
			local lastError = "tool calling validation failed" -- 3004
			local lastRaw = "" -- 3005
			local shouldFallbackToXml = false -- 3006
			do -- 3006
				local attempt = 0 -- 3007
				while attempt < shared.llmMaxTry do -- 3007
					Log( -- 3008
						"Info", -- 3008
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3008
					) -- 3008
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3009
					if shared.stopToken.stopped then -- 3009
						return ____awaiter_resolve( -- 3009
							nil, -- 3009
							{ -- 3016
								success = false, -- 3016
								message = getCancelledReason(shared) -- 3016
							} -- 3016
						) -- 3016
					end -- 3016
					if decision.success then -- 3016
						return ____awaiter_resolve(nil, decision) -- 3016
					end -- 3016
					lastError = decision.message -- 3021
					lastRaw = decision.raw or "" -- 3022
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3023
					if lastError == "missing tool call" then -- 3023
						shouldFallbackToXml = true -- 3025
						break -- 3026
					end -- 3026
					attempt = attempt + 1 -- 3007
				end -- 3007
			end -- 3007
			if shouldFallbackToXml then -- 3007
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3030
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3031
				do -- 3031
					local attempt = 0 -- 3032
					while attempt < shared.llmMaxTry do -- 3032
						Log( -- 3033
							"Info", -- 3033
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3033
						) -- 3033
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3034
						if shared.stopToken.stopped then -- 3034
							return ____awaiter_resolve( -- 3034
								nil, -- 3034
								{ -- 3041
									success = false, -- 3041
									message = getCancelledReason(shared) -- 3041
								} -- 3041
							) -- 3041
						end -- 3041
						if decision.success then -- 3041
							return ____awaiter_resolve(nil, decision) -- 3041
						end -- 3041
						lastError = decision.message -- 3046
						lastRaw = decision.raw or "" -- 3047
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3048
						attempt = attempt + 1 -- 3032
					end -- 3032
				end -- 3032
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3050
				return ____awaiter_resolve( -- 3050
					nil, -- 3050
					{ -- 3051
						success = false, -- 3051
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3051
					} -- 3051
				) -- 3051
			end -- 3051
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3053
			return ____awaiter_resolve( -- 3053
				nil, -- 3053
				{ -- 3054
					success = false, -- 3054
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3054
				} -- 3054
			) -- 3054
		end -- 3054
		local lastError = "xml validation failed" -- 3057
		local lastRaw = "" -- 3058
		do -- 3058
			local attempt = 0 -- 3059
			while attempt < shared.llmMaxTry do -- 3059
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3060
				if shared.stopToken.stopped then -- 3060
					return ____awaiter_resolve( -- 3060
						nil, -- 3060
						{ -- 3069
							success = false, -- 3069
							message = getCancelledReason(shared) -- 3069
						} -- 3069
					) -- 3069
				end -- 3069
				if decision.success then -- 3069
					return ____awaiter_resolve(nil, decision) -- 3069
				end -- 3069
				lastError = decision.message -- 3074
				lastRaw = decision.raw or "" -- 3075
				attempt = attempt + 1 -- 3059
			end -- 3059
		end -- 3059
		return ____awaiter_resolve( -- 3059
			nil, -- 3059
			{ -- 3077
				success = false, -- 3077
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3077
			} -- 3077
		) -- 3077
	end) -- 3077
end -- 2992
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3080
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3080
		local result = execRes -- 3081
		if not result.success then -- 3081
			if shared.stopToken.stopped then -- 3081
				shared.error = getCancelledReason(shared) -- 3084
				shared.done = true -- 3085
				return ____awaiter_resolve(nil, "done") -- 3085
			end -- 3085
			shared.error = result.message -- 3088
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3089
			shared.done = true -- 3090
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3091
			persistHistoryState(shared) -- 3095
			return ____awaiter_resolve(nil, "done") -- 3095
		end -- 3095
		if isDecisionBatchSuccess(result) then -- 3095
			local startStep = shared.step -- 3099
			local actions = {} -- 3100
			do -- 3100
				local i = 0 -- 3101
				while i < #result.decisions do -- 3101
					local decision = result.decisions[i + 1] -- 3102
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3103
					local step = startStep + i + 1 -- 3104
					local ____temp_53 -- 3105
					if i == 0 then -- 3105
						____temp_53 = decision.reason -- 3105
					else -- 3105
						____temp_53 = "" -- 3105
					end -- 3105
					local actionReason = ____temp_53 -- 3105
					local ____temp_54 -- 3106
					if i == 0 then -- 3106
						____temp_54 = decision.reasoningContent -- 3106
					else -- 3106
						____temp_54 = nil -- 3106
					end -- 3106
					local actionReasoningContent = ____temp_54 -- 3106
					emitAgentEvent(shared, { -- 3107
						type = "decision_made", -- 3108
						sessionId = shared.sessionId, -- 3109
						taskId = shared.taskId, -- 3110
						step = step, -- 3111
						tool = decision.tool, -- 3112
						reason = actionReason, -- 3113
						reasoningContent = actionReasoningContent, -- 3114
						params = decision.params -- 3115
					}) -- 3115
					local action = { -- 3117
						step = step, -- 3118
						toolCallId = toolCallId, -- 3119
						tool = decision.tool, -- 3120
						reason = actionReason or "", -- 3121
						reasoningContent = actionReasoningContent, -- 3122
						params = decision.params, -- 3123
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3124
					} -- 3124
					local ____shared_history_55 = shared.history -- 3124
					____shared_history_55[#____shared_history_55 + 1] = action -- 3126
					actions[#actions + 1] = action -- 3127
					i = i + 1 -- 3101
				end -- 3101
			end -- 3101
			shared.step = startStep + #actions -- 3129
			shared.pendingToolActions = actions -- 3130
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3131
			persistHistoryState(shared) -- 3137
			return ____awaiter_resolve(nil, "batch_tools") -- 3137
		end -- 3137
		if result.directSummary and result.directSummary ~= "" then -- 3137
			shared.response = result.directSummary -- 3141
			shared.done = true -- 3142
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3143
			persistHistoryState(shared) -- 3148
			return ____awaiter_resolve(nil, "done") -- 3148
		end -- 3148
		if result.tool == "finish" then -- 3148
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3152
			shared.response = finalMessage -- 3153
			shared.done = true -- 3154
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3155
			persistHistoryState(shared) -- 3160
			return ____awaiter_resolve(nil, "done") -- 3160
		end -- 3160
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3163
		shared.step = shared.step + 1 -- 3164
		local step = shared.step -- 3165
		emitAgentEvent(shared, { -- 3166
			type = "decision_made", -- 3167
			sessionId = shared.sessionId, -- 3168
			taskId = shared.taskId, -- 3169
			step = step, -- 3170
			tool = result.tool, -- 3171
			reason = result.reason, -- 3172
			reasoningContent = result.reasoningContent, -- 3173
			params = result.params -- 3174
		}) -- 3174
		local ____shared_history_56 = shared.history -- 3174
		____shared_history_56[#____shared_history_56 + 1] = { -- 3176
			step = step, -- 3177
			toolCallId = toolCallId, -- 3178
			tool = result.tool, -- 3179
			reason = result.reason or "", -- 3180
			reasoningContent = result.reasoningContent, -- 3181
			params = result.params, -- 3182
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3183
		} -- 3183
		local action = shared.history[#shared.history] -- 3185
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3186
		if canPreExecuteTool(action.tool) then -- 3186
			shared.pendingToolActions = {action} -- 3188
			persistHistoryState(shared) -- 3189
			return ____awaiter_resolve(nil, "batch_tools") -- 3189
		end -- 3189
		clearPreExecutedResults(shared) -- 3192
		persistHistoryState(shared) -- 3193
		return ____awaiter_resolve(nil, result.tool) -- 3193
	end) -- 3193
end -- 3080
local ReadFileAction = __TS__Class() -- 3198
ReadFileAction.name = "ReadFileAction" -- 3198
__TS__ClassExtends(ReadFileAction, Node) -- 3198
function ReadFileAction.prototype.prep(self, shared) -- 3199
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3199
		local last = shared.history[#shared.history] -- 3200
		if not last then -- 3200
			error( -- 3201
				__TS__New(Error, "no history"), -- 3201
				0 -- 3201
			) -- 3201
		end -- 3201
		emitAgentStartEvent(shared, last) -- 3202
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3203
		if __TS__StringTrim(path) == "" then -- 3203
			error( -- 3206
				__TS__New(Error, "missing path"), -- 3206
				0 -- 3206
			) -- 3206
		end -- 3206
		local ____path_59 = path -- 3208
		local ____shared_workingDir_60 = shared.workingDir -- 3210
		local ____temp_61 = shared.useChineseResponse and "zh" or "en" -- 3211
		local ____last_params_startLine_57 = last.params.startLine -- 3212
		if ____last_params_startLine_57 == nil then -- 3212
			____last_params_startLine_57 = 1 -- 3212
		end -- 3212
		local ____TS__Number_result_62 = __TS__Number(____last_params_startLine_57) -- 3212
		local ____last_params_endLine_58 = last.params.endLine -- 3213
		if ____last_params_endLine_58 == nil then -- 3213
			____last_params_endLine_58 = READ_FILE_DEFAULT_LIMIT -- 3213
		end -- 3213
		return ____awaiter_resolve( -- 3213
			nil, -- 3213
			{ -- 3207
				path = ____path_59, -- 3208
				tool = "read_file", -- 3209
				workDir = ____shared_workingDir_60, -- 3210
				docLanguage = ____temp_61, -- 3211
				startLine = ____TS__Number_result_62, -- 3212
				endLine = __TS__Number(____last_params_endLine_58) -- 3213
			} -- 3213
		) -- 3213
	end) -- 3213
end -- 3199
function ReadFileAction.prototype.exec(self, input) -- 3217
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3217
		return ____awaiter_resolve( -- 3217
			nil, -- 3217
			Tools.readFile( -- 3218
				input.workDir, -- 3219
				input.path, -- 3220
				__TS__Number(input.startLine or 1), -- 3221
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3222
				input.docLanguage -- 3223
			) -- 3223
		) -- 3223
	end) -- 3223
end -- 3217
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3227
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3227
		local result = execRes -- 3228
		local last = shared.history[#shared.history] -- 3229
		if last ~= nil then -- 3229
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3231
			appendToolResultMessage(shared, last) -- 3232
			emitAgentFinishEvent(shared, last) -- 3233
		end -- 3233
		persistHistoryState(shared) -- 3235
		__TS__Await(maybeCompressHistory(shared)) -- 3236
		persistHistoryState(shared) -- 3237
		return ____awaiter_resolve(nil, "main") -- 3237
	end) -- 3237
end -- 3227
local SearchFilesAction = __TS__Class() -- 3242
SearchFilesAction.name = "SearchFilesAction" -- 3242
__TS__ClassExtends(SearchFilesAction, Node) -- 3242
function SearchFilesAction.prototype.prep(self, shared) -- 3243
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3243
		local last = shared.history[#shared.history] -- 3244
		if not last then -- 3244
			error( -- 3245
				__TS__New(Error, "no history"), -- 3245
				0 -- 3245
			) -- 3245
		end -- 3245
		emitAgentStartEvent(shared, last) -- 3246
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3246
	end) -- 3246
end -- 3243
function SearchFilesAction.prototype.exec(self, input) -- 3250
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3250
		local params = input.params -- 3251
		local ____Tools_searchFiles_76 = Tools.searchFiles -- 3252
		local ____input_workDir_69 = input.workDir -- 3253
		local ____temp_70 = params.path or "" -- 3254
		local ____temp_71 = params.pattern or "" -- 3255
		local ____params_globs_72 = params.globs -- 3256
		local ____params_useRegex_73 = params.useRegex -- 3257
		local ____params_caseSensitive_74 = params.caseSensitive -- 3258
		local ____math_max_65 = math.max -- 3261
		local ____math_floor_64 = math.floor -- 3261
		local ____params_limit_63 = params.limit -- 3261
		if ____params_limit_63 == nil then -- 3261
			____params_limit_63 = SEARCH_FILES_LIMIT_DEFAULT -- 3261
		end -- 3261
		local ____math_max_65_result_75 = ____math_max_65( -- 3261
			1, -- 3261
			____math_floor_64(__TS__Number(____params_limit_63)) -- 3261
		) -- 3261
		local ____math_max_68 = math.max -- 3262
		local ____math_floor_67 = math.floor -- 3262
		local ____params_offset_66 = params.offset -- 3262
		if ____params_offset_66 == nil then -- 3262
			____params_offset_66 = 0 -- 3262
		end -- 3262
		local result = __TS__Await(____Tools_searchFiles_76({ -- 3252
			workDir = ____input_workDir_69, -- 3253
			path = ____temp_70, -- 3254
			pattern = ____temp_71, -- 3255
			globs = ____params_globs_72, -- 3256
			useRegex = ____params_useRegex_73, -- 3257
			caseSensitive = ____params_caseSensitive_74, -- 3258
			includeContent = true, -- 3259
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3260
			limit = ____math_max_65_result_75, -- 3261
			offset = ____math_max_68( -- 3262
				0, -- 3262
				____math_floor_67(__TS__Number(____params_offset_66)) -- 3262
			), -- 3262
			groupByFile = params.groupByFile == true -- 3263
		})) -- 3263
		return ____awaiter_resolve(nil, result) -- 3263
	end) -- 3263
end -- 3250
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3268
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3268
		local last = shared.history[#shared.history] -- 3269
		if last ~= nil then -- 3269
			local result = execRes -- 3271
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3272
			appendToolResultMessage(shared, last) -- 3273
			emitAgentFinishEvent(shared, last) -- 3274
		end -- 3274
		persistHistoryState(shared) -- 3276
		__TS__Await(maybeCompressHistory(shared)) -- 3277
		persistHistoryState(shared) -- 3278
		return ____awaiter_resolve(nil, "main") -- 3278
	end) -- 3278
end -- 3268
local SearchDoraAPIAction = __TS__Class() -- 3283
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3283
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3283
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3284
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3284
		local last = shared.history[#shared.history] -- 3285
		if not last then -- 3285
			error( -- 3286
				__TS__New(Error, "no history"), -- 3286
				0 -- 3286
			) -- 3286
		end -- 3286
		emitAgentStartEvent(shared, last) -- 3287
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3287
	end) -- 3287
end -- 3284
function SearchDoraAPIAction.prototype.exec(self, input) -- 3291
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3291
		local params = input.params -- 3292
		local ____Tools_searchDoraAPI_84 = Tools.searchDoraAPI -- 3293
		local ____temp_80 = params.pattern or "" -- 3294
		local ____temp_81 = params.docSource or "api" -- 3295
		local ____temp_82 = input.useChineseResponse and "zh" or "en" -- 3296
		local ____temp_83 = params.programmingLanguage or "ts" -- 3297
		local ____math_min_79 = math.min -- 3298
		local ____math_max_78 = math.max -- 3298
		local ____params_limit_77 = params.limit -- 3298
		if ____params_limit_77 == nil then -- 3298
			____params_limit_77 = 8 -- 3298
		end -- 3298
		local result = __TS__Await(____Tools_searchDoraAPI_84({ -- 3293
			pattern = ____temp_80, -- 3294
			docSource = ____temp_81, -- 3295
			docLanguage = ____temp_82, -- 3296
			programmingLanguage = ____temp_83, -- 3297
			limit = ____math_min_79( -- 3298
				SEARCH_DORA_API_LIMIT_MAX, -- 3298
				____math_max_78( -- 3298
					1, -- 3298
					__TS__Number(____params_limit_77) -- 3298
				) -- 3298
			), -- 3298
			useRegex = params.useRegex, -- 3299
			caseSensitive = false, -- 3300
			includeContent = true, -- 3301
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3302
		})) -- 3302
		return ____awaiter_resolve(nil, result) -- 3302
	end) -- 3302
end -- 3291
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3307
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3307
		local last = shared.history[#shared.history] -- 3308
		if last ~= nil then -- 3308
			local result = execRes -- 3310
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3311
			appendToolResultMessage(shared, last) -- 3312
			emitAgentFinishEvent(shared, last) -- 3313
		end -- 3313
		persistHistoryState(shared) -- 3315
		__TS__Await(maybeCompressHistory(shared)) -- 3316
		persistHistoryState(shared) -- 3317
		return ____awaiter_resolve(nil, "main") -- 3317
	end) -- 3317
end -- 3307
local ListFilesAction = __TS__Class() -- 3322
ListFilesAction.name = "ListFilesAction" -- 3322
__TS__ClassExtends(ListFilesAction, Node) -- 3322
function ListFilesAction.prototype.prep(self, shared) -- 3323
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3323
		local last = shared.history[#shared.history] -- 3324
		if not last then -- 3324
			error( -- 3325
				__TS__New(Error, "no history"), -- 3325
				0 -- 3325
			) -- 3325
		end -- 3325
		emitAgentStartEvent(shared, last) -- 3326
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3326
	end) -- 3326
end -- 3323
function ListFilesAction.prototype.exec(self, input) -- 3330
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3330
		local params = input.params -- 3331
		local ____Tools_listFiles_91 = Tools.listFiles -- 3332
		local ____input_workDir_88 = input.workDir -- 3333
		local ____temp_89 = params.path or "" -- 3334
		local ____params_globs_90 = params.globs -- 3335
		local ____math_max_87 = math.max -- 3336
		local ____math_floor_86 = math.floor -- 3336
		local ____params_maxEntries_85 = params.maxEntries -- 3336
		if ____params_maxEntries_85 == nil then -- 3336
			____params_maxEntries_85 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3336
		end -- 3336
		local result = ____Tools_listFiles_91({ -- 3332
			workDir = ____input_workDir_88, -- 3333
			path = ____temp_89, -- 3334
			globs = ____params_globs_90, -- 3335
			maxEntries = ____math_max_87( -- 3336
				1, -- 3336
				____math_floor_86(__TS__Number(____params_maxEntries_85)) -- 3336
			) -- 3336
		}) -- 3336
		return ____awaiter_resolve(nil, result) -- 3336
	end) -- 3336
end -- 3330
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3341
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3341
		local last = shared.history[#shared.history] -- 3342
		if last ~= nil then -- 3342
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3344
			appendToolResultMessage(shared, last) -- 3345
			emitAgentFinishEvent(shared, last) -- 3346
		end -- 3346
		persistHistoryState(shared) -- 3348
		__TS__Await(maybeCompressHistory(shared)) -- 3349
		persistHistoryState(shared) -- 3350
		return ____awaiter_resolve(nil, "main") -- 3350
	end) -- 3350
end -- 3341
local DeleteFileAction = __TS__Class() -- 3355
DeleteFileAction.name = "DeleteFileAction" -- 3355
__TS__ClassExtends(DeleteFileAction, Node) -- 3355
function DeleteFileAction.prototype.prep(self, shared) -- 3356
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3356
		local last = shared.history[#shared.history] -- 3357
		if not last then -- 3357
			error( -- 3358
				__TS__New(Error, "no history"), -- 3358
				0 -- 3358
			) -- 3358
		end -- 3358
		emitAgentStartEvent(shared, last) -- 3359
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3360
		if __TS__StringTrim(targetFile) == "" then -- 3360
			error( -- 3363
				__TS__New(Error, "missing target_file"), -- 3363
				0 -- 3363
			) -- 3363
		end -- 3363
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3363
	end) -- 3363
end -- 3356
function DeleteFileAction.prototype.exec(self, input) -- 3367
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3367
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3368
		if not result.success then -- 3368
			return ____awaiter_resolve(nil, result) -- 3368
		end -- 3368
		return ____awaiter_resolve(nil, { -- 3368
			success = true, -- 3376
			changed = true, -- 3377
			mode = "delete", -- 3378
			checkpointId = result.checkpointId, -- 3379
			checkpointSeq = result.checkpointSeq, -- 3380
			files = {{path = input.targetFile, op = "delete"}} -- 3381
		}) -- 3381
	end) -- 3381
end -- 3367
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3385
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3385
		local last = shared.history[#shared.history] -- 3386
		if last ~= nil then -- 3386
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3388
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3389
			appendToolResultMessage(shared, last) -- 3390
			emitAgentFinishEvent(shared, last) -- 3391
			local result = last.result -- 3392
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3392
				emitAgentEvent(shared, { -- 3397
					type = "checkpoint_created", -- 3398
					sessionId = shared.sessionId, -- 3399
					taskId = shared.taskId, -- 3400
					step = last.step, -- 3401
					tool = "delete_file", -- 3402
					checkpointId = result.checkpointId, -- 3403
					checkpointSeq = result.checkpointSeq, -- 3404
					files = result.files -- 3405
				}) -- 3405
			end -- 3405
		end -- 3405
		persistHistoryState(shared) -- 3409
		__TS__Await(maybeCompressHistory(shared)) -- 3410
		persistHistoryState(shared) -- 3411
		return ____awaiter_resolve(nil, "main") -- 3411
	end) -- 3411
end -- 3385
local BuildAction = __TS__Class() -- 3416
BuildAction.name = "BuildAction" -- 3416
__TS__ClassExtends(BuildAction, Node) -- 3416
function BuildAction.prototype.prep(self, shared) -- 3417
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3417
		local last = shared.history[#shared.history] -- 3418
		if not last then -- 3418
			error( -- 3419
				__TS__New(Error, "no history"), -- 3419
				0 -- 3419
			) -- 3419
		end -- 3419
		emitAgentStartEvent(shared, last) -- 3420
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3420
	end) -- 3420
end -- 3417
function BuildAction.prototype.exec(self, input) -- 3424
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3424
		local params = input.params -- 3425
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3426
		return ____awaiter_resolve(nil, result) -- 3426
	end) -- 3426
end -- 3424
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3433
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3433
		local last = shared.history[#shared.history] -- 3434
		if last ~= nil then -- 3434
			last.result = sanitizeBuildResultForHistory(execRes) -- 3436
			appendToolResultMessage(shared, last) -- 3437
			emitAgentFinishEvent(shared, last) -- 3438
		end -- 3438
		persistHistoryState(shared) -- 3440
		__TS__Await(maybeCompressHistory(shared)) -- 3441
		persistHistoryState(shared) -- 3442
		return ____awaiter_resolve(nil, "main") -- 3442
	end) -- 3442
end -- 3433
local SpawnSubAgentAction = __TS__Class() -- 3447
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3447
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3447
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3448
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3448
		local last = shared.history[#shared.history] -- 3457
		if not last then -- 3457
			error( -- 3458
				__TS__New(Error, "no history"), -- 3458
				0 -- 3458
			) -- 3458
		end -- 3458
		emitAgentStartEvent(shared, last) -- 3459
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3460
			last.params.filesHint, -- 3461
			function(____, item) return type(item) == "string" end -- 3461
		) or nil -- 3461
		return ____awaiter_resolve( -- 3461
			nil, -- 3461
			{ -- 3463
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3464
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3465
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3466
				filesHint = filesHint, -- 3467
				sessionId = shared.sessionId, -- 3468
				projectRoot = shared.workingDir, -- 3469
				spawnSubAgent = shared.spawnSubAgent -- 3470
			} -- 3470
		) -- 3470
	end) -- 3470
end -- 3448
function SpawnSubAgentAction.prototype.exec(self, input) -- 3474
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3474
		if not input.spawnSubAgent then -- 3474
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3474
		end -- 3474
		if input.sessionId == nil or input.sessionId <= 0 then -- 3474
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3474
		end -- 3474
		local ____Log_97 = Log -- 3489
		local ____temp_94 = #input.title -- 3489
		local ____temp_95 = #input.prompt -- 3489
		local ____temp_96 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3489
		local ____opt_92 = input.filesHint -- 3489
		____Log_97( -- 3489
			"Info", -- 3489
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_94)) .. " prompt_len=") .. tostring(____temp_95)) .. " expected_len=") .. tostring(____temp_96)) .. " files_hint_count=") .. tostring(____opt_92 and #____opt_92 or 0) -- 3489
		) -- 3489
		local result = __TS__Await(input.spawnSubAgent({ -- 3490
			parentSessionId = input.sessionId, -- 3491
			projectRoot = input.projectRoot, -- 3492
			title = input.title, -- 3493
			prompt = input.prompt, -- 3494
			expectedOutput = input.expectedOutput, -- 3495
			filesHint = input.filesHint -- 3496
		})) -- 3496
		if not result.success then -- 3496
			return ____awaiter_resolve(nil, result) -- 3496
		end -- 3496
		return ____awaiter_resolve(nil, { -- 3496
			success = true, -- 3502
			sessionId = result.sessionId, -- 3503
			taskId = result.taskId, -- 3504
			title = result.title, -- 3505
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3506
		}) -- 3506
	end) -- 3506
end -- 3474
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3510
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3510
		local last = shared.history[#shared.history] -- 3511
		if last ~= nil then -- 3511
			last.result = execRes -- 3513
			appendToolResultMessage(shared, last) -- 3514
			emitAgentFinishEvent(shared, last) -- 3515
		end -- 3515
		persistHistoryState(shared) -- 3517
		__TS__Await(maybeCompressHistory(shared)) -- 3518
		persistHistoryState(shared) -- 3519
		return ____awaiter_resolve(nil, "main") -- 3519
	end) -- 3519
end -- 3510
local ListSubAgentsAction = __TS__Class() -- 3524
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3524
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3524
function ListSubAgentsAction.prototype.prep(self, shared) -- 3525
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3525
		local last = shared.history[#shared.history] -- 3534
		if not last then -- 3534
			error( -- 3535
				__TS__New(Error, "no history"), -- 3535
				0 -- 3535
			) -- 3535
		end -- 3535
		emitAgentStartEvent(shared, last) -- 3536
		return ____awaiter_resolve( -- 3536
			nil, -- 3536
			{ -- 3537
				sessionId = shared.sessionId, -- 3538
				projectRoot = shared.workingDir, -- 3539
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3540
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3541
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3542
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3543
				listSubAgents = shared.listSubAgents -- 3544
			} -- 3544
		) -- 3544
	end) -- 3544
end -- 3525
function ListSubAgentsAction.prototype.exec(self, input) -- 3548
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3548
		if not input.listSubAgents then -- 3548
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3548
		end -- 3548
		if input.sessionId == nil or input.sessionId <= 0 then -- 3548
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3548
		end -- 3548
		local result = __TS__Await(input.listSubAgents({ -- 3563
			sessionId = input.sessionId, -- 3564
			projectRoot = input.projectRoot, -- 3565
			status = input.status, -- 3566
			limit = input.limit, -- 3567
			offset = input.offset, -- 3568
			query = input.query -- 3569
		})) -- 3569
		return ____awaiter_resolve(nil, result) -- 3569
	end) -- 3569
end -- 3548
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3574
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3574
		local last = shared.history[#shared.history] -- 3575
		if last ~= nil then -- 3575
			last.result = execRes -- 3577
			appendToolResultMessage(shared, last) -- 3578
			emitAgentFinishEvent(shared, last) -- 3579
		end -- 3579
		persistHistoryState(shared) -- 3581
		__TS__Await(maybeCompressHistory(shared)) -- 3582
		persistHistoryState(shared) -- 3583
		return ____awaiter_resolve(nil, "main") -- 3583
	end) -- 3583
end -- 3574
EditFileAction = __TS__Class() -- 3588
EditFileAction.name = "EditFileAction" -- 3588
__TS__ClassExtends(EditFileAction, Node) -- 3588
function EditFileAction.prototype.prep(self, shared) -- 3589
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3589
		local last = shared.history[#shared.history] -- 3590
		if not last then -- 3590
			error( -- 3591
				__TS__New(Error, "no history"), -- 3591
				0 -- 3591
			) -- 3591
		end -- 3591
		emitAgentStartEvent(shared, last) -- 3592
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3593
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3596
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3597
		if __TS__StringTrim(path) == "" then -- 3597
			error( -- 3598
				__TS__New(Error, "missing path"), -- 3598
				0 -- 3598
			) -- 3598
		end -- 3598
		return ____awaiter_resolve(nil, { -- 3598
			path = path, -- 3599
			oldStr = oldStr, -- 3599
			newStr = newStr, -- 3599
			taskId = shared.taskId, -- 3599
			workDir = shared.workingDir -- 3599
		}) -- 3599
	end) -- 3599
end -- 3589
function EditFileAction.prototype.exec(self, input) -- 3602
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3602
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3603
		if not readRes.success then -- 3603
			if input.oldStr ~= "" then -- 3603
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3603
			end -- 3603
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3608
			if not createRes.success then -- 3608
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3608
			end -- 3608
			return ____awaiter_resolve(nil, { -- 3608
				success = true, -- 3616
				changed = true, -- 3617
				mode = "create", -- 3618
				checkpointId = createRes.checkpointId, -- 3619
				checkpointSeq = createRes.checkpointSeq, -- 3620
				files = {{path = input.path, op = "create"}} -- 3621
			}) -- 3621
		end -- 3621
		if input.oldStr == "" then -- 3621
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3625
			if not overwriteRes.success then -- 3625
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3625
			end -- 3625
			return ____awaiter_resolve(nil, { -- 3625
				success = true, -- 3633
				changed = true, -- 3634
				mode = "overwrite", -- 3635
				checkpointId = overwriteRes.checkpointId, -- 3636
				checkpointSeq = overwriteRes.checkpointSeq, -- 3637
				files = {{path = input.path, op = "write"}} -- 3638
			}) -- 3638
		end -- 3638
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3643
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3644
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3645
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3648
		if occurrences == 0 then -- 3648
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3650
			if not indentTolerant.success then -- 3650
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3650
			end -- 3650
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3654
			if not applyRes.success then -- 3654
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3654
			end -- 3654
			return ____awaiter_resolve(nil, { -- 3654
				success = true, -- 3662
				changed = true, -- 3663
				mode = "replace_indent_tolerant", -- 3664
				checkpointId = applyRes.checkpointId, -- 3665
				checkpointSeq = applyRes.checkpointSeq, -- 3666
				files = {{path = input.path, op = "write"}} -- 3667
			}) -- 3667
		end -- 3667
		if occurrences > 1 then -- 3667
			return ____awaiter_resolve( -- 3667
				nil, -- 3667
				{ -- 3671
					success = false, -- 3671
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3671
				} -- 3671
			) -- 3671
		end -- 3671
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3675
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3676
		if not applyRes.success then -- 3676
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3676
		end -- 3676
		return ____awaiter_resolve(nil, { -- 3676
			success = true, -- 3684
			changed = true, -- 3685
			mode = "replace", -- 3686
			checkpointId = applyRes.checkpointId, -- 3687
			checkpointSeq = applyRes.checkpointSeq, -- 3688
			files = {{path = input.path, op = "write"}} -- 3689
		}) -- 3689
	end) -- 3689
end -- 3602
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3693
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3693
		local last = shared.history[#shared.history] -- 3694
		if last ~= nil then -- 3694
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3696
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3697
			appendToolResultMessage(shared, last) -- 3698
			emitAgentFinishEvent(shared, last) -- 3699
			local result = last.result -- 3700
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3700
				emitAgentEvent(shared, { -- 3705
					type = "checkpoint_created", -- 3706
					sessionId = shared.sessionId, -- 3707
					taskId = shared.taskId, -- 3708
					step = last.step, -- 3709
					tool = last.tool, -- 3710
					checkpointId = result.checkpointId, -- 3711
					checkpointSeq = result.checkpointSeq, -- 3712
					files = result.files -- 3713
				}) -- 3713
			end -- 3713
		end -- 3713
		persistHistoryState(shared) -- 3717
		__TS__Await(maybeCompressHistory(shared)) -- 3718
		persistHistoryState(shared) -- 3719
		return ____awaiter_resolve(nil, "main") -- 3719
	end) -- 3719
end -- 3693
local function emitCheckpointEventForAction(shared, action) -- 3724
	local result = action.result -- 3725
	if not result then -- 3725
		return -- 3726
	end -- 3726
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3726
		emitAgentEvent(shared, { -- 3731
			type = "checkpoint_created", -- 3732
			sessionId = shared.sessionId, -- 3733
			taskId = shared.taskId, -- 3734
			step = action.step, -- 3735
			tool = action.tool, -- 3736
			checkpointId = result.checkpointId, -- 3737
			checkpointSeq = result.checkpointSeq, -- 3738
			files = result.files -- 3739
		}) -- 3739
	end -- 3739
end -- 3724
local function canRunBatchActionInParallel(self, action) -- 4044
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 4045
end -- 4044
local function partitionToolCalls(actions) -- 4057
	local batches = {} -- 4058
	do -- 4058
		local i = 0 -- 4059
		while i < #actions do -- 4059
			local action = actions[i + 1] -- 4060
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4061
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4062
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4062
				local ____lastBatch_actions_132 = lastBatch.actions -- 4062
				____lastBatch_actions_132[#____lastBatch_actions_132 + 1] = action -- 4064
			else -- 4064
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4066
			end -- 4066
			i = i + 1 -- 4059
		end -- 4059
	end -- 4059
	return batches -- 4069
end -- 4057
local BatchToolAction = __TS__Class() -- 4072
BatchToolAction.name = "BatchToolAction" -- 4072
__TS__ClassExtends(BatchToolAction, Node) -- 4072
function BatchToolAction.prototype.prep(self, shared) -- 4073
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4073
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4073
	end) -- 4073
end -- 4073
function BatchToolAction.prototype.exec(self, input) -- 4077
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4077
		local shared = input.shared -- 4078
		local preExecuted = shared.preExecutedResults -- 4079
		local batches = partitionToolCalls(input.actions) -- 4080
		local parallelBatchCount = #__TS__ArrayFilter( -- 4081
			batches, -- 4081
			function(____, b) return b.isConcurrencySafe end -- 4081
		) -- 4081
		local serialBatchCount = #__TS__ArrayFilter( -- 4082
			batches, -- 4082
			function(____, b) return not b.isConcurrencySafe end -- 4082
		) -- 4082
		Log( -- 4083
			"Info", -- 4083
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4083
		) -- 4083
		do -- 4083
			local batchIdx = 0 -- 4085
			while batchIdx < #batches do -- 4085
				do -- 4085
					local batch = batches[batchIdx + 1] -- 4086
					if shared.stopToken.stopped then -- 4086
						for ____, action in ipairs(batch.actions) do -- 4088
							if not action.result then -- 4088
								action.result = { -- 4090
									success = false, -- 4090
									message = getCancelledReason(shared) -- 4090
								} -- 4090
							end -- 4090
						end -- 4090
						goto __continue659 -- 4093
					end -- 4093
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4093
						local preExecCount = #__TS__ArrayFilter( -- 4097
							batch.actions, -- 4097
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4097
						) -- 4097
						Log( -- 4098
							"Info", -- 4098
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4098
						) -- 4098
						do -- 4098
							local i = 0 -- 4099
							while i < #batch.actions do -- 4099
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4100
								i = i + 1 -- 4099
							end -- 4099
						end -- 4099
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4102
							batch.actions, -- 4102
							function(____, action) -- 4102
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4102
									if shared.stopToken.stopped then -- 4102
										action.result = { -- 4104
											success = false, -- 4104
											message = getCancelledReason(shared) -- 4104
										} -- 4104
										return ____awaiter_resolve(nil, action) -- 4104
									end -- 4104
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4107
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4108
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4109
									return ____awaiter_resolve(nil, action) -- 4109
								end) -- 4109
							end -- 4102
						))) -- 4102
						do -- 4102
							local i = 0 -- 4112
							while i < #batch.actions do -- 4112
								local action = batch.actions[i + 1] -- 4113
								if not action.result then -- 4113
									action.result = {success = false, message = "tool did not produce a result"} -- 4115
								end -- 4115
								appendToolResultMessage(shared, action) -- 4117
								emitAgentFinishEvent(shared, action) -- 4118
								emitCheckpointEventForAction(shared, action) -- 4119
								i = i + 1 -- 4112
							end -- 4112
						end -- 4112
					else -- 4112
						Log( -- 4122
							"Info", -- 4122
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4122
						) -- 4122
						do -- 4122
							local i = 0 -- 4123
							while i < #batch.actions do -- 4123
								local action = batch.actions[i + 1] -- 4124
								emitAgentStartEvent(shared, action) -- 4125
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4126
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4127
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4128
								appendToolResultMessage(shared, action) -- 4129
								emitAgentFinishEvent(shared, action) -- 4130
								emitCheckpointEventForAction(shared, action) -- 4131
								persistHistoryState(shared) -- 4132
								if shared.stopToken.stopped then -- 4132
									break -- 4134
								end -- 4134
								i = i + 1 -- 4123
							end -- 4123
						end -- 4123
					end -- 4123
				end -- 4123
				::__continue659:: -- 4123
				batchIdx = batchIdx + 1 -- 4085
			end -- 4085
		end -- 4085
		persistHistoryState(shared) -- 4139
		return ____awaiter_resolve(nil, input.actions) -- 4139
	end) -- 4139
end -- 4077
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4143
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4143
		shared.pendingToolActions = nil -- 4144
		shared.preExecutedResults = nil -- 4145
		persistHistoryState(shared) -- 4146
		__TS__Await(maybeCompressHistory(shared)) -- 4147
		persistHistoryState(shared) -- 4148
		return ____awaiter_resolve(nil, "main") -- 4148
	end) -- 4148
end -- 4143
local EndNode = __TS__Class() -- 4153
EndNode.name = "EndNode" -- 4153
__TS__ClassExtends(EndNode, Node) -- 4153
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4154
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4154
		return ____awaiter_resolve(nil, nil) -- 4154
	end) -- 4154
end -- 4154
local CodingAgentFlow = __TS__Class() -- 4159
CodingAgentFlow.name = "CodingAgentFlow" -- 4159
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4159
function CodingAgentFlow.prototype.____constructor(self, role) -- 4160
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4161
	local read = __TS__New(ReadFileAction, 1, 0) -- 4162
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4163
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4164
	local list = __TS__New(ListFilesAction, 1, 0) -- 4165
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4166
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4167
	local build = __TS__New(BuildAction, 1, 0) -- 4168
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4169
	local edit = __TS__New(EditFileAction, 1, 0) -- 4170
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4171
	local done = __TS__New(EndNode, 1, 0) -- 4172
	main:on("batch_tools", batch) -- 4174
	main:on("grep_files", search) -- 4175
	main:on("search_dora_api", searchDora) -- 4176
	main:on("glob_files", list) -- 4177
	if role == "main" then -- 4177
		main:on("read_file", read) -- 4179
		main:on("delete_file", del) -- 4180
		main:on("build", build) -- 4181
		main:on("edit_file", edit) -- 4182
		main:on("list_sub_agents", listSub) -- 4183
		main:on("spawn_sub_agent", spawn) -- 4184
	else -- 4184
		main:on("read_file", read) -- 4186
		main:on("delete_file", del) -- 4187
		main:on("build", build) -- 4188
		main:on("edit_file", edit) -- 4189
	end -- 4189
	main:on("done", done) -- 4191
	search:on("main", main) -- 4193
	searchDora:on("main", main) -- 4194
	list:on("main", main) -- 4195
	listSub:on("main", main) -- 4196
	spawn:on("main", main) -- 4197
	batch:on("main", main) -- 4198
	read:on("main", main) -- 4199
	del:on("main", main) -- 4200
	build:on("main", main) -- 4201
	edit:on("main", main) -- 4202
	Flow.prototype.____constructor(self, main) -- 4204
end -- 4160
local function runCodingAgentAsync(options) -- 4226
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4226
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4226
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4226
		end -- 4226
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4230
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4231
		if not llmConfigRes.success then -- 4231
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4231
		end -- 4231
		local llmConfig = llmConfigRes.config -- 4237
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4238
		if not taskRes.success then -- 4238
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4238
		end -- 4238
		local compressor = __TS__New(MemoryCompressor, { -- 4245
			compressionThreshold = 0.8, -- 4246
			compressionTargetThreshold = 0.5, -- 4247
			maxCompressionRounds = 3, -- 4248
			projectDir = options.workDir, -- 4249
			llmConfig = llmConfig, -- 4250
			promptPack = options.promptPack, -- 4251
			scope = options.memoryScope -- 4252
		}) -- 4252
		local persistedSession = compressor:getStorage():readSessionState() -- 4254
		local promptPack = compressor:getPromptPack() -- 4255
		local shared = { -- 4257
			sessionId = options.sessionId, -- 4258
			taskId = taskRes.taskId, -- 4259
			role = options.role or "main", -- 4260
			maxSteps = math.max( -- 4261
				1, -- 4261
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4261
			), -- 4261
			llmMaxTry = math.max( -- 4262
				1, -- 4262
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4262
			), -- 4262
			step = 0, -- 4263
			done = false, -- 4264
			stopToken = options.stopToken or ({stopped = false}), -- 4265
			response = "", -- 4266
			userQuery = normalizedPrompt, -- 4267
			workingDir = options.workDir, -- 4268
			useChineseResponse = options.useChineseResponse == true, -- 4269
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4270
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4273
			llmConfig = llmConfig, -- 4274
			onEvent = options.onEvent, -- 4275
			promptPack = promptPack, -- 4276
			history = {}, -- 4277
			messages = persistedSession.messages, -- 4278
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4279
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4280
			memory = {compressor = compressor}, -- 4282
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4286
			spawnSubAgent = options.spawnSubAgent, -- 4291
			listSubAgents = options.listSubAgents -- 4292
		} -- 4292
		local ____hasReturned, ____returnValue -- 4292
		local ____try = __TS__AsyncAwaiter(function() -- 4292
			emitAgentEvent(shared, { -- 4296
				type = "task_started", -- 4297
				sessionId = shared.sessionId, -- 4298
				taskId = shared.taskId, -- 4299
				prompt = shared.userQuery, -- 4300
				workDir = shared.workingDir, -- 4301
				maxSteps = shared.maxSteps -- 4302
			}) -- 4302
			if shared.stopToken.stopped then -- 4302
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4305
				____hasReturned = true -- 4306
				____returnValue = emitAgentTaskFinishEvent( -- 4306
					shared, -- 4306
					false, -- 4306
					getCancelledReason(shared) -- 4306
				) -- 4306
				return -- 4306
			end -- 4306
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4308
			local promptCommand = getPromptCommand(shared.userQuery) -- 4309
			if promptCommand == "clear" then -- 4309
				____hasReturned = true -- 4311
				____returnValue = clearSessionHistory(shared) -- 4311
				return -- 4311
			end -- 4311
			if promptCommand == "compact" then -- 4311
				if shared.role == "sub" then -- 4311
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4315
					____hasReturned = true -- 4316
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4316
					return -- 4316
				end -- 4316
				____hasReturned = true -- 4324
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4324
				return -- 4324
			end -- 4324
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4326
			persistHistoryState(shared) -- 4330
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4331
			__TS__Await(flow:run(shared)) -- 4332
			if shared.stopToken.stopped then -- 4332
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4334
				____hasReturned = true -- 4335
				____returnValue = emitAgentTaskFinishEvent( -- 4335
					shared, -- 4335
					false, -- 4335
					getCancelledReason(shared) -- 4335
				) -- 4335
				return -- 4335
			end -- 4335
			if shared.error then -- 4335
				____hasReturned = true -- 4338
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4338
				return -- 4338
			end -- 4338
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4341
			____hasReturned = true -- 4342
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4342
			return -- 4342
		end) -- 4342
		____try = ____try.catch( -- 4342
			____try, -- 4342
			function(____, e) -- 4342
				return __TS__AsyncAwaiter(function() -- 4342
					____hasReturned = true -- 4345
					____returnValue = finalizeAgentFailure( -- 4345
						shared, -- 4345
						tostring(e) -- 4345
					) -- 4345
					return -- 4345
				end) -- 4345
			end -- 4345
		) -- 4345
		__TS__Await(____try) -- 4295
		if ____hasReturned then -- 4295
			return ____awaiter_resolve(nil, ____returnValue) -- 4295
		end -- 4295
	end) -- 4295
end -- 4226
function ____exports.runCodingAgent(options, callback) -- 4349
	local ____self_135 = runCodingAgentAsync(options) -- 4349
	____self_135["then"]( -- 4349
		____self_135, -- 4349
		function(____, result) return callback(result) end -- 4350
	) -- 4350
end -- 4349
return ____exports -- 4349