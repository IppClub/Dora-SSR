-- [ts]: RemixTranscript.ts
local ____lualib = require("lualib_bundle")
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local __TS__ArrayPushArray = ____lualib.__TS__ArrayPushArray
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArraySome = ____lualib.__TS__ArraySome
local ____exports = {}
local ____Dora = require("Dora")
local App = ____Dora.App
local Color = ____Dora.Color
local Color3 = ____Dora.Color3
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Node = ____Dora.Node
local Size = ____Dora.Size
local Vec2 = ____Dora.Vec2
local ScrollArea = require("UI.Control.Basic.ScrollArea")
local ____Utils = require("Agent.Utils")
local safeJsonEncode = ____Utils.safeJsonEncode
local ____RemixModel = require("Dev.Mobile.RemixModel")
local compactAgentActivity = ____RemixModel.compactAgentActivity
local ____LightMarkdown = require("Dev.Mobile.LightMarkdown")
local parseLightMarkdown = ____LightMarkdown.parseLightMarkdown
local ____RemixHistory = require("Dev.Mobile.RemixHistory")
local remixHistory = ____RemixHistory.remixHistory
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS
local font = "sarasa-mono-sc-regular"
function ____exports.remixDisplayRevision(detail)
    if not detail.success then
        return detail.message
    end
    local history = remixHistory(detail)
    return (safeJsonEncode({
        status = detail.session.status,
        mode = detail.session.workMode,
        plan = detail.hasActivePlan,
        finalizing = detail.session.currentTaskFinalizing,
        questionnaire = detail.pendingQuestionnaire,
        currentTaskId = detail.session.currentTaskId,
        currentTaskStatus = detail.session.currentTaskStatus,
        hasEarlierMessages = history.hasEarlierMessages,
        messages = __TS__ArrayMap(
            history.messages,
            function(____, m) return {m.id, m.taskId or 0, m.role, m.displayContent or m.content} end
        ),
        steps = __TS__ArrayMap(
            history.steps,
            function(____, s)
                local ____array_6 = __TS__SparseArrayNew(s.id, s.tool, s.status, s.reason)
                local ____opt_0 = s.result
                __TS__SparseArrayPush(____array_6, ____opt_0 and ____opt_0.progress)
                local ____opt_2 = s.result
                __TS__SparseArrayPush(____array_6, ____opt_2 and ____opt_2.stage)
                local ____opt_4 = s.result
                __TS__SparseArrayPush(____array_6, ____opt_4 and ____opt_4.message)
                return {__TS__SparseArraySpread(____array_6)}
            end
        )
    })) or ""
end
local function itemsFor(detail, zh, actions)
    if not detail.success then
        return {}
    end
    local items = {}
    local history = remixHistory(detail)
    if history.hasEarlierMessages then
        items[#items + 1] = {
            id = "remix-history-limit",
            title = zh and "历史记录" or "History",
            text = zh and ("仅展示最近 " .. tostring(REMIX_HISTORY_ROUNDS)) .. " 轮，更早记录可在 Web IDE 查看。" or ("Showing the latest " .. tostring(REMIX_HISTORY_ROUNDS)) .. " rounds. View earlier messages in Web IDE.",
            user = false,
            activity = true
        }
    end
    local activities = __TS__ArrayMap(
        history.steps,
        function(____, s)
            local state = s.status == "DONE" and (zh and "已完成" or "Done") or (s.status == "FAILED" and (zh and "失败" or "Failed") or (s.status == "STOPPED" and (zh and "已停止" or "Stopped") or (s.status == "PENDING" and (zh and "等待中" or "Pending") or (zh and "进行中" or "Working"))))
            local ____temp_9 = s.status == "RUNNING"
            if ____temp_9 then
                local ____opt_7 = s.result
                ____temp_9 = type(____opt_7 and ____opt_7.progress) == "number"
            end
            local progress = ____temp_9 and (" · " .. tostring(math.floor(s.result.progress * 100))) .. "%" or ""
            local ____temp_12 = s.status == "RUNNING"
            if ____temp_12 then
                local ____opt_10 = s.result
                ____temp_12 = type(____opt_10 and ____opt_10.message) == "string"
            end
            local message = ____temp_12 and s.result.message or ""
            local title = compactAgentActivity(s.tool, "", zh, s.status == "RUNNING")
            return {
                id = "step-" .. tostring(s.id),
                title = ((state .. progress) .. " · ") .. title,
                text = s.reason .. (message ~= "" and "\n" .. message or ""),
                user = false,
                activity = true
            }
        end
    )
    local inserted = false
    for ____, m in ipairs(history.messages) do
        if not inserted and m.role == "assistant" and m.taskId == detail.session.currentTaskId then
            __TS__ArrayPushArray(items, activities)
            inserted = true
        end
        items[#items + 1] = {
            id = "message-" .. tostring(m.id),
            title = m.role == "user" and (zh and "你" or "You") or "Dora",
            text = m.displayContent or m.content,
            user = m.role == "user",
            activity = false
        }
    end
    if not inserted then
        __TS__ArrayPushArray(items, activities)
    end
    if #actions > 0 then
        items[#items + 1] = {
            id = "remix-terminal-actions",
            title = "",
            text = "",
            user = false,
            activity = true,
            actions = actions
        }
    end
    return items
end
local function drawCapsule(target, width, height, color, inset)
    if inset == nil then
        inset = 0
    end
    local radius = height / 2 - inset
    local left = height / 2
    local right = width - height / 2
    target:drawPolygon(
        {
            Vec2(left, inset),
            Vec2(right, inset),
            Vec2(right, height - inset),
            Vec2(left, height - inset)
        },
        Color(color)
    )
    target:drawDot(
        Vec2(left, height / 2),
        radius,
        Color(color)
    )
    target:drawDot(
        Vec2(right, height / 2),
        radius,
        Color(color)
    )
end
local function makeActionRow(actions, width, scale)
    local card = Node()
    card.tag = "remix-terminal-actions"
    card.anchor = Vec2(0, 1)
    card.width = width
    card.height = 44
    local gap = 10
    local buttonWidth = #actions > 1 and math.min((width - gap) / 2, 184) or math.min(width, 184)
    do
        local i = 0
        while i < #actions do
            local action = actions[i + 1]
            local button = Node()
            button.tag = "remix-action-" .. action.id
            button.anchor = Vec2.zero
            button.position = Vec2(i * (buttonWidth + gap), 3)
            button.size = Size(buttonWidth, 38)
            button.touchEnabled = true
            button.swallowTouches = true
            button:onTapped(action.onTapped)
            local bg = DrawNode()
            if action.primary then
                drawCapsule(bg, buttonWidth, 38, 4294954035)
            else
                drawCapsule(bg, buttonWidth, 38, 4282798180)
                drawCapsule(
                    bg,
                    buttonWidth,
                    38,
                    4279704614,
                    1
                )
            end
            button:addChild(bg)
            local label = Label(
                font,
                math.floor(14 * scale),
                true
            )
            if label then
                label.position = Vec2(buttonWidth / 2, 19)
                label.color3 = Color3(action.primary and 1512202 or 16052712)
                label.text = action.text
                button:addChild(label)
            end
            card:addChild(button)
            i = i + 1
        end
    end
    return card
end
local function makeCard(item, width, scale, zh)
    if item.actions then
        return makeActionRow(item.actions, width, scale)
    end
    local card = Node()
    card.tag = item.id
    card.anchor = Vec2(0, 1)
    card.width = width
    local labels = {}
    local top = 12
    local function add(text, size, color)
        local l = Label(
            font,
            math.floor(size * scale),
            true
        )
        if not l then
            return
        end
        l.anchor = Vec2(0, 1)
        l.x = 14
        l.textWidth = math.max(20, width - 28)
        l.alignment = "Left"
        l.lineGap = 4
        l.color3 = Color3(color)
        l.text = text
        labels[#labels + 1] = {label = l, top = top}
        top = top + (l.height + 8)
    end
    add(item.title, 13, (item.user or item.activity) and 16763955 or 11055037)
    for ____, block in ipairs(parseLightMarkdown(item.text)) do
        add(block.text, block.kind == "heading1" and 17 or (block.kind == "heading2" and 16 or 14), block.kind == "code" and 16763955 or 16052712)
    end
    if not item.user and not item.activity then
        add(zh and "复制全文" or "Copy message", 13, 16763955)
        local ____opt_13 = labels[#labels]
        local copy = ____opt_13 and ____opt_13.label
        if copy ~= nil then
            copy.tag = "remix-copy"
            copy.touchEnabled = true
            copy:onTapped(function() return App:setClipboardText(item.text) end)
        end
    end
    card.height = top + 4
    local bg = DrawNode()
    bg:drawPolygon(
        {
            Vec2.zero,
            Vec2(width, 0),
            Vec2(width, card.height),
            Vec2(0, card.height)
        },
        Color(item.user and 4280297010 or 4279704614),
        1,
        Color(4281613128)
    )
    card:addChild(bg)
    for ____, row in ipairs(labels) do
        row.label.y = card.height - row.top
        card:addChild(row.label)
    end
    return card
end
function ____exports.createRemixTranscript()
    local node = Node()
    node.tag = "remix-transcript"
    node.anchor = Vec2.zero
    local scroll = ScrollArea({
        width = 1,
        height = 1,
        paddingX = 0,
        paddingY = 40,
        scrollBar = false
    })
    scroll.tag = "remix-scroll"
    scroll:addTo(node)
    local latest = Label(font, 14, true)
    latest.tag = "remix-latest"
    latest.color3 = Color3(16763955)
    latest.touchEnabled = true
    local hintBackground = DrawNode()
    hintBackground.order = 1
    hintBackground:addTo(node)
    latest.order = 2
    latest:addTo(node)
    local width = 1
    local height = 1
    local scale = 1
    local zh = true
    local total = 0
    local following = true
    local touching = false
    local layingOut = false
    local unread = false
    local rows = {}
    local function maxOffset()
        return math.max(0, total - height)
    end
    local function updateHint()
        latest.visible = unread and not following
        latest.text = zh and "有新内容 · 回到最新 ↓" or "New activity · Latest ↓"
        hintBackground.visible = latest.visible
        hintBackground:clear()
        local half = math.min(width / 2, latest.width / 2 + 10)
        hintBackground:drawPolygon(
            {
                Vec2(width / 2 - half, 0),
                Vec2(width / 2 + half, 0),
                Vec2(width / 2 + half, 28),
                Vec2(width / 2 - half, 28)
            },
            Color(4280297010)
        )
    end
    scroll:slot(
        "ScrollTouchBegan",
        function()
            touching = true
        end
    )
    scroll:slot(
        "ScrollTouchEnded",
        function()
            touching = false
            following = maxOffset() - scroll.offset.y <= 24
            updateHint()
        end
    )
    scroll:slot(
        "Scrolled",
        function()
            if layingOut then
                return
            end
            following = maxOffset() - scroll.offset.y <= 24
            if following then
                unread = false
            end
            updateHint()
        end
    )
    latest:onTapped(function()
        scroll:unschedule()
        touching = false
        following = true
        unread = false
        scroll.offset = Vec2(
            0,
            maxOffset()
        )
        updateHint()
    end)
    return {
        node = node,
        scrollBy = function(self, amount)
            scroll:unschedule()
            following = false
            scroll.offset = Vec2(0, math.max(0, math.min(maxOffset(), scroll.offset.y + amount)))
            scroll.view:moveAndCullItems(Vec2.zero)
            following = maxOffset() - scroll.offset.y <= 24
            if following then unread = false end
            updateHint()
        end,
        update = function(self, detail, w, h, fontScale, chinese, actions)
            if actions == nil then
                actions = {}
            end
            local anchor = __TS__ArrayFind(
                rows,
                function(____, row) return row.node.y > 0 and row.node.y - row.node.height < height end
            )
            local anchorY = anchor and anchor.node.y
            local oldOffset = scroll.offset.y
            local layoutChanged = width ~= w or height ~= h or scale ~= fontScale or zh ~= chinese
            width = w
            height = h
            scale = fontScale
            zh = chinese
            node.size = Size(width, height)
            scroll.position = Vec2(width / 2, height / 2)
            latest.position = Vec2(width / 2, 14)
            local previous = rows
            local changed = layoutChanged
            rows = __TS__ArrayMap(
                itemsFor(detail, zh, actions),
                function(____, item)
                    local ____safeJsonEncode_24 = safeJsonEncode
                    local ____item_id_19 = item.id
                    local ____item_title_20 = item.title
                    local ____item_text_21 = item.text
                    local ____item_user_22 = item.user
                    local ____item_activity_23 = item.activity
                    local ____opt_17 = item.actions
                    local signature = (____safeJsonEncode_24({
                        id = ____item_id_19,
                        title = ____item_title_20,
                        text = ____item_text_21,
                        user = ____item_user_22,
                        activity = ____item_activity_23,
                        actions = ____opt_17 and __TS__ArrayMap(
                            item.actions,
                            function(____, action) return {action.id, action.text, action.primary == true} end
                        )
                    })) or ""
                    local existing = __TS__ArrayFind(
                        previous,
                        function(____, row) return row.id == item.id end
                    )
                    if not layoutChanged and (existing and existing.signature) == signature then
                        return existing
                    end
                    changed = true
                    local card = makeCard(item, width, scale, zh)
                    scroll.view:addChild(card)
                    return {id = item.id, signature = signature, node = card}
                end
            )
            for ____, row in ipairs(previous) do
                if not __TS__ArraySome(
                    rows,
                    function(____, next) return next.node == row.node end
                ) then
                    row.node:removeFromParent(true)
                    changed = true
                end
            end
            if not changed then
                return
            end
            layingOut = true
            scroll.offset = Vec2.zero
            total = 0
            for ____, row in ipairs(rows) do
                row.node.position = Vec2(0, height - total)
                total = total + (row.node.height + 10)
            end
            if #rows > 0 then
                total = total - 10
            end
            scroll:resetSize(width, height, width, total)
            local pinned = following and not touching
            local ____anchor_27
            if anchor then
                ____anchor_27 = __TS__ArrayFind(
                    rows,
                    function(____, row) return row.id == anchor.id end
                )
            else
                ____anchor_27 = nil
            end
            local replacement = ____anchor_27
            local offset = pinned and maxOffset() or (replacement and anchorY ~= nil and anchorY - replacement.node.y or oldOffset)
            scroll.offset = Vec2(
                0,
                math.max(
                    0,
                    math.min(
                        maxOffset(),
                        offset
                    )
                )
            )
            scroll.view:moveAndCullItems(Vec2.zero)
            layingOut = false
            if not pinned then
                unread = true
            end
            updateHint()
        end
    }
end
return ____exports
