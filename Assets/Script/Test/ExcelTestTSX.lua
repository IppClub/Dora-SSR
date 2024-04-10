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
local ____Utils = require("Utils") -- 294
local Struct = ____Utils.Struct -- 294
local AlignNodeCreate = require("UI.Control.Basic.AlignNode") -- 344
local CircleButtonCreate = require("UI.Control.Basic.CircleButton") -- 345
local ImGui = require("ImGui") -- 348
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
    return false -- 225
end) -- 217
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 228
    local rotationRef = useRef() -- 229
    local spriteRef = useRef() -- 230
    local sprite = toNode(React:createElement( -- 232
        "sprite", -- 232
        { -- 232
            file = icon, -- 232
            ref = spriteRef, -- 232
            onUpdate = loop(function() -- 232
                local rotation = rotationRef.current -- 232
                local sprite = spriteRef.current -- 232
                if not rotation or not sprite then -- 232
                    return true -- 236
                end -- 236
                sleep(sprite:runAction(rotation)) -- 237
                return false -- 238
            end) -- 233
        }, -- 233
        React:createElement( -- 233
            "action", -- 233
            {ref = rotationRef}, -- 233
            React:createElement( -- 233
                "spawn", -- 233
                nil, -- 233
                React:createElement("angle-y", {time = 5, start = 0, stop = 360}), -- 233
                React:createElement( -- 233
                    "sequence", -- 233
                    nil, -- 233
                    React:createElement("move-y", {time = 2.5, start = 0, stop = 40, easing = Ease.OutQuad}), -- 233
                    React:createElement("move-y", {time = 2.5, start = 40, stop = 0, easing = Ease.InQuad}) -- 233
                ) -- 233
            ) -- 233
        ) -- 233
    )) -- 233
    if not sprite then -- 233
        return false -- 252
    end -- 252
    local body = toNode(React:createElement( -- 254
        "body", -- 254
        { -- 254
            type = "Dynamic", -- 254
            world = world, -- 254
            linearAcceleration = Vec2(0, -10), -- 254
            x = x, -- 254
            order = ItemLayer, -- 254
            group = ItemGroup -- 254
        }, -- 254
        React:createElement("rect-fixture", {width = sprite.width * 0.5, height = sprite.height}), -- 254
        React:createElement("rect-fixture", {sensorTag = 0, width = sprite.width, height = sprite.height}) -- 254
    )) -- 254
    if not body then -- 254
        return false -- 263
    end -- 263
    local itemBody = body -- 265
    body:addChild(sprite) -- 266
    body:slot( -- 267
        "BodyEnter", -- 267
        function(item) -- 267
            if tolua.type(item) == "Platformer::Unit" then -- 267
                ____self.picked = true -- 269
                itemBody.group = Data.groupHide -- 270
                itemBody:schedule(once(function() -- 271
                    sleep(sprite:runAction(Spawn( -- 272
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 273
                        Opacity(0.2, 1, 0) -- 274
                    ))) -- 274
                    ____self.body = nil -- 276
                end)) -- 271
            end -- 271
        end -- 267
    ) -- 267
    world:addChild(body) -- 281
    ____self.body = body -- 282
    return false -- 283
end) -- 228
Observer("Remove", {"body"}):watch(function(____self) -- 286
    local body = tolua.cast(____self.oldValues.body, "Body") -- 287
    if body ~= nil then -- 287
        body:removeFromParent() -- 289
    end -- 289
    return false -- 291
end) -- 286
local function loadExcel() -- 315
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 316
    if xlsx ~= nil then -- 316
        local its = xlsx.items -- 318
        local names = its[2] -- 319
        table.remove(names, 1) -- 320
        if not Struct:has("Item") then -- 320
            Struct.Item(names) -- 322
        end -- 322
        Group({"item"}):each(function(e) -- 324
            e:destroy() -- 325
            return false -- 326
        end) -- 324
        do -- 324
            local i = 2 -- 328
            while i < #its do -- 328
                local st = Struct:load(its[i + 1]) -- 329
                local item = { -- 330
                    name = st.Name, -- 331
                    no = st.No, -- 332
                    x = st.X, -- 333
                    num = st.Num, -- 334
                    icon = st.Icon, -- 335
                    desc = st.Desc, -- 336
                    item = true -- 337
                } -- 337
                Entity(item) -- 339
                i = i + 1 -- 328
            end -- 328
        end -- 328
    end -- 328
end -- 315
local keyboardEnabled = true -- 350
local playerGroup = Group({"player"}) -- 352
local function updatePlayerControl(key, flag, vpad) -- 353
    if keyboardEnabled and vpad then -- 353
        keyboardEnabled = false -- 355
    end -- 355
    playerGroup:each(function(____self) -- 357
        ____self[key] = flag -- 358
        return false -- 359
    end) -- 357
end -- 353
local uiScale = App.devicePixelRatio -- 363
local function AlignNode(self, props) -- 372
    return React:createElement( -- 373
        "custom-node", -- 373
        __TS__ObjectAssign( -- 373
            {onCreate = function() return AlignNodeCreate({isRoot = props.root, inUI = props.ui, hAlign = props.hAlign, vAlign = props.vAlign}) end}, -- 373
            props -- 378
        ) -- 378
    ) -- 378
end -- 372
local function CircleButton(self, props) -- 385
    return React:createElement( -- 386
        "custom-node", -- 386
        __TS__ObjectAssign( -- 386
            {onCreate = function() return CircleButtonCreate({ -- 386
                text = props.text, -- 387
                radius = 30 * uiScale, -- 388
                fontSize = math.floor(18 * uiScale) -- 389
            }) end}, -- 389
            props -- 390
        ) -- 390
    ) -- 390
end -- 385
local ui = toNode(React:createElement( -- 393
    AlignNode, -- 394
    {root = true, ui = true}, -- 394
    React:createElement( -- 394
        AlignNode, -- 395
        {hAlign = "Left", vAlign = "Bottom"}, -- 395
        React:createElement( -- 395
            "menu", -- 395
            nil, -- 395
            React:createElement( -- 395
                CircleButton, -- 397
                { -- 397
                    text = "Left\n(a)", -- 397
                    x = 20 * uiScale, -- 397
                    y = 60 * uiScale, -- 397
                    anchorX = 0, -- 397
                    anchorY = 0, -- 397
                    onTapBegan = function() return updatePlayerControl("keyLeft", true, true) end, -- 397
                    onTapEnded = function() return updatePlayerControl("keyLeft", false, true) end -- 397
                } -- 397
            ), -- 397
            React:createElement( -- 397
                CircleButton, -- 402
                { -- 402
                    text = "Right\n(a)", -- 402
                    x = 90 * uiScale, -- 402
                    y = 60 * uiScale, -- 402
                    anchorX = 0, -- 402
                    anchorY = 0, -- 402
                    onTapBegan = function() return updatePlayerControl("keyRight", true, true) end, -- 402
                    onTapEnded = function() return updatePlayerControl("keyRight", false, true) end -- 402
                } -- 402
            ) -- 402
        ) -- 402
    ), -- 402
    React:createElement( -- 402
        AlignNode, -- 409
        {hAlign = "Right", vAlign = "Bottom"}, -- 409
        React:createElement( -- 409
            "menu", -- 409
            nil, -- 409
            React:createElement( -- 409
                CircleButton, -- 411
                { -- 411
                    text = "Jump\n(j)", -- 411
                    x = -80 * uiScale, -- 411
                    y = 60 * uiScale, -- 411
                    anchorX = 0, -- 411
                    anchorY = 0, -- 411
                    onTapBegan = function() return updatePlayerControl("keyJump", true, true) end, -- 411
                    onTapEnded = function() return updatePlayerControl("keyJump", false, true) end -- 411
                } -- 411
            ) -- 411
        ) -- 411
    ) -- 411
)) -- 411
if ui then -- 411
    local alignNode = ui -- 422
    alignNode:addTo(Director.ui) -- 423
    alignNode:alignLayout() -- 424
    alignNode:schedule(function() -- 425
        local keyA = Keyboard:isKeyPressed("A") -- 426
        local keyD = Keyboard:isKeyPressed("D") -- 427
        local keyJ = Keyboard:isKeyPressed("J") -- 428
        if keyD or keyD or keyJ then -- 428
            keyboardEnabled = true -- 430
        end -- 430
        if not keyboardEnabled then -- 430
            return false -- 433
        end -- 433
        updatePlayerControl("keyLeft", keyA, false) -- 435
        updatePlayerControl("keyRight", keyD, false) -- 436
        updatePlayerControl("keyJump", keyJ, false) -- 437
        return false -- 438
    end) -- 425
end -- 425
local pickedItemGroup = Group({"picked"}) -- 442
local windowFlags = { -- 443
    "NoDecoration", -- 444
    "AlwaysAutoResize", -- 445
    "NoSavedSettings", -- 446
    "NoFocusOnAppearing", -- 447
    "NoNav", -- 448
    "NoMove" -- 449
} -- 449
Director.ui:schedule(function() -- 451
    local size = App.visualSize -- 452
    ImGui.SetNextWindowBgAlpha(0.35) -- 453
    ImGui.SetNextWindowPos( -- 454
        Vec2(size.width - 10, 10), -- 454
        "Always", -- 454
        Vec2(1, 0) -- 454
    ) -- 454
    ImGui.SetNextWindowSize( -- 455
        Vec2(100, 300), -- 455
        "FirstUseEver" -- 455
    ) -- 455
    ImGui.Begin( -- 456
        "BackPack", -- 456
        windowFlags, -- 456
        function() -- 456
            if ImGui.Button("重新加载Excel") then -- 456
                loadExcel() -- 458
            end -- 458
            ImGui.Separator() -- 460
            ImGui.Dummy(Vec2(100, 10)) -- 461
            ImGui.Text("背包 (TSX)") -- 462
            ImGui.Separator() -- 463
            ImGui.Columns(3, false) -- 464
            pickedItemGroup:each(function(e) -- 465
                local item = e -- 466
                if item.num > 0 then -- 466
                    if ImGui.ImageButton( -- 466
                        "item" .. tostring(item.no), -- 468
                        item.icon, -- 468
                        Vec2(50, 50) -- 468
                    ) then -- 468
                        item.num = item.num - 1 -- 469
                        local sprite = Sprite(item.icon) -- 470
                        if not sprite then -- 470
                            return false -- 471
                        end -- 471
                        sprite.scaleY = 0.5 -- 472
                        sprite.scaleX = 0.5 -- 472
                        sprite:perform(Spawn( -- 473
                            Opacity(1, 1, 0), -- 474
                            Y(1, 150, 250) -- 475
                        )) -- 475
                        local player = playerGroup:find(function() return true end) -- 477
                        if player ~= nil then -- 477
                            local unit = player.unit -- 479
                            unit:addChild(sprite) -- 480
                        end -- 480
                    end -- 480
                    if ImGui.IsItemHovered() then -- 480
                        ImGui.BeginTooltip(function() -- 484
                            ImGui.Text(item.name) -- 485
                            ImGui.TextColored(themeColor, "数量：") -- 486
                            ImGui.SameLine() -- 487
                            ImGui.Text(tostring(item.num)) -- 488
                            ImGui.TextColored(themeColor, "描述：") -- 489
                            ImGui.SameLine() -- 490
                            ImGui.Text(tostring(item.desc)) -- 491
                        end) -- 484
                    end -- 484
                    ImGui.NextColumn() -- 494
                end -- 494
                return false -- 496
            end) -- 465
        end -- 456
    ) -- 456
    return false -- 499
end) -- 451
Entity({player = true}) -- 502
loadExcel() -- 503
return ____exports -- 503