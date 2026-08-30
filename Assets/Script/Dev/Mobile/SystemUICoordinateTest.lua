-- [ts]: SystemUICoordinateTest.ts
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
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local Node = ____Dora.Node -- 1
local Path = ____Dora.Path -- 1
local Vec2 = ____Dora.Vec2 -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local resultPath = Path(Content.writablePath, "dora-mobile-system-ui-coordinate.result") -- 3
Content:save(resultPath, "running\n") -- 4
thread(function() -- 5
	local ui = Node():addTo(Director.ui) -- 6
	local system = Node():addTo(Director.systemUI) -- 7
	local point = Vec2(20, -App.bufferSize.height * 0.3) -- 8
	local uiPoint -- 9
	local systemPoint -- 10
	ui:convertToWindowSpace( -- 11
		point, -- 11
		function(pos) -- 11
			uiPoint = {x = pos.x, y = pos.y} -- 11
		end -- 11
	) -- 11
	system:convertToWindowSpace( -- 12
		point, -- 12
		function(pos) -- 12
			systemPoint = {x = pos.x, y = pos.y} -- 12
		end -- 12
	) -- 12
	sleep(0.3) -- 13
	ui:removeFromParent(true) -- 14
	system:removeFromParent(true) -- 15
	local expectedX = App.winSize.width * (0.5 + 20 / App.bufferSize.width) -- 16
	local expectedY = App.winSize.height * 0.8 -- 17
	if not uiPoint or not systemPoint or math.abs(uiPoint.x - systemPoint.x) > 1 or math.abs(uiPoint.y - systemPoint.y) > 1 or math.abs(systemPoint.x - expectedX) > 1 or math.abs(systemPoint.y - expectedY) > 1 then -- 17
		Content:save( -- 20
			resultPath, -- 20
			((("failed UI y=" .. tostring(uiPoint and uiPoint.y)) .. " SystemUI y=") .. tostring(systemPoint and systemPoint.y)) .. "\n" -- 20
		) -- 20
		error( -- 21
			__TS__New(Error, "UI/SystemUI window coordinates differ"), -- 21
			0 -- 21
		) -- 21
	end -- 21
	Content:save( -- 23
		resultPath, -- 23
		((("passed x=" .. tostring(systemPoint.x)) .. " y=") .. tostring(systemPoint.y)) .. "\n" -- 23
	) -- 23
end) -- 5
return ____exports -- 5