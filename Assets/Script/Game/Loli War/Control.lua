-- [yue]: Script/Game/Loli War/Control.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = dora.Group -- 1
local App = dora.App -- 1
local Node = dora.Node -- 1
local Keyboard = dora.Keyboard -- 1
local Director = dora.Director -- 1
local HPWheel = require("UI.Control.HPWheel") -- 2
local AlignNode = require("UI.Control.Basic.AlignNode") -- 3
local LeftTouchPad = require("UI.View.LeftTouchPad") -- 4
local RightTouchPad = require("UI.View.RightTouchPad") -- 5
local RestartPad = require("UI.View.RestartPad") -- 6
local StartPanel = require("UI.Control.StartPanel") -- 7
local Store = Data.store -- 9
local GroupPlayer = Store.GroupPlayer -- 10
local playerGroup = Group({ -- 12
	"hero", -- 12
	"unit" -- 12
}) -- 12
local updatePlayerControl -- 13
updatePlayerControl = function(key, flag) -- 13
	return playerGroup:each(function(self) -- 14
		if self.group == GroupPlayer then -- 14
			self.unit.data[key] = flag -- 14
		end -- 14
	end) -- 14
end -- 13
local root = AlignNode({ -- 16
	isRoot = true -- 16
}) -- 16
root:addChild(HPWheel()) -- 17
do -- 18
	local _exp_0 = App.platform -- 18
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 19
		root:addChild((function() -- 20
			local _with_0 = LeftTouchPad() -- 20
			_with_0:slot("KeyLeftUp", function() -- 21
				return updatePlayerControl("keyLeft", false) -- 21
			end) -- 21
			_with_0:slot("KeyLeftDown", function() -- 22
				return updatePlayerControl("keyLeft", true) -- 22
			end) -- 22
			_with_0:slot("KeyRightUp", function() -- 23
				return updatePlayerControl("keyRight", false) -- 23
			end) -- 23
			_with_0:slot("KeyRightDown", function() -- 24
				return updatePlayerControl("keyRight", true) -- 24
			end) -- 24
			return _with_0 -- 20
		end)()) -- 20
		root:addChild((function() -- 25
			local _with_0 = RightTouchPad() -- 25
			_with_0:slot("KeyFUp", function() -- 26
				return updatePlayerControl("keyF", false) -- 26
			end) -- 26
			_with_0:slot("KeyFDown", function() -- 27
				return updatePlayerControl("keyF", true) -- 27
			end) -- 27
			_with_0:slot("KeyUpUp", function() -- 28
				return updatePlayerControl("keyUp", false) -- 28
			end) -- 28
			_with_0:slot("KeyUpDown", function() -- 29
				return updatePlayerControl("keyUp", true) -- 29
			end) -- 29
			return _with_0 -- 25
		end)()) -- 25
	elseif "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 30
		root:addChild((function() -- 31
			local _with_0 = Node() -- 31
			_with_0:schedule(function() -- 32
				updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 33
				updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 34
				updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 35
				return updatePlayerControl("keyF", Keyboard:isKeyPressed("J")) -- 36
			end) -- 32
			return _with_0 -- 31
		end)()) -- 31
	end -- 36
end -- 36
local showStartPanel -- 37
showStartPanel = function() -- 37
	root:addChild((function() -- 38
		local _with_0 = StartPanel() -- 38
		_with_0:slot("AlignLayout", function(w) -- 39
			w = w * 0.6 -- 40
			local width = 210 * 2 * App.devicePixelRatio -- 41
			if w < width then -- 42
				do -- 42
					local _tmp_0 = w / width -- 42
					_with_0.scaleX = _tmp_0 -- 42
					_with_0.scaleY = _tmp_0 -- 42
				end -- 42
			end -- 42
		end) -- 39
		return _with_0 -- 38
	end)()) -- 38
	return root:alignLayout() -- 43
end -- 37
root:addChild((function() -- 44
	local _with_0 = RestartPad() -- 44
	_with_0:slot("Tapped", function() -- 45
		Store.winner = -1 -- 46
		return showStartPanel() -- 47
	end) -- 45
	return _with_0 -- 44
end)()) -- 44
root:addTo(Director.ui) -- 48
showStartPanel() -- 49
return root -- 16
