Dorothy()

print("hello Dorothy SSR")

print(Object.count)

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

emit("UserEvent")

thread(function()
	sleep(1)
	print(1)
	sleep(1)
	print(2)
	sleep(1)
	print(3)
	sleep(1)
	Log("stop!")
end)
