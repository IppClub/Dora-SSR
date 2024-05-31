-- [yue]: Control.yue
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = Dora.Group -- 1
local AlignNode = Dora.AlignNode -- 1
local App = Dora.App -- 1
local Node = Dora.Node -- 1
local Keyboard = Dora.Keyboard -- 1
local Director = Dora.Director -- 1
local Vec2 = Dora.Vec2 -- 1
local math = _G.math -- 1
local HPWheel = require("UI.Control.HPWheel") -- 10
local LeftTouchPad = require("UI.View.LeftTouchPad") -- 11
local RightTouchPad = require("UI.View.RightTouchPad") -- 12
local RestartPad = require("UI.View.RestartPad") -- 13
local StartPanel = require("UI.Control.StartPanel") -- 14
local Store = Data.store -- 16
local GroupPlayer = Store.GroupPlayer -- 17
local playerGroup = Group({ -- 19
	"hero", -- 19
	"unit" -- 19
}) -- 19
local updatePlayerControl -- 20
updatePlayerControl = function(key, flag) -- 20
	return playerGroup:each(function(self) -- 21
		if self.group == GroupPlayer then -- 21
			self.unit.data[key] = flag -- 21
		end -- 21
	end) -- 21
end -- 20
local root = AlignNode(true) -- 23
root:css('flex-direction: column; justify-content: space-between') -- 24
root:addChild((function() -- 25
	local _with_0 = AlignNode() -- 25
	_with_0:css('width: 10; height: 10; margin-top: 75; margin-left: 75') -- 26
	_with_0:addChild(HPWheel()) -- 27
	return _with_0 -- 25
end)()) -- 25
root:addChild((function() -- 28
	local _with_0 = AlignNode() -- 28
	_with_0:css('margin-bottom: 10; height: 104; flex-direction: row; justify-content: space-between') -- 29
	local _exp_0 = App.platform -- 30
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 31
		_with_0:addChild((function() -- 32
			local _with_1 = AlignNode() -- 32
			_with_1:css('height: 104; width: 0') -- 33
			_with_1:addChild((function() -- 34
				local _with_2 = LeftTouchPad() -- 34
				_with_2:slot("KeyLeftUp", function() -- 35
					return updatePlayerControl("keyLeft", false) -- 35
				end) -- 35
				_with_2:slot("KeyLeftDown", function() -- 36
					return updatePlayerControl("keyLeft", true) -- 36
				end) -- 36
				_with_2:slot("KeyRightUp", function() -- 37
					return updatePlayerControl("keyRight", false) -- 37
				end) -- 37
				_with_2:slot("KeyRightDown", function() -- 38
					return updatePlayerControl("keyRight", true) -- 38
				end) -- 38
				return _with_2 -- 34
			end)()) -- 34
			return _with_1 -- 32
		end)()) -- 32
		_with_0:addChild((function() -- 39
			local _with_1 = AlignNode() -- 39
			_with_1:css('height: 104; width: 0') -- 40
			_with_1:addChild((function() -- 41
				local _with_2 = RightTouchPad() -- 41
				_with_2:slot("KeyFUp", function() -- 42
					return updatePlayerControl("keyF", false) -- 42
				end) -- 42
				_with_2:slot("KeyFDown", function() -- 43
					return updatePlayerControl("keyF", true) -- 43
				end) -- 43
				_with_2:slot("KeyUpUp", function() -- 44
					return updatePlayerControl("keyUp", false) -- 44
				end) -- 44
				_with_2:slot("KeyUpDown", function() -- 45
					return updatePlayerControl("keyUp", true) -- 45
				end) -- 45
				return _with_2 -- 41
			end)()) -- 41
			return _with_1 -- 39
		end)()) -- 39
	elseif "macOS" == _exp_0 or "Windows" == _exp_0 or "Linux" == _exp_0 then -- 46
		_with_0:addChild((function() -- 47
			local _with_1 = Node() -- 47
			_with_1:schedule(function() -- 48
				updatePlayerControl("keyLeft", Keyboard:isKeyPressed("A")) -- 49
				updatePlayerControl("keyRight", Keyboard:isKeyPressed("D")) -- 50
				updatePlayerControl("keyUp", Keyboard:isKeyPressed("K")) -- 51
				return updatePlayerControl("keyF", Keyboard:isKeyPressed("J")) -- 52
			end) -- 48
			return _with_1 -- 47
		end)()) -- 47
	end -- 52
	return _with_0 -- 28
end)()) -- 28
root.controllerEnabled = true -- 53
local updateButton -- 54
updateButton = function(id, buttonName, down) -- 54
	if not (id == 0) then -- 55
		return -- 55
	end -- 55
	if 'dpleft' == buttonName then -- 57
		return updatePlayerControl("keyLeft", down) -- 57
	elseif 'dpright' == buttonName then -- 58
		return updatePlayerControl("keyRight", down) -- 58
	elseif 'b' == buttonName then -- 59
		return updatePlayerControl("keyUp", down) -- 59
	elseif 'a' == buttonName then -- 60
		return updatePlayerControl("keyF", down) -- 60
	end -- 60
end -- 54
root:slot("ButtonDown", function(id, buttonName) -- 61
	return updateButton(id, buttonName, true) -- 61
end) -- 61
root:slot("ButtonUp", function(id, buttonName) -- 62
	return updateButton(id, buttonName, false) -- 62
end) -- 62
local showStartPanel -- 63
showStartPanel = function() -- 63
	return Director.ui:addChild((function() -- 64
		local _with_0 = AlignNode(true) -- 64
		_with_0:css('align-items: center; justify-content: center') -- 65
		_with_0:addChild((function() -- 66
			local align = AlignNode() -- 66
			align:css('width: 80%; height: 80%') -- 67
			align:addChild((function() -- 68
				local _with_1 = StartPanel() -- 68
				align:slot("AlignLayout", function(w, h) -- 69
					_with_1.position = Vec2(w / 2, h / 2) -- 70
					do -- 71
						local _tmp_0 = math.min(w / _with_1.node.width, h / _with_1.node.height) -- 71
						_with_1.scaleX = _tmp_0 -- 71
						_with_1.scaleY = _tmp_0 -- 71
					end -- 71
				end) -- 69
				return _with_1 -- 68
			end)()) -- 68
			return align -- 66
		end)()) -- 66
		return _with_0 -- 64
	end)()) -- 71
end -- 63
root:addChild((function() -- 72
	local _with_0 = RestartPad() -- 72
	root:slot("AlignLayout", function(w, h) -- 73
		_with_0.position = Vec2(w - 10, h - 10) -- 74
	end) -- 73
	_with_0:slot("Tapped", function() -- 75
		Store.winner = -1 -- 76
		return showStartPanel() -- 77
	end) -- 75
	return _with_0 -- 72
end)()) -- 72
root:addTo(Director.ui) -- 78
showStartPanel() -- 79
return root -- 23
