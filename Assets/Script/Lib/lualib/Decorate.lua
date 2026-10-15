local function __TS__Decorate(self, originalValue, decorators, context)
	local result = originalValue
	do
		local i = #decorators
		while i >= 0 do
			local decorator = decorators[i + 1]
			if decorator ~= nil then
				local ____decorator_result_0 = decorator(self, result, context)
				if ____decorator_result_0 == nil then
					____decorator_result_0 = result
				end
				result = ____decorator_result_0
			end
			i = i - 1
		end
	end
	return result
end
