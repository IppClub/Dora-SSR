-- [yue]: Control.yue
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
local inputManager = InputManager.CreateManager({ -- 20
	{ -- 20
		name = "Select", -- 20
		actions = { -- 22
			{ -- 22
				name = "Flandre", -- 22
				trigger = Trigger.Selector({ -- 24
					Trigger.ButtonDown("dpleft"), -- 24
					Trigger.KeyDown("A") -- 25
				}) -- 23
			}, -- 22
			{ -- 27
				name = "Villy", -- 27
				trigger = Trigger.Selector({ -- 29
					Trigger.ButtonDown("dpdown"), -- 29
					Trigger.KeyDown("S") -- 30
				}) -- 28
			}, -- 27
			{ -- 32
				name = "Dorothy", -- 32
				trigger = Trigger.Selector({ -- 34
					Trigger.ButtonDown("dpright"), -- 34
					Trigger.KeyDown("D") -- 35
				}) -- 33
			} -- 32
		} -- 21
	}, -- 20
	{ -- 37
		name = "Control", -- 37
		actions = { -- 39
			{ -- 39
				name = "LeftDown", -- 39
				trigger = Trigger.Selector({ -- 41
					Trigger.ButtonDown("dpleft"), -- 41
					Trigger.KeyDown("A") -- 42
				}) -- 40
			}, -- 39
			{ -- 44
				name = "RightDown", -- 44
				trigger = Trigger.Selector({ -- 46
					Trigger.ButtonDown("dpright"), -- 46
					Trigger.KeyDown("D") -- 47
				}) -- 45
			}, -- 44
			{ -- 49
				name = "JumpDown", -- 49
				trigger = Trigger.Selector({ -- 51
					Trigger.ButtonDown("a"), -- 51
					Trigger.KeyDown("K") -- 52
				}) -- 50
			}, -- 49
			{ -- 54
				name = "AttackDown", -- 54
				trigger = Trigger.Selector({ -- 56
					Trigger.ButtonDown("b"), -- 56
					Trigger.KeyDown("J") -- 57
				}) -- 55
			}, -- 54
			{ -- 59
				name = "LeftUp", -- 59
				trigger = Trigger.Selector({ -- 61
					Trigger.ButtonUp("dpleft"), -- 61
					Trigger.KeyUp("A") -- 62
				}) -- 60
			}, -- 59
			{ -- 64
				name = "RightUp", -- 64
				trigger = Trigger.Selector({ -- 66
					Trigger.ButtonUp("dpright"), -- 66
					Trigger.KeyUp("D") -- 67
				}) -- 65
			}, -- 64
			{ -- 69
				name = "JumpUp", -- 69
				trigger = Trigger.Selector({ -- 71
					Trigger.ButtonUp("a"), -- 71
					Trigger.KeyUp("K") -- 72
				}) -- 70
			}, -- 69
			{ -- 74
				name = "AttackUp", -- 74
				trigger = Trigger.Selector({ -- 76
					Trigger.ButtonUp("x"), -- 76
					Trigger.KeyUp("J") -- 77
				}) -- 75
			}, -- 74
			{ -- 79
				name = "Restart", -- 79
				trigger = Trigger.Selector({ -- 81
					Trigger.ButtonDown("back"), -- 81
					Trigger.KeyDown("Q") -- 82
				}) -- 80
			} -- 79
		} -- 38
	} -- 37
}) -- 19
inputManager:pushContext("Control") -- 85
local Store = Data.store -- 87
local GroupPlayer = Store.GroupPlayer -- 88
local playerGroup = Group({ -- 90
	"hero", -- 90
	"unit" -- 90
}) -- 90
local updatePlayerControl -- 91
updatePlayerControl = function(key, flag) -- 91
	return playerGroup:each(function(self) -- 92
		if self.group == GroupPlayer then -- 92
			self.unit.data[key] = flag -- 92
		end -- 92
	end) -- 92
end -- 91
local showStartPanel -- 94
showStartPanel = function() -- 94
	return Director.ui:addChild((function() -- 95
		local _with_0 = AlignNode(true) -- 95
		_with_0:css('align-items: center; justify-content: center') -- 96
		_with_0:addChild((function() -- 97
			local align = AlignNode() -- 97
			align:css('width: 80%; height: 80%') -- 98
			align:addChild((function() -- 99
				local _with_1 = StartPanel() -- 99
				align:slot("AlignLayout", function(w, h) -- 100
					_with_1.position = Vec2(w / 2, h / 2) -- 101
					do -- 102
						local _tmp_0 = math.min(w / _with_1.node.width, h / _with_1.node.height) -- 102
						_with_1.scaleX = _tmp_0 -- 102
						_with_1.scaleY = _tmp_0 -- 102
					end -- 102
				end) -- 100
				return _with_1 -- 99
			end)()) -- 99
			return align -- 97
		end)()) -- 97
		return _with_0 -- 95
	end)()) -- 102
end -- 94
local inputNode -- 104
do -- 104
	local _with_0 = inputManager:getNode() -- 104
	_with_0:gslot("Input.LeftDown", function() -- 105
		return updatePlayerControl("keyLeft", true) -- 105
	end) -- 105
	_with_0:gslot("Input.LeftUp", function() -- 106
		return updatePlayerControl("keyLeft", false) -- 106
	end) -- 106
	_with_0:gslot("Input.RightDown", function() -- 107
		return updatePlayerControl("keyRight", true) -- 107
	end) -- 107
	_with_0:gslot("Input.RightUp", function() -- 108
		return updatePlayerControl("keyRight", false) -- 108
	end) -- 108
	_with_0:gslot("Input.JumpDown", function() -- 109
		return updatePlayerControl("keyUp", true) -- 109
	end) -- 109
	_with_0:gslot("Input.JumpUp", function() -- 110
		return updatePlayerControl("keyUp", false) -- 110
	end) -- 110
	_with_0:gslot("Input.AttackDown", function() -- 111
		return updatePlayerControl("keyF", true) -- 111
	end) -- 111
	_with_0:gslot("Input.AttackUp", function() -- 112
		return updatePlayerControl("keyF", false) -- 112
	end) -- 112
	_with_0:gslot("Input.Restart", function() -- 113
		Store.winner = -1 -- 114
		return showStartPanel() -- 115
	end) -- 113
	_with_0:gslot("InputManager.Select", function(on) -- 116
		if on then -- 116
			return inputManager:pushContext("Select") -- 117
		else -- 119
			return inputManager:popContext() -- 119
		end -- 116
	end) -- 116
	inputNode = _with_0 -- 104
end -- 104
local root = AlignNode(true) -- 121
root:css('flex-direction: column; justify-content: space-between') -- 122
root:addChild((function() -- 123
	local _with_0 = AlignNode() -- 123
	_with_0:css('width: 10; height: 10; margin-top: 50; margin-left: 60') -- 124
	_with_0:addChild(HPWheel()) -- 125
	return _with_0 -- 123
end)()) -- 123
root:addChild((function() -- 126
	local _with_0 = AlignNode() -- 126
	_with_0:css('margin: 0, 10, 40; height: 104; flex-direction: row; justify-content: space-between') -- 127
	local _exp_0 = App.platform -- 128
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 129
		_with_0:addChild((function() -- 130
			local _with_1 = AlignNode() -- 130
			_with_1:css('height: 104; width: 0') -- 131
			_with_1:addChild((function() -- 132
				local _with_2 = LeftTouchPad() -- 132
				_with_2:slot("KeyLeftUp", function() -- 133
					return inputManager:emitKeyUp("A") -- 133
				end) -- 133
				_with_2:slot("KeyLeftDown", function() -- 134
					return inputManager:emitKeyDown("A") -- 134
				end) -- 134
				_with_2:slot("KeyRightUp", function() -- 135
					return inputManager:emitKeyUp("D") -- 135
				end) -- 135
				_with_2:slot("KeyRightDown", function() -- 136
					return inputManager:emitKeyDown("D") -- 136
				end) -- 136
				return _with_2 -- 132
			end)()) -- 132
			return _with_1 -- 130
		end)()) -- 130
		_with_0:addChild((function() -- 137
			local _with_1 = AlignNode() -- 137
			_with_1:css('height: 104; width: 0') -- 138
			_with_1:addChild((function() -- 139
				local _with_2 = RightTouchPad() -- 139
				_with_2:slot("KeyFUp", function() -- 140
					return inputManager:emitKeyUp("J") -- 140
				end) -- 140
				_with_2:slot("KeyFDown", function() -- 141
					return inputManager:emitKeyDown("J") -- 141
				end) -- 141
				_with_2:slot("KeyUpUp", function() -- 142
					return inputManager:emitKeyUp("K") -- 142
				end) -- 142
				_with_2:slot("KeyUpDown", function() -- 143
					return inputManager:emitKeyDown("K") -- 143
				end) -- 143
				return _with_2 -- 139
			end)()) -- 139
			return _with_1 -- 137
		end)()) -- 137
	end -- 143
	return _with_0 -- 126
end)()) -- 126
root:addChild((function() -- 144
	local _with_0 = RestartPad() -- 144
	root:slot("AlignLayout", function(w, h) -- 145
		_with_0.position = Vec2(w - 10, h - 10) -- 146
	end) -- 145
	_with_0:slot("Tapped", function() -- 147
		Store.winner = -1 -- 148
		return showStartPanel() -- 149
	end) -- 147
	return _with_0 -- 144
end)()) -- 144
root:addTo(Director.ui) -- 150
showStartPanel() -- 151
return root -- 121
