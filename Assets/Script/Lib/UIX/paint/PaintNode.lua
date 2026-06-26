-- [tsx]: PaintNode.tsx
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Node = ____Dora.Node -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____DoraX = require("DoraX") -- 3
local React = ____DoraX.React -- 3
local useCallback = ____DoraX.useCallback -- 3
local useRef = ____DoraX.useRef -- 3
local nvg = require("nvg") -- 4
local ____context = require("UIX.context") -- 5
local getUiContext = ____context.getUiContext -- 5
local ____clip = require("UIX.paint.clip") -- 6
local applyAncestorClips = ____clip.applyAncestorClips -- 6
local ____types = require("UIX.types") -- 7
local mergeInteractionState = ____types.mergeInteractionState -- 7
function ____exports.PaintNode(props) -- 33
	local holder = useRef() -- 34
	holder.current = props -- 35
	local onCreate = useCallback( -- 36
		function() -- 36
			local node = Node() -- 37
			node.anchor = Vec2(0, 0) -- 38
			node:onRender(function() -- 39
				local latest = holder.current -- 40
				local ui = getUiContext() -- 41
				local parent = node.parent -- 42
				local width = latest.width or parent and parent.width or node.width -- 43
				local height = latest.height or parent and parent.height or node.height -- 44
				node.size = Size(width, height) -- 45
				nvg.Save() -- 46
				nvg.ApplyTransform(node) -- 47
				applyAncestorClips(node) -- 48
				latest.painter({ -- 49
					width = width, -- 50
					height = height, -- 51
					theme = ui.theme, -- 52
					pixelRatio = ui.scale, -- 53
					opacity = latest.opacity or 1, -- 54
					state = mergeInteractionState(latest.state), -- 55
					time = App.elapsedTime, -- 56
					data = latest.data, -- 57
					node = node -- 58
				}) -- 58
				nvg.Restore() -- 60
				return false -- 61
			end) -- 39
			local ____opt_4 = holder.current.onMountNode -- 39
			if ____opt_4 ~= nil then -- 39
				____opt_4(node) -- 63
			end -- 63
			return node -- 64
		end, -- 36
		{holder} -- 65
	) -- 65
	return React.createElement( -- 66
		"custom-node", -- 66
		{ -- 66
			ref = props.ref, -- 66
			key = props.key, -- 66
			order = props.order, -- 66
			renderOrder = props.renderOrder, -- 66
			visible = props.visible, -- 66
			opacity = props.opacity, -- 66
			onCreate = onCreate, -- 66
			onUnmount = function(____self) -- 66
				local clearRender = ____self.clearRender -- 76
				if type(clearRender) == "function" then -- 76
					clearRender(____self) -- 78
				end -- 78
			end -- 75
		} -- 75
	) -- 75
end -- 33
return ____exports -- 33