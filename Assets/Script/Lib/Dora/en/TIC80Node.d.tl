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

	-- The constructor function for creating a TIC80Node instance with code from a file and resources from a cart file.
	-- @param resourceCartFile (string) The path to the TIC-80 cart file containing art and audio resources (`.tic` or `.png` format).
	-- @param codeFile (string) The path to the code file (e.g., `.lua`, `.yue`).
	-- @return (TIC80Node | nil) The created TIC80Node instance. If creation fails, returns nil.
	metamethod __call: function(
		self: TIC80NodeClass,
		resourceCartFile: string,
		codeFile: string
	): TIC80Node | nil

	-- Extracts code text from a TIC-80 cart file.
	-- @param cartFile (string) The path to the TIC-80 cart file (`.tic` or `.png` format).
	-- @return (string) The extracted code text, or empty string if failed.
	codeFromCart: function(self: TIC80NodeClass, cartFile: string): string

	-- Merges resource cart and code file into a .tic cart file.
	-- @param outputFile (string) The path to save the merged .tic cart file.
	-- @param resourceCartFile (string) The path to the resource cart file.
	-- @param codeFile (string) The path to the code file.
	-- @return (boolean) True if successful, false otherwise.
	mergeTic: function(self: TIC80NodeClass, outputFile: string, resourceCartFile: string, codeFile: string): boolean

	-- Merges PNG cover, resource cart, and optional code file into a .png cart file.
	-- @param outputFile (string) The path to save the merged .png cart file.
	-- @param coverPngFile (string) The path to the cover PNG image file.
	-- @param resourceCartFile (string) The path to the resource cart file.
	-- @param codeFile (string) [optional] Path to the code file. If empty, uses code from resource cart.
	-- @return (boolean) True if successful, false otherwise.
	mergePng: function(self: TIC80NodeClass, outputFile: string, coverPngFile: string, resourceCartFile: string, codeFile?: string): boolean
end

local tic80NodeClass: TIC80NodeClass
return tic80NodeClass
