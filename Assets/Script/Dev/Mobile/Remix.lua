-- [tsx]: Remix.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
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
local fontName = "sarasa-mono-sc-regular" -- 49
local colors = { -- 50
	background = 4278914322, -- 50
	panel = 4279704614, -- 50
	text = 4294242792, -- 50
	muted = 4289245117, -- 50
	brand = 4294954035, -- 50
	border = 4281613128, -- 50
	danger = 4294929259 -- 50
} -- 50
local composerGap = 12 -- 52
local composerBottom = 76 -- 53
local composerHeight = 60 -- 54
local composerActionWidth = 82 -- 55
local modeBottom = composerBottom + composerHeight + composerGap -- 56
local composerTop = modeBottom + 40 -- 57
local transcriptBottom = composerTop + composerGap -- 58
local statusHeight = 64 -- 59
local function ellipsizeSingleLine(text, width, fontSize) -- 61
	if text == "" then -- 61
		return "" -- 62
	end -- 62
	local measure = Label(fontName, fontSize, true) -- 63
	if not measure then -- 63
		return text -- 64
	end -- 64
	measure.visible = false -- 65
	measure.textWidth = -1 -- 66
	local function fits(value) -- 67
		measure.text = value -- 67
		return measure.width <= width -- 67
	end -- 67
	if fits(text) then -- 67
		measure:cleanup() -- 68
		return text -- 68
	end -- 68
	local low = 0 -- 69
	local high = inputLength(text) -- 69
	while low < high do -- 69
		local middle = math.floor((low + high + 1) / 2) -- 71
		if fits(inputSlice(text, 0, middle) .. "…") then -- 71
			low = middle -- 72
		else -- 72
			high = middle - 1 -- 73
		end -- 73
	end -- 73
	local result = inputSlice(text, 0, low) .. "…" -- 75
	measure:cleanup() -- 76
	return result -- 77
end -- 61
local function ActionButton(props) -- 80
	local height = props.height or 46 -- 81
	return React.createElement( -- 82
		"node", -- 82
		{ -- 82
			tag = props.tag, -- 82
			x = props.x, -- 82
			y = props.y, -- 82
			width = props.width, -- 82
			height = height, -- 82
			anchorX = 0, -- 82
			anchorY = 0, -- 82
			opacity = props.disabled and 0.45 or 1, -- 82
			touchEnabled = not props.disabled, -- 82
			swallowTouches = true, -- 82
			onTapped = props.onTapped -- 82
		}, -- 82
		React.createElement(RoundedSurface, { -- 82
			width = props.width, -- 82
			height = height, -- 82
			radius = 14, -- 82
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 82
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279704871), -- 82
			borderWidth = 1, -- 82
			borderColor = props.danger and colors.danger or (props.primary and 4294958435 or colors.border), -- 82
			shadow = props.primary or props.danger -- 82
		}), -- 82
		React.createElement("label", { -- 82
			x = props.width / 2, -- 82
			y = height / 2, -- 82
			fontName = fontName, -- 82
			fontSize = 15, -- 82
			text = props.text, -- 82
			color3 = props.primary and 1512202 or 16052712 -- 82
		}) -- 82
	) -- 82
end -- 80
local function ChoiceButton(props) -- 91
	local ____React_createElement_5 = React.createElement -- 91
	local ____temp_3 = { -- 91
		tag = props.tag, -- 91
		x = props.x, -- 91
		y = props.y, -- 91
		width = props.width, -- 91
		height = 40, -- 91
		anchorX = 0, -- 91
		anchorY = 0, -- 91
		opacity = props.disabled and 0.45 or 1, -- 91
		touchEnabled = not props.disabled, -- 91
		swallowTouches = true, -- 91
		onTapped = props.onTapped -- 91
	} -- 91
	local ____React_createElement_result_4 = React.createElement(RoundedSurface, { -- 91
		width = props.width, -- 91
		height = 40, -- 91
		radius = 12, -- 91
		topColor = props.selected and 4294958955 or 4280297526, -- 91
		bottomColor = props.selected and 4294950190 or 4279244061, -- 91
		borderWidth = 1, -- 91
		borderColor = props.selected and 4294958435 or colors.border -- 91
	}) -- 91
	local ____React_createElement_2 = React.createElement -- 91
	local ____array_1 = __TS__SparseArrayNew( -- 91
		"draw-node", -- 91
		{tag = props.tag and props.tag .. "-radio" or nil, x = 17, y = 20}, -- 91
		React.createElement("dot-shape", {radius = 7, color = props.selected and 4279702282 or 4289245117}), -- 91
		React.createElement("dot-shape", {radius = 5, color = props.selected and 4294954824 or 4279704614}) -- 91
	) -- 91
	local ____props_selected_0 -- 100
	if props.selected then -- 100
		____props_selected_0 = React.createElement( -- 100
			"draw-node", -- 100
			{tag = props.tag and props.tag .. "-radio-dot" or nil}, -- 100
			React.createElement("dot-shape", {radius = 2.5, color = 4279702282}) -- 100
		) -- 100
	else -- 100
		____props_selected_0 = nil -- 100
	end -- 100
	__TS__SparseArrayPush(____array_1, ____props_selected_0) -- 100
	return ____React_createElement_5( -- 92
		"node", -- 92
		____temp_3, -- 92
		____React_createElement_result_4, -- 92
		____React_createElement_2(__TS__SparseArraySpread(____array_1)), -- 92
		React.createElement("label", { -- 92
			x = 32, -- 92
			y = 20, -- 92
			anchorX = 0, -- 92
			fontName = fontName, -- 92
			fontSize = 14, -- 92
			text = props.text, -- 92
			textWidth = props.width - 44, -- 92
			alignment = "Left", -- 92
			color3 = props.selected and 1512202 or 16052712 -- 92
		}) -- 92
	) -- 92
end -- 91
function ____exports.startMobileRemix(options) -- 106
	local host, send, getTranscriptActions, render -- 106
	local onBack = options.onBack -- 107
	local onPlay = options.onPlay -- 108
	local packagePanel -- 109
	local services = options.services or ({ -- 110
		createSession = AgentSession.createSession, -- 111
		getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end, -- 112
		setWorkMode = AgentSession.setWorkMode, -- 113
		sendPrompt = AgentSession.sendPrompt, -- 114
		respondQuestionnaire = AgentSession.respondQuestionnaire, -- 115
		stopSessionTask = AgentSession.stopSessionTask, -- 116
		continuePrompt = AgentSession.continuePrompt, -- 117
		getActiveLLMConfig = getActiveLLMConfig, -- 118
		getLLMConfig = getLLMConfig, -- 119
		getLLMConfigSummaries = getLLMConfigSummaries -- 120
	}) -- 120
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 122
	local projectRoot = options.entry.workDir or "" -- 123
	local created = services.createSession(projectRoot, options.entry.title) -- 124
	local sessionId = created.success and created.session.id or 0 -- 125
	local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message}) -- 126
	local draft = "" -- 129
	local ____error = created.success and "" or created.message -- 130
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
		local ____detail_success_8 -- 148
		if detail.success then -- 148
			local ____opt_6 = detail.pendingQuestionnaire -- 148
			____detail_success_8 = ____opt_6 and ____opt_6.schema.questions[questionIndex + 1] -- 148
		else -- 148
			____detail_success_8 = nil -- 148
		end -- 148
		return ____detail_success_8 -- 148
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
	local ____temp_11 -- 162
	if rememberedRows and #rememberedRows > 0 then -- 162
		____temp_11 = tonumber(rememberedRows[1][1]) -- 162
	else -- 162
		____temp_11 = nil -- 162
	end -- 162
	local rememberedId = ____temp_11 -- 162
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
		local ____detail_success_15 -- 200
		if detail.success then -- 200
			local ____safeJsonEncode_14 = safeJsonEncode -- 200
			local ____array_13 = __TS__SparseArrayNew( -- 200
				detail.session.status, -- 201
				detail.session.workMode, -- 201
				detail.hasActivePlan, -- 201
				detail.pendingQuestionnaire or false, -- 201
				detail.session.currentTaskStatus or "" -- 202
			) -- 202
			local ____detail_session_currentTaskFinalizing_12 = detail.session.currentTaskFinalizing -- 202
			if ____detail_session_currentTaskFinalizing_12 == nil then -- 202
				____detail_session_currentTaskFinalizing_12 = false -- 202
			end -- 202
			__TS__SparseArrayPush( -- 202
				____array_13, -- 202
				____detail_session_currentTaskFinalizing_12, -- 202
				stopRequested, -- 202
				hasTranscriptContent(), -- 202
				resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or "" -- 203
			) -- 203
			____detail_success_15 = (____safeJsonEncode_14({__TS__SparseArraySpread(____array_13)})) or "" -- 200
		else -- 200
			____detail_success_15 = detail.message -- 204
		end -- 204
		return ____detail_success_15 -- 200
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
	local function advanceQuestionnaire() -- 356
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
		if not isQuestionAnswered(question, selected, text) then -- 364
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 366
			render() -- 367
			return -- 368
		end -- 368
		if questionIndex + 1 < #questions then -- 368
			questionIndex = questionIndex + 1 -- 371
			____error = "" -- 372
			render() -- 373
			return -- 374
		end -- 374
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 376
		if selectedLLMConfigId <= 0 then -- 376
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 378
			render() -- 379
			return -- 380
		end -- 380
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 382
		if not result.success then -- 382
			____error = result.message -- 383
		else -- 383
			taskLLMConfigId = selectedLLMConfigId -- 384
			____error = "" -- 384
		end -- 384
		refresh() -- 385
		render() -- 386
	end -- 356
	local function goBack() -- 388
		if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 388
			return -- 389
		end -- 389
		if detail.success and not canLeaveRemix(detail.session.status) then -- 389
			____error = zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back" -- 391
			render() -- 392
			return -- 393
		end -- 393
		blurInput() -- 395
		notifyProjectChanged() -- 396
		host.visible = false -- 397
		host:removeFromParent(true) -- 398
		onBack() -- 399
	end -- 388
	render = function() -- 402
		errorLabel = nil -- 403
		swipeRevision = swipeRevision + 1 -- 405
		swipeDragging = false -- 406
		swipeBackPending = false -- 407
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height) -- 408
		local ____temp_20 = layout == inputLayout and not (detail.success and detail.pendingQuestionnaire) -- 410
		if ____temp_20 then -- 410
			local ____opt_18 = inputRef.current -- 410
			____temp_20 = (____opt_18 and ____opt_18.tag) == "remix-input" -- 410
		end -- 410
		local keptInput = ____temp_20 and inputRef.current or nil -- 410
		if keptInput ~= nil then -- 410
			keptInput:removeFromParent(false) -- 412
		end -- 412
		transcript.node:removeFromParent(false) -- 413
		local restoreInputFocus = promptInput.isFocused() -- 414
		if not keptInput then -- 414
			promptInput.unmount() -- 416
			inputRef = reference() -- 417
		end -- 417
		host:removeAllChildren() -- 419
		inputLayout = layout -- 420
		host.scaleX = App.devicePixelRatio -- 421
		host.scaleY = App.devicePixelRatio -- 422
		local ____App_visualSize_23 = App.visualSize -- 423
		local width = ____App_visualSize_23.width -- 423
		local height = ____App_visualSize_23.height -- 423
		local safe = getLayoutArea() -- 424
		local left = safe.x -- 425
		local bottom = safe.y -- 426
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 427
		local state = detail.success and detail.session or nil -- 428
		local workMode = resolveRemixWorkMode(state) -- 429
		local stopping = hasActiveTask() -- 430
		local ____detail_success_24 -- 431
		if detail.success then -- 431
			____detail_success_24 = detail.hasActivePlan -- 431
		else -- 431
			____detail_success_24 = false -- 431
		end -- 431
		local hasActivePlan = ____detail_success_24 -- 431
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 432
		local layoutComposerBottom = 24 -- 433
		local layoutComposerHeight = composerHeight -- 434
		local layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap -- 435
		local layoutComposerTop = layoutModeBottom + 40 -- 436
		layoutTranscriptBottom = layoutComposerTop + composerGap + (phase == "done" and 48 or 0) -- 437
		local contentWidth = safe.width - 32 -- 438
		local inputWidth = contentWidth - composerActionWidth - composerGap -- 439
		local modeWidth = math.floor((contentWidth - composerGap) / 2) -- 440
		local modeStartX = left + 16 -- 441
		local modeCodeWidth = contentWidth - modeWidth - composerGap -- 442
		local playWidth = (contentWidth - composerGap) / 2 -- 443
		local playX = modeStartX + playWidth + composerGap -- 444
		local ____detail_success_25 -- 445
		if detail.success then -- 445
			____detail_success_25 = detail.pendingQuestionnaire -- 445
		else -- 445
			____detail_success_25 = nil -- 445
		end -- 445
		local questionnaire = ____detail_success_25 -- 445
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 446
		local fontScale = mobileFontScale -- 447
		local headerY = getHeaderY(safe) -- 448
		local compactHeaderStatus = useCompactHeaderStatus(safe) -- 449
		compactHeaderStatusActive = compactHeaderStatus -- 450
		local headerStatusWidth = 168 -- 451
		local modelButtonWidth = shortLandscape and 92 or 72 -- 452
		local headerSettingsX = left + safe.width - 104 - modelButtonWidth -- 453
		local headerStatusX = headerSettingsX - 8 - headerStatusWidth -- 454
		local headerTitleWidth = compactHeaderStatus and math.max(120, headerStatusX - (left + 16) - composerGap) or math.max(120, headerSettingsX - (left + 16) - composerGap) -- 455
		local selectedConfig = __TS__ArrayFind( -- 458
			llmConfigs, -- 458
			function(____, item) return item.id == selectedLLMConfigId end -- 458
		) -- 458
		local switchPending = hasActiveTask() and taskLLMConfigId > 0 and taskLLMConfigId ~= selectedLLMConfigId -- 459
		local modelName = selectedConfig and selectedConfig.name or (zh and "配置 AI" or "Set up AI") -- 460
		local modelNameLimit = shortLandscape and 10 or 6 -- 461
		local shortModelName = inputLength(modelName) > modelNameLimit and inputSlice(modelName, 0, modelNameLimit) .. "…" or modelName -- 462
		local modelLabel = ellipsizeSingleLine((switchPending and (zh and "下一轮·" or "Next·") or "") .. shortModelName, modelButtonWidth - 14, 11) -- 463
		local thinkingText = resolveRemixThinkingStatus(detail.success and detail.steps or ({}), state and state.currentTaskId) -- 464
		local statusText = thinkingText ~= nil and (zh and "正在思考" or "Thinking") or (phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game"))))))) -- 465
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 472
		if mascotAnimationState ~= mascotState then -- 472
			mascotAnimationState = mascotState -- 479
			mascotAnimationStartedAt = App.runningTime -- 480
		end -- 480
		local emptyLandscape = shortLandscape and not hasTranscriptContent() -- 482
		local emptyStatusBottom = bottom + layoutTranscriptBottom -- 483
		local emptyStatusTop = headerY - composerGap - statusHeight -- 484
		local messageTop = emptyLandscape and (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2 or headerY - composerGap - statusHeight / 2 -- 485
		local mascotSize = shortLandscape and 42 or 52 -- 488
		local compactStandaloneStatus = useCompactStandaloneStatus(safe) -- 489
		local standaloneStatusContentLift = shortLandscape and 0 or (compactStandaloneStatus and 26 or 14) -- 490
		local mascotX = shortLandscape and left + 40 or left + 66 -- 491
		local statusTextX = shortLandscape and left + 76 or left + 104 -- 492
		local statusTextWidth = shortLandscape and math.max(120, left + 16 + contentWidth - statusTextX) or contentWidth - 84 -- 493
		local renderedStatusX = compactHeaderStatus and 36 or statusTextX -- 494
		local renderedStatusY = compactHeaderStatus and 22 or statusHeight / 2 + standaloneStatusContentLift -- 495
		local renderedStatusWidth = compactHeaderStatus and headerStatusWidth - 36 or statusTextWidth -- 496
		local thinkingFontSize = compactHeaderStatus and math.floor(10 * fontScale) or math.floor(12 * fontScale) -- 497
		local thinkingRightPadding = compactHeaderStatus and 8 or 20 -- 498
		local renderedThinkingText = thinkingText == nil and "" or ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize) -- 499
		local swipeStart = Vec2.zero -- 500
		local swipeAxis = "none" -- 501
		local pageRef = reference() -- 502
		local hitsTranscriptButton -- 503
		hitsTranscriptButton = function(node, world) -- 503
			if not node.visible then -- 503
				return false -- 504
			end -- 504
			if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then -- 504
				local p = node:convertToNodeSpace(world) -- 506
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 506
					return true -- 507
				end -- 507
			end -- 507
			local hit = false -- 509
			node:eachChild(function(child) -- 510
				hit = hitsTranscriptButton(child, world) -- 510
				return hit -- 510
			end) -- 510
			return hit -- 511
		end -- 503
		local ____toNode_69 = toNode -- 513
		local ____React_createElement_68 = React.createElement -- 513
		local ____array_67 = __TS__SparseArrayNew( -- 513
			"node", -- 513
			{ -- 513
				tag = "remix-scene", -- 513
				x = -width / 2, -- 513
				y = -height / 2, -- 513
				width = width, -- 513
				height = height, -- 513
				anchorX = 0, -- 513
				anchorY = 0 -- 513
			}, -- 513
			React.createElement( -- 513
				"node", -- 513
				{ -- 513
					tag = "remix-focus-observer", -- 513
					order = 1000, -- 513
					width = width, -- 513
					height = height, -- 513
					anchorX = 0, -- 513
					anchorY = 0, -- 513
					touchEnabled = true, -- 513
					swallowTouches = false, -- 513
					swallowMouseWheel = false, -- 513
					onTapFilter = function(touch) -- 513
						touch.enabled = false -- 517
						if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 517
							return -- 518
						end -- 518
						local input = inputRef.current -- 519
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 520
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 521
						dismissedComposition = not inside and promptInput.isComposing() -- 522
						if not inside then -- 522
							blurInput() -- 523
						end -- 523
						if not inside and not questionnaire and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 523
							touch.enabled = true -- 528
						end -- 528
					end, -- 516
					onTapBegan = function(touch) -- 516
						swipeStart = touch.location -- 532
						swipeAxis = "none" -- 532
						swipeDragging = true -- 532
						local ____opt_34 = pageRef.current -- 532
						if ____opt_34 ~= nil then -- 532
							____opt_34:stopAllActions() -- 533
						end -- 533
					end, -- 531
					onTapMoved = function(touch) -- 531
						local delta = touch.location:sub(swipeStart) -- 536
						if swipeAxis == "none" and math.max( -- 536
							math.abs(delta.x), -- 537
							math.abs(delta.y) -- 537
						) >= 12 then -- 537
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 538
						end -- 538
						if pageRef.current then -- 538
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 540
						end -- 540
					end, -- 535
					onTapEnded = function(touch) -- 535
						local delta = touch.location:sub(swipeStart) -- 543
						swipeDragging = false -- 544
						if swipeBackPending then -- 544
							return -- 545
						end -- 545
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 546
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 547
						local page = pageRef.current -- 548
						if not page or not requested and page.x == 0 then -- 548
							return -- 549
						end -- 549
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 550
						local revision = swipeRevision -- 551
						swipeBackPending = true -- 552
						if not leaving then -- 552
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 554
						end -- 554
						thread(function() -- 556
							sleep(duration) -- 557
							if disposed or revision ~= swipeRevision or not host.parent then -- 557
								return -- 558
							end -- 558
							swipeBackPending = false -- 559
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 559
								refresh() -- 560
								goBack() -- 560
							else -- 560
								page.position = Vec2.zero -- 561
							end -- 561
						end) -- 556
					end -- 542
				} -- 542
			), -- 542
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 542
		) -- 542
		local ____React_createElement_66 = React.createElement -- 542
		local ____array_65 = __TS__SparseArrayNew( -- 542
			"node", -- 542
			{tag = "remix-page", ref = pageRef}, -- 542
			React.createElement( -- 542
				"clip-node", -- 542
				{ -- 542
					x = left + 16, -- 542
					y = headerY, -- 542
					width = headerTitleWidth, -- 542
					height = 44, -- 542
					anchorX = 0, -- 542
					anchorY = 0, -- 542
					stencil = React.createElement( -- 542
						"draw-node", -- 542
						{x = headerTitleWidth / 2, y = 22}, -- 542
						React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295}) -- 542
					) -- 542
				}, -- 542
				React.createElement("label", { -- 542
					tag = "remix-title", -- 542
					x = 0, -- 542
					y = 22, -- 542
					anchorX = 0, -- 542
					fontName = fontName, -- 542
					fontSize = 20, -- 542
					text = "REMIX · " .. options.entry.title, -- 542
					color3 = 16052712 -- 542
				}) -- 542
			), -- 542
			React.createElement( -- 542
				"node", -- 542
				{ -- 542
					tag = "remix-back", -- 542
					x = left + safe.width - 96, -- 542
					y = headerY, -- 542
					width = 80, -- 542
					height = 44, -- 542
					anchorX = 0, -- 542
					anchorY = 0, -- 542
					touchEnabled = true, -- 542
					swallowTouches = true, -- 542
					onTapped = goBack -- 542
				}, -- 542
				React.createElement("label", { -- 542
					x = 80, -- 542
					y = 22, -- 542
					anchorX = 1, -- 542
					fontName = fontName, -- 542
					fontSize = 18, -- 542
					text = zh and "返回 ›" or "Back ›", -- 542
					color3 = 16763955 -- 542
				}) -- 542
			) -- 542
		) -- 542
		local ____React_createElement_38 = React.createElement -- 542
		local ____array_37 = __TS__SparseArrayNew( -- 542
			"node", -- 542
			{ -- 542
				tag = "remix-model-config", -- 542
				x = headerSettingsX, -- 542
				y = headerY + 6, -- 542
				width = modelButtonWidth, -- 542
				height = 32, -- 542
				anchorX = 0, -- 542
				anchorY = 0, -- 542
				touchEnabled = true, -- 542
				swallowTouches = true, -- 542
				onTapped = configureLLM -- 542
			}, -- 542
			React.createElement(RoundedSurface, { -- 542
				width = modelButtonWidth, -- 542
				height = 32, -- 542
				radius = 16, -- 542
				topColor = 858534978, -- 542
				bottomColor = 856824097, -- 542
				borderWidth = 1, -- 542
				borderColor = needsLLMSetup and colors.brand or colors.border -- 542
			}), -- 542
			React.createElement("label", { -- 542
				x = modelButtonWidth / 2, -- 542
				y = 16, -- 542
				fontName = fontName, -- 542
				fontSize = 11, -- 542
				text = modelLabel, -- 542
				color3 = (needsLLMSetup or switchPending) and 16763955 or 11055037 -- 542
			}) -- 542
		) -- 542
		local ____needsLLMSetup_36 -- 579
		if needsLLMSetup then -- 579
			____needsLLMSetup_36 = React.createElement( -- 579
				"draw-node", -- 579
				{x = modelButtonWidth - 4, y = 28}, -- 579
				React.createElement("dot-shape", {radius = 3, color = 4294954035}) -- 579
			) -- 579
		else -- 579
			____needsLLMSetup_36 = nil -- 579
		end -- 579
		__TS__SparseArrayPush(____array_37, ____needsLLMSetup_36) -- 579
		__TS__SparseArrayPush( -- 579
			____array_65, -- 579
			____React_createElement_38(__TS__SparseArraySpread(____array_37)), -- 579
			React.createElement( -- 579
				"node", -- 579
				{ -- 579
					tag = "remix-status", -- 579
					x = compactHeaderStatus and headerStatusX or 0, -- 579
					y = compactHeaderStatus and headerY or messageTop - statusHeight / 2, -- 579
					width = compactHeaderStatus and headerStatusWidth or width, -- 579
					height = compactHeaderStatus and 44 or statusHeight, -- 579
					anchorX = 0, -- 579
					anchorY = 0 -- 579
				}, -- 579
				React.createElement(DoraMascot, { -- 579
					state = mascotState, -- 579
					x = compactHeaderStatus and 16 or mascotX, -- 579
					y = compactHeaderStatus and 20 or statusHeight / 2 - 2 + standaloneStatusContentLift, -- 579
					size = compactHeaderStatus and 30 or mascotSize, -- 579
					animationStartedAt = mascotAnimationStartedAt -- 579
				}), -- 579
				React.createElement( -- 579
					"clip-node", -- 579
					{ -- 579
						tag = "remix-status-clip", -- 579
						x = renderedStatusX, -- 579
						y = renderedStatusY - 22, -- 579
						width = renderedStatusWidth, -- 579
						height = 44, -- 579
						anchorX = 0, -- 579
						anchorY = 0, -- 579
						stencil = React.createElement( -- 579
							"draw-node", -- 579
							{x = renderedStatusWidth / 2, y = 22}, -- 579
							React.createElement("rect-shape", {width = renderedStatusWidth, height = 44, fillColor = 4294967295}) -- 579
						) -- 579
					}, -- 579
					React.createElement( -- 579
						"label", -- 579
						{ -- 579
							tag = "remix-status-text", -- 579
							x = 0, -- 579
							y = 22, -- 579
							anchorX = 0, -- 579
							fontName = fontName, -- 579
							fontSize = compactHeaderStatus and math.floor(13 * fontScale) or math.floor(15 * fontScale), -- 579
							text = statusText, -- 579
							textWidth = -1, -- 579
							alignment = "Left", -- 579
							color3 = phase == "failed" and 16739179 or 16763955 -- 579
						} -- 579
					), -- 579
					React.createElement("label", { -- 579
						tag = "remix-thinking-text", -- 579
						x = 0, -- 579
						y = 6, -- 579
						anchorX = 0, -- 579
						fontName = fontName, -- 579
						fontSize = thinkingFontSize, -- 579
						text = renderedThinkingText, -- 579
						textWidth = -1, -- 579
						alignment = "Left", -- 579
						color3 = colors.muted -- 579
					}) -- 579
				) -- 579
			) -- 579
		) -- 579
		local ____temp_46 -- 595
		if questionnaire and question then -- 595
			local ____React_createElement_45 = React.createElement -- 595
			local ____array_44 = __TS__SparseArrayNew( -- 595
				"node", -- 595
				{ -- 595
					tag = "remix-questionnaire", -- 595
					x = left + 16, -- 595
					y = bottom + 164, -- 595
					width = contentWidth, -- 595
					height = safe.height - 330, -- 595
					anchorX = 0, -- 595
					anchorY = 0 -- 595
				}, -- 595
				React.createElement(RoundedSurface, { -- 595
					width = contentWidth, -- 595
					height = safe.height - 330, -- 595
					radius = 20, -- 595
					topColor = 4280429370, -- 595
					bottomColor = 4279375648, -- 595
					borderWidth = 1, -- 595
					borderColor = 4282469213, -- 595
					shadow = true -- 595
				}), -- 595
				React.createElement( -- 595
					"label", -- 595
					{ -- 595
						x = 16, -- 595
						y = safe.height - 360, -- 595
						anchorX = 0, -- 595
						fontName = fontName, -- 595
						fontSize = 13, -- 595
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 595
						textWidth = contentWidth - 32, -- 595
						alignment = "Left", -- 595
						color3 = 16763955 -- 595
					} -- 595
				), -- 595
				React.createElement("label", { -- 595
					x = 16, -- 595
					y = safe.height - 405, -- 595
					anchorX = 0, -- 595
					fontName = fontName, -- 595
					fontSize = 16, -- 595
					text = question.prompt, -- 595
					textWidth = contentWidth - 32, -- 595
					alignment = "Left", -- 595
					color3 = 16052712 -- 595
				}), -- 595
				question.type ~= "text" and __TS__ArrayMap( -- 599
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 599
					function(____, option, optionIndex) return React.createElement( -- 599
						ChoiceButton, -- 599
						{ -- 599
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 599
							x = 16, -- 599
							y = safe.height - 460 - optionIndex * 43, -- 599
							width = contentWidth - 32, -- 599
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 599
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 599
							onTapped = function() -- 599
								local selected = questionnaireSelections[question.id] or ({}) -- 605
								local ____question_id_42 = question.id -- 606
								local ____temp_41 -- 606
								if question.type == "single_choice" then -- 606
									____temp_41 = {option.id} -- 607
								else -- 607
									local ____temp_40 -- 608
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 608
										____temp_40 = __TS__ArrayFilter( -- 608
											selected, -- 608
											function(____, id) return id ~= option.id end -- 608
										) -- 608
									else -- 608
										local ____array_39 = __TS__SparseArrayNew(table.unpack(selected)) -- 608
										__TS__SparseArrayPush(____array_39, option.id) -- 608
										____temp_40 = {__TS__SparseArraySpread(____array_39)} -- 608
									end -- 608
									____temp_41 = ____temp_40 -- 608
								end -- 608
								questionnaireSelections[____question_id_42] = ____temp_41 -- 606
								render() -- 609
							end -- 604
						} -- 604
					) end -- 604
				) or React.createElement("node", { -- 604
					tag = "remix-question-input", -- 604
					ref = inputRef, -- 604
					x = 16, -- 604
					y = safe.height - 510, -- 604
					width = contentWidth - 32, -- 604
					height = 92, -- 604
					anchorX = 0, -- 604
					anchorY = 0, -- 604
					onMount = promptInput.mount -- 604
				}) -- 604
			) -- 604
			local ____temp_43 -- 613
			if questionIndex > 0 then -- 613
				____temp_43 = React.createElement( -- 613
					ActionButton, -- 613
					{ -- 613
						tag = "remix-question-back", -- 613
						x = 16, -- 613
						y = 12, -- 613
						width = 92, -- 613
						text = zh and "上一步" or "Back", -- 613
						onTapped = function() -- 613
							questionIndex = questionIndex - 1 -- 613
							render() -- 613
						end -- 613
					} -- 613
				) -- 613
			else -- 613
				____temp_43 = nil -- 613
			end -- 613
			__TS__SparseArrayPush( -- 613
				____array_44, -- 613
				____temp_43, -- 613
				React.createElement( -- 613
					ActionButton, -- 614
					{ -- 614
						tag = "remix-question-submit", -- 614
						x = questionIndex > 0 and 120 or 16, -- 614
						y = 12, -- 614
						width = contentWidth - (questionIndex > 0 and 136 or 32), -- 614
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 614
						primary = true, -- 614
						onTapped = function() -- 614
							if not dismissedComposition then -- 614
								advanceQuestionnaire() -- 616
							end -- 616
							dismissedComposition = false -- 616
						end -- 616
					} -- 616
				) -- 616
			) -- 616
			____temp_46 = ____React_createElement_45(__TS__SparseArraySpread(____array_44)) -- 616
		else -- 616
			____temp_46 = nil -- 617
		end -- 617
		__TS__SparseArrayPush(____array_65, ____temp_46) -- 617
		local ____temp_47 -- 618
		if ____error ~= "" then -- 618
			____temp_47 = React.createElement( -- 618
				"label", -- 618
				{ -- 618
					tag = "remix-error", -- 618
					x = left + 20, -- 618
					y = bottom + (questionnaire and 144 or layoutComposerTop + composerGap), -- 618
					anchorX = 0, -- 618
					anchorY = 0, -- 618
					fontName = fontName, -- 618
					fontSize = 13, -- 618
					text = ____error, -- 618
					textWidth = contentWidth, -- 618
					alignment = "Left", -- 618
					color3 = 16739179, -- 618
					onMount = function(label) -- 618
						errorLabel = label -- 618
					end -- 618
				} -- 618
			) -- 618
		else -- 618
			____temp_47 = nil -- 618
		end -- 618
		__TS__SparseArrayPush(____array_65, ____temp_47) -- 618
		local ____temp_48 -- 619
		if questionnaire == nil then -- 619
			____temp_48 = React.createElement( -- 619
				"node", -- 619
				nil, -- 619
				React.createElement( -- 619
					ChoiceButton, -- 620
					{ -- 620
						tag = "remix-mode-plan", -- 620
						x = modeStartX, -- 620
						y = bottom + layoutModeBottom, -- 620
						width = modeWidth, -- 620
						text = zh and "计划" or "Plan", -- 620
						selected = workMode == "plan", -- 620
						disabled = not canSubmit(), -- 620
						onTapped = function() return changeWorkMode("plan") end -- 620
					} -- 620
				), -- 620
				React.createElement( -- 620
					ChoiceButton, -- 621
					{ -- 621
						tag = "remix-mode-code", -- 621
						x = modeStartX + modeWidth + composerGap, -- 621
						y = bottom + layoutModeBottom, -- 621
						width = modeCodeWidth, -- 621
						text = zh and "执行" or "Code", -- 621
						selected = workMode == "code", -- 621
						disabled = not canSubmit(), -- 621
						onTapped = function() return changeWorkMode("code") end -- 621
					} -- 621
				) -- 621
			) -- 621
		else -- 621
			____temp_48 = nil -- 622
		end -- 622
		__TS__SparseArrayPush(____array_65, ____temp_48) -- 622
		local ____temp_49 -- 623
		if questionnaire == nil and not keptInput then -- 623
			____temp_49 = React.createElement("node", { -- 623
				tag = "remix-input", -- 623
				ref = inputRef, -- 623
				x = left + 16, -- 623
				y = bottom + layoutComposerBottom, -- 623
				width = inputWidth, -- 623
				height = layoutComposerHeight, -- 623
				anchorX = 0, -- 623
				anchorY = 0, -- 623
				onMount = promptInput.mount -- 623
			}) -- 623
		else -- 623
			____temp_49 = nil -- 624
		end -- 624
		__TS__SparseArrayPush(____array_65, ____temp_49) -- 624
		local ____temp_62 -- 625
		if stopping or questionnaire == nil then -- 625
			local ____React_createElement_61 = React.createElement -- 625
			local ____ActionButton_60 = ActionButton -- 625
			local ____temp_55 = stopping and "remix-stop" or "remix-send" -- 625
			local ____temp_56 = left + 16 + inputWidth + composerGap -- 626
			local ____temp_57 = bottom + layoutComposerBottom -- 626
			local ____temp_58 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 627
			local ____temp_59 = not stopping -- 628
			local ____stopping_54 -- 628
			if stopping then -- 628
				____stopping_54 = stopRequested or (state and state.currentTaskFinalizing) == true -- 628
			else -- 628
				____stopping_54 = not canSubmit() -- 628
			end -- 628
			____temp_62 = ____React_createElement_61( -- 628
				____ActionButton_60, -- 625
				{ -- 625
					tag = ____temp_55, -- 625
					x = ____temp_56, -- 625
					y = ____temp_57, -- 625
					width = composerActionWidth, -- 625
					height = layoutComposerHeight, -- 625
					text = ____temp_58, -- 625
					primary = ____temp_59, -- 625
					danger = stopping, -- 625
					disabled = ____stopping_54, -- 625
					onTapped = function() -- 625
						if stopping then -- 625
							stop() -- 629
						elseif not dismissedComposition then -- 629
							send() -- 629
						end -- 629
						dismissedComposition = false -- 629
					end -- 629
				} -- 629
			) -- 629
		else -- 629
			____temp_62 = nil -- 629
		end -- 629
		__TS__SparseArrayPush(____array_65, ____temp_62) -- 629
		local ____temp_63 -- 630
		if phase == "done" then -- 630
			____temp_63 = React.createElement( -- 630
				ActionButton, -- 630
				{ -- 630
					tag = "remix-share", -- 630
					x = left + 16, -- 630
					y = bottom + layoutModeBottom + 48, -- 630
					width = playWidth, -- 630
					height = 40, -- 630
					text = zh and "分享作品" or "Share game", -- 630
					onTapped = function() -- 630
						if not host.visible or packagePanel or HttpServer.wsConnectionCount > 0 then -- 630
							return -- 631
						end -- 631
						blurInput() -- 632
						notifyProjectChanged() -- 632
						packagePanel = startPackagePanel({ -- 633
							mode = "share", -- 633
							entry = options.entry, -- 633
							onClosed = function() -- 633
								packagePanel = nil -- 633
							end -- 633
						}) -- 633
					end -- 630
				} -- 630
			) -- 630
		else -- 630
			____temp_63 = nil -- 634
		end -- 634
		__TS__SparseArrayPush(____array_65, ____temp_63) -- 634
		local ____temp_64 -- 635
		if phase == "done" then -- 635
			____temp_64 = React.createElement( -- 635
				ActionButton, -- 635
				{ -- 635
					tag = "remix-play", -- 635
					x = playX, -- 635
					y = bottom + layoutModeBottom + 48, -- 635
					width = playWidth, -- 635
					height = 40, -- 635
					text = zh and "立即试玩" or "Play now", -- 635
					primary = true, -- 635
					onTapped = function() -- 635
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 635
							return -- 635
						end -- 635
						blurInput() -- 635
						notifyProjectChanged() -- 635
						host.visible = false -- 635
						onPlay(options.entry) -- 635
					end -- 635
				} -- 635
			) -- 635
		else -- 635
			____temp_64 = nil -- 635
		end -- 635
		__TS__SparseArrayPush(____array_65, ____temp_64) -- 635
		__TS__SparseArrayPush( -- 635
			____array_67, -- 635
			____React_createElement_66(__TS__SparseArraySpread(____array_65)) -- 635
		) -- 635
		local scene = ____toNode_69(____React_createElement_68(__TS__SparseArraySpread(____array_67))) -- 513
		if scene then -- 513
			host:addChild(scene) -- 639
			if keptInput then -- 639
				keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom) -- 641
				keptInput.width = inputWidth -- 642
				keptInput.height = layoutComposerHeight -- 643
				local ____opt_70 = pageRef.current -- 643
				if ____opt_70 ~= nil then -- 643
					____opt_70:addChild(keptInput) -- 644
				end -- 644
			end -- 644
			if not questionnaire then -- 644
				transcript.node.position = Vec2( -- 647
					left + 16, -- 647
					bottom + getTranscriptBottom() -- 647
				) -- 647
				local ____opt_72 = pageRef.current -- 647
				if ____opt_72 ~= nil then -- 647
					____opt_72:addChild(transcript.node) -- 648
				end -- 648
				updateTranscript() -- 649
			end -- 649
		end -- 649
		if restoreInputFocus and inputRef.current and not keptInput then -- 649
			promptInput.focus(false) -- 652
		end -- 652
		if keptInput then -- 652
			promptInput.refresh() -- 653
		end -- 653
		shellRevision = getShellRevision() -- 654
		displayRevision = remixDisplayRevision(detail) -- 655
	end -- 402
	attachGamepad( -- 658
		host, -- 658
		{ -- 658
			initialTag = "remix-input", -- 659
			onBack = function() -- 660
				if promptInput.isFocused() then -- 660
					blurInput() -- 660
				else -- 660
					goBack() -- 660
				end -- 660
			end, -- 660
			onScroll = function(amount) return transcript:scrollBy(amount) end, -- 661
			onActivate = function(target) -- 662
				if target.tag == "remix-input" or target.tag == "remix-question-input" then -- 662
					target:emit("GamepadActivate") -- 663
				else -- 663
					if promptInput.isComposing() then -- 663
						blurInput() -- 665
						return -- 665
					end -- 665
					blurInput() -- 666
					dismissedComposition = false -- 667
					target:emit("Tapped") -- 668
				end -- 668
			end -- 662
		} -- 662
	) -- 662
	host:schedule(function(dt) -- 672
		pollElapsed = pollElapsed + dt -- 673
		if pollElapsed < 0.25 then -- 673
			return false -- 674
		end -- 674
		pollElapsed = 0 -- 675
		refresh() -- 676
		if swipeDragging or swipeBackPending then -- 676
			return false -- 677
		end -- 677
		local next = remixDisplayRevision(detail) -- 678
		if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then -- 678
			render() -- 679
		elseif displayRevision ~= next then -- 679
			updateTranscript() -- 680
		end -- 680
		return false -- 681
	end) -- 672
	host:onAppChange(function(setting) -- 683
		if setting == "Locale" then -- 683
			zh = (string.match(App.locale, "^zh")) ~= nil -- 684
		end -- 684
		if setting == "Size" or setting == "Locale" then -- 684
			render() -- 685
		end -- 685
	end) -- 683
	host:onAppEvent(function(event) -- 687
		if event == "BackButton" then -- 687
			if promptInput.isFocused() then -- 687
				blurInput() -- 688
			else -- 688
				goBack() -- 688
			end -- 688
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 688
			blurInput() -- 689
		end -- 689
	end) -- 687
	host:onCleanup(function() -- 691
		if packagePanel ~= nil then -- 691
			packagePanel:removeFromParent(true) -- 692
		end -- 692
		packagePanel = nil -- 693
		disposed = true -- 694
		blurInput() -- 694
	end) -- 691
	host:slot("SuspendLocalUI", blurInput) -- 696
	host:slot( -- 697
		"ResumeLocalUI", -- 697
		function() -- 697
			refresh() -- 697
			render() -- 697
		end -- 697
	) -- 697
	render() -- 698
	if needsLLMSetup then -- 698
		thread(function() -- 699
			sleep(0) -- 699
			if not disposed and host.parent then -- 699
				configureLLM() -- 699
			end -- 699
		end) -- 699
	end -- 699
	return host -- 700
end -- 106
return ____exports -- 106