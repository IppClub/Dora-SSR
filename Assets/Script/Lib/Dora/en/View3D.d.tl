local Node3D = require("Node3D").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type
local Vec3 = require("Vec3").Type
local Model3D = require("Model3D").Type
local RenderStats3D = require("RenderStats3DType")

-- Class used for rendering 3D content inside the 2D scene tree.
local record View3D

	-- Inherits from `Node`.
	embed Node

	-- The root node of the 3D scene.
	const scene: Node3D

	-- Statistics from the most recent 3D render and current 3D registries.
	const stats: RenderStats3D

	-- Whether current world AABBs are drawn for debugging.
	showAABB: boolean

	-- The shadow map side length. The value is normalized to 256, 512, 1024, 2048, or 4096.
	shadowMapSize: number

	-- Returns the world-space origin of the picking ray through a view point.
	getRayOrigin: function(self: View3D, viewPoint: Vec2): Vec3

	-- Returns the world-space direction of the picking ray through a view point.
	getRayDirection: function(self: View3D, viewPoint: Vec2): Vec3

	-- Returns the nearest visible model intersected by a view point.
	pick: function(self: View3D, viewPoint: Vec2): Model3D | nil

	-- Loads an environment map for image based lighting.
	-- @param path (string) The environment texture path. Empty string clears the environment map.
	-- @return (boolean) True when the environment map is loaded or cleared successfully.
	setEnvironmentMap: function(self: View3D, path: string): boolean

	-- Sets diffuse, specular and exposure intensity for environment lighting.
	-- @param diffuse (number) The diffuse lighting intensity.
	-- @param specular (number) The specular lighting intensity.
	-- @param exposure (number) [optional] The exposure value. Default is 1.0.
	setEnvironmentIntensity: function(
		self: View3D,
		diffuse: number,
		specular: number,
		exposure?: number --[[1.0]]
	)
end

local record View3DClass
	type Type = View3D

	-- Creates a new View3D object.
	-- @return (View3D) A new View3D object.
	metamethod __call: function(self: View3DClass): View3D
end

local view3DClass: View3DClass
return view3DClass
