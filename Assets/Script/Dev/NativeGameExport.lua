-- [yue]: Script/Dev/NativeGameExport.yue
local _module_0 = { } -- 1
local App, Content, HttpServer, Path, json, wait -- 1
do -- 1
	local _obj_0 = require("Dora") -- 1
	App, Content, HttpServer, Path, json, wait = _obj_0.App, _obj_0.Content, _obj_0.HttpServer, _obj_0.Path, _obj_0.json, _obj_0.wait -- 1
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
local resolveTemplate -- 62
resolveTemplate = function(target) -- 62
	local resolveExportTemplate = require("Script.Dev.ExportTemplate").resolveExportTemplate -- 63
	local result -- 64
	resolveExportTemplate(target, function(value) -- 65
		result = value -- 65
	end) -- 65
	wait(function() -- 66
		return result ~= nil -- 66
	end) -- 66
	if not result.folder then -- 67
		error(result.message, 0) -- 67
	end -- 67
	return result.folder -- 68
end -- 62
_module_0["resolveTemplate"] = resolveTemplate -- 62
local _anon_func_0 = function(result) -- 97
	if result ~= "" then -- 97
		return result -- 97
	end -- 97
end -- 97
local exportPackage -- 70
exportPackage = function(format, root, entry, stage, signing) -- 70
	local packageBuilder = require("dora.game_package") -- 71
	local assets = Path(stage, "assets") -- 72
	if not Content:mkdir(assets) then -- 73
		fail("无法准备游戏资源", "Could not prepare game assets") -- 74
	end -- 73
	local options = { -- 75
		format = format, -- 75
		assets = assets -- 75
	} -- 75
	if format == "android" then -- 76
		options.needsGodot = prepareGame(root, entry, assets) -- 77
		local version = App.version:match("^(%d+%.%d+%.%d+)%.%d+$") -- 78
		options.template = Path(resolveTemplate("android"), "dora-ssr-v" .. tostring(version) .. "-android.apk") -- 79
		options.policy = Content:load(Path(Content.assetPath, "Script", "Dev", "ExportPolicy.json")) -- 80
		options.game = signing.game -- 81
		options.password = signing.password -- 82
		options.key = signing.key -- 83
		options.output = Path(stage, "game.apk") -- 84
	else -- 86
		options.needsGodot = copyProject(root, assets) -- 86
		options.www = HttpServer.wwwPath -- 87
		options.output = Path(stage, "game.zip") -- 88
	end -- 76
	local success, result -- 89
	local done = false -- 90
	packageBuilder.run(json.encode(options), function(ok, value) -- 91
		success, result = ok, value -- 92
		done = true -- 93
	end) -- 91
	wait(function() -- 94
		return done -- 94
	end) -- 94
	if not success then -- 95
		error(result, 0) -- 95
	end -- 95
	Content:remove(assets) -- 96
	return options.output, _anon_func_0(result) -- 97
end -- 70
_module_0["exportPackage"] = exportPackage -- 70
local windowsGodotLibrary = "dora_godot.dll" -- 99
local windowsRuntimeSource -- 101
windowsRuntimeSource = function(useGodot) -- 101
	if App.platform == "Windows" then -- 102
		local exe = App.executablePath -- 103
		local godot = Path(Path:getPath(exe), windowsGodotLibrary) -- 104
		if not useGodot or (Content:exist(godot) and not Content:isdir(godot)) then -- 105
			return Content.assetPath, exe -- 106
		end -- 105
	end -- 102
	local folder = resolveTemplate("windows-x64") -- 107
	return folder, Path(folder, "Dora.exe") -- 108
end -- 101
local exportWindows -- 110
exportWindows = function(root, fileName, title, destination) -- 110
	local name = title:gsub('[\\/:*?"<>|%c]', "_"):match("^%s*(.-)%s*$") -- 111
	if not name or name == "" then -- 112
		name = "Game" -- 112
	end -- 112
	name = "Game-" .. tostring(name) -- 113
	do -- 114
		local last = utf8.offset(name, 61) -- 114
		if last then -- 114
			name = name:sub(1, last - 1) -- 115
		end -- 114
	end -- 114
	local archive = Path(destination, tostring(name) .. "-Windows.zip") -- 116
	local suffix = 2 -- 117
	while Content:exist(archive) do -- 118
		archive = Path(destination, tostring(name) .. "-Windows-" .. tostring(suffix) .. ".zip") -- 119
		suffix = suffix + 1 -- 120
	end -- 118
	local cache = Path(Content.appPath, ".native-export") -- 121
	local stage = Path(cache, "stage-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 122
	local assets = Path(stage, "game") -- 123
	local tempZip = Path(destination, ".dora-export-" .. tostring(Path:getName(stage)) .. ".tmp") -- 124
	local success, result = pcall(function() -- 125
		local id = projectId(root) -- 126
		if not Content:mkdir(assets) then -- 127
			fail("无法创建导出目录", "Could not create the export directory") -- 128
		end -- 127
		local useGodot = prepareGame(root, fileName, assets) -- 129
		local assetRoot, exe = windowsRuntimeSource(useGodot) -- 130
		if useGodot then -- 132
			local godot = Path(Path:getPath(exe), windowsGodotLibrary) -- 133
			if not (Content:exist(godot) and not Content:isdir(godot)) then -- 134
				fail("此项目需要 Godot，请使用包含 Godot 运行库的 Windows 版 Dora 导出", "Use a Windows build of Dora with Godot to export this project.") -- 135
			end -- 134
			copyFile(godot, Path(assets, windowsGodotLibrary)) -- 136
		end -- 132
		for _index_0 = 1, #runtimeRoots do -- 137
			local item = runtimeRoots[_index_0] -- 137
			local src = Path(assetRoot, item) -- 138
			if Content:isdir(src) then -- 139
				local _list_0 = Content:getAllFiles(src) -- 140
				for _index_1 = 1, #_list_0 do -- 140
					local file = _list_0[_index_1] -- 140
					if item == "Audio" and file == "GeneralUserGS.sf3" then -- 141
						goto _continue_0 -- 141
					end -- 141
					if item == "Image" and file:gsub("\\", "/") == "Mobile/dora-remix-states.png" then -- 142
						goto _continue_0 -- 142
					end -- 142
					copyFile(Path(src, file), Path(assets, item, file)) -- 143
					::_continue_0:: -- 141
				end -- 140
			elseif Content:exist(src) then -- 144
				copyFile(src, Path(assets, item)) -- 145
			end -- 139
		end -- 137
		copyFile(exe, Path(assets, tostring(name) .. ".exe")) -- 146
		if not Content:save(Path(assets, "dora-game-id"), id) then -- 147
			fail("无法写入游戏标识", "Could not write the game ID") -- 148
		end -- 147
		if not Content:zipAsync(assets, tempZip) then -- 149
			fail("无法创建游戏 ZIP", "Could not create the game ZIP") -- 150
		end -- 149
		if not Content:exist(archive) and Content:move(tempZip, archive) then -- 151
			return archive -- 152
		end -- 151
		return fail("无法保存游戏 ZIP", "Could not save the game ZIP") -- 153
	end) -- 125
	if Content:exist(stage) then -- 154
		Content:remove(stage) -- 154
	end -- 154
	if Content:exist(tempZip) then -- 155
		Content:remove(tempZip) -- 155
	end -- 155
	if not success then -- 156
		error(result, 0) -- 156
	end -- 156
	return result -- 157
end -- 110
_module_0["exportWindows"] = exportWindows -- 110
local exportAndroid -- 159
exportAndroid = function(root, fileName, title) -- 159
	local dispatch = require("dora.android_game_export") -- 160
	local stage = Path(Content.appPath, ".native-export", "android-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 161
	local success, result = pcall(function() -- 162
		if not Content:mkdir(stage) then -- 163
			fail("无法创建导出目录", "Could not create the export directory") -- 164
		end -- 163
		local useGodot = prepareGame(root, fileName, Path(stage, "assets")) -- 165
		local hasTemplate = require("dora.android_has_export_template") -- 166
		if not hasTemplate(useGodot) then -- 167
			local version = App.version:match("^(%d+%.%d+%.%d+)%.%d+$") -- 168
			local template = resolveTemplate("android") -- 169
			copyFile(Path(template, "dora-ssr-v" .. tostring(version) .. "-android.apk"), Path(stage, "template.apk")) -- 170
		end -- 167
		if not dispatch(stage, projectId(root), title, useGodot) then -- 171
			return fail("无法打开 APK 导出", "Could not open APK export") -- 172
		end -- 171
	end) -- 162
	if not success then -- 173
		if Content:exist(stage) then -- 174
			Content:remove(stage) -- 174
		end -- 174
		return error(result, 0) -- 175
	end -- 173
end -- 159
_module_0["exportAndroid"] = exportAndroid -- 159
return _module_0 -- 1
