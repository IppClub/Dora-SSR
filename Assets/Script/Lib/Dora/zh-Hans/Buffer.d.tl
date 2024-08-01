local Object = require("Object").Type

-- 用于ImGui输入组件的字符串缓冲区类。
local record Buffer

	-- 继承自“Object”。
	embed Object

	-- 缓冲区的大小。
	const size: integer

	-- 设置或获取缓冲区存储的文本。
	text: string

	-- 更改缓冲区的大小。
	-- @param size (integer) 缓冲区的新大小。
	resize: function(self: Buffer, size: integer)

	-- 将缓冲区中的所有字节设置为零。
	zeroMemory: function(self: Buffer)
end

-- 用于创建缓冲区对象的类。
local record BufferClass
	type Type = Buffer

	-- 创建一个新的缓冲区实例。
	-- @param size (integer) 要创建的缓冲区的大小。
	-- @return (Buffer) "Buffer"类型的新实例。
	metamethod __call: function(self: BufferClass, size: integer): Buffer
end

local bufferClass: BufferClass
return bufferClass
