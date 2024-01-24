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
    Warn("[Dora Warning] " .. msg) -- 13
end -- 13
function visitNode(nodeStack, node, parent) -- 1161
    if type(node) ~= "table" then -- 1161
        return -- 1163
    end -- 1163
    local enode = node -- 1165
    if enode.type == nil then -- 1165
        local list = node -- 1167
        if #list > 0 then -- 1167
            for i = 1, #list do -- 1167
                local stack = {} -- 1170
                visitNode(stack, list[i], parent) -- 1171
                for i = 1, #stack do -- 1171
                    nodeStack[#nodeStack + 1] = stack[i] -- 1173
                end -- 1173
            end -- 1173
        end -- 1173
    else -- 1173
        local handler = elementMap[enode.type] -- 1178
        if handler ~= nil then -- 1178
            handler(nodeStack, enode, parent) -- 1180
        else -- 1180
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1182
        end -- 1182
    end -- 1182
end -- 1182
function ____exports.toNode(enode) -- 1187
    local nodeStack = {} -- 1188
    visitNode(nodeStack, enode) -- 1189
    if #nodeStack == 1 then -- 1189
        return nodeStack[1] -- 1191
    elseif #nodeStack > 1 then -- 1191
        local node = dora.Node() -- 1193
        for i = 1, #nodeStack do -- 1193
            node:addChild(nodeStack[i]) -- 1195
        end -- 1195
        return node -- 1197
    end -- 1197
    return nil -- 1199
end -- 1187
____exports.React = {} -- 1187
local React = ____exports.React -- 1187
do -- 1187
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
                    local item = typeName(nil, props) -- 73
                    item.props.children = nil -- 74
                    return item -- 75
                end -- 75
            end -- 75
            ____cond14 = ____cond14 or ____switch14 == "table" -- 75
            if ____cond14 then -- 75
                do -- 75
                    if not typeName.isComponent then -- 75
                        Warn("unsupported class object in element creation") -- 79
                        return {} -- 80
                    end -- 80
                    if props == nil then -- 80
                        props = {} -- 82
                    end -- 82
                    if props.children then -- 82
                        local ____props_3 = props -- 84
                        local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 84
                        __TS__SparseArrayPush( -- 84
                            ____array_2, -- 84
                            table.unpack(children) -- 84
                        ) -- 84
                        ____props_3.children = {__TS__SparseArraySpread(____array_2)} -- 84
                    else -- 84
                        props.children = children -- 86
                    end -- 86
                    local inst = __TS__New(typeName, props) -- 88
                    return inst:render() -- 89
                end -- 89
            end -- 89
            do -- 89
                do -- 89
                    if props and props.children then -- 89
                        local ____array_4 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 89
                        __TS__SparseArrayPush( -- 89
                            ____array_4, -- 89
                            table.unpack(children) -- 93
                        ) -- 93
                        children = {__TS__SparseArraySpread(____array_4)} -- 93
                        props.children = nil -- 94
                    end -- 94
                    local flatChildren = {} -- 96
                    for i = 1, #children do -- 96
                        local child, flat = flattenChild(children[i]) -- 98
                        if flat then -- 98
                            flatChildren[#flatChildren + 1] = child -- 100
                        else -- 100
                            for i = 1, #child do -- 100
                                flatChildren[#flatChildren + 1] = child[i] -- 103
                            end -- 103
                        end -- 103
                    end -- 103
                    children = flatChildren -- 107
                end -- 107
            end -- 107
        until true -- 107
        if typeName == nil then -- 107
            return children -- 111
        end -- 111
        return {type = typeName, props = props, children = children} -- 113
    end -- 60
end -- 60
local function getNode(enode, cnode, attribHandler) -- 124
    cnode = cnode or dora.Node() -- 125
    local jnode = enode.props -- 126
    local anchor = nil -- 127
    local color3 = nil -- 128
    if jnode ~= nil then -- 128
        for k, v in pairs(enode.props) do -- 130
            repeat -- 130
                local ____switch32 = k -- 130
                local ____cond32 = ____switch32 == "ref" -- 130
                if ____cond32 then -- 130
                    v.current = cnode -- 132
                    break -- 132
                end -- 132
                ____cond32 = ____cond32 or ____switch32 == "anchorX" -- 132
                if ____cond32 then -- 132
                    anchor = dora.Vec2(v, (anchor or cnode.anchor).y) -- 133
                    break -- 133
                end -- 133
                ____cond32 = ____cond32 or ____switch32 == "anchorY" -- 133
                if ____cond32 then -- 133
                    anchor = dora.Vec2((anchor or cnode.anchor).x, v) -- 134
                    break -- 134
                end -- 134
                ____cond32 = ____cond32 or ____switch32 == "color3" -- 134
                if ____cond32 then -- 134
                    color3 = dora.Color3(v) -- 135
                    break -- 135
                end -- 135
                ____cond32 = ____cond32 or ____switch32 == "transformTarget" -- 135
                if ____cond32 then -- 135
                    cnode.transformTarget = v.current -- 136
                    break -- 136
                end -- 136
                ____cond32 = ____cond32 or ____switch32 == "onUpdate" -- 136
                if ____cond32 then -- 136
                    cnode:schedule(v) -- 137
                    break -- 137
                end -- 137
                ____cond32 = ____cond32 or ____switch32 == "onActionEnd" -- 137
                if ____cond32 then -- 137
                    cnode:slot("ActionEnd", v) -- 138
                    break -- 138
                end -- 138
                ____cond32 = ____cond32 or ____switch32 == "onTapFilter" -- 138
                if ____cond32 then -- 138
                    cnode:slot("TapFilter", v) -- 139
                    break -- 139
                end -- 139
                ____cond32 = ____cond32 or ____switch32 == "onTapBegan" -- 139
                if ____cond32 then -- 139
                    cnode:slot("TapBegan", v) -- 140
                    break -- 140
                end -- 140
                ____cond32 = ____cond32 or ____switch32 == "onTapEnded" -- 140
                if ____cond32 then -- 140
                    cnode:slot("TapEnded", v) -- 141
                    break -- 141
                end -- 141
                ____cond32 = ____cond32 or ____switch32 == "onTapped" -- 141
                if ____cond32 then -- 141
                    cnode:slot("Tapped", v) -- 142
                    break -- 142
                end -- 142
                ____cond32 = ____cond32 or ____switch32 == "onTapMoved" -- 142
                if ____cond32 then -- 142
                    cnode:slot("TapMoved", v) -- 143
                    break -- 143
                end -- 143
                ____cond32 = ____cond32 or ____switch32 == "onMouseWheel" -- 143
                if ____cond32 then -- 143
                    cnode:slot("MouseWheel", v) -- 144
                    break -- 144
                end -- 144
                ____cond32 = ____cond32 or ____switch32 == "onGesture" -- 144
                if ____cond32 then -- 144
                    cnode:slot("Gesture", v) -- 145
                    break -- 145
                end -- 145
                ____cond32 = ____cond32 or ____switch32 == "onEnter" -- 145
                if ____cond32 then -- 145
                    cnode:slot("Enter", v) -- 146
                    break -- 146
                end -- 146
                ____cond32 = ____cond32 or ____switch32 == "onExit" -- 146
                if ____cond32 then -- 146
                    cnode:slot("Exit", v) -- 147
                    break -- 147
                end -- 147
                ____cond32 = ____cond32 or ____switch32 == "onCleanup" -- 147
                if ____cond32 then -- 147
                    cnode:slot("Cleanup", v) -- 148
                    break -- 148
                end -- 148
                ____cond32 = ____cond32 or ____switch32 == "onKeyDown" -- 148
                if ____cond32 then -- 148
                    cnode:slot("KeyDown", v) -- 149
                    break -- 149
                end -- 149
                ____cond32 = ____cond32 or ____switch32 == "onKeyUp" -- 149
                if ____cond32 then -- 149
                    cnode:slot("KeyUp", v) -- 150
                    break -- 150
                end -- 150
                ____cond32 = ____cond32 or ____switch32 == "onKeyPressed" -- 150
                if ____cond32 then -- 150
                    cnode:slot("KeyPressed", v) -- 151
                    break -- 151
                end -- 151
                ____cond32 = ____cond32 or ____switch32 == "onAttachIME" -- 151
                if ____cond32 then -- 151
                    cnode:slot("AttachIME", v) -- 152
                    break -- 152
                end -- 152
                ____cond32 = ____cond32 or ____switch32 == "onDetachIME" -- 152
                if ____cond32 then -- 152
                    cnode:slot("DetachIME", v) -- 153
                    break -- 153
                end -- 153
                ____cond32 = ____cond32 or ____switch32 == "onTextInput" -- 153
                if ____cond32 then -- 153
                    cnode:slot("TextInput", v) -- 154
                    break -- 154
                end -- 154
                ____cond32 = ____cond32 or ____switch32 == "onTextEditing" -- 154
                if ____cond32 then -- 154
                    cnode:slot("TextEditing", v) -- 155
                    break -- 155
                end -- 155
                ____cond32 = ____cond32 or ____switch32 == "onButtonDown" -- 155
                if ____cond32 then -- 155
                    cnode:slot("ButtonDown", v) -- 156
                    break -- 156
                end -- 156
                ____cond32 = ____cond32 or ____switch32 == "onButtonUp" -- 156
                if ____cond32 then -- 156
                    cnode:slot("ButtonUp", v) -- 157
                    break -- 157
                end -- 157
                ____cond32 = ____cond32 or ____switch32 == "onAxis" -- 157
                if ____cond32 then -- 157
                    cnode:slot("Axis", v) -- 158
                    break -- 158
                end -- 158
                do -- 158
                    do -- 158
                        if attribHandler then -- 158
                            if not attribHandler(cnode, enode, k, v) then -- 158
                                cnode[k] = v -- 162
                            end -- 162
                        else -- 162
                            cnode[k] = v -- 165
                        end -- 165
                        break -- 167
                    end -- 167
                end -- 167
            until true -- 167
        end -- 167
        if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 167
            cnode.touchEnabled = true -- 180
        end -- 180
        if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 180
            cnode.keyboardEnabled = true -- 187
        end -- 187
        if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 187
            cnode.controllerEnabled = true -- 194
        end -- 194
    end -- 194
    if anchor ~= nil then -- 194
        cnode.anchor = anchor -- 197
    end -- 197
    if color3 ~= nil then -- 197
        cnode.color3 = color3 -- 198
    end -- 198
    if jnode.onMount ~= nil then -- 198
        jnode.onMount(cnode) -- 200
    end -- 200
    return cnode -- 202
end -- 124
local getClipNode -- 205
do -- 205
    local function handleClipNodeAttribute(cnode, _enode, k, v) -- 207
        repeat -- 207
            local ____switch45 = k -- 207
            local ____cond45 = ____switch45 == "stencil" -- 207
            if ____cond45 then -- 207
                cnode.stencil = ____exports.toNode(v) -- 214
                return true -- 214
            end -- 214
        until true -- 214
        return false -- 216
    end -- 207
    getClipNode = function(enode) -- 218
        return getNode( -- 219
            enode, -- 219
            dora.ClipNode(), -- 219
            handleClipNodeAttribute -- 219
        ) -- 219
    end -- 218
end -- 218
local getPlayable -- 223
local getDragonBone -- 224
local getSpine -- 225
local getModel -- 226
do -- 226
    local function handlePlayableAttribute(cnode, enode, k, v) -- 228
        repeat -- 228
            local ____switch49 = k -- 228
            local ____cond49 = ____switch49 == "file" -- 228
            if ____cond49 then -- 228
                return true -- 230
            end -- 230
            ____cond49 = ____cond49 or ____switch49 == "play" -- 230
            if ____cond49 then -- 230
                cnode:play(v, enode.props.loop == true) -- 231
                return true -- 231
            end -- 231
            ____cond49 = ____cond49 or ____switch49 == "loop" -- 231
            if ____cond49 then -- 231
                return true -- 232
            end -- 232
            ____cond49 = ____cond49 or ____switch49 == "onAnimationEnd" -- 232
            if ____cond49 then -- 232
                cnode:slot("AnimationEnd", v) -- 233
                return true -- 233
            end -- 233
        until true -- 233
        return false -- 235
    end -- 228
    getPlayable = function(enode, cnode, attribHandler) -- 237
        if attribHandler == nil then -- 237
            attribHandler = handlePlayableAttribute -- 238
        end -- 238
        cnode = cnode or dora.Playable(enode.props.file) or nil -- 239
        if cnode ~= nil then -- 239
            return getNode(enode, cnode, attribHandler) -- 241
        end -- 241
        return nil -- 243
    end -- 237
    local function handleDragonBoneAttribute(cnode, enode, k, v) -- 246
        repeat -- 246
            local ____switch53 = k -- 246
            local ____cond53 = ____switch53 == "showDebug" -- 246
            if ____cond53 then -- 246
                cnode.showDebug = v -- 248
                return true -- 248
            end -- 248
            ____cond53 = ____cond53 or ____switch53 == "hitTestEnabled" -- 248
            if ____cond53 then -- 248
                cnode.hitTestEnabled = true -- 249
                return true -- 249
            end -- 249
        until true -- 249
        return handlePlayableAttribute(cnode, enode, k, v) -- 251
    end -- 246
    getDragonBone = function(enode) -- 253
        local node = dora.DragonBone(enode.props.file) -- 254
        if node ~= nil then -- 254
            local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 256
            return cnode -- 257
        end -- 257
        return nil -- 259
    end -- 253
    local function handleSpineAttribute(cnode, enode, k, v) -- 262
        repeat -- 262
            local ____switch57 = k -- 262
            local ____cond57 = ____switch57 == "showDebug" -- 262
            if ____cond57 then -- 262
                cnode.showDebug = v -- 264
                return true -- 264
            end -- 264
            ____cond57 = ____cond57 or ____switch57 == "hitTestEnabled" -- 264
            if ____cond57 then -- 264
                cnode.hitTestEnabled = true -- 265
                return true -- 265
            end -- 265
        until true -- 265
        return handlePlayableAttribute(cnode, enode, k, v) -- 267
    end -- 262
    getSpine = function(enode) -- 269
        local node = dora.Spine(enode.props.file) -- 270
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
        local node = dora.Model(enode.props.file) -- 285
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
        local node = dora.DrawNode() -- 304
        local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 305
        local ____enode_5 = enode -- 306
        local children = ____enode_5.children -- 306
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
                                dora.Vec2(dot.x, dot.y), -- 316
                                dot.radius, -- 317
                                dora.Color(dot.color or 4294967295) -- 318
                            ) -- 318
                            break -- 320
                        end -- 320
                    end -- 320
                    ____cond70 = ____cond70 or ____switch70 == "segment-shape" -- 320
                    if ____cond70 then -- 320
                        do -- 320
                            local segment = child.props -- 323
                            node:drawSegment( -- 324
                                dora.Vec2(segment.startX, segment.startY), -- 325
                                dora.Vec2(segment.stopX, segment.stopY), -- 326
                                segment.radius, -- 327
                                dora.Color(segment.color or 4294967295) -- 328
                            ) -- 328
                            break -- 330
                        end -- 330
                    end -- 330
                    ____cond70 = ____cond70 or ____switch70 == "polygon-shape" -- 330
                    if ____cond70 then -- 330
                        do -- 330
                            local poly = child.props -- 333
                            node:drawPolygon( -- 334
                                poly.verts, -- 335
                                dora.Color(poly.fillColor or 4294967295), -- 336
                                poly.borderWidth or 0, -- 337
                                dora.Color(poly.borderColor or 4294967295) -- 338
                            ) -- 338
                            break -- 340
                        end -- 340
                    end -- 340
                    ____cond70 = ____cond70 or ____switch70 == "verts-shape" -- 340
                    if ____cond70 then -- 340
                        do -- 340
                            local verts = child.props -- 343
                            node:drawVertices(__TS__ArrayMap( -- 344
                                verts.verts, -- 344
                                function(____, ____bindingPattern0) -- 344
                                    local color -- 344
                                    local vert -- 344
                                    vert = ____bindingPattern0[1] -- 344
                                    color = ____bindingPattern0[2] -- 344
                                    return { -- 344
                                        vert, -- 344
                                        dora.Color(color) -- 344
                                    } -- 344
                                end -- 344
                            )) -- 344
                            break -- 345
                        end -- 345
                    end -- 345
                until true -- 345
            end -- 345
            ::__continue68:: -- 345
        end -- 345
        return cnode -- 349
    end -- 303
end -- 303
local getGrid -- 353
do -- 353
    local function handleGridAttribute(cnode, _enode, k, v) -- 355
        repeat -- 355
            local ____switch78 = k -- 355
            local ____cond78 = ____switch78 == "file" or ____switch78 == "gridX" or ____switch78 == "gridY" -- 355
            if ____cond78 then -- 355
                return true -- 357
            end -- 357
            ____cond78 = ____cond78 or ____switch78 == "textureRect" -- 357
            if ____cond78 then -- 357
                cnode.textureRect = v -- 358
                return true -- 358
            end -- 358
            ____cond78 = ____cond78 or ____switch78 == "depthWrite" -- 358
            if ____cond78 then -- 358
                cnode.depthWrite = v -- 359
                return true -- 359
            end -- 359
            ____cond78 = ____cond78 or ____switch78 == "blendFunc" -- 359
            if ____cond78 then -- 359
                cnode.blendFunc = v -- 360
                return true -- 360
            end -- 360
            ____cond78 = ____cond78 or ____switch78 == "effect" -- 360
            if ____cond78 then -- 360
                cnode.effect = v -- 361
                return true -- 361
            end -- 361
        until true -- 361
        return false -- 363
    end -- 355
    getGrid = function(enode) -- 365
        local grid = enode.props -- 366
        local node = dora.Grid(grid.file, grid.gridX, grid.gridY) -- 367
        local cnode = getNode(enode, node, handleGridAttribute) -- 368
        return cnode -- 369
    end -- 365
end -- 365
local getSprite -- 373
do -- 373
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 375
        repeat -- 375
            local ____switch82 = k -- 375
            local ____cond82 = ____switch82 == "file" -- 375
            if ____cond82 then -- 375
                return true -- 377
            end -- 377
            ____cond82 = ____cond82 or ____switch82 == "textureRect" -- 377
            if ____cond82 then -- 377
                cnode.textureRect = v -- 378
                return true -- 378
            end -- 378
            ____cond82 = ____cond82 or ____switch82 == "depthWrite" -- 378
            if ____cond82 then -- 378
                cnode.depthWrite = v -- 379
                return true -- 379
            end -- 379
            ____cond82 = ____cond82 or ____switch82 == "blendFunc" -- 379
            if ____cond82 then -- 379
                cnode.blendFunc = v -- 380
                return true -- 380
            end -- 380
            ____cond82 = ____cond82 or ____switch82 == "effect" -- 380
            if ____cond82 then -- 380
                cnode.effect = v -- 381
                return true -- 381
            end -- 381
            ____cond82 = ____cond82 or ____switch82 == "alphaRef" -- 381
            if ____cond82 then -- 381
                cnode.alphaRef = v -- 382
                return true -- 382
            end -- 382
            ____cond82 = ____cond82 or ____switch82 == "uwrap" -- 382
            if ____cond82 then -- 382
                cnode.uwrap = v -- 383
                return true -- 383
            end -- 383
            ____cond82 = ____cond82 or ____switch82 == "vwrap" -- 383
            if ____cond82 then -- 383
                cnode.vwrap = v -- 384
                return true -- 384
            end -- 384
            ____cond82 = ____cond82 or ____switch82 == "filter" -- 384
            if ____cond82 then -- 384
                cnode.filter = v -- 385
                return true -- 385
            end -- 385
        until true -- 385
        return false -- 387
    end -- 375
    getSprite = function(enode) -- 389
        local sp = enode.props -- 390
        local node = dora.Sprite(sp.file) -- 391
        if node ~= nil then -- 391
            local cnode = getNode(enode, node, handleSpriteAttribute) -- 393
            return cnode -- 394
        end -- 394
        return nil -- 396
    end -- 389
end -- 389
local getLabel -- 400
do -- 400
    local function handleLabelAttribute(cnode, _enode, k, v) -- 402
        repeat -- 402
            local ____switch87 = k -- 402
            local ____cond87 = ____switch87 == "fontName" or ____switch87 == "fontSize" or ____switch87 == "text" -- 402
            if ____cond87 then -- 402
                return true -- 404
            end -- 404
            ____cond87 = ____cond87 or ____switch87 == "alphaRef" -- 404
            if ____cond87 then -- 404
                cnode.alphaRef = v -- 405
                return true -- 405
            end -- 405
            ____cond87 = ____cond87 or ____switch87 == "textWidth" -- 405
            if ____cond87 then -- 405
                cnode.textWidth = v -- 406
                return true -- 406
            end -- 406
            ____cond87 = ____cond87 or ____switch87 == "lineGap" -- 406
            if ____cond87 then -- 406
                cnode.lineGap = v -- 407
                return true -- 407
            end -- 407
            ____cond87 = ____cond87 or ____switch87 == "blendFunc" -- 407
            if ____cond87 then -- 407
                cnode.blendFunc = v -- 408
                return true -- 408
            end -- 408
            ____cond87 = ____cond87 or ____switch87 == "depthWrite" -- 408
            if ____cond87 then -- 408
                cnode.depthWrite = v -- 409
                return true -- 409
            end -- 409
            ____cond87 = ____cond87 or ____switch87 == "batched" -- 409
            if ____cond87 then -- 409
                cnode.batched = v -- 410
                return true -- 410
            end -- 410
            ____cond87 = ____cond87 or ____switch87 == "effect" -- 410
            if ____cond87 then -- 410
                cnode.effect = v -- 411
                return true -- 411
            end -- 411
            ____cond87 = ____cond87 or ____switch87 == "alignment" -- 411
            if ____cond87 then -- 411
                cnode.alignment = v -- 412
                return true -- 412
            end -- 412
        until true -- 412
        return false -- 414
    end -- 402
    getLabel = function(enode) -- 416
        local label = enode.props -- 417
        local node = dora.Label(label.fontName, label.fontSize) -- 418
        if node ~= nil then -- 418
            local cnode = getNode(enode, node, handleLabelAttribute) -- 420
            local ____enode_6 = enode -- 421
            local children = ____enode_6.children -- 421
            local text = label.text or "" -- 422
            for i = 1, #children do -- 422
                local child = children[i] -- 424
                if type(child) ~= "table" then -- 424
                    text = text .. tostring(child) -- 426
                end -- 426
            end -- 426
            node.text = text -- 429
            return cnode -- 430
        end -- 430
        return nil -- 432
    end -- 416
end -- 416
local getLine -- 436
do -- 436
    local function handleLineAttribute(cnode, enode, k, v) -- 438
        local line = enode.props -- 439
        repeat -- 439
            local ____switch94 = k -- 439
            local ____cond94 = ____switch94 == "verts" -- 439
            if ____cond94 then -- 439
                cnode:set( -- 441
                    v, -- 441
                    dora.Color(line.lineColor or 4294967295) -- 441
                ) -- 441
                return true -- 441
            end -- 441
            ____cond94 = ____cond94 or ____switch94 == "depthWrite" -- 441
            if ____cond94 then -- 441
                cnode.depthWrite = v -- 442
                return true -- 442
            end -- 442
            ____cond94 = ____cond94 or ____switch94 == "blendFunc" -- 442
            if ____cond94 then -- 442
                cnode.blendFunc = v -- 443
                return true -- 443
            end -- 443
        until true -- 443
        return false -- 445
    end -- 438
    getLine = function(enode) -- 447
        local node = dora.Line() -- 448
        local cnode = getNode(enode, node, handleLineAttribute) -- 449
        return cnode -- 450
    end -- 447
end -- 447
local getParticle -- 454
do -- 454
    local function handleParticleAttribute(cnode, _enode, k, v) -- 456
        repeat -- 456
            local ____switch98 = k -- 456
            local ____cond98 = ____switch98 == "file" -- 456
            if ____cond98 then -- 456
                return true -- 458
            end -- 458
            ____cond98 = ____cond98 or ____switch98 == "emit" -- 458
            if ____cond98 then -- 458
                if v then -- 458
                    cnode:start() -- 459
                end -- 459
                return true -- 459
            end -- 459
            ____cond98 = ____cond98 or ____switch98 == "onFinished" -- 459
            if ____cond98 then -- 459
                cnode:slot("Finished", v) -- 460
                return true -- 460
            end -- 460
        until true -- 460
        return false -- 462
    end -- 456
    getParticle = function(enode) -- 464
        local particle = enode.props -- 465
        local node = dora.Particle(particle.file) -- 466
        if node ~= nil then -- 466
            local cnode = getNode(enode, node, handleParticleAttribute) -- 468
            return cnode -- 469
        end -- 469
        return nil -- 471
    end -- 464
end -- 464
local getMenu -- 475
do -- 475
    local function handleMenuAttribute(cnode, _enode, k, v) -- 477
        repeat -- 477
            local ____switch104 = k -- 477
            local ____cond104 = ____switch104 == "enabled" -- 477
            if ____cond104 then -- 477
                cnode.enabled = v -- 479
                return true -- 479
            end -- 479
        until true -- 479
        return false -- 481
    end -- 477
    getMenu = function(enode) -- 483
        local node = dora.Menu() -- 484
        local cnode = getNode(enode, node, handleMenuAttribute) -- 485
        return cnode -- 486
    end -- 483
end -- 483
local getPhysicsWorld -- 490
do -- 490
    local function handlePhysicsWorldAttribute(cnode, _enode, k, v) -- 492
        repeat -- 492
            local ____switch108 = k -- 492
            local ____cond108 = ____switch108 == "showDebug" -- 492
            if ____cond108 then -- 492
                cnode.showDebug = v -- 494
                return true -- 494
            end -- 494
        until true -- 494
        return false -- 496
    end -- 492
    getPhysicsWorld = function(enode) -- 498
        local node = dora.PhysicsWorld() -- 499
        local cnode = getNode(enode, node, handlePhysicsWorldAttribute) -- 500
        return cnode -- 501
    end -- 498
end -- 498
local getBody -- 505
do -- 505
    local function handleBodyAttribute(cnode, _enode, k, v) -- 507
        repeat -- 507
            local ____switch112 = k -- 507
            local ____cond112 = ____switch112 == "type" or ____switch112 == "linearAcceleration" or ____switch112 == "fixedRotation" or ____switch112 == "bullet" -- 507
            if ____cond112 then -- 507
                return true -- 513
            end -- 513
            ____cond112 = ____cond112 or ____switch112 == "velocityX" -- 513
            if ____cond112 then -- 513
                cnode.velocityX = v -- 514
                return true -- 514
            end -- 514
            ____cond112 = ____cond112 or ____switch112 == "velocityY" -- 514
            if ____cond112 then -- 514
                cnode.velocityY = v -- 515
                return true -- 515
            end -- 515
            ____cond112 = ____cond112 or ____switch112 == "angularRate" -- 515
            if ____cond112 then -- 515
                cnode.angularRate = v -- 516
                return true -- 516
            end -- 516
            ____cond112 = ____cond112 or ____switch112 == "group" -- 516
            if ____cond112 then -- 516
                cnode.group = v -- 517
                return true -- 517
            end -- 517
            ____cond112 = ____cond112 or ____switch112 == "linearDamping" -- 517
            if ____cond112 then -- 517
                cnode.linearDamping = v -- 518
                return true -- 518
            end -- 518
            ____cond112 = ____cond112 or ____switch112 == "angularDamping" -- 518
            if ____cond112 then -- 518
                cnode.angularDamping = v -- 519
                return true -- 519
            end -- 519
            ____cond112 = ____cond112 or ____switch112 == "owner" -- 519
            if ____cond112 then -- 519
                cnode.owner = v -- 520
                return true -- 520
            end -- 520
            ____cond112 = ____cond112 or ____switch112 == "receivingContact" -- 520
            if ____cond112 then -- 520
                cnode.receivingContact = v -- 521
                return true -- 521
            end -- 521
            ____cond112 = ____cond112 or ____switch112 == "onBodyEnter" -- 521
            if ____cond112 then -- 521
                cnode:slot("BodyEnter", v) -- 522
                return true -- 522
            end -- 522
            ____cond112 = ____cond112 or ____switch112 == "onBodyLeave" -- 522
            if ____cond112 then -- 522
                cnode:slot("BodyLeave", v) -- 523
                return true -- 523
            end -- 523
            ____cond112 = ____cond112 or ____switch112 == "onContactStart" -- 523
            if ____cond112 then -- 523
                cnode:slot("ContactStart", v) -- 524
                return true -- 524
            end -- 524
            ____cond112 = ____cond112 or ____switch112 == "onContactEnd" -- 524
            if ____cond112 then -- 524
                cnode:slot("ContactEnd", v) -- 525
                return true -- 525
            end -- 525
            ____cond112 = ____cond112 or ____switch112 == "onContactFilter" -- 525
            if ____cond112 then -- 525
                cnode:onContactFilter(v) -- 526
                return true -- 526
            end -- 526
        until true -- 526
        return false -- 528
    end -- 507
    getBody = function(enode, world) -- 530
        local def = enode.props -- 531
        local bodyDef = dora.BodyDef() -- 532
        bodyDef.type = def.type -- 533
        if def.angle ~= nil then -- 533
            bodyDef.angle = def.angle -- 534
        end -- 534
        if def.angularDamping ~= nil then -- 534
            bodyDef.angularDamping = def.angularDamping -- 535
        end -- 535
        if def.bullet ~= nil then -- 535
            bodyDef.bullet = def.bullet -- 536
        end -- 536
        if def.fixedRotation ~= nil then -- 536
            bodyDef.fixedRotation = def.fixedRotation -- 537
        end -- 537
        if def.linearAcceleration ~= nil then -- 537
            bodyDef.linearAcceleration = def.linearAcceleration -- 538
        end -- 538
        if def.linearDamping ~= nil then -- 538
            bodyDef.linearDamping = def.linearDamping -- 539
        end -- 539
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 540
        local extraSensors = nil -- 541
        for i = 1, #enode.children do -- 541
            do -- 541
                local child = enode.children[i] -- 543
                if type(child) ~= "table" then -- 543
                    goto __continue120 -- 545
                end -- 545
                repeat -- 545
                    local ____switch122 = child.type -- 545
                    local ____cond122 = ____switch122 == "rect-fixture" -- 545
                    if ____cond122 then -- 545
                        do -- 545
                            local shape = child.props -- 549
                            if shape.sensorTag ~= nil then -- 549
                                bodyDef:attachPolygonSensor( -- 551
                                    shape.sensorTag, -- 552
                                    shape.width, -- 553
                                    shape.height, -- 553
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 554
                                    shape.angle or 0 -- 555
                                ) -- 555
                            else -- 555
                                bodyDef:attachPolygon( -- 558
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 559
                                    shape.width, -- 560
                                    shape.height, -- 560
                                    shape.angle or 0, -- 561
                                    shape.density or 0, -- 562
                                    shape.friction or 0.4, -- 563
                                    shape.restitution or 0 -- 564
                                ) -- 564
                            end -- 564
                            break -- 567
                        end -- 567
                    end -- 567
                    ____cond122 = ____cond122 or ____switch122 == "polygon-fixture" -- 567
                    if ____cond122 then -- 567
                        do -- 567
                            local shape = child.props -- 570
                            if shape.sensorTag ~= nil then -- 570
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 572
                            else -- 572
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 577
                            end -- 577
                            break -- 584
                        end -- 584
                    end -- 584
                    ____cond122 = ____cond122 or ____switch122 == "multi-fixture" -- 584
                    if ____cond122 then -- 584
                        do -- 584
                            local shape = child.props -- 587
                            if shape.sensorTag ~= nil then -- 587
                                if extraSensors == nil then -- 587
                                    extraSensors = {} -- 589
                                end -- 589
                                extraSensors[#extraSensors + 1] = { -- 590
                                    shape.sensorTag, -- 590
                                    dora.BodyDef:multi(shape.verts) -- 590
                                } -- 590
                            else -- 590
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 592
                            end -- 592
                            break -- 599
                        end -- 599
                    end -- 599
                    ____cond122 = ____cond122 or ____switch122 == "disk-fixture" -- 599
                    if ____cond122 then -- 599
                        do -- 599
                            local shape = child.props -- 602
                            if shape.sensorTag ~= nil then -- 602
                                bodyDef:attachDiskSensor( -- 604
                                    shape.sensorTag, -- 605
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 606
                                    shape.radius -- 607
                                ) -- 607
                            else -- 607
                                bodyDef:attachDisk( -- 610
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 611
                                    shape.radius, -- 612
                                    shape.density or 0, -- 613
                                    shape.friction or 0.4, -- 614
                                    shape.restitution or 0 -- 615
                                ) -- 615
                            end -- 615
                            break -- 618
                        end -- 618
                    end -- 618
                    ____cond122 = ____cond122 or ____switch122 == "chain-fixture" -- 618
                    if ____cond122 then -- 618
                        do -- 618
                            local shape = child.props -- 621
                            if shape.sensorTag ~= nil then -- 621
                                if extraSensors == nil then -- 621
                                    extraSensors = {} -- 623
                                end -- 623
                                extraSensors[#extraSensors + 1] = { -- 624
                                    shape.sensorTag, -- 624
                                    dora.BodyDef:chain(shape.verts) -- 624
                                } -- 624
                            else -- 624
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 626
                            end -- 626
                            break -- 632
                        end -- 632
                    end -- 632
                until true -- 632
            end -- 632
            ::__continue120:: -- 632
        end -- 632
        local body = dora.Body(bodyDef, world) -- 636
        if extraSensors ~= nil then -- 636
            for i = 1, #extraSensors do -- 636
                local tag, def = table.unpack(extraSensors[i]) -- 639
                body:attachSensor(tag, def) -- 640
            end -- 640
        end -- 640
        local cnode = getNode(enode, body, handleBodyAttribute) -- 643
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 643
            body.receivingContact = true -- 650
        end -- 650
        return cnode -- 652
    end -- 530
end -- 530
local function addChild(nodeStack, cnode, enode) -- 656
    if #nodeStack > 0 then -- 656
        local last = nodeStack[#nodeStack] -- 658
        last:addChild(cnode) -- 659
    end -- 659
    nodeStack[#nodeStack + 1] = cnode -- 661
    local ____enode_7 = enode -- 662
    local children = ____enode_7.children -- 662
    for i = 1, #children do -- 662
        visitNode(nodeStack, children[i], enode) -- 664
    end -- 664
    if #nodeStack > 1 then -- 664
        table.remove(nodeStack) -- 667
    end -- 667
end -- 656
local function drawNodeCheck(_nodeStack, enode, parent) -- 675
    if parent == nil or parent.type ~= "draw-node" then -- 675
        Warn(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 677
    end -- 677
end -- 675
local function actionCheck(_nodeStack, enode, parent) -- 681
    local unsupported = false -- 682
    if parent == nil then -- 682
        unsupported = true -- 684
    else -- 684
        repeat -- 684
            local ____switch150 = enode.type -- 684
            local ____cond150 = ____switch150 == "action" or ____switch150 == "spawn" or ____switch150 == "sequence" -- 684
            if ____cond150 then -- 684
                break -- 687
            end -- 687
            do -- 687
                unsupported = true -- 688
                break -- 688
            end -- 688
        until true -- 688
    end -- 688
    if unsupported then -- 688
        Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 692
    end -- 692
end -- 681
local function bodyCheck(_nodeStack, enode, parent) -- 696
    if parent == nil or parent.type ~= "body" then -- 696
        Warn(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 698
    end -- 698
end -- 696
local actionMap = { -- 702
    ["anchor-x"] = dora.AnchorX, -- 705
    ["anchor-y"] = dora.AnchorY, -- 706
    angle = dora.Angle, -- 707
    ["angle-x"] = dora.AngleX, -- 708
    ["angle-y"] = dora.AngleY, -- 709
    width = dora.Width, -- 710
    height = dora.Height, -- 711
    opacity = dora.Opacity, -- 712
    roll = dora.Roll, -- 713
    scale = dora.Scale, -- 714
    ["scale-x"] = dora.ScaleX, -- 715
    ["scale-y"] = dora.ScaleY, -- 716
    ["skew-x"] = dora.SkewX, -- 717
    ["skew-y"] = dora.SkewY, -- 718
    ["move-x"] = dora.X, -- 719
    ["move-y"] = dora.Y, -- 720
    ["move-z"] = dora.Z -- 721
} -- 721
elementMap = { -- 724
    node = function(nodeStack, enode, parent) -- 725
        addChild( -- 726
            nodeStack, -- 726
            getNode(enode), -- 726
            enode -- 726
        ) -- 726
    end, -- 725
    ["clip-node"] = function(nodeStack, enode, parent) -- 728
        addChild( -- 729
            nodeStack, -- 729
            getClipNode(enode), -- 729
            enode -- 729
        ) -- 729
    end, -- 728
    playable = function(nodeStack, enode, parent) -- 731
        local cnode = getPlayable(enode) -- 732
        if cnode ~= nil then -- 732
            addChild(nodeStack, cnode, enode) -- 734
        end -- 734
    end, -- 731
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 737
        local cnode = getDragonBone(enode) -- 738
        if cnode ~= nil then -- 738
            addChild(nodeStack, cnode, enode) -- 740
        end -- 740
    end, -- 737
    spine = function(nodeStack, enode, parent) -- 743
        local cnode = getSpine(enode) -- 744
        if cnode ~= nil then -- 744
            addChild(nodeStack, cnode, enode) -- 746
        end -- 746
    end, -- 743
    model = function(nodeStack, enode, parent) -- 749
        local cnode = getModel(enode) -- 750
        if cnode ~= nil then -- 750
            addChild(nodeStack, cnode, enode) -- 752
        end -- 752
    end, -- 749
    ["draw-node"] = function(nodeStack, enode, parent) -- 755
        addChild( -- 756
            nodeStack, -- 756
            getDrawNode(enode), -- 756
            enode -- 756
        ) -- 756
    end, -- 755
    ["dot-shape"] = drawNodeCheck, -- 758
    ["segment-shape"] = drawNodeCheck, -- 759
    ["polygon-shape"] = drawNodeCheck, -- 760
    ["verts-shape"] = drawNodeCheck, -- 761
    grid = function(nodeStack, enode, parent) -- 762
        addChild( -- 763
            nodeStack, -- 763
            getGrid(enode), -- 763
            enode -- 763
        ) -- 763
    end, -- 762
    sprite = function(nodeStack, enode, parent) -- 765
        local cnode = getSprite(enode) -- 766
        if cnode ~= nil then -- 766
            addChild(nodeStack, cnode, enode) -- 768
        end -- 768
    end, -- 765
    label = function(nodeStack, enode, parent) -- 771
        local cnode = getLabel(enode) -- 772
        if cnode ~= nil then -- 772
            addChild(nodeStack, cnode, enode) -- 774
        end -- 774
    end, -- 771
    line = function(nodeStack, enode, parent) -- 777
        addChild( -- 778
            nodeStack, -- 778
            getLine(enode), -- 778
            enode -- 778
        ) -- 778
    end, -- 777
    particle = function(nodeStack, enode, parent) -- 780
        local cnode = getParticle(enode) -- 781
        if cnode ~= nil then -- 781
            addChild(nodeStack, cnode, enode) -- 783
        end -- 783
    end, -- 780
    menu = function(nodeStack, enode, parent) -- 786
        addChild( -- 787
            nodeStack, -- 787
            getMenu(enode), -- 787
            enode -- 787
        ) -- 787
    end, -- 786
    action = function(_nodeStack, enode, parent) -- 789
        if #enode.children == 0 then -- 789
            return -- 790
        end -- 790
        local action = enode.props -- 791
        if action.ref == nil then -- 791
            return -- 792
        end -- 792
        local function visitAction(actionStack, enode) -- 793
            local createAction = actionMap[enode.type] -- 794
            if createAction ~= nil then -- 794
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 796
                return -- 797
            end -- 797
            repeat -- 797
                local ____switch179 = enode.type -- 797
                local ____cond179 = ____switch179 == "delay" -- 797
                if ____cond179 then -- 797
                    do -- 797
                        local item = enode.props -- 801
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 802
                        return -- 803
                    end -- 803
                end -- 803
                ____cond179 = ____cond179 or ____switch179 == "event" -- 803
                if ____cond179 then -- 803
                    do -- 803
                        local item = enode.props -- 806
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 807
                        return -- 808
                    end -- 808
                end -- 808
                ____cond179 = ____cond179 or ____switch179 == "hide" -- 808
                if ____cond179 then -- 808
                    do -- 808
                        actionStack[#actionStack + 1] = dora.Hide() -- 811
                        return -- 812
                    end -- 812
                end -- 812
                ____cond179 = ____cond179 or ____switch179 == "show" -- 812
                if ____cond179 then -- 812
                    do -- 812
                        actionStack[#actionStack + 1] = dora.Show() -- 815
                        return -- 816
                    end -- 816
                end -- 816
                ____cond179 = ____cond179 or ____switch179 == "move" -- 816
                if ____cond179 then -- 816
                    do -- 816
                        local item = enode.props -- 819
                        actionStack[#actionStack + 1] = dora.Move( -- 820
                            item.time, -- 820
                            dora.Vec2(item.startX, item.startY), -- 820
                            dora.Vec2(item.stopX, item.stopY), -- 820
                            item.easing -- 820
                        ) -- 820
                        return -- 821
                    end -- 821
                end -- 821
                ____cond179 = ____cond179 or ____switch179 == "spawn" -- 821
                if ____cond179 then -- 821
                    do -- 821
                        local spawnStack = {} -- 824
                        for i = 1, #enode.children do -- 824
                            visitAction(spawnStack, enode.children[i]) -- 826
                        end -- 826
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 828
                    end -- 828
                end -- 828
                ____cond179 = ____cond179 or ____switch179 == "sequence" -- 828
                if ____cond179 then -- 828
                    do -- 828
                        local sequenceStack = {} -- 831
                        for i = 1, #enode.children do -- 831
                            visitAction(sequenceStack, enode.children[i]) -- 833
                        end -- 833
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 835
                    end -- 835
                end -- 835
                do -- 835
                    Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 838
                    break -- 839
                end -- 839
            until true -- 839
        end -- 793
        local actionStack = {} -- 842
        for i = 1, #enode.children do -- 842
            visitAction(actionStack, enode.children[i]) -- 844
        end -- 844
        if #actionStack == 1 then -- 844
            action.ref.current = actionStack[1] -- 847
        elseif #actionStack > 1 then -- 847
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 849
        end -- 849
    end, -- 789
    ["anchor-x"] = actionCheck, -- 852
    ["anchor-y"] = actionCheck, -- 853
    angle = actionCheck, -- 854
    ["angle-x"] = actionCheck, -- 855
    ["angle-y"] = actionCheck, -- 856
    delay = actionCheck, -- 857
    event = actionCheck, -- 858
    width = actionCheck, -- 859
    height = actionCheck, -- 860
    hide = actionCheck, -- 861
    show = actionCheck, -- 862
    move = actionCheck, -- 863
    opacity = actionCheck, -- 864
    roll = actionCheck, -- 865
    scale = actionCheck, -- 866
    ["scale-x"] = actionCheck, -- 867
    ["scale-y"] = actionCheck, -- 868
    ["skew-x"] = actionCheck, -- 869
    ["skew-y"] = actionCheck, -- 870
    ["move-x"] = actionCheck, -- 871
    ["move-y"] = actionCheck, -- 872
    ["move-z"] = actionCheck, -- 873
    spawn = actionCheck, -- 874
    sequence = actionCheck, -- 875
    ["physics-world"] = function(nodeStack, enode, _parent) -- 876
        addChild( -- 877
            nodeStack, -- 877
            getPhysicsWorld(enode), -- 877
            enode -- 877
        ) -- 877
    end, -- 876
    contact = function(nodeStack, enode, _parent) -- 879
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 880
        if world ~= nil then -- 880
            local contact = enode.props -- 882
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 883
        else -- 883
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 885
        end -- 885
    end, -- 879
    body = function(nodeStack, enode, _parent) -- 888
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 889
        if world ~= nil then -- 889
            addChild( -- 891
                nodeStack, -- 891
                getBody(enode, world), -- 891
                enode -- 891
            ) -- 891
        else -- 891
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 893
        end -- 893
    end, -- 888
    ["rect-fixture"] = bodyCheck, -- 896
    ["polygon-fixture"] = bodyCheck, -- 897
    ["multi-fixture"] = bodyCheck, -- 898
    ["disk-fixture"] = bodyCheck, -- 899
    ["chain-fixture"] = bodyCheck, -- 900
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 901
        local joint = enode.props -- 902
        if joint.ref == nil then -- 902
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 904
            return -- 905
        end -- 905
        if joint.bodyA.current == nil then -- 905
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 908
            return -- 909
        end -- 909
        if joint.bodyB.current == nil then -- 909
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 912
            return -- 913
        end -- 913
        local ____joint_ref_11 = joint.ref -- 915
        local ____self_9 = dora.Joint -- 915
        local ____self_9_distance_10 = ____self_9.distance -- 915
        local ____joint_canCollide_8 = joint.canCollide -- 916
        if ____joint_canCollide_8 == nil then -- 916
            ____joint_canCollide_8 = false -- 916
        end -- 916
        ____joint_ref_11.current = ____self_9_distance_10( -- 915
            ____self_9, -- 915
            ____joint_canCollide_8, -- 916
            joint.bodyA.current, -- 917
            joint.bodyB.current, -- 918
            joint.anchorA or dora.Vec2.zero, -- 919
            joint.anchorB or dora.Vec2.zero, -- 920
            joint.frequency or 0, -- 921
            joint.damping or 0 -- 922
        ) -- 922
    end, -- 901
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 924
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
        local ____joint_ref_15 = joint.ref -- 938
        local ____self_13 = dora.Joint -- 938
        local ____self_13_friction_14 = ____self_13.friction -- 938
        local ____joint_canCollide_12 = joint.canCollide -- 939
        if ____joint_canCollide_12 == nil then -- 939
            ____joint_canCollide_12 = false -- 939
        end -- 939
        ____joint_ref_15.current = ____self_13_friction_14( -- 938
            ____self_13, -- 938
            ____joint_canCollide_12, -- 939
            joint.bodyA.current, -- 940
            joint.bodyB.current, -- 941
            joint.worldPos, -- 942
            joint.maxForce, -- 943
            joint.maxTorque -- 944
        ) -- 944
    end, -- 924
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 947
        local joint = enode.props -- 948
        if joint.ref == nil then -- 948
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 950
            return -- 951
        end -- 951
        if joint.jointA.current == nil then -- 951
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 954
            return -- 955
        end -- 955
        if joint.jointB.current == nil then -- 955
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 958
            return -- 959
        end -- 959
        local ____joint_ref_19 = joint.ref -- 961
        local ____self_17 = dora.Joint -- 961
        local ____self_17_gear_18 = ____self_17.gear -- 961
        local ____joint_canCollide_16 = joint.canCollide -- 962
        if ____joint_canCollide_16 == nil then -- 962
            ____joint_canCollide_16 = false -- 962
        end -- 962
        ____joint_ref_19.current = ____self_17_gear_18( -- 961
            ____self_17, -- 961
            ____joint_canCollide_16, -- 962
            joint.jointA.current, -- 963
            joint.jointB.current, -- 964
            joint.ratio or 1 -- 965
        ) -- 965
    end, -- 947
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 968
        local joint = enode.props -- 969
        if joint.ref == nil then -- 969
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 971
            return -- 972
        end -- 972
        if joint.bodyA.current == nil then -- 972
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 975
            return -- 976
        end -- 976
        if joint.bodyB.current == nil then -- 976
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 979
            return -- 980
        end -- 980
        local ____joint_ref_23 = joint.ref -- 982
        local ____self_21 = dora.Joint -- 982
        local ____self_21_spring_22 = ____self_21.spring -- 982
        local ____joint_canCollide_20 = joint.canCollide -- 983
        if ____joint_canCollide_20 == nil then -- 983
            ____joint_canCollide_20 = false -- 983
        end -- 983
        ____joint_ref_23.current = ____self_21_spring_22( -- 982
            ____self_21, -- 982
            ____joint_canCollide_20, -- 983
            joint.bodyA.current, -- 984
            joint.bodyB.current, -- 985
            joint.linearOffset, -- 986
            joint.angularOffset, -- 987
            joint.maxForce, -- 988
            joint.maxTorque, -- 989
            joint.correctionFactor or 1 -- 990
        ) -- 990
    end, -- 968
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 993
        local joint = enode.props -- 994
        if joint.ref == nil then -- 994
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 996
            return -- 997
        end -- 997
        if joint.body.current == nil then -- 997
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1000
            return -- 1001
        end -- 1001
        local ____joint_ref_27 = joint.ref -- 1003
        local ____self_25 = dora.Joint -- 1003
        local ____self_25_move_26 = ____self_25.move -- 1003
        local ____joint_canCollide_24 = joint.canCollide -- 1004
        if ____joint_canCollide_24 == nil then -- 1004
            ____joint_canCollide_24 = false -- 1004
        end -- 1004
        ____joint_ref_27.current = ____self_25_move_26( -- 1003
            ____self_25, -- 1003
            ____joint_canCollide_24, -- 1004
            joint.body.current, -- 1005
            joint.targetPos, -- 1006
            joint.maxForce, -- 1007
            joint.frequency, -- 1008
            joint.damping or 0.7 -- 1009
        ) -- 1009
    end, -- 993
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1012
        local joint = enode.props -- 1013
        if joint.ref == nil then -- 1013
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1015
            return -- 1016
        end -- 1016
        if joint.bodyA.current == nil then -- 1016
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1019
            return -- 1020
        end -- 1020
        if joint.bodyB.current == nil then -- 1020
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1023
            return -- 1024
        end -- 1024
        local ____joint_ref_31 = joint.ref -- 1026
        local ____self_29 = dora.Joint -- 1026
        local ____self_29_prismatic_30 = ____self_29.prismatic -- 1026
        local ____joint_canCollide_28 = joint.canCollide -- 1027
        if ____joint_canCollide_28 == nil then -- 1027
            ____joint_canCollide_28 = false -- 1027
        end -- 1027
        ____joint_ref_31.current = ____self_29_prismatic_30( -- 1026
            ____self_29, -- 1026
            ____joint_canCollide_28, -- 1027
            joint.bodyA.current, -- 1028
            joint.bodyB.current, -- 1029
            joint.worldPos, -- 1030
            joint.axisAngle, -- 1031
            joint.lowerTranslation or 0, -- 1032
            joint.upperTranslation or 0, -- 1033
            joint.maxMotorForce or 0, -- 1034
            joint.motorSpeed or 0 -- 1035
        ) -- 1035
    end, -- 1012
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1038
        local joint = enode.props -- 1039
        if joint.ref == nil then -- 1039
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1041
            return -- 1042
        end -- 1042
        if joint.bodyA.current == nil then -- 1042
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1045
            return -- 1046
        end -- 1046
        if joint.bodyB.current == nil then -- 1046
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1049
            return -- 1050
        end -- 1050
        local ____joint_ref_35 = joint.ref -- 1052
        local ____self_33 = dora.Joint -- 1052
        local ____self_33_pulley_34 = ____self_33.pulley -- 1052
        local ____joint_canCollide_32 = joint.canCollide -- 1053
        if ____joint_canCollide_32 == nil then -- 1053
            ____joint_canCollide_32 = false -- 1053
        end -- 1053
        ____joint_ref_35.current = ____self_33_pulley_34( -- 1052
            ____self_33, -- 1052
            ____joint_canCollide_32, -- 1053
            joint.bodyA.current, -- 1054
            joint.bodyB.current, -- 1055
            joint.anchorA or dora.Vec2.zero, -- 1056
            joint.anchorB or dora.Vec2.zero, -- 1057
            joint.groundAnchorA, -- 1058
            joint.groundAnchorB, -- 1059
            joint.ratio or 1 -- 1060
        ) -- 1060
    end, -- 1038
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1063
        local joint = enode.props -- 1064
        if joint.ref == nil then -- 1064
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1066
            return -- 1067
        end -- 1067
        if joint.bodyA.current == nil then -- 1067
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1070
            return -- 1071
        end -- 1071
        if joint.bodyB.current == nil then -- 1071
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1074
            return -- 1075
        end -- 1075
        local ____joint_ref_39 = joint.ref -- 1077
        local ____self_37 = dora.Joint -- 1077
        local ____self_37_revolute_38 = ____self_37.revolute -- 1077
        local ____joint_canCollide_36 = joint.canCollide -- 1078
        if ____joint_canCollide_36 == nil then -- 1078
            ____joint_canCollide_36 = false -- 1078
        end -- 1078
        ____joint_ref_39.current = ____self_37_revolute_38( -- 1077
            ____self_37, -- 1077
            ____joint_canCollide_36, -- 1078
            joint.bodyA.current, -- 1079
            joint.bodyB.current, -- 1080
            joint.worldPos, -- 1081
            joint.lowerAngle or 0, -- 1082
            joint.upperAngle or 0, -- 1083
            joint.maxMotorTorque or 0, -- 1084
            joint.motorSpeed or 0 -- 1085
        ) -- 1085
    end, -- 1063
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1088
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
        local ____joint_ref_43 = joint.ref -- 1102
        local ____self_41 = dora.Joint -- 1102
        local ____self_41_rope_42 = ____self_41.rope -- 1102
        local ____joint_canCollide_40 = joint.canCollide -- 1103
        if ____joint_canCollide_40 == nil then -- 1103
            ____joint_canCollide_40 = false -- 1103
        end -- 1103
        ____joint_ref_43.current = ____self_41_rope_42( -- 1102
            ____self_41, -- 1102
            ____joint_canCollide_40, -- 1103
            joint.bodyA.current, -- 1104
            joint.bodyB.current, -- 1105
            joint.anchorA or dora.Vec2.zero, -- 1106
            joint.anchorB or dora.Vec2.zero, -- 1107
            joint.maxLength or 0 -- 1108
        ) -- 1108
    end, -- 1088
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1111
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
        local ____joint_ref_47 = joint.ref -- 1125
        local ____self_45 = dora.Joint -- 1125
        local ____self_45_weld_46 = ____self_45.weld -- 1125
        local ____joint_canCollide_44 = joint.canCollide -- 1126
        if ____joint_canCollide_44 == nil then -- 1126
            ____joint_canCollide_44 = false -- 1126
        end -- 1126
        ____joint_ref_47.current = ____self_45_weld_46( -- 1125
            ____self_45, -- 1125
            ____joint_canCollide_44, -- 1126
            joint.bodyA.current, -- 1127
            joint.bodyB.current, -- 1128
            joint.worldPos, -- 1129
            joint.frequency or 0, -- 1130
            joint.damping or 0 -- 1131
        ) -- 1131
    end, -- 1111
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1134
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
        local ____joint_ref_51 = joint.ref -- 1148
        local ____self_49 = dora.Joint -- 1148
        local ____self_49_wheel_50 = ____self_49.wheel -- 1148
        local ____joint_canCollide_48 = joint.canCollide -- 1149
        if ____joint_canCollide_48 == nil then -- 1149
            ____joint_canCollide_48 = false -- 1149
        end -- 1149
        ____joint_ref_51.current = ____self_49_wheel_50( -- 1148
            ____self_49, -- 1148
            ____joint_canCollide_48, -- 1149
            joint.bodyA.current, -- 1150
            joint.bodyB.current, -- 1151
            joint.worldPos, -- 1152
            joint.axisAngle, -- 1153
            joint.maxMotorTorque or 0, -- 1154
            joint.motorSpeed or 0, -- 1155
            joint.frequency or 0, -- 1156
            joint.damping or 0.7 -- 1157
        ) -- 1157
    end -- 1134
} -- 1134
function ____exports.useRef(item) -- 1202
    local ____item_52 = item -- 1203
    if ____item_52 == nil then -- 1203
        ____item_52 = nil -- 1203
    end -- 1203
    return {current = ____item_52} -- 1203
end -- 1202
local function getPreload(preloadList, node) -- 1206
    if type(node) ~= "table" then -- 1206
        return -- 1208
    end -- 1208
    local enode = node -- 1210
    if enode.type == nil then -- 1210
        local list = node -- 1212
        if #list > 0 then -- 1212
            for i = 1, #list do -- 1212
                getPreload(preloadList, list[i]) -- 1215
            end -- 1215
        end -- 1215
    else -- 1215
        repeat -- 1215
            local ____switch262 = enode.type -- 1215
            local sprite, playable, model, spine, dragonBone, label -- 1215
            local ____cond262 = ____switch262 == "sprite" -- 1215
            if ____cond262 then -- 1215
                sprite = enode.props -- 1221
                preloadList[#preloadList + 1] = sprite.file -- 1222
                break -- 1223
            end -- 1223
            ____cond262 = ____cond262 or ____switch262 == "playable" -- 1223
            if ____cond262 then -- 1223
                playable = enode.props -- 1225
                preloadList[#preloadList + 1] = playable.file -- 1226
                break -- 1227
            end -- 1227
            ____cond262 = ____cond262 or ____switch262 == "model" -- 1227
            if ____cond262 then -- 1227
                model = enode.props -- 1229
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1230
                break -- 1231
            end -- 1231
            ____cond262 = ____cond262 or ____switch262 == "spine" -- 1231
            if ____cond262 then -- 1231
                spine = enode.props -- 1233
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1234
                break -- 1235
            end -- 1235
            ____cond262 = ____cond262 or ____switch262 == "dragon-bone" -- 1235
            if ____cond262 then -- 1235
                dragonBone = enode.props -- 1237
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1238
                break -- 1239
            end -- 1239
            ____cond262 = ____cond262 or ____switch262 == "label" -- 1239
            if ____cond262 then -- 1239
                label = enode.props -- 1241
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1242
                break -- 1243
            end -- 1243
        until true -- 1243
    end -- 1243
    getPreload(preloadList, enode.children) -- 1246
end -- 1206
function ____exports.preloadAsync(enode, handler) -- 1249
    local preloadList = {} -- 1250
    getPreload(preloadList, enode) -- 1251
    dora.Cache:loadAsync(preloadList, handler) -- 1252
end -- 1249
return ____exports -- 1249
