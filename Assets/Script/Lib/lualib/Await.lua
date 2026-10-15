local __TS__AsyncAwaiter, __TS__Await
do
	local ____coroutine = _G.coroutine or ({})
	local cocreate = ____coroutine.create
	local coresume = ____coroutine.resume
	local costatus = ____coroutine.status
	local coyield = ____coroutine.yield
	function __TS__AsyncAwaiter(generator)
		return __TS__New(
			__TS__Promise,
			function(____, resolve, reject)
				local fulfilled, step, resolved, asyncCoroutine
				function fulfilled(self, value)
					local success, resultOrError = coresume(asyncCoroutine, value)
					if success then
						return step(resultOrError)
					end
					return reject(nil, resultOrError)
				end
				function step(result)
					if resolved then
						return
					end
					if costatus(asyncCoroutine) == "dead" then
						return resolve(nil, result)
					end
					return __TS__Promise.resolve(result):addCallbacks(fulfilled, reject)
				end
				resolved = false
				asyncCoroutine = cocreate(generator)
				local success, resultOrError = coresume(
					asyncCoroutine,
					function(____, v)
						resolved = true
						return __TS__Promise.resolve(v):addCallbacks(resolve, reject)
					end
				)
				if success then
					return step(resultOrError)
				else
					return reject(nil, resultOrError)
				end
			end
		)
	end
	function __TS__Await(thing)
		return coyield(thing)
	end
end
