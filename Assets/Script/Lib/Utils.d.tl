local Vec2 = require("Vec2").Type
local record Struct
	enum RecordEvent
		"Modified"
		"Updated"
	end
	enum ArrayEvent
		"Added"
		"Removed"
		"Changed"
		"Updated"
	end
	set: function(self: Struct, index: integer, item: any)
	get: function(self: Struct, index: integer): any
	insert: function(self: Struct, item: any)
	insert: function(self: Struct, index: integer, item: any)
	remove: function(self: Struct, item: any): any
	removeAt: function(self: Struct, index: integer): boolean
	clear: function(self: Struct)
	each: function(self: Struct, handler: function(value: any, index: integer): boolean): boolean
	eachAttr: function(self: Struct, handler: function(key: string, value: any))
	contains: function(self: Struct, item: any): boolean
	count: function(self: Struct): integer
	sort: function(comparer: function(any,any):boolean)
	__notify: function(event: RecordEvent, key: string, value: any)
	__notify: function(event: ArrayEvent, index: integer, value: any)
	metamethod __index: function(self: Struct, key: string): any
	metamethod __newindex: function(self: Struct, key: string, item: any)
end
local record StructClass
	metamethod __call: function(self: StructClass, values?: table): Struct
end
local record StructModule
	metamethod __index: function(self: StructModule, name: string): StructModule
	metamethod __call: function(self: StructModule, ...: string | {string}): StructClass
end
local record StructHelper
	type Type = Struct
	type RecordEvent = Struct.RecordEvent
	type ArrayEvent = Struct.ArrayEvent
	metamethod __index: function(self: StructHelper, name: string): StructModule
	load: function(self: StructHelper, input: string): Struct
	load: function(self: StructHelper, input: table): Struct
	load: function(self: StructHelper, name: string, input: table): Struct
	loadfile: function(self: StructHelper, filename: string): Struct
	clear: function(self: StructHelper)
	has: function(self: StructHelper, name: string): boolean
end
local record Utils
	Struct: StructHelper
	Set: function(list: {any}): {any: boolean}
	CompareTable: function(old: {any}, new: {any}):--[[added]] {any}, --[[deleted]] {any}
	Round: function(val: number): integer
	Round: function(val: Vec2): Vec2
	IsValidPath: function(path: string): boolean
	GSplit: function(text: string, pattern: string, plain: boolean): function(): string
end

return Utils