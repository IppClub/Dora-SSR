-- [tsx]: TypographyTest.tsx
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
local Label = ____Dora.Label -- 1
local Path = ____Dora.Path -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local reference = ____DoraX.reference -- 2
local toNode = ____DoraX.toNode -- 2
local resultPath = Path(Content.writablePath, "dora-mobile-typography.result") -- 4
Content:save(resultPath, "running\n") -- 5
local fontName = "sarasa-mono-sc-regular" -- 6
local defaultRef = reference() -- 7
local sdfRef = reference() -- 8
local bitmapRef = reference() -- 9
local optionalRef = reference() -- 10
local optional = nil -- 11
local host = toNode(React.createElement( -- 12
	"node", -- 12
	nil, -- 12
	React.createElement("label", {ref = defaultRef, fontName = fontName, fontSize = 16, text = "默认文字 Remix"}), -- 12
	React.createElement("label", { -- 12
		ref = sdfRef, -- 12
		fontName = fontName, -- 12
		fontSize = 16, -- 12
		sdf = true, -- 12
		text = "显式 SDF", -- 12
		y = -40 -- 12
	}), -- 12
	React.createElement("label", { -- 12
		ref = bitmapRef, -- 12
		fontName = fontName, -- 12
		fontSize = 16, -- 12
		sdf = false, -- 12
		text = "显式位图", -- 12
		y = -80 -- 12
	}), -- 12
	React.createElement("label", { -- 12
		ref = optionalRef, -- 12
		fontName = fontName, -- 12
		fontSize = 16, -- 12
		sdf = optional, -- 12
		text = "可空参数", -- 12
		y = -120 -- 12
	}) -- 12
)) -- 12
local function expect(condition, message) -- 19
	if condition then -- 19
		return -- 20
	end -- 20
	Content:save(resultPath, ("failed " .. message) .. "\n") -- 21
	error( -- 22
		__TS__New(Error, message), -- 22
		0 -- 22
	) -- 22
end -- 19
expect(host ~= nil, "JSX scene creation failed") -- 25
if host ~= nil then -- 25
	host:addTo(Director.systemUI) -- 26
end -- 26
thread(function() -- 27
	local label = defaultRef.current -- 28
	local explicit = sdfRef.current -- 29
	local bitmap = bitmapRef.current -- 30
	local nullable = optionalRef.current -- 31
	expect(label ~= nil and explicit ~= nil and bitmap ~= nil and nullable ~= nil, "Label refs missing") -- 32
	if not label or not explicit or not bitmap or not nullable or not host then -- 32
		return -- 33
	end -- 33
	local native = Label(fontName, 16) -- 34
	expect(native ~= nil, "native Label missing") -- 35
	expect(label.smooth.x > 0 and label.effect == (native and native.effect), "JSX default differs from native SDF default") -- 36
	expect(explicit.effect == label.effect and nullable.effect == label.effect, "explicit/undefined SDF differs from default") -- 37
	expect(bitmap.smooth.x == 0 and bitmap.smooth.y == 0 and bitmap.effect ~= label.effect, "explicit false must preserve bitmap rendering") -- 38
	local width = label.width -- 39
	local height = label.height -- 40
	for ____, scale in ipairs({1, 1.5, 2, 3}) do -- 41
		host.scaleX = scale -- 42
		host.scaleY = scale -- 43
		sleep(0.05) -- 44
		expect(label.width == width and label.height == height, "DPR changed logical text metrics") -- 45
	end -- 45
	label.text = "输入法你好 Remix" -- 47
	expect(defaultRef.current == label and label.text == "输入法你好 Remix", "live input Label reference broken") -- 48
	expect(label.effect == explicit.effect, "live text update disabled SDF") -- 49
	local customized = toNode(React.createElement("label", { -- 50
		fontName = fontName, -- 50
		fontSize = 16, -- 50
		smoothLower = 0.65, -- 50
		smoothUpper = 0.73, -- 50
		text = "custom" -- 50
	})) -- 50
	expect( -- 51
		customized ~= nil and math.abs(customized.smooth.x - 0.65) < 0.001 and math.abs(customized.smooth.y - 0.73) < 0.001, -- 51
		"custom smoothing regression" -- 51
	) -- 51
	host:removeFromParent(true) -- 52
	Content:save( -- 53
		resultPath, -- 53
		("passed default=true explicit=true/false undefined=true customSmooth=true scales=1,1.5,2,3 dpr=" .. tostring(App.devicePixelRatio)) .. "\n" -- 53
	) -- 53
end) -- 27
return ____exports -- 27