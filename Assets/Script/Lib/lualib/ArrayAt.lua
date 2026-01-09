local function __TS__ArrayAt(self, relativeIndex)
	local absoluteIndex = relativeIndex < 0 and #self + relativeIndex or relativeIndex
	if absoluteIndex >= 0 and absoluteIndex < #self then
		return self[absoluteIndex + 1]
	end
	return nil
end
