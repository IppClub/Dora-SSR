-- [yue]: Script/Dev/NativeGameExport.yue
local _module_0 = { } -- 1
local App, Content, Path, wait -- 1
do -- 1
	local _obj_0 = require("Dora") -- 1
	App, Content, Path, wait = _obj_0.App, _obj_0.Content, _obj_0.Path, _obj_0.wait -- 1
end -- 1
local projectFileAllowed = require("Script.Dev.ExportPolicy").projectFileAllowed -- 2
local needsGodot = require("Script.Dev.GodotDependency").needsGodot -- 3
local runtimeRoots = { -- 5
	"Audio", -- 5
	"Font", -- 5
	"Image", -- 5
	"Shader", -- 5
	"Script/Lib", -- 5
	"LICENSES", -- 5
	"GodotRuntimeNotices", -- 5
	"gamecontrollerdb.txt" -- 5
} -- 5
local entryExtensions = { -- 6
	"lua", -- 6
	"yue", -- 6
	"tl", -- 6
	"xml", -- 6
	"wasm" -- 6
} -- 6
local fail -- 8
fail = function(zh, en) -- 8
	return error(App.locale:match("^zh") and zh or en, 0) -- 8
end -- 8
local copyFile -- 10
copyFile = function(src, dst) -- 10
	Content:mkdir(Path:getPath(dst)) -- 11
	if not Content:copyAsync(src, dst) then -- 12
		return fail("复制失败：" .. tostring(src), "Could not copy: " .. tostring(src)) -- 13
	end -- 12
end -- 10
local copyProject -- 15
copyProject = function(root, folder) -- 15
	local _list_0 = Content:getAllFiles(root) -- 17
	for _index_0 = 1, #_list_0 do -- 17
		local file = _list_0[_index_0] -- 17
		if projectFileAllowed(file) then -- 18
			copyFile(Path(root, file), Path(folder, file)) -- 19
		end -- 18
	end -- 17
	return needsGodot(folder) -- 20
end -- 15
local projectId -- 22
projectId = function(root) -- 22
	local metadata = Path(root, ".dora") -- 23
	local file = Path(metadata, "native-export-id") -- 24
	if Content:exist(file) then -- 25
		local id = Content:load(file) -- 26
		if id and #id == 32 and id:match("^[0-9a-f]+$") then -- 27
			return id -- 27
		end -- 27
		fail("项目导出 ID 无效", "Invalid project export ID") -- 28
	end -- 25
	local id = (require("dora.new_game_id"))() -- 29
	Content:mkdir(metadata) -- 30
	if not Content:save(file, id) then -- 31
		fail("无法保存项目导出 ID", "Could not save the project export ID") -- 32
	end -- 31
	return id -- 33
end -- 22
local bootstrap -- 35
bootstrap = function(entry) -- 35
	return [[local Dora = require("Dora")
local Content, Path = Dora.Content, Dora.Path
local root = Path(Content.assetPath, "Game")
local paths = {root, Path(Content.assetPath, "Script", "Lib"), Content.assetPath}
local scripts = Path(root, "Script")
if Content:exist(scripts) then table.insert(paths, 1, scripts) end
Content.searchPaths = paths
local run = require(Path(root, ]] .. string.format("%q", entry) .. [[))
if type(run) == "function" then run() end
]] -- 35
end -- 35
local prepareGame -- 47
prepareGame = function(root, fileName, assets) -- 47
	local entry = Path:getRelative(fileName, root):gsub("\\", "/") -- 48
	if not projectFileAllowed(entry) then -- 49
		fail("游戏入口必须在项目内", "The game entry must be inside the project") -- 50
	end -- 49
	local runnable -- 51
	for _index_0 = 1, #entryExtensions do -- 51
		local ext = entryExtensions[_index_0] -- 51
		if Content:exist(Path(root, tostring(entry) .. "." .. tostring(ext))) then -- 52
			runnable = true -- 52
			break -- 52
		end -- 52
	end -- 51
	if not runnable then -- 53
		fail("请先在 IDE 中编译游戏", "Build the game in the IDE first") -- 54
	end -- 53
	local useGodot = copyProject(root, Path(assets, "Game")) -- 55
	Content:mkdir(Path(assets, "Script")) -- 56
	if not Content:save(Path(assets, "Script", "init.lua"), bootstrap(entry)) then -- 57
		fail("无法写入游戏入口", "Could not write the game entry") -- 58
	end -- 57
	return useGodot -- 60
end -- 47
_module_0["prepareGame"] = prepareGame -- 47
local snapshotWeb -- 62
snapshotWeb = function(root, archive) -- 62
	local ok, result = pcall(function() -- 63
		local stage = Path(Content.appPath, ".native-export", "web-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 64
		if not Content:mkdir(stage) then -- 65
			fail("无法创建导出目录", "Could not create the export directory") -- 66
		end -- 65
		local _ <close> = setmetatable({ }, { -- 67
			__close = function() -- 67
				return Content:remove(stage) -- 67
			end -- 67
		}) -- 67
		local useGodot = copyProject(root, stage) -- 68
		if not Content:zipAsync(stage, archive) then -- 69
			fail("无法打包游戏资源", "Could not package game assets") -- 70
		end -- 69
		return useGodot -- 71
	end) -- 63
	if ok then -- 72
		return { -- 72
			success = true, -- 72
			needsGodot = result -- 72
		} -- 72
	end -- 72
	return { -- 73
		success = false, -- 73
		message = tostring(result) -- 73
	} -- 73
end -- 62
_module_0["snapshotWeb"] = snapshotWeb -- 62
local resolveTemplate -- 75
resolveTemplate = function(target) -- 75
	local resolveExportTemplate = require("Script.Dev.ExportTemplate").resolveExportTemplate -- 76
	local result -- 77
	resolveExportTemplate(target, function(value) -- 78
		result = value -- 78
	end) -- 78
	wait(function() -- 79
		return result ~= nil -- 79
	end) -- 79
	if not result.folder then -- 80
		error(result.message, 0) -- 80
	end -- 80
	return result.folder -- 81
end -- 75
_module_0["resolveTemplate"] = resolveTemplate -- 75
local windowsGodotLibrary = "dora_godot.dll" -- 83
local windowsRuntimeSource -- 85
windowsRuntimeSource = function(useGodot) -- 85
	if App.platform == "Windows" then -- 86
		local exe = App.executablePath -- 87
		local godot = Path(Path:getPath(exe), windowsGodotLibrary) -- 88
		if not useGodot or (Content:exist(godot) and not Content:isdir(godot)) then -- 89
			return Content.assetPath, exe -- 90
		end -- 89
	end -- 86
	local folder = resolveTemplate("windows-x64") -- 91
	return folder, Path(folder, "Dora.exe") -- 92
end -- 85
local exportWindows -- 94
exportWindows = function(root, fileName, title, destination) -- 94
	local name = title:gsub('[\\/:*?"<>|%c]', "_"):match("^%s*(.-)%s*$") -- 95
	if not name or name == "" then -- 96
		name = "Game" -- 96
	end -- 96
	name = "Game-" .. tostring(name) -- 97
	do -- 98
		local last = utf8.offset(name, 61) -- 98
		if last then -- 98
			name = name:sub(1, last - 1) -- 99
		end -- 98
	end -- 98
	local archive = Path(destination, tostring(name) .. "-Windows.zip") -- 100
	local suffix = 2 -- 101
	while Content:exist(archive) do -- 102
		archive = Path(destination, tostring(name) .. "-Windows-" .. tostring(suffix) .. ".zip") -- 103
		suffix = suffix + 1 -- 104
	end -- 102
	local cache = Path(Content.appPath, ".native-export") -- 105
	local stage = Path(cache, "stage-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 106
	local assets = Path(stage, "game") -- 107
	local tempZip = Path(destination, ".dora-export-" .. tostring(Path:getName(stage)) .. ".tmp") -- 108
	local success, result = pcall(function() -- 109
		local id = projectId(root) -- 110
		if not Content:mkdir(assets) then -- 111
			fail("无法创建导出目录", "Could not create the export directory") -- 112
		end -- 111
		local useGodot = prepareGame(root, fileName, assets) -- 113
		local assetRoot, exe = windowsRuntimeSource(useGodot) -- 114
		if useGodot then -- 116
			local godot = Path(Path:getPath(exe), windowsGodotLibrary) -- 117
			if not (Content:exist(godot) and not Content:isdir(godot)) then -- 118
				fail("此项目需要 Godot，请使用包含 Godot 运行库的 Windows 版 Dora 导出", "Use a Windows build of Dora with Godot to export this project.") -- 119
			end -- 118
			copyFile(godot, Path(assets, windowsGodotLibrary)) -- 120
		end -- 116
		for _index_0 = 1, #runtimeRoots do -- 121
			local item = runtimeRoots[_index_0] -- 121
			local src = Path(assetRoot, item) -- 122
			if Content:isdir(src) then -- 123
				local _list_0 = Content:getAllFiles(src) -- 124
				for _index_1 = 1, #_list_0 do -- 124
					local file = _list_0[_index_1] -- 124
					if item == "Audio" and file == "GeneralUserGS.sf3" then -- 125
						goto _continue_0 -- 125
					end -- 125
					if item == "Image" and file:gsub("\\", "/") == "Mobile/dora-remix-states.png" then -- 126
						goto _continue_0 -- 126
					end -- 126
					copyFile(Path(src, file), Path(assets, item, file)) -- 127
					::_continue_0:: -- 125
				end -- 124
			elseif Content:exist(src) then -- 128
				copyFile(src, Path(assets, item)) -- 129
			end -- 123
		end -- 121
		copyFile(exe, Path(assets, tostring(name) .. ".exe")) -- 130
		if not Content:save(Path(assets, "dora-game-id"), id) then -- 131
			fail("无法写入游戏标识", "Could not write the game ID") -- 132
		end -- 131
		if not Content:zipAsync(assets, tempZip) then -- 133
			fail("无法创建游戏 ZIP", "Could not create the game ZIP") -- 134
		end -- 133
		if not Content:exist(archive) and Content:move(tempZip, archive) then -- 135
			return archive -- 136
		end -- 135
		return fail("无法保存游戏 ZIP", "Could not save the game ZIP") -- 137
	end) -- 109
	if Content:exist(stage) then -- 138
		Content:remove(stage) -- 138
	end -- 138
	if Content:exist(tempZip) then -- 139
		Content:remove(tempZip) -- 139
	end -- 139
	if not success then -- 140
		error(result, 0) -- 140
	end -- 140
	return result -- 141
end -- 94
_module_0["exportWindows"] = exportWindows -- 94
local exportAndroid -- 143
exportAndroid = function(root, fileName, title) -- 143
	local dispatch = require("dora.android_game_export") -- 144
	local stage = Path(Content.appPath, ".native-export", "android-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 145
	local success, result = pcall(function() -- 146
		if not Content:mkdir(stage) then -- 147
			fail("无法创建导出目录", "Could not create the export directory") -- 148
		end -- 147
		local useGodot = prepareGame(root, fileName, Path(stage, "assets")) -- 149
		local hasTemplate = require("dora.android_has_export_template") -- 150
		if not hasTemplate(useGodot) then -- 151
			local version = App.version:match("^(%d+%.%d+%.%d+)%.%d+$") -- 152
			local template = resolveTemplate("android") -- 153
			copyFile(Path(template, "dora-ssr-v" .. tostring(version) .. "-android.apk"), Path(stage, "template.apk")) -- 154
		end -- 151
		if not dispatch(stage, projectId(root), title, useGodot) then -- 155
			return fail("无法打开 APK 导出", "Could not open APK export") -- 156
		end -- 155
	end) -- 146
	if not success then -- 157
		if Content:exist(stage) then -- 158
			Content:remove(stage) -- 158
		end -- 158
		return error(result, 0) -- 159
	end -- 157
end -- 143
_module_0["exportAndroid"] = exportAndroid -- 143
return _module_0 -- 1
