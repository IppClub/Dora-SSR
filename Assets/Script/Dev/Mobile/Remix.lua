-- [tsx]: Remix.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local reference = ____DoraX.reference -- 1
local toNode = ____DoraX.toNode -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local DB = ____Dora.DB -- 2
local Director = ____Dora.Director -- 2
local Ease = ____Dora.Ease -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Move = ____Dora.Move -- 2
local Node = ____Dora.Node -- 2
local sleep = ____Dora.sleep -- 2
local thread = ____Dora.thread -- 2
local Vec2 = ____Dora.Vec2 -- 2
local AgentSession = require("Agent.Session") -- 3
local ____Utils = require("Agent.Utils") -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local getLLMConfig = ____Utils.getLLMConfig -- 4
local getLLMConfigSummaries = ____Utils.getLLMConfigSummaries -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local ____RemixModel = require("Dev.Mobile.RemixModel") -- 7
local buildQuestionnaireAnswers = ____RemixModel.buildQuestionnaireAnswers -- 7
local canLeaveRemix = ____RemixModel.canLeaveRemix -- 7
local isQuestionAnswered = ____RemixModel.isQuestionAnswered -- 7
local resolveRemixPhase = ____RemixModel.resolveRemixPhase -- 7
local resolveRemixWorkMode = ____RemixModel.resolveRemixWorkMode -- 7
local ____Mascot = require("Dev.Mobile.Mascot") -- 8
local DoraMascot = ____Mascot.DoraMascot -- 8
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 9
local mobileFontScale = ____Accessibility.mobileFontScale -- 9
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 10
local resolveFeedGesture = ____FeedModel.resolveFeedGesture -- 10
local ____RemixTranscript = require("Dev.Mobile.RemixTranscript") -- 11
local createRemixTranscript = ____RemixTranscript.createRemixTranscript -- 11
local remixDisplayRevision = ____RemixTranscript.remixDisplayRevision -- 11
local ____RemixHistory = require("Dev.Mobile.RemixHistory") -- 12
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS -- 12
local ____TextInput = require("Dev.Mobile.TextInput") -- 13
local createTextInput = ____TextInput.createTextInput -- 13
local fontName = "sarasa-mono-sc-regular" -- 43
local colors = { -- 44
	background = 4278914322, -- 44
	panel = 4279704614, -- 44
	text = 4294242792, -- 44
	muted = 4289245117, -- 44
	brand = 4294954035, -- 44
	border = 4281613128, -- 44
	danger = 4294929259 -- 44
} -- 44
local composerGap = 12 -- 46
local composerBottom = 76 -- 47
local composerHeight = 60 -- 48
local composerActionWidth = 82 -- 49
local modeBottom = composerBottom + composerHeight + composerGap -- 50
local composerTop = modeBottom + 40 -- 51
local transcriptBottom = composerTop + composerGap -- 52
local statusTopInset = 56 + composerGap -- 53
local statusHeight = 64 -- 54
local transcriptTopInset = statusTopInset + statusHeight + composerGap -- 55
local function ActionButton(props) -- 57
	local color = props.danger and colors.danger or (props.primary and colors.brand or colors.panel) -- 58
	local height = props.height or 46 -- 59
	return React.createElement( -- 60
		"node", -- 60
		{ -- 60
			tag = props.tag, -- 60
			x = props.x, -- 60
			y = props.y, -- 60
			width = props.width, -- 60
			height = height, -- 60
			anchorX = 0, -- 60
			anchorY = 0, -- 60
			opacity = props.disabled and 0.45 or 1, -- 60
			touchEnabled = not props.disabled, -- 60
			swallowTouches = true, -- 60
			onTapped = props.onTapped -- 60
		}, -- 60
		React.createElement( -- 60
			"draw-node", -- 60
			{x = props.width / 2, y = height / 2}, -- 60
			React.createElement("rect-shape", { -- 60
				width = props.width, -- 60
				height = height, -- 60
				fillColor = color, -- 60
				borderWidth = 1, -- 60
				borderColor = (props.primary or props.danger) and color or colors.border -- 60
			}) -- 60
		), -- 60
		React.createElement("label", { -- 60
			x = props.width / 2, -- 60
			y = height / 2, -- 60
			fontName = fontName, -- 60
			fontSize = 15, -- 60
			text = props.text, -- 60
			color3 = props.primary and 1512202 or 16052712 -- 60
		}) -- 60
	) -- 60
end -- 57
local function ChoiceButton(props) -- 66
	return React.createElement( -- 67
		"node", -- 67
		{ -- 67
			tag = props.tag, -- 67
			x = props.x, -- 67
			y = props.y, -- 67
			width = props.width, -- 67
			height = 40, -- 67
			anchorX = 0, -- 67
			anchorY = 0, -- 67
			opacity = props.disabled and 0.45 or 1, -- 67
			touchEnabled = not props.disabled, -- 67
			swallowTouches = true, -- 67
			onTapped = props.onTapped -- 67
		}, -- 67
		React.createElement( -- 67
			"draw-node", -- 67
			{x = props.width / 2, y = 20}, -- 67
			React.createElement("rect-shape", { -- 67
				width = props.width, -- 67
				height = 40, -- 67
				fillColor = props.selected and colors.brand or colors.background, -- 67
				borderWidth = 1, -- 67
				borderColor = props.selected and colors.brand or colors.border -- 67
			}) -- 67
		), -- 67
		React.createElement("label", { -- 67
			x = 12, -- 67
			y = 20, -- 67
			anchorX = 0, -- 67
			fontName = fontName, -- 67
			fontSize = 14, -- 67
			text = props.text, -- 67
			textWidth = props.width - 24, -- 67
			alignment = "Left", -- 67
			color3 = props.selected and 1512202 or 16052712 -- 67
		}) -- 67
	) -- 67
end -- 66
function ____exports.startMobileRemix(options) -- 73
	local host, send, render -- 73
	local onBack = options.onBack -- 74
	local onPlay = options.onPlay -- 75
	local services = options.services or ({ -- 76
		createSession = AgentSession.createSession, -- 77
		getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end, -- 78
		setWorkMode = AgentSession.setWorkMode, -- 79
		sendPrompt = AgentSession.sendPrompt, -- 80
		respondQuestionnaire = AgentSession.respondQuestionnaire, -- 81
		stopSessionTask = AgentSession.stopSessionTask, -- 82
		getActiveLLMConfig = getActiveLLMConfig, -- 83
		getLLMConfig = getLLMConfig, -- 84
		getLLMConfigSummaries = getLLMConfigSummaries -- 85
	}) -- 85
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 87
	local projectRoot = options.entry.workDir or "" -- 88
	local created = services.createSession(projectRoot, options.entry.title) -- 89
	local sessionId = created.success and created.session.id or 0 -- 90
	local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message}) -- 91
	local draft = "" -- 94
	local ____error = created.success and "" or created.message -- 95
	local pollElapsed = 0 -- 96
	local stopRequested = false -- 97
	local selectedLLMConfigId = 0 -- 98
	local questionnaireId = 0 -- 99
	local questionIndex = 0 -- 100
	local llmConfigs = services.getLLMConfigSummaries() -- 101
	local modelPickerOpen = false -- 102
	local questionnaireSelections = {} -- 103
	local questionnaireTexts = {} -- 104
	local inputRef = reference() -- 105
	local disposed = false -- 106
	local dismissedComposition = false -- 107
	local swipeBackPending = false -- 108
	local swipeDragging = false -- 109
	local swipeRevision = 0 -- 110
	local function currentQuestion() -- 111
		local ____detail_success_2 -- 111
		if detail.success then -- 111
			local ____opt_0 = detail.pendingQuestionnaire -- 111
			____detail_success_2 = ____opt_0 and ____opt_0.schema.questions[questionIndex + 1] -- 111
		else -- 111
			____detail_success_2 = nil -- 111
		end -- 111
		return ____detail_success_2 -- 111
	end -- 111
	local promptInput = createTextInput({ -- 112
		fontSize = math.floor(16 * mobileFontScale), -- 113
		getText = function() -- 114
			local question = currentQuestion() -- 114
			return question and (questionnaireTexts[question.id] or "") or draft -- 114
		end, -- 114
		setText = function(text) -- 115
			local question = currentQuestion() -- 115
			if question then -- 115
				questionnaireTexts[question.id] = text -- 115
			else -- 115
				draft = text -- 115
			end -- 115
		end, -- 115
		getPlaceholder = function() -- 116
			local question = currentQuestion() -- 117
			return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…")) -- 118
		end, -- 116
		isEnabled = function() return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end, -- 120
		onReturn = function(modified) -- 121
			if modified and not currentQuestion() then -- 121
				send() -- 121
				return true -- 121
			end -- 121
			return false -- 121
		end -- 121
	}) -- 121
	local blurInput = promptInput.blur -- 123
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 124
	local ____temp_5 -- 125
	if rememberedRows and #rememberedRows > 0 then -- 125
		____temp_5 = tonumber(rememberedRows[1][1]) -- 125
	else -- 125
		____temp_5 = nil -- 125
	end -- 125
	local rememberedId = ____temp_5 -- 125
	if rememberedId and __TS__ArraySome( -- 125
		llmConfigs, -- 126
		function(____, item) return item.id == rememberedId end -- 126
	) then -- 126
		selectedLLMConfigId = rememberedId -- 126
	elseif #llmConfigs == 1 then -- 126
		selectedLLMConfigId = llmConfigs[1].id -- 127
	elseif #llmConfigs > 1 then -- 127
		modelPickerOpen = true -- 128
	else -- 128
		local activeConfig = services.getActiveLLMConfig() -- 130
		if activeConfig.success then -- 130
			selectedLLMConfigId = activeConfig.id -- 131
		end -- 131
	end -- 131
	host = Node() -- 134
	host.tag = "mobile-remix" -- 135
	host.scaleX = App.devicePixelRatio -- 136
	host.scaleY = App.devicePixelRatio -- 137
	host:addTo(Director.systemUI) -- 138
	local transcript = createRemixTranscript() -- 139
	local displayRevision = "" -- 140
	local shellRevision = "" -- 141
	local inputLayout = "" -- 142
	local errorLabel -- 143
	local function getTranscriptBottom() -- 144
		return transcriptBottom + (errorLabel and errorLabel.height + composerGap or 0) -- 144
	end -- 144
	local function getShellRevision() -- 145
		local ____detail_success_9 -- 145
		if detail.success then -- 145
			local ____safeJsonEncode_8 = safeJsonEncode -- 145
			local ____array_7 = __TS__SparseArrayNew( -- 145
				detail.session.status, -- 146
				detail.session.workMode, -- 146
				detail.hasActivePlan, -- 146
				detail.pendingQuestionnaire or false, -- 146
				detail.session.currentTaskStatus or "" -- 147
			) -- 147
			local ____detail_session_currentTaskFinalizing_6 = detail.session.currentTaskFinalizing -- 147
			if ____detail_session_currentTaskFinalizing_6 == nil then -- 147
				____detail_session_currentTaskFinalizing_6 = false -- 147
			end -- 147
			__TS__SparseArrayPush(____array_7, ____detail_session_currentTaskFinalizing_6, stopRequested) -- 147
			____detail_success_9 = (____safeJsonEncode_8({__TS__SparseArraySpread(____array_7)})) or "" -- 145
		else -- 145
			____detail_success_9 = detail.message -- 148
		end -- 148
		return ____detail_success_9 -- 145
	end -- 145
	local function updateTranscript() -- 149
		local safe = App.safeArea -- 150
		transcript:update( -- 151
			detail, -- 151
			math.max(60, safe.width - 32), -- 151
			math.max( -- 151
				40, -- 151
				safe.height - getTranscriptBottom() - transcriptTopInset -- 151
			), -- 151
			mobileFontScale, -- 151
			zh -- 151
		) -- 151
		displayRevision = remixDisplayRevision(detail) -- 152
	end -- 149
	local function hasActiveTask() -- 155
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil) -- 155
	end -- 155
	local function refresh() -- 158
		if sessionId > 0 then -- 158
			detail = services.getSession(sessionId) -- 159
		end -- 159
		if detail.success and not hasActiveTask() then -- 159
			stopRequested = false -- 160
		end -- 160
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then -- 160
			questionnaireId = detail.pendingQuestionnaire.id -- 162
			questionIndex = 0 -- 163
		end -- 163
	end -- 158
	local function canSubmit() -- 166
		return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire -- 166
	end -- 166
	local function changeWorkMode(workMode) -- 169
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 169
			return -- 170
		end -- 170
		refresh() -- 171
		if not canSubmit() or not detail.success then -- 171
			return -- 172
		end -- 172
		if resolveRemixWorkMode(detail.session) == workMode then -- 172
			return -- 173
		end -- 173
		local result = services.setWorkMode(sessionId, workMode) -- 174
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode")) -- 175
		refresh() -- 176
		render() -- 177
	end -- 169
	send = function() -- 179
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 179
			return -- 180
		end -- 180
		refresh() -- 181
		if not canSubmit() or not detail.success or promptInput.isComposing() then -- 181
			return -- 182
		end -- 182
		local workMode = resolveRemixWorkMode(detail.session) -- 183
		local text = (string.match(draft, "^%s*(.-)%s*$")) or "" -- 186
		if sessionId <= 0 or text == "" then -- 186
			return -- 187
		end -- 187
		local config = selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig() -- 188
		if not config.success then -- 188
			____error = zh and "请先在桌面 Web IDE 中配置并启用一个模型" or "Configure and activate a model in Web IDE first" -- 190
			render() -- 191
			return -- 192
		end -- 192
		selectedLLMConfigId = config.id -- 194
		local result = services.sendPrompt( -- 195
			sessionId, -- 195
			text, -- 195
			nil, -- 195
			workMode, -- 195
			config.id, -- 195
			config.config -- 195
		) -- 195
		if not result.success then -- 195
			____error = result.message -- 196
		else -- 196
			draft = "" -- 197
			____error = "" -- 197
		end -- 197
		refresh() -- 198
		render() -- 199
	end -- 179
	local function stop() -- 201
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 201
			return -- 202
		end -- 202
		refresh() -- 203
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then -- 203
			return -- 205
		end -- 205
		local result = services.stopSessionTask(sessionId) -- 206
		if (result and result.success) == false then -- 206
			____error = result.message or (zh and "停止失败" or "Could not stop") -- 207
		else -- 207
			stopRequested = true -- 208
			____error = "" -- 208
		end -- 208
		refresh() -- 209
		render() -- 210
	end -- 201
	local function selectModel(id) -- 212
		selectedLLMConfigId = id -- 213
		modelPickerOpen = false -- 214
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id}) -- 215
		____error = "" -- 216
		render() -- 217
	end -- 212
	local function advanceQuestionnaire() -- 219
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 219
			return -- 220
		end -- 220
		if not detail.success or not detail.pendingQuestionnaire then -- 220
			return -- 221
		end -- 221
		local pending = detail.pendingQuestionnaire -- 222
		local questions = pending.schema.questions -- 223
		local question = questions[questionIndex + 1] -- 224
		if not question then -- 224
			return -- 225
		end -- 225
		local selected = questionnaireSelections[question.id] or ({}) -- 226
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "") -- 227
		if not isQuestionAnswered(question, selected, text) then -- 227
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 229
			render() -- 230
			return -- 231
		end -- 231
		if questionIndex + 1 < #questions then -- 231
			questionIndex = questionIndex + 1 -- 234
			____error = "" -- 235
			render() -- 236
			return -- 237
		end -- 237
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 239
		if selectedLLMConfigId <= 0 then -- 239
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 241
			render() -- 242
			return -- 243
		end -- 243
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 245
		if not result.success then -- 245
			____error = result.message -- 246
		else -- 246
			____error = "" -- 247
		end -- 247
		refresh() -- 248
		render() -- 249
	end -- 219
	local function goBack() -- 251
		if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 251
			return -- 252
		end -- 252
		if detail.success and not canLeaveRemix(detail.session.status) then -- 252
			____error = zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back" -- 254
			render() -- 255
			return -- 256
		end -- 256
		blurInput() -- 258
		host.visible = false -- 259
		host:removeFromParent(true) -- 260
		onBack() -- 261
	end -- 251
	render = function() -- 264
		errorLabel = nil -- 265
		swipeRevision = swipeRevision + 1 -- 267
		swipeDragging = false -- 268
		swipeBackPending = false -- 269
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height) -- 270
		local ____temp_14 = layout == inputLayout and not modelPickerOpen and not (detail.success and detail.pendingQuestionnaire) -- 272
		if ____temp_14 then -- 272
			local ____opt_12 = inputRef.current -- 272
			____temp_14 = (____opt_12 and ____opt_12.tag) == "remix-input" -- 272
		end -- 272
		local keptInput = ____temp_14 and inputRef.current or nil -- 272
		if keptInput ~= nil then -- 272
			keptInput:removeFromParent(false) -- 274
		end -- 274
		transcript.node:removeFromParent(false) -- 275
		local restoreInputFocus = promptInput.isFocused() -- 276
		if not keptInput then -- 276
			promptInput.unmount() -- 278
			inputRef = reference() -- 279
		end -- 279
		host:removeAllChildren() -- 281
		inputLayout = layout -- 282
		host.scaleX = App.devicePixelRatio -- 283
		host.scaleY = App.devicePixelRatio -- 284
		local ____App_visualSize_17 = App.visualSize -- 285
		local width = ____App_visualSize_17.width -- 285
		local height = ____App_visualSize_17.height -- 285
		local safe = App.safeArea -- 286
		local left = safe.x -- 287
		local bottom = safe.y -- 288
		local contentWidth = safe.width - 32 -- 289
		local inputWidth = contentWidth - composerActionWidth - composerGap -- 290
		local modeWidth = math.floor((contentWidth - composerGap) / 2) -- 291
		local state = detail.success and detail.session or nil -- 292
		local workMode = resolveRemixWorkMode(state) -- 293
		local stopping = hasActiveTask() -- 294
		local ____detail_success_18 -- 295
		if detail.success then -- 295
			____detail_success_18 = detail.hasActivePlan -- 295
		else -- 295
			____detail_success_18 = false -- 295
		end -- 295
		local hasActivePlan = ____detail_success_18 -- 295
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 296
		local ____detail_success_19 -- 297
		if detail.success then -- 297
			____detail_success_19 = detail.pendingQuestionnaire -- 297
		else -- 297
			____detail_success_19 = nil -- 297
		end -- 297
		local questionnaire = ____detail_success_19 -- 297
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 298
		local fontScale = mobileFontScale -- 299
		local pickerHeight = math.min(420, safe.height - 280) -- 300
		local statusText = phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game")))))) -- 301
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 308
		local messageTop = bottom + safe.height - statusTopInset - statusHeight / 2 -- 314
		local swipeStart = Vec2.zero -- 315
		local swipeAxis = "none" -- 316
		local pageRef = reference() -- 317
		local hitsTranscriptButton -- 318
		hitsTranscriptButton = function(node, world) -- 318
			if not node.visible then -- 318
				return false -- 319
			end -- 319
			if node.tag == "remix-copy" or node.tag == "remix-latest" then -- 319
				local p = node:convertToNodeSpace(world) -- 321
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 321
					return true -- 322
				end -- 322
			end -- 322
			local hit = false -- 324
			node:eachChild(function(child) -- 325
				hit = hitsTranscriptButton(child, world) -- 325
				return hit -- 325
			end) -- 325
			return hit -- 326
		end -- 318
		local ____toNode_56 = toNode -- 328
		local ____React_createElement_55 = React.createElement -- 328
		local ____array_54 = __TS__SparseArrayNew( -- 328
			"node", -- 328
			{ -- 328
				tag = "remix-scene", -- 328
				x = -width / 2, -- 328
				y = -height / 2, -- 328
				width = width, -- 328
				height = height, -- 328
				anchorX = 0, -- 328
				anchorY = 0 -- 328
			}, -- 328
			React.createElement( -- 328
				"node", -- 328
				{ -- 328
					tag = "remix-focus-observer", -- 328
					order = 1000, -- 328
					width = width, -- 328
					height = height, -- 328
					anchorX = 0, -- 328
					anchorY = 0, -- 328
					touchEnabled = true, -- 328
					swallowTouches = false, -- 328
					swallowMouseWheel = false, -- 328
					onTapFilter = function(touch) -- 328
						touch.enabled = false -- 332
						if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 332
							return -- 333
						end -- 333
						local input = inputRef.current -- 334
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 335
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 336
						dismissedComposition = not inside and promptInput.isComposing() -- 337
						if not inside then -- 337
							blurInput() -- 338
						end -- 338
						if not inside and not questionnaire and not modelPickerOpen and touch.first ~= false and touch.location.y >= bottom + transcriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 338
							touch.enabled = true -- 343
						end -- 343
					end, -- 331
					onTapBegan = function(touch) -- 331
						swipeStart = touch.location -- 347
						swipeAxis = "none" -- 347
						swipeDragging = true -- 347
						local ____opt_24 = pageRef.current -- 347
						if ____opt_24 ~= nil then -- 347
							____opt_24:stopAllActions() -- 348
						end -- 348
					end, -- 346
					onTapMoved = function(touch) -- 346
						local delta = touch.location:sub(swipeStart) -- 351
						if swipeAxis == "none" and math.max( -- 351
							math.abs(delta.x), -- 352
							math.abs(delta.y) -- 352
						) >= 12 then -- 352
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 353
						end -- 353
						if pageRef.current then -- 353
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 355
						end -- 355
					end, -- 350
					onTapEnded = function(touch) -- 350
						local delta = touch.location:sub(swipeStart) -- 358
						swipeDragging = false -- 359
						if swipeBackPending then -- 359
							return -- 360
						end -- 360
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 361
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 362
						local page = pageRef.current -- 363
						if not page or not requested and page.x == 0 then -- 363
							return -- 364
						end -- 364
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 365
						local revision = swipeRevision -- 366
						swipeBackPending = true -- 367
						if not leaving then -- 367
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 369
						end -- 369
						thread(function() -- 371
							sleep(duration) -- 372
							if disposed or revision ~= swipeRevision or not host.parent then -- 372
								return -- 373
							end -- 373
							swipeBackPending = false -- 374
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 374
								refresh() -- 375
								goBack() -- 375
							else -- 375
								page.position = Vec2.zero -- 376
							end -- 376
						end) -- 371
					end -- 357
				} -- 357
			), -- 357
			React.createElement( -- 357
				"draw-node", -- 357
				{x = width / 2, y = height / 2}, -- 357
				React.createElement("rect-shape", {width = width, height = height, fillColor = colors.background}) -- 357
			) -- 357
		) -- 357
		local ____React_createElement_53 = React.createElement -- 357
		local ____array_52 = __TS__SparseArrayNew( -- 357
			"node", -- 357
			{tag = "remix-page", ref = pageRef}, -- 357
			React.createElement( -- 357
				"clip-node", -- 357
				{ -- 357
					x = left + 16, -- 357
					y = bottom + safe.height - 56, -- 357
					width = safe.width - 124, -- 357
					height = 44, -- 357
					anchorX = 0, -- 357
					anchorY = 0, -- 357
					stencil = React.createElement( -- 357
						"draw-node", -- 357
						{x = (safe.width - 124) / 2, y = 22}, -- 357
						React.createElement("rect-shape", {width = safe.width - 124, height = 44, fillColor = 4294967295}) -- 357
					) -- 357
				}, -- 357
				React.createElement("label", { -- 357
					tag = "remix-title", -- 357
					x = 0, -- 357
					y = 22, -- 357
					anchorX = 0, -- 357
					fontName = fontName, -- 357
					fontSize = 20, -- 357
					text = "REMIX · " .. options.entry.title, -- 357
					color3 = 16052712 -- 357
				}) -- 357
			), -- 357
			React.createElement( -- 357
				"node", -- 357
				{ -- 357
					tag = "remix-back", -- 357
					x = left + safe.width - 96, -- 357
					y = bottom + safe.height - 56, -- 357
					width = 80, -- 357
					height = 44, -- 357
					anchorX = 0, -- 357
					anchorY = 0, -- 357
					touchEnabled = true, -- 357
					swallowTouches = true, -- 357
					onTapped = goBack -- 357
				}, -- 357
				React.createElement("label", { -- 357
					x = 80, -- 357
					y = 22, -- 357
					anchorX = 1, -- 357
					fontName = fontName, -- 357
					fontSize = 18, -- 357
					text = zh and "返回 ›" or "Back ›", -- 357
					color3 = 16763955 -- 357
				}) -- 357
			), -- 357
			React.createElement( -- 357
				"node", -- 357
				{ -- 357
					tag = "remix-status", -- 357
					y = messageTop - statusHeight / 2, -- 357
					width = width, -- 357
					height = statusHeight, -- 357
					anchorX = 0, -- 357
					anchorY = 0 -- 357
				}, -- 357
				React.createElement(DoraMascot, {state = mascotState, x = left + 66, y = statusHeight / 2 - 2, size = 52}), -- 357
				React.createElement( -- 357
					"label", -- 357
					{ -- 357
						x = left + 104, -- 357
						y = statusHeight / 2, -- 357
						anchorX = 0, -- 357
						fontName = fontName, -- 357
						fontSize = math.floor(15 * fontScale), -- 357
						text = statusText, -- 357
						textWidth = contentWidth - 84, -- 357
						alignment = "Left", -- 357
						color3 = phase == "failed" and 16739179 or 16763955 -- 357
					} -- 357
				) -- 357
			) -- 357
		) -- 357
		local ____temp_33 -- 393
		if questionnaire and question then -- 393
			local ____React_createElement_32 = React.createElement -- 393
			local ____array_31 = __TS__SparseArrayNew( -- 393
				"node", -- 393
				{ -- 393
					tag = "remix-questionnaire", -- 393
					x = left + 16, -- 393
					y = bottom + 164, -- 393
					width = contentWidth, -- 393
					height = safe.height - 330, -- 393
					anchorX = 0, -- 393
					anchorY = 0 -- 393
				}, -- 393
				React.createElement( -- 393
					"draw-node", -- 393
					{x = contentWidth / 2, y = (safe.height - 330) / 2}, -- 393
					React.createElement("rect-shape", { -- 393
						width = contentWidth, -- 393
						height = safe.height - 330, -- 393
						fillColor = colors.panel, -- 393
						borderWidth = 1, -- 393
						borderColor = colors.border -- 393
					}) -- 393
				), -- 393
				React.createElement( -- 393
					"label", -- 393
					{ -- 393
						x = 16, -- 393
						y = safe.height - 360, -- 393
						anchorX = 0, -- 393
						fontName = fontName, -- 393
						fontSize = 13, -- 393
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 393
						textWidth = contentWidth - 32, -- 393
						alignment = "Left", -- 393
						color3 = 16763955 -- 393
					} -- 393
				), -- 393
				React.createElement("label", { -- 393
					x = 16, -- 393
					y = safe.height - 405, -- 393
					anchorX = 0, -- 393
					fontName = fontName, -- 393
					fontSize = 16, -- 393
					text = question.prompt, -- 393
					textWidth = contentWidth - 32, -- 393
					alignment = "Left", -- 393
					color3 = 16052712 -- 393
				}), -- 393
				question.type ~= "text" and __TS__ArrayMap( -- 397
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 397
					function(____, option, optionIndex) return React.createElement( -- 397
						ChoiceButton, -- 397
						{ -- 397
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 397
							x = 16, -- 397
							y = safe.height - 460 - optionIndex * 43, -- 397
							width = contentWidth - 32, -- 397
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 397
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 397
							onTapped = function() -- 397
								local selected = questionnaireSelections[question.id] or ({}) -- 403
								local ____question_id_29 = question.id -- 404
								local ____temp_28 -- 404
								if question.type == "single_choice" then -- 404
									____temp_28 = {option.id} -- 405
								else -- 405
									local ____temp_27 -- 406
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 406
										____temp_27 = __TS__ArrayFilter( -- 406
											selected, -- 406
											function(____, id) return id ~= option.id end -- 406
										) -- 406
									else -- 406
										local ____array_26 = __TS__SparseArrayNew(table.unpack(selected)) -- 406
										__TS__SparseArrayPush(____array_26, option.id) -- 406
										____temp_27 = {__TS__SparseArraySpread(____array_26)} -- 406
									end -- 406
									____temp_28 = ____temp_27 -- 406
								end -- 406
								questionnaireSelections[____question_id_29] = ____temp_28 -- 404
								render() -- 407
							end -- 402
						} -- 402
					) end -- 402
				) or React.createElement("node", { -- 402
					tag = "remix-question-input", -- 402
					ref = inputRef, -- 402
					x = 16, -- 402
					y = safe.height - 510, -- 402
					width = contentWidth - 32, -- 402
					height = 92, -- 402
					anchorX = 0, -- 402
					anchorY = 0, -- 402
					onMount = promptInput.mount -- 402
				}) -- 402
			) -- 402
			local ____temp_30 -- 411
			if questionIndex > 0 then -- 411
				____temp_30 = React.createElement( -- 411
					ActionButton, -- 411
					{ -- 411
						x = 16, -- 411
						y = 12, -- 411
						width = 92, -- 411
						text = zh and "上一步" or "Back", -- 411
						onTapped = function() -- 411
							questionIndex = questionIndex - 1 -- 411
							render() -- 411
						end -- 411
					} -- 411
				) -- 411
			else -- 411
				____temp_30 = nil -- 411
			end -- 411
			__TS__SparseArrayPush( -- 411
				____array_31, -- 411
				____temp_30, -- 411
				React.createElement( -- 411
					ActionButton, -- 412
					{ -- 412
						tag = "remix-question-submit", -- 412
						x = questionIndex > 0 and 120 or 16, -- 412
						y = 12, -- 412
						width = contentWidth - (questionIndex > 0 and 136 or 32), -- 412
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 412
						primary = true, -- 412
						onTapped = function() -- 412
							if not dismissedComposition then -- 412
								advanceQuestionnaire() -- 414
							end -- 414
							dismissedComposition = false -- 414
						end -- 414
					} -- 414
				) -- 414
			) -- 414
			____temp_33 = ____React_createElement_32(__TS__SparseArraySpread(____array_31)) -- 414
		else -- 414
			____temp_33 = nil -- 415
		end -- 415
		__TS__SparseArrayPush(____array_52, ____temp_33) -- 415
		local ____modelPickerOpen_34 -- 416
		if modelPickerOpen then -- 416
			____modelPickerOpen_34 = React.createElement( -- 416
				"node", -- 416
				{ -- 416
					x = left + 16, -- 416
					y = bottom + 164, -- 416
					width = contentWidth, -- 416
					height = pickerHeight, -- 416
					anchorX = 0, -- 416
					anchorY = 0, -- 416
					touchEnabled = true, -- 416
					swallowTouches = true -- 416
				}, -- 416
				React.createElement( -- 416
					"draw-node", -- 416
					{x = contentWidth / 2, y = pickerHeight / 2}, -- 416
					React.createElement("rect-shape", { -- 416
						width = contentWidth, -- 416
						height = pickerHeight, -- 416
						fillColor = colors.panel, -- 416
						borderWidth = 1, -- 416
						borderColor = colors.border -- 416
					}) -- 416
				), -- 416
				React.createElement("label", { -- 416
					x = 16, -- 416
					y = pickerHeight - 34, -- 416
					anchorX = 0, -- 416
					fontName = fontName, -- 416
					fontSize = 17, -- 416
					text = zh and "选择 Remix 使用的模型" or "Choose a model for Remix", -- 416
					textWidth = contentWidth - 32, -- 416
					alignment = "Left", -- 416
					color3 = 16052712 -- 416
				}), -- 416
				__TS__ArrayMap( -- 419
					__TS__ArraySlice(llmConfigs, 0, 8), -- 419
					function(____, item, i) return React.createElement( -- 419
						ChoiceButton, -- 419
						{ -- 419
							x = 16, -- 419
							y = pickerHeight - 90 - i * 43, -- 419
							width = contentWidth - 32, -- 419
							text = (item.name .. " · ") .. item.model, -- 419
							selected = item.id == selectedLLMConfigId, -- 419
							onTapped = function() return selectModel(item.id) end -- 419
						} -- 419
					) end -- 419
				) -- 419
			) -- 419
		else -- 419
			____modelPickerOpen_34 = nil -- 421
		end -- 421
		__TS__SparseArrayPush(____array_52, ____modelPickerOpen_34) -- 421
		local ____temp_35 -- 422
		if ____error ~= "" then -- 422
			____temp_35 = React.createElement( -- 422
				"label", -- 422
				{ -- 422
					tag = "remix-error", -- 422
					x = left + 20, -- 422
					y = bottom + ((questionnaire or modelPickerOpen) and 144 or composerTop + composerGap), -- 422
					anchorX = 0, -- 422
					anchorY = 0, -- 422
					fontName = fontName, -- 422
					fontSize = 13, -- 422
					text = ____error, -- 422
					textWidth = contentWidth, -- 422
					alignment = "Left", -- 422
					color3 = 16739179, -- 422
					onMount = function(label) -- 422
						errorLabel = label -- 422
					end -- 422
				} -- 422
			) -- 422
		else -- 422
			____temp_35 = nil -- 422
		end -- 422
		__TS__SparseArrayPush(____array_52, ____temp_35) -- 422
		local ____temp_36 -- 423
		if questionnaire == nil and not modelPickerOpen then -- 423
			____temp_36 = React.createElement( -- 423
				"node", -- 423
				nil, -- 423
				React.createElement( -- 423
					ChoiceButton, -- 424
					{ -- 424
						tag = "remix-mode-plan", -- 424
						x = left + 16, -- 424
						y = bottom + modeBottom, -- 424
						width = modeWidth, -- 424
						text = zh and "计划" or "Plan", -- 424
						selected = workMode == "plan", -- 424
						disabled = not canSubmit(), -- 424
						onTapped = function() return changeWorkMode("plan") end -- 424
					} -- 424
				), -- 424
				React.createElement( -- 424
					ChoiceButton, -- 425
					{ -- 425
						tag = "remix-mode-code", -- 425
						x = left + 16 + modeWidth + composerGap, -- 425
						y = bottom + modeBottom, -- 425
						width = contentWidth - modeWidth - composerGap, -- 425
						text = zh and "执行" or "Code", -- 425
						selected = workMode == "code", -- 425
						disabled = not canSubmit(), -- 425
						onTapped = function() return changeWorkMode("code") end -- 425
					} -- 425
				) -- 425
			) -- 425
		else -- 425
			____temp_36 = nil -- 426
		end -- 426
		__TS__SparseArrayPush(____array_52, ____temp_36) -- 426
		local ____temp_37 -- 427
		if questionnaire == nil and not modelPickerOpen and not keptInput then -- 427
			____temp_37 = React.createElement("node", { -- 427
				tag = "remix-input", -- 427
				ref = inputRef, -- 427
				x = left + 16, -- 427
				y = bottom + composerBottom, -- 427
				width = inputWidth, -- 427
				height = composerHeight, -- 427
				anchorX = 0, -- 427
				anchorY = 0, -- 427
				onMount = promptInput.mount -- 427
			}) -- 427
		else -- 427
			____temp_37 = nil -- 428
		end -- 428
		__TS__SparseArrayPush(____array_52, ____temp_37) -- 428
		local ____temp_50 -- 429
		if stopping or questionnaire == nil and not modelPickerOpen then -- 429
			local ____React_createElement_49 = React.createElement -- 429
			local ____ActionButton_48 = ActionButton -- 429
			local ____temp_43 = stopping and "remix-stop" or "remix-send" -- 429
			local ____temp_44 = left + 16 + inputWidth + composerGap -- 430
			local ____temp_45 = bottom + composerBottom -- 430
			local ____temp_46 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 431
			local ____temp_47 = not stopping -- 432
			local ____stopping_42 -- 432
			if stopping then -- 432
				____stopping_42 = stopRequested or (state and state.currentTaskFinalizing) == true -- 432
			else -- 432
				____stopping_42 = not canSubmit() -- 432
			end -- 432
			____temp_50 = ____React_createElement_49( -- 432
				____ActionButton_48, -- 429
				{ -- 429
					tag = ____temp_43, -- 429
					x = ____temp_44, -- 429
					y = ____temp_45, -- 429
					width = composerActionWidth, -- 429
					height = composerHeight, -- 429
					text = ____temp_46, -- 429
					primary = ____temp_47, -- 429
					danger = stopping, -- 429
					disabled = ____stopping_42, -- 429
					onTapped = function() -- 429
						if stopping then -- 429
							stop() -- 433
						elseif not dismissedComposition then -- 433
							send() -- 433
						end -- 433
						dismissedComposition = false -- 433
					end -- 433
				} -- 433
			) -- 433
		else -- 433
			____temp_50 = nil -- 433
		end -- 433
		__TS__SparseArrayPush(____array_52, ____temp_50) -- 433
		local ____temp_51 -- 434
		if phase == "done" then -- 434
			____temp_51 = React.createElement( -- 434
				ActionButton, -- 434
				{ -- 434
					tag = "remix-play", -- 434
					x = left + 16, -- 434
					y = bottom + 18, -- 434
					width = contentWidth, -- 434
					text = zh and "立即试玩" or "Play now", -- 434
					primary = true, -- 434
					onTapped = function() -- 434
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 434
							return -- 434
						end -- 434
						blurInput() -- 434
						host.visible = false -- 434
						onPlay(options.entry) -- 434
					end -- 434
				} -- 434
			) -- 434
		else -- 434
			____temp_51 = nil -- 434
		end -- 434
		__TS__SparseArrayPush(____array_52, ____temp_51) -- 434
		__TS__SparseArrayPush( -- 434
			____array_54, -- 434
			____React_createElement_53(__TS__SparseArraySpread(____array_52)) -- 434
		) -- 434
		local scene = ____toNode_56(____React_createElement_55(__TS__SparseArraySpread(____array_54))) -- 328
		if scene then -- 328
			host:addChild(scene) -- 438
			if keptInput then -- 438
				local ____opt_57 = pageRef.current -- 438
				if ____opt_57 ~= nil then -- 438
					____opt_57:addChild(keptInput) -- 439
				end -- 439
			end -- 439
			if not questionnaire and not modelPickerOpen then -- 439
				transcript.node.position = Vec2( -- 441
					left + 16, -- 441
					bottom + getTranscriptBottom() -- 441
				) -- 441
				local ____opt_59 = pageRef.current -- 441
				if ____opt_59 ~= nil then -- 441
					____opt_59:addChild(transcript.node) -- 442
				end -- 442
				updateTranscript() -- 443
			end -- 443
		end -- 443
		if restoreInputFocus and inputRef.current and not keptInput then -- 443
			promptInput.focus(false) -- 446
		end -- 446
		if keptInput then -- 446
			promptInput.refresh() -- 447
		end -- 447
		shellRevision = getShellRevision() -- 448
		displayRevision = remixDisplayRevision(detail) -- 449
	end -- 264
	host:schedule(function(dt) -- 452
		pollElapsed = pollElapsed + dt -- 453
		if pollElapsed < 0.25 then -- 453
			return false -- 454
		end -- 454
		pollElapsed = 0 -- 455
		refresh() -- 456
		if swipeDragging or swipeBackPending then -- 456
			return false -- 457
		end -- 457
		local next = remixDisplayRevision(detail) -- 458
		if shellRevision ~= getShellRevision() then -- 458
			render() -- 459
		elseif displayRevision ~= next then -- 459
			updateTranscript() -- 460
		end -- 460
		return false -- 461
	end) -- 452
	host:onAppChange(function(setting) -- 463
		if setting == "Size" or setting == "Locale" then -- 463
			render() -- 463
		end -- 463
	end) -- 463
	host:onAppEvent(function(event) -- 464
		if event == "BackButton" then -- 464
			if promptInput.isFocused() then -- 464
				blurInput() -- 465
			else -- 465
				goBack() -- 465
			end -- 465
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 465
			blurInput() -- 466
		end -- 466
	end) -- 464
	host:onCleanup(function() -- 468
		disposed = true -- 468
		blurInput() -- 468
	end) -- 468
	host:slot("SuspendLocalUI", blurInput) -- 469
	host:slot( -- 470
		"ResumeLocalUI", -- 470
		function() -- 470
			refresh() -- 470
			render() -- 470
		end -- 470
	) -- 470
	render() -- 471
	return host -- 472
end -- 73
return ____exports -- 73