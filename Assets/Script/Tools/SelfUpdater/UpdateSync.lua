-- [ts]: UpdateSync.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
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
local function prepareFromAtomGit(ref, resolvePackage, options) -- 339
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 339
		local root = Path(Content.writablePath, ".download") -- 344
		local candidateName = ((("dora-update-" .. tostring(os.time())) .. "-") .. tostring(App.rand)) .. "-atomgit" -- 345
		local candidatePath = Path(root, candidateName) -- 346
		if Content:exist(candidatePath) then -- 346
			Content:remove(candidatePath) -- 347
		end -- 347
		emit(options, 0.02, "Connecting to AtomGit LFS", "AtomGit") -- 348
		local clone = __TS__Await(runGit( -- 349
			root, -- 350
			((((("clone " .. quoteGitArgument(ATOMGIT_RELEASES_REMOTE)) .. " ") .. quoteGitArgument(candidateName)) .. " --branch ") .. quoteGitArgument(ref)) .. " --depth 1",
			{ -- 352
				timeout = 1800, -- 353
				isCanceled = options.isCanceled, -- 354
				onStatus = function(____, status) return emit( -- 355
					options, -- 356
					math.max( -- 357
						0.03, -- 357
						math.min(0.85, status.progress * 0.85) -- 357
					), -- 357
					status.message or "Downloading update from AtomGit LFS", -- 358
					"AtomGit" -- 359
				) end -- 359
			} -- 359
		)) -- 359
		if not clone.success then -- 359
			Content:remove(candidatePath) -- 364
			return ____awaiter_resolve(nil, nil) -- 364
		end -- 364
		local commit = gitHeadFromStatus(clone.status) -- 367
		if not commit then -- 367
			Content:remove(candidatePath) -- 369
			return ____awaiter_resolve(nil, nil) -- 369
		end -- 369
		local signature = __TS__Await(runGit( -- 372
			candidatePath, -- 372
			"verify-update " .. quoteGitArgument(commit), -- 372
			{timeout = 60, isCanceled = options.isCanceled} -- 372
		)) -- 372
		if not signature.success then -- 372
			Content:remove(candidatePath) -- 377
			return ____awaiter_resolve(nil, nil) -- 377
		end -- 377
		local item = resolvePackage(candidatePath, commit) -- 380
		if not item then -- 380
			Content:remove(candidatePath) -- 382
			return ____awaiter_resolve(nil, nil) -- 382
		end -- 382
		emit(options, 0.9, "Verifying update package", "AtomGit") -- 385
		local packageResult = __TS__Await(verifyPackage(candidatePath, item, options)) -- 386
		if not packageResult.success then -- 386
			Content:remove(candidatePath) -- 388
			return ____awaiter_resolve(nil, nil) -- 388
		end -- 388
		return ____awaiter_resolve( -- 388
			nil, -- 388
			{ -- 391
				source = "AtomGit", -- 392
				file = Path(candidatePath, item.file), -- 393
				cleanupPath = candidatePath -- 394
			} -- 394
		) -- 394
	end) -- 394
end -- 339
local function downloadFromGitHub(item, options) -- 398
	return __TS__New( -- 401
		__TS__Promise, -- 401
		function(____, resolve) -- 401
			thread(function() -- 402
				local root = Path(Content.writablePath, ".download") -- 403
				local candidatePath = Path( -- 404
					root, -- 404
					((("dora-update-" .. tostring(os.time())) .. "-") .. tostring(App.rand)) .. "-github" -- 404
				) -- 404
				if Content:exist(candidatePath) then -- 404
					Content:remove(candidatePath) -- 405
				end -- 405
				if not Content:mkdir(candidatePath) and not Content:isdir(candidatePath) then -- 405
					resolve(nil, nil) -- 407
					return -- 408
				end -- 408
				local target = Path(candidatePath, item.file) -- 410
				emit(options, 0.02, "Connecting to GitHub Releases", "GitHub") -- 411
				local success = HttpClient:downloadAsync( -- 412
					item.github, -- 413
					target, -- 414
					300, -- 415
					function(current, total) -- 416
						emit( -- 417
							options, -- 418
							total > 0 and math.max( -- 419
								0.03, -- 419
								math.min(0.85, current / total * 0.85) -- 419
							) or 0.03, -- 419
							"Downloading update from GitHub Releases", -- 420
							"GitHub" -- 421
						) -- 421
						local ____options_isCanceled_4 -- 423
						if options.isCanceled then -- 423
							____options_isCanceled_4 = options:isCanceled() -- 423
						else -- 423
							____options_isCanceled_4 = false -- 423
						end -- 423
						return ____options_isCanceled_4 -- 423
					end -- 416
				) -- 416
				if not success then -- 416
					Content:remove(candidatePath) -- 427
					resolve(nil, nil) -- 428
					return -- 429
				end -- 429
				resolve(nil, {candidatePath, target}) -- 431
			end) -- 402
		end -- 401
	) -- 401
end -- 398
local function prepareFromGitHub(item, options) -- 435
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 435
		local download = __TS__Await(downloadFromGitHub(item, options)) -- 439
		if not download then -- 439
			return ____awaiter_resolve(nil, nil) -- 439
		end -- 439
		local candidatePath, target = table.unpack(download, 1, 2) -- 441
		emit(options, 0.9, "Verifying update package", "GitHub") -- 442
		local verified = __TS__Await(verifyPackage(candidatePath, item, options)) -- 443
		if not verified.success then -- 443
			Content:remove(candidatePath) -- 445
			return ____awaiter_resolve(nil, nil) -- 445
		end -- 445
		return ____awaiter_resolve(nil, {source = "GitHub", file = target, cleanupPath = candidatePath}) -- 445
	end) -- 445
end -- 435
____exports.prepareUpdatePackage = function(snapshot, platform, options) -- 451
	if options == nil then -- 451
		options = {} -- 454
	end -- 454
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 454
		Content:mkdir(Path(Content.writablePath, ".download")) -- 456
		if options.isCanceled and options:isCanceled() then -- 456
			return ____awaiter_resolve(nil, nil) -- 456
		end -- 456
		if snapshot.source == "AtomGit" then -- 456
			local item = snapshot.manifest.packages[platform] -- 459
			if not item then -- 459
				return ____awaiter_resolve(nil, nil) -- 459
			end -- 459
			return ____awaiter_resolve( -- 459
				nil, -- 459
				prepareFromAtomGit( -- 461
					item.ref, -- 461
					function(_path, commit) return commit == item.commit and item or nil end, -- 461
					options -- 461
				) -- 461
			) -- 461
		end -- 461
		local item = snapshot.packages[platform] -- 463
		if not item then -- 463
			return ____awaiter_resolve(nil, nil) -- 463
		end -- 463
		return ____awaiter_resolve( -- 463
			nil, -- 463
			prepareFromGitHub(item, options) -- 465
		) -- 465
	end) -- 465
end -- 451
--- Resolve an exact build even when the stable channel has already advanced.
____exports.preparePinnedUpdatePackage = function(version, revision, platform, options) -- 469
	if options == nil then -- 469
		options = {} -- 473
	end -- 473
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 473
		Content:mkdir(Path(Content.writablePath, ".download")) -- 475
		local file = updatePackageFilename(version, platform) -- 476
		local cached = ____exports.loadCachedUpdateManifest().snapshot -- 477
		local ____temp_7 -- 478
		if (cached and cached.source) == "AtomGit" and cached.manifest.version == version and cached.manifest.revision == revision then -- 478
			____temp_7 = cached.manifest.packages[platform] -- 479
		else -- 479
			____temp_7 = nil -- 479
		end -- 479
		local item = ____temp_7 -- 478
		local preferGitHub = item ~= nil and not localeIsChinese(App.locale) -- 480
		if item and preferGitHub then -- 480
			local prepared = __TS__Await(prepareFromGitHub(item, options)) -- 482
			if prepared then -- 482
				return ____awaiter_resolve(nil, prepared) -- 482
			end -- 482
		end -- 482
		local ref = (((("refs/tags/" .. version) .. "-") .. tostring(revision)) .. "-") .. platform -- 485
		local prepared = __TS__Await(prepareFromAtomGit( -- 486
			ref, -- 486
			function(path, commit) -- 486
				if item and item.commit ~= commit then -- 486
					return nil -- 487
				end -- 487
				local metadata = Path(path, "package.json") -- 488
				local text = Content:exist(metadata) and Content:read(metadata, 0, 4097) or nil -- 489
				if not text or #text > 4096 then -- 489
					return nil -- 490
				end -- 490
				local data, ____error = json.decode(text) -- 491
				if ____error ~= nil or type(data) ~= "table" or data == nil then -- 491
					return nil -- 492
				end -- 492
				local pkg = data -- 493
				if pkg.schemaVersion ~= 1 or pkg.platform ~= platform or pkg.version ~= version or pkg.revision ~= revision or pkg.file ~= file or type(pkg.size) ~= "number" or pkg.size < 1 or pkg.size > 2 * 1024 * 1024 * 1024 or math.floor(pkg.size) ~= pkg.size or type(pkg.sha256) ~= "string" or #pkg.sha256 ~= 64 or (string.match(pkg.sha256, "^[0-9a-f]+$")) == nil then -- 493
					return nil -- 497
				end -- 497
				if item and (item.sha256 ~= pkg.sha256 or item.size ~= pkg.size) then -- 497
					return nil -- 498
				end -- 498
				return {file = file, size = pkg.size, sha256 = pkg.sha256} -- 499
			end, -- 486
			options -- 500
		)) -- 500
		local ____prepared_9 = prepared -- 501
		if ____prepared_9 == nil then -- 501
			local ____temp_8 -- 501
			if item and not preferGitHub then -- 501
				____temp_8 = __TS__Await(prepareFromGitHub(item, options)) -- 501
			else -- 501
				____temp_8 = nil -- 501
			end -- 501
			____prepared_9 = ____temp_8 -- 501
		end -- 501
		return ____awaiter_resolve(nil, ____prepared_9) -- 501
	end) -- 501
end -- 469
return ____exports -- 469