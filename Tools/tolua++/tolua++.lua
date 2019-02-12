local globals = {lfs=true}
lfs = require("lfs")
TOLUA_VERSION = "1.0.92"

for k in pairs(_G) do
	globals[k] = true
end

for _,v in ipairs({
		{t=true,D=true,L="basic.lua",o="../../Source/Lua/LuaBinding.cpp",f="LuaBinding.pkg",lua_entry=true},
		{t=true,D=true,L="basic.lua",o="../../Source/Lua/LuaCode.cpp",f="LuaCode.pkg",lua_entry=true}
	}) do

	keys = {}
	for k in pairs(_G) do
		if not globals[k] then
			table.insert(keys,k)
		end
	end
	for _,k in ipairs(keys) do
		_G[k] = nil
	end

	_extra_parameters = {}
	flags = v

	local files = {
		"tolua++/compat.lua",
		"tolua++/basic.lua",
		"tolua++/feature.lua",
		"tolua++/verbatim.lua",
		"tolua++/code.lua",
		"tolua++/typedef.lua",
		"tolua++/container.lua",
		"tolua++/package.lua",
		"tolua++/module.lua",
		"tolua++/namespace.lua",
		"tolua++/define.lua",
		"tolua++/enumerate.lua",
		"tolua++/declaration.lua",
		"tolua++/variable.lua",
		"tolua++/array.lua",
		"tolua++/function.lua",
		"tolua++/operator.lua",
		"tolua++/template_class.lua",
		"tolua++/class.lua",
		"tolua++/clean.lua",
		"tolua++/doit.lua"
	}

	for _,file in ipairs(files) do
		dofile(file)
	end

	local err,msg = pcall(doit)
	if not err then
		local _,_,label,msg = strfind(msg,"(.-:.-:%s*)(.*)")
		error(msg..tostring(label))
		print(debug.traceback())
	end

end

