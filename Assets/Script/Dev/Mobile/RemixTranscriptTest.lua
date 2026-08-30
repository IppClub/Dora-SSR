-- [ts]: RemixTranscriptTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Vec2 = ____Dora.Vec2 -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local tolua = ____Dora.tolua -- 1
local ____Remix = require("Dev.Mobile.Remix") -- 2
local startMobileRemix = ____Remix.startMobileRemix -- 2
local result = "/tmp/dora-remix-transcript-test.result" -- 5
local session = { -- 6
	id = 99158, -- 6
	projectRoot = Content.writablePath, -- 6
	title = "Transcript test", -- 6
	kind = "main", -- 7
	rootSessionId = 99158, -- 7
	memoryScope = "main", -- 7
	status = "RUNNING", -- 7
	workMode = "code", -- 7
	currentTaskId = 99200, -- 7
	createdAt = 1, -- 7
	updatedAt = 1 -- 7
} -- 7
local messages = {} -- 8
do -- 8
	local i = 1 -- 9
	while i <= 8 do -- 9
		messages[#messages + 1] = { -- 9
			id = i, -- 9
			sessionId = session.id, -- 9
			role = i % 2 == 0 and "assistant" or "user", -- 9
			content = (("## 消息 " .. tostring(i)) .. "\n") .. string.rep( -- 10
				"这是完整长消息，用于验证换行、动态高度和历史滚动。\n", -- 10
				math.floor(8) -- 10
			), -- 10
			createdAt = 1, -- 10
			updatedAt = 1 -- 10
		} -- 10
		i = i + 1 -- 9
	end -- 9
end -- 9
local step = { -- 11
	id = 99001, -- 11
	sessionId = session.id, -- 11
	taskId = 99200, -- 11
	step = 1, -- 11
	tool = "build", -- 11
	status = "RUNNING", -- 11
	reason = "原始进度", -- 11
	reasoningContent = "DO_NOT_DISPLAY_PRIVATE_REASONING", -- 11
	createdAt = 1, -- 11
	updatedAt = 1 -- 11
} -- 11
local function detail() -- 12
	return { -- 12
		success = true, -- 12
		session = session, -- 12
		messages = messages, -- 12
		steps = {step}, -- 12
		checkpoints = {}, -- 12
		relatedSessions = {}, -- 12
		hasActivePlan = false -- 12
	} -- 12
end -- 12
local function unavailable() -- 13
	return {success = false, message = "Test does not use a model"} -- 13
end -- 13
local services = { -- 14
	createSession = function() return {success = true, session = session} end, -- 15
	getSession = detail, -- 15
	setWorkMode = function() return {success = true} end, -- 15
	sendPrompt = unavailable, -- 16
	respondQuestionnaire = unavailable, -- 16
	stopSessionTask = function() return nil end, -- 16
	getActiveLLMConfig = unavailable, -- 17
	getLLMConfig = unavailable, -- 17
	getLLMConfigSummaries = function() return {} end -- 17
} -- 17
local function find(root, tag) -- 19
	if root.tag == tag then -- 19
		return root -- 20
	end -- 20
	local found -- 21
	root:eachChild(function(n) -- 22
		found = find(n, tag) -- 22
		return found ~= nil -- 22
	end) -- 22
	return found -- 22
end -- 19
local function text(root) -- 24
	local ____opt_0 = tolua.cast(root, "Label") -- 24
	local value = ____opt_0 and ____opt_0.text or "" -- 25
	root:eachChild(function(n) -- 26
		value = value .. text(n) -- 26
		return false -- 26
	end) -- 26
	return value -- 26
end -- 24
local function expect(ok, message) -- 28
	if not ok then -- 28
		Content:save(result, "failed " .. message) -- 28
		error( -- 28
			__TS__New(Error, message), -- 28
			0 -- 28
		) -- 28
	end -- 28
end -- 28
thread(function() -- 31
	local host = startMobileRemix({ -- 32
		entry = {id = "transcript-test", title = "工作展示回归", workDir = Content.writablePath}, -- 32
		onBack = function() return nil end, -- 32
		onPlay = function() return nil end, -- 32
		services = services -- 32
	}) -- 32
	host.tag = "remix-transcript-test" -- 33
	sleep(0.4) -- 34
	local input = find(host, "remix-input") -- 35
	local inputLabel = find(host, "remix-input-text") -- 36
	local scroll = find(host, "remix-scroll") -- 37
	expect(scroll ~= nil and scroll.viewSize.height > scroll.area.height, "missing scrollable history") -- 38
	expect( -- 39
		__TS__StringIncludes( -- 39
			text(host), -- 39
			"消息 1" -- 39
		), -- 39
		"old messages truncated" -- 39
	) -- 39
	expect( -- 40
		not __TS__StringIncludes( -- 40
			text(host), -- 40
			"DO_NOT_DISPLAY_PRIVATE_REASONING" -- 40
		), -- 40
		"private reasoning exposed" -- 40
	) -- 40
	expect( -- 41
		math.abs(scroll.offset.y - (scroll.viewSize.height - scroll.area.height)) < 2, -- 41
		"initial list not at latest" -- 41
	) -- 41
	input:emit("TextInput", "草稿") -- 42
	input:emit("TextEditing", "ni") -- 42
	step.reason = "同一步骤更新了进度" -- 43
	step.result = {progress = 0.5, message = "验证进行中"} -- 43
	sleep(0.4) -- 44
	expect( -- 45
		__TS__StringIncludes( -- 45
			text(host), -- 45
			"同一步骤更新了进度" -- 45
		) and __TS__StringIncludes( -- 45
			text(host), -- 45
			"50%" -- 45
		), -- 45
		"same-count progress did not update" -- 45
	) -- 45
	expect( -- 46
		find(host, "remix-input") == input and inputLabel.text == "草稿ni", -- 46
		"progress reset input/composition" -- 46
	) -- 46
	expect( -- 47
		math.abs(scroll.offset.y - (scroll.viewSize.height - scroll.area.height)) < 2, -- 47
		"update failed to follow latest" -- 47
	) -- 47
	scroll.area:emit( -- 48
		"MouseWheel", -- 48
		Vec2(0, 12) -- 48
	) -- 48
	local offset = scroll.offset.y -- 49
	messages[#messages + 1] = { -- 50
		id = 9, -- 50
		sessionId = session.id, -- 50
		role = "assistant", -- 50
		content = string.rep( -- 50
			"新的追加消息\n", -- 50
			math.floor(8) -- 50
		), -- 50
		createdAt = 2, -- 50
		updatedAt = 2 -- 50
	} -- 50
	sleep(0.4) -- 51
	expect( -- 52
		math.abs(scroll.offset.y - offset) < 2, -- 52
		"new message stole reading position" -- 52
	) -- 52
	expect( -- 53
		find(host, "remix-latest").visible, -- 53
		"new-content hint missing" -- 53
	) -- 53
	find(host, "remix-latest"):emit("Tapped") -- 54
	expect( -- 55
		math.abs(scroll.offset.y - (scroll.viewSize.height - scroll.area.height)) < 2, -- 55
		"latest action did not reach bottom" -- 55
	) -- 55
	messages[9].content = "消息原位变更，不增加数量" -- 56
	step.status = "DONE" -- 57
	session.status = "DONE" -- 57
	sleep(0.4) -- 58
	expect( -- 59
		__TS__StringIncludes( -- 59
			text(host), -- 59
			"消息原位变更，不增加数量" -- 59
		), -- 59
		"same-count message change stale" -- 59
	) -- 59
	expect( -- 60
		find(host, "remix-play") ~= nil, -- 60
		"completion action missing" -- 60
	) -- 60
	expect( -- 61
		find(host, "remix-input") == input and inputLabel.text == "草稿ni", -- 61
		"completion reset input/composition" -- 61
	) -- 61
	input:emit("TextInput", "你好") -- 62
	expect(inputLabel.text == "草稿你好", "composition commit incorrect after update") -- 63
	host:slot( -- 64
		"TestAfterRun", -- 64
		function() -- 64
			messages[9].content = "运行之后仍持续更新" -- 64
		end -- 64
	) -- 64
	App:saveScreenshot("/tmp/dora-remix-transcript-fixed") -- 65
	Content:save(result, "passed sameStep=1 messageMutation=1 autoScroll=1 readingAnchor=1 inputIdentity=1 composition=1 privateReasoningHidden=1\n") -- 66
end) -- 31
return ____exports -- 31