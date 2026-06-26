-- [ts]: clip.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Vec2 = ____Dora.Vec2 -- 1
local nvg = require("nvg") -- 3
local clips = {} -- 10
function ____exports.registerClip(node, width, height) -- 12
	clips[node] = { -- 13
		width = math.max(0, width), -- 14
		height = math.max(0, height) -- 15
	} -- 15
end -- 12
function ____exports.unregisterClip(node) -- 19
	clips[node] = nil -- 20
end -- 19
local function resolveClipRect(node, clipNode, clip) -- 23
	local worldA = clipNode:convertToWorldSpace(Vec2(0, 0)) -- 24
	local worldB = clipNode:convertToWorldSpace(Vec2(clip.width, clip.height)) -- 25
	local localA = node:convertToNodeSpace(worldA) -- 26
	local localB = node:convertToNodeSpace(worldB) -- 27
	return { -- 28
		x = math.min(localA.x, localB.x), -- 29
		y = math.min(localA.y, localB.y), -- 30
		width = math.abs(localB.x - localA.x), -- 31
		height = math.abs(localB.y - localA.y) -- 32
	} -- 32
end -- 23
function ____exports.applyAncestorClips(node) -- 36
	local clipped = false -- 37
	local parent = node.parent -- 38
	while parent ~= nil do -- 38
		local clip = clips[parent] -- 40
		if clip ~= nil and clip.width > 0 and clip.height > 0 then -- 40
			local rect = resolveClipRect(node, parent, clip) -- 42
			if clipped then -- 42
				nvg.IntersectScissor(rect.x, rect.y, rect.width, rect.height) -- 44
			else -- 44
				nvg.Scissor(rect.x, rect.y, rect.width, rect.height) -- 46
				clipped = true -- 47
			end -- 47
		end -- 47
		parent = parent.parent -- 50
	end -- 50
end -- 36
return ____exports -- 36