-- 用于处理游戏控制器（游戏手柄）的单例类。
local record Controller
	userdata

	-- 用于定义控制器轴名称的枚举。
	enum AxisName
		"leftx"
		"lefty"
		"rightx"
		"righty"
		"lefttrigger"
		"righttrigger"
	end

	-- 用于定义控制器按钮名称的枚举。
	enum ButtonName
		"a"
		"b"
		"back"
		"dpdown"
		"dpleft"
		"dpright"
		"dpup"
		"leftshoulder"
		"leftstick"
		"rightshoulder"
		"rightstick"
		"start"
		"x"
		"y"
	end

	-- 检查当前帧是否按下了按钮。
	-- @param controllerId (integer) 控制器ID，当连接多个控制器时从0开始递增。
	-- @param name (ButtonName) 要检查的按钮名称。
	-- @return (boolean) 按钮是否被按下。
	isButtonDown: function(self: Controller, controllerId: integer, name: ButtonName): boolean

	-- 检查当前帧是否释放了按钮。
	-- @param controllerId (integer) 控制器ID，当连接多个控制器时从0开始递增。
	-- @param name (ButtonName) 要检查的按钮名称。
	-- @return (boolean) 按钮是否被释放。
	isButtonUp: function(self: Controller, controllerId: integer, name: ButtonName): boolean

	-- 检查按钮是否处于按下状态。
	-- @param controllerId (integer) 控制器ID，当连接多个控制器时从0开始递增。
	-- @param name (ButtonName) 要检查的按钮名称。
	-- @return (boolean) 按钮是否处于按下状态。
	isButtonPressed: function(self: Controller, controllerId: integer, name: ButtonName): boolean

	-- 从给定控制器获取轴的值。
	-- @param controllerId (integer) 控制器ID，当连接多个控制器时从0开始递增。
	-- @param name (AxisName) 要检查的控制器轴的名称。
	-- @return (number) 轴的值范围从-1.0到1.0。
	getAxis: function(self: Controller, controllerId: integer, name: AxisName): number
end

local controller: Controller
return controller
