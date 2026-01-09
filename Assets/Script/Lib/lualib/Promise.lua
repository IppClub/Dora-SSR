local __TS__Promise
do
	local function makeDeferredPromiseFactory()
		local resolve
		local reject
		local function executor(____, res, rej)
			resolve = res
			reject = rej
		end
		return function()
			local promise = __TS__New(__TS__Promise, executor)
			return promise, resolve, reject
		end
	end
	local makeDeferredPromise = makeDeferredPromiseFactory()
	local function isPromiseLike(value)
		return __TS__InstanceOf(value, __TS__Promise)
	end
	local function doNothing(self)
	end
	local ____pcall = _G.pcall
	__TS__Promise = __TS__Class()
	__TS__Promise.name = "__TS__Promise"
	function __TS__Promise.prototype.____constructor(self, executor)
		self.state = 0
		self.fulfilledCallbacks = {}
		self.rejectedCallbacks = {}
		self.finallyCallbacks = {}
		local success, ____error = ____pcall(
			executor,
			nil,
			function(____, v) return self:resolve(v) end,
			function(____, err) return self:reject(err) end
		)
		if not success then
			self:reject(____error)
		end
	end
	function __TS__Promise.resolve(value)
		if __TS__InstanceOf(value, __TS__Promise) then
			return value
		end
		local promise = __TS__New(__TS__Promise, doNothing)
		promise.state = 1
		promise.value = value
		return promise
	end
	function __TS__Promise.reject(reason)
		local promise = __TS__New(__TS__Promise, doNothing)
		promise.state = 2
		promise.rejectionReason = reason
		return promise
	end
	__TS__Promise.prototype["then"] = function(self, onFulfilled, onRejected)
		local promise, resolve, reject = makeDeferredPromise()
		self:addCallbacks(
			onFulfilled and self:createPromiseResolvingCallback(onFulfilled, resolve, reject) or resolve,
			onRejected and self:createPromiseResolvingCallback(onRejected, resolve, reject) or reject
		)
		return promise
	end
	function __TS__Promise.prototype.addCallbacks(self, fulfilledCallback, rejectedCallback)
		if self.state == 1 then
			return fulfilledCallback(nil, self.value)
		end
		if self.state == 2 then
			return rejectedCallback(nil, self.rejectionReason)
		end
		local ____self_fulfilledCallbacks_0 = self.fulfilledCallbacks
		____self_fulfilledCallbacks_0[#____self_fulfilledCallbacks_0 + 1] = fulfilledCallback
		local ____self_rejectedCallbacks_1 = self.rejectedCallbacks
		____self_rejectedCallbacks_1[#____self_rejectedCallbacks_1 + 1] = rejectedCallback
	end
	function __TS__Promise.prototype.catch(self, onRejected)
		return self["then"](self, nil, onRejected)
	end
	function __TS__Promise.prototype.finally(self, onFinally)
		if onFinally then
			local ____self_finallyCallbacks_2 = self.finallyCallbacks
			____self_finallyCallbacks_2[#____self_finallyCallbacks_2 + 1] = onFinally
			if self.state ~= 0 then
				onFinally(nil)
			end
		end
		return self
	end
	function __TS__Promise.prototype.resolve(self, value)
		if isPromiseLike(value) then
			return value:addCallbacks(
				function(____, v) return self:resolve(v) end,
				function(____, err) return self:reject(err) end
			)
		end
		if self.state == 0 then
			self.state = 1
			self.value = value
			return self:invokeCallbacks(self.fulfilledCallbacks, value)
		end
	end
	function __TS__Promise.prototype.reject(self, reason)
		if self.state == 0 then
			self.state = 2
			self.rejectionReason = reason
			return self:invokeCallbacks(self.rejectedCallbacks, reason)
		end
	end
	function __TS__Promise.prototype.invokeCallbacks(self, callbacks, value)
		local callbacksLength = #callbacks
		local finallyCallbacks = self.finallyCallbacks
		local finallyCallbacksLength = #finallyCallbacks
		if callbacksLength ~= 0 then
			for i = 1, callbacksLength - 1 do
				callbacks[i](callbacks, value)
			end
			if finallyCallbacksLength == 0 then
				return callbacks[callbacksLength](callbacks, value)
			end
			callbacks[callbacksLength](callbacks, value)
		end
		if finallyCallbacksLength ~= 0 then
			for i = 1, finallyCallbacksLength - 1 do
				finallyCallbacks[i](finallyCallbacks)
			end
			return finallyCallbacks[finallyCallbacksLength](finallyCallbacks)
		end
	end
	function __TS__Promise.prototype.createPromiseResolvingCallback(self, f, resolve, reject)
		return function(____, value)
			local success, resultOrError = ____pcall(f, nil, value)
			if not success then
				return reject(nil, resultOrError)
			end
			return self:handleCallbackValue(resultOrError, resolve, reject)
		end
	end
	function __TS__Promise.prototype.handleCallbackValue(self, value, resolve, reject)
		if isPromiseLike(value) then
			local nextpromise = value
			if nextpromise.state == 1 then
				return resolve(nil, nextpromise.value)
			elseif nextpromise.state == 2 then
				return reject(nil, nextpromise.rejectionReason)
			else
				return nextpromise:addCallbacks(resolve, reject)
			end
		else
			return resolve(nil, value)
		end
	end
end
