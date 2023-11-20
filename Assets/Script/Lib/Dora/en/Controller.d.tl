-- An interface for handling game controller inputs.
local record Controller
	userdata

	-- Enumeration for defining the controller axis names.
	enum AxisName
		"leftx"
		"lefty"
		"rightx"
		"righty"
		"lefttrigger"
		"righttrigger"
	end

	-- Enumeration for defining the controller button names.
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

	-- Check whether a button is pressed down in current frame.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param name (ButtonName) The name of the button to check.
	-- @return (boolean) Whether the button is pressed down.
	isButtonDown: function(self: Controller, controllerId: integer, name: ButtonName): boolean

	-- Check whether a button is released in current frame.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param name (ButtonName) The name of the button to check.
	-- @return (boolean) Whether the button is released.
	isButtonUp: function(self: Controller, controllerId: integer, name: ButtonName): boolean

	-- Check whether a button is in pressed state.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param name (ButtonName) The name of the button to check.
	-- @return (boolean) Whether the button is in pressed state.
	isButtonPressed: function(self: Controller, controllerId: integer, name: ButtonName): boolean

	-- Get the axis value from a given controller.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param name (AxisName) The name of the controller axis to check.
	-- @return (number) The axis value ranging from -1.0 to 1.0.
	getAxis: function(self: Controller, controllerId: integer, name: AxisName): number
end

local controller: Controller
return controller
