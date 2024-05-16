-- [ts]: Entity MoveTS.ts
local ____exports = {} -- 1
local ImGui = require("ImGui") -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Ease = ____Dora.Ease -- 4
local Entity = ____Dora.Entity -- 4
local Event = ____Dora.Event -- 4
local Group = ____Dora.Group -- 4
local Node = ____Dora.Node -- 4
local Observer = ____Dora.Observer -- 4
local Roll = ____Dora.Roll -- 4
local Scale = ____Dora.Scale -- 4
local Sequence = ____Dora.Sequence -- 4
local Sprite = ____Dora.Sprite -- 4
local Vec2 = ____Dora.Vec2 -- 4
local tolua = ____Dora.tolua -- 4
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
    return false -- 22
end) -- 13
Observer("Add", {"image"}):watch(function(entity, image) -- 25
    sceneGroup:each(function(e) -- 26
        local scene = toNode(nil, e.scene) -- 27
        if scene ~= nil then -- 27
            local sprite = Sprite(image) -- 29
            if sprite then -- 29
                sprite:addTo(scene) -- 31
                sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack)) -- 32
                entity.sprite = sprite -- 33
            end -- 33
            return true -- 35
        end -- 35
        return false -- 37
    end) -- 26
    return false -- 39
end) -- 25
Observer("Remove", {"sprite"}):watch(function(entity) -- 42
    local sprite = toNode(nil, entity.oldValues.sprite) -- 43
    if sprite ~= nil then -- 43
        sprite:removeFromParent() -- 44
    end -- 44
    return false -- 45
end) -- 42
Observer("Remove", {"target"}):watch(function(entity) -- 48
    print("remove target from entity " .. tostring(entity.index)) -- 49
    return false -- 50
end) -- 48
Group({"position", "direction", "speed", "target"}):watch(function(entity, position, _direction, speed, target) -- 53
    if target:equals(position) then -- 53
        return false -- 55
    end -- 55
    local dir = target:sub(position):normalize() -- 56
    local angle = math.deg(math.atan(dir.x, dir.y)) -- 57
    local newPos = position:add(dir:mul(speed)) -- 58
    newPos = newPos:clamp(position, target) -- 59
    entity.position = newPos -- 60
    entity.direction = angle -- 61
    if newPos:equals(target) then -- 61
        entity.target = nil -- 63
    end -- 63
    return false -- 65
end) -- 54
Observer("AddOrChange", {"position", "direction", "sprite"}):watch(function(entity, position, direction, sprite) -- 68
    sprite.position = position -- 70
    local ____entity_oldValues_direction_3 = entity.oldValues.direction -- 71
    if ____entity_oldValues_direction_3 == nil then -- 71
        ____entity_oldValues_direction_3 = sprite.angle -- 71
    end -- 71
    local lastDirection = ____entity_oldValues_direction_3 -- 71
    if type(lastDirection) == "number" then -- 71
        if math.abs(direction - lastDirection) > 1 then -- 71
            sprite:runAction(Roll(0.3, lastDirection, direction)) -- 74
        end -- 74
    end -- 74
    return false -- 77
end) -- 69
Entity({scene = Node()}) -- 87
local def = {image = "Image/logo.png", position = Vec2.zero, direction = 45, speed = 4} -- 89
Entity(def) -- 95
def = { -- 97
    image = "Image/logo.png", -- 98
    position = Vec2(-100, 200), -- 99
    direction = 90, -- 100
    speed = 10 -- 101
} -- 101
Entity(def) -- 103
local windowFlags = { -- 105
    "NoDecoration", -- 106
    "AlwaysAutoResize", -- 107
    "NoSavedSettings", -- 108
    "NoFocusOnAppearing", -- 109
    "NoNav", -- 110
    "NoMove" -- 111
} -- 111
Observer("Add", {"scene"}):watch(function(entity) -- 113
    local scene = toNode(nil, entity.scene) -- 114
    if scene ~= nil then -- 114
        scene:schedule(function() -- 116
            local ____App_visualSize_4 = App.visualSize -- 117
            local width = ____App_visualSize_4.width -- 117
            ImGui.SetNextWindowBgAlpha(0.35) -- 118
            ImGui.SetNextWindowPos( -- 119
                Vec2(width - 10, 10), -- 119
                "Always", -- 119
                Vec2(1, 0) -- 119
            ) -- 119
            ImGui.SetNextWindowSize( -- 120
                Vec2(240, 0), -- 120
                "FirstUseEver" -- 120
            ) -- 120
            ImGui.Begin( -- 121
                "ECS System", -- 121
                windowFlags, -- 121
                function() -- 121
                    ImGui.Text("ECS System (Typescript)") -- 122
                    ImGui.Separator() -- 123
                    ImGui.TextWrapped("Tap any place to move entities.") -- 124
                    if ImGui.Button("Create Random Entity") then -- 124
                        local def = { -- 126
                            image = "Image/logo.png", -- 127
                            position = Vec2( -- 128
                                6 * math.random(1, 100), -- 128
                                6 * math.random(1, 100) -- 128
                            ), -- 128
                            direction = 1 * math.random(0, 360), -- 129
                            speed = 1 * math.random(1, 20) -- 130
                        } -- 130
                        Entity(def) -- 132
                    end -- 132
                    if ImGui.Button("Destroy An Entity") then -- 132
                        Group({"sprite", "position"}):each(function(e) -- 135
                            e.position = nil -- 136
                            local sprite = toNode(nil, e.sprite) -- 137
                            if sprite ~= nil then -- 137
                                sprite:runAction(Sequence( -- 139
                                    Scale(0.5, 0.5, 0, Ease.InBack), -- 141
                                    Event("Destroy") -- 142
                                )) -- 142
                                sprite:slot( -- 145
                                    "Destroy", -- 145
                                    function() -- 145
                                        e:destroy() -- 146
                                    end -- 145
                                ) -- 145
                            end -- 145
                            return true -- 149
                        end) -- 135
                    end -- 135
                end -- 121
            ) -- 121
            return false -- 153
        end) -- 116
    end -- 116
    return false -- 156
end) -- 113
return ____exports -- 113