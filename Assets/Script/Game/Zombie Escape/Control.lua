-- [yue]: Script/Game/Zombie Escape/Control.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = dora.Group -- 1
local App = dora.App -- 1
local Menu = dora.Menu -- 1
local math = _G.math -- 1
local Vec2 = dora.Vec2 -- 1
local Director = dora.Director -- 1
local Keyboard = dora.Keyboard -- 1
local Node = dora.Node -- 1
local AlignNode = require("UI.Control.Basic.AlignNode") -- 10
local Rectangle = require("UI.View.Shape.Rectangle") -- 11
local Circle = require("UI.View.Shape.Circle") -- 12
local Star = require("UI.View.Shape.Star") -- 13
local CircleButton = require("UI.Control.Basic.CircleButton") -- 14
local Store = Data.store -- 16
Store.controlPlayer = "KidW" -- 18
local playerGroup = Group({ -- 19
	"player" -- 19
}) -- 19
local updatePlayerControl -- 20
updatePlayerControl = function(key, flag) -- 20
	local player = playerGroup:find(function(self) -- 21
		return self.unit.tag == Store.controlPlayer -- 21
	end) -- 21
	if player then -- 21
		player.unit.data[key] = flag -- 22
	end -- 21
end -- 20
local uiScale = App.devicePixelRatio -- 23
do -- 25
	local _with_0 = AlignNode({ -- 25
		isRoot = true -- 25
	}) -- 25
	_with_0.visible = false -- 26
	_with_0:addChild((function() -- 27
		local _with_1 = AlignNode() -- 27
		_with_1.hAlign = "Left" -- 28
		_with_1.vAlign = "Bottom" -- 29
		_with_1:addChild((function() -- 30
			local _with_2 = Menu() -- 30
			_with_2:addChild((function() -- 31
				local _with_3 = CircleButton({ -- 32
					text = "Left", -- 32
					x = 20 * uiScale, -- 33
					y = 60 * uiScale, -- 34
					radius = 30 * uiScale, -- 35
					fontSize = math.floor(18 * uiScale) -- 36
				}) -- 31
				_with_3.anchor = Vec2.zero -- 38
				_with_3:slot("TapBegan", function() -- 39
					return updatePlayerControl("keyLeft", true) -- 39
				end) -- 39
				_with_3:slot("TapEnded", function() -- 40
					return updatePlayerControl("keyLeft", false) -- 40
				end) -- 40
				return _with_3 -- 31
			end)()) -- 31
			_with_2:addChild((function() -- 41
				local _with_3 = CircleButton({ -- 42
					text = "Right", -- 42
					x = 90 * uiScale, -- 43
					y = 60 * uiScale, -- 44
					radius = 30 * uiScale, -- 45
					fontSize = math.floor(18 * uiScale) -- 46
				}) -- 41
				_with_3.anchor = Vec2.zero -- 48
				_with_3:slot("TapBegan", function() -- 49
					return updatePlayerControl("keyRight", true) -- 49
				end) -- 49
				_with_3:slot("TapEnded", function() -- 50
					return updatePlayerControl("keyRight", false) -- 50
				end) -- 50
				return _with_3 -- 41
			end)()) -- 41
			return _with_2 -- 30
		end)()) -- 30
		return _with_1 -- 27
	end)()) -- 27
	_with_0:addChild((function() -- 51
		local _with_1 = AlignNode() -- 51
		_with_1.hAlign = "Right" -- 52
		_with_1.vAlign = "Bottom" -- 53
		_with_1:addChild((function() -- 54
			local _with_2 = Menu() -- 54
			_with_2:addChild((function() -- 55
				local _with_3 = CircleButton({ -- 56
					text = "Jump", -- 56
					x = -80 * uiScale, -- 57
					y = 60 * uiScale, -- 58
					radius = 30 * uiScale, -- 59
					fontSize = math.floor(18 * uiScale) -- 60
				}) -- 55
				_with_3.anchor = Vec2.zero -- 62
				_with_3:slot("TapBegan", function() -- 63
					return updatePlayerControl("keyUp", true) -- 63
				end) -- 63
				_with_3:slot("TapEnded", function() -- 64
					return updatePlayerControl("keyUp", false) -- 64
				end) -- 64
				return _with_3 -- 55
			end)()) -- 55
			_with_2:addChild((function() -- 65
				local _with_3 = CircleButton({ -- 66
					text = "Shoot", -- 66
					x = -150 * uiScale, -- 67
					y = 60 * uiScale, -- 68
					radius = 30 * uiScale, -- 69
					fontSize = math.floor(18 * uiScale) -- 70
				}) -- 65
				_with_3.anchor = Vec2.zero -- 72
				_with_3:slot("TapBegan", function() -- 73
					return updatePlayerControl("keyShoot", true) -- 73
				end) -- 73
				_with_3:slot("TapEnded", function() -- 74
					return updatePlayerControl("keyShoot", false) -- 74
				end) -- 74
				return _with_3 -- 65
			end)()) -- 65
			return _with_2 -- 54
		end)()) -- 54
		return _with_1 -- 51
	end)()) -- 51
	_with_0:addTo((function() -- 75
		local _with_1 = Director.ui -- 75
		_with_1.renderGroup = true -- 76
		return _with_1 -- 75
	end)()) -- 75
end -- 25
Store.keyboardEnabled = false -- 78
local keyboardControl -- 79
keyboardControl = function() -- 79
	if not Store.keyboardEnabled then -- 80
		return -- 80
	end -- 80
	updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 81
	updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 82
	updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 83
	return updatePlayerControl("keyShoot", Keyboard:isKeyPressed("J")) -- 84
end -- 79
local _with_0 = Node() -- 86
_with_0:schedule(keyboardControl) -- 87
return _with_0 -- 86
