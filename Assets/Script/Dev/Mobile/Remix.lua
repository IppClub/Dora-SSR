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
local Keyboard = ____Dora.Keyboard -- 2
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
local ____RemixInput = require("Dev.Mobile.RemixInput") -- 13
local createRemixInputView = ____RemixInput.createRemixInputView -- 13
local inputLength = ____RemixInput.inputLength -- 13
local inputSlice = ____RemixInput.inputSlice -- 13
local insertInputText = ____RemixInput.insertInputText -- 13
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
	local render -- 73
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
	local inputLabel -- 106
	local inputFocused = false -- 107
	local focusRevision = 0 -- 108
	local disposed = false -- 109
	local function refreshInputDisplay() -- 110
	end -- 110
	local dismissedComposition = false -- 111
	local swipeBackPending = false -- 112
	local swipeDragging = false -- 113
	local swipeRevision = 0 -- 114
	local composingText = "" -- 115
	local inputCursor = 0 -- 116
	local compositionCursor = 0 -- 117
	local inputView -- 118
	local function clearInputFocus() -- 119
		focusRevision = focusRevision + 1 -- 120
		inputFocused = false -- 121
		composingText = "" -- 122
		compositionCursor = 0 -- 123
		if inputRef.current then -- 123
			inputRef.current.keyboardEnabled = false -- 124
		end -- 124
		refreshInputDisplay() -- 125
	end -- 119
	local function blurInput() -- 127
		if inputFocused then -- 127
			local ____opt_0 = inputRef.current -- 127
			if ____opt_0 ~= nil then -- 127
				____opt_0:detachIME() -- 128
			end -- 128
		end -- 128
		clearInputFocus() -- 130
	end -- 127
	local function updateIMEPos(next) -- 132
		local input = inputRef.current -- 133
		local label = inputLabel -- 134
		if not input or not label then -- 134
			return -- 135
		end -- 135
		local revision = focusRevision -- 136
		local caret = inputView and inputView.caretPosition() or Vec2(12, 8) -- 137
		input:convertToWindowSpace( -- 138
			Vec2( -- 138
				math.max( -- 138
					12, -- 138
					math.min(input.width - 12, caret.x) -- 138
				), -- 138
				math.max( -- 138
					8, -- 138
					math.min(input.height - 8, caret.y) -- 138
				) -- 138
			), -- 138
			function(pos) -- 138
				if disposed or revision ~= focusRevision or inputRef.current ~= input then -- 138
					return -- 139
				end -- 139
				Keyboard:updateIMEPosHint(pos) -- 140
				if next ~= nil then -- 140
					next() -- 141
				end -- 141
			end -- 138
		) -- 138
	end -- 132
	local function updateInputLabel(text, placeholder) -- 144
		local label = inputLabel -- 145
		if not label then -- 145
			return -- 146
		end -- 146
		if inputView ~= nil then -- 146
			inputView.update(text, placeholder, inputFocused, inputCursor + compositionCursor) -- 147
		end -- 147
		if inputFocused then -- 147
			updateIMEPos() -- 148
		end -- 148
	end -- 144
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 150
	local ____temp_8 -- 151
	if rememberedRows and #rememberedRows > 0 then -- 151
		____temp_8 = tonumber(rememberedRows[1][1]) -- 151
	else -- 151
		____temp_8 = nil -- 151
	end -- 151
	local rememberedId = ____temp_8 -- 151
	if rememberedId and __TS__ArraySome( -- 151
		llmConfigs, -- 152
		function(____, item) return item.id == rememberedId end -- 152
	) then -- 152
		selectedLLMConfigId = rememberedId -- 152
	elseif #llmConfigs == 1 then -- 152
		selectedLLMConfigId = llmConfigs[1].id -- 153
	elseif #llmConfigs > 1 then -- 153
		modelPickerOpen = true -- 154
	else -- 154
		local activeConfig = services.getActiveLLMConfig() -- 156
		if activeConfig.success then -- 156
			selectedLLMConfigId = activeConfig.id -- 157
		end -- 157
	end -- 157
	local host = Node() -- 160
	host.tag = "mobile-remix" -- 161
	host.scaleX = App.devicePixelRatio -- 162
	host.scaleY = App.devicePixelRatio -- 163
	host:addTo(Director.systemUI) -- 164
	local transcript = createRemixTranscript() -- 165
	local displayRevision = "" -- 166
	local shellRevision = "" -- 167
	local inputLayout = "" -- 168
	local errorLabel -- 169
	local function getTranscriptBottom() -- 170
		return transcriptBottom + (errorLabel and errorLabel.height + composerGap or 0) -- 170
	end -- 170
	local function getShellRevision() -- 171
		local ____detail_success_12 -- 171
		if detail.success then -- 171
			local ____safeJsonEncode_11 = safeJsonEncode -- 171
			local ____array_10 = __TS__SparseArrayNew( -- 171
				detail.session.status, -- 172
				detail.session.workMode, -- 172
				detail.hasActivePlan, -- 172
				detail.pendingQuestionnaire or false, -- 172
				detail.session.currentTaskStatus or "" -- 173
			) -- 173
			local ____detail_session_currentTaskFinalizing_9 = detail.session.currentTaskFinalizing -- 173
			if ____detail_session_currentTaskFinalizing_9 == nil then -- 173
				____detail_session_currentTaskFinalizing_9 = false -- 173
			end -- 173
			__TS__SparseArrayPush(____array_10, ____detail_session_currentTaskFinalizing_9, stopRequested) -- 173
			____detail_success_12 = (____safeJsonEncode_11({__TS__SparseArraySpread(____array_10)})) or "" -- 171
		else -- 171
			____detail_success_12 = detail.message -- 174
		end -- 174
		return ____detail_success_12 -- 171
	end -- 171
	local function updateTranscript() -- 175
		local safe = App.safeArea -- 176
		transcript:update( -- 177
			detail, -- 177
			math.max(60, safe.width - 32), -- 177
			math.max( -- 177
				40, -- 177
				safe.height - getTranscriptBottom() - transcriptTopInset -- 177
			), -- 177
			mobileFontScale, -- 177
			zh -- 177
		) -- 177
		displayRevision = remixDisplayRevision(detail) -- 178
	end -- 175
	local function hasActiveTask() -- 181
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil) -- 181
	end -- 181
	local function refresh() -- 184
		if sessionId > 0 then -- 184
			detail = services.getSession(sessionId) -- 185
		end -- 185
		if detail.success and not hasActiveTask() then -- 185
			stopRequested = false -- 186
		end -- 186
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then -- 186
			questionnaireId = detail.pendingQuestionnaire.id -- 188
			questionIndex = 0 -- 189
		end -- 189
	end -- 184
	local function canSubmit() -- 192
		return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire -- 192
	end -- 192
	local function changeWorkMode(workMode) -- 195
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 195
			return -- 196
		end -- 196
		refresh() -- 197
		if not canSubmit() or not detail.success then -- 197
			return -- 198
		end -- 198
		if resolveRemixWorkMode(detail.session) == workMode then -- 198
			return -- 199
		end -- 199
		local result = services.setWorkMode(sessionId, workMode) -- 200
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode")) -- 201
		refresh() -- 202
		render() -- 203
	end -- 195
	local function send() -- 205
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 205
			return -- 206
		end -- 206
		refresh() -- 207
		if not canSubmit() or not detail.success or composingText ~= "" then -- 207
			return -- 208
		end -- 208
		local workMode = resolveRemixWorkMode(detail.session) -- 209
		local text = (string.match(draft, "^%s*(.-)%s*$")) or "" -- 212
		if sessionId <= 0 or text == "" then -- 212
			return -- 213
		end -- 213
		local config = selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig() -- 214
		if not config.success then -- 214
			____error = zh and "请先在桌面 Web IDE 中配置并启用一个模型" or "Configure and activate a model in Web IDE first" -- 216
			render() -- 217
			return -- 218
		end -- 218
		selectedLLMConfigId = config.id -- 220
		local result = services.sendPrompt( -- 221
			sessionId, -- 221
			text, -- 221
			nil, -- 221
			workMode, -- 221
			config.id, -- 221
			config.config -- 221
		) -- 221
		if not result.success then -- 221
			____error = result.message -- 222
		else -- 222
			draft = "" -- 223
			inputCursor = 0 -- 223
			____error = "" -- 223
		end -- 223
		refresh() -- 224
		render() -- 225
	end -- 205
	local function stop() -- 227
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 227
			return -- 228
		end -- 228
		refresh() -- 229
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then -- 229
			return -- 231
		end -- 231
		local result = services.stopSessionTask(sessionId) -- 232
		if (result and result.success) == false then -- 232
			____error = result.message or (zh and "停止失败" or "Could not stop") -- 233
		else -- 233
			stopRequested = true -- 234
			____error = "" -- 234
		end -- 234
		refresh() -- 235
		render() -- 236
	end -- 227
	local function selectModel(id) -- 238
		selectedLLMConfigId = id -- 239
		modelPickerOpen = false -- 240
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id}) -- 241
		____error = "" -- 242
		render() -- 243
	end -- 238
	local function advanceQuestionnaire() -- 245
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 245
			return -- 246
		end -- 246
		if not detail.success or not detail.pendingQuestionnaire then -- 246
			return -- 247
		end -- 247
		local pending = detail.pendingQuestionnaire -- 248
		local questions = pending.schema.questions -- 249
		local question = questions[questionIndex + 1] -- 250
		if not question then -- 250
			return -- 251
		end -- 251
		local selected = questionnaireSelections[question.id] or ({}) -- 252
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "") -- 253
		if not isQuestionAnswered(question, selected, text) then -- 253
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 255
			render() -- 256
			return -- 257
		end -- 257
		if questionIndex + 1 < #questions then -- 257
			questionIndex = questionIndex + 1 -- 260
			____error = "" -- 261
			render() -- 262
			return -- 263
		end -- 263
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 265
		if selectedLLMConfigId <= 0 then -- 265
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 267
			render() -- 268
			return -- 269
		end -- 269
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 271
		if not result.success then -- 271
			____error = result.message -- 272
		else -- 272
			____error = "" -- 273
		end -- 273
		refresh() -- 274
		render() -- 275
	end -- 245
	local function goBack() -- 277
		if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 277
			return -- 278
		end -- 278
		if detail.success and not canLeaveRemix(detail.session.status) then -- 278
			____error = zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back" -- 280
			render() -- 281
			return -- 282
		end -- 282
		blurInput() -- 284
		host.visible = false -- 285
		host:removeFromParent(true) -- 286
		onBack() -- 287
	end -- 277
	render = function() -- 290
		errorLabel = nil -- 291
		swipeRevision = swipeRevision + 1 -- 293
		swipeDragging = false -- 294
		swipeBackPending = false -- 295
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height) -- 296
		local ____temp_17 = layout == inputLayout and not modelPickerOpen and not (detail.success and detail.pendingQuestionnaire) -- 298
		if ____temp_17 then -- 298
			local ____opt_15 = inputRef.current -- 298
			____temp_17 = (____opt_15 and ____opt_15.tag) == "remix-input" -- 298
		end -- 298
		local keptInput = ____temp_17 and inputRef.current or nil -- 298
		if keptInput ~= nil then -- 298
			keptInput:removeFromParent(false) -- 300
		end -- 300
		transcript.node:removeFromParent(false) -- 301
		local restoreInputFocus = inputFocused -- 302
		if not keptInput then -- 302
			blurInput() -- 304
			inputRef = reference() -- 305
			inputLabel = nil -- 306
			inputView = nil -- 307
		end -- 307
		host:removeAllChildren() -- 309
		inputLayout = layout -- 310
		host.scaleX = App.devicePixelRatio -- 311
		host.scaleY = App.devicePixelRatio -- 312
		local ____App_visualSize_20 = App.visualSize -- 313
		local width = ____App_visualSize_20.width -- 313
		local height = ____App_visualSize_20.height -- 313
		local safe = App.safeArea -- 314
		local left = safe.x -- 315
		local bottom = safe.y -- 316
		local contentWidth = safe.width - 32 -- 317
		local inputWidth = contentWidth - composerActionWidth - composerGap -- 318
		local modeWidth = math.floor((contentWidth - composerGap) / 2) -- 319
		local state = detail.success and detail.session or nil -- 320
		local workMode = resolveRemixWorkMode(state) -- 321
		local stopping = hasActiveTask() -- 322
		local ____detail_success_21 -- 323
		if detail.success then -- 323
			____detail_success_21 = detail.hasActivePlan -- 323
		else -- 323
			____detail_success_21 = false -- 323
		end -- 323
		local hasActivePlan = ____detail_success_21 -- 323
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 324
		local ____detail_success_22 -- 325
		if detail.success then -- 325
			____detail_success_22 = detail.pendingQuestionnaire -- 325
		else -- 325
			____detail_success_22 = nil -- 325
		end -- 325
		local questionnaire = ____detail_success_22 -- 325
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 326
		local function focusInput(reopen) -- 327
			if reopen == nil then -- 327
				reopen = true -- 327
			end -- 327
			if disposed or not host.visible or HttpServer.wsConnectionCount > 0 then -- 327
				return -- 328
			end -- 328
			focusRevision = focusRevision + 1 -- 329
			updateIMEPos(function() -- 331
				if not host.visible or HttpServer.wsConnectionCount > 0 then -- 331
					return -- 332
				end -- 332
				if reopen then -- 332
					local ____opt_25 = inputRef.current -- 332
					if ____opt_25 ~= nil then -- 332
						____opt_25:detachIME() -- 333
					end -- 333
				end -- 333
				local ____opt_27 = inputRef.current -- 333
				if ____opt_27 ~= nil then -- 333
					____opt_27:attachIME() -- 334
				end -- 334
				updateIMEPos() -- 335
			end) -- 331
		end -- 327
		local inputPlaceholder = question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…")) -- 338
		local function getInputText() -- 339
			return question and (questionnaireTexts[question.id] or "") or draft -- 339
		end -- 339
		refreshInputDisplay = function() return updateInputLabel( -- 340
			getInputText(), -- 340
			inputPlaceholder -- 340
		) end -- 340
		local function setInputText(text, cursor) -- 341
			if cursor == nil then -- 341
				cursor = inputLength(text) -- 341
			end -- 341
			if question then -- 341
				questionnaireTexts[question.id] = text -- 342
			else -- 342
				draft = text -- 343
			end -- 343
			inputCursor = cursor -- 344
			updateInputLabel(text, inputPlaceholder) -- 345
		end -- 341
		local function attachInput() -- 347
			inputFocused = true -- 348
			composingText = "" -- 349
			compositionCursor = 0 -- 350
			if inputRef.current then -- 350
				inputRef.current.keyboardEnabled = true -- 351
			end -- 351
			updateInputLabel( -- 352
				getInputText(), -- 352
				inputPlaceholder -- 352
			) -- 352
		end -- 347
		local detachInput = clearInputFocus -- 354
		local function textInput(text) -- 355
			if not host.visible or HttpServer.wsConnectionCount > 0 then -- 355
				return -- 356
			end -- 356
			composingText = "" -- 357
			compositionCursor = 0 -- 358
			local normalized = (string.gsub((string.gsub(text, "\r\n", "\n")), "\r", "\n")) -- 359
			setInputText( -- 360
				insertInputText( -- 360
					getInputText(), -- 360
					inputCursor, -- 360
					normalized -- 360
				), -- 360
				inputCursor + inputLength(normalized) -- 360
			) -- 360
		end -- 355
		local function textEditing(text, start) -- 362
			if not host.visible or HttpServer.wsConnectionCount > 0 then -- 362
				return -- 363
			end -- 363
			composingText = text -- 364
			compositionCursor = math.max( -- 365
				0, -- 365
				math.min( -- 365
					inputLength(text), -- 365
					start or inputLength(text) -- 365
				) -- 365
			) -- 365
			updateInputLabel( -- 366
				insertInputText( -- 366
					getInputText(), -- 366
					inputCursor, -- 366
					text -- 366
				), -- 366
				inputPlaceholder -- 366
			) -- 366
		end -- 362
		local function keyInput(key) -- 368
			if not host.visible or HttpServer.wsConnectionCount > 0 then -- 368
				return -- 369
			end -- 369
			if key == "Escape" then -- 369
				blurInput() -- 370
				return -- 370
			end -- 370
			if composingText ~= "" then -- 370
				return -- 372
			end -- 372
			local value = getInputText() -- 373
			if key == "BackSpace" and inputCursor > 0 then -- 373
				setInputText( -- 374
					inputSlice(value, 0, inputCursor - 1) .. inputSlice(value, inputCursor), -- 374
					inputCursor - 1 -- 374
				) -- 374
			elseif key == "Delete" and inputCursor < inputLength(value) then -- 374
				setInputText( -- 375
					inputSlice(value, 0, inputCursor) .. inputSlice(value, inputCursor + 1), -- 375
					inputCursor -- 375
				) -- 375
			elseif key == "Left" or key == "Right" or key == "Home" or key == "End" or key == "Up" or key == "Down" then -- 375
				inputCursor = key == "Home" and 0 or (key == "End" and inputLength(value) or ((key == "Up" or key == "Down") and (inputView and inputView.verticalIndex(inputCursor, key == "Up" and -1 or 1) or inputCursor) or math.max( -- 377
					0, -- 379
					math.min( -- 379
						inputLength(value), -- 379
						inputCursor + (key == "Left" and -1 or 1) -- 379
					) -- 379
				))) -- 379
				updateInputLabel(value, inputPlaceholder) -- 380
			elseif key == "Return" then -- 380
				if not question and (Keyboard:isKeyPressed("LCtrl") or Keyboard:isKeyPressed("RCtrl") or Keyboard:isKeyPressed("LGui") or Keyboard:isKeyPressed("RGui")) then -- 380
					send() -- 383
				else -- 383
					textInput("\n") -- 384
				end -- 384
			end -- 384
		end -- 368
		local fontScale = mobileFontScale -- 387
		local function mountInput(node) -- 388
			inputView = createRemixInputView( -- 389
				node, -- 389
				math.floor(16 * fontScale) -- 389
			) -- 389
			inputLabel = inputView.label -- 390
			inputCursor = math.min( -- 391
				inputCursor, -- 391
				inputLength(getInputText()) -- 391
			) -- 391
			updateInputLabel( -- 392
				insertInputText( -- 392
					getInputText(), -- 392
					inputCursor, -- 392
					composingText -- 392
				), -- 392
				inputPlaceholder -- 392
			) -- 392
		end -- 388
		local dragDistance = 0 -- 394
		local function tapInput(touch) -- 395
			if dragDistance > 5 or not host.visible or HttpServer.wsConnectionCount > 0 then -- 395
				return -- 396
			end -- 396
			if touch and composingText == "" then -- 396
				inputCursor = inputView and inputView.indexAt(touch.location) or inputCursor -- 397
			end -- 397
			updateInputLabel( -- 398
				insertInputText( -- 398
					getInputText(), -- 398
					inputCursor, -- 398
					composingText -- 398
				), -- 398
				inputPlaceholder -- 398
			) -- 398
			if not inputFocused then -- 398
				focusInput() -- 399
			end -- 399
		end -- 395
		local pickerHeight = math.min(420, safe.height - 280) -- 401
		local statusText = phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game")))))) -- 402
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 409
		local messageTop = bottom + safe.height - statusTopInset - statusHeight / 2 -- 415
		local swipeStart = Vec2.zero -- 416
		local swipeAxis = "none" -- 417
		local pageRef = reference() -- 418
		local hitsTranscriptButton -- 419
		hitsTranscriptButton = function(node, world) -- 419
			if not node.visible then -- 419
				return false -- 420
			end -- 420
			if node.tag == "remix-copy" or node.tag == "remix-latest" then -- 420
				local p = node:convertToNodeSpace(world) -- 422
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 422
					return true -- 423
				end -- 423
			end -- 423
			local hit = false -- 425
			node:eachChild(function(child) -- 426
				hit = hitsTranscriptButton(child, world) -- 426
				return hit -- 426
			end) -- 426
			return hit -- 427
		end -- 419
		local ____toNode_77 = toNode -- 429
		local ____React_createElement_76 = React.createElement -- 429
		local ____array_75 = __TS__SparseArrayNew( -- 429
			"node", -- 429
			{ -- 429
				tag = "remix-scene", -- 429
				x = -width / 2, -- 429
				y = -height / 2, -- 429
				width = width, -- 429
				height = height, -- 429
				anchorX = 0, -- 429
				anchorY = 0 -- 429
			}, -- 429
			React.createElement( -- 429
				"node", -- 429
				{ -- 429
					tag = "remix-focus-observer", -- 429
					order = 1000, -- 429
					width = width, -- 429
					height = height, -- 429
					anchorX = 0, -- 429
					anchorY = 0, -- 429
					touchEnabled = true, -- 429
					swallowTouches = false, -- 429
					swallowMouseWheel = false, -- 429
					onTapFilter = function(touch) -- 429
						touch.enabled = false -- 433
						if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 433
							return -- 434
						end -- 434
						local input = inputRef.current -- 435
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 436
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 437
						dismissedComposition = not inside and composingText ~= "" -- 438
						if not inside then -- 438
							blurInput() -- 439
						end -- 439
						if not inside and not questionnaire and not modelPickerOpen and touch.first ~= false and touch.location.y >= bottom + transcriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 439
							touch.enabled = true -- 444
						end -- 444
					end, -- 432
					onTapBegan = function(touch) -- 432
						swipeStart = touch.location -- 448
						swipeAxis = "none" -- 448
						swipeDragging = true -- 448
						local ____opt_37 = pageRef.current -- 448
						if ____opt_37 ~= nil then -- 448
							____opt_37:stopAllActions() -- 449
						end -- 449
					end, -- 447
					onTapMoved = function(touch) -- 447
						local delta = touch.location:sub(swipeStart) -- 452
						if swipeAxis == "none" and math.max( -- 452
							math.abs(delta.x), -- 453
							math.abs(delta.y) -- 453
						) >= 12 then -- 453
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 454
						end -- 454
						if pageRef.current then -- 454
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 456
						end -- 456
					end, -- 451
					onTapEnded = function(touch) -- 451
						local delta = touch.location:sub(swipeStart) -- 459
						swipeDragging = false -- 460
						if swipeBackPending then -- 460
							return -- 461
						end -- 461
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 462
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 463
						local page = pageRef.current -- 464
						if not page or not requested and page.x == 0 then -- 464
							return -- 465
						end -- 465
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 466
						local revision = swipeRevision -- 467
						swipeBackPending = true -- 468
						if not leaving then -- 468
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 470
						end -- 470
						thread(function() -- 472
							sleep(duration) -- 473
							if disposed or revision ~= swipeRevision or not host.parent then -- 473
								return -- 474
							end -- 474
							swipeBackPending = false -- 475
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 475
								refresh() -- 476
								goBack() -- 476
							else -- 476
								page.position = Vec2.zero -- 477
							end -- 477
						end) -- 472
					end -- 458
				} -- 458
			), -- 458
			React.createElement( -- 458
				"draw-node", -- 458
				{x = width / 2, y = height / 2}, -- 458
				React.createElement("rect-shape", {width = width, height = height, fillColor = colors.background}) -- 458
			) -- 458
		) -- 458
		local ____React_createElement_74 = React.createElement -- 458
		local ____array_73 = __TS__SparseArrayNew( -- 458
			"node", -- 458
			{tag = "remix-page", ref = pageRef}, -- 458
			React.createElement( -- 458
				"clip-node", -- 458
				{ -- 458
					x = left + 16, -- 458
					y = bottom + safe.height - 56, -- 458
					width = safe.width - 124, -- 458
					height = 44, -- 458
					anchorX = 0, -- 458
					anchorY = 0, -- 458
					stencil = React.createElement( -- 458
						"draw-node", -- 458
						{x = (safe.width - 124) / 2, y = 22}, -- 458
						React.createElement("rect-shape", {width = safe.width - 124, height = 44, fillColor = 4294967295}) -- 458
					) -- 458
				}, -- 458
				React.createElement("label", { -- 458
					tag = "remix-title", -- 458
					x = 0, -- 458
					y = 22, -- 458
					anchorX = 0, -- 458
					fontName = fontName, -- 458
					fontSize = 20, -- 458
					text = "REMIX · " .. options.entry.title, -- 458
					color3 = 16052712 -- 458
				}) -- 458
			), -- 458
			React.createElement( -- 458
				"node", -- 458
				{ -- 458
					tag = "remix-back", -- 458
					x = left + safe.width - 96, -- 458
					y = bottom + safe.height - 56, -- 458
					width = 80, -- 458
					height = 44, -- 458
					anchorX = 0, -- 458
					anchorY = 0, -- 458
					touchEnabled = true, -- 458
					swallowTouches = true, -- 458
					onTapped = goBack -- 458
				}, -- 458
				React.createElement("label", { -- 458
					x = 80, -- 458
					y = 22, -- 458
					anchorX = 1, -- 458
					fontName = fontName, -- 458
					fontSize = 18, -- 458
					text = zh and "返回 ›" or "Back ›", -- 458
					color3 = 16763955 -- 458
				}) -- 458
			), -- 458
			React.createElement( -- 458
				"node", -- 458
				{ -- 458
					tag = "remix-status", -- 458
					y = messageTop - statusHeight / 2, -- 458
					width = width, -- 458
					height = statusHeight, -- 458
					anchorX = 0, -- 458
					anchorY = 0 -- 458
				}, -- 458
				React.createElement(DoraMascot, {state = mascotState, x = left + 66, y = statusHeight / 2 - 2, size = 52}), -- 458
				React.createElement( -- 458
					"label", -- 458
					{ -- 458
						x = left + 104, -- 458
						y = statusHeight / 2, -- 458
						anchorX = 0, -- 458
						fontName = fontName, -- 458
						fontSize = math.floor(15 * fontScale), -- 458
						text = statusText, -- 458
						textWidth = contentWidth - 84, -- 458
						alignment = "Left", -- 458
						color3 = phase == "failed" and 16739179 or 16763955 -- 458
					} -- 458
				) -- 458
			) -- 458
		) -- 458
		local ____temp_50 -- 494
		if questionnaire and question then -- 494
			local ____React_createElement_49 = React.createElement -- 494
			local ____array_48 = __TS__SparseArrayNew( -- 494
				"node", -- 494
				{ -- 494
					tag = "remix-questionnaire", -- 494
					x = left + 16, -- 494
					y = bottom + 164, -- 494
					width = contentWidth, -- 494
					height = safe.height - 330, -- 494
					anchorX = 0, -- 494
					anchorY = 0 -- 494
				}, -- 494
				React.createElement( -- 494
					"draw-node", -- 494
					{x = contentWidth / 2, y = (safe.height - 330) / 2}, -- 494
					React.createElement("rect-shape", { -- 494
						width = contentWidth, -- 494
						height = safe.height - 330, -- 494
						fillColor = colors.panel, -- 494
						borderWidth = 1, -- 494
						borderColor = colors.border -- 494
					}) -- 494
				), -- 494
				React.createElement( -- 494
					"label", -- 494
					{ -- 494
						x = 16, -- 494
						y = safe.height - 360, -- 494
						anchorX = 0, -- 494
						fontName = fontName, -- 494
						fontSize = 13, -- 494
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 494
						textWidth = contentWidth - 32, -- 494
						alignment = "Left", -- 494
						color3 = 16763955 -- 494
					} -- 494
				), -- 494
				React.createElement("label", { -- 494
					x = 16, -- 494
					y = safe.height - 405, -- 494
					anchorX = 0, -- 494
					fontName = fontName, -- 494
					fontSize = 16, -- 494
					text = question.prompt, -- 494
					textWidth = contentWidth - 32, -- 494
					alignment = "Left", -- 494
					color3 = 16052712 -- 494
				}), -- 494
				question.type ~= "text" and __TS__ArrayMap( -- 498
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 498
					function(____, option, optionIndex) return React.createElement( -- 498
						ChoiceButton, -- 498
						{ -- 498
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 498
							x = 16, -- 498
							y = safe.height - 460 - optionIndex * 43, -- 498
							width = contentWidth - 32, -- 498
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 498
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 498
							onTapped = function() -- 498
								local selected = questionnaireSelections[question.id] or ({}) -- 504
								local ____question_id_42 = question.id -- 505
								local ____temp_41 -- 505
								if question.type == "single_choice" then -- 505
									____temp_41 = {option.id} -- 506
								else -- 506
									local ____temp_40 -- 507
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 507
										____temp_40 = __TS__ArrayFilter( -- 507
											selected, -- 507
											function(____, id) return id ~= option.id end -- 507
										) -- 507
									else -- 507
										local ____array_39 = __TS__SparseArrayNew(table.unpack(selected)) -- 507
										__TS__SparseArrayPush(____array_39, option.id) -- 507
										____temp_40 = {__TS__SparseArraySpread(____array_39)} -- 507
									end -- 507
									____temp_41 = ____temp_40 -- 507
								end -- 507
								questionnaireSelections[____question_id_42] = ____temp_41 -- 505
								render() -- 508
							end -- 503
						} -- 503
					) end -- 503
				) or React.createElement( -- 503
					"node", -- 503
					{ -- 503
						ref = inputRef, -- 503
						x = 16, -- 503
						y = safe.height - 510, -- 503
						width = contentWidth - 32, -- 503
						height = 92, -- 503
						anchorX = 0, -- 503
						anchorY = 0, -- 503
						touchEnabled = true, -- 503
						swallowTouches = true, -- 503
						onTapped = tapInput, -- 503
						onMount = mountInput, -- 503
						onTapBegan = function() -- 503
							dragDistance = 0 -- 512
						end, -- 512
						onTapMoved = function(touch) -- 512
							dragDistance = dragDistance + math.abs(touch.delta.y) -- 512
							if inputView ~= nil then -- 512
								inputView.scroll(touch.delta.y) -- 512
							end -- 512
						end, -- 512
						onMouseWheel = function(delta) return inputView and inputView.scroll(-delta.y * 20) end, -- 512
						onAttachIME = attachInput, -- 512
						onDetachIME = detachInput, -- 512
						onTextInput = textInput, -- 512
						onTextEditing = textEditing, -- 512
						onKeyDown = keyInput -- 512
					}, -- 512
					React.createElement( -- 512
						"draw-node", -- 512
						{x = (contentWidth - 32) / 2, y = 46}, -- 512
						React.createElement("rect-shape", { -- 512
							width = contentWidth - 32, -- 512
							height = 92, -- 512
							fillColor = colors.background, -- 512
							borderWidth = 1, -- 512
							borderColor = colors.border -- 512
						}) -- 512
					) -- 512
				) -- 512
			) -- 512
			local ____temp_47 -- 518
			if questionIndex > 0 then -- 518
				____temp_47 = React.createElement( -- 518
					ActionButton, -- 518
					{ -- 518
						x = 16, -- 518
						y = 12, -- 518
						width = 92, -- 518
						text = zh and "上一步" or "Back", -- 518
						onTapped = function() -- 518
							questionIndex = questionIndex - 1 -- 518
							render() -- 518
						end -- 518
					} -- 518
				) -- 518
			else -- 518
				____temp_47 = nil -- 518
			end -- 518
			__TS__SparseArrayPush( -- 518
				____array_48, -- 518
				____temp_47, -- 518
				React.createElement( -- 518
					ActionButton, -- 519
					{ -- 519
						tag = "remix-question-submit", -- 519
						x = questionIndex > 0 and 120 or 16, -- 519
						y = 12, -- 519
						width = contentWidth - (questionIndex > 0 and 136 or 32), -- 519
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 519
						primary = true, -- 519
						onTapped = function() -- 519
							if not dismissedComposition then -- 519
								advanceQuestionnaire() -- 521
							end -- 521
							dismissedComposition = false -- 521
						end -- 521
					} -- 521
				) -- 521
			) -- 521
			____temp_50 = ____React_createElement_49(__TS__SparseArraySpread(____array_48)) -- 521
		else -- 521
			____temp_50 = nil -- 522
		end -- 522
		__TS__SparseArrayPush(____array_73, ____temp_50) -- 522
		local ____modelPickerOpen_51 -- 523
		if modelPickerOpen then -- 523
			____modelPickerOpen_51 = React.createElement( -- 523
				"node", -- 523
				{ -- 523
					x = left + 16, -- 523
					y = bottom + 164, -- 523
					width = contentWidth, -- 523
					height = pickerHeight, -- 523
					anchorX = 0, -- 523
					anchorY = 0, -- 523
					touchEnabled = true, -- 523
					swallowTouches = true -- 523
				}, -- 523
				React.createElement( -- 523
					"draw-node", -- 523
					{x = contentWidth / 2, y = pickerHeight / 2}, -- 523
					React.createElement("rect-shape", { -- 523
						width = contentWidth, -- 523
						height = pickerHeight, -- 523
						fillColor = colors.panel, -- 523
						borderWidth = 1, -- 523
						borderColor = colors.border -- 523
					}) -- 523
				), -- 523
				React.createElement("label", { -- 523
					x = 16, -- 523
					y = pickerHeight - 34, -- 523
					anchorX = 0, -- 523
					fontName = fontName, -- 523
					fontSize = 17, -- 523
					text = zh and "选择 Remix 使用的模型" or "Choose a model for Remix", -- 523
					textWidth = contentWidth - 32, -- 523
					alignment = "Left", -- 523
					color3 = 16052712 -- 523
				}), -- 523
				__TS__ArrayMap( -- 526
					__TS__ArraySlice(llmConfigs, 0, 8), -- 526
					function(____, item, i) return React.createElement( -- 526
						ChoiceButton, -- 526
						{ -- 526
							x = 16, -- 526
							y = pickerHeight - 90 - i * 43, -- 526
							width = contentWidth - 32, -- 526
							text = (item.name .. " · ") .. item.model, -- 526
							selected = item.id == selectedLLMConfigId, -- 526
							onTapped = function() return selectModel(item.id) end -- 526
						} -- 526
					) end -- 526
				) -- 526
			) -- 526
		else -- 526
			____modelPickerOpen_51 = nil -- 528
		end -- 528
		__TS__SparseArrayPush(____array_73, ____modelPickerOpen_51) -- 528
		local ____temp_52 -- 529
		if ____error ~= "" then -- 529
			____temp_52 = React.createElement( -- 529
				"label", -- 529
				{ -- 529
					tag = "remix-error", -- 529
					x = left + 20, -- 529
					y = bottom + ((questionnaire or modelPickerOpen) and 144 or composerTop + composerGap), -- 529
					anchorX = 0, -- 529
					anchorY = 0, -- 529
					fontName = fontName, -- 529
					fontSize = 13, -- 529
					text = ____error, -- 529
					textWidth = contentWidth, -- 529
					alignment = "Left", -- 529
					color3 = 16739179, -- 529
					onMount = function(label) -- 529
						errorLabel = label -- 529
					end -- 529
				} -- 529
			) -- 529
		else -- 529
			____temp_52 = nil -- 529
		end -- 529
		__TS__SparseArrayPush(____array_73, ____temp_52) -- 529
		local ____temp_53 -- 530
		if questionnaire == nil and not modelPickerOpen then -- 530
			____temp_53 = React.createElement( -- 530
				"node", -- 530
				nil, -- 530
				React.createElement( -- 530
					ChoiceButton, -- 531
					{ -- 531
						tag = "remix-mode-plan", -- 531
						x = left + 16, -- 531
						y = bottom + modeBottom, -- 531
						width = modeWidth, -- 531
						text = zh and "计划" or "Plan", -- 531
						selected = workMode == "plan", -- 531
						disabled = not canSubmit(), -- 531
						onTapped = function() return changeWorkMode("plan") end -- 531
					} -- 531
				), -- 531
				React.createElement( -- 531
					ChoiceButton, -- 532
					{ -- 532
						tag = "remix-mode-code", -- 532
						x = left + 16 + modeWidth + composerGap, -- 532
						y = bottom + modeBottom, -- 532
						width = contentWidth - modeWidth - composerGap, -- 532
						text = zh and "执行" or "Code", -- 532
						selected = workMode == "code", -- 532
						disabled = not canSubmit(), -- 532
						onTapped = function() return changeWorkMode("code") end -- 532
					} -- 532
				) -- 532
			) -- 532
		else -- 532
			____temp_53 = nil -- 533
		end -- 533
		__TS__SparseArrayPush(____array_73, ____temp_53) -- 533
		local ____temp_58 -- 534
		if questionnaire == nil and not modelPickerOpen and not keptInput then -- 534
			____temp_58 = React.createElement( -- 534
				"node", -- 534
				{ -- 534
					tag = "remix-input", -- 534
					ref = inputRef, -- 534
					x = left + 16, -- 534
					y = bottom + composerBottom, -- 534
					width = inputWidth, -- 534
					height = composerHeight, -- 534
					anchorX = 0, -- 534
					anchorY = 0, -- 534
					touchEnabled = true, -- 534
					swallowTouches = true, -- 534
					onTapped = tapInput, -- 534
					onMount = mountInput, -- 534
					onTapBegan = function() -- 534
						dragDistance = 0 -- 536
					end, -- 536
					onTapMoved = function(touch) -- 536
						dragDistance = dragDistance + math.abs(touch.delta.y) -- 536
						if inputView ~= nil then -- 536
							inputView.scroll(touch.delta.y) -- 536
						end -- 536
					end, -- 536
					onMouseWheel = function(delta) return inputView and inputView.scroll(-delta.y * 20) end, -- 536
					onAttachIME = attachInput, -- 536
					onDetachIME = detachInput, -- 536
					onTextInput = textInput, -- 536
					onTextEditing = textEditing, -- 536
					onKeyDown = keyInput -- 536
				}, -- 536
				React.createElement( -- 536
					"draw-node", -- 536
					{x = inputWidth / 2, y = composerHeight / 2}, -- 536
					React.createElement("rect-shape", { -- 536
						width = inputWidth, -- 536
						height = composerHeight, -- 536
						fillColor = colors.panel, -- 536
						borderWidth = 1, -- 536
						borderColor = colors.border -- 536
					}) -- 536
				) -- 536
			) -- 536
		else -- 536
			____temp_58 = nil -- 541
		end -- 541
		__TS__SparseArrayPush(____array_73, ____temp_58) -- 541
		local ____temp_71 -- 542
		if stopping or questionnaire == nil and not modelPickerOpen then -- 542
			local ____React_createElement_70 = React.createElement -- 542
			local ____ActionButton_69 = ActionButton -- 542
			local ____temp_64 = stopping and "remix-stop" or "remix-send" -- 542
			local ____temp_65 = left + 16 + inputWidth + composerGap -- 543
			local ____temp_66 = bottom + composerBottom -- 543
			local ____temp_67 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 544
			local ____temp_68 = not stopping -- 545
			local ____stopping_63 -- 545
			if stopping then -- 545
				____stopping_63 = stopRequested or (state and state.currentTaskFinalizing) == true -- 545
			else -- 545
				____stopping_63 = not canSubmit() -- 545
			end -- 545
			____temp_71 = ____React_createElement_70( -- 545
				____ActionButton_69, -- 542
				{ -- 542
					tag = ____temp_64, -- 542
					x = ____temp_65, -- 542
					y = ____temp_66, -- 542
					width = composerActionWidth, -- 542
					height = composerHeight, -- 542
					text = ____temp_67, -- 542
					primary = ____temp_68, -- 542
					danger = stopping, -- 542
					disabled = ____stopping_63, -- 542
					onTapped = function() -- 542
						if stopping then -- 542
							stop() -- 546
						elseif not dismissedComposition then -- 546
							send() -- 546
						end -- 546
						dismissedComposition = false -- 546
					end -- 546
				} -- 546
			) -- 546
		else -- 546
			____temp_71 = nil -- 546
		end -- 546
		__TS__SparseArrayPush(____array_73, ____temp_71) -- 546
		local ____temp_72 -- 547
		if phase == "done" then -- 547
			____temp_72 = React.createElement( -- 547
				ActionButton, -- 547
				{ -- 547
					tag = "remix-play", -- 547
					x = left + 16, -- 547
					y = bottom + 18, -- 547
					width = contentWidth, -- 547
					text = zh and "立即试玩" or "Play now", -- 547
					primary = true, -- 547
					onTapped = function() -- 547
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 547
							return -- 547
						end -- 547
						blurInput() -- 547
						host.visible = false -- 547
						onPlay(options.entry) -- 547
					end -- 547
				} -- 547
			) -- 547
		else -- 547
			____temp_72 = nil -- 547
		end -- 547
		__TS__SparseArrayPush(____array_73, ____temp_72) -- 547
		__TS__SparseArrayPush( -- 547
			____array_75, -- 547
			____React_createElement_74(__TS__SparseArraySpread(____array_73)) -- 547
		) -- 547
		local scene = ____toNode_77(____React_createElement_76(__TS__SparseArraySpread(____array_75))) -- 429
		if scene then -- 429
			host:addChild(scene) -- 551
			if keptInput then -- 551
				local ____opt_78 = pageRef.current -- 551
				if ____opt_78 ~= nil then -- 551
					____opt_78:addChild(keptInput) -- 552
				end -- 552
			end -- 552
			if not questionnaire and not modelPickerOpen then -- 552
				transcript.node.position = Vec2( -- 554
					left + 16, -- 554
					bottom + getTranscriptBottom() -- 554
				) -- 554
				local ____opt_80 = pageRef.current -- 554
				if ____opt_80 ~= nil then -- 554
					____opt_80:addChild(transcript.node) -- 555
				end -- 555
				updateTranscript() -- 556
			end -- 556
		end -- 556
		if restoreInputFocus and inputRef.current and not keptInput then -- 556
			focusInput(false) -- 559
		end -- 559
		if keptInput then -- 559
			updateInputLabel( -- 560
				insertInputText(draft, inputCursor, composingText), -- 560
				inputPlaceholder -- 560
			) -- 560
		end -- 560
		shellRevision = getShellRevision() -- 561
		displayRevision = remixDisplayRevision(detail) -- 562
	end -- 290
	host:schedule(function(dt) -- 565
		pollElapsed = pollElapsed + dt -- 566
		if pollElapsed < 0.25 then -- 566
			return false -- 567
		end -- 567
		pollElapsed = 0 -- 568
		refresh() -- 569
		if swipeDragging or swipeBackPending then -- 569
			return false -- 570
		end -- 570
		local next = remixDisplayRevision(detail) -- 571
		if shellRevision ~= getShellRevision() then -- 571
			render() -- 572
		elseif displayRevision ~= next then -- 572
			updateTranscript() -- 573
		end -- 573
		return false -- 574
	end) -- 565
	host:onAppChange(function(setting) -- 576
		if setting == "Size" or setting == "Locale" then -- 576
			render() -- 576
		end -- 576
	end) -- 576
	host:onAppEvent(function(event) -- 577
		if event == "BackButton" then -- 577
			if inputFocused then -- 577
				blurInput() -- 578
			else -- 578
				goBack() -- 578
			end -- 578
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 578
			blurInput() -- 579
		end -- 579
	end) -- 577
	host:onCleanup(function() -- 581
		disposed = true -- 581
		blurInput() -- 581
	end) -- 581
	host:slot("SuspendLocalUI", blurInput) -- 582
	host:slot( -- 583
		"ResumeLocalUI", -- 583
		function() -- 583
			refresh() -- 583
			render() -- 583
		end -- 583
	) -- 583
	render() -- 584
	return host -- 585
end -- 73
return ____exports -- 73