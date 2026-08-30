-- [ts]: RemixUITest.ts
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
local Size = ____Dora.Size -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Remix = require("Dev.Mobile.Remix") -- 5
local startMobileRemix = ____Remix.startMobileRemix -- 5
local resultPath = "/tmp/dora-mobile-remix-ui.result" -- 7
local function expect(condition, message) -- 9
	if not condition then -- 9
		error( -- 10
			__TS__New(Error, message), -- 10
			0 -- 10
		) -- 10
	end -- 10
end -- 9
local function findTagged(root, tag) -- 13
	if root.tag == tag then -- 13
		return root -- 14
	end -- 14
	local result -- 15
	root:eachChild(function(child) -- 16
		local found = findTagged(child, tag) -- 17
		if not found then -- 17
			return false -- 18
		end -- 18
		result = found -- 19
		return true -- 20
	end) -- 16
	return result -- 22
end -- 13
local llmConfig = { -- 25
	url = "https://example.invalid", -- 26
	model = "ui-test-model", -- 27
	apiKey = "test", -- 28
	contextWindow = 64000, -- 29
	temperature = 0.1, -- 30
	maxTokens = 1024, -- 31
	supportsFunctionCalling = true -- 32
} -- 32
local status = "WAITING_USER" -- 35
local questionnairePending = true -- 36
local respondedAnswers -- 37
local stopCount = 0 -- 38
local playCount = 0 -- 39
local function session() -- 41
	return { -- 41
		id = 91001, -- 42
		projectRoot = Content.assetPath, -- 43
		title = "Mobile Remix UI Test", -- 44
		kind = "main", -- 45
		rootSessionId = 91001, -- 46
		memoryScope = "main", -- 47
		workMode = "code", -- 48
		status = status, -- 49
		currentTaskId = 92001, -- 50
		currentTaskStatus = status, -- 51
		createdAt = 1, -- 52
		updatedAt = 1 -- 53
	} -- 53
end -- 41
local function detail() -- 56
	return { -- 56
		success = true, -- 57
		session = session(), -- 58
		relatedSessions = {}, -- 59
		messages = {}, -- 60
		steps = {}, -- 61
		checkpoints = {}, -- 62
		pendingQuestionnaire = questionnairePending and ({ -- 63
			id = 93001, -- 64
			sessionId = 91001, -- 65
			taskId = 92001, -- 66
			step = 1, -- 67
			status = "PENDING", -- 68
			schema = {title = "选择 Remix 方向", questions = {{ -- 69
				id = "style", -- 72
				prompt = "希望调整成哪种节奏？", -- 73
				type = "single_choice", -- 74
				required = true, -- 75
				allowOther = true, -- 76
				options = {{id = "relaxed", label = "轻松", recommended = true}, {id = "fast", label = "紧张", recommended = false}} -- 77
			}}}, -- 77
			createdAt = 1 -- 83
		}) or nil, -- 83
		hasActivePlan = false -- 85
	} -- 85
end -- 56
local services = { -- 88
	createSession = function() return { -- 89
		success = true, -- 89
		session = session() -- 89
	} end, -- 89
	getSession = function() return detail() end, -- 90
	setWorkMode = function() return {success = true} end, -- 91
	sendPrompt = function() return {success = true, sessionId = 91001, taskId = 92001} end, -- 92
	respondQuestionnaire = function(_sessionId, _questionnaireId, answers) -- 93
		respondedAnswers = answers -- 94
		questionnairePending = false -- 95
		status = "RUNNING" -- 96
		return {success = true, sessionId = 91001, taskId = 92001} -- 97
	end, -- 93
	stopSessionTask = function() -- 99
		stopCount = stopCount + 1 -- 100
		status = "STOPPED" -- 101
		return {success = true} -- 102
	end, -- 99
	getActiveLLMConfig = function() return {success = true, id = 94001, config = llmConfig} end, -- 104
	getLLMConfig = function() return {success = true, id = 94001, config = llmConfig} end, -- 105
	getLLMConfigSummaries = function() return {{id = 94001, name = "UI Test", model = "ui-test-model", active = true}} end -- 106
} -- 106
App.winSize = Size(390, 844) -- 109
thread(function() -- 110
	sleep(0.4) -- 111
	local host = startMobileRemix({ -- 112
		entry = {id = "remix-ui-test", title = "轨道花园", workDir = Content.assetPath}, -- 113
		onBack = function() return nil end, -- 114
		onPlay = function() -- 115
			playCount = playCount + 1 -- 115
		end, -- 115
		services = services -- 116
	}) -- 116
	sleep(0.5) -- 118
	expect( -- 120
		findTagged(host, "remix-questionnaire") ~= nil, -- 120
		"questionnaire UI was not rendered" -- 120
	) -- 120
	expect( -- 121
		findTagged(host, "remix-stop") ~= nil and findTagged(host, "remix-send") == nil, -- 121
		"Questionnaire must retain only the shared Stop control" -- 121
	) -- 121
	expect( -- 122
		App:saveScreenshot("/tmp/dora-mobile-remix-questionnaire-ui") ~= "", -- 122
		"questionnaire screenshot failed" -- 122
	) -- 122
	sleep(0.25) -- 123
	local ____opt_0 = findTagged(host, "remix-question-submit") -- 123
	if ____opt_0 ~= nil then -- 123
		____opt_0:emit("Tapped") -- 125
	end -- 125
	expect(respondedAnswers == nil, "required questionnaire submitted without an answer") -- 126
	local option = findTagged(host, "remix-question-style-option-relaxed") -- 128
	expect(option ~= nil, "questionnaire choice was not rendered") -- 129
	if option ~= nil then -- 129
		option:emit("Tapped") -- 130
	end -- 130
	local ____opt_4 = findTagged(host, "remix-question-submit") -- 130
	if ____opt_4 ~= nil then -- 130
		____opt_4:emit("Tapped") -- 131
	end -- 131
	expect(respondedAnswers ~= nil, "questionnaire answer was not submitted") -- 132
	local ____expect_12 = expect -- 133
	local ____opt_8 = respondedAnswers and respondedAnswers[1] -- 133
	local ____opt_6 = ____opt_8 and ____opt_8.selectedOptionIds -- 133
	____expect_12((____opt_6 and ____opt_6[1]) == "relaxed", "questionnaire selected option mismatch") -- 133
	local stop = findTagged(host, "remix-stop") -- 135
	expect(stop ~= nil, "Stop action was not rendered after questionnaire resume") -- 136
	expect( -- 137
		findTagged(host, "remix-send") == nil and (stop and stop.width) == 82, -- 137
		"Stop must replace Send in its compact slot" -- 137
	) -- 137
	if stop ~= nil then -- 137
		stop:emit("Tapped") -- 138
	end -- 138
	expect(stopCount == 1 and status == "STOPPED", "Stop action did not stop the Agent") -- 139
	status = "DONE" -- 141
	sleep(0.35) -- 142
	local play = findTagged(host, "remix-play") -- 143
	expect(play ~= nil, "Play now action was not rendered for DONE state") -- 144
	expect( -- 145
		App:saveScreenshot("/tmp/dora-mobile-remix-done-ui") ~= "", -- 145
		"done screenshot failed" -- 145
	) -- 145
	sleep(0.25) -- 146
	if play ~= nil then -- 146
		play:emit("Tapped") -- 147
	end -- 147
	expect(playCount == 1, "Play now did not invoke the game callback") -- 148
	expect(not host.visible, "Remix host must hide before game launch") -- 149
	Content:save(resultPath, "passed questionnaire=1 stop=1 play=1\n") -- 151
	host:removeFromParent(true) -- 152
end) -- 110
return ____exports -- 110