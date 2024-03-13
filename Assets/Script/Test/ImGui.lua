-- [yue]: Script/Test/ImGui.yue
local threadLoop = dora.threadLoop -- 1
local ImGui = dora.ImGui -- 1
return threadLoop(ImGui.ShowDemoWindow) -- 3
