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
    print("[Dora Warning] " .. msg) -- 14
end -- 14
function visitNode(nodeStack, node, parent) -- 1347
    if type(node) ~= "table" then -- 1347
        return -- 1349
    end -- 1349
    local enode = node -- 1351
    if enode.type == nil then -- 1351
        local list = node -- 1353
        if #list > 0 then -- 1353
            for i = 1, #list do -- 1353
                local stack = {} -- 1356
                visitNode(stack, list[i], parent) -- 1357
                for i = 1, #stack do -- 1357
                    nodeStack[#nodeStack + 1] = stack[i] -- 1359
                end -- 1359
            end -- 1359
        end -- 1359
    else -- 1359
        local handler = elementMap[enode.type] -- 1364
        if handler ~= nil then -- 1364
            handler(nodeStack, enode, parent) -- 1366
        else -- 1366
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1368
        end -- 1368
    end -- 1368
end -- 1368
function ____exports.toNode(enode) -- 1373
    local nodeStack = {} -- 1374
    visitNode(nodeStack, enode) -- 1375
    if #nodeStack == 1 then -- 1375
        return nodeStack[1] -- 1377
    elseif #nodeStack > 1 then -- 1377
        local node = Dora.Node() -- 1379
        for i = 1, #nodeStack do -- 1379
            node:addChild(nodeStack[i]) -- 1381
        end -- 1381
        return node -- 1383
    end -- 1383
    return nil -- 1385
end -- 1373
____exports.React = {} -- 1373
local React = ____exports.React -- 1373
do -- 1373
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
    function React.createElement(self, typeName, props, ...) -- 61
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
                    return typeName(nil, props) -- 74
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
        local node = Dora.Sprite(sp.file) -- 405
        if node ~= nil then -- 405
            local cnode = getNode(enode, node, handleSpriteAttribute) -- 407
            return cnode -- 408
        end -- 408
        return nil -- 410
    end -- 403
end -- 403
local getLabel -- 414
do -- 414
    local function handleLabelAttribute(cnode, _enode, k, v) -- 416
        repeat -- 416
            local ____switch87 = k -- 416
            local ____cond87 = ____switch87 == "fontName" or ____switch87 == "fontSize" or ____switch87 == "text" -- 416
            if ____cond87 then -- 416
                return true -- 418
            end -- 418
            ____cond87 = ____cond87 or ____switch87 == "alphaRef" -- 418
            if ____cond87 then -- 418
                cnode.alphaRef = v -- 419
                return true -- 419
            end -- 419
            ____cond87 = ____cond87 or ____switch87 == "textWidth" -- 419
            if ____cond87 then -- 419
                cnode.textWidth = v -- 420
                return true -- 420
            end -- 420
            ____cond87 = ____cond87 or ____switch87 == "lineGap" -- 420
            if ____cond87 then -- 420
                cnode.lineGap = v -- 421
                return true -- 421
            end -- 421
            ____cond87 = ____cond87 or ____switch87 == "spacing" -- 421
            if ____cond87 then -- 421
                cnode.spacing = v -- 422
                return true -- 422
            end -- 422
            ____cond87 = ____cond87 or ____switch87 == "blendFunc" -- 422
            if ____cond87 then -- 422
                cnode.blendFunc = v -- 423
                return true -- 423
            end -- 423
            ____cond87 = ____cond87 or ____switch87 == "depthWrite" -- 423
            if ____cond87 then -- 423
                cnode.depthWrite = v -- 424
                return true -- 424
            end -- 424
            ____cond87 = ____cond87 or ____switch87 == "batched" -- 424
            if ____cond87 then -- 424
                cnode.batched = v -- 425
                return true -- 425
            end -- 425
            ____cond87 = ____cond87 or ____switch87 == "effect" -- 425
            if ____cond87 then -- 425
                cnode.effect = v -- 426
                return true -- 426
            end -- 426
            ____cond87 = ____cond87 or ____switch87 == "alignment" -- 426
            if ____cond87 then -- 426
                cnode.alignment = v -- 427
                return true -- 427
            end -- 427
        until true -- 427
        return false -- 429
    end -- 416
    getLabel = function(enode) -- 431
        local label = enode.props -- 432
        local node = Dora.Label(label.fontName, label.fontSize) -- 433
        if node ~= nil then -- 433
            local cnode = getNode(enode, node, handleLabelAttribute) -- 435
            local ____enode_8 = enode -- 436
            local children = ____enode_8.children -- 436
            local text = label.text or "" -- 437
            for i = 1, #children do -- 437
                local child = children[i] -- 439
                if type(child) ~= "table" then -- 439
                    text = text .. tostring(child) -- 441
                end -- 441
            end -- 441
            node.text = text -- 444
            return cnode -- 445
        end -- 445
        return nil -- 447
    end -- 431
end -- 431
local getLine -- 451
do -- 451
    local function handleLineAttribute(cnode, enode, k, v) -- 453
        local line = enode.props -- 454
        repeat -- 454
            local ____switch94 = k -- 454
            local ____cond94 = ____switch94 == "verts" -- 454
            if ____cond94 then -- 454
                cnode:set( -- 456
                    v, -- 456
                    Dora.Color(line.lineColor or 4294967295) -- 456
                ) -- 456
                return true -- 456
            end -- 456
            ____cond94 = ____cond94 or ____switch94 == "depthWrite" -- 456
            if ____cond94 then -- 456
                cnode.depthWrite = v -- 457
                return true -- 457
            end -- 457
            ____cond94 = ____cond94 or ____switch94 == "blendFunc" -- 457
            if ____cond94 then -- 457
                cnode.blendFunc = v -- 458
                return true -- 458
            end -- 458
        until true -- 458
        return false -- 460
    end -- 453
    getLine = function(enode) -- 462
        local node = Dora.Line() -- 463
        local cnode = getNode(enode, node, handleLineAttribute) -- 464
        return cnode -- 465
    end -- 462
end -- 462
local getParticle -- 469
do -- 469
    local function handleParticleAttribute(cnode, _enode, k, v) -- 471
        repeat -- 471
            local ____switch98 = k -- 471
            local ____cond98 = ____switch98 == "file" -- 471
            if ____cond98 then -- 471
                return true -- 473
            end -- 473
            ____cond98 = ____cond98 or ____switch98 == "emit" -- 473
            if ____cond98 then -- 473
                if v then -- 473
                    cnode:start() -- 474
                end -- 474
                return true -- 474
            end -- 474
            ____cond98 = ____cond98 or ____switch98 == "onFinished" -- 474
            if ____cond98 then -- 474
                cnode:slot("Finished", v) -- 475
                return true -- 475
            end -- 475
        until true -- 475
        return false -- 477
    end -- 471
    getParticle = function(enode) -- 479
        local particle = enode.props -- 480
        local node = Dora.Particle(particle.file) -- 481
        if node ~= nil then -- 481
            local cnode = getNode(enode, node, handleParticleAttribute) -- 483
            return cnode -- 484
        end -- 484
        return nil -- 486
    end -- 479
end -- 479
local getMenu -- 490
do -- 490
    local function handleMenuAttribute(cnode, _enode, k, v) -- 492
        repeat -- 492
            local ____switch104 = k -- 492
            local ____cond104 = ____switch104 == "enabled" -- 492
            if ____cond104 then -- 492
                cnode.enabled = v -- 494
                return true -- 494
            end -- 494
        until true -- 494
        return false -- 496
    end -- 492
    getMenu = function(enode) -- 498
        local node = Dora.Menu() -- 499
        local cnode = getNode(enode, node, handleMenuAttribute) -- 500
        return cnode -- 501
    end -- 498
end -- 498
local function getPhysicsWorld(enode) -- 505
    local node = Dora.PhysicsWorld() -- 506
    local cnode = getNode(enode, node) -- 507
    return cnode -- 508
end -- 505
local getBody -- 511
do -- 511
    local function handleBodyAttribute(cnode, _enode, k, v) -- 513
        repeat -- 513
            local ____switch109 = k -- 513
            local ____cond109 = ____switch109 == "type" or ____switch109 == "linearAcceleration" or ____switch109 == "fixedRotation" or ____switch109 == "bullet" or ____switch109 == "world" -- 513
            if ____cond109 then -- 513
                return true -- 520
            end -- 520
            ____cond109 = ____cond109 or ____switch109 == "velocityX" -- 520
            if ____cond109 then -- 520
                cnode.velocityX = v -- 521
                return true -- 521
            end -- 521
            ____cond109 = ____cond109 or ____switch109 == "velocityY" -- 521
            if ____cond109 then -- 521
                cnode.velocityY = v -- 522
                return true -- 522
            end -- 522
            ____cond109 = ____cond109 or ____switch109 == "angularRate" -- 522
            if ____cond109 then -- 522
                cnode.angularRate = v -- 523
                return true -- 523
            end -- 523
            ____cond109 = ____cond109 or ____switch109 == "group" -- 523
            if ____cond109 then -- 523
                cnode.group = v -- 524
                return true -- 524
            end -- 524
            ____cond109 = ____cond109 or ____switch109 == "linearDamping" -- 524
            if ____cond109 then -- 524
                cnode.linearDamping = v -- 525
                return true -- 525
            end -- 525
            ____cond109 = ____cond109 or ____switch109 == "angularDamping" -- 525
            if ____cond109 then -- 525
                cnode.angularDamping = v -- 526
                return true -- 526
            end -- 526
            ____cond109 = ____cond109 or ____switch109 == "owner" -- 526
            if ____cond109 then -- 526
                cnode.owner = v -- 527
                return true -- 527
            end -- 527
            ____cond109 = ____cond109 or ____switch109 == "receivingContact" -- 527
            if ____cond109 then -- 527
                cnode.receivingContact = v -- 528
                return true -- 528
            end -- 528
            ____cond109 = ____cond109 or ____switch109 == "onBodyEnter" -- 528
            if ____cond109 then -- 528
                cnode:slot("BodyEnter", v) -- 529
                return true -- 529
            end -- 529
            ____cond109 = ____cond109 or ____switch109 == "onBodyLeave" -- 529
            if ____cond109 then -- 529
                cnode:slot("BodyLeave", v) -- 530
                return true -- 530
            end -- 530
            ____cond109 = ____cond109 or ____switch109 == "onContactStart" -- 530
            if ____cond109 then -- 530
                cnode:slot("ContactStart", v) -- 531
                return true -- 531
            end -- 531
            ____cond109 = ____cond109 or ____switch109 == "onContactEnd" -- 531
            if ____cond109 then -- 531
                cnode:slot("ContactEnd", v) -- 532
                return true -- 532
            end -- 532
            ____cond109 = ____cond109 or ____switch109 == "onContactFilter" -- 532
            if ____cond109 then -- 532
                cnode:onContactFilter(v) -- 533
                return true -- 533
            end -- 533
        until true -- 533
        return false -- 535
    end -- 513
    getBody = function(enode, world) -- 537
        local def = enode.props -- 538
        local bodyDef = Dora.BodyDef() -- 539
        bodyDef.type = def.type -- 540
        if def.angle ~= nil then -- 540
            bodyDef.angle = def.angle -- 541
        end -- 541
        if def.angularDamping ~= nil then -- 541
            bodyDef.angularDamping = def.angularDamping -- 542
        end -- 542
        if def.bullet ~= nil then -- 542
            bodyDef.bullet = def.bullet -- 543
        end -- 543
        if def.fixedRotation ~= nil then -- 543
            bodyDef.fixedRotation = def.fixedRotation -- 544
        end -- 544
        bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 545
        if def.linearDamping ~= nil then -- 545
            bodyDef.linearDamping = def.linearDamping -- 546
        end -- 546
        bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 547
        local extraSensors = nil -- 548
        for i = 1, #enode.children do -- 548
            do -- 548
                local child = enode.children[i] -- 550
                if type(child) ~= "table" then -- 550
                    goto __continue116 -- 552
                end -- 552
                repeat -- 552
                    local ____switch118 = child.type -- 552
                    local ____cond118 = ____switch118 == "rect-fixture" -- 552
                    if ____cond118 then -- 552
                        do -- 552
                            local shape = child.props -- 556
                            if shape.sensorTag ~= nil then -- 556
                                bodyDef:attachPolygonSensor( -- 558
                                    shape.sensorTag, -- 559
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 560
                                    shape.width, -- 561
                                    shape.height, -- 561
                                    shape.angle or 0 -- 562
                                ) -- 562
                            else -- 562
                                bodyDef:attachPolygon( -- 565
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 566
                                    shape.width, -- 567
                                    shape.height, -- 567
                                    shape.angle or 0, -- 568
                                    shape.density or 1, -- 569
                                    shape.friction or 0.4, -- 570
                                    shape.restitution or 0 -- 571
                                ) -- 571
                            end -- 571
                            break -- 574
                        end -- 574
                    end -- 574
                    ____cond118 = ____cond118 or ____switch118 == "polygon-fixture" -- 574
                    if ____cond118 then -- 574
                        do -- 574
                            local shape = child.props -- 577
                            if shape.sensorTag ~= nil then -- 577
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 579
                            else -- 579
                                bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 584
                            end -- 584
                            break -- 591
                        end -- 591
                    end -- 591
                    ____cond118 = ____cond118 or ____switch118 == "multi-fixture" -- 591
                    if ____cond118 then -- 591
                        do -- 591
                            local shape = child.props -- 594
                            if shape.sensorTag ~= nil then -- 594
                                if extraSensors == nil then -- 594
                                    extraSensors = {} -- 596
                                end -- 596
                                extraSensors[#extraSensors + 1] = { -- 597
                                    shape.sensorTag, -- 597
                                    Dora.BodyDef:multi(shape.verts) -- 597
                                } -- 597
                            else -- 597
                                bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 599
                            end -- 599
                            break -- 606
                        end -- 606
                    end -- 606
                    ____cond118 = ____cond118 or ____switch118 == "disk-fixture" -- 606
                    if ____cond118 then -- 606
                        do -- 606
                            local shape = child.props -- 609
                            if shape.sensorTag ~= nil then -- 609
                                bodyDef:attachDiskSensor( -- 611
                                    shape.sensorTag, -- 612
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 613
                                    shape.radius -- 614
                                ) -- 614
                            else -- 614
                                bodyDef:attachDisk( -- 617
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 618
                                    shape.radius, -- 619
                                    shape.density or 1, -- 620
                                    shape.friction or 0.4, -- 621
                                    shape.restitution or 0 -- 622
                                ) -- 622
                            end -- 622
                            break -- 625
                        end -- 625
                    end -- 625
                    ____cond118 = ____cond118 or ____switch118 == "chain-fixture" -- 625
                    if ____cond118 then -- 625
                        do -- 625
                            local shape = child.props -- 628
                            if shape.sensorTag ~= nil then -- 628
                                if extraSensors == nil then -- 628
                                    extraSensors = {} -- 630
                                end -- 630
                                extraSensors[#extraSensors + 1] = { -- 631
                                    shape.sensorTag, -- 631
                                    Dora.BodyDef:chain(shape.verts) -- 631
                                } -- 631
                            else -- 631
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 633
                            end -- 633
                            break -- 639
                        end -- 639
                    end -- 639
                until true -- 639
            end -- 639
            ::__continue116:: -- 639
        end -- 639
        local body = Dora.Body(bodyDef, world) -- 643
        if extraSensors ~= nil then -- 643
            for i = 1, #extraSensors do -- 643
                local tag, def = table.unpack(extraSensors[i]) -- 646
                body:attachSensor(tag, def) -- 647
            end -- 647
        end -- 647
        local cnode = getNode(enode, body, handleBodyAttribute) -- 650
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 650
            body.receivingContact = true -- 657
        end -- 657
        return cnode -- 659
    end -- 537
end -- 537
local getCustomNode -- 663
do -- 663
    local function handleCustomNode(_cnode, _enode, k, _v) -- 665
        repeat -- 665
            local ____switch139 = k -- 665
            local ____cond139 = ____switch139 == "onCreate" -- 665
            if ____cond139 then -- 665
                return true -- 667
            end -- 667
        until true -- 667
        return false -- 669
    end -- 665
    getCustomNode = function(enode) -- 671
        local custom = enode.props -- 672
        local node = custom.onCreate() -- 673
        if node then -- 673
            local cnode = getNode(enode, node, handleCustomNode) -- 675
            return cnode -- 676
        end -- 676
        return nil -- 678
    end -- 671
end -- 671
local getAlignNode -- 682
do -- 682
    local function handleAlignNode(_cnode, _enode, k, _v) -- 684
        repeat -- 684
            local ____switch144 = k -- 684
            local ____cond144 = ____switch144 == "windowRoot" -- 684
            if ____cond144 then -- 684
                return true -- 686
            end -- 686
            ____cond144 = ____cond144 or ____switch144 == "style" -- 686
            if ____cond144 then -- 686
                return true -- 687
            end -- 687
            ____cond144 = ____cond144 or ____switch144 == "onLayout" -- 687
            if ____cond144 then -- 687
                return true -- 688
            end -- 688
        until true -- 688
        return false -- 690
    end -- 684
    getAlignNode = function(enode) -- 692
        local alignNode = enode.props -- 693
        local node = Dora.AlignNode(alignNode.windowRoot) -- 694
        if alignNode.style then -- 694
            local items = {} -- 696
            for k, v in pairs(alignNode.style) do -- 697
                local name = string.gsub(k, "%u", "-%1") -- 698
                name = string.lower(name) -- 699
                repeat -- 699
                    local ____switch148 = k -- 699
                    local ____cond148 = ____switch148 == "margin" or ____switch148 == "padding" or ____switch148 == "border" or ____switch148 == "gap" -- 699
                    if ____cond148 then -- 699
                        do -- 699
                            if type(v) == "table" then -- 699
                                local valueStr = table.concat( -- 704
                                    __TS__ArrayMap( -- 704
                                        v, -- 704
                                        function(____, item) return tostring(item) end -- 704
                                    ), -- 704
                                    "," -- 704
                                ) -- 704
                                items[#items + 1] = (name .. ":") .. valueStr -- 705
                            else -- 705
                                items[#items + 1] = (name .. ":") .. tostring(v) -- 707
                            end -- 707
                            break -- 709
                        end -- 709
                    end -- 709
                    do -- 709
                        items[#items + 1] = (name .. ":") .. tostring(v) -- 712
                        break -- 713
                    end -- 713
                until true -- 713
            end -- 713
            local styleStr = table.concat(items, ";") -- 716
            node:css(styleStr) -- 717
        end -- 717
        if alignNode.onLayout then -- 717
            node:slot("AlignLayout", alignNode.onLayout) -- 720
        end -- 720
        local cnode = getNode(enode, node, handleAlignNode) -- 722
        return cnode -- 723
    end -- 692
end -- 692
local function getEffekNode(enode) -- 727
    return getNode( -- 728
        enode, -- 728
        Dora.EffekNode() -- 728
    ) -- 728
end -- 727
local getTileNode -- 731
do -- 731
    local function handleTileNodeAttribute(cnode, _enode, k, v) -- 733
        repeat -- 733
            local ____switch157 = k -- 733
            local ____cond157 = ____switch157 == "file" or ____switch157 == "layers" -- 733
            if ____cond157 then -- 733
                return true -- 735
            end -- 735
            ____cond157 = ____cond157 or ____switch157 == "depthWrite" -- 735
            if ____cond157 then -- 735
                cnode.depthWrite = v -- 736
                return true -- 736
            end -- 736
            ____cond157 = ____cond157 or ____switch157 == "blendFunc" -- 736
            if ____cond157 then -- 736
                cnode.blendFunc = v -- 737
                return true -- 737
            end -- 737
            ____cond157 = ____cond157 or ____switch157 == "effect" -- 737
            if ____cond157 then -- 737
                cnode.effect = v -- 738
                return true -- 738
            end -- 738
            ____cond157 = ____cond157 or ____switch157 == "filter" -- 738
            if ____cond157 then -- 738
                cnode.filter = v -- 739
                return true -- 739
            end -- 739
        until true -- 739
        return false -- 741
    end -- 733
    getTileNode = function(enode) -- 743
        local tn = enode.props -- 744
        local ____tn_layers_9 -- 745
        if tn.layers then -- 745
            ____tn_layers_9 = Dora.TileNode(tn.file, tn.layers) -- 745
        else -- 745
            ____tn_layers_9 = Dora.TileNode(tn.file) -- 745
        end -- 745
        local node = ____tn_layers_9 -- 745
        if node ~= nil then -- 745
            local cnode = getNode(enode, node, handleTileNodeAttribute) -- 747
            return cnode -- 748
        end -- 748
        return nil -- 750
    end -- 743
end -- 743
local function addChild(nodeStack, cnode, enode) -- 754
    if #nodeStack > 0 then -- 754
        local last = nodeStack[#nodeStack] -- 756
        last:addChild(cnode) -- 757
    end -- 757
    nodeStack[#nodeStack + 1] = cnode -- 759
    local ____enode_10 = enode -- 760
    local children = ____enode_10.children -- 760
    for i = 1, #children do -- 760
        visitNode(nodeStack, children[i], enode) -- 762
    end -- 762
    if #nodeStack > 1 then -- 762
        table.remove(nodeStack) -- 765
    end -- 765
end -- 754
local function drawNodeCheck(_nodeStack, enode, parent) -- 773
    if parent == nil or parent.type ~= "draw-node" then -- 773
        Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 775
    end -- 775
end -- 773
local function visitAction(actionStack, enode) -- 779
    local createAction = actionMap[enode.type] -- 780
    if createAction ~= nil then -- 780
        actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 782
        return -- 783
    end -- 783
    repeat -- 783
        local ____switch168 = enode.type -- 783
        local ____cond168 = ____switch168 == "delay" -- 783
        if ____cond168 then -- 783
            do -- 783
                local item = enode.props -- 787
                actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 788
                break -- 789
            end -- 789
        end -- 789
        ____cond168 = ____cond168 or ____switch168 == "event" -- 789
        if ____cond168 then -- 789
            do -- 789
                local item = enode.props -- 792
                actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 793
                break -- 794
            end -- 794
        end -- 794
        ____cond168 = ____cond168 or ____switch168 == "hide" -- 794
        if ____cond168 then -- 794
            do -- 794
                actionStack[#actionStack + 1] = Dora.Hide() -- 797
                break -- 798
            end -- 798
        end -- 798
        ____cond168 = ____cond168 or ____switch168 == "show" -- 798
        if ____cond168 then -- 798
            do -- 798
                actionStack[#actionStack + 1] = Dora.Show() -- 801
                break -- 802
            end -- 802
        end -- 802
        ____cond168 = ____cond168 or ____switch168 == "move" -- 802
        if ____cond168 then -- 802
            do -- 802
                local item = enode.props -- 805
                actionStack[#actionStack + 1] = Dora.Move( -- 806
                    item.time, -- 806
                    Dora.Vec2(item.startX, item.startY), -- 806
                    Dora.Vec2(item.stopX, item.stopY), -- 806
                    item.easing -- 806
                ) -- 806
                break -- 807
            end -- 807
        end -- 807
        ____cond168 = ____cond168 or ____switch168 == "spawn" -- 807
        if ____cond168 then -- 807
            do -- 807
                local spawnStack = {} -- 810
                for i = 1, #enode.children do -- 810
                    visitAction(spawnStack, enode.children[i]) -- 812
                end -- 812
                actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 814
                break -- 815
            end -- 815
        end -- 815
        ____cond168 = ____cond168 or ____switch168 == "sequence" -- 815
        if ____cond168 then -- 815
            do -- 815
                local sequenceStack = {} -- 818
                for i = 1, #enode.children do -- 818
                    visitAction(sequenceStack, enode.children[i]) -- 820
                end -- 820
                actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 822
                break -- 823
            end -- 823
        end -- 823
        do -- 823
            Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 826
            break -- 827
        end -- 827
    until true -- 827
end -- 779
local function actionCheck(nodeStack, enode, parent) -- 831
    local unsupported = false -- 832
    if parent == nil then -- 832
        unsupported = true -- 834
    else -- 834
        repeat -- 834
            local ____switch181 = parent.type -- 834
            local ____cond181 = ____switch181 == "action" or ____switch181 == "spawn" or ____switch181 == "sequence" -- 834
            if ____cond181 then -- 834
                break -- 837
            end -- 837
            do -- 837
                unsupported = true -- 838
                break -- 838
            end -- 838
        until true -- 838
    end -- 838
    if unsupported then -- 838
        if #nodeStack > 0 then -- 838
            local node = nodeStack[#nodeStack] -- 843
            local actionStack = {} -- 844
            visitAction(actionStack, enode) -- 845
            if #actionStack == 1 then -- 845
                node:runAction(actionStack[1]) -- 847
            end -- 847
        else -- 847
            Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 850
        end -- 850
    end -- 850
end -- 831
local function bodyCheck(_nodeStack, enode, parent) -- 855
    if parent == nil or parent.type ~= "body" then -- 855
        Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 857
    end -- 857
end -- 855
actionMap = { -- 861
    ["anchor-x"] = Dora.AnchorX, -- 864
    ["anchor-y"] = Dora.AnchorY, -- 865
    angle = Dora.Angle, -- 866
    ["angle-x"] = Dora.AngleX, -- 867
    ["angle-y"] = Dora.AngleY, -- 868
    width = Dora.Width, -- 869
    height = Dora.Height, -- 870
    opacity = Dora.Opacity, -- 871
    roll = Dora.Roll, -- 872
    scale = Dora.Scale, -- 873
    ["scale-x"] = Dora.ScaleX, -- 874
    ["scale-y"] = Dora.ScaleY, -- 875
    ["skew-x"] = Dora.SkewX, -- 876
    ["skew-y"] = Dora.SkewY, -- 877
    ["move-x"] = Dora.X, -- 878
    ["move-y"] = Dora.Y, -- 879
    ["move-z"] = Dora.Z -- 880
} -- 880
elementMap = { -- 883
    node = function(nodeStack, enode, parent) -- 884
        addChild( -- 885
            nodeStack, -- 885
            getNode(enode), -- 885
            enode -- 885
        ) -- 885
    end, -- 884
    ["clip-node"] = function(nodeStack, enode, parent) -- 887
        addChild( -- 888
            nodeStack, -- 888
            getClipNode(enode), -- 888
            enode -- 888
        ) -- 888
    end, -- 887
    playable = function(nodeStack, enode, parent) -- 890
        local cnode = getPlayable(enode) -- 891
        if cnode ~= nil then -- 891
            addChild(nodeStack, cnode, enode) -- 893
        end -- 893
    end, -- 890
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 896
        local cnode = getDragonBone(enode) -- 897
        if cnode ~= nil then -- 897
            addChild(nodeStack, cnode, enode) -- 899
        end -- 899
    end, -- 896
    spine = function(nodeStack, enode, parent) -- 902
        local cnode = getSpine(enode) -- 903
        if cnode ~= nil then -- 903
            addChild(nodeStack, cnode, enode) -- 905
        end -- 905
    end, -- 902
    model = function(nodeStack, enode, parent) -- 908
        local cnode = getModel(enode) -- 909
        if cnode ~= nil then -- 909
            addChild(nodeStack, cnode, enode) -- 911
        end -- 911
    end, -- 908
    ["draw-node"] = function(nodeStack, enode, parent) -- 914
        addChild( -- 915
            nodeStack, -- 915
            getDrawNode(enode), -- 915
            enode -- 915
        ) -- 915
    end, -- 914
    ["dot-shape"] = drawNodeCheck, -- 917
    ["segment-shape"] = drawNodeCheck, -- 918
    ["rect-shape"] = drawNodeCheck, -- 919
    ["polygon-shape"] = drawNodeCheck, -- 920
    ["verts-shape"] = drawNodeCheck, -- 921
    grid = function(nodeStack, enode, parent) -- 922
        addChild( -- 923
            nodeStack, -- 923
            getGrid(enode), -- 923
            enode -- 923
        ) -- 923
    end, -- 922
    sprite = function(nodeStack, enode, parent) -- 925
        local cnode = getSprite(enode) -- 926
        if cnode ~= nil then -- 926
            addChild(nodeStack, cnode, enode) -- 928
        end -- 928
    end, -- 925
    label = function(nodeStack, enode, parent) -- 931
        local cnode = getLabel(enode) -- 932
        if cnode ~= nil then -- 932
            addChild(nodeStack, cnode, enode) -- 934
        end -- 934
    end, -- 931
    line = function(nodeStack, enode, parent) -- 937
        addChild( -- 938
            nodeStack, -- 938
            getLine(enode), -- 938
            enode -- 938
        ) -- 938
    end, -- 937
    particle = function(nodeStack, enode, parent) -- 940
        local cnode = getParticle(enode) -- 941
        if cnode ~= nil then -- 941
            addChild(nodeStack, cnode, enode) -- 943
        end -- 943
    end, -- 940
    menu = function(nodeStack, enode, parent) -- 946
        addChild( -- 947
            nodeStack, -- 947
            getMenu(enode), -- 947
            enode -- 947
        ) -- 947
    end, -- 946
    action = function(_nodeStack, enode, parent) -- 949
        if #enode.children == 0 then -- 949
            Warn("<action> tag has no children") -- 951
            return -- 952
        end -- 952
        local action = enode.props -- 954
        if action.ref == nil then -- 954
            Warn("<action> tag has no ref") -- 956
            return -- 957
        end -- 957
        local actionStack = {} -- 959
        for i = 1, #enode.children do -- 959
            visitAction(actionStack, enode.children[i]) -- 961
        end -- 961
        if #actionStack == 1 then -- 961
            action.ref.current = actionStack[1] -- 964
        elseif #actionStack > 1 then -- 964
            action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 966
        end -- 966
    end, -- 949
    ["anchor-x"] = actionCheck, -- 969
    ["anchor-y"] = actionCheck, -- 970
    angle = actionCheck, -- 971
    ["angle-x"] = actionCheck, -- 972
    ["angle-y"] = actionCheck, -- 973
    delay = actionCheck, -- 974
    event = actionCheck, -- 975
    width = actionCheck, -- 976
    height = actionCheck, -- 977
    hide = actionCheck, -- 978
    show = actionCheck, -- 979
    move = actionCheck, -- 980
    opacity = actionCheck, -- 981
    roll = actionCheck, -- 982
    scale = actionCheck, -- 983
    ["scale-x"] = actionCheck, -- 984
    ["scale-y"] = actionCheck, -- 985
    ["skew-x"] = actionCheck, -- 986
    ["skew-y"] = actionCheck, -- 987
    ["move-x"] = actionCheck, -- 988
    ["move-y"] = actionCheck, -- 989
    ["move-z"] = actionCheck, -- 990
    spawn = actionCheck, -- 991
    sequence = actionCheck, -- 992
    loop = function(nodeStack, enode, _parent) -- 993
        if #nodeStack > 0 then -- 993
            local node = nodeStack[#nodeStack] -- 995
            local actionStack = {} -- 996
            for i = 1, #enode.children do -- 996
                visitAction(actionStack, enode.children[i]) -- 998
            end -- 998
            if #actionStack == 1 then -- 998
                node:runAction(actionStack[1], true) -- 1001
            else -- 1001
                local loop = enode.props -- 1003
                if loop.spawn then -- 1003
                    node:runAction( -- 1005
                        Dora.Spawn(table.unpack(actionStack)), -- 1005
                        true -- 1005
                    ) -- 1005
                else -- 1005
                    node:runAction( -- 1007
                        Dora.Sequence(table.unpack(actionStack)), -- 1007
                        true -- 1007
                    ) -- 1007
                end -- 1007
            end -- 1007
        else -- 1007
            Warn("tag <loop> must be placed under a scene node to take effect") -- 1011
        end -- 1011
    end, -- 993
    ["physics-world"] = function(nodeStack, enode, _parent) -- 1014
        addChild( -- 1015
            nodeStack, -- 1015
            getPhysicsWorld(enode), -- 1015
            enode -- 1015
        ) -- 1015
    end, -- 1014
    contact = function(nodeStack, enode, _parent) -- 1017
        local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1018
        if world ~= nil then -- 1018
            local contact = enode.props -- 1020
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1021
        else -- 1021
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1023
        end -- 1023
    end, -- 1017
    body = function(nodeStack, enode, _parent) -- 1026
        local def = enode.props -- 1027
        if def.world then -- 1027
            addChild( -- 1029
                nodeStack, -- 1029
                getBody(enode, def.world), -- 1029
                enode -- 1029
            ) -- 1029
            return -- 1030
        end -- 1030
        local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1032
        if world ~= nil then -- 1032
            addChild( -- 1034
                nodeStack, -- 1034
                getBody(enode, world), -- 1034
                enode -- 1034
            ) -- 1034
        else -- 1034
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1036
        end -- 1036
    end, -- 1026
    ["rect-fixture"] = bodyCheck, -- 1039
    ["polygon-fixture"] = bodyCheck, -- 1040
    ["multi-fixture"] = bodyCheck, -- 1041
    ["disk-fixture"] = bodyCheck, -- 1042
    ["chain-fixture"] = bodyCheck, -- 1043
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 1044
        local joint = enode.props -- 1045
        if joint.ref == nil then -- 1045
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1047
            return -- 1048
        end -- 1048
        if joint.bodyA.current == nil then -- 1048
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1051
            return -- 1052
        end -- 1052
        if joint.bodyB.current == nil then -- 1052
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1055
            return -- 1056
        end -- 1056
        local ____joint_ref_14 = joint.ref -- 1058
        local ____self_12 = Dora.Joint -- 1058
        local ____self_12_distance_13 = ____self_12.distance -- 1058
        local ____joint_canCollide_11 = joint.canCollide -- 1059
        if ____joint_canCollide_11 == nil then -- 1059
            ____joint_canCollide_11 = false -- 1059
        end -- 1059
        ____joint_ref_14.current = ____self_12_distance_13( -- 1058
            ____self_12, -- 1058
            ____joint_canCollide_11, -- 1059
            joint.bodyA.current, -- 1060
            joint.bodyB.current, -- 1061
            joint.anchorA or Dora.Vec2.zero, -- 1062
            joint.anchorB or Dora.Vec2.zero, -- 1063
            joint.frequency or 0, -- 1064
            joint.damping or 0 -- 1065
        ) -- 1065
    end, -- 1044
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 1067
        local joint = enode.props -- 1068
        if joint.ref == nil then -- 1068
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1070
            return -- 1071
        end -- 1071
        if joint.bodyA.current == nil then -- 1071
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1074
            return -- 1075
        end -- 1075
        if joint.bodyB.current == nil then -- 1075
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1078
            return -- 1079
        end -- 1079
        local ____joint_ref_18 = joint.ref -- 1081
        local ____self_16 = Dora.Joint -- 1081
        local ____self_16_friction_17 = ____self_16.friction -- 1081
        local ____joint_canCollide_15 = joint.canCollide -- 1082
        if ____joint_canCollide_15 == nil then -- 1082
            ____joint_canCollide_15 = false -- 1082
        end -- 1082
        ____joint_ref_18.current = ____self_16_friction_17( -- 1081
            ____self_16, -- 1081
            ____joint_canCollide_15, -- 1082
            joint.bodyA.current, -- 1083
            joint.bodyB.current, -- 1084
            joint.worldPos, -- 1085
            joint.maxForce, -- 1086
            joint.maxTorque -- 1087
        ) -- 1087
    end, -- 1067
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 1090
        local joint = enode.props -- 1091
        if joint.ref == nil then -- 1091
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1093
            return -- 1094
        end -- 1094
        if joint.jointA.current == nil then -- 1094
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1097
            return -- 1098
        end -- 1098
        if joint.jointB.current == nil then -- 1098
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1101
            return -- 1102
        end -- 1102
        local ____joint_ref_22 = joint.ref -- 1104
        local ____self_20 = Dora.Joint -- 1104
        local ____self_20_gear_21 = ____self_20.gear -- 1104
        local ____joint_canCollide_19 = joint.canCollide -- 1105
        if ____joint_canCollide_19 == nil then -- 1105
            ____joint_canCollide_19 = false -- 1105
        end -- 1105
        ____joint_ref_22.current = ____self_20_gear_21( -- 1104
            ____self_20, -- 1104
            ____joint_canCollide_19, -- 1105
            joint.jointA.current, -- 1106
            joint.jointB.current, -- 1107
            joint.ratio or 1 -- 1108
        ) -- 1108
    end, -- 1090
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 1111
        local joint = enode.props -- 1112
        if joint.ref == nil then -- 1112
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1114
            return -- 1115
        end -- 1115
        if joint.bodyA.current == nil then -- 1115
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1118
            return -- 1119
        end -- 1119
        if joint.bodyB.current == nil then -- 1119
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1122
            return -- 1123
        end -- 1123
        local ____joint_ref_26 = joint.ref -- 1125
        local ____self_24 = Dora.Joint -- 1125
        local ____self_24_spring_25 = ____self_24.spring -- 1125
        local ____joint_canCollide_23 = joint.canCollide -- 1126
        if ____joint_canCollide_23 == nil then -- 1126
            ____joint_canCollide_23 = false -- 1126
        end -- 1126
        ____joint_ref_26.current = ____self_24_spring_25( -- 1125
            ____self_24, -- 1125
            ____joint_canCollide_23, -- 1126
            joint.bodyA.current, -- 1127
            joint.bodyB.current, -- 1128
            joint.linearOffset, -- 1129
            joint.angularOffset, -- 1130
            joint.maxForce, -- 1131
            joint.maxTorque, -- 1132
            joint.correctionFactor or 1 -- 1133
        ) -- 1133
    end, -- 1111
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1136
        local joint = enode.props -- 1137
        if joint.ref == nil then -- 1137
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1139
            return -- 1140
        end -- 1140
        if joint.body.current == nil then -- 1140
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1143
            return -- 1144
        end -- 1144
        local ____joint_ref_30 = joint.ref -- 1146
        local ____self_28 = Dora.Joint -- 1146
        local ____self_28_move_29 = ____self_28.move -- 1146
        local ____joint_canCollide_27 = joint.canCollide -- 1147
        if ____joint_canCollide_27 == nil then -- 1147
            ____joint_canCollide_27 = false -- 1147
        end -- 1147
        ____joint_ref_30.current = ____self_28_move_29( -- 1146
            ____self_28, -- 1146
            ____joint_canCollide_27, -- 1147
            joint.body.current, -- 1148
            joint.targetPos, -- 1149
            joint.maxForce, -- 1150
            joint.frequency, -- 1151
            joint.damping or 0.7 -- 1152
        ) -- 1152
    end, -- 1136
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1155
        local joint = enode.props -- 1156
        if joint.ref == nil then -- 1156
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1158
            return -- 1159
        end -- 1159
        if joint.bodyA.current == nil then -- 1159
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1162
            return -- 1163
        end -- 1163
        if joint.bodyB.current == nil then -- 1163
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1166
            return -- 1167
        end -- 1167
        local ____joint_ref_34 = joint.ref -- 1169
        local ____self_32 = Dora.Joint -- 1169
        local ____self_32_prismatic_33 = ____self_32.prismatic -- 1169
        local ____joint_canCollide_31 = joint.canCollide -- 1170
        if ____joint_canCollide_31 == nil then -- 1170
            ____joint_canCollide_31 = false -- 1170
        end -- 1170
        ____joint_ref_34.current = ____self_32_prismatic_33( -- 1169
            ____self_32, -- 1169
            ____joint_canCollide_31, -- 1170
            joint.bodyA.current, -- 1171
            joint.bodyB.current, -- 1172
            joint.worldPos, -- 1173
            joint.axisAngle, -- 1174
            joint.lowerTranslation or 0, -- 1175
            joint.upperTranslation or 0, -- 1176
            joint.maxMotorForce or 0, -- 1177
            joint.motorSpeed or 0 -- 1178
        ) -- 1178
    end, -- 1155
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1181
        local joint = enode.props -- 1182
        if joint.ref == nil then -- 1182
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1184
            return -- 1185
        end -- 1185
        if joint.bodyA.current == nil then -- 1185
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1188
            return -- 1189
        end -- 1189
        if joint.bodyB.current == nil then -- 1189
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1192
            return -- 1193
        end -- 1193
        local ____joint_ref_38 = joint.ref -- 1195
        local ____self_36 = Dora.Joint -- 1195
        local ____self_36_pulley_37 = ____self_36.pulley -- 1195
        local ____joint_canCollide_35 = joint.canCollide -- 1196
        if ____joint_canCollide_35 == nil then -- 1196
            ____joint_canCollide_35 = false -- 1196
        end -- 1196
        ____joint_ref_38.current = ____self_36_pulley_37( -- 1195
            ____self_36, -- 1195
            ____joint_canCollide_35, -- 1196
            joint.bodyA.current, -- 1197
            joint.bodyB.current, -- 1198
            joint.anchorA or Dora.Vec2.zero, -- 1199
            joint.anchorB or Dora.Vec2.zero, -- 1200
            joint.groundAnchorA, -- 1201
            joint.groundAnchorB, -- 1202
            joint.ratio or 1 -- 1203
        ) -- 1203
    end, -- 1181
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1206
        local joint = enode.props -- 1207
        if joint.ref == nil then -- 1207
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1209
            return -- 1210
        end -- 1210
        if joint.bodyA.current == nil then -- 1210
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1213
            return -- 1214
        end -- 1214
        if joint.bodyB.current == nil then -- 1214
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1217
            return -- 1218
        end -- 1218
        local ____joint_ref_42 = joint.ref -- 1220
        local ____self_40 = Dora.Joint -- 1220
        local ____self_40_revolute_41 = ____self_40.revolute -- 1220
        local ____joint_canCollide_39 = joint.canCollide -- 1221
        if ____joint_canCollide_39 == nil then -- 1221
            ____joint_canCollide_39 = false -- 1221
        end -- 1221
        ____joint_ref_42.current = ____self_40_revolute_41( -- 1220
            ____self_40, -- 1220
            ____joint_canCollide_39, -- 1221
            joint.bodyA.current, -- 1222
            joint.bodyB.current, -- 1223
            joint.worldPos, -- 1224
            joint.lowerAngle or 0, -- 1225
            joint.upperAngle or 0, -- 1226
            joint.maxMotorTorque or 0, -- 1227
            joint.motorSpeed or 0 -- 1228
        ) -- 1228
    end, -- 1206
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1231
        local joint = enode.props -- 1232
        if joint.ref == nil then -- 1232
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1234
            return -- 1235
        end -- 1235
        if joint.bodyA.current == nil then -- 1235
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1238
            return -- 1239
        end -- 1239
        if joint.bodyB.current == nil then -- 1239
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1242
            return -- 1243
        end -- 1243
        local ____joint_ref_46 = joint.ref -- 1245
        local ____self_44 = Dora.Joint -- 1245
        local ____self_44_rope_45 = ____self_44.rope -- 1245
        local ____joint_canCollide_43 = joint.canCollide -- 1246
        if ____joint_canCollide_43 == nil then -- 1246
            ____joint_canCollide_43 = false -- 1246
        end -- 1246
        ____joint_ref_46.current = ____self_44_rope_45( -- 1245
            ____self_44, -- 1245
            ____joint_canCollide_43, -- 1246
            joint.bodyA.current, -- 1247
            joint.bodyB.current, -- 1248
            joint.anchorA or Dora.Vec2.zero, -- 1249
            joint.anchorB or Dora.Vec2.zero, -- 1250
            joint.maxLength or 0 -- 1251
        ) -- 1251
    end, -- 1231
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1254
        local joint = enode.props -- 1255
        if joint.ref == nil then -- 1255
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1257
            return -- 1258
        end -- 1258
        if joint.bodyA.current == nil then -- 1258
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1261
            return -- 1262
        end -- 1262
        if joint.bodyB.current == nil then -- 1262
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1265
            return -- 1266
        end -- 1266
        local ____joint_ref_50 = joint.ref -- 1268
        local ____self_48 = Dora.Joint -- 1268
        local ____self_48_weld_49 = ____self_48.weld -- 1268
        local ____joint_canCollide_47 = joint.canCollide -- 1269
        if ____joint_canCollide_47 == nil then -- 1269
            ____joint_canCollide_47 = false -- 1269
        end -- 1269
        ____joint_ref_50.current = ____self_48_weld_49( -- 1268
            ____self_48, -- 1268
            ____joint_canCollide_47, -- 1269
            joint.bodyA.current, -- 1270
            joint.bodyB.current, -- 1271
            joint.worldPos, -- 1272
            joint.frequency or 0, -- 1273
            joint.damping or 0 -- 1274
        ) -- 1274
    end, -- 1254
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1277
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
        local ____joint_ref_54 = joint.ref -- 1291
        local ____self_52 = Dora.Joint -- 1291
        local ____self_52_wheel_53 = ____self_52.wheel -- 1291
        local ____joint_canCollide_51 = joint.canCollide -- 1292
        if ____joint_canCollide_51 == nil then -- 1292
            ____joint_canCollide_51 = false -- 1292
        end -- 1292
        ____joint_ref_54.current = ____self_52_wheel_53( -- 1291
            ____self_52, -- 1291
            ____joint_canCollide_51, -- 1292
            joint.bodyA.current, -- 1293
            joint.bodyB.current, -- 1294
            joint.worldPos, -- 1295
            joint.axisAngle, -- 1296
            joint.maxMotorTorque or 0, -- 1297
            joint.motorSpeed or 0, -- 1298
            joint.frequency or 0, -- 1299
            joint.damping or 0.7 -- 1300
        ) -- 1300
    end, -- 1277
    ["custom-node"] = function(nodeStack, enode, _parent) -- 1303
        local node = getCustomNode(enode) -- 1304
        if node ~= nil then -- 1304
            addChild(nodeStack, node, enode) -- 1306
        end -- 1306
    end, -- 1303
    ["custom-element"] = function() -- 1309
    end, -- 1309
    ["align-node"] = function(nodeStack, enode, _parent) -- 1310
        addChild( -- 1311
            nodeStack, -- 1311
            getAlignNode(enode), -- 1311
            enode -- 1311
        ) -- 1311
    end, -- 1310
    ["effek-node"] = function(nodeStack, enode, _parent) -- 1313
        addChild( -- 1314
            nodeStack, -- 1314
            getEffekNode(enode), -- 1314
            enode -- 1314
        ) -- 1314
    end, -- 1313
    effek = function(nodeStack, enode, parent) -- 1316
        if #nodeStack > 0 then -- 1316
            local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1318
            if node then -- 1318
                local effek = enode.props -- 1320
                local handle = node:play( -- 1321
                    effek.file, -- 1321
                    Dora.Vec2(effek.x or 0, effek.y or 0), -- 1321
                    effek.z or 0 -- 1321
                ) -- 1321
                if handle >= 0 then -- 1321
                    if effek.ref then -- 1321
                        effek.ref.current = handle -- 1324
                    end -- 1324
                    if effek.onEnd then -- 1324
                        local onEnd = effek.onEnd -- 1324
                        node:slot( -- 1328
                            "EffekEnd", -- 1328
                            function(h) -- 1328
                                if handle == h then -- 1328
                                    onEnd(nil) -- 1330
                                end -- 1330
                            end -- 1328
                        ) -- 1328
                    end -- 1328
                end -- 1328
            else -- 1328
                Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1336
            end -- 1336
        end -- 1336
    end, -- 1316
    ["tile-node"] = function(nodeStack, enode, parent) -- 1340
        local cnode = getTileNode(enode) -- 1341
        if cnode ~= nil then -- 1341
            addChild(nodeStack, cnode, enode) -- 1343
        end -- 1343
    end -- 1340
} -- 1340
function ____exports.useRef(item) -- 1388
    local ____item_55 = item -- 1389
    if ____item_55 == nil then -- 1389
        ____item_55 = nil -- 1389
    end -- 1389
    return {current = ____item_55} -- 1389
end -- 1388
local function getPreload(preloadList, node) -- 1392
    if type(node) ~= "table" then -- 1392
        return -- 1394
    end -- 1394
    local enode = node -- 1396
    if enode.type == nil then -- 1396
        local list = node -- 1398
        if #list > 0 then -- 1398
            for i = 1, #list do -- 1398
                getPreload(preloadList, list[i]) -- 1401
            end -- 1401
        end -- 1401
    else -- 1401
        repeat -- 1401
            local ____switch309 = enode.type -- 1401
            local sprite, playable, model, spine, dragonBone, label -- 1401
            local ____cond309 = ____switch309 == "sprite" -- 1401
            if ____cond309 then -- 1401
                sprite = enode.props -- 1407
                preloadList[#preloadList + 1] = sprite.file -- 1408
                break -- 1409
            end -- 1409
            ____cond309 = ____cond309 or ____switch309 == "playable" -- 1409
            if ____cond309 then -- 1409
                playable = enode.props -- 1411
                preloadList[#preloadList + 1] = playable.file -- 1412
                break -- 1413
            end -- 1413
            ____cond309 = ____cond309 or ____switch309 == "model" -- 1413
            if ____cond309 then -- 1413
                model = enode.props -- 1415
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1416
                break -- 1417
            end -- 1417
            ____cond309 = ____cond309 or ____switch309 == "spine" -- 1417
            if ____cond309 then -- 1417
                spine = enode.props -- 1419
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1420
                break -- 1421
            end -- 1421
            ____cond309 = ____cond309 or ____switch309 == "dragon-bone" -- 1421
            if ____cond309 then -- 1421
                dragonBone = enode.props -- 1423
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1424
                break -- 1425
            end -- 1425
            ____cond309 = ____cond309 or ____switch309 == "label" -- 1425
            if ____cond309 then -- 1425
                label = enode.props -- 1427
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1428
                break -- 1429
            end -- 1429
        until true -- 1429
    end -- 1429
    getPreload(preloadList, enode.children) -- 1432
end -- 1392
function ____exports.preloadAsync(enode, handler) -- 1435
    local preloadList = {} -- 1436
    getPreload(preloadList, enode) -- 1437
    Dora.Cache:loadAsync(preloadList, handler) -- 1438
end -- 1435
return ____exports -- 1435