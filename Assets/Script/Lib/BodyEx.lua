-- [yue]: Script/Lib/BodyEx.yue
local BodyDef = dora.BodyDef -- 1
local JointDef = dora.JointDef -- 1
local Dictionary = dora.Dictionary -- 1
local Node = dora.Node -- 1
local Vec2 = dora.Vec2 -- 1
local tolua = dora.tolua -- 1
local Body = dora.Body -- 1
local Playable = dora.Playable -- 1
local Sprite = dora.Sprite -- 1
local Joint = dora.Joint -- 1
local _module_0 = nil -- 1
local Struct = require("Utils").Struct -- 2
Struct.Array() -- 4
Struct.Phyx.Rect("name", "type", "position", "angle", "center", "size", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 6
Struct.Phyx.Disk("name", "type", "position", "angle", "center", "radius", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 27
Struct.Phyx.Poly("name", "type", "position", "angle", "vertices", "density", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "sensor", "sensorTag", "subShapes", "face", "facePos") -- 48
Struct.Phyx.Chain("name", "type", "position", "angle", "vertices", "friction", "restitution", "linearDamping", "angularDamping", "fixedRotation", "linearAcceleration", "bullet", "subShapes", "face", "facePos") -- 68
Struct.Phyx.SubRect("center", "angle", "size", "density", "friction", "restitution", "sensor", "sensorTag") -- 85
Struct.Phyx.SubDisk("center", "radius", "density", "friction", "restitution", "sensor", "sensorTag") -- 95
Struct.Phyx.SubPoly("vertices", "density", "friction", "restitution", "sensor", "sensorTag") -- 104
Struct.Phyx.SubChain("vertices", "friction", "restitution") -- 112
Struct.Phyx.Distance("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "frequency", "damping") -- 117
Struct.Phyx.Friction("name", "collision", "bodyA", "bodyB", "worldPos", "maxForce", "maxTorque") -- 127
Struct.Phyx.Gear("name", "collision", "jointA", "jointB", "ratio") -- 136
Struct.Phyx.Spring("name", "collision", "bodyA", "bodyB", "linearOffset", "angularOffset", "maxForce", "maxTorque", "correctionFactor") -- 143
Struct.Phyx.Prismatic("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "lowerTranslation", "upperTranslation", "maxMotorForce", "motorSpeed") -- 154
Struct.Phyx.Pulley("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "groundAnchorA", "groundAnchorB", "ratio") -- 166
Struct.Phyx.Revolute("name", "collision", "bodyA", "bodyB", "worldPos", "lowerAngle", "upperAngle", "maxMotorTorque", "motorSpeed") -- 177
Struct.Phyx.Rope("name", "collision", "bodyA", "bodyB", "anchorA", "anchorB", "maxLength") -- 188
Struct.Phyx.Weld("name", "collision", "bodyA", "bodyB", "worldPos", "frequency", "damping") -- 197
Struct.Phyx.Wheel("name", "collision", "bodyA", "bodyB", "worldPos", "axis", "maxMotorTorque", "motorSpeed", "frequency", "damping") -- 206
local loadFuncs = nil -- 219
local loadData -- 220
loadData = function(data, item) -- 220
	return loadFuncs[data[1]](data, item) -- 221
end -- 220
local toDef -- 223
toDef = function(data) -- 223
	local _with_0 = BodyDef() -- 223
	_with_0.type = data.type -- 224
	_with_0.bullet = data.bullet -- 225
	_with_0.linearAcceleration = data.linearAcceleration -- 226
	_with_0.fixedRotation = data.fixedRotation -- 227
	_with_0.linearDamping = data.linearDamping -- 228
	_with_0.angularDamping = data.angularDamping -- 229
	_with_0.position = data.position -- 230
	_with_0.angle = data.angle -- 231
	_with_0.face = data.face -- 232
	_with_0.facePos = data.facePos -- 233
	return _with_0 -- 223
end -- 223
loadFuncs = { -- 236
	["Array"] = function(data, itemDict) -- 236
		for i = 1, data:count() do -- 237
			loadData(data:get(i), itemDict) -- 238
		end -- 238
	end, -- 236
	["Phyx.Rect"] = function(data, itemDict) -- 240
		local bodyDef = toDef(data) -- 241
		local width, height -- 242
		do -- 242
			local _obj_0 = data.size -- 242
			width, height = _obj_0.width, _obj_0.height -- 242
		end -- 242
		if data.sensor then -- 243
			bodyDef:attachPolygonSensor(data.sensorTag, data.center, width, height) -- 244
		else -- 246
			bodyDef:attachPolygon(data.center, width, height, 0, data.density, data.friction, data.restitution) -- 246
		end -- 243
		do -- 250
			local subShapes = data.subShapes -- 250
			if subShapes then -- 250
				for i = 1, subShapes:count() do -- 251
					loadData(subShapes:get(i), bodyDef) -- 252
				end -- 252
			end -- 250
		end -- 250
		itemDict[data.name] = bodyDef -- 253
	end, -- 240
	["Phyx.Disk"] = function(data, itemDict) -- 255
		local bodyDef = toDef(data) -- 256
		if data.sensor then -- 257
			bodyDef:attachDiskSensor(data.sensorTag, data.center, data.radius) -- 258
		else -- 260
			bodyDef:attachDisk(data.center, data.radius, data.density, data.friction, data.restitution) -- 260
		end -- 257
		do -- 264
			local subShapes = data.subShapes -- 264
			if subShapes then -- 264
				for i = 1, subShapes:count() do -- 265
					loadData(subShapes:get(i), bodyDef) -- 266
				end -- 266
			end -- 264
		end -- 264
		itemDict[data.name] = bodyDef -- 267
	end, -- 255
	["Phyx.Poly"] = function(data, itemDict) -- 269
		local bodyDef = toDef(data) -- 270
		if data.sensor then -- 271
			bodyDef:attachPolygonSensor(data.sensorTag, data.vertices:toArray()) -- 272
		else -- 274
			bodyDef:attachPolygon(data.vertices:toArray(), data.density, data.friction, data.restitution) -- 274
		end -- 271
		do -- 278
			local subShapes = data.subShapes -- 278
			if subShapes then -- 278
				for i = 1, subShapes:count() do -- 279
					loadData(subShapes:get(i), bodyDef) -- 280
				end -- 280
			end -- 278
		end -- 278
		itemDict[data.name] = bodyDef -- 281
	end, -- 269
	["Phyx.Chain"] = function(data, itemDict) -- 283
		local bodyDef = toDef(data) -- 284
		bodyDef:attachChain(data.vertices:toArray(), data.friction, data.restitution) -- 285
		do -- 286
			local subShapes = data.subShapes -- 286
			if subShapes then -- 286
				for i = 1, subShapes:count() do -- 287
					loadData(subShapes:get(i), bodyDef) -- 288
				end -- 288
			end -- 286
		end -- 286
		itemDict[data.name] = bodyDef -- 289
	end, -- 283
	["Phyx.SubRect"] = function(data, bodyDef) -- 291
		local width, height -- 292
		do -- 292
			local _obj_0 = data.size -- 292
			width, height = _obj_0.width, _obj_0.height -- 292
		end -- 292
		if data.sensor then -- 293
			return bodyDef:attachPolygonSensor(data.sensorTag, data.center, width, height) -- 294
		else -- 296
			return bodyDef:attachPolygon(data.center, width, height, data.angle, data.density, data.friction, data.restitution) -- 299
		end -- 293
	end, -- 291
	["Phyx.SubDisk"] = function(data, bodyDef) -- 301
		if data.sensor then -- 302
			return bodyDef:attachDiskSensor(data.sensorTag, data.center, data.radius) -- 303
		else -- 305
			return bodyDef:attachDisk(data.center, data.radius, data.density, data.friction, data.restitution) -- 308
		end -- 302
	end, -- 301
	["Phyx.SubPoly"] = function(data, bodyDef) -- 310
		if data.sensor then -- 311
			return bodyDef:attachPolygonSensor(data.sensorTag, data.vertices:toArray()) -- 312
		else -- 314
			return bodyDef:attachPolygon(data.vertices:toArray(), data.density, data.friction, data.restitution) -- 317
		end -- 311
	end, -- 310
	["Phyx.SubChain"] = function(data, bodyDef) -- 319
		return bodyDef:attachChain(data.vertices:toArray(), data.friction, data.restitution) -- 320
	end, -- 319
	["Phyx.Distance"] = function(data, itemDict) -- 322
		itemDict[data.name] = JointDef:distance(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.frequency, data.damping) -- 323
	end, -- 322
	["Phyx.Friction"] = function(data, itemDict) -- 332
		itemDict[data.name] = JointDef:friction(data.collision, data.bodyA, data.bodyB, data.worldPos, data.maxForce, data.maxTorque) -- 333
	end, -- 332
	["Phyx.Gear"] = function(data, itemDict) -- 342
		itemDict[data.name] = JointDef:gear(data.collision, data.jointA, data.jointB, data.ratio) -- 343
	end, -- 342
	["Phyx.Spring"] = function(data, itemDict) -- 350
		itemDict[data.name] = JointDef:spring(data.collision, data.bodyA, data.bodyB, data.linearOffset, data.angularOffset, data.maxForce, data.maxTorque, data.correctionFactor) -- 351
	end, -- 350
	["Phyx.Prismatic"] = function(data, itemDict) -- 362
		itemDict[data.name] = JointDef:prismatic(data.collision, data.bodyA, data.bodyB, data.worldPos, data.axis, data.lowerTranslation, data.upperTranslation, data.maxMotorForce, data.motorSpeed) -- 363
	end, -- 362
	["Phyx.Pulley"] = function(data, itemDict) -- 375
		itemDict[data.name] = JointDef:pulley(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.groundAnchorA, data.groundAnchorB, data.ratio) -- 376
	end, -- 375
	["Phyx.Revolute"] = function(data, itemDict) -- 387
		itemDict[data.name] = JointDef:revolute(data.collision, data.bodyA, data.bodyB, data.worldPos, data.lowerAngle, data.upperAngle, data.maxMotorTorque, data.motorSpeed) -- 388
	end, -- 387
	["Phyx.Rope"] = function(data, itemDict) -- 399
		itemDict[data.name] = JointDef:rope(data.collision, data.bodyA, data.bodyB, data.anchorA, data.anchorB, data.maxLength) -- 400
	end, -- 399
	["Phyx.Weld"] = function(data, itemDict) -- 409
		itemDict[data.name] = JointDef:weld(data.collision, data.bodyA, data.bodyB, data.worldPos, data.frequency, data.damping) -- 410
	end, -- 409
	["Phyx.Wheel"] = function(data, itemDict) -- 419
		itemDict[data.name] = JointDef:wheel(data.collision, data.bodyA, data.bodyB, data.worldPos, data.axis, data.maxMotorTorque, data.motorSpeed, data.frequency, data.damping) -- 420
	end -- 419
} -- 235
_module_0 = function(bodyData, world, pos, angle) -- 432
	local itemDict = Dictionary() -- 433
	loadData(Struct:load(bodyData), itemDict) -- 434
	local root = Node() -- 435
	local items = root.data -- 436
	local center = Vec2.zero -- 437
	itemDict:each(function(itemDef, key) -- 438
		if "BodyDef" == tolua.type(itemDef) then -- 439
			local body = Body(itemDef, world, pos, angle) -- 440
			body.owner = root -- 441
			root:addChild(body) -- 442
			local faceStr = itemDef.face -- 443
			if faceStr ~= "" then -- 444
				local face -- 445
				if faceStr:match(":") then -- 445
					face = Playable(faceStr) -- 446
				else -- 448
					face = Sprite(faceStr) -- 448
				end -- 445
				if face then -- 449
					face.position = itemDef.facePos -- 450
					body:addChild(face) -- 451
				end -- 449
			end -- 444
			items[key] = body -- 452
		else -- 454
			if center then -- 454
				itemDef.center = center -- 455
				itemDef.position = pos -- 456
				itemDef.angle = angle -- 457
			end -- 454
			do -- 458
				local joint = Joint(itemDef, items) -- 458
				if joint then -- 458
					items[key] = joint -- 459
				end -- 458
			end -- 458
		end -- 439
	end) -- 438
	return root -- 460
end -- 432
return _module_0 -- 460
