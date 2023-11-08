local Vec2 = require("Vec2").Type

-- An interface for handling keyboard inputs.
local record Keyboard
	userdata

	-- Enumeration for defining the keys.
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

	-- Check whether a key is pressed down in current frame.
	-- @param name (KeyName) The name of the key to check.
	-- @return (boolean) Whether the key is pressed down.
	isKeyDown: function(self: Keyboard, name: KeyName): boolean

	-- Check whether a key is released in current frame.
	-- @param name (KeyName) The name of the key to check.
	-- @return (boolean) Whether the key is released.
	isKeyUp: function(self: Keyboard, name: KeyName): boolean

	-- Check whether a key is in pressed state.
	-- @param name (KeyName) The name of the key to check.
	-- @return (boolean) Whether the key is in pressed state.
	isKeyPressed: function(self: Keyboard, name: KeyName): boolean

	-- Update the input method editor (IME) position hint.
	-- @param winPos (Vec2) The position of the keyboard window.
	updateIMEPosHint: function(self: Keyboard, winPos: Vec2)
end

local keyboard: Keyboard
return keyboard
