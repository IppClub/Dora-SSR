local function __TS__ArrayToObject(self)
	local object = {}
	for i = 1, #self do
		object[i - 1] = self[i]
	end
	return object
end
