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
local HPWheel = require("UI.View.HPWheel") -- 2
local EPHint = require("UI.View.EPHint") -- 3
local GroupPlayer, GroupEnemy, GroupPlayerBlock, GroupEnemyBlock, MaxEP, MaxHP -- 5
do -- 5
	local _obj_0 = Data.store -- 12
	GroupPlayer, GroupEnemy, GroupPlayerBlock, GroupEnemyBlock, MaxEP, MaxHP = _obj_0.GroupPlayer, _obj_0.GroupEnemy, _obj_0.GroupPlayerBlock, _obj_0.GroupEnemyBlock, _obj_0.MaxEP, _obj_0.MaxHP -- 5
end -- 12
_module_0 = Class(HPWheel, { -- 15
	__init = function(self) -- 15
		self.ep = MaxEP -- 16
		self.hp = MaxHP -- 17
		self.hints = { } -- 18
		self.hpShow:slot("AnimationEnd", function(name) -- 20
			if name == "hit" then -- 21
				return self.hpShow:play("idle", true) -- 21
			end -- 21
		end) -- 20
		self:gslot("HPChange", function(group, value) -- 23
			if group == GroupPlayer then -- 24
				local newHP = math.max(self.hp + value, 0) -- 25
				self.hp = math.floor(math.max(math.min(MaxHP, newHP), 0) + 0.5) -- 26
				self.hpShow.look = tostring(self.hp) -- 27
				if value < 0 then -- 28
					return self.hpShow:play("hit") -- 28
				end -- 28
			end -- 24
		end) -- 23
		self:gslot("EPChange", function(group, value) -- 30
			if group == GroupPlayer then -- 31
				if 1 == value or (-1) == value or (-2) == value or 6 == value then -- 33
					self.ep = math.floor(math.max(math.min(MaxEP, self.ep + value), 0) + 0.5) -- 34
					self.fill:perform(ScaleX(0.2, self.fill.scaleX, self.ep / MaxEP)) -- 35
					local hint -- 36
					do -- 36
						local _with_0 = EPHint({ -- 36
							index = #self.hints + 1, -- 36
							clip = string.format("%+d", value) -- 36
						}) -- 36
						_with_0.index = #self.hints + 1 -- 37
						_with_0:slot("DisplayEnd", function() -- 38
							local index = hint.index -- 39
							hint:removeFromParent() -- 40
							table.remove(self.hints, index) -- 41
							for i, v in ipairs(self.hints) do -- 42
								v:runAction(X(0.2, v.x, 55 + 25 * (i - 1))) -- 43
								v.index = i -- 44
							end -- 44
						end) -- 38
						hint = _with_0 -- 36
					end -- 36
					table.insert(self.hints, hint) -- 45
					return self.energy:addChild(hint) -- 46
				end -- 46
			end -- 31
		end) -- 30
		self:gslot("BlockValue", function(group, value) -- 48
			if GroupPlayer == group then -- 50
				self.playerBlocks.value = value -- 51
			elseif GroupEnemy == group then -- 52
				self.enemyBlocks.value = value -- 53
			end -- 53
		end) -- 48
		return self:gslot("BlockChange", function(group, value) -- 55
			if GroupPlayer == group then -- 57
				self.playerBlocks.value = math.max(self.playerBlocks.value + value, 0) -- 58
			elseif GroupEnemy == group then -- 59
				self.enemyBlocks.value = math.max(self.enemyBlocks.value + value, 0) -- 60
			end -- 60
		end) -- 60
	end -- 15
}) -- 14
return _module_0 -- 60
