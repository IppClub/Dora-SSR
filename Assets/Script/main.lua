Dorothy()

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

Director:pushEntry(node)
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
	sleep(5)
	Director:popEntry()
end)
--[[

local sprite = Sprite("Image/logo.png")

Director:pushEntry(sprite)
]]
