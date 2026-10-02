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
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
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
local function isRecord(value) -- 93
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) -- 94
end -- 93
local function isNonEmptyString(value, maxLength) -- 96
	return type(value) == "string" and #value > 0 and #value <= maxLength -- 97
end -- 96
local function hasOnlyResourceIdChars(value) -- 99
	local invalid = string.match(value, "[^A-Za-z0-9._-]") -- 100
	return invalid == nil -- 101
end -- 99
local function hasOnlyTagChars(value) -- 104
	local invalid = string.match(value, "[^a-z0-9-]") -- 105
	local first = string.match(value, "^[a-z0-9]") -- 106
	return invalid == nil and first ~= nil -- 107
end -- 104
____exports.isSafeHttpsGitUrl = function(value) -- 110
	if not __TS__StringStartsWith(value, "https://") or #value > 2048 then -- 110
		return false -- 111
	end -- 111
	local whitespace = string.match(value, "%s") -- 112
	if whitespace ~= nil then -- 112
		return false -- 113
	end -- 113
	local authorityEnd = (string.find( -- 114
		value, -- 114
		"/", -- 114
		math.max(#"https://" + 1, 1), -- 114
		true -- 114
	) or 0) - 1 -- 114
	local authority = authorityEnd >= 0 and __TS__StringSubstring(value, #"https://", authorityEnd) or __TS__StringSubstring(value, #"https://") -- 115
	return #authority > 0 and (string.find(authority, "@", nil, true) or 0) - 1 < 0 -- 118
end -- 110
local function isSafeRelativePath(value) -- 121
	if #value == 0 or #value > 512 or __TS__StringStartsWith(value, "/") or (string.find(value, "\\", nil, true) or 0) - 1 >= 0 then -- 121
		return false -- 123
	end -- 123
	for ____, segment in ipairs(__TS__StringSplit(value, "/")) do -- 125
		if segment == "" or segment == "." or segment == ".." then -- 125
			return false -- 126
		end -- 126
	end -- 126
	return true -- 128
end -- 121
local function parseLocalized(value, field, errors) -- 131
	if not isRecord(value) or not isNonEmptyString(value["zh-Hans"], field == "title" and 200 or 4000) or not isNonEmptyString(value.en, field == "title" and 200 or 4000) then -- 131
		errors[#errors + 1] = field .. " must contain non-empty zh-Hans and en text" -- 135
		return nil -- 136
	end -- 136
	return {["zh-Hans"] = value["zh-Hans"], en = value.en} -- 138
end -- 131
local function parseStringList(value, field, maxItems, errors, tag) -- 144
	if tag == nil then -- 144
		tag = false -- 149
	end -- 149
	if not __TS__ArrayIsArray(value) or #value > maxItems then -- 149
		errors[#errors + 1] = ((field .. " must be an array with at most ") .. tostring(maxItems)) .. " items" -- 152
		return nil -- 153
	end -- 153
	local result = {} -- 155
	local seen = __TS__New(Set) -- 156
	for ____, item in ipairs(value) do -- 157
		if not isNonEmptyString(item, 100) or tag and not hasOnlyTagChars(item) then -- 157
			errors[#errors + 1] = field .. " contains an invalid value" -- 159
			return nil -- 160
		end -- 160
		if seen:has(item) then -- 160
			errors[#errors + 1] = (field .. " contains duplicate value ") .. item -- 163
			return nil -- 164
		end -- 164
		seen:add(item) -- 166
		result[#result + 1] = item -- 167
	end -- 167
	return result -- 169
end -- 144
local function parseLicense(value, errors) -- 172
	if not isRecord(value) or value.status ~= "pending" and value.status ~= "confirmed" then -- 172
		errors[#errors + 1] = "license.status must be pending or confirmed" -- 174
		return nil -- 175
	end -- 175
	if value.status == "pending" then -- 175
		return {status = "pending"} -- 177
	end -- 177
	if not isNonEmptyString(value.spdx, 100) then -- 177
		errors[#errors + 1] = "confirmed license must contain spdx" -- 179
		return nil -- 180
	end -- 180
	if value.file ~= nil and (not isNonEmptyString(value.file, 512) or not isSafeRelativePath(value.file)) then -- 180
		errors[#errors + 1] = "license.file must be a safe relative path" -- 183
		return nil -- 184
	end -- 184
	return {status = "confirmed", spdx = value.spdx, file = value.file} -- 186
end -- 172
local function parseEntrypoints(value, errors) -- 193
	if not __TS__ArrayIsArray(value) or #value > 32 then -- 193
		errors[#errors + 1] = "entrypoints must be an array with at most 32 items" -- 195
		return nil -- 196
	end -- 196
	local result = {} -- 198
	for ____, item in ipairs(value) do -- 199
		if not isRecord(item) or not isNonEmptyString(item.name, 100) or not isNonEmptyString(item.path, 512) or not isSafeRelativePath(item.path) then -- 199
			errors[#errors + 1] = "entrypoints contains an invalid entry" -- 204
			return nil -- 205
		end -- 205
		result[#result + 1] = {name = item.name, path = item.path} -- 207
	end -- 207
	return result -- 209
end -- 193
local function parseSources(value, errors) -- 212
	if not __TS__ArrayIsArray(value) or #value == 0 or #value > 8 then -- 212
		errors[#errors + 1] = "version.sources must contain 1 to 8 sources" -- 214
		return nil -- 215
	end -- 215
	local result = {} -- 217
	local seen = __TS__New(Set) -- 218
	for ____, item in ipairs(value) do -- 219
		if not isRecord(item) or item.role ~= "upstream" and item.role ~= "mirror" or not isNonEmptyString(item.url, 2048) or not ____exports.isSafeHttpsGitUrl(item.url) then -- 219
			errors[#errors + 1] = "version.sources contains an invalid HTTPS Git source" -- 224
			return nil -- 225
		end -- 225
		if seen:has(item.url) then -- 225
			errors[#errors + 1] = "version.sources contains duplicate URL " .. item.url -- 228
			return nil -- 229
		end -- 229
		seen:add(item.url) -- 231
		result[#result + 1] = {role = item.role, url = item.url} -- 232
	end -- 232
	return result -- 234
end -- 212
local function parseVersions(value, errors) -- 237
	if not __TS__ArrayIsArray(value) or #value == 0 or #value > 32 then -- 237
		errors[#errors + 1] = "versions must contain 1 to 32 items" -- 239
		return nil -- 240
	end -- 240
	local result = {} -- 242
	local seen = __TS__New(Set) -- 243
	for ____, item in ipairs(value) do -- 244
		if not isRecord(item) or not isNonEmptyString(item.name, 100) or not isNonEmptyString(item.publishedAt, 100) then -- 244
			errors[#errors + 1] = "versions contains invalid name or publishedAt" -- 248
			return nil -- 249
		end -- 249
		if item.tag ~= nil and not isNonEmptyString(item.tag, 200) then -- 249
			errors[#errors + 1] = "version.tag must be a non-empty string" -- 252
			return nil -- 253
		end -- 253
		local sources = parseSources(item.sources, errors) -- 255
		if not sources then -- 255
			return nil -- 256
		end -- 256
		if seen:has(item.name) then -- 256
			errors[#errors + 1] = "versions contains duplicate name " .. item.name -- 258
			return nil -- 259
		end -- 259
		seen:add(item.name) -- 261
		result[#result + 1] = {name = item.name, tag = item.tag, publishedAt = item.publishedAt, sources = sources} -- 262
	end -- 262
	return result -- 269
end -- 237
____exports.parseResourceJSON = function(text, projectName, projectPath, bannerPath) -- 272
	local errors = {} -- 278
	if #text > ____exports.MAX_RESOURCE_JSON_BYTES then -- 278
		return nil, {("resource.json exceeds " .. tostring(____exports.MAX_RESOURCE_JSON_BYTES)) .. " bytes"} -- 280
	end -- 280
	local decoded, decodeError = json.decode(text) -- 282
	if decodeError ~= nil or not isRecord(decoded) then -- 282
		return nil, {"invalid JSON: " .. (decodeError or "root must be an object")} -- 284
	end -- 284
	if decoded.schemaVersion ~= ____exports.CATALOG_SCHEMA_VERSION then -- 284
		errors[#errors + 1] = "unsupported schemaVersion " .. tostring(decoded.schemaVersion) -- 287
	end -- 287
	if not isNonEmptyString(decoded.id, 200) or not hasOnlyResourceIdChars(decoded.id) then -- 287
		errors[#errors + 1] = "id contains invalid characters" -- 290
	elseif decoded.id ~= projectName then -- 290
		errors[#errors + 1] = (("id " .. decoded.id) .. " does not match directory ") .. projectName -- 292
	end -- 292
	local allowedStatus = decoded.status == "active" or decoded.status == "deprecated" or decoded.status == "unavailable" or decoded.status == "blocked" -- 294
	if not allowedStatus then -- 294
		errors[#errors + 1] = "status is invalid" -- 298
	end -- 298
	local title = parseLocalized(decoded.title, "title", errors) -- 299
	local description = parseLocalized(decoded.description, "description", errors) -- 300
	local categories = parseStringList(decoded.categories, "categories", 32, errors) -- 301
	local tags = decoded.tags == nil and ({}) or parseStringList( -- 302
		decoded.tags, -- 304
		"tags", -- 304
		32, -- 304
		errors, -- 304
		true -- 304
	) -- 304
	local license = parseLicense(decoded.license, errors) -- 305
	if type(decoded.runnable) ~= "boolean" then -- 305
		errors[#errors + 1] = "runnable must be boolean" -- 306
	end -- 306
	local entrypoints = parseEntrypoints(decoded.entrypoints, errors) -- 307
	local versions = parseVersions(decoded.versions, errors) -- 308
	if decoded.playUrl ~= nil and (type(decoded.playUrl) ~= "string" or not ____exports.isSafeHttpsGitUrl(decoded.playUrl)) then -- 308
		errors[#errors + 1] = "playUrl must be a safe HTTPS URL" -- 310
	end -- 310
	if #errors > 0 or not title or not description or not categories or not tags or not license or not entrypoints or not versions or type(decoded.id) ~= "string" then -- 310
		return nil, errors -- 321
	end -- 321
	return { -- 323
		schemaVersion = ____exports.CATALOG_SCHEMA_VERSION, -- 324
		id = decoded.id, -- 325
		status = decoded.status, -- 326
		title = title, -- 327
		description = description, -- 328
		categories = categories, -- 329
		tags = tags, -- 330
		license = license, -- 331
		runnable = decoded.runnable, -- 332
		entrypoints = entrypoints, -- 333
		versions = versions, -- 334
		projectPath = projectPath, -- 335
		bannerPath = bannerPath, -- 336
		selectedVersion = 1, -- 337
		mobileOrder = type(decoded.mobileOrder) == "number" and decoded.mobileOrder or nil, -- 338
		playUrl = decoded.playUrl -- 339
	}, {} -- 339
end -- 272
____exports.loadCatalog = function(catalogRoot) -- 343
	local projectsPath = Path(catalogRoot, "projects") -- 344
	local issues = {} -- 345
	local resources = {} -- 346
	local categories = __TS__New(Set) -- 347
	local ids = __TS__New(Set) -- 348
	if not Content:isdir(projectsPath) then -- 348
		return {resources = resources, issues = {{project = "", message = "projects directory is missing"}}, categories = {}} -- 350
	end -- 350
	local projectNames = __TS__ArraySort(Content:getDirs(projectsPath)) -- 356
	if #projectNames > ____exports.MAX_CATALOG_RESOURCES then -- 356
		issues[#issues + 1] = { -- 358
			project = "", -- 359
			message = (("catalog contains " .. tostring(#projectNames)) .. " projects; maximum is ") .. tostring(____exports.MAX_CATALOG_RESOURCES) -- 360
		} -- 360
		return {resources = resources, issues = issues, categories = {}} -- 362
	end -- 362
	for ____, projectName in ipairs(projectNames) do -- 364
		do -- 364
			local projectPath = Path(projectsPath, projectName) -- 365
			local resourceFile = Path(projectPath, "resource.json") -- 366
			if not Content:exist(resourceFile) then -- 366
				issues[#issues + 1] = {project = projectName, message = "resource.json is missing"} -- 368
				goto __continue59 -- 369
			end -- 369
			local bannerFile = Path(projectPath, "banner.jpg") -- 371
			if Content:exist(bannerFile) then -- 371
				local bannerBytes = Content:getAttr(bannerFile) -- 373
				if bannerBytes == nil or bannerBytes > ____exports.MAX_BANNER_BYTES then -- 373
					issues[#issues + 1] = { -- 375
						project = projectName, -- 376
						message = ("banner.jpg exceeds " .. tostring(____exports.MAX_BANNER_BYTES)) .. " bytes" -- 377
					} -- 377
					goto __continue59 -- 379
				end -- 379
			end -- 379
			local resource, errors = ____exports.parseResourceJSON( -- 382
				Content:load(resourceFile), -- 383
				projectName, -- 384
				projectPath, -- 385
				Content:exist(bannerFile) and bannerFile or nil -- 386
			) -- 386
			if not resource then -- 386
				for ____, message in ipairs(errors) do -- 389
					issues[#issues + 1] = {project = projectName, message = message} -- 389
				end -- 389
				goto __continue59 -- 390
			end -- 390
			if ids:has(resource.id) then -- 390
				issues[#issues + 1] = {project = projectName, message = "duplicate resource id " .. resource.id} -- 393
				goto __continue59 -- 394
			end -- 394
			ids:add(resource.id) -- 396
			for ____, category in ipairs(resource.categories) do -- 397
				categories:add(category) -- 397
			end -- 397
			resources[#resources + 1] = resource -- 398
		end -- 398
		::__continue59:: -- 398
	end -- 398
	__TS__ArraySort( -- 400
		resources, -- 400
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 400
	) -- 400
	return { -- 401
		resources = resources, -- 402
		issues = issues, -- 403
		categories = __TS__ArraySort(__TS__ArrayFrom(categories)) -- 404
	} -- 404
end -- 343
____exports.isMinigame = function(resource) return __TS__ArrayIndexOf(resource.tags, "minigame") >= 0 end -- 408
____exports.isMobileFeedResource = function(resource) return resource.status == "active" and (resource.runnable and #resource.entrypoints > 0 or resource.playUrl ~= nil) and __TS__ArrayIndexOf(resource.tags, "mobile-feed") >= 0 end -- 410
____exports.getMobileFeedResources = function(resources) return __TS__ArraySort( -- 415
	(function() -- 416
		local tagged = __TS__ArrayFilter( -- 417
			resources, -- 417
			function(____, resource) return ____exports.isMobileFeedResource(resource) end -- 417
		) -- 417
		return #tagged > 0 and tagged or __TS__ArrayFilter( -- 418
			resources, -- 418
			function(____, resource) return resource.status == "active" and resource.runnable and #resource.entrypoints > 0 end -- 418
		) -- 418
	end)(), -- 416
	function(____, a, b) -- 421
		local orderA = a.mobileOrder or 1000000 -- 422
		local orderB = b.mobileOrder or 1000000 -- 423
		if orderA ~= orderB then -- 423
			return orderA - orderB -- 424
		end -- 424
		return a.id < b.id and -1 or (a.id > b.id and 1 or 0) -- 425
	end -- 421
) end -- 421
____exports.filterResources = function(resources, filter) -- 428
	local query = string.lower(__TS__StringTrim(filter.query or "")) -- 429
	return __TS__ArrayFilter( -- 430
		resources, -- 430
		function(____, resource) -- 430
			if resource.status == "blocked" then -- 430
				return false -- 431
			end -- 431
			local minigame = ____exports.isMinigame(resource) -- 432
			if filter.section == "featured" and minigame then -- 432
				return false -- 433
			end -- 433
			if filter.section == "minigame" and not minigame then -- 433
				return false -- 434
			end -- 434
			if filter.category ~= nil and __TS__ArrayIndexOf(resource.categories, filter.category) < 0 then -- 434
				return false -- 435
			end -- 435
			if query ~= "" then -- 435
				local searchText = string.lower(table.concat( -- 437
					{ -- 437
						resource.id, -- 438
						resource.title["zh-Hans"], -- 439
						resource.title.en, -- 440
						resource.description["zh-Hans"], -- 441
						resource.description.en, -- 442
						table.concat(resource.categories, " ") -- 443
					}, -- 443
					"\n" -- 444
				)) -- 444
				if (string.find(searchText, query, nil, true) or 0) - 1 < 0 then -- 444
					return false -- 445
				end -- 445
			end -- 445
			return true -- 447
		end -- 430
	) -- 430
end -- 428
____exports.paginateResources = function(resources, requestedPage, pageSize) -- 451
	local safePageSize = math.max( -- 456
		1, -- 456
		math.floor(pageSize) -- 456
	) -- 456
	local pageCount = math.max( -- 457
		1, -- 457
		math.ceil(#resources / safePageSize) -- 457
	) -- 457
	local page = math.max( -- 458
		0, -- 458
		math.min( -- 458
			math.floor(requestedPage), -- 458
			pageCount - 1 -- 458
		) -- 458
	) -- 458
	local start = page * safePageSize -- 459
	return { -- 460
		items = __TS__ArraySlice(resources, start, start + safePageSize), -- 461
		page = page, -- 462
		pageCount = pageCount, -- 463
		total = #resources -- 464
	} -- 464
end -- 451
return ____exports -- 451