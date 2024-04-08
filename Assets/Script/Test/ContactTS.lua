-- [ts]: ContactTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____dora = require("dora") -- 4
local App = ____dora.App -- 4
local Body = ____dora.Body -- 4
local BodyDef = ____dora.BodyDef -- 4
local Label = ____dora.Label -- 4
local Line = ____dora.Line -- 4
local PhysicsWorld = ____dora.PhysicsWorld -- 4
local Vec2 = ____dora.Vec2 -- 4
local threadLoop = ____dora.threadLoop -- 4
local gravity = Vec2(0, -10) -- 6
local world = PhysicsWorld() -- 8
world:setShouldContact(0, 0, true) -- 9
world.showDebug = true -- 10
local ____opt_0 = Label("sarasa-mono-sc-regular", 30) -- 10
local label = ____opt_0 and ____opt_0:addTo(world) -- 12
local terrainDef = BodyDef() -- 14
local count = 50 -- 15
local radius = 300 -- 16
local vertices = {} -- 17
for i = 0, count + 1 do -- 17
    local angle = 2 * math.pi * i / count -- 19
    vertices[#vertices + 1] = Vec2( -- 20
        radius * math.cos(angle), -- 20
        radius * math.sin(angle) -- 20
    ) -- 20
end -- 20
terrainDef:attachChain(vertices, 0.4, 0) -- 22
terrainDef:attachDisk( -- 23
    Vec2(0, -270), -- 23
    30, -- 23
    1, -- 23
    0, -- 23
    1 -- 23
) -- 23
terrainDef:attachPolygon( -- 24
    Vec2(0, 80), -- 24
    120, -- 24
    30, -- 24
    0, -- 24
    1, -- 24
    0, -- 24
    1 -- 24
) -- 24
local terrain = Body(terrainDef, world) -- 26
terrain:addTo(world) -- 27
local drawNode = Line( -- 29
    { -- 29
        Vec2(-20, 0), -- 30
        Vec2(20, 0), -- 31
        Vec2.zero, -- 32
        Vec2(0, -20), -- 33
        Vec2(0, 20) -- 34
    }, -- 34
    App.themeColor -- 35
) -- 35
drawNode:addTo(world) -- 36
local diskDef = BodyDef() -- 38
diskDef.type = "Dynamic" -- 39
diskDef.linearAcceleration = gravity -- 40
diskDef:attachDisk(20, 5, 0.8, 1) -- 41
local disk = Body( -- 43
    diskDef, -- 43
    world, -- 43
    Vec2(100, 200) -- 43
) -- 43
disk:addTo(world) -- 44
disk.angularRate = -1800 -- 45
disk.receivingContact = true -- 46
disk:slot( -- 47
    "ContactStart", -- 47
    function(_, point) -- 47
        drawNode.position = point -- 48
        if label ~= nil then -- 48
            label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y) -- 50
        end -- 50
    end -- 47
) -- 47
local windowFlags = { -- 53
    "NoDecoration", -- 54
    "AlwaysAutoResize", -- 55
    "NoSavedSettings", -- 56
    "NoFocusOnAppearing", -- 57
    "NoNav", -- 58
    "NoMove" -- 59
} -- 59
local receivingContact = disk.receivingContact -- 61
threadLoop(function() -- 62
    local ____App_visualSize_2 = App.visualSize -- 63
    local width = ____App_visualSize_2.width -- 63
    ImGui.SetNextWindowBgAlpha(0.35) -- 64
    ImGui.SetNextWindowPos( -- 65
        Vec2(width - 10, 10), -- 65
        "Always", -- 65
        Vec2(1, 0) -- 65
    ) -- 65
    ImGui.SetNextWindowSize( -- 66
        Vec2(240, 0), -- 66
        "FirstUseEver" -- 66
    ) -- 66
    ImGui.Begin( -- 67
        "Contact", -- 67
        windowFlags, -- 67
        function() -- 67
            ImGui.Text("Contact (Typescript)") -- 68
            ImGui.Separator() -- 69
            ImGui.TextWrapped("Receive events when physics bodies contact.") -- 70
            local changed = false -- 71
            changed, receivingContact = ImGui.Checkbox("Receiving Contact", receivingContact) -- 72
            if changed then -- 72
                disk.receivingContact = receivingContact -- 74
                if label ~= nil then -- 74
                    label.text = "" -- 75
                end -- 75
            end -- 75
        end -- 67
    ) -- 67
    return false -- 78
end) -- 62
return ____exports -- 62