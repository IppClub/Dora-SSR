-- [ts]: Entity MoveTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____dora = require("dora") -- 4
local App = ____dora.App -- 4
local Ease = ____dora.Ease -- 4
local Entity = ____dora.Entity -- 4
local Event = ____dora.Event -- 4
local Group = ____dora.Group -- 4
local Node = ____dora.Node -- 4
local Observer = ____dora.Observer -- 4
local Roll = ____dora.Roll -- 4
local Scale = ____dora.Scale -- 4
local Sequence = ____dora.Sequence -- 4
local Sprite = ____dora.Sprite -- 4
local Vec2 = ____dora.Vec2 -- 4
local tolua = ____dora.tolua -- 4
local sceneGroup = Group({"scene"}) -- 6
local positionGroup = Group({"position"}) -- 7
local function toNode(self, item) -- 9
    return tolua.cast(item, "Node") -- 10
end -- 9
Observer("Add", {"scene"}):watch(function(_, scene) -- 13
    scene.touchEnabled = true -- 14
    scene:slot( -- 15
        "TapEnded", -- 15
        function(touch) -- 15
            local ____touch_0 = touch -- 16
            local location = ____touch_0.location -- 16
            positionGroup:each(function(entity) -- 17
                entity.target = location -- 18
                return false -- 19
            end) -- 17
        end -- 15
    ) -- 15
end) -- 13
Observer("Add", {"image"}):watch(function(entity, image) -- 24
    sceneGroup:each(function(e) -- 25
        local scene = toNode(nil, e.scene) -- 26
        if scene ~= nil then -- 26
            local sprite = Sprite(image) -- 28
            if sprite then -- 28
                sprite:addTo(scene) -- 30
                sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack)) -- 31
                entity.sprite = sprite -- 32
            end -- 32
            return true -- 34
        end -- 34
        return false -- 36
    end) -- 25
end) -- 24
Observer("Remove", {"sprite"}):watch(function(entity) -- 40
    local sprite = toNode(nil, entity.oldValues.sprite) -- 41
    if sprite ~= nil then -- 41
        sprite:removeFromParent() -- 42
    end -- 42
end) -- 40
Observer("Remove", {"target"}):watch(function(entity) -- 45
    print("remove target from entity " .. tostring(entity.index)) -- 46
end) -- 45
Group({"position", "direction", "speed", "target"}):watch(function(entity, position, _direction, speed, target) -- 49
    if target:equals(position) then -- 49
        return -- 51
    end -- 51
    local dir = target:sub(position):normalize() -- 52
    local angle = math.deg(math.atan(dir.x, dir.y)) -- 53
    local newPos = position:add(dir:mul(speed)) -- 54
    newPos = newPos:clamp(position, target) -- 55
    entity.position = newPos -- 56
    entity.direction = angle -- 57
    if newPos:equals(target) then -- 57
        entity.target = nil -- 59
    end -- 59
end) -- 50
Observer("AddOrChange", {"position", "direction", "sprite"}):watch(function(entity, position, direction, sprite) -- 63
    sprite.position = position -- 65
    local ____entity_oldValues_direction_3 = entity.oldValues.direction -- 66
    if ____entity_oldValues_direction_3 == nil then -- 66
        ____entity_oldValues_direction_3 = sprite.angle -- 66
    end -- 66
    local lastDirection = ____entity_oldValues_direction_3 -- 66
    if type(lastDirection) == "number" then -- 66
        if math.abs(direction - lastDirection) > 1 then -- 66
            sprite:runAction(Roll(0.3, lastDirection, direction)) -- 69
        end -- 69
    end -- 69
end) -- 64
Entity({scene = Node()}) -- 81
local def = {image = "Image/logo.png", position = Vec2.zero, direction = 45, speed = 4} -- 83
Entity(def) -- 89
def = { -- 91
    image = "Image/logo.png", -- 92
    position = Vec2(-100, 200), -- 93
    direction = 90, -- 94
    speed = 10 -- 95
} -- 95
Entity(def) -- 97
local windowFlags = { -- 99
    "NoDecoration", -- 100
    "AlwaysAutoResize", -- 101
    "NoSavedSettings", -- 102
    "NoFocusOnAppearing", -- 103
    "NoNav", -- 104
    "NoMove" -- 105
} -- 105
Observer("Add", {"scene"}):watch(function(entity) -- 107
    local scene = toNode(nil, entity.scene) -- 108
    if scene ~= nil then -- 108
        scene:schedule(function() -- 110
            local ____App_visualSize_4 = App.visualSize -- 111
            local width = ____App_visualSize_4.width -- 111
            ImGui.SetNextWindowBgAlpha(0.35) -- 112
            ImGui.SetNextWindowPos( -- 113
                Vec2(width - 10, 10), -- 113
                "Always", -- 113
                Vec2(1, 0) -- 113
            ) -- 113
            ImGui.SetNextWindowSize( -- 114
                Vec2(240, 0), -- 114
                "FirstUseEver" -- 114
            ) -- 114
            ImGui.Begin( -- 115
                "ECS System", -- 115
                windowFlags, -- 115
                function() -- 115
                    ImGui.Text("ECS System (Typescript)") -- 116
                    ImGui.Separator() -- 117
                    ImGui.TextWrapped("Tap any place to move entities.") -- 118
                    if ImGui.Button("Create Random Entity") then -- 118
                        local def = { -- 120
                            image = "Image/logo.png", -- 121
                            position = Vec2( -- 122
                                6 * math.random(1, 100), -- 122
                                6 * math.random(1, 100) -- 122
                            ), -- 122
                            direction = 1 * math.random(0, 360), -- 123
                            speed = 1 * math.random(1, 20) -- 124
                        } -- 124
                        Entity(def) -- 126
                    end -- 126
                    if ImGui.Button("Destroy An Entity") then -- 126
                        Group({"sprite", "position"}):each(function(e) -- 129
                            e.position = nil -- 130
                            local sprite = toNode(nil, e.sprite) -- 131
                            if sprite ~= nil then -- 131
                                sprite:runAction(Sequence( -- 133
                                    Scale(0.5, 0.5, 0, Ease.InBack), -- 135
                                    Event("Destroy") -- 136
                                )) -- 136
                                sprite:slot( -- 139
                                    "Destroy", -- 139
                                    function() -- 139
                                        e:destroy() -- 140
                                    end -- 139
                                ) -- 139
                            end -- 139
                            return true -- 143
                        end) -- 129
                    end -- 129
                end -- 115
            ) -- 115
            return false -- 147
        end) -- 110
    end -- 110
end) -- 107
return ____exports -- 107