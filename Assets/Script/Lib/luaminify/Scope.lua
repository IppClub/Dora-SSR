local blacklist = {
	["do"] = true,
	["if"] = true,
	["in"] = true,
	["or"] = true,
	["for"] = true,
	["and"] = true,
	["not"] = true,
	["end"] = true,
	["nil"] = true
}

local insert, char = table.insert, string.char

local chars = {}
for i = 97, 122 do
	insert(chars, char(i))
end
for i = 65, 90 do
	insert(chars, char(i))
end

local function GetUnique(self)
	for x = 1, 52 do
		local c = chars[x]
		if not blacklist[c] and not self:GetVariable(c) then
			return c
		end
	end
	for x = 1, 52 do
		for y = 1, 52 do
			local c = chars[x]..chars[y]
			if not blacklist[c] and not self:GetVariable(c) then
				return c
			end
		end
	end
	for x = 1, 52 do
		for y = 1, 52 do
			for z = 1, 52 do
				local c = chars[x]..chars[y]..chars[z]
				if not blacklist[c] and not self:GetVariable(c) then
					return c
				end
			end
		end
	end
end

local Scope = {
	new = function(self, parent)
		local s = {
			Parent = parent,
			Locals = { },
			Globals = { },
			oldLocalNamesMap = { },
			oldGlobalNamesMap = { },
			Children = { },
		}

		if parent then
			table.insert(parent.Children, s)
		end

		return setmetatable(s, { __index = self })
	end,

	AddLocal = function(self, v)
		table.insert(self.Locals, v)
	end,

	AddGlobal = function(self, v)
		table.insert(self.Globals, v)
	end,

	CreateLocal = function(self, name)
		local v
		v = self:GetLocal(name)
		if v then return v end
		v = { }
		v.Scope = self
		v.Name = name
		v.IsGlobal = false
		v.CanRename = true
		v.References = 1
		self:AddLocal(v)
		return v
	end,

	GetLocal = function(self, name)
		for k, var in pairs(self.Locals) do
			if var.Name == name then return var end
		end

		if self.Parent then
			return self.Parent:GetLocal(name)
		end
	end,

	GetOldLocal = function(self, name)
		if self.oldLocalNamesMap[name] then
			return self.oldLocalNamesMap[name]
		end
		return self:GetLocal(name)
	end,

	mapLocal = function(self, name, var)
		self.oldLocalNamesMap[name] = var
	end,

	GetOldGlobal = function(self, name)
		if self.oldGlobalNamesMap[name] then
			return self.oldGlobalNamesMap[name]
		end
		return self:GetGlobal(name)
	end,

	mapGlobal = function(self, name, var)
		self.oldGlobalNamesMap[name] = var
	end,

	GetOldVariable = function(self, name)
		return self:GetOldLocal(name) or self:GetOldGlobal(name)
	end,

	RenameLocal = function(self, oldName, newName)
		oldName = type(oldName) == 'string' and oldName or oldName.Name
		local found = false
		local var = self:GetLocal(oldName)
		if var then
			var.Name = newName
			self:mapLocal(oldName, var)
			found = true
		end
		if not found and self.Parent then
			self.Parent:RenameLocal(oldName, newName)
		end
	end,

	RenameGlobal = function(self, oldName, newName)
		oldName = type(oldName) == 'string' and oldName or oldName.Name
		local found = false
		local var = self:GetGlobal(oldName)
		if var then
			var.Name = newName
			self:mapGlobal(oldName, var)
			found = true
		end
		if not found and self.Parent then
			self.Parent:RenameGlobal(oldName, newName)
		end
	end,

	RenameVariable = function(self, oldName, newName)
		oldName = type(oldName) == 'string' and oldName or oldName.Name
		if self:GetLocal(oldName) then
			self:RenameLocal(oldName, newName)
		else
			self:RenameGlobal(oldName, newName)
		end
	end,

	GetAllVariables = function(self)
		local ret = self:getVars(true) -- down
		for k, v in pairs(self:getVars(false)) do -- up
			table.insert(ret, v)
		end
		return ret
	end,

	getVars = function(self, top)
		local ret = { }
		if top then
			for k, v in pairs(self.Children) do
				for k2, v2 in pairs(v:getVars(true)) do
					table.insert(ret, v2)
				end
			end
		else
			for k, v in pairs(self.Locals) do
				table.insert(ret, v)
			end
			for k, v in pairs(self.Globals) do
				table.insert(ret, v)
			end
			if self.Parent then
				for k, v in pairs(self.Parent:getVars(false)) do
					table.insert(ret, v)
				end
			end
		end
		return ret
	end,

	CreateGlobal = function(self, name)
		local v
		v = self:GetGlobal(name)
		if v then return v end
		v = { }
		v.Scope = self
		v.Name = name
		v.IsGlobal = true
		v.CanRename = true
		v.References = 1
		self:AddGlobal(v)
		return v
	end,

	GetGlobal = function(self, name)
		for k, v in pairs(self.Globals) do
			if v.Name == name then return v end
		end

		if self.Parent then
			return self.Parent:GetGlobal(name)
		end
	end,

	GetVariable = function(self, name)
		return self:GetLocal(name) or self:GetGlobal(name)
	end,

	ObfuscateLocals = function(self, recommendedMaxLength, validNameChars)
		for i, var in pairs(self.Locals) do
			local id = GetUnique(self)
			self:RenameLocal(var.Name, id)
		end
	end
}

return Scope
