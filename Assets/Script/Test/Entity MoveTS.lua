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
            if sprite then -- 27
                sprite:addTo(scene) -- 29
                sprite:runAction(Scale(0.5, 0, 0.5, Ease.OutBack)) -- 30
                entity.sprite = sprite -- 31
            end -- 31
            return true -- 33
        end -- 33
        return false -- 35
    end) -- 24
end) -- 23
Observer("Remove", {"sprite"}):watch(function(entity) -- 39
    local sprite = toNode(nil, entity.oldValues.sprite) -- 40
    if sprite ~= nil then -- 40
        sprite:removeFromParent() -- 41
    end -- 41
end) -- 39
Observer("Remove", {"target"}):watch(function(entity) -- 44
    print("remove target from entity " .. tostring(entity.index)) -- 45
end) -- 44
Group({"position", "direction", "speed", "target"}):watch(function(entity, position, _direction, speed, target) -- 48
    if target:equals(position) then -- 48
        return -- 50
    end -- 50
    local dir = target:sub(position):normalize() -- 51
    local angle = math.deg(math.atan(dir.x, dir.y)) -- 52
    local newPos = position:add(dir:mul(speed)) -- 53
    newPos = newPos:clamp(position, target) -- 54
    entity.position = newPos -- 55
    entity.direction = angle -- 56
    if newPos:equals(target) then -- 56
        entity.target = nil -- 58
    end -- 58
end) -- 49
Observer("AddOrChange", {"position", "direction", "sprite"}):watch(function(entity, position, direction, sprite) -- 62
    sprite.position = position -- 64
    local ____entity_oldValues_direction_3 = entity.oldValues.direction -- 65
    if ____entity_oldValues_direction_3 == nil then -- 65
        ____entity_oldValues_direction_3 = sprite.angle -- 65
    end -- 65
    local lastDirection = ____entity_oldValues_direction_3 -- 65
    if type(lastDirection) == "number" then -- 65
        if math.abs(direction - lastDirection) > 1 then -- 65
            sprite:runAction(Roll(0.3, lastDirection, direction)) -- 68
        end -- 68
    end -- 68
end) -- 63
Entity({scene = Node()}) -- 80
local def = {image = "Image/logo.png", position = Vec2.zero, direction = 45, speed = 4} -- 82
Entity(def) -- 88
def = { -- 90
    image = "Image/logo.png", -- 91
    position = Vec2(-100, 200), -- 92
    direction = 90, -- 93
    speed = 10 -- 94
} -- 94
Entity(def) -- 96
local windowFlags = { -- 98
    "NoDecoration", -- 99
    "AlwaysAutoResize", -- 100
    "NoSavedSettings", -- 101
    "NoFocusOnAppearing", -- 102
    "NoNav", -- 103
    "NoMove" -- 104
} -- 104
Observer("Add", {"scene"}):watch(function(entity) -- 106
    local scene = toNode(nil, entity.scene) -- 107
    if scene ~= nil then -- 107
        scene:schedule(function() -- 109
            local ____App_visualSize_4 = App.visualSize -- 110
            local width = ____App_visualSize_4.width -- 110
            ImGui.SetNextWindowBgAlpha(0.35) -- 111
            ImGui.SetNextWindowPos( -- 112
                Vec2(width - 10, 10), -- 112
                "Always", -- 112
                Vec2(1, 0) -- 112
            ) -- 112
            ImGui.SetNextWindowSize( -- 113
                Vec2(240, 0), -- 113
                "FirstUseEver" -- 113
            ) -- 113
            ImGui.Begin( -- 114
                "ECS System", -- 114
                windowFlags, -- 114
                function() -- 114
                    ImGui.Text("ECS System") -- 115
                    ImGui.Separator() -- 116
                    ImGui.TextWrapped("Tap any place to move entities.") -- 117
                    if ImGui.Button("Create Random Entity") then -- 117
                        local def = { -- 119
                            image = "Image/logo.png", -- 120
                            position = Vec2( -- 121
                                6 * math.random(1, 100), -- 121
                                6 * math.random(1, 100) -- 121
                            ), -- 121
                            direction = 1 * math.random(0, 360), -- 122
                            speed = 1 * math.random(1, 20) -- 123
                        } -- 123
                        Entity(def) -- 125
                    end -- 125
                    if ImGui.Button("Destroy An Entity") then -- 125
                        Group({"sprite", "position"}):each(function(e) -- 128
                            e.position = nil -- 129
                            local sprite = toNode(nil, e.sprite) -- 130
                            if sprite ~= nil then -- 130
                                sprite:runAction(Sequence( -- 132
                                    Scale(0.5, 0.5, 0, Ease.InBack), -- 134
                                    Event("Destroy") -- 135
                                )) -- 135
                                sprite:slot( -- 138
                                    "Destroy", -- 138
                                    function() -- 138
                                        e:destroy() -- 139
                                    end -- 138
                                ) -- 138
                            end -- 138
                            return true -- 142
                        end) -- 128
                    end -- 128
                end -- 114
            ) -- 114
            return false -- 146
        end) -- 109
    end -- 109
end) -- 106
return ____exports -- 106