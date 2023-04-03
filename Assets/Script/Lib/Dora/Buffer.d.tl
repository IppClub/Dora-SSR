local Object = require("Object").Type

-- A buffer of string for the use of ImGui widget.
local record Buffer
	embed Object

	-- The size of the buffer.
	const size: integer

	-- Changing the size of the buffer.
	-- @param size (integer) The new size of the buffer.
	resize: function(self: Buffer, size: integer)

	-- Setting all bytes in the buffer to zero.
	zeroMemory: function(self: Buffer)

	-- Converting the buffer to a string.
	-- @return (string) The buffer contents as a string.
	toString: function(self: Buffer): string

	-- Setting the contents of the buffer with a string.
	-- @param string str The new contents of the buffer.
	setString: function(str: string)
end

-- A class for creating Buffer object.
local record BufferClass
	type Type = Buffer

	-- Creates a new buffer instance.
	-- @param size (integer) The size of the buffer to create.
	-- @return (Buffer) A new instance of the "Buffer" type with the given size.
	metamethod __call: function(self: BufferClass, size: integer): Buffer
end

local bufferClass: BufferClass
return bufferClass
