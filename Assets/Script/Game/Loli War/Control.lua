-- [yue]: Control.yue
local tostring = _G.tostring -- 1
local pairs = _G.pairs -- 1
local _module_0 = Dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Group = Dora.Group -- 1
local Director = Dora.Director -- 1
local AlignNode = Dora.AlignNode -- 1
local Vec2 = Dora.Vec2 -- 1
local math = _G.math -- 1
local App = Dora.App -- 1
local HPWheel = require("UI.Control.HPWheel") -- 10
local LeftTouchPad = require("UI.View.LeftTouchPad") -- 11
local RightTouchPad = require("UI.View.RightTouchPad") -- 12
local RestartPad = require("UI.View.RestartPad") -- 13
local StartPanel = require("UI.Control.StartPanel") -- 14
local InputManager = require("InputManager") -- 15
local Trigger = InputManager.Trigger -- 17
local KeyBtnDown -- 19
KeyBtnDown = function(buttonName, keyName) -- 19
	return Trigger.Selector({ -- 21
		Trigger.ButtonDown(buttonName), -- 21
		Trigger.KeyDown(keyName) -- 22
	}) -- 23
end -- 19
local KeyBtnDownUp -- 25
KeyBtnDownUp = function(name, buttonName, keyName) -- 25
	return { -- 26
		[tostring(name) .. "Down"] = Trigger.Selector({ -- 27
			Trigger.ButtonDown(buttonName), -- 27
			Trigger.KeyDown(keyName) -- 28
		}), -- 26
		[tostring(name) .. "Up"] = Trigger.Selector({ -- 31
			Trigger.ButtonUp(buttonName), -- 31
			Trigger.KeyUp(keyName) -- 32
		}) -- 30
	} -- 33
end -- 25
local inputManager = InputManager.CreateManager({ -- 36
	Select = { -- 37
		Flandre = KeyBtnDown("dpleft", "A"), -- 37
		Villy = KeyBtnDown("dpdown", "S"), -- 38
		Dorothy = KeyBtnDown("dpright", "D") -- 39
	}, -- 36
	Control = (function() -- 41
		local _tab_0 = { -- 41
			Restart = KeyBtnDown("back", "Q") -- 41
		} -- 42
		local _obj_0 = KeyBtnDownUp("Left", "dpleft", "A") -- 42
		local _idx_0 = 1 -- 42
		for _key_0, _value_0 in pairs(_obj_0) do -- 42
			if _idx_0 == _key_0 then -- 42
				_tab_0[#_tab_0 + 1] = _value_0 -- 42
				_idx_0 = _idx_0 + 1 -- 42
			else -- 42
				_tab_0[_key_0] = _value_0 -- 42
			end -- 42
		end -- 42
		local _obj_1 = KeyBtnDownUp("Right", "dpright", "D") -- 43
		local _idx_1 = 1 -- 43
		for _key_0, _value_0 in pairs(_obj_1) do -- 43
			if _idx_1 == _key_0 then -- 43
				_tab_0[#_tab_0 + 1] = _value_0 -- 43
				_idx_1 = _idx_1 + 1 -- 43
			else -- 43
				_tab_0[_key_0] = _value_0 -- 43
			end -- 43
		end -- 43
		local _obj_2 = KeyBtnDownUp("Jump", "a", "K") -- 44
		local _idx_2 = 1 -- 44
		for _key_0, _value_0 in pairs(_obj_2) do -- 44
			if _idx_2 == _key_0 then -- 44
				_tab_0[#_tab_0 + 1] = _value_0 -- 44
				_idx_2 = _idx_2 + 1 -- 44
			else -- 44
				_tab_0[_key_0] = _value_0 -- 44
			end -- 44
		end -- 44
		local _obj_3 = KeyBtnDownUp("Attack", "b", "J") -- 45
		local _idx_3 = 1 -- 45
		for _key_0, _value_0 in pairs(_obj_3) do -- 45
			if _idx_3 == _key_0 then -- 45
				_tab_0[#_tab_0 + 1] = _value_0 -- 45
				_idx_3 = _idx_3 + 1 -- 45
			else -- 45
				_tab_0[_key_0] = _value_0 -- 45
			end -- 45
		end -- 45
		return _tab_0 -- 41
	end)() -- 40
}) -- 35
inputManager:pushContext("Control") -- 48
local Store = Data.store -- 50
local GroupPlayer = Store.GroupPlayer -- 51
local playerGroup = Group({ -- 53
	"hero", -- 53
	"unit" -- 53
}) -- 53
local updatePlayerControl -- 54
updatePlayerControl = function(key, flag) -- 54
	return playerGroup:each(function(self) -- 55
		if self.group == GroupPlayer then -- 55
			self.unit.data[key] = flag -- 55
		end -- 55
	end) -- 55
end -- 54
local showStartPanel -- 57
showStartPanel = function() -- 57
	return Director.ui:addChild((function() -- 58
		local _with_0 = AlignNode(true) -- 58
		_with_0:css('align-items: center; justify-content: center') -- 59
		_with_0:addChild((function() -- 60
			local align = AlignNode() -- 60
			align:css('width: 80%; height: 80%') -- 61
			align:addChild((function() -- 62
				local _with_1 = StartPanel() -- 62
				align:slot("AlignLayout", function(w, h) -- 63
					_with_1.position = Vec2(w / 2, h / 2) -- 64
					do -- 65
						local _tmp_0 = math.min(w / _with_1.node.width, h / _with_1.node.height) -- 65
						_with_1.scaleX = _tmp_0 -- 65
						_with_1.scaleY = _tmp_0 -- 65
					end -- 65
				end) -- 63
				return _with_1 -- 62
			end)()) -- 62
			return align -- 60
		end)()) -- 60
		return _with_0 -- 58
	end)()) -- 65
end -- 57
local inputNode -- 67
do -- 67
	local _with_0 = inputManager:getNode() -- 67
	_with_0:gslot("Input.LeftDown", function() -- 68
		return updatePlayerControl("keyLeft", true) -- 68
	end) -- 68
	_with_0:gslot("Input.LeftUp", function() -- 69
		return updatePlayerControl("keyLeft", false) -- 69
	end) -- 69
	_with_0:gslot("Input.RightDown", function() -- 70
		return updatePlayerControl("keyRight", true) -- 70
	end) -- 70
	_with_0:gslot("Input.RightUp", function() -- 71
		return updatePlayerControl("keyRight", false) -- 71
	end) -- 71
	_with_0:gslot("Input.JumpDown", function() -- 72
		return updatePlayerControl("keyUp", true) -- 72
	end) -- 72
	_with_0:gslot("Input.JumpUp", function() -- 73
		return updatePlayerControl("keyUp", false) -- 73
	end) -- 73
	_with_0:gslot("Input.AttackDown", function() -- 74
		return updatePlayerControl("keyF", true) -- 74
	end) -- 74
	_with_0:gslot("Input.AttackUp", function() -- 75
		return updatePlayerControl("keyF", false) -- 75
	end) -- 75
	_with_0:gslot("Input.Restart", function() -- 76
		Store.winner = -1 -- 77
		return showStartPanel() -- 78
	end) -- 76
	_with_0:gslot("InputManager.Select", function(on) -- 79
		if on then -- 79
			return inputManager:pushContext("Select") -- 80
		else -- 82
			return inputManager:popContext() -- 82
		end -- 79
	end) -- 79
	inputNode = _with_0 -- 67
end -- 67
local root = AlignNode(true) -- 84
root:css('flex-direction: column; justify-content: space-between') -- 85
root:addChild((function() -- 86
	local _with_0 = AlignNode() -- 86
	_with_0:css('width: 10; height: 10; margin-top: 50; margin-left: 60') -- 87
	_with_0:addChild(HPWheel()) -- 88
	return _with_0 -- 86
end)()) -- 86
root:addChild((function() -- 89
	local _with_0 = AlignNode() -- 89
	_with_0:css('margin: 0, 10, 40; height: 104; flex-direction: row; justify-content: space-between') -- 90
	local _exp_0 = App.platform -- 91
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 92
		_with_0:addChild((function() -- 93
			local _with_1 = AlignNode() -- 93
			_with_1:css('height: 104; width: 0') -- 94
			_with_1:addChild((function() -- 95
				local _with_2 = LeftTouchPad() -- 95
				_with_2:slot("KeyLeftUp", function() -- 96
					return inputManager:emitKeyUp("A") -- 96
				end) -- 96
				_with_2:slot("KeyLeftDown", function() -- 97
					return inputManager:emitKeyDown("A") -- 97
				end) -- 97
				_with_2:slot("KeyRightUp", function() -- 98
					return inputManager:emitKeyUp("D") -- 98
				end) -- 98
				_with_2:slot("KeyRightDown", function() -- 99
					return inputManager:emitKeyDown("D") -- 99
				end) -- 99
				return _with_2 -- 95
			end)()) -- 95
			return _with_1 -- 93
		end)()) -- 93
		_with_0:addChild((function() -- 100
			local _with_1 = AlignNode() -- 100
			_with_1:css('height: 104; width: 0') -- 101
			_with_1:addChild((function() -- 102
				local _with_2 = RightTouchPad() -- 102
				_with_2:slot("KeyFUp", function() -- 103
					return inputManager:emitKeyUp("J") -- 103
				end) -- 103
				_with_2:slot("KeyFDown", function() -- 104
					return inputManager:emitKeyDown("J") -- 104
				end) -- 104
				_with_2:slot("KeyUpUp", function() -- 105
					return inputManager:emitKeyUp("K") -- 105
				end) -- 105
				_with_2:slot("KeyUpDown", function() -- 106
					return inputManager:emitKeyDown("K") -- 106
				end) -- 106
				return _with_2 -- 102
			end)()) -- 102
			return _with_1 -- 100
		end)()) -- 100
	end -- 106
	return _with_0 -- 89
end)()) -- 89
root:addChild((function() -- 107
	local _with_0 = RestartPad() -- 107
	root:slot("AlignLayout", function(w, h) -- 108
		_with_0.position = Vec2(w - 10, h - 10) -- 109
	end) -- 108
	_with_0:slot("Tapped", function() -- 110
		Store.winner = -1 -- 111
		return showStartPanel() -- 112
	end) -- 110
	return _with_0 -- 107
end)()) -- 107
root:addTo(Director.ui) -- 113
showStartPanel() -- 114
return root -- 84
