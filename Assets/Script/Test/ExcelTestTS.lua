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
local ____Utils = require("Utils") -- 289
local Struct = ____Utils.Struct -- 289
local CircleButton = require("UI.Control.Basic.CircleButton") -- 339
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
world:onAppChange(function(settingName) -- 25
    if settingName == "Size" then -- 25
        world.camera.zoom = View.size.width / DesignWidth -- 27
    end -- 27
end) -- 25
local terrainDef = BodyDef() -- 31
terrainDef.type = "Static" -- 32
terrainDef:attachPolygon( -- 33
    Vec2(0, -500), -- 33
    2500, -- 33
    10, -- 33
    0, -- 33
    1, -- 33
    1, -- 33
    0 -- 33
) -- 33
terrainDef:attachPolygon( -- 34
    Vec2(0, 500), -- 34
    2500, -- 34
    10, -- 34
    0, -- 34
    1, -- 34
    1, -- 34
    0 -- 34
) -- 34
terrainDef:attachPolygon( -- 35
    Vec2(1250, 0), -- 35
    10, -- 35
    1000, -- 35
    0, -- 35
    1, -- 35
    1, -- 35
    0 -- 35
) -- 35
terrainDef:attachPolygon( -- 36
    Vec2(-1250, 0), -- 36
    10, -- 36
    1000, -- 36
    0, -- 36
    1, -- 36
    1, -- 36
    0 -- 36
) -- 36
local terrain = Body(terrainDef, world, Vec2.zero) -- 38
terrain.order = TerrainLayer -- 39
terrain.group = TerrainGroup -- 40
terrain:addChild(Rectangle({ -- 41
    y = -500, -- 42
    width = 2500, -- 43
    height = 10, -- 44
    fillColor = fillColor, -- 45
    borderColor = borderColor, -- 46
    fillOrder = 1, -- 47
    lineOrder = 2 -- 48
})) -- 48
terrain:addChild(Rectangle({ -- 50
    x = 1250, -- 51
    y = 0, -- 52
    width = 10, -- 53
    height = 1000, -- 54
    fillColor = fillColor, -- 55
    borderColor = borderColor, -- 56
    fillOrder = 1, -- 57
    lineOrder = 2 -- 58
})) -- 58
terrain:addChild(Rectangle({ -- 60
    x = -1250, -- 61
    y = 0, -- 62
    width = 10, -- 63
    height = 1000, -- 64
    fillColor = fillColor, -- 65
    borderColor = borderColor, -- 66
    fillOrder = 1, -- 67
    lineOrder = 2 -- 68
})) -- 68
world:addChild(terrain) -- 70
UnitAction:add( -- 72
    "idle", -- 72
    { -- 72
        priority = 1, -- 73
        reaction = 2, -- 74
        recovery = 0.2, -- 75
        available = function(____self) -- 76
            return ____self.onSurface -- 77
        end, -- 76
        create = function(____self) -- 79
            local ____self_0 = ____self -- 80
            local playable = ____self_0.playable -- 80
            playable.speed = 1 -- 81
            playable:play("idle", true) -- 82
            local playIdleSpecial = loop(function() -- 83
                sleep(3) -- 84
                sleep(playable:play("idle1")) -- 85
                playable:play("idle", true) -- 86
                return false -- 87
            end) -- 83
            ____self.data.playIdleSpecial = playIdleSpecial -- 89
            return function(owner) -- 90
                coroutine.resume(playIdleSpecial) -- 91
                return not owner.onSurface -- 92
            end -- 90
        end -- 79
    } -- 79
) -- 79
UnitAction:add( -- 97
    "move", -- 97
    { -- 97
        priority = 1, -- 98
        reaction = 2, -- 99
        recovery = 0.2, -- 100
        available = function(____self) -- 101
            return ____self.onSurface -- 102
        end, -- 101
        create = function(____self) -- 104
            local ____self_1 = ____self -- 105
            local playable = ____self_1.playable -- 105
            playable.speed = 1 -- 106
            playable:play("fmove", true) -- 107
            return function(____self, action) -- 108
                local ____action_2 = action -- 109
                local elapsedTime = ____action_2.elapsedTime -- 109
                local recovery = action.recovery * 2 -- 110
                local move = ____self.unitDef.move -- 111
                local moveSpeed = 1 -- 112
                if elapsedTime < recovery then -- 112
                    moveSpeed = math.min(elapsedTime / recovery, 1) -- 114
                end -- 114
                ____self.velocityX = moveSpeed * (____self.faceRight and move or -move) -- 116
                return not ____self.onSurface -- 117
            end -- 108
        end -- 104
    } -- 104
) -- 104
UnitAction:add( -- 122
    "jump", -- 122
    { -- 122
        priority = 3, -- 123
        reaction = 2, -- 124
        recovery = 0.1, -- 125
        queued = true, -- 126
        available = function(____self) -- 127
            return ____self.onSurface -- 128
        end, -- 127
        create = function(____self) -- 130
            local jump = ____self.unitDef.jump -- 131
            ____self.velocityY = jump -- 132
            return once(function() -- 133
                local ____self_3 = ____self -- 134
                local playable = ____self_3.playable -- 134
                playable.speed = 1 -- 135
                sleep(playable:play("jump", false)) -- 136
            end) -- 133
        end -- 130
    } -- 130
) -- 130
UnitAction:add( -- 141
    "fallOff", -- 141
    { -- 141
        priority = 2, -- 142
        reaction = -1, -- 143
        recovery = 0.3, -- 144
        available = function(____self) -- 145
            return not ____self.onSurface -- 146
        end, -- 145
        create = function(____self) -- 148
            if ____self.playable.current ~= "jumping" then -- 148
                local ____self_4 = ____self -- 150
                local playable = ____self_4.playable -- 150
                playable.speed = 1 -- 151
                playable:play("jumping", true) -- 152
            end -- 152
            return loop(function() -- 154
                if ____self.onSurface then -- 154
                    local ____self_5 = ____self -- 156
                    local playable = ____self_5.playable -- 156
                    playable.speed = 1 -- 157
                    sleep(playable:play("landing", false)) -- 158
                    return true -- 159
                end -- 159
                return false -- 161
            end) -- 154
        end -- 148
    } -- 148
) -- 148
local ____Decision_6 = Decision -- 166
local Sel = ____Decision_6.Sel -- 166
local Seq = ____Decision_6.Seq -- 166
local Con = ____Decision_6.Con -- 166
local Act = ____Decision_6.Act -- 166
Data.store["AI:playerControl"] = Sel({ -- 168
    Seq({ -- 169
        Con( -- 170
            "fmove key down", -- 170
            function(____self) -- 170
                local keyLeft = ____self.entity.keyLeft -- 171
                local keyRight = ____self.entity.keyRight -- 172
                return not (keyLeft and keyRight) and (keyLeft and ____self.faceRight or keyRight and not ____self.faceRight) -- 173
            end -- 170
        ), -- 170
        Act("turn") -- 179
    }), -- 179
    Seq({ -- 181
        Con( -- 182
            "is falling", -- 182
            function(____self) -- 182
                return not ____self.onSurface -- 183
            end -- 182
        ), -- 182
        Act("fallOff") -- 185
    }), -- 185
    Seq({ -- 187
        Con( -- 188
            "jump key down", -- 188
            function(____self) -- 188
                return ____self.entity.keyJump -- 189
            end -- 188
        ), -- 188
        Act("jump") -- 191
    }), -- 191
    Seq({ -- 193
        Con( -- 194
            "fmove key down", -- 194
            function(____self) -- 194
                return ____self.entity.keyLeft or ____self.entity.keyRight -- 195
            end -- 194
        ), -- 194
        Act("move") -- 197
    }), -- 197
    Act("idle") -- 199
}) -- 199
local unitDef = Dictionary() -- 202
unitDef.linearAcceleration = Vec2(0, -15) -- 203
unitDef.bodyType = "Dynamic" -- 204
unitDef.scale = 1 -- 205
unitDef.density = 1 -- 206
unitDef.friction = 1 -- 207
unitDef.restitution = 0 -- 208
unitDef.playable = "spine:Spine/moling" -- 209
unitDef.defaultFaceRight = true -- 210
unitDef.size = Size(60, 300) -- 211
unitDef.sensity = 0 -- 212
unitDef.move = 300 -- 213
unitDef.jump = 1000 -- 214
unitDef.detectDistance = 350 -- 215
unitDef.hp = 5 -- 216
unitDef.tag = "player" -- 217
unitDef.decisionTree = "AI:playerControl" -- 218
unitDef.usePreciseHit = false -- 219
unitDef.actions = Array({ -- 220
    "idle", -- 221
    "turn", -- 222
    "move", -- 223
    "jump", -- 224
    "fallOff", -- 225
    "cancel" -- 226
}) -- 226
Observer("Add", {"player"}):watch(function(____self) -- 229
    local unit = Unit( -- 230
        unitDef, -- 230
        world, -- 230
        ____self, -- 230
        Vec2(300, -350) -- 230
    ) -- 230
    unit.order = PlayerLayer -- 231
    unit.group = PlayerGroup -- 232
    unit.playable.position = Vec2(0, -150) -- 233
    unit.playable:play("idle", true) -- 234
    world:addChild(unit) -- 235
    world.camera.followTarget = unit -- 236
    return false -- 237
end) -- 229
Observer("Add", {"x", "icon"}):watch(function(____self, x, icon) -- 240
    local sprite = Sprite(icon) -- 241
    if not sprite then -- 241
        return false -- 242
    end -- 242
    sprite:runAction( -- 243
        Spawn( -- 243
            AngleY(5, 0, 360), -- 244
            Sequence( -- 245
                Y(2.5, 0, 40, Ease.OutQuad), -- 246
                Y(2.5, 40, 0, Ease.InQuad) -- 247
            ) -- 247
        ), -- 247
        true -- 249
    ) -- 249
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
    body:onBodyEnter(function(item) -- 262
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
    end) -- 262
    world:addChild(body) -- 276
    ____self.body = body -- 277
    return false -- 278
end) -- 240
Observer("Remove", {"body"}):watch(function(____self) -- 281
    local body = tolua.cast(____self.oldValues.body, "Body") -- 282
    if body ~= nil then -- 282
        body:removeFromParent() -- 284
    end -- 284
    return false -- 286
end) -- 281
local function loadExcel() -- 310
    local xlsx = Content:loadExcel("Data/items.xlsx", {"items"}) -- 311
    if xlsx ~= nil then -- 311
        local its = xlsx.items -- 313
        local names = its[2] -- 314
        table.remove(names, 1) -- 315
        if not Struct:has("Item") then -- 315
            Struct.Item(names) -- 317
        end -- 317
        Group({"item"}):each(function(e) -- 319
            e:destroy() -- 320
            return false -- 321
        end) -- 319
        do -- 319
            local i = 2 -- 323
            while i < #its do -- 323
                local st = Struct:load(its[i + 1]) -- 324
                local item = { -- 325
                    name = st.Name, -- 326
                    no = st.No, -- 327
                    x = st.X, -- 328
                    num = st.Num, -- 329
                    icon = st.Icon, -- 330
                    desc = st.Desc, -- 331
                    item = true -- 332
                } -- 332
                Entity(item) -- 334
                i = i + 1 -- 323
            end -- 323
        end -- 323
    end -- 323
end -- 310
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
local ui = AlignNode(true) -- 356
ui:css("flex-direction: column-reverse") -- 357
ui:onButtonDown(function(id, buttonName) -- 358
    if id ~= 0 then -- 358
        return -- 359
    end -- 359
    repeat -- 359
        local ____switch42 = buttonName -- 359
        local ____cond42 = ____switch42 == "dpleft" -- 359
        if ____cond42 then -- 359
            updatePlayerControl("keyLeft", true, true) -- 361
            break -- 361
        end -- 361
        ____cond42 = ____cond42 or ____switch42 == "dpright" -- 361
        if ____cond42 then -- 361
            updatePlayerControl("keyRight", true, true) -- 362
            break -- 362
        end -- 362
        ____cond42 = ____cond42 or ____switch42 == "b" -- 362
        if ____cond42 then -- 362
            updatePlayerControl("keyJump", true, true) -- 363
            break -- 363
        end -- 363
    until true -- 363
end) -- 358
ui:onButtonUp(function(id, buttonName) -- 366
    if id ~= 0 then -- 366
        return -- 367
    end -- 367
    repeat -- 367
        local ____switch45 = buttonName -- 367
        local ____cond45 = ____switch45 == "dpleft" -- 367
        if ____cond45 then -- 367
            updatePlayerControl("keyLeft", false, true) -- 369
            break -- 369
        end -- 369
        ____cond45 = ____cond45 or ____switch45 == "dpright" -- 369
        if ____cond45 then -- 369
            updatePlayerControl("keyRight", false, true) -- 370
            break -- 370
        end -- 370
        ____cond45 = ____cond45 or ____switch45 == "b" -- 370
        if ____cond45 then -- 370
            updatePlayerControl("keyJump", false, true) -- 371
            break -- 371
        end -- 371
    until true -- 371
end) -- 366
ui:addTo(Director.ui) -- 374
local bottomAlign = AlignNode() -- 376
bottomAlign:css("\n\theight: 60;\n\tjustify-content: space-between;\n\tmargin: 0, 20, 40;\n\tflex-direction: row\n") -- 377
bottomAlign:addTo(ui) -- 383
local leftAlign = AlignNode() -- 385
leftAlign:css("width: 130; height: 60") -- 386
leftAlign:addTo(bottomAlign) -- 387
local leftMenu = Menu() -- 389
leftMenu.size = Size(250, 120) -- 390
leftMenu.anchor = Vec2.zero -- 391
leftMenu.scaleY = 0.5 -- 392
leftMenu.scaleX = 0.5 -- 392
leftMenu:addTo(leftAlign) -- 393
local leftButton = CircleButton({text = "左(a)", radius = 60, fontSize = 36}) -- 395
leftButton.anchor = Vec2.zero -- 400
leftButton:onTapBegan(function() -- 401
    updatePlayerControl("keyLeft", true, true) -- 402
end) -- 401
leftButton:onTapEnded(function() -- 404
    updatePlayerControl("keyLeft", false, true) -- 405
end) -- 404
leftButton:addTo(leftMenu) -- 407
local rightButton = CircleButton({text = "右(d)", x = 130, radius = 60, fontSize = 36}) -- 409
rightButton.anchor = Vec2.zero -- 415
rightButton:onTapBegan(function() -- 416
    updatePlayerControl("keyRight", true, true) -- 417
end) -- 416
rightButton:onTapEnded(function() -- 419
    updatePlayerControl("keyRight", false, true) -- 420
end) -- 419
rightButton:addTo(leftMenu) -- 422
local rightAlign = AlignNode() -- 424
rightAlign:css("width: 60; height: 60") -- 425
rightAlign:addTo(bottomAlign) -- 426
local rightMenu = Menu() -- 428
rightMenu.size = Size(120, 120) -- 429
rightMenu.anchor = Vec2.zero -- 430
rightMenu.scaleY = 0.5 -- 431
rightMenu.scaleX = 0.5 -- 431
rightAlign:addChild(rightMenu) -- 432
local jumpButton = CircleButton({text = "跳(j)", radius = 60, fontSize = 36}) -- 434
jumpButton.anchor = Vec2.zero -- 439
jumpButton:onTapBegan(function() -- 440
    updatePlayerControl("keyJump", true, true) -- 441
end) -- 440
jumpButton:onTapEnded(function() -- 443
    updatePlayerControl("keyJump", false, true) -- 444
end) -- 443
jumpButton:addTo(rightMenu) -- 446
ui:schedule(function() -- 448
    local keyA = Keyboard:isKeyPressed("A") -- 449
    local keyD = Keyboard:isKeyPressed("D") -- 450
    local keyJ = Keyboard:isKeyPressed("J") -- 451
    if keyD or keyD or keyJ then -- 451
        keyboardEnabled = true -- 453
    end -- 453
    if not keyboardEnabled then -- 453
        return false -- 456
    end -- 456
    updatePlayerControl("keyLeft", keyA, false) -- 458
    updatePlayerControl("keyRight", keyD, false) -- 459
    updatePlayerControl("keyJump", keyJ, false) -- 460
    return false -- 461
end) -- 448
local pickedItemGroup = Group({"picked"}) -- 464
local windowFlags = { -- 465
    "NoDecoration", -- 466
    "AlwaysAutoResize", -- 467
    "NoSavedSettings", -- 468
    "NoFocusOnAppearing", -- 469
    "NoNav", -- 470
    "NoMove" -- 471
} -- 471
Director.ui:schedule(function() -- 473
    local size = App.visualSize -- 474
    ImGui.SetNextWindowBgAlpha(0.35) -- 475
    ImGui.SetNextWindowPos( -- 476
        Vec2(size.width - 10, 10), -- 476
        "Always", -- 476
        Vec2(1, 0) -- 476
    ) -- 476
    ImGui.SetNextWindowSize( -- 477
        Vec2(100, 300), -- 477
        "FirstUseEver" -- 477
    ) -- 477
    ImGui.Begin( -- 478
        "BackPack", -- 478
        windowFlags, -- 478
        function() -- 478
            if ImGui.Button("重新加载Excel") then -- 478
                loadExcel() -- 480
            end -- 480
            ImGui.Separator() -- 482
            ImGui.Dummy(Vec2(100, 10)) -- 483
            ImGui.Text("背包 (Typescript)") -- 484
            ImGui.Separator() -- 485
            ImGui.Columns(3, false) -- 486
            pickedItemGroup:each(function(e) -- 487
                local item = e -- 488
                if item.num > 0 then -- 488
                    if ImGui.ImageButton( -- 488
                        "item" .. tostring(item.no), -- 490
                        item.icon, -- 490
                        Vec2(50, 50) -- 490
                    ) then -- 490
                        item.num = item.num - 1 -- 491
                        local sprite = Sprite(item.icon) -- 492
                        if not sprite then -- 492
                            return false -- 493
                        end -- 493
                        sprite.scaleX = 0.5 -- 494
                        sprite.scaleY = 0.5 -- 495
                        sprite:perform(Spawn( -- 496
                            Opacity(1, 1, 0), -- 497
                            Y(1, 150, 250) -- 498
                        )) -- 498
                        local player = playerGroup:find(function() return true end) -- 500
                        if player ~= nil then -- 500
                            local unit = player.unit -- 502
                            unit:addChild(sprite) -- 503
                        end -- 503
                    end -- 503
                    if ImGui.IsItemHovered() then -- 503
                        ImGui.BeginTooltip(function() -- 507
                            ImGui.Text(item.name) -- 508
                            ImGui.TextColored(themeColor, "数量：") -- 509
                            ImGui.SameLine() -- 510
                            ImGui.Text(tostring(item.num)) -- 511
                            ImGui.TextColored(themeColor, "描述：") -- 512
                            ImGui.SameLine() -- 513
                            ImGui.Text(tostring(item.desc)) -- 514
                        end) -- 507
                    end -- 507
                    ImGui.NextColumn() -- 517
                end -- 517
                return false -- 519
            end) -- 487
        end -- 478
    ) -- 478
    return false -- 522
end) -- 473
Entity({player = true}) -- 525
loadExcel() -- 526
return ____exports -- 526