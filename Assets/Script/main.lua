Dorothy()

print("hello Dorothy SSR")

print("Object.count",Object.count)

local sprite = Sprite("Image/logo.png")
--sprite.anchor = Vec2.zero
sprite.skewX = 45
sprite.scaleX = 0.5
sprite.scaleY = 0.5
sprite:addChild(Sprite("Image/test.pvr"))
sprite:schedule(once(function()
	cycle(1000,function(dt)
		sprite.angle = sprite.angle + 1
	end)
end))
Director:pushEntry(sprite)

--[[
Content:addSearchPath("Script")

thread(function()
	sleep(1)
	local text = Content:loadAsync("main.lua")
	print(#text)
	sleep(4)
	local file = Content.writablePath.."main.lua"
	Content:copyAsync("main.lua",file)
	print(file,Content:exist(file))
	Content:remove(file)
	print(tolua.type(Object),tolua.type(Content))
end)

local n = Node()
n:gslot("UserEvent", function(...)
	print("Recieve UserEvent", ...)
end)

emit("UserEvent", 998, 233, "abc", n)

n:gslot("AppWillEnterBackground", function()
	print("AppWillEnterBackground")
end)

n:gslot("AppDidEnterBackground", function()
	print("AppDidEnterBackground")
end)

n:gslot("AppWillEnterForeground", function()
	print("AppWillEnterForeground")
end)

n:gslot("AppDidEnterForeground", function()
	print("AppDidEnterForeground")
end)

n:slot("event", function(...)
	print("Recieve slot event", ...)
end)
n:emit("event",123,456,"xxx")
n:schedule(once(function()
	sleep(1)
	print("node scheduled!")
	coroutine.yield(true)
	print("node still scheduled!")
end))
n:slot("Enter",function()
	print("Enter!")
end)
n:slot("Exit",function()
	print("Exit!")
end)
n:slot("Cleanup",function()
	print("Cleanup!")
end)
Director:pushEntry(n)
--Director:popEntry()
--Director:pushEntry(Node())

thread(function()
	for i = 1,6 do
		sleep(1)
		print(i)
	end
	local v = Vec2(0.5,0.5)
	local s = Size(100,300)
	local v1 = v * s
	local s1 = s * v
	print(v1,v1.x,v1.y)
	print(s1,s1.width,s1.height)
	Log("stop!")
end)
]]
