-- [tsx]: UI-TSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local toAction = ____DoraX.toAction -- 2
local useRef = ____DoraX.useRef -- 2
local ____Dora = require("Dora") -- 3
local Ease = ____Dora.Ease -- 3
local Size = ____Dora.Size -- 3
local sleep = ____Dora.sleep -- 3
local thread = ____Dora.thread -- 3
local tolua = ____Dora.tolua -- 3
local Vec2 = ____Dora.Vec2 -- 3
local ____Utils = require("Utils") -- 4
local Struct = ____Utils.Struct -- 4
local LineRectCreate = require("UI.View.Shape.LineRect") -- 6
local ButtonCreate = require("UI.Control.Basic.Button") -- 7
local ScrollAreaCreate = require("UI.Control.Basic.ScrollArea") -- 9
local function Button(props) -- 21
	return React.createElement( -- 22
		"custom-node", -- 22
		{ -- 22
			onCreate = function() -- 22
				local btn = ButtonCreate({text = props.text, width = props.width, height = props.height}) -- 23
				btn:onTapped(function() -- 28
					props.onClick() -- 29
				end) -- 28
				if props.ref then -- 28
					props.ref.current = btn -- 32
				end -- 32
				return btn -- 34
			end, -- 22
			children = props.children -- 22
		} -- 22
	) -- 22
end -- 21
local function ScrollArea(props) -- 54
	return React.createElement( -- 55
		"custom-node", -- 55
		{onCreate = function() -- 55
			local ____props_0 = props -- 56
			local width = ____props_0.width -- 56
			local height = ____props_0.height -- 56
			local scrollArea = ScrollAreaCreate(props) -- 57
			if props.ref then -- 57
				props.ref.current = scrollArea -- 59
			end -- 59
			if props.children then -- 59
				for ____, child in ipairs(props.children) do -- 62
					local ____opt_1 = toNode(child) -- 62
					if ____opt_1 ~= nil then -- 62
						____opt_1:addTo(scrollArea.view) -- 63
					end -- 63
				end -- 63
				scrollArea:adjustSizeWithAlign( -- 65
					"Auto", -- 65
					10, -- 65
					Size(width, height) -- 65
				) -- 65
			end -- 65
			return scrollArea -- 67
		end} -- 55
	) -- 55
end -- 54
local Array = Struct.Array() -- 76
local Item = Struct.Item("name", "value") -- 77
local scrollArea = useRef() -- 79
local items = Array() -- 81
items.__added = function(index, item) -- 82
	local current = scrollArea.current -- 82
	if not current then -- 82
		return -- 84
	end -- 84
	local node = toNode(React.createElement( -- 85
		Button, -- 86
		{ -- 86
			text = item.name, -- 86
			width = 50, -- 86
			height = 50, -- 86
			onClick = function() -- 86
				thread(function() -- 87
					sleep(0.5) -- 88
					items:remove(item) -- 89
				end) -- 87
			end -- 86
		} -- 86
	)) -- 86
	if node then -- 86
		local ____tolua_cast_7 = tolua.cast -- 94
		local ____opt_5 = node.children -- 94
		local ____opt_3 = ____tolua_cast_7(____opt_5 and ____opt_5.first, "Node") -- 94
		if ____opt_3 ~= nil then -- 94
			____opt_3:perform(toAction(React.createElement("scale", {time = 0.3, start = 0, stop = 1, easing = Ease.OutBack}))) -- 94
		end -- 94
		node:addTo(current.view, index) -- 97
		current:adjustSizeWithAlign("Auto") -- 98
	end -- 98
end -- 82
items.__removed = function(index) -- 101
	local current = scrollArea.current -- 101
	local children = current and current.view.children -- 103
	if not children then -- 103
		return -- 104
	end -- 104
	local child = tolua.cast( -- 105
		children:get(index), -- 105
		"Node" -- 105
	) -- 105
	if child then -- 105
		child:removeFromParent() -- 106
	end -- 106
	do -- 106
		local i = 1 -- 107
		while i <= children.count do -- 107
			local child = tolua.cast(children[i], "Node") -- 108
			if child then -- 108
				child.order = i -- 109
			end -- 109
			i = i + 1 -- 107
		end -- 107
	end -- 107
	current:adjustSizeWithAlign("Auto") -- 111
end -- 101
toNode(React.createElement( -- 114
	"align-node", -- 114
	{windowRoot = true, style = {alignItems = "center", justifyContent = "center"}}, -- 114
	React.createElement( -- 114
		"align-node", -- 114
		{ -- 114
			style = {width = "50%", height = "50%"}, -- 114
			onLayout = function(width, height) -- 114
				local current = scrollArea.current -- 114
				if not current then -- 114
					return -- 118
				end -- 118
				current.position = Vec2(width / 2, height / 2) -- 119
				current:adjustSizeWithAlign( -- 120
					"Auto", -- 120
					10, -- 120
					Size(width, height) -- 120
				) -- 120
				local ____opt_10 = current:getChildByTag("border") -- 120
				if ____opt_10 ~= nil then -- 120
					____opt_10:removeFromParent() -- 121
				end -- 121
				local border = LineRectCreate({ -- 122
					x = -width / 2, -- 122
					y = -height / 2, -- 122
					width = width, -- 122
					height = height, -- 122
					color = 4294967295 -- 122
				}) -- 122
				current:addChild(border, 0, "border") -- 123
			end -- 116
		}, -- 116
		React.createElement(ScrollArea, {ref = scrollArea, width = 250, height = 300, paddingX = 0}) -- 116
	) -- 116
)) -- 116
thread(function() -- 130
	for i = 1, 30 do -- 130
		items:insert(Item({ -- 132
			name = "btn " .. tostring(i), -- 132
			value = i -- 132
		})) -- 132
		sleep(1) -- 133
	end -- 133
end) -- 130
return ____exports -- 130