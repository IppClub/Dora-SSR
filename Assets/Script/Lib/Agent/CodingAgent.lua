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
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local isArray, stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, getCancelledReason, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, getFinishMessage, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, executeToolAction, emitAgentTaskFinishEvent, READ_FILE_DEFAULT_LIMIT, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT, SEARCH_PREVIEW_CONTEXT, EditFileAction -- 1
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
function emitAgentEvent(shared, event) -- 729
	if shared.onEvent then -- 729
		do -- 729
			local function ____catch(____error) -- 729
				Log( -- 734
					"Error", -- 734
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 734
				) -- 734
			end -- 734
			local ____try, ____hasReturned = pcall(function() -- 734
				shared:onEvent(event) -- 732
			end) -- 732
			if not ____try then -- 732
				____catch(____hasReturned) -- 732
			end -- 732
		end -- 732
	end -- 732
end -- 732
function getCancelledReason(shared) -- 795
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 795
		return shared.stopToken.reason -- 796
	end -- 796
	return shared.useChineseResponse and "已取消" or "cancelled" -- 797
end -- 797
function truncateText(text, maxLen) -- 978
	if #text <= maxLen then -- 978
		return text -- 979
	end -- 979
	local nextPos = utf8.offset(text, maxLen + 1) -- 980
	if nextPos == nil then -- 980
		return text -- 981
	end -- 981
	return string.sub(text, 1, nextPos - 1) .. "..." -- 982
end -- 982
function getReplyLanguageDirective(shared) -- 992
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 993
end -- 993
function replacePromptVars(template, vars) -- 998
	local output = template -- 999
	for key in pairs(vars) do -- 1000
		output = table.concat( -- 1001
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1001
			vars[key] or "" or "," -- 1001
		) -- 1001
	end -- 1001
	return output -- 1003
end -- 1003
function getDecisionToolDefinitions(shared) -- 1154
	local base = replacePromptVars( -- 1155
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1156
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1157
	) -- 1157
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1159
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1180
		getAllowedToolsForRole(shared.role), -- 1181
		", " -- 1181
	) or "" -- 1181
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1183
	if (shared and shared.decisionMode) ~= "xml" then -- 1183
		return withRole -- 1185
	end -- 1185
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1187
end -- 1187
function getFinishMessage(params, fallback) -- 1486
	if fallback == nil then -- 1486
		fallback = "" -- 1486
	end -- 1486
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1486
		return __TS__StringTrim(params.message) -- 1488
	end -- 1488
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1488
		return __TS__StringTrim(params.response) -- 1491
	end -- 1491
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1491
		return __TS__StringTrim(params.summary) -- 1494
	end -- 1494
	return __TS__StringTrim(fallback) -- 1496
end -- 1496
function persistHistoryState(shared) -- 1499
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1500
end -- 1500
function getActiveConversationMessages(shared) -- 1507
	local activeMessages = {} -- 1508
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1508
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1515
	end -- 1515
	do -- 1515
		local i = shared.lastConsolidatedIndex -- 1519
		while i < #shared.messages do -- 1519
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1520
			i = i + 1 -- 1519
		end -- 1519
	end -- 1519
	return activeMessages -- 1522
end -- 1522
function getActiveRealMessageCount(shared) -- 1525
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1526
end -- 1526
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1529
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1534
	local previousActiveStart = shared.lastConsolidatedIndex -- 1535
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1536
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1537
	if type(carryMessageIndex) == "number" then -- 1537
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1537
		else -- 1537
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1545
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1548
		end -- 1548
	else -- 1548
		shared.carryMessageIndex = nil -- 1553
	end -- 1553
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1553
		shared.carryMessageIndex = nil -- 1563
	end -- 1563
end -- 1563
function getDecisionPath(params) -- 1819
	if type(params.path) == "string" then -- 1819
		return __TS__StringTrim(params.path) -- 1820
	end -- 1820
	if type(params.target_file) == "string" then -- 1820
		return __TS__StringTrim(params.target_file) -- 1821
	end -- 1821
	return "" -- 1822
end -- 1822
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1825
	local num = __TS__Number(value) -- 1826
	if not __TS__NumberIsFinite(num) then -- 1826
		num = fallback -- 1827
	end -- 1827
	num = math.floor(num) -- 1828
	if num < minValue then -- 1828
		num = minValue -- 1829
	end -- 1829
	if maxValue ~= nil and num > maxValue then -- 1829
		num = maxValue -- 1830
	end -- 1830
	return num -- 1831
end -- 1831
function parseReadLineParam(value, fallback, paramName) -- 1834
	local num = __TS__Number(value) -- 1839
	if not __TS__NumberIsFinite(num) then -- 1839
		num = fallback -- 1840
	end -- 1840
	num = math.floor(num) -- 1841
	if num == 0 then -- 1841
		return {success = false, message = paramName .. " cannot be 0"} -- 1843
	end -- 1843
	return {success = true, value = num} -- 1845
end -- 1845
function validateDecision(tool, params) -- 1848
	if tool == "finish" then -- 1848
		local message = getFinishMessage(params) -- 1853
		if message == "" then -- 1853
			return {success = false, message = "finish requires params.message"} -- 1854
		end -- 1854
		params.message = message -- 1855
		return {success = true, params = params} -- 1856
	end -- 1856
	if tool == "read_file" then -- 1856
		local path = getDecisionPath(params) -- 1860
		if path == "" then -- 1860
			return {success = false, message = "read_file requires path"} -- 1861
		end -- 1861
		params.path = path -- 1862
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1863
		if not startLineRes.success then -- 1863
			return startLineRes -- 1864
		end -- 1864
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1865
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1866
		if not endLineRes.success then -- 1866
			return endLineRes -- 1867
		end -- 1867
		params.startLine = startLineRes.value -- 1868
		params.endLine = endLineRes.value -- 1869
		return {success = true, params = params} -- 1870
	end -- 1870
	if tool == "edit_file" then -- 1870
		local path = getDecisionPath(params) -- 1874
		if path == "" then -- 1874
			return {success = false, message = "edit_file requires path"} -- 1875
		end -- 1875
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1876
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1877
		params.path = path -- 1878
		params.old_str = oldStr -- 1879
		params.new_str = newStr -- 1880
		return {success = true, params = params} -- 1881
	end -- 1881
	if tool == "delete_file" then -- 1881
		local targetFile = getDecisionPath(params) -- 1885
		if targetFile == "" then -- 1885
			return {success = false, message = "delete_file requires target_file"} -- 1886
		end -- 1886
		params.target_file = targetFile -- 1887
		return {success = true, params = params} -- 1888
	end -- 1888
	if tool == "grep_files" then -- 1888
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1892
		if pattern == "" then -- 1892
			return {success = false, message = "grep_files requires pattern"} -- 1893
		end -- 1893
		params.pattern = pattern -- 1894
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1895
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1896
		return {success = true, params = params} -- 1897
	end -- 1897
	if tool == "search_dora_api" then -- 1897
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1901
		if pattern == "" then -- 1901
			return {success = false, message = "search_dora_api requires pattern"} -- 1902
		end -- 1902
		params.pattern = pattern -- 1903
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1904
		return {success = true, params = params} -- 1905
	end -- 1905
	if tool == "glob_files" then -- 1905
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1909
		return {success = true, params = params} -- 1910
	end -- 1910
	if tool == "build" then -- 1910
		local path = getDecisionPath(params) -- 1914
		if path ~= "" then -- 1914
			params.path = path -- 1916
		end -- 1916
		return {success = true, params = params} -- 1918
	end -- 1918
	if tool == "list_sub_agents" then -- 1918
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1922
		if status ~= "" then -- 1922
			params.status = status -- 1924
		end -- 1924
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1926
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1927
		if type(params.query) == "string" then -- 1927
			params.query = __TS__StringTrim(params.query) -- 1929
		end -- 1929
		return {success = true, params = params} -- 1931
	end -- 1931
	if tool == "spawn_sub_agent" then -- 1931
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1935
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1936
		if prompt == "" then -- 1936
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1937
		end -- 1937
		if title == "" then -- 1937
			return {success = false, message = "spawn_sub_agent requires title"} -- 1938
		end -- 1938
		params.prompt = prompt -- 1939
		params.title = title -- 1940
		if type(params.expectedOutput) == "string" then -- 1940
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1942
		end -- 1942
		if isArray(params.filesHint) then -- 1942
			params.filesHint = __TS__ArrayMap( -- 1945
				__TS__ArrayFilter( -- 1945
					params.filesHint, -- 1945
					function(____, item) return type(item) == "string" end -- 1946
				), -- 1946
				function(____, item) return sanitizeUTF8(item) end -- 1947
			) -- 1947
		end -- 1947
		return {success = true, params = params} -- 1949
	end -- 1949
	return {success = true, params = params} -- 1952
end -- 1952
function getAllowedToolsForRole(role) -- 1978
	return role == "main" and ({ -- 1979
		"read_file", -- 1980
		"edit_file", -- 1980
		"delete_file", -- 1980
		"grep_files", -- 1980
		"search_dora_api", -- 1980
		"glob_files", -- 1980
		"build", -- 1980
		"list_sub_agents", -- 1980
		"spawn_sub_agent", -- 1980
		"finish" -- 1980
	}) or ({ -- 1980
		"read_file", -- 1981
		"edit_file", -- 1981
		"delete_file", -- 1981
		"grep_files", -- 1981
		"search_dora_api", -- 1981
		"glob_files", -- 1981
		"build", -- 1981
		"finish" -- 1981
	}) -- 1981
end -- 1981
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2087
	if includeToolDefinitions == nil then -- 2087
		includeToolDefinitions = false -- 2087
	end -- 2087
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2088
	local sections = { -- 2091
		shared.promptPack.agentIdentityPrompt, -- 2092
		rolePrompt, -- 2093
		getReplyLanguageDirective(shared) -- 2094
	} -- 2094
	if shared.decisionMode == "tool_calling" then -- 2094
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2097
	end -- 2097
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2099
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2100
	if memoryContext ~= "" then -- 2100
		sections[#sections + 1] = memoryContext -- 2102
	end -- 2102
	if includeToolDefinitions then -- 2102
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2105
		if shared.decisionMode == "xml" then -- 2105
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2107
		end -- 2107
	end -- 2107
	local skillsSection = buildSkillsSection(shared) -- 2111
	if skillsSection ~= "" then -- 2111
		sections[#sections + 1] = skillsSection -- 2113
	end -- 2113
	return table.concat(sections, "\n\n") -- 2115
end -- 2115
function buildSkillsSection(shared) -- 2118
	local ____opt_42 = shared.skills -- 2118
	if not (____opt_42 and ____opt_42.loader) then -- 2118
		return "" -- 2120
	end -- 2120
	return shared.skills.loader:buildSkillsPromptSection() -- 2122
end -- 2122
function buildXmlDecisionInstruction(shared, feedback) -- 2234
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2235
end -- 2235
function executeToolAction(shared, action) -- 3361
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3361
		if shared.stopToken.stopped then -- 3361
			return ____awaiter_resolve( -- 3361
				nil, -- 3361
				{ -- 3363
					success = false, -- 3363
					message = getCancelledReason(shared) -- 3363
				} -- 3363
			) -- 3363
		end -- 3363
		local params = action.params -- 3365
		if action.tool == "read_file" then -- 3365
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3367
			if __TS__StringTrim(path) == "" then -- 3367
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3367
			end -- 3367
			local ____Tools_readFile_104 = Tools.readFile -- 3371
			local ____shared_workingDir_102 = shared.workingDir -- 3372
			local ____params_startLine_100 = params.startLine -- 3374
			if ____params_startLine_100 == nil then -- 3374
				____params_startLine_100 = 1 -- 3374
			end -- 3374
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3374
			local ____params_endLine_101 = params.endLine -- 3375
			if ____params_endLine_101 == nil then -- 3375
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3375
			end -- 3375
			return ____awaiter_resolve( -- 3375
				nil, -- 3375
				____Tools_readFile_104( -- 3371
					____shared_workingDir_102, -- 3372
					path, -- 3373
					____TS__Number_result_103, -- 3374
					__TS__Number(____params_endLine_101), -- 3375
					shared.useChineseResponse and "zh" or "en" -- 3376
				) -- 3376
			) -- 3376
		end -- 3376
		if action.tool == "grep_files" then -- 3376
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3380
			local ____shared_workingDir_111 = shared.workingDir -- 3381
			local ____temp_112 = params.path or "" -- 3382
			local ____temp_113 = params.pattern or "" -- 3383
			local ____params_globs_114 = params.globs -- 3384
			local ____params_useRegex_115 = params.useRegex -- 3385
			local ____params_caseSensitive_116 = params.caseSensitive -- 3386
			local ____math_max_107 = math.max -- 3389
			local ____math_floor_106 = math.floor -- 3389
			local ____params_limit_105 = params.limit -- 3389
			if ____params_limit_105 == nil then -- 3389
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3389
			end -- 3389
			local ____math_max_107_result_117 = ____math_max_107( -- 3389
				1, -- 3389
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3389
			) -- 3389
			local ____math_max_110 = math.max -- 3390
			local ____math_floor_109 = math.floor -- 3390
			local ____params_offset_108 = params.offset -- 3390
			if ____params_offset_108 == nil then -- 3390
				____params_offset_108 = 0 -- 3390
			end -- 3390
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3380
				workDir = ____shared_workingDir_111, -- 3381
				path = ____temp_112, -- 3382
				pattern = ____temp_113, -- 3383
				globs = ____params_globs_114, -- 3384
				useRegex = ____params_useRegex_115, -- 3385
				caseSensitive = ____params_caseSensitive_116, -- 3386
				includeContent = true, -- 3387
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3388
				limit = ____math_max_107_result_117, -- 3389
				offset = ____math_max_110( -- 3390
					0, -- 3390
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3390
				), -- 3390
				groupByFile = params.groupByFile == true -- 3391
			})) -- 3391
			return ____awaiter_resolve(nil, result) -- 3391
		end -- 3391
		if action.tool == "search_dora_api" then -- 3391
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3396
			local ____temp_122 = params.pattern or "" -- 3397
			local ____temp_123 = params.docSource or "api" -- 3398
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3399
			local ____temp_125 = params.programmingLanguage or "ts" -- 3400
			local ____math_min_121 = math.min -- 3401
			local ____math_max_120 = math.max -- 3401
			local ____params_limit_119 = params.limit -- 3401
			if ____params_limit_119 == nil then -- 3401
				____params_limit_119 = 8 -- 3401
			end -- 3401
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3396
				pattern = ____temp_122, -- 3397
				docSource = ____temp_123, -- 3398
				docLanguage = ____temp_124, -- 3399
				programmingLanguage = ____temp_125, -- 3400
				limit = ____math_min_121( -- 3401
					SEARCH_DORA_API_LIMIT_MAX, -- 3401
					____math_max_120( -- 3401
						1, -- 3401
						__TS__Number(____params_limit_119) -- 3401
					) -- 3401
				), -- 3401
				useRegex = params.useRegex, -- 3402
				caseSensitive = false, -- 3403
				includeContent = true, -- 3404
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3405
			})) -- 3405
			return ____awaiter_resolve(nil, result) -- 3405
		end -- 3405
		if action.tool == "glob_files" then -- 3405
			local ____Tools_listFiles_133 = Tools.listFiles -- 3410
			local ____shared_workingDir_130 = shared.workingDir -- 3411
			local ____temp_131 = params.path or "" -- 3412
			local ____params_globs_132 = params.globs -- 3413
			local ____math_max_129 = math.max -- 3414
			local ____math_floor_128 = math.floor -- 3414
			local ____params_maxEntries_127 = params.maxEntries -- 3414
			if ____params_maxEntries_127 == nil then -- 3414
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3414
			end -- 3414
			local result = ____Tools_listFiles_133({ -- 3410
				workDir = ____shared_workingDir_130, -- 3411
				path = ____temp_131, -- 3412
				globs = ____params_globs_132, -- 3413
				maxEntries = ____math_max_129( -- 3414
					1, -- 3414
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3414
				) -- 3414
			}) -- 3414
			return ____awaiter_resolve(nil, result) -- 3414
		end -- 3414
		if action.tool == "delete_file" then -- 3414
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3419
			if __TS__StringTrim(targetFile) == "" then -- 3419
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3419
			end -- 3419
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3423
			if not result.success then -- 3423
				return ____awaiter_resolve(nil, result) -- 3423
			end -- 3423
			return ____awaiter_resolve(nil, { -- 3423
				success = true, -- 3431
				changed = true, -- 3432
				mode = "delete", -- 3433
				checkpointId = result.checkpointId, -- 3434
				checkpointSeq = result.checkpointSeq, -- 3435
				files = {{path = targetFile, op = "delete"}} -- 3436
			}) -- 3436
		end -- 3436
		if action.tool == "build" then -- 3436
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3440
			return ____awaiter_resolve(nil, result) -- 3440
		end -- 3440
		if action.tool == "spawn_sub_agent" then -- 3440
			if not shared.spawnSubAgent then -- 3440
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3440
			end -- 3440
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3440
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3440
			end -- 3440
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3453
				params.filesHint, -- 3454
				function(____, item) return type(item) == "string" end -- 3454
			) or nil -- 3454
			local result = __TS__Await(shared.spawnSubAgent({ -- 3456
				parentSessionId = shared.sessionId, -- 3457
				projectRoot = shared.workingDir, -- 3458
				title = type(params.title) == "string" and params.title or "Sub", -- 3459
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3460
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3461
				filesHint = filesHint -- 3462
			})) -- 3462
			if not result.success then -- 3462
				return ____awaiter_resolve(nil, result) -- 3462
			end -- 3462
			return ____awaiter_resolve(nil, { -- 3462
				success = true, -- 3468
				sessionId = result.sessionId, -- 3469
				taskId = result.taskId, -- 3470
				title = result.title, -- 3471
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3472
			}) -- 3472
		end -- 3472
		if action.tool == "list_sub_agents" then -- 3472
			if not shared.listSubAgents then -- 3472
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3472
			end -- 3472
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3472
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3472
			end -- 3472
			local result = __TS__Await(shared.listSubAgents({ -- 3482
				sessionId = shared.sessionId, -- 3483
				projectRoot = shared.workingDir, -- 3484
				status = type(params.status) == "string" and params.status or nil, -- 3485
				limit = type(params.limit) == "number" and params.limit or nil, -- 3486
				offset = type(params.offset) == "number" and params.offset or nil, -- 3487
				query = type(params.query) == "string" and params.query or nil -- 3488
			})) -- 3488
			return ____awaiter_resolve(nil, result) -- 3488
		end -- 3488
		if action.tool == "edit_file" then -- 3488
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3493
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3496
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3497
			if __TS__StringTrim(path) == "" then -- 3497
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3497
			end -- 3497
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3499
			return ____awaiter_resolve( -- 3499
				nil, -- 3499
				actionNode:exec({ -- 3500
					path = path, -- 3501
					oldStr = oldStr, -- 3502
					newStr = newStr, -- 3503
					taskId = shared.taskId, -- 3504
					workDir = shared.workingDir -- 3505
				}) -- 3505
			) -- 3505
		end -- 3505
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3505
	end) -- 3505
end -- 3505
function emitAgentTaskFinishEvent(shared, success, message) -- 3655
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3656
	emitAgentEvent(shared, { -- 3662
		type = "task_finished", -- 3663
		sessionId = shared.sessionId, -- 3664
		taskId = shared.taskId, -- 3665
		success = result.success, -- 3666
		message = result.message, -- 3667
		steps = result.steps -- 3668
	}) -- 3668
	return result -- 3670
end -- 3670
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
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 642
local HISTORY_READ_FILE_MAX_LINES = 300 -- 643
READ_FILE_DEFAULT_LIMIT = 300 -- 644
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 645
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 646
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 647
local HISTORY_BUILD_MAX_MESSAGES = 50 -- 648
local HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 649
SEARCH_DORA_API_LIMIT_MAX = 20 -- 650
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 651
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 652
SEARCH_PREVIEW_CONTEXT = 80 -- 653
local AGENT_DEFAULT_MAX_STEPS = 100 -- 654
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 655
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 656
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 657
local function buildLLMOptions(llmConfig, overrides) -- 659
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 660
	if llmConfig.reasoningEffort then -- 660
		options.reasoning_effort = llmConfig.reasoningEffort -- 665
	end -- 665
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 667
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 667
		__TS__Delete(merged, "reasoning_effort") -- 672
	else -- 672
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 674
	end -- 674
	return merged -- 676
end -- 659
local function emitAgentStartEvent(shared, action) -- 739
	emitAgentEvent(shared, { -- 740
		type = "tool_started", -- 741
		sessionId = shared.sessionId, -- 742
		taskId = shared.taskId, -- 743
		step = action.step, -- 744
		tool = action.tool -- 745
	}) -- 745
end -- 739
local function emitAgentFinishEvent(shared, action) -- 749
	emitAgentEvent(shared, { -- 750
		type = "tool_finished", -- 751
		sessionId = shared.sessionId, -- 752
		taskId = shared.taskId, -- 753
		step = action.step, -- 754
		tool = action.tool, -- 755
		result = action.result or ({}) -- 756
	}) -- 756
end -- 749
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 760
	emitAgentEvent(shared, { -- 761
		type = "assistant_message_updated", -- 762
		sessionId = shared.sessionId, -- 763
		taskId = shared.taskId, -- 764
		step = shared.step + 1, -- 765
		content = content, -- 766
		reasoningContent = reasoningContent -- 767
	}) -- 767
end -- 760
local function getMemoryCompressionStartReason(shared) -- 771
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 772
end -- 771
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 777
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 778
end -- 777
local function getMemoryCompressionFailureReason(shared, ____error) -- 783
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 784
end -- 783
local function summarizeHistoryEntryPreview(text, maxChars) -- 789
	if maxChars == nil then -- 789
		maxChars = 180 -- 789
	end -- 789
	local trimmed = __TS__StringTrim(text) -- 790
	if trimmed == "" then -- 790
		return "" -- 791
	end -- 791
	return truncateText(trimmed, maxChars) -- 792
end -- 789
local function getMaxStepsReachedReason(shared) -- 800
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 801
end -- 800
local function getFailureSummaryFallback(shared, ____error) -- 806
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 807
end -- 806
local function finalizeAgentFailure(shared, ____error) -- 812
	if shared.stopToken.stopped then -- 812
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 814
		return emitAgentTaskFinishEvent( -- 815
			shared, -- 815
			false, -- 815
			getCancelledReason(shared) -- 815
		) -- 815
	end -- 815
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 817
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 818
end -- 812
local function getPromptCommand(prompt) -- 821
	local trimmed = __TS__StringTrim(prompt) -- 822
	if trimmed == "/compact" then -- 822
		return "compact" -- 823
	end -- 823
	if trimmed == "/clear" then -- 823
		return "clear" -- 824
	end -- 824
	return nil -- 825
end -- 821
function ____exports.truncateAgentUserPrompt(prompt) -- 828
	if not prompt then -- 828
		return "" -- 829
	end -- 829
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 829
		return prompt -- 830
	end -- 830
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 831
	if offset == nil then -- 831
		return prompt -- 832
	end -- 832
	return string.sub(prompt, 1, offset - 1) -- 833
end -- 828
local function canWriteStepLLMDebug(shared, stepId) -- 836
	if stepId == nil then -- 836
		stepId = shared.step + 1 -- 836
	end -- 836
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 837
end -- 836
local function ensureDirRecursive(dir) -- 844
	if not dir then -- 844
		return false -- 845
	end -- 845
	if Content:exist(dir) then -- 845
		return Content:isdir(dir) -- 846
	end -- 846
	local parent = Path:getPath(dir) -- 847
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 847
		return false -- 849
	end -- 849
	return Content:mkdir(dir) -- 851
end -- 844
local function encodeDebugJSON(value) -- 854
	local text, err = safeJsonEncode(value) -- 855
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 856
end -- 854
local function getStepLLMDebugDir(shared) -- 859
	return Path( -- 860
		shared.workingDir, -- 861
		".agent", -- 862
		tostring(shared.sessionId), -- 863
		tostring(shared.taskId) -- 864
	) -- 864
end -- 859
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 868
	return Path( -- 869
		getStepLLMDebugDir(shared), -- 869
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 869
	) -- 869
end -- 868
local function getLatestStepLLMDebugSeq(shared, stepId) -- 872
	if not canWriteStepLLMDebug(shared, stepId) then -- 872
		return 0 -- 873
	end -- 873
	local dir = getStepLLMDebugDir(shared) -- 874
	if not Content:exist(dir) or not Content:isdir(dir) then -- 874
		return 0 -- 875
	end -- 875
	local latest = 0 -- 876
	for ____, file in ipairs(Content:getFiles(dir)) do -- 877
		do -- 877
			local name = Path:getFilename(file) -- 878
			local seqText = string.match( -- 879
				name, -- 879
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 879
			) -- 879
			if seqText ~= nil then -- 879
				latest = math.max( -- 881
					latest, -- 881
					tonumber(seqText) -- 881
				) -- 881
				goto __continue124 -- 882
			end -- 882
			local legacyMatch = string.match( -- 884
				name, -- 884
				("^" .. tostring(stepId)) .. "_in%.md$" -- 884
			) -- 884
			if legacyMatch ~= nil then -- 884
				latest = math.max(latest, 1) -- 886
			end -- 886
		end -- 886
		::__continue124:: -- 886
	end -- 886
	return latest -- 889
end -- 872
local function writeStepLLMDebugFile(path, content) -- 892
	if not Content:save(path, content) then -- 892
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 894
		return false -- 895
	end -- 895
	return true -- 897
end -- 892
local function createStepLLMDebugPair(shared, stepId, inContent) -- 900
	if not canWriteStepLLMDebug(shared, stepId) then -- 900
		return 0 -- 901
	end -- 901
	local dir = getStepLLMDebugDir(shared) -- 902
	if not ensureDirRecursive(dir) then -- 902
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 904
		return 0 -- 905
	end -- 905
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 907
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 908
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 909
	if not writeStepLLMDebugFile(inPath, inContent) then -- 909
		return 0 -- 911
	end -- 911
	writeStepLLMDebugFile(outPath, "") -- 913
	return seq -- 914
end -- 900
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 917
	if not canWriteStepLLMDebug(shared, stepId) then -- 917
		return -- 918
	end -- 918
	local dir = getStepLLMDebugDir(shared) -- 919
	if not ensureDirRecursive(dir) then -- 919
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 921
		return -- 922
	end -- 922
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 924
	if latestSeq <= 0 then -- 924
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 926
		writeStepLLMDebugFile(outPath, content) -- 927
		return -- 928
	end -- 928
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 930
	writeStepLLMDebugFile(outPath, content) -- 931
end -- 917
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 934
	if not canWriteStepLLMDebug(shared, stepId) then -- 934
		return -- 935
	end -- 935
	local sections = { -- 936
		"# LLM Input", -- 937
		"session_id: " .. tostring(shared.sessionId), -- 938
		"task_id: " .. tostring(shared.taskId), -- 939
		"step_id: " .. tostring(stepId), -- 940
		"phase: " .. phase, -- 941
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 942
		"## Options", -- 943
		"```json", -- 944
		encodeDebugJSON(options), -- 945
		"```" -- 946
	} -- 946
	do -- 946
		local i = 0 -- 948
		while i < #messages do -- 948
			local message = messages[i + 1] -- 949
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 950
			sections[#sections + 1] = encodeDebugJSON(message) -- 951
			i = i + 1 -- 948
		end -- 948
	end -- 948
	createStepLLMDebugPair( -- 953
		shared, -- 953
		stepId, -- 953
		table.concat(sections, "\n") -- 953
	) -- 953
end -- 934
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 956
	if not canWriteStepLLMDebug(shared, stepId) then -- 956
		return -- 957
	end -- 957
	local ____array_2 = __TS__SparseArrayNew( -- 957
		"# LLM Output", -- 959
		"session_id: " .. tostring(shared.sessionId), -- 960
		"task_id: " .. tostring(shared.taskId), -- 961
		"step_id: " .. tostring(stepId), -- 962
		"phase: " .. phase, -- 963
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 964
		table.unpack(meta and ({ -- 965
			"## Meta", -- 965
			"```json", -- 965
			encodeDebugJSON(meta), -- 965
			"```" -- 965
		}) or ({})) -- 965
	) -- 965
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 965
	local sections = {__TS__SparseArraySpread(____array_2)} -- 958
	updateLatestStepLLMDebugOutput( -- 969
		shared, -- 969
		stepId, -- 969
		table.concat(sections, "\n") -- 969
	) -- 969
end -- 956
local function toJson(value) -- 972
	local text, err = safeJsonEncode(value) -- 973
	if text ~= nil then -- 973
		return text -- 974
	end -- 974
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 975
end -- 972
local function utf8TakeHead(text, maxChars) -- 985
	if maxChars <= 0 or text == "" then -- 985
		return "" -- 986
	end -- 986
	local nextPos = utf8.offset(text, maxChars + 1) -- 987
	if nextPos == nil then -- 987
		return text -- 988
	end -- 988
	return string.sub(text, 1, nextPos - 1) -- 989
end -- 985
local function limitReadContentForHistory(content, tool) -- 1006
	local lines = __TS__StringSplit(content, "\n") -- 1007
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1008
	local limitedByLines = overLineLimit and table.concat( -- 1009
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1010
		"\n" -- 1010
	) or content -- 1010
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1010
		return content -- 1013
	end -- 1013
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1015
	local reasons = {} -- 1018
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1018
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1019
	end -- 1019
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1019
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1020
	end -- 1020
	local hint = "Narrow the requested line range." -- 1021
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1022
end -- 1006
local function summarizeEditTextParamForHistory(value, key) -- 1025
	if type(value) ~= "string" then -- 1025
		return nil -- 1026
	end -- 1026
	local text = value -- 1027
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1028
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1029
end -- 1025
local function sanitizeReadResultForHistory(tool, result) -- 1037
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1037
		return result -- 1039
	end -- 1039
	local clone = {} -- 1041
	for key in pairs(result) do -- 1042
		clone[key] = result[key] -- 1043
	end -- 1043
	clone.content = limitReadContentForHistory(result.content, tool) -- 1045
	return clone -- 1046
end -- 1037
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1049
	local shown = math.min(#items, maxItems) -- 1053
	local out = {} -- 1054
	do -- 1054
		local i = 0 -- 1055
		while i < shown do -- 1055
			local row = items[i + 1] -- 1056
			out[#out + 1] = { -- 1057
				file = row.file, -- 1058
				line = row.line, -- 1059
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1060
			} -- 1060
			i = i + 1 -- 1055
		end -- 1055
	end -- 1055
	return out -- 1065
end -- 1049
local function sanitizeSearchResultForHistory(tool, result) -- 1068
	if result.success ~= true or not isArray(result.results) then -- 1068
		return result -- 1072
	end -- 1072
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1072
		return result -- 1073
	end -- 1073
	local clone = {} -- 1074
	for key in pairs(result) do -- 1075
		clone[key] = result[key] -- 1076
	end -- 1076
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1078
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1079
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1079
		local grouped = result.groupedResults -- 1084
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1085
		local sanitizedGroups = {} -- 1086
		do -- 1086
			local i = 0 -- 1087
			while i < shown do -- 1087
				local row = grouped[i + 1] -- 1088
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1089
					file = row.file, -- 1090
					totalMatches = row.totalMatches, -- 1091
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1092
				} -- 1092
				i = i + 1 -- 1087
			end -- 1087
		end -- 1087
		clone.groupedResults = sanitizedGroups -- 1097
	end -- 1097
	return clone -- 1099
end -- 1068
local function sanitizeListFilesResultForHistory(result) -- 1102
	if result.success ~= true or not isArray(result.files) then -- 1102
		return result -- 1103
	end -- 1103
	local clone = {} -- 1104
	for key in pairs(result) do -- 1105
		clone[key] = result[key] -- 1106
	end -- 1106
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1108
	return clone -- 1109
end -- 1102
local function sanitizeBuildResultForHistory(result) -- 1112
	if not isArray(result.messages) then -- 1112
		return result -- 1113
	end -- 1113
	local clone = {} -- 1114
	for key in pairs(result) do -- 1115
		clone[key] = result[key] -- 1116
	end -- 1116
	local messages = result.messages -- 1118
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1119
	local sanitized = {} -- 1120
	do -- 1120
		local i = 0 -- 1121
		while i < shown do -- 1121
			local item = messages[i + 1] -- 1122
			local next = {} -- 1123
			for key in pairs(item) do -- 1124
				local value = item[key] -- 1125
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1126
			end -- 1126
			sanitized[#sanitized + 1] = next -- 1130
			i = i + 1 -- 1121
		end -- 1121
	end -- 1121
	clone.messages = sanitized -- 1132
	if #messages > shown then -- 1132
		clone.truncatedMessages = #messages - shown -- 1134
	end -- 1134
	return clone -- 1136
end -- 1112
local function sanitizeActionParamsForHistory(tool, params) -- 1139
	if tool ~= "edit_file" then -- 1139
		return params -- 1140
	end -- 1140
	local clone = {} -- 1141
	for key in pairs(params) do -- 1142
		if key == "old_str" then -- 1142
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1144
		elseif key == "new_str" then -- 1144
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1146
		else -- 1146
			clone[key] = params[key] -- 1148
		end -- 1148
	end -- 1148
	return clone -- 1151
end -- 1139
local function isToolAllowedForRole(role, tool) -- 1196
	return __TS__ArrayIndexOf( -- 1197
		getAllowedToolsForRole(role), -- 1197
		tool -- 1197
	) >= 0 -- 1197
end -- 1196
local PRE_EXEC_SAFE_TOOLS = { -- 1200
	"read_file", -- 1201
	"grep_files", -- 1202
	"search_dora_api", -- 1203
	"glob_files", -- 1204
	"list_sub_agents" -- 1205
} -- 1205
local function canPreExecuteTool(tool) -- 1208
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1209
end -- 1208
local function clearPreExecutedResults(shared) -- 1212
	shared.preExecutedResults = nil -- 1213
end -- 1212
local function startPreExecutedToolAction(shared, action) -- 1216
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1216
		local ____try = __TS__AsyncAwaiter(function() -- 1216
			return ____awaiter_resolve( -- 1216
				nil, -- 1216
				__TS__Await(executeToolAction(shared, action)) -- 1218
			) -- 1218
		end) -- 1218
		__TS__Await(____try.catch( -- 1217
			____try, -- 1217
			function(____, err) -- 1217
				local message = tostring(err) -- 1220
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1221
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1221
			end -- 1221
		)) -- 1221
	end) -- 1221
end -- 1216
local function executeToolActionWithPreExecution(shared, action) -- 1226
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1226
		local ____opt_9 = shared.preExecutedResults -- 1226
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1227
		if preResult then -- 1227
			Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1229
			local ____opt_11 = shared.preExecutedResults -- 1229
			if ____opt_11 ~= nil then -- 1229
				____opt_11:delete(action.toolCallId) -- 1230
			end -- 1230
			return ____awaiter_resolve( -- 1230
				nil, -- 1230
				__TS__Await(preResult) -- 1231
			) -- 1231
		end -- 1231
		return ____awaiter_resolve( -- 1231
			nil, -- 1231
			executeToolAction(shared, action) -- 1233
		) -- 1233
	end) -- 1233
end -- 1226
local function maybeCompressHistory(shared) -- 1236
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1236
		local ____shared_13 = shared -- 1237
		local memory = ____shared_13.memory -- 1237
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1238
		local changed = false -- 1239
		do -- 1239
			local round = 0 -- 1240
			while round < maxRounds do -- 1240
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1241
				local activeMessages = getActiveConversationMessages(shared) -- 1242
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1246
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1246
					if changed then -- 1246
						persistHistoryState(shared) -- 1255
					end -- 1255
					return ____awaiter_resolve(nil) -- 1255
				end -- 1255
				local compressionRound = round + 1 -- 1259
				shared.step = shared.step + 1 -- 1260
				local stepId = shared.step -- 1261
				local pendingMessages = #activeMessages -- 1262
				emitAgentEvent( -- 1263
					shared, -- 1263
					{ -- 1263
						type = "memory_compression_started", -- 1264
						sessionId = shared.sessionId, -- 1265
						taskId = shared.taskId, -- 1266
						step = stepId, -- 1267
						tool = "compress_memory", -- 1268
						reason = getMemoryCompressionStartReason(shared), -- 1269
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1270
					} -- 1270
				) -- 1270
				local result = __TS__Await(memory.compressor:compress( -- 1276
					activeMessages, -- 1277
					shared.llmOptions, -- 1278
					shared.llmMaxTry, -- 1279
					shared.decisionMode, -- 1280
					{ -- 1281
						onInput = function(____, phase, messages, options) -- 1282
							saveStepLLMDebugInput( -- 1283
								shared, -- 1283
								stepId, -- 1283
								phase, -- 1283
								messages, -- 1283
								options -- 1283
							) -- 1283
						end, -- 1282
						onOutput = function(____, phase, text, meta) -- 1285
							saveStepLLMDebugOutput( -- 1286
								shared, -- 1286
								stepId, -- 1286
								phase, -- 1286
								text, -- 1286
								meta -- 1286
							) -- 1286
						end -- 1285
					}, -- 1285
					"default", -- 1289
					systemPrompt, -- 1290
					toolDefinitions -- 1291
				)) -- 1291
				if not (result and result.success and result.compressedCount > 0) then -- 1291
					emitAgentEvent( -- 1294
						shared, -- 1294
						{ -- 1294
							type = "memory_compression_finished", -- 1295
							sessionId = shared.sessionId, -- 1296
							taskId = shared.taskId, -- 1297
							step = stepId, -- 1298
							tool = "compress_memory", -- 1299
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1300
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1304
						} -- 1304
					) -- 1304
					if changed then -- 1304
						persistHistoryState(shared) -- 1312
					end -- 1312
					return ____awaiter_resolve(nil) -- 1312
				end -- 1312
				local effectiveCompressedCount = math.max( -- 1316
					0, -- 1317
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1318
				) -- 1318
				if effectiveCompressedCount <= 0 then -- 1318
					if changed then -- 1318
						persistHistoryState(shared) -- 1322
					end -- 1322
					return ____awaiter_resolve(nil) -- 1322
				end -- 1322
				emitAgentEvent( -- 1326
					shared, -- 1326
					{ -- 1326
						type = "memory_compression_finished", -- 1327
						sessionId = shared.sessionId, -- 1328
						taskId = shared.taskId, -- 1329
						step = stepId, -- 1330
						tool = "compress_memory", -- 1331
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1332
						result = { -- 1333
							success = true, -- 1334
							round = compressionRound, -- 1335
							compressedCount = effectiveCompressedCount, -- 1336
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1337
						} -- 1337
					} -- 1337
				) -- 1337
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1340
				changed = true -- 1341
				Log( -- 1342
					"Info", -- 1342
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1342
				) -- 1342
				round = round + 1 -- 1240
			end -- 1240
		end -- 1240
		if changed then -- 1240
			persistHistoryState(shared) -- 1345
		end -- 1345
	end) -- 1345
end -- 1236
local function compactAllHistory(shared) -- 1349
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1349
		local ____shared_20 = shared -- 1350
		local memory = ____shared_20.memory -- 1350
		local rounds = 0 -- 1351
		local totalCompressed = 0 -- 1352
		while getActiveRealMessageCount(shared) > 0 do -- 1352
			if shared.stopToken.stopped then -- 1352
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1355
				return ____awaiter_resolve( -- 1355
					nil, -- 1355
					emitAgentTaskFinishEvent( -- 1356
						shared, -- 1356
						false, -- 1356
						getCancelledReason(shared) -- 1356
					) -- 1356
				) -- 1356
			end -- 1356
			rounds = rounds + 1 -- 1358
			shared.step = shared.step + 1 -- 1359
			local stepId = shared.step -- 1360
			local activeMessages = getActiveConversationMessages(shared) -- 1361
			local pendingMessages = #activeMessages -- 1362
			emitAgentEvent( -- 1363
				shared, -- 1363
				{ -- 1363
					type = "memory_compression_started", -- 1364
					sessionId = shared.sessionId, -- 1365
					taskId = shared.taskId, -- 1366
					step = stepId, -- 1367
					tool = "compress_memory", -- 1368
					reason = getMemoryCompressionStartReason(shared), -- 1369
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1370
				} -- 1370
			) -- 1370
			local result = __TS__Await(memory.compressor:compress( -- 1377
				activeMessages, -- 1378
				shared.llmOptions, -- 1379
				shared.llmMaxTry, -- 1380
				shared.decisionMode, -- 1381
				{ -- 1382
					onInput = function(____, phase, messages, options) -- 1383
						saveStepLLMDebugInput( -- 1384
							shared, -- 1384
							stepId, -- 1384
							phase, -- 1384
							messages, -- 1384
							options -- 1384
						) -- 1384
					end, -- 1383
					onOutput = function(____, phase, text, meta) -- 1386
						saveStepLLMDebugOutput( -- 1387
							shared, -- 1387
							stepId, -- 1387
							phase, -- 1387
							text, -- 1387
							meta -- 1387
						) -- 1387
					end -- 1386
				}, -- 1386
				"budget_max" -- 1390
			)) -- 1390
			if not (result and result.success and result.compressedCount > 0) then -- 1390
				emitAgentEvent( -- 1393
					shared, -- 1393
					{ -- 1393
						type = "memory_compression_finished", -- 1394
						sessionId = shared.sessionId, -- 1395
						taskId = shared.taskId, -- 1396
						step = stepId, -- 1397
						tool = "compress_memory", -- 1398
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1399
						result = { -- 1403
							success = false, -- 1404
							rounds = rounds, -- 1405
							error = result and result.error or "compression returned no changes", -- 1406
							compressedCount = result and result.compressedCount or 0, -- 1407
							fullCompaction = true -- 1408
						} -- 1408
					} -- 1408
				) -- 1408
				return ____awaiter_resolve( -- 1408
					nil, -- 1408
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1411
				) -- 1411
			end -- 1411
			local effectiveCompressedCount = math.max( -- 1416
				0, -- 1417
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1418
			) -- 1418
			if effectiveCompressedCount <= 0 then -- 1418
				return ____awaiter_resolve( -- 1418
					nil, -- 1418
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1421
				) -- 1421
			end -- 1421
			emitAgentEvent( -- 1428
				shared, -- 1428
				{ -- 1428
					type = "memory_compression_finished", -- 1429
					sessionId = shared.sessionId, -- 1430
					taskId = shared.taskId, -- 1431
					step = stepId, -- 1432
					tool = "compress_memory", -- 1433
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1434
					result = { -- 1435
						success = true, -- 1436
						round = rounds, -- 1437
						compressedCount = effectiveCompressedCount, -- 1438
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1439
						fullCompaction = true -- 1440
					} -- 1440
				} -- 1440
			) -- 1440
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1443
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1444
			persistHistoryState(shared) -- 1445
			Log( -- 1446
				"Info", -- 1446
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1446
			) -- 1446
		end -- 1446
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1448
		return ____awaiter_resolve( -- 1448
			nil, -- 1448
			emitAgentTaskFinishEvent( -- 1449
				shared, -- 1450
				true, -- 1451
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1452
			) -- 1452
		) -- 1452
	end) -- 1452
end -- 1349
local function clearSessionHistory(shared) -- 1458
	shared.messages = {} -- 1459
	shared.lastConsolidatedIndex = 0 -- 1460
	shared.carryMessageIndex = nil -- 1461
	persistHistoryState(shared) -- 1462
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1463
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1464
end -- 1458
local function isKnownToolName(name) -- 1473
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1474
end -- 1473
local function appendConversationMessage(shared, message) -- 1567
	local ____shared_messages_29 = shared.messages -- 1567
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1568
		{}, -- 1568
		message, -- 1569
		{ -- 1568
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1570
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1571
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1572
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1573
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1574
		} -- 1574
	) -- 1574
end -- 1567
local function ensureToolCallId(toolCallId) -- 1578
	if toolCallId and toolCallId ~= "" then -- 1578
		return toolCallId -- 1579
	end -- 1579
	return createLocalToolCallId() -- 1580
end -- 1578
local function appendToolResultMessage(shared, action) -- 1583
	appendConversationMessage( -- 1584
		shared, -- 1584
		{ -- 1584
			role = "tool", -- 1585
			tool_call_id = action.toolCallId, -- 1586
			name = action.tool, -- 1587
			content = action.result and toJson(action.result) or "" -- 1588
		} -- 1588
	) -- 1588
end -- 1583
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1592
	appendConversationMessage( -- 1598
		shared, -- 1598
		{ -- 1598
			role = "assistant", -- 1599
			content = content or "", -- 1600
			reasoning_content = reasoningContent, -- 1601
			tool_calls = __TS__ArrayMap( -- 1602
				actions, -- 1602
				function(____, action) return { -- 1602
					id = action.toolCallId, -- 1603
					type = "function", -- 1604
					["function"] = { -- 1605
						name = action.tool, -- 1606
						arguments = toJson(action.params) -- 1607
					} -- 1607
				} end -- 1607
			) -- 1607
		} -- 1607
	) -- 1607
end -- 1592
local function parseXMLToolCallObjectFromText(text) -- 1613
	local children = parseXMLObjectFromText(text, "tool_call") -- 1614
	if not children.success then -- 1614
		return children -- 1615
	end -- 1615
	local rawObj = children.obj -- 1616
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1617
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1618
	if not params.success then -- 1618
		return {success = false, message = params.message} -- 1622
	end -- 1622
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1624
end -- 1613
local function llm(shared, messages, phase) -- 1644
	if phase == nil then -- 1644
		phase = "decision_xml" -- 1647
	end -- 1647
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1647
		local stepId = shared.step + 1 -- 1649
		saveStepLLMDebugInput( -- 1650
			shared, -- 1650
			stepId, -- 1650
			phase, -- 1650
			messages, -- 1650
			shared.llmOptions -- 1650
		) -- 1650
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1651
		if res.success then -- 1651
			local ____opt_32 = res.response.choices -- 1651
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1651
			local message = ____opt_30 and ____opt_30.message -- 1653
			local text = message and message.content -- 1654
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1655
			if text then -- 1655
				saveStepLLMDebugOutput( -- 1659
					shared, -- 1659
					stepId, -- 1659
					phase, -- 1659
					text, -- 1659
					{success = true} -- 1659
				) -- 1659
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1659
			else -- 1659
				saveStepLLMDebugOutput( -- 1662
					shared, -- 1662
					stepId, -- 1662
					phase, -- 1662
					"empty LLM response", -- 1662
					{success = false} -- 1662
				) -- 1662
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1662
			end -- 1662
		else -- 1662
			saveStepLLMDebugOutput( -- 1666
				shared, -- 1666
				stepId, -- 1666
				phase, -- 1666
				res.raw or res.message, -- 1666
				{success = false} -- 1666
			) -- 1666
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1666
		end -- 1666
	end) -- 1666
end -- 1644
local function isDecisionBatchSuccess(result) -- 1690
	return result.kind == "batch" -- 1691
end -- 1690
local function parseDecisionObject(rawObj) -- 1694
	if type(rawObj.tool) ~= "string" then -- 1694
		return {success = false, message = "missing tool"} -- 1695
	end -- 1695
	local tool = rawObj.tool -- 1696
	if not isKnownToolName(tool) then -- 1696
		return {success = false, message = "unknown tool: " .. tool} -- 1698
	end -- 1698
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1700
	if tool ~= "finish" and (not reason or reason == "") then -- 1700
		return {success = false, message = tool .. " requires top-level reason"} -- 1704
	end -- 1704
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1706
	return {success = true, tool = tool, params = params, reason = reason} -- 1707
end -- 1694
local function parseDecisionToolCall(functionName, rawObj) -- 1715
	if not isKnownToolName(functionName) then -- 1715
		return {success = false, message = "unknown tool: " .. functionName} -- 1717
	end -- 1717
	if rawObj == nil or rawObj == nil then -- 1717
		return {success = true, tool = functionName, params = {}} -- 1720
	end -- 1720
	if not isRecord(rawObj) then -- 1720
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1723
	end -- 1723
	return {success = true, tool = functionName, params = rawObj} -- 1725
end -- 1715
local function parseToolCallArguments(functionName, argsText) -- 1732
	if __TS__StringTrim(argsText) == "" then -- 1732
		return {} -- 1734
	end -- 1734
	local rawObj, err = safeJsonDecode(argsText) -- 1736
	if err ~= nil or rawObj == nil then -- 1736
		return { -- 1738
			success = false, -- 1739
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1740
			raw = argsText -- 1741
		} -- 1741
	end -- 1741
	local encodedRaw = safeJsonEncode(rawObj) -- 1744
	if encodedRaw == "null" or not isRecord(rawObj) or isArray(rawObj) then -- 1744
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1746
	end -- 1746
	return rawObj -- 1752
end -- 1732
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1755
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1763
	if isRecord(rawArgs) and rawArgs.success == false then -- 1763
		return rawArgs -- 1765
	end -- 1765
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1767
	if not decision.success then -- 1767
		return {success = false, message = decision.message, raw = argsText} -- 1769
	end -- 1769
	local validation = validateDecision(decision.tool, decision.params) -- 1775
	if not validation.success then -- 1775
		return {success = false, message = validation.message, raw = argsText} -- 1777
	end -- 1777
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1777
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1784
	end -- 1784
	decision.params = validation.params -- 1790
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1791
	decision.reason = reason -- 1792
	decision.reasoningContent = reasoningContent -- 1793
	return decision -- 1794
end -- 1755
local function createPreExecutableActionFromStream(shared, toolCall) -- 1797
	local ____opt_38 = toolCall["function"] -- 1797
	local functionName = ____opt_38 and ____opt_38.name -- 1798
	local ____opt_40 = toolCall["function"] -- 1798
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1799
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1800
	if not functionName or not toolCallId then -- 1800
		return nil -- 1801
	end -- 1801
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1802
	if isRecord(rawArgs) and rawArgs.success == false then -- 1802
		return nil -- 1803
	end -- 1803
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1804
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1804
		return nil -- 1805
	end -- 1805
	local validation = validateDecision(decision.tool, decision.params) -- 1806
	if not validation.success then -- 1806
		return nil -- 1807
	end -- 1807
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1807
		return nil -- 1808
	end -- 1808
	return { -- 1809
		step = shared.step + 1, -- 1810
		toolCallId = toolCallId, -- 1811
		tool = decision.tool, -- 1812
		reason = "", -- 1813
		params = validation.params, -- 1814
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1815
	} -- 1815
end -- 1797
local function createFunctionToolSchema(name, description, properties, required) -- 1955
	if required == nil then -- 1955
		required = {} -- 1959
	end -- 1959
	local parameters = {type = "object", properties = properties} -- 1961
	if #required > 0 then -- 1961
		parameters.required = required -- 1966
	end -- 1966
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1968
end -- 1955
local function buildDecisionToolSchema(shared) -- 1984
	local allowed = getAllowedToolsForRole(shared.role) -- 1985
	local tools = { -- 1986
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1987
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1997
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2007
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2015
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2019
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2020
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2021
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2022
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2023
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2024
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2025
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2026
		}, {"pattern"}), -- 2026
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2030
		createFunctionToolSchema( -- 2039
			"search_dora_api", -- 2040
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2040
			{ -- 2042
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2043
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2044
				programmingLanguage = {type = "string", enum = { -- 2045
					"ts", -- 2047
					"tsx", -- 2047
					"lua", -- 2047
					"yue", -- 2047
					"teal", -- 2047
					"tl", -- 2047
					"wa" -- 2047
				}, description = "Preferred language variant to search."}, -- 2047
				limit = { -- 2050
					type = "number", -- 2050
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2050
				}, -- 2050
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2051
			}, -- 2051
			{"pattern"} -- 2053
		), -- 2053
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2055
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2062
			"active_or_recent", -- 2066
			"running", -- 2066
			"done", -- 2066
			"failed", -- 2066
			"all" -- 2066
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2066
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2072
	} -- 2072
	return __TS__ArrayFilter( -- 2084
		tools, -- 2084
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2084
	) -- 2084
end -- 1984
local function sanitizeMessagesForLLMInput(messages) -- 2125
	local sanitized = {} -- 2126
	local droppedAssistantToolCalls = 0 -- 2127
	local droppedToolResults = 0 -- 2128
	do -- 2128
		local i = 0 -- 2129
		while i < #messages do -- 2129
			do -- 2129
				local message = messages[i + 1] -- 2130
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2130
					local requiredIds = {} -- 2132
					do -- 2132
						local j = 0 -- 2133
						while j < #message.tool_calls do -- 2133
							local toolCall = message.tool_calls[j + 1] -- 2134
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2135
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2135
								requiredIds[#requiredIds + 1] = id -- 2137
							end -- 2137
							j = j + 1 -- 2133
						end -- 2133
					end -- 2133
					if #requiredIds == 0 then -- 2133
						sanitized[#sanitized + 1] = message -- 2141
						goto __continue335 -- 2142
					end -- 2142
					local matchedIds = {} -- 2144
					local matchedTools = {} -- 2145
					local j = i + 1 -- 2146
					while j < #messages do -- 2146
						local toolMessage = messages[j + 1] -- 2148
						if toolMessage.role ~= "tool" then -- 2148
							break -- 2149
						end -- 2149
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2150
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2150
							matchedIds[toolCallId] = true -- 2152
							matchedTools[#matchedTools + 1] = toolMessage -- 2153
						else -- 2153
							droppedToolResults = droppedToolResults + 1 -- 2155
						end -- 2155
						j = j + 1 -- 2157
					end -- 2157
					local complete = true -- 2159
					do -- 2159
						local j = 0 -- 2160
						while j < #requiredIds do -- 2160
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2160
								complete = false -- 2162
								break -- 2163
							end -- 2163
							j = j + 1 -- 2160
						end -- 2160
					end -- 2160
					if complete then -- 2160
						__TS__ArrayPush( -- 2167
							sanitized, -- 2167
							message, -- 2167
							table.unpack(matchedTools) -- 2167
						) -- 2167
					else -- 2167
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2169
						droppedToolResults = droppedToolResults + #matchedTools -- 2170
					end -- 2170
					i = j - 1 -- 2172
					goto __continue335 -- 2173
				end -- 2173
				if message.role == "tool" then -- 2173
					droppedToolResults = droppedToolResults + 1 -- 2176
					goto __continue335 -- 2177
				end -- 2177
				sanitized[#sanitized + 1] = message -- 2179
			end -- 2179
			::__continue335:: -- 2179
			i = i + 1 -- 2129
		end -- 2129
	end -- 2129
	return sanitized -- 2181
end -- 2125
local function getUnconsolidatedMessages(shared) -- 2184
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2185
end -- 2184
local function getFinalDecisionTurnPrompt(shared) -- 2188
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2189
end -- 2188
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2194
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2194
		return messages -- 2195
	end -- 2195
	local next = __TS__ArrayMap( -- 2196
		messages, -- 2196
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2196
	) -- 2196
	do -- 2196
		local i = #next - 1 -- 2197
		while i >= 0 do -- 2197
			do -- 2197
				local message = next[i + 1] -- 2198
				if message.role ~= "assistant" and message.role ~= "user" then -- 2198
					goto __continue357 -- 2199
				end -- 2199
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2200
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2201
				return next -- 2204
			end -- 2204
			::__continue357:: -- 2204
			i = i - 1 -- 2197
		end -- 2197
	end -- 2197
	next[#next + 1] = {role = "user", content = prompt} -- 2206
	return next -- 2207
end -- 2194
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2210
	if attempt == nil then -- 2210
		attempt = 1 -- 2210
	end -- 2210
	local messages = { -- 2211
		{ -- 2212
			role = "system", -- 2212
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 2212
		}, -- 2212
		table.unpack(getUnconsolidatedMessages(shared)) -- 2213
	} -- 2213
	if shared.step + 1 >= shared.maxSteps then -- 2213
		messages = appendPromptToLatestDecisionMessage( -- 2216
			messages, -- 2216
			getFinalDecisionTurnPrompt(shared) -- 2216
		) -- 2216
	end -- 2216
	if lastError and lastError ~= "" then -- 2216
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2219
		messages[#messages + 1] = { -- 2222
			role = "user", -- 2223
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2224
		} -- 2224
	end -- 2224
	return messages -- 2231
end -- 2210
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2238
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2245
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2246
	local repairPrompt = replacePromptVars( -- 2254
		shared.promptPack.xmlDecisionRepairPrompt, -- 2254
		{ -- 2254
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2255
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2256
			CANDIDATE_SECTION = candidateSection, -- 2257
			LAST_ERROR = lastError, -- 2258
			ATTEMPT = tostring(attempt) -- 2259
		} -- 2259
	) -- 2259
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2261
end -- 2238
local function tryParseAndValidateDecision(rawText) -- 2273
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2274
	if not parsed.success then -- 2274
		return {success = false, message = parsed.message, raw = rawText} -- 2276
	end -- 2276
	local decision = parseDecisionObject(parsed.obj) -- 2278
	if not decision.success then -- 2278
		return {success = false, message = decision.message, raw = rawText} -- 2280
	end -- 2280
	local validation = validateDecision(decision.tool, decision.params) -- 2282
	if not validation.success then -- 2282
		return {success = false, message = validation.message, raw = rawText} -- 2284
	end -- 2284
	decision.params = validation.params -- 2286
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2287
	return decision -- 2288
end -- 2273
local function normalizeLineEndings(text) -- 2291
	local res = string.gsub(text, "\r\n", "\n") -- 2292
	res = string.gsub(res, "\r", "\n") -- 2293
	return res -- 2294
end -- 2291
local function countOccurrences(text, searchStr) -- 2297
	if searchStr == "" then -- 2297
		return 0 -- 2298
	end -- 2298
	local count = 0 -- 2299
	local pos = 0 -- 2300
	while true do -- 2300
		local idx = (string.find( -- 2302
			text, -- 2302
			searchStr, -- 2302
			math.max(pos + 1, 1), -- 2302
			true -- 2302
		) or 0) - 1 -- 2302
		if idx < 0 then -- 2302
			break -- 2303
		end -- 2303
		count = count + 1 -- 2304
		pos = idx + #searchStr -- 2305
	end -- 2305
	return count -- 2307
end -- 2297
local function replaceFirst(text, oldStr, newStr) -- 2310
	if oldStr == "" then -- 2310
		return text -- 2311
	end -- 2311
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2312
	if idx < 0 then -- 2312
		return text -- 2313
	end -- 2313
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2314
end -- 2310
local function splitLines(text) -- 2317
	return __TS__StringSplit(text, "\n") -- 2318
end -- 2317
local function getLeadingWhitespace(text) -- 2321
	local i = 0 -- 2322
	while i < #text do -- 2322
		local ch = __TS__StringAccess(text, i) -- 2324
		if ch ~= " " and ch ~= "\t" then -- 2324
			break -- 2325
		end -- 2325
		i = i + 1 -- 2326
	end -- 2326
	return __TS__StringSubstring(text, 0, i) -- 2328
end -- 2321
local function getCommonIndentPrefix(lines) -- 2331
	local common -- 2332
	do -- 2332
		local i = 0 -- 2333
		while i < #lines do -- 2333
			do -- 2333
				local line = lines[i + 1] -- 2334
				if __TS__StringTrim(line) == "" then -- 2334
					goto __continue382 -- 2335
				end -- 2335
				local indent = getLeadingWhitespace(line) -- 2336
				if common == nil then -- 2336
					common = indent -- 2338
					goto __continue382 -- 2339
				end -- 2339
				local j = 0 -- 2341
				local maxLen = math.min(#common, #indent) -- 2342
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2342
					j = j + 1 -- 2344
				end -- 2344
				common = __TS__StringSubstring(common, 0, j) -- 2346
				if common == "" then -- 2346
					break -- 2347
				end -- 2347
			end -- 2347
			::__continue382:: -- 2347
			i = i + 1 -- 2333
		end -- 2333
	end -- 2333
	return common or "" -- 2349
end -- 2331
local function removeIndentPrefix(line, indent) -- 2352
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2352
		return __TS__StringSubstring(line, #indent) -- 2354
	end -- 2354
	local lineIndent = getLeadingWhitespace(line) -- 2356
	local j = 0 -- 2357
	local maxLen = math.min(#lineIndent, #indent) -- 2358
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2358
		j = j + 1 -- 2360
	end -- 2360
	return __TS__StringSubstring(line, j) -- 2362
end -- 2352
local function dedentLines(lines) -- 2365
	local indent = getCommonIndentPrefix(lines) -- 2366
	return { -- 2367
		indent = indent, -- 2368
		lines = __TS__ArrayMap( -- 2369
			lines, -- 2369
			function(____, line) return removeIndentPrefix(line, indent) end -- 2369
		) -- 2369
	} -- 2369
end -- 2365
local function joinLines(lines) -- 2373
	return table.concat(lines, "\n") -- 2374
end -- 2373
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2377
	local contentLines = splitLines(content) -- 2382
	local oldLines = splitLines(oldStr) -- 2383
	if #oldLines == 0 then -- 2383
		return {success = false, message = "old_str not found in file"} -- 2385
	end -- 2385
	local dedentedOld = dedentLines(oldLines) -- 2387
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2388
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2389
	local matches = {} -- 2390
	do -- 2390
		local start = 0 -- 2391
		while start <= #contentLines - #oldLines do -- 2391
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2392
			local dedentedCandidate = dedentLines(candidateLines) -- 2393
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2393
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2395
			end -- 2395
			start = start + 1 -- 2391
		end -- 2391
	end -- 2391
	if #matches == 0 then -- 2391
		return {success = false, message = "old_str not found in file"} -- 2403
	end -- 2403
	if #matches > 1 then -- 2403
		return { -- 2406
			success = false, -- 2407
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2408
		} -- 2408
	end -- 2408
	local match = matches[1] -- 2411
	local rebuiltNewLines = __TS__ArrayMap( -- 2412
		dedentedNew.lines, -- 2412
		function(____, line) return line == "" and "" or match.indent .. line end -- 2412
	) -- 2412
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2412
	__TS__SparseArrayPush( -- 2412
		____array_46, -- 2412
		table.unpack(rebuiltNewLines) -- 2415
	) -- 2415
	__TS__SparseArrayPush( -- 2415
		____array_46, -- 2415
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2416
	) -- 2416
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2413
	return { -- 2418
		success = true, -- 2418
		content = joinLines(nextLines) -- 2418
	} -- 2418
end -- 2377
local MainDecisionAgent = __TS__Class() -- 2421
MainDecisionAgent.name = "MainDecisionAgent" -- 2421
__TS__ClassExtends(MainDecisionAgent, Node) -- 2421
function MainDecisionAgent.prototype.prep(self, shared) -- 2422
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2422
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2422
			return ____awaiter_resolve(nil, {shared = shared}) -- 2422
		end -- 2422
		__TS__Await(maybeCompressHistory(shared)) -- 2427
		return ____awaiter_resolve(nil, {shared = shared}) -- 2427
	end) -- 2427
end -- 2422
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2432
	if attempt == nil then -- 2432
		attempt = 1 -- 2435
	end -- 2435
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2435
		if shared.stopToken.stopped then -- 2435
			return ____awaiter_resolve( -- 2435
				nil, -- 2435
				{ -- 2439
					success = false, -- 2439
					message = getCancelledReason(shared) -- 2439
				} -- 2439
			) -- 2439
		end -- 2439
		Log( -- 2441
			"Info", -- 2441
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2441
		) -- 2441
		local tools = buildDecisionToolSchema(shared) -- 2442
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2443
		local stepId = shared.step + 1 -- 2444
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2445
		saveStepLLMDebugInput( -- 2449
			shared, -- 2449
			stepId, -- 2449
			"decision_tool_calling", -- 2449
			messages, -- 2449
			llmOptions -- 2449
		) -- 2449
		local lastStreamContent = "" -- 2450
		local lastStreamReasoning = "" -- 2451
		local preExecutedResults = __TS__New(Map) -- 2452
		shared.preExecutedResults = preExecutedResults -- 2453
		local res = __TS__Await(callLLMStreamAggregated( -- 2454
			messages, -- 2455
			llmOptions, -- 2456
			shared.stopToken, -- 2457
			shared.llmConfig, -- 2458
			function(response) -- 2459
				local ____opt_49 = response.choices -- 2459
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2459
				local streamMessage = ____opt_47 and ____opt_47.message -- 2460
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2461
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2464
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2464
					return -- 2468
				end -- 2468
				lastStreamContent = nextContent -- 2470
				lastStreamReasoning = nextReasoning -- 2471
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2472
			end, -- 2459
			function(tc) -- 2474
				if shared.stopToken.stopped then -- 2474
					return -- 2475
				end -- 2475
				local action = createPreExecutableActionFromStream(shared, tc) -- 2476
				if not action or preExecutedResults:has(action.toolCallId) then -- 2476
					return -- 2477
				end -- 2477
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2478
				preExecutedResults:set( -- 2479
					action.toolCallId, -- 2479
					startPreExecutedToolAction(shared, action) -- 2479
				) -- 2479
			end -- 2474
		)) -- 2474
		if shared.stopToken.stopped then -- 2474
			clearPreExecutedResults(shared) -- 2483
			return ____awaiter_resolve( -- 2483
				nil, -- 2483
				{ -- 2484
					success = false, -- 2484
					message = getCancelledReason(shared) -- 2484
				} -- 2484
			) -- 2484
		end -- 2484
		if not res.success then -- 2484
			saveStepLLMDebugOutput( -- 2487
				shared, -- 2487
				stepId, -- 2487
				"decision_tool_calling", -- 2487
				res.raw or res.message, -- 2487
				{success = false} -- 2487
			) -- 2487
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2488
			clearPreExecutedResults(shared) -- 2489
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2489
		end -- 2489
		saveStepLLMDebugOutput( -- 2492
			shared, -- 2492
			stepId, -- 2492
			"decision_tool_calling", -- 2492
			encodeDebugJSON(res.response), -- 2492
			{success = true} -- 2492
		) -- 2492
		local choice = res.response.choices and res.response.choices[1] -- 2493
		local message = choice and choice.message -- 2494
		local toolCalls = message and message.tool_calls -- 2495
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2496
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2499
		Log( -- 2502
			"Info", -- 2502
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2502
		) -- 2502
		if not toolCalls or #toolCalls == 0 then -- 2502
			if messageContent and messageContent ~= "" then -- 2502
				Log( -- 2505
					"Info", -- 2505
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2505
				) -- 2505
				clearPreExecutedResults(shared) -- 2506
				return ____awaiter_resolve(nil, { -- 2506
					success = true, -- 2508
					tool = "finish", -- 2509
					params = {}, -- 2510
					reason = messageContent, -- 2511
					reasoningContent = reasoningContent, -- 2512
					directSummary = messageContent -- 2513
				}) -- 2513
			end -- 2513
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2516
			clearPreExecutedResults(shared) -- 2517
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2517
		end -- 2517
		local decisions = {} -- 2524
		do -- 2524
			local i = 0 -- 2525
			while i < #toolCalls do -- 2525
				local toolCall = toolCalls[i + 1] -- 2526
				local fn = toolCall and toolCall["function"] -- 2527
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2527
					Log( -- 2529
						"Error", -- 2529
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2529
					) -- 2529
					clearPreExecutedResults(shared) -- 2530
					return ____awaiter_resolve( -- 2530
						nil, -- 2530
						{ -- 2531
							success = false, -- 2532
							message = "missing function name for tool call " .. tostring(i + 1), -- 2533
							raw = messageContent -- 2534
						} -- 2534
					) -- 2534
				end -- 2534
				local functionName = fn.name -- 2537
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2538
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2539
				Log( -- 2542
					"Info", -- 2542
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2542
				) -- 2542
				local decision = parseAndValidateToolCallDecision( -- 2543
					shared, -- 2544
					functionName, -- 2545
					argsText, -- 2546
					toolCallId, -- 2547
					messageContent, -- 2548
					reasoningContent -- 2549
				) -- 2549
				if not decision.success then -- 2549
					Log( -- 2552
						"Error", -- 2552
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2552
					) -- 2552
					clearPreExecutedResults(shared) -- 2553
					return ____awaiter_resolve(nil, decision) -- 2553
				end -- 2553
				decisions[#decisions + 1] = decision -- 2556
				i = i + 1 -- 2525
			end -- 2525
		end -- 2525
		if #decisions == 1 then -- 2525
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2559
			return ____awaiter_resolve(nil, decisions[1]) -- 2559
		end -- 2559
		do -- 2559
			local i = 0 -- 2562
			while i < #decisions do -- 2562
				if decisions[i + 1].tool == "finish" then -- 2562
					clearPreExecutedResults(shared) -- 2564
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2564
				end -- 2564
				i = i + 1 -- 2562
			end -- 2562
		end -- 2562
		Log( -- 2572
			"Info", -- 2572
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2572
				__TS__ArrayMap( -- 2572
					decisions, -- 2572
					function(____, decision) return decision.tool end -- 2572
				), -- 2572
				"," -- 2572
			) -- 2572
		) -- 2572
		return ____awaiter_resolve(nil, { -- 2572
			success = true, -- 2574
			kind = "batch", -- 2575
			decisions = decisions, -- 2576
			content = messageContent, -- 2577
			reasoningContent = reasoningContent -- 2578
		}) -- 2578
	end) -- 2578
end -- 2432
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2582
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2582
		Log( -- 2587
			"Info", -- 2587
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2587
		) -- 2587
		local lastError = initialError -- 2588
		local candidateRaw = "" -- 2589
		do -- 2589
			local attempt = 0 -- 2590
			while attempt < shared.llmMaxTry do -- 2590
				do -- 2590
					Log( -- 2591
						"Info", -- 2591
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2591
					) -- 2591
					local messages = buildXmlRepairMessages( -- 2592
						shared, -- 2593
						originalRaw, -- 2594
						candidateRaw, -- 2595
						lastError, -- 2596
						attempt + 1 -- 2597
					) -- 2597
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2599
					if shared.stopToken.stopped then -- 2599
						return ____awaiter_resolve( -- 2599
							nil, -- 2599
							{ -- 2601
								success = false, -- 2601
								message = getCancelledReason(shared) -- 2601
							} -- 2601
						) -- 2601
					end -- 2601
					if not llmRes.success then -- 2601
						lastError = llmRes.message -- 2604
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2605
						goto __continue425 -- 2606
					end -- 2606
					candidateRaw = llmRes.text -- 2608
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2609
					if decision.success then -- 2609
						decision.reasoningContent = llmRes.reasoningContent -- 2611
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2612
						return ____awaiter_resolve(nil, decision) -- 2612
					end -- 2612
					lastError = decision.message -- 2615
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2616
				end -- 2616
				::__continue425:: -- 2616
				attempt = attempt + 1 -- 2590
			end -- 2590
		end -- 2590
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2618
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2618
	end) -- 2618
end -- 2582
function MainDecisionAgent.prototype.exec(self, input) -- 2626
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2626
		local shared = input.shared -- 2627
		if shared.stopToken.stopped then -- 2627
			return ____awaiter_resolve( -- 2627
				nil, -- 2627
				{ -- 2629
					success = false, -- 2629
					message = getCancelledReason(shared) -- 2629
				} -- 2629
			) -- 2629
		end -- 2629
		if shared.step >= shared.maxSteps then -- 2629
			Log( -- 2632
				"Warn", -- 2632
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2632
			) -- 2632
			return ____awaiter_resolve( -- 2632
				nil, -- 2632
				{ -- 2633
					success = false, -- 2633
					message = getMaxStepsReachedReason(shared) -- 2633
				} -- 2633
			) -- 2633
		end -- 2633
		if shared.decisionMode == "tool_calling" then -- 2633
			Log( -- 2637
				"Info", -- 2637
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2637
			) -- 2637
			local lastError = "tool calling validation failed" -- 2638
			local lastRaw = "" -- 2639
			do -- 2639
				local attempt = 0 -- 2640
				while attempt < shared.llmMaxTry do -- 2640
					Log( -- 2641
						"Info", -- 2641
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2641
					) -- 2641
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2642
					if shared.stopToken.stopped then -- 2642
						return ____awaiter_resolve( -- 2642
							nil, -- 2642
							{ -- 2649
								success = false, -- 2649
								message = getCancelledReason(shared) -- 2649
							} -- 2649
						) -- 2649
					end -- 2649
					if decision.success then -- 2649
						return ____awaiter_resolve(nil, decision) -- 2649
					end -- 2649
					lastError = decision.message -- 2654
					lastRaw = decision.raw or "" -- 2655
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2656
					attempt = attempt + 1 -- 2640
				end -- 2640
			end -- 2640
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2658
			return ____awaiter_resolve( -- 2658
				nil, -- 2658
				{ -- 2659
					success = false, -- 2659
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2659
				} -- 2659
			) -- 2659
		end -- 2659
		local lastError = "xml validation failed" -- 2662
		local lastRaw = "" -- 2663
		do -- 2663
			local attempt = 0 -- 2664
			while attempt < shared.llmMaxTry do -- 2664
				do -- 2664
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2665
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2673
					if shared.stopToken.stopped then -- 2673
						return ____awaiter_resolve( -- 2673
							nil, -- 2673
							{ -- 2675
								success = false, -- 2675
								message = getCancelledReason(shared) -- 2675
							} -- 2675
						) -- 2675
					end -- 2675
					if not llmRes.success then -- 2675
						lastError = llmRes.message -- 2678
						lastRaw = llmRes.text or "" -- 2679
						goto __continue438 -- 2680
					end -- 2680
					lastRaw = llmRes.text -- 2682
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2683
					if decision.success then -- 2683
						decision.reasoningContent = llmRes.reasoningContent -- 2685
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2685
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2687
							return ____awaiter_resolve( -- 2687
								nil, -- 2687
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2688
							) -- 2688
						end -- 2688
						return ____awaiter_resolve(nil, decision) -- 2688
					end -- 2688
					lastError = decision.message -- 2692
					return ____awaiter_resolve( -- 2692
						nil, -- 2692
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2693
					) -- 2693
				end -- 2693
				::__continue438:: -- 2693
				attempt = attempt + 1 -- 2664
			end -- 2664
		end -- 2664
		return ____awaiter_resolve( -- 2664
			nil, -- 2664
			{ -- 2695
				success = false, -- 2695
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2695
			} -- 2695
		) -- 2695
	end) -- 2695
end -- 2626
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2698
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2698
		local result = execRes -- 2699
		if not result.success then -- 2699
			if shared.stopToken.stopped then -- 2699
				shared.error = getCancelledReason(shared) -- 2702
				shared.done = true -- 2703
				return ____awaiter_resolve(nil, "done") -- 2703
			end -- 2703
			shared.error = result.message -- 2706
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2707
			shared.done = true -- 2708
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2709
			persistHistoryState(shared) -- 2713
			return ____awaiter_resolve(nil, "done") -- 2713
		end -- 2713
		if isDecisionBatchSuccess(result) then -- 2713
			local startStep = shared.step -- 2717
			local actions = {} -- 2718
			do -- 2718
				local i = 0 -- 2719
				while i < #result.decisions do -- 2719
					local decision = result.decisions[i + 1] -- 2720
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2721
					local step = startStep + i + 1 -- 2722
					local ____temp_55 -- 2723
					if i == 0 then -- 2723
						____temp_55 = decision.reason -- 2723
					else -- 2723
						____temp_55 = "" -- 2723
					end -- 2723
					local actionReason = ____temp_55 -- 2723
					local ____temp_56 -- 2724
					if i == 0 then -- 2724
						____temp_56 = decision.reasoningContent -- 2724
					else -- 2724
						____temp_56 = nil -- 2724
					end -- 2724
					local actionReasoningContent = ____temp_56 -- 2724
					emitAgentEvent(shared, { -- 2725
						type = "decision_made", -- 2726
						sessionId = shared.sessionId, -- 2727
						taskId = shared.taskId, -- 2728
						step = step, -- 2729
						tool = decision.tool, -- 2730
						reason = actionReason, -- 2731
						reasoningContent = actionReasoningContent, -- 2732
						params = decision.params -- 2733
					}) -- 2733
					local action = { -- 2735
						step = step, -- 2736
						toolCallId = toolCallId, -- 2737
						tool = decision.tool, -- 2738
						reason = actionReason or "", -- 2739
						reasoningContent = actionReasoningContent, -- 2740
						params = decision.params, -- 2741
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2742
					} -- 2742
					local ____shared_history_57 = shared.history -- 2742
					____shared_history_57[#____shared_history_57 + 1] = action -- 2744
					actions[#actions + 1] = action -- 2745
					i = i + 1 -- 2719
				end -- 2719
			end -- 2719
			shared.step = startStep + #actions -- 2747
			shared.pendingToolActions = actions -- 2748
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2749
			persistHistoryState(shared) -- 2755
			return ____awaiter_resolve(nil, "batch_tools") -- 2755
		end -- 2755
		if result.directSummary and result.directSummary ~= "" then -- 2755
			shared.response = result.directSummary -- 2759
			shared.done = true -- 2760
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2761
			persistHistoryState(shared) -- 2766
			return ____awaiter_resolve(nil, "done") -- 2766
		end -- 2766
		if result.tool == "finish" then -- 2766
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2770
			shared.response = finalMessage -- 2771
			shared.done = true -- 2772
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2773
			persistHistoryState(shared) -- 2778
			return ____awaiter_resolve(nil, "done") -- 2778
		end -- 2778
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2781
		shared.step = shared.step + 1 -- 2782
		local step = shared.step -- 2783
		emitAgentEvent(shared, { -- 2784
			type = "decision_made", -- 2785
			sessionId = shared.sessionId, -- 2786
			taskId = shared.taskId, -- 2787
			step = step, -- 2788
			tool = result.tool, -- 2789
			reason = result.reason, -- 2790
			reasoningContent = result.reasoningContent, -- 2791
			params = result.params -- 2792
		}) -- 2792
		local ____shared_history_58 = shared.history -- 2792
		____shared_history_58[#____shared_history_58 + 1] = { -- 2794
			step = step, -- 2795
			toolCallId = toolCallId, -- 2796
			tool = result.tool, -- 2797
			reason = result.reason or "", -- 2798
			reasoningContent = result.reasoningContent, -- 2799
			params = result.params, -- 2800
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2801
		} -- 2801
		local action = shared.history[#shared.history] -- 2803
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2804
		if canPreExecuteTool(action.tool) then -- 2804
			shared.pendingToolActions = {action} -- 2806
			persistHistoryState(shared) -- 2807
			return ____awaiter_resolve(nil, "batch_tools") -- 2807
		end -- 2807
		clearPreExecutedResults(shared) -- 2810
		persistHistoryState(shared) -- 2811
		return ____awaiter_resolve(nil, result.tool) -- 2811
	end) -- 2811
end -- 2698
local ReadFileAction = __TS__Class() -- 2816
ReadFileAction.name = "ReadFileAction" -- 2816
__TS__ClassExtends(ReadFileAction, Node) -- 2816
function ReadFileAction.prototype.prep(self, shared) -- 2817
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2817
		local last = shared.history[#shared.history] -- 2818
		if not last then -- 2818
			error( -- 2819
				__TS__New(Error, "no history"), -- 2819
				0 -- 2819
			) -- 2819
		end -- 2819
		emitAgentStartEvent(shared, last) -- 2820
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2821
		if __TS__StringTrim(path) == "" then -- 2821
			error( -- 2824
				__TS__New(Error, "missing path"), -- 2824
				0 -- 2824
			) -- 2824
		end -- 2824
		local ____path_61 = path -- 2826
		local ____shared_workingDir_62 = shared.workingDir -- 2828
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2829
		local ____last_params_startLine_59 = last.params.startLine -- 2830
		if ____last_params_startLine_59 == nil then -- 2830
			____last_params_startLine_59 = 1 -- 2830
		end -- 2830
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2830
		local ____last_params_endLine_60 = last.params.endLine -- 2831
		if ____last_params_endLine_60 == nil then -- 2831
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2831
		end -- 2831
		return ____awaiter_resolve( -- 2831
			nil, -- 2831
			{ -- 2825
				path = ____path_61, -- 2826
				tool = "read_file", -- 2827
				workDir = ____shared_workingDir_62, -- 2828
				docLanguage = ____temp_63, -- 2829
				startLine = ____TS__Number_result_64, -- 2830
				endLine = __TS__Number(____last_params_endLine_60) -- 2831
			} -- 2831
		) -- 2831
	end) -- 2831
end -- 2817
function ReadFileAction.prototype.exec(self, input) -- 2835
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2835
		return ____awaiter_resolve( -- 2835
			nil, -- 2835
			Tools.readFile( -- 2836
				input.workDir, -- 2837
				input.path, -- 2838
				__TS__Number(input.startLine or 1), -- 2839
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2840
				input.docLanguage -- 2841
			) -- 2841
		) -- 2841
	end) -- 2841
end -- 2835
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2845
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2845
		local result = execRes -- 2846
		local last = shared.history[#shared.history] -- 2847
		if last ~= nil then -- 2847
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2849
			appendToolResultMessage(shared, last) -- 2850
			emitAgentFinishEvent(shared, last) -- 2851
		end -- 2851
		persistHistoryState(shared) -- 2853
		__TS__Await(maybeCompressHistory(shared)) -- 2854
		persistHistoryState(shared) -- 2855
		return ____awaiter_resolve(nil, "main") -- 2855
	end) -- 2855
end -- 2845
local SearchFilesAction = __TS__Class() -- 2860
SearchFilesAction.name = "SearchFilesAction" -- 2860
__TS__ClassExtends(SearchFilesAction, Node) -- 2860
function SearchFilesAction.prototype.prep(self, shared) -- 2861
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2861
		local last = shared.history[#shared.history] -- 2862
		if not last then -- 2862
			error( -- 2863
				__TS__New(Error, "no history"), -- 2863
				0 -- 2863
			) -- 2863
		end -- 2863
		emitAgentStartEvent(shared, last) -- 2864
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2864
	end) -- 2864
end -- 2861
function SearchFilesAction.prototype.exec(self, input) -- 2868
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2868
		local params = input.params -- 2869
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 2870
		local ____input_workDir_71 = input.workDir -- 2871
		local ____temp_72 = params.path or "" -- 2872
		local ____temp_73 = params.pattern or "" -- 2873
		local ____params_globs_74 = params.globs -- 2874
		local ____params_useRegex_75 = params.useRegex -- 2875
		local ____params_caseSensitive_76 = params.caseSensitive -- 2876
		local ____math_max_67 = math.max -- 2879
		local ____math_floor_66 = math.floor -- 2879
		local ____params_limit_65 = params.limit -- 2879
		if ____params_limit_65 == nil then -- 2879
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 2879
		end -- 2879
		local ____math_max_67_result_77 = ____math_max_67( -- 2879
			1, -- 2879
			____math_floor_66(__TS__Number(____params_limit_65)) -- 2879
		) -- 2879
		local ____math_max_70 = math.max -- 2880
		local ____math_floor_69 = math.floor -- 2880
		local ____params_offset_68 = params.offset -- 2880
		if ____params_offset_68 == nil then -- 2880
			____params_offset_68 = 0 -- 2880
		end -- 2880
		local result = __TS__Await(____Tools_searchFiles_78({ -- 2870
			workDir = ____input_workDir_71, -- 2871
			path = ____temp_72, -- 2872
			pattern = ____temp_73, -- 2873
			globs = ____params_globs_74, -- 2874
			useRegex = ____params_useRegex_75, -- 2875
			caseSensitive = ____params_caseSensitive_76, -- 2876
			includeContent = true, -- 2877
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2878
			limit = ____math_max_67_result_77, -- 2879
			offset = ____math_max_70( -- 2880
				0, -- 2880
				____math_floor_69(__TS__Number(____params_offset_68)) -- 2880
			), -- 2880
			groupByFile = params.groupByFile == true -- 2881
		})) -- 2881
		return ____awaiter_resolve(nil, result) -- 2881
	end) -- 2881
end -- 2868
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2886
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2886
		local last = shared.history[#shared.history] -- 2887
		if last ~= nil then -- 2887
			local result = execRes -- 2889
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2890
			appendToolResultMessage(shared, last) -- 2891
			emitAgentFinishEvent(shared, last) -- 2892
		end -- 2892
		persistHistoryState(shared) -- 2894
		__TS__Await(maybeCompressHistory(shared)) -- 2895
		persistHistoryState(shared) -- 2896
		return ____awaiter_resolve(nil, "main") -- 2896
	end) -- 2896
end -- 2886
local SearchDoraAPIAction = __TS__Class() -- 2901
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2901
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2901
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2902
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2902
		local last = shared.history[#shared.history] -- 2903
		if not last then -- 2903
			error( -- 2904
				__TS__New(Error, "no history"), -- 2904
				0 -- 2904
			) -- 2904
		end -- 2904
		emitAgentStartEvent(shared, last) -- 2905
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2905
	end) -- 2905
end -- 2902
function SearchDoraAPIAction.prototype.exec(self, input) -- 2909
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2909
		local params = input.params -- 2910
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 2911
		local ____temp_82 = params.pattern or "" -- 2912
		local ____temp_83 = params.docSource or "api" -- 2913
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 2914
		local ____temp_85 = params.programmingLanguage or "ts" -- 2915
		local ____math_min_81 = math.min -- 2916
		local ____math_max_80 = math.max -- 2916
		local ____params_limit_79 = params.limit -- 2916
		if ____params_limit_79 == nil then -- 2916
			____params_limit_79 = 8 -- 2916
		end -- 2916
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 2911
			pattern = ____temp_82, -- 2912
			docSource = ____temp_83, -- 2913
			docLanguage = ____temp_84, -- 2914
			programmingLanguage = ____temp_85, -- 2915
			limit = ____math_min_81( -- 2916
				SEARCH_DORA_API_LIMIT_MAX, -- 2916
				____math_max_80( -- 2916
					1, -- 2916
					__TS__Number(____params_limit_79) -- 2916
				) -- 2916
			), -- 2916
			useRegex = params.useRegex, -- 2917
			caseSensitive = false, -- 2918
			includeContent = true, -- 2919
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2920
		})) -- 2920
		return ____awaiter_resolve(nil, result) -- 2920
	end) -- 2920
end -- 2909
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2925
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2925
		local last = shared.history[#shared.history] -- 2926
		if last ~= nil then -- 2926
			local result = execRes -- 2928
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2929
			appendToolResultMessage(shared, last) -- 2930
			emitAgentFinishEvent(shared, last) -- 2931
		end -- 2931
		persistHistoryState(shared) -- 2933
		__TS__Await(maybeCompressHistory(shared)) -- 2934
		persistHistoryState(shared) -- 2935
		return ____awaiter_resolve(nil, "main") -- 2935
	end) -- 2935
end -- 2925
local ListFilesAction = __TS__Class() -- 2940
ListFilesAction.name = "ListFilesAction" -- 2940
__TS__ClassExtends(ListFilesAction, Node) -- 2940
function ListFilesAction.prototype.prep(self, shared) -- 2941
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2941
		local last = shared.history[#shared.history] -- 2942
		if not last then -- 2942
			error( -- 2943
				__TS__New(Error, "no history"), -- 2943
				0 -- 2943
			) -- 2943
		end -- 2943
		emitAgentStartEvent(shared, last) -- 2944
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2944
	end) -- 2944
end -- 2941
function ListFilesAction.prototype.exec(self, input) -- 2948
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2948
		local params = input.params -- 2949
		local ____Tools_listFiles_93 = Tools.listFiles -- 2950
		local ____input_workDir_90 = input.workDir -- 2951
		local ____temp_91 = params.path or "" -- 2952
		local ____params_globs_92 = params.globs -- 2953
		local ____math_max_89 = math.max -- 2954
		local ____math_floor_88 = math.floor -- 2954
		local ____params_maxEntries_87 = params.maxEntries -- 2954
		if ____params_maxEntries_87 == nil then -- 2954
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2954
		end -- 2954
		local result = ____Tools_listFiles_93({ -- 2950
			workDir = ____input_workDir_90, -- 2951
			path = ____temp_91, -- 2952
			globs = ____params_globs_92, -- 2953
			maxEntries = ____math_max_89( -- 2954
				1, -- 2954
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 2954
			) -- 2954
		}) -- 2954
		return ____awaiter_resolve(nil, result) -- 2954
	end) -- 2954
end -- 2948
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2959
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2959
		local last = shared.history[#shared.history] -- 2960
		if last ~= nil then -- 2960
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2962
			appendToolResultMessage(shared, last) -- 2963
			emitAgentFinishEvent(shared, last) -- 2964
		end -- 2964
		persistHistoryState(shared) -- 2966
		__TS__Await(maybeCompressHistory(shared)) -- 2967
		persistHistoryState(shared) -- 2968
		return ____awaiter_resolve(nil, "main") -- 2968
	end) -- 2968
end -- 2959
local DeleteFileAction = __TS__Class() -- 2973
DeleteFileAction.name = "DeleteFileAction" -- 2973
__TS__ClassExtends(DeleteFileAction, Node) -- 2973
function DeleteFileAction.prototype.prep(self, shared) -- 2974
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2974
		local last = shared.history[#shared.history] -- 2975
		if not last then -- 2975
			error( -- 2976
				__TS__New(Error, "no history"), -- 2976
				0 -- 2976
			) -- 2976
		end -- 2976
		emitAgentStartEvent(shared, last) -- 2977
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2978
		if __TS__StringTrim(targetFile) == "" then -- 2978
			error( -- 2981
				__TS__New(Error, "missing target_file"), -- 2981
				0 -- 2981
			) -- 2981
		end -- 2981
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2981
	end) -- 2981
end -- 2974
function DeleteFileAction.prototype.exec(self, input) -- 2985
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2985
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2986
		if not result.success then -- 2986
			return ____awaiter_resolve(nil, result) -- 2986
		end -- 2986
		return ____awaiter_resolve(nil, { -- 2986
			success = true, -- 2994
			changed = true, -- 2995
			mode = "delete", -- 2996
			checkpointId = result.checkpointId, -- 2997
			checkpointSeq = result.checkpointSeq, -- 2998
			files = {{path = input.targetFile, op = "delete"}} -- 2999
		}) -- 2999
	end) -- 2999
end -- 2985
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3003
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3003
		local last = shared.history[#shared.history] -- 3004
		if last ~= nil then -- 3004
			last.result = execRes -- 3006
			appendToolResultMessage(shared, last) -- 3007
			emitAgentFinishEvent(shared, last) -- 3008
			local result = last.result -- 3009
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3009
				emitAgentEvent(shared, { -- 3014
					type = "checkpoint_created", -- 3015
					sessionId = shared.sessionId, -- 3016
					taskId = shared.taskId, -- 3017
					step = last.step, -- 3018
					tool = "delete_file", -- 3019
					checkpointId = result.checkpointId, -- 3020
					checkpointSeq = result.checkpointSeq, -- 3021
					files = result.files -- 3022
				}) -- 3022
			end -- 3022
		end -- 3022
		persistHistoryState(shared) -- 3026
		__TS__Await(maybeCompressHistory(shared)) -- 3027
		persistHistoryState(shared) -- 3028
		return ____awaiter_resolve(nil, "main") -- 3028
	end) -- 3028
end -- 3003
local BuildAction = __TS__Class() -- 3033
BuildAction.name = "BuildAction" -- 3033
__TS__ClassExtends(BuildAction, Node) -- 3033
function BuildAction.prototype.prep(self, shared) -- 3034
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3034
		local last = shared.history[#shared.history] -- 3035
		if not last then -- 3035
			error( -- 3036
				__TS__New(Error, "no history"), -- 3036
				0 -- 3036
			) -- 3036
		end -- 3036
		emitAgentStartEvent(shared, last) -- 3037
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3037
	end) -- 3037
end -- 3034
function BuildAction.prototype.exec(self, input) -- 3041
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3041
		local params = input.params -- 3042
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3043
		return ____awaiter_resolve(nil, result) -- 3043
	end) -- 3043
end -- 3041
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3050
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3050
		local last = shared.history[#shared.history] -- 3051
		if last ~= nil then -- 3051
			last.result = sanitizeBuildResultForHistory(execRes) -- 3053
			appendToolResultMessage(shared, last) -- 3054
			emitAgentFinishEvent(shared, last) -- 3055
		end -- 3055
		persistHistoryState(shared) -- 3057
		__TS__Await(maybeCompressHistory(shared)) -- 3058
		persistHistoryState(shared) -- 3059
		return ____awaiter_resolve(nil, "main") -- 3059
	end) -- 3059
end -- 3050
local SpawnSubAgentAction = __TS__Class() -- 3064
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3064
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3064
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3065
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3065
		local last = shared.history[#shared.history] -- 3074
		if not last then -- 3074
			error( -- 3075
				__TS__New(Error, "no history"), -- 3075
				0 -- 3075
			) -- 3075
		end -- 3075
		emitAgentStartEvent(shared, last) -- 3076
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3077
			last.params.filesHint, -- 3078
			function(____, item) return type(item) == "string" end -- 3078
		) or nil -- 3078
		return ____awaiter_resolve( -- 3078
			nil, -- 3078
			{ -- 3080
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3081
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3082
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3083
				filesHint = filesHint, -- 3084
				sessionId = shared.sessionId, -- 3085
				projectRoot = shared.workingDir, -- 3086
				spawnSubAgent = shared.spawnSubAgent -- 3087
			} -- 3087
		) -- 3087
	end) -- 3087
end -- 3065
function SpawnSubAgentAction.prototype.exec(self, input) -- 3091
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3091
		if not input.spawnSubAgent then -- 3091
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3091
		end -- 3091
		if input.sessionId == nil or input.sessionId <= 0 then -- 3091
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3091
		end -- 3091
		local ____Log_99 = Log -- 3106
		local ____temp_96 = #input.title -- 3106
		local ____temp_97 = #input.prompt -- 3106
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3106
		local ____opt_94 = input.filesHint -- 3106
		____Log_99( -- 3106
			"Info", -- 3106
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3106
		) -- 3106
		local result = __TS__Await(input.spawnSubAgent({ -- 3107
			parentSessionId = input.sessionId, -- 3108
			projectRoot = input.projectRoot, -- 3109
			title = input.title, -- 3110
			prompt = input.prompt, -- 3111
			expectedOutput = input.expectedOutput, -- 3112
			filesHint = input.filesHint -- 3113
		})) -- 3113
		if not result.success then -- 3113
			return ____awaiter_resolve(nil, result) -- 3113
		end -- 3113
		return ____awaiter_resolve(nil, { -- 3113
			success = true, -- 3119
			sessionId = result.sessionId, -- 3120
			taskId = result.taskId, -- 3121
			title = result.title, -- 3122
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3123
		}) -- 3123
	end) -- 3123
end -- 3091
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3127
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3127
		local last = shared.history[#shared.history] -- 3128
		if last ~= nil then -- 3128
			last.result = execRes -- 3130
			appendToolResultMessage(shared, last) -- 3131
			emitAgentFinishEvent(shared, last) -- 3132
		end -- 3132
		persistHistoryState(shared) -- 3134
		__TS__Await(maybeCompressHistory(shared)) -- 3135
		persistHistoryState(shared) -- 3136
		return ____awaiter_resolve(nil, "main") -- 3136
	end) -- 3136
end -- 3127
local ListSubAgentsAction = __TS__Class() -- 3141
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3141
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3141
function ListSubAgentsAction.prototype.prep(self, shared) -- 3142
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3142
		local last = shared.history[#shared.history] -- 3151
		if not last then -- 3151
			error( -- 3152
				__TS__New(Error, "no history"), -- 3152
				0 -- 3152
			) -- 3152
		end -- 3152
		emitAgentStartEvent(shared, last) -- 3153
		return ____awaiter_resolve( -- 3153
			nil, -- 3153
			{ -- 3154
				sessionId = shared.sessionId, -- 3155
				projectRoot = shared.workingDir, -- 3156
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3157
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3158
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3159
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3160
				listSubAgents = shared.listSubAgents -- 3161
			} -- 3161
		) -- 3161
	end) -- 3161
end -- 3142
function ListSubAgentsAction.prototype.exec(self, input) -- 3165
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3165
		if not input.listSubAgents then -- 3165
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3165
		end -- 3165
		if input.sessionId == nil or input.sessionId <= 0 then -- 3165
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3165
		end -- 3165
		local result = __TS__Await(input.listSubAgents({ -- 3180
			sessionId = input.sessionId, -- 3181
			projectRoot = input.projectRoot, -- 3182
			status = input.status, -- 3183
			limit = input.limit, -- 3184
			offset = input.offset, -- 3185
			query = input.query -- 3186
		})) -- 3186
		return ____awaiter_resolve(nil, result) -- 3186
	end) -- 3186
end -- 3165
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3191
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3191
		local last = shared.history[#shared.history] -- 3192
		if last ~= nil then -- 3192
			last.result = execRes -- 3194
			appendToolResultMessage(shared, last) -- 3195
			emitAgentFinishEvent(shared, last) -- 3196
		end -- 3196
		persistHistoryState(shared) -- 3198
		__TS__Await(maybeCompressHistory(shared)) -- 3199
		persistHistoryState(shared) -- 3200
		return ____awaiter_resolve(nil, "main") -- 3200
	end) -- 3200
end -- 3191
EditFileAction = __TS__Class() -- 3205
EditFileAction.name = "EditFileAction" -- 3205
__TS__ClassExtends(EditFileAction, Node) -- 3205
function EditFileAction.prototype.prep(self, shared) -- 3206
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3206
		local last = shared.history[#shared.history] -- 3207
		if not last then -- 3207
			error( -- 3208
				__TS__New(Error, "no history"), -- 3208
				0 -- 3208
			) -- 3208
		end -- 3208
		emitAgentStartEvent(shared, last) -- 3209
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3210
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3213
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3214
		if __TS__StringTrim(path) == "" then -- 3214
			error( -- 3215
				__TS__New(Error, "missing path"), -- 3215
				0 -- 3215
			) -- 3215
		end -- 3215
		return ____awaiter_resolve(nil, { -- 3215
			path = path, -- 3216
			oldStr = oldStr, -- 3216
			newStr = newStr, -- 3216
			taskId = shared.taskId, -- 3216
			workDir = shared.workingDir -- 3216
		}) -- 3216
	end) -- 3216
end -- 3206
function EditFileAction.prototype.exec(self, input) -- 3219
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3219
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3220
		if not readRes.success then -- 3220
			if input.oldStr ~= "" then -- 3220
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3220
			end -- 3220
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3225
			if not createRes.success then -- 3225
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3225
			end -- 3225
			return ____awaiter_resolve(nil, { -- 3225
				success = true, -- 3233
				changed = true, -- 3234
				mode = "create", -- 3235
				checkpointId = createRes.checkpointId, -- 3236
				checkpointSeq = createRes.checkpointSeq, -- 3237
				files = {{path = input.path, op = "create"}} -- 3238
			}) -- 3238
		end -- 3238
		if input.oldStr == "" then -- 3238
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3242
			if not overwriteRes.success then -- 3242
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3242
			end -- 3242
			return ____awaiter_resolve(nil, { -- 3242
				success = true, -- 3250
				changed = true, -- 3251
				mode = "overwrite", -- 3252
				checkpointId = overwriteRes.checkpointId, -- 3253
				checkpointSeq = overwriteRes.checkpointSeq, -- 3254
				files = {{path = input.path, op = "write"}} -- 3255
			}) -- 3255
		end -- 3255
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3260
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3261
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3262
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3265
		if occurrences == 0 then -- 3265
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3267
			if not indentTolerant.success then -- 3267
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3267
			end -- 3267
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3271
			if not applyRes.success then -- 3271
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3271
			end -- 3271
			return ____awaiter_resolve(nil, { -- 3271
				success = true, -- 3279
				changed = true, -- 3280
				mode = "replace_indent_tolerant", -- 3281
				checkpointId = applyRes.checkpointId, -- 3282
				checkpointSeq = applyRes.checkpointSeq, -- 3283
				files = {{path = input.path, op = "write"}} -- 3284
			}) -- 3284
		end -- 3284
		if occurrences > 1 then -- 3284
			return ____awaiter_resolve( -- 3284
				nil, -- 3284
				{ -- 3288
					success = false, -- 3288
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3288
				} -- 3288
			) -- 3288
		end -- 3288
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3292
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3293
		if not applyRes.success then -- 3293
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3293
		end -- 3293
		return ____awaiter_resolve(nil, { -- 3293
			success = true, -- 3301
			changed = true, -- 3302
			mode = "replace", -- 3303
			checkpointId = applyRes.checkpointId, -- 3304
			checkpointSeq = applyRes.checkpointSeq, -- 3305
			files = {{path = input.path, op = "write"}} -- 3306
		}) -- 3306
	end) -- 3306
end -- 3219
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3310
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3310
		local last = shared.history[#shared.history] -- 3311
		if last ~= nil then -- 3311
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3313
			last.result = execRes -- 3314
			appendToolResultMessage(shared, last) -- 3315
			emitAgentFinishEvent(shared, last) -- 3316
			local result = last.result -- 3317
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3317
				emitAgentEvent(shared, { -- 3322
					type = "checkpoint_created", -- 3323
					sessionId = shared.sessionId, -- 3324
					taskId = shared.taskId, -- 3325
					step = last.step, -- 3326
					tool = last.tool, -- 3327
					checkpointId = result.checkpointId, -- 3328
					checkpointSeq = result.checkpointSeq, -- 3329
					files = result.files -- 3330
				}) -- 3330
			end -- 3330
		end -- 3330
		persistHistoryState(shared) -- 3334
		__TS__Await(maybeCompressHistory(shared)) -- 3335
		persistHistoryState(shared) -- 3336
		return ____awaiter_resolve(nil, "main") -- 3336
	end) -- 3336
end -- 3310
local function emitCheckpointEventForAction(shared, action) -- 3341
	local result = action.result -- 3342
	if not result then -- 3342
		return -- 3343
	end -- 3343
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3343
		emitAgentEvent(shared, { -- 3348
			type = "checkpoint_created", -- 3349
			sessionId = shared.sessionId, -- 3350
			taskId = shared.taskId, -- 3351
			step = action.step, -- 3352
			tool = action.tool, -- 3353
			checkpointId = result.checkpointId, -- 3354
			checkpointSeq = result.checkpointSeq, -- 3355
			files = result.files -- 3356
		}) -- 3356
	end -- 3356
end -- 3341
local function sanitizeToolActionResultForHistory(action, result) -- 3511
	if action.tool == "read_file" then -- 3511
		return sanitizeReadResultForHistory(action.tool, result) -- 3513
	end -- 3513
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3513
		return sanitizeSearchResultForHistory(action.tool, result) -- 3516
	end -- 3516
	if action.tool == "glob_files" then -- 3516
		return sanitizeListFilesResultForHistory(result) -- 3519
	end -- 3519
	if action.tool == "build" then -- 3519
		return sanitizeBuildResultForHistory(result) -- 3522
	end -- 3522
	return result -- 3524
end -- 3511
local function canRunBatchActionInParallel(self, action) -- 3527
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3528
end -- 3527
local BatchToolAction = __TS__Class() -- 3535
BatchToolAction.name = "BatchToolAction" -- 3535
__TS__ClassExtends(BatchToolAction, Node) -- 3535
function BatchToolAction.prototype.prep(self, shared) -- 3536
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3536
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3536
	end) -- 3536
end -- 3536
function BatchToolAction.prototype.exec(self, input) -- 3540
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3540
		local shared = input.shared -- 3541
		local preExecuted = shared.preExecutedResults -- 3542
		local allParallelSafe = #input.actions > 1 and __TS__ArrayEvery(input.actions, canRunBatchActionInParallel) -- 3543
		if not allParallelSafe then -- 3543
			do -- 3543
				local i = 0 -- 3545
				while i < #input.actions do -- 3545
					local action = input.actions[i + 1] -- 3546
					emitAgentStartEvent(shared, action) -- 3547
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3548
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3549
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3550
					appendToolResultMessage(shared, action) -- 3551
					emitAgentFinishEvent(shared, action) -- 3552
					emitCheckpointEventForAction(shared, action) -- 3553
					persistHistoryState(shared) -- 3554
					if shared.stopToken.stopped then -- 3554
						break -- 3556
					end -- 3556
					i = i + 1 -- 3545
				end -- 3545
			end -- 3545
			return ____awaiter_resolve(nil, input.actions) -- 3545
		end -- 3545
		local preExecCount = #__TS__ArrayFilter( -- 3562
			input.actions, -- 3562
			function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3562
		) -- 3562
		Log( -- 3563
			"Info", -- 3563
			(("[CodingAgent] batch read-only tools executing in parallel count=" .. tostring(#input.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3563
		) -- 3563
		do -- 3563
			local i = 0 -- 3564
			while i < #input.actions do -- 3564
				emitAgentStartEvent(shared, input.actions[i + 1]) -- 3565
				i = i + 1 -- 3564
			end -- 3564
		end -- 3564
		__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3567
			input.actions, -- 3567
			function(____, action) -- 3567
				return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3567
					if shared.stopToken.stopped then -- 3567
						action.result = { -- 3569
							success = false, -- 3569
							message = getCancelledReason(shared) -- 3569
						} -- 3569
						return ____awaiter_resolve(nil, action) -- 3569
					end -- 3569
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3572
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3573
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3574
					return ____awaiter_resolve(nil, action) -- 3574
				end) -- 3574
			end -- 3567
		))) -- 3567
		do -- 3567
			local i = 0 -- 3577
			while i < #input.actions do -- 3577
				local action = input.actions[i + 1] -- 3578
				if not action.result then -- 3578
					action.result = {success = false, message = "tool did not produce a result"} -- 3580
				end -- 3580
				appendToolResultMessage(shared, action) -- 3582
				emitAgentFinishEvent(shared, action) -- 3583
				emitCheckpointEventForAction(shared, action) -- 3584
				i = i + 1 -- 3577
			end -- 3577
		end -- 3577
		persistHistoryState(shared) -- 3586
		return ____awaiter_resolve(nil, input.actions) -- 3586
	end) -- 3586
end -- 3540
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3590
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3590
		shared.pendingToolActions = nil -- 3591
		shared.preExecutedResults = nil -- 3592
		persistHistoryState(shared) -- 3593
		__TS__Await(maybeCompressHistory(shared)) -- 3594
		persistHistoryState(shared) -- 3595
		return ____awaiter_resolve(nil, "main") -- 3595
	end) -- 3595
end -- 3590
local EndNode = __TS__Class() -- 3600
EndNode.name = "EndNode" -- 3600
__TS__ClassExtends(EndNode, Node) -- 3600
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3601
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3601
		return ____awaiter_resolve(nil, nil) -- 3601
	end) -- 3601
end -- 3601
local CodingAgentFlow = __TS__Class() -- 3606
CodingAgentFlow.name = "CodingAgentFlow" -- 3606
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3606
function CodingAgentFlow.prototype.____constructor(self, role) -- 3607
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3608
	local read = __TS__New(ReadFileAction, 1, 0) -- 3609
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3610
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3611
	local list = __TS__New(ListFilesAction, 1, 0) -- 3612
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3613
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3614
	local build = __TS__New(BuildAction, 1, 0) -- 3615
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3616
	local edit = __TS__New(EditFileAction, 1, 0) -- 3617
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3618
	local done = __TS__New(EndNode, 1, 0) -- 3619
	main:on("batch_tools", batch) -- 3621
	main:on("grep_files", search) -- 3622
	main:on("search_dora_api", searchDora) -- 3623
	main:on("glob_files", list) -- 3624
	if role == "main" then -- 3624
		main:on("read_file", read) -- 3626
		main:on("delete_file", del) -- 3627
		main:on("build", build) -- 3628
		main:on("edit_file", edit) -- 3629
		main:on("list_sub_agents", listSub) -- 3630
		main:on("spawn_sub_agent", spawn) -- 3631
	else -- 3631
		main:on("read_file", read) -- 3633
		main:on("delete_file", del) -- 3634
		main:on("build", build) -- 3635
		main:on("edit_file", edit) -- 3636
	end -- 3636
	main:on("done", done) -- 3638
	search:on("main", main) -- 3640
	searchDora:on("main", main) -- 3641
	list:on("main", main) -- 3642
	listSub:on("main", main) -- 3643
	spawn:on("main", main) -- 3644
	batch:on("main", main) -- 3645
	read:on("main", main) -- 3646
	del:on("main", main) -- 3647
	build:on("main", main) -- 3648
	edit:on("main", main) -- 3649
	Flow.prototype.____constructor(self, main) -- 3651
end -- 3607
local function runCodingAgentAsync(options) -- 3673
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3673
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3673
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3673
		end -- 3673
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3677
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3678
		if not llmConfigRes.success then -- 3678
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3678
		end -- 3678
		local llmConfig = llmConfigRes.config -- 3684
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3685
		if not taskRes.success then -- 3685
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3685
		end -- 3685
		local compressor = __TS__New(MemoryCompressor, { -- 3692
			compressionThreshold = 0.8, -- 3693
			compressionTargetThreshold = 0.5, -- 3694
			maxCompressionRounds = 3, -- 3695
			projectDir = options.workDir, -- 3696
			llmConfig = llmConfig, -- 3697
			promptPack = options.promptPack, -- 3698
			scope = options.memoryScope -- 3699
		}) -- 3699
		local persistedSession = compressor:getStorage():readSessionState() -- 3701
		local promptPack = compressor:getPromptPack() -- 3702
		local shared = { -- 3704
			sessionId = options.sessionId, -- 3705
			taskId = taskRes.taskId, -- 3706
			role = options.role or "main", -- 3707
			maxSteps = math.max( -- 3708
				1, -- 3708
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3708
			), -- 3708
			llmMaxTry = math.max( -- 3709
				1, -- 3709
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3709
			), -- 3709
			step = 0, -- 3710
			done = false, -- 3711
			stopToken = options.stopToken or ({stopped = false}), -- 3712
			response = "", -- 3713
			userQuery = normalizedPrompt, -- 3714
			workingDir = options.workDir, -- 3715
			useChineseResponse = options.useChineseResponse == true, -- 3716
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3717
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3720
			llmConfig = llmConfig, -- 3721
			onEvent = options.onEvent, -- 3722
			promptPack = promptPack, -- 3723
			history = {}, -- 3724
			messages = persistedSession.messages, -- 3725
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3726
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3727
			memory = {compressor = compressor}, -- 3729
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3733
			spawnSubAgent = options.spawnSubAgent, -- 3738
			listSubAgents = options.listSubAgents -- 3739
		} -- 3739
		local ____try = __TS__AsyncAwaiter(function() -- 3739
			emitAgentEvent(shared, { -- 3743
				type = "task_started", -- 3744
				sessionId = shared.sessionId, -- 3745
				taskId = shared.taskId, -- 3746
				prompt = shared.userQuery, -- 3747
				workDir = shared.workingDir, -- 3748
				maxSteps = shared.maxSteps -- 3749
			}) -- 3749
			if shared.stopToken.stopped then -- 3749
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3752
				return ____awaiter_resolve( -- 3752
					nil, -- 3752
					emitAgentTaskFinishEvent( -- 3753
						shared, -- 3753
						false, -- 3753
						getCancelledReason(shared) -- 3753
					) -- 3753
				) -- 3753
			end -- 3753
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3755
			local promptCommand = getPromptCommand(shared.userQuery) -- 3756
			if promptCommand == "clear" then -- 3756
				return ____awaiter_resolve( -- 3756
					nil, -- 3756
					clearSessionHistory(shared) -- 3758
				) -- 3758
			end -- 3758
			if promptCommand == "compact" then -- 3758
				if shared.role == "sub" then -- 3758
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3762
					return ____awaiter_resolve( -- 3762
						nil, -- 3762
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3763
					) -- 3763
				end -- 3763
				return ____awaiter_resolve( -- 3763
					nil, -- 3763
					__TS__Await(compactAllHistory(shared)) -- 3771
				) -- 3771
			end -- 3771
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3773
			persistHistoryState(shared) -- 3777
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3778
			__TS__Await(flow:run(shared)) -- 3779
			if shared.stopToken.stopped then -- 3779
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3781
				return ____awaiter_resolve( -- 3781
					nil, -- 3781
					emitAgentTaskFinishEvent( -- 3782
						shared, -- 3782
						false, -- 3782
						getCancelledReason(shared) -- 3782
					) -- 3782
				) -- 3782
			end -- 3782
			if shared.error then -- 3782
				return ____awaiter_resolve( -- 3782
					nil, -- 3782
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3785
				) -- 3785
			end -- 3785
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3788
			return ____awaiter_resolve( -- 3788
				nil, -- 3788
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3789
			) -- 3789
		end) -- 3789
		__TS__Await(____try.catch( -- 3742
			____try, -- 3742
			function(____, e) -- 3742
				return ____awaiter_resolve( -- 3742
					nil, -- 3742
					finalizeAgentFailure( -- 3792
						shared, -- 3792
						tostring(e) -- 3792
					) -- 3792
				) -- 3792
			end -- 3792
		)) -- 3792
	end) -- 3792
end -- 3673
function ____exports.runCodingAgent(options, callback) -- 3796
	local ____self_136 = runCodingAgentAsync(options) -- 3796
	____self_136["then"]( -- 3796
		____self_136, -- 3796
		function(____, result) return callback(result) end -- 3797
	) -- 3797
end -- 3796
return ____exports -- 3796