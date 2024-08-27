-- [yue]: init.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local Vec2 = Dora.Vec2 -- 1
local Director = Dora.Director -- 1
local View = Dora.View -- 1
local Node = Dora.Node -- 1
local Audio = Dora.Audio -- 1
local PhysicsWorld = Dora.PhysicsWorld -- 1
local BodyDef = Dora.BodyDef -- 1
local Color = Dora.Color -- 1
local DrawNode = Dora.DrawNode -- 1
local Camera2D = Dora.Camera2D -- 1
local Body = Dora.Body -- 1
local Sprite = Dora.Sprite -- 1
local tostring = _G.tostring -- 1
local math = _G.math -- 1
local once = Dora.once -- 1
local sleep = Dora.sleep -- 1
local threadLoop = Dora.threadLoop -- 1
local App = Dora.App -- 1
local _module_0 = Dora.ImGui -- 1
local SetNextWindowBgAlpha = _module_0.SetNextWindowBgAlpha -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local Text = _module_0.Text -- 1
local Separator = _module_0.Separator -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local Checkbox = _module_0.Checkbox -- 1
local scriptPath = Path:getScriptPath(...) -- 13
Content:insertSearchPath(1, scriptPath) -- 14
local gravity <const> = Vec2(0, -10) -- 16
local updateViewScale -- 18
updateViewScale = function() -- 18
	Director.currentCamera.zoom = View.size.width / 1620 -- 19
end -- 18
local root -- 20
do -- 20
	local _with_0 = Node() -- 20
	_with_0:gslot("AppSizeChanged", updateViewScale) -- 21
	root = _with_0 -- 20
end -- 20
local ui -- 23
do -- 23
	local _with_0 = Node() -- 23
	_with_0:addTo(Director.ui) -- 24
	ui = _with_0 -- 23
end -- 23
local heartNode = nil -- 25
local restartButton = nil -- 26
Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 27
local world -- 29
do -- 29
	local _with_0 = PhysicsWorld() -- 29
	_with_0:setShouldContact(0, 1, true) -- 30
	_with_0.showDebug = false -- 31
	_with_0:addTo(root) -- 32
	world = _with_0 -- 29
end -- 29
local restartGame = nil -- 34
local cube = nil -- 35
local touchTheSky = false -- 36
local isInvincible = false -- 37
local hardMode = false -- 38
local getCubeDef -- 40
getCubeDef = function(width, height) -- 40
	local _with_0 = BodyDef() -- 40
	_with_0.type = "Dynamic" -- 41
	_with_0.linearAcceleration = gravity -- 42
	_with_0.angularDamping = 1.8 -- 43
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 45
	return _with_0 -- 40
end -- 40
local getBlockDef -- 47
getBlockDef = function(width, height) -- 47
	local _with_0 = BodyDef() -- 47
	_with_0.type = "Static" -- 48
	_with_0.linearAcceleration = gravity -- 49
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 50
	return _with_0 -- 47
end -- 47
local colorWhite = Color(0xccffffff) -- 52
local colorRed = Color(0xaae65100) -- 53
local colorBlue = Color(0xaa00b0ff) -- 54
local borderHeight = 19000 -- 56
local borderWidth = 1600 -- 57
local borderPos = Vec2(0, 0) -- 58
local springForce = 1000 -- 60
local heart = 3 -- 61
local cubeInitPos = Vec2(0, 100) -- 62
local borderDef -- 64
do -- 64
	local _with_0 = BodyDef() -- 64
	_with_0.type = "Static" -- 65
	_with_0:attachPolygon(borderPos, borderWidth, 10, 0, 1, 1, 0) -- 66
	_with_0:attachPolygon(Vec2(borderPos.x + borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 67
	_with_0:attachPolygon(Vec2(borderPos.x - borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 68
	borderDef = _with_0 -- 64
end -- 64
local destinationDef -- 70
do -- 70
	local _with_0 = BodyDef() -- 70
	_with_0:attachPolygonSensor(1, borderWidth, 10) -- 71
	destinationDef = _with_0 -- 70
end -- 70
local blockLevel = { -- 73
	300, -- 73
	5200, -- 73
	9800, -- 73
	14400 -- 73
} -- 73
local blocks1 = { -- 76
	{ -- 76
		200, -- 76
		200, -- 76
		Vec2(-700, 0), -- 76
		2 -- 76
	}, -- 76
	{ -- 77
		1000, -- 77
		200, -- 77
		Vec2(300, 400), -- 77
		0 -- 77
	}, -- 77
	{ -- 78
		200, -- 78
		200, -- 78
		Vec2(500, 800), -- 78
		1 -- 78
	}, -- 78
	{ -- 79
		600, -- 79
		200, -- 79
		Vec2(-500, 1000), -- 79
		2 -- 79
	}, -- 79
	{ -- 80
		200, -- 80
		200, -- 80
		Vec2(-300, 1400), -- 80
		0 -- 80
	}, -- 80
	{ -- 81
		200, -- 81
		200, -- 81
		Vec2(-100, 1600), -- 81
		0 -- 81
	}, -- 81
	{ -- 82
		200, -- 82
		200, -- 82
		Vec2(-300, 2000), -- 82
		2 -- 82
	}, -- 82
	{ -- 83
		200, -- 83
		200, -- 83
		Vec2(-500, 2200), -- 83
		2 -- 83
	}, -- 83
	{ -- 84
		200, -- 84
		200, -- 84
		Vec2(500, 2200), -- 84
		0 -- 84
	}, -- 84
	{ -- 85
		200, -- 85
		200, -- 85
		Vec2(300, 2400), -- 85
		0 -- 85
	}, -- 85
	{ -- 86
		200, -- 86
		200, -- 86
		Vec2(500, 2600), -- 86
		1 -- 86
	}, -- 86
	{ -- 87
		200, -- 87
		200, -- 87
		Vec2(-500, 2800), -- 87
		0 -- 87
	}, -- 87
	{ -- 88
		200, -- 88
		200, -- 88
		Vec2(-300, 3000), -- 88
		0 -- 88
	}, -- 88
	{ -- 89
		200, -- 89
		400, -- 89
		Vec2(700, 3100), -- 89
		0 -- 89
	}, -- 89
	{ -- 90
		1200, -- 90
		200, -- 90
		Vec2(-200, 3600), -- 90
		2 -- 90
	} -- 90
} -- 75
local blocks2 = { -- 94
	{ -- 94
		200, -- 94
		1000, -- 94
		Vec2(-300, 0), -- 94
		2 -- 94
	}, -- 94
	{ -- 95
		200, -- 95
		200, -- 95
		Vec2(300, -200), -- 95
		1 -- 95
	}, -- 95
	{ -- 96
		200, -- 96
		1000, -- 96
		Vec2(300, 800), -- 96
		2 -- 96
	}, -- 96
	{ -- 97
		200, -- 97
		200, -- 97
		Vec2(300, 1400), -- 97
		1 -- 97
	}, -- 97
	{ -- 98
		200, -- 98
		1600, -- 98
		Vec2(-300, 1500), -- 98
		2 -- 98
	}, -- 98
	{ -- 99
		200, -- 99
		200, -- 99
		Vec2(-500, 2400), -- 99
		1 -- 99
	}, -- 99
	{ -- 100
		200, -- 100
		1200, -- 100
		Vec2(500, 2500), -- 100
		0 -- 100
	}, -- 100
	{ -- 101
		200, -- 101
		200, -- 101
		Vec2(-700, 3000), -- 101
		2 -- 101
	}, -- 101
	{ -- 102
		200, -- 102
		200, -- 102
		Vec2(-500, 3200), -- 102
		2 -- 102
	}, -- 102
	{ -- 103
		200, -- 103
		200, -- 103
		Vec2(-300, 3400), -- 103
		2 -- 103
	}, -- 103
	{ -- 104
		800, -- 104
		200, -- 104
		Vec2(400, 4000), -- 104
		0 -- 104
	} -- 104
} -- 93
local blocks3 = { -- 108
	{ -- 108
		200, -- 108
		4000, -- 108
		Vec2(-700, 1900), -- 108
		2 -- 108
	}, -- 108
	{ -- 109
		200, -- 109
		200, -- 109
		Vec2(-100, 400), -- 109
		2 -- 109
	}, -- 109
	{ -- 110
		200, -- 110
		200, -- 110
		Vec2(100, 600), -- 110
		1 -- 110
	}, -- 110
	{ -- 111
		200, -- 111
		200, -- 111
		Vec2(300, 1200), -- 111
		1 -- 111
	}, -- 111
	{ -- 112
		200, -- 112
		200, -- 112
		Vec2(100, 1400), -- 112
		1 -- 112
	}, -- 112
	{ -- 113
		200, -- 113
		200, -- 113
		Vec2(300, 1800), -- 113
		1 -- 113
	}, -- 113
	{ -- 114
		400, -- 114
		200, -- 114
		Vec2(600, 2000), -- 114
		0 -- 114
	}, -- 114
	{ -- 115
		200, -- 115
		200, -- 115
		Vec2(100, 3000), -- 115
		1 -- 115
	}, -- 115
	{ -- 116
		200, -- 116
		200, -- 116
		Vec2(300, 3200), -- 116
		1 -- 116
	}, -- 116
	{ -- 117
		200, -- 117
		200, -- 117
		Vec2(300, 3400), -- 117
		2 -- 117
	}, -- 117
	{ -- 118
		200, -- 118
		200, -- 118
		Vec2(100, 3600), -- 118
		1 -- 118
	}, -- 118
	{ -- 119
		200, -- 119
		200, -- 119
		Vec2(-100, 3800), -- 119
		1 -- 119
	}, -- 119
	{ -- 120
		400, -- 120
		200, -- 120
		Vec2(0, 4000), -- 120
		0 -- 120
	} -- 120
} -- 107
local blocks4 = { -- 124
	{ -- 124
		200, -- 124
		200, -- 124
		Vec2(-300, 0), -- 124
		1 -- 124
	}, -- 124
	{ -- 125
		200, -- 125
		200, -- 125
		Vec2(300, 0), -- 125
		1 -- 125
	}, -- 125
	{ -- 126
		200, -- 126
		200, -- 126
		Vec2(-500, 600), -- 126
		1 -- 126
	}, -- 126
	{ -- 127
		200, -- 127
		200, -- 127
		Vec2(100, 600), -- 127
		1 -- 127
	}, -- 127
	{ -- 128
		200, -- 128
		200, -- 128
		Vec2(700, 600), -- 128
		1 -- 128
	}, -- 128
	{ -- 129
		600, -- 129
		200, -- 129
		Vec2(0, 1200), -- 129
		0 -- 129
	}, -- 129
	{ -- 130
		200, -- 130
		600, -- 130
		Vec2(700, 1400), -- 130
		2 -- 130
	}, -- 130
	{ -- 131
		200, -- 131
		1000, -- 131
		Vec2(-700, 1800), -- 131
		2 -- 131
	}, -- 131
	{ -- 132
		200, -- 132
		600, -- 132
		Vec2(-100, 2200), -- 132
		2 -- 132
	}, -- 132
	{ -- 133
		200, -- 133
		600, -- 133
		Vec2(500, 2400), -- 133
		1 -- 133
	}, -- 133
	{ -- 134
		200, -- 134
		200, -- 134
		Vec2(100, 2800), -- 134
		2 -- 134
	}, -- 134
	{ -- 135
		200, -- 135
		200, -- 135
		Vec2(300, 3000), -- 135
		2 -- 135
	}, -- 135
	{ -- 136
		200, -- 136
		200, -- 136
		Vec2(-300, 3400), -- 136
		2 -- 136
	}, -- 136
	{ -- 137
		200, -- 137
		1200, -- 137
		Vec2(500, 3700), -- 137
		2 -- 137
	}, -- 137
	{ -- 138
		200, -- 138
		800, -- 138
		Vec2(-500, 3900), -- 138
		2 -- 138
	} -- 138
} -- 123
local blockTypes = { -- 142
	blocks1, -- 142
	blocks2, -- 143
	blocks3, -- 144
	blocks4 -- 145
} -- 141
local blockBodies = { } -- 147
local ropeNode -- 149
do -- 149
	local _with_0 = DrawNode() -- 149
	_with_0:addTo(root) -- 150
	ropeNode = _with_0 -- 149
end -- 149
local isGrabbing = false -- 151
local isGrabbed = false -- 152
local grabBlock = Node() -- 153
local emitRope -- 155
emitRope = function(cubeBody, endPoint) -- 155
	local startPoint = cubeBody.position -- 156
	local isBlock = false -- 157
	local isSelf = true -- 158
	local grabPoint = endPoint -- 159
	Audio:play("sfx/slime_touch.wav") -- 160
	world:raycast(startPoint, endPoint, false, function(_body, point) -- 161
		if isBlock then -- 162
			isGrabbed = true -- 163
			grabPoint = point -- 164
			isBlock = false -- 165
		end -- 162
		if isSelf then -- 166
			isSelf = false -- 167
			isBlock = true -- 168
		end -- 166
	end) -- 161
	ropeNode:schedule(function() -- 170
		ropeNode:clear() -- 171
		if not hardMode or isGrabbed then -- 172
			return ropeNode:drawSegment(cubeBody.position, grabPoint, 10, Color(0xaaffffff)) -- 179
		end -- 172
	end) -- 170
	return ropeNode -- 169
end -- 155
local getGrabForce -- 181
getGrabForce = function(body, target) -- 181
	local prePos = body.position -- 182
	local force = target - prePos -- 183
	force = force:normalize() * 30 -- 184
	return force -- 185
end -- 181
local camera = Camera2D() -- 187
Director:pushCamera(camera) -- 188
updateViewScale() -- 189
local cameraFollow -- 191
cameraFollow = function(body) -- 191
	local _with_0 = Node() -- 192
	_with_0:schedule(function() -- 193
		camera.position = Vec2(0, (body.position.y - camera.position.y) * 0.1 + camera.position.y + 30) -- 194
	end) -- 193
	return _with_0 -- 192
end -- 191
local _anon_func_0 = function(Sprite, _with_0, scale) -- 207
	local _with_1 = Sprite("Image/cube.png") -- 206
	_with_1.scaleX = scale -- 207
	_with_1.scaleY = scale -- 207
	return _with_1 -- 206
end -- 206
local addCube -- 196
addCube = function() -- 196
	do -- 197
		local _with_0 = Node() -- 197
		_with_0:addTo(world) -- 198
		cube = _with_0 -- 197
	end -- 197
	local scale = 0.5 -- 199
	local cubebody -- 200
	do -- 200
		local _with_0 = Body(getCubeDef(256 * scale, 256 * scale), world, cubeInitPos) -- 200
		_with_0.receivingContact = true -- 201
		_with_0.tag = "cubeBody" -- 202
		_with_0.group = 0 -- 203
		_with_0.angularRate = 0 -- 204
		_with_0.velocity = Vec2.zero -- 205
		_with_0:addChild(_anon_func_0(Sprite, _with_0, scale)) -- 206
		_with_0:addTo(cube) -- 208
		cubebody = _with_0 -- 200
	end -- 200
	return cameraFollow(cubebody) -- 209
end -- 196
local _anon_func_1 = function(Sprite, View, _with_0) -- 216
	local _with_1 = Sprite("Image/heart_3.png") -- 213
	_with_1.tag = "heartSprite" -- 214
	_with_1.y = View.size.height / 2 - 100 -- 215
	_with_1.scaleX = 6 -- 216
	_with_1.scaleY = 6 -- 216
	return _with_1 -- 213
end -- 213
local addHeartUI -- 211
addHeartUI = function() -- 211
	do -- 212
		local _with_0 = Node() -- 212
		_with_0:addChild(_anon_func_1(Sprite, View, _with_0)) -- 213
		heartNode = _with_0 -- 212
	end -- 212
	return ui:addChild(heartNode) -- 217
end -- 211
local _anon_func_2 = function(View, heartSprite) -- 229
	heartSprite.tag = "heartSprite" -- 227
	heartSprite.y = View.size.height / 2 - 100 -- 228
	heartSprite.scaleX = 6 -- 229
	heartSprite.scaleY = 6 -- 229
	return heartSprite -- 226
end -- 226
local loseHeart -- 219
loseHeart = function() -- 219
	heart = heart - 1 -- 220
	heartNode:removeAllChildren() -- 221
	local heartSprite -- 222
	if 0 <= heart and heart <= 3 then -- 222
		heartSprite = Sprite("Image/heart_" .. tostring(math.tointeger(heart)) .. ".png") -- 223
	else -- 225
		heartSprite = Sprite("Image/heart_0.png") -- 225
	end -- 222
	return heartNode:addChild(_anon_func_2(View, heartSprite)) -- 229
end -- 219
local arriveDest -- 231
arriveDest = function() -- 231
	touchTheSky = true -- 232
	Audio:play("sfx/sky3.mp3") -- 233
	Audio:playStream("sfx/victory.ogg", true, 0.2) -- 234
	local body = cube:getChildByTag("cubeBody") -- 235
	body:applyLinearImpulse(Vec2(0, 1500), body.position) -- 236
	local _with_0 = Node() -- 237
	_with_0:addChild((function() -- 238
		local _with_1 = Sprite("Image/restart.png") -- 238
		_with_1.scaleX = 2 -- 239
		_with_1.scaleY = 2 -- 239
		_with_1.touchEnabled = true -- 240
		_with_1:slot("TapBegan", function() -- 241
			restartButton:removeFromParent() -- 242
			return restartGame() -- 243
		end) -- 241
		return _with_1 -- 238
	end)()) -- 238
	_with_0:addTo(ui) -- 244
	restartButton = _with_0 -- 237
end -- 231
local _anon_func_3 = function(Sprite, _with_0) -- 282
	local _with_1 = Sprite("Image/red.png") -- 281
	_with_1.scaleX = 0.15 -- 282
	_with_1.scaleY = 0.15 -- 282
	return _with_1 -- 281
end -- 281
local _anon_func_4 = function(Sprite, _with_0) -- 286
	local _with_1 = Sprite("Image/spring.png") -- 285
	_with_1.scaleX = 0.15 -- 286
	_with_1.scaleY = 0.15 -- 286
	return _with_1 -- 285
end -- 285
local _anon_func_5 = function(DrawNode, Vec2, _with_0, blockColor, height, width) -- 303
	local _with_1 = DrawNode() -- 296
	local verts = { -- 298
		Vec2(-width / 2, height / 2), -- 298
		Vec2(width / 2, height / 2), -- 299
		Vec2(width / 2, -height / 2), -- 300
		Vec2(-width / 2, -height / 2) -- 301
	} -- 297
	_with_1:drawPolygon(verts, blockColor) -- 303
	return _with_1 -- 296
end -- 296
local buildBlocks -- 246
buildBlocks = function(index) -- 246
	local blocks = blockTypes[index] -- 247
	for _index_0 = 1, #blocks do -- 248
		local block = blocks[_index_0] -- 248
		local width, height, pos, blockType = block[1], block[2], block[3], block[4] -- 249
		pos = pos + Vec2(0, blockLevel[index]) -- 250
		local _with_0 = Body(getBlockDef(width, height), world, pos) -- 251
		_with_0.group = 1 -- 252
		local blockColor = Color(0xffffffff) -- 253
		_with_0:attachSensor(1, BodyDef:polygon(width + 15, height + 15)) -- 254
		if 0 == blockType then -- 255
			_with_0:slot("BodyEnter", function() -- 256
				return Audio:play("sfx/strike.wav") -- 257
			end) -- 256
			blockColor = colorWhite -- 258
		elseif 1 == blockType then -- 259
			_with_0:slot("BodyEnter", function(body) -- 260
				if not isInvincible then -- 261
					loseHeart() -- 262
					body:applyLinearImpulse(Vec2(math.random(-1000, 1000), math.random(-1000, -500)), body.position) -- 263
					Audio:play("sfx/explode2.wav") -- 265
				end -- 261
				_with_0:schedule(once(function() -- 266
					isInvincible = true -- 267
					sleep(1) -- 268
					isInvincible = false -- 269
				end)) -- 266
				if heart <= 0 then -- 270
					isGrabbing = false -- 271
					isGrabbed = false -- 272
					grabBlock:unschedule() -- 273
					ropeNode:clear() -- 274
					ropeNode:unschedule() -- 275
					Audio:play("sfx/game_over.wav") -- 276
					return _with_0:schedule(once(function() -- 277
						sleep(0.5) -- 278
						return restartGame() -- 279
					end)) -- 279
				end -- 270
			end) -- 260
			blockColor = colorRed -- 280
			_with_0:addChild(_anon_func_3(Sprite, _with_0)) -- 281
		elseif 2 == blockType then -- 283
			blockColor = colorBlue -- 284
			_with_0:addChild(_anon_func_4(Sprite, _with_0)) -- 285
			local implulseAvailable = true -- 287
			_with_0:slot("BodyEnter", function(body) -- 288
				if not implulseAvailable then -- 289
					return -- 289
				end -- 289
				Audio:play("sfx/rebound.wav") -- 290
				body:applyLinearImpulse(Vec2(0, springForce), body.position) -- 291
				implulseAvailable = false -- 292
				return _with_0:schedule(once(function() -- 293
					sleep(0.2) -- 294
					implulseAvailable = true -- 295
				end)) -- 295
			end) -- 288
		end -- 295
		_with_0:addChild(_anon_func_5(DrawNode, Vec2, _with_0, blockColor, height, width)) -- 296
		_with_0:addTo(world) -- 304
		blockBodies[#blockBodies + 1] = _with_0 -- 251
	end -- 304
end -- 246
local _anon_func_6 = function(Sprite, _with_0) -- 316
	local _with_1 = Sprite("Image/sky.png") -- 313
	_with_1.x = 90 -- 314
	_with_1.y = 100 -- 315
	_with_1.scaleX = 2.7 -- 316
	_with_1.scaleY = 2.7 -- 316
	return _with_1 -- 313
end -- 313
local _anon_func_7 = function(DrawNode, Vec2, _with_0, borderHeight, borderWidth, colorWhite) -- 325
	local _with_1 = DrawNode() -- 322
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(borderWidth / 2, 0), 10, colorWhite) -- 323
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(-borderWidth / 2, borderHeight), 10, colorWhite) -- 324
	_with_1:drawSegment(Vec2(borderWidth / 2, 0), Vec2(borderWidth / 2, borderHeight), 10, colorWhite) -- 325
	return _with_1 -- 322
end -- 322
local buildWorld -- 306
buildWorld = function() -- 306
	buildBlocks(1) -- 307
	buildBlocks(2) -- 308
	buildBlocks(3) -- 309
	buildBlocks(4) -- 310
	do -- 311
		local _with_0 = Body(destinationDef, world, Vec2(borderPos.x, borderPos.y + borderHeight)) -- 311
		_with_0.group = 1 -- 312
		_with_0:addChild(_anon_func_6(Sprite, _with_0)) -- 313
		_with_0:slot("BodyEnter", function() -- 317
			if not touchTheSky then -- 318
				return arriveDest() -- 318
			end -- 318
		end) -- 317
		_with_0:addTo(world) -- 319
	end -- 311
	do -- 320
		local _with_0 = Body(borderDef, world, Vec2.zero) -- 320
		_with_0.group = 1 -- 321
		_with_0:addChild(_anon_func_7(DrawNode, Vec2, _with_0, borderHeight, borderWidth, colorWhite)) -- 322
		_with_0:addTo(world) -- 326
	end -- 320
	local _with_0 = Node() -- 327
	_with_0.touchEnabled = true -- 328
	_with_0:slot("TapBegan", function(touch) -- 329
		isGrabbing = true -- 330
		if not touch.first then -- 331
			return -- 331
		end -- 331
		local location = touch.location -- 332
		local body = cube:getChildByTag("cubeBody") -- 333
		emitRope(body, location) -- 334
		if not hardMode or isGrabbed then -- 335
			grabBlock:schedule(function() -- 337
				return body:applyLinearImpulse(getGrabForce(body, location), body.position) -- 338
			end) -- 337
			return grabBlock -- 336
		end -- 335
	end) -- 329
	_with_0:slot("TapEnded", function() -- 339
		isGrabbing = false -- 340
		isGrabbed = false -- 341
		grabBlock:unschedule() -- 342
		ropeNode:clear() -- 343
		return ropeNode:unschedule() -- 344
	end) -- 339
	_with_0:addTo(root) -- 345
	return _with_0 -- 327
end -- 306
addCube() -- 347
buildWorld() -- 348
addHeartUI() -- 349
restartGame = function() -- 351
	if touchTheSky then -- 352
		Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 353
	end -- 352
	heart = 3 -- 354
	touchTheSky = false -- 355
	local body = cube:getChildByTag("cubeBody") -- 356
	body.position = Vec2.zero -- 357
	body.angularRate = 0 -- 358
	ui:removeFromParent() -- 359
	do -- 360
		local _with_0 = Node() -- 360
		_with_0:addTo(Director.ui) -- 361
		heartNode:removeFromParent() -- 362
		ui = _with_0 -- 360
	end -- 360
	return addHeartUI() -- 363
end -- 351
local windowFlags = { -- 366
	"NoDecoration", -- 366
	"NoSavedSettings", -- 367
	"NoFocusOnAppearing", -- 368
	"NoNav", -- 369
	"NoMove" -- 370
} -- 365
return threadLoop(function() -- 371
	local width, height -- 372
	do -- 372
		local _obj_0 = App.visualSize -- 372
		width, height = _obj_0.width, _obj_0.height -- 372
	end -- 372
	SetNextWindowBgAlpha(0.35) -- 373
	SetNextWindowPos(Vec2(width - 140, height - 170), "Always", Vec2.zero) -- 374
	SetNextWindowSize(Vec2(140, 0), "Always") -- 375
	return Begin("Touch The Sky", windowFlags, function() -- 376
		Text("Touch The Sky") -- 377
		Separator() -- 378
		TextWrapped("Click to grab!") -- 379
		local changed, isHardMode = Checkbox("Hard Mode", hardMode) -- 380
		if changed then -- 380
			hardMode = isHardMode -- 381
		end -- 380
	end) -- 381
end) -- 381
