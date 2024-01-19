-- [ts]: dora-x.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Spread = ____lualib.__TS__Spread -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local visitNode, elementMap -- 1
local dora = require("dora") -- 10
function visitNode(nodeStack, node, parent) -- 1114
    if type(node) ~= "table" then -- 1114
        return -- 1116
    end -- 1116
    local enode = node -- 1118
    if enode.type == nil then -- 1118
        local list = node -- 1120
        if #list > 0 then -- 1120
            for i = 1, #list do -- 1120
                local stack = {} -- 1123
                visitNode(stack, list[i], parent) -- 1124
                for i = 1, #stack do -- 1124
                    nodeStack[#nodeStack + 1] = stack[i] -- 1126
                end -- 1126
            end -- 1126
        end -- 1126
    else -- 1126
        local handler = elementMap[enode.type] -- 1131
        if handler ~= nil then -- 1131
            handler(nodeStack, enode, parent) -- 1133
        else -- 1133
            print(("unsupported tag <" .. enode.type) .. ">") -- 1135
        end -- 1135
    end -- 1135
end -- 1135
function ____exports.toNode(enode) -- 1140
    local nodeStack = {} -- 1141
    visitNode(nodeStack, enode) -- 1142
    if #nodeStack == 1 then -- 1142
        return nodeStack[1] -- 1144
    elseif #nodeStack > 1 then -- 1144
        local node = dora.Node() -- 1146
        for i = 1, #nodeStack do -- 1146
            node:addChild(nodeStack[i]) -- 1148
        end -- 1148
        return node -- 1150
    end -- 1150
    return nil -- 1152
end -- 1140
____exports.React = {} -- 1140
local React = ____exports.React -- 1140
do -- 1140
    local function flattenChild(child) -- 14
        if type(child) ~= "table" then -- 14
            return child, true -- 16
        end -- 16
        if child.type ~= nil then -- 16
            return child, true -- 19
        elseif child.children then -- 19
            child = child.children -- 21
        end -- 21
        local list = child -- 23
        local flatChildren = {} -- 24
        for i = 1, #list do -- 24
            local child, flat = flattenChild(list[i]) -- 26
            if flat then -- 26
                flatChildren[#flatChildren + 1] = child -- 28
            else -- 28
                local listChild = child -- 30
                for i = 1, #listChild do -- 30
                    flatChildren[#flatChildren + 1] = listChild[i] -- 32
                end -- 32
            end -- 32
        end -- 32
        return flatChildren, false -- 36
    end -- 14
    function React.createElement(self, ____type, props, ...) -- 45
        local children = {...} -- 45
        if type(____type) == "function" then -- 45
            if props.children then -- 45
                local ____props_1 = props -- 52
                local ____array_0 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 52
                __TS__SparseArrayPush(____array_0, ...) -- 52
                ____props_1.children = {__TS__SparseArraySpread(____array_0)} -- 52
            else -- 52
                props.children = children -- 54
            end -- 54
            local item = ____type(nil, props) -- 56
            item.props.children = nil -- 57
            return item -- 58
        else -- 58
            if props and props.children then -- 58
                local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 58
                __TS__SparseArrayPush( -- 58
                    ____array_2, -- 58
                    table.unpack(children) -- 61
                ) -- 61
                children = {__TS__SparseArraySpread(____array_2)} -- 61
                props.children = nil -- 62
            end -- 62
            local flatChildren = {} -- 64
            for i = 1, #children do -- 64
                local child, flat = flattenChild(children[i]) -- 66
                if flat then -- 66
                    flatChildren[#flatChildren + 1] = child -- 68
                else -- 68
                    for i = 1, #child do -- 68
                        flatChildren[#flatChildren + 1] = child[i] -- 71
                    end -- 71
                end -- 71
            end -- 71
            children = flatChildren -- 75
        end -- 75
        if ____type == nil then -- 75
            return children -- 78
        end -- 78
        return {type = ____type, props = props, children = children} -- 80
    end -- 45
end -- 45
local function getNode(self, enode, cnode, attribHandler) -- 91
    cnode = cnode or dora.Node() -- 92
    local jnode = enode.props -- 93
    local anchor = nil -- 94
    local color3 = nil -- 95
    if jnode ~= nil then -- 95
        for k, v in pairs(enode.props) do -- 97
            repeat -- 97
                local ____switch25 = k -- 97
                local ____cond25 = ____switch25 == "ref" -- 97
                if ____cond25 then -- 97
                    v.current = cnode -- 99
                    break -- 99
                end -- 99
                ____cond25 = ____cond25 or ____switch25 == "anchorX" -- 99
                if ____cond25 then -- 99
                    anchor = dora.Vec2(v, (anchor or cnode.anchor).y) -- 100
                    break -- 100
                end -- 100
                ____cond25 = ____cond25 or ____switch25 == "anchorY" -- 100
                if ____cond25 then -- 100
                    anchor = dora.Vec2((anchor or cnode.anchor).x, v) -- 101
                    break -- 101
                end -- 101
                ____cond25 = ____cond25 or ____switch25 == "color3" -- 101
                if ____cond25 then -- 101
                    color3 = dora.Color3(v) -- 102
                    break -- 102
                end -- 102
                ____cond25 = ____cond25 or ____switch25 == "transformTarget" -- 102
                if ____cond25 then -- 102
                    cnode.transformTarget = v.current -- 103
                    break -- 103
                end -- 103
                ____cond25 = ____cond25 or ____switch25 == "onUpdate" -- 103
                if ____cond25 then -- 103
                    cnode:schedule(v) -- 104
                    break -- 104
                end -- 104
                ____cond25 = ____cond25 or ____switch25 == "onActionEnd" -- 104
                if ____cond25 then -- 104
                    cnode:slot("ActionEnd", v) -- 105
                    break -- 105
                end -- 105
                ____cond25 = ____cond25 or ____switch25 == "onTapFilter" -- 105
                if ____cond25 then -- 105
                    cnode:slot("TapFilter", v) -- 106
                    break -- 106
                end -- 106
                ____cond25 = ____cond25 or ____switch25 == "onTapBegan" -- 106
                if ____cond25 then -- 106
                    cnode:slot("TapBegan", v) -- 107
                    break -- 107
                end -- 107
                ____cond25 = ____cond25 or ____switch25 == "onTapEnded" -- 107
                if ____cond25 then -- 107
                    cnode:slot("TapEnded", v) -- 108
                    break -- 108
                end -- 108
                ____cond25 = ____cond25 or ____switch25 == "onTapped" -- 108
                if ____cond25 then -- 108
                    cnode:slot("Tapped", v) -- 109
                    break -- 109
                end -- 109
                ____cond25 = ____cond25 or ____switch25 == "onTapMoved" -- 109
                if ____cond25 then -- 109
                    cnode:slot("TapMoved", v) -- 110
                    break -- 110
                end -- 110
                ____cond25 = ____cond25 or ____switch25 == "onMouseWheel" -- 110
                if ____cond25 then -- 110
                    cnode:slot("MouseWheel", v) -- 111
                    break -- 111
                end -- 111
                ____cond25 = ____cond25 or ____switch25 == "onGesture" -- 111
                if ____cond25 then -- 111
                    cnode:slot("Gesture", v) -- 112
                    break -- 112
                end -- 112
                ____cond25 = ____cond25 or ____switch25 == "onEnter" -- 112
                if ____cond25 then -- 112
                    cnode:slot("Enter", v) -- 113
                    break -- 113
                end -- 113
                ____cond25 = ____cond25 or ____switch25 == "onExit" -- 113
                if ____cond25 then -- 113
                    cnode:slot("Exit", v) -- 114
                    break -- 114
                end -- 114
                ____cond25 = ____cond25 or ____switch25 == "onCleanup" -- 114
                if ____cond25 then -- 114
                    cnode:slot("Cleanup", v) -- 115
                    break -- 115
                end -- 115
                ____cond25 = ____cond25 or ____switch25 == "onKeyDown" -- 115
                if ____cond25 then -- 115
                    cnode:slot("KeyDown", v) -- 116
                    break -- 116
                end -- 116
                ____cond25 = ____cond25 or ____switch25 == "onKeyUp" -- 116
                if ____cond25 then -- 116
                    cnode:slot("KeyUp", v) -- 117
                    break -- 117
                end -- 117
                ____cond25 = ____cond25 or ____switch25 == "onKeyPressed" -- 117
                if ____cond25 then -- 117
                    cnode:slot("KeyPressed", v) -- 118
                    break -- 118
                end -- 118
                ____cond25 = ____cond25 or ____switch25 == "onAttachIME" -- 118
                if ____cond25 then -- 118
                    cnode:slot("AttachIME", v) -- 119
                    break -- 119
                end -- 119
                ____cond25 = ____cond25 or ____switch25 == "onDetachIME" -- 119
                if ____cond25 then -- 119
                    cnode:slot("DetachIME", v) -- 120
                    break -- 120
                end -- 120
                ____cond25 = ____cond25 or ____switch25 == "onTextInput" -- 120
                if ____cond25 then -- 120
                    cnode:slot("TextInput", v) -- 121
                    break -- 121
                end -- 121
                ____cond25 = ____cond25 or ____switch25 == "onTextEditing" -- 121
                if ____cond25 then -- 121
                    cnode:slot("TextEditing", v) -- 122
                    break -- 122
                end -- 122
                ____cond25 = ____cond25 or ____switch25 == "onButtonDown" -- 122
                if ____cond25 then -- 122
                    cnode:slot("ButtonDown", v) -- 123
                    break -- 123
                end -- 123
                ____cond25 = ____cond25 or ____switch25 == "onButtonUp" -- 123
                if ____cond25 then -- 123
                    cnode:slot("ButtonUp", v) -- 124
                    break -- 124
                end -- 124
                ____cond25 = ____cond25 or ____switch25 == "onAxis" -- 124
                if ____cond25 then -- 124
                    cnode:slot("Axis", v) -- 125
                    break -- 125
                end -- 125
                do -- 125
                    do -- 125
                        if attribHandler then -- 125
                            if not attribHandler(cnode, enode, k, v) then -- 125
                                cnode[k] = v -- 129
                            end -- 129
                        else -- 129
                            cnode[k] = v -- 132
                        end -- 132
                        break -- 134
                    end -- 134
                end -- 134
            until true -- 134
        end -- 134
        if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 134
            cnode.touchEnabled = true -- 147
        end -- 147
        if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 147
            cnode.keyboardEnabled = true -- 154
        end -- 154
        if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 154
            cnode.controllerEnabled = true -- 161
        end -- 161
    end -- 161
    if anchor ~= nil then -- 161
        cnode.anchor = anchor -- 164
    end -- 164
    if color3 ~= nil then -- 164
        cnode.color3 = color3 -- 165
    end -- 165
    return cnode -- 166
end -- 91
local getClipNode -- 169
do -- 169
    local function handleClipNodeAttribute(cnode, _enode, k, v) -- 171
        repeat -- 171
            local ____switch37 = k -- 171
            local ____cond37 = ____switch37 == "stencil" -- 171
            if ____cond37 then -- 171
                cnode.stencil = ____exports.toNode(v) -- 178
                return true -- 178
            end -- 178
        until true -- 178
        return false -- 180
    end -- 171
    getClipNode = function(enode) -- 182
        return getNode( -- 183
            nil, -- 183
            enode, -- 183
            dora.ClipNode(), -- 183
            handleClipNodeAttribute -- 183
        ) -- 183
    end -- 182
end -- 182
local getPlayable -- 187
local getDragonBone -- 188
local getSpine -- 189
local getModel -- 190
do -- 190
    local function handlePlayableAttribute(cnode, enode, k, v) -- 192
        repeat -- 192
            local ____switch41 = k -- 192
            local ____cond41 = ____switch41 == "file" -- 192
            if ____cond41 then -- 192
                return true -- 194
            end -- 194
            ____cond41 = ____cond41 or ____switch41 == "play" -- 194
            if ____cond41 then -- 194
                cnode:play(v, enode.props.loop == true) -- 195
                return true -- 195
            end -- 195
            ____cond41 = ____cond41 or ____switch41 == "loop" -- 195
            if ____cond41 then -- 195
                return true -- 196
            end -- 196
            ____cond41 = ____cond41 or ____switch41 == "onAnimationEnd" -- 196
            if ____cond41 then -- 196
                cnode:slot("AnimationEnd", v) -- 197
                return true -- 197
            end -- 197
        until true -- 197
        return false -- 199
    end -- 192
    getPlayable = function(enode, cnode, attribHandler) -- 201
        if attribHandler == nil then -- 201
            attribHandler = handlePlayableAttribute -- 202
        end -- 202
        cnode = cnode or dora.Playable(enode.props.file) or nil -- 203
        if cnode ~= nil then -- 203
            return getNode(nil, enode, cnode, attribHandler) -- 205
        end -- 205
        return nil -- 207
    end -- 201
    local function handleDragonBoneAttribute(cnode, enode, k, v) -- 210
        repeat -- 210
            local ____switch45 = k -- 210
            local ____cond45 = ____switch45 == "showDebug" -- 210
            if ____cond45 then -- 210
                cnode.showDebug = v -- 212
                return true -- 212
            end -- 212
            ____cond45 = ____cond45 or ____switch45 == "hitTestEnabled" -- 212
            if ____cond45 then -- 212
                cnode.hitTestEnabled = true -- 213
                return true -- 213
            end -- 213
        until true -- 213
        return handlePlayableAttribute(cnode, enode, k, v) -- 215
    end -- 210
    getDragonBone = function(enode) -- 217
        local node = dora.DragonBone(enode.props.file) -- 218
        if node ~= nil then -- 218
            local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 220
            return cnode -- 221
        end -- 221
        return nil -- 223
    end -- 217
    local function handleSpineAttribute(cnode, enode, k, v) -- 226
        repeat -- 226
            local ____switch49 = k -- 226
            local ____cond49 = ____switch49 == "showDebug" -- 226
            if ____cond49 then -- 226
                cnode.showDebug = v -- 228
                return true -- 228
            end -- 228
            ____cond49 = ____cond49 or ____switch49 == "hitTestEnabled" -- 228
            if ____cond49 then -- 228
                cnode.hitTestEnabled = true -- 229
                return true -- 229
            end -- 229
        until true -- 229
        return handlePlayableAttribute(cnode, enode, k, v) -- 231
    end -- 226
    getSpine = function(enode) -- 233
        local node = dora.Spine(enode.props.file) -- 234
        if node ~= nil then -- 234
            local cnode = getPlayable(enode, node, handleSpineAttribute) -- 236
            return cnode -- 237
        end -- 237
        return nil -- 239
    end -- 233
    local function handleModelAttribute(cnode, enode, k, v) -- 242
        repeat -- 242
            local ____switch53 = k -- 242
            local ____cond53 = ____switch53 == "reversed" -- 242
            if ____cond53 then -- 242
                cnode.reversed = v -- 244
                return true -- 244
            end -- 244
        until true -- 244
        return handlePlayableAttribute(cnode, enode, k, v) -- 246
    end -- 242
    getModel = function(enode) -- 248
        local node = dora.Model(enode.props.file) -- 249
        if node ~= nil then -- 249
            local cnode = getPlayable(enode, node, handleModelAttribute) -- 251
            return cnode -- 252
        end -- 252
        return nil -- 254
    end -- 248
end -- 248
local getDrawNode -- 258
do -- 258
    local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 260
        repeat -- 260
            local ____switch58 = k -- 260
            local ____cond58 = ____switch58 == "depthWrite" -- 260
            if ____cond58 then -- 260
                cnode.depthWrite = v -- 262
                return true -- 262
            end -- 262
            ____cond58 = ____cond58 or ____switch58 == "blendFunc" -- 262
            if ____cond58 then -- 262
                cnode.blendFunc = v -- 263
                return true -- 263
            end -- 263
        until true -- 263
        return false -- 265
    end -- 260
    getDrawNode = function(enode) -- 267
        local node = dora.DrawNode() -- 268
        local cnode = getNode(nil, enode, node, handleDrawNodeAttribute) -- 269
        local ____enode_3 = enode -- 270
        local children = ____enode_3.children -- 270
        for i = 1, #children do -- 270
            do -- 270
                local child = children[i] -- 272
                if type(child) ~= "table" then -- 272
                    goto __continue60 -- 274
                end -- 274
                repeat -- 274
                    local ____switch62 = child.type -- 274
                    local ____cond62 = ____switch62 == "dot" -- 274
                    if ____cond62 then -- 274
                        do -- 274
                            local dot = child.props -- 278
                            node:drawDot( -- 279
                                dora.Vec2(dot.x, dot.y), -- 280
                                dot.radius, -- 281
                                dora.Color(dot.color or 4294967295) -- 282
                            ) -- 282
                            break -- 284
                        end -- 284
                    end -- 284
                    ____cond62 = ____cond62 or ____switch62 == "segment" -- 284
                    if ____cond62 then -- 284
                        do -- 284
                            local segment = child.props -- 287
                            node:drawSegment( -- 288
                                dora.Vec2(segment.startX, segment.startY), -- 289
                                dora.Vec2(segment.stopX, segment.stopY), -- 290
                                segment.radius, -- 291
                                dora.Color(segment.color or 4294967295) -- 292
                            ) -- 292
                            break -- 294
                        end -- 294
                    end -- 294
                    ____cond62 = ____cond62 or ____switch62 == "polygon" -- 294
                    if ____cond62 then -- 294
                        do -- 294
                            local poly = child.props -- 297
                            node:drawPolygon( -- 298
                                poly.verts, -- 299
                                dora.Color(poly.fillColor or 4294967295), -- 300
                                poly.borderWidth or 0, -- 301
                                dora.Color(poly.borderColor or 4294967295) -- 302
                            ) -- 302
                            break -- 304
                        end -- 304
                    end -- 304
                    ____cond62 = ____cond62 or ____switch62 == "verts" -- 304
                    if ____cond62 then -- 304
                        do -- 304
                            local verts = child.props -- 307
                            node:drawVertices(__TS__ArrayMap( -- 308
                                verts.verts, -- 308
                                function(____, ____bindingPattern0) -- 308
                                    local color -- 308
                                    local vert -- 308
                                    vert = ____bindingPattern0[1] -- 308
                                    color = ____bindingPattern0[2] -- 308
                                    return { -- 308
                                        vert, -- 308
                                        dora.Color(color) -- 308
                                    } -- 308
                                end -- 308
                            )) -- 308
                            break -- 309
                        end -- 309
                    end -- 309
                until true -- 309
            end -- 309
            ::__continue60:: -- 309
        end -- 309
        return cnode -- 313
    end -- 267
end -- 267
local getGrid -- 317
do -- 317
    local function handleGridAttribute(cnode, _enode, k, v) -- 319
        repeat -- 319
            local ____switch70 = k -- 319
            local ____cond70 = ____switch70 == "file" or ____switch70 == "gridX" or ____switch70 == "gridY" -- 319
            if ____cond70 then -- 319
                return true -- 321
            end -- 321
            ____cond70 = ____cond70 or ____switch70 == "textureRect" -- 321
            if ____cond70 then -- 321
                cnode.textureRect = v -- 322
                return true -- 322
            end -- 322
            ____cond70 = ____cond70 or ____switch70 == "depthWrite" -- 322
            if ____cond70 then -- 322
                cnode.depthWrite = v -- 323
                return true -- 323
            end -- 323
            ____cond70 = ____cond70 or ____switch70 == "blendFunc" -- 323
            if ____cond70 then -- 323
                cnode.blendFunc = v -- 324
                return true -- 324
            end -- 324
            ____cond70 = ____cond70 or ____switch70 == "effect" -- 324
            if ____cond70 then -- 324
                cnode.effect = v -- 325
                return true -- 325
            end -- 325
        until true -- 325
        return false -- 327
    end -- 319
    getGrid = function(enode) -- 329
        local grid = enode.props -- 330
        local node = dora.Grid(grid.file, grid.gridX, grid.gridY) -- 331
        local cnode = getNode(nil, enode, node, handleGridAttribute) -- 332
        return cnode -- 333
    end -- 329
end -- 329
local getSprite -- 337
do -- 337
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 339
        repeat -- 339
            local ____switch74 = k -- 339
            local ____cond74 = ____switch74 == "file" -- 339
            if ____cond74 then -- 339
                return true -- 341
            end -- 341
            ____cond74 = ____cond74 or ____switch74 == "textureRect" -- 341
            if ____cond74 then -- 341
                cnode.textureRect = v -- 342
                return true -- 342
            end -- 342
            ____cond74 = ____cond74 or ____switch74 == "depthWrite" -- 342
            if ____cond74 then -- 342
                cnode.depthWrite = v -- 343
                return true -- 343
            end -- 343
            ____cond74 = ____cond74 or ____switch74 == "blendFunc" -- 343
            if ____cond74 then -- 343
                cnode.blendFunc = v -- 344
                return true -- 344
            end -- 344
            ____cond74 = ____cond74 or ____switch74 == "effect" -- 344
            if ____cond74 then -- 344
                cnode.effect = v -- 345
                return true -- 345
            end -- 345
            ____cond74 = ____cond74 or ____switch74 == "alphaRef" -- 345
            if ____cond74 then -- 345
                cnode.alphaRef = v -- 346
                return true -- 346
            end -- 346
            ____cond74 = ____cond74 or ____switch74 == "uwrap" -- 346
            if ____cond74 then -- 346
                cnode.uwrap = v -- 347
                return true -- 347
            end -- 347
            ____cond74 = ____cond74 or ____switch74 == "vwrap" -- 347
            if ____cond74 then -- 347
                cnode.vwrap = v -- 348
                return true -- 348
            end -- 348
            ____cond74 = ____cond74 or ____switch74 == "filter" -- 348
            if ____cond74 then -- 348
                cnode.filter = v -- 349
                return true -- 349
            end -- 349
        until true -- 349
        return false -- 351
    end -- 339
    getSprite = function(enode) -- 353
        local sp = enode.props -- 354
        local node = dora.Sprite(sp.file) -- 355
        if node ~= nil then -- 355
            local cnode = getNode(nil, enode, node, handleSpriteAttribute) -- 357
            return cnode -- 358
        end -- 358
        return nil -- 360
    end -- 353
end -- 353
local getLabel -- 364
do -- 364
    local function handleLabelAttribute(cnode, _enode, k, v) -- 366
        repeat -- 366
            local ____switch79 = k -- 366
            local ____cond79 = ____switch79 == "fontName" or ____switch79 == "fontSize" or ____switch79 == "text" -- 366
            if ____cond79 then -- 366
                return true -- 368
            end -- 368
            ____cond79 = ____cond79 or ____switch79 == "alphaRef" -- 368
            if ____cond79 then -- 368
                cnode.alphaRef = v -- 369
                return true -- 369
            end -- 369
            ____cond79 = ____cond79 or ____switch79 == "textWidth" -- 369
            if ____cond79 then -- 369
                cnode.textWidth = v -- 370
                return true -- 370
            end -- 370
            ____cond79 = ____cond79 or ____switch79 == "lineGap" -- 370
            if ____cond79 then -- 370
                cnode.lineGap = v -- 371
                return true -- 371
            end -- 371
            ____cond79 = ____cond79 or ____switch79 == "blendFunc" -- 371
            if ____cond79 then -- 371
                cnode.blendFunc = v -- 372
                return true -- 372
            end -- 372
            ____cond79 = ____cond79 or ____switch79 == "depthWrite" -- 372
            if ____cond79 then -- 372
                cnode.depthWrite = v -- 373
                return true -- 373
            end -- 373
            ____cond79 = ____cond79 or ____switch79 == "batched" -- 373
            if ____cond79 then -- 373
                cnode.batched = v -- 374
                return true -- 374
            end -- 374
            ____cond79 = ____cond79 or ____switch79 == "effect" -- 374
            if ____cond79 then -- 374
                cnode.effect = v -- 375
                return true -- 375
            end -- 375
            ____cond79 = ____cond79 or ____switch79 == "alignment" -- 375
            if ____cond79 then -- 375
                cnode.alignment = v -- 376
                return true -- 376
            end -- 376
        until true -- 376
        return false -- 378
    end -- 366
    getLabel = function(enode) -- 380
        local label = enode.props -- 381
        local node = dora.Label(label.fontName, label.fontSize) -- 382
        if node ~= nil then -- 382
            local cnode = getNode(nil, enode, node, handleLabelAttribute) -- 384
            local ____enode_4 = enode -- 385
            local children = ____enode_4.children -- 385
            local text = label.text or "" -- 386
            for i = 1, #children do -- 386
                local child = children[i] -- 388
                if type(child) ~= "table" then -- 388
                    text = text .. tostring(child) -- 390
                end -- 390
            end -- 390
            node.text = text -- 393
            return cnode -- 394
        end -- 394
        return nil -- 396
    end -- 380
end -- 380
local getLine -- 400
do -- 400
    local function handleLineAttribute(cnode, enode, k, v) -- 402
        local line = enode.props -- 403
        repeat -- 403
            local ____switch86 = k -- 403
            local ____cond86 = ____switch86 == "verts" -- 403
            if ____cond86 then -- 403
                cnode:set( -- 405
                    v, -- 405
                    dora.Color(line.lineColor or 4294967295) -- 405
                ) -- 405
                return true -- 405
            end -- 405
            ____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 405
            if ____cond86 then -- 405
                cnode.depthWrite = v -- 406
                return true -- 406
            end -- 406
            ____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 406
            if ____cond86 then -- 406
                cnode.blendFunc = v -- 407
                return true -- 407
            end -- 407
        until true -- 407
        return false -- 409
    end -- 402
    getLine = function(enode) -- 411
        local node = dora.Line() -- 412
        local cnode = getNode(nil, enode, node, handleLineAttribute) -- 413
        return cnode -- 414
    end -- 411
end -- 411
local getParticle -- 418
do -- 418
    local function handleParticleAttribute(cnode, _enode, k, v) -- 420
        repeat -- 420
            local ____switch90 = k -- 420
            local ____cond90 = ____switch90 == "file" -- 420
            if ____cond90 then -- 420
                return true -- 422
            end -- 422
            ____cond90 = ____cond90 or ____switch90 == "emit" -- 422
            if ____cond90 then -- 422
                if v then -- 422
                    cnode:start() -- 423
                end -- 423
                return true -- 423
            end -- 423
            ____cond90 = ____cond90 or ____switch90 == "onFinished" -- 423
            if ____cond90 then -- 423
                cnode:slot("Finished", v) -- 424
                return true -- 424
            end -- 424
        until true -- 424
        return false -- 426
    end -- 420
    getParticle = function(enode) -- 428
        local particle = enode.props -- 429
        local node = dora.Particle(particle.file) -- 430
        if node ~= nil then -- 430
            local cnode = getNode(nil, enode, node, handleParticleAttribute) -- 432
            return cnode -- 433
        end -- 433
        return nil -- 435
    end -- 428
end -- 428
local getMenu -- 439
do -- 439
    local function handleMenuAttribute(cnode, _enode, k, v) -- 441
        repeat -- 441
            local ____switch96 = k -- 441
            local ____cond96 = ____switch96 == "enabled" -- 441
            if ____cond96 then -- 441
                cnode.enabled = v -- 443
                return true -- 443
            end -- 443
        until true -- 443
        return false -- 445
    end -- 441
    getMenu = function(enode) -- 447
        local node = dora.Menu() -- 448
        local cnode = getNode(nil, enode, node, handleMenuAttribute) -- 449
        return cnode -- 450
    end -- 447
end -- 447
local getPhysicsWorld -- 454
do -- 454
    local function handlePhysicsWorldAttribute(cnode, _enode, k, v) -- 456
        repeat -- 456
            local ____switch100 = k -- 456
            local ____cond100 = ____switch100 == "showDebug" -- 456
            if ____cond100 then -- 456
                cnode.showDebug = v -- 458
                return true -- 458
            end -- 458
        until true -- 458
        return false -- 460
    end -- 456
    getPhysicsWorld = function(enode) -- 462
        local node = dora.PhysicsWorld() -- 463
        local cnode = getNode(nil, enode, node, handlePhysicsWorldAttribute) -- 464
        return cnode -- 465
    end -- 462
end -- 462
local getBody -- 469
do -- 469
    local function handleBodyAttribute(cnode, _enode, k, v) -- 471
        repeat -- 471
            local ____switch104 = k -- 471
            local ____cond104 = ____switch104 == "type" or ____switch104 == "linearAcceleration" or ____switch104 == "fixedRotation" or ____switch104 == "bullet" -- 471
            if ____cond104 then -- 471
                return true -- 477
            end -- 477
            ____cond104 = ____cond104 or ____switch104 == "velocityX" -- 477
            if ____cond104 then -- 477
                cnode.velocityX = v -- 478
                return true -- 478
            end -- 478
            ____cond104 = ____cond104 or ____switch104 == "velocityY" -- 478
            if ____cond104 then -- 478
                cnode.velocityY = v -- 479
                return true -- 479
            end -- 479
            ____cond104 = ____cond104 or ____switch104 == "angularRate" -- 479
            if ____cond104 then -- 479
                cnode.angularRate = v -- 480
                return true -- 480
            end -- 480
            ____cond104 = ____cond104 or ____switch104 == "group" -- 480
            if ____cond104 then -- 480
                cnode.group = v -- 481
                return true -- 481
            end -- 481
            ____cond104 = ____cond104 or ____switch104 == "linearDamping" -- 481
            if ____cond104 then -- 481
                cnode.linearDamping = v -- 482
                return true -- 482
            end -- 482
            ____cond104 = ____cond104 or ____switch104 == "angularDamping" -- 482
            if ____cond104 then -- 482
                cnode.angularDamping = v -- 483
                return true -- 483
            end -- 483
            ____cond104 = ____cond104 or ____switch104 == "owner" -- 483
            if ____cond104 then -- 483
                cnode.owner = v -- 484
                return true -- 484
            end -- 484
            ____cond104 = ____cond104 or ____switch104 == "receivingContact" -- 484
            if ____cond104 then -- 484
                cnode.receivingContact = v -- 485
                return true -- 485
            end -- 485
            ____cond104 = ____cond104 or ____switch104 == "onBodyEnter" -- 485
            if ____cond104 then -- 485
                cnode:slot("BodyEnter", v) -- 486
                return true -- 486
            end -- 486
            ____cond104 = ____cond104 or ____switch104 == "onBodyLeave" -- 486
            if ____cond104 then -- 486
                cnode:slot("BodyLeave", v) -- 487
                return true -- 487
            end -- 487
            ____cond104 = ____cond104 or ____switch104 == "onContactStart" -- 487
            if ____cond104 then -- 487
                cnode:slot("ContactStart", v) -- 488
                return true -- 488
            end -- 488
            ____cond104 = ____cond104 or ____switch104 == "onContactEnd" -- 488
            if ____cond104 then -- 488
                cnode:slot("ContactEnd", v) -- 489
                return true -- 489
            end -- 489
        until true -- 489
        return false -- 491
    end -- 471
    getBody = function(enode, world) -- 493
        local def = enode.props -- 494
        local bodyDef = dora.BodyDef() -- 495
        bodyDef.type = def.type -- 496
        if def.angle ~= nil then -- 496
            bodyDef.angle = def.angle -- 497
        end -- 497
        if def.angularDamping ~= nil then -- 497
            bodyDef.angularDamping = def.angularDamping -- 498
        end -- 498
        if def.bullet ~= nil then -- 498
            bodyDef.bullet = def.bullet -- 499
        end -- 499
        if def.fixedRotation ~= nil then -- 499
            bodyDef.fixedRotation = def.fixedRotation -- 500
        end -- 500
        if def.linearAcceleration ~= nil then -- 500
            bodyDef.linearAcceleration = def.linearAcceleration -- 501
        end -- 501
        if def.linearDamping ~= nil then -- 501
            bodyDef.linearDamping = def.linearDamping -- 502
        end -- 502
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 503
        local extraSensors = nil -- 504
        for i = 1, #enode.children do -- 504
            do -- 504
                local child = enode.children[i] -- 506
                if type(child) ~= "table" then -- 506
                    goto __continue112 -- 508
                end -- 508
                repeat -- 508
                    local ____switch114 = child.type -- 508
                    local ____cond114 = ____switch114 == "rect-shape" -- 508
                    if ____cond114 then -- 508
                        do -- 508
                            local shape = child.props -- 512
                            if shape.sensorTag ~= nil then -- 512
                                bodyDef:attachPolygonSensor( -- 514
                                    shape.sensorTag, -- 515
                                    shape.width, -- 516
                                    shape.height, -- 516
                                    shape.center or dora.Vec2.zero, -- 517
                                    shape.angle or 0 -- 518
                                ) -- 518
                            else -- 518
                                bodyDef:attachPolygon( -- 521
                                    shape.center or dora.Vec2.zero, -- 522
                                    shape.width, -- 523
                                    shape.height, -- 523
                                    shape.angle or 0, -- 524
                                    shape.density or 0, -- 525
                                    shape.friction or 0.4, -- 526
                                    shape.restitution or 0 -- 527
                                ) -- 527
                            end -- 527
                            break -- 530
                        end -- 530
                    end -- 530
                    ____cond114 = ____cond114 or ____switch114 == "polygon-shape" -- 530
                    if ____cond114 then -- 530
                        do -- 530
                            local shape = child.props -- 533
                            if shape.sensorTag ~= nil then -- 533
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 535
                            else -- 535
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 540
                            end -- 540
                            break -- 547
                        end -- 547
                    end -- 547
                    ____cond114 = ____cond114 or ____switch114 == "multi-shape" -- 547
                    if ____cond114 then -- 547
                        do -- 547
                            local shape = child.props -- 550
                            if shape.sensorTag ~= nil then -- 550
                                if extraSensors == nil then -- 550
                                    extraSensors = {} -- 552
                                end -- 552
                                extraSensors[#extraSensors + 1] = { -- 553
                                    shape.sensorTag, -- 553
                                    dora.BodyDef:multi(shape.verts) -- 553
                                } -- 553
                            else -- 553
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 555
                            end -- 555
                            break -- 562
                        end -- 562
                    end -- 562
                    ____cond114 = ____cond114 or ____switch114 == "disk-shape" -- 562
                    if ____cond114 then -- 562
                        do -- 562
                            local shape = child.props -- 565
                            if shape.sensorTag ~= nil then -- 565
                                bodyDef:attachDiskSensor(shape.sensorTag, shape.radius) -- 567
                            else -- 567
                                bodyDef:attachDisk( -- 572
                                    shape.center or dora.Vec2.zero, -- 573
                                    shape.radius, -- 574
                                    shape.density or 0, -- 575
                                    shape.friction or 0.4, -- 576
                                    shape.restitution or 0 -- 577
                                ) -- 577
                            end -- 577
                            break -- 580
                        end -- 580
                    end -- 580
                    ____cond114 = ____cond114 or ____switch114 == "chain-shape" -- 580
                    if ____cond114 then -- 580
                        do -- 580
                            local shape = child.props -- 583
                            if shape.sensorTag ~= nil then -- 583
                                if extraSensors == nil then -- 583
                                    extraSensors = {} -- 585
                                end -- 585
                                extraSensors[#extraSensors + 1] = { -- 586
                                    shape.sensorTag, -- 586
                                    dora.BodyDef:chain(shape.verts) -- 586
                                } -- 586
                            else -- 586
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 588
                            end -- 588
                            break -- 594
                        end -- 594
                    end -- 594
                until true -- 594
            end -- 594
            ::__continue112:: -- 594
        end -- 594
        local body = dora.Body(bodyDef, world) -- 598
        if extraSensors ~= nil then -- 598
            for i = 1, #extraSensors do -- 598
                local tag, def = table.unpack(extraSensors[i]) -- 601
                body:attachSensor(tag, def) -- 602
            end -- 602
        end -- 602
        local cnode = getNode(nil, enode, body, handleBodyAttribute) -- 605
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 605
            body.receivingContact = true -- 612
        end -- 612
        return cnode -- 614
    end -- 493
end -- 493
local function addChild(nodeStack, cnode, enode) -- 618
    if #nodeStack > 0 then -- 618
        local last = nodeStack[#nodeStack] -- 620
        last:addChild(cnode) -- 621
    end -- 621
    nodeStack[#nodeStack + 1] = cnode -- 623
    local ____enode_5 = enode -- 624
    local children = ____enode_5.children -- 624
    for i = 1, #children do -- 624
        visitNode(nodeStack, children[i], enode) -- 626
    end -- 626
    if #nodeStack > 1 then -- 626
        table.remove(nodeStack) -- 629
    end -- 629
end -- 618
local function drawNodeCheck(_nodeStack, enode, parent) -- 637
    if parent == nil or parent.type ~= "draw-node" then -- 637
        print(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 639
    end -- 639
end -- 637
local function actionCheck(_nodeStack, enode, parent) -- 643
    local unsupported = false -- 644
    if parent == nil then -- 644
        unsupported = true -- 646
    else -- 646
        repeat -- 646
            local ____switch142 = enode.type -- 646
            local ____cond142 = ____switch142 == "action" or ____switch142 == "spawn" or ____switch142 == "sequence" -- 646
            if ____cond142 then -- 646
                break -- 649
            end -- 649
            do -- 649
                unsupported = true -- 650
                break -- 650
            end -- 650
        until true -- 650
    end -- 650
    if unsupported then -- 650
        print(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 654
    end -- 654
end -- 643
local function bodyCheck(_nodeStack, enode, parent) -- 658
    if parent == nil or parent.type ~= "body" then -- 658
        print(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 660
    end -- 660
end -- 658
local actionMap = { -- 664
    ["anchor-x"] = dora.AnchorX, -- 667
    ["anchor-y"] = dora.AnchorY, -- 668
    angle = dora.Angle, -- 669
    ["angle-x"] = dora.AngleX, -- 670
    ["angle-y"] = dora.AngleY, -- 671
    width = dora.Width, -- 672
    height = dora.Height, -- 673
    opacity = dora.Opacity, -- 674
    roll = dora.Roll, -- 675
    scale = dora.Scale, -- 676
    ["scale-x"] = dora.ScaleX, -- 677
    ["scale-y"] = dora.ScaleY, -- 678
    ["skew-x"] = dora.SkewX, -- 679
    ["skew-y"] = dora.SkewY, -- 680
    ["move-x"] = dora.X, -- 681
    ["move-y"] = dora.Y, -- 682
    ["move-z"] = dora.Z -- 683
} -- 683
elementMap = { -- 686
    node = function(nodeStack, enode, parent) -- 687
        addChild( -- 688
            nodeStack, -- 688
            getNode(nil, enode), -- 688
            enode -- 688
        ) -- 688
    end, -- 687
    ["clip-node"] = function(nodeStack, enode, parent) -- 690
        addChild( -- 691
            nodeStack, -- 691
            getClipNode(enode), -- 691
            enode -- 691
        ) -- 691
    end, -- 690
    playable = function(nodeStack, enode, parent) -- 693
        local cnode = getPlayable(enode) -- 694
        if cnode ~= nil then -- 694
            addChild(nodeStack, cnode, enode) -- 696
        end -- 696
    end, -- 693
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 699
        local cnode = getDragonBone(enode) -- 700
        if cnode ~= nil then -- 700
            addChild(nodeStack, cnode, enode) -- 702
        end -- 702
    end, -- 699
    spine = function(nodeStack, enode, parent) -- 705
        local cnode = getSpine(enode) -- 706
        if cnode ~= nil then -- 706
            addChild(nodeStack, cnode, enode) -- 708
        end -- 708
    end, -- 705
    model = function(nodeStack, enode, parent) -- 711
        local cnode = getModel(enode) -- 712
        if cnode ~= nil then -- 712
            addChild(nodeStack, cnode, enode) -- 714
        end -- 714
    end, -- 711
    ["draw-node"] = function(nodeStack, enode, parent) -- 717
        addChild( -- 718
            nodeStack, -- 718
            getDrawNode(enode), -- 718
            enode -- 718
        ) -- 718
    end, -- 717
    dot = drawNodeCheck, -- 720
    segment = drawNodeCheck, -- 721
    polygon = drawNodeCheck, -- 722
    verts = drawNodeCheck, -- 723
    grid = function(nodeStack, enode, parent) -- 724
        addChild( -- 725
            nodeStack, -- 725
            getGrid(enode), -- 725
            enode -- 725
        ) -- 725
    end, -- 724
    sprite = function(nodeStack, enode, parent) -- 727
        local cnode = getSprite(enode) -- 728
        if cnode ~= nil then -- 728
            addChild(nodeStack, cnode, enode) -- 730
        end -- 730
    end, -- 727
    label = function(nodeStack, enode, parent) -- 733
        local cnode = getLabel(enode) -- 734
        if cnode ~= nil then -- 734
            addChild(nodeStack, cnode, enode) -- 736
        end -- 736
    end, -- 733
    line = function(nodeStack, enode, parent) -- 739
        addChild( -- 740
            nodeStack, -- 740
            getLine(enode), -- 740
            enode -- 740
        ) -- 740
    end, -- 739
    particle = function(nodeStack, enode, parent) -- 742
        local cnode = getParticle(enode) -- 743
        if cnode ~= nil then -- 743
            addChild(nodeStack, cnode, enode) -- 745
        end -- 745
    end, -- 742
    menu = function(nodeStack, enode, parent) -- 748
        addChild( -- 749
            nodeStack, -- 749
            getMenu(enode), -- 749
            enode -- 749
        ) -- 749
    end, -- 748
    action = function(_nodeStack, enode, parent) -- 751
        if #enode.children == 0 then -- 751
            return -- 752
        end -- 752
        local action = enode.props -- 753
        if action.ref == nil then -- 753
            return -- 754
        end -- 754
        local function visitAction(actionStack, enode) -- 755
            local createAction = actionMap[enode.type] -- 756
            if createAction ~= nil then -- 756
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 758
                return -- 759
            end -- 759
            repeat -- 759
                local ____switch171 = enode.type -- 759
                local ____cond171 = ____switch171 == "delay" -- 759
                if ____cond171 then -- 759
                    do -- 759
                        local item = enode.props -- 763
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 764
                        return -- 765
                    end -- 765
                end -- 765
                ____cond171 = ____cond171 or ____switch171 == "event" -- 765
                if ____cond171 then -- 765
                    do -- 765
                        local item = enode.props -- 768
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 769
                        return -- 770
                    end -- 770
                end -- 770
                ____cond171 = ____cond171 or ____switch171 == "hide" -- 770
                if ____cond171 then -- 770
                    do -- 770
                        actionStack[#actionStack + 1] = dora.Hide() -- 773
                        return -- 774
                    end -- 774
                end -- 774
                ____cond171 = ____cond171 or ____switch171 == "show" -- 774
                if ____cond171 then -- 774
                    do -- 774
                        actionStack[#actionStack + 1] = dora.Show() -- 777
                        return -- 778
                    end -- 778
                end -- 778
                ____cond171 = ____cond171 or ____switch171 == "move" -- 778
                if ____cond171 then -- 778
                    do -- 778
                        local item = enode.props -- 781
                        actionStack[#actionStack + 1] = dora.Move( -- 782
                            item.time, -- 782
                            dora.Vec2(item.startX, item.startY), -- 782
                            dora.Vec2(item.stopX, item.stopY), -- 782
                            item.easing -- 782
                        ) -- 782
                        return -- 783
                    end -- 783
                end -- 783
                ____cond171 = ____cond171 or ____switch171 == "spawn" -- 783
                if ____cond171 then -- 783
                    do -- 783
                        local spawnStack = {} -- 786
                        for i = 1, #enode.children do -- 786
                            visitAction(spawnStack, enode.children[i]) -- 788
                        end -- 788
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 790
                    end -- 790
                end -- 790
                ____cond171 = ____cond171 or ____switch171 == "sequence" -- 790
                if ____cond171 then -- 790
                    do -- 790
                        local sequenceStack = {} -- 793
                        for i = 1, #enode.children do -- 793
                            visitAction(sequenceStack, enode.children[i]) -- 795
                        end -- 795
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 797
                    end -- 797
                end -- 797
                do -- 797
                    print(("unsupported tag <" .. enode.type) .. "> under action definition") -- 800
                    break -- 801
                end -- 801
            until true -- 801
        end -- 755
        local actionStack = {} -- 804
        for i = 1, #enode.children do -- 804
            visitAction(actionStack, enode.children[i]) -- 806
        end -- 806
        if #actionStack == 1 then -- 806
            action.ref.current = actionStack[1] -- 809
        elseif #actionStack > 1 then -- 809
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 811
        end -- 811
    end, -- 751
    ["anchor-x"] = actionCheck, -- 814
    ["anchor-y"] = actionCheck, -- 815
    angle = actionCheck, -- 816
    ["angle-x"] = actionCheck, -- 817
    ["angle-y"] = actionCheck, -- 818
    delay = actionCheck, -- 819
    event = actionCheck, -- 820
    width = actionCheck, -- 821
    height = actionCheck, -- 822
    hide = actionCheck, -- 823
    show = actionCheck, -- 824
    move = actionCheck, -- 825
    opacity = actionCheck, -- 826
    roll = actionCheck, -- 827
    scale = actionCheck, -- 828
    ["scale-x"] = actionCheck, -- 829
    ["scale-y"] = actionCheck, -- 830
    ["skew-x"] = actionCheck, -- 831
    ["skew-y"] = actionCheck, -- 832
    ["move-x"] = actionCheck, -- 833
    ["move-y"] = actionCheck, -- 834
    ["move-z"] = actionCheck, -- 835
    spawn = actionCheck, -- 836
    sequence = actionCheck, -- 837
    ["physics-world"] = function(nodeStack, enode, _parent) -- 838
        addChild( -- 839
            nodeStack, -- 839
            getPhysicsWorld(enode), -- 839
            enode -- 839
        ) -- 839
    end, -- 838
    body = function(nodeStack, enode, _parent) -- 841
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 842
        if world ~= nil then -- 842
            addChild( -- 844
                nodeStack, -- 844
                getBody(enode, world), -- 844
                enode -- 844
            ) -- 844
        else -- 844
            print(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 846
        end -- 846
    end, -- 841
    ["rect-shape"] = bodyCheck, -- 849
    ["polygon-shape"] = bodyCheck, -- 850
    ["multi-shape"] = bodyCheck, -- 851
    ["disk-shape"] = bodyCheck, -- 852
    ["chain-shape"] = bodyCheck, -- 853
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 854
        local joint = enode.props -- 855
        if joint.ref == nil then -- 855
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 857
            return -- 858
        end -- 858
        if joint.bodyA.current == nil then -- 858
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 861
            return -- 862
        end -- 862
        if joint.bodyB.current == nil then -- 862
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 865
            return -- 866
        end -- 866
        local ____joint_ref_9 = joint.ref -- 868
        local ____self_7 = dora.Joint -- 868
        local ____self_7_distance_8 = ____self_7.distance -- 868
        local ____joint_canCollide_6 = joint.canCollide -- 869
        if ____joint_canCollide_6 == nil then -- 869
            ____joint_canCollide_6 = false -- 869
        end -- 869
        ____joint_ref_9.current = ____self_7_distance_8( -- 868
            ____self_7, -- 868
            ____joint_canCollide_6, -- 869
            joint.bodyA.current, -- 870
            joint.bodyB.current, -- 871
            joint.anchorA or dora.Vec2.zero, -- 872
            joint.anchorB or dora.Vec2.zero, -- 873
            joint.frequency or 0, -- 874
            joint.damping or 0 -- 875
        ) -- 875
    end, -- 854
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 877
        local joint = enode.props -- 878
        if joint.ref == nil then -- 878
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 880
            return -- 881
        end -- 881
        if joint.bodyA.current == nil then -- 881
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 884
            return -- 885
        end -- 885
        if joint.bodyB.current == nil then -- 885
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 888
            return -- 889
        end -- 889
        local ____joint_ref_13 = joint.ref -- 891
        local ____self_11 = dora.Joint -- 891
        local ____self_11_friction_12 = ____self_11.friction -- 891
        local ____joint_canCollide_10 = joint.canCollide -- 892
        if ____joint_canCollide_10 == nil then -- 892
            ____joint_canCollide_10 = false -- 892
        end -- 892
        ____joint_ref_13.current = ____self_11_friction_12( -- 891
            ____self_11, -- 891
            ____joint_canCollide_10, -- 892
            joint.bodyA.current, -- 893
            joint.bodyB.current, -- 894
            joint.worldPos, -- 895
            joint.maxForce, -- 896
            joint.maxTorque -- 897
        ) -- 897
    end, -- 877
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 900
        local joint = enode.props -- 901
        if joint.ref == nil then -- 901
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 903
            return -- 904
        end -- 904
        if joint.jointA.current == nil then -- 904
            print(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 907
            return -- 908
        end -- 908
        if joint.jointB.current == nil then -- 908
            print(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 911
            return -- 912
        end -- 912
        local ____joint_ref_17 = joint.ref -- 914
        local ____self_15 = dora.Joint -- 914
        local ____self_15_gear_16 = ____self_15.gear -- 914
        local ____joint_canCollide_14 = joint.canCollide -- 915
        if ____joint_canCollide_14 == nil then -- 915
            ____joint_canCollide_14 = false -- 915
        end -- 915
        ____joint_ref_17.current = ____self_15_gear_16( -- 914
            ____self_15, -- 914
            ____joint_canCollide_14, -- 915
            joint.jointA.current, -- 916
            joint.jointB.current, -- 917
            joint.ratio or 1 -- 918
        ) -- 918
    end, -- 900
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 921
        local joint = enode.props -- 922
        if joint.ref == nil then -- 922
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 924
            return -- 925
        end -- 925
        if joint.bodyA.current == nil then -- 925
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 928
            return -- 929
        end -- 929
        if joint.bodyB.current == nil then -- 929
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 932
            return -- 933
        end -- 933
        local ____joint_ref_21 = joint.ref -- 935
        local ____self_19 = dora.Joint -- 935
        local ____self_19_spring_20 = ____self_19.spring -- 935
        local ____joint_canCollide_18 = joint.canCollide -- 936
        if ____joint_canCollide_18 == nil then -- 936
            ____joint_canCollide_18 = false -- 936
        end -- 936
        ____joint_ref_21.current = ____self_19_spring_20( -- 935
            ____self_19, -- 935
            ____joint_canCollide_18, -- 936
            joint.bodyA.current, -- 937
            joint.bodyB.current, -- 938
            joint.linearOffset, -- 939
            joint.angularOffset, -- 940
            joint.maxForce, -- 941
            joint.maxTorque, -- 942
            joint.correctionFactor or 1 -- 943
        ) -- 943
    end, -- 921
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 946
        local joint = enode.props -- 947
        if joint.ref == nil then -- 947
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 949
            return -- 950
        end -- 950
        if joint.body.current == nil then -- 950
            print(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 953
            return -- 954
        end -- 954
        local ____joint_ref_25 = joint.ref -- 956
        local ____self_23 = dora.Joint -- 956
        local ____self_23_move_24 = ____self_23.move -- 956
        local ____joint_canCollide_22 = joint.canCollide -- 957
        if ____joint_canCollide_22 == nil then -- 957
            ____joint_canCollide_22 = false -- 957
        end -- 957
        ____joint_ref_25.current = ____self_23_move_24( -- 956
            ____self_23, -- 956
            ____joint_canCollide_22, -- 957
            joint.body.current, -- 958
            joint.targetPos, -- 959
            joint.maxForce, -- 960
            joint.frequency, -- 961
            joint.damping or 0.7 -- 962
        ) -- 962
    end, -- 946
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 965
        local joint = enode.props -- 966
        if joint.ref == nil then -- 966
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 968
            return -- 969
        end -- 969
        if joint.bodyA.current == nil then -- 969
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 972
            return -- 973
        end -- 973
        if joint.bodyB.current == nil then -- 973
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 976
            return -- 977
        end -- 977
        local ____joint_ref_29 = joint.ref -- 979
        local ____self_27 = dora.Joint -- 979
        local ____self_27_prismatic_28 = ____self_27.prismatic -- 979
        local ____joint_canCollide_26 = joint.canCollide -- 980
        if ____joint_canCollide_26 == nil then -- 980
            ____joint_canCollide_26 = false -- 980
        end -- 980
        ____joint_ref_29.current = ____self_27_prismatic_28( -- 979
            ____self_27, -- 979
            ____joint_canCollide_26, -- 980
            joint.bodyA.current, -- 981
            joint.bodyB.current, -- 982
            joint.worldPos, -- 983
            joint.axisAngle, -- 984
            joint.lowerTranslation or 0, -- 985
            joint.upperTranslation or 0, -- 986
            joint.maxMotorForce or 0, -- 987
            joint.motorSpeed or 0 -- 988
        ) -- 988
    end, -- 965
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 991
        local joint = enode.props -- 992
        if joint.ref == nil then -- 992
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 994
            return -- 995
        end -- 995
        if joint.bodyA.current == nil then -- 995
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 998
            return -- 999
        end -- 999
        if joint.bodyB.current == nil then -- 999
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1002
            return -- 1003
        end -- 1003
        local ____joint_ref_33 = joint.ref -- 1005
        local ____self_31 = dora.Joint -- 1005
        local ____self_31_pulley_32 = ____self_31.pulley -- 1005
        local ____joint_canCollide_30 = joint.canCollide -- 1006
        if ____joint_canCollide_30 == nil then -- 1006
            ____joint_canCollide_30 = false -- 1006
        end -- 1006
        ____joint_ref_33.current = ____self_31_pulley_32( -- 1005
            ____self_31, -- 1005
            ____joint_canCollide_30, -- 1006
            joint.bodyA.current, -- 1007
            joint.bodyB.current, -- 1008
            joint.anchorA or dora.Vec2.zero, -- 1009
            joint.anchorB or dora.Vec2.zero, -- 1010
            joint.groundAnchorA, -- 1011
            joint.groundAnchorB, -- 1012
            joint.ratio or 1 -- 1013
        ) -- 1013
    end, -- 991
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1016
        local joint = enode.props -- 1017
        if joint.ref == nil then -- 1017
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1019
            return -- 1020
        end -- 1020
        if joint.bodyA.current == nil then -- 1020
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1023
            return -- 1024
        end -- 1024
        if joint.bodyB.current == nil then -- 1024
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1027
            return -- 1028
        end -- 1028
        local ____joint_ref_37 = joint.ref -- 1030
        local ____self_35 = dora.Joint -- 1030
        local ____self_35_revolute_36 = ____self_35.revolute -- 1030
        local ____joint_canCollide_34 = joint.canCollide -- 1031
        if ____joint_canCollide_34 == nil then -- 1031
            ____joint_canCollide_34 = false -- 1031
        end -- 1031
        ____joint_ref_37.current = ____self_35_revolute_36( -- 1030
            ____self_35, -- 1030
            ____joint_canCollide_34, -- 1031
            joint.bodyA.current, -- 1032
            joint.bodyB.current, -- 1033
            joint.worldPos, -- 1034
            joint.lowerAngle or 0, -- 1035
            joint.upperAngle or 0, -- 1036
            joint.maxMotorTorque or 0, -- 1037
            joint.motorSpeed or 0 -- 1038
        ) -- 1038
    end, -- 1016
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1041
        local joint = enode.props -- 1042
        if joint.ref == nil then -- 1042
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1044
            return -- 1045
        end -- 1045
        if joint.bodyA.current == nil then -- 1045
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1048
            return -- 1049
        end -- 1049
        if joint.bodyB.current == nil then -- 1049
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1052
            return -- 1053
        end -- 1053
        local ____joint_ref_41 = joint.ref -- 1055
        local ____self_39 = dora.Joint -- 1055
        local ____self_39_rope_40 = ____self_39.rope -- 1055
        local ____joint_canCollide_38 = joint.canCollide -- 1056
        if ____joint_canCollide_38 == nil then -- 1056
            ____joint_canCollide_38 = false -- 1056
        end -- 1056
        ____joint_ref_41.current = ____self_39_rope_40( -- 1055
            ____self_39, -- 1055
            ____joint_canCollide_38, -- 1056
            joint.bodyA.current, -- 1057
            joint.bodyB.current, -- 1058
            joint.anchorA or dora.Vec2.zero, -- 1059
            joint.anchorB or dora.Vec2.zero, -- 1060
            joint.maxLength or 0 -- 1061
        ) -- 1061
    end, -- 1041
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1064
        local joint = enode.props -- 1065
        if joint.ref == nil then -- 1065
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1067
            return -- 1068
        end -- 1068
        if joint.bodyA.current == nil then -- 1068
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1071
            return -- 1072
        end -- 1072
        if joint.bodyB.current == nil then -- 1072
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1075
            return -- 1076
        end -- 1076
        local ____joint_ref_45 = joint.ref -- 1078
        local ____self_43 = dora.Joint -- 1078
        local ____self_43_weld_44 = ____self_43.weld -- 1078
        local ____joint_canCollide_42 = joint.canCollide -- 1079
        if ____joint_canCollide_42 == nil then -- 1079
            ____joint_canCollide_42 = false -- 1079
        end -- 1079
        ____joint_ref_45.current = ____self_43_weld_44( -- 1078
            ____self_43, -- 1078
            ____joint_canCollide_42, -- 1079
            joint.bodyA.current, -- 1080
            joint.bodyB.current, -- 1081
            joint.worldPos, -- 1082
            joint.frequency or 0, -- 1083
            joint.damping or 0 -- 1084
        ) -- 1084
    end, -- 1064
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1087
        local joint = enode.props -- 1088
        if joint.ref == nil then -- 1088
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1090
            return -- 1091
        end -- 1091
        if joint.bodyA.current == nil then -- 1091
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1094
            return -- 1095
        end -- 1095
        if joint.bodyB.current == nil then -- 1095
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1098
            return -- 1099
        end -- 1099
        local ____joint_ref_49 = joint.ref -- 1101
        local ____self_47 = dora.Joint -- 1101
        local ____self_47_wheel_48 = ____self_47.wheel -- 1101
        local ____joint_canCollide_46 = joint.canCollide -- 1102
        if ____joint_canCollide_46 == nil then -- 1102
            ____joint_canCollide_46 = false -- 1102
        end -- 1102
        ____joint_ref_49.current = ____self_47_wheel_48( -- 1101
            ____self_47, -- 1101
            ____joint_canCollide_46, -- 1102
            joint.bodyA.current, -- 1103
            joint.bodyB.current, -- 1104
            joint.worldPos, -- 1105
            joint.axisAngle, -- 1106
            joint.maxMotorTorque or 0, -- 1107
            joint.motorSpeed or 0, -- 1108
            joint.frequency or 0, -- 1109
            joint.damping or 0.7 -- 1110
        ) -- 1110
    end -- 1087
} -- 1087
function ____exports.useRef(item) -- 1155
    local ____item_50 = item -- 1156
    if ____item_50 == nil then -- 1156
        ____item_50 = nil -- 1156
    end -- 1156
    return {current = ____item_50} -- 1156
end -- 1155
return ____exports -- 1155
