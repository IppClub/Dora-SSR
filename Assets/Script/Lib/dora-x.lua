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
function visitNode(nodeStack, node, parent) -- 1112
    if type(node) ~= "table" then -- 1112
        return -- 1114
    end -- 1114
    local enode = node -- 1116
    if enode.type == nil then -- 1116
        local list = node -- 1118
        if #list > 0 then -- 1118
            for i = 1, #list do -- 1118
                local stack = {} -- 1121
                visitNode(stack, list[i], parent) -- 1122
                for i = 1, #stack do -- 1122
                    nodeStack[#nodeStack + 1] = stack[i] -- 1124
                end -- 1124
            end -- 1124
        end -- 1124
    else -- 1124
        local handler = elementMap[enode.type] -- 1129
        if handler ~= nil then -- 1129
            handler(nodeStack, enode, parent) -- 1131
        else -- 1131
            print(("unsupported tag <" .. enode.type) .. ">") -- 1133
        end -- 1133
    end -- 1133
end -- 1133
function ____exports.toNode(enode) -- 1138
    local nodeStack = {} -- 1139
    visitNode(nodeStack, enode) -- 1140
    if #nodeStack == 1 then -- 1140
        return nodeStack[1] -- 1142
    elseif #nodeStack > 1 then -- 1142
        local node = dora.Node() -- 1144
        for i = 1, #nodeStack do -- 1144
            node:addChild(nodeStack[i]) -- 1146
        end -- 1146
        return node -- 1148
    end -- 1148
    return nil -- 1150
end -- 1138
____exports.React = {} -- 1138
local React = ____exports.React -- 1138
do -- 1138
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
    local ____enode_5 = enode -- 622
    local children = ____enode_5.children -- 622
    for i = 1, #children do -- 622
        visitNode(nodeStack, children[i], enode) -- 624
    end -- 624
    if #nodeStack > 1 then -- 624
        table.remove(nodeStack) -- 627
    end -- 627
end -- 616
local function drawNodeCheck(_nodeStack, enode, parent) -- 635
    if parent == nil or parent.type ~= "draw-node" then -- 635
        print(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 637
    end -- 637
end -- 635
local function actionCheck(_nodeStack, enode, parent) -- 641
    local unsupported = false -- 642
    if parent == nil then -- 642
        unsupported = true -- 644
    else -- 644
        repeat -- 644
            local ____switch142 = enode.type -- 644
            local ____cond142 = ____switch142 == "action" or ____switch142 == "spawn" or ____switch142 == "sequence" -- 644
            if ____cond142 then -- 644
                break -- 647
            end -- 647
            do -- 647
                unsupported = true -- 648
                break -- 648
            end -- 648
        until true -- 648
    end -- 648
    if unsupported then -- 648
        print(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 652
    end -- 652
end -- 641
local function bodyCheck(_nodeStack, enode, parent) -- 656
    if parent == nil or parent.type ~= "body" then -- 656
        print(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 658
    end -- 658
end -- 656
local actionMap = { -- 662
    ["anchor-x"] = dora.AnchorX, -- 665
    ["anchor-y"] = dora.AnchorY, -- 666
    angle = dora.Angle, -- 667
    ["angle-x"] = dora.AngleX, -- 668
    ["angle-y"] = dora.AngleY, -- 669
    width = dora.Width, -- 670
    height = dora.Height, -- 671
    opacity = dora.Opacity, -- 672
    roll = dora.Roll, -- 673
    scale = dora.Scale, -- 674
    ["scale-x"] = dora.ScaleX, -- 675
    ["scale-y"] = dora.ScaleY, -- 676
    ["skew-x"] = dora.SkewX, -- 677
    ["skew-y"] = dora.SkewY, -- 678
    ["move-x"] = dora.X, -- 679
    ["move-y"] = dora.Y, -- 680
    ["move-z"] = dora.Z -- 681
} -- 681
elementMap = { -- 684
    node = function(nodeStack, enode, parent) -- 685
        addChild( -- 686
            nodeStack, -- 686
            getNode(nil, enode), -- 686
            enode -- 686
        ) -- 686
    end, -- 685
    ["clip-node"] = function(nodeStack, enode, parent) -- 688
        addChild( -- 689
            nodeStack, -- 689
            getClipNode(enode), -- 689
            enode -- 689
        ) -- 689
    end, -- 688
    playable = function(nodeStack, enode, parent) -- 691
        local cnode = getPlayable(enode) -- 692
        if cnode ~= nil then -- 692
            addChild(nodeStack, cnode, enode) -- 694
        end -- 694
    end, -- 691
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 697
        local cnode = getDragonBone(enode) -- 698
        if cnode ~= nil then -- 698
            addChild(nodeStack, cnode, enode) -- 700
        end -- 700
    end, -- 697
    spine = function(nodeStack, enode, parent) -- 703
        local cnode = getSpine(enode) -- 704
        if cnode ~= nil then -- 704
            addChild(nodeStack, cnode, enode) -- 706
        end -- 706
    end, -- 703
    model = function(nodeStack, enode, parent) -- 709
        local cnode = getModel(enode) -- 710
        if cnode ~= nil then -- 710
            addChild(nodeStack, cnode, enode) -- 712
        end -- 712
    end, -- 709
    ["draw-node"] = function(nodeStack, enode, parent) -- 715
        addChild( -- 716
            nodeStack, -- 716
            getDrawNode(enode), -- 716
            enode -- 716
        ) -- 716
    end, -- 715
    dot = drawNodeCheck, -- 718
    segment = drawNodeCheck, -- 719
    polygon = drawNodeCheck, -- 720
    verts = drawNodeCheck, -- 721
    grid = function(nodeStack, enode, parent) -- 722
        addChild( -- 723
            nodeStack, -- 723
            getGrid(enode), -- 723
            enode -- 723
        ) -- 723
    end, -- 722
    sprite = function(nodeStack, enode, parent) -- 725
        local cnode = getSprite(enode) -- 726
        if cnode ~= nil then -- 726
            addChild(nodeStack, cnode, enode) -- 728
        end -- 728
    end, -- 725
    label = function(nodeStack, enode, parent) -- 731
        local cnode = getLabel(enode) -- 732
        if cnode ~= nil then -- 732
            addChild(nodeStack, cnode, enode) -- 734
        end -- 734
    end, -- 731
    line = function(nodeStack, enode, parent) -- 737
        addChild( -- 738
            nodeStack, -- 738
            getLine(enode), -- 738
            enode -- 738
        ) -- 738
    end, -- 737
    particle = function(nodeStack, enode, parent) -- 740
        local cnode = getParticle(enode) -- 741
        if cnode ~= nil then -- 741
            addChild(nodeStack, cnode, enode) -- 743
        end -- 743
    end, -- 740
    menu = function(nodeStack, enode, parent) -- 746
        addChild( -- 747
            nodeStack, -- 747
            getMenu(enode), -- 747
            enode -- 747
        ) -- 747
    end, -- 746
    action = function(_nodeStack, enode, parent) -- 749
        if #enode.children == 0 then -- 749
            return -- 750
        end -- 750
        local action = enode.props -- 751
        if action.ref == nil then -- 751
            return -- 752
        end -- 752
        local function visitAction(actionStack, enode) -- 753
            local createAction = actionMap[enode.type] -- 754
            if createAction ~= nil then -- 754
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 756
                return -- 757
            end -- 757
            repeat -- 757
                local ____switch171 = enode.type -- 757
                local ____cond171 = ____switch171 == "delay" -- 757
                if ____cond171 then -- 757
                    do -- 757
                        local item = enode.props -- 761
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 762
                        return -- 763
                    end -- 763
                end -- 763
                ____cond171 = ____cond171 or ____switch171 == "event" -- 763
                if ____cond171 then -- 763
                    do -- 763
                        local item = enode.props -- 766
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 767
                        return -- 768
                    end -- 768
                end -- 768
                ____cond171 = ____cond171 or ____switch171 == "hide" -- 768
                if ____cond171 then -- 768
                    do -- 768
                        actionStack[#actionStack + 1] = dora.Hide() -- 771
                        return -- 772
                    end -- 772
                end -- 772
                ____cond171 = ____cond171 or ____switch171 == "show" -- 772
                if ____cond171 then -- 772
                    do -- 772
                        actionStack[#actionStack + 1] = dora.Show() -- 775
                        return -- 776
                    end -- 776
                end -- 776
                ____cond171 = ____cond171 or ____switch171 == "move" -- 776
                if ____cond171 then -- 776
                    do -- 776
                        local item = enode.props -- 779
                        actionStack[#actionStack + 1] = dora.Move( -- 780
                            item.time, -- 780
                            dora.Vec2(item.startX, item.startY), -- 780
                            dora.Vec2(item.stopX, item.stopY), -- 780
                            item.easing -- 780
                        ) -- 780
                        return -- 781
                    end -- 781
                end -- 781
                ____cond171 = ____cond171 or ____switch171 == "spawn" -- 781
                if ____cond171 then -- 781
                    do -- 781
                        local spawnStack = {} -- 784
                        for i = 1, #enode.children do -- 784
                            visitAction(spawnStack, enode.children[i]) -- 786
                        end -- 786
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 788
                    end -- 788
                end -- 788
                ____cond171 = ____cond171 or ____switch171 == "sequence" -- 788
                if ____cond171 then -- 788
                    do -- 788
                        local sequenceStack = {} -- 791
                        for i = 1, #enode.children do -- 791
                            visitAction(sequenceStack, enode.children[i]) -- 793
                        end -- 793
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 795
                    end -- 795
                end -- 795
                do -- 795
                    print(("unsupported tag <" .. enode.type) .. "> under action definition") -- 798
                    break -- 799
                end -- 799
            until true -- 799
        end -- 753
        local actionStack = {} -- 802
        for i = 1, #enode.children do -- 802
            visitAction(actionStack, enode.children[i]) -- 804
        end -- 804
        if #actionStack == 1 then -- 804
            action.ref.current = actionStack[1] -- 807
        elseif #actionStack > 1 then -- 807
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 809
        end -- 809
    end, -- 749
    ["anchor-x"] = actionCheck, -- 812
    ["anchor-y"] = actionCheck, -- 813
    angle = actionCheck, -- 814
    ["angle-x"] = actionCheck, -- 815
    ["angle-y"] = actionCheck, -- 816
    delay = actionCheck, -- 817
    event = actionCheck, -- 818
    width = actionCheck, -- 819
    height = actionCheck, -- 820
    hide = actionCheck, -- 821
    show = actionCheck, -- 822
    move = actionCheck, -- 823
    opacity = actionCheck, -- 824
    roll = actionCheck, -- 825
    scale = actionCheck, -- 826
    ["scale-x"] = actionCheck, -- 827
    ["scale-y"] = actionCheck, -- 828
    ["skew-x"] = actionCheck, -- 829
    ["skew-y"] = actionCheck, -- 830
    ["move-x"] = actionCheck, -- 831
    ["move-y"] = actionCheck, -- 832
    ["move-z"] = actionCheck, -- 833
    spawn = actionCheck, -- 834
    sequence = actionCheck, -- 835
    ["physics-world"] = function(nodeStack, enode, _parent) -- 836
        addChild( -- 837
            nodeStack, -- 837
            getPhysicsWorld(enode), -- 837
            enode -- 837
        ) -- 837
    end, -- 836
    body = function(nodeStack, enode, _parent) -- 839
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 840
        if world ~= nil then -- 840
            addChild( -- 842
                nodeStack, -- 842
                getBody(enode, world), -- 842
                enode -- 842
            ) -- 842
        else -- 842
            print(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 844
        end -- 844
    end, -- 839
    ["rect-shape"] = bodyCheck, -- 847
    ["polygon-shape"] = bodyCheck, -- 848
    ["multi-shape"] = bodyCheck, -- 849
    ["disk-shape"] = bodyCheck, -- 850
    ["chain-shape"] = bodyCheck, -- 851
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 852
        local joint = enode.props -- 853
        if joint.ref == nil then -- 853
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 855
            return -- 856
        end -- 856
        if joint.bodyA.current == nil then -- 856
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 859
            return -- 860
        end -- 860
        if joint.bodyB.current == nil then -- 860
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 863
            return -- 864
        end -- 864
        local ____joint_ref_9 = joint.ref -- 866
        local ____self_7 = dora.Joint -- 866
        local ____self_7_distance_8 = ____self_7.distance -- 866
        local ____joint_canCollide_6 = joint.canCollide -- 867
        if ____joint_canCollide_6 == nil then -- 867
            ____joint_canCollide_6 = false -- 867
        end -- 867
        ____joint_ref_9.current = ____self_7_distance_8( -- 866
            ____self_7, -- 866
            ____joint_canCollide_6, -- 867
            joint.bodyA.current, -- 868
            joint.bodyB.current, -- 869
            joint.anchorA or dora.Vec2.zero, -- 870
            joint.anchorB or dora.Vec2.zero, -- 871
            joint.frequency or 0, -- 872
            joint.damping or 0 -- 873
        ) -- 873
    end, -- 852
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 875
        local joint = enode.props -- 876
        if joint.ref == nil then -- 876
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 878
            return -- 879
        end -- 879
        if joint.bodyA.current == nil then -- 879
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 882
            return -- 883
        end -- 883
        if joint.bodyB.current == nil then -- 883
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 886
            return -- 887
        end -- 887
        local ____joint_ref_13 = joint.ref -- 889
        local ____self_11 = dora.Joint -- 889
        local ____self_11_friction_12 = ____self_11.friction -- 889
        local ____joint_canCollide_10 = joint.canCollide -- 890
        if ____joint_canCollide_10 == nil then -- 890
            ____joint_canCollide_10 = false -- 890
        end -- 890
        ____joint_ref_13.current = ____self_11_friction_12( -- 889
            ____self_11, -- 889
            ____joint_canCollide_10, -- 890
            joint.bodyA.current, -- 891
            joint.bodyB.current, -- 892
            joint.worldPos, -- 893
            joint.maxForce, -- 894
            joint.maxTorque -- 895
        ) -- 895
    end, -- 875
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 898
        local joint = enode.props -- 899
        if joint.ref == nil then -- 899
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 901
            return -- 902
        end -- 902
        if joint.jointA.current == nil then -- 902
            print(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 905
            return -- 906
        end -- 906
        if joint.jointB.current == nil then -- 906
            print(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 909
            return -- 910
        end -- 910
        local ____joint_ref_17 = joint.ref -- 912
        local ____self_15 = dora.Joint -- 912
        local ____self_15_gear_16 = ____self_15.gear -- 912
        local ____joint_canCollide_14 = joint.canCollide -- 913
        if ____joint_canCollide_14 == nil then -- 913
            ____joint_canCollide_14 = false -- 913
        end -- 913
        ____joint_ref_17.current = ____self_15_gear_16( -- 912
            ____self_15, -- 912
            ____joint_canCollide_14, -- 913
            joint.jointA.current, -- 914
            joint.jointB.current, -- 915
            joint.ratio or 1 -- 916
        ) -- 916
    end, -- 898
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 919
        local joint = enode.props -- 920
        if joint.ref == nil then -- 920
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 922
            return -- 923
        end -- 923
        if joint.bodyA.current == nil then -- 923
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 926
            return -- 927
        end -- 927
        if joint.bodyB.current == nil then -- 927
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 930
            return -- 931
        end -- 931
        local ____joint_ref_21 = joint.ref -- 933
        local ____self_19 = dora.Joint -- 933
        local ____self_19_spring_20 = ____self_19.spring -- 933
        local ____joint_canCollide_18 = joint.canCollide -- 934
        if ____joint_canCollide_18 == nil then -- 934
            ____joint_canCollide_18 = false -- 934
        end -- 934
        ____joint_ref_21.current = ____self_19_spring_20( -- 933
            ____self_19, -- 933
            ____joint_canCollide_18, -- 934
            joint.bodyA.current, -- 935
            joint.bodyB.current, -- 936
            joint.linearOffset, -- 937
            joint.angularOffset, -- 938
            joint.maxForce, -- 939
            joint.maxTorque, -- 940
            joint.correctionFactor or 1 -- 941
        ) -- 941
    end, -- 919
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 944
        local joint = enode.props -- 945
        if joint.ref == nil then -- 945
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 947
            return -- 948
        end -- 948
        if joint.body.current == nil then -- 948
            print(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 951
            return -- 952
        end -- 952
        local ____joint_ref_25 = joint.ref -- 954
        local ____self_23 = dora.Joint -- 954
        local ____self_23_move_24 = ____self_23.move -- 954
        local ____joint_canCollide_22 = joint.canCollide -- 955
        if ____joint_canCollide_22 == nil then -- 955
            ____joint_canCollide_22 = false -- 955
        end -- 955
        ____joint_ref_25.current = ____self_23_move_24( -- 954
            ____self_23, -- 954
            ____joint_canCollide_22, -- 955
            joint.body.current, -- 956
            joint.targetPos, -- 957
            joint.maxForce, -- 958
            joint.frequency, -- 959
            joint.damping or 0.7 -- 960
        ) -- 960
    end, -- 944
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 963
        local joint = enode.props -- 964
        if joint.ref == nil then -- 964
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 966
            return -- 967
        end -- 967
        if joint.bodyA.current == nil then -- 967
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 970
            return -- 971
        end -- 971
        if joint.bodyB.current == nil then -- 971
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 974
            return -- 975
        end -- 975
        local ____joint_ref_29 = joint.ref -- 977
        local ____self_27 = dora.Joint -- 977
        local ____self_27_prismatic_28 = ____self_27.prismatic -- 977
        local ____joint_canCollide_26 = joint.canCollide -- 978
        if ____joint_canCollide_26 == nil then -- 978
            ____joint_canCollide_26 = false -- 978
        end -- 978
        ____joint_ref_29.current = ____self_27_prismatic_28( -- 977
            ____self_27, -- 977
            ____joint_canCollide_26, -- 978
            joint.bodyA.current, -- 979
            joint.bodyB.current, -- 980
            joint.worldPos, -- 981
            joint.axisAngle, -- 982
            joint.lowerTranslation or 0, -- 983
            joint.upperTranslation or 0, -- 984
            joint.maxMotorForce or 0, -- 985
            joint.motorSpeed or 0 -- 986
        ) -- 986
    end, -- 963
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 989
        local joint = enode.props -- 990
        if joint.ref == nil then -- 990
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 992
            return -- 993
        end -- 993
        if joint.bodyA.current == nil then -- 993
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 996
            return -- 997
        end -- 997
        if joint.bodyB.current == nil then -- 997
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1000
            return -- 1001
        end -- 1001
        local ____joint_ref_33 = joint.ref -- 1003
        local ____self_31 = dora.Joint -- 1003
        local ____self_31_pulley_32 = ____self_31.pulley -- 1003
        local ____joint_canCollide_30 = joint.canCollide -- 1004
        if ____joint_canCollide_30 == nil then -- 1004
            ____joint_canCollide_30 = false -- 1004
        end -- 1004
        ____joint_ref_33.current = ____self_31_pulley_32( -- 1003
            ____self_31, -- 1003
            ____joint_canCollide_30, -- 1004
            joint.bodyA.current, -- 1005
            joint.bodyB.current, -- 1006
            joint.anchorA or dora.Vec2.zero, -- 1007
            joint.anchorB or dora.Vec2.zero, -- 1008
            joint.groundAnchorA, -- 1009
            joint.groundAnchorB, -- 1010
            joint.ratio or 1 -- 1011
        ) -- 1011
    end, -- 989
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1014
        local joint = enode.props -- 1015
        if joint.ref == nil then -- 1015
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1017
            return -- 1018
        end -- 1018
        if joint.bodyA.current == nil then -- 1018
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1021
            return -- 1022
        end -- 1022
        if joint.bodyB.current == nil then -- 1022
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1025
            return -- 1026
        end -- 1026
        local ____joint_ref_37 = joint.ref -- 1028
        local ____self_35 = dora.Joint -- 1028
        local ____self_35_revolute_36 = ____self_35.revolute -- 1028
        local ____joint_canCollide_34 = joint.canCollide -- 1029
        if ____joint_canCollide_34 == nil then -- 1029
            ____joint_canCollide_34 = false -- 1029
        end -- 1029
        ____joint_ref_37.current = ____self_35_revolute_36( -- 1028
            ____self_35, -- 1028
            ____joint_canCollide_34, -- 1029
            joint.bodyA.current, -- 1030
            joint.bodyB.current, -- 1031
            joint.worldPos, -- 1032
            joint.lowerAngle or 0, -- 1033
            joint.upperAngle or 0, -- 1034
            joint.maxMotorTorque or 0, -- 1035
            joint.motorSpeed or 0 -- 1036
        ) -- 1036
    end, -- 1014
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1039
        local joint = enode.props -- 1040
        if joint.ref == nil then -- 1040
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1042
            return -- 1043
        end -- 1043
        if joint.bodyA.current == nil then -- 1043
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1046
            return -- 1047
        end -- 1047
        if joint.bodyB.current == nil then -- 1047
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1050
            return -- 1051
        end -- 1051
        local ____joint_ref_41 = joint.ref -- 1053
        local ____self_39 = dora.Joint -- 1053
        local ____self_39_rope_40 = ____self_39.rope -- 1053
        local ____joint_canCollide_38 = joint.canCollide -- 1054
        if ____joint_canCollide_38 == nil then -- 1054
            ____joint_canCollide_38 = false -- 1054
        end -- 1054
        ____joint_ref_41.current = ____self_39_rope_40( -- 1053
            ____self_39, -- 1053
            ____joint_canCollide_38, -- 1054
            joint.bodyA.current, -- 1055
            joint.bodyB.current, -- 1056
            joint.anchorA or dora.Vec2.zero, -- 1057
            joint.anchorB or dora.Vec2.zero, -- 1058
            joint.maxLength or 0 -- 1059
        ) -- 1059
    end, -- 1039
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1062
        local joint = enode.props -- 1063
        if joint.ref == nil then -- 1063
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1065
            return -- 1066
        end -- 1066
        if joint.bodyA.current == nil then -- 1066
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1069
            return -- 1070
        end -- 1070
        if joint.bodyB.current == nil then -- 1070
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1073
            return -- 1074
        end -- 1074
        local ____joint_ref_45 = joint.ref -- 1076
        local ____self_43 = dora.Joint -- 1076
        local ____self_43_weld_44 = ____self_43.weld -- 1076
        local ____joint_canCollide_42 = joint.canCollide -- 1077
        if ____joint_canCollide_42 == nil then -- 1077
            ____joint_canCollide_42 = false -- 1077
        end -- 1077
        ____joint_ref_45.current = ____self_43_weld_44( -- 1076
            ____self_43, -- 1076
            ____joint_canCollide_42, -- 1077
            joint.bodyA.current, -- 1078
            joint.bodyB.current, -- 1079
            joint.worldPos, -- 1080
            joint.frequency or 0, -- 1081
            joint.damping or 0 -- 1082
        ) -- 1082
    end, -- 1062
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1085
        local joint = enode.props -- 1086
        if joint.ref == nil then -- 1086
            print(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1088
            return -- 1089
        end -- 1089
        if joint.bodyA.current == nil then -- 1089
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1092
            return -- 1093
        end -- 1093
        if joint.bodyB.current == nil then -- 1093
            print(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1096
            return -- 1097
        end -- 1097
        local ____joint_ref_49 = joint.ref -- 1099
        local ____self_47 = dora.Joint -- 1099
        local ____self_47_wheel_48 = ____self_47.wheel -- 1099
        local ____joint_canCollide_46 = joint.canCollide -- 1100
        if ____joint_canCollide_46 == nil then -- 1100
            ____joint_canCollide_46 = false -- 1100
        end -- 1100
        ____joint_ref_49.current = ____self_47_wheel_48( -- 1099
            ____self_47, -- 1099
            ____joint_canCollide_46, -- 1100
            joint.bodyA.current, -- 1101
            joint.bodyB.current, -- 1102
            joint.worldPos, -- 1103
            joint.axisAngle, -- 1104
            joint.maxMotorTorque or 0, -- 1105
            joint.motorSpeed or 0, -- 1106
            joint.frequency or 0, -- 1107
            joint.damping or 0.7 -- 1108
        ) -- 1108
    end -- 1085
} -- 1085
function ____exports.useRef(item) -- 1153
    local ____item_50 = item -- 1154
    if ____item_50 == nil then -- 1154
        ____item_50 = nil -- 1154
    end -- 1154
    return {current = ____item_50} -- 1154
end -- 1153
return ____exports -- 1153
