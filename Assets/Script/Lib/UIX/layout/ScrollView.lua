-- [tsx]: ScrollView.tsx
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Mouse = ____Dora.Mouse -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____DoraX = require("DoraX") -- 3
local React = ____DoraX.React -- 3
local useRef = ____DoraX.useRef -- 3
local ____clip = require("UIX.paint.clip") -- 4
local registerClip = ____clip.registerClip -- 4
local unregisterClip = ____clip.unregisterClip -- 4
local ____helpers = require("UIX.layout.helpers") -- 5
local mergeStyle = ____helpers.mergeStyle -- 5
local ____types = require("UIX.types") -- 7
local clamp = ____types.clamp -- 7
function ____exports.ScrollView(props) -- 21
	local localOffset = useRef(props.offsetY or 0) -- 22
	local localRef = useRef() -- 23
	local contentRef = useRef() -- 24
	local inputRef = useRef() -- 25
	local dragRef = useRef() -- 26
	local dragging = useRef(false) -- 27
	local scrollActive = useRef(false) -- 28
	local dragDistance = useRef(0) -- 29
	local lastDragY = useRef(0) -- 30
	local rootRef = props.ref or localRef -- 31
	local ____opt_0 = props.style -- 31
	local styleWidth = ____opt_0 and ____opt_0.width -- 32
	local ____opt_2 = props.style -- 32
	local styleHeight = ____opt_2 and ____opt_2.height -- 33
	local width = props.width or styleWidth or 240 -- 34
	local height = props.height or styleHeight or 160 -- 35
	local maxOffset = math.max(0, props.contentHeight - height) -- 36
	local offset = clamp(props.offsetY or localOffset.current or 0, 0, maxOffset) -- 37
	local function getOffset() -- 38
		return clamp(props.offsetY or localOffset.current or 0, 0, maxOffset) -- 38
	end -- 38
	local function applyContentOffset(next) -- 39
		local node = contentRef.current -- 40
		if node ~= nil then -- 40
			node.y = next -- 42
		end -- 42
	end -- 39
	local function setOffset(value) -- 45
		local next = clamp(value, 0, maxOffset) -- 46
		if props.offsetY == nil then -- 46
			localOffset.current = next -- 47
		end -- 47
		applyContentOffset(next) -- 48
		local ____opt_4 = props.onScroll -- 48
		if ____opt_4 ~= nil then -- 48
			____opt_4(next) -- 49
		end -- 49
	end -- 45
	local function scrollByWheel(deltaY) -- 51
		setOffset(getOffset() + deltaY * (props.wheelSpeed or 24)) -- 52
	end -- 51
	local function mouseRootLocation() -- 54
		local root = rootRef.current -- 55
		if root == nil then -- 55
			return nil -- 56
		end -- 56
		local ____App_bufferSize_6 = App.bufferSize -- 57
		local bw = ____App_bufferSize_6.width -- 57
		local bh = ____App_bufferSize_6.height -- 57
		local ____App_visualSize_7 = App.visualSize -- 58
		local vw = ____App_visualSize_7.width -- 58
		local pos = Mouse.position:mul(bw / vw) -- 59
		pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y) -- 60
		return root:convertToNodeSpace(pos) -- 61
	end -- 54
	local function touchRootLocation(touch) -- 63
		local root = rootRef.current -- 64
		if root ~= nil and touch.worldLocation ~= nil then -- 64
			return root:convertToNodeSpace(touch.worldLocation) -- 66
		end -- 66
		return touch.location -- 68
	end -- 63
	local function isInsideTouch(touch) -- 70
		local location = touchRootLocation(touch) -- 71
		return location.x >= 0 and location.x <= width and location.y >= 0 and location.y <= height -- 72
	end -- 70
	local function filterDrag(touch) -- 74
		if not touch.first or not isInsideTouch(touch) then -- 74
			touch.enabled = false -- 76
		end -- 76
	end -- 74
	local function moveDrag(touch) -- 79
		if Mouse.leftButtonPressed then -- 79
			return -- 80
		end -- 80
		local nextDistance = (dragDistance.current or 0) + touch.delta.length -- 81
		dragDistance.current = nextDistance -- 82
		if scrollActive.current or nextDistance > 10 then -- 82
			scrollActive.current = true -- 84
			setOffset(getOffset() + touch.delta.y) -- 85
		end -- 85
	end -- 79
	local function beginDrag(touch) -- 88
		local location = touchRootLocation(touch) -- 89
		dragging.current = Mouse.leftButtonPressed -- 90
		scrollActive.current = false -- 91
		dragDistance.current = 0 -- 92
		lastDragY.current = location.y -- 93
	end -- 88
	local function endDrag() -- 95
		dragging.current = false -- 96
		scrollActive.current = false -- 97
		dragDistance.current = 0 -- 98
	end -- 95
	local function pollDrag() -- 100
		if not dragging.current then -- 100
			return false -- 101
		end -- 101
		if not Mouse.leftButtonPressed then -- 101
			dragging.current = false -- 103
			return false -- 104
		end -- 104
		local location = mouseRootLocation() -- 106
		if location == nil then -- 106
			return false -- 107
		end -- 107
		local deltaY = location.y - (lastDragY.current or location.y) -- 108
		lastDragY.current = location.y -- 109
		local nextDistance = (dragDistance.current or 0) + math.abs(deltaY) -- 110
		dragDistance.current = nextDistance -- 111
		if scrollActive.current or nextDistance > 10 then -- 111
			scrollActive.current = true -- 113
			if deltaY ~= 0 then -- 113
				setOffset(getOffset() + deltaY) -- 114
			end -- 114
		end -- 114
		return false -- 116
	end -- 100
	local function syncClip(node, clipWidth, clipHeight) -- 118
		if node ~= nil then -- 118
			node.size = Size(clipWidth, clipHeight) -- 120
			registerClip(node, clipWidth, clipHeight) -- 121
		end -- 121
	end -- 118
	local function syncInputSize(node, inputWidth, inputHeight) -- 124
		if node ~= nil then -- 124
			node.size = Size(inputWidth, inputHeight) -- 125
		end -- 125
	end -- 124
	local function syncContentNode(node) -- 127
		if node ~= nil then -- 127
			node.y = getOffset() -- 129
			node.size = Size(width, props.contentHeight) -- 130
		end -- 130
	end -- 127
	local ____React_createElement_16 = React.createElement -- 127
	local ____temp_14 = { -- 127
		key = props.key, -- 127
		ref = rootRef, -- 127
		style = mergeStyle({position = "relative", width = width, height = height}, props.style), -- 127
		visible = props.visible, -- 127
		opacity = props.opacity, -- 127
		onLayout = function(w, h) return syncClip(rootRef.current, w, h) end, -- 127
		onUnmount = function(node) -- 127
			unregisterClip(node) -- 146
		end -- 145
	} -- 145
	local ____React_createElement_result_15 = React.createElement( -- 145
		"align-node", -- 145
		{ -- 145
			key = "content", -- 145
			ref = contentRef, -- 145
			style = { -- 145
				position = "absolute", -- 153
				width = "100%", -- 154
				height = props.contentHeight, -- 155
				flexDirection = "column", -- 156
				alignItems = "flex-start", -- 157
				justifyContent = "flex-start" -- 158
			}, -- 158
			onLayout = function() return syncContentNode(contentRef.current) end -- 158
		}, -- 158
		props.children -- 162
	) -- 162
	local ____temp_8 -- 164
	if props.inputOverlay ~= false then -- 164
		____temp_8 = React.createElement( -- 164
			"align-node", -- 164
			{ -- 164
				key = "input-overlay", -- 164
				ref = inputRef, -- 164
				style = { -- 164
					position = "absolute", -- 169
					left = 0, -- 170
					top = 0, -- 171
					width = width, -- 172
					height = height -- 173
				}, -- 173
				touchEnabled = not props.disabled, -- 173
				swallowTouches = props.dragOverlay == true, -- 173
				swallowMouseWheel = true, -- 173
				onLayout = function(w, h) return syncInputSize(inputRef.current, w, h) end, -- 173
				onMouseWheel = function(delta) return scrollByWheel(delta.y) end -- 173
			} -- 173
		) -- 173
	else -- 173
		____temp_8 = nil -- 180
	end -- 180
	local ____temp_13 -- 182
	if props.inputOverlay ~= false then -- 182
		local ____React_createElement_12 = React.createElement -- 182
		local ____temp_10 = { -- 186
			position = "absolute", -- 187
			left = 0, -- 188
			top = 0, -- 189
			width = width, -- 190
			height = height -- 191
		} -- 191
		local ____temp_11 = not props.disabled -- 193
		local ____props_swallowDrag_9 = props.swallowDrag -- 194
		if ____props_swallowDrag_9 == nil then -- 194
			____props_swallowDrag_9 = false -- 194
		end -- 194
		____temp_13 = ____React_createElement_12( -- 194
			"align-node", -- 194
			{ -- 194
				key = "drag-capture", -- 194
				ref = dragRef, -- 194
				style = ____temp_10, -- 194
				touchEnabled = ____temp_11, -- 194
				swallowTouches = ____props_swallowDrag_9, -- 194
				onLayout = function(w, h) return syncInputSize(dragRef.current, w, h) end, -- 194
				onTapFilter = filterDrag, -- 194
				onTapBegan = beginDrag, -- 194
				onTapMoved = moveDrag, -- 194
				onTapEnded = endDrag, -- 194
				onUpdate = pollDrag -- 194
			} -- 194
		) -- 194
	else -- 194
		____temp_13 = nil -- 201
	end -- 201
	return ____React_createElement_16( -- 133
		"align-node", -- 133
		____temp_14, -- 133
		____React_createElement_result_15, -- 133
		____temp_8, -- 133
		____temp_13 -- 133
	) -- 133
end -- 21
return ____exports -- 21