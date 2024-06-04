-- [yue]: init.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local Node = Dora.Node -- 1
local Audio = Dora.Audio -- 1
local Sprite = Dora.Sprite -- 1
local Label = Dora.Label -- 1
local Color3 = Dora.Color3 -- 1
local PhysicsWorld = Dora.PhysicsWorld -- 1
local Director = Dora.Director -- 1
local AlignNode = Dora.AlignNode -- 1
local Vec2 = Dora.Vec2 -- 1
local Grid = Dora.Grid -- 1
local X = Dora.X -- 1
local math = _G.math -- 1
local Sequence = Dora.Sequence -- 1
local Delay = Dora.Delay -- 1
local Spawn = Dora.Spawn -- 1
local Opacity = Dora.Opacity -- 1
local Ease = Dora.Ease -- 1
local Y = Dora.Y -- 1
local Event = Dora.Event -- 1
local Rect = Dora.Rect -- 1
local Size = Dora.Size -- 1
local Joint = Dora.Joint -- 1
local Show = Dora.Show -- 1
local Hide = Dora.Hide -- 1
local Scale = Dora.Scale -- 1
local Color = Dora.Color -- 1
local App = Dora.App -- 1
local tostring = _G.tostring -- 1
local scriptPath = Path:getScriptPath(...) -- 13
if not scriptPath then -- 14
	return -- 14
end -- 14
Content:insertSearchPath(1, scriptPath) -- 15
local BodyEx = require("BodyEx") -- 17
local SolidRect = require("UI.View.Shape.SolidRect") -- 18
local Struct, Set -- 19
do -- 19
	local _obj_0 = require("Utils") -- 19
	Struct, Set = _obj_0.Struct, _obj_0.Set -- 19
end -- 19
local root -- 21
do -- 21
	local _with_0 = Node() -- 21
	_with_0:slot("Cleanup", function() -- 22
		return Audio:stopStream(0.2) -- 22
	end) -- 22
	root = _with_0 -- 21
end -- 21
local ui -- 23
do -- 23
	local _with_0 = Node() -- 23
	_with_0.scaleX = 0.4 -- 24
	_with_0.scaleY = 0.4 -- 24
	_with_0:addChild(Sprite("Model/duality.clip|stat")) -- 25
	ui = _with_0 -- 23
end -- 23
local score = 0 -- 26
local scoreTxt -- 27
do -- 27
	local _with_0 = Label("sarasa-mono-sc-regular", 40) -- 27
	_with_0.textAlign = "Center" -- 28
	_with_0.color3 = Color3(0x0) -- 29
	_with_0.text = "0" -- 30
	_with_0:addTo(ui) -- 31
	scoreTxt = _with_0 -- 27
end -- 27
local world -- 33
do -- 33
	local _with_0 = PhysicsWorld() -- 33
	_with_0.y = 405 -- 34
	_with_0:setShouldContact(0, 0, true) -- 35
	_with_0:setShouldContact(0, 1, false) -- 36
	_with_0:addTo(root) -- 37
	world = _with_0 -- 33
end -- 33
local isSpace = true -- 39
local switchScene = nil -- 40
local center = nil -- 42
local spaceBack = nil -- 43
local dailyBack = nil -- 44
local _anon_func_0 = function(Grid, Vec2, _with_1, h, w) -- 63
	local _with_0 = Grid("Model/duality.clip|space", 1, 1) -- 57
	_with_0:moveUV(1, 1, Vec2(1, 1)) -- 58
	_with_0:moveUV(2, 1, Vec2(-1, 1)) -- 59
	_with_0:moveUV(1, 2, Vec2(1, -1)) -- 60
	_with_0:moveUV(2, 2, Vec2(-1, -1)) -- 61
	_with_0.scaleX = w / 8 -- 62
	_with_0.scaleY = h / 1078 -- 63
	return _with_0 -- 57
end -- 57
local _anon_func_1 = function(Sprite, _with_2, x, y) -- 71
	local _with_0 = Sprite("Model/duality.clip|stary") -- 68
	_with_0.anchorX = 0 -- 69
	_with_0.x = -3000 + (x - 1) * 1000 -- 70
	_with_0.y = 3000 - (y - 1) * 1000 -- 71
	return _with_0 -- 68
end -- 68
Director.ui:addChild((function() -- 45
	local _with_0 = AlignNode(true) -- 45
	_with_0:css("flex-direction: column") -- 46
	_with_0:slot("AlignLayout", function(w, h) -- 47
		local worldScale = w / 2970 -- 48
		root.scaleX = worldScale -- 49
		root.scaleY = worldScale -- 50
		center.position = Vec2(w / 2, h / 2) -- 51
		if spaceBack then -- 52
			spaceBack:removeFromParent() -- 52
		end -- 52
		do -- 53
			local _with_1 = Node() -- 53
			_with_1.position = Vec2(w / 2, h / 2) -- 54
			_with_1.visible = isSpace -- 55
			_with_1.order = -1 -- 56
			_with_1:addChild(_anon_func_0(Grid, Vec2, _with_1, h, w)) -- 57
			_with_1:addChild((function() -- 64
				local _with_2 = Node() -- 64
				_with_2.scaleX = worldScale -- 65
				_with_2.scaleY = worldScale -- 66
				for y = 1, 8 do -- 67
					for x = 1, 8 do -- 67
						_with_2:addChild(_anon_func_1(Sprite, _with_2, x, y)) -- 68
					end -- 71
				end -- 71
				_with_2:perform(X(10, 0, -1000 * worldScale)) -- 72
				_with_2:slot("ActionEnd", function() -- 73
					return _with_2:perform(X(10, 0, -1000 * worldScale)) -- 73
				end) -- 73
				return _with_2 -- 64
			end)()) -- 64
			spaceBack = _with_1 -- 53
		end -- 53
		_with_0:addChild(spaceBack) -- 74
		if dailyBack then -- 75
			dailyBack:removeFromParent() -- 75
		end -- 75
		do -- 76
			local _with_1 = Grid("Model/duality.clip|day", 1, 1) -- 76
			_with_1.position = Vec2(w / 2, h / 2) -- 77
			_with_1.visible = not isSpace -- 78
			_with_1.order = -1 -- 79
			_with_1:moveUV(1, 1, Vec2(1, 1)) -- 80
			_with_1:moveUV(2, 1, Vec2(-1, 1)) -- 81
			_with_1:moveUV(1, 2, Vec2(1, -1)) -- 82
			_with_1:moveUV(2, 2, Vec2(-1, -1)) -- 83
			_with_1.scaleX = w / 8 -- 84
			_with_1.scaleY = h / 1078 -- 85
			dailyBack = _with_1 -- 76
		end -- 76
		return _with_0:addChild(dailyBack) -- 86
	end) -- 47
	_with_0:addChild((function() -- 87
		local _with_1 = AlignNode() -- 87
		_with_1.order = 1 -- 88
		_with_1:css("height: 30%; flex-direction: row-reverse") -- 89
		_with_1:addChild((function() -- 90
			local _with_2 = AlignNode() -- 90
			_with_2:css("height: 25; margin-right: 45") -- 91
			_with_2:addChild(ui) -- 92
			return _with_2 -- 90
		end)()) -- 90
		return _with_1 -- 87
	end)()) -- 87
	_with_0:addChild((function() -- 93
		center = AlignNode() -- 93
		center.order = 2 -- 94
		center:css("height: 40%") -- 95
		center:addChild((function() -- 96
			local _with_1 = Node() -- 96
			_with_1.touchEnabled = true -- 97
			_with_1.swallowTouches = true -- 98
			_with_1:addChild((function() -- 99
				local banner = Sprite("Model/duality.clip|dismantlism") -- 99
				center:slot("AlignLayout", function(w, h) -- 100
					banner.position = Vec2(w / 2, h / 2) -- 101
					do -- 102
						local _tmp_0 = 0.9 * math.min(w / banner.width, h / banner.height) -- 102
						banner.scaleX = _tmp_0 -- 102
						banner.scaleY = _tmp_0 -- 102
					end -- 102
				end) -- 100
				return banner -- 99
			end)()) -- 99
			_with_1:perform(Sequence(Delay(1), Spawn(Opacity(1, 1, 0, Ease.OutQuad), Y(1, 0, 100, Ease.InQuad)), Event("Start"))) -- 103
			_with_1:slot("Start", function() -- 111
				isSpace = false -- 112
				switchScene() -- 113
				center:slot("AlignLayout", nil) -- 114
				return _with_1:removeFromParent() -- 115
			end) -- 111
			return _with_1 -- 96
		end)()) -- 96
		return center -- 93
	end)()) -- 93
	_with_0:addChild((function() -- 116
		local _with_1 = AlignNode() -- 116
		_with_1:css("height: 30%") -- 117
		_with_1:addChild(root) -- 118
		_with_1:slot("AlignLayout", function(w) -- 119
			root.x = w / 2 -- 119
		end) -- 119
		return _with_1 -- 116
	end)()) -- 116
	return _with_0 -- 45
end)()) -- 45
local moveJoint = nil -- 121
local movingBody = nil -- 122
do -- 123
	local _with_0 = Node() -- 123
	_with_0.touchEnabled = true -- 124
	_with_0:slot("TapBegan", function(touch) -- 125
		local worldPos = _with_0:convertToWorldSpace(touch.location) -- 126
		local pos = world:convertToNodeSpace(worldPos) -- 127
		return world:query(Rect(pos - Vec2(1, 1), Size(2, 2)), function(body) -- 128
			if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 129
				return false -- 129
			end -- 129
			if moveJoint then -- 130
				moveJoint:destroy() -- 130
			end -- 130
			moveJoint = Joint:move(true, body, pos, 400) -- 131
			movingBody = body -- 132
			return true -- 133
		end) -- 133
	end) -- 125
	_with_0:slot("TapMoved", function(touch) -- 134
		if moveJoint then -- 135
			local worldPos = _with_0:convertToWorldSpace(touch.location) -- 136
			local pos = world:convertToNodeSpace(worldPos) -- 137
			moveJoint.position = pos -- 138
		end -- 135
	end) -- 134
	_with_0:slot("TapEnded", function() -- 139
		if moveJoint then -- 140
			moveJoint:destroy() -- 141
			moveJoint = nil -- 142
			movingBody = nil -- 143
		end -- 140
	end) -- 139
end -- 123
local scene = require("scene") -- 145
Struct.Body("name", "file", "position", "angle") -- 146
Struct:load(scene) -- 147
local spaceItems = Set({ -- 150
	"rocket", -- 150
	"satlite", -- 151
	"spacestation", -- 152
	"star1", -- 153
	"star2", -- 154
	"ufo", -- 155
	"get" -- 156
}) -- 149
local dailyItems = Set({ -- 159
	"baseball", -- 159
	"burger", -- 160
	"donut", -- 161
	"fish", -- 162
	"radio", -- 163
	"tv", -- 164
	"pizza" -- 165
}) -- 158
local spaceBodies = { } -- 167
local dailyBodies = { } -- 168
switchScene = function(init) -- 170
	if isSpace then -- 171
		Audio:playStream("Audio/Dismantlism Space.ogg", true) -- 172
		if not init then -- 173
			dailyBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 174
			spaceBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 179
		end -- 173
		for _index_0 = 1, #dailyBodies do -- 183
			local body = dailyBodies[_index_0] -- 183
			local _with_0 = body.children[1] -- 184
			if _with_0.actionCount == 0 then -- 185
				_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 186
			end -- 185
		end -- 190
		for _index_0 = 1, #spaceBodies do -- 191
			local body = spaceBodies[_index_0] -- 191
			local _with_0 = body.children[1] -- 192
			if _with_0.actionCount == 0 then -- 193
				_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 194
			end -- 193
		end -- 197
	else -- 199
		Audio:playStream("Audio/Dismantlism Daily.ogg", true) -- 199
		if not init then -- 200
			spaceBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 201
			dailyBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 206
		end -- 200
		for _index_0 = 1, #spaceBodies do -- 210
			local body = spaceBodies[_index_0] -- 210
			local _with_0 = body.children[1] -- 211
			if _with_0.actionCount == 0 then -- 212
				_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 213
			end -- 212
		end -- 217
		for _index_0 = 1, #dailyBodies do -- 218
			local body = dailyBodies[_index_0] -- 218
			local _with_0 = body.children[1] -- 219
			if _with_0.actionCount == 0 then -- 220
				_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 221
			end -- 220
		end -- 224
	end -- 171
end -- 170
local restartScene = nil -- 226
local gameEnded = false -- 227
local _anon_func_2 = function(Color, Label, _with_0) -- 258
	local _with_1 = Label("sarasa-mono-sc-regular", 80) -- 255
	_with_1.textAlign = "Center" -- 256
	_with_1.color = Color(0x66ffffff) -- 257
	_with_1.text = "Drag It\nHere" -- 258
	return _with_1 -- 255
end -- 255
local _anon_func_3 = function(Delay, Ease, Event, Node, Opacity, Scale, Sequence, Spawn, Sprite, _with_1, body) -- 293
	local _with_0 = Node() -- 280
	_with_0:addChild(Sprite("Model/duality.clip|window")) -- 281
	_with_0:addChild(Sprite("Model/duality.clip|credits1")) -- 282
	_with_0.position = body.position -- 283
	_with_0:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 284
	_with_0:slot("End", function() -- 293
		return _with_0:removeFromParent() -- 293
	end) -- 293
	return _with_0 -- 280
end -- 280
local buildScene -- 228
buildScene = function() -- 228
	for i = 1, scene:count() do -- 229
		local name, file, position, angle -- 230
		do -- 230
			local _obj_0 = scene:get(i) -- 235
			name, file, position, angle = _obj_0.name, _obj_0.file, _obj_0.position, _obj_0.angle -- 230
			if position == nil then -- 233
				position = Vec2.zero -- 233
			end -- 233
			if angle == nil then -- 234
				angle = 0 -- 234
			end -- 234
		end -- 235
		local node = BodyEx(require(Path("Physics", file)), world, position, angle) -- 236
		world:addChild(node) -- 237
		if spaceItems[file] then -- 238
			node.data:each(function(self) -- 239
				self.tag = "space" -- 240
				self.children[1].tag = file -- 241
				spaceBodies[#spaceBodies + 1] = self -- 242
			end) -- 239
		elseif dailyItems[file] then -- 243
			node.data:each(function(self) -- 244
				self.tag = "daily" -- 245
				self.children[1].tag = file -- 246
				dailyBodies[#dailyBodies + 1] = self -- 247
			end) -- 244
		else -- 249
			node.data:each(function(self) -- 249
				if self.children and #self.children > 0 then -- 250
					self.children[1].tag = file -- 250
				end -- 250
			end) -- 249
		end -- 238
		if "removearea" == file then -- 252
			local _with_0 = node.data.rect -- 253
			_with_0:addChild(SolidRect({ -- 254
				x = -200, -- 254
				y = -200, -- 254
				width = 400, -- 254
				height = 400, -- 254
				color = 0x66000000 -- 254
			})) -- 254
			_with_0:addChild(_anon_func_2(Color, Label, _with_0)) -- 255
			_with_0:slot("BodyEnter", function(body) -- 259
				if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 260
					return -- 260
				end -- 260
				if body.group == 1 then -- 261
					return -- 261
				end -- 261
				body.group = 1 -- 262
				local _with_1 = body.children[1] -- 263
				_with_1:perform(Sequence(Spawn(Opacity(0.5, 1, 0), Scale(0.5, 1, 1.5, Ease.OutBack)), Event("Destroy"))) -- 264
				_with_1:slot("Destroy", function() -- 268
					do -- 269
						local _exp_0 = _with_1.tag -- 269
						if "star2" == _exp_0 or "pizza" == _exp_0 then -- 270
							score = score + 10 -- 271
							isSpace = not isSpace -- 272
							switchScene() -- 273
						elseif "quit" == _exp_0 then -- 274
							App:shutdown() -- 275
						elseif "get" == _exp_0 or "fish" == _exp_0 then -- 276
							score = score + 100 -- 277
						elseif "credit" == _exp_0 then -- 278
							score = score + 50 -- 279
							world:addChild(_anon_func_3(Delay, Ease, Event, Node, Opacity, Scale, Sequence, Spawn, Sprite, _with_1, body)) -- 280
						else -- 295
							score = score + 10 -- 295
						end -- 295
					end -- 295
					scoreTxt.text = tostring(score) -- 296
					if score > 600 then -- 297
						gameEnded = true -- 298
						center:addChild((function() -- 299
							local _with_2 = Node() -- 299
							_with_2:addChild(Sprite("Model/duality.clip|window")) -- 300
							_with_2:addChild(Sprite("Model/duality.clip|win")) -- 301
							_with_2:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 302
							_with_2:slot("End", function() -- 311
								_with_2:removeFromParent() -- 312
								return restartScene() -- 313
							end) -- 311
							return _with_2 -- 299
						end)()) -- 299
					end -- 297
					if movingBody == body and moveJoint then -- 314
						moveJoint:destroy() -- 315
						moveJoint = nil -- 316
						movingBody = nil -- 317
					end -- 314
					return body:removeFromParent() -- 318
				end) -- 268
				return _with_1 -- 263
			end) -- 259
		elseif "safearea" == file then -- 319
			local _with_0 = node.data.rect -- 320
			_with_0:slot("BodyEnter", function(body) -- 321
				if body == movingBody then -- 322
					return -- 322
				end -- 322
				local tag = body.children[1].tag -- 323
				if (name == "safe1" and tag == "get") or (name == "safe2" and tag == "fish") then -- 324
					if not gameEnded then -- 326
						gameEnded = true -- 327
						return world:addChild((function() -- 328
							local _with_1 = Node() -- 328
							_with_1:addChild(Sprite("Model/duality.clip|window")) -- 329
							_with_1:addChild(Sprite("Model/duality.clip|lose")) -- 330
							_with_1.position = body.position -- 331
							_with_1:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(2), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 332
							_with_1:slot("End", function() -- 341
								return restartScene() -- 341
							end) -- 341
							return _with_1 -- 328
						end)()) -- 341
					end -- 326
				end -- 324
			end) -- 321
		end -- 341
	end -- 341
end -- 228
buildScene() -- 343
switchScene(true) -- 344
restartScene = function() -- 346
	score = 0 -- 347
	scoreTxt.text = "0" -- 348
	isSpace = false -- 349
	gameEnded = false -- 350
	if moveJoint then -- 351
		moveJoint:destroy() -- 352
		moveJoint = nil -- 353
		movingBody = nil -- 354
	end -- 351
	world:removeFromParent() -- 355
	do -- 356
		local _with_0 = PhysicsWorld() -- 356
		_with_0.y = 405 -- 357
		_with_0:setShouldContact(0, 0, true) -- 358
		_with_0:setShouldContact(0, 1, false) -- 359
		_with_0:addTo(root) -- 360
		world = _with_0 -- 356
	end -- 356
	buildScene() -- 361
	return switchScene() -- 362
end -- 346
