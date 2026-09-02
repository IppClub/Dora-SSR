-- [ts]: PlayOverlayInteractionTest.ts
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
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____PlayOverlay = require("Dev.Mobile.PlayOverlay") -- 2
local resolvePlayHandleY = ____PlayOverlay.resolvePlayHandleY -- 2
local startMobilePlayOverlay = ____PlayOverlay.startMobilePlayOverlay -- 2
local resultPath = Path(Content.writablePath, "dora-mobile-play-overlay.result") -- 4
local function find(node, tag) -- 6
	if node.tag == tag then -- 6
		return node -- 7
	end -- 7
	local result -- 8
	node:eachChild(function(child) -- 9
		result = find(child, tag) -- 9
		return result ~= nil -- 9
	end) -- 9
	return result -- 10
end -- 6
thread(function() -- 13
	local exits = 0 -- 14
	local overlay = startMobilePlayOverlay({onExit = function() -- 15
		exits = exits + 1 -- 15
	end}) -- 15
	local ok, err = xpcall( -- 16
		function() -- 16
			if not find(overlay, "mobile-play-handle") or find(overlay, "mobile-play-exit") then -- 16
				error( -- 17
					__TS__New(Error, "overlay did not start as an edge handle"), -- 17
					0 -- 17
				) -- 17
			end -- 17
			local firstY = resolvePlayHandleY(100, 300, 310, 600) -- 18
			local laterY = resolvePlayHandleY(100, 300, 350, 600) -- 19
			if firstY ~= 110 or laterY ~= 150 then -- 19
				error( -- 20
					__TS__New(Error, "dragging does not track the absolute pointer path"), -- 20
					0 -- 20
				) -- 20
			end -- 20
			local handle = find(overlay, "mobile-play-handle") -- 21
			handle:emit("Tapped") -- 22
			if not find(overlay, "mobile-play-exit") then -- 22
				error( -- 23
					__TS__New(Error, "edge handle did not expand"), -- 23
					0 -- 23
				) -- 23
			end -- 23
			sleep(3.2) -- 24
			local collapsed = find(overlay, "mobile-play-handle") -- 25
			if not collapsed or find(overlay, "mobile-play-exit") then -- 25
				error( -- 26
					__TS__New(Error, "exit control did not auto-hide"), -- 26
					0 -- 26
				) -- 26
			end -- 26
			collapsed:emit("Tapped") -- 27
			local exit = find(overlay, "mobile-play-exit") -- 28
			if not exit then -- 28
				error( -- 29
					__TS__New(Error, "collapsed handle did not expand"), -- 29
					0 -- 29
				) -- 29
			end -- 29
			exit:emit("Tapped") -- 30
			if exits ~= 1 or overlay.parent ~= nil then -- 30
				error( -- 31
					__TS__New(Error, "expanded exit control did not exit once"), -- 31
					0 -- 31
				) -- 31
			end -- 31
		end, -- 16
		debug.traceback -- 32
	) -- 32
	overlay:removeFromParent(true) -- 33
	Content:save( -- 34
		resultPath, -- 34
		ok and "passed handle=1 absoluteDrag=1 expanded=1 autoHidden=1 reopened=1 exit=1\n" or "failed: " .. tostring(err) -- 34
	) -- 34
end) -- 13
return ____exports -- 13
