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
		local base = DrawNode() -- 72
		base:drawPolygon( -- 73
			{ -- 73
				Vec2.zero, -- 73
				Vec2(props.width, 0), -- 73
				Vec2(props.width, props.height), -- 73
				Vec2(0, props.height) -- 73
			}, -- 73
			Color(4278716943), -- 74
			0, -- 74
			Color(4278716943) -- 74
		) -- 74
		base:addTo(root) -- 75
		addLabel( -- 76
			root, -- 76
			((props.zh and "本地作品" or "LOCAL") .. " · ") .. tostring(#props.entries), -- 76
			18, -- 76
			4294242792, -- 76
			16, -- 77
			props.height - 34 -- 77
		) -- 77
		local back = Node() -- 78
		back.tag = "mobile-project-index-back" -- 78
		back.anchor = Vec2.zero -- 78
		back.position = Vec2(props.width - 96, props.height - 62) -- 79
		back.size = Size(80, 44) -- 79
		back.touchEnabled = true -- 79
		back.swallowTouches = true -- 79
		back:onTapped(props.onClose) -- 80
		back:addTo(root) -- 80
		addLabel( -- 81
			back, -- 81
			props.zh and "返回 ›" or "Back ›", -- 81
			18, -- 81
			4294954035, -- 81
			80, -- 81
			22, -- 81
			Vec2(1, 0.5) -- 81
		) -- 81
		local groups = groupFeedProjects(props.entries) -- 83
		local listX = railWidth + 8 -- 84
		local listWidth = math.max(40, props.width - listX - 14) -- 85
		local listHeight = math.max(40, props.height - headerHeight - footerHeight) -- 86
		local scroll = ScrollArea({ -- 87
			width = listWidth, -- 87
			height = listHeight, -- 87
			paddingX = 0, -- 87
			paddingY = 28, -- 87
			scrollBar = false -- 87
		}) -- 87
		scroll.tag = "mobile-project-index-scroll" -- 88
		scroll.position = Vec2(listX + listWidth / 2, footerHeight + listHeight / 2) -- 88
		scroll:addTo(root) -- 88
		local flat = {} -- 89
		local groupOffsets = {} -- 90
		local total = 0 -- 91
		do -- 91
			local groupIndex = 0 -- 92
			while groupIndex < #groups do -- 92
				local group = groups[groupIndex + 1] -- 93
				groupOffsets[#groupOffsets + 1] = total -- 94
				local heading = Node() -- 95
				heading.tag = "mobile-project-index-group-" .. group.key -- 95
				heading.anchor = Vec2(0, 1) -- 96
				heading.position = Vec2(0, listHeight - total) -- 96
				heading.size = Size(listWidth, groupHeight) -- 97
				heading:addTo(scroll.view) -- 97
				local groupTitle = group.key == "#" and (props.zh and "其它" or "Other") or group.key -- 98
				local headingBg = DrawNode() -- 99
				headingBg:drawSegment( -- 100
					Vec2(38, 18), -- 100
					Vec2(listWidth - 4, 18), -- 100
					0.5, -- 100
					Color(4281613128) -- 100
				) -- 100
				headingBg:addTo(heading) -- 101
				addLabel( -- 102
					heading, -- 102
					groupTitle, -- 102
					12, -- 102
					4294954035, -- 102
					8, -- 102
					18 -- 102
				) -- 102
				total = total + groupHeight -- 103
				for ____, entry in ipairs(group.entries) do -- 104
					local row = Node() -- 105
					row.tag = "mobile-project-index-entry-" .. tostring(#flat) -- 105
					row.anchor = Vec2(0, 1) -- 105
					row.position = Vec2(0, listHeight - total) -- 106
					row.size = Size(listWidth, rowHeight) -- 106
					row.touchEnabled = true -- 107
					row.swallowTouches = true -- 107
					row:onTapped(function() return props:onSelect(entry) end) -- 107
					row:addTo(scroll.view) -- 107
					local ____temp_4 = entry == props.current -- 108
					if not ____temp_4 then -- 108
						local ____temp_3 = entry.fileName ~= nil -- 108
						if ____temp_3 then -- 108
							local ____entry_fileName_2 = entry.fileName -- 108
							local ____opt_0 = props.current -- 108
							____temp_3 = ____entry_fileName_2 == (____opt_0 and ____opt_0.fileName) -- 108
						end -- 108
						____temp_4 = ____temp_3 -- 108
					end -- 108
					local ____temp_4_9 = ____temp_4 -- 108
					if not ____temp_4_9 then -- 108
						local ____temp_8 = entry.workDir ~= nil -- 109
						if ____temp_8 then -- 109
							local ____entry_workDir_7 = entry.workDir -- 109
							local ____opt_5 = props.current -- 109
							____temp_8 = ____entry_workDir_7 == (____opt_5 and ____opt_5.workDir) -- 109
						end -- 109
						____temp_4_9 = ____temp_8 -- 108
					end -- 108
					local selected = ____temp_4_9 -- 108
					local rowBg = DrawNode() -- 110
					rowBg:drawSegment( -- 111
						Vec2(8, 1), -- 111
						Vec2(listWidth - 8, 1), -- 111
						0.5, -- 111
						Color(4280560439) -- 111
					) -- 111
					if selected then -- 111
						rowBg:drawSegment( -- 112
							Vec2(5, 13), -- 112
							Vec2(5, rowHeight - 13), -- 112
							1.5, -- 112
							Color(4294954035) -- 112
						) -- 112
					end -- 112
					rowBg:addTo(row) -- 113
					addLabel( -- 114
						row, -- 114
						ellipsize( -- 114
							entry.title, -- 114
							math.max( -- 114
								8, -- 114
								math.floor((listWidth - 54) / 9) -- 114
							) -- 114
						), -- 114
						14, -- 114
						selected and 4294954035 or 4294242792, -- 115
						16, -- 115
						rowHeight / 2 -- 115
					) -- 115
					flat[#flat + 1] = {entry = entry, node = row, groupIndex = groupIndex, centerFromTop = total + rowHeight / 2} -- 116
					total = total + rowHeight -- 117
				end -- 117
				groupIndex = groupIndex + 1 -- 92
			end -- 92
		end -- 92
		if #groups == 0 then -- 92
			addLabel( -- 121
				scroll.view, -- 121
				props.zh and "还没有本地作品" or "No local games yet", -- 121
				14, -- 121
				4286021260, -- 121
				listWidth / 2, -- 122
				listHeight / 2, -- 122
				Vec2(0.5, 0.5) -- 122
			) -- 122
		end -- 122
		scroll:resetSize(listWidth, listHeight, listWidth, total) -- 124
		local function maxOffset() -- 125
			return math.max(0, total - listHeight) -- 125
		end -- 125
		local function scrollTo(centerFromTop) -- 126
			scroll:unschedule() -- 127
			scroll.offset = Vec2( -- 127
				0, -- 127
				math.max( -- 127
					0, -- 127
					math.min( -- 127
						maxOffset(), -- 127
						centerFromTop - listHeight / 2 -- 127
					) -- 127
				) -- 127
			) -- 127
			scroll.view:moveAndCullItems(Vec2.zero) -- 128
		end -- 126
		local selectedIndex = math.max( -- 130
			0, -- 130
			__TS__ArrayFindIndex( -- 130
				flat, -- 130
				function(____, item) -- 130
					local ____temp_14 = item.entry == props.current -- 130
					if not ____temp_14 then -- 130
						local ____temp_13 = item.entry.fileName ~= nil -- 131
						if ____temp_13 then -- 131
							local ____item_entry_fileName_12 = item.entry.fileName -- 131
							local ____opt_10 = props.current -- 131
							____temp_13 = ____item_entry_fileName_12 == (____opt_10 and ____opt_10.fileName) -- 131
						end -- 131
						____temp_14 = ____temp_13 -- 130
					end -- 130
					local ____temp_14_19 = ____temp_14 -- 130
					if not ____temp_14_19 then -- 130
						local ____temp_18 = item.entry.workDir ~= nil -- 132
						if ____temp_18 then -- 132
							local ____item_entry_workDir_17 = item.entry.workDir -- 132
							local ____opt_15 = props.current -- 132
							____temp_18 = ____item_entry_workDir_17 == (____opt_15 and ____opt_15.workDir) -- 132
						end -- 132
						____temp_14_19 = ____temp_18 -- 130
					end -- 130
					return ____temp_14_19 -- 130
				end -- 130
			) -- 130
		) -- 130
		if flat[selectedIndex + 1] ~= nil then -- 130
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 133
		end -- 133
		local popup = Node() -- 135
		popup.visible = false -- 135
		popup.position = Vec2(railWidth + 48, props.height / 2) -- 135
		popup:addTo(root) -- 135
		local popupShape = DrawNode() -- 136
		popupShape:drawPolygon( -- 137
			roundedVerts( -- 137
				-28, -- 137
				-28, -- 137
				56, -- 137
				56, -- 137
				16 -- 137
			), -- 137
			Color(4279704614), -- 137
			1, -- 137
			Color(4286606108) -- 137
		) -- 137
		popupShape:addTo(popup) -- 137
		local popupLabel = addLabel( -- 138
			popup, -- 138
			"", -- 138
			18, -- 138
			4294954035, -- 138
			0, -- 138
			0, -- 138
			Vec2(0.5, 0.5) -- 138
		) -- 138
		popupLabel.tag = "mobile-project-index-popup-label" -- 139
		local rail = Node() -- 140
		rail.tag = "mobile-project-index-rail" -- 140
		rail.anchor = Vec2.zero -- 140
		rail.position = Vec2(0, footerHeight) -- 141
		rail.size = Size(railWidth, listHeight) -- 141
		rail.touchEnabled = #groups > 0 -- 142
		rail.swallowTouches = true -- 142
		rail:addTo(root) -- 142
		local railLabels = {} -- 143
		do -- 143
			local i = 0 -- 144
			while i < #groups do -- 144
				local y = listHeight - (i + 0.5) * listHeight / #groups -- 145
				railLabels[#railLabels + 1] = addLabel( -- 146
					rail, -- 146
					groups[i + 1].key, -- 146
					#groups > 20 and 9 or 11, -- 146
					4286021260, -- 146
					railWidth / 2, -- 146
					y, -- 146
					Vec2(0.5, 0.5) -- 146
				) -- 146
				i = i + 1 -- 144
			end -- 144
		end -- 144
		local ____opt_20 = flat[selectedIndex + 1] -- 144
		local activeGroup = ____opt_20 and ____opt_20.groupIndex or 0 -- 148
		local function selectGroup(groupIndex, showPopup, jump) -- 149
			if jump == nil then -- 149
				jump = true -- 149
			end -- 149
			if #groups == 0 then -- 149
				return -- 150
			end -- 150
			activeGroup = math.max( -- 151
				0, -- 151
				math.min(#groups - 1, groupIndex) -- 151
			) -- 151
			if jump then -- 151
				scroll:unschedule() -- 153
				scroll.offset = Vec2( -- 153
					0, -- 153
					math.max( -- 153
						0, -- 153
						math.min( -- 153
							maxOffset(), -- 153
							groupOffsets[activeGroup + 1] -- 153
						) -- 153
					) -- 153
				) -- 153
				scroll.view:moveAndCullItems(Vec2.zero) -- 154
			end -- 154
			do -- 154
				local i = 0 -- 156
				while i < #railLabels do -- 156
					railLabels[i + 1].color3 = Color3(i == activeGroup and 4294954035 or 7831180) -- 156
					i = i + 1 -- 156
				end -- 156
			end -- 156
			popupLabel.text = groups[activeGroup + 1].key == "#" and (props.zh and "其它" or "Other") or groups[activeGroup + 1].key -- 157
			popup.visible = showPopup -- 158
		end -- 149
		selectGroup(activeGroup, false, false) -- 160
		local function groupAt(worldLocation) -- 161
			if #groups == 0 then -- 161
				return 0 -- 162
			end -- 162
			local point = rail:convertToNodeSpace(worldLocation) -- 163
			popup.y = footerHeight + math.max( -- 164
				32, -- 164
				math.min(listHeight - 32, point.y) -- 164
			) -- 164
			return math.max( -- 165
				0, -- 165
				math.min( -- 165
					#groups - 1, -- 165
					math.floor((listHeight - point.y) / listHeight * #groups) -- 165
				) -- 165
			) -- 165
		end -- 161
		rail:onTapBegan(function(touch) return selectGroup( -- 167
			groupAt(touch.worldLocation), -- 167
			true -- 167
		) end) -- 167
		rail:onTapMoved(function(touch) return selectGroup( -- 168
			groupAt(touch.worldLocation), -- 168
			true -- 168
		) end) -- 168
		rail:onTapEnded(function() -- 169
			popup.visible = false -- 169
		end) -- 169
		local hint = props.zh and "拖动左侧刻度快速定位" or "Drag the index to jump" -- 171
		addLabel( -- 172
			root, -- 172
			hint, -- 172
			9, -- 172
			4286021260, -- 172
			props.width / 2, -- 172
			footerHeight / 2, -- 172
			Vec2(0.5, 0.5) -- 172
		) -- 172
		local function moveSelection(delta) -- 173
			if #flat == 0 then -- 173
				return -- 174
			end -- 174
			selectedIndex = math.max( -- 175
				0, -- 175
				math.min(#flat - 1, selectedIndex + delta) -- 175
			) -- 175
			activeGroup = flat[selectedIndex + 1].groupIndex -- 176
			scrollTo(flat[selectedIndex + 1].centerFromTop) -- 176
			selectGroup(activeGroup, false, false) -- 177
			selectGamepadNode(root, flat[selectedIndex + 1].node.tag) -- 177
		end -- 173
		local ____opt_22 = flat[selectedIndex + 1] -- 173
		local gamepadOptions = { -- 179
			initialTag = ____opt_22 and ____opt_22.node.tag or "mobile-project-index-back", -- 180
			onBack = function() return props:onClose() end, -- 181
			onScroll = function(amount) -- 182
				scroll:unschedule() -- 182
				scroll.offset = Vec2( -- 182
					0, -- 182
					math.max( -- 182
						0, -- 182
						math.min( -- 182
							maxOffset(), -- 182
							scroll.offset.y + amount -- 182
						) -- 182
					) -- 182
				) -- 182
				scroll.view:moveAndCullItems(Vec2.zero) -- 182
			end, -- 182
			onButton = function(button) -- 183
				if button == "dpup" then -- 183
					moveSelection(-1) -- 184
					return true -- 184
				end -- 184
				if button == "dpdown" then -- 184
					moveSelection(1) -- 185
					return true -- 185
				end -- 185
				if button == "dpleft" or button == "dpright" then -- 185
					local nextGroup = math.max( -- 187
						0, -- 187
						math.min(#groups - 1, activeGroup + (button == "dpright" and 1 or -1)) -- 187
					) -- 187
					local next = __TS__ArrayFindIndex( -- 188
						flat, -- 188
						function(____, item) return item.groupIndex == nextGroup end -- 188
					) -- 188
					if next >= 0 then -- 188
						selectedIndex = next -- 189
						moveSelection(0) -- 189
					end -- 189
					return true -- 190
				end -- 190
				if button == "a" and flat[selectedIndex + 1] then -- 190
					props:onSelect(flat[selectedIndex + 1].entry) -- 192
					return true -- 192
				end -- 192
				return false -- 193
			end -- 183
		} -- 183
		root:schedule(function() -- 198
			attachGamepad(root, gamepadOptions) -- 198
			return true -- 198
		end) -- 198
		return root -- 199
	end -- 63
	return React.createElement("custom-node", { -- 201
		tag = "mobile-project-index-container", -- 201
		x = props.x, -- 201
		y = props.y, -- 201
		width = props.width, -- 201
		height = props.height, -- 201
		order = 15000, -- 201
		renderOrder = 15000, -- 201
		onCreate = onCreate -- 201
	}) -- 201
end -- 52
return ____exports -- 52