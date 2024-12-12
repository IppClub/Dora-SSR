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
function visitNode(nodeStack, node, parent) -- 1363
	if type(node) ~= "table" then -- 1363
		return -- 1365
	end -- 1365
	local enode = node -- 1367
	if enode.type == nil then -- 1367
		local list = node -- 1369
		if #list > 0 then -- 1369
			for i = 1, #list do -- 1369
				local stack = {} -- 1372
				visitNode(stack, list[i], parent) -- 1373
				for i = 1, #stack do -- 1373
					nodeStack[#nodeStack + 1] = stack[i] -- 1375
				end -- 1375
			end -- 1375
		end -- 1375
	else -- 1375
		local handler = elementMap[enode.type] -- 1380
		if handler ~= nil then -- 1380
			handler(nodeStack, enode, parent) -- 1382
		else -- 1382
			Warn(("unsupported tag <" .. enode.type) .. ">") -- 1384
		end -- 1384
	end -- 1384
end -- 1384
function ____exports.toNode(enode) -- 1389
	local nodeStack = {} -- 1390
	visitNode(nodeStack, enode) -- 1391
	if #nodeStack == 1 then -- 1391
		return nodeStack[1] -- 1393
	elseif #nodeStack > 1 then -- 1393
		local node = Dora.Node() -- 1395
		for i = 1, #nodeStack do -- 1395
			node:addChild(nodeStack[i]) -- 1397
		end -- 1397
		return node -- 1399
	end -- 1399
	return nil -- 1401
end -- 1389
____exports.React = {} -- 1389
local React = ____exports.React -- 1389
do -- 1389
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
			local ____cond89 = ____switch89 == "fontName" or ____switch89 == "fontSize" or ____switch89 == "text" or ____switch89 == "smoothLower" or ____switch89 == "smoothUpper" -- 422
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
			____cond89 = ____cond89 or ____switch89 == "outlineColor" -- 428
			if ____cond89 then -- 428
				cnode.outlineColor = Dora.Color(v) -- 429
				return true -- 429
			end -- 429
			____cond89 = ____cond89 or ____switch89 == "outlineWidth" -- 429
			if ____cond89 then -- 429
				cnode.outlineWidth = v -- 430
				return true -- 430
			end -- 430
			____cond89 = ____cond89 or ____switch89 == "blendFunc" -- 430
			if ____cond89 then -- 430
				cnode.blendFunc = v -- 431
				return true -- 431
			end -- 431
			____cond89 = ____cond89 or ____switch89 == "depthWrite" -- 431
			if ____cond89 then -- 431
				cnode.depthWrite = v -- 432
				return true -- 432
			end -- 432
			____cond89 = ____cond89 or ____switch89 == "batched" -- 432
			if ____cond89 then -- 432
				cnode.batched = v -- 433
				return true -- 433
			end -- 433
			____cond89 = ____cond89 or ____switch89 == "effect" -- 433
			if ____cond89 then -- 433
				cnode.effect = v -- 434
				return true -- 434
			end -- 434
			____cond89 = ____cond89 or ____switch89 == "alignment" -- 434
			if ____cond89 then -- 434
				cnode.alignment = v -- 435
				return true -- 435
			end -- 435
		until true -- 435
		return false -- 437
	end -- 422
	getLabel = function(enode) -- 439
		local label = enode.props -- 440
		local node = Dora.Label(label.fontName, label.fontSize, label.sdf) -- 441
		if node ~= nil then -- 441
			if label.smoothLower ~= nil or label.smoothUpper ~= nil then -- 441
				local ____node_smooth_8 = node.smooth -- 444
				local x = ____node_smooth_8.x -- 444
				local y = ____node_smooth_8.y -- 444
				node.smooth = Dora.Vec2(label.smoothLower or x, label.smoothUpper or y) -- 445
			end -- 445
			local cnode = getNode(enode, node, handleLabelAttribute) -- 447
			local ____enode_9 = enode -- 448
			local children = ____enode_9.children -- 448
			local text = label.text or "" -- 449
			for i = 1, #children do -- 449
				local child = children[i] -- 451
				if type(child) ~= "table" then -- 451
					text = text .. tostring(child) -- 453
				end -- 453
			end -- 453
			node.text = text -- 456
			return cnode -- 457
		end -- 457
		return nil -- 459
	end -- 439
end -- 439
local getLine -- 463
do -- 463
	local function handleLineAttribute(cnode, enode, k, v) -- 465
		local line = enode.props -- 466
		repeat -- 466
			local ____switch97 = k -- 466
			local ____cond97 = ____switch97 == "verts" -- 466
			if ____cond97 then -- 466
				cnode:set( -- 468
					v, -- 468
					Dora.Color(line.lineColor or 4294967295) -- 468
				) -- 468
				return true -- 468
			end -- 468
			____cond97 = ____cond97 or ____switch97 == "depthWrite" -- 468
			if ____cond97 then -- 468
				cnode.depthWrite = v -- 469
				return true -- 469
			end -- 469
			____cond97 = ____cond97 or ____switch97 == "blendFunc" -- 469
			if ____cond97 then -- 469
				cnode.blendFunc = v -- 470
				return true -- 470
			end -- 470
		until true -- 470
		return false -- 472
	end -- 465
	getLine = function(enode) -- 474
		local node = Dora.Line() -- 475
		local cnode = getNode(enode, node, handleLineAttribute) -- 476
		return cnode -- 477
	end -- 474
end -- 474
local getParticle -- 481
do -- 481
	local function handleParticleAttribute(cnode, _enode, k, v) -- 483
		repeat -- 483
			local ____switch101 = k -- 483
			local ____cond101 = ____switch101 == "file" -- 483
			if ____cond101 then -- 483
				return true -- 485
			end -- 485
			____cond101 = ____cond101 or ____switch101 == "emit" -- 485
			if ____cond101 then -- 485
				if v then -- 485
					cnode:start() -- 486
				end -- 486
				return true -- 486
			end -- 486
			____cond101 = ____cond101 or ____switch101 == "onFinished" -- 486
			if ____cond101 then -- 486
				cnode:slot("Finished", v) -- 487
				return true -- 487
			end -- 487
		until true -- 487
		return false -- 489
	end -- 483
	getParticle = function(enode) -- 491
		local particle = enode.props -- 492
		local node = Dora.Particle(particle.file) -- 493
		if node ~= nil then -- 493
			local cnode = getNode(enode, node, handleParticleAttribute) -- 495
			return cnode -- 496
		end -- 496
		return nil -- 498
	end -- 491
end -- 491
local getMenu -- 502
do -- 502
	local function handleMenuAttribute(cnode, _enode, k, v) -- 504
		repeat -- 504
			local ____switch107 = k -- 504
			local ____cond107 = ____switch107 == "enabled" -- 504
			if ____cond107 then -- 504
				cnode.enabled = v -- 506
				return true -- 506
			end -- 506
		until true -- 506
		return false -- 508
	end -- 504
	getMenu = function(enode) -- 510
		local node = Dora.Menu() -- 511
		local cnode = getNode(enode, node, handleMenuAttribute) -- 512
		return cnode -- 513
	end -- 510
end -- 510
local function getPhysicsWorld(enode) -- 517
	local node = Dora.PhysicsWorld() -- 518
	local cnode = getNode(enode, node) -- 519
	return cnode -- 520
end -- 517
local getBody -- 523
do -- 523
	local function handleBodyAttribute(cnode, _enode, k, v) -- 525
		repeat -- 525
			local ____switch112 = k -- 525
			local ____cond112 = ____switch112 == "type" or ____switch112 == "linearAcceleration" or ____switch112 == "fixedRotation" or ____switch112 == "bullet" or ____switch112 == "world" -- 525
			if ____cond112 then -- 525
				return true -- 532
			end -- 532
			____cond112 = ____cond112 or ____switch112 == "velocityX" -- 532
			if ____cond112 then -- 532
				cnode.velocityX = v -- 533
				return true -- 533
			end -- 533
			____cond112 = ____cond112 or ____switch112 == "velocityY" -- 533
			if ____cond112 then -- 533
				cnode.velocityY = v -- 534
				return true -- 534
			end -- 534
			____cond112 = ____cond112 or ____switch112 == "angularRate" -- 534
			if ____cond112 then -- 534
				cnode.angularRate = v -- 535
				return true -- 535
			end -- 535
			____cond112 = ____cond112 or ____switch112 == "group" -- 535
			if ____cond112 then -- 535
				cnode.group = v -- 536
				return true -- 536
			end -- 536
			____cond112 = ____cond112 or ____switch112 == "linearDamping" -- 536
			if ____cond112 then -- 536
				cnode.linearDamping = v -- 537
				return true -- 537
			end -- 537
			____cond112 = ____cond112 or ____switch112 == "angularDamping" -- 537
			if ____cond112 then -- 537
				cnode.angularDamping = v -- 538
				return true -- 538
			end -- 538
			____cond112 = ____cond112 or ____switch112 == "owner" -- 538
			if ____cond112 then -- 538
				cnode.owner = v -- 539
				return true -- 539
			end -- 539
			____cond112 = ____cond112 or ____switch112 == "receivingContact" -- 539
			if ____cond112 then -- 539
				cnode.receivingContact = v -- 540
				return true -- 540
			end -- 540
			____cond112 = ____cond112 or ____switch112 == "onBodyEnter" -- 540
			if ____cond112 then -- 540
				cnode:slot("BodyEnter", v) -- 541
				return true -- 541
			end -- 541
			____cond112 = ____cond112 or ____switch112 == "onBodyLeave" -- 541
			if ____cond112 then -- 541
				cnode:slot("BodyLeave", v) -- 542
				return true -- 542
			end -- 542
			____cond112 = ____cond112 or ____switch112 == "onContactStart" -- 542
			if ____cond112 then -- 542
				cnode:slot("ContactStart", v) -- 543
				return true -- 543
			end -- 543
			____cond112 = ____cond112 or ____switch112 == "onContactEnd" -- 543
			if ____cond112 then -- 543
				cnode:slot("ContactEnd", v) -- 544
				return true -- 544
			end -- 544
			____cond112 = ____cond112 or ____switch112 == "onContactFilter" -- 544
			if ____cond112 then -- 544
				cnode:onContactFilter(v) -- 545
				return true -- 545
			end -- 545
		until true -- 545
		return false -- 547
	end -- 525
	getBody = function(enode, world) -- 549
		local def = enode.props -- 550
		local bodyDef = Dora.BodyDef() -- 551
		bodyDef.type = def.type -- 552
		if def.angle ~= nil then -- 552
			bodyDef.angle = def.angle -- 553
		end -- 553
		if def.angularDamping ~= nil then -- 553
			bodyDef.angularDamping = def.angularDamping -- 554
		end -- 554
		if def.bullet ~= nil then -- 554
			bodyDef.bullet = def.bullet -- 555
		end -- 555
		if def.fixedRotation ~= nil then -- 555
			bodyDef.fixedRotation = def.fixedRotation -- 556
		end -- 556
		bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 557
		if def.linearDamping ~= nil then -- 557
			bodyDef.linearDamping = def.linearDamping -- 558
		end -- 558
		bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 559
		local extraSensors = nil -- 560
		for i = 1, #enode.children do -- 560
			do -- 560
				local child = enode.children[i] -- 562
				if type(child) ~= "table" then -- 562
					goto __continue119 -- 564
				end -- 564
				repeat -- 564
					local ____switch121 = child.type -- 564
					local ____cond121 = ____switch121 == "rect-fixture" -- 564
					if ____cond121 then -- 564
						do -- 564
							local shape = child.props -- 568
							if shape.sensorTag ~= nil then -- 568
								bodyDef:attachPolygonSensor( -- 570
									shape.sensorTag, -- 571
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 572
									shape.width, -- 573
									shape.height, -- 573
									shape.angle or 0 -- 574
								) -- 574
							else -- 574
								bodyDef:attachPolygon( -- 577
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 578
									shape.width, -- 579
									shape.height, -- 579
									shape.angle or 0, -- 580
									shape.density or 1, -- 581
									shape.friction or 0.4, -- 582
									shape.restitution or 0 -- 583
								) -- 583
							end -- 583
							break -- 586
						end -- 586
					end -- 586
					____cond121 = ____cond121 or ____switch121 == "polygon-fixture" -- 586
					if ____cond121 then -- 586
						do -- 586
							local shape = child.props -- 589
							if shape.sensorTag ~= nil then -- 589
								bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 591
							else -- 591
								bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 596
							end -- 596
							break -- 603
						end -- 603
					end -- 603
					____cond121 = ____cond121 or ____switch121 == "multi-fixture" -- 603
					if ____cond121 then -- 603
						do -- 603
							local shape = child.props -- 606
							if shape.sensorTag ~= nil then -- 606
								if extraSensors == nil then -- 606
									extraSensors = {} -- 608
								end -- 608
								extraSensors[#extraSensors + 1] = { -- 609
									shape.sensorTag, -- 609
									Dora.BodyDef:multi(shape.verts) -- 609
								} -- 609
							else -- 609
								bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 611
							end -- 611
							break -- 618
						end -- 618
					end -- 618
					____cond121 = ____cond121 or ____switch121 == "disk-fixture" -- 618
					if ____cond121 then -- 618
						do -- 618
							local shape = child.props -- 621
							if shape.sensorTag ~= nil then -- 621
								bodyDef:attachDiskSensor( -- 623
									shape.sensorTag, -- 624
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 625
									shape.radius -- 626
								) -- 626
							else -- 626
								bodyDef:attachDisk( -- 629
									Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 630
									shape.radius, -- 631
									shape.density or 1, -- 632
									shape.friction or 0.4, -- 633
									shape.restitution or 0 -- 634
								) -- 634
							end -- 634
							break -- 637
						end -- 637
					end -- 637
					____cond121 = ____cond121 or ____switch121 == "chain-fixture" -- 637
					if ____cond121 then -- 637
						do -- 637
							local shape = child.props -- 640
							if shape.sensorTag ~= nil then -- 640
								if extraSensors == nil then -- 640
									extraSensors = {} -- 642
								end -- 642
								extraSensors[#extraSensors + 1] = { -- 643
									shape.sensorTag, -- 643
									Dora.BodyDef:chain(shape.verts) -- 643
								} -- 643
							else -- 643
								bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 645
							end -- 645
							break -- 651
						end -- 651
					end -- 651
				until true -- 651
			end -- 651
			::__continue119:: -- 651
		end -- 651
		local body = Dora.Body(bodyDef, world) -- 655
		if extraSensors ~= nil then -- 655
			for i = 1, #extraSensors do -- 655
				local tag, def = table.unpack(extraSensors[i]) -- 658
				body:attachSensor(tag, def) -- 659
			end -- 659
		end -- 659
		local cnode = getNode(enode, body, handleBodyAttribute) -- 662
		if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 662
			body.receivingContact = true -- 667
		end -- 667
		return cnode -- 669
	end -- 549
end -- 549
local getCustomNode -- 673
do -- 673
	local function handleCustomNode(_cnode, _enode, k, _v) -- 675
		repeat -- 675
			local ____switch142 = k -- 675
			local ____cond142 = ____switch142 == "onCreate" -- 675
			if ____cond142 then -- 675
				return true -- 677
			end -- 677
		until true -- 677
		return false -- 679
	end -- 675
	getCustomNode = function(enode) -- 681
		local custom = enode.props -- 682
		local node = custom.onCreate() -- 683
		if node then -- 683
			local cnode = getNode(enode, node, handleCustomNode) -- 685
			return cnode -- 686
		end -- 686
		return nil -- 688
	end -- 681
end -- 681
local getAlignNode -- 692
do -- 692
	local function handleAlignNode(_cnode, _enode, k, _v) -- 694
		repeat -- 694
			local ____switch147 = k -- 694
			local ____cond147 = ____switch147 == "windowRoot" -- 694
			if ____cond147 then -- 694
				return true -- 696
			end -- 696
			____cond147 = ____cond147 or ____switch147 == "style" -- 696
			if ____cond147 then -- 696
				return true -- 697
			end -- 697
			____cond147 = ____cond147 or ____switch147 == "onLayout" -- 697
			if ____cond147 then -- 697
				return true -- 698
			end -- 698
		until true -- 698
		return false -- 700
	end -- 694
	getAlignNode = function(enode) -- 702
		local alignNode = enode.props -- 703
		local node = Dora.AlignNode(alignNode.windowRoot) -- 704
		if alignNode.style then -- 704
			local items = {} -- 706
			for k, v in pairs(alignNode.style) do -- 707
				local name = string.gsub(k, "%u", "-%1") -- 708
				name = string.lower(name) -- 709
				repeat -- 709
					local ____switch151 = k -- 709
					local ____cond151 = ____switch151 == "margin" or ____switch151 == "padding" or ____switch151 == "border" or ____switch151 == "gap" -- 709
					if ____cond151 then -- 709
						do -- 709
							if type(v) == "table" then -- 709
								local valueStr = table.concat( -- 714
									__TS__ArrayMap( -- 714
										v, -- 714
										function(____, item) return tostring(item) end -- 714
									), -- 714
									"," -- 714
								) -- 714
								items[#items + 1] = (name .. ":") .. valueStr -- 715
							else -- 715
								items[#items + 1] = (name .. ":") .. tostring(v) -- 717
							end -- 717
							break -- 719
						end -- 719
					end -- 719
					do -- 719
						items[#items + 1] = (name .. ":") .. tostring(v) -- 722
						break -- 723
					end -- 723
				until true -- 723
			end -- 723
			local styleStr = table.concat(items, ";") -- 726
			node:css(styleStr) -- 727
		end -- 727
		if alignNode.onLayout then -- 727
			node:slot("AlignLayout", alignNode.onLayout) -- 730
		end -- 730
		local cnode = getNode(enode, node, handleAlignNode) -- 732
		return cnode -- 733
	end -- 702
end -- 702
local function getEffekNode(enode) -- 737
	return getNode( -- 738
		enode, -- 738
		Dora.EffekNode() -- 738
	) -- 738
end -- 737
local getTileNode -- 741
do -- 741
	local function handleTileNodeAttribute(cnode, _enode, k, v) -- 743
		repeat -- 743
			local ____switch160 = k -- 743
			local ____cond160 = ____switch160 == "file" or ____switch160 == "layers" -- 743
			if ____cond160 then -- 743
				return true -- 745
			end -- 745
			____cond160 = ____cond160 or ____switch160 == "depthWrite" -- 745
			if ____cond160 then -- 745
				cnode.depthWrite = v -- 746
				return true -- 746
			end -- 746
			____cond160 = ____cond160 or ____switch160 == "blendFunc" -- 746
			if ____cond160 then -- 746
				cnode.blendFunc = v -- 747
				return true -- 747
			end -- 747
			____cond160 = ____cond160 or ____switch160 == "effect" -- 747
			if ____cond160 then -- 747
				cnode.effect = v -- 748
				return true -- 748
			end -- 748
			____cond160 = ____cond160 or ____switch160 == "filter" -- 748
			if ____cond160 then -- 748
				cnode.filter = v -- 749
				return true -- 749
			end -- 749
		until true -- 749
		return false -- 751
	end -- 743
	getTileNode = function(enode) -- 753
		local tn = enode.props -- 754
		local ____tn_layers_10 -- 755
		if tn.layers then -- 755
			____tn_layers_10 = Dora.TileNode(tn.file, tn.layers) -- 755
		else -- 755
			____tn_layers_10 = Dora.TileNode(tn.file) -- 755
		end -- 755
		local node = ____tn_layers_10 -- 755
		if node ~= nil then -- 755
			local cnode = getNode(enode, node, handleTileNodeAttribute) -- 757
			return cnode -- 758
		end -- 758
		return nil -- 760
	end -- 753
end -- 753
local function addChild(nodeStack, cnode, enode) -- 764
	if #nodeStack > 0 then -- 764
		local last = nodeStack[#nodeStack] -- 766
		last:addChild(cnode) -- 767
	end -- 767
	nodeStack[#nodeStack + 1] = cnode -- 769
	local ____enode_11 = enode -- 770
	local children = ____enode_11.children -- 770
	for i = 1, #children do -- 770
		visitNode(nodeStack, children[i], enode) -- 772
	end -- 772
	if #nodeStack > 1 then -- 772
		table.remove(nodeStack) -- 775
	end -- 775
end -- 764
local function drawNodeCheck(_nodeStack, enode, parent) -- 783
	if parent == nil or parent.type ~= "draw-node" then -- 783
		Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 785
	end -- 785
end -- 783
local function visitAction(actionStack, enode) -- 789
	local createAction = actionMap[enode.type] -- 790
	if createAction ~= nil then -- 790
		actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 792
		return -- 793
	end -- 793
	repeat -- 793
		local ____switch171 = enode.type -- 793
		local ____cond171 = ____switch171 == "delay" -- 793
		if ____cond171 then -- 793
			do -- 793
				local item = enode.props -- 797
				actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 798
				break -- 799
			end -- 799
		end -- 799
		____cond171 = ____cond171 or ____switch171 == "event" -- 799
		if ____cond171 then -- 799
			do -- 799
				local item = enode.props -- 802
				actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 803
				break -- 804
			end -- 804
		end -- 804
		____cond171 = ____cond171 or ____switch171 == "hide" -- 804
		if ____cond171 then -- 804
			do -- 804
				actionStack[#actionStack + 1] = Dora.Hide() -- 807
				break -- 808
			end -- 808
		end -- 808
		____cond171 = ____cond171 or ____switch171 == "show" -- 808
		if ____cond171 then -- 808
			do -- 808
				actionStack[#actionStack + 1] = Dora.Show() -- 811
				break -- 812
			end -- 812
		end -- 812
		____cond171 = ____cond171 or ____switch171 == "move" -- 812
		if ____cond171 then -- 812
			do -- 812
				local item = enode.props -- 815
				actionStack[#actionStack + 1] = Dora.Move( -- 816
					item.time, -- 816
					Dora.Vec2(item.startX, item.startY), -- 816
					Dora.Vec2(item.stopX, item.stopY), -- 816
					item.easing -- 816
				) -- 816
				break -- 817
			end -- 817
		end -- 817
		____cond171 = ____cond171 or ____switch171 == "frame" -- 817
		if ____cond171 then -- 817
			do -- 817
				local item = enode.props -- 820
				actionStack[#actionStack + 1] = Dora.Frame(item.file, item.time, item.frames) -- 821
				break -- 822
			end -- 822
		end -- 822
		____cond171 = ____cond171 or ____switch171 == "spawn" -- 822
		if ____cond171 then -- 822
			do -- 822
				local spawnStack = {} -- 825
				for i = 1, #enode.children do -- 825
					visitAction(spawnStack, enode.children[i]) -- 827
				end -- 827
				actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 829
				break -- 830
			end -- 830
		end -- 830
		____cond171 = ____cond171 or ____switch171 == "sequence" -- 830
		if ____cond171 then -- 830
			do -- 830
				local sequenceStack = {} -- 833
				for i = 1, #enode.children do -- 833
					visitAction(sequenceStack, enode.children[i]) -- 835
				end -- 835
				actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 837
				break -- 838
			end -- 838
		end -- 838
		do -- 838
			Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 841
			break -- 842
		end -- 842
	until true -- 842
end -- 789
local function actionCheck(nodeStack, enode, parent) -- 846
	local unsupported = false -- 847
	if parent == nil then -- 847
		unsupported = true -- 849
	else -- 849
		repeat -- 849
			local ____switch185 = parent.type -- 849
			local ____cond185 = ____switch185 == "action" or ____switch185 == "spawn" or ____switch185 == "sequence" -- 849
			if ____cond185 then -- 849
				break -- 852
			end -- 852
			do -- 852
				unsupported = true -- 853
				break -- 853
			end -- 853
		until true -- 853
	end -- 853
	if unsupported then -- 853
		if #nodeStack > 0 then -- 853
			local node = nodeStack[#nodeStack] -- 858
			local actionStack = {} -- 859
			visitAction(actionStack, enode) -- 860
			if #actionStack == 1 then -- 860
				node:runAction(actionStack[1]) -- 862
			end -- 862
		else -- 862
			Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 865
		end -- 865
	end -- 865
end -- 846
local function bodyCheck(_nodeStack, enode, parent) -- 870
	if parent == nil or parent.type ~= "body" then -- 870
		Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 872
	end -- 872
end -- 870
actionMap = { -- 876
	["anchor-x"] = Dora.AnchorX, -- 879
	["anchor-y"] = Dora.AnchorY, -- 880
	angle = Dora.Angle, -- 881
	["angle-x"] = Dora.AngleX, -- 882
	["angle-y"] = Dora.AngleY, -- 883
	width = Dora.Width, -- 884
	height = Dora.Height, -- 885
	opacity = Dora.Opacity, -- 886
	roll = Dora.Roll, -- 887
	scale = Dora.Scale, -- 888
	["scale-x"] = Dora.ScaleX, -- 889
	["scale-y"] = Dora.ScaleY, -- 890
	["skew-x"] = Dora.SkewX, -- 891
	["skew-y"] = Dora.SkewY, -- 892
	["move-x"] = Dora.X, -- 893
	["move-y"] = Dora.Y, -- 894
	["move-z"] = Dora.Z -- 895
} -- 895
elementMap = { -- 898
	node = function(nodeStack, enode, parent) -- 899
		addChild( -- 900
			nodeStack, -- 900
			getNode(enode), -- 900
			enode -- 900
		) -- 900
	end, -- 899
	["clip-node"] = function(nodeStack, enode, parent) -- 902
		addChild( -- 903
			nodeStack, -- 903
			getClipNode(enode), -- 903
			enode -- 903
		) -- 903
	end, -- 902
	playable = function(nodeStack, enode, parent) -- 905
		local cnode = getPlayable(enode) -- 906
		if cnode ~= nil then -- 906
			addChild(nodeStack, cnode, enode) -- 908
		end -- 908
	end, -- 905
	["dragon-bone"] = function(nodeStack, enode, parent) -- 911
		local cnode = getDragonBone(enode) -- 912
		if cnode ~= nil then -- 912
			addChild(nodeStack, cnode, enode) -- 914
		end -- 914
	end, -- 911
	spine = function(nodeStack, enode, parent) -- 917
		local cnode = getSpine(enode) -- 918
		if cnode ~= nil then -- 918
			addChild(nodeStack, cnode, enode) -- 920
		end -- 920
	end, -- 917
	model = function(nodeStack, enode, parent) -- 923
		local cnode = getModel(enode) -- 924
		if cnode ~= nil then -- 924
			addChild(nodeStack, cnode, enode) -- 926
		end -- 926
	end, -- 923
	["draw-node"] = function(nodeStack, enode, parent) -- 929
		addChild( -- 930
			nodeStack, -- 930
			getDrawNode(enode), -- 930
			enode -- 930
		) -- 930
	end, -- 929
	["dot-shape"] = drawNodeCheck, -- 932
	["segment-shape"] = drawNodeCheck, -- 933
	["rect-shape"] = drawNodeCheck, -- 934
	["polygon-shape"] = drawNodeCheck, -- 935
	["verts-shape"] = drawNodeCheck, -- 936
	grid = function(nodeStack, enode, parent) -- 937
		addChild( -- 938
			nodeStack, -- 938
			getGrid(enode), -- 938
			enode -- 938
		) -- 938
	end, -- 937
	sprite = function(nodeStack, enode, parent) -- 940
		local cnode = getSprite(enode) -- 941
		if cnode ~= nil then -- 941
			addChild(nodeStack, cnode, enode) -- 943
		end -- 943
	end, -- 940
	label = function(nodeStack, enode, parent) -- 946
		local cnode = getLabel(enode) -- 947
		if cnode ~= nil then -- 947
			addChild(nodeStack, cnode, enode) -- 949
		end -- 949
	end, -- 946
	line = function(nodeStack, enode, parent) -- 952
		addChild( -- 953
			nodeStack, -- 953
			getLine(enode), -- 953
			enode -- 953
		) -- 953
	end, -- 952
	particle = function(nodeStack, enode, parent) -- 955
		local cnode = getParticle(enode) -- 956
		if cnode ~= nil then -- 956
			addChild(nodeStack, cnode, enode) -- 958
		end -- 958
	end, -- 955
	menu = function(nodeStack, enode, parent) -- 961
		addChild( -- 962
			nodeStack, -- 962
			getMenu(enode), -- 962
			enode -- 962
		) -- 962
	end, -- 961
	action = function(_nodeStack, enode, parent) -- 964
		if #enode.children == 0 then -- 964
			Warn("<action> tag has no children") -- 966
			return -- 967
		end -- 967
		local action = enode.props -- 969
		if action.ref == nil then -- 969
			Warn("<action> tag has no ref") -- 971
			return -- 972
		end -- 972
		local actionStack = {} -- 974
		for i = 1, #enode.children do -- 974
			visitAction(actionStack, enode.children[i]) -- 976
		end -- 976
		if #actionStack == 1 then -- 976
			action.ref.current = actionStack[1] -- 979
		elseif #actionStack > 1 then -- 979
			action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 981
		end -- 981
	end, -- 964
	["anchor-x"] = actionCheck, -- 984
	["anchor-y"] = actionCheck, -- 985
	angle = actionCheck, -- 986
	["angle-x"] = actionCheck, -- 987
	["angle-y"] = actionCheck, -- 988
	delay = actionCheck, -- 989
	event = actionCheck, -- 990
	width = actionCheck, -- 991
	height = actionCheck, -- 992
	hide = actionCheck, -- 993
	show = actionCheck, -- 994
	move = actionCheck, -- 995
	opacity = actionCheck, -- 996
	roll = actionCheck, -- 997
	scale = actionCheck, -- 998
	["scale-x"] = actionCheck, -- 999
	["scale-y"] = actionCheck, -- 1000
	["skew-x"] = actionCheck, -- 1001
	["skew-y"] = actionCheck, -- 1002
	["move-x"] = actionCheck, -- 1003
	["move-y"] = actionCheck, -- 1004
	["move-z"] = actionCheck, -- 1005
	frame = actionCheck, -- 1006
	spawn = actionCheck, -- 1007
	sequence = actionCheck, -- 1008
	loop = function(nodeStack, enode, _parent) -- 1009
		if #nodeStack > 0 then -- 1009
			local node = nodeStack[#nodeStack] -- 1011
			local actionStack = {} -- 1012
			for i = 1, #enode.children do -- 1012
				visitAction(actionStack, enode.children[i]) -- 1014
			end -- 1014
			if #actionStack == 1 then -- 1014
				node:runAction(actionStack[1], true) -- 1017
			else -- 1017
				local loop = enode.props -- 1019
				if loop.spawn then -- 1019
					node:runAction( -- 1021
						Dora.Spawn(table.unpack(actionStack)), -- 1021
						true -- 1021
					) -- 1021
				else -- 1021
					node:runAction( -- 1023
						Dora.Sequence(table.unpack(actionStack)), -- 1023
						true -- 1023
					) -- 1023
				end -- 1023
			end -- 1023
		else -- 1023
			Warn("tag <loop> must be placed under a scene node to take effect") -- 1027
		end -- 1027
	end, -- 1009
	["physics-world"] = function(nodeStack, enode, _parent) -- 1030
		addChild( -- 1031
			nodeStack, -- 1031
			getPhysicsWorld(enode), -- 1031
			enode -- 1031
		) -- 1031
	end, -- 1030
	contact = function(nodeStack, enode, _parent) -- 1033
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1034
		if world ~= nil then -- 1034
			local contact = enode.props -- 1036
			world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1037
		else -- 1037
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1039
		end -- 1039
	end, -- 1033
	body = function(nodeStack, enode, _parent) -- 1042
		local def = enode.props -- 1043
		if def.world then -- 1043
			addChild( -- 1045
				nodeStack, -- 1045
				getBody(enode, def.world), -- 1045
				enode -- 1045
			) -- 1045
			return -- 1046
		end -- 1046
		local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1048
		if world ~= nil then -- 1048
			addChild( -- 1050
				nodeStack, -- 1050
				getBody(enode, world), -- 1050
				enode -- 1050
			) -- 1050
		else -- 1050
			Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1052
		end -- 1052
	end, -- 1042
	["rect-fixture"] = bodyCheck, -- 1055
	["polygon-fixture"] = bodyCheck, -- 1056
	["multi-fixture"] = bodyCheck, -- 1057
	["disk-fixture"] = bodyCheck, -- 1058
	["chain-fixture"] = bodyCheck, -- 1059
	["distance-joint"] = function(_nodeStack, enode, _parent) -- 1060
		local joint = enode.props -- 1061
		if joint.ref == nil then -- 1061
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1063
			return -- 1064
		end -- 1064
		if joint.bodyA.current == nil then -- 1064
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1067
			return -- 1068
		end -- 1068
		if joint.bodyB.current == nil then -- 1068
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1071
			return -- 1072
		end -- 1072
		local ____joint_ref_15 = joint.ref -- 1074
		local ____self_13 = Dora.Joint -- 1074
		local ____self_13_distance_14 = ____self_13.distance -- 1074
		local ____joint_canCollide_12 = joint.canCollide -- 1075
		if ____joint_canCollide_12 == nil then -- 1075
			____joint_canCollide_12 = false -- 1075
		end -- 1075
		____joint_ref_15.current = ____self_13_distance_14( -- 1074
			____self_13, -- 1074
			____joint_canCollide_12, -- 1075
			joint.bodyA.current, -- 1076
			joint.bodyB.current, -- 1077
			joint.anchorA or Dora.Vec2.zero, -- 1078
			joint.anchorB or Dora.Vec2.zero, -- 1079
			joint.frequency or 0, -- 1080
			joint.damping or 0 -- 1081
		) -- 1081
	end, -- 1060
	["friction-joint"] = function(_nodeStack, enode, _parent) -- 1083
		local joint = enode.props -- 1084
		if joint.ref == nil then -- 1084
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1086
			return -- 1087
		end -- 1087
		if joint.bodyA.current == nil then -- 1087
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1090
			return -- 1091
		end -- 1091
		if joint.bodyB.current == nil then -- 1091
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1094
			return -- 1095
		end -- 1095
		local ____joint_ref_19 = joint.ref -- 1097
		local ____self_17 = Dora.Joint -- 1097
		local ____self_17_friction_18 = ____self_17.friction -- 1097
		local ____joint_canCollide_16 = joint.canCollide -- 1098
		if ____joint_canCollide_16 == nil then -- 1098
			____joint_canCollide_16 = false -- 1098
		end -- 1098
		____joint_ref_19.current = ____self_17_friction_18( -- 1097
			____self_17, -- 1097
			____joint_canCollide_16, -- 1098
			joint.bodyA.current, -- 1099
			joint.bodyB.current, -- 1100
			joint.worldPos, -- 1101
			joint.maxForce, -- 1102
			joint.maxTorque -- 1103
		) -- 1103
	end, -- 1083
	["gear-joint"] = function(_nodeStack, enode, _parent) -- 1106
		local joint = enode.props -- 1107
		if joint.ref == nil then -- 1107
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1109
			return -- 1110
		end -- 1110
		if joint.jointA.current == nil then -- 1110
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1113
			return -- 1114
		end -- 1114
		if joint.jointB.current == nil then -- 1114
			Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1117
			return -- 1118
		end -- 1118
		local ____joint_ref_23 = joint.ref -- 1120
		local ____self_21 = Dora.Joint -- 1120
		local ____self_21_gear_22 = ____self_21.gear -- 1120
		local ____joint_canCollide_20 = joint.canCollide -- 1121
		if ____joint_canCollide_20 == nil then -- 1121
			____joint_canCollide_20 = false -- 1121
		end -- 1121
		____joint_ref_23.current = ____self_21_gear_22( -- 1120
			____self_21, -- 1120
			____joint_canCollide_20, -- 1121
			joint.jointA.current, -- 1122
			joint.jointB.current, -- 1123
			joint.ratio or 1 -- 1124
		) -- 1124
	end, -- 1106
	["spring-joint"] = function(_nodeStack, enode, _parent) -- 1127
		local joint = enode.props -- 1128
		if joint.ref == nil then -- 1128
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1130
			return -- 1131
		end -- 1131
		if joint.bodyA.current == nil then -- 1131
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1134
			return -- 1135
		end -- 1135
		if joint.bodyB.current == nil then -- 1135
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1138
			return -- 1139
		end -- 1139
		local ____joint_ref_27 = joint.ref -- 1141
		local ____self_25 = Dora.Joint -- 1141
		local ____self_25_spring_26 = ____self_25.spring -- 1141
		local ____joint_canCollide_24 = joint.canCollide -- 1142
		if ____joint_canCollide_24 == nil then -- 1142
			____joint_canCollide_24 = false -- 1142
		end -- 1142
		____joint_ref_27.current = ____self_25_spring_26( -- 1141
			____self_25, -- 1141
			____joint_canCollide_24, -- 1142
			joint.bodyA.current, -- 1143
			joint.bodyB.current, -- 1144
			joint.linearOffset, -- 1145
			joint.angularOffset, -- 1146
			joint.maxForce, -- 1147
			joint.maxTorque, -- 1148
			joint.correctionFactor or 1 -- 1149
		) -- 1149
	end, -- 1127
	["move-joint"] = function(_nodeStack, enode, _parent) -- 1152
		local joint = enode.props -- 1153
		if joint.ref == nil then -- 1153
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1155
			return -- 1156
		end -- 1156
		if joint.body.current == nil then -- 1156
			Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1159
			return -- 1160
		end -- 1160
		local ____joint_ref_31 = joint.ref -- 1162
		local ____self_29 = Dora.Joint -- 1162
		local ____self_29_move_30 = ____self_29.move -- 1162
		local ____joint_canCollide_28 = joint.canCollide -- 1163
		if ____joint_canCollide_28 == nil then -- 1163
			____joint_canCollide_28 = false -- 1163
		end -- 1163
		____joint_ref_31.current = ____self_29_move_30( -- 1162
			____self_29, -- 1162
			____joint_canCollide_28, -- 1163
			joint.body.current, -- 1164
			joint.targetPos, -- 1165
			joint.maxForce, -- 1166
			joint.frequency, -- 1167
			joint.damping or 0.7 -- 1168
		) -- 1168
	end, -- 1152
	["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1171
		local joint = enode.props -- 1172
		if joint.ref == nil then -- 1172
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1174
			return -- 1175
		end -- 1175
		if joint.bodyA.current == nil then -- 1175
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1178
			return -- 1179
		end -- 1179
		if joint.bodyB.current == nil then -- 1179
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1182
			return -- 1183
		end -- 1183
		local ____joint_ref_35 = joint.ref -- 1185
		local ____self_33 = Dora.Joint -- 1185
		local ____self_33_prismatic_34 = ____self_33.prismatic -- 1185
		local ____joint_canCollide_32 = joint.canCollide -- 1186
		if ____joint_canCollide_32 == nil then -- 1186
			____joint_canCollide_32 = false -- 1186
		end -- 1186
		____joint_ref_35.current = ____self_33_prismatic_34( -- 1185
			____self_33, -- 1185
			____joint_canCollide_32, -- 1186
			joint.bodyA.current, -- 1187
			joint.bodyB.current, -- 1188
			joint.worldPos, -- 1189
			joint.axisAngle, -- 1190
			joint.lowerTranslation or 0, -- 1191
			joint.upperTranslation or 0, -- 1192
			joint.maxMotorForce or 0, -- 1193
			joint.motorSpeed or 0 -- 1194
		) -- 1194
	end, -- 1171
	["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1197
		local joint = enode.props -- 1198
		if joint.ref == nil then -- 1198
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1200
			return -- 1201
		end -- 1201
		if joint.bodyA.current == nil then -- 1201
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1204
			return -- 1205
		end -- 1205
		if joint.bodyB.current == nil then -- 1205
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1208
			return -- 1209
		end -- 1209
		local ____joint_ref_39 = joint.ref -- 1211
		local ____self_37 = Dora.Joint -- 1211
		local ____self_37_pulley_38 = ____self_37.pulley -- 1211
		local ____joint_canCollide_36 = joint.canCollide -- 1212
		if ____joint_canCollide_36 == nil then -- 1212
			____joint_canCollide_36 = false -- 1212
		end -- 1212
		____joint_ref_39.current = ____self_37_pulley_38( -- 1211
			____self_37, -- 1211
			____joint_canCollide_36, -- 1212
			joint.bodyA.current, -- 1213
			joint.bodyB.current, -- 1214
			joint.anchorA or Dora.Vec2.zero, -- 1215
			joint.anchorB or Dora.Vec2.zero, -- 1216
			joint.groundAnchorA, -- 1217
			joint.groundAnchorB, -- 1218
			joint.ratio or 1 -- 1219
		) -- 1219
	end, -- 1197
	["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1222
		local joint = enode.props -- 1223
		if joint.ref == nil then -- 1223
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1225
			return -- 1226
		end -- 1226
		if joint.bodyA.current == nil then -- 1226
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1229
			return -- 1230
		end -- 1230
		if joint.bodyB.current == nil then -- 1230
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1233
			return -- 1234
		end -- 1234
		local ____joint_ref_43 = joint.ref -- 1236
		local ____self_41 = Dora.Joint -- 1236
		local ____self_41_revolute_42 = ____self_41.revolute -- 1236
		local ____joint_canCollide_40 = joint.canCollide -- 1237
		if ____joint_canCollide_40 == nil then -- 1237
			____joint_canCollide_40 = false -- 1237
		end -- 1237
		____joint_ref_43.current = ____self_41_revolute_42( -- 1236
			____self_41, -- 1236
			____joint_canCollide_40, -- 1237
			joint.bodyA.current, -- 1238
			joint.bodyB.current, -- 1239
			joint.worldPos, -- 1240
			joint.lowerAngle or 0, -- 1241
			joint.upperAngle or 0, -- 1242
			joint.maxMotorTorque or 0, -- 1243
			joint.motorSpeed or 0 -- 1244
		) -- 1244
	end, -- 1222
	["rope-joint"] = function(_nodeStack, enode, _parent) -- 1247
		local joint = enode.props -- 1248
		if joint.ref == nil then -- 1248
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1250
			return -- 1251
		end -- 1251
		if joint.bodyA.current == nil then -- 1251
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1254
			return -- 1255
		end -- 1255
		if joint.bodyB.current == nil then -- 1255
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1258
			return -- 1259
		end -- 1259
		local ____joint_ref_47 = joint.ref -- 1261
		local ____self_45 = Dora.Joint -- 1261
		local ____self_45_rope_46 = ____self_45.rope -- 1261
		local ____joint_canCollide_44 = joint.canCollide -- 1262
		if ____joint_canCollide_44 == nil then -- 1262
			____joint_canCollide_44 = false -- 1262
		end -- 1262
		____joint_ref_47.current = ____self_45_rope_46( -- 1261
			____self_45, -- 1261
			____joint_canCollide_44, -- 1262
			joint.bodyA.current, -- 1263
			joint.bodyB.current, -- 1264
			joint.anchorA or Dora.Vec2.zero, -- 1265
			joint.anchorB or Dora.Vec2.zero, -- 1266
			joint.maxLength or 0 -- 1267
		) -- 1267
	end, -- 1247
	["weld-joint"] = function(_nodeStack, enode, _parent) -- 1270
		local joint = enode.props -- 1271
		if joint.ref == nil then -- 1271
			Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1273
			return -- 1274
		end -- 1274
		if joint.bodyA.current == nil then -- 1274
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1277
			return -- 1278
		end -- 1278
		if joint.bodyB.current == nil then -- 1278
			Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1281
			return -- 1282
		end -- 1282
		local ____joint_ref_51 = joint.ref -- 1284
		local ____self_49 = Dora.Joint -- 1284
		local ____self_49_weld_50 = ____self_49.weld -- 1284
		local ____joint_canCollide_48 = joint.canCollide -- 1285
		if ____joint_canCollide_48 == nil then -- 1285
			____joint_canCollide_48 = false -- 1285
		end -- 1285
		____joint_ref_51.current = ____self_49_weld_50( -- 1284
			____self_49, -- 1284
			____joint_canCollide_48, -- 1285
			joint.bodyA.current, -- 1286
			joint.bodyB.current, -- 1287
			joint.worldPos, -- 1288
			joint.frequency or 0, -- 1289
			joint.damping or 0 -- 1290
		) -- 1290
	end, -- 1270
	["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1293
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
		local ____joint_ref_55 = joint.ref -- 1307
		local ____self_53 = Dora.Joint -- 1307
		local ____self_53_wheel_54 = ____self_53.wheel -- 1307
		local ____joint_canCollide_52 = joint.canCollide -- 1308
		if ____joint_canCollide_52 == nil then -- 1308
			____joint_canCollide_52 = false -- 1308
		end -- 1308
		____joint_ref_55.current = ____self_53_wheel_54( -- 1307
			____self_53, -- 1307
			____joint_canCollide_52, -- 1308
			joint.bodyA.current, -- 1309
			joint.bodyB.current, -- 1310
			joint.worldPos, -- 1311
			joint.axisAngle, -- 1312
			joint.maxMotorTorque or 0, -- 1313
			joint.motorSpeed or 0, -- 1314
			joint.frequency or 0, -- 1315
			joint.damping or 0.7 -- 1316
		) -- 1316
	end, -- 1293
	["custom-node"] = function(nodeStack, enode, _parent) -- 1319
		local node = getCustomNode(enode) -- 1320
		if node ~= nil then -- 1320
			addChild(nodeStack, node, enode) -- 1322
		end -- 1322
	end, -- 1319
	["custom-element"] = function() -- 1325
	end, -- 1325
	["align-node"] = function(nodeStack, enode, _parent) -- 1326
		addChild( -- 1327
			nodeStack, -- 1327
			getAlignNode(enode), -- 1327
			enode -- 1327
		) -- 1327
	end, -- 1326
	["effek-node"] = function(nodeStack, enode, _parent) -- 1329
		addChild( -- 1330
			nodeStack, -- 1330
			getEffekNode(enode), -- 1330
			enode -- 1330
		) -- 1330
	end, -- 1329
	effek = function(nodeStack, enode, parent) -- 1332
		if #nodeStack > 0 then -- 1332
			local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1334
			if node then -- 1334
				local effek = enode.props -- 1336
				local handle = node:play( -- 1337
					effek.file, -- 1337
					Dora.Vec2(effek.x or 0, effek.y or 0), -- 1337
					effek.z or 0 -- 1337
				) -- 1337
				if handle >= 0 then -- 1337
					if effek.ref then -- 1337
						effek.ref.current = handle -- 1340
					end -- 1340
					if effek.onEnd then -- 1340
						local onEnd = effek.onEnd -- 1340
						node:slot( -- 1344
							"EffekEnd", -- 1344
							function(h) -- 1344
								if handle == h then -- 1344
									onEnd(nil) -- 1346
								end -- 1346
							end -- 1344
						) -- 1344
					end -- 1344
				end -- 1344
			else -- 1344
				Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1352
			end -- 1352
		end -- 1352
	end, -- 1332
	["tile-node"] = function(nodeStack, enode, parent) -- 1356
		local cnode = getTileNode(enode) -- 1357
		if cnode ~= nil then -- 1357
			addChild(nodeStack, cnode, enode) -- 1359
		end -- 1359
	end -- 1356
} -- 1356
function ____exports.useRef(item) -- 1404
	local ____item_56 = item -- 1405
	if ____item_56 == nil then -- 1405
		____item_56 = nil -- 1405
	end -- 1405
	return {current = ____item_56} -- 1405
end -- 1404
local function getPreload(preloadList, node) -- 1408
	if type(node) ~= "table" then -- 1408
		return -- 1410
	end -- 1410
	local enode = node -- 1412
	if enode.type == nil then -- 1412
		local list = node -- 1414
		if #list > 0 then -- 1414
			for i = 1, #list do -- 1414
				getPreload(preloadList, list[i]) -- 1417
			end -- 1417
		end -- 1417
	else -- 1417
		repeat -- 1417
			local ____switch313 = enode.type -- 1417
			local sprite, playable, frame, model, spine, dragonBone, label -- 1417
			local ____cond313 = ____switch313 == "sprite" -- 1417
			if ____cond313 then -- 1417
				sprite = enode.props -- 1423
				if sprite.file then -- 1423
					preloadList[#preloadList + 1] = sprite.file -- 1425
				end -- 1425
				break -- 1427
			end -- 1427
			____cond313 = ____cond313 or ____switch313 == "playable" -- 1427
			if ____cond313 then -- 1427
				playable = enode.props -- 1429
				preloadList[#preloadList + 1] = playable.file -- 1430
				break -- 1431
			end -- 1431
			____cond313 = ____cond313 or ____switch313 == "frame" -- 1431
			if ____cond313 then -- 1431
				frame = enode.props -- 1433
				preloadList[#preloadList + 1] = frame.file -- 1434
				break -- 1435
			end -- 1435
			____cond313 = ____cond313 or ____switch313 == "model" -- 1435
			if ____cond313 then -- 1435
				model = enode.props -- 1437
				preloadList[#preloadList + 1] = "model:" .. model.file -- 1438
				break -- 1439
			end -- 1439
			____cond313 = ____cond313 or ____switch313 == "spine" -- 1439
			if ____cond313 then -- 1439
				spine = enode.props -- 1441
				preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1442
				break -- 1443
			end -- 1443
			____cond313 = ____cond313 or ____switch313 == "dragon-bone" -- 1443
			if ____cond313 then -- 1443
				dragonBone = enode.props -- 1445
				preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1446
				break -- 1447
			end -- 1447
			____cond313 = ____cond313 or ____switch313 == "label" -- 1447
			if ____cond313 then -- 1447
				label = enode.props -- 1449
				preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1450
				break -- 1451
			end -- 1451
		until true -- 1451
	end -- 1451
	getPreload(preloadList, enode.children) -- 1454
end -- 1408
function ____exports.preloadAsync(enode, handler) -- 1457
	local preloadList = {} -- 1458
	getPreload(preloadList, enode) -- 1459
	Dora.Cache:loadAsync(preloadList, handler) -- 1460
end -- 1457
function ____exports.toAction(enode) -- 1463
	local actionDef = ____exports.useRef() -- 1464
	____exports.toNode(____exports.React.createElement("action", {ref = actionDef}, enode)) -- 1465
	if not actionDef.current then -- 1465
		error("failed to create action") -- 1466
	end -- 1466
	return actionDef.current -- 1467
end -- 1463
return ____exports -- 1463