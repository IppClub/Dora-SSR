-- [yue]: Control.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = Dora.Group -- 1
local AlignNode = Dora.AlignNode -- 1
local Menu = Dora.Menu -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local math = _G.math -- 1
local Director = Dora.Director -- 1
local Keyboard = Dora.Keyboard -- 1
local Node = Dora.Node -- 1
local CircleButton = require("UI.Control.Basic.CircleButton") -- 10
local Store = Data.store -- 12
Store.controlPlayer = "KidW" -- 14
local playerGroup = Group({ -- 15
	"player" -- 15
}) -- 15
local updatePlayerControl -- 16
updatePlayerControl = function(key, flag) -- 16
	local player = playerGroup:find(function(self) -- 17
		return self.unit.tag == Store.controlPlayer -- 17
	end) -- 17
	if player then -- 17
		player.unit.data[key] = flag -- 18
	end -- 17
end -- 16
do -- 20
	local _with_0 = AlignNode(true) -- 20
	_with_0:css('flex-direction: column-reverse') -- 21
	_with_0.visible = false -- 22
	_with_0:addChild((function() -- 23
		local _with_1 = AlignNode() -- 23
		_with_1:css("\n			width: auto;\n			height: 60;\n			margin-bottom: 10;\n			margin-left: 10;\n			margin-right: 10;\n			flex-direction: row;\n			justify-content: space-between\n		") -- 24
		_with_1:addChild((function() -- 33
			local _with_2 = AlignNode() -- 33
			_with_2:css('height: 60; width: 0') -- 34
			_with_2:addChild((function() -- 35
				local _with_3 = Menu() -- 35
				_with_3.anchor = Vec2.zero -- 36
				_with_3.size = Size(130, 60) -- 37
				_with_3:addChild((function() -- 38
					local _with_4 = CircleButton({ -- 39
						text = "Left", -- 39
						radius = 60, -- 40
						fontSize = math.floor(36) -- 41
					}) -- 38
					_with_4.scaleX = 0.5 -- 43
					_with_4.scaleY = 0.5 -- 43
					_with_4.anchor = Vec2.zero -- 44
					_with_4:slot("TapBegan", function() -- 45
						return updatePlayerControl("keyLeft", true) -- 45
					end) -- 45
					_with_4:slot("TapEnded", function() -- 46
						return updatePlayerControl("keyLeft", false) -- 46
					end) -- 46
					return _with_4 -- 38
				end)()) -- 38
				_with_3:addChild((function() -- 47
					local _with_4 = CircleButton({ -- 48
						text = "Right", -- 48
						x = 70, -- 49
						radius = 60, -- 50
						fontSize = math.floor(36) -- 51
					}) -- 47
					_with_4.scaleX = 0.5 -- 53
					_with_4.scaleY = 0.5 -- 53
					_with_4.anchor = Vec2.zero -- 54
					_with_4:slot("TapBegan", function() -- 55
						return updatePlayerControl("keyRight", true) -- 55
					end) -- 55
					_with_4:slot("TapEnded", function() -- 56
						return updatePlayerControl("keyRight", false) -- 56
					end) -- 56
					return _with_4 -- 47
				end)()) -- 47
				return _with_3 -- 35
			end)()) -- 35
			return _with_2 -- 33
		end)()) -- 33
		_with_1:addChild((function() -- 57
			local _with_2 = AlignNode() -- 57
			_with_2:css('height: 60; width: 0') -- 58
			_with_2:addChild((function() -- 59
				local _with_3 = Menu() -- 59
				_with_3.anchor = Vec2(1, 0) -- 60
				_with_3.size = Size(130, 60) -- 61
				_with_3:addChild((function() -- 62
					local _with_4 = CircleButton({ -- 63
						text = "Jump", -- 63
						radius = 60, -- 64
						fontSize = math.floor(36) -- 65
					}) -- 62
					_with_4.scaleX = 0.5 -- 67
					_with_4.scaleY = 0.5 -- 67
					_with_4.anchor = Vec2.zero -- 68
					_with_4:slot("TapBegan", function() -- 69
						return updatePlayerControl("keyUp", true) -- 69
					end) -- 69
					_with_4:slot("TapEnded", function() -- 70
						return updatePlayerControl("keyUp", false) -- 70
					end) -- 70
					return _with_4 -- 62
				end)()) -- 62
				_with_3:addChild((function() -- 71
					local _with_4 = CircleButton({ -- 72
						text = "Shoot", -- 72
						x = 70, -- 73
						radius = 60, -- 74
						fontSize = math.floor(36) -- 75
					}) -- 71
					_with_4.scaleX = 0.5 -- 77
					_with_4.scaleY = 0.5 -- 77
					_with_4.anchor = Vec2.zero -- 78
					_with_4:slot("TapBegan", function() -- 79
						return updatePlayerControl("keyShoot", true) -- 79
					end) -- 79
					_with_4:slot("TapEnded", function() -- 80
						return updatePlayerControl("keyShoot", false) -- 80
					end) -- 80
					return _with_4 -- 71
				end)()) -- 71
				return _with_3 -- 59
			end)()) -- 59
			return _with_2 -- 57
		end)()) -- 57
		return _with_1 -- 23
	end)()) -- 23
	_with_0:addTo((function() -- 81
		local _with_1 = Director.ui -- 81
		_with_1.renderGroup = true -- 82
		return _with_1 -- 81
	end)()) -- 81
end -- 20
Store.keyboardEnabled = false -- 84
local keyboardControl -- 85
keyboardControl = function() -- 85
	if not Store.keyboardEnabled then -- 86
		return -- 86
	end -- 86
	updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 87
	updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 88
	updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 89
	return updatePlayerControl("keyShoot", Keyboard:isKeyPressed("J")) -- 90
end -- 85
local _with_0 = Node() -- 92
_with_0:schedule(keyboardControl) -- 93
return _with_0 -- 92
