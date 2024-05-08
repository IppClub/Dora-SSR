-- [ts]: dora-x.ts
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
local dora = require("dora") -- 10
function Warn(msg) -- 12
    print("[Dora Warning] " .. msg) -- 13
end -- 13
function visitNode(nodeStack, node, parent) -- 1286
    if type(node) ~= "table" then -- 1286
        return -- 1288
    end -- 1288
    local enode = node -- 1290
    if enode.type == nil then -- 1290
        local list = node -- 1292
        if #list > 0 then -- 1292
            for i = 1, #list do -- 1292
                local stack = {} -- 1295
                visitNode(stack, list[i], parent) -- 1296
                for i = 1, #stack do -- 1296
                    nodeStack[#nodeStack + 1] = stack[i] -- 1298
                end -- 1298
            end -- 1298
        end -- 1298
    else -- 1298
        local handler = elementMap[enode.type] -- 1303
        if handler ~= nil then -- 1303
            handler(nodeStack, enode, parent) -- 1305
        else -- 1305
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1307
        end -- 1307
    end -- 1307
end -- 1307
function ____exports.toNode(enode) -- 1312
    local nodeStack = {} -- 1313
    visitNode(nodeStack, enode) -- 1314
    if #nodeStack == 1 then -- 1314
        return nodeStack[1] -- 1316
    elseif #nodeStack > 1 then -- 1316
        local node = dora.Node() -- 1318
        for i = 1, #nodeStack do -- 1318
            node:addChild(nodeStack[i]) -- 1320
        end -- 1320
        return node -- 1322
    end -- 1322
    return nil -- 1324
end -- 1312
____exports.React = {} -- 1312
local React = ____exports.React -- 1312
do -- 1312
    React.Component = __TS__Class() -- 16
    local Component = React.Component -- 16
    Component.name = "Component" -- 18
    function Component.prototype.____constructor(self, props) -- 19
        self.props = props -- 20
    end -- 19
    Component.isComponent = true -- 19
    React.Fragment = nil -- 16
    local function flattenChild(child) -- 29
        if type(child) ~= "table" then -- 29
            return child, true -- 31
        end -- 31
        if child.type ~= nil then -- 31
            return child, true -- 34
        elseif child.children then -- 34
            child = child.children -- 36
        end -- 36
        local list = child -- 38
        local flatChildren = {} -- 39
        for i = 1, #list do -- 39
            local child, flat = flattenChild(list[i]) -- 41
            if flat then -- 41
                flatChildren[#flatChildren + 1] = child -- 43
            else -- 43
                local listChild = child -- 45
                for i = 1, #listChild do -- 45
                    flatChildren[#flatChildren + 1] = listChild[i] -- 47
                end -- 47
            end -- 47
        end -- 47
        return flatChildren, false -- 51
    end -- 29
    function React.createElement(self, typeName, props, ...) -- 60
        local children = {...} -- 60
        repeat -- 60
            local ____switch14 = type(typeName) -- 60
            local ____cond14 = ____switch14 == "function" -- 60
            if ____cond14 then -- 60
                do -- 60
                    if props == nil then -- 60
                        props = {} -- 67
                    end -- 67
                    if props.children then -- 67
                        local ____props_1 = props -- 69
                        local ____array_0 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 69
                        __TS__SparseArrayPush(____array_0, ...) -- 69
                        ____props_1.children = {__TS__SparseArraySpread(____array_0)} -- 69
                    else -- 69
                        props.children = children -- 71
                    end -- 71
                    return typeName(nil, props) -- 73
                end -- 73
            end -- 73
            ____cond14 = ____cond14 or ____switch14 == "table" -- 73
            if ____cond14 then -- 73
                do -- 73
                    if not typeName.isComponent then -- 73
                        Warn("unsupported class object in element creation") -- 77
                        return {} -- 78
                    end -- 78
                    if props == nil then -- 78
                        props = {} -- 80
                    end -- 80
                    if props.children then -- 80
                        local ____props_3 = props -- 82
                        local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 82
                        __TS__SparseArrayPush( -- 82
                            ____array_2, -- 82
                            table.unpack(children) -- 82
                        ) -- 82
                        ____props_3.children = {__TS__SparseArraySpread(____array_2)} -- 82
                    else -- 82
                        props.children = children -- 84
                    end -- 84
                    local inst = __TS__New(typeName, props) -- 86
                    return inst:render() -- 87
                end -- 87
            end -- 87
            do -- 87
                do -- 87
                    if props and props.children then -- 87
                        local ____array_4 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 87
                        __TS__SparseArrayPush( -- 87
                            ____array_4, -- 87
                            table.unpack(children) -- 91
                        ) -- 91
                        children = {__TS__SparseArraySpread(____array_4)} -- 91
                        props.children = nil -- 92
                    end -- 92
                    local flatChildren = {} -- 94
                    for i = 1, #children do -- 94
                        local child, flat = flattenChild(children[i]) -- 96
                        if flat then -- 96
                            flatChildren[#flatChildren + 1] = child -- 98
                        else -- 98
                            for i = 1, #child do -- 98
                                flatChildren[#flatChildren + 1] = child[i] -- 101
                            end -- 101
                        end -- 101
                    end -- 101
                    children = flatChildren -- 105
                end -- 105
            end -- 105
        until true -- 105
        if typeName == nil then -- 105
            return children -- 109
        end -- 109
        local ____typeName_6 = typeName -- 112
        local ____props_5 = props -- 113
        if ____props_5 == nil then -- 113
            ____props_5 = {} -- 113
        end -- 113
        return {type = ____typeName_6, props = ____props_5, children = children} -- 111
    end -- 60
end -- 60
local function getNode(enode, cnode, attribHandler) -- 122
    cnode = cnode or dora.Node() -- 123
    local jnode = enode.props -- 124
    local anchor = nil -- 125
    local color3 = nil -- 126
    for k, v in pairs(enode.props) do -- 127
        repeat -- 127
            local ____switch31 = k -- 127
            local ____cond31 = ____switch31 == "ref" -- 127
            if ____cond31 then -- 127
                v.current = cnode -- 129
                break -- 129
            end -- 129
            ____cond31 = ____cond31 or ____switch31 == "anchorX" -- 129
            if ____cond31 then -- 129
                anchor = dora.Vec2(v, (anchor or cnode.anchor).y) -- 130
                break -- 130
            end -- 130
            ____cond31 = ____cond31 or ____switch31 == "anchorY" -- 130
            if ____cond31 then -- 130
                anchor = dora.Vec2((anchor or cnode.anchor).x, v) -- 131
                break -- 131
            end -- 131
            ____cond31 = ____cond31 or ____switch31 == "color3" -- 131
            if ____cond31 then -- 131
                color3 = dora.Color3(v) -- 132
                break -- 132
            end -- 132
            ____cond31 = ____cond31 or ____switch31 == "transformTarget" -- 132
            if ____cond31 then -- 132
                cnode.transformTarget = v.current -- 133
                break -- 133
            end -- 133
            ____cond31 = ____cond31 or ____switch31 == "onUpdate" -- 133
            if ____cond31 then -- 133
                cnode:schedule(v) -- 134
                break -- 134
            end -- 134
            ____cond31 = ____cond31 or ____switch31 == "onActionEnd" -- 134
            if ____cond31 then -- 134
                cnode:slot("ActionEnd", v) -- 135
                break -- 135
            end -- 135
            ____cond31 = ____cond31 or ____switch31 == "onTapFilter" -- 135
            if ____cond31 then -- 135
                cnode:slot("TapFilter", v) -- 136
                break -- 136
            end -- 136
            ____cond31 = ____cond31 or ____switch31 == "onTapBegan" -- 136
            if ____cond31 then -- 136
                cnode:slot("TapBegan", v) -- 137
                break -- 137
            end -- 137
            ____cond31 = ____cond31 or ____switch31 == "onTapEnded" -- 137
            if ____cond31 then -- 137
                cnode:slot("TapEnded", v) -- 138
                break -- 138
            end -- 138
            ____cond31 = ____cond31 or ____switch31 == "onTapped" -- 138
            if ____cond31 then -- 138
                cnode:slot("Tapped", v) -- 139
                break -- 139
            end -- 139
            ____cond31 = ____cond31 or ____switch31 == "onTapMoved" -- 139
            if ____cond31 then -- 139
                cnode:slot("TapMoved", v) -- 140
                break -- 140
            end -- 140
            ____cond31 = ____cond31 or ____switch31 == "onMouseWheel" -- 140
            if ____cond31 then -- 140
                cnode:slot("MouseWheel", v) -- 141
                break -- 141
            end -- 141
            ____cond31 = ____cond31 or ____switch31 == "onGesture" -- 141
            if ____cond31 then -- 141
                cnode:slot("Gesture", v) -- 142
                break -- 142
            end -- 142
            ____cond31 = ____cond31 or ____switch31 == "onEnter" -- 142
            if ____cond31 then -- 142
                cnode:slot("Enter", v) -- 143
                break -- 143
            end -- 143
            ____cond31 = ____cond31 or ____switch31 == "onExit" -- 143
            if ____cond31 then -- 143
                cnode:slot("Exit", v) -- 144
                break -- 144
            end -- 144
            ____cond31 = ____cond31 or ____switch31 == "onCleanup" -- 144
            if ____cond31 then -- 144
                cnode:slot("Cleanup", v) -- 145
                break -- 145
            end -- 145
            ____cond31 = ____cond31 or ____switch31 == "onKeyDown" -- 145
            if ____cond31 then -- 145
                cnode:slot("KeyDown", v) -- 146
                break -- 146
            end -- 146
            ____cond31 = ____cond31 or ____switch31 == "onKeyUp" -- 146
            if ____cond31 then -- 146
                cnode:slot("KeyUp", v) -- 147
                break -- 147
            end -- 147
            ____cond31 = ____cond31 or ____switch31 == "onKeyPressed" -- 147
            if ____cond31 then -- 147
                cnode:slot("KeyPressed", v) -- 148
                break -- 148
            end -- 148
            ____cond31 = ____cond31 or ____switch31 == "onAttachIME" -- 148
            if ____cond31 then -- 148
                cnode:slot("AttachIME", v) -- 149
                break -- 149
            end -- 149
            ____cond31 = ____cond31 or ____switch31 == "onDetachIME" -- 149
            if ____cond31 then -- 149
                cnode:slot("DetachIME", v) -- 150
                break -- 150
            end -- 150
            ____cond31 = ____cond31 or ____switch31 == "onTextInput" -- 150
            if ____cond31 then -- 150
                cnode:slot("TextInput", v) -- 151
                break -- 151
            end -- 151
            ____cond31 = ____cond31 or ____switch31 == "onTextEditing" -- 151
            if ____cond31 then -- 151
                cnode:slot("TextEditing", v) -- 152
                break -- 152
            end -- 152
            ____cond31 = ____cond31 or ____switch31 == "onButtonDown" -- 152
            if ____cond31 then -- 152
                cnode:slot("ButtonDown", v) -- 153
                break -- 153
            end -- 153
            ____cond31 = ____cond31 or ____switch31 == "onButtonUp" -- 153
            if ____cond31 then -- 153
                cnode:slot("ButtonUp", v) -- 154
                break -- 154
            end -- 154
            ____cond31 = ____cond31 or ____switch31 == "onAxis" -- 154
            if ____cond31 then -- 154
                cnode:slot("Axis", v) -- 155
                break -- 155
            end -- 155
            do -- 155
                do -- 155
                    if attribHandler then -- 155
                        if not attribHandler(cnode, enode, k, v) then -- 155
                            cnode[k] = v -- 159
                        end -- 159
                    else -- 159
                        cnode[k] = v -- 162
                    end -- 162
                    break -- 164
                end -- 164
            end -- 164
        until true -- 164
    end -- 164
    if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 164
        cnode.touchEnabled = true -- 177
    end -- 177
    if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 177
        cnode.keyboardEnabled = true -- 184
    end -- 184
    if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 184
        cnode.controllerEnabled = true -- 191
    end -- 191
    if anchor ~= nil then -- 191
        cnode.anchor = anchor -- 193
    end -- 193
    if color3 ~= nil then -- 193
        cnode.color3 = color3 -- 194
    end -- 194
    if jnode.onMount ~= nil then -- 194
        jnode.onMount(cnode) -- 196
    end -- 196
    return cnode -- 198
end -- 122
local getClipNode -- 201
do -- 201
    local function handleClipNodeAttribute(cnode, _enode, k, v) -- 203
        repeat -- 203
            local ____switch44 = k -- 203
            local ____cond44 = ____switch44 == "stencil" -- 203
            if ____cond44 then -- 203
                cnode.stencil = ____exports.toNode(v) -- 210
                return true -- 210
            end -- 210
        until true -- 210
        return false -- 212
    end -- 203
    getClipNode = function(enode) -- 214
        return getNode( -- 215
            enode, -- 215
            dora.ClipNode(), -- 215
            handleClipNodeAttribute -- 215
        ) -- 215
    end -- 214
end -- 214
local getPlayable -- 219
local getDragonBone -- 220
local getSpine -- 221
local getModel -- 222
do -- 222
    local function handlePlayableAttribute(cnode, enode, k, v) -- 224
        repeat -- 224
            local ____switch48 = k -- 224
            local ____cond48 = ____switch48 == "file" -- 224
            if ____cond48 then -- 224
                return true -- 226
            end -- 226
            ____cond48 = ____cond48 or ____switch48 == "play" -- 226
            if ____cond48 then -- 226
                cnode:play(v, enode.props.loop == true) -- 227
                return true -- 227
            end -- 227
            ____cond48 = ____cond48 or ____switch48 == "loop" -- 227
            if ____cond48 then -- 227
                return true -- 228
            end -- 228
            ____cond48 = ____cond48 or ____switch48 == "onAnimationEnd" -- 228
            if ____cond48 then -- 228
                cnode:slot("AnimationEnd", v) -- 229
                return true -- 229
            end -- 229
        until true -- 229
        return false -- 231
    end -- 224
    getPlayable = function(enode, cnode, attribHandler) -- 233
        if attribHandler == nil then -- 233
            attribHandler = handlePlayableAttribute -- 234
        end -- 234
        cnode = cnode or dora.Playable(enode.props.file) or nil -- 235
        if cnode ~= nil then -- 235
            return getNode(enode, cnode, attribHandler) -- 237
        end -- 237
        return nil -- 239
    end -- 233
    local function handleDragonBoneAttribute(cnode, enode, k, v) -- 242
        repeat -- 242
            local ____switch52 = k -- 242
            local ____cond52 = ____switch52 == "hitTestEnabled" -- 242
            if ____cond52 then -- 242
                cnode.hitTestEnabled = true -- 244
                return true -- 244
            end -- 244
        until true -- 244
        return handlePlayableAttribute(cnode, enode, k, v) -- 246
    end -- 242
    getDragonBone = function(enode) -- 248
        local node = dora.DragonBone(enode.props.file) -- 249
        if node ~= nil then -- 249
            local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 251
            return cnode -- 252
        end -- 252
        return nil -- 254
    end -- 248
    local function handleSpineAttribute(cnode, enode, k, v) -- 257
        repeat -- 257
            local ____switch56 = k -- 257
            local ____cond56 = ____switch56 == "hitTestEnabled" -- 257
            if ____cond56 then -- 257
                cnode.hitTestEnabled = true -- 259
                return true -- 259
            end -- 259
        until true -- 259
        return handlePlayableAttribute(cnode, enode, k, v) -- 261
    end -- 257
    getSpine = function(enode) -- 263
        local node = dora.Spine(enode.props.file) -- 264
        if node ~= nil then -- 264
            local cnode = getPlayable(enode, node, handleSpineAttribute) -- 266
            return cnode -- 267
        end -- 267
        return nil -- 269
    end -- 263
    local function handleModelAttribute(cnode, enode, k, v) -- 272
        repeat -- 272
            local ____switch60 = k -- 272
            local ____cond60 = ____switch60 == "reversed" -- 272
            if ____cond60 then -- 272
                cnode.reversed = v -- 274
                return true -- 274
            end -- 274
        until true -- 274
        return handlePlayableAttribute(cnode, enode, k, v) -- 276
    end -- 272
    getModel = function(enode) -- 278
        local node = dora.Model(enode.props.file) -- 279
        if node ~= nil then -- 279
            local cnode = getPlayable(enode, node, handleModelAttribute) -- 281
            return cnode -- 282
        end -- 282
        return nil -- 284
    end -- 278
end -- 278
local getDrawNode -- 288
do -- 288
    local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 290
        repeat -- 290
            local ____switch65 = k -- 290
            local ____cond65 = ____switch65 == "depthWrite" -- 290
            if ____cond65 then -- 290
                cnode.depthWrite = v -- 292
                return true -- 292
            end -- 292
            ____cond65 = ____cond65 or ____switch65 == "blendFunc" -- 292
            if ____cond65 then -- 292
                cnode.blendFunc = v -- 293
                return true -- 293
            end -- 293
        until true -- 293
        return false -- 295
    end -- 290
    getDrawNode = function(enode) -- 297
        local node = dora.DrawNode() -- 298
        local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 299
        local ____enode_7 = enode -- 300
        local children = ____enode_7.children -- 300
        for i = 1, #children do -- 300
            do -- 300
                local child = children[i] -- 302
                if type(child) ~= "table" then -- 302
                    goto __continue67 -- 304
                end -- 304
                repeat -- 304
                    local ____switch69 = child.type -- 304
                    local ____cond69 = ____switch69 == "dot-shape" -- 304
                    if ____cond69 then -- 304
                        do -- 304
                            local dot = child.props -- 308
                            node:drawDot( -- 309
                                dora.Vec2(dot.x or 0, dot.y or 0), -- 310
                                dot.radius, -- 311
                                dora.Color(dot.color or 4294967295) -- 312
                            ) -- 312
                            break -- 314
                        end -- 314
                    end -- 314
                    ____cond69 = ____cond69 or ____switch69 == "segment-shape" -- 314
                    if ____cond69 then -- 314
                        do -- 314
                            local segment = child.props -- 317
                            node:drawSegment( -- 318
                                dora.Vec2(segment.startX, segment.startY), -- 319
                                dora.Vec2(segment.stopX, segment.stopY), -- 320
                                segment.radius, -- 321
                                dora.Color(segment.color or 4294967295) -- 322
                            ) -- 322
                            break -- 324
                        end -- 324
                    end -- 324
                    ____cond69 = ____cond69 or ____switch69 == "rect-shape" -- 324
                    if ____cond69 then -- 324
                        do -- 324
                            local rect = child.props -- 327
                            local centerX = rect.centerX or 0 -- 328
                            local centerY = rect.centerY or 0 -- 329
                            local hw = rect.width / 2 -- 330
                            local hh = rect.height / 2 -- 331
                            node:drawPolygon( -- 332
                                { -- 333
                                    dora.Vec2(centerX - hw, centerY + hh), -- 334
                                    dora.Vec2(centerX + hw, centerY + hh), -- 335
                                    dora.Vec2(centerX + hw, centerY - hh), -- 336
                                    dora.Vec2(centerX - hw, centerY - hh) -- 337
                                }, -- 337
                                dora.Color(rect.fillColor or 4294967295), -- 339
                                rect.borderWidth or 0, -- 340
                                dora.Color(rect.borderColor or 4294967295) -- 341
                            ) -- 341
                            break -- 343
                        end -- 343
                    end -- 343
                    ____cond69 = ____cond69 or ____switch69 == "polygon-shape" -- 343
                    if ____cond69 then -- 343
                        do -- 343
                            local poly = child.props -- 346
                            node:drawPolygon( -- 347
                                poly.verts, -- 348
                                dora.Color(poly.fillColor or 4294967295), -- 349
                                poly.borderWidth or 0, -- 350
                                dora.Color(poly.borderColor or 4294967295) -- 351
                            ) -- 351
                            break -- 353
                        end -- 353
                    end -- 353
                    ____cond69 = ____cond69 or ____switch69 == "verts-shape" -- 353
                    if ____cond69 then -- 353
                        do -- 353
                            local verts = child.props -- 356
                            node:drawVertices(__TS__ArrayMap( -- 357
                                verts.verts, -- 357
                                function(____, ____bindingPattern0) -- 357
                                    local color -- 357
                                    local vert -- 357
                                    vert = ____bindingPattern0[1] -- 357
                                    color = ____bindingPattern0[2] -- 357
                                    return { -- 357
                                        vert, -- 357
                                        dora.Color(color) -- 357
                                    } -- 357
                                end -- 357
                            )) -- 357
                            break -- 358
                        end -- 358
                    end -- 358
                until true -- 358
            end -- 358
            ::__continue67:: -- 358
        end -- 358
        return cnode -- 362
    end -- 297
end -- 297
local getGrid -- 366
do -- 366
    local function handleGridAttribute(cnode, _enode, k, v) -- 368
        repeat -- 368
            local ____switch78 = k -- 368
            local ____cond78 = ____switch78 == "file" or ____switch78 == "gridX" or ____switch78 == "gridY" -- 368
            if ____cond78 then -- 368
                return true -- 370
            end -- 370
            ____cond78 = ____cond78 or ____switch78 == "textureRect" -- 370
            if ____cond78 then -- 370
                cnode.textureRect = v -- 371
                return true -- 371
            end -- 371
            ____cond78 = ____cond78 or ____switch78 == "depthWrite" -- 371
            if ____cond78 then -- 371
                cnode.depthWrite = v -- 372
                return true -- 372
            end -- 372
            ____cond78 = ____cond78 or ____switch78 == "blendFunc" -- 372
            if ____cond78 then -- 372
                cnode.blendFunc = v -- 373
                return true -- 373
            end -- 373
            ____cond78 = ____cond78 or ____switch78 == "effect" -- 373
            if ____cond78 then -- 373
                cnode.effect = v -- 374
                return true -- 374
            end -- 374
        until true -- 374
        return false -- 376
    end -- 368
    getGrid = function(enode) -- 378
        local grid = enode.props -- 379
        local node = dora.Grid(grid.file, grid.gridX, grid.gridY) -- 380
        local cnode = getNode(enode, node, handleGridAttribute) -- 381
        return cnode -- 382
    end -- 378
end -- 378
local getSprite -- 386
do -- 386
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 388
        repeat -- 388
            local ____switch82 = k -- 388
            local ____cond82 = ____switch82 == "file" -- 388
            if ____cond82 then -- 388
                return true -- 390
            end -- 390
            ____cond82 = ____cond82 or ____switch82 == "textureRect" -- 390
            if ____cond82 then -- 390
                cnode.textureRect = v -- 391
                return true -- 391
            end -- 391
            ____cond82 = ____cond82 or ____switch82 == "depthWrite" -- 391
            if ____cond82 then -- 391
                cnode.depthWrite = v -- 392
                return true -- 392
            end -- 392
            ____cond82 = ____cond82 or ____switch82 == "blendFunc" -- 392
            if ____cond82 then -- 392
                cnode.blendFunc = v -- 393
                return true -- 393
            end -- 393
            ____cond82 = ____cond82 or ____switch82 == "effect" -- 393
            if ____cond82 then -- 393
                cnode.effect = v -- 394
                return true -- 394
            end -- 394
            ____cond82 = ____cond82 or ____switch82 == "alphaRef" -- 394
            if ____cond82 then -- 394
                cnode.alphaRef = v -- 395
                return true -- 395
            end -- 395
            ____cond82 = ____cond82 or ____switch82 == "uwrap" -- 395
            if ____cond82 then -- 395
                cnode.uwrap = v -- 396
                return true -- 396
            end -- 396
            ____cond82 = ____cond82 or ____switch82 == "vwrap" -- 396
            if ____cond82 then -- 396
                cnode.vwrap = v -- 397
                return true -- 397
            end -- 397
            ____cond82 = ____cond82 or ____switch82 == "filter" -- 397
            if ____cond82 then -- 397
                cnode.filter = v -- 398
                return true -- 398
            end -- 398
        until true -- 398
        return false -- 400
    end -- 388
    getSprite = function(enode) -- 402
        local sp = enode.props -- 403
        local node = dora.Sprite(sp.file) -- 404
        if node ~= nil then -- 404
            local cnode = getNode(enode, node, handleSpriteAttribute) -- 406
            return cnode -- 407
        end -- 407
        return nil -- 409
    end -- 402
end -- 402
local getLabel -- 413
do -- 413
    local function handleLabelAttribute(cnode, _enode, k, v) -- 415
        repeat -- 415
            local ____switch87 = k -- 415
            local ____cond87 = ____switch87 == "fontName" or ____switch87 == "fontSize" or ____switch87 == "text" -- 415
            if ____cond87 then -- 415
                return true -- 417
            end -- 417
            ____cond87 = ____cond87 or ____switch87 == "alphaRef" -- 417
            if ____cond87 then -- 417
                cnode.alphaRef = v -- 418
                return true -- 418
            end -- 418
            ____cond87 = ____cond87 or ____switch87 == "textWidth" -- 418
            if ____cond87 then -- 418
                cnode.textWidth = v -- 419
                return true -- 419
            end -- 419
            ____cond87 = ____cond87 or ____switch87 == "lineGap" -- 419
            if ____cond87 then -- 419
                cnode.lineGap = v -- 420
                return true -- 420
            end -- 420
            ____cond87 = ____cond87 or ____switch87 == "spacing" -- 420
            if ____cond87 then -- 420
                cnode.spacing = v -- 421
                return true -- 421
            end -- 421
            ____cond87 = ____cond87 or ____switch87 == "blendFunc" -- 421
            if ____cond87 then -- 421
                cnode.blendFunc = v -- 422
                return true -- 422
            end -- 422
            ____cond87 = ____cond87 or ____switch87 == "depthWrite" -- 422
            if ____cond87 then -- 422
                cnode.depthWrite = v -- 423
                return true -- 423
            end -- 423
            ____cond87 = ____cond87 or ____switch87 == "batched" -- 423
            if ____cond87 then -- 423
                cnode.batched = v -- 424
                return true -- 424
            end -- 424
            ____cond87 = ____cond87 or ____switch87 == "effect" -- 424
            if ____cond87 then -- 424
                cnode.effect = v -- 425
                return true -- 425
            end -- 425
            ____cond87 = ____cond87 or ____switch87 == "alignment" -- 425
            if ____cond87 then -- 425
                cnode.alignment = v -- 426
                return true -- 426
            end -- 426
        until true -- 426
        return false -- 428
    end -- 415
    getLabel = function(enode) -- 430
        local label = enode.props -- 431
        local node = dora.Label(label.fontName, label.fontSize) -- 432
        if node ~= nil then -- 432
            local cnode = getNode(enode, node, handleLabelAttribute) -- 434
            local ____enode_8 = enode -- 435
            local children = ____enode_8.children -- 435
            local text = label.text or "" -- 436
            for i = 1, #children do -- 436
                local child = children[i] -- 438
                if type(child) ~= "table" then -- 438
                    text = text .. tostring(child) -- 440
                end -- 440
            end -- 440
            node.text = text -- 443
            return cnode -- 444
        end -- 444
        return nil -- 446
    end -- 430
end -- 430
local getLine -- 450
do -- 450
    local function handleLineAttribute(cnode, enode, k, v) -- 452
        local line = enode.props -- 453
        repeat -- 453
            local ____switch94 = k -- 453
            local ____cond94 = ____switch94 == "verts" -- 453
            if ____cond94 then -- 453
                cnode:set( -- 455
                    v, -- 455
                    dora.Color(line.lineColor or 4294967295) -- 455
                ) -- 455
                return true -- 455
            end -- 455
            ____cond94 = ____cond94 or ____switch94 == "depthWrite" -- 455
            if ____cond94 then -- 455
                cnode.depthWrite = v -- 456
                return true -- 456
            end -- 456
            ____cond94 = ____cond94 or ____switch94 == "blendFunc" -- 456
            if ____cond94 then -- 456
                cnode.blendFunc = v -- 457
                return true -- 457
            end -- 457
        until true -- 457
        return false -- 459
    end -- 452
    getLine = function(enode) -- 461
        local node = dora.Line() -- 462
        local cnode = getNode(enode, node, handleLineAttribute) -- 463
        return cnode -- 464
    end -- 461
end -- 461
local getParticle -- 468
do -- 468
    local function handleParticleAttribute(cnode, _enode, k, v) -- 470
        repeat -- 470
            local ____switch98 = k -- 470
            local ____cond98 = ____switch98 == "file" -- 470
            if ____cond98 then -- 470
                return true -- 472
            end -- 472
            ____cond98 = ____cond98 or ____switch98 == "emit" -- 472
            if ____cond98 then -- 472
                if v then -- 472
                    cnode:start() -- 473
                end -- 473
                return true -- 473
            end -- 473
            ____cond98 = ____cond98 or ____switch98 == "onFinished" -- 473
            if ____cond98 then -- 473
                cnode:slot("Finished", v) -- 474
                return true -- 474
            end -- 474
        until true -- 474
        return false -- 476
    end -- 470
    getParticle = function(enode) -- 478
        local particle = enode.props -- 479
        local node = dora.Particle(particle.file) -- 480
        if node ~= nil then -- 480
            local cnode = getNode(enode, node, handleParticleAttribute) -- 482
            return cnode -- 483
        end -- 483
        return nil -- 485
    end -- 478
end -- 478
local getMenu -- 489
do -- 489
    local function handleMenuAttribute(cnode, _enode, k, v) -- 491
        repeat -- 491
            local ____switch104 = k -- 491
            local ____cond104 = ____switch104 == "enabled" -- 491
            if ____cond104 then -- 491
                cnode.enabled = v -- 493
                return true -- 493
            end -- 493
        until true -- 493
        return false -- 495
    end -- 491
    getMenu = function(enode) -- 497
        local node = dora.Menu() -- 498
        local cnode = getNode(enode, node, handleMenuAttribute) -- 499
        return cnode -- 500
    end -- 497
end -- 497
local function getPhysicsWorld(enode) -- 504
    local node = dora.PhysicsWorld() -- 505
    local cnode = getNode(enode, node) -- 506
    return cnode -- 507
end -- 504
local getBody -- 510
do -- 510
    local function handleBodyAttribute(cnode, _enode, k, v) -- 512
        repeat -- 512
            local ____switch109 = k -- 512
            local ____cond109 = ____switch109 == "type" or ____switch109 == "linearAcceleration" or ____switch109 == "fixedRotation" or ____switch109 == "bullet" or ____switch109 == "world" -- 512
            if ____cond109 then -- 512
                return true -- 519
            end -- 519
            ____cond109 = ____cond109 or ____switch109 == "velocityX" -- 519
            if ____cond109 then -- 519
                cnode.velocityX = v -- 520
                return true -- 520
            end -- 520
            ____cond109 = ____cond109 or ____switch109 == "velocityY" -- 520
            if ____cond109 then -- 520
                cnode.velocityY = v -- 521
                return true -- 521
            end -- 521
            ____cond109 = ____cond109 or ____switch109 == "angularRate" -- 521
            if ____cond109 then -- 521
                cnode.angularRate = v -- 522
                return true -- 522
            end -- 522
            ____cond109 = ____cond109 or ____switch109 == "group" -- 522
            if ____cond109 then -- 522
                cnode.group = v -- 523
                return true -- 523
            end -- 523
            ____cond109 = ____cond109 or ____switch109 == "linearDamping" -- 523
            if ____cond109 then -- 523
                cnode.linearDamping = v -- 524
                return true -- 524
            end -- 524
            ____cond109 = ____cond109 or ____switch109 == "angularDamping" -- 524
            if ____cond109 then -- 524
                cnode.angularDamping = v -- 525
                return true -- 525
            end -- 525
            ____cond109 = ____cond109 or ____switch109 == "owner" -- 525
            if ____cond109 then -- 525
                cnode.owner = v -- 526
                return true -- 526
            end -- 526
            ____cond109 = ____cond109 or ____switch109 == "receivingContact" -- 526
            if ____cond109 then -- 526
                cnode.receivingContact = v -- 527
                return true -- 527
            end -- 527
            ____cond109 = ____cond109 or ____switch109 == "onBodyEnter" -- 527
            if ____cond109 then -- 527
                cnode:slot("BodyEnter", v) -- 528
                return true -- 528
            end -- 528
            ____cond109 = ____cond109 or ____switch109 == "onBodyLeave" -- 528
            if ____cond109 then -- 528
                cnode:slot("BodyLeave", v) -- 529
                return true -- 529
            end -- 529
            ____cond109 = ____cond109 or ____switch109 == "onContactStart" -- 529
            if ____cond109 then -- 529
                cnode:slot("ContactStart", v) -- 530
                return true -- 530
            end -- 530
            ____cond109 = ____cond109 or ____switch109 == "onContactEnd" -- 530
            if ____cond109 then -- 530
                cnode:slot("ContactEnd", v) -- 531
                return true -- 531
            end -- 531
            ____cond109 = ____cond109 or ____switch109 == "onContactFilter" -- 531
            if ____cond109 then -- 531
                cnode:onContactFilter(v) -- 532
                return true -- 532
            end -- 532
        until true -- 532
        return false -- 534
    end -- 512
    getBody = function(enode, world) -- 536
        local def = enode.props -- 537
        local bodyDef = dora.BodyDef() -- 538
        bodyDef.type = def.type -- 539
        if def.angle ~= nil then -- 539
            bodyDef.angle = def.angle -- 540
        end -- 540
        if def.angularDamping ~= nil then -- 540
            bodyDef.angularDamping = def.angularDamping -- 541
        end -- 541
        if def.bullet ~= nil then -- 541
            bodyDef.bullet = def.bullet -- 542
        end -- 542
        if def.fixedRotation ~= nil then -- 542
            bodyDef.fixedRotation = def.fixedRotation -- 543
        end -- 543
        bodyDef.linearAcceleration = def.linearAcceleration or dora.Vec2(0, -9.8) -- 544
        if def.linearDamping ~= nil then -- 544
            bodyDef.linearDamping = def.linearDamping -- 545
        end -- 545
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 546
        local extraSensors = nil -- 547
        for i = 1, #enode.children do -- 547
            do -- 547
                local child = enode.children[i] -- 549
                if type(child) ~= "table" then -- 549
                    goto __continue116 -- 551
                end -- 551
                repeat -- 551
                    local ____switch118 = child.type -- 551
                    local ____cond118 = ____switch118 == "rect-fixture" -- 551
                    if ____cond118 then -- 551
                        do -- 551
                            local shape = child.props -- 555
                            if shape.sensorTag ~= nil then -- 555
                                bodyDef:attachPolygonSensor( -- 557
                                    shape.sensorTag, -- 558
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 559
                                    shape.width, -- 560
                                    shape.height, -- 560
                                    shape.angle or 0 -- 561
                                ) -- 561
                            else -- 561
                                bodyDef:attachPolygon( -- 564
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 565
                                    shape.width, -- 566
                                    shape.height, -- 566
                                    shape.angle or 0, -- 567
                                    shape.density or 1, -- 568
                                    shape.friction or 0.4, -- 569
                                    shape.restitution or 0 -- 570
                                ) -- 570
                            end -- 570
                            break -- 573
                        end -- 573
                    end -- 573
                    ____cond118 = ____cond118 or ____switch118 == "polygon-fixture" -- 573
                    if ____cond118 then -- 573
                        do -- 573
                            local shape = child.props -- 576
                            if shape.sensorTag ~= nil then -- 576
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 578
                            else -- 578
                                bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 583
                            end -- 583
                            break -- 590
                        end -- 590
                    end -- 590
                    ____cond118 = ____cond118 or ____switch118 == "multi-fixture" -- 590
                    if ____cond118 then -- 590
                        do -- 590
                            local shape = child.props -- 593
                            if shape.sensorTag ~= nil then -- 593
                                if extraSensors == nil then -- 593
                                    extraSensors = {} -- 595
                                end -- 595
                                extraSensors[#extraSensors + 1] = { -- 596
                                    shape.sensorTag, -- 596
                                    dora.BodyDef:multi(shape.verts) -- 596
                                } -- 596
                            else -- 596
                                bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 598
                            end -- 598
                            break -- 605
                        end -- 605
                    end -- 605
                    ____cond118 = ____cond118 or ____switch118 == "disk-fixture" -- 605
                    if ____cond118 then -- 605
                        do -- 605
                            local shape = child.props -- 608
                            if shape.sensorTag ~= nil then -- 608
                                bodyDef:attachDiskSensor( -- 610
                                    shape.sensorTag, -- 611
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 612
                                    shape.radius -- 613
                                ) -- 613
                            else -- 613
                                bodyDef:attachDisk( -- 616
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 617
                                    shape.radius, -- 618
                                    shape.density or 1, -- 619
                                    shape.friction or 0.4, -- 620
                                    shape.restitution or 0 -- 621
                                ) -- 621
                            end -- 621
                            break -- 624
                        end -- 624
                    end -- 624
                    ____cond118 = ____cond118 or ____switch118 == "chain-fixture" -- 624
                    if ____cond118 then -- 624
                        do -- 624
                            local shape = child.props -- 627
                            if shape.sensorTag ~= nil then -- 627
                                if extraSensors == nil then -- 627
                                    extraSensors = {} -- 629
                                end -- 629
                                extraSensors[#extraSensors + 1] = { -- 630
                                    shape.sensorTag, -- 630
                                    dora.BodyDef:chain(shape.verts) -- 630
                                } -- 630
                            else -- 630
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 632
                            end -- 632
                            break -- 638
                        end -- 638
                    end -- 638
                until true -- 638
            end -- 638
            ::__continue116:: -- 638
        end -- 638
        local body = dora.Body(bodyDef, world) -- 642
        if extraSensors ~= nil then -- 642
            for i = 1, #extraSensors do -- 642
                local tag, def = table.unpack(extraSensors[i]) -- 645
                body:attachSensor(tag, def) -- 646
            end -- 646
        end -- 646
        local cnode = getNode(enode, body, handleBodyAttribute) -- 649
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 649
            body.receivingContact = true -- 656
        end -- 656
        return cnode -- 658
    end -- 536
end -- 536
local getCustomNode -- 662
do -- 662
    local function handleCustomNode(_cnode, _enode, k, _v) -- 664
        repeat -- 664
            local ____switch139 = k -- 664
            local ____cond139 = ____switch139 == "onCreate" -- 664
            if ____cond139 then -- 664
                return true -- 666
            end -- 666
        until true -- 666
        return false -- 668
    end -- 664
    getCustomNode = function(enode) -- 670
        local custom = enode.props -- 671
        local node = custom.onCreate() -- 672
        if node then -- 672
            local cnode = getNode(enode, node, handleCustomNode) -- 674
            return cnode -- 675
        end -- 675
        return nil -- 677
    end -- 670
end -- 670
local getAlignNode -- 681
do -- 681
    local function handleAlignNode(_cnode, _enode, k, _v) -- 683
        repeat -- 683
            local ____switch144 = k -- 683
            local ____cond144 = ____switch144 == "windowRoot" -- 683
            if ____cond144 then -- 683
                return true -- 685
            end -- 685
            ____cond144 = ____cond144 or ____switch144 == "style" -- 685
            if ____cond144 then -- 685
                return true -- 686
            end -- 686
            ____cond144 = ____cond144 or ____switch144 == "onLayout" -- 686
            if ____cond144 then -- 686
                return true -- 687
            end -- 687
        until true -- 687
        return false -- 689
    end -- 683
    getAlignNode = function(enode) -- 691
        local alignNode = enode.props -- 692
        local node = dora.AlignNode(alignNode.windowRoot) -- 693
        if alignNode.style then -- 693
            local items = {} -- 695
            for k, v in pairs(alignNode.style) do -- 696
                local name = string.gsub(k, "%u", "-%1") -- 697
                name = string.lower(name) -- 698
                repeat -- 698
                    local ____switch148 = k -- 698
                    local ____cond148 = ____switch148 == "margin" or ____switch148 == "padding" or ____switch148 == "border" or ____switch148 == "gap" -- 698
                    if ____cond148 then -- 698
                        do -- 698
                            if type(v) == "table" then -- 698
                                local valueStr = table.concat( -- 703
                                    __TS__ArrayMap( -- 703
                                        v, -- 703
                                        function(____, item) return tostring(item) end -- 703
                                    ), -- 703
                                    "," -- 703
                                ) -- 703
                                items[#items + 1] = (name .. ":") .. valueStr -- 704
                            else -- 704
                                items[#items + 1] = (name .. ":") .. tostring(v) -- 706
                            end -- 706
                            break -- 708
                        end -- 708
                    end -- 708
                    do -- 708
                        items[#items + 1] = (name .. ":") .. tostring(v) -- 711
                        break -- 712
                    end -- 712
                until true -- 712
            end -- 712
            if alignNode.onLayout then -- 712
                node:slot("AlignLayout", alignNode.onLayout) -- 716
            end -- 716
            local styleStr = table.concat(items, ";") -- 718
            node:css(styleStr) -- 719
        end -- 719
        local cnode = getNode(enode, node, handleAlignNode) -- 721
        return cnode -- 722
    end -- 691
end -- 691
local function addChild(nodeStack, cnode, enode) -- 726
    if #nodeStack > 0 then -- 726
        local last = nodeStack[#nodeStack] -- 728
        last:addChild(cnode) -- 729
    end -- 729
    nodeStack[#nodeStack + 1] = cnode -- 731
    local ____enode_9 = enode -- 732
    local children = ____enode_9.children -- 732
    for i = 1, #children do -- 732
        visitNode(nodeStack, children[i], enode) -- 734
    end -- 734
    if #nodeStack > 1 then -- 734
        table.remove(nodeStack) -- 737
    end -- 737
end -- 726
local function drawNodeCheck(_nodeStack, enode, parent) -- 745
    if parent == nil or parent.type ~= "draw-node" then -- 745
        Warn(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 747
    end -- 747
end -- 745
local function visitAction(actionStack, enode) -- 751
    local createAction = actionMap[enode.type] -- 752
    if createAction ~= nil then -- 752
        actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 754
        return -- 755
    end -- 755
    repeat -- 755
        local ____switch162 = enode.type -- 755
        local ____cond162 = ____switch162 == "delay" -- 755
        if ____cond162 then -- 755
            do -- 755
                local item = enode.props -- 759
                actionStack[#actionStack + 1] = dora.Delay(item.time) -- 760
                break -- 761
            end -- 761
        end -- 761
        ____cond162 = ____cond162 or ____switch162 == "event" -- 761
        if ____cond162 then -- 761
            do -- 761
                local item = enode.props -- 764
                actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 765
                break -- 766
            end -- 766
        end -- 766
        ____cond162 = ____cond162 or ____switch162 == "hide" -- 766
        if ____cond162 then -- 766
            do -- 766
                actionStack[#actionStack + 1] = dora.Hide() -- 769
                break -- 770
            end -- 770
        end -- 770
        ____cond162 = ____cond162 or ____switch162 == "show" -- 770
        if ____cond162 then -- 770
            do -- 770
                actionStack[#actionStack + 1] = dora.Show() -- 773
                break -- 774
            end -- 774
        end -- 774
        ____cond162 = ____cond162 or ____switch162 == "move" -- 774
        if ____cond162 then -- 774
            do -- 774
                local item = enode.props -- 777
                actionStack[#actionStack + 1] = dora.Move( -- 778
                    item.time, -- 778
                    dora.Vec2(item.startX, item.startY), -- 778
                    dora.Vec2(item.stopX, item.stopY), -- 778
                    item.easing -- 778
                ) -- 778
                break -- 779
            end -- 779
        end -- 779
        ____cond162 = ____cond162 or ____switch162 == "spawn" -- 779
        if ____cond162 then -- 779
            do -- 779
                local spawnStack = {} -- 782
                for i = 1, #enode.children do -- 782
                    visitAction(spawnStack, enode.children[i]) -- 784
                end -- 784
                actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 786
                break -- 787
            end -- 787
        end -- 787
        ____cond162 = ____cond162 or ____switch162 == "sequence" -- 787
        if ____cond162 then -- 787
            do -- 787
                local sequenceStack = {} -- 790
                for i = 1, #enode.children do -- 790
                    visitAction(sequenceStack, enode.children[i]) -- 792
                end -- 792
                actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 794
                break -- 795
            end -- 795
        end -- 795
        do -- 795
            Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 798
            break -- 799
        end -- 799
    until true -- 799
end -- 751
local function actionCheck(nodeStack, enode, parent) -- 803
    local unsupported = false -- 804
    if parent == nil then -- 804
        unsupported = true -- 806
    else -- 806
        repeat -- 806
            local ____switch175 = parent.type -- 806
            local ____cond175 = ____switch175 == "action" or ____switch175 == "spawn" or ____switch175 == "sequence" -- 806
            if ____cond175 then -- 806
                break -- 809
            end -- 809
            do -- 809
                unsupported = true -- 810
                break -- 810
            end -- 810
        until true -- 810
    end -- 810
    if unsupported then -- 810
        if #nodeStack > 0 then -- 810
            local node = nodeStack[#nodeStack] -- 815
            local actionStack = {} -- 816
            visitAction(actionStack, enode) -- 817
            if #actionStack == 1 then -- 817
                node:runAction(actionStack[1]) -- 819
            end -- 819
        else -- 819
            Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 822
        end -- 822
    end -- 822
end -- 803
local function bodyCheck(_nodeStack, enode, parent) -- 827
    if parent == nil or parent.type ~= "body" then -- 827
        Warn(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 829
    end -- 829
end -- 827
actionMap = { -- 833
    ["anchor-x"] = dora.AnchorX, -- 836
    ["anchor-y"] = dora.AnchorY, -- 837
    angle = dora.Angle, -- 838
    ["angle-x"] = dora.AngleX, -- 839
    ["angle-y"] = dora.AngleY, -- 840
    width = dora.Width, -- 841
    height = dora.Height, -- 842
    opacity = dora.Opacity, -- 843
    roll = dora.Roll, -- 844
    scale = dora.Scale, -- 845
    ["scale-x"] = dora.ScaleX, -- 846
    ["scale-y"] = dora.ScaleY, -- 847
    ["skew-x"] = dora.SkewX, -- 848
    ["skew-y"] = dora.SkewY, -- 849
    ["move-x"] = dora.X, -- 850
    ["move-y"] = dora.Y, -- 851
    ["move-z"] = dora.Z -- 852
} -- 852
elementMap = { -- 855
    node = function(nodeStack, enode, parent) -- 856
        addChild( -- 857
            nodeStack, -- 857
            getNode(enode), -- 857
            enode -- 857
        ) -- 857
    end, -- 856
    ["clip-node"] = function(nodeStack, enode, parent) -- 859
        addChild( -- 860
            nodeStack, -- 860
            getClipNode(enode), -- 860
            enode -- 860
        ) -- 860
    end, -- 859
    playable = function(nodeStack, enode, parent) -- 862
        local cnode = getPlayable(enode) -- 863
        if cnode ~= nil then -- 863
            addChild(nodeStack, cnode, enode) -- 865
        end -- 865
    end, -- 862
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 868
        local cnode = getDragonBone(enode) -- 869
        if cnode ~= nil then -- 869
            addChild(nodeStack, cnode, enode) -- 871
        end -- 871
    end, -- 868
    spine = function(nodeStack, enode, parent) -- 874
        local cnode = getSpine(enode) -- 875
        if cnode ~= nil then -- 875
            addChild(nodeStack, cnode, enode) -- 877
        end -- 877
    end, -- 874
    model = function(nodeStack, enode, parent) -- 880
        local cnode = getModel(enode) -- 881
        if cnode ~= nil then -- 881
            addChild(nodeStack, cnode, enode) -- 883
        end -- 883
    end, -- 880
    ["draw-node"] = function(nodeStack, enode, parent) -- 886
        addChild( -- 887
            nodeStack, -- 887
            getDrawNode(enode), -- 887
            enode -- 887
        ) -- 887
    end, -- 886
    ["dot-shape"] = drawNodeCheck, -- 889
    ["segment-shape"] = drawNodeCheck, -- 890
    ["rect-shape"] = drawNodeCheck, -- 891
    ["polygon-shape"] = drawNodeCheck, -- 892
    ["verts-shape"] = drawNodeCheck, -- 893
    grid = function(nodeStack, enode, parent) -- 894
        addChild( -- 895
            nodeStack, -- 895
            getGrid(enode), -- 895
            enode -- 895
        ) -- 895
    end, -- 894
    sprite = function(nodeStack, enode, parent) -- 897
        local cnode = getSprite(enode) -- 898
        if cnode ~= nil then -- 898
            addChild(nodeStack, cnode, enode) -- 900
        end -- 900
    end, -- 897
    label = function(nodeStack, enode, parent) -- 903
        local cnode = getLabel(enode) -- 904
        if cnode ~= nil then -- 904
            addChild(nodeStack, cnode, enode) -- 906
        end -- 906
    end, -- 903
    line = function(nodeStack, enode, parent) -- 909
        addChild( -- 910
            nodeStack, -- 910
            getLine(enode), -- 910
            enode -- 910
        ) -- 910
    end, -- 909
    particle = function(nodeStack, enode, parent) -- 912
        local cnode = getParticle(enode) -- 913
        if cnode ~= nil then -- 913
            addChild(nodeStack, cnode, enode) -- 915
        end -- 915
    end, -- 912
    menu = function(nodeStack, enode, parent) -- 918
        addChild( -- 919
            nodeStack, -- 919
            getMenu(enode), -- 919
            enode -- 919
        ) -- 919
    end, -- 918
    action = function(_nodeStack, enode, parent) -- 921
        if #enode.children == 0 then -- 921
            Warn("<action> tag has no children") -- 923
            return -- 924
        end -- 924
        local action = enode.props -- 926
        if action.ref == nil then -- 926
            Warn("<action> tag has no ref") -- 928
            return -- 929
        end -- 929
        local actionStack = {} -- 931
        for i = 1, #enode.children do -- 931
            visitAction(actionStack, enode.children[i]) -- 933
        end -- 933
        if #actionStack == 1 then -- 933
            action.ref.current = actionStack[1] -- 936
        elseif #actionStack > 1 then -- 936
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 938
        end -- 938
    end, -- 921
    ["anchor-x"] = actionCheck, -- 941
    ["anchor-y"] = actionCheck, -- 942
    angle = actionCheck, -- 943
    ["angle-x"] = actionCheck, -- 944
    ["angle-y"] = actionCheck, -- 945
    delay = actionCheck, -- 946
    event = actionCheck, -- 947
    width = actionCheck, -- 948
    height = actionCheck, -- 949
    hide = actionCheck, -- 950
    show = actionCheck, -- 951
    move = actionCheck, -- 952
    opacity = actionCheck, -- 953
    roll = actionCheck, -- 954
    scale = actionCheck, -- 955
    ["scale-x"] = actionCheck, -- 956
    ["scale-y"] = actionCheck, -- 957
    ["skew-x"] = actionCheck, -- 958
    ["skew-y"] = actionCheck, -- 959
    ["move-x"] = actionCheck, -- 960
    ["move-y"] = actionCheck, -- 961
    ["move-z"] = actionCheck, -- 962
    spawn = actionCheck, -- 963
    sequence = actionCheck, -- 964
    loop = function(nodeStack, enode, _parent) -- 965
        if #nodeStack > 0 then -- 965
            local node = nodeStack[#nodeStack] -- 967
            local actionStack = {} -- 968
            for i = 1, #enode.children do -- 968
                visitAction(actionStack, enode.children[i]) -- 970
            end -- 970
            if #actionStack == 1 then -- 970
                node:runAction(actionStack[1], true) -- 973
            else -- 973
                local loop = enode.props -- 975
                if loop.spawn then -- 975
                    node:runAction( -- 977
                        dora.Spawn(table.unpack(actionStack)), -- 977
                        true -- 977
                    ) -- 977
                else -- 977
                    node:runAction( -- 979
                        dora.Sequence(table.unpack(actionStack)), -- 979
                        true -- 979
                    ) -- 979
                end -- 979
            end -- 979
        else -- 979
            Warn("tag <loop> must be placed under a scene node to take effect") -- 983
        end -- 983
    end, -- 965
    ["physics-world"] = function(nodeStack, enode, _parent) -- 986
        addChild( -- 987
            nodeStack, -- 987
            getPhysicsWorld(enode), -- 987
            enode -- 987
        ) -- 987
    end, -- 986
    contact = function(nodeStack, enode, _parent) -- 989
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 990
        if world ~= nil then -- 990
            local contact = enode.props -- 992
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 993
        else -- 993
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 995
        end -- 995
    end, -- 989
    body = function(nodeStack, enode, _parent) -- 998
        local def = enode.props -- 999
        if def.world then -- 999
            addChild( -- 1001
                nodeStack, -- 1001
                getBody(enode, def.world), -- 1001
                enode -- 1001
            ) -- 1001
            return -- 1002
        end -- 1002
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1004
        if world ~= nil then -- 1004
            addChild( -- 1006
                nodeStack, -- 1006
                getBody(enode, world), -- 1006
                enode -- 1006
            ) -- 1006
        else -- 1006
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1008
        end -- 1008
    end, -- 998
    ["rect-fixture"] = bodyCheck, -- 1011
    ["polygon-fixture"] = bodyCheck, -- 1012
    ["multi-fixture"] = bodyCheck, -- 1013
    ["disk-fixture"] = bodyCheck, -- 1014
    ["chain-fixture"] = bodyCheck, -- 1015
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 1016
        local joint = enode.props -- 1017
        if joint.ref == nil then -- 1017
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1019
            return -- 1020
        end -- 1020
        if joint.bodyA.current == nil then -- 1020
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1023
            return -- 1024
        end -- 1024
        if joint.bodyB.current == nil then -- 1024
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1027
            return -- 1028
        end -- 1028
        local ____joint_ref_13 = joint.ref -- 1030
        local ____self_11 = dora.Joint -- 1030
        local ____self_11_distance_12 = ____self_11.distance -- 1030
        local ____joint_canCollide_10 = joint.canCollide -- 1031
        if ____joint_canCollide_10 == nil then -- 1031
            ____joint_canCollide_10 = false -- 1031
        end -- 1031
        ____joint_ref_13.current = ____self_11_distance_12( -- 1030
            ____self_11, -- 1030
            ____joint_canCollide_10, -- 1031
            joint.bodyA.current, -- 1032
            joint.bodyB.current, -- 1033
            joint.anchorA or dora.Vec2.zero, -- 1034
            joint.anchorB or dora.Vec2.zero, -- 1035
            joint.frequency or 0, -- 1036
            joint.damping or 0 -- 1037
        ) -- 1037
    end, -- 1016
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 1039
        local joint = enode.props -- 1040
        if joint.ref == nil then -- 1040
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1042
            return -- 1043
        end -- 1043
        if joint.bodyA.current == nil then -- 1043
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1046
            return -- 1047
        end -- 1047
        if joint.bodyB.current == nil then -- 1047
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1050
            return -- 1051
        end -- 1051
        local ____joint_ref_17 = joint.ref -- 1053
        local ____self_15 = dora.Joint -- 1053
        local ____self_15_friction_16 = ____self_15.friction -- 1053
        local ____joint_canCollide_14 = joint.canCollide -- 1054
        if ____joint_canCollide_14 == nil then -- 1054
            ____joint_canCollide_14 = false -- 1054
        end -- 1054
        ____joint_ref_17.current = ____self_15_friction_16( -- 1053
            ____self_15, -- 1053
            ____joint_canCollide_14, -- 1054
            joint.bodyA.current, -- 1055
            joint.bodyB.current, -- 1056
            joint.worldPos, -- 1057
            joint.maxForce, -- 1058
            joint.maxTorque -- 1059
        ) -- 1059
    end, -- 1039
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 1062
        local joint = enode.props -- 1063
        if joint.ref == nil then -- 1063
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1065
            return -- 1066
        end -- 1066
        if joint.jointA.current == nil then -- 1066
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1069
            return -- 1070
        end -- 1070
        if joint.jointB.current == nil then -- 1070
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1073
            return -- 1074
        end -- 1074
        local ____joint_ref_21 = joint.ref -- 1076
        local ____self_19 = dora.Joint -- 1076
        local ____self_19_gear_20 = ____self_19.gear -- 1076
        local ____joint_canCollide_18 = joint.canCollide -- 1077
        if ____joint_canCollide_18 == nil then -- 1077
            ____joint_canCollide_18 = false -- 1077
        end -- 1077
        ____joint_ref_21.current = ____self_19_gear_20( -- 1076
            ____self_19, -- 1076
            ____joint_canCollide_18, -- 1077
            joint.jointA.current, -- 1078
            joint.jointB.current, -- 1079
            joint.ratio or 1 -- 1080
        ) -- 1080
    end, -- 1062
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 1083
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
        local ____joint_ref_25 = joint.ref -- 1097
        local ____self_23 = dora.Joint -- 1097
        local ____self_23_spring_24 = ____self_23.spring -- 1097
        local ____joint_canCollide_22 = joint.canCollide -- 1098
        if ____joint_canCollide_22 == nil then -- 1098
            ____joint_canCollide_22 = false -- 1098
        end -- 1098
        ____joint_ref_25.current = ____self_23_spring_24( -- 1097
            ____self_23, -- 1097
            ____joint_canCollide_22, -- 1098
            joint.bodyA.current, -- 1099
            joint.bodyB.current, -- 1100
            joint.linearOffset, -- 1101
            joint.angularOffset, -- 1102
            joint.maxForce, -- 1103
            joint.maxTorque, -- 1104
            joint.correctionFactor or 1 -- 1105
        ) -- 1105
    end, -- 1083
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1108
        local joint = enode.props -- 1109
        if joint.ref == nil then -- 1109
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1111
            return -- 1112
        end -- 1112
        if joint.body.current == nil then -- 1112
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1115
            return -- 1116
        end -- 1116
        local ____joint_ref_29 = joint.ref -- 1118
        local ____self_27 = dora.Joint -- 1118
        local ____self_27_move_28 = ____self_27.move -- 1118
        local ____joint_canCollide_26 = joint.canCollide -- 1119
        if ____joint_canCollide_26 == nil then -- 1119
            ____joint_canCollide_26 = false -- 1119
        end -- 1119
        ____joint_ref_29.current = ____self_27_move_28( -- 1118
            ____self_27, -- 1118
            ____joint_canCollide_26, -- 1119
            joint.body.current, -- 1120
            joint.targetPos, -- 1121
            joint.maxForce, -- 1122
            joint.frequency, -- 1123
            joint.damping or 0.7 -- 1124
        ) -- 1124
    end, -- 1108
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1127
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
        local ____joint_ref_33 = joint.ref -- 1141
        local ____self_31 = dora.Joint -- 1141
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1141
        local ____joint_canCollide_30 = joint.canCollide -- 1142
        if ____joint_canCollide_30 == nil then -- 1142
            ____joint_canCollide_30 = false -- 1142
        end -- 1142
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1141
            ____self_31, -- 1141
            ____joint_canCollide_30, -- 1142
            joint.bodyA.current, -- 1143
            joint.bodyB.current, -- 1144
            joint.worldPos, -- 1145
            joint.axisAngle, -- 1146
            joint.lowerTranslation or 0, -- 1147
            joint.upperTranslation or 0, -- 1148
            joint.maxMotorForce or 0, -- 1149
            joint.motorSpeed or 0 -- 1150
        ) -- 1150
    end, -- 1127
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1153
        local joint = enode.props -- 1154
        if joint.ref == nil then -- 1154
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1156
            return -- 1157
        end -- 1157
        if joint.bodyA.current == nil then -- 1157
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1160
            return -- 1161
        end -- 1161
        if joint.bodyB.current == nil then -- 1161
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1164
            return -- 1165
        end -- 1165
        local ____joint_ref_37 = joint.ref -- 1167
        local ____self_35 = dora.Joint -- 1167
        local ____self_35_pulley_36 = ____self_35.pulley -- 1167
        local ____joint_canCollide_34 = joint.canCollide -- 1168
        if ____joint_canCollide_34 == nil then -- 1168
            ____joint_canCollide_34 = false -- 1168
        end -- 1168
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1167
            ____self_35, -- 1167
            ____joint_canCollide_34, -- 1168
            joint.bodyA.current, -- 1169
            joint.bodyB.current, -- 1170
            joint.anchorA or dora.Vec2.zero, -- 1171
            joint.anchorB or dora.Vec2.zero, -- 1172
            joint.groundAnchorA, -- 1173
            joint.groundAnchorB, -- 1174
            joint.ratio or 1 -- 1175
        ) -- 1175
    end, -- 1153
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1178
        local joint = enode.props -- 1179
        if joint.ref == nil then -- 1179
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1181
            return -- 1182
        end -- 1182
        if joint.bodyA.current == nil then -- 1182
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1185
            return -- 1186
        end -- 1186
        if joint.bodyB.current == nil then -- 1186
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1189
            return -- 1190
        end -- 1190
        local ____joint_ref_41 = joint.ref -- 1192
        local ____self_39 = dora.Joint -- 1192
        local ____self_39_revolute_40 = ____self_39.revolute -- 1192
        local ____joint_canCollide_38 = joint.canCollide -- 1193
        if ____joint_canCollide_38 == nil then -- 1193
            ____joint_canCollide_38 = false -- 1193
        end -- 1193
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1192
            ____self_39, -- 1192
            ____joint_canCollide_38, -- 1193
            joint.bodyA.current, -- 1194
            joint.bodyB.current, -- 1195
            joint.worldPos, -- 1196
            joint.lowerAngle or 0, -- 1197
            joint.upperAngle or 0, -- 1198
            joint.maxMotorTorque or 0, -- 1199
            joint.motorSpeed or 0 -- 1200
        ) -- 1200
    end, -- 1178
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1203
        local joint = enode.props -- 1204
        if joint.ref == nil then -- 1204
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1206
            return -- 1207
        end -- 1207
        if joint.bodyA.current == nil then -- 1207
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1210
            return -- 1211
        end -- 1211
        if joint.bodyB.current == nil then -- 1211
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1214
            return -- 1215
        end -- 1215
        local ____joint_ref_45 = joint.ref -- 1217
        local ____self_43 = dora.Joint -- 1217
        local ____self_43_rope_44 = ____self_43.rope -- 1217
        local ____joint_canCollide_42 = joint.canCollide -- 1218
        if ____joint_canCollide_42 == nil then -- 1218
            ____joint_canCollide_42 = false -- 1218
        end -- 1218
        ____joint_ref_45.current = ____self_43_rope_44( -- 1217
            ____self_43, -- 1217
            ____joint_canCollide_42, -- 1218
            joint.bodyA.current, -- 1219
            joint.bodyB.current, -- 1220
            joint.anchorA or dora.Vec2.zero, -- 1221
            joint.anchorB or dora.Vec2.zero, -- 1222
            joint.maxLength or 0 -- 1223
        ) -- 1223
    end, -- 1203
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1226
        local joint = enode.props -- 1227
        if joint.ref == nil then -- 1227
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1229
            return -- 1230
        end -- 1230
        if joint.bodyA.current == nil then -- 1230
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1233
            return -- 1234
        end -- 1234
        if joint.bodyB.current == nil then -- 1234
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1237
            return -- 1238
        end -- 1238
        local ____joint_ref_49 = joint.ref -- 1240
        local ____self_47 = dora.Joint -- 1240
        local ____self_47_weld_48 = ____self_47.weld -- 1240
        local ____joint_canCollide_46 = joint.canCollide -- 1241
        if ____joint_canCollide_46 == nil then -- 1241
            ____joint_canCollide_46 = false -- 1241
        end -- 1241
        ____joint_ref_49.current = ____self_47_weld_48( -- 1240
            ____self_47, -- 1240
            ____joint_canCollide_46, -- 1241
            joint.bodyA.current, -- 1242
            joint.bodyB.current, -- 1243
            joint.worldPos, -- 1244
            joint.frequency or 0, -- 1245
            joint.damping or 0 -- 1246
        ) -- 1246
    end, -- 1226
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1249
        local joint = enode.props -- 1250
        if joint.ref == nil then -- 1250
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1252
            return -- 1253
        end -- 1253
        if joint.bodyA.current == nil then -- 1253
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1256
            return -- 1257
        end -- 1257
        if joint.bodyB.current == nil then -- 1257
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1260
            return -- 1261
        end -- 1261
        local ____joint_ref_53 = joint.ref -- 1263
        local ____self_51 = dora.Joint -- 1263
        local ____self_51_wheel_52 = ____self_51.wheel -- 1263
        local ____joint_canCollide_50 = joint.canCollide -- 1264
        if ____joint_canCollide_50 == nil then -- 1264
            ____joint_canCollide_50 = false -- 1264
        end -- 1264
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1263
            ____self_51, -- 1263
            ____joint_canCollide_50, -- 1264
            joint.bodyA.current, -- 1265
            joint.bodyB.current, -- 1266
            joint.worldPos, -- 1267
            joint.axisAngle, -- 1268
            joint.maxMotorTorque or 0, -- 1269
            joint.motorSpeed or 0, -- 1270
            joint.frequency or 0, -- 1271
            joint.damping or 0.7 -- 1272
        ) -- 1272
    end, -- 1249
    ["custom-node"] = function(nodeStack, enode, _parent) -- 1275
        local node = getCustomNode(enode) -- 1276
        if node ~= nil then -- 1276
            addChild(nodeStack, node, enode) -- 1278
        end -- 1278
    end, -- 1275
    ["custom-element"] = function() -- 1281
    end, -- 1281
    ["align-node"] = function(nodeStack, enode, _parent) -- 1282
        addChild( -- 1283
            nodeStack, -- 1283
            getAlignNode(enode), -- 1283
            enode -- 1283
        ) -- 1283
    end -- 1282
} -- 1282
function ____exports.useRef(item) -- 1327
    local ____item_54 = item -- 1328
    if ____item_54 == nil then -- 1328
        ____item_54 = nil -- 1328
    end -- 1328
    return {current = ____item_54} -- 1328
end -- 1327
local function getPreload(preloadList, node) -- 1331
    if type(node) ~= "table" then -- 1331
        return -- 1333
    end -- 1333
    local enode = node -- 1335
    if enode.type == nil then -- 1335
        local list = node -- 1337
        if #list > 0 then -- 1337
            for i = 1, #list do -- 1337
                getPreload(preloadList, list[i]) -- 1340
            end -- 1340
        end -- 1340
    else -- 1340
        repeat -- 1340
            local ____switch291 = enode.type -- 1340
            local sprite, playable, model, spine, dragonBone, label -- 1340
            local ____cond291 = ____switch291 == "sprite" -- 1340
            if ____cond291 then -- 1340
                sprite = enode.props -- 1346
                preloadList[#preloadList + 1] = sprite.file -- 1347
                break -- 1348
            end -- 1348
            ____cond291 = ____cond291 or ____switch291 == "playable" -- 1348
            if ____cond291 then -- 1348
                playable = enode.props -- 1350
                preloadList[#preloadList + 1] = playable.file -- 1351
                break -- 1352
            end -- 1352
            ____cond291 = ____cond291 or ____switch291 == "model" -- 1352
            if ____cond291 then -- 1352
                model = enode.props -- 1354
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1355
                break -- 1356
            end -- 1356
            ____cond291 = ____cond291 or ____switch291 == "spine" -- 1356
            if ____cond291 then -- 1356
                spine = enode.props -- 1358
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1359
                break -- 1360
            end -- 1360
            ____cond291 = ____cond291 or ____switch291 == "dragon-bone" -- 1360
            if ____cond291 then -- 1360
                dragonBone = enode.props -- 1362
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1363
                break -- 1364
            end -- 1364
            ____cond291 = ____cond291 or ____switch291 == "label" -- 1364
            if ____cond291 then -- 1364
                label = enode.props -- 1366
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1367
                break -- 1368
            end -- 1368
        until true -- 1368
    end -- 1368
    getPreload(preloadList, enode.children) -- 1371
end -- 1331
function ____exports.preloadAsync(enode, handler) -- 1374
    local preloadList = {} -- 1375
    getPreload(preloadList, enode) -- 1376
    dora.Cache:loadAsync(preloadList, handler) -- 1377
end -- 1374
return ____exports -- 1374