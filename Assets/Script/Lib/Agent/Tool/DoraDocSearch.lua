-- [ts]: DoraDocSearch.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local ____Workspace = require("Agent.Tool.Workspace") -- 3
local ensureSafeSearchGlobs = ____Workspace.ensureSafeSearchGlobs -- 4
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 5
local readFile = ____Workspace.readFile -- 6
local splitSearchPatterns = ____Workspace.splitSearchPatterns -- 7
local splitWhitespaceSearchPatterns = ____Workspace.splitWhitespaceSearchPatterns -- 8
local AGENT_DORA_DOC_PREFIX = ____Workspace.AGENT_DORA_DOC_PREFIX -- 9
local getDoraDocSearchTarget = ____Workspace.getDoraDocSearchTarget -- 10
local getDoraDocResultBaseRoot = ____Workspace.getDoraDocResultBaseRoot -- 11
local isDoraDocFileInScope = ____Workspace.isDoraDocFileInScope -- 12
local toDocRelativePath = ____Workspace.toDocRelativePath -- 13
local function mergeDoraDocSearchHitsUnique(resultsList) -- 32
	local merged = {} -- 33
	local seen = __TS__New(Set) -- 34
	local index = 0 -- 35
	local advanced = true -- 36
	while advanced do -- 36
		advanced = false -- 38
		do -- 38
			local i = 0 -- 39
			while i < #resultsList do -- 39
				do -- 39
					local list = resultsList[i + 1] -- 40
					if index >= #list then -- 40
						goto __continue5 -- 41
					end -- 41
					advanced = true -- 42
					local row = list[index + 1] -- 43
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 44
					if seen:has(key) then -- 44
						goto __continue5 -- 45
					end -- 45
					seen:add(key) -- 46
					merged[#merged + 1] = row -- 47
				end -- 47
				::__continue5:: -- 47
				i = i + 1 -- 39
			end -- 39
		end -- 39
		index = index + 1 -- 49
	end -- 49
	return merged -- 51
end -- 32
local function getDoraDocFilePriority(file, docType, programmingLanguage) -- 54
	if docType ~= "dora-api" then -- 54
		return 100 -- 55
	end -- 55
	if programmingLanguage ~= "tsx" then -- 55
		return 100 -- 56
	end -- 56
	repeat -- 56
		local ____switch11 = string.lower(Path:getFilename(file)) -- 56
		local ____cond11 = ____switch11 == "jsx.d.ts" -- 56
		if ____cond11 then -- 56
			return 0 -- 58
		end -- 58
		____cond11 = ____cond11 or ____switch11 == "dorax.d.ts" -- 58
		if ____cond11 then -- 58
			return 1 -- 59
		end -- 59
		____cond11 = ____cond11 or ____switch11 == "dora.d.ts" -- 59
		if ____cond11 then -- 59
			return 2 -- 60
		end -- 60
		do -- 60
			return 100 -- 61
		end -- 61
	until true -- 61
end -- 54
local function sortDoraDocSearchHits(hits, docType, programmingLanguage) -- 65
	local sorted = __TS__ArraySlice(hits) -- 70
	__TS__ArraySort( -- 71
		sorted, -- 71
		function(____, a, b) -- 71
			local pa = getDoraDocFilePriority(a.file, docType, programmingLanguage) -- 72
			local pb = getDoraDocFilePriority(b.file, docType, programmingLanguage) -- 73
			if pa ~= pb then -- 73
				return pa - pb -- 74
			end -- 74
			local fa = string.lower(a.file) -- 75
			local fb = string.lower(b.file) -- 76
			if fa ~= fb then -- 76
				return fa < fb and -1 or 1 -- 77
			end -- 77
			return (a.line or 0) - (b.line or 0) -- 78
		end -- 71
	) -- 71
	return sorted -- 80
end -- 65
function ____exports.searchDoraDoc(req) -- 83
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 83
		local pattern = __TS__StringTrim(req.pattern or "") -- 94
		if pattern == "" then -- 94
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 94
		end -- 94
		local patterns = splitSearchPatterns(pattern) -- 96
		if #patterns == 0 then -- 96
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 96
		end -- 96
		local docType = req.docType or "dora-api" -- 98
		local target = getDoraDocSearchTarget(docType, req.docLanguage, req.programmingLanguage) -- 99
		local docRoot = target.root -- 100
		local resultBaseRoot = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 101
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 101
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 101
		end -- 101
		local exts = target.exts -- 105
		local dotExts = __TS__ArrayMap( -- 106
			exts, -- 106
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 106
		) -- 106
		local globs = target.globs -- 107
		local limit = math.max( -- 108
			1, -- 108
			math.floor(req.limit or 10) -- 108
		) -- 108
		return ____awaiter_resolve( -- 108
			nil, -- 108
			__TS__New( -- 110
				__TS__Promise, -- 110
				function(____, resolve) -- 110
					Director.systemScheduler:schedule(once(function() -- 111
						do -- 111
							local function ____catch(e) -- 111
								resolve( -- 191
									nil, -- 191
									{ -- 191
										success = false, -- 191
										message = tostring(e) -- 191
									} -- 191
								) -- 191
							end -- 191
							local ____try, ____hasReturned = pcall(function() -- 191
								local allHits = {} -- 113
								do -- 113
									local p = 0 -- 114
									while p < #patterns do -- 114
										local ____Content_4 = Content -- 115
										local ____Content_searchFilesAsync_5 = Content.searchFilesAsync -- 115
										local ____array_3 = __TS__SparseArrayNew( -- 115
											docRoot, -- 116
											dotExts, -- 117
											{}, -- 118
											ensureSafeSearchGlobs(globs), -- 119
											patterns[p + 1] -- 120
										) -- 120
										local ____req_useRegex_0 = req.useRegex -- 121
										if ____req_useRegex_0 == nil then -- 121
											____req_useRegex_0 = false -- 121
										end -- 121
										__TS__SparseArrayPush(____array_3, ____req_useRegex_0) -- 121
										local ____req_caseSensitive_1 = req.caseSensitive -- 122
										if ____req_caseSensitive_1 == nil then -- 122
											____req_caseSensitive_1 = false -- 122
										end -- 122
										__TS__SparseArrayPush(____array_3, ____req_caseSensitive_1) -- 122
										local ____req_includeContent_2 = req.includeContent -- 123
										if ____req_includeContent_2 == nil then -- 123
											____req_includeContent_2 = true -- 123
										end -- 123
										__TS__SparseArrayPush(____array_3, ____req_includeContent_2, req.contentWindow or 80) -- 123
										local raw = ____Content_searchFilesAsync_5( -- 115
											____Content_4, -- 115
											__TS__SparseArraySpread(____array_3) -- 115
										) -- 115
										local hits = {} -- 126
										do -- 126
											local i = 0 -- 127
											while i < #raw do -- 127
												do -- 127
													local row = raw[i + 1] -- 128
													local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 129
													if file == "" then -- 129
														goto __continue27 -- 130
													end -- 130
													hits[#hits + 1] = { -- 131
														file = file, -- 132
														line = type(row.line) == "number" and row.line or nil, -- 133
														content = type(row.content) == "string" and row.content or nil -- 134
													} -- 134
												end -- 134
												::__continue27:: -- 134
												i = i + 1 -- 127
											end -- 127
										end -- 127
										allHits[#allHits + 1] = __TS__ArraySlice( -- 137
											sortDoraDocSearchHits(hits, docType, req.programmingLanguage), -- 137
											0, -- 137
											limit -- 137
										) -- 137
										p = p + 1 -- 114
									end -- 114
								end -- 114
								local hits = mergeDoraDocSearchHitsUnique(allHits) -- 139
								local fallbackPatterns -- 140
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 140
									local terms = splitWhitespaceSearchPatterns(pattern) -- 145
									if #terms > 1 then -- 145
										fallbackPatterns = terms -- 147
										local fallbackHits = {} -- 148
										do -- 148
											local p = 0 -- 149
											while p < #terms do -- 149
												local ____Content_9 = Content -- 150
												local ____Content_searchFilesAsync_10 = Content.searchFilesAsync -- 150
												local ____array_8 = __TS__SparseArrayNew( -- 150
													docRoot, -- 151
													dotExts, -- 152
													{}, -- 153
													ensureSafeSearchGlobs(globs), -- 154
													terms[p + 1], -- 155
													false -- 156
												) -- 156
												local ____req_caseSensitive_6 = req.caseSensitive -- 157
												if ____req_caseSensitive_6 == nil then -- 157
													____req_caseSensitive_6 = false -- 157
												end -- 157
												__TS__SparseArrayPush(____array_8, ____req_caseSensitive_6) -- 157
												local ____req_includeContent_7 = req.includeContent -- 158
												if ____req_includeContent_7 == nil then -- 158
													____req_includeContent_7 = true -- 158
												end -- 158
												__TS__SparseArrayPush(____array_8, ____req_includeContent_7, req.contentWindow or 80) -- 158
												local raw = ____Content_searchFilesAsync_10( -- 150
													____Content_9, -- 150
													__TS__SparseArraySpread(____array_8) -- 150
												) -- 150
												local termHits = {} -- 161
												do -- 161
													local i = 0 -- 162
													while i < #raw do -- 162
														do -- 162
															local row = raw[i + 1] -- 163
															local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 164
															if file == "" then -- 164
																goto __continue34 -- 165
															end -- 165
															termHits[#termHits + 1] = { -- 166
																file = file, -- 167
																line = type(row.line) == "number" and row.line or nil, -- 168
																content = type(row.content) == "string" and row.content or nil -- 169
															} -- 169
														end -- 169
														::__continue34:: -- 169
														i = i + 1 -- 162
													end -- 162
												end -- 162
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 172
													sortDoraDocSearchHits(termHits, docType, req.programmingLanguage), -- 172
													0, -- 172
													limit -- 172
												) -- 172
												p = p + 1 -- 149
											end -- 149
										end -- 149
										hits = mergeDoraDocSearchHitsUnique(fallbackHits) -- 174
									end -- 174
								end -- 174
								resolve(nil, { -- 177
									success = true, -- 178
									docType = docType, -- 179
									docLanguage = req.docLanguage, -- 180
									programmingLanguage = req.programmingLanguage, -- 181
									exts = exts, -- 182
									results = hits, -- 183
									hint = "Use read_file with a namespaced result to view it, or grep_files with that exact @dora-doc path to search within the document.", -- 184
									totalResults = #hits, -- 185
									truncated = false, -- 186
									limit = limit, -- 187
									fallbackPatterns = fallbackPatterns -- 188
								}) -- 188
							end) -- 188
							if not ____try then -- 188
								____catch(____hasReturned) -- 188
							end -- 188
						end -- 188
					end)) -- 111
				end -- 110
			) -- 110
		) -- 110
	end) -- 110
end -- 83
function ____exports.searchDoraDocHttp(req, callback) -- 197
	local ____self_11 = ____exports.searchDoraDoc(req) -- 197
	____self_11["then"]( -- 197
		____self_11, -- 197
		function(____, result) return callback(result) end -- 208
	) -- 208
end -- 197
function ____exports.readDoraDoc(req) -- 211
	local requestedFile = table.concat( -- 217
		__TS__StringSplit(req.file or "", "\\"), -- 217
		"/" -- 217
	) -- 217
	local file = requestedFile -- 218
	local namespacedType = nil -- 219
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 219
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 221
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 221
			namespacedType = "dora-api" -- 223
			file = string.sub(namespaced, 10) -- 224
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 224
			namespacedType = "love-api" -- 226
			file = string.sub(namespaced, 10) -- 227
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 227
			namespacedType = "tic80-api" -- 229
			file = string.sub(namespaced, 11) -- 230
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 230
			namespacedType = "dora-tutorial" -- 232
			file = string.sub(namespaced, 15) -- 233
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 233
			namespacedType = "dora-api" -- 235
			file = string.sub(namespaced, 5) -- 236
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 236
			namespacedType = "dora-tutorial" -- 238
			file = string.sub(namespaced, 10) -- 239
		else -- 239
			return {success = false, message = "invalid Dora doc namespace"} -- 241
		end -- 241
	end -- 241
	if not isValidWorkspacePath(file) or file == "." then -- 241
		return {success = false, message = "invalid file"} -- 245
	end -- 245
	local lowerFile = string.lower(file) -- 247
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 248
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 249
	if not isTutorialDoc and not isAPIDoc then -- 249
		return {success = false, message = "unsupported doc file type"} -- 250
	end -- 250
	local docType = namespacedType or (isTutorialDoc and "dora-tutorial" or "dora-api") -- 251
	if not isDoraDocFileInScope(docType, file) then -- 251
		return {success = false, message = "document is outside the requested search type"} -- 253
	end -- 253
	local root = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 255
	local fullPath = Path(root, file) -- 256
	local relative = Path:getRelative(fullPath, root) -- 257
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 257
		return {success = false, message = "invalid file"} -- 259
	end -- 259
	local readResult = readFile(root, file, req.startLine or 1, req.endLine or -1) -- 261
	if not readResult.success then -- 261
		return readResult -- 262
	end -- 262
	return { -- 263
		success = true, -- 264
		docLanguage = req.docLanguage, -- 265
		file = file, -- 266
		content = readResult.content, -- 267
		startLine = readResult.startLine, -- 268
		endLine = readResult.endLine -- 269
	} -- 269
end -- 211
return ____exports -- 211