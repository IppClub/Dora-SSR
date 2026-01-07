-- [ts]: DoraX.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Spread = ____lualib.__TS__Spread -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local Warn, visitNode, actionMap, elementMap -- 1
local Dora = require("Dora") -- 11
function Warn(msg) -- 13
	Dora.Log("Warn", "[Dora Warning] " .. msg) -- 14
end -- 14
function visitNode(nodeStack, node, parent) -- 1459
	if type(node) ~= "table" then -- 1459
		return -- 1461
	end -- 1461
	local enode = node -- 1463
	if enode.type == nil then -- 1463
		local list = node -- 1465
		if #list > 0 then -- 1465
			for i = 1, #list do -- 1465
				local stack = {} -- 1468
				visitNode(stack, list[i], parent) -- 1469
				for i = 1, #stack do -- 1469
					nodeStack[#nodeStack + 1] = stack[i] -- 1471
				end -- 1471
			end -- 1471
		end -- 1471
	else -- 1471
		local handler = elementMap[enode.type] -- 1476
		if handler ~= nil then -- 1476
			handler(nodeStack, enode, parent) -- 1478
		else -- 1478
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1480
		end -- 1480
	end -- 1480
end -- 1480
function ____exports.toNode(enode) -- 1485
	local nodeStack = {} -- 1486
	visitNode(nodeStack, enode) -- 1487
	if #nodeStack == 1 then -- 1487
		return nodeStack[1] -- 1489
	elseif #nodeStack > 1 then -- 1489
		local node = Dora.Node() -- 1491
		for i = 1, #nodeStack do -- 1491
			node:addChild(nodeStack[i]) -- 1493
		end -- 1493
		return node -- 1495
	end -- 1495
	return nil -- 1497
end -- 1485
____exports.React = {} -- 1485
local React = ____exports.React -- 1485
do -- 1485
	React.Component = __TS__Class() -- 17
	local Component = React.Component -- 17
	Component.name = "Component" -- 19
	function Component.prototype.____constructor(self, props) -- 20
		self.props = props -- 21
	end -- 20
	Component.isComponent = true -- 20
	React.Fragment = nil -- 17
	local function flattenChild(child) -- 30
		if type(child) ~= "table" then -- 30
			return child, true -- 32
		end -- 32
		if child.type ~= nil then -- 32
			return child, true -- 35
		elseif child.children then -- 35
			child = child.children -- 37
		end -- 37
		local list = child -- 39
		local flatChildren = {} -- 40
		for i = 1, #list do -- 40
			local child, flat = flattenChild(list[i]) -- 42
			if flat then -- 42
				flatChildren[#flatChildren + 1] = child -- 44
			else -- 44
				local listChild = child -- 46
				for i = 1, #listChild do -- 46
					flatChildren[#flatChildren + 1] = listChild[i] -- 48
				end -- 48
			end -- 48
		end -- 48
		return flatChildren, false -- 52
	end -- 30
	function React.createElement(typeName, props, ...) -- 61
		local children = {...} -- 61
		local items = {} -- 66
		for ____, v in pairs(children) do -- 67
			items[#items + 1] = v -- 68
		end -- 68
		children = items -- 70
		repeat -- 70
			local ____switch15 = type(typeName) -- 70
			local ____cond15 = ____switch15 == "function" -- 70
			if ____cond15 then -- 70
				do -- 70
					if props == nil then -- 70
						props = {} -- 73
					end -- 73
					if props.children then -- 73
						local ____props_1 = props -- 75
						local ____array_0 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 75
						__TS__SparseArrayPush( -- 75
							____array_0, -- 75
							table.unpack(children) -- 75
						) -- 75
						____props_1.children = {__TS__SparseArraySpread(____array_0)} -- 75
					else -- 75
						props.children = children -- 77
					end -- 77
					return typeName(props) -- 79
				end -- 79
			end -- 79
			____cond15 = ____cond15 or ____switch15 == "table" -- 79
			if ____cond15 then -- 79
				do -- 79
					if not typeName.isComponent then -- 79
						Warn("unsupported class object in element creation") -- 83
						return {} -- 84
					end -- 84
					if props == nil then -- 84
						props = {} -- 86
					end -- 86
					if props.children then -- 86
						local ____props_3 = props -- 88
						local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 88
						__TS__SparseArrayPush( -- 88
							____array_2, -- 88
							table.unpack(children) -- 88
						) -- 88
						____props_3.children = {__TS__SparseArraySpread(____array_2)} -- 88
					else -- 88
						props.children = children -- 90
					end -- 90
					local inst = __TS__New(typeName, props) -- 92
					return inst:render() -- 93
				end -- 93
			end -- 93
			do -- 93
				do -- 93
					if props and props.children then -- 93
						local ____array_4 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 93
						__TS__SparseArrayPush( -- 93
							____array_4, -- 93
							table.unpack(children) -- 97
						) -- 97
						children = {__TS__SparseArraySpread(____array_4)} -- 97
						props.children = nil -- 98
					end -- 98
					local flatChildren = {} -- 100
					for i = 1, #children do -- 100
						local child, flat = flattenChild(children[i]) -- 102
						if flat then -- 102
							flatChildren[#flatChildren + 1] = child -- 104
						else -- 104
							for i = 1, #child do -- 104
								flatChildren[#flatChildren + 1] = child[i] -- 107
							end -- 107
						end -- 107
					end -- 107
					children = flatChildren -- 111
				end -- 111
			end -- 111
		until true -- 111
		if typeName == nil then -- 111
			return children -- 115
		end -- 115
		local ____typeName_6 = typeName -- 118
		local ____props_5 = props -- 119
		if ____props_5 == nil then -- 119
			____props_5 = {} -- 119
		end -- 119
		return {type = ____typeName_6, props = ____props_5, children = children} -- 117
	end -- 61
end -- 61
local function getNode(enode, cnode, attribHandler) -- 128
	cnode = cnode or Dora.Node() -- 129
	local jnode = enode.props -- 130
	local anchor = nil -- 131
	local color3 = nil -- 132
	for k, v in pairs(enode.props) do -- 133
		repeat -- 133
			local ____switch32 = k -- 133
			local ____cond32 = ____switch32 == "ref" -- 133
			if ____cond32 then -- 133
				v.current = cnode -- 135
				break -- 135
			end -- 135
			____cond32 = ____cond32 or ____switch32 == "anchorX" -- 135
			if ____cond32 then -- 135
				anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 136
				break -- 136
			end -- 136
			____cond32 = ____cond32 or ____switch32 == "anchorY" -- 136
			if ____cond32 then -- 136
				anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 137
				break -- 137
			end -- 137
			____cond32 = ____cond32 or ____switch32 == "color3" -- 137
			if ____cond32 then -- 137
				color3 = Dora.Color3(v) -- 138
				break -- 138
			end -- 138
			____cond32 = ____cond32 or ____switch32 == "transformTarget" -- 138
			if ____cond32 then -- 138
				cnode.transformTarget = v.current -- 139
				break -- 139
			end -- 139
			____cond32 = ____cond32 or ____switch32 == "onUpdate" -- 139
			if ____cond32 then -- 139
				cnode:schedule(v) -- 140
				break -- 140
			end -- 140
			____cond32 = ____cond32 or ____switch32 == "onActionEnd" -- 140
			if ____cond32 then -- 140
				cnode:slot("ActionEnd", v) -- 141
				break -- 141
			end -- 141
			____cond32 = ____cond32 or ____switch32 == "onTapFilter" -- 141
			if ____cond32 then -- 141
				cnode:slot("TapFilter", v) -- 142
				break -- 142
			end -- 142
			____cond32 = ____cond32 or ____switch32 == "onTapBegan" -- 142
			if ____cond32 then -- 142
				cnode:slot("TapBegan", v) -- 143
				break -- 143
			end -- 143
			____cond32 = ____cond32 or ____switch32 == "onTapEnded" -- 143
			if ____cond32 then -- 143
				cnode:slot("TapEnded", v) -- 144
				break -- 144
			end -- 144
			____cond32 = ____cond32 or ____switch32 == "onTapped" -- 144
			if ____cond32 then -- 144
				cnode:slot("Tapped", v) -- 145
				break -- 145
			end -- 145
			____cond32 = ____cond32 or ____switch32 == "onTapMoved" -- 145
			if ____cond32 then -- 145
				cnode:slot("TapMoved", v) -- 146
				break -- 146
			end -- 146
			____cond32 = ____cond32 or ____switch32 == "onMouseWheel" -- 146
			if ____cond32 then -- 146
				cnode:slot("MouseWheel", v) -- 147
				break -- 147
			end -- 147
			____cond32 = ____cond32 or ____switch32 == "onGesture" -- 147
			if ____cond32 then -- 147
				cnode:slot("Gesture", v) -- 148
				break -- 148
			end -- 148
			____cond32 = ____cond32 or ____switch32 == "onEnter" -- 148
			if ____cond32 then -- 148
				cnode:slot("Enter", v) -- 149
				break -- 149
			end -- 149
			____cond32 = ____cond32 or ____switch32 == "onExit" -- 149
			if ____cond32 then -- 149
				cnode:slot("Exit", v) -- 150
				break -- 150
			end -- 150
			____cond32 = ____cond32 or ____switch32 == "onCleanup" -- 150
			if ____cond32 then -- 150
				cnode:slot("Cleanup", v) -- 151
				break -- 151
			end -- 151
			____cond32 = ____cond32 or ____switch32 == "onKeyDown" -- 151
			if ____cond32 then -- 151
				cnode:slot("KeyDown", v) -- 152
				break -- 152
			end -- 152
			____cond32 = ____cond32 or ____switch32 == "onKeyUp" -- 152
			if ____cond32 then -- 152
				cnode:slot("KeyUp", v) -- 153
				break -- 153
			end -- 153
			____cond32 = ____cond32 or ____switch32 == "onKeyPressed" -- 153
			if ____cond32 then -- 153
				cnode:slot("KeyPressed", v) -- 154
				break -- 154
			end -- 154
			____cond32 = ____cond32 or ____switch32 == "onAttachIME" -- 154
			if ____cond32 then -- 154
				cnode:slot("AttachIME", v) -- 155
				break -- 155
			end -- 155
			____cond32 = ____cond32 or ____switch32 == "onDetachIME" -- 155
			if ____cond32 then -- 155
				cnode:slot("DetachIME", v) -- 156
				break -- 156
			end -- 156
			____cond32 = ____cond32 or ____switch32 == "onTextInput" -- 156
			if ____cond32 then -- 156
				cnode:slot("TextInput", v) -- 157
				break -- 157
			end -- 157
			____cond32 = ____cond32 or ____switch32 == "onTextEditing" -- 157
			if ____cond32 then -- 157
				cnode:slot("TextEditing", v) -- 158
				break -- 158
			end -- 158
			____cond32 = ____cond32 or ____switch32 == "onButtonDown" -- 158
			if ____cond32 then -- 158
				cnode:slot("ButtonDown", v) -- 159
				break -- 159
			end -- 159
			____cond32 = ____cond32 or ____switch32 == "onButtonUp" -- 159
			if ____cond32 then -- 159
				cnode:slot("ButtonUp", v) -- 160
				break -- 160
			end -- 160
			____cond32 = ____cond32 or ____switch32 == "onAxis" -- 160
			if ____cond32 then -- 160
				cnode:slot("Axis", v) -- 161
				break -- 161
			end -- 161
			do -- 161
				do -- 161
					if attribHandler then -- 161
						if not attribHandler(cnode, enode, k, v) then -- 161
							cnode[k] = v -- 165
						end -- 165
					else -- 165
						cnode[k] = v -- 168
					end -- 168
					break -- 170
				end -- 170
			end -- 170
		until true -- 170
	end -- 170
	if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 170
		cnode.touchEnabled = true -- 183
	end -- 183
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 183
		cnode.keyboardEnabled = true -- 190
	end -- 190
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 190
		cnode.controllerEnabled = true -- 197
	end -- 197
	if anchor ~= nil then -- 197
		cnode.anchor = anchor -- 199
	end -- 199
	if color3 ~= nil then -- 199
		cnode.color3 = color3 -- 200
	end -- 200
	if jnode.onMount ~= nil then -- 200
		jnode.onMount(cnode) -- 202
	end -- 202
	return cnode -- 204
end -- 128
local getClipNode -- 207
do -- 207
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 209
		repeat -- 209
			local ____switch45 = k -- 209
			local ____cond45 = ____switch45 == "stencil" -- 209
			if ____cond45 then -- 209
				cnode.stencil = ____exports.toNode(v) -- 216
				return true -- 216
			end -- 216
		until true -- 216
		return false -- 218
	end -- 209
	getClipNode = function(enode) -- 220
		return getNode( -- 221
			enode, -- 221
			Dora.ClipNode(), -- 221
			handleClipNodeAttribute -- 221
		) -- 221
	end -- 220
end -- 220
local getPlayable -- 225
local getDragonBone -- 226
local getSpine -- 227
local getModel -- 228
do -- 228
	local function handlePlayableAttribute(cnode, enode, k, v) -- 230
		repeat -- 230
			local ____switch49 = k -- 230
			local ____cond49 = ____switch49 == "file" -- 230
			if ____cond49 then -- 230
				return true -- 232
			end -- 232
			____cond49 = ____cond49 or ____switch49 == "play" -- 232
			if ____cond49 then -- 232
				cnode:play(v, enode.props.loop == true) -- 233
				return true -- 233
			end -- 233
			____cond49 = ____cond49 or ____switch49 == "loop" -- 233
			if ____cond49 then -- 233
				return true -- 234
			end -- 234
			____cond49 = ____cond49 or ____switch49 == "onAnimationEnd" -- 234
			if ____cond49 then -- 234
				cnode:slot("AnimationEnd", v) -- 235
				return true -- 235
			end -- 235
		until true -- 235
		return false -- 237
	end -- 230
	getPlayable = function(enode, cnode, attribHandler) -- 239
		if attribHandler == nil then -- 239
			attribHandler = handlePlayableAttribute -- 240
		end -- 240
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 241
		if cnode ~= nil then -- 241
			return getNode(enode, cnode, attribHandler) -- 243
		end -- 243
		return nil -- 245
	end -- 239
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 248
		repeat -- 248
			local ____switch53 = k -- 248
			local ____cond53 = ____switch53 == "hitTestEnabled" -- 248
			if ____cond53 then -- 248
				cnode.hitTestEnabled = true -- 250
				return true -- 250
			end -- 250
		until true -- 250
		return handlePlayableAttribute(cnode, enode, k, v) -- 252
	end -- 248
	getDragonBone = function(enode) -- 254
		local node = Dora.DragonBone(enode.props.file) -- 255
		if node ~= nil then -- 255
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 257
			return cnode -- 258
		end -- 258
		return nil -- 260
	end -- 254
	local function handleSpineAttribute(cnode, enode, k, v) -- 263
		repeat -- 263
			local ____switch57 = k -- 263
			local ____cond57 = ____switch57 == "hitTestEnabled" -- 263
			if ____cond57 then -- 263
				cnode.hitTestEnabled = true -- 265
				return true -- 265
			end -- 265
		until true -- 265
		return handlePlayableAttribute(cnode, enode, k, v) -- 267
	end -- 263
	getSpine = function(enode) -- 269
		local node = Dora.Spine(enode.props.file) -- 270
		if node ~= nil then -- 270
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 272
			return cnode -- 273
		end -- 273
		return nil -- 275
	end -- 269
	local function handleModelAttribute(cnode, enode, k, v) -- 278
		repeat -- 278
			local ____switch61 = k -- 278
			local ____cond61 = ____switch61 == "reversed" -- 278
			if ____cond61 then -- 278
				cnode.reversed = v -- 280
				return true -- 280
			end -- 280
		until true -- 280
		return handlePlayableAttribute(cnode, enode, k, v) -- 282
	end -- 278
	getModel = function(enode) -- 284
		local node = Dora.Model(enode.props.file) -- 285
		if node ~= nil then -- 285
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 287
			return cnode -- 288
		end -- 288
		return nil -- 290
	end -- 284
end -- 284
local getDrawNode -- 294
do -- 294
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 296
		repeat -- 296
			local ____switch66 = k -- 296
			local ____cond66 = ____switch66 == "depthWrite" -- 296
			if ____cond66 then -- 296
				cnode.depthWrite = v -- 298
				return true -- 298
			end -- 298
			____cond66 = ____cond66 or ____switch66 == "blendFunc" -- 298
			if ____cond66 then -- 298
				cnode.blendFunc = v -- 299
				return true -- 299
			end -- 299
		until true -- 299
		return false -- 301
	end -- 296
	getDrawNode = function(enode) -- 303
		local node = Dora.DrawNode() -- 304
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 305
		local ____enode_7 = enode -- 306
		local children = ____enode_7.children -- 306
		for i = 1, #children do -- 306
			do -- 306
				local child = children[i] -- 308
				if type(child) ~= "table" then -- 308
					goto __continue68 -- 310
				end -- 310
				repeat -- 310
					local ____switch70 = child.type -- 310
					local ____cond70 = ____switch70 == "dot-shape" -- 310
					if ____cond70 then -- 310
						do -- 310
							local dot = child.props -- 314
							node:drawDot( -- 315
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 316
								dot.radius, -- 317
								Dora.Color(dot.color or 4294967295) -- 318
							) -- 318
							break -- 320
						end -- 320
					end -- 320
					____cond70 = ____cond70 or ____switch70 == "segment-shape" -- 320
					if ____cond70 then -- 320
						do -- 320
							local segment = child.props -- 323
							node:drawSegment( -- 324
								Dora.Vec2(segment.startX, segment.startY), -- 325
								Dora.Vec2(segment.stopX, segment.stopY), -- 326
								segment.radius, -- 327
								Dora.Color(segment.color or 4294967295) -- 328
							) -- 328
							break -- 330
						end -- 330
					end -- 330
					____cond70 = ____cond70 or ____switch70 == "rect-shape" -- 330
					if ____cond70 then -- 330
						do -- 330
							local rect = child.props -- 333
							local centerX = rect.centerX or 0 -- 334
							local centerY = rect.centerY or 0 -- 335
							local hw = rect.width / 2 -- 336
							local hh = rect.height / 2 -- 337
							node:drawPolygon( -- 338
								{ -- 339
									Dora.Vec2(centerX - hw, centerY + hh), -- 340
									Dora.Vec2(centerX + hw, centerY + hh), -- 341
									Dora.Vec2(centerX + hw, centerY - hh), -- 342
									Dora.Vec2(centerX - hw, centerY - hh) -- 343
								}, -- 343
								Dora.Color(rect.fillColor or 4294967295), -- 345
								rect.borderWidth or 0, -- 346
								Dora.Color(rect.borderColor or 4294967295) -- 347
							) -- 347
							break -- 349
						end -- 349
					end -- 349
					____cond70 = ____cond70 or ____switch70 == "polygon-shape" -- 349
					if ____cond70 then -- 349
						do -- 349
							local poly = child.props -- 352
							node:drawPolygon( -- 353
								poly.verts, -- 354
								Dora.Color(poly.fillColor or 4294967295), -- 355
								poly.borderWidth or 0, -- 356
								Dora.Color(poly.borderColor or 4294967295) -- 357
							) -- 357
							break -- 359
						end -- 359
					end -- 359
					____cond70 = ____cond70 or ____switch70 == "verts-shape" -- 359
					if ____cond70 then -- 359
						do -- 359
							local verts = child.props -- 362
							node:drawVertices(__TS__ArrayMap( -- 363
								verts.verts, -- 363
								function(____, ____bindingPattern0) -- 363
									local color -- 363
									local vert -- 363
									vert = ____bindingPattern0[1] -- 363
									color = ____bindingPattern0[2] -- 363
									return { -- 363
										vert, -- 363
										Dora.Color(color) -- 363
									} -- 363
								end -- 363
							)) -- 363
							break -- 364
						end -- 364
					end -- 364
				until true -- 364
			end -- 364
			::__continue68:: -- 364
		end -- 364
		return cnode -- 368
	end -- 303
end -- 303
local getGrid -- 372
do -- 372
	local function handleGridAttribute(cnode, _enode, k, v) -- 374
		repeat -- 374
			local ____switch79 = k -- 374
			local ____cond79 = ____switch79 == "file" or ____switch79 == "gridX" or ____switch79 == "gridY" -- 374
			if ____cond79 then -- 374
				return true -- 376
			end -- 376
			____cond79 = ____cond79 or ____switch79 == "textureRect" -- 376
			if ____cond79 then -- 376
				cnode.textureRect = v -- 377
				return true -- 377
			end -- 377
			____cond79 = ____cond79 or ____switch79 == "depthWrite" -- 377
			if ____cond79 then -- 377
				cnode.depthWrite = v -- 378
				return true -- 378
			end -- 378
			____cond79 = ____cond79 or ____switch79 == "blendFunc" -- 378
			if ____cond79 then -- 378
				cnode.blendFunc = v -- 379
				return true -- 379
			end -- 379
			____cond79 = ____cond79 or ____switch79 == "effect" -- 379
			if ____cond79 then -- 379
				cnode.effect = v -- 380
				return true -- 380
			end -- 380
		until true -- 380
		return false -- 382
	end -- 374
	getGrid = function(enode) -- 384
		local grid = enode.props -- 385
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 386
		local cnode = getNode(enode, node, handleGridAttribute) -- 387
		return cnode -- 388
	end -- 384
end -- 384
local getSprite -- 392
local getVideoNode -- 393
local getTIC80Node -- 394
do -- 394
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 396
		repeat -- 396
			local ____switch83 = k -- 396
			local ____cond83 = ____switch83 == "file" -- 396
			if ____cond83 then -- 396
				return true -- 398
			end -- 398
			____cond83 = ____cond83 or ____switch83 == "textureRect" -- 398
			if ____cond83 then -- 398
				cnode.textureRect = v -- 399
				return true -- 399
			end -- 399
			____cond83 = ____cond83 or ____switch83 == "depthWrite" -- 399
			if ____cond83 then -- 399
				cnode.depthWrite = v -- 400
				return true -- 400
			end -- 400
			____cond83 = ____cond83 or ____switch83 == "blendFunc" -- 400
			if ____cond83 then -- 400
				cnode.blendFunc = v -- 401
				return true -- 401
			end -- 401
			____cond83 = ____cond83 or ____switch83 == "effect" -- 401
			if ____cond83 then -- 401
				cnode.effect = v -- 402
				return true -- 402
			end -- 402
			____cond83 = ____cond83 or ____switch83 == "alphaRef" -- 402
			if ____cond83 then -- 402
				cnode.alphaRef = v -- 403
				return true -- 403
			end -- 403
			____cond83 = ____cond83 or ____switch83 == "uwrap" -- 403
			if ____cond83 then -- 403
				cnode.uwrap = v -- 404
				return true -- 404
			end -- 404
			____cond83 = ____cond83 or ____switch83 == "vwrap" -- 404
			if ____cond83 then -- 404
				cnode.vwrap = v -- 405
				return true -- 405
			end -- 405
			____cond83 = ____cond83 or ____switch83 == "filter" -- 405
			if ____cond83 then -- 405
				cnode.filter = v -- 406
				return true -- 406
			end -- 406
		until true -- 406
		return false -- 408
	end -- 396
	getSprite = function(enode) -- 410
		local sp = enode.props -- 411
		if sp.file then -- 411
			local node = Dora.Sprite(sp.file) -- 413
			if node ~= nil then -- 413
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 415
				return cnode -- 416
			end -- 416
		else -- 416
			local node = Dora.Sprite() -- 419
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 420
			return cnode -- 421
		end -- 421
		return nil -- 423
	end -- 410
	getVideoNode = function(enode) -- 425
		local vn = enode.props -- 426
		local ____Dora_VideoNode_10 = Dora.VideoNode -- 427
		local ____vn_file_9 = vn.file -- 427
		local ____vn_looped_8 = vn.looped -- 427
		if ____vn_looped_8 == nil then -- 427
			____vn_looped_8 = false -- 427
		end -- 427
		local node = ____Dora_VideoNode_10(____vn_file_9, ____vn_looped_8) -- 427
		if node ~= nil then -- 427
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 429
			return cnode -- 430
		end -- 430
		return nil -- 432
	end -- 425
	getTIC80Node = function(enode) -- 434
		local tic = enode.props -- 435
		local node = Dora.TIC80Node(tic.file) -- 436
		if node ~= nil then -- 436
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 438
			return cnode -- 439
		end -- 439
		return nil -- 441
	end -- 434
end -- 434
local getAudioSource -- 445
do -- 445
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 447
		repeat -- 447
			local ____switch94 = k -- 447
			local ____cond94 = ____switch94 == "file" -- 447
			if ____cond94 then -- 447
				return true -- 449
			end -- 449
			____cond94 = ____cond94 or ____switch94 == "autoRemove" -- 449
			if ____cond94 then -- 449
				return true -- 450
			end -- 450
			____cond94 = ____cond94 or ____switch94 == "bus" -- 450
			if ____cond94 then -- 450
				return true -- 451
			end -- 451
			____cond94 = ____cond94 or ____switch94 == "volume" -- 451
			if ____cond94 then -- 451
				cnode.volume = v -- 452
				return true -- 452
			end -- 452
			____cond94 = ____cond94 or ____switch94 == "pan" -- 452
			if ____cond94 then -- 452
				cnode.pan = v -- 453
				return true -- 453
			end -- 453
			____cond94 = ____cond94 or ____switch94 == "looping" -- 453
			if ____cond94 then -- 453
				cnode.looping = v -- 454
				return true -- 454
			end -- 454
			____cond94 = ____cond94 or ____switch94 == "playMode" -- 454
			if ____cond94 then -- 454
				do -- 454
					local aus = enode.props -- 456
					repeat -- 456
						local ____switch96 = v -- 456
						local ____cond96 = ____switch96 == "normal" -- 456
						if ____cond96 then -- 456
							cnode:play(aus.delayTime or 0) -- 458
							break -- 458
						end -- 458
						____cond96 = ____cond96 or ____switch96 == "background" -- 458
						if ____cond96 then -- 458
							cnode:playBackground() -- 459
							break -- 459
						end -- 459
						____cond96 = ____cond96 or ____switch96 == "3D" -- 459
						if ____cond96 then -- 459
							cnode:play3D(aus.delayTime or 0) -- 460
							break -- 460
						end -- 460
					until true -- 460
					return true -- 462
				end -- 462
			end -- 462
			____cond94 = ____cond94 or ____switch94 == "delayTime" -- 462
			if ____cond94 then -- 462
				return true -- 464
			end -- 464
			____cond94 = ____cond94 or ____switch94 == "protected" -- 464
			if ____cond94 then -- 464
				cnode:setProtected(v) -- 465
				return true -- 465
			end -- 465
			____cond94 = ____cond94 or ____switch94 == "loopPoint" -- 465
			if ____cond94 then -- 465
				cnode:setLoopPoint(v) -- 466
				return true -- 466
			end -- 466
			____cond94 = ____cond94 or ____switch94 == "velocity" -- 466
			if ____cond94 then -- 466
				do -- 466
					local vx, vy, vz = table.unpack(v, 1, 3) -- 468
					cnode:setVelocity(vx, vy, vz) -- 469
					return true -- 470
				end -- 470
			end -- 470
			____cond94 = ____cond94 or ____switch94 == "minMaxDistance" -- 470
			if ____cond94 then -- 470
				do -- 470
					local min, max = table.unpack(v, 1, 2) -- 473
					cnode:setMinMaxDistance(min, max) -- 474
					return true -- 475
				end -- 475
			end -- 475
			____cond94 = ____cond94 or ____switch94 == "attenuation" -- 475
			if ____cond94 then -- 475
				do -- 475
					local model, factor = table.unpack(v, 1, 2) -- 478
					cnode:setAttenuation(model, factor) -- 479
					return true -- 480
				end -- 480
			end -- 480
			____cond94 = ____cond94 or ____switch94 == "dopplerFactor" -- 480
			if ____cond94 then -- 480
				cnode:setDopplerFactor(v) -- 482
				return true -- 482
			end -- 482
		until true -- 482
		return false -- 484
	end -- 447
	getAudioSource = function(enode) -- 486
		local aus = enode.props -- 487
		local ____aus_autoRemove_11 = aus.autoRemove -- 488
		if ____aus_autoRemove_11 == nil then -- 488
			____aus_autoRemove_11 = true -- 488
		end -- 488
		local autoRemove = ____aus_autoRemove_11 -- 488
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 489
		if node ~= nil then -- 489
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 491
			return cnode -- 492
		end -- 492
		return nil -- 494
	end -- 486
end -- 486
local getLabel -- 498
do -- 498
	local function handleLabelAttribute(cnode, _enode, k, v) -- 500
		repeat -- 500
			local ____switch104 = k -- 500
			local ____cond104 = ____switch104 == "fontName" or ____switch104 == "fontSize" or ____switch104 == "text" or ____switch104 == "smoothLower" or ____switch104 == "smoothUpper" -- 500
			if ____cond104 then -- 500
				return true -- 502
			end -- 502
			____cond104 = ____cond104 or ____switch104 == "alphaRef" -- 502
			if ____cond104 then -- 502
				cnode.alphaRef = v -- 503
				return true -- 503
			end -- 503
			____cond104 = ____cond104 or ____switch104 == "textWidth" -- 503
			if ____cond104 then -- 503
				cnode.textWidth = v -- 504
				return true -- 504
			end -- 504
			____cond104 = ____cond104 or ____switch104 == "lineGap" -- 504
			if ____cond104 then -- 504
				cnode.lineGap = v -- 505
				return true -- 505
			end -- 505
			____cond104 = ____cond104 or ____switch104 == "spacing" -- 505
			if ____cond104 then -- 505
				cnode.spacing = v -- 506
				return true -- 506
			end -- 506
			____cond104 = ____cond104 or ____switch104 == "outlineColor" -- 506
			if ____cond104 then -- 506
				cnode.outlineColor = Dora.Color(v) -- 507
				return true -- 507
			end -- 507
			____cond104 = ____cond104 or ____switch104 == "outlineWidth" -- 507
			if ____cond104 then -- 507
				cnode.outlineWidth = v -- 508
				return true -- 508
			end -- 508
			____cond104 = ____cond104 or ____switch104 == "blendFunc" -- 508
			if ____cond104 then -- 508
				cnode.blendFunc = v -- 509
				return true -- 509
			end -- 509
			____cond104 = ____cond104 or ____switch104 == "depthWrite" -- 509
			if ____cond104 then -- 509
				cnode.depthWrite = v -- 510
				return true -- 510
			end -- 510
			____cond104 = ____cond104 or ____switch104 == "batched" -- 510
			if ____cond104 then -- 510
				cnode.batched = v -- 511
				return true -- 511
			end -- 511
			____cond104 = ____cond104 or ____switch104 == "effect" -- 511
			if ____cond104 then -- 511
				cnode.effect = v -- 512
				return true -- 512
			end -- 512
			____cond104 = ____cond104 or ____switch104 == "alignment" -- 512
			if ____cond104 then -- 512
				cnode.alignment = v -- 513
				return true -- 513
			end -- 513
		until true -- 513
		return false -- 515
	end -- 500
	getLabel = function(enode) -- 517
		local label = enode.props -- 518
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 519
		if node ~= nil then -- 519
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 519
				local ____node_smooth_12 = node.smooth -- 522
				local x = ____node_smooth_12.x -- 522
				local y = ____node_smooth_12.y -- 522
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 523
			end -- 523
			local cnode = getNode(enode, node, handleLabelAttribute) -- 525
			local ____enode_13 = enode -- 526
			local children = ____enode_13.children -- 526
			local text = label.text or "" -- 527
			for i = 1, #children do -- 527
				local child = children[i] -- 529
				if type(child) ~= "table" then -- 529
					text = text .. tostring(child) -- 531
				end -- 531
			end -- 531
			node.text = text -- 534
			return cnode -- 535
		end -- 535
		return nil -- 537
	end -- 517
end -- 517
local getLine -- 541
do -- 541
	local function handleLineAttribute(cnode, enode, k, v) -- 543
		local line = enode.props -- 544
		repeat -- 544
			local ____switch112 = k -- 544
			local ____cond112 = ____switch112 == "verts" -- 544
			if ____cond112 then -- 544
				cnode:set( -- 546
					v, -- 546
					Dora.Color(line.lineColor or 4294967295) -- 546
				) -- 546
				return true -- 546
			end -- 546
			____cond112 = ____cond112 or ____switch112 == "depthWrite" -- 546
			if ____cond112 then -- 546
				cnode.depthWrite = v -- 547
				return true -- 547
			end -- 547
			____cond112 = ____cond112 or ____switch112 == "blendFunc" -- 547
			if ____cond112 then -- 547
				cnode.blendFunc = v -- 548
				return true -- 548
			end -- 548
		until true -- 548
		return false -- 550
	end -- 543
	getLine = function(enode) -- 552
		local node = Dora.Line() -- 553
		local cnode = getNode(enode, node, handleLineAttribute) -- 554
		return cnode -- 555
	end -- 552
end -- 552
local getParticle -- 559
do -- 559
	local function handleParticleAttribute(cnode, _enode, k, v) -- 561
		repeat -- 561
			local ____switch116 = k -- 561
			local ____cond116 = ____switch116 == "file" -- 561
			if ____cond116 then -- 561
				return true -- 563
			end -- 563
			____cond116 = ____cond116 or ____switch116 == "emit" -- 563
			if ____cond116 then -- 563
				if v then -- 563
					cnode:start() -- 564
				end -- 564
				return true -- 564
			end -- 564
			____cond116 = ____cond116 or ____switch116 == "onFinished" -- 564
			if ____cond116 then -- 564
				cnode:slot("Finished", v) -- 565
				return true -- 565
			end -- 565
		until true -- 565
		return false -- 567
	end -- 561
	getParticle = function(enode) -- 569
		local particle = enode.props -- 570
		local node = Dora.Particle(particle.file) -- 571
		if node ~= nil then -- 571
			local cnode = getNode(enode, node, handleParticleAttribute) -- 573
			return cnode -- 574
		end -- 574
		return nil -- 576
	end -- 569
end -- 569
local getMenu -- 580
do -- 580
	local function handleMenuAttribute(cnode, _enode, k, v) -- 582
		repeat -- 582
			local ____switch122 = k -- 582
			local ____cond122 = ____switch122 == "enabled" -- 582
			if ____cond122 then -- 582
				cnode.enabled = v -- 584
				return true -- 584
			end -- 584
		until true -- 584
		return false -- 586
	end -- 582
	getMenu = function(enode) -- 588
		local node = Dora.Menu() -- 589
		local cnode = getNode(enode, node, handleMenuAttribute) -- 590
		return cnode -- 591
	end -- 588
end -- 588
local function getPhysicsWorld(enode) -- 595
	local node = Dora.PhysicsWorld() -- 596
	local cnode = getNode(enode, node) -- 597
	return cnode -- 598
end -- 595
local getBody -- 601
do -- 601
	local function handleBodyAttribute(cnode, _enode, k, v) -- 603
		repeat -- 603
			local ____switch127 = k -- 603
			local ____cond127 = ____switch127 == "type" or ____switch127 == "linearAcceleration" or ____switch127 == "fixedRotation" or ____switch127 == "bullet" or ____switch127 == "world" -- 603
			if ____cond127 then -- 603
				return true -- 610
			end -- 610
			____cond127 = ____cond127 or ____switch127 == "velocityX" -- 610
			if ____cond127 then -- 610
				cnode.velocityX = v -- 611
				return true -- 611
			end -- 611
			____cond127 = ____cond127 or ____switch127 == "velocityY" -- 611
			if ____cond127 then -- 611
				cnode.velocityY = v -- 612
				return true -- 612
			end -- 612
			____cond127 = ____cond127 or ____switch127 == "angularRate" -- 612
			if ____cond127 then -- 612
				cnode.angularRate = v -- 613
				return true -- 613
			end -- 613
			____cond127 = ____cond127 or ____switch127 == "group" -- 613
			if ____cond127 then -- 613
				cnode.group = v -- 614
				return true -- 614
			end -- 614
			____cond127 = ____cond127 or ____switch127 == "linearDamping" -- 614
			if ____cond127 then -- 614
				cnode.linearDamping = v -- 615
				return true -- 615
			end -- 615
			____cond127 = ____cond127 or ____switch127 == "angularDamping" -- 615
			if ____cond127 then -- 615
				cnode.angularDamping = v -- 616
				return true -- 616
			end -- 616
			____cond127 = ____cond127 or ____switch127 == "owner" -- 616
			if ____cond127 then -- 616
				cnode.owner = v -- 617
				return true -- 617
			end -- 617
			____cond127 = ____cond127 or ____switch127 == "receivingContact" -- 617
			if ____cond127 then -- 617
				cnode.receivingContact = v -- 618
				return true -- 618
			end -- 618
			____cond127 = ____cond127 or ____switch127 == "onBodyEnter" -- 618
			if ____cond127 then -- 618
				cnode:slot("BodyEnter", v) -- 619
				return true -- 619
			end -- 619
			____cond127 = ____cond127 or ____switch127 == "onBodyLeave" -- 619
			if ____cond127 then -- 619
				cnode:slot("BodyLeave", v) -- 620
				return true -- 620
			end -- 620
			____cond127 = ____cond127 or ____switch127 == "onContactStart" -- 620
			if ____cond127 then -- 620
				cnode:slot("ContactStart", v) -- 621
				return true -- 621
			end -- 621
			____cond127 = ____cond127 or ____switch127 == "onContactEnd" -- 621
			if ____cond127 then -- 621
				cnode:slot("ContactEnd", v) -- 622
				return true -- 622
			end -- 622
			____cond127 = ____cond127 or ____switch127 == "onContactFilter" -- 622
			if ____cond127 then -- 622
				cnode:onContactFilter(v) -- 623
				return true -- 623
			end -- 623
		until true -- 623
		return false -- 625
	end -- 603
	getBody = function(enode, world) -- 627
		local def = enode.props -- 628
		local bodyDef = Dora.BodyDef() -- 629
		bodyDef.type = def.type -- 630
		if def.angle ~= nil then -- 630
			bodyDef.angle = def.angle -- 631
		end -- 631
		if def.angularDamping ~= nil then -- 631
			bodyDef.angularDamping = def.angularDamping -- 632
		end -- 632
		if def.bullet ~= nil then -- 632
			bodyDef.bullet = def.bullet -- 633
		end -- 633
		if def.fixedRotation ~= nil then -- 633
			bodyDef.fixedRotation = def.fixedRotation -- 634
		end -- 634
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 635
		if def.linearDamping ~= nil then -- 635
			bodyDef.linearDamping = def.linearDamping -- 636
		end -- 636
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 637
		local extraSensors = nil -- 638
		for i = 1, #enode.children do -- 638
			do -- 638
				local child = enode.children[i] -- 640
				if type(child) ~= "table" then -- 640
					goto __continue134 -- 642
				end -- 642
				repeat -- 642
					local ____switch136 = child.type -- 642
					local ____cond136 = ____switch136 == "rect-fixture" -- 642
					if ____cond136 then -- 642
						do -- 642
							local shape = child.props -- 646
							if shape.sensorTag ~= nil then -- 646
								bodyDef:attachPolygonSensor( -- 648
									shape.sensorTag, -- 649
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 650
									shape.width, -- 651
									shape.height, -- 651
									shape.angle or 0 -- 652
								) -- 652
							else -- 652
								bodyDef:attachPolygon( -- 655
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 656
									shape.width, -- 657
									shape.height, -- 657
									shape.angle or 0, -- 658
									shape.density or 1, -- 659
									shape.friction or 0.4, -- 660
									shape.restitution or 0 -- 661
								) -- 661
							end -- 661
							break -- 664
						end -- 664
					end -- 664
					____cond136 = ____cond136 or ____switch136 == "polygon-fixture" -- 664
					if ____cond136 then -- 664
						do -- 664
							local shape = child.props -- 667
							if shape.sensorTag ~= nil then -- 667
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 669
							else -- 669
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 674
							end -- 674
							break -- 681
						end -- 681
					end -- 681
					____cond136 = ____cond136 or ____switch136 == "multi-fixture" -- 681
					if ____cond136 then -- 681
						do -- 681
							local shape = child.props -- 684
							if shape.sensorTag ~= nil then -- 684
								if extraSensors == nil then -- 684
									extraSensors = {} -- 686
								end -- 686
								extraSensors[#extraSensors + 1] = { -- 687
									shape.sensorTag, -- 687
									Dora.BodyDef:multi(shape.verts) -- 687
								} -- 687
							else -- 687
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 689
							end -- 689
							break -- 696
						end -- 696
					end -- 696
					____cond136 = ____cond136 or ____switch136 == "disk-fixture" -- 696
					if ____cond136 then -- 696
						do -- 696
							local shape = child.props -- 699
							if shape.sensorTag ~= nil then -- 699
								bodyDef:attachDiskSensor( -- 701
									shape.sensorTag, -- 702
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 703
									shape.radius -- 704
								) -- 704
							else -- 704
								bodyDef:attachDisk( -- 707
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 708
									shape.radius, -- 709
									shape.density or 1, -- 710
									shape.friction or 0.4, -- 711
									shape.restitution or 0 -- 712
								) -- 712
							end -- 712
							break -- 715
						end -- 715
					end -- 715
					____cond136 = ____cond136 or ____switch136 == "chain-fixture" -- 715
					if ____cond136 then -- 715
						do -- 715
							local shape = child.props -- 718
							if shape.sensorTag ~= nil then -- 718
								if extraSensors == nil then -- 718
									extraSensors = {} -- 720
								end -- 720
								extraSensors[#extraSensors + 1] = { -- 721
									shape.sensorTag, -- 721
									Dora.BodyDef:chain(shape.verts) -- 721
								} -- 721
							else -- 721
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 723
							end -- 723
							break -- 729
						end -- 729
					end -- 729
				until true -- 729
			end -- 729
			::__continue134:: -- 729
		end -- 729
		local body = Dora.Body(bodyDef, world) -- 733
		if extraSensors ~= nil then -- 733
			for i = 1, #extraSensors do -- 733
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 736
				body:attachSensor(tag, def) -- 737
			end -- 737
		end -- 737
		local cnode = getNode(enode, body, handleBodyAttribute) -- 740
		if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 740
			body.receivingContact = true -- 745
		end -- 745
		return cnode -- 747
	end -- 627
end -- 627
local getCustomNode -- 751
do -- 751
	local function handleCustomNode(_cnode, _enode, k, _v) -- 753
		repeat -- 753
			local ____switch157 = k -- 753
			local ____cond157 = ____switch157 == "onCreate" -- 753
			if ____cond157 then -- 753
				return true -- 755
			end -- 755
		until true -- 755
		return false -- 757
	end -- 753
	getCustomNode = function(enode) -- 759
		local custom = enode.props -- 760
		local node = custom.onCreate() -- 761
		if node then -- 761
			local cnode = getNode(enode, node, handleCustomNode) -- 763
			return cnode -- 764
		end -- 764
		return nil -- 766
	end -- 759
end -- 759
local getAlignNode -- 770
do -- 770
	local function handleAlignNode(_cnode, _enode, k, _v) -- 772
		repeat -- 772
			local ____switch162 = k -- 772
			local ____cond162 = ____switch162 == "windowRoot" -- 772
			if ____cond162 then -- 772
				return true -- 774
			end -- 774
			____cond162 = ____cond162 or ____switch162 == "style" -- 774
			if ____cond162 then -- 774
				return true -- 775
			end -- 775
			____cond162 = ____cond162 or ____switch162 == "onLayout" -- 775
			if ____cond162 then -- 775
				return true -- 776
			end -- 776
		until true -- 776
		return false -- 778
	end -- 772
	getAlignNode = function(enode) -- 780
		local alignNode = enode.props -- 781
		local node = Dora.AlignNode(alignNode.windowRoot) -- 782
		if alignNode.style then -- 782
			local items = {} -- 784
			for k, v in pairs(alignNode.style) do -- 785
				local name = string.gsub(k, "%u", "-%1") -- 786
				name = string.lower(name) -- 787
				repeat -- 787
					local ____switch166 = k -- 787
					local ____cond166 = ____switch166 == "margin" or ____switch166 == "padding" or ____switch166 == "border" or ____switch166 == "gap" -- 787
					if ____cond166 then -- 787
						do -- 787
							if type(v) == "table" then -- 787
								local valueStr = table.concat( -- 792
									__TS__ArrayMap( -- 792
										v, -- 792
										function(____, item) return tostring(item) end -- 792
									), -- 792
									"," -- 792
								) -- 792
								items[#items + 1] = (name .. ":") .. valueStr -- 793
							else -- 793
								items[#items + 1] = (name .. ":") .. tostring(v) -- 795
							end -- 795
							break -- 797
						end -- 797
					end -- 797
					do -- 797
						items[#items + 1] = (name .. ":") .. tostring(v) -- 800
						break -- 801
					end -- 801
				until true -- 801
			end -- 801
			local styleStr = table.concat(items, ";") -- 804
			node:css(styleStr) -- 805
		end -- 805
		if alignNode.onLayout then -- 805
			node:slot("AlignLayout", alignNode.onLayout) -- 808
		end -- 808
		local cnode = getNode(enode, node, handleAlignNode) -- 810
		return cnode -- 811
	end -- 780
end -- 780
local function getEffekNode(enode) -- 815
	return getNode( -- 816
		enode, -- 816
		Dora.EffekNode() -- 816
	) -- 816
end -- 815
local getTileNode -- 819
do -- 819
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 821
		repeat -- 821
			local ____switch175 = k -- 821
			local ____cond175 = ____switch175 == "file" or ____switch175 == "layers" -- 821
			if ____cond175 then -- 821
				return true -- 823
			end -- 823
			____cond175 = ____cond175 or ____switch175 == "depthWrite" -- 823
			if ____cond175 then -- 823
				cnode.depthWrite = v -- 824
				return true -- 824
			end -- 824
			____cond175 = ____cond175 or ____switch175 == "blendFunc" -- 824
			if ____cond175 then -- 824
				cnode.blendFunc = v -- 825
				return true -- 825
			end -- 825
			____cond175 = ____cond175 or ____switch175 == "effect" -- 825
			if ____cond175 then -- 825
				cnode.effect = v -- 826
				return true -- 826
			end -- 826
			____cond175 = ____cond175 or ____switch175 == "filter" -- 826
			if ____cond175 then -- 826
				cnode.filter = v -- 827
				return true -- 827
			end -- 827
		until true -- 827
		return false -- 829
	end -- 821
	getTileNode = function(enode) -- 831
		local tn = enode.props -- 832
		local ____tn_layers_14 -- 833
		if tn.layers then -- 833
			____tn_layers_14 = Dora.TileNode(tn.file, tn.layers) -- 833
		else -- 833
			____tn_layers_14 = Dora.TileNode(tn.file) -- 833
		end -- 833
		local node = ____tn_layers_14 -- 833
		if node ~= nil then -- 833
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 835
			return cnode -- 836
		end -- 836
		return nil -- 838
	end -- 831
end -- 831
local function addChild(nodeStack, cnode, enode) -- 842
	if #nodeStack > 0 then -- 842
		local last = nodeStack[#nodeStack] -- 844
		last:addChild(cnode) -- 845
	end -- 845
	nodeStack[#nodeStack + 1] = cnode -- 847
	local ____enode_15 = enode -- 848
	local children = ____enode_15.children -- 848
	for i = 1, #children do -- 848
		visitNode(nodeStack, children[i], enode) -- 850
	end -- 850
	if #nodeStack > 1 then -- 850
		table.remove(nodeStack) -- 853
	end -- 853
end -- 842
local function drawNodeCheck(_nodeStack, enode, parent) -- 861
	if parent == nil or parent.type ~= "draw-node" then -- 861
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 863
	end -- 863
end -- 861
local function visitAction(actionStack, enode) -- 867
	local createAction = actionMap[enode.type] -- 868
	if createAction ~= nil then -- 868
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 870
		return -- 871
	end -- 871
	repeat -- 871
		local ____switch186 = enode.type -- 871
		local ____cond186 = ____switch186 == "delay" -- 871
		if ____cond186 then -- 871
			do -- 871
				local item = enode.props -- 875
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 876
				break -- 877
			end -- 877
		end -- 877
		____cond186 = ____cond186 or ____switch186 == "event" -- 877
		if ____cond186 then -- 877
			do -- 877
				local item = enode.props -- 880
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 881
				break -- 882
			end -- 882
		end -- 882
		____cond186 = ____cond186 or ____switch186 == "hide" -- 882
		if ____cond186 then -- 882
			do -- 882
				actionStack[#actionStack + 1] = Dora.Hide() -- 885
				break -- 886
			end -- 886
		end -- 886
		____cond186 = ____cond186 or ____switch186 == "show" -- 886
		if ____cond186 then -- 886
			do -- 886
				actionStack[#actionStack + 1] = Dora.Show() -- 889
				break -- 890
			end -- 890
		end -- 890
		____cond186 = ____cond186 or ____switch186 == "move" -- 890
		if ____cond186 then -- 890
			do -- 890
				local item = enode.props -- 893
				actionStack[#actionStack + 1] = Dora.Move( -- 894
					item.time, -- 894
					Dora.Vec2(item.startX, item.startY), -- 894
					Dora.Vec2(item.stopX, item.stopY), -- 894
					item.easing -- 894
				) -- 894
				break -- 895
			end -- 895
		end -- 895
		____cond186 = ____cond186 or ____switch186 == "frame" -- 895
		if ____cond186 then -- 895
			do -- 895
				local item = enode.props -- 898
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 899
				break -- 900
			end -- 900
		end -- 900
		____cond186 = ____cond186 or ____switch186 == "spawn" -- 900
		if ____cond186 then -- 900
			do -- 900
				local spawnStack = {} -- 903
				for i = 1, #enode.children do -- 903
					visitAction(spawnStack, enode.children[i]) -- 905
				end -- 905
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 907
				break -- 908
			end -- 908
		end -- 908
		____cond186 = ____cond186 or ____switch186 == "sequence" -- 908
		if ____cond186 then -- 908
			do -- 908
				local sequenceStack = {} -- 911
				for i = 1, #enode.children do -- 911
					visitAction(sequenceStack, enode.children[i]) -- 913
				end -- 913
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 915
				break -- 916
			end -- 916
		end -- 916
		do -- 916
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 919
			break -- 920
		end -- 920
	until true -- 920
end -- 867
local function actionCheck(nodeStack, enode, parent) -- 924
	local unsupported = false -- 925
	if parent == nil then -- 925
		unsupported = true -- 927
	else -- 927
		repeat -- 927
			local ____switch200 = parent.type -- 927
			local ____cond200 = ____switch200 == "action" or ____switch200 == "spawn" or ____switch200 == "sequence" -- 927
			if ____cond200 then -- 927
				break -- 930
			end -- 930
			do -- 930
				unsupported = true -- 931
				break -- 931
			end -- 931
		until true -- 931
	end -- 931
	if unsupported then -- 931
		if #nodeStack > 0 then -- 931
			local node = nodeStack[#nodeStack] -- 936
			local actionStack = {} -- 937
			visitAction(actionStack, enode) -- 938
			if #actionStack == 1 then -- 938
				node:runAction(actionStack[1]) -- 940
			end -- 940
		else -- 940
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 943
		end -- 943
	end -- 943
end -- 924
local function bodyCheck(_nodeStack, enode, parent) -- 948
	if parent == nil or parent.type ~= "body" then -- 948
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 950
	end -- 950
end -- 948
actionMap = { -- 954
	["anchor-x"] = Dora.AnchorX, -- 957
	["anchor-y"] = Dora.AnchorY, -- 958
	angle = Dora.Angle, -- 959
	["angle-x"] = Dora.AngleX, -- 960
	["angle-y"] = Dora.AngleY, -- 961
	width = Dora.Width, -- 962
	height = Dora.Height, -- 963
	opacity = Dora.Opacity, -- 964
	roll = Dora.Roll, -- 965
	scale = Dora.Scale, -- 966
	["scale-x"] = Dora.ScaleX, -- 967
	["scale-y"] = Dora.ScaleY, -- 968
	["skew-x"] = Dora.SkewX, -- 969
	["skew-y"] = Dora.SkewY, -- 970
	["move-x"] = Dora.X, -- 971
	["move-y"] = Dora.Y, -- 972
	["move-z"] = Dora.Z -- 973
} -- 973
elementMap = { -- 976
	node = function(nodeStack, enode, parent) -- 977
		addChild( -- 978
			nodeStack, -- 978
			getNode(enode), -- 978
			enode -- 978
		) -- 978
	end, -- 977
	["clip-node"] = function(nodeStack, enode, parent) -- 980
		addChild( -- 981
			nodeStack, -- 981
			getClipNode(enode), -- 981
			enode -- 981
		) -- 981
	end, -- 980
	playable = function(nodeStack, enode, parent) -- 983
		local cnode = getPlayable(enode) -- 984
		if cnode ~= nil then -- 984
			addChild(nodeStack, cnode, enode) -- 986
		end -- 986
	end, -- 983
	["dragon-bone"] = function(nodeStack, enode, parent) -- 989
		local cnode = getDragonBone(enode) -- 990
		if cnode ~= nil then -- 990
			addChild(nodeStack, cnode, enode) -- 992
		end -- 992
	end, -- 989
	spine = function(nodeStack, enode, parent) -- 995
		local cnode = getSpine(enode) -- 996
		if cnode ~= nil then -- 996
			addChild(nodeStack, cnode, enode) -- 998
		end -- 998
	end, -- 995
	model = function(nodeStack, enode, parent) -- 1001
		local cnode = getModel(enode) -- 1002
		if cnode ~= nil then -- 1002
			addChild(nodeStack, cnode, enode) -- 1004
		end -- 1004
	end, -- 1001
	["draw-node"] = function(nodeStack, enode, parent) -- 1007
		addChild( -- 1008
			nodeStack, -- 1008
			getDrawNode(enode), -- 1008
			enode -- 1008
		) -- 1008
	end, -- 1007
	["dot-shape"] = drawNodeCheck, -- 1010
	["segment-shape"] = drawNodeCheck, -- 1011
	["rect-shape"] = drawNodeCheck, -- 1012
	["polygon-shape"] = drawNodeCheck, -- 1013
	["verts-shape"] = drawNodeCheck, -- 1014
	grid = function(nodeStack, enode, parent) -- 1015
		addChild( -- 1016
			nodeStack, -- 1016
			getGrid(enode), -- 1016
			enode -- 1016
		) -- 1016
	end, -- 1015
	sprite = function(nodeStack, enode, parent) -- 1018
		local cnode = getSprite(enode) -- 1019
		if cnode ~= nil then -- 1019
			addChild(nodeStack, cnode, enode) -- 1021
		end -- 1021
	end, -- 1018
	["audio-source"] = function(nodeStack, enode, parent) -- 1024
		local cnode = getAudioSource(enode) -- 1025
		if cnode ~= nil then -- 1025
			addChild(nodeStack, cnode, enode) -- 1027
		end -- 1027
	end, -- 1024
	["video-node"] = function(nodeStack, enode, parent) -- 1030
		local cnode = getVideoNode(enode) -- 1031
		if cnode ~= nil then -- 1031
			addChild(nodeStack, cnode, enode) -- 1033
		end -- 1033
	end, -- 1030
	["tic80-node"] = function(nodeStack, enode, parent) -- 1036
		local cnode = getTIC80Node(enode) -- 1037
		if cnode ~= nil then -- 1037
			addChild(nodeStack, cnode, enode) -- 1039
		end -- 1039
	end, -- 1036
	label = function(nodeStack, enode, parent) -- 1042
		local cnode = getLabel(enode) -- 1043
		if cnode ~= nil then -- 1043
			addChild(nodeStack, cnode, enode) -- 1045
		end -- 1045
	end, -- 1042
	line = function(nodeStack, enode, parent) -- 1048
		addChild( -- 1049
			nodeStack, -- 1049
			getLine(enode), -- 1049
			enode -- 1049
		) -- 1049
	end, -- 1048
	particle = function(nodeStack, enode, parent) -- 1051
		local cnode = getParticle(enode) -- 1052
		if cnode ~= nil then -- 1052
			addChild(nodeStack, cnode, enode) -- 1054
		end -- 1054
	end, -- 1051
	menu = function(nodeStack, enode, parent) -- 1057
		addChild( -- 1058
			nodeStack, -- 1058
			getMenu(enode), -- 1058
			enode -- 1058
		) -- 1058
	end, -- 1057
	action = function(_nodeStack, enode, parent) -- 1060
		if #enode.children == 0 then -- 1060
			Warn("<action> tag has no children") -- 1062
			return -- 1063
		end -- 1063
		local action = enode.props -- 1065
		if action.ref == nil then -- 1065
			Warn("<action> tag has no ref") -- 1067
			return -- 1068
		end -- 1068
		local actionStack = {} -- 1070
		for i = 1, #enode.children do -- 1070
			visitAction(actionStack, enode.children[i]) -- 1072
		end -- 1072
		if #actionStack == 1 then -- 1072
			action.ref.current = actionStack[1] -- 1075
		elseif #actionStack > 1 then -- 1075
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1077
		end -- 1077
	end, -- 1060
	["anchor-x"] = actionCheck, -- 1080
	["anchor-y"] = actionCheck, -- 1081
	angle = actionCheck, -- 1082
	["angle-x"] = actionCheck, -- 1083
	["angle-y"] = actionCheck, -- 1084
	delay = actionCheck, -- 1085
	event = actionCheck, -- 1086
	width = actionCheck, -- 1087
	height = actionCheck, -- 1088
	hide = actionCheck, -- 1089
	show = actionCheck, -- 1090
	move = actionCheck, -- 1091
	opacity = actionCheck, -- 1092
	roll = actionCheck, -- 1093
	scale = actionCheck, -- 1094
	["scale-x"] = actionCheck, -- 1095
	["scale-y"] = actionCheck, -- 1096
	["skew-x"] = actionCheck, -- 1097
	["skew-y"] = actionCheck, -- 1098
	["move-x"] = actionCheck, -- 1099
	["move-y"] = actionCheck, -- 1100
	["move-z"] = actionCheck, -- 1101
	frame = actionCheck, -- 1102
	spawn = actionCheck, -- 1103
	sequence = actionCheck, -- 1104
	loop = function(nodeStack, enode, _parent) -- 1105
		if #nodeStack > 0 then -- 1105
			local node = nodeStack[#nodeStack] -- 1107
			local actionStack = {} -- 1108
			for i = 1, #enode.children do -- 1108
				visitAction(actionStack, enode.children[i]) -- 1110
			end -- 1110
			if #actionStack == 1 then -- 1110
				node:runAction(actionStack[1], true) -- 1113
			else -- 1113
				local loop = enode.props -- 1115
				if loop.spawn then -- 1115
					node:runAction( -- 1117
						Dora.Spawn(table.unpack(actionStack)), -- 1117
						true -- 1117
					) -- 1117
				else -- 1117
					node:runAction( -- 1119
						Dora.Sequence(table.unpack(actionStack)), -- 1119
						true -- 1119
					) -- 1119
				end -- 1119
			end -- 1119
		else -- 1119
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1123
		end -- 1123
	end, -- 1105
	["physics-world"] = function(nodeStack, enode, _parent) -- 1126
		addChild( -- 1127
			nodeStack, -- 1127
			getPhysicsWorld(enode), -- 1127
			enode -- 1127
		) -- 1127
	end, -- 1126
	contact = function(nodeStack, enode, _parent) -- 1129
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1130
		if world ~= nil then -- 1130
			local contact = enode.props -- 1132
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1133
		else -- 1133
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1135
		end -- 1135
	end, -- 1129
	body = function(nodeStack, enode, _parent) -- 1138
		local def = enode.props -- 1139
		if def.world then -- 1139
			addChild( -- 1141
				nodeStack, -- 1141
				getBody(enode, def.world), -- 1141
				enode -- 1141
			) -- 1141
			return -- 1142
		end -- 1142
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1144
		if world ~= nil then -- 1144
			addChild( -- 1146
				nodeStack, -- 1146
				getBody(enode, world), -- 1146
				enode -- 1146
			) -- 1146
		else -- 1146
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1148
		end -- 1148
	end, -- 1138
	["rect-fixture"] = bodyCheck, -- 1151
	["polygon-fixture"] = bodyCheck, -- 1152
	["multi-fixture"] = bodyCheck, -- 1153
	["disk-fixture"] = bodyCheck, -- 1154
	["chain-fixture"] = bodyCheck, -- 1155
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1156
		local joint = enode.props -- 1157
		if joint.ref == nil then -- 1157
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1159
			return -- 1160
		end -- 1160
		if joint.bodyA.current == nil then -- 1160
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1163
			return -- 1164
		end -- 1164
		if joint.bodyB.current == nil then -- 1164
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1167
			return -- 1168
		end -- 1168
		local ____joint_ref_19 = joint.ref -- 1170
		local ____self_17 = Dora.Joint -- 1170
		local ____self_17_distance_18 = ____self_17.distance -- 1170
		local ____joint_canCollide_16 = joint.canCollide -- 1171
		if ____joint_canCollide_16 == nil then -- 1171
			____joint_canCollide_16 = false -- 1171
		end -- 1171
		____joint_ref_19.current = ____self_17_distance_18( -- 1170
			____self_17, -- 1170
			____joint_canCollide_16, -- 1171
			joint.bodyA.current, -- 1172
			joint.bodyB.current, -- 1173
			joint.anchorA or Dora.Vec2.zero, -- 1174
			joint.anchorB or Dora.Vec2.zero, -- 1175
			joint.frequency or 0, -- 1176
			joint.damping or 0 -- 1177
		) -- 1177
	end, -- 1156
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1179
		local joint = enode.props -- 1180
		if joint.ref == nil then -- 1180
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1182
			return -- 1183
		end -- 1183
		if joint.bodyA.current == nil then -- 1183
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1186
			return -- 1187
		end -- 1187
		if joint.bodyB.current == nil then -- 1187
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1190
			return -- 1191
		end -- 1191
		local ____joint_ref_23 = joint.ref -- 1193
		local ____self_21 = Dora.Joint -- 1193
		local ____self_21_friction_22 = ____self_21.friction -- 1193
		local ____joint_canCollide_20 = joint.canCollide -- 1194
		if ____joint_canCollide_20 == nil then -- 1194
			____joint_canCollide_20 = false -- 1194
		end -- 1194
		____joint_ref_23.current = ____self_21_friction_22( -- 1193
			____self_21, -- 1193
			____joint_canCollide_20, -- 1194
			joint.bodyA.current, -- 1195
			joint.bodyB.current, -- 1196
			joint.worldPos, -- 1197
			joint.maxForce, -- 1198
			joint.maxTorque -- 1199
		) -- 1199
	end, -- 1179
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1202
		local joint = enode.props -- 1203
		if joint.ref == nil then -- 1203
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1205
			return -- 1206
		end -- 1206
		if joint.jointA.current == nil then -- 1206
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1209
			return -- 1210
		end -- 1210
		if joint.jointB.current == nil then -- 1210
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1213
			return -- 1214
		end -- 1214
		local ____joint_ref_27 = joint.ref -- 1216
		local ____self_25 = Dora.Joint -- 1216
		local ____self_25_gear_26 = ____self_25.gear -- 1216
		local ____joint_canCollide_24 = joint.canCollide -- 1217
		if ____joint_canCollide_24 == nil then -- 1217
			____joint_canCollide_24 = false -- 1217
		end -- 1217
		____joint_ref_27.current = ____self_25_gear_26( -- 1216
			____self_25, -- 1216
			____joint_canCollide_24, -- 1217
			joint.jointA.current, -- 1218
			joint.jointB.current, -- 1219
			joint.ratio or 1 -- 1220
		) -- 1220
	end, -- 1202
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1223
		local joint = enode.props -- 1224
		if joint.ref == nil then -- 1224
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1226
			return -- 1227
		end -- 1227
		if joint.bodyA.current == nil then -- 1227
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1230
			return -- 1231
		end -- 1231
		if joint.bodyB.current == nil then -- 1231
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1234
			return -- 1235
		end -- 1235
		local ____joint_ref_31 = joint.ref -- 1237
		local ____self_29 = Dora.Joint -- 1237
		local ____self_29_spring_30 = ____self_29.spring -- 1237
		local ____joint_canCollide_28 = joint.canCollide -- 1238
		if ____joint_canCollide_28 == nil then -- 1238
			____joint_canCollide_28 = false -- 1238
		end -- 1238
		____joint_ref_31.current = ____self_29_spring_30( -- 1237
			____self_29, -- 1237
			____joint_canCollide_28, -- 1238
			joint.bodyA.current, -- 1239
			joint.bodyB.current, -- 1240
			joint.linearOffset, -- 1241
			joint.angularOffset, -- 1242
			joint.maxForce, -- 1243
			joint.maxTorque, -- 1244
			joint.correctionFactor or 1 -- 1245
		) -- 1245
	end, -- 1223
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1248
		local joint = enode.props -- 1249
		if joint.ref == nil then -- 1249
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1251
			return -- 1252
		end -- 1252
		if joint.body.current == nil then -- 1252
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1255
			return -- 1256
		end -- 1256
		local ____joint_ref_35 = joint.ref -- 1258
		local ____self_33 = Dora.Joint -- 1258
		local ____self_33_move_34 = ____self_33.move -- 1258
		local ____joint_canCollide_32 = joint.canCollide -- 1259
		if ____joint_canCollide_32 == nil then -- 1259
			____joint_canCollide_32 = false -- 1259
		end -- 1259
		____joint_ref_35.current = ____self_33_move_34( -- 1258
			____self_33, -- 1258
			____joint_canCollide_32, -- 1259
			joint.body.current, -- 1260
			joint.targetPos, -- 1261
			joint.maxForce, -- 1262
			joint.frequency, -- 1263
			joint.damping or 0.7 -- 1264
		) -- 1264
	end, -- 1248
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1267
		local joint = enode.props -- 1268
		if joint.ref == nil then -- 1268
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1270
			return -- 1271
		end -- 1271
		if joint.bodyA.current == nil then -- 1271
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1274
			return -- 1275
		end -- 1275
		if joint.bodyB.current == nil then -- 1275
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1278
			return -- 1279
		end -- 1279
		local ____joint_ref_39 = joint.ref -- 1281
		local ____self_37 = Dora.Joint -- 1281
		local ____self_37_prismatic_38 = ____self_37.prismatic -- 1281
		local ____joint_canCollide_36 = joint.canCollide -- 1282
		if ____joint_canCollide_36 == nil then -- 1282
			____joint_canCollide_36 = false -- 1282
		end -- 1282
		____joint_ref_39.current = ____self_37_prismatic_38( -- 1281
			____self_37, -- 1281
			____joint_canCollide_36, -- 1282
			joint.bodyA.current, -- 1283
			joint.bodyB.current, -- 1284
			joint.worldPos, -- 1285
			joint.axisAngle, -- 1286
			joint.lowerTranslation or 0, -- 1287
			joint.upperTranslation or 0, -- 1288
			joint.maxMotorForce or 0, -- 1289
			joint.motorSpeed or 0 -- 1290
		) -- 1290
	end, -- 1267
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1293
		local joint = enode.props -- 1294
		if joint.ref == nil then -- 1294
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1296
			return -- 1297
		end -- 1297
		if joint.bodyA.current == nil then -- 1297
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1300
			return -- 1301
		end -- 1301
		if joint.bodyB.current == nil then -- 1301
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1304
			return -- 1305
		end -- 1305
		local ____joint_ref_43 = joint.ref -- 1307
		local ____self_41 = Dora.Joint -- 1307
		local ____self_41_pulley_42 = ____self_41.pulley -- 1307
		local ____joint_canCollide_40 = joint.canCollide -- 1308
		if ____joint_canCollide_40 == nil then -- 1308
			____joint_canCollide_40 = false -- 1308
		end -- 1308
		____joint_ref_43.current = ____self_41_pulley_42( -- 1307
			____self_41, -- 1307
			____joint_canCollide_40, -- 1308
			joint.bodyA.current, -- 1309
			joint.bodyB.current, -- 1310
			joint.anchorA or Dora.Vec2.zero, -- 1311
			joint.anchorB or Dora.Vec2.zero, -- 1312
			joint.groundAnchorA, -- 1313
			joint.groundAnchorB, -- 1314
			joint.ratio or 1 -- 1315
		) -- 1315
	end, -- 1293
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1318
		local joint = enode.props -- 1319
		if joint.ref == nil then -- 1319
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1321
			return -- 1322
		end -- 1322
		if joint.bodyA.current == nil then -- 1322
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1325
			return -- 1326
		end -- 1326
		if joint.bodyB.current == nil then -- 1326
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1329
			return -- 1330
		end -- 1330
		local ____joint_ref_47 = joint.ref -- 1332
		local ____self_45 = Dora.Joint -- 1332
		local ____self_45_revolute_46 = ____self_45.revolute -- 1332
		local ____joint_canCollide_44 = joint.canCollide -- 1333
		if ____joint_canCollide_44 == nil then -- 1333
			____joint_canCollide_44 = false -- 1333
		end -- 1333
		____joint_ref_47.current = ____self_45_revolute_46( -- 1332
			____self_45, -- 1332
			____joint_canCollide_44, -- 1333
			joint.bodyA.current, -- 1334
			joint.bodyB.current, -- 1335
			joint.worldPos, -- 1336
			joint.lowerAngle or 0, -- 1337
			joint.upperAngle or 0, -- 1338
			joint.maxMotorTorque or 0, -- 1339
			joint.motorSpeed or 0 -- 1340
		) -- 1340
	end, -- 1318
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1343
		local joint = enode.props -- 1344
		if joint.ref == nil then -- 1344
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1346
			return -- 1347
		end -- 1347
		if joint.bodyA.current == nil then -- 1347
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1350
			return -- 1351
		end -- 1351
		if joint.bodyB.current == nil then -- 1351
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1354
			return -- 1355
		end -- 1355
		local ____joint_ref_51 = joint.ref -- 1357
		local ____self_49 = Dora.Joint -- 1357
		local ____self_49_rope_50 = ____self_49.rope -- 1357
		local ____joint_canCollide_48 = joint.canCollide -- 1358
		if ____joint_canCollide_48 == nil then -- 1358
			____joint_canCollide_48 = false -- 1358
		end -- 1358
		____joint_ref_51.current = ____self_49_rope_50( -- 1357
			____self_49, -- 1357
			____joint_canCollide_48, -- 1358
			joint.bodyA.current, -- 1359
			joint.bodyB.current, -- 1360
			joint.anchorA or Dora.Vec2.zero, -- 1361
			joint.anchorB or Dora.Vec2.zero, -- 1362
			joint.maxLength or 0 -- 1363
		) -- 1363
	end, -- 1343
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1366
		local joint = enode.props -- 1367
		if joint.ref == nil then -- 1367
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1369
			return -- 1370
		end -- 1370
		if joint.bodyA.current == nil then -- 1370
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1373
			return -- 1374
		end -- 1374
		if joint.bodyB.current == nil then -- 1374
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1377
			return -- 1378
		end -- 1378
		local ____joint_ref_55 = joint.ref -- 1380
		local ____self_53 = Dora.Joint -- 1380
		local ____self_53_weld_54 = ____self_53.weld -- 1380
		local ____joint_canCollide_52 = joint.canCollide -- 1381
		if ____joint_canCollide_52 == nil then -- 1381
			____joint_canCollide_52 = false -- 1381
		end -- 1381
		____joint_ref_55.current = ____self_53_weld_54( -- 1380
			____self_53, -- 1380
			____joint_canCollide_52, -- 1381
			joint.bodyA.current, -- 1382
			joint.bodyB.current, -- 1383
			joint.worldPos, -- 1384
			joint.frequency or 0, -- 1385
			joint.damping or 0 -- 1386
		) -- 1386
	end, -- 1366
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1389
		local joint = enode.props -- 1390
		if joint.ref == nil then -- 1390
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1392
			return -- 1393
		end -- 1393
		if joint.bodyA.current == nil then -- 1393
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1396
			return -- 1397
		end -- 1397
		if joint.bodyB.current == nil then -- 1397
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1400
			return -- 1401
		end -- 1401
		local ____joint_ref_59 = joint.ref -- 1403
		local ____self_57 = Dora.Joint -- 1403
		local ____self_57_wheel_58 = ____self_57.wheel -- 1403
		local ____joint_canCollide_56 = joint.canCollide -- 1404
		if ____joint_canCollide_56 == nil then -- 1404
			____joint_canCollide_56 = false -- 1404
		end -- 1404
		____joint_ref_59.current = ____self_57_wheel_58( -- 1403
			____self_57, -- 1403
			____joint_canCollide_56, -- 1404
			joint.bodyA.current, -- 1405
			joint.bodyB.current, -- 1406
			joint.worldPos, -- 1407
			joint.axisAngle, -- 1408
			joint.maxMotorTorque or 0, -- 1409
			joint.motorSpeed or 0, -- 1410
			joint.frequency or 0, -- 1411
			joint.damping or 0.7 -- 1412
		) -- 1412
	end, -- 1389
	["custom-node"] = function(nodeStack, enode, _parent) -- 1415
		local node = getCustomNode(enode) -- 1416
		if node ~= nil then -- 1416
			addChild(nodeStack, node, enode) -- 1418
		end -- 1418
	end, -- 1415
	["custom-element"] = function() -- 1421
	end, -- 1421
	["align-node"] = function(nodeStack, enode, _parent) -- 1422
		addChild( -- 1423
			nodeStack, -- 1423
			getAlignNode(enode), -- 1423
			enode -- 1423
		) -- 1423
	end, -- 1422
	["effek-node"] = function(nodeStack, enode, _parent) -- 1425
		addChild( -- 1426
			nodeStack, -- 1426
			getEffekNode(enode), -- 1426
			enode -- 1426
		) -- 1426
	end, -- 1425
	effek = function(nodeStack, enode, parent) -- 1428
		if #nodeStack > 0 then -- 1428
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1430
			if node then -- 1430
				local effek = enode.props -- 1432
				local handle = node:play( -- 1433
					effek.file, -- 1433
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1433
					effek.z or 0 -- 1433
				) -- 1433
				if handle >= 0 then -- 1433
					if effek.ref then -- 1433
						effek.ref.current = handle -- 1436
					end -- 1436
					if effek.onEnd then -- 1436
						local onEnd = effek.onEnd -- 1436
						node:slot( -- 1440
							"EffekEnd", -- 1440
							function(h) -- 1440
								if handle == h then -- 1440
									onEnd(nil) -- 1442
								end -- 1442
							end -- 1440
						) -- 1440
					end -- 1440
				end -- 1440
			else -- 1440
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1448
			end -- 1448
		end -- 1448
	end, -- 1428
	["tile-node"] = function(nodeStack, enode, parent) -- 1452
		local cnode = getTileNode(enode) -- 1453
		if cnode ~= nil then -- 1453
			addChild(nodeStack, cnode, enode) -- 1455
		end -- 1455
	end -- 1452
} -- 1452
function ____exports.useRef(item) -- 1500
	local ____item_60 = item -- 1501
	if ____item_60 == nil then -- 1501
		____item_60 = nil -- 1501
	end -- 1501
	return {current = ____item_60} -- 1501
end -- 1500
local function getPreload(preloadList, node) -- 1504
	if type(node) ~= "table" then -- 1504
		return -- 1506
	end -- 1506
	local enode = node -- 1508
	if enode.type == nil then -- 1508
		local list = node -- 1510
		if #list > 0 then -- 1510
			for i = 1, #list do -- 1510
				getPreload(preloadList, list[i]) -- 1513
			end -- 1513
		end -- 1513
	else -- 1513
		repeat -- 1513
			local ____switch334 = enode.type -- 1513
			local sprite, playable, frame, model, spine, dragonBone, label -- 1513
			local ____cond334 = ____switch334 == "sprite" -- 1513
			if ____cond334 then -- 1513
				sprite = enode.props -- 1519
				if sprite.file then -- 1519
					preloadList[#preloadList + 1] = sprite.file -- 1521
				end -- 1521
				break -- 1523
			end -- 1523
			____cond334 = ____cond334 or ____switch334 == "playable" -- 1523
			if ____cond334 then -- 1523
				playable = enode.props -- 1525
				preloadList[#preloadList + 1] = playable.file -- 1526
				break -- 1527
			end -- 1527
			____cond334 = ____cond334 or ____switch334 == "frame" -- 1527
			if ____cond334 then -- 1527
				frame = enode.props -- 1529
				preloadList[#preloadList + 1] = frame.file -- 1530
				break -- 1531
			end -- 1531
			____cond334 = ____cond334 or ____switch334 == "model" -- 1531
			if ____cond334 then -- 1531
				model = enode.props -- 1533
				preloadList[#preloadList + 1] = "model:" .. model.file -- 1534
				break -- 1535
			end -- 1535
			____cond334 = ____cond334 or ____switch334 == "spine" -- 1535
			if ____cond334 then -- 1535
				spine = enode.props -- 1537
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1538
				break -- 1539
			end -- 1539
			____cond334 = ____cond334 or ____switch334 == "dragon-bone" -- 1539
			if ____cond334 then -- 1539
				dragonBone = enode.props -- 1541
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1542
				break -- 1543
			end -- 1543
			____cond334 = ____cond334 or ____switch334 == "label" -- 1543
			if ____cond334 then -- 1543
				label = enode.props -- 1545
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1546
				break -- 1547
			end -- 1547
		until true -- 1547
	end -- 1547
	getPreload(preloadList, enode.children) -- 1550
end -- 1504
function ____exports.preloadAsync(enode, handler) -- 1553
	local preloadList = {} -- 1554
	getPreload(preloadList, enode) -- 1555
	Dora.Cache:loadAsync(preloadList, handler) -- 1556
end -- 1553
function ____exports.toAction(enode) -- 1559
	local actionDef = ____exports.useRef() -- 1560
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 1561
	if not actionDef.current then -- 1561
		error("failed to create action") -- 1562
	end -- 1562
	return actionDef.current -- 1563
end -- 1559
return ____exports -- 1559