-- [ts]: Entity MoveTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Ease = ____dora.Ease -- 3
local Entity = ____dora.Entity -- 3
local Event = ____dora.Event -- 3
local Group = ____dora.Group -- 3
local Node = ____dora.Node -- 3
local Observer = ____dora.Observer -- 3
local Roll = ____dora.Roll -- 3
local Scale = ____dora.Scale -- 3
local Sequence = ____dora.Sequence -- 3
local Sprite = ____dora.Sprite -- 3
local Vec2 = ____dora.Vec2 -- 3
local tolua = ____dora.tolua -- 3
local sceneGroup = Group({"scene"}) -- 5
local positionGroup = Group({"position"}) -- 6
local function toNode(self, item) -- 8
    return tolua.cast(item, "Node") -- 9
end -- 8
Observer("Add", {"scene"}):watch(function(_, scene) -- 12
    scene.touchEnabled = true -- 13
    scene:slot( -- 14
        "TapEnded", -- 14
        function(touch) -- 14
            local ____touch_0 = touch -- 15
            local location = ____touch_0.location -- 15
            positionGroup:each(function(entity) -- 16
                entity.target = location -- 17
                return false -- 18
            end) -- 16
        end -- 14
    ) -- 14
end) -- 12
Observer("Add", {"image"}):watch(function(entity, image) -- 23
    sceneGroup:each(function(e) -- 24
        local scene = toNode(nil, e.scene) -- 25
        if scene ~= nil then -- 25
            local sprite = Sprite(image) -- 27
            sprite:addTo(scene) -- 28
            sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack)) -- 29
            entity.sprite = sprite -- 30
            return true -- 31
        end -- 31
        return false -- 33
    end) -- 24
end) -- 23
Observer("Remove", {"sprite"}):watch(function(entity) -- 37
    local sprite = toNode(nil, entity.oldValues.sprite) -- 38
    if sprite ~= nil then -- 38
        sprite:removeFromParent() -- 39
    end -- 39
end) -- 37
Observer("Remove", {"target"}):watch(function(entity) -- 42
    print("remove target from entity " .. tostring(entity.index)) -- 43
end) -- 42
Group({"position", "direction", "speed", "target"}):watch(function(entity, position, _direction, speed, target) -- 46
    if target:equals(position) then -- 46
        return -- 48
    end -- 48
    local dir = target:sub(position):normalize() -- 49
    local angle = math.deg(math.atan(dir.x, dir.y)) -- 50
    local newPos = position:add(dir:mul(speed)) -- 51
    newPos = newPos:clamp(position, target) -- 52
    entity.position = newPos -- 53
    entity.direction = angle -- 54
    if newPos:equals(target) then -- 54
        entity.target = nil -- 56
    end -- 56
end) -- 47
Observer("AddOrChange", {"position", "direction", "sprite"}):watch(function(entity, position, direction, sprite) -- 60
    sprite.position = position -- 62
    local ____entity_oldValues_direction_3 = entity.oldValues.direction -- 63
    if ____entity_oldValues_direction_3 == nil then -- 63
        ____entity_oldValues_direction_3 = sprite.angle -- 63
    end -- 63
    local lastDirection = ____entity_oldValues_direction_3 -- 63
    if type(lastDirection) == "number" then -- 63
        if math.abs(direction - lastDirection) > 1 then -- 63
            sprite:runAction(Roll(0.3, lastDirection, direction)) -- 66
        end -- 66
    end -- 66
end) -- 61
Entity({scene = Node()}) -- 78
local def = {image = "Image/logo.png", position = Vec2.zero, direction = 45, speed = 4} -- 80
Entity(def) -- 86
def = { -- 88
    image = "Image/logo.png", -- 89
    position = Vec2(-100, 200), -- 90
    direction = 90, -- 91
    speed = 10 -- 92
} -- 92
Entity(def) -- 94
local windowFlags = { -- 96
    "NoDecoration", -- 97
    "AlwaysAutoResize", -- 98
    "NoSavedSettings", -- 99
    "NoFocusOnAppearing", -- 100
    "NoNav", -- 101
    "NoMove" -- 102
} -- 102
Observer("Add", {"scene"}):watch(function(entity) -- 104
    local scene = toNode(nil, entity.scene) -- 105
    if scene ~= nil then -- 105
        scene:schedule(function() -- 107
            local ____App_visualSize_4 = App.visualSize -- 108
            local width = ____App_visualSize_4.width -- 108
            ImGui.SetNextWindowBgAlpha(0.35) -- 109
            ImGui.SetNextWindowPos( -- 110
                Vec2(width - 10, 10), -- 110
                "Always", -- 110
                Vec2(1, 0) -- 110
            ) -- 110
            ImGui.SetNextWindowSize( -- 111
                Vec2(240, 0), -- 111
                "FirstUseEver" -- 111
            ) -- 111
            ImGui.Begin( -- 112
                "ECS System", -- 112
                windowFlags, -- 112
                function() -- 112
                    ImGui.Text("ECS System") -- 113
                    ImGui.Separator() -- 114
                    ImGui.TextWrapped("Tap any place to move entities.") -- 115
                    if ImGui.Button("Create Random Entity") then -- 115
                        local def = { -- 117
                            image = "Image/logo.png", -- 118
                            position = Vec2( -- 119
                                6 * math.random(1, 100), -- 119
                                6 * math.random(1, 100) -- 119
                            ), -- 119
                            direction = 1 * math.random(0, 360), -- 120
                            speed = 1 * math.random(1, 20) -- 121
                        } -- 121
                        Entity(def) -- 123
                    end -- 123
                    if ImGui.Button("Destroy An Entity") then -- 123
                        Group({"sprite", "position"}):each(function(e) -- 126
                            e.position = nil -- 127
                            local sprite = toNode(nil, e.sprite) -- 128
                            if sprite ~= nil then -- 128
                                sprite:runAction(Sequence( -- 130
                                    Scale(0.5, 0.5, 0, Ease.InBack), -- 132
                                    Event("Destroy") -- 133
                                )) -- 133
                                sprite:slot( -- 136
                                    "Destroy", -- 136
                                    function() -- 136
                                        e:destroy() -- 137
                                    end -- 136
                                ) -- 136
                            end -- 136
                            return true -- 140
                        end) -- 126
                    end -- 126
                end -- 112
            ) -- 112
            return false -- 144
        end) -- 107
    end -- 107
end) -- 104
return ____exports -- 104