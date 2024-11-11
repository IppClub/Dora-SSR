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
function visitNode(nodeStack, node, parent) -- 1357
	if type(node) ~= "table" then -- 1357
		return -- 1359
	end -- 1359
	local enode = node -- 1361
	if enode.type == nil then -- 1361
		local list = node -- 1363
		if #list > 0 then -- 1363
			for i = 1, #list do -- 1363
				local stack = {} -- 1366
				visitNode(stack, list[i], parent) -- 1367
				for i = 1, #stack do -- 1367
					nodeStack[#nodeStack + 1] = stack[i] -- 1369
				end -- 1369
			end -- 1369
		end -- 1369
	else -- 1369
		local handler = elementMap[enode.type] -- 1374
		if handler ~= nil then -- 1374
			handler(nodeStack, enode, parent) -- 1376
		else -- 1376
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1378
		end -- 1378
	end -- 1378
end -- 1378
function ____exports.toNode(enode) -- 1383
	local nodeStack = {} -- 1384
	visitNode(nodeStack, enode) -- 1385
	if #nodeStack == 1 then -- 1385
		return nodeStack[1] -- 1387
	elseif #nodeStack > 1 then -- 1387
		local node = Dora.Node() -- 1389
		for i = 1, #nodeStack do -- 1389
			node:addChild(nodeStack[i]) -- 1391
		end -- 1391
		return node -- 1393
	end -- 1393
	return nil -- 1395
end -- 1383
____exports.React = {} -- 1383
local React = ____exports.React -- 1383
do -- 1383
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
		repeat -- 61
			local ____switch14 = type(typeName) -- 61
			local ____cond14 = ____switch14 == "function" -- 61
			if ____cond14 then -- 61
				do -- 61
					if props == nil then -- 61
						props = {} -- 68
					end -- 68
					if props.children then -- 68
						local ____props_1 = props -- 70
						local ____array_0 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 70
						__TS__SparseArrayPush(____array_0, ...) -- 70
						____props_1.children = {__TS__SparseArraySpread(____array_0)} -- 70
					else -- 70
						props.children = children -- 72
					end -- 72
					return typeName(props) -- 74
				end -- 74
			end -- 74
			____cond14 = ____cond14 or ____switch14 == "table" -- 74
			if ____cond14 then -- 74
				do -- 74
					if not typeName.isComponent then -- 74
						Warn("unsupported class object in element creation") -- 78
						return {} -- 79
					end -- 79
					if props == nil then -- 79
						props = {} -- 81
					end -- 81
					if props.children then -- 81
						local ____props_3 = props -- 83
						local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 83
						__TS__SparseArrayPush( -- 83
							____array_2, -- 83
							table.unpack(children) -- 83
						) -- 83
						____props_3.children = {__TS__SparseArraySpread(____array_2)} -- 83
					else -- 83
						props.children = children -- 85
					end -- 85
					local inst = __TS__New(typeName, props) -- 87
					return inst:render() -- 88
				end -- 88
			end -- 88
			do -- 88
				do -- 88
					if props and props.children then -- 88
						local ____array_4 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 88
						__TS__SparseArrayPush( -- 88
							____array_4, -- 88
							table.unpack(children) -- 92
						) -- 92
						children = {__TS__SparseArraySpread(____array_4)} -- 92
						props.children = nil -- 93
					end -- 93
					local flatChildren = {} -- 95
					for i = 1, #children do -- 95
						local child, flat = flattenChild(children[i]) -- 97
						if flat then -- 97
							flatChildren[#flatChildren + 1] = child -- 99
						else -- 99
							for i = 1, #child do -- 99
								flatChildren[#flatChildren + 1] = child[i] -- 102
							end -- 102
						end -- 102
					end -- 102
					children = flatChildren -- 106
				end -- 106
			end -- 106
		until true -- 106
		if typeName == nil then -- 106
			return children -- 110
		end -- 110
		local ____typeName_6 = typeName -- 113
		local ____props_5 = props -- 114
		if ____props_5 == nil then -- 114
			____props_5 = {} -- 114
		end -- 114
		return {type = ____typeName_6, props = ____props_5, children = children} -- 112
	end -- 61
end -- 61
local function getNode(enode, cnode, attribHandler) -- 123
	cnode = cnode or Dora.Node() -- 124
	local jnode = enode.props -- 125
	local anchor = nil -- 126
	local color3 = nil -- 127
	for k, v in pairs(enode.props) do -- 128
		repeat -- 128
			local ____switch31 = k -- 128
			local ____cond31 = ____switch31 == "ref" -- 128
			if ____cond31 then -- 128
				v.current = cnode -- 130
				break -- 130
			end -- 130
			____cond31 = ____cond31 or ____switch31 == "anchorX" -- 130
			if ____cond31 then -- 130
				anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 131
				break -- 131
			end -- 131
			____cond31 = ____cond31 or ____switch31 == "anchorY" -- 131
			if ____cond31 then -- 131
				anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 132
				break -- 132
			end -- 132
			____cond31 = ____cond31 or ____switch31 == "color3" -- 132
			if ____cond31 then -- 132
				color3 = Dora.Color3(v) -- 133
				break -- 133
			end -- 133
			____cond31 = ____cond31 or ____switch31 == "transformTarget" -- 133
			if ____cond31 then -- 133
				cnode.transformTarget = v.current -- 134
				break -- 134
			end -- 134
			____cond31 = ____cond31 or ____switch31 == "onUpdate" -- 134
			if ____cond31 then -- 134
				cnode:schedule(v) -- 135
				break -- 135
			end -- 135
			____cond31 = ____cond31 or ____switch31 == "onActionEnd" -- 135
			if ____cond31 then -- 135
				cnode:slot("ActionEnd", v) -- 136
				break -- 136
			end -- 136
			____cond31 = ____cond31 or ____switch31 == "onTapFilter" -- 136
			if ____cond31 then -- 136
				cnode:slot("TapFilter", v) -- 137
				break -- 137
			end -- 137
			____cond31 = ____cond31 or ____switch31 == "onTapBegan" -- 137
			if ____cond31 then -- 137
				cnode:slot("TapBegan", v) -- 138
				break -- 138
			end -- 138
			____cond31 = ____cond31 or ____switch31 == "onTapEnded" -- 138
			if ____cond31 then -- 138
				cnode:slot("TapEnded", v) -- 139
				break -- 139
			end -- 139
			____cond31 = ____cond31 or ____switch31 == "onTapped" -- 139
			if ____cond31 then -- 139
				cnode:slot("Tapped", v) -- 140
				break -- 140
			end -- 140
			____cond31 = ____cond31 or ____switch31 == "onTapMoved" -- 140
			if ____cond31 then -- 140
				cnode:slot("TapMoved", v) -- 141
				break -- 141
			end -- 141
			____cond31 = ____cond31 or ____switch31 == "onMouseWheel" -- 141
			if ____cond31 then -- 141
				cnode:slot("MouseWheel", v) -- 142
				break -- 142
			end -- 142
			____cond31 = ____cond31 or ____switch31 == "onGesture" -- 142
			if ____cond31 then -- 142
				cnode:slot("Gesture", v) -- 143
				break -- 143
			end -- 143
			____cond31 = ____cond31 or ____switch31 == "onEnter" -- 143
			if ____cond31 then -- 143
				cnode:slot("Enter", v) -- 144
				break -- 144
			end -- 144
			____cond31 = ____cond31 or ____switch31 == "onExit" -- 144
			if ____cond31 then -- 144
				cnode:slot("Exit", v) -- 145
				break -- 145
			end -- 145
			____cond31 = ____cond31 or ____switch31 == "onCleanup" -- 145
			if ____cond31 then -- 145
				cnode:slot("Cleanup", v) -- 146
				break -- 146
			end -- 146
			____cond31 = ____cond31 or ____switch31 == "onKeyDown" -- 146
			if ____cond31 then -- 146
				cnode:slot("KeyDown", v) -- 147
				break -- 147
			end -- 147
			____cond31 = ____cond31 or ____switch31 == "onKeyUp" -- 147
			if ____cond31 then -- 147
				cnode:slot("KeyUp", v) -- 148
				break -- 148
			end -- 148
			____cond31 = ____cond31 or ____switch31 == "onKeyPressed" -- 148
			if ____cond31 then -- 148
				cnode:slot("KeyPressed", v) -- 149
				break -- 149
			end -- 149
			____cond31 = ____cond31 or ____switch31 == "onAttachIME" -- 149
			if ____cond31 then -- 149
				cnode:slot("AttachIME", v) -- 150
				break -- 150
			end -- 150
			____cond31 = ____cond31 or ____switch31 == "onDetachIME" -- 150
			if ____cond31 then -- 150
				cnode:slot("DetachIME", v) -- 151
				break -- 151
			end -- 151
			____cond31 = ____cond31 or ____switch31 == "onTextInput" -- 151
			if ____cond31 then -- 151
				cnode:slot("TextInput", v) -- 152
				break -- 152
			end -- 152
			____cond31 = ____cond31 or ____switch31 == "onTextEditing" -- 152
			if ____cond31 then -- 152
				cnode:slot("TextEditing", v) -- 153
				break -- 153
			end -- 153
			____cond31 = ____cond31 or ____switch31 == "onButtonDown" -- 153
			if ____cond31 then -- 153
				cnode:slot("ButtonDown", v) -- 154
				break -- 154
			end -- 154
			____cond31 = ____cond31 or ____switch31 == "onButtonUp" -- 154
			if ____cond31 then -- 154
				cnode:slot("ButtonUp", v) -- 155
				break -- 155
			end -- 155
			____cond31 = ____cond31 or ____switch31 == "onAxis" -- 155
			if ____cond31 then -- 155
				cnode:slot("Axis", v) -- 156
				break -- 156
			end -- 156
			do -- 156
				do -- 156
					if attribHandler then -- 156
						if not attribHandler(cnode, enode, k, v) then -- 156
							cnode[k] = v -- 160
						end -- 160
					else -- 160
						cnode[k] = v -- 163
					end -- 163
					break -- 165
				end -- 165
			end -- 165
		until true -- 165
	end -- 165
	if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 165
		cnode.touchEnabled = true -- 178
	end -- 178
	if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 178
		cnode.keyboardEnabled = true -- 185
	end -- 185
	if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 185
		cnode.controllerEnabled = true -- 192
	end -- 192
	if anchor ~= nil then -- 192
		cnode.anchor = anchor -- 194
	end -- 194
	if color3 ~= nil then -- 194
		cnode.color3 = color3 -- 195
	end -- 195
	if jnode.onMount ~= nil then -- 195
		jnode.onMount(cnode) -- 197
	end -- 197
	return cnode -- 199
end -- 123
local getClipNode -- 202
do -- 202
	local function handleClipNodeAttribute(cnode, _enode, k, v) -- 204
		repeat -- 204
			local ____switch44 = k -- 204
			local ____cond44 = ____switch44 == "stencil" -- 204
			if ____cond44 then -- 204
				cnode.stencil = ____exports.toNode(v) -- 211
				return true -- 211
			end -- 211
		until true -- 211
		return false -- 213
	end -- 204
	getClipNode = function(enode) -- 215
		return getNode( -- 216
			enode, -- 216
			Dora.ClipNode(), -- 216
			handleClipNodeAttribute -- 216
		) -- 216
	end -- 215
end -- 215
local getPlayable -- 220
local getDragonBone -- 221
local getSpine -- 222
local getModel -- 223
do -- 223
	local function handlePlayableAttribute(cnode, enode, k, v) -- 225
		repeat -- 225
			local ____switch48 = k -- 225
			local ____cond48 = ____switch48 == "file" -- 225
			if ____cond48 then -- 225
				return true -- 227
			end -- 227
			____cond48 = ____cond48 or ____switch48 == "play" -- 227
			if ____cond48 then -- 227
				cnode:play(v, enode.props.loop == true) -- 228
				return true -- 228
			end -- 228
			____cond48 = ____cond48 or ____switch48 == "loop" -- 228
			if ____cond48 then -- 228
				return true -- 229
			end -- 229
			____cond48 = ____cond48 or ____switch48 == "onAnimationEnd" -- 229
			if ____cond48 then -- 229
				cnode:slot("AnimationEnd", v) -- 230
				return true -- 230
			end -- 230
		until true -- 230
		return false -- 232
	end -- 225
	getPlayable = function(enode, cnode, attribHandler) -- 234
		if attribHandler == nil then -- 234
			attribHandler = handlePlayableAttribute -- 235
		end -- 235
		cnode = cnode or Dora.Playable(enode.props.file) or nil -- 236
		if cnode ~= nil then -- 236
			return getNode(enode, cnode, attribHandler) -- 238
		end -- 238
		return nil -- 240
	end -- 234
	local function handleDragonBoneAttribute(cnode, enode, k, v) -- 243
		repeat -- 243
			local ____switch52 = k -- 243
			local ____cond52 = ____switch52 == "hitTestEnabled" -- 243
			if ____cond52 then -- 243
				cnode.hitTestEnabled = true -- 245
				return true -- 245
			end -- 245
		until true -- 245
		return handlePlayableAttribute(cnode, enode, k, v) -- 247
	end -- 243
	getDragonBone = function(enode) -- 249
		local node = Dora.DragonBone(enode.props.file) -- 250
		if node ~= nil then -- 250
			local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 252
			return cnode -- 253
		end -- 253
		return nil -- 255
	end -- 249
	local function handleSpineAttribute(cnode, enode, k, v) -- 258
		repeat -- 258
			local ____switch56 = k -- 258
			local ____cond56 = ____switch56 == "hitTestEnabled" -- 258
			if ____cond56 then -- 258
				cnode.hitTestEnabled = true -- 260
				return true -- 260
			end -- 260
		until true -- 260
		return handlePlayableAttribute(cnode, enode, k, v) -- 262
	end -- 258
	getSpine = function(enode) -- 264
		local node = Dora.Spine(enode.props.file) -- 265
		if node ~= nil then -- 265
			local cnode = getPlayable(enode, node, handleSpineAttribute) -- 267
			return cnode -- 268
		end -- 268
		return nil -- 270
	end -- 264
	local function handleModelAttribute(cnode, enode, k, v) -- 273
		repeat -- 273
			local ____switch60 = k -- 273
			local ____cond60 = ____switch60 == "reversed" -- 273
			if ____cond60 then -- 273
				cnode.reversed = v -- 275
				return true -- 275
			end -- 275
		until true -- 275
		return handlePlayableAttribute(cnode, enode, k, v) -- 277
	end -- 273
	getModel = function(enode) -- 279
		local node = Dora.Model(enode.props.file) -- 280
		if node ~= nil then -- 280
			local cnode = getPlayable(enode, node, handleModelAttribute) -- 282
			return cnode -- 283
		end -- 283
		return nil -- 285
	end -- 279
end -- 279
local getDrawNode -- 289
do -- 289
	local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 291
		repeat -- 291
			local ____switch65 = k -- 291
			local ____cond65 = ____switch65 == "depthWrite" -- 291
			if ____cond65 then -- 291
				cnode.depthWrite = v -- 293
				return true -- 293
			end -- 293
			____cond65 = ____cond65 or ____switch65 == "blendFunc" -- 293
			if ____cond65 then -- 293
				cnode.blendFunc = v -- 294
				return true -- 294
			end -- 294
		until true -- 294
		return false -- 296
	end -- 291
	getDrawNode = function(enode) -- 298
		local node = Dora.DrawNode() -- 299
		local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 300
		local ____enode_7 = enode -- 301
		local children = ____enode_7.children -- 301
		for i = 1, #children do -- 301
			do -- 301
				local child = children[i] -- 303
				if type(child) ~= "table" then -- 303
					goto __continue67 -- 305
				end -- 305
				repeat -- 305
					local ____switch69 = child.type -- 305
					local ____cond69 = ____switch69 == "dot-shape" -- 305
					if ____cond69 then -- 305
						do -- 305
							local dot = child.props -- 309
							node:drawDot( -- 310
								Dora.Vec2(dot.x or 0, dot.y or 0), -- 311
								dot.radius, -- 312
								Dora.Color(dot.color or 4294967295) -- 313
							) -- 313
							break -- 315
						end -- 315
					end -- 315
					____cond69 = ____cond69 or ____switch69 == "segment-shape" -- 315
					if ____cond69 then -- 315
						do -- 315
							local segment = child.props -- 318
							node:drawSegment( -- 319
								Dora.Vec2(segment.startX, segment.startY), -- 320
								Dora.Vec2(segment.stopX, segment.stopY), -- 321
								segment.radius, -- 322
								Dora.Color(segment.color or 4294967295) -- 323
							) -- 323
							break -- 325
						end -- 325
					end -- 325
					____cond69 = ____cond69 or ____switch69 == "rect-shape" -- 325
					if ____cond69 then -- 325
						do -- 325
							local rect = child.props -- 328
							local centerX = rect.centerX or 0 -- 329
							local centerY = rect.centerY or 0 -- 330
							local hw = rect.width / 2 -- 331
							local hh = rect.height / 2 -- 332
							node:drawPolygon( -- 333
								{ -- 334
									Dora.Vec2(centerX - hw, centerY + hh), -- 335
									Dora.Vec2(centerX + hw, centerY + hh), -- 336
									Dora.Vec2(centerX + hw, centerY - hh), -- 337
									Dora.Vec2(centerX - hw, centerY - hh) -- 338
								}, -- 338
								Dora.Color(rect.fillColor or 4294967295), -- 340
								rect.borderWidth or 0, -- 341
								Dora.Color(rect.borderColor or 4294967295) -- 342
							) -- 342
							break -- 344
						end -- 344
					end -- 344
					____cond69 = ____cond69 or ____switch69 == "polygon-shape" -- 344
					if ____cond69 then -- 344
						do -- 344
							local poly = child.props -- 347
							node:drawPolygon( -- 348
								poly.verts, -- 349
								Dora.Color(poly.fillColor or 4294967295), -- 350
								poly.borderWidth or 0, -- 351
								Dora.Color(poly.borderColor or 4294967295) -- 352
							) -- 352
							break -- 354
						end -- 354
					end -- 354
					____cond69 = ____cond69 or ____switch69 == "verts-shape" -- 354
					if ____cond69 then -- 354
						do -- 354
							local verts = child.props -- 357
							node:drawVertices(__TS__ArrayMap( -- 358
								verts.verts, -- 358
								function(____, ____bindingPattern0) -- 358
									local color -- 358
									local vert -- 358
									vert = ____bindingPattern0[1] -- 358
									color = ____bindingPattern0[2] -- 358
									return { -- 358
										vert, -- 358
										Dora.Color(color) -- 358
									} -- 358
								end -- 358
							)) -- 358
							break -- 359
						end -- 359
					end -- 359
				until true -- 359
			end -- 359
			::__continue67:: -- 359
		end -- 359
		return cnode -- 363
	end -- 298
end -- 298
local getGrid -- 367
do -- 367
	local function handleGridAttribute(cnode, _enode, k, v) -- 369
		repeat -- 369
			local ____switch78 = k -- 369
			local ____cond78 = ____switch78 == "file" or ____switch78 == "gridX" or ____switch78 == "gridY" -- 369
			if ____cond78 then -- 369
				return true -- 371
			end -- 371
			____cond78 = ____cond78 or ____switch78 == "textureRect" -- 371
			if ____cond78 then -- 371
				cnode.textureRect = v -- 372
				return true -- 372
			end -- 372
			____cond78 = ____cond78 or ____switch78 == "depthWrite" -- 372
			if ____cond78 then -- 372
				cnode.depthWrite = v -- 373
				return true -- 373
			end -- 373
			____cond78 = ____cond78 or ____switch78 == "blendFunc" -- 373
			if ____cond78 then -- 373
				cnode.blendFunc = v -- 374
				return true -- 374
			end -- 374
			____cond78 = ____cond78 or ____switch78 == "effect" -- 374
			if ____cond78 then -- 374
				cnode.effect = v -- 375
				return true -- 375
			end -- 375
		until true -- 375
		return false -- 377
	end -- 369
	getGrid = function(enode) -- 379
		local grid = enode.props -- 380
		local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 381
		local cnode = getNode(enode, node, handleGridAttribute) -- 382
		return cnode -- 383
	end -- 379
end -- 379
local getSprite -- 387
do -- 387
	local function handleSpriteAttribute(cnode, _enode, k, v) -- 389
		repeat -- 389
			local ____switch82 = k -- 389
			local ____cond82 = ____switch82 == "file" -- 389
			if ____cond82 then -- 389
				return true -- 391
			end -- 391
			____cond82 = ____cond82 or ____switch82 == "textureRect" -- 391
			if ____cond82 then -- 391
				cnode.textureRect = v -- 392
				return true -- 392
			end -- 392
			____cond82 = ____cond82 or ____switch82 == "depthWrite" -- 392
			if ____cond82 then -- 392
				cnode.depthWrite = v -- 393
				return true -- 393
			end -- 393
			____cond82 = ____cond82 or ____switch82 == "blendFunc" -- 393
			if ____cond82 then -- 393
				cnode.blendFunc = v -- 394
				return true -- 394
			end -- 394
			____cond82 = ____cond82 or ____switch82 == "effect" -- 394
			if ____cond82 then -- 394
				cnode.effect = v -- 395
				return true -- 395
			end -- 395
			____cond82 = ____cond82 or ____switch82 == "alphaRef" -- 395
			if ____cond82 then -- 395
				cnode.alphaRef = v -- 396
				return true -- 396
			end -- 396
			____cond82 = ____cond82 or ____switch82 == "uwrap" -- 396
			if ____cond82 then -- 396
				cnode.uwrap = v -- 397
				return true -- 397
			end -- 397
			____cond82 = ____cond82 or ____switch82 == "vwrap" -- 397
			if ____cond82 then -- 397
				cnode.vwrap = v -- 398
				return true -- 398
			end -- 398
			____cond82 = ____cond82 or ____switch82 == "filter" -- 398
			if ____cond82 then -- 398
				cnode.filter = v -- 399
				return true -- 399
			end -- 399
		until true -- 399
		return false -- 401
	end -- 389
	getSprite = function(enode) -- 403
		local sp = enode.props -- 404
		if sp.file then -- 404
			local node = Dora.Sprite(sp.file) -- 406
			if node ~= nil then -- 406
				local cnode = getNode(enode, node, handleSpriteAttribute) -- 408
				return cnode -- 409
			end -- 409
		else -- 409
			local node = Dora.Sprite() -- 412
			local cnode = getNode(enode, node, handleSpriteAttribute) -- 413
			return cnode -- 414
		end -- 414
		return nil -- 416
	end -- 403
end -- 403
local getLabel -- 420
do -- 420
	local function handleLabelAttribute(cnode, _enode, k, v) -- 422
		repeat -- 422
			local ____switch89 = k -- 422
			local ____cond89 = ____switch89 == "fontName" or ____switch89 == "fontSize" or ____switch89 == "text" -- 422
			if ____cond89 then -- 422
				return true -- 424
			end -- 424
			____cond89 = ____cond89 or ____switch89 == "alphaRef" -- 424
			if ____cond89 then -- 424
				cnode.alphaRef = v -- 425
				return true -- 425
			end -- 425
			____cond89 = ____cond89 or ____switch89 == "textWidth" -- 425
			if ____cond89 then -- 425
				cnode.textWidth = v -- 426
				return true -- 426
			end -- 426
			____cond89 = ____cond89 or ____switch89 == "lineGap" -- 426
			if ____cond89 then -- 426
				cnode.lineGap = v -- 427
				return true -- 427
			end -- 427
			____cond89 = ____cond89 or ____switch89 == "spacing" -- 427
			if ____cond89 then -- 427
				cnode.spacing = v -- 428
				return true -- 428
			end -- 428
			____cond89 = ____cond89 or ____switch89 == "blendFunc" -- 428
			if ____cond89 then -- 428
				cnode.blendFunc = v -- 429
				return true -- 429
			end -- 429
			____cond89 = ____cond89 or ____switch89 == "depthWrite" -- 429
			if ____cond89 then -- 429
				cnode.depthWrite = v -- 430
				return true -- 430
			end -- 430
			____cond89 = ____cond89 or ____switch89 == "batched" -- 430
			if ____cond89 then -- 430
				cnode.batched = v -- 431
				return true -- 431
			end -- 431
			____cond89 = ____cond89 or ____switch89 == "effect" -- 431
			if ____cond89 then -- 431
				cnode.effect = v -- 432
				return true -- 432
			end -- 432
			____cond89 = ____cond89 or ____switch89 == "alignment" -- 432
			if ____cond89 then -- 432
				cnode.alignment = v -- 433
				return true -- 433
			end -- 433
		until true -- 433
		return false -- 435
	end -- 422
	getLabel = function(enode) -- 437
		local label = enode.props -- 438
		local node = Dora.Label(label.fontName, label.fontSize) -- 439
		if node ~= nil then -- 439
			local cnode = getNode(enode, node, handleLabelAttribute) -- 441
			local ____enode_8 = enode -- 442
			local children = ____enode_8.children -- 442
			local text = label.text or "" -- 443
			for i = 1, #children do -- 443
				local child = children[i] -- 445
				if type(child) ~= "table" then -- 445
					text = text .. tostring(child) -- 447
				end -- 447
			end -- 447
			node.text = text -- 450
			return cnode -- 451
		end -- 451
		return nil -- 453
	end -- 437
end -- 437
local getLine -- 457
do -- 457
	local function handleLineAttribute(cnode, enode, k, v) -- 459
		local line = enode.props -- 460
		repeat -- 460
			local ____switch96 = k -- 460
			local ____cond96 = ____switch96 == "verts" -- 460
			if ____cond96 then -- 460
				cnode:set( -- 462
					v, -- 462
					Dora.Color(line.lineColor or 4294967295) -- 462
				) -- 462
				return true -- 462
			end -- 462
			____cond96 = ____cond96 or ____switch96 == "depthWrite" -- 462
			if ____cond96 then -- 462
				cnode.depthWrite = v -- 463
				return true -- 463
			end -- 463
			____cond96 = ____cond96 or ____switch96 == "blendFunc" -- 463
			if ____cond96 then -- 463
				cnode.blendFunc = v -- 464
				return true -- 464
			end -- 464
		until true -- 464
		return false -- 466
	end -- 459
	getLine = function(enode) -- 468
		local node = Dora.Line() -- 469
		local cnode = getNode(enode, node, handleLineAttribute) -- 470
		return cnode -- 471
	end -- 468
end -- 468
local getParticle -- 475
do -- 475
	local function handleParticleAttribute(cnode, _enode, k, v) -- 477
		repeat -- 477
			local ____switch100 = k -- 477
			local ____cond100 = ____switch100 == "file" -- 477
			if ____cond100 then -- 477
				return true -- 479
			end -- 479
			____cond100 = ____cond100 or ____switch100 == "emit" -- 479
			if ____cond100 then -- 479
				if v then -- 479
					cnode:start() -- 480
				end -- 480
				return true -- 480
			end -- 480
			____cond100 = ____cond100 or ____switch100 == "onFinished" -- 480
			if ____cond100 then -- 480
				cnode:slot("Finished", v) -- 481
				return true -- 481
			end -- 481
		until true -- 481
		return false -- 483
	end -- 477
	getParticle = function(enode) -- 485
		local particle = enode.props -- 486
		local node = Dora.Particle(particle.file) -- 487
		if node ~= nil then -- 487
			local cnode = getNode(enode, node, handleParticleAttribute) -- 489
			return cnode -- 490
		end -- 490
		return nil -- 492
	end -- 485
end -- 485
local getMenu -- 496
do -- 496
	local function handleMenuAttribute(cnode, _enode, k, v) -- 498
		repeat -- 498
			local ____switch106 = k -- 498
			local ____cond106 = ____switch106 == "enabled" -- 498
			if ____cond106 then -- 498
				cnode.enabled = v -- 500
				return true -- 500
			end -- 500
		until true -- 500
		return false -- 502
	end -- 498
	getMenu = function(enode) -- 504
		local node = Dora.Menu() -- 505
		local cnode = getNode(enode, node, handleMenuAttribute) -- 506
		return cnode -- 507
	end -- 504
end -- 504
local function getPhysicsWorld(enode) -- 511
	local node = Dora.PhysicsWorld() -- 512
	local cnode = getNode(enode, node) -- 513
	return cnode -- 514
end -- 511
local getBody -- 517
do -- 517
	local function handleBodyAttribute(cnode, _enode, k, v) -- 519
		repeat -- 519
			local ____switch111 = k -- 519
			local ____cond111 = ____switch111 == "type" or ____switch111 == "linearAcceleration" or ____switch111 == "fixedRotation" or ____switch111 == "bullet" or ____switch111 == "world" -- 519
			if ____cond111 then -- 519
				return true -- 526
			end -- 526
			____cond111 = ____cond111 or ____switch111 == "velocityX" -- 526
			if ____cond111 then -- 526
				cnode.velocityX = v -- 527
				return true -- 527
			end -- 527
			____cond111 = ____cond111 or ____switch111 == "velocityY" -- 527
			if ____cond111 then -- 527
				cnode.velocityY = v -- 528
				return true -- 528
			end -- 528
			____cond111 = ____cond111 or ____switch111 == "angularRate" -- 528
			if ____cond111 then -- 528
				cnode.angularRate = v -- 529
				return true -- 529
			end -- 529
			____cond111 = ____cond111 or ____switch111 == "group" -- 529
			if ____cond111 then -- 529
				cnode.group = v -- 530
				return true -- 530
			end -- 530
			____cond111 = ____cond111 or ____switch111 == "linearDamping" -- 530
			if ____cond111 then -- 530
				cnode.linearDamping = v -- 531
				return true -- 531
			end -- 531
			____cond111 = ____cond111 or ____switch111 == "angularDamping" -- 531
			if ____cond111 then -- 531
				cnode.angularDamping = v -- 532
				return true -- 532
			end -- 532
			____cond111 = ____cond111 or ____switch111 == "owner" -- 532
			if ____cond111 then -- 532
				cnode.owner = v -- 533
				return true -- 533
			end -- 533
			____cond111 = ____cond111 or ____switch111 == "receivingContact" -- 533
			if ____cond111 then -- 533
				cnode.receivingContact = v -- 534
				return true -- 534
			end -- 534
			____cond111 = ____cond111 or ____switch111 == "onBodyEnter" -- 534
			if ____cond111 then -- 534
				cnode:slot("BodyEnter", v) -- 535
				return true -- 535
			end -- 535
			____cond111 = ____cond111 or ____switch111 == "onBodyLeave" -- 535
			if ____cond111 then -- 535
				cnode:slot("BodyLeave", v) -- 536
				return true -- 536
			end -- 536
			____cond111 = ____cond111 or ____switch111 == "onContactStart" -- 536
			if ____cond111 then -- 536
				cnode:slot("ContactStart", v) -- 537
				return true -- 537
			end -- 537
			____cond111 = ____cond111 or ____switch111 == "onContactEnd" -- 537
			if ____cond111 then -- 537
				cnode:slot("ContactEnd", v) -- 538
				return true -- 538
			end -- 538
			____cond111 = ____cond111 or ____switch111 == "onContactFilter" -- 538
			if ____cond111 then -- 538
				cnode:onContactFilter(v) -- 539
				return true -- 539
			end -- 539
		until true -- 539
		return false -- 541
	end -- 519
	getBody = function(enode, world) -- 543
		local def = enode.props -- 544
		local bodyDef = Dora.BodyDef() -- 545
		bodyDef.type = def.type -- 546
		if def.angle ~= nil then -- 546
			bodyDef.angle = def.angle -- 547
		end -- 547
		if def.angularDamping ~= nil then -- 547
			bodyDef.angularDamping = def.angularDamping -- 548
		end -- 548
		if def.bullet ~= nil then -- 548
			bodyDef.bullet = def.bullet -- 549
		end -- 549
		if def.fixedRotation ~= nil then -- 549
			bodyDef.fixedRotation = def.fixedRotation -- 550
		end -- 550
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 551
		if def.linearDamping ~= nil then -- 551
			bodyDef.linearDamping = def.linearDamping -- 552
		end -- 552
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 553
		local extraSensors = nil -- 554
		for i = 1, #enode.children do -- 554
			do -- 554
				local child = enode.children[i] -- 556
				if type(child) ~= "table" then -- 556
					goto __continue118 -- 558
				end -- 558
				repeat -- 558
					local ____switch120 = child.type -- 558
					local ____cond120 = ____switch120 == "rect-fixture" -- 558
					if ____cond120 then -- 558
						do -- 558
							local shape = child.props -- 562
							if shape.sensorTag ~= nil then -- 562
								bodyDef:attachPolygonSensor( -- 564
									shape.sensorTag, -- 565
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 566
									shape.width, -- 567
									shape.height, -- 567
									shape.angle or 0 -- 568
								) -- 568
							else -- 568
								bodyDef:attachPolygon( -- 571
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 572
									shape.width, -- 573
									shape.height, -- 573
									shape.angle or 0, -- 574
									shape.density or 1, -- 575
									shape.friction or 0.4, -- 576
									shape.restitution or 0 -- 577
								) -- 577
							end -- 577
							break -- 580
						end -- 580
					end -- 580
					____cond120 = ____cond120 or ____switch120 == "polygon-fixture" -- 580
					if ____cond120 then -- 580
						do -- 580
							local shape = child.props -- 583
							if shape.sensorTag ~= nil then -- 583
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 585
							else -- 585
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 590
							end -- 590
							break -- 597
						end -- 597
					end -- 597
					____cond120 = ____cond120 or ____switch120 == "multi-fixture" -- 597
					if ____cond120 then -- 597
						do -- 597
							local shape = child.props -- 600
							if shape.sensorTag ~= nil then -- 600
								if extraSensors == nil then -- 600
									extraSensors = {} -- 602
								end -- 602
								extraSensors[#extraSensors + 1] = { -- 603
									shape.sensorTag, -- 603
									Dora.BodyDef:multi(shape.verts) -- 603
								} -- 603
							else -- 603
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 605
							end -- 605
							break -- 612
						end -- 612
					end -- 612
					____cond120 = ____cond120 or ____switch120 == "disk-fixture" -- 612
					if ____cond120 then -- 612
						do -- 612
							local shape = child.props -- 615
							if shape.sensorTag ~= nil then -- 615
								bodyDef:attachDiskSensor( -- 617
									shape.sensorTag, -- 618
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 619
									shape.radius -- 620
								) -- 620
							else -- 620
								bodyDef:attachDisk( -- 623
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 624
									shape.radius, -- 625
									shape.density or 1, -- 626
									shape.friction or 0.4, -- 627
									shape.restitution or 0 -- 628
								) -- 628
							end -- 628
							break -- 631
						end -- 631
					end -- 631
					____cond120 = ____cond120 or ____switch120 == "chain-fixture" -- 631
					if ____cond120 then -- 631
						do -- 631
							local shape = child.props -- 634
							if shape.sensorTag ~= nil then -- 634
								if extraSensors == nil then -- 634
									extraSensors = {} -- 636
								end -- 636
								extraSensors[#extraSensors + 1] = { -- 637
									shape.sensorTag, -- 637
									Dora.BodyDef:chain(shape.verts) -- 637
								} -- 637
							else -- 637
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 639
							end -- 639
							break -- 645
						end -- 645
					end -- 645
				until true -- 645
			end -- 645
			::__continue118:: -- 645
		end -- 645
		local body = Dora.Body(bodyDef, world) -- 649
		if extraSensors ~= nil then -- 649
			for i = 1, #extraSensors do -- 649
				local tag, def = table.unpack(extraSensors[i]) -- 652
				body:attachSensor(tag, def) -- 653
			end -- 653
		end -- 653
		local cnode = getNode(enode, body, handleBodyAttribute) -- 656
		if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 656
			body.receivingContact = true -- 661
		end -- 661
		return cnode -- 663
	end -- 543
end -- 543
local getCustomNode -- 667
do -- 667
	local function handleCustomNode(_cnode, _enode, k, _v) -- 669
		repeat -- 669
			local ____switch141 = k -- 669
			local ____cond141 = ____switch141 == "onCreate" -- 669
			if ____cond141 then -- 669
				return true -- 671
			end -- 671
		until true -- 671
		return false -- 673
	end -- 669
	getCustomNode = function(enode) -- 675
		local custom = enode.props -- 676
		local node = custom.onCreate() -- 677
		if node then -- 677
			local cnode = getNode(enode, node, handleCustomNode) -- 679
			return cnode -- 680
		end -- 680
		return nil -- 682
	end -- 675
end -- 675
local getAlignNode -- 686
do -- 686
	local function handleAlignNode(_cnode, _enode, k, _v) -- 688
		repeat -- 688
			local ____switch146 = k -- 688
			local ____cond146 = ____switch146 == "windowRoot" -- 688
			if ____cond146 then -- 688
				return true -- 690
			end -- 690
			____cond146 = ____cond146 or ____switch146 == "style" -- 690
			if ____cond146 then -- 690
				return true -- 691
			end -- 691
			____cond146 = ____cond146 or ____switch146 == "onLayout" -- 691
			if ____cond146 then -- 691
				return true -- 692
			end -- 692
		until true -- 692
		return false -- 694
	end -- 688
	getAlignNode = function(enode) -- 696
		local alignNode = enode.props -- 697
		local node = Dora.AlignNode(alignNode.windowRoot) -- 698
		if alignNode.style then -- 698
			local items = {} -- 700
			for k, v in pairs(alignNode.style) do -- 701
				local name = string.gsub(k, "%u", "-%1") -- 702
				name = string.lower(name) -- 703
				repeat -- 703
					local ____switch150 = k -- 703
					local ____cond150 = ____switch150 == "margin" or ____switch150 == "padding" or ____switch150 == "border" or ____switch150 == "gap" -- 703
					if ____cond150 then -- 703
						do -- 703
							if type(v) == "table" then -- 703
								local valueStr = table.concat( -- 708
									__TS__ArrayMap( -- 708
										v, -- 708
										function(____, item) return tostring(item) end -- 708
									), -- 708
									"," -- 708
								) -- 708
								items[#items + 1] = (name .. ":") .. valueStr -- 709
							else -- 709
								items[#items + 1] = (name .. ":") .. tostring(v) -- 711
							end -- 711
							break -- 713
						end -- 713
					end -- 713
					do -- 713
						items[#items + 1] = (name .. ":") .. tostring(v) -- 716
						break -- 717
					end -- 717
				until true -- 717
			end -- 717
			local styleStr = table.concat(items, ";") -- 720
			node:css(styleStr) -- 721
		end -- 721
		if alignNode.onLayout then -- 721
			node:slot("AlignLayout", alignNode.onLayout) -- 724
		end -- 724
		local cnode = getNode(enode, node, handleAlignNode) -- 726
		return cnode -- 727
	end -- 696
end -- 696
local function getEffekNode(enode) -- 731
	return getNode( -- 732
		enode, -- 732
		Dora.EffekNode() -- 732
	) -- 732
end -- 731
local getTileNode -- 735
do -- 735
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 737
		repeat -- 737
			local ____switch159 = k -- 737
			local ____cond159 = ____switch159 == "file" or ____switch159 == "layers" -- 737
			if ____cond159 then -- 737
				return true -- 739
			end -- 739
			____cond159 = ____cond159 or ____switch159 == "depthWrite" -- 739
			if ____cond159 then -- 739
				cnode.depthWrite = v -- 740
				return true -- 740
			end -- 740
			____cond159 = ____cond159 or ____switch159 == "blendFunc" -- 740
			if ____cond159 then -- 740
				cnode.blendFunc = v -- 741
				return true -- 741
			end -- 741
			____cond159 = ____cond159 or ____switch159 == "effect" -- 741
			if ____cond159 then -- 741
				cnode.effect = v -- 742
				return true -- 742
			end -- 742
			____cond159 = ____cond159 or ____switch159 == "filter" -- 742
			if ____cond159 then -- 742
				cnode.filter = v -- 743
				return true -- 743
			end -- 743
		until true -- 743
		return false -- 745
	end -- 737
	getTileNode = function(enode) -- 747
		local tn = enode.props -- 748
		local ____tn_layers_9 -- 749
		if tn.layers then -- 749
			____tn_layers_9 = Dora.TileNode(tn.file, tn.layers) -- 749
		else -- 749
			____tn_layers_9 = Dora.TileNode(tn.file) -- 749
		end -- 749
		local node = ____tn_layers_9 -- 749
		if node ~= nil then -- 749
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 751
			return cnode -- 752
		end -- 752
		return nil -- 754
	end -- 747
end -- 747
local function addChild(nodeStack, cnode, enode) -- 758
	if #nodeStack > 0 then -- 758
		local last = nodeStack[#nodeStack] -- 760
		last:addChild(cnode) -- 761
	end -- 761
	nodeStack[#nodeStack + 1] = cnode -- 763
	local ____enode_10 = enode -- 764
	local children = ____enode_10.children -- 764
	for i = 1, #children do -- 764
		visitNode(nodeStack, children[i], enode) -- 766
	end -- 766
	if #nodeStack > 1 then -- 766
		table.remove(nodeStack) -- 769
	end -- 769
end -- 758
local function drawNodeCheck(_nodeStack, enode, parent) -- 777
	if parent == nil or parent.type ~= "draw-node" then -- 777
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 779
	end -- 779
end -- 777
local function visitAction(actionStack, enode) -- 783
	local createAction = actionMap[enode.type] -- 784
	if createAction ~= nil then -- 784
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 786
		return -- 787
	end -- 787
	repeat -- 787
		local ____switch170 = enode.type -- 787
		local ____cond170 = ____switch170 == "delay" -- 787
		if ____cond170 then -- 787
			do -- 787
				local item = enode.props -- 791
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 792
				break -- 793
			end -- 793
		end -- 793
		____cond170 = ____cond170 or ____switch170 == "event" -- 793
		if ____cond170 then -- 793
			do -- 793
				local item = enode.props -- 796
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 797
				break -- 798
			end -- 798
		end -- 798
		____cond170 = ____cond170 or ____switch170 == "hide" -- 798
		if ____cond170 then -- 798
			do -- 798
				actionStack[#actionStack + 1] = Dora.Hide() -- 801
				break -- 802
			end -- 802
		end -- 802
		____cond170 = ____cond170 or ____switch170 == "show" -- 802
		if ____cond170 then -- 802
			do -- 802
				actionStack[#actionStack + 1] = Dora.Show() -- 805
				break -- 806
			end -- 806
		end -- 806
		____cond170 = ____cond170 or ____switch170 == "move" -- 806
		if ____cond170 then -- 806
			do -- 806
				local item = enode.props -- 809
				actionStack[#actionStack + 1] = Dora.Move( -- 810
					item.time, -- 810
					Dora.Vec2(item.startX, item.startY), -- 810
					Dora.Vec2(item.stopX, item.stopY), -- 810
					item.easing -- 810
				) -- 810
				break -- 811
			end -- 811
		end -- 811
		____cond170 = ____cond170 or ____switch170 == "frame" -- 811
		if ____cond170 then -- 811
			do -- 811
				local item = enode.props -- 814
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 815
				break -- 816
			end -- 816
		end -- 816
		____cond170 = ____cond170 or ____switch170 == "spawn" -- 816
		if ____cond170 then -- 816
			do -- 816
				local spawnStack = {} -- 819
				for i = 1, #enode.children do -- 819
					visitAction(spawnStack, enode.children[i]) -- 821
				end -- 821
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 823
				break -- 824
			end -- 824
		end -- 824
		____cond170 = ____cond170 or ____switch170 == "sequence" -- 824
		if ____cond170 then -- 824
			do -- 824
				local sequenceStack = {} -- 827
				for i = 1, #enode.children do -- 827
					visitAction(sequenceStack, enode.children[i]) -- 829
				end -- 829
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 831
				break -- 832
			end -- 832
		end -- 832
		do -- 832
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 835
			break -- 836
		end -- 836
	until true -- 836
end -- 783
local function actionCheck(nodeStack, enode, parent) -- 840
	local unsupported = false -- 841
	if parent == nil then -- 841
		unsupported = true -- 843
	else -- 843
		repeat -- 843
			local ____switch184 = parent.type -- 843
			local ____cond184 = ____switch184 == "action" or ____switch184 == "spawn" or ____switch184 == "sequence" -- 843
			if ____cond184 then -- 843
				break -- 846
			end -- 846
			do -- 846
				unsupported = true -- 847
				break -- 847
			end -- 847
		until true -- 847
	end -- 847
	if unsupported then -- 847
		if #nodeStack > 0 then -- 847
			local node = nodeStack[#nodeStack] -- 852
			local actionStack = {} -- 853
			visitAction(actionStack, enode) -- 854
			if #actionStack == 1 then -- 854
				node:runAction(actionStack[1]) -- 856
			end -- 856
		else -- 856
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 859
		end -- 859
	end -- 859
end -- 840
local function bodyCheck(_nodeStack, enode, parent) -- 864
	if parent == nil or parent.type ~= "body" then -- 864
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 866
	end -- 866
end -- 864
actionMap = { -- 870
	["anchor-x"] = Dora.AnchorX, -- 873
	["anchor-y"] = Dora.AnchorY, -- 874
	angle = Dora.Angle, -- 875
	["angle-x"] = Dora.AngleX, -- 876
	["angle-y"] = Dora.AngleY, -- 877
	width = Dora.Width, -- 878
	height = Dora.Height, -- 879
	opacity = Dora.Opacity, -- 880
	roll = Dora.Roll, -- 881
	scale = Dora.Scale, -- 882
	["scale-x"] = Dora.ScaleX, -- 883
	["scale-y"] = Dora.ScaleY, -- 884
	["skew-x"] = Dora.SkewX, -- 885
	["skew-y"] = Dora.SkewY, -- 886
	["move-x"] = Dora.X, -- 887
	["move-y"] = Dora.Y, -- 888
	["move-z"] = Dora.Z -- 889
} -- 889
elementMap = { -- 892
	node = function(nodeStack, enode, parent) -- 893
		addChild( -- 894
			nodeStack, -- 894
			getNode(enode), -- 894
			enode -- 894
		) -- 894
	end, -- 893
	["clip-node"] = function(nodeStack, enode, parent) -- 896
		addChild( -- 897
			nodeStack, -- 897
			getClipNode(enode), -- 897
			enode -- 897
		) -- 897
	end, -- 896
	playable = function(nodeStack, enode, parent) -- 899
		local cnode = getPlayable(enode) -- 900
		if cnode ~= nil then -- 900
			addChild(nodeStack, cnode, enode) -- 902
		end -- 902
	end, -- 899
	["dragon-bone"] = function(nodeStack, enode, parent) -- 905
		local cnode = getDragonBone(enode) -- 906
		if cnode ~= nil then -- 906
			addChild(nodeStack, cnode, enode) -- 908
		end -- 908
	end, -- 905
	spine = function(nodeStack, enode, parent) -- 911
		local cnode = getSpine(enode) -- 912
		if cnode ~= nil then -- 912
			addChild(nodeStack, cnode, enode) -- 914
		end -- 914
	end, -- 911
	model = function(nodeStack, enode, parent) -- 917
		local cnode = getModel(enode) -- 918
		if cnode ~= nil then -- 918
			addChild(nodeStack, cnode, enode) -- 920
		end -- 920
	end, -- 917
	["draw-node"] = function(nodeStack, enode, parent) -- 923
		addChild( -- 924
			nodeStack, -- 924
			getDrawNode(enode), -- 924
			enode -- 924
		) -- 924
	end, -- 923
	["dot-shape"] = drawNodeCheck, -- 926
	["segment-shape"] = drawNodeCheck, -- 927
	["rect-shape"] = drawNodeCheck, -- 928
	["polygon-shape"] = drawNodeCheck, -- 929
	["verts-shape"] = drawNodeCheck, -- 930
	grid = function(nodeStack, enode, parent) -- 931
		addChild( -- 932
			nodeStack, -- 932
			getGrid(enode), -- 932
			enode -- 932
		) -- 932
	end, -- 931
	sprite = function(nodeStack, enode, parent) -- 934
		local cnode = getSprite(enode) -- 935
		if cnode ~= nil then -- 935
			addChild(nodeStack, cnode, enode) -- 937
		end -- 937
	end, -- 934
	label = function(nodeStack, enode, parent) -- 940
		local cnode = getLabel(enode) -- 941
		if cnode ~= nil then -- 941
			addChild(nodeStack, cnode, enode) -- 943
		end -- 943
	end, -- 940
	line = function(nodeStack, enode, parent) -- 946
		addChild( -- 947
			nodeStack, -- 947
			getLine(enode), -- 947
			enode -- 947
		) -- 947
	end, -- 946
	particle = function(nodeStack, enode, parent) -- 949
		local cnode = getParticle(enode) -- 950
		if cnode ~= nil then -- 950
			addChild(nodeStack, cnode, enode) -- 952
		end -- 952
	end, -- 949
	menu = function(nodeStack, enode, parent) -- 955
		addChild( -- 956
			nodeStack, -- 956
			getMenu(enode), -- 956
			enode -- 956
		) -- 956
	end, -- 955
	action = function(_nodeStack, enode, parent) -- 958
		if #enode.children == 0 then -- 958
			Warn("<action> tag has no children") -- 960
			return -- 961
		end -- 961
		local action = enode.props -- 963
		if action.ref == nil then -- 963
			Warn("<action> tag has no ref") -- 965
			return -- 966
		end -- 966
		local actionStack = {} -- 968
		for i = 1, #enode.children do -- 968
			visitAction(actionStack, enode.children[i]) -- 970
		end -- 970
		if #actionStack == 1 then -- 970
			action.ref.current = actionStack[1] -- 973
		elseif #actionStack > 1 then -- 973
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 975
		end -- 975
	end, -- 958
	["anchor-x"] = actionCheck, -- 978
	["anchor-y"] = actionCheck, -- 979
	angle = actionCheck, -- 980
	["angle-x"] = actionCheck, -- 981
	["angle-y"] = actionCheck, -- 982
	delay = actionCheck, -- 983
	event = actionCheck, -- 984
	width = actionCheck, -- 985
	height = actionCheck, -- 986
	hide = actionCheck, -- 987
	show = actionCheck, -- 988
	move = actionCheck, -- 989
	opacity = actionCheck, -- 990
	roll = actionCheck, -- 991
	scale = actionCheck, -- 992
	["scale-x"] = actionCheck, -- 993
	["scale-y"] = actionCheck, -- 994
	["skew-x"] = actionCheck, -- 995
	["skew-y"] = actionCheck, -- 996
	["move-x"] = actionCheck, -- 997
	["move-y"] = actionCheck, -- 998
	["move-z"] = actionCheck, -- 999
	frame = actionCheck, -- 1000
	spawn = actionCheck, -- 1001
	sequence = actionCheck, -- 1002
	loop = function(nodeStack, enode, _parent) -- 1003
		if #nodeStack > 0 then -- 1003
			local node = nodeStack[#nodeStack] -- 1005
			local actionStack = {} -- 1006
			for i = 1, #enode.children do -- 1006
				visitAction(actionStack, enode.children[i]) -- 1008
			end -- 1008
			if #actionStack == 1 then -- 1008
				node:runAction(actionStack[1], true) -- 1011
			else -- 1011
				local loop = enode.props -- 1013
				if loop.spawn then -- 1013
					node:runAction( -- 1015
						Dora.Spawn(table.unpack(actionStack)), -- 1015
						true -- 1015
					) -- 1015
				else -- 1015
					node:runAction( -- 1017
						Dora.Sequence(table.unpack(actionStack)), -- 1017
						true -- 1017
					) -- 1017
				end -- 1017
			end -- 1017
		else -- 1017
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1021
		end -- 1021
	end, -- 1003
	["physics-world"] = function(nodeStack, enode, _parent) -- 1024
		addChild( -- 1025
			nodeStack, -- 1025
			getPhysicsWorld(enode), -- 1025
			enode -- 1025
		) -- 1025
	end, -- 1024
	contact = function(nodeStack, enode, _parent) -- 1027
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1028
		if world ~= nil then -- 1028
			local contact = enode.props -- 1030
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1031
		else -- 1031
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1033
		end -- 1033
	end, -- 1027
	body = function(nodeStack, enode, _parent) -- 1036
		local def = enode.props -- 1037
		if def.world then -- 1037
			addChild( -- 1039
				nodeStack, -- 1039
				getBody(enode, def.world), -- 1039
				enode -- 1039
			) -- 1039
			return -- 1040
		end -- 1040
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1042
		if world ~= nil then -- 1042
			addChild( -- 1044
				nodeStack, -- 1044
				getBody(enode, world), -- 1044
				enode -- 1044
			) -- 1044
		else -- 1044
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1046
		end -- 1046
	end, -- 1036
	["rect-fixture"] = bodyCheck, -- 1049
	["polygon-fixture"] = bodyCheck, -- 1050
	["multi-fixture"] = bodyCheck, -- 1051
	["disk-fixture"] = bodyCheck, -- 1052
	["chain-fixture"] = bodyCheck, -- 1053
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1054
		local joint = enode.props -- 1055
		if joint.ref == nil then -- 1055
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1057
			return -- 1058
		end -- 1058
		if joint.bodyA.current == nil then -- 1058
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1061
			return -- 1062
		end -- 1062
		if joint.bodyB.current == nil then -- 1062
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1065
			return -- 1066
		end -- 1066
		local ____joint_ref_14 = joint.ref -- 1068
		local ____self_12 = Dora.Joint -- 1068
		local ____self_12_distance_13 = ____self_12.distance -- 1068
		local ____joint_canCollide_11 = joint.canCollide -- 1069
		if ____joint_canCollide_11 == nil then -- 1069
			____joint_canCollide_11 = false -- 1069
		end -- 1069
		____joint_ref_14.current = ____self_12_distance_13( -- 1068
			____self_12, -- 1068
			____joint_canCollide_11, -- 1069
			joint.bodyA.current, -- 1070
			joint.bodyB.current, -- 1071
			joint.anchorA or Dora.Vec2.zero, -- 1072
			joint.anchorB or Dora.Vec2.zero, -- 1073
			joint.frequency or 0, -- 1074
			joint.damping or 0 -- 1075
		) -- 1075
	end, -- 1054
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1077
		local joint = enode.props -- 1078
		if joint.ref == nil then -- 1078
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1080
			return -- 1081
		end -- 1081
		if joint.bodyA.current == nil then -- 1081
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1084
			return -- 1085
		end -- 1085
		if joint.bodyB.current == nil then -- 1085
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1088
			return -- 1089
		end -- 1089
		local ____joint_ref_18 = joint.ref -- 1091
		local ____self_16 = Dora.Joint -- 1091
		local ____self_16_friction_17 = ____self_16.friction -- 1091
		local ____joint_canCollide_15 = joint.canCollide -- 1092
		if ____joint_canCollide_15 == nil then -- 1092
			____joint_canCollide_15 = false -- 1092
		end -- 1092
		____joint_ref_18.current = ____self_16_friction_17( -- 1091
			____self_16, -- 1091
			____joint_canCollide_15, -- 1092
			joint.bodyA.current, -- 1093
			joint.bodyB.current, -- 1094
			joint.worldPos, -- 1095
			joint.maxForce, -- 1096
			joint.maxTorque -- 1097
		) -- 1097
	end, -- 1077
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1100
		local joint = enode.props -- 1101
		if joint.ref == nil then -- 1101
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1103
			return -- 1104
		end -- 1104
		if joint.jointA.current == nil then -- 1104
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1107
			return -- 1108
		end -- 1108
		if joint.jointB.current == nil then -- 1108
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1111
			return -- 1112
		end -- 1112
		local ____joint_ref_22 = joint.ref -- 1114
		local ____self_20 = Dora.Joint -- 1114
		local ____self_20_gear_21 = ____self_20.gear -- 1114
		local ____joint_canCollide_19 = joint.canCollide -- 1115
		if ____joint_canCollide_19 == nil then -- 1115
			____joint_canCollide_19 = false -- 1115
		end -- 1115
		____joint_ref_22.current = ____self_20_gear_21( -- 1114
			____self_20, -- 1114
			____joint_canCollide_19, -- 1115
			joint.jointA.current, -- 1116
			joint.jointB.current, -- 1117
			joint.ratio or 1 -- 1118
		) -- 1118
	end, -- 1100
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1121
		local joint = enode.props -- 1122
		if joint.ref == nil then -- 1122
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1124
			return -- 1125
		end -- 1125
		if joint.bodyA.current == nil then -- 1125
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1128
			return -- 1129
		end -- 1129
		if joint.bodyB.current == nil then -- 1129
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1132
			return -- 1133
		end -- 1133
		local ____joint_ref_26 = joint.ref -- 1135
		local ____self_24 = Dora.Joint -- 1135
		local ____self_24_spring_25 = ____self_24.spring -- 1135
		local ____joint_canCollide_23 = joint.canCollide -- 1136
		if ____joint_canCollide_23 == nil then -- 1136
			____joint_canCollide_23 = false -- 1136
		end -- 1136
		____joint_ref_26.current = ____self_24_spring_25( -- 1135
			____self_24, -- 1135
			____joint_canCollide_23, -- 1136
			joint.bodyA.current, -- 1137
			joint.bodyB.current, -- 1138
			joint.linearOffset, -- 1139
			joint.angularOffset, -- 1140
			joint.maxForce, -- 1141
			joint.maxTorque, -- 1142
			joint.correctionFactor or 1 -- 1143
		) -- 1143
	end, -- 1121
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1146
		local joint = enode.props -- 1147
		if joint.ref == nil then -- 1147
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1149
			return -- 1150
		end -- 1150
		if joint.body.current == nil then -- 1150
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1153
			return -- 1154
		end -- 1154
		local ____joint_ref_30 = joint.ref -- 1156
		local ____self_28 = Dora.Joint -- 1156
		local ____self_28_move_29 = ____self_28.move -- 1156
		local ____joint_canCollide_27 = joint.canCollide -- 1157
		if ____joint_canCollide_27 == nil then -- 1157
			____joint_canCollide_27 = false -- 1157
		end -- 1157
		____joint_ref_30.current = ____self_28_move_29( -- 1156
			____self_28, -- 1156
			____joint_canCollide_27, -- 1157
			joint.body.current, -- 1158
			joint.targetPos, -- 1159
			joint.maxForce, -- 1160
			joint.frequency, -- 1161
			joint.damping or 0.7 -- 1162
		) -- 1162
	end, -- 1146
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1165
		local joint = enode.props -- 1166
		if joint.ref == nil then -- 1166
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1168
			return -- 1169
		end -- 1169
		if joint.bodyA.current == nil then -- 1169
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1172
			return -- 1173
		end -- 1173
		if joint.bodyB.current == nil then -- 1173
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1176
			return -- 1177
		end -- 1177
		local ____joint_ref_34 = joint.ref -- 1179
		local ____self_32 = Dora.Joint -- 1179
		local ____self_32_prismatic_33 = ____self_32.prismatic -- 1179
		local ____joint_canCollide_31 = joint.canCollide -- 1180
		if ____joint_canCollide_31 == nil then -- 1180
			____joint_canCollide_31 = false -- 1180
		end -- 1180
		____joint_ref_34.current = ____self_32_prismatic_33( -- 1179
			____self_32, -- 1179
			____joint_canCollide_31, -- 1180
			joint.bodyA.current, -- 1181
			joint.bodyB.current, -- 1182
			joint.worldPos, -- 1183
			joint.axisAngle, -- 1184
			joint.lowerTranslation or 0, -- 1185
			joint.upperTranslation or 0, -- 1186
			joint.maxMotorForce or 0, -- 1187
			joint.motorSpeed or 0 -- 1188
		) -- 1188
	end, -- 1165
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1191
		local joint = enode.props -- 1192
		if joint.ref == nil then -- 1192
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1194
			return -- 1195
		end -- 1195
		if joint.bodyA.current == nil then -- 1195
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1198
			return -- 1199
		end -- 1199
		if joint.bodyB.current == nil then -- 1199
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1202
			return -- 1203
		end -- 1203
		local ____joint_ref_38 = joint.ref -- 1205
		local ____self_36 = Dora.Joint -- 1205
		local ____self_36_pulley_37 = ____self_36.pulley -- 1205
		local ____joint_canCollide_35 = joint.canCollide -- 1206
		if ____joint_canCollide_35 == nil then -- 1206
			____joint_canCollide_35 = false -- 1206
		end -- 1206
		____joint_ref_38.current = ____self_36_pulley_37( -- 1205
			____self_36, -- 1205
			____joint_canCollide_35, -- 1206
			joint.bodyA.current, -- 1207
			joint.bodyB.current, -- 1208
			joint.anchorA or Dora.Vec2.zero, -- 1209
			joint.anchorB or Dora.Vec2.zero, -- 1210
			joint.groundAnchorA, -- 1211
			joint.groundAnchorB, -- 1212
			joint.ratio or 1 -- 1213
		) -- 1213
	end, -- 1191
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1216
		local joint = enode.props -- 1217
		if joint.ref == nil then -- 1217
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1219
			return -- 1220
		end -- 1220
		if joint.bodyA.current == nil then -- 1220
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1223
			return -- 1224
		end -- 1224
		if joint.bodyB.current == nil then -- 1224
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1227
			return -- 1228
		end -- 1228
		local ____joint_ref_42 = joint.ref -- 1230
		local ____self_40 = Dora.Joint -- 1230
		local ____self_40_revolute_41 = ____self_40.revolute -- 1230
		local ____joint_canCollide_39 = joint.canCollide -- 1231
		if ____joint_canCollide_39 == nil then -- 1231
			____joint_canCollide_39 = false -- 1231
		end -- 1231
		____joint_ref_42.current = ____self_40_revolute_41( -- 1230
			____self_40, -- 1230
			____joint_canCollide_39, -- 1231
			joint.bodyA.current, -- 1232
			joint.bodyB.current, -- 1233
			joint.worldPos, -- 1234
			joint.lowerAngle or 0, -- 1235
			joint.upperAngle or 0, -- 1236
			joint.maxMotorTorque or 0, -- 1237
			joint.motorSpeed or 0 -- 1238
		) -- 1238
	end, -- 1216
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1241
		local joint = enode.props -- 1242
		if joint.ref == nil then -- 1242
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1244
			return -- 1245
		end -- 1245
		if joint.bodyA.current == nil then -- 1245
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1248
			return -- 1249
		end -- 1249
		if joint.bodyB.current == nil then -- 1249
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1252
			return -- 1253
		end -- 1253
		local ____joint_ref_46 = joint.ref -- 1255
		local ____self_44 = Dora.Joint -- 1255
		local ____self_44_rope_45 = ____self_44.rope -- 1255
		local ____joint_canCollide_43 = joint.canCollide -- 1256
		if ____joint_canCollide_43 == nil then -- 1256
			____joint_canCollide_43 = false -- 1256
		end -- 1256
		____joint_ref_46.current = ____self_44_rope_45( -- 1255
			____self_44, -- 1255
			____joint_canCollide_43, -- 1256
			joint.bodyA.current, -- 1257
			joint.bodyB.current, -- 1258
			joint.anchorA or Dora.Vec2.zero, -- 1259
			joint.anchorB or Dora.Vec2.zero, -- 1260
			joint.maxLength or 0 -- 1261
		) -- 1261
	end, -- 1241
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1264
		local joint = enode.props -- 1265
		if joint.ref == nil then -- 1265
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1267
			return -- 1268
		end -- 1268
		if joint.bodyA.current == nil then -- 1268
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1271
			return -- 1272
		end -- 1272
		if joint.bodyB.current == nil then -- 1272
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1275
			return -- 1276
		end -- 1276
		local ____joint_ref_50 = joint.ref -- 1278
		local ____self_48 = Dora.Joint -- 1278
		local ____self_48_weld_49 = ____self_48.weld -- 1278
		local ____joint_canCollide_47 = joint.canCollide -- 1279
		if ____joint_canCollide_47 == nil then -- 1279
			____joint_canCollide_47 = false -- 1279
		end -- 1279
		____joint_ref_50.current = ____self_48_weld_49( -- 1278
			____self_48, -- 1278
			____joint_canCollide_47, -- 1279
			joint.bodyA.current, -- 1280
			joint.bodyB.current, -- 1281
			joint.worldPos, -- 1282
			joint.frequency or 0, -- 1283
			joint.damping or 0 -- 1284
		) -- 1284
	end, -- 1264
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1287
		local joint = enode.props -- 1288
		if joint.ref == nil then -- 1288
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1290
			return -- 1291
		end -- 1291
		if joint.bodyA.current == nil then -- 1291
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1294
			return -- 1295
		end -- 1295
		if joint.bodyB.current == nil then -- 1295
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1298
			return -- 1299
		end -- 1299
		local ____joint_ref_54 = joint.ref -- 1301
		local ____self_52 = Dora.Joint -- 1301
		local ____self_52_wheel_53 = ____self_52.wheel -- 1301
		local ____joint_canCollide_51 = joint.canCollide -- 1302
		if ____joint_canCollide_51 == nil then -- 1302
			____joint_canCollide_51 = false -- 1302
		end -- 1302
		____joint_ref_54.current = ____self_52_wheel_53( -- 1301
			____self_52, -- 1301
			____joint_canCollide_51, -- 1302
			joint.bodyA.current, -- 1303
			joint.bodyB.current, -- 1304
			joint.worldPos, -- 1305
			joint.axisAngle, -- 1306
			joint.maxMotorTorque or 0, -- 1307
			joint.motorSpeed or 0, -- 1308
			joint.frequency or 0, -- 1309
			joint.damping or 0.7 -- 1310
		) -- 1310
	end, -- 1287
	["custom-node"] = function(nodeStack, enode, _parent) -- 1313
		local node = getCustomNode(enode) -- 1314
		if node ~= nil then -- 1314
			addChild(nodeStack, node, enode) -- 1316
		end -- 1316
	end, -- 1313
	["custom-element"] = function() -- 1319
	end, -- 1319
	["align-node"] = function(nodeStack, enode, _parent) -- 1320
		addChild( -- 1321
			nodeStack, -- 1321
			getAlignNode(enode), -- 1321
			enode -- 1321
		) -- 1321
	end, -- 1320
	["effek-node"] = function(nodeStack, enode, _parent) -- 1323
		addChild( -- 1324
			nodeStack, -- 1324
			getEffekNode(enode), -- 1324
			enode -- 1324
		) -- 1324
	end, -- 1323
	effek = function(nodeStack, enode, parent) -- 1326
		if #nodeStack > 0 then -- 1326
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1328
			if node then -- 1328
				local effek = enode.props -- 1330
				local handle = node:play( -- 1331
					effek.file, -- 1331
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1331
					effek.z or 0 -- 1331
				) -- 1331
				if handle >= 0 then -- 1331
					if effek.ref then -- 1331
						effek.ref.current = handle -- 1334
					end -- 1334
					if effek.onEnd then -- 1334
						local onEnd = effek.onEnd -- 1334
						node:slot( -- 1338
							"EffekEnd", -- 1338
							function(h) -- 1338
								if handle == h then -- 1338
									onEnd(nil) -- 1340
								end -- 1340
							end -- 1338
						) -- 1338
					end -- 1338
				end -- 1338
			else -- 1338
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1346
			end -- 1346
		end -- 1346
	end, -- 1326
	["tile-node"] = function(nodeStack, enode, parent) -- 1350
		local cnode = getTileNode(enode) -- 1351
		if cnode ~= nil then -- 1351
			addChild(nodeStack, cnode, enode) -- 1353
		end -- 1353
	end -- 1350
} -- 1350
function ____exports.useRef(item) -- 1398
	local ____item_55 = item -- 1399
	if ____item_55 == nil then -- 1399
		____item_55 = nil -- 1399
	end -- 1399
	return {current = ____item_55} -- 1399
end -- 1398
local function getPreload(preloadList, node) -- 1402
	if type(node) ~= "table" then -- 1402
		return -- 1404
	end -- 1404
	local enode = node -- 1406
	if enode.type == nil then -- 1406
		local list = node -- 1408
		if #list > 0 then -- 1408
			for i = 1, #list do -- 1408
				getPreload(preloadList, list[i]) -- 1411
			end -- 1411
		end -- 1411
	else -- 1411
		repeat -- 1411
			local ____switch312 = enode.type -- 1411
			local sprite, playable, frame, model, spine, dragonBone, label -- 1411
			local ____cond312 = ____switch312 == "sprite" -- 1411
			if ____cond312 then -- 1411
				sprite = enode.props -- 1417
				if sprite.file then -- 1417
					preloadList[#preloadList + 1] = sprite.file -- 1419
				end -- 1419
				break -- 1421
			end -- 1421
			____cond312 = ____cond312 or ____switch312 == "playable" -- 1421
			if ____cond312 then -- 1421
				playable = enode.props -- 1423
				preloadList[#preloadList + 1] = playable.file -- 1424
				break -- 1425
			end -- 1425
			____cond312 = ____cond312 or ____switch312 == "frame" -- 1425
			if ____cond312 then -- 1425
				frame = enode.props -- 1427
				preloadList[#preloadList + 1] = frame.file -- 1428
				break -- 1429
			end -- 1429
			____cond312 = ____cond312 or ____switch312 == "model" -- 1429
			if ____cond312 then -- 1429
				model = enode.props -- 1431
				preloadList[#preloadList + 1] = "model:" .. model.file -- 1432
				break -- 1433
			end -- 1433
			____cond312 = ____cond312 or ____switch312 == "spine" -- 1433
			if ____cond312 then -- 1433
				spine = enode.props -- 1435
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1436
				break -- 1437
			end -- 1437
			____cond312 = ____cond312 or ____switch312 == "dragon-bone" -- 1437
			if ____cond312 then -- 1437
				dragonBone = enode.props -- 1439
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1440
				break -- 1441
			end -- 1441
			____cond312 = ____cond312 or ____switch312 == "label" -- 1441
			if ____cond312 then -- 1441
				label = enode.props -- 1443
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1444
				break -- 1445
			end -- 1445
		until true -- 1445
	end -- 1445
	getPreload(preloadList, enode.children) -- 1448
end -- 1402
function ____exports.preloadAsync(enode, handler) -- 1451
	local preloadList = {} -- 1452
	getPreload(preloadList, enode) -- 1453
	Dora.Cache:loadAsync(preloadList, handler) -- 1454
end -- 1451
function ____exports.toAction(enode) -- 1457
	local actionDef = ____exports.useRef() -- 1458
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 1459
	if not actionDef.current then -- 1459
		error("failed to create action") -- 1460
	end -- 1460
	return actionDef.current -- 1461
end -- 1457
return ____exports -- 1457