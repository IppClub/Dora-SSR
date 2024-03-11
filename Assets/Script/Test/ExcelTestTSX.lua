-- [tsx]: ExcelTestTSX.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____dora_2Dx = require("dora-x") -- 1
local React = ____dora_2Dx.React -- 1
local toNode = ____dora_2Dx.toNode -- 1
local useRef = ____dora_2Dx.useRef -- 1
local ____Platformer = require("Platformer") -- 2
local Data = ____Platformer.Data -- 2
local PlatformWorld = ____Platformer.PlatformWorld -- 2
local Unit = ____Platformer.Unit -- 2
local UnitAction = ____Platformer.UnitAction -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Color = ____dora.Color -- 3
local Color3 = ____dora.Color3 -- 3
local Dictionary = ____dora.Dictionary -- 3
local Rect = ____dora.Rect -- 3
local Size = ____dora.Size -- 3
local Vec2 = ____dora.Vec2 -- 3
local View = ____dora.View -- 3
local loop = ____dora.loop -- 3
local once = ____dora.once -- 3
local sleep = ____dora.sleep -- 3
local Array = ____dora.Array -- 3
local Observer = ____dora.Observer -- 3
local Sprite = ____dora.Sprite -- 3
local Spawn = ____dora.Spawn -- 3
local Ease = ____dora.Ease -- 3
local Y = ____dora.Y -- 3
local tolua = ____dora.tolua -- 3
local Scale = ____dora.Scale -- 3
local Opacity = ____dora.Opacity -- 3
local Content = ____dora.Content -- 3
local Group = ____dora.Group -- 3
local Entity = ____dora.Entity -- 3
local Director = ____dora.Director -- 3
local Keyboard = ____dora.Keyboard -- 3
local ____Platformer_2Dx = require("Platformer-x") -- 4
local DecisionTree = ____Platformer_2Dx.DecisionTree -- 4
local toAI = ____Platformer_2Dx.toAI -- 4
local ____Utils = require("Utils") -- 290
local Struct = ____Utils.Struct -- 290
local AlignNodeCreate = require("UI.Control.Basic.AlignNode") -- 340
local CircleButtonCreate = require("UI.Control.Basic.CircleButton") -- 341
local ImGui = require("ImGui") -- 344
local TerrainLayer = 0 -- 6
local PlayerLayer = 1 -- 7
local ItemLayer = 2 -- 8
local PlayerGroup = Data.groupFirstPlayer -- 10
local ItemGroup = Data.groupFirstPlayer + 1 -- 11
local TerrainGroup = Data.groupTerrain -- 12
Data:setShouldContact(PlayerGroup, ItemGroup, true) -- 14
local themeColor = App.themeColor -- 16
local color = themeColor:toARGB() -- 17
local DesignWidth = 1500 -- 18
local world = PlatformWorld() -- 20
world.camera.boundary = Rect(-1250, -500, 2500, 1000) -- 21
world.camera.followRatio = Vec2(0.02, 0.02) -- 22
world.camera.zoom = View.size.width / DesignWidth -- 23
world:gslot( -- 24
    "AppSizeChanged", -- 24
    function() -- 24
        world.camera.zoom = View.size.width / DesignWidth -- 25
    end -- 24
) -- 24
local function RectShape(self, props) -- 36
    local hw = props.width / 2 -- 37
    local hh = props.height / 2 -- 38
    local x = props.x or 0 -- 39
    local y = props.y or 0 -- 40
    local color = Color3(props.color) -- 41
    local fillColor = Color(color, 102):toARGB() -- 42
    local borderColor = Color(color, 255):toARGB() -- 43
    return React:createElement( -- 44
        "polygon-shape", -- 44
        { -- 44
            verts = { -- 44
                Vec2(-hw + x, hh + y), -- 46
                Vec2(hw + x, hh + y), -- 47
                Vec2(hw + x, -hh + y), -- 48
                Vec2(-hw + x, -hh + y) -- 49
            }, -- 49
            fillColor = fillColor, -- 49
            borderColor = borderColor, -- 49
            borderWidth = 1 -- 49
        } -- 49
    ) -- 49
end -- 36
local terrain = toNode(React:createElement( -- 57
    "body", -- 57
    {type = "Static", world = world, order = TerrainLayer, group = TerrainGroup}, -- 57
    React:createElement("rect-fixture", { -- 57
        centerY = -500, -- 57
        width = 2500, -- 57
        height = 10, -- 57
        friction = 1, -- 57
        restitution = 0 -- 57
    }), -- 57
    React:createElement("rect-fixture", { -- 57
        centerY = 500, -- 57
        width = 2500, -- 57
        height = 10, -- 57
        friction = 1, -- 57
        restitution = 0 -- 57
    }), -- 57
    React:createElement("rect-fixture", { -- 57
        centerX = 1250, -- 57
        width = 10, -- 57
        height = 2500, -- 57
        friction = 1, -- 57
        restitution = 0 -- 57
    }), -- 57
    React:createElement("rect-fixture", { -- 57
        centerX = -1250, -- 57
        width = 10, -- 57
        height = 2500, -- 57
        friction = 1, -- 57
        restitution = 0 -- 57
    }), -- 57
    React:createElement( -- 57
        "draw-node", -- 57
        nil, -- 57
        React:createElement(RectShape, {y = -500, width = 2500, height = 10, color = color}), -- 57
        React:createElement(RectShape, {x = 1250, width = 10, height = 1000, color = color}), -- 57
        React:createElement(RectShape, {x = -1250, width = 10, height = 1000, color = color}) -- 57
    ) -- 57
)) -- 57
if terrain ~= nil then -- 57
    terrain:addTo(world) -- 70
end -- 70
UnitAction:add( -- 72
    "idle", -- 72
    { -- 72
        priority = 1, -- 73
        reaction = 2, -- 74
        recovery = 0.2, -- 75
        available = function(____self) return ____self.onSurface end, -- 76
        create = function(____self) -- 77
            local ____self_2 = ____self -- 78
            local playable = ____self_2.playable -- 78
            playable.speed = 1 -- 79
            playable:play("idle", true) -- 80
            local playIdleSpecial = loop(function() -- 81
                sleep(3) -- 82
                sleep(playable:play("idle1")) -- 83
                playable:play("idle", true) -- 84
                return false -- 85
            end) -- 81
            ____self.data.playIdleSpecial = playIdleSpecial -- 87
            return function(owner) -- 88
                coroutine.resume(playIdleSpecial) -- 89
                return not owner.onSurface -- 90
            end -- 88
        end -- 77
    } -- 77
) -- 77
UnitAction:add( -- 95
    "move", -- 95
    { -- 95
        priority = 1, -- 96
        reaction = 2, -- 97
        recovery = 0.2, -- 98
        available = function(____self) return ____self.onSurface end, -- 99
        create = function(____self) -- 100
            local ____self_3 = ____self -- 101
            local playable = ____self_3.playable -- 101
            playable.speed = 1 -- 102
            playable:play("fmove", true) -- 103
            return function(____self, action) -- 104
                local ____action_4 = action -- 105
                local elapsedTime = ____action_4.elapsedTime -- 105
                local recovery = action.recovery * 2 -- 106
                local move = ____self.unitDef.move -- 107
                local moveSpeed = 1 -- 108
                if elapsedTime < recovery then -- 108
                    moveSpeed = math.min(elapsedTime / recovery, 1) -- 110
                end -- 110
                ____self.velocityX = moveSpeed * (____self.faceRight and move or -move) -- 112
                return not ____self.onSurface -- 113
            end -- 104
        end -- 100
    } -- 100
) -- 100
UnitAction:add( -- 118
    "jump", -- 118
    { -- 118
        priority = 3, -- 119
        reaction = 2, -- 120
        recovery = 0.1, -- 121
        queued = true, -- 122
        available = function(____self) return ____self.onSurface end, -- 123
        create = function(____self) -- 124
            local jump = ____self.unitDef.jump -- 125
            ____self.velocityY = jump -- 126
            return once(function() -- 127
                local ____self_5 = ____self -- 128
                local playable = ____self_5.playable -- 128
                playable.speed = 1 -- 129
                sleep(playable:play("jump", false)) -- 130
            end) -- 127
        end -- 124
    } -- 124
) -- 124
UnitAction:add( -- 135
    "fallOff", -- 135
    { -- 135
        priority = 2, -- 136
        reaction = -1, -- 137
        recovery = 0.3, -- 138
        available = function(____self) return not ____self.onSurface end, -- 139
        create = function(____self) -- 140
            if ____self.playable.current ~= "jumping" then -- 140
                local ____self_6 = ____self -- 142
                local playable = ____self_6.playable -- 142
                playable.speed = 1 -- 143
                playable:play("jumping", true) -- 144
            end -- 144
            return loop(function() -- 146
                if ____self.onSurface then -- 146
                    local ____self_7 = ____self -- 148
                    local playable = ____self_7.playable -- 148
                    playable.speed = 1 -- 149
                    sleep(playable:play("landing", false)) -- 150
                    return true -- 151
                end -- 151
                return false -- 153
            end) -- 146
        end -- 140
    } -- 140
) -- 140
local ____DecisionTree_8 = DecisionTree -- 158
local Selector = ____DecisionTree_8.Selector -- 158
local Match = ____DecisionTree_8.Match -- 158
local Action = ____DecisionTree_8.Action -- 158
Data.store["AI:playerControl"] = toAI(React:createElement( -- 160
    Selector, -- 161
    nil, -- 161
    React:createElement( -- 161
        Match, -- 162
        { -- 162
            desc = "fmove key down", -- 162
            onCheck = function(____self) -- 162
                local keyLeft = ____self.entity.keyLeft -- 163
                local keyRight = ____self.entity.keyRight -- 164
                return not (keyLeft and keyRight) and (keyLeft and ____self.faceRight or keyRight and not ____self.faceRight) -- 165
            end -- 162
        }, -- 162
        React:createElement(Action, {name = "turn"}) -- 162
    ), -- 162
    React:createElement( -- 162
        Match, -- 174
        { -- 174
            desc = "is falling", -- 174
            onCheck = function(____self) return not ____self.onSurface end -- 174
        }, -- 174
        React:createElement(Action, {name = "fallOff"}) -- 174
    ), -- 174
    React:createElement( -- 174
        Match, -- 178
        { -- 178
            desc = "jump key down", -- 178
            onCheck = function(____self) return ____self.entity.keyJump end -- 178
        }, -- 178
        React:createElement(Action, {name = "jump"}) -- 178
    ), -- 178
    React:createElement( -- 178
        Match, -- 182
        { -- 182
            desc = "fmove key down", -- 182
            onCheck = function(____self) return ____self.entity.keyLeft or ____self.entity.keyRight end -- 182
        }, -- 182
        React:createElement(Action, {name = "move"}) -- 182
    ), -- 182
    React:createElement(Action, {name = "idle"}) -- 182
)) -- 182
local unitDef = Dictionary() -- 190
unitDef.linearAcceleration = Vec2(0, -15) -- 191
unitDef.bodyType = "Dynamic" -- 192
unitDef.scale = 1 -- 193
unitDef.density = 1 -- 194
unitDef.friction = 1 -- 195
unitDef.restitution = 0 -- 196
unitDef.playable = "spine:Spine/moling" -- 197
unitDef.defaultFaceRight = true -- 198
unitDef.size = Size(60, 300) -- 199
unitDef.sensity = 0 -- 200
unitDef.move = 300 -- 201
unitDef.jump = 1000 -- 202
unitDef.detectDistance = 350 -- 203
unitDef.hp = 5 -- 204
unitDef.tag = "player" -- 205
unitDef.decisionTree = "AI:playerControl" -- 206
unitDef.actions = Array({ -- 207
    "idle", -- 208
    "turn", -- 209
    "move", -- 210
    "jump", -- 211
    "fallOff", -- 212
    "cancel" -- 213
}) -- 213
Observer("Add", {"player"}):watch(function(____self) -- 216
    local unit = Unit( -- 217
        unitDef, -- 217
        world, -- 217
        ____self, -- 217
        Vec2(300, -350) -- 217
    ) -- 217
    unit.order = PlayerLayer -- 218
    unit.group = PlayerGroup -- 219
    unit.playable.position = Vec2(0, -150) -- 220
    unit.playable:play("idle", true) -- 221
    world:addChild(unit) -- 222
    world.camera.followTarget = unit -- 223
end) -- 216
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 226
    local rotationRef = useRef() -- 227
    local spriteRef = useRef() -- 228
    local sprite = toNode(React:createElement( -- 230
        "sprite", -- 230
        { -- 230
            file = icon, -- 230
            ref = spriteRef, -- 230
            onUpdate = loop(function() -- 230
                local rotation = rotationRef.current -- 230
                local sprite = spriteRef.current -- 230
                if not rotation or not sprite then -- 230
                    return true -- 234
                end -- 234
                sleep(sprite:runAction(rotation)) -- 235
                return false -- 236
            end) -- 231
        }, -- 231
        React:createElement( -- 231
            "action", -- 231
            {ref = rotationRef}, -- 231
            React:createElement( -- 231
                "spawn", -- 231
                nil, -- 231
                React:createElement("angle-y", {time = 5, start = 0, stop = 360}), -- 231
                React:createElement( -- 231
                    "sequence", -- 231
                    nil, -- 231
                    React:createElement("move-y", {time = 2.5, start = 0, stop = 40, easing = Ease.OutQuad}), -- 231
                    React:createElement("move-y", {time = 2.5, start = 40, stop = 0, easing = Ease.InQuad}) -- 231
                ) -- 231
            ) -- 231
        ) -- 231
    )) -- 231
    if not sprite then -- 231
        return false -- 250
    end -- 250
    local body = toNode(React:createElement( -- 252
        "body", -- 252
        { -- 252
            type = "Dynamic", -- 252
            world = world, -- 252
            linearAcceleration = Vec2(0, -10), -- 252
            x = x, -- 252
            order = ItemLayer, -- 252
            group = ItemGroup -- 252
        }, -- 252
        React:createElement("rect-fixture", {width = sprite.width * 0.5, height = sprite.height}), -- 252
        React:createElement("rect-fixture", {sensorTag = 0, width = sprite.width, height = sprite.height}) -- 252
    )) -- 252
    if not body then -- 252
        return false -- 261
    end -- 261
    local itemBody = body -- 263
    body:addChild(sprite) -- 264
    body:slot( -- 265
        "BodyEnter", -- 265
        function(item) -- 265
            if tolua.type(item) == "Platformer::Unit" then -- 265
                ____self.picked = true -- 267
                itemBody.group = Data.groupHide -- 268
                itemBody:schedule(once(function() -- 269
                    sleep(sprite:runAction(Spawn( -- 270
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 271
                        Opacity(0.2, 1, 0) -- 272
                    ))) -- 272
                    ____self.body = nil -- 274
                end)) -- 269
            end -- 269
        end -- 265
    ) -- 265
    world:addChild(body) -- 279
    ____self.body = body -- 280
end) -- 226
Observer("Remove", {"body"}):watch(function(____self) -- 283
    local body = tolua.cast(____self.oldValues.body, "Body") -- 284
    if body ~= nil then -- 284
        body:removeFromParent() -- 286
    end -- 286
end) -- 283
local function loadExcel() -- 311
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 312
    if xlsx ~= nil then -- 312
        local its = xlsx.items -- 314
        local names = its[2] -- 315
        table.remove(names, 1) -- 316
        if not Struct:has("Item") then -- 316
            Struct.Item(names) -- 318
        end -- 318
        Group({"item"}):each(function(e) -- 320
            e:destroy() -- 321
            return false -- 322
        end) -- 320
        do -- 320
            local i = 2 -- 324
            while i < #its do -- 324
                local st = Struct:load(its[i + 1]) -- 325
                local item = { -- 326
                    name = st.Name, -- 327
                    no = st.No, -- 328
                    x = st.X, -- 329
                    num = st.Num, -- 330
                    icon = st.Icon, -- 331
                    desc = st.Desc, -- 332
                    item = true -- 333
                } -- 333
                Entity(item) -- 335
                i = i + 1 -- 324
            end -- 324
        end -- 324
    end -- 324
end -- 311
local keyboardEnabled = true -- 346
local playerGroup = Group({"player"}) -- 348
local function updatePlayerControl(key, flag, vpad) -- 349
    if keyboardEnabled and vpad then -- 349
        keyboardEnabled = false -- 351
    end -- 351
    playerGroup:each(function(____self) -- 353
        ____self[key] = flag -- 354
        return false -- 355
    end) -- 353
end -- 349
local uiScale = App.devicePixelRatio -- 359
local function AlignNode(self, props) -- 368
    return React:createElement( -- 369
        "custom-node", -- 369
        __TS__ObjectAssign( -- 369
            {onCreate = function() return AlignNodeCreate({isRoot = props.root, inUI = props.ui, hAlign = props.hAlign, vAlign = props.vAlign}) end}, -- 369
            props -- 374
        ) -- 374
    ) -- 374
end -- 368
local function CircleButton(self, props) -- 381
    return React:createElement( -- 382
        "custom-node", -- 382
        __TS__ObjectAssign( -- 382
            {onCreate = function() return CircleButtonCreate({ -- 382
                text = props.text, -- 383
                radius = 30 * uiScale, -- 384
                fontSize = math.floor(18 * uiScale) -- 385
            }) end}, -- 385
            props -- 386
        ) -- 386
    ) -- 386
end -- 381
local ui = toNode(React:createElement( -- 389
    AlignNode, -- 390
    {root = true, ui = true}, -- 390
    React:createElement( -- 390
        AlignNode, -- 391
        {hAlign = "Left", vAlign = "Bottom"}, -- 391
        React:createElement( -- 391
            "menu", -- 391
            nil, -- 391
            React:createElement( -- 391
                CircleButton, -- 393
                { -- 393
                    text = "Left\n(a)", -- 393
                    x = 20 * uiScale, -- 393
                    y = 60 * uiScale, -- 393
                    anchorX = 0, -- 393
                    anchorY = 0, -- 393
                    onTapBegan = function() return updatePlayerControl("keyLeft", true, true) end, -- 393
                    onTapEnded = function() return updatePlayerControl("keyLeft", false, true) end -- 393
                } -- 393
            ), -- 393
            React:createElement( -- 393
                CircleButton, -- 398
                { -- 398
                    text = "Right\n(a)", -- 398
                    x = 90 * uiScale, -- 398
                    y = 60 * uiScale, -- 398
                    anchorX = 0, -- 398
                    anchorY = 0, -- 398
                    onTapBegan = function() return updatePlayerControl("keyRight", true, true) end, -- 398
                    onTapEnded = function() return updatePlayerControl("keyRight", false, true) end -- 398
                } -- 398
            ) -- 398
        ) -- 398
    ), -- 398
    React:createElement( -- 398
        AlignNode, -- 405
        {hAlign = "Right", vAlign = "Bottom"}, -- 405
        React:createElement( -- 405
            "menu", -- 405
            nil, -- 405
            React:createElement( -- 405
                CircleButton, -- 407
                { -- 407
                    text = "Jump\n(j)", -- 407
                    x = -80 * uiScale, -- 407
                    y = 60 * uiScale, -- 407
                    anchorX = 0, -- 407
                    anchorY = 0, -- 407
                    onTapBegan = function() return updatePlayerControl("keyJump", true, true) end, -- 407
                    onTapEnded = function() return updatePlayerControl("keyJump", false, true) end -- 407
                } -- 407
            ) -- 407
        ) -- 407
    ) -- 407
)) -- 407
if ui then -- 407
    local alignNode = ui -- 418
    alignNode:addTo(Director.ui) -- 419
    alignNode:alignLayout() -- 420
    alignNode:schedule(function() -- 421
        local keyA = Keyboard:isKeyPressed("A") -- 422
        local keyD = Keyboard:isKeyPressed("D") -- 423
        local keyJ = Keyboard:isKeyPressed("J") -- 424
        if keyD or keyD or keyJ then -- 424
            keyboardEnabled = true -- 426
        end -- 426
        if not keyboardEnabled then -- 426
            return false -- 429
        end -- 429
        updatePlayerControl("keyLeft", keyA, false) -- 431
        updatePlayerControl("keyRight", keyD, false) -- 432
        updatePlayerControl("keyJump", keyJ, false) -- 433
        return false -- 434
    end) -- 421
end -- 421
local pickedItemGroup = Group({"picked"}) -- 438
local windowFlags = { -- 439
    "NoDecoration", -- 440
    "AlwaysAutoResize", -- 441
    "NoSavedSettings", -- 442
    "NoFocusOnAppearing", -- 443
    "NoNav", -- 444
    "NoMove" -- 445
} -- 445
Director.ui:schedule(function() -- 447
    local size = App.visualSize -- 448
    ImGui.SetNextWindowBgAlpha(0.35) -- 449
    ImGui.SetNextWindowPos( -- 450
        Vec2(size.width - 10, 10), -- 450
        "Always", -- 450
        Vec2(1, 0) -- 450
    ) -- 450
    ImGui.SetNextWindowSize( -- 451
        Vec2(100, 300), -- 451
        "FirstUseEver" -- 451
    ) -- 451
    ImGui.Begin( -- 452
        "BackPack", -- 452
        windowFlags, -- 452
        function() -- 452
            if ImGui.Button("重新加载Excel") then -- 452
                loadExcel() -- 454
            end -- 454
            ImGui.Separator() -- 456
            ImGui.Dummy(Vec2(100, 10)) -- 457
            ImGui.Text("背包") -- 458
            ImGui.Separator() -- 459
            ImGui.Columns(3, false) -- 460
            pickedItemGroup:each(function(e) -- 461
                local item = e -- 462
                if item.num > 0 then -- 462
                    if ImGui.ImageButton( -- 462
                        "item" .. tostring(item.no), -- 464
                        item.icon, -- 464
                        Vec2(50, 50) -- 464
                    ) then -- 464
                        item.num = item.num - 1 -- 465
                        local sprite = Sprite(item.icon) -- 466
                        if not sprite then -- 466
                            return false -- 467
                        end -- 467
                        sprite.scaleY = 0.5 -- 468
                        sprite.scaleX = 0.5 -- 468
                        sprite:perform(Spawn( -- 469
                            Opacity(1, 1, 0), -- 470
                            Y(1, 150, 250) -- 471
                        )) -- 471
                        local player = playerGroup:find(function() return true end) -- 473
                        if player ~= nil then -- 473
                            local unit = player.unit -- 475
                            unit:addChild(sprite) -- 476
                        end -- 476
                    end -- 476
                    if ImGui.IsItemHovered() then -- 476
                        ImGui.BeginTooltip(function() -- 480
                            ImGui.Text(item.name) -- 481
                            ImGui.TextColored(themeColor, "数量：") -- 482
                            ImGui.SameLine() -- 483
                            ImGui.Text(tostring(item.num)) -- 484
                            ImGui.TextColored(themeColor, "描述：") -- 485
                            ImGui.SameLine() -- 486
                            ImGui.Text(tostring(item.desc)) -- 487
                        end) -- 480
                    end -- 480
                    ImGui.NextColumn() -- 490
                end -- 490
                return false -- 492
            end) -- 461
        end -- 452
    ) -- 452
    return false -- 495
end) -- 447
Entity({player = true}) -- 498
loadExcel() -- 499
return ____exports -- 499