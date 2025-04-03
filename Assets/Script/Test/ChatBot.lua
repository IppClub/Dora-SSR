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
local ImGui = require("ImGui") -- 3
local ____flow = require("flow") -- 5
local Node = ____flow.Node -- 5
local Flow = ____flow.Flow -- 5
local url = Buffer(512) -- 12
url.text = "https://api.deepseek.com/chat/completions" -- 13
local apiKey = Buffer(256) -- 14
local model = Buffer(128) -- 15
model.text = "deepseek-chat" -- 16
local function callLLM(messages, url, apiKey, model, receiver) -- 18
	local data = {model = model, messages = messages, stream = true} -- 19
	return __TS__New( -- 24
		__TS__Promise, -- 24
		function(____, resolve, reject) -- 24
			thread(function() -- 25
				local jsonStr = json.dump(data) -- 26
				if jsonStr ~= nil then -- 26
					local res = HttpClient:postAsync( -- 28
						url, -- 28
						{"Authorization: Bearer " .. apiKey}, -- 28
						jsonStr, -- 30
						10, -- 30
						receiver -- 30
					) -- 30
					if res ~= nil then -- 30
						resolve(nil, res) -- 32
					else -- 32
						reject(nil, "failed to get http response") -- 34
					end -- 34
				end -- 34
			end) -- 25
		end -- 24
	) -- 24
end -- 18
local root = DNode() -- 41
local llmWorking = false -- 47
local ChatNode = __TS__Class() -- 49
ChatNode.name = "ChatNode" -- 49
__TS__ClassExtends(ChatNode, Node) -- 49
function ChatNode.prototype.prep(self, shared) -- 50
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 50
		return ____awaiter_resolve( -- 50
			nil, -- 50
			__TS__New( -- 51
				__TS__Promise, -- 51
				function(____, resolve) -- 51
					root:slot( -- 52
						"Input", -- 52
						function(message) -- 52
							local ____shared_messages_0 = shared.messages -- 52
							____shared_messages_0[#____shared_messages_0 + 1] = {role = "user", content = message} -- 53
							resolve( -- 54
								nil, -- 54
								__TS__ArraySlice(shared.messages, -10) -- 54
							) -- 54
						end -- 52
					) -- 52
				end -- 51
			) -- 51
		) -- 51
	end) -- 51
end -- 50
function ChatNode.prototype.exec(self, messages) -- 58
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 58
		return ____awaiter_resolve( -- 58
			nil, -- 58
			__TS__New( -- 59
				__TS__Promise, -- 59
				function(____, resolve, reject) -- 59
					return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 59
						local str = "" -- 60
						root:emit("Output", "LLM: ") -- 61
						llmWorking = true -- 62
						local ____try = __TS__AsyncAwaiter(function() -- 62
							__TS__Await(callLLM( -- 64
								messages, -- 64
								url.text, -- 64
								apiKey.text, -- 64
								model.text, -- 64
								function(data) -- 64
									local done = string.match(data, "data:%s*(%b[])") -- 65
									if done == "[DONE]" then -- 65
										resolve(nil, str) -- 67
										return -- 68
									end -- 68
									for item in string.gmatch(data, "data:%s*(%b{})") do -- 70
										local res = json.load(item) -- 71
										if res then -- 71
											str = str .. res.choices[1].delta.content -- 73
										end -- 73
									end -- 73
									root:emit("Update", "LLM: " .. str) -- 76
								end -- 64
							)) -- 64
							llmWorking = false -- 78
						end) -- 78
						__TS__Await(____try.catch( -- 63
							____try, -- 63
							function(____, e) -- 63
								llmWorking = false -- 80
								reject(nil, e) -- 81
							end -- 81
						)) -- 81
					end) -- 81
				end -- 59
			) -- 59
		) -- 59
	end) -- 59
end -- 58
function ChatNode.prototype.post(self, shared, _prepRes, execRes) -- 85
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 85
		if execRes ~= "" then -- 85
			local ____shared_messages_1 = shared.messages -- 85
			____shared_messages_1[#____shared_messages_1 + 1] = {role = "system", content = execRes} -- 87
		end -- 87
		return ____awaiter_resolve(nil, nil) -- 87
	end) -- 87
end -- 85
local chatNode = __TS__New(ChatNode, 2, 1) -- 93
chatNode:next(chatNode) -- 94
local flow = __TS__New(Flow, chatNode) -- 96
local runFlow -- 97
runFlow = function() -- 97
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 97
		local chatInfo = {messages = {}} -- 98
		local ____try = __TS__AsyncAwaiter(function() -- 98
			__TS__Await(flow:run(chatInfo)) -- 102
		end) -- 102
		__TS__Await(____try.catch( -- 101
			____try, -- 101
			function(____, err) -- 101
				Log("Error", err) -- 104
				runFlow() -- 105
			end -- 105
		)) -- 105
	end) -- 105
end -- 97
runFlow() -- 108
local logs = {} -- 110
local inputBuffer = Buffer(500) -- 111
local function ChatButton() -- 113
	if ImGui.InputText("Chat", inputBuffer, {"EnterReturnsTrue"}) then -- 113
		local command = inputBuffer.text -- 115
		if command ~= "" then -- 115
			logs[#logs + 1] = "User: " .. command -- 117
			root:emit("Input", command) -- 118
		end -- 118
		inputBuffer.text = "" -- 120
	end -- 120
end -- 113
root:loop(function() -- 124
	ImGui.SetNextWindowSize( -- 125
		Vec2(400, 300), -- 125
		"FirstUseEver" -- 125
	) -- 125
	ImGui.Begin( -- 126
		"LLM Chat", -- 126
		function() -- 126
			ImGui.InputText("URL", url) -- 127
			ImGui.InputText("API Key", apiKey) -- 128
			ImGui.InputText("Model", model) -- 129
			ImGui.Separator() -- 130
			ImGui.BeginChild( -- 131
				"LogArea", -- 131
				Vec2(0, -40), -- 131
				function() -- 131
					for ____, log in ipairs(logs) do -- 132
						ImGui.TextWrapped(log) -- 133
					end -- 133
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 133
						ImGui.SetScrollHereY(1) -- 136
					end -- 136
				end -- 131
			) -- 131
			if llmWorking then -- 131
				ImGui.BeginDisabled(function() -- 140
					ChatButton() -- 141
				end) -- 140
			else -- 140
				ChatButton() -- 144
			end -- 144
		end -- 126
	) -- 126
	return false -- 147
end) -- 124
root:slot( -- 150
	"Output", -- 150
	function(message) -- 150
		logs[#logs + 1] = message -- 151
	end -- 150
) -- 150
root:slot( -- 154
	"Update", -- 154
	function(message) -- 154
		logs[#logs] = message -- 155
	end -- 154
) -- 154
return ____exports -- 154