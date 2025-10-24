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
function visitNode(nodeStack, node, parent) -- 1368
	if type(node) ~= "table" then -- 1368
		return -- 1370
	end -- 1370
	local enode = node -- 1372
	if enode.type == nil then -- 1372
		local list = node -- 1374
		if #list > 0 then -- 1374
			for i = 1, #list do -- 1374
				local stack = {} -- 1377
				visitNode(stack, list[i], parent) -- 1378
				for i = 1, #stack do -- 1378
					nodeStack[#nodeStack + 1] = stack[i] -- 1380
				end -- 1380
			end -- 1380
		end -- 1380
	else -- 1380
		local handler = elementMap[enode.type] -- 1385
		if handler ~= nil then -- 1385
			handler(nodeStack, enode, parent) -- 1387
		else -- 1387
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1389
		end -- 1389
	end -- 1389
end -- 1389
function ____exports.toNode(enode) -- 1394
	local nodeStack = {} -- 1395
	visitNode(nodeStack, enode) -- 1396
	if #nodeStack == 1 then -- 1396
		return nodeStack[1] -- 1398
	elseif #nodeStack > 1 then -- 1398
		local node = Dora.Node() -- 1400
		for i = 1, #nodeStack do -- 1400
			node:addChild(nodeStack[i]) -- 1402
		end -- 1402
		return node -- 1404
	end -- 1404
	return nil -- 1406
end -- 1394
____exports.React = {} -- 1394
local React = ____exports.React -- 1394
do -- 1394
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
do -- 392
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 394
		repeat -- 394
			local ____switch83 = k -- 394
			local ____cond83 = ____switch83 == "file" -- 394
			if ____cond83 then -- 394
				return true -- 396
			end -- 396
			____cond83 = ____cond83 or ____switch83 == "textureRect" -- 396
			if ____cond83 then -- 396
				cnode.textureRect = v -- 397
				return true -- 397
			end -- 397
			____cond83 = ____cond83 or ____switch83 == "depthWrite" -- 397
			if ____cond83 then -- 397
				cnode.depthWrite = v -- 398
				return true -- 398
			end -- 398
			____cond83 = ____cond83 or ____switch83 == "blendFunc" -- 398
			if ____cond83 then -- 398
				cnode.blendFunc = v -- 399
				return true -- 399
			end -- 399
			____cond83 = ____cond83 or ____switch83 == "effect" -- 399
			if ____cond83 then -- 399
				cnode.effect = v -- 400
				return true -- 400
			end -- 400
			____cond83 = ____cond83 or ____switch83 == "alphaRef" -- 400
			if ____cond83 then -- 400
				cnode.alphaRef = v -- 401
				return true -- 401
			end -- 401
			____cond83 = ____cond83 or ____switch83 == "uwrap" -- 401
			if ____cond83 then -- 401
				cnode.uwrap = v -- 402
				return true -- 402
			end -- 402
			____cond83 = ____cond83 or ____switch83 == "vwrap" -- 402
			if ____cond83 then -- 402
				cnode.vwrap = v -- 403
				return true -- 403
			end -- 403
			____cond83 = ____cond83 or ____switch83 == "filter" -- 403
			if ____cond83 then -- 403
				cnode.filter = v -- 404
				return true -- 404
			end -- 404
		until true -- 404
		return false -- 406
	end -- 394
	getSprite = function(enode) -- 408
		local sp = enode.props -- 409
		if sp.file then -- 409
			local node = Dora.Sprite(sp.file) -- 411
			if node ~= nil then -- 411
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 413
				return cnode -- 414
			end -- 414
		else -- 414
			local node = Dora.Sprite() -- 417
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 418
			return cnode -- 419
		end -- 419
		return nil -- 421
	end -- 408
end -- 408
local getLabel -- 425
do -- 425
	local function handleLabelAttribute(cnode, _enode, k, v) -- 427
		repeat -- 427
			local ____switch90 = k -- 427
			local ____cond90 = ____switch90 == "fontName" or ____switch90 == "fontSize" or ____switch90 == "text" or ____switch90 == "smoothLower" or ____switch90 == "smoothUpper" -- 427
			if ____cond90 then -- 427
				return true -- 429
			end -- 429
			____cond90 = ____cond90 or ____switch90 == "alphaRef" -- 429
			if ____cond90 then -- 429
				cnode.alphaRef = v -- 430
				return true -- 430
			end -- 430
			____cond90 = ____cond90 or ____switch90 == "textWidth" -- 430
			if ____cond90 then -- 430
				cnode.textWidth = v -- 431
				return true -- 431
			end -- 431
			____cond90 = ____cond90 or ____switch90 == "lineGap" -- 431
			if ____cond90 then -- 431
				cnode.lineGap = v -- 432
				return true -- 432
			end -- 432
			____cond90 = ____cond90 or ____switch90 == "spacing" -- 432
			if ____cond90 then -- 432
				cnode.spacing = v -- 433
				return true -- 433
			end -- 433
			____cond90 = ____cond90 or ____switch90 == "outlineColor" -- 433
			if ____cond90 then -- 433
				cnode.outlineColor = Dora.Color(v) -- 434
				return true -- 434
			end -- 434
			____cond90 = ____cond90 or ____switch90 == "outlineWidth" -- 434
			if ____cond90 then -- 434
				cnode.outlineWidth = v -- 435
				return true -- 435
			end -- 435
			____cond90 = ____cond90 or ____switch90 == "blendFunc" -- 435
			if ____cond90 then -- 435
				cnode.blendFunc = v -- 436
				return true -- 436
			end -- 436
			____cond90 = ____cond90 or ____switch90 == "depthWrite" -- 436
			if ____cond90 then -- 436
				cnode.depthWrite = v -- 437
				return true -- 437
			end -- 437
			____cond90 = ____cond90 or ____switch90 == "batched" -- 437
			if ____cond90 then -- 437
				cnode.batched = v -- 438
				return true -- 438
			end -- 438
			____cond90 = ____cond90 or ____switch90 == "effect" -- 438
			if ____cond90 then -- 438
				cnode.effect = v -- 439
				return true -- 439
			end -- 439
			____cond90 = ____cond90 or ____switch90 == "alignment" -- 439
			if ____cond90 then -- 439
				cnode.alignment = v -- 440
				return true -- 440
			end -- 440
		until true -- 440
		return false -- 442
	end -- 427
	getLabel = function(enode) -- 444
		local label = enode.props -- 445
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 446
		if node ~= nil then -- 446
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 446
				local ____node_smooth_8 = node.smooth -- 449
				local x = ____node_smooth_8.x -- 449
				local y = ____node_smooth_8.y -- 449
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 450
			end -- 450
			local cnode = getNode(enode, node, handleLabelAttribute) -- 452
			local ____enode_9 = enode -- 453
			local children = ____enode_9.children -- 453
			local text = label.text or "" -- 454
			for i = 1, #children do -- 454
				local child = children[i] -- 456
				if type(child) ~= "table" then -- 456
					text = text .. tostring(child) -- 458
				end -- 458
			end -- 458
			node.text = text -- 461
			return cnode -- 462
		end -- 462
		return nil -- 464
	end -- 444
end -- 444
local getLine -- 468
do -- 468
	local function handleLineAttribute(cnode, enode, k, v) -- 470
		local line = enode.props -- 471
		repeat -- 471
			local ____switch98 = k -- 471
			local ____cond98 = ____switch98 == "verts" -- 471
			if ____cond98 then -- 471
				cnode:set( -- 473
					v, -- 473
					Dora.Color(line.lineColor or 4294967295) -- 473
				) -- 473
				return true -- 473
			end -- 473
			____cond98 = ____cond98 or ____switch98 == "depthWrite" -- 473
			if ____cond98 then -- 473
				cnode.depthWrite = v -- 474
				return true -- 474
			end -- 474
			____cond98 = ____cond98 or ____switch98 == "blendFunc" -- 474
			if ____cond98 then -- 474
				cnode.blendFunc = v -- 475
				return true -- 475
			end -- 475
		until true -- 475
		return false -- 477
	end -- 470
	getLine = function(enode) -- 479
		local node = Dora.Line() -- 480
		local cnode = getNode(enode, node, handleLineAttribute) -- 481
		return cnode -- 482
	end -- 479
end -- 479
local getParticle -- 486
do -- 486
	local function handleParticleAttribute(cnode, _enode, k, v) -- 488
		repeat -- 488
			local ____switch102 = k -- 488
			local ____cond102 = ____switch102 == "file" -- 488
			if ____cond102 then -- 488
				return true -- 490
			end -- 490
			____cond102 = ____cond102 or ____switch102 == "emit" -- 490
			if ____cond102 then -- 490
				if v then -- 490
					cnode:start() -- 491
				end -- 491
				return true -- 491
			end -- 491
			____cond102 = ____cond102 or ____switch102 == "onFinished" -- 491
			if ____cond102 then -- 491
				cnode:slot("Finished", v) -- 492
				return true -- 492
			end -- 492
		until true -- 492
		return false -- 494
	end -- 488
	getParticle = function(enode) -- 496
		local particle = enode.props -- 497
		local node = Dora.Particle(particle.file) -- 498
		if node ~= nil then -- 498
			local cnode = getNode(enode, node, handleParticleAttribute) -- 500
			return cnode -- 501
		end -- 501
		return nil -- 503
	end -- 496
end -- 496
local getMenu -- 507
do -- 507
	local function handleMenuAttribute(cnode, _enode, k, v) -- 509
		repeat -- 509
			local ____switch108 = k -- 509
			local ____cond108 = ____switch108 == "enabled" -- 509
			if ____cond108 then -- 509
				cnode.enabled = v -- 511
				return true -- 511
			end -- 511
		until true -- 511
		return false -- 513
	end -- 509
	getMenu = function(enode) -- 515
		local node = Dora.Menu() -- 516
		local cnode = getNode(enode, node, handleMenuAttribute) -- 517
		return cnode -- 518
	end -- 515
end -- 515
local function getPhysicsWorld(enode) -- 522
	local node = Dora.PhysicsWorld() -- 523
	local cnode = getNode(enode, node) -- 524
	return cnode -- 525
end -- 522
local getBody -- 528
do -- 528
	local function handleBodyAttribute(cnode, _enode, k, v) -- 530
		repeat -- 530
			local ____switch113 = k -- 530
			local ____cond113 = ____switch113 == "type" or ____switch113 == "linearAcceleration" or ____switch113 == "fixedRotation" or ____switch113 == "bullet" or ____switch113 == "world" -- 530
			if ____cond113 then -- 530
				return true -- 537
			end -- 537
			____cond113 = ____cond113 or ____switch113 == "velocityX" -- 537
			if ____cond113 then -- 537
				cnode.velocityX = v -- 538
				return true -- 538
			end -- 538
			____cond113 = ____cond113 or ____switch113 == "velocityY" -- 538
			if ____cond113 then -- 538
				cnode.velocityY = v -- 539
				return true -- 539
			end -- 539
			____cond113 = ____cond113 or ____switch113 == "angularRate" -- 539
			if ____cond113 then -- 539
				cnode.angularRate = v -- 540
				return true -- 540
			end -- 540
			____cond113 = ____cond113 or ____switch113 == "group" -- 540
			if ____cond113 then -- 540
				cnode.group = v -- 541
				return true -- 541
			end -- 541
			____cond113 = ____cond113 or ____switch113 == "linearDamping" -- 541
			if ____cond113 then -- 541
				cnode.linearDamping = v -- 542
				return true -- 542
			end -- 542
			____cond113 = ____cond113 or ____switch113 == "angularDamping" -- 542
			if ____cond113 then -- 542
				cnode.angularDamping = v -- 543
				return true -- 543
			end -- 543
			____cond113 = ____cond113 or ____switch113 == "owner" -- 543
			if ____cond113 then -- 543
				cnode.owner = v -- 544
				return true -- 544
			end -- 544
			____cond113 = ____cond113 or ____switch113 == "receivingContact" -- 544
			if ____cond113 then -- 544
				cnode.receivingContact = v -- 545
				return true -- 545
			end -- 545
			____cond113 = ____cond113 or ____switch113 == "onBodyEnter" -- 545
			if ____cond113 then -- 545
				cnode:slot("BodyEnter", v) -- 546
				return true -- 546
			end -- 546
			____cond113 = ____cond113 or ____switch113 == "onBodyLeave" -- 546
			if ____cond113 then -- 546
				cnode:slot("BodyLeave", v) -- 547
				return true -- 547
			end -- 547
			____cond113 = ____cond113 or ____switch113 == "onContactStart" -- 547
			if ____cond113 then -- 547
				cnode:slot("ContactStart", v) -- 548
				return true -- 548
			end -- 548
			____cond113 = ____cond113 or ____switch113 == "onContactEnd" -- 548
			if ____cond113 then -- 548
				cnode:slot("ContactEnd", v) -- 549
				return true -- 549
			end -- 549
			____cond113 = ____cond113 or ____switch113 == "onContactFilter" -- 549
			if ____cond113 then -- 549
				cnode:onContactFilter(v) -- 550
				return true -- 550
			end -- 550
		until true -- 550
		return false -- 552
	end -- 530
	getBody = function(enode, world) -- 554
		local def = enode.props -- 555
		local bodyDef = Dora.BodyDef() -- 556
		bodyDef.type = def.type -- 557
		if def.angle ~= nil then -- 557
			bodyDef.angle = def.angle -- 558
		end -- 558
		if def.angularDamping ~= nil then -- 558
			bodyDef.angularDamping = def.angularDamping -- 559
		end -- 559
		if def.bullet ~= nil then -- 559
			bodyDef.bullet = def.bullet -- 560
		end -- 560
		if def.fixedRotation ~= nil then -- 560
			bodyDef.fixedRotation = def.fixedRotation -- 561
		end -- 561
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 562
		if def.linearDamping ~= nil then -- 562
			bodyDef.linearDamping = def.linearDamping -- 563
		end -- 563
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 564
		local extraSensors = nil -- 565
		for i = 1, #enode.children do -- 565
			do -- 565
				local child = enode.children[i] -- 567
				if type(child) ~= "table" then -- 567
					goto __continue120 -- 569
				end -- 569
				repeat -- 569
					local ____switch122 = child.type -- 569
					local ____cond122 = ____switch122 == "rect-fixture" -- 569
					if ____cond122 then -- 569
						do -- 569
							local shape = child.props -- 573
							if shape.sensorTag ~= nil then -- 573
								bodyDef:attachPolygonSensor( -- 575
									shape.sensorTag, -- 576
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 577
									shape.width, -- 578
									shape.height, -- 578
									shape.angle or 0 -- 579
								) -- 579
							else -- 579
								bodyDef:attachPolygon( -- 582
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 583
									shape.width, -- 584
									shape.height, -- 584
									shape.angle or 0, -- 585
									shape.density or 1, -- 586
									shape.friction or 0.4, -- 587
									shape.restitution or 0 -- 588
								) -- 588
							end -- 588
							break -- 591
						end -- 591
					end -- 591
					____cond122 = ____cond122 or ____switch122 == "polygon-fixture" -- 591
					if ____cond122 then -- 591
						do -- 591
							local shape = child.props -- 594
							if shape.sensorTag ~= nil then -- 594
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 596
							else -- 596
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 601
							end -- 601
							break -- 608
						end -- 608
					end -- 608
					____cond122 = ____cond122 or ____switch122 == "multi-fixture" -- 608
					if ____cond122 then -- 608
						do -- 608
							local shape = child.props -- 611
							if shape.sensorTag ~= nil then -- 611
								if extraSensors == nil then -- 611
									extraSensors = {} -- 613
								end -- 613
								extraSensors[#extraSensors + 1] = { -- 614
									shape.sensorTag, -- 614
									Dora.BodyDef:multi(shape.verts) -- 614
								} -- 614
							else -- 614
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 616
							end -- 616
							break -- 623
						end -- 623
					end -- 623
					____cond122 = ____cond122 or ____switch122 == "disk-fixture" -- 623
					if ____cond122 then -- 623
						do -- 623
							local shape = child.props -- 626
							if shape.sensorTag ~= nil then -- 626
								bodyDef:attachDiskSensor( -- 628
									shape.sensorTag, -- 629
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 630
									shape.radius -- 631
								) -- 631
							else -- 631
								bodyDef:attachDisk( -- 634
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 635
									shape.radius, -- 636
									shape.density or 1, -- 637
									shape.friction or 0.4, -- 638
									shape.restitution or 0 -- 639
								) -- 639
							end -- 639
							break -- 642
						end -- 642
					end -- 642
					____cond122 = ____cond122 or ____switch122 == "chain-fixture" -- 642
					if ____cond122 then -- 642
						do -- 642
							local shape = child.props -- 645
							if shape.sensorTag ~= nil then -- 645
								if extraSensors == nil then -- 645
									extraSensors = {} -- 647
								end -- 647
								extraSensors[#extraSensors + 1] = { -- 648
									shape.sensorTag, -- 648
									Dora.BodyDef:chain(shape.verts) -- 648
								} -- 648
							else -- 648
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 650
							end -- 650
							break -- 656
						end -- 656
					end -- 656
				until true -- 656
			end -- 656
			::__continue120:: -- 656
		end -- 656
		local body = Dora.Body(bodyDef, world) -- 660
		if extraSensors ~= nil then -- 660
			for i = 1, #extraSensors do -- 660
				local tag, def = table.unpack(extraSensors[i], 1, 2) -- 663
				body:attachSensor(tag, def) -- 664
			end -- 664
		end -- 664
		local cnode = getNode(enode, body, handleBodyAttribute) -- 667
		if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 667
			body.receivingContact = true -- 672
		end -- 672
		return cnode -- 674
	end -- 554
end -- 554
local getCustomNode -- 678
do -- 678
	local function handleCustomNode(_cnode, _enode, k, _v) -- 680
		repeat -- 680
			local ____switch143 = k -- 680
			local ____cond143 = ____switch143 == "onCreate" -- 680
			if ____cond143 then -- 680
				return true -- 682
			end -- 682
		until true -- 682
		return false -- 684
	end -- 680
	getCustomNode = function(enode) -- 686
		local custom = enode.props -- 687
		local node = custom.onCreate() -- 688
		if node then -- 688
			local cnode = getNode(enode, node, handleCustomNode) -- 690
			return cnode -- 691
		end -- 691
		return nil -- 693
	end -- 686
end -- 686
local getAlignNode -- 697
do -- 697
	local function handleAlignNode(_cnode, _enode, k, _v) -- 699
		repeat -- 699
			local ____switch148 = k -- 699
			local ____cond148 = ____switch148 == "windowRoot" -- 699
			if ____cond148 then -- 699
				return true -- 701
			end -- 701
			____cond148 = ____cond148 or ____switch148 == "style" -- 701
			if ____cond148 then -- 701
				return true -- 702
			end -- 702
			____cond148 = ____cond148 or ____switch148 == "onLayout" -- 702
			if ____cond148 then -- 702
				return true -- 703
			end -- 703
		until true -- 703
		return false -- 705
	end -- 699
	getAlignNode = function(enode) -- 707
		local alignNode = enode.props -- 708
		local node = Dora.AlignNode(alignNode.windowRoot) -- 709
		if alignNode.style then -- 709
			local items = {} -- 711
			for k, v in pairs(alignNode.style) do -- 712
				local name = string.gsub(k, "%u", "-%1") -- 713
				name = string.lower(name) -- 714
				repeat -- 714
					local ____switch152 = k -- 714
					local ____cond152 = ____switch152 == "margin" or ____switch152 == "padding" or ____switch152 == "border" or ____switch152 == "gap" -- 714
					if ____cond152 then -- 714
						do -- 714
							if type(v) == "table" then -- 714
								local valueStr = table.concat( -- 719
									__TS__ArrayMap( -- 719
										v, -- 719
										function(____, item) return tostring(item) end -- 719
									), -- 719
									"," -- 719
								) -- 719
								items[#items + 1] = (name .. ":") .. valueStr -- 720
							else -- 720
								items[#items + 1] = (name .. ":") .. tostring(v) -- 722
							end -- 722
							break -- 724
						end -- 724
					end -- 724
					do -- 724
						items[#items + 1] = (name .. ":") .. tostring(v) -- 727
						break -- 728
					end -- 728
				until true -- 728
			end -- 728
			local styleStr = table.concat(items, ";") -- 731
			node:css(styleStr) -- 732
		end -- 732
		if alignNode.onLayout then -- 732
			node:slot("AlignLayout", alignNode.onLayout) -- 735
		end -- 735
		local cnode = getNode(enode, node, handleAlignNode) -- 737
		return cnode -- 738
	end -- 707
end -- 707
local function getEffekNode(enode) -- 742
	return getNode( -- 743
		enode, -- 743
		Dora.EffekNode() -- 743
	) -- 743
end -- 742
local getTileNode -- 746
do -- 746
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 748
		repeat -- 748
			local ____switch161 = k -- 748
			local ____cond161 = ____switch161 == "file" or ____switch161 == "layers" -- 748
			if ____cond161 then -- 748
				return true -- 750
			end -- 750
			____cond161 = ____cond161 or ____switch161 == "depthWrite" -- 750
			if ____cond161 then -- 750
				cnode.depthWrite = v -- 751
				return true -- 751
			end -- 751
			____cond161 = ____cond161 or ____switch161 == "blendFunc" -- 751
			if ____cond161 then -- 751
				cnode.blendFunc = v -- 752
				return true -- 752
			end -- 752
			____cond161 = ____cond161 or ____switch161 == "effect" -- 752
			if ____cond161 then -- 752
				cnode.effect = v -- 753
				return true -- 753
			end -- 753
			____cond161 = ____cond161 or ____switch161 == "filter" -- 753
			if ____cond161 then -- 753
				cnode.filter = v -- 754
				return true -- 754
			end -- 754
		until true -- 754
		return false -- 756
	end -- 748
	getTileNode = function(enode) -- 758
		local tn = enode.props -- 759
		local ____tn_layers_10 -- 760
		if tn.layers then -- 760
			____tn_layers_10 = Dora.TileNode(tn.file, tn.layers) -- 760
		else -- 760
			____tn_layers_10 = Dora.TileNode(tn.file) -- 760
		end -- 760
		local node = ____tn_layers_10 -- 760
		if node ~= nil then -- 760
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 762
			return cnode -- 763
		end -- 763
		return nil -- 765
	end -- 758
end -- 758
local function addChild(nodeStack, cnode, enode) -- 769
	if #nodeStack > 0 then -- 769
		local last = nodeStack[#nodeStack] -- 771
		last:addChild(cnode) -- 772
	end -- 772
	nodeStack[#nodeStack + 1] = cnode -- 774
	local ____enode_11 = enode -- 775
	local children = ____enode_11.children -- 775
	for i = 1, #children do -- 775
		visitNode(nodeStack, children[i], enode) -- 777
	end -- 777
	if #nodeStack > 1 then -- 777
		table.remove(nodeStack) -- 780
	end -- 780
end -- 769
local function drawNodeCheck(_nodeStack, enode, parent) -- 788
	if parent == nil or parent.type ~= "draw-node" then -- 788
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 790
	end -- 790
end -- 788
local function visitAction(actionStack, enode) -- 794
	local createAction = actionMap[enode.type] -- 795
	if createAction ~= nil then -- 795
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 797
		return -- 798
	end -- 798
	repeat -- 798
		local ____switch172 = enode.type -- 798
		local ____cond172 = ____switch172 == "delay" -- 798
		if ____cond172 then -- 798
			do -- 798
				local item = enode.props -- 802
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 803
				break -- 804
			end -- 804
		end -- 804
		____cond172 = ____cond172 or ____switch172 == "event" -- 804
		if ____cond172 then -- 804
			do -- 804
				local item = enode.props -- 807
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 808
				break -- 809
			end -- 809
		end -- 809
		____cond172 = ____cond172 or ____switch172 == "hide" -- 809
		if ____cond172 then -- 809
			do -- 809
				actionStack[#actionStack + 1] = Dora.Hide() -- 812
				break -- 813
			end -- 813
		end -- 813
		____cond172 = ____cond172 or ____switch172 == "show" -- 813
		if ____cond172 then -- 813
			do -- 813
				actionStack[#actionStack + 1] = Dora.Show() -- 816
				break -- 817
			end -- 817
		end -- 817
		____cond172 = ____cond172 or ____switch172 == "move" -- 817
		if ____cond172 then -- 817
			do -- 817
				local item = enode.props -- 820
				actionStack[#actionStack + 1] = Dora.Move( -- 821
					item.time, -- 821
					Dora.Vec2(item.startX, item.startY), -- 821
					Dora.Vec2(item.stopX, item.stopY), -- 821
					item.easing -- 821
				) -- 821
				break -- 822
			end -- 822
		end -- 822
		____cond172 = ____cond172 or ____switch172 == "frame" -- 822
		if ____cond172 then -- 822
			do -- 822
				local item = enode.props -- 825
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 826
				break -- 827
			end -- 827
		end -- 827
		____cond172 = ____cond172 or ____switch172 == "spawn" -- 827
		if ____cond172 then -- 827
			do -- 827
				local spawnStack = {} -- 830
				for i = 1, #enode.children do -- 830
					visitAction(spawnStack, enode.children[i]) -- 832
				end -- 832
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 834
				break -- 835
			end -- 835
		end -- 835
		____cond172 = ____cond172 or ____switch172 == "sequence" -- 835
		if ____cond172 then -- 835
			do -- 835
				local sequenceStack = {} -- 838
				for i = 1, #enode.children do -- 838
					visitAction(sequenceStack, enode.children[i]) -- 840
				end -- 840
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 842
				break -- 843
			end -- 843
		end -- 843
		do -- 843
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 846
			break -- 847
		end -- 847
	until true -- 847
end -- 794
local function actionCheck(nodeStack, enode, parent) -- 851
	local unsupported = false -- 852
	if parent == nil then -- 852
		unsupported = true -- 854
	else -- 854
		repeat -- 854
			local ____switch186 = parent.type -- 854
			local ____cond186 = ____switch186 == "action" or ____switch186 == "spawn" or ____switch186 == "sequence" -- 854
			if ____cond186 then -- 854
				break -- 857
			end -- 857
			do -- 857
				unsupported = true -- 858
				break -- 858
			end -- 858
		until true -- 858
	end -- 858
	if unsupported then -- 858
		if #nodeStack > 0 then -- 858
			local node = nodeStack[#nodeStack] -- 863
			local actionStack = {} -- 864
			visitAction(actionStack, enode) -- 865
			if #actionStack == 1 then -- 865
				node:runAction(actionStack[1]) -- 867
			end -- 867
		else -- 867
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 870
		end -- 870
	end -- 870
end -- 851
local function bodyCheck(_nodeStack, enode, parent) -- 875
	if parent == nil or parent.type ~= "body" then -- 875
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 877
	end -- 877
end -- 875
actionMap = { -- 881
	["anchor-x"] = Dora.AnchorX, -- 884
	["anchor-y"] = Dora.AnchorY, -- 885
	angle = Dora.Angle, -- 886
	["angle-x"] = Dora.AngleX, -- 887
	["angle-y"] = Dora.AngleY, -- 888
	width = Dora.Width, -- 889
	height = Dora.Height, -- 890
	opacity = Dora.Opacity, -- 891
	roll = Dora.Roll, -- 892
	scale = Dora.Scale, -- 893
	["scale-x"] = Dora.ScaleX, -- 894
	["scale-y"] = Dora.ScaleY, -- 895
	["skew-x"] = Dora.SkewX, -- 896
	["skew-y"] = Dora.SkewY, -- 897
	["move-x"] = Dora.X, -- 898
	["move-y"] = Dora.Y, -- 899
	["move-z"] = Dora.Z -- 900
} -- 900
elementMap = { -- 903
	node = function(nodeStack, enode, parent) -- 904
		addChild( -- 905
			nodeStack, -- 905
			getNode(enode), -- 905
			enode -- 905
		) -- 905
	end, -- 904
	["clip-node"] = function(nodeStack, enode, parent) -- 907
		addChild( -- 908
			nodeStack, -- 908
			getClipNode(enode), -- 908
			enode -- 908
		) -- 908
	end, -- 907
	playable = function(nodeStack, enode, parent) -- 910
		local cnode = getPlayable(enode) -- 911
		if cnode ~= nil then -- 911
			addChild(nodeStack, cnode, enode) -- 913
		end -- 913
	end, -- 910
	["dragon-bone"] = function(nodeStack, enode, parent) -- 916
		local cnode = getDragonBone(enode) -- 917
		if cnode ~= nil then -- 917
			addChild(nodeStack, cnode, enode) -- 919
		end -- 919
	end, -- 916
	spine = function(nodeStack, enode, parent) -- 922
		local cnode = getSpine(enode) -- 923
		if cnode ~= nil then -- 923
			addChild(nodeStack, cnode, enode) -- 925
		end -- 925
	end, -- 922
	model = function(nodeStack, enode, parent) -- 928
		local cnode = getModel(enode) -- 929
		if cnode ~= nil then -- 929
			addChild(nodeStack, cnode, enode) -- 931
		end -- 931
	end, -- 928
	["draw-node"] = function(nodeStack, enode, parent) -- 934
		addChild( -- 935
			nodeStack, -- 935
			getDrawNode(enode), -- 935
			enode -- 935
		) -- 935
	end, -- 934
	["dot-shape"] = drawNodeCheck, -- 937
	["segment-shape"] = drawNodeCheck, -- 938
	["rect-shape"] = drawNodeCheck, -- 939
	["polygon-shape"] = drawNodeCheck, -- 940
	["verts-shape"] = drawNodeCheck, -- 941
	grid = function(nodeStack, enode, parent) -- 942
		addChild( -- 943
			nodeStack, -- 943
			getGrid(enode), -- 943
			enode -- 943
		) -- 943
	end, -- 942
	sprite = function(nodeStack, enode, parent) -- 945
		local cnode = getSprite(enode) -- 946
		if cnode ~= nil then -- 946
			addChild(nodeStack, cnode, enode) -- 948
		end -- 948
	end, -- 945
	label = function(nodeStack, enode, parent) -- 951
		local cnode = getLabel(enode) -- 952
		if cnode ~= nil then -- 952
			addChild(nodeStack, cnode, enode) -- 954
		end -- 954
	end, -- 951
	line = function(nodeStack, enode, parent) -- 957
		addChild( -- 958
			nodeStack, -- 958
			getLine(enode), -- 958
			enode -- 958
		) -- 958
	end, -- 957
	particle = function(nodeStack, enode, parent) -- 960
		local cnode = getParticle(enode) -- 961
		if cnode ~= nil then -- 961
			addChild(nodeStack, cnode, enode) -- 963
		end -- 963
	end, -- 960
	menu = function(nodeStack, enode, parent) -- 966
		addChild( -- 967
			nodeStack, -- 967
			getMenu(enode), -- 967
			enode -- 967
		) -- 967
	end, -- 966
	action = function(_nodeStack, enode, parent) -- 969
		if #enode.children == 0 then -- 969
			Warn("<action> tag has no children") -- 971
			return -- 972
		end -- 972
		local action = enode.props -- 974
		if action.ref == nil then -- 974
			Warn("<action> tag has no ref") -- 976
			return -- 977
		end -- 977
		local actionStack = {} -- 979
		for i = 1, #enode.children do -- 979
			visitAction(actionStack, enode.children[i]) -- 981
		end -- 981
		if #actionStack == 1 then -- 981
			action.ref.current = actionStack[1] -- 984
		elseif #actionStack > 1 then -- 984
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 986
		end -- 986
	end, -- 969
	["anchor-x"] = actionCheck, -- 989
	["anchor-y"] = actionCheck, -- 990
	angle = actionCheck, -- 991
	["angle-x"] = actionCheck, -- 992
	["angle-y"] = actionCheck, -- 993
	delay = actionCheck, -- 994
	event = actionCheck, -- 995
	width = actionCheck, -- 996
	height = actionCheck, -- 997
	hide = actionCheck, -- 998
	show = actionCheck, -- 999
	move = actionCheck, -- 1000
	opacity = actionCheck, -- 1001
	roll = actionCheck, -- 1002
	scale = actionCheck, -- 1003
	["scale-x"] = actionCheck, -- 1004
	["scale-y"] = actionCheck, -- 1005
	["skew-x"] = actionCheck, -- 1006
	["skew-y"] = actionCheck, -- 1007
	["move-x"] = actionCheck, -- 1008
	["move-y"] = actionCheck, -- 1009
	["move-z"] = actionCheck, -- 1010
	frame = actionCheck, -- 1011
	spawn = actionCheck, -- 1012
	sequence = actionCheck, -- 1013
	loop = function(nodeStack, enode, _parent) -- 1014
		if #nodeStack > 0 then -- 1014
			local node = nodeStack[#nodeStack] -- 1016
			local actionStack = {} -- 1017
			for i = 1, #enode.children do -- 1017
				visitAction(actionStack, enode.children[i]) -- 1019
			end -- 1019
			if #actionStack == 1 then -- 1019
				node:runAction(actionStack[1], true) -- 1022
			else -- 1022
				local loop = enode.props -- 1024
				if loop.spawn then -- 1024
					node:runAction( -- 1026
						Dora.Spawn(table.unpack(actionStack)), -- 1026
						true -- 1026
					) -- 1026
				else -- 1026
					node:runAction( -- 1028
						Dora.Sequence(table.unpack(actionStack)), -- 1028
						true -- 1028
					) -- 1028
				end -- 1028
			end -- 1028
		else -- 1028
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1032
		end -- 1032
	end, -- 1014
	["physics-world"] = function(nodeStack, enode, _parent) -- 1035
		addChild( -- 1036
			nodeStack, -- 1036
			getPhysicsWorld(enode), -- 1036
			enode -- 1036
		) -- 1036
	end, -- 1035
	contact = function(nodeStack, enode, _parent) -- 1038
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1039
		if world ~= nil then -- 1039
			local contact = enode.props -- 1041
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1042
		else -- 1042
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1044
		end -- 1044
	end, -- 1038
	body = function(nodeStack, enode, _parent) -- 1047
		local def = enode.props -- 1048
		if def.world then -- 1048
			addChild( -- 1050
				nodeStack, -- 1050
				getBody(enode, def.world), -- 1050
				enode -- 1050
			) -- 1050
			return -- 1051
		end -- 1051
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1053
		if world ~= nil then -- 1053
			addChild( -- 1055
				nodeStack, -- 1055
				getBody(enode, world), -- 1055
				enode -- 1055
			) -- 1055
		else -- 1055
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1057
		end -- 1057
	end, -- 1047
	["rect-fixture"] = bodyCheck, -- 1060
	["polygon-fixture"] = bodyCheck, -- 1061
	["multi-fixture"] = bodyCheck, -- 1062
	["disk-fixture"] = bodyCheck, -- 1063
	["chain-fixture"] = bodyCheck, -- 1064
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1065
		local joint = enode.props -- 1066
		if joint.ref == nil then -- 1066
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1068
			return -- 1069
		end -- 1069
		if joint.bodyA.current == nil then -- 1069
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1072
			return -- 1073
		end -- 1073
		if joint.bodyB.current == nil then -- 1073
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1076
			return -- 1077
		end -- 1077
		local ____joint_ref_15 = joint.ref -- 1079
		local ____self_13 = Dora.Joint -- 1079
		local ____self_13_distance_14 = ____self_13.distance -- 1079
		local ____joint_canCollide_12 = joint.canCollide -- 1080
		if ____joint_canCollide_12 == nil then -- 1080
			____joint_canCollide_12 = false -- 1080
		end -- 1080
		____joint_ref_15.current = ____self_13_distance_14( -- 1079
			____self_13, -- 1079
			____joint_canCollide_12, -- 1080
			joint.bodyA.current, -- 1081
			joint.bodyB.current, -- 1082
			joint.anchorA or Dora.Vec2.zero, -- 1083
			joint.anchorB or Dora.Vec2.zero, -- 1084
			joint.frequency or 0, -- 1085
			joint.damping or 0 -- 1086
		) -- 1086
	end, -- 1065
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1088
		local joint = enode.props -- 1089
		if joint.ref == nil then -- 1089
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1091
			return -- 1092
		end -- 1092
		if joint.bodyA.current == nil then -- 1092
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1095
			return -- 1096
		end -- 1096
		if joint.bodyB.current == nil then -- 1096
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1099
			return -- 1100
		end -- 1100
		local ____joint_ref_19 = joint.ref -- 1102
		local ____self_17 = Dora.Joint -- 1102
		local ____self_17_friction_18 = ____self_17.friction -- 1102
		local ____joint_canCollide_16 = joint.canCollide -- 1103
		if ____joint_canCollide_16 == nil then -- 1103
			____joint_canCollide_16 = false -- 1103
		end -- 1103
		____joint_ref_19.current = ____self_17_friction_18( -- 1102
			____self_17, -- 1102
			____joint_canCollide_16, -- 1103
			joint.bodyA.current, -- 1104
			joint.bodyB.current, -- 1105
			joint.worldPos, -- 1106
			joint.maxForce, -- 1107
			joint.maxTorque -- 1108
		) -- 1108
	end, -- 1088
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1111
		local joint = enode.props -- 1112
		if joint.ref == nil then -- 1112
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1114
			return -- 1115
		end -- 1115
		if joint.jointA.current == nil then -- 1115
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1118
			return -- 1119
		end -- 1119
		if joint.jointB.current == nil then -- 1119
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1122
			return -- 1123
		end -- 1123
		local ____joint_ref_23 = joint.ref -- 1125
		local ____self_21 = Dora.Joint -- 1125
		local ____self_21_gear_22 = ____self_21.gear -- 1125
		local ____joint_canCollide_20 = joint.canCollide -- 1126
		if ____joint_canCollide_20 == nil then -- 1126
			____joint_canCollide_20 = false -- 1126
		end -- 1126
		____joint_ref_23.current = ____self_21_gear_22( -- 1125
			____self_21, -- 1125
			____joint_canCollide_20, -- 1126
			joint.jointA.current, -- 1127
			joint.jointB.current, -- 1128
			joint.ratio or 1 -- 1129
		) -- 1129
	end, -- 1111
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1132
		local joint = enode.props -- 1133
		if joint.ref == nil then -- 1133
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1135
			return -- 1136
		end -- 1136
		if joint.bodyA.current == nil then -- 1136
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1139
			return -- 1140
		end -- 1140
		if joint.bodyB.current == nil then -- 1140
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1143
			return -- 1144
		end -- 1144
		local ____joint_ref_27 = joint.ref -- 1146
		local ____self_25 = Dora.Joint -- 1146
		local ____self_25_spring_26 = ____self_25.spring -- 1146
		local ____joint_canCollide_24 = joint.canCollide -- 1147
		if ____joint_canCollide_24 == nil then -- 1147
			____joint_canCollide_24 = false -- 1147
		end -- 1147
		____joint_ref_27.current = ____self_25_spring_26( -- 1146
			____self_25, -- 1146
			____joint_canCollide_24, -- 1147
			joint.bodyA.current, -- 1148
			joint.bodyB.current, -- 1149
			joint.linearOffset, -- 1150
			joint.angularOffset, -- 1151
			joint.maxForce, -- 1152
			joint.maxTorque, -- 1153
			joint.correctionFactor or 1 -- 1154
		) -- 1154
	end, -- 1132
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1157
		local joint = enode.props -- 1158
		if joint.ref == nil then -- 1158
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1160
			return -- 1161
		end -- 1161
		if joint.body.current == nil then -- 1161
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1164
			return -- 1165
		end -- 1165
		local ____joint_ref_31 = joint.ref -- 1167
		local ____self_29 = Dora.Joint -- 1167
		local ____self_29_move_30 = ____self_29.move -- 1167
		local ____joint_canCollide_28 = joint.canCollide -- 1168
		if ____joint_canCollide_28 == nil then -- 1168
			____joint_canCollide_28 = false -- 1168
		end -- 1168
		____joint_ref_31.current = ____self_29_move_30( -- 1167
			____self_29, -- 1167
			____joint_canCollide_28, -- 1168
			joint.body.current, -- 1169
			joint.targetPos, -- 1170
			joint.maxForce, -- 1171
			joint.frequency, -- 1172
			joint.damping or 0.7 -- 1173
		) -- 1173
	end, -- 1157
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1176
		local joint = enode.props -- 1177
		if joint.ref == nil then -- 1177
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1179
			return -- 1180
		end -- 1180
		if joint.bodyA.current == nil then -- 1180
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1183
			return -- 1184
		end -- 1184
		if joint.bodyB.current == nil then -- 1184
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1187
			return -- 1188
		end -- 1188
		local ____joint_ref_35 = joint.ref -- 1190
		local ____self_33 = Dora.Joint -- 1190
		local ____self_33_prismatic_34 = ____self_33.prismatic -- 1190
		local ____joint_canCollide_32 = joint.canCollide -- 1191
		if ____joint_canCollide_32 == nil then -- 1191
			____joint_canCollide_32 = false -- 1191
		end -- 1191
		____joint_ref_35.current = ____self_33_prismatic_34( -- 1190
			____self_33, -- 1190
			____joint_canCollide_32, -- 1191
			joint.bodyA.current, -- 1192
			joint.bodyB.current, -- 1193
			joint.worldPos, -- 1194
			joint.axisAngle, -- 1195
			joint.lowerTranslation or 0, -- 1196
			joint.upperTranslation or 0, -- 1197
			joint.maxMotorForce or 0, -- 1198
			joint.motorSpeed or 0 -- 1199
		) -- 1199
	end, -- 1176
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1202
		local joint = enode.props -- 1203
		if joint.ref == nil then -- 1203
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1205
			return -- 1206
		end -- 1206
		if joint.bodyA.current == nil then -- 1206
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1209
			return -- 1210
		end -- 1210
		if joint.bodyB.current == nil then -- 1210
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1213
			return -- 1214
		end -- 1214
		local ____joint_ref_39 = joint.ref -- 1216
		local ____self_37 = Dora.Joint -- 1216
		local ____self_37_pulley_38 = ____self_37.pulley -- 1216
		local ____joint_canCollide_36 = joint.canCollide -- 1217
		if ____joint_canCollide_36 == nil then -- 1217
			____joint_canCollide_36 = false -- 1217
		end -- 1217
		____joint_ref_39.current = ____self_37_pulley_38( -- 1216
			____self_37, -- 1216
			____joint_canCollide_36, -- 1217
			joint.bodyA.current, -- 1218
			joint.bodyB.current, -- 1219
			joint.anchorA or Dora.Vec2.zero, -- 1220
			joint.anchorB or Dora.Vec2.zero, -- 1221
			joint.groundAnchorA, -- 1222
			joint.groundAnchorB, -- 1223
			joint.ratio or 1 -- 1224
		) -- 1224
	end, -- 1202
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1227
		local joint = enode.props -- 1228
		if joint.ref == nil then -- 1228
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1230
			return -- 1231
		end -- 1231
		if joint.bodyA.current == nil then -- 1231
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1234
			return -- 1235
		end -- 1235
		if joint.bodyB.current == nil then -- 1235
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1238
			return -- 1239
		end -- 1239
		local ____joint_ref_43 = joint.ref -- 1241
		local ____self_41 = Dora.Joint -- 1241
		local ____self_41_revolute_42 = ____self_41.revolute -- 1241
		local ____joint_canCollide_40 = joint.canCollide -- 1242
		if ____joint_canCollide_40 == nil then -- 1242
			____joint_canCollide_40 = false -- 1242
		end -- 1242
		____joint_ref_43.current = ____self_41_revolute_42( -- 1241
			____self_41, -- 1241
			____joint_canCollide_40, -- 1242
			joint.bodyA.current, -- 1243
			joint.bodyB.current, -- 1244
			joint.worldPos, -- 1245
			joint.lowerAngle or 0, -- 1246
			joint.upperAngle or 0, -- 1247
			joint.maxMotorTorque or 0, -- 1248
			joint.motorSpeed or 0 -- 1249
		) -- 1249
	end, -- 1227
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1252
		local joint = enode.props -- 1253
		if joint.ref == nil then -- 1253
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1255
			return -- 1256
		end -- 1256
		if joint.bodyA.current == nil then -- 1256
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1259
			return -- 1260
		end -- 1260
		if joint.bodyB.current == nil then -- 1260
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1263
			return -- 1264
		end -- 1264
		local ____joint_ref_47 = joint.ref -- 1266
		local ____self_45 = Dora.Joint -- 1266
		local ____self_45_rope_46 = ____self_45.rope -- 1266
		local ____joint_canCollide_44 = joint.canCollide -- 1267
		if ____joint_canCollide_44 == nil then -- 1267
			____joint_canCollide_44 = false -- 1267
		end -- 1267
		____joint_ref_47.current = ____self_45_rope_46( -- 1266
			____self_45, -- 1266
			____joint_canCollide_44, -- 1267
			joint.bodyA.current, -- 1268
			joint.bodyB.current, -- 1269
			joint.anchorA or Dora.Vec2.zero, -- 1270
			joint.anchorB or Dora.Vec2.zero, -- 1271
			joint.maxLength or 0 -- 1272
		) -- 1272
	end, -- 1252
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1275
		local joint = enode.props -- 1276
		if joint.ref == nil then -- 1276
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1278
			return -- 1279
		end -- 1279
		if joint.bodyA.current == nil then -- 1279
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1282
			return -- 1283
		end -- 1283
		if joint.bodyB.current == nil then -- 1283
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1286
			return -- 1287
		end -- 1287
		local ____joint_ref_51 = joint.ref -- 1289
		local ____self_49 = Dora.Joint -- 1289
		local ____self_49_weld_50 = ____self_49.weld -- 1289
		local ____joint_canCollide_48 = joint.canCollide -- 1290
		if ____joint_canCollide_48 == nil then -- 1290
			____joint_canCollide_48 = false -- 1290
		end -- 1290
		____joint_ref_51.current = ____self_49_weld_50( -- 1289
			____self_49, -- 1289
			____joint_canCollide_48, -- 1290
			joint.bodyA.current, -- 1291
			joint.bodyB.current, -- 1292
			joint.worldPos, -- 1293
			joint.frequency or 0, -- 1294
			joint.damping or 0 -- 1295
		) -- 1295
	end, -- 1275
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1298
		local joint = enode.props -- 1299
		if joint.ref == nil then -- 1299
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1301
			return -- 1302
		end -- 1302
		if joint.bodyA.current == nil then -- 1302
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1305
			return -- 1306
		end -- 1306
		if joint.bodyB.current == nil then -- 1306
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1309
			return -- 1310
		end -- 1310
		local ____joint_ref_55 = joint.ref -- 1312
		local ____self_53 = Dora.Joint -- 1312
		local ____self_53_wheel_54 = ____self_53.wheel -- 1312
		local ____joint_canCollide_52 = joint.canCollide -- 1313
		if ____joint_canCollide_52 == nil then -- 1313
			____joint_canCollide_52 = false -- 1313
		end -- 1313
		____joint_ref_55.current = ____self_53_wheel_54( -- 1312
			____self_53, -- 1312
			____joint_canCollide_52, -- 1313
			joint.bodyA.current, -- 1314
			joint.bodyB.current, -- 1315
			joint.worldPos, -- 1316
			joint.axisAngle, -- 1317
			joint.maxMotorTorque or 0, -- 1318
			joint.motorSpeed or 0, -- 1319
			joint.frequency or 0, -- 1320
			joint.damping or 0.7 -- 1321
		) -- 1321
	end, -- 1298
	["custom-node"] = function(nodeStack, enode, _parent) -- 1324
		local node = getCustomNode(enode) -- 1325
		if node ~= nil then -- 1325
			addChild(nodeStack, node, enode) -- 1327
		end -- 1327
	end, -- 1324
	["custom-element"] = function() -- 1330
	end, -- 1330
	["align-node"] = function(nodeStack, enode, _parent) -- 1331
		addChild( -- 1332
			nodeStack, -- 1332
			getAlignNode(enode), -- 1332
			enode -- 1332
		) -- 1332
	end, -- 1331
	["effek-node"] = function(nodeStack, enode, _parent) -- 1334
		addChild( -- 1335
			nodeStack, -- 1335
			getEffekNode(enode), -- 1335
			enode -- 1335
		) -- 1335
	end, -- 1334
	effek = function(nodeStack, enode, parent) -- 1337
		if #nodeStack > 0 then -- 1337
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1339
			if node then -- 1339
				local effek = enode.props -- 1341
				local handle = node:play( -- 1342
					effek.file, -- 1342
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1342
					effek.z or 0 -- 1342
				) -- 1342
				if handle >= 0 then -- 1342
					if effek.ref then -- 1342
						effek.ref.current = handle -- 1345
					end -- 1345
					if effek.onEnd then -- 1345
						local onEnd = effek.onEnd -- 1345
						node:slot( -- 1349
							"EffekEnd", -- 1349
							function(h) -- 1349
								if handle == h then -- 1349
									onEnd(nil) -- 1351
								end -- 1351
							end -- 1349
						) -- 1349
					end -- 1349
				end -- 1349
			else -- 1349
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1357
			end -- 1357
		end -- 1357
	end, -- 1337
	["tile-node"] = function(nodeStack, enode, parent) -- 1361
		local cnode = getTileNode(enode) -- 1362
		if cnode ~= nil then -- 1362
			addChild(nodeStack, cnode, enode) -- 1364
		end -- 1364
	end -- 1361
} -- 1361
function ____exports.useRef(item) -- 1409
	local ____item_56 = item -- 1410
	if ____item_56 == nil then -- 1410
		____item_56 = nil -- 1410
	end -- 1410
	return {current = ____item_56} -- 1410
end -- 1409
local function getPreload(preloadList, node) -- 1413
	if type(node) ~= "table" then -- 1413
		return -- 1415
	end -- 1415
	local enode = node -- 1417
	if enode.type == nil then -- 1417
		local list = node -- 1419
		if #list > 0 then -- 1419
			for i = 1, #list do -- 1419
				getPreload(preloadList, list[i]) -- 1422
			end -- 1422
		end -- 1422
	else -- 1422
		repeat -- 1422
			local ____switch314 = enode.type -- 1422
			local sprite, playable, frame, model, spine, dragonBone, label -- 1422
			local ____cond314 = ____switch314 == "sprite" -- 1422
			if ____cond314 then -- 1422
				sprite = enode.props -- 1428
				if sprite.file then -- 1428
					preloadList[#preloadList + 1] = sprite.file -- 1430
				end -- 1430
				break -- 1432
			end -- 1432
			____cond314 = ____cond314 or ____switch314 == "playable" -- 1432
			if ____cond314 then -- 1432
				playable = enode.props -- 1434
				preloadList[#preloadList + 1] = playable.file -- 1435
				break -- 1436
			end -- 1436
			____cond314 = ____cond314 or ____switch314 == "frame" -- 1436
			if ____cond314 then -- 1436
				frame = enode.props -- 1438
				preloadList[#preloadList + 1] = frame.file -- 1439
				break -- 1440
			end -- 1440
			____cond314 = ____cond314 or ____switch314 == "model" -- 1440
			if ____cond314 then -- 1440
				model = enode.props -- 1442
				preloadList[#preloadList + 1] = "model:" .. model.file -- 1443
				break -- 1444
			end -- 1444
			____cond314 = ____cond314 or ____switch314 == "spine" -- 1444
			if ____cond314 then -- 1444
				spine = enode.props -- 1446
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1447
				break -- 1448
			end -- 1448
			____cond314 = ____cond314 or ____switch314 == "dragon-bone" -- 1448
			if ____cond314 then -- 1448
				dragonBone = enode.props -- 1450
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1451
				break -- 1452
			end -- 1452
			____cond314 = ____cond314 or ____switch314 == "label" -- 1452
			if ____cond314 then -- 1452
				label = enode.props -- 1454
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1455
				break -- 1456
			end -- 1456
		until true -- 1456
	end -- 1456
	getPreload(preloadList, enode.children) -- 1459
end -- 1413
function ____exports.preloadAsync(enode, handler) -- 1462
	local preloadList = {} -- 1463
	getPreload(preloadList, enode) -- 1464
	Dora.Cache:loadAsync(preloadList, handler) -- 1465
end -- 1462
function ____exports.toAction(enode) -- 1468
	local actionDef = ____exports.useRef() -- 1469
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 1470
	if not actionDef.current then -- 1470
		error("failed to create action") -- 1471
	end -- 1471
	return actionDef.current -- 1472
end -- 1468
return ____exports -- 1468