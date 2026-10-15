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
local font = "sarasa-mono-sc-regular" -- 21
function ____exports.remixDisplayRevision(detail) -- 24
	if not detail.success then -- 24
		return detail.message -- 25
	end -- 25
	local history = remixHistory(detail) -- 26
	return (safeJsonEncode({ -- 27
		status = detail.session.status, -- 28
		mode = detail.session.workMode, -- 28
		plan = detail.hasActivePlan, -- 28
		finalizing = detail.session.currentTaskFinalizing, -- 29
		questionnaire = detail.pendingQuestionnaire, -- 29
		currentTaskId = detail.session.currentTaskId, -- 30
		currentTaskStatus = detail.session.currentTaskStatus, -- 30
		hasEarlierMessages = history.hasEarlierMessages, -- 31
		messages = __TS__ArrayMap( -- 32
			history.messages, -- 32
			function(____, m) return {m.id, m.taskId or 0, m.role, m.displayContent or m.content} end -- 32
		), -- 32
		steps = __TS__ArrayMap( -- 33
			history.steps, -- 33
			function(____, s) -- 33
				local ____array_12 = __TS__SparseArrayNew(s.id, s.tool, s.status, s.reason) -- 33
				local ____opt_0 = s.result -- 33
				__TS__SparseArrayPush(____array_12, ____opt_0 and ____opt_0.progress) -- 33
				local ____opt_2 = s.result -- 33
				__TS__SparseArrayPush(____array_12, ____opt_2 and ____opt_2.stage) -- 33
				local ____opt_4 = s.result -- 33
				__TS__SparseArrayPush(____array_12, ____opt_4 and ____opt_4.message) -- 33
				local ____opt_6 = s.result -- 33
				__TS__SparseArrayPush(____array_12, ____opt_6 and ____opt_6.assets) -- 33
				local ____opt_8 = s.result -- 33
				__TS__SparseArrayPush(____array_12, ____opt_8 and ____opt_8.report) -- 33
				local ____opt_10 = s.result -- 33
				__TS__SparseArrayPush(____array_12, ____opt_10 and ____opt_10.model) -- 33
				return {__TS__SparseArraySpread(____array_12)} -- 33
			end -- 33
		) -- 33
	})) or "" -- 33
end -- 24
local function itemsFor(detail, zh, actions) -- 37
	if not detail.success then -- 37
		return {} -- 38
	end -- 38
	local items = {} -- 39
	local history = remixHistory(detail) -- 40
	if history.hasEarlierMessages then -- 40
		items[#items + 1] = { -- 41
			id = "remix-history-limit", -- 41
			title = zh and "历史记录" or "History", -- 41
			text = zh and ("仅展示最近 " .. tostring(REMIX_HISTORY_ROUNDS)) .. " 轮，更早记录可在 Web IDE 查看。" or ("Showing the latest " .. tostring(REMIX_HISTORY_ROUNDS)) .. " rounds. View earlier messages in Web IDE.", -- 42
			user = false, -- 43
			activity = true -- 43
		} -- 43
	end -- 43
	local activities = __TS__ArrayMap( -- 44
		history.steps, -- 44
		function(____, s) -- 44
			local state = s.status == "DONE" and (zh and "已完成" or "Done") or (s.status == "FAILED" and (zh and "失败" or "Failed") or (s.status == "STOPPED" and (zh and "已停止" or "Stopped") or (s.status == "PENDING" and (zh and "等待中" or "Pending") or (zh and "进行中" or "Working")))) -- 45
			local ____temp_15 = s.status == "RUNNING" -- 49
			if ____temp_15 then -- 49
				local ____opt_13 = s.result -- 49
				____temp_15 = type(____opt_13 and ____opt_13.progress) == "number" -- 49
			end -- 49
			local progress = ____temp_15 and (" · " .. tostring(math.floor(s.result.progress * 100))) .. "%" or "" -- 49
			local vision = s.tool == "analyze_image" -- 50
			local ____temp_18 = s.status == "RUNNING" or vision -- 51
			if ____temp_18 then -- 51
				local ____opt_16 = s.result -- 51
				____temp_18 = type(____opt_16 and ____opt_16.message) == "string" -- 51
			end -- 51
			local message = ____temp_18 and s.result.message or "" -- 51
			local ____vision_21 = vision -- 52
			if ____vision_21 then -- 52
				local ____opt_19 = s.result -- 52
				____vision_21 = type(____opt_19 and ____opt_19.report) == "string" -- 52
			end -- 52
			local report = ____vision_21 and s.result.report or "" -- 52
			local ____vision_24 = vision -- 53
			if ____vision_24 then -- 53
				local ____opt_22 = s.result -- 53
				____vision_24 = type(____opt_22 and ____opt_22.model) == "string" -- 53
			end -- 53
			local model = ____vision_24 and s.result.model or "" -- 53
			local title = compactAgentActivity(s.tool, "", zh, s.status == "RUNNING") -- 54
			return { -- 55
				id = "step-" .. tostring(s.id), -- 55
				title = ((state .. progress) .. " · ") .. title, -- 55
				text = ((s.reason .. (message ~= "" and "\n" .. message or "")) .. (model ~= "" and (("\n" .. (zh and "看图模型" or "Vision model")) .. ": ") .. model or "")) .. (report ~= "" and "\n" .. report or ""), -- 56
				user = false, -- 57
				activity = true -- 57
			} -- 57
		end -- 44
	) -- 44
	local inserted = false -- 59
	for ____, m in ipairs(history.messages) do -- 60
		if not inserted and m.role == "assistant" and m.taskId == detail.session.currentTaskId then -- 60
			__TS__ArrayPushArray(items, activities) -- 63
			inserted = true -- 63
		end -- 63
		items[#items + 1] = { -- 65
			id = "message-" .. tostring(m.id), -- 65
			title = m.role == "user" and (zh and "你" or "You") or "Dora", -- 65
			text = m.displayContent or m.content, -- 66
			user = m.role == "user", -- 66
			activity = false -- 66
		} -- 66
	end -- 66
	if not inserted then -- 66
		__TS__ArrayPushArray(items, activities) -- 68
	end -- 68
	if #actions > 0 then -- 68
		items[#items + 1] = { -- 69
			id = "remix-terminal-actions", -- 69
			title = "", -- 69
			text = "", -- 69
			user = false, -- 69
			activity = true, -- 69
			actions = actions -- 69
		} -- 69
	end -- 69
	return items -- 70
end -- 37
local function drawCapsule(target, width, height, color, inset) -- 73
	if inset == nil then -- 73
		inset = 0 -- 73
	end -- 73
	local radius = height / 2 - inset -- 74
	local left = height / 2 -- 75
	local right = width - height / 2 -- 76
	target:drawPolygon( -- 77
		{ -- 77
			Vec2(left, inset), -- 77
			Vec2(right, inset), -- 77
			Vec2(right, height - inset), -- 77
			Vec2(left, height - inset) -- 77
		}, -- 77
		Color(color) -- 77
	) -- 77
	target:drawDot( -- 78
		Vec2(left, height / 2), -- 78
		radius, -- 78
		Color(color) -- 78
	) -- 78
	target:drawDot( -- 79
		Vec2(right, height / 2), -- 79
		radius, -- 79
		Color(color) -- 79
	) -- 79
end -- 73
local function makeActionRow(actions, width, scale) -- 82
	local card = Node() -- 83
	card.tag = "remix-terminal-actions" -- 84
	card.anchor = Vec2(0, 1) -- 85
	card.width = width -- 86
	card.height = 44 -- 87
	local gap = 10 -- 88
	local buttonWidth = #actions > 1 and math.min((width - gap) / 2, 184) or math.min(width, 184) -- 89
	do -- 89
		local i = 0 -- 90
		while i < #actions do -- 90
			local action = actions[i + 1] -- 91
			local button = Node() -- 92
			button.tag = "remix-action-" .. action.id -- 93
			button.anchor = Vec2.zero -- 94
			button.position = Vec2(i * (buttonWidth + gap), 3) -- 95
			button.size = Size(buttonWidth, 38) -- 96
			button.touchEnabled = true -- 97
			button.swallowTouches = true -- 98
			button:onTapped(action.onTapped) -- 99
			local bg = DrawNode() -- 100
			if action.primary then -- 100
				drawCapsule(bg, buttonWidth, 38, 4294954035) -- 101
			else -- 101
				drawCapsule(bg, buttonWidth, 38, 4282798180) -- 103
				drawCapsule( -- 104
					bg, -- 104
					buttonWidth, -- 104
					38, -- 104
					4279704614, -- 104
					1 -- 104
				) -- 104
			end -- 104
			button:addChild(bg) -- 106
			local label = Label( -- 107
				font, -- 107
				math.floor(14 * scale), -- 107
				true -- 107
			) -- 107
			if label then -- 107
				label.position = Vec2(buttonWidth / 2, 19) -- 109
				label.color3 = Color3(action.primary and 1512202 or 16052712) -- 110
				label.text = action.text -- 111
				button:addChild(label) -- 112
			end -- 112
			card:addChild(button) -- 114
			i = i + 1 -- 90
		end -- 90
	end -- 90
	return card -- 116
end -- 82
local function makeCard(item, width, scale, zh) -- 119
	if item.actions then -- 119
		return makeActionRow(item.actions, width, scale) -- 120
	end -- 120
	local card = Node() -- 121
	card.tag = item.id -- 122
	card.anchor = Vec2(0, 1) -- 123
	card.width = width -- 124
	local labels = {} -- 125
	local top = 12 -- 126
	local function add(text, size, color) -- 127
		local l = Label( -- 128
			font, -- 128
			math.floor(size * scale), -- 128
			true -- 128
		) -- 128
		if not l then -- 128
			return -- 129
		end -- 129
		l.anchor = Vec2(0, 1) -- 130
		l.x = 14 -- 130
		l.textWidth = math.max(20, width - 28) -- 130
		l.alignment = "Left" -- 131
		l.lineGap = 4 -- 131
		l.color3 = Color3(color) -- 131
		l.text = text -- 131
		labels[#labels + 1] = {label = l, top = top} -- 132
		top = top + (l.height + 8) -- 132
	end -- 127
	add(item.title, 13, (item.user or item.activity) and 16763955 or 11055037) -- 134
	for ____, block in ipairs(parseLightMarkdown(item.text)) do -- 135
		add(block.text, block.kind == "heading1" and 17 or (block.kind == "heading2" and 16 or 14), block.kind == "code" and 16763955 or 16052712) -- 136
	end -- 136
	if not item.user and not item.activity then -- 136
		add(zh and "复制全文" or "Copy message", 13, 16763955) -- 140
		local ____opt_25 = labels[#labels] -- 140
		local copy = ____opt_25 and ____opt_25.label -- 141
		if copy ~= nil then -- 141
			copy.tag = "remix-copy" -- 142
			copy.touchEnabled = true -- 142
			copy:onTapped(function() return App:setClipboardText(item.text) end) -- 142
		end -- 142
	end -- 142
	card.height = top + 4 -- 144
	local bg = DrawNode() -- 145
	bg:drawPolygon( -- 146
		{ -- 146
			Vec2.zero, -- 146
			Vec2(width, 0), -- 146
			Vec2(width, card.height), -- 146
			Vec2(0, card.height) -- 146
		}, -- 146
		Color(item.user and 4280297010 or 4279704614), -- 147
		1, -- 147
		Color(4281613128) -- 147
	) -- 147
	card:addChild(bg) -- 148
	for ____, row in ipairs(labels) do -- 149
		row.label.y = card.height - row.top -- 149
		card:addChild(row.label) -- 149
	end -- 149
	return card -- 150
end -- 119
function ____exports.createRemixTranscript() -- 153
	local node = Node() -- 154
	node.tag = "remix-transcript" -- 154
	node.anchor = Vec2.zero -- 154
	local scroll = ScrollArea({ -- 155
		width = 1, -- 155
		height = 1, -- 155
		paddingX = 0, -- 155
		paddingY = 40, -- 155
		scrollBar = false -- 155
	}) -- 155
	scroll.tag = "remix-scroll" -- 156
	scroll:addTo(node) -- 156
	local latest = Label(font, 14, true) -- 157
	latest.tag = "remix-latest" -- 158
	latest.color3 = Color3(16763955) -- 158
	latest.touchEnabled = true -- 158
	local hintBackground = DrawNode() -- 159
	hintBackground.order = 1 -- 159
	hintBackground:addTo(node) -- 159
	latest.order = 2 -- 160
	latest:addTo(node) -- 161
	local width = 1 -- 162
	local height = 1 -- 162
	local scale = 1 -- 162
	local zh = true -- 162
	local total = 0 -- 162
	local following = true -- 163
	local touching = false -- 163
	local layingOut = false -- 163
	local unread = false -- 163
	local rows = {} -- 164
	local function maxOffset() -- 165
		return math.max(0, total - height) -- 165
	end -- 165
	local function updateHint() -- 166
		latest.visible = unread and not following -- 167
		latest.text = zh and "有新内容 · 回到最新 ↓" or "New activity · Latest ↓" -- 168
		hintBackground.visible = latest.visible -- 169
		hintBackground:clear() -- 170
		local half = math.min(width / 2, latest.width / 2 + 10) -- 171
		hintBackground:drawPolygon( -- 172
			{ -- 172
				Vec2(width / 2 - half, 0), -- 172
				Vec2(width / 2 + half, 0), -- 172
				Vec2(width / 2 + half, 28), -- 172
				Vec2(width / 2 - half, 28) -- 172
			}, -- 172
			Color(4280297010) -- 172
		) -- 172
	end -- 166
	scroll:slot( -- 174
		"ScrollTouchBegan", -- 174
		function() -- 174
			touching = true -- 174
		end -- 174
	) -- 174
	scroll:slot( -- 175
		"ScrollTouchEnded", -- 175
		function() -- 175
			touching = false -- 175
			following = maxOffset() - scroll.offset.y <= 24 -- 175
			updateHint() -- 175
		end -- 175
	) -- 175
	scroll:slot( -- 176
		"Scrolled", -- 176
		function() -- 176
			if layingOut then -- 176
				return -- 177
			end -- 177
			following = maxOffset() - scroll.offset.y <= 24 -- 178
			if following then -- 178
				unread = false -- 179
			end -- 179
			updateHint() -- 180
		end -- 176
	) -- 176
	latest:onTapped(function() -- 182
		scroll:unschedule() -- 183
		touching = false -- 183
		following = true -- 183
		unread = false -- 183
		scroll.offset = Vec2( -- 184
			0, -- 184
			maxOffset() -- 184
		) -- 184
		updateHint() -- 184
	end) -- 182
	return { -- 186
		node = node, -- 187
		scrollBy = function(self, amount) -- 188
			scroll:unschedule() -- 189
			following = false -- 190
			scroll.offset = Vec2( -- 191
				0, -- 191
				math.max( -- 191
					0, -- 191
					math.min( -- 191
						maxOffset(), -- 191
						scroll.offset.y + amount -- 191
					) -- 191
				) -- 191
			) -- 191
			scroll.view:moveAndCullItems(Vec2.zero) -- 192
			following = maxOffset() - scroll.offset.y <= 24 -- 193
			if following then -- 193
				unread = false -- 194
			end -- 194
			updateHint() -- 195
		end, -- 188
		update = function(self, detail, w, h, fontScale, chinese, actions) -- 197
			if actions == nil then -- 197
				actions = {} -- 197
			end -- 197
			local anchor = __TS__ArrayFind( -- 198
				rows, -- 198
				function(____, row) return row.node.y > 0 and row.node.y - row.node.height < height end -- 198
			) -- 198
			local anchorY = anchor and anchor.node.y -- 199
			local oldOffset = scroll.offset.y -- 200
			local layoutChanged = width ~= w or height ~= h or scale ~= fontScale or zh ~= chinese -- 201
			width = w -- 202
			height = h -- 202
			scale = fontScale -- 202
			zh = chinese -- 202
			node.size = Size(width, height) -- 203
			scroll.position = Vec2(width / 2, height / 2) -- 203
			latest.position = Vec2(width / 2, 14) -- 204
			local previous = rows -- 205
			local changed = layoutChanged -- 206
			rows = __TS__ArrayMap( -- 207
				itemsFor(detail, zh, actions), -- 207
				function(____, item) -- 207
					local ____safeJsonEncode_36 = safeJsonEncode -- 208
					local ____item_id_31 = item.id -- 208
					local ____item_title_32 = item.title -- 208
					local ____item_text_33 = item.text -- 208
					local ____item_user_34 = item.user -- 208
					local ____item_activity_35 = item.activity -- 209
					local ____opt_29 = item.actions -- 209
					local signature = (____safeJsonEncode_36({ -- 208
						id = ____item_id_31, -- 208
						title = ____item_title_32, -- 208
						text = ____item_text_33, -- 208
						user = ____item_user_34, -- 208
						activity = ____item_activity_35, -- 209
						actions = ____opt_29 and __TS__ArrayMap( -- 209
							item.actions, -- 209
							function(____, action) return {action.id, action.text, action.primary == true} end -- 209
						) -- 209
					})) or "" -- 209
					local existing = __TS__ArrayFind( -- 210
						previous, -- 210
						function(____, row) return row.id == item.id end -- 210
					) -- 210
					if not layoutChanged and (existing and existing.signature) == signature then -- 210
						return existing -- 211
					end -- 211
					changed = true -- 212
					local card = makeCard(item, width, scale, zh) -- 213
					scroll.view:addChild(card) -- 213
					return {id = item.id, signature = signature, node = card} -- 214
				end -- 207
			) -- 207
			for ____, row in ipairs(previous) do -- 216
				if not __TS__ArraySome( -- 216
					rows, -- 216
					function(____, next) return next.node == row.node end -- 216
				) then -- 216
					row.node:removeFromParent(true) -- 216
					changed = true -- 216
				end -- 216
			end -- 216
			if not changed then -- 216
				return -- 217
			end -- 217
			layingOut = true -- 218
			scroll.offset = Vec2.zero -- 219
			total = 0 -- 220
			for ____, row in ipairs(rows) do -- 221
				row.node.position = Vec2(0, height - total) -- 221
				total = total + (row.node.height + 10) -- 221
			end -- 221
			if #rows > 0 then -- 221
				total = total - 10 -- 222
			end -- 222
			scroll:resetSize(width, height, width, total) -- 223
			local pinned = following and not touching -- 224
			local ____anchor_39 -- 225
			if anchor then -- 225
				____anchor_39 = __TS__ArrayFind( -- 225
					rows, -- 225
					function(____, row) return row.id == anchor.id end -- 225
				) -- 225
			else -- 225
				____anchor_39 = nil -- 225
			end -- 225
			local replacement = ____anchor_39 -- 225
			local offset = pinned and maxOffset() or (replacement and anchorY ~= nil and anchorY - replacement.node.y or oldOffset) -- 226
			scroll.offset = Vec2( -- 227
				0, -- 227
				math.max( -- 227
					0, -- 227
					math.min( -- 227
						maxOffset(), -- 227
						offset -- 227
					) -- 227
				) -- 227
			) -- 227
			scroll.view:moveAndCullItems(Vec2.zero) -- 228
			layingOut = false -- 229
			if not pinned then -- 229
				unread = true -- 230
			end -- 230
			updateHint() -- 231
		end -- 197
	} -- 197
end -- 153
return ____exports -- 153