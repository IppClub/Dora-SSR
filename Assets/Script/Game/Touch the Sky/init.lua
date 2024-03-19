-- [yue]: Script/Game/Touch the Sky/init.yue
local Path = dora.Path -- 1
local Content = dora.Content -- 1
local Vec2 = dora.Vec2 -- 1
local Director = dora.Director -- 1
local View = dora.View -- 1
local Node = dora.Node -- 1
local Audio = dora.Audio -- 1
local PhysicsWorld = dora.PhysicsWorld -- 1
local BodyDef = dora.BodyDef -- 1
local Color = dora.Color -- 1
local DrawNode = dora.DrawNode -- 1
local Camera2D = dora.Camera2D -- 1
local Body = dora.Body -- 1
local Sprite = dora.Sprite -- 1
local tostring = _G.tostring -- 1
local math = _G.math -- 1
local once = dora.once -- 1
local sleep = dora.sleep -- 1
local threadLoop = dora.threadLoop -- 1
local App = dora.App -- 1
local _module_0 = dora.ImGui -- 1
local SetNextWindowBgAlpha = _module_0.SetNextWindowBgAlpha -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local Text = _module_0.Text -- 1
local Separator = _module_0.Separator -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local Checkbox = _module_0.Checkbox -- 1
local scriptPath = Path:getScriptPath(...) -- 4
Content:insertSearchPath(1, scriptPath) -- 5
local gravity <const> = Vec2(0, -10) -- 7
local updateViewScale -- 9
updateViewScale = function() -- 9
	Director.currentCamera.zoom = View.size.width / 1620 -- 10
end -- 9
local root -- 11
do -- 11
	local _with_0 = Node() -- 11
	_with_0:gslot("AppSizeChanged", updateViewScale) -- 12
	root = _with_0 -- 11
end -- 11
local ui -- 14
do -- 14
	local _with_0 = Node() -- 14
	_with_0:addTo(Director.ui) -- 15
	ui = _with_0 -- 14
end -- 14
local heartNode = nil -- 16
local restartButton = nil -- 17
Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 18
local world -- 20
do -- 20
	local _with_0 = PhysicsWorld() -- 20
	_with_0:setShouldContact(0, 1, true) -- 21
	_with_0.showDebug = false -- 22
	_with_0:addTo(root) -- 23
	world = _with_0 -- 20
end -- 20
local restartGame = nil -- 25
local cube = nil -- 26
local touchTheSky = false -- 27
local isInvincible = false -- 28
local hardMode = false -- 29
local getCubeDef -- 31
getCubeDef = function(width, height) -- 31
	local _with_0 = BodyDef() -- 31
	_with_0.type = "Dynamic" -- 32
	_with_0.linearAcceleration = gravity -- 33
	_with_0.angularDamping = 1.8 -- 34
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 36
	return _with_0 -- 31
end -- 31
local getBlockDef -- 38
getBlockDef = function(width, height) -- 38
	local _with_0 = BodyDef() -- 38
	_with_0.type = "Static" -- 39
	_with_0.linearAcceleration = gravity -- 40
	_with_0:attachPolygon(width, height, 0.4, 0.4, 0.4) -- 41
	return _with_0 -- 38
end -- 38
local colorWhite = Color(0xccffffff) -- 43
local colorRed = Color(0xaae65100) -- 44
local colorBlue = Color(0xaa00b0ff) -- 45
local borderHeight = 19000 -- 47
local borderWidth = 1600 -- 48
local borderPos = Vec2(0, 0) -- 49
local springForce = 1000 -- 51
local heart = 3 -- 52
local cubeInitPos = Vec2(0, 100) -- 53
local borderDef -- 55
do -- 55
	local _with_0 = BodyDef() -- 55
	_with_0.type = "Static" -- 56
	_with_0:attachPolygon(borderPos, borderWidth, 10, 0, 1, 1, 0) -- 57
	_with_0:attachPolygon(Vec2(borderPos.x + borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 58
	_with_0:attachPolygon(Vec2(borderPos.x - borderWidth / 2, borderPos.y + borderHeight / 2), 10, borderHeight, 0, 1, 1, 0) -- 59
	borderDef = _with_0 -- 55
end -- 55
local destinationDef -- 61
do -- 61
	local _with_0 = BodyDef() -- 61
	_with_0:attachPolygonSensor(1, borderWidth, 10) -- 62
	destinationDef = _with_0 -- 61
end -- 61
local blockLevel = { -- 64
	300, -- 64
	5200, -- 64
	9800, -- 64
	14400 -- 64
} -- 64
local blocks1 = { -- 67
	{ -- 67
		200, -- 67
		200, -- 67
		Vec2(-700, 0), -- 67
		2 -- 67
	}, -- 67
	{ -- 68
		1000, -- 68
		200, -- 68
		Vec2(300, 400), -- 68
		0 -- 68
	}, -- 68
	{ -- 69
		200, -- 69
		200, -- 69
		Vec2(500, 800), -- 69
		1 -- 69
	}, -- 69
	{ -- 70
		600, -- 70
		200, -- 70
		Vec2(-500, 1000), -- 70
		2 -- 70
	}, -- 70
	{ -- 71
		200, -- 71
		200, -- 71
		Vec2(-300, 1400), -- 71
		0 -- 71
	}, -- 71
	{ -- 72
		200, -- 72
		200, -- 72
		Vec2(-100, 1600), -- 72
		0 -- 72
	}, -- 72
	{ -- 73
		200, -- 73
		200, -- 73
		Vec2(-300, 2000), -- 73
		2 -- 73
	}, -- 73
	{ -- 74
		200, -- 74
		200, -- 74
		Vec2(-500, 2200), -- 74
		2 -- 74
	}, -- 74
	{ -- 75
		200, -- 75
		200, -- 75
		Vec2(500, 2200), -- 75
		0 -- 75
	}, -- 75
	{ -- 76
		200, -- 76
		200, -- 76
		Vec2(300, 2400), -- 76
		0 -- 76
	}, -- 76
	{ -- 77
		200, -- 77
		200, -- 77
		Vec2(500, 2600), -- 77
		1 -- 77
	}, -- 77
	{ -- 78
		200, -- 78
		200, -- 78
		Vec2(-500, 2800), -- 78
		0 -- 78
	}, -- 78
	{ -- 79
		200, -- 79
		200, -- 79
		Vec2(-300, 3000), -- 79
		0 -- 79
	}, -- 79
	{ -- 80
		200, -- 80
		400, -- 80
		Vec2(700, 3100), -- 80
		0 -- 80
	}, -- 80
	{ -- 81
		1200, -- 81
		200, -- 81
		Vec2(-200, 3600), -- 81
		2 -- 81
	} -- 81
} -- 66
local blocks2 = { -- 85
	{ -- 85
		200, -- 85
		1000, -- 85
		Vec2(-300, 0), -- 85
		2 -- 85
	}, -- 85
	{ -- 86
		200, -- 86
		200, -- 86
		Vec2(300, -200), -- 86
		1 -- 86
	}, -- 86
	{ -- 87
		200, -- 87
		1000, -- 87
		Vec2(300, 800), -- 87
		2 -- 87
	}, -- 87
	{ -- 88
		200, -- 88
		200, -- 88
		Vec2(300, 1400), -- 88
		1 -- 88
	}, -- 88
	{ -- 89
		200, -- 89
		1600, -- 89
		Vec2(-300, 1500), -- 89
		2 -- 89
	}, -- 89
	{ -- 90
		200, -- 90
		200, -- 90
		Vec2(-500, 2400), -- 90
		1 -- 90
	}, -- 90
	{ -- 91
		200, -- 91
		1200, -- 91
		Vec2(500, 2500), -- 91
		0 -- 91
	}, -- 91
	{ -- 92
		200, -- 92
		200, -- 92
		Vec2(-700, 3000), -- 92
		2 -- 92
	}, -- 92
	{ -- 93
		200, -- 93
		200, -- 93
		Vec2(-500, 3200), -- 93
		2 -- 93
	}, -- 93
	{ -- 94
		200, -- 94
		200, -- 94
		Vec2(-300, 3400), -- 94
		2 -- 94
	}, -- 94
	{ -- 95
		800, -- 95
		200, -- 95
		Vec2(400, 4000), -- 95
		0 -- 95
	} -- 95
} -- 84
local blocks3 = { -- 99
	{ -- 99
		200, -- 99
		4000, -- 99
		Vec2(-700, 1900), -- 99
		2 -- 99
	}, -- 99
	{ -- 100
		200, -- 100
		200, -- 100
		Vec2(-100, 400), -- 100
		2 -- 100
	}, -- 100
	{ -- 101
		200, -- 101
		200, -- 101
		Vec2(100, 600), -- 101
		1 -- 101
	}, -- 101
	{ -- 102
		200, -- 102
		200, -- 102
		Vec2(300, 1200), -- 102
		1 -- 102
	}, -- 102
	{ -- 103
		200, -- 103
		200, -- 103
		Vec2(100, 1400), -- 103
		1 -- 103
	}, -- 103
	{ -- 104
		200, -- 104
		200, -- 104
		Vec2(300, 1800), -- 104
		1 -- 104
	}, -- 104
	{ -- 105
		400, -- 105
		200, -- 105
		Vec2(600, 2000), -- 105
		0 -- 105
	}, -- 105
	{ -- 106
		200, -- 106
		200, -- 106
		Vec2(100, 3000), -- 106
		1 -- 106
	}, -- 106
	{ -- 107
		200, -- 107
		200, -- 107
		Vec2(300, 3200), -- 107
		1 -- 107
	}, -- 107
	{ -- 108
		200, -- 108
		200, -- 108
		Vec2(300, 3400), -- 108
		2 -- 108
	}, -- 108
	{ -- 109
		200, -- 109
		200, -- 109
		Vec2(100, 3600), -- 109
		1 -- 109
	}, -- 109
	{ -- 110
		200, -- 110
		200, -- 110
		Vec2(-100, 3800), -- 110
		1 -- 110
	}, -- 110
	{ -- 111
		400, -- 111
		200, -- 111
		Vec2(0, 4000), -- 111
		0 -- 111
	} -- 111
} -- 98
local blocks4 = { -- 115
	{ -- 115
		200, -- 115
		200, -- 115
		Vec2(-300, 0), -- 115
		1 -- 115
	}, -- 115
	{ -- 116
		200, -- 116
		200, -- 116
		Vec2(300, 0), -- 116
		1 -- 116
	}, -- 116
	{ -- 117
		200, -- 117
		200, -- 117
		Vec2(-500, 600), -- 117
		1 -- 117
	}, -- 117
	{ -- 118
		200, -- 118
		200, -- 118
		Vec2(100, 600), -- 118
		1 -- 118
	}, -- 118
	{ -- 119
		200, -- 119
		200, -- 119
		Vec2(700, 600), -- 119
		1 -- 119
	}, -- 119
	{ -- 120
		600, -- 120
		200, -- 120
		Vec2(0, 1200), -- 120
		0 -- 120
	}, -- 120
	{ -- 121
		200, -- 121
		600, -- 121
		Vec2(700, 1400), -- 121
		2 -- 121
	}, -- 121
	{ -- 122
		200, -- 122
		1000, -- 122
		Vec2(-700, 1800), -- 122
		2 -- 122
	}, -- 122
	{ -- 123
		200, -- 123
		600, -- 123
		Vec2(-100, 2200), -- 123
		2 -- 123
	}, -- 123
	{ -- 124
		200, -- 124
		600, -- 124
		Vec2(500, 2400), -- 124
		1 -- 124
	}, -- 124
	{ -- 125
		200, -- 125
		200, -- 125
		Vec2(100, 2800), -- 125
		2 -- 125
	}, -- 125
	{ -- 126
		200, -- 126
		200, -- 126
		Vec2(300, 3000), -- 126
		2 -- 126
	}, -- 126
	{ -- 127
		200, -- 127
		200, -- 127
		Vec2(-300, 3400), -- 127
		2 -- 127
	}, -- 127
	{ -- 128
		200, -- 128
		1200, -- 128
		Vec2(500, 3700), -- 128
		2 -- 128
	}, -- 128
	{ -- 129
		200, -- 129
		800, -- 129
		Vec2(-500, 3900), -- 129
		2 -- 129
	} -- 129
} -- 114
local blockTypes = { -- 133
	blocks1, -- 133
	blocks2, -- 134
	blocks3, -- 135
	blocks4 -- 136
} -- 132
local blockBodies = { } -- 138
local ropeNode -- 140
do -- 140
	local _with_0 = DrawNode() -- 140
	_with_0:addTo(root) -- 141
	ropeNode = _with_0 -- 140
end -- 140
local isGrabbing = false -- 142
local isGrabbed = false -- 143
local grabBlock = Node() -- 144
local emitRope -- 146
emitRope = function(cubeBody, endPoint) -- 146
	local startPoint = cubeBody.position -- 147
	local isBlock = false -- 148
	local isSelf = true -- 149
	local grabPoint = endPoint -- 150
	Audio:play("sfx/slime_touch.wav") -- 151
	world:raycast(startPoint, endPoint, false, function(_body, point) -- 152
		if isBlock then -- 153
			isGrabbed = true -- 154
			grabPoint = point -- 155
			isBlock = false -- 156
		end -- 153
		if isSelf then -- 157
			isSelf = false -- 158
			isBlock = true -- 159
		end -- 157
	end) -- 152
	ropeNode:schedule(function() -- 161
		ropeNode:clear() -- 162
		if not hardMode or isGrabbed then -- 163
			return ropeNode:drawSegment(cubeBody.position, grabPoint, 10, Color(0xaaffffff)) -- 170
		end -- 163
	end) -- 161
	return ropeNode -- 160
end -- 146
local getGrabForce -- 172
getGrabForce = function(body, target) -- 172
	local prePos = body.position -- 173
	local force = target - prePos -- 174
	force = force:normalize() * 30 -- 175
	return force -- 176
end -- 172
local camera = Camera2D() -- 178
Director:pushCamera(camera) -- 179
updateViewScale() -- 180
local cameraFollow -- 182
cameraFollow = function(body) -- 182
	local _with_0 = Node() -- 183
	_with_0:schedule(function() -- 184
		camera.position = Vec2(0, (body.position.y - camera.position.y) * 0.1 + camera.position.y + 30) -- 185
	end) -- 184
	return _with_0 -- 183
end -- 182
local _anon_func_0 = function(Sprite, _with_0, scale) -- 198
	local _with_1 = Sprite("Image/cube.png") -- 197
	_with_1.scaleX = scale -- 198
	_with_1.scaleY = scale -- 198
	return _with_1 -- 197
end -- 197
local addCube -- 187
addCube = function() -- 187
	do -- 188
		local _with_0 = Node() -- 188
		_with_0:addTo(world) -- 189
		cube = _with_0 -- 188
	end -- 188
	local scale = 0.5 -- 190
	local cubebody -- 191
	do -- 191
		local _with_0 = Body(getCubeDef(256 * scale, 256 * scale), world, cubeInitPos) -- 191
		_with_0.receivingContact = true -- 192
		_with_0.tag = "cubeBody" -- 193
		_with_0.group = 0 -- 194
		_with_0.angularRate = 0 -- 195
		_with_0.velocity = Vec2.zero -- 196
		_with_0:addChild(_anon_func_0(Sprite, _with_0, scale)) -- 197
		_with_0:addTo(cube) -- 199
		cubebody = _with_0 -- 191
	end -- 191
	return cameraFollow(cubebody) -- 200
end -- 187
local _anon_func_1 = function(Sprite, View, _with_0) -- 207
	local _with_1 = Sprite("Image/heart_3.png") -- 204
	_with_1.tag = "heartSprite" -- 205
	_with_1.y = View.size.height / 2 - 100 -- 206
	_with_1.scaleX = 6 -- 207
	_with_1.scaleY = 6 -- 207
	return _with_1 -- 204
end -- 204
local addHeartUI -- 202
addHeartUI = function() -- 202
	do -- 203
		local _with_0 = Node() -- 203
		_with_0:addChild(_anon_func_1(Sprite, View, _with_0)) -- 204
		heartNode = _with_0 -- 203
	end -- 203
	return ui:addChild(heartNode) -- 208
end -- 202
local _anon_func_2 = function(View, heartSprite) -- 220
	heartSprite.tag = "heartSprite" -- 218
	heartSprite.y = View.size.height / 2 - 100 -- 219
	heartSprite.scaleX = 6 -- 220
	heartSprite.scaleY = 6 -- 220
	return heartSprite -- 217
end -- 217
local loseHeart -- 210
loseHeart = function() -- 210
	heart = heart - 1 -- 211
	heartNode:removeAllChildren() -- 212
	local heartSprite -- 213
	if 0 <= heart and heart <= 3 then -- 213
		heartSprite = Sprite("Image/heart_" .. tostring(math.tointeger(heart)) .. ".png") -- 214
	else -- 216
		heartSprite = Sprite("Image/heart_0.png") -- 216
	end -- 213
	return heartNode:addChild(_anon_func_2(View, heartSprite)) -- 220
end -- 210
local arriveDest -- 222
arriveDest = function() -- 222
	touchTheSky = true -- 223
	Audio:play("sfx/sky3.mp3") -- 224
	Audio:playStream("sfx/victory.ogg", true, 0.2) -- 225
	local body = cube:getChildByTag("cubeBody") -- 226
	body:applyLinearImpulse(Vec2(0, 1500), body.position) -- 227
	do -- 228
		local _with_0 = Node() -- 228
		_with_0:addChild((function() -- 229
			local _with_1 = Sprite("Image/restart.png") -- 229
			_with_1.scaleX = 2 -- 230
			_with_1.scaleY = 2 -- 230
			_with_1.touchEnabled = true -- 231
			_with_1:slot("TapBegan", function() -- 232
				restartButton:removeFromParent() -- 233
				return restartGame() -- 234
			end) -- 232
			return _with_1 -- 229
		end)()) -- 229
		_with_0:addTo(ui) -- 235
		restartButton = _with_0 -- 228
	end -- 228
end -- 222
local _anon_func_3 = function(Sprite, _with_0) -- 273
	local _with_1 = Sprite("Image/red.png") -- 272
	_with_1.scaleX = 0.15 -- 273
	_with_1.scaleY = 0.15 -- 273
	return _with_1 -- 272
end -- 272
local _anon_func_4 = function(Sprite, _with_0) -- 277
	local _with_1 = Sprite("Image/spring.png") -- 276
	_with_1.scaleX = 0.15 -- 277
	_with_1.scaleY = 0.15 -- 277
	return _with_1 -- 276
end -- 276
local _anon_func_5 = function(DrawNode, Vec2, _with_0, blockColor, height, width) -- 294
	local _with_1 = DrawNode() -- 287
	local verts = { -- 289
		Vec2(-width / 2, height / 2), -- 289
		Vec2(width / 2, height / 2), -- 290
		Vec2(width / 2, -height / 2), -- 291
		Vec2(-width / 2, -height / 2) -- 292
	} -- 288
	_with_1:drawPolygon(verts, blockColor) -- 294
	return _with_1 -- 287
end -- 287
local buildBlocks -- 237
buildBlocks = function(index) -- 237
	local blocks = blockTypes[index] -- 238
	for _index_0 = 1, #blocks do -- 239
		local block = blocks[_index_0] -- 239
		local width, height, pos, blockType = block[1], block[2], block[3], block[4] -- 240
		pos = pos + Vec2(0, blockLevel[index]) -- 241
		do -- 242
			local _with_0 = Body(getBlockDef(width, height), world, pos) -- 242
			_with_0.group = 1 -- 243
			local blockColor = Color(0xffffffff) -- 244
			_with_0:attachSensor(1, BodyDef:polygon(width + 15, height + 15)) -- 245
			if 0 == blockType then -- 246
				_with_0:slot("BodyEnter", function() -- 247
					return Audio:play("sfx/strike.wav") -- 248
				end) -- 247
				blockColor = colorWhite -- 249
			elseif 1 == blockType then -- 250
				_with_0:slot("BodyEnter", function(body) -- 251
					if not isInvincible then -- 252
						loseHeart() -- 253
						body:applyLinearImpulse(Vec2(math.random(-1000, 1000), math.random(-1000, -500)), body.position) -- 254
						Audio:play("sfx/explode2.wav") -- 256
					end -- 252
					_with_0:schedule(once(function() -- 257
						isInvincible = true -- 258
						sleep(1) -- 259
						isInvincible = false -- 260
					end)) -- 257
					if heart <= 0 then -- 261
						isGrabbing = false -- 262
						isGrabbed = false -- 263
						grabBlock:unschedule() -- 264
						ropeNode:clear() -- 265
						ropeNode:unschedule() -- 266
						Audio:play("sfx/game_over.wav") -- 267
						return _with_0:schedule(once(function() -- 268
							sleep(0.5) -- 269
							return restartGame() -- 270
						end)) -- 270
					end -- 261
				end) -- 251
				blockColor = colorRed -- 271
				_with_0:addChild(_anon_func_3(Sprite, _with_0)) -- 272
			elseif 2 == blockType then -- 274
				blockColor = colorBlue -- 275
				_with_0:addChild(_anon_func_4(Sprite, _with_0)) -- 276
				local implulseAvailable = true -- 278
				_with_0:slot("BodyEnter", function(body) -- 279
					if not implulseAvailable then -- 280
						return -- 280
					end -- 280
					Audio:play("sfx/rebound.wav") -- 281
					body:applyLinearImpulse(Vec2(0, springForce), body.position) -- 282
					implulseAvailable = false -- 283
					return _with_0:schedule(once(function() -- 284
						sleep(0.2) -- 285
						implulseAvailable = true -- 286
					end)) -- 286
				end) -- 279
			end -- 286
			_with_0:addChild(_anon_func_5(DrawNode, Vec2, _with_0, blockColor, height, width)) -- 287
			_with_0:addTo(world) -- 295
			blockBodies[#blockBodies + 1] = _with_0 -- 242
		end -- 242
	end -- 295
end -- 237
local _anon_func_6 = function(Sprite, _with_0) -- 307
	local _with_1 = Sprite("Image/sky.png") -- 304
	_with_1.x = 90 -- 305
	_with_1.y = 100 -- 306
	_with_1.scaleX = 2.7 -- 307
	_with_1.scaleY = 2.7 -- 307
	return _with_1 -- 304
end -- 304
local _anon_func_7 = function(DrawNode, Vec2, _with_0, borderHeight, borderWidth, colorWhite) -- 316
	local _with_1 = DrawNode() -- 313
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(borderWidth / 2, 0), 10, colorWhite) -- 314
	_with_1:drawSegment(Vec2(-borderWidth / 2, 0), Vec2(-borderWidth / 2, borderHeight), 10, colorWhite) -- 315
	_with_1:drawSegment(Vec2(borderWidth / 2, 0), Vec2(borderWidth / 2, borderHeight), 10, colorWhite) -- 316
	return _with_1 -- 313
end -- 313
local buildWorld -- 297
buildWorld = function() -- 297
	buildBlocks(1) -- 298
	buildBlocks(2) -- 299
	buildBlocks(3) -- 300
	buildBlocks(4) -- 301
	do -- 302
		local _with_0 = Body(destinationDef, world, Vec2(borderPos.x, borderPos.y + borderHeight)) -- 302
		_with_0.group = 1 -- 303
		_with_0:addChild(_anon_func_6(Sprite, _with_0)) -- 304
		_with_0:slot("BodyEnter", function() -- 308
			if not touchTheSky then -- 309
				return arriveDest() -- 309
			end -- 309
		end) -- 308
		_with_0:addTo(world) -- 310
	end -- 302
	do -- 311
		local _with_0 = Body(borderDef, world, Vec2.zero) -- 311
		_with_0.group = 1 -- 312
		_with_0:addChild(_anon_func_7(DrawNode, Vec2, _with_0, borderHeight, borderWidth, colorWhite)) -- 313
		_with_0:addTo(world) -- 317
	end -- 311
	local _with_0 = Node() -- 318
	_with_0.touchEnabled = true -- 319
	_with_0:slot("TapBegan", function(touch) -- 320
		isGrabbing = true -- 321
		if not touch.first then -- 322
			return -- 322
		end -- 322
		local location = touch.location -- 323
		local body = cube:getChildByTag("cubeBody") -- 324
		emitRope(body, location) -- 325
		if not hardMode or isGrabbed then -- 326
			grabBlock:schedule(function() -- 328
				return body:applyLinearImpulse(getGrabForce(body, location), body.position) -- 329
			end) -- 328
			return grabBlock -- 327
		end -- 326
	end) -- 320
	_with_0:slot("TapEnded", function() -- 330
		isGrabbing = false -- 331
		isGrabbed = false -- 332
		grabBlock:unschedule() -- 333
		ropeNode:clear() -- 334
		return ropeNode:unschedule() -- 335
	end) -- 330
	_with_0:addTo(root) -- 336
	return _with_0 -- 318
end -- 297
addCube() -- 338
buildWorld() -- 339
addHeartUI() -- 340
restartGame = function() -- 342
	if touchTheSky then -- 343
		Audio:playStream("sfx/bgm.ogg", true, 0.2) -- 344
	end -- 343
	heart = 3 -- 345
	touchTheSky = false -- 346
	local body = cube:getChildByTag("cubeBody") -- 347
	body.position = Vec2.zero -- 348
	body.angularRate = 0 -- 349
	ui:removeFromParent() -- 350
	do -- 351
		local _with_0 = Node() -- 351
		_with_0:addTo(Director.ui) -- 352
		heartNode:removeFromParent() -- 353
		ui = _with_0 -- 351
	end -- 351
	return addHeartUI() -- 354
end -- 342
local windowFlags = { -- 357
	"NoDecoration", -- 357
	"NoSavedSettings", -- 358
	"NoFocusOnAppearing", -- 359
	"NoNav", -- 360
	"NoMove" -- 361
} -- 356
return threadLoop(function() -- 362
	local width, height -- 363
	do -- 363
		local _obj_0 = App.visualSize -- 363
		width, height = _obj_0.width, _obj_0.height -- 363
	end -- 363
	SetNextWindowBgAlpha(0.35) -- 364
	SetNextWindowPos(Vec2(width - 140, height - 170), "Always", Vec2.zero) -- 365
	SetNextWindowSize(Vec2(140, 0), "Always") -- 366
	return Begin("Touch The Sky", windowFlags, function() -- 367
		Text("Touch The Sky") -- 368
		Separator() -- 369
		TextWrapped("Click to grab!") -- 370
		do -- 371
			local changed, isHardMode = Checkbox("Hard Mode", hardMode) -- 371
			if changed then -- 371
				hardMode = isHardMode -- 372
			end -- 371
		end -- 371
	end) -- 372
end) -- 372
