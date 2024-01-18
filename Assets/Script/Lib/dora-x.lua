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
function visitNode(nodeStack, node, parent) -- 1111
    if type(node) ~= "table" then -- 1111
        return -- 1113
    end -- 1113
    local enode = node -- 1115
    if enode.type == nil then -- 1115
        local list = node -- 1117
        local stack = {} -- 1118
        for i = 1, #list do -- 1118
            visitNode(stack, list[i], parent) -- 1120
            for i = 1, #stack do -- 1120
                nodeStack[#nodeStack + 1] = stack[i] -- 1122
            end -- 1122
        end -- 1122
    else -- 1122
        local handler = elementMap[enode.type] -- 1126
        if handler ~= nil then -- 1126
            handler(nodeStack, enode, parent) -- 1128
        else -- 1128
            print(("unsupported tag <" .. enode.type) .. ">") -- 1130
        end -- 1130
    end -- 1130
end -- 1130
function ____exports.toNode(enode) -- 1135
    local nodeStack = {} -- 1136
    visitNode(nodeStack, enode) -- 1137
    if #nodeStack == 1 then -- 1137
        return nodeStack[1] -- 1139
    elseif #nodeStack > 1 then -- 1139
        local node = dora.Node() -- 1141
        for i = 1, #nodeStack do -- 1141
            node:addChild(nodeStack[i]) -- 1143
        end -- 1143
        return node -- 1145
    end -- 1145
    return nil -- 1147
end -- 1135
____exports.React = {} -- 1135
local React = ____exports.React -- 1135
do -- 1135
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
                ____cond25 = ____cond25 or ____switch25 == "onActionEnd" -- 102
                if ____cond25 then -- 102
                    cnode:slot("ActionEnd", v) -- 103
                    break -- 103
                end -- 103
                ____cond25 = ____cond25 or ____switch25 == "onTapFilter" -- 103
                if ____cond25 then -- 103
                    cnode:slot("TapFilter", v) -- 104
                    break -- 104
                end -- 104
                ____cond25 = ____cond25 or ____switch25 == "onTapBegan" -- 104
                if ____cond25 then -- 104
                    cnode:slot("TapBegan", v) -- 105
                    break -- 105
                end -- 105
                ____cond25 = ____cond25 or ____switch25 == "onTapEnded" -- 105
                if ____cond25 then -- 105
                    cnode:slot("TapEnded", v) -- 106
                    break -- 106
                end -- 106
                ____cond25 = ____cond25 or ____switch25 == "onTapped" -- 106
                if ____cond25 then -- 106
                    cnode:slot("Tapped", v) -- 107
                    break -- 107
                end -- 107
                ____cond25 = ____cond25 or ____switch25 == "onTapMoved" -- 107
                if ____cond25 then -- 107
                    cnode:slot("TapMoved", v) -- 108
                    break -- 108
                end -- 108
                ____cond25 = ____cond25 or ____switch25 == "onMouseWheel" -- 108
                if ____cond25 then -- 108
                    cnode:slot("MouseWheel", v) -- 109
                    break -- 109
                end -- 109
                ____cond25 = ____cond25 or ____switch25 == "onGesture" -- 109
                if ____cond25 then -- 109
                    cnode:slot("Gesture", v) -- 110
                    break -- 110
                end -- 110
                ____cond25 = ____cond25 or ____switch25 == "onEnter" -- 110
                if ____cond25 then -- 110
                    cnode:slot("Enter", v) -- 111
                    break -- 111
                end -- 111
                ____cond25 = ____cond25 or ____switch25 == "onExit" -- 111
                if ____cond25 then -- 111
                    cnode:slot("Exit", v) -- 112
                    break -- 112
                end -- 112
                ____cond25 = ____cond25 or ____switch25 == "onCleanup" -- 112
                if ____cond25 then -- 112
                    cnode:slot("Cleanup", v) -- 113
                    break -- 113
                end -- 113
                ____cond25 = ____cond25 or ____switch25 == "onKeyDown" -- 113
                if ____cond25 then -- 113
                    cnode:slot("KeyDown", v) -- 114
                    break -- 114
                end -- 114
                ____cond25 = ____cond25 or ____switch25 == "onKeyUp" -- 114
                if ____cond25 then -- 114
                    cnode:slot("KeyUp", v) -- 115
                    break -- 115
                end -- 115
                ____cond25 = ____cond25 or ____switch25 == "onKeyPressed" -- 115
                if ____cond25 then -- 115
                    cnode:slot("KeyPressed", v) -- 116
                    break -- 116
                end -- 116
                ____cond25 = ____cond25 or ____switch25 == "onAttachIME" -- 116
                if ____cond25 then -- 116
                    cnode:slot("AttachIME", v) -- 117
                    break -- 117
                end -- 117
                ____cond25 = ____cond25 or ____switch25 == "onDetachIME" -- 117
                if ____cond25 then -- 117
                    cnode:slot("DetachIME", v) -- 118
                    break -- 118
                end -- 118
                ____cond25 = ____cond25 or ____switch25 == "onTextInput" -- 118
                if ____cond25 then -- 118
                    cnode:slot("TextInput", v) -- 119
                    break -- 119
                end -- 119
                ____cond25 = ____cond25 or ____switch25 == "onTextEditing" -- 119
                if ____cond25 then -- 119
                    cnode:slot("TextEditing", v) -- 120
                    break -- 120
                end -- 120
                ____cond25 = ____cond25 or ____switch25 == "onButtonDown" -- 120
                if ____cond25 then -- 120
                    cnode:slot("ButtonDown", v) -- 121
                    break -- 121
                end -- 121
                ____cond25 = ____cond25 or ____switch25 == "onButtonUp" -- 121
                if ____cond25 then -- 121
                    cnode:slot("ButtonUp", v) -- 122
                    break -- 122
                end -- 122
                ____cond25 = ____cond25 or ____switch25 == "onAxis" -- 122
                if ____cond25 then -- 122
                    cnode:slot("Axis", v) -- 123
                    break -- 123
                end -- 123
                do -- 123
                    do -- 123
                        if attribHandler then -- 123
                            if not attribHandler(cnode, enode, k, v) then -- 123
                                cnode[k] = v -- 127
                            end -- 127
                        else -- 127
                            cnode[k] = v -- 130
                        end -- 130
                        break -- 132
                    end -- 132
                end -- 132
            until true -- 132
        end -- 132
        if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 132
            cnode.touchEnabled = true -- 145
        end -- 145
        if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 145
            cnode.keyboardEnabled = true -- 152
        end -- 152
        if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 152
            cnode.controllerEnabled = true -- 159
        end -- 159
    end -- 159
    if anchor ~= nil then -- 159
        cnode.anchor = anchor -- 162
    end -- 162
    if color3 ~= nil then -- 162
        cnode.color3 = color3 -- 163
    end -- 163
    return cnode -- 164
end -- 91
local getClipNode -- 167
do -- 167
    local function handleClipNodeAttribute(cnode, _enode, k, v) -- 169
        repeat -- 169
            local ____switch37 = k -- 169
            local ____cond37 = ____switch37 == "stencil" -- 169
            if ____cond37 then -- 169
                cnode.stencil = ____exports.toNode(v) -- 176
                return true -- 176
            end -- 176
        until true -- 176
        return false -- 178
    end -- 169
    getClipNode = function(enode) -- 180
        return getNode( -- 181
            nil, -- 181
            enode, -- 181
            dora.ClipNode(), -- 181
            handleClipNodeAttribute -- 181
        ) -- 181
    end -- 180
end -- 180
local getPlayable -- 185
local getDragonBone -- 186
local getSpine -- 187
local getModel -- 188
do -- 188
    local function handlePlayableAttribute(cnode, enode, k, v) -- 190
        repeat -- 190
            local ____switch41 = k -- 190
            local ____cond41 = ____switch41 == "file" -- 190
            if ____cond41 then -- 190
                return true -- 192
            end -- 192
            ____cond41 = ____cond41 or ____switch41 == "play" -- 192
            if ____cond41 then -- 192
                cnode:play(v, enode.props.loop == true) -- 193
                return true -- 193
            end -- 193
            ____cond41 = ____cond41 or ____switch41 == "loop" -- 193
            if ____cond41 then -- 193
                return true -- 194
            end -- 194
            ____cond41 = ____cond41 or ____switch41 == "onAnimationEnd" -- 194
            if ____cond41 then -- 194
                cnode:slot("AnimationEnd", v) -- 195
                return true -- 195
            end -- 195
        until true -- 195
        return false -- 197
    end -- 190
    getPlayable = function(enode, cnode, attribHandler) -- 199
        if attribHandler == nil then -- 199
            attribHandler = handlePlayableAttribute -- 200
        end -- 200
        cnode = cnode or dora.Playable(enode.props.file) or nil -- 201
        if cnode ~= nil then -- 201
            return getNode(nil, enode, cnode, attribHandler) -- 203
        end -- 203
        return nil -- 205
    end -- 199
    local function handleDragonBoneAttribute(cnode, enode, k, v) -- 208
        repeat -- 208
            local ____switch45 = k -- 208
            local ____cond45 = ____switch45 == "showDebug" -- 208
            if ____cond45 then -- 208
                cnode.showDebug = v -- 210
                return true -- 210
            end -- 210
            ____cond45 = ____cond45 or ____switch45 == "hitTestEnabled" -- 210
            if ____cond45 then -- 210
                cnode.hitTestEnabled = true -- 211
                return true -- 211
            end -- 211
        until true -- 211
        return handlePlayableAttribute(cnode, enode, k, v) -- 213
    end -- 208
    getDragonBone = function(enode) -- 215
        local node = dora.DragonBone(enode.props.file) -- 216
        if node ~= nil then -- 216
            local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 218
            return cnode -- 219
        end -- 219
        return nil -- 221
    end -- 215
    local function handleSpineAttribute(cnode, enode, k, v) -- 224
        repeat -- 224
            local ____switch49 = k -- 224
            local ____cond49 = ____switch49 == "showDebug" -- 224
            if ____cond49 then -- 224
                cnode.showDebug = v -- 226
                return true -- 226
            end -- 226
            ____cond49 = ____cond49 or ____switch49 == "hitTestEnabled" -- 226
            if ____cond49 then -- 226
                cnode.hitTestEnabled = true -- 227
                return true -- 227
            end -- 227
        until true -- 227
        return handlePlayableAttribute(cnode, enode, k, v) -- 229
    end -- 224
    getSpine = function(enode) -- 231
        local node = dora.Spine(enode.props.file) -- 232
        if node ~= nil then -- 232
            local cnode = getPlayable(enode, node, handleSpineAttribute) -- 234
            return cnode -- 235
        end -- 235
        return nil -- 237
    end -- 231
    local function handleModelAttribute(cnode, enode, k, v) -- 240
        repeat -- 240
            local ____switch53 = k -- 240
            local ____cond53 = ____switch53 == "reversed" -- 240
            if ____cond53 then -- 240
                cnode.reversed = v -- 242
                return true -- 242
            end -- 242
        until true -- 242
        return handlePlayableAttribute(cnode, enode, k, v) -- 244
    end -- 240
    getModel = function(enode) -- 246
        local node = dora.Model(enode.props.file) -- 247
        if node ~= nil then -- 247
            local cnode = getPlayable(enode, node, handleModelAttribute) -- 249
            return cnode -- 250
        end -- 250
        return nil -- 252
    end -- 246
end -- 246
local getDrawNode -- 256
do -- 256
    local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 258
        repeat -- 258
            local ____switch58 = k -- 258
            local ____cond58 = ____switch58 == "depthWrite" -- 258
            if ____cond58 then -- 258
                cnode.depthWrite = v -- 260
                return true -- 260
            end -- 260
            ____cond58 = ____cond58 or ____switch58 == "blendFunc" -- 260
            if ____cond58 then -- 260
                cnode.blendFunc = v -- 261
                return true -- 261
            end -- 261
        until true -- 261
        return false -- 263
    end -- 258
    getDrawNode = function(enode) -- 265
        local node = dora.DrawNode() -- 266
        local cnode = getNode(nil, enode, node, handleDrawNodeAttribute) -- 267
        local ____enode_3 = enode -- 268
        local children = ____enode_3.children -- 268
        for i = 1, #children do -- 268
            do -- 268
                local child = children[i] -- 270
                if type(child) ~= "table" then -- 270
                    goto __continue60 -- 272
                end -- 272
                repeat -- 272
                    local ____switch62 = child.type -- 272
                    local ____cond62 = ____switch62 == "dot" -- 272
                    if ____cond62 then -- 272
                        do -- 272
                            local dot = child.props -- 276
                            node:drawDot( -- 277
                                dora.Vec2(dot.x, dot.y), -- 278
                                dot.radius, -- 279
                                dora.Color(dot.color or 4294967295) -- 280
                            ) -- 280
                            break -- 282
                        end -- 282
                    end -- 282
                    ____cond62 = ____cond62 or ____switch62 == "segment" -- 282
                    if ____cond62 then -- 282
                        do -- 282
                            local segment = child.props -- 285
                            node:drawSegment( -- 286
                                dora.Vec2(segment.startX, segment.startY), -- 287
                                dora.Vec2(segment.stopX, segment.stopY), -- 288
                                segment.radius, -- 289
                                dora.Color(segment.color or 4294967295) -- 290
                            ) -- 290
                            break -- 292
                        end -- 292
                    end -- 292
                    ____cond62 = ____cond62 or ____switch62 == "polygon" -- 292
                    if ____cond62 then -- 292
                        do -- 292
                            local poly = child.props -- 295
                            node:drawPolygon( -- 296
                                poly.verts, -- 297
                                dora.Color(poly.fillColor or 4294967295), -- 298
                                poly.borderWidth or 0, -- 299
                                dora.Color(poly.borderColor or 4294967295) -- 300
                            ) -- 300
                            break -- 302
                        end -- 302
                    end -- 302
                    ____cond62 = ____cond62 or ____switch62 == "verts" -- 302
                    if ____cond62 then -- 302
                        do -- 302
                            local verts = child.props -- 305
                            node:drawVertices(__TS__ArrayMap( -- 306
                                verts.verts, -- 306
                                function(____, ____bindingPattern0) -- 306
                                    local color -- 306
                                    local vert -- 306
                                    vert = ____bindingPattern0[1] -- 306
                                    color = ____bindingPattern0[2] -- 306
                                    return { -- 306
                                        vert, -- 306
                                        dora.Color(color) -- 306
                                    } -- 306
                                end -- 306
                            )) -- 306
                            break -- 307
                        end -- 307
                    end -- 307
                until true -- 307
            end -- 307
            ::__continue60:: -- 307
        end -- 307
        return cnode -- 311
    end -- 265
end -- 265
local getGrid -- 315
do -- 315
    local function handleGridAttribute(cnode, _enode, k, v) -- 317
        repeat -- 317
            local ____switch70 = k -- 317
            local ____cond70 = ____switch70 == "file" or ____switch70 == "gridX" or ____switch70 == "gridY" -- 317
            if ____cond70 then -- 317
                return true -- 319
            end -- 319
            ____cond70 = ____cond70 or ____switch70 == "textureRect" -- 319
            if ____cond70 then -- 319
                cnode.textureRect = v -- 320
                return true -- 320
            end -- 320
            ____cond70 = ____cond70 or ____switch70 == "depthWrite" -- 320
            if ____cond70 then -- 320
                cnode.depthWrite = v -- 321
                return true -- 321
            end -- 321
            ____cond70 = ____cond70 or ____switch70 == "blendFunc" -- 321
            if ____cond70 then -- 321
                cnode.blendFunc = v -- 322
                return true -- 322
            end -- 322
            ____cond70 = ____cond70 or ____switch70 == "effect" -- 322
            if ____cond70 then -- 322
                cnode.effect = v -- 323
                return true -- 323
            end -- 323
        until true -- 323
        return false -- 325
    end -- 317
    getGrid = function(enode) -- 327
        local grid = enode.props -- 328
        local node = dora.Grid(grid.file, grid.gridX, grid.gridY) -- 329
        local cnode = getNode(nil, enode, node, handleGridAttribute) -- 330
        return cnode -- 331
    end -- 327
end -- 327
local getSprite -- 335
do -- 335
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 337
        repeat -- 337
            local ____switch74 = k -- 337
            local ____cond74 = ____switch74 == "file" -- 337
            if ____cond74 then -- 337
                return true -- 339
            end -- 339
            ____cond74 = ____cond74 or ____switch74 == "textureRect" -- 339
            if ____cond74 then -- 339
                cnode.textureRect = v -- 340
                return true -- 340
            end -- 340
            ____cond74 = ____cond74 or ____switch74 == "depthWrite" -- 340
            if ____cond74 then -- 340
                cnode.depthWrite = v -- 341
                return true -- 341
            end -- 341
            ____cond74 = ____cond74 or ____switch74 == "blendFunc" -- 341
            if ____cond74 then -- 341
                cnode.blendFunc = v -- 342
                return true -- 342
            end -- 342
            ____cond74 = ____cond74 or ____switch74 == "effect" -- 342
            if ____cond74 then -- 342
                cnode.effect = v -- 343
                return true -- 343
            end -- 343
            ____cond74 = ____cond74 or ____switch74 == "alphaRef" -- 343
            if ____cond74 then -- 343
                cnode.alphaRef = v -- 344
                return true -- 344
            end -- 344
            ____cond74 = ____cond74 or ____switch74 == "uwrap" -- 344
            if ____cond74 then -- 344
                cnode.uwrap = v -- 345
                return true -- 345
            end -- 345
            ____cond74 = ____cond74 or ____switch74 == "vwrap" -- 345
            if ____cond74 then -- 345
                cnode.vwrap = v -- 346
                return true -- 346
            end -- 346
            ____cond74 = ____cond74 or ____switch74 == "filter" -- 346
            if ____cond74 then -- 346
                cnode.filter = v -- 347
                return true -- 347
            end -- 347
        until true -- 347
        return false -- 349
    end -- 337
    getSprite = function(enode) -- 351
        local sp = enode.props -- 352
        local node = dora.Sprite(sp.file) -- 353
        if node ~= nil then -- 353
            local cnode = getNode(nil, enode, node, handleSpriteAttribute) -- 355
            return cnode -- 356
        end -- 356
        return nil -- 358
    end -- 351
end -- 351
local getLabel -- 362
do -- 362
    local function handleLabelAttribute(cnode, _enode, k, v) -- 364
        repeat -- 364
            local ____switch79 = k -- 364
            local ____cond79 = ____switch79 == "fontName" or ____switch79 == "fontSize" or ____switch79 == "text" -- 364
            if ____cond79 then -- 364
                return true -- 366
            end -- 366
            ____cond79 = ____cond79 or ____switch79 == "alphaRef" -- 366
            if ____cond79 then -- 366
                cnode.alphaRef = v -- 367
                return true -- 367
            end -- 367
            ____cond79 = ____cond79 or ____switch79 == "textWidth" -- 367
            if ____cond79 then -- 367
                cnode.textWidth = v -- 368
                return true -- 368
            end -- 368
            ____cond79 = ____cond79 or ____switch79 == "lineGap" -- 368
            if ____cond79 then -- 368
                cnode.lineGap = v -- 369
                return true -- 369
            end -- 369
            ____cond79 = ____cond79 or ____switch79 == "blendFunc" -- 369
            if ____cond79 then -- 369
                cnode.blendFunc = v -- 370
                return true -- 370
            end -- 370
            ____cond79 = ____cond79 or ____switch79 == "depthWrite" -- 370
            if ____cond79 then -- 370
                cnode.depthWrite = v -- 371
                return true -- 371
            end -- 371
            ____cond79 = ____cond79 or ____switch79 == "batched" -- 371
            if ____cond79 then -- 371
                cnode.batched = v -- 372
                return true -- 372
            end -- 372
            ____cond79 = ____cond79 or ____switch79 == "effect" -- 372
            if ____cond79 then -- 372
                cnode.effect = v -- 373
                return true -- 373
            end -- 373
            ____cond79 = ____cond79 or ____switch79 == "alignment" -- 373
            if ____cond79 then -- 373
                cnode.alignment = v -- 374
                return true -- 374
            end -- 374
        until true -- 374
        return false -- 376
    end -- 364
    getLabel = function(enode) -- 378
        local label = enode.props -- 379
        local node = dora.Label(label.fontName, label.fontSize) -- 380
        if node ~= nil then -- 380
            local cnode = getNode(nil, enode, node, handleLabelAttribute) -- 382
            local ____enode_4 = enode -- 383
            local children = ____enode_4.children -- 383
            local text = label.text or "" -- 384
            for i = 1, #children do -- 384
                local child = children[i] -- 386
                if type(child) ~= "table" then -- 386
                    text = text .. tostring(child) -- 388
                end -- 388
            end -- 388
            node.text = text -- 391
            return cnode -- 392
        end -- 392
        return nil -- 394
    end -- 378
end -- 378
local getLine -- 398
do -- 398
    local function handleLineAttribute(cnode, enode, k, v) -- 400
        local line = enode.props -- 401
        repeat -- 401
            local ____switch86 = k -- 401
            local ____cond86 = ____switch86 == "verts" -- 401
            if ____cond86 then -- 401
                cnode:set( -- 403
                    v, -- 403
                    dora.Color(line.lineColor or 4294967295) -- 403
                ) -- 403
                return true -- 403
            end -- 403
            ____cond86 = ____cond86 or ____switch86 == "depthWrite" -- 403
            if ____cond86 then -- 403
                cnode.depthWrite = v -- 404
                return true -- 404
            end -- 404
            ____cond86 = ____cond86 or ____switch86 == "blendFunc" -- 404
            if ____cond86 then -- 404
                cnode.blendFunc = v -- 405
                return true -- 405
            end -- 405
        until true -- 405
        return false -- 407
    end -- 400
    getLine = function(enode) -- 409
        local node = dora.Line() -- 410
        local cnode = getNode(nil, enode, node, handleLineAttribute) -- 411
        return cnode -- 412
    end -- 409
end -- 409
local getParticle -- 416
do -- 416
    local function handleParticleAttribute(cnode, _enode, k, v) -- 418
        repeat -- 418
            local ____switch90 = k -- 418
            local ____cond90 = ____switch90 == "file" -- 418
            if ____cond90 then -- 418
                return true -- 420
            end -- 420
            ____cond90 = ____cond90 or ____switch90 == "emit" -- 420
            if ____cond90 then -- 420
                if v then -- 420
                    cnode:start() -- 421
                end -- 421
                return true -- 421
            end -- 421
            ____cond90 = ____cond90 or ____switch90 == "onFinished" -- 421
            if ____cond90 then -- 421
                cnode:slot("Finished", v) -- 422
                return true -- 422
            end -- 422
        until true -- 422
        return false -- 424
    end -- 418
    getParticle = function(enode) -- 426
        local particle = enode.props -- 427
        local node = dora.Particle(particle.file) -- 428
        if node ~= nil then -- 428
            local cnode = getNode(nil, enode, node, handleParticleAttribute) -- 430
            return cnode -- 431
        end -- 431
        return nil -- 433
    end -- 426
end -- 426
local getMenu -- 437
do -- 437
    local function handleMenuAttribute(cnode, _enode, k, v) -- 439
        repeat -- 439
            local ____switch96 = k -- 439
            local ____cond96 = ____switch96 == "enabled" -- 439
            if ____cond96 then -- 439
                cnode.enabled = v -- 441
                return true -- 441
            end -- 441
        until true -- 441
        return false -- 443
    end -- 439
    getMenu = function(enode) -- 445
        local node = dora.Menu() -- 446
        local cnode = getNode(nil, enode, node, handleMenuAttribute) -- 447
        return cnode -- 448
    end -- 445
end -- 445
local getPhysicsWorld -- 452
do -- 452
    local function handlePhysicsWorldAttribute(cnode, _enode, k, v) -- 454
        repeat -- 454
            local ____switch100 = k -- 454
            local ____cond100 = ____switch100 == "showDebug" -- 454
            if ____cond100 then -- 454
                cnode.showDebug = v -- 456
                return true -- 456
            end -- 456
        until true -- 456
        return false -- 458
    end -- 454
    getPhysicsWorld = function(enode) -- 460
        local node = dora.PhysicsWorld() -- 461
        local cnode = getNode(nil, enode, node, handlePhysicsWorldAttribute) -- 462
        return cnode -- 463
    end -- 460
end -- 460
local getBody -- 467
do -- 467
    local function handleBodyAttribute(cnode, _enode, k, v) -- 469
        repeat -- 469
            local ____switch104 = k -- 469
            local ____cond104 = ____switch104 == "type" or ____switch104 == "linearAcceleration" or ____switch104 == "fixedRotation" or ____switch104 == "bullet" -- 469
            if ____cond104 then -- 469
                return true -- 475
            end -- 475
            ____cond104 = ____cond104 or ____switch104 == "velocityX" -- 475
            if ____cond104 then -- 475
                cnode.velocityX = v -- 476
                return true -- 476
            end -- 476
            ____cond104 = ____cond104 or ____switch104 == "velocityY" -- 476
            if ____cond104 then -- 476
                cnode.velocityY = v -- 477
                return true -- 477
            end -- 477
            ____cond104 = ____cond104 or ____switch104 == "angularRate" -- 477
            if ____cond104 then -- 477
                cnode.angularRate = v -- 478
                return true -- 478
            end -- 478
            ____cond104 = ____cond104 or ____switch104 == "group" -- 478
            if ____cond104 then -- 478
                cnode.group = v -- 479
                return true -- 479
            end -- 479
            ____cond104 = ____cond104 or ____switch104 == "linearDamping" -- 479
            if ____cond104 then -- 479
                cnode.linearDamping = v -- 480
                return true -- 480
            end -- 480
            ____cond104 = ____cond104 or ____switch104 == "angularDamping" -- 480
            if ____cond104 then -- 480
                cnode.angularDamping = v -- 481
                return true -- 481
            end -- 481
            ____cond104 = ____cond104 or ____switch104 == "owner" -- 481
            if ____cond104 then -- 481
                cnode.owner = v -- 482
                return true -- 482
            end -- 482
            ____cond104 = ____cond104 or ____switch104 == "receivingContact" -- 482
            if ____cond104 then -- 482
                cnode.receivingContact = v -- 483
                return true -- 483
            end -- 483
            ____cond104 = ____cond104 or ____switch104 == "onBodyEnter" -- 483
            if ____cond104 then -- 483
                cnode:slot("BodyEnter", v) -- 484
                return true -- 484
            end -- 484
            ____cond104 = ____cond104 or ____switch104 == "onBodyLeave" -- 484
            if ____cond104 then -- 484
                cnode:slot("BodyLeave", v) -- 485
                return true -- 485
            end -- 485
            ____cond104 = ____cond104 or ____switch104 == "onContactStart" -- 485
            if ____cond104 then -- 485
                cnode:slot("ContactStart", v) -- 486
                return true -- 486
            end -- 486
            ____cond104 = ____cond104 or ____switch104 == "onContactEnd" -- 486
            if ____cond104 then -- 486
                cnode:slot("ContactEnd", v) -- 487
                return true -- 487
            end -- 487
        until true -- 487
        return false -- 489
    end -- 469
    getBody = function(enode, world) -- 491
        local def = enode.props -- 492
        local bodyDef = dora.BodyDef() -- 493
        bodyDef.type = def.type -- 494
        if def.angle ~= nil then -- 494
            bodyDef.angle = def.angle -- 495
        end -- 495
        if def.angularDamping ~= nil then -- 495
            bodyDef.angularDamping = def.angularDamping -- 496
        end -- 496
        if def.bullet ~= nil then -- 496
            bodyDef.bullet = def.bullet -- 497
        end -- 497
        if def.fixedRotation ~= nil then -- 497
            bodyDef.fixedRotation = def.fixedRotation -- 498
        end -- 498
        if def.linearAcceleration ~= nil then -- 498
            bodyDef.linearAcceleration = def.linearAcceleration -- 499
        end -- 499
        if def.linearDamping ~= nil then -- 499
            bodyDef.linearDamping = def.linearDamping -- 500
        end -- 500
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 501
        local extraSensors = nil -- 502
        for i = 1, #enode.children do -- 502
            do -- 502
                local child = enode.children[i] -- 504
                if type(child) ~= "table" then -- 504
                    goto __continue112 -- 506
                end -- 506
                repeat -- 506
                    local ____switch114 = child.type -- 506
                    local ____cond114 = ____switch114 == "rect-shape" -- 506
                    if ____cond114 then -- 506
                        do -- 506
                            local shape = child.props -- 510
                            if shape.sensorTag ~= nil then -- 510
                                bodyDef:attachPolygonSensor( -- 512
                                    shape.sensorTag, -- 513
                                    shape.width, -- 514
                                    shape.height, -- 514
                                    shape.center or dora.Vec2.zero, -- 515
                                    shape.angle or 0 -- 516
                                ) -- 516
                            else -- 516
                                bodyDef:attachPolygon( -- 519
                                    shape.center or dora.Vec2.zero, -- 520
                                    shape.width, -- 521
                                    shape.height, -- 521
                                    shape.angle or 0, -- 522
                                    shape.density or 0, -- 523
                                    shape.friction or 0.4, -- 524
                                    shape.restitution or 0 -- 525
                                ) -- 525
                            end -- 525
                            break -- 528
                        end -- 528
                    end -- 528
                    ____cond114 = ____cond114 or ____switch114 == "polygon-shape" -- 528
                    if ____cond114 then -- 528
                        do -- 528
                            local shape = child.props -- 531
                            if shape.sensorTag ~= nil then -- 531
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 533
                            else -- 533
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 538
                            end -- 538
                            break -- 545
                        end -- 545
                    end -- 545
                    ____cond114 = ____cond114 or ____switch114 == "multi-shape" -- 545
                    if ____cond114 then -- 545
                        do -- 545
                            local shape = child.props -- 548
                            if shape.sensorTag ~= nil then -- 548
                                if extraSensors == nil then -- 548
                                    extraSensors = {} -- 550
                                end -- 550
                                extraSensors[#extraSensors + 1] = { -- 551
                                    shape.sensorTag, -- 551
                                    dora.BodyDef:multi(shape.verts) -- 551
                                } -- 551
                            else -- 551
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 553
                            end -- 553
                            break -- 560
                        end -- 560
                    end -- 560
                    ____cond114 = ____cond114 or ____switch114 == "disk-shape" -- 560
                    if ____cond114 then -- 560
                        do -- 560
                            local shape = child.props -- 563
                            if shape.sensorTag ~= nil then -- 563
                                bodyDef:attachDiskSensor(shape.sensorTag, shape.radius) -- 565
                            else -- 565
                                bodyDef:attachDisk( -- 570
                                    shape.center or dora.Vec2.zero, -- 571
                                    shape.radius, -- 572
                                    shape.density or 0, -- 573
                                    shape.friction or 0.4, -- 574
                                    shape.restitution or 0 -- 575
                                ) -- 575
                            end -- 575
                            break -- 578
                        end -- 578
                    end -- 578
                    ____cond114 = ____cond114 or ____switch114 == "chain-shape" -- 578
                    if ____cond114 then -- 578
                        do -- 578
                            local shape = child.props -- 581
                            if shape.sensorTag ~= nil then -- 581
                                if extraSensors == nil then -- 581
                                    extraSensors = {} -- 583
                                end -- 583
                                extraSensors[#extraSensors + 1] = { -- 584
                                    shape.sensorTag, -- 584
                                    dora.BodyDef:chain(shape.verts) -- 584
                                } -- 584
                            else -- 584
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 586
                            end -- 586
                            break -- 592
                        end -- 592
                    end -- 592
                until true -- 592
            end -- 592
            ::__continue112:: -- 592
        end -- 592
        local body = dora.Body(bodyDef, world) -- 596
        if extraSensors ~= nil then -- 596
            for i = 1, #extraSensors do -- 596
                local tag, def = table.unpack(extraSensors[i]) -- 599
                body:attachSensor(tag, def) -- 600
            end -- 600
        end -- 600
        local cnode = getNode(nil, enode, body, handleBodyAttribute) -- 603
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 603
            body.receivingContact = true -- 610
        end -- 610
        return cnode -- 612
    end -- 491
end -- 491
local function addChild(nodeStack, cnode, enode) -- 616
    if #nodeStack > 0 then -- 616
        local last = nodeStack[#nodeStack] -- 618
        last:addChild(cnode) -- 619
    end -- 619
    nodeStack[#nodeStack + 1] = cnode -- 621
    if #enode.children > 0 then -- 621
        visitNode(nodeStack, enode.children, enode) -- 623
    end -- 623
    if #nodeStack > 1 then -- 623
        table.remove(nodeStack) -- 626
    end -- 626
end -- 616
local function drawNodeCheck(_nodeStack, enode, parent) -- 634
    if parent == nil or parent.type ~= "draw-node" then -- 634
        print(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 636
    end -- 636
end -- 634
local function actionCheck(_nodeStack, enode, parent) -- 640
    local unsupported = false -- 641
    if parent == nil then -- 641
        unsupported = true -- 643
    else -- 643
        repeat -- 643
            local ____switch142 = enode.type -- 643
            local ____cond142 = ____switch142 == "action" or ____switch142 == "spawn" or ____switch142 == "sequence" -- 643
            if ____cond142 then -- 643
                break -- 646
            end -- 646
            do -- 646
                unsupported = true -- 647
                break -- 647
            end -- 647
        until true -- 647
    end -- 647
    if unsupported then -- 647
        print(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 651
    end -- 651
end -- 640
local function bodyCheck(_nodeStack, enode, parent) -- 655
    if parent == nil or parent.type ~= "body" then -- 655
        print(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 657
    end -- 657
end -- 655
local actionMap = { -- 661
    ["anchor-x"] = dora.AnchorX, -- 664
    ["anchor-y"] = dora.AnchorY, -- 665
    angle = dora.Angle, -- 666
    ["angle-x"] = dora.AngleX, -- 667
    ["angle-y"] = dora.AngleY, -- 668
    width = dora.Width, -- 669
    height = dora.Height, -- 670
    opacity = dora.Opacity, -- 671
    roll = dora.Roll, -- 672
    scale = dora.Scale, -- 673
    ["scale-x"] = dora.ScaleX, -- 674
    ["scale-y"] = dora.ScaleY, -- 675
    ["skew-x"] = dora.SkewX, -- 676
    ["skew-y"] = dora.SkewY, -- 677
    ["move-x"] = dora.X, -- 678
    ["move-y"] = dora.Y, -- 679
    ["move-z"] = dora.Z -- 680
} -- 680
elementMap = { -- 683
    node = function(nodeStack, enode, parent) -- 684
        addChild( -- 685
            nodeStack, -- 685
            getNode(nil, enode), -- 685
            enode -- 685
        ) -- 685
    end, -- 684
    ["clip-node"] = function(nodeStack, enode, parent) -- 687
        addChild( -- 688
            nodeStack, -- 688
            getClipNode(enode), -- 688
            enode -- 688
        ) -- 688
    end, -- 687
    playable = function(nodeStack, enode, parent) -- 690
        local cnode = getPlayable(enode) -- 691
        if cnode ~= nil then -- 691
            addChild(nodeStack, cnode, enode) -- 693
        end -- 693
    end, -- 690
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 696
        local cnode = getDragonBone(enode) -- 697
        if cnode ~= nil then -- 697
            addChild(nodeStack, cnode, enode) -- 699
        end -- 699
    end, -- 696
    spine = function(nodeStack, enode, parent) -- 702
        local cnode = getSpine(enode) -- 703
        if cnode ~= nil then -- 703
            addChild(nodeStack, cnode, enode) -- 705
        end -- 705
    end, -- 702
    model = function(nodeStack, enode, parent) -- 708
        local cnode = getModel(enode) -- 709
        if cnode ~= nil then -- 709
            addChild(nodeStack, cnode, enode) -- 711
        end -- 711
    end, -- 708
    ["draw-node"] = function(nodeStack, enode, parent) -- 714
        addChild( -- 715
            nodeStack, -- 715
            getDrawNode(enode), -- 715
            enode -- 715
        ) -- 715
    end, -- 714
    dot = drawNodeCheck, -- 717
    segment = drawNodeCheck, -- 718
    polygon = drawNodeCheck, -- 719
    verts = drawNodeCheck, -- 720
    grid = function(nodeStack, enode, parent) -- 721
        addChild( -- 722
            nodeStack, -- 722
            getGrid(enode), -- 722
            enode -- 722
        ) -- 722
    end, -- 721
    sprite = function(nodeStack, enode, parent) -- 724
        local cnode = getSprite(enode) -- 725
        if cnode ~= nil then -- 725
            addChild(nodeStack, cnode, enode) -- 727
        end -- 727
    end, -- 724
    label = function(nodeStack, enode, parent) -- 730
        local cnode = getLabel(enode) -- 731
        if cnode ~= nil then -- 731
            addChild(nodeStack, cnode, enode) -- 733
        end -- 733
    end, -- 730
    line = function(nodeStack, enode, parent) -- 736
        addChild( -- 737
            nodeStack, -- 737
            getLine(enode), -- 737
            enode -- 737
        ) -- 737
    end, -- 736
    particle = function(nodeStack, enode, parent) -- 739
        local cnode = getParticle(enode) -- 740
        if cnode ~= nil then -- 740
            addChild(nodeStack, cnode, enode) -- 742
        end -- 742
    end, -- 739
    menu = function(nodeStack, enode, parent) -- 745
        addChild( -- 746
            nodeStack, -- 746
            getMenu(enode), -- 746
            enode -- 746
        ) -- 746
    end, -- 745
    action = function(_nodeStack, enode, parent) -- 748
        if #enode.children == 0 then -- 748
            return -- 749
        end -- 749
        local action = enode.props -- 750
        if action.ref == nil then -- 750
            return -- 751
        end -- 751
        local function visitAction(actionStack, enode) -- 752
            local createAction = actionMap[enode.type] -- 753
            if createAction ~= nil then -- 753
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 755
                return -- 756
            end -- 756
            repeat -- 756
                local ____switch171 = enode.type -- 756
                local ____cond171 = ____switch171 == "delay" -- 756
                if ____cond171 then -- 756
                    do -- 756
                        local item = enode.props -- 760
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 761
                        return -- 762
                    end -- 762
                end -- 762
                ____cond171 = ____cond171 or ____switch171 == "event" -- 762
                if ____cond171 then -- 762
                    do -- 762
                        local item = enode.props -- 765
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 766
                        return -- 767
                    end -- 767
                end -- 767
                ____cond171 = ____cond171 or ____switch171 == "hide" -- 767
                if ____cond171 then -- 767
                    do -- 767
                        actionStack[#actionStack + 1] = dora.Hide() -- 770
                        return -- 771
                    end -- 771
                end -- 771
                ____cond171 = ____cond171 or ____switch171 == "show" -- 771
                if ____cond171 then -- 771
                    do -- 771
                        actionStack[#actionStack + 1] = dora.Show() -- 774
                        return -- 775
                    end -- 775
                end -- 775
                ____cond171 = ____cond171 or ____switch171 == "move" -- 775
                if ____cond171 then -- 775
                    do -- 775
                        local item = enode.props -- 778
                        actionStack[#actionStack + 1] = dora.Move( -- 779
                            item.time, -- 779
                            dora.Vec2(item.startX, item.startY), -- 779
                            dora.Vec2(item.stopX, item.stopY), -- 779
                            item.easing -- 779
                        ) -- 779
                        return -- 780
                    end -- 780
                end -- 780
                ____cond171 = ____cond171 or ____switch171 == "spawn" -- 780
                if ____cond171 then -- 780
                    do -- 780
                        local spawnStack = {} -- 783
                        for i = 1, #enode.children do -- 783
                            visitAction(spawnStack, enode.children[i]) -- 785
                        end -- 785
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 787
                    end -- 787
                end -- 787
                ____cond171 = ____cond171 or ____switch171 == "sequence" -- 787
                if ____cond171 then -- 787
                    do -- 787
                        local sequenceStack = {} -- 790
                        for i = 1, #enode.children do -- 790
                            visitAction(sequenceStack, enode.children[i]) -- 792
                        end -- 792
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 794
                    end -- 794
                end -- 794
                do -- 794
                    print(("unsupported tag <" .. enode.type) .. "> under action definition") -- 797
                    break -- 798
                end -- 798
            until true -- 798
        end -- 752
        local actionStack = {} -- 801
        for i = 1, #enode.children do -- 801
            visitAction(actionStack, enode.children[i]) -- 803
        end -- 803
        if #actionStack == 1 then -- 803
            action.ref.current = actionStack[1] -- 806
        elseif #actionStack > 1 then -- 806
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 808
        end -- 808
    end, -- 748
    ["anchor-x"] = actionCheck, -- 811
    ["anchor-y"] = actionCheck, -- 812
    angle = actionCheck, -- 813
    ["angle-x"] = actionCheck, -- 814
    ["angle-y"] = actionCheck, -- 815
    delay = actionCheck, -- 816
    event = actionCheck, -- 817
    width = actionCheck, -- 818
    height = actionCheck, -- 819
    hide = actionCheck, -- 820
    show = actionCheck, -- 821
    move = actionCheck, -- 822
    opacity = actionCheck, -- 823
    roll = actionCheck, -- 824
    scale = actionCheck, -- 825
    ["scale-x"] = actionCheck, -- 826
    ["scale-y"] = actionCheck, -- 827
    ["skew-x"] = actionCheck, -- 828
    ["skew-y"] = actionCheck, -- 829
    ["move-x"] = actionCheck, -- 830
    ["move-y"] = actionCheck, -- 831
    ["move-z"] = actionCheck, -- 832
    spawn = actionCheck, -- 833
    sequence = actionCheck, -- 834
    ["physics-world"] = function(nodeStack, enode, _parent) -- 835
        addChild( -- 836
            nodeStack, -- 836
            getPhysicsWorld(enode), -- 836
            enode -- 836
        ) -- 836
    end, -- 835
    body = function(nodeStack, enode, _parent) -- 838
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 839
        if world ~= nil then -- 839
            addChild( -- 841
                nodeStack, -- 841
                getBody(enode, world), -- 841
                enode -- 841
            ) -- 841
        else -- 841
            print(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 843
        end -- 843
    end, -- 838
    ["rect-shape"] = bodyCheck, -- 846
    ["polygon-shape"] = bodyCheck, -- 847
    ["multi-shape"] = bodyCheck, -- 848
    ["disk-shape"] = bodyCheck, -- 849
    ["chain-shape"] = bodyCheck, -- 850
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 851
        local joint = enode.props -- 852
        if joint.ref == nil then -- 852
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 854
            return -- 855
        end -- 855
        if joint.bodyA.current == nil then -- 855
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 858
            return -- 859
        end -- 859
        if joint.bodyB.current == nil then -- 859
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 862
            return -- 863
        end -- 863
        local ____joint_ref_8 = joint.ref -- 865
        local ____self_6 = dora.Joint -- 865
        local ____self_6_distance_7 = ____self_6.distance -- 865
        local ____joint_canCollide_5 = joint.canCollide -- 866
        if ____joint_canCollide_5 == nil then -- 866
            ____joint_canCollide_5 = false -- 866
        end -- 866
        ____joint_ref_8.current = ____self_6_distance_7( -- 865
            ____self_6, -- 865
            ____joint_canCollide_5, -- 866
            joint.bodyA.current, -- 867
            joint.bodyB.current, -- 868
            joint.anchorA or dora.Vec2.zero, -- 869
            joint.anchorB or dora.Vec2.zero, -- 870
            joint.frequency or 0, -- 871
            joint.damping or 0 -- 872
        ) -- 872
    end, -- 851
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 874
        local joint = enode.props -- 875
        if joint.ref == nil then -- 875
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 877
            return -- 878
        end -- 878
        if joint.bodyA.current == nil then -- 878
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 881
            return -- 882
        end -- 882
        if joint.bodyB.current == nil then -- 882
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 885
            return -- 886
        end -- 886
        local ____joint_ref_12 = joint.ref -- 888
        local ____self_10 = dora.Joint -- 888
        local ____self_10_friction_11 = ____self_10.friction -- 888
        local ____joint_canCollide_9 = joint.canCollide -- 889
        if ____joint_canCollide_9 == nil then -- 889
            ____joint_canCollide_9 = false -- 889
        end -- 889
        ____joint_ref_12.current = ____self_10_friction_11( -- 888
            ____self_10, -- 888
            ____joint_canCollide_9, -- 889
            joint.bodyA.current, -- 890
            joint.bodyB.current, -- 891
            joint.worldPos, -- 892
            joint.maxForce, -- 893
            joint.maxTorque -- 894
        ) -- 894
    end, -- 874
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 897
        local joint = enode.props -- 898
        if joint.ref == nil then -- 898
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 900
            return -- 901
        end -- 901
        if joint.jointA.current == nil then -- 901
            print(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 904
            return -- 905
        end -- 905
        if joint.jointB.current == nil then -- 905
            print(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 908
            return -- 909
        end -- 909
        local ____joint_ref_16 = joint.ref -- 911
        local ____self_14 = dora.Joint -- 911
        local ____self_14_gear_15 = ____self_14.gear -- 911
        local ____joint_canCollide_13 = joint.canCollide -- 912
        if ____joint_canCollide_13 == nil then -- 912
            ____joint_canCollide_13 = false -- 912
        end -- 912
        ____joint_ref_16.current = ____self_14_gear_15( -- 911
            ____self_14, -- 911
            ____joint_canCollide_13, -- 912
            joint.jointA.current, -- 913
            joint.jointB.current, -- 914
            joint.ratio or 1 -- 915
        ) -- 915
    end, -- 897
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 918
        local joint = enode.props -- 919
        if joint.ref == nil then -- 919
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 921
            return -- 922
        end -- 922
        if joint.bodyA.current == nil then -- 922
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 925
            return -- 926
        end -- 926
        if joint.bodyB.current == nil then -- 926
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 929
            return -- 930
        end -- 930
        local ____joint_ref_20 = joint.ref -- 932
        local ____self_18 = dora.Joint -- 932
        local ____self_18_spring_19 = ____self_18.spring -- 932
        local ____joint_canCollide_17 = joint.canCollide -- 933
        if ____joint_canCollide_17 == nil then -- 933
            ____joint_canCollide_17 = false -- 933
        end -- 933
        ____joint_ref_20.current = ____self_18_spring_19( -- 932
            ____self_18, -- 932
            ____joint_canCollide_17, -- 933
            joint.bodyA.current, -- 934
            joint.bodyB.current, -- 935
            joint.linearOffset, -- 936
            joint.angularOffset, -- 937
            joint.maxForce, -- 938
            joint.maxTorque, -- 939
            joint.correctionFactor or 1 -- 940
        ) -- 940
    end, -- 918
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 943
        local joint = enode.props -- 944
        if joint.ref == nil then -- 944
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 946
            return -- 947
        end -- 947
        if joint.body.current == nil then -- 947
            print(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 950
            return -- 951
        end -- 951
        local ____joint_ref_24 = joint.ref -- 953
        local ____self_22 = dora.Joint -- 953
        local ____self_22_move_23 = ____self_22.move -- 953
        local ____joint_canCollide_21 = joint.canCollide -- 954
        if ____joint_canCollide_21 == nil then -- 954
            ____joint_canCollide_21 = false -- 954
        end -- 954
        ____joint_ref_24.current = ____self_22_move_23( -- 953
            ____self_22, -- 953
            ____joint_canCollide_21, -- 954
            joint.body.current, -- 955
            joint.targetPos, -- 956
            joint.maxForce, -- 957
            joint.frequency, -- 958
            joint.damping or 0.7 -- 959
        ) -- 959
    end, -- 943
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 962
        local joint = enode.props -- 963
        if joint.ref == nil then -- 963
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 965
            return -- 966
        end -- 966
        if joint.bodyA.current == nil then -- 966
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 969
            return -- 970
        end -- 970
        if joint.bodyB.current == nil then -- 970
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 973
            return -- 974
        end -- 974
        local ____joint_ref_28 = joint.ref -- 976
        local ____self_26 = dora.Joint -- 976
        local ____self_26_prismatic_27 = ____self_26.prismatic -- 976
        local ____joint_canCollide_25 = joint.canCollide -- 977
        if ____joint_canCollide_25 == nil then -- 977
            ____joint_canCollide_25 = false -- 977
        end -- 977
        ____joint_ref_28.current = ____self_26_prismatic_27( -- 976
            ____self_26, -- 976
            ____joint_canCollide_25, -- 977
            joint.bodyA.current, -- 978
            joint.bodyB.current, -- 979
            joint.worldPos, -- 980
            joint.axisAngle, -- 981
            joint.lowerTranslation or 0, -- 982
            joint.upperTranslation or 0, -- 983
            joint.maxMotorForce or 0, -- 984
            joint.motorSpeed or 0 -- 985
        ) -- 985
    end, -- 962
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 988
        local joint = enode.props -- 989
        if joint.ref == nil then -- 989
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 991
            return -- 992
        end -- 992
        if joint.bodyA.current == nil then -- 992
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 995
            return -- 996
        end -- 996
        if joint.bodyB.current == nil then -- 996
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 999
            return -- 1000
        end -- 1000
        local ____joint_ref_32 = joint.ref -- 1002
        local ____self_30 = dora.Joint -- 1002
        local ____self_30_pulley_31 = ____self_30.pulley -- 1002
        local ____joint_canCollide_29 = joint.canCollide -- 1003
        if ____joint_canCollide_29 == nil then -- 1003
            ____joint_canCollide_29 = false -- 1003
        end -- 1003
        ____joint_ref_32.current = ____self_30_pulley_31( -- 1002
            ____self_30, -- 1002
            ____joint_canCollide_29, -- 1003
            joint.bodyA.current, -- 1004
            joint.bodyB.current, -- 1005
            joint.anchorA or dora.Vec2.zero, -- 1006
            joint.anchorB or dora.Vec2.zero, -- 1007
            joint.groundAnchorA, -- 1008
            joint.groundAnchorB, -- 1009
            joint.ratio or 1 -- 1010
        ) -- 1010
    end, -- 988
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1013
        local joint = enode.props -- 1014
        if joint.ref == nil then -- 1014
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1016
            return -- 1017
        end -- 1017
        if joint.bodyA.current == nil then -- 1017
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1020
            return -- 1021
        end -- 1021
        if joint.bodyB.current == nil then -- 1021
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1024
            return -- 1025
        end -- 1025
        local ____joint_ref_36 = joint.ref -- 1027
        local ____self_34 = dora.Joint -- 1027
        local ____self_34_revolute_35 = ____self_34.revolute -- 1027
        local ____joint_canCollide_33 = joint.canCollide -- 1028
        if ____joint_canCollide_33 == nil then -- 1028
            ____joint_canCollide_33 = false -- 1028
        end -- 1028
        ____joint_ref_36.current = ____self_34_revolute_35( -- 1027
            ____self_34, -- 1027
            ____joint_canCollide_33, -- 1028
            joint.bodyA.current, -- 1029
            joint.bodyB.current, -- 1030
            joint.worldPos, -- 1031
            joint.lowerAngle or 0, -- 1032
            joint.upperAngle or 0, -- 1033
            joint.maxMotorTorque or 0, -- 1034
            joint.motorSpeed or 0 -- 1035
        ) -- 1035
    end, -- 1013
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1038
        local joint = enode.props -- 1039
        if joint.ref == nil then -- 1039
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1041
            return -- 1042
        end -- 1042
        if joint.bodyA.current == nil then -- 1042
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1045
            return -- 1046
        end -- 1046
        if joint.bodyB.current == nil then -- 1046
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1049
            return -- 1050
        end -- 1050
        local ____joint_ref_40 = joint.ref -- 1052
        local ____self_38 = dora.Joint -- 1052
        local ____self_38_rope_39 = ____self_38.rope -- 1052
        local ____joint_canCollide_37 = joint.canCollide -- 1053
        if ____joint_canCollide_37 == nil then -- 1053
            ____joint_canCollide_37 = false -- 1053
        end -- 1053
        ____joint_ref_40.current = ____self_38_rope_39( -- 1052
            ____self_38, -- 1052
            ____joint_canCollide_37, -- 1053
            joint.bodyA.current, -- 1054
            joint.bodyB.current, -- 1055
            joint.anchorA or dora.Vec2.zero, -- 1056
            joint.anchorB or dora.Vec2.zero, -- 1057
            joint.maxLength or 0 -- 1058
        ) -- 1058
    end, -- 1038
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1061
        local joint = enode.props -- 1062
        if joint.ref == nil then -- 1062
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1064
            return -- 1065
        end -- 1065
        if joint.bodyA.current == nil then -- 1065
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1068
            return -- 1069
        end -- 1069
        if joint.bodyB.current == nil then -- 1069
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1072
            return -- 1073
        end -- 1073
        local ____joint_ref_44 = joint.ref -- 1075
        local ____self_42 = dora.Joint -- 1075
        local ____self_42_weld_43 = ____self_42.weld -- 1075
        local ____joint_canCollide_41 = joint.canCollide -- 1076
        if ____joint_canCollide_41 == nil then -- 1076
            ____joint_canCollide_41 = false -- 1076
        end -- 1076
        ____joint_ref_44.current = ____self_42_weld_43( -- 1075
            ____self_42, -- 1075
            ____joint_canCollide_41, -- 1076
            joint.bodyA.current, -- 1077
            joint.bodyB.current, -- 1078
            joint.worldPos, -- 1079
            joint.frequency or 0, -- 1080
            joint.damping or 0 -- 1081
        ) -- 1081
    end, -- 1061
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1084
        local joint = enode.props -- 1085
        if joint.ref == nil then -- 1085
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1087
            return -- 1088
        end -- 1088
        if joint.bodyA.current == nil then -- 1088
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1091
            return -- 1092
        end -- 1092
        if joint.bodyB.current == nil then -- 1092
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1095
            return -- 1096
        end -- 1096
        local ____joint_ref_48 = joint.ref -- 1098
        local ____self_46 = dora.Joint -- 1098
        local ____self_46_wheel_47 = ____self_46.wheel -- 1098
        local ____joint_canCollide_45 = joint.canCollide -- 1099
        if ____joint_canCollide_45 == nil then -- 1099
            ____joint_canCollide_45 = false -- 1099
        end -- 1099
        ____joint_ref_48.current = ____self_46_wheel_47( -- 1098
            ____self_46, -- 1098
            ____joint_canCollide_45, -- 1099
            joint.bodyA.current, -- 1100
            joint.bodyB.current, -- 1101
            joint.worldPos, -- 1102
            joint.axisAngle, -- 1103
            joint.maxMotorTorque or 0, -- 1104
            joint.motorSpeed or 0, -- 1105
            joint.frequency or 0, -- 1106
            joint.damping or 0.7 -- 1107
        ) -- 1107
    end -- 1084
} -- 1084
function ____exports.useRef(item) -- 1150
    local ____item_49 = item -- 1151
    if ____item_49 == nil then -- 1151
        ____item_49 = nil -- 1151
    end -- 1151
    return {current = ____item_49} -- 1151
end -- 1150
return ____exports -- 1150