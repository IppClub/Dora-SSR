-- [yue]: Script/Game/Loli War/Control.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = dora.Group -- 1
local App = dora.App -- 1
local Node = dora.Node -- 1
local Keyboard = dora.Keyboard -- 1
local Director = dora.Director -- 1
local HPWheel = require("UI.Control.HPWheel") -- 10
local AlignNode = require("UI.Control.Basic.AlignNode") -- 11
local LeftTouchPad = require("UI.View.LeftTouchPad") -- 12
local RightTouchPad = require("UI.View.RightTouchPad") -- 13
local RestartPad = require("UI.View.RestartPad") -- 14
local StartPanel = require("UI.Control.StartPanel") -- 15
local Store = Data.store -- 17
local GroupPlayer = Store.GroupPlayer -- 18
local playerGroup = Group({ -- 20
	"hero", -- 20
	"unit" -- 20
}) -- 20
local updatePlayerControl -- 21
updatePlayerControl = function(key, flag) -- 21
	return playerGroup:each(function(self) -- 22
		if self.group == GroupPlayer then -- 22
			self.unit.data[key] = flag -- 22
		end -- 22
	end) -- 22
end -- 21
local root = AlignNode({ -- 24
	isRoot = true -- 24
}) -- 24
root:addChild(HPWheel()) -- 25
do -- 26
	local _exp_0 = App.platform -- 26
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 27
		root:addChild((function() -- 28
			local _with_0 = LeftTouchPad() -- 28
			_with_0:slot("KeyLeftUp", function() -- 29
				return updatePlayerControl("keyLeft", false) -- 29
			end) -- 29
			_with_0:slot("KeyLeftDown", function() -- 30
				return updatePlayerControl("keyLeft", true) -- 30
			end) -- 30
			_with_0:slot("KeyRightUp", function() -- 31
				return updatePlayerControl("keyRight", false) -- 31
			end) -- 31
			_with_0:slot("KeyRightDown", function() -- 32
				return updatePlayerControl("keyRight", true) -- 32
			end) -- 32
			return _with_0 -- 28
		end)()) -- 28
		root:addChild((function() -- 33
			local _with_0 = RightTouchPad() -- 33
			_with_0:slot("KeyFUp", function() -- 34
				return updatePlayerControl("keyF", false) -- 34
			end) -- 34
			_with_0:slot("KeyFDown", function() -- 35
				return updatePlayerControl("keyF", true) -- 35
			end) -- 35
			_with_0:slot("KeyUpUp", function() -- 36
				return updatePlayerControl("keyUp", false) -- 36
			end) -- 36
			_with_0:slot("KeyUpDown", function() -- 37
				return updatePlayerControl("keyUp", true) -- 37
			end) -- 37
			return _with_0 -- 33
		end)()) -- 33
	elseif "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 38
		root:addChild((function() -- 39
			local _with_0 = Node() -- 39
			_with_0:schedule(function() -- 40
				updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 41
				updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 42
				updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 43
				return updatePlayerControl("keyF", Keyboard:isKeyPressed("J")) -- 44
			end) -- 40
			return _with_0 -- 39
		end)()) -- 39
	end -- 44
end -- 44
local showStartPanel -- 45
showStartPanel = function() -- 45
	root:addChild((function() -- 46
		local _with_0 = StartPanel() -- 46
		_with_0:slot("AlignLayout", function(w) -- 47
			w = w * 0.6 -- 48
			local width = 210 * 2 * App.devicePixelRatio -- 49
			if w < width then -- 50
				do -- 50
					local _tmp_0 = w / width -- 50
					_with_0.scaleX = _tmp_0 -- 50
					_with_0.scaleY = _tmp_0 -- 50
				end -- 50
			end -- 50
		end) -- 47
		return _with_0 -- 46
	end)()) -- 46
	return root:alignLayout() -- 51
end -- 45
root:addChild((function() -- 52
	local _with_0 = RestartPad() -- 52
	_with_0:slot("Tapped", function() -- 53
		Store.winner = -1 -- 54
		return showStartPanel() -- 55
	end) -- 53
	return _with_0 -- 52
end)()) -- 52
root:addTo(Director.ui) -- 56
showStartPanel() -- 57
return root -- 24
