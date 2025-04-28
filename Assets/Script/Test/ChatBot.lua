-- [ts]: ChatBot.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local HttpClient = ____Dora.HttpClient -- 2
local json = ____Dora.json -- 2
local thread = ____Dora.thread -- 2
local Buffer = ____Dora.Buffer -- 2
local Vec2 = ____Dora.Vec2 -- 2
local DNode = ____Dora.Node -- 2
local Log = ____Dora.Log -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local ImGui = require("ImGui") -- 3
local ____flow = require("Agent.flow") -- 5
local Node = ____flow.Node -- 5
local Flow = ____flow.Flow -- 5
local Config = require("Config") -- 6
if not DB:existDB("llm") then -- 6
	local dbPath = Path(Content.writablePath, "llm.db") -- 15
	DB:exec(("ATTACH DATABASE '" .. dbPath) .. "' AS llm") -- 16
	Director.entry:slot( -- 17
		"Cleanup", -- 17
		function() return DB:exec("DETACH DATABASE llm") end -- 17
	) -- 17
end -- 17
local config = Config( -- 20
	"llm", -- 20
	"url", -- 20
	"model", -- 20
	"apiKey", -- 20
	"output" -- 20
) -- 20
config:load() -- 21
local url = Buffer(512) -- 23
if type(config.url) == "string" then -- 23
	url.text = config.url -- 25
else -- 25
	config.url = "https://api.deepseek.com/chat/completions" -- 27
	url.text = "https://api.deepseek.com/chat/completions" -- 27
end -- 27
local apiKey = Buffer(256) -- 29
if type(config.apiKey) == "string" then -- 29
	apiKey.text = config.apiKey -- 31
end -- 31
local model = Buffer(128) -- 33
if type(config.model) == "string" then -- 33
	model.text = config.model -- 35
else -- 35
	config.model = "deepseek-chat" -- 37
	model.text = "deepseek-chat" -- 37
end -- 37
local function callLLM(messages, url, apiKey, model, receiver) -- 45
	local data = {model = model, messages = messages, stream = true} -- 46
	return __TS__New( -- 51
		__TS__Promise, -- 51
		function(____, resolve, reject) -- 51
			thread(function() -- 52
				local jsonStr = json.dump(data) -- 53
				if jsonStr ~= nil then -- 53
					local res = HttpClient:postAsync( -- 55
						url, -- 55
						{"Authorization: Bearer " .. apiKey}, -- 55
						jsonStr, -- 57
						10, -- 57
						receiver -- 57
					) -- 57
					if res ~= nil then -- 57
						resolve(nil, res) -- 59
					else -- 59
						reject(nil, "failed to get http response") -- 61
					end -- 61
				end -- 61
			end) -- 52
		end -- 51
	) -- 51
end -- 45
local root = DNode() -- 68
local llmWorking = false -- 74
local ChatNode = __TS__Class() -- 76
ChatNode.name = "ChatNode" -- 76
__TS__ClassExtends(ChatNode, Node) -- 76
function ChatNode.prototype.prep(self, shared) -- 77
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 77
		return ____awaiter_resolve( -- 77
			nil, -- 77
			__TS__New( -- 78
				__TS__Promise, -- 78
				function(____, resolve) -- 78
					root:slot( -- 79
						"Input", -- 79
						function(message) -- 79
							local ____shared_messages_0 = shared.messages -- 79
							____shared_messages_0[#____shared_messages_0 + 1] = {role = "user", content = message} -- 80
							resolve( -- 81
								nil, -- 81
								__TS__ArraySlice(shared.messages, -10) -- 81
							) -- 81
						end -- 79
					) -- 79
				end -- 78
			) -- 78
		) -- 78
	end) -- 78
end -- 77
function ChatNode.prototype.exec(self, messages) -- 85
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 85
		return ____awaiter_resolve( -- 85
			nil, -- 85
			__TS__New( -- 86
				__TS__Promise, -- 86
				function(____, resolve, reject) -- 86
					return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 86
						local str = "" -- 87
						root:emit("Output", "LLM: ") -- 88
						llmWorking = true -- 89
						local ____try = __TS__AsyncAwaiter(function() -- 89
							__TS__Await(callLLM( -- 91
								messages, -- 91
								url.text, -- 91
								apiKey.text, -- 91
								model.text, -- 91
								function(data) -- 91
									local done = string.match(data, "data:%s*(%b[])") -- 92
									if done == "[DONE]" then -- 92
										resolve(nil, str) -- 94
										return -- 95
									end -- 95
									for item in string.gmatch(data, "data:%s*(%b{})") do -- 97
										local res = json.load(item) -- 98
										if res then -- 98
											str = str .. res.choices[1].delta.content -- 100
										end -- 100
									end -- 100
									root:emit("Update", "LLM: " .. str) -- 103
								end -- 91
							)) -- 91
							llmWorking = false -- 105
						end) -- 105
						__TS__Await(____try.catch( -- 90
							____try, -- 90
							function(____, e) -- 90
								llmWorking = false -- 107
								reject(nil, e) -- 108
							end -- 108
						)) -- 108
					end) -- 108
				end -- 86
			) -- 86
		) -- 86
	end) -- 86
end -- 85
function ChatNode.prototype.post(self, shared, _prepRes, execRes) -- 112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 112
		if execRes ~= "" then -- 112
			local ____shared_messages_1 = shared.messages -- 112
			____shared_messages_1[#____shared_messages_1 + 1] = {role = "system", content = execRes} -- 114
		end -- 114
		return ____awaiter_resolve(nil, nil) -- 114
	end) -- 114
end -- 112
local chatNode = __TS__New(ChatNode, 2, 1) -- 120
chatNode:next(chatNode) -- 121
local flow = __TS__New(Flow, chatNode) -- 123
local runFlow -- 124
runFlow = function() -- 124
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 124
		local chatInfo = {messages = {}} -- 125
		local ____try = __TS__AsyncAwaiter(function() -- 125
			__TS__Await(flow:run(chatInfo)) -- 129
		end) -- 129
		__TS__Await(____try.catch( -- 128
			____try, -- 128
			function(____, err) -- 128
				Log("Error", err) -- 131
				runFlow() -- 132
			end -- 132
		)) -- 132
	end) -- 132
end -- 124
runFlow() -- 135
local logs = {} -- 137
local inputBuffer = Buffer(500) -- 138
local function ChatButton() -- 140
	if ImGui.InputText("Chat", inputBuffer, {"EnterReturnsTrue"}) then -- 140
		local command = inputBuffer.text -- 142
		if command ~= "" then -- 142
			logs[#logs + 1] = "User: " .. command -- 144
			root:emit("Input", command) -- 145
		end -- 145
		inputBuffer.text = "" -- 147
	end -- 147
end -- 140
local inputFlags = {"Password"} -- 151
root:loop(function() -- 152
	ImGui.SetNextWindowSize( -- 153
		Vec2(400, 300), -- 153
		"FirstUseEver" -- 153
	) -- 153
	ImGui.Begin( -- 154
		"LLM Chat", -- 154
		function() -- 154
			if ImGui.InputText("URL", url) then -- 154
				config.url = url.text -- 156
			end -- 156
			if ImGui.InputText("API Key", apiKey, inputFlags) then -- 156
				config.apiKey = apiKey.text -- 159
			end -- 159
			if ImGui.InputText("Model", model) then -- 159
				config.model = model.text -- 162
			end -- 162
			ImGui.Separator() -- 164
			ImGui.BeginChild( -- 165
				"LogArea", -- 165
				Vec2(0, -40), -- 165
				function() -- 165
					for ____, log in ipairs(logs) do -- 166
						ImGui.TextWrapped(log) -- 167
					end -- 167
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 167
						ImGui.SetScrollHereY(1) -- 170
					end -- 170
				end -- 165
			) -- 165
			if llmWorking then -- 165
				ImGui.BeginDisabled(function() -- 174
					ChatButton() -- 175
				end) -- 174
			else -- 174
				ChatButton() -- 178
			end -- 178
		end -- 154
	) -- 154
	return false -- 181
end) -- 152
root:slot( -- 184
	"Output", -- 184
	function(message) -- 184
		logs[#logs + 1] = message -- 185
	end -- 184
) -- 184
root:slot( -- 188
	"Update", -- 188
	function(message) -- 188
		logs[#logs] = message -- 189
	end -- 188
) -- 188
return ____exports -- 188