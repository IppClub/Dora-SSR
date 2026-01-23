-- [yue]: Script/Lib/BodyEx.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local Struct = require("Utils").Struct -- 10
local BodyDef <const> = BodyDef -- 11
local JointDef <const> = JointDef -- 11
local Dictionary <const> = Dictionary -- 11
local Node <const> = Node -- 11
local Vec2 <const> = Vec2 -- 11
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
local loadData -- 229
loadData = function(data, item) -- 229
	return loadFuncs[data[1]](data, item) -- 230
end -- 229
local toDef -- 232
toDef = function(data) -- 232
	local _with_0 = BodyDef() -- 232
	_with_0.type = data.type -- 233
	_with_0.bullet = data.bullet -- 234
	_with_0.linearAcceleration = data.linearAcceleration -- 235
	_with_0.fixedRotation = data.fixedRotation -- 236
	_with_0.linearDamping = data.linearDamping -- 237
	_with_0.angularDamping = data.angularDamping -- 238
	_with_0.position = data.position -- 239
	_with_0.angle = data.angle -- 240
	_with_0.face = data.face -- 241
	_with_0.facePos = data.facePos -- 242
	return _with_0 -- 232
end -- 232
loadFuncs = { -- 245
	["Array"] = function(data, itemDict) -- 245
		for i = 1, data:count() do -- 246
			loadData(data:get(i), itemDict) -- 247
		end -- 246
	end, -- 245
	["Phyx.Rect"] = function(data, itemDict) -- 249
		local bodyDef = toDef(data) -- 250
		local width, height -- 251
		do -- 251
			local _obj_0 = data.size -- 251
			width, height = _obj_0.width, _obj_0.height -- 251
		end -- 251
		if data.sensor then -- 252
			bodyDef:attachPolygonSensor(data.sensorTag, data.center, width, height) -- 253
		else -- 255
			bodyDef:attachPolygon(data.center, width, height, 0, data.density, data.friction, data.restitution) -- 255
		end -- 252
		do -- 259
			local subShapes = data.subShapes -- 259
			if subShapes then -- 259
				for i = 1, subShapes:count() do -- 260
					loadData(subShapes:get(i), bodyDef) -- 261
				end -- 260
			end -- 259
		end -- 259
		itemDict[data.name] = bodyDef -- 262
	end, -- 249
	["Phyx.Disk"] = function(data, itemDict) -- 264
		local bodyDef = toDef(data) -- 265
		if data.sensor then -- 266
			bodyDef:attachDiskSensor(data.sensorTag, data.center, data.radius) -- 267
		else -- 269
			bodyDef:attachDisk(data.center, data.radius, data.density, data.friction, data.restitution) -- 269
		end -- 266
		do -- 273
			local subShapes = data.subShapes -- 273
			if subShapes then -- 273
				for i = 1, subShapes:count() do -- 274
					loadData(subShapes:get(i), bodyDef) -- 275
				end -- 274
			end -- 273
		end -- 273
		itemDict[data.name] = bodyDef -- 276
	end, -- 264
	["Phyx.Poly"] = function(data, itemDict) -- 278
		local bodyDef = toDef(data) -- 279
		if data.sensor then -- 280
			bodyDef:attachPolygonSensor(data.sensorTag, data.vertices:toArray()) -- 281
		else -- 283
			bodyDef:attachPolygon(data.vertices:toArray(), data.density, data.friction, data.restitution) -- 283
		end -- 280
		do -- 287
			local subShapes = data.subShapes -- 287
			if subShapes then -- 287
				for i = 1, subShapes:count() do -- 288
					loadData(subShapes:get(i), bodyDef) -- 289
				end -- 288
			end -- 287
		end -- 287
		itemDict[data.name] = bodyDef -- 290
	end, -- 278
	["Phyx.Chain"] = function(data, itemDict) -- 292
		local bodyDef = toDef(data) -- 293
		bodyDef:attachChain(data.vertices:toArray(), data.friction, data.restitution) -- 294
		do -- 295
			local subShapes = data.subShapes -- 295
			if subShapes then -- 295
				for i = 1, subShapes:count() do -- 296
					loadData(subShapes:get(i), bodyDef) -- 297
				end -- 296
			end -- 295
		end -- 295
		itemDict[data.name] = bodyDef -- 298
	end, -- 292
	["Phyx.SubRect"] = function(data, bodyDef) -- 300
		local width, height -- 301
		do -- 301
			local _obj_0 = data.size -- 301
			width, height = _obj_0.width, _obj_0.height -- 301
		end -- 301
		if data.sensor then -- 302
			return bodyDef:attachPolygonSensor(data.sensorTag, data.center, width, height) -- 303
		else -- 305
			return bodyDef:attachPolygon(data.center, width, height, data.angle, data.density, data.friction, data.restitution) -- 305
		end -- 302
	end, -- 300
	["Phyx.SubDisk"] = function(data, bodyDef) -- 310
		if data.sensor then -- 311
			return bodyDef:attachDiskSensor(data.sensorTag, data.center, data.radius) -- 312
		else -- 314
			return bodyDef:attachDisk(data.center, data.radius, data.density, data.friction, data.restitution) -- 314
		end -- 311
	end, -- 310
	["Phyx.SubPoly"] = function(data, bodyDef) -- 319
		if data.sensor then -- 320
			return bodyDef:attachPolygonSensor(data.sensorTag, data.vertices:toArray()) -- 321
		else -- 323
			return bodyDef:attachPolygon(data.vertices:toArray(), data.density, data.friction, data.restitution) -- 323
		end -- 320
	end, -- 319
	["Phyx.SubChain"] = function(data, bodyDef) -- 328
		return bodyDef:attachChain(data.vertices:toArray(), data.friction, data.restitution) -- 329
	end, -- 328
	["Phyx.Distance"] = function(data, itemDict) -- 331
		itemDict[data.name] = JointDef:distance(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.frequency, data.damping) -- 332
	end, -- 331
	["Phyx.Friction"] = function(data, itemDict) -- 341
		itemDict[data.name] = JointDef:friction(data.collision, data.bodyA, data.bodyB, data.worldPos, data.maxForce, data.maxTorque) -- 342
	end, -- 341
	["Phyx.Gear"] = function(data, itemDict) -- 351
		itemDict[data.name] = JointDef:gear(data.collision, data.jointA, data.jointB, data.ratio) -- 352
	end, -- 351
	["Phyx.Spring"] = function(data, itemDict) -- 359
		itemDict[data.name] = JointDef:spring(data.collision, data.bodyA, data.bodyB, data.linearOffset, data.angularOffset, data.maxForce, data.maxTorque, data.correctionFactor) -- 360
	end, -- 359
	["Phyx.Prismatic"] = function(data, itemDict) -- 371
		itemDict[data.name] = JointDef:prismatic(data.collision, data.bodyA, data.bodyB, data.worldPos, data.axis, data.lowerTranslation, data.upperTranslation, data.maxMotorForce, data.motorSpeed) -- 372
	end, -- 371
	["Phyx.Pulley"] = function(data, itemDict) -- 384
		itemDict[data.name] = JointDef:pulley(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.groundAnchorA, data.groundAnchorB, data.ratio) -- 385
	end, -- 384
	["Phyx.Revolute"] = function(data, itemDict) -- 396
		itemDict[data.name] = JointDef:revolute(data.collision, data.bodyA, data.bodyB, data.worldPos, data.lowerAngle, data.upperAngle, data.maxMotorTorque, data.motorSpeed) -- 397
	end, -- 396
	["Phyx.Rope"] = function(data, itemDict) -- 408
		itemDict[data.name] = JointDef:rope(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.maxLength) -- 409
	end, -- 408
	["Phyx.Weld"] = function(data, itemDict) -- 418
		itemDict[data.name] = JointDef:weld(data.collision, data.bodyA, data.bodyB, data.worldPos, data.frequency, data.damping) -- 419
	end, -- 418
	["Phyx.Wheel"] = function(data, itemDict) -- 428
		itemDict[data.name] = JointDef:wheel(data.collision, data.bodyA, data.bodyB, data.worldPos, data.axis, data.maxMotorTorque, data.motorSpeed, data.frequency, data.damping) -- 429
	end -- 428
} -- 244
_module_0 = function(bodyData, world, pos, angle) -- 441
	local itemDict = Dictionary() -- 442
	loadData(Struct:load(bodyData), itemDict) -- 443
	local root = Node() -- 444
	local items = root.data -- 445
	local center = Vec2.zero -- 446
	itemDict:each(function(itemDef, key) -- 447
		if "BodyDef" == tolua.type(itemDef) then -- 448
			local body = Body(itemDef, world, pos, angle) -- 449
			body.owner = root -- 450
			root:addChild(body) -- 451
			local faceStr = itemDef.face -- 452
			if faceStr ~= "" then -- 453
				local face -- 454
				if faceStr:match(":") then -- 454
					face = Playable(faceStr) -- 455
				else -- 457
					face = Sprite(faceStr) -- 457
				end -- 454
				if face then -- 458
					face.position = itemDef.facePos -- 459
					body:addChild(face) -- 460
				end -- 458
			end -- 453
			items[key] = body -- 461
		else -- 463
			if center then -- 463
				itemDef.center = center -- 464
				itemDef.position = pos -- 465
				itemDef.angle = angle -- 466
			end -- 463
			local joint = Joint(itemDef, items) -- 467
			if joint then -- 467
				items[key] = joint -- 468
			end -- 467
		end -- 448
	end) -- 447
	return root -- 469
end -- 441
return _module_0 -- 1
