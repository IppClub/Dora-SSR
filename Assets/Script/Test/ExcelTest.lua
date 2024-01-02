-- [ts]: ExcelTest.ts
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
local AlignNode = require("UI.Control.Basic.AlignNode") -- 323
local CircleButton = require("UI.Control.Basic.CircleButton") -- 324
local ImGui = require("ImGui") -- 327
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
local function loadExcel() -- 294
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 295
    if xlsx ~= nil then -- 295
        local its = xlsx.items -- 297
        local names = its[2] -- 298
        table.remove(names, 1) -- 299
        if not Struct:has("Item") then -- 299
            Struct.Item(names) -- 301
        end -- 301
        Group({"item"}):each(function(e) -- 303
            e:destroy() -- 304
            return false -- 305
        end) -- 303
        do -- 303
            local i = 2 -- 307
            while i < #its do -- 307
                local st = Struct:load(its[i + 1]) -- 308
                local item = { -- 309
                    name = st.Name, -- 310
                    no = st.No, -- 311
                    x = st.X, -- 312
                    num = st.Num, -- 313
                    icon = st.Icon, -- 314
                    desc = st.Desc, -- 315
                    item = true -- 316
                } -- 316
                Entity(item) -- 318
                i = i + 1 -- 307
            end -- 307
        end -- 307
    end -- 307
end -- 294
local keyboardEnabled = true -- 329
local playerGroup = Group({"player"}) -- 331
local function updatePlayerControl(key, flag, vpad) -- 332
    if keyboardEnabled and vpad then -- 332
        keyboardEnabled = false -- 334
    end -- 334
    playerGroup:each(function(____self) -- 336
        ____self[key] = flag -- 337
        return false -- 338
    end) -- 336
end -- 332
local uiScale = App.devicePixelRatio -- 342
local alignNode = AlignNode({isRoot = true, inUI = true}) -- 343
Director.ui:addChild(alignNode) -- 347
local leftAlign = AlignNode({hAlign = "Left", vAlign = "Bottom"}) -- 349
alignNode:addChild(leftAlign) -- 353
local leftMenu = Menu() -- 355
leftAlign:addChild(leftMenu) -- 356
local leftButton = CircleButton({ -- 358
    text = "左(a)", -- 359
    x = 20 * uiScale, -- 360
    y = 60 * uiScale, -- 361
    radius = 30 * uiScale, -- 362
    fontSize = math.floor(18 * uiScale) -- 363
}) -- 363
leftButton.anchor = Vec2.zero -- 365
leftButton:slot( -- 366
    "TapBegan", -- 366
    function() -- 366
        updatePlayerControl("keyLeft", true, true) -- 367
    end -- 366
) -- 366
leftButton:slot( -- 369
    "TapEnded", -- 369
    function() -- 369
        updatePlayerControl("keyLeft", false, true) -- 370
    end -- 369
) -- 369
leftMenu:addChild(leftButton) -- 372
local rightButton = CircleButton({ -- 374
    text = "右(d)", -- 375
    x = 90 * uiScale, -- 376
    y = 60 * uiScale, -- 377
    radius = 30 * uiScale, -- 378
    fontSize = math.floor(18 * uiScale) -- 379
}) -- 379
rightButton.anchor = Vec2.zero -- 381
rightButton:slot( -- 382
    "TapBegan", -- 382
    function() -- 382
        updatePlayerControl("keyRight", true, true) -- 383
    end -- 382
) -- 382
rightButton:slot( -- 385
    "TapEnded", -- 385
    function() -- 385
        updatePlayerControl("keyRight", false, true) -- 386
    end -- 385
) -- 385
leftMenu:addChild(rightButton) -- 388
local rightAlign = AlignNode({hAlign = "Right", vAlign = "Bottom"}) -- 390
alignNode:addChild(rightAlign) -- 394
local rightMenu = Menu() -- 396
rightAlign:addChild(rightMenu) -- 397
local jumpButton = CircleButton({ -- 399
    text = "跳(j)", -- 400
    x = -80 * uiScale, -- 401
    y = 60 * uiScale, -- 402
    radius = 30 * uiScale, -- 403
    fontSize = math.floor(18 * uiScale) -- 404
}) -- 404
jumpButton.anchor = Vec2.zero -- 406
jumpButton:slot( -- 407
    "TapBegan", -- 407
    function() -- 407
        updatePlayerControl("keyJump", true, true) -- 408
    end -- 407
) -- 407
jumpButton:slot( -- 410
    "TapEnded", -- 410
    function() -- 410
        updatePlayerControl("keyJump", false, true) -- 411
    end -- 410
) -- 410
rightMenu:addChild(jumpButton) -- 413
alignNode:alignLayout() -- 415
alignNode:schedule(function() -- 417
    local keyA = Keyboard:isKeyPressed("A") -- 418
    local keyD = Keyboard:isKeyPressed("D") -- 419
    local keyJ = Keyboard:isKeyPressed("J") -- 420
    if keyD or keyD or keyJ then -- 420
        keyboardEnabled = true -- 422
    end -- 422
    if not keyboardEnabled then -- 422
        return false -- 425
    end -- 425
    updatePlayerControl("keyLeft", keyA, false) -- 427
    updatePlayerControl("keyRight", keyD, false) -- 428
    updatePlayerControl("keyJump", keyJ, false) -- 429
    return false -- 430
end) -- 417
local pickedItemGroup = Group({"picked"}) -- 433
local windowFlags = { -- 434
    "NoDecoration", -- 435
    "AlwaysAutoResize", -- 436
    "NoSavedSettings", -- 437
    "NoFocusOnAppearing", -- 438
    "NoNav", -- 439
    "NoMove" -- 440
} -- 440
Director.ui:schedule(function() -- 442
    local size = App.visualSize -- 443
    ImGui.SetNextWindowBgAlpha(0.35) -- 444
    ImGui.SetNextWindowPos( -- 445
        Vec2(size.width - 10, 10), -- 445
        "Always", -- 445
        Vec2(1, 0) -- 445
    ) -- 445
    ImGui.SetNextWindowSize( -- 446
        Vec2(100, 300), -- 446
        "FirstUseEver" -- 446
    ) -- 446
    ImGui.Begin( -- 447
        "BackPack", -- 447
        windowFlags, -- 447
        function() -- 447
            if ImGui.Button("重新加载Excel") then -- 447
                loadExcel() -- 449
            end -- 449
            ImGui.Separator() -- 451
            ImGui.Dummy(Vec2(100, 10)) -- 452
            ImGui.Text("背包") -- 453
            ImGui.Separator() -- 454
            ImGui.Columns(3, false) -- 455
            pickedItemGroup:each(function(e) -- 456
                local item = e -- 457
                if item.num > 0 then -- 457
                    if ImGui.ImageButton( -- 457
                        "item" .. tostring(item.no), -- 459
                        item.icon, -- 459
                        Vec2(50, 50) -- 459
                    ) then -- 459
                        item.num = item.num - 1 -- 460
                        local sprite = Sprite(item.icon) -- 461
                        sprite.scaleX = 0.5 -- 462
                        sprite.scaleY = 0.5 -- 463
                        sprite:perform(Spawn( -- 464
                            Opacity(1, 1, 0), -- 465
                            Y(1, 150, 250) -- 466
                        )) -- 466
                        local player = playerGroup:find(function() return true end) -- 468
                        if player ~= nil then -- 468
                            local unit = player.unit -- 470
                            unit:addChild(sprite) -- 471
                        end -- 471
                    end -- 471
                    if ImGui.IsItemHovered() then -- 471
                        ImGui.BeginTooltip(function() -- 475
                            ImGui.Text(item.name) -- 476
                            ImGui.TextColored(themeColor, "数量：") -- 477
                            ImGui.SameLine() -- 478
                            ImGui.Text(tostring(item.num)) -- 479
                            ImGui.TextColored(themeColor, "描述：") -- 480
                            ImGui.SameLine() -- 481
                            ImGui.Text(tostring(item.desc)) -- 482
                        end) -- 475
                    end -- 475
                    ImGui.NextColumn() -- 485
                end -- 485
                return false -- 487
            end) -- 456
        end -- 447
    ) -- 447
    return false -- 490
end) -- 442
Entity({player = true}) -- 493
loadExcel() -- 494
return ____exports -- 494