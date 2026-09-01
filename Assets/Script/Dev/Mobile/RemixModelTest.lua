-- [ts]: RemixModelTest.ts
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
local Content = ____Dora.Content -- 1
local ____RemixModel = require("Dev.Mobile.RemixModel") -- 2
local buildQuestionnaireAnswers = ____RemixModel.buildQuestionnaireAnswers -- 3
local canLeaveRemix = ____RemixModel.canLeaveRemix -- 4
local canPlayRemix = ____RemixModel.canPlayRemix -- 5
local compactAgentActivity = ____RemixModel.compactAgentActivity -- 6
local isQuestionAnswered = ____RemixModel.isQuestionAnswered -- 7
local resolveRemixPhase = ____RemixModel.resolveRemixPhase -- 8
local resolveRemixThinkingStatus = ____RemixModel.resolveRemixThinkingStatus
local resolveRemixWorkMode = ____RemixModel.resolveRemixWorkMode -- 9
local resultPath = "/tmp/dora-mobile-remix-model.result" -- 13
local function expect(condition, message) -- 14
	if not condition then -- 14
		error( -- 14
			__TS__New(Error, message), -- 14
			0 -- 14
		) -- 14
	end -- 14
end -- 14
do -- 14
	local function ____catch(____error) -- 14
		Content:save( -- 68
			resultPath, -- 68
			"failed: " .. tostring(____error) -- 68
		) -- 68
	end -- 68
	local ____try, ____hasReturned = pcall(function() -- 68
		expect( -- 17
			resolveRemixWorkMode() == "code", -- 17
			"Missing session must default to code" -- 17
		) -- 17
		expect( -- 18
			resolveRemixWorkMode({kind = "main"}) == "code", -- 18
			"Missing preference must default to code" -- 18
		) -- 18
		expect( -- 19
			resolveRemixWorkMode({kind = "main", workMode = "invalid"}) == "code", -- 19
			"Invalid preference must default to code" -- 19
		) -- 19
		expect( -- 20
			resolveRemixWorkMode({kind = "main", workMode = "plan"}) == "plan", -- 20
			"Saved plan mode must be restored" -- 20
		) -- 20
		expect( -- 21
			resolveRemixWorkMode({kind = "main", workMode = "code"}) == "code", -- 21
			"Saved code mode must be restored" -- 21
		) -- 21
		expect( -- 22
			resolveRemixWorkMode({kind = "sub", workMode = "plan"}) == "code", -- 22
			"Sub sessions must match Web IDE code mode" -- 22
		) -- 22
		expect( -- 23
			resolveRemixPhase({status = "RUNNING", workMode = "plan", hasActivePlan = false}) == "planning", -- 23
			"plan phase mismatch" -- 23
		) -- 23
		expect( -- 24
			resolveRemixPhase({status = "DONE", workMode = "plan", hasActivePlan = true}) == "plan-ready", -- 24
			"plan-ready phase mismatch" -- 24
		) -- 24
		expect( -- 25
			resolveRemixPhase({status = "DONE", workMode = "plan", hasActivePlan = false}) == "plan-ready", -- 25
			"plan completion must not require a plan file" -- 25
		) -- 25
		expect( -- 26
			resolveRemixPhase({status = "IDLE", workMode = "plan", hasActivePlan = true}) == "idle", -- 26
			"old plan files must not gate a new request" -- 26
		) -- 26
		expect( -- 27
			resolveRemixPhase({status = "RUNNING", workMode = "code", hasActivePlan = true}) == "working", -- 27
			"code phase mismatch" -- 27
		) -- 27
		expect( -- 28
			resolveRemixPhase({status = "WAITING_USER", workMode = "plan", hasActivePlan = false}) == "waiting", -- 28
			"waiting phase mismatch" -- 28
		) -- 28
		expect( -- 29
			resolveRemixPhase({status = "FAILED", workMode = "code", hasActivePlan = true}) == "failed", -- 29
			"failed phase mismatch" -- 29
		) -- 29
		expect( -- 30
			resolveRemixPhase({status = "STOPPED", workMode = "code", hasActivePlan = true}) == "stopped", -- 30
			"stopped phase mismatch" -- 30
		) -- 30
		expect( -- 31
			resolveRemixPhase({status = "DONE", workMode = "code", hasActivePlan = false}) == "done", -- 31
			"done phase mismatch" -- 31
		) -- 31
		expect( -- 32
			resolveRemixPhase({status = "IDLE", workMode = "plan", hasActivePlan = false}) == "idle", -- 32
			"idle phase mismatch" -- 32
		) -- 32
		expect( -- 33
			not canLeaveRemix("RUNNING") and not canLeaveRemix("WAITING_USER"), -- 33
			"active session must block leaving" -- 33
		) -- 33
		expect( -- 34
			canLeaveRemix("STOPPED") and canLeaveRemix("FAILED") and canLeaveRemix("DONE"), -- 34
			"terminal session must allow leaving" -- 34
		) -- 34
		expect( -- 35
			canPlayRemix("DONE") and not canPlayRemix("RUNNING") and not canPlayRemix("STOPPED"), -- 35
			"play gate mismatch" -- 35
		) -- 35
		local textQuestion = { -- 37
			id = "name", -- 37
			prompt = "Name", -- 37
			type = "text", -- 37
			required = true, -- 37
			allowOther = false -- 37
		} -- 37
		local choiceQuestion = { -- 38
			id = "style", -- 39
			prompt = "Style", -- 40
			type = "single_choice", -- 41
			required = true, -- 42
			allowOther = true, -- 43
			options = {{id = "fast", label = "Fast"}, {id = "calm", label = "Calm"}} -- 44
		} -- 44
		local optionalQuestion = { -- 46
			id = "notes", -- 46
			prompt = "Notes", -- 46
			type = "text", -- 46
			required = false, -- 46
			allowOther = false -- 46
		} -- 46
		expect( -- 47
			not isQuestionAnswered(textQuestion, {}, "   "), -- 47
			"blank required text must be rejected" -- 47
		) -- 47
		expect( -- 48
			isQuestionAnswered(textQuestion, {}, " Dora "), -- 48
			"required text must be accepted" -- 48
		) -- 48
		expect( -- 49
			not isQuestionAnswered(choiceQuestion, {}, ""), -- 49
			"empty required choice must be rejected" -- 49
		) -- 49
		expect( -- 50
			isQuestionAnswered(choiceQuestion, {"fast"}, ""), -- 50
			"required choice must be accepted" -- 50
		) -- 50
		local answers = buildQuestionnaireAnswers({textQuestion, choiceQuestion, optionalQuestion}, {style = {"fast"}}, {name = " Dora ", notes = "   "}) -- 51
		expect(#answers == 3, "questionnaire answer count mismatch") -- 56
		expect(answers[1].status == "answered" and answers[1].text == "Dora", "text answer normalization mismatch") -- 57
		local ____temp_2 = answers[2].status == "answered" -- 58
		if ____temp_2 then -- 58
			local ____opt_0 = answers[2].selectedOptionIds -- 58
			____temp_2 = (____opt_0 and ____opt_0[1]) == "fast" -- 58
		end -- 58
		expect(____temp_2, "choice answer mismatch") -- 58
		expect(answers[3].status == "skipped", "optional blank answer must be skipped") -- 59
		expect( -- 61
			string.sub( -- 61
				compactAgentActivity("edit_file", "update player speed", false), -- 61
				1, -- 61
				12 -- 61
			) == "Editing game", -- 61
			"activity summary mismatch" -- 61
		) -- 61
		expect( -- 62
			compactAgentActivity("search_files", "", true) == "正在查找资料", -- 62
			"search activity label mismatch" -- 62
		) -- 62
		expect( -- 63
			compactAgentActivity("build", "", false) == "Validating game", -- 63
			"build activity label mismatch" -- 63
		) -- 63
		expect( -- 64
			compactAgentActivity("unknown", "", false) == "Working", -- 64
			"fallback activity label mismatch" -- 64
		) -- 64
		expect( -- 65
			#compactAgentActivity( -- 65
				"read_file", -- 65
				string.rep( -- 65
					"x", -- 65
					math.floor(100) -- 65
				), -- 65
				false -- 65
			) == #"Reading project · " + 72, -- 65
			"activity reason must be truncated" -- 65
		) -- 65
		local thinkingStep = {
			id = 1,
			taskId = 7,
			step = 3,
			tool = "message",
			status = "RUNNING",
			reason = "",
			reasoningContent = "先分析布局\r\n再核对状态栏\n"
		}
		expect(
			resolveRemixThinkingStatus({thinkingStep}, 7) == "再核对状态栏",
			"thinking status must use the last non-empty line"
		)
		expect(
			resolveRemixThinkingStatus({{
				id = 1, taskId = 7, step = 3, tool = "message", status = "RUNNING",
				reason = "开始输出正文", reasoningContent = thinkingStep.reasoningContent
			}}, 7) == nil,
			"content output must restore the regular status"
		)
		expect(
			resolveRemixThinkingStatus({{
				id = 1, taskId = 7, step = 3, tool = "message", status = "DONE",
				reason = "", reasoningContent = thinkingStep.reasoningContent
			}}, 7) == nil,
			"completed step must restore the regular status"
		)
		expect(
			resolveRemixThinkingStatus({thinkingStep, {
				id = 2, taskId = 7, step = 4, tool = "message", status = "RUNNING",
				reason = "", reasoningContent = ""
			}}, 7) == nil,
			"next loop must replace stale reasoning"
		)
		expect(
			resolveRemixThinkingStatus({thinkingStep}, 8) == nil,
			"other task reasoning must be ignored"
		)
		Content:save(resultPath, "passed") -- 66
	end) -- 66
	if not ____try then -- 66
		____catch(____hasReturned) -- 66
	end -- 66
end -- 66
return ____exports -- 66
