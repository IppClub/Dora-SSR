-- [ts]: JsonSchema.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__TypeOf = ____lualib.__TS__TypeOf -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local normalizeLimits, createState, addError, escapePointerToken, appendPointer, isRecord, isJsonNull, isFiniteNumber, isNonNegativeInteger, deepEqual, validateJsonData, validateAnnotationValue, validateSchemaArray, validateSchemaNode, JSON_SCHEMA_TYPES, SUPPORTED_KEYWORDS -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
function normalizeLimits(options) -- 111
	local depth = type(options and options.maxDepth) == "number" and __TS__NumberIsFinite(options.maxDepth) and math.floor(options.maxDepth) or 64 -- 112
	local errors = type(options and options.maxErrors) == "number" and __TS__NumberIsFinite(options.maxErrors) and math.floor(options.maxErrors) or 32 -- 115
	return { -- 118
		maxDepth = math.max(1, depth), -- 119
		maxErrors = math.max(1, errors) -- 120
	} -- 120
end -- 120
function createState(options) -- 124
	return { -- 125
		errors = {}, -- 126
		truncated = false, -- 127
		limits = normalizeLimits(options) -- 128
	} -- 128
end -- 128
function addError(state, keyword, instancePath, schemaPath, message) -- 132
	if #state.errors >= state.limits.maxErrors then -- 132
		state.truncated = true -- 140
		return -- 141
	end -- 141
	local ____state_errors_4 = state.errors -- 141
	____state_errors_4[#____state_errors_4 + 1] = {keyword = keyword, instancePath = instancePath, schemaPath = schemaPath, message = message} -- 143
end -- 143
function escapePointerToken(value) -- 154
	return table.concat( -- 155
		__TS__StringSplit( -- 155
			table.concat( -- 155
				__TS__StringSplit(value, "~"), -- 155
				"~0" -- 155
			), -- 155
			"/" -- 155
		), -- 155
		"~1" -- 155
	) -- 155
end -- 155
function appendPointer(path, token) -- 158
	return (path .. "/") .. escapePointerToken(tostring(token)) -- 159
end -- 159
function isRecord(value) -- 162
	return type(value) == "table" and value ~= nil and not __TS__ArrayIsArray(value) and value ~= json.null -- 163
end -- 163
function isJsonNull(value) -- 166
	return value == json.null -- 167
end -- 167
function isFiniteNumber(value) -- 170
	return type(value) == "number" and __TS__NumberIsFinite(value) -- 171
end -- 171
function isNonNegativeInteger(value) -- 174
	return isFiniteNumber(value) and value >= 0 and math.floor(value) == value -- 175
end -- 175
function deepEqual(left, right, depth) -- 183
	if depth == nil then -- 183
		depth = 0 -- 183
	end -- 183
	if left == right then -- 183
		return true -- 184
	end -- 184
	if isJsonNull(left) or isJsonNull(right) then -- 184
		return isJsonNull(left) and isJsonNull(right) -- 185
	end -- 185
	if depth > 64 or __TS__TypeOf(left) ~= __TS__TypeOf(right) then -- 185
		return false -- 186
	end -- 186
	if __TS__ArrayIsArray(left) or __TS__ArrayIsArray(right) then -- 186
		if not __TS__ArrayIsArray(left) or not __TS__ArrayIsArray(right) or #left ~= #right then -- 186
			return false -- 188
		end -- 188
		do -- 188
			local i = 0 -- 189
			while i < #left do -- 189
				if not deepEqual(left[i + 1], right[i + 1], depth + 1) then -- 189
					return false -- 190
				end -- 190
				i = i + 1 -- 189
			end -- 189
		end -- 189
		return true -- 192
	end -- 192
	if isRecord(left) or isRecord(right) then -- 192
		if not isRecord(left) or not isRecord(right) then -- 192
			return false -- 195
		end -- 195
		local leftKeys = __TS__ObjectKeys(left) -- 196
		local rightKeys = __TS__ObjectKeys(right) -- 197
		if #leftKeys ~= #rightKeys then -- 197
			return false -- 198
		end -- 198
		for ____, key in ipairs(leftKeys) do -- 199
			if right[key] == nil or not deepEqual(left[key], right[key], depth + 1) then -- 199
				return false -- 200
			end -- 200
		end -- 200
		return true -- 202
	end -- 202
	return false -- 204
end -- 204
function validateJsonData(value, instancePath, depth, state, stack) -- 207
	if state.truncated then -- 207
		return -- 214
	end -- 214
	if depth > state.limits.maxDepth then -- 214
		addError( -- 216
			state, -- 216
			"json", -- 216
			instancePath, -- 216
			"", -- 216
			"JSON value exceeds maximum depth " .. tostring(state.limits.maxDepth) -- 216
		) -- 216
		return -- 217
	end -- 217
	if isJsonNull(value) or type(value) == "string" or type(value) == "boolean" then -- 217
		return -- 219
	end -- 219
	if type(value) == "number" then -- 219
		if not __TS__NumberIsFinite(value) then -- 219
			addError( -- 222
				state, -- 222
				"json", -- 222
				instancePath, -- 222
				"", -- 222
				"number must be finite JSON data" -- 222
			) -- 222
		end -- 222
		return -- 224
	end -- 224
	if __TS__ArrayIsArray(value) then -- 224
		if __TS__ArrayIndexOf(stack, value) >= 0 then -- 224
			addError( -- 228
				state, -- 228
				"json", -- 228
				instancePath, -- 228
				"", -- 228
				"cyclic arrays are not valid JSON data" -- 228
			) -- 228
			return -- 229
		end -- 229
		stack[#stack + 1] = value -- 231
		do -- 231
			local i = 0 -- 232
			while i < #value and not state.truncated do -- 232
				do -- 232
					if value[i + 1] == nil then -- 232
						addError( -- 234
							state, -- 234
							"json", -- 234
							appendPointer(instancePath, i), -- 234
							"", -- 234
							"sparse or undefined array item is not valid JSON data" -- 234
						) -- 234
						goto __continue38 -- 235
					end -- 235
					validateJsonData( -- 237
						value[i + 1], -- 237
						appendPointer(instancePath, i), -- 237
						depth + 1, -- 237
						state, -- 237
						stack -- 237
					) -- 237
				end -- 237
				::__continue38:: -- 237
				i = i + 1 -- 232
			end -- 232
		end -- 232
		table.remove(stack) -- 239
		return -- 240
	end -- 240
	if isRecord(value) then -- 240
		if __TS__ArrayIndexOf(stack, value) >= 0 then -- 240
			addError( -- 244
				state, -- 244
				"json", -- 244
				instancePath, -- 244
				"", -- 244
				"cyclic objects are not valid JSON data" -- 244
			) -- 244
			return -- 245
		end -- 245
		stack[#stack + 1] = value -- 247
		for ____, key in ipairs(__TS__ObjectKeys(value)) do -- 248
			do -- 248
				if state.truncated then -- 248
					break -- 249
				end -- 249
				if value[key] == nil then -- 249
					addError( -- 251
						state, -- 251
						"json", -- 251
						appendPointer(instancePath, key), -- 251
						"", -- 251
						"undefined object property is not valid JSON data" -- 251
					) -- 251
					goto __continue42 -- 252
				end -- 252
				validateJsonData( -- 254
					value[key], -- 254
					appendPointer(instancePath, key), -- 254
					depth + 1, -- 254
					state, -- 254
					stack -- 254
				) -- 254
			end -- 254
			::__continue42:: -- 254
		end -- 254
		table.remove(stack) -- 256
		return -- 257
	end -- 257
	addError( -- 259
		state, -- 259
		"json", -- 259
		instancePath, -- 259
		"", -- 259
		"unsupported JSON value type: " .. __TS__TypeOf(value) -- 259
	) -- 259
end -- 259
function validateAnnotationValue(value, keyword, schemaPath, depth, state) -- 262
	local annotationState = createState({maxDepth = state.limits.maxDepth - depth, maxErrors = state.limits.maxErrors - #state.errors}) -- 269
	validateJsonData( -- 273
		value, -- 273
		"", -- 273
		0, -- 273
		annotationState, -- 273
		{} -- 273
	) -- 273
	for ____, ____error in ipairs(annotationState.errors) do -- 274
		addError( -- 275
			state, -- 275
			keyword, -- 275
			"", -- 275
			schemaPath, -- 275
			(keyword .. " must contain JSON data: ") .. ____error.message -- 275
		) -- 275
	end -- 275
	if annotationState.truncated then -- 275
		state.truncated = true -- 277
	end -- 277
end -- 277
function validateSchemaArray(value, keyword, schemaPath, depth, state, stack) -- 280
	if not __TS__ArrayIsArray(value) or #value == 0 then -- 280
		addError( -- 289
			state, -- 289
			keyword, -- 289
			"", -- 289
			schemaPath, -- 289
			keyword .. " must be a non-empty array of schemas" -- 289
		) -- 289
		return -- 290
	end -- 290
	do -- 290
		local i = 0 -- 292
		while i < #value do -- 292
			validateSchemaNode( -- 293
				value[i + 1], -- 293
				appendPointer(schemaPath, i), -- 293
				depth + 1, -- 293
				state, -- 293
				stack -- 293
			) -- 293
			i = i + 1 -- 292
		end -- 292
	end -- 292
end -- 292
function validateSchemaNode(schema, schemaPath, depth, state, stack) -- 297
	if state.truncated then -- 297
		return -- 304
	end -- 304
	if depth > state.limits.maxDepth then -- 304
		addError( -- 306
			state, -- 306
			"schema", -- 306
			"", -- 306
			schemaPath, -- 306
			"schema exceeds maximum depth " .. tostring(state.limits.maxDepth) -- 306
		) -- 306
		return -- 307
	end -- 307
	if type(schema) == "boolean" then -- 307
		return -- 309
	end -- 309
	if not isRecord(schema) then -- 309
		addError( -- 311
			state, -- 311
			"schema", -- 311
			"", -- 311
			schemaPath, -- 311
			"schema must be a boolean or object" -- 311
		) -- 311
		return -- 312
	end -- 312
	if __TS__ArrayIndexOf(stack, schema) >= 0 then -- 312
		addError( -- 315
			state, -- 315
			"schema", -- 315
			"", -- 315
			schemaPath, -- 315
			"cyclic schemas are not supported" -- 315
		) -- 315
		return -- 316
	end -- 316
	stack[#stack + 1] = schema -- 318
	for ____, keyword in ipairs(__TS__ObjectKeys(schema)) do -- 320
		if __TS__ArrayIndexOf(SUPPORTED_KEYWORDS, keyword) < 0 then -- 320
			addError( -- 322
				state, -- 322
				keyword, -- 322
				"", -- 322
				appendPointer(schemaPath, keyword), -- 322
				"unsupported JSON Schema keyword: " .. keyword -- 322
			) -- 322
		end -- 322
	end -- 322
	for ____, keyword in ipairs({"$schema", "title", "description"}) do -- 326
		local value = schema[keyword] -- 327
		if value ~= nil and type(value) ~= "string" then -- 327
			addError( -- 329
				state, -- 329
				keyword, -- 329
				"", -- 329
				appendPointer(schemaPath, keyword), -- 329
				keyword .. " must be a string" -- 329
			) -- 329
		end -- 329
	end -- 329
	if schema.default ~= nil then -- 329
		validateAnnotationValue( -- 333
			schema.default, -- 333
			"default", -- 333
			appendPointer(schemaPath, "default"), -- 333
			depth + 1, -- 333
			state -- 333
		) -- 333
	end -- 333
	if schema.examples ~= nil then -- 333
		if not __TS__ArrayIsArray(schema.examples) then -- 333
			addError( -- 337
				state, -- 337
				"examples", -- 337
				"", -- 337
				appendPointer(schemaPath, "examples"), -- 337
				"examples must be an array" -- 337
			) -- 337
		else -- 337
			validateAnnotationValue( -- 339
				schema.examples, -- 339
				"examples", -- 339
				appendPointer(schemaPath, "examples"), -- 339
				depth + 1, -- 339
				state -- 339
			) -- 339
		end -- 339
	end -- 339
	if schema.type ~= nil then -- 339
		local types = __TS__ArrayIsArray(schema.type) and schema.type or ({schema.type}) -- 344
		if #types == 0 then -- 344
			addError( -- 346
				state, -- 346
				"type", -- 346
				"", -- 346
				appendPointer(schemaPath, "type"), -- 346
				"type array must not be empty" -- 346
			) -- 346
		end -- 346
		local seen = {} -- 348
		do -- 348
			local i = 0 -- 349
			while i < #types do -- 349
				local item = types[i + 1] -- 350
				if type(item) ~= "string" or __TS__ArrayIndexOf(JSON_SCHEMA_TYPES, item) < 0 then -- 350
					addError( -- 352
						state, -- 352
						"type", -- 352
						"", -- 352
						appendPointer( -- 352
							appendPointer(schemaPath, "type"), -- 352
							i -- 352
						), -- 352
						"unsupported JSON Schema type: " .. tostring(item) -- 352
					) -- 352
				elseif __TS__ArrayIndexOf(seen, item) >= 0 then -- 352
					addError( -- 354
						state, -- 354
						"type", -- 354
						"", -- 354
						appendPointer(schemaPath, "type"), -- 354
						"duplicate JSON Schema type: " .. item -- 354
					) -- 354
				else -- 354
					seen[#seen + 1] = item -- 356
				end -- 356
				i = i + 1 -- 349
			end -- 349
		end -- 349
	end -- 349
	if schema.enum ~= nil then -- 349
		if not __TS__ArrayIsArray(schema.enum) or #schema.enum == 0 then -- 349
			addError( -- 363
				state, -- 363
				"enum", -- 363
				"", -- 363
				appendPointer(schemaPath, "enum"), -- 363
				"enum must be a non-empty array" -- 363
			) -- 363
		else -- 363
			validateAnnotationValue( -- 365
				schema.enum, -- 365
				"enum", -- 365
				appendPointer(schemaPath, "enum"), -- 365
				depth + 1, -- 365
				state -- 365
			) -- 365
			do -- 365
				local i = 0 -- 366
				while i < #schema.enum do -- 366
					do -- 366
						local j = 0 -- 367
						while j < i do -- 367
							if deepEqual(schema.enum[i + 1], schema.enum[j + 1]) then -- 367
								addError( -- 369
									state, -- 369
									"enum", -- 369
									"", -- 369
									appendPointer( -- 369
										appendPointer(schemaPath, "enum"), -- 369
										i -- 369
									), -- 369
									"enum values must be unique" -- 369
								) -- 369
								break -- 370
							end -- 370
							j = j + 1 -- 367
						end -- 367
					end -- 367
					i = i + 1 -- 366
				end -- 366
			end -- 366
		end -- 366
	end -- 366
	if schema.const ~= nil then -- 366
		validateAnnotationValue( -- 377
			schema.const, -- 377
			"const", -- 377
			appendPointer(schemaPath, "const"), -- 377
			depth + 1, -- 377
			state -- 377
		) -- 377
	end -- 377
	if schema.properties ~= nil then -- 377
		if not isRecord(schema.properties) then -- 377
			addError( -- 382
				state, -- 382
				"properties", -- 382
				"", -- 382
				appendPointer(schemaPath, "properties"), -- 382
				"properties must be an object of schemas" -- 382
			) -- 382
		else -- 382
			for ____, key in ipairs(__TS__ObjectKeys(schema.properties)) do -- 384
				validateSchemaNode( -- 385
					schema.properties[key], -- 386
					appendPointer( -- 387
						appendPointer(schemaPath, "properties"), -- 387
						key -- 387
					), -- 387
					depth + 1, -- 388
					state, -- 389
					stack -- 390
				) -- 390
			end -- 390
		end -- 390
	end -- 390
	if schema.required ~= nil then -- 390
		if not __TS__ArrayIsArray(schema.required) then -- 390
			addError( -- 397
				state, -- 397
				"required", -- 397
				"", -- 397
				appendPointer(schemaPath, "required"), -- 397
				"required must be an array of unique strings" -- 397
			) -- 397
		else -- 397
			local seen = {} -- 399
			do -- 399
				local i = 0 -- 400
				while i < #schema.required do -- 400
					local item = schema.required[i + 1] -- 401
					if type(item) ~= "string" or __TS__ArrayIndexOf(seen, item) >= 0 then -- 401
						addError( -- 403
							state, -- 403
							"required", -- 403
							"", -- 403
							appendPointer( -- 403
								appendPointer(schemaPath, "required"), -- 403
								i -- 403
							), -- 403
							"required entries must be unique strings" -- 403
						) -- 403
					else -- 403
						seen[#seen + 1] = item -- 405
					end -- 405
					i = i + 1 -- 400
				end -- 400
			end -- 400
		end -- 400
	end -- 400
	if schema.additionalProperties ~= nil then -- 400
		validateSchemaNode( -- 411
			schema.additionalProperties, -- 411
			appendPointer(schemaPath, "additionalProperties"), -- 411
			depth + 1, -- 411
			state, -- 411
			stack -- 411
		) -- 411
	end -- 411
	if schema.items ~= nil then -- 411
		validateSchemaNode( -- 414
			schema.items, -- 414
			appendPointer(schemaPath, "items"), -- 414
			depth + 1, -- 414
			state, -- 414
			stack -- 414
		) -- 414
	end -- 414
	if schema["not"] ~= nil then -- 414
		validateSchemaNode( -- 417
			schema["not"], -- 417
			appendPointer(schemaPath, "not"), -- 417
			depth + 1, -- 417
			state, -- 417
			stack -- 417
		) -- 417
	end -- 417
	for ____, keyword in ipairs({"minItems", "maxItems", "minLength", "maxLength"}) do -- 420
		local value = schema[keyword] -- 421
		if value ~= nil and not isNonNegativeInteger(value) then -- 421
			addError( -- 423
				state, -- 423
				keyword, -- 423
				"", -- 423
				appendPointer(schemaPath, keyword), -- 423
				keyword .. " must be a non-negative integer" -- 423
			) -- 423
		end -- 423
	end -- 423
	if isNonNegativeInteger(schema.minItems) and isNonNegativeInteger(schema.maxItems) and schema.minItems > schema.maxItems then -- 423
		addError( -- 427
			state, -- 427
			"maxItems", -- 427
			"", -- 427
			appendPointer(schemaPath, "maxItems"), -- 427
			"maxItems must be greater than or equal to minItems" -- 427
		) -- 427
	end -- 427
	if isNonNegativeInteger(schema.minLength) and isNonNegativeInteger(schema.maxLength) and schema.minLength > schema.maxLength then -- 427
		addError( -- 430
			state, -- 430
			"maxLength", -- 430
			"", -- 430
			appendPointer(schemaPath, "maxLength"), -- 430
			"maxLength must be greater than or equal to minLength" -- 430
		) -- 430
	end -- 430
	for ____, keyword in ipairs({"minimum", "maximum", "exclusiveMinimum", "exclusiveMaximum"}) do -- 432
		local value = schema[keyword] -- 433
		if value ~= nil and not isFiniteNumber(value) then -- 433
			addError( -- 435
				state, -- 435
				keyword, -- 435
				"", -- 435
				appendPointer(schemaPath, keyword), -- 435
				keyword .. " must be a finite number" -- 435
			) -- 435
		end -- 435
	end -- 435
	if isFiniteNumber(schema.minimum) and isFiniteNumber(schema.maximum) and schema.minimum > schema.maximum then -- 435
		addError( -- 439
			state, -- 439
			"maximum", -- 439
			"", -- 439
			appendPointer(schemaPath, "maximum"), -- 439
			"maximum must be greater than or equal to minimum" -- 439
		) -- 439
	end -- 439
	if isFiniteNumber(schema.exclusiveMinimum) and isFiniteNumber(schema.exclusiveMaximum) and schema.exclusiveMinimum >= schema.exclusiveMaximum then -- 439
		addError( -- 442
			state, -- 442
			"exclusiveMaximum", -- 442
			"", -- 442
			appendPointer(schemaPath, "exclusiveMaximum"), -- 442
			"exclusiveMaximum must be greater than exclusiveMinimum" -- 442
		) -- 442
	end -- 442
	if schema.allOf ~= nil then -- 442
		validateSchemaArray( -- 445
			schema.allOf, -- 445
			"allOf", -- 445
			appendPointer(schemaPath, "allOf"), -- 445
			depth, -- 445
			state, -- 445
			stack -- 445
		) -- 445
	end -- 445
	if schema.anyOf ~= nil then -- 445
		validateSchemaArray( -- 446
			schema.anyOf, -- 446
			"anyOf", -- 446
			appendPointer(schemaPath, "anyOf"), -- 446
			depth, -- 446
			state, -- 446
			stack -- 446
		) -- 446
	end -- 446
	if schema.oneOf ~= nil then -- 446
		validateSchemaArray( -- 447
			schema.oneOf, -- 447
			"oneOf", -- 447
			appendPointer(schemaPath, "oneOf"), -- 447
			depth, -- 447
			state, -- 447
			stack -- 447
		) -- 447
	end -- 447
	table.remove(stack) -- 449
end -- 449
JSON_SCHEMA_TYPES = { -- 74
	"null", -- 75
	"boolean", -- 76
	"number", -- 77
	"integer", -- 78
	"string", -- 79
	"array", -- 80
	"object" -- 81
} -- 81
SUPPORTED_KEYWORDS = { -- 84
	"$schema", -- 85
	"title", -- 86
	"description", -- 87
	"default", -- 88
	"examples", -- 89
	"type", -- 90
	"enum", -- 91
	"const", -- 92
	"properties", -- 93
	"required", -- 94
	"additionalProperties", -- 95
	"items", -- 96
	"minItems", -- 97
	"maxItems", -- 98
	"minLength", -- 99
	"maxLength", -- 100
	"minimum", -- 101
	"maximum", -- 102
	"exclusiveMinimum", -- 103
	"exclusiveMaximum", -- 104
	"allOf", -- 105
	"anyOf", -- 106
	"oneOf", -- 107
	"not" -- 108
} -- 108
local function toResult(state) -- 146
	return {valid = #state.errors == 0 and not state.truncated, errors = state.errors, truncated = state.truncated} -- 147
end -- 146
local function getStringLength(value) -- 178
	local length = utf8.len(value) -- 179
	return length or #value -- 180
end -- 178
local function matchesType(value, expected) -- 452
	if expected == "null" then -- 452
		return isJsonNull(value) -- 453
	end -- 453
	if expected == "boolean" then -- 453
		return type(value) == "boolean" -- 454
	end -- 454
	if expected == "number" then -- 454
		return isFiniteNumber(value) -- 455
	end -- 455
	if expected == "integer" then -- 455
		return isFiniteNumber(value) and math.floor(value) == value -- 456
	end -- 456
	if expected == "string" then -- 456
		return type(value) == "string" -- 457
	end -- 457
	if expected == "array" then -- 457
		return __TS__ArrayIsArray(value) -- 458
	end -- 458
	return isRecord(value) -- 459
end -- 452
local function validateInstanceNode(schema, value, instancePath, schemaPath, depth, state) -- 462
	if state.truncated then -- 462
		return -- 470
	end -- 470
	if depth > state.limits.maxDepth then -- 470
		addError( -- 472
			state, -- 472
			"schema", -- 472
			instancePath, -- 472
			schemaPath, -- 472
			"validation exceeds maximum depth " .. tostring(state.limits.maxDepth) -- 472
		) -- 472
		return -- 473
	end -- 473
	if schema == true then -- 473
		return -- 475
	end -- 475
	if schema == false then -- 475
		addError( -- 477
			state, -- 477
			"falseSchema", -- 477
			instancePath, -- 477
			schemaPath, -- 477
			"value is rejected by false schema" -- 477
		) -- 477
		return -- 478
	end -- 478
	if schema.type ~= nil then -- 478
		local types = __TS__ArrayIsArray(schema.type) and schema.type or ({schema.type}) -- 482
		local matched = false -- 483
		for ____, expected in ipairs(types) do -- 484
			if matchesType(value, expected) then -- 484
				matched = true -- 486
				break -- 487
			end -- 487
		end -- 487
		if not matched then -- 487
			addError( -- 491
				state, -- 491
				"type", -- 491
				instancePath, -- 491
				appendPointer(schemaPath, "type"), -- 491
				"expected type " .. table.concat(types, " or ") -- 491
			) -- 491
			return -- 492
		end -- 492
	end -- 492
	if schema.enum ~= nil then -- 492
		local matched = false -- 497
		for ____, item in ipairs(schema.enum) do -- 498
			if deepEqual(value, item) then -- 498
				matched = true -- 500
				break -- 501
			end -- 501
		end -- 501
		if not matched then -- 501
			addError( -- 504
				state, -- 504
				"enum", -- 504
				instancePath, -- 504
				appendPointer(schemaPath, "enum"), -- 504
				"value is not one of the allowed enum values" -- 504
			) -- 504
		end -- 504
	end -- 504
	if schema.const ~= nil and not deepEqual(value, schema.const) then -- 504
		addError( -- 507
			state, -- 507
			"const", -- 507
			instancePath, -- 507
			appendPointer(schemaPath, "const"), -- 507
			"value does not equal const" -- 507
		) -- 507
	end -- 507
	if isRecord(value) then -- 507
		local properties = isRecord(schema.properties) and schema.properties or ({}) -- 511
		for ____, name in ipairs(schema.required or ({})) do -- 512
			if value[name] == nil then -- 512
				addError( -- 514
					state, -- 514
					"required", -- 514
					instancePath, -- 514
					appendPointer(schemaPath, "required"), -- 514
					"required property is missing: " .. name -- 514
				) -- 514
			end -- 514
		end -- 514
		for ____, key in ipairs(__TS__ObjectKeys(value)) do -- 517
			local childSchema = properties[key] -- 518
			if childSchema ~= nil then -- 518
				validateInstanceNode( -- 520
					childSchema, -- 521
					value[key], -- 522
					appendPointer(instancePath, key), -- 523
					appendPointer( -- 524
						appendPointer(schemaPath, "properties"), -- 524
						key -- 524
					), -- 524
					depth + 1, -- 525
					state -- 526
				) -- 526
			elseif schema.additionalProperties ~= nil then -- 526
				validateInstanceNode( -- 529
					schema.additionalProperties, -- 530
					value[key], -- 531
					appendPointer(instancePath, key), -- 532
					appendPointer(schemaPath, "additionalProperties"), -- 533
					depth + 1, -- 534
					state -- 535
				) -- 535
			end -- 535
		end -- 535
	end -- 535
	if __TS__ArrayIsArray(value) then -- 535
		if schema.minItems ~= nil and #value < schema.minItems then -- 535
			addError( -- 543
				state, -- 543
				"minItems", -- 543
				instancePath, -- 543
				appendPointer(schemaPath, "minItems"), -- 543
				("array must contain at least " .. tostring(schema.minItems)) .. " items" -- 543
			) -- 543
		end -- 543
		if schema.maxItems ~= nil and #value > schema.maxItems then -- 543
			addError( -- 546
				state, -- 546
				"maxItems", -- 546
				instancePath, -- 546
				appendPointer(schemaPath, "maxItems"), -- 546
				("array must contain at most " .. tostring(schema.maxItems)) .. " items" -- 546
			) -- 546
		end -- 546
		if schema.items ~= nil then -- 546
			do -- 546
				local i = 0 -- 549
				while i < #value do -- 549
					validateInstanceNode( -- 550
						schema.items, -- 550
						value[i + 1], -- 550
						appendPointer(instancePath, i), -- 550
						appendPointer(schemaPath, "items"), -- 550
						depth + 1, -- 550
						state -- 550
					) -- 550
					i = i + 1 -- 549
				end -- 549
			end -- 549
		end -- 549
	end -- 549
	if type(value) == "string" then -- 549
		local length = getStringLength(value) -- 556
		if schema.minLength ~= nil and length < schema.minLength then -- 556
			addError( -- 558
				state, -- 558
				"minLength", -- 558
				instancePath, -- 558
				appendPointer(schemaPath, "minLength"), -- 558
				("string must contain at least " .. tostring(schema.minLength)) .. " characters" -- 558
			) -- 558
		end -- 558
		if schema.maxLength ~= nil and length > schema.maxLength then -- 558
			addError( -- 561
				state, -- 561
				"maxLength", -- 561
				instancePath, -- 561
				appendPointer(schemaPath, "maxLength"), -- 561
				("string must contain at most " .. tostring(schema.maxLength)) .. " characters" -- 561
			) -- 561
		end -- 561
	end -- 561
	if isFiniteNumber(value) then -- 561
		if schema.minimum ~= nil and value < schema.minimum then -- 561
			addError( -- 567
				state, -- 567
				"minimum", -- 567
				instancePath, -- 567
				appendPointer(schemaPath, "minimum"), -- 567
				"number must be greater than or equal to " .. tostring(schema.minimum) -- 567
			) -- 567
		end -- 567
		if schema.maximum ~= nil and value > schema.maximum then -- 567
			addError( -- 570
				state, -- 570
				"maximum", -- 570
				instancePath, -- 570
				appendPointer(schemaPath, "maximum"), -- 570
				"number must be less than or equal to " .. tostring(schema.maximum) -- 570
			) -- 570
		end -- 570
		if schema.exclusiveMinimum ~= nil and value <= schema.exclusiveMinimum then -- 570
			addError( -- 573
				state, -- 573
				"exclusiveMinimum", -- 573
				instancePath, -- 573
				appendPointer(schemaPath, "exclusiveMinimum"), -- 573
				"number must be greater than " .. tostring(schema.exclusiveMinimum) -- 573
			) -- 573
		end -- 573
		if schema.exclusiveMaximum ~= nil and value >= schema.exclusiveMaximum then -- 573
			addError( -- 576
				state, -- 576
				"exclusiveMaximum", -- 576
				instancePath, -- 576
				appendPointer(schemaPath, "exclusiveMaximum"), -- 576
				"number must be less than " .. tostring(schema.exclusiveMaximum) -- 576
			) -- 576
		end -- 576
	end -- 576
	do -- 576
		local i = 0 -- 580
		while i < #(schema.allOf or ({})) do -- 580
			validateInstanceNode( -- 581
				schema.allOf[i + 1], -- 581
				value, -- 581
				instancePath, -- 581
				appendPointer( -- 581
					appendPointer(schemaPath, "allOf"), -- 581
					i -- 581
				), -- 581
				depth + 1, -- 581
				state -- 581
			) -- 581
			i = i + 1 -- 580
		end -- 580
	end -- 580
	if schema.anyOf ~= nil then -- 580
		local matches = 0 -- 584
		do -- 584
			local i = 0 -- 585
			while i < #schema.anyOf do -- 585
				local branch = createState(state.limits) -- 586
				validateInstanceNode( -- 587
					schema.anyOf[i + 1], -- 587
					value, -- 587
					instancePath, -- 587
					appendPointer( -- 587
						appendPointer(schemaPath, "anyOf"), -- 587
						i -- 587
					), -- 587
					depth + 1, -- 587
					branch -- 587
				) -- 587
				if #branch.errors == 0 and not branch.truncated then -- 587
					matches = matches + 1 -- 588
				end -- 588
				i = i + 1 -- 585
			end -- 585
		end -- 585
		if matches == 0 then -- 585
			addError( -- 590
				state, -- 590
				"anyOf", -- 590
				instancePath, -- 590
				appendPointer(schemaPath, "anyOf"), -- 590
				"value must match at least one anyOf schema" -- 590
			) -- 590
		end -- 590
	end -- 590
	if schema.oneOf ~= nil then -- 590
		local matches = 0 -- 593
		do -- 593
			local i = 0 -- 594
			while i < #schema.oneOf do -- 594
				local branch = createState(state.limits) -- 595
				validateInstanceNode( -- 596
					schema.oneOf[i + 1], -- 596
					value, -- 596
					instancePath, -- 596
					appendPointer( -- 596
						appendPointer(schemaPath, "oneOf"), -- 596
						i -- 596
					), -- 596
					depth + 1, -- 596
					branch -- 596
				) -- 596
				if #branch.errors == 0 and not branch.truncated then -- 596
					matches = matches + 1 -- 597
				end -- 597
				i = i + 1 -- 594
			end -- 594
		end -- 594
		if matches ~= 1 then -- 594
			addError( -- 599
				state, -- 599
				"oneOf", -- 599
				instancePath, -- 599
				appendPointer(schemaPath, "oneOf"), -- 599
				"value must match exactly one oneOf schema; matched " .. tostring(matches) -- 599
			) -- 599
		end -- 599
	end -- 599
	if schema["not"] ~= nil then -- 599
		local branch = createState(state.limits) -- 602
		validateInstanceNode( -- 603
			schema["not"], -- 603
			value, -- 603
			instancePath, -- 603
			appendPointer(schemaPath, "not"), -- 603
			depth + 1, -- 603
			branch -- 603
		) -- 603
		if #branch.errors == 0 and not branch.truncated then -- 603
			addError( -- 605
				state, -- 605
				"not", -- 605
				instancePath, -- 605
				appendPointer(schemaPath, "not"), -- 605
				"value must not match the not schema" -- 605
			) -- 605
		end -- 605
	end -- 605
end -- 462
function ____exports.validateJsonSchema(schema, options) -- 610
	local state = createState(options) -- 611
	validateSchemaNode( -- 612
		schema, -- 612
		"", -- 612
		0, -- 612
		state, -- 612
		{} -- 612
	) -- 612
	return toResult(state) -- 613
end -- 610
function ____exports.compileJsonSchema(schema, options) -- 616
	local schemaResult = ____exports.validateJsonSchema(schema, options) -- 617
	if not schemaResult.valid then -- 617
		return {success = false, errors = schemaResult.errors, truncated = schemaResult.truncated} -- 619
	end -- 619
	local typedSchema = schema -- 621
	local limits = normalizeLimits(options) -- 622
	return { -- 623
		success = true, -- 624
		validator = { -- 625
			schema = typedSchema, -- 626
			validate = function(self, value) -- 627
				local state = {errors = {}, truncated = false, limits = limits} -- 628
				validateJsonData( -- 629
					value, -- 629
					"", -- 629
					0, -- 629
					state, -- 629
					{} -- 629
				) -- 629
				if #state.errors == 0 and not state.truncated then -- 629
					validateInstanceNode( -- 631
						typedSchema, -- 631
						value, -- 631
						"", -- 631
						"", -- 631
						0, -- 631
						state -- 631
					) -- 631
				end -- 631
				return toResult(state) -- 633
			end -- 627
		} -- 627
	} -- 627
end -- 616
function ____exports.validateJsonValue(schema, value, options) -- 639
	local compiled = ____exports.compileJsonSchema(schema, options) -- 644
	if not compiled.success then -- 644
		return {valid = false, errors = compiled.errors, truncated = compiled.truncated} -- 646
	end -- 646
	return compiled.validator:validate(value) -- 648
end -- 639
return ____exports -- 639