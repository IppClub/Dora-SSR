-- [ts]: UpdateSync.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local HttpClient = ____Dora.HttpClient -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
local thread = ____Dora.thread -- 2
local ____Git = require("Tools.ResourceDownloader.Git") -- 3
local gitHeadFromStatus = ____Git.gitHeadFromStatus -- 3
local quoteGitArgument = ____Git.quoteGitArgument -- 3
local runGit = ____Git.runGit -- 3
local ____Manifest = require("Tools.SelfUpdater.Manifest") -- 4
local loadUpdateManifest = ____Manifest.loadUpdateManifest -- 5
local updatePlatformsForVersion = ____Manifest.updatePlatformsForVersion -- 6
local updatePackageFilename = ____Manifest.updatePackageFilename -- 7
local ATOMGIT_RELEASES_REMOTE = "https://gitcode.com/ippclub/Dora-Releases.git" -- 13
local function cacheRoot() -- 75
	return Path(Content.appPath, ".cache", "self-updater") -- 75
end -- 75
local function repoPath() -- 76
	return Path( -- 76
		cacheRoot(), -- 76
		"repo" -- 76
	) -- 76
end -- 76
local function statePath() -- 77
	return Path( -- 77
		cacheRoot(), -- 77
		"state.json" -- 77
	) -- 77
end -- 77
local function emit(options, progress, message, source) -- 79
	if options.onProgress then -- 79
		options:onProgress({progress = progress, message = message, source = source}) -- 85
	end -- 85
end -- 79
local function localeIsChinese(locale) -- 88
	return (string.match(locale, "^zh")) ~= nil -- 88
end -- 88
____exports.updateSourcesForLocale = function(locale) return localeIsChinese(locale) and ({"AtomGit", "GitHub"}) or ({"GitHub", "AtomGit"}) end -- 90
local function readState() -- 94
	if not Content:exist(statePath()) then -- 94
		return nil -- 95
	end -- 95
	local decoded, err = json.decode(Content:load(statePath())) -- 96
	if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 96
		return nil -- 97
	end -- 97
	local state = decoded -- 98
	if state.schemaVersion ~= 1 or type(state.commit) ~= "string" or type(state.source) ~= "string" or type(state.signer) ~= "string" or type(state.verifiedAt) ~= "string" or type(state.checkedAt) ~= "number" then -- 98
		return nil -- 105
	end -- 105
	return state -- 107
end -- 94
local function writeState(state) -- 110
	local text = json.encode(state) -- 111
	return text ~= nil and Content:save( -- 112
		statePath(), -- 112
		text -- 112
	) -- 112
end -- 110
local function snapshotFrom(path, state) -- 115
	local result = loadUpdateManifest(path) -- 116
	if not result.manifest then -- 116
		return {success = false, message = result.message or "invalid update manifest"} -- 117
	end -- 117
	return {success = true, snapshot = { -- 118
		source = "AtomGit", -- 121
		manifest = result.manifest, -- 122
		commit = state.commit, -- 123
		remote = state.source, -- 124
		signer = state.signer, -- 125
		verifiedAt = state.verifiedAt -- 126
	}} -- 126
end -- 115
____exports.loadCachedUpdateManifest = function() -- 131
	local state = readState() -- 132
	if not state or not Content:isdir(repoPath()) then -- 132
		return {success = false, message = "no verified update metadata cache is available"} -- 134
	end -- 134
	local result = snapshotFrom( -- 136
		repoPath(), -- 136
		state -- 136
	) -- 136
	if result.success then -- 136
		result.usedCache = true -- 137
	end -- 137
	return result -- 138
end -- 131
____exports.syncUpdateManifest = function(options) -- 141
	if options == nil then -- 141
		options = {} -- 142
	end -- 142
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 142
		local existingState = readState() -- 144
		local cached = ____exports.loadCachedUpdateManifest() -- 145
		local root = cacheRoot() -- 146
		if not Content:mkdir(root) and not Content:isdir(root) then -- 146
			return ____awaiter_resolve(nil, cached.success and cached or ({success = false, message = "failed to create update metadata cache"})) -- 146
		end -- 146
		local candidateName = "candidate" -- 150
		local candidatePath = Path(root, candidateName) -- 151
		local lastMessage = "AtomGit update metadata is unavailable" -- 152
		for ____, remote in ipairs({{source = "AtomGit", url = ATOMGIT_RELEASES_REMOTE}}) do -- 153
			do -- 153
				if options.isCanceled and options:isCanceled() then -- 153
					return ____awaiter_resolve(nil, {success = false, message = "update check canceled"}) -- 153
				end -- 153
				if Content:exist(candidatePath) then -- 153
					Content:remove(candidatePath) -- 157
				end -- 157
				emit(options, 0.02, "Connecting to update metadata", remote.source) -- 158
				local clone = __TS__Await(runGit( -- 159
					root, -- 160
					((("clone " .. quoteGitArgument(remote.url)) .. " ") .. quoteGitArgument(candidateName)) .. " --branch main",
					{ -- 162
						timeout = 180, -- 163
						isCanceled = options.isCanceled, -- 164
						onStatus = function(____, status) return emit( -- 165
							options, -- 166
							math.max( -- 167
								0.03, -- 167
								math.min(0.65, status.progress * 0.65) -- 167
							), -- 167
							status.message or "Receiving update metadata", -- 168
							remote.source -- 169
						) end -- 169
					} -- 169
				)) -- 169
				if not clone.success then -- 169
					Content:remove(candidatePath) -- 174
					lastMessage = clone.message or "failed to clone update metadata" -- 175
					goto __continue21 -- 176
				end -- 176
				local commit = gitHeadFromStatus(clone.status) -- 178
				if not commit then -- 178
					Content:remove(candidatePath) -- 180
					lastMessage = "update metadata clone did not return a commit" -- 181
					goto __continue21 -- 182
				end -- 182
				emit(options, 0.7, "Verifying update signature and history", remote.source) -- 184
				local command = "verify-update " .. quoteGitArgument(commit) -- 185
				if existingState then -- 185
					command = command .. " " .. quoteGitArgument(existingState.commit) -- 186
				end -- 186
				local verified = __TS__Await(runGit(candidatePath, command, {timeout = 60, isCanceled = options.isCanceled})) -- 187
				if not verified.success then -- 187
					Content:remove(candidatePath) -- 192
					lastMessage = verified.message or "update metadata signature verification failed" -- 193
					goto __continue21 -- 194
				end -- 194
				local ____opt_2 = verified.status -- 194
				local ____opt_0 = ____opt_2 and ____opt_2.data -- 194
				local signer = ____opt_0 and ____opt_0.signer -- 196
				if type(signer) ~= "string" or signer == "" then -- 196
					Content:remove(candidatePath) -- 198
					lastMessage = "update metadata verification did not return a signer" -- 199
					goto __continue21 -- 200
				end -- 200
				emit(options, 0.8, "Validating update manifest", remote.source) -- 202
				local state = { -- 203
					schemaVersion = 1, -- 204
					commit = commit, -- 205
					source = remote.url, -- 206
					signer = signer, -- 207
					verifiedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 208
					checkedAt = os.time() -- 209
				} -- 209
				local candidate = snapshotFrom(candidatePath, state) -- 211
				if not candidate.success then -- 211
					Content:remove(candidatePath) -- 213
					lastMessage = candidate.message or "update manifest validation failed" -- 214
					goto __continue21 -- 215
				end -- 215
				local backupPath = Path(root, "repo-backup") -- 217
				if Content:exist(backupPath) then -- 217
					Content:remove(backupPath) -- 218
				end -- 218
				if Content:exist(repoPath()) and not Content:move( -- 218
					repoPath(), -- 219
					backupPath -- 219
				) then -- 219
					Content:remove(candidatePath) -- 220
					lastMessage = "failed to prepare update metadata replacement" -- 221
					goto __continue21 -- 222
				end -- 222
				if not Content:move( -- 222
					candidatePath, -- 224
					repoPath() -- 224
				) then -- 224
					if Content:exist(backupPath) then -- 224
						Content:move( -- 225
							backupPath, -- 225
							repoPath() -- 225
						) -- 225
					end -- 225
					lastMessage = "failed to activate verified update metadata" -- 226
					goto __continue21 -- 227
				end -- 227
				if not writeState(state) then -- 227
					Content:remove(repoPath()) -- 230
					if Content:exist(backupPath) then -- 230
						Content:move( -- 231
							backupPath, -- 231
							repoPath() -- 231
						) -- 231
					end -- 231
					lastMessage = "failed to save update metadata state" -- 232
					goto __continue21 -- 233
				end -- 233
				if Content:exist(backupPath) then -- 233
					Content:remove(backupPath) -- 235
				end -- 235
				emit(options, 1, "Update metadata is ready", remote.source) -- 236
				return ____awaiter_resolve( -- 236
					nil, -- 236
					snapshotFrom( -- 237
						repoPath(), -- 237
						state -- 237
					) -- 237
				) -- 237
			end -- 237
			::__continue21:: -- 237
		end -- 237
		if cached.success then -- 237
			cached.usedCache = true -- 240
			cached.message = lastMessage -- 241
			return ____awaiter_resolve(nil, cached) -- 241
		end -- 241
		return ____awaiter_resolve(nil, {success = false, message = lastMessage}) -- 241
	end) -- 241
end -- 141
____exports.checkGitHubRelease = function(options) -- 260
	if options == nil then -- 260
		options = {} -- 261
	end -- 261
	return __TS__New( -- 262
		__TS__Promise, -- 262
		function(____, resolve) -- 262
			thread(function() -- 263
				if options.isCanceled and options:isCanceled() then -- 263
					resolve(nil, {success = false, message = "update check canceled"}) -- 265
					return -- 266
				end -- 266
				emit(options, 0.05, "Checking GitHub Releases", "GitHub") -- 268
				local response = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 269
				if not response then -- 269
					resolve(nil, {success = false, message = "GitHub Release API is unavailable"}) -- 271
					return -- 272
				end -- 272
				local decoded, err = json.decode(response) -- 274
				if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 274
					resolve(nil, {success = false, message = "GitHub returned invalid release metadata"}) -- 276
					return -- 277
				end -- 277
				local release = decoded -- 279
				if type(release.tag_name) ~= "string" or (string.match(release.tag_name, "^v%d+%.%d+%.%d+$")) == nil or type(release.published_at) ~= "string" or not __TS__ArrayIsArray(release.assets) then -- 279
					resolve(nil, {success = false, message = "GitHub latest release metadata is incomplete"}) -- 284
					return -- 285
				end -- 285
				local packages = {} -- 287
				for ____, platform in ipairs(updatePlatformsForVersion(release.tag_name)) do -- 288
					local file = updatePackageFilename(release.tag_name, platform) -- 289
					local matched -- 290
					for ____, value in ipairs(release.assets) do -- 291
						if value.name == file then -- 291
							matched = value -- 293
							break -- 294
						end -- 294
					end -- 294
					local github = (("https://github.com/IppClub/Dora-SSR/releases/download/" .. release.tag_name) .. "/") .. file -- 297
					if not matched or type(matched.size) ~= "number" or matched.size < 1 or type(matched.digest) ~= "string" or #matched.digest ~= 71 or (string.find(matched.digest, "sha256:", 1, true)) ~= 1 or (string.match( -- 297
						string.sub(matched.digest, 8), -- 304
						"^[0-9a-f]+$" -- 304
					)) == nil or matched.browser_download_url ~= github then -- 304
						resolve(nil, {success = false, message = "GitHub asset metadata is invalid: " .. file}) -- 306
						return -- 307
					end -- 307
					packages[platform] = { -- 309
						file = file, -- 310
						size = matched.size, -- 311
						sha256 = string.sub(matched.digest, 8), -- 312
						github = github -- 313
					} -- 313
				end -- 313
				emit(options, 1, "GitHub release metadata is ready", "GitHub") -- 316
				resolve(nil, {success = true, snapshot = {source = "GitHub", version = release.tag_name, publishedAt = release.published_at, packages = packages}}) -- 317
			end) -- 263
		end -- 262
	) -- 262
end -- 260
local function verifyPackage(root, item, options) -- 329
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 329
		return ____awaiter_resolve( -- 329
			nil, -- 329
			runGit( -- 333
				root, -- 334
				(((("verify-update-package " .. quoteGitArgument(item.file)) .. " ") .. quoteGitArgument(item.sha256)) .. " ") .. tostring(item.size), -- 334
				{timeout = 300, isCanceled = options.isCanceled} -- 336
			) -- 336
		) -- 336
	end) -- 336
end -- 329
local function prepareFromAtomGit(item, options) -- 339
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 339
		local root = Path(Content.writablePath, ".download") -- 343
		local candidateName = ("dora-update-" .. tostring(os.time())) .. "-atomgit" -- 344
		local candidatePath = Path(root, candidateName) -- 345
		if Content:exist(candidatePath) then -- 345
			Content:remove(candidatePath) -- 346
		end -- 346
		emit(options, 0.02, "Connecting to AtomGit LFS", "AtomGit") -- 347
		local clone = __TS__Await(runGit( -- 348
			root, -- 349
			((((("clone " .. quoteGitArgument(ATOMGIT_RELEASES_REMOTE)) .. " ") .. quoteGitArgument(candidateName)) .. " --branch ") .. quoteGitArgument(item.ref)) .. " --depth 1",
			{ -- 351
				timeout = 1800, -- 352
				isCanceled = options.isCanceled, -- 353
				onStatus = function(____, status) return emit( -- 354
					options, -- 355
					math.max( -- 356
						0.03, -- 356
						math.min(0.85, status.progress * 0.85) -- 356
					), -- 356
					status.message or "Downloading update from AtomGit LFS", -- 357
					"AtomGit" -- 358
				) end -- 358
			} -- 358
		)) -- 358
		if not clone.success then -- 358
			Content:remove(candidatePath) -- 363
			return ____awaiter_resolve(nil, nil) -- 363
		end -- 363
		local commit = gitHeadFromStatus(clone.status) -- 366
		if commit ~= item.commit then -- 366
			Content:remove(candidatePath) -- 368
			return ____awaiter_resolve(nil, nil) -- 368
		end -- 368
		local signature = __TS__Await(runGit( -- 371
			candidatePath, -- 371
			"verify-update " .. quoteGitArgument(commit), -- 371
			{timeout = 60, isCanceled = options.isCanceled} -- 371
		)) -- 371
		if not signature.success then -- 371
			Content:remove(candidatePath) -- 376
			return ____awaiter_resolve(nil, nil) -- 376
		end -- 376
		emit(options, 0.9, "Verifying update package", "AtomGit") -- 379
		local packageResult = __TS__Await(verifyPackage(candidatePath, item, options)) -- 380
		if not packageResult.success then -- 380
			Content:remove(candidatePath) -- 382
			return ____awaiter_resolve(nil, nil) -- 382
		end -- 382
		return ____awaiter_resolve( -- 382
			nil, -- 382
			{ -- 385
				source = "AtomGit", -- 386
				file = Path(candidatePath, item.file), -- 387
				cleanupPath = candidatePath -- 388
			} -- 388
		) -- 388
	end) -- 388
end -- 339
local function downloadFromGitHub(item, options) -- 392
	return __TS__New( -- 395
		__TS__Promise, -- 395
		function(____, resolve) -- 395
			thread(function() -- 396
				local root = Path(Content.writablePath, ".download") -- 397
				local candidatePath = Path( -- 398
					root, -- 398
					("dora-update-" .. tostring(os.time())) .. "-github" -- 398
				) -- 398
				if Content:exist(candidatePath) then -- 398
					Content:remove(candidatePath) -- 399
				end -- 399
				if not Content:mkdir(candidatePath) and not Content:isdir(candidatePath) then -- 399
					resolve(nil, nil) -- 401
					return -- 402
				end -- 402
				local target = Path(candidatePath, item.file) -- 404
				emit(options, 0.02, "Connecting to GitHub Releases", "GitHub") -- 405
				local success = HttpClient:downloadAsync( -- 406
					item.github, -- 407
					target, -- 408
					300, -- 409
					function(current, total) -- 410
						emit( -- 411
							options, -- 412
							total > 0 and math.max( -- 413
								0.03, -- 413
								math.min(0.85, current / total * 0.85) -- 413
							) or 0.03, -- 413
							"Downloading update from GitHub Releases", -- 414
							"GitHub" -- 415
						) -- 415
						local ____options_isCanceled_4 -- 417
						if options.isCanceled then -- 417
							____options_isCanceled_4 = options:isCanceled() -- 417
						else -- 417
							____options_isCanceled_4 = false -- 417
						end -- 417
						return ____options_isCanceled_4 -- 417
					end -- 410
				) -- 410
				if not success then -- 410
					Content:remove(candidatePath) -- 421
					resolve(nil, nil) -- 422
					return -- 423
				end -- 423
				resolve(nil, {candidatePath, target}) -- 425
			end) -- 396
		end -- 395
	) -- 395
end -- 392
local function prepareFromGitHub(item, options) -- 429
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 429
		local download = __TS__Await(downloadFromGitHub(item, options)) -- 433
		if not download then -- 433
			return ____awaiter_resolve(nil, nil) -- 433
		end -- 433
		local candidatePath, target = table.unpack(download, 1, 2) -- 435
		emit(options, 0.9, "Verifying update package", "GitHub") -- 436
		local verified = __TS__Await(verifyPackage(candidatePath, item, options)) -- 437
		if not verified.success then -- 437
			Content:remove(candidatePath) -- 439
			return ____awaiter_resolve(nil, nil) -- 439
		end -- 439
		return ____awaiter_resolve(nil, {source = "GitHub", file = target, cleanupPath = candidatePath}) -- 439
	end) -- 439
end -- 429
____exports.prepareUpdatePackage = function(snapshot, platform, options) -- 445
	if options == nil then -- 445
		options = {} -- 448
	end -- 448
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 448
		Content:mkdir(Path(Content.writablePath, ".download")) -- 450
		if options.isCanceled and options:isCanceled() then -- 450
			return ____awaiter_resolve(nil, nil) -- 450
		end -- 450
		if snapshot.source == "AtomGit" then -- 450
			local item = snapshot.manifest.packages[platform] -- 453
			if not item then -- 453
				return ____awaiter_resolve(nil, nil) -- 453
			end -- 453
			return ____awaiter_resolve( -- 453
				nil, -- 453
				prepareFromAtomGit(item, options) -- 455
			) -- 455
		end -- 455
		local item = snapshot.packages[platform] -- 457
		if not item then -- 457
			return ____awaiter_resolve(nil, nil) -- 457
		end -- 457
		return ____awaiter_resolve( -- 457
			nil, -- 457
			prepareFromGitHub(item, options) -- 459
		) -- 459
	end) -- 459
end -- 445
return ____exports -- 445
