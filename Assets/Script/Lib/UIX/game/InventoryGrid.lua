-- [tsx]: InventoryGrid.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____ItemSlot = require("UIX.game.ItemSlot") -- 2
local ItemSlot = ____ItemSlot.ItemSlot -- 2
local ____Column = require("UIX.layout.Column") -- 3
local Column = ____Column.Column -- 3
local ____Row = require("UIX.layout.Row") -- 4
local Row = ____Row.Row -- 4
local ____helpers = require("UIX.layout.helpers") -- 5
local mergeStyle = ____helpers.mergeStyle -- 5
local function itemAt(items, index) -- 43
	return items[index] -- 44
end -- 43
function ____exports.InventoryGrid(props) -- 47
	local columns = math.max(1, props.columns) -- 48
	local rows = props.rows or math.max( -- 49
		1, -- 49
		math.ceil(#props.items / columns) -- 49
	) -- 49
	local slotSize = props.slotSize or 56 -- 50
	local gap = props.gap or 8 -- 51
	local width = columns * slotSize + (columns - 1) * gap -- 52
	local height = rows * slotSize + (rows - 1) * gap -- 53
	local rowElements = {} -- 54
	for row = 1, rows do -- 54
		local slots = {} -- 56
		for column = 1, columns do -- 56
			local index = (row - 1) * columns + column -- 58
			local item = itemAt(props.items, index) -- 59
			slots[#slots + 1] = React.createElement( -- 60
				ItemSlot, -- 61
				{ -- 61
					key = item and item.id or "empty-" .. tostring(index), -- 61
					id = item and item.id, -- 61
					icon = item and item.icon, -- 61
					quality = item and item.quality, -- 61
					count = item and item.count, -- 61
					disabled = props.disabled == true or (item and item.disabled) == true, -- 61
					selected = item ~= nil and item.id == props.selectedId, -- 61
					cooldown = item and item.cooldown, -- 61
					maxCooldown = item and item.maxCooldown, -- 61
					swallowTouches = props.slotSwallowTouches, -- 61
					style = {width = slotSize, height = slotSize}, -- 61
					onClick = function(id) -- 61
						if id ~= nil then -- 61
							local ____opt_16 = props.onSelect -- 61
							if ____opt_16 ~= nil then -- 61
								____opt_16(id) -- 74
							end -- 74
						end -- 74
					end -- 73
				} -- 73
			) -- 73
		end -- 73
		rowElements[#rowElements + 1] = React.createElement( -- 79
			Row, -- 80
			{ -- 80
				key = "row-" .. tostring(row), -- 80
				gap = gap, -- 80
				style = {height = slotSize} -- 80
			}, -- 80
			slots -- 81
		) -- 81
	end -- 81
	return React.createElement( -- 85
		Column, -- 86
		{ -- 86
			key = props.key, -- 86
			ref = props.ref, -- 86
			gap = gap, -- 86
			style = mergeStyle({width = width, height = height}, props.style), -- 86
			visible = props.visible, -- 86
			opacity = props.opacity -- 86
		}, -- 86
		rowElements -- 94
	) -- 94
end -- 47
return ____exports -- 47