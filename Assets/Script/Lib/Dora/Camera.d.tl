local Object = require("Object").Type
local record Camera
	embed Object
	const name: string
end
local record CameraClass
	type Type = Camera
end
local cameraClass: CameraClass
return cameraClass
