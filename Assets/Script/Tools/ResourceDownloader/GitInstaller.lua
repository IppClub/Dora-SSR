-- [ts]: GitInstaller.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
local ____Git = require("Script.Tools.ResourceDownloader.Git") -- 4
local gitHeadFromStatus = ____Git.gitHeadFromStatus -- 4
local quoteGitArgument = ____Git.quoteGitArgument -- 4
local runGit = ____Git.runGit -- 4
local function emitProgress(options, progress, message, source) -- 26
	if options.onProgress then -- 26
		options:onProgress({progress = progress, message = message, source = source}) -- 32
	end -- 32
end -- 26
local function installMetadata(resource, version, catalogCommit, source, tempPath) -- 35
	local doraPath = Path(tempPath, ".dora") -- 42
	if not Content:mkdir(doraPath) and not Content:isdir(doraPath) then -- 42
		return "failed to create .dora directory" -- 44
	end -- 44
	local stateJSON = json.encode({ -- 46
		schemaVersion = 1, -- 47
		resourceId = resource.id, -- 48
		version = version.name, -- 49
		commit = version.commit, -- 50
		source = source, -- 51
		catalogCommit = catalogCommit, -- 52
		installedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 53
	}) -- 53
	if not stateJSON or not Content:save( -- 53
		Path(doraPath, "resource-state.json"), -- 55
		stateJSON -- 55
	) then -- 55
		return "failed to save resource installation state" -- 56
	end -- 56
	local oldEntrypoints = __TS__ArrayMap( -- 58
		resource.entrypoints, -- 58
		function(____, entry) return Path:getPath(entry.path) end -- 58
	) -- 58
	local ____json_encode_5 = json.encode -- 59
	local ____resource_id_1 = resource.id -- 60
	local ____temp_2 = {zh = resource.title["zh-Hans"], en = resource.title.en} -- 61
	local ____temp_3 = {zh = resource.description["zh-Hans"], en = resource.description.en} -- 65
	local ____resource_categories_4 = resource.categories -- 69
	local ____resource_runnable_0 -- 70
	if resource.runnable then -- 70
		____resource_runnable_0 = #oldEntrypoints > 0 and oldEntrypoints or true -- 71
	else -- 71
		____resource_runnable_0 = false -- 72
	end -- 72
	local repoJSON = ____json_encode_5({ -- 59
		name = ____resource_id_1, -- 60
		title = ____temp_2, -- 61
		desc = ____temp_3, -- 65
		categories = ____resource_categories_4, -- 69
		exe = ____resource_runnable_0, -- 70
		noBanner = resource.bannerPath == nil -- 73
	}) -- 73
	if not repoJSON or not Content:save( -- 73
		Path(doraPath, "repo.json"), -- 75
		repoJSON -- 75
	) then -- 75
		return "failed to save compatibility metadata" -- 76
	end -- 76
	local previewSource = resource.bannerPath or Path(Content.assetPath, "Image", "banner.jpg") -- 78
	if Content:exist(previewSource) and not Content:copy( -- 78
		previewSource, -- 80
		Path(doraPath, "banner.jpg") -- 80
	) then -- 80
		return "failed to copy resource preview" -- 81
	end -- 81
	return nil -- 83
end -- 35
____exports.getResourceInstallPath = function(resourceId) return Path(Content.writablePath, "Download", resourceId) end -- 86
____exports.isResourceInstalled = function(resourceId) return Content:isdir(____exports.getResourceInstallPath(resourceId)) end -- 89
____exports.installResource = function(resource, version, options) -- 92
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 92
		local targetPath = ____exports.getResourceInstallPath(resource.id) -- 97
		if Content:exist(targetPath) then -- 97
			return ____awaiter_resolve(nil, {success = false, message = "target directory already exists; use Git tools to maintain the installed project"}) -- 97
		end -- 97
		if resource.status ~= "active" and resource.status ~= "deprecated" then -- 97
			return ____awaiter_resolve(nil, {success = false, message = ("resource status " .. resource.status) .. " cannot be installed"}) -- 97
		end -- 97
		local stagingRoot = Path(Content.writablePath, ".download") -- 107
		if not Content:mkdir(stagingRoot) and not Content:isdir(stagingRoot) then -- 107
			return ____awaiter_resolve(nil, {success = false, message = "failed to create download staging directory"}) -- 107
		end -- 107
		local lastMessage = "no resource source is available" -- 111
		do -- 111
			local sourceIndex = 0 -- 112
			while sourceIndex < #version.sources do -- 112
				do -- 112
					if options.isCanceled and options:isCanceled() then -- 112
						return ____awaiter_resolve(nil, {success = false, message = "installation canceled", canceled = true}) -- 112
					end -- 112
					local source = version.sources[sourceIndex + 1] -- 116
					local operationId = (tostring(os.time()) .. "-") .. tostring(sourceIndex + 1) -- 117
					local tempName = ((".resource-" .. resource.id) .. "-") .. operationId -- 118
					local tempPath = Path(stagingRoot, tempName) -- 119
					if Content:exist(tempPath) then -- 119
						Content:remove(tempPath) -- 120
					end -- 120
					emitProgress(options, 0.02, sourceIndex == 0 and "Connecting to resource repository" or "Trying the next resource source", source.url) -- 121
					local command = ((("clone " .. quoteGitArgument(source.url)) .. " ") .. quoteGitArgument(tempName)) .. " --depth 1"
					if version.tag then -- 127
						command = command .. " --branch " .. quoteGitArgument("refs/tags/" .. version.tag)
					end -- 129
					local cloneResult = __TS__Await(runGit( -- 131
						stagingRoot, -- 131
						command, -- 131
						{ -- 131
							timeout = 1800, -- 132
							isCanceled = options.isCanceled, -- 133
							onStatus = function(____, status) -- 134
								emitProgress( -- 135
									options, -- 136
									math.max( -- 137
										0.03, -- 137
										math.min(0.82, status.progress * 0.82) -- 137
									), -- 137
									status.message or "Receiving Git objects", -- 138
									source.url -- 139
								) -- 139
							end -- 134
						} -- 134
					)) -- 134
					if not cloneResult.success then -- 134
						Content:remove(tempPath) -- 144
						lastMessage = cloneResult.message or "Git clone failed" -- 145
						if cloneResult.canceled then -- 145
							return ____awaiter_resolve(nil, {success = false, message = lastMessage, canceled = true}) -- 145
						end -- 145
						goto __continue17 -- 149
					end -- 149
					emitProgress(options, 0.86, "Verifying the installed commit", source.url) -- 151
					local actualHead = gitHeadFromStatus(cloneResult.status) -- 152
					if actualHead ~= version.commit then -- 152
						Content:remove(tempPath) -- 154
						lastMessage = actualHead and (("source HEAD " .. actualHead) .. " does not match catalog commit ") .. version.commit or "Git clone did not return a commit hash" -- 155
						goto __continue17 -- 158
					end -- 158
					local verifyResult = __TS__Await(runGit( -- 160
						tempPath, -- 161
						"verify-resource " .. quoteGitArgument(version.commit), -- 162
						{timeout = 60, isCanceled = options.isCanceled} -- 163
					)) -- 163
					if not verifyResult.success then -- 163
						Content:remove(tempPath) -- 166
						lastMessage = verifyResult.message or "resource repository safety verification failed" -- 167
						goto __continue17 -- 168
					end -- 168
					local missingEntrypoint = __TS__ArrayFind( -- 170
						resource.entrypoints, -- 170
						function(____, entry) return not Content:exist(Path(tempPath, entry.path)) end -- 171
					) -- 171
					if missingEntrypoint then -- 171
						Content:remove(tempPath) -- 174
						lastMessage = "resource entrypoint does not exist: " .. missingEntrypoint.path -- 175
						goto __continue17 -- 176
					end -- 176
					emitProgress(options, 0.92, "Writing Dora resource metadata", source.url) -- 178
					local metadataError = installMetadata( -- 179
						resource, -- 179
						version, -- 179
						options.catalogCommit, -- 179
						source.url, -- 179
						tempPath -- 179
					) -- 179
					if metadataError then -- 179
						Content:remove(tempPath) -- 181
						lastMessage = metadataError -- 182
						goto __continue17 -- 183
					end -- 183
					if Content:exist(targetPath) then -- 183
						Content:remove(tempPath) -- 186
						return ____awaiter_resolve(nil, {success = false, message = "target directory was created while the resource was installing"}) -- 186
					end -- 186
					emitProgress(options, 0.97, "Installing the verified project", source.url) -- 192
					if not Content:move(tempPath, targetPath) then -- 192
						Content:remove(tempPath) -- 194
						lastMessage = "failed to move the verified project into Download" -- 195
						goto __continue17 -- 196
					end -- 196
					Director.postNode:emit("UpdateEntries") -- 198
					emitProgress(options, 1, "Installed", source.url) -- 199
					return ____awaiter_resolve(nil, {success = true, targetPath = targetPath, source = source.url}) -- 199
				end -- 199
				::__continue17:: -- 199
				sourceIndex = sourceIndex + 1 -- 112
			end -- 112
		end -- 112
		return ____awaiter_resolve(nil, {success = false, message = lastMessage}) -- 112
	end) -- 112
end -- 92
return ____exports -- 92