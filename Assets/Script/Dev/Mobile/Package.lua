-- [ts]: Package.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local json = ____Dora.json -- 1
local ____ExportPolicy = require("Dev.ExportPolicy") -- 2
local projectFileAllowed = ____ExportPolicy.projectFileAllowed -- 2
local manifestName = "dora-package.json" -- 5
local maxPackageBytes = 256 * 1024 * 1024 -- 6
local maxUnpackedBytes = 512 * 1024 * 1024 -- 7
local runtimeEntries = { -- 8
	"init.lua", -- 8
	"init.yue", -- 8
	"init.tl", -- 8
	"init.xml", -- 8
	"init.wasm" -- 8
} -- 8
function ____exports.packageFileAllowed(file) -- 19
	return projectFileAllowed(file, true) -- 20
end -- 19
local function fail(zh, en) -- 23
	error(__TS__StringStartsWith( -- 24
		string.lower(App.locale), -- 24
		"zh" -- 24
	) and zh or en) -- 24
end -- 23
local function cleanName(value) -- 27
	local replaced = (string.gsub(value, "[\\/:*?\"<>|%c]", "_")) -- 28
	local cleaned = (string.match(replaced, "^%s*(.-)%s*$")) or replaced -- 32
	local name = (string.gsub(cleaned, "^%.+", "")) -- 33
	local ____end = utf8.offset(name, 61) -- 34
	return name == "" and "Game" or (____end and string.sub(name, 1, ____end - 1) or name) -- 35
end -- 27
local function newStage() -- 38
	local cache = Path(Content.writablePath, ".share") -- 39
	for ____, dir in ipairs(Content:exist(cache) and Content:getDirs(cache) or ({})) do -- 41
		local stamp = string.match(dir, "^(%d+)%-%d+$") -- 42
		if stamp ~= nil and (tonumber(stamp) or os.time()) < os.time() - 7 * 86400 then -- 42
			Content:remove(Path(cache, dir)) -- 43
		end -- 43
	end -- 43
	local path = Path( -- 45
		Content.writablePath, -- 45
		".share", -- 45
		(tostring(os.time()) .. "-") .. tostring(App.rand) -- 45
	) -- 45
	if not Content:mkdir(path) then -- 45
		fail("无法创建临时目录", "Could not create temporary folder") -- 46
	end -- 46
	return path -- 47
end -- 38
local function encodeObject(value) -- 50
	local encoded = json.encode(value) -- 51
	if encoded == nil then -- 51
		fail("无法编码作品信息", "Could not encode game metadata") -- 52
	end -- 52
	return encoded -- 53
end -- 50
local function readObject(path) -- 56
	if not Content:exist(path) then -- 56
		return nil -- 57
	end -- 57
	local size = Content:getAttr(path) -- 58
	if size == nil or size > 64 * 1024 then -- 58
		fail("作品信息过大", "Package metadata is too large") -- 59
	end -- 59
	local value = json.decode(Content:load(path)) -- 60
	if type(value) ~= "table" then -- 60
		fail("作品信息格式不正确", "Invalid package metadata") -- 61
	end -- 61
	return value -- 62
end -- 56
local function runnable(root) -- 65
	return __TS__ArraySome( -- 66
		runtimeEntries, -- 66
		function(____, file) return Content:exist(Path(root, file)) and not Content:isdir(Path(root, file)) end -- 66
	) -- 66
end -- 65
function ____exports.discardPackage(preview) -- 69
	Content:remove(preview.stage) -- 70
end -- 69
--- Call in a Dora coroutine. This inspects data only, never executes imported code.
function ____exports.inspectPackage(path) -- 74
	local bytes = Content:getAttr(path) -- 75
	if bytes == nil or bytes > maxPackageBytes or bytes == 0 or Content:isdir(path) then -- 75
		fail("无法读取作品包，文件应小于 256 MB", "Cannot read package; maximum size is 256 MB") -- 77
	end -- 77
	local stage = newStage() -- 79
	do -- 79
		local function ____catch(e) -- 79
			Content:remove(stage) -- 121
			error(e, 0) -- 122
		end -- 122
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 122
			local unpacked = Path(stage, "content") -- 81
			if not Content:unzipAsync( -- 81
				path, -- 82
				unpacked, -- 82
				____exports.packageFileAllowed, -- 82
				maxUnpackedBytes, -- 82
				10000 -- 82
			) then -- 82
				fail("作品包损坏、过大或含有无效路径", "Package is damaged, too large, or contains invalid paths") -- 82
			end -- 82
			local root = unpacked -- 83
			if not runnable(root) then -- 83
				local dirs = __TS__ArrayFilter( -- 85
					Content:getDirs(root), -- 85
					function(____, dir) return not __TS__StringStartsWith(dir, ".") end -- 85
				) -- 85
				if #dirs == 1 and runnable(Path(root, dirs[1])) then -- 85
					root = Path(root, dirs[1]) -- 86
				end -- 86
			end -- 86
			if not runnable(root) then -- 86
				fail("未找到可运行入口 init，请先在 Dora 中构建作品", "No runnable init entry; build the project in Dora first") -- 88
			end -- 88
			local total = 0 -- 89
			for ____, file in ipairs(Content:getAllFiles(root)) do -- 90
				local size = Content:getAttr(Path(root, file)) -- 91
				total = total + (size or 0) -- 92
			end -- 92
			if total > maxUnpackedBytes then -- 92
				fail("解包后的作品不能超过 512 MB", "Unpacked game exceeds 512 MB") -- 94
			end -- 94
			local manifest = readObject(Path(root, manifestName)) -- 95
			if manifest and (manifest.format ~= "dora-game" or manifest.version ~= 1) then -- 95
				fail("不支持此作品包版本，请更新 Dora", "Unsupported package version; update Dora") -- 96
			end -- 96
			local repo = readObject(Path(root, ".dora", "repo.json")) -- 97
			if type(manifest and manifest.engineVersion) == "string" then -- 97
				local required = __TS__ArrayMap( -- 99
					__TS__StringSplit(manifest.engineVersion, "."), -- 99
					function(____, part) return tonumber(part) or 0 end -- 99
				) -- 99
				local current = __TS__ArrayMap( -- 100
					__TS__StringSplit(App.version, "."), -- 100
					function(____, part) return tonumber(part) or 0 end -- 100
				) -- 100
				do -- 100
					local i = 0 -- 101
					while i < math.max(#required, #current) do -- 101
						if (required[i + 1] or 0) > (current[i + 1] or 0) then -- 101
							fail("作品由更新版本的 Dora 导出，请先更新引擎", "This package was exported by a newer Dora; update the engine first") -- 102
						end -- 102
						if (required[i + 1] or 0) < (current[i + 1] or 0) then -- 102
							break -- 103
						end -- 103
						i = i + 1 -- 101
					end -- 101
				end -- 101
			end -- 101
			local title = cleanName(type(manifest and manifest.title) == "string" and manifest.title or (root ~= unpacked and Path:getFilename(root) or Path:getName(path))) -- 106
			local author = type(manifest and manifest.author) == "string" and __TS__StringSubstring(manifest.author, 0, 80) or nil -- 107
			if repo then -- 107
				local ____temp_6 -- 110
				if type(repo.title) == "table" then -- 110
					____temp_6 = repo.title -- 110
				else -- 110
					____temp_6 = {} -- 110
				end -- 110
				local titleInfo = ____temp_6 -- 110
				local ____temp_7 -- 111
				if type(repo.description) == "table" then -- 111
					____temp_7 = repo.description -- 111
				else -- 111
					____temp_7 = {} -- 111
				end -- 111
				local description = ____temp_7 -- 111
				repo.title = { -- 112
					zh = type(titleInfo.zh) == "string" and titleInfo.zh or title, -- 112
					en = type(titleInfo.en) == "string" and titleInfo.en or title -- 112
				} -- 112
				repo.description = { -- 113
					zh = type(description.zh) == "string" and description.zh or "", -- 113
					en = type(description.en) == "string" and description.en or "" -- 113
				} -- 113
				repo.categories = {} -- 114
				if not Content:save( -- 114
					Path(root, ".dora", "repo.json"), -- 115
					encodeObject(repo) -- 115
				) then -- 115
					fail("无法保存作品信息", "Could not save game metadata") -- 115
				end -- 115
			end -- 115
			local bannerFile = __TS__ArrayFind( -- 117
				__TS__ArrayMap( -- 117
					{".dora/banner.jpg", ".dora/banner.png", "Image/banner.jpg", "Image/banner.png"}, -- 117
					function(____, file) return Path(root, file) end -- 118
				), -- 118
				function(____, file) return Content:exist(file) end -- 118
			) -- 118
			return true, { -- 119
				stage = stage, -- 119
				root = root, -- 119
				title = title, -- 119
				author = author, -- 119
				bannerFile = bannerFile, -- 119
				bytes = bytes -- 119
			} -- 119
		end) -- 119
		if not ____try then -- 119
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 119
		end -- 119
		if ____hasReturned then -- 119
			return ____returnValue -- 80
		end -- 80
	end -- 80
end -- 74
function ____exports.installPackage(preview) -- 126
	local ____array_8 = __TS__SparseArrayNew(table.unpack(Content:getDirs(Content.writablePath))) -- 126
	__TS__SparseArrayPush( -- 126
		____array_8, -- 126
		table.unpack(Content:getFiles(Content.writablePath)) -- 127
	) -- 127
	local existing = __TS__ArrayMap( -- 127
		{__TS__SparseArraySpread(____array_8)}, -- 127
		function(____, name) return string.lower(name) end -- 127
	) -- 127
	local name = cleanName(preview.title) -- 128
	local suffix = 2 -- 129
	while __TS__ArrayIncludes( -- 129
		existing, -- 130
		string.lower(name) -- 130
	) or Content:exist(Path(Content.writablePath, name)) do -- 130
		local ____cleanName_result_10 = cleanName(preview.title) -- 130
		local ____suffix_9 = suffix -- 130
		suffix = ____suffix_9 + 1 -- 130
		name = ((____cleanName_result_10 .. " (") .. tostring(____suffix_9)) .. ")" -- 130
	end -- 130
	local target = Path(Content.writablePath, name) -- 131
	local banner = preview.bannerFile and Path:getRelative(preview.bannerFile, preview.root) or nil -- 132
	if not Content:move(preview.root, target) then -- 132
		fail("无法安装作品，请检查剩余空间后重试", "Could not install game; check available space and retry") -- 133
	end -- 133
	Content:remove(preview.stage) -- 134
	return { -- 135
		id = name, -- 135
		title = preview.title, -- 135
		description = "", -- 135
		kind = "local", -- 135
		workDir = target, -- 135
		fileName = Path(target, "init"), -- 136
		bannerFile = banner and Path(target, banner) or nil -- 136
	} -- 136
end -- 126
--- Snapshot source and assets before zipping so subsequent edits cannot alter a shared package.
function ____exports.exportPackage(entry) -- 140
	local root = entry.workDir -- 141
	if not root or not runnable(root) then -- 141
		fail("请先构建作品，确认可以试玩后再分享", "Build the game and check that it runs before sharing") -- 142
	end -- 142
	local stage = newStage() -- 143
	do -- 143
		local function ____catch(e) -- 143
			Content:remove(stage) -- 168
			error(e, 0) -- 169
		end -- 169
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 169
			local snapshot = Path(stage, "snapshot") -- 145
			if not Content:mkdir(snapshot) then -- 145
				fail("无法创建作品快照", "Could not create game snapshot") -- 146
			end -- 146
			local total = 0 -- 147
			local files = __TS__ArrayFilter( -- 148
				Content:getAllFiles(root), -- 148
				function(____, file) return ____exports.packageFileAllowed(file) end -- 148
			) -- 148
			if #files > 10000 then -- 148
				fail("作品文件数量过多", "Too many game files") -- 149
			end -- 149
			for ____, file in ipairs(files) do -- 150
				local size = Content:getAttr(Path(root, file)) -- 151
				total = total + (size or 0) -- 152
				if total > maxUnpackedBytes then -- 152
					fail("作品不能超过 512 MB", "Game exceeds 512 MB") -- 153
				end -- 153
				local target = Path(snapshot, file) -- 154
				Content:mkdir(Path:getPath(target)) -- 155
				if not Content:copyAsync( -- 155
					Path(root, file), -- 156
					target -- 156
				) then -- 156
					fail("复制作品文件失败", "Could not copy game files") -- 156
				end -- 156
			end -- 156
			local previous = readObject(Path(snapshot, manifestName)) -- 158
			local manifest = __TS__ObjectAssign({}, previous or ({}), { -- 159
				format = "dora-game", -- 159
				version = 1, -- 159
				title = entry.title, -- 159
				engineVersion = App.version, -- 159
				entry = "init" -- 159
			}) -- 159
			if not Content:save( -- 159
				Path(snapshot, manifestName), -- 160
				encodeObject(manifest) -- 160
			) then -- 160
				fail("无法保存作品信息", "Could not save game metadata") -- 160
			end -- 160
			local path = Path( -- 161
				stage, -- 161
				cleanName(entry.title) .. ".zip" -- 161
			) -- 161
			if not Content:zipAsync(snapshot, path) then -- 161
				fail("作品打包失败", "Could not package game") -- 162
			end -- 162
			Content:remove(snapshot) -- 163
			local bytes = Content:getAttr(path) -- 164
			if bytes == nil or bytes > maxPackageBytes then -- 164
				fail("作品包不能超过 256 MB", "Package exceeds 256 MB") -- 165
			end -- 165
			return true, {path = path, bytes = bytes} -- 166
		end) -- 166
		if not ____try then -- 166
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 166
		end -- 166
		if ____hasReturned then -- 166
			return ____returnValue -- 144
		end -- 144
	end -- 144
end -- 140
return ____exports -- 140