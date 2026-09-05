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
local function measureWrappedTextHeight(text, width, fontSize) -- 80
	local measure = Label(fontName, fontSize, true) -- 81
	if not measure then -- 81
		return fontSize -- 82
	end -- 82
	measure.visible = false -- 83
	measure.textWidth = width -- 84
	measure.alignment = "Left" -- 85
	measure.text = text -- 86
	local height = measure.height -- 87
	measure:cleanup() -- 88
	return height -- 89
end -- 80
local function ActionButton(props) -- 92
	local height = props.height or 46 -- 93
	return React.createElement( -- 94
		"node", -- 94
		{ -- 94
			tag = props.tag, -- 94
			x = props.x, -- 94
			y = props.y, -- 94
			width = props.width, -- 94
			height = height, -- 94
			anchorX = 0, -- 94
			anchorY = 0, -- 94
			opacity = props.disabled and 0.45 or 1, -- 94
			touchEnabled = not props.disabled, -- 94
			swallowTouches = true, -- 94
			onTapped = props.onTapped -- 94
		}, -- 94
		React.createElement(RoundedSurface, { -- 94
			width = props.width, -- 94
			height = height, -- 94
			radius = 14, -- 94
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 94
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279704871), -- 94
			borderWidth = 1, -- 94
			borderColor = props.danger and colors.danger or (props.primary and 4294958435 or colors.border), -- 94
			shadow = props.primary or props.danger -- 94
		}), -- 94
		React.createElement("label", { -- 94
			x = props.width / 2, -- 94
			y = height / 2, -- 94
			fontName = fontName, -- 94
			fontSize = 15, -- 94
			text = props.text, -- 94
			color3 = props.primary and 1512202 or 16052712 -- 94
		}) -- 94
	) -- 94
end -- 92
local function ChoiceButton(props) -- 103
	local ____React_createElement_5 = React.createElement -- 103
	local ____temp_3 = { -- 103
		tag = props.tag, -- 103
		x = props.x, -- 103
		y = props.y, -- 103
		width = props.width, -- 103
		height = 40, -- 103
		anchorX = 0, -- 103
		anchorY = 0, -- 103
		opacity = props.disabled and 0.45 or 1, -- 103
		touchEnabled = not props.disabled, -- 103
		swallowTouches = true, -- 103
		onTapped = props.onTapped -- 103
	} -- 103
	local ____React_createElement_result_4 = React.createElement(RoundedSurface, { -- 103
		width = props.width, -- 103
		height = 40, -- 103
		radius = 12, -- 103
		topColor = props.selected and 4294958955 or 4280297526, -- 103
		bottomColor = props.selected and 4294950190 or 4279244061, -- 103
		borderWidth = 1, -- 103
		borderColor = props.selected and 4294958435 or colors.border -- 103
	}) -- 103
	local ____React_createElement_2 = React.createElement -- 103
	local ____array_1 = __TS__SparseArrayNew( -- 103
		"draw-node", -- 103
		{tag = props.tag and props.tag .. "-radio" or nil, x = 17, y = 20}, -- 103
		React.createElement("dot-shape", {radius = 7, color = props.selected and 4279702282 or 4289245117}), -- 103
		React.createElement("dot-shape", {radius = 5, color = props.selected and 4294954824 or 4279704614}) -- 103
	) -- 103
	local ____props_selected_0 -- 112
	if props.selected then -- 112
		____props_selected_0 = React.createElement( -- 112
			"draw-node", -- 112
			{tag = props.tag and props.tag .. "-radio-dot" or nil}, -- 112
			React.createElement("dot-shape", {radius = 2.5, color = 4279702282}) -- 112
		) -- 112
	else -- 112
		____props_selected_0 = nil -- 112
	end -- 112
	__TS__SparseArrayPush(____array_1, ____props_selected_0) -- 112
	return ____React_createElement_5( -- 104
		"node", -- 104
		____temp_3, -- 104
		____React_createElement_result_4, -- 104
		____React_createElement_2(__TS__SparseArraySpread(____array_1)), -- 104
		React.createElement("label", { -- 104
			x = 32, -- 104
			y = 20, -- 104
			anchorX = 0, -- 104
			fontName = fontName, -- 104
			fontSize = 14, -- 104
			text = props.text, -- 104
			textWidth = props.width - 44, -- 104
			alignment = "Left", -- 104
			color3 = props.selected and 1512202 or 16052712 -- 104
		}) -- 104
	) -- 104
end -- 103
function ____exports.startMobileRemix(options) -- 118
	local host, send, getTranscriptActions, render -- 118
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 119
	local onBack = options.onBack -- 120
	local onPlay = options.onPlay -- 121
	local packagePanel -- 122
	local services = options.services or ({ -- 123
		createSession = AgentSession.createSession, -- 124
		getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end, -- 125
		setWorkMode = AgentSession.setWorkMode, -- 126
		sendPrompt = AgentSession.sendPrompt, -- 127
		respondQuestionnaire = AgentSession.respondQuestionnaire, -- 128
		stopSessionTask = AgentSession.stopSessionTask, -- 129
		continuePrompt = AgentSession.continuePrompt, -- 130
		getActiveLLMConfig = getActiveLLMConfig, -- 131
		getLLMConfig = getLLMConfig, -- 132
		getLLMConfigSummaries = getLLMConfigSummaries -- 133
	}) -- 133
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 135
	local projectRoot = options.entry.workDir or "" -- 136
	local created = services.createSession(projectRoot, options.entry.title) -- 137
	local sessionId = created.success and created.session.id or 0 -- 138
	local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message}) -- 139
	local draft = "" -- 142
	local ____error = created.success and "" or created.message -- 143
	local backNoticeUntil = 0 -- 144
	local pollElapsed = 0 -- 145
	local stopRequested = false -- 146
	local selectedLLMConfigId = 0 -- 147
	local questionnaireId = 0 -- 148
	local questionIndex = 0 -- 149
	local llmConfigs = services.getLLMConfigSummaries() -- 150
	local taskLLMConfigId = 0 -- 151
	local needsLLMSetup = false -- 152
	local questionnaireSelections = {} -- 153
	local questionnaireTexts = {} -- 154
	local inputRef = reference() -- 155
	local disposed = false -- 156
	local dismissedComposition = false -- 157
	local swipeBackPending = false -- 158
	local swipeDragging = false -- 159
	local swipeRevision = 0 -- 160
	local projectChangeNotified = false -- 161
	local function currentQuestion() -- 162
		local ____detail_success_8 -- 162
		if detail.success then -- 162
			local ____opt_6 = detail.pendingQuestionnaire -- 162
			____detail_success_8 = ____opt_6 and ____opt_6.schema.questions[questionIndex + 1] -- 162
		else -- 162
			____detail_success_8 = nil -- 162
		end -- 162
		return ____detail_success_8 -- 162
	end -- 162
	local promptInput = createTextInput({ -- 163
		fontSize = math.floor(16 * mobileFontScale), -- 164
		getText = function() -- 165
			local question = currentQuestion() -- 165
			return question and (questionnaireTexts[question.id] or "") or draft -- 165
		end, -- 165
		setText = function(text) -- 166
			local question = currentQuestion() -- 166
			if question then -- 166
				questionnaireTexts[question.id] = text -- 166
			else -- 166
				draft = text -- 166
			end -- 166
		end, -- 166
		getPlaceholder = function() -- 167
			local question = currentQuestion() -- 168
			return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…")) -- 169
		end, -- 167
		isEnabled = function() return not packagePanel and not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end, -- 171
		onReturn = function(modified) -- 172
			if modified and not currentQuestion() then -- 172
				send() -- 172
				return true -- 172
			end -- 172
			return false -- 172
		end -- 172
	}) -- 172
	local blurInput = promptInput.blur -- 174
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 175
	local ____temp_11 -- 176
	if rememberedRows and #rememberedRows > 0 then -- 176
		____temp_11 = tonumber(rememberedRows[1][1]) -- 176
	else -- 176
		____temp_11 = nil -- 176
	end -- 176
	local rememberedId = ____temp_11 -- 176
	if rememberedId and __TS__ArraySome( -- 176
		llmConfigs, -- 177
		function(____, item) return item.id == rememberedId end -- 177
	) then -- 177
		selectedLLMConfigId = rememberedId -- 177
	elseif #llmConfigs > 0 then -- 177
		selectedLLMConfigId = llmConfigs[1].id -- 178
	else -- 178
		local activeConfig = services.getActiveLLMConfig() -- 180
		if activeConfig.success then -- 180
			selectedLLMConfigId = activeConfig.id -- 181
		else -- 181
			needsLLMSetup = true -- 182
		end -- 182
	end -- 182
	host = Node() -- 185
	host.tag = "mobile-remix" -- 186
	host.scaleX = App.devicePixelRatio -- 187
	host.scaleY = App.devicePixelRatio -- 188
	host:addTo(Director.systemUI) -- 189
	local transcript = createRemixTranscript() -- 190
	local displayRevision = "" -- 191
	local shellRevision = "" -- 192
	local inputLayout = "" -- 193
	local mascotAnimationState -- 194
	local mascotAnimationStartedAt = App.runningTime -- 195
	local compactHeaderStatusActive = false -- 196
	local errorLabel -- 197
	local layoutTranscriptBottom = transcriptBottom -- 198
	local function getLayoutArea() -- 199
		return App.safeArea -- 199
	end -- 199
	local function getTranscriptBottom() -- 200
		return layoutTranscriptBottom + (errorLabel and errorLabel.height + composerGap or 0) -- 200
	end -- 200
	local function hasTranscriptContent() -- 201
		return detail.success and (#detail.messages > 0 or #detail.steps > 0) -- 201
	end -- 201
	local function getHeaderY(safe) -- 202
		local landscapeTopLift = safe.width >= 760 and safe.height < 500 and 28 or 0 -- 203
		return safe.y + safe.height - 56 + landscapeTopLift -- 204
	end -- 202
	local function useCompactHeaderStatus(safe) -- 206
		return safe.width >= 760 and safe.height < 500 and hasTranscriptContent() -- 206
	end -- 206
	local function useCompactStandaloneStatus(safe) -- 207
		return safe.height >= 500 and hasTranscriptContent() -- 207
	end -- 207
	local function getTranscriptHeight(safe) -- 208
		local statusInset = useCompactHeaderStatus(safe) and composerGap or statusHeight + composerGap * 2 - (useCompactStandaloneStatus(safe) and 24 or 0) -- 209
		local available = math.max( -- 211
			40, -- 211
			getHeaderY(safe) - safe.y - getTranscriptBottom() - statusInset -- 211
		) -- 211
		return safe.width >= 760 and safe.height < 500 and not hasTranscriptContent() and 8 or available -- 212
	end -- 208
	local function getShellRevision() -- 214
		local ____detail_success_15 -- 214
		if detail.success then -- 214
			local ____safeJsonEncode_14 = safeJsonEncode -- 214
			local ____array_13 = __TS__SparseArrayNew( -- 214
				detail.session.status, -- 215
				detail.session.workMode, -- 215
				detail.hasActivePlan, -- 215
				detail.pendingQuestionnaire or false, -- 215
				detail.session.currentTaskStatus or "" -- 216
			) -- 216
			local ____detail_session_currentTaskFinalizing_12 = detail.session.currentTaskFinalizing -- 216
			if ____detail_session_currentTaskFinalizing_12 == nil then -- 216
				____detail_session_currentTaskFinalizing_12 = false -- 216
			end -- 216
			__TS__SparseArrayPush( -- 216
				____array_13, -- 216
				____detail_session_currentTaskFinalizing_12, -- 216
				stopRequested, -- 216
				hasTranscriptContent(), -- 216
				resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or "" -- 217
			) -- 217
			____detail_success_15 = (____safeJsonEncode_14({__TS__SparseArraySpread(____array_13)})) or "" -- 214
		else -- 214
			____detail_success_15 = detail.message -- 218
		end -- 218
		return ____detail_success_15 -- 214
	end -- 214
	local function updateTranscript() -- 219
		local safe = getLayoutArea() -- 220
		transcript:update( -- 221
			detail, -- 221
			math.max(60, safe.width - 32), -- 221
			getTranscriptHeight(safe), -- 221
			mobileFontScale, -- 221
			zh, -- 221
			getTranscriptActions() -- 221
		) -- 221
		displayRevision = remixDisplayRevision(detail) -- 222
	end -- 219
	local function hasActiveTask() -- 225
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil) -- 225
	end -- 225
	local function notifyProjectChanged() -- 228
		if projectChangeNotified or not detail.success or not options.onProjectChanged then -- 228
			return -- 229
		end -- 229
		if not __TS__ArraySome( -- 229
			detail.steps, -- 230
			function(____, step) return step.files ~= nil and #step.files > 0 end -- 230
		) then -- 230
			return -- 230
		end -- 230
		projectChangeNotified = true -- 231
		options.onProjectChanged(options.entry) -- 232
	end -- 228
	local function refresh() -- 234
		if sessionId > 0 then -- 234
			detail = services.getSession(sessionId) -- 235
		end -- 235
		if detail.success and not hasActiveTask() then -- 235
			stopRequested = false -- 236
		end -- 236
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then -- 236
			questionnaireId = detail.pendingQuestionnaire.id -- 238
			questionIndex = 0 -- 239
		end -- 239
	end -- 234
	local function canSubmit() -- 242
		return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire -- 242
	end -- 242
	local function resolveLLMConfig() -- 245
		return selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig() -- 245
	end -- 245
	local function configureLLM() -- 246
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 246
			return -- 247
		end -- 247
		blurInput() -- 248
		startMobileLLMManager({ -- 249
			coveredNode = host, -- 250
			selectedId = selectedLLMConfigId, -- 251
			taskRunning = hasActiveTask(), -- 252
			runningId = taskLLMConfigId, -- 253
			onSelected = function(id) -- 254
				if disposed or not host.parent then -- 254
					return -- 255
				end -- 255
				llmConfigs = services.getLLMConfigSummaries() -- 256
				selectedLLMConfigId = id -- 257
				needsLLMSetup = #llmConfigs == 0 -- 258
				____error = "" -- 259
				render() -- 260
			end, -- 254
			onClose = function() -- 262
				if not disposed and host.parent then -- 262
					render() -- 262
				end -- 262
			end -- 262
		}) -- 262
	end -- 246
	local function changeWorkMode(workMode) -- 265
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 265
			return -- 266
		end -- 266
		refresh() -- 267
		if not canSubmit() or not detail.success then -- 267
			return -- 268
		end -- 268
		if resolveRemixWorkMode(detail.session) == workMode then -- 268
			return -- 269
		end -- 269
		local result = services.setWorkMode(sessionId, workMode) -- 270
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode")) -- 271
		refresh() -- 272
		render() -- 273
	end -- 265
	send = function() -- 275
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 275
			return -- 276
		end -- 276
		refresh() -- 277
		if not canSubmit() or not detail.success or promptInput.isComposing() then -- 277
			return -- 278
		end -- 278
		local workMode = resolveRemixWorkMode(detail.session) -- 279
		local text = (string.match(draft, "^%s*(.-)%s*$")) or "" -- 282
		if sessionId <= 0 or text == "" then -- 282
			return -- 283
		end -- 283
		local config = resolveLLMConfig() -- 284
		if not config.success then -- 284
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 286
			render() -- 287
			configureLLM() -- 288
			return -- 289
		end -- 289
		selectedLLMConfigId = config.id -- 291
		local result = services.sendPrompt( -- 292
			sessionId, -- 292
			text, -- 292
			nil, -- 292
			workMode, -- 292
			config.id, -- 292
			config.config -- 292
		) -- 292
		if not result.success then -- 292
			____error = result.message -- 293
		else -- 293
			taskLLMConfigId = config.id -- 294
			draft = "" -- 294
			____error = "" -- 294
		end -- 294
		refresh() -- 295
		render() -- 296
	end -- 275
	local function continueTask() -- 298
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 298
			return -- 299
		end -- 299
		refresh() -- 300
		if not detail.success or hasActiveTask() or detail.session.currentTaskStatus ~= "FAILED" and detail.session.currentTaskStatus ~= "STOPPED" or detail.session.currentTaskId == nil then -- 300
			return -- 302
		end -- 302
		local config = resolveLLMConfig() -- 303
		if not config.success then -- 303
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 305
			render() -- 306
			configureLLM() -- 307
			return -- 308
		end -- 308
		if not services.continuePrompt then -- 308
			____error = zh and "当前版本不支持继续会话" or "Continuing this session is unavailable" -- 311
			render() -- 312
			return -- 313
		end -- 313
		selectedLLMConfigId = config.id -- 315
		local result = services.continuePrompt(sessionId, nil, config.id) -- 316
		____error = result.success and "" or result.message -- 317
		if result.success then -- 317
			taskLLMConfigId = config.id -- 318
			stopRequested = false -- 318
		end -- 318
		refresh() -- 319
		render() -- 320
	end -- 298
	local function startDevelopment() -- 322
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 322
			return -- 323
		end -- 323
		refresh() -- 324
		if not detail.success or hasActiveTask() or detail.session.workMode ~= "plan" or not detail.hasActivePlan then -- 324
			return -- 325
		end -- 325
		local modeResult = services.setWorkMode(sessionId, "code") -- 326
		if not modeResult.success then -- 326
			____error = modeResult.message or (zh and "切换执行模式失败" or "Could not switch to Code mode") -- 328
			render() -- 329
			return -- 330
		end -- 330
		local config = resolveLLMConfig() -- 332
		if not config.success then -- 332
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 334
			refresh() -- 335
			render() -- 336
			configureLLM() -- 337
			return -- 338
		end -- 338
		selectedLLMConfigId = config.id -- 340
		local prompt = zh and "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。" or "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated." -- 341
		local result = services.sendPrompt( -- 344
			sessionId, -- 344
			prompt, -- 344
			nil, -- 344
			"code", -- 344
			config.id, -- 344
			config.config -- 344
		) -- 344
		____error = result.success and "" or result.message -- 345
		if result.success then -- 345
			taskLLMConfigId = config.id -- 346
		end -- 346
		refresh() -- 347
		render() -- 348
	end -- 322
	getTranscriptActions = function() -- 350
		if not detail.success or not hasTranscriptContent() or hasActiveTask() or __TS__ArrayEvery( -- 350
			detail.messages, -- 351
			function(____, message) return message.role ~= "assistant" end -- 351
		) then -- 351
			return {} -- 351
		end -- 351
		local actions = {} -- 352
		if (detail.session.currentTaskStatus == "FAILED" or detail.session.currentTaskStatus == "STOPPED") and detail.session.currentTaskId ~= nil then -- 352
			actions[#actions + 1] = {id = "continue", text = zh and "继续" or "Continue", onTapped = continueTask} -- 354
		end -- 354
		if detail.session.kind == "main" and detail.session.workMode == "plan" and detail.hasActivePlan then -- 354
			actions[#actions + 1] = {id = "start-development", text = zh and "开始开发" or "Start development", primary = true, onTapped = startDevelopment} -- 356
		end -- 356
		return actions -- 357
	end -- 350
	local function stop() -- 359
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 359
			return -- 360
		end -- 360
		refresh() -- 361
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then -- 361
			return -- 363
		end -- 363
		local result = services.stopSessionTask(sessionId) -- 364
		if (result and result.success) == false then -- 364
			____error = result.message or (zh and "停止失败" or "Could not stop") -- 365
		else -- 365
			stopRequested = true -- 366
			____error = "" -- 366
		end -- 366
		refresh() -- 367
		render() -- 368
	end -- 359
	local function advanceQuestionnaire(skipCurrent) -- 370
		if skipCurrent == nil then -- 370
			skipCurrent = false -- 370
		end -- 370
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 370
			return -- 371
		end -- 371
		if not detail.success or not detail.pendingQuestionnaire then -- 371
			return -- 372
		end -- 372
		local pending = detail.pendingQuestionnaire -- 373
		local questions = pending.schema.questions -- 374
		local question = questions[questionIndex + 1] -- 375
		if not question then -- 375
			return -- 376
		end -- 376
		local selected = questionnaireSelections[question.id] or ({}) -- 377
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "") -- 378
		if skipCurrent then -- 378
			if question.required then -- 378
				return -- 380
			end -- 380
			questionnaireSelections[question.id] = {} -- 381
			questionnaireTexts[question.id] = "" -- 382
		elseif not isQuestionAnswered(question, selected, text) then -- 382
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 384
			render() -- 385
			return -- 386
		end -- 386
		if questionIndex + 1 < #questions then -- 386
			questionIndex = questionIndex + 1 -- 389
			____error = "" -- 390
			render() -- 391
			return -- 392
		end -- 392
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 394
		if selectedLLMConfigId <= 0 then -- 394
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 396
			render() -- 397
			return -- 398
		end -- 398
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 400
		if not result.success then -- 400
			____error = result.message -- 401
		else -- 401
			taskLLMConfigId = selectedLLMConfigId -- 402
			____error = "" -- 402
		end -- 402
		refresh() -- 403
		render() -- 404
	end -- 370
	local function goBack() -- 406
		if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 406
			return -- 407
		end -- 407
		if detail.success and not canLeaveRemix(detail.session.status) then -- 407
			____error = "" -- 409
			backNoticeUntil = App.runningTime + 3 -- 410
			render() -- 411
			return -- 412
		end -- 412
		blurInput() -- 414
		notifyProjectChanged() -- 415
		host.visible = false -- 416
		host:removeFromParent(true) -- 417
		onBack() -- 418
	end -- 406
	render = function() -- 421
		local visibleError = ____error ~= "" and ____error or (backNoticeUntil > App.runningTime and (zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back") or "") -- 422
		errorLabel = nil -- 424
		swipeRevision = swipeRevision + 1 -- 426
		swipeDragging = false -- 427
		swipeBackPending = false -- 428
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height) -- 429
		local ____temp_20 = layout == inputLayout and not (detail.success and detail.pendingQuestionnaire) -- 431
		if ____temp_20 then -- 431
			local ____opt_18 = inputRef.current -- 431
			____temp_20 = (____opt_18 and ____opt_18.tag) == "remix-input" -- 431
		end -- 431
		local keptInput = ____temp_20 and inputRef.current or nil -- 431
		if keptInput ~= nil then -- 431
			keptInput:removeFromParent(false) -- 433
		end -- 433
		transcript.node:removeFromParent(false) -- 434
		local restoreInputFocus = promptInput.isFocused() -- 435
		if not keptInput then -- 435
			promptInput.unmount() -- 437
			inputRef = reference() -- 438
		end -- 438
		host:removeAllChildren() -- 440
		inputLayout = layout -- 441
		host.scaleX = App.devicePixelRatio -- 442
		host.scaleY = App.devicePixelRatio -- 443
		local ____App_visualSize_23 = App.visualSize -- 444
		local width = ____App_visualSize_23.width -- 444
		local height = ____App_visualSize_23.height -- 444
		local safe = getLayoutArea() -- 445
		local left = safe.x -- 446
		local bottom = safe.y -- 447
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 448
		local state = detail.success and detail.session or nil -- 449
		local workMode = resolveRemixWorkMode(state) -- 450
		local stopping = hasActiveTask() -- 451
		local ____detail_success_24 -- 452
		if detail.success then -- 452
			____detail_success_24 = detail.hasActivePlan -- 452
		else -- 452
			____detail_success_24 = false -- 452
		end -- 452
		local hasActivePlan = ____detail_success_24 -- 452
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 453
		local layoutComposerBottom = 24 -- 454
		local layoutComposerHeight = composerHeight -- 455
		local layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap -- 456
		local layoutComposerTop = layoutModeBottom + 40 -- 457
		layoutTranscriptBottom = layoutComposerTop + composerGap + (phase == "done" and 48 or 0) -- 458
		local contentWidth = safe.width - 32 -- 459
		local inputWidth = contentWidth - composerActionWidth - composerGap -- 460
		local modeWidth = math.floor((contentWidth - composerGap) / 2) -- 461
		local modeStartX = left + 16 -- 462
		local modeCodeWidth = contentWidth - modeWidth - composerGap -- 463
		local playWidth = canShare and (contentWidth - composerGap) / 2 or contentWidth -- 464
		local playX = canShare and modeStartX + playWidth + composerGap or modeStartX -- 465
		local ____detail_success_25 -- 466
		if detail.success then -- 466
			____detail_success_25 = detail.pendingQuestionnaire -- 466
		else -- 466
			____detail_success_25 = nil -- 466
		end -- 466
		local questionnaire = ____detail_success_25 -- 466
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 467
		local questionPromptWidth = contentWidth - 32 -- 468
		local questionPromptHeight = question and measureWrappedTextHeight(question.prompt, questionPromptWidth, 16) or 0 -- 469
		local questionAnswerTop = safe.height - 405 - questionPromptHeight / 2 - 14 -- 470
		local questionHasBack = questionIndex > 0 -- 471
		local questionCanSkip = question ~= nil and not question.required -- 472
		local questionActionGap = 8 -- 473
		local questionBackWidth = 76 -- 474
		local questionSkipWidth = 64 -- 475
		local questionSkipX = 16 + (questionHasBack and questionBackWidth + questionActionGap or 0) -- 476
		local questionSubmitX = questionSkipX + (questionCanSkip and questionSkipWidth + questionActionGap or 0) -- 477
		local fontScale = mobileFontScale -- 478
		local headerY = getHeaderY(safe) -- 479
		local compactHeaderStatus = useCompactHeaderStatus(safe) -- 480
		compactHeaderStatusActive = compactHeaderStatus -- 481
		local headerStatusWidth = 168 -- 482
		local modelButtonWidth = shortLandscape and 92 or 72 -- 483
		local backText = zh and "返回 ›" or "Back ›" -- 484
		local backMeasure = Label(fontName, 18, true) -- 485
		backMeasure.text = backText -- 486
		local backWidth = math.max(44, backMeasure.width) -- 487
		backMeasure:cleanup() -- 488
		local headerBackX = left + safe.width - 16 - backWidth -- 489
		local headerSettingsX = headerBackX - composerGap - modelButtonWidth -- 490
		local headerStatusX = headerSettingsX - 8 - headerStatusWidth -- 491
		local headerTitleWidth = compactHeaderStatus and math.max(120, headerStatusX - (left + 16) - composerGap) or math.max(120, headerSettingsX - (left + 16) - composerGap) -- 492
		local selectedConfig = __TS__ArrayFind( -- 495
			llmConfigs, -- 495
			function(____, item) return item.id == selectedLLMConfigId end -- 495
		) -- 495
		local switchPending = hasActiveTask() and taskLLMConfigId > 0 and taskLLMConfigId ~= selectedLLMConfigId -- 496
		local modelName = selectedConfig and selectedConfig.name or (zh and "配置 AI" or "Set up AI") -- 497
		local modelNameLimit = shortLandscape and 10 or 6 -- 498
		local shortModelName = inputLength(modelName) > modelNameLimit and inputSlice(modelName, 0, modelNameLimit) .. "…" or modelName -- 499
		local modelLabel = ellipsizeSingleLine((switchPending and (zh and "下一轮·" or "Next·") or "") .. shortModelName, modelButtonWidth - 14, 11) -- 500
		local thinkingText = resolveRemixThinkingStatus(detail.success and detail.steps or ({}), state and state.currentTaskId) -- 501
		local statusText = thinkingText ~= nil and (zh and "正在思考" or "Thinking") or (phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game"))))))) -- 502
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 509
		if mascotAnimationState ~= mascotState then -- 509
			mascotAnimationState = mascotState -- 516
			mascotAnimationStartedAt = App.runningTime -- 517
		end -- 517
		local emptyLandscape = shortLandscape and not hasTranscriptContent() -- 519
		local emptyStatusBottom = bottom + layoutTranscriptBottom -- 520
		local emptyStatusTop = headerY - composerGap - statusHeight -- 521
		local messageTop = emptyLandscape and (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2 or headerY - composerGap - statusHeight / 2 -- 522
		local mascotSize = shortLandscape and 42 or 52 -- 525
		local compactStandaloneStatus = useCompactStandaloneStatus(safe) -- 526
		local standaloneStatusContentLift = shortLandscape and 0 or (compactStandaloneStatus and 26 or 14) -- 527
		local mascotX = shortLandscape and left + 40 or left + 66 -- 528
		local statusTextX = shortLandscape and left + 76 or left + 104 -- 529
		local statusTextWidth = shortLandscape and math.max(120, left + 16 + contentWidth - statusTextX) or contentWidth - 84 -- 530
		local renderedStatusX = compactHeaderStatus and 36 or statusTextX -- 531
		local renderedStatusY = compactHeaderStatus and 22 or statusHeight / 2 + standaloneStatusContentLift -- 532
		local renderedStatusWidth = compactHeaderStatus and headerStatusWidth - 36 or statusTextWidth -- 533
		local thinkingFontSize = compactHeaderStatus and math.floor(10 * fontScale) or math.floor(12 * fontScale) -- 534
		local thinkingRightPadding = compactHeaderStatus and 8 or 20 -- 535
		local renderedThinkingText = thinkingText == nil and "" or ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize) -- 536
		local swipeStart = Vec2.zero -- 537
		local swipeAxis = "none" -- 538
		local pageRef = reference() -- 539
		local hitsTranscriptButton -- 540
		hitsTranscriptButton = function(node, world) -- 540
			if not node.visible then -- 540
				return false -- 541
			end -- 541
			if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then -- 541
				local p = node:convertToNodeSpace(world) -- 543
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 543
					return true -- 544
				end -- 544
			end -- 544
			local hit = false -- 546
			node:eachChild(function(child) -- 547
				hit = hitsTranscriptButton(child, world) -- 547
				return hit -- 547
			end) -- 547
			return hit -- 548
		end -- 540
		local ____toNode_70 = toNode -- 550
		local ____React_createElement_69 = React.createElement -- 550
		local ____array_68 = __TS__SparseArrayNew( -- 550
			"node", -- 550
			{ -- 550
				tag = "remix-scene", -- 550
				x = -width / 2, -- 550
				y = -height / 2, -- 550
				width = width, -- 550
				height = height, -- 550
				anchorX = 0, -- 550
				anchorY = 0 -- 550
			}, -- 550
			React.createElement( -- 550
				"node", -- 550
				{ -- 550
					tag = "remix-focus-observer", -- 550
					order = 1000, -- 550
					width = width, -- 550
					height = height, -- 550
					anchorX = 0, -- 550
					anchorY = 0, -- 550
					touchEnabled = true, -- 550
					swallowTouches = false, -- 550
					swallowMouseWheel = false, -- 550
					onTapFilter = function(touch) -- 550
						touch.enabled = false -- 554
						if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 554
							return -- 555
						end -- 555
						local input = inputRef.current -- 556
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 557
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 558
						dismissedComposition = not inside and promptInput.isComposing() -- 559
						if not inside then -- 559
							blurInput() -- 560
						end -- 560
						if not inside and not questionnaire and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 560
							touch.enabled = true -- 565
						end -- 565
					end, -- 553
					onTapBegan = function(touch) -- 553
						swipeStart = touch.location -- 569
						swipeAxis = "none" -- 569
						swipeDragging = true -- 569
						local ____opt_34 = pageRef.current -- 569
						if ____opt_34 ~= nil then -- 569
							____opt_34:stopAllActions() -- 570
						end -- 570
					end, -- 568
					onTapMoved = function(touch) -- 568
						local delta = touch.location:sub(swipeStart) -- 573
						if swipeAxis == "none" and math.max( -- 573
							math.abs(delta.x), -- 574
							math.abs(delta.y) -- 574
						) >= 12 then -- 574
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 575
						end -- 575
						if pageRef.current then -- 575
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 577
						end -- 577
					end, -- 572
					onTapEnded = function(touch) -- 572
						local delta = touch.location:sub(swipeStart) -- 580
						swipeDragging = false -- 581
						if swipeBackPending then -- 581
							return -- 582
						end -- 582
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 583
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 584
						local page = pageRef.current -- 585
						if not page or not requested and page.x == 0 then -- 585
							return -- 586
						end -- 586
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 587
						local revision = swipeRevision -- 588
						swipeBackPending = true -- 589
						if not leaving then -- 589
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 591
						end -- 591
						thread(function() -- 593
							sleep(duration) -- 594
							if disposed or revision ~= swipeRevision or not host.parent then -- 594
								return -- 595
							end -- 595
							swipeBackPending = false -- 596
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 596
								refresh() -- 597
								goBack() -- 597
							else -- 597
								page.position = Vec2.zero -- 598
							end -- 598
						end) -- 593
					end -- 579
				} -- 579
			), -- 579
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 579
		) -- 579
		local ____React_createElement_67 = React.createElement -- 579
		local ____array_66 = __TS__SparseArrayNew( -- 579
			"node", -- 579
			{tag = "remix-page", ref = pageRef}, -- 579
			React.createElement( -- 579
				"clip-node", -- 579
				{ -- 579
					x = left + 16, -- 579
					y = headerY, -- 579
					width = headerTitleWidth, -- 579
					height = 44, -- 579
					anchorX = 0, -- 579
					anchorY = 0, -- 579
					stencil = React.createElement( -- 579
						"draw-node", -- 579
						{x = headerTitleWidth / 2, y = 22}, -- 579
						React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295}) -- 579
					) -- 579
				}, -- 579
				React.createElement("label", { -- 579
					tag = "remix-title", -- 579
					x = 0, -- 579
					y = 22, -- 579
					anchorX = 0, -- 579
					fontName = fontName, -- 579
					fontSize = 20, -- 579
					text = "REMIX · " .. options.entry.title, -- 579
					color3 = 16052712 -- 579
				}) -- 579
			), -- 579
			React.createElement( -- 579
				"node", -- 579
				{ -- 579
					tag = "remix-back", -- 579
					x = headerBackX, -- 579
					y = headerY, -- 579
					width = backWidth, -- 579
					height = 44, -- 579
					anchorX = 0, -- 579
					anchorY = 0, -- 579
					touchEnabled = true, -- 579
					swallowTouches = true, -- 579
					onTapped = goBack -- 579
				}, -- 579
				React.createElement("label", { -- 579
					x = backWidth, -- 579
					y = 22, -- 579
					anchorX = 1, -- 579
					fontName = fontName, -- 579
					fontSize = 18, -- 579
					text = backText, -- 579
					color3 = 16763955 -- 579
				}) -- 579
			) -- 579
		) -- 579
		local ____React_createElement_38 = React.createElement -- 579
		local ____array_37 = __TS__SparseArrayNew( -- 579
			"node", -- 579
			{ -- 579
				tag = "remix-model-config", -- 579
				x = headerSettingsX, -- 579
				y = headerY + 6, -- 579
				width = modelButtonWidth, -- 579
				height = 32, -- 579
				anchorX = 0, -- 579
				anchorY = 0, -- 579
				touchEnabled = true, -- 579
				swallowTouches = true, -- 579
				onTapped = configureLLM -- 579
			}, -- 579
			React.createElement(RoundedSurface, { -- 579
				width = modelButtonWidth, -- 579
				height = 32, -- 579
				radius = 16, -- 579
				topColor = 858534978, -- 579
				bottomColor = 856824097, -- 579
				borderWidth = 1, -- 579
				borderColor = needsLLMSetup and colors.brand or colors.border -- 579
			}), -- 579
			React.createElement("label", { -- 579
				x = modelButtonWidth / 2, -- 579
				y = 16, -- 579
				fontName = fontName, -- 579
				fontSize = 11, -- 579
				text = modelLabel, -- 579
				color3 = (needsLLMSetup or switchPending) and 16763955 or 11055037 -- 579
			}) -- 579
		) -- 579
		local ____needsLLMSetup_36 -- 616
		if needsLLMSetup then -- 616
			____needsLLMSetup_36 = React.createElement( -- 616
				"draw-node", -- 616
				{x = modelButtonWidth - 4, y = 28}, -- 616
				React.createElement("dot-shape", {radius = 3, color = 4294954035}) -- 616
			) -- 616
		else -- 616
			____needsLLMSetup_36 = nil -- 616
		end -- 616
		__TS__SparseArrayPush(____array_37, ____needsLLMSetup_36) -- 616
		__TS__SparseArrayPush( -- 616
			____array_66, -- 616
			____React_createElement_38(__TS__SparseArraySpread(____array_37)), -- 616
			React.createElement( -- 616
				"node", -- 616
				{ -- 616
					tag = "remix-status", -- 616
					x = compactHeaderStatus and headerStatusX or 0, -- 616
					y = compactHeaderStatus and headerY or messageTop - statusHeight / 2, -- 616
					width = compactHeaderStatus and headerStatusWidth or width, -- 616
					height = compactHeaderStatus and 44 or statusHeight, -- 616
					anchorX = 0, -- 616
					anchorY = 0 -- 616
				}, -- 616
				React.createElement(DoraMascot, { -- 616
					state = mascotState, -- 616
					x = compactHeaderStatus and 16 or mascotX, -- 616
					y = compactHeaderStatus and 20 or statusHeight / 2 - 2 + standaloneStatusContentLift, -- 616
					size = compactHeaderStatus and 30 or mascotSize, -- 616
					animationStartedAt = mascotAnimationStartedAt -- 616
				}), -- 616
				React.createElement( -- 616
					"clip-node", -- 616
					{ -- 616
						tag = "remix-status-clip", -- 616
						x = renderedStatusX, -- 616
						y = renderedStatusY - 22, -- 616
						width = renderedStatusWidth, -- 616
						height = 44, -- 616
						anchorX = 0, -- 616
						anchorY = 0, -- 616
						stencil = React.createElement( -- 616
							"draw-node", -- 616
							{x = renderedStatusWidth / 2, y = 22}, -- 616
							React.createElement("rect-shape", {width = renderedStatusWidth, height = 44, fillColor = 4294967295}) -- 616
						) -- 616
					}, -- 616
					React.createElement( -- 616
						"label", -- 616
						{ -- 616
							tag = "remix-status-text", -- 616
							x = 0, -- 616
							y = 22, -- 616
							anchorX = 0, -- 616
							fontName = fontName, -- 616
							fontSize = compactHeaderStatus and math.floor(13 * fontScale) or math.floor(15 * fontScale), -- 616
							text = statusText, -- 616
							textWidth = -1, -- 616
							alignment = "Left", -- 616
							color3 = phase == "failed" and 16739179 or 16763955 -- 616
						} -- 616
					), -- 616
					React.createElement("label", { -- 616
						tag = "remix-thinking-text", -- 616
						x = 0, -- 616
						y = 6, -- 616
						anchorX = 0, -- 616
						fontName = fontName, -- 616
						fontSize = thinkingFontSize, -- 616
						text = renderedThinkingText, -- 616
						textWidth = -1, -- 616
						alignment = "Left", -- 616
						color3 = colors.muted -- 616
					}) -- 616
				) -- 616
			) -- 616
		) -- 616
		local ____temp_47 -- 632
		if questionnaire and question then -- 632
			local ____React_createElement_46 = React.createElement -- 632
			local ____array_45 = __TS__SparseArrayNew( -- 632
				"node", -- 632
				{ -- 632
					tag = "remix-questionnaire", -- 632
					x = left + 16, -- 632
					y = bottom + 164, -- 632
					width = contentWidth, -- 632
					height = safe.height - 330, -- 632
					anchorX = 0, -- 632
					anchorY = 0 -- 632
				}, -- 632
				React.createElement(RoundedSurface, { -- 632
					width = contentWidth, -- 632
					height = safe.height - 330, -- 632
					radius = 20, -- 632
					topColor = 4280429370, -- 632
					bottomColor = 4279375648, -- 632
					borderWidth = 1, -- 632
					borderColor = 4282469213, -- 632
					shadow = true -- 632
				}), -- 632
				React.createElement( -- 632
					"label", -- 632
					{ -- 632
						x = 16, -- 632
						y = safe.height - 360, -- 632
						anchorX = 0, -- 632
						fontName = fontName, -- 632
						fontSize = 13, -- 632
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 632
						textWidth = contentWidth - 32, -- 632
						alignment = "Left", -- 632
						color3 = 16763955 -- 632
					} -- 632
				), -- 632
				React.createElement("label", { -- 632
					tag = "remix-question-prompt", -- 632
					x = 16, -- 632
					y = safe.height - 405, -- 632
					anchorX = 0, -- 632
					fontName = fontName, -- 632
					fontSize = 16, -- 632
					text = question.prompt, -- 632
					textWidth = questionPromptWidth, -- 632
					alignment = "Left", -- 632
					color3 = 16052712 -- 632
				}), -- 632
				question.type ~= "text" and __TS__ArrayMap( -- 636
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 636
					function(____, option, optionIndex) return React.createElement( -- 636
						ChoiceButton, -- 636
						{ -- 636
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 636
							x = 16, -- 636
							y = questionAnswerTop - 40 - optionIndex * 43, -- 636
							width = contentWidth - 32, -- 636
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 636
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 636
							onTapped = function() -- 636
								local selected = questionnaireSelections[question.id] or ({}) -- 642
								local ____question_id_42 = question.id -- 643
								local ____temp_41 -- 643
								if question.type == "single_choice" then -- 643
									____temp_41 = {option.id} -- 644
								else -- 644
									local ____temp_40 -- 645
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 645
										____temp_40 = __TS__ArrayFilter( -- 645
											selected, -- 645
											function(____, id) return id ~= option.id end -- 645
										) -- 645
									else -- 645
										local ____array_39 = __TS__SparseArrayNew(table.unpack(selected)) -- 645
										__TS__SparseArrayPush(____array_39, option.id) -- 645
										____temp_40 = {__TS__SparseArraySpread(____array_39)} -- 645
									end -- 645
									____temp_41 = ____temp_40 -- 645
								end -- 645
								questionnaireSelections[____question_id_42] = ____temp_41 -- 643
								render() -- 646
							end -- 641
						} -- 641
					) end -- 641
				) or React.createElement("node", { -- 641
					tag = "remix-question-input", -- 641
					ref = inputRef, -- 641
					x = 16, -- 641
					y = questionAnswerTop - 92, -- 641
					width = contentWidth - 32, -- 641
					height = 92, -- 641
					anchorX = 0, -- 641
					anchorY = 0, -- 641
					onMount = promptInput.mount -- 641
				}) -- 641
			) -- 641
			local ____questionHasBack_43 -- 650
			if questionHasBack then -- 650
				____questionHasBack_43 = React.createElement( -- 650
					ActionButton, -- 650
					{ -- 650
						tag = "remix-question-back", -- 650
						x = 16, -- 650
						y = 12, -- 650
						width = questionBackWidth, -- 650
						text = zh and "上一步" or "Back", -- 650
						onTapped = function() -- 650
							questionIndex = questionIndex - 1 -- 650
							render() -- 650
						end -- 650
					} -- 650
				) -- 650
			else -- 650
				____questionHasBack_43 = nil -- 650
			end -- 650
			__TS__SparseArrayPush(____array_45, ____questionHasBack_43) -- 650
			local ____questionCanSkip_44 -- 651
			if questionCanSkip then -- 651
				____questionCanSkip_44 = React.createElement( -- 651
					ActionButton, -- 651
					{ -- 651
						tag = "remix-question-skip", -- 651
						x = questionSkipX, -- 651
						y = 12, -- 651
						width = questionSkipWidth, -- 651
						text = zh and "跳过" or "Skip", -- 651
						onTapped = function() return advanceQuestionnaire(true) end -- 651
					} -- 651
				) -- 651
			else -- 651
				____questionCanSkip_44 = nil -- 651
			end -- 651
			__TS__SparseArrayPush( -- 651
				____array_45, -- 651
				____questionCanSkip_44, -- 651
				React.createElement( -- 651
					ActionButton, -- 652
					{ -- 652
						tag = "remix-question-submit", -- 652
						x = questionSubmitX, -- 652
						y = 12, -- 652
						width = contentWidth - questionSubmitX - 16, -- 652
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 652
						primary = true, -- 652
						onTapped = function() -- 652
							if not dismissedComposition then -- 652
								advanceQuestionnaire() -- 654
							end -- 654
							dismissedComposition = false -- 654
						end -- 654
					} -- 654
				) -- 654
			) -- 654
			____temp_47 = ____React_createElement_46(__TS__SparseArraySpread(____array_45)) -- 654
		else -- 654
			____temp_47 = nil -- 655
		end -- 655
		__TS__SparseArrayPush(____array_66, ____temp_47) -- 655
		local ____temp_48 -- 656
		if visibleError ~= "" then -- 656
			____temp_48 = React.createElement( -- 656
				"label", -- 656
				{ -- 656
					tag = "remix-error", -- 656
					x = left + 20, -- 656
					y = bottom + (questionnaire and 144 or layoutComposerTop + composerGap), -- 656
					anchorX = 0, -- 656
					anchorY = 0, -- 656
					fontName = fontName, -- 656
					fontSize = 13, -- 656
					text = visibleError, -- 656
					textWidth = contentWidth, -- 656
					alignment = "Left", -- 656
					color3 = 16739179, -- 656
					onMount = function(label) -- 656
						errorLabel = label -- 656
					end -- 656
				} -- 656
			) -- 656
		else -- 656
			____temp_48 = nil -- 656
		end -- 656
		__TS__SparseArrayPush(____array_66, ____temp_48) -- 656
		local ____temp_49 -- 657
		if questionnaire == nil then -- 657
			____temp_49 = React.createElement( -- 657
				"node", -- 657
				nil, -- 657
				React.createElement( -- 657
					ChoiceButton, -- 658
					{ -- 658
						tag = "remix-mode-plan", -- 658
						x = modeStartX, -- 658
						y = bottom + layoutModeBottom, -- 658
						width = modeWidth, -- 658
						text = zh and "计划" or "Plan", -- 658
						selected = workMode == "plan", -- 658
						disabled = not canSubmit(), -- 658
						onTapped = function() return changeWorkMode("plan") end -- 658
					} -- 658
				), -- 658
				React.createElement( -- 658
					ChoiceButton, -- 659
					{ -- 659
						tag = "remix-mode-code", -- 659
						x = modeStartX + modeWidth + composerGap, -- 659
						y = bottom + layoutModeBottom, -- 659
						width = modeCodeWidth, -- 659
						text = zh and "执行" or "Code", -- 659
						selected = workMode == "code", -- 659
						disabled = not canSubmit(), -- 659
						onTapped = function() return changeWorkMode("code") end -- 659
					} -- 659
				) -- 659
			) -- 659
		else -- 659
			____temp_49 = nil -- 660
		end -- 660
		__TS__SparseArrayPush(____array_66, ____temp_49) -- 660
		local ____temp_50 -- 661
		if questionnaire == nil and not keptInput then -- 661
			____temp_50 = React.createElement("node", { -- 661
				tag = "remix-input", -- 661
				ref = inputRef, -- 661
				x = left + 16, -- 661
				y = bottom + layoutComposerBottom, -- 661
				width = inputWidth, -- 661
				height = layoutComposerHeight, -- 661
				anchorX = 0, -- 661
				anchorY = 0, -- 661
				onMount = promptInput.mount -- 661
			}) -- 661
		else -- 661
			____temp_50 = nil -- 662
		end -- 662
		__TS__SparseArrayPush(____array_66, ____temp_50) -- 662
		local ____temp_63 -- 663
		if stopping or questionnaire == nil then -- 663
			local ____React_createElement_62 = React.createElement -- 663
			local ____ActionButton_61 = ActionButton -- 663
			local ____temp_56 = stopping and "remix-stop" or "remix-send" -- 663
			local ____temp_57 = left + 16 + inputWidth + composerGap -- 664
			local ____temp_58 = bottom + layoutComposerBottom -- 664
			local ____temp_59 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 665
			local ____temp_60 = not stopping -- 666
			local ____stopping_55 -- 666
			if stopping then -- 666
				____stopping_55 = stopRequested or (state and state.currentTaskFinalizing) == true -- 666
			else -- 666
				____stopping_55 = not canSubmit() -- 666
			end -- 666
			____temp_63 = ____React_createElement_62( -- 666
				____ActionButton_61, -- 663
				{ -- 663
					tag = ____temp_56, -- 663
					x = ____temp_57, -- 663
					y = ____temp_58, -- 663
					width = composerActionWidth, -- 663
					height = layoutComposerHeight, -- 663
					text = ____temp_59, -- 663
					primary = ____temp_60, -- 663
					danger = stopping, -- 663
					disabled = ____stopping_55, -- 663
					onTapped = function() -- 663
						if stopping then -- 663
							stop() -- 667
						elseif not dismissedComposition then -- 667
							send() -- 667
						end -- 667
						dismissedComposition = false -- 667
					end -- 667
				} -- 667
			) -- 667
		else -- 667
			____temp_63 = nil -- 667
		end -- 667
		__TS__SparseArrayPush(____array_66, ____temp_63) -- 667
		local ____temp_64 -- 668
		if phase == "done" and canShare then -- 668
			____temp_64 = React.createElement( -- 668
				ActionButton, -- 668
				{ -- 668
					tag = "remix-share", -- 668
					x = left + 16, -- 668
					y = bottom + layoutModeBottom + 48, -- 668
					width = playWidth, -- 668
					height = 40, -- 668
					text = zh and "分享作品" or "Share game", -- 668
					onTapped = function() -- 668
						if not host.visible or packagePanel or HttpServer.wsConnectionCount > 0 then -- 668
							return -- 669
						end -- 669
						blurInput() -- 670
						notifyProjectChanged() -- 670
						packagePanel = startPackagePanel({ -- 671
							mode = "share", -- 671
							entry = options.entry, -- 671
							onClosed = function() -- 671
								packagePanel = nil -- 671
							end -- 671
						}) -- 671
					end -- 668
				} -- 668
			) -- 668
		else -- 668
			____temp_64 = nil -- 672
		end -- 672
		__TS__SparseArrayPush(____array_66, ____temp_64) -- 672
		local ____temp_65 -- 673
		if phase == "done" then -- 673
			____temp_65 = React.createElement( -- 673
				ActionButton, -- 673
				{ -- 673
					tag = "remix-play", -- 673
					x = playX, -- 673
					y = bottom + layoutModeBottom + 48, -- 673
					width = playWidth, -- 673
					height = 40, -- 673
					text = zh and "立即试玩" or "Play now", -- 673
					primary = true, -- 673
					onTapped = function() -- 673
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 673
							return -- 673
						end -- 673
						blurInput() -- 673
						notifyProjectChanged() -- 673
						host.visible = false -- 673
						onPlay(options.entry) -- 673
					end -- 673
				} -- 673
			) -- 673
		else -- 673
			____temp_65 = nil -- 673
		end -- 673
		__TS__SparseArrayPush(____array_66, ____temp_65) -- 673
		__TS__SparseArrayPush( -- 673
			____array_68, -- 673
			____React_createElement_67(__TS__SparseArraySpread(____array_66)) -- 673
		) -- 673
		local scene = ____toNode_70(____React_createElement_69(__TS__SparseArraySpread(____array_68))) -- 550
		if scene then -- 550
			host:addChild(scene) -- 677
			if keptInput then -- 677
				keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom) -- 679
				keptInput.width = inputWidth -- 680
				keptInput.height = layoutComposerHeight -- 681
				local ____opt_71 = pageRef.current -- 681
				if ____opt_71 ~= nil then -- 681
					____opt_71:addChild(keptInput) -- 682
				end -- 682
			end -- 682
			if not questionnaire then -- 682
				transcript.node.position = Vec2( -- 685
					left + 16, -- 685
					bottom + getTranscriptBottom() -- 685
				) -- 685
				local ____opt_73 = pageRef.current -- 685
				if ____opt_73 ~= nil then -- 685
					____opt_73:addChild(transcript.node) -- 686
				end -- 686
				updateTranscript() -- 687
			end -- 687
		end -- 687
		if restoreInputFocus and inputRef.current and not keptInput then -- 687
			promptInput.focus(false) -- 690
		end -- 690
		if keptInput then -- 690
			promptInput.refresh() -- 691
		end -- 691
		shellRevision = getShellRevision() -- 692
		displayRevision = remixDisplayRevision(detail) -- 693
	end -- 421
	attachGamepad( -- 696
		host, -- 696
		{ -- 696
			initialTag = "remix-input", -- 697
			onBack = function() -- 698
				if promptInput.isFocused() then -- 698
					blurInput() -- 698
				else -- 698
					goBack() -- 698
				end -- 698
			end, -- 698
			onScroll = function(amount) return transcript:scrollBy(amount) end, -- 699
			onActivate = function(target) -- 700
				if target.tag == "remix-input" or target.tag == "remix-question-input" then -- 700
					target:emit("GamepadActivate") -- 701
				else -- 701
					if promptInput.isComposing() then -- 701
						blurInput() -- 703
						return -- 703
					end -- 703
					blurInput() -- 704
					dismissedComposition = false -- 705
					target:emit("Tapped") -- 706
				end -- 706
			end -- 700
		} -- 700
	) -- 700
	host:schedule(function(dt) -- 710
		pollElapsed = pollElapsed + dt -- 711
		if pollElapsed < 0.25 then -- 711
			return false -- 712
		end -- 712
		pollElapsed = 0 -- 713
		refresh() -- 714
		if swipeDragging or swipeBackPending then -- 714
			return false -- 715
		end -- 715
		if backNoticeUntil > 0 and App.runningTime >= backNoticeUntil then -- 715
			backNoticeUntil = 0 -- 717
			render() -- 718
			return false -- 719
		end -- 719
		local next = remixDisplayRevision(detail) -- 721
		if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then -- 721
			render() -- 722
		elseif displayRevision ~= next then -- 722
			updateTranscript() -- 723
		end -- 723
		return false -- 724
	end) -- 710
	host:onAppChange(function(setting) -- 726
		if setting == "Locale" then -- 726
			zh = (string.match(App.locale, "^zh")) ~= nil -- 727
		end -- 727
		if setting == "Size" or setting == "Locale" then -- 727
			render() -- 728
		end -- 728
	end) -- 726
	host:onAppEvent(function(event) -- 730
		if event == "BackButton" then -- 730
			if promptInput.isFocused() then -- 730
				blurInput() -- 731
			else -- 731
				goBack() -- 731
			end -- 731
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 731
			blurInput() -- 732
		end -- 732
	end) -- 730
	host:onCleanup(function() -- 734
		if packagePanel ~= nil then -- 734
			packagePanel:removeFromParent(true) -- 735
		end -- 735
		packagePanel = nil -- 736
		disposed = true -- 737
		blurInput() -- 737
	end) -- 734
	host:slot("SuspendLocalUI", blurInput) -- 739
	host:slot( -- 740
		"ResumeLocalUI", -- 740
		function() -- 740
			refresh() -- 740
			render() -- 740
		end -- 740
	) -- 740
	render() -- 741
	if needsLLMSetup then -- 741
		thread(function() -- 742
			sleep(0) -- 742
			if not disposed and host.parent then -- 742
				configureLLM() -- 742
			end -- 742
		end) -- 742
	end -- 742
	return host -- 743
end -- 118
return ____exports -- 118