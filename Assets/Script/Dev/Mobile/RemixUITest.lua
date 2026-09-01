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
local projectChangedCount = 0 -- 40
local backCount = 0 -- 41
local projectFilesChanged = false -- 42
local function session() -- 44
	return { -- 44
		id = 91001, -- 45
		projectRoot = Content.assetPath, -- 46
		title = "Mobile Remix UI Test", -- 47
		kind = "main", -- 48
		rootSessionId = 91001, -- 49
		memoryScope = "main", -- 50
		workMode = "code", -- 51
		status = status, -- 52
		currentTaskId = 92001, -- 53
		currentTaskStatus = status, -- 54
		createdAt = 1, -- 55
		updatedAt = 1 -- 56
	} -- 56
end -- 44
local function detail() -- 59
	return { -- 59
		success = true, -- 60
		session = session(), -- 61
		relatedSessions = {}, -- 62
		messages = {}, -- 63
		steps = projectFilesChanged and ({{ -- 64
			id = 95001, -- 65
			sessionId = 91001, -- 66
			taskId = 92001, -- 67
			step = 1, -- 68
			tool = "edit_file", -- 69
			status = "DONE", -- 70
			reason = "updated game", -- 71
			reasoningContent = "", -- 72
			files = {{path = "init.ts", op = "write"}}, -- 73
			createdAt = 1, -- 74
			updatedAt = 2 -- 75
		}}) or ({}), -- 75
		checkpoints = {}, -- 77
		pendingQuestionnaire = questionnairePending and ({ -- 78
			id = 93001, -- 79
			sessionId = 91001, -- 80
			taskId = 92001, -- 81
			step = 1, -- 82
			status = "PENDING", -- 83
			schema = {title = "选择 Remix 方向", questions = {{ -- 84
				id = "style", -- 87
				prompt = "希望调整成哪种节奏？", -- 88
				type = "single_choice", -- 89
				required = true, -- 90
				allowOther = true, -- 91
				options = {{id = "relaxed", label = "轻松", recommended = true}, {id = "fast", label = "紧张", recommended = false}} -- 92
			}}}, -- 92
			createdAt = 1 -- 98
		}) or nil, -- 98
		hasActivePlan = false -- 100
	} -- 100
end -- 59
local services = { -- 103
	createSession = function() return { -- 104
		success = true, -- 104
		session = session() -- 104
	} end, -- 104
	getSession = function() return detail() end, -- 105
	setWorkMode = function() return {success = true} end, -- 106
	sendPrompt = function() return {success = true, sessionId = 91001, taskId = 92001} end, -- 107
	respondQuestionnaire = function(_sessionId, _questionnaireId, answers) -- 108
		respondedAnswers = answers -- 109
		questionnairePending = false -- 110
		status = "RUNNING" -- 111
		return {success = true, sessionId = 91001, taskId = 92001} -- 112
	end, -- 108
	stopSessionTask = function() -- 114
		stopCount = stopCount + 1 -- 115
		status = "STOPPED" -- 116
		return {success = true} -- 117
	end, -- 114
	getActiveLLMConfig = function() return {success = true, id = 94001, config = llmConfig} end, -- 119
	getLLMConfig = function() return {success = true, id = 94001, config = llmConfig} end, -- 120
	getLLMConfigSummaries = function() return {{id = 94001, name = "UI Test", model = "ui-test-model", active = true}} end -- 121
} -- 121
App.winSize = Size(390, 844) -- 124
thread(function() -- 125
	sleep(0.4) -- 126
	local host = startMobileRemix({ -- 127
		entry = {id = "remix-ui-test", title = "轨道花园", workDir = Content.assetPath}, -- 128
		onBack = function() return nil end, -- 129
		onPlay = function() -- 130
			playCount = playCount + 1 -- 130
		end, -- 130
		onProjectChanged = function() -- 131
			projectChangedCount = projectChangedCount + 1 -- 131
		end, -- 131
		services = services -- 132
	}) -- 132
	sleep(0.5) -- 134
	expect( -- 136
		findTagged(host, "remix-questionnaire") ~= nil, -- 136
		"questionnaire UI was not rendered" -- 136
	) -- 136
	expect( -- 137
		findTagged(host, "remix-stop") ~= nil and findTagged(host, "remix-send") == nil, -- 137
		"Questionnaire must retain only the shared Stop control" -- 137
	) -- 137
	expect( -- 138
		App:saveScreenshot("/tmp/dora-mobile-remix-questionnaire-ui") ~= "", -- 138
		"questionnaire screenshot failed" -- 138
	) -- 138
	sleep(0.25) -- 139
	local ____opt_0 = findTagged(host, "remix-question-submit") -- 139
	if ____opt_0 ~= nil then -- 139
		____opt_0:emit("Tapped") -- 141
	end -- 141
	expect(respondedAnswers == nil, "required questionnaire submitted without an answer") -- 142
	local option = findTagged(host, "remix-question-style-option-relaxed") -- 144
	expect(option ~= nil, "questionnaire choice was not rendered") -- 145
	if option ~= nil then -- 145
		option:emit("Tapped") -- 146
	end -- 146
	local ____opt_4 = findTagged(host, "remix-question-submit") -- 146
	if ____opt_4 ~= nil then -- 146
		____opt_4:emit("Tapped") -- 147
	end -- 147
	expect(respondedAnswers ~= nil, "questionnaire answer was not submitted") -- 148
	local ____expect_12 = expect -- 149
	local ____opt_8 = respondedAnswers and respondedAnswers[1] -- 149
	local ____opt_6 = ____opt_8 and ____opt_8.selectedOptionIds -- 149
	____expect_12((____opt_6 and ____opt_6[1]) == "relaxed", "questionnaire selected option mismatch") -- 149
	local stop = findTagged(host, "remix-stop") -- 151
	expect(stop ~= nil, "Stop action was not rendered after questionnaire resume") -- 152
	expect( -- 153
		findTagged(host, "remix-send") == nil and (stop and stop.width) == 82, -- 153
		"Stop must replace Send in its compact slot" -- 153
	) -- 153
	if stop ~= nil then -- 153
		stop:emit("Tapped") -- 154
	end -- 154
	expect(stopCount == 1 and status == "STOPPED", "Stop action did not stop the Agent") -- 155
	projectFilesChanged = true -- 157
	status = "DONE" -- 158
	sleep(0.35) -- 159
	local play = findTagged(host, "remix-play") -- 160
	expect(play ~= nil, "Play now action was not rendered for DONE state") -- 161
	expect( -- 162
		App:saveScreenshot("/tmp/dora-mobile-remix-done-ui") ~= "", -- 162
		"done screenshot failed" -- 162
	) -- 162
	sleep(0.25) -- 163
	if play ~= nil then -- 163
		play:emit("Tapped") -- 164
	end -- 164
	expect(playCount == 1, "Play now did not invoke the game callback") -- 165
	expect(projectChangedCount == 1, "Play now did not report changed project files exactly once") -- 166
	expect(not host.visible, "Remix host must hide before game launch") -- 167
	projectFilesChanged = false -- 169
	status = "STOPPED" -- 170
	local unchangedHost = startMobileRemix({ -- 171
		entry = {id = "remix-ui-unchanged", title = "未修改项目", workDir = Content.assetPath}, -- 172
		onBack = function() -- 173
			backCount = backCount + 1 -- 173
		end, -- 173
		onPlay = function() return nil end, -- 174
		onProjectChanged = function() -- 175
			projectChangedCount = projectChangedCount + 1 -- 175
		end, -- 175
		services = services -- 176
	}) -- 176
	sleep(0.2) -- 178
	local ____opt_19 = findTagged(unchangedHost, "remix-back") -- 178
	if ____opt_19 ~= nil then -- 178
		____opt_19:emit("Tapped") -- 179
	end -- 179
	expect(backCount == 1, "Back did not close the unchanged Remix session") -- 180
	expect(projectChangedCount == 1, "Unchanged Remix incorrectly reported project changes") -- 181
	Content:save(resultPath, "passed questionnaire=1 stop=1 play=1 unchangedBack=1\n") -- 183
	host:removeFromParent(true) -- 184
end) -- 125
return ____exports -- 125