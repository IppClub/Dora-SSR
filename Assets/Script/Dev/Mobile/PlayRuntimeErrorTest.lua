-- [ts]: PlayRuntimeErrorTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local Node = ____Dora.Node -- 1
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____PlayOverlay = require("Dev.Mobile.PlayOverlay") -- 2
local startMobilePlayOverlay = ____PlayOverlay.startMobilePlayOverlay -- 2
local resultPath = Path(Content.writablePath, "dora-mobile-play-runtime-error.result") -- 4
local exitCount = 0 -- 5
local errorCount = 0 -- 6
local errorMessage = "" -- 7
thread(function() -- 9
	local overlay = startMobilePlayOverlay({ -- 10
		onExit = function() -- 11
			exitCount = exitCount + 1 -- 11
		end, -- 11
		onRuntimeError = function(message) -- 12
			errorCount = errorCount + 1 -- 13
			errorMessage = message -- 14
		end -- 12
	}) -- 12
	local crashingNode = Node():addTo(Director.ui) -- 17
	crashingNode:schedule(function() -- 18
		error( -- 19
			__TS__New(Error, "mobile runtime failure injection"), -- 19
			0 -- 19
		) -- 19
	end) -- 18
	sleep(0.8) -- 21
	if errorCount ~= 1 then -- 21
		error( -- 23
			__TS__New( -- 23
				Error, -- 23
				"runtime error callback count mismatch: " .. tostring(errorCount) -- 23
			), -- 23
			0 -- 23
		) -- 23
	end -- 23
	if exitCount ~= 0 then -- 23
		error( -- 24
			__TS__New(Error, "runtime failure incorrectly used the normal exit callback"), -- 24
			0 -- 24
		) -- 24
	end -- 24
	if (string.find(errorMessage, "mobile runtime failure injection", nil, true) or 0) - 1 < 0 then -- 24
		error( -- 25
			__TS__New(Error, "runtime traceback was not forwarded"), -- 25
			0 -- 25
		) -- 25
	end -- 25
	if overlay.parent ~= nil then -- 25
		error( -- 26
			__TS__New(Error, "play overlay was not removed after runtime failure"), -- 26
			0 -- 26
		) -- 26
	end -- 26
	Content:save(resultPath, "passed runtimeError=1 overlayRemoved=1\n") -- 27
	crashingNode:removeFromParent(true) -- 28
end) -- 9
return ____exports -- 9
