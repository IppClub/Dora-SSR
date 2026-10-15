local function __TS__Class(self)
	local c = {prototype = {}}
	c.prototype.__index = c.prototype
	c.prototype.constructor = c
	return c
end
