-- [ts]: SceneImGuiEditor.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local threadLoop = ____Dora.threadLoop -- 2
local ____Model = require("Script.Tools.SceneEditor.Model") -- 3
local createEditorState = ____Model.createEditorState -- 3
local addNode = ____Model.addNode -- 3
local loadSceneFromFile = ____Model.loadSceneFromFile -- 3
local ____Panels = require("Script.Tools.SceneEditor.Panels") -- 4
local drawEditor = ____Panels.drawEditor -- 4
local drawRuntimeError = ____Panels.drawRuntimeError -- 4
local editor = createEditorState() -- 7
if not loadSceneFromFile(editor, Path(Content.writablePath, ".dora", "imgui-editor.scene.json")) then -- 8
	addNode(editor, "Root", "MainScene") -- 8
	addNode(editor, "Camera", "Camera2D", "root") -- 9
end -- 9
local runtimeError = nil -- 11
threadLoop(function() -- 13
	if runtimeError ~= nil then -- 13
		drawRuntimeError(runtimeError) -- 15
		return false -- 16
	end -- 16
	local ok, err = pcall(function() return drawEditor(editor) end) -- 18
	if not ok then -- 18
		runtimeError = tostring(err) -- 20
	end -- 20
	return false -- 22
end) -- 13
____exports.default = editor -- 25
return ____exports -- 25
