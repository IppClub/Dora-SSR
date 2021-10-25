local Node = require("Node").Type
local Object = require("Object").Type
local Camera = require("Camera").Type
local Texture2D = require("Texture2D").Type
local Color = require("Color").Type
local record RenderTarget
	embed Object
	width: integer
	height: integer
	camera: Camera
	texture: Texture2D
	render: function(self: RenderTarget, target: Node)
	renderWithClear: function(
		self: RenderTarget,
		color: Color,
		depth?: number --[[1]],
		stencil?: number --[[0]]
	)
	renderWithClear: function(
		self: RenderTarget,
		target: Node,
		color: Color,
		depth?: number --[[1]],
		stencil?: integer --[[0]]
	)
	saveAsync: function(self: RenderTarget, filename: string)
end
local record RenderTargetClass
	type Type = RenderTarget
	metamethod __call: function(cls: RenderTargetClass, width: integer, height: integer): RenderTarget
end
print(RenderTarget.camera)
print(RenderTarget.texture)
local renderTargetClass: RenderTargetClass
return renderTargetClass
