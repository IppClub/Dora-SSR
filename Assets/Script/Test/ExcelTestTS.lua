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
local ____Utils = require("Utils") -- 282
local Struct = ____Utils.Struct -- 282
local AlignNode = require("UI.Control.Basic.AlignNode") -- 332
local CircleButton = require("UI.Control.Basic.CircleButton") -- 333
local ImGui = require("ImGui") -- 336
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
    sprite:schedule(loop(function() -- 238
        sleep(sprite:runAction(Spawn( -- 239
            AngleY(5, 0, 360), -- 240
            Sequence( -- 241
                Y(2.5, 0, 40, Ease.OutQuad), -- 242
                Y(2.5, 40, 0, Ease.InQuad) -- 243
            ) -- 243
        ))) -- 243
        return false -- 246
    end)) -- 238
    local bodyDef = BodyDef() -- 249
    bodyDef.type = "Dynamic" -- 250
    bodyDef.linearAcceleration = Vec2(0, -10) -- 251
    bodyDef:attachPolygon(sprite.width * 0.5, sprite.height) -- 252
    bodyDef:attachPolygonSensor(0, sprite.width, sprite.height) -- 253
    local body = Body( -- 255
        bodyDef, -- 255
        world, -- 255
        Vec2(x, 0) -- 255
    ) -- 255
    body.order = ItemLayer -- 256
    body.group = ItemGroup -- 257
    body:addChild(sprite) -- 258
    body:slot( -- 260
        "BodyEnter", -- 260
        function(item) -- 260
            if tolua.type(item) == "Platformer::Unit" then -- 260
                ____self.picked = true -- 262
                body.group = Data.groupHide -- 263
                body:schedule(once(function() -- 264
                    sleep(sprite:runAction(Spawn( -- 265
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 266
                        Opacity(0.2, 1, 0) -- 267
                    ))) -- 267
                    ____self.body = nil -- 269
                end)) -- 264
            end -- 264
        end -- 260
    ) -- 260
    world:addChild(body) -- 274
    ____self.body = body -- 275
end) -- 236
Observer("Remove", {"body"}):watch(function(____self) -- 278
    ____self.oldValues.body:removeFromParent() -- 279
end) -- 278
local function loadExcel() -- 303
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 304
    if xlsx ~= nil then -- 304
        local its = xlsx.items -- 306
        local names = its[2] -- 307
        table.remove(names, 1) -- 308
        if not Struct:has("Item") then -- 308
            Struct.Item(names) -- 310
        end -- 310
        Group({"item"}):each(function(e) -- 312
            e:destroy() -- 313
            return false -- 314
        end) -- 312
        do -- 312
            local i = 2 -- 316
            while i < #its do -- 316
                local st = Struct:load(its[i + 1]) -- 317
                local item = { -- 318
                    name = st.Name, -- 319
                    no = st.No, -- 320
                    x = st.X, -- 321
                    num = st.Num, -- 322
                    icon = st.Icon, -- 323
                    desc = st.Desc, -- 324
                    item = true -- 325
                } -- 325
                Entity(item) -- 327
                i = i + 1 -- 316
            end -- 316
        end -- 316
    end -- 316
end -- 303
local keyboardEnabled = true -- 338
local playerGroup = Group({"player"}) -- 340
local function updatePlayerControl(key, flag, vpad) -- 341
    if keyboardEnabled and vpad then -- 341
        keyboardEnabled = false -- 343
    end -- 343
    playerGroup:each(function(____self) -- 345
        ____self[key] = flag -- 346
        return false -- 347
    end) -- 345
end -- 341
local uiScale = App.devicePixelRatio -- 351
local alignNode = AlignNode({isRoot = true, inUI = true}) -- 352
Director.ui:addChild(alignNode) -- 356
local leftAlign = AlignNode({hAlign = "Left", vAlign = "Bottom"}) -- 358
alignNode:addChild(leftAlign) -- 362
local leftMenu = Menu() -- 364
leftAlign:addChild(leftMenu) -- 365
local leftButton = CircleButton({ -- 367
    text = "左(a)", -- 368
    x = 20 * uiScale, -- 369
    y = 60 * uiScale, -- 370
    radius = 30 * uiScale, -- 371
    fontSize = math.floor(18 * uiScale) -- 372
}) -- 372
leftButton.anchor = Vec2.zero -- 374
leftButton:slot( -- 375
    "TapBegan", -- 375
    function() -- 375
        updatePlayerControl("keyLeft", true, true) -- 376
    end -- 375
) -- 375
leftButton:slot( -- 378
    "TapEnded", -- 378
    function() -- 378
        updatePlayerControl("keyLeft", false, true) -- 379
    end -- 378
) -- 378
leftMenu:addChild(leftButton) -- 381
local rightButton = CircleButton({ -- 383
    text = "右(d)", -- 384
    x = 90 * uiScale, -- 385
    y = 60 * uiScale, -- 386
    radius = 30 * uiScale, -- 387
    fontSize = math.floor(18 * uiScale) -- 388
}) -- 388
rightButton.anchor = Vec2.zero -- 390
rightButton:slot( -- 391
    "TapBegan", -- 391
    function() -- 391
        updatePlayerControl("keyRight", true, true) -- 392
    end -- 391
) -- 391
rightButton:slot( -- 394
    "TapEnded", -- 394
    function() -- 394
        updatePlayerControl("keyRight", false, true) -- 395
    end -- 394
) -- 394
leftMenu:addChild(rightButton) -- 397
local rightAlign = AlignNode({hAlign = "Right", vAlign = "Bottom"}) -- 399
alignNode:addChild(rightAlign) -- 403
local rightMenu = Menu() -- 405
rightAlign:addChild(rightMenu) -- 406
local jumpButton = CircleButton({ -- 408
    text = "跳(j)", -- 409
    x = -80 * uiScale, -- 410
    y = 60 * uiScale, -- 411
    radius = 30 * uiScale, -- 412
    fontSize = math.floor(18 * uiScale) -- 413
}) -- 413
jumpButton.anchor = Vec2.zero -- 415
jumpButton:slot( -- 416
    "TapBegan", -- 416
    function() -- 416
        updatePlayerControl("keyJump", true, true) -- 417
    end -- 416
) -- 416
jumpButton:slot( -- 419
    "TapEnded", -- 419
    function() -- 419
        updatePlayerControl("keyJump", false, true) -- 420
    end -- 419
) -- 419
rightMenu:addChild(jumpButton) -- 422
alignNode:alignLayout() -- 424
alignNode:schedule(function() -- 426
    local keyA = Keyboard:isKeyPressed("A") -- 427
    local keyD = Keyboard:isKeyPressed("D") -- 428
    local keyJ = Keyboard:isKeyPressed("J") -- 429
    if keyD or keyD or keyJ then -- 429
        keyboardEnabled = true -- 431
    end -- 431
    if not keyboardEnabled then -- 431
        return false -- 434
    end -- 434
    updatePlayerControl("keyLeft", keyA, false) -- 436
    updatePlayerControl("keyRight", keyD, false) -- 437
    updatePlayerControl("keyJump", keyJ, false) -- 438
    return false -- 439
end) -- 426
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
            ImGui.Text("背包") -- 462
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
                        sprite.scaleX = 0.5 -- 471
                        sprite.scaleY = 0.5 -- 472
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