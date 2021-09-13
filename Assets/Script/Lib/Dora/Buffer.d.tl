local Object = require("Object").Type
local record Buffer
	embed Object
	const size: integer
	resize: function(self: Buffer, size: integer)
	zeroMemory: function(self: Buffer)
	toString: function(self: Buffer): string
	setString: function(str: string)
end
local record BufferClass
	type Type = Buffer
	metamethod __call: function(cls: BufferClass, size: integer): Buffer
end
local bufferClass: BufferClass
return bufferClass
