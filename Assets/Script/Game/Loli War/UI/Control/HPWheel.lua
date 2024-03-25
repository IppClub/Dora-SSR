-- [yue]: Script/Game/Loli War/UI/Control/HPWheel.yue
local _module_0 = dora.Platformer -- 1
local Data = _module_0.Data -- 1
local Class = dora.Class -- 1
local math = _G.math -- 1
local tostring = _G.tostring -- 1
local ScaleX = dora.ScaleX -- 1
local string = _G.string -- 1
local table = _G.table -- 1
local ipairs = _G.ipairs -- 1
local X = dora.X -- 1
local _module_0 = nil -- 1
local HPWheel = require("UI.View.HPWheel") -- 10
local EPHint = require("UI.View.EPHint") -- 11
local GroupPlayer, GroupEnemy, GroupPlayerBlock, GroupEnemyBlock, MaxEP, MaxHP -- 13
do -- 13
	local _obj_0 = Data.store -- 20
	GroupPlayer, GroupEnemy, GroupPlayerBlock, GroupEnemyBlock, MaxEP, MaxHP = _obj_0.GroupPlayer, _obj_0.GroupEnemy, _obj_0.GroupPlayerBlock, _obj_0.GroupEnemyBlock, _obj_0.MaxEP, _obj_0.MaxHP -- 13
end -- 20
_module_0 = Class(HPWheel, { -- 23
	__init = function(self) -- 23
		self.ep = MaxEP -- 24
		self.hp = MaxHP -- 25
		self.hints = { } -- 26
		self.hpShow:slot("AnimationEnd", function(name) -- 28
			if name == "hit" then -- 29
				return self.hpShow:play("idle", true) -- 29
			end -- 29
		end) -- 28
		self:gslot("HPChange", function(group, value) -- 31
			if group == GroupPlayer then -- 32
				local newHP = math.max(self.hp + value, 0) -- 33
				self.hp = math.floor(math.max(math.min(MaxHP, newHP), 0) + 0.5) -- 34
				self.hpShow.look = tostring(self.hp) -- 35
				if value < 0 then -- 36
					return self.hpShow:play("hit") -- 36
				end -- 36
			end -- 32
		end) -- 31
		self:gslot("EPChange", function(group, value) -- 38
			if group == GroupPlayer then -- 39
				if 1 == value or (-1) == value or (-2) == value or 6 == value then -- 41
					self.ep = math.floor(math.max(math.min(MaxEP, self.ep + value), 0) + 0.5) -- 42
					self.fill:perform(ScaleX(0.2, self.fill.scaleX, self.ep / MaxEP)) -- 43
					local hint -- 44
					do -- 44
						local _with_0 = EPHint({ -- 44
							index = #self.hints + 1, -- 44
							clip = string.format("%+d", value) -- 44
						}) -- 44
						_with_0.index = #self.hints + 1 -- 45
						_with_0:slot("DisplayEnd", function() -- 46
							local index = hint.index -- 47
							hint:removeFromParent() -- 48
							table.remove(self.hints, index) -- 49
							for i, v in ipairs(self.hints) do -- 50
								v:runAction(X(0.2, v.x, 55 + 25 * (i - 1))) -- 51
								v.index = i -- 52
							end -- 52
						end) -- 46
						hint = _with_0 -- 44
					end -- 44
					table.insert(self.hints, hint) -- 53
					return self.energy:addChild(hint) -- 54
				end -- 54
			end -- 39
		end) -- 38
		self:gslot("BlockValue", function(group, value) -- 56
			if GroupPlayer == group then -- 58
				self.playerBlocks.value = value -- 59
			elseif GroupEnemy == group then -- 60
				self.enemyBlocks.value = value -- 61
			end -- 61
		end) -- 56
		return self:gslot("BlockChange", function(group, value) -- 63
			if GroupPlayer == group then -- 65
				self.playerBlocks.value = math.max(self.playerBlocks.value + value, 0) -- 66
			elseif GroupEnemy == group then -- 67
				self.enemyBlocks.value = math.max(self.enemyBlocks.value + value, 0) -- 68
			end -- 68
		end) -- 68
	end -- 23
}) -- 22
return _module_0 -- 68
