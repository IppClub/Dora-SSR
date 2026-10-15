local Vec2 = require("Vec2").Type

-- 用于处理键盘事件的接口类。
local record Keyboard
	userdata

	-- 键盘按键名称的枚举。
	enum KeyName
		"Return"
		"Escape"
		"BackSpace"
		"Tab"
		"Space"
		"!"
		"\""
		"#"
		"%"
		"$"
		"&"
		"'"
		"("
		")"
		"*"
		"+"
		","
		"-"
		"."
		"/"
		"1"
		"2"
		"3"
		"4"
		"5"
		"6"
		"7"
		"8"
		"9"
		"0"
		":"
		";"
		"<"
		"="
		">"
		"?"
		"@"
		"["
		"\\"
		"]"
		"^"
		"_"
		"`"
		"A"
		"B"
		"C"
		"D"
		"E"
		"F"
		"G"
		"H"
		"I"
		"J"
		"K"
		"L"
		"M"
		"N"
		"O"
		"P"
		"Q"
		"R"
		"S"
		"T"
		"U"
		"V"
		"W"
		"X"
		"Y"
		"Z"
		"Delete"
		"CapsLock"
		"F1"
		"F2"
		"F3"
		"F4"
		"F5"
		"F6"
		"F7"
		"F8"
		"F9"
		"F10"
		"F11"
		"F12"
		"PrintScreen"
		"ScrollLock"
		"Pause"
		"Insert"
		"Home"
		"PageUp"
		"Delete"
		"End"
		"PageDown"
		"Right"
		"Left"
		"Down"
		"Up"
		"Application"
		"LCtrl"
		"LShift"
		"LAlt"
		"LGui"
		"RCtrl"
		"RShift"
		"RAlt"
		"RGui"
	end

	-- 检查当前帧中是否按下了某个键。
	-- @param name (KeyName) 要检查的键的名称。
	-- @return (boolean) 按键是否按下。
	isKeyDown: function(self: Keyboard, name: KeyName): boolean

	-- 检查当前帧中是否释放了某个键。
	-- @param name (KeyName) 要检查的键的名称。
	-- @return (boolean) 按键是否已释放。
	isKeyUp: function(self: Keyboard, name: KeyName): boolean

	-- 检查某个键是否处于按下状态。
	-- @param name (KeyName) 要检查的键的名称。
	-- @return (boolean) 按键是否处于按下状态。
	isKeyPressed: function(self: Keyboard, name: KeyName): boolean

	-- 更新系统输入法（IME）弹出的位置提示。
	-- @param winPos (Vec2) 弹出输入法窗口的位置。
	updateIMEPosHint: function(self: Keyboard, winPos: Vec2)
end

local keyboard: Keyboard
return keyboard
