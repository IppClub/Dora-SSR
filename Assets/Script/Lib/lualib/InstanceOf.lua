local function __TS__InstanceOf(obj, classTbl)
	if type(classTbl) ~= "table" then
		error("Right-hand side of 'instanceof' is not an object", 0)
	end
	if classTbl[Symbol.hasInstance] ~= nil then
		return not not classTbl[Symbol.hasInstance](classTbl, obj)
	end
	if type(obj) == "table" then
		local luaClass = obj.constructor
		while luaClass ~= nil do
			if luaClass == classTbl then
				return true
			end
			luaClass = luaClass.____super
		end
	end
	return false
end
