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
local Warn, visitNode, elementMap -- 1
local dora = require("dora") -- 10
function Warn(msg) -- 12
    print("[Dora Warning] " .. msg) -- 13
end -- 13
function visitNode(nodeStack, node, parent) -- 1192
    if type(node) ~= "table" then -- 1192
        return -- 1194
    end -- 1194
    local enode = node -- 1196
    if enode.type == nil then -- 1196
        local list = node -- 1198
        if #list > 0 then -- 1198
            for i = 1, #list do -- 1198
                local stack = {} -- 1201
                visitNode(stack, list[i], parent) -- 1202
                for i = 1, #stack do -- 1202
                    nodeStack[#nodeStack + 1] = stack[i] -- 1204
                end -- 1204
            end -- 1204
        end -- 1204
    else -- 1204
        local handler = elementMap[enode.type] -- 1209
        if handler ~= nil then -- 1209
            handler(nodeStack, enode, parent) -- 1211
        else -- 1211
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1213
        end -- 1213
    end -- 1213
end -- 1213
function ____exports.toNode(enode) -- 1218
    local nodeStack = {} -- 1219
    visitNode(nodeStack, enode) -- 1220
    if #nodeStack == 1 then -- 1220
        return nodeStack[1] -- 1222
    elseif #nodeStack > 1 then -- 1222
        local node = dora.Node() -- 1224
        for i = 1, #nodeStack do -- 1224
            node:addChild(nodeStack[i]) -- 1226
        end -- 1226
        return node -- 1228
    end -- 1228
    return nil -- 1230
end -- 1218
____exports.React = {} -- 1218
local React = ____exports.React -- 1218
do -- 1218
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
                                dora.Vec2(dot.x, dot.y), -- 312
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
                    ____cond69 = ____cond69 or ____switch69 == "polygon-shape" -- 326
                    if ____cond69 then -- 326
                        do -- 326
                            local poly = child.props -- 329
                            node:drawPolygon( -- 330
                                poly.verts, -- 331
                                dora.Color(poly.fillColor or 4294967295), -- 332
                                poly.borderWidth or 0, -- 333
                                dora.Color(poly.borderColor or 4294967295) -- 334
                            ) -- 334
                            break -- 336
                        end -- 336
                    end -- 336
                    ____cond69 = ____cond69 or ____switch69 == "verts-shape" -- 336
                    if ____cond69 then -- 336
                        do -- 336
                            local verts = child.props -- 339
                            node:drawVertices(__TS__ArrayMap( -- 340
                                verts.verts, -- 340
                                function(____, ____bindingPattern0) -- 340
                                    local color -- 340
                                    local vert -- 340
                                    vert = ____bindingPattern0[1] -- 340
                                    color = ____bindingPattern0[2] -- 340
                                    return { -- 340
                                        vert, -- 340
                                        dora.Color(color) -- 340
                                    } -- 340
                                end -- 340
                            )) -- 340
                            break -- 341
                        end -- 341
                    end -- 341
                until true -- 341
            end -- 341
            ::__continue67:: -- 341
        end -- 341
        return cnode -- 345
    end -- 299
end -- 299
local getGrid -- 349
do -- 349
    local function handleGridAttribute(cnode, _enode, k, v) -- 351
        repeat -- 351
            local ____switch77 = k -- 351
            local ____cond77 = ____switch77 == "file" or ____switch77 == "gridX" or ____switch77 == "gridY" -- 351
            if ____cond77 then -- 351
                return true -- 353
            end -- 353
            ____cond77 = ____cond77 or ____switch77 == "textureRect" -- 353
            if ____cond77 then -- 353
                cnode.textureRect = v -- 354
                return true -- 354
            end -- 354
            ____cond77 = ____cond77 or ____switch77 == "depthWrite" -- 354
            if ____cond77 then -- 354
                cnode.depthWrite = v -- 355
                return true -- 355
            end -- 355
            ____cond77 = ____cond77 or ____switch77 == "blendFunc" -- 355
            if ____cond77 then -- 355
                cnode.blendFunc = v -- 356
                return true -- 356
            end -- 356
            ____cond77 = ____cond77 or ____switch77 == "effect" -- 356
            if ____cond77 then -- 356
                cnode.effect = v -- 357
                return true -- 357
            end -- 357
        until true -- 357
        return false -- 359
    end -- 351
    getGrid = function(enode) -- 361
        local grid = enode.props -- 362
        local node = dora.Grid(grid.file, grid.gridX, grid.gridY) -- 363
        local cnode = getNode(enode, node, handleGridAttribute) -- 364
        return cnode -- 365
    end -- 361
end -- 361
local getSprite -- 369
do -- 369
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 371
        repeat -- 371
            local ____switch81 = k -- 371
            local ____cond81 = ____switch81 == "file" -- 371
            if ____cond81 then -- 371
                return true -- 373
            end -- 373
            ____cond81 = ____cond81 or ____switch81 == "textureRect" -- 373
            if ____cond81 then -- 373
                cnode.textureRect = v -- 374
                return true -- 374
            end -- 374
            ____cond81 = ____cond81 or ____switch81 == "depthWrite" -- 374
            if ____cond81 then -- 374
                cnode.depthWrite = v -- 375
                return true -- 375
            end -- 375
            ____cond81 = ____cond81 or ____switch81 == "blendFunc" -- 375
            if ____cond81 then -- 375
                cnode.blendFunc = v -- 376
                return true -- 376
            end -- 376
            ____cond81 = ____cond81 or ____switch81 == "effect" -- 376
            if ____cond81 then -- 376
                cnode.effect = v -- 377
                return true -- 377
            end -- 377
            ____cond81 = ____cond81 or ____switch81 == "alphaRef" -- 377
            if ____cond81 then -- 377
                cnode.alphaRef = v -- 378
                return true -- 378
            end -- 378
            ____cond81 = ____cond81 or ____switch81 == "uwrap" -- 378
            if ____cond81 then -- 378
                cnode.uwrap = v -- 379
                return true -- 379
            end -- 379
            ____cond81 = ____cond81 or ____switch81 == "vwrap" -- 379
            if ____cond81 then -- 379
                cnode.vwrap = v -- 380
                return true -- 380
            end -- 380
            ____cond81 = ____cond81 or ____switch81 == "filter" -- 380
            if ____cond81 then -- 380
                cnode.filter = v -- 381
                return true -- 381
            end -- 381
        until true -- 381
        return false -- 383
    end -- 371
    getSprite = function(enode) -- 385
        local sp = enode.props -- 386
        local node = dora.Sprite(sp.file) -- 387
        if node ~= nil then -- 387
            local cnode = getNode(enode, node, handleSpriteAttribute) -- 389
            return cnode -- 390
        end -- 390
        return nil -- 392
    end -- 385
end -- 385
local getLabel -- 396
do -- 396
    local function handleLabelAttribute(cnode, _enode, k, v) -- 398
        repeat -- 398
            local ____switch86 = k -- 398
            local ____cond86 = ____switch86 == "fontName" or ____switch86 == "fontSize" or ____switch86 == "text" -- 398
            if ____cond86 then -- 398
                return true -- 400
            end -- 400
            ____cond86 = ____cond86 or ____switch86 == "alphaRef" -- 400
            if ____cond86 then -- 400
                cnode.alphaRef = v -- 401
                return true -- 401
            end -- 401
            ____cond86 = ____cond86 or ____switch86 == "textWidth" -- 401
            if ____cond86 then -- 401
                cnode.textWidth = v -- 402
                return true -- 402
            end -- 402
            ____cond86 = ____cond86 or ____switch86 == "lineGap" -- 402
            if ____cond86 then -- 402
                cnode.lineGap = v -- 403
                return true -- 403
            end -- 403
            ____cond86 = ____cond86 or ____switch86 == "spacing" -- 403
            if ____cond86 then -- 403
                cnode.spacing = v -- 404
                return true -- 404
            end -- 404
            ____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 404
            if ____cond86 then -- 404
                cnode.blendFunc = v -- 405
                return true -- 405
            end -- 405
            ____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 405
            if ____cond86 then -- 405
                cnode.depthWrite = v -- 406
                return true -- 406
            end -- 406
            ____cond86 = ____cond86 or ____switch86 == "batched" -- 406
            if ____cond86 then -- 406
                cnode.batched = v -- 407
                return true -- 407
            end -- 407
            ____cond86 = ____cond86 or ____switch86 == "effect" -- 407
            if ____cond86 then -- 407
                cnode.effect = v -- 408
                return true -- 408
            end -- 408
            ____cond86 = ____cond86 or ____switch86 == "alignment" -- 408
            if ____cond86 then -- 408
                cnode.alignment = v -- 409
                return true -- 409
            end -- 409
        until true -- 409
        return false -- 411
    end -- 398
    getLabel = function(enode) -- 413
        local label = enode.props -- 414
        local node = dora.Label(label.fontName, label.fontSize) -- 415
        if node ~= nil then -- 415
            local cnode = getNode(enode, node, handleLabelAttribute) -- 417
            local ____enode_8 = enode -- 418
            local children = ____enode_8.children -- 418
            local text = label.text or "" -- 419
            for i = 1, #children do -- 419
                local child = children[i] -- 421
                if type(child) ~= "table" then -- 421
                    text = text .. tostring(child) -- 423
                end -- 423
            end -- 423
            node.text = text -- 426
            return cnode -- 427
        end -- 427
        return nil -- 429
    end -- 413
end -- 413
local getLine -- 433
do -- 433
    local function handleLineAttribute(cnode, enode, k, v) -- 435
        local line = enode.props -- 436
        repeat -- 436
            local ____switch93 = k -- 436
            local ____cond93 = ____switch93 == "verts" -- 436
            if ____cond93 then -- 436
                cnode:set( -- 438
                    v, -- 438
                    dora.Color(line.lineColor or 4294967295) -- 438
                ) -- 438
                return true -- 438
            end -- 438
            ____cond93 = ____cond93 or ____switch93 == "depthWrite" -- 438
            if ____cond93 then -- 438
                cnode.depthWrite = v -- 439
                return true -- 439
            end -- 439
            ____cond93 = ____cond93 or ____switch93 == "blendFunc" -- 439
            if ____cond93 then -- 439
                cnode.blendFunc = v -- 440
                return true -- 440
            end -- 440
        until true -- 440
        return false -- 442
    end -- 435
    getLine = function(enode) -- 444
        local node = dora.Line() -- 445
        local cnode = getNode(enode, node, handleLineAttribute) -- 446
        return cnode -- 447
    end -- 444
end -- 444
local getParticle -- 451
do -- 451
    local function handleParticleAttribute(cnode, _enode, k, v) -- 453
        repeat -- 453
            local ____switch97 = k -- 453
            local ____cond97 = ____switch97 == "file" -- 453
            if ____cond97 then -- 453
                return true -- 455
            end -- 455
            ____cond97 = ____cond97 or ____switch97 == "emit" -- 455
            if ____cond97 then -- 455
                if v then -- 455
                    cnode:start() -- 456
                end -- 456
                return true -- 456
            end -- 456
            ____cond97 = ____cond97 or ____switch97 == "onFinished" -- 456
            if ____cond97 then -- 456
                cnode:slot("Finished", v) -- 457
                return true -- 457
            end -- 457
        until true -- 457
        return false -- 459
    end -- 453
    getParticle = function(enode) -- 461
        local particle = enode.props -- 462
        local node = dora.Particle(particle.file) -- 463
        if node ~= nil then -- 463
            local cnode = getNode(enode, node, handleParticleAttribute) -- 465
            return cnode -- 466
        end -- 466
        return nil -- 468
    end -- 461
end -- 461
local getMenu -- 472
do -- 472
    local function handleMenuAttribute(cnode, _enode, k, v) -- 474
        repeat -- 474
            local ____switch103 = k -- 474
            local ____cond103 = ____switch103 == "enabled" -- 474
            if ____cond103 then -- 474
                cnode.enabled = v -- 476
                return true -- 476
            end -- 476
        until true -- 476
        return false -- 478
    end -- 474
    getMenu = function(enode) -- 480
        local node = dora.Menu() -- 481
        local cnode = getNode(enode, node, handleMenuAttribute) -- 482
        return cnode -- 483
    end -- 480
end -- 480
local getPhysicsWorld -- 487
do -- 487
    local function handlePhysicsWorldAttribute(cnode, _enode, k, v) -- 489
        repeat -- 489
            local ____switch107 = k -- 489
            local ____cond107 = ____switch107 == "showDebug" -- 489
            if ____cond107 then -- 489
                cnode.showDebug = v -- 491
                return true -- 491
            end -- 491
        until true -- 491
        return false -- 493
    end -- 489
    getPhysicsWorld = function(enode) -- 495
        local node = dora.PhysicsWorld() -- 496
        local cnode = getNode(enode, node, handlePhysicsWorldAttribute) -- 497
        return cnode -- 498
    end -- 495
end -- 495
local getBody -- 502
do -- 502
    local function handleBodyAttribute(cnode, _enode, k, v) -- 504
        repeat -- 504
            local ____switch111 = k -- 504
            local ____cond111 = ____switch111 == "type" or ____switch111 == "linearAcceleration" or ____switch111 == "fixedRotation" or ____switch111 == "bullet" or ____switch111 == "world" -- 504
            if ____cond111 then -- 504
                return true -- 511
            end -- 511
            ____cond111 = ____cond111 or ____switch111 == "velocityX" -- 511
            if ____cond111 then -- 511
                cnode.velocityX = v -- 512
                return true -- 512
            end -- 512
            ____cond111 = ____cond111 or ____switch111 == "velocityY" -- 512
            if ____cond111 then -- 512
                cnode.velocityY = v -- 513
                return true -- 513
            end -- 513
            ____cond111 = ____cond111 or ____switch111 == "angularRate" -- 513
            if ____cond111 then -- 513
                cnode.angularRate = v -- 514
                return true -- 514
            end -- 514
            ____cond111 = ____cond111 or ____switch111 == "group" -- 514
            if ____cond111 then -- 514
                cnode.group = v -- 515
                return true -- 515
            end -- 515
            ____cond111 = ____cond111 or ____switch111 == "linearDamping" -- 515
            if ____cond111 then -- 515
                cnode.linearDamping = v -- 516
                return true -- 516
            end -- 516
            ____cond111 = ____cond111 or ____switch111 == "angularDamping" -- 516
            if ____cond111 then -- 516
                cnode.angularDamping = v -- 517
                return true -- 517
            end -- 517
            ____cond111 = ____cond111 or ____switch111 == "owner" -- 517
            if ____cond111 then -- 517
                cnode.owner = v -- 518
                return true -- 518
            end -- 518
            ____cond111 = ____cond111 or ____switch111 == "receivingContact" -- 518
            if ____cond111 then -- 518
                cnode.receivingContact = v -- 519
                return true -- 519
            end -- 519
            ____cond111 = ____cond111 or ____switch111 == "onBodyEnter" -- 519
            if ____cond111 then -- 519
                cnode:slot("BodyEnter", v) -- 520
                return true -- 520
            end -- 520
            ____cond111 = ____cond111 or ____switch111 == "onBodyLeave" -- 520
            if ____cond111 then -- 520
                cnode:slot("BodyLeave", v) -- 521
                return true -- 521
            end -- 521
            ____cond111 = ____cond111 or ____switch111 == "onContactStart" -- 521
            if ____cond111 then -- 521
                cnode:slot("ContactStart", v) -- 522
                return true -- 522
            end -- 522
            ____cond111 = ____cond111 or ____switch111 == "onContactEnd" -- 522
            if ____cond111 then -- 522
                cnode:slot("ContactEnd", v) -- 523
                return true -- 523
            end -- 523
            ____cond111 = ____cond111 or ____switch111 == "onContactFilter" -- 523
            if ____cond111 then -- 523
                cnode:onContactFilter(v) -- 524
                return true -- 524
            end -- 524
        until true -- 524
        return false -- 526
    end -- 504
    getBody = function(enode, world) -- 528
        local def = enode.props -- 529
        local bodyDef = dora.BodyDef() -- 530
        bodyDef.type = def.type -- 531
        if def.angle ~= nil then -- 531
            bodyDef.angle = def.angle -- 532
        end -- 532
        if def.angularDamping ~= nil then -- 532
            bodyDef.angularDamping = def.angularDamping -- 533
        end -- 533
        if def.bullet ~= nil then -- 533
            bodyDef.bullet = def.bullet -- 534
        end -- 534
        if def.fixedRotation ~= nil then -- 534
            bodyDef.fixedRotation = def.fixedRotation -- 535
        end -- 535
        if def.linearAcceleration ~= nil then -- 535
            bodyDef.linearAcceleration = def.linearAcceleration -- 536
        end -- 536
        if def.linearDamping ~= nil then -- 536
            bodyDef.linearDamping = def.linearDamping -- 537
        end -- 537
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 538
        local extraSensors = nil -- 539
        for i = 1, #enode.children do -- 539
            do -- 539
                local child = enode.children[i] -- 541
                if type(child) ~= "table" then -- 541
                    goto __continue119 -- 543
                end -- 543
                repeat -- 543
                    local ____switch121 = child.type -- 543
                    local ____cond121 = ____switch121 == "rect-fixture" -- 543
                    if ____cond121 then -- 543
                        do -- 543
                            local shape = child.props -- 547
                            if shape.sensorTag ~= nil then -- 547
                                bodyDef:attachPolygonSensor( -- 549
                                    shape.sensorTag, -- 550
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 551
                                    shape.width, -- 552
                                    shape.height, -- 552
                                    shape.angle or 0 -- 553
                                ) -- 553
                            else -- 553
                                bodyDef:attachPolygon( -- 556
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 557
                                    shape.width, -- 558
                                    shape.height, -- 558
                                    shape.angle or 0, -- 559
                                    shape.density or 0, -- 560
                                    shape.friction or 0.4, -- 561
                                    shape.restitution or 0 -- 562
                                ) -- 562
                            end -- 562
                            break -- 565
                        end -- 565
                    end -- 565
                    ____cond121 = ____cond121 or ____switch121 == "polygon-fixture" -- 565
                    if ____cond121 then -- 565
                        do -- 565
                            local shape = child.props -- 568
                            if shape.sensorTag ~= nil then -- 568
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 570
                            else -- 570
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 575
                            end -- 575
                            break -- 582
                        end -- 582
                    end -- 582
                    ____cond121 = ____cond121 or ____switch121 == "multi-fixture" -- 582
                    if ____cond121 then -- 582
                        do -- 582
                            local shape = child.props -- 585
                            if shape.sensorTag ~= nil then -- 585
                                if extraSensors == nil then -- 585
                                    extraSensors = {} -- 587
                                end -- 587
                                extraSensors[#extraSensors + 1] = { -- 588
                                    shape.sensorTag, -- 588
                                    dora.BodyDef:multi(shape.verts) -- 588
                                } -- 588
                            else -- 588
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 590
                            end -- 590
                            break -- 597
                        end -- 597
                    end -- 597
                    ____cond121 = ____cond121 or ____switch121 == "disk-fixture" -- 597
                    if ____cond121 then -- 597
                        do -- 597
                            local shape = child.props -- 600
                            if shape.sensorTag ~= nil then -- 600
                                bodyDef:attachDiskSensor( -- 602
                                    shape.sensorTag, -- 603
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 604
                                    shape.radius -- 605
                                ) -- 605
                            else -- 605
                                bodyDef:attachDisk( -- 608
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 609
                                    shape.radius, -- 610
                                    shape.density or 0, -- 611
                                    shape.friction or 0.4, -- 612
                                    shape.restitution or 0 -- 613
                                ) -- 613
                            end -- 613
                            break -- 616
                        end -- 616
                    end -- 616
                    ____cond121 = ____cond121 or ____switch121 == "chain-fixture" -- 616
                    if ____cond121 then -- 616
                        do -- 616
                            local shape = child.props -- 619
                            if shape.sensorTag ~= nil then -- 619
                                if extraSensors == nil then -- 619
                                    extraSensors = {} -- 621
                                end -- 621
                                extraSensors[#extraSensors + 1] = { -- 622
                                    shape.sensorTag, -- 622
                                    dora.BodyDef:chain(shape.verts) -- 622
                                } -- 622
                            else -- 622
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 624
                            end -- 624
                            break -- 630
                        end -- 630
                    end -- 630
                until true -- 630
            end -- 630
            ::__continue119:: -- 630
        end -- 630
        local body = dora.Body(bodyDef, world) -- 634
        if extraSensors ~= nil then -- 634
            for i = 1, #extraSensors do -- 634
                local tag, def = table.unpack(extraSensors[i]) -- 637
                body:attachSensor(tag, def) -- 638
            end -- 638
        end -- 638
        local cnode = getNode(enode, body, handleBodyAttribute) -- 641
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 641
            body.receivingContact = true -- 648
        end -- 648
        return cnode -- 650
    end -- 528
end -- 528
local getCustomNode -- 654
do -- 654
    local function handleCustomNode(_cnode, _enode, k, _v) -- 656
        repeat -- 656
            local ____switch142 = k -- 656
            local ____cond142 = ____switch142 == "onCreate" -- 656
            if ____cond142 then -- 656
                return true -- 658
            end -- 658
        until true -- 658
        return false -- 660
    end -- 656
    getCustomNode = function(enode) -- 662
        local custom = enode.props -- 663
        local node = custom.onCreate() -- 664
        if node then -- 664
            local cnode = getNode(enode, node, handleCustomNode) -- 666
            return cnode -- 667
        end -- 667
        return nil -- 669
    end -- 662
end -- 662
local function addChild(nodeStack, cnode, enode) -- 673
    if #nodeStack > 0 then -- 673
        local last = nodeStack[#nodeStack] -- 675
        last:addChild(cnode) -- 676
    end -- 676
    nodeStack[#nodeStack + 1] = cnode -- 678
    local ____enode_9 = enode -- 679
    local children = ____enode_9.children -- 679
    for i = 1, #children do -- 679
        visitNode(nodeStack, children[i], enode) -- 681
    end -- 681
    if #nodeStack > 1 then -- 681
        table.remove(nodeStack) -- 684
    end -- 684
end -- 673
local function drawNodeCheck(_nodeStack, enode, parent) -- 692
    if parent == nil or parent.type ~= "draw-node" then -- 692
        Warn(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 694
    end -- 694
end -- 692
local function actionCheck(_nodeStack, enode, parent) -- 698
    local unsupported = false -- 699
    if parent == nil then -- 699
        unsupported = true -- 701
    else -- 701
        repeat -- 701
            local ____switch154 = enode.type -- 701
            local ____cond154 = ____switch154 == "action" or ____switch154 == "spawn" or ____switch154 == "sequence" -- 701
            if ____cond154 then -- 701
                break -- 704
            end -- 704
            do -- 704
                unsupported = true -- 705
                break -- 705
            end -- 705
        until true -- 705
    end -- 705
    if unsupported then -- 705
        Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 709
    end -- 709
end -- 698
local function bodyCheck(_nodeStack, enode, parent) -- 713
    if parent == nil or parent.type ~= "body" then -- 713
        Warn(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 715
    end -- 715
end -- 713
local actionMap = { -- 719
    ["anchor-x"] = dora.AnchorX, -- 722
    ["anchor-y"] = dora.AnchorY, -- 723
    angle = dora.Angle, -- 724
    ["angle-x"] = dora.AngleX, -- 725
    ["angle-y"] = dora.AngleY, -- 726
    width = dora.Width, -- 727
    height = dora.Height, -- 728
    opacity = dora.Opacity, -- 729
    roll = dora.Roll, -- 730
    scale = dora.Scale, -- 731
    ["scale-x"] = dora.ScaleX, -- 732
    ["scale-y"] = dora.ScaleY, -- 733
    ["skew-x"] = dora.SkewX, -- 734
    ["skew-y"] = dora.SkewY, -- 735
    ["move-x"] = dora.X, -- 736
    ["move-y"] = dora.Y, -- 737
    ["move-z"] = dora.Z -- 738
} -- 738
elementMap = { -- 741
    node = function(nodeStack, enode, parent) -- 742
        addChild( -- 743
            nodeStack, -- 743
            getNode(enode), -- 743
            enode -- 743
        ) -- 743
    end, -- 742
    ["clip-node"] = function(nodeStack, enode, parent) -- 745
        addChild( -- 746
            nodeStack, -- 746
            getClipNode(enode), -- 746
            enode -- 746
        ) -- 746
    end, -- 745
    playable = function(nodeStack, enode, parent) -- 748
        local cnode = getPlayable(enode) -- 749
        if cnode ~= nil then -- 749
            addChild(nodeStack, cnode, enode) -- 751
        end -- 751
    end, -- 748
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 754
        local cnode = getDragonBone(enode) -- 755
        if cnode ~= nil then -- 755
            addChild(nodeStack, cnode, enode) -- 757
        end -- 757
    end, -- 754
    spine = function(nodeStack, enode, parent) -- 760
        local cnode = getSpine(enode) -- 761
        if cnode ~= nil then -- 761
            addChild(nodeStack, cnode, enode) -- 763
        end -- 763
    end, -- 760
    model = function(nodeStack, enode, parent) -- 766
        local cnode = getModel(enode) -- 767
        if cnode ~= nil then -- 767
            addChild(nodeStack, cnode, enode) -- 769
        end -- 769
    end, -- 766
    ["draw-node"] = function(nodeStack, enode, parent) -- 772
        addChild( -- 773
            nodeStack, -- 773
            getDrawNode(enode), -- 773
            enode -- 773
        ) -- 773
    end, -- 772
    ["dot-shape"] = drawNodeCheck, -- 775
    ["segment-shape"] = drawNodeCheck, -- 776
    ["polygon-shape"] = drawNodeCheck, -- 777
    ["verts-shape"] = drawNodeCheck, -- 778
    grid = function(nodeStack, enode, parent) -- 779
        addChild( -- 780
            nodeStack, -- 780
            getGrid(enode), -- 780
            enode -- 780
        ) -- 780
    end, -- 779
    sprite = function(nodeStack, enode, parent) -- 782
        local cnode = getSprite(enode) -- 783
        if cnode ~= nil then -- 783
            addChild(nodeStack, cnode, enode) -- 785
        end -- 785
    end, -- 782
    label = function(nodeStack, enode, parent) -- 788
        local cnode = getLabel(enode) -- 789
        if cnode ~= nil then -- 789
            addChild(nodeStack, cnode, enode) -- 791
        end -- 791
    end, -- 788
    line = function(nodeStack, enode, parent) -- 794
        addChild( -- 795
            nodeStack, -- 795
            getLine(enode), -- 795
            enode -- 795
        ) -- 795
    end, -- 794
    particle = function(nodeStack, enode, parent) -- 797
        local cnode = getParticle(enode) -- 798
        if cnode ~= nil then -- 798
            addChild(nodeStack, cnode, enode) -- 800
        end -- 800
    end, -- 797
    menu = function(nodeStack, enode, parent) -- 803
        addChild( -- 804
            nodeStack, -- 804
            getMenu(enode), -- 804
            enode -- 804
        ) -- 804
    end, -- 803
    action = function(_nodeStack, enode, parent) -- 806
        if #enode.children == 0 then -- 806
            return -- 807
        end -- 807
        local action = enode.props -- 808
        if action.ref == nil then -- 808
            return -- 809
        end -- 809
        local function visitAction(actionStack, enode) -- 810
            local createAction = actionMap[enode.type] -- 811
            if createAction ~= nil then -- 811
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 813
                return -- 814
            end -- 814
            repeat -- 814
                local ____switch183 = enode.type -- 814
                local ____cond183 = ____switch183 == "delay" -- 814
                if ____cond183 then -- 814
                    do -- 814
                        local item = enode.props -- 818
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 819
                        break -- 820
                    end -- 820
                end -- 820
                ____cond183 = ____cond183 or ____switch183 == "event" -- 820
                if ____cond183 then -- 820
                    do -- 820
                        local item = enode.props -- 823
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 824
                        break -- 825
                    end -- 825
                end -- 825
                ____cond183 = ____cond183 or ____switch183 == "hide" -- 825
                if ____cond183 then -- 825
                    do -- 825
                        actionStack[#actionStack + 1] = dora.Hide() -- 828
                        break -- 829
                    end -- 829
                end -- 829
                ____cond183 = ____cond183 or ____switch183 == "show" -- 829
                if ____cond183 then -- 829
                    do -- 829
                        actionStack[#actionStack + 1] = dora.Show() -- 832
                        break -- 833
                    end -- 833
                end -- 833
                ____cond183 = ____cond183 or ____switch183 == "move" -- 833
                if ____cond183 then -- 833
                    do -- 833
                        local item = enode.props -- 836
                        actionStack[#actionStack + 1] = dora.Move( -- 837
                            item.time, -- 837
                            dora.Vec2(item.startX, item.startY), -- 837
                            dora.Vec2(item.stopX, item.stopY), -- 837
                            item.easing -- 837
                        ) -- 837
                        break -- 838
                    end -- 838
                end -- 838
                ____cond183 = ____cond183 or ____switch183 == "spawn" -- 838
                if ____cond183 then -- 838
                    do -- 838
                        local spawnStack = {} -- 841
                        for i = 1, #enode.children do -- 841
                            visitAction(spawnStack, enode.children[i]) -- 843
                        end -- 843
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 845
                        break -- 846
                    end -- 846
                end -- 846
                ____cond183 = ____cond183 or ____switch183 == "sequence" -- 846
                if ____cond183 then -- 846
                    do -- 846
                        local sequenceStack = {} -- 849
                        for i = 1, #enode.children do -- 849
                            visitAction(sequenceStack, enode.children[i]) -- 851
                        end -- 851
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 853
                        break -- 854
                    end -- 854
                end -- 854
                do -- 854
                    Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 857
                    break -- 858
                end -- 858
            until true -- 858
        end -- 810
        local actionStack = {} -- 861
        for i = 1, #enode.children do -- 861
            visitAction(actionStack, enode.children[i]) -- 863
        end -- 863
        if #actionStack == 1 then -- 863
            action.ref.current = actionStack[1] -- 866
        elseif #actionStack > 1 then -- 866
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 868
        end -- 868
    end, -- 806
    ["anchor-x"] = actionCheck, -- 871
    ["anchor-y"] = actionCheck, -- 872
    angle = actionCheck, -- 873
    ["angle-x"] = actionCheck, -- 874
    ["angle-y"] = actionCheck, -- 875
    delay = actionCheck, -- 876
    event = actionCheck, -- 877
    width = actionCheck, -- 878
    height = actionCheck, -- 879
    hide = actionCheck, -- 880
    show = actionCheck, -- 881
    move = actionCheck, -- 882
    opacity = actionCheck, -- 883
    roll = actionCheck, -- 884
    scale = actionCheck, -- 885
    ["scale-x"] = actionCheck, -- 886
    ["scale-y"] = actionCheck, -- 887
    ["skew-x"] = actionCheck, -- 888
    ["skew-y"] = actionCheck, -- 889
    ["move-x"] = actionCheck, -- 890
    ["move-y"] = actionCheck, -- 891
    ["move-z"] = actionCheck, -- 892
    spawn = actionCheck, -- 893
    sequence = actionCheck, -- 894
    ["physics-world"] = function(nodeStack, enode, _parent) -- 895
        addChild( -- 896
            nodeStack, -- 896
            getPhysicsWorld(enode), -- 896
            enode -- 896
        ) -- 896
    end, -- 895
    contact = function(nodeStack, enode, _parent) -- 898
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 899
        if world ~= nil then -- 899
            local contact = enode.props -- 901
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 902
        else -- 902
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 904
        end -- 904
    end, -- 898
    body = function(nodeStack, enode, _parent) -- 907
        local def = enode.props -- 908
        if def.world then -- 908
            addChild( -- 910
                nodeStack, -- 910
                getBody(enode, def.world), -- 910
                enode -- 910
            ) -- 910
            return -- 911
        end -- 911
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 913
        if world ~= nil then -- 913
            addChild( -- 915
                nodeStack, -- 915
                getBody(enode, world), -- 915
                enode -- 915
            ) -- 915
        else -- 915
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 917
        end -- 917
    end, -- 907
    ["rect-fixture"] = bodyCheck, -- 920
    ["polygon-fixture"] = bodyCheck, -- 921
    ["multi-fixture"] = bodyCheck, -- 922
    ["disk-fixture"] = bodyCheck, -- 923
    ["chain-fixture"] = bodyCheck, -- 924
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 925
        local joint = enode.props -- 926
        if joint.ref == nil then -- 926
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 928
            return -- 929
        end -- 929
        if joint.bodyA.current == nil then -- 929
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 932
            return -- 933
        end -- 933
        if joint.bodyB.current == nil then -- 933
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 936
            return -- 937
        end -- 937
        local ____joint_ref_13 = joint.ref -- 939
        local ____self_11 = dora.Joint -- 939
        local ____self_11_distance_12 = ____self_11.distance -- 939
        local ____joint_canCollide_10 = joint.canCollide -- 940
        if ____joint_canCollide_10 == nil then -- 940
            ____joint_canCollide_10 = false -- 940
        end -- 940
        ____joint_ref_13.current = ____self_11_distance_12( -- 939
            ____self_11, -- 939
            ____joint_canCollide_10, -- 940
            joint.bodyA.current, -- 941
            joint.bodyB.current, -- 942
            joint.anchorA or dora.Vec2.zero, -- 943
            joint.anchorB or dora.Vec2.zero, -- 944
            joint.frequency or 0, -- 945
            joint.damping or 0 -- 946
        ) -- 946
    end, -- 925
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 948
        local joint = enode.props -- 949
        if joint.ref == nil then -- 949
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 951
            return -- 952
        end -- 952
        if joint.bodyA.current == nil then -- 952
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 955
            return -- 956
        end -- 956
        if joint.bodyB.current == nil then -- 956
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 959
            return -- 960
        end -- 960
        local ____joint_ref_17 = joint.ref -- 962
        local ____self_15 = dora.Joint -- 962
        local ____self_15_friction_16 = ____self_15.friction -- 962
        local ____joint_canCollide_14 = joint.canCollide -- 963
        if ____joint_canCollide_14 == nil then -- 963
            ____joint_canCollide_14 = false -- 963
        end -- 963
        ____joint_ref_17.current = ____self_15_friction_16( -- 962
            ____self_15, -- 962
            ____joint_canCollide_14, -- 963
            joint.bodyA.current, -- 964
            joint.bodyB.current, -- 965
            joint.worldPos, -- 966
            joint.maxForce, -- 967
            joint.maxTorque -- 968
        ) -- 968
    end, -- 948
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 971
        local joint = enode.props -- 972
        if joint.ref == nil then -- 972
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 974
            return -- 975
        end -- 975
        if joint.jointA.current == nil then -- 975
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 978
            return -- 979
        end -- 979
        if joint.jointB.current == nil then -- 979
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 982
            return -- 983
        end -- 983
        local ____joint_ref_21 = joint.ref -- 985
        local ____self_19 = dora.Joint -- 985
        local ____self_19_gear_20 = ____self_19.gear -- 985
        local ____joint_canCollide_18 = joint.canCollide -- 986
        if ____joint_canCollide_18 == nil then -- 986
            ____joint_canCollide_18 = false -- 986
        end -- 986
        ____joint_ref_21.current = ____self_19_gear_20( -- 985
            ____self_19, -- 985
            ____joint_canCollide_18, -- 986
            joint.jointA.current, -- 987
            joint.jointB.current, -- 988
            joint.ratio or 1 -- 989
        ) -- 989
    end, -- 971
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 992
        local joint = enode.props -- 993
        if joint.ref == nil then -- 993
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 995
            return -- 996
        end -- 996
        if joint.bodyA.current == nil then -- 996
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 999
            return -- 1000
        end -- 1000
        if joint.bodyB.current == nil then -- 1000
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1003
            return -- 1004
        end -- 1004
        local ____joint_ref_25 = joint.ref -- 1006
        local ____self_23 = dora.Joint -- 1006
        local ____self_23_spring_24 = ____self_23.spring -- 1006
        local ____joint_canCollide_22 = joint.canCollide -- 1007
        if ____joint_canCollide_22 == nil then -- 1007
            ____joint_canCollide_22 = false -- 1007
        end -- 1007
        ____joint_ref_25.current = ____self_23_spring_24( -- 1006
            ____self_23, -- 1006
            ____joint_canCollide_22, -- 1007
            joint.bodyA.current, -- 1008
            joint.bodyB.current, -- 1009
            joint.linearOffset, -- 1010
            joint.angularOffset, -- 1011
            joint.maxForce, -- 1012
            joint.maxTorque, -- 1013
            joint.correctionFactor or 1 -- 1014
        ) -- 1014
    end, -- 992
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1017
        local joint = enode.props -- 1018
        if joint.ref == nil then -- 1018
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1020
            return -- 1021
        end -- 1021
        if joint.body.current == nil then -- 1021
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1024
            return -- 1025
        end -- 1025
        local ____joint_ref_29 = joint.ref -- 1027
        local ____self_27 = dora.Joint -- 1027
        local ____self_27_move_28 = ____self_27.move -- 1027
        local ____joint_canCollide_26 = joint.canCollide -- 1028
        if ____joint_canCollide_26 == nil then -- 1028
            ____joint_canCollide_26 = false -- 1028
        end -- 1028
        ____joint_ref_29.current = ____self_27_move_28( -- 1027
            ____self_27, -- 1027
            ____joint_canCollide_26, -- 1028
            joint.body.current, -- 1029
            joint.targetPos, -- 1030
            joint.maxForce, -- 1031
            joint.frequency, -- 1032
            joint.damping or 0.7 -- 1033
        ) -- 1033
    end, -- 1017
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1036
        local joint = enode.props -- 1037
        if joint.ref == nil then -- 1037
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1039
            return -- 1040
        end -- 1040
        if joint.bodyA.current == nil then -- 1040
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1043
            return -- 1044
        end -- 1044
        if joint.bodyB.current == nil then -- 1044
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1047
            return -- 1048
        end -- 1048
        local ____joint_ref_33 = joint.ref -- 1050
        local ____self_31 = dora.Joint -- 1050
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1050
        local ____joint_canCollide_30 = joint.canCollide -- 1051
        if ____joint_canCollide_30 == nil then -- 1051
            ____joint_canCollide_30 = false -- 1051
        end -- 1051
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1050
            ____self_31, -- 1050
            ____joint_canCollide_30, -- 1051
            joint.bodyA.current, -- 1052
            joint.bodyB.current, -- 1053
            joint.worldPos, -- 1054
            joint.axisAngle, -- 1055
            joint.lowerTranslation or 0, -- 1056
            joint.upperTranslation or 0, -- 1057
            joint.maxMotorForce or 0, -- 1058
            joint.motorSpeed or 0 -- 1059
        ) -- 1059
    end, -- 1036
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1062
        local joint = enode.props -- 1063
        if joint.ref == nil then -- 1063
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1065
            return -- 1066
        end -- 1066
        if joint.bodyA.current == nil then -- 1066
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1069
            return -- 1070
        end -- 1070
        if joint.bodyB.current == nil then -- 1070
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1073
            return -- 1074
        end -- 1074
        local ____joint_ref_37 = joint.ref -- 1076
        local ____self_35 = dora.Joint -- 1076
        local ____self_35_pulley_36 = ____self_35.pulley -- 1076
        local ____joint_canCollide_34 = joint.canCollide -- 1077
        if ____joint_canCollide_34 == nil then -- 1077
            ____joint_canCollide_34 = false -- 1077
        end -- 1077
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1076
            ____self_35, -- 1076
            ____joint_canCollide_34, -- 1077
            joint.bodyA.current, -- 1078
            joint.bodyB.current, -- 1079
            joint.anchorA or dora.Vec2.zero, -- 1080
            joint.anchorB or dora.Vec2.zero, -- 1081
            joint.groundAnchorA, -- 1082
            joint.groundAnchorB, -- 1083
            joint.ratio or 1 -- 1084
        ) -- 1084
    end, -- 1062
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1087
        local joint = enode.props -- 1088
        if joint.ref == nil then -- 1088
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1090
            return -- 1091
        end -- 1091
        if joint.bodyA.current == nil then -- 1091
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1094
            return -- 1095
        end -- 1095
        if joint.bodyB.current == nil then -- 1095
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1098
            return -- 1099
        end -- 1099
        local ____joint_ref_41 = joint.ref -- 1101
        local ____self_39 = dora.Joint -- 1101
        local ____self_39_revolute_40 = ____self_39.revolute -- 1101
        local ____joint_canCollide_38 = joint.canCollide -- 1102
        if ____joint_canCollide_38 == nil then -- 1102
            ____joint_canCollide_38 = false -- 1102
        end -- 1102
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1101
            ____self_39, -- 1101
            ____joint_canCollide_38, -- 1102
            joint.bodyA.current, -- 1103
            joint.bodyB.current, -- 1104
            joint.worldPos, -- 1105
            joint.lowerAngle or 0, -- 1106
            joint.upperAngle or 0, -- 1107
            joint.maxMotorTorque or 0, -- 1108
            joint.motorSpeed or 0 -- 1109
        ) -- 1109
    end, -- 1087
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1112
        local joint = enode.props -- 1113
        if joint.ref == nil then -- 1113
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1115
            return -- 1116
        end -- 1116
        if joint.bodyA.current == nil then -- 1116
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1119
            return -- 1120
        end -- 1120
        if joint.bodyB.current == nil then -- 1120
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1123
            return -- 1124
        end -- 1124
        local ____joint_ref_45 = joint.ref -- 1126
        local ____self_43 = dora.Joint -- 1126
        local ____self_43_rope_44 = ____self_43.rope -- 1126
        local ____joint_canCollide_42 = joint.canCollide -- 1127
        if ____joint_canCollide_42 == nil then -- 1127
            ____joint_canCollide_42 = false -- 1127
        end -- 1127
        ____joint_ref_45.current = ____self_43_rope_44( -- 1126
            ____self_43, -- 1126
            ____joint_canCollide_42, -- 1127
            joint.bodyA.current, -- 1128
            joint.bodyB.current, -- 1129
            joint.anchorA or dora.Vec2.zero, -- 1130
            joint.anchorB or dora.Vec2.zero, -- 1131
            joint.maxLength or 0 -- 1132
        ) -- 1132
    end, -- 1112
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1135
        local joint = enode.props -- 1136
        if joint.ref == nil then -- 1136
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1138
            return -- 1139
        end -- 1139
        if joint.bodyA.current == nil then -- 1139
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1142
            return -- 1143
        end -- 1143
        if joint.bodyB.current == nil then -- 1143
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1146
            return -- 1147
        end -- 1147
        local ____joint_ref_49 = joint.ref -- 1149
        local ____self_47 = dora.Joint -- 1149
        local ____self_47_weld_48 = ____self_47.weld -- 1149
        local ____joint_canCollide_46 = joint.canCollide -- 1150
        if ____joint_canCollide_46 == nil then -- 1150
            ____joint_canCollide_46 = false -- 1150
        end -- 1150
        ____joint_ref_49.current = ____self_47_weld_48( -- 1149
            ____self_47, -- 1149
            ____joint_canCollide_46, -- 1150
            joint.bodyA.current, -- 1151
            joint.bodyB.current, -- 1152
            joint.worldPos, -- 1153
            joint.frequency or 0, -- 1154
            joint.damping or 0 -- 1155
        ) -- 1155
    end, -- 1135
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1158
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
        local ____joint_ref_53 = joint.ref -- 1172
        local ____self_51 = dora.Joint -- 1172
        local ____self_51_wheel_52 = ____self_51.wheel -- 1172
        local ____joint_canCollide_50 = joint.canCollide -- 1173
        if ____joint_canCollide_50 == nil then -- 1173
            ____joint_canCollide_50 = false -- 1173
        end -- 1173
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1172
            ____self_51, -- 1172
            ____joint_canCollide_50, -- 1173
            joint.bodyA.current, -- 1174
            joint.bodyB.current, -- 1175
            joint.worldPos, -- 1176
            joint.axisAngle, -- 1177
            joint.maxMotorTorque or 0, -- 1178
            joint.motorSpeed or 0, -- 1179
            joint.frequency or 0, -- 1180
            joint.damping or 0.7 -- 1181
        ) -- 1181
    end, -- 1158
    ["custom-node"] = function(nodeStack, enode, parent) -- 1184
        local node = getCustomNode(enode) -- 1185
        if node ~= nil then -- 1185
            addChild(nodeStack, node, enode) -- 1187
        end -- 1187
    end, -- 1184
    ["custom-element"] = function() -- 1190
    end -- 1190
} -- 1190
function ____exports.useRef(item) -- 1233
    local ____item_54 = item -- 1234
    if ____item_54 == nil then -- 1234
        ____item_54 = nil -- 1234
    end -- 1234
    return {current = ____item_54} -- 1234
end -- 1233
local function getPreload(preloadList, node) -- 1237
    if type(node) ~= "table" then -- 1237
        return -- 1239
    end -- 1239
    local enode = node -- 1241
    if enode.type == nil then -- 1241
        local list = node -- 1243
        if #list > 0 then -- 1243
            for i = 1, #list do -- 1243
                getPreload(preloadList, list[i]) -- 1246
            end -- 1246
        end -- 1246
    else -- 1246
        repeat -- 1246
            local ____switch270 = enode.type -- 1246
            local sprite, playable, model, spine, dragonBone, label -- 1246
            local ____cond270 = ____switch270 == "sprite" -- 1246
            if ____cond270 then -- 1246
                sprite = enode.props -- 1252
                preloadList[#preloadList + 1] = sprite.file -- 1253
                break -- 1254
            end -- 1254
            ____cond270 = ____cond270 or ____switch270 == "playable" -- 1254
            if ____cond270 then -- 1254
                playable = enode.props -- 1256
                preloadList[#preloadList + 1] = playable.file -- 1257
                break -- 1258
            end -- 1258
            ____cond270 = ____cond270 or ____switch270 == "model" -- 1258
            if ____cond270 then -- 1258
                model = enode.props -- 1260
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1261
                break -- 1262
            end -- 1262
            ____cond270 = ____cond270 or ____switch270 == "spine" -- 1262
            if ____cond270 then -- 1262
                spine = enode.props -- 1264
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1265
                break -- 1266
            end -- 1266
            ____cond270 = ____cond270 or ____switch270 == "dragon-bone" -- 1266
            if ____cond270 then -- 1266
                dragonBone = enode.props -- 1268
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1269
                break -- 1270
            end -- 1270
            ____cond270 = ____cond270 or ____switch270 == "label" -- 1270
            if ____cond270 then -- 1270
                label = enode.props -- 1272
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1273
                break -- 1274
            end -- 1274
        until true -- 1274
    end -- 1274
    getPreload(preloadList, enode.children) -- 1277
end -- 1237
function ____exports.preloadAsync(enode, handler) -- 1280
    local preloadList = {} -- 1281
    getPreload(preloadList, enode) -- 1282
    dora.Cache:loadAsync(preloadList, handler) -- 1283
end -- 1280
return ____exports -- 1280
