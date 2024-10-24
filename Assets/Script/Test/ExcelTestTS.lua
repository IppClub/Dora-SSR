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
local CircleButton = require("UI.Control.Basic.CircleButton") -- 340
local ImGui = require("ImGui") -- 342
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
		if not its then -- 313
			return -- 314
		end -- 314
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
end -- 310
local keyboardEnabled = true -- 344
local playerGroup = Group({"player"}) -- 346
local function updatePlayerControl(key, flag, vpad) -- 347
	if keyboardEnabled and vpad then -- 347
		keyboardEnabled = false -- 349
	end -- 349
	playerGroup:each(function(____self) -- 351
		____self[key] = flag -- 352
		return false -- 353
	end) -- 351
end -- 347
local ui = AlignNode(true) -- 357
ui:css("flex-direction: column-reverse") -- 358
ui:onButtonDown(function(id, buttonName) -- 359
	if id ~= 0 then -- 359
		return -- 360
	end -- 360
	repeat -- 360
		local ____switch43 = buttonName -- 360
		local ____cond43 = ____switch43 == "dpleft" -- 360
		if ____cond43 then -- 360
			updatePlayerControl("keyLeft", true, true) -- 362
			break -- 362
		end -- 362
		____cond43 = ____cond43 or ____switch43 == "dpright" -- 362
		if ____cond43 then -- 362
			updatePlayerControl("keyRight", true, true) -- 363
			break -- 363
		end -- 363
		____cond43 = ____cond43 or ____switch43 == "b" -- 363
		if ____cond43 then -- 363
			updatePlayerControl("keyJump", true, true) -- 364
			break -- 364
		end -- 364
	until true -- 364
end) -- 359
ui:onButtonUp(function(id, buttonName) -- 367
	if id ~= 0 then -- 367
		return -- 368
	end -- 368
	repeat -- 368
		local ____switch46 = buttonName -- 368
		local ____cond46 = ____switch46 == "dpleft" -- 368
		if ____cond46 then -- 368
			updatePlayerControl("keyLeft", false, true) -- 370
			break -- 370
		end -- 370
		____cond46 = ____cond46 or ____switch46 == "dpright" -- 370
		if ____cond46 then -- 370
			updatePlayerControl("keyRight", false, true) -- 371
			break -- 371
		end -- 371
		____cond46 = ____cond46 or ____switch46 == "b" -- 371
		if ____cond46 then -- 371
			updatePlayerControl("keyJump", false, true) -- 372
			break -- 372
		end -- 372
	until true -- 372
end) -- 367
ui:addTo(Director.ui) -- 375
local bottomAlign = AlignNode() -- 377
bottomAlign:css("\n\theight: 60;\n\tjustify-content: space-between;\n\tmargin: 0, 20, 40;\n\tflex-direction: row\n") -- 378
bottomAlign:addTo(ui) -- 384
local leftAlign = AlignNode() -- 386
leftAlign:css("width: 130; height: 60") -- 387
leftAlign:addTo(bottomAlign) -- 388
local leftMenu = Menu() -- 390
leftMenu.size = Size(250, 120) -- 391
leftMenu.anchor = Vec2.zero -- 392
leftMenu.scaleY = 0.5 -- 393
leftMenu.scaleX = 0.5 -- 393
leftMenu:addTo(leftAlign) -- 394
local leftButton = CircleButton({text = "左(a)", radius = 60, fontSize = 36}) -- 396
leftButton.anchor = Vec2.zero -- 401
leftButton:onTapBegan(function() -- 402
	updatePlayerControl("keyLeft", true, true) -- 403
end) -- 402
leftButton:onTapEnded(function() -- 405
	updatePlayerControl("keyLeft", false, true) -- 406
end) -- 405
leftButton:addTo(leftMenu) -- 408
local rightButton = CircleButton({text = "右(d)", x = 130, radius = 60, fontSize = 36}) -- 410
rightButton.anchor = Vec2.zero -- 416
rightButton:onTapBegan(function() -- 417
	updatePlayerControl("keyRight", true, true) -- 418
end) -- 417
rightButton:onTapEnded(function() -- 420
	updatePlayerControl("keyRight", false, true) -- 421
end) -- 420
rightButton:addTo(leftMenu) -- 423
local rightAlign = AlignNode() -- 425
rightAlign:css("width: 60; height: 60") -- 426
rightAlign:addTo(bottomAlign) -- 427
local rightMenu = Menu() -- 429
rightMenu.size = Size(120, 120) -- 430
rightMenu.anchor = Vec2.zero -- 431
rightMenu.scaleY = 0.5 -- 432
rightMenu.scaleX = 0.5 -- 432
rightAlign:addChild(rightMenu) -- 433
local jumpButton = CircleButton({text = "跳(j)", radius = 60, fontSize = 36}) -- 435
jumpButton.anchor = Vec2.zero -- 440
jumpButton:onTapBegan(function() -- 441
	updatePlayerControl("keyJump", true, true) -- 442
end) -- 441
jumpButton:onTapEnded(function() -- 444
	updatePlayerControl("keyJump", false, true) -- 445
end) -- 444
jumpButton:addTo(rightMenu) -- 447
ui:schedule(function() -- 449
	local keyA = Keyboard:isKeyPressed("A") -- 450
	local keyD = Keyboard:isKeyPressed("D") -- 451
	local keyJ = Keyboard:isKeyPressed("J") -- 452
	if keyD or keyD or keyJ then -- 452
		keyboardEnabled = true -- 454
	end -- 454
	if not keyboardEnabled then -- 454
		return false -- 457
	end -- 457
	updatePlayerControl("keyLeft", keyA, false) -- 459
	updatePlayerControl("keyRight", keyD, false) -- 460
	updatePlayerControl("keyJump", keyJ, false) -- 461
	return false -- 462
end) -- 449
local pickedItemGroup = Group({"picked"}) -- 465
local windowFlags = { -- 466
	"NoDecoration", -- 467
	"AlwaysAutoResize", -- 468
	"NoSavedSettings", -- 469
	"NoFocusOnAppearing", -- 470
	"NoNav", -- 471
	"NoMove" -- 472
} -- 472
Director.ui:schedule(function() -- 474
	local size = App.visualSize -- 475
	ImGui.SetNextWindowBgAlpha(0.35) -- 476
	ImGui.SetNextWindowPos( -- 477
		Vec2(size.width - 10, 10), -- 477
		"Always", -- 477
		Vec2(1, 0) -- 477
	) -- 477
	ImGui.SetNextWindowSize( -- 478
		Vec2(100, 300), -- 478
		"FirstUseEver" -- 478
	) -- 478
	ImGui.Begin( -- 479
		"BackPack", -- 479
		windowFlags, -- 479
		function() -- 479
			if ImGui.Button("重新加载Excel") then -- 479
				loadExcel() -- 481
			end -- 481
			ImGui.Separator() -- 483
			ImGui.Dummy(Vec2(100, 10)) -- 484
			ImGui.Text("背包 (Typescript)") -- 485
			ImGui.Separator() -- 486
			ImGui.Columns(3, false) -- 487
			pickedItemGroup:each(function(e) -- 488
				local item = e -- 489
				if item.num > 0 then -- 489
					if ImGui.ImageButton( -- 489
						"item" .. tostring(item.no), -- 491
						item.icon, -- 491
						Vec2(50, 50) -- 491
					) then -- 491
						item.num = item.num - 1 -- 492
						local sprite = Sprite(item.icon) -- 493
						if not sprite then -- 493
							return false -- 494
						end -- 494
						sprite.scaleX = 0.5 -- 495
						sprite.scaleY = 0.5 -- 496
						sprite:perform(Spawn( -- 497
							Opacity(1, 1, 0), -- 498
							Y(1, 150, 250) -- 499
						)) -- 499
						local player = playerGroup:find(function() return true end) -- 501
						if player ~= nil then -- 501
							local unit = player.unit -- 503
							unit:addChild(sprite) -- 504
						end -- 504
					end -- 504
					if ImGui.IsItemHovered() then -- 504
						ImGui.BeginTooltip(function() -- 508
							ImGui.Text(item.name) -- 509
							ImGui.TextColored(themeColor, "数量：") -- 510
							ImGui.SameLine() -- 511
							ImGui.Text(tostring(item.num)) -- 512
							ImGui.TextColored(themeColor, "描述：") -- 513
							ImGui.SameLine() -- 514
							ImGui.Text(tostring(item.desc)) -- 515
						end) -- 508
					end -- 508
					ImGui.NextColumn() -- 518
				end -- 518
				return false -- 520
			end) -- 488
		end -- 479
	) -- 479
	return false -- 523
end) -- 474
Entity({player = true}) -- 526
loadExcel() -- 527
return ____exports -- 527