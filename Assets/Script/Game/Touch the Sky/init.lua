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
	_with_0:onAppChange(function(settingName) -- 21
		if settingName == "Size" then -- 21
			return updateViewScale() -- 22
		end -- 21
	end) -- 21
	root = _with_0 -- 20
end -- 20
local ui -- 24
do -- 24
	local _with_0 = Node() -- 24
	_with_0:addTo(Director.ui) -- 25
	ui = _with_0 -- 24
end -- 24
local heartNode = nil -- 26
local restartButton = nil -- 27
Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 28
local world -- 30
do -- 30
	local _with_0 = PhysicsWorld() -- 30
	_with_0:setShouldContact(0, 1, true) -- 31
	_with_0.showDebug = false -- 32
	_with_0:addTo(root) -- 33
	world = _with_0 -- 30
end -- 30
local restartGame = nil -- 35
local cube = nil -- 36
local touchTheSky = false -- 37
local isInvincible = false -- 38
local hardMode = false -- 39
local getCubeDef -- 41
getCubeDef = function(width, height) -- 41
	local _with_0 = BodyDef() -- 41
	_with_0.type = "Dynamic" -- 42
	_with_0.linearAcceleration = gravity -- 43
	_with_0.angularDamping = 1.8 -- 44
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 46
	return _with_0 -- 41
end -- 41
local getBlockDef -- 48
getBlockDef = function(width, height) -- 48
	local _with_0 = BodyDef() -- 48
	_with_0.type = "Static" -- 49
	_with_0.linearAcceleration = gravity -- 50
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 51
	return _with_0 -- 48
end -- 48
local colorWhite = Color(0xccffffff) -- 53
local colorRed = Color(0xaae65100) -- 54
local colorBlue = Color(0xaa00b0ff) -- 55
local borderHeight = 19000 -- 57
local borderWidth = 1600 -- 58
local borderPos = Vec2(0, 0) -- 59
local springForce = 1000 -- 61
local heart = 3 -- 62
local cubeInitPos = Vec2(0, 100) -- 63
local borderDef -- 65
do -- 65
	local _with_0 = BodyDef() -- 65
	_with_0.type = "Static" -- 66
	_with_0:attachPolygon(borderPos, borderWidth, 10, 0, 1, 1, 0) -- 67
	_with_0:attachPolygon(Vec2(borderPos.x + borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 68
	_with_0:attachPolygon(Vec2(borderPos.x - borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 69
	borderDef = _with_0 -- 65
end -- 65
local destinationDef -- 71
do -- 71
	local _with_0 = BodyDef() -- 71
	_with_0:attachPolygonSensor(1, borderWidth, 10) -- 72
	destinationDef = _with_0 -- 71
end -- 71
local blockLevel = { -- 74
	300, -- 74
	5200, -- 74
	9800, -- 74
	14400 -- 74
} -- 74
local blocks1 = { -- 77
	{ -- 77
		200, -- 77
		200, -- 77
		Vec2(-700, 0), -- 77
		2 -- 77
	}, -- 77
	{ -- 78
		1000, -- 78
		200, -- 78
		Vec2(300, 400), -- 78
		0 -- 78
	}, -- 78
	{ -- 79
		200, -- 79
		200, -- 79
		Vec2(500, 800), -- 79
		1 -- 79
	}, -- 79
	{ -- 80
		600, -- 80
		200, -- 80
		Vec2(-500, 1000), -- 80
		2 -- 80
	}, -- 80
	{ -- 81
		200, -- 81
		200, -- 81
		Vec2(-300, 1400), -- 81
		0 -- 81
	}, -- 81
	{ -- 82
		200, -- 82
		200, -- 82
		Vec2(-100, 1600), -- 82
		0 -- 82
	}, -- 82
	{ -- 83
		200, -- 83
		200, -- 83
		Vec2(-300, 2000), -- 83
		2 -- 83
	}, -- 83
	{ -- 84
		200, -- 84
		200, -- 84
		Vec2(-500, 2200), -- 84
		2 -- 84
	}, -- 84
	{ -- 85
		200, -- 85
		200, -- 85
		Vec2(500, 2200), -- 85
		0 -- 85
	}, -- 85
	{ -- 86
		200, -- 86
		200, -- 86
		Vec2(300, 2400), -- 86
		0 -- 86
	}, -- 86
	{ -- 87
		200, -- 87
		200, -- 87
		Vec2(500, 2600), -- 87
		1 -- 87
	}, -- 87
	{ -- 88
		200, -- 88
		200, -- 88
		Vec2(-500, 2800), -- 88
		0 -- 88
	}, -- 88
	{ -- 89
		200, -- 89
		200, -- 89
		Vec2(-300, 3000), -- 89
		0 -- 89
	}, -- 89
	{ -- 90
		200, -- 90
		400, -- 90
		Vec2(700, 3100), -- 90
		0 -- 90
	}, -- 90
	{ -- 91
		1200, -- 91
		200, -- 91
		Vec2(-200, 3600), -- 91
		2 -- 91
	} -- 91
} -- 76
local blocks2 = { -- 95
	{ -- 95
		200, -- 95
		1000, -- 95
		Vec2(-300, 0), -- 95
		2 -- 95
	}, -- 95
	{ -- 96
		200, -- 96
		200, -- 96
		Vec2(300, -200), -- 96
		1 -- 96
	}, -- 96
	{ -- 97
		200, -- 97
		1000, -- 97
		Vec2(300, 800), -- 97
		2 -- 97
	}, -- 97
	{ -- 98
		200, -- 98
		200, -- 98
		Vec2(300, 1400), -- 98
		1 -- 98
	}, -- 98
	{ -- 99
		200, -- 99
		1600, -- 99
		Vec2(-300, 1500), -- 99
		2 -- 99
	}, -- 99
	{ -- 100
		200, -- 100
		200, -- 100
		Vec2(-500, 2400), -- 100
		1 -- 100
	}, -- 100
	{ -- 101
		200, -- 101
		1200, -- 101
		Vec2(500, 2500), -- 101
		0 -- 101
	}, -- 101
	{ -- 102
		200, -- 102
		200, -- 102
		Vec2(-700, 3000), -- 102
		2 -- 102
	}, -- 102
	{ -- 103
		200, -- 103
		200, -- 103
		Vec2(-500, 3200), -- 103
		2 -- 103
	}, -- 103
	{ -- 104
		200, -- 104
		200, -- 104
		Vec2(-300, 3400), -- 104
		2 -- 104
	}, -- 104
	{ -- 105
		800, -- 105
		200, -- 105
		Vec2(400, 4000), -- 105
		0 -- 105
	} -- 105
} -- 94
local blocks3 = { -- 109
	{ -- 109
		200, -- 109
		4000, -- 109
		Vec2(-700, 1900), -- 109
		2 -- 109
	}, -- 109
	{ -- 110
		200, -- 110
		200, -- 110
		Vec2(-100, 400), -- 110
		2 -- 110
	}, -- 110
	{ -- 111
		200, -- 111
		200, -- 111
		Vec2(100, 600), -- 111
		1 -- 111
	}, -- 111
	{ -- 112
		200, -- 112
		200, -- 112
		Vec2(300, 1200), -- 112
		1 -- 112
	}, -- 112
	{ -- 113
		200, -- 113
		200, -- 113
		Vec2(100, 1400), -- 113
		1 -- 113
	}, -- 113
	{ -- 114
		200, -- 114
		200, -- 114
		Vec2(300, 1800), -- 114
		1 -- 114
	}, -- 114
	{ -- 115
		400, -- 115
		200, -- 115
		Vec2(600, 2000), -- 115
		0 -- 115
	}, -- 115
	{ -- 116
		200, -- 116
		200, -- 116
		Vec2(100, 3000), -- 116
		1 -- 116
	}, -- 116
	{ -- 117
		200, -- 117
		200, -- 117
		Vec2(300, 3200), -- 117
		1 -- 117
	}, -- 117
	{ -- 118
		200, -- 118
		200, -- 118
		Vec2(300, 3400), -- 118
		2 -- 118
	}, -- 118
	{ -- 119
		200, -- 119
		200, -- 119
		Vec2(100, 3600), -- 119
		1 -- 119
	}, -- 119
	{ -- 120
		200, -- 120
		200, -- 120
		Vec2(-100, 3800), -- 120
		1 -- 120
	}, -- 120
	{ -- 121
		400, -- 121
		200, -- 121
		Vec2(0, 4000), -- 121
		0 -- 121
	} -- 121
} -- 108
local blocks4 = { -- 125
	{ -- 125
		200, -- 125
		200, -- 125
		Vec2(-300, 0), -- 125
		1 -- 125
	}, -- 125
	{ -- 126
		200, -- 126
		200, -- 126
		Vec2(300, 0), -- 126
		1 -- 126
	}, -- 126
	{ -- 127
		200, -- 127
		200, -- 127
		Vec2(-500, 600), -- 127
		1 -- 127
	}, -- 127
	{ -- 128
		200, -- 128
		200, -- 128
		Vec2(100, 600), -- 128
		1 -- 128
	}, -- 128
	{ -- 129
		200, -- 129
		200, -- 129
		Vec2(700, 600), -- 129
		1 -- 129
	}, -- 129
	{ -- 130
		600, -- 130
		200, -- 130
		Vec2(0, 1200), -- 130
		0 -- 130
	}, -- 130
	{ -- 131
		200, -- 131
		600, -- 131
		Vec2(700, 1400), -- 131
		2 -- 131
	}, -- 131
	{ -- 132
		200, -- 132
		1000, -- 132
		Vec2(-700, 1800), -- 132
		2 -- 132
	}, -- 132
	{ -- 133
		200, -- 133
		600, -- 133
		Vec2(-100, 2200), -- 133
		2 -- 133
	}, -- 133
	{ -- 134
		200, -- 134
		600, -- 134
		Vec2(500, 2400), -- 134
		1 -- 134
	}, -- 134
	{ -- 135
		200, -- 135
		200, -- 135
		Vec2(100, 2800), -- 135
		2 -- 135
	}, -- 135
	{ -- 136
		200, -- 136
		200, -- 136
		Vec2(300, 3000), -- 136
		2 -- 136
	}, -- 136
	{ -- 137
		200, -- 137
		200, -- 137
		Vec2(-300, 3400), -- 137
		2 -- 137
	}, -- 137
	{ -- 138
		200, -- 138
		1200, -- 138
		Vec2(500, 3700), -- 138
		2 -- 138
	}, -- 138
	{ -- 139
		200, -- 139
		800, -- 139
		Vec2(-500, 3900), -- 139
		2 -- 139
	} -- 139
} -- 124
local blockTypes = { -- 143
	blocks1, -- 143
	blocks2, -- 144
	blocks3, -- 145
	blocks4 -- 146
} -- 142
local blockBodies = { } -- 148
local ropeNode -- 150
do -- 150
	local _with_0 = DrawNode() -- 150
	_with_0:addTo(root) -- 151
	ropeNode = _with_0 -- 150
end -- 150
local isGrabbing = false -- 152
local isGrabbed = false -- 153
local grabBlock = Node() -- 154
local emitRope -- 156
emitRope = function(cubeBody, endPoint) -- 156
	local startPoint = cubeBody.position -- 157
	local isBlock = false -- 158
	local isSelf = true -- 159
	local grabPoint = endPoint -- 160
	Audio:play("sfx/slime_touch.wav") -- 161
	world:raycast(startPoint, endPoint, false, function(_body, point) -- 162
		if isBlock then -- 163
			isGrabbed = true -- 164
			grabPoint = point -- 165
			isBlock = false -- 166
		end -- 163
		if isSelf then -- 167
			isSelf = false -- 168
			isBlock = true -- 169
		end -- 167
	end) -- 162
	ropeNode:schedule(function() -- 171
		ropeNode:clear() -- 172
		if not hardMode or isGrabbed then -- 173
			return ropeNode:drawSegment(cubeBody.position, grabPoint, 10, Color(0xaaffffff)) -- 180
		end -- 173
	end) -- 171
	return ropeNode -- 170
end -- 156
local getGrabForce -- 182
getGrabForce = function(body, target) -- 182
	local prePos = body.position -- 183
	local force = target - prePos -- 184
	force = force:normalize() * 30 -- 185
	return force -- 186
end -- 182
local camera = Camera2D() -- 188
Director:pushCamera(camera) -- 189
updateViewScale() -- 190
local cameraFollow -- 192
cameraFollow = function(body) -- 192
	local _with_0 = Node() -- 193
	_with_0:schedule(function() -- 194
		camera.position = Vec2(0, (body.position.y - camera.position.y) * 0.1 + camera.position.y + 30) -- 195
	end) -- 194
	return _with_0 -- 193
end -- 192
local _anon_func_0 = function(Sprite, _with_0, scale) -- 208
	local _with_1 = Sprite("Image/cube.png") -- 207
	_with_1.scaleX = scale -- 208
	_with_1.scaleY = scale -- 208
	return _with_1 -- 207
end -- 207
local addCube -- 197
addCube = function() -- 197
	do -- 198
		local _with_0 = Node() -- 198
		_with_0:addTo(world) -- 199
		cube = _with_0 -- 198
	end -- 198
	local scale = 0.5 -- 200
	local cubebody -- 201
	do -- 201
		local _with_0 = Body(getCubeDef(256 * scale, 256 * scale), world, cubeInitPos) -- 201
		_with_0.receivingContact = true -- 202
		_with_0.tag = "cubeBody" -- 203
		_with_0.group = 0 -- 204
		_with_0.angularRate = 0 -- 205
		_with_0.velocity = Vec2.zero -- 206
		_with_0:addChild(_anon_func_0(Sprite, _with_0, scale)) -- 207
		_with_0:addTo(cube) -- 209
		cubebody = _with_0 -- 201
	end -- 201
	return cameraFollow(cubebody) -- 210
end -- 197
local _anon_func_1 = function(Sprite, View, _with_0) -- 217
	local _with_1 = Sprite("Image/heart_3.png") -- 214
	_with_1.tag = "heartSprite" -- 215
	_with_1.y = View.size.height / 2 - 100 -- 216
	_with_1.scaleX = 6 -- 217
	_with_1.scaleY = 6 -- 217
	return _with_1 -- 214
end -- 214
local addHeartUI -- 212
addHeartUI = function() -- 212
	do -- 213
		local _with_0 = Node() -- 213
		_with_0:addChild(_anon_func_1(Sprite, View, _with_0)) -- 214
		heartNode = _with_0 -- 213
	end -- 213
	return ui:addChild(heartNode) -- 218
end -- 212
local _anon_func_2 = function(View, heartSprite) -- 230
	heartSprite.tag = "heartSprite" -- 228
	heartSprite.y = View.size.height / 2 - 100 -- 229
	heartSprite.scaleX = 6 -- 230
	heartSprite.scaleY = 6 -- 230
	return heartSprite -- 227
end -- 227
local loseHeart -- 220
loseHeart = function() -- 220
	heart = heart - 1 -- 221
	heartNode:removeAllChildren() -- 222
	local heartSprite -- 223
	if 0 <= heart and heart <= 3 then -- 223
		heartSprite = Sprite("Image/heart_" .. tostring(math.tointeger(heart)) .. ".png") -- 224
	else -- 226
		heartSprite = Sprite("Image/heart_0.png") -- 226
	end -- 223
	return heartNode:addChild(_anon_func_2(View, heartSprite)) -- 230
end -- 220
local arriveDest -- 232
arriveDest = function() -- 232
	touchTheSky = true -- 233
	Audio:play("sfx/sky3.mp3") -- 234
	Audio:playStream("sfx/victory.ogg", true, 0.2) -- 235
	local body = cube:getChildByTag("cubeBody") -- 236
	body:applyLinearImpulse(Vec2(0, 1500), body.position) -- 237
	local _with_0 = Node() -- 238
	_with_0:addChild((function() -- 239
		local _with_1 = Sprite("Image/restart.png") -- 239
		_with_1.scaleX = 2 -- 240
		_with_1.scaleY = 2 -- 240
		_with_1.touchEnabled = true -- 241
		_with_1:slot("TapBegan", function() -- 242
			restartButton:removeFromParent() -- 243
			return restartGame() -- 244
		end) -- 242
		return _with_1 -- 239
	end)()) -- 239
	_with_0:addTo(ui) -- 245
	restartButton = _with_0 -- 238
end -- 232
local _anon_func_3 = function(Sprite, _with_0) -- 283
	local _with_1 = Sprite("Image/red.png") -- 282
	_with_1.scaleX = 0.15 -- 283
	_with_1.scaleY = 0.15 -- 283
	return _with_1 -- 282
end -- 282
local _anon_func_4 = function(Sprite, _with_0) -- 287
	local _with_1 = Sprite("Image/spring.png") -- 286
	_with_1.scaleX = 0.15 -- 287
	_with_1.scaleY = 0.15 -- 287
	return _with_1 -- 286
end -- 286
local _anon_func_5 = function(DrawNode, Vec2, _with_0, blockColor, height, width) -- 304
	local _with_1 = DrawNode() -- 297
	local verts = { -- 299
		Vec2(-width / 2, height / 2), -- 299
		Vec2(width / 2, height / 2), -- 300
		Vec2(width / 2, -height / 2), -- 301
		Vec2(-width / 2, -height / 2) -- 302
	} -- 298
	_with_1:drawPolygon(verts, blockColor) -- 304
	return _with_1 -- 297
end -- 297
local buildBlocks -- 247
buildBlocks = function(index) -- 247
	local blocks = blockTypes[index] -- 248
	for _index_0 = 1, #blocks do -- 249
		local block = blocks[_index_0] -- 249
		local width, height, pos, blockType = block[1], block[2], block[3], block[4] -- 250
		pos = pos + Vec2(0, blockLevel[index]) -- 251
		local _with_0 = Body(getBlockDef(width, height), world, pos) -- 252
		_with_0.group = 1 -- 253
		local blockColor = Color(0xffffffff) -- 254
		_with_0:attachSensor(1, BodyDef:polygon(width + 15, height + 15)) -- 255
		if 0 == blockType then -- 256
			_with_0:slot("BodyEnter", function() -- 257
				return Audio:play("sfx/strike.wav") -- 258
			end) -- 257
			blockColor = colorWhite -- 259
		elseif 1 == blockType then -- 260
			_with_0:slot("BodyEnter", function(body) -- 261
				if not isInvincible then -- 262
					loseHeart() -- 263
					body:applyLinearImpulse(Vec2(math.random(-1000, 1000), math.random(-1000, -500)), body.position) -- 264
					Audio:play("sfx/explode2.wav") -- 266
				end -- 262
				_with_0:schedule(once(function() -- 267
					isInvincible = true -- 268
					sleep(1) -- 269
					isInvincible = false -- 270
				end)) -- 267
				if heart <= 0 then -- 271
					isGrabbing = false -- 272
					isGrabbed = false -- 273
					grabBlock:unschedule() -- 274
					ropeNode:clear() -- 275
					ropeNode:unschedule() -- 276
					Audio:play("sfx/game_over.wav") -- 277
					return _with_0:schedule(once(function() -- 278
						sleep(0.5) -- 279
						return restartGame() -- 280
					end)) -- 280
				end -- 271
			end) -- 261
			blockColor = colorRed -- 281
			_with_0:addChild(_anon_func_3(Sprite, _with_0)) -- 282
		elseif 2 == blockType then -- 284
			blockColor = colorBlue -- 285
			_with_0:addChild(_anon_func_4(Sprite, _with_0)) -- 286
			local implulseAvailable = true -- 288
			_with_0:slot("BodyEnter", function(body) -- 289
				if not implulseAvailable then -- 290
					return -- 290
				end -- 290
				Audio:play("sfx/rebound.wav") -- 291
				body:applyLinearImpulse(Vec2(0, springForce), body.position) -- 292
				implulseAvailable = false -- 293
				return _with_0:schedule(once(function() -- 294
					sleep(0.2) -- 295
					implulseAvailable = true -- 296
				end)) -- 296
			end) -- 289
		end -- 296
		_with_0:addChild(_anon_func_5(DrawNode, Vec2, _with_0, blockColor, height, width)) -- 297
		_with_0:addTo(world) -- 305
		blockBodies[#blockBodies + 1] = _with_0 -- 252
	end -- 305
end -- 247
local _anon_func_6 = function(Sprite, _with_0) -- 317
	local _with_1 = Sprite("Image/sky.png") -- 314
	_with_1.x = 90 -- 315
	_with_1.y = 100 -- 316
	_with_1.scaleX = 2.7 -- 317
	_with_1.scaleY = 2.7 -- 317
	return _with_1 -- 314
end -- 314
local _anon_func_7 = function(DrawNode, Vec2, _with_0, borderHeight, borderWidth, colorWhite) -- 326
	local _with_1 = DrawNode() -- 323
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(borderWidth / 2, 0), 10, colorWhite) -- 324
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(-borderWidth / 2, borderHeight), 10, colorWhite) -- 325
	_with_1:drawSegment(Vec2(borderWidth / 2, 0), Vec2(borderWidth / 2, borderHeight), 10, colorWhite) -- 326
	return _with_1 -- 323
end -- 323
local buildWorld -- 307
buildWorld = function() -- 307
	buildBlocks(1) -- 308
	buildBlocks(2) -- 309
	buildBlocks(3) -- 310
	buildBlocks(4) -- 311
	do -- 312
		local _with_0 = Body(destinationDef, world, Vec2(borderPos.x, borderPos.y + borderHeight)) -- 312
		_with_0.group = 1 -- 313
		_with_0:addChild(_anon_func_6(Sprite, _with_0)) -- 314
		_with_0:slot("BodyEnter", function() -- 318
			if not touchTheSky then -- 319
				return arriveDest() -- 319
			end -- 319
		end) -- 318
		_with_0:addTo(world) -- 320
	end -- 312
	do -- 321
		local _with_0 = Body(borderDef, world, Vec2.zero) -- 321
		_with_0.group = 1 -- 322
		_with_0:addChild(_anon_func_7(DrawNode, Vec2, _with_0, borderHeight, borderWidth, colorWhite)) -- 323
		_with_0:addTo(world) -- 327
	end -- 321
	local _with_0 = Node() -- 328
	_with_0.touchEnabled = true -- 329
	_with_0:slot("TapBegan", function(touch) -- 330
		isGrabbing = true -- 331
		if not touch.first then -- 332
			return -- 332
		end -- 332
		local location = touch.location -- 333
		local body = cube:getChildByTag("cubeBody") -- 334
		emitRope(body, location) -- 335
		if not hardMode or isGrabbed then -- 336
			grabBlock:schedule(function() -- 338
				return body:applyLinearImpulse(getGrabForce(body, location), body.position) -- 339
			end) -- 338
			return grabBlock -- 337
		end -- 336
	end) -- 330
	_with_0:slot("TapEnded", function() -- 340
		isGrabbing = false -- 341
		isGrabbed = false -- 342
		grabBlock:unschedule() -- 343
		ropeNode:clear() -- 344
		return ropeNode:unschedule() -- 345
	end) -- 340
	_with_0:addTo(root) -- 346
	return _with_0 -- 328
end -- 307
addCube() -- 348
buildWorld() -- 349
addHeartUI() -- 350
restartGame = function() -- 352
	if touchTheSky then -- 353
		Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 354
	end -- 353
	heart = 3 -- 355
	touchTheSky = false -- 356
	local body = cube:getChildByTag("cubeBody") -- 357
	body.position = Vec2.zero -- 358
	body.angularRate = 0 -- 359
	ui:removeFromParent() -- 360
	do -- 361
		local _with_0 = Node() -- 361
		_with_0:addTo(Director.ui) -- 362
		heartNode:removeFromParent() -- 363
		ui = _with_0 -- 361
	end -- 361
	return addHeartUI() -- 364
end -- 352
local windowFlags = { -- 367
	"NoDecoration", -- 367
	"NoSavedSettings", -- 368
	"NoFocusOnAppearing", -- 369
	"NoNav", -- 370
	"NoMove" -- 371
} -- 366
return threadLoop(function() -- 372
	local width, height -- 373
	do -- 373
		local _obj_0 = App.visualSize -- 373
		width, height = _obj_0.width, _obj_0.height -- 373
	end -- 373
	SetNextWindowBgAlpha(0.35) -- 374
	SetNextWindowPos(Vec2(width - 140, height - 170), "Always", Vec2.zero) -- 375
	SetNextWindowSize(Vec2(140, 0), "Always") -- 376
	return Begin("Touch The Sky", windowFlags, function() -- 377
		Text("Touch The Sky") -- 378
		Separator() -- 379
		TextWrapped("Click to grab!") -- 380
		local changed, isHardMode = Checkbox("Hard Mode", hardMode) -- 381
		if changed then -- 381
			hardMode = isHardMode -- 382
		end -- 381
	end) -- 382
end) -- 382
