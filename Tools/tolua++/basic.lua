TOLUA_VERSION = "1.0.92+dora"
local output_change = lfs.attributes(flags.o, "modification")
local rebuild = output_change == nil

if not rebuild then
	local input_changes = {
		lfs.attributes(flags.f, "modification"),
		lfs.attributes("basic.lua", "modification"),
		lfs.attributes("tolua++/compat.lua", "modification"),
		lfs.attributes("tolua++/basic.lua", "modification"),
		lfs.attributes("tolua++/feature.lua", "modification"),
		lfs.attributes("tolua++/verbatim.lua", "modification"),
		lfs.attributes("tolua++/code.lua", "modification"),
		lfs.attributes("tolua++/typedef.lua", "modification"),
		lfs.attributes("tolua++/container.lua", "modification"),
		lfs.attributes("tolua++/package.lua", "modification"),
		lfs.attributes("tolua++/module.lua", "modification"),
		lfs.attributes("tolua++/namespace.lua", "modification"),
		lfs.attributes("tolua++/define.lua", "modification"),
		lfs.attributes("tolua++/enumerate.lua", "modification"),
		lfs.attributes("tolua++/declaration.lua", "modification"),
		lfs.attributes("tolua++/variable.lua", "modification"),
		lfs.attributes("tolua++/array.lua", "modification"),
		lfs.attributes("tolua++/function.lua", "modification"),
		lfs.attributes("tolua++/operator.lua", "modification"),
		lfs.attributes("tolua++/template_class.lua", "modification"),
		lfs.attributes("tolua++/class.lua", "modification"),
		lfs.attributes("tolua++/clean.lua", "modification"),
		lfs.attributes("tolua++/doit.lua", "modification")
	}
	local inputFile = io.open(flags.f, "r")
	local content = inputFile:read("*a")
	inputFile:close()
	for file in content:gmatch('file%s*"([^"]+)') do
		input_changes[#input_changes + 1] = lfs.attributes(file, "modification")
	end
	for _, change in ipairs(input_changes) do
		if output_change < change then
			rebuild = true
			break
		end
	end
end

if not rebuild then
	print(string.format('C++ codes for "%s" are updated.', flags.f))
	if not flags.lua_entry then
		os.exit(0)
	end
else
	print(string.format('Generating C++ codes for "%s"...', flags.f))
end

_push_functions = _push_functions or {}
_collect_functions = _collect_functions or {}
_to_functions = _to_functions or {}
_is_functions = _is_functions or {}

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
	"Pass",
	"ParticleNode",
	"Camera",
	"Playable",
	"Model",
	"Spine",
	"DragonBone",
	"OthoCamera",
	"FixtureDef",
	"BodyDef",
	"Buffer",
	"Camera2D",
	"Sprite",
	"Grid",
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
	"Node::Grabber",
	"Line",
	"Touch",
	"Label",
	"ML::QLearner",
	"SVGDef",
	"AlignNode",
	"EffekNode",
	"TileNode",
	"AudioBus",
	"AudioSource",
	"VideoNode",
	"TIC80Node",
	"Platformer::Unit",
	"Platformer::Face",
	"Platformer::PlatformCamera",
	"Platformer::Visual",
	"Platformer::UnitDef",
	"Platformer::BulletDef",
	"Platformer::Decision::Leaf",
	"Platformer::Behavior::Leaf",
	"Platformer::Bullet",
	"Platformer::PlatformWorld"
}
_push_object_func_name = "tolua_pushobject"
_is_object_func_name = "tolua_isobject"
for i = 1, #objects do
	_is_functions[objects[i]] = _is_object_func_name
	_push_functions[objects[i]] = _push_object_func_name
	_collect_functions[objects[i]] = "tolua_collect_object"
end

_light_object = "Vec2"
_push_light_func_name = "tolua_pushlight"
_push_functions[_light_object] = _push_light_func_name
_to_functions[_light_object] = "tolua_tolight"

-- Name -> push'name'
_basic["Slice"] = "slice"
_basic["int8_t"] = "integer"
_basic["uint8_t"] = "integer"
_basic["int16_t"] = "integer"
_basic["uint16_t"] = "integer"
_basic["int32_t"] = "integer"
_basic["uint32_t"] = "integer"
_basic["int64_t"] = "integer"
_basic["uint64_t"] = "integer"
_basic["size_t"] = "integer"
_basic["string"] = "slice"
_basic["std::string"] = "slice"

-- c types
_basic_ctype.slice = "Slice"

local toWrite = {}
local currentString = ""
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
		if string.sub(currentString, -1) == "\n" then
			toWrite[#toWrite + 1] = currentString
			currentString = ""
		end
	else
		WRITE(a)
	end
end

function post_output_hook(package)
	local result = table.concat(toWrite)
	local function replace(pattern, replacement)
		local k = 0
		local nxt, currentString = 1, ""
		repeat
			local s, e = string.find(result, pattern, nxt, true)
			if e then
				currentString = currentString .. string.sub(result, nxt, s - 1) .. replacement
				nxt = e + 1
				k = k + 1
			end
		until not e
		result = currentString .. string.sub(result, nxt)
		if k == 0 then
			print("Pattern not replaced", pattern)
		end
	end

	--replace("","")

	WRITE(result)
end

function get_property_methods_hook(ptype, name)
	--tolua_property__common
	if ptype == "common" then
		local newName = string.upper(string.sub(name, 1, 1)) .. string.sub(name, 2, string.len(name))
		return "get" .. newName, "set" .. newName
	end
	--tolua_property__bool
	if ptype == "bool" then
		--local temp = string.sub(name,3,string.len(name)-2)
		--local newName = string.upper(string.sub(str1,1,1))..string.sub(str1,2,string.len(str1)-1)
		local newName = string.upper(string.sub(name, 1, 1)) .. string.sub(name, 2, string.len(name))
		return "is" .. newName, "set" .. newName
	end
	-- etc
end

