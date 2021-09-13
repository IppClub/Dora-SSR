local record BlendFunc end
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
	get: function(func: Func): integer
	const default: BlendFunc
	metamethod __call: function(cls: BlendFuncClass, src: Func, dst: Func): BlendFunc
end
local blendFuncClass: BlendFuncClass
return blendFuncClass
