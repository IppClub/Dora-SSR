local record BlendFunc
	userdata
end
local record BlendFuncClass
	type Type = BlendFunc
	enum Func
		"One"
		"Zero"
		"SrcColor"
		"SrcAlpha"
		"DstColor"
		"DstAlpha"
		"InvSrcColor"
		"InvSrcAlpha"
		"InvDstColor"
		"InvDstAlpha"
	end
	get: function(self: BlendFuncClass, func: Func): integer
	metamethod __call: function(self: BlendFuncClass, src: Func, dst: Func): BlendFunc
	metamethod __call: function(self: BlendFuncClass, srcColor: Func, dstColor: Func, srcAlpha: Func, dstAlpha: Func): BlendFunc
	const default: BlendFunc
end
local blendFuncClass: BlendFuncClass
return blendFuncClass
