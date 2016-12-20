Dorothy()

print("hello Dorothy SSR")
print(oObject.count)
oContent:addSearchPath("Script")
local text = oContent:loadFile("main.lua")
print(text)
