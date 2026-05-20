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
local loadBodyData -- 234
loadBodyData = function(bodyData) -- 234
	local data -- 235
	do -- 235
		local _exp_0 = type(bodyData) -- 235
		if "string" == _exp_0 then -- 235
			local file -- 236
			do -- 236
				local _val_0 -- 236
				repeat -- 236
					if Content:exist(bodyData) then -- 237
						_val_0 = bodyData -- 237
						break -- 237
					end -- 237
					file = bodyData .. ".b.lua" -- 238
					if Content:exist(file) then -- 239
						_val_0 = file -- 239
						break -- 239
					end -- 239
				until true -- 236
				file = _val_0 -- 236
			end -- 236
			if file then -- 241
				local fullPath = Content:getFullPath(file) -- 242
				data = require(fullPath) -- 243
			else -- 245
				error("failed to locate body data file: \"" .. tostring(bodyData) .. "\"") -- 245
				data = nil -- 246
			end -- 241
		elseif "table" == _exp_0 then -- 247
			data = bodyData -- 248
		end -- 235
	end -- 235
	return Struct:load(data) -- 249
end -- 234
local toVec -- 251
toVec = function(value) -- 251
	local _type_0 = type(value) -- 252
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 252
	local _match_0 = false -- 252
	if _tab_0 then -- 252
		local x = value[1] -- 252
		local y = value[2] -- 252
		if x ~= nil and y ~= nil then -- 252
			_match_0 = true -- 252
			return Vec2(x, y) -- 252
		end -- 252
	end -- 252
	if not _match_0 then -- 252
		return value -- 253
	end -- 252
end -- 251
local toVecArray -- 255
toVecArray = function(values) -- 255
	if values.toArray then -- 256
		values = values:toArray() -- 257
	end -- 256
	local start -- 258
	if values[1] == "Array" then -- 258
		start = 2 -- 258
	else -- 258
		start = 1 -- 258
	end -- 258
	local _accum_0 = { } -- 259
	local _len_0 = 1 -- 259
	for i = start, #values do -- 259
		_accum_0[_len_0] = toVec(values[i]) -- 259
		_len_0 = _len_0 + 1 -- 259
	end -- 259
	return _accum_0 -- 259
end -- 255
local axisToAngle -- 261
axisToAngle = function(value) -- 261
	local axis = toVec(value) -- 262
	if not (axis and axis.x ~= nil and axis.y ~= nil) then -- 263
		return 0 -- 263
	end -- 263
	return -math.deg(math.atan(axis.y, axis.x)) -- 264
end -- 261
local sizeDims -- 266
sizeDims = function(size) -- 266
	if size.width ~= nil and size.height ~= nil then -- 267
		return size.width, size.height -- 267
	end -- 267
	return size[1] or 0, size[2] or 0 -- 268
end -- 266
local arrayCount -- 270
arrayCount = function(values) -- 270
	if values.count then -- 271
		return values:count() -- 271
	end -- 271
	if values[1] == "Array" then -- 272
		return #values - 1 -- 272
	else -- 272
		return #values -- 272
	end -- 272
end -- 270
local arrayGet -- 274
arrayGet = function(values, index) -- 274
	if values.get then -- 275
		return values:get(index) -- 275
	end -- 275
	if values[1] == "Array" then -- 276
		return values[index + 1] -- 276
	else -- 276
		return values[index] -- 276
	end -- 276
end -- 274
local loadData -- 278
loadData = function(data, item) -- 278
	return loadFuncs[data[1]](data, item) -- 279
end -- 278
local toDef -- 281
toDef = function(data) -- 281
	local _with_0 = BodyDef() -- 281
	_with_0.type = data.type -- 282
	_with_0.bullet = data.bullet -- 283
	_with_0.linearAcceleration = toVec(data.linearAcceleration) -- 284
	_with_0.fixedRotation = data.fixedRotation -- 285
	_with_0.linearDamping = data.linearDamping -- 286
	_with_0.angularDamping = data.angularDamping -- 287
	_with_0.position = toVec(data.position) -- 288
	_with_0.angle = data.angle -- 289
	_with_0.face = data.face -- 290
	_with_0.facePos = toVec(data.facePos) -- 291
	_with_0.faceScale = data.faceScale or 1 -- 292
	return _with_0 -- 281
end -- 281
loadFuncs = { -- 295
	["Array"] = function(data, itemDict) -- 295
		for i = 1, arrayCount(data) do -- 296
			loadData(arrayGet(data, i), itemDict) -- 297
		end -- 296
	end, -- 295
	["Phyx.Rect"] = function(data, itemDict) -- 299
		local bodyDef = toDef(data) -- 300
		local width, height = sizeDims(data.size) -- 301
		if data.sensor then -- 302
			bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 303
		else -- 305
			bodyDef:attachPolygon(toVec(data.center), width, height, 0, data.density, data.friction, data.restitution) -- 305
		end -- 302
		do -- 309
			local subShapes = data.subShapes -- 309
			if subShapes then -- 309
				for i = 1, arrayCount(subShapes) do -- 310
					loadData(arrayGet(subShapes, i), bodyDef) -- 311
				end -- 310
			end -- 309
		end -- 309
		itemDict[data.name] = bodyDef -- 312
	end, -- 299
	["Phyx.Disk"] = function(data, itemDict) -- 314
		local bodyDef = toDef(data) -- 315
		if data.sensor then -- 316
			bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 317
		else -- 319
			bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 319
		end -- 316
		do -- 323
			local subShapes = data.subShapes -- 323
			if subShapes then -- 323
				for i = 1, arrayCount(subShapes) do -- 324
					loadData(arrayGet(subShapes, i), bodyDef) -- 325
				end -- 324
			end -- 323
		end -- 323
		itemDict[data.name] = bodyDef -- 326
	end, -- 314
	["Phyx.Poly"] = function(data, itemDict) -- 328
		local bodyDef = toDef(data) -- 329
		if data.sensor then -- 330
			bodyDef:attachPolygonSensor(data.sensorTag, toVecArray(data.vertices)) -- 331
		else -- 333
			bodyDef:attachPolygon(toVecArray(data.vertices), data.density, data.friction, data.restitution) -- 333
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
	end, -- 328
	["Phyx.Chain"] = function(data, itemDict) -- 342
		local bodyDef = toDef(data) -- 343
		bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 344
		do -- 345
			local subShapes = data.subShapes -- 345
			if subShapes then -- 345
				for i = 1, arrayCount(subShapes) do -- 346
					loadData(arrayGet(subShapes, i), bodyDef) -- 347
				end -- 346
			end -- 345
		end -- 345
		itemDict[data.name] = bodyDef -- 348
	end, -- 342
	["Phyx.SubRect"] = function(data, bodyDef) -- 350
		local width, height = sizeDims(data.size) -- 351
		if data.sensor then -- 352
			return bodyDef:attachPolygonSensor(data.sensorTag, toVec(data.center), width, height) -- 353
		else -- 355
			return bodyDef:attachPolygon(toVec(data.center), width, height, data.angle, data.density, data.friction, data.restitution) -- 355
		end -- 352
	end, -- 350
	["Phyx.SubDisk"] = function(data, bodyDef) -- 360
		if data.sensor then -- 361
			return bodyDef:attachDiskSensor(data.sensorTag, toVec(data.center), data.radius) -- 362
		else -- 364
			return bodyDef:attachDisk(toVec(data.center), data.radius, data.density, data.friction, data.restitution) -- 364
		end -- 361
	end, -- 360
	["Phyx.SubPoly"] = function(data, bodyDef) -- 369
		if data.sensor then -- 370
			return bodyDef:attachPolygonSensor(data.sensorTag, toVecArray(data.vertices)) -- 371
		else -- 373
			return bodyDef:attachPolygon(toVecArray(data.vertices), data.density, data.friction, data.restitution) -- 373
		end -- 370
	end, -- 369
	["Phyx.SubChain"] = function(data, bodyDef) -- 378
		return bodyDef:attachChain(toVecArray(data.vertices), data.friction, data.restitution) -- 379
	end, -- 378
	["Phyx.Distance"] = function(data, itemDict) -- 381
		itemDict[data.name] = JointDef:distance(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.frequency, data.damping) -- 382
	end, -- 381
	["Phyx.Friction"] = function(data, itemDict) -- 392
		itemDict[data.name] = JointDef:friction(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.maxForce, data.maxTorque) -- 393
	end, -- 392
	["Phyx.Gear"] = function(data, itemDict) -- 402
		itemDict[data.name] = JointDef:gear(data.collision, data.jointA, data.jointB, data.ratio) -- 403
	end, -- 402
	["Phyx.Spring"] = function(data, itemDict) -- 410
		itemDict[data.name] = JointDef:spring(data.collision, data.bodyA, data.bodyB, toVec(data.linearOffset), data.angularOffset, data.maxForce, data.maxTorque, data.correctionFactor) -- 411
	end, -- 410
	["Phyx.Prismatic"] = function(data, itemDict) -- 422
		itemDict[data.name] = JointDef:prismatic(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), axisToAngle(data.axis), data.lowerTranslation, data.upperTranslation, data.maxMotorForce, data.motorSpeed) -- 423
	end, -- 422
	["Phyx.Pulley"] = function(data, itemDict) -- 435
		itemDict[data.name] = JointDef:pulley(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), toVec(data.groundAnchorA), toVec(data.groundAnchorB), data.ratio) -- 436
	end, -- 435
	["Phyx.Revolute"] = function(data, itemDict) -- 447
		itemDict[data.name] = JointDef:revolute(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.lowerAngle, data.upperAngle, data.maxMotorTorque, data.motorSpeed) -- 448
	end, -- 447
	["Phyx.Rope"] = function(data, itemDict) -- 459
		itemDict[data.name] = JointDef:rope(data.collision, data.bodyA, data.bodyB, toVec(data.anchorA), toVec(data.anchorB), data.maxLength) -- 460
	end, -- 459
	["Phyx.Weld"] = function(data, itemDict) -- 469
		itemDict[data.name] = JointDef:weld(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), data.frequency, data.damping) -- 470
	end, -- 469
	["Phyx.Wheel"] = function(data, itemDict) -- 479
		itemDict[data.name] = JointDef:wheel(data.collision, data.bodyA, data.bodyB, toVec(data.worldPos), axisToAngle(data.axis), data.maxMotorTorque, data.motorSpeed, data.frequency, data.damping) -- 480
	end -- 479
} -- 294
_module_0 = function(bodyData, world, pos, angle) -- 492
	if pos == nil then -- 492
		pos = Vec2.zero -- 492
	end -- 492
	if angle == nil then -- 492
		angle = 0 -- 492
	end -- 492
	local root = Node() -- 493
	local itemDict = Dictionary() -- 494
	xpcall(function() -- 495
		loadData(loadBodyData(bodyData), itemDict) -- 496
		local items = root.data -- 497
		local center = Vec2.zero -- 498
		local jointDefs = { } -- 499
		itemDict:each(function(itemDef, key) -- 500
			if "BodyDef" == tolua.type(itemDef) then -- 501
				local body = Body(itemDef, world, pos, angle) -- 502
				body.owner = root -- 503
				root:addChild(body) -- 504
				local faceStr = itemDef.face -- 505
				if faceStr ~= "" then -- 506
					local face -- 507
					if faceStr:match(":") then -- 507
						face = Playable(faceStr) -- 508
					else -- 510
						face = Sprite(faceStr) -- 510
					end -- 507
					if face then -- 511
						face.position = itemDef.facePos -- 512
						face.scaleX = itemDef.faceScale -- 513
						face.scaleY = itemDef.faceScale -- 514
						body:addChild(face) -- 515
					end -- 511
				end -- 506
				items[key] = body -- 516
			else -- 518
				jointDefs[#jointDefs + 1] = { -- 518
					key, -- 518
					itemDef -- 518
				} -- 518
			end -- 501
		end) -- 500
		for _index_0 = 1, #jointDefs do -- 519
			local _des_0 = jointDefs[_index_0] -- 519
			local key, itemDef = _des_0[1], _des_0[2] -- 519
			if center then -- 520
				itemDef.center = center -- 521
				itemDef.position = pos -- 522
				itemDef.angle = angle -- 523
			end -- 520
			local joint = Joint(itemDef, items) -- 524
			if joint then -- 524
				items[key] = joint -- 525
			end -- 524
		end -- 519
	end, function(err) -- 525
		Log("Error", "failed to load body data due to: \"" .. tostring(err) .. "\"") -- 527
		root:cleanup() -- 528
		itemDict:clear() -- 529
		root = nil -- 530
	end) -- 495
	return root -- 531
end -- 492
return _module_0 -- 1
