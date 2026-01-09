local function __TS__DelegatedYield(iterable)
	if type(iterable) == "string" then
		for index = 0, #iterable - 1 do
			coroutine.yield(__TS__StringAccess(iterable, index))
		end
	elseif iterable.____coroutine ~= nil then
		local co = iterable.____coroutine
		while true do
			local status, value = coroutine.resume(co)
			if not status then
				error(value, 0)
			end
			if coroutine.status(co) == "dead" then
				return value
			else
				coroutine.yield(value)
			end
		end
	elseif iterable[Symbol.iterator] then
		local iterator = iterable[Symbol.iterator](iterable)
		while true do
			local result = iterator:next()
			if result.done then
				return result.value
			else
				coroutine.yield(result.value)
			end
		end
	else
		for ____, value in ipairs(iterable) do
			coroutine.yield(value)
		end
	end
end
