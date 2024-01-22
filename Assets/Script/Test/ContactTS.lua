-- [ts]: ContactTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Body = ____dora.Body -- 3
local BodyDef = ____dora.BodyDef -- 3
local Label = ____dora.Label -- 3
local Line = ____dora.Line -- 3
local PhysicsWorld = ____dora.PhysicsWorld -- 3
local Vec2 = ____dora.Vec2 -- 3
local threadLoop = ____dora.threadLoop -- 3
local gravity = Vec2(0, -10) -- 5
local world = PhysicsWorld() -- 7
world:setShouldContact(0, 0, true) -- 8
world.showDebug = true -- 9
local ____opt_0 = Label("sarasa-mono-sc-regular", 30) -- 9
local label = ____opt_0 and ____opt_0:addTo(world) -- 11
local terrainDef = BodyDef() -- 13
local count = 50 -- 14
local radius = 300 -- 15
local vertices = {} -- 16
for i = 0, count + 1 do -- 16
    local angle = 2 * math.pi * i / count -- 18
    vertices[#vertices + 1] = Vec2( -- 19
        radius * math.cos(angle), -- 19
        radius * math.sin(angle) -- 19
    ) -- 19
end -- 19
terrainDef:attachChain(vertices, 0.4, 0) -- 21
terrainDef:attachDisk( -- 22
    Vec2(0, -270), -- 22
    30, -- 22
    1, -- 22
    0, -- 22
    1 -- 22
) -- 22
terrainDef:attachPolygon( -- 23
    Vec2(0, 80), -- 23
    120, -- 23
    30, -- 23
    0, -- 23
    1, -- 23
    0, -- 23
    1 -- 23
) -- 23
local terrain = Body(terrainDef, world) -- 25
terrain:addTo(world) -- 26
local drawNode = Line( -- 28
    { -- 28
        Vec2(-20, 0), -- 29
        Vec2(20, 0), -- 30
        Vec2.zero, -- 31
        Vec2(0, -20), -- 32
        Vec2(0, 20) -- 33
    }, -- 33
    App.themeColor -- 34
) -- 34
drawNode:addTo(world) -- 35
local diskDef = BodyDef() -- 37
diskDef.type = "Dynamic" -- 38
diskDef.linearAcceleration = gravity -- 39
diskDef:attachDisk(20, 5, 0.8, 1) -- 40
local disk = Body( -- 42
    diskDef, -- 42
    world, -- 42
    Vec2(100, 200) -- 42
) -- 42
disk:addTo(world) -- 43
disk.angularRate = -1800 -- 44
disk.receivingContact = true -- 45
disk:slot( -- 46
    "ContactStart", -- 46
    function(_, point) -- 46
        drawNode.position = point -- 47
        if label ~= nil then -- 47
            label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y) -- 49
        end -- 49
    end -- 46
) -- 46
local windowFlags = { -- 52
    "NoDecoration", -- 53
    "AlwaysAutoResize", -- 54
    "NoSavedSettings", -- 55
    "NoFocusOnAppearing", -- 56
    "NoNav", -- 57
    "NoMove" -- 58
} -- 58
local receivingContact = disk.receivingContact -- 60
threadLoop(function() -- 61
    local ____App_visualSize_2 = App.visualSize -- 62
    local width = ____App_visualSize_2.width -- 62
    ImGui.SetNextWindowBgAlpha(0.35) -- 63
    ImGui.SetNextWindowPos( -- 64
        Vec2(width - 10, 10), -- 64
        "Always", -- 64
        Vec2(1, 0) -- 64
    ) -- 64
    ImGui.SetNextWindowSize( -- 65
        Vec2(240, 0), -- 65
        "FirstUseEver" -- 65
    ) -- 65
    ImGui.Begin( -- 66
        "Contact", -- 66
        windowFlags, -- 66
        function() -- 66
            ImGui.Text("Contact") -- 67
            ImGui.Separator() -- 68
            ImGui.TextWrapped("Receive events when physics bodies contact.") -- 69
            local changed = false -- 70
            changed, receivingContact = ImGui.Checkbox("Receiving Contact", receivingContact) -- 71
            if changed then -- 71
                disk.receivingContact = receivingContact -- 73
                if label ~= nil then -- 73
                    label.text = "" -- 74
                end -- 74
            end -- 74
        end -- 66
    ) -- 66
    return false -- 77
end) -- 61
return ____exports -- 61