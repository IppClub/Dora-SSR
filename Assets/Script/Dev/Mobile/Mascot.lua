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
	local elapsed = props.animationStartedAt ~= nil and not App.reducedMotion and math.max(0, App.runningTime - props.animationStartedAt) or 0 -- 35
	local frame = mascotFrameAt(elapsed, props.state == "idle" and 0.34 or 0.2) -- 38
	local ____React_createElement_4 = React.createElement -- 38
	local ____temp_2 = { -- 38
		tag = "mascot-" .. props.state, -- 38
		x = snap(props.x), -- 38
		y = snap(props.y), -- 38
		onMount = function(node) return node:schedule(function(dt) -- 38
			elapsed = mascotAnimationTime(elapsed, dt, App.reducedMotion) -- 40
			local nextFrame = mascotFrameAt(elapsed, props.state == "idle" and 0.34 or 0.2) -- 41
			if nextFrame == frame then -- 41
				return false -- 42
			end -- 42
			frame = nextFrame -- 43
			local sprite = spriteRef.current -- 44
			if sprite then -- 44
				sprite.textureRect = frameRect(props.state, frame) -- 46
				sprite.anchor = Vec2( -- 47
					mascotFramePivotX( -- 47
						stateRow(props.state), -- 47
						frame -- 47
					) / MASCOT_CELL_SIZE, -- 47
					1 - MASCOT_PIVOT_Y / MASCOT_CELL_SIZE -- 47
				) -- 47
			end -- 47
			return false -- 49
		end) end -- 39
	} -- 39
	local ____React_createElement_result_3 = React.createElement( -- 39
		"sprite", -- 39
		{ -- 39
			tag = "mascot-sprite", -- 39
			ref = spriteRef, -- 39
			file = "Image/Mobile/dora-remix-states.png", -- 39
			textureRect = frameRect(props.state, frame), -- 39
			anchorX = mascotFramePivotX( -- 39
				stateRow(props.state), -- 52
				frame -- 52
			) / MASCOT_CELL_SIZE, -- 52
			anchorY = 1 - MASCOT_PIVOT_Y / MASCOT_CELL_SIZE, -- 52
			y = layout.feetY, -- 52
			scaleX = layout.scale, -- 52
			scaleY = layout.scale, -- 52
			filter = "Point", -- 52
			onMount = function(sprite) -- 52
				sprite.width = MASCOT_CELL_SIZE -- 54
				sprite.height = MASCOT_CELL_SIZE -- 54
			end -- 54
		} -- 54
	) -- 54
	local ____temp_0 -- 55
	if props.state ~= "idle" then -- 55
		____temp_0 = React.createElement( -- 55
			"draw-node", -- 55
			nil, -- 55
			React.createElement( -- 55
				"dot-shape", -- 55
				{ -- 55
					x = size * 0.36, -- 55
					y = -size * 0.38, -- 55
					radius = size * 0.17, -- 55
					color = stateColor(props.state) -- 55
				} -- 55
			) -- 55
		) -- 55
	else -- 55
		____temp_0 = nil -- 57
	end -- 57
	local ____temp_1 -- 58
	if props.state ~= "idle" then -- 58
		____temp_1 = React.createElement( -- 58
			"label", -- 58
			{ -- 58
				x = size * 0.36, -- 58
				y = -size * 0.38, -- 58
				fontName = "sarasa-mono-sc-regular", -- 58
				fontSize = math.floor(size * 0.22), -- 58
				text = stateMark(props.state), -- 58
				color3 = 1512202 -- 58
			} -- 58
		) -- 58
	else -- 58
		____temp_1 = nil -- 59
	end -- 59
	return ____React_createElement_4( -- 39
		"node", -- 39
		____temp_2, -- 39
		____React_createElement_result_3, -- 39
		____temp_0, -- 39
		____temp_1 -- 39
	) -- 39
end -- 30
return ____exports -- 30