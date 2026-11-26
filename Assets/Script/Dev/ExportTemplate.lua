-- [ts]: ExportTemplate.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local thread = ____Dora.thread -- 2
local ____UpdateSync = require("Tools.SelfUpdater.UpdateSync") -- 3
local preparePinnedUpdatePackage = ____UpdateSync.preparePinnedUpdatePackage -- 3
local pending = {} -- 7
local function usable(folder, target, apk) -- 9
	local ____temp_0 -- 10
	if target == "android" then -- 10
		____temp_0 = Content:exist(Path(folder, apk)) -- 11
	else -- 11
		____temp_0 = Content:exist(Path(folder, "Dora.exe")) and Content:isdir(Path(folder, "Script", "Lib")) -- 12
	end -- 12
	return ____temp_0 -- 10
end -- 9
local function download(target, version, revision, folder, apk) -- 15
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 15
		local zh = __TS__StringStartsWith(App.locale, "zh") -- 16
		local prepared = __TS__Await(preparePinnedUpdatePackage(version, revision, target)) -- 17
		if not prepared then -- 17
			return ____awaiter_resolve(nil, {message = zh and ((("无法下载与 Dora " .. App.version) .. " 匹配的 ") .. target) .. " 模板" or (("Could not download the " .. target) .. " template matching Dora ") .. App.version}) -- 17
		end -- 17
		return ____awaiter_resolve( -- 17
			nil, -- 17
			__TS__New( -- 21
				__TS__Promise, -- 21
				function(____, resolve) return thread(function() -- 21
					local stage = (((folder .. ".stage-") .. tostring(os.time())) .. "-") .. tostring(App.rand) -- 22
					Content:mkdir(Path:getPath(folder)) -- 23
					local unpacked = Content:unzipAsync( -- 24
						prepared.file, -- 24
						stage, -- 24
						nil, -- 24
						2 * 1024 * 1024 * 1024, -- 24
						30000 -- 24
					) -- 24
					local success = false -- 25
					if unpacked and usable(stage, target, apk) then -- 25
						if Content:exist(folder) then -- 25
							Content:remove(folder) -- 27
						end -- 27
						success = Content:move(stage, folder) -- 28
					end -- 28
					if Content:exist(stage) then -- 28
						Content:remove(stage) -- 30
					end -- 30
					Content:remove(prepared.cleanupPath) -- 31
					resolve(nil, success and ({folder = folder}) or ({message = zh and "无法缓存导出模板" or "Could not cache the export template"})) -- 32
				end) end -- 21
			) -- 21
		) -- 21
	end) -- 21
end -- 15
function ____exports.resolveExportTemplate(target, done) -- 36
	local version, revision = string.match(App.version, "^(%d+%.%d+%.%d+)%.(%d+)$") -- 37
	if version == nil or revision == nil then -- 37
		done({message = "Could not determine the Dora engine version"}) -- 39
		return -- 40
	end -- 40
	local folder = Path( -- 42
		Content.appPath, -- 42
		".cache", -- 42
		"export-templates", -- 42
		App.version, -- 42
		target -- 42
	) -- 42
	local tag = "v" .. version -- 43
	local apk = ("dora-ssr-" .. tag) .. "-android.apk" -- 44
	if usable(folder, target, apk) then -- 44
		done({folder = folder}) -- 46
		return -- 47
	end -- 47
	local operation = pending[target] or download( -- 49
		target, -- 49
		tag, -- 49
		tonumber(revision), -- 49
		folder, -- 49
		apk -- 49
	) -- 49
	pending[target] = operation -- 50
	operation["then"]( -- 51
		operation, -- 51
		function(____, result) -- 51
			pending[target] = nil -- 52
			done(result) -- 53
		end, -- 51
		function(____, ____error) -- 54
			pending[target] = nil -- 55
			done({message = tostring(____error)}) -- 56
		end -- 54
	) -- 54
end -- 36
return ____exports -- 36