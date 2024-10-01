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
			local border = LineRectCreate({ -- 66
				x = 1, -- 66
				y = 1, -- 66
				width = width - 2, -- 66
				height = height - 2, -- 66
				color = 4294967295 -- 66
			}) -- 66
			scrollArea.area:addChild(border, 0, "border") -- 67
			return scrollArea -- 68
		end} -- 54
	) -- 54
end -- 53
local Array = Struct.Array() -- 77
local Item = Struct.Item("name", "value") -- 78
local scrollArea = useRef() -- 80
local items = Array() -- 82
items.__notify = function(event, index, item) -- 83
	repeat -- 83
		local ____switch13 = event -- 83
		local ____cond13 = ____switch13 == "Added" -- 83
		if ____cond13 then -- 83
			do -- 83
				local current = scrollArea.current -- 83
				if current then -- 83
					local ____opt_3 = toNode(React.createElement( -- 83
						Button, -- 89
						{ -- 89
							text = item.name, -- 89
							width = 50, -- 89
							height = 50, -- 89
							onClick = function() -- 89
								thread(function() -- 90
									sleep(0.5) -- 91
									items:remove(item) -- 92
								end) -- 90
							end -- 89
						} -- 89
					)) -- 89
					if ____opt_3 ~= nil then -- 89
						____opt_3:addTo(current.view) -- 88
					end -- 88
				end -- 88
				break -- 97
			end -- 97
		end -- 97
		____cond13 = ____cond13 or ____switch13 == "Removed" -- 97
		if ____cond13 then -- 97
			do -- 97
				local current = scrollArea.current -- 97
				if current then -- 97
					local ____opt_5 = current.view.children -- 97
					local child = ____opt_5 and ____opt_5:get(index) -- 102
					if child then -- 102
						child:removeFromParent() -- 104
					end -- 104
				end -- 104
				break -- 107
			end -- 107
		end -- 107
		____cond13 = ____cond13 or ____switch13 == "Updated" -- 107
		if ____cond13 then -- 107
			do -- 107
				local current = scrollArea.current -- 107
				if current then -- 107
					current:adjustSizeWithAlign("Auto") -- 112
				end -- 112
				break -- 114
			end -- 114
		end -- 114
	until true -- 114
end -- 83
toNode(React.createElement( -- 119
	"align-node", -- 119
	{windowRoot = true, style = {alignItems = "center", justifyContent = "center"}}, -- 119
	React.createElement( -- 119
		"align-node", -- 119
		{ -- 119
			style = {width = "50%", height = "50%"}, -- 119
			onLayout = function(width, height) -- 119
				local current = scrollArea.current -- 119
				if current then -- 119
					current.position = Vec2(width / 2, height / 2) -- 124
					current:adjustSizeWithAlign( -- 125
						"Auto", -- 125
						10, -- 125
						Size(width, height) -- 125
					) -- 125
					local border = LineRectCreate({ -- 126
						x = 1, -- 126
						y = 1, -- 126
						width = width - 2, -- 126
						height = height - 2, -- 126
						color = 4294967295 -- 126
					}) -- 126
					local ____opt_7 = current.area:getChildByTag("border") -- 126
					if ____opt_7 ~= nil then -- 126
						____opt_7:removeFromParent() -- 127
					end -- 127
					current.area:addChild(border, 0, "border") -- 128
				end -- 128
			end -- 121
		}, -- 121
		React.createElement(ScrollArea, {ref = scrollArea, width = 250, height = 300, paddingX = 0}) -- 121
	) -- 121
)) -- 121
for i = 1, 30 do -- 121
	items:insert(Item({ -- 137
		name = "btn " .. tostring(i), -- 137
		value = i -- 137
	})) -- 137
end -- 137
return ____exports -- 137