-- [ts]: RemixTranscript.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayPushArray = ____lualib.__TS__ArrayPushArray -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Color3 = ____Dora.Color3 -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 2
local ____Utils = require("Agent.Utils") -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local ____RemixModel = require("Dev.Mobile.RemixModel") -- 5
local compactAgentActivity = ____RemixModel.compactAgentActivity -- 5
local ____LightMarkdown = require("Dev.Mobile.LightMarkdown") -- 6
local parseLightMarkdown = ____LightMarkdown.parseLightMarkdown -- 6
local ____RemixHistory = require("Dev.Mobile.RemixHistory") -- 7
local remixHistory = ____RemixHistory.remixHistory -- 7
local REMIX_HISTORY_ROUNDS = ____RemixHistory.REMIX_HISTORY_ROUNDS -- 7
local font = "sarasa-mono-sc-regular" -- 14
function ____exports.remixDisplayRevision(detail) -- 17
	if not detail.success then -- 17
		return detail.message -- 18
	end -- 18
	local history = remixHistory(detail) -- 19
	return (safeJsonEncode({ -- 20
		status = detail.session.status, -- 21
		mode = detail.session.workMode, -- 21
		plan = detail.hasActivePlan, -- 21
		finalizing = detail.session.currentTaskFinalizing, -- 22
		questionnaire = detail.pendingQuestionnaire, -- 22
		currentTaskId = detail.session.currentTaskId, -- 23
		hasEarlierMessages = history.hasEarlierMessages, -- 23
		messages = __TS__ArrayMap( -- 24
			history.messages, -- 24
			function(____, m) return {m.id, m.taskId or 0, m.role, m.displayContent or m.content} end -- 24
		), -- 24
		steps = __TS__ArrayMap( -- 25
			history.steps, -- 25
			function(____, s) -- 25
				local ____array_6 = __TS__SparseArrayNew(s.id, s.tool, s.status, s.reason) -- 25
				local ____opt_0 = s.result -- 25
				__TS__SparseArrayPush(____array_6, ____opt_0 and ____opt_0.progress) -- 25
				local ____opt_2 = s.result -- 25
				__TS__SparseArrayPush(____array_6, ____opt_2 and ____opt_2.stage) -- 25
				local ____opt_4 = s.result -- 25
				__TS__SparseArrayPush(____array_6, ____opt_4 and ____opt_4.message) -- 25
				return {__TS__SparseArraySpread(____array_6)} -- 25
			end -- 25
		) -- 25
	})) or "" -- 25
end -- 17
local function itemsFor(detail, zh) -- 29
	if not detail.success then -- 29
		return {} -- 30
	end -- 30
	local items = {} -- 31
	local history = remixHistory(detail) -- 32
	if history.hasEarlierMessages then -- 32
		items[#items + 1] = { -- 33
			id = "remix-history-limit", -- 33
			title = zh and "历史记录" or "History", -- 33
			text = zh and ("仅展示最近 " .. tostring(REMIX_HISTORY_ROUNDS)) .. " 轮，更早记录可在 Web IDE 查看。" or ("Showing the latest " .. tostring(REMIX_HISTORY_ROUNDS)) .. " rounds. View earlier messages in Web IDE.", -- 34
			user = false, -- 35
			activity = true -- 35
		} -- 35
	end -- 35
	local activities = __TS__ArrayMap( -- 36
		history.steps, -- 36
		function(____, s) -- 36
			local state = s.status == "DONE" and (zh and "已完成" or "Done") or (s.status == "FAILED" and (zh and "失败" or "Failed") or (s.status == "STOPPED" and (zh and "已停止" or "Stopped") or (s.status == "PENDING" and (zh and "等待中" or "Pending") or (zh and "进行中" or "Working")))) -- 37
			local ____temp_9 = s.status == "RUNNING" -- 41
			if ____temp_9 then -- 41
				local ____opt_7 = s.result -- 41
				____temp_9 = type(____opt_7 and ____opt_7.progress) == "number" -- 41
			end -- 41
			local progress = ____temp_9 and (" · " .. tostring(math.floor(s.result.progress * 100))) .. "%" or "" -- 41
			local ____temp_12 = s.status == "RUNNING" -- 42
			if ____temp_12 then -- 42
				local ____opt_10 = s.result -- 42
				____temp_12 = type(____opt_10 and ____opt_10.message) == "string" -- 42
			end -- 42
			local message = ____temp_12 and s.result.message or "" -- 42
			local activity = compactAgentActivity(s.tool, "", zh) -- 43
			local title = s.status == "RUNNING" and activity or (string.gsub(activity, "正在", "")) -- 44
			return { -- 45
				id = "step-" .. tostring(s.id), -- 45
				title = ((state .. progress) .. " · ") .. title, -- 45
				text = s.reason .. (message ~= "" and "\n" .. message or ""), -- 46
				user = false, -- 46
				activity = true -- 46
			} -- 46
		end -- 36
	) -- 36
	local inserted = false -- 48
	for ____, m in ipairs(history.messages) do -- 49
		if not inserted and m.role == "assistant" and m.taskId == detail.session.currentTaskId then -- 49
			__TS__ArrayPushArray(items, activities) -- 52
			inserted = true -- 52
		end -- 52
		items[#items + 1] = { -- 54
			id = "message-" .. tostring(m.id), -- 54
			title = m.role == "user" and (zh and "你" or "You") or "Dora", -- 54
			text = m.displayContent or m.content, -- 55
			user = m.role == "user", -- 55
			activity = false -- 55
		} -- 55
	end -- 55
	if not inserted then -- 55
		__TS__ArrayPushArray(items, activities) -- 57
	end -- 57
	return items -- 58
end -- 29
local function makeCard(item, width, scale, zh) -- 61
	local card = Node() -- 62
	card.tag = item.id -- 63
	card.anchor = Vec2(0, 1) -- 64
	card.width = width -- 65
	local labels = {} -- 66
	local top = 12 -- 67
	local function add(text, size, color) -- 68
		local l = Label( -- 69
			font, -- 69
			math.floor(size * scale), -- 69
			true -- 69
		) -- 69
		if not l then -- 69
			return -- 70
		end -- 70
		l.anchor = Vec2(0, 1) -- 71
		l.x = 14 -- 71
		l.textWidth = math.max(20, width - 28) -- 71
		l.alignment = "Left" -- 72
		l.lineGap = 4 -- 72
		l.color3 = Color3(color) -- 72
		l.text = text -- 72
		labels[#labels + 1] = {label = l, top = top} -- 73
		top = top + (l.height + 8) -- 73
	end -- 68
	add(item.title, 13, (item.user or item.activity) and 16763955 or 11055037) -- 75
	for ____, block in ipairs(parseLightMarkdown(item.text)) do -- 76
		add(block.text, block.kind == "heading1" and 17 or (block.kind == "heading2" and 16 or 14), block.kind == "code" and 16763955 or 16052712) -- 77
	end -- 77
	if not item.user and not item.activity then -- 77
		add(zh and "复制全文" or "Copy message", 13, 16763955) -- 81
		local ____opt_13 = labels[#labels] -- 81
		local copy = ____opt_13 and ____opt_13.label -- 82
		if copy ~= nil then -- 82
			copy.tag = "remix-copy" -- 83
			copy.touchEnabled = true -- 83
			copy:onTapped(function() return App:setClipboardText(item.text) end) -- 83
		end -- 83
	end -- 83
	card.height = top + 4 -- 85
	local bg = DrawNode() -- 86
	bg:drawPolygon( -- 87
		{ -- 87
			Vec2.zero, -- 87
			Vec2(width, 0), -- 87
			Vec2(width, card.height), -- 87
			Vec2(0, card.height) -- 87
		}, -- 87
		Color(item.user and 4280297010 or 4279704614), -- 88
		1, -- 88
		Color(4281613128) -- 88
	) -- 88
	card:addChild(bg) -- 89
	for ____, row in ipairs(labels) do -- 90
		row.label.y = card.height - row.top -- 90
		card:addChild(row.label) -- 90
	end -- 90
	return card -- 91
end -- 61
function ____exports.createRemixTranscript() -- 94
	local node = Node() -- 95
	node.tag = "remix-transcript" -- 95
	node.anchor = Vec2.zero -- 95
	local scroll = ScrollArea({ -- 96
		width = 1, -- 96
		height = 1, -- 96
		paddingX = 0, -- 96
		paddingY = 40, -- 96
		scrollBar = false -- 96
	}) -- 96
	scroll.tag = "remix-scroll" -- 97
	scroll:addTo(node) -- 97
	local latest = Label(font, 14, true) -- 98
	latest.tag = "remix-latest" -- 99
	latest.color3 = Color3(16763955) -- 99
	latest.touchEnabled = true -- 99
	local hintBackground = DrawNode() -- 100
	hintBackground.order = 1 -- 100
	hintBackground:addTo(node) -- 100
	latest.order = 2 -- 101
	latest:addTo(node) -- 102
	local width = 1 -- 103
	local height = 1 -- 103
	local scale = 1 -- 103
	local zh = true -- 103
	local total = 0 -- 103
	local following = true -- 104
	local touching = false -- 104
	local layingOut = false -- 104
	local unread = false -- 104
	local rows = {} -- 105
	local function maxOffset() -- 106
		return math.max(0, total - height) -- 106
	end -- 106
	local function updateHint() -- 107
		latest.visible = unread and not following -- 108
		latest.text = zh and "有新内容 · 回到最新 ↓" or "New activity · Latest ↓" -- 109
		hintBackground.visible = latest.visible -- 110
		hintBackground:clear() -- 111
		local half = math.min(width / 2, latest.width / 2 + 10) -- 112
		hintBackground:drawPolygon( -- 113
			{ -- 113
				Vec2(width / 2 - half, 0), -- 113
				Vec2(width / 2 + half, 0), -- 113
				Vec2(width / 2 + half, 28), -- 113
				Vec2(width / 2 - half, 28) -- 113
			}, -- 113
			Color(4280297010) -- 113
		) -- 113
	end -- 107
	scroll:slot( -- 115
		"ScrollTouchBegan", -- 115
		function() -- 115
			touching = true -- 115
		end -- 115
	) -- 115
	scroll:slot( -- 116
		"ScrollTouchEnded", -- 116
		function() -- 116
			touching = false -- 116
			following = maxOffset() - scroll.offset.y <= 24 -- 116
			updateHint() -- 116
		end -- 116
	) -- 116
	scroll:slot( -- 117
		"Scrolled", -- 117
		function() -- 117
			if layingOut then -- 117
				return -- 118
			end -- 118
			following = maxOffset() - scroll.offset.y <= 24 -- 119
			if following then -- 119
				unread = false -- 120
			end -- 120
			updateHint() -- 121
		end -- 117
	) -- 117
	latest:onTapped(function() -- 123
		scroll:unschedule() -- 124
		touching = false -- 124
		following = true -- 124
		unread = false -- 124
		scroll.offset = Vec2( -- 125
			0, -- 125
			maxOffset() -- 125
		) -- 125
		updateHint() -- 125
	end) -- 123
	return { -- 127
		node = node, -- 128
		update = function(self, detail, w, h, fontScale, chinese) -- 129
			local anchor = __TS__ArrayFind( -- 130
				rows, -- 130
				function(____, row) return row.node.y > 0 and row.node.y - row.node.height < height end -- 130
			) -- 130
			local anchorY = anchor and anchor.node.y -- 131
			local oldOffset = scroll.offset.y -- 132
			local layoutChanged = width ~= w or height ~= h or scale ~= fontScale or zh ~= chinese -- 133
			width = w -- 134
			height = h -- 134
			scale = fontScale -- 134
			zh = chinese -- 134
			node.size = Size(width, height) -- 135
			scroll.position = Vec2(width / 2, height / 2) -- 135
			latest.position = Vec2(width / 2, 14) -- 136
			local previous = rows -- 137
			local changed = layoutChanged -- 138
			rows = __TS__ArrayMap( -- 139
				itemsFor(detail, zh), -- 139
				function(____, item) -- 139
					local signature = (safeJsonEncode(item)) or "" -- 140
					local existing = __TS__ArrayFind( -- 141
						previous, -- 141
						function(____, row) return row.id == item.id end -- 141
					) -- 141
					if not layoutChanged and (existing and existing.signature) == signature then -- 141
						return existing -- 142
					end -- 142
					changed = true -- 143
					local card = makeCard(item, width, scale, zh) -- 144
					scroll.view:addChild(card) -- 144
					return {id = item.id, signature = signature, node = card} -- 145
				end -- 139
			) -- 139
			for ____, row in ipairs(previous) do -- 147
				if not __TS__ArraySome( -- 147
					rows, -- 147
					function(____, next) return next.node == row.node end -- 147
				) then -- 147
					row.node:removeFromParent(true) -- 147
					changed = true -- 147
				end -- 147
			end -- 147
			if not changed then -- 147
				return -- 148
			end -- 148
			layingOut = true -- 149
			scroll.offset = Vec2.zero -- 150
			total = 0 -- 151
			for ____, row in ipairs(rows) do -- 152
				row.node.position = Vec2(0, height - total) -- 152
				total = total + (row.node.height + 10) -- 152
			end -- 152
			if #rows > 0 then -- 152
				total = total - 10 -- 153
			end -- 153
			scroll:resetSize(width, height, width, total) -- 154
			local pinned = following and not touching -- 155
			local ____anchor_19 -- 156
			if anchor then -- 156
				____anchor_19 = __TS__ArrayFind( -- 156
					rows, -- 156
					function(____, row) return row.id == anchor.id end -- 156
				) -- 156
			else -- 156
				____anchor_19 = nil -- 156
			end -- 156
			local replacement = ____anchor_19 -- 156
			local offset = pinned and maxOffset() or (replacement and anchorY ~= nil and anchorY - replacement.node.y or oldOffset) -- 157
			scroll.offset = Vec2( -- 158
				0, -- 158
				math.max( -- 158
					0, -- 158
					math.min( -- 158
						maxOffset(), -- 158
						offset -- 158
					) -- 158
				) -- 158
			) -- 158
			scroll.view:moveAndCullItems(Vec2.zero) -- 159
			layingOut = false -- 160
			if not pinned then -- 160
				unread = true -- 161
			end -- 161
			updateHint() -- 162
		end -- 129
	} -- 129
end -- 94
return ____exports -- 94