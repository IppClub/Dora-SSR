-- [yue]: Script/Lib/BodyEx.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local Struct = require("Utils").Struct -- 10
local type <const> = type -- 11
local ipairs <const> = ipairs -- 11
local load <const> = load -- 11
local Vec2 <const> = Vec2 -- 11
local BodyDef <const> = BodyDef -- 11
local JointDef <const> = JointDef -- 11
local Dictionary <const> = Dictionary -- 11
local Node <const> = Node -- 11
local tolua <const> = tolua -- 11
local Body <const> = Body -- 11
local Playable <const> = Playable -- 11
local Sprite <const> = Sprite -- 11
local Joint <const> = Joint -- 11
Struct.Array() -- 13
Struct.Phyx.Rect("name", "type", "position", "angle", "center", "size", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 15
Struct.Phyx.Disk("name", "type", "position", "angle", "center", "radius", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 36
Struct.Phyx.Poly("name", "type", "position", "angle", "vertices", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 57
Struct.Phyx.Chain("name", "type", "position", "angle", "vertices", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "subShapes", "face", "facePos") -- 77
Struct.Phyx.SubRect("center", "angle", "size", "density", "friction", "restitution", "sensor", "sensorTag") -- 94
Struct.Phyx.SubDisk("center", "radius", "density", "friction", "restitution", "sensor", "sensorTag") -- 104
Struct.Phyx.SubPoly("vertices", "density", "friction", "restitution", "sensor", "sensorTag") -- 113
Struct.Phyx.SubChain("vertices", "friction", "restitution") -- 121
Struct.Phyx.Distance("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "frequency", "damping") -- 126
Struct.Phyx.Friction("name", "collision", "bodyA", "bodyB", "worldPos", "maxForce", "maxTorque") -- 136
Struct.Phyx.Gear("name", "collision", "jointA", "jointB", "ratio") -- 145
Struct.Phyx.Spring("name", "collision", "bodyA", "bodyB", "linearOffset", "angularOffset", "maxForce", "maxTorque", "correctionFactor") -- 152
Struct.Phyx.Prismatic("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "lowerTranslation", "upperTranslation", "maxMotorForce", "motorSpeed") -- 163
Struct.Phyx.Pulley("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "groundAnchorA", "groundAnchorB", "ratio") -- 175
Struct.Phyx.Revolute("name", "collision", "bodyA", "bodyB", "worldPos", "lowerAngle", "upperAngle", "maxMotorTorque", "motorSpeed") -- 186
Struct.Phyx.Rope("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "maxLength") -- 197
Struct.Phyx.Weld("name", "collision", "bodyA", "bodyB", "worldPos", "frequency", "damping") -- 206
Struct.Phyx.Wheel("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "maxMotorTorque", "motorSpeed", "frequency", "damping") -- 215
local loadFuncs = nil -- 228
local fieldDefs = { -- 230
	["Array"] = { }, -- 230
	["Phyx.Rect"] = { -- 231
		"name", -- 231
		"type", -- 231
		"position", -- 231
		"angle", -- 231
		"center", -- 231
		"size", -- 231
		"density", -- 231
		"friction", -- 231
		"restitution", -- 231
		"linearDamping", -- 231
		"angularDamping", -- 231
		"fixedRotation", -- 231
		"linearAcceleration", -- 231
		"bullet", -- 231
		"sensor", -- 231
		"sensorTag", -- 231
		"subShapes", -- 231
		"face", -- 231
		"facePos" -- 231
	}, -- 231
	["Phyx.Disk"] = { -- 232
		"name", -- 232
		"type", -- 232
		"position", -- 232
		"angle", -- 232
		"center", -- 232
		"radius", -- 232
		"density", -- 232
		"friction", -- 232
		"restitution", -- 232
		"linearDamping", -- 232
		"angularDamping", -- 232
		"fixedRotation", -- 232
		"linearAcceleration", -- 232
		"bullet", -- 232
		"sensor", -- 232
		"sensorTag", -- 232
		"subShapes", -- 232
		"face", -- 232
		"facePos" -- 232
	}, -- 232
	["Phyx.Poly"] = { -- 233
		"name", -- 233
		"type", -- 233
		"position", -- 233
		"angle", -- 233
		"vertices", -- 233
		"density", -- 233
		"friction", -- 233
		"restitution", -- 233
		"linearDamping", -- 233
		"angularDamping", -- 233
		"fixedRotation", -- 233
		"linearAcceleration", -- 233
		"bullet", -- 233
		"sensor", -- 233
		"sensorTag", -- 233
		"subShapes", -- 233
		"face", -- 233
		"facePos" -- 233
	}, -- 233
	["Phyx.Chain"] = { -- 234
		"name", -- 234
		"type", -- 234
		"position", -- 234
		"angle", -- 234
		"vertices", -- 234
		"friction", -- 234
		"restitution", -- 234
		"linearDamping", -- 234
		"angularDamping", -- 234
		"fixedRotation", -- 234
		"linearAcceleration", -- 234
		"bullet", -- 234
		"subShapes", -- 234
		"face", -- 234
		"facePos" -- 234
	}, -- 234
	["Phyx.SubRect"] = { -- 235
		"center", -- 235
		"angle", -- 235
		"size", -- 235
		"density", -- 235
		"friction", -- 235
		"restitution", -- 235
		"sensor", -- 235
		"sensorTag" -- 235
	}, -- 235
	["Phyx.SubDisk"] = { -- 236
		"center", -- 236
		"radius", -- 236
		"density", -- 236
		"friction", -- 236
		"restitution", -- 236
		"sensor", -- 236
		"sensorTag" -- 236
	}, -- 236
	["Phyx.SubPoly"] = { -- 237
		"vertices", -- 237
		"density", -- 237
		"friction", -- 237
		"restitution", -- 237
		"sensor", -- 237
		"sensorTag" -- 237
	}, -- 237
	["Phyx.SubChain"] = { -- 238
		"vertices", -- 238
		"friction", -- 238
		"restitution" -- 238
	}, -- 238
	["Phyx.Distance"] = { -- 239
		"name", -- 239
		"collision", -- 239
		"bodyA", -- 239
		"bodyB", -- 239
		"anchorA", -- 239
		"anchorB", -- 239
		"frequency", -- 239
		"damping" -- 239
	}, -- 239
	["Phyx.Friction"] = { -- 240
		"name", -- 240
		"collision", -- 240
		"bodyA", -- 240
		"bodyB", -- 240
		"worldPos", -- 240
		"maxForce", -- 240
		"maxTorque" -- 240
	}, -- 240
	["Phyx.Gear"] = { -- 241
		"name", -- 241
		"collision", -- 241
		"jointA", -- 241
		"jointB", -- 241
		"ratio" -- 241
	}, -- 241
	["Phyx.Spring"] = { -- 242
		"name", -- 242
		"collision", -- 242
		"bodyA", -- 242
		"bodyB", -- 242
		"linearOffset", -- 242
		"angularOffset", -- 242
		"maxForce", -- 242
		"maxTorque", -- 242
		"correctionFactor" -- 242
	}, -- 242
	["Phyx.Prismatic"] = { -- 243
		"name", -- 243
		"collision", -- 243
		"bodyA", -- 243
		"bodyB", -- 243
		"worldPos", -- 243
		"axis", -- 243
		"lowerTranslation", -- 243
		"upperTranslation", -- 243
		"maxMotorForce", -- 243
		"motorSpeed" -- 243
	}, -- 243
	["Phyx.Pulley"] = { -- 244
		"name", -- 244
		"collision", -- 244
		"bodyA", -- 244
		"bodyB", -- 244
		"anchorA", -- 244
		"anchorB", -- 244
		"groundAnchorA", -- 244
		"groundAnchorB", -- 244
		"ratio" -- 244
	}, -- 244
	["Phyx.Revolute"] = { -- 245
		"name", -- 245
		"collision", -- 245
		"bodyA", -- 245
		"bodyB", -- 245
		"worldPos", -- 245
		"lowerAngle", -- 245
		"upperAngle", -- 245
		"maxMotorTorque", -- 245
		"motorSpeed" -- 245
	}, -- 245
	["Phyx.Rope"] = { -- 246
		"name", -- 246
		"collision", -- 246
		"bodyA", -- 246
		"bodyB", -- 246
		"anchorA", -- 246
		"anchorB", -- 246
		"maxLength" -- 246
	}, -- 246
	["Phyx.Weld"] = { -- 247
		"name", -- 247
		"collision", -- 247
		"bodyA", -- 247
		"bodyB", -- 247
		"worldPos", -- 247
		"frequency", -- 247
		"damping" -- 247
	}, -- 247
	["Phyx.Wheel"] = { -- 248
		"name", -- 248
		"collision", -- 248
		"bodyA", -- 248
		"bodyB", -- 248
		"worldPos", -- 248
		"axis", -- 248
		"maxMotorTorque", -- 248
		"motorSpeed", -- 248
		"frequency", -- 248
		"damping" -- 248
	} -- 248
} -- 229
local normalizeData -- 250
normalizeData = function(data) -- 250
	if "table" == type(data) then -- 251
		local fields = fieldDefs[data[1]] -- 252
		if fields then -- 252
			for i, key in ipairs(fields) do -- 253
				data[key] = normalizeData(data[i + 1]) -- 254
			end -- 253
		end -- 252
	end -- 251
	return data -- 255
end -- 250
local loadBodyData -- 257
loadBodyData = function(bodyData) -- 257
	local data -- 258
	do -- 258
		local _exp_0 = type(bodyData) -- 258
		if "string" == _exp_0 then -- 259
			local code -- 260
			if bodyData:sub(1, 6) == "return" then -- 260
				code = bodyData -- 260
			else -- 260
				code = "return " .. bodyData -- 260
			end -- 260
			data = (load(code))() -- 261
		elseif "table" == _exp_0 then -- 262
			data = bodyData -- 263
		end -- 258
	end -- 258
	return normalizeData(data) -- 264
end -- 257
local toVec -- 266
toVec = function(value) -- 266
	if not ("table" == type(value)) then -- 267
		return value -- 267
	end -- 267
	if value.x ~= nil and value.y ~= nil then -- 268
		return value -- 268
	end -- 268
	return Vec2(value[1] or 0, value[2] or 0) -- 269
end -- 266
local toVecArray -- 271
toVecArray = function(values) -- 271
	if values.toArray then -- 272
		return values:toArray() -- 272
	end -- 272
	local start -- 273
	if values[1] == "Array" then -- 273
		start = 2 -- 273
	else -- 273
		start = 1 -- 273
	end -- 273
	local _accum_0 = { } -- 274
	local _len_0 = 1 -- 274
	for i = start, #values do -- 274
		_accum_0[_len_0] = toVec(values[i]) -- 274
		_len_0 = _len_0 + 1 -- 274
	end -- 274
	return _accum_0 -- 274
end -- 271
local sizeDims -- 276
sizeDims = function(size) -- 276
	if size.width ~= nil and size.height ~= nil then -- 277
		return size.width, size.height -- 277
	end -- 277
	return size[1] or 0, size[2] or 0 -- 278
end -- 276
local arrayCount -- 280
arrayCount = function(values) -- 280
	if values.count then -- 281
		return values:count() -- 281
	end -- 281
	if values[1] == "Array" then -- 282
		return #values - 1 -- 282
	else -- 282
		return #values -- 282
	end -- 282
end -- 280
local arrayGet -- 284
arrayGet = function(values, index) -- 284
	if values.get then -- 285
		return values:get(index) -- 285
	end -- 285
	if values[1] == "Array" then -- 286
		return values[index + 1] -- 286
	else -- 286
		return values[index] -- 286
	end -- 286
end -- 284
local loadData -- 288
loadData = function(data, item) -- 288
	data = normalizeData(data) -- 289
	return loadFuncs[data[1]](data, item) -- 290
end -- 288
local toDef -- 292
toDef = function(data) -- 292
	local _with_0 = BodyDef() -- 292
	_with_0.type = data.type -- 293
	_with_0.bullet = data.bullet -- 294
	_with_0.linearAcceleration = toVec(data.linearAcceleration) -- 295
	_with_0.fixedRotation = data.fixedRotation -- 296
	_with_0.linearDamping = data.linearDamping -- 297
	_with_0.angularDamping = data.angularDamping -- 298
	_with_0.position = toVec(data.position) -- 299
	_with_0.angle = data.angle -- 300
	_with_0.face = data.face -- 301
	_with_0.facePos = toVec(data.facePos) -- 302
	return _with_0 -- 292
end -- 292
loadFuncs = { -- 305
	["Array"] = function(data, itemDict) -- 305
		for i = 1, arrayCount(data) do -- 306
			loadData(arrayGet(data, i), itemDict) -- 307
		end -- 306
	end, -- 305
	["Phyx.Rect"] = function(data, itemDict) -- 309
		local bodyDef = toDef(data) -- 310
		local width, height = sizeDims(data.size) -- 311
		if data.sensor then -- 312
			bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 313
		else -- 315
			bodyDef:attachPolygon(toVec(data.center), width, height, 0, data.density, data.friction, data.restitution) -- 315
		end -- 312
		do -- 319
			local subShapes = data.subShapes -- 319
			if subShapes then -- 319
				for i = 1, arrayCount(subShapes) do -- 320
					loadData(arrayGet(subShapes, i), bodyDef) -- 321
				end -- 320
			end -- 319
		end -- 319
		itemDict[data.name] = bodyDef -- 322
	end, -- 309
	["Phyx.Disk"] = function(data, itemDict) -- 324
		local bodyDef = toDef(data) -- 325
		if data.sensor then -- 326
			bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 327
		else -- 329
			bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 329
		end -- 326
		do -- 333
			local subShapes = data.subShapes -- 333
			if subShapes then -- 333
				for i = 1, arrayCount(subShapes) do -- 334
					loadData(arrayGet(subShapes, i), bodyDef) -- 335
				end -- 334
			end -- 333
		end -- 333
		itemDict[data.name] = bodyDef -- 336
	end, -- 324
	["Phyx.Poly"] = function(data, itemDict) -- 338
		local bodyDef = toDef(data) -- 339
		if data.sensor then -- 340
			bodyDef:attachPolygonSensor(data.sensorTag, toVecArray(data.vertices)) -- 341
		else -- 343
			bodyDef:attachPolygon(toVecArray(data.vertices), data.density, data.friction, data.restitution) -- 343
		end -- 340
		do -- 347
			local subShapes = data.subShapes -- 347
			if subShapes then -- 347
				for i = 1, arrayCount(subShapes) do -- 348
					loadData(arrayGet(subShapes, i), bodyDef) -- 349
				end -- 348
			end -- 347
		end -- 347
		itemDict[data.name] = bodyDef -- 350
	end, -- 338
	["Phyx.Chain"] = function(data, itemDict) -- 352
		local bodyDef = toDef(data) -- 353
		bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 354
		do -- 355
			local subShapes = data.subShapes -- 355
			if subShapes then -- 355
				for i = 1, arrayCount(subShapes) do -- 356
					loadData(arrayGet(subShapes, i), bodyDef) -- 357
				end -- 356
			end -- 355
		end -- 355
		itemDict[data.name] = bodyDef -- 358
	end, -- 352
	["Phyx.SubRect"] = function(data, bodyDef) -- 360
		local width, height = sizeDims(data.size) -- 361
		if data.sensor then -- 362
			return bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 363
		else -- 365
			return bodyDef:attachPolygon(toVec(data.center), width, height, data.angle, data.density, data.friction, data.restitution) -- 365
		end -- 362
	end, -- 360
	["Phyx.SubDisk"] = function(data, bodyDef) -- 370
		if data.sensor then -- 371
			return bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 372
		else -- 374
			return bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 374
		end -- 371
	end, -- 370
	["Phyx.SubPoly"] = function(data, bodyDef) -- 379
		if data.sensor then -- 380
			return bodyDef:attachPolygonSensor(data.sensorTag, toVecArray(data.vertices)) -- 381
		else -- 383
			return bodyDef:attachPolygon(toVecArray(data.vertices), data.density, data.friction, data.restitution) -- 383
		end -- 380
	end, -- 379
	["Phyx.SubChain"] = function(data, bodyDef) -- 388
		return bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 389
	end, -- 388
	["Phyx.Distance"] = function(data, itemDict) -- 391
		itemDict[data.name] = JointDef:distance(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.frequency, data.damping) -- 392
	end, -- 391
	["Phyx.Friction"] = function(data, itemDict) -- 401
		itemDict[data.name] = JointDef:friction(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.maxForce, data.maxTorque) -- 402
	end, -- 401
	["Phyx.Gear"] = function(data, itemDict) -- 411
		itemDict[data.name] = JointDef:gear(data.collision, data.jointA, data.jointB, data.ratio) -- 412
	end, -- 411
	["Phyx.Spring"] = function(data, itemDict) -- 419
		itemDict[data.name] = JointDef:spring(data.collision, data.bodyA, data.bodyB, toVec(data.linearOffset), data.angularOffset, data.maxForce, data.maxTorque, data.correctionFactor) -- 420
	end, -- 419
	["Phyx.Prismatic"] = function(data, itemDict) -- 431
		itemDict[data.name] = JointDef:prismatic(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), toVec(data.axis), data.lowerTranslation, data.upperTranslation, data.maxMotorForce, data.motorSpeed) -- 432
	end, -- 431
	["Phyx.Pulley"] = function(data, itemDict) -- 444
		itemDict[data.name] = JointDef:pulley(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), toVec(data.groundAnchorA), toVec(data.groundAnchorB), data.ratio) -- 445
	end, -- 444
	["Phyx.Revolute"] = function(data, itemDict) -- 456
		itemDict[data.name] = JointDef:revolute(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.lowerAngle, data.upperAngle, data.maxMotorTorque, data.motorSpeed) -- 457
	end, -- 456
	["Phyx.Rope"] = function(data, itemDict) -- 468
		itemDict[data.name] = JointDef:rope(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.maxLength) -- 469
	end, -- 468
	["Phyx.Weld"] = function(data, itemDict) -- 478
		itemDict[data.name] = JointDef:weld(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.frequency, data.damping) -- 479
	end, -- 478
	["Phyx.Wheel"] = function(data, itemDict) -- 488
		itemDict[data.name] = JointDef:wheel(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), toVec(data.axis), data.maxMotorTorque, data.motorSpeed, data.frequency, data.damping) -- 489
	end -- 488
} -- 304
_module_0 = function(bodyData, world, pos, angle) -- 501
	local itemDict = Dictionary() -- 502
	loadData(loadBodyData(bodyData), itemDict) -- 503
	local root = Node() -- 504
	local items = root.data -- 505
	local center = Vec2.zero -- 506
	itemDict:each(function(itemDef, key) -- 507
		if "BodyDef" == tolua.type(itemDef) then -- 508
			local body = Body(itemDef, world, pos, angle) -- 509
			body.owner = root -- 510
			root:addChild(body) -- 511
			local faceStr = itemDef.face -- 512
			if faceStr ~= "" then -- 513
				local face -- 514
				if faceStr:match(":") then -- 514
					face = Playable(faceStr) -- 515
				else -- 517
					face = Sprite(faceStr) -- 517
				end -- 514
				if face then -- 518
					face.position = itemDef.facePos -- 519
					body:addChild(face) -- 520
				end -- 518
			end -- 513
			items[key] = body -- 521
		else -- 523
			if center then -- 523
				itemDef.center = center -- 524
				itemDef.position = pos -- 525
				itemDef.angle = angle -- 526
			end -- 523
			local joint = Joint(itemDef, items) -- 527
			if joint then -- 527
				items[key] = joint -- 528
			end -- 527
		end -- 508
	end) -- 507
	return root -- 529
end -- 501
return _module_0 -- 1
