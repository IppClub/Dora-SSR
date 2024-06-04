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
		_with_1:css("\n			width: auto;\n			height: 60;\n			margin: 0, 20, 40;\n			flex-direction: row;\n			justify-content: space-between\n		") -- 24
		_with_1:addChild((function() -- 31
			local _with_2 = AlignNode() -- 31
			_with_2:css('height: 60; width: 0') -- 32
			_with_2:addChild((function() -- 33
				local _with_3 = Menu() -- 33
				_with_3.anchor = Vec2.zero -- 34
				_with_3.size = Size(130, 60) -- 35
				_with_3:addChild((function() -- 36
					local _with_4 = CircleButton({ -- 37
						text = "Left", -- 37
						radius = 60, -- 38
						fontSize = math.floor(36) -- 39
					}) -- 36
					_with_4.scaleX = 0.5 -- 41
					_with_4.scaleY = 0.5 -- 41
					_with_4.anchor = Vec2.zero -- 42
					_with_4:slot("TapBegan", function() -- 43
						return updatePlayerControl("keyLeft", true) -- 43
					end) -- 43
					_with_4:slot("TapEnded", function() -- 44
						return updatePlayerControl("keyLeft", false) -- 44
					end) -- 44
					return _with_4 -- 36
				end)()) -- 36
				_with_3:addChild((function() -- 45
					local _with_4 = CircleButton({ -- 46
						text = "Right", -- 46
						x = 70, -- 47
						radius = 60, -- 48
						fontSize = math.floor(36) -- 49
					}) -- 45
					_with_4.scaleX = 0.5 -- 51
					_with_4.scaleY = 0.5 -- 51
					_with_4.anchor = Vec2.zero -- 52
					_with_4:slot("TapBegan", function() -- 53
						return updatePlayerControl("keyRight", true) -- 53
					end) -- 53
					_with_4:slot("TapEnded", function() -- 54
						return updatePlayerControl("keyRight", false) -- 54
					end) -- 54
					return _with_4 -- 45
				end)()) -- 45
				return _with_3 -- 33
			end)()) -- 33
			return _with_2 -- 31
		end)()) -- 31
		_with_1:addChild((function() -- 55
			local _with_2 = AlignNode() -- 55
			_with_2:css('height: 60; width: 0') -- 56
			_with_2:addChild((function() -- 57
				local _with_3 = Menu() -- 57
				_with_3.anchor = Vec2(1, 0) -- 58
				_with_3.size = Size(130, 60) -- 59
				_with_3:addChild((function() -- 60
					local _with_4 = CircleButton({ -- 61
						text = "Jump", -- 61
						radius = 60, -- 62
						fontSize = math.floor(36) -- 63
					}) -- 60
					_with_4.scaleX = 0.5 -- 65
					_with_4.scaleY = 0.5 -- 65
					_with_4.anchor = Vec2.zero -- 66
					_with_4:slot("TapBegan", function() -- 67
						return updatePlayerControl("keyUp", true) -- 67
					end) -- 67
					_with_4:slot("TapEnded", function() -- 68
						return updatePlayerControl("keyUp", false) -- 68
					end) -- 68
					return _with_4 -- 60
				end)()) -- 60
				_with_3:addChild((function() -- 69
					local _with_4 = CircleButton({ -- 70
						text = "Shoot", -- 70
						x = 70, -- 71
						radius = 60, -- 72
						fontSize = math.floor(36) -- 73
					}) -- 69
					_with_4.scaleX = 0.5 -- 75
					_with_4.scaleY = 0.5 -- 75
					_with_4.anchor = Vec2.zero -- 76
					_with_4:slot("TapBegan", function() -- 77
						return updatePlayerControl("keyShoot", true) -- 77
					end) -- 77
					_with_4:slot("TapEnded", function() -- 78
						return updatePlayerControl("keyShoot", false) -- 78
					end) -- 78
					return _with_4 -- 69
				end)()) -- 69
				return _with_3 -- 57
			end)()) -- 57
			return _with_2 -- 55
		end)()) -- 55
		return _with_1 -- 23
	end)()) -- 23
	_with_0:addTo((function() -- 79
		local _with_1 = Director.ui -- 79
		_with_1.renderGroup = true -- 80
		return _with_1 -- 79
	end)()) -- 79
end -- 20
Store.keyboardEnabled = false -- 82
local keyboardControl -- 83
keyboardControl = function() -- 83
	if not Store.keyboardEnabled then -- 84
		return -- 84
	end -- 84
	updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 85
	updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 86
	updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 87
	return updatePlayerControl("keyShoot", Keyboard:isKeyPressed("J")) -- 88
end -- 83
local _with_0 = Node() -- 90
_with_0:schedule(keyboardControl) -- 91
return _with_0 -- 90
