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
local GroupPlayer, GroupEnemy, MaxEP, MaxHP -- 13
do -- 13
	local _obj_0 = Data.store -- 18
	GroupPlayer, GroupEnemy, MaxEP, MaxHP = _obj_0.GroupPlayer, _obj_0.GroupEnemy, _obj_0.MaxEP, _obj_0.MaxHP -- 13
end -- 18
_module_0 = Class(HPWheel, { -- 21
	__init = function(self) -- 21
		self.ep = MaxEP -- 22
		self.hp = MaxHP -- 23
		self.hints = { } -- 24
		self.hpShow:slot("AnimationEnd", function(name) -- 26
			if name == "hit" then -- 27
				return self.hpShow:play("idle", true) -- 27
			end -- 27
		end) -- 26
		self:gslot("HPChange", function(group, value) -- 29
			if group == GroupPlayer then -- 30
				local newHP = math.max(self.hp + value, 0) -- 31
				self.hp = math.floor(math.max(math.min(MaxHP, newHP), 0) + 0.5) -- 32
				self.hpShow.look = tostring(self.hp) -- 33
				if value < 0 then -- 34
					return self.hpShow:play("hit") -- 34
				end -- 34
			end -- 30
		end) -- 29
		self:gslot("EPChange", function(group, value) -- 36
			if group == GroupPlayer then -- 37
				if 1 == value or (-1) == value or (-2) == value or 6 == value then -- 39
					self.ep = math.floor(math.max(math.min(MaxEP, self.ep + value), 0) + 0.5) -- 40
					self.fill:perform(ScaleX(0.2, self.fill.scaleX, self.ep / MaxEP)) -- 41
					local hint -- 42
					do -- 42
						local _with_0 = EPHint({ -- 42
							index = #self.hints + 1, -- 42
							clip = string.format("%+d", value) -- 42
						}) -- 42
						_with_0.index = #self.hints + 1 -- 43
						_with_0:slot("DisplayEnd", function() -- 44
							local index = hint.index -- 45
							hint:removeFromParent() -- 46
							table.remove(self.hints, index) -- 47
							for i, v in ipairs(self.hints) do -- 48
								v:runAction(X(0.2, v.x, 55 + 25 * (i - 1))) -- 49
								v.index = i -- 50
							end -- 50
						end) -- 44
						hint = _with_0 -- 42
					end -- 42
					table.insert(self.hints, hint) -- 51
					return self.energy:addChild(hint) -- 52
				end -- 52
			end -- 37
		end) -- 36
		self:gslot("BlockValue", function(group, value) -- 54
			if GroupPlayer == group then -- 56
				self.playerBlocks.value = value -- 57
			elseif GroupEnemy == group then -- 58
				self.enemyBlocks.value = value -- 59
			end -- 59
		end) -- 54
		return self:gslot("BlockChange", function(group, value) -- 61
			if GroupPlayer == group then -- 63
				self.playerBlocks.value = math.max(self.playerBlocks.value + value, 0) -- 64
			elseif GroupEnemy == group then -- 65
				self.enemyBlocks.value = math.max(self.enemyBlocks.value + value, 0) -- 66
			end -- 66
		end) -- 66
	end -- 21
}) -- 20
return _module_0 -- 66
