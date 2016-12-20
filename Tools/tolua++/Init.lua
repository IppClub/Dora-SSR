for k,v in pairs(_G) do
	builtin[k] = v
end

builtin.oContent = builtin.oContent()

local function disallowAssignGlobal(_,name)
	error("Disallow creating global value \""..name.."\".")
end

local dorothyEnvMeta = {
	__index = builtin,
	__newindex = disallowAssignGlobal
}

-- env must be a data only table without metatable
local function Dorothy(env)
	if env then
		setfenv(2,setmetatable(env,dorothyEnvMeta))
	else
		setfenv(2,builtin)
	end
end
_G.Dorothy = Dorothy
builtin.Dorothy = Dorothy

setmetatable(package.loaded,{__index=builtin})

local builtinEnvMeta = {
	__newindex = disallowAssignGlobal
}
setmetatable(_G,builtinEnvMeta)
setmetatable(builtin,builtinEnvMeta)

collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)
