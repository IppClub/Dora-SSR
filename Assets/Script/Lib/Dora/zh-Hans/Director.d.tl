local Color = require("Color").Type
local Scheduler = require("Scheduler").Type
local Node = require("Node").Type
local Camera = require("Camera").Type

-- 游戏导演类，是用于管理游戏场景树，并提供多种用途的游戏场景根节点的单例类。
-- @usage
-- local Director = require("Director")
-- Director.entry:addChild(node)
local record Director
	userdata

	-- 用于设置游戏窗体的背景颜色。
	clearColor: Color

	-- 提供访问游戏调度器的方法，用于调度每帧执行的任务，如动画和游戏事件更新。
	scheduler: Scheduler

	-- 用于挂载 2D 用户界面元素（如按钮和标签）的根节点。
	const ui: Node

	-- 用于挂载带有 3D 投影视觉效果的 3D 用户界面元素的根节点。
	const ui3D: Node

	-- 用于挂载主要游戏内容场景树的根节点。
	const entry: Node

	-- 用于挂载在后期做渲染的物件的场景树的根节点。
	const postNode: Node

	-- 访问系统调度器的方法，用于调度底层的系统任务，不应在其中放置任何游戏逻辑。
	const systemScheduler: Scheduler

	-- 访问用于在后期处理的游戏逻辑的调度器的方法。
	const postScheduler: Scheduler

	-- 当前在应用的相机。
	const currentCamera: Camera

	-- 是否启用视锥体裁剪。
	frustumCulling: boolean

	-- 是否通过内置的 Web Socket 服务器发送收集的性能统计信息。只对 Web IDE 有用.
	profilerSending: boolean

	-- 添加新相机到相机堆栈中，并设置为当前应用的相机。
	-- @param camera (Camera) 要添加的相机。
	pushCamera: function(self: Director, camera: Camera)

	-- 从相机堆栈中删除当前应用的相机。
	popCamera: function(self: Director)

	-- 从相机堆栈中删除指定的相机。
	-- @param camera (Camera) 要删除的相机。
	-- @return (boolean) 如果相机被找到并删除，则为 true，否则为 false。
	removeCamera: function(self: Director, camera: Camera): boolean

	-- 从相机堆栈中删除所有相机。
	clearCamera: function(self: Director)

	-- 清理游戏导演类管理的所有资源，包括所有场景树和相机。
	cleanup: function(self: Director)
end

local director: Director
return director
