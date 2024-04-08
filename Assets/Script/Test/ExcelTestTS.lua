-- [ts]: ExcelTestTS.ts
local ____exports = {} -- 1
local ____Platformer = require("Platformer") -- 2
local Data = ____Platformer.Data -- 2
local Decision = ____Platformer.Decision -- 2
local PlatformWorld = ____Platformer.PlatformWorld -- 2
local Unit = ____Platformer.Unit -- 2
local UnitAction = ____Platformer.UnitAction -- 2
local ____dora = require("dora") -- 3
local App = ____dora.App -- 3
local Body = ____dora.Body -- 3
local BodyDef = ____dora.BodyDef -- 3
local Color = ____dora.Color -- 3
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
local AngleY = ____dora.AngleY -- 3
local Sequence = ____dora.Sequence -- 3
local Ease = ____dora.Ease -- 3
local Y = ____dora.Y -- 3
local tolua = ____dora.tolua -- 3
local Scale = ____dora.Scale -- 3
local Opacity = ____dora.Opacity -- 3
local Content = ____dora.Content -- 3
local Group = ____dora.Group -- 3
local Entity = ____dora.Entity -- 3
local Director = ____dora.Director -- 3
local Menu = ____dora.Menu -- 3
local Keyboard = ____dora.Keyboard -- 3
local Rectangle = require("UI.View.Shape.Rectangle") -- 4
local ____Utils = require("Utils") -- 287
local Struct = ____Utils.Struct -- 287
local AlignNode = require("UI.Control.Basic.AlignNode") -- 337
local CircleButton = require("UI.Control.Basic.CircleButton") -- 338
local ImGui = require("ImGui") -- 341
local TerrainLayer = 0 -- 6
local PlayerLayer = 1 -- 7
local ItemLayer = 2 -- 8
local PlayerGroup = Data.groupFirstPlayer -- 10
local ItemGroup = Data.groupFirstPlayer + 1 -- 11
local TerrainGroup = Data.groupTerrain -- 12
Data:setShouldContact(PlayerGroup, ItemGroup, true) -- 14
local themeColor = App.themeColor -- 16
local fillColor = Color( -- 17
    themeColor:toColor3(), -- 17
    102 -- 17
):toARGB() -- 17
local borderColor = themeColor:toARGB() -- 18
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
local terrainDef = BodyDef() -- 29
terrainDef.type = "Static" -- 30
terrainDef:attachPolygon( -- 31
    Vec2(0, -500), -- 31
    2500, -- 31
    10, -- 31
    0, -- 31
    1, -- 31
    1, -- 31
    0 -- 31
) -- 31
terrainDef:attachPolygon( -- 32
    Vec2(0, 500), -- 32
    2500, -- 32
    10, -- 32
    0, -- 32
    1, -- 32
    1, -- 32
    0 -- 32
) -- 32
terrainDef:attachPolygon( -- 33
    Vec2(1250, 0), -- 33
    10, -- 33
    1000, -- 33
    0, -- 33
    1, -- 33
    1, -- 33
    0 -- 33
) -- 33
terrainDef:attachPolygon( -- 34
    Vec2(-1250, 0), -- 34
    10, -- 34
    1000, -- 34
    0, -- 34
    1, -- 34
    1, -- 34
    0 -- 34
) -- 34
local terrain = Body(terrainDef, world, Vec2.zero) -- 36
terrain.order = TerrainLayer -- 37
terrain.group = TerrainGroup -- 38
terrain:addChild(Rectangle({ -- 39
    y = -500, -- 40
    width = 2500, -- 41
    height = 10, -- 42
    fillColor = fillColor, -- 43
    borderColor = borderColor, -- 44
    fillOrder = 1, -- 45
    lineOrder = 2 -- 46
})) -- 46
terrain:addChild(Rectangle({ -- 48
    x = 1250, -- 49
    y = 0, -- 50
    width = 10, -- 51
    height = 1000, -- 52
    fillColor = fillColor, -- 53
    borderColor = borderColor, -- 54
    fillOrder = 1, -- 55
    lineOrder = 2 -- 56
})) -- 56
terrain:addChild(Rectangle({ -- 58
    x = -1250, -- 59
    y = 0, -- 60
    width = 10, -- 61
    height = 1000, -- 62
    fillColor = fillColor, -- 63
    borderColor = borderColor, -- 64
    fillOrder = 1, -- 65
    lineOrder = 2 -- 66
})) -- 66
world:addChild(terrain) -- 68
UnitAction:add( -- 70
    "idle", -- 70
    { -- 70
        priority = 1, -- 71
        reaction = 2, -- 72
        recovery = 0.2, -- 73
        available = function(____self) -- 74
            return ____self.onSurface -- 75
        end, -- 74
        create = function(____self) -- 77
            local ____self_0 = ____self -- 78
            local playable = ____self_0.playable -- 78
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
        available = function(____self) -- 99
            return ____self.onSurface -- 100
        end, -- 99
        create = function(____self) -- 102
            local ____self_1 = ____self -- 103
            local playable = ____self_1.playable -- 103
            playable.speed = 1 -- 104
            playable:play("fmove", true) -- 105
            return function(____self, action) -- 106
                local ____action_2 = action -- 107
                local elapsedTime = ____action_2.elapsedTime -- 107
                local recovery = action.recovery * 2 -- 108
                local move = ____self.unitDef.move -- 109
                local moveSpeed = 1 -- 110
                if elapsedTime < recovery then -- 110
                    moveSpeed = math.min(elapsedTime / recovery, 1) -- 112
                end -- 112
                ____self.velocityX = moveSpeed * (____self.faceRight and move or -move) -- 114
                return not ____self.onSurface -- 115
            end -- 106
        end -- 102
    } -- 102
) -- 102
UnitAction:add( -- 120
    "jump", -- 120
    { -- 120
        priority = 3, -- 121
        reaction = 2, -- 122
        recovery = 0.1, -- 123
        queued = true, -- 124
        available = function(____self) -- 125
            return ____self.onSurface -- 126
        end, -- 125
        create = function(____self) -- 128
            local jump = ____self.unitDef.jump -- 129
            ____self.velocityY = jump -- 130
            return once(function() -- 131
                local ____self_3 = ____self -- 132
                local playable = ____self_3.playable -- 132
                playable.speed = 1 -- 133
                sleep(playable:play("jump", false)) -- 134
            end) -- 131
        end -- 128
    } -- 128
) -- 128
UnitAction:add( -- 139
    "fallOff", -- 139
    { -- 139
        priority = 2, -- 140
        reaction = -1, -- 141
        recovery = 0.3, -- 142
        available = function(____self) -- 143
            return not ____self.onSurface -- 144
        end, -- 143
        create = function(____self) -- 146
            if ____self.playable.current ~= "jumping" then -- 146
                local ____self_4 = ____self -- 148
                local playable = ____self_4.playable -- 148
                playable.speed = 1 -- 149
                playable:play("jumping", true) -- 150
            end -- 150
            return loop(function() -- 152
                if ____self.onSurface then -- 152
                    local ____self_5 = ____self -- 154
                    local playable = ____self_5.playable -- 154
                    playable.speed = 1 -- 155
                    sleep(playable:play("landing", false)) -- 156
                    return true -- 157
                end -- 157
                return false -- 159
            end) -- 152
        end -- 146
    } -- 146
) -- 146
local ____Decision_6 = Decision -- 164
local Sel = ____Decision_6.Sel -- 164
local Seq = ____Decision_6.Seq -- 164
local Con = ____Decision_6.Con -- 164
local Act = ____Decision_6.Act -- 164
Data.store["AI:playerControl"] = Sel({ -- 166
    Seq({ -- 167
        Con( -- 168
            "fmove key down", -- 168
            function(____self) -- 168
                local keyLeft = ____self.entity.keyLeft -- 169
                local keyRight = ____self.entity.keyRight -- 170
                return not (keyLeft and keyRight) and (keyLeft and ____self.faceRight or keyRight and not ____self.faceRight) -- 171
            end -- 168
        ), -- 168
        Act("turn") -- 177
    }), -- 177
    Seq({ -- 179
        Con( -- 180
            "is falling", -- 180
            function(____self) -- 180
                return not ____self.onSurface -- 181
            end -- 180
        ), -- 180
        Act("fallOff") -- 183
    }), -- 183
    Seq({ -- 185
        Con( -- 186
            "jump key down", -- 186
            function(____self) -- 186
                return ____self.entity.keyJump -- 187
            end -- 186
        ), -- 186
        Act("jump") -- 189
    }), -- 189
    Seq({ -- 191
        Con( -- 192
            "fmove key down", -- 192
            function(____self) -- 192
                return ____self.entity.keyLeft or ____self.entity.keyRight -- 193
            end -- 192
        ), -- 192
        Act("move") -- 195
    }), -- 195
    Act("idle") -- 197
}) -- 197
local unitDef = Dictionary() -- 200
unitDef.linearAcceleration = Vec2(0, -15) -- 201
unitDef.bodyType = "Dynamic" -- 202
unitDef.scale = 1 -- 203
unitDef.density = 1 -- 204
unitDef.friction = 1 -- 205
unitDef.restitution = 0 -- 206
unitDef.playable = "spine:Spine/moling" -- 207
unitDef.defaultFaceRight = true -- 208
unitDef.size = Size(60, 300) -- 209
unitDef.sensity = 0 -- 210
unitDef.move = 300 -- 211
unitDef.jump = 1000 -- 212
unitDef.detectDistance = 350 -- 213
unitDef.hp = 5 -- 214
unitDef.tag = "player" -- 215
unitDef.decisionTree = "AI:playerControl" -- 216
unitDef.usePreciseHit = false -- 217
unitDef.actions = Array({ -- 218
    "idle", -- 219
    "turn", -- 220
    "move", -- 221
    "jump", -- 222
    "fallOff", -- 223
    "cancel" -- 224
}) -- 224
Observer("Add", {"player"}):watch(function(____self) -- 227
    local unit = Unit( -- 228
        unitDef, -- 228
        world, -- 228
        ____self, -- 228
        Vec2(300, -350) -- 228
    ) -- 228
    unit.order = PlayerLayer -- 229
    unit.group = PlayerGroup -- 230
    unit.playable.position = Vec2(0, -150) -- 231
    unit.playable:play("idle", true) -- 232
    world:addChild(unit) -- 233
    world.camera.followTarget = unit -- 234
end) -- 227
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 237
    local sprite = Sprite(icon) -- 238
    if not sprite then -- 238
        return -- 239
    end -- 239
    sprite:schedule(loop(function() -- 240
        sleep(sprite:runAction(Spawn( -- 241
            AngleY(5, 0, 360), -- 242
            Sequence( -- 243
                Y(2.5, 0, 40, Ease.OutQuad), -- 244
                Y(2.5, 40, 0, Ease.InQuad) -- 245
            ) -- 245
        ))) -- 245
        return false -- 248
    end)) -- 240
    local bodyDef = BodyDef() -- 251
    bodyDef.type = "Dynamic" -- 252
    bodyDef.linearAcceleration = Vec2(0, -10) -- 253
    bodyDef:attachPolygon(sprite.width * 0.5, sprite.height) -- 254
    bodyDef:attachPolygonSensor(0, sprite.width, sprite.height) -- 255
    local body = Body( -- 257
        bodyDef, -- 257
        world, -- 257
        Vec2(x, 0) -- 257
    ) -- 257
    body.order = ItemLayer -- 258
    body.group = ItemGroup -- 259
    body:addChild(sprite) -- 260
    body:slot( -- 262
        "BodyEnter", -- 262
        function(item) -- 262
            if tolua.type(item) == "Platformer::Unit" then -- 262
                ____self.picked = true -- 264
                body.group = Data.groupHide -- 265
                body:schedule(once(function() -- 266
                    sleep(sprite:runAction(Spawn( -- 267
                        Scale(0.2, 1, 1.3, Ease.OutBack), -- 268
                        Opacity(0.2, 1, 0) -- 269
                    ))) -- 269
                    ____self.body = nil -- 271
                end)) -- 266
            end -- 266
        end -- 262
    ) -- 262
    world:addChild(body) -- 276
    ____self.body = body -- 277
end) -- 237
Observer("Remove", {"body"}):watch(function(____self) -- 280
    local body = tolua.cast(____self.oldValues.body, "Body") -- 281
    if body ~= nil then -- 281
        body:removeFromParent() -- 283
    end -- 283
end) -- 280
local function loadExcel() -- 308
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 309
    if xlsx ~= nil then -- 309
        local its = xlsx.items -- 311
        local names = its[2] -- 312
        table.remove(names, 1) -- 313
        if not Struct:has("Item") then -- 313
            Struct.Item(names) -- 315
        end -- 315
        Group({"item"}):each(function(e) -- 317
            e:destroy() -- 318
            return false -- 319
        end) -- 317
        do -- 317
            local i = 2 -- 321
            while i < #its do -- 321
                local st = Struct:load(its[i + 1]) -- 322
                local item = { -- 323
                    name = st.Name, -- 324
                    no = st.No, -- 325
                    x = st.X, -- 326
                    num = st.Num, -- 327
                    icon = st.Icon, -- 328
                    desc = st.Desc, -- 329
                    item = true -- 330
                } -- 330
                Entity(item) -- 332
                i = i + 1 -- 321
            end -- 321
        end -- 321
    end -- 321
end -- 308
local keyboardEnabled = true -- 343
local playerGroup = Group({"player"}) -- 345
local function updatePlayerControl(key, flag, vpad) -- 346
    if keyboardEnabled and vpad then -- 346
        keyboardEnabled = false -- 348
    end -- 348
    playerGroup:each(function(____self) -- 350
        ____self[key] = flag -- 351
        return false -- 352
    end) -- 350
end -- 346
local uiScale = App.devicePixelRatio -- 356
local alignNode = AlignNode({isRoot = true, inUI = true}) -- 357
Director.ui:addChild(alignNode) -- 361
local leftAlign = AlignNode({hAlign = "Left", vAlign = "Bottom"}) -- 363
alignNode:addChild(leftAlign) -- 367
local leftMenu = Menu() -- 369
leftAlign:addChild(leftMenu) -- 370
local leftButton = CircleButton({ -- 372
    text = "左(a)", -- 373
    x = 20 * uiScale, -- 374
    y = 60 * uiScale, -- 375
    radius = 30 * uiScale, -- 376
    fontSize = math.floor(18 * uiScale) -- 377
}) -- 377
leftButton.anchor = Vec2.zero -- 379
leftButton:slot( -- 380
    "TapBegan", -- 380
    function() -- 380
        updatePlayerControl("keyLeft", true, true) -- 381
    end -- 380
) -- 380
leftButton:slot( -- 383
    "TapEnded", -- 383
    function() -- 383
        updatePlayerControl("keyLeft", false, true) -- 384
    end -- 383
) -- 383
leftMenu:addChild(leftButton) -- 386
local rightButton = CircleButton({ -- 388
    text = "右(d)", -- 389
    x = 90 * uiScale, -- 390
    y = 60 * uiScale, -- 391
    radius = 30 * uiScale, -- 392
    fontSize = math.floor(18 * uiScale) -- 393
}) -- 393
rightButton.anchor = Vec2.zero -- 395
rightButton:slot( -- 396
    "TapBegan", -- 396
    function() -- 396
        updatePlayerControl("keyRight", true, true) -- 397
    end -- 396
) -- 396
rightButton:slot( -- 399
    "TapEnded", -- 399
    function() -- 399
        updatePlayerControl("keyRight", false, true) -- 400
    end -- 399
) -- 399
leftMenu:addChild(rightButton) -- 402
local rightAlign = AlignNode({hAlign = "Right", vAlign = "Bottom"}) -- 404
alignNode:addChild(rightAlign) -- 408
local rightMenu = Menu() -- 410
rightAlign:addChild(rightMenu) -- 411
local jumpButton = CircleButton({ -- 413
    text = "跳(j)", -- 414
    x = -80 * uiScale, -- 415
    y = 60 * uiScale, -- 416
    radius = 30 * uiScale, -- 417
    fontSize = math.floor(18 * uiScale) -- 418
}) -- 418
jumpButton.anchor = Vec2.zero -- 420
jumpButton:slot( -- 421
    "TapBegan", -- 421
    function() -- 421
        updatePlayerControl("keyJump", true, true) -- 422
    end -- 421
) -- 421
jumpButton:slot( -- 424
    "TapEnded", -- 424
    function() -- 424
        updatePlayerControl("keyJump", false, true) -- 425
    end -- 424
) -- 424
rightMenu:addChild(jumpButton) -- 427
alignNode:alignLayout() -- 429
alignNode:schedule(function() -- 431
    local keyA = Keyboard:isKeyPressed("A") -- 432
    local keyD = Keyboard:isKeyPressed("D") -- 433
    local keyJ = Keyboard:isKeyPressed("J") -- 434
    if keyD or keyD or keyJ then -- 434
        keyboardEnabled = true -- 436
    end -- 436
    if not keyboardEnabled then -- 436
        return false -- 439
    end -- 439
    updatePlayerControl("keyLeft", keyA, false) -- 441
    updatePlayerControl("keyRight", keyD, false) -- 442
    updatePlayerControl("keyJump", keyJ, false) -- 443
    return false -- 444
end) -- 431
local pickedItemGroup = Group({"picked"}) -- 447
local windowFlags = { -- 448
    "NoDecoration", -- 449
    "AlwaysAutoResize", -- 450
    "NoSavedSettings", -- 451
    "NoFocusOnAppearing", -- 452
    "NoNav", -- 453
    "NoMove" -- 454
} -- 454
Director.ui:schedule(function() -- 456
    local size = App.visualSize -- 457
    ImGui.SetNextWindowBgAlpha(0.35) -- 458
    ImGui.SetNextWindowPos( -- 459
        Vec2(size.width - 10, 10), -- 459
        "Always", -- 459
        Vec2(1, 0) -- 459
    ) -- 459
    ImGui.SetNextWindowSize( -- 460
        Vec2(100, 300), -- 460
        "FirstUseEver" -- 460
    ) -- 460
    ImGui.Begin( -- 461
        "BackPack", -- 461
        windowFlags, -- 461
        function() -- 461
            if ImGui.Button("重新加载Excel") then -- 461
                loadExcel() -- 463
            end -- 463
            ImGui.Separator() -- 465
            ImGui.Dummy(Vec2(100, 10)) -- 466
            ImGui.Text("背包 (Typescript)") -- 467
            ImGui.Separator() -- 468
            ImGui.Columns(3, false) -- 469
            pickedItemGroup:each(function(e) -- 470
                local item = e -- 471
                if item.num > 0 then -- 471
                    if ImGui.ImageButton( -- 471
                        "item" .. tostring(item.no), -- 473
                        item.icon, -- 473
                        Vec2(50, 50) -- 473
                    ) then -- 473
                        item.num = item.num - 1 -- 474
                        local sprite = Sprite(item.icon) -- 475
                        if not sprite then -- 475
                            return false -- 476
                        end -- 476
                        sprite.scaleX = 0.5 -- 477
                        sprite.scaleY = 0.5 -- 478
                        sprite:perform(Spawn( -- 479
                            Opacity(1, 1, 0), -- 480
                            Y(1, 150, 250) -- 481
                        )) -- 481
                        local player = playerGroup:find(function() return true end) -- 483
                        if player ~= nil then -- 483
                            local unit = player.unit -- 485
                            unit:addChild(sprite) -- 486
                        end -- 486
                    end -- 486
                    if ImGui.IsItemHovered() then -- 486
                        ImGui.BeginTooltip(function() -- 490
                            ImGui.Text(item.name) -- 491
                            ImGui.TextColored(themeColor, "数量：") -- 492
                            ImGui.SameLine() -- 493
                            ImGui.Text(tostring(item.num)) -- 494
                            ImGui.TextColored(themeColor, "描述：") -- 495
                            ImGui.SameLine() -- 496
                            ImGui.Text(tostring(item.desc)) -- 497
                        end) -- 490
                    end -- 490
                    ImGui.NextColumn() -- 500
                end -- 500
                return false -- 502
            end) -- 470
        end -- 461
    ) -- 461
    return false -- 505
end) -- 456
Entity({player = true}) -- 508
loadExcel() -- 509
return ____exports -- 509