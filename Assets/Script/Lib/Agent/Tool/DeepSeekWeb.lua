-- [ts]: DeepSeekWeb.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Director = ____Dora.Director -- 2
local HttpClient = ____Dora.HttpClient -- 2
local once = ____Dora.once -- 2
local ____Utils = require("Agent.Utils") -- 3
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 3
local getLLMConfigRecords = ____Utils.getLLMConfigRecords -- 3
local ____NetworkSafety = require("Agent.Tool.NetworkSafety") -- 4
local isSafePublicHttpUrl = ____NetworkSafety.isSafePublicHttpUrl -- 4
local DEEPSEEK_ORIGIN = "https://api.deepseek.com" -- 6
____exports.WEB_REQUEST_TIMEOUT_SECONDS = 30 -- 7
local function isOfficialEndpoint(url) -- 9
	return url == DEEPSEEK_ORIGIN .. "/chat/completions" or url == DEEPSEEK_ORIGIN .. "/v1/chat/completions" -- 10
end -- 9
local function resolveDeepSeekWebApiKey(config) -- 13
	if config.studioGateway then -- 13
		return nil -- 14
	end -- 14
	local url = string.gsub( -- 15
		__TS__StringTrim(config.url), -- 15
		"/+$", -- 15
		"" -- 15
	) -- 15
	if not isOfficialEndpoint(url) then -- 15
		return nil -- 16
	end -- 16
	local apiKey = __TS__StringTrim(config.apiKey) -- 17
	return apiKey ~= "" and apiKey or nil -- 18
end -- 13
local function findApiKey() -- 21
	local active = getActiveLLMConfig() -- 22
	local ____active_success_0 -- 23
	if active.success then -- 23
		____active_success_0 = resolveDeepSeekWebApiKey(active.config) -- 23
	else -- 23
		____active_success_0 = nil -- 23
	end -- 23
	local activeKey = ____active_success_0 -- 23
	if activeKey ~= nil then -- 23
		return activeKey -- 24
	end -- 24
	for ____, record in ipairs(getLLMConfigRecords()) do -- 25
		do -- 25
			if type(record.url) ~= "string" or type(record.api_key) ~= "string" then -- 25
				goto __continue8 -- 26
			end -- 26
			local url = string.gsub( -- 27
				__TS__StringTrim(record.url), -- 27
				"/+$", -- 27
				"" -- 27
			) -- 27
			if isOfficialEndpoint(url) and __TS__StringTrim(record.api_key) ~= "" then -- 27
				return __TS__StringTrim(record.api_key) -- 28
			end -- 28
		end -- 28
		::__continue8:: -- 28
	end -- 28
	return nil -- 30
end -- 21
local function request(apiKey, isCancelled, endpoint, payload) -- 33
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 33
		if isCancelled() then -- 33
			return ____awaiter_resolve(nil, nil) -- 33
		end -- 33
		local body = safeJsonEncode(payload) -- 37
		if body == nil then -- 37
			return ____awaiter_resolve(nil, nil) -- 37
		end -- 37
		local headers = {"Authorization: Bearer " .. apiKey, "Content-Type: application/json"} -- 39
		local start = App.runningTime -- 40
		local raw = __TS__Await(__TS__New( -- 41
			__TS__Promise, -- 41
			function(____, resolve) -- 41
				local requestId = 0 -- 42
				local finished = false -- 43
				local responseReady = false -- 44
				local response -- 45
				Director.systemScheduler:schedule(function() -- 46
					local cancelled = isCancelled() or App.runningTime - start >= ____exports.WEB_REQUEST_TIMEOUT_SECONDS -- 47
					if not cancelled and not responseReady then -- 47
						return false -- 48
					end -- 48
					finished = true -- 49
					if cancelled and requestId ~= 0 and not responseReady then -- 49
						HttpClient:cancel(requestId) -- 50
					end -- 50
					local ____resolve_2 = resolve -- 51
					local ____cancelled_1 -- 51
					if cancelled then -- 51
						____cancelled_1 = nil -- 51
					else -- 51
						____cancelled_1 = response -- 51
					end -- 51
					____resolve_2(nil, ____cancelled_1) -- 51
					return true -- 52
				end) -- 46
				Director.systemScheduler:schedule(once(function() -- 54
					if finished then -- 54
						return -- 55
					end -- 55
					if isCancelled() then -- 55
						responseReady = true -- 57
						return -- 58
					end -- 58
					requestId = HttpClient:post( -- 60
						(DEEPSEEK_ORIGIN .. "/v1/tools/") .. endpoint, -- 60
						headers, -- 60
						body, -- 60
						____exports.WEB_REQUEST_TIMEOUT_SECONDS, -- 60
						function(data) -- 60
							if finished then -- 60
								return -- 61
							end -- 61
							response = data -- 63
							responseReady = true -- 64
						end -- 60
					) -- 60
					if requestId == 0 then -- 60
						responseReady = true -- 66
					end -- 66
				end)) -- 54
			end -- 41
		)) -- 41
		if raw == nil or #raw > 2 * 1024 * 1024 then -- 41
			return ____awaiter_resolve(nil, nil) -- 41
		end -- 41
		local value = safeJsonDecode(raw) -- 70
		return ____awaiter_resolve( -- 70
			nil, -- 70
			type(value) == "table" and value or nil -- 71
		) -- 71
	end) -- 71
end -- 33
local function failure(message) -- 74
	return {success = false, message = message} -- 75
end -- 74
local unavailable = "No official DeepSeek API configuration found. Add a DeepSeek configuration with an API key in Agent settings." -- 78
function ____exports.searchWeb(input, limit, isCancelled) -- 80
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 80
		local apiKey = findApiKey() -- 81
		if apiKey == nil then -- 81
			return ____awaiter_resolve( -- 81
				nil, -- 81
				failure(unavailable) -- 82
			) -- 82
		end -- 82
		local query = type(input) == "string" and __TS__StringTrim(input) or "" -- 83
		local length = utf8.len(query) -- 84
		if length == nil or length < 1 or length > 128 then -- 84
			return ____awaiter_resolve( -- 84
				nil, -- 84
				failure("query must contain 1–128 characters") -- 85
			) -- 85
		end -- 85
		local ____limit_3 = limit -- 86
		if ____limit_3 == nil then -- 86
			____limit_3 = 5 -- 86
		end -- 86
		local count = ____limit_3 -- 86
		if type(count) ~= "number" or math.floor(count) ~= count or count < 1 or count > 10 then -- 86
			return ____awaiter_resolve( -- 86
				nil, -- 86
				failure("count must be between 1 and 10") -- 87
			) -- 87
		end -- 87
		local result = __TS__Await(request(apiKey, isCancelled, "search", {query = query, count = count})) -- 88
		if not result or not __TS__ArrayIsArray(result.results) then -- 88
			return ____awaiter_resolve( -- 88
				nil, -- 88
				failure("DeepSeek web search failed or returned an invalid response.") -- 89
			) -- 89
		end -- 89
		local results = __TS__ArrayMap( -- 90
			__TS__ArrayFilter( -- 90
				__TS__ArraySlice(result.results, 0, count), -- 90
				function(____, item) return type(item) == "table" and type(item.url) == "string" end -- 91
			), -- 91
			function(____, item) return { -- 92
				title = item.title, -- 93
				url = item.url, -- 94
				summary = type(item.summary) == "string" and clipTextToTokenBudget(item.summary, 350) or item.snippet, -- 95
				date = item.date, -- 96
				rerank_score = item.rerank_score -- 97
			} end -- 97
		) -- 97
		return ____awaiter_resolve(nil, {success = true, results = results}) -- 97
	end) -- 97
end -- 80
function ____exports.readWebPage(input, isCancelled) -- 102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 102
		local apiKey = findApiKey() -- 103
		if apiKey == nil then -- 103
			return ____awaiter_resolve( -- 103
				nil, -- 103
				failure(unavailable) -- 104
			) -- 104
		end -- 104
		local url = type(input) == "string" and __TS__StringTrim(input) or "" -- 105
		local authority = string.match(url, "^[Hh][Tt][Tt][Pp][Ss]?://([^/?#]+)") -- 106
		if #url > 8192 or authority == nil or __TS__StringIncludes(authority, "@") or not isSafePublicHttpUrl(url) then -- 106
			return ____awaiter_resolve( -- 106
				nil, -- 106
				failure("url must be a public HTTP or HTTPS URL without credentials (up to 8192 bytes)") -- 108
			) -- 108
		end -- 108
		local result = __TS__Await(request(apiKey, isCancelled, "fetch", {url = url})) -- 110
		if not result or type(result.content) ~= "string" or result.content == "" then -- 110
			return ____awaiter_resolve( -- 110
				nil, -- 110
				failure("DeepSeek could not retrieve readable page content.") -- 112
			) -- 112
		end -- 112
		local content = clipTextToTokenBudget(result.content, 4000) -- 114
		return ____awaiter_resolve(nil, { -- 114
			success = true, -- 115
			url = url, -- 115
			title = result.title, -- 115
			content = content, -- 115
			truncated = content ~= result.content -- 115
		}) -- 115
	end) -- 115
end -- 102
return ____exports -- 102