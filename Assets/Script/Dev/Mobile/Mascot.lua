-- [tsx]: Mascot.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local reference = ____DoraX.reference -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Rect = ____Dora.Rect -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ____MascotModel = require("Dev.Mobile.MascotModel") -- 3
local MASCOT_CELL_SIZE = ____MascotModel.MASCOT_CELL_SIZE -- 3
local MASCOT_PIVOT_Y = ____MascotModel.MASCOT_PIVOT_Y -- 3
local mascotAnimationTime = ____MascotModel.mascotAnimationTime -- 3
local mascotFrameAt = ____MascotModel.mascotFrameAt -- 3
local mascotFramePivotX = ____MascotModel.mascotFramePivotX -- 3
local mascotLayout = ____MascotModel.mascotLayout -- 3
local function stateColor(state) -- 7
	return state == "success" and 4285388172 or (state == "failed" and 4294929259 or (state == "working" and 4294954035 or (state == "thinking" and 4285708287 or (state == "waiting" and 4289245117 or 4294242792)))) -- 7
end -- 7
local function stateMark(state) -- 14
	return state == "success" and "✓" or (state == "failed" and "!" or (state == "working" and "›" or (state == "thinking" and "…" or (state == "waiting" and "·" or "")))) -- 14
end -- 14
local function stateRow(state) -- 21
	return state == "waiting" and 1 or (state == "thinking" and 2 or (state == "working" and 3 or (state == "success" and 4 or (state == "failed" and 5 or 0)))) -- 21
end -- 21
local function frameRect(state, frame) -- 28
	return Rect( -- 28
		frame * MASCOT_CELL_SIZE, -- 28
		stateRow(state) * MASCOT_CELL_SIZE, -- 28
		MASCOT_CELL_SIZE, -- 28
		MASCOT_CELL_SIZE -- 28
	) -- 28
end -- 28
function ____exports.DoraMascot(props) -- 30
	local size = props.size or 48 -- 31
	local layout = mascotLayout(size) -- 32
	local function snap(value) -- 33
		return math.floor(value * App.devicePixelRatio + 0.5) / App.devicePixelRatio -- 33
	end -- 33
	local spriteRef = reference() -- 34
	local frame = 0 -- 35
	local elapsed = 0 -- 36
	local ____React_createElement_4 = React.createElement -- 36
	local ____temp_2 = { -- 36
		tag = "mascot-" .. props.state, -- 36
		x = snap(props.x), -- 36
		y = snap(props.y), -- 36
		onMount = function(node) return node:schedule(function(dt) -- 36
			elapsed = mascotAnimationTime(elapsed, dt, App.reducedMotion) -- 38
			local nextFrame = mascotFrameAt(elapsed, props.state == "idle" and 0.34 or 0.2) -- 39
			if nextFrame == frame then -- 39
				return false -- 40
			end -- 40
			frame = nextFrame -- 41
			local sprite = spriteRef.current -- 42
			if sprite then -- 42
				sprite.textureRect = frameRect(props.state, frame) -- 44
				sprite.anchor = Vec2( -- 45
					mascotFramePivotX( -- 45
						stateRow(props.state), -- 45
						frame -- 45
					) / MASCOT_CELL_SIZE, -- 45
					1 - MASCOT_PIVOT_Y / MASCOT_CELL_SIZE -- 45
				) -- 45
			end -- 45
			return false -- 47
		end) end -- 37
	} -- 37
	local ____React_createElement_result_3 = React.createElement( -- 37
		"sprite", -- 37
		{ -- 37
			tag = "mascot-sprite", -- 37
			ref = spriteRef, -- 37
			file = "Image/Mobile/dora-remix-states.png", -- 37
			textureRect = frameRect(props.state, 0), -- 37
			anchorX = mascotFramePivotX( -- 37
				stateRow(props.state), -- 50
				0 -- 50
			) / MASCOT_CELL_SIZE, -- 50
			anchorY = 1 - MASCOT_PIVOT_Y / MASCOT_CELL_SIZE, -- 50
			y = layout.feetY, -- 50
			scaleX = layout.scale, -- 50
			scaleY = layout.scale, -- 50
			filter = "Point", -- 50
			onMount = function(sprite) -- 50
				sprite.width = MASCOT_CELL_SIZE -- 52
				sprite.height = MASCOT_CELL_SIZE -- 52
			end -- 52
		} -- 52
	) -- 52
	local ____temp_0 -- 53
	if props.state ~= "idle" then -- 53
		____temp_0 = React.createElement( -- 53
			"draw-node", -- 53
			nil, -- 53
			React.createElement( -- 53
				"dot-shape", -- 53
				{ -- 53
					x = size * 0.36, -- 53
					y = -size * 0.38, -- 53
					radius = size * 0.17, -- 53
					color = stateColor(props.state) -- 53
				} -- 53
			) -- 53
		) -- 53
	else -- 53
		____temp_0 = nil -- 55
	end -- 55
	local ____temp_1 -- 56
	if props.state ~= "idle" then -- 56
		____temp_1 = React.createElement( -- 56
			"label", -- 56
			{ -- 56
				x = size * 0.36, -- 56
				y = -size * 0.38, -- 56
				fontName = "sarasa-mono-sc-regular", -- 56
				fontSize = math.floor(size * 0.22), -- 56
				text = stateMark(props.state), -- 56
				color3 = 1512202 -- 56
			} -- 56
		) -- 56
	else -- 56
		____temp_1 = nil -- 57
	end -- 57
	return ____React_createElement_4( -- 37
		"node", -- 37
		____temp_2, -- 37
		____React_createElement_result_3, -- 37
		____temp_0, -- 37
		____temp_1 -- 37
	) -- 37
end -- 30
return ____exports -- 30