-- [yue]: Script/Lib/BodyEx.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local Struct = require("Utils").Struct -- 10
local type <const> = type -- 11
local Content <const> = Content -- 11
local require <const> = require -- 11
local error <const> = error -- 11
local tostring <const> = tostring -- 11
local Vec2 <const> = Vec2 -- 11
local table <const> = table -- 11
local ipairs <const> = ipairs -- 11
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
Struct.Phyx.Poly("name", "type", "position", "angle", "vertices", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos", "faceScale", "convexes") -- 59
Struct.Phyx.Chain("name", "type", "position", "angle", "vertices", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "subShapes", "face", "facePos", "faceScale") -- 81
Struct.Phyx.SubRect("center", "angle", "size", "density", "friction", "restitution", "sensor", "sensorTag") -- 99
Struct.Phyx.SubDisk("center", "radius", "density", "friction", "restitution", "sensor", "sensorTag") -- 109
Struct.Phyx.SubPoly("vertices", "density", "friction", "restitution", "sensor", "sensorTag", "convexes") -- 118
Struct.Phyx.SubChain("vertices", "friction", "restitution") -- 127
Struct.Phyx.Distance("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "frequency", "damping") -- 132
Struct.Phyx.Friction("name", "collision", "bodyA", "bodyB", "worldPos", "maxForce", "maxTorque") -- 142
Struct.Phyx.Gear("name", "collision", "jointA", "jointB", "ratio") -- 151
Struct.Phyx.Spring("name", "collision", "bodyA", "bodyB", "linearOffset", "angularOffset", "maxForce", "maxTorque", "correctionFactor") -- 158
Struct.Phyx.Prismatic("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "lowerTranslation", "upperTranslation", "maxMotorForce", "motorSpeed") -- 169
Struct.Phyx.Pulley("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "groundAnchorA", "groundAnchorB", "ratio") -- 181
Struct.Phyx.Revolute("name", "collision", "bodyA", "bodyB", "worldPos", "lowerAngle", "upperAngle", "maxMotorTorque", "motorSpeed") -- 192
Struct.Phyx.Rope("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "maxLength") -- 203
Struct.Phyx.Weld("name", "collision", "bodyA", "bodyB", "worldPos", "frequency", "damping") -- 212
Struct.Phyx.Wheel("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "maxMotorTorque", "motorSpeed", "frequency", "damping") -- 221
local loadFuncs = nil -- 234
local loadBodyData -- 236
loadBodyData = function(bodyData) -- 236
	local data -- 237
	do -- 237
		local _exp_0 = type(bodyData) -- 237
		if "string" == _exp_0 then -- 237
			local file -- 238
			do -- 238
				local _val_0 -- 238
				repeat -- 238
					if Content:exist(bodyData) then -- 239
						_val_0 = bodyData -- 239
						break -- 239
					end -- 239
					file = bodyData .. ".b.lua" -- 240
					if Content:exist(file) then -- 241
						_val_0 = file -- 241
						break -- 241
					end -- 241
				until true -- 238
				file = _val_0 -- 238
			end -- 238
			if file then -- 243
				local fullPath = Content:getFullPath(file) -- 244
				data = require(fullPath) -- 245
			else -- 247
				error("failed to locate body data file: \"" .. tostring(bodyData) .. "\"") -- 247
				data = nil -- 248
			end -- 243
		elseif "table" == _exp_0 then -- 249
			data = bodyData -- 250
		end -- 237
	end -- 237
	return Struct:load(data) -- 251
end -- 236
local toVec -- 253
toVec = function(value) -- 253
	if not ("table" == type(value)) then -- 254
		return value -- 254
	end -- 254
	return Vec2(value.x or value[1] or 0, value.y or value[2] or 0) -- 255
end -- 253
local toVecArray -- 257
toVecArray = function(values) -- 257
	if values.toArray then -- 258
		values = values:toArray() -- 259
	end -- 258
	local start -- 260
	if values[1] == "Array" then -- 260
		start = 2 -- 260
	else -- 260
		start = 1 -- 260
	end -- 260
	local _accum_0 = { } -- 261
	local _len_0 = 1 -- 261
	for i = start, #values do -- 261
		_accum_0[_len_0] = toVec(values[i]) -- 261
		_len_0 = _len_0 + 1 -- 261
	end -- 261
	return _accum_0 -- 261
end -- 257
local copyVec -- 263
copyVec = function(value) -- 263
	return Vec2(value.x, value.y) -- 263
end -- 263
local toVecParts -- 265
toVecParts = function(values, vertices) -- 265
	if not values then -- 266
		return { -- 266
			toVecArray(vertices) -- 266
		} -- 266
	end -- 266
	if values.toArray then -- 267
		values = values:toArray() -- 267
	end -- 267
	if #values == 0 then -- 268
		return { -- 268
			toVecArray(vertices) -- 268
		} -- 268
	end -- 268
	local start -- 269
	if values[1] == "Array" then -- 269
		start = 2 -- 269
	else -- 269
		start = 1 -- 269
	end -- 269
	if start > #values then -- 270
		return { -- 270
			toVecArray(vertices) -- 270
		} -- 270
	end -- 270
	local parts = { } -- 271
	for i = start, #values do -- 272
		table.insert(parts, toVecArray(values[i])) -- 273
	end -- 272
	if #parts == 0 then -- 274
		error("polygon convex data must contain at least one convex part") -- 274
	end -- 274
	return parts -- 275
end -- 265
local encodeMultiParts -- 277
encodeMultiParts = function(parts) -- 277
	local result = { } -- 278
	for i, part in ipairs(parts) do -- 279
		for _index_0 = 1, #part do -- 280
			local point = part[_index_0] -- 280
			table.insert(result, copyVec(point)) -- 281
		end -- 280
		if i < #parts and #part > 0 then -- 282
			table.insert(result, copyVec(part[#part])) -- 283
		end -- 282
	end -- 279
	return result -- 284
end -- 277
local attachPolygonParts -- 286
attachPolygonParts = function(bodyDef, data) -- 286
	local parts = toVecParts(data.convexes, data.vertices) -- 287
	if data.sensor then -- 288
		for _index_0 = 1, #parts do -- 289
			local part = parts[_index_0] -- 289
			bodyDef:attachPolygonSensor(data.sensorTag, part) -- 290
		end -- 289
	else -- 291
		if #parts == 1 then -- 291
			return bodyDef:attachPolygon(parts[1], data.density, data.friction, data.restitution) -- 292
		else -- 294
			return bodyDef:attachMulti(encodeMultiParts(parts), data.density, data.friction, data.restitution) -- 294
		end -- 291
	end -- 288
end -- 286
local axisToAngle -- 296
axisToAngle = function(value) -- 296
	local axis = toVec(value) -- 297
	if not (axis and axis.x ~= nil and axis.y ~= nil) then -- 298
		return 0 -- 298
	end -- 298
	return -math.deg(math.atan(axis.y, axis.x)) -- 299
end -- 296
local sizeDims -- 301
sizeDims = function(size) -- 301
	if size.width ~= nil and size.height ~= nil then -- 302
		return size.width, size.height -- 302
	end -- 302
	return size[1] or 0, size[2] or 0 -- 303
end -- 301
local arrayCount -- 305
arrayCount = function(values) -- 305
	if values.count then -- 306
		return values:count() -- 306
	end -- 306
	if values[1] == "Array" then -- 307
		return #values - 1 -- 307
	else -- 307
		return #values -- 307
	end -- 307
end -- 305
local arrayGet -- 309
arrayGet = function(values, index) -- 309
	if values.get then -- 310
		return values:get(index) -- 310
	end -- 310
	if values[1] == "Array" then -- 311
		return values[index + 1] -- 311
	else -- 311
		return values[index] -- 311
	end -- 311
end -- 309
local loadData -- 313
loadData = function(data, item) -- 313
	return loadFuncs[data[1]](data, item) -- 314
end -- 313
local toDef -- 316
toDef = function(data) -- 316
	local _with_0 = BodyDef() -- 316
	_with_0.type = data.type -- 317
	_with_0.bullet = data.bullet -- 318
	_with_0.linearAcceleration = toVec(data.linearAcceleration) -- 319
	_with_0.fixedRotation = data.fixedRotation -- 320
	_with_0.linearDamping = data.linearDamping -- 321
	_with_0.angularDamping = data.angularDamping -- 322
	_with_0.position = toVec(data.position) -- 323
	_with_0.angle = data.angle -- 324
	_with_0.face = data.face -- 325
	_with_0.facePos = toVec(data.facePos) -- 326
	_with_0.faceScale = data.faceScale or 1 -- 327
	return _with_0 -- 316
end -- 316
loadFuncs = { -- 330
	["Array"] = function(data, itemDict) -- 330
		for i = 1, arrayCount(data) do -- 331
			loadData(arrayGet(data, i), itemDict) -- 332
		end -- 331
	end, -- 330
	["Phyx.Rect"] = function(data, itemDict) -- 334
		local bodyDef = toDef(data) -- 335
		local width, height = sizeDims(data.size) -- 336
		if data.sensor then -- 337
			bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 338
		else -- 340
			bodyDef:attachPolygon(toVec(data.center), width, height, 0, data.density, data.friction, data.restitution) -- 340
		end -- 337
		do -- 344
			local subShapes = data.subShapes -- 344
			if subShapes then -- 344
				for i = 1, arrayCount(subShapes) do -- 345
					loadData(arrayGet(subShapes, i), bodyDef) -- 346
				end -- 345
			end -- 344
		end -- 344
		itemDict[data.name] = bodyDef -- 347
	end, -- 334
	["Phyx.Disk"] = function(data, itemDict) -- 349
		local bodyDef = toDef(data) -- 350
		if data.sensor then -- 351
			bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 352
		else -- 354
			bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 354
		end -- 351
		do -- 358
			local subShapes = data.subShapes -- 358
			if subShapes then -- 358
				for i = 1, arrayCount(subShapes) do -- 359
					loadData(arrayGet(subShapes, i), bodyDef) -- 360
				end -- 359
			end -- 358
		end -- 358
		itemDict[data.name] = bodyDef -- 361
	end, -- 349
	["Phyx.Poly"] = function(data, itemDict) -- 363
		local bodyDef = toDef(data) -- 364
		attachPolygonParts(bodyDef, data) -- 365
		do -- 366
			local subShapes = data.subShapes -- 366
			if subShapes then -- 366
				for i = 1, arrayCount(subShapes) do -- 367
					loadData(arrayGet(subShapes, i), bodyDef) -- 368
				end -- 367
			end -- 366
		end -- 366
		itemDict[data.name] = bodyDef -- 369
	end, -- 363
	["Phyx.Chain"] = function(data, itemDict) -- 371
		local bodyDef = toDef(data) -- 372
		bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 373
		do -- 374
			local subShapes = data.subShapes -- 374
			if subShapes then -- 374
				for i = 1, arrayCount(subShapes) do -- 375
					loadData(arrayGet(subShapes, i), bodyDef) -- 376
				end -- 375
			end -- 374
		end -- 374
		itemDict[data.name] = bodyDef -- 377
	end, -- 371
	["Phyx.SubRect"] = function(data, bodyDef) -- 379
		local width, height = sizeDims(data.size) -- 380
		if data.sensor then -- 381
			return bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 382
		else -- 384
			return bodyDef:attachPolygon(toVec(data.center), width, height, data.angle, data.density, data.friction, data.restitution) -- 384
		end -- 381
	end, -- 379
	["Phyx.SubDisk"] = function(data, bodyDef) -- 389
		if data.sensor then -- 390
			return bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 391
		else -- 393
			return bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 393
		end -- 390
	end, -- 389
	["Phyx.SubPoly"] = function(data, bodyDef) -- 398
		return attachPolygonParts(bodyDef, data) -- 399
	end, -- 398
	["Phyx.SubChain"] = function(data, bodyDef) -- 401
		return bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 402
	end, -- 401
	["Phyx.Distance"] = function(data, itemDict) -- 404
		itemDict[data.name] = JointDef:distance(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.frequency, data.damping) -- 405
	end, -- 404
	["Phyx.Friction"] = function(data, itemDict) -- 415
		itemDict[data.name] = JointDef:friction(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.maxForce, data.maxTorque) -- 416
	end, -- 415
	["Phyx.Gear"] = function(data, itemDict) -- 425
		itemDict[data.name] = JointDef:gear(data.collision, data.jointA, data.jointB, data.ratio) -- 426
	end, -- 425
	["Phyx.Spring"] = function(data, itemDict) -- 433
		itemDict[data.name] = JointDef:spring(data.collision, data.bodyA, data.bodyB, toVec(data.linearOffset), data.angularOffset, data.maxForce, data.maxTorque, data.correctionFactor) -- 434
	end, -- 433
	["Phyx.Prismatic"] = function(data, itemDict) -- 445
		itemDict[data.name] = JointDef:prismatic(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), axisToAngle(data.axis), data.lowerTranslation, data.upperTranslation, data.maxMotorForce, data.motorSpeed) -- 446
	end, -- 445
	["Phyx.Pulley"] = function(data, itemDict) -- 458
		itemDict[data.name] = JointDef:pulley(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), toVec(data.groundAnchorA), toVec(data.groundAnchorB), data.ratio) -- 459
	end, -- 458
	["Phyx.Revolute"] = function(data, itemDict) -- 470
		itemDict[data.name] = JointDef:revolute(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.lowerAngle, data.upperAngle, data.maxMotorTorque, data.motorSpeed) -- 471
	end, -- 470
	["Phyx.Rope"] = function(data, itemDict) -- 482
		itemDict[data.name] = JointDef:rope(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.maxLength) -- 483
	end, -- 482
	["Phyx.Weld"] = function(data, itemDict) -- 492
		itemDict[data.name] = JointDef:weld(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.frequency, data.damping) -- 493
	end, -- 492
	["Phyx.Wheel"] = function(data, itemDict) -- 502
		itemDict[data.name] = JointDef:wheel(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), axisToAngle(data.axis), data.maxMotorTorque, data.motorSpeed, data.frequency, data.damping) -- 503
	end -- 502
} -- 329
_module_0 = function(bodyData, world, pos, angle) -- 515
	if pos == nil then -- 515
		pos = Vec2.zero -- 515
	end -- 515
	if angle == nil then -- 515
		angle = 0 -- 515
	end -- 515
	local root = Node() -- 516
	local itemDict = Dictionary() -- 517
	xpcall(function() -- 518
		loadData(loadBodyData(bodyData), itemDict) -- 519
		local items = root.data -- 520
		local center = Vec2.zero -- 521
		local jointDefs = { } -- 522
		itemDict:each(function(itemDef, key) -- 523
			if "BodyDef" == tolua.type(itemDef) then -- 524
				local body = Body(itemDef, world, pos, angle) -- 525
				body.owner = root -- 526
				root:addChild(body) -- 527
				local faceStr = itemDef.face -- 528
				if faceStr ~= "" then -- 529
					local face -- 530
					if faceStr:match(":") then -- 530
						face = Playable(faceStr) -- 531
					else -- 533
						face = Sprite(faceStr) -- 533
					end -- 530
					if face then -- 534
						face.position = itemDef.facePos -- 535
						face.scaleX = itemDef.faceScale -- 536
						face.scaleY = itemDef.faceScale -- 537
						body:addChild(face) -- 538
					end -- 534
				end -- 529
				items[key] = body -- 539
			else -- 541
				jointDefs[#jointDefs + 1] = { -- 541
					key, -- 541
					itemDef -- 541
				} -- 541
			end -- 524
		end) -- 523
		for _index_0 = 1, #jointDefs do -- 542
			local _des_0 = jointDefs[_index_0] -- 542
			local key, itemDef = _des_0[1], _des_0[2] -- 542
			if center then -- 543
				itemDef.center = center -- 544
				itemDef.position = pos -- 545
				itemDef.angle = angle -- 546
			end -- 543
			local joint = Joint(itemDef, items) -- 547
			if joint then -- 547
				items[key] = joint -- 548
			end -- 547
		end -- 542
	end, function(err) -- 548
		Log("Error", "failed to load body data due to: \"" .. tostring(err) .. "\"") -- 550
		root:cleanup() -- 551
		itemDict:clear() -- 552
		root = nil -- 553
	end) -- 518
	return root -- 554
end -- 515
return _module_0 -- 1
