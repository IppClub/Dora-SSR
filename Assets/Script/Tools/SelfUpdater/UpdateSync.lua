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
local ATOMGIT_RELEASES_REMOTE = "https://gitcode.com/ippclub/Dora-Releases.git" -- 12
local function cacheRoot() -- 74
	return Path(Content.appPath, ".cache", "self-updater") -- 74
end -- 74
local function repoPath() -- 75
	return Path( -- 75
		cacheRoot(), -- 75
		"repo" -- 75
	) -- 75
end -- 75
local function statePath() -- 76
	return Path( -- 76
		cacheRoot(), -- 76
		"state.json" -- 76
	) -- 76
end -- 76
local function emit(options, progress, message, source) -- 78
	if options.onProgress then -- 78
		options:onProgress({progress = progress, message = message, source = source}) -- 84
	end -- 84
end -- 78
local function localeIsChinese(locale) -- 87
	return (string.match(locale, "^zh")) ~= nil -- 87
end -- 87
____exports.updateSourcesForLocale = function(locale) return localeIsChinese(locale) and ({"AtomGit", "GitHub"}) or ({"GitHub", "AtomGit"}) end -- 89
local function readState() -- 93
	if not Content:exist(statePath()) then -- 93
		return nil -- 94
	end -- 94
	local decoded, err = json.decode(Content:load(statePath())) -- 95
	if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 95
		return nil -- 96
	end -- 96
	local state = decoded -- 97
	if state.schemaVersion ~= 1 or type(state.commit) ~= "string" or type(state.source) ~= "string" or type(state.signer) ~= "string" or type(state.verifiedAt) ~= "string" or type(state.checkedAt) ~= "number" then -- 97
		return nil -- 104
	end -- 104
	return state -- 106
end -- 93
local function writeState(state) -- 109
	local text = json.encode(state) -- 110
	return text ~= nil and Content:save( -- 111
		statePath(), -- 111
		text -- 111
	) -- 111
end -- 109
local function snapshotFrom(path, state) -- 114
	local result = loadUpdateManifest(path) -- 115
	if not result.manifest then -- 115
		return {success = false, message = result.message or "invalid update manifest"} -- 116
	end -- 116
	return {success = true, snapshot = { -- 117
		source = "AtomGit", -- 120
		manifest = result.manifest, -- 121
		commit = state.commit, -- 122
		remote = state.source, -- 123
		signer = state.signer, -- 124
		verifiedAt = state.verifiedAt -- 125
	}} -- 125
end -- 114
____exports.loadCachedUpdateManifest = function() -- 130
	local state = readState() -- 131
	if not state or not Content:isdir(repoPath()) then -- 131
		return {success = false, message = "no verified update metadata cache is available"} -- 133
	end -- 133
	local result = snapshotFrom( -- 135
		repoPath(), -- 135
		state -- 135
	) -- 135
	if result.success then -- 135
		result.usedCache = true -- 136
	end -- 136
	return result -- 137
end -- 130
____exports.syncUpdateManifest = function(options) -- 140
	if options == nil then -- 140
		options = {} -- 141
	end -- 141
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 141
		local existingState = readState() -- 143
		local cached = ____exports.loadCachedUpdateManifest() -- 144
		local root = cacheRoot() -- 145
		if not Content:mkdir(root) and not Content:isdir(root) then -- 145
			return ____awaiter_resolve(nil, cached.success and cached or ({success = false, message = "failed to create update metadata cache"})) -- 145
		end -- 145
		local candidateName = "candidate" -- 149
		local candidatePath = Path(root, candidateName) -- 150
		local lastMessage = "AtomGit update metadata is unavailable" -- 151
		for ____, remote in ipairs({{source = "AtomGit", url = ATOMGIT_RELEASES_REMOTE}}) do -- 152
			do -- 152
				if options.isCanceled and options:isCanceled() then -- 152
					return ____awaiter_resolve(nil, {success = false, message = "update check canceled"}) -- 152
				end -- 152
				if Content:exist(candidatePath) then -- 152
					Content:remove(candidatePath) -- 156
				end -- 156
				emit(options, 0.02, "Connecting to update metadata", remote.source) -- 157
				local clone = __TS__Await(runGit( -- 158
					root, -- 159
					((("clone " .. quoteGitArgument(remote.url)) .. " ") .. quoteGitArgument(candidateName)) .. " --branch main",
					{ -- 161
						timeout = 180, -- 162
						isCanceled = options.isCanceled, -- 163
						onStatus = function(____, status) return emit( -- 164
							options, -- 165
							math.max( -- 166
								0.03, -- 166
								math.min(0.65, status.progress * 0.65) -- 166
							), -- 166
							status.message or "Receiving update metadata", -- 167
							remote.source -- 168
						) end -- 168
					} -- 168
				)) -- 168
				if not clone.success then -- 168
					Content:remove(candidatePath) -- 173
					lastMessage = clone.message or "failed to clone update metadata" -- 174
					goto __continue21 -- 175
				end -- 175
				local commit = gitHeadFromStatus(clone.status) -- 177
				if not commit then -- 177
					Content:remove(candidatePath) -- 179
					lastMessage = "update metadata clone did not return a commit" -- 180
					goto __continue21 -- 181
				end -- 181
				emit(options, 0.7, "Verifying update signature and history", remote.source) -- 183
				local command = "verify-update " .. quoteGitArgument(commit) -- 184
				if existingState then -- 184
					command = command .. " " .. quoteGitArgument(existingState.commit) -- 185
				end -- 185
				local verified = __TS__Await(runGit(candidatePath, command, {timeout = 60, isCanceled = options.isCanceled})) -- 186
				if not verified.success then -- 186
					Content:remove(candidatePath) -- 191
					lastMessage = verified.message or "update metadata signature verification failed" -- 192
					goto __continue21 -- 193
				end -- 193
				local ____opt_2 = verified.status -- 193
				local ____opt_0 = ____opt_2 and ____opt_2.data -- 193
				local signer = ____opt_0 and ____opt_0.signer -- 195
				if type(signer) ~= "string" or signer == "" then -- 195
					Content:remove(candidatePath) -- 197
					lastMessage = "update metadata verification did not return a signer" -- 198
					goto __continue21 -- 199
				end -- 199
				emit(options, 0.8, "Validating update manifest", remote.source) -- 201
				local state = { -- 202
					schemaVersion = 1, -- 203
					commit = commit, -- 204
					source = remote.url, -- 205
					signer = signer, -- 206
					verifiedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 207
					checkedAt = os.time() -- 208
				} -- 208
				local candidate = snapshotFrom(candidatePath, state) -- 210
				if not candidate.success then -- 210
					Content:remove(candidatePath) -- 212
					lastMessage = candidate.message or "update manifest validation failed" -- 213
					goto __continue21 -- 214
				end -- 214
				local backupPath = Path(root, "repo-backup") -- 216
				if Content:exist(backupPath) then -- 216
					Content:remove(backupPath) -- 217
				end -- 217
				if Content:exist(repoPath()) and not Content:move( -- 217
					repoPath(), -- 218
					backupPath -- 218
				) then -- 218
					Content:remove(candidatePath) -- 219
					lastMessage = "failed to prepare update metadata replacement" -- 220
					goto __continue21 -- 221
				end -- 221
				if not Content:move( -- 221
					candidatePath, -- 223
					repoPath() -- 223
				) then -- 223
					if Content:exist(backupPath) then -- 223
						Content:move( -- 224
							backupPath, -- 224
							repoPath() -- 224
						) -- 224
					end -- 224
					lastMessage = "failed to activate verified update metadata" -- 225
					goto __continue21 -- 226
				end -- 226
				if not writeState(state) then -- 226
					Content:remove(repoPath()) -- 229
					if Content:exist(backupPath) then -- 229
						Content:move( -- 230
							backupPath, -- 230
							repoPath() -- 230
						) -- 230
					end -- 230
					lastMessage = "failed to save update metadata state" -- 231
					goto __continue21 -- 232
				end -- 232
				if Content:exist(backupPath) then -- 232
					Content:remove(backupPath) -- 234
				end -- 234
				emit(options, 1, "Update metadata is ready", remote.source) -- 235
				return ____awaiter_resolve( -- 235
					nil, -- 235
					snapshotFrom( -- 236
						repoPath(), -- 236
						state -- 236
					) -- 236
				) -- 236
			end -- 236
			::__continue21:: -- 236
		end -- 236
		if cached.success then -- 236
			cached.usedCache = true -- 239
			cached.message = lastMessage -- 240
			return ____awaiter_resolve(nil, cached) -- 240
		end -- 240
		return ____awaiter_resolve(nil, {success = false, message = lastMessage}) -- 240
	end) -- 240
end -- 140
____exports.checkGitHubRelease = function(options) -- 259
	if options == nil then -- 259
		options = {} -- 260
	end -- 260
	return __TS__New( -- 261
		__TS__Promise, -- 261
		function(____, resolve) -- 261
			thread(function() -- 262
				if options.isCanceled and options:isCanceled() then -- 262
					resolve(nil, {success = false, message = "update check canceled"}) -- 264
					return -- 265
				end -- 265
				emit(options, 0.05, "Checking GitHub Releases", "GitHub") -- 267
				local response = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 268
				if not response then -- 268
					resolve(nil, {success = false, message = "GitHub Release API is unavailable"}) -- 270
					return -- 271
				end -- 271
				local decoded, err = json.decode(response) -- 273
				if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 273
					resolve(nil, {success = false, message = "GitHub returned invalid release metadata"}) -- 275
					return -- 276
				end -- 276
				local release = decoded -- 278
				if type(release.tag_name) ~= "string" or (string.match(release.tag_name, "^v%d+%.%d+%.%d+$")) == nil or type(release.published_at) ~= "string" or not __TS__ArrayIsArray(release.assets) then -- 278
					resolve(nil, {success = false, message = "GitHub latest release metadata is incomplete"}) -- 283
					return -- 284
				end -- 284
				local packages = {} -- 286
				for ____, platform in ipairs(updatePlatformsForVersion(release.tag_name)) do -- 287
					local file = ((("dora-ssr-" .. release.tag_name) .. "-") .. platform) .. ".zip" -- 288
					local matched -- 289
					for ____, value in ipairs(release.assets) do -- 290
						if value.name == file then -- 290
							matched = value -- 292
							break -- 293
						end -- 293
					end -- 293
					local github = (("https://github.com/IppClub/Dora-SSR/releases/download/" .. release.tag_name) .. "/") .. file -- 296
					if not matched or type(matched.size) ~= "number" or matched.size < 1 or type(matched.digest) ~= "string" or #matched.digest ~= 71 or (string.find(matched.digest, "sha256:", 1, true)) ~= 1 or (string.match( -- 296
						string.sub(matched.digest, 8), -- 303
						"^[0-9a-f]+$" -- 303
					)) == nil or matched.browser_download_url ~= github then -- 303
						resolve(nil, {success = false, message = "GitHub asset metadata is invalid: " .. file}) -- 305
						return -- 306
					end -- 306
					packages[platform] = { -- 308
						file = file, -- 309
						size = matched.size, -- 310
						sha256 = string.sub(matched.digest, 8), -- 311
						github = github -- 312
					} -- 312
				end -- 312
				emit(options, 1, "GitHub release metadata is ready", "GitHub") -- 315
				resolve(nil, {success = true, snapshot = {source = "GitHub", version = release.tag_name, publishedAt = release.published_at, packages = packages}}) -- 316
			end) -- 262
		end -- 261
	) -- 261
end -- 259
local function verifyPackage(root, item, options) -- 328
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 328
		return ____awaiter_resolve( -- 328
			nil, -- 328
			runGit( -- 332
				root, -- 333
				(((("verify-update-package " .. quoteGitArgument(item.file)) .. " ") .. quoteGitArgument(item.sha256)) .. " ") .. tostring(item.size), -- 333
				{timeout = 300, isCanceled = options.isCanceled} -- 335
			) -- 335
		) -- 335
	end) -- 335
end -- 328
local function prepareFromAtomGit(item, options) -- 338
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 338
		local root = Path(Content.writablePath, ".download") -- 342
		local candidateName = ("dora-update-" .. tostring(os.time())) .. "-atomgit" -- 343
		local candidatePath = Path(root, candidateName) -- 344
		if Content:exist(candidatePath) then -- 344
			Content:remove(candidatePath) -- 345
		end -- 345
		emit(options, 0.02, "Connecting to AtomGit LFS", "AtomGit") -- 346
		local clone = __TS__Await(runGit( -- 347
			root, -- 348
			((((("clone " .. quoteGitArgument(ATOMGIT_RELEASES_REMOTE)) .. " ") .. quoteGitArgument(candidateName)) .. " --branch ") .. quoteGitArgument(item.ref)) .. " --depth 1",
			{ -- 350
				timeout = 1800, -- 351
				isCanceled = options.isCanceled, -- 352
				onStatus = function(____, status) return emit( -- 353
					options, -- 354
					math.max( -- 355
						0.03, -- 355
						math.min(0.85, status.progress * 0.85) -- 355
					), -- 355
					status.message or "Downloading update from AtomGit LFS", -- 356
					"AtomGit" -- 357
				) end -- 357
			} -- 357
		)) -- 357
		if not clone.success then -- 357
			Content:remove(candidatePath) -- 362
			return ____awaiter_resolve(nil, nil) -- 362
		end -- 362
		local commit = gitHeadFromStatus(clone.status) -- 365
		if commit ~= item.commit then -- 365
			Content:remove(candidatePath) -- 367
			return ____awaiter_resolve(nil, nil) -- 367
		end -- 367
		local signature = __TS__Await(runGit( -- 370
			candidatePath, -- 370
			"verify-update " .. quoteGitArgument(commit), -- 370
			{timeout = 60, isCanceled = options.isCanceled} -- 370
		)) -- 370
		if not signature.success then -- 370
			Content:remove(candidatePath) -- 375
			return ____awaiter_resolve(nil, nil) -- 375
		end -- 375
		emit(options, 0.9, "Verifying update package", "AtomGit") -- 378
		local packageResult = __TS__Await(verifyPackage(candidatePath, item, options)) -- 379
		if not packageResult.success then -- 379
			Content:remove(candidatePath) -- 381
			return ____awaiter_resolve(nil, nil) -- 381
		end -- 381
		return ____awaiter_resolve( -- 381
			nil, -- 381
			{ -- 384
				source = "AtomGit", -- 385
				file = Path(candidatePath, item.file), -- 386
				cleanupPath = candidatePath -- 387
			} -- 387
		) -- 387
	end) -- 387
end -- 338
local function downloadFromGitHub(item, options) -- 391
	return __TS__New( -- 394
		__TS__Promise, -- 394
		function(____, resolve) -- 394
			thread(function() -- 395
				local root = Path(Content.writablePath, ".download") -- 396
				local candidatePath = Path( -- 397
					root, -- 397
					("dora-update-" .. tostring(os.time())) .. "-github" -- 397
				) -- 397
				if Content:exist(candidatePath) then -- 397
					Content:remove(candidatePath) -- 398
				end -- 398
				if not Content:mkdir(candidatePath) and not Content:isdir(candidatePath) then -- 398
					resolve(nil, nil) -- 400
					return -- 401
				end -- 401
				local target = Path(candidatePath, item.file) -- 403
				emit(options, 0.02, "Connecting to GitHub Releases", "GitHub") -- 404
				local success = HttpClient:downloadAsync( -- 405
					item.github, -- 406
					target, -- 407
					300, -- 408
					function(current, total) -- 409
						emit( -- 410
							options, -- 411
							total > 0 and math.max( -- 412
								0.03, -- 412
								math.min(0.85, current / total * 0.85) -- 412
							) or 0.03, -- 412
							"Downloading update from GitHub Releases", -- 413
							"GitHub" -- 414
						) -- 414
						local ____options_isCanceled_4 -- 416
						if options.isCanceled then -- 416
							____options_isCanceled_4 = options:isCanceled() -- 416
						else -- 416
							____options_isCanceled_4 = false -- 416
						end -- 416
						return ____options_isCanceled_4 -- 416
					end -- 409
				) -- 409
				if not success then -- 409
					Content:remove(candidatePath) -- 420
					resolve(nil, nil) -- 421
					return -- 422
				end -- 422
				resolve(nil, {candidatePath, target}) -- 424
			end) -- 395
		end -- 394
	) -- 394
end -- 391
local function prepareFromGitHub(item, options) -- 428
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 428
		local download = __TS__Await(downloadFromGitHub(item, options)) -- 432
		if not download then -- 432
			return ____awaiter_resolve(nil, nil) -- 432
		end -- 432
		local candidatePath, target = table.unpack(download, 1, 2) -- 434
		emit(options, 0.9, "Verifying update package", "GitHub") -- 435
		local verified = __TS__Await(verifyPackage(candidatePath, item, options)) -- 436
		if not verified.success then -- 436
			Content:remove(candidatePath) -- 438
			return ____awaiter_resolve(nil, nil) -- 438
		end -- 438
		return ____awaiter_resolve(nil, {source = "GitHub", file = target, cleanupPath = candidatePath}) -- 438
	end) -- 438
end -- 428
____exports.prepareUpdatePackage = function(snapshot, platform, options) -- 444
	if options == nil then -- 444
		options = {} -- 447
	end -- 447
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 447
		Content:mkdir(Path(Content.writablePath, ".download")) -- 449
		if options.isCanceled and options:isCanceled() then -- 449
			return ____awaiter_resolve(nil, nil) -- 449
		end -- 449
		if snapshot.source == "AtomGit" then -- 449
			local item = snapshot.manifest.packages[platform] -- 452
			if not item then -- 452
				return ____awaiter_resolve(nil, nil) -- 452
			end -- 452
			return ____awaiter_resolve( -- 452
				nil, -- 452
				prepareFromAtomGit(item, options) -- 454
			) -- 454
		end -- 454
		local item = snapshot.packages[platform] -- 456
		if not item then -- 456
			return ____awaiter_resolve(nil, nil) -- 456
		end -- 456
		return ____awaiter_resolve( -- 456
			nil, -- 456
			prepareFromGitHub(item, options) -- 458
		) -- 458
	end) -- 458
end -- 444
return ____exports -- 444