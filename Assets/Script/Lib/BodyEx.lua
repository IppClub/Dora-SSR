-- [yue]: Script/Lib/BodyEx.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local Struct = require("Utils").Struct -- 10
local type <const> = type -- 11
local ipairs <const> = ipairs -- 11
local Content <const> = Content -- 11
local require <const> = require -- 11
local error <const> = error -- 11
local tostring <const> = tostring -- 11
local Vec2 <const> = Vec2 -- 11
local math <const> = math -- 11
local BodyDef <const> = BodyDef -- 11
local JointDef <const> = JointDef -- 11
local Node <const> = Node -- 11
local Dictionary <const> = Dictionary -- 11
local xpcall <const> = xpcall -- 11
local tolua <const> = tolua -- 11
local Body <const> = Body -- 11
local Playable <const> = Playable -- 11
local Sprite <const> = Sprite -- 11
local Joint <const> = Joint -- 11
local Log <const> = Log -- 11
Struct.Array() -- 13
Struct.Phyx.Rect("name", "type", "position", "angle", "center", "size", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos", "faceScale") -- 15
Struct.Phyx.Disk("name", "type", "position", "angle", "center", "radius", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos", "faceScale") -- 37
Struct.Phyx.Poly("name", "type", "position", "angle", "vertices", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos", "faceScale") -- 59
Struct.Phyx.Chain("name", "type", "position", "angle", "vertices", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "subShapes", "face", "facePos", "faceScale") -- 80
Struct.Phyx.SubRect("center", "angle", "size", "density", "friction", "restitution", "sensor", "sensorTag") -- 98
Struct.Phyx.SubDisk("center", "radius", "density", "friction", "restitution", "sensor", "sensorTag") -- 108
Struct.Phyx.SubPoly("vertices", "density", "friction", "restitution", "sensor", "sensorTag") -- 117
Struct.Phyx.SubChain("vertices", "friction", "restitution") -- 125
Struct.Phyx.Distance("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "frequency", "damping") -- 130
Struct.Phyx.Friction("name", "collision", "bodyA", "bodyB", "worldPos", "maxForce", "maxTorque") -- 140
Struct.Phyx.Gear("name", "collision", "jointA", "jointB", "ratio") -- 149
Struct.Phyx.Spring("name", "collision", "bodyA", "bodyB", "linearOffset", "angularOffset", "maxForce", "maxTorque", "correctionFactor") -- 156
Struct.Phyx.Prismatic("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "lowerTranslation", "upperTranslation", "maxMotorForce", "motorSpeed") -- 167
Struct.Phyx.Pulley("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "groundAnchorA", "groundAnchorB", "ratio") -- 179
Struct.Phyx.Revolute("name", "collision", "bodyA", "bodyB", "worldPos", "lowerAngle", "upperAngle", "maxMotorTorque", "motorSpeed") -- 190
Struct.Phyx.Rope("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "maxLength") -- 201
Struct.Phyx.Weld("name", "collision", "bodyA", "bodyB", "worldPos", "frequency", "damping") -- 210
Struct.Phyx.Wheel("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "maxMotorTorque", "motorSpeed", "frequency", "damping") -- 219
local loadFuncs = nil -- 232
local fieldDefs = { -- 234
	["Array"] = { }, -- 234
	["Phyx.Rect"] = { -- 235
		"name", -- 235
		"type", -- 235
		"position", -- 235
		"angle", -- 235
		"center", -- 235
		"size", -- 235
		"density", -- 235
		"friction", -- 235
		"restitution", -- 235
		"linearDamping", -- 235
		"angularDamping", -- 235
		"fixedRotation", -- 235
		"linearAcceleration", -- 235
		"bullet", -- 235
		"sensor", -- 235
		"sensorTag", -- 235
		"subShapes", -- 235
		"face", -- 235
		"facePos", -- 235
		"faceScale" -- 235
	}, -- 235
	["Phyx.Disk"] = { -- 236
		"name", -- 236
		"type", -- 236
		"position", -- 236
		"angle", -- 236
		"center", -- 236
		"radius", -- 236
		"density", -- 236
		"friction", -- 236
		"restitution", -- 236
		"linearDamping", -- 236
		"angularDamping", -- 236
		"fixedRotation", -- 236
		"linearAcceleration", -- 236
		"bullet", -- 236
		"sensor", -- 236
		"sensorTag", -- 236
		"subShapes", -- 236
		"face", -- 236
		"facePos", -- 236
		"faceScale" -- 236
	}, -- 236
	["Phyx.Poly"] = { -- 237
		"name", -- 237
		"type", -- 237
		"position", -- 237
		"angle", -- 237
		"vertices", -- 237
		"density", -- 237
		"friction", -- 237
		"restitution", -- 237
		"linearDamping", -- 237
		"angularDamping", -- 237
		"fixedRotation", -- 237
		"linearAcceleration", -- 237
		"bullet", -- 237
		"sensor", -- 237
		"sensorTag", -- 237
		"subShapes", -- 237
		"face", -- 237
		"facePos", -- 237
		"faceScale" -- 237
	}, -- 237
	["Phyx.Chain"] = { -- 238
		"name", -- 238
		"type", -- 238
		"position", -- 238
		"angle", -- 238
		"vertices", -- 238
		"friction", -- 238
		"restitution", -- 238
		"linearDamping", -- 238
		"angularDamping", -- 238
		"fixedRotation", -- 238
		"linearAcceleration", -- 238
		"bullet", -- 238
		"subShapes", -- 238
		"face", -- 238
		"facePos", -- 238
		"faceScale" -- 238
	}, -- 238
	["Phyx.SubRect"] = { -- 239
		"center", -- 239
		"angle", -- 239
		"size", -- 239
		"density", -- 239
		"friction", -- 239
		"restitution", -- 239
		"sensor", -- 239
		"sensorTag" -- 239
	}, -- 239
	["Phyx.SubDisk"] = { -- 240
		"center", -- 240
		"radius", -- 240
		"density", -- 240
		"friction", -- 240
		"restitution", -- 240
		"sensor", -- 240
		"sensorTag" -- 240
	}, -- 240
	["Phyx.SubPoly"] = { -- 241
		"vertices", -- 241
		"density", -- 241
		"friction", -- 241
		"restitution", -- 241
		"sensor", -- 241
		"sensorTag" -- 241
	}, -- 241
	["Phyx.SubChain"] = { -- 242
		"vertices", -- 242
		"friction", -- 242
		"restitution" -- 242
	}, -- 242
	["Phyx.Distance"] = { -- 243
		"name", -- 243
		"collision", -- 243
		"bodyA", -- 243
		"bodyB", -- 243
		"anchorA", -- 243
		"anchorB", -- 243
		"frequency", -- 243
		"damping" -- 243
	}, -- 243
	["Phyx.Friction"] = { -- 244
		"name", -- 244
		"collision", -- 244
		"bodyA", -- 244
		"bodyB", -- 244
		"worldPos", -- 244
		"maxForce", -- 244
		"maxTorque" -- 244
	}, -- 244
	["Phyx.Gear"] = { -- 245
		"name", -- 245
		"collision", -- 245
		"jointA", -- 245
		"jointB", -- 245
		"ratio" -- 245
	}, -- 245
	["Phyx.Spring"] = { -- 246
		"name", -- 246
		"collision", -- 246
		"bodyA", -- 246
		"bodyB", -- 246
		"linearOffset", -- 246
		"angularOffset", -- 246
		"maxForce", -- 246
		"maxTorque", -- 246
		"correctionFactor" -- 246
	}, -- 246
	["Phyx.Prismatic"] = { -- 247
		"name", -- 247
		"collision", -- 247
		"bodyA", -- 247
		"bodyB", -- 247
		"worldPos", -- 247
		"axis", -- 247
		"lowerTranslation", -- 247
		"upperTranslation", -- 247
		"maxMotorForce", -- 247
		"motorSpeed" -- 247
	}, -- 247
	["Phyx.Pulley"] = { -- 248
		"name", -- 248
		"collision", -- 248
		"bodyA", -- 248
		"bodyB", -- 248
		"anchorA", -- 248
		"anchorB", -- 248
		"groundAnchorA", -- 248
		"groundAnchorB", -- 248
		"ratio" -- 248
	}, -- 248
	["Phyx.Revolute"] = { -- 249
		"name", -- 249
		"collision", -- 249
		"bodyA", -- 249
		"bodyB", -- 249
		"worldPos", -- 249
		"lowerAngle", -- 249
		"upperAngle", -- 249
		"maxMotorTorque", -- 249
		"motorSpeed" -- 249
	}, -- 249
	["Phyx.Rope"] = { -- 250
		"name", -- 250
		"collision", -- 250
		"bodyA", -- 250
		"bodyB", -- 250
		"anchorA", -- 250
		"anchorB", -- 250
		"maxLength" -- 250
	}, -- 250
	["Phyx.Weld"] = { -- 251
		"name", -- 251
		"collision", -- 251
		"bodyA", -- 251
		"bodyB", -- 251
		"worldPos", -- 251
		"frequency", -- 251
		"damping" -- 251
	}, -- 251
	["Phyx.Wheel"] = { -- 252
		"name", -- 252
		"collision", -- 252
		"bodyA", -- 252
		"bodyB", -- 252
		"worldPos", -- 252
		"axis", -- 252
		"maxMotorTorque", -- 252
		"motorSpeed", -- 252
		"frequency", -- 252
		"damping" -- 252
	} -- 252
} -- 233
local normalizeData -- 254
normalizeData = function(data) -- 254
	if "table" == type(data) then -- 255
		local fields = fieldDefs[data[1]] -- 256
		if fields then -- 256
			for i, key in ipairs(fields) do -- 257
				data[key] = normalizeData(data[i + 1]) -- 258
			end -- 257
		end -- 256
	end -- 255
	return data -- 259
end -- 254
local loadBodyData -- 261
loadBodyData = function(bodyData) -- 261
	local data -- 262
	do -- 262
		local _exp_0 = type(bodyData) -- 262
		if "string" == _exp_0 then -- 262
			local file -- 263
			do -- 263
				local _val_0 -- 263
				repeat -- 263
					if Content:exist(bodyData) then -- 264
						_val_0 = bodyData -- 264
						break -- 264
					end -- 264
					file = bodyData .. ".body.lua" -- 265
					if Content:exist(file) then -- 266
						_val_0 = file -- 266
						break -- 266
					end -- 266
				until true -- 263
				file = _val_0 -- 263
			end -- 263
			if file then -- 268
				local fullPath = Content:getFullPath(file) -- 269
				data = require(fullPath) -- 270
			else -- 272
				error("failed to locate body data file: \"" .. tostring(bodyData) .. "\"") -- 272
				data = nil -- 273
			end -- 268
		elseif "table" == _exp_0 then -- 274
			data = bodyData -- 275
		end -- 262
	end -- 262
	return normalizeData(data) -- 276
end -- 261
local toVec -- 278
toVec = function(value) -- 278
	if not ("table" == type(value)) then -- 279
		return value -- 279
	end -- 279
	if value.x ~= nil and value.y ~= nil then -- 280
		return value -- 280
	end -- 280
	return Vec2(value[1] or 0, value[2] or 0) -- 281
end -- 278
local toVecArray -- 283
toVecArray = function(values) -- 283
	if values.toArray then -- 284
		return values:toArray() -- 284
	end -- 284
	local start -- 285
	if values[1] == "Array" then -- 285
		start = 2 -- 285
	else -- 285
		start = 1 -- 285
	end -- 285
	local _accum_0 = { } -- 286
	local _len_0 = 1 -- 286
	for i = start, #values do -- 286
		_accum_0[_len_0] = toVec(values[i]) -- 286
		_len_0 = _len_0 + 1 -- 286
	end -- 286
	return _accum_0 -- 286
end -- 283
local axisToAngle -- 288
axisToAngle = function(value) -- 288
	local axis = toVec(value) -- 289
	if not (axis and axis.x ~= nil and axis.y ~= nil) then -- 290
		return 0 -- 290
	end -- 290
	return -math.deg(math.atan(axis.y, axis.x)) -- 291
end -- 288
local sizeDims -- 293
sizeDims = function(size) -- 293
	if size.width ~= nil and size.height ~= nil then -- 294
		return size.width, size.height -- 294
	end -- 294
	return size[1] or 0, size[2] or 0 -- 295
end -- 293
local arrayCount -- 297
arrayCount = function(values) -- 297
	if values.count then -- 298
		return values:count() -- 298
	end -- 298
	if values[1] == "Array" then -- 299
		return #values - 1 -- 299
	else -- 299
		return #values -- 299
	end -- 299
end -- 297
local arrayGet -- 301
arrayGet = function(values, index) -- 301
	if values.get then -- 302
		return values:get(index) -- 302
	end -- 302
	if values[1] == "Array" then -- 303
		return values[index + 1] -- 303
	else -- 303
		return values[index] -- 303
	end -- 303
end -- 301
local loadData -- 305
loadData = function(data, item) -- 305
	data = normalizeData(data) -- 306
	if data then -- 306
		return loadFuncs[data[1]](data, item) -- 307
	end -- 306
end -- 305
local toDef -- 309
toDef = function(data) -- 309
	local _with_0 = BodyDef() -- 309
	_with_0.type = data.type -- 310
	_with_0.bullet = data.bullet -- 311
	_with_0.linearAcceleration = toVec(data.linearAcceleration) -- 312
	_with_0.fixedRotation = data.fixedRotation -- 313
	_with_0.linearDamping = data.linearDamping -- 314
	_with_0.angularDamping = data.angularDamping -- 315
	_with_0.position = toVec(data.position) -- 316
	_with_0.angle = data.angle -- 317
	_with_0.face = data.face -- 318
	_with_0.facePos = toVec(data.facePos) -- 319
	_with_0.faceScale = data.faceScale or 1 -- 320
	return _with_0 -- 309
end -- 309
loadFuncs = { -- 323
	["Array"] = function(data, itemDict) -- 323
		for i = 1, arrayCount(data) do -- 324
			loadData(arrayGet(data, i), itemDict) -- 325
		end -- 324
	end, -- 323
	["Phyx.Rect"] = function(data, itemDict) -- 327
		local bodyDef = toDef(data) -- 328
		local width, height = sizeDims(data.size) -- 329
		if data.sensor then -- 330
			bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 331
		else -- 333
			bodyDef:attachPolygon(toVec(data.center), width, height, 0, data.density, data.friction, data.restitution) -- 333
		end -- 330
		do -- 337
			local subShapes = data.subShapes -- 337
			if subShapes then -- 337
				for i = 1, arrayCount(subShapes) do -- 338
					loadData(arrayGet(subShapes, i), bodyDef) -- 339
				end -- 338
			end -- 337
		end -- 337
		itemDict[data.name] = bodyDef -- 340
	end, -- 327
	["Phyx.Disk"] = function(data, itemDict) -- 342
		local bodyDef = toDef(data) -- 343
		if data.sensor then -- 344
			bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 345
		else -- 347
			bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 347
		end -- 344
		do -- 351
			local subShapes = data.subShapes -- 351
			if subShapes then -- 351
				for i = 1, arrayCount(subShapes) do -- 352
					loadData(arrayGet(subShapes, i), bodyDef) -- 353
				end -- 352
			end -- 351
		end -- 351
		itemDict[data.name] = bodyDef -- 354
	end, -- 342
	["Phyx.Poly"] = function(data, itemDict) -- 356
		local bodyDef = toDef(data) -- 357
		if data.sensor then -- 358
			bodyDef:attachPolygonSensor(data.sensorTag, toVecArray(data.vertices)) -- 359
		else -- 361
			bodyDef:attachPolygon(toVecArray(data.vertices), data.density, data.friction, data.restitution) -- 361
		end -- 358
		do -- 365
			local subShapes = data.subShapes -- 365
			if subShapes then -- 365
				for i = 1, arrayCount(subShapes) do -- 366
					loadData(arrayGet(subShapes, i), bodyDef) -- 367
				end -- 366
			end -- 365
		end -- 365
		itemDict[data.name] = bodyDef -- 368
	end, -- 356
	["Phyx.Chain"] = function(data, itemDict) -- 370
		local bodyDef = toDef(data) -- 371
		bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 372
		do -- 373
			local subShapes = data.subShapes -- 373
			if subShapes then -- 373
				for i = 1, arrayCount(subShapes) do -- 374
					loadData(arrayGet(subShapes, i), bodyDef) -- 375
				end -- 374
			end -- 373
		end -- 373
		itemDict[data.name] = bodyDef -- 376
	end, -- 370
	["Phyx.SubRect"] = function(data, bodyDef) -- 378
		local width, height = sizeDims(data.size) -- 379
		if data.sensor then -- 380
			return bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 381
		else -- 383
			return bodyDef:attachPolygon(toVec(data.center), width, height, data.angle, data.density, data.friction, data.restitution) -- 383
		end -- 380
	end, -- 378
	["Phyx.SubDisk"] = function(data, bodyDef) -- 388
		if data.sensor then -- 389
			return bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 390
		else -- 392
			return bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 392
		end -- 389
	end, -- 388
	["Phyx.SubPoly"] = function(data, bodyDef) -- 397
		if data.sensor then -- 398
			return bodyDef:attachPolygonSensor(data.sensorTag, toVecArray(data.vertices)) -- 399
		else -- 401
			return bodyDef:attachPolygon(toVecArray(data.vertices), data.density, data.friction, data.restitution) -- 401
		end -- 398
	end, -- 397
	["Phyx.SubChain"] = function(data, bodyDef) -- 406
		return bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 407
	end, -- 406
	["Phyx.Distance"] = function(data, itemDict) -- 409
		itemDict[data.name] = JointDef:distance(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.frequency, data.damping) -- 410
	end, -- 409
	["Phyx.Friction"] = function(data, itemDict) -- 420
		itemDict[data.name] = JointDef:friction(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.maxForce, data.maxTorque) -- 421
	end, -- 420
	["Phyx.Gear"] = function(data, itemDict) -- 430
		itemDict[data.name] = JointDef:gear(data.collision, data.jointA, data.jointB, data.ratio) -- 431
	end, -- 430
	["Phyx.Spring"] = function(data, itemDict) -- 438
		itemDict[data.name] = JointDef:spring(data.collision, data.bodyA, data.bodyB, toVec(data.linearOffset), data.angularOffset, data.maxForce, data.maxTorque, data.correctionFactor) -- 439
	end, -- 438
	["Phyx.Prismatic"] = function(data, itemDict) -- 450
		itemDict[data.name] = JointDef:prismatic(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), axisToAngle(data.axis), data.lowerTranslation, data.upperTranslation, data.maxMotorForce, data.motorSpeed) -- 451
	end, -- 450
	["Phyx.Pulley"] = function(data, itemDict) -- 463
		itemDict[data.name] = JointDef:pulley(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), toVec(data.groundAnchorA), toVec(data.groundAnchorB), data.ratio) -- 464
	end, -- 463
	["Phyx.Revolute"] = function(data, itemDict) -- 475
		itemDict[data.name] = JointDef:revolute(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.lowerAngle, data.upperAngle, data.maxMotorTorque, data.motorSpeed) -- 476
	end, -- 475
	["Phyx.Rope"] = function(data, itemDict) -- 487
		itemDict[data.name] = JointDef:rope(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.maxLength) -- 488
	end, -- 487
	["Phyx.Weld"] = function(data, itemDict) -- 497
		itemDict[data.name] = JointDef:weld(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.frequency, data.damping) -- 498
	end, -- 497
	["Phyx.Wheel"] = function(data, itemDict) -- 507
		itemDict[data.name] = JointDef:wheel(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), axisToAngle(data.axis), data.maxMotorTorque, data.motorSpeed, data.frequency, data.damping) -- 508
	end -- 507
} -- 322
_module_0 = function(bodyData, world, pos, angle) -- 520
	if pos == nil then -- 520
		pos = Vec2.zero -- 520
	end -- 520
	if angle == nil then -- 520
		angle = 0 -- 520
	end -- 520
	local root = Node() -- 521
	local itemDict = Dictionary() -- 522
	xpcall(function() -- 523
		loadData(loadBodyData(bodyData), itemDict) -- 524
		local items = root.data -- 525
		local center = Vec2.zero -- 526
		local jointDefs = { } -- 527
		itemDict:each(function(itemDef, key) -- 528
			if "BodyDef" == tolua.type(itemDef) then -- 529
				local body = Body(itemDef, world, pos, angle) -- 530
				body.owner = root -- 531
				root:addChild(body) -- 532
				local faceStr = itemDef.face -- 533
				if faceStr ~= "" then -- 534
					local face -- 535
					if faceStr:match(":") then -- 535
						face = Playable(faceStr) -- 536
					else -- 538
						face = Sprite(faceStr) -- 538
					end -- 535
					if face then -- 539
						face.position = itemDef.facePos -- 540
						face.scaleX = itemDef.faceScale -- 541
						face.scaleY = itemDef.faceScale -- 542
						body:addChild(face) -- 543
					end -- 539
				end -- 534
				items[key] = body -- 544
			else -- 546
				jointDefs[#jointDefs + 1] = { -- 546
					key, -- 546
					itemDef -- 546
				} -- 546
			end -- 529
		end) -- 528
		for _index_0 = 1, #jointDefs do -- 547
			local _des_0 = jointDefs[_index_0] -- 547
			local key, itemDef = _des_0[1], _des_0[2] -- 547
			if center then -- 548
				itemDef.center = center -- 549
				itemDef.position = pos -- 550
				itemDef.angle = angle -- 551
			end -- 548
			local joint = Joint(itemDef, items) -- 552
			if joint then -- 552
				items[key] = joint -- 553
			end -- 552
		end -- 547
	end, function(err) -- 553
		Log("Error", "failed to load body data due to: \"" .. tostring(err) .. "\"") -- 555
		root:cleanup() -- 556
		itemDict:clear() -- 557
		root = nil -- 558
	end) -- 523
	return root -- 559
end -- 520
return _module_0 -- 1
