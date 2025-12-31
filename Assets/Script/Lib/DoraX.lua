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
function visitNode(nodeStack, node, parent) -- 1443
	if type(node) ~= "table" then -- 1443
		return -- 1445
	end -- 1445
	local enode = node -- 1447
	if enode.type == nil then -- 1447
		local list = node -- 1449
		if #list > 0 then -- 1449
			for i = 1, #list do -- 1449
				local stack = {} -- 1452
				visitNode(stack, list[i], parent) -- 1453
				for i = 1, #stack do -- 1453
					nodeStack[#nodeStack + 1] = stack[i] -- 1455
				end -- 1455
			end -- 1455
		end -- 1455
	else -- 1455
		local handler = elementMap[enode.type] -- 1460
		if handler ~= nil then -- 1460
			handler(nodeStack, enode, parent) -- 1462
		else -- 1462
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1464
		end -- 1464
	end -- 1464
end -- 1464
function ____exports.toNode(enode) -- 1469
	local nodeStack = {} -- 1470
	visitNode(nodeStack, enode) -- 1471
	if #nodeStack == 1 then -- 1471
		return nodeStack[1] -- 1473
	elseif #nodeStack > 1 then -- 1473
		local node = Dora.Node() -- 1475
		for i = 1, #nodeStack do -- 1475
			node:addChild(nodeStack[i]) -- 1477
		end -- 1477
		return node -- 1479
	end -- 1479
	return nil -- 1481
end -- 1469
____exports.React = {} -- 1469
local React = ____exports.React -- 1469
do -- 1469
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
do -- 393
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 395
		repeat -- 395
			local ____switch83 = k -- 395
			local ____cond83 = ____switch83 == "file" -- 395
			if ____cond83 then -- 395
				return true -- 397
			end -- 397
			____cond83 = ____cond83 or ____switch83 == "textureRect" -- 397
			if ____cond83 then -- 397
				cnode.textureRect = v -- 398
				return true -- 398
			end -- 398
			____cond83 = ____cond83 or ____switch83 == "depthWrite" -- 398
			if ____cond83 then -- 398
				cnode.depthWrite = v -- 399
				return true -- 399
			end -- 399
			____cond83 = ____cond83 or ____switch83 == "blendFunc" -- 399
			if ____cond83 then -- 399
				cnode.blendFunc = v -- 400
				return true -- 400
			end -- 400
			____cond83 = ____cond83 or ____switch83 == "effect" -- 400
			if ____cond83 then -- 400
				cnode.effect = v -- 401
				return true -- 401
			end -- 401
			____cond83 = ____cond83 or ____switch83 == "alphaRef" -- 401
			if ____cond83 then -- 401
				cnode.alphaRef = v -- 402
				return true -- 402
			end -- 402
			____cond83 = ____cond83 or ____switch83 == "uwrap" -- 402
			if ____cond83 then -- 402
				cnode.uwrap = v -- 403
				return true -- 403
			end -- 403
			____cond83 = ____cond83 or ____switch83 == "vwrap" -- 403
			if ____cond83 then -- 403
				cnode.vwrap = v -- 404
				return true -- 404
			end -- 404
			____cond83 = ____cond83 or ____switch83 == "filter" -- 404
			if ____cond83 then -- 404
				cnode.filter = v -- 405
				return true -- 405
			end -- 405
		until true -- 405
		return false -- 407
	end -- 395
	getSprite = function(enode) -- 409
		local sp = enode.props -- 410
		if sp.file then -- 410
			local node = Dora.Sprite(sp.file) -- 412
			if node ~= nil then -- 412
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 414
				return cnode -- 415
			end -- 415
		else -- 415
			local node = Dora.Sprite() -- 418
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 419
			return cnode -- 420
		end -- 420
		return nil -- 422
	end -- 409
	getVideoNode = function(enode) -- 424
		local vn = enode.props -- 425
		local ____Dora_VideoNode_10 = Dora.VideoNode -- 426
		local ____vn_file_9 = vn.file -- 426
		local ____vn_looped_8 = vn.looped -- 426
		if ____vn_looped_8 == nil then -- 426
			____vn_looped_8 = false -- 426
		end -- 426
		local node = ____Dora_VideoNode_10(____vn_file_9, ____vn_looped_8) -- 426
		if node ~= nil then -- 426
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 428
			return cnode -- 429
		end -- 429
		return nil -- 431
	end -- 424
end -- 424
local getAudioSource -- 435
do -- 435
	local function handleAudioSourceAttribute(cnode, enode, k, v) -- 437
		repeat -- 437
			local ____switch92 = k -- 437
			local ____cond92 = ____switch92 == "file" -- 437
			if ____cond92 then -- 437
				return true -- 439
			end -- 439
			____cond92 = ____cond92 or ____switch92 == "autoRemove" -- 439
			if ____cond92 then -- 439
				return true -- 440
			end -- 440
			____cond92 = ____cond92 or ____switch92 == "bus" -- 440
			if ____cond92 then -- 440
				return true -- 441
			end -- 441
			____cond92 = ____cond92 or ____switch92 == "volume" -- 441
			if ____cond92 then -- 441
				cnode.volume = v -- 442
				return true -- 442
			end -- 442
			____cond92 = ____cond92 or ____switch92 == "pan" -- 442
			if ____cond92 then -- 442
				cnode.pan = v -- 443
				return true -- 443
			end -- 443
			____cond92 = ____cond92 or ____switch92 == "looping" -- 443
			if ____cond92 then -- 443
				cnode.looping = v -- 444
				return true -- 444
			end -- 444
			____cond92 = ____cond92 or ____switch92 == "playMode" -- 444
			if ____cond92 then -- 444
				do -- 444
					local aus = enode.props -- 446
					repeat -- 446
						local ____switch94 = v -- 446
						local ____cond94 = ____switch94 == "normal" -- 446
						if ____cond94 then -- 446
							cnode:play(aus.delayTime or 0) -- 448
							break -- 448
						end -- 448
						____cond94 = ____cond94 or ____switch94 == "background" -- 448
						if ____cond94 then -- 448
							cnode:playBackground() -- 449
							break -- 449
						end -- 449
						____cond94 = ____cond94 or ____switch94 == "3D" -- 449
						if ____cond94 then -- 449
							cnode:play3D(aus.delayTime or 0) -- 450
							break -- 450
						end -- 450
					until true -- 450
					return true -- 452
				end -- 452
			end -- 452
			____cond92 = ____cond92 or ____switch92 == "delayTime" -- 452
			if ____cond92 then -- 452
				return true -- 454
			end -- 454
			____cond92 = ____cond92 or ____switch92 == "protected" -- 454
			if ____cond92 then -- 454
				cnode:setProtected(v) -- 455
				return true -- 455
			end -- 455
			____cond92 = ____cond92 or ____switch92 == "loopPoint" -- 455
			if ____cond92 then -- 455
				cnode:setLoopPoint(v) -- 456
				return true -- 456
			end -- 456
			____cond92 = ____cond92 or ____switch92 == "velocity" -- 456
			if ____cond92 then -- 456
				do -- 456
					local vx, vy, vz = table.unpack(v, 1, 3) -- 458
					cnode:setVelocity(vx, vy, vz) -- 459
					return true -- 460
				end -- 460
			end -- 460
			____cond92 = ____cond92 or ____switch92 == "minMaxDistance" -- 460
			if ____cond92 then -- 460
				do -- 460
					local min, max = table.unpack(v, 1, 2) -- 463
					cnode:setMinMaxDistance(min, max) -- 464
					return true -- 465
				end -- 465
			end -- 465
			____cond92 = ____cond92 or ____switch92 == "attenuation" -- 465
			if ____cond92 then -- 465
				do -- 465
					local model, factor = table.unpack(v, 1, 2) -- 468
					cnode:setAttenuation(model, factor) -- 469
					return true -- 470
				end -- 470
			end -- 470
			____cond92 = ____cond92 or ____switch92 == "dopplerFactor" -- 470
			if ____cond92 then -- 470
				cnode:setDopplerFactor(v) -- 472
				return true -- 472
			end -- 472
		until true -- 472
		return false -- 474
	end -- 437
	getAudioSource = function(enode) -- 476
		local aus = enode.props -- 477
		local ____aus_autoRemove_11 = aus.autoRemove -- 478
		if ____aus_autoRemove_11 == nil then -- 478
			____aus_autoRemove_11 = true -- 478
		end -- 478
		local autoRemove = ____aus_autoRemove_11 -- 478
		local node = Dora.AudioSource(aus.file, autoRemove, aus.bus) -- 479
		if node ~= nil then -- 479
			local cnode = getNode(enode, node, handleAudioSourceAttribute) -- 481
			return cnode -- 482
		end -- 482
		return nil -- 484
	end -- 476
end -- 476
local getLabel -- 488
do -- 488
	local function handleLabelAttribute(cnode, _enode, k, v) -- 490
		repeat -- 490
			local ____switch102 = k -- 490
			local ____cond102 = ____switch102 == "fontName" or ____switch102 == "fontSize" or ____switch102 == "text" or ____switch102 == "smoothLower" or ____switch102 == "smoothUpper" -- 490
			if ____cond102 then -- 490
				return true -- 492
			end -- 492
			____cond102 = ____cond102 or ____switch102 == "alphaRef" -- 492
			if ____cond102 then -- 492
				cnode.alphaRef = v -- 493
				return true -- 493
			end -- 493
			____cond102 = ____cond102 or ____switch102 == "textWidth" -- 493
			if ____cond102 then -- 493
				cnode.textWidth = v -- 494
				return true -- 494
			end -- 494
			____cond102 = ____cond102 or ____switch102 == "lineGap" -- 494
			if ____cond102 then -- 494
				cnode.lineGap = v -- 495
				return true -- 495
			end -- 495
			____cond102 = ____cond102 or ____switch102 == "spacing" -- 495
			if ____cond102 then -- 495
				cnode.spacing = v -- 496
				return true -- 496
			end -- 496
			____cond102 = ____cond102 or ____switch102 == "outlineColor" -- 496
			if ____cond102 then -- 496
				cnode.outlineColor = Dora.Color(v) -- 497
				return true -- 497
			end -- 497
			____cond102 = ____cond102 or ____switch102 == "outlineWidth" -- 497
			if ____cond102 then -- 497
				cnode.outlineWidth = v -- 498
				return true -- 498
			end -- 498
			____cond102 = ____cond102 or ____switch102 == "blendFunc" -- 498
			if ____cond102 then -- 498
				cnode.blendFunc = v -- 499
				return true -- 499
			end -- 499
			____cond102 = ____cond102 or ____switch102 == "depthWrite" -- 499
			if ____cond102 then -- 499
				cnode.depthWrite = v -- 500
				return true -- 500
			end -- 500
			____cond102 = ____cond102 or ____switch102 == "batched" -- 500
			if ____cond102 then -- 500
				cnode.batched = v -- 501
				return true -- 501
			end -- 501
			____cond102 = ____cond102 or ____switch102 == "effect" -- 501
			if ____cond102 then -- 501
				cnode.effect = v -- 502
				return true -- 502
			end -- 502
			____cond102 = ____cond102 or ____switch102 == "alignment" -- 502
			if ____cond102 then -- 502
				cnode.alignment = v -- 503
				return true -- 503
			end -- 503
		until true -- 503
		return false -- 505
	end -- 490
	getLabel = function(enode) -- 507
		local label = enode.props -- 508
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 509
		if node ~= nil then -- 509
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 509
				local ____node_smooth_12 = node.smooth -- 512
				local x = ____node_smooth_12.x -- 512
				local y = ____node_smooth_12.y -- 512
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 513
			end -- 513
			local cnode = getNode(enode, node, handleLabelAttribute) -- 515
			local ____enode_13 = enode -- 516
			local children = ____enode_13.children -- 516
			local text = label.text or "" -- 517
			for i = 1, #children do -- 517
				local child = children[i] -- 519
				if type(child) ~= "table" then -- 519
					text = text .. tostring(child) -- 521
				end -- 521
			end -- 521
			node.text = text -- 524
			return cnode -- 525
		end -- 525
		return nil -- 527
	end -- 507
end -- 507
local getLine -- 531
do -- 531
	local function handleLineAttribute(cnode, enode, k, v) -- 533
		local line = enode.props -- 534
		repeat -- 534
			local ____switch110 = k -- 534
			local ____cond110 = ____switch110 == "verts" -- 534
			if ____cond110 then -- 534
				cnode:set( -- 536
					v, -- 536
					Dora.Color(line.lineColor or 4294967295) -- 536
				) -- 536
				return true -- 536
			end -- 536
			____cond110 = ____cond110 or ____switch110 == "depthWrite" -- 536
			if ____cond110 then -- 536
				cnode.depthWrite = v -- 537
				return true -- 537
			end -- 537
			____cond110 = ____cond110 or ____switch110 == "blendFunc" -- 537
			if ____cond110 then -- 537
				cnode.blendFunc = v -- 538
				return true -- 538
			end -- 538
		until true -- 538
		return false -- 540
	end -- 533
	getLine = function(enode) -- 542
		local node = Dora.Line() -- 543
		local cnode = getNode(enode, node, handleLineAttribute) -- 544
		return cnode -- 545
	end -- 542
end -- 542
local getParticle -- 549
do -- 549
	local function handleParticleAttribute(cnode, _enode, k, v) -- 551
		repeat -- 551
			local ____switch114 = k -- 551
			local ____cond114 = ____switch114 == "file" -- 551
			if ____cond114 then -- 551
				return true -- 553
			end -- 553
			____cond114 = ____cond114 or ____switch114 == "emit" -- 553
			if ____cond114 then -- 553
				if v then -- 553
					cnode:start() -- 554
				end -- 554
				return true -- 554
			end -- 554
			____cond114 = ____cond114 or ____switch114 == "onFinished" -- 554
			if ____cond114 then -- 554
				cnode:slot("Finished", v) -- 555
				return true -- 555
			end -- 555
		until true -- 555
		return false -- 557
	end -- 551
	getParticle = function(enode) -- 559
		local particle = enode.props -- 560
		local node = Dora.Particle(particle.file) -- 561
		if node ~= nil then -- 561
			local cnode = getNode(enode, node, handleParticleAttribute) -- 563
			return cnode -- 564
		end -- 564
		return nil -- 566
	end -- 559
end -- 559
local getMenu -- 570
do -- 570
	local function handleMenuAttribute(cnode, _enode, k, v) -- 572
		repeat -- 572
			local ____switch120 = k -- 572
			local ____cond120 = ____switch120 == "enabled" -- 572
			if ____cond120 then -- 572
				cnode.enabled = v -- 574
				return true -- 574
			end -- 574
		until true -- 574
		return false -- 576
	end -- 572
	getMenu = function(enode) -- 578
		local node = Dora.Menu() -- 579
		local cnode = getNode(enode, node, handleMenuAttribute) -- 580
		return cnode -- 581
	end -- 578
end -- 578
local function getPhysicsWorld(enode) -- 585
	local node = Dora.PhysicsWorld() -- 586
	local cnode = getNode(enode, node) -- 587
	return cnode -- 588
end -- 585
local getBody -- 591
do -- 591
	local function handleBodyAttribute(cnode, _enode, k, v) -- 593
		repeat -- 593
			local ____switch125 = k -- 593
			local ____cond125 = ____switch125 == "type" or ____switch125 == "linearAcceleration" or ____switch125 == "fixedRotation" or ____switch125 == "bullet" or ____switch125 == "world" -- 593
			if ____cond125 then -- 593
				return true -- 600
			end -- 600
			____cond125 = ____cond125 or ____switch125 == "velocityX" -- 600
			if ____cond125 then -- 600
				cnode.velocityX = v -- 601
				return true -- 601
			end -- 601
			____cond125 = ____cond125 or ____switch125 == "velocityY" -- 601
			if ____cond125 then -- 601
				cnode.velocityY = v -- 602
				return true -- 602
			end -- 602
			____cond125 = ____cond125 or ____switch125 == "angularRate" -- 602
			if ____cond125 then -- 602
				cnode.angularRate = v -- 603
				return true -- 603
			end -- 603
			____cond125 = ____cond125 or ____switch125 == "group" -- 603
			if ____cond125 then -- 603
				cnode.group = v -- 604
				return true -- 604
			end -- 604
			____cond125 = ____cond125 or ____switch125 == "linearDamping" -- 604
			if ____cond125 then -- 604
				cnode.linearDamping = v -- 605
				return true -- 605
			end -- 605
			____cond125 = ____cond125 or ____switch125 == "angularDamping" -- 605
			if ____cond125 then -- 605
				cnode.angularDamping = v -- 606
				return true -- 606
			end -- 606
			____cond125 = ____cond125 or ____switch125 == "owner" -- 606
			if ____cond125 then -- 606
				cnode.owner = v -- 607
				return true -- 607
			end -- 607
			____cond125 = ____cond125 or ____switch125 == "receivingContact" -- 607
			if ____cond125 then -- 607
				cnode.receivingContact = v -- 608
				return true -- 608
			end -- 608
			____cond125 = ____cond125 or ____switch125 == "onBodyEnter" -- 608
			if ____cond125 then -- 608
				cnode:slot("BodyEnter", v) -- 609
				return true -- 609
			end -- 609
			____cond125 = ____cond125 or ____switch125 == "onBodyLeave" -- 609
			if ____cond125 then -- 609
				cnode:slot("BodyLeave", v) -- 610
				return true -- 610
			end -- 610
			____cond125 = ____cond125 or ____switch125 == "onContactStart" -- 610
			if ____cond125 then -- 610
				cnode:slot("ContactStart", v) -- 611
				return true -- 611
			end -- 611
			____cond125 = ____cond125 or ____switch125 == "onContactEnd" -- 611
			if ____cond125 then -- 611
				cnode:slot("ContactEnd", v) -- 612
				return true -- 612
			end -- 612
			____cond125 = ____cond125 or ____switch125 == "onContactFilter" -- 612
			if ____cond125 then -- 612
				cnode:onContactFilter(v) -- 613
				return true -- 613
			end -- 613
		until true -- 613
		return false -- 615
	end -- 593
	getBody = function(enode, world) -- 617
		local def = enode.props -- 618
		local bodyDef = Dora.BodyDef() -- 619
		bodyDef.type = def.type -- 620
		if def.angle ~= nil then -- 620
			bodyDef.angle = def.angle -- 621
		end -- 621
		if def.angularDamping ~= nil then -- 621
			bodyDef.angularDamping = def.angularDamping -- 622
		end -- 622
		if def.bullet ~= nil then -- 622
			bodyDef.bullet = def.bullet -- 623
		end -- 623
		if def.fixedRotation ~= nil then -- 623
			bodyDef.fixedRotation = def.fixedRotation -- 624
		end -- 624
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 625
		if def.linearDamping ~= nil then -- 625
			bodyDef.linearDamping = def.linearDamping -- 626
		end -- 626
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 627
		local extraSensors = nil -- 628
		for i = 1, #enode.children do -- 628
			do -- 628
				local child = enode.children[i] -- 630
				if type(child) ~= "table" then -- 630
					goto __continue132 -- 632
				end -- 632
				repeat -- 632
					local ____switch134 = child.type -- 632
					local ____cond134 = ____switch134 == "rect-fixture" -- 632
					if ____cond134 then -- 632
						do -- 632
							local shape = child.props -- 636
							if shape.sensorTag ~= nil then -- 636
								bodyDef:attachPolygonSensor( -- 638
									shape.sensorTag, -- 639
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 640
									shape.width, -- 641
									shape.height, -- 641
									shape.angle or 0 -- 642
								) -- 642
							else -- 642
								bodyDef:attachPolygon( -- 645
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 646
									shape.width, -- 647
									shape.height, -- 647
									shape.angle or 0, -- 648
									shape.density or 1, -- 649
									shape.friction or 0.4, -- 650
									shape.restitution or 0 -- 651
								) -- 651
							end -- 651
							break -- 654
						end -- 654
					end -- 654
					____cond134 = ____cond134 or ____switch134 == "polygon-fixture" -- 654
					if ____cond134 then -- 654
						do -- 654
							local shape = child.props -- 657
							if shape.sensorTag ~= nil then -- 657
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 659
							else -- 659
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 664
							end -- 664
							break -- 671
						end -- 671
					end -- 671
					____cond134 = ____cond134 or ____switch134 == "multi-fixture" -- 671
					if ____cond134 then -- 671
						do -- 671
							local shape = child.props -- 674
							if shape.sensorTag ~= nil then -- 674
								if extraSensors == nil then -- 674
									extraSensors = {} -- 676
								end -- 676
								extraSensors[#extraSensors + 1] = { -- 677
									shape.sensorTag, -- 677
									Dora.BodyDef:multi(shape.verts) -- 677
								} -- 677
							else -- 677
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 679
							end -- 679
							break -- 686
						end -- 686
					end -- 686
					____cond134 = ____cond134 or ____switch134 == "disk-fixture" -- 686
					if ____cond134 then -- 686
						do -- 686
							local shape = child.props -- 689
							if shape.sensorTag ~= nil then -- 689
								bodyDef:attachDiskSensor( -- 691
									shape.sensorTag, -- 692
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 693
									shape.radius -- 694
								) -- 694
							else -- 694
								bodyDef:attachDisk( -- 697
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 698
									shape.radius, -- 699
									shape.density or 1, -- 700
									shape.friction or 0.4, -- 701
									shape.restitution or 0 -- 702
								) -- 702
							end -- 702
							break -- 705
						end -- 705
					end -- 705
					____cond134 = ____cond134 or ____switch134 == "chain-fixture" -- 705
					if ____cond134 then -- 705
						do -- 705
							local shape = child.props -- 708
							if shape.sensorTag ~= nil then -- 708
								if extraSensors == nil then -- 708
									extraSensors = {} -- 710
								end -- 710
								extraSensors[#extraSensors + 1] = { -- 711
									shape.sensorTag, -- 711
									Dora.BodyDef:chain(shape.verts) -- 711
								} -- 711
							else -- 711
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 713
							end -- 713
							break -- 719
						end -- 719
					end -- 719
				until true -- 719
			end -- 719
			::__continue132:: -- 719
		end -- 719
		local body = Dora.Body(bodyDef, world) -- 723
		if extraSensors ~= nil then -- 723
			for i = 1, #extraSensors do -- 723
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 726
				body:attachSensor(tag, def) -- 727
			end -- 727
		end -- 727
		local cnode = getNode(enode, body, handleBodyAttribute) -- 730
		if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 730
			body.receivingContact = true -- 735
		end -- 735
		return cnode -- 737
	end -- 617
end -- 617
local getCustomNode -- 741
do -- 741
	local function handleCustomNode(_cnode, _enode, k, _v) -- 743
		repeat -- 743
			local ____switch155 = k -- 743
			local ____cond155 = ____switch155 == "onCreate" -- 743
			if ____cond155 then -- 743
				return true -- 745
			end -- 745
		until true -- 745
		return false -- 747
	end -- 743
	getCustomNode = function(enode) -- 749
		local custom = enode.props -- 750
		local node = custom.onCreate() -- 751
		if node then -- 751
			local cnode = getNode(enode, node, handleCustomNode) -- 753
			return cnode -- 754
		end -- 754
		return nil -- 756
	end -- 749
end -- 749
local getAlignNode -- 760
do -- 760
	local function handleAlignNode(_cnode, _enode, k, _v) -- 762
		repeat -- 762
			local ____switch160 = k -- 762
			local ____cond160 = ____switch160 == "windowRoot" -- 762
			if ____cond160 then -- 762
				return true -- 764
			end -- 764
			____cond160 = ____cond160 or ____switch160 == "style" -- 764
			if ____cond160 then -- 764
				return true -- 765
			end -- 765
			____cond160 = ____cond160 or ____switch160 == "onLayout" -- 765
			if ____cond160 then -- 765
				return true -- 766
			end -- 766
		until true -- 766
		return false -- 768
	end -- 762
	getAlignNode = function(enode) -- 770
		local alignNode = enode.props -- 771
		local node = Dora.AlignNode(alignNode.windowRoot) -- 772
		if alignNode.style then -- 772
			local items = {} -- 774
			for k, v in pairs(alignNode.style) do -- 775
				local name = string.gsub(k, "%u", "-%1") -- 776
				name = string.lower(name) -- 777
				repeat -- 777
					local ____switch164 = k -- 777
					local ____cond164 = ____switch164 == "margin" or ____switch164 == "padding" or ____switch164 == "border" or ____switch164 == "gap" -- 777
					if ____cond164 then -- 777
						do -- 777
							if type(v) == "table" then -- 777
								local valueStr = table.concat( -- 782
									__TS__ArrayMap( -- 782
										v, -- 782
										function(____, item) return tostring(item) end -- 782
									), -- 782
									"," -- 782
								) -- 782
								items[#items + 1] = (name .. ":") .. valueStr -- 783
							else -- 783
								items[#items + 1] = (name .. ":") .. tostring(v) -- 785
							end -- 785
							break -- 787
						end -- 787
					end -- 787
					do -- 787
						items[#items + 1] = (name .. ":") .. tostring(v) -- 790
						break -- 791
					end -- 791
				until true -- 791
			end -- 791
			local styleStr = table.concat(items, ";") -- 794
			node:css(styleStr) -- 795
		end -- 795
		if alignNode.onLayout then -- 795
			node:slot("AlignLayout", alignNode.onLayout) -- 798
		end -- 798
		local cnode = getNode(enode, node, handleAlignNode) -- 800
		return cnode -- 801
	end -- 770
end -- 770
local function getEffekNode(enode) -- 805
	return getNode( -- 806
		enode, -- 806
		Dora.EffekNode() -- 806
	) -- 806
end -- 805
local getTileNode -- 809
do -- 809
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 811
		repeat -- 811
			local ____switch173 = k -- 811
			local ____cond173 = ____switch173 == "file" or ____switch173 == "layers" -- 811
			if ____cond173 then -- 811
				return true -- 813
			end -- 813
			____cond173 = ____cond173 or ____switch173 == "depthWrite" -- 813
			if ____cond173 then -- 813
				cnode.depthWrite = v -- 814
				return true -- 814
			end -- 814
			____cond173 = ____cond173 or ____switch173 == "blendFunc" -- 814
			if ____cond173 then -- 814
				cnode.blendFunc = v -- 815
				return true -- 815
			end -- 815
			____cond173 = ____cond173 or ____switch173 == "effect" -- 815
			if ____cond173 then -- 815
				cnode.effect = v -- 816
				return true -- 816
			end -- 816
			____cond173 = ____cond173 or ____switch173 == "filter" -- 816
			if ____cond173 then -- 816
				cnode.filter = v -- 817
				return true -- 817
			end -- 817
		until true -- 817
		return false -- 819
	end -- 811
	getTileNode = function(enode) -- 821
		local tn = enode.props -- 822
		local ____tn_layers_14 -- 823
		if tn.layers then -- 823
			____tn_layers_14 = Dora.TileNode(tn.file, tn.layers) -- 823
		else -- 823
			____tn_layers_14 = Dora.TileNode(tn.file) -- 823
		end -- 823
		local node = ____tn_layers_14 -- 823
		if node ~= nil then -- 823
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 825
			return cnode -- 826
		end -- 826
		return nil -- 828
	end -- 821
end -- 821
local function addChild(nodeStack, cnode, enode) -- 832
	if #nodeStack > 0 then -- 832
		local last = nodeStack[#nodeStack] -- 834
		last:addChild(cnode) -- 835
	end -- 835
	nodeStack[#nodeStack + 1] = cnode -- 837
	local ____enode_15 = enode -- 838
	local children = ____enode_15.children -- 838
	for i = 1, #children do -- 838
		visitNode(nodeStack, children[i], enode) -- 840
	end -- 840
	if #nodeStack > 1 then -- 840
		table.remove(nodeStack) -- 843
	end -- 843
end -- 832
local function drawNodeCheck(_nodeStack, enode, parent) -- 851
	if parent == nil or parent.type ~= "draw-node" then -- 851
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 853
	end -- 853
end -- 851
local function visitAction(actionStack, enode) -- 857
	local createAction = actionMap[enode.type] -- 858
	if createAction ~= nil then -- 858
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 860
		return -- 861
	end -- 861
	repeat -- 861
		local ____switch184 = enode.type -- 861
		local ____cond184 = ____switch184 == "delay" -- 861
		if ____cond184 then -- 861
			do -- 861
				local item = enode.props -- 865
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 866
				break -- 867
			end -- 867
		end -- 867
		____cond184 = ____cond184 or ____switch184 == "event" -- 867
		if ____cond184 then -- 867
			do -- 867
				local item = enode.props -- 870
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 871
				break -- 872
			end -- 872
		end -- 872
		____cond184 = ____cond184 or ____switch184 == "hide" -- 872
		if ____cond184 then -- 872
			do -- 872
				actionStack[#actionStack + 1] = Dora.Hide() -- 875
				break -- 876
			end -- 876
		end -- 876
		____cond184 = ____cond184 or ____switch184 == "show" -- 876
		if ____cond184 then -- 876
			do -- 876
				actionStack[#actionStack + 1] = Dora.Show() -- 879
				break -- 880
			end -- 880
		end -- 880
		____cond184 = ____cond184 or ____switch184 == "move" -- 880
		if ____cond184 then -- 880
			do -- 880
				local item = enode.props -- 883
				actionStack[#actionStack + 1] = Dora.Move( -- 884
					item.time, -- 884
					Dora.Vec2(item.startX, item.startY), -- 884
					Dora.Vec2(item.stopX, item.stopY), -- 884
					item.easing -- 884
				) -- 884
				break -- 885
			end -- 885
		end -- 885
		____cond184 = ____cond184 or ____switch184 == "frame" -- 885
		if ____cond184 then -- 885
			do -- 885
				local item = enode.props -- 888
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 889
				break -- 890
			end -- 890
		end -- 890
		____cond184 = ____cond184 or ____switch184 == "spawn" -- 890
		if ____cond184 then -- 890
			do -- 890
				local spawnStack = {} -- 893
				for i = 1, #enode.children do -- 893
					visitAction(spawnStack, enode.children[i]) -- 895
				end -- 895
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 897
				break -- 898
			end -- 898
		end -- 898
		____cond184 = ____cond184 or ____switch184 == "sequence" -- 898
		if ____cond184 then -- 898
			do -- 898
				local sequenceStack = {} -- 901
				for i = 1, #enode.children do -- 901
					visitAction(sequenceStack, enode.children[i]) -- 903
				end -- 903
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 905
				break -- 906
			end -- 906
		end -- 906
		do -- 906
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 909
			break -- 910
		end -- 910
	until true -- 910
end -- 857
local function actionCheck(nodeStack, enode, parent) -- 914
	local unsupported = false -- 915
	if parent == nil then -- 915
		unsupported = true -- 917
	else -- 917
		repeat -- 917
			local ____switch198 = parent.type -- 917
			local ____cond198 = ____switch198 == "action" or ____switch198 == "spawn" or ____switch198 == "sequence" -- 917
			if ____cond198 then -- 917
				break -- 920
			end -- 920
			do -- 920
				unsupported = true -- 921
				break -- 921
			end -- 921
		until true -- 921
	end -- 921
	if unsupported then -- 921
		if #nodeStack > 0 then -- 921
			local node = nodeStack[#nodeStack] -- 926
			local actionStack = {} -- 927
			visitAction(actionStack, enode) -- 928
			if #actionStack == 1 then -- 928
				node:runAction(actionStack[1]) -- 930
			end -- 930
		else -- 930
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 933
		end -- 933
	end -- 933
end -- 914
local function bodyCheck(_nodeStack, enode, parent) -- 938
	if parent == nil or parent.type ~= "body" then -- 938
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 940
	end -- 940
end -- 938
actionMap = { -- 944
	["anchor-x"] = Dora.AnchorX, -- 947
	["anchor-y"] = Dora.AnchorY, -- 948
	angle = Dora.Angle, -- 949
	["angle-x"] = Dora.AngleX, -- 950
	["angle-y"] = Dora.AngleY, -- 951
	width = Dora.Width, -- 952
	height = Dora.Height, -- 953
	opacity = Dora.Opacity, -- 954
	roll = Dora.Roll, -- 955
	scale = Dora.Scale, -- 956
	["scale-x"] = Dora.ScaleX, -- 957
	["scale-y"] = Dora.ScaleY, -- 958
	["skew-x"] = Dora.SkewX, -- 959
	["skew-y"] = Dora.SkewY, -- 960
	["move-x"] = Dora.X, -- 961
	["move-y"] = Dora.Y, -- 962
	["move-z"] = Dora.Z -- 963
} -- 963
elementMap = { -- 966
	node = function(nodeStack, enode, parent) -- 967
		addChild( -- 968
			nodeStack, -- 968
			getNode(enode), -- 968
			enode -- 968
		) -- 968
	end, -- 967
	["clip-node"] = function(nodeStack, enode, parent) -- 970
		addChild( -- 971
			nodeStack, -- 971
			getClipNode(enode), -- 971
			enode -- 971
		) -- 971
	end, -- 970
	playable = function(nodeStack, enode, parent) -- 973
		local cnode = getPlayable(enode) -- 974
		if cnode ~= nil then -- 974
			addChild(nodeStack, cnode, enode) -- 976
		end -- 976
	end, -- 973
	["dragon-bone"] = function(nodeStack, enode, parent) -- 979
		local cnode = getDragonBone(enode) -- 980
		if cnode ~= nil then -- 980
			addChild(nodeStack, cnode, enode) -- 982
		end -- 982
	end, -- 979
	spine = function(nodeStack, enode, parent) -- 985
		local cnode = getSpine(enode) -- 986
		if cnode ~= nil then -- 986
			addChild(nodeStack, cnode, enode) -- 988
		end -- 988
	end, -- 985
	model = function(nodeStack, enode, parent) -- 991
		local cnode = getModel(enode) -- 992
		if cnode ~= nil then -- 992
			addChild(nodeStack, cnode, enode) -- 994
		end -- 994
	end, -- 991
	["draw-node"] = function(nodeStack, enode, parent) -- 997
		addChild( -- 998
			nodeStack, -- 998
			getDrawNode(enode), -- 998
			enode -- 998
		) -- 998
	end, -- 997
	["dot-shape"] = drawNodeCheck, -- 1000
	["segment-shape"] = drawNodeCheck, -- 1001
	["rect-shape"] = drawNodeCheck, -- 1002
	["polygon-shape"] = drawNodeCheck, -- 1003
	["verts-shape"] = drawNodeCheck, -- 1004
	grid = function(nodeStack, enode, parent) -- 1005
		addChild( -- 1006
			nodeStack, -- 1006
			getGrid(enode), -- 1006
			enode -- 1006
		) -- 1006
	end, -- 1005
	sprite = function(nodeStack, enode, parent) -- 1008
		local cnode = getSprite(enode) -- 1009
		if cnode ~= nil then -- 1009
			addChild(nodeStack, cnode, enode) -- 1011
		end -- 1011
	end, -- 1008
	["audio-source"] = function(nodeStack, enode, parent) -- 1014
		local cnode = getAudioSource(enode) -- 1015
		if cnode ~= nil then -- 1015
			addChild(nodeStack, cnode, enode) -- 1017
		end -- 1017
	end, -- 1014
	["video-node"] = function(nodeStack, enode, parent) -- 1020
		local cnode = getVideoNode(enode) -- 1021
		if cnode ~= nil then -- 1021
			addChild(nodeStack, cnode, enode) -- 1023
		end -- 1023
	end, -- 1020
	label = function(nodeStack, enode, parent) -- 1026
		local cnode = getLabel(enode) -- 1027
		if cnode ~= nil then -- 1027
			addChild(nodeStack, cnode, enode) -- 1029
		end -- 1029
	end, -- 1026
	line = function(nodeStack, enode, parent) -- 1032
		addChild( -- 1033
			nodeStack, -- 1033
			getLine(enode), -- 1033
			enode -- 1033
		) -- 1033
	end, -- 1032
	particle = function(nodeStack, enode, parent) -- 1035
		local cnode = getParticle(enode) -- 1036
		if cnode ~= nil then -- 1036
			addChild(nodeStack, cnode, enode) -- 1038
		end -- 1038
	end, -- 1035
	menu = function(nodeStack, enode, parent) -- 1041
		addChild( -- 1042
			nodeStack, -- 1042
			getMenu(enode), -- 1042
			enode -- 1042
		) -- 1042
	end, -- 1041
	action = function(_nodeStack, enode, parent) -- 1044
		if #enode.children == 0 then -- 1044
			Warn("<action> tag has no children") -- 1046
			return -- 1047
		end -- 1047
		local action = enode.props -- 1049
		if action.ref == nil then -- 1049
			Warn("<action> tag has no ref") -- 1051
			return -- 1052
		end -- 1052
		local actionStack = {} -- 1054
		for i = 1, #enode.children do -- 1054
			visitAction(actionStack, enode.children[i]) -- 1056
		end -- 1056
		if #actionStack == 1 then -- 1056
			action.ref.current = actionStack[1] -- 1059
		elseif #actionStack > 1 then -- 1059
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 1061
		end -- 1061
	end, -- 1044
	["anchor-x"] = actionCheck, -- 1064
	["anchor-y"] = actionCheck, -- 1065
	angle = actionCheck, -- 1066
	["angle-x"] = actionCheck, -- 1067
	["angle-y"] = actionCheck, -- 1068
	delay = actionCheck, -- 1069
	event = actionCheck, -- 1070
	width = actionCheck, -- 1071
	height = actionCheck, -- 1072
	hide = actionCheck, -- 1073
	show = actionCheck, -- 1074
	move = actionCheck, -- 1075
	opacity = actionCheck, -- 1076
	roll = actionCheck, -- 1077
	scale = actionCheck, -- 1078
	["scale-x"] = actionCheck, -- 1079
	["scale-y"] = actionCheck, -- 1080
	["skew-x"] = actionCheck, -- 1081
	["skew-y"] = actionCheck, -- 1082
	["move-x"] = actionCheck, -- 1083
	["move-y"] = actionCheck, -- 1084
	["move-z"] = actionCheck, -- 1085
	frame = actionCheck, -- 1086
	spawn = actionCheck, -- 1087
	sequence = actionCheck, -- 1088
	loop = function(nodeStack, enode, _parent) -- 1089
		if #nodeStack > 0 then -- 1089
			local node = nodeStack[#nodeStack] -- 1091
			local actionStack = {} -- 1092
			for i = 1, #enode.children do -- 1092
				visitAction(actionStack, enode.children[i]) -- 1094
			end -- 1094
			if #actionStack == 1 then -- 1094
				node:runAction(actionStack[1], true) -- 1097
			else -- 1097
				local loop = enode.props -- 1099
				if loop.spawn then -- 1099
					node:runAction( -- 1101
						Dora.Spawn(table.unpack(actionStack)), -- 1101
						true -- 1101
					) -- 1101
				else -- 1101
					node:runAction( -- 1103
						Dora.Sequence(table.unpack(actionStack)), -- 1103
						true -- 1103
					) -- 1103
				end -- 1103
			end -- 1103
		else -- 1103
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1107
		end -- 1107
	end, -- 1089
	["physics-world"] = function(nodeStack, enode, _parent) -- 1110
		addChild( -- 1111
			nodeStack, -- 1111
			getPhysicsWorld(enode), -- 1111
			enode -- 1111
		) -- 1111
	end, -- 1110
	contact = function(nodeStack, enode, _parent) -- 1113
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1114
		if world ~= nil then -- 1114
			local contact = enode.props -- 1116
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1117
		else -- 1117
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1119
		end -- 1119
	end, -- 1113
	body = function(nodeStack, enode, _parent) -- 1122
		local def = enode.props -- 1123
		if def.world then -- 1123
			addChild( -- 1125
				nodeStack, -- 1125
				getBody(enode, def.world), -- 1125
				enode -- 1125
			) -- 1125
			return -- 1126
		end -- 1126
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1128
		if world ~= nil then -- 1128
			addChild( -- 1130
				nodeStack, -- 1130
				getBody(enode, world), -- 1130
				enode -- 1130
			) -- 1130
		else -- 1130
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1132
		end -- 1132
	end, -- 1122
	["rect-fixture"] = bodyCheck, -- 1135
	["polygon-fixture"] = bodyCheck, -- 1136
	["multi-fixture"] = bodyCheck, -- 1137
	["disk-fixture"] = bodyCheck, -- 1138
	["chain-fixture"] = bodyCheck, -- 1139
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1140
		local joint = enode.props -- 1141
		if joint.ref == nil then -- 1141
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1143
			return -- 1144
		end -- 1144
		if joint.bodyA.current == nil then -- 1144
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1147
			return -- 1148
		end -- 1148
		if joint.bodyB.current == nil then -- 1148
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1151
			return -- 1152
		end -- 1152
		local ____joint_ref_19 = joint.ref -- 1154
		local ____self_17 = Dora.Joint -- 1154
		local ____self_17_distance_18 = ____self_17.distance -- 1154
		local ____joint_canCollide_16 = joint.canCollide -- 1155
		if ____joint_canCollide_16 == nil then -- 1155
			____joint_canCollide_16 = false -- 1155
		end -- 1155
		____joint_ref_19.current = ____self_17_distance_18( -- 1154
			____self_17, -- 1154
			____joint_canCollide_16, -- 1155
			joint.bodyA.current, -- 1156
			joint.bodyB.current, -- 1157
			joint.anchorA or Dora.Vec2.zero, -- 1158
			joint.anchorB or Dora.Vec2.zero, -- 1159
			joint.frequency or 0, -- 1160
			joint.damping or 0 -- 1161
		) -- 1161
	end, -- 1140
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1163
		local joint = enode.props -- 1164
		if joint.ref == nil then -- 1164
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1166
			return -- 1167
		end -- 1167
		if joint.bodyA.current == nil then -- 1167
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1170
			return -- 1171
		end -- 1171
		if joint.bodyB.current == nil then -- 1171
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1174
			return -- 1175
		end -- 1175
		local ____joint_ref_23 = joint.ref -- 1177
		local ____self_21 = Dora.Joint -- 1177
		local ____self_21_friction_22 = ____self_21.friction -- 1177
		local ____joint_canCollide_20 = joint.canCollide -- 1178
		if ____joint_canCollide_20 == nil then -- 1178
			____joint_canCollide_20 = false -- 1178
		end -- 1178
		____joint_ref_23.current = ____self_21_friction_22( -- 1177
			____self_21, -- 1177
			____joint_canCollide_20, -- 1178
			joint.bodyA.current, -- 1179
			joint.bodyB.current, -- 1180
			joint.worldPos, -- 1181
			joint.maxForce, -- 1182
			joint.maxTorque -- 1183
		) -- 1183
	end, -- 1163
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1186
		local joint = enode.props -- 1187
		if joint.ref == nil then -- 1187
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1189
			return -- 1190
		end -- 1190
		if joint.jointA.current == nil then -- 1190
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1193
			return -- 1194
		end -- 1194
		if joint.jointB.current == nil then -- 1194
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1197
			return -- 1198
		end -- 1198
		local ____joint_ref_27 = joint.ref -- 1200
		local ____self_25 = Dora.Joint -- 1200
		local ____self_25_gear_26 = ____self_25.gear -- 1200
		local ____joint_canCollide_24 = joint.canCollide -- 1201
		if ____joint_canCollide_24 == nil then -- 1201
			____joint_canCollide_24 = false -- 1201
		end -- 1201
		____joint_ref_27.current = ____self_25_gear_26( -- 1200
			____self_25, -- 1200
			____joint_canCollide_24, -- 1201
			joint.jointA.current, -- 1202
			joint.jointB.current, -- 1203
			joint.ratio or 1 -- 1204
		) -- 1204
	end, -- 1186
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1207
		local joint = enode.props -- 1208
		if joint.ref == nil then -- 1208
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1210
			return -- 1211
		end -- 1211
		if joint.bodyA.current == nil then -- 1211
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1214
			return -- 1215
		end -- 1215
		if joint.bodyB.current == nil then -- 1215
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1218
			return -- 1219
		end -- 1219
		local ____joint_ref_31 = joint.ref -- 1221
		local ____self_29 = Dora.Joint -- 1221
		local ____self_29_spring_30 = ____self_29.spring -- 1221
		local ____joint_canCollide_28 = joint.canCollide -- 1222
		if ____joint_canCollide_28 == nil then -- 1222
			____joint_canCollide_28 = false -- 1222
		end -- 1222
		____joint_ref_31.current = ____self_29_spring_30( -- 1221
			____self_29, -- 1221
			____joint_canCollide_28, -- 1222
			joint.bodyA.current, -- 1223
			joint.bodyB.current, -- 1224
			joint.linearOffset, -- 1225
			joint.angularOffset, -- 1226
			joint.maxForce, -- 1227
			joint.maxTorque, -- 1228
			joint.correctionFactor or 1 -- 1229
		) -- 1229
	end, -- 1207
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1232
		local joint = enode.props -- 1233
		if joint.ref == nil then -- 1233
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1235
			return -- 1236
		end -- 1236
		if joint.body.current == nil then -- 1236
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1239
			return -- 1240
		end -- 1240
		local ____joint_ref_35 = joint.ref -- 1242
		local ____self_33 = Dora.Joint -- 1242
		local ____self_33_move_34 = ____self_33.move -- 1242
		local ____joint_canCollide_32 = joint.canCollide -- 1243
		if ____joint_canCollide_32 == nil then -- 1243
			____joint_canCollide_32 = false -- 1243
		end -- 1243
		____joint_ref_35.current = ____self_33_move_34( -- 1242
			____self_33, -- 1242
			____joint_canCollide_32, -- 1243
			joint.body.current, -- 1244
			joint.targetPos, -- 1245
			joint.maxForce, -- 1246
			joint.frequency, -- 1247
			joint.damping or 0.7 -- 1248
		) -- 1248
	end, -- 1232
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1251
		local joint = enode.props -- 1252
		if joint.ref == nil then -- 1252
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1254
			return -- 1255
		end -- 1255
		if joint.bodyA.current == nil then -- 1255
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1258
			return -- 1259
		end -- 1259
		if joint.bodyB.current == nil then -- 1259
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1262
			return -- 1263
		end -- 1263
		local ____joint_ref_39 = joint.ref -- 1265
		local ____self_37 = Dora.Joint -- 1265
		local ____self_37_prismatic_38 = ____self_37.prismatic -- 1265
		local ____joint_canCollide_36 = joint.canCollide -- 1266
		if ____joint_canCollide_36 == nil then -- 1266
			____joint_canCollide_36 = false -- 1266
		end -- 1266
		____joint_ref_39.current = ____self_37_prismatic_38( -- 1265
			____self_37, -- 1265
			____joint_canCollide_36, -- 1266
			joint.bodyA.current, -- 1267
			joint.bodyB.current, -- 1268
			joint.worldPos, -- 1269
			joint.axisAngle, -- 1270
			joint.lowerTranslation or 0, -- 1271
			joint.upperTranslation or 0, -- 1272
			joint.maxMotorForce or 0, -- 1273
			joint.motorSpeed or 0 -- 1274
		) -- 1274
	end, -- 1251
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1277
		local joint = enode.props -- 1278
		if joint.ref == nil then -- 1278
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1280
			return -- 1281
		end -- 1281
		if joint.bodyA.current == nil then -- 1281
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1284
			return -- 1285
		end -- 1285
		if joint.bodyB.current == nil then -- 1285
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1288
			return -- 1289
		end -- 1289
		local ____joint_ref_43 = joint.ref -- 1291
		local ____self_41 = Dora.Joint -- 1291
		local ____self_41_pulley_42 = ____self_41.pulley -- 1291
		local ____joint_canCollide_40 = joint.canCollide -- 1292
		if ____joint_canCollide_40 == nil then -- 1292
			____joint_canCollide_40 = false -- 1292
		end -- 1292
		____joint_ref_43.current = ____self_41_pulley_42( -- 1291
			____self_41, -- 1291
			____joint_canCollide_40, -- 1292
			joint.bodyA.current, -- 1293
			joint.bodyB.current, -- 1294
			joint.anchorA or Dora.Vec2.zero, -- 1295
			joint.anchorB or Dora.Vec2.zero, -- 1296
			joint.groundAnchorA, -- 1297
			joint.groundAnchorB, -- 1298
			joint.ratio or 1 -- 1299
		) -- 1299
	end, -- 1277
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1302
		local joint = enode.props -- 1303
		if joint.ref == nil then -- 1303
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1305
			return -- 1306
		end -- 1306
		if joint.bodyA.current == nil then -- 1306
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1309
			return -- 1310
		end -- 1310
		if joint.bodyB.current == nil then -- 1310
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1313
			return -- 1314
		end -- 1314
		local ____joint_ref_47 = joint.ref -- 1316
		local ____self_45 = Dora.Joint -- 1316
		local ____self_45_revolute_46 = ____self_45.revolute -- 1316
		local ____joint_canCollide_44 = joint.canCollide -- 1317
		if ____joint_canCollide_44 == nil then -- 1317
			____joint_canCollide_44 = false -- 1317
		end -- 1317
		____joint_ref_47.current = ____self_45_revolute_46( -- 1316
			____self_45, -- 1316
			____joint_canCollide_44, -- 1317
			joint.bodyA.current, -- 1318
			joint.bodyB.current, -- 1319
			joint.worldPos, -- 1320
			joint.lowerAngle or 0, -- 1321
			joint.upperAngle or 0, -- 1322
			joint.maxMotorTorque or 0, -- 1323
			joint.motorSpeed or 0 -- 1324
		) -- 1324
	end, -- 1302
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1327
		local joint = enode.props -- 1328
		if joint.ref == nil then -- 1328
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1330
			return -- 1331
		end -- 1331
		if joint.bodyA.current == nil then -- 1331
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1334
			return -- 1335
		end -- 1335
		if joint.bodyB.current == nil then -- 1335
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1338
			return -- 1339
		end -- 1339
		local ____joint_ref_51 = joint.ref -- 1341
		local ____self_49 = Dora.Joint -- 1341
		local ____self_49_rope_50 = ____self_49.rope -- 1341
		local ____joint_canCollide_48 = joint.canCollide -- 1342
		if ____joint_canCollide_48 == nil then -- 1342
			____joint_canCollide_48 = false -- 1342
		end -- 1342
		____joint_ref_51.current = ____self_49_rope_50( -- 1341
			____self_49, -- 1341
			____joint_canCollide_48, -- 1342
			joint.bodyA.current, -- 1343
			joint.bodyB.current, -- 1344
			joint.anchorA or Dora.Vec2.zero, -- 1345
			joint.anchorB or Dora.Vec2.zero, -- 1346
			joint.maxLength or 0 -- 1347
		) -- 1347
	end, -- 1327
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1350
		local joint = enode.props -- 1351
		if joint.ref == nil then -- 1351
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1353
			return -- 1354
		end -- 1354
		if joint.bodyA.current == nil then -- 1354
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1357
			return -- 1358
		end -- 1358
		if joint.bodyB.current == nil then -- 1358
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1361
			return -- 1362
		end -- 1362
		local ____joint_ref_55 = joint.ref -- 1364
		local ____self_53 = Dora.Joint -- 1364
		local ____self_53_weld_54 = ____self_53.weld -- 1364
		local ____joint_canCollide_52 = joint.canCollide -- 1365
		if ____joint_canCollide_52 == nil then -- 1365
			____joint_canCollide_52 = false -- 1365
		end -- 1365
		____joint_ref_55.current = ____self_53_weld_54( -- 1364
			____self_53, -- 1364
			____joint_canCollide_52, -- 1365
			joint.bodyA.current, -- 1366
			joint.bodyB.current, -- 1367
			joint.worldPos, -- 1368
			joint.frequency or 0, -- 1369
			joint.damping or 0 -- 1370
		) -- 1370
	end, -- 1350
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1373
		local joint = enode.props -- 1374
		if joint.ref == nil then -- 1374
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1376
			return -- 1377
		end -- 1377
		if joint.bodyA.current == nil then -- 1377
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1380
			return -- 1381
		end -- 1381
		if joint.bodyB.current == nil then -- 1381
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1384
			return -- 1385
		end -- 1385
		local ____joint_ref_59 = joint.ref -- 1387
		local ____self_57 = Dora.Joint -- 1387
		local ____self_57_wheel_58 = ____self_57.wheel -- 1387
		local ____joint_canCollide_56 = joint.canCollide -- 1388
		if ____joint_canCollide_56 == nil then -- 1388
			____joint_canCollide_56 = false -- 1388
		end -- 1388
		____joint_ref_59.current = ____self_57_wheel_58( -- 1387
			____self_57, -- 1387
			____joint_canCollide_56, -- 1388
			joint.bodyA.current, -- 1389
			joint.bodyB.current, -- 1390
			joint.worldPos, -- 1391
			joint.axisAngle, -- 1392
			joint.maxMotorTorque or 0, -- 1393
			joint.motorSpeed or 0, -- 1394
			joint.frequency or 0, -- 1395
			joint.damping or 0.7 -- 1396
		) -- 1396
	end, -- 1373
	["custom-node"] = function(nodeStack, enode, _parent) -- 1399
		local node = getCustomNode(enode) -- 1400
		if node ~= nil then -- 1400
			addChild(nodeStack, node, enode) -- 1402
		end -- 1402
	end, -- 1399
	["custom-element"] = function() -- 1405
	end, -- 1405
	["align-node"] = function(nodeStack, enode, _parent) -- 1406
		addChild( -- 1407
			nodeStack, -- 1407
			getAlignNode(enode), -- 1407
			enode -- 1407
		) -- 1407
	end, -- 1406
	["effek-node"] = function(nodeStack, enode, _parent) -- 1409
		addChild( -- 1410
			nodeStack, -- 1410
			getEffekNode(enode), -- 1410
			enode -- 1410
		) -- 1410
	end, -- 1409
	effek = function(nodeStack, enode, parent) -- 1412
		if #nodeStack > 0 then -- 1412
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1414
			if node then -- 1414
				local effek = enode.props -- 1416
				local handle = node:play( -- 1417
					effek.file, -- 1417
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1417
					effek.z or 0 -- 1417
				) -- 1417
				if handle >= 0 then -- 1417
					if effek.ref then -- 1417
						effek.ref.current = handle -- 1420
					end -- 1420
					if effek.onEnd then -- 1420
						local onEnd = effek.onEnd -- 1420
						node:slot( -- 1424
							"EffekEnd", -- 1424
							function(h) -- 1424
								if handle == h then -- 1424
									onEnd(nil) -- 1426
								end -- 1426
							end -- 1424
						) -- 1424
					end -- 1424
				end -- 1424
			else -- 1424
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1432
			end -- 1432
		end -- 1432
	end, -- 1412
	["tile-node"] = function(nodeStack, enode, parent) -- 1436
		local cnode = getTileNode(enode) -- 1437
		if cnode ~= nil then -- 1437
			addChild(nodeStack, cnode, enode) -- 1439
		end -- 1439
	end -- 1436
} -- 1436
function ____exports.useRef(item) -- 1484
	local ____item_60 = item -- 1485
	if ____item_60 == nil then -- 1485
		____item_60 = nil -- 1485
	end -- 1485
	return {current = ____item_60} -- 1485
end -- 1484
local function getPreload(preloadList, node) -- 1488
	if type(node) ~= "table" then -- 1488
		return -- 1490
	end -- 1490
	local enode = node -- 1492
	if enode.type == nil then -- 1492
		local list = node -- 1494
		if #list > 0 then -- 1494
			for i = 1, #list do -- 1494
				getPreload(preloadList, list[i]) -- 1497
			end -- 1497
		end -- 1497
	else -- 1497
		repeat -- 1497
			local ____switch330 = enode.type -- 1497
			local sprite, playable, frame, model, spine, dragonBone, label -- 1497
			local ____cond330 = ____switch330 == "sprite" -- 1497
			if ____cond330 then -- 1497
				sprite = enode.props -- 1503
				if sprite.file then -- 1503
					preloadList[#preloadList + 1] = sprite.file -- 1505
				end -- 1505
				break -- 1507
			end -- 1507
			____cond330 = ____cond330 or ____switch330 == "playable" -- 1507
			if ____cond330 then -- 1507
				playable = enode.props -- 1509
				preloadList[#preloadList + 1] = playable.file -- 1510
				break -- 1511
			end -- 1511
			____cond330 = ____cond330 or ____switch330 == "frame" -- 1511
			if ____cond330 then -- 1511
				frame = enode.props -- 1513
				preloadList[#preloadList + 1] = frame.file -- 1514
				break -- 1515
			end -- 1515
			____cond330 = ____cond330 or ____switch330 == "model" -- 1515
			if ____cond330 then -- 1515
				model = enode.props -- 1517
				preloadList[#preloadList + 1] = "model:" .. model.file -- 1518
				break -- 1519
			end -- 1519
			____cond330 = ____cond330 or ____switch330 == "spine" -- 1519
			if ____cond330 then -- 1519
				spine = enode.props -- 1521
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1522
				break -- 1523
			end -- 1523
			____cond330 = ____cond330 or ____switch330 == "dragon-bone" -- 1523
			if ____cond330 then -- 1523
				dragonBone = enode.props -- 1525
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1526
				break -- 1527
			end -- 1527
			____cond330 = ____cond330 or ____switch330 == "label" -- 1527
			if ____cond330 then -- 1527
				label = enode.props -- 1529
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1530
				break -- 1531
			end -- 1531
		until true -- 1531
	end -- 1531
	getPreload(preloadList, enode.children) -- 1534
end -- 1488
function ____exports.preloadAsync(enode, handler) -- 1537
	local preloadList = {} -- 1538
	getPreload(preloadList, enode) -- 1539
	Dora.Cache:loadAsync(preloadList, handler) -- 1540
end -- 1537
function ____exports.toAction(enode) -- 1543
	local actionDef = ____exports.useRef() -- 1544
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 1545
	if not actionDef.current then -- 1545
		error("failed to create action") -- 1546
	end -- 1546
	return actionDef.current -- 1547
end -- 1543
return ____exports -- 1543