-- [yue]: Control.yue
local tostring = _G.tostring -- 1
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
KeyBtnDown = function(name, buttonName, keyName) -- 19
	return { -- 21
		name = name, -- 21
		trigger = Trigger.Selector({ -- 23
			Trigger.ButtonDown(buttonName), -- 23
			Trigger.KeyDown(keyName) -- 24
		}) -- 22
	} -- 25
end -- 19
local KeyBtnDownUp -- 27
KeyBtnDownUp = function(name, buttonName, keyName) -- 27
	return { -- 29
		{ -- 29
			name = tostring(name) .. "Down", -- 29
			trigger = Trigger.Selector({ -- 31
				Trigger.ButtonDown(buttonName), -- 31
				Trigger.KeyDown(keyName) -- 32
			}) -- 30
		}, -- 29
		{ -- 34
			name = tostring(name) .. "Up", -- 34
			trigger = Trigger.Selector({ -- 36
				Trigger.ButtonUp(buttonName), -- 36
				Trigger.KeyUp(keyName) -- 37
			}) -- 35
		} -- 34
	} -- 38
end -- 27
local inputManager = InputManager.CreateManager({ -- 41
	{ -- 41
		name = "Select", -- 41
		actions = { -- 43
			KeyBtnDown("Flandre", "dpleft", "A"), -- 43
			KeyBtnDown("Villy", "dpdown", "S"), -- 44
			KeyBtnDown("Dorothy", "dpright", "D") -- 45
		} -- 42
	}, -- 41
	{ -- 46
		name = "Control", -- 46
		actions = (function() -- 48
			local _tab_0 = { -- 48
				KeyBtnDown("Restart", "back", "Q") -- 48
			} -- 49
			local _obj_0 = KeyBtnDownUp("Left", "dpleft", "A") -- 49
			local _idx_0 = #_tab_0 + 1 -- 49
			for _index_0 = 1, #_obj_0 do -- 49
				local _value_0 = _obj_0[_index_0] -- 49
				_tab_0[_idx_0] = _value_0 -- 49
				_idx_0 = _idx_0 + 1 -- 49
			end -- 49
			local _obj_1 = KeyBtnDownUp("Right", "dpright", "D") -- 50
			local _idx_1 = #_tab_0 + 1 -- 50
			for _index_0 = 1, #_obj_1 do -- 50
				local _value_0 = _obj_1[_index_0] -- 50
				_tab_0[_idx_1] = _value_0 -- 50
				_idx_1 = _idx_1 + 1 -- 50
			end -- 50
			local _obj_2 = KeyBtnDownUp("Jump", "a", "K") -- 51
			local _idx_2 = #_tab_0 + 1 -- 51
			for _index_0 = 1, #_obj_2 do -- 51
				local _value_0 = _obj_2[_index_0] -- 51
				_tab_0[_idx_2] = _value_0 -- 51
				_idx_2 = _idx_2 + 1 -- 51
			end -- 51
			local _obj_3 = KeyBtnDownUp("Attack", "b", "J") -- 52
			local _idx_3 = #_tab_0 + 1 -- 52
			for _index_0 = 1, #_obj_3 do -- 52
				local _value_0 = _obj_3[_index_0] -- 52
				_tab_0[_idx_3] = _value_0 -- 52
				_idx_3 = _idx_3 + 1 -- 52
			end -- 52
			return _tab_0 -- 48
		end)() -- 47
	} -- 46
}) -- 40
inputManager:pushContext("Control") -- 55
local Store = Data.store -- 57
local GroupPlayer = Store.GroupPlayer -- 58
local playerGroup = Group({ -- 60
	"hero", -- 60
	"unit" -- 60
}) -- 60
local updatePlayerControl -- 61
updatePlayerControl = function(key, flag) -- 61
	return playerGroup:each(function(self) -- 62
		if self.group == GroupPlayer then -- 62
			self.unit.data[key] = flag -- 62
		end -- 62
	end) -- 62
end -- 61
local showStartPanel -- 64
showStartPanel = function() -- 64
	return Director.ui:addChild((function() -- 65
		local _with_0 = AlignNode(true) -- 65
		_with_0:css('align-items: center; justify-content: center') -- 66
		_with_0:addChild((function() -- 67
			local align = AlignNode() -- 67
			align:css('width: 80%; height: 80%') -- 68
			align:addChild((function() -- 69
				local _with_1 = StartPanel() -- 69
				align:slot("AlignLayout", function(w, h) -- 70
					_with_1.position = Vec2(w / 2, h / 2) -- 71
					do -- 72
						local _tmp_0 = math.min(w / _with_1.node.width, h / _with_1.node.height) -- 72
						_with_1.scaleX = _tmp_0 -- 72
						_with_1.scaleY = _tmp_0 -- 72
					end -- 72
				end) -- 70
				return _with_1 -- 69
			end)()) -- 69
			return align -- 67
		end)()) -- 67
		return _with_0 -- 65
	end)()) -- 72
end -- 64
local inputNode -- 74
do -- 74
	local _with_0 = inputManager:getNode() -- 74
	_with_0:gslot("Input.LeftDown", function() -- 75
		return updatePlayerControl("keyLeft", true) -- 75
	end) -- 75
	_with_0:gslot("Input.LeftUp", function() -- 76
		return updatePlayerControl("keyLeft", false) -- 76
	end) -- 76
	_with_0:gslot("Input.RightDown", function() -- 77
		return updatePlayerControl("keyRight", true) -- 77
	end) -- 77
	_with_0:gslot("Input.RightUp", function() -- 78
		return updatePlayerControl("keyRight", false) -- 78
	end) -- 78
	_with_0:gslot("Input.JumpDown", function() -- 79
		return updatePlayerControl("keyUp", true) -- 79
	end) -- 79
	_with_0:gslot("Input.JumpUp", function() -- 80
		return updatePlayerControl("keyUp", false) -- 80
	end) -- 80
	_with_0:gslot("Input.AttackDown", function() -- 81
		return updatePlayerControl("keyF", true) -- 81
	end) -- 81
	_with_0:gslot("Input.AttackUp", function() -- 82
		return updatePlayerControl("keyF", false) -- 82
	end) -- 82
	_with_0:gslot("Input.Restart", function() -- 83
		Store.winner = -1 -- 84
		return showStartPanel() -- 85
	end) -- 83
	_with_0:gslot("InputManager.Select", function(on) -- 86
		if on then -- 86
			return inputManager:pushContext("Select") -- 87
		else -- 89
			return inputManager:popContext() -- 89
		end -- 86
	end) -- 86
	inputNode = _with_0 -- 74
end -- 74
local root = AlignNode(true) -- 91
root:css('flex-direction: column; justify-content: space-between') -- 92
root:addChild((function() -- 93
	local _with_0 = AlignNode() -- 93
	_with_0:css('width: 10; height: 10; margin-top: 50; margin-left: 60') -- 94
	_with_0:addChild(HPWheel()) -- 95
	return _with_0 -- 93
end)()) -- 93
root:addChild((function() -- 96
	local _with_0 = AlignNode() -- 96
	_with_0:css('margin: 0, 10, 40; height: 104; flex-direction: row; justify-content: space-between') -- 97
	local _exp_0 = App.platform -- 98
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 99
		_with_0:addChild((function() -- 100
			local _with_1 = AlignNode() -- 100
			_with_1:css('height: 104; width: 0') -- 101
			_with_1:addChild((function() -- 102
				local _with_2 = LeftTouchPad() -- 102
				_with_2:slot("KeyLeftUp", function() -- 103
					return inputManager:emitKeyUp("A") -- 103
				end) -- 103
				_with_2:slot("KeyLeftDown", function() -- 104
					return inputManager:emitKeyDown("A") -- 104
				end) -- 104
				_with_2:slot("KeyRightUp", function() -- 105
					return inputManager:emitKeyUp("D") -- 105
				end) -- 105
				_with_2:slot("KeyRightDown", function() -- 106
					return inputManager:emitKeyDown("D") -- 106
				end) -- 106
				return _with_2 -- 102
			end)()) -- 102
			return _with_1 -- 100
		end)()) -- 100
		_with_0:addChild((function() -- 107
			local _with_1 = AlignNode() -- 107
			_with_1:css('height: 104; width: 0') -- 108
			_with_1:addChild((function() -- 109
				local _with_2 = RightTouchPad() -- 109
				_with_2:slot("KeyFUp", function() -- 110
					return inputManager:emitKeyUp("J") -- 110
				end) -- 110
				_with_2:slot("KeyFDown", function() -- 111
					return inputManager:emitKeyDown("J") -- 111
				end) -- 111
				_with_2:slot("KeyUpUp", function() -- 112
					return inputManager:emitKeyUp("K") -- 112
				end) -- 112
				_with_2:slot("KeyUpDown", function() -- 113
					return inputManager:emitKeyDown("K") -- 113
				end) -- 113
				return _with_2 -- 109
			end)()) -- 109
			return _with_1 -- 107
		end)()) -- 107
	end -- 113
	return _with_0 -- 96
end)()) -- 96
root:addChild((function() -- 114
	local _with_0 = RestartPad() -- 114
	root:slot("AlignLayout", function(w, h) -- 115
		_with_0.position = Vec2(w - 10, h - 10) -- 116
	end) -- 115
	_with_0:slot("Tapped", function() -- 117
		Store.winner = -1 -- 118
		return showStartPanel() -- 119
	end) -- 117
	return _with_0 -- 114
end)()) -- 114
root:addTo(Director.ui) -- 120
showStartPanel() -- 121
return root -- 91
