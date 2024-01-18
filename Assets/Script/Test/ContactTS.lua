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
local index = 0 -- 17
do -- 17
    local i = 0 -- 18
    while i < count + 1 do -- 18
        local angle = 2 * math.pi * i / count -- 19
        vertices[index + 1] = Vec2( -- 20
            radius * math.cos(angle), -- 20
            radius * math.sin(angle) -- 20
        ) -- 20
        index = index + 1 -- 21
        i = i + 1 -- 18
    end -- 18
end -- 18
terrainDef:attachChain(vertices, 0.4, 0) -- 23
terrainDef:attachDisk( -- 24
    Vec2(0, -270), -- 24
    30, -- 24
    1, -- 24
    0, -- 24
    1 -- 24
) -- 24
terrainDef:attachPolygon( -- 25
    Vec2(0, 80), -- 25
    120, -- 25
    30, -- 25
    0, -- 25
    1, -- 25
    0, -- 25
    1 -- 25
) -- 25
local terrain = Body(terrainDef, world) -- 27
terrain:addTo(world) -- 28
local drawNode = Line( -- 30
    { -- 30
        Vec2(-20, 0), -- 31
        Vec2(20, 0), -- 32
        Vec2.zero, -- 33
        Vec2(0, -20), -- 34
        Vec2(0, 20) -- 35
    }, -- 35
    App.themeColor -- 36
) -- 36
drawNode:addTo(world) -- 37
local diskDef = BodyDef() -- 39
diskDef.type = "Dynamic" -- 40
diskDef.linearAcceleration = gravity -- 41
diskDef:attachDisk(20, 5, 0.8, 1) -- 42
local disk = Body( -- 44
    diskDef, -- 44
    world, -- 44
    Vec2(100, 200) -- 44
) -- 44
disk:addTo(world) -- 45
disk.angularRate = -1800 -- 46
disk.receivingContact = true -- 47
disk:slot( -- 48
    "ContactStart", -- 48
    function(_, point) -- 48
        drawNode.position = point -- 49
        if label ~= nil then -- 49
            label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y) -- 51
        end -- 51
    end -- 48
) -- 48
local windowFlags = { -- 54
    "NoDecoration", -- 55
    "AlwaysAutoResize", -- 56
    "NoSavedSettings", -- 57
    "NoFocusOnAppearing", -- 58
    "NoNav", -- 59
    "NoMove" -- 60
} -- 60
local receivingContact = disk.receivingContact -- 62
threadLoop(function() -- 63
    local ____App_visualSize_2 = App.visualSize -- 64
    local width = ____App_visualSize_2.width -- 64
    ImGui.SetNextWindowBgAlpha(0.35) -- 65
    ImGui.SetNextWindowPos( -- 66
        Vec2(width - 10, 10), -- 66
        "Always", -- 66
        Vec2(1, 0) -- 66
    ) -- 66
    ImGui.SetNextWindowSize( -- 67
        Vec2(240, 0), -- 67
        "FirstUseEver" -- 67
    ) -- 67
    ImGui.Begin( -- 68
        "Contact", -- 68
        windowFlags, -- 68
        function() -- 68
            ImGui.Text("Contact") -- 69
            ImGui.Separator() -- 70
            ImGui.TextWrapped("Receive events when physics bodies contact.") -- 71
            local changed = false -- 72
            changed, receivingContact = ImGui.Checkbox("Receiving Contact", receivingContact) -- 73
            if changed then -- 73
                disk.receivingContact = receivingContact -- 75
                if label ~= nil then -- 75
                    label.text = "" -- 76
                end -- 76
            end -- 76
        end -- 68
    ) -- 68
    return false -- 79
end) -- 63
return ____exports -- 63