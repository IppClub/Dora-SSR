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
local ____Utils = require("Utils") -- 283
local Struct = ____Utils.Struct -- 283
local AlignNodeCreate = require("UI.Control.Basic.AlignNode") -- 333
local CircleButtonCreate = require("UI.Control.Basic.CircleButton") -- 334
local ImGui = require("ImGui") -- 337
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
    local sprite = toNode(React:createElement( -- 229
        "sprite", -- 229
        {file = icon}, -- 229
        React:createElement( -- 229
            "loop", -- 229
            nil, -- 229
            React:createElement( -- 229
                "spawn", -- 229
                nil, -- 229
                React:createElement("angle-y", {time = 5, start = 0, stop = 360}), -- 229
                React:createElement( -- 229
                    "sequence", -- 229
                    nil, -- 229
                    React:createElement("move-y", {time = 2.5, start = 0, stop = 40, easing = Ease.OutQuad}), -- 229
                    React:createElement("move-y", {time = 2.5, start = 40, stop = 0, easing = Ease.InQuad}) -- 229
                ) -- 229
            ) -- 229
        ) -- 229
    )) -- 229
    if not sprite then -- 229
        return false -- 242
    end -- 242
    local body = toNode(React:createElement( -- 244
        "body", -- 244
        { -- 244
            type = "Dynamic", -- 244
            world = world, -- 244
            linearAcceleration = Vec2(0, -10), -- 244
            x = x, -- 244
            order = ItemLayer, -- 244
            group = ItemGroup -- 244
        }, -- 244
        React:createElement("rect-fixture", {width = sprite.width * 0.5, height = sprite.height}), -- 244
        React:createElement("rect-fixture", {sensorTag = 0, width = sprite.width, height = sprite.height}) -- 244
    )) -- 244
    if not body then -- 244
        return false -- 252
    end -- 252
    local itemBody = body -- 254
    body:addChild(sprite) -- 255
    body:slot( -- 256
        "BodyEnter", -- 256
        function(item) -- 256
            if tolua.type(item) == "Platformer::Unit" then -- 256
                ____self.picked = true -- 258
                itemBody.group = Data.groupHide -- 259
                itemBody:schedule(once(function() -- 260
                    sleep(sprite:runAction(Spawn( -- 261
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 262
                        Opacity(0.2, 1, 0) -- 263
                    ))) -- 263
                    ____self.body = nil -- 265
                end)) -- 260
            end -- 260
        end -- 256
    ) -- 256
    world:addChild(body) -- 270
    ____self.body = body -- 271
    return false -- 272
end) -- 228
Observer("Remove", {"body"}):watch(function(____self) -- 275
    local body = tolua.cast(____self.oldValues.body, "Body") -- 276
    if body ~= nil then -- 276
        body:removeFromParent() -- 278
    end -- 278
    return false -- 280
end) -- 275
local function loadExcel() -- 304
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 305
    if xlsx ~= nil then -- 305
        local its = xlsx.items -- 307
        local names = its[2] -- 308
        table.remove(names, 1) -- 309
        if not Struct:has("Item") then -- 309
            Struct.Item(names) -- 311
        end -- 311
        Group({"item"}):each(function(e) -- 313
            e:destroy() -- 314
            return false -- 315
        end) -- 313
        do -- 313
            local i = 2 -- 317
            while i < #its do -- 317
                local st = Struct:load(its[i + 1]) -- 318
                local item = { -- 319
                    name = st.Name, -- 320
                    no = st.No, -- 321
                    x = st.X, -- 322
                    num = st.Num, -- 323
                    icon = st.Icon, -- 324
                    desc = st.Desc, -- 325
                    item = true -- 326
                } -- 326
                Entity(item) -- 328
                i = i + 1 -- 317
            end -- 317
        end -- 317
    end -- 317
end -- 304
local keyboardEnabled = true -- 339
local playerGroup = Group({"player"}) -- 341
local function updatePlayerControl(key, flag, vpad) -- 342
    if keyboardEnabled and vpad then -- 342
        keyboardEnabled = false -- 344
    end -- 344
    playerGroup:each(function(____self) -- 346
        ____self[key] = flag -- 347
        return false -- 348
    end) -- 346
end -- 342
local uiScale = App.devicePixelRatio -- 352
local function AlignNode(self, props) -- 361
    return React:createElement( -- 362
        "custom-node", -- 362
        __TS__ObjectAssign( -- 362
            {onCreate = function() return AlignNodeCreate({isRoot = props.root, inUI = props.ui, hAlign = props.hAlign, vAlign = props.vAlign}) end}, -- 362
            props -- 367
        ) -- 367
    ) -- 367
end -- 361
local function CircleButton(self, props) -- 374
    return React:createElement( -- 375
        "custom-node", -- 375
        __TS__ObjectAssign( -- 375
            {onCreate = function() return CircleButtonCreate({ -- 375
                text = props.text, -- 376
                radius = 30 * uiScale, -- 377
                fontSize = math.floor(18 * uiScale) -- 378
            }) end}, -- 378
            props -- 379
        ) -- 379
    ) -- 379
end -- 374
local ui = toNode(React:createElement( -- 382
    AlignNode, -- 383
    {root = true, ui = true}, -- 383
    React:createElement( -- 383
        AlignNode, -- 384
        {hAlign = "Left", vAlign = "Bottom"}, -- 384
        React:createElement( -- 384
            "menu", -- 384
            nil, -- 384
            React:createElement( -- 384
                CircleButton, -- 386
                { -- 386
                    text = "Left\n(a)", -- 386
                    x = 20 * uiScale, -- 386
                    y = 60 * uiScale, -- 386
                    anchorX = 0, -- 386
                    anchorY = 0, -- 386
                    onTapBegan = function() return updatePlayerControl("keyLeft", true, true) end, -- 386
                    onTapEnded = function() return updatePlayerControl("keyLeft", false, true) end -- 386
                } -- 386
            ), -- 386
            React:createElement( -- 386
                CircleButton, -- 391
                { -- 391
                    text = "Right\n(a)", -- 391
                    x = 90 * uiScale, -- 391
                    y = 60 * uiScale, -- 391
                    anchorX = 0, -- 391
                    anchorY = 0, -- 391
                    onTapBegan = function() return updatePlayerControl("keyRight", true, true) end, -- 391
                    onTapEnded = function() return updatePlayerControl("keyRight", false, true) end -- 391
                } -- 391
            ) -- 391
        ) -- 391
    ), -- 391
    React:createElement( -- 391
        AlignNode, -- 398
        {hAlign = "Right", vAlign = "Bottom"}, -- 398
        React:createElement( -- 398
            "menu", -- 398
            nil, -- 398
            React:createElement( -- 398
                CircleButton, -- 400
                { -- 400
                    text = "Jump\n(j)", -- 400
                    x = -80 * uiScale, -- 400
                    y = 60 * uiScale, -- 400
                    anchorX = 0, -- 400
                    anchorY = 0, -- 400
                    onTapBegan = function() return updatePlayerControl("keyJump", true, true) end, -- 400
                    onTapEnded = function() return updatePlayerControl("keyJump", false, true) end -- 400
                } -- 400
            ) -- 400
        ) -- 400
    ) -- 400
)) -- 400
if ui then -- 400
    local alignNode = ui -- 411
    alignNode:addTo(Director.ui) -- 412
    alignNode:alignLayout() -- 413
    alignNode:schedule(function() -- 414
        local keyA = Keyboard:isKeyPressed("A") -- 415
        local keyD = Keyboard:isKeyPressed("D") -- 416
        local keyJ = Keyboard:isKeyPressed("J") -- 417
        if keyD or keyD or keyJ then -- 417
            keyboardEnabled = true -- 419
        end -- 419
        if not keyboardEnabled then -- 419
            return false -- 422
        end -- 422
        updatePlayerControl("keyLeft", keyA, false) -- 424
        updatePlayerControl("keyRight", keyD, false) -- 425
        updatePlayerControl("keyJump", keyJ, false) -- 426
        return false -- 427
    end) -- 414
end -- 414
local pickedItemGroup = Group({"picked"}) -- 431
local windowFlags = { -- 432
    "NoDecoration", -- 433
    "AlwaysAutoResize", -- 434
    "NoSavedSettings", -- 435
    "NoFocusOnAppearing", -- 436
    "NoNav", -- 437
    "NoMove" -- 438
} -- 438
Director.ui:schedule(function() -- 440
    local size = App.visualSize -- 441
    ImGui.SetNextWindowBgAlpha(0.35) -- 442
    ImGui.SetNextWindowPos( -- 443
        Vec2(size.width - 10, 10), -- 443
        "Always", -- 443
        Vec2(1, 0) -- 443
    ) -- 443
    ImGui.SetNextWindowSize( -- 444
        Vec2(100, 300), -- 444
        "FirstUseEver" -- 444
    ) -- 444
    ImGui.Begin( -- 445
        "BackPack", -- 445
        windowFlags, -- 445
        function() -- 445
            if ImGui.Button("重新加载Excel") then -- 445
                loadExcel() -- 447
            end -- 447
            ImGui.Separator() -- 449
            ImGui.Dummy(Vec2(100, 10)) -- 450
            ImGui.Text("背包 (TSX)") -- 451
            ImGui.Separator() -- 452
            ImGui.Columns(3, false) -- 453
            pickedItemGroup:each(function(e) -- 454
                local item = e -- 455
                if item.num > 0 then -- 455
                    if ImGui.ImageButton( -- 455
                        "item" .. tostring(item.no), -- 457
                        item.icon, -- 457
                        Vec2(50, 50) -- 457
                    ) then -- 457
                        item.num = item.num - 1 -- 458
                        local sprite = Sprite(item.icon) -- 459
                        if not sprite then -- 459
                            return false -- 460
                        end -- 460
                        sprite.scaleY = 0.5 -- 461
                        sprite.scaleX = 0.5 -- 461
                        sprite:perform(Spawn( -- 462
                            Opacity(1, 1, 0), -- 463
                            Y(1, 150, 250) -- 464
                        )) -- 464
                        local player = playerGroup:find(function() return true end) -- 466
                        if player ~= nil then -- 466
                            local unit = player.unit -- 468
                            unit:addChild(sprite) -- 469
                        end -- 469
                    end -- 469
                    if ImGui.IsItemHovered() then -- 469
                        ImGui.BeginTooltip(function() -- 473
                            ImGui.Text(item.name) -- 474
                            ImGui.TextColored(themeColor, "数量：") -- 475
                            ImGui.SameLine() -- 476
                            ImGui.Text(tostring(item.num)) -- 477
                            ImGui.TextColored(themeColor, "描述：") -- 478
                            ImGui.SameLine() -- 479
                            ImGui.Text(tostring(item.desc)) -- 480
                        end) -- 473
                    end -- 473
                    ImGui.NextColumn() -- 483
                end -- 483
                return false -- 485
            end) -- 454
        end -- 445
    ) -- 445
    return false -- 488
end) -- 440
Entity({player = true}) -- 491
loadExcel() -- 492
return ____exports -- 492