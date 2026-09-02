-- [ts]: RemixModel.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
____exports.resolveRemixWorkMode = function(session) return (session and session.kind) == "main" and session.workMode == "plan" and "plan" or "code" end -- 7
____exports.resolveRemixPhase = function(state) -- 16
	if state.status == "FAILED" then -- 16
		return "failed" -- 17
	end -- 17
	if state.status == "STOPPED" then -- 17
		return "stopped" -- 18
	end -- 18
	if state.status == "WAITING_USER" then -- 18
		return "waiting" -- 19
	end -- 19
	if state.status == "RUNNING" then -- 19
		return state.workMode == "plan" and "planning" or "working" -- 20
	end -- 20
	if state.status == "DONE" then -- 20
		return state.workMode == "plan" and "plan-ready" or "done" -- 21
	end -- 21
	return "idle" -- 22
end -- 16
____exports.canLeaveRemix = function(status) return status ~= "RUNNING" and status ~= "WAITING_USER" end -- 25
____exports.canPlayRemix = function(status) return status == "DONE" end -- 28
____exports.isQuestionAnswered = function(question, selectedOptionIds, text) -- 30
	local ____temp_3 = not question.required -- 34
	if not ____temp_3 then -- 34
		local ____temp_2 -- 34
		if question.type == "text" then -- 34
			____temp_2 = __TS__StringTrim(text) ~= "" -- 34
		else -- 34
			____temp_2 = #selectedOptionIds > 0 -- 34
		end -- 34
		____temp_3 = ____temp_2 -- 34
	end -- 34
	return ____temp_3 -- 34
end -- 30
____exports.buildQuestionnaireAnswers = function(questions, selections, texts) return __TS__ArrayMap( -- 36
	questions, -- 40
	function(____, question) -- 40
		local text = __TS__StringTrim(texts[question.id] or "") -- 41
		local selectedOptionIds = selections[question.id] or ({}) -- 42
		if not question.required and text == "" and #selectedOptionIds == 0 then -- 42
			return {questionId = question.id, status = "skipped"} -- 44
		end -- 44
		return question.type == "text" and ({questionId = question.id, status = "answered", text = text}) or ({questionId = question.id, status = "answered", selectedOptionIds = selectedOptionIds}) -- 46
	end -- 40
) end -- 40
____exports.compactAgentActivity = function(tool, reason, zh, active) -- 51
	if active == nil then -- 51
		active = true -- 51
	end -- 51
	local label = (tool == "search_files" or tool == "search_dora_doc") and (zh and (active and "正在查找资料" or "查找资料") or (active and "Searching" or "Search")) or (tool == "read_file" and (zh and (active and "正在阅读项目" or "阅读项目") or (active and "Reading project" or "Read project")) or ((tool == "edit_file" or tool == "write_file") and (zh and (active and "正在修改作品" or "修改作品") or (active and "Editing game" or "Edit game")) or (tool == "build" and (zh and (active and "正在验证作品" or "验证作品") or (active and "Validating game" or "Validate game")) or (zh and (active and "正在处理" or "处理") or (active and "Working" or "Process"))))) -- 52
	local clean = __TS__StringTrim(reason) -- 61
	return clean == "" and label or (label .. " · ") .. string.sub(clean, 1, 72) -- 62
end -- 51
____exports.resolveRemixThinkingStatus = function(steps, currentTaskId) -- 68
	if currentTaskId == nil then -- 73
		return nil -- 73
	end -- 73
	local current -- 74
	for ____, step in ipairs(steps) do -- 75
		do -- 75
			if step.taskId ~= currentTaskId then -- 76
				goto __continue75 -- 76
			end -- 76
			if not current or step.step > current.step or step.step == current.step and step.id > current.id then -- 77
				current = step -- 77
			end -- 77
		end -- 77
		::__continue75:: -- 75
	end -- 75
	if not current or current.tool ~= "message" or current.status ~= "RUNNING" or string.match(current.reason, "^%s*$") == nil then -- 79
		return nil -- 80
	end -- 80
	local reasoning = string.gsub(current.reasoningContent, "\r\n", "\n") -- 81
	reasoning = string.gsub(reasoning, "\r", "\n") -- 82
	reasoning = string.gsub(reasoning, "[ \t\n]+$", "") -- 83
	local lastLine = string.match(reasoning, "([^\n]+)$") or "" -- 84
	if lastLine == "" then -- 85
		return nil -- 85
	end -- 85
	return lastLine -- 86
end -- 68
return ____exports -- 68
