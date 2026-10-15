-- [tsx]: Remix.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local reference = ____DoraX.reference -- 1
local toNode = ____DoraX.toNode -- 1
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 2
local attachGamepad = ____Gamepad.attachGamepad -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local DB = ____Dora.DB -- 3
local Director = ____Dora.Director -- 3
local Ease = ____Dora.Ease -- 3
local HttpServer = ____Dora.HttpServer -- 3
local Label = ____Dora.Label -- 3
local Move = ____Dora.Move -- 3
local Node = ____Dora.Node -- 3
local sleep = ____Dora.sleep -- 3
local thread = ____Dora.thread -- 3
local Vec2 = ____Dora.Vec2 -- 3
local AgentSession = require("Agent.Session") -- 4
local ____Utils = require("Agent.Utils") -- 5
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 5
local getLLMConfig = ____Utils.getLLMConfig -- 5
local getLLMConfigSummaries = ____Utils.getLLMConfigSummaries -- 5
local safeJsonEncode = ____Utils.safeJsonEncode -- 5
local ____RemixModel = require("Dev.Mobile.RemixModel") -- 8
local buildQuestionnaireAnswers = ____RemixModel.buildQuestionnaireAnswers -- 8
local canLeaveRemix = ____RemixModel.canLeaveRemix -- 8
local isQuestionAnswered = ____RemixModel.isQuestionAnswered -- 8
local resolveRemixPhase = ____RemixModel.resolveRemixPhase -- 8
local resolveRemixThinkingStatus = ____RemixModel.resolveRemixThinkingStatus -- 8
local resolveRemixWorkMode = ____RemixModel.resolveRemixWorkMode -- 8
local ____Mascot = require("Dev.Mobile.Mascot") -- 9
local DoraMascot = ____Mascot.DoraMascot -- 9
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 10
local mobileFontScale = ____Accessibility.mobileFontScale -- 10
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 11
local resolveFeedGesture = ____FeedModel.resolveFeedGesture -- 11
local ____RemixTranscript = require("Dev.Mobile.RemixTranscript") -- 12
local createRemixTranscript = ____RemixTranscript.createRemixTranscript -- 12
local remixDisplayRevision = ____RemixTranscript.remixDisplayRevision -- 12
local ____RemixHistory = require("Dev.Mobile.RemixHistory") -- 13
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS -- 13
local ____TextInput = require("Dev.Mobile.TextInput") -- 14
local createTextInput = ____TextInput.createTextInput -- 14
local inputLength = ____TextInput.inputLength -- 14
local inputSlice = ____TextInput.inputSlice -- 14
local ____LLMSetup = require("Dev.Mobile.LLMSetup") -- 15
local startMobileLLMManager = ____LLMSetup.startMobileLLMManager -- 15
local ____PackagePanel = require("Dev.Mobile.PackagePanel") -- 16
local startPackagePanel = ____PackagePanel.startPackagePanel -- 16
local ____Visual = require("Dev.Mobile.Visual") -- 17
local RoundedSurface = ____Visual.RoundedSurface -- 17
local VerticalGradient = ____Visual.VerticalGradient -- 17
local ____Controls = require("Dev.Mobile.Controls") -- 18
local ChoiceButton = ____Controls.MobileChoiceButton -- 18
local fontName = "sarasa-mono-sc-regular" -- 50
local colors = { -- 51
	background = 4278914322, -- 51
	panel = 4279704614, -- 51
	text = 4294242792, -- 51
	muted = 4289245117, -- 51
	brand = 4294954035, -- 51
	border = 4281613128, -- 51
	danger = 4294929259 -- 51
} -- 51
local composerGap = 12 -- 53
local composerBottom = 76 -- 54
local composerHeight = 60 -- 55
local composerActionWidth = 82 -- 56
local modeBottom = composerBottom + composerHeight + composerGap -- 57
local composerTop = modeBottom + 40 -- 58
local transcriptBottom = composerTop + composerGap -- 59
local statusHeight = 64 -- 60
local function ellipsizeSingleLine(text, width, fontSize) -- 62
	if text == "" then -- 62
		return "" -- 63
	end -- 63
	local measure = Label(fontName, fontSize, true) -- 64
	if not measure then -- 64
		return text -- 65
	end -- 65
	measure.visible = false -- 66
	measure.textWidth = -1 -- 67
	local function fits(value) -- 68
		measure.text = value -- 68
		return measure.width <= width -- 68
	end -- 68
	if fits(text) then -- 68
		measure:cleanup() -- 69
		return text -- 69
	end -- 69
	local low = 0 -- 70
	local high = inputLength(text) -- 70
	while low < high do -- 70
		local middle = math.floor((low + high + 1) / 2) -- 72
		if fits(inputSlice(text, 0, middle) .. "…") then -- 72
			low = middle -- 73
		else -- 73
			high = middle - 1 -- 74
		end -- 74
	end -- 74
	local result = inputSlice(text, 0, low) .. "…" -- 76
	measure:cleanup() -- 77
	return result -- 78
end -- 62
local function measureWrappedTextHeight(text, width, fontSize) -- 81
	local measure = Label(fontName, fontSize, true) -- 82
	if not measure then -- 82
		return fontSize -- 83
	end -- 83
	measure.visible = false -- 84
	measure.textWidth = width -- 85
	measure.alignment = "Left" -- 86
	measure.text = text -- 87
	local height = measure.height -- 88
	measure:cleanup() -- 89
	return height -- 90
end -- 81
local function ActionButton(props) -- 93
	local height = props.height or 46 -- 94
	return React.createElement( -- 95
		"node", -- 95
		{ -- 95
			tag = props.tag, -- 95
			x = props.x, -- 95
			y = props.y, -- 95
			width = props.width, -- 95
			height = height, -- 95
			anchorX = 0, -- 95
			anchorY = 0, -- 95
			opacity = props.disabled and 0.45 or 1, -- 95
			touchEnabled = not props.disabled, -- 95
			swallowTouches = true, -- 95
			onTapped = props.onTapped -- 95
		}, -- 95
		React.createElement(RoundedSurface, { -- 95
			width = props.width, -- 95
			height = height, -- 95
			radius = 14, -- 95
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 95
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279704871), -- 95
			borderWidth = 1, -- 95
			borderColor = props.danger and colors.danger or (props.primary and 4294958435 or colors.border), -- 95
			shadow = props.primary or props.danger -- 95
		}), -- 95
		React.createElement("label", { -- 95
			x = props.width / 2, -- 95
			y = height / 2, -- 95
			fontName = fontName, -- 95
			fontSize = 15, -- 95
			text = props.text, -- 95
			color3 = props.primary and 1512202 or 16052712 -- 95
		}) -- 95
	) -- 95
end -- 93
function ____exports.startMobileRemix(options) -- 104
	local host, send, getTranscriptActions, render -- 104
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 105
	local onBack = options.onBack -- 106
	local onPlay = options.onPlay -- 107
	local packagePanel -- 108
	local services = options.services or ({ -- 109
		createSession = AgentSession.createSession, -- 110
		getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end, -- 111
		setWorkMode = AgentSession.setWorkMode, -- 112
		sendPrompt = AgentSession.sendPrompt, -- 113
		respondQuestionnaire = AgentSession.respondQuestionnaire, -- 114
		stopSessionTask = AgentSession.stopSessionTask, -- 115
		continuePrompt = AgentSession.continuePrompt, -- 116
		getActiveLLMConfig = getActiveLLMConfig, -- 117
		getLLMConfig = getLLMConfig, -- 118
		getLLMConfigSummaries = getLLMConfigSummaries -- 119
	}) -- 119
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 121
	local projectRoot = options.entry.workDir or "" -- 122
	local created = services.createSession(projectRoot, options.entry.title) -- 123
	local sessionId = created.success and created.session.id or 0 -- 124
	local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message}) -- 125
	local draft = "" -- 128
	local ____error = created.success and "" or created.message -- 129
	local backNoticeUntil = 0 -- 130
	local pollElapsed = 0 -- 131
	local stopRequested = false -- 132
	local selectedLLMConfigId = 0 -- 133
	local questionnaireId = 0 -- 134
	local questionIndex = 0 -- 135
	local llmConfigs = services.getLLMConfigSummaries() -- 136
	local taskLLMConfigId = 0 -- 137
	local needsLLMSetup = false -- 138
	local questionnaireSelections = {} -- 139
	local questionnaireTexts = {} -- 140
	local inputRef = reference() -- 141
	local disposed = false -- 142
	local dismissedComposition = false -- 143
	local swipeBackPending = false -- 144
	local swipeDragging = false -- 145
	local swipeRevision = 0 -- 146
	local projectChangeNotified = false -- 147
	local function currentQuestion() -- 148
		local ____detail_success_2 -- 148
		if detail.success then -- 148
			local ____opt_0 = detail.pendingQuestionnaire -- 148
			____detail_success_2 = ____opt_0 and ____opt_0.schema.questions[questionIndex + 1] -- 148
		else -- 148
			____detail_success_2 = nil -- 148
		end -- 148
		return ____detail_success_2 -- 148
	end -- 148
	local promptInput = createTextInput({ -- 149
		fontSize = math.floor(16 * mobileFontScale), -- 150
		getText = function() -- 151
			local question = currentQuestion() -- 151
			return question and (questionnaireTexts[question.id] or "") or draft -- 151
		end, -- 151
		setText = function(text) -- 152
			local question = currentQuestion() -- 152
			if question then -- 152
				questionnaireTexts[question.id] = text -- 152
			else -- 152
				draft = text -- 152
			end -- 152
		end, -- 152
		getPlaceholder = function() -- 153
			local question = currentQuestion() -- 154
			return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…")) -- 155
		end, -- 153
		isEnabled = function() return not packagePanel and not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end, -- 157
		onReturn = function(modified) -- 158
			if modified and not currentQuestion() then -- 158
				send() -- 158
				return true -- 158
			end -- 158
			return false -- 158
		end -- 158
	}) -- 158
	local blurInput = promptInput.blur -- 160
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 161
	local ____temp_5 -- 162
	if rememberedRows and #rememberedRows > 0 then -- 162
		____temp_5 = tonumber(rememberedRows[1][1]) -- 162
	else -- 162
		____temp_5 = nil -- 162
	end -- 162
	local rememberedId = ____temp_5 -- 162
	if rememberedId and __TS__ArraySome( -- 162
		llmConfigs, -- 163
		function(____, item) return item.id == rememberedId end -- 163
	) then -- 163
		selectedLLMConfigId = rememberedId -- 163
	elseif #llmConfigs > 0 then -- 163
		selectedLLMConfigId = llmConfigs[1].id -- 164
	else -- 164
		local activeConfig = services.getActiveLLMConfig() -- 166
		if activeConfig.success then -- 166
			selectedLLMConfigId = activeConfig.id -- 167
		else -- 167
			needsLLMSetup = true -- 168
		end -- 168
	end -- 168
	host = Node() -- 171
	host.tag = "mobile-remix" -- 172
	host.scaleX = App.devicePixelRatio -- 173
	host.scaleY = App.devicePixelRatio -- 174
	host:addTo(Director.systemUI) -- 175
	local transcript = createRemixTranscript() -- 176
	local displayRevision = "" -- 177
	local shellRevision = "" -- 178
	local inputLayout = "" -- 179
	local mascotAnimationState -- 180
	local mascotAnimationStartedAt = App.runningTime -- 181
	local compactHeaderStatusActive = false -- 182
	local errorLabel -- 183
	local layoutTranscriptBottom = transcriptBottom -- 184
	local function getLayoutArea() -- 185
		return App.safeArea -- 185
	end -- 185
	local function getTranscriptBottom() -- 186
		return layoutTranscriptBottom + (errorLabel and errorLabel.height + composerGap or 0) -- 186
	end -- 186
	local function hasTranscriptContent() -- 187
		return detail.success and (#detail.messages > 0 or #detail.steps > 0) -- 187
	end -- 187
	local function getHeaderY(safe) -- 188
		local landscapeTopLift = safe.width >= 760 and safe.height < 500 and 28 or 0 -- 189
		return safe.y + safe.height - 56 + landscapeTopLift -- 190
	end -- 188
	local function useCompactHeaderStatus(safe) -- 192
		return safe.width >= 760 and safe.height < 500 and hasTranscriptContent() -- 192
	end -- 192
	local function useCompactStandaloneStatus(safe) -- 193
		return safe.height >= 500 and hasTranscriptContent() -- 193
	end -- 193
	local function getTranscriptHeight(safe) -- 194
		local statusInset = useCompactHeaderStatus(safe) and composerGap or statusHeight + composerGap * 2 - (useCompactStandaloneStatus(safe) and 24 or 0) -- 195
		local available = math.max( -- 197
			40, -- 197
			getHeaderY(safe) - safe.y - getTranscriptBottom() - statusInset -- 197
		) -- 197
		return safe.width >= 760 and safe.height < 500 and not hasTranscriptContent() and 8 or available -- 198
	end -- 194
	local function getShellRevision() -- 200
		local ____detail_success_9 -- 200
		if detail.success then -- 200
			local ____safeJsonEncode_8 = safeJsonEncode -- 200
			local ____array_7 = __TS__SparseArrayNew( -- 200
				detail.session.status, -- 201
				detail.session.workMode, -- 201
				detail.hasActivePlan, -- 201
				detail.pendingQuestionnaire or false, -- 201
				detail.session.currentTaskStatus or "" -- 202
			) -- 202
			local ____detail_session_currentTaskFinalizing_6 = detail.session.currentTaskFinalizing -- 202
			if ____detail_session_currentTaskFinalizing_6 == nil then -- 202
				____detail_session_currentTaskFinalizing_6 = false -- 202
			end -- 202
			__TS__SparseArrayPush( -- 202
				____array_7, -- 202
				____detail_session_currentTaskFinalizing_6, -- 202
				stopRequested, -- 202
				hasTranscriptContent(), -- 202
				resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or "" -- 203
			) -- 203
			____detail_success_9 = (____safeJsonEncode_8({__TS__SparseArraySpread(____array_7)})) or "" -- 200
		else -- 200
			____detail_success_9 = detail.message -- 204
		end -- 204
		return ____detail_success_9 -- 200
	end -- 200
	local function updateTranscript() -- 205
		local safe = getLayoutArea() -- 206
		transcript:update( -- 207
			detail, -- 207
			math.max(60, safe.width - 32), -- 207
			getTranscriptHeight(safe), -- 207
			mobileFontScale, -- 207
			zh, -- 207
			getTranscriptActions() -- 207
		) -- 207
		displayRevision = remixDisplayRevision(detail) -- 208
	end -- 205
	local function hasActiveTask() -- 211
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil) -- 211
	end -- 211
	local function notifyProjectChanged() -- 214
		if projectChangeNotified or not detail.success or not options.onProjectChanged then -- 214
			return -- 215
		end -- 215
		if not __TS__ArraySome( -- 215
			detail.steps, -- 216
			function(____, step) return step.files ~= nil and #step.files > 0 end -- 216
		) then -- 216
			return -- 216
		end -- 216
		projectChangeNotified = true -- 217
		options.onProjectChanged(options.entry) -- 218
	end -- 214
	local function refresh() -- 220
		if sessionId > 0 then -- 220
			detail = services.getSession(sessionId) -- 221
		end -- 221
		if detail.success and not hasActiveTask() then -- 221
			stopRequested = false -- 222
		end -- 222
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then -- 222
			questionnaireId = detail.pendingQuestionnaire.id -- 224
			questionIndex = 0 -- 225
		end -- 225
	end -- 220
	local function canSubmit() -- 228
		return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire -- 228
	end -- 228
	local function resolveLLMConfig() -- 231
		return selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig() -- 231
	end -- 231
	local function configureLLM() -- 232
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 232
			return -- 233
		end -- 233
		blurInput() -- 234
		startMobileLLMManager({ -- 235
			coveredNode = host, -- 236
			selectedId = selectedLLMConfigId, -- 237
			taskRunning = hasActiveTask(), -- 238
			runningId = taskLLMConfigId, -- 239
			onSelected = function(id) -- 240
				if disposed or not host.parent then -- 240
					return -- 241
				end -- 241
				llmConfigs = services.getLLMConfigSummaries() -- 242
				selectedLLMConfigId = id -- 243
				needsLLMSetup = #llmConfigs == 0 -- 244
				____error = "" -- 245
				render() -- 246
			end, -- 240
			onClose = function() -- 248
				if not disposed and host.parent then -- 248
					render() -- 248
				end -- 248
			end -- 248
		}) -- 248
	end -- 232
	local function changeWorkMode(workMode) -- 251
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 251
			return -- 252
		end -- 252
		refresh() -- 253
		if not canSubmit() or not detail.success then -- 253
			return -- 254
		end -- 254
		if resolveRemixWorkMode(detail.session) == workMode then -- 254
			return -- 255
		end -- 255
		local result = services.setWorkMode(sessionId, workMode) -- 256
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode")) -- 257
		refresh() -- 258
		render() -- 259
	end -- 251
	send = function() -- 261
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 261
			return -- 262
		end -- 262
		refresh() -- 263
		if not canSubmit() or not detail.success or promptInput.isComposing() then -- 263
			return -- 264
		end -- 264
		local workMode = resolveRemixWorkMode(detail.session) -- 265
		local text = (string.match(draft, "^%s*(.-)%s*$")) or "" -- 268
		if sessionId <= 0 or text == "" then -- 268
			return -- 269
		end -- 269
		local config = resolveLLMConfig() -- 270
		if not config.success then -- 270
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 272
			render() -- 273
			configureLLM() -- 274
			return -- 275
		end -- 275
		selectedLLMConfigId = config.id -- 277
		local result = services.sendPrompt( -- 278
			sessionId, -- 278
			text, -- 278
			nil, -- 278
			workMode, -- 278
			config.id, -- 278
			config.config -- 278
		) -- 278
		if not result.success then -- 278
			____error = result.message -- 279
		else -- 279
			taskLLMConfigId = config.id -- 280
			draft = "" -- 280
			____error = "" -- 280
		end -- 280
		refresh() -- 281
		render() -- 282
	end -- 261
	local function continueTask() -- 284
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 284
			return -- 285
		end -- 285
		refresh() -- 286
		if not detail.success or hasActiveTask() or detail.session.currentTaskStatus ~= "FAILED" and detail.session.currentTaskStatus ~= "STOPPED" or detail.session.currentTaskId == nil then -- 286
			return -- 288
		end -- 288
		local config = resolveLLMConfig() -- 289
		if not config.success then -- 289
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 291
			render() -- 292
			configureLLM() -- 293
			return -- 294
		end -- 294
		if not services.continuePrompt then -- 294
			____error = zh and "当前版本不支持继续会话" or "Continuing this session is unavailable" -- 297
			render() -- 298
			return -- 299
		end -- 299
		selectedLLMConfigId = config.id -- 301
		local result = services.continuePrompt(sessionId, nil, config.id) -- 302
		____error = result.success and "" or result.message -- 303
		if result.success then -- 303
			taskLLMConfigId = config.id -- 304
			stopRequested = false -- 304
		end -- 304
		refresh() -- 305
		render() -- 306
	end -- 284
	local function startDevelopment() -- 308
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 308
			return -- 309
		end -- 309
		refresh() -- 310
		if not detail.success or hasActiveTask() or detail.session.workMode ~= "plan" or not detail.hasActivePlan then -- 310
			return -- 311
		end -- 311
		local modeResult = services.setWorkMode(sessionId, "code") -- 312
		if not modeResult.success then -- 312
			____error = modeResult.message or (zh and "切换执行模式失败" or "Could not switch to Code mode") -- 314
			render() -- 315
			return -- 316
		end -- 316
		local config = resolveLLMConfig() -- 318
		if not config.success then -- 318
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 320
			refresh() -- 321
			render() -- 322
			configureLLM() -- 323
			return -- 324
		end -- 324
		selectedLLMConfigId = config.id -- 326
		local prompt = zh and "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。" or "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated." -- 327
		local result = services.sendPrompt( -- 330
			sessionId, -- 330
			prompt, -- 330
			nil, -- 330
			"code", -- 330
			config.id, -- 330
			config.config -- 330
		) -- 330
		____error = result.success and "" or result.message -- 331
		if result.success then -- 331
			taskLLMConfigId = config.id -- 332
		end -- 332
		refresh() -- 333
		render() -- 334
	end -- 308
	getTranscriptActions = function() -- 336
		if not detail.success or not hasTranscriptContent() or hasActiveTask() or __TS__ArrayEvery( -- 336
			detail.messages, -- 337
			function(____, message) return message.role ~= "assistant" end -- 337
		) then -- 337
			return {} -- 337
		end -- 337
		local actions = {} -- 338
		if (detail.session.currentTaskStatus == "FAILED" or detail.session.currentTaskStatus == "STOPPED") and detail.session.currentTaskId ~= nil then -- 338
			actions[#actions + 1] = {id = "continue", text = zh and "继续" or "Continue", onTapped = continueTask} -- 340
		end -- 340
		if detail.session.kind == "main" and detail.session.workMode == "plan" and detail.hasActivePlan then -- 340
			actions[#actions + 1] = {id = "start-development", text = zh and "开始开发" or "Start development", primary = true, onTapped = startDevelopment} -- 342
		end -- 342
		return actions -- 343
	end -- 336
	local function stop() -- 345
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 345
			return -- 346
		end -- 346
		refresh() -- 347
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then -- 347
			return -- 349
		end -- 349
		local result = services.stopSessionTask(sessionId) -- 350
		if (result and result.success) == false then -- 350
			____error = result.message or (zh and "停止失败" or "Could not stop") -- 351
		else -- 351
			stopRequested = true -- 352
			____error = "" -- 352
		end -- 352
		refresh() -- 353
		render() -- 354
	end -- 345
	local function advanceQuestionnaire(skipCurrent) -- 356
		if skipCurrent == nil then -- 356
			skipCurrent = false -- 356
		end -- 356
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 356
			return -- 357
		end -- 357
		if not detail.success or not detail.pendingQuestionnaire then -- 357
			return -- 358
		end -- 358
		local pending = detail.pendingQuestionnaire -- 359
		local questions = pending.schema.questions -- 360
		local question = questions[questionIndex + 1] -- 361
		if not question then -- 361
			return -- 362
		end -- 362
		local selected = questionnaireSelections[question.id] or ({}) -- 363
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "") -- 364
		if skipCurrent then -- 364
			if question.required then -- 364
				return -- 366
			end -- 366
			questionnaireSelections[question.id] = {} -- 367
			questionnaireTexts[question.id] = "" -- 368
		elseif not isQuestionAnswered(question, selected, text) then -- 368
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 370
			render() -- 371
			return -- 372
		end -- 372
		if questionIndex + 1 < #questions then -- 372
			questionIndex = questionIndex + 1 -- 375
			____error = "" -- 376
			render() -- 377
			return -- 378
		end -- 378
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 380
		if selectedLLMConfigId <= 0 then -- 380
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 382
			render() -- 383
			return -- 384
		end -- 384
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 386
		if not result.success then -- 386
			____error = result.message -- 387
		else -- 387
			taskLLMConfigId = selectedLLMConfigId -- 388
			____error = "" -- 388
		end -- 388
		refresh() -- 389
		render() -- 390
	end -- 356
	local function goBack() -- 392
		if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 392
			return -- 393
		end -- 393
		if detail.success and not canLeaveRemix(detail.session.status) then -- 393
			____error = "" -- 395
			backNoticeUntil = App.runningTime + 3 -- 396
			render() -- 397
			return -- 398
		end -- 398
		blurInput() -- 400
		notifyProjectChanged() -- 401
		host.visible = false -- 402
		host:removeFromParent(true) -- 403
		onBack() -- 404
	end -- 392
	render = function() -- 407
		local visibleError = ____error ~= "" and ____error or (backNoticeUntil > App.runningTime and (zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back") or "") -- 408
		errorLabel = nil -- 410
		swipeRevision = swipeRevision + 1 -- 412
		swipeDragging = false -- 413
		swipeBackPending = false -- 414
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height) -- 415
		local ____temp_14 = layout == inputLayout and not (detail.success and detail.pendingQuestionnaire) -- 417
		if ____temp_14 then -- 417
			local ____opt_12 = inputRef.current -- 417
			____temp_14 = (____opt_12 and ____opt_12.tag) == "remix-input" -- 417
		end -- 417
		local keptInput = ____temp_14 and inputRef.current or nil -- 417
		if keptInput ~= nil then -- 417
			keptInput:removeFromParent(false) -- 419
		end -- 419
		transcript.node:removeFromParent(false) -- 420
		local restoreInputFocus = promptInput.isFocused() -- 421
		if not keptInput then -- 421
			promptInput.unmount() -- 423
			inputRef = reference() -- 424
		end -- 424
		host:removeAllChildren() -- 426
		inputLayout = layout -- 427
		host.scaleX = App.devicePixelRatio -- 428
		host.scaleY = App.devicePixelRatio -- 429
		local ____App_visualSize_17 = App.visualSize -- 430
		local width = ____App_visualSize_17.width -- 430
		local height = ____App_visualSize_17.height -- 430
		local safe = getLayoutArea() -- 431
		local left = safe.x -- 432
		local bottom = safe.y -- 433
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 434
		local state = detail.success and detail.session or nil -- 435
		local workMode = resolveRemixWorkMode(state) -- 436
		local stopping = hasActiveTask() -- 437
		local ____detail_success_18 -- 438
		if detail.success then -- 438
			____detail_success_18 = detail.hasActivePlan -- 438
		else -- 438
			____detail_success_18 = false -- 438
		end -- 438
		local hasActivePlan = ____detail_success_18 -- 438
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 439
		local layoutComposerBottom = 24 -- 440
		local layoutComposerHeight = composerHeight -- 441
		local layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap -- 442
		local layoutComposerTop = layoutModeBottom + 40 -- 443
		layoutTranscriptBottom = layoutComposerTop + composerGap + (phase == "done" and 48 or 0) -- 444
		local contentWidth = safe.width - 32 -- 445
		local inputWidth = contentWidth - composerActionWidth - composerGap -- 446
		local modeWidth = math.floor((contentWidth - composerGap) / 2) -- 447
		local modeStartX = left + 16 -- 448
		local modeCodeWidth = contentWidth - modeWidth - composerGap -- 449
		local playWidth = canShare and (contentWidth - composerGap) / 2 or contentWidth -- 450
		local playX = canShare and modeStartX + playWidth + composerGap or modeStartX -- 451
		local ____detail_success_19 -- 452
		if detail.success then -- 452
			____detail_success_19 = detail.pendingQuestionnaire -- 452
		else -- 452
			____detail_success_19 = nil -- 452
		end -- 452
		local questionnaire = ____detail_success_19 -- 452
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 453
		local questionPromptWidth = contentWidth - 32 -- 454
		local questionPromptHeight = question and measureWrappedTextHeight(question.prompt, questionPromptWidth, 16) or 0 -- 455
		local questionOptions = question and question.type ~= "text" and __TS__ArraySlice(question.options or ({}), 0, 8) or ({}) -- 458
		local questionAnswerHeight = #questionOptions > 0 and 40 + 43 * (#questionOptions - 1) or 92 -- 459
		local questionCardMinHeight = safe.height - 330 -- 460
		local questionCardMaxHeight = math.max(questionCardMinHeight, safe.height - 164 - 72) -- 461
		local questionCardHeight = math.min( -- 462
			math.max(questionCardMinHeight, 75 + questionPromptHeight / 2 + 14 + questionAnswerHeight + 16 + 40 + 12), -- 463
			questionCardMaxHeight -- 464
		) -- 464
		local questionAnswerTop = questionCardHeight - 75 - questionPromptHeight / 2 - 14 -- 466
		local questionHasBack = questionIndex > 0 -- 467
		local questionCanSkip = question ~= nil and not question.required -- 468
		local questionActionGap = 8 -- 469
		local questionBackWidth = 76 -- 470
		local questionSkipWidth = 64 -- 471
		local questionSkipX = 16 + (questionHasBack and questionBackWidth + questionActionGap or 0) -- 472
		local questionSubmitX = questionSkipX + (questionCanSkip and questionSkipWidth + questionActionGap or 0) -- 473
		local fontScale = mobileFontScale -- 474
		local headerY = getHeaderY(safe) -- 475
		local compactHeaderStatus = useCompactHeaderStatus(safe) -- 476
		compactHeaderStatusActive = compactHeaderStatus -- 477
		local headerStatusWidth = 168 -- 478
		local modelButtonWidth = shortLandscape and 92 or 72 -- 479
		local backText = zh and "返回 ›" or "Back ›" -- 480
		local backMeasure = Label(fontName, 18, true) -- 481
		backMeasure.text = backText -- 482
		local backWidth = math.max(44, backMeasure.width) -- 483
		backMeasure:cleanup() -- 484
		local headerBackX = left + safe.width - 16 - backWidth -- 485
		local headerSettingsX = headerBackX - composerGap - modelButtonWidth -- 486
		local headerStatusX = headerSettingsX - 8 - headerStatusWidth -- 487
		local headerTitleWidth = compactHeaderStatus and math.max(120, headerStatusX - (left + 16) - composerGap) or math.max(120, headerSettingsX - (left + 16) - composerGap) -- 488
		local selectedConfig = __TS__ArrayFind( -- 491
			llmConfigs, -- 491
			function(____, item) return item.id == selectedLLMConfigId end -- 491
		) -- 491
		local switchPending = hasActiveTask() and taskLLMConfigId > 0 and taskLLMConfigId ~= selectedLLMConfigId -- 492
		local modelName = selectedConfig and selectedConfig.name or (zh and "配置 AI" or "Set up AI") -- 493
		local modelNameLimit = shortLandscape and 10 or 6 -- 494
		local shortModelName = inputLength(modelName) > modelNameLimit and inputSlice(modelName, 0, modelNameLimit) .. "…" or modelName -- 495
		local modelLabel = ellipsizeSingleLine((switchPending and (zh and "下一轮·" or "Next·") or "") .. shortModelName, modelButtonWidth - 14, 11) -- 496
		local thinkingText = resolveRemixThinkingStatus(detail.success and detail.steps or ({}), state and state.currentTaskId) -- 497
		local statusText = thinkingText ~= nil and (zh and "正在思考" or "Thinking") or (phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game"))))))) -- 498
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 505
		if mascotAnimationState ~= mascotState then -- 505
			mascotAnimationState = mascotState -- 512
			mascotAnimationStartedAt = App.runningTime -- 513
		end -- 513
		local emptyLandscape = shortLandscape and not hasTranscriptContent() -- 515
		local emptyStatusBottom = bottom + layoutTranscriptBottom -- 516
		local emptyStatusTop = headerY - composerGap - statusHeight -- 517
		local messageTop = emptyLandscape and (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2 or headerY - composerGap - statusHeight / 2 -- 518
		local mascotSize = shortLandscape and 42 or 52 -- 521
		local compactStandaloneStatus = useCompactStandaloneStatus(safe) -- 522
		local standaloneStatusContentLift = shortLandscape and 0 or (compactStandaloneStatus and 26 or 14) -- 523
		local mascotX = shortLandscape and left + 40 or left + 66 -- 524
		local statusTextX = shortLandscape and left + 76 or left + 104 -- 525
		local statusTextWidth = shortLandscape and math.max(120, left + 16 + contentWidth - statusTextX) or contentWidth - 84 -- 526
		local renderedStatusX = compactHeaderStatus and 36 or statusTextX -- 527
		local renderedStatusY = compactHeaderStatus and 22 or statusHeight / 2 + standaloneStatusContentLift -- 528
		local renderedStatusWidth = compactHeaderStatus and headerStatusWidth - 36 or statusTextWidth -- 529
		local thinkingFontSize = compactHeaderStatus and math.floor(10 * fontScale) or math.floor(12 * fontScale) -- 530
		local thinkingRightPadding = compactHeaderStatus and 8 or 20 -- 531
		local renderedThinkingText = thinkingText == nil and "" or ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize) -- 532
		local swipeStart = Vec2.zero -- 533
		local swipeAxis = "none" -- 534
		local pageRef = reference() -- 535
		local hitsTranscriptButton -- 536
		hitsTranscriptButton = function(node, world) -- 536
			if not node.visible then -- 536
				return false -- 537
			end -- 537
			if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then -- 537
				local p = node:convertToNodeSpace(world) -- 539
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 539
					return true -- 540
				end -- 540
			end -- 540
			local hit = false -- 542
			node:eachChild(function(child) -- 543
				hit = hitsTranscriptButton(child, world) -- 543
				return hit -- 543
			end) -- 543
			return hit -- 544
		end -- 536
		local ____toNode_64 = toNode -- 546
		local ____React_createElement_63 = React.createElement -- 546
		local ____array_62 = __TS__SparseArrayNew( -- 546
			"node", -- 546
			{ -- 546
				tag = "remix-scene", -- 546
				x = -width / 2, -- 546
				y = -height / 2, -- 546
				width = width, -- 546
				height = height, -- 546
				anchorX = 0, -- 546
				anchorY = 0 -- 546
			}, -- 546
			React.createElement( -- 546
				"node", -- 546
				{ -- 546
					tag = "remix-focus-observer", -- 546
					order = 1000, -- 546
					width = width, -- 546
					height = height, -- 546
					anchorX = 0, -- 546
					anchorY = 0, -- 546
					touchEnabled = true, -- 546
					swallowTouches = false, -- 546
					swallowMouseWheel = false, -- 546
					onTapFilter = function(touch) -- 546
						touch.enabled = false -- 550
						if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 550
							return -- 551
						end -- 551
						local input = inputRef.current -- 552
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 553
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 554
						dismissedComposition = not inside and promptInput.isComposing() -- 555
						if not inside then -- 555
							blurInput() -- 556
						end -- 556
						if not inside and not questionnaire and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 556
							touch.enabled = true -- 561
						end -- 561
					end, -- 549
					onTapBegan = function(touch) -- 549
						swipeStart = touch.location -- 565
						swipeAxis = "none" -- 565
						swipeDragging = true -- 565
						local ____opt_28 = pageRef.current -- 565
						if ____opt_28 ~= nil then -- 565
							____opt_28:stopAllActions() -- 566
						end -- 566
					end, -- 564
					onTapMoved = function(touch) -- 564
						local delta = touch.location:sub(swipeStart) -- 569
						if swipeAxis == "none" and math.max( -- 569
							math.abs(delta.x), -- 570
							math.abs(delta.y) -- 570
						) >= 12 then -- 570
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 571
						end -- 571
						if pageRef.current then -- 571
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 573
						end -- 573
					end, -- 568
					onTapEnded = function(touch) -- 568
						local delta = touch.location:sub(swipeStart) -- 576
						swipeDragging = false -- 577
						if swipeBackPending then -- 577
							return -- 578
						end -- 578
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 579
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 580
						local page = pageRef.current -- 581
						if not page or not requested and page.x == 0 then -- 581
							return -- 582
						end -- 582
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 583
						local revision = swipeRevision -- 584
						swipeBackPending = true -- 585
						if not leaving then -- 585
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 587
						end -- 587
						thread(function() -- 589
							sleep(duration) -- 590
							if disposed or revision ~= swipeRevision or not host.parent then -- 590
								return -- 591
							end -- 591
							swipeBackPending = false -- 592
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 592
								refresh() -- 593
								goBack() -- 593
							else -- 593
								page.position = Vec2.zero -- 594
							end -- 594
						end) -- 589
					end -- 575
				} -- 575
			), -- 575
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 575
		) -- 575
		local ____React_createElement_61 = React.createElement -- 575
		local ____array_60 = __TS__SparseArrayNew( -- 575
			"node", -- 575
			{tag = "remix-page", ref = pageRef}, -- 575
			React.createElement( -- 575
				"clip-node", -- 575
				{ -- 575
					x = left + 16, -- 575
					y = headerY, -- 575
					width = headerTitleWidth, -- 575
					height = 44, -- 575
					anchorX = 0, -- 575
					anchorY = 0, -- 575
					stencil = React.createElement( -- 575
						"draw-node", -- 575
						{x = headerTitleWidth / 2, y = 22}, -- 575
						React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295}) -- 575
					) -- 575
				}, -- 575
				React.createElement("label", { -- 575
					tag = "remix-title", -- 575
					x = 0, -- 575
					y = 22, -- 575
					anchorX = 0, -- 575
					fontName = fontName, -- 575
					fontSize = 20, -- 575
					text = "REMIX · " .. options.entry.title, -- 575
					color3 = 16052712 -- 575
				}) -- 575
			), -- 575
			React.createElement( -- 575
				"node", -- 575
				{ -- 575
					tag = "remix-back", -- 575
					x = headerBackX, -- 575
					y = headerY, -- 575
					width = backWidth, -- 575
					height = 44, -- 575
					anchorX = 0, -- 575
					anchorY = 0, -- 575
					touchEnabled = true, -- 575
					swallowTouches = true, -- 575
					onTapped = goBack -- 575
				}, -- 575
				React.createElement("label", { -- 575
					x = backWidth, -- 575
					y = 22, -- 575
					anchorX = 1, -- 575
					fontName = fontName, -- 575
					fontSize = 18, -- 575
					text = backText, -- 575
					color3 = 16763955 -- 575
				}) -- 575
			) -- 575
		) -- 575
		local ____React_createElement_32 = React.createElement -- 575
		local ____array_31 = __TS__SparseArrayNew( -- 575
			"node", -- 575
			{ -- 575
				tag = "remix-model-config", -- 575
				x = headerSettingsX, -- 575
				y = headerY + 6, -- 575
				width = modelButtonWidth, -- 575
				height = 32, -- 575
				anchorX = 0, -- 575
				anchorY = 0, -- 575
				touchEnabled = true, -- 575
				swallowTouches = true, -- 575
				onTapped = configureLLM -- 575
			}, -- 575
			React.createElement(RoundedSurface, { -- 575
				width = modelButtonWidth, -- 575
				height = 32, -- 575
				radius = 16, -- 575
				topColor = 858534978, -- 575
				bottomColor = 856824097, -- 575
				borderWidth = 1, -- 575
				borderColor = needsLLMSetup and colors.brand or colors.border -- 575
			}), -- 575
			React.createElement("label", { -- 575
				x = modelButtonWidth / 2, -- 575
				y = 16, -- 575
				fontName = fontName, -- 575
				fontSize = 11, -- 575
				text = modelLabel, -- 575
				color3 = (needsLLMSetup or switchPending) and 16763955 or 11055037 -- 575
			}) -- 575
		) -- 575
		local ____needsLLMSetup_30 -- 612
		if needsLLMSetup then -- 612
			____needsLLMSetup_30 = React.createElement( -- 612
				"draw-node", -- 612
				{x = modelButtonWidth - 4, y = 28}, -- 612
				React.createElement("dot-shape", {radius = 3, color = 4294954035}) -- 612
			) -- 612
		else -- 612
			____needsLLMSetup_30 = nil -- 612
		end -- 612
		__TS__SparseArrayPush(____array_31, ____needsLLMSetup_30) -- 612
		__TS__SparseArrayPush( -- 612
			____array_60, -- 612
			____React_createElement_32(__TS__SparseArraySpread(____array_31)), -- 612
			React.createElement( -- 612
				"node", -- 612
				{ -- 612
					tag = "remix-status", -- 612
					x = compactHeaderStatus and headerStatusX or 0, -- 612
					y = compactHeaderStatus and headerY or messageTop - statusHeight / 2, -- 612
					width = compactHeaderStatus and headerStatusWidth or width, -- 612
					height = compactHeaderStatus and 44 or statusHeight, -- 612
					anchorX = 0, -- 612
					anchorY = 0 -- 612
				}, -- 612
				React.createElement(DoraMascot, { -- 612
					state = mascotState, -- 612
					x = compactHeaderStatus and 16 or mascotX, -- 612
					y = compactHeaderStatus and 20 or statusHeight / 2 - 2 + standaloneStatusContentLift, -- 612
					size = compactHeaderStatus and 30 or mascotSize, -- 612
					animationStartedAt = mascotAnimationStartedAt -- 612
				}), -- 612
				React.createElement( -- 612
					"clip-node", -- 612
					{ -- 612
						tag = "remix-status-clip", -- 612
						x = renderedStatusX, -- 612
						y = renderedStatusY - 22, -- 612
						width = renderedStatusWidth, -- 612
						height = 44, -- 612
						anchorX = 0, -- 612
						anchorY = 0, -- 612
						stencil = React.createElement( -- 612
							"draw-node", -- 612
							{x = renderedStatusWidth / 2, y = 22}, -- 612
							React.createElement("rect-shape", {width = renderedStatusWidth, height = 44, fillColor = 4294967295}) -- 612
						) -- 612
					}, -- 612
					React.createElement( -- 612
						"label", -- 612
						{ -- 612
							tag = "remix-status-text", -- 612
							x = 0, -- 612
							y = 22, -- 612
							anchorX = 0, -- 612
							fontName = fontName, -- 612
							fontSize = compactHeaderStatus and math.floor(13 * fontScale) or math.floor(15 * fontScale), -- 612
							text = statusText, -- 612
							textWidth = -1, -- 612
							alignment = "Left", -- 612
							color3 = phase == "failed" and 16739179 or 16763955 -- 612
						} -- 612
					), -- 612
					React.createElement("label", { -- 612
						tag = "remix-thinking-text", -- 612
						x = 0, -- 612
						y = 6, -- 612
						anchorX = 0, -- 612
						fontName = fontName, -- 612
						fontSize = thinkingFontSize, -- 612
						text = renderedThinkingText, -- 612
						textWidth = -1, -- 612
						alignment = "Left", -- 612
						color3 = colors.muted -- 612
					}) -- 612
				) -- 612
			) -- 612
		) -- 612
		local ____temp_41 -- 628
		if questionnaire and question then -- 628
			local ____React_createElement_40 = React.createElement -- 628
			local ____array_39 = __TS__SparseArrayNew( -- 628
				"node", -- 628
				{ -- 628
					tag = "remix-questionnaire", -- 628
					x = left + 16, -- 628
					y = bottom + 164, -- 628
					width = contentWidth, -- 628
					height = questionCardHeight, -- 628
					anchorX = 0, -- 628
					anchorY = 0 -- 628
				}, -- 628
				React.createElement(RoundedSurface, { -- 628
					width = contentWidth, -- 628
					height = questionCardHeight, -- 628
					radius = 20, -- 628
					topColor = 4280429370, -- 628
					bottomColor = 4279375648, -- 628
					borderWidth = 1, -- 628
					borderColor = 4282469213, -- 628
					shadow = true -- 628
				}), -- 628
				React.createElement( -- 628
					"label", -- 628
					{ -- 628
						x = 16, -- 628
						y = questionCardHeight - 30, -- 628
						anchorX = 0, -- 628
						fontName = fontName, -- 628
						fontSize = 13, -- 628
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 628
						textWidth = contentWidth - 32, -- 628
						alignment = "Left", -- 628
						color3 = 16763955 -- 628
					} -- 628
				), -- 628
				React.createElement("label", { -- 628
					tag = "remix-question-prompt", -- 628
					x = 16, -- 628
					y = questionCardHeight - 75, -- 628
					anchorX = 0, -- 628
					fontName = fontName, -- 628
					fontSize = 16, -- 628
					text = question.prompt, -- 628
					textWidth = questionPromptWidth, -- 628
					alignment = "Left", -- 628
					color3 = 16052712 -- 628
				}), -- 628
				question.type ~= "text" and __TS__ArrayMap( -- 632
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 632
					function(____, option, optionIndex) return React.createElement( -- 632
						ChoiceButton, -- 632
						{ -- 632
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 632
							x = 16, -- 632
							y = questionAnswerTop - 40 - optionIndex * 43, -- 632
							width = contentWidth - 32, -- 632
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 632
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 632
							onTapped = function() -- 632
								local selected = questionnaireSelections[question.id] or ({}) -- 638
								local ____question_id_36 = question.id -- 639
								local ____temp_35 -- 639
								if question.type == "single_choice" then -- 639
									____temp_35 = {option.id} -- 640
								else -- 640
									local ____temp_34 -- 641
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 641
										____temp_34 = __TS__ArrayFilter( -- 641
											selected, -- 641
											function(____, id) return id ~= option.id end -- 641
										) -- 641
									else -- 641
										local ____array_33 = __TS__SparseArrayNew(table.unpack(selected)) -- 641
										__TS__SparseArrayPush(____array_33, option.id) -- 641
										____temp_34 = {__TS__SparseArraySpread(____array_33)} -- 641
									end -- 641
									____temp_35 = ____temp_34 -- 641
								end -- 641
								questionnaireSelections[____question_id_36] = ____temp_35 -- 639
								render() -- 642
							end -- 637
						} -- 637
					) end -- 637
				) or React.createElement("node", { -- 637
					tag = "remix-question-input", -- 637
					ref = inputRef, -- 637
					x = 16, -- 637
					y = questionAnswerTop - 92, -- 637
					width = contentWidth - 32, -- 637
					height = 92, -- 637
					anchorX = 0, -- 637
					anchorY = 0, -- 637
					onMount = promptInput.mount -- 637
				}) -- 637
			) -- 637
			local ____questionHasBack_37 -- 646
			if questionHasBack then -- 646
				____questionHasBack_37 = React.createElement( -- 646
					ActionButton, -- 646
					{ -- 646
						tag = "remix-question-back", -- 646
						x = 16, -- 646
						y = 12, -- 646
						width = questionBackWidth, -- 646
						text = zh and "上一步" or "Back", -- 646
						onTapped = function() -- 646
							questionIndex = questionIndex - 1 -- 646
							render() -- 646
						end -- 646
					} -- 646
				) -- 646
			else -- 646
				____questionHasBack_37 = nil -- 646
			end -- 646
			__TS__SparseArrayPush(____array_39, ____questionHasBack_37) -- 646
			local ____questionCanSkip_38 -- 647
			if questionCanSkip then -- 647
				____questionCanSkip_38 = React.createElement( -- 647
					ActionButton, -- 647
					{ -- 647
						tag = "remix-question-skip", -- 647
						x = questionSkipX, -- 647
						y = 12, -- 647
						width = questionSkipWidth, -- 647
						text = zh and "跳过" or "Skip", -- 647
						onTapped = function() return advanceQuestionnaire(true) end -- 647
					} -- 647
				) -- 647
			else -- 647
				____questionCanSkip_38 = nil -- 647
			end -- 647
			__TS__SparseArrayPush( -- 647
				____array_39, -- 647
				____questionCanSkip_38, -- 647
				React.createElement( -- 647
					ActionButton, -- 648
					{ -- 648
						tag = "remix-question-submit", -- 648
						x = questionSubmitX, -- 648
						y = 12, -- 648
						width = contentWidth - questionSubmitX - 16, -- 648
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 648
						primary = true, -- 648
						onTapped = function() -- 648
							if not dismissedComposition then -- 648
								advanceQuestionnaire() -- 650
							end -- 650
							dismissedComposition = false -- 650
						end -- 650
					} -- 650
				) -- 650
			) -- 650
			____temp_41 = ____React_createElement_40(__TS__SparseArraySpread(____array_39)) -- 650
		else -- 650
			____temp_41 = nil -- 651
		end -- 651
		__TS__SparseArrayPush(____array_60, ____temp_41) -- 651
		local ____temp_42 -- 652
		if visibleError ~= "" then -- 652
			____temp_42 = React.createElement( -- 652
				"label", -- 652
				{ -- 652
					tag = "remix-error", -- 652
					x = left + 20, -- 652
					y = bottom + (questionnaire and 144 or layoutComposerTop + composerGap), -- 652
					anchorX = 0, -- 652
					anchorY = 0, -- 652
					fontName = fontName, -- 652
					fontSize = 13, -- 652
					text = visibleError, -- 652
					textWidth = contentWidth, -- 652
					alignment = "Left", -- 652
					color3 = 16739179, -- 652
					onMount = function(label) -- 652
						errorLabel = label -- 652
					end -- 652
				} -- 652
			) -- 652
		else -- 652
			____temp_42 = nil -- 652
		end -- 652
		__TS__SparseArrayPush(____array_60, ____temp_42) -- 652
		local ____temp_43 -- 653
		if questionnaire == nil then -- 653
			____temp_43 = React.createElement( -- 653
				"node", -- 653
				nil, -- 653
				React.createElement( -- 653
					ChoiceButton, -- 654
					{ -- 654
						tag = "remix-mode-plan", -- 654
						x = modeStartX, -- 654
						y = bottom + layoutModeBottom, -- 654
						width = modeWidth, -- 654
						text = zh and "计划" or "Plan", -- 654
						selected = workMode == "plan", -- 654
						disabled = not canSubmit(), -- 654
						onTapped = function() return changeWorkMode("plan") end -- 654
					} -- 654
				), -- 654
				React.createElement( -- 654
					ChoiceButton, -- 655
					{ -- 655
						tag = "remix-mode-code", -- 655
						x = modeStartX + modeWidth + composerGap, -- 655
						y = bottom + layoutModeBottom, -- 655
						width = modeCodeWidth, -- 655
						text = zh and "执行" or "Code", -- 655
						selected = workMode == "code", -- 655
						disabled = not canSubmit(), -- 655
						onTapped = function() return changeWorkMode("code") end -- 655
					} -- 655
				) -- 655
			) -- 655
		else -- 655
			____temp_43 = nil -- 656
		end -- 656
		__TS__SparseArrayPush(____array_60, ____temp_43) -- 656
		local ____temp_44 -- 657
		if questionnaire == nil and not keptInput then -- 657
			____temp_44 = React.createElement("node", { -- 657
				tag = "remix-input", -- 657
				ref = inputRef, -- 657
				x = left + 16, -- 657
				y = bottom + layoutComposerBottom, -- 657
				width = inputWidth, -- 657
				height = layoutComposerHeight, -- 657
				anchorX = 0, -- 657
				anchorY = 0, -- 657
				onMount = promptInput.mount -- 657
			}) -- 657
		else -- 657
			____temp_44 = nil -- 658
		end -- 658
		__TS__SparseArrayPush(____array_60, ____temp_44) -- 658
		local ____temp_57 -- 659
		if stopping or questionnaire == nil then -- 659
			local ____React_createElement_56 = React.createElement -- 659
			local ____ActionButton_55 = ActionButton -- 659
			local ____temp_50 = stopping and "remix-stop" or "remix-send" -- 659
			local ____temp_51 = left + 16 + inputWidth + composerGap -- 660
			local ____temp_52 = bottom + layoutComposerBottom -- 660
			local ____temp_53 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 661
			local ____temp_54 = not stopping -- 662
			local ____stopping_49 -- 662
			if stopping then -- 662
				____stopping_49 = stopRequested or (state and state.currentTaskFinalizing) == true -- 662
			else -- 662
				____stopping_49 = not canSubmit() -- 662
			end -- 662
			____temp_57 = ____React_createElement_56( -- 662
				____ActionButton_55, -- 659
				{ -- 659
					tag = ____temp_50, -- 659
					x = ____temp_51, -- 659
					y = ____temp_52, -- 659
					width = composerActionWidth, -- 659
					height = layoutComposerHeight, -- 659
					text = ____temp_53, -- 659
					primary = ____temp_54, -- 659
					danger = stopping, -- 659
					disabled = ____stopping_49, -- 659
					onTapped = function() -- 659
						if stopping then -- 659
							stop() -- 663
						elseif not dismissedComposition then -- 663
							send() -- 663
						end -- 663
						dismissedComposition = false -- 663
					end -- 663
				} -- 663
			) -- 663
		else -- 663
			____temp_57 = nil -- 663
		end -- 663
		__TS__SparseArrayPush(____array_60, ____temp_57) -- 663
		local ____temp_58 -- 664
		if phase == "done" and canShare then -- 664
			____temp_58 = React.createElement( -- 664
				ActionButton, -- 664
				{ -- 664
					tag = "remix-share", -- 664
					x = left + 16, -- 664
					y = bottom + layoutModeBottom + 48, -- 664
					width = playWidth, -- 664
					height = 40, -- 664
					text = zh and "分享作品" or "Share game", -- 664
					onTapped = function() -- 664
						if not host.visible or packagePanel or HttpServer.wsConnectionCount > 0 then -- 664
							return -- 665
						end -- 665
						blurInput() -- 666
						notifyProjectChanged() -- 666
						packagePanel = startPackagePanel({ -- 667
							mode = "share", -- 667
							entry = options.entry, -- 667
							onClosed = function() -- 667
								packagePanel = nil -- 667
							end -- 667
						}) -- 667
					end -- 664
				} -- 664
			) -- 664
		else -- 664
			____temp_58 = nil -- 668
		end -- 668
		__TS__SparseArrayPush(____array_60, ____temp_58) -- 668
		local ____temp_59 -- 669
		if phase == "done" then -- 669
			____temp_59 = React.createElement( -- 669
				ActionButton, -- 669
				{ -- 669
					tag = "remix-play", -- 669
					x = playX, -- 669
					y = bottom + layoutModeBottom + 48, -- 669
					width = playWidth, -- 669
					height = 40, -- 669
					text = zh and "立即试玩" or "Play now", -- 669
					primary = true, -- 669
					onTapped = function() -- 669
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 669
							return -- 669
						end -- 669
						blurInput() -- 669
						notifyProjectChanged() -- 669
						host.visible = false -- 669
						onPlay(options.entry) -- 669
					end -- 669
				} -- 669
			) -- 669
		else -- 669
			____temp_59 = nil -- 669
		end -- 669
		__TS__SparseArrayPush(____array_60, ____temp_59) -- 669
		__TS__SparseArrayPush( -- 669
			____array_62, -- 669
			____React_createElement_61(__TS__SparseArraySpread(____array_60)) -- 669
		) -- 669
		local scene = ____toNode_64(____React_createElement_63(__TS__SparseArraySpread(____array_62))) -- 546
		if scene then -- 546
			host:addChild(scene) -- 673
			if keptInput then -- 673
				keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom) -- 675
				keptInput.width = inputWidth -- 676
				keptInput.height = layoutComposerHeight -- 677
				local ____opt_65 = pageRef.current -- 677
				if ____opt_65 ~= nil then -- 677
					____opt_65:addChild(keptInput) -- 678
				end -- 678
			end -- 678
			if not questionnaire then -- 678
				transcript.node.position = Vec2( -- 681
					left + 16, -- 681
					bottom + getTranscriptBottom() -- 681
				) -- 681
				local ____opt_67 = pageRef.current -- 681
				if ____opt_67 ~= nil then -- 681
					____opt_67:addChild(transcript.node) -- 682
				end -- 682
				updateTranscript() -- 683
			end -- 683
		end -- 683
		if restoreInputFocus and inputRef.current and not keptInput then -- 683
			promptInput.focus(false) -- 686
		end -- 686
		if keptInput then -- 686
			promptInput.refresh() -- 687
		end -- 687
		shellRevision = getShellRevision() -- 688
		displayRevision = remixDisplayRevision(detail) -- 689
	end -- 407
	attachGamepad( -- 692
		host, -- 692
		{ -- 692
			initialTag = "remix-input", -- 693
			onBack = function() -- 694
				if promptInput.isFocused() then -- 694
					blurInput() -- 694
				else -- 694
					goBack() -- 694
				end -- 694
			end, -- 694
			onScroll = function(amount) return transcript:scrollBy(amount) end, -- 695
			onActivate = function(target) -- 696
				if target.tag == "remix-input" or target.tag == "remix-question-input" then -- 696
					target:emit("GamepadActivate") -- 697
				else -- 697
					if promptInput.isComposing() then -- 697
						blurInput() -- 699
						return -- 699
					end -- 699
					blurInput() -- 700
					dismissedComposition = false -- 701
					target:emit("Tapped") -- 702
				end -- 702
			end -- 696
		} -- 696
	) -- 696
	host:schedule(function(dt) -- 706
		pollElapsed = pollElapsed + dt -- 707
		if pollElapsed < 0.25 then -- 707
			return false -- 708
		end -- 708
		pollElapsed = 0 -- 709
		refresh() -- 710
		if swipeDragging or swipeBackPending then -- 710
			return false -- 711
		end -- 711
		if backNoticeUntil > 0 and App.runningTime >= backNoticeUntil then -- 711
			backNoticeUntil = 0 -- 713
			render() -- 714
			return false -- 715
		end -- 715
		local next = remixDisplayRevision(detail) -- 717
		if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then -- 717
			render() -- 718
		elseif displayRevision ~= next then -- 718
			updateTranscript() -- 719
		end -- 719
		return false -- 720
	end) -- 706
	host:onAppChange(function(setting) -- 722
		if setting == "Locale" then -- 722
			zh = (string.match(App.locale, "^zh")) ~= nil -- 723
		end -- 723
		if setting == "Size" or setting == "Locale" then -- 723
			render() -- 724
		end -- 724
	end) -- 722
	host:onAppEvent(function(event) -- 726
		if event == "BackButton" then -- 726
			if promptInput.isFocused() then -- 726
				blurInput() -- 727
			else -- 727
				goBack() -- 727
			end -- 727
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 727
			blurInput() -- 728
		end -- 728
	end) -- 726
	host:onCleanup(function() -- 730
		if packagePanel ~= nil then -- 730
			packagePanel:removeFromParent(true) -- 731
		end -- 731
		packagePanel = nil -- 732
		disposed = true -- 733
		blurInput() -- 733
	end) -- 730
	host:slot("SuspendLocalUI", blurInput) -- 735
	host:slot( -- 736
		"ResumeLocalUI", -- 736
		function() -- 736
			refresh() -- 736
			render() -- 736
		end -- 736
	) -- 736
	render() -- 737
	if needsLLMSetup then -- 737
		thread(function() -- 738
			sleep(0) -- 738
			if not disposed and host.parent then -- 738
				configureLLM() -- 738
			end -- 738
		end) -- 738
	end -- 738
	return host -- 739
end -- 104
return ____exports -- 104