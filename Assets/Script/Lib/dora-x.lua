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
function visitNode(nodeStack, node, parent) -- 1249
    if type(node) ~= "table" then -- 1249
        return -- 1251
    end -- 1251
    local enode = node -- 1253
    if enode.type == nil then -- 1253
        local list = node -- 1255
        if #list > 0 then -- 1255
            for i = 1, #list do -- 1255
                local stack = {} -- 1258
                visitNode(stack, list[i], parent) -- 1259
                for i = 1, #stack do -- 1259
                    nodeStack[#nodeStack + 1] = stack[i] -- 1261
                end -- 1261
            end -- 1261
        end -- 1261
    else -- 1261
        local handler = elementMap[enode.type] -- 1266
        if handler ~= nil then -- 1266
            handler(nodeStack, enode, parent) -- 1268
        else -- 1268
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1270
        end -- 1270
    end -- 1270
end -- 1270
function ____exports.toNode(enode) -- 1275
    local nodeStack = {} -- 1276
    visitNode(nodeStack, enode) -- 1277
    if #nodeStack == 1 then -- 1277
        return nodeStack[1] -- 1279
    elseif #nodeStack > 1 then -- 1279
        local node = dora.Node() -- 1281
        for i = 1, #nodeStack do -- 1281
            node:addChild(nodeStack[i]) -- 1283
        end -- 1283
        return node -- 1285
    end -- 1285
    return nil -- 1287
end -- 1275
____exports.React = {} -- 1275
local React = ____exports.React -- 1275
do -- 1275
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
            local ____cond52 = ____switch52 == "showDebug" -- 242
            if ____cond52 then -- 242
                cnode.showDebug = v -- 244
                return true -- 244
            end -- 244
            ____cond52 = ____cond52 or ____switch52 == "hitTestEnabled" -- 244
            if ____cond52 then -- 244
                cnode.hitTestEnabled = true -- 245
                return true -- 245
            end -- 245
        until true -- 245
        return handlePlayableAttribute(cnode, enode, k, v) -- 247
    end -- 242
    getDragonBone = function(enode) -- 249
        local node = dora.DragonBone(enode.props.file) -- 250
        if node ~= nil then -- 250
            local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 252
            return cnode -- 253
        end -- 253
        return nil -- 255
    end -- 249
    local function handleSpineAttribute(cnode, enode, k, v) -- 258
        repeat -- 258
            local ____switch56 = k -- 258
            local ____cond56 = ____switch56 == "showDebug" -- 258
            if ____cond56 then -- 258
                cnode.showDebug = v -- 260
                return true -- 260
            end -- 260
            ____cond56 = ____cond56 or ____switch56 == "hitTestEnabled" -- 260
            if ____cond56 then -- 260
                cnode.hitTestEnabled = true -- 261
                return true -- 261
            end -- 261
        until true -- 261
        return handlePlayableAttribute(cnode, enode, k, v) -- 263
    end -- 258
    getSpine = function(enode) -- 265
        local node = dora.Spine(enode.props.file) -- 266
        if node ~= nil then -- 266
            local cnode = getPlayable(enode, node, handleSpineAttribute) -- 268
            return cnode -- 269
        end -- 269
        return nil -- 271
    end -- 265
    local function handleModelAttribute(cnode, enode, k, v) -- 274
        repeat -- 274
            local ____switch60 = k -- 274
            local ____cond60 = ____switch60 == "reversed" -- 274
            if ____cond60 then -- 274
                cnode.reversed = v -- 276
                return true -- 276
            end -- 276
        until true -- 276
        return handlePlayableAttribute(cnode, enode, k, v) -- 278
    end -- 274
    getModel = function(enode) -- 280
        local node = dora.Model(enode.props.file) -- 281
        if node ~= nil then -- 281
            local cnode = getPlayable(enode, node, handleModelAttribute) -- 283
            return cnode -- 284
        end -- 284
        return nil -- 286
    end -- 280
end -- 280
local getDrawNode -- 290
do -- 290
    local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 292
        repeat -- 292
            local ____switch65 = k -- 292
            local ____cond65 = ____switch65 == "depthWrite" -- 292
            if ____cond65 then -- 292
                cnode.depthWrite = v -- 294
                return true -- 294
            end -- 294
            ____cond65 = ____cond65 or ____switch65 == "blendFunc" -- 294
            if ____cond65 then -- 294
                cnode.blendFunc = v -- 295
                return true -- 295
            end -- 295
        until true -- 295
        return false -- 297
    end -- 292
    getDrawNode = function(enode) -- 299
        local node = dora.DrawNode() -- 300
        local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 301
        local ____enode_7 = enode -- 302
        local children = ____enode_7.children -- 302
        for i = 1, #children do -- 302
            do -- 302
                local child = children[i] -- 304
                if type(child) ~= "table" then -- 304
                    goto __continue67 -- 306
                end -- 306
                repeat -- 306
                    local ____switch69 = child.type -- 306
                    local ____cond69 = ____switch69 == "dot-shape" -- 306
                    if ____cond69 then -- 306
                        do -- 306
                            local dot = child.props -- 310
                            node:drawDot( -- 311
                                dora.Vec2(dot.x or 0, dot.y or 0), -- 312
                                dot.radius, -- 313
                                dora.Color(dot.color or 4294967295) -- 314
                            ) -- 314
                            break -- 316
                        end -- 316
                    end -- 316
                    ____cond69 = ____cond69 or ____switch69 == "segment-shape" -- 316
                    if ____cond69 then -- 316
                        do -- 316
                            local segment = child.props -- 319
                            node:drawSegment( -- 320
                                dora.Vec2(segment.startX, segment.startY), -- 321
                                dora.Vec2(segment.stopX, segment.stopY), -- 322
                                segment.radius, -- 323
                                dora.Color(segment.color or 4294967295) -- 324
                            ) -- 324
                            break -- 326
                        end -- 326
                    end -- 326
                    ____cond69 = ____cond69 or ____switch69 == "rect-shape" -- 326
                    if ____cond69 then -- 326
                        do -- 326
                            local rect = child.props -- 329
                            local centerX = rect.centerX or 0 -- 330
                            local centerY = rect.centerY or 0 -- 331
                            local hw = rect.width / 2 -- 332
                            local hh = rect.height / 2 -- 333
                            node:drawPolygon( -- 334
                                { -- 335
                                    dora.Vec2(centerX - hw, centerY + hh), -- 336
                                    dora.Vec2(centerX + hw, centerY + hh), -- 337
                                    dora.Vec2(centerX + hw, centerY - hh), -- 338
                                    dora.Vec2(centerX - hw, centerY - hh) -- 339
                                }, -- 339
                                dora.Color(rect.fillColor or 4294967295), -- 341
                                rect.borderWidth or 0, -- 342
                                dora.Color(rect.borderColor or 4294967295) -- 343
                            ) -- 343
                            break -- 345
                        end -- 345
                    end -- 345
                    ____cond69 = ____cond69 or ____switch69 == "polygon-shape" -- 345
                    if ____cond69 then -- 345
                        do -- 345
                            local poly = child.props -- 348
                            node:drawPolygon( -- 349
                                poly.verts, -- 350
                                dora.Color(poly.fillColor or 4294967295), -- 351
                                poly.borderWidth or 0, -- 352
                                dora.Color(poly.borderColor or 4294967295) -- 353
                            ) -- 353
                            break -- 355
                        end -- 355
                    end -- 355
                    ____cond69 = ____cond69 or ____switch69 == "verts-shape" -- 355
                    if ____cond69 then -- 355
                        do -- 355
                            local verts = child.props -- 358
                            node:drawVertices(__TS__ArrayMap( -- 359
                                verts.verts, -- 359
                                function(____, ____bindingPattern0) -- 359
                                    local color -- 359
                                    local vert -- 359
                                    vert = ____bindingPattern0[1] -- 359
                                    color = ____bindingPattern0[2] -- 359
                                    return { -- 359
                                        vert, -- 359
                                        dora.Color(color) -- 359
                                    } -- 359
                                end -- 359
                            )) -- 359
                            break -- 360
                        end -- 360
                    end -- 360
                until true -- 360
            end -- 360
            ::__continue67:: -- 360
        end -- 360
        return cnode -- 364
    end -- 299
end -- 299
local getGrid -- 368
do -- 368
    local function handleGridAttribute(cnode, _enode, k, v) -- 370
        repeat -- 370
            local ____switch78 = k -- 370
            local ____cond78 = ____switch78 == "file" or ____switch78 == "gridX" or ____switch78 == "gridY" -- 370
            if ____cond78 then -- 370
                return true -- 372
            end -- 372
            ____cond78 = ____cond78 or ____switch78 == "textureRect" -- 372
            if ____cond78 then -- 372
                cnode.textureRect = v -- 373
                return true -- 373
            end -- 373
            ____cond78 = ____cond78 or ____switch78 == "depthWrite" -- 373
            if ____cond78 then -- 373
                cnode.depthWrite = v -- 374
                return true -- 374
            end -- 374
            ____cond78 = ____cond78 or ____switch78 == "blendFunc" -- 374
            if ____cond78 then -- 374
                cnode.blendFunc = v -- 375
                return true -- 375
            end -- 375
            ____cond78 = ____cond78 or ____switch78 == "effect" -- 375
            if ____cond78 then -- 375
                cnode.effect = v -- 376
                return true -- 376
            end -- 376
        until true -- 376
        return false -- 378
    end -- 370
    getGrid = function(enode) -- 380
        local grid = enode.props -- 381
        local node = dora.Grid(grid.file, grid.gridX, grid.gridY) -- 382
        local cnode = getNode(enode, node, handleGridAttribute) -- 383
        return cnode -- 384
    end -- 380
end -- 380
local getSprite -- 388
do -- 388
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 390
        repeat -- 390
            local ____switch82 = k -- 390
            local ____cond82 = ____switch82 == "file" -- 390
            if ____cond82 then -- 390
                return true -- 392
            end -- 392
            ____cond82 = ____cond82 or ____switch82 == "textureRect" -- 392
            if ____cond82 then -- 392
                cnode.textureRect = v -- 393
                return true -- 393
            end -- 393
            ____cond82 = ____cond82 or ____switch82 == "depthWrite" -- 393
            if ____cond82 then -- 393
                cnode.depthWrite = v -- 394
                return true -- 394
            end -- 394
            ____cond82 = ____cond82 or ____switch82 == "blendFunc" -- 394
            if ____cond82 then -- 394
                cnode.blendFunc = v -- 395
                return true -- 395
            end -- 395
            ____cond82 = ____cond82 or ____switch82 == "effect" -- 395
            if ____cond82 then -- 395
                cnode.effect = v -- 396
                return true -- 396
            end -- 396
            ____cond82 = ____cond82 or ____switch82 == "alphaRef" -- 396
            if ____cond82 then -- 396
                cnode.alphaRef = v -- 397
                return true -- 397
            end -- 397
            ____cond82 = ____cond82 or ____switch82 == "uwrap" -- 397
            if ____cond82 then -- 397
                cnode.uwrap = v -- 398
                return true -- 398
            end -- 398
            ____cond82 = ____cond82 or ____switch82 == "vwrap" -- 398
            if ____cond82 then -- 398
                cnode.vwrap = v -- 399
                return true -- 399
            end -- 399
            ____cond82 = ____cond82 or ____switch82 == "filter" -- 399
            if ____cond82 then -- 399
                cnode.filter = v -- 400
                return true -- 400
            end -- 400
        until true -- 400
        return false -- 402
    end -- 390
    getSprite = function(enode) -- 404
        local sp = enode.props -- 405
        local node = dora.Sprite(sp.file) -- 406
        if node ~= nil then -- 406
            local cnode = getNode(enode, node, handleSpriteAttribute) -- 408
            return cnode -- 409
        end -- 409
        return nil -- 411
    end -- 404
end -- 404
local getLabel -- 415
do -- 415
    local function handleLabelAttribute(cnode, _enode, k, v) -- 417
        repeat -- 417
            local ____switch87 = k -- 417
            local ____cond87 = ____switch87 == "fontName" or ____switch87 == "fontSize" or ____switch87 == "text" -- 417
            if ____cond87 then -- 417
                return true -- 419
            end -- 419
            ____cond87 = ____cond87 or ____switch87 == "alphaRef" -- 419
            if ____cond87 then -- 419
                cnode.alphaRef = v -- 420
                return true -- 420
            end -- 420
            ____cond87 = ____cond87 or ____switch87 == "textWidth" -- 420
            if ____cond87 then -- 420
                cnode.textWidth = v -- 421
                return true -- 421
            end -- 421
            ____cond87 = ____cond87 or ____switch87 == "lineGap" -- 421
            if ____cond87 then -- 421
                cnode.lineGap = v -- 422
                return true -- 422
            end -- 422
            ____cond87 = ____cond87 or ____switch87 == "spacing" -- 422
            if ____cond87 then -- 422
                cnode.spacing = v -- 423
                return true -- 423
            end -- 423
            ____cond87 = ____cond87 or ____switch87 == "blendFunc" -- 423
            if ____cond87 then -- 423
                cnode.blendFunc = v -- 424
                return true -- 424
            end -- 424
            ____cond87 = ____cond87 or ____switch87 == "depthWrite" -- 424
            if ____cond87 then -- 424
                cnode.depthWrite = v -- 425
                return true -- 425
            end -- 425
            ____cond87 = ____cond87 or ____switch87 == "batched" -- 425
            if ____cond87 then -- 425
                cnode.batched = v -- 426
                return true -- 426
            end -- 426
            ____cond87 = ____cond87 or ____switch87 == "effect" -- 426
            if ____cond87 then -- 426
                cnode.effect = v -- 427
                return true -- 427
            end -- 427
            ____cond87 = ____cond87 or ____switch87 == "alignment" -- 427
            if ____cond87 then -- 427
                cnode.alignment = v -- 428
                return true -- 428
            end -- 428
        until true -- 428
        return false -- 430
    end -- 417
    getLabel = function(enode) -- 432
        local label = enode.props -- 433
        local node = dora.Label(label.fontName, label.fontSize) -- 434
        if node ~= nil then -- 434
            local cnode = getNode(enode, node, handleLabelAttribute) -- 436
            local ____enode_8 = enode -- 437
            local children = ____enode_8.children -- 437
            local text = label.text or "" -- 438
            for i = 1, #children do -- 438
                local child = children[i] -- 440
                if type(child) ~= "table" then -- 440
                    text = text .. tostring(child) -- 442
                end -- 442
            end -- 442
            node.text = text -- 445
            return cnode -- 446
        end -- 446
        return nil -- 448
    end -- 432
end -- 432
local getLine -- 452
do -- 452
    local function handleLineAttribute(cnode, enode, k, v) -- 454
        local line = enode.props -- 455
        repeat -- 455
            local ____switch94 = k -- 455
            local ____cond94 = ____switch94 == "verts" -- 455
            if ____cond94 then -- 455
                cnode:set( -- 457
                    v, -- 457
                    dora.Color(line.lineColor or 4294967295) -- 457
                ) -- 457
                return true -- 457
            end -- 457
            ____cond94 = ____cond94 or ____switch94 == "depthWrite" -- 457
            if ____cond94 then -- 457
                cnode.depthWrite = v -- 458
                return true -- 458
            end -- 458
            ____cond94 = ____cond94 or ____switch94 == "blendFunc" -- 458
            if ____cond94 then -- 458
                cnode.blendFunc = v -- 459
                return true -- 459
            end -- 459
        until true -- 459
        return false -- 461
    end -- 454
    getLine = function(enode) -- 463
        local node = dora.Line() -- 464
        local cnode = getNode(enode, node, handleLineAttribute) -- 465
        return cnode -- 466
    end -- 463
end -- 463
local getParticle -- 470
do -- 470
    local function handleParticleAttribute(cnode, _enode, k, v) -- 472
        repeat -- 472
            local ____switch98 = k -- 472
            local ____cond98 = ____switch98 == "file" -- 472
            if ____cond98 then -- 472
                return true -- 474
            end -- 474
            ____cond98 = ____cond98 or ____switch98 == "emit" -- 474
            if ____cond98 then -- 474
                if v then -- 474
                    cnode:start() -- 475
                end -- 475
                return true -- 475
            end -- 475
            ____cond98 = ____cond98 or ____switch98 == "onFinished" -- 475
            if ____cond98 then -- 475
                cnode:slot("Finished", v) -- 476
                return true -- 476
            end -- 476
        until true -- 476
        return false -- 478
    end -- 472
    getParticle = function(enode) -- 480
        local particle = enode.props -- 481
        local node = dora.Particle(particle.file) -- 482
        if node ~= nil then -- 482
            local cnode = getNode(enode, node, handleParticleAttribute) -- 484
            return cnode -- 485
        end -- 485
        return nil -- 487
    end -- 480
end -- 480
local getMenu -- 491
do -- 491
    local function handleMenuAttribute(cnode, _enode, k, v) -- 493
        repeat -- 493
            local ____switch104 = k -- 493
            local ____cond104 = ____switch104 == "enabled" -- 493
            if ____cond104 then -- 493
                cnode.enabled = v -- 495
                return true -- 495
            end -- 495
        until true -- 495
        return false -- 497
    end -- 493
    getMenu = function(enode) -- 499
        local node = dora.Menu() -- 500
        local cnode = getNode(enode, node, handleMenuAttribute) -- 501
        return cnode -- 502
    end -- 499
end -- 499
local getPhysicsWorld -- 506
do -- 506
    local function handlePhysicsWorldAttribute(cnode, _enode, k, v) -- 508
        repeat -- 508
            local ____switch108 = k -- 508
            local ____cond108 = ____switch108 == "showDebug" -- 508
            if ____cond108 then -- 508
                cnode.showDebug = v -- 510
                return true -- 510
            end -- 510
        until true -- 510
        return false -- 512
    end -- 508
    getPhysicsWorld = function(enode) -- 514
        local node = dora.PhysicsWorld() -- 515
        local cnode = getNode(enode, node, handlePhysicsWorldAttribute) -- 516
        return cnode -- 517
    end -- 514
end -- 514
local getBody -- 521
do -- 521
    local function handleBodyAttribute(cnode, _enode, k, v) -- 523
        repeat -- 523
            local ____switch112 = k -- 523
            local ____cond112 = ____switch112 == "type" or ____switch112 == "linearAcceleration" or ____switch112 == "fixedRotation" or ____switch112 == "bullet" or ____switch112 == "world" -- 523
            if ____cond112 then -- 523
                return true -- 530
            end -- 530
            ____cond112 = ____cond112 or ____switch112 == "velocityX" -- 530
            if ____cond112 then -- 530
                cnode.velocityX = v -- 531
                return true -- 531
            end -- 531
            ____cond112 = ____cond112 or ____switch112 == "velocityY" -- 531
            if ____cond112 then -- 531
                cnode.velocityY = v -- 532
                return true -- 532
            end -- 532
            ____cond112 = ____cond112 or ____switch112 == "angularRate" -- 532
            if ____cond112 then -- 532
                cnode.angularRate = v -- 533
                return true -- 533
            end -- 533
            ____cond112 = ____cond112 or ____switch112 == "group" -- 533
            if ____cond112 then -- 533
                cnode.group = v -- 534
                return true -- 534
            end -- 534
            ____cond112 = ____cond112 or ____switch112 == "linearDamping" -- 534
            if ____cond112 then -- 534
                cnode.linearDamping = v -- 535
                return true -- 535
            end -- 535
            ____cond112 = ____cond112 or ____switch112 == "angularDamping" -- 535
            if ____cond112 then -- 535
                cnode.angularDamping = v -- 536
                return true -- 536
            end -- 536
            ____cond112 = ____cond112 or ____switch112 == "owner" -- 536
            if ____cond112 then -- 536
                cnode.owner = v -- 537
                return true -- 537
            end -- 537
            ____cond112 = ____cond112 or ____switch112 == "receivingContact" -- 537
            if ____cond112 then -- 537
                cnode.receivingContact = v -- 538
                return true -- 538
            end -- 538
            ____cond112 = ____cond112 or ____switch112 == "onBodyEnter" -- 538
            if ____cond112 then -- 538
                cnode:slot("BodyEnter", v) -- 539
                return true -- 539
            end -- 539
            ____cond112 = ____cond112 or ____switch112 == "onBodyLeave" -- 539
            if ____cond112 then -- 539
                cnode:slot("BodyLeave", v) -- 540
                return true -- 540
            end -- 540
            ____cond112 = ____cond112 or ____switch112 == "onContactStart" -- 540
            if ____cond112 then -- 540
                cnode:slot("ContactStart", v) -- 541
                return true -- 541
            end -- 541
            ____cond112 = ____cond112 or ____switch112 == "onContactEnd" -- 541
            if ____cond112 then -- 541
                cnode:slot("ContactEnd", v) -- 542
                return true -- 542
            end -- 542
            ____cond112 = ____cond112 or ____switch112 == "onContactFilter" -- 542
            if ____cond112 then -- 542
                cnode:onContactFilter(v) -- 543
                return true -- 543
            end -- 543
        until true -- 543
        return false -- 545
    end -- 523
    getBody = function(enode, world) -- 547
        local def = enode.props -- 548
        local bodyDef = dora.BodyDef() -- 549
        bodyDef.type = def.type -- 550
        if def.angle ~= nil then -- 550
            bodyDef.angle = def.angle -- 551
        end -- 551
        if def.angularDamping ~= nil then -- 551
            bodyDef.angularDamping = def.angularDamping -- 552
        end -- 552
        if def.bullet ~= nil then -- 552
            bodyDef.bullet = def.bullet -- 553
        end -- 553
        if def.fixedRotation ~= nil then -- 553
            bodyDef.fixedRotation = def.fixedRotation -- 554
        end -- 554
        if def.linearAcceleration ~= nil then -- 554
            bodyDef.linearAcceleration = def.linearAcceleration -- 555
        end -- 555
        if def.linearDamping ~= nil then -- 555
            bodyDef.linearDamping = def.linearDamping -- 556
        end -- 556
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 557
        local extraSensors = nil -- 558
        for i = 1, #enode.children do -- 558
            do -- 558
                local child = enode.children[i] -- 560
                if type(child) ~= "table" then -- 560
                    goto __continue120 -- 562
                end -- 562
                repeat -- 562
                    local ____switch122 = child.type -- 562
                    local ____cond122 = ____switch122 == "rect-fixture" -- 562
                    if ____cond122 then -- 562
                        do -- 562
                            local shape = child.props -- 566
                            if shape.sensorTag ~= nil then -- 566
                                bodyDef:attachPolygonSensor( -- 568
                                    shape.sensorTag, -- 569
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 570
                                    shape.width, -- 571
                                    shape.height, -- 571
                                    shape.angle or 0 -- 572
                                ) -- 572
                            else -- 572
                                bodyDef:attachPolygon( -- 575
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 576
                                    shape.width, -- 577
                                    shape.height, -- 577
                                    shape.angle or 0, -- 578
                                    shape.density or 0, -- 579
                                    shape.friction or 0.4, -- 580
                                    shape.restitution or 0 -- 581
                                ) -- 581
                            end -- 581
                            break -- 584
                        end -- 584
                    end -- 584
                    ____cond122 = ____cond122 or ____switch122 == "polygon-fixture" -- 584
                    if ____cond122 then -- 584
                        do -- 584
                            local shape = child.props -- 587
                            if shape.sensorTag ~= nil then -- 587
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 589
                            else -- 589
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 594
                            end -- 594
                            break -- 601
                        end -- 601
                    end -- 601
                    ____cond122 = ____cond122 or ____switch122 == "multi-fixture" -- 601
                    if ____cond122 then -- 601
                        do -- 601
                            local shape = child.props -- 604
                            if shape.sensorTag ~= nil then -- 604
                                if extraSensors == nil then -- 604
                                    extraSensors = {} -- 606
                                end -- 606
                                extraSensors[#extraSensors + 1] = { -- 607
                                    shape.sensorTag, -- 607
                                    dora.BodyDef:multi(shape.verts) -- 607
                                } -- 607
                            else -- 607
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 609
                            end -- 609
                            break -- 616
                        end -- 616
                    end -- 616
                    ____cond122 = ____cond122 or ____switch122 == "disk-fixture" -- 616
                    if ____cond122 then -- 616
                        do -- 616
                            local shape = child.props -- 619
                            if shape.sensorTag ~= nil then -- 619
                                bodyDef:attachDiskSensor( -- 621
                                    shape.sensorTag, -- 622
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 623
                                    shape.radius -- 624
                                ) -- 624
                            else -- 624
                                bodyDef:attachDisk( -- 627
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 628
                                    shape.radius, -- 629
                                    shape.density or 0, -- 630
                                    shape.friction or 0.4, -- 631
                                    shape.restitution or 0 -- 632
                                ) -- 632
                            end -- 632
                            break -- 635
                        end -- 635
                    end -- 635
                    ____cond122 = ____cond122 or ____switch122 == "chain-fixture" -- 635
                    if ____cond122 then -- 635
                        do -- 635
                            local shape = child.props -- 638
                            if shape.sensorTag ~= nil then -- 638
                                if extraSensors == nil then -- 638
                                    extraSensors = {} -- 640
                                end -- 640
                                extraSensors[#extraSensors + 1] = { -- 641
                                    shape.sensorTag, -- 641
                                    dora.BodyDef:chain(shape.verts) -- 641
                                } -- 641
                            else -- 641
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 643
                            end -- 643
                            break -- 649
                        end -- 649
                    end -- 649
                until true -- 649
            end -- 649
            ::__continue120:: -- 649
        end -- 649
        local body = dora.Body(bodyDef, world) -- 653
        if extraSensors ~= nil then -- 653
            for i = 1, #extraSensors do -- 653
                local tag, def = table.unpack(extraSensors[i]) -- 656
                body:attachSensor(tag, def) -- 657
            end -- 657
        end -- 657
        local cnode = getNode(enode, body, handleBodyAttribute) -- 660
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 660
            body.receivingContact = true -- 667
        end -- 667
        return cnode -- 669
    end -- 547
end -- 547
local getCustomNode -- 673
do -- 673
    local function handleCustomNode(_cnode, _enode, k, _v) -- 675
        repeat -- 675
            local ____switch143 = k -- 675
            local ____cond143 = ____switch143 == "onCreate" -- 675
            if ____cond143 then -- 675
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
local function addChild(nodeStack, cnode, enode) -- 692
    if #nodeStack > 0 then -- 692
        local last = nodeStack[#nodeStack] -- 694
        last:addChild(cnode) -- 695
    end -- 695
    nodeStack[#nodeStack + 1] = cnode -- 697
    local ____enode_9 = enode -- 698
    local children = ____enode_9.children -- 698
    for i = 1, #children do -- 698
        visitNode(nodeStack, children[i], enode) -- 700
    end -- 700
    if #nodeStack > 1 then -- 700
        table.remove(nodeStack) -- 703
    end -- 703
end -- 692
local function drawNodeCheck(_nodeStack, enode, parent) -- 711
    if parent == nil or parent.type ~= "draw-node" then -- 711
        Warn(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 713
    end -- 713
end -- 711
local function visitAction(actionStack, enode) -- 717
    local createAction = actionMap[enode.type] -- 718
    if createAction ~= nil then -- 718
        actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 720
        return -- 721
    end -- 721
    repeat -- 721
        local ____switch154 = enode.type -- 721
        local ____cond154 = ____switch154 == "delay" -- 721
        if ____cond154 then -- 721
            do -- 721
                local item = enode.props -- 725
                actionStack[#actionStack + 1] = dora.Delay(item.time) -- 726
                break -- 727
            end -- 727
        end -- 727
        ____cond154 = ____cond154 or ____switch154 == "event" -- 727
        if ____cond154 then -- 727
            do -- 727
                local item = enode.props -- 730
                actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 731
                break -- 732
            end -- 732
        end -- 732
        ____cond154 = ____cond154 or ____switch154 == "hide" -- 732
        if ____cond154 then -- 732
            do -- 732
                actionStack[#actionStack + 1] = dora.Hide() -- 735
                break -- 736
            end -- 736
        end -- 736
        ____cond154 = ____cond154 or ____switch154 == "show" -- 736
        if ____cond154 then -- 736
            do -- 736
                actionStack[#actionStack + 1] = dora.Show() -- 739
                break -- 740
            end -- 740
        end -- 740
        ____cond154 = ____cond154 or ____switch154 == "move" -- 740
        if ____cond154 then -- 740
            do -- 740
                local item = enode.props -- 743
                actionStack[#actionStack + 1] = dora.Move( -- 744
                    item.time, -- 744
                    dora.Vec2(item.startX, item.startY), -- 744
                    dora.Vec2(item.stopX, item.stopY), -- 744
                    item.easing -- 744
                ) -- 744
                break -- 745
            end -- 745
        end -- 745
        ____cond154 = ____cond154 or ____switch154 == "spawn" -- 745
        if ____cond154 then -- 745
            do -- 745
                local spawnStack = {} -- 748
                for i = 1, #enode.children do -- 748
                    visitAction(spawnStack, enode.children[i]) -- 750
                end -- 750
                actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 752
                break -- 753
            end -- 753
        end -- 753
        ____cond154 = ____cond154 or ____switch154 == "sequence" -- 753
        if ____cond154 then -- 753
            do -- 753
                local sequenceStack = {} -- 756
                for i = 1, #enode.children do -- 756
                    visitAction(sequenceStack, enode.children[i]) -- 758
                end -- 758
                actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 760
                break -- 761
            end -- 761
        end -- 761
        do -- 761
            Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 764
            break -- 765
        end -- 765
    until true -- 765
end -- 717
local function actionCheck(nodeStack, enode, parent) -- 769
    local unsupported = false -- 770
    if parent == nil then -- 770
        unsupported = true -- 772
    else -- 772
        repeat -- 772
            local ____switch167 = parent.type -- 772
            local ____cond167 = ____switch167 == "action" or ____switch167 == "spawn" or ____switch167 == "sequence" -- 772
            if ____cond167 then -- 772
                break -- 775
            end -- 775
            do -- 775
                unsupported = true -- 776
                break -- 776
            end -- 776
        until true -- 776
    end -- 776
    if unsupported then -- 776
        if #nodeStack > 0 then -- 776
            local node = nodeStack[#nodeStack] -- 781
            local actionStack = {} -- 782
            visitAction(actionStack, enode) -- 783
            if #actionStack == 1 then -- 783
                node:runAction(actionStack[1]) -- 785
            end -- 785
        else -- 785
            Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 788
        end -- 788
    end -- 788
end -- 769
local function bodyCheck(_nodeStack, enode, parent) -- 793
    if parent == nil or parent.type ~= "body" then -- 793
        Warn(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 795
    end -- 795
end -- 793
actionMap = { -- 799
    ["anchor-x"] = dora.AnchorX, -- 802
    ["anchor-y"] = dora.AnchorY, -- 803
    angle = dora.Angle, -- 804
    ["angle-x"] = dora.AngleX, -- 805
    ["angle-y"] = dora.AngleY, -- 806
    width = dora.Width, -- 807
    height = dora.Height, -- 808
    opacity = dora.Opacity, -- 809
    roll = dora.Roll, -- 810
    scale = dora.Scale, -- 811
    ["scale-x"] = dora.ScaleX, -- 812
    ["scale-y"] = dora.ScaleY, -- 813
    ["skew-x"] = dora.SkewX, -- 814
    ["skew-y"] = dora.SkewY, -- 815
    ["move-x"] = dora.X, -- 816
    ["move-y"] = dora.Y, -- 817
    ["move-z"] = dora.Z -- 818
} -- 818
elementMap = { -- 821
    node = function(nodeStack, enode, parent) -- 822
        addChild( -- 823
            nodeStack, -- 823
            getNode(enode), -- 823
            enode -- 823
        ) -- 823
    end, -- 822
    ["clip-node"] = function(nodeStack, enode, parent) -- 825
        addChild( -- 826
            nodeStack, -- 826
            getClipNode(enode), -- 826
            enode -- 826
        ) -- 826
    end, -- 825
    playable = function(nodeStack, enode, parent) -- 828
        local cnode = getPlayable(enode) -- 829
        if cnode ~= nil then -- 829
            addChild(nodeStack, cnode, enode) -- 831
        end -- 831
    end, -- 828
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 834
        local cnode = getDragonBone(enode) -- 835
        if cnode ~= nil then -- 835
            addChild(nodeStack, cnode, enode) -- 837
        end -- 837
    end, -- 834
    spine = function(nodeStack, enode, parent) -- 840
        local cnode = getSpine(enode) -- 841
        if cnode ~= nil then -- 841
            addChild(nodeStack, cnode, enode) -- 843
        end -- 843
    end, -- 840
    model = function(nodeStack, enode, parent) -- 846
        local cnode = getModel(enode) -- 847
        if cnode ~= nil then -- 847
            addChild(nodeStack, cnode, enode) -- 849
        end -- 849
    end, -- 846
    ["draw-node"] = function(nodeStack, enode, parent) -- 852
        addChild( -- 853
            nodeStack, -- 853
            getDrawNode(enode), -- 853
            enode -- 853
        ) -- 853
    end, -- 852
    ["dot-shape"] = drawNodeCheck, -- 855
    ["segment-shape"] = drawNodeCheck, -- 856
    ["rect-shape"] = drawNodeCheck, -- 857
    ["polygon-shape"] = drawNodeCheck, -- 858
    ["verts-shape"] = drawNodeCheck, -- 859
    grid = function(nodeStack, enode, parent) -- 860
        addChild( -- 861
            nodeStack, -- 861
            getGrid(enode), -- 861
            enode -- 861
        ) -- 861
    end, -- 860
    sprite = function(nodeStack, enode, parent) -- 863
        local cnode = getSprite(enode) -- 864
        if cnode ~= nil then -- 864
            addChild(nodeStack, cnode, enode) -- 866
        end -- 866
    end, -- 863
    label = function(nodeStack, enode, parent) -- 869
        local cnode = getLabel(enode) -- 870
        if cnode ~= nil then -- 870
            addChild(nodeStack, cnode, enode) -- 872
        end -- 872
    end, -- 869
    line = function(nodeStack, enode, parent) -- 875
        addChild( -- 876
            nodeStack, -- 876
            getLine(enode), -- 876
            enode -- 876
        ) -- 876
    end, -- 875
    particle = function(nodeStack, enode, parent) -- 878
        local cnode = getParticle(enode) -- 879
        if cnode ~= nil then -- 879
            addChild(nodeStack, cnode, enode) -- 881
        end -- 881
    end, -- 878
    menu = function(nodeStack, enode, parent) -- 884
        addChild( -- 885
            nodeStack, -- 885
            getMenu(enode), -- 885
            enode -- 885
        ) -- 885
    end, -- 884
    action = function(_nodeStack, enode, parent) -- 887
        if #enode.children == 0 then -- 887
            Warn("<action> tag has no children") -- 889
            return -- 890
        end -- 890
        local action = enode.props -- 892
        if action.ref == nil then -- 892
            Warn("<action> tag has no ref") -- 894
            return -- 895
        end -- 895
        local actionStack = {} -- 897
        for i = 1, #enode.children do -- 897
            visitAction(actionStack, enode.children[i]) -- 899
        end -- 899
        if #actionStack == 1 then -- 899
            action.ref.current = actionStack[1] -- 902
        elseif #actionStack > 1 then -- 902
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 904
        end -- 904
    end, -- 887
    ["anchor-x"] = actionCheck, -- 907
    ["anchor-y"] = actionCheck, -- 908
    angle = actionCheck, -- 909
    ["angle-x"] = actionCheck, -- 910
    ["angle-y"] = actionCheck, -- 911
    delay = actionCheck, -- 912
    event = actionCheck, -- 913
    width = actionCheck, -- 914
    height = actionCheck, -- 915
    hide = actionCheck, -- 916
    show = actionCheck, -- 917
    move = actionCheck, -- 918
    opacity = actionCheck, -- 919
    roll = actionCheck, -- 920
    scale = actionCheck, -- 921
    ["scale-x"] = actionCheck, -- 922
    ["scale-y"] = actionCheck, -- 923
    ["skew-x"] = actionCheck, -- 924
    ["skew-y"] = actionCheck, -- 925
    ["move-x"] = actionCheck, -- 926
    ["move-y"] = actionCheck, -- 927
    ["move-z"] = actionCheck, -- 928
    spawn = actionCheck, -- 929
    sequence = actionCheck, -- 930
    loop = function(nodeStack, enode, _parent) -- 931
        if #nodeStack > 0 then -- 931
            local node = nodeStack[#nodeStack] -- 933
            local actionStack = {} -- 934
            for i = 1, #enode.children do -- 934
                visitAction(actionStack, enode.children[i]) -- 936
            end -- 936
            if #actionStack == 1 then -- 936
                node:runAction(actionStack[1], true) -- 939
            else -- 939
                local loop = enode.props -- 941
                if loop.spawn then -- 941
                    node:runAction( -- 943
                        dora.Spawn(table.unpack(actionStack)), -- 943
                        true -- 943
                    ) -- 943
                else -- 943
                    node:runAction( -- 945
                        dora.Sequence(table.unpack(actionStack)), -- 945
                        true -- 945
                    ) -- 945
                end -- 945
            end -- 945
        else -- 945
            Warn("tag <loop> must be placed under a scene node to take effect") -- 949
        end -- 949
    end, -- 931
    ["physics-world"] = function(nodeStack, enode, _parent) -- 952
        addChild( -- 953
            nodeStack, -- 953
            getPhysicsWorld(enode), -- 953
            enode -- 953
        ) -- 953
    end, -- 952
    contact = function(nodeStack, enode, _parent) -- 955
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 956
        if world ~= nil then -- 956
            local contact = enode.props -- 958
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 959
        else -- 959
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 961
        end -- 961
    end, -- 955
    body = function(nodeStack, enode, _parent) -- 964
        local def = enode.props -- 965
        if def.world then -- 965
            addChild( -- 967
                nodeStack, -- 967
                getBody(enode, def.world), -- 967
                enode -- 967
            ) -- 967
            return -- 968
        end -- 968
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 970
        if world ~= nil then -- 970
            addChild( -- 972
                nodeStack, -- 972
                getBody(enode, world), -- 972
                enode -- 972
            ) -- 972
        else -- 972
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 974
        end -- 974
    end, -- 964
    ["rect-fixture"] = bodyCheck, -- 977
    ["polygon-fixture"] = bodyCheck, -- 978
    ["multi-fixture"] = bodyCheck, -- 979
    ["disk-fixture"] = bodyCheck, -- 980
    ["chain-fixture"] = bodyCheck, -- 981
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 982
        local joint = enode.props -- 983
        if joint.ref == nil then -- 983
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 985
            return -- 986
        end -- 986
        if joint.bodyA.current == nil then -- 986
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 989
            return -- 990
        end -- 990
        if joint.bodyB.current == nil then -- 990
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 993
            return -- 994
        end -- 994
        local ____joint_ref_13 = joint.ref -- 996
        local ____self_11 = dora.Joint -- 996
        local ____self_11_distance_12 = ____self_11.distance -- 996
        local ____joint_canCollide_10 = joint.canCollide -- 997
        if ____joint_canCollide_10 == nil then -- 997
            ____joint_canCollide_10 = false -- 997
        end -- 997
        ____joint_ref_13.current = ____self_11_distance_12( -- 996
            ____self_11, -- 996
            ____joint_canCollide_10, -- 997
            joint.bodyA.current, -- 998
            joint.bodyB.current, -- 999
            joint.anchorA or dora.Vec2.zero, -- 1000
            joint.anchorB or dora.Vec2.zero, -- 1001
            joint.frequency or 0, -- 1002
            joint.damping or 0 -- 1003
        ) -- 1003
    end, -- 982
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 1005
        local joint = enode.props -- 1006
        if joint.ref == nil then -- 1006
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1008
            return -- 1009
        end -- 1009
        if joint.bodyA.current == nil then -- 1009
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1012
            return -- 1013
        end -- 1013
        if joint.bodyB.current == nil then -- 1013
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1016
            return -- 1017
        end -- 1017
        local ____joint_ref_17 = joint.ref -- 1019
        local ____self_15 = dora.Joint -- 1019
        local ____self_15_friction_16 = ____self_15.friction -- 1019
        local ____joint_canCollide_14 = joint.canCollide -- 1020
        if ____joint_canCollide_14 == nil then -- 1020
            ____joint_canCollide_14 = false -- 1020
        end -- 1020
        ____joint_ref_17.current = ____self_15_friction_16( -- 1019
            ____self_15, -- 1019
            ____joint_canCollide_14, -- 1020
            joint.bodyA.current, -- 1021
            joint.bodyB.current, -- 1022
            joint.worldPos, -- 1023
            joint.maxForce, -- 1024
            joint.maxTorque -- 1025
        ) -- 1025
    end, -- 1005
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 1028
        local joint = enode.props -- 1029
        if joint.ref == nil then -- 1029
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1031
            return -- 1032
        end -- 1032
        if joint.jointA.current == nil then -- 1032
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1035
            return -- 1036
        end -- 1036
        if joint.jointB.current == nil then -- 1036
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1039
            return -- 1040
        end -- 1040
        local ____joint_ref_21 = joint.ref -- 1042
        local ____self_19 = dora.Joint -- 1042
        local ____self_19_gear_20 = ____self_19.gear -- 1042
        local ____joint_canCollide_18 = joint.canCollide -- 1043
        if ____joint_canCollide_18 == nil then -- 1043
            ____joint_canCollide_18 = false -- 1043
        end -- 1043
        ____joint_ref_21.current = ____self_19_gear_20( -- 1042
            ____self_19, -- 1042
            ____joint_canCollide_18, -- 1043
            joint.jointA.current, -- 1044
            joint.jointB.current, -- 1045
            joint.ratio or 1 -- 1046
        ) -- 1046
    end, -- 1028
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 1049
        local joint = enode.props -- 1050
        if joint.ref == nil then -- 1050
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1052
            return -- 1053
        end -- 1053
        if joint.bodyA.current == nil then -- 1053
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1056
            return -- 1057
        end -- 1057
        if joint.bodyB.current == nil then -- 1057
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1060
            return -- 1061
        end -- 1061
        local ____joint_ref_25 = joint.ref -- 1063
        local ____self_23 = dora.Joint -- 1063
        local ____self_23_spring_24 = ____self_23.spring -- 1063
        local ____joint_canCollide_22 = joint.canCollide -- 1064
        if ____joint_canCollide_22 == nil then -- 1064
            ____joint_canCollide_22 = false -- 1064
        end -- 1064
        ____joint_ref_25.current = ____self_23_spring_24( -- 1063
            ____self_23, -- 1063
            ____joint_canCollide_22, -- 1064
            joint.bodyA.current, -- 1065
            joint.bodyB.current, -- 1066
            joint.linearOffset, -- 1067
            joint.angularOffset, -- 1068
            joint.maxForce, -- 1069
            joint.maxTorque, -- 1070
            joint.correctionFactor or 1 -- 1071
        ) -- 1071
    end, -- 1049
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1074
        local joint = enode.props -- 1075
        if joint.ref == nil then -- 1075
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1077
            return -- 1078
        end -- 1078
        if joint.body.current == nil then -- 1078
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1081
            return -- 1082
        end -- 1082
        local ____joint_ref_29 = joint.ref -- 1084
        local ____self_27 = dora.Joint -- 1084
        local ____self_27_move_28 = ____self_27.move -- 1084
        local ____joint_canCollide_26 = joint.canCollide -- 1085
        if ____joint_canCollide_26 == nil then -- 1085
            ____joint_canCollide_26 = false -- 1085
        end -- 1085
        ____joint_ref_29.current = ____self_27_move_28( -- 1084
            ____self_27, -- 1084
            ____joint_canCollide_26, -- 1085
            joint.body.current, -- 1086
            joint.targetPos, -- 1087
            joint.maxForce, -- 1088
            joint.frequency, -- 1089
            joint.damping or 0.7 -- 1090
        ) -- 1090
    end, -- 1074
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1093
        local joint = enode.props -- 1094
        if joint.ref == nil then -- 1094
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1096
            return -- 1097
        end -- 1097
        if joint.bodyA.current == nil then -- 1097
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1100
            return -- 1101
        end -- 1101
        if joint.bodyB.current == nil then -- 1101
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1104
            return -- 1105
        end -- 1105
        local ____joint_ref_33 = joint.ref -- 1107
        local ____self_31 = dora.Joint -- 1107
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1107
        local ____joint_canCollide_30 = joint.canCollide -- 1108
        if ____joint_canCollide_30 == nil then -- 1108
            ____joint_canCollide_30 = false -- 1108
        end -- 1108
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1107
            ____self_31, -- 1107
            ____joint_canCollide_30, -- 1108
            joint.bodyA.current, -- 1109
            joint.bodyB.current, -- 1110
            joint.worldPos, -- 1111
            joint.axisAngle, -- 1112
            joint.lowerTranslation or 0, -- 1113
            joint.upperTranslation or 0, -- 1114
            joint.maxMotorForce or 0, -- 1115
            joint.motorSpeed or 0 -- 1116
        ) -- 1116
    end, -- 1093
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1119
        local joint = enode.props -- 1120
        if joint.ref == nil then -- 1120
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1122
            return -- 1123
        end -- 1123
        if joint.bodyA.current == nil then -- 1123
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1126
            return -- 1127
        end -- 1127
        if joint.bodyB.current == nil then -- 1127
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1130
            return -- 1131
        end -- 1131
        local ____joint_ref_37 = joint.ref -- 1133
        local ____self_35 = dora.Joint -- 1133
        local ____self_35_pulley_36 = ____self_35.pulley -- 1133
        local ____joint_canCollide_34 = joint.canCollide -- 1134
        if ____joint_canCollide_34 == nil then -- 1134
            ____joint_canCollide_34 = false -- 1134
        end -- 1134
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1133
            ____self_35, -- 1133
            ____joint_canCollide_34, -- 1134
            joint.bodyA.current, -- 1135
            joint.bodyB.current, -- 1136
            joint.anchorA or dora.Vec2.zero, -- 1137
            joint.anchorB or dora.Vec2.zero, -- 1138
            joint.groundAnchorA, -- 1139
            joint.groundAnchorB, -- 1140
            joint.ratio or 1 -- 1141
        ) -- 1141
    end, -- 1119
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1144
        local joint = enode.props -- 1145
        if joint.ref == nil then -- 1145
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1147
            return -- 1148
        end -- 1148
        if joint.bodyA.current == nil then -- 1148
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1151
            return -- 1152
        end -- 1152
        if joint.bodyB.current == nil then -- 1152
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1155
            return -- 1156
        end -- 1156
        local ____joint_ref_41 = joint.ref -- 1158
        local ____self_39 = dora.Joint -- 1158
        local ____self_39_revolute_40 = ____self_39.revolute -- 1158
        local ____joint_canCollide_38 = joint.canCollide -- 1159
        if ____joint_canCollide_38 == nil then -- 1159
            ____joint_canCollide_38 = false -- 1159
        end -- 1159
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1158
            ____self_39, -- 1158
            ____joint_canCollide_38, -- 1159
            joint.bodyA.current, -- 1160
            joint.bodyB.current, -- 1161
            joint.worldPos, -- 1162
            joint.lowerAngle or 0, -- 1163
            joint.upperAngle or 0, -- 1164
            joint.maxMotorTorque or 0, -- 1165
            joint.motorSpeed or 0 -- 1166
        ) -- 1166
    end, -- 1144
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1169
        local joint = enode.props -- 1170
        if joint.ref == nil then -- 1170
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1172
            return -- 1173
        end -- 1173
        if joint.bodyA.current == nil then -- 1173
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1176
            return -- 1177
        end -- 1177
        if joint.bodyB.current == nil then -- 1177
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1180
            return -- 1181
        end -- 1181
        local ____joint_ref_45 = joint.ref -- 1183
        local ____self_43 = dora.Joint -- 1183
        local ____self_43_rope_44 = ____self_43.rope -- 1183
        local ____joint_canCollide_42 = joint.canCollide -- 1184
        if ____joint_canCollide_42 == nil then -- 1184
            ____joint_canCollide_42 = false -- 1184
        end -- 1184
        ____joint_ref_45.current = ____self_43_rope_44( -- 1183
            ____self_43, -- 1183
            ____joint_canCollide_42, -- 1184
            joint.bodyA.current, -- 1185
            joint.bodyB.current, -- 1186
            joint.anchorA or dora.Vec2.zero, -- 1187
            joint.anchorB or dora.Vec2.zero, -- 1188
            joint.maxLength or 0 -- 1189
        ) -- 1189
    end, -- 1169
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1192
        local joint = enode.props -- 1193
        if joint.ref == nil then -- 1193
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1195
            return -- 1196
        end -- 1196
        if joint.bodyA.current == nil then -- 1196
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1199
            return -- 1200
        end -- 1200
        if joint.bodyB.current == nil then -- 1200
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1203
            return -- 1204
        end -- 1204
        local ____joint_ref_49 = joint.ref -- 1206
        local ____self_47 = dora.Joint -- 1206
        local ____self_47_weld_48 = ____self_47.weld -- 1206
        local ____joint_canCollide_46 = joint.canCollide -- 1207
        if ____joint_canCollide_46 == nil then -- 1207
            ____joint_canCollide_46 = false -- 1207
        end -- 1207
        ____joint_ref_49.current = ____self_47_weld_48( -- 1206
            ____self_47, -- 1206
            ____joint_canCollide_46, -- 1207
            joint.bodyA.current, -- 1208
            joint.bodyB.current, -- 1209
            joint.worldPos, -- 1210
            joint.frequency or 0, -- 1211
            joint.damping or 0 -- 1212
        ) -- 1212
    end, -- 1192
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1215
        local joint = enode.props -- 1216
        if joint.ref == nil then -- 1216
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1218
            return -- 1219
        end -- 1219
        if joint.bodyA.current == nil then -- 1219
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1222
            return -- 1223
        end -- 1223
        if joint.bodyB.current == nil then -- 1223
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1226
            return -- 1227
        end -- 1227
        local ____joint_ref_53 = joint.ref -- 1229
        local ____self_51 = dora.Joint -- 1229
        local ____self_51_wheel_52 = ____self_51.wheel -- 1229
        local ____joint_canCollide_50 = joint.canCollide -- 1230
        if ____joint_canCollide_50 == nil then -- 1230
            ____joint_canCollide_50 = false -- 1230
        end -- 1230
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1229
            ____self_51, -- 1229
            ____joint_canCollide_50, -- 1230
            joint.bodyA.current, -- 1231
            joint.bodyB.current, -- 1232
            joint.worldPos, -- 1233
            joint.axisAngle, -- 1234
            joint.maxMotorTorque or 0, -- 1235
            joint.motorSpeed or 0, -- 1236
            joint.frequency or 0, -- 1237
            joint.damping or 0.7 -- 1238
        ) -- 1238
    end, -- 1215
    ["custom-node"] = function(nodeStack, enode, parent) -- 1241
        local node = getCustomNode(enode) -- 1242
        if node ~= nil then -- 1242
            addChild(nodeStack, node, enode) -- 1244
        end -- 1244
    end, -- 1241
    ["custom-element"] = function() -- 1247
    end -- 1247
} -- 1247
function ____exports.useRef(item) -- 1290
    local ____item_54 = item -- 1291
    if ____item_54 == nil then -- 1291
        ____item_54 = nil -- 1291
    end -- 1291
    return {current = ____item_54} -- 1291
end -- 1290
local function getPreload(preloadList, node) -- 1294
    if type(node) ~= "table" then -- 1294
        return -- 1296
    end -- 1296
    local enode = node -- 1298
    if enode.type == nil then -- 1298
        local list = node -- 1300
        if #list > 0 then -- 1300
            for i = 1, #list do -- 1300
                getPreload(preloadList, list[i]) -- 1303
            end -- 1303
        end -- 1303
    else -- 1303
        repeat -- 1303
            local ____switch282 = enode.type -- 1303
            local sprite, playable, model, spine, dragonBone, label -- 1303
            local ____cond282 = ____switch282 == "sprite" -- 1303
            if ____cond282 then -- 1303
                sprite = enode.props -- 1309
                preloadList[#preloadList + 1] = sprite.file -- 1310
                break -- 1311
            end -- 1311
            ____cond282 = ____cond282 or ____switch282 == "playable" -- 1311
            if ____cond282 then -- 1311
                playable = enode.props -- 1313
                preloadList[#preloadList + 1] = playable.file -- 1314
                break -- 1315
            end -- 1315
            ____cond282 = ____cond282 or ____switch282 == "model" -- 1315
            if ____cond282 then -- 1315
                model = enode.props -- 1317
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1318
                break -- 1319
            end -- 1319
            ____cond282 = ____cond282 or ____switch282 == "spine" -- 1319
            if ____cond282 then -- 1319
                spine = enode.props -- 1321
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1322
                break -- 1323
            end -- 1323
            ____cond282 = ____cond282 or ____switch282 == "dragon-bone" -- 1323
            if ____cond282 then -- 1323
                dragonBone = enode.props -- 1325
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1326
                break -- 1327
            end -- 1327
            ____cond282 = ____cond282 or ____switch282 == "label" -- 1327
            if ____cond282 then -- 1327
                label = enode.props -- 1329
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1330
                break -- 1331
            end -- 1331
        until true -- 1331
    end -- 1331
    getPreload(preloadList, enode.children) -- 1334
end -- 1294
function ____exports.preloadAsync(enode, handler) -- 1337
    local preloadList = {} -- 1338
    getPreload(preloadList, enode) -- 1339
    dora.Cache:loadAsync(preloadList, handler) -- 1340
end -- 1337
return ____exports -- 1337