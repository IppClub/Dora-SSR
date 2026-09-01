-- [tsx]: Remix.tsx
local ____lualib = require("lualib_bundle")
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____DoraX = require("DoraX")
local React = ____DoraX.React
local reference = ____DoraX.reference
local toNode = ____DoraX.toNode
local ____Dora = require("Dora")
local App = ____Dora.App
local DB = ____Dora.DB
local Director = ____Dora.Director
local Ease = ____Dora.Ease
local HttpServer = ____Dora.HttpServer
local Label = ____Dora.Label
local Move = ____Dora.Move
local Node = ____Dora.Node
local sleep = ____Dora.sleep
local thread = ____Dora.thread
local Vec2 = ____Dora.Vec2
local AgentSession = require("Agent.Session")
local ____Utils = require("Agent.Utils")
local getActiveLLMConfig = ____Utils.getActiveLLMConfig
local getLLMConfig = ____Utils.getLLMConfig
local getLLMConfigSummaries = ____Utils.getLLMConfigSummaries
local safeJsonEncode = ____Utils.safeJsonEncode
local ____RemixModel = require("Dev.Mobile.RemixModel")
local buildQuestionnaireAnswers = ____RemixModel.buildQuestionnaireAnswers
local canLeaveRemix = ____RemixModel.canLeaveRemix
local isQuestionAnswered = ____RemixModel.isQuestionAnswered
local resolveRemixPhase = ____RemixModel.resolveRemixPhase
local resolveRemixThinkingStatus = ____RemixModel.resolveRemixThinkingStatus
local resolveRemixWorkMode = ____RemixModel.resolveRemixWorkMode
local ____Mascot = require("Dev.Mobile.Mascot")
local DoraMascot = ____Mascot.DoraMascot
local ____Accessibility = require("Dev.Mobile.Accessibility")
local mobileFontScale = ____Accessibility.mobileFontScale
local ____FeedModel = require("Dev.Mobile.FeedModel")
local resolveFeedGesture = ____FeedModel.resolveFeedGesture
local ____RemixTranscript = require("Dev.Mobile.RemixTranscript")
local createRemixTranscript = ____RemixTranscript.createRemixTranscript
local remixDisplayRevision = ____RemixTranscript.remixDisplayRevision
local ____RemixHistory = require("Dev.Mobile.RemixHistory")
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS
local ____TextInput = require("Dev.Mobile.TextInput")
local createTextInput = ____TextInput.createTextInput
local inputLength = ____TextInput.inputLength
local inputSlice = ____TextInput.inputSlice
local ____Visual = require("Dev.Mobile.Visual")
local RoundedSurface = ____Visual.RoundedSurface
local VerticalGradient = ____Visual.VerticalGradient
local fontName = "sarasa-mono-sc-regular"
local colors = {
    background = 4278914322,
    panel = 4279704614,
    text = 4294242792,
    muted = 4289245117,
    brand = 4294954035,
    border = 4281613128,
    danger = 4294929259
}
local composerGap = 12
local composerBottom = 76
local composerHeight = 60
local composerActionWidth = 82
local modeBottom = composerBottom + composerHeight + composerGap
local composerTop = modeBottom + 40
local transcriptBottom = composerTop + composerGap
local statusHeight = 64
local function ellipsizeSingleLine(text, width, fontSize)
    if text == "" then
        return ""
    end
    local measure = Label(fontName, fontSize, true)
    if not measure then
        return text
    end
    measure.visible = false
    measure.textWidth = -1
    local function fits(value)
        measure.text = value
        return measure.width <= width
    end
    if fits(text) then
        measure:cleanup()
        return text
    end
    local low, high = 0, inputLength(text)
    while low < high do
        local middle = math.floor((low + high + 1) / 2)
        if fits(inputSlice(text, 0, middle) .. "…") then
            low = middle
        else
            high = middle - 1
        end
    end
    local result = inputSlice(text, 0, low) .. "…"
    measure:cleanup()
    return result
end
local function ActionButton(props)
    local height = props.height or 46
    return React.createElement(
        "node",
        {
            tag = props.tag,
            x = props.x,
            y = props.y,
            width = props.width,
            height = height,
            anchorX = 0,
            anchorY = 0,
            opacity = props.disabled and 0.45 or 1,
            touchEnabled = not props.disabled,
            swallowTouches = true,
            onTapped = props.onTapped
        },
        React.createElement(RoundedSurface, {
            width = props.width,
            height = height,
            radius = 14,
            topColor = props.danger and 4294935941 or (props.primary and 4294958955 or 4280889664),
            bottomColor = props.danger and 4292824662 or (props.primary and 4294950190 or 4279704871),
            borderWidth = 1,
            borderColor = props.danger and colors.danger or (props.primary and 4294958435 or colors.border),
            shadow = props.primary or props.danger
        }),
        React.createElement("label", {
            x = props.width / 2,
            y = height / 2,
            fontName = fontName,
            fontSize = 15,
            text = props.text,
            color3 = props.primary and 1512202 or 16052712
        })
    )
end
local function ChoiceButton(props)
    local ____React_createElement_5 = React.createElement
    local ____temp_3 = {
        tag = props.tag,
        x = props.x,
        y = props.y,
        width = props.width,
        height = 40,
        anchorX = 0,
        anchorY = 0,
        opacity = props.disabled and 0.45 or 1,
        touchEnabled = not props.disabled,
        swallowTouches = true,
        onTapped = props.onTapped
    }
    local ____React_createElement_result_4 = React.createElement(RoundedSurface, {
        width = props.width,
        height = 40,
        radius = 12,
        topColor = props.selected and 4294958955 or 4280297526,
        bottomColor = props.selected and 4294950190 or 4279244061,
        borderWidth = 1,
        borderColor = props.selected and 4294958435 or colors.border
    })
    local ____React_createElement_2 = React.createElement
    local ____array_1 = __TS__SparseArrayNew(
        "draw-node",
        {tag = props.tag and props.tag .. "-radio" or nil, x = 17, y = 20},
        React.createElement("dot-shape", {radius = 7, color = props.selected and 4279702282 or 4289245117}),
        React.createElement("dot-shape", {radius = 5, color = props.selected and 4294954824 or 4279704614})
    )
    local ____props_selected_0
    if props.selected then
        ____props_selected_0 = React.createElement(
            "draw-node",
            {tag = props.tag and props.tag .. "-radio-dot" or nil},
            React.createElement("dot-shape", {radius = 2.5, color = 4279702282})
        )
    else
        ____props_selected_0 = nil
    end
    __TS__SparseArrayPush(____array_1, ____props_selected_0)
    return ____React_createElement_5(
        "node",
        ____temp_3,
        ____React_createElement_result_4,
        ____React_createElement_2(__TS__SparseArraySpread(____array_1)),
        React.createElement("label", {
            x = 32,
            y = 20,
            anchorX = 0,
            fontName = fontName,
            fontSize = 14,
            text = props.text,
            textWidth = props.width - 44,
            alignment = "Left",
            color3 = props.selected and 1512202 or 16052712
        })
    )
end
function ____exports.startMobileRemix(options)
    local host, send, getTranscriptActions, render
    local onBack = options.onBack
    local onPlay = options.onPlay
    local services = options.services or ({
        createSession = AgentSession.createSession,
        getSession = function(id) return AgentSession.getSession(id, {recentRounds = REMIX_HISTORY_ROUNDS, currentTaskStepsOnly = true}) end,
        setWorkMode = AgentSession.setWorkMode,
        sendPrompt = AgentSession.sendPrompt,
        respondQuestionnaire = AgentSession.respondQuestionnaire,
        stopSessionTask = AgentSession.stopSessionTask,
        continuePrompt = AgentSession.continuePrompt,
        getActiveLLMConfig = getActiveLLMConfig,
        getLLMConfig = getLLMConfig,
        getLLMConfigSummaries = getLLMConfigSummaries
    })
    local zh = (string.match(App.locale, "^zh")) ~= nil
    local projectRoot = options.entry.workDir or ""
    local created = services.createSession(projectRoot, options.entry.title)
    local sessionId = created.success and created.session.id or 0
    local detail = sessionId > 0 and services.getSession(sessionId) or ({success = false, message = created.success and "session unavailable" or created.message})
    local draft = ""
    local ____error = created.success and "" or created.message
    local pollElapsed = 0
    local stopRequested = false
    local selectedLLMConfigId = 0
    local questionnaireId = 0
    local questionIndex = 0
    local llmConfigs = services.getLLMConfigSummaries()
    local modelPickerOpen = false
    local questionnaireSelections = {}
    local questionnaireTexts = {}
    local inputRef = reference()
    local disposed = false
    local dismissedComposition = false
    local swipeBackPending = false
    local swipeDragging = false
    local swipeRevision = 0
    local projectChangeNotified = false
    local function currentQuestion()
        local ____detail_success_8
        if detail.success then
            local ____opt_6 = detail.pendingQuestionnaire
            ____detail_success_8 = ____opt_6 and ____opt_6.schema.questions[questionIndex + 1]
        else
            ____detail_success_8 = nil
        end
        return ____detail_success_8
    end
    local promptInput = createTextInput({
        fontSize = math.floor(16 * mobileFontScale),
        getText = function()
            local question = currentQuestion()
            return question and (questionnaireTexts[question.id] or "") or draft
        end,
        setText = function(text)
            local question = currentQuestion()
            if question then
                questionnaireTexts[question.id] = text
            else
                draft = text
            end
        end,
        getPlaceholder = function()
            local question = currentQuestion()
            return question and question.placeholder or (question and (zh and "输入回答…" or "Type an answer…") or (zh and "输入修改要求…" or "Describe a change…"))
        end,
        isEnabled = function() return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 end,
        onReturn = function(modified)
            if modified and not currentQuestion() then
                send()
                return true
            end
            return false
        end
    })
    local blurInput = promptInput.blur
    local rememberedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1")
    local ____temp_11
    if rememberedRows and #rememberedRows > 0 then
        ____temp_11 = tonumber(rememberedRows[1][1])
    else
        ____temp_11 = nil
    end
    local rememberedId = ____temp_11
    if rememberedId and __TS__ArraySome(
        llmConfigs,
        function(____, item) return item.id == rememberedId end
    ) then
        selectedLLMConfigId = rememberedId
    elseif #llmConfigs == 1 then
        selectedLLMConfigId = llmConfigs[1].id
    elseif #llmConfigs > 1 then
        modelPickerOpen = true
    else
        local activeConfig = services.getActiveLLMConfig()
        if activeConfig.success then
            selectedLLMConfigId = activeConfig.id
        end
    end
    host = Node()
    host.tag = "mobile-remix"
    host.scaleX = App.devicePixelRatio
    host.scaleY = App.devicePixelRatio
    host:addTo(Director.systemUI)
    local transcript = createRemixTranscript()
    local displayRevision = ""
    local shellRevision = ""
    local inputLayout = ""
    local mascotAnimationState
    local mascotAnimationStartedAt = App.runningTime
    local compactHeaderStatusActive = false
    local errorLabel
    local layoutTranscriptBottom = transcriptBottom
    local function getLayoutArea()
        return App.safeArea
    end
    local function getTranscriptBottom()
        return layoutTranscriptBottom + (errorLabel and errorLabel.height + composerGap or 0)
    end
    local function hasTranscriptContent()
        return detail.success and (#detail.messages > 0 or #detail.steps > 0)
    end
    local function getHeaderY(safe)
        local landscapeTopLift = safe.width >= 760 and safe.height < 500 and 28 or 0
        return safe.y + safe.height - 56 + landscapeTopLift
    end
    local function useCompactHeaderStatus(safe)
        return safe.width >= 760 and safe.height < 500 and hasTranscriptContent()
    end
    local function useCompactStandaloneStatus(safe)
        return safe.height >= 500 and hasTranscriptContent()
    end
    local function getTranscriptHeight(safe)
        local statusInset = useCompactHeaderStatus(safe) and composerGap or statusHeight + composerGap * 2 - (useCompactStandaloneStatus(safe) and 24 or 0)
        local available = math.max(
            40,
            getHeaderY(safe) - safe.y - getTranscriptBottom() - statusInset
        )
        return safe.width >= 760 and safe.height < 500 and not hasTranscriptContent() and 8 or available
    end
    local function getShellRevision()
        local ____detail_success_15
        if detail.success then
            local ____safeJsonEncode_14 = safeJsonEncode
            local ____array_13 = __TS__SparseArrayNew(
                detail.session.status,
                detail.session.workMode,
                detail.hasActivePlan,
                detail.pendingQuestionnaire or false,
                detail.session.currentTaskStatus or ""
            )
            local ____detail_session_currentTaskFinalizing_12 = detail.session.currentTaskFinalizing
            if ____detail_session_currentTaskFinalizing_12 == nil then
                ____detail_session_currentTaskFinalizing_12 = false
            end
            __TS__SparseArrayPush(
                ____array_13,
                ____detail_session_currentTaskFinalizing_12,
                stopRequested,
                hasTranscriptContent(),
                resolveRemixThinkingStatus(detail.steps, detail.session.currentTaskId) or ""
            )
            ____detail_success_15 = (____safeJsonEncode_14({__TS__SparseArraySpread(____array_13)})) or ""
        else
            ____detail_success_15 = detail.message
        end
        return ____detail_success_15
    end
    local function updateTranscript()
        local safe = getLayoutArea()
        transcript:update(
            detail,
            math.max(60, safe.width - 32),
            getTranscriptHeight(safe),
            mobileFontScale,
            zh,
            getTranscriptActions()
        )
        displayRevision = remixDisplayRevision(detail)
    end
    local function hasActiveTask()
        return detail.success and (detail.session.status == "RUNNING" or detail.session.status == "WAITING_USER" or detail.session.currentTaskStatus == "RUNNING" or detail.session.currentTaskStatus == "WAITING_USER" or detail.session.currentTaskFinalizing == true or detail.pendingQuestionnaire ~= nil)
    end
    local function notifyProjectChanged()
        if projectChangeNotified or not detail.success or not options.onProjectChanged then
            return
        end
        if not __TS__ArraySome(
            detail.steps,
            function(____, step) return step.files ~= nil and #step.files > 0 end
        ) then
            return
        end
        projectChangeNotified = true
        options.onProjectChanged(options.entry)
    end
    local function refresh()
        if sessionId > 0 then
            detail = services.getSession(sessionId)
        end
        if detail.success and not hasActiveTask() then
            stopRequested = false
        end
        if detail.success and detail.pendingQuestionnaire and detail.pendingQuestionnaire.id ~= questionnaireId then
            questionnaireId = detail.pendingQuestionnaire.id
            questionIndex = 0
        end
    end
    local function canSubmit()
        return detail.success and canLeaveRemix(detail.session.status) and detail.session.currentTaskStatus ~= "RUNNING" and detail.session.currentTaskStatus ~= "WAITING_USER" and not detail.session.currentTaskFinalizing and not detail.pendingQuestionnaire
    end
    local function resolveLLMConfig()
        return selectedLLMConfigId > 0 and services.getLLMConfig(selectedLLMConfigId) or services.getActiveLLMConfig()
    end
    local function changeWorkMode(workMode)
        if not host.visible or HttpServer.wsConnectionCount > 0 then
            return
        end
        refresh()
        if not canSubmit() or not detail.success then
            return
        end
        if resolveRemixWorkMode(detail.session) == workMode then
            return
        end
        local result = services.setWorkMode(sessionId, workMode)
        ____error = result.success and "" or (result.message or (zh and "切换模式失败" or "Could not change mode"))
        refresh()
        render()
    end
    send = function()
        if not host.visible or HttpServer.wsConnectionCount > 0 then
            return
        end
        refresh()
        if not canSubmit() or not detail.success or promptInput.isComposing() then
            return
        end
        local workMode = resolveRemixWorkMode(detail.session)
        local text = (string.match(draft, "^%s*(.-)%s*$")) or ""
        if sessionId <= 0 or text == "" then
            return
        end
        local config = resolveLLMConfig()
        if not config.success then
            ____error = zh and "请先在桌面 Web IDE 中配置并启用一个模型" or "Configure and activate a model in Web IDE first"
            render()
            return
        end
        selectedLLMConfigId = config.id
        local result = services.sendPrompt(
            sessionId,
            text,
            nil,
            workMode,
            config.id,
            config.config
        )
        if not result.success then
            ____error = result.message
        else
            draft = ""
            ____error = ""
        end
        refresh()
        render()
    end
    local function continueTask()
        if not host.visible or HttpServer.wsConnectionCount > 0 then
            return
        end
        refresh()
        if not detail.success or hasActiveTask() or detail.session.currentTaskStatus ~= "FAILED" and detail.session.currentTaskStatus ~= "STOPPED" or detail.session.currentTaskId == nil then
            return
        end
        local config = resolveLLMConfig()
        if not config.success then
            ____error = zh and "请先在桌面 Web IDE 中配置并启用一个模型" or "Configure and activate a model in Web IDE first"
            render()
            return
        end
        if not services.continuePrompt then
            ____error = zh and "当前版本不支持继续会话" or "Continuing this session is unavailable"
            render()
            return
        end
        selectedLLMConfigId = config.id
        local result = services.continuePrompt(sessionId, nil, config.id)
        ____error = result.success and "" or result.message
        if result.success then
            stopRequested = false
        end
        refresh()
        render()
    end
    local function startDevelopment()
        if not host.visible or HttpServer.wsConnectionCount > 0 then
            return
        end
        refresh()
        if not detail.success or hasActiveTask() or detail.session.workMode ~= "plan" or not detail.hasActivePlan then
            return
        end
        local modeResult = services.setWorkMode(sessionId, "code")
        if not modeResult.success then
            ____error = modeResult.message or (zh and "切换执行模式失败" or "Could not switch to Code mode")
            render()
            return
        end
        local config = resolveLLMConfig()
        if not config.success then
            ____error = zh and "请先在桌面 Web IDE 中配置并启用一个模型" or "Configure and activate a model in Web IDE first"
            refresh()
            render()
            return
        end
        selectedLLMConfigId = config.id
        local prompt = zh and "请读取 .agent/plan/PLAN.md 和 PROGRESS.md，从当前方案的下一未完成步骤开始开发，并持续更新进度文档。" or "Read .agent/plan/PLAN.md and PROGRESS.md, start from the next unfinished step in the current plan, and keep the progress document updated."
        local result = services.sendPrompt(
            sessionId,
            prompt,
            nil,
            "code",
            config.id,
            config.config
        )
        ____error = result.success and "" or result.message
        refresh()
        render()
    end
    getTranscriptActions = function()
        if not detail.success or not hasTranscriptContent() or hasActiveTask() or __TS__ArrayEvery(
            detail.messages,
            function(____, message) return message.role ~= "assistant" end
        ) then
            return {}
        end
        local actions = {}
        if (detail.session.currentTaskStatus == "FAILED" or detail.session.currentTaskStatus == "STOPPED") and detail.session.currentTaskId ~= nil then
            actions[#actions + 1] = {id = "continue", text = zh and "继续" or "Continue", onTapped = continueTask}
        end
        if detail.session.kind == "main" and detail.session.workMode == "plan" and detail.hasActivePlan then
            actions[#actions + 1] = {id = "start-development", text = zh and "开始开发" or "Start development", primary = true, onTapped = startDevelopment}
        end
        return actions
    end
    local function stop()
        if not host.visible or HttpServer.wsConnectionCount > 0 then
            return
        end
        refresh()
        if not hasActiveTask() or not detail.success or detail.session.currentTaskFinalizing or stopRequested then
            return
        end
        local result = services.stopSessionTask(sessionId)
        if (result and result.success) == false then
            ____error = result.message or (zh and "停止失败" or "Could not stop")
        else
            stopRequested = true
            ____error = ""
        end
        refresh()
        render()
    end
    local function selectModel(id)
        selectedLLMConfigId = id
        modelPickerOpen = false
        DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id})
        ____error = ""
        render()
    end
    local function advanceQuestionnaire()
        if not host.visible or HttpServer.wsConnectionCount > 0 then
            return
        end
        if not detail.success or not detail.pendingQuestionnaire then
            return
        end
        local pending = detail.pendingQuestionnaire
        local questions = pending.schema.questions
        local question = questions[questionIndex + 1]
        if not question then
            return
        end
        local selected = questionnaireSelections[question.id] or ({})
        local text = __TS__StringTrim(questionnaireTexts[question.id] or "")
        if not isQuestionAnswered(question, selected, text) then
            ____error = zh and "请先完成当前必答问题" or "Answer the required question first"
            render()
            return
        end
        if questionIndex + 1 < #questions then
            questionIndex = questionIndex + 1
            ____error = ""
            render()
            return
        end
        local answers = buildQuestionnaireAnswers(questions, questionnaireSelections, questionnaireTexts)
        if selectedLLMConfigId <= 0 then
            ____error = zh and "没有可用的模型配置" or "No model configuration is available"
            render()
            return
        end
        local result = services.respondQuestionnaire(sessionId, pending.id, answers, selectedLLMConfigId)
        if not result.success then
            ____error = result.message
        else
            ____error = ""
        end
        refresh()
        render()
    end
    local function goBack()
        if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then
            return
        end
        if detail.success and not canLeaveRemix(detail.session.status) then
            ____error = zh and "Agent 工作中，请先停止再返回" or "Stop the Agent before going back"
            render()
            return
        end
        blurInput()
        notifyProjectChanged()
        host.visible = false
        host:removeFromParent(true)
        onBack()
    end
    render = function()
        errorLabel = nil
        swipeRevision = swipeRevision + 1
        swipeDragging = false
        swipeBackPending = false
        local layout = (tostring(App.safeArea.width) .. ":") .. tostring(App.safeArea.height)
        local ____temp_20 = layout == inputLayout and not modelPickerOpen and not (detail.success and detail.pendingQuestionnaire)
        if ____temp_20 then
            local ____opt_18 = inputRef.current
            ____temp_20 = (____opt_18 and ____opt_18.tag) == "remix-input"
        end
        local keptInput = ____temp_20 and inputRef.current or nil
        if keptInput ~= nil then
            keptInput:removeFromParent(false)
        end
        transcript.node:removeFromParent(false)
        local restoreInputFocus = promptInput.isFocused()
        if not keptInput then
            promptInput.unmount()
            inputRef = reference()
        end
        host:removeAllChildren()
        inputLayout = layout
        host.scaleX = App.devicePixelRatio
        host.scaleY = App.devicePixelRatio
        local ____App_visualSize_23 = App.visualSize
        local width = ____App_visualSize_23.width
        local height = ____App_visualSize_23.height
        local safe = getLayoutArea()
        local left = safe.x
        local bottom = safe.y
        local shortLandscape = safe.width >= 760 and safe.height < 500
        local state = detail.success and detail.session or nil
        local workMode = resolveRemixWorkMode(state)
        local stopping = hasActiveTask()
        local ____detail_success_24
        if detail.success then
            ____detail_success_24 = detail.hasActivePlan
        else
            ____detail_success_24 = false
        end
        local hasActivePlan = ____detail_success_24
        local phase = state and resolveRemixPhase({status = state.status, workMode = workMode, hasActivePlan = hasActivePlan}) or "failed"
        local layoutComposerBottom = 24
        local layoutComposerHeight = composerHeight
        local layoutModeBottom = layoutComposerBottom + layoutComposerHeight + composerGap
        local layoutComposerTop = layoutModeBottom + 40
        layoutTranscriptBottom = layoutComposerTop + composerGap
        local contentWidth = safe.width - 32
        local inputWidth = contentWidth - composerActionWidth - composerGap
        local inlinePlay = phase == "done"
        local modeWidth = inlinePlay and (shortLandscape and math.min(
            170,
            math.floor((contentWidth - composerGap * 2 - 120) / 2)
        ) or math.floor((contentWidth - composerGap * 2) / 3)) or math.floor((contentWidth - composerGap) / 2)
        local modeStartX = left + 16
        local modeCodeWidth = inlinePlay and shortLandscape and modeWidth or (inlinePlay and math.floor((contentWidth - composerGap * 2) / 3) or contentWidth - modeWidth - composerGap)
        local playWidth = inlinePlay and contentWidth - modeWidth - modeCodeWidth - composerGap * 2 or 0
        local playX = modeStartX + modeWidth + composerGap + modeCodeWidth + composerGap
        local ____detail_success_25
        if detail.success then
            ____detail_success_25 = detail.pendingQuestionnaire
        else
            ____detail_success_25 = nil
        end
        local questionnaire = ____detail_success_25
        local question = questionnaire and questionnaire.schema.questions[questionIndex + 1]
        local fontScale = mobileFontScale
        local pickerHeight = math.min(420, safe.height - 280)
        local headerY = getHeaderY(safe)
        local compactHeaderStatus = useCompactHeaderStatus(safe)
        compactHeaderStatusActive = compactHeaderStatus
        local headerStatusWidth = 168
        local headerTitleWidth = compactHeaderStatus and math.max(120, safe.width - 124 - headerStatusWidth - composerGap) or safe.width - 124
        local headerStatusX = left + 16 + headerTitleWidth + composerGap
        local thinkingText = resolveRemixThinkingStatus(detail.success and detail.steps or ({}), state and state.currentTaskId)
        local statusText = thinkingText ~= nil and (zh and "正在思考" or "Thinking") or (phase == "planning" and (zh and "Dora 正在整理方案…" or "Dora is planning…") or (phase == "working" and (zh and "Dora 正在 Remix…" or "Dora is remixing…") or (phase == "plan-ready" and (zh and "计划对话已完成" or "Planning conversation complete") or (phase == "waiting" and (zh and "需要你的确认" or "Waiting for you") or (phase == "done" and (zh and "Remix 已完成" or "Remix complete") or (phase == "failed" and (zh and "执行失败，可以修改要求后重试" or "Failed; revise and retry") or (zh and "告诉 Dora 你想怎样改这个游戏" or "Tell Dora how to change this game")))))))
        local mascotState = phase == "planning" and "thinking" or (phase == "working" and "working" or (phase == "waiting" and "waiting" or ((phase == "done" or phase == "plan-ready") and "success" or (phase == "failed" and "failed" or "idle"))))
        if mascotAnimationState ~= mascotState then
            mascotAnimationState = mascotState
            mascotAnimationStartedAt = App.runningTime
        end
        local emptyLandscape = shortLandscape and not hasTranscriptContent()
        local emptyStatusBottom = bottom + layoutModeBottom + 40 + composerGap
        local emptyStatusTop = headerY - composerGap - statusHeight
        local messageTop = emptyLandscape and (emptyStatusBottom + emptyStatusTop) / 2 + statusHeight / 2 or headerY - composerGap - statusHeight / 2
        local mascotSize = shortLandscape and 42 or 52
        local compactStandaloneStatus = useCompactStandaloneStatus(safe)
        local standaloneStatusContentLift = shortLandscape and 0 or (compactStandaloneStatus and 26 or 14)
        local mascotX = shortLandscape and left + 40 or left + 66
        local statusTextX = shortLandscape and left + 76 or left + 104
        local statusTextWidth = shortLandscape and math.max(120, left + 16 + contentWidth - statusTextX) or contentWidth - 84
        local renderedStatusX = compactHeaderStatus and 36 or statusTextX
        local renderedStatusY = compactHeaderStatus and 22 or statusHeight / 2 + standaloneStatusContentLift
        local renderedStatusWidth = compactHeaderStatus and headerStatusWidth - 36 or statusTextWidth
        local thinkingFontSize = compactHeaderStatus and math.floor(10 * fontScale) or math.floor(12 * fontScale)
        local thinkingRightPadding = compactHeaderStatus and 8 or 20
        local renderedThinkingText = thinkingText == nil and "" or ellipsizeSingleLine(thinkingText, renderedStatusWidth - thinkingRightPadding, thinkingFontSize)
        local swipeStart = Vec2.zero
        local swipeAxis = "none"
        local pageRef = reference()
        local hitsTranscriptButton
        hitsTranscriptButton = function(node, world)
            if not node.visible then
                return false
            end
            if node.tag == "remix-copy" or node.tag == "remix-latest" or node.tag == "remix-action-continue" or node.tag == "remix-action-start-development" then
                local p = node:convertToNodeSpace(world)
                if p.x >= 0 and p.y >= 0 and p.x <= node.width and p.y <= node.height then
                    return true
                end
            end
            local hit = false
            node:eachChild(function(child)
                hit = hitsTranscriptButton(child, world)
                return hit
            end)
            return hit
        end
        local ____toNode_64 = toNode
        local ____React_createElement_63 = React.createElement
        local ____array_62 = __TS__SparseArrayNew(
            "node",
            {
                tag = "remix-scene",
                x = -width / 2,
                y = -height / 2,
                width = width,
                height = height,
                anchorX = 0,
                anchorY = 0
            },
            React.createElement(
                "node",
                {
                    tag = "remix-focus-observer",
                    order = 1000,
                    width = width,
                    height = height,
                    anchorX = 0,
                    anchorY = 0,
                    touchEnabled = true,
                    swallowTouches = false,
                    swallowMouseWheel = false,
                    onTapFilter = function(touch)
                        touch.enabled = false
                        if swipeBackPending or not host.visible or HttpServer.wsConnectionCount > 0 then
                            return
                        end
                        local input = inputRef.current
                        local point = input and input:convertToNodeSpace(touch.worldLocation)
                        local inside = input and point and point.x >= 0 and point.y >= 0 and point.x <= input.width and point.y <= input.height
                        dismissedComposition = not inside and promptInput.isComposing()
                        if not inside then
                            blurInput()
                        end
                        if not inside and not questionnaire and not modelPickerOpen and touch.first ~= false and touch.location.y >= bottom + layoutTranscriptBottom and touch.location.y < bottom + safe.height - 64 and not hitsTranscriptButton(transcript.node, touch.worldLocation) then
                            touch.enabled = true
                        end
                    end,
                    onTapBegan = function(touch)
                        swipeStart = touch.location
                        swipeAxis = "none"
                        swipeDragging = true
                        local ____opt_32 = pageRef.current
                        if ____opt_32 ~= nil then
                            ____opt_32:stopAllActions()
                        end
                    end,
                    onTapMoved = function(touch)
                        local delta = touch.location:sub(swipeStart)
                        if swipeAxis == "none" and math.max(
                            math.abs(delta.x),
                            math.abs(delta.y)
                        ) >= 12 then
                            swipeAxis = math.abs(delta.x) > math.abs(delta.y) * 1.2 and "horizontal" or "vertical"
                        end
                        if pageRef.current then
                            pageRef.current.x = swipeAxis == "horizontal" and math.min(0, delta.x) * 0.18 or 0
                        end
                    end,
                    onTapEnded = function(touch)
                        local delta = touch.location:sub(swipeStart)
                        swipeDragging = false
                        if swipeBackPending then
                            return
                        end
                        local requested = swipeAxis ~= "vertical" and resolveFeedGesture(delta.x, delta.y, safe.width, safe.height) == "play"
                        local leaving = requested and (not detail.success or canLeaveRemix(detail.session.status))
                        local page = pageRef.current
                        if not page or not requested and page.x == 0 then
                            return
                        end
                        local duration = (leaving or App.reducedMotion) and 0 or 0.16
                        local revision = swipeRevision
                        swipeBackPending = true
                        if not leaving then
                            page:perform(Move(duration, page.position, Vec2.zero, Ease.OutQuad))
                        end
                        thread(function()
                            sleep(duration)
                            if disposed or revision ~= swipeRevision or not host.parent then
                                return
                            end
                            swipeBackPending = false
                            if requested and host.visible and HttpServer.wsConnectionCount == 0 then
                                refresh()
                                goBack()
                            else
                                page.position = Vec2.zero
                            end
                        end)
                    end
                }
            ),
            React.createElement(VerticalGradient, {width = width, height = height, topColor = 4279310117, bottomColor = 4278716943})
        )
        local ____React_createElement_61 = React.createElement
        local ____array_60 = __TS__SparseArrayNew(
            "node",
            {tag = "remix-page", ref = pageRef},
            React.createElement(
                "clip-node",
                {
                    x = left + 16,
                    y = headerY,
                    width = headerTitleWidth,
                    height = 44,
                    anchorX = 0,
                    anchorY = 0,
                    stencil = React.createElement(
                        "draw-node",
                        {x = headerTitleWidth / 2, y = 22},
                        React.createElement("rect-shape", {width = headerTitleWidth, height = 44, fillColor = 4294967295})
                    )
                },
                React.createElement("label", {
                    tag = "remix-title",
                    x = 0,
                    y = 22,
                    anchorX = 0,
                    fontName = fontName,
                    fontSize = 20,
                    text = "REMIX · " .. options.entry.title,
                    color3 = 16052712
                })
            ),
            React.createElement(
                "node",
                {
                    tag = "remix-back",
                    x = left + safe.width - 96,
                    y = headerY,
                    width = 80,
                    height = 44,
                    anchorX = 0,
                    anchorY = 0,
                    touchEnabled = true,
                    swallowTouches = true,
                    onTapped = goBack
                },
                React.createElement("label", {
                    x = 80,
                    y = 22,
                    anchorX = 1,
                    fontName = fontName,
                    fontSize = 18,
                    text = zh and "返回 ›" or "Back ›",
                    color3 = 16763955
                })
            ),
            React.createElement(
                "node",
                {
                    tag = "remix-status",
                    x = compactHeaderStatus and headerStatusX or 0,
                    y = compactHeaderStatus and headerY or messageTop - statusHeight / 2,
                    width = compactHeaderStatus and headerStatusWidth or width,
                    height = compactHeaderStatus and 44 or statusHeight,
                    anchorX = 0,
                    anchorY = 0
                },
                React.createElement(DoraMascot, {state = mascotState, x = compactHeaderStatus and 16 or mascotX, y = compactHeaderStatus and 20 or statusHeight / 2 - 2 + standaloneStatusContentLift, size = compactHeaderStatus and 30 or mascotSize, animationStartedAt = mascotAnimationStartedAt}),
                React.createElement(
                    "clip-node",
                    {
                        tag = "remix-status-clip",
                        x = renderedStatusX,
                        y = renderedStatusY - 22,
                        width = renderedStatusWidth,
                        height = 44,
                        anchorX = 0,
                        anchorY = 0,
                        stencil = React.createElement(
                            "draw-node",
                            {x = renderedStatusWidth / 2, y = 22},
                            React.createElement("rect-shape", {width = renderedStatusWidth, height = 44, fillColor = 4294967295})
                        )
                    },
                    React.createElement(
                        "label",
                        {
                            tag = "remix-status-text",
                            x = 0,
                            y = 22,
                            anchorX = 0,
                            fontName = fontName,
                            fontSize = compactHeaderStatus and math.floor(13 * fontScale) or math.floor(15 * fontScale),
                            text = statusText,
                            textWidth = -1,
                            alignment = "Left",
                            color3 = phase == "failed" and 16739179 or 16763955
                        }
                    ),
                    React.createElement(
                        "label",
                        {
                            tag = "remix-thinking-text",
                            x = 0,
                            y = 6,
                            anchorX = 0,
                            fontName = fontName,
                            fontSize = thinkingFontSize,
                            text = renderedThinkingText,
                            textWidth = -1,
                            alignment = "Left",
                            color3 = colors.muted
                        }
                    )
                )
            )
        )
        local ____temp_41
        if questionnaire and question then
            local ____React_createElement_40 = React.createElement
            local ____array_39 = __TS__SparseArrayNew(
                "node",
                {
                    tag = "remix-questionnaire",
                    x = left + 16,
                    y = bottom + 164,
                    width = contentWidth,
                    height = safe.height - 330,
                    anchorX = 0,
                    anchorY = 0
                },
                React.createElement(RoundedSurface, {
                    width = contentWidth,
                    height = safe.height - 330,
                    radius = 20,
                    topColor = 4280429370,
                    bottomColor = 4279375648,
                    borderWidth = 1,
                    borderColor = 4282469213,
                    shadow = true
                }),
                React.createElement(
                    "label",
                    {
                        x = 16,
                        y = safe.height - 360,
                        anchorX = 0,
                        fontName = fontName,
                        fontSize = 13,
                        text = (((tostring(questionIndex + 1) .. " / ") .. tostring(#questionnaire.schema.questions)) .. " · ") .. questionnaire.schema.title,
                        textWidth = contentWidth - 32,
                        alignment = "Left",
                        color3 = 16763955
                    }
                ),
                React.createElement("label", {
                    x = 16,
                    y = safe.height - 405,
                    anchorX = 0,
                    fontName = fontName,
                    fontSize = 16,
                    text = question.prompt,
                    textWidth = contentWidth - 32,
                    alignment = "Left",
                    color3 = 16052712
                }),
                question.type ~= "text" and __TS__ArrayMap(
                    __TS__ArraySlice(question.options or ({}), 0, 8),
                    function(____, option, optionIndex) return React.createElement(
                        ChoiceButton,
                        {
                            tag = (("remix-question-" .. question.id) .. "-option-") .. option.id,
                            x = 16,
                            y = safe.height - 460 - optionIndex * 43,
                            width = contentWidth - 32,
                            text = (((__TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0 and "●" or "○") .. " ") .. option.label) .. (option.recommended and (zh and "（推荐）" or " (recommended)") or ""),
                            selected = __TS__ArrayIndexOf(questionnaireSelections[question.id] or ({}), option.id) >= 0,
                            onTapped = function()
                                local selected = questionnaireSelections[question.id] or ({})
                                local ____question_id_37 = question.id
                                local ____temp_36
                                if question.type == "single_choice" then
                                    ____temp_36 = {option.id}
                                else
                                    local ____temp_35
                                    if __TS__ArrayIndexOf(selected, option.id) >= 0 then
                                        ____temp_35 = __TS__ArrayFilter(
                                            selected,
                                            function(____, id) return id ~= option.id end
                                        )
                                    else
                                        local ____array_34 = __TS__SparseArrayNew(table.unpack(selected))
                                        __TS__SparseArrayPush(____array_34, option.id)
                                        ____temp_35 = {__TS__SparseArraySpread(____array_34)}
                                    end
                                    ____temp_36 = ____temp_35
                                end
                                questionnaireSelections[____question_id_37] = ____temp_36
                                render()
                            end
                        }
                    ) end
                ) or React.createElement("node", {
                    tag = "remix-question-input",
                    ref = inputRef,
                    x = 16,
                    y = safe.height - 510,
                    width = contentWidth - 32,
                    height = 92,
                    anchorX = 0,
                    anchorY = 0,
                    onMount = promptInput.mount
                })
            )
            local ____temp_38
            if questionIndex > 0 then
                ____temp_38 = React.createElement(
                    ActionButton,
                    {
                        x = 16,
                        y = 12,
                        width = 92,
                        text = zh and "上一步" or "Back",
                        onTapped = function()
                            questionIndex = questionIndex - 1
                            render()
                        end
                    }
                )
            else
                ____temp_38 = nil
            end
            __TS__SparseArrayPush(
                ____array_39,
                ____temp_38,
                React.createElement(
                    ActionButton,
                    {
                        tag = "remix-question-submit",
                        x = questionIndex > 0 and 120 or 16,
                        y = 12,
                        width = contentWidth - (questionIndex > 0 and 136 or 32),
                        text = questionIndex + 1 == #questionnaire.schema.questions and (zh and "提交回答" or "Submit") or (zh and "下一步" or "Next"),
                        primary = true,
                        onTapped = function()
                            if not dismissedComposition then
                                advanceQuestionnaire()
                            end
                            dismissedComposition = false
                        end
                    }
                )
            )
            ____temp_41 = ____React_createElement_40(__TS__SparseArraySpread(____array_39))
        else
            ____temp_41 = nil
        end
        __TS__SparseArrayPush(____array_60, ____temp_41)
        local ____modelPickerOpen_42
        if modelPickerOpen then
            ____modelPickerOpen_42 = React.createElement(
                "node",
                {
                    x = left + 16,
                    y = bottom + 164,
                    width = contentWidth,
                    height = pickerHeight,
                    anchorX = 0,
                    anchorY = 0,
                    touchEnabled = true,
                    swallowTouches = true
                },
                React.createElement(RoundedSurface, {
                    width = contentWidth,
                    height = pickerHeight,
                    radius = 20,
                    topColor = 4280429370,
                    bottomColor = 4279375648,
                    borderWidth = 1,
                    borderColor = 4282469213,
                    shadow = true
                }),
                React.createElement("label", {
                    x = 16,
                    y = pickerHeight - 34,
                    anchorX = 0,
                    fontName = fontName,
                    fontSize = 17,
                    text = zh and "选择 Remix 使用的模型" or "Choose a model for Remix",
                    textWidth = contentWidth - 32,
                    alignment = "Left",
                    color3 = 16052712
                }),
                __TS__ArrayMap(
                    __TS__ArraySlice(llmConfigs, 0, 8),
                    function(____, item, i) return React.createElement(
                        ChoiceButton,
                        {
                            x = 16,
                            y = pickerHeight - 90 - i * 43,
                            width = contentWidth - 32,
                            text = (item.name .. " · ") .. item.model,
                            selected = item.id == selectedLLMConfigId,
                            onTapped = function() return selectModel(item.id) end
                        }
                    ) end
                )
            )
        else
            ____modelPickerOpen_42 = nil
        end
        __TS__SparseArrayPush(____array_60, ____modelPickerOpen_42)
        local ____temp_43
        if ____error ~= "" then
            ____temp_43 = React.createElement(
                "label",
                {
                    tag = "remix-error",
                    x = left + 20,
                    y = bottom + ((questionnaire or modelPickerOpen) and 144 or layoutComposerTop + composerGap),
                    anchorX = 0,
                    anchorY = 0,
                    fontName = fontName,
                    fontSize = 13,
                    text = ____error,
                    textWidth = contentWidth,
                    alignment = "Left",
                    color3 = 16739179,
                    onMount = function(label)
                        errorLabel = label
                    end
                }
            )
        else
            ____temp_43 = nil
        end
        __TS__SparseArrayPush(____array_60, ____temp_43)
        local ____temp_44
        if questionnaire == nil and not modelPickerOpen then
            ____temp_44 = React.createElement(
                "node",
                nil,
                React.createElement(
                    ChoiceButton,
                    {
                        tag = "remix-mode-plan",
                        x = modeStartX,
                        y = bottom + layoutModeBottom,
                        width = modeWidth,
                        text = zh and "计划" or "Plan",
                        selected = workMode == "plan",
                        disabled = not canSubmit(),
                        onTapped = function() return changeWorkMode("plan") end
                    }
                ),
                React.createElement(
                    ChoiceButton,
                    {
                        tag = "remix-mode-code",
                        x = modeStartX + modeWidth + composerGap,
                        y = bottom + layoutModeBottom,
                        width = modeCodeWidth,
                        text = zh and "执行" or "Code",
                        selected = workMode == "code",
                        disabled = not canSubmit(),
                        onTapped = function() return changeWorkMode("code") end
                    }
                )
            )
        else
            ____temp_44 = nil
        end
        __TS__SparseArrayPush(____array_60, ____temp_44)
        local ____temp_45
        if questionnaire == nil and not modelPickerOpen and not keptInput then
            ____temp_45 = React.createElement("node", {
                tag = "remix-input",
                ref = inputRef,
                x = left + 16,
                y = bottom + layoutComposerBottom,
                width = inputWidth,
                height = layoutComposerHeight,
                anchorX = 0,
                anchorY = 0,
                onMount = promptInput.mount
            })
        else
            ____temp_45 = nil
        end
        __TS__SparseArrayPush(____array_60, ____temp_45)
        local ____temp_58
        if stopping or questionnaire == nil and not modelPickerOpen then
            local ____React_createElement_57 = React.createElement
            local ____ActionButton_56 = ActionButton
            local ____temp_51 = stopping and "remix-stop" or "remix-send"
            local ____temp_52 = left + 16 + inputWidth + composerGap
            local ____temp_53 = bottom + layoutComposerBottom
            local ____temp_54 = stopping and (state and state.currentTaskFinalizing and (zh and "收尾中" or "Finishing") or (stopRequested and (zh and "停止中" or "Stopping") or (zh and "停止" or "Stop"))) or (zh and "发送" or "Send")
            local ____temp_55 = not stopping
            local ____stopping_50
            if stopping then
                ____stopping_50 = stopRequested or (state and state.currentTaskFinalizing) == true
            else
                ____stopping_50 = not canSubmit()
            end
            ____temp_58 = ____React_createElement_57(
                ____ActionButton_56,
                {
                    tag = ____temp_51,
                    x = ____temp_52,
                    y = ____temp_53,
                    width = composerActionWidth,
                    height = layoutComposerHeight,
                    text = ____temp_54,
                    primary = ____temp_55,
                    danger = stopping,
                    disabled = ____stopping_50,
                    onTapped = function()
                        if stopping then
                            stop()
                        elseif not dismissedComposition then
                            send()
                        end
                        dismissedComposition = false
                    end
                }
            )
        else
            ____temp_58 = nil
        end
        __TS__SparseArrayPush(____array_60, ____temp_58)
        local ____temp_59
        if phase == "done" then
            ____temp_59 = React.createElement(
                ActionButton,
                {
                    tag = "remix-play",
                    x = playX,
                    y = bottom + layoutModeBottom,
                    width = playWidth,
                    height = 40,
                    text = zh and "立即试玩" or "Play now",
                    primary = true,
                    onTapped = function()
                        if not host.visible or HttpServer.wsConnectionCount > 0 then
                            return
                        end
                        blurInput()
                        notifyProjectChanged()
                        host.visible = false
                        onPlay(options.entry)
                    end
                }
            )
        else
            ____temp_59 = nil
        end
        __TS__SparseArrayPush(____array_60, ____temp_59)
        __TS__SparseArrayPush(
            ____array_62,
            ____React_createElement_61(__TS__SparseArraySpread(____array_60))
        )
        local scene = ____toNode_64(____React_createElement_63(__TS__SparseArraySpread(____array_62)))
        if scene then
            host:addChild(scene)
            if keptInput then
                keptInput.position = Vec2(left + 16, bottom + layoutComposerBottom)
                keptInput.width = inputWidth
                keptInput.height = layoutComposerHeight
                local ____opt_65 = pageRef.current
                if ____opt_65 ~= nil then
                    ____opt_65:addChild(keptInput)
                end
            end
            if not questionnaire and not modelPickerOpen then
                transcript.node.position = Vec2(
                    left + 16,
                    bottom + getTranscriptBottom()
                )
                local ____opt_67 = pageRef.current
                if ____opt_67 ~= nil then
                    ____opt_67:addChild(transcript.node)
                end
                updateTranscript()
            end
        end
        if restoreInputFocus and inputRef.current and not keptInput then
            promptInput.focus(false)
        end
        if keptInput then
            promptInput.refresh()
        end
        shellRevision = getShellRevision()
        displayRevision = remixDisplayRevision(detail)
    end
    host:schedule(function(dt)
        pollElapsed = pollElapsed + dt
        if pollElapsed < 0.25 then
            return false
        end
        pollElapsed = 0
        refresh()
        if swipeDragging or swipeBackPending then
            return false
        end
        local next = remixDisplayRevision(detail)
        if shellRevision ~= getShellRevision() or compactHeaderStatusActive ~= useCompactHeaderStatus(getLayoutArea()) then
            render()
        elseif displayRevision ~= next then
            updateTranscript()
        end
        return false
    end)
    host:onAppChange(function(setting)
        if setting == "Size" or setting == "Locale" then
            render()
        end
    end)
    host:onAppEvent(function(event)
        if event == "BackButton" then
            if promptInput.isFocused() then
                blurInput()
            else
                goBack()
            end
        elseif event == "WillEnterBackground" or event == "DidEnterBackground" then
            blurInput()
        end
    end)
    host:onCleanup(function()
        disposed = true
        blurInput()
    end)
    host:slot("SuspendLocalUI", blurInput)
    host:slot(
        "ResumeLocalUI",
        function()
            refresh()
            render()
        end
    )
    render()
    return host
end
return ____exports
