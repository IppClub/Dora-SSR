local function __TS__ArrayReduceRight(self, callbackFn, ...)
	local len = #self
	local k = len - 1
	local accumulator = nil
	if __TS__CountVarargs(...) ~= 0 then
		accumulator = ...
	elseif len > 0 then
		accumulator = self[k + 1]
		k = k - 1
	else
		error("Reduce of empty array with no initial value", 0)
	end
	for i = k + 1, 1, -1 do
		accumulator = callbackFn(
			nil,
			accumulator,
			self[i],
			i - 1,
			self
		)
	end
	return accumulator
end
