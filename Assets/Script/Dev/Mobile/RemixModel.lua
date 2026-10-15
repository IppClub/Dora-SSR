-- [ts]: RemixModel.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
____exports.resolveRemixWorkMode = function(session) return (session and session.kind) == "main" and session.workMode == "plan" and "plan" or "code" end -- 8
____exports.resolveRemixPhase = function(state) -- 17
	if state.status == "FAILED" then -- 17
		return "failed" -- 18
	end -- 18
	if state.status == "STOPPED" then -- 18
		return "stopped" -- 19
	end -- 19
	if state.status == "WAITING_USER" then -- 19
		return "waiting" -- 20
	end -- 20
	if state.status == "RUNNING" then -- 20
		return state.workMode == "plan" and "planning" or "working" -- 21
	end -- 21
	if state.status == "DONE" then -- 21
		return state.workMode == "plan" and "plan-ready" or "done" -- 22
	end -- 22
	return "idle" -- 23
end -- 17
____exports.canLeaveRemix = function(status) return status ~= "RUNNING" and status ~= "WAITING_USER" end -- 26
____exports.canPlayRemix = function(status) return status == "DONE" end -- 29
____exports.isQuestionAnswered = function(question, selectedOptionIds, text) -- 31
	local ____temp_3 = not question.required -- 35
	if not ____temp_3 then -- 35
		local ____temp_2 -- 35
		if question.type == "text" then -- 35
			____temp_2 = __TS__StringTrim(text) ~= "" -- 35
		else -- 35
			____temp_2 = #selectedOptionIds > 0 -- 35
		end -- 35
		____temp_3 = ____temp_2 -- 35
	end -- 35
	return ____temp_3 -- 35
end -- 31
____exports.buildQuestionnaireAnswers = function(questions, selections, texts) return __TS__ArrayMap( -- 37
	questions, -- 41
	function(____, question) -- 41
		local text = __TS__StringTrim(texts[question.id] or "") -- 42
		local selectedOptionIds = selections[question.id] or ({}) -- 43
		if not question.required and text == "" and #selectedOptionIds == 0 then -- 43
			return {questionId = question.id, status = "skipped"} -- 45
		end -- 45
		return question.type == "text" and ({questionId = question.id, status = "answered", text = text}) or ({questionId = question.id, status = "answered", selectedOptionIds = selectedOptionIds}) -- 47
	end -- 41
) end -- 41
____exports.compactAgentActivity = function(tool, reason, zh, active) -- 52
	if active == nil then -- 52
		active = true -- 52
	end -- 52
	if tool == "analyze_image" then -- 52
		return zh and (active and "正在分析游戏画面" or "画面分析") or (active and "Analyzing game" or "Image analysis") -- 53
	end -- 53
	local label = (tool == "search_files" or tool == "search_dora_doc") and (zh and (active and "正在查找资料" or "查找资料") or (active and "Searching" or "Search")) or (tool == "read_file" and (zh and (active and "正在阅读项目" or "阅读项目") or (active and "Reading project" or "Read project")) or ((tool == "edit_file" or tool == "write_file") and (zh and (active and "正在修改作品" or "修改作品") or (active and "Editing game" or "Edit game")) or (tool == "build" and (zh and (active and "正在验证作品" or "验证作品") or (active and "Validating game" or "Validate game")) or (zh and (active and "正在处理" or "处理") or (active and "Working" or "Process"))))) -- 54
	local clean = __TS__StringTrim(reason) -- 63
	return clean == "" and label or (label .. " · ") .. string.sub(clean, 1, 72) -- 64
end -- 52
____exports.resolveRemixThinkingStatus = function(steps, currentTaskId) -- 69
	if currentTaskId == nil then -- 69
		return nil -- 73
	end -- 73
	local current -- 74
	for ____, step in ipairs(steps) do -- 75
		do -- 75
			if step.taskId ~= currentTaskId then -- 75
				goto __continue19 -- 76
			end -- 76
			if not current or step.step > current.step or step.step == current.step and step.id > current.id then -- 76
				current = step -- 77
			end -- 77
		end -- 77
		::__continue19:: -- 77
	end -- 77
	if not current or current.tool ~= "message" or current.status ~= "RUNNING" or (string.match(current.reason, "^%s*$")) == nil then -- 77
		return nil -- 80
	end -- 80
	local reasoning = (string.gsub(current.reasoningContent, "\r\n", "\n")) -- 81
	reasoning = (string.gsub(reasoning, "\r", "\n")) -- 82
	reasoning = (string.gsub(reasoning, "[ \t\n]+$", "")) -- 83
	local lastLine = (string.match(reasoning, "([^\n]+)$")) or "" -- 84
	if lastLine == "" then -- 84
		return nil -- 85
	end -- 85
	return lastLine -- 86
end -- 69
return ____exports -- 69