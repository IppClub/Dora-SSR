-- [ts]: GitInstaller.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
local ____Git = require("Tools.ResourceDownloader.Git") -- 4
local quoteGitArgument = ____Git.quoteGitArgument -- 4
local runGit = ____Git.runGit -- 4
local activeProjects = __TS__New(Set) -- 28
local operationSequence = 0 -- 29
local function emitProgress(options, progress, message, source, transferredBytes) -- 31
	if options.onProgress then -- 31
		options:onProgress({progress = progress, message = message, source = source, transferredBytes = transferredBytes}) -- 38
	end -- 38
end -- 31
local function installMetadata(resource, version, installedCommit, catalogCommit, source, tempPath) -- 41
	local doraPath = Path(tempPath, ".dora") -- 49
	if not Content:mkdir(doraPath) and not Content:isdir(doraPath) then -- 49
		return "failed to create .dora directory" -- 51
	end -- 51
	local stateJSON = json.encode({ -- 53
		schemaVersion = 1, -- 54
		resourceId = resource.id, -- 55
		version = version.name, -- 56
		commit = installedCommit, -- 57
		source = source, -- 58
		catalogCommit = catalogCommit, -- 59
		installedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 60
	}) -- 60
	if not stateJSON or not Content:save( -- 60
		Path(doraPath, "resource-state.json"), -- 62
		stateJSON -- 62
	) then -- 62
		return "failed to save resource installation state" -- 63
	end -- 63
	local oldEntrypoints = __TS__ArrayMap( -- 65
		resource.entrypoints, -- 65
		function(____, entry) return Path:getPath(entry.path) end -- 65
	) -- 65
	local ____json_encode_5 = json.encode -- 66
	local ____resource_id_1 = resource.id -- 67
	local ____temp_2 = {zh = resource.title["zh-Hans"], en = resource.title.en} -- 68
	local ____temp_3 = {zh = resource.description["zh-Hans"], en = resource.description.en} -- 72
	local ____resource_categories_4 = resource.categories -- 76
	local ____resource_runnable_0 -- 77
	if resource.runnable then -- 77
		____resource_runnable_0 = #oldEntrypoints > 0 and oldEntrypoints or true -- 78
	else -- 78
		____resource_runnable_0 = false -- 79
	end -- 79
	local repoJSON = ____json_encode_5({ -- 66
		name = ____resource_id_1, -- 67
		title = ____temp_2, -- 68
		desc = ____temp_3, -- 72
		categories = ____resource_categories_4, -- 76
		exe = ____resource_runnable_0, -- 77
		noBanner = resource.bannerPath == nil -- 80
	}) -- 80
	if not repoJSON or not Content:save( -- 80
		Path(doraPath, "repo.json"), -- 82
		repoJSON -- 82
	) then -- 82
		return "failed to save compatibility metadata" -- 83
	end -- 83
	local previewSource = resource.bannerPath or Path(Content.assetPath, "Image", "banner.jpg") -- 85
	if Content:exist(previewSource) and not Content:copy( -- 85
		previewSource, -- 87
		Path(doraPath, "banner.jpg") -- 87
	) then -- 87
		return "failed to copy resource preview" -- 88
	end -- 88
	return nil -- 90
end -- 41
____exports.getResourceInstallPath = function(resourceId) return Path(Content.writablePath, "Download", resourceId) end -- 93
____exports.isResourceInstalled = function(resourceId) return Content:isdir(____exports.getResourceInstallPath(resourceId)) end -- 96
____exports.getInstalledCatalogResource = function(workDir, resources) -- 101
	local prefix = table.concat( -- 102
		__TS__StringSplit( -- 102
			Path(Content.writablePath, "Download"), -- 102
			"\\" -- 102
		), -- 102
		"/" -- 102
	) .. "/" -- 102
	local normalized = table.concat( -- 103
		__TS__StringSplit(workDir, "\\"), -- 103
		"/" -- 103
	) -- 103
	if not __TS__StringStartsWith(normalized, prefix) then -- 103
		return nil -- 104
	end -- 104
	local resourceId = __TS__StringSplit( -- 105
		__TS__StringSlice(normalized, #prefix), -- 105
		"/" -- 105
	)[1] -- 105
	local resource = __TS__ArrayFind( -- 106
		resources, -- 106
		function(____, item) return item.id == resourceId end -- 106
	) -- 106
	if not resource then -- 106
		return nil -- 107
	end -- 107
	local installPath = ____exports.getResourceInstallPath(resourceId) -- 108
	if not Content:isdir(installPath) then -- 108
		return nil -- 109
	end -- 109
	local stateFile = Path(installPath, ".dora", "resource-state.json") -- 110
	local hasState = Content:exist(stateFile) -- 111
	local file = hasState and stateFile or Path(installPath, ".dora", "repo.json") -- 114
	if not Content:exist(file) then -- 114
		return nil -- 115
	end -- 115
	local state, err = json.decode(Content:load(file)) -- 116
	local ____temp_7 = err == nil and type(state) == "table" and state ~= nil -- 117
	if ____temp_7 then -- 117
		local ____hasState_6 -- 118
		if hasState then -- 118
			____hasState_6 = state.resourceId -- 118
		else -- 118
			____hasState_6 = state.name -- 118
		end -- 118
		____temp_7 = ____hasState_6 == resourceId -- 117
	end -- 117
	if ____temp_7 then -- 117
		return resource -- 118
	end -- 118
	return nil -- 119
end -- 101
local function installResourceInternal(resource, version, options, replaceExisting) -- 122
	if replaceExisting == nil then -- 122
		replaceExisting = false -- 126
	end -- 126
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 126
		local downloadPath = Path(Content.writablePath, "Download") -- 128
		if not Content:mkdir(downloadPath) and not Content:isdir(downloadPath) then -- 128
			return ____awaiter_resolve(nil, {success = false, message = "failed to create Download directory"}) -- 128
		end -- 128
		local targetPath = ____exports.getResourceInstallPath(resource.id) -- 132
		if Content:exist(targetPath) and not replaceExisting then -- 132
			return ____awaiter_resolve(nil, {success = false, message = "target directory already exists; use Git tools to maintain the installed project"}) -- 132
		end -- 132
		if resource.status ~= "active" and resource.status ~= "deprecated" then -- 132
			return ____awaiter_resolve(nil, {success = false, message = ("resource status " .. resource.status) .. " cannot be installed"}) -- 132
		end -- 132
		local stagingRoot = Path(Content.writablePath, ".download") -- 142
		if not Content:mkdir(stagingRoot) and not Content:isdir(stagingRoot) then -- 142
			return ____awaiter_resolve(nil, {success = false, message = "failed to create download staging directory"}) -- 142
		end -- 142
		local lastMessage = "no resource source is available" -- 146
		do -- 146
			local sourceIndex = 0 -- 147
			while sourceIndex < #version.sources do -- 147
				do -- 147
					if options.isCanceled and options:isCanceled() then -- 147
						return ____awaiter_resolve(nil, {success = false, message = "installation canceled", canceled = true}) -- 147
					end -- 147
					local source = version.sources[sourceIndex + 1] -- 151
					local ____os_time_result_8 = os.time() -- 152
					operationSequence = operationSequence + 1 -- 152
					local operationId = (((tostring(____os_time_result_8) .. "-") .. tostring(operationSequence)) .. "-") .. tostring(sourceIndex + 1) -- 152
					local tempName = ((".resource-" .. resource.id) .. "-") .. operationId -- 153
					local tempPath = Path(stagingRoot, tempName) -- 154
					if Content:exist(tempPath) then -- 154
						Content:remove(tempPath) -- 155
					end -- 155
					emitProgress(options, 0.02, sourceIndex == 0 and "Connecting to resource repository" or "Trying the next resource source", source.url) -- 156
					local command = ((("clone " .. quoteGitArgument(source.url)) .. " ") .. quoteGitArgument(tempName)) .. " --depth 1"
					if version.tag then -- 162
						command = command .. " --branch " .. quoteGitArgument("refs/tags/" .. version.tag)
					end -- 164
					local cloneResult = __TS__Await(runGit( -- 166
						stagingRoot, -- 166
						command, -- 166
						{ -- 166
							timeout = 1800, -- 167
							isCanceled = options.isCanceled, -- 168
							onStatus = function(____, status) -- 169
								emitProgress( -- 170
									options, -- 171
									math.max( -- 172
										0.03, -- 172
										math.min(0.82, status.progress * 0.82) -- 172
									), -- 172
									status.message or "Receiving Git objects", -- 173
									source.url, -- 174
									status.transferredBytes -- 175
								) -- 175
							end -- 169
						} -- 169
					)) -- 169
					if not cloneResult.success then -- 169
						Content:remove(tempPath) -- 180
						lastMessage = cloneResult.message or "Git clone failed" -- 181
						if cloneResult.canceled then -- 181
							return ____awaiter_resolve(nil, {success = false, message = lastMessage, canceled = true}) -- 181
						end -- 181
						goto __continue25 -- 185
					end -- 185
					emitProgress(options, 0.86, "Checking resource structure", source.url) -- 187
					local verifyResult = __TS__Await(runGit(tempPath, "verify-resource", {timeout = 60, isCanceled = options.isCanceled})) -- 188
					if not verifyResult.success then -- 188
						Content:remove(tempPath) -- 194
						lastMessage = verifyResult.message or "resource repository safety verification failed" -- 195
						goto __continue25 -- 196
					end -- 196
					local ____opt_11 = verifyResult.status -- 196
					local ____opt_9 = ____opt_11 and ____opt_11.data -- 196
					local installedCommit = ____opt_9 and ____opt_9.commit -- 198
					if type(installedCommit) ~= "string" then -- 198
						Content:remove(tempPath) -- 200
						lastMessage = "resource repository safety verification did not return HEAD" -- 201
						goto __continue25 -- 202
					end -- 202
					emitProgress(options, 0.92, "Writing Dora resource metadata", source.url) -- 204
					local metadataError = installMetadata( -- 205
						resource, -- 206
						version, -- 207
						installedCommit, -- 208
						options.catalogCommit, -- 209
						source.url, -- 210
						tempPath -- 211
					) -- 211
					if metadataError then -- 211
						Content:remove(tempPath) -- 214
						lastMessage = metadataError -- 215
						goto __continue25 -- 216
					end -- 216
					local ____this_14 -- 216
					____this_14 = options -- 218
					local ____opt_13 = ____this_14.isCanceled -- 218
					if ____opt_13 and ____opt_13(____this_14) then -- 218
						Content:remove(tempPath) -- 219
						return ____awaiter_resolve(nil, {success = false, message = "synchronization canceled", canceled = true}) -- 219
					end -- 219
					if Content:exist(targetPath) and not replaceExisting then -- 219
						Content:remove(tempPath) -- 223
						return ____awaiter_resolve(nil, {success = false, message = "target directory was created while the resource was installing"}) -- 223
					end -- 223
					emitProgress(options, 0.97, "Installing project", source.url) -- 229
					local backupPath = Path(stagingRoot, tempName .. "-previous") -- 232
					local hadOriginal = Content:exist(targetPath) -- 233
					if hadOriginal and not Content:move(targetPath, backupPath) then -- 233
						Content:remove(tempPath) -- 235
						return ____awaiter_resolve(nil, {success = false, message = "failed to preserve the previous project"}) -- 235
					end -- 235
					if not Content:move(tempPath, targetPath) then -- 235
						Content:remove(tempPath) -- 239
						local cleared = not Content:exist(targetPath) or Content:remove(targetPath) -- 242
						local restored = cleared and (not hadOriginal or Content:move(backupPath, targetPath)) -- 243
						return ____awaiter_resolve(nil, {success = false, message = restored and "failed to replace the project; previous project restored" or "failed to replace the project; previous project remains at " .. backupPath}) -- 243
					end -- 243
					local cleanupMessage = hadOriginal and not Content:remove(backupPath) and "synchronized; previous project could not be removed from " .. backupPath or nil -- 248
					Content:clearPathCache() -- 250
					Director.postNode:emit("UpdateEntries") -- 251
					emitProgress(options, 1, "Installed", source.url) -- 252
					return ____awaiter_resolve(nil, {success = true, targetPath = targetPath, source = source.url, message = cleanupMessage}) -- 252
				end -- 252
				::__continue25:: -- 252
				sourceIndex = sourceIndex + 1 -- 147
			end -- 147
		end -- 147
		return ____awaiter_resolve(nil, {success = false, message = lastMessage}) -- 147
	end) -- 147
end -- 122
local function withProjectOperation(resource, operation) -- 258
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 258
		local path = ____exports.getResourceInstallPath(resource.id) -- 259
		if activeProjects:has(path) then -- 259
			return ____awaiter_resolve(nil, {success = false, message = "project operation already in progress"}) -- 259
		end -- 259
		activeProjects:add(path) -- 261
		local ____hasReturned, ____returnValue -- 261
		local ____try = __TS__AsyncAwaiter(function() -- 261
			____hasReturned = true -- 263
			____returnValue = __TS__Await(operation()) -- 263
			return -- 263
		end) -- 263
		____try = ____try.finally( -- 263
			____try, -- 263
			function() -- 263
				return __TS__AsyncAwaiter(function() -- 263
					activeProjects:delete(path) -- 265
				end) -- 265
			end -- 265
		) -- 265
		__TS__Await(____try) -- 262
		if ____hasReturned then -- 262
			return ____awaiter_resolve(nil, ____returnValue) -- 262
		end -- 262
	end) -- 262
end -- 258
____exports.installResource = function(resource, version, options) return withProjectOperation( -- 269
	resource, -- 270
	function() return installResourceInternal(resource, version, options) end -- 270
) end -- 270
____exports.syncResource = function(resource, version, options, force) -- 272
	if force == nil then -- 272
		force = false -- 272
	end -- 272
	return withProjectOperation( -- 273
		resource, -- 273
		function() -- 273
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 273
				local targetPath = ____exports.getResourceInstallPath(resource.id) -- 274
				if not ____exports.getInstalledCatalogResource(targetPath, {resource}) then -- 274
					return ____awaiter_resolve(nil, {success = false, message = "project has no matching Catalog installation state"}) -- 274
				end -- 274
				if resource.status ~= "active" and resource.status ~= "deprecated" then -- 274
					return ____awaiter_resolve(nil, {success = false, message = ("resource status " .. resource.status) .. " cannot be synchronized"}) -- 274
				end -- 274
				if force then -- 274
					return ____awaiter_resolve( -- 274
						nil, -- 274
						installResourceInternal(resource, version, options, true) -- 281
					) -- 281
				end -- 281
				local remotes = __TS__Await(runGit(targetPath, "remote -v", {isCanceled = options.isCanceled})) -- 282
				if not remotes.success then -- 282
					return ____awaiter_resolve( -- 282
						nil, -- 282
						__TS__ObjectAssign({}, remotes, {forceable = not remotes.canceled}) -- 283
					) -- 283
				end -- 283
				local ____opt_23 = remotes.status -- 283
				local ____opt_21 = ____opt_23 and ____opt_23.data -- 283
				local ____opt_15 = ____opt_21 and ____opt_21.remotes -- 283
				if ____opt_15 ~= nil then -- 283
					local ____opt_18 = remotes.status -- 283
					local ____opt_16 = ____opt_18 and ____opt_18.data -- 283
					____opt_15 = __TS__ArrayFind( -- 283
						____opt_16 and ____opt_16.remotes, -- 284
						function(____, remote) return remote.name == "origin" end -- 285
					) -- 285
				end -- 285
				local origin = ____opt_15 -- 284
				local lastMessage = "no resource source is available" -- 286
				for ____, source in ipairs(version.sources) do -- 287
					do -- 287
						local ____this_26 -- 287
						____this_26 = options -- 288
						local ____opt_25 = ____this_26.isCanceled -- 288
						if ____opt_25 and ____opt_25(____this_26) then -- 288
							return ____awaiter_resolve(nil, {success = false, message = "synchronization canceled", canceled = true}) -- 288
						end -- 288
						emitProgress(options, 0.05, "Pulling from Catalog repository", source.url) -- 289
						local configured = __TS__Await(runGit( -- 290
							targetPath, -- 290
							(("remote " .. (origin and "set-url" or "add")) .. " origin ") .. quoteGitArgument(source.url) -- 290
						)) -- 290
						if not configured.success then -- 290
							return ____awaiter_resolve(nil, {success = false, message = configured.message, forceable = true}) -- 290
						end -- 290
						local pulled = __TS__Await(runGit( -- 293
							targetPath, -- 293
							"pull origin", -- 293
							{ -- 293
								timeout = 1800, -- 294
								isCanceled = options.isCanceled, -- 294
								onStatus = function(____, status) return emitProgress( -- 295
									options, -- 295
									math.max(0.05, status.progress * 0.85), -- 295
									status.message or "Pulling project", -- 296
									source.url, -- 296
									status.transferredBytes -- 296
								) end -- 296
							} -- 296
						)) -- 296
						if not pulled.success then -- 296
							__TS__Await(runGit( -- 299
								targetPath, -- 299
								origin and "remote set-url origin " .. quoteGitArgument(origin.urls[1]) or "remote remove origin" -- 299
							)) -- 299
							lastMessage = pulled.message or "Git pull failed" -- 301
							if pulled.canceled then -- 301
								return ____awaiter_resolve(nil, {success = false, message = lastMessage, canceled = true}) -- 301
							end -- 301
							goto __continue51 -- 303
						end -- 303
						local verified = __TS__Await(runGit(targetPath, "verify-resource")) -- 305
						local ____opt_29 = verified.status -- 305
						local ____opt_27 = ____opt_29 and ____opt_29.data -- 305
						local commit = ____opt_27 and ____opt_27.commit -- 306
						if not verified.success or type(commit) ~= "string" then -- 306
							return ____awaiter_resolve(nil, {success = false, message = verified.message or "resource verification failed", forceable = true}) -- 306
						end -- 306
						local metadataError = installMetadata( -- 310
							resource, -- 310
							version, -- 310
							commit, -- 310
							options.catalogCommit, -- 310
							source.url, -- 310
							targetPath -- 310
						) -- 310
						if metadataError then -- 310
							return ____awaiter_resolve(nil, {success = false, message = metadataError, forceable = true}) -- 310
						end -- 310
						Content:clearPathCache() -- 312
						Director.postNode:emit("UpdateEntries") -- 313
						emitProgress(options, 1, "Synchronized", source.url) -- 314
						return ____awaiter_resolve(nil, {success = true, targetPath = targetPath, source = source.url}) -- 314
					end -- 314
					::__continue51:: -- 314
				end -- 314
				return ____awaiter_resolve(nil, {success = false, message = lastMessage, forceable = true}) -- 314
			end) -- 314
		end -- 273
	) -- 273
end -- 272
return ____exports -- 272