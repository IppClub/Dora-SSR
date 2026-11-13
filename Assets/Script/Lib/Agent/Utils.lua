local ____lualib = require("lualib_bundle")
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__StringSlice = ____lualib.__TS__StringSlice
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__StringAccess = ____lualib.__TS__StringAccess
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__StringIncludes = ____lualib.__TS__StringIncludes
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__Promise = ____lualib.__TS__Promise
local __TS__New = ____lualib.__TS__New
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__Delete = ____lualib.__TS__Delete
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite
local __TS__Number = ____lualib.__TS__Number
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArraySort = ____lualib.__TS__ArraySort
local ____exports = {}
local normalizeReasoningEffort
local ____Dora = require("Dora")
local json = ____Dora.json
local HttpClient = ____Dora.HttpClient
local DB = ____Dora.DB
local emit = ____Dora.emit
local DoraLog = ____Dora.Log
local Director = ____Dora.Director
local once = ____Dora.once
local App = ____Dora.App
local AgentConfig = require("Agent.Config.Defaults")
local ____LLMConfigMigration = require("Agent.Config.LLMConfigMigration")
local upgradeLLMConfig = ____LLMConfigMigration.upgradeLLMConfig
function ____exports.sanitizeUTF8(text)
	if text == "" then
		return ""
	end
	local remaining = text
	local output = ""
	while remaining ~= "" do
		local len, invalidPos = utf8.len(remaining)
		if len ~= nil then
			output = output .. remaining
			break
		end
		local badPos = type(invalidPos) == "number" and invalidPos or 1
		if badPos > 1 then
			output = output .. __TS__StringSubstring(remaining, 0, badPos - 1)
		end
		remaining = __TS__StringSubstring(remaining, badPos)
	end
	return output
end
function normalizeReasoningEffort(value)
	if type(value) ~= "string" then
		return nil
	end
	local normalized = __TS__StringTrim(____exports.sanitizeUTF8(value))
	return normalized ~= "" and normalized or nil
end
function ____exports.applyCustomLLMOptions(options, customOptions)
	if not customOptions then
		return options
	end
	local merged = __TS__ObjectAssign({}, options)
	for key in pairs(customOptions) do
		do
			if key == "auxiliaryOptions" then
				goto __continue282
			end
			local value = customOptions[key]
			if value == json.null then
				__TS__Delete(merged, key)
			else
				merged[key] = value
			end
		end
		::__continue282::
	end
	return merged
end
local LOG_LEVEL = App.debugging and 3 or 2
function ____exports.setLogLevel(level)
	LOG_LEVEL = level
end
local LLM_TIMEOUT = 600
local LLM_STREAM_TIMEOUT = 600
local LLM_TIMEOUT_MIN_SECONDS = 60
local LLM_TIMEOUT_PER_10K_TOKENS = 30
local function estimateRequestTimeout(messages, stream)
	local base = stream and LLM_STREAM_TIMEOUT or LLM_TIMEOUT
	local estimatedTokens = 0
	do
		local i = 0
		while i < #messages do
			local message = messages[i + 1]
			if type(message.content) == "string" then
				estimatedTokens = estimatedTokens + #message.content / 4
			end
			if type(message.reasoning_content) == "string" then
				estimatedTokens = estimatedTokens + #message.reasoning_content / 4
			end
			if message.tool_calls then
				do
					local j = 0
					while j < #message.tool_calls do
						local fn = message.tool_calls[j + 1]["function"]
						if fn ~= nil and type(fn.arguments) == "string" then
							estimatedTokens = estimatedTokens + #fn.arguments / 4
						end
						j = j + 1
					end
				end
			end
			i = i + 1
		end
	end
	local adaptive = math.max(
		LLM_TIMEOUT_MIN_SECONDS,
		math.floor(estimatedTokens / 10000) * LLM_TIMEOUT_PER_10K_TOKENS + LLM_TIMEOUT_MIN_SECONDS
	)
	return math.min(base, adaptive)
end
local LLM_STREAM_RAW_DEBUG_MAX = 12000
local LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT = 5
____exports.Log = function(____type, msg)
	if LOG_LEVEL < 1 then
		return
	elseif LOG_LEVEL < 2 and (____type == "Info" or ____type == "Warn") then
		return
	elseif LOG_LEVEL < 3 and ____type == "Info" then
		return
	end
	DoraLog(____type, msg)
end
local TOOL_CALL_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz"
local TOOL_CALL_ID_COUNTER = 0
local STUDIO_MODEL_REQUEST_COUNTER = 0
local function toBase36(value)
	if value <= 0 then
		return "0"
	end
	local remaining = math.floor(value)
	local out = ""
	while remaining > 0 do
		local digit = remaining % 36
		out = string.sub(TOOL_CALL_ID_ALPHABET, digit + 1, digit + 1) .. out
		remaining = math.floor(remaining / 36)
	end
	return out
end
function ____exports.createLocalToolCallId()
	TOOL_CALL_ID_COUNTER = TOOL_CALL_ID_COUNTER + 1
	local timePart = toBase36(os.time())
	local counterPart = toBase36(TOOL_CALL_ID_COUNTER)
	return ("tc" .. timePart) .. counterPart
end
function ____exports.createStudioModelRequestId()
	STUDIO_MODEL_REQUEST_COUNTER = STUDIO_MODEL_REQUEST_COUNTER + 1
	return ((("mr" .. toBase36(os.time())) .. toBase36(STUDIO_MODEL_REQUEST_COUNTER)) .. toBase36(math.floor(math.random() * 1000000000))) .. toBase36(math.floor(math.random() * 1000000000))
end
local function normalizeCompletionText(value)
	if type(value) ~= "string" then
		return ""
	end
	return __TS__StringSlice(
		__TS__StringTrim(____exports.sanitizeUTF8(value)),
		0,
		AgentConfig.AGENT_LIMITS.completionTextMaxChars
	)
end
local function normalizeCompletionTextList(value, maxItems)
	if maxItems == nil then
		maxItems = AgentConfig.AGENT_LIMITS.completionListMaxItems
	end
	if not __TS__ArrayIsArray(value) then
		return {}
	end
	local items = {}
	do
		local i = 0
		while i < #value and #items < maxItems do
			local item = normalizeCompletionText(value[i + 1])
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then
				items[#items + 1] = item
			end
			i = i + 1
		end
	end
	return items
end
function ____exports.normalizeAgentCompletionReport(value)
	local row = value and not __TS__ArrayIsArray(value) and type(value) == "table" and value or ({})
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed"
	local validation = {}
	if __TS__ArrayIsArray(row.validation) then
		do
			local i = 0
			while i < #row.validation and #validation < AgentConfig.AGENT_LIMITS.completionListMaxItems do
				do
					local raw = row.validation[i + 1]
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then
						goto __continue31
					end
					local item = raw
					local kind = (item.kind == "runtime" or item.kind == "manual") and item.kind or (item.kind == "build" and "build" or nil)
					local result = (item.result == "passed" or item.result == "failed" or item.result == "not_run") and item.result or nil
					if kind == nil or result == nil then
						goto __continue31
					end
					validation[#validation + 1] = {
						kind = kind,
						result = result,
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems)
					}
				end
				::__continue31::
				i = i + 1
			end
		end
	end
	local learningCandidates = {}
	if __TS__ArrayIsArray(row.learningCandidates) then
		do
			local i = 0
			while i < #row.learningCandidates and #learningCandidates < AgentConfig.AGENT_LIMITS.completionListMaxItems do
				do
					local raw = row.learningCandidates[i + 1]
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then
						goto __continue36
					end
					local item = raw
					local claim = normalizeCompletionText(item.claim)
					if claim == "" then
						goto __continue36
					end
					learningCandidates[#learningCandidates + 1] = {
						claim = claim,
						scope = (item.scope == "file" or item.scope == "engine") and item.scope or "project",
						evidence = normalizeCompletionTextList(item.evidence, AgentConfig.AGENT_LIMITS.completionEvidenceMaxItems),
						confidence = item.confidence == "inferred" and "inferred" or "observed"
					}
				end
				::__continue36::
				i = i + 1
			end
		end
	end
	return {
		outcome = outcome,
		budgetExhausted = row.budgetExhausted == true,
		validation = validation,
		knownIssues = normalizeCompletionTextList(row.knownIssues),
		assumptions = normalizeCompletionTextList(row.assumptions),
		learningCandidates = learningCandidates
	}
end
function ____exports.replaceFirst(text, oldStr, newStr)
	if oldStr == "" then
		return text
	end
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1
	if idx < 0 then
		return text
	end
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr)
end
local function getLeadingWhitespace(text)
	local i = 0
	while i < #text do
		local ch = __TS__StringAccess(text, i)
		if ch ~= " " and ch ~= "\t" then
			break
		end
		i = i + 1
	end
	return __TS__StringSubstring(text, 0, i)
end
local function getCommonIndentPrefix(lines)
	local common
	do
		local i = 0
		while i < #lines do
			do
				local line = lines[i + 1]
				if __TS__StringTrim(line) == "" then
					goto __continue47
				end
				local indent = getLeadingWhitespace(line)
				if common == nil then
					common = indent
					goto __continue47
				end
				local j = 0
				local maxLen = math.min(#common, #indent)
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do
					j = j + 1
				end
				common = __TS__StringSubstring(common, 0, j)
				if common == "" then
					break
				end
			end
			::__continue47::
			i = i + 1
		end
	end
	return common or ""
end
local function removeIndentPrefix(line, indent)
	if indent ~= "" and __TS__StringStartsWith(line, indent) then
		return __TS__StringSubstring(line, #indent)
	end
	local lineIndent = getLeadingWhitespace(line)
	local j = 0
	local maxLen = math.min(#lineIndent, #indent)
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do
		j = j + 1
	end
	return __TS__StringSubstring(line, j)
end
local function dedentLines(lines)
	local indent = getCommonIndentPrefix(lines)
	return {
		indent = indent,
		lines = __TS__ArrayMap(
			lines,
			function(____, line) return removeIndentPrefix(line, indent) end
		)
	}
end
local function findWhitespaceTolerantReplacement(content, oldStr, newStr)
	local function foldWhitespace(text, withMap)
		local parts = {}
		local map = {}
		local i = 0
		while i < #text do
			local ch = __TS__StringAccess(text, i)
			if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then
				local start = i
				while i < #text do
					local next = __TS__StringAccess(text, i)
					if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then
						break
					end
					i = i + 1
				end
				parts[#parts + 1] = " "
				if withMap then
					map[#map + 1] = {char = " ", start = start, ["end"] = i}
				end
			else
				parts[#parts + 1] = ch
				if withMap then
					map[#map + 1] = {char = ch, start = i, ["end"] = i + 1}
				end
				i = i + 1
			end
		end
		return {
			text = table.concat(parts, ""),
			map = map
		}
	end
	local foldedContent = foldWhitespace(content, true)
	local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text)
	if foldedOld == "" then
		return {success = false, message = "old_str not found in file"}
	end
	local matches = {}
	local pos = 0
	while true do
		local idx = (string.find(
			foldedContent.text,
			foldedOld,
			math.max(pos + 1, 1),
			true
		) or 0) - 1
		if idx < 0 then
			break
		end
		local lastIdx = idx + #foldedOld - 1
		local startMap = foldedContent.map[idx + 1]
		local endMap = foldedContent.map[lastIdx + 1]
		if startMap ~= nil and endMap ~= nil then
			matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]}
		end
		pos = idx + #foldedOld
	end
	if #matches == 0 then
		return {success = false, message = "old_str not found in file"}
	end
	if #matches > 1 then
		return {
			success = false,
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location."
		}
	end
	local match = matches[1]
	return {
		success = true,
		content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"])
	}
end
function ____exports.findIndentTolerantReplacement(content, oldStr, newStr)
	local contentLines = __TS__StringSplit(content, "\n")
	local oldLines = __TS__StringSplit(oldStr, "\n")
	if #oldLines == 0 then
		return {success = false, message = "old_str not found in file"}
	end
	local dedentedOld = dedentLines(oldLines)
	local dedentedOldText = table.concat(dedentedOld.lines, "\n")
	local dedentedNew = dedentLines(__TS__StringSplit(newStr, "\n"))
	local matches = {}
	do
		local start = 0
		while start <= #contentLines - #oldLines do
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines)
			local dedentedCandidate = dedentLines(candidateLines)
			if table.concat(dedentedCandidate.lines, "\n") == dedentedOldText then
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent}
			end
			start = start + 1
		end
	end
	if #matches == 0 then
		return findWhitespaceTolerantReplacement(content, oldStr, newStr)
	end
	if #matches > 1 then
		return {
			success = false,
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location."
		}
	end
	local match = matches[1]
	local rebuiltNewLines = __TS__ArrayMap(
		dedentedNew.lines,
		function(____, line) return line == "" and "" or match.indent .. line end
	)
	local ____array_0 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start)))
	__TS__SparseArrayPush(
		____array_0,
		table.unpack(rebuiltNewLines)
	)
	__TS__SparseArrayPush(
		____array_0,
		table.unpack(__TS__ArraySlice(contentLines, match["end"]))
	)
	local nextLines = {__TS__SparseArraySpread(____array_0)}
	return {
		success = true,
		content = table.concat(nextLines, "\n")
	}
end
local function previewText(text, maxLen)
	if maxLen == nil then
		maxLen = 200
	end
	if text == "" then
		return ""
	end
	local compact = __TS__StringReplace(
		__TS__StringReplace(text, "\r", "\\r"),
		"\n",
		"\\n"
	)
	if #compact <= maxLen then
		return compact
	end
	return __TS__StringSlice(compact, 0, maxLen) .. "..."
end
local function sanitizeJSONValue(value)
	if type(value) == "string" then
		return ____exports.sanitizeUTF8(value)
	end
	if __TS__ArrayIsArray(value) then
		return __TS__ArrayMap(
			value,
			function(____, item) return sanitizeJSONValue(item) end
		)
	end
	if value and type(value) == "table" then
		local result = {}
		for key in pairs(value) do
			result[key] = sanitizeJSONValue(value[key])
		end
		return result
	end
	return value
end
function ____exports.safeJsonEncode(value, format, emptyAsArray, numAsStr, maxDepth)
	if format == nil then
		format = false
	end
	if emptyAsArray == nil then
		emptyAsArray = true
	end
	if numAsStr == nil then
		numAsStr = false
	end
	if maxDepth == nil then
		maxDepth = 128
	end
	return json.encode(
		sanitizeJSONValue(value),
		format,
		emptyAsArray,
		numAsStr,
		maxDepth
	)
end
function ____exports.safeJsonDecode(text)
	local value, err = json.decode(____exports.sanitizeUTF8(text))
	if value == nil then
		return value, err
	end
	return sanitizeJSONValue(value), err
end
local function isPlainRecord(value)
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value)
end
local function normalizeLLMJSONResponse(text)
	return __TS__StringTrim(text)
end
local function utf8TakeHead(text, maxChars)
	if maxChars <= 0 or text == "" then
		return ""
	end
	local nextPos = utf8.offset(text, maxChars + 1)
	if nextPos == nil then
		return text
	end
	return string.sub(text, 1, nextPos - 1)
end
local function utf8TakeTail(text, maxChars)
	if maxChars <= 0 or text == "" then
		return ""
	end
	local charLen = utf8.len(text)
	if charLen == nil or charLen <= maxChars then
		return text
	end
	local startChar = math.max(1, charLen - maxChars + 1)
	local startPos = utf8.offset(text, startChar)
	if startPos == nil then
		return text
	end
	return string.sub(text, startPos)
end
function ____exports.estimateTextTokens(text)
	if text == "" then
		return 0
	end
	return App:estimateTokens(text)
end
local function stringifyMessageContent(content)
	if type(content) == "string" then
		return content
	end
	if __TS__ArrayIsArray(content) then
		local parts = {}
		for ____, block in ipairs(content) do
			if block.type == "text" and block.text ~= nil then
				parts[#parts + 1] = block.text
			elseif block.type == "image_url" then
				parts[#parts + 1] = "[image]"
			end
		end
		return table.concat(parts, "\n")
	end
	return ""
end
local function estimateMessagesTokens(messages)
	local total = 0
	do
		local i = 0
		while i < #messages do
			local message = messages[i + 1]
			total = total + 8
			total = total + ____exports.estimateTextTokens(message.role or "")
			total = total + ____exports.estimateTextTokens(type(message.content) == "string" and message.content or stringifyMessageContent(message.content))
			total = total + ____exports.estimateTextTokens(message.name or "")
			total = total + ____exports.estimateTextTokens(message.tool_call_id or "")
			total = total + ____exports.estimateTextTokens(message.reasoning_content or "")
			local toolCallsText = ____exports.safeJsonEncode(message.tool_calls or ({}))
			total = total + ____exports.estimateTextTokens(toolCallsText or "")
			i = i + 1
		end
	end
	return total
end
local function estimateOptionsTokens(options)
	local text = ____exports.safeJsonEncode(options)
	return text and ____exports.estimateTextTokens(text) or 0
end
local function getReservedOutputTokens(options, contextWindow)
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0)
	if explicitMax > 0 then
		return math.max(256, explicitMax)
	end
	return math.max(
		1024,
		math.floor(contextWindow * 0.2)
	)
end
local function getInputTokenBudget(messages, options, config)
	local contextWindow = config.contextWindow > 0 and math.floor(config.contextWindow) or 64000
	local reservedOutputTokens = getReservedOutputTokens(options, contextWindow)
	local optionTokens = estimateOptionsTokens(options)
	local structuralOverhead = math.max(256, #messages * 16)
	return math.max(512, contextWindow - reservedOutputTokens - optionTokens - structuralOverhead)
end
function ____exports.clipTextToTokenBudget(text, budgetTokens)
	if budgetTokens <= 0 or text == "" then
		return ""
	end
	local estimated = ____exports.estimateTextTokens(text)
	if estimated <= budgetTokens then
		return text
	end
	local charsPerToken = estimated > 0 and #text / estimated or 4
	local targetChars = math.max(
		200,
		math.floor(budgetTokens * charsPerToken)
	)
	local keepHead = math.max(
		0,
		math.floor(targetChars * 0.35)
	)
	local keepTail = math.max(0, targetChars - keepHead)
	local head = keepHead > 0 and utf8TakeHead(text, keepHead) or ""
	local tail = keepTail > 0 and utf8TakeTail(text, keepTail) or ""
	return (head .. "\n...\n") .. tail
end
local function isXMLWhitespaceChar(ch)
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r"
end
local function findLineStart(value, from)
	local i = from
	while i >= 0 do
		if __TS__StringAccess(value, i) == "\n" then
			return i + 1
		end
		i = i - 1
	end
	return 0
end
local function findLastLiteral(text, needle)
	if needle == "" then
		return #text
	end
	local last = -1
	local from = 0
	while from <= #text - #needle do
		local pos = (string.find(
			text,
			needle,
			math.max(from + 1, 1),
			true
		) or 0) - 1
		if pos < 0 then
			break
		end
		last = pos
		from = pos + 1
	end
	return last
end
local function unwrapXMLRawText(text)
	local trimmed = __TS__StringTrim(text)
	if __TS__StringStartsWith(trimmed, "<![CDATA[") and __TS__StringEndsWith(trimmed, "]]>") then
		return __TS__StringSlice(trimmed, 9, #trimmed - 3)
	end
	return text
end
local function readSimpleXMLTagName(source, openStart, openEnd)
	local rawTag = __TS__StringTrim(__TS__StringSlice(source, openStart + 1, openEnd))
	if rawTag == "" then
		return {
			success = false,
			message = "invalid xml: empty tag at offset " .. tostring(openStart)
		}
	end
	local selfClosing = false
	local tagText = rawTag
	if __TS__StringEndsWith(tagText, "/") then
		selfClosing = true
		tagText = __TS__StringTrim(__TS__StringSlice(tagText, 0, #tagText - 1))
	end
	local tagName = ""
	do
		local i = 0
		while i < #tagText do
			local ch = __TS__StringAccess(tagText, i)
			if isXMLWhitespaceChar(ch) or ch == "/" then
				break
			end
			tagName = tagName .. ch
			i = i + 1
		end
	end
	if tagName == "" then
		return {success = false, message = ("invalid xml: unsupported tag syntax <" .. rawTag) .. ">"}
	end
	return {success = true, tagName = tagName, selfClosing = selfClosing}
end
local function findMatchingXMLClose(source, tagName, contentStart)
	local sameOpenPrefix = "<" .. tagName
	local sameCloseToken = ("</" .. tagName) .. ">"
	local pos = contentStart
	local depth = 1
	while pos < #source do
		do
			local lt = (string.find(
				source,
				"<",
				math.max(pos + 1, 1),
				true
			) or 0) - 1
			if lt < 0 then
				break
			end
			if __TS__StringStartsWith(source, "<![CDATA[", lt) then
				local cdataEnd = (string.find(
					source,
					"]]>",
					math.max(lt + 9 + 1, 1),
					true
				) or 0) - 1
				if cdataEnd < 0 then
					return {success = false, message = "invalid xml: unterminated CDATA"}
				end
				pos = cdataEnd + 3
				goto __continue144
			end
			if __TS__StringStartsWith(source, "<!--", lt) then
				local commentEnd = (string.find(
					source,
					"-->",
					math.max(lt + 4 + 1, 1),
					true
				) or 0) - 1
				if commentEnd < 0 then
					return {success = false, message = "invalid xml: unterminated comment"}
				end
				pos = commentEnd + 3
				goto __continue144
			end
			if __TS__StringStartsWith(source, sameCloseToken, lt) then
				depth = depth - 1
				if depth == 0 then
					return {success = true, closeStart = lt}
				end
				pos = lt + #sameCloseToken
				goto __continue144
			end
			if __TS__StringStartsWith(source, sameOpenPrefix, lt) then
				local openEnd = (string.find(
					source,
					">",
					math.max(lt + 1, 1),
					true
				) or 0) - 1
				if openEnd < 0 then
					return {success = false, message = "invalid xml: unterminated opening tag"}
				end
				local tagInfo = readSimpleXMLTagName(source, lt, openEnd)
				if not tagInfo.success then
					return tagInfo
				end
				if tagInfo.tagName == tagName and not tagInfo.selfClosing then
					depth = depth + 1
				end
				pos = openEnd + 1
				goto __continue144
			end
			local genericEnd = (string.find(
				source,
				">",
				math.max(lt + 1, 1),
				true
			) or 0) - 1
			if genericEnd < 0 then
				return {success = false, message = "invalid xml: unterminated nested tag"}
			end
			pos = genericEnd + 1
		end
		::__continue144::
	end
	return {success = false, message = ("invalid xml: missing closing tag </" .. tagName) .. ">"}
end
function ____exports.extractXMLFromText(text)
	local source = __TS__StringTrim(text)
	local function extractFencedBlock(fence)
		if not __TS__StringStartsWith(source, fence) then
			return nil
		end
		local firstLineEnd = (string.find(
			source,
			"\n",
			math.max(1, 1),
			true
		) or 0) - 1
		if firstLineEnd < 0 then
			return nil
		end
		local searchPos = firstLineEnd + 1
		local closingFencePositions = {}
		while searchPos < #source do
			local ____end = (string.find(
				source,
				"```",
				math.max(searchPos + 1, 1),
				true
			) or 0) - 1
			if ____end < 0 then
				break
			end
			local lineStart = findLineStart(source, ____end - 1)
			local lineEnd = (string.find(
				source,
				"\n",
				math.max(____end + 1, 1),
				true
			) or 0) - 1
			local actualLineEnd = lineEnd >= 0 and lineEnd or #source
			if __TS__StringTrim(__TS__StringSlice(source, lineStart, actualLineEnd)) == "```" then
				closingFencePositions[#closingFencePositions + 1] = ____end
			end
			searchPos = ____end + 1
		end
		do
			local i = #closingFencePositions - 1
			while i >= 0 do
				do
					local closingFencePos = closingFencePositions[i + 1]
					local afterFence = __TS__StringTrim(__TS__StringSlice(source, closingFencePos + 3))
					if afterFence ~= "" then
						goto __continue165
					end
					return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, closingFencePos))
				end
				::__continue165::
				i = i - 1
			end
		end
		return nil
	end
	local xmlBlock = extractFencedBlock("```xml")
	if xmlBlock ~= nil then
		return xmlBlock
	end
	local genericBlock = extractFencedBlock("```")
	if genericBlock ~= nil then
		return genericBlock
	end
	return source
end
function ____exports.parseSimpleXMLChildren(source)
	local result = {}
	local pos = 0
	while pos < #source do
		do
			while pos < #source and isXMLWhitespaceChar(__TS__StringAccess(source, pos)) do
				pos = pos + 1
			end
			if pos >= #source then
				break
			end
			if __TS__StringAccess(source, pos) ~= "<" then
				return {
					success = false,
					message = "invalid xml: expected tag at offset " .. tostring(pos)
				}
			end
			if __TS__StringStartsWith(source, "</", pos) then
				return {
					success = false,
					message = "invalid xml: unexpected closing tag at offset " .. tostring(pos)
				}
			end
			local openEnd = (string.find(
				source,
				">",
				math.max(pos + 1, 1),
				true
			) or 0) - 1
			if openEnd < 0 then
				return {success = false, message = "invalid xml: unterminated opening tag"}
			end
			local tagInfo = readSimpleXMLTagName(source, pos, openEnd)
			if not tagInfo.success then
				return tagInfo
			end
			if tagInfo.selfClosing then
				result[tagInfo.tagName] = ""
				pos = openEnd + 1
				goto __continue170
			end
			local closeRes = findMatchingXMLClose(source, tagInfo.tagName, openEnd + 1)
			if not closeRes.success then
				return closeRes
			end
			local closeToken = ("</" .. tagInfo.tagName) .. ">"
			result[tagInfo.tagName] = unwrapXMLRawText(__TS__StringSlice(source, openEnd + 1, closeRes.closeStart))
			pos = closeRes.closeStart + #closeToken
		end
		::__continue170::
	end
	return {success = true, obj = result}
end
function ____exports.parseXMLObjectFromText(text, rootTag)
	local xmlText = ____exports.extractXMLFromText(text)
	local rootOpen = ("<" .. rootTag) .. ">"
	local rootClose = ("</" .. rootTag) .. ">"
	local start = (string.find(xmlText, rootOpen, nil, true) or 0) - 1
	local ____end = findLastLiteral(xmlText, rootClose)
	if start < 0 or ____end < start then
		return {success = false, message = ("invalid xml: missing <" .. rootTag) .. "> root"}
	end
	local beforeRoot = __TS__StringTrim(__TS__StringSlice(xmlText, 0, start))
	local afterRoot = __TS__StringTrim(__TS__StringSlice(xmlText, ____end + #rootClose))
	if beforeRoot ~= "" or afterRoot ~= "" then
		return {success = false, message = "invalid xml: root must be the only top-level block"}
	end
	local rootContent = __TS__StringSlice(xmlText, start + #rootOpen, ____end)
	return ____exports.parseSimpleXMLChildren(rootContent)
end
function ____exports.fitMessagesToContext(messages, options, config)
	local modelName = string.lower(config.model)
	local shouldEchoReasoningContent = __TS__ArraySome(
		messages,
		function(____, message) return type(message.reasoning_content) == "string" end
	) or (normalizeReasoningEffort(config.reasoningEffort) or "") ~= "" or __TS__StringIncludes(modelName, "reasoner") or __TS__StringIncludes(modelName, "thinking")
	local cloned = __TS__ArrayMap(
		messages,
		function(____, message)
			local clonedMessage = __TS__ObjectAssign({}, message)
			if shouldEchoReasoningContent and clonedMessage.role == "assistant" and type(clonedMessage.reasoning_content) ~= "string" then
				clonedMessage.reasoning_content = ""
			end
			return clonedMessage
		end
	)
	local budgetTokens = getInputTokenBudget(cloned, options, config)
	local originalTokens = estimateMessagesTokens(cloned)
	if originalTokens <= budgetTokens then
		return {
			messages = cloned,
			trimmed = false,
			originalTokens = originalTokens,
			fittedTokens = originalTokens,
			budgetTokens = budgetTokens
		}
	end
	local function roleOverhead(message)
		return ____exports.estimateTextTokens(message.role or "") + 8
	end
	local fixedOverhead = 0
	local contentIndexes = {}
	do
		local i = 0
		while i < #cloned do
			fixedOverhead = fixedOverhead + roleOverhead(cloned[i + 1])
			contentIndexes[#contentIndexes + 1] = i
			i = i + 1
		end
	end
	local contentBudget = math.max(64, budgetTokens - fixedOverhead)
	if #contentIndexes == 1 then
		local idx = contentIndexes[1]
		cloned[idx + 1].content = ____exports.clipTextToTokenBudget(
			type(cloned[idx + 1].content) == "string" and cloned[idx + 1].content or stringifyMessageContent(cloned[idx + 1].content),
			contentBudget
		)
		local fittedTokens = estimateMessagesTokens(cloned)
		return {
			messages = cloned,
			trimmed = true,
			originalTokens = originalTokens,
			fittedTokens = fittedTokens,
			budgetTokens = budgetTokens
		}
	end
	local nonSystemIndexes = {}
	local systemIndexes = {}
	do
		local i = 0
		while i < #cloned do
			if cloned[i + 1].role == "system" then
				systemIndexes[#systemIndexes + 1] = i
			else
				nonSystemIndexes[#nonSystemIndexes + 1] = i
			end
			i = i + 1
		end
	end
	local ____array_1 = __TS__SparseArrayNew(table.unpack(nonSystemIndexes))
	__TS__SparseArrayPush(
		____array_1,
		table.unpack(systemIndexes)
	)
	local priorityIndexes = {__TS__SparseArraySpread(____array_1)}
	local remainingContentBudget = contentBudget
	do
		local i = #priorityIndexes - 1
		while i >= 0 do
			local idx = priorityIndexes[i + 1]
			local message = cloned[idx + 1]
			local minBudget = message.role == "system" and 96 or 192
			local target = math.max(
				minBudget,
				math.floor(remainingContentBudget / math.max(1, i + 1))
			)
			message.content = ____exports.clipTextToTokenBudget(
				type(message.content) == "string" and message.content or stringifyMessageContent(message.content),
				target
			)
			remainingContentBudget = remainingContentBudget - ____exports.estimateTextTokens(type(message.content) == "string" and message.content or stringifyMessageContent(message.content))
			remainingContentBudget = math.max(0, remainingContentBudget)
			i = i - 1
		end
	end
	local fittedTokens = estimateMessagesTokens(cloned)
	if fittedTokens > budgetTokens then
		do
			local i = 0
			while i < #priorityIndexes and fittedTokens > budgetTokens do
				local idx = priorityIndexes[i + 1]
				local message = cloned[idx + 1]
				local currentTokens = ____exports.estimateTextTokens(type(message.content) == "string" and message.content or stringifyMessageContent(message.content))
				local excess = fittedTokens - budgetTokens
				local nextBudget = math.max(message.role == "system" and 48 or 96, currentTokens - excess - 16)
				message.content = ____exports.clipTextToTokenBudget(
					type(message.content) == "string" and message.content or stringifyMessageContent(message.content),
					nextBudget
				)
				fittedTokens = estimateMessagesTokens(cloned)
				i = i + 1
			end
		end
	end
	if fittedTokens > budgetTokens then
		do
			local i = 0
			while i < #priorityIndexes and fittedTokens > budgetTokens do
				do
					local idx = priorityIndexes[i + 1]
					if cloned[idx + 1].role == "system" then
						goto __continue202
					end
					cloned[idx + 1].content = ____exports.clipTextToTokenBudget(
						type(cloned[idx + 1].content) == "string" and cloned[idx + 1].content or stringifyMessageContent(cloned[idx + 1].content),
						48
					)
					fittedTokens = estimateMessagesTokens(cloned)
				end
				::__continue202::
				i = i + 1
			end
		end
	end
	return {
		messages = cloned,
		trimmed = true,
		originalTokens = originalTokens,
		fittedTokens = fittedTokens,
		budgetTokens = budgetTokens
	}
end
local function postLLM(messages, url, apiKey, model, options, stream, customOptions, receiver, stopToken, studioGateway)
	local requestTimeout = estimateRequestTimeout(messages, stream)
	local requestOptions = ____exports.applyCustomLLMOptions(options, customOptions)
	local data = __TS__ObjectAssign({model = model}, requestOptions, {messages = messages, stream = stream})
	local studioRequestId = studioGateway and ____exports.createStudioModelRequestId() or nil
	if stopToken == nil then
		stopToken = {stopped = false}
	end
	return __TS__New(
		__TS__Promise,
		function(____, resolve, reject)
			local requestId = 0
			local settled = false
			local function finishResolve(text)
				if settled then
					return
				end
				settled = true
				resolve(nil, text)
			end
			local function finishReject(err)
				if settled then
					return
				end
				settled = true
				reject(nil, err)
			end
			Director.systemScheduler:schedule(function()
				if not settled then
					if stopToken.stopped then
						if requestId ~= 0 then
							HttpClient:cancel(requestId)
							requestId = 0
						end
						finishReject("request cancelled")
						return true
					end
					return false
				end
				return true
			end)
			Director.systemScheduler:schedule(once(function()
				emit(
					"LLM_IN",
					table.concat(
						__TS__ArrayMap(
							messages,
							function(____, m, i) return (tostring(i) .. ": ") .. tostring(m.content) end
						),
						"\n"
					)
				)
				local jsonStr, err = ____exports.safeJsonEncode(data)
				if jsonStr ~= nil then
					local headers = {
						"Authorization: Bearer " .. apiKey,
						"Content-Type: application/json",
						receiver and "Accept: text/event-stream" or "Accept: application/json",
						table.unpack(studioRequestId and ({"X-Studio-Model-Request-Id: " .. studioRequestId}) or ({}))
					}
					requestId = receiver and HttpClient:post(
						url,
						headers,
						jsonStr,
						requestTimeout,
						function(data)
							if stopToken.stopped then
								return true
							end
							return receiver(data)
						end,
						function(data)
							requestId = 0
							if data ~= nil then
								finishResolve(data)
							else
								finishReject("failed to get http response")
							end
						end
					) or HttpClient:post(
						url,
						headers,
						jsonStr,
						requestTimeout,
						function(data)
							requestId = 0
							if stopToken.stopped then
								finishReject("request cancelled")
								return
							end
							if data ~= nil then
								finishResolve(data)
							else
								finishReject("failed to get http response")
							end
						end
					)
					if requestId == 0 then
						finishReject("failed to schedule http request")
					elseif stopToken.stopped then
						HttpClient:cancel(requestId)
						requestId = 0
						finishReject("request cancelled")
					end
				else
					finishReject(err)
				end
			end))
		end
	)
end
function ____exports.createSSEJSONParser(opts)
	local buffer = ""
	local eventDataLines = {}
	local function flushEventIfAny()
		if #eventDataLines == 0 then
			return
		end
		local dataPayload = table.concat(eventDataLines, "\n")
		eventDataLines = {}
		if dataPayload == "[DONE]" then
			local ____opt_2 = opts.onDone
			if ____opt_2 ~= nil then
				____opt_2(dataPayload)
			end
			return
		end
		local obj, err = ____exports.safeJsonDecode(dataPayload)
		if err == nil then
			opts.onJSON(obj, dataPayload)
		else
			local ____opt_4 = opts.onError
			if ____opt_4 ~= nil then
				____opt_4(err, {raw = dataPayload})
			end
		end
	end
	local function append(chunk)
		buffer = buffer .. chunk
	end
	local function drain(maxLines)
		local processedLines = 0
		while maxLines == nil or processedLines < maxLines do
			do
				local nl = (string.find(buffer, "\n", nil, true) or 0) - 1
				if nl < 0 then
					break
				end
				processedLines = processedLines + 1
				local line = __TS__StringSlice(buffer, 0, nl)
				buffer = __TS__StringSlice(buffer, nl + 1)
				if __TS__StringEndsWith(line, "\r") then
					line = string.sub(line, 1, -2)
				end
				if line == "" then
					flushEventIfAny()
					goto __continue237
				end
				if __TS__StringStartsWith(line, ":") then
					goto __continue237
				end
				if __TS__StringStartsWith(line, "data:") then
					local v = string.sub(line, 6)
					if __TS__StringStartsWith(v, " ") then
						v = string.sub(v, 2)
					end
					eventDataLines[#eventDataLines + 1] = v
					goto __continue237
				end
			end
			::__continue237::
		end
		return (string.find(buffer, "\n", nil, true) or 0) - 1 >= 0
	end
	local function feed(chunk)
		append(chunk)
		drain()
	end
	local function ____end()
		if #buffer > 0 then
			local line = buffer
			buffer = ""
			if __TS__StringEndsWith(line, "\r") then
				line = string.sub(line, 1, -2)
			end
			if __TS__StringStartsWith(line, "data:") then
				local v = string.sub(line, 6)
				if __TS__StringStartsWith(v, " ") then
					v = string.sub(v, 2)
				end
				eventDataLines[#eventDataLines + 1] = v
			end
		end
		flushEventIfAny()
	end
	local function discard()
		buffer = ""
		eventDataLines = {}
	end
	return {
		append = append,
		drain = drain,
		feed = feed,
		["end"] = ____end,
		discard = discard
	}
end
local SSE_PARSE_LINES_PER_FRAME = 256
local function createScheduledSSEJSONParser(opts, isCancelled)
	local parser = ____exports.createSSEJSONParser(opts)
	local inputFinished = false
	local settled = false
	local resolveFinished
	local finished = __TS__New(
		__TS__Promise,
		function(____, resolve)
			resolveFinished = resolve
		end
	)
	local function settle()
		if settled then
			return
		end
		settled = true
		if resolveFinished ~= nil then
			resolveFinished()
		end
	end
	Director.systemScheduler:schedule(function()
		if settled then
			return true
		end
		if isCancelled and isCancelled() then
			parser.discard()
			settle()
			return true
		end
		local hasMoreCompleteLines = parser.drain(SSE_PARSE_LINES_PER_FRAME)
		if inputFinished and not hasMoreCompleteLines then
			parser["end"]()
			settle()
			return true
		end
		return false
	end)
	return {
		append = parser.append,
		finish = function()
			return __TS__AsyncAwaiter(function(____awaiter_resolve)
				inputFinished = true
				__TS__Await(finished)
			end)
		end,
		cancel = function()
			parser.discard()
			settle()
		end
	}
end
function ____exports.extractLLMTokenUsage(response)
	local usage = response and response.usage
	if not usage or type(usage) ~= "table" then
		return nil
	end
	local inputTokens = type(usage.prompt_tokens) == "number" and usage.prompt_tokens or usage.input_tokens
	local outputTokens = type(usage.completion_tokens) == "number" and usage.completion_tokens or usage.output_tokens
	if type(inputTokens) ~= "number" or type(outputTokens) ~= "number" then
		return nil
	end
	local ____temp_17
	if type(usage.prompt_cache_hit_tokens) == "number" then
		____temp_17 = usage.prompt_cache_hit_tokens
	else
		local ____temp_16
		local ____opt_12 = usage.prompt_tokens_details
		if type(____opt_12 and ____opt_12.cached_tokens) == "number" then
			____temp_16 = usage.prompt_tokens_details.cached_tokens
		else
			local ____opt_14 = usage.input_tokens_details
			____temp_16 = type(____opt_14 and ____opt_14.cached_tokens) == "number" and usage.input_tokens_details.cached_tokens or usage.cache_read_input_tokens
		end
		____temp_17 = ____temp_16
	end
	local cachedInputTokens = ____temp_17
	local ____inputTokens_20 = inputTokens
	local ____outputTokens_21 = outputTokens
	local ____temp_22 = type(usage.total_tokens) == "number" and usage.total_tokens or nil
	local ____temp_23 = type(cachedInputTokens) == "number" and cachedInputTokens or nil
	local ____temp_24 = type(usage.prompt_cache_miss_tokens) == "number" and usage.prompt_cache_miss_tokens or nil
	local ____opt_18 = usage.completion_tokens_details
	return {
		inputTokens = ____inputTokens_20,
		outputTokens = ____outputTokens_21,
		totalTokens = ____temp_22,
		cachedInputTokens = ____temp_23,
		cacheMissInputTokens = ____temp_24,
		reasoningOutputTokens = type(____opt_18 and ____opt_18.reasoning_tokens) == "number" and usage.completion_tokens_details.reasoning_tokens or nil
	}
end
function ____exports.validateAgentLLMConfig(config)
	local ____opt_25 = config.customOptions
	local auxiliaryOptions = ____opt_25 and ____opt_25.auxiliaryOptions
	if isPlainRecord(auxiliaryOptions) then
		for _key in pairs(auxiliaryOptions) do
			return {success = true}
		end
	end
	return {success = false, message = "LLM 配置的 customOptions 必须包含非空 auxiliaryOptions，请检查 LLM 配置"}
end
local function normalizeContextWindow(value)
	if type(value) == "number" and value > 0 then
		return math.floor(value)
	end
	return 64000
end
local function normalizeSupportsFunctionCalling(value)
	return value == nil or value ~= 0
end
local function normalizeLLMTemperature(value)
	if type(value) == "number" then
		return math.max(
			0,
			math.min(2, value)
		)
	end
	return 0.1
end
local function normalizeLLMMaxTokens(value)
	if type(value) == "number" then
		return math.max(
			1,
			math.floor(value)
		)
	end
	return AgentConfig.AGENT_DEFAULTS.llmMaxTokens
end
local function normalizeLLMCustomOptions(value)
	if type(value) ~= "string" then
		return nil
	end
	local text = __TS__StringTrim(____exports.sanitizeUTF8(value))
	if text == "" then
		return nil
	end
	local decoded = ____exports.safeJsonDecode(text)
	return isPlainRecord(decoded) and decoded or nil
end
local function getLLMConfigRecords()
	upgradeLLMConfig()
	local rows = DB:query("select * from LLMConfig", true)
	local records = {}
	if rows and #rows > 1 then
		do
			local i = 1
			while i < #rows do
				local record = {}
				do
					local c = 0
					while c < #rows[i + 1] do
						record[rows[1][c + 1]] = rows[i + 1][c + 1]
						c = c + 1
					end
				end
				records[#records + 1] = record
				i = i + 1
			end
		end
	end
	return records
end
function ____exports.getLLMConfigSummaries()
	return __TS__ArrayFlatMap(
		getLLMConfigRecords(),
		function(____, record)
			local id = record.id
			local name = record.name
			local model = record.model
			if type(id) ~= "number" or type(name) ~= "string" or type(model) ~= "string" then
				return {}
			end
			return {{id = id, name = name, model = model, active = record.active ~= 0}}
		end
	)
end
local function parseLLMConfig(config)
	if not config then
		return {success = false, message = "LLM config not found"}
	end
	local ____config_27 = config
	local id = ____config_27.id
	local url = ____config_27.url
	local model = ____config_27.model
	local api_key = ____config_27.api_key
	if type(id) ~= "number" or type(url) ~= "string" or type(model) ~= "string" or type(api_key) ~= "string" then
		return {success = false, message = "got invalid LLM config"}
	end
	return {
		success = true,
		id = id,
		config = {
			url = url,
			model = model,
			apiKey = api_key,
			contextWindow = normalizeContextWindow(config.context_window),
			temperature = normalizeLLMTemperature(config.temperature),
			maxTokens = normalizeLLMMaxTokens(config.max_tokens),
			reasoningEffort = normalizeReasoningEffort(config.reasoning_effort),
			customOptions = normalizeLLMCustomOptions(config.custom_options),
			supportsFunctionCalling = normalizeSupportsFunctionCalling(config.supports_function_calling)
		}
	}
end
function ____exports.getLLMConfig(configId)
	local normalizedId = type(configId) == "number" and math.floor(configId) or tonumber(configId)
	if normalizedId == nil or normalizedId <= 0 then
		return {success = false, message = "LLM config is not selected"}
	end
	return parseLLMConfig(__TS__ArrayFind(
		getLLMConfigRecords(),
		function(____, record) return record.id == normalizedId end
	))
end
function ____exports.getActiveLLMConfig()
	local records = getLLMConfigRecords()
	local config = __TS__ArrayFind(
		records,
		function(____, r) return r.active ~= 0 end
	)
	if not config then
		return {success = false, message = "no active LLM config"}
	end
	return parseLLMConfig(config)
end
____exports.callLLMStream = function(messages, options, event, llmConfig)
	local callEvent
	if event.id ~= nil then
		local id = event.id
		callEvent = {
			id = nil,
			onData = function(data)
				emit("AppWS", "Send", {name = "LLMContent", id = id, data = data})
				return event.stopToken.stopped
			end,
			onCancel = function(reason)
				emit("AppWS", "Send", {name = "LLMCancel", id = id, reason = reason})
			end,
			onDone = function()
				emit("AppWS", "Send", {name = "LLMDone", id = id})
			end
		}
	else
		callEvent = event
	end
	local ____callEvent_28 = callEvent
	local onData = ____callEvent_28.onData
	local onDone = ____callEvent_28.onDone
	local ____callEvent_29 = callEvent
	local onCancel = ____callEvent_29.onCancel
	local config = llmConfig or (function()
		local configRes = ____exports.getActiveLLMConfig()
		if not configRes.success then
			if onCancel then
				onCancel(configRes.message)
			end
			return nil
		end
		return configRes.config
	end)()
	if not config then
		return {success = false, message = "no active LLM config"}
	end
	local url = config.url
	local model = config.model
	local apiKey = config.apiKey
	local fitted = ____exports.fitMessagesToContext(messages, options, config)
	if fitted.trimmed then
		____exports.Log(
			"Warn",
			(((("[Agent.Utils] callLLMStream trimmed input tokens=" .. tostring(fitted.originalTokens)) .. " budget=") .. tostring(fitted.budgetTokens)) .. " fitted=") .. tostring(fitted.fittedTokens)
		)
	end
	local stopLLM = false
	local streamStopToken = event.stopToken ~= nil and event.stopToken and event.stopToken or ({stopped = false})
	local parser = createScheduledSSEJSONParser(
		{onJSON = function(obj)
			local result = onData(obj)
			if result then
				stopLLM = true
				streamStopToken.stopped = true
				streamStopToken.reason = "LLM Stopped"
			end
		end},
		function() return streamStopToken.stopped end
	);
	(function()
		return __TS__AsyncAwaiter(function(____awaiter_resolve)
			local ____try = __TS__AsyncAwaiter(function()
				local result = __TS__Await(postLLM(
					fitted.messages,
					url,
					apiKey,
					model,
					options,
					true,
					config.customOptions,
					function(data)
						if stopLLM then
							if onCancel then
								onCancel("LLM Stopped")
								onCancel = nil
							end
							return true
						end
						parser.append(data)
						return false
					end,
					streamStopToken,
					config.studioGateway
				))
				__TS__Await(parser.finish())
				if onDone then
					onDone(result)
				end
			end)
			____try = ____try.catch(
				____try,
				function(____, e)
					return __TS__AsyncAwaiter(function()
						parser.cancel()
						stopLLM = true
						if onCancel then
							onCancel(tostring(e))
							onCancel = nil
						end
					end)
				end
			)
			__TS__Await(____try)
		end)
	end)()
	return {success = true}
end
local function mergeStreamToolCall(target, delta)
	if type(delta.id) == "string" and delta.id ~= "" then
		target.id = delta.id
	end
	if type(delta.type) == "string" and delta.type ~= "" then
		target.type = delta.type
	end
	if delta["function"] then
		if target["function"] == nil then
			target["function"] = {}
		end
		if type(delta["function"].name) == "string" and delta["function"].name ~= "" then
			target["function"].name = (target["function"].name or "") .. delta["function"].name
		end
		if type(delta["function"].arguments) == "string" and delta["function"].arguments ~= "" then
			target["function"].arguments = (target["function"].arguments or "") .. delta["function"].arguments
		end
	end
end
local function isToolCallComplete(tc)
	if type(tc.id) ~= "string" or tc.id == "" then
		return false
	end
	if not tc["function"] or type(tc["function"].name) ~= "string" or tc["function"].name == "" then
		return false
	end
	if type(tc["function"].arguments) ~= "string" or tc["function"].arguments == "" then
		return false
	end
	local args = tc["function"].arguments
	if __TS__StringCharCodeAt(args, #args - 1) ~= 125 then
		return false
	end
	local decoded = ____exports.safeJsonDecode(args)
	return decoded ~= nil
end
local function mergeStreamChoice(acc, choice, onToolCallReady, emittedToolCallIds)
	local delta = choice.delta or ({})
	local fullMessage = choice.message or ({})
	local message = acc.message
	local role = type(delta.role) == "string" and delta.role ~= "" and delta.role or (type(fullMessage.role) == "string" and fullMessage.role or nil)
	if type(role) == "string" and role ~= "" then
		message.role = role
	end
	local content = type(delta.content) == "string" and delta.content ~= "" and delta.content or (type(fullMessage.content) == "string" and fullMessage.content or nil)
	if type(content) == "string" and content ~= "" then
		message.content = (message.content or "") .. content
	end
	local reasoningContent = type(delta.reasoning_content) == "string" and delta.reasoning_content ~= "" and delta.reasoning_content or (type(fullMessage.reasoning_content) == "string" and fullMessage.reasoning_content or nil)
	if type(reasoningContent) == "string" and reasoningContent ~= "" then
		message.reasoning_content = (message.reasoning_content or "") .. reasoningContent
	end
	local toolCalls = delta.tool_calls and #delta.tool_calls > 0 and delta.tool_calls or (fullMessage.tool_calls or ({}))
	if #toolCalls > 0 then
		if message.tool_calls == nil then
			message.tool_calls = {}
		end
		do
			local i = 0
			while i < #toolCalls do
				local item = toolCalls[i + 1]
				local index = type(item.index) == "number" and item.index >= 0 and math.floor(item.index) or i
				local ____message_tool_calls_30, ____temp_31 = message.tool_calls, index + 1
				if ____message_tool_calls_30[____temp_31] == nil then
					____message_tool_calls_30[____temp_31] = {}
				end
				mergeStreamToolCall(message.tool_calls[index + 1], item)
				if onToolCallReady and emittedToolCallIds then
					local tc = message.tool_calls[index + 1]
					if isToolCallComplete(tc) and not emittedToolCallIds[tc.id] then
						emittedToolCallIds[tc.id] = true
						onToolCallReady(tc)
					end
				end
				i = i + 1
			end
		end
	end
	if type(choice.finish_reason) == "string" and choice.finish_reason ~= "" then
		acc.finish_reason = choice.finish_reason
	end
end
local function buildStreamResponse(states, model, id, created, object, providerError, usage)
	local indexes = __TS__ArraySort(
		__TS__ArrayFilter(
			__TS__ArrayMap(
				__TS__ObjectKeys(states),
				function(____, key) return __TS__Number(key) end
			),
			function(____, index) return __TS__NumberIsFinite(index) end
		),
		function(____, a, b) return a - b end
	)
	return {
		id = id,
		created = created,
		object = object,
		model = model,
		choices = __TS__ArrayMap(
			indexes,
			function(____, index)
				local state = states[index]
				return {index = index, message = {role = state.message.role or "assistant", content = state.message.content, reasoning_content = state.message.reasoning_content, tool_calls = state.message.tool_calls}, finish_reason = state.finish_reason}
			end
		),
		usage = usage,
		error = providerError
	}
end
function ____exports.callLLMStreamAggregated(messages, options, stopTokenOrConfig, llmConfig, onChunk, onToolCallReady)
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig
		local resolvedConfig = config or (function()
			local configRes = ____exports.getActiveLLMConfig()
			if not configRes.success then
				____exports.Log("Error", "[Agent.Utils] callLLMStreamAggregated config error: " .. configRes.message)
				return nil
			end
			return configRes.config
		end)()
		if not resolvedConfig then
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"})
		end
		local url = resolvedConfig.url
		local model = resolvedConfig.model
		local apiKey = resolvedConfig.apiKey
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig)
		local toolCount = __TS__ArrayIsArray(options.tools) and #options.tools or 0
		local toolChoice = type(options.tool_choice) == "string" and options.tool_choice or (options.tool_choice ~= nil and "object" or "unset")
		local ____model_36 = model
		local ____url_37 = url
		local ____temp_38 = #messages
		local ____tostring_33 = tostring
		local ____options_max_tokens_32 = options.max_tokens
		if ____options_max_tokens_32 == nil then
			____options_max_tokens_32 = "unset"
		end
		local ____tostring_33_result_39 = ____tostring_33(____options_max_tokens_32)
		local ____tostring_35 = tostring
		local ____options_temperature_34 = options.temperature
		if ____options_temperature_34 == nil then
			____options_temperature_34 = "unset"
		end
		____exports.Log(
			"Info",
			((((((((((((("[Agent.Utils] callLLMStreamAggregated request model=" .. ____model_36) .. " url=") .. ____url_37) .. " messages=") .. tostring(____temp_38)) .. " tools=") .. tostring(toolCount)) .. " tool_choice=") .. toolChoice) .. " max_tokens=") .. ____tostring_33_result_39) .. " temperature=") .. ____tostring_35(____options_temperature_34)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "")
		)
		if stopToken and stopToken.stopped then
			local reason = stopToken.reason or "request cancelled"
			____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled before request: " .. reason)
			return ____awaiter_resolve(nil, {success = false, message = reason})
		end
		local ____hasReturned, ____returnValue
		local ____try = __TS__AsyncAwaiter(function()
			local states = {}
			local emittedToolCallIds = {}
			local responseId = nil
			local responseCreated = nil
			local responseObject = nil
			local providerError
			local responseUsage
			local httpChunkCount = 0
			local rawStreamBytes = 0
			local rawStreamPreview = ""
			local sseJSONChunkCount = 0
			local choiceJSONChunkCount = 0
			local emptyChoicesChunkCount = 0
			local missingChoicesChunkCount = 0
			local parseErrorCount = 0
			local doneChunkSeen = false
			local lastJSONPreview = ""
			local parser = createScheduledSSEJSONParser(
				{
					onJSON = function(obj, raw)
						sseJSONChunkCount = sseJSONChunkCount + 1
						lastJSONPreview = previewText(raw, 500)
						if not obj or type(obj) ~= "table" then
							return
						end
						local chunk = obj
						if chunk.error then
							providerError = chunk.error
							____exports.Log(
								"Warn",
								"[Agent.Utils] callLLMStreamAggregated provider error chunk: " .. previewText(raw, 300)
							)
							return
						end
						responseId = type(chunk.id) == "string" and chunk.id or responseId
						responseCreated = type(chunk.created) == "number" and chunk.created or responseCreated
						responseObject = type(chunk.object) == "string" and chunk.object or responseObject
						if chunk.usage and type(chunk.usage) == "table" then
							responseUsage = chunk.usage
						end
						local choices = __TS__ArrayIsArray(chunk.choices) and chunk.choices or ({})
						if not __TS__ArrayIsArray(chunk.choices) then
							missingChoicesChunkCount = missingChoicesChunkCount + 1
							if missingChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then
								____exports.Log(
									"Warn",
									"[Agent.Utils] callLLMStreamAggregated chunk missing choices raw=" .. previewText(raw, 300)
								)
							end
						elseif #choices == 0 then
							emptyChoicesChunkCount = emptyChoicesChunkCount + 1
							if emptyChoicesChunkCount <= LLM_STREAM_CHUNK_DEBUG_LOG_LIMIT then
								____exports.Log(
									"Warn",
									"[Agent.Utils] callLLMStreamAggregated chunk empty choices raw=" .. previewText(raw, 300)
								)
							end
						else
							choiceJSONChunkCount = choiceJSONChunkCount + 1
						end
						do
							local i = 0
							while i < #choices do
								local choice = choices[i + 1]
								local index = type(choice.index) == "number" and choice.index or i
								if states[index] == nil then
									states[index] = {index = index, message = {role = "assistant"}}
								end
								mergeStreamChoice(states[index], choice, onToolCallReady, emittedToolCallIds)
								i = i + 1
							end
						end
						if onChunk ~= nil then
							onChunk(
								buildStreamResponse(
									states,
									model,
									responseId,
									responseCreated,
									responseObject,
									providerError,
									responseUsage
								),
								{
									id = chunk.id or "",
									created = chunk.created or 0,
									object = chunk.object or "",
									model = chunk.model or model,
									choices = choices
								}
							)
						end
					end,
					onDone = function()
						doneChunkSeen = true
					end,
					onError = function(err, context)
						parseErrorCount = parseErrorCount + 1
						____exports.Log(
							"Warn",
							(("[Agent.Utils] callLLMStreamAggregated parse error: " .. tostring(err)) .. " raw=") .. previewText(context and context.raw or "", 300)
						)
					end
				},
				function() return (stopToken and stopToken.stopped) == true end
			)
			local ____try = __TS__AsyncAwaiter(function()
				__TS__Await(postLLM(
					fitted.messages,
					url,
					apiKey,
					model,
					options,
					true,
					resolvedConfig.customOptions,
					function(data)
						if stopToken and stopToken.stopped then
							return true
						end
						httpChunkCount = httpChunkCount + 1
						rawStreamBytes = rawStreamBytes + #data
						if #rawStreamPreview < LLM_STREAM_RAW_DEBUG_MAX then
							rawStreamPreview = rawStreamPreview .. __TS__StringSlice(data, 0, LLM_STREAM_RAW_DEBUG_MAX - #rawStreamPreview)
						end
						parser.append(data)
						return false
					end,
					stopToken,
					resolvedConfig.studioGateway
				))
				__TS__Await(parser.finish())
			end)
			____try = ____try.catch(
				____try,
				function(____, e)
					return __TS__AsyncAwaiter(function()
						parser.cancel()
						error(e, 0)
					end)
				end
			)
			__TS__Await(____try)
			if sseJSONChunkCount == 0 and __TS__StringTrim(rawStreamPreview) ~= "" then
				local rawResponse = ____exports.safeJsonDecode(normalizeLLMJSONResponse(rawStreamPreview))
				if rawResponse and type(rawResponse) == "table" then
					local rawResponseObj = rawResponse
					if rawResponseObj.error then
						providerError = rawResponseObj.error
						lastJSONPreview = previewText(
							normalizeLLMJSONResponse(rawStreamPreview),
							500
						)
						____exports.Log(
							"Warn",
							"[Agent.Utils] callLLMStreamAggregated non-SSE provider error raw=" .. previewText(rawStreamPreview, 500)
						)
					end
					if rawResponseObj.usage and type(rawResponseObj.usage) == "table" then
						responseUsage = rawResponseObj.usage
					end
				end
			end
			local response = buildStreamResponse(
				states,
				model,
				responseId,
				responseCreated,
				responseObject,
				providerError,
				responseUsage
			)
			local tokenUsage = ____exports.extractLLMTokenUsage(response)
			local choiceCount = response.choices and #response.choices or 0
			local streamStats = (((((((((((((("http_chunks=" .. tostring(httpChunkCount)) .. " raw_bytes=") .. tostring(rawStreamBytes)) .. " sse_json_chunks=") .. tostring(sseJSONChunkCount)) .. " choice_chunks=") .. tostring(choiceJSONChunkCount)) .. " empty_choice_chunks=") .. tostring(emptyChoicesChunkCount)) .. " missing_choice_chunks=") .. tostring(missingChoicesChunkCount)) .. " parse_errors=") .. tostring(parseErrorCount)) .. " done=") .. (doneChunkSeen and "true" or "false")
			____exports.Log(
				"Info",
				(("[Agent.Utils] callLLMStreamAggregated decoded response choices=" .. tostring(choiceCount)) .. " ") .. streamStats
			)
			if not doneChunkSeen then
				local rawPreview = previewText(
					____exports.sanitizeUTF8(rawStreamPreview),
					1200
				)
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or ""
				local message = ((("stream incomplete: missing [DONE]; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated incomplete stream " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON)
				____hasReturned = true
				____returnValue = {
					success = false,
					message = message,
					raw = rawStreamPreview,
					response = response,
					tokenUsage = tokenUsage
				}
				return
			end
			if not response.choices or #response.choices == 0 then
				local providerMessage = providerError and providerError.message or ""
				local providerType = providerError and providerError.type or ""
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or ""
				local details = table.concat(
					__TS__ArrayFilter(
						{providerType, providerCode},
						function(____, part) return part ~= "" end
					),
					"/"
				)
				local rawPreview = previewText(
					____exports.sanitizeUTF8(rawStreamPreview),
					1200
				)
				local lastJSON = lastJSONPreview ~= "" and " last_json=" .. lastJSONPreview or ""
				local message = providerMessage ~= "" and (((((("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "")) .. "; ") .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON or ((("LLM returned no choices; " .. streamStats) .. "; raw=") .. rawPreview) .. lastJSON
				____exports.Log("Error", ((("[Agent.Utils] callLLMStreamAggregated empty choices " .. streamStats) .. " raw_preview=") .. rawPreview) .. lastJSON)
				____hasReturned = true
				____returnValue = {success = false, message = message, raw = rawStreamPreview, tokenUsage = tokenUsage}
				return
			end
			____hasReturned = true
			____returnValue = {success = true, response = response, tokenUsage = tokenUsage}
			return
		end)
		____try = ____try.catch(
			____try,
			function(____, e)
				return __TS__AsyncAwaiter(function()
					if stopToken and stopToken.stopped then
						local reason = stopToken.reason or "request cancelled"
						____exports.Log("Info", "[Agent.Utils] callLLMStreamAggregated cancelled during request: " .. reason)
						____hasReturned = true
						____returnValue = {success = false, message = reason}
						return
					end
					____exports.Log(
						"Error",
						"[Agent.Utils] callLLMStreamAggregated exception: " .. tostring(e)
					)
					____hasReturned = true
					____returnValue = {
						success = false,
						message = tostring(e)
					}
					return
				end)
			end
		)
		__TS__Await(____try)
		if ____hasReturned then
			return ____awaiter_resolve(nil, ____returnValue)
		end
	end)
end
function ____exports.callLLM(messages, options, stopTokenOrConfig, llmConfig)
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local stopToken = stopTokenOrConfig and stopTokenOrConfig.stopped ~= nil and stopTokenOrConfig or nil
		local config = stopTokenOrConfig and stopTokenOrConfig.url ~= nil and stopTokenOrConfig or llmConfig
		local resolvedConfig = config or (function()
			local configRes = ____exports.getActiveLLMConfig()
			if not configRes.success then
				____exports.Log("Error", "[Agent.Utils] callLLMOnce config error: " .. configRes.message)
				return nil
			end
			return configRes.config
		end)()
		if not resolvedConfig then
			return ____awaiter_resolve(nil, {success = false, message = "no active LLM config"})
		end
		local url = resolvedConfig.url
		local model = resolvedConfig.model
		local apiKey = resolvedConfig.apiKey
		local fitted = ____exports.fitMessagesToContext(messages, options, resolvedConfig)
		____exports.Log(
			"Info",
			((((("[Agent.Utils] callLLMOnce request model=" .. model) .. " url=") .. url) .. " messages=") .. tostring(#messages)) .. (fitted.trimmed and ((((" trimmed_tokens=" .. tostring(fitted.originalTokens)) .. "->") .. tostring(fitted.fittedTokens)) .. "/") .. tostring(fitted.budgetTokens) or "")
		)
		if stopToken and stopToken.stopped then
			local reason = stopToken.reason or "request cancelled"
			____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled before request: " .. reason)
			return ____awaiter_resolve(nil, {success = false, message = reason})
		end
		local ____hasReturned, ____returnValue
		local ____try = __TS__AsyncAwaiter(function()
			local raw = ____exports.sanitizeUTF8(__TS__Await(postLLM(
				fitted.messages,
				url,
				apiKey,
				model,
				options,
				false,
				resolvedConfig.customOptions,
				nil,
				stopToken,
				resolvedConfig.studioGateway
			)))
			local normalizedRaw = normalizeLLMJSONResponse(raw)
			____exports.Log(
				"Info",
				("[Agent.Utils] callLLMOnce raw response length=" .. tostring(#raw)) .. (#normalizedRaw ~= #raw and " normalized=" .. tostring(#normalizedRaw) or "")
			)
			local response, err = ____exports.safeJsonDecode(normalizedRaw)
			if err ~= nil or response == nil or type(response) ~= "table" then
				local rawPreview = previewText(raw)
				____exports.Log(
					"Error",
					(("[Agent.Utils] callLLMOnce invalid JSON: " .. tostring(err)) .. " raw_preview=") .. rawPreview
				)
				____hasReturned = true
				____returnValue = {
					success = false,
					message = (("invalid LLM response JSON: " .. tostring(err)) .. "; raw=") .. rawPreview,
					raw = raw
				}
				return
			end
			local responseObj = response
			local choiceCount = responseObj.choices and #responseObj.choices or 0
			____exports.Log(
				"Info",
				"[Agent.Utils] callLLMOnce decoded response choices=" .. tostring(choiceCount)
			)
			if not responseObj.choices or #responseObj.choices == 0 then
				local providerError = responseObj.error
				local providerMessage = providerError and type(providerError.message) == "string" and providerError.message or ""
				local providerType = providerError and type(providerError.type) == "string" and providerError.type or ""
				local providerCode = providerError and (type(providerError.code) == "string" or type(providerError.code) == "number") and tostring(providerError.code) or ""
				local details = table.concat(
					__TS__ArrayFilter(
						{providerType, providerCode},
						function(____, part) return part ~= "" end
					),
					"/"
				)
				local rawPreview = previewText(raw, 400)
				local message = providerMessage ~= "" and ("LLM returned no choices: " .. providerMessage) .. (details ~= "" and (" (" .. details) .. ")" or "") or "LLM returned no choices; raw=" .. rawPreview
				____exports.Log("Error", "[Agent.Utils] callLLMOnce empty choices raw_preview=" .. rawPreview)
				____hasReturned = true
				____returnValue = {success = false, message = message, raw = raw}
				return
			end
			____hasReturned = true
			____returnValue = {success = true, response = responseObj}
			return
		end)
		____try = ____try.catch(
			____try,
			function(____, e)
				return __TS__AsyncAwaiter(function()
					if stopToken and stopToken.stopped then
						local reason = stopToken.reason or "request cancelled"
						____exports.Log("Info", "[Agent.Utils] callLLMOnce cancelled during request: " .. reason)
						____hasReturned = true
						____returnValue = {success = false, message = reason}
						return
					end
					____exports.Log(
						"Error",
						"[Agent.Utils] callLLMOnce exception: " .. tostring(e)
					)
					____hasReturned = true
					____returnValue = {
						success = false,
						message = tostring(e)
					}
					return
				end)
			end
		)
		__TS__Await(____try)
		if ____hasReturned then
			return ____awaiter_resolve(nil, ____returnValue)
		end
	end)
end
return ____exports
