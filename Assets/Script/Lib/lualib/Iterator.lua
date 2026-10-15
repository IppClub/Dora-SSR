local __TS__Iterator
do
	local function iteratorGeneratorStep(self)
		local co = self.____coroutine
		local status, value = coroutine.resume(co)
		if not status then
			error(value, 0)
		end
		if coroutine.status(co) == "dead" then
			return
		end
		return true, value
	end
	local function iteratorIteratorStep(self)
		local result = self:next()
		if result.done then
			return
		end
		return true, result.value
	end
	local function iteratorStringStep(self, index)
		index = index + 1
		if index > #self then
			return
		end
		return index, string.sub(self, index, index)
	end
	function __TS__Iterator(iterable)
		if type(iterable) == "string" then
			return iteratorStringStep, iterable, 0
		elseif iterable.____coroutine ~= nil then
			return iteratorGeneratorStep, iterable
		elseif iterable[Symbol.iterator] then
			local iterator = iterable[Symbol.iterator](iterable)
			return iteratorIteratorStep, iterator
		else
			return ipairs(iterable)
		end
	end
end
