-- [ts]: RemixIntegrationTest.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local AgentSession = require("Agent.Session") -- 2
local ____Utils = require("Agent.Utils") -- 3
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 3
local resultPath = "/tmp/dora-mobile-remix-integration.result" -- 5
local projectRoot = "/tmp/dora-mobile-remix-integration-project" -- 6
thread(function() -- 8
	Content:save(resultPath, "running") -- 9
	Content:mkdir(projectRoot) -- 10
	Content:save( -- 11
		Path(projectRoot, "init.lua"), -- 11
		"return function() end\n" -- 11
	) -- 11
	AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 12
	local created = AgentSession.createSession(projectRoot, "Mobile Remix Integration Test") -- 13
	if not created.success then -- 13
		Content:save(resultPath, "failed: " .. created.message) -- 15
		return -- 16
	end -- 16
	local config = getActiveLLMConfig() -- 18
	if not config.success then -- 18
		Content:save(resultPath, "skipped: no active LLM config") -- 20
		AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 21
		return -- 22
	end -- 22
	AgentSession.setWorkMode(created.session.id, "plan") -- 24
	local sent = AgentSession.sendPrompt( -- 25
		created.session.id, -- 26
		"请只分析这个最小 Dora 项目，制定并提交一个不修改文件的简短测试计划。不要进入 Code 模式。", -- 27
		nil, -- 28
		"plan", -- 29
		config.id, -- 30
		config.config -- 31
	) -- 31
	if not sent.success then -- 31
		Content:save(resultPath, "failed: " .. sent.message) -- 34
		AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 35
		return -- 36
	end -- 36
	local planReady = false -- 38
	do -- 38
		local i = 0 -- 39
		while i < 120 do -- 39
			do -- 39
				sleep(0.5) -- 40
				local detail = AgentSession.getSession(created.session.id) -- 41
				if not detail.success then -- 41
					goto __continue7 -- 42
				end -- 42
				local assistantMessages = #__TS__ArrayFilter( -- 43
					detail.messages, -- 43
					function(____, message) return message.role == "assistant" end -- 43
				) -- 43
				if detail.session.status == "DONE" and detail.hasActivePlan and assistantMessages > 0 then -- 43
					planReady = true -- 45
					break -- 46
				end -- 46
				if detail.session.status == "FAILED" or detail.session.status == "STOPPED" then -- 46
					Content:save(resultPath, "failed: status=" .. detail.session.status) -- 49
					return -- 50
				end -- 50
			end -- 50
			::__continue7:: -- 50
			i = i + 1 -- 39
		end -- 39
	end -- 39
	if not planReady then -- 39
		AgentSession.stopSessionTask(created.session.id) -- 54
		Content:save(resultPath, "failed: timed out waiting for an active plan") -- 55
		return -- 56
	end -- 56
	local codeSent = AgentSession.sendPrompt( -- 58
		created.session.id, -- 59
		"开始 Code 模式执行已确认计划：只把 init.lua 改成返回一个函数，该函数打印 mobile-remix-integration-ok；然后读取文件确认修改。", -- 60
		nil, -- 61
		"code", -- 62
		config.id, -- 63
		config.config -- 64
	) -- 64
	if not codeSent.success then -- 64
		Content:save(resultPath, "failed: code start: " .. codeSent.message) -- 67
		return -- 68
	end -- 68
	do -- 68
		local i = 0 -- 70
		while i < 180 do -- 70
			do -- 70
				sleep(0.5) -- 71
				local detail = AgentSession.getSession(created.session.id) -- 72
				if not detail.success then -- 72
					goto __continue15 -- 73
				end -- 73
				if detail.session.status == "DONE" then -- 73
					local source = Content:load(Path(projectRoot, "init.lua")) -- 75
					local assistantMessages = #__TS__ArrayFilter( -- 76
						detail.messages, -- 76
						function(____, message) return message.role == "assistant" end -- 76
					) -- 76
					if source ~= nil and (string.match(source, "mobile%-remix%-integration%-ok")) ~= nil and assistantMessages >= 2 then -- 76
						Content:save( -- 78
							resultPath, -- 78
							(((("passed: plan-to-code status=" .. detail.session.status) .. " messages=") .. tostring(#detail.messages)) .. " steps=") .. tostring(#detail.steps) -- 78
						) -- 78
						return -- 79
					end -- 79
					Content:save(resultPath, "failed: code completed without the expected file change") -- 81
					return -- 82
				end -- 82
				if detail.session.status == "FAILED" or detail.session.status == "STOPPED" then -- 82
					Content:save(resultPath, "failed: code status=" .. detail.session.status) -- 85
					return -- 86
				end -- 86
			end -- 86
			::__continue15:: -- 86
			i = i + 1 -- 70
		end -- 70
	end -- 70
	AgentSession.stopSessionTask(created.session.id) -- 89
	Content:save(resultPath, "failed: timed out waiting for Code completion") -- 90
end) -- 8
return ____exports -- 8