-- [ts]: surface3d.ts
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
local Camera3D = ____Dora.Camera3D -- 4
local Content = ____Dora.Content -- 5
local Director = ____Dora.Director -- 6
local Label = ____Dora.Label -- 7
local Size = ____Dora.Size -- 8
local Surface3D = ____Dora.Surface3D -- 9
local Vec3 = ____Dora.Vec3 -- 10
local threadLoop = ____Dora.threadLoop -- 11
local view = Director.entry -- 14
local camera = Camera3D() -- 15
camera:lookAt( -- 16
	Vec3(0, 1.5, 5), -- 16
	Vec3(0, 1.5, 0) -- 16
) -- 16
Director:pushCamera(camera) -- 17
local label = Label("sarasa-mono-sc-regular", 24) -- 19
if not label then -- 19
	error( -- 20
		__TS__New(Error, "failed to create label"), -- 20
		0 -- 20
	) -- 20
end -- 20
label.text = "Hello from 2D" -- 21
local surface = Surface3D( -- 23
	label, -- 23
	Size(3, 1), -- 23
	Size(512, 128) -- 23
) -- 23
if not surface then -- 23
	error( -- 24
		__TS__New(Error, "failed to create Surface3D"), -- 24
		0 -- 24
	) -- 24
end -- 24
surface.position = Vec3(0, 1.5, 0) -- 25
surface.billboard = "YAxis" -- 26
view:addChild(surface) -- 27
local frames = 0 -- 29
threadLoop(function() -- 30
	frames = frames + 1 -- 31
	if frames >= 60 then -- 31
		Content:save("/tmp/surface3d-tutorial.result", surface.content == label and "passed" or "failed") -- 33
		return true -- 34
	end -- 34
	return false -- 36
end) -- 30
return ____exports -- 30