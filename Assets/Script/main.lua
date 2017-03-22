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

node = Sprite("Image/logo.png")
--node.opacity = 0.03
--action = Action(Sequence(Call(function() print("start!") end), Delay(3), Call(function() print("stop!") end)))
--action.reversed = true
node:runAction(action)
action:pause()
thread(function()
	cycle(3, function(eclapsed)
		action:updateTo(eclapsed * action.duration, false)
	end)
end)
node:slot("ActionEnd", function(action, node)
	action.reversed = not action.reversed
	print("restarted!", action.reversed)
	node:runAction(action)
end)

Director:pushEntry(node)
--print(action,action.running,action.duration)

--[[

local sprite = Sprite("Image/logo.png")

Director:pushEntry(sprite)
]]
