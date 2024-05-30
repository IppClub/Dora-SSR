-- [yue]: Script/Test/ImGui.yue
local threadLoop = Dora.threadLoop -- 1
local ImGui = Dora.ImGui -- 1
return threadLoop(ImGui.ShowDemoWindow) -- 4
