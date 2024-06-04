-- [ts]: ExcelTestTS.ts
local ____exports = {} -- 1
local ____Platformer = require("Platformer") -- 2
local Data = ____Platformer.Data -- 2
local Decision = ____Platformer.Decision -- 2
local PlatformWorld = ____Platformer.PlatformWorld -- 2
local Unit = ____Platformer.Unit -- 2
local UnitAction = ____Platformer.UnitAction -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Body = ____Dora.Body -- 3
local BodyDef = ____Dora.BodyDef -- 3
local Color = ____Dora.Color -- 3
local Dictionary = ____Dora.Dictionary -- 3
local Rect = ____Dora.Rect -- 3
local Size = ____Dora.Size -- 3
local Vec2 = ____Dora.Vec2 -- 3
local View = ____Dora.View -- 3
local loop = ____Dora.loop -- 3
local once = ____Dora.once -- 3
local sleep = ____Dora.sleep -- 3
local Array = ____Dora.Array -- 3
local Observer = ____Dora.Observer -- 3
local Sprite = ____Dora.Sprite -- 3
local Spawn = ____Dora.Spawn -- 3
local AngleY = ____Dora.AngleY -- 3
local Sequence = ____Dora.Sequence -- 3
local Ease = ____Dora.Ease -- 3
local Y = ____Dora.Y -- 3
local tolua = ____Dora.tolua -- 3
local Scale = ____Dora.Scale -- 3
local Opacity = ____Dora.Opacity -- 3
local Content = ____Dora.Content -- 3
local Group = ____Dora.Group -- 3
local Entity = ____Dora.Entity -- 3
local Director = ____Dora.Director -- 3
local Menu = ____Dora.Menu -- 3
local Keyboard = ____Dora.Keyboard -- 3
local AlignNode = ____Dora.AlignNode -- 3
local Rectangle = require("UI.View.Shape.Rectangle") -- 4
local ____Utils = require("Utils") -- 287
local Struct = ____Utils.Struct -- 287
local CircleButton = require("UI.Control.Basic.CircleButton") -- 337
local ImGui = require("ImGui") -- 339
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
    return false -- 235
end) -- 227
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 238
    local sprite = Sprite(icon) -- 239
    if not sprite then -- 239
        return false -- 240
    end -- 240
    sprite:runAction( -- 241
        Spawn( -- 241
            AngleY(5, 0, 360), -- 242
            Sequence( -- 243
                Y(2.5, 0, 40, Ease.OutQuad), -- 244
                Y(2.5, 40, 0, Ease.InQuad) -- 245
            ) -- 245
        ), -- 245
        true -- 247
    ) -- 247
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
    return false -- 276
end) -- 238
Observer("Remove", {"body"}):watch(function(____self) -- 279
    local body = tolua.cast(____self.oldValues.body, "Body") -- 280
    if body ~= nil then -- 280
        body:removeFromParent() -- 282
    end -- 282
    return false -- 284
end) -- 279
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
local keyboardEnabled = true -- 341
local playerGroup = Group({"player"}) -- 343
local function updatePlayerControl(key, flag, vpad) -- 344
    if keyboardEnabled and vpad then -- 344
        keyboardEnabled = false -- 346
    end -- 346
    playerGroup:each(function(____self) -- 348
        ____self[key] = flag -- 349
        return false -- 350
    end) -- 348
end -- 344
local ui = AlignNode(true) -- 354
ui:css("flex-direction: column-reverse") -- 355
ui.controllerEnabled = true -- 356
ui:slot( -- 357
    "ButtonDown", -- 357
    function(id, buttonName) -- 357
        if id ~= 0 then -- 357
            return -- 358
        end -- 358
        repeat -- 358
            local ____switch41 = buttonName -- 358
            local ____cond41 = ____switch41 == "dpleft" -- 358
            if ____cond41 then -- 358
                updatePlayerControl("keyLeft", true, true) -- 360
                break -- 360
            end -- 360
            ____cond41 = ____cond41 or ____switch41 == "dpright" -- 360
            if ____cond41 then -- 360
                updatePlayerControl("keyRight", true, true) -- 361
                break -- 361
            end -- 361
            ____cond41 = ____cond41 or ____switch41 == "b" -- 361
            if ____cond41 then -- 361
                updatePlayerControl("keyJump", true, true) -- 362
                break -- 362
            end -- 362
        until true -- 362
    end -- 357
) -- 357
ui:slot( -- 365
    "ButtonUp", -- 365
    function(id, buttonName) -- 365
        if id ~= 0 then -- 365
            return -- 366
        end -- 366
        repeat -- 366
            local ____switch44 = buttonName -- 366
            local ____cond44 = ____switch44 == "dpleft" -- 366
            if ____cond44 then -- 366
                updatePlayerControl("keyLeft", false, true) -- 368
                break -- 368
            end -- 368
            ____cond44 = ____cond44 or ____switch44 == "dpright" -- 368
            if ____cond44 then -- 368
                updatePlayerControl("keyRight", false, true) -- 369
                break -- 369
            end -- 369
            ____cond44 = ____cond44 or ____switch44 == "b" -- 369
            if ____cond44 then -- 369
                updatePlayerControl("keyJump", false, true) -- 370
                break -- 370
            end -- 370
        until true -- 370
    end -- 365
) -- 365
ui:addTo(Director.ui) -- 373
local bottomAlign = AlignNode() -- 375
bottomAlign:css("\n\theight: 60;\n\tjustify-content: space-between;\n\tmargin: 0, 20, 40;\n\tflex-direction: row\n") -- 376
bottomAlign:addTo(ui) -- 382
local leftAlign = AlignNode() -- 384
leftAlign:css("width: 130; height: 60") -- 385
leftAlign:addTo(bottomAlign) -- 386
local leftMenu = Menu() -- 388
leftMenu.size = Size(250, 120) -- 389
leftMenu.anchor = Vec2.zero -- 390
leftMenu.scaleY = 0.5 -- 391
leftMenu.scaleX = 0.5 -- 391
leftMenu:addTo(leftAlign) -- 392
local leftButton = CircleButton({text = "左(a)", radius = 60, fontSize = 36}) -- 394
leftButton.anchor = Vec2.zero -- 399
leftButton:slot( -- 400
    "TapBegan", -- 400
    function() -- 400
        updatePlayerControl("keyLeft", true, true) -- 401
    end -- 400
) -- 400
leftButton:slot( -- 403
    "TapEnded", -- 403
    function() -- 403
        updatePlayerControl("keyLeft", false, true) -- 404
    end -- 403
) -- 403
leftButton:addTo(leftMenu) -- 406
local rightButton = CircleButton({text = "右(d)", x = 130, radius = 60, fontSize = 36}) -- 408
rightButton.anchor = Vec2.zero -- 414
rightButton:slot( -- 415
    "TapBegan", -- 415
    function() -- 415
        updatePlayerControl("keyRight", true, true) -- 416
    end -- 415
) -- 415
rightButton:slot( -- 418
    "TapEnded", -- 418
    function() -- 418
        updatePlayerControl("keyRight", false, true) -- 419
    end -- 418
) -- 418
rightButton:addTo(leftMenu) -- 421
local rightAlign = AlignNode() -- 423
rightAlign:css("width: 60; height: 60") -- 424
rightAlign:addTo(bottomAlign) -- 425
local rightMenu = Menu() -- 427
rightMenu.size = Size(120, 120) -- 428
rightMenu.anchor = Vec2.zero -- 429
rightMenu.scaleY = 0.5 -- 430
rightMenu.scaleX = 0.5 -- 430
rightAlign:addChild(rightMenu) -- 431
local jumpButton = CircleButton({text = "跳(j)", radius = 60, fontSize = 36}) -- 433
jumpButton.anchor = Vec2.zero -- 438
jumpButton:slot( -- 439
    "TapBegan", -- 439
    function() -- 439
        updatePlayerControl("keyJump", true, true) -- 440
    end -- 439
) -- 439
jumpButton:slot( -- 442
    "TapEnded", -- 442
    function() -- 442
        updatePlayerControl("keyJump", false, true) -- 443
    end -- 442
) -- 442
jumpButton:addTo(rightMenu) -- 445
ui:schedule(function() -- 447
    local keyA = Keyboard:isKeyPressed("A") -- 448
    local keyD = Keyboard:isKeyPressed("D") -- 449
    local keyJ = Keyboard:isKeyPressed("J") -- 450
    if keyD or keyD or keyJ then -- 450
        keyboardEnabled = true -- 452
    end -- 452
    if not keyboardEnabled then -- 452
        return false -- 455
    end -- 455
    updatePlayerControl("keyLeft", keyA, false) -- 457
    updatePlayerControl("keyRight", keyD, false) -- 458
    updatePlayerControl("keyJump", keyJ, false) -- 459
    return false -- 460
end) -- 447
local pickedItemGroup = Group({"picked"}) -- 463
local windowFlags = { -- 464
    "NoDecoration", -- 465
    "AlwaysAutoResize", -- 466
    "NoSavedSettings", -- 467
    "NoFocusOnAppearing", -- 468
    "NoNav", -- 469
    "NoMove" -- 470
} -- 470
Director.ui:schedule(function() -- 472
    local size = App.visualSize -- 473
    ImGui.SetNextWindowBgAlpha(0.35) -- 474
    ImGui.SetNextWindowPos( -- 475
        Vec2(size.width - 10, 10), -- 475
        "Always", -- 475
        Vec2(1, 0) -- 475
    ) -- 475
    ImGui.SetNextWindowSize( -- 476
        Vec2(100, 300), -- 476
        "FirstUseEver" -- 476
    ) -- 476
    ImGui.Begin( -- 477
        "BackPack", -- 477
        windowFlags, -- 477
        function() -- 477
            if ImGui.Button("重新加载Excel") then -- 477
                loadExcel() -- 479
            end -- 479
            ImGui.Separator() -- 481
            ImGui.Dummy(Vec2(100, 10)) -- 482
            ImGui.Text("背包 (Typescript)") -- 483
            ImGui.Separator() -- 484
            ImGui.Columns(3, false) -- 485
            pickedItemGroup:each(function(e) -- 486
                local item = e -- 487
                if item.num > 0 then -- 487
                    if ImGui.ImageButton( -- 487
                        "item" .. tostring(item.no), -- 489
                        item.icon, -- 489
                        Vec2(50, 50) -- 489
                    ) then -- 489
                        item.num = item.num - 1 -- 490
                        local sprite = Sprite(item.icon) -- 491
                        if not sprite then -- 491
                            return false -- 492
                        end -- 492
                        sprite.scaleX = 0.5 -- 493
                        sprite.scaleY = 0.5 -- 494
                        sprite:perform(Spawn( -- 495
                            Opacity(1, 1, 0), -- 496
                            Y(1, 150, 250) -- 497
                        )) -- 497
                        local player = playerGroup:find(function() return true end) -- 499
                        if player ~= nil then -- 499
                            local unit = player.unit -- 501
                            unit:addChild(sprite) -- 502
                        end -- 502
                    end -- 502
                    if ImGui.IsItemHovered() then -- 502
                        ImGui.BeginTooltip(function() -- 506
                            ImGui.Text(item.name) -- 507
                            ImGui.TextColored(themeColor, "数量：") -- 508
                            ImGui.SameLine() -- 509
                            ImGui.Text(tostring(item.num)) -- 510
                            ImGui.TextColored(themeColor, "描述：") -- 511
                            ImGui.SameLine() -- 512
                            ImGui.Text(tostring(item.desc)) -- 513
                        end) -- 506
                    end -- 506
                    ImGui.NextColumn() -- 516
                end -- 516
                return false -- 518
            end) -- 486
        end -- 477
    ) -- 477
    return false -- 521
end) -- 472
Entity({player = true}) -- 524
loadExcel() -- 525
return ____exports -- 525