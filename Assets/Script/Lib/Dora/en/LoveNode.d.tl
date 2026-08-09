local Sprite = require("Sprite").Type

-- A Dora scene node that owns and runs one isolated Love Lua state.
local record LoveNode
	-- Inherits from `Sprite`.
	embed Sprite

	-- The boot file or package path used to create this LoveNode.
	bootFile: string

	-- The root directory used to resolve this LoveNode's project files.
	sourceRoot: string

	-- The most recent error reported while loading or running the Love project. An empty string means no error has been reported.
	lastError: string

	-- Whether this LoveNode currently owns a running Love Lua state.
	running: boolean

	-- Destroys the old Love state, reloads the boot file, and starts a new state.
	-- @return (boolean) Whether the Love project was restarted successfully.
	restart: function(self: LoveNode): boolean
end

-- A class for creating LoveNode objects.
local record LoveNodeClass
	type Type = LoveNode

	-- Creates a LoveNode from a boot Lua file, `.love` package, or ZIP package. An extensionless relative path also resolves to the corresponding `.love`, `.zip`, or `main.lua` project entry.
	-- @param bootFile (string) The Dora Content path to a boot Lua file, `.love` package, ZIP package, or extensionless Love project path.
	-- @return (LoveNode | nil) The created LoveNode, or nil when the project cannot be loaded.
	metamethod __call: function(self: LoveNodeClass, bootFile: string): LoveNode | nil
end

local loveNodeClass: LoveNodeClass
return loveNodeClass
