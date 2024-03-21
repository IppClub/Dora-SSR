-- [yue]: Script/Test/EntitySystem.yue
local Group = dora.Group -- 1
local Observer = dora.Observer -- 1
local Entity = dora.Entity -- 1
local print = _G.print -- 1
local assert = _G.assert -- 1
local tostring = _G.tostring -- 1
local hpGroup = Group({ -- 3
	"hp" -- 3
}) -- 3
local spGroup = Group({ -- 4
	"sp" -- 4
}) -- 4
local observer = Observer("Change", { -- 6
	"hp", -- 6
	"mp" -- 6
}) -- 6
local observer1 = Observer("Remove", { -- 7
	"hp", -- 7
	"sp" -- 7
}) -- 7
Entity({ -- 10
	hp = 100, -- 10
	mp = 998, -- 11
	id = 0 -- 12
}) -- 9
local entity0 = hpGroup:find(function(self) -- 14
	return self.id == 0 -- 14
end) -- 14
Entity({ -- 17
	hp = 119, -- 17
	sp = 233, -- 18
	id = 1 -- 19
}) -- 16
local entity1 = hpGroup:find(function(self) -- 21
	return self.id == 1 -- 21
end) -- 21
print("-- {hp} group") -- 23
hpGroup:each(function(self) -- 24
	return print("entity", self.id) -- 25
end) -- 24
print("-- {sp} group") -- 27
spGroup:each(function(self) -- 28
	return print("entity", self.id) -- 29
end) -- 28
print("-- {hp mp} observer") -- 31
entity0.hp = entity0.hp + 20 -- 32
entity0.hp = entity0.hp - 34 -- 33
entity1.hp = entity1.hp - 1 -- 35
entity1.hp = entity1.hp - 99 -- 36
observer:watch(function(self, hp, mp) -- 39
	do -- 40
		local oldHP = self.oldValues.hp -- 40
		if oldHP then -- 40
			assert(self.oldValues.hp == 100) -- 41
			assert(hp == 86) -- 42
			print("hp change [from " .. tostring(oldHP) .. " to " .. tostring(hp) .. "]: entity " .. tostring(self.id)) -- 43
		end -- 40
	end -- 40
	local oldMP = self.oldValues.mp -- 44
	if oldMP then -- 44
		return print("mp change [from " .. tostring(oldMP) .. " to " .. tostring(mp) .. "]: entity " .. tostring(self.id)) -- 45
	end -- 44
end) -- 38
observer1:watch(function(self, hp, sp) -- 48
	if hp == nil then -- 49
		assert(self.oldValues.hp == 119) -- 50
		print("hp removed from entity " .. tostring(self.id) .. ", old value: " .. tostring(self.oldValues.hp)) -- 51
	end -- 49
	if sp == nil then -- 52
		return print("sp removed from entity " .. tostring(self.id) .. ", old value: " .. tostring(self.oldValues.sp)) -- 53
	end -- 52
end) -- 47
print("-- {hp} group") -- 55
hpGroup:each(function(self) -- 56
	return print("entity", self.id, self.hp) -- 57
end) -- 56
print("remove hp from entity", entity1.id) -- 59
entity1.hp = nil -- 60
print("-- {hp} group") -- 62
hpGroup:each(function(self) -- 63
	return print("entity", self.index, self.hp) -- 64
end) -- 63
assert(hpGroup.count == 1) -- 66
print("-- {sp} group") -- 68
spGroup:each(function(self) -- 69
	return print("entity", self.index, self.sp) -- 70
end) -- 69
return assert(spGroup.count == 1) -- 72
