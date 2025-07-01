local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local Size = require("Size").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local Scheduler = require("Scheduler").Type
local Array = require("Array").Type
local Dictionary = require("Dictionary").Type
local Action = require("Action").Type
local ActionDef = require("Action").Def
local Slot = require("Slot").Type
local GSlot = require("GSlot").Type
local Touch = require("Touch").Type
local Routine = require("Routine")
local Camera = require("Camera").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Keyboard = require("Keyboard")
local Controller = require("Controller")

-- 用于构建游戏场景树的层次结构的类。
local record Node

	-- 继承自`Object`。
	embed Object

	-- 在同级子节点列表中的顺序。
	order: integer

	-- 节点的旋转角度，以度为单位。
	angle: number

	-- 节点的 X 轴旋转角度，以度为单位。
	angleX: number

	-- 节点的 Y 轴旋转角度，以度为单位。
	angleY: number

	-- 节点的 X 轴缩放系数。
	scaleX: number

	-- 节点的 Y 轴缩放系数。
	scaleY: number

	-- 节点的 Z 轴缩放系数。
	scaleZ: number

	-- 节点的 X 轴位置。
	x: number

	-- 节点的 Y 轴位置。
	y: number

	-- 节点的 Z 轴位置。
	z: number

	-- 以二维向量对象表示的节点位置。
	position: Vec2

	-- 节点的 X 轴倾斜角度，以度为单位。
	skewX: number

	-- 节点的 Y 轴倾斜角度，以度为单位。
	skewY: number

	-- 节点是否可见。
	visible: boolean

	-- 以 Vec2 对象表示的节点锚点。
	anchor: Vec2

	-- 节点的宽度。
	width: number

	-- 节点的高度。
	height: number

	-- 以`Size`对象表示的节点大小。
	size: Size

	-- 以字符串形式表示的节点标签。
	tag: string

	-- 节点的不透明度，取值范围为 0 到 1.0。
	opacity: number

	-- 以`Color`对象表示的节点颜色。
	color: Color

	-- 以`Color3`对象表示的节点颜色。
	color3: Color3

	-- 是否传递不透明度值给子节点。
	passOpacity: boolean

	-- 是否传递颜色值给子节点。
	passColor3: boolean

	-- 用于继承矩阵变换的目标节点。
	transformTarget: Node

	-- 用于调度每帧逻辑更新的调度器。
	scheduler: Scheduler

	-- 是否有子节点。
	const hasChildren: boolean

	-- 子节点的列表，可能为nil。
	const children: Array

	-- 节点的父节点。
	const parent: Node

	-- 节点是否在场景树中挂载运行。
	const running: boolean

	-- 节点是否在调度更新函数或协程。
	const scheduled: boolean

	-- 节点上当前正在运行的动作数量。
	const actionCount: integer

	-- 在节点上存储管理的附加数据。
	const data: Dictionary

	-- 是否启用触摸事件。
	touchEnabled: boolean

	-- 节点是否独占触摸事件。
	swallowTouches: boolean

	-- 节点是否独占鼠标滚轮事件。
	swallowMouseWheel: boolean

	-- 是否启用键盘事件。
	keyboardEnabled: boolean

	-- 是否启用游戏手柄事件。
	controllerEnabled: boolean

	-- 是否将所有层级的子节点按分组编号做分组渲染。
	renderGroup: boolean

	-- 是否显示节点的调试信息。
	showDebug: boolean

	-- 用于分组渲染的分组顺序编号。节点的渲染顺序编号越小，渲染就越靠前。
	renderOrder: integer

	-- 给当前节点添加子节点。
	-- @param child (Node) 要添加的子节点。
	-- @param order (integer) [可选] 子节点的绘制顺序。默认为0。
	-- @param tag (string) [可选] 子节点的标签。默认为空字符串。
	addChild: function(
		self: Node,
		child: Node,
		order?: integer --[[0]],
		tag?: string --[[""]]
	)

	-- 将当前节点添加到父节点
	-- @param parent (Node) 要添加当前节点的父节点。
	-- @param order (integer) [可选] 当前节点的绘制顺序。默认为0。
	-- @param tag (string) [可选] 当前节点的标签。默认为空字符串。
	-- @return (Node) 当前节点，用于级连调用。
	addTo: function(
		self: Node,
		parent: Node,
		order?: integer --[[0]],
		tag?: string --[[""]]
	): Node

	-- 从当前节点中移除一个子节点。
	-- @param child (Node) 要移除的子节点。
	-- @param cleanup (boolean) [可选] 是否清理子节点。默认为 true。
	removeChild: function(
		self: Node,
		child: Node,
		cleanup?: boolean --[[true]]
	)

	-- 通过标签从当前节点中移除一个子节点。
	-- @param tag (string) 要移除的子节点的标签。
	-- @param cleanup (boolean) [可选] 是否清理子节点。默认为 true。
	removeChildByTag: function(
		self: Node,
		tag: string,
		cleanup?: boolean --[[true]]
	)

	-- 从当前节点中移除所有子节点。
	-- @param cleanup (boolean) [可选] 是否清理子节点。默认为 true。
	removeAllChildren: function(
		self: Node,
		cleanup?: boolean --[[true]]
	)

	-- 从其父节点中移除当前节点。
	-- @param cleanup (boolean) [可选] 是否清理当前节点。默认为 true。
	removeFromParent: function(
		self: Node,
		cleanup?: boolean --[[true]]
	)

	-- 将当前节点移动到一个新的父节点中，而不触发节点进出场景树的事件。
	-- @param parent (Node) 要将当前节点移动到的新父节点。
	moveToParent: function(self: Node, parent: Node)

	-- 清理当前节点上的所有资源。
	cleanup: function(self: Node)

	-- 通过标签获取子节点。
	-- @param tag (string) 要获取的子节点的标签。
	-- @return (Node) 子节点，如果未找到则返回nil。
	getChildByTag: function(self: Node, tag: string): Node

	-- 调度一个主更新函数在每一帧运行。重复调用会覆盖被调度的主更新函数或协程任务。
	-- @param func (function) 要被调度的主更新函数，返回true停止运行。
	schedule: function(self: Node, func: function(number): boolean)

	-- 调度执行一个主协程任务。重复调用会覆盖被调度的主更新函数或协程任务。
	-- @param job (Routine.Job) 要运行的主协程，用`return true`或`coroutine.yield(true)`停止运行。
	schedule: function(self: Node, job: Routine.Job)

	-- 停止调度的每帧运行的主更新函数或协程任务。
	unschedule: function(self: Node)

	-- 调度一个函数，该函数会在协程中运行一次。调用该函数会覆盖被调度的主更新函数或协程任务。
	-- @param func (function) 要在协程运行一次的函数。
	once: function(self: Node, func: function())

	-- 调度一个函数，该函数会在协程中循环执行。调用该函数会覆盖被调度的主更新函数或协程任务。
	-- @param func (function) 要在循环执行的函数，返回true以停止。
	loop: function(self: Node, func: function(): boolean)

	-- 将世界空间中的点坐标转换为节点空间的点坐标。
	-- @param worldPoint (Vec2) 要转换的点。
	-- @return (Vec2) 转换后的点。
	convertToNodeSpace: function(self: Node, worldPoint: Vec2): Vec2

	-- 将世界空间中的点坐标转换为节点空间的点坐标。
	-- @param worldPoint (Vec2) 要转换的点。
	-- @param z (number) 点的 z 坐标。
	-- @return (Vec2) 转换后的点。
	-- @return (number) 转换后的点的 z 坐标。
	convertToNodeSpace: function(self: Node, worldPoint: Vec2, z: number): Vec2, number

	-- 将节点空间中的点坐标转换为世界空间坐标。
	-- @param nodePoint (Vec2) 节点空间中的点。
	-- @return (Vec2) 转换后的世界空间中的点。
	convertToWorldSpace: function(self: Node, nodePoint: Vec2): Vec2

	-- 将节点空间中的点坐标转换为世界空间坐标。
	-- @param nodePoint (Vec2) 节点空间中的点。
	-- @param z (number) 节点空间中的 z 坐标。
	-- @return (Vec2) 转换后的世界空间中的点。
	-- @return (number) 转换后的世界空间中 z 坐标。
	convertToWorldSpace: function(self: Node, nodePoint: Vec2, z: number): Vec2, number

	-- 将节点空间中的点坐标转换为操作系统窗口空间坐标。
	-- @param nodePoint (Vec2) 节点空间中的点。
	-- @param callback (function) 接收转换后的操作系统窗口空间中的点点坐标的回调函数。
	convertToWindowSpace: function(self: Node, nodePoint: Vec2, callback: function(Vec2))

	-- 对该节点的每个子节点调用给定的函数。在迭代过程中，子节点不能被添加或删除。
	-- @param func (function) 对每个子节点要调用的函数。该函数应返回一个布尔值，指示是否继续迭代。返回 true 以停止迭代。
	-- @return (boolean) 如果已访问所有子节点，则为false；如果函数中断了迭代，则为true。
	eachChild: function(self: Node, func: function(Node): boolean): boolean

	-- 从此节点开始遍历场景树结构，并对每个访问的节点调用给定的函数。
	-- 未开启`TraverseEnabled`标志的节点不会被访问。在迭代过程中，子节点不能被添加或删除。
	-- @param func (function) 对于每个被访问的节点调用的函数。该函数应返回一个布尔值，指示是否继续遍历。返回true停止迭代。
	-- @return (boolean) 如果访问了所有节点，则为false，如果函数中断了遍历，则为true。
	traverse: function(self: Node, func: function(Node): boolean): boolean

	-- 从此节点开始遍历整个节点层次结构，并对每个访问的节点调用给定的函数。
	-- 未开启`TraverseEnabled`标志的节点也会被访问。在迭代过程中，子节点不能被添加或删除。
	-- @param func (function) 对于每个访问的节点调用的函数。该函数应返回一个布尔值，指示是否继续遍历。
	-- @return (boolean) 如果访问了所有节点，则为true，如果函数中断了遍历，则为false。
	traverseAll: function(self: Node, func: function(Node): boolean): boolean

	-- 在此节点上执行给定的动作对象。
	-- @param action (Action) 要执行的动作对象。
	-- @param loop (boolean) [可选] 是否循环执行动作。默认为 false。
	-- @return (number) 新执行的动作的持续时间，以秒为单位。
	runAction: function(self: Node, action: Action, loop?: boolean): number

	-- 在此节点上执行由动作定义对象定义的动作。
	-- @param actionDef (ActionDef) 要运行的动作定义。
	-- @param loop (boolean) [可选] 是否循环执行动作。默认为 false。
	-- @return (number) 新执行的动作的持续时间，以秒为单位。
	runAction: function(self: Node, actionDef: ActionDef, loop?: boolean): number

	-- 停止在此节点上运行的所有动作。
	stopAllActions: function(self: Node)

	-- 立即停止所有现有动作，并开始执行一个新动作。
	-- @param action (Action) 要执行的动作。
	-- @param loop (boolean) [可选] 是否循环执行动作。默认为 false。
	-- @return (number) 新执行的动作的持续时间，以秒为单位。
	perform: function(self: Node, action: Action, loop?: boolean): number

	-- 立即停止所有现有动作，并通过动作定义对象开始执行一个新动作。
	-- @param actionDef (ActionDef) 要执行的动作定义。
	-- @param loop (boolean) [可选] 是否循环执行动作。默认为 false。
	-- @return (number) 新执行的动作的持续时间，以秒为单位。
	perform: function(self: Node, actionDef: ActionDef, loop?: boolean): number

	-- 停止在此节点上运行的某个动作。
	-- @param action (Action) 要停止的动作。
	stopAction: function(self: Node, action: Action)

	-- 垂直对齐该节点的所有子节点。
	-- @param padding (number) [可选] 子节点之间的间距。默认值为10。
	-- @return (Size) 对齐后的子节点区域的大小。
	alignItemsVertically: function(
		self: Node,
		padding?: number --[[10]]
	): Size

	-- 使用给定的范围和间距在节点内垂直对齐所有子节点。
	-- @param size (Size) 用于对齐排布的范围。
	-- @param padding (number) [可选] 子节点之间的间距（默认值为10）。
	-- @return (Size) 对齐后的节点区域大小。
	alignItemsVertically: function(
		self: Node,
		size: Size,
		padding?: number --[[10]]
	): Size

	-- 使用给定的间距在节点内水平对齐所有子节点。
	-- @param padding (number) [可选] 子节点之间的间距（默认值为10）。
	-- @return (Size) 对齐后的节点区域大小。
	alignItemsHorizontally: function(
		self: Node,
		padding?: number --[[10]]
	): Size

	-- 使用给定的范围和间距在节点内水平对齐所有子节点。
	-- @param size (Size) 用于对齐排布的范围。
	-- @param padding (number) [可选] 子节点之间的间距（默认值为10）。
	-- @return (Size) 对齐后的节点区域大小。
	alignItemsHorizontally: function(
		self: Node,
		size: Size,
		padding?: number --[[10]]
	): Size

	-- 使用给定间距在节点内对齐所有子节点。
	-- @param padding (number) [可选] 子节点之间的间距（默认值为10）。
	-- @return (Size) 对齐后的节点区域大小。
	alignItems: function(
		self: Node,
		padding?: number --[[10]]
	): Size

	-- 使用给定的范围和间距在节点内对齐所有子节点。
	-- @param size (Size) 用于对齐排布的范围。
	-- @param padding (number) [可选] 每个子节点之间要使用的填充量（默认值为10）。
	-- @return (Size) 对齐后的节点大小。
	alignItems: function(
		self: Node,
		size: Size,
		padding?: number --[[10]]
	): Size

	-- 基于子节点在父节点区域中的位置，移动并更改子节点的可见性。
	-- @param delta (Vec2) 子节点移动的向量。
	moveAndCullItems: function(self: Node, delta: Vec2)

	-- 将操作系统输入法功能 (IME) 开启到节点上。
	-- 使节点能接收 "AttachIME"、"DetachIME"、"TextInput"、"TextEditing" 事件。
	attachIME: function(self: Node)

	-- 在节点上关闭操作系统输入法 (IME)。
	detachIME: function(self: Node)

	-- 获取挂在节点上的监听特定全局事件的所有信号槽。
	-- @param eventName (string) 全局事件的名称。
	-- @return ({GSlot}) 节点上监听对应全局事件的所有信号槽。
	gslot: function(self: Node, eventName: string): {GSlot}

	-- 在节点上注册监听全局事件的回调函数。
	-- @param eventName (string) 全局事件的名称。
	-- @param handler (function) 全局事件的处理函数。
	-- @return (GSlot) 节点上监听该全局事件的监听器对象。
	gslot: function(self: Node, eventName: string, handler: function()): GSlot

	-- 获取挂在节点上的监听特定节点事件的所有信号槽。
	-- @param eventName (string) 节点事件的名称。
	-- @return (Slot) 节点上监听对应节点事件的信号槽。
	slot: function(self: Node, eventName: string): Slot

	-- 在节点上注册监听节点事件的回调函数。
	-- @param eventName (string) 节点事件的名称。
	-- @param handler (function) 节点事件的处理函数。
	slot: function(self: Node, eventName: string, handler: function())

	-- 发送一个节点事件。
	-- @param eventName (string) 节点事件的名称。
	-- @param ... (...any) 传递给节点事件处理函数的参数。
	emit: function(self: Node, eventName: string, ...: any)

	-- 将场景的一部分节点渲染到一张绑定到网格的纹理上的抓取器类。
	-- @usage
	-- local node = Node()
	-- node.size = Size(500, 500)
	-- local grabber = node:grab(true)
	-- grabber:moveUV(0, 0, Vec2(0, 0.1))
	record Grabber

		-- 继承自`Object`。
		embed Object

		-- 用于渲染网格的相机。
		camera: Camera

		-- 渲染网格使用的图元着色器特效。
		effect: SpriteEffect

		-- 渲染网格使用的混合函数。
		blendFunc: BlendFunc

		-- 用于清空纹理的颜色。
		clearColor: Color

		-- 设置抓取器网格中一个顶点的位置。
		-- @param x (integer) 顶点在抓取器网格中的 x 索引。
		-- @param y (integer) 顶点在抓取器网格中的 y 索引。
		-- @param pos (Vec2) 顶点的新位置。
		-- @param z (number) [可选] 顶点的新 z 坐标（默认值：0.0）。
		setPos: function(self: Grabber, x: integer, y: integer, pos: Vec2, z?: number --[[0.0]])

		-- 获取抓取器网格中一个顶点的位置。
		-- @param x (integer) 顶点在抓取器网格中的 x 索引。
		-- @param y (integer) 顶点在抓取器网格中的 y 索引。
		-- @return (Vec2) 顶点的位置。
		getPos: function(self: Grabber, x: integer, y: integer): Vec2

		-- 获取抓取器网格中一个顶点的颜色。
		-- @param x (integer) 顶点在抓取器网格中的 x 索引。
		-- @param y (integer) 顶点在抓取器网格中的 y 索引。
		-- @return (Color) 顶点的颜色。
		getColor: function(self: Grabber, x: integer, y: integer): Color

		-- 设置抓取器网格中一个顶点的颜色。
		-- @param x (integer) 顶点在抓取器网格中的 x 索引。
		-- @param y (integer) 顶点在抓取器网格中的 y 索引。
		-- @param color (Color) 顶点的新颜色。
		setColor: function(self: Grabber, x: integer, y: integer, color: Color)

		-- 设置抓取器网格中一个顶点的纹理坐标。
		-- @param x (integer) 顶点在抓取器网格中的 x 索引。
		-- @param y (integer) 顶点在抓取器网格中的 y 索引。
		-- @param offset (Vec2) 顶点的新纹理坐标。
		moveUV: function(self: Grabber, x: integer, y: integer, offset: Vec2)
	end

	-- 创建或移除节点上的纹理抓取器。
	-- @param enabled (boolean) [可选] 是否启用或禁用抓取器。默认为 true。
	-- @return (Grabber) 启用时会返回一个抓取器对象（gridX 和 gridY 均为 1）。
	grab: function(
		self: Node,
		enabled?: boolean --[[true]]
	): Grabber

	-- 创建一个指定网格大小的纹理抓取器。
	-- @param gridX (number) 将抓取器分成的水平网格单元数。
	-- @param gridY (number) 将抓取器分成的垂直网格单元数。
	-- @return (Grabber) 返回一个抓取器对象。
	grab: function(self: Node, gridX: number, gridY: number): Grabber

	-- 调度一个函数，该函数会在每一帧运行。可以反复调用以同时调度多个函数。
	-- @param func (function) 要在每一帧运行的函数，返回true以停止。
	-- 	@parem deltaTime (number) 从上一帧到当前帧的时间间隔。
	-- 	@return (boolean) 如果返回true，则停止调度。
	onUpdate: function(self: Node, func: function(number): boolean)

	-- 调度一个协程，该协程会在每一帧运行。可以反复调用以同时调度多个协程。
	-- @param job (Routine.Job) 要在每一帧运行的协程。
	onUpdate: function(self: Node, job: Routine.Job)

	-- 注册节点进入渲染阶段时触发的回调函数。该回调在每一帧都会被调用，并且能确保它的调用顺序与场景树的渲染顺序一致，如使子节点在父节点之后渲染。推荐用于调用矢量绘图的接口。
	-- @param func (function) 渲染时的回调函数。
	-- 	@parem deltaTime (number) 从上一帧到当前帧的时间间隔。
	-- 	@return (boolean) 如果返回true，则停止触发该渲染回调。
	onRender: function(self: Node, func: function(number): boolean)

	-- 注册节点执行完一个动作时触发的回调函数。
	-- @param callback (function) 动作执行完时的回调函数。
	-- 	@param action (Action) 执行完的动作对象。
	-- 	@param target (Node) 执行完动作的节点。
	onActionEnd: function(self: Node, callback: function(action: Action, target: Node))

	-- 注册节点点击事件的过滤器回调函数。
	-- 同时会设置节点的`touchEnabled`属性为 true。
	-- @param callback (function) 点击事件的过滤器回调函数。
	-- 	@param touch (Touch) 点击事件的触摸消息对象。
	onTapFilter: function(self: Node, callback: function(touch: Touch))

	-- 注册节点检测到点击开始时触发的回调函数。
	-- 同时会设置节点的`touchEnabled`属性为 true。
	-- @param callback (function) 点击事件开始的回调函数。
	-- 	@param touch (Touch) 点击事件的触摸消息对象。
	onTapBegan: function(self: Node, callback: function(touch: Touch))

	-- 注册节点点击结束时触发的回调函数。
	-- 同时会设置节点的`touchEnabled`属性为 true。
	-- @param callback (function) 点击事件结束的回调函数。
	-- 	@param touch (Touch) 点击事件的触摸消息对象。
	onTapEnded: function(self: Node, callback: function(touch: Touch))

	-- 注册节点检测到并结束点击时触发的回调函数。
	-- 同时会设置节点的`touchEnabled`属性为 true。
	-- @param callback (function) 点击事件结束的回调函数。
	-- 	@param touch (Touch) 点击事件的触摸消息对象。
	onTapped: function(self: Node, callback: function(touch: Touch))

	-- 注册节点点击移动时触发的回调函数。
	-- 同时会设置节点的`touchEnabled`属性为 true。
	-- @param callback (function) 点击事件移动的回调函数。
	-- 	@param touch (Touch) 点击事件的触摸消息对象。
	onTapMoved: function(self: Node, callback: function(touch: Touch))

	-- 注册节点滚动鼠标滚轮时触发的回调函数。
	-- 同时会设置节点的`touchEnabled`属性为 true。
	-- @param callback (function) 鼠标滚轮滚动的回调函数。
	-- 	@param delta (Vec2) 鼠标滚轮滚动的增量。
	onMouseWheel: function(self: Node, callback: function(delta: Vec2))

	-- 注册节点识别到多点手势时触发的回调函数。
	-- 同时会设置节点的`touchEnabled`属性为 true。
	-- @param callback (function) 多点手势的回调函数。
	-- 	@param center (Vec2) 多点手势的中心点。
	-- 	@param numFingers (integer) 多点手势的手指数量。
	-- 	@param deltaDist (number) 多点手势的距离变化。
	-- 	@param deltaAngle (number) 多点手势的角度变化。
	onGesture: function(self: Node, callback: function(center: Vec2, numFingers: integer, deltaDist: number, deltaAngle: number))

	-- 注册节点进入场景树时触发的回调函数。
	-- @param callback (function) 节点进入场景树时的回调函数。
	onEnter: function(self: Node, callback: function())

	-- 注册节点离开场景树时触发的回调函数。
	-- @param callback (function) 节点离开场景树时的回调函数。
	onExit: function(self: Node, callback: function())

	-- 注册节点清理时触发的回调函数。
	-- @param callback (function) 节点清理时的回调函数。
	onCleanup: function(self: Node, callback: function())

	-- 注册按下键盘按键时触发的回调函数。
	-- 同时会设置节点的`keyboardEnabled`属性为 true。
	-- @param callback (function) 按键按下时的回调函数。
	-- 	@param keyName (Keyboard.KeyName) 按下的键盘按键名称。
	onKeyDown: function(self: Node, callback: function(keyName: Keyboard.KeyName))

	-- 注册释放键盘按键时触发的回调函数。
	-- 同时会设置节点的`keyboardEnabled`属性为 true。
	-- @param callback (function) 按键释放时的回调函数。
	-- 	@param keyName (Keyboard.KeyName) 释放的键盘按键名称。
	onKeyUp: function(self: Node, callback: function(keyName: Keyboard.KeyName))

	-- 注册按键盘按键时触发的回调函数。
	-- 同时会设置节点的`keyboardEnabled`属性为 true。
	-- @param callback (function) 按键按下时的回调函数。
	-- 	@param keyName (Keyboard.KeyName) 按下的键盘按键名称。
	onKeyPressed: function(self: Node, callback: function(keyName: Keyboard.KeyName))

	-- 注册打开操作系统输入法 (IME) 时触发的回调函数。
	-- @param callback (function) 打开输入法时的回调函数。
	onAttachIME: function(self: Node, callback: function())

	-- 注册关闭操作系统输入法 (IME) 时触发的回调函数。
	-- @param callback (function) 关闭输入法时的回调函数。
	onDetachIME: function(self: Node, callback: function())

	-- 注册输入文本时触发的回调函数。
	-- @param callback (function) 输入文本时的回调函数。
	-- 	@param text (string) 输入的文本。
	onTextInput: function(self: Node, callback: function(text: string))

	-- 注册编辑文本时触发的回调函数。
	-- @param callback (function) 编辑文本时的回调函数。
	-- 	@param text (string) 编辑的文本。
	onTextEditing: function(self: Node, callback: function(text: string, startPos: integer))

	-- 注册按下游戏手柄按键时触发的回调函数。
	-- 同时会设置节点的`controllerEnabled`属性为 true。
	-- @param callback (function) 按键按下时的回调函数。
	-- 	@param controllerId (integer) 游戏手柄的 ID。
	-- 	@param buttonName (Controller.ButtonName) 按下的游戏手柄按键名称。
	onButtonDown: function(self: Node, callback: function(controllerId: integer, buttonName: Controller.ButtonName))

	-- 注册释放游戏手柄按键时触发的回调函数。
	-- 同时会设置节点的`controllerEnabled`属性为 true。
	-- @param callback (function) 按键释放时的回调函数。
	-- 	@param controllerId (integer) 游戏手柄的 ID。
	-- 	@param buttonName (Controller.ButtonName) 释放的游戏手柄按键名称。
	onButtonUp: function(self: Node, callback: function(controllerId: integer, buttonName: Controller.ButtonName))

	-- 注册按住游戏手柄按键时触发的回调函数。
	-- 同时会设置节点的`controllerEnabled`属性为 true。
	-- @param callback (function) 按键按住时的回调函数。
	-- 	@param controllerId (integer) 游戏手柄的 ID。
	-- 	@param buttonName (Controller.ButtonName) 按住的游戏手柄按键名称。
	onButtonPressed: function(self: Node, callback: function(controllerId: integer, buttonName: Controller.ButtonName))

	-- 注册游戏控制器轴发生变化时触发的回调函数。
	-- 同时会设置节点的`controllerEnabled`属性为 true。
	-- @param callback (function) 控制器轴变化时的回调函数。
	-- 	@param controllerId (integer) 游戏手柄的 ID。
	-- 	@param axisName (Controller.AxisName) 变化的轴名称。
	-- 	@param value (number) 轴的新值。
	onAxis: function(self: Node, callback: function(controllerId: integer, axisName: Controller.AxisName, value: number))

	-- 应用程序事件的枚举。
	enum AppEventType

		-- 应用程序即将退出。
		"Quit"

		-- 应用程序收到低内存警告。
		"LowMemory"

		-- 应用程序即将进入后台。
		"WillEnterBackground"

		-- 应用程序已进入后台。
		"DidEnterBackground"

		-- 应用程序即将进入前台。
		"WillEnterForeground"

		-- 应用程序已进入前台。
		"DidEnterForeground"
	end

	-- 注册应用程序事件发生时触发的回调函数。
	-- @param callback (function) 要注册的回调函数。
	-- 	@param eventType (AppEventType) 发生的应用程序事件类型。
	onAppEvent: function(self: Node, callback: function(eventType: AppEventType))

	-- 应用程序设置的枚举。
	enum AppSettingName

		-- 应用程序的区域设置。
		"Locale"

		-- 应用程序的主题颜色。
		"Theme"

		-- 应用程序窗口的全屏状态。
		"FullScreen"

		-- 应用程序窗口的位置。
		"Position"

		-- 应用程序窗口的大小。
		"Size"
	end

	-- 注册应用程序设置更改时触发的回调函数。
	-- @param callback (function) 要注册的回调函数。
	-- 	@param settingName (AppSettingName) 更改的应用程序设置名称。
	onAppChange: function(self: Node, callback: function(settingName: AppSettingName))

	-- 应用程序 WebSocket 事件的枚举。
	enum AppWSEvent

		-- WebSocket 连接已打开。
		"Open"

		-- WebSocket 连接已关闭。
		"Close"

		-- WebSocket 接收到消息。
		"Send"

		-- WebSocket 广播消息。
		"Receive"
	end

	-- 注册应用程序 WebSocket 事件发生时触发的回调函数。
	-- @param callback (function) 要注册的回调函数。
	-- 	@param event (AppWSEvent) 发生的 WebSocket 事件类型。
	-- 	@param message (string) 接收到或发送的消息。
	onAppWS: function(self: Node, callback: function(event: AppWSEvent, message: string))
end

-- 节点可监听的事件的定义。
-- 这只是一个演示记录，展示了信号插槽的名称和回调。
-- @usage
-- -- 可以使用如下示例代码注册监听这些事件：
-- node:slot("ActionEnd", function(action: Action, target: Node)
-- 	print("Action end", action, target)
-- end)
local record __SLOT__

	-- ActionEnd事件会在节点执行完一个动作时触发。
	-- 在`node:runAction()`和`node:perform()`之后触发。
	-- @param action (Action) 执行完成的动作。
	-- @param target (Node) 执行完成动作的节点。
	["ActionEnd"]: function(action: Action, target: Node)

	-- TapFilter事件在TapBegan插槽之前触发，可用于过滤某些点击事件。
	-- 在设置`node.touchEnabled = true`之后才会触发。
	-- @param touch (Touch) 点击事件的消息对象。
	["TapFilter"]: function(touch: Touch)

	-- TapBegan事件在检测到点击时触发。
	-- 在设置`node.touchEnabled = true`之后才会触发。
	-- @param touch (Touch) 点击事件的消息对象。
	["TapBegan"]: function(touch: Touch)

	-- TapEnded事件在点击结束时触发。
	-- 在设置`node.touchEnabled = true`之后才会触发。
	-- @param touch (Touch) 点击事件的消息对象。
	["TapEnded"]: function(touch: Touch)

	-- Tapped事件在检测到并结束点击时触发。
	-- 在设置`node.touchEnabled = true`之后才会触发。
	-- @param touch (Touch) 点击事件的消息对象。
	["Tapped"]: function(touch: Touch)

	-- TapMoved事件在点击移动时触发。
	-- 在设置`node.touchEnabled = true`之后才会触发。
	-- @param touch (Touch) 点击事件的消息对象。
	["TapMoved"]: function(touch: Touch)

	-- MouseWheel事件在滚动鼠标滚轮时触发。
	-- 在设置`node.touchEnabled = true`之后才会触发。
	-- @param delta (Vec2) 滚动的向量。
	["MouseWheel"]: function(delta: Vec2)

	-- Gesture事件在识别到多点手势时触发。
	-- 在设置`node.touchEnabled = true`之后才会触发。
	-- @param center (Vec2) 手势的中心点。
	-- @param numFingers (integer) 手势涉及的触摸点数量。
	-- @param deltaDist (number) 手势移动的距离。
	-- @param deltaAngle (number) 手势的变动角度。
	["Gesture"]: function(center: Vec2, numFingers: integer, deltaDist: number, deltaAngle: number)

	-- 当节点被添加到场景树中时，触发Enter事件。
	-- 当执行`node:addChild()`时触发。
	["Enter"]: function()

	-- 当节点从场景树中移除时，触发Exit事件。
	-- 当执行`node:removeChild()`时触发。
	["Exit"]: function()

	-- 当节点被清理时，触发Cleanup事件。
	-- 仅当执行`parent:removeChild(node, true)`时触发。
	["Cleanup"]: function()

	-- 当按下某个键盘按键时，触发KeyDown事件。
	-- 在设置`node.keyboardEnabled = true`后才会触发。
	-- @param keyName (string) 被按下的键的名称。
	["KeyDown"]: function(keyName: Keyboard.KeyName)

	-- 当释放某个键盘按键时，触发KeyUp事件。
	-- 在设置`node.keyboardEnabled = true`后才会触发。
	-- @param keyName (string) 被释放的键的名称。
	["KeyUp"]: function(keyName: Keyboard.KeyName)

	-- 当持续按下某个键时，触发KeyPressed事件。
	-- 在设置`node.keyboardEnabled = true`后才会触发。
	-- @param keyName (string) 被持续按下的键的名称。
	["KeyPressed"]: function(keyName: Keyboard.KeyName)

	-- 当系统输入法（IME）开启到节点（调用`node: attachIME()`）时，会触发AttachIME事件。
	["AttachIME"]: function()

	-- 当系统输入法（IME）关闭（调用`node: detachIME()`或手动关闭IME）时，会触发DetachIME事件。
	["DetachIME"]: function()

	-- 当接收到系统输入法文本输入时，会触发TextInput事件。
	-- 在调用`node:attachIME()`之后触发。
	-- @param text (string) 输入的文本。
	["TextInput"]: function(text: string)

	-- 当系统输入法文本正在被编辑时，会触发TextEditing事件。
	-- 在调用`node:attachIME()`之后触发。
	-- @param text (string) 正在编辑的文本。
	-- @param startPos (integer) 正在编辑的文本的起始位置。
	["TextEditing"]: function(text: string, startPos: integer)

	-- 当游戏控制器按钮被按下时触发ButtonDown事件。
	-- 在设置`node.controllerEnabled = true`之后触发。
	-- @param controllerId (integer) 控制器ID，当有多个控制器连接时从0开始递增。
	-- @param buttonName (Keyboard.KeyName) 被按下的按钮名称。
	["ButtonDown"]: function(controllerId: integer, buttonName: Controller.ButtonName)

	-- 当游戏控制器按钮被释放时触发ButtonUp事件。
	-- 在设置`node.controllerEnabled = true`之后触发。
	-- @param controllerId (integer) 控制器ID，当有多个控制器连接时从0开始递增。
	-- @param buttonName (Keyboard.KeyName) 被释放的按钮名称。
	["ButtonUp"]: function(controllerId: integer, buttonName: Controller.ButtonName)

	-- 当游戏控制器按钮被持续按下时触发ButtonPressed事件。
	-- 在设置`node.controllerEnabled = true`之后触发。
	-- @param controllerId (integer) 控制器ID，当有多个控制器连接时从0开始递增。
	-- @param buttonName (Keyboard.KeyName) 被按下的按钮名称。
	["ButtonPressed"]: function(controllerId: integer, buttonName: Controller.ButtonName)

	-- 当游戏控制器轴发生变化时触发Axis事件。
	-- 在设置`node.controllerEnabled = true`之后触发。
	-- @param controllerId (integer) 控制器ID，当有多个控制器连接时从0开始递增。
	-- @param axisValue (number) 控制器轴的值，范围从 -1.0 到 1.0。
	["Axis"]: function(controllerId: integer, axisValue: number)
end

-- 用于创建场景节点实例的类。
local record NodeClass
	type Type = Node
	type AppEventType = Node.AppEventType
	type AppSettingName = Node.AppSettingName
	type AppWSEvent = Node.AppWSEvent

	-- 创建一个新的场景节点实例。
	-- @usage
	-- local Node = require("Node")
	-- local node = Node()
	-- @return (Node) 场景节点的新实例。
	metamethod __call: function(self: NodeClass): Node
end

local nodeClass: NodeClass
return nodeClass
