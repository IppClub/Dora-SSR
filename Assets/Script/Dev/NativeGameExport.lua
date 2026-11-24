-- [yue]: Script/Dev/NativeGameExport.yue
local _module_0 = { } -- 1
local App, Content, Path -- 1
do -- 1
	local _obj_0 = require("Dora") -- 1
	App, Content, Path = _obj_0.App, _obj_0.Content, _obj_0.Path -- 1
end -- 1
local packageFileAllowed = require("Script.Dev.Mobile.Package").packageFileAllowed -- 2
local runtimeRoots = { -- 4
	"Audio", -- 4
	"Font", -- 4
	"Image", -- 4
	"Shader", -- 4
	"Script/Lib", -- 4
	"LICENSES", -- 4
	"GodotRuntimeNotices", -- 4
	"gamecontrollerdb.txt" -- 4
} -- 4
local entryExtensions = { -- 5
	"lua", -- 5
	"yue", -- 5
	"tl", -- 5
	"xml", -- 5
	"wasm" -- 5
} -- 5
local nativeFileAllowed -- 8
nativeFileAllowed = function(file) -- 8
	return file:sub(1, 1) ~= "." and packageFileAllowed(file) -- 8
end -- 8
local fail -- 10
fail = function(zh, en) -- 10
	return error(App.locale:match("^zh") and zh or en, 0) -- 10
end -- 10
local copyFile -- 12
copyFile = function(src, dst) -- 12
	Content:mkdir(Path:getPath(dst)) -- 13
	if not Content:copyAsync(src, dst) then -- 14
		return fail("复制失败：" .. tostring(src), "Could not copy: " .. tostring(src)) -- 15
	end -- 14
end -- 12
local projectId -- 17
projectId = function(root) -- 17
	local metadata = Path(root, ".dora") -- 18
	local file = Path(metadata, "native-export-id") -- 19
	if Content:exist(file) then -- 20
		local id = Content:load(file) -- 21
		if id and #id == 32 and id:match("^[0-9a-f]+$") then -- 22
			return id -- 22
		end -- 22
		fail("项目导出 ID 无效", "Invalid project export ID") -- 23
	end -- 20
	local id = (require("dora.new_game_id"))() -- 24
	Content:mkdir(metadata) -- 25
	if not Content:save(file, id) then -- 26
		fail("无法保存项目导出 ID", "Could not save the project export ID") -- 27
	end -- 26
	return id -- 28
end -- 17
local bootstrap -- 30
bootstrap = function(entry) -- 30
	return [[local Dora = require("Dora")
local Content, Path = Dora.Content, Dora.Path
local root = Path(Content.assetPath, "Game")
local paths = {root, Path(Content.assetPath, "Script", "Lib"), Content.assetPath}
local scripts = Path(root, "Script")
if Content:exist(scripts) then table.insert(paths, 1, scripts) end
Content.searchPaths = paths
local run = require(Path(root, ]] .. string.format("%q", entry) .. [[))
if type(run) == "function" then run() end
]] -- 30
end -- 30
local prepareGame -- 42
prepareGame = function(root, fileName, assets) -- 42
	local entry = Path:getRelative(fileName, root):gsub("\\", "/") -- 43
	if not nativeFileAllowed(entry) then -- 44
		fail("游戏入口必须在项目内", "The game entry must be inside the project") -- 45
	end -- 44
	local runnable -- 46
	for _index_0 = 1, #entryExtensions do -- 46
		local ext = entryExtensions[_index_0] -- 46
		if Content:exist(Path(root, tostring(entry) .. "." .. tostring(ext))) then -- 47
			runnable = true -- 47
			break -- 47
		end -- 47
	end -- 46
	if not runnable then -- 48
		fail("请先在 IDE 中编译游戏", "Build the game in the IDE first") -- 49
	end -- 48
	local _list_0 = Content:getAllFiles(root) -- 50
	for _index_0 = 1, #_list_0 do -- 50
		local file = _list_0[_index_0] -- 50
		if nativeFileAllowed(file) then -- 51
			copyFile(Path(root, file), Path(assets, "Game", file)) -- 52
		end -- 51
	end -- 50
	Content:mkdir(Path(assets, "Script")) -- 53
	if not Content:save(Path(assets, "Script", "init.lua"), bootstrap(entry)) then -- 54
		return fail("无法写入游戏入口", "Could not write the game entry") -- 55
	end -- 54
end -- 42
_module_0["prepareGame"] = prepareGame -- 42
local exportWindows -- 57
exportWindows = function(root, fileName, title, destination) -- 57
	local name = title:gsub('[\\/:*?"<>|%c]', "_"):match("^%s*(.-)%s*$") -- 58
	if not name or name == "" then -- 59
		name = "Game" -- 59
	end -- 59
	name = "Game-" .. tostring(name) -- 60
	do -- 61
		local last = utf8.offset(name, 61) -- 61
		if last then -- 61
			name = name:sub(1, last - 1) -- 62
		end -- 61
	end -- 61
	local archive = Path(destination, tostring(name) .. "-Windows.zip") -- 63
	local suffix = 2 -- 64
	while Content:exist(archive) do -- 65
		archive = Path(destination, tostring(name) .. "-Windows-" .. tostring(suffix) .. ".zip") -- 66
		suffix = suffix + 1 -- 67
	end -- 65
	local assetRoot = Content.assetPath -- 68
	local cache = Path(Content.appPath, ".native-export") -- 69
	local stage = Path(cache, "stage-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 70
	local assets = Path(stage, "game") -- 71
	local tempZip = Path(destination, ".dora-export-" .. tostring(Path:getName(stage)) .. ".tmp") -- 72
	local success, result = pcall(function() -- 73
		local id = projectId(root) -- 74
		if not Content:mkdir(assets) then -- 75
			fail("无法创建导出目录", "Could not create the export directory") -- 76
		end -- 75
		prepareGame(root, fileName, assets) -- 77
		local exe = App.executablePath -- 78
		local needsGodot = require("Script.Dev.GodotDependency").needsGodot -- 79
		if needsGodot(Path(assets, "Game")) then -- 80
			local godot = Path(Path:getPath(exe), "dora_godot.dll") -- 81
			if not (Content:exist(godot) and not Content:isdir(godot)) then -- 82
				fail("此项目需要 Godot，请使用包含 Godot 运行库的 Windows 版 Dora 导出", "Use a Windows build of Dora with Godot to export this project.") -- 83
			end -- 82
			copyFile(godot, Path(assets, "dora_godot.dll")) -- 84
		end -- 80
		for _index_0 = 1, #runtimeRoots do -- 85
			local item = runtimeRoots[_index_0] -- 85
			local src = Path(assetRoot, item) -- 86
			if Content:isdir(src) then -- 87
				local _list_0 = Content:getAllFiles(src) -- 88
				for _index_1 = 1, #_list_0 do -- 88
					local file = _list_0[_index_1] -- 88
					if item == "Audio" and file == "GeneralUserGS.sf3" then -- 89
						goto _continue_0 -- 89
					end -- 89
					if item == "Image" and file:gsub("\\", "/") == "Mobile/dora-remix-states.png" then -- 90
						goto _continue_0 -- 90
					end -- 90
					copyFile(Path(src, file), Path(assets, item, file)) -- 91
					::_continue_0:: -- 89
				end -- 88
			elseif Content:exist(src) then -- 92
				copyFile(src, Path(assets, item)) -- 93
			end -- 87
		end -- 85
		copyFile(exe, Path(assets, tostring(name) .. ".exe")) -- 94
		if not Content:save(Path(assets, "dora-game-id"), id) then -- 95
			fail("无法写入游戏标识", "Could not write the game ID") -- 96
		end -- 95
		if not Content:zipAsync(assets, tempZip) then -- 97
			fail("无法创建游戏 ZIP", "Could not create the game ZIP") -- 98
		end -- 97
		if not Content:exist(archive) and Content:move(tempZip, archive) then -- 99
			return archive -- 100
		end -- 99
		return fail("无法保存游戏 ZIP", "Could not save the game ZIP") -- 101
	end) -- 73
	if Content:exist(stage) then -- 102
		Content:remove(stage) -- 102
	end -- 102
	if Content:exist(tempZip) then -- 103
		Content:remove(tempZip) -- 103
	end -- 103
	if not success then -- 104
		error(result, 0) -- 104
	end -- 104
	return result -- 105
end -- 57
_module_0["exportWindows"] = exportWindows -- 57
local exportAndroid -- 107
exportAndroid = function(root, fileName, title) -- 107
	local dispatch = require("dora.android_game_export") -- 108
	local stage = Path(Content.appPath, ".native-export", "android-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 109
	local success, result = pcall(function() -- 110
		if not Content:mkdir(stage) then -- 111
			fail("无法创建导出目录", "Could not create the export directory") -- 112
		end -- 111
		prepareGame(root, fileName, Path(stage, "assets")) -- 113
		if not dispatch(stage, projectId(root), title) then -- 114
			return fail("无法打开 APK 导出", "Could not open APK export") -- 115
		end -- 114
	end) -- 110
	if not success then -- 116
		if Content:exist(stage) then -- 117
			Content:remove(stage) -- 117
		end -- 117
		return error(result, 0) -- 118
	end -- 116
end -- 107
_module_0["exportAndroid"] = exportAndroid -- 107
return _module_0 -- 1
