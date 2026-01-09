local function __TS__ArrayReverse(self)
	local i = 1
	local j = #self
	while i < j do
		local temp = self[j]
		self[j] = self[i]
		self[i] = temp
		i = i + 1
		j = j - 1
	end
	return self
end
