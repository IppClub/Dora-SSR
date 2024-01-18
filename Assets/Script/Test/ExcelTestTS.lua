-- [ts]: ExcelTestTS.ts
local ____exports = {} -- 1
local ____Platformer = require("Platformer") -- 1
local Data = ____Platformer.Data -- 1
local Decision = ____Platformer.Decision -- 1
local PlatformWorld = ____Platformer.PlatformWorld -- 1
local Unit = ____Platformer.Unit -- 1
local UnitAction = ____Platformer.UnitAction -- 1
local ____dora = require("dora") -- 2
local App = ____dora.App -- 2
local Body = ____dora.Body -- 2
local BodyDef = ____dora.BodyDef -- 2
local Color = ____dora.Color -- 2
local Dictionary = ____dora.Dictionary -- 2
local Rect = ____dora.Rect -- 2
local Size = ____dora.Size -- 2
local Vec2 = ____dora.Vec2 -- 2
local View = ____dora.View -- 2
local loop = ____dora.loop -- 2
local once = ____dora.once -- 2
local sleep = ____dora.sleep -- 2
local Array = ____dora.Array -- 2
local Observer = ____dora.Observer -- 2
local Sprite = ____dora.Sprite -- 2
local Spawn = ____dora.Spawn -- 2
local AngleY = ____dora.AngleY -- 2
local Sequence = ____dora.Sequence -- 2
local Ease = ____dora.Ease -- 2
local Y = ____dora.Y -- 2
local tolua = ____dora.tolua -- 2
local Scale = ____dora.Scale -- 2
local Opacity = ____dora.Opacity -- 2
local Content = ____dora.Content -- 2
local Group = ____dora.Group -- 2
local Entity = ____dora.Entity -- 2
local Director = ____dora.Director -- 2
local Menu = ____dora.Menu -- 2
local Keyboard = ____dora.Keyboard -- 2
local Rectangle = require("UI.View.Shape.Rectangle") -- 3
local ____Utils = require("Utils") -- 286
local Struct = ____Utils.Struct -- 286
local AlignNode = require("UI.Control.Basic.AlignNode") -- 336
local CircleButton = require("UI.Control.Basic.CircleButton") -- 337
local ImGui = require("ImGui") -- 340
local TerrainLayer = 0 -- 5
local PlayerLayer = 1 -- 6
local ItemLayer = 2 -- 7
local PlayerGroup = Data.groupFirstPlayer -- 9
local ItemGroup = Data.groupFirstPlayer + 1 -- 10
local TerrainGroup = Data.groupTerrain -- 11
Data:setShouldContact(PlayerGroup, ItemGroup, true) -- 13
local themeColor = App.themeColor -- 15
local fillColor = Color( -- 16
    themeColor:toColor3(), -- 16
    102 -- 16
):toARGB() -- 16
local borderColor = themeColor:toARGB() -- 17
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
local terrainDef = BodyDef() -- 28
terrainDef.type = "Static" -- 29
terrainDef:attachPolygon( -- 30
    Vec2(0, -500), -- 30
    2500, -- 30
    10, -- 30
    0, -- 30
    1, -- 30
    1, -- 30
    0 -- 30
) -- 30
terrainDef:attachPolygon( -- 31
    Vec2(0, 500), -- 31
    2500, -- 31
    10, -- 31
    0, -- 31
    1, -- 31
    1, -- 31
    0 -- 31
) -- 31
terrainDef:attachPolygon( -- 32
    Vec2(1250, 0), -- 32
    10, -- 32
    1000, -- 32
    0, -- 32
    1, -- 32
    1, -- 32
    0 -- 32
) -- 32
terrainDef:attachPolygon( -- 33
    Vec2(-1250, 0), -- 33
    10, -- 33
    1000, -- 33
    0, -- 33
    1, -- 33
    1, -- 33
    0 -- 33
) -- 33
local terrain = Body(terrainDef, world, Vec2.zero) -- 35
terrain.order = TerrainLayer -- 36
terrain.group = TerrainGroup -- 37
terrain:addChild(Rectangle({ -- 38
    y = -500, -- 39
    width = 2500, -- 40
    height = 10, -- 41
    fillColor = fillColor, -- 42
    borderColor = borderColor, -- 43
    fillOrder = 1, -- 44
    lineOrder = 2 -- 45
})) -- 45
terrain:addChild(Rectangle({ -- 47
    x = 1250, -- 48
    y = 0, -- 49
    width = 10, -- 50
    height = 1000, -- 51
    fillColor = fillColor, -- 52
    borderColor = borderColor, -- 53
    fillOrder = 1, -- 54
    lineOrder = 2 -- 55
})) -- 55
terrain:addChild(Rectangle({ -- 57
    x = -1250, -- 58
    y = 0, -- 59
    width = 10, -- 60
    height = 1000, -- 61
    fillColor = fillColor, -- 62
    borderColor = borderColor, -- 63
    fillOrder = 1, -- 64
    lineOrder = 2 -- 65
})) -- 65
world:addChild(terrain) -- 67
UnitAction:add( -- 69
    "idle", -- 69
    { -- 69
        priority = 1, -- 70
        reaction = 2, -- 71
        recovery = 0.2, -- 72
        available = function(____self) -- 73
            return ____self.onSurface -- 74
        end, -- 73
        create = function(____self) -- 76
            local ____self_0 = ____self -- 77
            local playable = ____self_0.playable -- 77
            playable.speed = 1 -- 78
            playable:play("idle", true) -- 79
            local playIdleSpecial = loop(function() -- 80
                sleep(3) -- 81
                sleep(playable:play("idle1")) -- 82
                playable:play("idle", true) -- 83
                return false -- 84
            end) -- 80
            ____self.data.playIdleSpecial = playIdleSpecial -- 86
            return function(owner) -- 87
                coroutine.resume(playIdleSpecial) -- 88
                return not owner.onSurface -- 89
            end -- 87
        end -- 76
    } -- 76
) -- 76
UnitAction:add( -- 94
    "move", -- 94
    { -- 94
        priority = 1, -- 95
        reaction = 2, -- 96
        recovery = 0.2, -- 97
        available = function(____self) -- 98
            return ____self.onSurface -- 99
        end, -- 98
        create = function(____self) -- 101
            local ____self_1 = ____self -- 102
            local playable = ____self_1.playable -- 102
            playable.speed = 1 -- 103
            playable:play("fmove", true) -- 104
            return function(____self, action) -- 105
                local ____action_2 = action -- 106
                local elapsedTime = ____action_2.elapsedTime -- 106
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
        available = function(____self) -- 124
            return ____self.onSurface -- 125
        end, -- 124
        create = function(____self) -- 127
            local jump = ____self.unitDef.jump -- 128
            ____self.velocityY = jump -- 129
            return once(function() -- 130
                local ____self_3 = ____self -- 131
                local playable = ____self_3.playable -- 131
                playable.speed = 1 -- 132
                sleep(playable:play("jump", false)) -- 133
            end) -- 130
        end -- 127
    } -- 127
) -- 127
UnitAction:add( -- 138
    "fallOff", -- 138
    { -- 138
        priority = 2, -- 139
        reaction = -1, -- 140
        recovery = 0.3, -- 141
        available = function(____self) -- 142
            return not ____self.onSurface -- 143
        end, -- 142
        create = function(____self) -- 145
            if ____self.playable.current ~= "jumping" then -- 145
                local ____self_4 = ____self -- 147
                local playable = ____self_4.playable -- 147
                playable.speed = 1 -- 148
                playable:play("jumping", true) -- 149
            end -- 149
            return loop(function() -- 151
                if ____self.onSurface then -- 151
                    local ____self_5 = ____self -- 153
                    local playable = ____self_5.playable -- 153
                    playable.speed = 1 -- 154
                    sleep(playable:play("landing", false)) -- 155
                    return true -- 156
                end -- 156
                return false -- 158
            end) -- 151
        end -- 145
    } -- 145
) -- 145
local ____Decision_6 = Decision -- 163
local Sel = ____Decision_6.Sel -- 163
local Seq = ____Decision_6.Seq -- 163
local Con = ____Decision_6.Con -- 163
local Act = ____Decision_6.Act -- 163
Data.store["AI:playerControl"] = Sel({ -- 165
    Seq({ -- 166
        Con( -- 167
            "fmove key down", -- 167
            function(____self) -- 167
                local keyLeft = ____self.entity.keyLeft -- 168
                local keyRight = ____self.entity.keyRight -- 169
                return not (keyLeft and keyRight) and (keyLeft and ____self.faceRight or keyRight and not ____self.faceRight) -- 170
            end -- 167
        ), -- 167
        Act("turn") -- 176
    }), -- 176
    Seq({ -- 178
        Con( -- 179
            "is falling", -- 179
            function(____self) -- 179
                return not ____self.onSurface -- 180
            end -- 179
        ), -- 179
        Act("fallOff") -- 182
    }), -- 182
    Seq({ -- 184
        Con( -- 185
            "jump key down", -- 185
            function(____self) -- 185
                return ____self.entity.keyJump -- 186
            end -- 185
        ), -- 185
        Act("jump") -- 188
    }), -- 188
    Seq({ -- 190
        Con( -- 191
            "fmove key down", -- 191
            function(____self) -- 191
                return ____self.entity.keyLeft or ____self.entity.keyRight -- 192
            end -- 191
        ), -- 191
        Act("move") -- 194
    }), -- 194
    Act("idle") -- 196
}) -- 196
local unitDef = Dictionary() -- 199
unitDef.linearAcceleration = Vec2(0, -15) -- 200
unitDef.bodyType = "Dynamic" -- 201
unitDef.scale = 1 -- 202
unitDef.density = 1 -- 203
unitDef.friction = 1 -- 204
unitDef.restitution = 0 -- 205
unitDef.playable = "spine:Spine/moling" -- 206
unitDef.defaultFaceRight = true -- 207
unitDef.size = Size(60, 300) -- 208
unitDef.sensity = 0 -- 209
unitDef.move = 300 -- 210
unitDef.jump = 1000 -- 211
unitDef.detectDistance = 350 -- 212
unitDef.hp = 5 -- 213
unitDef.tag = "player" -- 214
unitDef.decisionTree = "AI:playerControl" -- 215
unitDef.usePreciseHit = false -- 216
unitDef.actions = Array({ -- 217
    "idle", -- 218
    "turn", -- 219
    "move", -- 220
    "jump", -- 221
    "fallOff", -- 222
    "cancel" -- 223
}) -- 223
Observer("Add", {"player"}):watch(function(____self) -- 226
    local unit = Unit( -- 227
        unitDef, -- 227
        world, -- 227
        ____self, -- 227
        Vec2(300, -350) -- 227
    ) -- 227
    unit.order = PlayerLayer -- 228
    unit.group = PlayerGroup -- 229
    unit.playable.position = Vec2(0, -150) -- 230
    unit.playable:play("idle", true) -- 231
    world:addChild(unit) -- 232
    world.camera.followTarget = unit -- 233
end) -- 226
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 236
    local sprite = Sprite(icon) -- 237
    if not sprite then -- 237
        return -- 238
    end -- 238
    sprite:schedule(loop(function() -- 239
        sleep(sprite:runAction(Spawn( -- 240
            AngleY(5, 0, 360), -- 241
            Sequence( -- 242
                Y(2.5, 0, 40, Ease.OutQuad), -- 243
                Y(2.5, 40, 0, Ease.InQuad) -- 244
            ) -- 244
        ))) -- 244
        return false -- 247
    end)) -- 239
    local bodyDef = BodyDef() -- 250
    bodyDef.type = "Dynamic" -- 251
    bodyDef.linearAcceleration = Vec2(0, -10) -- 252
    bodyDef:attachPolygon(sprite.width * 0.5, sprite.height) -- 253
    bodyDef:attachPolygonSensor(0, sprite.width, sprite.height) -- 254
    local body = Body( -- 256
        bodyDef, -- 256
        world, -- 256
        Vec2(x, 0) -- 256
    ) -- 256
    body.order = ItemLayer -- 257
    body.group = ItemGroup -- 258
    body:addChild(sprite) -- 259
    body:slot( -- 261
        "BodyEnter", -- 261
        function(item) -- 261
            if tolua.type(item) == "Platformer::Unit" then -- 261
                ____self.picked = true -- 263
                body.group = Data.groupHide -- 264
                body:schedule(once(function() -- 265
                    sleep(sprite:runAction(Spawn( -- 266
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 267
                        Opacity(0.2, 1, 0) -- 268
                    ))) -- 268
                    ____self.body = nil -- 270
                end)) -- 265
            end -- 265
        end -- 261
    ) -- 261
    world:addChild(body) -- 275
    ____self.body = body -- 276
end) -- 236
Observer("Remove", {"body"}):watch(function(____self) -- 279
    local body = tolua.cast(____self.oldValues.body, "Body") -- 280
    if body ~= nil then -- 280
        body:removeFromParent() -- 282
    end -- 282
end) -- 279
local function loadExcel() -- 307
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 308
    if xlsx ~= nil then -- 308
        local its = xlsx.items -- 310
        local names = its[2] -- 311
        table.remove(names, 1) -- 312
        if not Struct:has("Item") then -- 312
            Struct.Item(names) -- 314
        end -- 314
        Group({"item"}):each(function(e) -- 316
            e:destroy() -- 317
            return false -- 318
        end) -- 316
        do -- 316
            local i = 2 -- 320
            while i < #its do -- 320
                local st = Struct:load(its[i + 1]) -- 321
                local item = { -- 322
                    name = st.Name, -- 323
                    no = st.No, -- 324
                    x = st.X, -- 325
                    num = st.Num, -- 326
                    icon = st.Icon, -- 327
                    desc = st.Desc, -- 328
                    item = true -- 329
                } -- 329
                Entity(item) -- 331
                i = i + 1 -- 320
            end -- 320
        end -- 320
    end -- 320
end -- 307
local keyboardEnabled = true -- 342
local playerGroup = Group({"player"}) -- 344
local function updatePlayerControl(key, flag, vpad) -- 345
    if keyboardEnabled and vpad then -- 345
        keyboardEnabled = false -- 347
    end -- 347
    playerGroup:each(function(____self) -- 349
        ____self[key] = flag -- 350
        return false -- 351
    end) -- 349
end -- 345
local uiScale = App.devicePixelRatio -- 355
local alignNode = AlignNode({isRoot = true, inUI = true}) -- 356
Director.ui:addChild(alignNode) -- 360
local leftAlign = AlignNode({hAlign = "Left", vAlign = "Bottom"}) -- 362
alignNode:addChild(leftAlign) -- 366
local leftMenu = Menu() -- 368
leftAlign:addChild(leftMenu) -- 369
local leftButton = CircleButton({ -- 371
    text = "左(a)", -- 372
    x = 20 * uiScale, -- 373
    y = 60 * uiScale, -- 374
    radius = 30 * uiScale, -- 375
    fontSize = math.floor(18 * uiScale) -- 376
}) -- 376
leftButton.anchor = Vec2.zero -- 378
leftButton:slot( -- 379
    "TapBegan", -- 379
    function() -- 379
        updatePlayerControl("keyLeft", true, true) -- 380
    end -- 379
) -- 379
leftButton:slot( -- 382
    "TapEnded", -- 382
    function() -- 382
        updatePlayerControl("keyLeft", false, true) -- 383
    end -- 382
) -- 382
leftMenu:addChild(leftButton) -- 385
local rightButton = CircleButton({ -- 387
    text = "右(d)", -- 388
    x = 90 * uiScale, -- 389
    y = 60 * uiScale, -- 390
    radius = 30 * uiScale, -- 391
    fontSize = math.floor(18 * uiScale) -- 392
}) -- 392
rightButton.anchor = Vec2.zero -- 394
rightButton:slot( -- 395
    "TapBegan", -- 395
    function() -- 395
        updatePlayerControl("keyRight", true, true) -- 396
    end -- 395
) -- 395
rightButton:slot( -- 398
    "TapEnded", -- 398
    function() -- 398
        updatePlayerControl("keyRight", false, true) -- 399
    end -- 398
) -- 398
leftMenu:addChild(rightButton) -- 401
local rightAlign = AlignNode({hAlign = "Right", vAlign = "Bottom"}) -- 403
alignNode:addChild(rightAlign) -- 407
local rightMenu = Menu() -- 409
rightAlign:addChild(rightMenu) -- 410
local jumpButton = CircleButton({ -- 412
    text = "跳(j)", -- 413
    x = -80 * uiScale, -- 414
    y = 60 * uiScale, -- 415
    radius = 30 * uiScale, -- 416
    fontSize = math.floor(18 * uiScale) -- 417
}) -- 417
jumpButton.anchor = Vec2.zero -- 419
jumpButton:slot( -- 420
    "TapBegan", -- 420
    function() -- 420
        updatePlayerControl("keyJump", true, true) -- 421
    end -- 420
) -- 420
jumpButton:slot( -- 423
    "TapEnded", -- 423
    function() -- 423
        updatePlayerControl("keyJump", false, true) -- 424
    end -- 423
) -- 423
rightMenu:addChild(jumpButton) -- 426
alignNode:alignLayout() -- 428
alignNode:schedule(function() -- 430
    local keyA = Keyboard:isKeyPressed("A") -- 431
    local keyD = Keyboard:isKeyPressed("D") -- 432
    local keyJ = Keyboard:isKeyPressed("J") -- 433
    if keyD or keyD or keyJ then -- 433
        keyboardEnabled = true -- 435
    end -- 435
    if not keyboardEnabled then -- 435
        return false -- 438
    end -- 438
    updatePlayerControl("keyLeft", keyA, false) -- 440
    updatePlayerControl("keyRight", keyD, false) -- 441
    updatePlayerControl("keyJump", keyJ, false) -- 442
    return false -- 443
end) -- 430
local pickedItemGroup = Group({"picked"}) -- 446
local windowFlags = { -- 447
    "NoDecoration", -- 448
    "AlwaysAutoResize", -- 449
    "NoSavedSettings", -- 450
    "NoFocusOnAppearing", -- 451
    "NoNav", -- 452
    "NoMove" -- 453
} -- 453
Director.ui:schedule(function() -- 455
    local size = App.visualSize -- 456
    ImGui.SetNextWindowBgAlpha(0.35) -- 457
    ImGui.SetNextWindowPos( -- 458
        Vec2(size.width - 10, 10), -- 458
        "Always", -- 458
        Vec2(1, 0) -- 458
    ) -- 458
    ImGui.SetNextWindowSize( -- 459
        Vec2(100, 300), -- 459
        "FirstUseEver" -- 459
    ) -- 459
    ImGui.Begin( -- 460
        "BackPack", -- 460
        windowFlags, -- 460
        function() -- 460
            if ImGui.Button("重新加载Excel") then -- 460
                loadExcel() -- 462
            end -- 462
            ImGui.Separator() -- 464
            ImGui.Dummy(Vec2(100, 10)) -- 465
            ImGui.Text("背包") -- 466
            ImGui.Separator() -- 467
            ImGui.Columns(3, false) -- 468
            pickedItemGroup:each(function(e) -- 469
                local item = e -- 470
                if item.num > 0 then -- 470
                    if ImGui.ImageButton( -- 470
                        "item" .. tostring(item.no), -- 472
                        item.icon, -- 472
                        Vec2(50, 50) -- 472
                    ) then -- 472
                        item.num = item.num - 1 -- 473
                        local sprite = Sprite(item.icon) -- 474
                        if not sprite then -- 474
                            return false -- 475
                        end -- 475
                        sprite.scaleX = 0.5 -- 476
                        sprite.scaleY = 0.5 -- 477
                        sprite:perform(Spawn( -- 478
                            Opacity(1, 1, 0), -- 479
                            Y(1, 150, 250) -- 480
                        )) -- 480
                        local player = playerGroup:find(function() return true end) -- 482
                        if player ~= nil then -- 482
                            local unit = player.unit -- 484
                            unit:addChild(sprite) -- 485
                        end -- 485
                    end -- 485
                    if ImGui.IsItemHovered() then -- 485
                        ImGui.BeginTooltip(function() -- 489
                            ImGui.Text(item.name) -- 490
                            ImGui.TextColored(themeColor, "数量：") -- 491
                            ImGui.SameLine() -- 492
                            ImGui.Text(tostring(item.num)) -- 493
                            ImGui.TextColored(themeColor, "描述：") -- 494
                            ImGui.SameLine() -- 495
                            ImGui.Text(tostring(item.desc)) -- 496
                        end) -- 489
                    end -- 489
                    ImGui.NextColumn() -- 499
                end -- 499
                return false -- 501
            end) -- 469
        end -- 460
    ) -- 460
    return false -- 504
end) -- 455
Entity({player = true}) -- 507
loadExcel() -- 508
return ____exports -- 508