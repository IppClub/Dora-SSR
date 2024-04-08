-- [ts]: BodyTS.ts
local ____exports = {} -- 1
local ____dora = require("dora") -- 2
local App = ____dora.App -- 2
local Body = ____dora.Body -- 2
local BodyDef = ____dora.BodyDef -- 2
local PhysicsWorld = ____dora.PhysicsWorld -- 2
local Vec2 = ____dora.Vec2 -- 2
local threadLoop = ____dora.threadLoop -- 2
local ImGui = require("ImGui") -- 3
local gravity = Vec2(0, -10) -- 6
local groupZero = 0 -- 7
local groupOne = 1 -- 8
local groupTwo = 2 -- 9
local terrainDef = BodyDef() -- 11
terrainDef.type = "Static" -- 12
terrainDef:attachPolygon( -- 13
    800, -- 13
    10, -- 13
    1, -- 13
    0.8, -- 13
    0.2 -- 13
) -- 13
local polygonDef = BodyDef() -- 15
polygonDef.type = "Dynamic" -- 16
polygonDef.linearAcceleration = gravity -- 17
polygonDef:attachPolygon( -- 18
    { -- 18
        Vec2(60, 0), -- 19
        Vec2(30, -30), -- 20
        Vec2(-30, -30), -- 21
        Vec2(-60, 0), -- 22
        Vec2(-30, 30), -- 23
        Vec2(30, 30) -- 24
    }, -- 24
    1, -- 25
    0.4, -- 25
    0.4 -- 25
) -- 25
local diskDef = BodyDef() -- 27
diskDef.type = "Dynamic" -- 28
diskDef.linearAcceleration = gravity -- 29
diskDef:attachDisk(60, 1, 0.4, 0.4) -- 30
local world = PhysicsWorld() -- 32
world.y = -200 -- 33
world:setShouldContact(groupZero, groupOne, false) -- 34
world:setShouldContact(groupZero, groupTwo, true) -- 35
world:setShouldContact(groupOne, groupTwo, true) -- 36
world.showDebug = true -- 37
local body = Body(terrainDef, world, Vec2.zero) -- 39
body.group = groupTwo -- 40
world:addChild(body) -- 41
local bodyP = Body( -- 43
    polygonDef, -- 43
    world, -- 43
    Vec2(0, 500), -- 43
    15 -- 43
) -- 43
bodyP.group = groupOne -- 44
world:addChild(bodyP) -- 45
local bodyD = Body( -- 47
    diskDef, -- 47
    world, -- 47
    Vec2(50, 800) -- 47
) -- 47
bodyD.group = groupZero -- 48
bodyD.angularRate = 90 -- 49
world:addChild(bodyD) -- 50
local windowFlags = { -- 52
    "NoDecoration", -- 53
    "AlwaysAutoResize", -- 54
    "NoSavedSettings", -- 55
    "NoFocusOnAppearing", -- 56
    "NoNav", -- 57
    "NoMove" -- 58
} -- 58
threadLoop(function() -- 60
    local ____App_visualSize_0 = App.visualSize -- 61
    local width = ____App_visualSize_0.width -- 61
    ImGui.SetNextWindowBgAlpha(0.35) -- 62
    ImGui.SetNextWindowPos( -- 63
        Vec2(width - 10, 10), -- 63
        "Always", -- 63
        Vec2(1, 0) -- 63
    ) -- 63
    ImGui.SetNextWindowSize( -- 64
        Vec2(240, 0), -- 64
        "FirstUseEver" -- 64
    ) -- 64
    ImGui.Begin( -- 65
        "Body", -- 65
        windowFlags, -- 65
        function() -- 65
            ImGui.Text("Body (Typescript)") -- 66
            ImGui.Separator() -- 67
            ImGui.TextWrapped("Basic usage to create physics bodies!") -- 68
        end -- 65
    ) -- 65
    return false -- 70
end) -- 60
return ____exports -- 60