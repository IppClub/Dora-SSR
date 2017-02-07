Dorothy()

print("hello Dorothy SSR")

print("Object.count",Object.count)

local tex

thread(function()
	tex = TextureCache:loadAsync("Image/logo.png")
	print(tex.width, tex.height)
end)

thread(function()
	local sprite = Sprite("Image/logo.png")
	Director:pushEntry(sprite)
	--sprite.passOpacity = false
	local pos = sprite:convertToWorldSpace(Vec2.zero)
	print(pos.x, pos.y)
	--sprite.anchor = Vec2.zero
	--sprite.skewX = 45
	sprite.scaleX = 5
	sprite.scaleY = 5
	sprite.angleY = -45
--[[
	local s = Sprite("Image/logo.png")
	s.position = Vec2(1,1)
	sprite:addChild(s)

	local sp = Sprite("Image/logo.png")
	s:addChild(sp)

	local sp1 = Sprite("Image/logo.png")
	sp:addChild(sp1)
--]]
--[[
	sleep(1)

	sprite:schedule(once(function()
		cycle(10000,function(dt)
			sprite.angle = sprite.angle + 1
		end)
	end))
	print(tex, sprite.texture, tex == sprite.texture)
	print(tostring(Dorothy))
--]]
	--sprite.opacity = 0.05
	sprite:slot("TapBegan", function(touch)
		print("TapBegan", touch.location.x, touch.location.y)
		local sp = Sprite("Image/logo.png")
		sp.position = touch.location
		sp.scaleX = 0.1
		sp.scaleY = 0.1
		sprite:addChild(sp)
	end)
	sprite:slot("Tapped", function(touch)
		print("Tapped", touch.location.x, touch.location.y)
	end)
end)

print("continue")

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
