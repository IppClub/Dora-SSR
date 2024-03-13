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
local AlignNode = require("UI.Control.Basic.AlignNode") -- 2
local Rectangle = require("UI.View.Shape.Rectangle") -- 3
local Circle = require("UI.View.Shape.Circle") -- 4
local Star = require("UI.View.Shape.Star") -- 5
local CircleButton = require("UI.Control.Basic.CircleButton") -- 6
local Store = Data.store -- 8
Store.controlPlayer = "KidW" -- 10
local playerGroup = Group({ -- 11
	"player" -- 11
}) -- 11
local updatePlayerControl -- 12
updatePlayerControl = function(key, flag) -- 12
	do -- 13
		local player = playerGroup:find(function(self) -- 13
			return self.unit.tag == Store.controlPlayer -- 13
		end) -- 13
		if player then -- 13
			player.unit.data[key] = flag -- 14
		end -- 13
	end -- 13
end -- 12
local uiScale = App.devicePixelRatio -- 15
do -- 17
	local _with_0 = AlignNode({ -- 17
		isRoot = true -- 17
	}) -- 17
	_with_0.visible = false -- 18
	_with_0:addChild((function() -- 19
		local _with_1 = AlignNode() -- 19
		_with_1.hAlign = "Left" -- 20
		_with_1.vAlign = "Bottom" -- 21
		_with_1:addChild((function() -- 22
			local _with_2 = Menu() -- 22
			_with_2:addChild((function() -- 23
				local _with_3 = CircleButton({ -- 24
					text = "Left", -- 24
					x = 20 * uiScale, -- 25
					y = 60 * uiScale, -- 26
					radius = 30 * uiScale, -- 27
					fontSize = math.floor(18 * uiScale) -- 28
				}) -- 23
				_with_3.anchor = Vec2.zero -- 30
				_with_3:slot("TapBegan", function() -- 31
					return updatePlayerControl("keyLeft", true) -- 31
				end) -- 31
				_with_3:slot("TapEnded", function() -- 32
					return updatePlayerControl("keyLeft", false) -- 32
				end) -- 32
				return _with_3 -- 23
			end)()) -- 23
			_with_2:addChild((function() -- 33
				local _with_3 = CircleButton({ -- 34
					text = "Right", -- 34
					x = 90 * uiScale, -- 35
					y = 60 * uiScale, -- 36
					radius = 30 * uiScale, -- 37
					fontSize = math.floor(18 * uiScale) -- 38
				}) -- 33
				_with_3.anchor = Vec2.zero -- 40
				_with_3:slot("TapBegan", function() -- 41
					return updatePlayerControl("keyRight", true) -- 41
				end) -- 41
				_with_3:slot("TapEnded", function() -- 42
					return updatePlayerControl("keyRight", false) -- 42
				end) -- 42
				return _with_3 -- 33
			end)()) -- 33
			return _with_2 -- 22
		end)()) -- 22
		return _with_1 -- 19
	end)()) -- 19
	_with_0:addChild((function() -- 43
		local _with_1 = AlignNode() -- 43
		_with_1.hAlign = "Right" -- 44
		_with_1.vAlign = "Bottom" -- 45
		_with_1:addChild((function() -- 46
			local _with_2 = Menu() -- 46
			_with_2:addChild((function() -- 47
				local _with_3 = CircleButton({ -- 48
					text = "Jump", -- 48
					x = -80 * uiScale, -- 49
					y = 60 * uiScale, -- 50
					radius = 30 * uiScale, -- 51
					fontSize = math.floor(18 * uiScale) -- 52
				}) -- 47
				_with_3.anchor = Vec2.zero -- 54
				_with_3:slot("TapBegan", function() -- 55
					return updatePlayerControl("keyUp", true) -- 55
				end) -- 55
				_with_3:slot("TapEnded", function() -- 56
					return updatePlayerControl("keyUp", false) -- 56
				end) -- 56
				return _with_3 -- 47
			end)()) -- 47
			_with_2:addChild((function() -- 57
				local _with_3 = CircleButton({ -- 58
					text = "Shoot", -- 58
					x = -150 * uiScale, -- 59
					y = 60 * uiScale, -- 60
					radius = 30 * uiScale, -- 61
					fontSize = math.floor(18 * uiScale) -- 62
				}) -- 57
				_with_3.anchor = Vec2.zero -- 64
				_with_3:slot("TapBegan", function() -- 65
					return updatePlayerControl("keyShoot", true) -- 65
				end) -- 65
				_with_3:slot("TapEnded", function() -- 66
					return updatePlayerControl("keyShoot", false) -- 66
				end) -- 66
				return _with_3 -- 57
			end)()) -- 57
			return _with_2 -- 46
		end)()) -- 46
		return _with_1 -- 43
	end)()) -- 43
	_with_0:addTo((function() -- 67
		local _with_1 = Director.ui -- 67
		_with_1.renderGroup = true -- 68
		return _with_1 -- 67
	end)()) -- 67
end -- 17
Store.keyboardEnabled = false -- 70
local keyboardControl -- 71
keyboardControl = function() -- 71
	if not Store.keyboardEnabled then -- 72
		return -- 72
	end -- 72
	updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 73
	updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 74
	updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 75
	return updatePlayerControl("keyShoot", Keyboard:isKeyPressed("J")) -- 76
end -- 71
local _with_0 = Node() -- 78
_with_0:schedule(keyboardControl) -- 79
return _with_0 -- 78
