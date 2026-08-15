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
local App = ____Dora.App -- 1
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
	local ____temp_0 -- 46
	if action == "" then -- 46
		____temp_0 = nil -- 46
	else -- 46
		____temp_0 = action -- 46
	end -- 46
	local nextAction = ____temp_0 or "default" -- 46
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
			local retry = 0 -- 72
			while retry < self.maxRetries do -- 72
				self.currentRetry = retry -- 73
				local ____hasReturned, ____returnValue -- 73
				local ____try = __TS__AsyncAwaiter(function() -- 73
					____hasReturned = true -- 75
					____returnValue = __TS__Await(self:exec(prepRes)) -- 75
					return -- 75
				end) -- 75
				____try = ____try.catch( -- 75
					____try, -- 75
					function(____, e) -- 75
						return __TS__AsyncAwaiter(function() -- 75
							if retry == self.maxRetries - 1 then -- 75
								____hasReturned = true -- 77
								____returnValue = __TS__Await(self:execFallback(prepRes, e)) -- 77
								return -- 77
							end -- 77
							if self.wait > 0 then -- 77
								__TS__Await(__TS__New( -- 78
									__TS__Promise, -- 78
									function(____, resolve) -- 78
										local resumeAt = App.runningTime + self.wait -- 79
										Director.systemScheduler:schedule(function() -- 80
											if App.runningTime < resumeAt then -- 80
												return false -- 81
											end -- 81
											resolve(nil, nil) -- 82
											return true -- 83
										end) -- 80
									end -- 78
								)) -- 78
							end -- 78
						end) -- 78
					end -- 78
				) -- 78
				__TS__Await(____try) -- 74
				if ____hasReturned then -- 74
					return ____awaiter_resolve(nil, ____returnValue) -- 74
				end -- 74
				retry = retry + 1 -- 72
			end -- 72
		end -- 72
		return ____awaiter_resolve(nil, nil) -- 72
	end) -- 72
end -- 71
local BatchNode = __TS__Class() -- 91
BatchNode.name = "BatchNode" -- 91
__TS__ClassExtends(BatchNode, Node) -- 91
function BatchNode.prototype._exec(self, items) -- 92
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 92
		if not items or not __TS__ArrayIsArray(items) then -- 92
			return ____awaiter_resolve(nil, {}) -- 92
		end -- 92
		local results = {} -- 94
		for ____, item in ipairs(items) do -- 95
			results[#results + 1] = __TS__Await(Node.prototype._exec(self, item)) -- 96
		end -- 96
		return ____awaiter_resolve(nil, results) -- 96
	end) -- 96
end -- 92
local ParallelBatchNode = __TS__Class() -- 101
ParallelBatchNode.name = "ParallelBatchNode" -- 101
__TS__ClassExtends(ParallelBatchNode, Node) -- 101
function ParallelBatchNode.prototype._exec(self, items) -- 102
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 102
		if not items or not __TS__ArrayIsArray(items) then -- 102
			return ____awaiter_resolve(nil, {}) -- 102
		end -- 102
		return ____awaiter_resolve( -- 102
			nil, -- 102
			__TS__PromiseAll(__TS__ArrayMap( -- 104
				items, -- 104
				function(____, item) return Node.prototype._exec(self, item) end -- 104
			)) -- 104
		) -- 104
	end) -- 104
end -- 102
local Flow = __TS__Class() -- 107
Flow.name = "Flow" -- 107
__TS__ClassExtends(Flow, BaseNode) -- 107
function Flow.prototype.____constructor(self, start) -- 109
	BaseNode.prototype.____constructor(self) -- 109
	self.start = start -- 109
end -- 109
function Flow.prototype._orchestrate(self, shared, params) -- 110
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 110
		local current = self.start:clone() -- 111
		local p = params or self._params -- 112
		while current do -- 112
			current:setParams(p) -- 114
			local action = __TS__Await(current:_run(shared)) -- 115
			current = current:getNextNode(action) -- 116
			current = current and current:clone() -- 117
		end -- 117
	end) -- 117
end -- 110
function Flow.prototype._run(self, shared) -- 120
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 120
		local pr = __TS__Await(self:prep(shared)) -- 121
		__TS__Await(self:_orchestrate(shared)) -- 122
		return ____awaiter_resolve( -- 122
			nil, -- 122
			__TS__Await(self:post(shared, pr, nil)) -- 123
		) -- 123
	end) -- 123
end -- 120
function Flow.prototype.exec(self, prepRes) -- 125
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 125
		error( -- 126
			__TS__New(Error, "Flow can't exec."), -- 126
			0 -- 126
		) -- 126
	end) -- 126
end -- 125
local BatchFlow = __TS__Class() -- 129
BatchFlow.name = "BatchFlow" -- 129
__TS__ClassExtends(BatchFlow, Flow) -- 129
function BatchFlow.prototype._run(self, shared) -- 130
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 130
		local batchParams = __TS__Await(self:prep(shared)) -- 131
		for ____, bp in ipairs(batchParams) do -- 132
			local mergedParams = __TS__ObjectAssign({}, self._params, bp) -- 133
			__TS__Await(self:_orchestrate(shared, mergedParams)) -- 134
		end -- 134
		return ____awaiter_resolve( -- 134
			nil, -- 134
			__TS__Await(self:post(shared, batchParams, nil)) -- 136
		) -- 136
	end) -- 136
end -- 130
function BatchFlow.prototype.prep(self, shared) -- 138
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 138
		local empty = {} -- 139
		return ____awaiter_resolve(nil, empty) -- 139
	end) -- 139
end -- 138
local ParallelBatchFlow = __TS__Class() -- 143
ParallelBatchFlow.name = "ParallelBatchFlow" -- 143
__TS__ClassExtends(ParallelBatchFlow, BatchFlow) -- 143
function ParallelBatchFlow.prototype._run(self, shared) -- 144
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 144
		local batchParams = __TS__Await(self:prep(shared)) -- 145
		__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 146
			batchParams, -- 146
			function(____, bp) -- 146
				local mergedParams = __TS__ObjectAssign({}, self._params, bp) -- 147
				return self:_orchestrate(shared, mergedParams) -- 148
			end -- 146
		))) -- 146
		return ____awaiter_resolve( -- 146
			nil, -- 146
			__TS__Await(self:post(shared, batchParams, nil)) -- 150
		) -- 150
	end) -- 150
end -- 144
____exports.BaseNode = BaseNode -- 153
____exports.Node = Node -- 153
____exports.BatchNode = BatchNode -- 153
____exports.ParallelBatchNode = ParallelBatchNode -- 153
____exports.Flow = Flow -- 153
____exports.BatchFlow = BatchFlow -- 153
____exports.ParallelBatchFlow = ParallelBatchFlow -- 153
return ____exports -- 153