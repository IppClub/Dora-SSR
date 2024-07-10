-- [tsx]: ExcelTestTSX.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Platformer = require("Platformer") -- 3
local Data = ____Platformer.Data -- 3
local PlatformWorld = ____Platformer.PlatformWorld -- 3
local Unit = ____Platformer.Unit -- 3
local UnitAction = ____Platformer.UnitAction -- 3
local ____Dora = require("Dora") -- 4
local App = ____Dora.App -- 4
local Color = ____Dora.Color -- 4
local Color3 = ____Dora.Color3 -- 4
local Dictionary = ____Dora.Dictionary -- 4
local Rect = ____Dora.Rect -- 4
local Size = ____Dora.Size -- 4
local Vec2 = ____Dora.Vec2 -- 4
local View = ____Dora.View -- 4
local loop = ____Dora.loop -- 4
local once = ____Dora.once -- 4
local sleep = ____Dora.sleep -- 4
local Array = ____Dora.Array -- 4
local Observer = ____Dora.Observer -- 4
local Sprite = ____Dora.Sprite -- 4
local Spawn = ____Dora.Spawn -- 4
local Ease = ____Dora.Ease -- 4
local Y = ____Dora.Y -- 4
local tolua = ____Dora.tolua -- 4
local Scale = ____Dora.Scale -- 4
local Opacity = ____Dora.Opacity -- 4
local Content = ____Dora.Content -- 4
local Group = ____Dora.Group -- 4
local Entity = ____Dora.Entity -- 4
local Director = ____Dora.Director -- 4
local Keyboard = ____Dora.Keyboard -- 4
local ____PlatformerX = require("PlatformerX") -- 5
local DecisionTree = ____PlatformerX.DecisionTree -- 5
local toAI = ____PlatformerX.toAI -- 5
local ____Utils = require("Utils") -- 279
local Struct = ____Utils.Struct -- 279
local CircleButtonCreate = require("UI.Control.Basic.CircleButton") -- 329
local ImGui = require("ImGui") -- 331
local TerrainLayer = 0 -- 7
local PlayerLayer = 1 -- 8
local ItemLayer = 2 -- 9
local PlayerGroup = Data.groupFirstPlayer -- 11
local ItemGroup = Data.groupFirstPlayer + 1 -- 12
local TerrainGroup = Data.groupTerrain -- 13
Data:setShouldContact(PlayerGroup, ItemGroup, true) -- 15
local themeColor = App.themeColor -- 17
local color = themeColor:toARGB() -- 18
local DesignWidth = 1500 -- 19
local world = PlatformWorld() -- 21
world.camera.boundary = Rect(-1250, -500, 2500, 1000) -- 22
world.camera.followRatio = Vec2(0.02, 0.02) -- 23
world.camera.zoom = View.size.width / DesignWidth -- 24
world:gslot( -- 25
    "AppSizeChanged", -- 25
    function() -- 25
        world.camera.zoom = View.size.width / DesignWidth -- 26
    end -- 25
) -- 25
local function RectShape(self, props) -- 37
    local x = props.x or 0 -- 38
    local y = props.y or 0 -- 39
    local color = Color3(props.color) -- 40
    local fillColor = Color(color, 102):toARGB() -- 41
    local borderColor = Color(color, 255):toARGB() -- 42
    return React:createElement("rect-shape", { -- 43
        centerX = x, -- 43
        centerY = y, -- 43
        width = props.width, -- 43
        height = props.height, -- 43
        fillColor = fillColor, -- 43
        borderColor = borderColor, -- 43
        borderWidth = 1 -- 43
    }) -- 43
end -- 37
local terrain = toNode(React:createElement( -- 54
    "body", -- 54
    {type = "Static", world = world, order = TerrainLayer, group = TerrainGroup}, -- 54
    React:createElement("rect-fixture", { -- 54
        centerY = -500, -- 54
        width = 2500, -- 54
        height = 10, -- 54
        friction = 1, -- 54
        restitution = 0 -- 54
    }), -- 54
    React:createElement("rect-fixture", { -- 54
        centerY = 500, -- 54
        width = 2500, -- 54
        height = 10, -- 54
        friction = 1, -- 54
        restitution = 0 -- 54
    }), -- 54
    React:createElement("rect-fixture", { -- 54
        centerX = 1250, -- 54
        width = 10, -- 54
        height = 2500, -- 54
        friction = 1, -- 54
        restitution = 0 -- 54
    }), -- 54
    React:createElement("rect-fixture", { -- 54
        centerX = -1250, -- 54
        width = 10, -- 54
        height = 2500, -- 54
        friction = 1, -- 54
        restitution = 0 -- 54
    }), -- 54
    React:createElement( -- 54
        "draw-node", -- 54
        nil, -- 54
        React:createElement(RectShape, {y = -500, width = 2500, height = 10, color = color}), -- 54
        React:createElement(RectShape, {x = 1250, width = 10, height = 1000, color = color}), -- 54
        React:createElement(RectShape, {x = -1250, width = 10, height = 1000, color = color}) -- 54
    ) -- 54
)) -- 54
if terrain ~= nil then -- 54
    terrain:addTo(world) -- 67
end -- 67
UnitAction:add( -- 69
    "idle", -- 69
    { -- 69
        priority = 1, -- 70
        reaction = 2, -- 71
        recovery = 0.2, -- 72
        available = function(____self) return ____self.onSurface end, -- 73
        create = function(____self) -- 74
            local ____self_2 = ____self -- 75
            local playable = ____self_2.playable -- 75
            playable.speed = 1 -- 76
            playable:play("idle", true) -- 77
            local playIdleSpecial = loop(function() -- 78
                sleep(3) -- 79
                sleep(playable:play("idle1")) -- 80
                playable:play("idle", true) -- 81
                return false -- 82
            end) -- 78
            ____self.data.playIdleSpecial = playIdleSpecial -- 84
            return function(owner) -- 85
                coroutine.resume(playIdleSpecial) -- 86
                return not owner.onSurface -- 87
            end -- 85
        end -- 74
    } -- 74
) -- 74
UnitAction:add( -- 92
    "move", -- 92
    { -- 92
        priority = 1, -- 93
        reaction = 2, -- 94
        recovery = 0.2, -- 95
        available = function(____self) return ____self.onSurface end, -- 96
        create = function(____self) -- 97
            local ____self_3 = ____self -- 98
            local playable = ____self_3.playable -- 98
            playable.speed = 1 -- 99
            playable:play("fmove", true) -- 100
            return function(____self, action) -- 101
                local ____action_4 = action -- 102
                local elapsedTime = ____action_4.elapsedTime -- 102
                local recovery = action.recovery * 2 -- 103
                local move = ____self.unitDef.move -- 104
                local moveSpeed = 1 -- 105
                if elapsedTime < recovery then -- 105
                    moveSpeed = math.min(elapsedTime / recovery, 1) -- 107
                end -- 107
                ____self.velocityX = moveSpeed * (____self.faceRight and move or -move) -- 109
                return not ____self.onSurface -- 110
            end -- 101
        end -- 97
    } -- 97
) -- 97
UnitAction:add( -- 115
    "jump", -- 115
    { -- 115
        priority = 3, -- 116
        reaction = 2, -- 117
        recovery = 0.1, -- 118
        queued = true, -- 119
        available = function(____self) return ____self.onSurface end, -- 120
        create = function(____self) -- 121
            local jump = ____self.unitDef.jump -- 122
            ____self.velocityY = jump -- 123
            return once(function() -- 124
                local ____self_5 = ____self -- 125
                local playable = ____self_5.playable -- 125
                playable.speed = 1 -- 126
                sleep(playable:play("jump", false)) -- 127
            end) -- 124
        end -- 121
    } -- 121
) -- 121
UnitAction:add( -- 132
    "fallOff", -- 132
    { -- 132
        priority = 2, -- 133
        reaction = -1, -- 134
        recovery = 0.3, -- 135
        available = function(____self) return not ____self.onSurface end, -- 136
        create = function(____self) -- 137
            if ____self.playable.current ~= "jumping" then -- 137
                local ____self_6 = ____self -- 139
                local playable = ____self_6.playable -- 139
                playable.speed = 1 -- 140
                playable:play("jumping", true) -- 141
            end -- 141
            return loop(function() -- 143
                if ____self.onSurface then -- 143
                    local ____self_7 = ____self -- 145
                    local playable = ____self_7.playable -- 145
                    playable.speed = 1 -- 146
                    sleep(playable:play("landing", false)) -- 147
                    return true -- 148
                end -- 148
                return false -- 150
            end) -- 143
        end -- 137
    } -- 137
) -- 137
local ____DecisionTree_8 = DecisionTree -- 155
local Selector = ____DecisionTree_8.Selector -- 155
local Match = ____DecisionTree_8.Match -- 155
local Action = ____DecisionTree_8.Action -- 155
Data.store["AI:playerControl"] = toAI(React:createElement( -- 157
    Selector, -- 158
    nil, -- 158
    React:createElement( -- 158
        Match, -- 159
        { -- 159
            desc = "fmove key down", -- 159
            onCheck = function(____self) -- 159
                local keyLeft = ____self.entity.keyLeft -- 160
                local keyRight = ____self.entity.keyRight -- 161
                return not (keyLeft and keyRight) and (keyLeft and ____self.faceRight or keyRight and not ____self.faceRight) -- 162
            end -- 159
        }, -- 159
        React:createElement(Action, {name = "turn"}) -- 159
    ), -- 159
    React:createElement( -- 159
        Match, -- 171
        { -- 171
            desc = "is falling", -- 171
            onCheck = function(____self) return not ____self.onSurface end -- 171
        }, -- 171
        React:createElement(Action, {name = "fallOff"}) -- 171
    ), -- 171
    React:createElement( -- 171
        Match, -- 175
        { -- 175
            desc = "jump key down", -- 175
            onCheck = function(____self) return ____self.entity.keyJump end -- 175
        }, -- 175
        React:createElement(Action, {name = "jump"}) -- 175
    ), -- 175
    React:createElement( -- 175
        Match, -- 179
        { -- 179
            desc = "fmove key down", -- 179
            onCheck = function(____self) return ____self.entity.keyLeft or ____self.entity.keyRight end -- 179
        }, -- 179
        React:createElement(Action, {name = "move"}) -- 179
    ), -- 179
    React:createElement(Action, {name = "idle"}) -- 179
)) -- 179
local unitDef = Dictionary() -- 187
unitDef.linearAcceleration = Vec2(0, -15) -- 188
unitDef.bodyType = "Dynamic" -- 189
unitDef.scale = 1 -- 190
unitDef.density = 1 -- 191
unitDef.friction = 1 -- 192
unitDef.restitution = 0 -- 193
unitDef.playable = "spine:Spine/moling" -- 194
unitDef.defaultFaceRight = true -- 195
unitDef.size = Size(60, 300) -- 196
unitDef.sensity = 0 -- 197
unitDef.move = 300 -- 198
unitDef.jump = 1000 -- 199
unitDef.detectDistance = 350 -- 200
unitDef.hp = 5 -- 201
unitDef.tag = "player" -- 202
unitDef.decisionTree = "AI:playerControl" -- 203
unitDef.actions = Array({ -- 204
    "idle", -- 205
    "turn", -- 206
    "move", -- 207
    "jump", -- 208
    "fallOff", -- 209
    "cancel" -- 210
}) -- 210
Observer("Add", {"player"}):watch(function(____self) -- 213
    local unit = Unit( -- 214
        unitDef, -- 214
        world, -- 214
        ____self, -- 214
        Vec2(300, -350) -- 214
    ) -- 214
    unit.order = PlayerLayer -- 215
    unit.group = PlayerGroup -- 216
    unit.playable.position = Vec2(0, -150) -- 217
    unit.playable:play("idle", true) -- 218
    world:addChild(unit) -- 219
    world.camera.followTarget = unit -- 220
    return false -- 221
end) -- 213
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 224
    local sprite = toNode(React:createElement( -- 225
        "sprite", -- 225
        {file = icon}, -- 225
        React:createElement( -- 225
            "loop", -- 225
            nil, -- 225
            React:createElement( -- 225
                "spawn", -- 225
                nil, -- 225
                React:createElement("angle-y", {time = 5, start = 0, stop = 360}), -- 225
                React:createElement( -- 225
                    "sequence", -- 225
                    nil, -- 225
                    React:createElement("move-y", {time = 2.5, start = 0, stop = 40, easing = Ease.OutQuad}), -- 225
                    React:createElement("move-y", {time = 2.5, start = 40, stop = 0, easing = Ease.InQuad}) -- 225
                ) -- 225
            ) -- 225
        ) -- 225
    )) -- 225
    if not sprite then -- 225
        return false -- 238
    end -- 238
    local body = toNode(React:createElement( -- 240
        "body", -- 240
        { -- 240
            type = "Dynamic", -- 240
            world = world, -- 240
            linearAcceleration = Vec2(0, -10), -- 240
            x = x, -- 240
            order = ItemLayer, -- 240
            group = ItemGroup -- 240
        }, -- 240
        React:createElement("rect-fixture", {width = sprite.width * 0.5, height = sprite.height}), -- 240
        React:createElement("rect-fixture", {sensorTag = 0, width = sprite.width, height = sprite.height}) -- 240
    )) -- 240
    if not body then -- 240
        return false -- 248
    end -- 248
    local itemBody = body -- 250
    body:addChild(sprite) -- 251
    body:slot( -- 252
        "BodyEnter", -- 252
        function(item) -- 252
            if tolua.type(item) == "Platformer::Unit" then -- 252
                ____self.picked = true -- 254
                itemBody.group = Data.groupHide -- 255
                itemBody:schedule(once(function() -- 256
                    sleep(sprite:runAction(Spawn( -- 257
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 258
                        Opacity(0.2, 1, 0) -- 259
                    ))) -- 259
                    ____self.body = nil -- 261
                end)) -- 256
            end -- 256
        end -- 252
    ) -- 252
    world:addChild(body) -- 266
    ____self.body = body -- 267
    return false -- 268
end) -- 224
Observer("Remove", {"body"}):watch(function(____self) -- 271
    local body = tolua.cast(____self.oldValues.body, "Body") -- 272
    if body ~= nil then -- 272
        body:removeFromParent() -- 274
    end -- 274
    return false -- 276
end) -- 271
local function loadExcel() -- 300
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 301
    if xlsx ~= nil then -- 301
        local its = xlsx.items -- 303
        local names = its[2] -- 304
        table.remove(names, 1) -- 305
        if not Struct:has("Item") then -- 305
            Struct.Item(names) -- 307
        end -- 307
        Group({"item"}):each(function(e) -- 309
            e:destroy() -- 310
            return false -- 311
        end) -- 309
        do -- 309
            local i = 2 -- 313
            while i < #its do -- 313
                local st = Struct:load(its[i + 1]) -- 314
                local item = { -- 315
                    name = st.Name, -- 316
                    no = st.No, -- 317
                    x = st.X, -- 318
                    num = st.Num, -- 319
                    icon = st.Icon, -- 320
                    desc = st.Desc, -- 321
                    item = true -- 322
                } -- 322
                Entity(item) -- 324
                i = i + 1 -- 313
            end -- 313
        end -- 313
    end -- 313
end -- 300
local keyboardEnabled = true -- 333
local playerGroup = Group({"player"}) -- 335
local function updatePlayerControl(key, flag, vpad) -- 336
    if keyboardEnabled and vpad then -- 336
        keyboardEnabled = false -- 338
    end -- 338
    playerGroup:each(function(____self) -- 340
        ____self[key] = flag -- 341
        return false -- 342
    end) -- 340
end -- 336
local function CircleButton(self, props) -- 350
    return React:createElement( -- 351
        "custom-node", -- 351
        __TS__ObjectAssign( -- 351
            {onCreate = function() return CircleButtonCreate({text = props.text, radius = 60, fontSize = 36}) end}, -- 351
            props -- 355
        ) -- 355
    ) -- 355
end -- 350
local ui = toNode(React:createElement( -- 358
    "align-node", -- 358
    { -- 358
        windowRoot = true, -- 358
        style = {flexDirection = "column-reverse"}, -- 358
        onButtonDown = function(id, buttonName) -- 358
            if id ~= 0 then -- 358
                return -- 361
            end -- 361
            repeat -- 361
                local ____switch45 = buttonName -- 361
                local ____cond45 = ____switch45 == "dpleft" -- 361
                if ____cond45 then -- 361
                    updatePlayerControl("keyLeft", true, true) -- 363
                    break -- 363
                end -- 363
                ____cond45 = ____cond45 or ____switch45 == "dpright" -- 363
                if ____cond45 then -- 363
                    updatePlayerControl("keyRight", true, true) -- 364
                    break -- 364
                end -- 364
                ____cond45 = ____cond45 or ____switch45 == "b" -- 364
                if ____cond45 then -- 364
                    updatePlayerControl("keyJump", true, true) -- 365
                    break -- 365
                end -- 365
            until true -- 365
        end, -- 360
        onButtonUp = function(id, buttonName) -- 360
            if id ~= 0 then -- 360
                return -- 369
            end -- 369
            repeat -- 369
                local ____switch48 = buttonName -- 369
                local ____cond48 = ____switch48 == "dpleft" -- 369
                if ____cond48 then -- 369
                    updatePlayerControl("keyLeft", false, true) -- 371
                    break -- 371
                end -- 371
                ____cond48 = ____cond48 or ____switch48 == "dpright" -- 371
                if ____cond48 then -- 371
                    updatePlayerControl("keyRight", false, true) -- 372
                    break -- 372
                end -- 372
                ____cond48 = ____cond48 or ____switch48 == "b" -- 372
                if ____cond48 then -- 372
                    updatePlayerControl("keyJump", false, true) -- 373
                    break -- 373
                end -- 373
            until true -- 373
        end -- 368
    }, -- 368
    React:createElement( -- 368
        "align-node", -- 368
        {style = {height = 60, justifyContent = "space-between", margin = {0, 20, 40}, flexDirection = "row"}}, -- 368
        React:createElement( -- 368
            "align-node", -- 368
            {style = {width = 130, height = 60}}, -- 368
            React:createElement( -- 368
                "menu", -- 368
                { -- 368
                    width = 250, -- 368
                    height = 120, -- 368
                    anchorX = 0, -- 368
                    anchorY = 0, -- 368
                    scaleX = 0.5, -- 368
                    scaleY = 0.5 -- 368
                }, -- 368
                React:createElement( -- 368
                    CircleButton, -- 379
                    { -- 379
                        text = "Left\n(a)", -- 379
                        anchorX = 0, -- 379
                        anchorY = 0, -- 379
                        onTapBegan = function() return updatePlayerControl("keyLeft", true, true) end, -- 379
                        onTapEnded = function() return updatePlayerControl("keyLeft", false, true) end -- 379
                    } -- 379
                ), -- 379
                React:createElement( -- 379
                    CircleButton, -- 384
                    { -- 384
                        text = "Right\n(a)", -- 384
                        x = 130, -- 384
                        anchorX = 0, -- 384
                        anchorY = 0, -- 384
                        onTapBegan = function() return updatePlayerControl("keyRight", true, true) end, -- 384
                        onTapEnded = function() return updatePlayerControl("keyRight", false, true) end -- 384
                    } -- 384
                ) -- 384
            ) -- 384
        ), -- 384
        React:createElement( -- 384
            "align-node", -- 384
            {style = {width = 60, height = 60}}, -- 384
            React:createElement( -- 384
                "menu", -- 384
                { -- 384
                    width = 120, -- 384
                    height = 120, -- 384
                    anchorX = 0, -- 384
                    anchorY = 0, -- 384
                    scaleX = 0.5, -- 384
                    scaleY = 0.5 -- 384
                }, -- 384
                React:createElement( -- 384
                    CircleButton, -- 393
                    { -- 393
                        text = "Jump\n(j)", -- 393
                        anchorX = 0, -- 393
                        anchorY = 0, -- 393
                        onTapBegan = function() return updatePlayerControl("keyJump", true, true) end, -- 393
                        onTapEnded = function() return updatePlayerControl("keyJump", false, true) end -- 393
                    } -- 393
                ) -- 393
            ) -- 393
        ) -- 393
    ) -- 393
)) -- 393
if ui then -- 393
    ui:addTo(Director.ui) -- 405
    ui:schedule(function() -- 406
        local keyA = Keyboard:isKeyPressed("A") -- 407
        local keyD = Keyboard:isKeyPressed("D") -- 408
        local keyJ = Keyboard:isKeyPressed("J") -- 409
        if keyD or keyD or keyJ then -- 409
            keyboardEnabled = true -- 411
        end -- 411
        if not keyboardEnabled then -- 411
            return false -- 414
        end -- 414
        updatePlayerControl("keyLeft", keyA, false) -- 416
        updatePlayerControl("keyRight", keyD, false) -- 417
        updatePlayerControl("keyJump", keyJ, false) -- 418
        return false -- 419
    end) -- 406
end -- 406
local pickedItemGroup = Group({"picked"}) -- 423
local windowFlags = { -- 424
    "NoDecoration", -- 425
    "AlwaysAutoResize", -- 426
    "NoSavedSettings", -- 427
    "NoFocusOnAppearing", -- 428
    "NoNav", -- 429
    "NoMove" -- 430
} -- 430
Director.ui:schedule(function() -- 432
    local size = App.visualSize -- 433
    ImGui.SetNextWindowBgAlpha(0.35) -- 434
    ImGui.SetNextWindowPos( -- 435
        Vec2(size.width - 10, 10), -- 435
        "Always", -- 435
        Vec2(1, 0) -- 435
    ) -- 435
    ImGui.SetNextWindowSize( -- 436
        Vec2(100, 300), -- 436
        "FirstUseEver" -- 436
    ) -- 436
    ImGui.Begin( -- 437
        "BackPack", -- 437
        windowFlags, -- 437
        function() -- 437
            if ImGui.Button("重新加载Excel") then -- 437
                loadExcel() -- 439
            end -- 439
            ImGui.Separator() -- 441
            ImGui.Dummy(Vec2(100, 10)) -- 442
            ImGui.Text("背包 (TSX)") -- 443
            ImGui.Separator() -- 444
            ImGui.Columns(3, false) -- 445
            pickedItemGroup:each(function(e) -- 446
                local item = e -- 447
                if item.num > 0 then -- 447
                    if ImGui.ImageButton( -- 447
                        "item" .. tostring(item.no), -- 449
                        item.icon, -- 449
                        Vec2(50, 50) -- 449
                    ) then -- 449
                        item.num = item.num - 1 -- 450
                        local sprite = Sprite(item.icon) -- 451
                        if not sprite then -- 451
                            return false -- 452
                        end -- 452
                        sprite.scaleY = 0.5 -- 453
                        sprite.scaleX = 0.5 -- 453
                        sprite:perform(Spawn( -- 454
                            Opacity(1, 1, 0), -- 455
                            Y(1, 150, 250) -- 456
                        )) -- 456
                        local player = playerGroup:find(function() return true end) -- 458
                        if player ~= nil then -- 458
                            local unit = player.unit -- 460
                            unit:addChild(sprite) -- 461
                        end -- 461
                    end -- 461
                    if ImGui.IsItemHovered() then -- 461
                        ImGui.BeginTooltip(function() -- 465
                            ImGui.Text(item.name) -- 466
                            ImGui.TextColored(themeColor, "数量：") -- 467
                            ImGui.SameLine() -- 468
                            ImGui.Text(tostring(item.num)) -- 469
                            ImGui.TextColored(themeColor, "描述：") -- 470
                            ImGui.SameLine() -- 471
                            ImGui.Text(tostring(item.desc)) -- 472
                        end) -- 465
                    end -- 465
                    ImGui.NextColumn() -- 475
                end -- 475
                return false -- 477
            end) -- 446
        end -- 437
    ) -- 437
    return false -- 480
end) -- 432
Entity({player = true}) -- 483
loadExcel() -- 484
return ____exports -- 484