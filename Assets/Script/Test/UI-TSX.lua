-- [tsx]: UI-TSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local useRef = ____DoraX.useRef -- 2
local ____Dora = require("Dora") -- 3
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
local function Button(props) -- 20
	return React.createElement( -- 21
		"custom-node", -- 21
		{onCreate = function() -- 21
			local btn = ButtonCreate({text = props.text, width = props.width, height = props.height}) -- 22
			btn:onTapped(function() -- 27
				props:onClick() -- 28
			end) -- 27
			if props.ref then -- 27
				props.ref.current = btn -- 31
			end -- 31
			return btn -- 33
		end} -- 21
	) -- 21
end -- 20
local function ScrollArea(props) -- 53
	return React.createElement( -- 54
		"custom-node", -- 54
		{onCreate = function() -- 54
			local ____props_0 = props -- 55
			local width = ____props_0.width -- 55
			local height = ____props_0.height -- 55
			local scrollArea = ScrollAreaCreate(props) -- 56
			if props.ref then -- 56
				props.ref.current = scrollArea -- 58
			end -- 58
			if props.children then -- 58
				for ____, child in ipairs(props.children) do -- 61
					local ____opt_1 = toNode(child) -- 61
					if ____opt_1 ~= nil then -- 61
						____opt_1:addTo(scrollArea.view) -- 62
					end -- 62
				end -- 62
				scrollArea:adjustSizeWithAlign( -- 64
					"Auto", -- 64
					10, -- 64
					Size(width, height) -- 64
				) -- 64
			end -- 64
			return scrollArea -- 66
		end} -- 54
	) -- 54
end -- 53
local Array = Struct.Array() -- 75
local Item = Struct.Item("name", "value") -- 76
local scrollArea = useRef() -- 78
local items = Array() -- 80
items.__added = function(index, item) -- 81
	local current = scrollArea.current -- 81
	if not current then -- 81
		return -- 83
	end -- 83
	local node = toNode(React.createElement( -- 84
		Button, -- 85
		{ -- 85
			text = item.name, -- 85
			width = 50, -- 85
			height = 50, -- 85
			onClick = function() -- 85
				thread(function() -- 86
					sleep(0.5) -- 87
					items:remove(item) -- 88
				end) -- 86
			end -- 85
		} -- 85
	)) -- 85
	if node then -- 85
		node.visible = false -- 93
		node.x = -1000 -- 94
		node:addTo(current.view, index) -- 95
	end -- 95
end -- 81
items.__removed = function(index) -- 98
	local current = scrollArea.current -- 98
	local ____tolua_cast_7 = tolua.cast -- 100
	local ____opt_3 = current and current.view.children -- 100
	local child = ____tolua_cast_7( -- 100
		____opt_3 and ____opt_3:get(index), -- 100
		"Node" -- 100
	) -- 100
	if child then -- 100
		child:removeFromParent() -- 101
	end -- 101
end -- 98
items.__updated = function() -- 103
	local current = scrollArea.current -- 103
	if current ~= nil then -- 103
		current:adjustSizeWithAlign("Auto") -- 105
	end -- 105
end -- 103
toNode(React.createElement( -- 108
	"align-node", -- 108
	{windowRoot = true, style = {alignItems = "center", justifyContent = "center"}}, -- 108
	React.createElement( -- 108
		"align-node", -- 108
		{ -- 108
			style = {width = "50%", height = "50%"}, -- 108
			onLayout = function(width, height) -- 108
				local current = scrollArea.current -- 108
				if not current then -- 108
					return -- 112
				end -- 112
				current.position = Vec2(width / 2, height / 2) -- 113
				current:adjustSizeWithAlign( -- 114
					"Auto", -- 114
					10, -- 114
					Size(width, height) -- 114
				) -- 114
				local ____opt_10 = current:getChildByTag("border") -- 114
				if ____opt_10 ~= nil then -- 114
					____opt_10:removeFromParent() -- 115
				end -- 115
				local border = LineRectCreate({ -- 116
					x = -width / 2, -- 116
					y = -height / 2, -- 116
					width = width, -- 116
					height = height, -- 116
					color = 4294967295 -- 116
				}) -- 116
				current:addChild(border, 0, "border") -- 117
			end -- 110
		}, -- 110
		React.createElement(ScrollArea, {ref = scrollArea, width = 250, height = 300, paddingX = 0}) -- 110
	) -- 110
)) -- 110
thread(function() -- 124
	for i = 1, 30 do -- 124
		items:insert(Item({ -- 126
			name = "btn " .. tostring(i), -- 126
			value = i -- 126
		})) -- 126
		sleep(1) -- 127
	end -- 127
end) -- 124
return ____exports -- 124