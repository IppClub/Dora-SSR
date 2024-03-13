-- [yue]: Script/Game/Zombie Escape/Debug.yue
local _module_1 = dora.Platformer -- 1
local Data = _module_1.Data -- 1
local Group = dora.Group -- 1
local App = dora.App -- 1
local _module_0 = dora.ImGui -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local Vec2 = dora.Vec2 -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local tostring = _G.tostring -- 1
local SameLine = _module_0.SameLine -- 1
local Button = _module_0.Button -- 1
local Rect = dora.Rect -- 1
local Size = dora.Size -- 1
local Entity = dora.Entity -- 1
local DragFloat = _module_0.DragFloat -- 1
local Checkbox = _module_0.Checkbox -- 1
local Separator = _module_0.Separator -- 1
local RadioButton = _module_0.RadioButton -- 1
local Director = dora.Director -- 1
local table = _G.table -- 1
local Text = _module_0.Text -- 1
local Observer = dora.Observer -- 1
local Star = require("UI.View.Shape.Star") -- 2
local Store = Data.store -- 4
local world, ZombieLayer, PlayerGroup = Store.world, Store.ZombieLayer, Store.PlayerGroup -- 5
local playerGroup = Group({ -- 11
	"player", -- 11
	"unit" -- 11
}) -- 11
local zombieGroup = Group({ -- 12
	"zombie", -- 12
	"unit" -- 12
}) -- 12
local userControl = false -- 13
local playerChoice = 1 -- 14
local controlChoice -- 15
do -- 15
	local _exp_0 = App.platform -- 15
	if "iOS" == _exp_0 or "Android" == _exp_0 then -- 16
		controlChoice = 0 -- 16
	else -- 17
		controlChoice = 1 -- 17
	end -- 17
end -- 17
local camZoom = world.camera.zoom -- 18
local decisions = { } -- 19
local showDecisionTrace = false -- 20
local lastDecisionTree = "" -- 21
world:schedule(function() -- 22
	local width, height -- 23
	do -- 23
		local _obj_0 = App.visualSize -- 23
		width, height = _obj_0.width, _obj_0.height -- 23
	end -- 23
	SetNextWindowPos(Vec2(width - 250, 10), "FirstUseEver") -- 24
	SetNextWindowSize(Vec2(240, userControl and 500 or 300)) -- 25
	Begin("Zombie Game Demo", { -- 26
		"NoResize", -- 26
		"NoSavedSettings" -- 26
	}, function() -- 26
		TextWrapped("Zombie Killed: " .. tostring(Store.zombieKilled)) -- 27
		SameLine() -- 28
		if Button("Army") then -- 29
			for i = 0, 10 do -- 30
				local available = false -- 31
				local pos = Vec2.zero -- 32
				while not available do -- 33
					pos = Vec2(App.rand % 2400 - 1200, -430) -- 34
					available = not world:query(Rect(pos, Size(5, 5)), function(self) -- 35
						return self.group == Data.groupTerrain -- 35
					end) -- 35
				end -- 35
				Entity({ -- 37
					unitDef = "Unit_Zombie" .. tostring(App.rand % 2 + 1), -- 37
					order = ZombieLayer, -- 38
					position = pos, -- 39
					group = PlayerGroup, -- 40
					faceRight = App.rand % 2 == 0, -- 41
					stared = true -- 42
				}) -- 36
			end -- 42
		end -- 29
		local changed -- 43
		changed, camZoom = DragFloat("Zoom", camZoom, 0.01, 0.5, 2, "%.2f") -- 43
		if changed then -- 44
			world.camera.zoom = camZoom -- 44
		end -- 44
		playerGroup:each(function(self) -- 45
			return TextWrapped(tostring(self.unit.tag) .. " HP: " .. tostring(self.hp)) -- 45
		end) -- 45
		local result -- 46
		changed, result = Checkbox("Physics Debug", world.showDebug) -- 46
		if changed then -- 47
			world.showDebug = result -- 47
		end -- 47
		changed, showDecisionTrace = Checkbox("AI Debug", showDecisionTrace) -- 48
		if changed then -- 49
			playerGroup:each(function(self) -- 50
				self.unit.receivingDecisionTrace = showDecisionTrace -- 50
			end) -- 50
		end -- 49
		changed, userControl = Checkbox("Take Control", userControl) -- 51
		if userControl then -- 52
			if Store.controlPlayer == "Zombie" and not playerGroup:each(function(self) -- 54
				if self.unit.tag == "Zombie" then -- 55
					if self.hp <= 0 then -- 56
						self.player = nil -- 57
						self.unit.children.last:removeFromParent() -- 58
						self.unit.decisionTree = "" -- 59
						self.unit.tag = "ZombieDead" -- 60
						return false -- 61
					else -- 62
						return true -- 62
					end -- 56
				end -- 55
				return false -- 63
			end) then -- 53
				zombieGroup:each(function(self) -- 64
					if self.hp <= 0 then -- 65
						return false -- 65
					end -- 65
					self.player = true -- 66
					self.zombie = nil -- 67
					do -- 68
						local _with_0 = self.unit -- 68
						_with_0.tag = "Zombie" -- 69
						_with_0.group = PlayerGroup -- 70
						_with_0.decisionTree = "AI_PlayerControl" -- 71
						_with_0.sensity = 0 -- 72
						_with_0:addChild(Star({ -- 74
							y = 100, -- 74
							size = 18, -- 75
							borderColor = 0xffff8800, -- 76
							fillColor = 0x66ff8800, -- 77
							fillOrder = 1, -- 78
							lineOrder = 2 -- 79
						})) -- 73
						world.camera.followTarget = _with_0 -- 68
					end -- 68
					return true -- 81
				end) -- 64
			end -- 53
			Separator() -- 82
			local pressedA, choice = RadioButton("Male", playerChoice, 0) -- 83
			if pressedA then -- 84
				playerChoice = choice -- 84
			end -- 84
			local pressedB -- 85
			pressedB, choice = RadioButton("Female", playerChoice, 1) -- 85
			if pressedB then -- 86
				playerChoice = choice -- 86
			end -- 86
			local pressedC -- 87
			pressedC, choice = RadioButton("Zombie", playerChoice, 2) -- 87
			if pressedC then -- 88
				playerChoice = choice -- 88
			end -- 88
			if pressedA or pressedB or pressedC or changed then -- 89
				if 0 == playerChoice then -- 91
					Store.controlPlayer = "KidM" -- 91
				elseif 1 == playerChoice then -- 92
					Store.controlPlayer = "KidW" -- 92
				elseif 2 == playerChoice then -- 93
					Store.controlPlayer = "Zombie" -- 93
				end -- 93
				if Store.controlPlayer == "Zombie" and not playerGroup:each(function(self) -- 95
					return self.unit.tag == "Zombie" -- 95
				end) then -- 94
					zombieGroup:each(function(self) -- 96
						self.player = true -- 97
						self.zombie = nil -- 98
						do -- 99
							local _with_0 = self.unit -- 99
							_with_0.tag = "Zombie" -- 100
							_with_0.group = PlayerGroup -- 101
							_with_0:addChild(Star({ -- 103
								y = 100, -- 103
								size = 18, -- 104
								borderColor = 0xffff8800, -- 105
								fillColor = 0x66ff8800, -- 106
								fillOrder = 1, -- 107
								lineOrder = 2 -- 108
							})) -- 102
						end -- 99
						return true -- 110
					end) -- 96
				end -- 94
				playerGroup:each(function(self) -- 111
					if self.unit.tag == Store.controlPlayer then -- 112
						self.unit.decisionTree = "AI_PlayerControl" -- 113
						self.unit.sensity = 0 -- 114
						world.camera.followTarget = self.unit -- 115
					else -- 117
						do -- 117
							local _exp_0 = self.unit.tag -- 117
							if "KidM" == _exp_0 then -- 118
								self.unit.decisionTree = "AI_KidFollow" -- 118
							elseif "KidW" == _exp_0 then -- 119
								self.unit.decisionTree = "AI_KidSearch" -- 119
							elseif "Zombie" == _exp_0 then -- 120
								self.unit.decisionTree = "AI_Zombie" -- 120
							end -- 120
						end -- 120
						self.unit.sensity = 0.1 -- 121
					end -- 112
				end) -- 111
			end -- 89
			if changed then -- 122
				Store.keyboardEnabled = controlChoice == 1 -- 123
				Director.ui.children.first.visible = controlChoice == 0 -- 124
			end -- 122
			Separator() -- 125
			TextWrapped((function() -- 126
				if controlChoice == 1 then -- 126
					return "Keyboard: Left(A), Right(D), Shoot(J), Jump(K)" -- 127
				else -- 128
					return "TouchPad: Use buttons in lower screen to control unit." -- 128
				end -- 126
			end)()) -- 126
			Separator() -- 129
			pressedA, choice = RadioButton("TouchPad", controlChoice, 0) -- 130
			if pressedA then -- 131
				controlChoice = choice -- 132
				Store.keyboardEnabled = false -- 133
				Director.ui:eachChild(function(self) -- 134
					self.visible = true -- 134
				end) -- 134
			end -- 131
			pressedB, choice = RadioButton("Keyboard", controlChoice, 1) -- 135
			if pressedB then -- 136
				controlChoice = choice -- 137
				Store.keyboardEnabled = true -- 138
				Director.ui.children.first.visible = false -- 139
			end -- 136
		elseif changed then -- 140
			playerGroup:each(function(self) -- 141
				do -- 142
					local _exp_0 = self.unit.tag -- 142
					if "KidM" == _exp_0 then -- 143
						self.unit.decisionTree = "AI_KidFollow" -- 143
					elseif "KidW" == _exp_0 then -- 144
						self.unit.decisionTree = "AI_KidSearch" -- 144
					elseif "Zombie" == _exp_0 then -- 145
						self.unit.decisionTree = "AI_Zombie" -- 145
					end -- 145
				end -- 145
				self.unit.sensity = 0.1 -- 146
			end) -- 141
			Store.keyboardEnabled = false -- 147
			Director.ui.children.first.visible = false -- 148
		end -- 52
	end) -- 26
	local target = world.camera.followTarget -- 150
	if target then -- 151
		local player = target.entity -- 152
		local decisionTrace = player.decisionTrace -- 153
		local lastDecision = decisions[#decisions] -- 154
		if lastDecision ~= decisionTrace then -- 155
			decisions[#decisions + 1] = decisionTrace -- 156
		end -- 155
		if #decisions > 5 then -- 157
			table.remove(decisions, 1) -- 157
		end -- 157
		lastDecisionTree = target.decisionTree -- 158
	end -- 151
	if showDecisionTrace then -- 160
		SetNextWindowPos(Vec2(width / 2 - 200, 10), "FirstUseEver") -- 161
		SetNextWindowSize(Vec2(400, 160), "FirstUseEver") -- 162
		return Begin("Decision Trace (" .. tostring(lastDecisionTree) .. ")", { -- 163
			"NoSavedSettings" -- 163
		}, function() -- 163
			return Text(table.concat(decisions, "\n")) -- 164
		end) -- 164
	end -- 160
end) -- 22
do -- 166
	local _with_0 = Observer("Add", { -- 166
		"group", -- 166
		"unit", -- 166
		"player", -- 166
		"stared" -- 166
	}) -- 166
	_with_0:watch(function(self, group, unit) -- 167
		unit:addChild(Star({ -- 169
			y = 100, -- 169
			size = 18, -- 170
			borderColor = 0xff66ccff, -- 171
			fillColor = 0x6666ccff, -- 172
			fillOrder = 1, -- 173
			lineOrder = 2 -- 174
		})) -- 168
		return false -- 175
	end) -- 167
end -- 166
local _with_0 = Observer("Add", { -- 177
	"unit", -- 177
	"player" -- 177
}) -- 177
_with_0:watch(function(self, unit) -- 178
	unit.receivingDecisionTrace = true -- 178
	return false -- 178
end) -- 178
return _with_0 -- 177
