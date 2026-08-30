-- [ts]: GitInstaller.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
local ____Git = require("Tools.ResourceDownloader.Git") -- 4
local quoteGitArgument = ____Git.quoteGitArgument -- 4
local runGit = ____Git.runGit -- 4
local function emitProgress(options, progress, message, source) -- 26
	if options.onProgress then -- 26
		options:onProgress({progress = progress, message = message, source = source}) -- 32
	end -- 32
end -- 26
local function installMetadata(resource, version, installedCommit, catalogCommit, source, tempPath) -- 35
	local doraPath = Path(tempPath, ".dora") -- 43
	if not Content:mkdir(doraPath) and not Content:isdir(doraPath) then -- 43
		return "failed to create .dora directory" -- 45
	end -- 45
	local stateJSON = json.encode({ -- 47
		schemaVersion = 1, -- 48
		resourceId = resource.id, -- 49
		version = version.name, -- 50
		commit = installedCommit, -- 51
		source = source, -- 52
		catalogCommit = catalogCommit, -- 53
		installedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 54
	}) -- 54
	if not stateJSON or not Content:save( -- 54
		Path(doraPath, "resource-state.json"), -- 56
		stateJSON -- 56
	) then -- 56
		return "failed to save resource installation state" -- 57
	end -- 57
	local oldEntrypoints = __TS__ArrayMap( -- 59
		resource.entrypoints, -- 59
		function(____, entry) return Path:getPath(entry.path) end -- 59
	) -- 59
	local ____json_encode_5 = json.encode -- 60
	local ____resource_id_1 = resource.id -- 61
	local ____temp_2 = {zh = resource.title["zh-Hans"], en = resource.title.en} -- 62
	local ____temp_3 = {zh = resource.description["zh-Hans"], en = resource.description.en} -- 66
	local ____resource_categories_4 = resource.categories -- 70
	local ____resource_runnable_0 -- 71
	if resource.runnable then -- 71
		____resource_runnable_0 = #oldEntrypoints > 0 and oldEntrypoints or true -- 72
	else -- 72
		____resource_runnable_0 = false -- 73
	end -- 73
	local repoJSON = ____json_encode_5({ -- 60
		name = ____resource_id_1, -- 61
		title = ____temp_2, -- 62
		desc = ____temp_3, -- 66
		categories = ____resource_categories_4, -- 70
		exe = ____resource_runnable_0, -- 71
		noBanner = resource.bannerPath == nil -- 74
	}) -- 74
	if not repoJSON or not Content:save( -- 74
		Path(doraPath, "repo.json"), -- 76
		repoJSON -- 76
	) then -- 76
		return "failed to save compatibility metadata" -- 77
	end -- 77
	local previewSource = resource.bannerPath or Path(Content.assetPath, "Image", "banner.jpg") -- 79
	if Content:exist(previewSource) and not Content:copy( -- 79
		previewSource, -- 81
		Path(doraPath, "banner.jpg") -- 81
	) then -- 81
		return "failed to copy resource preview" -- 82
	end -- 82
	return nil -- 84
end -- 35
____exports.getResourceInstallPath = function(resourceId) return Path(Content.writablePath, "Download", resourceId) end -- 87
____exports.isResourceInstalled = function(resourceId) return Content:isdir(____exports.getResourceInstallPath(resourceId)) end -- 90
____exports.installResource = function(resource, version, options) -- 93
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 93
		local downloadPath = Path(Content.writablePath, "Download") -- 98
		if not Content:mkdir(downloadPath) and not Content:isdir(downloadPath) then -- 98
			return ____awaiter_resolve(nil, {success = false, message = "failed to create Download directory"}) -- 98
		end -- 98
		local targetPath = ____exports.getResourceInstallPath(resource.id) -- 102
		if Content:exist(targetPath) then -- 102
			return ____awaiter_resolve(nil, {success = false, message = "target directory already exists; use Git tools to maintain the installed project"}) -- 102
		end -- 102
		if resource.status ~= "active" and resource.status ~= "deprecated" then -- 102
			return ____awaiter_resolve(nil, {success = false, message = ("resource status " .. resource.status) .. " cannot be installed"}) -- 102
		end -- 102
		local stagingRoot = Path(Content.writablePath, ".download") -- 112
		if not Content:mkdir(stagingRoot) and not Content:isdir(stagingRoot) then -- 112
			return ____awaiter_resolve(nil, {success = false, message = "failed to create download staging directory"}) -- 112
		end -- 112
		local lastMessage = "no resource source is available" -- 116
		do -- 116
			local sourceIndex = 0 -- 117
			while sourceIndex < #version.sources do -- 117
				do -- 117
					if options.isCanceled and options:isCanceled() then -- 117
						return ____awaiter_resolve(nil, {success = false, message = "installation canceled", canceled = true}) -- 117
					end -- 117
					local source = version.sources[sourceIndex + 1] -- 121
					local operationId = (tostring(os.time()) .. "-") .. tostring(sourceIndex + 1) -- 122
					local tempName = ((".resource-" .. resource.id) .. "-") .. operationId -- 123
					local tempPath = Path(stagingRoot, tempName) -- 124
					if Content:exist(tempPath) then -- 124
						Content:remove(tempPath) -- 125
					end -- 125
					emitProgress(options, 0.02, sourceIndex == 0 and "Connecting to resource repository" or "Trying the next resource source", source.url) -- 126
					local command = ((("clone " .. quoteGitArgument(source.url)) .. " ") .. quoteGitArgument(tempName)) .. " --depth 1"
					if version.tag then -- 132
						command = command .. " --branch " .. quoteGitArgument("refs/tags/" .. version.tag)
					end -- 134
					local cloneResult = __TS__Await(runGit( -- 136
						stagingRoot, -- 136
						command, -- 136
						{ -- 136
							timeout = 1800, -- 137
							isCanceled = options.isCanceled, -- 138
							onStatus = function(____, status) -- 139
								emitProgress( -- 140
									options, -- 141
									math.max( -- 142
										0.03, -- 142
										math.min(0.82, status.progress * 0.82) -- 142
									), -- 142
									status.message or "Receiving Git objects", -- 143
									source.url -- 144
								) -- 144
							end -- 139
						} -- 139
					)) -- 139
					if not cloneResult.success then -- 139
						Content:remove(tempPath) -- 149
						lastMessage = cloneResult.message or "Git clone failed" -- 150
						if cloneResult.canceled then -- 150
							return ____awaiter_resolve(nil, {success = false, message = lastMessage, canceled = true}) -- 150
						end -- 150
						goto __continue18 -- 154
					end -- 154
					emitProgress(options, 0.86, "Checking resource structure", source.url) -- 156
					local verifyResult = __TS__Await(runGit(tempPath, "verify-resource", {timeout = 60, isCanceled = options.isCanceled})) -- 157
					if not verifyResult.success then -- 157
						Content:remove(tempPath) -- 163
						lastMessage = verifyResult.message or "resource repository safety verification failed" -- 164
						goto __continue18 -- 165
					end -- 165
					local ____opt_8 = verifyResult.status -- 165
					local ____opt_6 = ____opt_8 and ____opt_8.data -- 165
					local installedCommit = ____opt_6 and ____opt_6.commit -- 167
					if type(installedCommit) ~= "string" then -- 167
						Content:remove(tempPath) -- 169
						lastMessage = "resource repository safety verification did not return HEAD" -- 170
						goto __continue18 -- 171
					end -- 171
					emitProgress(options, 0.92, "Writing Dora resource metadata", source.url) -- 173
					local metadataError = installMetadata( -- 174
						resource, -- 175
						version, -- 176
						installedCommit, -- 177
						options.catalogCommit, -- 178
						source.url, -- 179
						tempPath -- 180
					) -- 180
					if metadataError then -- 180
						Content:remove(tempPath) -- 183
						lastMessage = metadataError -- 184
						goto __continue18 -- 185
					end -- 185
					if Content:exist(targetPath) then -- 185
						Content:remove(tempPath) -- 188
						return ____awaiter_resolve(nil, {success = false, message = "target directory was created while the resource was installing"}) -- 188
					end -- 188
					emitProgress(options, 0.97, "Installing project", source.url) -- 194
					if not Content:move(tempPath, targetPath) then -- 194
						Content:remove(tempPath) -- 196
						lastMessage = "failed to move the project into Download" -- 197
						goto __continue18 -- 198
					end -- 198
					Director.postNode:emit("UpdateEntries") -- 200
					emitProgress(options, 1, "Installed", source.url) -- 201
					return ____awaiter_resolve(nil, {success = true, targetPath = targetPath, source = source.url}) -- 201
				end -- 201
				::__continue18:: -- 201
				sourceIndex = sourceIndex + 1 -- 117
			end -- 117
		end -- 117
		return ____awaiter_resolve(nil, {success = false, message = lastMessage}) -- 117
	end) -- 117
end -- 93
return ____exports -- 93