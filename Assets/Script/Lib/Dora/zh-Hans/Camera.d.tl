local Object = require("Object").Type

-- 游戏引擎中相机对象的类。
local record Camera

	-- 继承自`Object`
	embed Object

	-- 相机的名称。
	const name: string
end

local record CameraClass
	type Type = Camera
end

local cameraClass: CameraClass
return cameraClass
