-- [ts]: flow.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Log = ____Dora.Log -- 1
local Director = ____Dora.Director -- 1
local once = ____Dora.once -- 1
local sleep = ____Dora.sleep -- 1
local BaseNode = __TS__Class() -- 4
BaseNode.name = "BaseNode" -- 4
function BaseNode.prototype.____constructor(self) -- 4
	self._params = {} -- 5
	self._successors = __TS__New(Map) -- 6
end -- 4
function BaseNode.prototype._exec(self, prepRes) -- 7
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 7
		return ____awaiter_resolve( -- 7
			nil, -- 7
			__TS__Await(self:exec(prepRes)) -- 8
		) -- 8
	end) -- 8
end -- 7
function BaseNode.prototype.prep(self, shared) -- 10
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 10
		return ____awaiter_resolve(nil, nil) -- 10
	end) -- 10
end -- 10
function BaseNode.prototype.exec(self, prepRes) -- 13
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 13
		return ____awaiter_resolve(nil, nil) -- 13
	end) -- 13
end -- 13
function BaseNode.prototype.post(self, shared, prepRes, execRes) -- 16
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 16
		return ____awaiter_resolve(nil, nil) -- 16
	end) -- 16
end -- 16
function BaseNode.prototype._run(self, shared) -- 19
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 19
		local p = __TS__Await(self:prep(shared)) -- 20
		local e = __TS__Await(self:_exec(p)) -- 21
		return ____awaiter_resolve( -- 21
			nil, -- 21
			__TS__Await(self:post(shared, p, e)) -- 22
		) -- 22
	end) -- 22
end -- 19
function BaseNode.prototype.run(self, shared) -- 24
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 24
		if self._successors.size > 0 then -- 24
			Log("Error", "Node won't run successors. Use Flow.") -- 26
		end -- 26
		return ____awaiter_resolve( -- 26
			nil, -- 26
			__TS__Await(self:_run(shared)) -- 28
		) -- 28
	end) -- 28
end -- 24
function BaseNode.prototype.setParams(self, params) -- 30
	self._params = params -- 31
	return self -- 32
end -- 30
function BaseNode.prototype.next(self, node) -- 34
	self:on("default", node) -- 35
	return node -- 36
end -- 34
function BaseNode.prototype.on(self, action, node) -- 38
	if self._successors:has(action) then -- 38
		Log("Error", ("Overwriting successor for action '" .. action) .. "'") -- 40
	end -- 40
	self._successors:set(action, node) -- 42
	return self -- 43
end -- 38
function BaseNode.prototype.getNextNode(self, action) -- 45
	if action == nil then -- 45
		action = "default" -- 45
	end -- 45
	local nextAction = action or "default" -- 46
	local next = self._successors:get(nextAction) -- 46
	if not next and self._successors.size > 0 then -- 46
		Log( -- 48
			"Error", -- 48
			((("Flow ends: '" .. nextAction) .. "' not found in [") .. tostring(__TS__ArrayFrom(self._successors:keys()))) .. "]" -- 48
		) -- 48
	end -- 48
	return next -- 49
end -- 45
function BaseNode.prototype.clone(self) -- 51
	local clonedNode = __TS__ObjectAssign({}, self) -- 52
	setmetatable( -- 53
		clonedNode, -- 53
		getmetatable(self) -- 53
	) -- 53
	clonedNode._params = __TS__ObjectAssign({}, self._params) -- 54
	clonedNode._successors = __TS__New(Map, self._successors) -- 55
	return clonedNode -- 56
end -- 51
local Node = __TS__Class() -- 59
Node.name = "Node" -- 59
__TS__ClassExtends(Node, BaseNode) -- 59
function Node.prototype.____constructor(self, maxRetries, wait) -- 63
	if maxRetries == nil then -- 63
		maxRetries = 1 -- 63
	end -- 63
	if wait == nil then -- 63
		wait = 0 -- 63
	end -- 63
	BaseNode.prototype.____constructor(self) -- 64
	self.currentRetry = 0 -- 62
	self.maxRetries = maxRetries -- 65
	self.wait = wait -- 66
end -- 63
function Node.prototype.execFallback(self, prepRes, ____error) -- 68
	error(____error, 0) -- 69
end -- 68
function Node.prototype._exec(self, prepRes) -- 71
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 71
		do -- 71
			self.currentRetry = 0 -- 72
			while self.currentRetry < self.maxRetries do -- 72
				local ____try = __TS__AsyncAwaiter(function() -- 72
					return ____awaiter_resolve( -- 72
						nil, -- 72
						__TS__Await(self:exec(prepRes)) -- 74
					) -- 74
				end) -- 74
				__TS__Await(____try.catch( -- 73
					____try, -- 73
					function(____, e) -- 73
						if self.currentRetry == self.maxRetries - 1 then -- 73
							return ____awaiter_resolve( -- 73
								nil, -- 73
								__TS__Await(self:execFallback(prepRes, e)) -- 76
							) -- 76
						end -- 76
						if self.wait > 0 then -- 76
							__TS__Await(__TS__New( -- 77
								__TS__Promise, -- 77
								function(____, resolve) -- 77
									Director.systemScheduler:schedule(once(function() -- 78
										sleep(self.wait) -- 79
										resolve(nil, nil) -- 80
									end)) -- 78
								end -- 77
							)) -- 77
						end -- 77
					end -- 77
				)) -- 77
				self.currentRetry = self.currentRetry + 1 -- 72
			end -- 72
		end -- 72
		return ____awaiter_resolve(nil, nil) -- 72
	end) -- 72
end -- 71
local BatchNode = __TS__Class() -- 88
BatchNode.name = "BatchNode" -- 88
__TS__ClassExtends(BatchNode, Node) -- 88
function BatchNode.prototype._exec(self, items) -- 89
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 89
		if not items or not __TS__ArrayIsArray(items) then -- 89
			return ____awaiter_resolve(nil, {}) -- 89
		end -- 89
		local results = {} -- 91
		for ____, item in ipairs(items) do -- 92
			results[#results + 1] = __TS__Await(Node.prototype._exec(self, item)) -- 93
		end -- 93
		return ____awaiter_resolve(nil, results) -- 93
	end) -- 93
end -- 89
local ParallelBatchNode = __TS__Class() -- 98
ParallelBatchNode.name = "ParallelBatchNode" -- 98
__TS__ClassExtends(ParallelBatchNode, Node) -- 98
function ParallelBatchNode.prototype._exec(self, items) -- 99
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 99
		if not items or not __TS__ArrayIsArray(items) then -- 99
			return ____awaiter_resolve(nil, {}) -- 99
		end -- 99
		return ____awaiter_resolve( -- 99
			nil, -- 99
			__TS__PromiseAll(__TS__ArrayMap( -- 101
				items, -- 101
				function(____, item) return Node.prototype._exec(self, item) end -- 101
			)) -- 101
		) -- 101
	end) -- 101
end -- 99
local Flow = __TS__Class() -- 104
Flow.name = "Flow" -- 104
__TS__ClassExtends(Flow, BaseNode) -- 104
function Flow.prototype.____constructor(self, start) -- 106
	BaseNode.prototype.____constructor(self) -- 106
	self.start = start -- 106
end -- 106
function Flow.prototype._orchestrate(self, shared, params) -- 107
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 107
		local current = self.start:clone() -- 108
		local p = params or self._params -- 109
		while current do -- 109
			current:setParams(p) -- 111
			local action = __TS__Await(current:_run(shared)) -- 112
			current = current:getNextNode(action) -- 113
			current = current and current:clone() -- 114
		end -- 114
	end) -- 114
end -- 107
function Flow.prototype._run(self, shared) -- 117
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 117
		local pr = __TS__Await(self:prep(shared)) -- 118
		__TS__Await(self:_orchestrate(shared)) -- 119
		return ____awaiter_resolve( -- 119
			nil, -- 119
			__TS__Await(self:post(shared, pr, nil)) -- 120
		) -- 120
	end) -- 120
end -- 117
function Flow.prototype.exec(self, prepRes) -- 122
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 122
		error( -- 123
			__TS__New(Error, "Flow can't exec."), -- 123
			0 -- 123
		) -- 123
	end) -- 123
end -- 122
local BatchFlow = __TS__Class() -- 126
BatchFlow.name = "BatchFlow" -- 126
__TS__ClassExtends(BatchFlow, Flow) -- 126
function BatchFlow.prototype._run(self, shared) -- 127
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 127
		local batchParams = __TS__Await(self:prep(shared)) -- 128
		for ____, bp in ipairs(batchParams) do -- 129
			local mergedParams = __TS__ObjectAssign({}, self._params, bp) -- 130
			__TS__Await(self:_orchestrate(shared, mergedParams)) -- 131
		end -- 131
		return ____awaiter_resolve( -- 131
			nil, -- 131
			__TS__Await(self:post(shared, batchParams, nil)) -- 133
		) -- 133
	end) -- 133
end -- 127
function BatchFlow.prototype.prep(self, shared) -- 135
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 135
		local empty = {} -- 136
		return ____awaiter_resolve(nil, empty) -- 136
	end) -- 136
end -- 135
local ParallelBatchFlow = __TS__Class() -- 140
ParallelBatchFlow.name = "ParallelBatchFlow" -- 140
__TS__ClassExtends(ParallelBatchFlow, BatchFlow) -- 140
function ParallelBatchFlow.prototype._run(self, shared) -- 141
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 141
		local batchParams = __TS__Await(self:prep(shared)) -- 142
		__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 143
			batchParams, -- 143
			function(____, bp) -- 143
				local mergedParams = __TS__ObjectAssign({}, self._params, bp) -- 144
				return self:_orchestrate(shared, mergedParams) -- 145
			end -- 143
		))) -- 143
		return ____awaiter_resolve( -- 143
			nil, -- 143
			__TS__Await(self:post(shared, batchParams, nil)) -- 147
		) -- 147
	end) -- 147
end -- 141
____exports.BaseNode = BaseNode -- 150
____exports.Node = Node -- 150
____exports.BatchNode = BatchNode -- 150
____exports.ParallelBatchNode = ParallelBatchNode -- 150
____exports.Flow = Flow -- 150
____exports.BatchFlow = BatchFlow -- 150
____exports.ParallelBatchFlow = ParallelBatchFlow -- 150
return ____exports -- 150