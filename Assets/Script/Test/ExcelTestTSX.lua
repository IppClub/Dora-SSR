-- [tsx]: ExcelTestTSX.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____dora_2Dx = require("dora-x") -- 2
local React = ____dora_2Dx.React -- 2
local toNode = ____dora_2Dx.toNode -- 2
local useRef = ____dora_2Dx.useRef -- 2
local ____Platformer = require("Platformer") -- 3
local Data = ____Platformer.Data -- 3
local PlatformWorld = ____Platformer.PlatformWorld -- 3
local Unit = ____Platformer.Unit -- 3
local UnitAction = ____Platformer.UnitAction -- 3
local ____dora = require("dora") -- 4
local App = ____dora.App -- 4
local Color = ____dora.Color -- 4
local Color3 = ____dora.Color3 -- 4
local Dictionary = ____dora.Dictionary -- 4
local Rect = ____dora.Rect -- 4
local Size = ____dora.Size -- 4
local Vec2 = ____dora.Vec2 -- 4
local View = ____dora.View -- 4
local loop = ____dora.loop -- 4
local once = ____dora.once -- 4
local sleep = ____dora.sleep -- 4
local Array = ____dora.Array -- 4
local Observer = ____dora.Observer -- 4
local Sprite = ____dora.Sprite -- 4
local Spawn = ____dora.Spawn -- 4
local Ease = ____dora.Ease -- 4
local Y = ____dora.Y -- 4
local tolua = ____dora.tolua -- 4
local Scale = ____dora.Scale -- 4
local Opacity = ____dora.Opacity -- 4
local Content = ____dora.Content -- 4
local Group = ____dora.Group -- 4
local Entity = ____dora.Entity -- 4
local Director = ____dora.Director -- 4
local Keyboard = ____dora.Keyboard -- 4
local ____Platformer_2Dx = require("Platformer-x") -- 5
local DecisionTree = ____Platformer_2Dx.DecisionTree -- 5
local toAI = ____Platformer_2Dx.toAI -- 5
local ____Utils = require("Utils") -- 291
local Struct = ____Utils.Struct -- 291
local AlignNodeCreate = require("UI.Control.Basic.AlignNode") -- 341
local CircleButtonCreate = require("UI.Control.Basic.CircleButton") -- 342
local ImGui = require("ImGui") -- 345
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
    local hw = props.width / 2 -- 38
    local hh = props.height / 2 -- 39
    local x = props.x or 0 -- 40
    local y = props.y or 0 -- 41
    local color = Color3(props.color) -- 42
    local fillColor = Color(color, 102):toARGB() -- 43
    local borderColor = Color(color, 255):toARGB() -- 44
    return React:createElement( -- 45
        "polygon-shape", -- 45
        { -- 45
            verts = { -- 45
                Vec2(-hw + x, hh + y), -- 47
                Vec2(hw + x, hh + y), -- 48
                Vec2(hw + x, -hh + y), -- 49
                Vec2(-hw + x, -hh + y) -- 50
            }, -- 50
            fillColor = fillColor, -- 50
            borderColor = borderColor, -- 50
            borderWidth = 1 -- 50
        } -- 50
    ) -- 50
end -- 37
local terrain = toNode(React:createElement( -- 58
    "body", -- 58
    {type = "Static", world = world, order = TerrainLayer, group = TerrainGroup}, -- 58
    React:createElement("rect-fixture", { -- 58
        centerY = -500, -- 58
        width = 2500, -- 58
        height = 10, -- 58
        friction = 1, -- 58
        restitution = 0 -- 58
    }), -- 58
    React:createElement("rect-fixture", { -- 58
        centerY = 500, -- 58
        width = 2500, -- 58
        height = 10, -- 58
        friction = 1, -- 58
        restitution = 0 -- 58
    }), -- 58
    React:createElement("rect-fixture", { -- 58
        centerX = 1250, -- 58
        width = 10, -- 58
        height = 2500, -- 58
        friction = 1, -- 58
        restitution = 0 -- 58
    }), -- 58
    React:createElement("rect-fixture", { -- 58
        centerX = -1250, -- 58
        width = 10, -- 58
        height = 2500, -- 58
        friction = 1, -- 58
        restitution = 0 -- 58
    }), -- 58
    React:createElement( -- 58
        "draw-node", -- 58
        nil, -- 58
        React:createElement(RectShape, {y = -500, width = 2500, height = 10, color = color}), -- 58
        React:createElement(RectShape, {x = 1250, width = 10, height = 1000, color = color}), -- 58
        React:createElement(RectShape, {x = -1250, width = 10, height = 1000, color = color}) -- 58
    ) -- 58
)) -- 58
if terrain ~= nil then -- 58
    terrain:addTo(world) -- 71
end -- 71
UnitAction:add( -- 73
    "idle", -- 73
    { -- 73
        priority = 1, -- 74
        reaction = 2, -- 75
        recovery = 0.2, -- 76
        available = function(____self) return ____self.onSurface end, -- 77
        create = function(____self) -- 78
            local ____self_2 = ____self -- 79
            local playable = ____self_2.playable -- 79
            playable.speed = 1 -- 80
            playable:play("idle", true) -- 81
            local playIdleSpecial = loop(function() -- 82
                sleep(3) -- 83
                sleep(playable:play("idle1")) -- 84
                playable:play("idle", true) -- 85
                return false -- 86
            end) -- 82
            ____self.data.playIdleSpecial = playIdleSpecial -- 88
            return function(owner) -- 89
                coroutine.resume(playIdleSpecial) -- 90
                return not owner.onSurface -- 91
            end -- 89
        end -- 78
    } -- 78
) -- 78
UnitAction:add( -- 96
    "move", -- 96
    { -- 96
        priority = 1, -- 97
        reaction = 2, -- 98
        recovery = 0.2, -- 99
        available = function(____self) return ____self.onSurface end, -- 100
        create = function(____self) -- 101
            local ____self_3 = ____self -- 102
            local playable = ____self_3.playable -- 102
            playable.speed = 1 -- 103
            playable:play("fmove", true) -- 104
            return function(____self, action) -- 105
                local ____action_4 = action -- 106
                local elapsedTime = ____action_4.elapsedTime -- 106
                local recovery = action.recovery * 2 -- 107
                local move = ____self.unitDef.move -- 108
                local moveSpeed = 1 -- 109
                if elapsedTime < recovery then -- 109
                    moveSpeed = math.min(elapsedTime / recovery, 1) -- 111
                end -- 111
                ____self.velocityX = moveSpeed * (____self.faceRight and move or -move) -- 113
                return not ____self.onSurface -- 114
            end -- 105
        end -- 101
    } -- 101
) -- 101
UnitAction:add( -- 119
    "jump", -- 119
    { -- 119
        priority = 3, -- 120
        reaction = 2, -- 121
        recovery = 0.1, -- 122
        queued = true, -- 123
        available = function(____self) return ____self.onSurface end, -- 124
        create = function(____self) -- 125
            local jump = ____self.unitDef.jump -- 126
            ____self.velocityY = jump -- 127
            return once(function() -- 128
                local ____self_5 = ____self -- 129
                local playable = ____self_5.playable -- 129
                playable.speed = 1 -- 130
                sleep(playable:play("jump", false)) -- 131
            end) -- 128
        end -- 125
    } -- 125
) -- 125
UnitAction:add( -- 136
    "fallOff", -- 136
    { -- 136
        priority = 2, -- 137
        reaction = -1, -- 138
        recovery = 0.3, -- 139
        available = function(____self) return not ____self.onSurface end, -- 140
        create = function(____self) -- 141
            if ____self.playable.current ~= "jumping" then -- 141
                local ____self_6 = ____self -- 143
                local playable = ____self_6.playable -- 143
                playable.speed = 1 -- 144
                playable:play("jumping", true) -- 145
            end -- 145
            return loop(function() -- 147
                if ____self.onSurface then -- 147
                    local ____self_7 = ____self -- 149
                    local playable = ____self_7.playable -- 149
                    playable.speed = 1 -- 150
                    sleep(playable:play("landing", false)) -- 151
                    return true -- 152
                end -- 152
                return false -- 154
            end) -- 147
        end -- 141
    } -- 141
) -- 141
local ____DecisionTree_8 = DecisionTree -- 159
local Selector = ____DecisionTree_8.Selector -- 159
local Match = ____DecisionTree_8.Match -- 159
local Action = ____DecisionTree_8.Action -- 159
Data.store["AI:playerControl"] = toAI(React:createElement( -- 161
    Selector, -- 162
    nil, -- 162
    React:createElement( -- 162
        Match, -- 163
        { -- 163
            desc = "fmove key down", -- 163
            onCheck = function(____self) -- 163
                local keyLeft = ____self.entity.keyLeft -- 164
                local keyRight = ____self.entity.keyRight -- 165
                return not (keyLeft and keyRight) and (keyLeft and ____self.faceRight or keyRight and not ____self.faceRight) -- 166
            end -- 163
        }, -- 163
        React:createElement(Action, {name = "turn"}) -- 163
    ), -- 163
    React:createElement( -- 163
        Match, -- 175
        { -- 175
            desc = "is falling", -- 175
            onCheck = function(____self) return not ____self.onSurface end -- 175
        }, -- 175
        React:createElement(Action, {name = "fallOff"}) -- 175
    ), -- 175
    React:createElement( -- 175
        Match, -- 179
        { -- 179
            desc = "jump key down", -- 179
            onCheck = function(____self) return ____self.entity.keyJump end -- 179
        }, -- 179
        React:createElement(Action, {name = "jump"}) -- 179
    ), -- 179
    React:createElement( -- 179
        Match, -- 183
        { -- 183
            desc = "fmove key down", -- 183
            onCheck = function(____self) return ____self.entity.keyLeft or ____self.entity.keyRight end -- 183
        }, -- 183
        React:createElement(Action, {name = "move"}) -- 183
    ), -- 183
    React:createElement(Action, {name = "idle"}) -- 183
)) -- 183
local unitDef = Dictionary() -- 191
unitDef.linearAcceleration = Vec2(0, -15) -- 192
unitDef.bodyType = "Dynamic" -- 193
unitDef.scale = 1 -- 194
unitDef.density = 1 -- 195
unitDef.friction = 1 -- 196
unitDef.restitution = 0 -- 197
unitDef.playable = "spine:Spine/moling" -- 198
unitDef.defaultFaceRight = true -- 199
unitDef.size = Size(60, 300) -- 200
unitDef.sensity = 0 -- 201
unitDef.move = 300 -- 202
unitDef.jump = 1000 -- 203
unitDef.detectDistance = 350 -- 204
unitDef.hp = 5 -- 205
unitDef.tag = "player" -- 206
unitDef.decisionTree = "AI:playerControl" -- 207
unitDef.actions = Array({ -- 208
    "idle", -- 209
    "turn", -- 210
    "move", -- 211
    "jump", -- 212
    "fallOff", -- 213
    "cancel" -- 214
}) -- 214
Observer("Add", {"player"}):watch(function(____self) -- 217
    local unit = Unit( -- 218
        unitDef, -- 218
        world, -- 218
        ____self, -- 218
        Vec2(300, -350) -- 218
    ) -- 218
    unit.order = PlayerLayer -- 219
    unit.group = PlayerGroup -- 220
    unit.playable.position = Vec2(0, -150) -- 221
    unit.playable:play("idle", true) -- 222
    world:addChild(unit) -- 223
    world.camera.followTarget = unit -- 224
end) -- 217
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 227
    local rotationRef = useRef() -- 228
    local spriteRef = useRef() -- 229
    local sprite = toNode(React:createElement( -- 231
        "sprite", -- 231
        { -- 231
            file = icon, -- 231
            ref = spriteRef, -- 231
            onUpdate = loop(function() -- 231
                local rotation = rotationRef.current -- 231
                local sprite = spriteRef.current -- 231
                if not rotation or not sprite then -- 231
                    return true -- 235
                end -- 235
                sleep(sprite:runAction(rotation)) -- 236
                return false -- 237
            end) -- 232
        }, -- 232
        React:createElement( -- 232
            "action", -- 232
            {ref = rotationRef}, -- 232
            React:createElement( -- 232
                "spawn", -- 232
                nil, -- 232
                React:createElement("angle-y", {time = 5, start = 0, stop = 360}), -- 232
                React:createElement( -- 232
                    "sequence", -- 232
                    nil, -- 232
                    React:createElement("move-y", {time = 2.5, start = 0, stop = 40, easing = Ease.OutQuad}), -- 232
                    React:createElement("move-y", {time = 2.5, start = 40, stop = 0, easing = Ease.InQuad}) -- 232
                ) -- 232
            ) -- 232
        ) -- 232
    )) -- 232
    if not sprite then -- 232
        return false -- 251
    end -- 251
    local body = toNode(React:createElement( -- 253
        "body", -- 253
        { -- 253
            type = "Dynamic", -- 253
            world = world, -- 253
            linearAcceleration = Vec2(0, -10), -- 253
            x = x, -- 253
            order = ItemLayer, -- 253
            group = ItemGroup -- 253
        }, -- 253
        React:createElement("rect-fixture", {width = sprite.width * 0.5, height = sprite.height}), -- 253
        React:createElement("rect-fixture", {sensorTag = 0, width = sprite.width, height = sprite.height}) -- 253
    )) -- 253
    if not body then -- 253
        return false -- 262
    end -- 262
    local itemBody = body -- 264
    body:addChild(sprite) -- 265
    body:slot( -- 266
        "BodyEnter", -- 266
        function(item) -- 266
            if tolua.type(item) == "Platformer::Unit" then -- 266
                ____self.picked = true -- 268
                itemBody.group = Data.groupHide -- 269
                itemBody:schedule(once(function() -- 270
                    sleep(sprite:runAction(Spawn( -- 271
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 272
                        Opacity(0.2, 1, 0) -- 273
                    ))) -- 273
                    ____self.body = nil -- 275
                end)) -- 270
            end -- 270
        end -- 266
    ) -- 266
    world:addChild(body) -- 280
    ____self.body = body -- 281
end) -- 227
Observer("Remove", {"body"}):watch(function(____self) -- 284
    local body = tolua.cast(____self.oldValues.body, "Body") -- 285
    if body ~= nil then -- 285
        body:removeFromParent() -- 287
    end -- 287
end) -- 284
local function loadExcel() -- 312
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 313
    if xlsx ~= nil then -- 313
        local its = xlsx.items -- 315
        local names = its[2] -- 316
        table.remove(names, 1) -- 317
        if not Struct:has("Item") then -- 317
            Struct.Item(names) -- 319
        end -- 319
        Group({"item"}):each(function(e) -- 321
            e:destroy() -- 322
            return false -- 323
        end) -- 321
        do -- 321
            local i = 2 -- 325
            while i < #its do -- 325
                local st = Struct:load(its[i + 1]) -- 326
                local item = { -- 327
                    name = st.Name, -- 328
                    no = st.No, -- 329
                    x = st.X, -- 330
                    num = st.Num, -- 331
                    icon = st.Icon, -- 332
                    desc = st.Desc, -- 333
                    item = true -- 334
                } -- 334
                Entity(item) -- 336
                i = i + 1 -- 325
            end -- 325
        end -- 325
    end -- 325
end -- 312
local keyboardEnabled = true -- 347
local playerGroup = Group({"player"}) -- 349
local function updatePlayerControl(key, flag, vpad) -- 350
    if keyboardEnabled and vpad then -- 350
        keyboardEnabled = false -- 352
    end -- 352
    playerGroup:each(function(____self) -- 354
        ____self[key] = flag -- 355
        return false -- 356
    end) -- 354
end -- 350
local uiScale = App.devicePixelRatio -- 360
local function AlignNode(self, props) -- 369
    return React:createElement( -- 370
        "custom-node", -- 370
        __TS__ObjectAssign( -- 370
            {onCreate = function() return AlignNodeCreate({isRoot = props.root, inUI = props.ui, hAlign = props.hAlign, vAlign = props.vAlign}) end}, -- 370
            props -- 375
        ) -- 375
    ) -- 375
end -- 369
local function CircleButton(self, props) -- 382
    return React:createElement( -- 383
        "custom-node", -- 383
        __TS__ObjectAssign( -- 383
            {onCreate = function() return CircleButtonCreate({ -- 383
                text = props.text, -- 384
                radius = 30 * uiScale, -- 385
                fontSize = math.floor(18 * uiScale) -- 386
            }) end}, -- 386
            props -- 387
        ) -- 387
    ) -- 387
end -- 382
local ui = toNode(React:createElement( -- 390
    AlignNode, -- 391
    {root = true, ui = true}, -- 391
    React:createElement( -- 391
        AlignNode, -- 392
        {hAlign = "Left", vAlign = "Bottom"}, -- 392
        React:createElement( -- 392
            "menu", -- 392
            nil, -- 392
            React:createElement( -- 392
                CircleButton, -- 394
                { -- 394
                    text = "Left\n(a)", -- 394
                    x = 20 * uiScale, -- 394
                    y = 60 * uiScale, -- 394
                    anchorX = 0, -- 394
                    anchorY = 0, -- 394
                    onTapBegan = function() return updatePlayerControl("keyLeft", true, true) end, -- 394
                    onTapEnded = function() return updatePlayerControl("keyLeft", false, true) end -- 394
                } -- 394
            ), -- 394
            React:createElement( -- 394
                CircleButton, -- 399
                { -- 399
                    text = "Right\n(a)", -- 399
                    x = 90 * uiScale, -- 399
                    y = 60 * uiScale, -- 399
                    anchorX = 0, -- 399
                    anchorY = 0, -- 399
                    onTapBegan = function() return updatePlayerControl("keyRight", true, true) end, -- 399
                    onTapEnded = function() return updatePlayerControl("keyRight", false, true) end -- 399
                } -- 399
            ) -- 399
        ) -- 399
    ), -- 399
    React:createElement( -- 399
        AlignNode, -- 406
        {hAlign = "Right", vAlign = "Bottom"}, -- 406
        React:createElement( -- 406
            "menu", -- 406
            nil, -- 406
            React:createElement( -- 406
                CircleButton, -- 408
                { -- 408
                    text = "Jump\n(j)", -- 408
                    x = -80 * uiScale, -- 408
                    y = 60 * uiScale, -- 408
                    anchorX = 0, -- 408
                    anchorY = 0, -- 408
                    onTapBegan = function() return updatePlayerControl("keyJump", true, true) end, -- 408
                    onTapEnded = function() return updatePlayerControl("keyJump", false, true) end -- 408
                } -- 408
            ) -- 408
        ) -- 408
    ) -- 408
)) -- 408
if ui then -- 408
    local alignNode = ui -- 419
    alignNode:addTo(Director.ui) -- 420
    alignNode:alignLayout() -- 421
    alignNode:schedule(function() -- 422
        local keyA = Keyboard:isKeyPressed("A") -- 423
        local keyD = Keyboard:isKeyPressed("D") -- 424
        local keyJ = Keyboard:isKeyPressed("J") -- 425
        if keyD or keyD or keyJ then -- 425
            keyboardEnabled = true -- 427
        end -- 427
        if not keyboardEnabled then -- 427
            return false -- 430
        end -- 430
        updatePlayerControl("keyLeft", keyA, false) -- 432
        updatePlayerControl("keyRight", keyD, false) -- 433
        updatePlayerControl("keyJump", keyJ, false) -- 434
        return false -- 435
    end) -- 422
end -- 422
local pickedItemGroup = Group({"picked"}) -- 439
local windowFlags = { -- 440
    "NoDecoration", -- 441
    "AlwaysAutoResize", -- 442
    "NoSavedSettings", -- 443
    "NoFocusOnAppearing", -- 444
    "NoNav", -- 445
    "NoMove" -- 446
} -- 446
Director.ui:schedule(function() -- 448
    local size = App.visualSize -- 449
    ImGui.SetNextWindowBgAlpha(0.35) -- 450
    ImGui.SetNextWindowPos( -- 451
        Vec2(size.width - 10, 10), -- 451
        "Always", -- 451
        Vec2(1, 0) -- 451
    ) -- 451
    ImGui.SetNextWindowSize( -- 452
        Vec2(100, 300), -- 452
        "FirstUseEver" -- 452
    ) -- 452
    ImGui.Begin( -- 453
        "BackPack", -- 453
        windowFlags, -- 453
        function() -- 453
            if ImGui.Button("重新加载Excel") then -- 453
                loadExcel() -- 455
            end -- 455
            ImGui.Separator() -- 457
            ImGui.Dummy(Vec2(100, 10)) -- 458
            ImGui.Text("背包 (TSX)") -- 459
            ImGui.Separator() -- 460
            ImGui.Columns(3, false) -- 461
            pickedItemGroup:each(function(e) -- 462
                local item = e -- 463
                if item.num > 0 then -- 463
                    if ImGui.ImageButton( -- 463
                        "item" .. tostring(item.no), -- 465
                        item.icon, -- 465
                        Vec2(50, 50) -- 465
                    ) then -- 465
                        item.num = item.num - 1 -- 466
                        local sprite = Sprite(item.icon) -- 467
                        if not sprite then -- 467
                            return false -- 468
                        end -- 468
                        sprite.scaleY = 0.5 -- 469
                        sprite.scaleX = 0.5 -- 469
                        sprite:perform(Spawn( -- 470
                            Opacity(1, 1, 0), -- 471
                            Y(1, 150, 250) -- 472
                        )) -- 472
                        local player = playerGroup:find(function() return true end) -- 474
                        if player ~= nil then -- 474
                            local unit = player.unit -- 476
                            unit:addChild(sprite) -- 477
                        end -- 477
                    end -- 477
                    if ImGui.IsItemHovered() then -- 477
                        ImGui.BeginTooltip(function() -- 481
                            ImGui.Text(item.name) -- 482
                            ImGui.TextColored(themeColor, "数量：") -- 483
                            ImGui.SameLine() -- 484
                            ImGui.Text(tostring(item.num)) -- 485
                            ImGui.TextColored(themeColor, "描述：") -- 486
                            ImGui.SameLine() -- 487
                            ImGui.Text(tostring(item.desc)) -- 488
                        end) -- 481
                    end -- 481
                    ImGui.NextColumn() -- 491
                end -- 491
                return false -- 493
            end) -- 462
        end -- 453
    ) -- 453
    return false -- 496
end) -- 448
Entity({player = true}) -- 499
loadExcel() -- 500
return ____exports -- 500