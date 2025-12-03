-- [yue]: Script/Lib/BodyEx.yue
local BodyDef = Dora.BodyDef -- 1
local JointDef = Dora.JointDef -- 1
local Dictionary = Dora.Dictionary -- 1
local Node = Dora.Node -- 1
local Vec2 = Dora.Vec2 -- 1
local tolua = Dora.tolua -- 1
local Body = Dora.Body -- 1
local Playable = Dora.Playable -- 1
local Sprite = Dora.Sprite -- 1
local Joint = Dora.Joint -- 1
local _module_0 = nil -- 1
local Struct = require("Utils").Struct -- 10
Struct.Array() -- 12
Struct.Phyx.Rect("name", "type", "position", "angle", "center", "size", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 14
Struct.Phyx.Disk("name", "type", "position", "angle", "center", "radius", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 35
Struct.Phyx.Poly("name", "type", "position", "angle", "vertices", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 56
Struct.Phyx.Chain("name", "type", "position", "angle", "vertices", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "subShapes", "face", "facePos") -- 76
Struct.Phyx.SubRect("center", "angle", "size", "density", "friction", "restitution", "sensor", "sensorTag") -- 93
Struct.Phyx.SubDisk("center", "radius", "density", "friction", "restitution", "sensor", "sensorTag") -- 103
Struct.Phyx.SubPoly("vertices", "density", "friction", "restitution", "sensor", "sensorTag") -- 112
Struct.Phyx.SubChain("vertices", "friction", "restitution") -- 120
Struct.Phyx.Distance("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "frequency", "damping") -- 125
Struct.Phyx.Friction("name", "collision", "bodyA", "bodyB", "worldPos", "maxForce", "maxTorque") -- 135
Struct.Phyx.Gear("name", "collision", "jointA", "jointB", "ratio") -- 144
Struct.Phyx.Spring("name", "collision", "bodyA", "bodyB", "linearOffset", "angularOffset", "maxForce", "maxTorque", "correctionFactor") -- 151
Struct.Phyx.Prismatic("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "lowerTranslation", "upperTranslation", "maxMotorForce", "motorSpeed") -- 162
Struct.Phyx.Pulley("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "groundAnchorA", "groundAnchorB", "ratio") -- 174
Struct.Phyx.Revolute("name", "collision", "bodyA", "bodyB", "worldPos", "lowerAngle", "upperAngle", "maxMotorTorque", "motorSpeed") -- 185
Struct.Phyx.Rope("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "maxLength") -- 196
Struct.Phyx.Weld("name", "collision", "bodyA", "bodyB", "worldPos", "frequency", "damping") -- 205
Struct.Phyx.Wheel("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "maxMotorTorque", "motorSpeed", "frequency", "damping") -- 214
local loadFuncs = nil -- 227
local loadData -- 228
loadData = function(data, item) -- 228
	return loadFuncs[data[1]](data, item) -- 229
end -- 228
local toDef -- 231
toDef = function(data) -- 231
	local _with_0 = BodyDef() -- 231
	_with_0.type = data.type -- 232
	_with_0.bullet = data.bullet -- 233
	_with_0.linearAcceleration = data.linearAcceleration -- 234
	_with_0.fixedRotation = data.fixedRotation -- 235
	_with_0.linearDamping = data.linearDamping -- 236
	_with_0.angularDamping = data.angularDamping -- 237
	_with_0.position = data.position -- 238
	_with_0.angle = data.angle -- 239
	_with_0.face = data.face -- 240
	_with_0.facePos = data.facePos -- 241
	return _with_0 -- 231
end -- 231
loadFuncs = { -- 244
	["Array"] = function(data, itemDict) -- 244
		for i = 1, data:count() do -- 245
			loadData(data:get(i), itemDict) -- 246
		end -- 245
	end, -- 244
	["Phyx.Rect"] = function(data, itemDict) -- 248
		local bodyDef = toDef(data) -- 249
		local width, height -- 250
		do -- 250
			local _obj_0 = data.size -- 250
			width, height = _obj_0.width, _obj_0.height -- 250
		end -- 250
		if data.sensor then -- 251
			bodyDef:attachPolygonSensor(data.sensorTag, data.center, width, height) -- 252
		else -- 254
			bodyDef:attachPolygon(data.center, width, height, 0, data.density, data.friction, data.restitution) -- 254
		end -- 251
		do -- 258
			local subShapes = data.subShapes -- 258
			if subShapes then -- 258
				for i = 1, subShapes:count() do -- 259
					loadData(subShapes:get(i), bodyDef) -- 260
				end -- 259
			end -- 258
		end -- 258
		itemDict[data.name] = bodyDef -- 261
	end, -- 248
	["Phyx.Disk"] = function(data, itemDict) -- 263
		local bodyDef = toDef(data) -- 264
		if data.sensor then -- 265
			bodyDef:attachDiskSensor(data.sensorTag, data.center, data.radius) -- 266
		else -- 268
			bodyDef:attachDisk(data.center, data.radius, data.density, data.friction, data.restitution) -- 268
		end -- 265
		do -- 272
			local subShapes = data.subShapes -- 272
			if subShapes then -- 272
				for i = 1, subShapes:count() do -- 273
					loadData(subShapes:get(i), bodyDef) -- 274
				end -- 273
			end -- 272
		end -- 272
		itemDict[data.name] = bodyDef -- 275
	end, -- 263
	["Phyx.Poly"] = function(data, itemDict) -- 277
		local bodyDef = toDef(data) -- 278
		if data.sensor then -- 279
			bodyDef:attachPolygonSensor(data.sensorTag, data.vertices:toArray()) -- 280
		else -- 282
			bodyDef:attachPolygon(data.vertices:toArray(), data.density, data.friction, data.restitution) -- 282
		end -- 279
		do -- 286
			local subShapes = data.subShapes -- 286
			if subShapes then -- 286
				for i = 1, subShapes:count() do -- 287
					loadData(subShapes:get(i), bodyDef) -- 288
				end -- 287
			end -- 286
		end -- 286
		itemDict[data.name] = bodyDef -- 289
	end, -- 277
	["Phyx.Chain"] = function(data, itemDict) -- 291
		local bodyDef = toDef(data) -- 292
		bodyDef:attachChain(data.vertices:toArray(), data.friction, data.restitution) -- 293
		do -- 294
			local subShapes = data.subShapes -- 294
			if subShapes then -- 294
				for i = 1, subShapes:count() do -- 295
					loadData(subShapes:get(i), bodyDef) -- 296
				end -- 295
			end -- 294
		end -- 294
		itemDict[data.name] = bodyDef -- 297
	end, -- 291
	["Phyx.SubRect"] = function(data, bodyDef) -- 299
		local width, height -- 300
		do -- 300
			local _obj_0 = data.size -- 300
			width, height = _obj_0.width, _obj_0.height -- 300
		end -- 300
		if data.sensor then -- 301
			return bodyDef:attachPolygonSensor(data.sensorTag, data.center, width, height) -- 302
		else -- 304
			return bodyDef:attachPolygon(data.center, width, height, data.angle, data.density, data.friction, data.restitution) -- 304
		end -- 301
	end, -- 299
	["Phyx.SubDisk"] = function(data, bodyDef) -- 309
		if data.sensor then -- 310
			return bodyDef:attachDiskSensor(data.sensorTag, data.center, data.radius) -- 311
		else -- 313
			return bodyDef:attachDisk(data.center, data.radius, data.density, data.friction, data.restitution) -- 313
		end -- 310
	end, -- 309
	["Phyx.SubPoly"] = function(data, bodyDef) -- 318
		if data.sensor then -- 319
			return bodyDef:attachPolygonSensor(data.sensorTag, data.vertices:toArray()) -- 320
		else -- 322
			return bodyDef:attachPolygon(data.vertices:toArray(), data.density, data.friction, data.restitution) -- 322
		end -- 319
	end, -- 318
	["Phyx.SubChain"] = function(data, bodyDef) -- 327
		return bodyDef:attachChain(data.vertices:toArray(), data.friction, data.restitution) -- 328
	end, -- 327
	["Phyx.Distance"] = function(data, itemDict) -- 330
		itemDict[data.name] = JointDef:distance(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.frequency, data.damping) -- 331
	end, -- 330
	["Phyx.Friction"] = function(data, itemDict) -- 340
		itemDict[data.name] = JointDef:friction(data.collision, data.bodyA, data.bodyB, data.worldPos, data.maxForce, data.maxTorque) -- 341
	end, -- 340
	["Phyx.Gear"] = function(data, itemDict) -- 350
		itemDict[data.name] = JointDef:gear(data.collision, data.jointA, data.jointB, data.ratio) -- 351
	end, -- 350
	["Phyx.Spring"] = function(data, itemDict) -- 358
		itemDict[data.name] = JointDef:spring(data.collision, data.bodyA, data.bodyB, data.linearOffset, data.angularOffset, data.maxForce, data.maxTorque, data.correctionFactor) -- 359
	end, -- 358
	["Phyx.Prismatic"] = function(data, itemDict) -- 370
		itemDict[data.name] = JointDef:prismatic(data.collision, data.bodyA, data.bodyB, data.worldPos, data.axis, data.lowerTranslation, data.upperTranslation, data.maxMotorForce, data.motorSpeed) -- 371
	end, -- 370
	["Phyx.Pulley"] = function(data, itemDict) -- 383
		itemDict[data.name] = JointDef:pulley(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.groundAnchorA, data.groundAnchorB, data.ratio) -- 384
	end, -- 383
	["Phyx.Revolute"] = function(data, itemDict) -- 395
		itemDict[data.name] = JointDef:revolute(data.collision, data.bodyA, data.bodyB, data.worldPos, data.lowerAngle, data.upperAngle, data.maxMotorTorque, data.motorSpeed) -- 396
	end, -- 395
	["Phyx.Rope"] = function(data, itemDict) -- 407
		itemDict[data.name] = JointDef:rope(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.maxLength) -- 408
	end, -- 407
	["Phyx.Weld"] = function(data, itemDict) -- 417
		itemDict[data.name] = JointDef:weld(data.collision, data.bodyA, data.bodyB, data.worldPos, data.frequency, data.damping) -- 418
	end, -- 417
	["Phyx.Wheel"] = function(data, itemDict) -- 427
		itemDict[data.name] = JointDef:wheel(data.collision, data.bodyA, data.bodyB, data.worldPos, data.axis, data.maxMotorTorque, data.motorSpeed, data.frequency, data.damping) -- 428
	end -- 427
} -- 243
_module_0 = function(bodyData, world, pos, angle) -- 440
	local itemDict = Dictionary() -- 441
	loadData(Struct:load(bodyData), itemDict) -- 442
	local root = Node() -- 443
	local items = root.data -- 444
	local center = Vec2.zero -- 445
	itemDict:each(function(itemDef, key) -- 446
		if "BodyDef" == tolua.type(itemDef) then -- 447
			local body = Body(itemDef, world, pos, angle) -- 448
			body.owner = root -- 449
			root:addChild(body) -- 450
			local faceStr = itemDef.face -- 451
			if faceStr ~= "" then -- 452
				local face -- 453
				if faceStr:match(":") then -- 453
					face = Playable(faceStr) -- 454
				else -- 456
					face = Sprite(faceStr) -- 456
				end -- 453
				if face then -- 457
					face.position = itemDef.facePos -- 458
					body:addChild(face) -- 459
				end -- 457
			end -- 452
			items[key] = body -- 460
		else -- 462
			if center then -- 462
				itemDef.center = center -- 463
				itemDef.position = pos -- 464
				itemDef.angle = angle -- 465
			end -- 462
			local joint = Joint(itemDef, items) -- 466
			if joint then -- 466
				items[key] = joint -- 467
			end -- 466
		end -- 447
	end) -- 446
	return root -- 468
end -- 440
return _module_0 -- 1
