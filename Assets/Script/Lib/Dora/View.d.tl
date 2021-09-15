local Size = require("Size").Type
local SpriteEffect = require("SpriteEffect").Type
local record View
	userdata
	const size: Size
	const standardDistance: number
	const aspectRatio: number
	nearPlaneDistance: number
	farPlaneDistance: number
	fieldOfView: number
	scale: number
	postEffect: SpriteEffect
	vsync: boolean
end
print(View.size)
print(View.postEffect)
local view: View
return view
