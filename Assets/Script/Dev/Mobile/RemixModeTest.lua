-- [ts]: RemixModeTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Remix = require("Dev.Mobile.Remix") -- 4
local startMobileRemix = ____Remix.startMobileRemix -- 4
local function expect(condition, message) -- 6
	if not condition then -- 6
		error( -- 6
			__TS__New(Error, message), -- 6
			0 -- 6
		) -- 6
	end -- 6
end -- 6
local function find(root, tag) -- 7
	if root.tag == tag then -- 7
		return root -- 8
	end -- 8
	local found -- 9
	root:eachChild(function(child) -- 10
		found = find(child, tag) -- 10
		return found ~= nil -- 10
	end) -- 10
	return found -- 11
end -- 7
local session = { -- 13
	id = 91901, -- 14
	projectRoot = Content.assetPath, -- 14
	title = "Manual modes", -- 14
	kind = "main", -- 14
	rootSessionId = 91901, -- 14
	memoryScope = "main", -- 15
	workMode = "code", -- 15
	status = "IDLE", -- 15
	createdAt = 1, -- 15
	updatedAt = 1 -- 15
} -- 15
local config = { -- 17
	url = "https://example.invalid", -- 17
	model = "test", -- 17
	apiKey = "test", -- 17
	contextWindow = 64000, -- 17
	temperature = 0.1, -- 17
	maxTokens = 1024, -- 17
	supportsFunctionCalling = true -- 17
} -- 17
local changes = 0 -- 18
local rejectMode = false -- 19
local rejectSend = false -- 20
local sent = {} -- 21
local services = { -- 22
	createSession = function() return {success = true, session = session} end, -- 23
	getSession = function() return { -- 24
		success = true, -- 24
		session = session, -- 24
		messages = {}, -- 24
		steps = {}, -- 24
		checkpoints = {}, -- 24
		relatedSessions = {}, -- 24
		hasActivePlan = false -- 24
	} end, -- 24
	setWorkMode = function(_id, mode) -- 25
		changes = changes + 1 -- 26
		if rejectMode then -- 26
			return {success = false, message = "Mode rejected"} -- 27
		end -- 27
		session.workMode = mode -- 28
		return {success = true} -- 29
	end, -- 25
	sendPrompt = function(_id, text, _tools, mode) -- 31
		if rejectSend then -- 31
			return {success = false, message = "Send rejected"} -- 32
		end -- 32
		sent[#sent + 1] = {text = text, mode = mode} -- 33
		session.status = "DONE" -- 34
		return {success = true, sessionId = session.id, taskId = 92901} -- 35
	end, -- 31
	respondQuestionnaire = function() return {success = false, message = "Not expected"} end, -- 37
	stopSessionTask = function() return nil end, -- 38
	getActiveLLMConfig = function() return {success = true, id = 94901, config = config} end, -- 39
	getLLMConfig = function() return {success = true, id = 94901, config = config} end, -- 40
	getLLMConfigSummaries = function() return {{id = 94901, name = "Test", model = "test", active = true}} end -- 41
} -- 41
thread(function() -- 43
	local host = startMobileRemix({ -- 44
		entry = {id = "mode-test", title = "手动模式回归", workDir = Content.assetPath}, -- 44
		services = services, -- 44
		onBack = function() return nil end, -- 44
		onPlay = function() return nil end -- 44
	}) -- 44
	do -- 44
		local function ____catch(____error) -- 44
			Content:save( -- 86
				"/tmp/dora-remix-mode.result", -- 86
				"failed: " .. tostring(____error) -- 86
			) -- 86
		end -- 86
		local ____try, ____hasReturned = pcall(function() -- 86
			local function tap(tag) -- 46
				local node = find(host, tag) -- 46
				expect(node ~= nil, "Missing " .. tag) -- 46
				if node ~= nil then -- 46
					node:emit("Tapped") -- 46
				end -- 46
			end -- 46
			local input = find(host, "remix-input") -- 47
			local function label() -- 48
				return find(host, "remix-input-text") -- 48
			end -- 48
			expect(changes == 0 and session.workMode == "code", "Opening changed the saved mode") -- 49
			input:emit("TextInput", "直接执行") -- 50
			tap("remix-send") -- 50
			input:emit("TextInput", "继续执行") -- 51
			tap("remix-send") -- 51
			expect(#sent == 2 and sent[1].mode == "code" and sent[2].mode == "code", "Code requests forced planning") -- 52
			input:emit("TextInput", "保留草稿") -- 53
			input:emit("TextEditing", "ni") -- 53
			tap("remix-mode-plan") -- 54
			expect(#sent == 2 and session.workMode == "plan", "Switching must not send a request") -- 55
			expect( -- 56
				find(host, "remix-input") == input and label().text == "保留草稿ni", -- 56
				"Mode switch lost input/composition" -- 56
			) -- 56
			tap("remix-send") -- 57
			expect(#sent == 2, "Uncommitted composition was sent") -- 57
			input:emit("TextInput", "你") -- 58
			tap("remix-send") -- 58
			expect(sent[3].mode == "plan" and sent[3].text == "保留草稿你", (("Plan send changed mode or prompt: " .. sent[3].mode) .. " / ") .. sent[3].text) -- 59
			expect( -- 60
				find(host, "remix-start") == nil, -- 60
				"Mandatory start gate remains" -- 60
			) -- 60
			input:emit("TextInput", "继续讨论") -- 61
			tap("remix-send") -- 61
			expect(sent[4].mode == "plan", "Plan mode reset after a reply") -- 62
			input:emit("TextInput", "失败后保留") -- 63
			rejectMode = true -- 63
			tap("remix-mode-code") -- 63
			expect( -- 64
				session.workMode == "plan" and label().text == "失败后保留", -- 64
				"Rejected mode switch changed mode/draft" -- 64
			) -- 64
			rejectMode = false -- 65
			rejectSend = true -- 65
			tap("remix-send") -- 65
			expect( -- 66
				#sent == 4 and label().text == "失败后保留", -- 66
				"Rejected send lost draft" -- 66
			) -- 66
			rejectSend = false -- 66
			local before = changes -- 67
			for ____, status in ipairs({"RUNNING", "WAITING_USER"}) do -- 68
				session.status = status -- 69
				sleep(0.3) -- 69
				local ____opt_2 = find(host, "remix-mode-code") -- 69
				expect(not (____opt_2 and ____opt_2.touchEnabled), "Busy mode control was enabled") -- 70
				tap("remix-mode-code") -- 71
				local ____opt_4 = find(host, "remix-send") -- 71
				if ____opt_4 ~= nil then -- 71
					____opt_4:emit("Tapped") -- 71
				end -- 71
			end -- 71
			session.status = "DONE" -- 73
			session.currentTaskFinalizing = true -- 73
			sleep(0.3) -- 73
			tap("remix-mode-code") -- 74
			local ____opt_6 = find(host, "remix-send") -- 74
			if ____opt_6 ~= nil then -- 74
				____opt_6:emit("Tapped") -- 74
			end -- 74
			session.currentTaskFinalizing = false -- 75
			session.currentTaskStatus = "RUNNING" -- 75
			tap("remix-mode-code") -- 76
			local ____opt_8 = find(host, "remix-send") -- 76
			if ____opt_8 ~= nil then -- 76
				____opt_8:emit("Tapped") -- 76
			end -- 76
			session.currentTaskStatus = "DONE" -- 76
			host.visible = false -- 77
			tap("remix-mode-code") -- 77
			local ____opt_10 = find(host, "remix-send") -- 77
			if ____opt_10 ~= nil then -- 77
				____opt_10:emit("Tapped") -- 77
			end -- 77
			host.visible = true -- 77
			expect(changes == before and #sent == 4, "Busy/hidden controls changed state") -- 78
			host:removeFromParent(true) -- 79
			host = startMobileRemix({ -- 80
				entry = {id = "mode-test", title = "手动模式回归", workDir = Content.assetPath}, -- 80
				services = services, -- 80
				onBack = function() return nil end, -- 80
				onPlay = function() return nil end -- 80
			}) -- 80
			expect(changes == before and session.workMode == "plan", "Reopening did not preserve plan mode") -- 81
			tap("remix-mode-code") -- 82
			local ____opt_12 = find(host, "remix-input") -- 82
			if ____opt_12 ~= nil then -- 82
				____opt_12:emit("TextInput", "手动执行") -- 82
			end -- 82
			tap("remix-send") -- 82
			expect(sent[5].mode == "code" and sent[5].text == "手动执行", "Manual code mode requires plan files or injected prompt") -- 83
			sleep(0.3) -- 84
			App:saveScreenshot("/tmp/dora-remix-manual-mode") -- 84
			sleep(0.3) -- 84
			Content:save("/tmp/dora-remix-mode.result", "passed defaultCode=1 repeatedCode=1 repeatedPlan=1 manualSwitch=1 exactPrompt=1 savedMode=1 draftIME=1 rejectedActions=1 busyFinalizingHidden=1 noStartGate=1\n") -- 85
		end) -- 85
		if not ____try then -- 85
			____catch(____hasReturned) -- 85
		end -- 85
	end -- 85
	host:removeFromParent(true) -- 87
end) -- 43
return ____exports -- 43