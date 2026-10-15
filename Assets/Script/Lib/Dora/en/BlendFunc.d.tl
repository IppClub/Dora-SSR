-- A blend function object used for rendering.
local record BlendFunc
	userdata
end

-- A class for creating BlendFunc objects.
local record BlendFuncClass
	type Type = BlendFunc

	-- An enum defining blend functions.
	enum Func

		-- The source color is multiplied by 1 and added to the destination color (essentially, the source color is drawn on top of the destination color).
		"One"

		-- The source color is multiplied by 0 and added to the destination color (essentially, the source color has no effect on the destination color).
		"Zero"

		-- The source color is multiplied by the source alpha, and added to the destination color multiplied by the inverse of the source alpha.
		"SrcColor"

		-- The source alpha is multiplied by the source color, and added to the destination alpha multiplied by the inverse of the source alpha.
		"SrcAlpha"

		-- The destination color is multiplied by the destination alpha, and added to the source color multiplied by the inverse of the destination alpha.
		"DstColor"

		-- The destination alpha is multiplied by the source alpha, and added to the source alpha multiplied by the inverse of the destination alpha.
		"DstAlpha"

		-- Same as "SrcColor", but with the source and destination colors swapped.
		"InvSrcColor"

		-- Same as "SrcAlpha", but with the source and destination alphas swapped.
		"InvSrcAlpha"

		-- Same as "DstColor", but with the source and destination colors swapped.
		"InvDstColor"

		-- Same as "DstAlpha", but with the source and destination alphas swapped.
		"InvDstAlpha"
	end

	-- Gets the integer value of a blend function.
	-- @param func (Func) The blend function to get the value of.
	-- @return (integer) The integer value of the specified blend function.
	get: function(self: BlendFuncClass, func: Func): integer

	-- Creates a new BlendFunc instance with the specified source and destination factors.
	-- @param src (Func) The source blend factor.
	-- @param dst (Func) The destination blend factor.
	-- @return (BlendFunc) The new BlendFunc instance.
	metamethod __call: function(self: BlendFuncClass, src: Func, dst: Func): BlendFunc

	-- Creates a new BlendFunc instance with the specified source and destination factors for color and alpha channels.
	-- @param srcColor (Func) The source blend factor for the color channel.
	-- @param dstColor (Func) The destination blend factor for the color channel.
	-- @param srcAlpha (Func) The source blend factor for the alpha channel.
	-- @param dstAlpha (Func) The destination blend factor for the alpha channel.
	-- @return (BlendFunc) The new BlendFunc instance.
	metamethod __call: function(self: BlendFuncClass, srcColor: Func, dstColor: Func, srcAlpha: Func, dstAlpha: Func): BlendFunc

	-- The default blend function.
	-- Equals to BlendFunc("SrcAlpha", "InvSrcAlpha", "One", "InvSrcAlpha")
	const default: BlendFunc
end

local blendFuncClass: BlendFuncClass
return blendFuncClass
