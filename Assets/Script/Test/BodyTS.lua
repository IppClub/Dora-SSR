-- [ts]: BodyTS.ts
local ____exports = {} -- 1
local ____dora = require("dora") -- 1
local App = ____dora.App -- 1
local Body = ____dora.Body -- 1
local BodyDef = ____dora.BodyDef -- 1
local PhysicsWorld = ____dora.PhysicsWorld -- 1
local Vec2 = ____dora.Vec2 -- 1
local threadLoop = ____dora.threadLoop -- 1
local ImGui = require("ImGui") -- 2
local gravity = Vec2(0, -10) -- 5
local groupZero = 0 -- 6
local groupOne = 1 -- 7
local groupTwo = 2 -- 8
local terrainDef = BodyDef() -- 10
terrainDef.type = "Static" -- 11
terrainDef:attachPolygon( -- 12
    800, -- 12
    10, -- 12
    1, -- 12
    0.8, -- 12
    0.2 -- 12
) -- 12
local polygonDef = BodyDef() -- 14
polygonDef.type = "Dynamic" -- 15
polygonDef.linearAcceleration = gravity -- 16
polygonDef:attachPolygon( -- 17
    { -- 17
        Vec2(60, 0), -- 18
        Vec2(30, -30), -- 19
        Vec2(-30, -30), -- 20
        Vec2(-60, 0), -- 21
        Vec2(-30, 30), -- 22
        Vec2(30, 30) -- 23
    }, -- 23
    1, -- 24
    0.4, -- 24
    0.4 -- 24
) -- 24
local diskDef = BodyDef() -- 26
diskDef.type = "Dynamic" -- 27
diskDef.linearAcceleration = gravity -- 28
diskDef:attachDisk(60, 1, 0.4, 0.4) -- 29
local world = PhysicsWorld() -- 31
world.y = -200 -- 32
world:setShouldContact(groupZero, groupOne, false) -- 33
world:setShouldContact(groupZero, groupTwo, true) -- 34
world:setShouldContact(groupOne, groupTwo, true) -- 35
world.showDebug = true -- 36
local body = Body(terrainDef, world, Vec2.zero) -- 38
body.group = groupTwo -- 39
world:addChild(body) -- 40
local bodyP = Body( -- 42
    polygonDef, -- 42
    world, -- 42
    Vec2(0, 500), -- 42
    15 -- 42
) -- 42
bodyP.group = groupOne -- 43
world:addChild(bodyP) -- 44
local bodyD = Body( -- 46
    diskDef, -- 46
    world, -- 46
    Vec2(50, 800) -- 46
) -- 46
bodyD.group = groupZero -- 47
bodyD.angularRate = 90 -- 48
world:addChild(bodyD) -- 49
local windowFlags = { -- 51
    "NoDecoration", -- 52
    "AlwaysAutoResize", -- 53
    "NoSavedSettings", -- 54
    "NoFocusOnAppearing", -- 55
    "NoNav", -- 56
    "NoMove" -- 57
} -- 57
threadLoop(function() -- 59
    local ____App_visualSize_0 = App.visualSize -- 60
    local width = ____App_visualSize_0.width -- 60
    ImGui.SetNextWindowBgAlpha(0.35) -- 61
    ImGui.SetNextWindowPos( -- 62
        Vec2(width - 10, 10), -- 62
        "Always", -- 62
        Vec2(1, 0) -- 62
    ) -- 62
    ImGui.SetNextWindowSize( -- 63
        Vec2(240, 0), -- 63
        "FirstUseEver" -- 63
    ) -- 63
    ImGui.Begin( -- 64
        "Body", -- 64
        windowFlags, -- 64
        function() -- 64
            ImGui.Text("Body") -- 65
            ImGui.Separator() -- 66
            ImGui.TextWrapped("Basic usage to create physics bodies!") -- 67
        end -- 64
    ) -- 64
    return false -- 69
end) -- 59
return ____exports -- 59