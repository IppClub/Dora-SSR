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
local __TS__TypeOf = ____lualib.__TS__TypeOf -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
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
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local isArray, stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, isCacheableReadOnlyTool, shouldInvalidateToolCacheAfterResult, stableToolCacheValue, createToolActionCacheKey, cloneToolCacheValue, cloneToolCacheResult, evictOldestToolCacheEntry, getCachedToolActionResult, rememberToolActionResult, invalidateReadOnlyToolCache, getFinishMessage, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, executeToolActionUncached, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, HISTORY_READ_FILE_MAX_CHARS, HISTORY_READ_FILE_MAX_LINES, READ_FILE_DEFAULT_LIMIT, HISTORY_SEARCH_FILES_MAX_MATCHES, HISTORY_SEARCH_DORA_API_MAX_MATCHES, HISTORY_LIST_FILES_MAX_ENTRIES, HISTORY_BUILD_MAX_MESSAGES, HISTORY_BUILD_MESSAGE_MAX_CHARS, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT, SEARCH_PREVIEW_CONTEXT, EditFileAction -- 1
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
function emitAgentEvent(shared, event) -- 815
	if shared.onEvent then -- 815
		do -- 815
			local function ____catch(____error) -- 815
				Log( -- 820
					"Error", -- 820
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 820
				) -- 820
			end -- 820
			local ____try, ____hasReturned = pcall(function() -- 820
				shared:onEvent(event) -- 818
			end) -- 818
			if not ____try then -- 818
				____catch(____hasReturned) -- 818
			end -- 818
		end -- 818
	end -- 818
end -- 818
function getCancelledReason(shared) -- 949
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 949
		return shared.stopToken.reason -- 950
	end -- 950
	return shared.useChineseResponse and "已取消" or "cancelled" -- 951
end -- 951
function truncateText(text, maxLen) -- 1132
	if #text <= maxLen then -- 1132
		return text -- 1133
	end -- 1133
	local nextPos = utf8.offset(text, maxLen + 1) -- 1134
	if nextPos == nil then -- 1134
		return text -- 1135
	end -- 1135
	return string.sub(text, 1, nextPos - 1) .. "..." -- 1136
end -- 1136
function utf8TakeHead(text, maxChars) -- 1139
	if maxChars <= 0 or text == "" then -- 1139
		return "" -- 1140
	end -- 1140
	local nextPos = utf8.offset(text, maxChars + 1) -- 1141
	if nextPos == nil then -- 1141
		return text -- 1142
	end -- 1142
	return string.sub(text, 1, nextPos - 1) -- 1143
end -- 1143
function getReplyLanguageDirective(shared) -- 1146
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 1147
end -- 1147
function replacePromptVars(template, vars) -- 1152
	local output = template -- 1153
	for key in pairs(vars) do -- 1154
		output = table.concat( -- 1155
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1155
			vars[key] or "" or "," -- 1155
		) -- 1155
	end -- 1155
	return output -- 1157
end -- 1157
function limitReadContentForHistory(content, tool) -- 1160
	local lines = __TS__StringSplit(content, "\n") -- 1161
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1162
	local limitedByLines = overLineLimit and table.concat( -- 1163
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1164
		"\n" -- 1164
	) or content -- 1164
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1164
		return content -- 1167
	end -- 1167
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1169
	local reasons = {} -- 1172
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1172
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1173
	end -- 1173
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1173
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1174
	end -- 1174
	local hint = "Narrow the requested line range." -- 1175
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1176
end -- 1176
function sanitizeReadResultForHistory(tool, result) -- 1191
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1191
		return result -- 1193
	end -- 1193
	local clone = {} -- 1195
	for key in pairs(result) do -- 1196
		clone[key] = result[key] -- 1197
	end -- 1197
	clone.content = limitReadContentForHistory(result.content, tool) -- 1199
	return clone -- 1200
end -- 1200
function sanitizeSearchMatchesForHistory(items, maxItems) -- 1203
	local shown = math.min(#items, maxItems) -- 1207
	local out = {} -- 1208
	do -- 1208
		local i = 0 -- 1209
		while i < shown do -- 1209
			local row = items[i + 1] -- 1210
			out[#out + 1] = { -- 1211
				file = row.file, -- 1212
				line = row.line, -- 1213
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1214
			} -- 1214
			i = i + 1 -- 1209
		end -- 1209
	end -- 1209
	return out -- 1219
end -- 1219
function sanitizeSearchResultForHistory(tool, result) -- 1222
	if result.success ~= true or not isArray(result.results) then -- 1222
		return result -- 1226
	end -- 1226
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1226
		return result -- 1227
	end -- 1227
	local clone = {} -- 1228
	for key in pairs(result) do -- 1229
		clone[key] = result[key] -- 1230
	end -- 1230
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1232
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1233
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1233
		local grouped = result.groupedResults -- 1238
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1239
		local sanitizedGroups = {} -- 1240
		do -- 1240
			local i = 0 -- 1241
			while i < shown do -- 1241
				local row = grouped[i + 1] -- 1242
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1243
					file = row.file, -- 1244
					totalMatches = row.totalMatches, -- 1245
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1246
				} -- 1246
				i = i + 1 -- 1241
			end -- 1241
		end -- 1241
		clone.groupedResults = sanitizedGroups -- 1251
	end -- 1251
	return clone -- 1253
end -- 1253
function sanitizeListFilesResultForHistory(result) -- 1256
	if result.success ~= true or not isArray(result.files) then -- 1256
		return result -- 1257
	end -- 1257
	local clone = {} -- 1258
	for key in pairs(result) do -- 1259
		clone[key] = result[key] -- 1260
	end -- 1260
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1262
	return clone -- 1263
end -- 1263
function sanitizeBuildResultForHistory(result) -- 1266
	if not isArray(result.messages) then -- 1266
		return result -- 1267
	end -- 1267
	local clone = {} -- 1268
	for key in pairs(result) do -- 1269
		clone[key] = result[key] -- 1270
	end -- 1270
	local messages = result.messages -- 1272
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1273
	local sanitized = {} -- 1274
	do -- 1274
		local i = 0 -- 1275
		while i < shown do -- 1275
			local item = messages[i + 1] -- 1276
			local next = {} -- 1277
			for key in pairs(item) do -- 1278
				local value = item[key] -- 1279
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1280
			end -- 1280
			sanitized[#sanitized + 1] = next -- 1284
			i = i + 1 -- 1275
		end -- 1275
	end -- 1275
	clone.messages = sanitized -- 1286
	if #messages > shown then -- 1286
		clone.truncatedMessages = #messages - shown -- 1288
	end -- 1288
	return clone -- 1290
end -- 1290
function getDecisionToolDefinitions(shared) -- 1308
	if shared ~= nil and shared.promptCache.decisionToolDefinitions ~= nil and shared.promptCache.decisionToolDefinitionsRole == shared.role and shared.promptCache.decisionToolDefinitionsMode == shared.decisionMode then -- 1308
		return shared.promptCache.decisionToolDefinitions -- 1315
	end -- 1315
	local base = replacePromptVars( -- 1317
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1318
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1319
	) -- 1319
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1321
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1342
		getAllowedToolsForRole(shared.role), -- 1343
		", " -- 1343
	) or "" -- 1343
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1345
	local result -- 1346
	if (shared and shared.decisionMode) ~= "xml" then -- 1346
		result = withRole -- 1348
	else -- 1348
		result = withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1350
	end -- 1350
	if shared ~= nil then -- 1350
		shared.promptCache.decisionToolDefinitions = result -- 1359
		shared.promptCache.decisionToolDefinitionsRole = shared.role -- 1360
		shared.promptCache.decisionToolDefinitionsMode = shared.decisionMode -- 1361
	end -- 1361
	return result -- 1363
end -- 1363
function isCacheableReadOnlyTool(tool) -- 1384
	return tool == "read_file" or tool == "grep_files" or tool == "search_dora_api" or tool == "glob_files" -- 1385
end -- 1385
function shouldInvalidateToolCacheAfterResult(tool, result) -- 1391
	if tool == "build" then -- 1391
		return true -- 1392
	end -- 1392
	if tool == "edit_file" or tool == "delete_file" then -- 1392
		return result.success == true -- 1394
	end -- 1394
	return false -- 1396
end -- 1396
function stableToolCacheValue(value) -- 1414
	if value == nil or value == nil then -- 1414
		return "nil" -- 1415
	end -- 1415
	local kind = __TS__TypeOf(value) -- 1416
	if kind == "string" then -- 1416
		local text = value -- 1418
		return (("s" .. tostring(#text)) .. ":") .. text -- 1419
	end -- 1419
	if kind == "number" or kind == "boolean" then -- 1419
		return (kind .. ":") .. tostring(value) -- 1422
	end -- 1422
	if isArray(value) then -- 1422
		local parts = {} -- 1425
		do -- 1425
			local i = 0 -- 1426
			while i < #value do -- 1426
				parts[#parts + 1] = stableToolCacheValue(value[i + 1]) -- 1427
				i = i + 1 -- 1426
			end -- 1426
		end -- 1426
		return ((("a" .. tostring(#parts)) .. ":[") .. table.concat(parts, "|")) .. "]" -- 1429
	end -- 1429
	if kind == "object" then -- 1429
		local record = value -- 1432
		local keys = __TS__ObjectKeys(record) -- 1433
		__TS__ArraySort(keys) -- 1434
		local parts = {} -- 1435
		do -- 1435
			local i = 0 -- 1436
			while i < #keys do -- 1436
				local key = keys[i + 1] -- 1437
				parts[#parts + 1] = (((("k" .. tostring(#key)) .. ":") .. key) .. "=") .. stableToolCacheValue(record[key]) -- 1438
				i = i + 1 -- 1436
			end -- 1436
		end -- 1436
		return ((("o" .. tostring(#parts)) .. ":{") .. table.concat(parts, "|")) .. "}" -- 1440
	end -- 1440
	return (kind .. ":") .. tostring(value) -- 1442
end -- 1442
function createToolActionCacheKey(shared, action) -- 1445
	return stableToolCacheValue({ -- 1446
		version = 1, -- 1447
		workingDir = shared.workingDir, -- 1448
		language = shared.useChineseResponse and "zh" or "en", -- 1449
		tool = action.tool, -- 1450
		params = action.params -- 1451
	}) -- 1451
end -- 1451
function cloneToolCacheValue(value) -- 1455
	if value == nil or value == nil then -- 1455
		return value -- 1456
	end -- 1456
	if isArray(value) then -- 1456
		return __TS__ArrayMap( -- 1458
			value, -- 1458
			function(____, item) return cloneToolCacheValue(item) end -- 1458
		) -- 1458
	end -- 1458
	if type(value) == "table" then -- 1458
		local clone = {} -- 1461
		for key in pairs(value) do -- 1462
			clone[key] = cloneToolCacheValue(value[key]) -- 1463
		end -- 1463
		return clone -- 1465
	end -- 1465
	return value -- 1467
end -- 1467
function cloneToolCacheResult(result) -- 1470
	return cloneToolCacheValue(result) -- 1471
end -- 1471
function evictOldestToolCacheEntry(cache) -- 1474
	if cache.readonlyResults.size < cache.maxEntries then -- 1474
		return -- 1475
	end -- 1475
	cache.readonlyResults:clear() -- 1476
	cache.evictions = cache.evictions + 1 -- 1477
end -- 1477
function getCachedToolActionResult(shared, action, cacheKey) -- 1480
	local cache = shared.toolCache -- 1481
	local entry = cache.readonlyResults:get(cacheKey) -- 1482
	if entry == nil then -- 1482
		return nil -- 1483
	end -- 1483
	entry.usedAtStep = shared.step -- 1484
	cache.hits = cache.hits + 1 -- 1485
	Log( -- 1486
		"Info", -- 1486
		(("[CodingAgent] tool cache hit tool=" .. action.tool) .. " hits=") .. tostring(cache.hits) -- 1486
	) -- 1486
	return cloneToolCacheResult(entry.result) -- 1487
end -- 1487
function rememberToolActionResult(shared, action, cacheKey, result) -- 1490
	local cache = shared.toolCache -- 1491
	evictOldestToolCacheEntry(cache) -- 1492
	cache.readonlyResults:set( -- 1493
		cacheKey, -- 1493
		{ -- 1493
			result = cloneToolCacheResult(result), -- 1494
			insertedAtStep = shared.step, -- 1495
			usedAtStep = shared.step -- 1496
		} -- 1496
	) -- 1496
	cache.stores = cache.stores + 1 -- 1498
	Log( -- 1499
		"Info", -- 1499
		(((("[CodingAgent] tool cache store tool=" .. action.tool) .. " size=") .. tostring(cache.readonlyResults.size)) .. " stores=") .. tostring(cache.stores) -- 1499
	) -- 1499
end -- 1499
function invalidateReadOnlyToolCache(shared, reason) -- 1502
	local cache = shared.toolCache -- 1503
	if cache.readonlyResults.size == 0 and cache.readonlyInFlight.size == 0 then -- 1503
		cache.version = cache.version + 1 -- 1505
		return -- 1506
	end -- 1506
	local size = cache.readonlyResults.size -- 1508
	local pending = cache.readonlyInFlight.size -- 1509
	cache.readonlyResults:clear() -- 1510
	cache.readonlyInFlight:clear() -- 1511
	cache.version = cache.version + 1 -- 1512
	cache.invalidations = cache.invalidations + 1 -- 1513
	Log( -- 1514
		"Info", -- 1514
		(((((("[CodingAgent] tool cache invalidated reason=" .. reason) .. " cleared=") .. tostring(size)) .. " pending=") .. tostring(pending)) .. " invalidations=") .. tostring(cache.invalidations) -- 1514
	) -- 1514
end -- 1514
function getFinishMessage(params, fallback) -- 1847
	if fallback == nil then -- 1847
		fallback = "" -- 1847
	end -- 1847
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1847
		return __TS__StringTrim(params.message) -- 1849
	end -- 1849
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1849
		return __TS__StringTrim(params.response) -- 1852
	end -- 1852
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1852
		return __TS__StringTrim(params.summary) -- 1855
	end -- 1855
	return __TS__StringTrim(fallback) -- 1857
end -- 1857
function persistHistoryState(shared) -- 1860
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1861
end -- 1861
function getActiveConversationMessages(shared) -- 1868
	local activeMessages = {} -- 1869
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1869
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1876
	end -- 1876
	do -- 1876
		local i = shared.lastConsolidatedIndex -- 1880
		while i < #shared.messages do -- 1880
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1881
			i = i + 1 -- 1880
		end -- 1880
	end -- 1880
	return activeMessages -- 1883
end -- 1883
function getActiveRealMessageCount(shared) -- 1886
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1887
end -- 1887
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1890
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1895
	local previousActiveStart = shared.lastConsolidatedIndex -- 1896
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1897
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1898
	if type(carryMessageIndex) == "number" then -- 1898
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1898
		else -- 1898
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1906
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1909
		end -- 1909
	else -- 1909
		shared.carryMessageIndex = nil -- 1914
	end -- 1914
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1914
		shared.carryMessageIndex = nil -- 1924
	end -- 1924
end -- 1924
function getDecisionPath(params) -- 2182
	if type(params.path) == "string" then -- 2182
		return __TS__StringTrim(params.path) -- 2183
	end -- 2183
	if type(params.target_file) == "string" then -- 2183
		return __TS__StringTrim(params.target_file) -- 2184
	end -- 2184
	return "" -- 2185
end -- 2185
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2188
	local num = __TS__Number(value) -- 2189
	if not __TS__NumberIsFinite(num) then -- 2189
		num = fallback -- 2190
	end -- 2190
	num = math.floor(num) -- 2191
	if num < minValue then -- 2191
		num = minValue -- 2192
	end -- 2192
	if maxValue ~= nil and num > maxValue then -- 2192
		num = maxValue -- 2193
	end -- 2193
	return num -- 2194
end -- 2194
function parseReadLineParam(value, fallback, paramName) -- 2197
	local num = __TS__Number(value) -- 2202
	if not __TS__NumberIsFinite(num) then -- 2202
		num = fallback -- 2203
	end -- 2203
	num = math.floor(num) -- 2204
	if num == 0 then -- 2204
		return {success = false, message = paramName .. " cannot be 0"} -- 2206
	end -- 2206
	return {success = true, value = num} -- 2208
end -- 2208
function validateDecision(tool, params) -- 2211
	if tool == "finish" then -- 2211
		local message = getFinishMessage(params) -- 2216
		if message == "" then -- 2216
			return {success = false, message = "finish requires params.message"} -- 2217
		end -- 2217
		params.message = message -- 2218
		return {success = true, params = params} -- 2219
	end -- 2219
	if tool == "read_file" then -- 2219
		local path = getDecisionPath(params) -- 2223
		if path == "" then -- 2223
			return {success = false, message = "read_file requires path"} -- 2224
		end -- 2224
		params.path = path -- 2225
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2226
		if not startLineRes.success then -- 2226
			return startLineRes -- 2227
		end -- 2227
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 2228
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2229
		if not endLineRes.success then -- 2229
			return endLineRes -- 2230
		end -- 2230
		params.startLine = startLineRes.value -- 2231
		params.endLine = endLineRes.value -- 2232
		return {success = true, params = params} -- 2233
	end -- 2233
	if tool == "edit_file" then -- 2233
		local path = getDecisionPath(params) -- 2237
		if path == "" then -- 2237
			return {success = false, message = "edit_file requires path"} -- 2238
		end -- 2238
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2239
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2240
		params.path = path -- 2241
		params.old_str = oldStr -- 2242
		params.new_str = newStr -- 2243
		return {success = true, params = params} -- 2244
	end -- 2244
	if tool == "delete_file" then -- 2244
		local targetFile = getDecisionPath(params) -- 2248
		if targetFile == "" then -- 2248
			return {success = false, message = "delete_file requires target_file"} -- 2249
		end -- 2249
		params.target_file = targetFile -- 2250
		return {success = true, params = params} -- 2251
	end -- 2251
	if tool == "grep_files" then -- 2251
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2255
		if pattern == "" then -- 2255
			return {success = false, message = "grep_files requires pattern"} -- 2256
		end -- 2256
		params.pattern = pattern -- 2257
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 2258
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2259
		return {success = true, params = params} -- 2260
	end -- 2260
	if tool == "search_dora_api" then -- 2260
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2264
		if pattern == "" then -- 2264
			return {success = false, message = "search_dora_api requires pattern"} -- 2265
		end -- 2265
		params.pattern = pattern -- 2266
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2267
		return {success = true, params = params} -- 2268
	end -- 2268
	if tool == "glob_files" then -- 2268
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2272
		return {success = true, params = params} -- 2273
	end -- 2273
	if tool == "build" then -- 2273
		local path = getDecisionPath(params) -- 2277
		if path ~= "" then -- 2277
			params.path = path -- 2279
		end -- 2279
		return {success = true, params = params} -- 2281
	end -- 2281
	if tool == "list_sub_agents" then -- 2281
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2285
		if status ~= "" then -- 2285
			params.status = status -- 2287
		end -- 2287
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2289
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2290
		if type(params.query) == "string" then -- 2290
			params.query = __TS__StringTrim(params.query) -- 2292
		end -- 2292
		return {success = true, params = params} -- 2294
	end -- 2294
	if tool == "spawn_sub_agent" then -- 2294
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2298
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2299
		if prompt == "" then -- 2299
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2300
		end -- 2300
		if title == "" then -- 2300
			return {success = false, message = "spawn_sub_agent requires title"} -- 2301
		end -- 2301
		params.prompt = prompt -- 2302
		params.title = title -- 2303
		if type(params.expectedOutput) == "string" then -- 2303
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2305
		end -- 2305
		if isArray(params.filesHint) then -- 2305
			params.filesHint = __TS__ArrayMap( -- 2308
				__TS__ArrayFilter( -- 2308
					params.filesHint, -- 2308
					function(____, item) return type(item) == "string" end -- 2309
				), -- 2309
				function(____, item) return sanitizeUTF8(item) end -- 2310
			) -- 2310
		end -- 2310
		return {success = true, params = params} -- 2312
	end -- 2312
	return {success = true, params = params} -- 2315
end -- 2315
function getAllowedToolsForRole(role) -- 2341
	return role == "main" and ({ -- 2342
		"read_file", -- 2343
		"edit_file", -- 2343
		"delete_file", -- 2343
		"grep_files", -- 2343
		"search_dora_api", -- 2343
		"glob_files", -- 2343
		"build", -- 2343
		"list_sub_agents", -- 2343
		"spawn_sub_agent", -- 2343
		"finish" -- 2343
	}) or ({ -- 2343
		"read_file", -- 2344
		"edit_file", -- 2344
		"delete_file", -- 2344
		"grep_files", -- 2344
		"search_dora_api", -- 2344
		"glob_files", -- 2344
		"build", -- 2344
		"finish" -- 2344
	}) -- 2344
end -- 2344
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2459
	if includeToolDefinitions == nil then -- 2459
		includeToolDefinitions = false -- 2459
	end -- 2459
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2460
	local sections = { -- 2463
		shared.promptPack.agentIdentityPrompt, -- 2464
		rolePrompt, -- 2465
		getReplyLanguageDirective(shared) -- 2466
	} -- 2466
	if shared.decisionMode == "tool_calling" then -- 2466
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2469
	end -- 2469
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2471
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2472
	if memoryContext ~= "" then -- 2472
		sections[#sections + 1] = memoryContext -- 2474
	end -- 2474
	if includeToolDefinitions then -- 2474
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2477
		if shared.decisionMode == "xml" then -- 2477
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2479
		end -- 2479
	end -- 2479
	local skillsSection = buildSkillsSection(shared) -- 2483
	if skillsSection ~= "" then -- 2483
		sections[#sections + 1] = skillsSection -- 2485
	end -- 2485
	return table.concat(sections, "\n\n") -- 2487
end -- 2487
function buildSkillsSection(shared) -- 2490
	local ____opt_42 = shared.skills -- 2490
	if not (____opt_42 and ____opt_42.loader) then -- 2490
		return "" -- 2492
	end -- 2492
	return shared.skills.loader:buildSkillsPromptSection() -- 2494
end -- 2494
function buildXmlDecisionInstruction(shared, feedback) -- 2663
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2664
end -- 2664
function executeToolActionUncached(shared, action) -- 3933
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3933
		if shared.stopToken.stopped then -- 3933
			return ____awaiter_resolve( -- 3933
				nil, -- 3933
				{ -- 3935
					success = false, -- 3935
					message = getCancelledReason(shared) -- 3935
				} -- 3935
			) -- 3935
		end -- 3935
		local params = action.params -- 3937
		if action.tool == "read_file" then -- 3937
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3939
			if __TS__StringTrim(path) == "" then -- 3939
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3939
			end -- 3939
			local ____Tools_readFile_104 = Tools.readFile -- 3943
			local ____shared_workingDir_102 = shared.workingDir -- 3944
			local ____params_startLine_100 = params.startLine -- 3946
			if ____params_startLine_100 == nil then -- 3946
				____params_startLine_100 = 1 -- 3946
			end -- 3946
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3946
			local ____params_endLine_101 = params.endLine -- 3947
			if ____params_endLine_101 == nil then -- 3947
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3947
			end -- 3947
			return ____awaiter_resolve( -- 3947
				nil, -- 3947
				____Tools_readFile_104( -- 3943
					____shared_workingDir_102, -- 3944
					path, -- 3945
					____TS__Number_result_103, -- 3946
					__TS__Number(____params_endLine_101), -- 3947
					shared.useChineseResponse and "zh" or "en" -- 3948
				) -- 3948
			) -- 3948
		end -- 3948
		if action.tool == "grep_files" then -- 3948
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3952
			local ____shared_workingDir_111 = shared.workingDir -- 3953
			local ____temp_112 = params.path or "" -- 3954
			local ____temp_113 = params.pattern or "" -- 3955
			local ____params_globs_114 = params.globs -- 3956
			local ____params_useRegex_115 = params.useRegex -- 3957
			local ____params_caseSensitive_116 = params.caseSensitive -- 3958
			local ____math_max_107 = math.max -- 3961
			local ____math_floor_106 = math.floor -- 3961
			local ____params_limit_105 = params.limit -- 3961
			if ____params_limit_105 == nil then -- 3961
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3961
			end -- 3961
			local ____math_max_107_result_117 = ____math_max_107( -- 3961
				1, -- 3961
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3961
			) -- 3961
			local ____math_max_110 = math.max -- 3962
			local ____math_floor_109 = math.floor -- 3962
			local ____params_offset_108 = params.offset -- 3962
			if ____params_offset_108 == nil then -- 3962
				____params_offset_108 = 0 -- 3962
			end -- 3962
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3952
				workDir = ____shared_workingDir_111, -- 3953
				path = ____temp_112, -- 3954
				pattern = ____temp_113, -- 3955
				globs = ____params_globs_114, -- 3956
				useRegex = ____params_useRegex_115, -- 3957
				caseSensitive = ____params_caseSensitive_116, -- 3958
				includeContent = true, -- 3959
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3960
				limit = ____math_max_107_result_117, -- 3961
				offset = ____math_max_110( -- 3962
					0, -- 3962
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3962
				), -- 3962
				groupByFile = params.groupByFile == true -- 3963
			})) -- 3963
			return ____awaiter_resolve(nil, result) -- 3963
		end -- 3963
		if action.tool == "search_dora_api" then -- 3963
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3968
			local ____temp_122 = params.pattern or "" -- 3969
			local ____temp_123 = params.docSource or "api" -- 3970
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3971
			local ____temp_125 = params.programmingLanguage or "ts" -- 3972
			local ____math_min_121 = math.min -- 3973
			local ____math_max_120 = math.max -- 3973
			local ____params_limit_119 = params.limit -- 3973
			if ____params_limit_119 == nil then -- 3973
				____params_limit_119 = 8 -- 3973
			end -- 3973
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3968
				pattern = ____temp_122, -- 3969
				docSource = ____temp_123, -- 3970
				docLanguage = ____temp_124, -- 3971
				programmingLanguage = ____temp_125, -- 3972
				limit = ____math_min_121( -- 3973
					SEARCH_DORA_API_LIMIT_MAX, -- 3973
					____math_max_120( -- 3973
						1, -- 3973
						__TS__Number(____params_limit_119) -- 3973
					) -- 3973
				), -- 3973
				useRegex = params.useRegex, -- 3974
				caseSensitive = false, -- 3975
				includeContent = true, -- 3976
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3977
			})) -- 3977
			return ____awaiter_resolve(nil, result) -- 3977
		end -- 3977
		if action.tool == "glob_files" then -- 3977
			local ____Tools_listFiles_133 = Tools.listFiles -- 3982
			local ____shared_workingDir_130 = shared.workingDir -- 3983
			local ____temp_131 = params.path or "" -- 3984
			local ____params_globs_132 = params.globs -- 3985
			local ____math_max_129 = math.max -- 3986
			local ____math_floor_128 = math.floor -- 3986
			local ____params_maxEntries_127 = params.maxEntries -- 3986
			if ____params_maxEntries_127 == nil then -- 3986
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3986
			end -- 3986
			local result = ____Tools_listFiles_133({ -- 3982
				workDir = ____shared_workingDir_130, -- 3983
				path = ____temp_131, -- 3984
				globs = ____params_globs_132, -- 3985
				maxEntries = ____math_max_129( -- 3986
					1, -- 3986
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3986
				) -- 3986
			}) -- 3986
			return ____awaiter_resolve(nil, result) -- 3986
		end -- 3986
		if action.tool == "delete_file" then -- 3986
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3991
			if __TS__StringTrim(targetFile) == "" then -- 3991
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3991
			end -- 3991
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3995
			if not result.success then -- 3995
				return ____awaiter_resolve(nil, result) -- 3995
			end -- 3995
			return ____awaiter_resolve(nil, { -- 3995
				success = true, -- 4003
				changed = true, -- 4004
				mode = "delete", -- 4005
				checkpointId = result.checkpointId, -- 4006
				checkpointSeq = result.checkpointSeq, -- 4007
				files = {{path = targetFile, op = "delete"}} -- 4008
			}) -- 4008
		end -- 4008
		if action.tool == "build" then -- 4008
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 4012
			return ____awaiter_resolve(nil, result) -- 4012
		end -- 4012
		if action.tool == "spawn_sub_agent" then -- 4012
			if not shared.spawnSubAgent then -- 4012
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4012
			end -- 4012
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4012
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4012
			end -- 4012
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4025
				params.filesHint, -- 4026
				function(____, item) return type(item) == "string" end -- 4026
			) or nil -- 4026
			local result = __TS__Await(shared.spawnSubAgent({ -- 4028
				parentSessionId = shared.sessionId, -- 4029
				projectRoot = shared.workingDir, -- 4030
				title = type(params.title) == "string" and params.title or "Sub", -- 4031
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4032
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4033
				filesHint = filesHint -- 4034
			})) -- 4034
			if not result.success then -- 4034
				return ____awaiter_resolve(nil, result) -- 4034
			end -- 4034
			return ____awaiter_resolve(nil, { -- 4034
				success = true, -- 4040
				sessionId = result.sessionId, -- 4041
				taskId = result.taskId, -- 4042
				title = result.title, -- 4043
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 4044
			}) -- 4044
		end -- 4044
		if action.tool == "list_sub_agents" then -- 4044
			if not shared.listSubAgents then -- 4044
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4044
			end -- 4044
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4044
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4044
			end -- 4044
			local result = __TS__Await(shared.listSubAgents({ -- 4054
				sessionId = shared.sessionId, -- 4055
				projectRoot = shared.workingDir, -- 4056
				status = type(params.status) == "string" and params.status or nil, -- 4057
				limit = type(params.limit) == "number" and params.limit or nil, -- 4058
				offset = type(params.offset) == "number" and params.offset or nil, -- 4059
				query = type(params.query) == "string" and params.query or nil -- 4060
			})) -- 4060
			return ____awaiter_resolve(nil, result) -- 4060
		end -- 4060
		if action.tool == "edit_file" then -- 4060
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4065
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4068
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4069
			if __TS__StringTrim(path) == "" then -- 4069
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4069
			end -- 4069
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4071
			return ____awaiter_resolve( -- 4071
				nil, -- 4071
				actionNode:exec({ -- 4072
					path = path, -- 4073
					oldStr = oldStr, -- 4074
					newStr = newStr, -- 4075
					taskId = shared.taskId, -- 4076
					workDir = shared.workingDir -- 4077
				}) -- 4077
			) -- 4077
		end -- 4077
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4077
	end) -- 4077
end -- 4077
function executeToolAction(shared, action) -- 4083
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4083
		if shared.stopToken.stopped then -- 4083
			return ____awaiter_resolve( -- 4083
				nil, -- 4083
				{ -- 4085
					success = false, -- 4085
					message = getCancelledReason(shared) -- 4085
				} -- 4085
			) -- 4085
		end -- 4085
		if not isCacheableReadOnlyTool(action.tool) then -- 4085
			local result = __TS__Await(executeToolActionUncached(shared, action)) -- 4088
			if shouldInvalidateToolCacheAfterResult(action.tool, result) then -- 4088
				invalidateReadOnlyToolCache(shared, action.tool) -- 4090
			end -- 4090
			return ____awaiter_resolve(nil, result) -- 4090
		end -- 4090
		local cacheKey = createToolActionCacheKey(shared, action) -- 4095
		local cached = getCachedToolActionResult(shared, action, cacheKey) -- 4096
		if cached ~= nil then -- 4096
			return ____awaiter_resolve(nil, cached) -- 4096
		end -- 4096
		local pending = shared.toolCache.readonlyInFlight:get(cacheKey) -- 4101
		if pending ~= nil then -- 4101
			local ____shared_toolCache_134, ____pendingHits_135 = shared.toolCache, "pendingHits" -- 4101
			____shared_toolCache_134[____pendingHits_135] = ____shared_toolCache_134[____pendingHits_135] + 1 -- 4103
			Log( -- 4104
				"Info", -- 4104
				(("[CodingAgent] tool cache pending-hit tool=" .. action.tool) .. " pending_hits=") .. tostring(shared.toolCache.pendingHits) -- 4104
			) -- 4104
			local pendingResult = __TS__Await(pending) -- 4105
			return ____awaiter_resolve( -- 4105
				nil, -- 4105
				cloneToolCacheResult(pendingResult) -- 4106
			) -- 4106
		end -- 4106
		local ____shared_toolCache_136, ____misses_137 = shared.toolCache, "misses" -- 4106
		____shared_toolCache_136[____misses_137] = ____shared_toolCache_136[____misses_137] + 1 -- 4109
		local cacheVersion = shared.toolCache.version -- 4110
		local promise = executeToolActionUncached(shared, action) -- 4111
		shared.toolCache.readonlyInFlight:set(cacheKey, promise) -- 4112
		local ____hasReturned, ____returnValue -- 4112
		local ____try = __TS__AsyncAwaiter(function() -- 4112
			local result = __TS__Await(promise) -- 4114
			if shared.toolCache.version == cacheVersion then -- 4114
				rememberToolActionResult(shared, action, cacheKey, result) -- 4116
			end -- 4116
			____hasReturned = true -- 4118
			____returnValue = cloneToolCacheResult(result) -- 4118
			return -- 4118
		end) -- 4118
		____try = ____try.finally( -- 4118
			____try, -- 4118
			function() -- 4118
				return __TS__AsyncAwaiter(function() -- 4118
					shared.toolCache.readonlyInFlight:delete(cacheKey) -- 4120
				end) -- 4120
			end -- 4120
		) -- 4120
		__TS__Await(____try) -- 4113
		if ____hasReturned then -- 4113
			return ____awaiter_resolve(nil, ____returnValue) -- 4113
		end -- 4113
	end) -- 4113
end -- 4113
function sanitizeToolActionResultForHistory(action, result) -- 4124
	if action.tool == "read_file" then -- 4124
		return sanitizeReadResultForHistory(action.tool, result) -- 4126
	end -- 4126
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4126
		return sanitizeSearchResultForHistory(action.tool, result) -- 4129
	end -- 4129
	if action.tool == "glob_files" then -- 4129
		return sanitizeListFilesResultForHistory(result) -- 4132
	end -- 4132
	if action.tool == "build" then -- 4132
		return sanitizeBuildResultForHistory(result) -- 4135
	end -- 4135
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4135
		if result.success ~= true then -- 4135
			return result -- 4138
		end -- 4138
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4138
			return result -- 4139
		end -- 4139
		if isArray(result.fileContext) then -- 4139
			return result -- 4140
		end -- 4140
		local contextLimits = { -- 4142
			fullContentChars = 12000, -- 4143
			previewChars = 4000, -- 4144
			diffChars = 8000, -- 4145
			totalChars = 24000, -- 4146
			maxFiles = 8 -- 4147
		} -- 4147
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4149
			if maxChars <= 0 then -- 4149
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4150
			end -- 4150
			if #sourceText <= maxChars then -- 4150
				return sourceText -- 4151
			end -- 4151
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4152
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4153
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4154
		end -- 4149
		local function countLines(sourceText) -- 4156
			if sourceText == "" then -- 4156
				return 0 -- 4157
			end -- 4157
			return #__TS__StringSplit(sourceText, "\n") -- 4158
		end -- 4156
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4160
			if beforeContent == afterContent then -- 4160
				return "" -- 4161
			end -- 4161
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4162
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4163
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4165
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4165
				firstChangedLine = firstChangedLine + 1 -- 4171
			end -- 4171
			local lastChangedBeforeLine = #beforeLines - 1 -- 4173
			local lastChangedAfterLine = #afterLines - 1 -- 4174
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4174
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4180
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4181
			end -- 4181
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4183
			local previewEndLine = math.max( -- 4184
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4185
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4186
			) -- 4186
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4188
			do -- 4188
				local lineIndex = previewStartLine -- 4189
				while lineIndex <= previewEndLine do -- 4189
					do -- 4189
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4190
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4191
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4192
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4193
						if not beforeChanged and not afterChanged then -- 4193
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4195
							if contextLine ~= nil then -- 4195
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4196
							end -- 4196
							goto __continue663 -- 4197
						end -- 4197
						if beforeChanged and beforeLine ~= nil then -- 4197
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4199
						end -- 4199
						if afterChanged and afterLine ~= nil then -- 4199
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4200
						end -- 4200
					end -- 4200
					::__continue663:: -- 4200
					lineIndex = lineIndex + 1 -- 4189
				end -- 4189
			end -- 4189
			return truncateContextSnippet( -- 4202
				table.concat(unifiedDiffLines, "\n"), -- 4202
				maxChars, -- 4202
				"diff" -- 4202
			) -- 4202
		end -- 4160
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4205
		if not checkpointDiff.success then -- 4205
			return result -- 4206
		end -- 4206
		local remainingContextBudget = contextLimits.totalChars -- 4207
		local fileContextItems = {} -- 4208
		local changedFiles = checkpointDiff.files -- 4209
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4210
		do -- 4210
			local fileIndex = 0 -- 4211
			while fileIndex < maxContextFiles do -- 4211
				if remainingContextBudget <= 0 then -- 4211
					break -- 4212
				end -- 4212
				local changedFile = changedFiles[fileIndex + 1] -- 4213
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4214
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4215
				local contextItem = { -- 4216
					path = changedFile.path, -- 4217
					op = changedFile.op, -- 4218
					checkpointId = result.checkpointId, -- 4219
					checkpointSeq = result.checkpointSeq, -- 4220
					beforeExists = changedFile.beforeExists, -- 4221
					afterExists = changedFile.afterExists, -- 4222
					beforeBytes = #beforeContent, -- 4223
					afterBytes = #afterContent, -- 4224
					diffPreview = "", -- 4225
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4226
					contentTruncated = false, -- 4227
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4228
				} -- 4228
				if changedFile.afterExists then -- 4228
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4228
						contextItem.afterContent = afterContent -- 4232
						remainingContextBudget = remainingContextBudget - #afterContent -- 4233
					else -- 4233
						contextItem.afterContentPreview = truncateContextSnippet( -- 4235
							afterContent, -- 4236
							math.min( -- 4237
								contextLimits.previewChars, -- 4237
								math.max(400, remainingContextBudget) -- 4237
							), -- 4237
							"afterContent" -- 4238
						) -- 4238
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4240
						contextItem.contentTruncated = true -- 4241
					end -- 4241
				end -- 4241
				local diffPreview = buildUnifiedDiffPreview( -- 4244
					changedFile.path, -- 4245
					beforeContent, -- 4246
					afterContent, -- 4247
					math.min( -- 4248
						contextLimits.diffChars, -- 4248
						math.max(400, remainingContextBudget) -- 4248
					) -- 4248
				) -- 4248
				contextItem.diffPreview = diffPreview -- 4250
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4251
				if not changedFile.afterExists and beforeContent ~= "" then -- 4251
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4253
						beforeContent, -- 4254
						math.min( -- 4255
							contextLimits.previewChars, -- 4255
							math.max(400, remainingContextBudget) -- 4255
						), -- 4255
						"beforeContent" -- 4256
					) -- 4256
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4258
					if #beforeContent > contextLimits.previewChars then -- 4258
						contextItem.contentTruncated = true -- 4259
					end -- 4259
				end -- 4259
				fileContextItems[#fileContextItems + 1] = contextItem -- 4261
				fileIndex = fileIndex + 1 -- 4211
			end -- 4211
		end -- 4211
		if #fileContextItems == 0 then -- 4211
			return result -- 4263
		end -- 4263
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4264
	end -- 4264
	return result -- 4271
end -- 4271
function emitAgentTaskFinishEvent(shared, success, message) -- 4438
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 4439
	emitAgentEvent(shared, { -- 4445
		type = "task_finished", -- 4446
		sessionId = shared.sessionId, -- 4447
		taskId = shared.taskId, -- 4448
		success = result.success, -- 4449
		message = result.message, -- 4450
		steps = result.steps -- 4451
	}) -- 4451
	return result -- 4453
end -- 4453
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
function SkillsLoader.prototype.____constructor(self, config) -- 228
	self.skills = __TS__New(Map) -- 224
	self.loaded = false -- 225
	self.config = config -- 229
end -- 228
function SkillsLoader.prototype.load(self) -- 232
	self.skills:clear() -- 233
	self.promptSectionCache = nil -- 234
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 236
	local builtInParent = Content.assetPath -- 237
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 238
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 240
	local userParent = Content.writablePath -- 241
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 242
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 244
	local projectParent = self.config.projectDir -- 245
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 246
	self.loaded = true -- 248
	Log( -- 249
		"Info", -- 249
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 249
	) -- 249
end -- 232
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 252
	if not Content:exist(dir) or not Content:isdir(dir) then -- 252
		return -- 254
	end -- 254
	local subdirs = Content:getDirs(dir) -- 257
	if not subdirs or #subdirs == 0 then -- 257
		return -- 259
	end -- 259
	for ____, subdir in ipairs(subdirs) do -- 262
		do -- 262
			local skillPath = Path(dir, subdir, "SKILL.md") -- 263
			if not Content:exist(skillPath) then -- 263
				goto __continue39 -- 265
			end -- 265
			local skill = self:loadSkillFile(skillPath) -- 268
			if not skill then -- 268
				goto __continue39 -- 270
			end -- 270
			skill.location = Path:getRelative(skillPath, parent) -- 273
			local existing = self.skills:get(skill.name) -- 275
			if existing and existing.priority >= priority then -- 275
				goto __continue39 -- 277
			end -- 277
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 280
		end -- 280
		::__continue39:: -- 280
	end -- 280
end -- 252
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 284
	local content = Content:load(skillPath) -- 285
	if not content then -- 285
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 287
		return nil -- 288
	end -- 288
	local parsed = parseYAMLFrontmatter(content) -- 291
	local validated = validateSkillMetadata(parsed.metadata) -- 292
	if validated.error then -- 292
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 295
		return nil -- 296
	end -- 296
	local displayLocation = skillPath -- 299
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 299
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 301
	end -- 301
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 304
	return skill -- 310
end -- 284
function SkillsLoader.prototype.getAllSkills(self) -- 313
	if not self.loaded then -- 313
		self:load() -- 315
	end -- 315
	local result = {} -- 318
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 319
		result[#result + 1] = entry.skill -- 320
	end -- 320
	__TS__ArraySort( -- 323
		result, -- 323
		function(____, a, b) -- 323
			if a.name < b.name then -- 323
				return -1 -- 325
			end -- 325
			if a.name > b.name then -- 325
				return 1 -- 328
			end -- 328
			if a.location < b.location then -- 328
				return -1 -- 331
			end -- 331
			if a.location > b.location then -- 331
				return 1 -- 334
			end -- 334
			return 0 -- 336
		end -- 323
	) -- 323
	return result -- 339
end -- 313
function SkillsLoader.prototype.getSkill(self, name) -- 342
	if not self.loaded then -- 342
		self:load() -- 344
	end -- 344
	local ____opt_0 = self.skills:get(name) -- 344
	return ____opt_0 and ____opt_0.skill -- 347
end -- 342
function SkillsLoader.prototype.getAlwaysSkills(self) -- 350
	local all = self:getAllSkills() -- 351
	return __TS__ArrayFilter( -- 352
		all, -- 352
		function(____, skill) return skill.always == true end -- 352
	) -- 352
end -- 350
function SkillsLoader.prototype.getSummarySkills(self) -- 355
	local all = self:getAllSkills() -- 356
	return __TS__ArrayFilter( -- 357
		all, -- 357
		function(____, skill) return skill.always ~= true end -- 357
	) -- 357
end -- 355
function SkillsLoader.prototype.buildLevel1Summary(self) -- 360
	local skills = self:getSummarySkills() -- 361
	if #skills == 0 then -- 361
		return "" -- 364
	end -- 364
	local parts = {} -- 367
	for ____, skill in ipairs(skills) do -- 369
		local skillXML = "<skill>\n" -- 370
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 371
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 372
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 373
		skillXML = skillXML .. "</skill>" -- 374
		parts[#parts + 1] = skillXML -- 375
	end -- 375
	return table.concat(parts, "\n\n") -- 378
end -- 360
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 381
	local skills = self:getAlwaysSkills() -- 382
	if #skills == 0 then -- 382
		return "" -- 385
	end -- 385
	local parts = {} -- 388
	for ____, skill in ipairs(skills) do -- 390
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 391
		if skill.description ~= nil then -- 391
			parts[#parts + 1] = skill.description .. "\n" -- 393
		end -- 393
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 393
			parts[#parts + 1] = "\n" .. skill.body -- 396
		end -- 396
		parts[#parts + 1] = "" -- 398
	end -- 398
	return table.concat(parts, "\n") -- 401
end -- 381
function SkillsLoader.prototype.loadSkillContent(self, name) -- 404
	local skill = self:getSkill(name) -- 405
	if not skill then -- 405
		return nil -- 407
	end -- 407
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 407
		return skill.body -- 411
	end -- 411
	local content = Content:load(skill.location) -- 414
	if not content then -- 414
		return nil -- 416
	end -- 416
	local parsed = parseYAMLFrontmatter(content) -- 419
	return parsed.body or nil -- 420
end -- 404
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 423
	if not self.loaded then -- 423
		self:load() -- 425
	end -- 425
	if self.promptSectionCache ~= nil then -- 425
		return self.promptSectionCache -- 428
	end -- 428
	local sections = {} -- 431
	local activeContent = self:buildActiveSkillsContent() -- 433
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 434
	local summary = self:buildLevel1Summary() -- 436
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 437
	self.promptSectionCache = table.concat(sections, "\n\n---\n\n")
	return self.promptSectionCache -- 440
end -- 423
function SkillsLoader.prototype.escapeXML(self, text) -- 443
	return escapeXMLText(text) -- 444
end -- 443
function SkillsLoader.prototype.reload(self) -- 447
	self.loaded = false -- 448
	self.promptSectionCache = nil -- 449
	self:load() -- 450
end -- 447
function SkillsLoader.prototype.getSkillCount(self) -- 453
	if not self.loaded then -- 453
		self:load() -- 455
	end -- 455
	return self.skills.size -- 457
end -- 453
local function createSkillsLoader(config) -- 461
	return __TS__New(SkillsLoader, config) -- 462
end -- 461
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 546
HISTORY_READ_FILE_MAX_CHARS = 12000 -- 676
HISTORY_READ_FILE_MAX_LINES = 300 -- 677
READ_FILE_DEFAULT_LIMIT = 300 -- 678
HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 679
HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 680
HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 681
HISTORY_BUILD_MAX_MESSAGES = 50 -- 682
HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 683
SEARCH_DORA_API_LIMIT_MAX = 20 -- 684
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 685
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 686
SEARCH_PREVIEW_CONTEXT = 80 -- 687
local AGENT_DEFAULT_MAX_STEPS = 100 -- 688
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 689
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 690
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 691
local function buildLLMOptions(llmConfig, overrides) -- 693
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 694
	if llmConfig.reasoningEffort then -- 694
		options.reasoning_effort = llmConfig.reasoningEffort -- 699
	end -- 699
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 701
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 701
		__TS__Delete(merged, "reasoning_effort") -- 706
	else -- 706
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 708
	end -- 708
	return merged -- 710
end -- 693
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 825
	local messagesTokens = 0 -- 832
	do -- 832
		local i = 0 -- 833
		while i < #messages do -- 833
			local message = messages[i + 1] -- 834
			messagesTokens = messagesTokens + 8 -- 835
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 836
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 837
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 838
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 839
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 840
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 841
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 842
			i = i + 1 -- 833
		end -- 833
	end -- 833
	local toolDefinitionsTokens = 0 -- 845
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 845
		local toolsText = safeJsonEncode(options.tools) -- 847
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 848
	end -- 848
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 851
	__TS__Delete(optionsWithoutTools, "tools") -- 852
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 853
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 854
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 855
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 856
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 861
		1024, -- 863
		math.floor(contextWindow * 0.2) -- 863
	) -- 863
	local structuralOverhead = math.max(256, #messages * 16) -- 864
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 866
	local maxTokens = contextWindow -- 867
	emitAgentEvent( -- 868
		shared, -- 868
		{ -- 868
			type = "metrics_updated", -- 869
			sessionId = shared.sessionId, -- 870
			taskId = shared.taskId, -- 871
			step = step, -- 872
			metrics = {context = { -- 873
				usedTokens = usedTokens, -- 875
				maxTokens = maxTokens, -- 876
				ratio = math.max( -- 877
					0, -- 877
					math.min(1, usedTokens / maxTokens) -- 877
				), -- 877
				messagesTokens = messagesTokens, -- 878
				optionsTokens = optionsTokens, -- 879
				toolDefinitionsTokens = toolDefinitionsTokens, -- 880
				reservedOutputTokens = reservedOutputTokens, -- 881
				structuralOverhead = structuralOverhead, -- 882
				contextWindow = contextWindow, -- 883
				source = "llm_input_estimate", -- 884
				updatedAt = os.time(), -- 885
				phase = phase, -- 886
				step = step -- 887
			}} -- 887
		} -- 887
	) -- 887
end -- 825
local function emitAgentStartEvent(shared, action) -- 893
	emitAgentEvent(shared, { -- 894
		type = "tool_started", -- 895
		sessionId = shared.sessionId, -- 896
		taskId = shared.taskId, -- 897
		step = action.step, -- 898
		tool = action.tool -- 899
	}) -- 899
end -- 893
local function emitAgentFinishEvent(shared, action) -- 903
	emitAgentEvent(shared, { -- 904
		type = "tool_finished", -- 905
		sessionId = shared.sessionId, -- 906
		taskId = shared.taskId, -- 907
		step = action.step, -- 908
		tool = action.tool, -- 909
		result = action.result or ({}) -- 910
	}) -- 910
end -- 903
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 914
	emitAgentEvent(shared, { -- 915
		type = "assistant_message_updated", -- 916
		sessionId = shared.sessionId, -- 917
		taskId = shared.taskId, -- 918
		step = shared.step + 1, -- 919
		content = content, -- 920
		reasoningContent = reasoningContent -- 921
	}) -- 921
end -- 914
local function getMemoryCompressionStartReason(shared) -- 925
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 926
end -- 925
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 931
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 932
end -- 931
local function getMemoryCompressionFailureReason(shared, ____error) -- 937
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 938
end -- 937
local function summarizeHistoryEntryPreview(text, maxChars) -- 943
	if maxChars == nil then -- 943
		maxChars = 180 -- 943
	end -- 943
	local trimmed = __TS__StringTrim(text) -- 944
	if trimmed == "" then -- 944
		return "" -- 945
	end -- 945
	return truncateText(trimmed, maxChars) -- 946
end -- 943
local function getMaxStepsReachedReason(shared) -- 954
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 955
end -- 954
local function getFailureSummaryFallback(shared, ____error) -- 960
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 961
end -- 960
local function finalizeAgentFailure(shared, ____error) -- 966
	if shared.stopToken.stopped then -- 966
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 968
		return emitAgentTaskFinishEvent( -- 969
			shared, -- 969
			false, -- 969
			getCancelledReason(shared) -- 969
		) -- 969
	end -- 969
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 971
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 972
end -- 966
local function getPromptCommand(prompt) -- 975
	local trimmed = __TS__StringTrim(prompt) -- 976
	if trimmed == "/compact" then -- 976
		return "compact" -- 977
	end -- 977
	if trimmed == "/clear" then -- 977
		return "clear" -- 978
	end -- 978
	return nil -- 979
end -- 975
function ____exports.truncateAgentUserPrompt(prompt) -- 982
	if not prompt then -- 982
		return "" -- 983
	end -- 983
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 983
		return prompt -- 984
	end -- 984
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 985
	if offset == nil then -- 985
		return prompt -- 986
	end -- 986
	return string.sub(prompt, 1, offset - 1) -- 987
end -- 982
local function canWriteStepLLMDebug(shared, stepId) -- 990
	if stepId == nil then -- 990
		stepId = shared.step + 1 -- 990
	end -- 990
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 991
end -- 990
local function ensureDirRecursive(dir) -- 998
	if not dir then -- 998
		return false -- 999
	end -- 999
	if Content:exist(dir) then -- 999
		return Content:isdir(dir) -- 1000
	end -- 1000
	local parent = Path:getPath(dir) -- 1001
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 1001
		return false -- 1003
	end -- 1003
	return Content:mkdir(dir) -- 1005
end -- 998
local function encodeDebugJSON(value) -- 1008
	local text, err = safeJsonEncode(value) -- 1009
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 1010
end -- 1008
local function getStepLLMDebugDir(shared) -- 1013
	return Path( -- 1014
		shared.workingDir, -- 1015
		".agent", -- 1016
		tostring(shared.sessionId), -- 1017
		tostring(shared.taskId) -- 1018
	) -- 1018
end -- 1013
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 1022
	return Path( -- 1023
		getStepLLMDebugDir(shared), -- 1023
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 1023
	) -- 1023
end -- 1022
local function getLatestStepLLMDebugSeq(shared, stepId) -- 1026
	if not canWriteStepLLMDebug(shared, stepId) then -- 1026
		return 0 -- 1027
	end -- 1027
	local dir = getStepLLMDebugDir(shared) -- 1028
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1028
		return 0 -- 1029
	end -- 1029
	local latest = 0 -- 1030
	for ____, file in ipairs(Content:getFiles(dir)) do -- 1031
		do -- 1031
			local name = Path:getFilename(file) -- 1032
			local seqText = string.match( -- 1033
				name, -- 1033
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 1033
			) -- 1033
			if seqText ~= nil then -- 1033
				latest = math.max( -- 1035
					latest, -- 1035
					tonumber(seqText) -- 1035
				) -- 1035
				goto __continue129 -- 1036
			end -- 1036
			local legacyMatch = string.match( -- 1038
				name, -- 1038
				("^" .. tostring(stepId)) .. "_in%.md$" -- 1038
			) -- 1038
			if legacyMatch ~= nil then -- 1038
				latest = math.max(latest, 1) -- 1040
			end -- 1040
		end -- 1040
		::__continue129:: -- 1040
	end -- 1040
	return latest -- 1043
end -- 1026
local function writeStepLLMDebugFile(path, content) -- 1046
	if not Content:save(path, content) then -- 1046
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 1048
		return false -- 1049
	end -- 1049
	return true -- 1051
end -- 1046
local function createStepLLMDebugPair(shared, stepId, inContent) -- 1054
	if not canWriteStepLLMDebug(shared, stepId) then -- 1054
		return 0 -- 1055
	end -- 1055
	local dir = getStepLLMDebugDir(shared) -- 1056
	if not ensureDirRecursive(dir) then -- 1056
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1058
		return 0 -- 1059
	end -- 1059
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 1061
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 1062
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 1063
	if not writeStepLLMDebugFile(inPath, inContent) then -- 1063
		return 0 -- 1065
	end -- 1065
	writeStepLLMDebugFile(outPath, "") -- 1067
	return seq -- 1068
end -- 1054
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 1071
	if not canWriteStepLLMDebug(shared, stepId) then -- 1071
		return -- 1072
	end -- 1072
	local dir = getStepLLMDebugDir(shared) -- 1073
	if not ensureDirRecursive(dir) then -- 1073
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1075
		return -- 1076
	end -- 1076
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 1078
	if latestSeq <= 0 then -- 1078
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 1080
		writeStepLLMDebugFile(outPath, content) -- 1081
		return -- 1082
	end -- 1082
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 1084
	writeStepLLMDebugFile(outPath, content) -- 1085
end -- 1071
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 1088
	if not canWriteStepLLMDebug(shared, stepId) then -- 1088
		return -- 1089
	end -- 1089
	local sections = { -- 1090
		"# LLM Input", -- 1091
		"session_id: " .. tostring(shared.sessionId), -- 1092
		"task_id: " .. tostring(shared.taskId), -- 1093
		"step_id: " .. tostring(stepId), -- 1094
		"phase: " .. phase, -- 1095
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1096
		"## Options", -- 1097
		"```json", -- 1098
		encodeDebugJSON(options), -- 1099
		"```" -- 1100
	} -- 1100
	do -- 1100
		local i = 0 -- 1102
		while i < #messages do -- 1102
			local message = messages[i + 1] -- 1103
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 1104
			sections[#sections + 1] = encodeDebugJSON(message) -- 1105
			i = i + 1 -- 1102
		end -- 1102
	end -- 1102
	createStepLLMDebugPair( -- 1107
		shared, -- 1107
		stepId, -- 1107
		table.concat(sections, "\n") -- 1107
	) -- 1107
end -- 1088
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 1110
	if not canWriteStepLLMDebug(shared, stepId) then -- 1110
		return -- 1111
	end -- 1111
	local ____array_2 = __TS__SparseArrayNew( -- 1111
		"# LLM Output", -- 1113
		"session_id: " .. tostring(shared.sessionId), -- 1114
		"task_id: " .. tostring(shared.taskId), -- 1115
		"step_id: " .. tostring(stepId), -- 1116
		"phase: " .. phase, -- 1117
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1118
		table.unpack(meta and ({ -- 1119
			"## Meta", -- 1119
			"```json", -- 1119
			encodeDebugJSON(meta), -- 1119
			"```" -- 1119
		}) or ({})) -- 1119
	) -- 1119
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 1119
	local sections = {__TS__SparseArraySpread(____array_2)} -- 1112
	updateLatestStepLLMDebugOutput( -- 1123
		shared, -- 1123
		stepId, -- 1123
		table.concat(sections, "\n") -- 1123
	) -- 1123
end -- 1110
local function toJson(value, emptyAsArray) -- 1126
	if emptyAsArray == nil then -- 1126
		emptyAsArray = true -- 1126
	end -- 1126
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 1127
	if text ~= nil then -- 1127
		return text -- 1128
	end -- 1128
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 1129
end -- 1126
local function summarizeEditTextParamForHistory(value, key) -- 1179
	if type(value) ~= "string" then -- 1179
		return nil -- 1180
	end -- 1180
	local text = value -- 1181
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1182
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1183
end -- 1179
local function sanitizeActionParamsForHistory(tool, params) -- 1293
	if tool ~= "edit_file" then -- 1293
		return params -- 1294
	end -- 1294
	local clone = {} -- 1295
	for key in pairs(params) do -- 1296
		if key == "old_str" then -- 1296
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1298
		elseif key == "new_str" then -- 1298
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1300
		else -- 1300
			clone[key] = params[key] -- 1302
		end -- 1302
	end -- 1302
	return clone -- 1305
end -- 1293
local function isToolAllowedForRole(role, tool) -- 1366
	return __TS__ArrayIndexOf( -- 1367
		getAllowedToolsForRole(role), -- 1367
		tool -- 1367
	) >= 0 -- 1367
end -- 1366
local PRE_EXEC_SAFE_TOOLS = { -- 1370
	"read_file", -- 1371
	"grep_files", -- 1372
	"search_dora_api", -- 1373
	"glob_files", -- 1374
	"list_sub_agents" -- 1375
} -- 1375
local TOOL_RESULT_CACHE_MAX_ENTRIES = 128 -- 1378
local function canPreExecuteTool(tool) -- 1380
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1381
end -- 1380
local function createAgentToolCache(maxEntries) -- 1399
	if maxEntries == nil then -- 1399
		maxEntries = TOOL_RESULT_CACHE_MAX_ENTRIES -- 1399
	end -- 1399
	return { -- 1400
		readonlyResults = __TS__New(Map), -- 1401
		readonlyInFlight = __TS__New(Map), -- 1402
		version = 0, -- 1403
		maxEntries = maxEntries, -- 1404
		hits = 0, -- 1405
		pendingHits = 0, -- 1406
		misses = 0, -- 1407
		stores = 0, -- 1408
		evictions = 0, -- 1409
		invalidations = 0 -- 1410
	} -- 1410
end -- 1399
local function clearPreExecutedResults(shared) -- 1517
	shared.preExecutedResults = nil -- 1518
end -- 1517
local function startPreExecutedToolAction(shared, action) -- 1521
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1521
		local ____hasReturned, ____returnValue -- 1521
		local ____try = __TS__AsyncAwaiter(function() -- 1521
			____hasReturned = true -- 1523
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1523
			return -- 1523
		end) -- 1523
		____try = ____try.catch( -- 1523
			____try, -- 1523
			function(____, err) -- 1523
				return __TS__AsyncAwaiter(function() -- 1523
					local message = tostring(err) -- 1525
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1526
					____hasReturned = true -- 1527
					____returnValue = {success = false, message = message} -- 1527
					return -- 1527
				end) -- 1527
			end -- 1527
		) -- 1527
		__TS__Await(____try) -- 1522
		if ____hasReturned then -- 1522
			return ____awaiter_resolve(nil, ____returnValue) -- 1522
		end -- 1522
	end) -- 1522
end -- 1521
local function createPreExecutedToolResult(shared, action) -- 1531
	local cloneParamValue -- 1532
	cloneParamValue = function(value) -- 1532
		if value == nil or value == nil then -- 1532
			return value -- 1533
		end -- 1533
		if isArray(value) then -- 1533
			return __TS__ArrayMap( -- 1535
				value, -- 1535
				function(____, item) return cloneParamValue(item) end -- 1535
			) -- 1535
		end -- 1535
		if type(value) == "table" then -- 1535
			local clone = {} -- 1538
			for key in pairs(value) do -- 1539
				clone[key] = cloneParamValue(value[key]) -- 1540
			end -- 1540
			return clone -- 1542
		end -- 1542
		return value -- 1544
	end -- 1532
	local params = cloneParamValue(action.params) -- 1546
	local areParamValuesEqual -- 1547
	areParamValuesEqual = function(left, right) -- 1547
		if left == right then -- 1547
			return true -- 1548
		end -- 1548
		if left == nil or left == nil or right == nil or right == nil then -- 1548
			return false -- 1549
		end -- 1549
		if isArray(left) or isArray(right) then -- 1549
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1549
				return false -- 1551
			end -- 1551
			do -- 1551
				local i = 0 -- 1552
				while i < #left do -- 1552
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1552
						return false -- 1553
					end -- 1553
					i = i + 1 -- 1552
				end -- 1552
			end -- 1552
			return true -- 1555
		end -- 1555
		if type(left) == "table" and type(right) == "table" then -- 1555
			local leftCount = 0 -- 1558
			for key in pairs(left) do -- 1559
				leftCount = leftCount + 1 -- 1560
				if not areParamValuesEqual(left[key], right[key]) then -- 1560
					return false -- 1565
				end -- 1565
			end -- 1565
			local rightCount = 0 -- 1568
			for key in pairs(right) do -- 1569
				rightCount = rightCount + 1 -- 1570
			end -- 1570
			return leftCount == rightCount -- 1572
		end -- 1572
		return false -- 1574
	end -- 1547
	return { -- 1576
		matches = function(self, nextAction) -- 1577
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1578
		end, -- 1577
		promise = startPreExecutedToolAction(shared, action) -- 1580
	} -- 1580
end -- 1531
local function executeToolActionWithPreExecution(shared, action) -- 1584
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1584
		local ____opt_9 = shared.preExecutedResults -- 1584
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1585
		if preResult then -- 1585
			local ____opt_11 = shared.preExecutedResults -- 1585
			if ____opt_11 ~= nil then -- 1585
				____opt_11:delete(action.toolCallId) -- 1587
			end -- 1587
			if preResult:matches(action) then -- 1587
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1589
				return ____awaiter_resolve( -- 1589
					nil, -- 1589
					__TS__Await(preResult.promise) -- 1590
				) -- 1590
			end -- 1590
			Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1592
		end -- 1592
		return ____awaiter_resolve( -- 1592
			nil, -- 1592
			executeToolAction(shared, action) -- 1594
		) -- 1594
	end) -- 1594
end -- 1584
local function maybeCompressHistory(shared) -- 1597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1597
		local ____shared_13 = shared -- 1598
		local memory = ____shared_13.memory -- 1598
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1599
		local changed = false -- 1600
		do -- 1600
			local round = 0 -- 1601
			while round < maxRounds do -- 1601
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1602
				local activeMessages = getActiveConversationMessages(shared) -- 1603
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1607
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1607
					if changed then -- 1607
						persistHistoryState(shared) -- 1616
					end -- 1616
					return ____awaiter_resolve(nil) -- 1616
				end -- 1616
				local compressionRound = round + 1 -- 1620
				shared.step = shared.step + 1 -- 1621
				local stepId = shared.step -- 1622
				local pendingMessages = #activeMessages -- 1623
				emitAgentEvent( -- 1624
					shared, -- 1624
					{ -- 1624
						type = "memory_compression_started", -- 1625
						sessionId = shared.sessionId, -- 1626
						taskId = shared.taskId, -- 1627
						step = stepId, -- 1628
						tool = "compress_memory", -- 1629
						reason = getMemoryCompressionStartReason(shared), -- 1630
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1631
					} -- 1631
				) -- 1631
				local result = __TS__Await(memory.compressor:compress( -- 1637
					activeMessages, -- 1638
					shared.llmOptions, -- 1639
					shared.llmMaxTry, -- 1640
					shared.decisionMode, -- 1641
					{ -- 1642
						onInput = function(____, phase, messages, options) -- 1643
							saveStepLLMDebugInput( -- 1644
								shared, -- 1644
								stepId, -- 1644
								phase, -- 1644
								messages, -- 1644
								options -- 1644
							) -- 1644
						end, -- 1643
						onOutput = function(____, phase, text, meta) -- 1646
							saveStepLLMDebugOutput( -- 1647
								shared, -- 1647
								stepId, -- 1647
								phase, -- 1647
								text, -- 1647
								meta -- 1647
							) -- 1647
						end -- 1646
					}, -- 1646
					"default", -- 1650
					systemPrompt, -- 1651
					toolDefinitions -- 1652
				)) -- 1652
				if not (result and result.success and result.compressedCount > 0) then -- 1652
					emitAgentEvent( -- 1655
						shared, -- 1655
						{ -- 1655
							type = "memory_compression_finished", -- 1656
							sessionId = shared.sessionId, -- 1657
							taskId = shared.taskId, -- 1658
							step = stepId, -- 1659
							tool = "compress_memory", -- 1660
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1661
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1665
						} -- 1665
					) -- 1665
					if changed then -- 1665
						persistHistoryState(shared) -- 1673
					end -- 1673
					return ____awaiter_resolve(nil) -- 1673
				end -- 1673
				local effectiveCompressedCount = math.max( -- 1677
					0, -- 1678
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1679
				) -- 1679
				if effectiveCompressedCount <= 0 then -- 1679
					if changed then -- 1679
						persistHistoryState(shared) -- 1683
					end -- 1683
					return ____awaiter_resolve(nil) -- 1683
				end -- 1683
				emitAgentEvent( -- 1687
					shared, -- 1687
					{ -- 1687
						type = "memory_compression_finished", -- 1688
						sessionId = shared.sessionId, -- 1689
						taskId = shared.taskId, -- 1690
						step = stepId, -- 1691
						tool = "compress_memory", -- 1692
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1693
						result = { -- 1694
							success = true, -- 1695
							round = compressionRound, -- 1696
							compressedCount = effectiveCompressedCount, -- 1697
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1698
						} -- 1698
					} -- 1698
				) -- 1698
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1701
				changed = true -- 1702
				Log( -- 1703
					"Info", -- 1703
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1703
				) -- 1703
				round = round + 1 -- 1601
			end -- 1601
		end -- 1601
		if changed then -- 1601
			persistHistoryState(shared) -- 1706
		end -- 1706
	end) -- 1706
end -- 1597
local function compactAllHistory(shared) -- 1710
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1710
		local ____shared_20 = shared -- 1711
		local memory = ____shared_20.memory -- 1711
		local rounds = 0 -- 1712
		local totalCompressed = 0 -- 1713
		while getActiveRealMessageCount(shared) > 0 do -- 1713
			if shared.stopToken.stopped then -- 1713
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1716
				return ____awaiter_resolve( -- 1716
					nil, -- 1716
					emitAgentTaskFinishEvent( -- 1717
						shared, -- 1717
						false, -- 1717
						getCancelledReason(shared) -- 1717
					) -- 1717
				) -- 1717
			end -- 1717
			rounds = rounds + 1 -- 1719
			shared.step = shared.step + 1 -- 1720
			local stepId = shared.step -- 1721
			local activeMessages = getActiveConversationMessages(shared) -- 1722
			local pendingMessages = #activeMessages -- 1723
			emitAgentEvent( -- 1724
				shared, -- 1724
				{ -- 1724
					type = "memory_compression_started", -- 1725
					sessionId = shared.sessionId, -- 1726
					taskId = shared.taskId, -- 1727
					step = stepId, -- 1728
					tool = "compress_memory", -- 1729
					reason = getMemoryCompressionStartReason(shared), -- 1730
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1731
				} -- 1731
			) -- 1731
			local result = __TS__Await(memory.compressor:compress( -- 1738
				activeMessages, -- 1739
				shared.llmOptions, -- 1740
				shared.llmMaxTry, -- 1741
				shared.decisionMode, -- 1742
				{ -- 1743
					onInput = function(____, phase, messages, options) -- 1744
						saveStepLLMDebugInput( -- 1745
							shared, -- 1745
							stepId, -- 1745
							phase, -- 1745
							messages, -- 1745
							options -- 1745
						) -- 1745
					end, -- 1744
					onOutput = function(____, phase, text, meta) -- 1747
						saveStepLLMDebugOutput( -- 1748
							shared, -- 1748
							stepId, -- 1748
							phase, -- 1748
							text, -- 1748
							meta -- 1748
						) -- 1748
					end -- 1747
				}, -- 1747
				"budget_max" -- 1751
			)) -- 1751
			if not (result and result.success and result.compressedCount > 0) then -- 1751
				emitAgentEvent( -- 1754
					shared, -- 1754
					{ -- 1754
						type = "memory_compression_finished", -- 1755
						sessionId = shared.sessionId, -- 1756
						taskId = shared.taskId, -- 1757
						step = stepId, -- 1758
						tool = "compress_memory", -- 1759
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1760
						result = { -- 1764
							success = false, -- 1765
							rounds = rounds, -- 1766
							error = result and result.error or "compression returned no changes", -- 1767
							compressedCount = result and result.compressedCount or 0, -- 1768
							fullCompaction = true -- 1769
						} -- 1769
					} -- 1769
				) -- 1769
				return ____awaiter_resolve( -- 1769
					nil, -- 1769
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1772
				) -- 1772
			end -- 1772
			local effectiveCompressedCount = math.max( -- 1777
				0, -- 1778
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1779
			) -- 1779
			if effectiveCompressedCount <= 0 then -- 1779
				return ____awaiter_resolve( -- 1779
					nil, -- 1779
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1782
				) -- 1782
			end -- 1782
			emitAgentEvent( -- 1789
				shared, -- 1789
				{ -- 1789
					type = "memory_compression_finished", -- 1790
					sessionId = shared.sessionId, -- 1791
					taskId = shared.taskId, -- 1792
					step = stepId, -- 1793
					tool = "compress_memory", -- 1794
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1795
					result = { -- 1796
						success = true, -- 1797
						round = rounds, -- 1798
						compressedCount = effectiveCompressedCount, -- 1799
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1800
						fullCompaction = true -- 1801
					} -- 1801
				} -- 1801
			) -- 1801
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1804
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1805
			persistHistoryState(shared) -- 1806
			Log( -- 1807
				"Info", -- 1807
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1807
			) -- 1807
		end -- 1807
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1809
		return ____awaiter_resolve( -- 1809
			nil, -- 1809
			emitAgentTaskFinishEvent( -- 1810
				shared, -- 1811
				true, -- 1812
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1813
			) -- 1813
		) -- 1813
	end) -- 1813
end -- 1710
local function clearSessionHistory(shared) -- 1819
	shared.messages = {} -- 1820
	shared.lastConsolidatedIndex = 0 -- 1821
	shared.carryMessageIndex = nil -- 1822
	persistHistoryState(shared) -- 1823
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1824
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1825
end -- 1819
local function isKnownToolName(name) -- 1834
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1835
end -- 1834
local function appendConversationMessage(shared, message) -- 1928
	local ____shared_messages_29 = shared.messages -- 1928
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1929
		{}, -- 1929
		message, -- 1930
		{ -- 1929
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1931
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1932
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1933
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1934
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1935
		} -- 1935
	) -- 1935
end -- 1928
local function ensureToolCallId(toolCallId) -- 1939
	if toolCallId and toolCallId ~= "" then -- 1939
		return toolCallId -- 1940
	end -- 1940
	return createLocalToolCallId() -- 1941
end -- 1939
local function appendToolResultMessage(shared, action) -- 1944
	appendConversationMessage( -- 1945
		shared, -- 1945
		{ -- 1945
			role = "tool", -- 1946
			tool_call_id = action.toolCallId, -- 1947
			name = action.tool, -- 1948
			content = action.result and toJson(action.result) or "" -- 1949
		} -- 1949
	) -- 1949
end -- 1944
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1953
	appendConversationMessage( -- 1959
		shared, -- 1959
		{ -- 1959
			role = "assistant", -- 1960
			content = content or "", -- 1961
			reasoning_content = reasoningContent, -- 1962
			tool_calls = __TS__ArrayMap( -- 1963
				actions, -- 1963
				function(____, action) return { -- 1963
					id = action.toolCallId, -- 1964
					type = "function", -- 1965
					["function"] = { -- 1966
						name = action.tool, -- 1967
						arguments = toJson(action.params, false) -- 1968
					} -- 1968
				} end -- 1968
			) -- 1968
		} -- 1968
	) -- 1968
end -- 1953
local function parseXMLToolCallObjectFromText(text) -- 1974
	local children = parseXMLObjectFromText(text, "tool_call") -- 1975
	if not children.success then -- 1975
		return children -- 1976
	end -- 1976
	local rawObj = children.obj -- 1977
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1978
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1979
	if not params.success then -- 1979
		return {success = false, message = params.message} -- 1983
	end -- 1983
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1985
end -- 1974
local function llm(shared, messages, phase) -- 2005
	if phase == nil then -- 2005
		phase = "decision_xml" -- 2008
	end -- 2008
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2008
		local stepId = shared.step + 1 -- 2010
		emitLLMContextMetrics( -- 2011
			shared, -- 2011
			stepId, -- 2011
			phase, -- 2011
			messages, -- 2011
			shared.llmOptions -- 2011
		) -- 2011
		saveStepLLMDebugInput( -- 2012
			shared, -- 2012
			stepId, -- 2012
			phase, -- 2012
			messages, -- 2012
			shared.llmOptions -- 2012
		) -- 2012
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 2013
		if res.success then -- 2013
			local ____opt_32 = res.response.choices -- 2013
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 2013
			local message = ____opt_30 and ____opt_30.message -- 2015
			local text = message and message.content -- 2016
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 2017
			if text then -- 2017
				saveStepLLMDebugOutput( -- 2021
					shared, -- 2021
					stepId, -- 2021
					phase, -- 2021
					text, -- 2021
					{success = true} -- 2021
				) -- 2021
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 2021
			else -- 2021
				saveStepLLMDebugOutput( -- 2024
					shared, -- 2024
					stepId, -- 2024
					phase, -- 2024
					"empty LLM response", -- 2024
					{success = false} -- 2024
				) -- 2024
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 2024
			end -- 2024
		else -- 2024
			saveStepLLMDebugOutput( -- 2028
				shared, -- 2028
				stepId, -- 2028
				phase, -- 2028
				res.raw or res.message, -- 2028
				{success = false} -- 2028
			) -- 2028
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 2028
		end -- 2028
	end) -- 2028
end -- 2005
local function isDecisionBatchSuccess(result) -- 2052
	return result.kind == "batch" -- 2053
end -- 2052
local function parseDecisionObject(rawObj) -- 2056
	if type(rawObj.tool) ~= "string" then -- 2056
		return {success = false, message = "missing tool"} -- 2057
	end -- 2057
	local tool = rawObj.tool -- 2058
	if not isKnownToolName(tool) then -- 2058
		return {success = false, message = "unknown tool: " .. tool} -- 2060
	end -- 2060
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2062
	if tool ~= "finish" and (not reason or reason == "") then -- 2062
		return {success = false, message = tool .. " requires top-level reason"} -- 2066
	end -- 2066
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2068
	return {success = true, tool = tool, params = params, reason = reason} -- 2069
end -- 2056
local function parseDecisionToolCall(functionName, rawObj) -- 2077
	if not isKnownToolName(functionName) then -- 2077
		return {success = false, message = "unknown tool: " .. functionName} -- 2079
	end -- 2079
	if rawObj == nil or rawObj == nil then -- 2079
		return {success = true, tool = functionName, params = {}} -- 2082
	end -- 2082
	if not isRecord(rawObj) then -- 2082
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2085
	end -- 2085
	return {success = true, tool = functionName, params = rawObj} -- 2087
end -- 2077
local function parseToolCallArguments(functionName, argsText) -- 2094
	local trimmedArgs = __TS__StringTrim(argsText) -- 2095
	if trimmedArgs == "" then -- 2095
		return {} -- 2097
	end -- 2097
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 2099
	if err ~= nil or rawObj == nil then -- 2099
		return { -- 2101
			success = false, -- 2102
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2103
			raw = argsText -- 2104
		} -- 2104
	end -- 2104
	local encodedRaw = safeJsonEncode(rawObj) -- 2107
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2107
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2109
	end -- 2109
	return rawObj -- 2115
end -- 2094
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2118
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2126
	if isRecord(rawArgs) and rawArgs.success == false then -- 2126
		return rawArgs -- 2128
	end -- 2128
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2130
	if not decision.success then -- 2130
		return {success = false, message = decision.message, raw = argsText} -- 2132
	end -- 2132
	local validation = validateDecision(decision.tool, decision.params) -- 2138
	if not validation.success then -- 2138
		return {success = false, message = validation.message, raw = argsText} -- 2140
	end -- 2140
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 2140
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 2147
	end -- 2147
	decision.params = validation.params -- 2153
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2154
	decision.reason = reason -- 2155
	decision.reasoningContent = reasoningContent -- 2156
	return decision -- 2157
end -- 2118
local function createPreExecutableActionFromStream(shared, toolCall) -- 2160
	local ____opt_38 = toolCall["function"] -- 2160
	local functionName = ____opt_38 and ____opt_38.name -- 2161
	local ____opt_40 = toolCall["function"] -- 2161
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 2162
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2163
	if not functionName or not toolCallId then -- 2163
		return nil -- 2164
	end -- 2164
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2165
	if isRecord(rawArgs) and rawArgs.success == false then -- 2165
		return nil -- 2166
	end -- 2166
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2167
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 2167
		return nil -- 2168
	end -- 2168
	local validation = validateDecision(decision.tool, decision.params) -- 2169
	if not validation.success then -- 2169
		return nil -- 2170
	end -- 2170
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 2170
		return nil -- 2171
	end -- 2171
	return { -- 2172
		step = shared.step + 1, -- 2173
		toolCallId = toolCallId, -- 2174
		tool = decision.tool, -- 2175
		reason = "", -- 2176
		params = validation.params, -- 2177
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2178
	} -- 2178
end -- 2160
local function createFunctionToolSchema(name, description, properties, required) -- 2318
	if required == nil then -- 2318
		required = {} -- 2322
	end -- 2322
	local parameters = {type = "object", properties = properties} -- 2324
	if #required > 0 then -- 2324
		parameters.required = required -- 2329
	end -- 2329
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2331
end -- 2318
local function buildDecisionToolSchema(shared) -- 2347
	if shared.promptCache.decisionToolSchema ~= nil and shared.promptCache.decisionToolSchemaRole == shared.role then -- 2347
		return shared.promptCache.decisionToolSchema -- 2352
	end -- 2352
	local allowed = getAllowedToolsForRole(shared.role) -- 2354
	local tools = { -- 2355
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2356
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2366
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2376
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2384
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2388
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2389
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2390
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2391
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2392
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2393
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2394
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2395
		}, {"pattern"}), -- 2395
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2399
		createFunctionToolSchema( -- 2408
			"search_dora_api", -- 2409
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2409
			{ -- 2411
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2412
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2413
				programmingLanguage = {type = "string", enum = { -- 2414
					"ts", -- 2416
					"tsx", -- 2416
					"lua", -- 2416
					"yue", -- 2416
					"teal", -- 2416
					"tl", -- 2416
					"wa" -- 2416
				}, description = "Preferred language variant to search."}, -- 2416
				limit = { -- 2419
					type = "number", -- 2419
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2419
				}, -- 2419
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2420
			}, -- 2420
			{"pattern"} -- 2422
		), -- 2422
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2424
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2431
			"active_or_recent", -- 2435
			"running", -- 2435
			"done", -- 2435
			"failed", -- 2435
			"all" -- 2435
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2435
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2441
	} -- 2441
	local filtered = __TS__ArrayFilter( -- 2453
		tools, -- 2453
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2453
	) -- 2453
	shared.promptCache.decisionToolSchema = filtered -- 2454
	shared.promptCache.decisionToolSchemaRole = shared.role -- 2455
	return filtered -- 2456
end -- 2347
local function sanitizeMessagesForLLMInput(messages) -- 2497
	local function sanitizeAssistantToolCalls(message) -- 2498
		local toolCalls = message.tool_calls -- 2499
		if not toolCalls or #toolCalls == 0 then -- 2499
			return message -- 2500
		end -- 2500
		local changed = false -- 2501
		local sanitizedToolCalls = __TS__ArrayMap( -- 2502
			toolCalls, -- 2502
			function(____, toolCall) -- 2502
				local fn = toolCall["function"] or ({}) -- 2503
				local raw = type(fn.arguments) == "string" and __TS__StringTrim(fn.arguments) or "" -- 2504
				local safeArguments = "{}" -- 2505
				if raw ~= "" then -- 2505
					local decoded, err = safeJsonDecode(raw) -- 2507
					local encodedRaw = nil -- 2508
					if err == nil and decoded ~= nil then -- 2508
						encodedRaw = safeJsonEncode(decoded, false, false) -- 2510
					end -- 2510
					if encodedRaw ~= nil and encodedRaw ~= "null" and __TS__StringAccess(raw, 0) ~= "[" and not __TS__ArrayIsArray(decoded) and decoded ~= nil and type(decoded) == "table" then -- 2510
						safeArguments = encodedRaw -- 2520
					else -- 2520
						changed = true -- 2522
						Log("Warn", "[CodingAgent] replacing invalid historical tool-call arguments with {}") -- 2523
					end -- 2523
				end -- 2523
				if toolCall.type ~= "function" or toolCall["function"] == nil or fn.arguments ~= safeArguments then -- 2523
					changed = true -- 2531
				end -- 2531
				return __TS__ObjectAssign( -- 2533
					{}, -- 2533
					toolCall, -- 2534
					{ -- 2533
						type = "function", -- 2535
						["function"] = __TS__ObjectAssign({}, fn, {arguments = safeArguments}) -- 2536
					} -- 2536
				) -- 2536
			end -- 2502
		) -- 2502
		if not changed then -- 2502
			return message -- 2542
		end -- 2542
		return __TS__ObjectAssign({}, message, {tool_calls = sanitizedToolCalls}) -- 2543
	end -- 2498
	local sanitized = {} -- 2549
	local droppedAssistantToolCalls = 0 -- 2550
	local droppedToolResults = 0 -- 2551
	do -- 2551
		local i = 0 -- 2552
		while i < #messages do -- 2552
			do -- 2552
				local message = messages[i + 1] -- 2553
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2553
					local requiredIds = {} -- 2555
					do -- 2555
						local j = 0 -- 2556
						while j < #message.tool_calls do -- 2556
							local toolCall = message.tool_calls[j + 1] -- 2557
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2558
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2558
								requiredIds[#requiredIds + 1] = id -- 2560
							end -- 2560
							j = j + 1 -- 2556
						end -- 2556
					end -- 2556
					if #requiredIds == 0 then -- 2556
						sanitized[#sanitized + 1] = sanitizeAssistantToolCalls(message) -- 2564
						goto __continue408 -- 2565
					end -- 2565
					local matchedIds = {} -- 2567
					local matchedTools = {} -- 2568
					local j = i + 1 -- 2569
					while j < #messages do -- 2569
						local toolMessage = messages[j + 1] -- 2571
						if toolMessage.role ~= "tool" then -- 2571
							break -- 2572
						end -- 2572
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2573
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2573
							matchedIds[toolCallId] = true -- 2575
							matchedTools[#matchedTools + 1] = toolMessage -- 2576
						else -- 2576
							droppedToolResults = droppedToolResults + 1 -- 2578
						end -- 2578
						j = j + 1 -- 2580
					end -- 2580
					local complete = true -- 2582
					do -- 2582
						local j = 0 -- 2583
						while j < #requiredIds do -- 2583
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2583
								complete = false -- 2585
								break -- 2586
							end -- 2586
							j = j + 1 -- 2583
						end -- 2583
					end -- 2583
					if complete then -- 2583
						__TS__ArrayPush( -- 2590
							sanitized, -- 2590
							sanitizeAssistantToolCalls(message), -- 2590
							table.unpack(matchedTools) -- 2590
						) -- 2590
					else -- 2590
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2592
						droppedToolResults = droppedToolResults + #matchedTools -- 2593
					end -- 2593
					i = j - 1 -- 2595
					goto __continue408 -- 2596
				end -- 2596
				if message.role == "tool" then -- 2596
					droppedToolResults = droppedToolResults + 1 -- 2599
					goto __continue408 -- 2600
				end -- 2600
				sanitized[#sanitized + 1] = message -- 2602
			end -- 2602
			::__continue408:: -- 2602
			i = i + 1 -- 2552
		end -- 2552
	end -- 2552
	return sanitized -- 2604
end -- 2497
local function getUnconsolidatedMessages(shared) -- 2607
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2608
end -- 2607
local function getFinalDecisionTurnPrompt(shared) -- 2611
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2612
end -- 2611
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2617
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2617
		return messages -- 2618
	end -- 2618
	local next = __TS__ArrayMap( -- 2619
		messages, -- 2619
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2619
	) -- 2619
	do -- 2619
		local i = #next - 1 -- 2620
		while i >= 0 do -- 2620
			do -- 2620
				local message = next[i + 1] -- 2621
				if message.role ~= "assistant" and message.role ~= "user" then -- 2621
					goto __continue430 -- 2622
				end -- 2622
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2623
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2624
				return next -- 2627
			end -- 2627
			::__continue430:: -- 2627
			i = i - 1 -- 2620
		end -- 2620
	end -- 2620
	next[#next + 1] = {role = "user", content = prompt} -- 2629
	return next -- 2630
end -- 2617
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2633
	if attempt == nil then -- 2633
		attempt = 1 -- 2636
	end -- 2636
	if decisionMode == nil then -- 2636
		decisionMode = shared.decisionMode -- 2638
	end -- 2638
	local messages = { -- 2640
		{ -- 2641
			role = "system", -- 2641
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2641
		}, -- 2641
		table.unpack(getUnconsolidatedMessages(shared)) -- 2642
	} -- 2642
	if shared.step + 1 >= shared.maxSteps then -- 2642
		messages = appendPromptToLatestDecisionMessage( -- 2645
			messages, -- 2645
			getFinalDecisionTurnPrompt(shared) -- 2645
		) -- 2645
	end -- 2645
	if lastError and lastError ~= "" then -- 2645
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2648
		messages[#messages + 1] = { -- 2651
			role = "user", -- 2652
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2653
		} -- 2653
	end -- 2653
	return messages -- 2660
end -- 2633
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2667
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2674
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2675
	local repairPrompt = replacePromptVars( -- 2683
		shared.promptPack.xmlDecisionRepairPrompt, -- 2683
		{ -- 2683
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2684
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2685
			CANDIDATE_SECTION = candidateSection, -- 2686
			LAST_ERROR = lastError, -- 2687
			ATTEMPT = tostring(attempt) -- 2688
		} -- 2688
	) -- 2688
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2690
end -- 2667
local function tryParseAndValidateDecision(rawText) -- 2702
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2703
	if not parsed.success then -- 2703
		return {success = false, message = parsed.message, raw = rawText} -- 2705
	end -- 2705
	local decision = parseDecisionObject(parsed.obj) -- 2707
	if not decision.success then -- 2707
		return {success = false, message = decision.message, raw = rawText} -- 2709
	end -- 2709
	local validation = validateDecision(decision.tool, decision.params) -- 2711
	if not validation.success then -- 2711
		return {success = false, message = validation.message, raw = rawText} -- 2713
	end -- 2713
	decision.params = validation.params -- 2715
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2716
	return decision -- 2717
end -- 2702
local function normalizeLineEndings(text) -- 2720
	local res = string.gsub(text, "\r\n", "\n") -- 2721
	res = string.gsub(res, "\r", "\n") -- 2722
	return res -- 2723
end -- 2720
local function countOccurrences(text, searchStr) -- 2726
	if searchStr == "" then -- 2726
		return 0 -- 2727
	end -- 2727
	local count = 0 -- 2728
	local pos = 0 -- 2729
	while true do -- 2729
		local idx = (string.find( -- 2731
			text, -- 2731
			searchStr, -- 2731
			math.max(pos + 1, 1), -- 2731
			true -- 2731
		) or 0) - 1 -- 2731
		if idx < 0 then -- 2731
			break -- 2732
		end -- 2732
		count = count + 1 -- 2733
		pos = idx + #searchStr -- 2734
	end -- 2734
	return count -- 2736
end -- 2726
local function replaceFirst(text, oldStr, newStr) -- 2739
	if oldStr == "" then -- 2739
		return text -- 2740
	end -- 2740
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2741
	if idx < 0 then -- 2741
		return text -- 2742
	end -- 2742
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2743
end -- 2739
local function splitLines(text) -- 2746
	return __TS__StringSplit(text, "\n") -- 2747
end -- 2746
local function getLeadingWhitespace(text) -- 2750
	local i = 0 -- 2751
	while i < #text do -- 2751
		local ch = __TS__StringAccess(text, i) -- 2753
		if ch ~= " " and ch ~= "\t" then -- 2753
			break -- 2754
		end -- 2754
		i = i + 1 -- 2755
	end -- 2755
	return __TS__StringSubstring(text, 0, i) -- 2757
end -- 2750
local function getCommonIndentPrefix(lines) -- 2760
	local common -- 2761
	do -- 2761
		local i = 0 -- 2762
		while i < #lines do -- 2762
			do -- 2762
				local line = lines[i + 1] -- 2763
				if __TS__StringTrim(line) == "" then -- 2763
					goto __continue455 -- 2764
				end -- 2764
				local indent = getLeadingWhitespace(line) -- 2765
				if common == nil then -- 2765
					common = indent -- 2767
					goto __continue455 -- 2768
				end -- 2768
				local j = 0 -- 2770
				local maxLen = math.min(#common, #indent) -- 2771
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2771
					j = j + 1 -- 2773
				end -- 2773
				common = __TS__StringSubstring(common, 0, j) -- 2775
				if common == "" then -- 2775
					break -- 2776
				end -- 2776
			end -- 2776
			::__continue455:: -- 2776
			i = i + 1 -- 2762
		end -- 2762
	end -- 2762
	return common or "" -- 2778
end -- 2760
local function removeIndentPrefix(line, indent) -- 2781
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2781
		return __TS__StringSubstring(line, #indent) -- 2783
	end -- 2783
	local lineIndent = getLeadingWhitespace(line) -- 2785
	local j = 0 -- 2786
	local maxLen = math.min(#lineIndent, #indent) -- 2787
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2787
		j = j + 1 -- 2789
	end -- 2789
	return __TS__StringSubstring(line, j) -- 2791
end -- 2781
local function dedentLines(lines) -- 2794
	local indent = getCommonIndentPrefix(lines) -- 2795
	return { -- 2796
		indent = indent, -- 2797
		lines = __TS__ArrayMap( -- 2798
			lines, -- 2798
			function(____, line) return removeIndentPrefix(line, indent) end -- 2798
		) -- 2798
	} -- 2798
end -- 2794
local function joinLines(lines) -- 2802
	return table.concat(lines, "\n") -- 2803
end -- 2802
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2806
	local contentLines = splitLines(content) -- 2811
	local oldLines = splitLines(oldStr) -- 2812
	if #oldLines == 0 then -- 2812
		return {success = false, message = "old_str not found in file"} -- 2814
	end -- 2814
	local dedentedOld = dedentLines(oldLines) -- 2816
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2817
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2818
	local matches = {} -- 2819
	do -- 2819
		local start = 0 -- 2820
		while start <= #contentLines - #oldLines do -- 2820
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2821
			local dedentedCandidate = dedentLines(candidateLines) -- 2822
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2822
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2824
			end -- 2824
			start = start + 1 -- 2820
		end -- 2820
	end -- 2820
	if #matches == 0 then -- 2820
		return {success = false, message = "old_str not found in file"} -- 2832
	end -- 2832
	if #matches > 1 then -- 2832
		return { -- 2835
			success = false, -- 2836
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2837
		} -- 2837
	end -- 2837
	local match = matches[1] -- 2840
	local rebuiltNewLines = __TS__ArrayMap( -- 2841
		dedentedNew.lines, -- 2841
		function(____, line) return line == "" and "" or match.indent .. line end -- 2841
	) -- 2841
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2841
	__TS__SparseArrayPush( -- 2841
		____array_46, -- 2841
		table.unpack(rebuiltNewLines) -- 2844
	) -- 2844
	__TS__SparseArrayPush( -- 2844
		____array_46, -- 2844
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2845
	) -- 2845
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2842
	return { -- 2847
		success = true, -- 2847
		content = joinLines(nextLines) -- 2847
	} -- 2847
end -- 2806
local MainDecisionAgent = __TS__Class() -- 2850
MainDecisionAgent.name = "MainDecisionAgent" -- 2850
__TS__ClassExtends(MainDecisionAgent, Node) -- 2850
function MainDecisionAgent.prototype.prep(self, shared) -- 2851
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2851
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2851
			return ____awaiter_resolve(nil, {shared = shared}) -- 2851
		end -- 2851
		__TS__Await(maybeCompressHistory(shared)) -- 2856
		return ____awaiter_resolve(nil, {shared = shared}) -- 2856
	end) -- 2856
end -- 2851
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2861
	if attempt == nil then -- 2861
		attempt = 1 -- 2864
	end -- 2864
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2864
		if shared.stopToken.stopped then -- 2864
			return ____awaiter_resolve( -- 2864
				nil, -- 2864
				{ -- 2868
					success = false, -- 2868
					message = getCancelledReason(shared) -- 2868
				} -- 2868
			) -- 2868
		end -- 2868
		Log( -- 2870
			"Info", -- 2870
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2870
		) -- 2870
		local tools = buildDecisionToolSchema(shared) -- 2871
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2872
		local stepId = shared.step + 1 -- 2873
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2874
		emitLLMContextMetrics( -- 2878
			shared, -- 2878
			stepId, -- 2878
			"decision_tool_calling", -- 2878
			messages, -- 2878
			llmOptions -- 2878
		) -- 2878
		saveStepLLMDebugInput( -- 2879
			shared, -- 2879
			stepId, -- 2879
			"decision_tool_calling", -- 2879
			messages, -- 2879
			llmOptions -- 2879
		) -- 2879
		local lastStreamContent = "" -- 2880
		local lastStreamReasoning = "" -- 2881
		local preExecutedResults = __TS__New(Map) -- 2882
		shared.preExecutedResults = preExecutedResults -- 2883
		local res = __TS__Await(callLLMStreamAggregated( -- 2884
			messages, -- 2885
			llmOptions, -- 2886
			shared.stopToken, -- 2887
			shared.llmConfig, -- 2888
			function(response) -- 2889
				local ____opt_49 = response.choices -- 2889
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2889
				local streamMessage = ____opt_47 and ____opt_47.message -- 2890
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2891
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2894
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2894
					return -- 2898
				end -- 2898
				lastStreamContent = nextContent -- 2900
				lastStreamReasoning = nextReasoning -- 2901
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2902
			end, -- 2889
			function(tc) -- 2904
				if shared.stopToken.stopped then -- 2904
					return -- 2905
				end -- 2905
				local action = createPreExecutableActionFromStream(shared, tc) -- 2906
				if not action or preExecutedResults:has(action.toolCallId) then -- 2906
					return -- 2907
				end -- 2907
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2908
				preExecutedResults:set( -- 2909
					action.toolCallId, -- 2909
					createPreExecutedToolResult(shared, action) -- 2909
				) -- 2909
			end -- 2904
		)) -- 2904
		if shared.stopToken.stopped then -- 2904
			clearPreExecutedResults(shared) -- 2913
			return ____awaiter_resolve( -- 2913
				nil, -- 2913
				{ -- 2914
					success = false, -- 2914
					message = getCancelledReason(shared) -- 2914
				} -- 2914
			) -- 2914
		end -- 2914
		if not res.success then -- 2914
			saveStepLLMDebugOutput( -- 2917
				shared, -- 2917
				stepId, -- 2917
				"decision_tool_calling", -- 2917
				res.raw or res.message, -- 2917
				{success = false} -- 2917
			) -- 2917
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2918
			clearPreExecutedResults(shared) -- 2919
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2919
		end -- 2919
		saveStepLLMDebugOutput( -- 2922
			shared, -- 2922
			stepId, -- 2922
			"decision_tool_calling", -- 2922
			encodeDebugJSON(res.response), -- 2922
			{success = true} -- 2922
		) -- 2922
		local choice = res.response.choices and res.response.choices[1] -- 2923
		local message = choice and choice.message -- 2924
		local toolCalls = message and message.tool_calls -- 2925
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2926
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2929
		Log( -- 2932
			"Info", -- 2932
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2932
		) -- 2932
		if not toolCalls or #toolCalls == 0 then -- 2932
			if messageContent and messageContent ~= "" then -- 2932
				Log( -- 2935
					"Info", -- 2935
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2935
				) -- 2935
				clearPreExecutedResults(shared) -- 2936
				return ____awaiter_resolve(nil, { -- 2936
					success = true, -- 2938
					tool = "finish", -- 2939
					params = {}, -- 2940
					reason = messageContent, -- 2941
					reasoningContent = reasoningContent, -- 2942
					directSummary = messageContent -- 2943
				}) -- 2943
			end -- 2943
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2946
			clearPreExecutedResults(shared) -- 2947
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2947
		end -- 2947
		local decisions = {} -- 2954
		do -- 2954
			local i = 0 -- 2955
			while i < #toolCalls do -- 2955
				local toolCall = toolCalls[i + 1] -- 2956
				local fn = toolCall and toolCall["function"] -- 2957
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2957
					Log( -- 2959
						"Error", -- 2959
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2959
					) -- 2959
					clearPreExecutedResults(shared) -- 2960
					return ____awaiter_resolve( -- 2960
						nil, -- 2960
						{ -- 2961
							success = false, -- 2962
							message = "missing function name for tool call " .. tostring(i + 1), -- 2963
							raw = messageContent -- 2964
						} -- 2964
					) -- 2964
				end -- 2964
				local functionName = fn.name -- 2967
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2968
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2969
				Log( -- 2972
					"Info", -- 2972
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2972
				) -- 2972
				local decision = parseAndValidateToolCallDecision( -- 2973
					shared, -- 2974
					functionName, -- 2975
					argsText, -- 2976
					toolCallId, -- 2977
					messageContent, -- 2978
					reasoningContent -- 2979
				) -- 2979
				if not decision.success then -- 2979
					Log( -- 2982
						"Error", -- 2982
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2982
					) -- 2982
					clearPreExecutedResults(shared) -- 2983
					return ____awaiter_resolve(nil, decision) -- 2983
				end -- 2983
				decisions[#decisions + 1] = decision -- 2986
				i = i + 1 -- 2955
			end -- 2955
		end -- 2955
		if #decisions == 1 then -- 2955
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2989
			return ____awaiter_resolve(nil, decisions[1]) -- 2989
		end -- 2989
		do -- 2989
			local i = 0 -- 2992
			while i < #decisions do -- 2992
				if decisions[i + 1].tool == "finish" then -- 2992
					clearPreExecutedResults(shared) -- 2994
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2994
				end -- 2994
				i = i + 1 -- 2992
			end -- 2992
		end -- 2992
		Log( -- 3002
			"Info", -- 3002
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3002
				__TS__ArrayMap( -- 3002
					decisions, -- 3002
					function(____, decision) return decision.tool end -- 3002
				), -- 3002
				"," -- 3002
			) -- 3002
		) -- 3002
		return ____awaiter_resolve(nil, { -- 3002
			success = true, -- 3004
			kind = "batch", -- 3005
			decisions = decisions, -- 3006
			content = messageContent, -- 3007
			reasoningContent = reasoningContent -- 3008
		}) -- 3008
	end) -- 3008
end -- 2861
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 3012
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3012
		Log( -- 3017
			"Info", -- 3017
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3017
		) -- 3017
		local lastError = initialError -- 3018
		local candidateRaw = "" -- 3019
		do -- 3019
			local attempt = 0 -- 3020
			while attempt < shared.llmMaxTry do -- 3020
				do -- 3020
					Log( -- 3021
						"Info", -- 3021
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3021
					) -- 3021
					local messages = buildXmlRepairMessages( -- 3022
						shared, -- 3023
						originalRaw, -- 3024
						candidateRaw, -- 3025
						lastError, -- 3026
						attempt + 1 -- 3027
					) -- 3027
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3029
					if shared.stopToken.stopped then -- 3029
						return ____awaiter_resolve( -- 3029
							nil, -- 3029
							{ -- 3031
								success = false, -- 3031
								message = getCancelledReason(shared) -- 3031
							} -- 3031
						) -- 3031
					end -- 3031
					if not llmRes.success then -- 3031
						lastError = llmRes.message -- 3034
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3035
						goto __continue498 -- 3036
					end -- 3036
					candidateRaw = llmRes.text -- 3038
					local decision = tryParseAndValidateDecision(candidateRaw) -- 3039
					if decision.success then -- 3039
						decision.reasoningContent = llmRes.reasoningContent -- 3041
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3042
						return ____awaiter_resolve(nil, decision) -- 3042
					end -- 3042
					lastError = decision.message -- 3045
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3046
				end -- 3046
				::__continue498:: -- 3046
				attempt = attempt + 1 -- 3020
			end -- 3020
		end -- 3020
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3048
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3048
	end) -- 3048
end -- 3012
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3056
	if attempt == nil then -- 3056
		attempt = 1 -- 3059
	end -- 3059
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3059
		local messages = buildDecisionMessages( -- 3062
			shared, -- 3063
			lastError, -- 3064
			attempt, -- 3065
			lastRaw, -- 3066
			"xml" -- 3067
		) -- 3067
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3069
		if shared.stopToken.stopped then -- 3069
			return ____awaiter_resolve( -- 3069
				nil, -- 3069
				{ -- 3071
					success = false, -- 3071
					message = getCancelledReason(shared) -- 3071
				} -- 3071
			) -- 3071
		end -- 3071
		if not llmRes.success then -- 3071
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3071
		end -- 3071
		local decision = tryParseAndValidateDecision(llmRes.text) -- 3080
		if decision.success then -- 3080
			decision.reasoningContent = llmRes.reasoningContent -- 3082
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 3082
				return ____awaiter_resolve( -- 3082
					nil, -- 3082
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 3084
				) -- 3084
			end -- 3084
			return ____awaiter_resolve(nil, decision) -- 3084
		end -- 3084
		return ____awaiter_resolve( -- 3084
			nil, -- 3084
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 3092
		) -- 3092
	end) -- 3092
end -- 3056
function MainDecisionAgent.prototype.exec(self, input) -- 3095
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3095
		local shared = input.shared -- 3096
		if shared.stopToken.stopped then -- 3096
			return ____awaiter_resolve( -- 3096
				nil, -- 3096
				{ -- 3098
					success = false, -- 3098
					message = getCancelledReason(shared) -- 3098
				} -- 3098
			) -- 3098
		end -- 3098
		if shared.step >= shared.maxSteps then -- 3098
			Log( -- 3101
				"Warn", -- 3101
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3101
			) -- 3101
			return ____awaiter_resolve( -- 3101
				nil, -- 3101
				{ -- 3102
					success = false, -- 3102
					message = getMaxStepsReachedReason(shared) -- 3102
				} -- 3102
			) -- 3102
		end -- 3102
		if shared.decisionMode == "tool_calling" then -- 3102
			Log( -- 3106
				"Info", -- 3106
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3106
			) -- 3106
			local function containsAnyText(text, needles) -- 3107
				do -- 3107
					local i = 0 -- 3108
					while i < #needles do -- 3108
						if (string.find(text, needles[i + 1], nil, true) or 0) - 1 >= 0 then -- 3108
							return true -- 3109
						end -- 3109
						i = i + 1 -- 3108
					end -- 3108
				end -- 3108
				return false -- 3111
			end -- 3107
			local function shouldFallbackToolCallingToXml(message, raw) -- 3113
				local text = string.lower(((message or "") .. "\n") .. (raw or "")) -- 3114
				if (string.find(text, "missing tool call", nil, true) or 0) - 1 >= 0 then -- 3114
					return true -- 3115
				end -- 3115
				if containsAnyText(text, { -- 3115
					"cancelled", -- 3117
					"canceled", -- 3118
					"stopped", -- 3119
					"no active llm config", -- 3120
					"unauthorized", -- 3121
					"authentication", -- 3122
					"invalid api key", -- 3123
					"api key", -- 3124
					"forbidden", -- 3125
					"permission denied", -- 3126
					"insufficient_quota", -- 3127
					"quota", -- 3128
					"billing", -- 3129
					"balance", -- 3130
					"rate limit", -- 3131
					"too many requests", -- 3132
					"context length", -- 3133
					"context_length", -- 3134
					"maximum context", -- 3135
					"max context", -- 3136
					"token limit", -- 3137
					"too many tokens", -- 3138
					"input is too long", -- 3139
					"invalid model", -- 3140
					"model_not_found", -- 3141
					"model not found", -- 3142
					"not supported model" -- 3143
				}) then -- 3143
					return false -- 3145
				end -- 3145
				if (string.find(text, "can only get item pairs from a mapping", nil, true) or 0) - 1 >= 0 or (string.find(text, "item pairs from a mapping", nil, true) or 0) - 1 >= 0 then -- 3145
					return true -- 3151
				end -- 3151
				if containsAnyText(text, { -- 3151
					"tool_choice", -- 3154
					"tool_calls", -- 3155
					"tool call", -- 3156
					"function calling", -- 3157
					"function_call", -- 3158
					"parallel_tool_calls", -- 3159
					"unsupported tool", -- 3160
					"tools are not supported", -- 3161
					"does not support tools", -- 3162
					"doesn't support tools", -- 3163
					"does not support function", -- 3164
					"doesn't support function", -- 3165
					"unsupported parameter: tools", -- 3166
					"unsupported parameter: tool_choice", -- 3167
					"unknown parameter: tools", -- 3168
					"unknown parameter: tool_choice", -- 3169
					"unrecognized request argument supplied: tools", -- 3170
					"unrecognized request argument supplied: tool_choice" -- 3171
				}) then -- 3171
					return true -- 3173
				end -- 3173
				return containsAnyText(text, { -- 3175
					"llm returned no choices", -- 3176
					"internalservererror", -- 3177
					"internal server error", -- 3178
					"/500", -- 3179
					" 500" -- 3180
				}) -- 3180
			end -- 3113
			local lastError = "tool calling validation failed" -- 3183
			local lastRaw = "" -- 3184
			local shouldFallbackToXml = false -- 3185
			do -- 3185
				local attempt = 0 -- 3186
				while attempt < shared.llmMaxTry do -- 3186
					Log( -- 3187
						"Info", -- 3187
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3187
					) -- 3187
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3188
					if shared.stopToken.stopped then -- 3188
						return ____awaiter_resolve( -- 3188
							nil, -- 3188
							{ -- 3195
								success = false, -- 3195
								message = getCancelledReason(shared) -- 3195
							} -- 3195
						) -- 3195
					end -- 3195
					if decision.success then -- 3195
						return ____awaiter_resolve(nil, decision) -- 3195
					end -- 3195
					lastError = decision.message -- 3200
					lastRaw = decision.raw or "" -- 3201
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3202
					if shouldFallbackToolCallingToXml(lastError, lastRaw) then -- 3202
						shouldFallbackToXml = true -- 3204
						break -- 3205
					end -- 3205
					attempt = attempt + 1 -- 3186
				end -- 3186
			end -- 3186
			if shouldFallbackToXml then -- 3186
				local xmlFallbackPrompt = (string.find(lastError, "missing tool call", nil, true) or 0) - 1 >= 0 and "tool-calling returned no tool calls. Use XML decision format instead. Return exactly one valid XML tool_call block." or ("tool-calling provider/function-call format failed (" .. truncateText(lastError, 220)) .. "). Use XML decision format instead. Return exactly one valid XML tool_call block." -- 3209
				Log("Warn", "[CodingAgent] tool-calling fallback to XML decision format: " .. lastError) -- 3212
				lastError = xmlFallbackPrompt -- 3213
				do -- 3213
					local attempt = 0 -- 3214
					while attempt < shared.llmMaxTry do -- 3214
						Log( -- 3215
							"Info", -- 3215
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3215
						) -- 3215
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or xmlFallbackPrompt, attempt + 1, lastRaw)) -- 3216
						if shared.stopToken.stopped then -- 3216
							return ____awaiter_resolve( -- 3216
								nil, -- 3216
								{ -- 3223
									success = false, -- 3223
									message = getCancelledReason(shared) -- 3223
								} -- 3223
							) -- 3223
						end -- 3223
						if decision.success then -- 3223
							return ____awaiter_resolve(nil, decision) -- 3223
						end -- 3223
						lastError = decision.message -- 3228
						lastRaw = decision.raw or "" -- 3229
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3230
						attempt = attempt + 1 -- 3214
					end -- 3214
				end -- 3214
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3232
				return ____awaiter_resolve( -- 3232
					nil, -- 3232
					{ -- 3233
						success = false, -- 3233
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3233
					} -- 3233
				) -- 3233
			end -- 3233
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3235
			return ____awaiter_resolve( -- 3235
				nil, -- 3235
				{ -- 3236
					success = false, -- 3236
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3236
				} -- 3236
			) -- 3236
		end -- 3236
		local lastError = "xml validation failed" -- 3239
		local lastRaw = "" -- 3240
		do -- 3240
			local attempt = 0 -- 3241
			while attempt < shared.llmMaxTry do -- 3241
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3242
				if shared.stopToken.stopped then -- 3242
					return ____awaiter_resolve( -- 3242
						nil, -- 3242
						{ -- 3251
							success = false, -- 3251
							message = getCancelledReason(shared) -- 3251
						} -- 3251
					) -- 3251
				end -- 3251
				if decision.success then -- 3251
					return ____awaiter_resolve(nil, decision) -- 3251
				end -- 3251
				lastError = decision.message -- 3256
				lastRaw = decision.raw or "" -- 3257
				attempt = attempt + 1 -- 3241
			end -- 3241
		end -- 3241
		return ____awaiter_resolve( -- 3241
			nil, -- 3241
			{ -- 3259
				success = false, -- 3259
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3259
			} -- 3259
		) -- 3259
	end) -- 3259
end -- 3095
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3262
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3262
		local result = execRes -- 3263
		if not result.success then -- 3263
			if shared.stopToken.stopped then -- 3263
				shared.error = getCancelledReason(shared) -- 3266
				shared.done = true -- 3267
				return ____awaiter_resolve(nil, "done") -- 3267
			end -- 3267
			shared.error = result.message -- 3270
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3271
			shared.done = true -- 3272
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3273
			persistHistoryState(shared) -- 3277
			return ____awaiter_resolve(nil, "done") -- 3277
		end -- 3277
		if isDecisionBatchSuccess(result) then -- 3277
			local startStep = shared.step -- 3281
			local actions = {} -- 3282
			do -- 3282
				local i = 0 -- 3283
				while i < #result.decisions do -- 3283
					local decision = result.decisions[i + 1] -- 3284
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3285
					local step = startStep + i + 1 -- 3286
					local ____temp_55 -- 3287
					if i == 0 then -- 3287
						____temp_55 = decision.reason -- 3287
					else -- 3287
						____temp_55 = "" -- 3287
					end -- 3287
					local actionReason = ____temp_55 -- 3287
					local ____temp_56 -- 3288
					if i == 0 then -- 3288
						____temp_56 = decision.reasoningContent -- 3288
					else -- 3288
						____temp_56 = nil -- 3288
					end -- 3288
					local actionReasoningContent = ____temp_56 -- 3288
					emitAgentEvent(shared, { -- 3289
						type = "decision_made", -- 3290
						sessionId = shared.sessionId, -- 3291
						taskId = shared.taskId, -- 3292
						step = step, -- 3293
						tool = decision.tool, -- 3294
						reason = actionReason, -- 3295
						reasoningContent = actionReasoningContent, -- 3296
						params = decision.params -- 3297
					}) -- 3297
					local action = { -- 3299
						step = step, -- 3300
						toolCallId = toolCallId, -- 3301
						tool = decision.tool, -- 3302
						reason = actionReason or "", -- 3303
						reasoningContent = actionReasoningContent, -- 3304
						params = decision.params, -- 3305
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3306
					} -- 3306
					local ____shared_history_57 = shared.history -- 3306
					____shared_history_57[#____shared_history_57 + 1] = action -- 3308
					actions[#actions + 1] = action -- 3309
					i = i + 1 -- 3283
				end -- 3283
			end -- 3283
			shared.step = startStep + #actions -- 3311
			shared.pendingToolActions = actions -- 3312
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3313
			persistHistoryState(shared) -- 3319
			return ____awaiter_resolve(nil, "batch_tools") -- 3319
		end -- 3319
		if result.directSummary and result.directSummary ~= "" then -- 3319
			shared.response = result.directSummary -- 3323
			shared.done = true -- 3324
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3325
			persistHistoryState(shared) -- 3330
			return ____awaiter_resolve(nil, "done") -- 3330
		end -- 3330
		if result.tool == "finish" then -- 3330
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3334
			shared.response = finalMessage -- 3335
			shared.done = true -- 3336
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3337
			persistHistoryState(shared) -- 3342
			return ____awaiter_resolve(nil, "done") -- 3342
		end -- 3342
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3345
		shared.step = shared.step + 1 -- 3346
		local step = shared.step -- 3347
		emitAgentEvent(shared, { -- 3348
			type = "decision_made", -- 3349
			sessionId = shared.sessionId, -- 3350
			taskId = shared.taskId, -- 3351
			step = step, -- 3352
			tool = result.tool, -- 3353
			reason = result.reason, -- 3354
			reasoningContent = result.reasoningContent, -- 3355
			params = result.params -- 3356
		}) -- 3356
		local ____shared_history_58 = shared.history -- 3356
		____shared_history_58[#____shared_history_58 + 1] = { -- 3358
			step = step, -- 3359
			toolCallId = toolCallId, -- 3360
			tool = result.tool, -- 3361
			reason = result.reason or "", -- 3362
			reasoningContent = result.reasoningContent, -- 3363
			params = result.params, -- 3364
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3365
		} -- 3365
		local action = shared.history[#shared.history] -- 3367
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3368
		if canPreExecuteTool(action.tool) then -- 3368
			shared.pendingToolActions = {action} -- 3370
			persistHistoryState(shared) -- 3371
			return ____awaiter_resolve(nil, "batch_tools") -- 3371
		end -- 3371
		clearPreExecutedResults(shared) -- 3374
		persistHistoryState(shared) -- 3375
		return ____awaiter_resolve(nil, result.tool) -- 3375
	end) -- 3375
end -- 3262
local ReadFileAction = __TS__Class() -- 3380
ReadFileAction.name = "ReadFileAction" -- 3380
__TS__ClassExtends(ReadFileAction, Node) -- 3380
function ReadFileAction.prototype.prep(self, shared) -- 3381
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3381
		local last = shared.history[#shared.history] -- 3382
		if not last then -- 3382
			error( -- 3383
				__TS__New(Error, "no history"), -- 3383
				0 -- 3383
			) -- 3383
		end -- 3383
		emitAgentStartEvent(shared, last) -- 3384
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3385
		if __TS__StringTrim(path) == "" then -- 3385
			error( -- 3388
				__TS__New(Error, "missing path"), -- 3388
				0 -- 3388
			) -- 3388
		end -- 3388
		local ____path_61 = path -- 3390
		local ____shared_workingDir_62 = shared.workingDir -- 3392
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 3393
		local ____last_params_startLine_59 = last.params.startLine -- 3394
		if ____last_params_startLine_59 == nil then -- 3394
			____last_params_startLine_59 = 1 -- 3394
		end -- 3394
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 3394
		local ____last_params_endLine_60 = last.params.endLine -- 3395
		if ____last_params_endLine_60 == nil then -- 3395
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 3395
		end -- 3395
		return ____awaiter_resolve( -- 3395
			nil, -- 3395
			{ -- 3389
				path = ____path_61, -- 3390
				tool = "read_file", -- 3391
				workDir = ____shared_workingDir_62, -- 3392
				docLanguage = ____temp_63, -- 3393
				startLine = ____TS__Number_result_64, -- 3394
				endLine = __TS__Number(____last_params_endLine_60) -- 3395
			} -- 3395
		) -- 3395
	end) -- 3395
end -- 3381
function ReadFileAction.prototype.exec(self, input) -- 3399
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3399
		return ____awaiter_resolve( -- 3399
			nil, -- 3399
			Tools.readFile( -- 3400
				input.workDir, -- 3401
				input.path, -- 3402
				__TS__Number(input.startLine or 1), -- 3403
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 3404
				input.docLanguage -- 3405
			) -- 3405
		) -- 3405
	end) -- 3405
end -- 3399
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3409
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3409
		local result = execRes -- 3410
		local last = shared.history[#shared.history] -- 3411
		if last ~= nil then -- 3411
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3413
			appendToolResultMessage(shared, last) -- 3414
			emitAgentFinishEvent(shared, last) -- 3415
		end -- 3415
		persistHistoryState(shared) -- 3417
		__TS__Await(maybeCompressHistory(shared)) -- 3418
		persistHistoryState(shared) -- 3419
		return ____awaiter_resolve(nil, "main") -- 3419
	end) -- 3419
end -- 3409
local SearchFilesAction = __TS__Class() -- 3424
SearchFilesAction.name = "SearchFilesAction" -- 3424
__TS__ClassExtends(SearchFilesAction, Node) -- 3424
function SearchFilesAction.prototype.prep(self, shared) -- 3425
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3425
		local last = shared.history[#shared.history] -- 3426
		if not last then -- 3426
			error( -- 3427
				__TS__New(Error, "no history"), -- 3427
				0 -- 3427
			) -- 3427
		end -- 3427
		emitAgentStartEvent(shared, last) -- 3428
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3428
	end) -- 3428
end -- 3425
function SearchFilesAction.prototype.exec(self, input) -- 3432
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3432
		local params = input.params -- 3433
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 3434
		local ____input_workDir_71 = input.workDir -- 3435
		local ____temp_72 = params.path or "" -- 3436
		local ____temp_73 = params.pattern or "" -- 3437
		local ____params_globs_74 = params.globs -- 3438
		local ____params_useRegex_75 = params.useRegex -- 3439
		local ____params_caseSensitive_76 = params.caseSensitive -- 3440
		local ____math_max_67 = math.max -- 3443
		local ____math_floor_66 = math.floor -- 3443
		local ____params_limit_65 = params.limit -- 3443
		if ____params_limit_65 == nil then -- 3443
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 3443
		end -- 3443
		local ____math_max_67_result_77 = ____math_max_67( -- 3443
			1, -- 3443
			____math_floor_66(__TS__Number(____params_limit_65)) -- 3443
		) -- 3443
		local ____math_max_70 = math.max -- 3444
		local ____math_floor_69 = math.floor -- 3444
		local ____params_offset_68 = params.offset -- 3444
		if ____params_offset_68 == nil then -- 3444
			____params_offset_68 = 0 -- 3444
		end -- 3444
		local result = __TS__Await(____Tools_searchFiles_78({ -- 3434
			workDir = ____input_workDir_71, -- 3435
			path = ____temp_72, -- 3436
			pattern = ____temp_73, -- 3437
			globs = ____params_globs_74, -- 3438
			useRegex = ____params_useRegex_75, -- 3439
			caseSensitive = ____params_caseSensitive_76, -- 3440
			includeContent = true, -- 3441
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3442
			limit = ____math_max_67_result_77, -- 3443
			offset = ____math_max_70( -- 3444
				0, -- 3444
				____math_floor_69(__TS__Number(____params_offset_68)) -- 3444
			), -- 3444
			groupByFile = params.groupByFile == true -- 3445
		})) -- 3445
		return ____awaiter_resolve(nil, result) -- 3445
	end) -- 3445
end -- 3432
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3450
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3450
		local last = shared.history[#shared.history] -- 3451
		if last ~= nil then -- 3451
			local result = execRes -- 3453
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3454
			appendToolResultMessage(shared, last) -- 3455
			emitAgentFinishEvent(shared, last) -- 3456
		end -- 3456
		persistHistoryState(shared) -- 3458
		__TS__Await(maybeCompressHistory(shared)) -- 3459
		persistHistoryState(shared) -- 3460
		return ____awaiter_resolve(nil, "main") -- 3460
	end) -- 3460
end -- 3450
local SearchDoraAPIAction = __TS__Class() -- 3465
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3465
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3465
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3466
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3466
		local last = shared.history[#shared.history] -- 3467
		if not last then -- 3467
			error( -- 3468
				__TS__New(Error, "no history"), -- 3468
				0 -- 3468
			) -- 3468
		end -- 3468
		emitAgentStartEvent(shared, last) -- 3469
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3469
	end) -- 3469
end -- 3466
function SearchDoraAPIAction.prototype.exec(self, input) -- 3473
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3473
		local params = input.params -- 3474
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 3475
		local ____temp_82 = params.pattern or "" -- 3476
		local ____temp_83 = params.docSource or "api" -- 3477
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 3478
		local ____temp_85 = params.programmingLanguage or "ts" -- 3479
		local ____math_min_81 = math.min -- 3480
		local ____math_max_80 = math.max -- 3480
		local ____params_limit_79 = params.limit -- 3480
		if ____params_limit_79 == nil then -- 3480
			____params_limit_79 = 8 -- 3480
		end -- 3480
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 3475
			pattern = ____temp_82, -- 3476
			docSource = ____temp_83, -- 3477
			docLanguage = ____temp_84, -- 3478
			programmingLanguage = ____temp_85, -- 3479
			limit = ____math_min_81( -- 3480
				SEARCH_DORA_API_LIMIT_MAX, -- 3480
				____math_max_80( -- 3480
					1, -- 3480
					__TS__Number(____params_limit_79) -- 3480
				) -- 3480
			), -- 3480
			useRegex = params.useRegex, -- 3481
			caseSensitive = false, -- 3482
			includeContent = true, -- 3483
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3484
		})) -- 3484
		return ____awaiter_resolve(nil, result) -- 3484
	end) -- 3484
end -- 3473
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3489
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3489
		local last = shared.history[#shared.history] -- 3490
		if last ~= nil then -- 3490
			local result = execRes -- 3492
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3493
			appendToolResultMessage(shared, last) -- 3494
			emitAgentFinishEvent(shared, last) -- 3495
		end -- 3495
		persistHistoryState(shared) -- 3497
		__TS__Await(maybeCompressHistory(shared)) -- 3498
		persistHistoryState(shared) -- 3499
		return ____awaiter_resolve(nil, "main") -- 3499
	end) -- 3499
end -- 3489
local ListFilesAction = __TS__Class() -- 3504
ListFilesAction.name = "ListFilesAction" -- 3504
__TS__ClassExtends(ListFilesAction, Node) -- 3504
function ListFilesAction.prototype.prep(self, shared) -- 3505
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3505
		local last = shared.history[#shared.history] -- 3506
		if not last then -- 3506
			error( -- 3507
				__TS__New(Error, "no history"), -- 3507
				0 -- 3507
			) -- 3507
		end -- 3507
		emitAgentStartEvent(shared, last) -- 3508
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3508
	end) -- 3508
end -- 3505
function ListFilesAction.prototype.exec(self, input) -- 3512
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3512
		local params = input.params -- 3513
		local ____Tools_listFiles_93 = Tools.listFiles -- 3514
		local ____input_workDir_90 = input.workDir -- 3515
		local ____temp_91 = params.path or "" -- 3516
		local ____params_globs_92 = params.globs -- 3517
		local ____math_max_89 = math.max -- 3518
		local ____math_floor_88 = math.floor -- 3518
		local ____params_maxEntries_87 = params.maxEntries -- 3518
		if ____params_maxEntries_87 == nil then -- 3518
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3518
		end -- 3518
		local result = ____Tools_listFiles_93({ -- 3514
			workDir = ____input_workDir_90, -- 3515
			path = ____temp_91, -- 3516
			globs = ____params_globs_92, -- 3517
			maxEntries = ____math_max_89( -- 3518
				1, -- 3518
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3518
			) -- 3518
		}) -- 3518
		return ____awaiter_resolve(nil, result) -- 3518
	end) -- 3518
end -- 3512
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3523
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3523
		local last = shared.history[#shared.history] -- 3524
		if last ~= nil then -- 3524
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3526
			appendToolResultMessage(shared, last) -- 3527
			emitAgentFinishEvent(shared, last) -- 3528
		end -- 3528
		persistHistoryState(shared) -- 3530
		__TS__Await(maybeCompressHistory(shared)) -- 3531
		persistHistoryState(shared) -- 3532
		return ____awaiter_resolve(nil, "main") -- 3532
	end) -- 3532
end -- 3523
local DeleteFileAction = __TS__Class() -- 3537
DeleteFileAction.name = "DeleteFileAction" -- 3537
__TS__ClassExtends(DeleteFileAction, Node) -- 3537
function DeleteFileAction.prototype.prep(self, shared) -- 3538
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3538
		local last = shared.history[#shared.history] -- 3539
		if not last then -- 3539
			error( -- 3540
				__TS__New(Error, "no history"), -- 3540
				0 -- 3540
			) -- 3540
		end -- 3540
		emitAgentStartEvent(shared, last) -- 3541
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3542
		if __TS__StringTrim(targetFile) == "" then -- 3542
			error( -- 3545
				__TS__New(Error, "missing target_file"), -- 3545
				0 -- 3545
			) -- 3545
		end -- 3545
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3545
	end) -- 3545
end -- 3538
function DeleteFileAction.prototype.exec(self, input) -- 3549
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3549
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3550
		if not result.success then -- 3550
			return ____awaiter_resolve(nil, result) -- 3550
		end -- 3550
		return ____awaiter_resolve(nil, { -- 3550
			success = true, -- 3558
			changed = true, -- 3559
			mode = "delete", -- 3560
			checkpointId = result.checkpointId, -- 3561
			checkpointSeq = result.checkpointSeq, -- 3562
			files = {{path = input.targetFile, op = "delete"}} -- 3563
		}) -- 3563
	end) -- 3563
end -- 3549
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3567
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3567
		local last = shared.history[#shared.history] -- 3568
		if last ~= nil then -- 3568
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3570
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3571
			appendToolResultMessage(shared, last) -- 3572
			emitAgentFinishEvent(shared, last) -- 3573
			local result = last.result -- 3574
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3574
				emitAgentEvent(shared, { -- 3579
					type = "checkpoint_created", -- 3580
					sessionId = shared.sessionId, -- 3581
					taskId = shared.taskId, -- 3582
					step = last.step, -- 3583
					tool = "delete_file", -- 3584
					checkpointId = result.checkpointId, -- 3585
					checkpointSeq = result.checkpointSeq, -- 3586
					files = result.files -- 3587
				}) -- 3587
			end -- 3587
			if last.result and last.result.success == true then -- 3587
				invalidateReadOnlyToolCache(shared, "delete_file") -- 3591
			end -- 3591
		end -- 3591
		persistHistoryState(shared) -- 3594
		__TS__Await(maybeCompressHistory(shared)) -- 3595
		persistHistoryState(shared) -- 3596
		return ____awaiter_resolve(nil, "main") -- 3596
	end) -- 3596
end -- 3567
local BuildAction = __TS__Class() -- 3601
BuildAction.name = "BuildAction" -- 3601
__TS__ClassExtends(BuildAction, Node) -- 3601
function BuildAction.prototype.prep(self, shared) -- 3602
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3602
		local last = shared.history[#shared.history] -- 3603
		if not last then -- 3603
			error( -- 3604
				__TS__New(Error, "no history"), -- 3604
				0 -- 3604
			) -- 3604
		end -- 3604
		emitAgentStartEvent(shared, last) -- 3605
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3605
	end) -- 3605
end -- 3602
function BuildAction.prototype.exec(self, input) -- 3609
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3609
		local params = input.params -- 3610
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3611
		return ____awaiter_resolve(nil, result) -- 3611
	end) -- 3611
end -- 3609
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3618
		local last = shared.history[#shared.history] -- 3619
		if last ~= nil then -- 3619
			last.result = sanitizeBuildResultForHistory(execRes) -- 3621
			appendToolResultMessage(shared, last) -- 3622
			emitAgentFinishEvent(shared, last) -- 3623
		end -- 3623
		invalidateReadOnlyToolCache(shared, "build") -- 3625
		persistHistoryState(shared) -- 3626
		__TS__Await(maybeCompressHistory(shared)) -- 3627
		persistHistoryState(shared) -- 3628
		return ____awaiter_resolve(nil, "main") -- 3628
	end) -- 3628
end -- 3618
local SpawnSubAgentAction = __TS__Class() -- 3633
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3633
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3633
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3634
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3634
		local last = shared.history[#shared.history] -- 3643
		if not last then -- 3643
			error( -- 3644
				__TS__New(Error, "no history"), -- 3644
				0 -- 3644
			) -- 3644
		end -- 3644
		emitAgentStartEvent(shared, last) -- 3645
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3646
			last.params.filesHint, -- 3647
			function(____, item) return type(item) == "string" end -- 3647
		) or nil -- 3647
		return ____awaiter_resolve( -- 3647
			nil, -- 3647
			{ -- 3649
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3650
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3651
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3652
				filesHint = filesHint, -- 3653
				sessionId = shared.sessionId, -- 3654
				projectRoot = shared.workingDir, -- 3655
				spawnSubAgent = shared.spawnSubAgent -- 3656
			} -- 3656
		) -- 3656
	end) -- 3656
end -- 3634
function SpawnSubAgentAction.prototype.exec(self, input) -- 3660
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3660
		if not input.spawnSubAgent then -- 3660
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3660
		end -- 3660
		if input.sessionId == nil or input.sessionId <= 0 then -- 3660
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3660
		end -- 3660
		local ____Log_99 = Log -- 3675
		local ____temp_96 = #input.title -- 3675
		local ____temp_97 = #input.prompt -- 3675
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3675
		local ____opt_94 = input.filesHint -- 3675
		____Log_99( -- 3675
			"Info", -- 3675
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3675
		) -- 3675
		local result = __TS__Await(input.spawnSubAgent({ -- 3676
			parentSessionId = input.sessionId, -- 3677
			projectRoot = input.projectRoot, -- 3678
			title = input.title, -- 3679
			prompt = input.prompt, -- 3680
			expectedOutput = input.expectedOutput, -- 3681
			filesHint = input.filesHint -- 3682
		})) -- 3682
		if not result.success then -- 3682
			return ____awaiter_resolve(nil, result) -- 3682
		end -- 3682
		return ____awaiter_resolve(nil, { -- 3682
			success = true, -- 3688
			sessionId = result.sessionId, -- 3689
			taskId = result.taskId, -- 3690
			title = result.title, -- 3691
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3692
		}) -- 3692
	end) -- 3692
end -- 3660
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3696
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3696
		local last = shared.history[#shared.history] -- 3697
		if last ~= nil then -- 3697
			last.result = execRes -- 3699
			appendToolResultMessage(shared, last) -- 3700
			emitAgentFinishEvent(shared, last) -- 3701
		end -- 3701
		persistHistoryState(shared) -- 3703
		__TS__Await(maybeCompressHistory(shared)) -- 3704
		persistHistoryState(shared) -- 3705
		return ____awaiter_resolve(nil, "main") -- 3705
	end) -- 3705
end -- 3696
local ListSubAgentsAction = __TS__Class() -- 3710
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3710
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3710
function ListSubAgentsAction.prototype.prep(self, shared) -- 3711
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3711
		local last = shared.history[#shared.history] -- 3720
		if not last then -- 3720
			error( -- 3721
				__TS__New(Error, "no history"), -- 3721
				0 -- 3721
			) -- 3721
		end -- 3721
		emitAgentStartEvent(shared, last) -- 3722
		return ____awaiter_resolve( -- 3722
			nil, -- 3722
			{ -- 3723
				sessionId = shared.sessionId, -- 3724
				projectRoot = shared.workingDir, -- 3725
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3726
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3727
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3728
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3729
				listSubAgents = shared.listSubAgents -- 3730
			} -- 3730
		) -- 3730
	end) -- 3730
end -- 3711
function ListSubAgentsAction.prototype.exec(self, input) -- 3734
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3734
		if not input.listSubAgents then -- 3734
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3734
		end -- 3734
		if input.sessionId == nil or input.sessionId <= 0 then -- 3734
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3734
		end -- 3734
		local result = __TS__Await(input.listSubAgents({ -- 3749
			sessionId = input.sessionId, -- 3750
			projectRoot = input.projectRoot, -- 3751
			status = input.status, -- 3752
			limit = input.limit, -- 3753
			offset = input.offset, -- 3754
			query = input.query -- 3755
		})) -- 3755
		return ____awaiter_resolve(nil, result) -- 3755
	end) -- 3755
end -- 3734
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3760
		local last = shared.history[#shared.history] -- 3761
		if last ~= nil then -- 3761
			last.result = execRes -- 3763
			appendToolResultMessage(shared, last) -- 3764
			emitAgentFinishEvent(shared, last) -- 3765
		end -- 3765
		persistHistoryState(shared) -- 3767
		__TS__Await(maybeCompressHistory(shared)) -- 3768
		persistHistoryState(shared) -- 3769
		return ____awaiter_resolve(nil, "main") -- 3769
	end) -- 3769
end -- 3760
EditFileAction = __TS__Class() -- 3774
EditFileAction.name = "EditFileAction" -- 3774
__TS__ClassExtends(EditFileAction, Node) -- 3774
function EditFileAction.prototype.prep(self, shared) -- 3775
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3775
		local last = shared.history[#shared.history] -- 3776
		if not last then -- 3776
			error( -- 3777
				__TS__New(Error, "no history"), -- 3777
				0 -- 3777
			) -- 3777
		end -- 3777
		emitAgentStartEvent(shared, last) -- 3778
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3779
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3782
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3783
		if __TS__StringTrim(path) == "" then -- 3783
			error( -- 3784
				__TS__New(Error, "missing path"), -- 3784
				0 -- 3784
			) -- 3784
		end -- 3784
		return ____awaiter_resolve(nil, { -- 3784
			path = path, -- 3785
			oldStr = oldStr, -- 3785
			newStr = newStr, -- 3785
			taskId = shared.taskId, -- 3785
			workDir = shared.workingDir -- 3785
		}) -- 3785
	end) -- 3785
end -- 3775
function EditFileAction.prototype.exec(self, input) -- 3788
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3788
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3789
		if not readRes.success then -- 3789
			if input.oldStr ~= "" then -- 3789
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3789
			end -- 3789
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3794
			if not createRes.success then -- 3794
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3794
			end -- 3794
			return ____awaiter_resolve(nil, { -- 3794
				success = true, -- 3802
				changed = true, -- 3803
				mode = "create", -- 3804
				checkpointId = createRes.checkpointId, -- 3805
				checkpointSeq = createRes.checkpointSeq, -- 3806
				files = {{path = input.path, op = "create"}} -- 3807
			}) -- 3807
		end -- 3807
		if input.oldStr == "" then -- 3807
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3811
			if not overwriteRes.success then -- 3811
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3811
			end -- 3811
			return ____awaiter_resolve(nil, { -- 3811
				success = true, -- 3819
				changed = true, -- 3820
				mode = "overwrite", -- 3821
				checkpointId = overwriteRes.checkpointId, -- 3822
				checkpointSeq = overwriteRes.checkpointSeq, -- 3823
				files = {{path = input.path, op = "write"}} -- 3824
			}) -- 3824
		end -- 3824
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3829
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3830
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3831
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3834
		if occurrences == 0 then -- 3834
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3836
			if not indentTolerant.success then -- 3836
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3836
			end -- 3836
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3840
			if not applyRes.success then -- 3840
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3840
			end -- 3840
			return ____awaiter_resolve(nil, { -- 3840
				success = true, -- 3848
				changed = true, -- 3849
				mode = "replace_indent_tolerant", -- 3850
				checkpointId = applyRes.checkpointId, -- 3851
				checkpointSeq = applyRes.checkpointSeq, -- 3852
				files = {{path = input.path, op = "write"}} -- 3853
			}) -- 3853
		end -- 3853
		if occurrences > 1 then -- 3853
			return ____awaiter_resolve( -- 3853
				nil, -- 3853
				{ -- 3857
					success = false, -- 3857
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3857
				} -- 3857
			) -- 3857
		end -- 3857
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3861
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3862
		if not applyRes.success then -- 3862
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3862
		end -- 3862
		return ____awaiter_resolve(nil, { -- 3862
			success = true, -- 3870
			changed = true, -- 3871
			mode = "replace", -- 3872
			checkpointId = applyRes.checkpointId, -- 3873
			checkpointSeq = applyRes.checkpointSeq, -- 3874
			files = {{path = input.path, op = "write"}} -- 3875
		}) -- 3875
	end) -- 3875
end -- 3788
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3879
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3879
		local last = shared.history[#shared.history] -- 3880
		if last ~= nil then -- 3880
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3882
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3883
			appendToolResultMessage(shared, last) -- 3884
			emitAgentFinishEvent(shared, last) -- 3885
			local result = last.result -- 3886
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3886
				emitAgentEvent(shared, { -- 3891
					type = "checkpoint_created", -- 3892
					sessionId = shared.sessionId, -- 3893
					taskId = shared.taskId, -- 3894
					step = last.step, -- 3895
					tool = last.tool, -- 3896
					checkpointId = result.checkpointId, -- 3897
					checkpointSeq = result.checkpointSeq, -- 3898
					files = result.files -- 3899
				}) -- 3899
			end -- 3899
			if last.result and last.result.success == true then -- 3899
				invalidateReadOnlyToolCache(shared, last.tool) -- 3903
			end -- 3903
		end -- 3903
		persistHistoryState(shared) -- 3906
		__TS__Await(maybeCompressHistory(shared)) -- 3907
		persistHistoryState(shared) -- 3908
		return ____awaiter_resolve(nil, "main") -- 3908
	end) -- 3908
end -- 3879
local function emitCheckpointEventForAction(shared, action) -- 3913
	local result = action.result -- 3914
	if not result then -- 3914
		return -- 3915
	end -- 3915
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3915
		emitAgentEvent(shared, { -- 3920
			type = "checkpoint_created", -- 3921
			sessionId = shared.sessionId, -- 3922
			taskId = shared.taskId, -- 3923
			step = action.step, -- 3924
			tool = action.tool, -- 3925
			checkpointId = result.checkpointId, -- 3926
			checkpointSeq = result.checkpointSeq, -- 3927
			files = result.files -- 3928
		}) -- 3928
	end -- 3928
end -- 3913
local function canRunBatchActionInParallel(self, action) -- 4274
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 4275
end -- 4274
local function partitionToolCalls(actions) -- 4287
	local batches = {} -- 4288
	do -- 4288
		local i = 0 -- 4289
		while i < #actions do -- 4289
			local action = actions[i + 1] -- 4290
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4291
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4292
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4292
				local ____lastBatch_actions_138 = lastBatch.actions -- 4292
				____lastBatch_actions_138[#____lastBatch_actions_138 + 1] = action -- 4294
			else -- 4294
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4296
			end -- 4296
			i = i + 1 -- 4289
		end -- 4289
	end -- 4289
	return batches -- 4299
end -- 4287
local BatchToolAction = __TS__Class() -- 4302
BatchToolAction.name = "BatchToolAction" -- 4302
__TS__ClassExtends(BatchToolAction, Node) -- 4302
function BatchToolAction.prototype.prep(self, shared) -- 4303
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4303
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4303
	end) -- 4303
end -- 4303
function BatchToolAction.prototype.exec(self, input) -- 4307
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4307
		local shared = input.shared -- 4308
		local preExecuted = shared.preExecutedResults -- 4309
		local batches = partitionToolCalls(input.actions) -- 4310
		local parallelBatchCount = #__TS__ArrayFilter( -- 4311
			batches, -- 4311
			function(____, b) return b.isConcurrencySafe end -- 4311
		) -- 4311
		local serialBatchCount = #__TS__ArrayFilter( -- 4312
			batches, -- 4312
			function(____, b) return not b.isConcurrencySafe end -- 4312
		) -- 4312
		Log( -- 4313
			"Info", -- 4313
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4313
		) -- 4313
		do -- 4313
			local batchIdx = 0 -- 4315
			while batchIdx < #batches do -- 4315
				do -- 4315
					local batch = batches[batchIdx + 1] -- 4316
					if shared.stopToken.stopped then -- 4316
						for ____, action in ipairs(batch.actions) do -- 4318
							if not action.result then -- 4318
								action.result = { -- 4320
									success = false, -- 4320
									message = getCancelledReason(shared) -- 4320
								} -- 4320
							end -- 4320
						end -- 4320
						goto __continue689 -- 4323
					end -- 4323
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4323
						local preExecCount = #__TS__ArrayFilter( -- 4327
							batch.actions, -- 4327
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4327
						) -- 4327
						Log( -- 4328
							"Info", -- 4328
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4328
						) -- 4328
						do -- 4328
							local i = 0 -- 4329
							while i < #batch.actions do -- 4329
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4330
								i = i + 1 -- 4329
							end -- 4329
						end -- 4329
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4332
							batch.actions, -- 4332
							function(____, action) -- 4332
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4332
									if shared.stopToken.stopped then -- 4332
										action.result = { -- 4334
											success = false, -- 4334
											message = getCancelledReason(shared) -- 4334
										} -- 4334
										return ____awaiter_resolve(nil, action) -- 4334
									end -- 4334
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4337
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4338
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4339
									return ____awaiter_resolve(nil, action) -- 4339
								end) -- 4339
							end -- 4332
						))) -- 4332
						do -- 4332
							local i = 0 -- 4342
							while i < #batch.actions do -- 4342
								local action = batch.actions[i + 1] -- 4343
								if not action.result then -- 4343
									action.result = {success = false, message = "tool did not produce a result"} -- 4345
								end -- 4345
								appendToolResultMessage(shared, action) -- 4347
								emitAgentFinishEvent(shared, action) -- 4348
								emitCheckpointEventForAction(shared, action) -- 4349
								i = i + 1 -- 4342
							end -- 4342
						end -- 4342
					else -- 4342
						Log( -- 4352
							"Info", -- 4352
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4352
						) -- 4352
						do -- 4352
							local i = 0 -- 4353
							while i < #batch.actions do -- 4353
								local action = batch.actions[i + 1] -- 4354
								emitAgentStartEvent(shared, action) -- 4355
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4356
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4357
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4358
								appendToolResultMessage(shared, action) -- 4359
								emitAgentFinishEvent(shared, action) -- 4360
								emitCheckpointEventForAction(shared, action) -- 4361
								persistHistoryState(shared) -- 4362
								if shared.stopToken.stopped then -- 4362
									break -- 4364
								end -- 4364
								i = i + 1 -- 4353
							end -- 4353
						end -- 4353
					end -- 4353
				end -- 4353
				::__continue689:: -- 4353
				batchIdx = batchIdx + 1 -- 4315
			end -- 4315
		end -- 4315
		persistHistoryState(shared) -- 4369
		return ____awaiter_resolve(nil, input.actions) -- 4369
	end) -- 4369
end -- 4307
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4373
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4373
		shared.pendingToolActions = nil -- 4374
		shared.preExecutedResults = nil -- 4375
		persistHistoryState(shared) -- 4376
		__TS__Await(maybeCompressHistory(shared)) -- 4377
		persistHistoryState(shared) -- 4378
		return ____awaiter_resolve(nil, "main") -- 4378
	end) -- 4378
end -- 4373
local EndNode = __TS__Class() -- 4383
EndNode.name = "EndNode" -- 4383
__TS__ClassExtends(EndNode, Node) -- 4383
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4384
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4384
		return ____awaiter_resolve(nil, nil) -- 4384
	end) -- 4384
end -- 4384
local CodingAgentFlow = __TS__Class() -- 4389
CodingAgentFlow.name = "CodingAgentFlow" -- 4389
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4389
function CodingAgentFlow.prototype.____constructor(self, role) -- 4390
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4391
	local read = __TS__New(ReadFileAction, 1, 0) -- 4392
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4393
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4394
	local list = __TS__New(ListFilesAction, 1, 0) -- 4395
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4396
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4397
	local build = __TS__New(BuildAction, 1, 0) -- 4398
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4399
	local edit = __TS__New(EditFileAction, 1, 0) -- 4400
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4401
	local done = __TS__New(EndNode, 1, 0) -- 4402
	main:on("batch_tools", batch) -- 4404
	main:on("grep_files", search) -- 4405
	main:on("search_dora_api", searchDora) -- 4406
	main:on("glob_files", list) -- 4407
	if role == "main" then -- 4407
		main:on("read_file", read) -- 4409
		main:on("delete_file", del) -- 4410
		main:on("build", build) -- 4411
		main:on("edit_file", edit) -- 4412
		main:on("list_sub_agents", listSub) -- 4413
		main:on("spawn_sub_agent", spawn) -- 4414
	else -- 4414
		main:on("read_file", read) -- 4416
		main:on("delete_file", del) -- 4417
		main:on("build", build) -- 4418
		main:on("edit_file", edit) -- 4419
	end -- 4419
	main:on("done", done) -- 4421
	search:on("main", main) -- 4423
	searchDora:on("main", main) -- 4424
	list:on("main", main) -- 4425
	listSub:on("main", main) -- 4426
	spawn:on("main", main) -- 4427
	batch:on("main", main) -- 4428
	read:on("main", main) -- 4429
	del:on("main", main) -- 4430
	build:on("main", main) -- 4431
	edit:on("main", main) -- 4432
	Flow.prototype.____constructor(self, main) -- 4434
end -- 4390
local function runCodingAgentAsync(options) -- 4456
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4456
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4456
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4456
		end -- 4456
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4460
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4461
		if not llmConfigRes.success then -- 4461
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4461
		end -- 4461
		local llmConfig = llmConfigRes.config -- 4467
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 4468
		if not taskRes.success then -- 4468
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4468
		end -- 4468
		local compressor = __TS__New(MemoryCompressor, { -- 4475
			compressionThreshold = 0.8, -- 4476
			compressionTargetThreshold = 0.5, -- 4477
			maxCompressionRounds = 3, -- 4478
			projectDir = options.workDir, -- 4479
			llmConfig = llmConfig, -- 4480
			promptPack = options.promptPack, -- 4481
			scope = options.memoryScope -- 4482
		}) -- 4482
		local persistedSession = compressor:getStorage():readSessionState() -- 4484
		local promptPack = compressor:getPromptPack() -- 4485
		local shared = { -- 4487
			sessionId = options.sessionId, -- 4488
			taskId = taskRes.taskId, -- 4489
			role = options.role or "main", -- 4490
			maxSteps = math.max( -- 4491
				1, -- 4491
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 4491
			), -- 4491
			llmMaxTry = math.max( -- 4492
				1, -- 4492
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 4492
			), -- 4492
			step = 0, -- 4493
			done = false, -- 4494
			stopToken = options.stopToken or ({stopped = false}), -- 4495
			response = "", -- 4496
			userQuery = normalizedPrompt, -- 4497
			workingDir = options.workDir, -- 4498
			useChineseResponse = options.useChineseResponse == true, -- 4499
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4500
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4503
			llmConfig = llmConfig, -- 4504
			onEvent = options.onEvent, -- 4505
			promptPack = promptPack, -- 4506
			history = {}, -- 4507
			toolCache = createAgentToolCache(), -- 4508
			promptCache = {}, -- 4509
			messages = persistedSession.messages, -- 4510
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4511
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4512
			memory = {compressor = compressor}, -- 4514
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 4518
			spawnSubAgent = options.spawnSubAgent, -- 4523
			listSubAgents = options.listSubAgents -- 4524
		} -- 4524
		local ____hasReturned, ____returnValue -- 4524
		local ____try = __TS__AsyncAwaiter(function() -- 4524
			emitAgentEvent(shared, { -- 4528
				type = "task_started", -- 4529
				sessionId = shared.sessionId, -- 4530
				taskId = shared.taskId, -- 4531
				prompt = shared.userQuery, -- 4532
				workDir = shared.workingDir, -- 4533
				maxSteps = shared.maxSteps -- 4534
			}) -- 4534
			if shared.stopToken.stopped then -- 4534
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4537
				____hasReturned = true -- 4538
				____returnValue = emitAgentTaskFinishEvent( -- 4538
					shared, -- 4538
					false, -- 4538
					getCancelledReason(shared) -- 4538
				) -- 4538
				return -- 4538
			end -- 4538
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4540
			local promptCommand = getPromptCommand(shared.userQuery) -- 4541
			if promptCommand == "clear" then -- 4541
				____hasReturned = true -- 4543
				____returnValue = clearSessionHistory(shared) -- 4543
				return -- 4543
			end -- 4543
			if promptCommand == "compact" then -- 4543
				if shared.role == "sub" then -- 4543
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4547
					____hasReturned = true -- 4548
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4548
					return -- 4548
				end -- 4548
				____hasReturned = true -- 4556
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4556
				return -- 4556
			end -- 4556
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4558
			persistHistoryState(shared) -- 4562
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4563
			__TS__Await(flow:run(shared)) -- 4564
			if shared.stopToken.stopped then -- 4564
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4566
				____hasReturned = true -- 4567
				____returnValue = emitAgentTaskFinishEvent( -- 4567
					shared, -- 4567
					false, -- 4567
					getCancelledReason(shared) -- 4567
				) -- 4567
				return -- 4567
			end -- 4567
			if shared.error then -- 4567
				____hasReturned = true -- 4570
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4570
				return -- 4570
			end -- 4570
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4573
			____hasReturned = true -- 4574
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4574
			return -- 4574
		end) -- 4574
		____try = ____try.catch( -- 4574
			____try, -- 4574
			function(____, e) -- 4574
				return __TS__AsyncAwaiter(function() -- 4574
					____hasReturned = true -- 4577
					____returnValue = finalizeAgentFailure( -- 4577
						shared, -- 4577
						tostring(e) -- 4577
					) -- 4577
					return -- 4577
				end) -- 4577
			end -- 4577
		) -- 4577
		__TS__Await(____try) -- 4527
		if ____hasReturned then -- 4527
			return ____awaiter_resolve(nil, ____returnValue) -- 4527
		end -- 4527
	end) -- 4527
end -- 4456
function ____exports.runCodingAgent(options, callback) -- 4581
	local ____self_141 = runCodingAgentAsync(options) -- 4581
	____self_141["then"]( -- 4581
		____self_141, -- 4581
		function(____, result) return callback(result) end -- 4582
	) -- 4582
end -- 4581
return ____exports -- 4581