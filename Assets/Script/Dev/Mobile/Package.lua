-- [ts]: Package.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
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
	local cleaned = __TS__StringTrim((string.gsub(value, "[\\/:*?\"<>|%c]", "_"))) -- 34
	local name = (string.gsub(cleaned, "^%.+", "")) -- 35
	local ____end = utf8.offset(name, 61) -- 36
	return name == "" and "Game" or (____end and string.sub(name, 1, ____end - 1) or name) -- 37
end -- 33
local function newStage() -- 40
	local cache = Path(Content.writablePath, ".share") -- 41
	for ____, dir in ipairs(Content:exist(cache) and Content:getDirs(cache) or ({})) do -- 43
		local stamp = string.match(dir, "^(%d+)%-%d+$") -- 44
		if stamp ~= nil and (tonumber(stamp) or os.time()) < os.time() - 7 * 86400 then -- 44
			Content:remove(Path(cache, dir)) -- 45
		end -- 45
	end -- 45
	local path = Path( -- 47
		Content.writablePath, -- 47
		".share", -- 47
		(tostring(os.time()) .. "-") .. tostring(App.rand) -- 47
	) -- 47
	if not Content:mkdir(path) then -- 47
		fail("无法创建临时目录", "Could not create temporary folder") -- 48
	end -- 48
	return path -- 49
end -- 40
local function encodeObject(value) -- 52
	local encoded = json.encode(value) -- 53
	if encoded == nil then -- 53
		fail("无法编码作品信息", "Could not encode game metadata") -- 54
	end -- 54
	return encoded -- 55
end -- 52
local function readObject(path) -- 58
	if not Content:exist(path) then -- 58
		return nil -- 59
	end -- 59
	local size = Content:getAttr(path) -- 60
	if size == nil or size > 64 * 1024 then -- 60
		fail("作品信息过大", "Package metadata is too large") -- 61
	end -- 61
	local value = json.decode(Content:load(path)) -- 62
	if type(value) ~= "table" then -- 62
		fail("作品信息格式不正确", "Invalid package metadata") -- 63
	end -- 63
	return value -- 64
end -- 58
local function runnable(root) -- 67
	return __TS__ArraySome( -- 68
		runtimeEntries, -- 68
		function(____, file) return Content:exist(Path(root, file)) and not Content:isdir(Path(root, file)) end -- 68
	) -- 68
end -- 67
function ____exports.discardPackage(preview) -- 71
	Content:remove(preview.stage) -- 72
end -- 71
--- Call in a Dora coroutine. This inspects data only, never executes imported code.
function ____exports.inspectPackage(path) -- 76
	local bytes = Content:getAttr(path) -- 77
	if bytes == nil or bytes > maxPackageBytes or bytes == 0 or Content:isdir(path) then -- 77
		fail("无法读取作品包，文件应小于 256 MB", "Cannot read package; maximum size is 256 MB") -- 79
	end -- 79
	local stage = newStage() -- 81
	do -- 81
		local function ____catch(e) -- 81
			Content:remove(stage) -- 123
			error(e, 0) -- 124
		end -- 124
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 124
			local unpacked = Path(stage, "content") -- 83
			if not Content:unzipAsync( -- 83
				path, -- 84
				unpacked, -- 84
				____exports.packageFileAllowed, -- 84
				maxUnpackedBytes, -- 84
				10000 -- 84
			) then -- 84
				fail("作品包损坏、过大或含有无效路径", "Package is damaged, too large, or contains invalid paths") -- 84
			end -- 84
			local root = unpacked -- 85
			if not runnable(root) then -- 85
				local dirs = __TS__ArrayFilter( -- 87
					Content:getDirs(root), -- 87
					function(____, dir) return not __TS__StringStartsWith(dir, ".") end -- 87
				) -- 87
				if #dirs == 1 and runnable(Path(root, dirs[1])) then -- 87
					root = Path(root, dirs[1]) -- 88
				end -- 88
			end -- 88
			if not runnable(root) then -- 88
				fail("未找到可运行入口 init，请先在 Dora 中构建作品", "No runnable init entry; build the project in Dora first") -- 90
			end -- 90
			local total = 0 -- 91
			for ____, file in ipairs(Content:getAllFiles(root)) do -- 92
				local size = Content:getAttr(Path(root, file)) -- 93
				total = total + (size or 0) -- 94
			end -- 94
			if total > maxUnpackedBytes then -- 94
				fail("解包后的作品不能超过 512 MB", "Unpacked game exceeds 512 MB") -- 96
			end -- 96
			local manifest = readObject(Path(root, manifestName)) -- 97
			if manifest and (manifest.format ~= "dora-game" or manifest.version ~= 1) then -- 97
				fail("不支持此作品包版本，请更新 Dora", "Unsupported package version; update Dora") -- 98
			end -- 98
			local repo = readObject(Path(root, ".dora", "repo.json")) -- 99
			if type(manifest and manifest.engineVersion) == "string" then -- 99
				local required = __TS__ArrayMap( -- 101
					__TS__StringSplit(manifest.engineVersion, "."), -- 101
					function(____, part) return tonumber(part) or 0 end -- 101
				) -- 101
				local current = __TS__ArrayMap( -- 102
					__TS__StringSplit(App.version, "."), -- 102
					function(____, part) return tonumber(part) or 0 end -- 102
				) -- 102
				do -- 102
					local i = 0 -- 103
					while i < math.max(#required, #current) do -- 103
						if (required[i + 1] or 0) > (current[i + 1] or 0) then -- 103
							fail("作品由更新版本的 Dora 导出，请先更新引擎", "This package was exported by a newer Dora; update the engine first") -- 104
						end -- 104
						if (required[i + 1] or 0) < (current[i + 1] or 0) then -- 104
							break -- 105
						end -- 105
						i = i + 1 -- 103
					end -- 103
				end -- 103
			end -- 103
			local title = cleanName(type(manifest and manifest.title) == "string" and manifest.title or (root ~= unpacked and Path:getFilename(root) or Path:getName(path))) -- 108
			local author = type(manifest and manifest.author) == "string" and __TS__StringSubstring(manifest.author, 0, 80) or nil -- 109
			if repo then -- 109
				local ____temp_6 -- 112
				if type(repo.title) == "table" then -- 112
					____temp_6 = repo.title -- 112
				else -- 112
					____temp_6 = {} -- 112
				end -- 112
				local titleInfo = ____temp_6 -- 112
				local ____temp_7 -- 113
				if type(repo.description) == "table" then -- 113
					____temp_7 = repo.description -- 113
				else -- 113
					____temp_7 = {} -- 113
				end -- 113
				local description = ____temp_7 -- 113
				repo.title = { -- 114
					zh = type(titleInfo.zh) == "string" and titleInfo.zh or title, -- 114
					en = type(titleInfo.en) == "string" and titleInfo.en or title -- 114
				} -- 114
				repo.description = { -- 115
					zh = type(description.zh) == "string" and description.zh or "", -- 115
					en = type(description.en) == "string" and description.en or "" -- 115
				} -- 115
				repo.categories = {} -- 116
				if not Content:save( -- 116
					Path(root, ".dora", "repo.json"), -- 117
					encodeObject(repo) -- 117
				) then -- 117
					fail("无法保存作品信息", "Could not save game metadata") -- 117
				end -- 117
			end -- 117
			local bannerFile = __TS__ArrayFind( -- 119
				__TS__ArrayMap( -- 119
					{".dora/banner.jpg", ".dora/banner.png", "Image/banner.jpg", "Image/banner.png"}, -- 119
					function(____, file) return Path(root, file) end -- 120
				), -- 120
				function(____, file) return Content:exist(file) end -- 120
			) -- 120
			return true, { -- 121
				stage = stage, -- 121
				root = root, -- 121
				title = title, -- 121
				author = author, -- 121
				bannerFile = bannerFile, -- 121
				bytes = bytes -- 121
			} -- 121
		end) -- 121
		if not ____try then -- 121
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 121
		end -- 121
		if ____hasReturned then -- 121
			return ____returnValue -- 82
		end -- 82
	end -- 82
end -- 76
function ____exports.installPackage(preview) -- 128
	local ____array_8 = __TS__SparseArrayNew(table.unpack(Content:getDirs(Content.writablePath))) -- 128
	__TS__SparseArrayPush( -- 128
		____array_8, -- 128
		table.unpack(Content:getFiles(Content.writablePath)) -- 129
	) -- 129
	local existing = __TS__ArrayMap( -- 129
		{__TS__SparseArraySpread(____array_8)}, -- 129
		function(____, name) return string.lower(name) end -- 129
	) -- 129
	local name = cleanName(preview.title) -- 130
	local suffix = 2 -- 131
	while __TS__ArrayIncludes( -- 131
		existing, -- 132
		string.lower(name) -- 132
	) or Content:exist(Path(Content.writablePath, name)) do -- 132
		local ____cleanName_result_10 = cleanName(preview.title) -- 132
		local ____suffix_9 = suffix -- 132
		suffix = ____suffix_9 + 1 -- 132
		name = ((____cleanName_result_10 .. " (") .. tostring(____suffix_9)) .. ")" -- 132
	end -- 132
	local target = Path(Content.writablePath, name) -- 133
	local banner = preview.bannerFile and Path:getRelative(preview.bannerFile, preview.root) or nil -- 134
	if not Content:move(preview.root, target) then -- 134
		fail("无法安装作品，请检查剩余空间后重试", "Could not install game; check available space and retry") -- 135
	end -- 135
	Content:remove(preview.stage) -- 136
	return { -- 137
		id = name, -- 137
		title = preview.title, -- 137
		description = "", -- 137
		kind = "local", -- 137
		workDir = target, -- 137
		fileName = Path(target, "init"), -- 138
		bannerFile = banner and Path(target, banner) or nil -- 138
	} -- 138
end -- 128
--- Snapshot source and assets before zipping so subsequent edits cannot alter a shared package.
function ____exports.exportPackage(entry) -- 142
	local root = entry.workDir -- 143
	if not root or not runnable(root) then -- 143
		fail("请先构建作品，确认可以试玩后再分享", "Build the game and check that it runs before sharing") -- 144
	end -- 144
	local stage = newStage() -- 145
	do -- 145
		local function ____catch(e) -- 145
			Content:remove(stage) -- 170
			error(e, 0) -- 171
		end -- 171
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 171
			local snapshot = Path(stage, "snapshot") -- 147
			if not Content:mkdir(snapshot) then -- 147
				fail("无法创建作品快照", "Could not create game snapshot") -- 148
			end -- 148
			local total = 0 -- 149
			local files = __TS__ArrayFilter( -- 150
				Content:getAllFiles(root), -- 150
				function(____, file) return ____exports.packageFileAllowed(file) end -- 150
			) -- 150
			if #files > 10000 then -- 150
				fail("作品文件数量过多", "Too many game files") -- 151
			end -- 151
			for ____, file in ipairs(files) do -- 152
				local size = Content:getAttr(Path(root, file)) -- 153
				total = total + (size or 0) -- 154
				if total > maxUnpackedBytes then -- 154
					fail("作品不能超过 512 MB", "Game exceeds 512 MB") -- 155
				end -- 155
				local target = Path(snapshot, file) -- 156
				Content:mkdir(Path:getPath(target)) -- 157
				if not Content:copyAsync( -- 157
					Path(root, file), -- 158
					target -- 158
				) then -- 158
					fail("复制作品文件失败", "Could not copy game files") -- 158
				end -- 158
			end -- 158
			local previous = readObject(Path(snapshot, manifestName)) -- 160
			local manifest = __TS__ObjectAssign({}, previous or ({}), { -- 161
				format = "dora-game", -- 161
				version = 1, -- 161
				title = entry.title, -- 161
				engineVersion = App.version, -- 161
				entry = "init" -- 161
			}) -- 161
			if not Content:save( -- 161
				Path(snapshot, manifestName), -- 162
				encodeObject(manifest) -- 162
			) then -- 162
				fail("无法保存作品信息", "Could not save game metadata") -- 162
			end -- 162
			local path = Path( -- 163
				stage, -- 163
				cleanName(entry.title) .. ".zip" -- 163
			) -- 163
			if not Content:zipAsync(snapshot, path) then -- 163
				fail("作品打包失败", "Could not package game") -- 164
			end -- 164
			Content:remove(snapshot) -- 165
			local bytes = Content:getAttr(path) -- 166
			if bytes == nil or bytes > maxPackageBytes then -- 166
				fail("作品包不能超过 256 MB", "Package exceeds 256 MB") -- 167
			end -- 167
			return true, {path = path, bytes = bytes} -- 168
		end) -- 168
		if not ____try then -- 168
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 168
		end -- 168
		if ____hasReturned then -- 168
			return ____returnValue -- 146
		end -- 146
	end -- 146
end -- 142
return ____exports -- 142