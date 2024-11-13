local type Keyboard = require("Keyboard")
local type Controller = require("Controller")
local type Node = require("Node")

local type KeyName = Keyboard.KeyName;
local type ButtonName = Controller.ButtonName;
local type AxisName = Controller.AxisName;

-- `InputManager` 是一个用于管理输入上下文和动作的类。可以通过创建输入上下文和动作，然后将它们添加到输入管理器中，来实现输入事件的监听和处理。可以通过调用 `pushContext` 和 `popContext` 方法来激活和停用特定组合的输入上下文。在触发事件时，可以通过注册全局输入事件监听器来处理输入事件。
-- @usage
-- local InputManager = require("InputManager")
-- local inputManager = InputManager.CreateManager({
-- 	context1 = {
-- 		action1 = Trigger.KeyDown("W"),
-- 	},
-- })
-- -- 激活上下文 context1
-- inputManager:pushContext("context1")
-- -- 要监听的输入事件名需要加上 `Input.` 前缀
-- node:gslot("Input.action1", function()
-- 	print("action1 triggered")
-- end)
-- -- 从上下文栈中删除 context1
-- inputManager:popContext()
-- -- 销毁输入管理器
-- inputManager:destroy()
local record InputManager

	-- 获取当前输入系统使用的场景节点。该节点用于接收输入事件。它在创建后，如果没有被添加到指定的父节点，会在稍后被自动添加到 `Director.entry` 中。
	-- @return (Node) 输入系统的场景节点。
	getNode: function(self: InputManager): Node.Type

	-- 将指定名称的上下文添加到上下文栈中。会暂时禁用之前生效的上下文，然后激活新上下文中会触发的动作和事件。
	-- @param contextNames (string | {string}) 单个上下文的名称或是上下文名称的数组。
	-- @return (boolean) 上下文是否成功添加和生效。
	pushContext: function(self: InputManager, contextNames: string | {string}): boolean

	-- 从上下文栈中移除并停止当前栈顶在生效的上下文。然后激活前一组上下文。
	-- @param count (number) [可选] 要移除的上下文数量。默认为1。
	-- @return (boolean) 栈顶上下文是否成功移除。
	popContext: function(self: InputManager, count?: number): boolean

	-- 发送按键按下事件到输入系统以模拟输入。
	-- @param keyName (KeyName) 键的名称。
	emitKeyDown: function(self: InputManager, keyName: KeyName)

	-- 发送按键释放事件到输入系统以模拟输入。
	-- @param keyName (KeyName) 键的名称。
	emitKeyUp: function(self: InputManager, keyName: KeyName)

	-- 发送按键按住事件到输入系统以模拟输入。
	-- @param buttonName (ButtonName) 按钮的名称。
	-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
	emitButtonDown: function(self: InputManager, buttonName: ButtonName, controllerId?: number)

	-- 发送按键释放事件到输入系统以模拟输入。
	-- @param buttonName (ButtonName) 按钮的名称。
	-- @param controllerId (number) [optional] 游戏手柄控制器的ID。默认为0。
	emitButtonUp: function(self: InputManager, buttonName: ButtonName, controllerId?: number)

	-- 发送摇杆变动的事件到输入系统以模拟输入。
	-- @param axisName (AxisName) 轴的名称。
	-- @param value (number) 轴的值，取值范围为-1到1。
	-- @param controllerId (number) [optional] 游戏手柄控制器的ID。默认为0。
	emitAxis: function(self: InputManager, axisName: AxisName, value: number, controllerId?: number)

	-- 销毁输入管理器并清除在生效的输入事件监听器。
	destroy: function(self: InputManager)
end

-- 输入管理器模块类。
local record InputManagerClass

	-- 摇杆类型的枚举。
	enum JoyStickType
		"Left"
		"Right"
	end

	-- 输入触发器的管理类，定义了键盘键、游戏手柄按钮和摇杆的各种输入触发器。
	record Trigger

		-- 创建一个触发器，当所有指定的键被按下时触发。
		-- @param combineKeys (KeyName | {KeyName}) 要检查的单个键或组合键。
		-- @return (Trigger) 触发器对象。
		KeyDown: function(combineKeys: KeyName | {KeyName}): Trigger

		-- 创建一个触发器，当所有指定的键被按下并且其中任何一个被释放时触发。
		-- @param combineKeys (KeyName | {KeyName}) 要检查的单个键或组合键。
		-- @return (Trigger) 触发器对象。
		KeyUp: function(combineKeys: KeyName | {KeyName}): Trigger

		-- 创建一个触发器，当所有指定的键正在被按下时触发。
		-- @param combineKeys (KeyName | {KeyName}) 要检查的单个键或组合键。
		-- @return (Trigger) 触发器对象。
		KeyPressed: function(combineKeys: KeyName | {KeyName}): Trigger

		-- 创建一个触发器，当特定键被按下并且保持按下指定的持续时间时触发。
		-- @param keyName (KeyName) 要检查的键。
		-- @param holdTime (number) 持续时间，以秒为单位。
		-- @return (Trigger) 触发器对象。
		KeyHold: function(keyName: KeyName, holdTime: number): Trigger

		-- 创建一个触发器，当特定键在指定的时间窗口内被按下时触发。
		-- @param keyName (KeyName) 要检查的键。
		-- @param timeWindow (number) 时间窗口，以秒为单位。
		-- @return (Trigger) 触发器对象。
		KeyTimed: function(keyName: KeyName, timeWindow: number): Trigger

		-- 创建一个触发器，当特定键被双击时触发。
		-- @param key (KeyName) 要检查的键。
		-- @param threshold (number) [可选] 双击的时间阈值，以秒为单位。默认为0.3。
		-- @return (Trigger) 触发器对象。
		KeyDoubleDown: function(key: KeyName, threshold?: number): Trigger

		-- 创建一个触发器，当任何键被持续按下时触发。
		-- @return (Trigger) 触发器对象。
		AnyKeyPressed: function(): Trigger

		-- 创建一个触发器，当所有指定的游戏手柄按钮被按下时触发。
		-- @param combineButtons (ButtonName | {ButtonName}) 要检查的游戏手柄按钮或组合按钮。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		ButtonDown: function(combineButtons: ButtonName | {ButtonName}, controllerId?: number): Trigger

		-- 创建一个触发器，当所有指定的游戏手柄按钮被按下并且其中任何一个被释放时触发。
		-- @param combineButtons (ButtonName | {ButtonName}) 要检查的游戏手柄按钮或组合按钮。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		ButtonUp: function(combineButtons: ButtonName | {ButtonName}, controllerId?: number): Trigger

		-- 创建一个触发器，当所有指定的游戏手柄按钮正在被按下时触发。
		-- @param combineButtons (ButtonName | {ButtonName}) 要检查的游戏手柄按钮或组合按钮。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		ButtonPressed: function(combineButtons: ButtonName | {ButtonName}, controllerId?: number): Trigger

		-- 创建一个触发器，当特定的游戏手柄按钮被按下并且保持按下指定的持续时间后触发。
		-- @param buttonName (ButtonName) 要检查的游戏手柄按钮。
		-- @param holdTime (number) 持续时间，以秒为单位。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		ButtonHold: function(buttonName: ButtonName, holdTime: number, controllerId?: number): Trigger

		-- 创建一个触发器，当特定的游戏手柄按钮在指定的时间窗口内被按下时触发。
		-- @param buttonName (ButtonName) 要检查的游戏手柄按钮。
		-- @param timeWindow (number) 时间窗口，以秒为单位。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		ButtonTimed: function(buttonName: ButtonName, timeWindow: number, controllerId?: number): Trigger

		-- 创建一个触发器，当特定的游戏手柄按钮被双击时触发。
		-- @param button (ButtonName) 要检查的游戏手柄按钮。
		-- @param threshold (number) [可选] 双击的时间阈值，以秒为单位。默认为0.3。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		ButtonDoubleDown: function(button: ButtonName, threshold?: number, controllerId?: number): Trigger

		-- 创建一个触发器，当任何游戏手柄按钮被持续按下时触发。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		AnyButtonPressed: function(controllerId?: number): Trigger

		-- 创建一个触发器，当特定的游戏手柄轴被移动时触发。
		-- @param joyStickType (JoyStickType) 要检查的操纵杆类型。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		JoyStick: function(joyStickType: JoyStickType, controllerId?: number): Trigger

		-- 创建一个触发器，当操纵杆移动超过指定阈值时触发。
		-- @param joyStickType (JoyStickType) 要检查的操纵杆类型。
		-- @param threshold (number) 阈值，取值范围为0到1。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		JoyStickThreshold: function(joyStickType: JoyStickType, threshold: number, controllerId?: number): Trigger

		-- 创建一个触发器，当操纵杆在容忍的偏差角度内朝特定方向移动时触发。
		-- @param joyStickType (JoyStickType) 要检查的操纵杆类型。
		-- @param angle (number) 方向的角度，以度为单位。
		-- @param tolerance (number) 容忍角度，以度为单位。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		JoyStickDirectional: function(joyStickType: JoyStickType, angle: number, tolerance: number, controllerId?: number): Trigger

		-- 创建一个触发器，当操纵杆在指定范围内时触发。
		-- @param joyStickType (JoyStickType) 要检查的操纵杆类型。
		-- @param minRange (number) 最小范围值，取值范围为0到1。
		-- @param maxRange (number) 最大范围值，取值范围为0到1。
		-- @param controllerId (number) [可选] 游戏手柄控制器的ID。默认为0。
		-- @return (Trigger) 触发器对象。
		JoyStickRange: function(joyStickType: JoyStickType, minRange: number, maxRange: number, controllerId?: number): Trigger

		-- 创建一个触发器，当一组其他触发器同时进入完成状态时触发。
		-- @param triggers ({Trigger}) 要检查的触发器。
		-- @return (Trigger) 触发器对象。
		Sequence: function(triggers: {Trigger}): Trigger

		-- 创建一个触发器，当一组其他触发器中的任何一个进入完成状态时触发。
		-- @param triggers ({Trigger}) 要检查的触发器。
		-- @return (Trigger) 触发器对象。
		Selector: function(triggers: {Trigger}): Trigger

		-- 当子触发器处于完成状态时，它将反过来报告为取消状态，用于阻塞触发器的事件。
		-- @param trigger (Trigger) 要被阻塞的触发器。
		-- @return (Trigger) 触发器对象。
		Block: function(trigger: Trigger): Trigger
	end

	-- 触发器状态的枚举。
	enum TriggerState

		-- 无状态：当前暂未获得输入状态。
		"None"

		-- 已开始：发生了开始触发器求值的某个事件。例如，"按住"触发器的第一次按键将调用一次"已开始"状态。
		"Started"

		-- 进行中：触发器仍在进行处理。例如，当用户按下按钮时，在达到指定持续时间之前，"按住"动作处于进行中状态。根据触发器，此事件将在收到输入值之后在对动作求值时，每次更新触发一次。
		"Ongoing"

		-- 已完成：触发器求值过程已完成。
		"Completed"

		-- 已取消：触发已取消。例如，在"按住"动作还没触发之前，用户就松开了按钮。
		"Canceled"
	end

	-- 使用指定的输入上下文创建输入管理器。
	-- @param contexts ({string: {string: Trigger}) 要创建的一组输入上下文。
	-- @return (InputManager) 输入管理器。
	CreateManager: function(contexts: {--[[contextName]] string: {--[[actionName]] string: Trigger}}): InputManager

	-- 虚拟方向键（D-pad）的属性。
	record DPadProps

		-- D-pad的按钮宽度。[可选]
		width: number

		-- D-pad的按钮高度。[可选]
		height: number

		-- D-pad的按钮间距。[可选]
		offset: number

		-- D-pad的输入管理器。[必需]
		inputManager: InputManager
	end

	-- 创建一个虚拟方向键（D-pad）的UI节点。
	-- @param props (DPadProps) D-pad的属性。
	-- @return (Node) D-pad节点。
	CreateDPad: function(props: DPadProps): Node.Type

	-- 虚拟操纵杆UI的属性。
	record JoyStickProps

		-- 操纵杆的类型。[必需]
		stickType: JoyStickType

		-- 操纵杆的移动大小。[可选]
		moveSize: number

		-- 帽子的大小。[可选]
		hatSize: number

		-- 操纵杆的字体名称。[可选]
		fontName: string

		-- 操纵杆按钮的大小。[可选]
		buttonSize: number

		-- 操纵杆的输入管理器。[必需]
		inputManager: InputManager

		-- 操纵杆的颜色。[可选]
		color: number

		-- 操纵杆的主要透明度。[可选]
		primaryOpacity: number

		-- 操纵杆的次要透明度。[可选]
		secondaryOpacity: number

		-- 是否隐藏操纵杆按钮。[可选]
		noStickButton: boolean
	end

	-- 创建一个虚拟摇杆的UI节点（L、LS 或是 R、RS）。
	-- @param props (JoyStickProps) 操纵杆的属性。
	-- @return (Node) 操纵杆节点。
	CreateJoyStick: function(props: JoyStickProps): Node.Type

	-- 虚拟按钮盘UI的属性。
	record ButtonPadProps

		-- 按钮的大小。[可选]
		buttonSize: number

		-- 按钮的间距。[可选]
		buttonPadding: number

		-- 按钮盘的字体名称。[可选]
		fontName: string

		-- 按钮盘的输入管理器。[必需]
		inputManager: InputManager
	end

	-- 创建一个虚拟按钮盘的UI节点（A、B、X、Y）。
	-- @param props (ButtonPadProps) 按钮盘的属性。
	-- @return (Node) 按钮盘节点。
	CreateButtonPad: function(props: ButtonPadProps): Node.Type

	-- 虚拟肩部按钮UI的属性。
	record ControlPadProps

		-- 按钮的大小。[可选]
		buttonSize: number

		-- 按钮盘的字体名称。[可选]
		fontName: string

		-- 按钮盘的输入管理器。[必需]
		inputManager: InputManager

		-- 按钮盘的颜色。[可选]
		color: number

		-- 按钮盘的主要透明度。[可选]
		primaryOpacity: number
	end

	-- 创建一个虚拟控制盘（开始和返回按钮）的UI节点。
	-- @param props (ControlPadProps) 控制盘的属性。
	-- @return (Node) 控制盘节点。
	CreateControlPad: function(props: ControlPadProps): Node.Type

	-- 虚拟触发器按钮UI的属性。
	record TriggerPadProps

		-- 按钮的大小。[可选]
		buttonSize: number

		-- 按钮盘的字体名称。[可选]
		fontName: string

		-- 按钮盘的输入管理器。[必需]
		inputManager: InputManager

		-- 按钮盘的颜色。[可选]
		color: number

		-- 按钮盘的主要透明度。[可选]
		primaryOpacity: number

		-- 是否隐藏肩部按钮。[可选]
		noShoulder: boolean
	end

	-- 创建一个虚拟触发器盘的UI节点（LB、LT、RB、RT）。
	-- @param props (TriggerPadProps) 触发器盘的属性。
	-- @return (Node) 触发器盘节点。
	CreateTriggerPad: function(props: TriggerPadProps): Node.Type

	-- 虚拟游戏手柄UI的属性。
	record GamePadProps

		-- 是否隐藏方向键盘（D-pad）。[可选]
		noDPad: boolean

		-- 是否隐藏左摇杆（L、LS）。[可选]
		noLeftStick: boolean

		-- 是否隐藏右摇杆（R、RS）。[可选]
		noRightStick: boolean

		-- 是否隐藏按钮盘（A、B、X、Y）。[可选]
		noButtonPad: boolean

		-- 是否隐藏触发器盘（LB、LT、RB、RT）。[可选]
		noTriggerPad: boolean

		-- 是否隐藏控制盘（开始和返回按钮）。[可选]
		noControlPad: boolean

		-- 是否隐藏肩部按钮（LB、RB）。[可选]
		noShoulder: boolean

		-- 是否隐藏摇杆按钮（LS、RS）。[可选]
		noStickButton: boolean

		-- 游戏手柄的颜色。[可选]
		color: number

		-- 游戏手柄的主要透明度。[可选]
		primaryOpacity: number

		-- 游戏手柄的次要透明度。[可选]
		secondaryOpacity: number

		-- 游戏手柄的输入管理器。[必需]
		inputManager: InputManager
	end

	-- 创建一个虚拟游戏手柄的UI节点。
	-- @param props (GamePadProps) 游戏手柄的属性。
	-- @return (Node) 游戏手柄节点。
	CreateGamePad: function(props: GamePadProps): Node.Type
end

local inputManagerClass: InputManagerClass
return inputManagerClass
