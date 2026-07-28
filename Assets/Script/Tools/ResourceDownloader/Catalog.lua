-- [ts]: Catalog.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
____exports.CATALOG_SCHEMA_VERSION = 1 -- 4
____exports.MAX_CATALOG_RESOURCES = 5000 -- 5
____exports.MAX_RESOURCE_JSON_BYTES = 256 * 1024 -- 6
____exports.MAX_BANNER_BYTES = 4 * 1024 * 1024 -- 7
local function isRecord(value) -- 92
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 93
end -- 92
local function isNonEmptyString(value, maxLength) -- 95
	return type(value) == "string" and #value > 0 and #value <= maxLength -- 96
end -- 95
local function hasOnlyResourceIdChars(value) -- 98
	local invalid = string.match(value, "[^A-Za-z0-9._-]") -- 99
	return invalid == nil -- 100
end -- 98
local function hasOnlyTagChars(value) -- 103
	local invalid = string.match(value, "[^a-z0-9-]") -- 104
	local first = string.match(value, "^[a-z0-9]") -- 105
	return invalid == nil and first ~= nil -- 106
end -- 103
local function isCommit(value) -- 109
	if type(value) ~= "string" or #value ~= 40 then -- 109
		return false -- 110
	end -- 110
	local invalid = string.match(value, "[^0-9a-f]") -- 111
	return invalid == nil -- 112
end -- 109
____exports.isSafeHttpsGitUrl = function(value) -- 115
	if not __TS__StringStartsWith(value, "https://") or #value > 2048 then -- 115
		return false -- 116
	end -- 116
	local whitespace = string.match(value, "%s") -- 117
	if whitespace ~= nil then -- 117
		return false -- 118
	end -- 118
	local authorityEnd = (string.find( -- 119
		value, -- 119
		"/", -- 119
		math.max(#"https://" + 1, 1), -- 119
		true -- 119
	) or 0) - 1 -- 119
	local authority = authorityEnd >= 0 and __TS__StringSubstring(value, #"https://", authorityEnd) or __TS__StringSubstring(value, #"https://") -- 120
	return #authority > 0 and (string.find(authority, "@", nil, true) or 0) - 1 < 0 -- 123
end -- 115
local function isSafeRelativePath(value) -- 126
	if #value == 0 or #value > 512 or __TS__StringStartsWith(value, "/") or (string.find(value, "\\", nil, true) or 0) - 1 >= 0 then -- 126
		return false -- 128
	end -- 128
	for ____, segment in ipairs(__TS__StringSplit(value, "/")) do -- 130
		if segment == "" or segment == "." or segment == ".." then -- 130
			return false -- 131
		end -- 131
	end -- 131
	return true -- 133
end -- 126
local function parseLocalized(value, field, errors) -- 136
	if not isRecord(value) or not isNonEmptyString(value["zh-Hans"], field == "title" and 200 or 4000) or not isNonEmptyString(value.en, field == "title" and 200 or 4000) then -- 136
		errors[#errors + 1] = field .. " must contain non-empty zh-Hans and en text" -- 140
		return nil -- 141
	end -- 141
	return {["zh-Hans"] = value["zh-Hans"], en = value.en} -- 143
end -- 136
local function parseStringList(value, field, maxItems, errors, tag) -- 149
	if tag == nil then -- 149
		tag = false -- 154
	end -- 154
	if not __TS__ArrayIsArray(value) or #value > maxItems then -- 154
		errors[#errors + 1] = ((field .. " must be an array with at most ") .. tostring(maxItems)) .. " items" -- 157
		return nil -- 158
	end -- 158
	local result = {} -- 160
	local seen = __TS__New(Set) -- 161
	for ____, item in ipairs(value) do -- 162
		if not isNonEmptyString(item, 100) or tag and not hasOnlyTagChars(item) then -- 162
			errors[#errors + 1] = field .. " contains an invalid value" -- 164
			return nil -- 165
		end -- 165
		if seen:has(item) then -- 165
			errors[#errors + 1] = (field .. " contains duplicate value ") .. item -- 168
			return nil -- 169
		end -- 169
		seen:add(item) -- 171
		result[#result + 1] = item -- 172
	end -- 172
	return result -- 174
end -- 149
local function parseLicense(value, errors) -- 177
	if not isRecord(value) or value.status ~= "pending" and value.status ~= "confirmed" then -- 177
		errors[#errors + 1] = "license.status must be pending or confirmed" -- 179
		return nil -- 180
	end -- 180
	if value.status == "pending" then -- 180
		return {status = "pending"} -- 182
	end -- 182
	if not isNonEmptyString(value.spdx, 100) then -- 182
		errors[#errors + 1] = "confirmed license must contain spdx" -- 184
		return nil -- 185
	end -- 185
	if value.file ~= nil and (not isNonEmptyString(value.file, 512) or not isSafeRelativePath(value.file)) then -- 185
		errors[#errors + 1] = "license.file must be a safe relative path" -- 188
		return nil -- 189
	end -- 189
	return {status = "confirmed", spdx = value.spdx, file = value.file} -- 191
end -- 177
local function parseEntrypoints(value, errors) -- 198
	if not __TS__ArrayIsArray(value) or #value > 32 then -- 198
		errors[#errors + 1] = "entrypoints must be an array with at most 32 items" -- 200
		return nil -- 201
	end -- 201
	local result = {} -- 203
	for ____, item in ipairs(value) do -- 204
		if not isRecord(item) or not isNonEmptyString(item.name, 100) or not isNonEmptyString(item.path, 512) or not isSafeRelativePath(item.path) then -- 204
			errors[#errors + 1] = "entrypoints contains an invalid entry" -- 209
			return nil -- 210
		end -- 210
		result[#result + 1] = {name = item.name, path = item.path} -- 212
	end -- 212
	return result -- 214
end -- 198
local function parseSources(value, errors) -- 217
	if not __TS__ArrayIsArray(value) or #value == 0 or #value > 8 then -- 217
		errors[#errors + 1] = "version.sources must contain 1 to 8 sources" -- 219
		return nil -- 220
	end -- 220
	local result = {} -- 222
	local seen = __TS__New(Set) -- 223
	for ____, item in ipairs(value) do -- 224
		if not isRecord(item) or item.role ~= "upstream" and item.role ~= "mirror" or not isNonEmptyString(item.url, 2048) or not ____exports.isSafeHttpsGitUrl(item.url) then -- 224
			errors[#errors + 1] = "version.sources contains an invalid HTTPS Git source" -- 229
			return nil -- 230
		end -- 230
		if seen:has(item.url) then -- 230
			errors[#errors + 1] = "version.sources contains duplicate URL " .. item.url -- 233
			return nil -- 234
		end -- 234
		seen:add(item.url) -- 236
		result[#result + 1] = {role = item.role, url = item.url} -- 237
	end -- 237
	return result -- 239
end -- 217
local function parseVersions(value, errors) -- 242
	if not __TS__ArrayIsArray(value) or #value == 0 or #value > 32 then -- 242
		errors[#errors + 1] = "versions must contain 1 to 32 items" -- 244
		return nil -- 245
	end -- 245
	local result = {} -- 247
	local seen = __TS__New(Set) -- 248
	for ____, item in ipairs(value) do -- 249
		if not isRecord(item) or not isNonEmptyString(item.name, 100) or not isCommit(item.commit) or not isNonEmptyString(item.publishedAt, 100) then -- 249
			errors[#errors + 1] = "versions contains invalid name, commit, or publishedAt" -- 254
			return nil -- 255
		end -- 255
		if item.tag ~= nil and not isNonEmptyString(item.tag, 200) then -- 255
			errors[#errors + 1] = "version.tag must be a non-empty string" -- 258
			return nil -- 259
		end -- 259
		local sources = parseSources(item.sources, errors) -- 261
		if not sources then -- 261
			return nil -- 262
		end -- 262
		if seen:has(item.commit) then -- 262
			errors[#errors + 1] = "versions contains duplicate commit " .. item.commit -- 264
			return nil -- 265
		end -- 265
		seen:add(item.commit) -- 267
		result[#result + 1] = { -- 268
			name = item.name, -- 269
			tag = item.tag, -- 270
			commit = item.commit, -- 271
			publishedAt = item.publishedAt, -- 272
			sources = sources -- 273
		} -- 273
	end -- 273
	return result -- 276
end -- 242
____exports.parseResourceJSON = function(text, projectName, projectPath, bannerPath) -- 279
	local errors = {} -- 285
	if #text > ____exports.MAX_RESOURCE_JSON_BYTES then -- 285
		return nil, {("resource.json exceeds " .. tostring(____exports.MAX_RESOURCE_JSON_BYTES)) .. " bytes"} -- 287
	end -- 287
	local decoded, decodeError = json.decode(text) -- 289
	if decodeError ~= nil or not isRecord(decoded) then -- 289
		return nil, {"invalid JSON: " .. (decodeError or "root must be an object")} -- 291
	end -- 291
	if decoded.schemaVersion ~= ____exports.CATALOG_SCHEMA_VERSION then -- 291
		errors[#errors + 1] = "unsupported schemaVersion " .. tostring(decoded.schemaVersion) -- 294
	end -- 294
	if not isNonEmptyString(decoded.id, 200) or not hasOnlyResourceIdChars(decoded.id) then -- 294
		errors[#errors + 1] = "id contains invalid characters" -- 297
	elseif decoded.id ~= projectName then -- 297
		errors[#errors + 1] = (("id " .. decoded.id) .. " does not match directory ") .. projectName -- 299
	end -- 299
	local allowedStatus = decoded.status == "active" or decoded.status == "deprecated" or decoded.status == "unavailable" or decoded.status == "blocked" -- 301
	if not allowedStatus then -- 301
		errors[#errors + 1] = "status is invalid" -- 305
	end -- 305
	local title = parseLocalized(decoded.title, "title", errors) -- 306
	local description = parseLocalized(decoded.description, "description", errors) -- 307
	local categories = parseStringList(decoded.categories, "categories", 32, errors) -- 308
	local tags = decoded.tags == nil and ({}) or parseStringList( -- 309
		decoded.tags, -- 311
		"tags", -- 311
		32, -- 311
		errors, -- 311
		true -- 311
	) -- 311
	local license = parseLicense(decoded.license, errors) -- 312
	if type(decoded.runnable) ~= "boolean" then -- 312
		errors[#errors + 1] = "runnable must be boolean" -- 313
	end -- 313
	local entrypoints = parseEntrypoints(decoded.entrypoints, errors) -- 314
	local versions = parseVersions(decoded.versions, errors) -- 315
	if #errors > 0 or not title or not description or not categories or not tags or not license or not entrypoints or not versions or type(decoded.id) ~= "string" then -- 315
		return nil, errors -- 325
	end -- 325
	return { -- 327
		schemaVersion = ____exports.CATALOG_SCHEMA_VERSION, -- 328
		id = decoded.id, -- 329
		status = decoded.status, -- 330
		title = title, -- 331
		description = description, -- 332
		categories = categories, -- 333
		tags = tags, -- 334
		license = license, -- 335
		runnable = decoded.runnable, -- 336
		entrypoints = entrypoints, -- 337
		versions = versions, -- 338
		projectPath = projectPath, -- 339
		bannerPath = bannerPath, -- 340
		selectedVersion = 1 -- 341
	}, {} -- 341
end -- 279
____exports.loadCatalog = function(catalogRoot) -- 345
	local projectsPath = Path(catalogRoot, "projects") -- 346
	local issues = {} -- 347
	local resources = {} -- 348
	local categories = __TS__New(Set) -- 349
	local ids = __TS__New(Set) -- 350
	if not Content:isdir(projectsPath) then -- 350
		return {resources = resources, issues = {{project = "", message = "projects directory is missing"}}, categories = {}} -- 352
	end -- 352
	local projectNames = __TS__ArraySort(Content:getDirs(projectsPath)) -- 358
	if #projectNames > ____exports.MAX_CATALOG_RESOURCES then -- 358
		issues[#issues + 1] = { -- 360
			project = "", -- 361
			message = (("catalog contains " .. tostring(#projectNames)) .. " projects; maximum is ") .. tostring(____exports.MAX_CATALOG_RESOURCES) -- 362
		} -- 362
		return {resources = resources, issues = issues, categories = {}} -- 364
	end -- 364
	for ____, projectName in ipairs(projectNames) do -- 366
		do -- 366
			local projectPath = Path(projectsPath, projectName) -- 367
			local resourceFile = Path(projectPath, "resource.json") -- 368
			if not Content:exist(resourceFile) then -- 368
				issues[#issues + 1] = {project = projectName, message = "resource.json is missing"} -- 370
				goto __continue60 -- 371
			end -- 371
			local bannerFile = Path(projectPath, "banner.jpg") -- 373
			if Content:exist(bannerFile) then -- 373
				local bannerBytes = Content:getAttr(bannerFile) -- 375
				if bannerBytes == nil or bannerBytes > ____exports.MAX_BANNER_BYTES then -- 375
					issues[#issues + 1] = { -- 377
						project = projectName, -- 378
						message = ("banner.jpg exceeds " .. tostring(____exports.MAX_BANNER_BYTES)) .. " bytes" -- 379
					} -- 379
					goto __continue60 -- 381
				end -- 381
			end -- 381
			local resource, errors = ____exports.parseResourceJSON( -- 384
				Content:load(resourceFile), -- 385
				projectName, -- 386
				projectPath, -- 387
				Content:exist(bannerFile) and bannerFile or nil -- 388
			) -- 388
			if not resource then -- 388
				for ____, message in ipairs(errors) do -- 391
					issues[#issues + 1] = {project = projectName, message = message} -- 391
				end -- 391
				goto __continue60 -- 392
			end -- 392
			if ids:has(resource.id) then -- 392
				issues[#issues + 1] = {project = projectName, message = "duplicate resource id " .. resource.id} -- 395
				goto __continue60 -- 396
			end -- 396
			ids:add(resource.id) -- 398
			for ____, category in ipairs(resource.categories) do -- 399
				categories:add(category) -- 399
			end -- 399
			resources[#resources + 1] = resource -- 400
		end -- 400
		::__continue60:: -- 400
	end -- 400
	__TS__ArraySort( -- 402
		resources, -- 402
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 402
	) -- 402
	return { -- 403
		resources = resources, -- 404
		issues = issues, -- 405
		categories = __TS__ArraySort(__TS__ArrayFrom(categories)) -- 406
	} -- 406
end -- 345
____exports.isMinigame = function(resource) return __TS__ArrayIndexOf(resource.tags, "minigame") >= 0 end -- 410
____exports.filterResources = function(resources, filter) -- 412
	local query = string.lower(__TS__StringTrim(filter.query or "")) -- 413
	return __TS__ArrayFilter( -- 414
		resources, -- 414
		function(____, resource) -- 414
			if resource.status == "blocked" then -- 414
				return false -- 415
			end -- 415
			local minigame = ____exports.isMinigame(resource) -- 416
			if filter.section == "featured" and minigame then -- 416
				return false -- 417
			end -- 417
			if filter.section == "minigame" and not minigame then -- 417
				return false -- 418
			end -- 418
			if filter.category ~= nil and __TS__ArrayIndexOf(resource.categories, filter.category) < 0 then -- 418
				return false -- 419
			end -- 419
			if query ~= "" then -- 419
				local searchText = string.lower(table.concat( -- 421
					{ -- 421
						resource.id, -- 422
						resource.title["zh-Hans"], -- 423
						resource.title.en, -- 424
						resource.description["zh-Hans"], -- 425
						resource.description.en, -- 426
						table.concat(resource.categories, " ") -- 427
					}, -- 427
					"\n" -- 428
				)) -- 428
				if (string.find(searchText, query, nil, true) or 0) - 1 < 0 then -- 428
					return false -- 429
				end -- 429
			end -- 429
			return true -- 431
		end -- 414
	) -- 414
end -- 412
____exports.paginateResources = function(resources, requestedPage, pageSize) -- 435
	local safePageSize = math.max( -- 440
		1, -- 440
		math.floor(pageSize) -- 440
	) -- 440
	local pageCount = math.max( -- 441
		1, -- 441
		math.ceil(#resources / safePageSize) -- 441
	) -- 441
	local page = math.max( -- 442
		0, -- 442
		math.min( -- 442
			math.floor(requestedPage), -- 442
			pageCount - 1 -- 442
		) -- 442
	) -- 442
	local start = page * safePageSize -- 443
	return { -- 444
		items = __TS__ArraySlice(resources, start, start + safePageSize), -- 445
		page = page, -- 446
		pageCount = pageCount, -- 447
		total = #resources -- 448
	} -- 448
end -- 435
return ____exports -- 435