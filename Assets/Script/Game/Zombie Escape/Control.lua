-- [yue]: Script/Game/Zombie Escape/Control.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = Dora.Group -- 1
local App = Dora.App -- 1
local Menu = Dora.Menu -- 1
local math = _G.math -- 1
local Vec2 = Dora.Vec2 -- 1
local Director = Dora.Director -- 1
local Keyboard = Dora.Keyboard -- 1
local Node = Dora.Node -- 1
local AlignNode = require("UI.Control.Basic.AlignNode") -- 10
local CircleButton = require("UI.Control.Basic.CircleButton") -- 11
local Store = Data.store -- 13
Store.controlPlayer = "KidW" -- 15
local playerGroup = Group({ -- 16
	"player" -- 16
}) -- 16
local updatePlayerControl -- 17
updatePlayerControl = function(key, flag) -- 17
	local player = playerGroup:find(function(self) -- 18
		return self.unit.tag == Store.controlPlayer -- 18
	end) -- 18
	if player then -- 18
		player.unit.data[key] = flag -- 19
	end -- 18
end -- 17
local uiScale = App.devicePixelRatio -- 20
do -- 22
	local _with_0 = AlignNode({ -- 22
		isRoot = true -- 22
	}) -- 22
	_with_0.visible = false -- 23
	_with_0:addChild((function() -- 24
		local _with_1 = AlignNode() -- 24
		_with_1.hAlign = "Left" -- 25
		_with_1.vAlign = "Bottom" -- 26
		_with_1:addChild((function() -- 27
			local _with_2 = Menu() -- 27
			_with_2:addChild((function() -- 28
				local _with_3 = CircleButton({ -- 29
					text = "Left", -- 29
					x = 20 * uiScale, -- 30
					y = 60 * uiScale, -- 31
					radius = 30 * uiScale, -- 32
					fontSize = math.floor(18 * uiScale) -- 33
				}) -- 28
				_with_3.anchor = Vec2.zero -- 35
				_with_3:slot("TapBegan", function() -- 36
					return updatePlayerControl("keyLeft", true) -- 36
				end) -- 36
				_with_3:slot("TapEnded", function() -- 37
					return updatePlayerControl("keyLeft", false) -- 37
				end) -- 37
				return _with_3 -- 28
			end)()) -- 28
			_with_2:addChild((function() -- 38
				local _with_3 = CircleButton({ -- 39
					text = "Right", -- 39
					x = 90 * uiScale, -- 40
					y = 60 * uiScale, -- 41
					radius = 30 * uiScale, -- 42
					fontSize = math.floor(18 * uiScale) -- 43
				}) -- 38
				_with_3.anchor = Vec2.zero -- 45
				_with_3:slot("TapBegan", function() -- 46
					return updatePlayerControl("keyRight", true) -- 46
				end) -- 46
				_with_3:slot("TapEnded", function() -- 47
					return updatePlayerControl("keyRight", false) -- 47
				end) -- 47
				return _with_3 -- 38
			end)()) -- 38
			return _with_2 -- 27
		end)()) -- 27
		return _with_1 -- 24
	end)()) -- 24
	_with_0:addChild((function() -- 48
		local _with_1 = AlignNode() -- 48
		_with_1.hAlign = "Right" -- 49
		_with_1.vAlign = "Bottom" -- 50
		_with_1:addChild((function() -- 51
			local _with_2 = Menu() -- 51
			_with_2:addChild((function() -- 52
				local _with_3 = CircleButton({ -- 53
					text = "Jump", -- 53
					x = -80 * uiScale, -- 54
					y = 60 * uiScale, -- 55
					radius = 30 * uiScale, -- 56
					fontSize = math.floor(18 * uiScale) -- 57
				}) -- 52
				_with_3.anchor = Vec2.zero -- 59
				_with_3:slot("TapBegan", function() -- 60
					return updatePlayerControl("keyUp", true) -- 60
				end) -- 60
				_with_3:slot("TapEnded", function() -- 61
					return updatePlayerControl("keyUp", false) -- 61
				end) -- 61
				return _with_3 -- 52
			end)()) -- 52
			_with_2:addChild((function() -- 62
				local _with_3 = CircleButton({ -- 63
					text = "Shoot", -- 63
					x = -150 * uiScale, -- 64
					y = 60 * uiScale, -- 65
					radius = 30 * uiScale, -- 66
					fontSize = math.floor(18 * uiScale) -- 67
				}) -- 62
				_with_3.anchor = Vec2.zero -- 69
				_with_3:slot("TapBegan", function() -- 70
					return updatePlayerControl("keyShoot", true) -- 70
				end) -- 70
				_with_3:slot("TapEnded", function() -- 71
					return updatePlayerControl("keyShoot", false) -- 71
				end) -- 71
				return _with_3 -- 62
			end)()) -- 62
			return _with_2 -- 51
		end)()) -- 51
		return _with_1 -- 48
	end)()) -- 48
	_with_0:addTo((function() -- 72
		local _with_1 = Director.ui -- 72
		_with_1.renderGroup = true -- 73
		return _with_1 -- 72
	end)()) -- 72
end -- 22
Store.keyboardEnabled = false -- 75
local keyboardControl -- 76
keyboardControl = function() -- 76
	if not Store.keyboardEnabled then -- 77
		return -- 77
	end -- 77
	updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 78
	updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 79
	updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 80
	return updatePlayerControl("keyShoot", Keyboard:isKeyPressed("J")) -- 81
end -- 76
local _with_0 = Node() -- 83
_with_0:schedule(keyboardControl) -- 84
return _with_0 -- 83
