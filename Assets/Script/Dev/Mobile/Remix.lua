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
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local DB = ____Dora.DB -- 2
local Director = ____Dora.Director -- 2
local Ease = ____Dora.Ease -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Label = ____Dora.Label -- 2
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
local resolveRemixThinkingStatus = ____RemixModel.resolveRemixThinkingStatus -- 7
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
local inputLength = ____TextInput.inputLength -- 13
local inputSlice = ____TextInput.inputSlice -- 13
local ____LLMSetup = require("Dev.Mobile.LLMSetup") -- 14
local startMobileLLMManager = ____LLMSetup.startMobileLLMManager -- 14
local ____Visual = require("Dev.Mobile.Visual") -- 15
local RoundedSurface = ____Visual.RoundedSurface -- 15
local VerticalGradient = ____Visual.VerticalGradient -- 15
local fontName = "sarasa-mono-sc-regular" -- 47
local colors = { -- 48
	background = 4278914322, -- 48
	panel = 4279704614, -- 48
	text = 4294242792, -- 48
	muted = 4289245117, -- 48
	brand = 4294954035, -- 48
	border = 4281613128, -- 48
	danger = 4294929259 -- 48
} -- 48
local composerGap = 12 -- 50
local composerBottom = 76 -- 51
local composerHeight = 60 -- 52
local composerActionWidth = 82 -- 53
local modeBottom = composerBottom + composerHeight + composerGap -- 54
local composerTop = modeBottom + 40 -- 55
local transcriptBottom = composerTop + composerGap -- 56
local statusHeight = 64 -- 57
local function ellipsizeSingleLine(text, width, fontSize) -- 59
	if text == "" then -- 59
		return "" -- 60
	end -- 60
	local measure = Label(fontName, fontSize, true) -- 61
	if not measure then -- 61
		return text -- 62
	end -- 62
	measure.visible = false -- 63
	measure.textWidth = -1 -- 64
	local function fits(value) -- 65
		measure.text = value -- 65
		return measure.width <= width -- 65
	end -- 65
	if fits(text) then -- 65
		measure:cleanup() -- 66
		return text -- 66
	end -- 66
	local low = 0 -- 67
	local high = inputLength(text) -- 67
	while low < high do -- 67
		local middle = math.floor((low + high + 1) / 2) -- 69
		if fits(inputSlice(text, 0, middle) .. "…") then -- 69
			low = middle -- 70
		else -- 70
			high = middle - 1 -- 71
		end -- 71
	end -- 71
	local result = inputSlice(text, 0, low) .. "…" -- 73
	measure:cleanup() -- 74
	return result -- 75
end -- 59
local function ActionButton(props) -- 78
	local height = props.height or 46 -- 79
	return React.createElement( -- 80
		"node", -- 80
		{ -- 80
			tag = props.tag, -- 80
			x = props.x, -- 80
			y = props.y, -- 80
			width = props.width, -- 80
			height = height, -- 80
			anchorX = 0, -- 80
			anchorY = 0, -- 80
			opacity = props.disabled and 0.45 or 1, -- 80
			touchEnabled = not props.disabled, -- 80
			swallowTouches = true, -- 80
			onTapped = props.onTapped -- 80
		}, -- 80
		React.createElement(RoundedSurface, { -- 80
			width = props.width, -- 80
			height = height, -- 80
			radius = 14, -- 80
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664), -- 80
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279704871), -- 80
			borderWidth = 1, -- 80
			borderColor = props.danger and colors.danger or (props.primary and 4294958435 or colors.border), -- 80
			shadow = props.primary or props.danger -- 80
		}), -- 80
		React.createElement("label", { -- 80
			x = props.width / 2, -- 80
			y = height / 2, -- 80
			fontName = fontName, -- 80
			fontSize = 15, -- 80
			text = props.text, -- 80
			color3 = props.primary and 1512202 or 16052712 -- 80
		}) -- 80
	) -- 80
end -- 78
local function ChoiceButton(props) -- 89
	local ____React_createElement_5 = React.createElement -- 89
	local ____temp_3 = { -- 89
		tag = props.tag, -- 89
		x = props.x, -- 89
		y = props.y, -- 89
		width = props.width, -- 89
		height = 40, -- 89
		anchorX = 0, -- 89
		anchorY = 0, -- 89
		opacity = props.disabled and 0.45 or 1, -- 89
		touchEnabled = not props.disabled, -- 89
		swallowTouches = true, -- 89
		onTapped = props.onTapped -- 89
	} -- 89
	local ____React_createElement_result_4 = React.createElement(RoundedSurface, { -- 89
		width = props.width, -- 89
		height = 40, -- 89
		radius = 12, -- 89
		topColor = props.selected and 4294958955 or 4280297526, -- 89
		bottomColor = props.selected and 4294950190 or 4279244061, -- 89
		borderWidth = 1, -- 89
		borderColor = props.selected and 4294958435 or colors.border -- 89
	}) -- 89
	local ____React_createElement_2 = React.createElement -- 89
	local ____array_1 = __TS__SparseArrayNew( -- 89
		"draw-node", -- 89
		{tag = props.tag and props.tag .. "-radio" or nil, x = 17, y = 20}, -- 89
		React.createElement("dot-shape", {radius = 7, color = props.selected and 4279702282 or 4289245117}), -- 89
		React.createElement("dot-shape", {radius = 5, color = props.selected and 4294954824 or 4279704614}) -- 89
	) -- 89
	local ____props_selected_0 -- 98
	if props.selected then -- 98
		____props_selected_0 = React.createElement( -- 98
			"draw-node", -- 98
			{tag = props.tag and props.tag .. "-radio-dot" or nil}, -- 98
			React.createElement("dot-shape", {radius = 2.5, color = 4279702282}) -- 98
		) -- 98
	else -- 98
		____props_selected_0 = nil -- 98
	end -- 98
	__TS__SparseArrayPush(____array_1, ____props_selected_0) -- 98
	return ____React_createElement_5( -- 90
		"node", -- 90
		____temp_3, -- 90
		____React_createElement_result_4, -- 90
		____React_createElement_2(__TS__SparseArraySpread(____array_1)), -- 90
		React.createElement("label", { -- 90
			x = 32, -- 90
			y = 20, -- 90
			anchorX = 0, -- 90
			fontName = fontName, -- 90
			fontSize = 14, -- 90
			text = props.text, -- 90
			textWidth = props.width - 44, -- 90
			alignment = "Left", -- 90
			color3 = props.selected and 1512202 or 16052712 -- 90
		}) -- 90
	) -- 90
end -- 89
function ____exports.startMobileRemix(options) -- 104
	local host, send, getTranscriptActions, render -- 104
	local onBack = options.onBack -- 105
	local onPlay = options.onPlay -- 106
	local services = options.services or ({ -- 107
		createSession = AgentSession.createSession, -- 108
		getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end, -- 109
		setWorkMode = AgentSession.setWorkMode, -- 110
		sendPrompt = AgentSession.sendPrompt, -- 111
		respondQuestionnaire = AgentSession.respondQuestionnaire, -- 112
		stopSessionTask = AgentSession.stopSessionTask, -- 113
		continuePrompt = AgentSession.continuePrompt, -- 114
		getActiveLLMConfig = getActiveLLMConfig, -- 115
		getLLMConfig = getLLMConfig, -- 116
		getLLMConfigSummaries = getLLMConfigSummaries -- 117
	}) -- 117
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 119
	local projectRoot = options.entry.workDir or "" -- 120
	local created = services.createSession(projectRoot, options.entry.title) -- 121
	local sessionId = created.success and created.session.id or 0 -- 122
	local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message}) -- 123
	local draft = "" -- 126
	local ____error = created.success and "" or created.message -- 127
	local pollElapsed = 0 -- 128
	local stopRequested = false -- 129
	local selectedLLMConfigId = 0 -- 130
	local questionnaireId = 0 -- 131
	local questionIndex = 0 -- 132
	local llmConfigs = services.getLLMConfigSummaries() -- 133
	local taskLLMConfigId = 0 -- 134
	local needsLLMSetup = false -- 135
	local questionnaireSelections = {} -- 136
	local questionnaireTexts = {} -- 137
	local inputRef = reference() -- 138
	local disposed = false -- 139
	local dismissedComposition = false -- 140
	local swipeBackPending = false -- 141
	local swipeDragging = false -- 142
	local swipeRevision = 0 -- 143
	local projectChangeNotified = false -- 144
	local function currentQuestion() -- 145
		local ____detail_success_8 -- 145
		if detail.success then -- 145
			local ____opt_6 = detail.pendingQuestionnaire -- 145
			____detail_success_8 = ____opt_6 and ____opt_6.schema.questions[questionIndex + 1] -- 145
		else -- 145
			____detail_success_8 = nil -- 145
		end -- 145
		return ____detail_success_8 -- 145
	end -- 145
	local promptInput = createTextInput({ -- 146
		fontSize = math.floor(16 * mobileFontScale), -- 147
		getText = function() -- 148
			local question = currentQuestion() -- 148
			return question and (questionnaireTexts[question.id] or "") or draft -- 148
		end, -- 148
		setText = function(text) -- 149
			local question = currentQuestion() -- 149
			if question then -- 149
				questionnaireTexts[question.id] = text -- 149
			else -- 149
				draft = text -- 149
			end -- 149
		end, -- 149
		getPlaceholder = function() -- 150
			local question = currentQuestion() -- 151
			return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…")) -- 152
		end, -- 150
		isEnabled = function() return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end, -- 154
		onReturn = function(modified) -- 155
			if modified and not currentQuestion() then -- 155
				send() -- 155
				return true -- 155
			end -- 155
			return false -- 155
		end -- 155
	}) -- 155
	local blurInput = promptInput.blur -- 157
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 158
	local ____temp_11 -- 159
	if rememberedRows and #rememberedRows > 0 then -- 159
		____temp_11 = tonumber(rememberedRows[1][1]) -- 159
	else -- 159
		____temp_11 = nil -- 159
	end -- 159
	local rememberedId = ____temp_11 -- 159
	if rememberedId and __TS__ArraySome( -- 159
		llmConfigs, -- 160
		function(____, item) return item.id == rememberedId end -- 160
	) then -- 160
		selectedLLMConfigId = rememberedId -- 160
	elseif #llmConfigs > 0 then -- 160
		selectedLLMConfigId = llmConfigs[1].id -- 161
	else -- 161
		local activeConfig = services.getActiveLLMConfig() -- 163
		if activeConfig.success then -- 163
			selectedLLMConfigId = activeConfig.id -- 164
		else -- 164
			needsLLMSetup = true -- 165
		end -- 165
	end -- 165
	host = Node() -- 168
	host.tag = "mobile-remix" -- 169
	host.scaleX = App.devicePixelRatio -- 170
	host.scaleY = App.devicePixelRatio -- 171
	host:addTo(Director.systemUI) -- 172
	local transcript = createRemixTranscript() -- 173
	local displayRevision = "" -- 174
	local shellRevision = "" -- 175
	local inputLayout = "" -- 176
	local mascotAnimationState -- 177
	local mascotAnimationStartedAt = App.runningTime -- 178
	local compactHeaderStatusActive = false -- 179
	local errorLabel -- 180
	local layoutTranscriptBottom = transcriptBottom -- 181
	local function getLayoutArea() -- 182
		return App.safeArea -- 182
	end -- 182
	local function getTranscriptBottom() -- 183
		return layoutTranscriptBottom + (errorLabel and errorLabel.height + composerGap or 0) -- 183
	end -- 183
	local function hasTranscriptContent() -- 184
		return detail.success and (#detail.messages > 0 or #detail.steps > 0) -- 184
	end -- 184
	local function getHeaderY(safe) -- 185
		local landscapeTopLift = safe.width >= 760 and safe.height < 500 and 28 or 0 -- 186
		return safe.y + safe.height - 56 + landscapeTopLift -- 187
	end -- 185
	local function useCompactHeaderStatus(safe) -- 189
		return safe.width >= 760 and safe.height < 500 and hasTranscriptContent() -- 189
	end -- 189
	local function useCompactStandaloneStatus(safe) -- 190
		return safe.height >= 500 and hasTranscriptContent() -- 190
	end -- 190
	local function getTranscriptHeight(safe) -- 191
		local statusInset = useCompactHeaderStatus(safe) and composerGap or statusHeight + composerGap * 2 - (useCompactStandaloneStatus(safe) and 24 or 0) -- 192
		local available = math.max( -- 194
			40, -- 194
			getHeaderY(safe) - safe.y - getTranscriptBottom() - statusInset -- 194
		) -- 194
		return safe.width >= 760 and safe.height < 500 and not hasTranscriptContent() and 8 or available -- 195
	end -- 191
	local function getShellRevision() -- 197
		local ____detail_success_15 -- 197
		if detail.success then -- 197
			local ____safeJsonEncode_14 = safeJsonEncode -- 197
			local ____array_13 = __TS__SparseArrayNew( -- 197
				detail.session.status, -- 198
				detail.session.workMode, -- 198
				detail.hasActivePlan, -- 198
				detail.pendingQuestionnaire or false, -- 198
				detail.session.currentTaskStatus or "" -- 199
			) -- 199
			local ____detail_session_currentTaskFinalizing_12 = detail.session.currentTaskFinalizing -- 199
			if ____detail_session_currentTaskFinalizing_12 == nil then -- 199
				____detail_session_currentTaskFinalizing_12 = false -- 199
			end -- 199
			__TS__SparseArrayPush( -- 199
				____array_13, -- 199
				____detail_session_currentTaskFinalizing_12, -- 199
				stopRequested, -- 199
				hasTranscriptContent(), -- 199
				resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or "" -- 200
			) -- 200
			____detail_success_15 = (____safeJsonEncode_14({__TS__SparseArraySpread(____array_13)})) or "" -- 197
		else -- 197
			____detail_success_15 = detail.message -- 201
		end -- 201
		return ____detail_success_15 -- 197
	end -- 197
	local function updateTranscript() -- 202
		local safe = getLayoutArea() -- 203
		transcript:update( -- 204
			detail, -- 204
			math.max(60, safe.width - 32), -- 204
			getTranscriptHeight(safe), -- 204
			mobileFontScale, -- 204
			zh, -- 204
			getTranscriptActions() -- 204
		) -- 204
		displayRevision = remixDisplayRevision(detail) -- 205
	end -- 202
	local function hasActiveTask() -- 208
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil) -- 208
	end -- 208
	local function notifyProjectChanged() -- 211
		if projectChangeNotified or not detail.success or not options.onProjectChanged then -- 211
			return -- 212
		end -- 212
		if not __TS__ArraySome( -- 212
			detail.steps, -- 213
			function(____, step) return step.files ~= nil and #step.files > 0 end -- 213
		) then -- 213
			return -- 213
		end -- 213
		projectChangeNotified = true -- 214
		options.onProjectChanged(options.entry) -- 215
	end -- 211
	local function refresh() -- 217
		if sessionId > 0 then -- 217
			detail = services.getSession(sessionId) -- 218
		end -- 218
		if detail.success and not hasActiveTask() then -- 218
			stopRequested = false -- 219
		end -- 219
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then -- 219
			questionnaireId = detail.pendingQuestionnaire.id -- 221
			questionIndex = 0 -- 222
		end -- 222
	end -- 217
	local function canSubmit() -- 225
		return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire -- 225
	end -- 225
	local function resolveLLMConfig() -- 228
		return selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig() -- 228
	end -- 228
	local function configureLLM() -- 229
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 229
			return -- 230
		end -- 230
		blurInput() -- 231
		startMobileLLMManager({ -- 232
			coveredNode = host, -- 233
			selectedId = selectedLLMConfigId, -- 234
			taskRunning = hasActiveTask(), -- 235
			runningId = taskLLMConfigId, -- 236
			onSelected = function(id) -- 237
				if disposed or not host.parent then -- 237
					return -- 238
				end -- 238
				llmConfigs = services.getLLMConfigSummaries() -- 239
				selectedLLMConfigId = id -- 240
				needsLLMSetup = #llmConfigs == 0 -- 241
				____error = "" -- 242
				render() -- 243
			end, -- 237
			onClose = function() -- 245
				if not disposed and host.parent then -- 245
					render() -- 245
				end -- 245
			end -- 245
		}) -- 245
	end -- 229
	local function changeWorkMode(workMode) -- 248
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 248
			return -- 249
		end -- 249
		refresh() -- 250
		if not canSubmit() or not detail.success then -- 250
			return -- 251
		end -- 251
		if resolveRemixWorkMode(detail.session) == workMode then -- 251
			return -- 252
		end -- 252
		local result = services.setWorkMode(sessionId, workMode) -- 253
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode")) -- 254
		refresh() -- 255
		render() -- 256
	end -- 248
	send = function() -- 258
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 258
			return -- 259
		end -- 259
		refresh() -- 260
		if not canSubmit() or not detail.success or promptInput.isComposing() then -- 260
			return -- 261
		end -- 261
		local workMode = resolveRemixWorkMode(detail.session) -- 262
		local text = (string.match(draft, "^%s*(.-)%s*$")) or "" -- 265
		if sessionId <= 0 or text == "" then -- 265
			return -- 266
		end -- 266
		local config = resolveLLMConfig() -- 267
		if not config.success then -- 267
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 269
			render() -- 270
			configureLLM() -- 271
			return -- 272
		end -- 272
		selectedLLMConfigId = config.id -- 274
		local result = services.sendPrompt( -- 275
			sessionId, -- 275
			text, -- 275
			nil, -- 275
			workMode, -- 275
			config.id, -- 275
			config.config -- 275
		) -- 275
		if not result.success then -- 275
			____error = result.message -- 276
		else -- 276
			taskLLMConfigId = config.id -- 277
			draft = "" -- 277
			____error = "" -- 277
		end -- 277
		refresh() -- 278
		render() -- 279
	end -- 258
	local function continueTask() -- 281
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 281
			return -- 282
		end -- 282
		refresh() -- 283
		if not detail.success or hasActiveTask() or detail.session.currentTaskStatus ~= "FAILED" and detail.session.currentTaskStatus ~= "STOPPED" or detail.session.currentTaskId == nil then -- 283
			return -- 285
		end -- 285
		local config = resolveLLMConfig() -- 286
		if not config.success then -- 286
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 288
			render() -- 289
			configureLLM() -- 290
			return -- 291
		end -- 291
		if not services.continuePrompt then -- 291
			____error = zh and "当前版本不支持继续会话" or "Continuing this session is unavailable" -- 294
			render() -- 295
			return -- 296
		end -- 296
		selectedLLMConfigId = config.id -- 298
		local result = services.continuePrompt(sessionId, nil, config.id) -- 299
		____error = result.success and "" or result.message -- 300
		if result.success then -- 300
			taskLLMConfigId = config.id -- 301
			stopRequested = false -- 301
		end -- 301
		refresh() -- 302
		render() -- 303
	end -- 281
	local function startDevelopment() -- 305
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 305
			return -- 306
		end -- 306
		refresh() -- 307
		if not detail.success or hasActiveTask() or detail.session.workMode ~= "plan" or not detail.hasActivePlan then -- 307
			return -- 308
		end -- 308
		local modeResult = services.setWorkMode(sessionId, "code") -- 309
		if not modeResult.success then -- 309
			____error = modeResult.message or (zh and "切换执行模式失败" or "Could not switch to Code mode") -- 311
			render() -- 312
			return -- 313
		end -- 313
		local config = resolveLLMConfig() -- 315
		if not config.success then -- 315
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 317
			refresh() -- 318
			render() -- 319
			configureLLM() -- 320
			return -- 321
		end -- 321
		selectedLLMConfigId = config.id -- 323
		local prompt = zh and "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。" or "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated." -- 324
		local result = services.sendPrompt( -- 327
			sessionId, -- 327
			prompt, -- 327
			nil, -- 327
			"code", -- 327
			config.id, -- 327
			config.config -- 327
		) -- 327
		____error = result.success and "" or result.message -- 328
		if result.success then -- 328
			taskLLMConfigId = config.id -- 329
		end -- 329
		refresh() -- 330
		render() -- 331
	end -- 305
	getTranscriptActions = function() -- 333
		if not detail.success or not hasTranscriptContent() or hasActiveTask() or __TS__ArrayEvery( -- 333
			detail.messages, -- 334
			function(____, message) return message.role ~= "assistant" end -- 334
		) then -- 334
			return {} -- 334
		end -- 334
		local actions = {} -- 335
		if (detail.session.currentTaskStatus == "FAILED" or detail.session.currentTaskStatus == "STOPPED") and detail.session.currentTaskId ~= nil then -- 335
			actions[#actions + 1] = {id = "continue", text = zh and "继续" or "Continue", onTapped = continueTask} -- 337
		end -- 337
		if detail.session.kind == "main" and detail.session.workMode == "plan" and detail.hasActivePlan then -- 337
			actions[#actions + 1] = {id = "start-development", text = zh and "开始开发" or "Start development", primary = true, onTapped = startDevelopment} -- 339
		end -- 339
		return actions -- 340
	end -- 333
	local function stop() -- 342
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 342
			return -- 343
		end -- 343
		refresh() -- 344
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then -- 344
			return -- 346
		end -- 346
		local result = services.stopSessionTask(sessionId) -- 347
		if (result and result.success) == false then -- 347
			____error = result.message or (zh and "停止失败" or "Could not stop") -- 348
		else -- 348
			stopRequested = true -- 349
			____error = "" -- 349
		end -- 349
		refresh() -- 350
		render() -- 351
	end -- 342
	local function advanceQuestionnaire() -- 353
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 353
			return -- 354
		end -- 354
		if not detail.success or not detail.pendingQuestionnaire then -- 354
			return -- 355
		end -- 355
		local pending = detail.pendingQuestionnaire -- 356
		local questions = pending.schema.questions -- 357
		local question = questions[questionIndex + 1] -- 358
		if not question then -- 358
			return -- 359
		end -- 359
		local selected = questionnaireSelections[question.id] or ({}) -- 360
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "") -- 361
		if not isQuestionAnswered(question, selected, text) then -- 361
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 363
			render() -- 364
			return -- 365
		end -- 365
		if questionIndex + 1 < #questions then -- 365
			questionIndex = questionIndex + 1 -- 368
			____error = "" -- 369
			render() -- 370
			return -- 371
		end -- 371
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 373
		if selectedLLMConfigId <= 0 then -- 373
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 375
			render() -- 376
			return -- 377
		end -- 377
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 379
		if not result.success then -- 379
			____error = result.message -- 380
		else -- 380
			taskLLMConfigId = selectedLLMConfigId -- 381
			____error = "" -- 381
		end -- 381
		refresh() -- 382
		render() -- 383
	end -- 353
	local function goBack() -- 385
		if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 385
			return -- 386
		end -- 386
		if detail.success and not canLeaveRemix(detail.session.status) then -- 386
			____error = zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back" -- 388
			render() -- 389
			return -- 390
		end -- 390
		blurInput() -- 392
		notifyProjectChanged() -- 393
		host.visible = false -- 394
		host:removeFromParent(true) -- 395
		onBack() -- 396
	end -- 385
	render = function() -- 399
		errorLabel = nil -- 400
		swipeRevision = swipeRevision + 1 -- 402
		swipeDragging = false -- 403
		swipeBackPending = false -- 404
		local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height) -- 405
		local ____temp_20 = layout == inputLayout and not (detail.success and detail.pendingQuestionnaire) -- 407
		if ____temp_20 then -- 407
			local ____opt_18 = inputRef.current -- 407
			____temp_20 = (____opt_18 and ____opt_18.tag) == "remix-input" -- 407
		end -- 407
		local keptInput = ____temp_20 and inputRef.current or nil -- 407
		if keptInput ~= nil then -- 407
			keptInput:removeFromParent(false) -- 409
		end -- 409
		transcript.node:removeFromParent(false) -- 410
		local restoreInputFocus = promptInput.isFocused() -- 411
		if not keptInput then -- 411
			promptInput.unmount() -- 413
			inputRef = reference() -- 414
		end -- 414
		host:removeAllChildren() -- 416
		inputLayout = layout -- 417
		host.scaleX = App.devicePixelRatio -- 418
		host.scaleY = App.devicePixelRatio -- 419
		local ____App_visualSize_23 = App.visualSize -- 420
		local width = ____App_visualSize_23.width -- 420
		local height = ____App_visualSize_23.height -- 420
		local safe = getLayoutArea() -- 421
		local left = safe.x -- 422
		local bottom = safe.y -- 423
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 424
		local state = detail.success and detail.session or nil -- 425
		local workMode = resolveRemixWorkMode(state) -- 426
		local stopping = hasActiveTask() -- 427
		local ____detail_success_24 -- 428
		if detail.success then -- 428
			____detail_success_24 = detail.hasActivePlan -- 428
		else -- 428
			____detail_success_24 = false -- 428
		end -- 428
		local hasActivePlan = ____detail_success_24 -- 428
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 429
		local layoutComposerBottom = 24 -- 430
		local layoutComposerHeight = composerHeight -- 431
		local layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap -- 432
		local layoutComposerTop = layoutModeBottom + 40 -- 433
		layoutTranscriptBottom = layoutComposerTop + composerGap -- 434
		local contentWidth = safe.width - 32 -- 435
		local inputWidth = contentWidth - composerActionWidth - composerGap -- 436
		local inlinePlay = phase == "done" -- 437
		local modeWidth = inlinePlay and (shortLandscape and math.min( -- 438
			170, -- 439
			math.floor((contentWidth - composerGap * 2 - 120) / 2) -- 439
		) or math.floor((contentWidth - composerGap * 2) / 3)) or math.floor((contentWidth - composerGap) / 2) -- 439
		local modeStartX = left + 16 -- 441
		local modeCodeWidth = inlinePlay and shortLandscape and modeWidth or (inlinePlay and math.floor((contentWidth - composerGap * 2) / 3) or contentWidth - modeWidth - composerGap) -- 442
		local playWidth = inlinePlay and contentWidth - modeWidth - modeCodeWidth - composerGap * 2 or 0 -- 445
		local playX = modeStartX + modeWidth + composerGap + modeCodeWidth + composerGap -- 446
		local ____detail_success_25 -- 447
		if detail.success then -- 447
			____detail_success_25 = detail.pendingQuestionnaire -- 447
		else -- 447
			____detail_success_25 = nil -- 447
		end -- 447
		local questionnaire = ____detail_success_25 -- 447
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 448
		local fontScale = mobileFontScale -- 449
		local headerY = getHeaderY(safe) -- 450
		local compactHeaderStatus = useCompactHeaderStatus(safe) -- 451
		compactHeaderStatusActive = compactHeaderStatus -- 452
		local headerStatusWidth = 168 -- 453
		local modelButtonWidth = shortLandscape and 92 or 72 -- 454
		local headerSettingsX = left + safe.width - 104 - modelButtonWidth -- 455
		local headerStatusX = headerSettingsX - 8 - headerStatusWidth -- 456
		local headerTitleWidth = compactHeaderStatus and math.max(120, headerStatusX - (left + 16) - composerGap) or math.max(120, headerSettingsX - (left + 16) - composerGap) -- 457
		local selectedConfig = __TS__ArrayFind( -- 460
			llmConfigs, -- 460
			function(____, item) return item.id == selectedLLMConfigId end -- 460
		) -- 460
		local switchPending = hasActiveTask() and taskLLMConfigId > 0 and taskLLMConfigId ~= selectedLLMConfigId -- 461
		local modelName = selectedConfig and selectedConfig.name or (zh and "配置 AI" or "Set up AI") -- 462
		local modelNameLimit = shortLandscape and 10 or 6 -- 463
		local shortModelName = inputLength(modelName) > modelNameLimit and inputSlice(modelName, 0, modelNameLimit) .. "…" or modelName -- 464
		local modelLabel = ellipsizeSingleLine((switchPending and (zh and "下一轮·" or "Next·") or "") .. shortModelName, modelButtonWidth - 14, 11) -- 465
		local thinkingText = resolveRemixThinkingStatus(detail.success and detail.steps or ({}), state and state.currentTaskId) -- 466
		local statusText = thinkingText ~= nil and (zh and "正在思考" or "Thinking") or (phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game"))))))) -- 467
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 474
		if mascotAnimationState ~= mascotState then -- 474
			mascotAnimationState = mascotState -- 481
			mascotAnimationStartedAt = App.runningTime -- 482
		end -- 482
		local emptyLandscape = shortLandscape and not hasTranscriptContent() -- 484
		local emptyStatusBottom = bottom + layoutModeBottom + 40 + composerGap -- 485
		local emptyStatusTop = headerY - composerGap - statusHeight -- 486
		local messageTop = emptyLandscape and (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2 or headerY - composerGap - statusHeight / 2 -- 487
		local mascotSize = shortLandscape and 42 or 52 -- 490
		local compactStandaloneStatus = useCompactStandaloneStatus(safe) -- 491
		local standaloneStatusContentLift = shortLandscape and 0 or (compactStandaloneStatus and 26 or 14) -- 492
		local mascotX = shortLandscape and left + 40 or left + 66 -- 493
		local statusTextX = shortLandscape and left + 76 or left + 104 -- 494
		local statusTextWidth = shortLandscape and math.max(120, left + 16 + contentWidth - statusTextX) or contentWidth - 84 -- 495
		local renderedStatusX = compactHeaderStatus and 36 or statusTextX -- 496
		local renderedStatusY = compactHeaderStatus and 22 or statusHeight / 2 + standaloneStatusContentLift -- 497
		local renderedStatusWidth = compactHeaderStatus and headerStatusWidth - 36 or statusTextWidth -- 498
		local thinkingFontSize = compactHeaderStatus and math.floor(10 * fontScale) or math.floor(12 * fontScale) -- 499
		local thinkingRightPadding = compactHeaderStatus and 8 or 20 -- 500
		local renderedThinkingText = thinkingText == nil and "" or ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize) -- 501
		local swipeStart = Vec2.zero -- 502
		local swipeAxis = "none" -- 503
		local pageRef = reference() -- 504
		local hitsTranscriptButton -- 505
		hitsTranscriptButton = function(node, world) -- 505
			if not node.visible then -- 505
				return false -- 506
			end -- 506
			if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then -- 506
				local p = node:convertToNodeSpace(world) -- 508
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 508
					return true -- 509
				end -- 509
			end -- 509
			local hit = false -- 511
			node:eachChild(function(child) -- 512
				hit = hitsTranscriptButton(child, world) -- 512
				return hit -- 512
			end) -- 512
			return hit -- 513
		end -- 505
		local ____toNode_68 = toNode -- 515
		local ____React_createElement_67 = React.createElement -- 515
		local ____array_66 = __TS__SparseArrayNew( -- 515
			"node", -- 515
			{ -- 515
				tag = "remix-scene", -- 515
				x = -width / 2, -- 515
				y = -height / 2, -- 515
				width = width, -- 515
				height = height, -- 515
				anchorX = 0, -- 515
				anchorY = 0 -- 515
			}, -- 515
			React.createElement( -- 515
				"node", -- 515
				{ -- 515
					tag = "remix-focus-observer", -- 515
					order = 1000, -- 515
					width = width, -- 515
					height = height, -- 515
					anchorX = 0, -- 515
					anchorY = 0, -- 515
					touchEnabled = true, -- 515
					swallowTouches = false, -- 515
					swallowMouseWheel = false, -- 515
					onTapFilter = function(touch) -- 515
						touch.enabled = false -- 519
						if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 519
							return -- 520
						end -- 520
						local input = inputRef.current -- 521
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 522
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 523
						dismissedComposition = not inside and promptInput.isComposing() -- 524
						if not inside then -- 524
							blurInput() -- 525
						end -- 525
						if not inside and not questionnaire and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 525
							touch.enabled = true -- 530
						end -- 530
					end, -- 518
					onTapBegan = function(touch) -- 518
						swipeStart = touch.location -- 534
						swipeAxis = "none" -- 534
						swipeDragging = true -- 534
						local ____opt_34 = pageRef.current -- 534
						if ____opt_34 ~= nil then -- 534
							____opt_34:stopAllActions() -- 535
						end -- 535
					end, -- 533
					onTapMoved = function(touch) -- 533
						local delta = touch.location:sub(swipeStart) -- 538
						if swipeAxis == "none" and math.max( -- 538
							math.abs(delta.x), -- 539
							math.abs(delta.y) -- 539
						) >= 12 then -- 539
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 540
						end -- 540
						if pageRef.current then -- 540
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 542
						end -- 542
					end, -- 537
					onTapEnded = function(touch) -- 537
						local delta = touch.location:sub(swipeStart) -- 545
						swipeDragging = false -- 546
						if swipeBackPending then -- 546
							return -- 547
						end -- 547
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 548
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 549
						local page = pageRef.current -- 550
						if not page or not requested and page.x == 0 then -- 550
							return -- 551
						end -- 551
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 552
						local revision = swipeRevision -- 553
						swipeBackPending = true -- 554
						if not leaving then -- 554
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 556
						end -- 556
						thread(function() -- 558
							sleep(duration) -- 559
							if disposed or revision ~= swipeRevision or not host.parent then -- 559
								return -- 560
							end -- 560
							swipeBackPending = false -- 561
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 561
								refresh() -- 562
								goBack() -- 562
							else -- 562
								page.position = Vec2.zero -- 563
							end -- 563
						end) -- 558
					end -- 544
				} -- 544
			), -- 544
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943}) -- 544
		) -- 544
		local ____React_createElement_65 = React.createElement -- 544
		local ____array_64 = __TS__SparseArrayNew( -- 544
			"node", -- 544
			{tag = "remix-page", ref = pageRef}, -- 544
			React.createElement( -- 544
				"clip-node", -- 544
				{ -- 544
					x = left + 16, -- 544
					y = headerY, -- 544
					width = headerTitleWidth, -- 544
					height = 44, -- 544
					anchorX = 0, -- 544
					anchorY = 0, -- 544
					stencil = React.createElement( -- 544
						"draw-node", -- 544
						{x = headerTitleWidth / 2, y = 22}, -- 544
						React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295}) -- 544
					) -- 544
				}, -- 544
				React.createElement("label", { -- 544
					tag = "remix-title", -- 544
					x = 0, -- 544
					y = 22, -- 544
					anchorX = 0, -- 544
					fontName = fontName, -- 544
					fontSize = 20, -- 544
					text = "REMIX · " .. options.entry.title, -- 544
					color3 = 16052712 -- 544
				}) -- 544
			), -- 544
			React.createElement( -- 544
				"node", -- 544
				{ -- 544
					tag = "remix-back", -- 544
					x = left + safe.width - 96, -- 544
					y = headerY, -- 544
					width = 80, -- 544
					height = 44, -- 544
					anchorX = 0, -- 544
					anchorY = 0, -- 544
					touchEnabled = true, -- 544
					swallowTouches = true, -- 544
					onTapped = goBack -- 544
				}, -- 544
				React.createElement("label", { -- 544
					x = 80, -- 544
					y = 22, -- 544
					anchorX = 1, -- 544
					fontName = fontName, -- 544
					fontSize = 18, -- 544
					text = zh and "返回 ›" or "Back ›", -- 544
					color3 = 16763955 -- 544
				}) -- 544
			) -- 544
		) -- 544
		local ____React_createElement_38 = React.createElement -- 544
		local ____array_37 = __TS__SparseArrayNew( -- 544
			"node", -- 544
			{ -- 544
				tag = "remix-model-config", -- 544
				x = headerSettingsX, -- 544
				y = headerY + 6, -- 544
				width = modelButtonWidth, -- 544
				height = 32, -- 544
				anchorX = 0, -- 544
				anchorY = 0, -- 544
				touchEnabled = true, -- 544
				swallowTouches = true, -- 544
				onTapped = configureLLM -- 544
			}, -- 544
			React.createElement(RoundedSurface, { -- 544
				width = modelButtonWidth, -- 544
				height = 32, -- 544
				radius = 16, -- 544
				topColor = 858534978, -- 544
				bottomColor = 856824097, -- 544
				borderWidth = 1, -- 544
				borderColor = needsLLMSetup and colors.brand or colors.border -- 544
			}), -- 544
			React.createElement("label", { -- 544
				x = modelButtonWidth / 2, -- 544
				y = 16, -- 544
				fontName = fontName, -- 544
				fontSize = 11, -- 544
				text = modelLabel, -- 544
				color3 = (needsLLMSetup or switchPending) and 16763955 or 11055037 -- 544
			}) -- 544
		) -- 544
		local ____needsLLMSetup_36 -- 581
		if needsLLMSetup then -- 581
			____needsLLMSetup_36 = React.createElement( -- 581
				"draw-node", -- 581
				{x = modelButtonWidth - 4, y = 28}, -- 581
				React.createElement("dot-shape", {radius = 3, color = 4294954035}) -- 581
			) -- 581
		else -- 581
			____needsLLMSetup_36 = nil -- 581
		end -- 581
		__TS__SparseArrayPush(____array_37, ____needsLLMSetup_36) -- 581
		__TS__SparseArrayPush( -- 581
			____array_64, -- 581
			____React_createElement_38(__TS__SparseArraySpread(____array_37)), -- 581
			React.createElement( -- 581
				"node", -- 581
				{ -- 581
					tag = "remix-status", -- 581
					x = compactHeaderStatus and headerStatusX or 0, -- 581
					y = compactHeaderStatus and headerY or messageTop - statusHeight / 2, -- 581
					width = compactHeaderStatus and headerStatusWidth or width, -- 581
					height = compactHeaderStatus and 44 or statusHeight, -- 581
					anchorX = 0, -- 581
					anchorY = 0 -- 581
				}, -- 581
				React.createElement(DoraMascot, { -- 581
					state = mascotState, -- 581
					x = compactHeaderStatus and 16 or mascotX, -- 581
					y = compactHeaderStatus and 20 or statusHeight / 2 - 2 + standaloneStatusContentLift, -- 581
					size = compactHeaderStatus and 30 or mascotSize, -- 581
					animationStartedAt = mascotAnimationStartedAt -- 581
				}), -- 581
				React.createElement( -- 581
					"clip-node", -- 581
					{ -- 581
						tag = "remix-status-clip", -- 581
						x = renderedStatusX, -- 581
						y = renderedStatusY - 22, -- 581
						width = renderedStatusWidth, -- 581
						height = 44, -- 581
						anchorX = 0, -- 581
						anchorY = 0, -- 581
						stencil = React.createElement( -- 581
							"draw-node", -- 581
							{x = renderedStatusWidth / 2, y = 22}, -- 581
							React.createElement("rect-shape", {width = renderedStatusWidth, height = 44, fillColor = 4294967295}) -- 581
						) -- 581
					}, -- 581
					React.createElement( -- 581
						"label", -- 581
						{ -- 581
							tag = "remix-status-text", -- 581
							x = 0, -- 581
							y = 22, -- 581
							anchorX = 0, -- 581
							fontName = fontName, -- 581
							fontSize = compactHeaderStatus and math.floor(13 * fontScale) or math.floor(15 * fontScale), -- 581
							text = statusText, -- 581
							textWidth = -1, -- 581
							alignment = "Left", -- 581
							color3 = phase == "failed" and 16739179 or 16763955 -- 581
						} -- 581
					), -- 581
					React.createElement("label", { -- 581
						tag = "remix-thinking-text", -- 581
						x = 0, -- 581
						y = 6, -- 581
						anchorX = 0, -- 581
						fontName = fontName, -- 581
						fontSize = thinkingFontSize, -- 581
						text = renderedThinkingText, -- 581
						textWidth = -1, -- 581
						alignment = "Left", -- 581
						color3 = colors.muted -- 581
					}) -- 581
				) -- 581
			) -- 581
		) -- 581
		local ____temp_46 -- 597
		if questionnaire and question then -- 597
			local ____React_createElement_45 = React.createElement -- 597
			local ____array_44 = __TS__SparseArrayNew( -- 597
				"node", -- 597
				{ -- 597
					tag = "remix-questionnaire", -- 597
					x = left + 16, -- 597
					y = bottom + 164, -- 597
					width = contentWidth, -- 597
					height = safe.height - 330, -- 597
					anchorX = 0, -- 597
					anchorY = 0 -- 597
				}, -- 597
				React.createElement(RoundedSurface, { -- 597
					width = contentWidth, -- 597
					height = safe.height - 330, -- 597
					radius = 20, -- 597
					topColor = 4280429370, -- 597
					bottomColor = 4279375648, -- 597
					borderWidth = 1, -- 597
					borderColor = 4282469213, -- 597
					shadow = true -- 597
				}), -- 597
				React.createElement( -- 597
					"label", -- 597
					{ -- 597
						x = 16, -- 597
						y = safe.height - 360, -- 597
						anchorX = 0, -- 597
						fontName = fontName, -- 597
						fontSize = 13, -- 597
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 597
						textWidth = contentWidth - 32, -- 597
						alignment = "Left", -- 597
						color3 = 16763955 -- 597
					} -- 597
				), -- 597
				React.createElement("label", { -- 597
					x = 16, -- 597
					y = safe.height - 405, -- 597
					anchorX = 0, -- 597
					fontName = fontName, -- 597
					fontSize = 16, -- 597
					text = question.prompt, -- 597
					textWidth = contentWidth - 32, -- 597
					alignment = "Left", -- 597
					color3 = 16052712 -- 597
				}), -- 597
				question.type ~= "text" and __TS__ArrayMap( -- 601
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 601
					function(____, option, optionIndex) return React.createElement( -- 601
						ChoiceButton, -- 601
						{ -- 601
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 601
							x = 16, -- 601
							y = safe.height - 460 - optionIndex * 43, -- 601
							width = contentWidth - 32, -- 601
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 601
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 601
							onTapped = function() -- 601
								local selected = questionnaireSelections[question.id] or ({}) -- 607
								local ____question_id_42 = question.id -- 608
								local ____temp_41 -- 608
								if question.type == "single_choice" then -- 608
									____temp_41 = {option.id} -- 609
								else -- 609
									local ____temp_40 -- 610
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 610
										____temp_40 = __TS__ArrayFilter( -- 610
											selected, -- 610
											function(____, id) return id ~= option.id end -- 610
										) -- 610
									else -- 610
										local ____array_39 = __TS__SparseArrayNew(table.unpack(selected)) -- 610
										__TS__SparseArrayPush(____array_39, option.id) -- 610
										____temp_40 = {__TS__SparseArraySpread(____array_39)} -- 610
									end -- 610
									____temp_41 = ____temp_40 -- 610
								end -- 610
								questionnaireSelections[____question_id_42] = ____temp_41 -- 608
								render() -- 611
							end -- 606
						} -- 606
					) end -- 606
				) or React.createElement("node", { -- 606
					tag = "remix-question-input", -- 606
					ref = inputRef, -- 606
					x = 16, -- 606
					y = safe.height - 510, -- 606
					width = contentWidth - 32, -- 606
					height = 92, -- 606
					anchorX = 0, -- 606
					anchorY = 0, -- 606
					onMount = promptInput.mount -- 606
				}) -- 606
			) -- 606
			local ____temp_43 -- 615
			if questionIndex > 0 then -- 615
				____temp_43 = React.createElement( -- 615
					ActionButton, -- 615
					{ -- 615
						x = 16, -- 615
						y = 12, -- 615
						width = 92, -- 615
						text = zh and "上一步" or "Back", -- 615
						onTapped = function() -- 615
							questionIndex = questionIndex - 1 -- 615
							render() -- 615
						end -- 615
					} -- 615
				) -- 615
			else -- 615
				____temp_43 = nil -- 615
			end -- 615
			__TS__SparseArrayPush( -- 615
				____array_44, -- 615
				____temp_43, -- 615
				React.createElement( -- 615
					ActionButton, -- 616
					{ -- 616
						tag = "remix-question-submit", -- 616
						x = questionIndex > 0 and 120 or 16, -- 616
						y = 12, -- 616
						width = contentWidth - (questionIndex > 0 and 136 or 32), -- 616
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 616
						primary = true, -- 616
						onTapped = function() -- 616
							if not dismissedComposition then -- 616
								advanceQuestionnaire() -- 618
							end -- 618
							dismissedComposition = false -- 618
						end -- 618
					} -- 618
				) -- 618
			) -- 618
			____temp_46 = ____React_createElement_45(__TS__SparseArraySpread(____array_44)) -- 618
		else -- 618
			____temp_46 = nil -- 619
		end -- 619
		__TS__SparseArrayPush(____array_64, ____temp_46) -- 619
		local ____temp_47 -- 620
		if ____error ~= "" then -- 620
			____temp_47 = React.createElement( -- 620
				"label", -- 620
				{ -- 620
					tag = "remix-error", -- 620
					x = left + 20, -- 620
					y = bottom + (questionnaire and 144 or layoutComposerTop + composerGap), -- 620
					anchorX = 0, -- 620
					anchorY = 0, -- 620
					fontName = fontName, -- 620
					fontSize = 13, -- 620
					text = ____error, -- 620
					textWidth = contentWidth, -- 620
					alignment = "Left", -- 620
					color3 = 16739179, -- 620
					onMount = function(label) -- 620
						errorLabel = label -- 620
					end -- 620
				} -- 620
			) -- 620
		else -- 620
			____temp_47 = nil -- 620
		end -- 620
		__TS__SparseArrayPush(____array_64, ____temp_47) -- 620
		local ____temp_48 -- 621
		if questionnaire == nil then -- 621
			____temp_48 = React.createElement( -- 621
				"node", -- 621
				nil, -- 621
				React.createElement( -- 621
					ChoiceButton, -- 622
					{ -- 622
						tag = "remix-mode-plan", -- 622
						x = modeStartX, -- 622
						y = bottom + layoutModeBottom, -- 622
						width = modeWidth, -- 622
						text = zh and "计划" or "Plan", -- 622
						selected = workMode == "plan", -- 622
						disabled = not canSubmit(), -- 622
						onTapped = function() return changeWorkMode("plan") end -- 622
					} -- 622
				), -- 622
				React.createElement( -- 622
					ChoiceButton, -- 623
					{ -- 623
						tag = "remix-mode-code", -- 623
						x = modeStartX + modeWidth + composerGap, -- 623
						y = bottom + layoutModeBottom, -- 623
						width = modeCodeWidth, -- 623
						text = zh and "执行" or "Code", -- 623
						selected = workMode == "code", -- 623
						disabled = not canSubmit(), -- 623
						onTapped = function() return changeWorkMode("code") end -- 623
					} -- 623
				) -- 623
			) -- 623
		else -- 623
			____temp_48 = nil -- 624
		end -- 624
		__TS__SparseArrayPush(____array_64, ____temp_48) -- 624
		local ____temp_49 -- 625
		if questionnaire == nil and not keptInput then -- 625
			____temp_49 = React.createElement("node", { -- 625
				tag = "remix-input", -- 625
				ref = inputRef, -- 625
				x = left + 16, -- 625
				y = bottom + layoutComposerBottom, -- 625
				width = inputWidth, -- 625
				height = layoutComposerHeight, -- 625
				anchorX = 0, -- 625
				anchorY = 0, -- 625
				onMount = promptInput.mount -- 625
			}) -- 625
		else -- 625
			____temp_49 = nil -- 626
		end -- 626
		__TS__SparseArrayPush(____array_64, ____temp_49) -- 626
		local ____temp_62 -- 627
		if stopping or questionnaire == nil then -- 627
			local ____React_createElement_61 = React.createElement -- 627
			local ____ActionButton_60 = ActionButton -- 627
			local ____temp_55 = stopping and "remix-stop" or "remix-send" -- 627
			local ____temp_56 = left + 16 + inputWidth + composerGap -- 628
			local ____temp_57 = bottom + layoutComposerBottom -- 628
			local ____temp_58 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 629
			local ____temp_59 = not stopping -- 630
			local ____stopping_54 -- 630
			if stopping then -- 630
				____stopping_54 = stopRequested or (state and state.currentTaskFinalizing) == true -- 630
			else -- 630
				____stopping_54 = not canSubmit() -- 630
			end -- 630
			____temp_62 = ____React_createElement_61( -- 630
				____ActionButton_60, -- 627
				{ -- 627
					tag = ____temp_55, -- 627
					x = ____temp_56, -- 627
					y = ____temp_57, -- 627
					width = composerActionWidth, -- 627
					height = layoutComposerHeight, -- 627
					text = ____temp_58, -- 627
					primary = ____temp_59, -- 627
					danger = stopping, -- 627
					disabled = ____stopping_54, -- 627
					onTapped = function() -- 627
						if stopping then -- 627
							stop() -- 631
						elseif not dismissedComposition then -- 631
							send() -- 631
						end -- 631
						dismissedComposition = false -- 631
					end -- 631
				} -- 631
			) -- 631
		else -- 631
			____temp_62 = nil -- 631
		end -- 631
		__TS__SparseArrayPush(____array_64, ____temp_62) -- 631
		local ____temp_63 -- 632
		if phase == "done" then -- 632
			____temp_63 = React.createElement( -- 632
				ActionButton, -- 632
				{ -- 632
					tag = "remix-play", -- 632
					x = playX, -- 632
					y = bottom + layoutModeBottom, -- 632
					width = playWidth, -- 632
					height = 40, -- 632
					text = zh and "立即试玩" or "Play now", -- 632
					primary = true, -- 632
					onTapped = function() -- 632
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 632
							return -- 632
						end -- 632
						blurInput() -- 632
						notifyProjectChanged() -- 632
						host.visible = false -- 632
						onPlay(options.entry) -- 632
					end -- 632
				} -- 632
			) -- 632
		else -- 632
			____temp_63 = nil -- 632
		end -- 632
		__TS__SparseArrayPush(____array_64, ____temp_63) -- 632
		__TS__SparseArrayPush( -- 632
			____array_66, -- 632
			____React_createElement_65(__TS__SparseArraySpread(____array_64)) -- 632
		) -- 632
		local scene = ____toNode_68(____React_createElement_67(__TS__SparseArraySpread(____array_66))) -- 515
		if scene then -- 515
			host:addChild(scene) -- 636
			if keptInput then -- 636
				keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom) -- 638
				keptInput.width = inputWidth -- 639
				keptInput.height = layoutComposerHeight -- 640
				local ____opt_69 = pageRef.current -- 640
				if ____opt_69 ~= nil then -- 640
					____opt_69:addChild(keptInput) -- 641
				end -- 641
			end -- 641
			if not questionnaire then -- 641
				transcript.node.position = Vec2( -- 644
					left + 16, -- 644
					bottom + getTranscriptBottom() -- 644
				) -- 644
				local ____opt_71 = pageRef.current -- 644
				if ____opt_71 ~= nil then -- 644
					____opt_71:addChild(transcript.node) -- 645
				end -- 645
				updateTranscript() -- 646
			end -- 646
		end -- 646
		if restoreInputFocus and inputRef.current and not keptInput then -- 646
			promptInput.focus(false) -- 649
		end -- 649
		if keptInput then -- 649
			promptInput.refresh() -- 650
		end -- 650
		shellRevision = getShellRevision() -- 651
		displayRevision = remixDisplayRevision(detail) -- 652
	end -- 399
	host:schedule(function(dt) -- 655
		pollElapsed = pollElapsed + dt -- 656
		if pollElapsed < 0.25 then -- 656
			return false -- 657
		end -- 657
		pollElapsed = 0 -- 658
		refresh() -- 659
		if swipeDragging or swipeBackPending then -- 659
			return false -- 660
		end -- 660
		local next = remixDisplayRevision(detail) -- 661
		if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then -- 661
			render() -- 662
		elseif displayRevision ~= next then -- 662
			updateTranscript() -- 663
		end -- 663
		return false -- 664
	end) -- 655
	host:onAppChange(function(setting) -- 666
		if setting == "Size" or setting == "Locale" then -- 666
			render() -- 666
		end -- 666
	end) -- 666
	host:onAppEvent(function(event) -- 667
		if event == "BackButton" then -- 667
			if promptInput.isFocused() then -- 667
				blurInput() -- 668
			else -- 668
				goBack() -- 668
			end -- 668
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 668
			blurInput() -- 669
		end -- 669
	end) -- 667
	host:onCleanup(function() -- 671
		disposed = true -- 671
		blurInput() -- 671
	end) -- 671
	host:slot("SuspendLocalUI", blurInput) -- 672
	host:slot( -- 673
		"ResumeLocalUI", -- 673
		function() -- 673
			refresh() -- 673
			render() -- 673
		end -- 673
	) -- 673
	render() -- 674
	if needsLLMSetup then -- 674
		thread(function() -- 675
			sleep(0) -- 675
			if not disposed and host.parent then -- 675
				configureLLM() -- 675
			end -- 675
		end) -- 675
	end -- 675
	return host -- 676
end -- 104
return ____exports -- 104
