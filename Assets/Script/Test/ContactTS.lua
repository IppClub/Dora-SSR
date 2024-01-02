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
local label = Label("sarasa-mono-sc-regular", 30) -- 11
label:addTo(world) -- 12
local terrainDef = BodyDef() -- 14
local count = 50 -- 15
local radius = 300 -- 16
local vertices = {} -- 17
local index = 0 -- 18
do -- 18
    local i = 0 -- 19
    while i < count + 1 do -- 19
        local angle = 2 * math.pi * i / count -- 20
        vertices[index + 1] = Vec2( -- 21
            radius * math.cos(angle), -- 21
            radius * math.sin(angle) -- 21
        ) -- 21
        index = index + 1 -- 22
        i = i + 1 -- 19
    end -- 19
end -- 19
terrainDef:attachChain(vertices, 0.4, 0) -- 24
terrainDef:attachDisk( -- 25
    Vec2(0, -270), -- 25
    30, -- 25
    1, -- 25
    0, -- 25
    1 -- 25
) -- 25
terrainDef:attachPolygon( -- 26
    Vec2(0, 80), -- 26
    120, -- 26
    30, -- 26
    0, -- 26
    1, -- 26
    0, -- 26
    1 -- 26
) -- 26
local terrain = Body(terrainDef, world) -- 28
terrain:addTo(world) -- 29
local drawNode = Line( -- 31
    { -- 31
        Vec2(-20, 0), -- 32
        Vec2(20, 0), -- 33
        Vec2.zero, -- 34
        Vec2(0, -20), -- 35
        Vec2(0, 20) -- 36
    }, -- 36
    App.themeColor -- 37
) -- 37
drawNode:addTo(world) -- 38
local diskDef = BodyDef() -- 40
diskDef.type = "Dynamic" -- 41
diskDef.linearAcceleration = gravity -- 42
diskDef:attachDisk(20, 5, 0.8, 1) -- 43
local disk = Body( -- 45
    diskDef, -- 45
    world, -- 45
    Vec2(100, 200) -- 45
) -- 45
disk:addTo(world) -- 46
disk.angularRate = -1800 -- 47
disk.receivingContact = true -- 48
disk:slot( -- 49
    "ContactStart", -- 49
    function(_, point) -- 49
        drawNode.position = point -- 50
        label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y) -- 51
    end -- 49
) -- 49
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
    local ____App_visualSize_0 = App.visualSize -- 64
    local width = ____App_visualSize_0.width -- 64
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
                label.text = "" -- 76
            end -- 76
        end -- 68
    ) -- 68
    return false -- 79
end) -- 63
return ____exports -- 63