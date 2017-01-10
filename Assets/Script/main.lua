Dorothy()

print("hello Dorothy SSR")

print("Object.count",Object.count)

Content:addSearchPath("Script")

thread(function()
	sleep(1)
	local text = Content:loadAsync("main.lua")
	print(text)
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
n:slot("event", function(...)
	print("Recieve slot event", ...)
end)
n:emit("event",123,456,"xxx")

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
