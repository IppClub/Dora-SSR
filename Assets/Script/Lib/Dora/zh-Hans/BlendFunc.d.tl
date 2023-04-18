-- 用于渲染的混合函数对象。
local record BlendFunc
	userdata
end

-- 用于创建混合函数对象的类。
local record BlendFuncClass
	type Type = BlendFunc

	-- 混合函数的枚举类型。
	enum Func

		-- 源颜色乘以 1 并加到目标颜色上（源颜色绘制在目标颜色之上）。
		"One"

		-- 源颜色乘以 0 并加到目标颜色上（源颜色对目标颜色没有影响）。
		"Zero"

		-- 源颜色乘以源 alpha 值，加到目标颜色乘以（1 - 源 alpha 值）上。
		"SrcColor"

		-- 源 alpha 值乘以源颜色，加到目标 alpha 值乘以（1 - 源 alpha 值）上。
		"SrcAlpha"

		-- 目标颜色乘以目标 alpha 值，加到源颜色乘以（1 - 目标 alpha 值）上。
		"DstColor"

		-- 目标 alpha 值乘以源 alpha 值，加到源 alpha 值乘以（1 - 目标 alpha 值）上。
		"DstAlpha"

		-- 类似于 "SrcColor"，但是交换源颜色和目标颜色做计算。
		"InvSrcColor"

		-- 类似于 "SrcAlpha"，但是交换源 alpha 值和目标 alpha 值做计算。
		"InvSrcAlpha"

		-- 类似于 "DstColor"，但是交换源颜色和目标颜色做计算。
		"InvDstColor"

		-- 类似于 "DstAlpha"，但是交换源 alpha 值和目标 alpha 值做计算。
		"InvDstAlpha"
	end

	-- 获取混合函数的参数值。
	-- @param func (Func) 要获取参数值的混合函数。
	-- @return (integer) 混合函数的参数值。
	get: function(self: BlendFuncClass, func: Func): integer

	-- 创建新的混合函数对象。
	-- @param src (Func) 源混合函数。
	-- @param dst (Func) 目标混合函数。
	-- @return (BlendFunc) 新的混合函数对象。
	metamethod __call: function(self: BlendFuncClass, src: Func, dst: Func): BlendFunc

	-- 创建新的混合函数对象。
	-- @param srcColor (Func) 颜色通道的源混合函数。
	-- @param dstColor (Func) 颜色通道的目标混合函数。
	-- @param srcAlpha (Func) alpha 通道的源混合函数。
	-- @param dstAlpha (Func) alpha 通道的目标混合函数。
	-- @return (BlendFunc) 新的混合函数对象。
	metamethod __call: function(self: BlendFuncClass, srcColor: Func, dstColor: Func, srcAlpha: Func, dstAlpha: Func): BlendFunc

	-- 默认的混合函数。
	-- 等同于 BlendFunc("SrcAlpha", "InvSrcAlpha", "One", "InvSrcAlpha")
	const default: BlendFunc
end

local blendFuncClass: BlendFuncClass
return blendFuncClass
