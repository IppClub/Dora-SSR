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
local thread = ____Dora.thread -- 1
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
		return ____awaiter_resolve( -- 71
			nil, -- 71
			__TS__New( -- 72
				__TS__Promise, -- 72
				function(____, resolve, reject) -- 72
					thread(function() -- 73
						return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 73
							do -- 73
								self.currentRetry = 0 -- 74
								while self.currentRetry < self.maxRetries do -- 74
									local result -- 75
									local done = false -- 76
									local ____try = __TS__AsyncAwaiter(function() -- 76
										result = __TS__Await(self:exec(prepRes)) -- 78
										done = true -- 79
									end) -- 79
									__TS__Await(____try.catch( -- 77
										____try, -- 77
										function(____, e) -- 77
											if self.currentRetry == self.maxRetries - 1 then -- 77
												local ____try = __TS__AsyncAwaiter(function() -- 77
													return ____awaiter_resolve( -- 77
														nil, -- 77
														self:execFallback(prepRes, e) -- 83
													) -- 83
												end) -- 83
												__TS__Await(____try.catch( -- 82
													____try, -- 82
													function(____, e) -- 82
														reject(nil, e) -- 85
													end -- 85
												)) -- 85
											end -- 85
											if self.wait > 0 then -- 85
												sleep(self.wait) -- 89
											end -- 89
										end -- 89
									)) -- 89
									if done then -- 89
										resolve(nil, result) -- 93
										return ____awaiter_resolve(nil, true) -- 93
									end -- 93
									self.currentRetry = self.currentRetry + 1 -- 74
								end -- 74
							end -- 74
						end) -- 74
					end) -- 73
				end -- 72
			) -- 72
		) -- 72
	end) -- 72
end -- 71
local BatchNode = __TS__Class() -- 101
BatchNode.name = "BatchNode" -- 101
__TS__ClassExtends(BatchNode, Node) -- 101
function BatchNode.prototype._exec(self, items) -- 102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 102
		if not items or not __TS__ArrayIsArray(items) then -- 102
			return ____awaiter_resolve(nil, {}) -- 102
		end -- 102
		local results = {} -- 104
		for ____, item in ipairs(items) do -- 105
			results[#results + 1] = __TS__Await(Node.prototype._exec(self, item)) -- 106
		end -- 106
		return ____awaiter_resolve(nil, results) -- 106
	end) -- 106
end -- 102
local ParallelBatchNode = __TS__Class() -- 111
ParallelBatchNode.name = "ParallelBatchNode" -- 111
__TS__ClassExtends(ParallelBatchNode, Node) -- 111
function ParallelBatchNode.prototype._exec(self, items) -- 112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 112
		if not items or not __TS__ArrayIsArray(items) then -- 112
			return ____awaiter_resolve(nil, {}) -- 112
		end -- 112
		return ____awaiter_resolve( -- 112
			nil, -- 112
			__TS__PromiseAll(__TS__ArrayMap( -- 114
				items, -- 114
				function(____, item) return Node.prototype._exec(self, item) end -- 114
			)) -- 114
		) -- 114
	end) -- 114
end -- 112
local Flow = __TS__Class() -- 117
Flow.name = "Flow" -- 117
__TS__ClassExtends(Flow, BaseNode) -- 117
function Flow.prototype.____constructor(self, start) -- 119
	BaseNode.prototype.____constructor(self) -- 119
	self.start = start -- 119
end -- 119
function Flow.prototype._orchestrate(self, shared, params) -- 120
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 120
		local current = self.start:clone() -- 121
		local p = params or self._params -- 122
		while current do -- 122
			current:setParams(p) -- 124
			local action = __TS__Await(current:_run(shared)) -- 125
			current = current:getNextNode(action) -- 126
			current = current and current:clone() -- 127
		end -- 127
	end) -- 127
end -- 120
function Flow.prototype._run(self, shared) -- 130
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 130
		local pr = __TS__Await(self:prep(shared)) -- 131
		__TS__Await(self:_orchestrate(shared)) -- 132
		return ____awaiter_resolve( -- 132
			nil, -- 132
			__TS__Await(self:post(shared, pr, nil)) -- 133
		) -- 133
	end) -- 133
end -- 130
function Flow.prototype.exec(self, prepRes) -- 135
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 135
		error( -- 136
			__TS__New(Error, "Flow can't exec."), -- 136
			0 -- 136
		) -- 136
	end) -- 136
end -- 135
local BatchFlow = __TS__Class() -- 139
BatchFlow.name = "BatchFlow" -- 139
__TS__ClassExtends(BatchFlow, Flow) -- 139
function BatchFlow.prototype._run(self, shared) -- 140
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 140
		local batchParams = __TS__Await(self:prep(shared)) -- 141
		for ____, bp in ipairs(batchParams) do -- 142
			local mergedParams = __TS__ObjectAssign({}, self._params, bp) -- 143
			__TS__Await(self:_orchestrate(shared, mergedParams)) -- 144
		end -- 144
		return ____awaiter_resolve( -- 144
			nil, -- 144
			__TS__Await(self:post(shared, batchParams, nil)) -- 146
		) -- 146
	end) -- 146
end -- 140
function BatchFlow.prototype.prep(self, shared) -- 148
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 148
		local empty = {} -- 149
		return ____awaiter_resolve(nil, empty) -- 149
	end) -- 149
end -- 148
local ParallelBatchFlow = __TS__Class() -- 153
ParallelBatchFlow.name = "ParallelBatchFlow" -- 153
__TS__ClassExtends(ParallelBatchFlow, BatchFlow) -- 153
function ParallelBatchFlow.prototype._run(self, shared) -- 154
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 154
		local batchParams = __TS__Await(self:prep(shared)) -- 155
		__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 156
			batchParams, -- 156
			function(____, bp) -- 156
				local mergedParams = __TS__ObjectAssign({}, self._params, bp) -- 157
				return self:_orchestrate(shared, mergedParams) -- 158
			end -- 156
		))) -- 156
		return ____awaiter_resolve( -- 156
			nil, -- 156
			__TS__Await(self:post(shared, batchParams, nil)) -- 160
		) -- 160
	end) -- 160
end -- 154
____exports.BaseNode = BaseNode -- 163
____exports.Node = Node -- 163
____exports.BatchNode = BatchNode -- 163
____exports.ParallelBatchNode = ParallelBatchNode -- 163
____exports.Flow = Flow -- 163
____exports.BatchFlow = BatchFlow -- 163
____exports.ParallelBatchFlow = ParallelBatchFlow -- 163
return ____exports -- 163