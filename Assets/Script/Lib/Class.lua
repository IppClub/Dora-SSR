local builtin = _G.builtin
local tolua = builtin.tolua
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

	0 - class
	1 - instance

3.To inherit a class

	-- Inherit a lua table class
	local Base = class({ ... })
	local MyClass = class(Base,{ ... })

	-- Inherit a C++ instance class
	local MyClass = class({
		__partial = function(self, args)
			return Node()
		end,
	})

	-- or
	local MyClass = class(function(args)
		return Node()
	end,{ ... })

	-- or
	local MyClass = class(Node,{ ... })

4.To add class member function

	local MyClass = class({
		foo = function(self)
			print("bar")
		end
	})

	-- or
	local MyClass = class()

	function MyClass:foo()
		print("bar")
	end

5.Use number index to add field to a class
	is deprecated. Example below may cause error.

	MyClass = class({
		[0] = 123
		[1] = 998
		[2] = 233
	})

6.Instance created by class has some special field

	local BaseClass = class()
	local MyClass = class(BaseClass)

	local inst = MyClass()
	print(inst.__class == MyClass) -- true
	print(inst.__base == BaseClass) -- true
]]

local function __call(cls,...)
	local inst = {}
	setmetatable(inst,cls)
	if cls.__partial then
		local c_inst = cls.__partial(inst,...)
		if c_inst then
			local peer = tolua.getpeer(c_inst)
			if peer then
				for k,v in pairs(peer) do
					inst[k] = v
				end
				local peerClass = getmetatable(peer)
				if peerClass then
					local baseClass = getmetatable(cls)
					setmetatable(baseClass,peerClass) -- chaining partial class`s metatable
				end
			end
			tolua.setpeer(c_inst,inst)
			inst[0] = c_inst
		end
		inst = c_inst or inst
	end
	if cls.__init then
		cls.__init(inst,...)
	end
	return inst
end

local function __index(self,name)
	local cls = getmetatable(self)
	local item = cls[1][name] -- access properties
	if item then
		return item(rawget(self,0) or self)
	else
		item = rawget(cls,name) -- access member functions
		if item then
			return item
		else
			local c = getmetatable(cls)
			while c do -- recursive to access super classes
				item = c[1][name]
				if item then
					cls[1][name] = item -- cache super properties to class
					return item(rawget(self,0) or self)
				else
					item = rawget(c,name)
					if item then
						rawset(cls,name,item) -- cache super member to class
						return item
					end
				end
				c = getmetatable(c)
			end
			return nil
		end
	end
end

local function __newindex(self,name,value)
	local cls = getmetatable(self)
	local item = cls[2][name] -- access properties
	if item then
		item(rawget(self,0) or self,value)
	else
		local c = getmetatable(cls)
		while c do -- recursive to access super properties
			item = c[2][name]
			if item then
				cls[2][name] = item -- cache super property to class
				item(rawget(self,0) or self,value)
				return
			end
			c = getmetatable(c)
		end
		rawset(self,name,value) -- assign field to self
	end
end

local function assignReadOnly()
	error("Try to assign to a readonly property!")
end

local function class(arg1,arg2)
	-- check params
	local __partial,classDef,base
	local argType = tolua.type(arg1)
	-- case 1
	-- arg1:function(__partial), arg2:table(ClassDef)
	if argType == "function" then
		__partial = function(self,...)
			return arg1(...)
		end
		classDef = arg2
	-- case 2
	-- arg1:table(BaseClass), arg2:table(ClassDef)
	-- arg1:table(ClassDef), arg2:nil
	elseif argType == "table" then
		if arg2 then
			base,classDef = arg1,arg2
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
				__class = function() return base end,
				__base = function() return getmetatable(base) end,
			},
			{
				__class = assignReadOnly,
				__base = assignReadOnly,
			},
			__index = __index,
			__newindex = __newindex,
			__call = __call,
		}
	end

	-- create class
	local cls
	cls = {
		{
			__class = function() return cls end,
			__base = function() return base end,
		},
		{
			__class = assignReadOnly,
			__base = assignReadOnly,
		},
		__index = __index,
		__newindex = __newindex,
		__call = __call,
		__partial = __partial,
	}

	-- copy class def
	if classDef then
		for k,v in pairs(classDef) do
			if type(v) == "table" then
				if v.__fieldlevel == 0 then
					base[1][k] = v[1]
					base[2][k] = v[2]
				elseif v.__fieldlevel == 1 then
					cls[1][k] = v[1]
					cls[2][k] = v[2]
				else
					cls[k] = v
				end
			else
				cls[k] = v
			end
		end
	end

	-- make class derived from base
	setmetatable(cls,base)

	-- invoke the class init function
	local __initc = rawget(cls,"__initc")
	if __initc then
		__initc(cls)
		rawset(cls,__initc,nil) -- run once and dispose this method
	end
	return cls
end

local function property(getter,setter)
	return {getter,setter or assignReadOnly,__fieldlevel=1}
end

local function classfield(getter,setter)
	return {getter,setter or assignReadOnly,__fieldlevel=0}
end

local function classmethod(method)
	return method
end

builtin.Class = class
builtin.property = property
builtin.classfield = classfield
builtin.classmethod = classmethod
