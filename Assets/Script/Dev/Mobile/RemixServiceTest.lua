-- [ts]: RemixServiceTest.ts
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
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____Session = require("Agent.Session") -- 2
local createSession = ____Session.createSession -- 2
local deleteSessionsByProjectRoot = ____Session.deleteSessionsByProjectRoot -- 2
local getSession = ____Session.getSession -- 2
local setWorkMode = ____Session.setWorkMode -- 2
local ____Remix = require("Dev.Mobile.Remix") -- 3
local startMobileRemix = ____Remix.startMobileRemix -- 3
local projectRoot = Path( -- 6
	Content.writablePath, -- 6
	"mobile-remix-service-test-" .. tostring(App.runningTime) -- 6
) -- 6
local resultPath = Path(Content.writablePath, "dora-mobile-remix-service.result") -- 7
local function expect(condition, message) -- 8
	if not condition then -- 8
		error( -- 9
			__TS__New(Error, message), -- 9
			0 -- 9
		) -- 9
	end -- 9
end -- 8
local function findTagged(root, tag) -- 11
	if root.tag == tag then -- 11
		return root -- 12
	end -- 12
	local found -- 13
	root:eachChild(function(child) -- 14
		found = findTagged(child, tag) -- 14
		return found ~= nil -- 14
	end) -- 14
	return found -- 15
end -- 11
thread(function() -- 17
	if not Content:mkdir(projectRoot) then -- 17
		error( -- 18
			__TS__New(Error, "Cannot create test project"), -- 18
			0 -- 18
		) -- 18
	end -- 18
	local created = createSession(projectRoot, "Manual mode service test") -- 19
	if not created.success then -- 19
		error( -- 20
			__TS__New(Error, created.message), -- 20
			0 -- 20
		) -- 20
	end -- 20
	local sessionId = created.session.id -- 21
	expect(created.session.workMode == "code", "New session must use the Web IDE default code mode") -- 22
	local host = startMobileRemix({ -- 23
		entry = {id = "remix-service-test", title = "Service regression", workDir = projectRoot}, -- 24
		onBack = function() return nil end, -- 25
		onPlay = function() return nil end -- 26
	}) -- 26
	sleep(0.5) -- 28
	if not findTagged(host, "remix-scene") then -- 28
		error( -- 29
			__TS__New(Error, "Real service Remix scene did not render"), -- 29
			0 -- 29
		) -- 29
	end -- 29
	local input = findTagged(host, "remix-input") -- 30
	if input then -- 30
		local ____opt_0 = findTagged(host, "remix-mode-plan") -- 30
		if ____opt_0 ~= nil then -- 30
			____opt_0:emit("Tapped") -- 32
		end -- 32
		local shared = getSession(sessionId) -- 33
		expect(shared.success and shared.session.workMode == "plan", "Mobile mode did not reach the shared Web IDE session") -- 34
		expect( -- 35
			setWorkMode(sessionId, "code").success, -- 35
			"Shared service could not select code" -- 35
		) -- 35
		sleep(0.35) -- 36
		expect( -- 37
			findTagged(host, "remix-input") == input, -- 37
			"External mode change replaced input" -- 37
		) -- 37
		local ____opt_2 = findTagged(host, "remix-mode-plan") -- 37
		if ____opt_2 ~= nil then -- 37
			____opt_2:emit("Tapped") -- 38
		end -- 38
		shared = getSession(sessionId) -- 39
		expect(shared.success and shared.session.workMode == "plan" and #shared.messages == 0, "Mode change sent a prompt or diverged from shared session") -- 40
		for ____, text in ipairs({ -- 41
			"a", -- 41
			"b", -- 41
			"c", -- 41
			"中文", -- 41
			"🙂" -- 41
		}) do -- 41
			input:emit("TextInput", text) -- 41
		end -- 41
		if findTagged(host, "remix-input") ~= input then -- 41
			error( -- 42
				__TS__New(Error, "Typing replaced the IME node"), -- 42
				0 -- 42
			) -- 42
		end -- 42
		local label = findTagged(host, "remix-input-text") -- 43
		expect(label.text == "abc中文🙂", "Continuous text input lost characters") -- 44
		input:emit("KeyDown", "BackSpace") -- 45
		expect(label.text == "abc中文", "Backspace broke UTF-8 text") -- 46
		input:emit("TextEditing", "ni") -- 47
		expect(label.text == "abc中文ni", "Composition preview missing") -- 48
		input:emit("TextEditing", "nihao") -- 49
		expect(label.text == "abc中文nihao", "Composition preview duplicated") -- 50
		input:emit("TextInput", "你好") -- 51
		expect(label.text == "abc中文你好", "Composition commit duplicated preview") -- 52
		input:emit("TextEditing", "cancel") -- 53
		input:emit("TextEditing", "") -- 54
		expect(label.text == "abc中文你好", "Composition cancellation lost committed text") -- 55
		input:emit("TextEditing", "pending") -- 56
		host:emit("SuspendLocalUI") -- 57
		host.visible = false -- 58
		input:emit("TextInput", "blocked") -- 59
		host.visible = true -- 60
		host:emit("ResumeLocalUI") -- 61
		local resumedLabel = findTagged(host, "remix-input-text") -- 62
		expect(resumedLabel.text == "abc中文你好", "UI takeover lost draft or retained unfinished composition") -- 63
	end -- 63
	host:removeFromParent(true) -- 65
	local reopened = startMobileRemix({ -- 66
		entry = {id = "remix-service-test", title = "Service regression", workDir = projectRoot}, -- 66
		onBack = function() return nil end, -- 66
		onPlay = function() return nil end -- 66
	}) -- 66
	local saved = getSession(sessionId) -- 67
	expect(saved.success and saved.session.workMode == "plan", "Reopening changed saved mode") -- 68
	reopened:removeFromParent(true) -- 69
	deleteSessionsByProjectRoot(projectRoot) -- 70
	Content:remove(projectRoot) -- 71
	Content:save( -- 72
		resultPath, -- 72
		("passed realServices=1 scene=1 polling=1 input=" .. tostring(input and 1 or 0)) .. " suspendResumeDraft=1 sharedManualMode=1 savedMode=1 noPrompts=1\n" -- 72
	) -- 72
end) -- 17
return ____exports -- 17