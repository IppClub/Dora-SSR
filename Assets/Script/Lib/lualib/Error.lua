local Error, RangeError, ReferenceError, SyntaxError, TypeError, URIError
do
	local function getErrorStack(self, constructor)
		if debug == nil then
			return nil
		end
		local level = 1
		while true do
			local info = debug.getinfo(level, "f")
			level = level + 1
			if not info then
				level = 1
				break
			elseif info.func == constructor then
				break
			end
		end
		if __TS__StringIncludes(_VERSION, "Lua 5.0") then
			return debug.traceback(("[Level " .. tostring(level)) .. "]")
		elseif _VERSION == "Lua 5.1" then
			return string.sub(
				debug.traceback("", level),
				2
			)
		else
			return debug.traceback(nil, level)
		end
	end
	local function wrapErrorToString(self, getDescription)
		return function(self)
			local description = getDescription(self)
			local caller = debug.getinfo(3, "f")
			local isClassicLua = __TS__StringIncludes(_VERSION, "Lua 5.0")
			if isClassicLua or caller and caller.func ~= error then
				return description
			else
				return (description .. "\n") .. tostring(self.stack)
			end
		end
	end
	local function initErrorClass(self, Type, name)
		Type.name = name
		return setmetatable(
			Type,
			{__call = function(____, _self, message) return __TS__New(Type, message) end}
		)
	end
	local ____initErrorClass_1 = initErrorClass
	local ____class_0 = __TS__Class()
	____class_0.name = ""
	function ____class_0.prototype.____constructor(self, message)
		if message == nil then
			message = ""
		end
		self.message = message
		self.name = "Error"
		self.stack = getErrorStack(nil, __TS__New)
		local metatable = getmetatable(self)
		if metatable and not metatable.__errorToStringPatched then
			metatable.__errorToStringPatched = true
			metatable.__tostring = wrapErrorToString(nil, metatable.__tostring)
		end
	end
	function ____class_0.prototype.__tostring(self)
		return self.message ~= "" and (self.name .. ": ") .. self.message or self.name
	end
	Error = ____initErrorClass_1(nil, ____class_0, "Error")
	local function createErrorClass(self, name)
		local ____initErrorClass_3 = initErrorClass
		local ____class_2 = __TS__Class()
		____class_2.name = ____class_2.name
		__TS__ClassExtends(____class_2, Error)
		function ____class_2.prototype.____constructor(self, ...)
			____class_2.____super.prototype.____constructor(self, ...)
			self.name = name
		end
		return ____initErrorClass_3(nil, ____class_2, name)
	end
	RangeError = createErrorClass(nil, "RangeError")
	ReferenceError = createErrorClass(nil, "ReferenceError")
	SyntaxError = createErrorClass(nil, "SyntaxError")
	TypeError = createErrorClass(nil, "TypeError")
	URIError = createErrorClass(nil, "URIError")
end
