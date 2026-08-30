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
____exports.isSafeHttpsGitUrl = function(value) -- 109
	if not __TS__StringStartsWith(value, "https://") or #value > 2048 then -- 109
		return false -- 110
	end -- 110
	local whitespace = string.match(value, "%s") -- 111
	if whitespace ~= nil then -- 111
		return false -- 112
	end -- 112
	local authorityEnd = (string.find( -- 113
		value, -- 113
		"/", -- 113
		math.max(#"https://" + 1, 1), -- 113
		true -- 113
	) or 0) - 1 -- 113
	local authority = authorityEnd >= 0 and __TS__StringSubstring(value, #"https://", authorityEnd) or __TS__StringSubstring(value, #"https://") -- 114
	return #authority > 0 and (string.find(authority, "@", nil, true) or 0) - 1 < 0 -- 117
end -- 109
local function isSafeRelativePath(value) -- 120
	if #value == 0 or #value > 512 or __TS__StringStartsWith(value, "/") or (string.find(value, "\\", nil, true) or 0) - 1 >= 0 then -- 120
		return false -- 122
	end -- 122
	for ____, segment in ipairs(__TS__StringSplit(value, "/")) do -- 124
		if segment == "" or segment == "." or segment == ".." then -- 124
			return false -- 125
		end -- 125
	end -- 125
	return true -- 127
end -- 120
local function parseLocalized(value, field, errors) -- 130
	if not isRecord(value) or not isNonEmptyString(value["zh-Hans"], field == "title" and 200 or 4000) or not isNonEmptyString(value.en, field == "title" and 200 or 4000) then -- 130
		errors[#errors + 1] = field .. " must contain non-empty zh-Hans and en text" -- 134
		return nil -- 135
	end -- 135
	return {["zh-Hans"] = value["zh-Hans"], en = value.en} -- 137
end -- 130
local function parseStringList(value, field, maxItems, errors, tag) -- 143
	if tag == nil then -- 143
		tag = false -- 148
	end -- 148
	if not __TS__ArrayIsArray(value) or #value > maxItems then -- 148
		errors[#errors + 1] = ((field .. " must be an array with at most ") .. tostring(maxItems)) .. " items" -- 151
		return nil -- 152
	end -- 152
	local result = {} -- 154
	local seen = __TS__New(Set) -- 155
	for ____, item in ipairs(value) do -- 156
		if not isNonEmptyString(item, 100) or tag and not hasOnlyTagChars(item) then -- 156
			errors[#errors + 1] = field .. " contains an invalid value" -- 158
			return nil -- 159
		end -- 159
		if seen:has(item) then -- 159
			errors[#errors + 1] = (field .. " contains duplicate value ") .. item -- 162
			return nil -- 163
		end -- 163
		seen:add(item) -- 165
		result[#result + 1] = item -- 166
	end -- 166
	return result -- 168
end -- 143
local function parseLicense(value, errors) -- 171
	if not isRecord(value) or value.status ~= "pending" and value.status ~= "confirmed" then -- 171
		errors[#errors + 1] = "license.status must be pending or confirmed" -- 173
		return nil -- 174
	end -- 174
	if value.status == "pending" then -- 174
		return {status = "pending"} -- 176
	end -- 176
	if not isNonEmptyString(value.spdx, 100) then -- 176
		errors[#errors + 1] = "confirmed license must contain spdx" -- 178
		return nil -- 179
	end -- 179
	if value.file ~= nil and (not isNonEmptyString(value.file, 512) or not isSafeRelativePath(value.file)) then -- 179
		errors[#errors + 1] = "license.file must be a safe relative path" -- 182
		return nil -- 183
	end -- 183
	return {status = "confirmed", spdx = value.spdx, file = value.file} -- 185
end -- 171
local function parseEntrypoints(value, errors) -- 192
	if not __TS__ArrayIsArray(value) or #value > 32 then -- 192
		errors[#errors + 1] = "entrypoints must be an array with at most 32 items" -- 194
		return nil -- 195
	end -- 195
	local result = {} -- 197
	for ____, item in ipairs(value) do -- 198
		if not isRecord(item) or not isNonEmptyString(item.name, 100) or not isNonEmptyString(item.path, 512) or not isSafeRelativePath(item.path) then -- 198
			errors[#errors + 1] = "entrypoints contains an invalid entry" -- 203
			return nil -- 204
		end -- 204
		result[#result + 1] = {name = item.name, path = item.path} -- 206
	end -- 206
	return result -- 208
end -- 192
local function parseSources(value, errors) -- 211
	if not __TS__ArrayIsArray(value) or #value == 0 or #value > 8 then -- 211
		errors[#errors + 1] = "version.sources must contain 1 to 8 sources" -- 213
		return nil -- 214
	end -- 214
	local result = {} -- 216
	local seen = __TS__New(Set) -- 217
	for ____, item in ipairs(value) do -- 218
		if not isRecord(item) or item.role ~= "upstream" and item.role ~= "mirror" or not isNonEmptyString(item.url, 2048) or not ____exports.isSafeHttpsGitUrl(item.url) then -- 218
			errors[#errors + 1] = "version.sources contains an invalid HTTPS Git source" -- 223
			return nil -- 224
		end -- 224
		if seen:has(item.url) then -- 224
			errors[#errors + 1] = "version.sources contains duplicate URL " .. item.url -- 227
			return nil -- 228
		end -- 228
		seen:add(item.url) -- 230
		result[#result + 1] = {role = item.role, url = item.url} -- 231
	end -- 231
	return result -- 233
end -- 211
local function parseVersions(value, errors) -- 236
	if not __TS__ArrayIsArray(value) or #value == 0 or #value > 32 then -- 236
		errors[#errors + 1] = "versions must contain 1 to 32 items" -- 238
		return nil -- 239
	end -- 239
	local result = {} -- 241
	local seen = __TS__New(Set) -- 242
	for ____, item in ipairs(value) do -- 243
		if not isRecord(item) or not isNonEmptyString(item.name, 100) or not isNonEmptyString(item.publishedAt, 100) then -- 243
			errors[#errors + 1] = "versions contains invalid name or publishedAt" -- 247
			return nil -- 248
		end -- 248
		if item.tag ~= nil and not isNonEmptyString(item.tag, 200) then -- 248
			errors[#errors + 1] = "version.tag must be a non-empty string" -- 251
			return nil -- 252
		end -- 252
		local sources = parseSources(item.sources, errors) -- 254
		if not sources then -- 254
			return nil -- 255
		end -- 255
		if seen:has(item.name) then -- 255
			errors[#errors + 1] = "versions contains duplicate name " .. item.name -- 257
			return nil -- 258
		end -- 258
		seen:add(item.name) -- 260
		result[#result + 1] = {name = item.name, tag = item.tag, publishedAt = item.publishedAt, sources = sources} -- 261
	end -- 261
	return result -- 268
end -- 236
____exports.parseResourceJSON = function(text, projectName, projectPath, bannerPath) -- 271
	local errors = {} -- 277
	if #text > ____exports.MAX_RESOURCE_JSON_BYTES then -- 277
		return nil, {("resource.json exceeds " .. tostring(____exports.MAX_RESOURCE_JSON_BYTES)) .. " bytes"} -- 279
	end -- 279
	local decoded, decodeError = json.decode(text) -- 281
	if decodeError ~= nil or not isRecord(decoded) then -- 281
		return nil, {"invalid JSON: " .. (decodeError or "root must be an object")} -- 283
	end -- 283
	if decoded.schemaVersion ~= ____exports.CATALOG_SCHEMA_VERSION then -- 283
		errors[#errors + 1] = "unsupported schemaVersion " .. tostring(decoded.schemaVersion) -- 286
	end -- 286
	if not isNonEmptyString(decoded.id, 200) or not hasOnlyResourceIdChars(decoded.id) then -- 286
		errors[#errors + 1] = "id contains invalid characters" -- 289
	elseif decoded.id ~= projectName then -- 289
		errors[#errors + 1] = (("id " .. decoded.id) .. " does not match directory ") .. projectName -- 291
	end -- 291
	local allowedStatus = decoded.status == "active" or decoded.status == "deprecated" or decoded.status == "unavailable" or decoded.status == "blocked" -- 293
	if not allowedStatus then -- 293
		errors[#errors + 1] = "status is invalid" -- 297
	end -- 297
	local title = parseLocalized(decoded.title, "title", errors) -- 298
	local description = parseLocalized(decoded.description, "description", errors) -- 299
	local categories = parseStringList(decoded.categories, "categories", 32, errors) -- 300
	local tags = decoded.tags == nil and ({}) or parseStringList( -- 301
		decoded.tags, -- 303
		"tags", -- 303
		32, -- 303
		errors, -- 303
		true -- 303
	) -- 303
	local license = parseLicense(decoded.license, errors) -- 304
	if type(decoded.runnable) ~= "boolean" then -- 304
		errors[#errors + 1] = "runnable must be boolean" -- 305
	end -- 305
	local entrypoints = parseEntrypoints(decoded.entrypoints, errors) -- 306
	local versions = parseVersions(decoded.versions, errors) -- 307
	if #errors > 0 or not title or not description or not categories or not tags or not license or not entrypoints or not versions or type(decoded.id) ~= "string" then -- 307
		return nil, errors -- 317
	end -- 317
	return { -- 319
		schemaVersion = ____exports.CATALOG_SCHEMA_VERSION, -- 320
		id = decoded.id, -- 321
		status = decoded.status, -- 322
		title = title, -- 323
		description = description, -- 324
		categories = categories, -- 325
		tags = tags, -- 326
		license = license, -- 327
		runnable = decoded.runnable, -- 328
		entrypoints = entrypoints, -- 329
		versions = versions, -- 330
		projectPath = projectPath, -- 331
		bannerPath = bannerPath, -- 332
		selectedVersion = 1, -- 333
		mobileOrder = type(decoded.mobileOrder) == "number" and decoded.mobileOrder or nil -- 334
	}, {} -- 334
end -- 271
____exports.loadCatalog = function(catalogRoot) -- 338
	local projectsPath = Path(catalogRoot, "projects") -- 339
	local issues = {} -- 340
	local resources = {} -- 341
	local categories = __TS__New(Set) -- 342
	local ids = __TS__New(Set) -- 343
	if not Content:isdir(projectsPath) then -- 343
		return {resources = resources, issues = {{project = "", message = "projects directory is missing"}}, categories = {}} -- 345
	end -- 345
	local projectNames = __TS__ArraySort(Content:getDirs(projectsPath)) -- 351
	if #projectNames > ____exports.MAX_CATALOG_RESOURCES then -- 351
		issues[#issues + 1] = { -- 353
			project = "", -- 354
			message = (("catalog contains " .. tostring(#projectNames)) .. " projects; maximum is ") .. tostring(____exports.MAX_CATALOG_RESOURCES) -- 355
		} -- 355
		return {resources = resources, issues = issues, categories = {}} -- 357
	end -- 357
	for ____, projectName in ipairs(projectNames) do -- 359
		do -- 359
			local projectPath = Path(projectsPath, projectName) -- 360
			local resourceFile = Path(projectPath, "resource.json") -- 361
			if not Content:exist(resourceFile) then -- 361
				issues[#issues + 1] = {project = projectName, message = "resource.json is missing"} -- 363
				goto __continue58 -- 364
			end -- 364
			local bannerFile = Path(projectPath, "banner.jpg") -- 366
			if Content:exist(bannerFile) then -- 366
				local bannerBytes = Content:getAttr(bannerFile) -- 368
				if bannerBytes == nil or bannerBytes > ____exports.MAX_BANNER_BYTES then -- 368
					issues[#issues + 1] = { -- 370
						project = projectName, -- 371
						message = ("banner.jpg exceeds " .. tostring(____exports.MAX_BANNER_BYTES)) .. " bytes" -- 372
					} -- 372
					goto __continue58 -- 374
				end -- 374
			end -- 374
			local resource, errors = ____exports.parseResourceJSON( -- 377
				Content:load(resourceFile), -- 378
				projectName, -- 379
				projectPath, -- 380
				Content:exist(bannerFile) and bannerFile or nil -- 381
			) -- 381
			if not resource then -- 381
				for ____, message in ipairs(errors) do -- 384
					issues[#issues + 1] = {project = projectName, message = message} -- 384
				end -- 384
				goto __continue58 -- 385
			end -- 385
			if ids:has(resource.id) then -- 385
				issues[#issues + 1] = {project = projectName, message = "duplicate resource id " .. resource.id} -- 388
				goto __continue58 -- 389
			end -- 389
			ids:add(resource.id) -- 391
			for ____, category in ipairs(resource.categories) do -- 392
				categories:add(category) -- 392
			end -- 392
			resources[#resources + 1] = resource -- 393
		end -- 393
		::__continue58:: -- 393
	end -- 393
	__TS__ArraySort( -- 395
		resources, -- 395
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 395
	) -- 395
	return { -- 396
		resources = resources, -- 397
		issues = issues, -- 398
		categories = __TS__ArraySort(__TS__ArrayFrom(categories)) -- 399
	} -- 399
end -- 338
____exports.isMinigame = function(resource) return __TS__ArrayIndexOf(resource.tags, "minigame") >= 0 end -- 403
____exports.isMobileFeedResource = function(resource) return resource.status == "active" and resource.runnable and #resource.entrypoints > 0 and __TS__ArrayIndexOf(resource.tags, "mobile-feed") >= 0 end -- 405
____exports.getMobileFeedResources = function(resources) return __TS__ArraySort( -- 411
	(function() -- 412
		local tagged = __TS__ArrayFilter( -- 413
			resources, -- 413
			function(____, resource) return ____exports.isMobileFeedResource(resource) end -- 413
		) -- 413
		return #tagged > 0 and tagged or __TS__ArrayFilter( -- 414
			resources, -- 414
			function(____, resource) return resource.status == "active" and resource.runnable and #resource.entrypoints > 0 end -- 414
		) -- 414
	end)(), -- 412
	function(____, a, b) -- 417
		local orderA = a.mobileOrder or 1000000 -- 418
		local orderB = b.mobileOrder or 1000000 -- 419
		if orderA ~= orderB then -- 419
			return orderA - orderB -- 420
		end -- 420
		return a.id < b.id and -1 or (a.id > b.id and 1 or 0) -- 421
	end -- 417
) end -- 417
____exports.filterResources = function(resources, filter) -- 424
	local query = string.lower(__TS__StringTrim(filter.query or "")) -- 425
	return __TS__ArrayFilter( -- 426
		resources, -- 426
		function(____, resource) -- 426
			if resource.status == "blocked" then -- 426
				return false -- 427
			end -- 427
			local minigame = ____exports.isMinigame(resource) -- 428
			if filter.section == "featured" and minigame then -- 428
				return false -- 429
			end -- 429
			if filter.section == "minigame" and not minigame then -- 429
				return false -- 430
			end -- 430
			if filter.category ~= nil and __TS__ArrayIndexOf(resource.categories, filter.category) < 0 then -- 430
				return false -- 431
			end -- 431
			if query ~= "" then -- 431
				local searchText = string.lower(table.concat( -- 433
					{ -- 433
						resource.id, -- 434
						resource.title["zh-Hans"], -- 435
						resource.title.en, -- 436
						resource.description["zh-Hans"], -- 437
						resource.description.en, -- 438
						table.concat(resource.categories, " ") -- 439
					}, -- 439
					"\n" -- 440
				)) -- 440
				if (string.find(searchText, query, nil, true) or 0) - 1 < 0 then -- 440
					return false -- 441
				end -- 441
			end -- 441
			return true -- 443
		end -- 426
	) -- 426
end -- 424
____exports.paginateResources = function(resources, requestedPage, pageSize) -- 447
	local safePageSize = math.max( -- 452
		1, -- 452
		math.floor(pageSize) -- 452
	) -- 452
	local pageCount = math.max( -- 453
		1, -- 453
		math.ceil(#resources / safePageSize) -- 453
	) -- 453
	local page = math.max( -- 454
		0, -- 454
		math.min( -- 454
			math.floor(requestedPage), -- 454
			pageCount - 1 -- 454
		) -- 454
	) -- 454
	local start = page * safePageSize -- 455
	return { -- 456
		items = __TS__ArraySlice(resources, start, start + safePageSize), -- 457
		page = page, -- 458
		pageCount = pageCount, -- 459
		total = #resources -- 460
	} -- 460
end -- 447
return ____exports -- 447