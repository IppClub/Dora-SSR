--[[ Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. ]]

local tolua = Dora.tolua
local setmetatable = setmetatable
local getmetatable = getmetatable
local pairs = pairs
local rawget = rawget
local rawset = rawset
local type = type

--[[
1.Class Field

	0 - C++ instance
	1 - getters
	2 - setters

2.Field Level

	1 - class
	2 - instance

3.To inherit a class

	-- Inherit a lua table class
	local Base = Class({ ... })
	local MyClass = Class(Base, { ... })

	-- Inherit a C++ instance class
	local MyClass = Class({
		__partial = function(self, args)
			return Node()
		end,
	})

	-- or
	local MyClass = Class(function(args)
		return Node()
	end, { ... })

	-- or
	local MyClass = Class(Node, { ... })

4.To add class member function

	local MyClass = Class({
		foo = function(self)
			print("bar")
		end
	})

	-- or
	local MyClass = Class()

	function MyClass:foo()
		print("bar")
	end

5.Use number index to add field to a class
	is deprecated. Example below may cause error.

	MyClass = Class({
		[1] = 123
		[2] = 998
		[3] = 233
	})

6.Instance created by class has some special field

	local BaseClass = Class()
	local MyClass = Class(BaseClass)

	local inst = MyClass()
	print(inst.__class == MyClass) -- true
	print(inst.__base == BaseClass) -- true
]]

local CppInst <const> = 0
local Getter <const> = 1
local Setter <const> = 2

local ClassField <const> = 1
local ObjectField <const> = 2

local function __call(cls, ...)
	local inst = {}
	setmetatable(inst, cls)
	if cls.__partial then
		local c_inst = cls.__partial(inst, ...)
		if c_inst then
			local peer = tolua.getpeer(c_inst)
			if peer then
				for k, v in pairs(peer) do
					inst[k] = v
				end
				local peerClass = getmetatable(peer)
				if peerClass then
					local baseClass = getmetatable(cls)
					setmetatable(baseClass, peerClass) -- chaining partial class`s metatable
				end
			end
			tolua.setpeer(c_inst, inst)
			inst[CppInst] = c_inst
		end
		inst = c_inst or inst
	end
	if cls.__init then
		cls.__init(inst, ...)
	end
	return inst
end

local function __index(self, name)
	local cls = getmetatable(self)
	local item = cls[Getter][name] -- access properties
	if item then
		return item(rawget(self, CppInst) or self)
	else
		item = rawget(cls, name) -- access member functions
		if item ~= nil then
			return item
		else
			local c = getmetatable(cls)
			while c do -- recursive to access super classes
				item = c[Getter][name]
				if item then
					cls[Getter][name] = item -- cache super properties to class
					return item(rawget(self, CppInst) or self)
				else
					item = rawget(c, name)
					if item ~= nil then
						rawset(cls, name, item) -- cache super member to class
						return item
					end
				end
				c = getmetatable(c)
			end
			return nil
		end
	end
end

local function __newindex(self, name, value)
	local cls = getmetatable(self)
	local item = cls[Setter][name] -- access properties
	if item then
		item(rawget(self, CppInst) or self, value)
	else
		local c = getmetatable(cls)
		while c do -- recursive to access super properties
			item = c[Setter][name]
			if item then
				cls[Setter][name] = item -- cache super property to class
				item(rawget(self, CppInst) or self, value)
				return
			end
			c = getmetatable(c)
		end
		rawset(self, name, value) -- assign field to self
	end
end

local function assignReadOnly()
	error("try to assign to a readonly property!")
end

local function Class(arg1, arg2)
	-- check params
	local __partial, classDef, base
	local argType = tolua.type(arg1)
	-- case 1
	-- arg1:function(__partial), arg2:table(ClassDef)
	if argType == "function" then
		__partial = function(self, ...)
			return arg1(...)
		end
		classDef = arg2
		-- case 2
		-- arg1:table(BaseClass), arg2:table(ClassDef)
		-- arg1:table(ClassDef), arg2:nil
	elseif argType == "table" then
		if arg2 then
			base, classDef = arg1, arg2
		elseif arg1.__class then
			base = arg1
		else
			classDef = arg1
		end
		-- case 3
		-- arg1:Object(C++ Inst), arg2:table(ClassDef)
	elseif argType ~= "nil" then
		__partial = function(self)
			return arg1()
		end
		classDef = arg2
	end

	-- create base
	if not base then
		base = {
			{
				__class = function()
					return base
				end,
				__base = function()
					return getmetatable(base)
				end
			},
			{
				__class = assignReadOnly,
				__base = assignReadOnly
			},
			__index = __index,
			__newindex = __newindex,
			__call = __call
		}
	end

	-- create class
	local cls
	cls = {
		{
			__class = function()
				return cls
			end,
			__base = function()
				return base
			end
		},
		{
			__class = assignReadOnly,
			__base = assignReadOnly
		},
		__index = __index,
		__newindex = __newindex,
		__call = __call,
		__partial = __partial
	}

	-- copy class def
	if classDef then
		for k, v in pairs(classDef) do
			if type(v) == "table" then
				if v.__fieldlevel == ClassField then
					base[Getter][k] = v[1]
					base[Setter][k] = v[2]
				elseif v.__fieldlevel == ObjectField then
					cls[Getter][k] = v[1]
					cls[Setter][k] = v[2]
				else
					cls[k] = v
				end
			else
				cls[k] = v
			end
		end
	end

	-- make class derived from base
	setmetatable(cls, base)

	-- invoke the class init function
	local __initc = rawget(cls, "__initc")
	if __initc then
		__initc(cls)
		rawset(cls, __initc, nil) -- run once and dispose this method
	end
	return cls
end

local function property(getter, setter)
	return {
		getter,
		setter or assignReadOnly,
		__fieldlevel = ObjectField
	}
end

local function classfield(getter, setter)
	return {
		getter,
		setter or assignReadOnly,
		__fieldlevel = ClassField
	}
end

local function classmethod(method)
	return method
end

Dora.Class = Class
Dora.property = property
Dora.classfield = classfield
Dora.classmethod = classmethod
