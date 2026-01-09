local function __TS__PromiseRace(iterable)
	local pending = {}
	for ____, item in __TS__Iterator(iterable) do
		if __TS__InstanceOf(item, __TS__Promise) then
			if item.state == 1 then
				return __TS__Promise.resolve(item.value)
			elseif item.state == 2 then
				return __TS__Promise.reject(item.rejectionReason)
			else
				pending[#pending + 1] = item
			end
		else
			return __TS__Promise.resolve(item)
		end
	end
	return __TS__New(
		__TS__Promise,
		function(____, resolve, reject)
			for ____, promise in ipairs(pending) do
				promise["then"](
					promise,
					function(____, value) return resolve(nil, value) end,
					function(____, reason) return reject(nil, reason) end
				)
			end
		end
	)
end
