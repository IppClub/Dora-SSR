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
function visitNode(nodeStack, node, parent) -- 1126
    if type(node) ~= "table" then -- 1126
        return -- 1128
    end -- 1128
    local enode = node -- 1130
    if enode.type == nil then -- 1130
        local list = node -- 1132
        if #list > 0 then -- 1132
            for i = 1, #list do -- 1132
                local stack = {} -- 1135
                visitNode(stack, list[i], parent) -- 1136
                for i = 1, #stack do -- 1136
                    nodeStack[#nodeStack + 1] = stack[i] -- 1138
                end -- 1138
            end -- 1138
        end -- 1138
    else -- 1138
        local handler = elementMap[enode.type] -- 1143
        if handler ~= nil then -- 1143
            handler(nodeStack, enode, parent) -- 1145
        else -- 1145
            print(("unsupported tag <" .. enode.type) .. ">") -- 1147
        end -- 1147
    end -- 1147
end -- 1147
function ____exports.toNode(enode) -- 1152
    local nodeStack = {} -- 1153
    visitNode(nodeStack, enode) -- 1154
    if #nodeStack == 1 then -- 1154
        return nodeStack[1] -- 1156
    elseif #nodeStack > 1 then -- 1156
        local node = dora.Node() -- 1158
        for i = 1, #nodeStack do -- 1158
            node:addChild(nodeStack[i]) -- 1160
        end -- 1160
        return node -- 1162
    end -- 1162
    return nil -- 1164
end -- 1152
____exports.React = {} -- 1152
local React = ____exports.React -- 1152
do -- 1152
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
    function React.createElement(____type, props, ...) -- 45
        local children = {...} -- 45
        if type(____type) == "function" then -- 45
            if props == nil then -- 45
                props = {} -- 52
            end -- 52
            if props.children then -- 52
                local ____props_1 = props -- 54
                local ____array_0 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 54
                __TS__SparseArrayPush(____array_0, ...) -- 54
                ____props_1.children = {__TS__SparseArraySpread(____array_0)} -- 54
            else -- 54
                props.children = children -- 56
            end -- 56
            local item = ____type(nil, props) -- 58
            item.props.children = nil -- 59
            return item -- 60
        else -- 60
            if props and props.children then -- 60
                local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 60
                __TS__SparseArrayPush( -- 60
                    ____array_2, -- 60
                    table.unpack(children) -- 63
                ) -- 63
                children = {__TS__SparseArraySpread(____array_2)} -- 63
                props.children = nil -- 64
            end -- 64
            local flatChildren = {} -- 66
            for i = 1, #children do -- 66
                local child, flat = flattenChild(children[i]) -- 68
                if flat then -- 68
                    flatChildren[#flatChildren + 1] = child -- 70
                else -- 70
                    for i = 1, #child do -- 70
                        flatChildren[#flatChildren + 1] = child[i] -- 73
                    end -- 73
                end -- 73
            end -- 73
            children = flatChildren -- 77
        end -- 77
        if ____type == nil then -- 77
            return children -- 80
        end -- 80
        return {type = ____type, props = props, children = children} -- 82
    end -- 45
end -- 45
local function getNode(self, enode, cnode, attribHandler) -- 93
    cnode = cnode or dora.Node() -- 94
    local jnode = enode.props -- 95
    local anchor = nil -- 96
    local color3 = nil -- 97
    if jnode ~= nil then -- 97
        for k, v in pairs(enode.props) do -- 99
            repeat -- 99
                local ____switch25 = k -- 99
                local ____cond25 = ____switch25 == "ref" -- 99
                if ____cond25 then -- 99
                    v.current = cnode -- 101
                    break -- 101
                end -- 101
                ____cond25 = ____cond25 or ____switch25 == "anchorX" -- 101
                if ____cond25 then -- 101
                    anchor = dora.Vec2(v, (anchor or cnode.anchor).y) -- 102
                    break -- 102
                end -- 102
                ____cond25 = ____cond25 or ____switch25 == "anchorY" -- 102
                if ____cond25 then -- 102
                    anchor = dora.Vec2((anchor or cnode.anchor).x, v) -- 103
                    break -- 103
                end -- 103
                ____cond25 = ____cond25 or ____switch25 == "color3" -- 103
                if ____cond25 then -- 103
                    color3 = dora.Color3(v) -- 104
                    break -- 104
                end -- 104
                ____cond25 = ____cond25 or ____switch25 == "transformTarget" -- 104
                if ____cond25 then -- 104
                    cnode.transformTarget = v.current -- 105
                    break -- 105
                end -- 105
                ____cond25 = ____cond25 or ____switch25 == "onUpdate" -- 105
                if ____cond25 then -- 105
                    cnode:schedule(v) -- 106
                    break -- 106
                end -- 106
                ____cond25 = ____cond25 or ____switch25 == "onActionEnd" -- 106
                if ____cond25 then -- 106
                    cnode:slot("ActionEnd", v) -- 107
                    break -- 107
                end -- 107
                ____cond25 = ____cond25 or ____switch25 == "onTapFilter" -- 107
                if ____cond25 then -- 107
                    cnode:slot("TapFilter", v) -- 108
                    break -- 108
                end -- 108
                ____cond25 = ____cond25 or ____switch25 == "onTapBegan" -- 108
                if ____cond25 then -- 108
                    cnode:slot("TapBegan", v) -- 109
                    break -- 109
                end -- 109
                ____cond25 = ____cond25 or ____switch25 == "onTapEnded" -- 109
                if ____cond25 then -- 109
                    cnode:slot("TapEnded", v) -- 110
                    break -- 110
                end -- 110
                ____cond25 = ____cond25 or ____switch25 == "onTapped" -- 110
                if ____cond25 then -- 110
                    cnode:slot("Tapped", v) -- 111
                    break -- 111
                end -- 111
                ____cond25 = ____cond25 or ____switch25 == "onTapMoved" -- 111
                if ____cond25 then -- 111
                    cnode:slot("TapMoved", v) -- 112
                    break -- 112
                end -- 112
                ____cond25 = ____cond25 or ____switch25 == "onMouseWheel" -- 112
                if ____cond25 then -- 112
                    cnode:slot("MouseWheel", v) -- 113
                    break -- 113
                end -- 113
                ____cond25 = ____cond25 or ____switch25 == "onGesture" -- 113
                if ____cond25 then -- 113
                    cnode:slot("Gesture", v) -- 114
                    break -- 114
                end -- 114
                ____cond25 = ____cond25 or ____switch25 == "onEnter" -- 114
                if ____cond25 then -- 114
                    cnode:slot("Enter", v) -- 115
                    break -- 115
                end -- 115
                ____cond25 = ____cond25 or ____switch25 == "onExit" -- 115
                if ____cond25 then -- 115
                    cnode:slot("Exit", v) -- 116
                    break -- 116
                end -- 116
                ____cond25 = ____cond25 or ____switch25 == "onCleanup" -- 116
                if ____cond25 then -- 116
                    cnode:slot("Cleanup", v) -- 117
                    break -- 117
                end -- 117
                ____cond25 = ____cond25 or ____switch25 == "onKeyDown" -- 117
                if ____cond25 then -- 117
                    cnode:slot("KeyDown", v) -- 118
                    break -- 118
                end -- 118
                ____cond25 = ____cond25 or ____switch25 == "onKeyUp" -- 118
                if ____cond25 then -- 118
                    cnode:slot("KeyUp", v) -- 119
                    break -- 119
                end -- 119
                ____cond25 = ____cond25 or ____switch25 == "onKeyPressed" -- 119
                if ____cond25 then -- 119
                    cnode:slot("KeyPressed", v) -- 120
                    break -- 120
                end -- 120
                ____cond25 = ____cond25 or ____switch25 == "onAttachIME" -- 120
                if ____cond25 then -- 120
                    cnode:slot("AttachIME", v) -- 121
                    break -- 121
                end -- 121
                ____cond25 = ____cond25 or ____switch25 == "onDetachIME" -- 121
                if ____cond25 then -- 121
                    cnode:slot("DetachIME", v) -- 122
                    break -- 122
                end -- 122
                ____cond25 = ____cond25 or ____switch25 == "onTextInput" -- 122
                if ____cond25 then -- 122
                    cnode:slot("TextInput", v) -- 123
                    break -- 123
                end -- 123
                ____cond25 = ____cond25 or ____switch25 == "onTextEditing" -- 123
                if ____cond25 then -- 123
                    cnode:slot("TextEditing", v) -- 124
                    break -- 124
                end -- 124
                ____cond25 = ____cond25 or ____switch25 == "onButtonDown" -- 124
                if ____cond25 then -- 124
                    cnode:slot("ButtonDown", v) -- 125
                    break -- 125
                end -- 125
                ____cond25 = ____cond25 or ____switch25 == "onButtonUp" -- 125
                if ____cond25 then -- 125
                    cnode:slot("ButtonUp", v) -- 126
                    break -- 126
                end -- 126
                ____cond25 = ____cond25 or ____switch25 == "onAxis" -- 126
                if ____cond25 then -- 126
                    cnode:slot("Axis", v) -- 127
                    break -- 127
                end -- 127
                do -- 127
                    do -- 127
                        if attribHandler then -- 127
                            if not attribHandler(cnode, enode, k, v) then -- 127
                                cnode[k] = v -- 131
                            end -- 131
                        else -- 131
                            cnode[k] = v -- 134
                        end -- 134
                        break -- 136
                    end -- 136
                end -- 136
            until true -- 136
        end -- 136
        if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 136
            cnode.touchEnabled = true -- 149
        end -- 149
        if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 149
            cnode.keyboardEnabled = true -- 156
        end -- 156
        if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 156
            cnode.controllerEnabled = true -- 163
        end -- 163
    end -- 163
    if anchor ~= nil then -- 163
        cnode.anchor = anchor -- 166
    end -- 166
    if color3 ~= nil then -- 166
        cnode.color3 = color3 -- 167
    end -- 167
    return cnode -- 168
end -- 93
local getClipNode -- 171
do -- 171
    local function handleClipNodeAttribute(cnode, _enode, k, v) -- 173
        repeat -- 173
            local ____switch37 = k -- 173
            local ____cond37 = ____switch37 == "stencil" -- 173
            if ____cond37 then -- 173
                cnode.stencil = ____exports.toNode(v) -- 180
                return true -- 180
            end -- 180
        until true -- 180
        return false -- 182
    end -- 173
    getClipNode = function(enode) -- 184
        return getNode( -- 185
            nil, -- 185
            enode, -- 185
            dora.ClipNode(), -- 185
            handleClipNodeAttribute -- 185
        ) -- 185
    end -- 184
end -- 184
local getPlayable -- 189
local getDragonBone -- 190
local getSpine -- 191
local getModel -- 192
do -- 192
    local function handlePlayableAttribute(cnode, enode, k, v) -- 194
        repeat -- 194
            local ____switch41 = k -- 194
            local ____cond41 = ____switch41 == "file" -- 194
            if ____cond41 then -- 194
                return true -- 196
            end -- 196
            ____cond41 = ____cond41 or ____switch41 == "play" -- 196
            if ____cond41 then -- 196
                cnode:play(v, enode.props.loop == true) -- 197
                return true -- 197
            end -- 197
            ____cond41 = ____cond41 or ____switch41 == "loop" -- 197
            if ____cond41 then -- 197
                return true -- 198
            end -- 198
            ____cond41 = ____cond41 or ____switch41 == "onAnimationEnd" -- 198
            if ____cond41 then -- 198
                cnode:slot("AnimationEnd", v) -- 199
                return true -- 199
            end -- 199
        until true -- 199
        return false -- 201
    end -- 194
    getPlayable = function(enode, cnode, attribHandler) -- 203
        if attribHandler == nil then -- 203
            attribHandler = handlePlayableAttribute -- 204
        end -- 204
        cnode = cnode or dora.Playable(enode.props.file) or nil -- 205
        if cnode ~= nil then -- 205
            return getNode(nil, enode, cnode, attribHandler) -- 207
        end -- 207
        return nil -- 209
    end -- 203
    local function handleDragonBoneAttribute(cnode, enode, k, v) -- 212
        repeat -- 212
            local ____switch45 = k -- 212
            local ____cond45 = ____switch45 == "showDebug" -- 212
            if ____cond45 then -- 212
                cnode.showDebug = v -- 214
                return true -- 214
            end -- 214
            ____cond45 = ____cond45 or ____switch45 == "hitTestEnabled" -- 214
            if ____cond45 then -- 214
                cnode.hitTestEnabled = true -- 215
                return true -- 215
            end -- 215
        until true -- 215
        return handlePlayableAttribute(cnode, enode, k, v) -- 217
    end -- 212
    getDragonBone = function(enode) -- 219
        local node = dora.DragonBone(enode.props.file) -- 220
        if node ~= nil then -- 220
            local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 222
            return cnode -- 223
        end -- 223
        return nil -- 225
    end -- 219
    local function handleSpineAttribute(cnode, enode, k, v) -- 228
        repeat -- 228
            local ____switch49 = k -- 228
            local ____cond49 = ____switch49 == "showDebug" -- 228
            if ____cond49 then -- 228
                cnode.showDebug = v -- 230
                return true -- 230
            end -- 230
            ____cond49 = ____cond49 or ____switch49 == "hitTestEnabled" -- 230
            if ____cond49 then -- 230
                cnode.hitTestEnabled = true -- 231
                return true -- 231
            end -- 231
        until true -- 231
        return handlePlayableAttribute(cnode, enode, k, v) -- 233
    end -- 228
    getSpine = function(enode) -- 235
        local node = dora.Spine(enode.props.file) -- 236
        if node ~= nil then -- 236
            local cnode = getPlayable(enode, node, handleSpineAttribute) -- 238
            return cnode -- 239
        end -- 239
        return nil -- 241
    end -- 235
    local function handleModelAttribute(cnode, enode, k, v) -- 244
        repeat -- 244
            local ____switch53 = k -- 244
            local ____cond53 = ____switch53 == "reversed" -- 244
            if ____cond53 then -- 244
                cnode.reversed = v -- 246
                return true -- 246
            end -- 246
        until true -- 246
        return handlePlayableAttribute(cnode, enode, k, v) -- 248
    end -- 244
    getModel = function(enode) -- 250
        local node = dora.Model(enode.props.file) -- 251
        if node ~= nil then -- 251
            local cnode = getPlayable(enode, node, handleModelAttribute) -- 253
            return cnode -- 254
        end -- 254
        return nil -- 256
    end -- 250
end -- 250
local getDrawNode -- 260
do -- 260
    local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 262
        repeat -- 262
            local ____switch58 = k -- 262
            local ____cond58 = ____switch58 == "depthWrite" -- 262
            if ____cond58 then -- 262
                cnode.depthWrite = v -- 264
                return true -- 264
            end -- 264
            ____cond58 = ____cond58 or ____switch58 == "blendFunc" -- 264
            if ____cond58 then -- 264
                cnode.blendFunc = v -- 265
                return true -- 265
            end -- 265
        until true -- 265
        return false -- 267
    end -- 262
    getDrawNode = function(enode) -- 269
        local node = dora.DrawNode() -- 270
        local cnode = getNode(nil, enode, node, handleDrawNodeAttribute) -- 271
        local ____enode_3 = enode -- 272
        local children = ____enode_3.children -- 272
        for i = 1, #children do -- 272
            do -- 272
                local child = children[i] -- 274
                if type(child) ~= "table" then -- 274
                    goto __continue60 -- 276
                end -- 276
                repeat -- 276
                    local ____switch62 = child.type -- 276
                    local ____cond62 = ____switch62 == "dot" -- 276
                    if ____cond62 then -- 276
                        do -- 276
                            local dot = child.props -- 280
                            node:drawDot( -- 281
                                dora.Vec2(dot.x, dot.y), -- 282
                                dot.radius, -- 283
                                dora.Color(dot.color or 4294967295) -- 284
                            ) -- 284
                            break -- 286
                        end -- 286
                    end -- 286
                    ____cond62 = ____cond62 or ____switch62 == "segment" -- 286
                    if ____cond62 then -- 286
                        do -- 286
                            local segment = child.props -- 289
                            node:drawSegment( -- 290
                                dora.Vec2(segment.startX, segment.startY), -- 291
                                dora.Vec2(segment.stopX, segment.stopY), -- 292
                                segment.radius, -- 293
                                dora.Color(segment.color or 4294967295) -- 294
                            ) -- 294
                            break -- 296
                        end -- 296
                    end -- 296
                    ____cond62 = ____cond62 or ____switch62 == "polygon" -- 296
                    if ____cond62 then -- 296
                        do -- 296
                            local poly = child.props -- 299
                            node:drawPolygon( -- 300
                                poly.verts, -- 301
                                dora.Color(poly.fillColor or 4294967295), -- 302
                                poly.borderWidth or 0, -- 303
                                dora.Color(poly.borderColor or 4294967295) -- 304
                            ) -- 304
                            break -- 306
                        end -- 306
                    end -- 306
                    ____cond62 = ____cond62 or ____switch62 == "verts" -- 306
                    if ____cond62 then -- 306
                        do -- 306
                            local verts = child.props -- 309
                            node:drawVertices(__TS__ArrayMap( -- 310
                                verts.verts, -- 310
                                function(____, ____bindingPattern0) -- 310
                                    local color -- 310
                                    local vert -- 310
                                    vert = ____bindingPattern0[1] -- 310
                                    color = ____bindingPattern0[2] -- 310
                                    return { -- 310
                                        vert, -- 310
                                        dora.Color(color) -- 310
                                    } -- 310
                                end -- 310
                            )) -- 310
                            break -- 311
                        end -- 311
                    end -- 311
                until true -- 311
            end -- 311
            ::__continue60:: -- 311
        end -- 311
        return cnode -- 315
    end -- 269
end -- 269
local getGrid -- 319
do -- 319
    local function handleGridAttribute(cnode, _enode, k, v) -- 321
        repeat -- 321
            local ____switch70 = k -- 321
            local ____cond70 = ____switch70 == "file" or ____switch70 == "gridX" or ____switch70 == "gridY" -- 321
            if ____cond70 then -- 321
                return true -- 323
            end -- 323
            ____cond70 = ____cond70 or ____switch70 == "textureRect" -- 323
            if ____cond70 then -- 323
                cnode.textureRect = v -- 324
                return true -- 324
            end -- 324
            ____cond70 = ____cond70 or ____switch70 == "depthWrite" -- 324
            if ____cond70 then -- 324
                cnode.depthWrite = v -- 325
                return true -- 325
            end -- 325
            ____cond70 = ____cond70 or ____switch70 == "blendFunc" -- 325
            if ____cond70 then -- 325
                cnode.blendFunc = v -- 326
                return true -- 326
            end -- 326
            ____cond70 = ____cond70 or ____switch70 == "effect" -- 326
            if ____cond70 then -- 326
                cnode.effect = v -- 327
                return true -- 327
            end -- 327
        until true -- 327
        return false -- 329
    end -- 321
    getGrid = function(enode) -- 331
        local grid = enode.props -- 332
        local node = dora.Grid(grid.file, grid.gridX, grid.gridY) -- 333
        local cnode = getNode(nil, enode, node, handleGridAttribute) -- 334
        return cnode -- 335
    end -- 331
end -- 331
local getSprite -- 339
do -- 339
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 341
        repeat -- 341
            local ____switch74 = k -- 341
            local ____cond74 = ____switch74 == "file" -- 341
            if ____cond74 then -- 341
                return true -- 343
            end -- 343
            ____cond74 = ____cond74 or ____switch74 == "textureRect" -- 343
            if ____cond74 then -- 343
                cnode.textureRect = v -- 344
                return true -- 344
            end -- 344
            ____cond74 = ____cond74 or ____switch74 == "depthWrite" -- 344
            if ____cond74 then -- 344
                cnode.depthWrite = v -- 345
                return true -- 345
            end -- 345
            ____cond74 = ____cond74 or ____switch74 == "blendFunc" -- 345
            if ____cond74 then -- 345
                cnode.blendFunc = v -- 346
                return true -- 346
            end -- 346
            ____cond74 = ____cond74 or ____switch74 == "effect" -- 346
            if ____cond74 then -- 346
                cnode.effect = v -- 347
                return true -- 347
            end -- 347
            ____cond74 = ____cond74 or ____switch74 == "alphaRef" -- 347
            if ____cond74 then -- 347
                cnode.alphaRef = v -- 348
                return true -- 348
            end -- 348
            ____cond74 = ____cond74 or ____switch74 == "uwrap" -- 348
            if ____cond74 then -- 348
                cnode.uwrap = v -- 349
                return true -- 349
            end -- 349
            ____cond74 = ____cond74 or ____switch74 == "vwrap" -- 349
            if ____cond74 then -- 349
                cnode.vwrap = v -- 350
                return true -- 350
            end -- 350
            ____cond74 = ____cond74 or ____switch74 == "filter" -- 350
            if ____cond74 then -- 350
                cnode.filter = v -- 351
                return true -- 351
            end -- 351
        until true -- 351
        return false -- 353
    end -- 341
    getSprite = function(enode) -- 355
        local sp = enode.props -- 356
        local node = dora.Sprite(sp.file) -- 357
        if node ~= nil then -- 357
            local cnode = getNode(nil, enode, node, handleSpriteAttribute) -- 359
            return cnode -- 360
        end -- 360
        return nil -- 362
    end -- 355
end -- 355
local getLabel -- 366
do -- 366
    local function handleLabelAttribute(cnode, _enode, k, v) -- 368
        repeat -- 368
            local ____switch79 = k -- 368
            local ____cond79 = ____switch79 == "fontName" or ____switch79 == "fontSize" or ____switch79 == "text" -- 368
            if ____cond79 then -- 368
                return true -- 370
            end -- 370
            ____cond79 = ____cond79 or ____switch79 == "alphaRef" -- 370
            if ____cond79 then -- 370
                cnode.alphaRef = v -- 371
                return true -- 371
            end -- 371
            ____cond79 = ____cond79 or ____switch79 == "textWidth" -- 371
            if ____cond79 then -- 371
                cnode.textWidth = v -- 372
                return true -- 372
            end -- 372
            ____cond79 = ____cond79 or ____switch79 == "lineGap" -- 372
            if ____cond79 then -- 372
                cnode.lineGap = v -- 373
                return true -- 373
            end -- 373
            ____cond79 = ____cond79 or ____switch79 == "blendFunc" -- 373
            if ____cond79 then -- 373
                cnode.blendFunc = v -- 374
                return true -- 374
            end -- 374
            ____cond79 = ____cond79 or ____switch79 == "depthWrite" -- 374
            if ____cond79 then -- 374
                cnode.depthWrite = v -- 375
                return true -- 375
            end -- 375
            ____cond79 = ____cond79 or ____switch79 == "batched" -- 375
            if ____cond79 then -- 375
                cnode.batched = v -- 376
                return true -- 376
            end -- 376
            ____cond79 = ____cond79 or ____switch79 == "effect" -- 376
            if ____cond79 then -- 376
                cnode.effect = v -- 377
                return true -- 377
            end -- 377
            ____cond79 = ____cond79 or ____switch79 == "alignment" -- 377
            if ____cond79 then -- 377
                cnode.alignment = v -- 378
                return true -- 378
            end -- 378
        until true -- 378
        return false -- 380
    end -- 368
    getLabel = function(enode) -- 382
        local label = enode.props -- 383
        local node = dora.Label(label.fontName, label.fontSize) -- 384
        if node ~= nil then -- 384
            local cnode = getNode(nil, enode, node, handleLabelAttribute) -- 386
            local ____enode_4 = enode -- 387
            local children = ____enode_4.children -- 387
            local text = label.text or "" -- 388
            for i = 1, #children do -- 388
                local child = children[i] -- 390
                if type(child) ~= "table" then -- 390
                    text = text .. tostring(child) -- 392
                end -- 392
            end -- 392
            node.text = text -- 395
            return cnode -- 396
        end -- 396
        return nil -- 398
    end -- 382
end -- 382
local getLine -- 402
do -- 402
    local function handleLineAttribute(cnode, enode, k, v) -- 404
        local line = enode.props -- 405
        repeat -- 405
            local ____switch86 = k -- 405
            local ____cond86 = ____switch86 == "verts" -- 405
            if ____cond86 then -- 405
                cnode:set( -- 407
                    v, -- 407
                    dora.Color(line.lineColor or 4294967295) -- 407
                ) -- 407
                return true -- 407
            end -- 407
            ____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 407
            if ____cond86 then -- 407
                cnode.depthWrite = v -- 408
                return true -- 408
            end -- 408
            ____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 408
            if ____cond86 then -- 408
                cnode.blendFunc = v -- 409
                return true -- 409
            end -- 409
        until true -- 409
        return false -- 411
    end -- 404
    getLine = function(enode) -- 413
        local node = dora.Line() -- 414
        local cnode = getNode(nil, enode, node, handleLineAttribute) -- 415
        return cnode -- 416
    end -- 413
end -- 413
local getParticle -- 420
do -- 420
    local function handleParticleAttribute(cnode, _enode, k, v) -- 422
        repeat -- 422
            local ____switch90 = k -- 422
            local ____cond90 = ____switch90 == "file" -- 422
            if ____cond90 then -- 422
                return true -- 424
            end -- 424
            ____cond90 = ____cond90 or ____switch90 == "emit" -- 424
            if ____cond90 then -- 424
                if v then -- 424
                    cnode:start() -- 425
                end -- 425
                return true -- 425
            end -- 425
            ____cond90 = ____cond90 or ____switch90 == "onFinished" -- 425
            if ____cond90 then -- 425
                cnode:slot("Finished", v) -- 426
                return true -- 426
            end -- 426
        until true -- 426
        return false -- 428
    end -- 422
    getParticle = function(enode) -- 430
        local particle = enode.props -- 431
        local node = dora.Particle(particle.file) -- 432
        if node ~= nil then -- 432
            local cnode = getNode(nil, enode, node, handleParticleAttribute) -- 434
            return cnode -- 435
        end -- 435
        return nil -- 437
    end -- 430
end -- 430
local getMenu -- 441
do -- 441
    local function handleMenuAttribute(cnode, _enode, k, v) -- 443
        repeat -- 443
            local ____switch96 = k -- 443
            local ____cond96 = ____switch96 == "enabled" -- 443
            if ____cond96 then -- 443
                cnode.enabled = v -- 445
                return true -- 445
            end -- 445
        until true -- 445
        return false -- 447
    end -- 443
    getMenu = function(enode) -- 449
        local node = dora.Menu() -- 450
        local cnode = getNode(nil, enode, node, handleMenuAttribute) -- 451
        return cnode -- 452
    end -- 449
end -- 449
local getPhysicsWorld -- 456
do -- 456
    local function handlePhysicsWorldAttribute(cnode, _enode, k, v) -- 458
        repeat -- 458
            local ____switch100 = k -- 458
            local ____cond100 = ____switch100 == "showDebug" -- 458
            if ____cond100 then -- 458
                cnode.showDebug = v -- 460
                return true -- 460
            end -- 460
        until true -- 460
        return false -- 462
    end -- 458
    getPhysicsWorld = function(enode) -- 464
        local node = dora.PhysicsWorld() -- 465
        local cnode = getNode(nil, enode, node, handlePhysicsWorldAttribute) -- 466
        return cnode -- 467
    end -- 464
end -- 464
local getBody -- 471
do -- 471
    local function handleBodyAttribute(cnode, _enode, k, v) -- 473
        repeat -- 473
            local ____switch104 = k -- 473
            local ____cond104 = ____switch104 == "type" or ____switch104 == "linearAcceleration" or ____switch104 == "fixedRotation" or ____switch104 == "bullet" -- 473
            if ____cond104 then -- 473
                return true -- 479
            end -- 479
            ____cond104 = ____cond104 or ____switch104 == "velocityX" -- 479
            if ____cond104 then -- 479
                cnode.velocityX = v -- 480
                return true -- 480
            end -- 480
            ____cond104 = ____cond104 or ____switch104 == "velocityY" -- 480
            if ____cond104 then -- 480
                cnode.velocityY = v -- 481
                return true -- 481
            end -- 481
            ____cond104 = ____cond104 or ____switch104 == "angularRate" -- 481
            if ____cond104 then -- 481
                cnode.angularRate = v -- 482
                return true -- 482
            end -- 482
            ____cond104 = ____cond104 or ____switch104 == "group" -- 482
            if ____cond104 then -- 482
                cnode.group = v -- 483
                return true -- 483
            end -- 483
            ____cond104 = ____cond104 or ____switch104 == "linearDamping" -- 483
            if ____cond104 then -- 483
                cnode.linearDamping = v -- 484
                return true -- 484
            end -- 484
            ____cond104 = ____cond104 or ____switch104 == "angularDamping" -- 484
            if ____cond104 then -- 484
                cnode.angularDamping = v -- 485
                return true -- 485
            end -- 485
            ____cond104 = ____cond104 or ____switch104 == "owner" -- 485
            if ____cond104 then -- 485
                cnode.owner = v -- 486
                return true -- 486
            end -- 486
            ____cond104 = ____cond104 or ____switch104 == "receivingContact" -- 486
            if ____cond104 then -- 486
                cnode.receivingContact = v -- 487
                return true -- 487
            end -- 487
            ____cond104 = ____cond104 or ____switch104 == "onBodyEnter" -- 487
            if ____cond104 then -- 487
                cnode:slot("BodyEnter", v) -- 488
                return true -- 488
            end -- 488
            ____cond104 = ____cond104 or ____switch104 == "onBodyLeave" -- 488
            if ____cond104 then -- 488
                cnode:slot("BodyLeave", v) -- 489
                return true -- 489
            end -- 489
            ____cond104 = ____cond104 or ____switch104 == "onContactStart" -- 489
            if ____cond104 then -- 489
                cnode:slot("ContactStart", v) -- 490
                return true -- 490
            end -- 490
            ____cond104 = ____cond104 or ____switch104 == "onContactEnd" -- 490
            if ____cond104 then -- 490
                cnode:slot("ContactEnd", v) -- 491
                return true -- 491
            end -- 491
            ____cond104 = ____cond104 or ____switch104 == "onContactFilter" -- 491
            if ____cond104 then -- 491
                cnode:onContactFilter(v) -- 492
                return true -- 492
            end -- 492
        until true -- 492
        return false -- 494
    end -- 473
    getBody = function(enode, world) -- 496
        local def = enode.props -- 497
        local bodyDef = dora.BodyDef() -- 498
        bodyDef.type = def.type -- 499
        if def.angle ~= nil then -- 499
            bodyDef.angle = def.angle -- 500
        end -- 500
        if def.angularDamping ~= nil then -- 500
            bodyDef.angularDamping = def.angularDamping -- 501
        end -- 501
        if def.bullet ~= nil then -- 501
            bodyDef.bullet = def.bullet -- 502
        end -- 502
        if def.fixedRotation ~= nil then -- 502
            bodyDef.fixedRotation = def.fixedRotation -- 503
        end -- 503
        if def.linearAcceleration ~= nil then -- 503
            bodyDef.linearAcceleration = def.linearAcceleration -- 504
        end -- 504
        if def.linearDamping ~= nil then -- 504
            bodyDef.linearDamping = def.linearDamping -- 505
        end -- 505
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 506
        local extraSensors = nil -- 507
        for i = 1, #enode.children do -- 507
            do -- 507
                local child = enode.children[i] -- 509
                if type(child) ~= "table" then -- 509
                    goto __continue112 -- 511
                end -- 511
                repeat -- 511
                    local ____switch114 = child.type -- 511
                    local ____cond114 = ____switch114 == "rect-shape" -- 511
                    if ____cond114 then -- 511
                        do -- 511
                            local shape = child.props -- 515
                            if shape.sensorTag ~= nil then -- 515
                                bodyDef:attachPolygonSensor( -- 517
                                    shape.sensorTag, -- 518
                                    shape.width, -- 519
                                    shape.height, -- 519
                                    shape.center or dora.Vec2.zero, -- 520
                                    shape.angle or 0 -- 521
                                ) -- 521
                            else -- 521
                                bodyDef:attachPolygon( -- 524
                                    shape.center or dora.Vec2.zero, -- 525
                                    shape.width, -- 526
                                    shape.height, -- 526
                                    shape.angle or 0, -- 527
                                    shape.density or 0, -- 528
                                    shape.friction or 0.4, -- 529
                                    shape.restitution or 0 -- 530
                                ) -- 530
                            end -- 530
                            break -- 533
                        end -- 533
                    end -- 533
                    ____cond114 = ____cond114 or ____switch114 == "polygon-shape" -- 533
                    if ____cond114 then -- 533
                        do -- 533
                            local shape = child.props -- 536
                            if shape.sensorTag ~= nil then -- 536
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 538
                            else -- 538
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 543
                            end -- 543
                            break -- 550
                        end -- 550
                    end -- 550
                    ____cond114 = ____cond114 or ____switch114 == "multi-shape" -- 550
                    if ____cond114 then -- 550
                        do -- 550
                            local shape = child.props -- 553
                            if shape.sensorTag ~= nil then -- 553
                                if extraSensors == nil then -- 553
                                    extraSensors = {} -- 555
                                end -- 555
                                extraSensors[#extraSensors + 1] = { -- 556
                                    shape.sensorTag, -- 556
                                    dora.BodyDef:multi(shape.verts) -- 556
                                } -- 556
                            else -- 556
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 558
                            end -- 558
                            break -- 565
                        end -- 565
                    end -- 565
                    ____cond114 = ____cond114 or ____switch114 == "disk-shape" -- 565
                    if ____cond114 then -- 565
                        do -- 565
                            local shape = child.props -- 568
                            if shape.sensorTag ~= nil then -- 568
                                bodyDef:attachDiskSensor(shape.sensorTag, shape.radius) -- 570
                            else -- 570
                                bodyDef:attachDisk( -- 575
                                    shape.center or dora.Vec2.zero, -- 576
                                    shape.radius, -- 577
                                    shape.density or 0, -- 578
                                    shape.friction or 0.4, -- 579
                                    shape.restitution or 0 -- 580
                                ) -- 580
                            end -- 580
                            break -- 583
                        end -- 583
                    end -- 583
                    ____cond114 = ____cond114 or ____switch114 == "chain-shape" -- 583
                    if ____cond114 then -- 583
                        do -- 583
                            local shape = child.props -- 586
                            if shape.sensorTag ~= nil then -- 586
                                if extraSensors == nil then -- 586
                                    extraSensors = {} -- 588
                                end -- 588
                                extraSensors[#extraSensors + 1] = { -- 589
                                    shape.sensorTag, -- 589
                                    dora.BodyDef:chain(shape.verts) -- 589
                                } -- 589
                            else -- 589
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 591
                            end -- 591
                            break -- 597
                        end -- 597
                    end -- 597
                until true -- 597
            end -- 597
            ::__continue112:: -- 597
        end -- 597
        local body = dora.Body(bodyDef, world) -- 601
        if extraSensors ~= nil then -- 601
            for i = 1, #extraSensors do -- 601
                local tag, def = table.unpack(extraSensors[i]) -- 604
                body:attachSensor(tag, def) -- 605
            end -- 605
        end -- 605
        local cnode = getNode(nil, enode, body, handleBodyAttribute) -- 608
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 608
            body.receivingContact = true -- 615
        end -- 615
        return cnode -- 617
    end -- 496
end -- 496
local function addChild(nodeStack, cnode, enode) -- 621
    if #nodeStack > 0 then -- 621
        local last = nodeStack[#nodeStack] -- 623
        last:addChild(cnode) -- 624
    end -- 624
    nodeStack[#nodeStack + 1] = cnode -- 626
    local ____enode_5 = enode -- 627
    local children = ____enode_5.children -- 627
    for i = 1, #children do -- 627
        visitNode(nodeStack, children[i], enode) -- 629
    end -- 629
    if #nodeStack > 1 then -- 629
        table.remove(nodeStack) -- 632
    end -- 632
end -- 621
local function drawNodeCheck(_nodeStack, enode, parent) -- 640
    if parent == nil or parent.type ~= "draw-node" then -- 640
        print(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 642
    end -- 642
end -- 640
local function actionCheck(_nodeStack, enode, parent) -- 646
    local unsupported = false -- 647
    if parent == nil then -- 647
        unsupported = true -- 649
    else -- 649
        repeat -- 649
            local ____switch142 = enode.type -- 649
            local ____cond142 = ____switch142 == "action" or ____switch142 == "spawn" or ____switch142 == "sequence" -- 649
            if ____cond142 then -- 649
                break -- 652
            end -- 652
            do -- 652
                unsupported = true -- 653
                break -- 653
            end -- 653
        until true -- 653
    end -- 653
    if unsupported then -- 653
        print(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 657
    end -- 657
end -- 646
local function bodyCheck(_nodeStack, enode, parent) -- 661
    if parent == nil or parent.type ~= "body" then -- 661
        print(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 663
    end -- 663
end -- 661
local actionMap = { -- 667
    ["anchor-x"] = dora.AnchorX, -- 670
    ["anchor-y"] = dora.AnchorY, -- 671
    angle = dora.Angle, -- 672
    ["angle-x"] = dora.AngleX, -- 673
    ["angle-y"] = dora.AngleY, -- 674
    width = dora.Width, -- 675
    height = dora.Height, -- 676
    opacity = dora.Opacity, -- 677
    roll = dora.Roll, -- 678
    scale = dora.Scale, -- 679
    ["scale-x"] = dora.ScaleX, -- 680
    ["scale-y"] = dora.ScaleY, -- 681
    ["skew-x"] = dora.SkewX, -- 682
    ["skew-y"] = dora.SkewY, -- 683
    ["move-x"] = dora.X, -- 684
    ["move-y"] = dora.Y, -- 685
    ["move-z"] = dora.Z -- 686
} -- 686
elementMap = { -- 689
    node = function(nodeStack, enode, parent) -- 690
        addChild( -- 691
            nodeStack, -- 691
            getNode(nil, enode), -- 691
            enode -- 691
        ) -- 691
    end, -- 690
    ["clip-node"] = function(nodeStack, enode, parent) -- 693
        addChild( -- 694
            nodeStack, -- 694
            getClipNode(enode), -- 694
            enode -- 694
        ) -- 694
    end, -- 693
    playable = function(nodeStack, enode, parent) -- 696
        local cnode = getPlayable(enode) -- 697
        if cnode ~= nil then -- 697
            addChild(nodeStack, cnode, enode) -- 699
        end -- 699
    end, -- 696
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 702
        local cnode = getDragonBone(enode) -- 703
        if cnode ~= nil then -- 703
            addChild(nodeStack, cnode, enode) -- 705
        end -- 705
    end, -- 702
    spine = function(nodeStack, enode, parent) -- 708
        local cnode = getSpine(enode) -- 709
        if cnode ~= nil then -- 709
            addChild(nodeStack, cnode, enode) -- 711
        end -- 711
    end, -- 708
    model = function(nodeStack, enode, parent) -- 714
        local cnode = getModel(enode) -- 715
        if cnode ~= nil then -- 715
            addChild(nodeStack, cnode, enode) -- 717
        end -- 717
    end, -- 714
    ["draw-node"] = function(nodeStack, enode, parent) -- 720
        addChild( -- 721
            nodeStack, -- 721
            getDrawNode(enode), -- 721
            enode -- 721
        ) -- 721
    end, -- 720
    dot = drawNodeCheck, -- 723
    segment = drawNodeCheck, -- 724
    polygon = drawNodeCheck, -- 725
    verts = drawNodeCheck, -- 726
    grid = function(nodeStack, enode, parent) -- 727
        addChild( -- 728
            nodeStack, -- 728
            getGrid(enode), -- 728
            enode -- 728
        ) -- 728
    end, -- 727
    sprite = function(nodeStack, enode, parent) -- 730
        local cnode = getSprite(enode) -- 731
        if cnode ~= nil then -- 731
            addChild(nodeStack, cnode, enode) -- 733
        end -- 733
    end, -- 730
    label = function(nodeStack, enode, parent) -- 736
        local cnode = getLabel(enode) -- 737
        if cnode ~= nil then -- 737
            addChild(nodeStack, cnode, enode) -- 739
        end -- 739
    end, -- 736
    line = function(nodeStack, enode, parent) -- 742
        addChild( -- 743
            nodeStack, -- 743
            getLine(enode), -- 743
            enode -- 743
        ) -- 743
    end, -- 742
    particle = function(nodeStack, enode, parent) -- 745
        local cnode = getParticle(enode) -- 746
        if cnode ~= nil then -- 746
            addChild(nodeStack, cnode, enode) -- 748
        end -- 748
    end, -- 745
    menu = function(nodeStack, enode, parent) -- 751
        addChild( -- 752
            nodeStack, -- 752
            getMenu(enode), -- 752
            enode -- 752
        ) -- 752
    end, -- 751
    action = function(_nodeStack, enode, parent) -- 754
        if #enode.children == 0 then -- 754
            return -- 755
        end -- 755
        local action = enode.props -- 756
        if action.ref == nil then -- 756
            return -- 757
        end -- 757
        local function visitAction(actionStack, enode) -- 758
            local createAction = actionMap[enode.type] -- 759
            if createAction ~= nil then -- 759
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 761
                return -- 762
            end -- 762
            repeat -- 762
                local ____switch171 = enode.type -- 762
                local ____cond171 = ____switch171 == "delay" -- 762
                if ____cond171 then -- 762
                    do -- 762
                        local item = enode.props -- 766
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 767
                        return -- 768
                    end -- 768
                end -- 768
                ____cond171 = ____cond171 or ____switch171 == "event" -- 768
                if ____cond171 then -- 768
                    do -- 768
                        local item = enode.props -- 771
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 772
                        return -- 773
                    end -- 773
                end -- 773
                ____cond171 = ____cond171 or ____switch171 == "hide" -- 773
                if ____cond171 then -- 773
                    do -- 773
                        actionStack[#actionStack + 1] = dora.Hide() -- 776
                        return -- 777
                    end -- 777
                end -- 777
                ____cond171 = ____cond171 or ____switch171 == "show" -- 777
                if ____cond171 then -- 777
                    do -- 777
                        actionStack[#actionStack + 1] = dora.Show() -- 780
                        return -- 781
                    end -- 781
                end -- 781
                ____cond171 = ____cond171 or ____switch171 == "move" -- 781
                if ____cond171 then -- 781
                    do -- 781
                        local item = enode.props -- 784
                        actionStack[#actionStack + 1] = dora.Move( -- 785
                            item.time, -- 785
                            dora.Vec2(item.startX, item.startY), -- 785
                            dora.Vec2(item.stopX, item.stopY), -- 785
                            item.easing -- 785
                        ) -- 785
                        return -- 786
                    end -- 786
                end -- 786
                ____cond171 = ____cond171 or ____switch171 == "spawn" -- 786
                if ____cond171 then -- 786
                    do -- 786
                        local spawnStack = {} -- 789
                        for i = 1, #enode.children do -- 789
                            visitAction(spawnStack, enode.children[i]) -- 791
                        end -- 791
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 793
                    end -- 793
                end -- 793
                ____cond171 = ____cond171 or ____switch171 == "sequence" -- 793
                if ____cond171 then -- 793
                    do -- 793
                        local sequenceStack = {} -- 796
                        for i = 1, #enode.children do -- 796
                            visitAction(sequenceStack, enode.children[i]) -- 798
                        end -- 798
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 800
                    end -- 800
                end -- 800
                do -- 800
                    print(("unsupported tag <" .. enode.type) .. "> under action definition") -- 803
                    break -- 804
                end -- 804
            until true -- 804
        end -- 758
        local actionStack = {} -- 807
        for i = 1, #enode.children do -- 807
            visitAction(actionStack, enode.children[i]) -- 809
        end -- 809
        if #actionStack == 1 then -- 809
            action.ref.current = actionStack[1] -- 812
        elseif #actionStack > 1 then -- 812
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 814
        end -- 814
    end, -- 754
    ["anchor-x"] = actionCheck, -- 817
    ["anchor-y"] = actionCheck, -- 818
    angle = actionCheck, -- 819
    ["angle-x"] = actionCheck, -- 820
    ["angle-y"] = actionCheck, -- 821
    delay = actionCheck, -- 822
    event = actionCheck, -- 823
    width = actionCheck, -- 824
    height = actionCheck, -- 825
    hide = actionCheck, -- 826
    show = actionCheck, -- 827
    move = actionCheck, -- 828
    opacity = actionCheck, -- 829
    roll = actionCheck, -- 830
    scale = actionCheck, -- 831
    ["scale-x"] = actionCheck, -- 832
    ["scale-y"] = actionCheck, -- 833
    ["skew-x"] = actionCheck, -- 834
    ["skew-y"] = actionCheck, -- 835
    ["move-x"] = actionCheck, -- 836
    ["move-y"] = actionCheck, -- 837
    ["move-z"] = actionCheck, -- 838
    spawn = actionCheck, -- 839
    sequence = actionCheck, -- 840
    ["physics-world"] = function(nodeStack, enode, _parent) -- 841
        addChild( -- 842
            nodeStack, -- 842
            getPhysicsWorld(enode), -- 842
            enode -- 842
        ) -- 842
    end, -- 841
    contact = function(nodeStack, enode, _parent) -- 844
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 845
        if world ~= nil then -- 845
            local contact = enode.props -- 847
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 848
        else -- 848
            print(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 850
        end -- 850
    end, -- 844
    body = function(nodeStack, enode, _parent) -- 853
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 854
        if world ~= nil then -- 854
            addChild( -- 856
                nodeStack, -- 856
                getBody(enode, world), -- 856
                enode -- 856
            ) -- 856
        else -- 856
            print(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 858
        end -- 858
    end, -- 853
    ["rect-shape"] = bodyCheck, -- 861
    ["polygon-shape"] = bodyCheck, -- 862
    ["multi-shape"] = bodyCheck, -- 863
    ["disk-shape"] = bodyCheck, -- 864
    ["chain-shape"] = bodyCheck, -- 865
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 866
        local joint = enode.props -- 867
        if joint.ref == nil then -- 867
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 869
            return -- 870
        end -- 870
        if joint.bodyA.current == nil then -- 870
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 873
            return -- 874
        end -- 874
        if joint.bodyB.current == nil then -- 874
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 877
            return -- 878
        end -- 878
        local ____joint_ref_9 = joint.ref -- 880
        local ____self_7 = dora.Joint -- 880
        local ____self_7_distance_8 = ____self_7.distance -- 880
        local ____joint_canCollide_6 = joint.canCollide -- 881
        if ____joint_canCollide_6 == nil then -- 881
            ____joint_canCollide_6 = false -- 881
        end -- 881
        ____joint_ref_9.current = ____self_7_distance_8( -- 880
            ____self_7, -- 880
            ____joint_canCollide_6, -- 881
            joint.bodyA.current, -- 882
            joint.bodyB.current, -- 883
            joint.anchorA or dora.Vec2.zero, -- 884
            joint.anchorB or dora.Vec2.zero, -- 885
            joint.frequency or 0, -- 886
            joint.damping or 0 -- 887
        ) -- 887
    end, -- 866
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 889
        local joint = enode.props -- 890
        if joint.ref == nil then -- 890
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 892
            return -- 893
        end -- 893
        if joint.bodyA.current == nil then -- 893
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 896
            return -- 897
        end -- 897
        if joint.bodyB.current == nil then -- 897
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 900
            return -- 901
        end -- 901
        local ____joint_ref_13 = joint.ref -- 903
        local ____self_11 = dora.Joint -- 903
        local ____self_11_friction_12 = ____self_11.friction -- 903
        local ____joint_canCollide_10 = joint.canCollide -- 904
        if ____joint_canCollide_10 == nil then -- 904
            ____joint_canCollide_10 = false -- 904
        end -- 904
        ____joint_ref_13.current = ____self_11_friction_12( -- 903
            ____self_11, -- 903
            ____joint_canCollide_10, -- 904
            joint.bodyA.current, -- 905
            joint.bodyB.current, -- 906
            joint.worldPos, -- 907
            joint.maxForce, -- 908
            joint.maxTorque -- 909
        ) -- 909
    end, -- 889
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 912
        local joint = enode.props -- 913
        if joint.ref == nil then -- 913
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 915
            return -- 916
        end -- 916
        if joint.jointA.current == nil then -- 916
            print(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 919
            return -- 920
        end -- 920
        if joint.jointB.current == nil then -- 920
            print(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 923
            return -- 924
        end -- 924
        local ____joint_ref_17 = joint.ref -- 926
        local ____self_15 = dora.Joint -- 926
        local ____self_15_gear_16 = ____self_15.gear -- 926
        local ____joint_canCollide_14 = joint.canCollide -- 927
        if ____joint_canCollide_14 == nil then -- 927
            ____joint_canCollide_14 = false -- 927
        end -- 927
        ____joint_ref_17.current = ____self_15_gear_16( -- 926
            ____self_15, -- 926
            ____joint_canCollide_14, -- 927
            joint.jointA.current, -- 928
            joint.jointB.current, -- 929
            joint.ratio or 1 -- 930
        ) -- 930
    end, -- 912
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 933
        local joint = enode.props -- 934
        if joint.ref == nil then -- 934
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 936
            return -- 937
        end -- 937
        if joint.bodyA.current == nil then -- 937
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 940
            return -- 941
        end -- 941
        if joint.bodyB.current == nil then -- 941
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 944
            return -- 945
        end -- 945
        local ____joint_ref_21 = joint.ref -- 947
        local ____self_19 = dora.Joint -- 947
        local ____self_19_spring_20 = ____self_19.spring -- 947
        local ____joint_canCollide_18 = joint.canCollide -- 948
        if ____joint_canCollide_18 == nil then -- 948
            ____joint_canCollide_18 = false -- 948
        end -- 948
        ____joint_ref_21.current = ____self_19_spring_20( -- 947
            ____self_19, -- 947
            ____joint_canCollide_18, -- 948
            joint.bodyA.current, -- 949
            joint.bodyB.current, -- 950
            joint.linearOffset, -- 951
            joint.angularOffset, -- 952
            joint.maxForce, -- 953
            joint.maxTorque, -- 954
            joint.correctionFactor or 1 -- 955
        ) -- 955
    end, -- 933
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 958
        local joint = enode.props -- 959
        if joint.ref == nil then -- 959
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 961
            return -- 962
        end -- 962
        if joint.body.current == nil then -- 962
            print(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 965
            return -- 966
        end -- 966
        local ____joint_ref_25 = joint.ref -- 968
        local ____self_23 = dora.Joint -- 968
        local ____self_23_move_24 = ____self_23.move -- 968
        local ____joint_canCollide_22 = joint.canCollide -- 969
        if ____joint_canCollide_22 == nil then -- 969
            ____joint_canCollide_22 = false -- 969
        end -- 969
        ____joint_ref_25.current = ____self_23_move_24( -- 968
            ____self_23, -- 968
            ____joint_canCollide_22, -- 969
            joint.body.current, -- 970
            joint.targetPos, -- 971
            joint.maxForce, -- 972
            joint.frequency, -- 973
            joint.damping or 0.7 -- 974
        ) -- 974
    end, -- 958
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 977
        local joint = enode.props -- 978
        if joint.ref == nil then -- 978
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 980
            return -- 981
        end -- 981
        if joint.bodyA.current == nil then -- 981
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 984
            return -- 985
        end -- 985
        if joint.bodyB.current == nil then -- 985
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 988
            return -- 989
        end -- 989
        local ____joint_ref_29 = joint.ref -- 991
        local ____self_27 = dora.Joint -- 991
        local ____self_27_prismatic_28 = ____self_27.prismatic -- 991
        local ____joint_canCollide_26 = joint.canCollide -- 992
        if ____joint_canCollide_26 == nil then -- 992
            ____joint_canCollide_26 = false -- 992
        end -- 992
        ____joint_ref_29.current = ____self_27_prismatic_28( -- 991
            ____self_27, -- 991
            ____joint_canCollide_26, -- 992
            joint.bodyA.current, -- 993
            joint.bodyB.current, -- 994
            joint.worldPos, -- 995
            joint.axisAngle, -- 996
            joint.lowerTranslation or 0, -- 997
            joint.upperTranslation or 0, -- 998
            joint.maxMotorForce or 0, -- 999
            joint.motorSpeed or 0 -- 1000
        ) -- 1000
    end, -- 977
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1003
        local joint = enode.props -- 1004
        if joint.ref == nil then -- 1004
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1006
            return -- 1007
        end -- 1007
        if joint.bodyA.current == nil then -- 1007
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1010
            return -- 1011
        end -- 1011
        if joint.bodyB.current == nil then -- 1011
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1014
            return -- 1015
        end -- 1015
        local ____joint_ref_33 = joint.ref -- 1017
        local ____self_31 = dora.Joint -- 1017
        local ____self_31_pulley_32 = ____self_31.pulley -- 1017
        local ____joint_canCollide_30 = joint.canCollide -- 1018
        if ____joint_canCollide_30 == nil then -- 1018
            ____joint_canCollide_30 = false -- 1018
        end -- 1018
        ____joint_ref_33.current = ____self_31_pulley_32( -- 1017
            ____self_31, -- 1017
            ____joint_canCollide_30, -- 1018
            joint.bodyA.current, -- 1019
            joint.bodyB.current, -- 1020
            joint.anchorA or dora.Vec2.zero, -- 1021
            joint.anchorB or dora.Vec2.zero, -- 1022
            joint.groundAnchorA, -- 1023
            joint.groundAnchorB, -- 1024
            joint.ratio or 1 -- 1025
        ) -- 1025
    end, -- 1003
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1028
        local joint = enode.props -- 1029
        if joint.ref == nil then -- 1029
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1031
            return -- 1032
        end -- 1032
        if joint.bodyA.current == nil then -- 1032
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1035
            return -- 1036
        end -- 1036
        if joint.bodyB.current == nil then -- 1036
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1039
            return -- 1040
        end -- 1040
        local ____joint_ref_37 = joint.ref -- 1042
        local ____self_35 = dora.Joint -- 1042
        local ____self_35_revolute_36 = ____self_35.revolute -- 1042
        local ____joint_canCollide_34 = joint.canCollide -- 1043
        if ____joint_canCollide_34 == nil then -- 1043
            ____joint_canCollide_34 = false -- 1043
        end -- 1043
        ____joint_ref_37.current = ____self_35_revolute_36( -- 1042
            ____self_35, -- 1042
            ____joint_canCollide_34, -- 1043
            joint.bodyA.current, -- 1044
            joint.bodyB.current, -- 1045
            joint.worldPos, -- 1046
            joint.lowerAngle or 0, -- 1047
            joint.upperAngle or 0, -- 1048
            joint.maxMotorTorque or 0, -- 1049
            joint.motorSpeed or 0 -- 1050
        ) -- 1050
    end, -- 1028
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1053
        local joint = enode.props -- 1054
        if joint.ref == nil then -- 1054
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1056
            return -- 1057
        end -- 1057
        if joint.bodyA.current == nil then -- 1057
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1060
            return -- 1061
        end -- 1061
        if joint.bodyB.current == nil then -- 1061
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1064
            return -- 1065
        end -- 1065
        local ____joint_ref_41 = joint.ref -- 1067
        local ____self_39 = dora.Joint -- 1067
        local ____self_39_rope_40 = ____self_39.rope -- 1067
        local ____joint_canCollide_38 = joint.canCollide -- 1068
        if ____joint_canCollide_38 == nil then -- 1068
            ____joint_canCollide_38 = false -- 1068
        end -- 1068
        ____joint_ref_41.current = ____self_39_rope_40( -- 1067
            ____self_39, -- 1067
            ____joint_canCollide_38, -- 1068
            joint.bodyA.current, -- 1069
            joint.bodyB.current, -- 1070
            joint.anchorA or dora.Vec2.zero, -- 1071
            joint.anchorB or dora.Vec2.zero, -- 1072
            joint.maxLength or 0 -- 1073
        ) -- 1073
    end, -- 1053
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1076
        local joint = enode.props -- 1077
        if joint.ref == nil then -- 1077
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1079
            return -- 1080
        end -- 1080
        if joint.bodyA.current == nil then -- 1080
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1083
            return -- 1084
        end -- 1084
        if joint.bodyB.current == nil then -- 1084
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1087
            return -- 1088
        end -- 1088
        local ____joint_ref_45 = joint.ref -- 1090
        local ____self_43 = dora.Joint -- 1090
        local ____self_43_weld_44 = ____self_43.weld -- 1090
        local ____joint_canCollide_42 = joint.canCollide -- 1091
        if ____joint_canCollide_42 == nil then -- 1091
            ____joint_canCollide_42 = false -- 1091
        end -- 1091
        ____joint_ref_45.current = ____self_43_weld_44( -- 1090
            ____self_43, -- 1090
            ____joint_canCollide_42, -- 1091
            joint.bodyA.current, -- 1092
            joint.bodyB.current, -- 1093
            joint.worldPos, -- 1094
            joint.frequency or 0, -- 1095
            joint.damping or 0 -- 1096
        ) -- 1096
    end, -- 1076
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1099
        local joint = enode.props -- 1100
        if joint.ref == nil then -- 1100
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1102
            return -- 1103
        end -- 1103
        if joint.bodyA.current == nil then -- 1103
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1106
            return -- 1107
        end -- 1107
        if joint.bodyB.current == nil then -- 1107
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1110
            return -- 1111
        end -- 1111
        local ____joint_ref_49 = joint.ref -- 1113
        local ____self_47 = dora.Joint -- 1113
        local ____self_47_wheel_48 = ____self_47.wheel -- 1113
        local ____joint_canCollide_46 = joint.canCollide -- 1114
        if ____joint_canCollide_46 == nil then -- 1114
            ____joint_canCollide_46 = false -- 1114
        end -- 1114
        ____joint_ref_49.current = ____self_47_wheel_48( -- 1113
            ____self_47, -- 1113
            ____joint_canCollide_46, -- 1114
            joint.bodyA.current, -- 1115
            joint.bodyB.current, -- 1116
            joint.worldPos, -- 1117
            joint.axisAngle, -- 1118
            joint.maxMotorTorque or 0, -- 1119
            joint.motorSpeed or 0, -- 1120
            joint.frequency or 0, -- 1121
            joint.damping or 0.7 -- 1122
        ) -- 1122
    end -- 1099
} -- 1099
function ____exports.useRef(item) -- 1167
    local ____item_50 = item -- 1168
    if ____item_50 == nil then -- 1168
        ____item_50 = nil -- 1168
    end -- 1168
    return {current = ____item_50} -- 1168
end -- 1167
return ____exports -- 1167
