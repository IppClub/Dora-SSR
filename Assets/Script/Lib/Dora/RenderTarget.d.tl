local Node = require("Node").Type
local Camera = require("Camera").Type
local Sprite = require("Sprite").Type
local Color = require("Color").Type
local record RenderTarget
	embed Node
	camera: Camera
	const surface: Sprite
	render: function(self: RenderTarget, target: Node)
	renderWithClear: function(self: RenderTarget, color: Color, depth: number --[[1]], stencil: number --[[0]])
	renderWithClear: function(self: RenderTarget, target: Node, color: Color, depth: number --[[1]], stencil: integer --[[0]])
	saveAsync: function(self: RenderTarget, filename: string)
end
local record RenderTargetClass
	type Type = RenderTarget
	metamethod __call: function(cls: RenderTargetClass, width: integer, height: integer): RenderTarget
end
local renderTarget: RenderTarget
return renderTarget
