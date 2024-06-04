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
ui:slot( -- 356
    "ButtonDown", -- 356
    function(id, buttonName) -- 356
        if id ~= 0 then -- 356
            return -- 357
        end -- 357
        repeat -- 357
            local ____switch41 = buttonName -- 357
            local ____cond41 = ____switch41 == "dpleft" -- 357
            if ____cond41 then -- 357
                updatePlayerControl("keyLeft", true, true) -- 359
                break -- 359
            end -- 359
            ____cond41 = ____cond41 or ____switch41 == "dpright" -- 359
            if ____cond41 then -- 359
                updatePlayerControl("keyRight", true, true) -- 360
                break -- 360
            end -- 360
            ____cond41 = ____cond41 or ____switch41 == "b" -- 360
            if ____cond41 then -- 360
                updatePlayerControl("keyJump", true, true) -- 361
                break -- 361
            end -- 361
        until true -- 361
    end -- 356
) -- 356
ui:slot( -- 364
    "ButtonUp", -- 364
    function(id, buttonName) -- 364
        if id ~= 0 then -- 364
            return -- 365
        end -- 365
        repeat -- 365
            local ____switch44 = buttonName -- 365
            local ____cond44 = ____switch44 == "dpleft" -- 365
            if ____cond44 then -- 365
                updatePlayerControl("keyLeft", false, true) -- 367
                break -- 367
            end -- 367
            ____cond44 = ____cond44 or ____switch44 == "dpright" -- 367
            if ____cond44 then -- 367
                updatePlayerControl("keyRight", false, true) -- 368
                break -- 368
            end -- 368
            ____cond44 = ____cond44 or ____switch44 == "b" -- 368
            if ____cond44 then -- 368
                updatePlayerControl("keyJump", false, true) -- 369
                break -- 369
            end -- 369
        until true -- 369
    end -- 364
) -- 364
ui:addTo(Director.ui) -- 372
local bottomAlign = AlignNode() -- 374
bottomAlign:css("\n\theight: 80;\n\tjustify-content: space-between;\n\tpadding: 0, 20, 20;\n\tflex-direction: row\n") -- 375
bottomAlign:addTo(ui) -- 381
local leftAlign = AlignNode() -- 383
leftAlign:css("width: 130; height: 60") -- 384
leftAlign:addTo(bottomAlign) -- 385
local leftMenu = Menu() -- 387
leftMenu.size = Size(250, 120) -- 388
leftMenu.anchor = Vec2.zero -- 389
leftMenu.scaleY = 0.5 -- 390
leftMenu.scaleX = 0.5 -- 390
leftMenu:addTo(leftAlign) -- 391
local leftButton = CircleButton({text = "左(a)", radius = 60, fontSize = 36}) -- 393
leftButton.anchor = Vec2.zero -- 398
leftButton:slot( -- 399
    "TapBegan", -- 399
    function() -- 399
        updatePlayerControl("keyLeft", true, true) -- 400
    end -- 399
) -- 399
leftButton:slot( -- 402
    "TapEnded", -- 402
    function() -- 402
        updatePlayerControl("keyLeft", false, true) -- 403
    end -- 402
) -- 402
leftButton:addTo(leftMenu) -- 405
local rightButton = CircleButton({text = "右(d)", x = 130, radius = 60, fontSize = 36}) -- 407
rightButton.anchor = Vec2.zero -- 413
rightButton:slot( -- 414
    "TapBegan", -- 414
    function() -- 414
        updatePlayerControl("keyRight", true, true) -- 415
    end -- 414
) -- 414
rightButton:slot( -- 417
    "TapEnded", -- 417
    function() -- 417
        updatePlayerControl("keyRight", false, true) -- 418
    end -- 417
) -- 417
rightButton:addTo(leftMenu) -- 420
local rightAlign = AlignNode() -- 422
rightAlign:css("width: 60; height: 60") -- 423
rightAlign:addTo(bottomAlign) -- 424
local rightMenu = Menu() -- 426
rightMenu.size = Size(120, 120) -- 427
rightMenu.anchor = Vec2.zero -- 428
rightMenu.scaleY = 0.5 -- 429
rightMenu.scaleX = 0.5 -- 429
rightAlign:addChild(rightMenu) -- 430
local jumpButton = CircleButton({text = "跳(j)", radius = 60, fontSize = 36}) -- 432
jumpButton.anchor = Vec2.zero -- 437
jumpButton:slot( -- 438
    "TapBegan", -- 438
    function() -- 438
        updatePlayerControl("keyJump", true, true) -- 439
    end -- 438
) -- 438
jumpButton:slot( -- 441
    "TapEnded", -- 441
    function() -- 441
        updatePlayerControl("keyJump", false, true) -- 442
    end -- 441
) -- 441
jumpButton:addTo(rightMenu) -- 444
ui:schedule(function() -- 446
    local keyA = Keyboard:isKeyPressed("A") -- 447
    local keyD = Keyboard:isKeyPressed("D") -- 448
    local keyJ = Keyboard:isKeyPressed("J") -- 449
    if keyD or keyD or keyJ then -- 449
        keyboardEnabled = true -- 451
    end -- 451
    if not keyboardEnabled then -- 451
        return false -- 454
    end -- 454
    updatePlayerControl("keyLeft", keyA, false) -- 456
    updatePlayerControl("keyRight", keyD, false) -- 457
    updatePlayerControl("keyJump", keyJ, false) -- 458
    return false -- 459
end) -- 446
local pickedItemGroup = Group({"picked"}) -- 462
local windowFlags = { -- 463
    "NoDecoration", -- 464
    "AlwaysAutoResize", -- 465
    "NoSavedSettings", -- 466
    "NoFocusOnAppearing", -- 467
    "NoNav", -- 468
    "NoMove" -- 469
} -- 469
Director.ui:schedule(function() -- 471
    local size = App.visualSize -- 472
    ImGui.SetNextWindowBgAlpha(0.35) -- 473
    ImGui.SetNextWindowPos( -- 474
        Vec2(size.width - 10, 10), -- 474
        "Always", -- 474
        Vec2(1, 0) -- 474
    ) -- 474
    ImGui.SetNextWindowSize( -- 475
        Vec2(100, 300), -- 475
        "FirstUseEver" -- 475
    ) -- 475
    ImGui.Begin( -- 476
        "BackPack", -- 476
        windowFlags, -- 476
        function() -- 476
            if ImGui.Button("重新加载Excel") then -- 476
                loadExcel() -- 478
            end -- 478
            ImGui.Separator() -- 480
            ImGui.Dummy(Vec2(100, 10)) -- 481
            ImGui.Text("背包 (Typescript)") -- 482
            ImGui.Separator() -- 483
            ImGui.Columns(3, false) -- 484
            pickedItemGroup:each(function(e) -- 485
                local item = e -- 486
                if item.num > 0 then -- 486
                    if ImGui.ImageButton( -- 486
                        "item" .. tostring(item.no), -- 488
                        item.icon, -- 488
                        Vec2(50, 50) -- 488
                    ) then -- 488
                        item.num = item.num - 1 -- 489
                        local sprite = Sprite(item.icon) -- 490
                        if not sprite then -- 490
                            return false -- 491
                        end -- 491
                        sprite.scaleX = 0.5 -- 492
                        sprite.scaleY = 0.5 -- 493
                        sprite:perform(Spawn( -- 494
                            Opacity(1, 1, 0), -- 495
                            Y(1, 150, 250) -- 496
                        )) -- 496
                        local player = playerGroup:find(function() return true end) -- 498
                        if player ~= nil then -- 498
                            local unit = player.unit -- 500
                            unit:addChild(sprite) -- 501
                        end -- 501
                    end -- 501
                    if ImGui.IsItemHovered() then -- 501
                        ImGui.BeginTooltip(function() -- 505
                            ImGui.Text(item.name) -- 506
                            ImGui.TextColored(themeColor, "数量：") -- 507
                            ImGui.SameLine() -- 508
                            ImGui.Text(tostring(item.num)) -- 509
                            ImGui.TextColored(themeColor, "描述：") -- 510
                            ImGui.SameLine() -- 511
                            ImGui.Text(tostring(item.desc)) -- 512
                        end) -- 505
                    end -- 505
                    ImGui.NextColumn() -- 515
                end -- 515
                return false -- 517
            end) -- 485
        end -- 476
    ) -- 476
    return false -- 520
end) -- 471
Entity({player = true}) -- 523
loadExcel() -- 524
return ____exports -- 524