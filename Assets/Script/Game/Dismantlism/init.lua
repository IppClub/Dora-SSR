-- [yue]: Script/Game/Dismantlism/init.yue
local Path = dora.Path -- 1
local Content = dora.Content -- 1
local Node = dora.Node -- 1
local Audio = dora.Audio -- 1
local Sprite = dora.Sprite -- 1
local Label = dora.Label -- 1
local Color3 = dora.Color3 -- 1
local PhysicsWorld = dora.PhysicsWorld -- 1
local Grid = dora.Grid -- 1
local Vec2 = dora.Vec2 -- 1
local X = dora.X -- 1
local Sequence = dora.Sequence -- 1
local Delay = dora.Delay -- 1
local Spawn = dora.Spawn -- 1
local Opacity = dora.Opacity -- 1
local Ease = dora.Ease -- 1
local Y = dora.Y -- 1
local Event = dora.Event -- 1
local Rect = dora.Rect -- 1
local Size = dora.Size -- 1
local Joint = dora.Joint -- 1
local Show = dora.Show -- 1
local Hide = dora.Hide -- 1
local Scale = dora.Scale -- 1
local Color = dora.Color -- 1
local App = dora.App -- 1
local tostring = _G.tostring -- 1
local scriptPath = Path:getScriptPath(...) -- 4
if not scriptPath then -- 5
	return -- 5
end -- 5
Content:insertSearchPath(1, scriptPath) -- 6
local BodyEx = require("BodyEx") -- 8
local SolidRect = require("UI.View.Shape.SolidRect") -- 9
local AlignNode = require("UI.Control.Basic.AlignNode") -- 10
local Struct, Set -- 11
do -- 11
	local _obj_0 = require("Utils") -- 11
	Struct, Set = _obj_0.Struct, _obj_0.Set -- 11
end -- 11
local root -- 13
do -- 13
	local _with_0 = Node() -- 13
	_with_0:slot("Cleanup", function() -- 14
		return Audio:stopStream(0.2) -- 14
	end) -- 14
	root = _with_0 -- 13
end -- 13
local ui -- 15
do -- 15
	local _with_0 = Node() -- 15
	_with_0.x = -100 -- 16
	_with_0.y = -50 -- 17
	_with_0:addChild(Sprite("Model/duality.clip|stat")) -- 18
	ui = _with_0 -- 15
end -- 15
local score = 0 -- 19
local scoreTxt -- 20
do -- 20
	local _with_0 = Label("sarasa-mono-sc-regular", 40) -- 20
	_with_0.textAlign = "Center" -- 21
	_with_0.color3 = Color3(0x0) -- 22
	_with_0.text = "0" -- 23
	_with_0:addTo(ui) -- 24
	scoreTxt = _with_0 -- 20
end -- 20
local world -- 26
do -- 26
	local _with_0 = PhysicsWorld() -- 26
	_with_0.y = 405 -- 27
	_with_0:setShouldContact(0, 0, true) -- 28
	_with_0:setShouldContact(0, 1, false) -- 29
	_with_0:addTo(root) -- 30
	world = _with_0 -- 26
end -- 26
local isSpace = true -- 32
local switchScene = nil -- 33
local spaceBack = nil -- 35
local dailyBack = nil -- 36
local center = AlignNode({ -- 37
	hAlign = "Center", -- 37
	vAlign = "Center" -- 37
}) -- 37
do -- 38
	local _with_0 = AlignNode({ -- 38
		isRoot = true, -- 38
		inUI = false -- 38
	}) -- 38
	_with_0:slot("AlignLayout", function(w, h) -- 39
		local worldScale = w / 2970 -- 40
		root.scaleX = worldScale -- 41
		root.scaleY = worldScale -- 42
		ui.scaleX = worldScale -- 43
		ui.scaleY = worldScale -- 44
		if spaceBack then -- 45
			spaceBack:removeFromParent() -- 45
		end -- 45
		do -- 46
			local _with_1 = Node() -- 46
			_with_1.visible = isSpace -- 47
			_with_1.order = -1 -- 48
			_with_1:addChild((function() -- 49
				local _with_2 = Grid("Model/duality.clip|space", 1, 1) -- 49
				_with_2:moveUV(1, 1, Vec2(1, 1)) -- 50
				_with_2:moveUV(2, 1, Vec2(-1, 1)) -- 51
				_with_2:moveUV(1, 2, Vec2(1, -1)) -- 52
				_with_2:moveUV(2, 2, Vec2(-1, -1)) -- 53
				_with_2.scaleX = w / 8 -- 54
				_with_2.scaleY = h / 1078 -- 55
				return _with_2 -- 49
			end)()) -- 49
			_with_1:addChild((function() -- 56
				local _with_2 = Node() -- 56
				_with_2.scaleX = worldScale -- 57
				_with_2.scaleY = worldScale -- 58
				for y = 1, 8 do -- 59
					for x = 1, 8 do -- 59
						_with_2:addChild((function() -- 60
							local _with_3 = Sprite("Model/duality.clip|stary") -- 60
							_with_3.anchorX = 0 -- 61
							_with_3.x = -3000 + (x - 1) * 1000 -- 62
							_with_3.y = 3000 - (y - 1) * 1000 -- 63
							return _with_3 -- 60
						end)()) -- 60
					end -- 63
				end -- 63
				_with_2:perform(X(10, 0, -1000 * worldScale)) -- 64
				_with_2:slot("ActionEnd", function() -- 65
					return _with_2:perform(X(10, 0, -1000 * worldScale)) -- 65
				end) -- 65
				return _with_2 -- 56
			end)()) -- 56
			spaceBack = _with_1 -- 46
		end -- 46
		if dailyBack then -- 66
			dailyBack:removeFromParent() -- 66
		end -- 66
		do -- 67
			local _with_1 = Grid("Model/duality.clip|day", 1, 1) -- 67
			_with_1.visible = not isSpace -- 68
			_with_1.order = -1 -- 69
			_with_1:moveUV(1, 1, Vec2(1, 1)) -- 70
			_with_1:moveUV(2, 1, Vec2(-1, 1)) -- 71
			_with_1:moveUV(1, 2, Vec2(1, -1)) -- 72
			_with_1:moveUV(2, 2, Vec2(-1, -1)) -- 73
			_with_1.scaleX = w / 8 -- 74
			_with_1.scaleY = h / 1078 -- 75
			dailyBack = _with_1 -- 67
		end -- 67
	end) -- 39
	_with_0:addChild((function() -- 76
		local _with_1 = AlignNode({ -- 76
			hAlign = "Center", -- 76
			vAlign = "Bottom" -- 76
		}) -- 76
		_with_1:addChild(root) -- 77
		return _with_1 -- 76
	end)()) -- 76
	_with_0:addChild((function() -- 78
		local _with_1 = AlignNode({ -- 78
			hAlign = "Right", -- 78
			vAlign = "Top" -- 78
		}) -- 78
		_with_1:addChild(ui) -- 79
		return _with_1 -- 78
	end)()) -- 78
	_with_0:addChild((function() -- 80
		center:addChild((function() -- 81
			local _with_1 = Node() -- 81
			_with_1.touchEnabled = true -- 82
			_with_1.swallowTouches = true -- 83
			_with_1:addChild(Sprite("Model/duality.clip|dismantlism")) -- 84
			_with_1:perform(Sequence(Delay(1), Spawn(Opacity(1, 1, 0, Ease.OutQuad), Y(1, 0, 100, Ease.InQuad)), Event("Start"))) -- 85
			_with_1:slot("Start", function() -- 93
				isSpace = false -- 94
				switchScene() -- 95
				return _with_1:removeFromParent() -- 96
			end) -- 93
			return _with_1 -- 81
		end)()) -- 81
		return center -- 80
	end)()) -- 80
	_with_0:alignLayout() -- 97
end -- 38
local moveJoint = nil -- 99
local movingBody = nil -- 100
do -- 101
	local _with_0 = Node() -- 101
	_with_0.touchEnabled = true -- 102
	_with_0:slot("TapBegan", function(touch) -- 103
		local worldPos = _with_0:convertToWorldSpace(touch.location) -- 104
		local pos = world:convertToNodeSpace(worldPos) -- 105
		return world:query(Rect(pos - Vec2(1, 1), Size(2, 2)), function(body) -- 106
			if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 107
				return false -- 107
			end -- 107
			if moveJoint then -- 108
				moveJoint:destroy() -- 108
			end -- 108
			moveJoint = Joint:move(true, body, pos, 400) -- 109
			movingBody = body -- 110
			return true -- 111
		end) -- 111
	end) -- 103
	_with_0:slot("TapMoved", function(touch) -- 112
		if moveJoint then -- 113
			local worldPos = _with_0:convertToWorldSpace(touch.location) -- 114
			local pos = world:convertToNodeSpace(worldPos) -- 115
			moveJoint.position = pos -- 116
		end -- 113
	end) -- 112
	_with_0:slot("TapEnded", function() -- 117
		if moveJoint then -- 118
			moveJoint:destroy() -- 119
			moveJoint = nil -- 120
			movingBody = nil -- 121
		end -- 118
	end) -- 117
end -- 101
local scene = require("scene") -- 123
Struct.Body("name", "file", "position", "angle") -- 124
Struct:load(scene) -- 125
local spaceItems = Set({ -- 128
	"rocket", -- 128
	"satlite", -- 129
	"spacestation", -- 130
	"star1", -- 131
	"star2", -- 132
	"ufo", -- 133
	"get" -- 134
}) -- 127
local dailyItems = Set({ -- 137
	"baseball", -- 137
	"burger", -- 138
	"donut", -- 139
	"fish", -- 140
	"radio", -- 141
	"tv", -- 142
	"pizza" -- 143
}) -- 136
local spaceBodies = { } -- 145
local dailyBodies = { } -- 146
switchScene = function() -- 148
	if isSpace then -- 149
		Audio:playStream("Audio/Dismantlism Space.ogg", true, 0.2) -- 150
		dailyBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 151
		spaceBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 156
		for _index_0 = 1, #dailyBodies do -- 160
			local body = dailyBodies[_index_0] -- 160
			do -- 161
				local _with_0 = body.children[1] -- 161
				if _with_0.actionCount == 0 then -- 162
					_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 163
				end -- 162
			end -- 161
		end -- 167
		for _index_0 = 1, #spaceBodies do -- 168
			local body = spaceBodies[_index_0] -- 168
			do -- 169
				local _with_0 = body.children[1] -- 169
				if _with_0.actionCount == 0 then -- 170
					_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 171
				end -- 170
			end -- 169
		end -- 174
	else -- 176
		Audio:playStream("Audio/Dismantlism Daily.ogg", true, 0.2) -- 176
		spaceBack:perform(Sequence(Show(), Opacity(0.5, 1, 0), Hide())) -- 177
		dailyBack:perform(Sequence(Show(), Opacity(0.5, 0, 1))) -- 182
		for _index_0 = 1, #spaceBodies do -- 186
			local body = spaceBodies[_index_0] -- 186
			do -- 187
				local _with_0 = body.children[1] -- 187
				if _with_0.actionCount == 0 then -- 188
					_with_0:perform(Sequence(Show(), Scale(0.5, 1, 0, Ease.OutBack), Hide())) -- 189
				end -- 188
			end -- 187
		end -- 193
		for _index_0 = 1, #dailyBodies do -- 194
			local body = dailyBodies[_index_0] -- 194
			do -- 195
				local _with_0 = body.children[1] -- 195
				if _with_0.actionCount == 0 then -- 196
					_with_0:perform(Sequence(Show(), Scale(0.5, 0, 1, Ease.OutBack))) -- 197
				end -- 196
			end -- 195
		end -- 200
	end -- 149
end -- 148
local restartScene = nil -- 202
local gameEnded = false -- 203
local buildScene -- 204
buildScene = function() -- 204
	for i = 1, scene:count() do -- 205
		local name, file, position, angle -- 206
		do -- 206
			local _obj_0 = scene:get(i) -- 211
			name, file, position, angle = _obj_0.name, _obj_0.file, _obj_0.position, _obj_0.angle -- 206
			if position == nil then -- 209
				position = Vec2.zero -- 209
			end -- 209
			if angle == nil then -- 210
				angle = 0 -- 210
			end -- 210
		end -- 211
		local node = BodyEx(require(Path("Physics", file)), world, position, angle) -- 212
		world:addChild(node) -- 213
		if spaceItems[file] then -- 214
			node.data:each(function(self) -- 215
				self.tag = "space" -- 216
				self.children[1].tag = file -- 217
				spaceBodies[#spaceBodies + 1] = self -- 218
			end) -- 215
		elseif dailyItems[file] then -- 219
			node.data:each(function(self) -- 220
				self.tag = "daily" -- 221
				self.children[1].tag = file -- 222
				dailyBodies[#dailyBodies + 1] = self -- 223
			end) -- 220
		else -- 225
			node.data:each(function(self) -- 225
				if self.children and #self.children > 0 then -- 226
					self.children[1].tag = file -- 226
				end -- 226
			end) -- 225
		end -- 214
		if "removearea" == file then -- 228
			do -- 229
				local _with_0 = node.data.rect -- 229
				_with_0:addChild(SolidRect({ -- 230
					x = -200, -- 230
					y = -200, -- 230
					width = 400, -- 230
					height = 400, -- 230
					color = 0x66000000 -- 230
				})) -- 230
				_with_0:addChild((function() -- 231
					local _with_1 = Label("sarasa-mono-sc-regular", 80) -- 231
					_with_1.textAlign = "Center" -- 232
					_with_1.color = Color(0x66ffffff) -- 233
					_with_1.text = "Drag It\nHere" -- 234
					return _with_1 -- 231
				end)()) -- 231
				_with_0:slot("BodyEnter", function(body) -- 235
					if body.tag ~= "" and body.tag ~= (isSpace and "space" or "daily") then -- 236
						return -- 236
					end -- 236
					if body.group == 1 then -- 237
						return -- 237
					end -- 237
					body.group = 1 -- 238
					local _with_1 = body.children[1] -- 239
					_with_1:perform(Sequence(Spawn(Opacity(0.5, 1, 0), Scale(0.5, 1, 1.5, Ease.OutBack)), Event("Destroy"))) -- 240
					_with_1:slot("Destroy", function() -- 244
						do -- 245
							local _exp_0 = _with_1.tag -- 245
							if "star2" == _exp_0 or "pizza" == _exp_0 then -- 246
								score = score + 10 -- 247
								isSpace = not isSpace -- 248
								switchScene() -- 249
							elseif "quit" == _exp_0 then -- 250
								App:shutdown() -- 251
							elseif "get" == _exp_0 or "fish" == _exp_0 then -- 252
								score = score + 100 -- 253
							elseif "credit" == _exp_0 then -- 254
								score = score + 50 -- 255
								world:addChild((function() -- 256
									local _with_2 = Node() -- 256
									_with_2:addChild(Sprite("Model/duality.clip|window")) -- 257
									_with_2:addChild(Sprite("Model/duality.clip|credits1")) -- 258
									_with_2.position = body.position -- 259
									_with_2:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 260
									_with_2:slot("End", function() -- 269
										return _with_2:removeFromParent() -- 269
									end) -- 269
									return _with_2 -- 256
								end)()) -- 256
							else -- 271
								score = score + 10 -- 271
							end -- 271
						end -- 271
						scoreTxt.text = tostring(score) -- 272
						if score > 600 then -- 273
							gameEnded = true -- 274
							center:addChild((function() -- 275
								local _with_2 = Node() -- 275
								_with_2:addChild(Sprite("Model/duality.clip|window")) -- 276
								_with_2:addChild(Sprite("Model/duality.clip|win")) -- 277
								_with_2:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(3), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 278
								_with_2:slot("End", function() -- 287
									_with_2:removeFromParent() -- 288
									return restartScene() -- 289
								end) -- 287
								return _with_2 -- 275
							end)()) -- 275
						end -- 273
						if movingBody == body and moveJoint then -- 290
							moveJoint:destroy() -- 291
							moveJoint = nil -- 292
							movingBody = nil -- 293
						end -- 290
						return body:removeFromParent() -- 294
					end) -- 244
					return _with_1 -- 239
				end) -- 235
			end -- 229
		elseif "safearea" == file then -- 295
			do -- 296
				local _with_0 = node.data.rect -- 296
				_with_0:slot("BodyEnter", function(body) -- 297
					if body == movingBody then -- 298
						return -- 298
					end -- 298
					local tag = body.children[1].tag -- 299
					if (name == "safe1" and tag == "get") or (name == "safe2" and tag == "fish") then -- 300
						if not gameEnded then -- 302
							gameEnded = true -- 303
							return world:addChild((function() -- 304
								local _with_1 = Node() -- 304
								_with_1:addChild(Sprite("Model/duality.clip|window")) -- 305
								_with_1:addChild(Sprite("Model/duality.clip|lose")) -- 306
								_with_1.position = body.position -- 307
								_with_1:perform(Sequence(Spawn(Scale(0.5, 0, 1, Ease.OutBack), Opacity(0.5, 0, 1)), Delay(2), Scale(0.5, 1, 0, Ease.InBack), Event("End"))) -- 308
								_with_1:slot("End", function() -- 317
									return restartScene() -- 317
								end) -- 317
								return _with_1 -- 304
							end)()) -- 317
						end -- 302
					end -- 300
				end) -- 297
			end -- 296
		end -- 317
	end -- 317
end -- 204
buildScene() -- 319
switchScene() -- 320
restartScene = function() -- 322
	score = 0 -- 323
	scoreTxt.text = "0" -- 324
	isSpace = false -- 325
	gameEnded = false -- 326
	if moveJoint then -- 327
		moveJoint:destroy() -- 328
		moveJoint = nil -- 329
		movingBody = nil -- 330
	end -- 327
	world:removeFromParent() -- 331
	do -- 332
		local _with_0 = PhysicsWorld() -- 332
		_with_0.y = 405 -- 333
		_with_0:setShouldContact(0, 0, true) -- 334
		_with_0:setShouldContact(0, 1, false) -- 335
		_with_0:addTo(root) -- 336
		world = _with_0 -- 332
	end -- 332
	buildScene() -- 337
	return switchScene() -- 338
end -- 322
