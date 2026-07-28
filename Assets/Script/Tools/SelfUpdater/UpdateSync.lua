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
local ____Git = require("Script.Tools.ResourceDownloader.Git") -- 3
local gitHeadFromStatus = ____Git.gitHeadFromStatus -- 3
local quoteGitArgument = ____Git.quoteGitArgument -- 3
local runGit = ____Git.runGit -- 3
local ____Manifest = require("Script.Tools.SelfUpdater.Manifest") -- 4
local loadUpdateManifest = ____Manifest.loadUpdateManifest -- 5
local ATOMGIT_RELEASES_REMOTE = "https://gitcode.com/ippclub/Dora-Releases.git" -- 11
local function cacheRoot() -- 73
	return Path(Content.appPath, ".cache", "self-updater") -- 73
end -- 73
local function repoPath() -- 74
	return Path( -- 74
		cacheRoot(), -- 74
		"repo" -- 74
	) -- 74
end -- 74
local function statePath() -- 75
	return Path( -- 75
		cacheRoot(), -- 75
		"state.json" -- 75
	) -- 75
end -- 75
local function emit(options, progress, message, source) -- 77
	if options.onProgress then -- 77
		options:onProgress({progress = progress, message = message, source = source}) -- 83
	end -- 83
end -- 77
local function localeIsChinese(locale) -- 86
	return (string.match(locale, "^zh")) ~= nil -- 86
end -- 86
____exports.updateSourcesForLocale = function(locale) return localeIsChinese(locale) and ({"AtomGit", "GitHub"}) or ({"GitHub", "AtomGit"}) end -- 88
local function readState() -- 92
	if not Content:exist(statePath()) then -- 92
		return nil -- 93
	end -- 93
	local decoded, err = json.decode(Content:load(statePath())) -- 94
	if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 94
		return nil -- 95
	end -- 95
	local state = decoded -- 96
	if state.schemaVersion ~= 1 or type(state.commit) ~= "string" or type(state.source) ~= "string" or type(state.signer) ~= "string" or type(state.verifiedAt) ~= "string" or type(state.checkedAt) ~= "number" then -- 96
		return nil -- 103
	end -- 103
	return state -- 105
end -- 92
local function writeState(state) -- 108
	local text = json.encode(state) -- 109
	return text ~= nil and Content:save( -- 110
		statePath(), -- 110
		text -- 110
	) -- 110
end -- 108
local function snapshotFrom(path, state) -- 113
	local result = loadUpdateManifest(path) -- 114
	if not result.manifest then -- 114
		return {success = false, message = result.message or "invalid update manifest"} -- 115
	end -- 115
	return {success = true, snapshot = { -- 116
		source = "AtomGit", -- 119
		manifest = result.manifest, -- 120
		commit = state.commit, -- 121
		remote = state.source, -- 122
		signer = state.signer, -- 123
		verifiedAt = state.verifiedAt -- 124
	}} -- 124
end -- 113
____exports.loadCachedUpdateManifest = function() -- 129
	local state = readState() -- 130
	if not state or not Content:isdir(repoPath()) then -- 130
		return {success = false, message = "no verified update metadata cache is available"} -- 132
	end -- 132
	local result = snapshotFrom( -- 134
		repoPath(), -- 134
		state -- 134
	) -- 134
	if result.success then -- 134
		result.usedCache = true -- 135
	end -- 135
	return result -- 136
end -- 129
____exports.syncUpdateManifest = function(options) -- 139
	if options == nil then -- 139
		options = {} -- 140
	end -- 140
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 140
		local existingState = readState() -- 142
		local cached = ____exports.loadCachedUpdateManifest() -- 143
		local root = cacheRoot() -- 144
		if not Content:mkdir(root) and not Content:isdir(root) then -- 144
			return ____awaiter_resolve(nil, cached.success and cached or ({success = false, message = "failed to create update metadata cache"})) -- 144
		end -- 144
		local candidateName = "candidate" -- 148
		local candidatePath = Path(root, candidateName) -- 149
		local lastMessage = "AtomGit update metadata is unavailable" -- 150
		for ____, remote in ipairs({{source = "AtomGit", url = ATOMGIT_RELEASES_REMOTE}}) do -- 151
			do -- 151
				if options.isCanceled and options:isCanceled() then -- 151
					return ____awaiter_resolve(nil, {success = false, message = "update check canceled"}) -- 151
				end -- 151
				if Content:exist(candidatePath) then -- 151
					Content:remove(candidatePath) -- 155
				end -- 155
				emit(options, 0.02, "Connecting to update metadata", remote.source) -- 156
				local clone = __TS__Await(runGit( -- 157
					root, -- 158
					((("clone " .. quoteGitArgument(remote.url)) .. " ") .. quoteGitArgument(candidateName)) .. " --branch main",
					{ -- 160
						timeout = 180, -- 161
						isCanceled = options.isCanceled, -- 162
						onStatus = function(____, status) return emit( -- 163
							options, -- 164
							math.max( -- 165
								0.03, -- 165
								math.min(0.65, status.progress * 0.65) -- 165
							), -- 165
							status.message or "Receiving update metadata", -- 166
							remote.source -- 167
						) end -- 167
					} -- 167
				)) -- 167
				if not clone.success then -- 167
					Content:remove(candidatePath) -- 172
					lastMessage = clone.message or "failed to clone update metadata" -- 173
					goto __continue21 -- 174
				end -- 174
				local commit = gitHeadFromStatus(clone.status) -- 176
				if not commit then -- 176
					Content:remove(candidatePath) -- 178
					lastMessage = "update metadata clone did not return a commit" -- 179
					goto __continue21 -- 180
				end -- 180
				emit(options, 0.7, "Verifying update signature and history", remote.source) -- 182
				local command = "verify-update " .. quoteGitArgument(commit) -- 183
				if existingState then -- 183
					command = command .. " " .. quoteGitArgument(existingState.commit) -- 184
				end -- 184
				local verified = __TS__Await(runGit(candidatePath, command, {timeout = 60, isCanceled = options.isCanceled})) -- 185
				if not verified.success then -- 185
					Content:remove(candidatePath) -- 190
					lastMessage = verified.message or "update metadata signature verification failed" -- 191
					goto __continue21 -- 192
				end -- 192
				local ____opt_2 = verified.status -- 192
				local ____opt_0 = ____opt_2 and ____opt_2.data -- 192
				local signer = ____opt_0 and ____opt_0.signer -- 194
				if type(signer) ~= "string" or signer == "" then -- 194
					Content:remove(candidatePath) -- 196
					lastMessage = "update metadata verification did not return a signer" -- 197
					goto __continue21 -- 198
				end -- 198
				emit(options, 0.8, "Validating update manifest", remote.source) -- 200
				local state = { -- 201
					schemaVersion = 1, -- 202
					commit = commit, -- 203
					source = remote.url, -- 204
					signer = signer, -- 205
					verifiedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 206
					checkedAt = os.time() -- 207
				} -- 207
				local candidate = snapshotFrom(candidatePath, state) -- 209
				if not candidate.success then -- 209
					Content:remove(candidatePath) -- 211
					lastMessage = candidate.message or "update manifest validation failed" -- 212
					goto __continue21 -- 213
				end -- 213
				local backupPath = Path(root, "repo-backup") -- 215
				if Content:exist(backupPath) then -- 215
					Content:remove(backupPath) -- 216
				end -- 216
				if Content:exist(repoPath()) and not Content:move( -- 216
					repoPath(), -- 217
					backupPath -- 217
				) then -- 217
					Content:remove(candidatePath) -- 218
					lastMessage = "failed to prepare update metadata replacement" -- 219
					goto __continue21 -- 220
				end -- 220
				if not Content:move( -- 220
					candidatePath, -- 222
					repoPath() -- 222
				) then -- 222
					if Content:exist(backupPath) then -- 222
						Content:move( -- 223
							backupPath, -- 223
							repoPath() -- 223
						) -- 223
					end -- 223
					lastMessage = "failed to activate verified update metadata" -- 224
					goto __continue21 -- 225
				end -- 225
				if not writeState(state) then -- 225
					Content:remove(repoPath()) -- 228
					if Content:exist(backupPath) then -- 228
						Content:move( -- 229
							backupPath, -- 229
							repoPath() -- 229
						) -- 229
					end -- 229
					lastMessage = "failed to save update metadata state" -- 230
					goto __continue21 -- 231
				end -- 231
				if Content:exist(backupPath) then -- 231
					Content:remove(backupPath) -- 233
				end -- 233
				emit(options, 1, "Update metadata is ready", remote.source) -- 234
				return ____awaiter_resolve( -- 234
					nil, -- 234
					snapshotFrom( -- 235
						repoPath(), -- 235
						state -- 235
					) -- 235
				) -- 235
			end -- 235
			::__continue21:: -- 235
		end -- 235
		if cached.success then -- 235
			cached.usedCache = true -- 238
			cached.message = lastMessage -- 239
			return ____awaiter_resolve(nil, cached) -- 239
		end -- 239
		return ____awaiter_resolve(nil, {success = false, message = lastMessage}) -- 239
	end) -- 239
end -- 139
____exports.checkGitHubRelease = function(options) -- 258
	if options == nil then -- 258
		options = {} -- 259
	end -- 259
	return __TS__New( -- 260
		__TS__Promise, -- 260
		function(____, resolve) -- 260
			thread(function() -- 261
				if options.isCanceled and options:isCanceled() then -- 261
					resolve(nil, {success = false, message = "update check canceled"}) -- 263
					return -- 264
				end -- 264
				emit(options, 0.05, "Checking GitHub Releases", "GitHub") -- 266
				local response = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 267
				if not response then -- 267
					resolve(nil, {success = false, message = "GitHub Release API is unavailable"}) -- 269
					return -- 270
				end -- 270
				local decoded, err = json.decode(response) -- 272
				if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 272
					resolve(nil, {success = false, message = "GitHub returned invalid release metadata"}) -- 274
					return -- 275
				end -- 275
				local release = decoded -- 277
				if type(release.tag_name) ~= "string" or (string.match(release.tag_name, "^v%d+%.%d+%.%d+$")) == nil or type(release.published_at) ~= "string" or not __TS__ArrayIsArray(release.assets) then -- 277
					resolve(nil, {success = false, message = "GitHub latest release metadata is incomplete"}) -- 282
					return -- 283
				end -- 283
				local packages = {} -- 285
				for ____, platform in ipairs({"android", "windows-x86", "macos-universal"}) do -- 286
					local file = ((("dora-ssr-" .. release.tag_name) .. "-") .. platform) .. ".zip" -- 287
					local matched -- 288
					for ____, value in ipairs(release.assets) do -- 289
						if value.name == file then -- 289
							matched = value -- 291
							break -- 292
						end -- 292
					end -- 292
					local github = (("https://github.com/IppClub/Dora-SSR/releases/download/" .. release.tag_name) .. "/") .. file -- 295
					if not matched or type(matched.size) ~= "number" or matched.size < 1 or type(matched.digest) ~= "string" or #matched.digest ~= 71 or (string.find(matched.digest, "sha256:", 1, true)) ~= 1 or (string.match( -- 295
						string.sub(matched.digest, 8), -- 302
						"^[0-9a-f]+$" -- 302
					)) == nil or matched.browser_download_url ~= github then -- 302
						resolve(nil, {success = false, message = "GitHub asset metadata is invalid: " .. file}) -- 304
						return -- 305
					end -- 305
					packages[platform] = { -- 307
						file = file, -- 308
						size = matched.size, -- 309
						sha256 = string.sub(matched.digest, 8), -- 310
						github = github -- 311
					} -- 311
				end -- 311
				emit(options, 1, "GitHub release metadata is ready", "GitHub") -- 314
				resolve(nil, {success = true, snapshot = {source = "GitHub", version = release.tag_name, publishedAt = release.published_at, packages = packages}}) -- 315
			end) -- 261
		end -- 260
	) -- 260
end -- 258
local function verifyPackage(root, item, options) -- 327
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 327
		return ____awaiter_resolve( -- 327
			nil, -- 327
			runGit( -- 331
				root, -- 332
				(((("verify-update-package " .. quoteGitArgument(item.file)) .. " ") .. quoteGitArgument(item.sha256)) .. " ") .. tostring(item.size), -- 332
				{timeout = 300, isCanceled = options.isCanceled} -- 334
			) -- 334
		) -- 334
	end) -- 334
end -- 327
local function prepareFromAtomGit(item, options) -- 337
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 337
		local root = Path(Content.writablePath, ".download") -- 341
		local candidateName = ("dora-update-" .. tostring(os.time())) .. "-atomgit" -- 342
		local candidatePath = Path(root, candidateName) -- 343
		if Content:exist(candidatePath) then -- 343
			Content:remove(candidatePath) -- 344
		end -- 344
		emit(options, 0.02, "Connecting to AtomGit LFS", "AtomGit") -- 345
		local clone = __TS__Await(runGit( -- 346
			root, -- 347
			((((("clone " .. quoteGitArgument(ATOMGIT_RELEASES_REMOTE)) .. " ") .. quoteGitArgument(candidateName)) .. " --branch ") .. quoteGitArgument(item.ref)) .. " --depth 1",
			{ -- 349
				timeout = 1800, -- 350
				isCanceled = options.isCanceled, -- 351
				onStatus = function(____, status) return emit( -- 352
					options, -- 353
					math.max( -- 354
						0.03, -- 354
						math.min(0.85, status.progress * 0.85) -- 354
					), -- 354
					status.message or "Downloading update from AtomGit LFS", -- 355
					"AtomGit" -- 356
				) end -- 356
			} -- 356
		)) -- 356
		if not clone.success then -- 356
			Content:remove(candidatePath) -- 361
			return ____awaiter_resolve(nil, nil) -- 361
		end -- 361
		local commit = gitHeadFromStatus(clone.status) -- 364
		if commit ~= item.commit then -- 364
			Content:remove(candidatePath) -- 366
			return ____awaiter_resolve(nil, nil) -- 366
		end -- 366
		local signature = __TS__Await(runGit( -- 369
			candidatePath, -- 369
			"verify-update " .. quoteGitArgument(commit), -- 369
			{timeout = 60, isCanceled = options.isCanceled} -- 369
		)) -- 369
		if not signature.success then -- 369
			Content:remove(candidatePath) -- 374
			return ____awaiter_resolve(nil, nil) -- 374
		end -- 374
		emit(options, 0.9, "Verifying update package", "AtomGit") -- 377
		local packageResult = __TS__Await(verifyPackage(candidatePath, item, options)) -- 378
		if not packageResult.success then -- 378
			Content:remove(candidatePath) -- 380
			return ____awaiter_resolve(nil, nil) -- 380
		end -- 380
		return ____awaiter_resolve( -- 380
			nil, -- 380
			{ -- 383
				source = "AtomGit", -- 384
				file = Path(candidatePath, item.file), -- 385
				cleanupPath = candidatePath -- 386
			} -- 386
		) -- 386
	end) -- 386
end -- 337
local function downloadFromGitHub(item, options) -- 390
	return __TS__New( -- 393
		__TS__Promise, -- 393
		function(____, resolve) -- 393
			thread(function() -- 394
				local root = Path(Content.writablePath, ".download") -- 395
				local candidatePath = Path( -- 396
					root, -- 396
					("dora-update-" .. tostring(os.time())) .. "-github" -- 396
				) -- 396
				if Content:exist(candidatePath) then -- 396
					Content:remove(candidatePath) -- 397
				end -- 397
				if not Content:mkdir(candidatePath) and not Content:isdir(candidatePath) then -- 397
					resolve(nil, nil) -- 399
					return -- 400
				end -- 400
				local target = Path(candidatePath, item.file) -- 402
				emit(options, 0.02, "Connecting to GitHub Releases", "GitHub") -- 403
				local success = HttpClient:downloadAsync( -- 404
					item.github, -- 405
					target, -- 406
					300, -- 407
					function(current, total) -- 408
						emit( -- 409
							options, -- 410
							total > 0 and math.max( -- 411
								0.03, -- 411
								math.min(0.85, current / total * 0.85) -- 411
							) or 0.03, -- 411
							"Downloading update from GitHub Releases", -- 412
							"GitHub" -- 413
						) -- 413
						local ____options_isCanceled_4 -- 415
						if options.isCanceled then -- 415
							____options_isCanceled_4 = options:isCanceled() -- 415
						else -- 415
							____options_isCanceled_4 = false -- 415
						end -- 415
						return ____options_isCanceled_4 -- 415
					end -- 408
				) -- 408
				if not success then -- 408
					Content:remove(candidatePath) -- 419
					resolve(nil, nil) -- 420
					return -- 421
				end -- 421
				resolve(nil, {candidatePath, target}) -- 423
			end) -- 394
		end -- 393
	) -- 393
end -- 390
local function prepareFromGitHub(item, options) -- 427
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 427
		local download = __TS__Await(downloadFromGitHub(item, options)) -- 431
		if not download then -- 431
			return ____awaiter_resolve(nil, nil) -- 431
		end -- 431
		local candidatePath, target = table.unpack(download, 1, 2) -- 433
		emit(options, 0.9, "Verifying update package", "GitHub") -- 434
		local verified = __TS__Await(verifyPackage(candidatePath, item, options)) -- 435
		if not verified.success then -- 435
			Content:remove(candidatePath) -- 437
			return ____awaiter_resolve(nil, nil) -- 437
		end -- 437
		return ____awaiter_resolve(nil, {source = "GitHub", file = target, cleanupPath = candidatePath}) -- 437
	end) -- 437
end -- 427
____exports.prepareUpdatePackage = function(snapshot, platform, options) -- 443
	if options == nil then -- 443
		options = {} -- 446
	end -- 446
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 446
		Content:mkdir(Path(Content.writablePath, ".download")) -- 448
		if options.isCanceled and options:isCanceled() then -- 448
			return ____awaiter_resolve(nil, nil) -- 448
		end -- 448
		if snapshot.source == "AtomGit" then -- 448
			local item = snapshot.manifest.packages[platform] -- 451
			return ____awaiter_resolve( -- 451
				nil, -- 451
				prepareFromAtomGit(item, options) -- 452
			) -- 452
		end -- 452
		local item = snapshot.packages[platform] -- 454
		return ____awaiter_resolve( -- 454
			nil, -- 454
			prepareFromGitHub(item, options) -- 455
		) -- 455
	end) -- 455
end -- 443
return ____exports -- 443