local Size = require("Size").Type
local SpriteEffect = require("SpriteEffect").Type

-- 用于访问当前应用渲染视图设置的类。
local record View
	userdata

	-- 视图的像素尺寸。
	const size: Size

	-- 视图平面距原点的标准距离。
	const standardDistance: number

	-- 视图的宽高比。
	const aspectRatio: number

	-- 近裁剪平面的距离。
	nearPlaneDistance: number

	-- 远裁剪平面的距离。
	farPlaneDistance: number

	-- 视图的视野（以度数表示）。
	fieldOfView: number

	-- 视图的缩放比例系数。
	scale: number

	-- 要应用到视图的后处理着色器特效。
	postEffect: SpriteEffect

	-- 是否启用垂直同步。
	vsync: boolean
end

local view: View
return view
