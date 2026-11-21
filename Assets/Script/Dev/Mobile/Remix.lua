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
local ____RemixVoice = require("Dev.Mobile.RemixVoice") -- 15
local createRemixVoice = ____RemixVoice.createRemixVoice -- 15
local remixVoiceKey = ____RemixVoice.remixVoiceKey -- 15
local ____LLMSetup = require("Dev.Mobile.LLMSetup") -- 16
local startMobileLLMManager = ____LLMSetup.startMobileLLMManager -- 16
local ____PackagePanel = require("Dev.Mobile.PackagePanel") -- 17
local startPackagePanel = ____PackagePanel.startPackagePanel -- 17
local ____Visual = require("Dev.Mobile.Visual") -- 18
local RoundedSurface = ____Visual.RoundedSurface -- 18
local VerticalGradient = ____Visual.VerticalGradient -- 18
local ____Controls = require("Dev.Mobile.Controls") -- 19
local ChoiceButton = ____Controls.MobileChoiceButton -- 19
local fontName = "sarasa-mono-sc-regular" -- 51
local colors = { -- 52
	background = 4279045390, -- 52
	panel = 4279966750, -- 52
	text = 4294242792, -- 52
	muted = 4289245117, -- 52
	brand = 4294954035, -- 52
	border = 4281940797, -- 52
	danger = 4294929259 -- 52
} -- 52
local composerGap = 12 -- 54
local composerBottom = 76 -- 55
local composerHeight = 60 -- 56
local composerActionWidth = 82 -- 57
local modeBottom = composerBottom + composerHeight + composerGap -- 58
local composerTop = modeBottom + 40 -- 59
local transcriptBottom = composerTop + composerGap -- 60
local statusHeight = 64 -- 61
local function ellipsizeSingleLine(text, width, fontSize) -- 63
	if text == "" then -- 63
		return "" -- 64
	end -- 64
	local measure = Label(fontName, fontSize, true) -- 65
	if not measure then -- 65
		return text -- 66
	end -- 66
	measure.visible = false -- 67
	measure.textWidth = -1 -- 68
	local function fits(value) -- 69
		measure.text = value -- 69
		return measure.width <= width -- 69
	end -- 69
	if fits(text) then -- 69
		measure:cleanup() -- 70
		return text -- 70
	end -- 70
	local low = 0 -- 71
	local high = inputLength(text) -- 71
	while low < high do -- 71
		local middle = math.floor((low + high + 1) / 2) -- 73
		if fits(inputSlice(text, 0, middle) .. "…") then -- 73
			low = middle -- 74
		else -- 74
			high = middle - 1 -- 75
		end -- 75
	end -- 75
	local result = inputSlice(text, 0, low) .. "…" -- 77
	measure:cleanup() -- 78
	return result -- 79
end -- 63
local function measureWrappedTextHeight(text, width, fontSize) -- 82
	local measure = Label(fontName, fontSize, true) -- 83
	if not measure then -- 83
		return fontSize -- 84
	end -- 84
	measure.visible = false -- 85
	measure.textWidth = width -- 86
	measure.alignment = "Left" -- 87
	measure.text = text -- 88
	local height = measure.height -- 89
	measure:cleanup() -- 90
	return height -- 91
end -- 82
local function ActionButton(props) -- 94
	local height = props.height or 46 -- 95
	return React.createElement( -- 96
		"node", -- 96
		{ -- 96
			tag = props.tag, -- 96
			x = props.x, -- 96
			y = props.y, -- 96
			width = props.width, -- 96
			height = height, -- 96
			anchorX = 0, -- 96
			anchorY = 0, -- 96
			opacity = props.disabled and 0.45 or 1, -- 96
			touchEnabled = not props.disabled, -- 96
			swallowTouches = true, -- 96
			onTapped = props.onTapped -- 96
		}, -- 96
		React.createElement(RoundedSurface, { -- 96
			width = props.width, -- 96
			height = height, -- 96
			radius = 14, -- 96
			topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4281282868), -- 96
			bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279967007), -- 96
			borderWidth = 1, -- 96
			borderColor = props.danger and colors.danger or (props.primary and 4294958435 or colors.border), -- 96
			shadow = props.primary or props.danger -- 96
		}), -- 96
		React.createElement("label", { -- 96
			x = props.width / 2, -- 96
			y = height / 2, -- 96
			fontName = fontName, -- 96
			fontSize = 15, -- 96
			text = props.text, -- 96
			color3 = props.primary and 1512202 or 16052712 -- 96
		}) -- 96
	) -- 96
end -- 94
function ____exports.startMobileRemix(options) -- 105
	local host, voice, send, getTranscriptActions, render -- 105
	local canShare = App.platform == "Android" or App.platform == "iOS" -- 106
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
	local voiceEnabled = false -- 130
	local voiceForeground = true -- 131
	local ____error = created.success and "" or created.message -- 132
	local backNoticeUntil = 0 -- 133
	local pollElapsed = 0 -- 134
	local stopRequested = false -- 135
	local selectedLLMConfigId = 0 -- 136
	local questionnaireId = 0 -- 137
	local questionIndex = 0 -- 138
	local llmConfigs = services.getLLMConfigSummaries() -- 139
	local taskLLMConfigId = 0 -- 140
	local needsLLMSetup = false -- 141
	local questionnaireSelections = {} -- 142
	local questionnaireTexts = {} -- 143
	local inputRef = reference() -- 144
	local disposed = false -- 145
	local dismissedComposition = false -- 146
	local swipeBackPending = false -- 147
	local swipeDragging = false -- 148
	local swipeRevision = 0 -- 149
	local projectChangeNotified = false -- 150
	local function currentQuestion() -- 151
		local ____detail_success_2 -- 151
		if detail.success then -- 151
			local ____opt_0 = detail.pendingQuestionnaire -- 151
			____detail_success_2 = ____opt_0 and ____opt_0.schema.questions[questionIndex + 1] -- 151
		else -- 151
			____detail_success_2 = nil -- 151
		end -- 151
		return ____detail_success_2 -- 151
	end -- 151
	local promptInput = createTextInput({ -- 152
		fontSize = math.floor(16 * mobileFontScale), -- 153
		getText = function() -- 154
			local question = currentQuestion() -- 154
			return question and (questionnaireTexts[question.id] or "") or draft -- 154
		end, -- 154
		setText = function(text) -- 155
			local question = currentQuestion() -- 155
			if question then -- 155
				questionnaireTexts[question.id] = text -- 155
			else -- 155
				draft = text -- 155
			end -- 155
		end, -- 155
		getPlaceholder = function() -- 156
			local question = currentQuestion() -- 157
			return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…")) -- 158
		end, -- 156
		isEnabled = function() return voice.phase() == "idle" and not packagePanel and not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end, -- 160
		onReturn = function(modified) -- 161
			if modified and not currentQuestion() then -- 161
				send() -- 161
				return true -- 161
			end -- 161
			return false -- 161
		end -- 161
	}) -- 161
	local blurInput = promptInput.blur -- 163
	local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 164
	local ____temp_5 -- 165
	if rememberedRows and #rememberedRows > 0 then -- 165
		____temp_5 = tonumber(rememberedRows[1][1]) -- 165
	else -- 165
		____temp_5 = nil -- 165
	end -- 165
	local rememberedId = ____temp_5 -- 165
	if rememberedId and __TS__ArraySome( -- 165
		llmConfigs, -- 166
		function(____, item) return item.id == rememberedId end -- 166
	) then -- 166
		selectedLLMConfigId = rememberedId -- 166
	elseif #llmConfigs > 0 then -- 166
		selectedLLMConfigId = llmConfigs[1].id -- 167
	else -- 167
		local activeConfig = services.getActiveLLMConfig() -- 169
		if activeConfig.success then -- 169
			selectedLLMConfigId = activeConfig.id -- 170
		else -- 170
			needsLLMSetup = true -- 171
		end -- 171
	end -- 171
	host = Node() -- 174
	host.tag = "mobile-remix" -- 175
	host.scaleX = App.devicePixelRatio -- 176
	host.scaleY = App.devicePixelRatio -- 177
	host:addTo(Director.systemUI) -- 178
	local transcript = createRemixTranscript() -- 179
	local displayRevision = "" -- 180
	local shellRevision = "" -- 181
	local inputLayout = "" -- 182
	local mascotAnimationState -- 183
	local mascotAnimationStartedAt = App.runningTime -- 184
	local compactHeaderStatusActive = false -- 185
	local errorLabel -- 186
	local voiceMeter = reference() -- 187
	local displayedVoiceLevel = 0 -- 188
	local layoutTranscriptBottom = transcriptBottom -- 189
	local function getLayoutArea() -- 190
		return App.safeArea -- 190
	end -- 190
	local function getTranscriptBottom() -- 191
		return layoutTranscriptBottom + (errorLabel and errorLabel.height + composerGap or 0) -- 191
	end -- 191
	local function hasTranscriptContent() -- 192
		return detail.success and (#detail.messages > 0 or #detail.steps > 0) -- 192
	end -- 192
	local function getHeaderY(safe) -- 193
		local landscapeTopLift = safe.width >= 760 and safe.height < 500 and 28 or 0 -- 194
		return safe.y + safe.height - 56 + landscapeTopLift -- 195
	end -- 193
	local function useCompactHeaderStatus(safe) -- 197
		return safe.width >= 760 and safe.height < 500 and hasTranscriptContent() -- 197
	end -- 197
	local function useCompactStandaloneStatus(safe) -- 198
		return safe.height >= 500 and hasTranscriptContent() -- 198
	end -- 198
	local function getTranscriptHeight(safe) -- 199
		local statusInset = useCompactHeaderStatus(safe) and composerGap or statusHeight + composerGap * 2 - (useCompactStandaloneStatus(safe) and 24 or 0) -- 200
		local available = math.max( -- 202
			40, -- 202
			getHeaderY(safe) - safe.y - getTranscriptBottom() - statusInset -- 202
		) -- 202
		return safe.width >= 760 and safe.height < 500 and not hasTranscriptContent() and 8 or available -- 203
	end -- 199
	local function getShellRevision() -- 205
		local ____detail_success_9 -- 205
		if detail.success then -- 205
			local ____safeJsonEncode_8 = safeJsonEncode -- 205
			local ____array_7 = __TS__SparseArrayNew( -- 205
				detail.session.status, -- 206
				detail.session.workMode, -- 206
				detail.hasActivePlan, -- 206
				detail.pendingQuestionnaire or false, -- 206
				detail.session.currentTaskStatus or "" -- 207
			) -- 207
			local ____detail_session_currentTaskFinalizing_6 = detail.session.currentTaskFinalizing -- 207
			if ____detail_session_currentTaskFinalizing_6 == nil then -- 207
				____detail_session_currentTaskFinalizing_6 = false -- 207
			end -- 207
			__TS__SparseArrayPush( -- 207
				____array_7, -- 207
				____detail_session_currentTaskFinalizing_6, -- 207
				stopRequested, -- 207
				hasTranscriptContent(), -- 207
				resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or "" -- 208
			) -- 208
			____detail_success_9 = (____safeJsonEncode_8({__TS__SparseArraySpread(____array_7)})) or "" -- 205
		else -- 205
			____detail_success_9 = detail.message -- 209
		end -- 209
		return ____detail_success_9 -- 205
	end -- 205
	local function updateTranscript() -- 210
		local safe = getLayoutArea() -- 211
		transcript:update( -- 212
			detail, -- 212
			math.max(60, safe.width - 32), -- 212
			getTranscriptHeight(safe), -- 212
			mobileFontScale, -- 212
			zh, -- 212
			getTranscriptActions() -- 212
		) -- 212
		displayRevision = remixDisplayRevision(detail) -- 213
	end -- 210
	local function hasActiveTask() -- 216
		return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil) -- 216
	end -- 216
	local function notifyProjectChanged() -- 219
		if projectChangeNotified or not detail.success or not options.onProjectChanged then -- 219
			return -- 220
		end -- 220
		if not __TS__ArraySome( -- 220
			detail.steps, -- 221
			function(____, step) return step.files ~= nil and #step.files > 0 end -- 221
		) then -- 221
			return -- 221
		end -- 221
		projectChangeNotified = true -- 222
		options.onProjectChanged(options.entry) -- 223
	end -- 219
	local function refresh() -- 225
		if sessionId > 0 then -- 225
			detail = services.getSession(sessionId) -- 226
		end -- 226
		if detail.success and not hasActiveTask() then -- 226
			stopRequested = false -- 227
		end -- 227
		if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then -- 227
			questionnaireId = detail.pendingQuestionnaire.id -- 229
			questionIndex = 0 -- 230
		end -- 230
	end -- 225
	local function canSubmit() -- 233
		return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire -- 233
	end -- 233
	local function resolveLLMConfig() -- 236
		return selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig() -- 236
	end -- 236
	local function getVoiceKey() -- 237
		local selected = resolveLLMConfig() -- 238
		local ____selected_success_10 -- 239
		if selected.success then -- 239
			____selected_success_10 = remixVoiceKey(selected.config) -- 239
		else -- 239
			____selected_success_10 = nil -- 239
		end -- 239
		local preferred = ____selected_success_10 -- 239
		if preferred then -- 239
			return preferred -- 240
		end -- 240
		for ____, item in ipairs(llmConfigs) do -- 241
			do -- 241
				if selected.success and item.id == selected.id then -- 241
					goto __continue52 -- 242
				end -- 242
				local result = services.getLLMConfig(item.id) -- 243
				local ____result_success_11 -- 244
				if result.success then -- 244
					____result_success_11 = remixVoiceKey(result.config) -- 244
				else -- 244
					____result_success_11 = nil -- 244
				end -- 244
				local key = ____result_success_11 -- 244
				if key then -- 244
					return key -- 245
				end -- 245
			end -- 245
			::__continue52:: -- 245
		end -- 245
		return nil -- 247
	end -- 237
	voiceEnabled = getVoiceKey() ~= nil -- 249
	voice = createRemixVoice( -- 250
		function() -- 251
			if not disposed and host.parent and host.visible then -- 251
				render() -- 251
			end -- 251
		end, -- 251
		function(text) -- 252
			if disposed or not host.visible or not canSubmit() then -- 252
				return -- 253
			end -- 253
			local separator = draft ~= "" and (string.match(draft, "%s$")) == nil and " " or "" -- 254
			draft = inputSlice((draft .. separator) .. text, 0, 12000) -- 255
			promptInput.refresh() -- 256
		end, -- 252
		function(issue) -- 258
			if disposed or not host.visible then -- 258
				return -- 259
			end -- 259
			____error = issue == "silence" and (zh and "未检测到语音。" or "No speech detected.") or (issue == "capture" and (zh and "无法收音，请检查麦克风及其权限。" or "Could not capture audio. Check microphone access.") or (zh and "DeepSeek 转写失败，请检查密钥和网络。" or "DeepSeek transcription failed. Check the key and connection.")) -- 260
			render() -- 263
		end -- 258
	) -- 258
	local function startVoice() -- 266
		if not host.visible or HttpServer.wsConnectionCount > 0 or not canSubmit() or voice.phase() ~= "idle" then -- 266
			return -- 267
		end -- 267
		if dismissedComposition or promptInput.isComposing() then -- 267
			dismissedComposition = false -- 268
			blurInput() -- 268
			return -- 268
		end -- 268
		local key = getVoiceKey() -- 269
		if not key then -- 269
			voiceEnabled = false -- 270
			render() -- 270
			return -- 270
		end -- 270
		blurInput() -- 271
		____error = "" -- 272
		voice.start(key) -- 273
	end -- 266
	local function configureLLM() -- 275
		if voice.phase() ~= "idle" or not host.visible or HttpServer.wsConnectionCount > 0 then -- 275
			return -- 276
		end -- 276
		blurInput() -- 277
		startMobileLLMManager({ -- 278
			coveredNode = host, -- 279
			selectedId = selectedLLMConfigId, -- 280
			taskRunning = hasActiveTask(), -- 281
			runningId = taskLLMConfigId, -- 282
			onSelected = function(id) -- 283
				if disposed or not host.parent then -- 283
					return -- 284
				end -- 284
				llmConfigs = services.getLLMConfigSummaries() -- 285
				selectedLLMConfigId = id -- 286
				voiceEnabled = getVoiceKey() ~= nil -- 287
				needsLLMSetup = #llmConfigs == 0 -- 288
				____error = "" -- 289
				render() -- 290
			end, -- 283
			onClose = function() -- 292
				if not disposed and host.parent then -- 292
					render() -- 292
				end -- 292
			end -- 292
		}) -- 292
	end -- 275
	local function changeWorkMode(workMode) -- 295
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 295
			return -- 296
		end -- 296
		refresh() -- 297
		if not canSubmit() or not detail.success then -- 297
			return -- 298
		end -- 298
		if resolveRemixWorkMode(detail.session) == workMode then -- 298
			return -- 299
		end -- 299
		local result = services.setWorkMode(sessionId, workMode) -- 300
		____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode")) -- 301
		refresh() -- 302
		render() -- 303
	end -- 295
	send = function() -- 305
		if voice.phase() ~= "idle" or not host.visible or HttpServer.wsConnectionCount > 0 then -- 305
			return -- 306
		end -- 306
		refresh() -- 307
		if not canSubmit() or not detail.success or promptInput.isComposing() then -- 307
			return -- 308
		end -- 308
		local workMode = resolveRemixWorkMode(detail.session) -- 309
		local text = (string.match(draft, "^%s*(.-)%s*$")) or "" -- 312
		if sessionId <= 0 or text == "" then -- 312
			return -- 313
		end -- 313
		local config = resolveLLMConfig() -- 314
		if not config.success then -- 314
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 316
			render() -- 317
			configureLLM() -- 318
			return -- 319
		end -- 319
		selectedLLMConfigId = config.id -- 321
		local result = services.sendPrompt( -- 322
			sessionId, -- 322
			text, -- 322
			nil, -- 322
			workMode, -- 322
			config.id, -- 322
			config.config -- 322
		) -- 322
		if not result.success then -- 322
			____error = result.message -- 323
		else -- 323
			taskLLMConfigId = config.id -- 324
			draft = "" -- 324
			____error = "" -- 324
		end -- 324
		refresh() -- 325
		render() -- 326
	end -- 305
	local function continueTask() -- 328
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 328
			return -- 329
		end -- 329
		refresh() -- 330
		if not detail.success or hasActiveTask() or detail.session.currentTaskStatus ~= "FAILED" and detail.session.currentTaskStatus ~= "STOPPED" or detail.session.currentTaskId == nil then -- 330
			return -- 332
		end -- 332
		local config = resolveLLMConfig() -- 333
		if not config.success then -- 333
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 335
			render() -- 336
			configureLLM() -- 337
			return -- 338
		end -- 338
		if not services.continuePrompt then -- 338
			____error = zh and "当前版本不支持继续会话" or "Continuing this session is unavailable" -- 341
			render() -- 342
			return -- 343
		end -- 343
		selectedLLMConfigId = config.id -- 345
		local result = services.continuePrompt(sessionId, nil, config.id) -- 346
		____error = result.success and "" or result.message -- 347
		if result.success then -- 347
			taskLLMConfigId = config.id -- 348
			stopRequested = false -- 348
		end -- 348
		refresh() -- 349
		render() -- 350
	end -- 328
	local function startDevelopment() -- 352
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 352
			return -- 353
		end -- 353
		refresh() -- 354
		if not detail.success or hasActiveTask() or detail.session.workMode ~= "plan" or not detail.hasActivePlan then -- 354
			return -- 355
		end -- 355
		local modeResult = services.setWorkMode(sessionId, "code") -- 356
		if not modeResult.success then -- 356
			____error = modeResult.message or (zh and "切换执行模式失败" or "Could not switch to Code mode") -- 358
			render() -- 359
			return -- 360
		end -- 360
		local config = resolveLLMConfig() -- 362
		if not config.success then -- 362
			____error = zh and "请先完成 AI 快速配置" or "Complete the quick AI setup first" -- 364
			refresh() -- 365
			render() -- 366
			configureLLM() -- 367
			return -- 368
		end -- 368
		selectedLLMConfigId = config.id -- 370
		local prompt = zh and "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。" or "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated." -- 371
		local result = services.sendPrompt( -- 374
			sessionId, -- 374
			prompt, -- 374
			nil, -- 374
			"code", -- 374
			config.id, -- 374
			config.config -- 374
		) -- 374
		____error = result.success and "" or result.message -- 375
		if result.success then -- 375
			taskLLMConfigId = config.id -- 376
		end -- 376
		refresh() -- 377
		render() -- 378
	end -- 352
	getTranscriptActions = function() -- 380
		if not detail.success or not hasTranscriptContent() or hasActiveTask() or __TS__ArrayEvery( -- 380
			detail.messages, -- 381
			function(____, message) return message.role ~= "assistant" end -- 381
		) then -- 381
			return {} -- 381
		end -- 381
		local actions = {} -- 382
		if (detail.session.currentTaskStatus == "FAILED" or detail.session.currentTaskStatus == "STOPPED") and detail.session.currentTaskId ~= nil then -- 382
			actions[#actions + 1] = {id = "continue", text = zh and "继续" or "Continue", onTapped = continueTask} -- 384
		end -- 384
		if detail.session.kind == "main" and detail.session.workMode == "plan" and detail.hasActivePlan then -- 384
			actions[#actions + 1] = {id = "start-development", text = zh and "开始开发" or "Start development", primary = true, onTapped = startDevelopment} -- 386
		end -- 386
		return actions -- 387
	end -- 380
	local function stop() -- 389
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 389
			return -- 390
		end -- 390
		refresh() -- 391
		if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then -- 391
			return -- 393
		end -- 393
		local result = services.stopSessionTask(sessionId) -- 394
		if (result and result.success) == false then -- 394
			____error = result.message or (zh and "停止失败" or "Could not stop") -- 395
		else -- 395
			stopRequested = true -- 396
			____error = "" -- 396
		end -- 396
		refresh() -- 397
		render() -- 398
	end -- 389
	local function advanceQuestionnaire(skipCurrent) -- 400
		if skipCurrent == nil then -- 400
			skipCurrent = false -- 400
		end -- 400
		if not host.visible or HttpServer.wsConnectionCount > 0 then -- 400
			return -- 401
		end -- 401
		if not detail.success or not detail.pendingQuestionnaire then -- 401
			return -- 402
		end -- 402
		local pending = detail.pendingQuestionnaire -- 403
		local questions = pending.schema.questions -- 404
		local question = questions[questionIndex + 1] -- 405
		if question == nil then -- 405
			return -- 406
		end -- 406
		local selected = questionnaireSelections[question.id] or ({}) -- 407
		local text = __TS__StringTrim(questionnaireTexts[question.id] or "") -- 408
		if skipCurrent then -- 408
			if question.required then -- 408
				return -- 410
			end -- 410
			questionnaireSelections[question.id] = {} -- 411
			questionnaireTexts[question.id] = "" -- 412
		elseif not isQuestionAnswered(question, selected, text) then -- 412
			____error = zh and "请先完成当前必答问题" or "Answer the required question first" -- 414
			render() -- 415
			return -- 416
		end -- 416
		if questionIndex + 1 < #questions then -- 416
			questionIndex = questionIndex + 1 -- 419
			____error = "" -- 420
			render() -- 421
			return -- 422
		end -- 422
		local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts) -- 424
		if selectedLLMConfigId <= 0 then -- 424
			____error = zh and "没有可用的模型配置" or "No model configuration is available" -- 426
			render() -- 427
			return -- 428
		end -- 428
		local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId) -- 430
		if not result.success then -- 430
			____error = result.message -- 431
		else -- 431
			taskLLMConfigId = selectedLLMConfigId -- 432
			____error = "" -- 432
		end -- 432
		refresh() -- 433
		render() -- 434
	end -- 400
	local function goBack() -- 436
		if voice.phase() ~= "idle" then -- 436
			voice.cancel() -- 437
			return -- 437
		end -- 437
		if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 437
			return -- 438
		end -- 438
		if detail.success and not canLeaveRemix(detail.session.status) then -- 438
			____error = "" -- 440
			backNoticeUntil = App.runningTime + 3 -- 441
			render() -- 442
			return -- 443
		end -- 443
		blurInput() -- 445
		notifyProjectChanged() -- 446
		host.visible = false -- 447
		host:removeFromParent(true) -- 448
		onBack() -- 449
	end -- 436
	render = function() -- 452
		local visibleError = ____error ~= "" and ____error or (backNoticeUntil > App.runningTime and (zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back") or "") -- 453
		errorLabel = nil -- 455
		voiceMeter = reference() -- 456
		swipeRevision = swipeRevision + 1 -- 458
		swipeDragging = false -- 459
		swipeBackPending = false -- 460
		local layout = (((tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height)) .. ":") .. tostring(voiceEnabled) -- 461
		local ____temp_16 = layout == inputLayout and not (detail.success and detail.pendingQuestionnaire) -- 463
		if ____temp_16 then -- 463
			local ____opt_14 = inputRef.current -- 463
			____temp_16 = (____opt_14 and ____opt_14.tag) == "remix-input" -- 463
		end -- 463
		local keptInput = ____temp_16 and inputRef.current or nil -- 463
		if keptInput ~= nil then -- 463
			keptInput:removeFromParent(false) -- 465
		end -- 465
		transcript.node:removeFromParent(false) -- 466
		local restoreInputFocus = promptInput.isFocused() -- 467
		if not keptInput then -- 467
			promptInput.unmount() -- 469
			inputRef = reference() -- 470
		end -- 470
		host:removeAllChildren() -- 472
		inputLayout = layout -- 473
		host.scaleX = App.devicePixelRatio -- 474
		host.scaleY = App.devicePixelRatio -- 475
		local ____App_visualSize_19 = App.visualSize -- 476
		local width = ____App_visualSize_19.width -- 476
		local height = ____App_visualSize_19.height -- 476
		local safe = getLayoutArea() -- 477
		local left = safe.x -- 478
		local bottom = safe.y -- 479
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 480
		local state = detail.success and detail.session or nil -- 481
		local workMode = resolveRemixWorkMode(state) -- 482
		local stopping = hasActiveTask() -- 483
		local ____detail_success_20 -- 484
		if detail.success then -- 484
			____detail_success_20 = detail.hasActivePlan -- 484
		else -- 484
			____detail_success_20 = false -- 484
		end -- 484
		local hasActivePlan = ____detail_success_20 -- 484
		local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed" -- 485
		local layoutComposerBottom = 24 -- 486
		local layoutComposerHeight = composerHeight -- 487
		local layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap -- 488
		local layoutComposerTop = layoutModeBottom + 40 -- 489
		layoutTranscriptBottom = layoutComposerTop + composerGap + (phase == "done" and 48 or 0) -- 490
		local contentWidth = safe.width - 32 -- 491
		local voicePhase = voice.phase() -- 492
		local voiceActive = voicePhase ~= "idle" -- 493
		local meterWidth = math.max(24, contentWidth - 152) -- 494
		local voiceWidth = voiceEnabled and 60 + composerGap or 0 -- 495
		local inputWidth = contentWidth - composerActionWidth - composerGap - voiceWidth -- 496
		local voiceLabel = voicePhase == "opening" and (zh and "正在打开麦克风…" or "Opening microphone…") or (voicePhase == "waiting" and (zh and "等待开口…" or "Waiting for speech…") or (voicePhase == "recording" and (zh and "正在收音…" or "Listening…") or (zh and "DeepSeek 正在转写…" or "Transcribing with DeepSeek…"))) -- 497
		local modeWidth = math.floor((contentWidth - composerGap) / 2) -- 501
		local modeStartX = left + 16 -- 502
		local modeCodeWidth = contentWidth - modeWidth - composerGap -- 503
		local playWidth = canShare and (contentWidth - composerGap) / 2 or contentWidth -- 504
		local playX = canShare and modeStartX + playWidth + composerGap or modeStartX -- 505
		local ____detail_success_21 -- 506
		if detail.success then -- 506
			____detail_success_21 = detail.pendingQuestionnaire -- 506
		else -- 506
			____detail_success_21 = nil -- 506
		end -- 506
		local questionnaire = ____detail_success_21 -- 506
		local question = questionnaire and questionnaire.schema.questions[questionIndex + 1] -- 507
		local questionPromptWidth = contentWidth - 32 -- 508
		local questionPromptHeight = question and measureWrappedTextHeight(question.prompt, questionPromptWidth, 16) or 0 -- 509
		local questionOptions = question and question.type ~= "text" and __TS__ArraySlice(question.options or ({}), 0, 8) or ({}) -- 512
		local questionAnswerHeight = #questionOptions > 0 and 40 + 43 * (#questionOptions - 1) or 92 -- 513
		local questionCardMinHeight = safe.height - 330 -- 514
		local questionCardMaxHeight = math.max(questionCardMinHeight, safe.height - 164 - 72) -- 515
		local questionCardHeight = math.min( -- 516
			math.max(questionCardMinHeight, 75 + questionPromptHeight / 2 + 14 + questionAnswerHeight + 16 + 40 + 12), -- 517
			questionCardMaxHeight -- 518
		) -- 518
		local questionAnswerTop = questionCardHeight - 75 - questionPromptHeight / 2 - 14 -- 520
		local questionHasBack = questionIndex > 0 -- 521
		local questionCanSkip = question ~= nil and not question.required -- 522
		local questionActionGap = 8 -- 523
		local questionBackWidth = 76 -- 524
		local questionSkipWidth = 64 -- 525
		local questionSkipX = 16 + (questionHasBack and questionBackWidth + questionActionGap or 0) -- 526
		local questionSubmitX = questionSkipX + (questionCanSkip and questionSkipWidth + questionActionGap or 0) -- 527
		local fontScale = mobileFontScale -- 528
		local headerY = getHeaderY(safe) -- 529
		local compactHeaderStatus = useCompactHeaderStatus(safe) -- 530
		compactHeaderStatusActive = compactHeaderStatus -- 531
		local headerStatusWidth = 168 -- 532
		local modelButtonWidth = shortLandscape and 92 or 72 -- 533
		local backText = zh and "返回 ›" or "Back ›" -- 534
		local backMeasure = Label(fontName, 18, true) -- 535
		backMeasure.text = backText -- 536
		local backWidth = math.max(44, backMeasure.width) -- 537
		backMeasure:cleanup() -- 538
		local headerBackX = left + safe.width - 16 - backWidth -- 539
		local headerSettingsX = headerBackX - composerGap - modelButtonWidth -- 540
		local headerStatusX = headerSettingsX - 8 - headerStatusWidth -- 541
		local headerTitleWidth = compactHeaderStatus and math.max(120, headerStatusX - (left + 16) - composerGap) or math.max(120, headerSettingsX - (left + 16) - composerGap) -- 542
		local selectedConfig = __TS__ArrayFind( -- 545
			llmConfigs, -- 545
			function(____, item) return item.id == selectedLLMConfigId end -- 545
		) -- 545
		local switchPending = hasActiveTask() and taskLLMConfigId > 0 and taskLLMConfigId ~= selectedLLMConfigId -- 546
		local modelName = selectedConfig and selectedConfig.name or (zh and "配置 AI" or "Set up AI") -- 547
		local modelNameLimit = shortLandscape and 10 or 6 -- 548
		local shortModelName = inputLength(modelName) > modelNameLimit and inputSlice(modelName, 0, modelNameLimit) .. "…" or modelName -- 549
		local modelLabel = ellipsizeSingleLine((switchPending and (zh and "下一轮·" or "Next·") or "") .. shortModelName, modelButtonWidth - 14, 11) -- 550
		local thinkingText = resolveRemixThinkingStatus(detail.success and detail.steps or ({}), state and state.currentTaskId) -- 551
		local statusText = thinkingText ~= nil and (zh and "正在思考" or "Thinking") or (phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game"))))))) -- 552
		local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle")))) -- 559
		if mascotAnimationState ~= mascotState then -- 559
			mascotAnimationState = mascotState -- 566
			mascotAnimationStartedAt = App.runningTime -- 567
		end -- 567
		local emptyLandscape = shortLandscape and not hasTranscriptContent() -- 569
		local emptyStatusBottom = bottom + layoutTranscriptBottom -- 570
		local emptyStatusTop = headerY - composerGap - statusHeight -- 571
		local messageTop = emptyLandscape and (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2 or headerY - composerGap - statusHeight / 2 -- 572
		local mascotSize = shortLandscape and 42 or 52 -- 575
		local compactStandaloneStatus = useCompactStandaloneStatus(safe) -- 576
		local standaloneStatusContentLift = shortLandscape and 0 or (compactStandaloneStatus and 26 or 14) -- 577
		local mascotX = shortLandscape and left + 40 or left + 66 -- 578
		local statusTextX = shortLandscape and left + 76 or left + 104 -- 579
		local statusTextWidth = shortLandscape and math.max(120, left + 16 + contentWidth - statusTextX) or contentWidth - 84 -- 580
		local renderedStatusX = compactHeaderStatus and 36 or statusTextX -- 581
		local renderedStatusY = compactHeaderStatus and 22 or statusHeight / 2 + standaloneStatusContentLift -- 582
		local renderedStatusWidth = compactHeaderStatus and headerStatusWidth - 36 or statusTextWidth -- 583
		local thinkingFontSize = compactHeaderStatus and math.floor(10 * fontScale) or math.floor(12 * fontScale) -- 584
		local thinkingRightPadding = compactHeaderStatus and 8 or 20 -- 585
		local renderedThinkingText = thinkingText == nil and "" or ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize) -- 586
		local swipeStart = Vec2.zero -- 587
		local swipeAxis = "none" -- 588
		local pageRef = reference() -- 589
		local hitsTranscriptButton -- 590
		hitsTranscriptButton = function(node, world) -- 590
			if not node.visible then -- 590
				return false -- 591
			end -- 591
			if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then -- 591
				local p = node:convertToNodeSpace(world) -- 593
				if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then -- 593
					return true -- 594
				end -- 594
			end -- 594
			local hit = false -- 596
			node:eachChild(function(child) -- 597
				hit = hitsTranscriptButton(child, world) -- 597
				return hit -- 597
			end) -- 597
			return hit -- 598
		end -- 590
		local ____toNode_71 = toNode -- 600
		local ____React_createElement_70 = React.createElement -- 600
		local ____array_69 = __TS__SparseArrayNew( -- 600
			"node", -- 600
			{ -- 600
				tag = "remix-scene", -- 600
				x = -width / 2, -- 600
				y = -height / 2, -- 600
				width = width, -- 600
				height = height, -- 600
				anchorX = 0, -- 600
				anchorY = 0 -- 600
			}, -- 600
			React.createElement( -- 600
				"node", -- 600
				{ -- 600
					tag = "remix-focus-observer", -- 600
					order = 1000, -- 600
					width = width, -- 600
					height = height, -- 600
					anchorX = 0, -- 600
					anchorY = 0, -- 600
					touchEnabled = true, -- 600
					swallowTouches = false, -- 600
					swallowMouseWheel = false, -- 600
					onTapFilter = function(touch) -- 600
						touch.enabled = false -- 604
						if packagePanel or swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then -- 604
							return -- 605
						end -- 605
						local input = inputRef.current -- 606
						local point = input and input:convertToNodeSpace(touch.worldLocation) -- 607
						local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height -- 608
						dismissedComposition = not inside and promptInput.isComposing() -- 609
						if not inside then -- 609
							blurInput() -- 610
						end -- 610
						if not inside and not questionnaire and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then -- 610
							touch.enabled = true -- 615
						end -- 615
					end, -- 603
					onTapBegan = function(touch) -- 603
						swipeStart = touch.location -- 619
						swipeAxis = "none" -- 619
						swipeDragging = true -- 619
						local ____opt_30 = pageRef.current -- 619
						if ____opt_30 ~= nil then -- 619
							____opt_30:stopAllActions() -- 620
						end -- 620
					end, -- 618
					onTapMoved = function(touch) -- 618
						local delta = touch.location:sub(swipeStart) -- 623
						if swipeAxis == "none" and math.max( -- 623
							math.abs(delta.x), -- 624
							math.abs(delta.y) -- 624
						) >= 12 then -- 624
							swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical" -- 625
						end -- 625
						if pageRef.current then -- 625
							pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0 -- 627
						end -- 627
					end, -- 622
					onTapEnded = function(touch) -- 622
						local delta = touch.location:sub(swipeStart) -- 630
						swipeDragging = false -- 631
						if swipeBackPending then -- 631
							return -- 632
						end -- 632
						local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play" -- 633
						local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status)) -- 634
						local page = pageRef.current -- 635
						if not page or not requested and page.x == 0 then -- 635
							return -- 636
						end -- 636
						local duration = (leaving or App.reducedMotion) and 0 or 0.16 -- 637
						local revision = swipeRevision -- 638
						swipeBackPending = true -- 639
						if not leaving then -- 639
							page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad)) -- 641
						end -- 641
						thread(function() -- 643
							sleep(duration) -- 644
							if disposed or revision ~= swipeRevision or not host.parent then -- 644
								return -- 645
							end -- 645
							swipeBackPending = false -- 646
							if requested and host.visible and HttpServer.wsConnectionCount == 0 then -- 646
								refresh() -- 647
								goBack() -- 647
							else -- 647
								page.position = Vec2.zero -- 648
							end -- 648
						end) -- 643
					end -- 629
				} -- 629
			), -- 629
			React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279572250, bottomColor = 4278848011}) -- 629
		) -- 629
		local ____React_createElement_68 = React.createElement -- 629
		local ____array_67 = __TS__SparseArrayNew( -- 629
			"node", -- 629
			{tag = "remix-page", ref = pageRef}, -- 629
			React.createElement( -- 629
				"clip-node", -- 629
				{ -- 629
					x = left + 16, -- 629
					y = headerY, -- 629
					width = headerTitleWidth, -- 629
					height = 44, -- 629
					anchorX = 0, -- 629
					anchorY = 0, -- 629
					stencil = React.createElement( -- 629
						"draw-node", -- 629
						{x = headerTitleWidth / 2, y = 22}, -- 629
						React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295}) -- 629
					) -- 629
				}, -- 629
				React.createElement("label", { -- 629
					tag = "remix-title", -- 629
					x = 0, -- 629
					y = 22, -- 629
					anchorX = 0, -- 629
					fontName = fontName, -- 629
					fontSize = 20, -- 629
					text = "REMIX · " .. options.entry.title, -- 629
					color3 = 16052712 -- 629
				}) -- 629
			), -- 629
			React.createElement( -- 629
				"node", -- 629
				{ -- 629
					tag = "remix-back", -- 629
					x = headerBackX, -- 629
					y = headerY, -- 629
					width = backWidth, -- 629
					height = 44, -- 629
					anchorX = 0, -- 629
					anchorY = 0, -- 629
					touchEnabled = true, -- 629
					swallowTouches = true, -- 629
					onTapped = goBack -- 629
				}, -- 629
				React.createElement("label", { -- 629
					x = backWidth, -- 629
					y = 22, -- 629
					anchorX = 1, -- 629
					fontName = fontName, -- 629
					fontSize = 18, -- 629
					text = backText, -- 629
					color3 = 16763955 -- 629
				}) -- 629
			) -- 629
		) -- 629
		local ____React_createElement_34 = React.createElement -- 629
		local ____array_33 = __TS__SparseArrayNew( -- 629
			"node", -- 629
			{ -- 629
				tag = "remix-model-config", -- 629
				x = headerSettingsX, -- 629
				y = headerY + 6, -- 629
				width = modelButtonWidth, -- 629
				height = 32, -- 629
				anchorX = 0, -- 629
				anchorY = 0, -- 629
				touchEnabled = true, -- 629
				swallowTouches = true, -- 629
				onTapped = configureLLM -- 629
			}, -- 629
			React.createElement(RoundedSurface, { -- 629
				width = modelButtonWidth, -- 629
				height = 32, -- 629
				radius = 16, -- 629
				topColor = 858927927, -- 629
				bottomColor = 857151514, -- 629
				borderWidth = 1, -- 629
				borderColor = needsLLMSetup and colors.brand or colors.border -- 629
			}), -- 629
			React.createElement("label", { -- 629
				x = modelButtonWidth / 2, -- 629
				y = 16, -- 629
				fontName = fontName, -- 629
				fontSize = 11, -- 629
				text = modelLabel, -- 629
				color3 = (needsLLMSetup or switchPending) and 16763955 or 11055037 -- 629
			}) -- 629
		) -- 629
		local ____needsLLMSetup_32 -- 666
		if needsLLMSetup then -- 666
			____needsLLMSetup_32 = React.createElement( -- 666
				"draw-node", -- 666
				{x = modelButtonWidth - 4, y = 28}, -- 666
				React.createElement("dot-shape", {radius = 3, color = 4294954035}) -- 666
			) -- 666
		else -- 666
			____needsLLMSetup_32 = nil -- 666
		end -- 666
		__TS__SparseArrayPush(____array_33, ____needsLLMSetup_32) -- 666
		__TS__SparseArrayPush( -- 666
			____array_67, -- 666
			____React_createElement_34(__TS__SparseArraySpread(____array_33)), -- 666
			React.createElement( -- 666
				"node", -- 666
				{ -- 666
					tag = "remix-status", -- 666
					x = compactHeaderStatus and headerStatusX or 0, -- 666
					y = compactHeaderStatus and headerY or messageTop - statusHeight / 2, -- 666
					width = compactHeaderStatus and headerStatusWidth or width, -- 666
					height = compactHeaderStatus and 44 or statusHeight, -- 666
					anchorX = 0, -- 666
					anchorY = 0 -- 666
				}, -- 666
				React.createElement(DoraMascot, { -- 666
					state = mascotState, -- 666
					x = compactHeaderStatus and 16 or mascotX, -- 666
					y = compactHeaderStatus and 20 or statusHeight / 2 - 2 + standaloneStatusContentLift, -- 666
					size = compactHeaderStatus and 30 or mascotSize, -- 666
					animationStartedAt = mascotAnimationStartedAt -- 666
				}), -- 666
				React.createElement( -- 666
					"clip-node", -- 666
					{ -- 666
						tag = "remix-status-clip", -- 666
						x = renderedStatusX, -- 666
						y = renderedStatusY - 22, -- 666
						width = renderedStatusWidth, -- 666
						height = 44, -- 666
						anchorX = 0, -- 666
						anchorY = 0, -- 666
						stencil = React.createElement( -- 666
							"draw-node", -- 666
							{x = renderedStatusWidth / 2, y = 22}, -- 666
							React.createElement("rect-shape", {width = renderedStatusWidth, height = 44, fillColor = 4294967295}) -- 666
						) -- 666
					}, -- 666
					React.createElement( -- 666
						"label", -- 666
						{ -- 666
							tag = "remix-status-text", -- 666
							x = 0, -- 666
							y = 22, -- 666
							anchorX = 0, -- 666
							fontName = fontName, -- 666
							fontSize = compactHeaderStatus and math.floor(13 * fontScale) or math.floor(15 * fontScale), -- 666
							text = statusText, -- 666
							textWidth = -1, -- 666
							alignment = "Left", -- 666
							color3 = phase == "failed" and 16739179 or 16763955 -- 666
						} -- 666
					), -- 666
					React.createElement("label", { -- 666
						tag = "remix-thinking-text", -- 666
						x = 0, -- 666
						y = 6, -- 666
						anchorX = 0, -- 666
						fontName = fontName, -- 666
						fontSize = thinkingFontSize, -- 666
						text = renderedThinkingText, -- 666
						textWidth = -1, -- 666
						alignment = "Left", -- 666
						color3 = colors.muted -- 666
					}) -- 666
				) -- 666
			) -- 666
		) -- 666
		local ____temp_43 -- 682
		if questionnaire and question then -- 682
			local ____React_createElement_42 = React.createElement -- 682
			local ____array_41 = __TS__SparseArrayNew( -- 682
				"node", -- 682
				{ -- 682
					tag = "remix-questionnaire", -- 682
					x = left + 16, -- 682
					y = bottom + 164, -- 682
					width = contentWidth, -- 682
					height = questionCardHeight, -- 682
					anchorX = 0, -- 682
					anchorY = 0 -- 682
				}, -- 682
				React.createElement(RoundedSurface, { -- 682
					width = contentWidth, -- 682
					height = questionCardHeight, -- 682
					radius = 20, -- 682
					topColor = 4280822318, -- 682
					bottomColor = 4279637785, -- 682
					borderWidth = 1, -- 682
					borderColor = 4282927694, -- 682
					shadow = true -- 682
				}), -- 682
				React.createElement( -- 682
					"label", -- 682
					{ -- 682
						x = 16, -- 682
						y = questionCardHeight - 30, -- 682
						anchorX = 0, -- 682
						fontName = fontName, -- 682
						fontSize = 13, -- 682
						text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title, -- 682
						textWidth = contentWidth - 32, -- 682
						alignment = "Left", -- 682
						color3 = 16763955 -- 682
					} -- 682
				), -- 682
				React.createElement("label", { -- 682
					tag = "remix-question-prompt", -- 682
					x = 16, -- 682
					y = questionCardHeight - 75, -- 682
					anchorX = 0, -- 682
					fontName = fontName, -- 682
					fontSize = 16, -- 682
					text = question.prompt, -- 682
					textWidth = questionPromptWidth, -- 682
					alignment = "Left", -- 682
					color3 = 16052712 -- 682
				}), -- 682
				question.type ~= "text" and __TS__ArrayMap( -- 686
					__TS__ArraySlice(question.options or ({}), 0, 8), -- 686
					function(____, option, optionIndex) return React.createElement( -- 686
						ChoiceButton, -- 686
						{ -- 686
							tag = (("remix-question-" .. question.id) .. "-option-") .. option.id, -- 686
							x = 16, -- 686
							y = questionAnswerTop - 40 - optionIndex * 43, -- 686
							width = contentWidth - 32, -- 686
							text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""), -- 686
							selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0, -- 686
							onTapped = function() -- 686
								local selected = questionnaireSelections[question.id] or ({}) -- 692
								local ____question_id_38 = question.id -- 693
								local ____temp_37 -- 693
								if question.type == "single_choice" then -- 693
									____temp_37 = {option.id} -- 694
								else -- 694
									local ____temp_36 -- 695
									if __TS__ArrayIndexOf(selected, option.id) >= 0 then -- 695
										____temp_36 = __TS__ArrayFilter( -- 695
											selected, -- 695
											function(____, id) return id ~= option.id end -- 695
										) -- 695
									else -- 695
										local ____array_35 = __TS__SparseArrayNew(table.unpack(selected)) -- 695
										__TS__SparseArrayPush(____array_35, option.id) -- 695
										____temp_36 = {__TS__SparseArraySpread(____array_35)} -- 695
									end -- 695
									____temp_37 = ____temp_36 -- 695
								end -- 695
								questionnaireSelections[____question_id_38] = ____temp_37 -- 693
								render() -- 696
							end -- 691
						} -- 691
					) end -- 691
				) or React.createElement("node", { -- 691
					tag = "remix-question-input", -- 691
					ref = inputRef, -- 691
					x = 16, -- 691
					y = questionAnswerTop - 92, -- 691
					width = contentWidth - 32, -- 691
					height = 92, -- 691
					anchorX = 0, -- 691
					anchorY = 0, -- 691
					onMount = promptInput.mount -- 691
				}) -- 691
			) -- 691
			local ____questionHasBack_39 -- 700
			if questionHasBack then -- 700
				____questionHasBack_39 = React.createElement( -- 700
					ActionButton, -- 700
					{ -- 700
						tag = "remix-question-back", -- 700
						x = 16, -- 700
						y = 12, -- 700
						width = questionBackWidth, -- 700
						text = zh and "上一步" or "Back", -- 700
						onTapped = function() -- 700
							questionIndex = questionIndex - 1 -- 700
							render() -- 700
						end -- 700
					} -- 700
				) -- 700
			else -- 700
				____questionHasBack_39 = nil -- 700
			end -- 700
			__TS__SparseArrayPush(____array_41, ____questionHasBack_39) -- 700
			local ____questionCanSkip_40 -- 701
			if questionCanSkip then -- 701
				____questionCanSkip_40 = React.createElement( -- 701
					ActionButton, -- 701
					{ -- 701
						tag = "remix-question-skip", -- 701
						x = questionSkipX, -- 701
						y = 12, -- 701
						width = questionSkipWidth, -- 701
						text = zh and "跳过" or "Skip", -- 701
						onTapped = function() return advanceQuestionnaire(true) end -- 701
					} -- 701
				) -- 701
			else -- 701
				____questionCanSkip_40 = nil -- 701
			end -- 701
			__TS__SparseArrayPush( -- 701
				____array_41, -- 701
				____questionCanSkip_40, -- 701
				React.createElement( -- 701
					ActionButton, -- 702
					{ -- 702
						tag = "remix-question-submit", -- 702
						x = questionSubmitX, -- 702
						y = 12, -- 702
						width = contentWidth - questionSubmitX - 16, -- 702
						text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"), -- 702
						primary = true, -- 702
						onTapped = function() -- 702
							if not dismissedComposition then -- 702
								advanceQuestionnaire() -- 704
							end -- 704
							dismissedComposition = false -- 704
						end -- 704
					} -- 704
				) -- 704
			) -- 704
			____temp_43 = ____React_createElement_42(__TS__SparseArraySpread(____array_41)) -- 704
		else -- 704
			____temp_43 = nil -- 705
		end -- 705
		__TS__SparseArrayPush(____array_67, ____temp_43) -- 705
		local ____temp_44 -- 706
		if visibleError ~= "" then -- 706
			____temp_44 = React.createElement( -- 706
				"label", -- 706
				{ -- 706
					tag = "remix-error", -- 706
					x = left + 20, -- 706
					y = bottom + (questionnaire and 144 or layoutComposerTop + composerGap), -- 706
					anchorX = 0, -- 706
					anchorY = 0, -- 706
					fontName = fontName, -- 706
					fontSize = 13, -- 706
					text = visibleError, -- 706
					textWidth = contentWidth, -- 706
					alignment = "Left", -- 706
					color3 = 16739179, -- 706
					onMount = function(label) -- 706
						errorLabel = label -- 706
					end -- 706
				} -- 706
			) -- 706
		else -- 706
			____temp_44 = nil -- 706
		end -- 706
		__TS__SparseArrayPush(____array_67, ____temp_44) -- 706
		local ____temp_48 -- 707
		if questionnaire == nil and voiceActive then -- 707
			local ____React_createElement_47 = React.createElement -- 707
			local ____array_46 = __TS__SparseArrayNew( -- 707
				"node", -- 707
				nil, -- 707
				React.createElement(ActionButton, { -- 707
					tag = "remix-voice-cancel", -- 707
					x = left + 16, -- 707
					y = bottom + layoutModeBottom, -- 707
					width = 64, -- 707
					height = 40, -- 707
					text = zh and "取消" or "Cancel", -- 707
					onTapped = voice.cancel -- 707
				}), -- 707
				React.createElement( -- 707
					"label", -- 707
					{ -- 707
						x = left + 16 + contentWidth / 2, -- 707
						y = bottom + layoutModeBottom + 26, -- 707
						fontName = fontName, -- 707
						fontSize = 13, -- 707
						text = ellipsizeSingleLine(voiceLabel, meterWidth, 13), -- 707
						color3 = 11055037 -- 707
					} -- 707
				), -- 707
				React.createElement( -- 707
					"node", -- 707
					{x = left + 16 + (contentWidth - meterWidth) / 2, y = bottom + layoutModeBottom + 11}, -- 707
					React.createElement( -- 707
						"draw-node", -- 707
						nil, -- 707
						React.createElement("rect-shape", {centerX = meterWidth / 2, width = meterWidth, height = 3, fillColor = colors.border}) -- 707
					), -- 707
					React.createElement( -- 707
						"node", -- 707
						{tag = "remix-voice-level", ref = voiceMeter, scaleX = displayedVoiceLevel, visible = displayedVoiceLevel > 0}, -- 707
						React.createElement( -- 707
							"draw-node", -- 707
							nil, -- 707
							React.createElement("rect-shape", {centerX = meterWidth / 2, width = meterWidth, height = 3, fillColor = colors.brand}) -- 707
						) -- 707
					) -- 707
				) -- 707
			) -- 707
			local ____temp_45 -- 718
			if voicePhase == "waiting" or voicePhase == "recording" then -- 718
				____temp_45 = React.createElement(ActionButton, { -- 718
					tag = "remix-voice-finish", -- 718
					x = left + 16 + contentWidth - 64, -- 718
					y = bottom + layoutModeBottom, -- 718
					width = 64, -- 718
					height = 40, -- 718
					text = zh and "完成" or "Done", -- 718
					onTapped = voice.finish -- 718
				}) -- 718
			else -- 718
				____temp_45 = nil -- 720
			end -- 720
			__TS__SparseArrayPush(____array_46, ____temp_45) -- 720
			____temp_48 = ____React_createElement_47(__TS__SparseArraySpread(____array_46)) -- 720
		else -- 720
			____temp_48 = nil -- 721
		end -- 721
		__TS__SparseArrayPush(____array_67, ____temp_48) -- 721
		local ____temp_49 -- 722
		if questionnaire == nil and not voiceActive then -- 722
			____temp_49 = React.createElement( -- 722
				"node", -- 722
				nil, -- 722
				React.createElement( -- 722
					ChoiceButton, -- 723
					{ -- 723
						tag = "remix-mode-plan", -- 723
						x = modeStartX, -- 723
						y = bottom + layoutModeBottom, -- 723
						width = modeWidth, -- 723
						text = zh and "计划" or "Plan", -- 723
						selected = workMode == "plan", -- 723
						disabled = not canSubmit(), -- 723
						onTapped = function() return changeWorkMode("plan") end -- 723
					} -- 723
				), -- 723
				React.createElement( -- 723
					ChoiceButton, -- 724
					{ -- 724
						tag = "remix-mode-code", -- 724
						x = modeStartX + modeWidth + composerGap, -- 724
						y = bottom + layoutModeBottom, -- 724
						width = modeCodeWidth, -- 724
						text = zh and "执行" or "Code", -- 724
						selected = workMode == "code", -- 724
						disabled = not canSubmit(), -- 724
						onTapped = function() return changeWorkMode("code") end -- 724
					} -- 724
				) -- 724
			) -- 724
		else -- 724
			____temp_49 = nil -- 725
		end -- 725
		__TS__SparseArrayPush(____array_67, ____temp_49) -- 725
		local ____temp_50 -- 726
		if questionnaire == nil and not keptInput then -- 726
			____temp_50 = React.createElement("node", { -- 726
				tag = "remix-input", -- 726
				ref = inputRef, -- 726
				x = left + 16, -- 726
				y = bottom + layoutComposerBottom, -- 726
				width = inputWidth, -- 726
				height = layoutComposerHeight, -- 726
				anchorX = 0, -- 726
				anchorY = 0, -- 726
				onMount = promptInput.mount -- 726
			}) -- 726
		else -- 726
			____temp_50 = nil -- 727
		end -- 727
		__TS__SparseArrayPush(____array_67, ____temp_50) -- 727
		local ____temp_51 -- 728
		if voiceEnabled and questionnaire == nil then -- 728
			____temp_51 = React.createElement( -- 728
				ActionButton, -- 728
				{ -- 728
					tag = "remix-voice", -- 728
					x = left + 16 + inputWidth + composerGap, -- 728
					y = bottom + layoutComposerBottom, -- 728
					width = 60, -- 728
					height = layoutComposerHeight, -- 728
					text = zh and "语音" or "Voice", -- 728
					disabled = voiceActive or not canSubmit(), -- 728
					onTapped = startVoice -- 728
				} -- 728
			) -- 728
		else -- 728
			____temp_51 = nil -- 730
		end -- 730
		__TS__SparseArrayPush(____array_67, ____temp_51) -- 730
		local ____temp_64 -- 731
		if stopping or questionnaire == nil then -- 731
			local ____React_createElement_63 = React.createElement -- 731
			local ____ActionButton_62 = ActionButton -- 731
			local ____temp_57 = stopping and "remix-stop" or "remix-send" -- 731
			local ____temp_58 = left + 16 + inputWidth + composerGap + voiceWidth -- 732
			local ____temp_59 = bottom + layoutComposerBottom -- 732
			local ____temp_60 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send") -- 733
			local ____temp_61 = not stopping -- 734
			local ____stopping_56 -- 734
			if stopping then -- 734
				____stopping_56 = stopRequested or (state and state.currentTaskFinalizing) == true -- 734
			else -- 734
				____stopping_56 = voiceActive or not canSubmit() -- 734
			end -- 734
			____temp_64 = ____React_createElement_63( -- 734
				____ActionButton_62, -- 731
				{ -- 731
					tag = ____temp_57, -- 731
					x = ____temp_58, -- 731
					y = ____temp_59, -- 731
					width = composerActionWidth, -- 731
					height = layoutComposerHeight, -- 731
					text = ____temp_60, -- 731
					primary = ____temp_61, -- 731
					danger = stopping, -- 731
					disabled = ____stopping_56, -- 731
					onTapped = function() -- 731
						if stopping then -- 731
							stop() -- 735
						elseif not dismissedComposition then -- 735
							send() -- 735
						end -- 735
						dismissedComposition = false -- 735
					end -- 735
				} -- 735
			) -- 735
		else -- 735
			____temp_64 = nil -- 735
		end -- 735
		__TS__SparseArrayPush(____array_67, ____temp_64) -- 735
		local ____temp_65 -- 736
		if phase == "done" and canShare and not voiceActive then -- 736
			____temp_65 = React.createElement( -- 736
				ActionButton, -- 736
				{ -- 736
					tag = "remix-share", -- 736
					x = left + 16, -- 736
					y = bottom + layoutModeBottom + 48, -- 736
					width = playWidth, -- 736
					height = 40, -- 736
					text = zh and "分享作品" or "Share game", -- 736
					onTapped = function() -- 736
						if not host.visible or packagePanel or HttpServer.wsConnectionCount > 0 then -- 736
							return -- 737
						end -- 737
						blurInput() -- 738
						notifyProjectChanged() -- 738
						packagePanel = startPackagePanel({ -- 739
							mode = "share", -- 739
							entry = options.entry, -- 739
							onClosed = function() -- 739
								packagePanel = nil -- 739
							end -- 739
						}) -- 739
					end -- 736
				} -- 736
			) -- 736
		else -- 736
			____temp_65 = nil -- 740
		end -- 740
		__TS__SparseArrayPush(____array_67, ____temp_65) -- 740
		local ____temp_66 -- 741
		if phase == "done" and not voiceActive then -- 741
			____temp_66 = React.createElement( -- 741
				ActionButton, -- 741
				{ -- 741
					tag = "remix-play", -- 741
					x = playX, -- 741
					y = bottom + layoutModeBottom + 48, -- 741
					width = playWidth, -- 741
					height = 40, -- 741
					text = zh and "立即试玩" or "Play now", -- 741
					primary = true, -- 741
					onTapped = function() -- 741
						if not host.visible or HttpServer.wsConnectionCount > 0 then -- 741
							return -- 741
						end -- 741
						blurInput() -- 741
						notifyProjectChanged() -- 741
						host.visible = false -- 741
						onPlay(options.entry) -- 741
					end -- 741
				} -- 741
			) -- 741
		else -- 741
			____temp_66 = nil -- 741
		end -- 741
		__TS__SparseArrayPush(____array_67, ____temp_66) -- 741
		__TS__SparseArrayPush( -- 741
			____array_69, -- 741
			____React_createElement_68(__TS__SparseArraySpread(____array_67)) -- 741
		) -- 741
		local scene = ____toNode_71(____React_createElement_70(__TS__SparseArraySpread(____array_69))) -- 600
		if scene then -- 600
			host:addChild(scene) -- 745
			if keptInput then -- 745
				keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom) -- 747
				keptInput.width = inputWidth -- 748
				keptInput.height = layoutComposerHeight -- 749
				local ____opt_72 = pageRef.current -- 749
				if ____opt_72 ~= nil then -- 749
					____opt_72:addChild(keptInput) -- 750
				end -- 750
			end -- 750
			if not questionnaire then -- 750
				transcript.node.position = Vec2( -- 753
					left + 16, -- 753
					bottom + getTranscriptBottom() -- 753
				) -- 753
				local ____opt_74 = pageRef.current -- 753
				if ____opt_74 ~= nil then -- 753
					____opt_74:addChild(transcript.node) -- 754
				end -- 754
				updateTranscript() -- 755
			end -- 755
		end -- 755
		if restoreInputFocus and inputRef.current and not keptInput then -- 755
			promptInput.focus(false) -- 758
		end -- 758
		if keptInput then -- 758
			promptInput.refresh() -- 759
		end -- 759
		shellRevision = getShellRevision() -- 760
		displayRevision = remixDisplayRevision(detail) -- 761
	end -- 452
	attachGamepad( -- 764
		host, -- 764
		{ -- 764
			initialTag = "remix-input", -- 765
			onBack = function() -- 766
				if promptInput.isFocused() then -- 766
					blurInput() -- 766
				else -- 766
					goBack() -- 766
				end -- 766
			end, -- 766
			onScroll = function(amount) return transcript:scrollBy(amount) end, -- 767
			onActivate = function(target) -- 768
				if target.tag == "remix-input" or target.tag == "remix-question-input" then -- 768
					target:emit("GamepadActivate") -- 769
				else -- 769
					if promptInput.isComposing() then -- 769
						blurInput() -- 771
						return -- 771
					end -- 771
					blurInput() -- 772
					dismissedComposition = false -- 773
					target:emit("Tapped") -- 774
				end -- 774
			end -- 768
		} -- 768
	) -- 768
	host:schedule(function(dt) -- 778
		if voiceForeground and voice.phase() ~= "idle" then -- 778
			if not host.visible or packagePanel or HttpServer.wsConnectionCount > 0 or not canSubmit() then -- 778
				voice.cancel() -- 780
			else -- 780
				voice.tick() -- 781
			end -- 781
		end -- 781
		local meter = voiceMeter.current -- 783
		if meter then -- 783
			local target = voice.level() -- 785
			displayedVoiceLevel = displayedVoiceLevel + (target - displayedVoiceLevel) * math.min(1, dt / 0.08) -- 786
			meter.scaleX = displayedVoiceLevel -- 787
			meter.visible = displayedVoiceLevel >= 0.002 -- 788
		else -- 788
			displayedVoiceLevel = 0 -- 789
		end -- 789
		pollElapsed = pollElapsed + dt -- 790
		if pollElapsed < 0.25 then -- 790
			return false -- 791
		end -- 791
		pollElapsed = 0 -- 792
		refresh() -- 793
		if swipeDragging or swipeBackPending then -- 793
			return false -- 794
		end -- 794
		if backNoticeUntil > 0 and App.runningTime >= backNoticeUntil then -- 794
			backNoticeUntil = 0 -- 796
			render() -- 797
			return false -- 798
		end -- 798
		local next = remixDisplayRevision(detail) -- 800
		if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then -- 800
			render() -- 801
		elseif displayRevision ~= next then -- 801
			updateTranscript() -- 802
		end -- 802
		return false -- 803
	end) -- 778
	host:onAppChange(function(setting) -- 805
		if setting == "Locale" then -- 805
			zh = (string.match(App.locale, "^zh")) ~= nil -- 806
		end -- 806
		if setting == "Size" or setting == "Locale" then -- 806
			render() -- 807
		end -- 807
	end) -- 805
	host:onAppEvent(function(event) -- 809
		if event == "BackButton" then -- 809
			if promptInput.isFocused() then -- 809
				blurInput() -- 810
			else -- 810
				goBack() -- 810
			end -- 810
		elseif event == "WillEnterBackground" or event == "DidEnterBackground" then -- 810
			voiceForeground = false -- 812
			if voice.phase() ~= "opening" then -- 812
				voice.cancel() -- 815
			end -- 815
			blurInput() -- 816
		elseif event == "DidEnterForeground" then -- 816
			voiceForeground = true -- 817
		end -- 817
	end) -- 809
	host:onCleanup(function() -- 819
		if packagePanel ~= nil then -- 819
			packagePanel:removeFromParent(true) -- 820
		end -- 820
		packagePanel = nil -- 821
		disposed = true -- 822
		voice.cancel() -- 822
		blurInput() -- 822
	end) -- 819
	host:slot( -- 824
		"SuspendLocalUI", -- 824
		function() -- 824
			voice.cancel() -- 824
			blurInput() -- 824
		end -- 824
	) -- 824
	host:slot( -- 825
		"ResumeLocalUI", -- 825
		function() -- 825
			llmConfigs = services.getLLMConfigSummaries() -- 825
			voiceEnabled = getVoiceKey() ~= nil -- 825
			refresh() -- 825
			render() -- 825
		end -- 825
	) -- 825
	render() -- 826
	if needsLLMSetup then -- 826
		thread(function() -- 827
			sleep(0) -- 827
			if not disposed and host.parent then -- 827
				configureLLM() -- 827
			end -- 827
		end) -- 827
	end -- 827
	return host -- 828
end -- 105
return ____exports -- 105