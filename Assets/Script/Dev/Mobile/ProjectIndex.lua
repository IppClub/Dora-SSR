-- [tsx]: ProjectIndex.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Color3 = ____Dora.Color3 -- 2
local DrawNode = ____Dora.DrawNode -- 2
local Label = ____Dora.Label -- 2
local Node = ____Dora.Node -- 2
local Size = ____Dora.Size -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 3
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 4
local attachGamepad = ____Gamepad.attachGamepad -- 4
local selectGamepadNode = ____Gamepad.selectGamepadNode -- 4
local ____FeedModel = require("Dev.Mobile.FeedModel") -- 5
local groupFeedProjects = ____FeedModel.groupFeedProjects -- 5
local fontName = "sarasa-mono-sc-regular" -- 7
local headerHeight = 72 -- 8
local railWidth = 48 -- 9
local groupHeight = 36 -- 10
local rowHeight = 48 -- 11
local function ellipsize(text, limit) -- 18
	local length = (utf8.len(text)) or 0 -- 19
	if length <= limit then -- 19
		return text -- 20
	end -- 20
	local stop = utf8.offset( -- 21
		text, -- 21
		math.max(2, limit) -- 21
	) or #text -- 21
	return string.sub(text, 1, stop - 1) .. "…" -- 22
end -- 18
local function addLabel(parent, text, size, color, x, y, anchor) -- 25
	if anchor == nil then -- 25
		anchor = Vec2(0, 0.5) -- 25
	end -- 25
	local label = Label(fontName, size, true) -- 26
	label.text = text -- 27
	label.color3 = Color3(color) -- 27
	label.position = Vec2(x, y) -- 27
	label.anchor = anchor -- 27
	label.renderOrder = 15002 -- 28
	label:addTo(parent) -- 29
	return label -- 30
end -- 25
local function roundedVerts(x, y, width, height, radius) -- 33
	local verts = {} -- 34
	local r = math.max( -- 35
		0, -- 35
		math.min(radius, width / 2, height / 2) -- 35
	) -- 35
	local corners = {{x = x + width - r, y = y + r, start = -math.pi / 2}, {x = x + width - r, y = y + height - r, start = 0}, {x = x + r, y = y + height - r, start = math.pi / 2}, {x = x + r, y = y + r, start = math.pi}} -- 36
	for ____, corner in ipairs(corners) do -- 42
		do -- 42
			local step = 0 -- 43
			while step <= 6 do -- 43
				local angle = corner.start + step * math.pi / 12 -- 44
				verts[#verts + 1] = Vec2( -- 45
					corner.x + math.cos(angle) * r, -- 45
					corner.y + math.sin(angle) * r -- 45
				) -- 45
				step = step + 1 -- 43
			end -- 43
		end -- 43
	end -- 43
	return verts -- 48
end -- 33
function ____exports.ProjectIndex(props) -- 51
	local function onCreate() -- 67
		local root = Node() -- 68
		root.tag = "mobile-project-index" -- 69
		root.anchor = Vec2.zero -- 70
		root.size = Size(props.width, props.height) -- 71
		root.renderGroup = true -- 72
		root.renderOrder = 15000 -- 73
		root.touchEnabled = true -- 74
		root.swallowTouches = true -- 75
		local discover = props.kind == "discover" -- 76
		local canRefresh = discover and props.onRefresh ~= nil -- 77
		local footerHeight = canRefresh and 64 or 36 -- 78
		addLabel( -- 79
			root, -- 79
			((discover and (props.zh and "发现作品" or "DISCOVER") or (props.zh and "本地作品" or "LOCAL")) .. " · ") .. tostring(#props.entries), -- 79
			18, -- 79
			4294242792, -- 79
			16, -- 80
			props.height - 34 -- 80
		) -- 80
		local back = Node() -- 81
		back.tag = "mobile-project-index-back" -- 81
		back.anchor = Vec2.zero -- 81
		back.position = Vec2(props.width - 96, props.height - 62) -- 82
		back.size = Size(80, 44) -- 82
		back.touchEnabled = true -- 82
		back.swallowTouches = true -- 82
		back:onTapped(props.onClose) -- 83
		back:addTo(root) -- 83
		addLabel( -- 84
			back, -- 84
			props.zh and "返回 ›" or "Back ›", -- 84
			18, -- 84
			4294954035, -- 84
			80, -- 84
			22, -- 84
			Vec2(1, 0.5) -- 84
		) -- 84
		local groups = groupFeedProjects(props.entries) -- 86
		local listX = railWidth + 8 -- 87
		local listWidth = math.max(40, props.width - listX - 14) -- 88
		local listHeight = math.max(40, props.height - headerHeight - footerHeight) -- 89
		local scroll = ScrollArea({ -- 90
			width = listWidth, -- 90
			height = listHeight, -- 90
			paddingX = 0, -- 90
			paddingY = 28, -- 90
			scrollBar = false -- 90
		}) -- 90
		scroll.tag = "mobile-project-index-scroll" -- 91
		scroll.position = Vec2(listX + listWidth / 2, footerHeight + listHeight / 2) -- 91
		scroll:addTo(root) -- 91
		local flat = {} -- 92
		local groupOffsets = {} -- 93
		local total = 0 -- 94
		do -- 94
			local groupIndex = 0 -- 95
			while groupIndex < #groups do -- 95
				local group = groups[groupIndex + 1] -- 96
				groupOffsets[#groupOffsets + 1] = total -- 97
				local heading = Node() -- 98
				heading.tag = "mobile-project-index-group-" .. group.key -- 98
				heading.anchor = Vec2(0, 1) -- 99
				heading.position = Vec2(0, listHeight - total) -- 99
				heading.size = Size(listWidth, groupHeight) -- 100
				heading:addTo(scroll.view) -- 100
				local groupTitle = group.key == "#" and (props.zh and "其它" or "Other") or group.key -- 101
				local headingBg = DrawNode() -- 102
				headingBg:drawSegment( -- 103
					Vec2(38, 18), -- 103
					Vec2(listWidth - 4, 18), -- 103
					0.5, -- 103
					Color(4281613128) -- 103
				) -- 103
				headingBg:addTo(heading) -- 104
				addLabel( -- 105
					heading, -- 105
					groupTitle, -- 105
					12, -- 105
					4294954035, -- 105
					8, -- 105
					18 -- 105
				) -- 105
				total = total + groupHeight -- 106
				for ____, entry in ipairs(group.entries) do -- 107
					local row = Node() -- 108
					row.tag = "mobile-project-index-entry-" .. tostring(#flat) -- 108
					row.anchor = Vec2(0, 1) -- 108
					row.position = Vec2(0, listHeight - total) -- 109
					row.size = Size(listWidth, rowHeight) -- 109
					row.touchEnabled = true -- 110
					row.swallowTouches = true -- 110
					row:onTapped(function() return props:onSelect(entry) end) -- 110
					row:addTo(scroll.view) -- 110
					local ____temp_4 = entry == props.current -- 111
					if not ____temp_4 then -- 111
						local ____temp_3 = entry.fileName ~= nil -- 111
						if ____temp_3 then -- 111
							local ____entry_fileName_2 = entry.fileName -- 111
							local ____opt_0 = props.current -- 111
							____temp_3 = ____entry_fileName_2 == (____opt_0 and ____opt_0.fileName) -- 111
						end -- 111
						____temp_4 = ____temp_3 -- 111
					end -- 111
					local ____temp_4_9 = ____temp_4 -- 111
					if not ____temp_4_9 then -- 111
						local ____temp_8 = entry.workDir ~= nil -- 112
						if ____temp_8 then -- 112
							local ____entry_workDir_7 = entry.workDir -- 112
							local ____opt_5 = props.current -- 112
							____temp_8 = ____entry_workDir_7 == (____opt_5 and ____opt_5.workDir) -- 112
						end -- 112
						____temp_4_9 = ____temp_8 -- 111
					end -- 111
					local selected = ____temp_4_9 -- 111
					local rowBg = DrawNode() -- 113
					rowBg:drawSegment( -- 114
						Vec2(8, 1), -- 114
						Vec2(listWidth - 8, 1), -- 114
						0.5, -- 114
						Color(4280560439) -- 114
					) -- 114
					if selected then -- 114
						rowBg:drawSegment( -- 115
							Vec2(5, 13), -- 115
							Vec2(5, rowHeight - 13), -- 115
							1.5, -- 115
							Color(4294954035) -- 115
						) -- 115
					end -- 115
					rowBg:addTo(row) -- 116
					addLabel( -- 117
						row, -- 117
						ellipsize( -- 117
							entry.title, -- 117
							math.max( -- 117
								8, -- 117
								math.floor((listWidth - 54) / 9) -- 117
							) -- 117
						), -- 117
						14, -- 117
						selected and 4294954035 or 4294242792, -- 118
						16, -- 118
						rowHeight / 2 -- 118
					) -- 118
					flat[#flat + 1] = {entry = entry, node = row, groupIndex = groupIndex, centerFromTop = total + rowHeight / 2} -- 119
					total = total + rowHeight -- 120
				end -- 120
				groupIndex = groupIndex + 1 -- 95
			end -- 95
		end -- 95
		if #groups == 0 then -- 95
			addLabel( -- 124
				scroll.view, -- 124
				discover and (props.zh and "暂无发现作品" or "No discovered games yet") or (props.zh and "还没有本地作品" or "No local games yet"), -- 124
				14, -- 124
				4286021260, -- 124
				listWidth / 2, -- 125
				listHeight / 2, -- 125
				Vec2(0.5, 0.5) -- 125
			) -- 125
		end -- 125
		scroll:resetSize(listWidth, listHeight, listWidth, total) -- 127
		local function maxOffset() -- 128
			return math.max(0, total - listHeight) -- 128
		end -- 128
		local function scrollTo(centerFromTop) -- 129
			scroll:unschedule() -- 130
			scroll.offset = Vec2( -- 130
				0, -- 130
				math.max( -- 130
					0, -- 130
					math.min( -- 130
						maxOffset(), -- 130
						centerFromTop - listHeight / 2 -- 130
					) -- 130
				) -- 130
			) -- 130
			scroll.view:moveAndCullItems(Vec2.zero) -- 131
		end -- 129
		local selectedIndex = math.max( -- 133
			0, -- 133
			__TS__ArrayFindIndex( -- 133
				flat, -- 133
				function(____, item) -- 133
					local ____temp_14 = item.entry == props.current -- 133
					if not ____temp_14 then -- 133
						local ____temp_13 = item.entry.fileName ~= nil -- 134
						if ____temp_13 then -- 134
							local ____item_entry_fileName_12 = item.entry.fileName -- 134
							local ____opt_10 = props.current -- 134
							____temp_13 = ____item_entry_fileName_12 == (____opt_10 and ____opt_10.fileName) -- 134
						end -- 134
						____temp_14 = ____temp_13 -- 133
					end -- 133
					local ____temp_14_19 = ____temp_14 -- 133
					if not ____temp_14_19 then -- 133
						local ____temp_18 = item.entry.workDir ~= nil -- 135
						if ____temp_18 then -- 135
							local ____item_entry_workDir_17 = item.entry.workDir -- 135
							local ____opt_15 = props.current -- 135
							____temp_18 = ____item_entry_workDir_17 == (____opt_15 and ____opt_15.workDir) -- 135
						end -- 135
						____temp_14_19 = ____temp_18 -- 133
					end -- 133
					return ____temp_14_19 -- 133
				end -- 133
			) -- 133
		) -- 133
		if flat[selectedIndex + 1] ~= nil then -- 133
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 136
		end -- 136
		local popup = Node() -- 138
		popup.visible = false -- 138
		popup.position = Vec2(railWidth + 48, props.height / 2) -- 138
		popup:addTo(root) -- 138
		local popupShape = DrawNode() -- 139
		popupShape:drawPolygon( -- 140
			roundedVerts( -- 140
				-28, -- 140
				-28, -- 140
				56, -- 140
				56, -- 140
				16 -- 140
			), -- 140
			Color(4279704614), -- 140
			1, -- 140
			Color(4286606108) -- 140
		) -- 140
		popupShape:addTo(popup) -- 140
		local popupLabel = addLabel( -- 141
			popup, -- 141
			"", -- 141
			18, -- 141
			4294954035, -- 141
			0, -- 141
			0, -- 141
			Vec2(0.5, 0.5) -- 141
		) -- 141
		popupLabel.tag = "mobile-project-index-popup-label" -- 142
		local rail = Node() -- 143
		rail.tag = "mobile-project-index-rail" -- 143
		rail.anchor = Vec2.zero -- 143
		rail.position = Vec2(0, footerHeight) -- 144
		rail.size = Size(railWidth, listHeight) -- 144
		rail.touchEnabled = #groups > 0 -- 145
		rail.swallowTouches = true -- 145
		rail:addTo(root) -- 145
		local railLabels = {} -- 146
		do -- 146
			local i = 0 -- 147
			while i < #groups do -- 147
				local y = listHeight - (i + 0.5) * listHeight / #groups -- 148
				railLabels[#railLabels + 1] = addLabel( -- 149
					rail, -- 149
					groups[i + 1].key, -- 149
					#groups > 20 and 9 or 11, -- 149
					4286021260, -- 149
					railWidth / 2, -- 149
					y, -- 149
					Vec2(0.5, 0.5) -- 149
				) -- 149
				i = i + 1 -- 147
			end -- 147
		end -- 147
		local ____opt_20 = flat[selectedIndex + 1] -- 147
		local activeGroup = ____opt_20 and ____opt_20.groupIndex or 0 -- 151
		local function selectGroup(groupIndex, showPopup, jump) -- 152
			if jump == nil then -- 152
				jump = true -- 152
			end -- 152
			if #groups == 0 then -- 152
				return -- 153
			end -- 153
			activeGroup = math.max( -- 154
				0, -- 154
				math.min(#groups - 1, groupIndex) -- 154
			) -- 154
			if jump then -- 154
				scroll:unschedule() -- 156
				scroll.offset = Vec2( -- 156
					0, -- 156
					math.max( -- 156
						0, -- 156
						math.min( -- 156
							maxOffset(), -- 156
							groupOffsets[activeGroup + 1] -- 156
						) -- 156
					) -- 156
				) -- 156
				scroll.view:moveAndCullItems(Vec2.zero) -- 157
			end -- 157
			do -- 157
				local i = 0 -- 159
				while i < #railLabels do -- 159
					railLabels[i + 1].color3 = Color3(i == activeGroup and 4294954035 or 7831180) -- 159
					i = i + 1 -- 159
				end -- 159
			end -- 159
			popupLabel.text = groups[activeGroup + 1].key == "#" and (props.zh and "其它" or "Other") or groups[activeGroup + 1].key -- 160
			popup.visible = showPopup -- 161
		end -- 152
		selectGroup(activeGroup, false, false) -- 163
		local function groupAt(worldLocation) -- 164
			if #groups == 0 then -- 164
				return 0 -- 165
			end -- 165
			local point = rail:convertToNodeSpace(worldLocation) -- 166
			popup.y = footerHeight + math.max( -- 167
				32, -- 167
				math.min(listHeight - 32, point.y) -- 167
			) -- 167
			return math.max( -- 168
				0, -- 168
				math.min( -- 168
					#groups - 1, -- 168
					math.floor((listHeight - point.y) / listHeight * #groups) -- 168
				) -- 168
			) -- 168
		end -- 164
		rail:onTapBegan(function(touch) return selectGroup( -- 170
			groupAt(touch.worldLocation), -- 170
			true -- 170
		) end) -- 170
		rail:onTapMoved(function(touch) return selectGroup( -- 171
			groupAt(touch.worldLocation), -- 171
			true -- 171
		) end) -- 171
		rail:onTapEnded(function() -- 172
			popup.visible = false -- 172
		end) -- 172
		local hint = props.zh and "拖动左侧刻度快速定位" or "Drag the index to jump" -- 174
		if canRefresh then -- 174
			local refresh = Node() -- 176
			refresh.tag = "mobile-project-index-refresh" -- 176
			refresh.anchor = Vec2.zero -- 177
			refresh.position = Vec2(16, 10) -- 177
			refresh.size = Size(76, 44) -- 177
			refresh.touchEnabled = not props.refreshing -- 178
			refresh.swallowTouches = true -- 178
			refresh:onTapped(function() -- 179
				if not props.refreshing then -- 179
					local ____this_23 -- 179
					____this_23 = props -- 179
					local ____opt_22 = ____this_23.onRefresh -- 179
					if ____opt_22 ~= nil then -- 179
						____opt_22(____this_23) -- 179
					end -- 179
				end -- 179
			end) -- 179
			refresh:addTo(root) -- 179
			local border = DrawNode() -- 180
			border.renderOrder = 15001 -- 180
			border:drawPolygon( -- 181
				roundedVerts( -- 181
					0, -- 181
					6, -- 181
					76, -- 181
					32, -- 181
					16 -- 181
				), -- 181
				Color(0), -- 181
				0.5, -- 181
				Color(props.refreshing and 4281613128 or 4286606108) -- 181
			) -- 181
			border:addTo(refresh) -- 181
			addLabel( -- 182
				refresh, -- 182
				props.refreshing and (props.zh and "刷新中…" or "Syncing…") or (props.zh and "刷新" or "Refresh"), -- 182
				12, -- 182
				props.refreshing and 4289245117 or 4294954035, -- 183
				38, -- 183
				22, -- 183
				Vec2(0.5, 0.5) -- 183
			) -- 183
			local status = addLabel( -- 184
				root, -- 184
				"", -- 184
				11, -- 184
				4289245117, -- 184
				104, -- 184
				32 -- 184
			) -- 184
			status.tag = "mobile-project-index-refresh-status" -- 185
			local function update(message) -- 186
				status.text = ellipsize( -- 186
					(string.gsub(message ~= "" and message or hint, "[\r\n]+", " ")), -- 186
					math.max( -- 186
						4, -- 186
						math.floor((props.width - 120) / 11) -- 186
					) -- 186
				) -- 186
			end -- 186
			update(props.refreshStatus or "") -- 187
			local ____this_25 -- 187
			____this_25 = props -- 187
			local ____opt_24 = ____this_25.onStatusReady -- 187
			if ____opt_24 ~= nil then -- 187
				____opt_24(____this_25, update) -- 187
			end -- 187
		else -- 187
			addLabel( -- 188
				root, -- 188
				hint, -- 188
				9, -- 188
				4286021260, -- 188
				props.width / 2, -- 188
				footerHeight / 2, -- 188
				Vec2(0.5, 0.5) -- 188
			) -- 188
		end -- 188
		local function moveSelection(delta) -- 189
			if #flat == 0 then -- 189
				return -- 190
			end -- 190
			selectedIndex = math.max( -- 191
				0, -- 191
				math.min(#flat - 1, selectedIndex + delta) -- 191
			) -- 191
			activeGroup = flat[selectedIndex + 1].groupIndex -- 192
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 192
			selectGroup(activeGroup, false, false) -- 193
			selectGamepadNode(root, flat[selectedIndex + 1].node.tag) -- 193
		end -- 189
		local ____opt_26 = flat[selectedIndex + 1] -- 189
		local gamepadOptions = { -- 195
			initialTag = ____opt_26 and ____opt_26.node.tag or "mobile-project-index-back", -- 196
			onBack = function() return props:onClose() end, -- 197
			onScroll = function(amount) -- 198
				scroll:unschedule() -- 198
				scroll.offset = Vec2( -- 198
					0, -- 198
					math.max( -- 198
						0, -- 198
						math.min( -- 198
							maxOffset(), -- 198
							scroll.offset.y + amount -- 198
						) -- 198
					) -- 198
				) -- 198
				scroll.view:moveAndCullItems(Vec2.zero) -- 198
			end, -- 198
			onButton = function(button) -- 199
				if button == "x" and canRefresh then -- 199
					if not props.refreshing then -- 199
						local ____this_29 -- 199
						____this_29 = props -- 200
						local ____opt_28 = ____this_29.onRefresh -- 200
						if ____opt_28 ~= nil then -- 200
							____opt_28(____this_29) -- 200
						end -- 200
					end -- 200
					return true -- 200
				end -- 200
				if button == "dpup" then -- 200
					moveSelection(-1) -- 201
					return true -- 201
				end -- 201
				if button == "dpdown" then -- 201
					moveSelection(1) -- 202
					return true -- 202
				end -- 202
				if button == "dpleft" or button == "dpright" then -- 202
					local nextGroup = math.max( -- 204
						0, -- 204
						math.min(#groups - 1, activeGroup + (button == "dpright" and 1 or -1)) -- 204
					) -- 204
					local next = __TS__ArrayFindIndex( -- 205
						flat, -- 205
						function(____, item) return item.groupIndex == nextGroup end -- 205
					) -- 205
					if next >= 0 then -- 205
						selectedIndex = next -- 206
						moveSelection(0) -- 206
					end -- 206
					return true -- 207
				end -- 207
				if button == "a" and flat[selectedIndex + 1] then -- 207
					props:onSelect(flat[selectedIndex + 1].entry) -- 209
					return true -- 209
				end -- 209
				return false -- 210
			end -- 199
		} -- 199
		root:schedule(function() -- 215
			attachGamepad(root, gamepadOptions) -- 215
			return true -- 215
		end) -- 215
		return root -- 216
	end -- 67
	return React.createElement("custom-node", { -- 218
		tag = "mobile-project-index-container", -- 218
		x = props.x, -- 218
		y = props.y, -- 218
		width = props.width, -- 218
		height = props.height, -- 218
		order = 15000, -- 218
		renderOrder = 15000, -- 218
		onCreate = onCreate -- 218
	}) -- 218
end -- 51
return ____exports -- 51