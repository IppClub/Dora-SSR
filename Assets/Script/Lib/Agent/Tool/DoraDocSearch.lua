-- [ts]: DoraDocSearch.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local Map = ____lualib.Map -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local ____Utils = require("Agent.Utils") -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local ____Workspace = require("Agent.Tool.Workspace") -- 4
local ensureSafeSearchGlobs = ____Workspace.ensureSafeSearchGlobs -- 5
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 6
local readFile = ____Workspace.readFile -- 7
local splitSearchPatterns = ____Workspace.splitSearchPatterns -- 8
local splitWhitespaceSearchPatterns = ____Workspace.splitWhitespaceSearchPatterns -- 9
local AGENT_DORA_DOC_PREFIX = ____Workspace.AGENT_DORA_DOC_PREFIX -- 10
local getDoraDocSearchTarget = ____Workspace.getDoraDocSearchTarget -- 11
local getDoraDocResultBaseRoot = ____Workspace.getDoraDocResultBaseRoot -- 12
local isDoraDocFileInScope = ____Workspace.isDoraDocFileInScope -- 13
local toDocRelativePath = ____Workspace.toDocRelativePath -- 14
local function mergeDoraDocSearchHitsUnique(resultsList) -- 33
	local merged = {} -- 34
	local seen = __TS__New(Set) -- 35
	local index = 0 -- 36
	local advanced = true -- 37
	while advanced do -- 37
		advanced = false -- 39
		do -- 39
			local i = 0 -- 40
			while i < #resultsList do -- 40
				do -- 40
					local list = resultsList[i + 1] -- 41
					if index >= #list then -- 41
						goto __continue5 -- 42
					end -- 42
					advanced = true -- 43
					local row = list[index + 1] -- 44
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 45
					if seen:has(key) then -- 45
						goto __continue5 -- 46
					end -- 46
					seen:add(key) -- 47
					merged[#merged + 1] = row -- 48
				end -- 48
				::__continue5:: -- 48
				i = i + 1 -- 40
			end -- 40
		end -- 40
		index = index + 1 -- 50
	end -- 50
	return merged -- 52
end -- 33
local function getDoraDocFilePriority(file, docType, programmingLanguage) -- 55
	if docType ~= "dora-api" then -- 55
		return 100 -- 56
	end -- 56
	if programmingLanguage ~= "tsx" then -- 56
		return 100 -- 57
	end -- 57
	repeat -- 57
		local ____switch11 = string.lower(Path:getFilename(file)) -- 57
		local ____cond11 = ____switch11 == "jsx.d.ts" -- 57
		if ____cond11 then -- 57
			return 0 -- 59
		end -- 59
		____cond11 = ____cond11 or ____switch11 == "dorax.d.ts" -- 59
		if ____cond11 then -- 59
			return 1 -- 60
		end -- 60
		____cond11 = ____cond11 or ____switch11 == "dora.d.ts" -- 60
		if ____cond11 then -- 60
			return 2 -- 61
		end -- 61
		do -- 61
			return 100 -- 62
		end -- 62
	until true -- 62
end -- 55
local function sortDoraDocSearchHits(hits, docType, programmingLanguage) -- 66
	local sorted = __TS__ArraySlice(hits) -- 71
	__TS__ArraySort( -- 72
		sorted, -- 72
		function(____, a, b) -- 72
			local ____temp_2 -- 73
			if docType == "godot-api" then -- 73
				local ____opt_0 = a.content -- 73
				____temp_2 = ____opt_0 and __TS__StringStartsWith(a.content, "## ") and 0 or 100 -- 73
			else -- 73
				____temp_2 = getDoraDocFilePriority(a.file, docType, programmingLanguage) -- 73
			end -- 73
			local pa = ____temp_2 -- 73
			local ____temp_5 -- 74
			if docType == "godot-api" then -- 74
				local ____opt_3 = b.content -- 74
				____temp_5 = ____opt_3 and __TS__StringStartsWith(b.content, "## ") and 0 or 100 -- 74
			else -- 74
				____temp_5 = getDoraDocFilePriority(b.file, docType, programmingLanguage) -- 74
			end -- 74
			local pb = ____temp_5 -- 74
			if pa ~= pb then -- 74
				return pa - pb -- 75
			end -- 75
			local fa = string.lower(a.file) -- 76
			local fb = string.lower(b.file) -- 77
			if fa ~= fb then -- 77
				return fa < fb and -1 or 1 -- 78
			end -- 78
			return (a.line or 0) - (b.line or 0) -- 79
		end -- 72
	) -- 72
	return sorted -- 81
end -- 66
local function findGodotSymbol(root, query, includeContent, caseSensitive) -- 86
	if __TS__StringEndsWith(query, "()") then -- 86
		query = string.sub(query, 1, -3) -- 87
	end -- 87
	local className, member = string.match(query, "^([%w_@]+)%.([%w_]+)$") -- 88
	local classOnly = string.match(query, "^([%w_@]+)$") -- 89
	local owner = className or classOnly -- 90
	if owner == nil then -- 90
		return nil -- 91
	end -- 91
	if not Content:exist(Path(root, "classes", owner .. ".md")) and not caseSensitive then -- 91
		local requested = string.lower(owner .. ".md") -- 93
		local name = __TS__ArrayFind( -- 94
			Content:getFiles(Path(root, "classes")), -- 94
			function(____, file) return string.lower(file) == requested end -- 94
		) -- 94
		if name ~= nil then -- 94
			owner = Path:getName(name) -- 95
		end -- 95
	end -- 95
	if not Content:exist(Path(root, "classes", owner .. ".md")) then -- 95
		return nil -- 97
	end -- 97
	local seen = __TS__New(Set) -- 98
	while owner ~= nil and not seen:has(owner) and seen.size < 64 do -- 98
		seen:add(owner) -- 100
		local relative = ("classes/" .. owner) .. ".md" -- 101
		local content = Content:load(Path(root, relative)) -- 102
		if content == nil then -- 102
			break -- 103
		end -- 103
		local lines = __TS__StringSplit(content, "\n") -- 104
		local heading = member == nil and "# " .. owner or (("## " .. owner) .. ".") .. member -- 105
		local index = __TS__ArrayFindIndex( -- 106
			lines, -- 106
			function(____, line) -- 106
				local ____caseSensitive_6 -- 106
				if caseSensitive then -- 106
					____caseSensitive_6 = line == heading -- 106
				else -- 106
					____caseSensitive_6 = string.lower(line) == string.lower(heading) -- 106
				end -- 106
				return ____caseSensitive_6 -- 106
			end -- 106
		) -- 106
		if index >= 0 then -- 106
			return {{ -- 107
				file = (AGENT_DORA_DOC_PREFIX .. "godot-api/") .. relative, -- 107
				line = index + 1, -- 107
				content = includeContent and table.concat( -- 108
					__TS__ArraySlice(lines, index, index + 8), -- 108
					"\n" -- 108
				) or nil -- 108
			}} -- 108
		end -- 108
		owner = string.match(content, "\nInherits: `([%w_@]+)`") -- 109
	end -- 109
	return {} -- 111
end -- 86
local function godotMatchContent(root, hit, cache, window) -- 114
	if hit.content == nil or hit.line == nil then -- 114
		return hit.content -- 115
	end -- 115
	local lines = cache:get(hit.file) -- 116
	if lines == nil then -- 116
		local relative = __TS__StringSlice(hit.file, #(AGENT_DORA_DOC_PREFIX .. "godot-api/")) -- 118
		local source = Content:load(Path(root, relative)) -- 119
		if source == nil then -- 119
			return hit.content -- 120
		end -- 120
		lines = __TS__StringSplit(source, "\n") -- 121
		cache:set(hit.file, lines) -- 121
	end -- 121
	return __TS__StringSlice( -- 123
		table.concat( -- 123
			__TS__ArraySlice(lines, hit.line - 1, hit.line + 4), -- 123
			"\n" -- 123
		), -- 123
		0, -- 123
		math.max(20, window * 2) -- 123
	) -- 123
end -- 114
function ____exports.searchDoraDoc(req) -- 126
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 126
		local pattern = __TS__StringTrim(req.pattern or "") -- 137
		if pattern == "" then -- 137
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 137
		end -- 137
		local patterns = splitSearchPatterns(pattern) -- 139
		if #patterns == 0 then -- 139
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 139
		end -- 139
		local docType = req.docType or "dora-api" -- 141
		local target = getDoraDocSearchTarget(docType, req.docLanguage, req.programmingLanguage) -- 142
		local docRoot = target.root -- 143
		local resultBaseRoot = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 144
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 144
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 144
		end -- 144
		local sourceVersion -- 148
		if docType == "godot-api" then -- 148
			local metadata = safeJsonDecode(Content:load(Path(docRoot, "manifest.json")) or "") -- 150
			if type(metadata) == "table" then -- 150
				sourceVersion = metadata.godot_version -- 151
			end -- 151
		end -- 151
		local exts = target.exts -- 153
		local dotExts = __TS__ArrayMap( -- 154
			exts, -- 154
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 154
		) -- 154
		local globs = target.globs -- 155
		local limit = math.max( -- 156
			1, -- 156
			math.floor(req.limit or 10) -- 156
		) -- 156
		return ____awaiter_resolve( -- 156
			nil, -- 156
			__TS__New( -- 158
				__TS__Promise, -- 158
				function(____, resolve) -- 158
					Director.systemScheduler:schedule(once(function() -- 159
						do -- 159
							local function ____catch(e) -- 159
								resolve( -- 248
									nil, -- 248
									{ -- 248
										success = false, -- 248
										message = tostring(e) -- 248
									} -- 248
								) -- 248
							end -- 248
							local ____try, ____hasReturned = pcall(function() -- 248
								local allHits = {} -- 161
								local godotLines = __TS__New(Map) -- 162
								do -- 162
									local p = 0 -- 163
									while p < #patterns do -- 163
										do -- 163
											local ____temp_11 -- 164
											if docType == "godot-api" and req.useRegex ~= true then -- 164
												local ____findGodotSymbol_10 = findGodotSymbol -- 165
												local ____patterns_index_9 = patterns[p + 1] -- 165
												local ____req_includeContent_7 = req.includeContent -- 165
												if ____req_includeContent_7 == nil then -- 165
													____req_includeContent_7 = true -- 165
												end -- 165
												local ____req_caseSensitive_8 = req.caseSensitive -- 165
												if ____req_caseSensitive_8 == nil then -- 165
													____req_caseSensitive_8 = false -- 165
												end -- 165
												____temp_11 = ____findGodotSymbol_10(docRoot, ____patterns_index_9, ____req_includeContent_7, ____req_caseSensitive_8) -- 165
											else -- 165
												____temp_11 = nil -- 165
											end -- 165
											local exact = ____temp_11 -- 164
											if exact ~= nil then -- 164
												allHits[#allHits + 1] = exact -- 166
												goto __continue42 -- 166
											end -- 166
											local ____Content_16 = Content -- 167
											local ____Content_searchFilesAsync_17 = Content.searchFilesAsync -- 167
											local ____array_15 = __TS__SparseArrayNew( -- 167
												docRoot, -- 168
												dotExts, -- 169
												{}, -- 170
												ensureSafeSearchGlobs(globs), -- 171
												patterns[p + 1] -- 172
											) -- 172
											local ____req_useRegex_12 = req.useRegex -- 173
											if ____req_useRegex_12 == nil then -- 173
												____req_useRegex_12 = false -- 173
											end -- 173
											__TS__SparseArrayPush(____array_15, ____req_useRegex_12) -- 173
											local ____req_caseSensitive_13 = req.caseSensitive -- 174
											if ____req_caseSensitive_13 == nil then -- 174
												____req_caseSensitive_13 = false -- 174
											end -- 174
											__TS__SparseArrayPush(____array_15, ____req_caseSensitive_13) -- 174
											local ____req_includeContent_14 = req.includeContent -- 175
											if ____req_includeContent_14 == nil then -- 175
												____req_includeContent_14 = true -- 175
											end -- 175
											__TS__SparseArrayPush(____array_15, ____req_includeContent_14, req.contentWindow or 80) -- 175
											local raw = ____Content_searchFilesAsync_17( -- 167
												____Content_16, -- 167
												__TS__SparseArraySpread(____array_15) -- 167
											) -- 167
											local hits = {} -- 178
											do -- 178
												local i = 0 -- 179
												while i < #raw do -- 179
													do -- 179
														local row = raw[i + 1] -- 180
														local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 181
														if file == "" then -- 181
															goto __continue45 -- 182
														end -- 182
														hits[#hits + 1] = { -- 183
															file = file, -- 184
															line = type(row.line) == "number" and row.line or nil, -- 185
															content = type(row.content) == "string" and row.content or nil -- 186
														} -- 186
													end -- 186
													::__continue45:: -- 186
													i = i + 1 -- 179
												end -- 179
											end -- 179
											if docType == "godot-api" then -- 179
												for ____, hit in ipairs(hits) do -- 189
													hit.content = godotMatchContent(docRoot, hit, godotLines, req.contentWindow or 80) -- 189
												end -- 189
											end -- 189
											local sorted = sortDoraDocSearchHits(hits, docType, req.programmingLanguage) -- 190
											allHits[#allHits + 1] = docType == "godot-api" and sorted or __TS__ArraySlice(sorted, 0, limit) -- 191
										end -- 191
										::__continue42:: -- 191
										p = p + 1 -- 163
									end -- 163
								end -- 163
								local hits = mergeDoraDocSearchHitsUnique(allHits) -- 193
								local fallbackPatterns -- 194
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 194
									local terms = splitWhitespaceSearchPatterns(pattern) -- 199
									if #terms > 1 then -- 199
										fallbackPatterns = terms -- 201
										local fallbackHits = {} -- 202
										do -- 202
											local p = 0 -- 203
											while p < #terms do -- 203
												local ____Content_21 = Content -- 204
												local ____Content_searchFilesAsync_22 = Content.searchFilesAsync -- 204
												local ____array_20 = __TS__SparseArrayNew( -- 204
													docRoot, -- 205
													dotExts, -- 206
													{}, -- 207
													ensureSafeSearchGlobs(globs), -- 208
													terms[p + 1], -- 209
													false -- 210
												) -- 210
												local ____req_caseSensitive_18 = req.caseSensitive -- 211
												if ____req_caseSensitive_18 == nil then -- 211
													____req_caseSensitive_18 = false -- 211
												end -- 211
												__TS__SparseArrayPush(____array_20, ____req_caseSensitive_18) -- 211
												local ____req_includeContent_19 = req.includeContent -- 212
												if ____req_includeContent_19 == nil then -- 212
													____req_includeContent_19 = true -- 212
												end -- 212
												__TS__SparseArrayPush(____array_20, ____req_includeContent_19, req.contentWindow or 80) -- 212
												local raw = ____Content_searchFilesAsync_22( -- 204
													____Content_21, -- 204
													__TS__SparseArraySpread(____array_20) -- 204
												) -- 204
												local termHits = {} -- 215
												do -- 215
													local i = 0 -- 216
													while i < #raw do -- 216
														do -- 216
															local row = raw[i + 1] -- 217
															local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 218
															if file == "" then -- 218
																goto __continue55 -- 219
															end -- 219
															termHits[#termHits + 1] = { -- 220
																file = file, -- 221
																line = type(row.line) == "number" and row.line or nil, -- 222
																content = type(row.content) == "string" and row.content or nil -- 223
															} -- 223
														end -- 223
														::__continue55:: -- 223
														i = i + 1 -- 216
													end -- 216
												end -- 216
												if docType == "godot-api" then -- 216
													for ____, hit in ipairs(termHits) do -- 226
														hit.content = godotMatchContent(docRoot, hit, godotLines, req.contentWindow or 80) -- 226
													end -- 226
												end -- 226
												local sorted = sortDoraDocSearchHits(termHits, docType, req.programmingLanguage) -- 227
												fallbackHits[#fallbackHits + 1] = docType == "godot-api" and sorted or __TS__ArraySlice(sorted, 0, limit) -- 228
												p = p + 1 -- 203
											end -- 203
										end -- 203
										hits = mergeDoraDocSearchHitsUnique(fallbackHits) -- 230
									end -- 230
								end -- 230
								resolve( -- 233
									nil, -- 233
									{ -- 233
										success = true, -- 234
										docType = docType, -- 235
										docLanguage = docType == "godot-api" and "en" or req.docLanguage, -- 236
										programmingLanguage = docType == "godot-api" and "gdscript" or req.programmingLanguage, -- 237
										exts = exts, -- 238
										results = docType == "godot-api" and __TS__ArraySlice(hits, 0, limit) or hits, -- 239
										hint = (docType == "godot-api" and "English originals from the bundled Godot source version. API documentation does not establish runtime availability. " or "") .. "Use read_file with a namespaced result to view it, or grep_files with that exact @dora-doc path to search within the document.", -- 240
										totalResults = #hits, -- 241
										truncated = docType == "godot-api" and #hits > limit, -- 242
										limit = limit, -- 243
										fallbackPatterns = fallbackPatterns, -- 244
										sourceVersion = type(sourceVersion) == "string" and sourceVersion or nil -- 245
									} -- 245
								) -- 245
							end) -- 245
							if not ____try then -- 245
								____catch(____hasReturned) -- 245
							end -- 245
						end -- 245
					end)) -- 159
				end -- 158
			) -- 158
		) -- 158
	end) -- 158
end -- 126
function ____exports.searchDoraDocHttp(req, callback) -- 254
	local ____self_23 = ____exports.searchDoraDoc(req) -- 254
	____self_23["then"]( -- 254
		____self_23, -- 254
		function(____, result) return callback(result) end -- 265
	) -- 265
end -- 254
function ____exports.readDoraDoc(req) -- 268
	local requestedFile = table.concat( -- 274
		__TS__StringSplit(req.file or "", "\\"), -- 274
		"/" -- 274
	) -- 274
	local file = requestedFile -- 275
	local namespacedType = nil -- 276
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 276
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 278
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 278
			namespacedType = "dora-api" -- 280
			file = string.sub(namespaced, 10) -- 281
		elseif __TS__StringStartsWith(namespaced, "godot-api/") then -- 281
			namespacedType = "godot-api" -- 283
			file = string.sub(namespaced, 11) -- 284
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 284
			namespacedType = "love-api" -- 286
			file = string.sub(namespaced, 10) -- 287
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 287
			namespacedType = "tic80-api" -- 289
			file = string.sub(namespaced, 11) -- 290
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 290
			namespacedType = "dora-tutorial" -- 292
			file = string.sub(namespaced, 15) -- 293
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 293
			namespacedType = "dora-api" -- 295
			file = string.sub(namespaced, 5) -- 296
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 296
			namespacedType = "dora-tutorial" -- 298
			file = string.sub(namespaced, 10) -- 299
		else -- 299
			return {success = false, message = "invalid Dora doc namespace"} -- 301
		end -- 301
	end -- 301
	if not isValidWorkspacePath(file) or file == "." then -- 301
		return {success = false, message = "invalid file"} -- 305
	end -- 305
	local lowerFile = string.lower(file) -- 307
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 308
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 309
	if not isTutorialDoc and not isAPIDoc then -- 309
		return {success = false, message = "unsupported doc file type"} -- 310
	end -- 310
	local docType = namespacedType or (isTutorialDoc and "dora-tutorial" or "dora-api") -- 311
	if not isDoraDocFileInScope(docType, file) then -- 311
		return {success = false, message = "document is outside the requested search type"} -- 313
	end -- 313
	local root = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 315
	local fullPath = Path(root, file) -- 316
	local relative = Path:getRelative(fullPath, root) -- 317
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 317
		return {success = false, message = "invalid file"} -- 319
	end -- 319
	local readResult = readFile(root, file, req.startLine or 1, req.endLine or -1) -- 321
	if not readResult.success then -- 321
		return readResult -- 322
	end -- 322
	return { -- 323
		success = true, -- 324
		docLanguage = docType == "godot-api" and "en" or req.docLanguage, -- 325
		file = file, -- 326
		content = readResult.content, -- 327
		startLine = readResult.startLine, -- 328
		endLine = readResult.endLine -- 329
	} -- 329
end -- 268
return ____exports -- 268