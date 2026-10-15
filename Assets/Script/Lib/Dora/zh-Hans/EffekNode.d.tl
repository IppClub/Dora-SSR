local Node = require("Node").Type
local Vec2 = require("Vec2").Type

-- 用于播放 Effekseer 特效的类。
local record EffekNode

	-- 继承自`Node`.
	embed Node

	-- 播放一个 Effekseer 特效。
	-- @param filename (string) 要播放的特效文件的路径。
	-- @param pos (Vec2) [optional] 要播放特效的XY坐标位置。
	-- @param z (number) [optional] 要播放特效的Z坐标位置。
	-- @return (integer) 用于控制特效的句柄。
	play: function(self: EffekNode, filename: string, pos?: Vec2, z?: number): integer

	-- 停止一个 Effekseer 特效。
	-- @param handle (integer) 要停止的特效的句柄。
	stop: function(self: EffekNode, handle: integer)

	-- 注册一个回调函数，当一个 Effekseer 特效结束时触发。
	-- @param callback (function) 特效结束时的回调函数。
	-- 	@param handle (integer) 结束的特效的句柄。
	onEffekEnd: function(self: EffekNode, callback: function(handle: integer))
end

-- 用于创建 EffekNode 对象的类。
local record EffekNodeClass
	type Type = EffekNode

	-- 创建一个新的 EffekNode 对象。
	-- @return (EffekNode) 新创建的 EffekNode 对象。
	metamethod __call: function(self: EffekNodeClass): EffekNode
end

-- 用于连接到 EffekNode 对象的信号槽。
-- @usage
-- -- 可以使用以下形式的代码来注册监听这些事件：
-- local effekNode = EffekNode()
-- local laserHandle = effekNode:play("Laser.efk", Vec2.zero)
-- effekNode:slot("EffekEnd", function(handle: integer)
-- 	if handle == laserHandle then
-- 		print("激光特效已结束")
-- 	end
-- end)
local record __SLOT__

	-- 当一个 Effekseer 特效结束时触发。
	-- @param handle (integer) 结束的特效的句柄。
	["EffekEnd"]: function(handle: integer)
end

local effekNodeClass: EffekNodeClass
return effekNodeClass
