-- [yue]: Script/Test/EntitySystem.yue
local Group = Dora.Group -- 1
local Observer = Dora.Observer -- 1
local Entity = Dora.Entity -- 1
local print = _G.print -- 1
local assert = _G.assert -- 1
local tostring = _G.tostring -- 1
local hpGroup = Group({ -- 4
	"hp" -- 4
}) -- 4
local spGroup = Group({ -- 5
	"sp" -- 5
}) -- 5
local observer = Observer("Change", { -- 7
	"hp", -- 7
	"mp" -- 7
}) -- 7
local observer1 = Observer("Remove", { -- 8
	"hp", -- 8
	"sp" -- 8
}) -- 8
Entity({ -- 11
	hp = 100, -- 11
	mp = 998, -- 12
	id = 0 -- 13
}) -- 10
local entity0 = hpGroup:find(function(self) -- 15
	return self.id == 0 -- 15
end) -- 15
Entity({ -- 18
	hp = 119, -- 18
	sp = 233, -- 19
	id = 1 -- 20
}) -- 17
local entity1 = hpGroup:find(function(self) -- 22
	return self.id == 1 -- 22
end) -- 22
print("-- {hp} group") -- 24
hpGroup:each(function(self) -- 25
	return print("entity", self.id) -- 26
end) -- 25
print("-- {sp} group") -- 28
spGroup:each(function(self) -- 29
	return print("entity", self.id) -- 30
end) -- 29
print("-- {hp mp} observer") -- 32
entity0.hp = entity0.hp + 20 -- 33
entity0.hp = entity0.hp - 34 -- 34
entity1.hp = entity1.hp - 1 -- 36
entity1.hp = entity1.hp - 99 -- 37
observer:watch(function(self, hp, mp) -- 40
	do -- 41
		local oldHP = self.oldValues.hp -- 41
		if oldHP then -- 41
			assert(self.oldValues.hp == 100) -- 42
			assert(hp == 86) -- 43
			print("hp change [from " .. tostring(oldHP) .. " to " .. tostring(hp) .. "]: entity " .. tostring(self.id)) -- 44
		end -- 41
	end -- 41
	local oldMP = self.oldValues.mp -- 45
	if oldMP then -- 45
		return print("mp change [from " .. tostring(oldMP) .. " to " .. tostring(mp) .. "]: entity " .. tostring(self.id)) -- 46
	end -- 45
end) -- 39
observer1:watch(function(self, hp, sp) -- 49
	if hp == nil then -- 50
		assert(self.oldValues.hp == 119) -- 51
		print("hp removed from entity " .. tostring(self.id) .. ", old value: " .. tostring(self.oldValues.hp)) -- 52
	end -- 50
	if sp == nil then -- 53
		return print("sp removed from entity " .. tostring(self.id) .. ", old value: " .. tostring(self.oldValues.sp)) -- 54
	end -- 53
end) -- 48
print("-- {hp} group") -- 56
hpGroup:each(function(self) -- 57
	return print("entity", self.id, self.hp) -- 58
end) -- 57
print("remove hp from entity", entity1.id) -- 60
entity1.hp = nil -- 61
print("-- {hp} group") -- 63
hpGroup:each(function(self) -- 64
	return print("entity", self.index, self.hp) -- 65
end) -- 64
assert(hpGroup.count == 1) -- 67
print("-- {sp} group") -- 69
spGroup:each(function(self) -- 70
	return print("entity", self.index, self.sp) -- 71
end) -- 70
return assert(spGroup.count == 1) -- 73
