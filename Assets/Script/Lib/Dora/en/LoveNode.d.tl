local Sprite = require("Sprite").Type

-- A Dora scene node that owns and runs one isolated Love Lua state.
local record LoveNode
	embed Sprite

	bootFile: string
	sourceRoot: string
	lastError: string
	running: boolean

	-- Destroys the old Love state, reloads the boot file, and starts a new state.
	restart: function(self: LoveNode): boolean
end

local record LoveNodeClass
	type Type = LoveNode

	-- Creates a LoveNode from a boot Lua file, .love package, or ZIP package. An extensionless relative path also resolves to `<path>.love`, `<path>.zip`, or `<path>/main.lua`. Returns nil when loading fails.
	metamethod __call: function(self: LoveNodeClass, bootFile: string): LoveNode | nil
end

local loveNodeClass: LoveNodeClass
return loveNodeClass
