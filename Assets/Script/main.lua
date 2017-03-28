Dorothy()

Director.displayStats = true

local model = Model("Model/jixienv.model")
model.loop = true
model:play("walk")
model.visible = false

local label = Label("NotoSansHans-Regular", 18)
model:addChild(label)

local buffer = Buffer(4*100)

model:schedule(function()
	if ImGui.Begin("Test", "ShowBorders|MenuBar") then
		if ImGui.InputText("", buffer) then
			label.text = buffer:toString()
		end
	end
	ImGui.End()
end)

Director:pushEntry(model)

collectgarbage("collect")

for k,v in pairs(ubox()) do
	print(k,v)
end

if true then return end

local function Move(duration, start, stop, ease)
	return Spawn(
		X(duration, start.x, stop.x, ease),
		Y(duration, start.y, stop.y, ease))
end

local action = Action(
	Sequence(
		Move(2, Vec2(0,0), Vec2(100,100), Ease.OutBack),
		Show(),
		Delay(0.2),
		Hide(),
		Delay(0.2),
		Show(),
		Delay(0.2),
		Hide(),
		Delay(0.2),
		Show(),
		Call(function()
			print("end!")
		end)
	))
action.reversed = false
--print(action,action.running,action.duration)

local node = Sprite("Image/logo.png")
--node.opacity = 0.03
--action = Action(Sequence(Call(function() print("start!") end), Delay(3), Call(function() print("stop!") end)))
--action.reversed = true
node:runAction(action)
action:pause()
Director.camera.zoom = 0
thread(function()
	cycle(2, function(time)
		action:updateTo(time * action.duration, false)
		Director.camera.zoom = Ease:func(Ease.OutQuad, time)
	end)
	action:resume()
end)
node:slot("ActionEnd", function(action, node)
	action.reversed = not action.reversed
	print("restarted!", action.reversed)
	node:runAction(action)
end)

print(Director.camera.name, Director.camera)

--Director:pushEntry(node)
--print(action,action.running,action.duration)

local dict = Dictionary()
dict.abc = "998"
dict.efg = 998

print(#dict, dict.abc, dict.efg)

local arr = Array()
for i = 1, 10 do
	arr:add(Node())
end

for i = 1, #arr do
	print(i, arr[i])
end

thread(function()
	print("here1")
	sleep(5)
	--Director:popEntry()
	print("here2")
	--[[local model = Director.currentEntry.children.first.children.first
	print(model)
	model.reversed = false
	model.speed = 0.5
	sleep(3)
	model.speed = 2.5
	sleep(3)
	model.speed = 1]]
end)

--[[

local sprite = Sprite("Image/logo.png")

Director:pushEntry(sprite)
]]

Content:addSearchPath("Script")
Content:addSearchPath("Script/Lib")
require("moonscript")

debug.traceback = function(err)
	local STP = require("StackTracePlus")
	STP.dump_locals = false
	STP.simplified = true
	return STP.stacktrace(err, 1)
end

require("test")
