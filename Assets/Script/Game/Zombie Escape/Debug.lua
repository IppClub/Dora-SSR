-- [yue]: Debug.yue
local _module_1 = Dora.Platformer -- 1
local Data = _module_1.Data -- 1
local Group = Dora.Group -- 1
local App = Dora.App -- 1
local _module_0 = Dora.ImGui -- 1
local SetNextWindowPos = _module_0.SetNextWindowPos -- 1
local Vec2 = Dora.Vec2 -- 1
local SetNextWindowSize = _module_0.SetNextWindowSize -- 1
local Begin = _module_0.Begin -- 1
local TextWrapped = _module_0.TextWrapped -- 1
local tostring = _G.tostring -- 1
local SameLine = _module_0.SameLine -- 1
local Button = _module_0.Button -- 1
local Rect = Dora.Rect -- 1
local Size = Dora.Size -- 1
local Entity = Dora.Entity -- 1
local DragFloat = _module_0.DragFloat -- 1
local Checkbox = _module_0.Checkbox -- 1
local Separator = _module_0.Separator -- 1
local RadioButton = _module_0.RadioButton -- 1
local Director = Dora.Director -- 1
local table = _G.table -- 1
local Text = _module_0.Text -- 1
local Observer = Dora.Observer -- 1
local Star = require("UI.View.Shape.Star") -- 10
local Store = Data.store -- 12
local world, ZombieLayer, PlayerGroup = Store.world, Store.ZombieLayer, Store.PlayerGroup -- 13
local playerGroup = Group({ -- 19
	"player", -- 19
	"unit" -- 19
}) -- 19
local zombieGroup = Group({ -- 20
	"zombie", -- 20
	"unit" -- 20
}) -- 20
local userControl = false -- 21
local playerChoice = 1 -- 22
local controlChoice -- 23
do -- 23
	local _exp_0 = App.platform -- 23
	if "iOS" == _exp_0 or "Android" == _exp_0 or "macOS" == _exp_0 then -- 24
		controlChoice = 0 -- 24
	else -- 25
		controlChoice = 1 -- 25
	end -- 25
end -- 25
local camZoom = world.camera.zoom -- 26
local decisions = { } -- 27
local showDecisionTrace = false -- 28
local lastDecisionTree = "" -- 29
local _anon_func_0 = function(controlChoice) -- 134
	if controlChoice == 1 then -- 134
		return "Keyboard: Left(A), Right(D), Shoot(J), Jump(K)" -- 135
	else -- 136
		return "TouchPad: Use buttons in lower screen to control unit." -- 136
	end -- 134
end -- 134
world:schedule(function() -- 30
	local width = App.visualSize.width -- 31
	SetNextWindowPos(Vec2(width - 250, 10), "FirstUseEver") -- 32
	SetNextWindowSize(Vec2(240, userControl and 500 or 300)) -- 33
	Begin("Zombie Game Demo", { -- 34
		"NoResize", -- 34
		"NoSavedSettings" -- 34
	}, function() -- 34
		TextWrapped("Zombie Killed: " .. tostring(Store.zombieKilled)) -- 35
		SameLine() -- 36
		if Button("Army") then -- 37
			for _i = 0, 10 do -- 38
				local available = false -- 39
				local pos = Vec2.zero -- 40
				while not available do -- 41
					pos = Vec2(App.rand % 2400 - 1200, -430) -- 42
					available = not world:query(Rect(pos, Size(5, 5)), function(self) -- 43
						return self.group == Data.groupTerrain -- 43
					end) -- 43
				end -- 43
				Entity({ -- 45
					unitDef = "Unit_Zombie" .. tostring(App.rand % 2 + 1), -- 45
					order = ZombieLayer, -- 46
					position = pos, -- 47
					group = PlayerGroup, -- 48
					faceRight = App.rand % 2 == 0, -- 49
					stared = true -- 50
				}) -- 44
			end -- 50
		end -- 37
		local changed -- 51
		changed, camZoom = DragFloat("Zoom", camZoom, 0.01, 0.5, 2, "%.2f") -- 51
		if changed then -- 52
			world.camera.zoom = camZoom -- 52
		end -- 52
		playerGroup:each(function(self) -- 53
			return TextWrapped(tostring(self.unit.tag) .. " HP: " .. tostring(self.hp)) -- 53
		end) -- 53
		local result -- 54
		changed, result = Checkbox("Physics Debug", world.showDebug) -- 54
		if changed then -- 55
			world.showDebug = result -- 55
		end -- 55
		changed, showDecisionTrace = Checkbox("AI Debug", showDecisionTrace) -- 56
		if changed then -- 57
			playerGroup:each(function(self) -- 58
				self.unit.receivingDecisionTrace = showDecisionTrace -- 58
			end) -- 58
		end -- 57
		changed, userControl = Checkbox("Take Control", userControl) -- 59
		if userControl then -- 60
			if Store.controlPlayer == "Zombie" and not playerGroup:each(function(self) -- 62
				if self.unit.tag == "Zombie" then -- 63
					if self.hp <= 0 then -- 64
						self.player = nil -- 65
						self.unit.children.last:removeFromParent() -- 66
						self.unit.decisionTree = "" -- 67
						self.unit.tag = "ZombieDead" -- 68
						return false -- 69
					else -- 70
						return true -- 70
					end -- 64
				end -- 63
				return false -- 71
			end) then -- 61
				zombieGroup:each(function(self) -- 72
					if self.hp <= 0 then -- 73
						return false -- 73
					end -- 73
					self.player = true -- 74
					self.zombie = nil -- 75
					do -- 76
						local _with_0 = self.unit -- 76
						_with_0.tag = "Zombie" -- 77
						_with_0.group = PlayerGroup -- 78
						_with_0.decisionTree = "AI_PlayerControl" -- 79
						_with_0.sensity = 0 -- 80
						_with_0:addChild(Star({ -- 82
							y = 100, -- 82
							size = 18, -- 83
							borderColor = 0xffff8800, -- 84
							fillColor = 0x66ff8800, -- 85
							fillOrder = 1, -- 86
							lineOrder = 2 -- 87
						})) -- 81
						world.camera.followTarget = _with_0 -- 76
					end -- 76
					return true -- 89
				end) -- 72
			end -- 61
			Separator() -- 90
			local pressedA, choice = RadioButton("Male", playerChoice, 0) -- 91
			if pressedA then -- 92
				playerChoice = choice -- 92
			end -- 92
			local pressedB -- 93
			pressedB, choice = RadioButton("Female", playerChoice, 1) -- 93
			if pressedB then -- 94
				playerChoice = choice -- 94
			end -- 94
			local pressedC -- 95
			pressedC, choice = RadioButton("Zombie", playerChoice, 2) -- 95
			if pressedC then -- 96
				playerChoice = choice -- 96
			end -- 96
			if pressedA or pressedB or pressedC or changed then -- 97
				if 0 == playerChoice then -- 99
					Store.controlPlayer = "KidM" -- 99
				elseif 1 == playerChoice then -- 100
					Store.controlPlayer = "KidW" -- 100
				elseif 2 == playerChoice then -- 101
					Store.controlPlayer = "Zombie" -- 101
				end -- 101
				if Store.controlPlayer == "Zombie" and not playerGroup:each(function(self) -- 103
					return self.unit.tag == "Zombie" -- 103
				end) then -- 102
					zombieGroup:each(function(self) -- 104
						self.player = true -- 105
						self.zombie = nil -- 106
						do -- 107
							local _with_0 = self.unit -- 107
							_with_0.tag = "Zombie" -- 108
							_with_0.group = PlayerGroup -- 109
							_with_0:addChild(Star({ -- 111
								y = 100, -- 111
								size = 18, -- 112
								borderColor = 0xffff8800, -- 113
								fillColor = 0x66ff8800, -- 114
								fillOrder = 1, -- 115
								lineOrder = 2 -- 116
							})) -- 110
						end -- 107
						return true -- 118
					end) -- 104
				end -- 102
				playerGroup:each(function(self) -- 119
					if self.unit.tag == Store.controlPlayer then -- 120
						self.unit.decisionTree = "AI_PlayerControl" -- 121
						self.unit.sensity = 0 -- 122
						world.camera.followTarget = self.unit -- 123
					else -- 125
						do -- 125
							local _exp_0 = self.unit.tag -- 125
							if "KidM" == _exp_0 then -- 126
								self.unit.decisionTree = "AI_KidFollow" -- 126
							elseif "KidW" == _exp_0 then -- 127
								self.unit.decisionTree = "AI_KidSearch" -- 127
							elseif "Zombie" == _exp_0 then -- 128
								self.unit.decisionTree = "AI_Zombie" -- 128
							end -- 128
						end -- 128
						self.unit.sensity = 0.1 -- 129
					end -- 120
				end) -- 119
			end -- 97
			if changed then -- 130
				Store.keyboardEnabled = controlChoice == 1 -- 131
				Director.ui.children.first.visible = controlChoice == 0 -- 132
			end -- 130
			Separator() -- 133
			TextWrapped(_anon_func_0(controlChoice)) -- 134
			Separator() -- 137
			pressedA, choice = RadioButton("TouchPad", controlChoice, 0) -- 138
			if pressedA then -- 139
				controlChoice = choice -- 140
				Store.keyboardEnabled = false -- 141
				Director.ui:eachChild(function(self) -- 142
					self.visible = true -- 142
				end) -- 142
			end -- 139
			pressedB, choice = RadioButton("Keyboard", controlChoice, 1) -- 143
			if pressedB then -- 144
				controlChoice = choice -- 145
				Store.keyboardEnabled = true -- 146
				Director.ui.children.first.visible = false -- 147
			end -- 144
		elseif changed then -- 148
			playerGroup:each(function(self) -- 149
				do -- 150
					local _exp_0 = self.unit.tag -- 150
					if "KidM" == _exp_0 then -- 151
						self.unit.decisionTree = "AI_KidFollow" -- 151
					elseif "KidW" == _exp_0 then -- 152
						self.unit.decisionTree = "AI_KidSearch" -- 152
					elseif "Zombie" == _exp_0 then -- 153
						self.unit.decisionTree = "AI_Zombie" -- 153
					end -- 153
				end -- 153
				self.unit.sensity = 0.1 -- 154
			end) -- 149
			Store.keyboardEnabled = false -- 155
			Director.ui.children.first.visible = false -- 156
		end -- 60
	end) -- 34
	local target = world.camera.followTarget -- 158
	if target then -- 159
		local player = target.entity -- 160
		local decisionTrace = player.decisionTrace -- 161
		local lastDecision = decisions[#decisions] -- 162
		if lastDecision ~= decisionTrace then -- 163
			decisions[#decisions + 1] = decisionTrace -- 164
		end -- 163
		if #decisions > 5 then -- 165
			table.remove(decisions, 1) -- 165
		end -- 165
		lastDecisionTree = target.decisionTree -- 166
	end -- 159
	if showDecisionTrace then -- 168
		SetNextWindowPos(Vec2(width / 2 - 200, 10), "FirstUseEver") -- 169
		SetNextWindowSize(Vec2(400, 160), "FirstUseEver") -- 170
		return Begin("Decision Trace (" .. tostring(lastDecisionTree) .. ")", { -- 171
			"NoSavedSettings" -- 171
		}, function() -- 171
			return Text(table.concat(decisions, "\n")) -- 172
		end) -- 172
	end -- 168
end) -- 30
do -- 174
	local _with_0 = Observer("Add", { -- 174
		"group", -- 174
		"unit", -- 174
		"player", -- 174
		"stared" -- 174
	}) -- 174
	_with_0:watch(function(_entity, _group, unit) -- 175
		unit:addChild(Star({ -- 177
			y = 100, -- 177
			size = 18, -- 178
			borderColor = 0xff66ccff, -- 179
			fillColor = 0x6666ccff, -- 180
			fillOrder = 1, -- 181
			lineOrder = 2 -- 182
		})) -- 176
		return false -- 183
	end) -- 175
end -- 174
local _with_0 = Observer("Add", { -- 185
	"unit", -- 185
	"player" -- 185
}) -- 185
_with_0:watch(function(_entity, unit) -- 186
	unit.receivingDecisionTrace = true -- 186
	return false -- 186
end) -- 186
return _with_0 -- 185
