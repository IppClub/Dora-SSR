local function __TS__ArraySplice(self, ...)
	local args = {...}
	local len = #self
	local actualArgumentCount = __TS__CountVarargs(...)
	local start = args[1]
	local deleteCount = args[2]
	if start < 0 then
		start = len + start
		if start < 0 then
			start = 0
		end
	elseif start > len then
		start = len
	end
	local itemCount = actualArgumentCount - 2
	if itemCount < 0 then
		itemCount = 0
	end
	local actualDeleteCount
	if actualArgumentCount == 0 then
		actualDeleteCount = 0
	elseif actualArgumentCount == 1 then
		actualDeleteCount = len - start
	else
		actualDeleteCount = deleteCount or 0
		if actualDeleteCount < 0 then
			actualDeleteCount = 0
		end
		if actualDeleteCount > len - start then
			actualDeleteCount = len - start
		end
	end
	local out = {}
	for k = 1, actualDeleteCount do
		local from = start + k
		if self[from] ~= nil then
			out[k] = self[from]
		end
	end
	if itemCount < actualDeleteCount then
		for k = start + 1, len - actualDeleteCount do
			local from = k + actualDeleteCount
			local to = k + itemCount
			if self[from] then
				self[to] = self[from]
			else
				self[to] = nil
			end
		end
		for k = len - actualDeleteCount + itemCount + 1, len do
			self[k] = nil
		end
	elseif itemCount > actualDeleteCount then
		for k = len - actualDeleteCount, start + 1, -1 do
			local from = k + actualDeleteCount
			local to = k + itemCount
			if self[from] then
				self[to] = self[from]
			else
				self[to] = nil
			end
		end
	end
	local j = start + 1
	for i = 3, actualArgumentCount do
		self[j] = args[i]
		j = j + 1
	end
	for k = #self, len - actualDeleteCount + itemCount + 1, -1 do
		self[k] = nil
	end
	return out
end
