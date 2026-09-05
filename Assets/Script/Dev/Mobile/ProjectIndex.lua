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
local footerHeight = 36 -- 9
local railWidth = 48 -- 10
local groupHeight = 36 -- 11
local rowHeight = 48 -- 12
local function ellipsize(text, limit) -- 19
	local length = (utf8.len(text)) or 0 -- 20
	if length <= limit then -- 20
		return text -- 21
	end -- 21
	local stop = utf8.offset( -- 22
		text, -- 22
		math.max(2, limit) -- 22
	) or #text -- 22
	return string.sub(text, 1, stop - 1) .. "…" -- 23
end -- 19
local function addLabel(parent, text, size, color, x, y, anchor) -- 26
	if anchor == nil then -- 26
		anchor = Vec2(0, 0.5) -- 26
	end -- 26
	local label = Label(fontName, size, true) -- 27
	label.text = text -- 28
	label.color3 = Color3(color) -- 28
	label.position = Vec2(x, y) -- 28
	label.anchor = anchor -- 28
	label.renderOrder = 15002 -- 29
	label:addTo(parent) -- 30
	return label -- 31
end -- 26
local function roundedVerts(x, y, width, height, radius) -- 34
	local verts = {} -- 35
	local r = math.max( -- 36
		0, -- 36
		math.min(radius, width / 2, height / 2) -- 36
	) -- 36
	local corners = {{x = x + width - r, y = y + r, start = -math.pi / 2}, {x = x + width - r, y = y + height - r, start = 0}, {x = x + r, y = y + height - r, start = math.pi / 2}, {x = x + r, y = y + r, start = math.pi}} -- 37
	for ____, corner in ipairs(corners) do -- 43
		do -- 43
			local step = 0 -- 44
			while step <= 6 do -- 44
				local angle = corner.start + step * math.pi / 12 -- 45
				verts[#verts + 1] = Vec2( -- 46
					corner.x + math.cos(angle) * r, -- 46
					corner.y + math.sin(angle) * r -- 46
				) -- 46
				step = step + 1 -- 44
			end -- 44
		end -- 44
	end -- 44
	return verts -- 49
end -- 34
function ____exports.ProjectIndex(props) -- 52
	local function onCreate() -- 63
		local root = Node() -- 64
		root.tag = "mobile-project-index" -- 65
		root.anchor = Vec2.zero -- 66
		root.size = Size(props.width, props.height) -- 67
		root.renderGroup = true -- 68
		root.renderOrder = 15000 -- 69
		root.touchEnabled = true -- 70
		root.swallowTouches = true -- 71
		addLabel( -- 72
			root, -- 72
			((props.zh and "本地作品" or "LOCAL") .. " · ") .. tostring(#props.entries), -- 72
			18, -- 72
			4294242792, -- 72
			16, -- 73
			props.height - 34 -- 73
		) -- 73
		local back = Node() -- 74
		back.tag = "mobile-project-index-back" -- 74
		back.anchor = Vec2.zero -- 74
		back.position = Vec2(props.width - 96, props.height - 62) -- 75
		back.size = Size(80, 44) -- 75
		back.touchEnabled = true -- 75
		back.swallowTouches = true -- 75
		back:onTapped(props.onClose) -- 76
		back:addTo(root) -- 76
		addLabel( -- 77
			back, -- 77
			props.zh and "返回 ›" or "Back ›", -- 77
			18, -- 77
			4294954035, -- 77
			80, -- 77
			22, -- 77
			Vec2(1, 0.5) -- 77
		) -- 77
		local groups = groupFeedProjects(props.entries) -- 79
		local listX = railWidth + 8 -- 80
		local listWidth = math.max(40, props.width - listX - 14) -- 81
		local listHeight = math.max(40, props.height - headerHeight - footerHeight) -- 82
		local scroll = ScrollArea({ -- 83
			width = listWidth, -- 83
			height = listHeight, -- 83
			paddingX = 0, -- 83
			paddingY = 28, -- 83
			scrollBar = false -- 83
		}) -- 83
		scroll.tag = "mobile-project-index-scroll" -- 84
		scroll.position = Vec2(listX + listWidth / 2, footerHeight + listHeight / 2) -- 84
		scroll:addTo(root) -- 84
		local flat = {} -- 85
		local groupOffsets = {} -- 86
		local total = 0 -- 87
		do -- 87
			local groupIndex = 0 -- 88
			while groupIndex < #groups do -- 88
				local group = groups[groupIndex + 1] -- 89
				groupOffsets[#groupOffsets + 1] = total -- 90
				local heading = Node() -- 91
				heading.tag = "mobile-project-index-group-" .. group.key -- 91
				heading.anchor = Vec2(0, 1) -- 92
				heading.position = Vec2(0, listHeight - total) -- 92
				heading.size = Size(listWidth, groupHeight) -- 93
				heading:addTo(scroll.view) -- 93
				local groupTitle = group.key == "#" and (props.zh and "其它" or "Other") or group.key -- 94
				local headingBg = DrawNode() -- 95
				headingBg:drawSegment( -- 96
					Vec2(38, 18), -- 96
					Vec2(listWidth - 4, 18), -- 96
					0.5, -- 96
					Color(4281613128) -- 96
				) -- 96
				headingBg:addTo(heading) -- 97
				addLabel( -- 98
					heading, -- 98
					groupTitle, -- 98
					12, -- 98
					4294954035, -- 98
					8, -- 98
					18 -- 98
				) -- 98
				total = total + groupHeight -- 99
				for ____, entry in ipairs(group.entries) do -- 100
					local row = Node() -- 101
					row.tag = "mobile-project-index-entry-" .. tostring(#flat) -- 101
					row.anchor = Vec2(0, 1) -- 101
					row.position = Vec2(0, listHeight - total) -- 102
					row.size = Size(listWidth, rowHeight) -- 102
					row.touchEnabled = true -- 103
					row.swallowTouches = true -- 103
					row:onTapped(function() return props:onSelect(entry) end) -- 103
					row:addTo(scroll.view) -- 103
					local ____temp_4 = entry == props.current -- 104
					if not ____temp_4 then -- 104
						local ____temp_3 = entry.fileName ~= nil -- 104
						if ____temp_3 then -- 104
							local ____entry_fileName_2 = entry.fileName -- 104
							local ____opt_0 = props.current -- 104
							____temp_3 = ____entry_fileName_2 == (____opt_0 and ____opt_0.fileName) -- 104
						end -- 104
						____temp_4 = ____temp_3 -- 104
					end -- 104
					local ____temp_4_9 = ____temp_4 -- 104
					if not ____temp_4_9 then -- 104
						local ____temp_8 = entry.workDir ~= nil -- 105
						if ____temp_8 then -- 105
							local ____entry_workDir_7 = entry.workDir -- 105
							local ____opt_5 = props.current -- 105
							____temp_8 = ____entry_workDir_7 == (____opt_5 and ____opt_5.workDir) -- 105
						end -- 105
						____temp_4_9 = ____temp_8 -- 104
					end -- 104
					local selected = ____temp_4_9 -- 104
					local rowBg = DrawNode() -- 106
					rowBg:drawSegment( -- 107
						Vec2(8, 1), -- 107
						Vec2(listWidth - 8, 1), -- 107
						0.5, -- 107
						Color(4280560439) -- 107
					) -- 107
					if selected then -- 107
						rowBg:drawSegment( -- 108
							Vec2(5, 13), -- 108
							Vec2(5, rowHeight - 13), -- 108
							1.5, -- 108
							Color(4294954035) -- 108
						) -- 108
					end -- 108
					rowBg:addTo(row) -- 109
					addLabel( -- 110
						row, -- 110
						ellipsize( -- 110
							entry.title, -- 110
							math.max( -- 110
								8, -- 110
								math.floor((listWidth - 54) / 9) -- 110
							) -- 110
						), -- 110
						14, -- 110
						selected and 4294954035 or 4294242792, -- 111
						16, -- 111
						rowHeight / 2 -- 111
					) -- 111
					flat[#flat + 1] = {entry = entry, node = row, groupIndex = groupIndex, centerFromTop = total + rowHeight / 2} -- 112
					total = total + rowHeight -- 113
				end -- 113
				groupIndex = groupIndex + 1 -- 88
			end -- 88
		end -- 88
		if #groups == 0 then -- 88
			addLabel( -- 117
				scroll.view, -- 117
				props.zh and "还没有本地作品" or "No local games yet", -- 117
				14, -- 117
				4286021260, -- 117
				listWidth / 2, -- 118
				listHeight / 2, -- 118
				Vec2(0.5, 0.5) -- 118
			) -- 118
		end -- 118
		scroll:resetSize(listWidth, listHeight, listWidth, total) -- 120
		local function maxOffset() -- 121
			return math.max(0, total - listHeight) -- 121
		end -- 121
		local function scrollTo(centerFromTop) -- 122
			scroll:unschedule() -- 123
			scroll.offset = Vec2( -- 123
				0, -- 123
				math.max( -- 123
					0, -- 123
					math.min( -- 123
						maxOffset(), -- 123
						centerFromTop - listHeight / 2 -- 123
					) -- 123
				) -- 123
			) -- 123
			scroll.view:moveAndCullItems(Vec2.zero) -- 124
		end -- 122
		local selectedIndex = math.max( -- 126
			0, -- 126
			__TS__ArrayFindIndex( -- 126
				flat, -- 126
				function(____, item) -- 126
					local ____temp_14 = item.entry == props.current -- 126
					if not ____temp_14 then -- 126
						local ____temp_13 = item.entry.fileName ~= nil -- 127
						if ____temp_13 then -- 127
							local ____item_entry_fileName_12 = item.entry.fileName -- 127
							local ____opt_10 = props.current -- 127
							____temp_13 = ____item_entry_fileName_12 == (____opt_10 and ____opt_10.fileName) -- 127
						end -- 127
						____temp_14 = ____temp_13 -- 126
					end -- 126
					local ____temp_14_19 = ____temp_14 -- 126
					if not ____temp_14_19 then -- 126
						local ____temp_18 = item.entry.workDir ~= nil -- 128
						if ____temp_18 then -- 128
							local ____item_entry_workDir_17 = item.entry.workDir -- 128
							local ____opt_15 = props.current -- 128
							____temp_18 = ____item_entry_workDir_17 == (____opt_15 and ____opt_15.workDir) -- 128
						end -- 128
						____temp_14_19 = ____temp_18 -- 126
					end -- 126
					return ____temp_14_19 -- 126
				end -- 126
			) -- 126
		) -- 126
		if flat[selectedIndex + 1] ~= nil then -- 126
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 129
		end -- 129
		local popup = Node() -- 131
		popup.visible = false -- 131
		popup.position = Vec2(railWidth + 48, props.height / 2) -- 131
		popup:addTo(root) -- 131
		local popupShape = DrawNode() -- 132
		popupShape:drawPolygon( -- 133
			roundedVerts( -- 133
				-28, -- 133
				-28, -- 133
				56, -- 133
				56, -- 133
				16 -- 133
			), -- 133
			Color(4279704614), -- 133
			1, -- 133
			Color(4286606108) -- 133
		) -- 133
		popupShape:addTo(popup) -- 133
		local popupLabel = addLabel( -- 134
			popup, -- 134
			"", -- 134
			18, -- 134
			4294954035, -- 134
			0, -- 134
			0, -- 134
			Vec2(0.5, 0.5) -- 134
		) -- 134
		popupLabel.tag = "mobile-project-index-popup-label" -- 135
		local rail = Node() -- 136
		rail.tag = "mobile-project-index-rail" -- 136
		rail.anchor = Vec2.zero -- 136
		rail.position = Vec2(0, footerHeight) -- 137
		rail.size = Size(railWidth, listHeight) -- 137
		rail.touchEnabled = #groups > 0 -- 138
		rail.swallowTouches = true -- 138
		rail:addTo(root) -- 138
		local railLabels = {} -- 139
		do -- 139
			local i = 0 -- 140
			while i < #groups do -- 140
				local y = listHeight - (i + 0.5) * listHeight / #groups -- 141
				railLabels[#railLabels + 1] = addLabel( -- 142
					rail, -- 142
					groups[i + 1].key, -- 142
					#groups > 20 and 9 or 11, -- 142
					4286021260, -- 142
					railWidth / 2, -- 142
					y, -- 142
					Vec2(0.5, 0.5) -- 142
				) -- 142
				i = i + 1 -- 140
			end -- 140
		end -- 140
		local ____opt_20 = flat[selectedIndex + 1] -- 140
		local activeGroup = ____opt_20 and ____opt_20.groupIndex or 0 -- 144
		local function selectGroup(groupIndex, showPopup, jump) -- 145
			if jump == nil then -- 145
				jump = true -- 145
			end -- 145
			if #groups == 0 then -- 145
				return -- 146
			end -- 146
			activeGroup = math.max( -- 147
				0, -- 147
				math.min(#groups - 1, groupIndex) -- 147
			) -- 147
			if jump then -- 147
				scroll:unschedule() -- 149
				scroll.offset = Vec2( -- 149
					0, -- 149
					math.max( -- 149
						0, -- 149
						math.min( -- 149
							maxOffset(), -- 149
							groupOffsets[activeGroup + 1] -- 149
						) -- 149
					) -- 149
				) -- 149
				scroll.view:moveAndCullItems(Vec2.zero) -- 150
			end -- 150
			do -- 150
				local i = 0 -- 152
				while i < #railLabels do -- 152
					railLabels[i + 1].color3 = Color3(i == activeGroup and 4294954035 or 7831180) -- 152
					i = i + 1 -- 152
				end -- 152
			end -- 152
			popupLabel.text = groups[activeGroup + 1].key == "#" and (props.zh and "其它" or "Other") or groups[activeGroup + 1].key -- 153
			popup.visible = showPopup -- 154
		end -- 145
		selectGroup(activeGroup, false, false) -- 156
		local function groupAt(worldLocation) -- 157
			if #groups == 0 then -- 157
				return 0 -- 158
			end -- 158
			local point = rail:convertToNodeSpace(worldLocation) -- 159
			popup.y = footerHeight + math.max( -- 160
				32, -- 160
				math.min(listHeight - 32, point.y) -- 160
			) -- 160
			return math.max( -- 161
				0, -- 161
				math.min( -- 161
					#groups - 1, -- 161
					math.floor((listHeight - point.y) / listHeight * #groups) -- 161
				) -- 161
			) -- 161
		end -- 157
		rail:onTapBegan(function(touch) return selectGroup( -- 163
			groupAt(touch.worldLocation), -- 163
			true -- 163
		) end) -- 163
		rail:onTapMoved(function(touch) return selectGroup( -- 164
			groupAt(touch.worldLocation), -- 164
			true -- 164
		) end) -- 164
		rail:onTapEnded(function() -- 165
			popup.visible = false -- 165
		end) -- 165
		local hint = props.zh and "拖动左侧刻度快速定位" or "Drag the index to jump" -- 167
		addLabel( -- 168
			root, -- 168
			hint, -- 168
			9, -- 168
			4286021260, -- 168
			props.width / 2, -- 168
			footerHeight / 2, -- 168
			Vec2(0.5, 0.5) -- 168
		) -- 168
		local function moveSelection(delta) -- 169
			if #flat == 0 then -- 169
				return -- 170
			end -- 170
			selectedIndex = math.max( -- 171
				0, -- 171
				math.min(#flat - 1, selectedIndex + delta) -- 171
			) -- 171
			activeGroup = flat[selectedIndex + 1].groupIndex -- 172
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 172
			selectGroup(activeGroup, false, false) -- 173
			selectGamepadNode(root, flat[selectedIndex + 1].node.tag) -- 173
		end -- 169
		local ____opt_22 = flat[selectedIndex + 1] -- 169
		local gamepadOptions = { -- 175
			initialTag = ____opt_22 and ____opt_22.node.tag or "mobile-project-index-back", -- 176
			onBack = function() return props:onClose() end, -- 177
			onScroll = function(amount) -- 178
				scroll:unschedule() -- 178
				scroll.offset = Vec2( -- 178
					0, -- 178
					math.max( -- 178
						0, -- 178
						math.min( -- 178
							maxOffset(), -- 178
							scroll.offset.y + amount -- 178
						) -- 178
					) -- 178
				) -- 178
				scroll.view:moveAndCullItems(Vec2.zero) -- 178
			end, -- 178
			onButton = function(button) -- 179
				if button == "dpup" then -- 179
					moveSelection(-1) -- 180
					return true -- 180
				end -- 180
				if button == "dpdown" then -- 180
					moveSelection(1) -- 181
					return true -- 181
				end -- 181
				if button == "dpleft" or button == "dpright" then -- 181
					local nextGroup = math.max( -- 183
						0, -- 183
						math.min(#groups - 1, activeGroup + (button == "dpright" and 1 or -1)) -- 183
					) -- 183
					local next = __TS__ArrayFindIndex( -- 184
						flat, -- 184
						function(____, item) return item.groupIndex == nextGroup end -- 184
					) -- 184
					if next >= 0 then -- 184
						selectedIndex = next -- 185
						moveSelection(0) -- 185
					end -- 185
					return true -- 186
				end -- 186
				if button == "a" and flat[selectedIndex + 1] then -- 186
					props:onSelect(flat[selectedIndex + 1].entry) -- 188
					return true -- 188
				end -- 188
				return false -- 189
			end -- 179
		} -- 179
		root:schedule(function() -- 194
			attachGamepad(root, gamepadOptions) -- 194
			return true -- 194
		end) -- 194
		return root -- 195
	end -- 63
	return React.createElement("custom-node", { -- 197
		tag = "mobile-project-index-container", -- 197
		x = props.x, -- 197
		y = props.y, -- 197
		width = props.width, -- 197
		height = props.height, -- 197
		order = 15000, -- 197
		renderOrder = 15000, -- 197
		onCreate = onCreate -- 197
	}) -- 197
end -- 52
return ____exports -- 52