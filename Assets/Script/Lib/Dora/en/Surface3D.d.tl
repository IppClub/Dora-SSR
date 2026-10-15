local Node3D = require("Node3D").Type
local Node = require("Node").Type
local Size = require("Size").Type

-- Displays a 2D Node subtree in a View3D scene.
-- The engine automatically chooses direct rendering when the subtree can share
-- the 3D depth buffer, otherwise it uses an isolated render target.
local record Surface3D
	embed Node3D
	-- Billboard modes used by Surface3D.
	enum Billboard
		"None"
		"Screen"
		"YAxis"
	end
	content: Node
	-- The physical width and height in the 3D world.
	size: Size
	-- Raster size used when the subtree requires an isolated render target.
	pixelSize: Size
	-- Billboard mode. Default is `Billboard.None`.
	billboard: Billboard
	-- Whether the current frame selected the isolated render-target path.
	const usingTexture: boolean
end

local record Surface3DClass
	type Type = Surface3D
	metamethod __call: function(self: Surface3DClass, content: Node, size: Size, pixelSize?: Size --[[Size.zero]]): Surface3D | nil
end

local surface3DClass: Surface3DClass
return surface3DClass
