-- [ts]: MascotModel.ts
local ____exports = {} -- 1
local ____MascotFrames = require("Dev.Mobile.MascotFrames") -- 1
local MASCOT_CELL_SIZE = ____MascotFrames.MASCOT_CELL_SIZE -- 1
local MASCOT_FRAME_PIVOT_X = ____MascotFrames.MASCOT_FRAME_PIVOT_X -- 1
local MASCOT_PIVOT_Y = ____MascotFrames.MASCOT_PIVOT_Y -- 1
do -- 1
	local ____MascotFrames = require("Dev.Mobile.MascotFrames") -- 2
	____exports.MASCOT_CELL_SIZE = ____MascotFrames.MASCOT_CELL_SIZE -- 2
	____exports.MASCOT_PIVOT_Y = ____MascotFrames.MASCOT_PIVOT_Y -- 2
end -- 2
____exports.MASCOT_FRAME_COUNT = 4 -- 3
____exports.mascotFramePivotX = function(row, frame) return MASCOT_FRAME_PIVOT_X[row * ____exports.MASCOT_FRAME_COUNT + frame + 1] end -- 5
____exports.mascotLayout = function(size) -- 7
	local scale = size / MASCOT_CELL_SIZE -- 9
	return {scale = scale, width = MASCOT_CELL_SIZE * scale, feetY = (MASCOT_CELL_SIZE / 2 - MASCOT_PIVOT_Y) * scale} -- 10
end -- 7
____exports.mascotFrameAt = function(elapsed, interval) return math.floor(elapsed / interval) % ____exports.MASCOT_FRAME_COUNT end -- 17
____exports.mascotAnimationTime = function(elapsed, dt, reducedMotion) return reducedMotion and 0 or elapsed + dt end -- 18
return ____exports -- 18