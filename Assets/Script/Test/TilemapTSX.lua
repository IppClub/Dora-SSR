-- [tsx]: TilemapTSX.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local useRef = ____DoraX.useRef -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Vec2 = ____Dora.Vec2 -- 3
local threadLoop = ____Dora.threadLoop -- 3
local ImGui = require("ImGui") -- 5
local current = nil -- 7
local function TMX(self, file) -- 9
    if current then -- 9
        current:removeFromParent() -- 11
    end -- 11
    local tileNodeRef = useRef() -- 13
    current = toNode(React:createElement( -- 14
        "align-node", -- 14
        { -- 14
            windowRoot = true, -- 14
            onTapMoved = function(touch) -- 14
                if tileNodeRef.current then -- 14
                    tileNodeRef.current.position = tileNodeRef.current.position:add(touch.delta) -- 17
                end -- 17
            end -- 15
        }, -- 15
        React:createElement("tile-node", {ref = tileNodeRef, file = file}) -- 15
    )) -- 15
end -- 9
local files = {"TMX/platform.tmx", "TMX/demo.tmx"} -- 25
TMX(nil, files[1]) -- 30
local currentTest = 1 -- 32
local windowFlags = { -- 33
    "NoDecoration", -- 34
    "NoSavedSettings", -- 35
    "NoFocusOnAppearing", -- 36
    "NoNav", -- 37
    "NoMove" -- 38
} -- 38
threadLoop(function() -- 40
    local ____App_visualSize_0 = App.visualSize -- 41
    local width = ____App_visualSize_0.width -- 41
    ImGui.SetNextWindowPos( -- 42
        Vec2(width - 10, 10), -- 42
        "Always", -- 42
        Vec2(1, 0) -- 42
    ) -- 42
    ImGui.SetNextWindowSize( -- 43
        Vec2(200, 0), -- 43
        "Always" -- 43
    ) -- 43
    ImGui.Begin( -- 44
        "Tilemap", -- 44
        windowFlags, -- 44
        function() -- 44
            ImGui.Text("Tilemap (TSX)") -- 45
            ImGui.Separator() -- 46
            ImGui.TextWrapped("Drag to view the whole scene.") -- 47
            local changed = false -- 48
            changed, currentTest = ImGui.Combo("File", currentTest, files) -- 49
            if changed then -- 49
                TMX(nil, files[currentTest]) -- 51
            end -- 51
        end -- 44
    ) -- 44
    return false -- 54
end) -- 40
return ____exports -- 40