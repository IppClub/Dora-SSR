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
local Vec2 = ____Dora.Vec2 -- 3
local ____Utils = require("Utils") -- 4
local Struct = ____Utils.Struct -- 4
local ButtonCreate = require("UI.Control.Basic.Button") -- 6
local LineRectCreate = require("UI.View.Shape.LineRect") -- 8
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
	if current then -- 81
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
	end -- 95
end -- 81
items.__removed = function(index) -- 99
	local current = scrollArea.current -- 99
	if current then -- 99
		local ____opt_3 = current.view.children -- 99
		local child = ____opt_3 and ____opt_3:get(index) -- 102
		if child then -- 102
			child:removeFromParent() -- 104
		end -- 104
	end -- 104
end -- 99
items.__updated = function() -- 108
	local current = scrollArea.current -- 108
	if current then -- 108
		current:adjustSizeWithAlign("Auto") -- 111
	end -- 111
end -- 108
toNode(React.createElement( -- 115
	"align-node", -- 115
	{windowRoot = true, style = {alignItems = "center", justifyContent = "center"}}, -- 115
	React.createElement( -- 115
		"align-node", -- 115
		{ -- 115
			style = {width = "50%", height = "50%"}, -- 115
			onLayout = function(width, height) -- 115
				local current = scrollArea.current -- 115
				if current then -- 115
					current.position = Vec2(width / 2, height / 2) -- 120
					current:adjustSizeWithAlign( -- 121
						"Auto", -- 121
						10, -- 121
						Size(width, height) -- 121
					) -- 121
					local ____opt_5 = current:getChildByTag("border") -- 121
					if ____opt_5 ~= nil then -- 121
						____opt_5:removeFromParent() -- 122
					end -- 122
					local border = LineRectCreate({ -- 123
						x = -width / 2, -- 123
						y = -height / 2, -- 123
						width = width, -- 123
						height = height, -- 123
						color = 4294967295 -- 123
					}) -- 123
					current:addChild(border, 0, "border") -- 124
				end -- 124
			end -- 117
		}, -- 117
		React.createElement(ScrollArea, {ref = scrollArea, width = 250, height = 300, paddingX = 0}) -- 117
	) -- 117
)) -- 117
thread(function() -- 132
	for i = 1, 30 do -- 132
		items:insert(Item({ -- 134
			name = "btn " .. tostring(i), -- 134
			value = i -- 134
		})) -- 134
		sleep(1) -- 135
	end -- 135
end) -- 132
return ____exports -- 132