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
function visitNode(nodeStack, node, parent) -- 1190
    if type(node) ~= "table" then -- 1190
        return -- 1192
    end -- 1192
    local enode = node -- 1194
    if enode.type == nil then -- 1194
        local list = node -- 1196
        if #list > 0 then -- 1196
            for i = 1, #list do -- 1196
                local stack = {} -- 1199
                visitNode(stack, list[i], parent) -- 1200
                for i = 1, #stack do -- 1200
                    nodeStack[#nodeStack + 1] = stack[i] -- 1202
                end -- 1202
            end -- 1202
        end -- 1202
    else -- 1202
        local handler = elementMap[enode.type] -- 1207
        if handler ~= nil then -- 1207
            handler(nodeStack, enode, parent) -- 1209
        else -- 1209
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1211
        end -- 1211
    end -- 1211
end -- 1211
function ____exports.toNode(enode) -- 1216
    local nodeStack = {} -- 1217
    visitNode(nodeStack, enode) -- 1218
    if #nodeStack == 1 then -- 1218
        return nodeStack[1] -- 1220
    elseif #nodeStack > 1 then -- 1220
        local node = dora.Node() -- 1222
        for i = 1, #nodeStack do -- 1222
            node:addChild(nodeStack[i]) -- 1224
        end -- 1224
        return node -- 1226
    end -- 1226
    return nil -- 1228
end -- 1216
____exports.React = {} -- 1216
local React = ____exports.React -- 1216
do -- 1216
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
            ____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 403
            if ____cond86 then -- 403
                cnode.blendFunc = v -- 404
                return true -- 404
            end -- 404
            ____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 404
            if ____cond86 then -- 404
                cnode.depthWrite = v -- 405
                return true -- 405
            end -- 405
            ____cond86 = ____cond86 or ____switch86 == "batched" -- 405
            if ____cond86 then -- 405
                cnode.batched = v -- 406
                return true -- 406
            end -- 406
            ____cond86 = ____cond86 or ____switch86 == "effect" -- 406
            if ____cond86 then -- 406
                cnode.effect = v -- 407
                return true -- 407
            end -- 407
            ____cond86 = ____cond86 or ____switch86 == "alignment" -- 407
            if ____cond86 then -- 407
                cnode.alignment = v -- 408
                return true -- 408
            end -- 408
        until true -- 408
        return false -- 410
    end -- 398
    getLabel = function(enode) -- 412
        local label = enode.props -- 413
        local node = dora.Label(label.fontName, label.fontSize) -- 414
        if node ~= nil then -- 414
            local cnode = getNode(enode, node, handleLabelAttribute) -- 416
            local ____enode_8 = enode -- 417
            local children = ____enode_8.children -- 417
            local text = label.text or "" -- 418
            for i = 1, #children do -- 418
                local child = children[i] -- 420
                if type(child) ~= "table" then -- 420
                    text = text .. tostring(child) -- 422
                end -- 422
            end -- 422
            node.text = text -- 425
            return cnode -- 426
        end -- 426
        return nil -- 428
    end -- 412
end -- 412
local getLine -- 432
do -- 432
    local function handleLineAttribute(cnode, enode, k, v) -- 434
        local line = enode.props -- 435
        repeat -- 435
            local ____switch93 = k -- 435
            local ____cond93 = ____switch93 == "verts" -- 435
            if ____cond93 then -- 435
                cnode:set( -- 437
                    v, -- 437
                    dora.Color(line.lineColor or 4294967295) -- 437
                ) -- 437
                return true -- 437
            end -- 437
            ____cond93 = ____cond93 or ____switch93 == "depthWrite" -- 437
            if ____cond93 then -- 437
                cnode.depthWrite = v -- 438
                return true -- 438
            end -- 438
            ____cond93 = ____cond93 or ____switch93 == "blendFunc" -- 438
            if ____cond93 then -- 438
                cnode.blendFunc = v -- 439
                return true -- 439
            end -- 439
        until true -- 439
        return false -- 441
    end -- 434
    getLine = function(enode) -- 443
        local node = dora.Line() -- 444
        local cnode = getNode(enode, node, handleLineAttribute) -- 445
        return cnode -- 446
    end -- 443
end -- 443
local getParticle -- 450
do -- 450
    local function handleParticleAttribute(cnode, _enode, k, v) -- 452
        repeat -- 452
            local ____switch97 = k -- 452
            local ____cond97 = ____switch97 == "file" -- 452
            if ____cond97 then -- 452
                return true -- 454
            end -- 454
            ____cond97 = ____cond97 or ____switch97 == "emit" -- 454
            if ____cond97 then -- 454
                if v then -- 454
                    cnode:start() -- 455
                end -- 455
                return true -- 455
            end -- 455
            ____cond97 = ____cond97 or ____switch97 == "onFinished" -- 455
            if ____cond97 then -- 455
                cnode:slot("Finished", v) -- 456
                return true -- 456
            end -- 456
        until true -- 456
        return false -- 458
    end -- 452
    getParticle = function(enode) -- 460
        local particle = enode.props -- 461
        local node = dora.Particle(particle.file) -- 462
        if node ~= nil then -- 462
            local cnode = getNode(enode, node, handleParticleAttribute) -- 464
            return cnode -- 465
        end -- 465
        return nil -- 467
    end -- 460
end -- 460
local getMenu -- 471
do -- 471
    local function handleMenuAttribute(cnode, _enode, k, v) -- 473
        repeat -- 473
            local ____switch103 = k -- 473
            local ____cond103 = ____switch103 == "enabled" -- 473
            if ____cond103 then -- 473
                cnode.enabled = v -- 475
                return true -- 475
            end -- 475
        until true -- 475
        return false -- 477
    end -- 473
    getMenu = function(enode) -- 479
        local node = dora.Menu() -- 480
        local cnode = getNode(enode, node, handleMenuAttribute) -- 481
        return cnode -- 482
    end -- 479
end -- 479
local getPhysicsWorld -- 486
do -- 486
    local function handlePhysicsWorldAttribute(cnode, _enode, k, v) -- 488
        repeat -- 488
            local ____switch107 = k -- 488
            local ____cond107 = ____switch107 == "showDebug" -- 488
            if ____cond107 then -- 488
                cnode.showDebug = v -- 490
                return true -- 490
            end -- 490
        until true -- 490
        return false -- 492
    end -- 488
    getPhysicsWorld = function(enode) -- 494
        local node = dora.PhysicsWorld() -- 495
        local cnode = getNode(enode, node, handlePhysicsWorldAttribute) -- 496
        return cnode -- 497
    end -- 494
end -- 494
local getBody -- 501
do -- 501
    local function handleBodyAttribute(cnode, _enode, k, v) -- 503
        repeat -- 503
            local ____switch111 = k -- 503
            local ____cond111 = ____switch111 == "type" or ____switch111 == "linearAcceleration" or ____switch111 == "fixedRotation" or ____switch111 == "bullet" or ____switch111 == "world" -- 503
            if ____cond111 then -- 503
                return true -- 510
            end -- 510
            ____cond111 = ____cond111 or ____switch111 == "velocityX" -- 510
            if ____cond111 then -- 510
                cnode.velocityX = v -- 511
                return true -- 511
            end -- 511
            ____cond111 = ____cond111 or ____switch111 == "velocityY" -- 511
            if ____cond111 then -- 511
                cnode.velocityY = v -- 512
                return true -- 512
            end -- 512
            ____cond111 = ____cond111 or ____switch111 == "angularRate" -- 512
            if ____cond111 then -- 512
                cnode.angularRate = v -- 513
                return true -- 513
            end -- 513
            ____cond111 = ____cond111 or ____switch111 == "group" -- 513
            if ____cond111 then -- 513
                cnode.group = v -- 514
                return true -- 514
            end -- 514
            ____cond111 = ____cond111 or ____switch111 == "linearDamping" -- 514
            if ____cond111 then -- 514
                cnode.linearDamping = v -- 515
                return true -- 515
            end -- 515
            ____cond111 = ____cond111 or ____switch111 == "angularDamping" -- 515
            if ____cond111 then -- 515
                cnode.angularDamping = v -- 516
                return true -- 516
            end -- 516
            ____cond111 = ____cond111 or ____switch111 == "owner" -- 516
            if ____cond111 then -- 516
                cnode.owner = v -- 517
                return true -- 517
            end -- 517
            ____cond111 = ____cond111 or ____switch111 == "receivingContact" -- 517
            if ____cond111 then -- 517
                cnode.receivingContact = v -- 518
                return true -- 518
            end -- 518
            ____cond111 = ____cond111 or ____switch111 == "onBodyEnter" -- 518
            if ____cond111 then -- 518
                cnode:slot("BodyEnter", v) -- 519
                return true -- 519
            end -- 519
            ____cond111 = ____cond111 or ____switch111 == "onBodyLeave" -- 519
            if ____cond111 then -- 519
                cnode:slot("BodyLeave", v) -- 520
                return true -- 520
            end -- 520
            ____cond111 = ____cond111 or ____switch111 == "onContactStart" -- 520
            if ____cond111 then -- 520
                cnode:slot("ContactStart", v) -- 521
                return true -- 521
            end -- 521
            ____cond111 = ____cond111 or ____switch111 == "onContactEnd" -- 521
            if ____cond111 then -- 521
                cnode:slot("ContactEnd", v) -- 522
                return true -- 522
            end -- 522
            ____cond111 = ____cond111 or ____switch111 == "onContactFilter" -- 522
            if ____cond111 then -- 522
                cnode:onContactFilter(v) -- 523
                return true -- 523
            end -- 523
        until true -- 523
        return false -- 525
    end -- 503
    getBody = function(enode, world) -- 527
        local def = enode.props -- 528
        local bodyDef = dora.BodyDef() -- 529
        bodyDef.type = def.type -- 530
        if def.angle ~= nil then -- 530
            bodyDef.angle = def.angle -- 531
        end -- 531
        if def.angularDamping ~= nil then -- 531
            bodyDef.angularDamping = def.angularDamping -- 532
        end -- 532
        if def.bullet ~= nil then -- 532
            bodyDef.bullet = def.bullet -- 533
        end -- 533
        if def.fixedRotation ~= nil then -- 533
            bodyDef.fixedRotation = def.fixedRotation -- 534
        end -- 534
        if def.linearAcceleration ~= nil then -- 534
            bodyDef.linearAcceleration = def.linearAcceleration -- 535
        end -- 535
        if def.linearDamping ~= nil then -- 535
            bodyDef.linearDamping = def.linearDamping -- 536
        end -- 536
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 537
        local extraSensors = nil -- 538
        for i = 1, #enode.children do -- 538
            do -- 538
                local child = enode.children[i] -- 540
                if type(child) ~= "table" then -- 540
                    goto __continue119 -- 542
                end -- 542
                repeat -- 542
                    local ____switch121 = child.type -- 542
                    local ____cond121 = ____switch121 == "rect-fixture" -- 542
                    if ____cond121 then -- 542
                        do -- 542
                            local shape = child.props -- 546
                            if shape.sensorTag ~= nil then -- 546
                                bodyDef:attachPolygonSensor( -- 548
                                    shape.sensorTag, -- 549
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 550
                                    shape.width, -- 551
                                    shape.height, -- 551
                                    shape.angle or 0 -- 552
                                ) -- 552
                            else -- 552
                                bodyDef:attachPolygon( -- 555
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 556
                                    shape.width, -- 557
                                    shape.height, -- 557
                                    shape.angle or 0, -- 558
                                    shape.density or 0, -- 559
                                    shape.friction or 0.4, -- 560
                                    shape.restitution or 0 -- 561
                                ) -- 561
                            end -- 561
                            break -- 564
                        end -- 564
                    end -- 564
                    ____cond121 = ____cond121 or ____switch121 == "polygon-fixture" -- 564
                    if ____cond121 then -- 564
                        do -- 564
                            local shape = child.props -- 567
                            if shape.sensorTag ~= nil then -- 567
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 569
                            else -- 569
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 574
                            end -- 574
                            break -- 581
                        end -- 581
                    end -- 581
                    ____cond121 = ____cond121 or ____switch121 == "multi-fixture" -- 581
                    if ____cond121 then -- 581
                        do -- 581
                            local shape = child.props -- 584
                            if shape.sensorTag ~= nil then -- 584
                                if extraSensors == nil then -- 584
                                    extraSensors = {} -- 586
                                end -- 586
                                extraSensors[#extraSensors + 1] = { -- 587
                                    shape.sensorTag, -- 587
                                    dora.BodyDef:multi(shape.verts) -- 587
                                } -- 587
                            else -- 587
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 589
                            end -- 589
                            break -- 596
                        end -- 596
                    end -- 596
                    ____cond121 = ____cond121 or ____switch121 == "disk-fixture" -- 596
                    if ____cond121 then -- 596
                        do -- 596
                            local shape = child.props -- 599
                            if shape.sensorTag ~= nil then -- 599
                                bodyDef:attachDiskSensor( -- 601
                                    shape.sensorTag, -- 602
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 603
                                    shape.radius -- 604
                                ) -- 604
                            else -- 604
                                bodyDef:attachDisk( -- 607
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 608
                                    shape.radius, -- 609
                                    shape.density or 0, -- 610
                                    shape.friction or 0.4, -- 611
                                    shape.restitution or 0 -- 612
                                ) -- 612
                            end -- 612
                            break -- 615
                        end -- 615
                    end -- 615
                    ____cond121 = ____cond121 or ____switch121 == "chain-fixture" -- 615
                    if ____cond121 then -- 615
                        do -- 615
                            local shape = child.props -- 618
                            if shape.sensorTag ~= nil then -- 618
                                if extraSensors == nil then -- 618
                                    extraSensors = {} -- 620
                                end -- 620
                                extraSensors[#extraSensors + 1] = { -- 621
                                    shape.sensorTag, -- 621
                                    dora.BodyDef:chain(shape.verts) -- 621
                                } -- 621
                            else -- 621
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 623
                            end -- 623
                            break -- 629
                        end -- 629
                    end -- 629
                until true -- 629
            end -- 629
            ::__continue119:: -- 629
        end -- 629
        local body = dora.Body(bodyDef, world) -- 633
        if extraSensors ~= nil then -- 633
            for i = 1, #extraSensors do -- 633
                local tag, def = table.unpack(extraSensors[i]) -- 636
                body:attachSensor(tag, def) -- 637
            end -- 637
        end -- 637
        local cnode = getNode(enode, body, handleBodyAttribute) -- 640
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 640
            body.receivingContact = true -- 647
        end -- 647
        return cnode -- 649
    end -- 527
end -- 527
local getCustomNode -- 653
do -- 653
    local function handleCustomNode(_cnode, _enode, k, _v) -- 655
        repeat -- 655
            local ____switch142 = k -- 655
            local ____cond142 = ____switch142 == "onCreate" -- 655
            if ____cond142 then -- 655
                return true -- 657
            end -- 657
        until true -- 657
        return false -- 659
    end -- 655
    getCustomNode = function(enode) -- 661
        local custom = enode.props -- 662
        local node = custom.onCreate() -- 663
        if node then -- 663
            local cnode = getNode(enode, node, handleCustomNode) -- 665
            return cnode -- 666
        end -- 666
        return nil -- 668
    end -- 661
end -- 661
local function addChild(nodeStack, cnode, enode) -- 672
    if #nodeStack > 0 then -- 672
        local last = nodeStack[#nodeStack] -- 674
        last:addChild(cnode) -- 675
    end -- 675
    nodeStack[#nodeStack + 1] = cnode -- 677
    local ____enode_9 = enode -- 678
    local children = ____enode_9.children -- 678
    for i = 1, #children do -- 678
        visitNode(nodeStack, children[i], enode) -- 680
    end -- 680
    if #nodeStack > 1 then -- 680
        table.remove(nodeStack) -- 683
    end -- 683
end -- 672
local function drawNodeCheck(_nodeStack, enode, parent) -- 691
    if parent == nil or parent.type ~= "draw-node" then -- 691
        Warn(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 693
    end -- 693
end -- 691
local function actionCheck(_nodeStack, enode, parent) -- 697
    local unsupported = false -- 698
    if parent == nil then -- 698
        unsupported = true -- 700
    else -- 700
        repeat -- 700
            local ____switch154 = enode.type -- 700
            local ____cond154 = ____switch154 == "action" or ____switch154 == "spawn" or ____switch154 == "sequence" -- 700
            if ____cond154 then -- 700
                break -- 703
            end -- 703
            do -- 703
                unsupported = true -- 704
                break -- 704
            end -- 704
        until true -- 704
    end -- 704
    if unsupported then -- 704
        Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 708
    end -- 708
end -- 697
local function bodyCheck(_nodeStack, enode, parent) -- 712
    if parent == nil or parent.type ~= "body" then -- 712
        Warn(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 714
    end -- 714
end -- 712
local actionMap = { -- 718
    ["anchor-x"] = dora.AnchorX, -- 721
    ["anchor-y"] = dora.AnchorY, -- 722
    angle = dora.Angle, -- 723
    ["angle-x"] = dora.AngleX, -- 724
    ["angle-y"] = dora.AngleY, -- 725
    width = dora.Width, -- 726
    height = dora.Height, -- 727
    opacity = dora.Opacity, -- 728
    roll = dora.Roll, -- 729
    scale = dora.Scale, -- 730
    ["scale-x"] = dora.ScaleX, -- 731
    ["scale-y"] = dora.ScaleY, -- 732
    ["skew-x"] = dora.SkewX, -- 733
    ["skew-y"] = dora.SkewY, -- 734
    ["move-x"] = dora.X, -- 735
    ["move-y"] = dora.Y, -- 736
    ["move-z"] = dora.Z -- 737
} -- 737
elementMap = { -- 740
    node = function(nodeStack, enode, parent) -- 741
        addChild( -- 742
            nodeStack, -- 742
            getNode(enode), -- 742
            enode -- 742
        ) -- 742
    end, -- 741
    ["clip-node"] = function(nodeStack, enode, parent) -- 744
        addChild( -- 745
            nodeStack, -- 745
            getClipNode(enode), -- 745
            enode -- 745
        ) -- 745
    end, -- 744
    playable = function(nodeStack, enode, parent) -- 747
        local cnode = getPlayable(enode) -- 748
        if cnode ~= nil then -- 748
            addChild(nodeStack, cnode, enode) -- 750
        end -- 750
    end, -- 747
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 753
        local cnode = getDragonBone(enode) -- 754
        if cnode ~= nil then -- 754
            addChild(nodeStack, cnode, enode) -- 756
        end -- 756
    end, -- 753
    spine = function(nodeStack, enode, parent) -- 759
        local cnode = getSpine(enode) -- 760
        if cnode ~= nil then -- 760
            addChild(nodeStack, cnode, enode) -- 762
        end -- 762
    end, -- 759
    model = function(nodeStack, enode, parent) -- 765
        local cnode = getModel(enode) -- 766
        if cnode ~= nil then -- 766
            addChild(nodeStack, cnode, enode) -- 768
        end -- 768
    end, -- 765
    ["draw-node"] = function(nodeStack, enode, parent) -- 771
        addChild( -- 772
            nodeStack, -- 772
            getDrawNode(enode), -- 772
            enode -- 772
        ) -- 772
    end, -- 771
    ["dot-shape"] = drawNodeCheck, -- 774
    ["segment-shape"] = drawNodeCheck, -- 775
    ["polygon-shape"] = drawNodeCheck, -- 776
    ["verts-shape"] = drawNodeCheck, -- 777
    grid = function(nodeStack, enode, parent) -- 778
        addChild( -- 779
            nodeStack, -- 779
            getGrid(enode), -- 779
            enode -- 779
        ) -- 779
    end, -- 778
    sprite = function(nodeStack, enode, parent) -- 781
        local cnode = getSprite(enode) -- 782
        if cnode ~= nil then -- 782
            addChild(nodeStack, cnode, enode) -- 784
        end -- 784
    end, -- 781
    label = function(nodeStack, enode, parent) -- 787
        local cnode = getLabel(enode) -- 788
        if cnode ~= nil then -- 788
            addChild(nodeStack, cnode, enode) -- 790
        end -- 790
    end, -- 787
    line = function(nodeStack, enode, parent) -- 793
        addChild( -- 794
            nodeStack, -- 794
            getLine(enode), -- 794
            enode -- 794
        ) -- 794
    end, -- 793
    particle = function(nodeStack, enode, parent) -- 796
        local cnode = getParticle(enode) -- 797
        if cnode ~= nil then -- 797
            addChild(nodeStack, cnode, enode) -- 799
        end -- 799
    end, -- 796
    menu = function(nodeStack, enode, parent) -- 802
        addChild( -- 803
            nodeStack, -- 803
            getMenu(enode), -- 803
            enode -- 803
        ) -- 803
    end, -- 802
    action = function(_nodeStack, enode, parent) -- 805
        if #enode.children == 0 then -- 805
            return -- 806
        end -- 806
        local action = enode.props -- 807
        if action.ref == nil then -- 807
            return -- 808
        end -- 808
        local function visitAction(actionStack, enode) -- 809
            local createAction = actionMap[enode.type] -- 810
            if createAction ~= nil then -- 810
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 812
                return -- 813
            end -- 813
            repeat -- 813
                local ____switch183 = enode.type -- 813
                local ____cond183 = ____switch183 == "delay" -- 813
                if ____cond183 then -- 813
                    do -- 813
                        local item = enode.props -- 817
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 818
                        break -- 819
                    end -- 819
                end -- 819
                ____cond183 = ____cond183 or ____switch183 == "event" -- 819
                if ____cond183 then -- 819
                    do -- 819
                        local item = enode.props -- 822
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 823
                        break -- 824
                    end -- 824
                end -- 824
                ____cond183 = ____cond183 or ____switch183 == "hide" -- 824
                if ____cond183 then -- 824
                    do -- 824
                        actionStack[#actionStack + 1] = dora.Hide() -- 827
                        break -- 828
                    end -- 828
                end -- 828
                ____cond183 = ____cond183 or ____switch183 == "show" -- 828
                if ____cond183 then -- 828
                    do -- 828
                        actionStack[#actionStack + 1] = dora.Show() -- 831
                        break -- 832
                    end -- 832
                end -- 832
                ____cond183 = ____cond183 or ____switch183 == "move" -- 832
                if ____cond183 then -- 832
                    do -- 832
                        local item = enode.props -- 835
                        actionStack[#actionStack + 1] = dora.Move( -- 836
                            item.time, -- 836
                            dora.Vec2(item.startX, item.startY), -- 836
                            dora.Vec2(item.stopX, item.stopY), -- 836
                            item.easing -- 836
                        ) -- 836
                        break -- 837
                    end -- 837
                end -- 837
                ____cond183 = ____cond183 or ____switch183 == "spawn" -- 837
                if ____cond183 then -- 837
                    do -- 837
                        local spawnStack = {} -- 840
                        for i = 1, #enode.children do -- 840
                            visitAction(spawnStack, enode.children[i]) -- 842
                        end -- 842
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 844
                        break -- 845
                    end -- 845
                end -- 845
                ____cond183 = ____cond183 or ____switch183 == "sequence" -- 845
                if ____cond183 then -- 845
                    do -- 845
                        local sequenceStack = {} -- 848
                        for i = 1, #enode.children do -- 848
                            visitAction(sequenceStack, enode.children[i]) -- 850
                        end -- 850
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 852
                        break -- 853
                    end -- 853
                end -- 853
                do -- 853
                    Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 856
                    break -- 857
                end -- 857
            until true -- 857
        end -- 809
        local actionStack = {} -- 860
        for i = 1, #enode.children do -- 860
            visitAction(actionStack, enode.children[i]) -- 862
        end -- 862
        if #actionStack == 1 then -- 862
            action.ref.current = actionStack[1] -- 865
        elseif #actionStack > 1 then -- 865
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 867
        end -- 867
    end, -- 805
    ["anchor-x"] = actionCheck, -- 870
    ["anchor-y"] = actionCheck, -- 871
    angle = actionCheck, -- 872
    ["angle-x"] = actionCheck, -- 873
    ["angle-y"] = actionCheck, -- 874
    delay = actionCheck, -- 875
    event = actionCheck, -- 876
    width = actionCheck, -- 877
    height = actionCheck, -- 878
    hide = actionCheck, -- 879
    show = actionCheck, -- 880
    move = actionCheck, -- 881
    opacity = actionCheck, -- 882
    roll = actionCheck, -- 883
    scale = actionCheck, -- 884
    ["scale-x"] = actionCheck, -- 885
    ["scale-y"] = actionCheck, -- 886
    ["skew-x"] = actionCheck, -- 887
    ["skew-y"] = actionCheck, -- 888
    ["move-x"] = actionCheck, -- 889
    ["move-y"] = actionCheck, -- 890
    ["move-z"] = actionCheck, -- 891
    spawn = actionCheck, -- 892
    sequence = actionCheck, -- 893
    ["physics-world"] = function(nodeStack, enode, _parent) -- 894
        addChild( -- 895
            nodeStack, -- 895
            getPhysicsWorld(enode), -- 895
            enode -- 895
        ) -- 895
    end, -- 894
    contact = function(nodeStack, enode, _parent) -- 897
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 898
        if world ~= nil then -- 898
            local contact = enode.props -- 900
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 901
        else -- 901
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 903
        end -- 903
    end, -- 897
    body = function(nodeStack, enode, _parent) -- 906
        local def = enode.props -- 907
        if def.world then -- 907
            addChild( -- 909
                nodeStack, -- 909
                getBody(enode, def.world), -- 909
                enode -- 909
            ) -- 909
            return -- 910
        end -- 910
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 912
        if world ~= nil then -- 912
            addChild( -- 914
                nodeStack, -- 914
                getBody(enode, world), -- 914
                enode -- 914
            ) -- 914
        else -- 914
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 916
        end -- 916
    end, -- 906
    ["rect-fixture"] = bodyCheck, -- 919
    ["polygon-fixture"] = bodyCheck, -- 920
    ["multi-fixture"] = bodyCheck, -- 921
    ["disk-fixture"] = bodyCheck, -- 922
    ["chain-fixture"] = bodyCheck, -- 923
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 924
        local joint = enode.props -- 925
        if joint.ref == nil then -- 925
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 927
            return -- 928
        end -- 928
        if joint.bodyA.current == nil then -- 928
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 931
            return -- 932
        end -- 932
        if joint.bodyB.current == nil then -- 932
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 935
            return -- 936
        end -- 936
        local ____joint_ref_13 = joint.ref -- 938
        local ____self_11 = dora.Joint -- 938
        local ____self_11_distance_12 = ____self_11.distance -- 938
        local ____joint_canCollide_10 = joint.canCollide -- 939
        if ____joint_canCollide_10 == nil then -- 939
            ____joint_canCollide_10 = false -- 939
        end -- 939
        ____joint_ref_13.current = ____self_11_distance_12( -- 938
            ____self_11, -- 938
            ____joint_canCollide_10, -- 939
            joint.bodyA.current, -- 940
            joint.bodyB.current, -- 941
            joint.anchorA or dora.Vec2.zero, -- 942
            joint.anchorB or dora.Vec2.zero, -- 943
            joint.frequency or 0, -- 944
            joint.damping or 0 -- 945
        ) -- 945
    end, -- 924
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 947
        local joint = enode.props -- 948
        if joint.ref == nil then -- 948
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 950
            return -- 951
        end -- 951
        if joint.bodyA.current == nil then -- 951
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 954
            return -- 955
        end -- 955
        if joint.bodyB.current == nil then -- 955
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 958
            return -- 959
        end -- 959
        local ____joint_ref_17 = joint.ref -- 961
        local ____self_15 = dora.Joint -- 961
        local ____self_15_friction_16 = ____self_15.friction -- 961
        local ____joint_canCollide_14 = joint.canCollide -- 962
        if ____joint_canCollide_14 == nil then -- 962
            ____joint_canCollide_14 = false -- 962
        end -- 962
        ____joint_ref_17.current = ____self_15_friction_16( -- 961
            ____self_15, -- 961
            ____joint_canCollide_14, -- 962
            joint.bodyA.current, -- 963
            joint.bodyB.current, -- 964
            joint.worldPos, -- 965
            joint.maxForce, -- 966
            joint.maxTorque -- 967
        ) -- 967
    end, -- 947
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 970
        local joint = enode.props -- 971
        if joint.ref == nil then -- 971
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 973
            return -- 974
        end -- 974
        if joint.jointA.current == nil then -- 974
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 977
            return -- 978
        end -- 978
        if joint.jointB.current == nil then -- 978
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 981
            return -- 982
        end -- 982
        local ____joint_ref_21 = joint.ref -- 984
        local ____self_19 = dora.Joint -- 984
        local ____self_19_gear_20 = ____self_19.gear -- 984
        local ____joint_canCollide_18 = joint.canCollide -- 985
        if ____joint_canCollide_18 == nil then -- 985
            ____joint_canCollide_18 = false -- 985
        end -- 985
        ____joint_ref_21.current = ____self_19_gear_20( -- 984
            ____self_19, -- 984
            ____joint_canCollide_18, -- 985
            joint.jointA.current, -- 986
            joint.jointB.current, -- 987
            joint.ratio or 1 -- 988
        ) -- 988
    end, -- 970
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 991
        local joint = enode.props -- 992
        if joint.ref == nil then -- 992
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 994
            return -- 995
        end -- 995
        if joint.bodyA.current == nil then -- 995
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 998
            return -- 999
        end -- 999
        if joint.bodyB.current == nil then -- 999
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1002
            return -- 1003
        end -- 1003
        local ____joint_ref_25 = joint.ref -- 1005
        local ____self_23 = dora.Joint -- 1005
        local ____self_23_spring_24 = ____self_23.spring -- 1005
        local ____joint_canCollide_22 = joint.canCollide -- 1006
        if ____joint_canCollide_22 == nil then -- 1006
            ____joint_canCollide_22 = false -- 1006
        end -- 1006
        ____joint_ref_25.current = ____self_23_spring_24( -- 1005
            ____self_23, -- 1005
            ____joint_canCollide_22, -- 1006
            joint.bodyA.current, -- 1007
            joint.bodyB.current, -- 1008
            joint.linearOffset, -- 1009
            joint.angularOffset, -- 1010
            joint.maxForce, -- 1011
            joint.maxTorque, -- 1012
            joint.correctionFactor or 1 -- 1013
        ) -- 1013
    end, -- 991
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1016
        local joint = enode.props -- 1017
        if joint.ref == nil then -- 1017
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1019
            return -- 1020
        end -- 1020
        if joint.body.current == nil then -- 1020
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1023
            return -- 1024
        end -- 1024
        local ____joint_ref_29 = joint.ref -- 1026
        local ____self_27 = dora.Joint -- 1026
        local ____self_27_move_28 = ____self_27.move -- 1026
        local ____joint_canCollide_26 = joint.canCollide -- 1027
        if ____joint_canCollide_26 == nil then -- 1027
            ____joint_canCollide_26 = false -- 1027
        end -- 1027
        ____joint_ref_29.current = ____self_27_move_28( -- 1026
            ____self_27, -- 1026
            ____joint_canCollide_26, -- 1027
            joint.body.current, -- 1028
            joint.targetPos, -- 1029
            joint.maxForce, -- 1030
            joint.frequency, -- 1031
            joint.damping or 0.7 -- 1032
        ) -- 1032
    end, -- 1016
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1035
        local joint = enode.props -- 1036
        if joint.ref == nil then -- 1036
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1038
            return -- 1039
        end -- 1039
        if joint.bodyA.current == nil then -- 1039
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1042
            return -- 1043
        end -- 1043
        if joint.bodyB.current == nil then -- 1043
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1046
            return -- 1047
        end -- 1047
        local ____joint_ref_33 = joint.ref -- 1049
        local ____self_31 = dora.Joint -- 1049
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1049
        local ____joint_canCollide_30 = joint.canCollide -- 1050
        if ____joint_canCollide_30 == nil then -- 1050
            ____joint_canCollide_30 = false -- 1050
        end -- 1050
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1049
            ____self_31, -- 1049
            ____joint_canCollide_30, -- 1050
            joint.bodyA.current, -- 1051
            joint.bodyB.current, -- 1052
            joint.worldPos, -- 1053
            joint.axisAngle, -- 1054
            joint.lowerTranslation or 0, -- 1055
            joint.upperTranslation or 0, -- 1056
            joint.maxMotorForce or 0, -- 1057
            joint.motorSpeed or 0 -- 1058
        ) -- 1058
    end, -- 1035
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1061
        local joint = enode.props -- 1062
        if joint.ref == nil then -- 1062
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1064
            return -- 1065
        end -- 1065
        if joint.bodyA.current == nil then -- 1065
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1068
            return -- 1069
        end -- 1069
        if joint.bodyB.current == nil then -- 1069
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1072
            return -- 1073
        end -- 1073
        local ____joint_ref_37 = joint.ref -- 1075
        local ____self_35 = dora.Joint -- 1075
        local ____self_35_pulley_36 = ____self_35.pulley -- 1075
        local ____joint_canCollide_34 = joint.canCollide -- 1076
        if ____joint_canCollide_34 == nil then -- 1076
            ____joint_canCollide_34 = false -- 1076
        end -- 1076
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1075
            ____self_35, -- 1075
            ____joint_canCollide_34, -- 1076
            joint.bodyA.current, -- 1077
            joint.bodyB.current, -- 1078
            joint.anchorA or dora.Vec2.zero, -- 1079
            joint.anchorB or dora.Vec2.zero, -- 1080
            joint.groundAnchorA, -- 1081
            joint.groundAnchorB, -- 1082
            joint.ratio or 1 -- 1083
        ) -- 1083
    end, -- 1061
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1086
        local joint = enode.props -- 1087
        if joint.ref == nil then -- 1087
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1089
            return -- 1090
        end -- 1090
        if joint.bodyA.current == nil then -- 1090
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1093
            return -- 1094
        end -- 1094
        if joint.bodyB.current == nil then -- 1094
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1097
            return -- 1098
        end -- 1098
        local ____joint_ref_41 = joint.ref -- 1100
        local ____self_39 = dora.Joint -- 1100
        local ____self_39_revolute_40 = ____self_39.revolute -- 1100
        local ____joint_canCollide_38 = joint.canCollide -- 1101
        if ____joint_canCollide_38 == nil then -- 1101
            ____joint_canCollide_38 = false -- 1101
        end -- 1101
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1100
            ____self_39, -- 1100
            ____joint_canCollide_38, -- 1101
            joint.bodyA.current, -- 1102
            joint.bodyB.current, -- 1103
            joint.worldPos, -- 1104
            joint.lowerAngle or 0, -- 1105
            joint.upperAngle or 0, -- 1106
            joint.maxMotorTorque or 0, -- 1107
            joint.motorSpeed or 0 -- 1108
        ) -- 1108
    end, -- 1086
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1111
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
        local ____joint_ref_45 = joint.ref -- 1125
        local ____self_43 = dora.Joint -- 1125
        local ____self_43_rope_44 = ____self_43.rope -- 1125
        local ____joint_canCollide_42 = joint.canCollide -- 1126
        if ____joint_canCollide_42 == nil then -- 1126
            ____joint_canCollide_42 = false -- 1126
        end -- 1126
        ____joint_ref_45.current = ____self_43_rope_44( -- 1125
            ____self_43, -- 1125
            ____joint_canCollide_42, -- 1126
            joint.bodyA.current, -- 1127
            joint.bodyB.current, -- 1128
            joint.anchorA or dora.Vec2.zero, -- 1129
            joint.anchorB or dora.Vec2.zero, -- 1130
            joint.maxLength or 0 -- 1131
        ) -- 1131
    end, -- 1111
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1134
        local joint = enode.props -- 1135
        if joint.ref == nil then -- 1135
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1137
            return -- 1138
        end -- 1138
        if joint.bodyA.current == nil then -- 1138
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1141
            return -- 1142
        end -- 1142
        if joint.bodyB.current == nil then -- 1142
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1145
            return -- 1146
        end -- 1146
        local ____joint_ref_49 = joint.ref -- 1148
        local ____self_47 = dora.Joint -- 1148
        local ____self_47_weld_48 = ____self_47.weld -- 1148
        local ____joint_canCollide_46 = joint.canCollide -- 1149
        if ____joint_canCollide_46 == nil then -- 1149
            ____joint_canCollide_46 = false -- 1149
        end -- 1149
        ____joint_ref_49.current = ____self_47_weld_48( -- 1148
            ____self_47, -- 1148
            ____joint_canCollide_46, -- 1149
            joint.bodyA.current, -- 1150
            joint.bodyB.current, -- 1151
            joint.worldPos, -- 1152
            joint.frequency or 0, -- 1153
            joint.damping or 0 -- 1154
        ) -- 1154
    end, -- 1134
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1157
        local joint = enode.props -- 1158
        if joint.ref == nil then -- 1158
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1160
            return -- 1161
        end -- 1161
        if joint.bodyA.current == nil then -- 1161
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1164
            return -- 1165
        end -- 1165
        if joint.bodyB.current == nil then -- 1165
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1168
            return -- 1169
        end -- 1169
        local ____joint_ref_53 = joint.ref -- 1171
        local ____self_51 = dora.Joint -- 1171
        local ____self_51_wheel_52 = ____self_51.wheel -- 1171
        local ____joint_canCollide_50 = joint.canCollide -- 1172
        if ____joint_canCollide_50 == nil then -- 1172
            ____joint_canCollide_50 = false -- 1172
        end -- 1172
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1171
            ____self_51, -- 1171
            ____joint_canCollide_50, -- 1172
            joint.bodyA.current, -- 1173
            joint.bodyB.current, -- 1174
            joint.worldPos, -- 1175
            joint.axisAngle, -- 1176
            joint.maxMotorTorque or 0, -- 1177
            joint.motorSpeed or 0, -- 1178
            joint.frequency or 0, -- 1179
            joint.damping or 0.7 -- 1180
        ) -- 1180
    end, -- 1157
    ["custom-node"] = function(nodeStack, enode, parent) -- 1183
        local node = getCustomNode(enode) -- 1184
        if node ~= nil then -- 1184
            addChild(nodeStack, node, enode) -- 1186
        end -- 1186
    end -- 1183
} -- 1183
function ____exports.useRef(item) -- 1231
    local ____item_54 = item -- 1232
    if ____item_54 == nil then -- 1232
        ____item_54 = nil -- 1232
    end -- 1232
    return {current = ____item_54} -- 1232
end -- 1231
local function getPreload(preloadList, node) -- 1235
    if type(node) ~= "table" then -- 1235
        return -- 1237
    end -- 1237
    local enode = node -- 1239
    if enode.type == nil then -- 1239
        local list = node -- 1241
        if #list > 0 then -- 1241
            for i = 1, #list do -- 1241
                getPreload(preloadList, list[i]) -- 1244
            end -- 1244
        end -- 1244
    else -- 1244
        repeat -- 1244
            local ____switch269 = enode.type -- 1244
            local sprite, playable, model, spine, dragonBone, label -- 1244
            local ____cond269 = ____switch269 == "sprite" -- 1244
            if ____cond269 then -- 1244
                sprite = enode.props -- 1250
                preloadList[#preloadList + 1] = sprite.file -- 1251
                break -- 1252
            end -- 1252
            ____cond269 = ____cond269 or ____switch269 == "playable" -- 1252
            if ____cond269 then -- 1252
                playable = enode.props -- 1254
                preloadList[#preloadList + 1] = playable.file -- 1255
                break -- 1256
            end -- 1256
            ____cond269 = ____cond269 or ____switch269 == "model" -- 1256
            if ____cond269 then -- 1256
                model = enode.props -- 1258
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1259
                break -- 1260
            end -- 1260
            ____cond269 = ____cond269 or ____switch269 == "spine" -- 1260
            if ____cond269 then -- 1260
                spine = enode.props -- 1262
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1263
                break -- 1264
            end -- 1264
            ____cond269 = ____cond269 or ____switch269 == "dragon-bone" -- 1264
            if ____cond269 then -- 1264
                dragonBone = enode.props -- 1266
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1267
                break -- 1268
            end -- 1268
            ____cond269 = ____cond269 or ____switch269 == "label" -- 1268
            if ____cond269 then -- 1268
                label = enode.props -- 1270
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1271
                break -- 1272
            end -- 1272
        until true -- 1272
    end -- 1272
    getPreload(preloadList, enode.children) -- 1275
end -- 1235
function ____exports.preloadAsync(enode, handler) -- 1278
    local preloadList = {} -- 1279
    getPreload(preloadList, enode) -- 1280
    dora.Cache:loadAsync(preloadList, handler) -- 1281
end -- 1278
return ____exports -- 1278
