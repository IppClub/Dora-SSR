local Sprite = require("Sprite").Type

-- A class that represents a TIC-80 virtual machine node.
local record TIC80Node

	-- Inherits from `Sprite`.
	embed Sprite
end

-- A class for creating TIC80Node objects.
local record TIC80NodeClass
	type Type = TIC80Node

	-- The constructor function for creating a TIC80Node instance.
	-- @param cartFile (string) The path to the TIC-80 cart file. It should be a valid TIC-80 cart file (`.tic` or `.png` format).
	--     The TIC-80 cart file contains the complete game or program that will run in the TIC-80 virtual machine.
	--     Supported features:
	--     - Full TIC-80 API support (drawing, sound, input, etc.).
	--     - Keyboard, controller, and touch input handling.
	--     - Audio playback through the TIC-80 sound engine.
	--     - Runs at TIC-80's native resolution (240x136 pixels).
	--     - Fixed frame rate matching TIC-80's specification (60 FPS).
	-- @return (TIC80Node | nil) The created TIC80Node instance. If creation fails, returns nil.
	metamethod __call: function(
		self: TIC80NodeClass,
		cartFile: string
	): TIC80Node | nil
end

local tic80NodeClass: TIC80NodeClass
return tic80NodeClass
