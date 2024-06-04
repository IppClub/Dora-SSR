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
local CircleButtonCreate = require("UI.Control.Basic.CircleButton") -- 333
local ImGui = require("ImGui") -- 335
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
local keyboardEnabled = true -- 337
local playerGroup = Group({"player"}) -- 339
local function updatePlayerControl(key, flag, vpad) -- 340
    if keyboardEnabled and vpad then -- 340
        keyboardEnabled = false -- 342
    end -- 342
    playerGroup:each(function(____self) -- 344
        ____self[key] = flag -- 345
        return false -- 346
    end) -- 344
end -- 340
local function CircleButton(self, props) -- 354
    return React:createElement( -- 355
        "custom-node", -- 355
        __TS__ObjectAssign( -- 355
            {onCreate = function() return CircleButtonCreate({text = props.text, radius = 60, fontSize = 36}) end}, -- 355
            props -- 359
        ) -- 359
    ) -- 359
end -- 354
local ui = toNode(React:createElement( -- 362
    "align-node", -- 362
    { -- 362
        windowRoot = true, -- 362
        style = {flexDirection = "column-reverse"}, -- 362
        onButtonDown = function(id, buttonName) -- 362
            if id ~= 0 then -- 362
                return -- 365
            end -- 365
            repeat -- 365
                local ____switch45 = buttonName -- 365
                local ____cond45 = ____switch45 == "dpleft" -- 365
                if ____cond45 then -- 365
                    updatePlayerControl("keyLeft", true, true) -- 367
                    break -- 367
                end -- 367
                ____cond45 = ____cond45 or ____switch45 == "dpright" -- 367
                if ____cond45 then -- 367
                    updatePlayerControl("keyRight", true, true) -- 368
                    break -- 368
                end -- 368
                ____cond45 = ____cond45 or ____switch45 == "b" -- 368
                if ____cond45 then -- 368
                    updatePlayerControl("keyJump", true, true) -- 369
                    break -- 369
                end -- 369
            until true -- 369
        end, -- 364
        onButtonUp = function(id, buttonName) -- 364
            if id ~= 0 then -- 364
                return -- 373
            end -- 373
            repeat -- 373
                local ____switch48 = buttonName -- 373
                local ____cond48 = ____switch48 == "dpleft" -- 373
                if ____cond48 then -- 373
                    updatePlayerControl("keyLeft", false, true) -- 375
                    break -- 375
                end -- 375
                ____cond48 = ____cond48 or ____switch48 == "dpright" -- 375
                if ____cond48 then -- 375
                    updatePlayerControl("keyRight", false, true) -- 376
                    break -- 376
                end -- 376
                ____cond48 = ____cond48 or ____switch48 == "b" -- 376
                if ____cond48 then -- 376
                    updatePlayerControl("keyJump", false, true) -- 377
                    break -- 377
                end -- 377
            until true -- 377
        end -- 372
    }, -- 372
    React:createElement( -- 372
        "align-node", -- 372
        {style = {height = 60, justifyContent = "space-between", margin = {0, 20, 40}, flexDirection = "row"}}, -- 372
        React:createElement( -- 372
            "align-node", -- 372
            {style = {width = 130, height = 60}}, -- 372
            React:createElement( -- 372
                "menu", -- 372
                { -- 372
                    width = 250, -- 372
                    height = 120, -- 372
                    anchorX = 0, -- 372
                    anchorY = 0, -- 372
                    scaleX = 0.5, -- 372
                    scaleY = 0.5 -- 372
                }, -- 372
                React:createElement( -- 372
                    CircleButton, -- 383
                    { -- 383
                        text = "Left\n(a)", -- 383
                        anchorX = 0, -- 383
                        anchorY = 0, -- 383
                        onTapBegan = function() return updatePlayerControl("keyLeft", true, true) end, -- 383
                        onTapEnded = function() return updatePlayerControl("keyLeft", false, true) end -- 383
                    } -- 383
                ), -- 383
                React:createElement( -- 383
                    CircleButton, -- 388
                    { -- 388
                        text = "Right\n(a)", -- 388
                        x = 130, -- 388
                        anchorX = 0, -- 388
                        anchorY = 0, -- 388
                        onTapBegan = function() return updatePlayerControl("keyRight", true, true) end, -- 388
                        onTapEnded = function() return updatePlayerControl("keyRight", false, true) end -- 388
                    } -- 388
                ) -- 388
            ) -- 388
        ), -- 388
        React:createElement( -- 388
            "align-node", -- 388
            {style = {width = 60, height = 60}}, -- 388
            React:createElement( -- 388
                "menu", -- 388
                { -- 388
                    width = 120, -- 388
                    height = 120, -- 388
                    anchorX = 0, -- 388
                    anchorY = 0, -- 388
                    scaleX = 0.5, -- 388
                    scaleY = 0.5 -- 388
                }, -- 388
                React:createElement( -- 388
                    CircleButton, -- 397
                    { -- 397
                        text = "Jump\n(j)", -- 397
                        anchorX = 0, -- 397
                        anchorY = 0, -- 397
                        onTapBegan = function() return updatePlayerControl("keyJump", true, true) end, -- 397
                        onTapEnded = function() return updatePlayerControl("keyJump", false, true) end -- 397
                    } -- 397
                ) -- 397
            ) -- 397
        ) -- 397
    ) -- 397
)) -- 397
if ui then -- 397
    ui:addTo(Director.ui) -- 409
    ui:schedule(function() -- 410
        local keyA = Keyboard:isKeyPressed("A") -- 411
        local keyD = Keyboard:isKeyPressed("D") -- 412
        local keyJ = Keyboard:isKeyPressed("J") -- 413
        if keyD or keyD or keyJ then -- 413
            keyboardEnabled = true -- 415
        end -- 415
        if not keyboardEnabled then -- 415
            return false -- 418
        end -- 418
        updatePlayerControl("keyLeft", keyA, false) -- 420
        updatePlayerControl("keyRight", keyD, false) -- 421
        updatePlayerControl("keyJump", keyJ, false) -- 422
        return false -- 423
    end) -- 410
end -- 410
local pickedItemGroup = Group({"picked"}) -- 427
local windowFlags = { -- 428
    "NoDecoration", -- 429
    "AlwaysAutoResize", -- 430
    "NoSavedSettings", -- 431
    "NoFocusOnAppearing", -- 432
    "NoNav", -- 433
    "NoMove" -- 434
} -- 434
Director.ui:schedule(function() -- 436
    local size = App.visualSize -- 437
    ImGui.SetNextWindowBgAlpha(0.35) -- 438
    ImGui.SetNextWindowPos( -- 439
        Vec2(size.width - 10, 10), -- 439
        "Always", -- 439
        Vec2(1, 0) -- 439
    ) -- 439
    ImGui.SetNextWindowSize( -- 440
        Vec2(100, 300), -- 440
        "FirstUseEver" -- 440
    ) -- 440
    ImGui.Begin( -- 441
        "BackPack", -- 441
        windowFlags, -- 441
        function() -- 441
            if ImGui.Button("重新加载Excel") then -- 441
                loadExcel() -- 443
            end -- 443
            ImGui.Separator() -- 445
            ImGui.Dummy(Vec2(100, 10)) -- 446
            ImGui.Text("背包 (TSX)") -- 447
            ImGui.Separator() -- 448
            ImGui.Columns(3, false) -- 449
            pickedItemGroup:each(function(e) -- 450
                local item = e -- 451
                if item.num > 0 then -- 451
                    if ImGui.ImageButton( -- 451
                        "item" .. tostring(item.no), -- 453
                        item.icon, -- 453
                        Vec2(50, 50) -- 453
                    ) then -- 453
                        item.num = item.num - 1 -- 454
                        local sprite = Sprite(item.icon) -- 455
                        if not sprite then -- 455
                            return false -- 456
                        end -- 456
                        sprite.scaleY = 0.5 -- 457
                        sprite.scaleX = 0.5 -- 457
                        sprite:perform(Spawn( -- 458
                            Opacity(1, 1, 0), -- 459
                            Y(1, 150, 250) -- 460
                        )) -- 460
                        local player = playerGroup:find(function() return true end) -- 462
                        if player ~= nil then -- 462
                            local unit = player.unit -- 464
                            unit:addChild(sprite) -- 465
                        end -- 465
                    end -- 465
                    if ImGui.IsItemHovered() then -- 465
                        ImGui.BeginTooltip(function() -- 469
                            ImGui.Text(item.name) -- 470
                            ImGui.TextColored(themeColor, "数量：") -- 471
                            ImGui.SameLine() -- 472
                            ImGui.Text(tostring(item.num)) -- 473
                            ImGui.TextColored(themeColor, "描述：") -- 474
                            ImGui.SameLine() -- 475
                            ImGui.Text(tostring(item.desc)) -- 476
                        end) -- 469
                    end -- 469
                    ImGui.NextColumn() -- 479
                end -- 479
                return false -- 481
            end) -- 450
        end -- 441
    ) -- 441
    return false -- 484
end) -- 436
Entity({player = true}) -- 487
loadExcel() -- 488
return ____exports -- 488