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
	"dora-wa", -- 4
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
local fail -- 7
fail = function(zh, en) -- 7
	return error(App.locale:match("^zh") and zh or en, 0) -- 7
end -- 7
local copyFile -- 9
copyFile = function(src, dst) -- 9
	Content:mkdir(Path:getPath(dst)) -- 10
	if not Content:copyAsync(src, dst) then -- 11
		return fail("复制失败：" .. tostring(src), "Could not copy: " .. tostring(src)) -- 12
	end -- 11
end -- 9
local projectId -- 14
projectId = function(root) -- 14
	local metadata = Path(root, ".dora") -- 15
	local file = Path(metadata, "native-export-id") -- 16
	if Content:exist(file) then -- 17
		local id = Content:load(file) -- 18
		if id and #id == 32 and id:match("^[0-9a-f]+$") then -- 19
			return id -- 19
		end -- 19
		fail("项目导出 ID 无效", "Invalid project export ID") -- 20
	end -- 17
	local id = (require("dora.new_game_id"))() -- 21
	Content:mkdir(metadata) -- 22
	if not Content:save(file, id) then -- 23
		fail("无法保存项目导出 ID", "Could not save the project export ID") -- 24
	end -- 23
	return id -- 25
end -- 14
local bootstrap -- 27
bootstrap = function(entry) -- 27
	return [[local Dora = require("Dora")
local Content, Path = Dora.Content, Dora.Path
local root = Path(Content.assetPath, "Game")
local paths = {root, Path(Content.assetPath, "Script", "Lib"), Content.assetPath}
local scripts = Path(root, "Script")
if Content:exist(scripts) then table.insert(paths, 1, scripts) end
Content.searchPaths = paths
local run = require(Path(root, ]] .. string.format("%q", entry) .. [[))
if type(run) == "function" then run() end
]] -- 27
end -- 27
local prepareGame -- 39
prepareGame = function(root, fileName, assets) -- 39
	local entry = Path:getRelative(fileName, root):gsub("\\", "/") -- 40
	if not packageFileAllowed(entry) then -- 41
		fail("游戏入口必须在项目内", "The game entry must be inside the project") -- 42
	end -- 41
	local runnable -- 43
	for _index_0 = 1, #entryExtensions do -- 43
		local ext = entryExtensions[_index_0] -- 43
		if Content:exist(Path(root, tostring(entry) .. "." .. tostring(ext))) then -- 44
			runnable = true -- 44
			break -- 44
		end -- 44
	end -- 43
	if not runnable then -- 45
		fail("请先在 IDE 中编译游戏", "Build the game in the IDE first") -- 46
	end -- 45
	local _list_0 = Content:getAllFiles(root) -- 47
	for _index_0 = 1, #_list_0 do -- 47
		local file = _list_0[_index_0] -- 47
		if packageFileAllowed(file) then -- 48
			copyFile(Path(root, file), Path(assets, "Game", file)) -- 49
		end -- 48
	end -- 47
	Content:mkdir(Path(assets, "Script")) -- 50
	if not Content:save(Path(assets, "Script", "init.lua"), bootstrap(entry)) then -- 51
		return fail("无法写入游戏入口", "Could not write the game entry") -- 52
	end -- 51
end -- 39
_module_0["prepareGame"] = prepareGame -- 39
local exportWindows -- 54
exportWindows = function(root, fileName, title, destination) -- 54
	local name = title:gsub('[\\/:*?"<>|%c]', "_"):match("^%s*(.-)%s*$") -- 55
	if not name or name == "" then -- 56
		name = "Game" -- 56
	end -- 56
	name = "Game-" .. tostring(name) -- 57
	do -- 58
		local last = utf8.offset(name, 61) -- 58
		if last then -- 58
			name = name:sub(1, last - 1) -- 59
		end -- 58
	end -- 58
	local archive = Path(destination, tostring(name) .. "-Windows.zip") -- 60
	local suffix = 2 -- 61
	while Content:exist(archive) do -- 62
		archive = Path(destination, tostring(name) .. "-Windows-" .. tostring(suffix) .. ".zip") -- 63
		suffix = suffix + 1 -- 64
	end -- 62
	local assetRoot = Content.assetPath -- 65
	local cache = Path(Content.appPath, ".native-export") -- 66
	local stage = Path(cache, "stage-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 67
	local assets = Path(stage, "game") -- 68
	local tempZip = Path(destination, ".dora-export-" .. tostring(Path:getName(stage)) .. ".tmp") -- 69
	local success, result = pcall(function() -- 70
		local id = projectId(root) -- 71
		if not Content:mkdir(assets) then -- 72
			fail("无法创建导出目录", "Could not create the export directory") -- 73
		end -- 72
		prepareGame(root, fileName, assets) -- 74
		for _index_0 = 1, #runtimeRoots do -- 75
			local item = runtimeRoots[_index_0] -- 75
			local src = Path(assetRoot, item) -- 76
			if Content:isdir(src) then -- 77
				local _list_0 = Content:getAllFiles(src) -- 78
				for _index_1 = 1, #_list_0 do -- 78
					local file = _list_0[_index_1] -- 78
					copyFile(Path(src, file), Path(assets, item, file)) -- 79
				end -- 78
			elseif Content:exist(src) then -- 80
				copyFile(src, Path(assets, item)) -- 81
			end -- 77
		end -- 75
		local exe = App.executablePath -- 82
		copyFile(exe, Path(assets, tostring(name) .. ".exe")) -- 83
		local _list_0 = { -- 84
			"wa.dll", -- 84
			"dora_godot.dll" -- 84
		} -- 84
		for _index_0 = 1, #_list_0 do -- 84
			local library = _list_0[_index_0] -- 84
			local src = Path(Path:getPath(exe), library) -- 85
			if Content:exist(src) then -- 86
				copyFile(src, Path(assets, library)) -- 86
			end -- 86
		end -- 84
		if not Content:save(Path(assets, "dora-game-id"), id) then -- 87
			fail("无法写入游戏标识", "Could not write the game ID") -- 88
		end -- 87
		if not Content:zipAsync(assets, tempZip) then -- 89
			fail("无法创建游戏 ZIP", "Could not create the game ZIP") -- 90
		end -- 89
		if not Content:exist(archive) and Content:move(tempZip, archive) then -- 91
			return archive -- 92
		end -- 91
		return fail("无法保存游戏 ZIP", "Could not save the game ZIP") -- 93
	end) -- 70
	if Content:exist(stage) then -- 94
		Content:remove(stage) -- 94
	end -- 94
	if Content:exist(tempZip) then -- 95
		Content:remove(tempZip) -- 95
	end -- 95
	if not success then -- 96
		error(result, 0) -- 96
	end -- 96
	return result -- 97
end -- 54
_module_0["exportWindows"] = exportWindows -- 54
local exportAndroid -- 99
exportAndroid = function(root, fileName, title) -- 99
	local dispatch = require("dora.android_game_export") -- 100
	local stage = Path(Content.appPath, ".native-export", "android-" .. tostring(os.time()) .. "-" .. tostring(App.rand)) -- 101
	local success, result = pcall(function() -- 102
		if not Content:mkdir(stage) then -- 103
			fail("无法创建导出目录", "Could not create the export directory") -- 104
		end -- 103
		prepareGame(root, fileName, Path(stage, "assets")) -- 105
		if not dispatch(stage, projectId(root), title) then -- 106
			return fail("无法打开 APK 导出", "Could not open APK export") -- 107
		end -- 106
	end) -- 102
	if not success then -- 108
		if Content:exist(stage) then -- 109
			Content:remove(stage) -- 109
		end -- 109
		return error(result, 0) -- 110
	end -- 108
end -- 99
_module_0["exportAndroid"] = exportAndroid -- 99
return _module_0 -- 1
