local function __TS__ArraySetLength(self, length)
	if length < 0 or length ~= length or length == math.huge or math.floor(length) ~= length then
		error(
			"invalid array length: " .. tostring(length),
			0
		)
	end
	for i = length + 1, #self do
		self[i] = nil
	end
	return length
end
