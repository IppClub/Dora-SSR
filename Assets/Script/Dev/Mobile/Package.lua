-- [ts]: Package.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
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
local manifestName = "dora-package.json" -- 4
local maxPackageBytes = 256 * 1024 * 1024 -- 5
local maxUnpackedBytes = 512 * 1024 * 1024 -- 6
local runtimeEntries = { -- 7
	"init.lua", -- 7
	"init.yue", -- 7
	"init.tl", -- 7
	"init.xml", -- 7
	"init.wasm" -- 7
} -- 7
function ____exports.packageFileAllowed(file) -- 18
	local name = (string.gsub(file, "\\", "/")) -- 19
	if __TS__StringStartsWith(name, "/") or (string.find(name, ":", nil, true) or 0) - 1 >= 0 then -- 19
		return false -- 20
	end -- 20
	local parts = __TS__StringSplit(name, "/") -- 21
	if __TS__ArraySome( -- 21
		parts, -- 22
		function(____, part) return part == ".." or part == "." or part == "" end -- 22
	) then -- 22
		return false -- 22
	end -- 22
	if name == ".dora/repo.json" or name == ".dora/banner.jpg" or name == ".dora/banner.png" then -- 22
		return true -- 23
	end -- 23
	return not __TS__ArraySome( -- 24
		parts, -- 24
		function(____, part) return __TS__StringStartsWith(part, ".") or part == "node_modules" or part == "__MACOSX" or string.lower(part) == "credentials.json" or string.lower(part) == "config.db" end -- 24
	) and not __TS__StringEndsWith( -- 24
		string.lower(name), -- 26
		".log" -- 26
	) -- 26
end -- 18
local function fail(zh, en) -- 29
	error(__TS__StringStartsWith( -- 30
		string.lower(App.locale), -- 30
		"zh" -- 30
	) and zh or en) -- 30
end -- 29
local function cleanName(value) -- 33
	local replaced = (string.gsub(value, "[\\/:*?\"<>|%c]", "_")) -- 34
	local cleaned = (string.match(replaced, "^%s*(.-)%s*$")) or replaced -- 38
	local name = (string.gsub(cleaned, "^%.+", "")) -- 39
	local ____end = utf8.offset(name, 61) -- 40
	return name == "" and "Game" or (____end and string.sub(name, 1, ____end - 1) or name) -- 41
end -- 33
local function newStage() -- 44
	local cache = Path(Content.writablePath, ".share") -- 45
	for ____, dir in ipairs(Content:exist(cache) and Content:getDirs(cache) or ({})) do -- 47
		local stamp = string.match(dir, "^(%d+)%-%d+$") -- 48
		if stamp ~= nil and (tonumber(stamp) or os.time()) < os.time() - 7 * 86400 then -- 48
			Content:remove(Path(cache, dir)) -- 49
		end -- 49
	end -- 49
	local path = Path( -- 51
		Content.writablePath, -- 51
		".share", -- 51
		(tostring(os.time()) .. "-") .. tostring(App.rand) -- 51
	) -- 51
	if not Content:mkdir(path) then -- 51
		fail("无法创建临时目录", "Could not create temporary folder") -- 52
	end -- 52
	return path -- 53
end -- 44
local function encodeObject(value) -- 56
	local encoded = json.encode(value) -- 57
	if encoded == nil then -- 57
		fail("无法编码作品信息", "Could not encode game metadata") -- 58
	end -- 58
	return encoded -- 59
end -- 56
local function readObject(path) -- 62
	if not Content:exist(path) then -- 62
		return nil -- 63
	end -- 63
	local size = Content:getAttr(path) -- 64
	if size == nil or size > 64 * 1024 then -- 64
		fail("作品信息过大", "Package metadata is too large") -- 65
	end -- 65
	local value = json.decode(Content:load(path)) -- 66
	if type(value) ~= "table" then -- 66
		fail("作品信息格式不正确", "Invalid package metadata") -- 67
	end -- 67
	return value -- 68
end -- 62
local function runnable(root) -- 71
	return __TS__ArraySome( -- 72
		runtimeEntries, -- 72
		function(____, file) return Content:exist(Path(root, file)) and not Content:isdir(Path(root, file)) end -- 72
	) -- 72
end -- 71
function ____exports.discardPackage(preview) -- 75
	Content:remove(preview.stage) -- 76
end -- 75
--- Call in a Dora coroutine. This inspects data only, never executes imported code.
function ____exports.inspectPackage(path) -- 80
	local bytes = Content:getAttr(path) -- 81
	if bytes == nil or bytes > maxPackageBytes or bytes == 0 or Content:isdir(path) then -- 81
		fail("无法读取作品包，文件应小于 256 MB", "Cannot read package; maximum size is 256 MB") -- 83
	end -- 83
	local stage = newStage() -- 85
	do -- 85
		local function ____catch(e) -- 85
			Content:remove(stage) -- 127
			error(e, 0) -- 128
		end -- 128
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 128
			local unpacked = Path(stage, "content") -- 87
			if not Content:unzipAsync( -- 87
				path, -- 88
				unpacked, -- 88
				____exports.packageFileAllowed, -- 88
				maxUnpackedBytes, -- 88
				10000 -- 88
			) then -- 88
				fail("作品包损坏、过大或含有无效路径", "Package is damaged, too large, or contains invalid paths") -- 88
			end -- 88
			local root = unpacked -- 89
			if not runnable(root) then -- 89
				local dirs = __TS__ArrayFilter( -- 91
					Content:getDirs(root), -- 91
					function(____, dir) return not __TS__StringStartsWith(dir, ".") end -- 91
				) -- 91
				if #dirs == 1 and runnable(Path(root, dirs[1])) then -- 91
					root = Path(root, dirs[1]) -- 92
				end -- 92
			end -- 92
			if not runnable(root) then -- 92
				fail("未找到可运行入口 init，请先在 Dora 中构建作品", "No runnable init entry; build the project in Dora first") -- 94
			end -- 94
			local total = 0 -- 95
			for ____, file in ipairs(Content:getAllFiles(root)) do -- 96
				local size = Content:getAttr(Path(root, file)) -- 97
				total = total + (size or 0) -- 98
			end -- 98
			if total > maxUnpackedBytes then -- 98
				fail("解包后的作品不能超过 512 MB", "Unpacked game exceeds 512 MB") -- 100
			end -- 100
			local manifest = readObject(Path(root, manifestName)) -- 101
			if manifest and (manifest.format ~= "dora-game" or manifest.version ~= 1) then -- 101
				fail("不支持此作品包版本，请更新 Dora", "Unsupported package version; update Dora") -- 102
			end -- 102
			local repo = readObject(Path(root, ".dora", "repo.json")) -- 103
			if type(manifest and manifest.engineVersion) == "string" then -- 103
				local required = __TS__ArrayMap( -- 105
					__TS__StringSplit(manifest.engineVersion, "."), -- 105
					function(____, part) return tonumber(part) or 0 end -- 105
				) -- 105
				local current = __TS__ArrayMap( -- 106
					__TS__StringSplit(App.version, "."), -- 106
					function(____, part) return tonumber(part) or 0 end -- 106
				) -- 106
				do -- 106
					local i = 0 -- 107
					while i < math.max(#required, #current) do -- 107
						if (required[i + 1] or 0) > (current[i + 1] or 0) then -- 107
							fail("作品由更新版本的 Dora 导出，请先更新引擎", "This package was exported by a newer Dora; update the engine first") -- 108
						end -- 108
						if (required[i + 1] or 0) < (current[i + 1] or 0) then -- 108
							break -- 109
						end -- 109
						i = i + 1 -- 107
					end -- 107
				end -- 107
			end -- 107
			local title = cleanName(type(manifest and manifest.title) == "string" and manifest.title or (root ~= unpacked and Path:getFilename(root) or Path:getName(path))) -- 112
			local author = type(manifest and manifest.author) == "string" and __TS__StringSubstring(manifest.author, 0, 80) or nil -- 113
			if repo then -- 113
				local ____temp_6 -- 116
				if type(repo.title) == "table" then -- 116
					____temp_6 = repo.title -- 116
				else -- 116
					____temp_6 = {} -- 116
				end -- 116
				local titleInfo = ____temp_6 -- 116
				local ____temp_7 -- 117
				if type(repo.description) == "table" then -- 117
					____temp_7 = repo.description -- 117
				else -- 117
					____temp_7 = {} -- 117
				end -- 117
				local description = ____temp_7 -- 117
				repo.title = { -- 118
					zh = type(titleInfo.zh) == "string" and titleInfo.zh or title, -- 118
					en = type(titleInfo.en) == "string" and titleInfo.en or title -- 118
				} -- 118
				repo.description = { -- 119
					zh = type(description.zh) == "string" and description.zh or "", -- 119
					en = type(description.en) == "string" and description.en or "" -- 119
				} -- 119
				repo.categories = {} -- 120
				if not Content:save( -- 120
					Path(root, ".dora", "repo.json"), -- 121
					encodeObject(repo) -- 121
				) then -- 121
					fail("无法保存作品信息", "Could not save game metadata") -- 121
				end -- 121
			end -- 121
			local bannerFile = __TS__ArrayFind( -- 123
				__TS__ArrayMap( -- 123
					{".dora/banner.jpg", ".dora/banner.png", "Image/banner.jpg", "Image/banner.png"}, -- 123
					function(____, file) return Path(root, file) end -- 124
				), -- 124
				function(____, file) return Content:exist(file) end -- 124
			) -- 124
			return true, { -- 125
				stage = stage, -- 125
				root = root, -- 125
				title = title, -- 125
				author = author, -- 125
				bannerFile = bannerFile, -- 125
				bytes = bytes -- 125
			} -- 125
		end) -- 125
		if not ____try then -- 125
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 125
		end -- 125
		if ____hasReturned then -- 125
			return ____returnValue -- 86
		end -- 86
	end -- 86
end -- 80
function ____exports.installPackage(preview) -- 132
	local ____array_8 = __TS__SparseArrayNew(table.unpack(Content:getDirs(Content.writablePath))) -- 132
	__TS__SparseArrayPush( -- 132
		____array_8, -- 132
		table.unpack(Content:getFiles(Content.writablePath)) -- 133
	) -- 133
	local existing = __TS__ArrayMap( -- 133
		{__TS__SparseArraySpread(____array_8)}, -- 133
		function(____, name) return string.lower(name) end -- 133
	) -- 133
	local name = cleanName(preview.title) -- 134
	local suffix = 2 -- 135
	while __TS__ArrayIncludes( -- 135
		existing, -- 136
		string.lower(name) -- 136
	) or Content:exist(Path(Content.writablePath, name)) do -- 136
		local ____cleanName_result_10 = cleanName(preview.title) -- 136
		local ____suffix_9 = suffix -- 136
		suffix = ____suffix_9 + 1 -- 136
		name = ((____cleanName_result_10 .. " (") .. tostring(____suffix_9)) .. ")" -- 136
	end -- 136
	local target = Path(Content.writablePath, name) -- 137
	local banner = preview.bannerFile and Path:getRelative(preview.bannerFile, preview.root) or nil -- 138
	if not Content:move(preview.root, target) then -- 138
		fail("无法安装作品，请检查剩余空间后重试", "Could not install game; check available space and retry") -- 139
	end -- 139
	Content:remove(preview.stage) -- 140
	return { -- 141
		id = name, -- 141
		title = preview.title, -- 141
		description = "", -- 141
		kind = "local", -- 141
		workDir = target, -- 141
		fileName = Path(target, "init"), -- 142
		bannerFile = banner and Path(target, banner) or nil -- 142
	} -- 142
end -- 132
--- Snapshot source and assets before zipping so subsequent edits cannot alter a shared package.
function ____exports.exportPackage(entry) -- 146
	local root = entry.workDir -- 147
	if not root or not runnable(root) then -- 147
		fail("请先构建作品，确认可以试玩后再分享", "Build the game and check that it runs before sharing") -- 148
	end -- 148
	local stage = newStage() -- 149
	do -- 149
		local function ____catch(e) -- 149
			Content:remove(stage) -- 174
			error(e, 0) -- 175
		end -- 175
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 175
			local snapshot = Path(stage, "snapshot") -- 151
			if not Content:mkdir(snapshot) then -- 151
				fail("无法创建作品快照", "Could not create game snapshot") -- 152
			end -- 152
			local total = 0 -- 153
			local files = __TS__ArrayFilter( -- 154
				Content:getAllFiles(root), -- 154
				function(____, file) return ____exports.packageFileAllowed(file) end -- 154
			) -- 154
			if #files > 10000 then -- 154
				fail("作品文件数量过多", "Too many game files") -- 155
			end -- 155
			for ____, file in ipairs(files) do -- 156
				local size = Content:getAttr(Path(root, file)) -- 157
				total = total + (size or 0) -- 158
				if total > maxUnpackedBytes then -- 158
					fail("作品不能超过 512 MB", "Game exceeds 512 MB") -- 159
				end -- 159
				local target = Path(snapshot, file) -- 160
				Content:mkdir(Path:getPath(target)) -- 161
				if not Content:copyAsync( -- 161
					Path(root, file), -- 162
					target -- 162
				) then -- 162
					fail("复制作品文件失败", "Could not copy game files") -- 162
				end -- 162
			end -- 162
			local previous = readObject(Path(snapshot, manifestName)) -- 164
			local manifest = __TS__ObjectAssign({}, previous or ({}), { -- 165
				format = "dora-game", -- 165
				version = 1, -- 165
				title = entry.title, -- 165
				engineVersion = App.version, -- 165
				entry = "init" -- 165
			}) -- 165
			if not Content:save( -- 165
				Path(snapshot, manifestName), -- 166
				encodeObject(manifest) -- 166
			) then -- 166
				fail("无法保存作品信息", "Could not save game metadata") -- 166
			end -- 166
			local path = Path( -- 167
				stage, -- 167
				cleanName(entry.title) .. ".zip" -- 167
			) -- 167
			if not Content:zipAsync(snapshot, path) then -- 167
				fail("作品打包失败", "Could not package game") -- 168
			end -- 168
			Content:remove(snapshot) -- 169
			local bytes = Content:getAttr(path) -- 170
			if bytes == nil or bytes > maxPackageBytes then -- 170
				fail("作品包不能超过 256 MB", "Package exceeds 256 MB") -- 171
			end -- 171
			return true, {path = path, bytes = bytes} -- 172
		end) -- 172
		if not ____try then -- 172
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 172
		end -- 172
		if ____hasReturned then -- 172
			return ____returnValue -- 150
		end -- 150
	end -- 150
end -- 146
return ____exports -- 146