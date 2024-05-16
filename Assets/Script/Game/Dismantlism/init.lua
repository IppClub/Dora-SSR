-- [yue]: Script/Game/Dismantlism/init.yue
local Path = Dora.Path -- 1
local Content = Dora.Content -- 1
local Node = Dora.Node -- 1
local Audio = Dora.Audio -- 1
local Sprite = Dora.Sprite -- 1
local Label = Dora.Label -- 1
local Color3 = Dora.Color3 -- 1
local PhysicsWorld = Dora.PhysicsWorld -- 1
local Grid = Dora.Grid -- 1
local Vec2 = Dora.Vec2 -- 1
local X = Dora.X -- 1
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
local AlignNode = require("UI.Control.Basic.AlignNode") -- 19
local Struct, Set -- 20
do -- 20
	local _obj_0 = require("Utils") -- 20
	Struct, Set = _obj_0.Struct, _obj_0.Set -- 20
end -- 20
local root -- 22
do -- 22
	local _with_0 = Node() -- 22
	_with_0:slot("Cleanup", function() -- 23
		return Audio:stopStream(0.2) -- 23
	end) -- 23
	root = _with_0 -- 22
end -- 22
local ui -- 24
do -- 24
	local _with_0 = Node() -- 24
	_with_0.x = -100 -- 25
	_with_0.y = -50 -- 26
	_with_0:addChild(Sprite("Model/duality.clip|stat")) -- 27
	ui = _with_0 -- 24
end -- 24
local score = 0 -- 28
local scoreTxt -- 29
do -- 29
	local _with_0 = Label("sarasa-mono-sc-regular", 40) -- 29
	_with_0.textAlign = "Center" -- 30
	_with_0.color3 = Color3(0x0) -- 31
	_with_0.text = "0" -- 32
	_with_0:addTo(ui) -- 33
	scoreTxt = _with_0 -- 29
end -- 29
local world -- 35
do -- 35
	local _with_0 = PhysicsWorld() -- 35
	_with_0.y = 405 -- 36
	_with_0:setShouldContact(0, 0, true) -- 37
	_with_0:setShouldContact(0, 1, false) -- 38
	_with_0:addTo(root) -- 39
	world = _with_0 -- 35
end -- 35
local isSpace = true -- 41
local switchScene = nil -- 42
local spaceBack = nil -- 44
local dailyBack = nil -- 45
local center = AlignNode({ -- 46
	hAlign = "Center", -- 46
	vAlign = "Center" -- 46
}) -- 46
local _anon_func_0 = function(Grid, Vec2, _with_1, h, w) -- 64
	local _with_0 = Grid("Model/duality.clip|space", 1, 1) -- 58
	_with_0:moveUV(1, 1, Vec2(1, 1)) -- 59
	_with_0:moveUV(2, 1, Vec2(-1, 1)) -- 60
	_with_0:moveUV(1, 2, Vec2(1, -1)) -- 61
	_with_0:moveUV(2, 2, Vec2(-1, -1)) -- 62
	_with_0.scaleX = w / 8 -- 63
	_with_0.scaleY = h / 1078 -- 64
	return _with_0 -- 58
end -- 58
local _anon_func_1 = function(Sprite, _with_2, x, y) -- 72
	local _with_0 = Sprite("Model/duality.clip|stary") -- 69
	_with_0.anchorX = 0 -- 70
	_with_0.x = -3000 + (x - 1) * 1000 -- 71
	_with_0.y = 3000 - (y - 1) * 1000 -- 72
	return _with_0 -- 69
end -- 69
do -- 47
	local _with_0 = AlignNode({ -- 47
		isRoot = true, -- 47
		inUI = false -- 47
	}) -- 47
	_with_0:slot("AlignLayout", function(w, h) -- 48
		local worldScale = w / 2970 -- 49
		root.scaleX = worldScale -- 50
		root.scaleY = worldScale -- 51
		ui.scaleX = worldScale -- 52
		ui.scaleY = worldScale -- 53
		if spaceBack then -- 54
			spaceBack:removeFromParent() -- 54
		end -- 54
		do -- 55
			local _with_1 = Node() -- 55
			_with_1.visible = isSpace -- 56
			_with_1.order = -1 -- 57
			_with_1:addChild(_anon_func_0(Grid, Vec2, _with_1, h, w)) -- 58
			_with_1:addChild((function() -- 65
				local _with_2 = Node() -- 65
				_with_2.scaleX = worldScale -- 66
				_with_2.scaleY = worldScale -- 67
				for y = 1, 8 do -- 68
					for x = 1, 8 do -- 68
						_with_2:addChild(_anon_func_1(Sprite, _with_2, x, y)) -- 69
					end -- 72
				end -- 72
				_with_2:perform(X(10, 0, -1000 * worldScale)) -- 73
				_with_2:slot("ActionEnd", function() -- 74
					return _with_2:perform(X(10, 0, -1000 * worldScale)) -- 74
				end) -- 74
				return _with_2 -- 65
			end)()) -- 65
			spaceBack = _with_1 -- 55
		end -- 55
		if dailyBack then -- 75
			dailyBack:removeFromParent() -- 75
		end -- 75
		local _with_1 = Grid("Model/duality.clip|day", 1, 1) -- 76
		_with_1.visible = not isSpace -- 77
		_with_1.order = -1 -- 78
		_with_1:moveUV(1, 1, Vec2(1, 1)) -- 79
		_with_1:moveUV(2, 1, Vec2(-1, 1)) -- 80
		_with_1:moveUV(1, 2, Vec2(1, -1)) -- 81
		_with_1:moveUV(2, 2, Vec2(-1, -1)) -- 82
		_with_1.scaleX = w / 8 -- 83
		_with_1.scaleY = h / 1078 -- 84
		dailyBack = _with_1 -- 76
	end) -- 48
	_with_0:addChild((function() -- 85
		local _with_1 = AlignNode({ -- 85
			hAlign = "Center", -- 85
			vAlign = "Bottom" -- 85
		}) -- 85
		_with_1:addChild(root) -- 86
		return _with_1 -- 85
	end)()) -- 85
	_with_0:addChild((function() -- 87
		local _with_1 = AlignNode({ -- 87
			hAlign = "Right", -- 87
			vAlign = "Top" -- 87
		}) -- 87
		_with_1:addChild(ui) -- 88
		return _with_1 -- 87
	end)()) -- 87
	_with_0:addChild((function() -- 89
		center:addChild((function() -- 90
			local _with_1 = Node() -- 90
			_with_1.touchEnabled = true -- 91
			_with_1.swallowTouches = true -- 92
			_with_1:addChild(Sprite("Model/duality.clip|dismantlism")) -- 93
			_with_1:perform(Sequence(Delay(1), Spawn(Opacity(1, 1, 0, Ease.OutQuad), Y(1, 0, 100, Ease.InQuad)), Event("Start"))) -- 94
			_with_1:slot("Start", function() -- 102
				isSpace = false -- 103
				switchScene() -- 104
				return _with_1:removeFromParent() -- 105
			end) -- 102
			return _with_1 -- 90
		end)()) -- 90
		return center -- 89
	end)()) -- 89
	_with_0:alignLayout() -- 106
end -- 47
local moveJoint = nil -- 108
local movingBody = nil -- 109
do -- 110
	local _with_0 = Node() -- 110
	_with_0.touchEnabled = true -- 111
	_with_0:slot("TapBegan", function(touch) -- 112
		local worldPos = _with_0:convertToWorldSpace(touch.location) -- 113
		local pos = world:convertToNodeSpace(worldPos) -- 114
		return world:query(Rect(pos - Vec2(1, 1), Size(2, 2)), function(body) -- 115
			if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 116
				return false -- 116
			end -- 116
			if moveJoint then -- 117
				moveJoint:destroy() -- 117
			end -- 117
			moveJoint = Joint:move(true, body, pos, 400) -- 118
			movingBody = body -- 119
			return true -- 120
		end) -- 120
	end) -- 112
	_with_0:slot("TapMoved", function(touch) -- 121
		if moveJoint then -- 122
			local worldPos = _with_0:convertToWorldSpace(touch.location) -- 123
			local pos = world:convertToNodeSpace(worldPos) -- 124
			moveJoint.position = pos -- 125
		end -- 122
	end) -- 121
	_with_0:slot("TapEnded", function() -- 126
		if moveJoint then -- 127
			moveJoint:destroy() -- 128
			moveJoint = nil -- 129
			movingBody = nil -- 130
		end -- 127
	end) -- 126
end -- 110
local scene = require("scene") -- 132
Struct.Body("name", "file", "position", "angle") -- 133
Struct:load(scene) -- 134
local spaceItems = Set({ -- 137
	"rocket", -- 137
	"satlite", -- 138
	"spacestation", -- 139
	"star1", -- 140
	"star2", -- 141
	"ufo", -- 142
	"get" -- 143
}) -- 136
local dailyItems = Set({ -- 146
	"baseball", -- 146
	"burger", -- 147
	"donut", -- 148
	"fish", -- 149
	"radio", -- 150
	"tv", -- 151
	"pizza" -- 152
}) -- 145
local spaceBodies = { } -- 154
local dailyBodies = { } -- 155
switchScene = function() -- 157
	if isSpace then -- 158
		Audio:playStream("Audio/Dismantlism Space.ogg", true, 0.2) -- 159
		dailyBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 160
		spaceBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 165
		for _index_0 = 1, #dailyBodies do -- 169
			local body = dailyBodies[_index_0] -- 169
			local _with_0 = body.children[1] -- 170
			if _with_0.actionCount == 0 then -- 171
				_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 172
			end -- 171
		end -- 176
		for _index_0 = 1, #spaceBodies do -- 177
			local body = spaceBodies[_index_0] -- 177
			local _with_0 = body.children[1] -- 178
			if _with_0.actionCount == 0 then -- 179
				_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 180
			end -- 179
		end -- 183
	else -- 185
		Audio:playStream("Audio/Dismantlism Daily.ogg", true, 0.2) -- 185
		spaceBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 186
		dailyBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 191
		for _index_0 = 1, #spaceBodies do -- 195
			local body = spaceBodies[_index_0] -- 195
			local _with_0 = body.children[1] -- 196
			if _with_0.actionCount == 0 then -- 197
				_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 198
			end -- 197
		end -- 202
		for _index_0 = 1, #dailyBodies do -- 203
			local body = dailyBodies[_index_0] -- 203
			local _with_0 = body.children[1] -- 204
			if _with_0.actionCount == 0 then -- 205
				_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 206
			end -- 205
		end -- 209
	end -- 158
end -- 157
local restartScene = nil -- 211
local gameEnded = false -- 212
local _anon_func_2 = function(Color, Label, _with_0) -- 243
	local _with_1 = Label("sarasa-mono-sc-regular", 80) -- 240
	_with_1.textAlign = "Center" -- 241
	_with_1.color = Color(0x66ffffff) -- 242
	_with_1.text = "Drag It\nHere" -- 243
	return _with_1 -- 240
end -- 240
local _anon_func_3 = function(Delay, Ease, Event, Node, Opacity, Scale, Sequence, Spawn, Sprite, _with_1, body) -- 278
	local _with_0 = Node() -- 265
	_with_0:addChild(Sprite("Model/duality.clip|window")) -- 266
	_with_0:addChild(Sprite("Model/duality.clip|credits1")) -- 267
	_with_0.position = body.position -- 268
	_with_0:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 269
	_with_0:slot("End", function() -- 278
		return _with_0:removeFromParent() -- 278
	end) -- 278
	return _with_0 -- 265
end -- 265
local buildScene -- 213
buildScene = function() -- 213
	for i = 1, scene:count() do -- 214
		local name, file, position, angle -- 215
		do -- 215
			local _obj_0 = scene:get(i) -- 220
			name, file, position, angle = _obj_0.name, _obj_0.file, _obj_0.position, _obj_0.angle -- 215
			if position == nil then -- 218
				position = Vec2.zero -- 218
			end -- 218
			if angle == nil then -- 219
				angle = 0 -- 219
			end -- 219
		end -- 220
		local node = BodyEx(require(Path("Physics", file)), world, position, angle) -- 221
		world:addChild(node) -- 222
		if spaceItems[file] then -- 223
			node.data:each(function(self) -- 224
				self.tag = "space" -- 225
				self.children[1].tag = file -- 226
				spaceBodies[#spaceBodies + 1] = self -- 227
			end) -- 224
		elseif dailyItems[file] then -- 228
			node.data:each(function(self) -- 229
				self.tag = "daily" -- 230
				self.children[1].tag = file -- 231
				dailyBodies[#dailyBodies + 1] = self -- 232
			end) -- 229
		else -- 234
			node.data:each(function(self) -- 234
				if self.children and #self.children > 0 then -- 235
					self.children[1].tag = file -- 235
				end -- 235
			end) -- 234
		end -- 223
		if "removearea" == file then -- 237
			local _with_0 = node.data.rect -- 238
			_with_0:addChild(SolidRect({ -- 239
				x = -200, -- 239
				y = -200, -- 239
				width = 400, -- 239
				height = 400, -- 239
				color = 0x66000000 -- 239
			})) -- 239
			_with_0:addChild(_anon_func_2(Color, Label, _with_0)) -- 240
			_with_0:slot("BodyEnter", function(body) -- 244
				if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 245
					return -- 245
				end -- 245
				if body.group == 1 then -- 246
					return -- 246
				end -- 246
				body.group = 1 -- 247
				local _with_1 = body.children[1] -- 248
				_with_1:perform(Sequence(Spawn(Opacity(0.5, 1, 0), Scale(0.5, 1, 1.5, Ease.OutBack)), Event("Destroy"))) -- 249
				_with_1:slot("Destroy", function() -- 253
					do -- 254
						local _exp_0 = _with_1.tag -- 254
						if "star2" == _exp_0 or "pizza" == _exp_0 then -- 255
							score = score + 10 -- 256
							isSpace = not isSpace -- 257
							switchScene() -- 258
						elseif "quit" == _exp_0 then -- 259
							App:shutdown() -- 260
						elseif "get" == _exp_0 or "fish" == _exp_0 then -- 261
							score = score + 100 -- 262
						elseif "credit" == _exp_0 then -- 263
							score = score + 50 -- 264
							world:addChild(_anon_func_3(Delay, Ease, Event, Node, Opacity, Scale, Sequence, Spawn, Sprite, _with_1, body)) -- 265
						else -- 280
							score = score + 10 -- 280
						end -- 280
					end -- 280
					scoreTxt.text = tostring(score) -- 281
					if score > 600 then -- 282
						gameEnded = true -- 283
						center:addChild((function() -- 284
							local _with_2 = Node() -- 284
							_with_2:addChild(Sprite("Model/duality.clip|window")) -- 285
							_with_2:addChild(Sprite("Model/duality.clip|win")) -- 286
							_with_2:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 287
							_with_2:slot("End", function() -- 296
								_with_2:removeFromParent() -- 297
								return restartScene() -- 298
							end) -- 296
							return _with_2 -- 284
						end)()) -- 284
					end -- 282
					if movingBody == body and moveJoint then -- 299
						moveJoint:destroy() -- 300
						moveJoint = nil -- 301
						movingBody = nil -- 302
					end -- 299
					return body:removeFromParent() -- 303
				end) -- 253
				return _with_1 -- 248
			end) -- 244
		elseif "safearea" == file then -- 304
			local _with_0 = node.data.rect -- 305
			_with_0:slot("BodyEnter", function(body) -- 306
				if body == movingBody then -- 307
					return -- 307
				end -- 307
				local tag = body.children[1].tag -- 308
				if (name == "safe1" and tag == "get") or (name == "safe2" and tag == "fish") then -- 309
					if not gameEnded then -- 311
						gameEnded = true -- 312
						return world:addChild((function() -- 313
							local _with_1 = Node() -- 313
							_with_1:addChild(Sprite("Model/duality.clip|window")) -- 314
							_with_1:addChild(Sprite("Model/duality.clip|lose")) -- 315
							_with_1.position = body.position -- 316
							_with_1:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(2), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 317
							_with_1:slot("End", function() -- 326
								return restartScene() -- 326
							end) -- 326
							return _with_1 -- 313
						end)()) -- 326
					end -- 311
				end -- 309
			end) -- 306
		end -- 326
	end -- 326
end -- 213
buildScene() -- 328
switchScene() -- 329
restartScene = function() -- 331
	score = 0 -- 332
	scoreTxt.text = "0" -- 333
	isSpace = false -- 334
	gameEnded = false -- 335
	if moveJoint then -- 336
		moveJoint:destroy() -- 337
		moveJoint = nil -- 338
		movingBody = nil -- 339
	end -- 336
	world:removeFromParent() -- 340
	do -- 341
		local _with_0 = PhysicsWorld() -- 341
		_with_0.y = 405 -- 342
		_with_0:setShouldContact(0, 0, true) -- 343
		_with_0:setShouldContact(0, 1, false) -- 344
		_with_0:addTo(root) -- 345
		world = _with_0 -- 341
	end -- 341
	buildScene() -- 346
	return switchScene() -- 347
end -- 331
