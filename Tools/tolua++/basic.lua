local output_change = lfs.attributes(flags.o,"change")
local rebuild = output_change == nil

if not rebuild then
	local input_changes = {
		lfs.attributes(flags.f,"change"),
		lfs.attributes("basic.lua","change"),
	}
	local inputFile = io.open(flags.f,"r")
	local content = inputFile:read("*a")
	inputFile:close()
	for file in content:gmatch("file%s*\"([^\"]+)") do
		input_changes[#input_changes + 1] = lfs.attributes(file, "change")
	end
	for _,change in ipairs(input_changes) do
		if output_change < change then
			rebuild = true
			break
		end
	end
end

if not rebuild then
	print(string.format("C++ codes for \"%s\" are updated.", flags.f))
	if not flags.lua_entry then
		os.exit(0)
	end
else
	print(string.format("Generating C++ codes for \"%s\"...", flags.f))
end

_push_functions = _push_functions or {}
_collect_functions = _collect_functions or {}
local objects = {
"Object",
"Scheduler",
"Listener",
"Array",
"Dictionary",
"PhysicsWorld",
"DrawNode",
"VGNode",
"Effect",
"Particle",
"Camera",
"Model",
"OthoCamera",
"BodyDef",
"Buffer",
"Camera2D",
"Sprite",
"MotorJoint",
"Menu",
"Action",
"Array",
"Body",
"Dictionary",
"Entity",
"EntityGroup",
"EntityObserver",
"Joint",
"Sensor",
"Scheduler",
"RenderTarget",
"SpriteEffect",
"MoveJoint",
"ClipNode",
"Texture2D",
"JointDef",
"Node",
"Line",
"Touch",
"Label",
"Slot",
"Platformer::Unit",
"Platformer::Face",
"Platformer::PlatformCamera",
"Platformer::Visual",
"Platformer::UnitDef",
"Platformer::BulletDef",
"Platformer::AILeaf",
"Platformer::Bullet",
"Platformer::PlatformWorld",
}

-- register Object types
for i = 1, #objects do
    _push_functions[objects[i]] = "tolua_pushobject"
	_collect_functions[objects[i]] = "tolua_collect_object"
end

-- Name -> push'name'
_basic["Slice"] = "slice"
_basic["Uint8"] = "number"
_basic["Uint16"] = "number"
_basic["Uint32"] = "number"
_basic["size_t"] = "number"
_basic['string'] = 'slice'
_basic['std::string'] = 'slice'

-- c types
_basic_ctype.slice = "Slice"

local toWrite = {}
local currentString = ''
local out
local WRITE, OUTPUT = write, output

function output(s)
    out = _OUTPUT
    output = OUTPUT -- restore
    output(s)
end

function write(a)
    if out == _OUTPUT then
        currentString = currentString .. a
        if string.sub(currentString,-1) == '\n'  then
            toWrite[#toWrite+1] = currentString
            currentString = ''
        end
    else
        WRITE(a)
    end
end

function post_output_hook(package)
    local result = table.concat(toWrite)
    local function replace(pattern, replacement)
        local k = 0
        local nxt, currentString = 1, ''
        repeat
            local s, e = string.find(result, pattern, nxt, true)
            if e then
                currentString = currentString .. string.sub(result, nxt, s-1) .. replacement
                nxt = e + 1
                k = k + 1
            end
        until not e
        result = currentString..string.sub(result, nxt)
        if k == 0 then print('Pattern not replaced', pattern) end
    end

	--replace("","")

    WRITE(result)
end

function get_property_methods_hook(ptype, name)
	--tolua_property__common
	if ptype == "common" then
		local newName = string.upper(string.sub(name,1,1))..string.sub(name,2,string.len(name))
		return "get"..newName, "set"..newName
	end
	--tolua_property__bool
	if ptype == "bool" then
		--local temp = string.sub(name,3,string.len(name)-2)
		--local newName = string.upper(string.sub(str1,1,1))..string.sub(str1,2,string.len(str1)-1)
		local newName = string.upper(string.sub(name,1,1))..string.sub(name,2,string.len(name))
		return "is"..newName, "set"..newName
	end
	-- etc
end

