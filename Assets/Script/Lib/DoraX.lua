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
function visitNode(nodeStack, node, parent) -- 1318
    if type(node) ~= "table" then -- 1318
        return -- 1320
    end -- 1320
    local enode = node -- 1322
    if enode.type == nil then -- 1322
        local list = node -- 1324
        if #list > 0 then -- 1324
            for i = 1, #list do -- 1324
                local stack = {} -- 1327
                visitNode(stack, list[i], parent) -- 1328
                for i = 1, #stack do -- 1328
                    nodeStack[#nodeStack + 1] = stack[i] -- 1330
                end -- 1330
            end -- 1330
        end -- 1330
    else -- 1330
        local handler = elementMap[enode.type] -- 1335
        if handler ~= nil then -- 1335
            handler(nodeStack, enode, parent) -- 1337
        else -- 1337
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1339
        end -- 1339
    end -- 1339
end -- 1339
function ____exports.toNode(enode) -- 1344
    local nodeStack = {} -- 1345
    visitNode(nodeStack, enode) -- 1346
    if #nodeStack == 1 then -- 1346
        return nodeStack[1] -- 1348
    elseif #nodeStack > 1 then -- 1348
        local node = Dora.Node() -- 1350
        for i = 1, #nodeStack do -- 1350
            node:addChild(nodeStack[i]) -- 1352
        end -- 1352
        return node -- 1354
    end -- 1354
    return nil -- 1356
end -- 1344
____exports.React = {} -- 1344
local React = ____exports.React -- 1344
do -- 1344
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
local function addChild(nodeStack, cnode, enode) -- 731
    if #nodeStack > 0 then -- 731
        local last = nodeStack[#nodeStack] -- 733
        last:addChild(cnode) -- 734
    end -- 734
    nodeStack[#nodeStack + 1] = cnode -- 736
    local ____enode_9 = enode -- 737
    local children = ____enode_9.children -- 737
    for i = 1, #children do -- 737
        visitNode(nodeStack, children[i], enode) -- 739
    end -- 739
    if #nodeStack > 1 then -- 739
        table.remove(nodeStack) -- 742
    end -- 742
end -- 731
local function drawNodeCheck(_nodeStack, enode, parent) -- 750
    if parent == nil or parent.type ~= "draw-node" then -- 750
        Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 752
    end -- 752
end -- 750
local function visitAction(actionStack, enode) -- 756
    local createAction = actionMap[enode.type] -- 757
    if createAction ~= nil then -- 757
        actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 759
        return -- 760
    end -- 760
    repeat -- 760
        local ____switch163 = enode.type -- 760
        local ____cond163 = ____switch163 == "delay" -- 760
        if ____cond163 then -- 760
            do -- 760
                local item = enode.props -- 764
                actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 765
                break -- 766
            end -- 766
        end -- 766
        ____cond163 = ____cond163 or ____switch163 == "event" -- 766
        if ____cond163 then -- 766
            do -- 766
                local item = enode.props -- 769
                actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 770
                break -- 771
            end -- 771
        end -- 771
        ____cond163 = ____cond163 or ____switch163 == "hide" -- 771
        if ____cond163 then -- 771
            do -- 771
                actionStack[#actionStack + 1] = Dora.Hide() -- 774
                break -- 775
            end -- 775
        end -- 775
        ____cond163 = ____cond163 or ____switch163 == "show" -- 775
        if ____cond163 then -- 775
            do -- 775
                actionStack[#actionStack + 1] = Dora.Show() -- 778
                break -- 779
            end -- 779
        end -- 779
        ____cond163 = ____cond163 or ____switch163 == "move" -- 779
        if ____cond163 then -- 779
            do -- 779
                local item = enode.props -- 782
                actionStack[#actionStack + 1] = Dora.Move( -- 783
                    item.time, -- 783
                    Dora.Vec2(item.startX, item.startY), -- 783
                    Dora.Vec2(item.stopX, item.stopY), -- 783
                    item.easing -- 783
                ) -- 783
                break -- 784
            end -- 784
        end -- 784
        ____cond163 = ____cond163 or ____switch163 == "spawn" -- 784
        if ____cond163 then -- 784
            do -- 784
                local spawnStack = {} -- 787
                for i = 1, #enode.children do -- 787
                    visitAction(spawnStack, enode.children[i]) -- 789
                end -- 789
                actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 791
                break -- 792
            end -- 792
        end -- 792
        ____cond163 = ____cond163 or ____switch163 == "sequence" -- 792
        if ____cond163 then -- 792
            do -- 792
                local sequenceStack = {} -- 795
                for i = 1, #enode.children do -- 795
                    visitAction(sequenceStack, enode.children[i]) -- 797
                end -- 797
                actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 799
                break -- 800
            end -- 800
        end -- 800
        do -- 800
            Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 803
            break -- 804
        end -- 804
    until true -- 804
end -- 756
local function actionCheck(nodeStack, enode, parent) -- 808
    local unsupported = false -- 809
    if parent == nil then -- 809
        unsupported = true -- 811
    else -- 811
        repeat -- 811
            local ____switch176 = parent.type -- 811
            local ____cond176 = ____switch176 == "action" or ____switch176 == "spawn" or ____switch176 == "sequence" -- 811
            if ____cond176 then -- 811
                break -- 814
            end -- 814
            do -- 814
                unsupported = true -- 815
                break -- 815
            end -- 815
        until true -- 815
    end -- 815
    if unsupported then -- 815
        if #nodeStack > 0 then -- 815
            local node = nodeStack[#nodeStack] -- 820
            local actionStack = {} -- 821
            visitAction(actionStack, enode) -- 822
            if #actionStack == 1 then -- 822
                node:runAction(actionStack[1]) -- 824
            end -- 824
        else -- 824
            Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 827
        end -- 827
    end -- 827
end -- 808
local function bodyCheck(_nodeStack, enode, parent) -- 832
    if parent == nil or parent.type ~= "body" then -- 832
        Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 834
    end -- 834
end -- 832
actionMap = { -- 838
    ["anchor-x"] = Dora.AnchorX, -- 841
    ["anchor-y"] = Dora.AnchorY, -- 842
    angle = Dora.Angle, -- 843
    ["angle-x"] = Dora.AngleX, -- 844
    ["angle-y"] = Dora.AngleY, -- 845
    width = Dora.Width, -- 846
    height = Dora.Height, -- 847
    opacity = Dora.Opacity, -- 848
    roll = Dora.Roll, -- 849
    scale = Dora.Scale, -- 850
    ["scale-x"] = Dora.ScaleX, -- 851
    ["scale-y"] = Dora.ScaleY, -- 852
    ["skew-x"] = Dora.SkewX, -- 853
    ["skew-y"] = Dora.SkewY, -- 854
    ["move-x"] = Dora.X, -- 855
    ["move-y"] = Dora.Y, -- 856
    ["move-z"] = Dora.Z -- 857
} -- 857
elementMap = { -- 860
    node = function(nodeStack, enode, parent) -- 861
        addChild( -- 862
            nodeStack, -- 862
            getNode(enode), -- 862
            enode -- 862
        ) -- 862
    end, -- 861
    ["clip-node"] = function(nodeStack, enode, parent) -- 864
        addChild( -- 865
            nodeStack, -- 865
            getClipNode(enode), -- 865
            enode -- 865
        ) -- 865
    end, -- 864
    playable = function(nodeStack, enode, parent) -- 867
        local cnode = getPlayable(enode) -- 868
        if cnode ~= nil then -- 868
            addChild(nodeStack, cnode, enode) -- 870
        end -- 870
    end, -- 867
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 873
        local cnode = getDragonBone(enode) -- 874
        if cnode ~= nil then -- 874
            addChild(nodeStack, cnode, enode) -- 876
        end -- 876
    end, -- 873
    spine = function(nodeStack, enode, parent) -- 879
        local cnode = getSpine(enode) -- 880
        if cnode ~= nil then -- 880
            addChild(nodeStack, cnode, enode) -- 882
        end -- 882
    end, -- 879
    model = function(nodeStack, enode, parent) -- 885
        local cnode = getModel(enode) -- 886
        if cnode ~= nil then -- 886
            addChild(nodeStack, cnode, enode) -- 888
        end -- 888
    end, -- 885
    ["draw-node"] = function(nodeStack, enode, parent) -- 891
        addChild( -- 892
            nodeStack, -- 892
            getDrawNode(enode), -- 892
            enode -- 892
        ) -- 892
    end, -- 891
    ["dot-shape"] = drawNodeCheck, -- 894
    ["segment-shape"] = drawNodeCheck, -- 895
    ["rect-shape"] = drawNodeCheck, -- 896
    ["polygon-shape"] = drawNodeCheck, -- 897
    ["verts-shape"] = drawNodeCheck, -- 898
    grid = function(nodeStack, enode, parent) -- 899
        addChild( -- 900
            nodeStack, -- 900
            getGrid(enode), -- 900
            enode -- 900
        ) -- 900
    end, -- 899
    sprite = function(nodeStack, enode, parent) -- 902
        local cnode = getSprite(enode) -- 903
        if cnode ~= nil then -- 903
            addChild(nodeStack, cnode, enode) -- 905
        end -- 905
    end, -- 902
    label = function(nodeStack, enode, parent) -- 908
        local cnode = getLabel(enode) -- 909
        if cnode ~= nil then -- 909
            addChild(nodeStack, cnode, enode) -- 911
        end -- 911
    end, -- 908
    line = function(nodeStack, enode, parent) -- 914
        addChild( -- 915
            nodeStack, -- 915
            getLine(enode), -- 915
            enode -- 915
        ) -- 915
    end, -- 914
    particle = function(nodeStack, enode, parent) -- 917
        local cnode = getParticle(enode) -- 918
        if cnode ~= nil then -- 918
            addChild(nodeStack, cnode, enode) -- 920
        end -- 920
    end, -- 917
    menu = function(nodeStack, enode, parent) -- 923
        addChild( -- 924
            nodeStack, -- 924
            getMenu(enode), -- 924
            enode -- 924
        ) -- 924
    end, -- 923
    action = function(_nodeStack, enode, parent) -- 926
        if #enode.children == 0 then -- 926
            Warn("<action> tag has no children") -- 928
            return -- 929
        end -- 929
        local action = enode.props -- 931
        if action.ref == nil then -- 931
            Warn("<action> tag has no ref") -- 933
            return -- 934
        end -- 934
        local actionStack = {} -- 936
        for i = 1, #enode.children do -- 936
            visitAction(actionStack, enode.children[i]) -- 938
        end -- 938
        if #actionStack == 1 then -- 938
            action.ref.current = actionStack[1] -- 941
        elseif #actionStack > 1 then -- 941
            action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 943
        end -- 943
    end, -- 926
    ["anchor-x"] = actionCheck, -- 946
    ["anchor-y"] = actionCheck, -- 947
    angle = actionCheck, -- 948
    ["angle-x"] = actionCheck, -- 949
    ["angle-y"] = actionCheck, -- 950
    delay = actionCheck, -- 951
    event = actionCheck, -- 952
    width = actionCheck, -- 953
    height = actionCheck, -- 954
    hide = actionCheck, -- 955
    show = actionCheck, -- 956
    move = actionCheck, -- 957
    opacity = actionCheck, -- 958
    roll = actionCheck, -- 959
    scale = actionCheck, -- 960
    ["scale-x"] = actionCheck, -- 961
    ["scale-y"] = actionCheck, -- 962
    ["skew-x"] = actionCheck, -- 963
    ["skew-y"] = actionCheck, -- 964
    ["move-x"] = actionCheck, -- 965
    ["move-y"] = actionCheck, -- 966
    ["move-z"] = actionCheck, -- 967
    spawn = actionCheck, -- 968
    sequence = actionCheck, -- 969
    loop = function(nodeStack, enode, _parent) -- 970
        if #nodeStack > 0 then -- 970
            local node = nodeStack[#nodeStack] -- 972
            local actionStack = {} -- 973
            for i = 1, #enode.children do -- 973
                visitAction(actionStack, enode.children[i]) -- 975
            end -- 975
            if #actionStack == 1 then -- 975
                node:runAction(actionStack[1], true) -- 978
            else -- 978
                local loop = enode.props -- 980
                if loop.spawn then -- 980
                    node:runAction( -- 982
                        Dora.Spawn(table.unpack(actionStack)), -- 982
                        true -- 982
                    ) -- 982
                else -- 982
                    node:runAction( -- 984
                        Dora.Sequence(table.unpack(actionStack)), -- 984
                        true -- 984
                    ) -- 984
                end -- 984
            end -- 984
        else -- 984
            Warn("tag <loop> must be placed under a scene node to take effect") -- 988
        end -- 988
    end, -- 970
    ["physics-world"] = function(nodeStack, enode, _parent) -- 991
        addChild( -- 992
            nodeStack, -- 992
            getPhysicsWorld(enode), -- 992
            enode -- 992
        ) -- 992
    end, -- 991
    contact = function(nodeStack, enode, _parent) -- 994
        local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 995
        if world ~= nil then -- 995
            local contact = enode.props -- 997
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 998
        else -- 998
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1000
        end -- 1000
    end, -- 994
    body = function(nodeStack, enode, _parent) -- 1003
        local def = enode.props -- 1004
        if def.world then -- 1004
            addChild( -- 1006
                nodeStack, -- 1006
                getBody(enode, def.world), -- 1006
                enode -- 1006
            ) -- 1006
            return -- 1007
        end -- 1007
        local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1009
        if world ~= nil then -- 1009
            addChild( -- 1011
                nodeStack, -- 1011
                getBody(enode, world), -- 1011
                enode -- 1011
            ) -- 1011
        else -- 1011
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1013
        end -- 1013
    end, -- 1003
    ["rect-fixture"] = bodyCheck, -- 1016
    ["polygon-fixture"] = bodyCheck, -- 1017
    ["multi-fixture"] = bodyCheck, -- 1018
    ["disk-fixture"] = bodyCheck, -- 1019
    ["chain-fixture"] = bodyCheck, -- 1020
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 1021
        local joint = enode.props -- 1022
        if joint.ref == nil then -- 1022
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1024
            return -- 1025
        end -- 1025
        if joint.bodyA.current == nil then -- 1025
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1028
            return -- 1029
        end -- 1029
        if joint.bodyB.current == nil then -- 1029
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1032
            return -- 1033
        end -- 1033
        local ____joint_ref_13 = joint.ref -- 1035
        local ____self_11 = Dora.Joint -- 1035
        local ____self_11_distance_12 = ____self_11.distance -- 1035
        local ____joint_canCollide_10 = joint.canCollide -- 1036
        if ____joint_canCollide_10 == nil then -- 1036
            ____joint_canCollide_10 = false -- 1036
        end -- 1036
        ____joint_ref_13.current = ____self_11_distance_12( -- 1035
            ____self_11, -- 1035
            ____joint_canCollide_10, -- 1036
            joint.bodyA.current, -- 1037
            joint.bodyB.current, -- 1038
            joint.anchorA or Dora.Vec2.zero, -- 1039
            joint.anchorB or Dora.Vec2.zero, -- 1040
            joint.frequency or 0, -- 1041
            joint.damping or 0 -- 1042
        ) -- 1042
    end, -- 1021
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 1044
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
        local ____joint_ref_17 = joint.ref -- 1058
        local ____self_15 = Dora.Joint -- 1058
        local ____self_15_friction_16 = ____self_15.friction -- 1058
        local ____joint_canCollide_14 = joint.canCollide -- 1059
        if ____joint_canCollide_14 == nil then -- 1059
            ____joint_canCollide_14 = false -- 1059
        end -- 1059
        ____joint_ref_17.current = ____self_15_friction_16( -- 1058
            ____self_15, -- 1058
            ____joint_canCollide_14, -- 1059
            joint.bodyA.current, -- 1060
            joint.bodyB.current, -- 1061
            joint.worldPos, -- 1062
            joint.maxForce, -- 1063
            joint.maxTorque -- 1064
        ) -- 1064
    end, -- 1044
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 1067
        local joint = enode.props -- 1068
        if joint.ref == nil then -- 1068
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1070
            return -- 1071
        end -- 1071
        if joint.jointA.current == nil then -- 1071
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1074
            return -- 1075
        end -- 1075
        if joint.jointB.current == nil then -- 1075
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1078
            return -- 1079
        end -- 1079
        local ____joint_ref_21 = joint.ref -- 1081
        local ____self_19 = Dora.Joint -- 1081
        local ____self_19_gear_20 = ____self_19.gear -- 1081
        local ____joint_canCollide_18 = joint.canCollide -- 1082
        if ____joint_canCollide_18 == nil then -- 1082
            ____joint_canCollide_18 = false -- 1082
        end -- 1082
        ____joint_ref_21.current = ____self_19_gear_20( -- 1081
            ____self_19, -- 1081
            ____joint_canCollide_18, -- 1082
            joint.jointA.current, -- 1083
            joint.jointB.current, -- 1084
            joint.ratio or 1 -- 1085
        ) -- 1085
    end, -- 1067
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 1088
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
        local ____joint_ref_25 = joint.ref -- 1102
        local ____self_23 = Dora.Joint -- 1102
        local ____self_23_spring_24 = ____self_23.spring -- 1102
        local ____joint_canCollide_22 = joint.canCollide -- 1103
        if ____joint_canCollide_22 == nil then -- 1103
            ____joint_canCollide_22 = false -- 1103
        end -- 1103
        ____joint_ref_25.current = ____self_23_spring_24( -- 1102
            ____self_23, -- 1102
            ____joint_canCollide_22, -- 1103
            joint.bodyA.current, -- 1104
            joint.bodyB.current, -- 1105
            joint.linearOffset, -- 1106
            joint.angularOffset, -- 1107
            joint.maxForce, -- 1108
            joint.maxTorque, -- 1109
            joint.correctionFactor or 1 -- 1110
        ) -- 1110
    end, -- 1088
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1113
        local joint = enode.props -- 1114
        if joint.ref == nil then -- 1114
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1116
            return -- 1117
        end -- 1117
        if joint.body.current == nil then -- 1117
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1120
            return -- 1121
        end -- 1121
        local ____joint_ref_29 = joint.ref -- 1123
        local ____self_27 = Dora.Joint -- 1123
        local ____self_27_move_28 = ____self_27.move -- 1123
        local ____joint_canCollide_26 = joint.canCollide -- 1124
        if ____joint_canCollide_26 == nil then -- 1124
            ____joint_canCollide_26 = false -- 1124
        end -- 1124
        ____joint_ref_29.current = ____self_27_move_28( -- 1123
            ____self_27, -- 1123
            ____joint_canCollide_26, -- 1124
            joint.body.current, -- 1125
            joint.targetPos, -- 1126
            joint.maxForce, -- 1127
            joint.frequency, -- 1128
            joint.damping or 0.7 -- 1129
        ) -- 1129
    end, -- 1113
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1132
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
        local ____joint_ref_33 = joint.ref -- 1146
        local ____self_31 = Dora.Joint -- 1146
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1146
        local ____joint_canCollide_30 = joint.canCollide -- 1147
        if ____joint_canCollide_30 == nil then -- 1147
            ____joint_canCollide_30 = false -- 1147
        end -- 1147
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1146
            ____self_31, -- 1146
            ____joint_canCollide_30, -- 1147
            joint.bodyA.current, -- 1148
            joint.bodyB.current, -- 1149
            joint.worldPos, -- 1150
            joint.axisAngle, -- 1151
            joint.lowerTranslation or 0, -- 1152
            joint.upperTranslation or 0, -- 1153
            joint.maxMotorForce or 0, -- 1154
            joint.motorSpeed or 0 -- 1155
        ) -- 1155
    end, -- 1132
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1158
        local joint = enode.props -- 1159
        if joint.ref == nil then -- 1159
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1161
            return -- 1162
        end -- 1162
        if joint.bodyA.current == nil then -- 1162
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1165
            return -- 1166
        end -- 1166
        if joint.bodyB.current == nil then -- 1166
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1169
            return -- 1170
        end -- 1170
        local ____joint_ref_37 = joint.ref -- 1172
        local ____self_35 = Dora.Joint -- 1172
        local ____self_35_pulley_36 = ____self_35.pulley -- 1172
        local ____joint_canCollide_34 = joint.canCollide -- 1173
        if ____joint_canCollide_34 == nil then -- 1173
            ____joint_canCollide_34 = false -- 1173
        end -- 1173
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1172
            ____self_35, -- 1172
            ____joint_canCollide_34, -- 1173
            joint.bodyA.current, -- 1174
            joint.bodyB.current, -- 1175
            joint.anchorA or Dora.Vec2.zero, -- 1176
            joint.anchorB or Dora.Vec2.zero, -- 1177
            joint.groundAnchorA, -- 1178
            joint.groundAnchorB, -- 1179
            joint.ratio or 1 -- 1180
        ) -- 1180
    end, -- 1158
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1183
        local joint = enode.props -- 1184
        if joint.ref == nil then -- 1184
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1186
            return -- 1187
        end -- 1187
        if joint.bodyA.current == nil then -- 1187
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1190
            return -- 1191
        end -- 1191
        if joint.bodyB.current == nil then -- 1191
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1194
            return -- 1195
        end -- 1195
        local ____joint_ref_41 = joint.ref -- 1197
        local ____self_39 = Dora.Joint -- 1197
        local ____self_39_revolute_40 = ____self_39.revolute -- 1197
        local ____joint_canCollide_38 = joint.canCollide -- 1198
        if ____joint_canCollide_38 == nil then -- 1198
            ____joint_canCollide_38 = false -- 1198
        end -- 1198
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1197
            ____self_39, -- 1197
            ____joint_canCollide_38, -- 1198
            joint.bodyA.current, -- 1199
            joint.bodyB.current, -- 1200
            joint.worldPos, -- 1201
            joint.lowerAngle or 0, -- 1202
            joint.upperAngle or 0, -- 1203
            joint.maxMotorTorque or 0, -- 1204
            joint.motorSpeed or 0 -- 1205
        ) -- 1205
    end, -- 1183
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1208
        local joint = enode.props -- 1209
        if joint.ref == nil then -- 1209
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1211
            return -- 1212
        end -- 1212
        if joint.bodyA.current == nil then -- 1212
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1215
            return -- 1216
        end -- 1216
        if joint.bodyB.current == nil then -- 1216
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1219
            return -- 1220
        end -- 1220
        local ____joint_ref_45 = joint.ref -- 1222
        local ____self_43 = Dora.Joint -- 1222
        local ____self_43_rope_44 = ____self_43.rope -- 1222
        local ____joint_canCollide_42 = joint.canCollide -- 1223
        if ____joint_canCollide_42 == nil then -- 1223
            ____joint_canCollide_42 = false -- 1223
        end -- 1223
        ____joint_ref_45.current = ____self_43_rope_44( -- 1222
            ____self_43, -- 1222
            ____joint_canCollide_42, -- 1223
            joint.bodyA.current, -- 1224
            joint.bodyB.current, -- 1225
            joint.anchorA or Dora.Vec2.zero, -- 1226
            joint.anchorB or Dora.Vec2.zero, -- 1227
            joint.maxLength or 0 -- 1228
        ) -- 1228
    end, -- 1208
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1231
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
        local ____joint_ref_49 = joint.ref -- 1245
        local ____self_47 = Dora.Joint -- 1245
        local ____self_47_weld_48 = ____self_47.weld -- 1245
        local ____joint_canCollide_46 = joint.canCollide -- 1246
        if ____joint_canCollide_46 == nil then -- 1246
            ____joint_canCollide_46 = false -- 1246
        end -- 1246
        ____joint_ref_49.current = ____self_47_weld_48( -- 1245
            ____self_47, -- 1245
            ____joint_canCollide_46, -- 1246
            joint.bodyA.current, -- 1247
            joint.bodyB.current, -- 1248
            joint.worldPos, -- 1249
            joint.frequency or 0, -- 1250
            joint.damping or 0 -- 1251
        ) -- 1251
    end, -- 1231
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1254
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
        local ____joint_ref_53 = joint.ref -- 1268
        local ____self_51 = Dora.Joint -- 1268
        local ____self_51_wheel_52 = ____self_51.wheel -- 1268
        local ____joint_canCollide_50 = joint.canCollide -- 1269
        if ____joint_canCollide_50 == nil then -- 1269
            ____joint_canCollide_50 = false -- 1269
        end -- 1269
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1268
            ____self_51, -- 1268
            ____joint_canCollide_50, -- 1269
            joint.bodyA.current, -- 1270
            joint.bodyB.current, -- 1271
            joint.worldPos, -- 1272
            joint.axisAngle, -- 1273
            joint.maxMotorTorque or 0, -- 1274
            joint.motorSpeed or 0, -- 1275
            joint.frequency or 0, -- 1276
            joint.damping or 0.7 -- 1277
        ) -- 1277
    end, -- 1254
    ["custom-node"] = function(nodeStack, enode, _parent) -- 1280
        local node = getCustomNode(enode) -- 1281
        if node ~= nil then -- 1281
            addChild(nodeStack, node, enode) -- 1283
        end -- 1283
    end, -- 1280
    ["custom-element"] = function() -- 1286
    end, -- 1286
    ["align-node"] = function(nodeStack, enode, _parent) -- 1287
        addChild( -- 1288
            nodeStack, -- 1288
            getAlignNode(enode), -- 1288
            enode -- 1288
        ) -- 1288
    end, -- 1287
    ["effek-node"] = function(nodeStack, enode, _parent) -- 1290
        addChild( -- 1291
            nodeStack, -- 1291
            getEffekNode(enode), -- 1291
            enode -- 1291
        ) -- 1291
    end, -- 1290
    effek = function(nodeStack, enode, parent) -- 1293
        if #nodeStack > 0 then -- 1293
            local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1295
            if node then -- 1295
                local effek = enode.props -- 1297
                local handle = node:play( -- 1298
                    effek.file, -- 1298
                    Dora.Vec2(effek.x or 0, effek.y or 0), -- 1298
                    effek.z or 0 -- 1298
                ) -- 1298
                if handle >= 0 then -- 1298
                    if effek.ref then -- 1298
                        effek.ref.current = handle -- 1301
                    end -- 1301
                    if effek.onEnd then -- 1301
                        local onEnd = effek.onEnd -- 1301
                        node:slot( -- 1305
                            "EffekEnd", -- 1305
                            function(h) -- 1305
                                if handle == h then -- 1305
                                    onEnd(nil) -- 1307
                                end -- 1307
                            end -- 1305
                        ) -- 1305
                    end -- 1305
                end -- 1305
            else -- 1305
                Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1313
            end -- 1313
        end -- 1313
    end -- 1293
} -- 1293
function ____exports.useRef(item) -- 1359
    local ____item_54 = item -- 1360
    if ____item_54 == nil then -- 1360
        ____item_54 = nil -- 1360
    end -- 1360
    return {current = ____item_54} -- 1360
end -- 1359
local function getPreload(preloadList, node) -- 1363
    if type(node) ~= "table" then -- 1363
        return -- 1365
    end -- 1365
    local enode = node -- 1367
    if enode.type == nil then -- 1367
        local list = node -- 1369
        if #list > 0 then -- 1369
            for i = 1, #list do -- 1369
                getPreload(preloadList, list[i]) -- 1372
            end -- 1372
        end -- 1372
    else -- 1372
        repeat -- 1372
            local ____switch302 = enode.type -- 1372
            local sprite, playable, model, spine, dragonBone, label -- 1372
            local ____cond302 = ____switch302 == "sprite" -- 1372
            if ____cond302 then -- 1372
                sprite = enode.props -- 1378
                preloadList[#preloadList + 1] = sprite.file -- 1379
                break -- 1380
            end -- 1380
            ____cond302 = ____cond302 or ____switch302 == "playable" -- 1380
            if ____cond302 then -- 1380
                playable = enode.props -- 1382
                preloadList[#preloadList + 1] = playable.file -- 1383
                break -- 1384
            end -- 1384
            ____cond302 = ____cond302 or ____switch302 == "model" -- 1384
            if ____cond302 then -- 1384
                model = enode.props -- 1386
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1387
                break -- 1388
            end -- 1388
            ____cond302 = ____cond302 or ____switch302 == "spine" -- 1388
            if ____cond302 then -- 1388
                spine = enode.props -- 1390
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1391
                break -- 1392
            end -- 1392
            ____cond302 = ____cond302 or ____switch302 == "dragon-bone" -- 1392
            if ____cond302 then -- 1392
                dragonBone = enode.props -- 1394
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1395
                break -- 1396
            end -- 1396
            ____cond302 = ____cond302 or ____switch302 == "label" -- 1396
            if ____cond302 then -- 1396
                label = enode.props -- 1398
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1399
                break -- 1400
            end -- 1400
        until true -- 1400
    end -- 1400
    getPreload(preloadList, enode.children) -- 1403
end -- 1363
function ____exports.preloadAsync(enode, handler) -- 1406
    local preloadList = {} -- 1407
    getPreload(preloadList, enode) -- 1408
    Dora.Cache:loadAsync(preloadList, handler) -- 1409
end -- 1406
return ____exports -- 1406