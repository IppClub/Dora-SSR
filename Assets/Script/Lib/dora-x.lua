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
function visitNode(nodeStack, node, parent) -- 1157
    if type(node) ~= "table" then -- 1157
        return -- 1159
    end -- 1159
    local enode = node -- 1161
    if enode.type == nil then -- 1161
        local list = node -- 1163
        if #list > 0 then -- 1163
            for i = 1, #list do -- 1163
                local stack = {} -- 1166
                visitNode(stack, list[i], parent) -- 1167
                for i = 1, #stack do -- 1167
                    nodeStack[#nodeStack + 1] = stack[i] -- 1169
                end -- 1169
            end -- 1169
        end -- 1169
    else -- 1169
        local handler = elementMap[enode.type] -- 1174
        if handler ~= nil then -- 1174
            handler(nodeStack, enode, parent) -- 1176
        else -- 1176
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1178
        end -- 1178
    end -- 1178
end -- 1178
function ____exports.toNode(enode) -- 1183
    local nodeStack = {} -- 1184
    visitNode(nodeStack, enode) -- 1185
    if #nodeStack == 1 then -- 1185
        return nodeStack[1] -- 1187
    elseif #nodeStack > 1 then -- 1187
        local node = dora.Node() -- 1189
        for i = 1, #nodeStack do -- 1189
            node:addChild(nodeStack[i]) -- 1191
        end -- 1191
        return node -- 1193
    end -- 1193
    return nil -- 1195
end -- 1183
____exports.React = {} -- 1183
local React = ____exports.React -- 1183
do -- 1183
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
            local ____cond111 = ____switch111 == "type" or ____switch111 == "linearAcceleration" or ____switch111 == "fixedRotation" or ____switch111 == "bullet" -- 503
            if ____cond111 then -- 503
                return true -- 509
            end -- 509
            ____cond111 = ____cond111 or ____switch111 == "velocityX" -- 509
            if ____cond111 then -- 509
                cnode.velocityX = v -- 510
                return true -- 510
            end -- 510
            ____cond111 = ____cond111 or ____switch111 == "velocityY" -- 510
            if ____cond111 then -- 510
                cnode.velocityY = v -- 511
                return true -- 511
            end -- 511
            ____cond111 = ____cond111 or ____switch111 == "angularRate" -- 511
            if ____cond111 then -- 511
                cnode.angularRate = v -- 512
                return true -- 512
            end -- 512
            ____cond111 = ____cond111 or ____switch111 == "group" -- 512
            if ____cond111 then -- 512
                cnode.group = v -- 513
                return true -- 513
            end -- 513
            ____cond111 = ____cond111 or ____switch111 == "linearDamping" -- 513
            if ____cond111 then -- 513
                cnode.linearDamping = v -- 514
                return true -- 514
            end -- 514
            ____cond111 = ____cond111 or ____switch111 == "angularDamping" -- 514
            if ____cond111 then -- 514
                cnode.angularDamping = v -- 515
                return true -- 515
            end -- 515
            ____cond111 = ____cond111 or ____switch111 == "owner" -- 515
            if ____cond111 then -- 515
                cnode.owner = v -- 516
                return true -- 516
            end -- 516
            ____cond111 = ____cond111 or ____switch111 == "receivingContact" -- 516
            if ____cond111 then -- 516
                cnode.receivingContact = v -- 517
                return true -- 517
            end -- 517
            ____cond111 = ____cond111 or ____switch111 == "onBodyEnter" -- 517
            if ____cond111 then -- 517
                cnode:slot("BodyEnter", v) -- 518
                return true -- 518
            end -- 518
            ____cond111 = ____cond111 or ____switch111 == "onBodyLeave" -- 518
            if ____cond111 then -- 518
                cnode:slot("BodyLeave", v) -- 519
                return true -- 519
            end -- 519
            ____cond111 = ____cond111 or ____switch111 == "onContactStart" -- 519
            if ____cond111 then -- 519
                cnode:slot("ContactStart", v) -- 520
                return true -- 520
            end -- 520
            ____cond111 = ____cond111 or ____switch111 == "onContactEnd" -- 520
            if ____cond111 then -- 520
                cnode:slot("ContactEnd", v) -- 521
                return true -- 521
            end -- 521
            ____cond111 = ____cond111 or ____switch111 == "onContactFilter" -- 521
            if ____cond111 then -- 521
                cnode:onContactFilter(v) -- 522
                return true -- 522
            end -- 522
        until true -- 522
        return false -- 524
    end -- 503
    getBody = function(enode, world) -- 526
        local def = enode.props -- 527
        local bodyDef = dora.BodyDef() -- 528
        bodyDef.type = def.type -- 529
        if def.angle ~= nil then -- 529
            bodyDef.angle = def.angle -- 530
        end -- 530
        if def.angularDamping ~= nil then -- 530
            bodyDef.angularDamping = def.angularDamping -- 531
        end -- 531
        if def.bullet ~= nil then -- 531
            bodyDef.bullet = def.bullet -- 532
        end -- 532
        if def.fixedRotation ~= nil then -- 532
            bodyDef.fixedRotation = def.fixedRotation -- 533
        end -- 533
        if def.linearAcceleration ~= nil then -- 533
            bodyDef.linearAcceleration = def.linearAcceleration -- 534
        end -- 534
        if def.linearDamping ~= nil then -- 534
            bodyDef.linearDamping = def.linearDamping -- 535
        end -- 535
        bodyDef.position = dora.Vec2(def.x or 0, def.y or 0) -- 536
        local extraSensors = nil -- 537
        for i = 1, #enode.children do -- 537
            do -- 537
                local child = enode.children[i] -- 539
                if type(child) ~= "table" then -- 539
                    goto __continue119 -- 541
                end -- 541
                repeat -- 541
                    local ____switch121 = child.type -- 541
                    local ____cond121 = ____switch121 == "rect-fixture" -- 541
                    if ____cond121 then -- 541
                        do -- 541
                            local shape = child.props -- 545
                            if shape.sensorTag ~= nil then -- 545
                                bodyDef:attachPolygonSensor( -- 547
                                    shape.sensorTag, -- 548
                                    shape.width, -- 549
                                    shape.height, -- 549
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 550
                                    shape.angle or 0 -- 551
                                ) -- 551
                            else -- 551
                                bodyDef:attachPolygon( -- 554
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 555
                                    shape.width, -- 556
                                    shape.height, -- 556
                                    shape.angle or 0, -- 557
                                    shape.density or 0, -- 558
                                    shape.friction or 0.4, -- 559
                                    shape.restitution or 0 -- 560
                                ) -- 560
                            end -- 560
                            break -- 563
                        end -- 563
                    end -- 563
                    ____cond121 = ____cond121 or ____switch121 == "polygon-fixture" -- 563
                    if ____cond121 then -- 563
                        do -- 563
                            local shape = child.props -- 566
                            if shape.sensorTag ~= nil then -- 566
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 568
                            else -- 568
                                bodyDef:attachPolygon(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 573
                            end -- 573
                            break -- 580
                        end -- 580
                    end -- 580
                    ____cond121 = ____cond121 or ____switch121 == "multi-fixture" -- 580
                    if ____cond121 then -- 580
                        do -- 580
                            local shape = child.props -- 583
                            if shape.sensorTag ~= nil then -- 583
                                if extraSensors == nil then -- 583
                                    extraSensors = {} -- 585
                                end -- 585
                                extraSensors[#extraSensors + 1] = { -- 586
                                    shape.sensorTag, -- 586
                                    dora.BodyDef:multi(shape.verts) -- 586
                                } -- 586
                            else -- 586
                                bodyDef:attachMulti(shape.verts, shape.density or 0, shape.friction or 0.4, shape.restitution or 0) -- 588
                            end -- 588
                            break -- 595
                        end -- 595
                    end -- 595
                    ____cond121 = ____cond121 or ____switch121 == "disk-fixture" -- 595
                    if ____cond121 then -- 595
                        do -- 595
                            local shape = child.props -- 598
                            if shape.sensorTag ~= nil then -- 598
                                bodyDef:attachDiskSensor( -- 600
                                    shape.sensorTag, -- 601
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 602
                                    shape.radius -- 603
                                ) -- 603
                            else -- 603
                                bodyDef:attachDisk( -- 606
                                    dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 607
                                    shape.radius, -- 608
                                    shape.density or 0, -- 609
                                    shape.friction or 0.4, -- 610
                                    shape.restitution or 0 -- 611
                                ) -- 611
                            end -- 611
                            break -- 614
                        end -- 614
                    end -- 614
                    ____cond121 = ____cond121 or ____switch121 == "chain-fixture" -- 614
                    if ____cond121 then -- 614
                        do -- 614
                            local shape = child.props -- 617
                            if shape.sensorTag ~= nil then -- 617
                                if extraSensors == nil then -- 617
                                    extraSensors = {} -- 619
                                end -- 619
                                extraSensors[#extraSensors + 1] = { -- 620
                                    shape.sensorTag, -- 620
                                    dora.BodyDef:chain(shape.verts) -- 620
                                } -- 620
                            else -- 620
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 622
                            end -- 622
                            break -- 628
                        end -- 628
                    end -- 628
                until true -- 628
            end -- 628
            ::__continue119:: -- 628
        end -- 628
        local body = dora.Body(bodyDef, world) -- 632
        if extraSensors ~= nil then -- 632
            for i = 1, #extraSensors do -- 632
                local tag, def = table.unpack(extraSensors[i]) -- 635
                body:attachSensor(tag, def) -- 636
            end -- 636
        end -- 636
        local cnode = getNode(enode, body, handleBodyAttribute) -- 639
        if def.receivingContact ~= false and (def.onBodyEnter or def.onBodyLeave or def.onContactStart or def.onContactEnd) then -- 639
            body.receivingContact = true -- 646
        end -- 646
        return cnode -- 648
    end -- 526
end -- 526
local function addChild(nodeStack, cnode, enode) -- 652
    if #nodeStack > 0 then -- 652
        local last = nodeStack[#nodeStack] -- 654
        last:addChild(cnode) -- 655
    end -- 655
    nodeStack[#nodeStack + 1] = cnode -- 657
    local ____enode_9 = enode -- 658
    local children = ____enode_9.children -- 658
    for i = 1, #children do -- 658
        visitNode(nodeStack, children[i], enode) -- 660
    end -- 660
    if #nodeStack > 1 then -- 660
        table.remove(nodeStack) -- 663
    end -- 663
end -- 652
local function drawNodeCheck(_nodeStack, enode, parent) -- 671
    if parent == nil or parent.type ~= "draw-node" then -- 671
        Warn(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 673
    end -- 673
end -- 671
local function actionCheck(_nodeStack, enode, parent) -- 677
    local unsupported = false -- 678
    if parent == nil then -- 678
        unsupported = true -- 680
    else -- 680
        repeat -- 680
            local ____switch149 = enode.type -- 680
            local ____cond149 = ____switch149 == "action" or ____switch149 == "spawn" or ____switch149 == "sequence" -- 680
            if ____cond149 then -- 680
                break -- 683
            end -- 683
            do -- 683
                unsupported = true -- 684
                break -- 684
            end -- 684
        until true -- 684
    end -- 684
    if unsupported then -- 684
        Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 688
    end -- 688
end -- 677
local function bodyCheck(_nodeStack, enode, parent) -- 692
    if parent == nil or parent.type ~= "body" then -- 692
        Warn(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 694
    end -- 694
end -- 692
local actionMap = { -- 698
    ["anchor-x"] = dora.AnchorX, -- 701
    ["anchor-y"] = dora.AnchorY, -- 702
    angle = dora.Angle, -- 703
    ["angle-x"] = dora.AngleX, -- 704
    ["angle-y"] = dora.AngleY, -- 705
    width = dora.Width, -- 706
    height = dora.Height, -- 707
    opacity = dora.Opacity, -- 708
    roll = dora.Roll, -- 709
    scale = dora.Scale, -- 710
    ["scale-x"] = dora.ScaleX, -- 711
    ["scale-y"] = dora.ScaleY, -- 712
    ["skew-x"] = dora.SkewX, -- 713
    ["skew-y"] = dora.SkewY, -- 714
    ["move-x"] = dora.X, -- 715
    ["move-y"] = dora.Y, -- 716
    ["move-z"] = dora.Z -- 717
} -- 717
elementMap = { -- 720
    node = function(nodeStack, enode, parent) -- 721
        addChild( -- 722
            nodeStack, -- 722
            getNode(enode), -- 722
            enode -- 722
        ) -- 722
    end, -- 721
    ["clip-node"] = function(nodeStack, enode, parent) -- 724
        addChild( -- 725
            nodeStack, -- 725
            getClipNode(enode), -- 725
            enode -- 725
        ) -- 725
    end, -- 724
    playable = function(nodeStack, enode, parent) -- 727
        local cnode = getPlayable(enode) -- 728
        if cnode ~= nil then -- 728
            addChild(nodeStack, cnode, enode) -- 730
        end -- 730
    end, -- 727
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 733
        local cnode = getDragonBone(enode) -- 734
        if cnode ~= nil then -- 734
            addChild(nodeStack, cnode, enode) -- 736
        end -- 736
    end, -- 733
    spine = function(nodeStack, enode, parent) -- 739
        local cnode = getSpine(enode) -- 740
        if cnode ~= nil then -- 740
            addChild(nodeStack, cnode, enode) -- 742
        end -- 742
    end, -- 739
    model = function(nodeStack, enode, parent) -- 745
        local cnode = getModel(enode) -- 746
        if cnode ~= nil then -- 746
            addChild(nodeStack, cnode, enode) -- 748
        end -- 748
    end, -- 745
    ["draw-node"] = function(nodeStack, enode, parent) -- 751
        addChild( -- 752
            nodeStack, -- 752
            getDrawNode(enode), -- 752
            enode -- 752
        ) -- 752
    end, -- 751
    ["dot-shape"] = drawNodeCheck, -- 754
    ["segment-shape"] = drawNodeCheck, -- 755
    ["polygon-shape"] = drawNodeCheck, -- 756
    ["verts-shape"] = drawNodeCheck, -- 757
    grid = function(nodeStack, enode, parent) -- 758
        addChild( -- 759
            nodeStack, -- 759
            getGrid(enode), -- 759
            enode -- 759
        ) -- 759
    end, -- 758
    sprite = function(nodeStack, enode, parent) -- 761
        local cnode = getSprite(enode) -- 762
        if cnode ~= nil then -- 762
            addChild(nodeStack, cnode, enode) -- 764
        end -- 764
    end, -- 761
    label = function(nodeStack, enode, parent) -- 767
        local cnode = getLabel(enode) -- 768
        if cnode ~= nil then -- 768
            addChild(nodeStack, cnode, enode) -- 770
        end -- 770
    end, -- 767
    line = function(nodeStack, enode, parent) -- 773
        addChild( -- 774
            nodeStack, -- 774
            getLine(enode), -- 774
            enode -- 774
        ) -- 774
    end, -- 773
    particle = function(nodeStack, enode, parent) -- 776
        local cnode = getParticle(enode) -- 777
        if cnode ~= nil then -- 777
            addChild(nodeStack, cnode, enode) -- 779
        end -- 779
    end, -- 776
    menu = function(nodeStack, enode, parent) -- 782
        addChild( -- 783
            nodeStack, -- 783
            getMenu(enode), -- 783
            enode -- 783
        ) -- 783
    end, -- 782
    action = function(_nodeStack, enode, parent) -- 785
        if #enode.children == 0 then -- 785
            return -- 786
        end -- 786
        local action = enode.props -- 787
        if action.ref == nil then -- 787
            return -- 788
        end -- 788
        local function visitAction(actionStack, enode) -- 789
            local createAction = actionMap[enode.type] -- 790
            if createAction ~= nil then -- 790
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 792
                return -- 793
            end -- 793
            repeat -- 793
                local ____switch178 = enode.type -- 793
                local ____cond178 = ____switch178 == "delay" -- 793
                if ____cond178 then -- 793
                    do -- 793
                        local item = enode.props -- 797
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 798
                        return -- 799
                    end -- 799
                end -- 799
                ____cond178 = ____cond178 or ____switch178 == "event" -- 799
                if ____cond178 then -- 799
                    do -- 799
                        local item = enode.props -- 802
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 803
                        return -- 804
                    end -- 804
                end -- 804
                ____cond178 = ____cond178 or ____switch178 == "hide" -- 804
                if ____cond178 then -- 804
                    do -- 804
                        actionStack[#actionStack + 1] = dora.Hide() -- 807
                        return -- 808
                    end -- 808
                end -- 808
                ____cond178 = ____cond178 or ____switch178 == "show" -- 808
                if ____cond178 then -- 808
                    do -- 808
                        actionStack[#actionStack + 1] = dora.Show() -- 811
                        return -- 812
                    end -- 812
                end -- 812
                ____cond178 = ____cond178 or ____switch178 == "move" -- 812
                if ____cond178 then -- 812
                    do -- 812
                        local item = enode.props -- 815
                        actionStack[#actionStack + 1] = dora.Move( -- 816
                            item.time, -- 816
                            dora.Vec2(item.startX, item.startY), -- 816
                            dora.Vec2(item.stopX, item.stopY), -- 816
                            item.easing -- 816
                        ) -- 816
                        return -- 817
                    end -- 817
                end -- 817
                ____cond178 = ____cond178 or ____switch178 == "spawn" -- 817
                if ____cond178 then -- 817
                    do -- 817
                        local spawnStack = {} -- 820
                        for i = 1, #enode.children do -- 820
                            visitAction(spawnStack, enode.children[i]) -- 822
                        end -- 822
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 824
                    end -- 824
                end -- 824
                ____cond178 = ____cond178 or ____switch178 == "sequence" -- 824
                if ____cond178 then -- 824
                    do -- 824
                        local sequenceStack = {} -- 827
                        for i = 1, #enode.children do -- 827
                            visitAction(sequenceStack, enode.children[i]) -- 829
                        end -- 829
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 831
                    end -- 831
                end -- 831
                do -- 831
                    Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 834
                    break -- 835
                end -- 835
            until true -- 835
        end -- 789
        local actionStack = {} -- 838
        for i = 1, #enode.children do -- 838
            visitAction(actionStack, enode.children[i]) -- 840
        end -- 840
        if #actionStack == 1 then -- 840
            action.ref.current = actionStack[1] -- 843
        elseif #actionStack > 1 then -- 843
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 845
        end -- 845
    end, -- 785
    ["anchor-x"] = actionCheck, -- 848
    ["anchor-y"] = actionCheck, -- 849
    angle = actionCheck, -- 850
    ["angle-x"] = actionCheck, -- 851
    ["angle-y"] = actionCheck, -- 852
    delay = actionCheck, -- 853
    event = actionCheck, -- 854
    width = actionCheck, -- 855
    height = actionCheck, -- 856
    hide = actionCheck, -- 857
    show = actionCheck, -- 858
    move = actionCheck, -- 859
    opacity = actionCheck, -- 860
    roll = actionCheck, -- 861
    scale = actionCheck, -- 862
    ["scale-x"] = actionCheck, -- 863
    ["scale-y"] = actionCheck, -- 864
    ["skew-x"] = actionCheck, -- 865
    ["skew-y"] = actionCheck, -- 866
    ["move-x"] = actionCheck, -- 867
    ["move-y"] = actionCheck, -- 868
    ["move-z"] = actionCheck, -- 869
    spawn = actionCheck, -- 870
    sequence = actionCheck, -- 871
    ["physics-world"] = function(nodeStack, enode, _parent) -- 872
        addChild( -- 873
            nodeStack, -- 873
            getPhysicsWorld(enode), -- 873
            enode -- 873
        ) -- 873
    end, -- 872
    contact = function(nodeStack, enode, _parent) -- 875
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 876
        if world ~= nil then -- 876
            local contact = enode.props -- 878
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 879
        else -- 879
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 881
        end -- 881
    end, -- 875
    body = function(nodeStack, enode, _parent) -- 884
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 885
        if world ~= nil then -- 885
            addChild( -- 887
                nodeStack, -- 887
                getBody(enode, world), -- 887
                enode -- 887
            ) -- 887
        else -- 887
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 889
        end -- 889
    end, -- 884
    ["rect-fixture"] = bodyCheck, -- 892
    ["polygon-fixture"] = bodyCheck, -- 893
    ["multi-fixture"] = bodyCheck, -- 894
    ["disk-fixture"] = bodyCheck, -- 895
    ["chain-fixture"] = bodyCheck, -- 896
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 897
        local joint = enode.props -- 898
        if joint.ref == nil then -- 898
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 900
            return -- 901
        end -- 901
        if joint.bodyA.current == nil then -- 901
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 904
            return -- 905
        end -- 905
        if joint.bodyB.current == nil then -- 905
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 908
            return -- 909
        end -- 909
        local ____joint_ref_13 = joint.ref -- 911
        local ____self_11 = dora.Joint -- 911
        local ____self_11_distance_12 = ____self_11.distance -- 911
        local ____joint_canCollide_10 = joint.canCollide -- 912
        if ____joint_canCollide_10 == nil then -- 912
            ____joint_canCollide_10 = false -- 912
        end -- 912
        ____joint_ref_13.current = ____self_11_distance_12( -- 911
            ____self_11, -- 911
            ____joint_canCollide_10, -- 912
            joint.bodyA.current, -- 913
            joint.bodyB.current, -- 914
            joint.anchorA or dora.Vec2.zero, -- 915
            joint.anchorB or dora.Vec2.zero, -- 916
            joint.frequency or 0, -- 917
            joint.damping or 0 -- 918
        ) -- 918
    end, -- 897
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 920
        local joint = enode.props -- 921
        if joint.ref == nil then -- 921
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 923
            return -- 924
        end -- 924
        if joint.bodyA.current == nil then -- 924
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 927
            return -- 928
        end -- 928
        if joint.bodyB.current == nil then -- 928
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 931
            return -- 932
        end -- 932
        local ____joint_ref_17 = joint.ref -- 934
        local ____self_15 = dora.Joint -- 934
        local ____self_15_friction_16 = ____self_15.friction -- 934
        local ____joint_canCollide_14 = joint.canCollide -- 935
        if ____joint_canCollide_14 == nil then -- 935
            ____joint_canCollide_14 = false -- 935
        end -- 935
        ____joint_ref_17.current = ____self_15_friction_16( -- 934
            ____self_15, -- 934
            ____joint_canCollide_14, -- 935
            joint.bodyA.current, -- 936
            joint.bodyB.current, -- 937
            joint.worldPos, -- 938
            joint.maxForce, -- 939
            joint.maxTorque -- 940
        ) -- 940
    end, -- 920
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 943
        local joint = enode.props -- 944
        if joint.ref == nil then -- 944
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 946
            return -- 947
        end -- 947
        if joint.jointA.current == nil then -- 947
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 950
            return -- 951
        end -- 951
        if joint.jointB.current == nil then -- 951
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 954
            return -- 955
        end -- 955
        local ____joint_ref_21 = joint.ref -- 957
        local ____self_19 = dora.Joint -- 957
        local ____self_19_gear_20 = ____self_19.gear -- 957
        local ____joint_canCollide_18 = joint.canCollide -- 958
        if ____joint_canCollide_18 == nil then -- 958
            ____joint_canCollide_18 = false -- 958
        end -- 958
        ____joint_ref_21.current = ____self_19_gear_20( -- 957
            ____self_19, -- 957
            ____joint_canCollide_18, -- 958
            joint.jointA.current, -- 959
            joint.jointB.current, -- 960
            joint.ratio or 1 -- 961
        ) -- 961
    end, -- 943
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 964
        local joint = enode.props -- 965
        if joint.ref == nil then -- 965
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 967
            return -- 968
        end -- 968
        if joint.bodyA.current == nil then -- 968
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 971
            return -- 972
        end -- 972
        if joint.bodyB.current == nil then -- 972
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 975
            return -- 976
        end -- 976
        local ____joint_ref_25 = joint.ref -- 978
        local ____self_23 = dora.Joint -- 978
        local ____self_23_spring_24 = ____self_23.spring -- 978
        local ____joint_canCollide_22 = joint.canCollide -- 979
        if ____joint_canCollide_22 == nil then -- 979
            ____joint_canCollide_22 = false -- 979
        end -- 979
        ____joint_ref_25.current = ____self_23_spring_24( -- 978
            ____self_23, -- 978
            ____joint_canCollide_22, -- 979
            joint.bodyA.current, -- 980
            joint.bodyB.current, -- 981
            joint.linearOffset, -- 982
            joint.angularOffset, -- 983
            joint.maxForce, -- 984
            joint.maxTorque, -- 985
            joint.correctionFactor or 1 -- 986
        ) -- 986
    end, -- 964
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 989
        local joint = enode.props -- 990
        if joint.ref == nil then -- 990
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 992
            return -- 993
        end -- 993
        if joint.body.current == nil then -- 993
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 996
            return -- 997
        end -- 997
        local ____joint_ref_29 = joint.ref -- 999
        local ____self_27 = dora.Joint -- 999
        local ____self_27_move_28 = ____self_27.move -- 999
        local ____joint_canCollide_26 = joint.canCollide -- 1000
        if ____joint_canCollide_26 == nil then -- 1000
            ____joint_canCollide_26 = false -- 1000
        end -- 1000
        ____joint_ref_29.current = ____self_27_move_28( -- 999
            ____self_27, -- 999
            ____joint_canCollide_26, -- 1000
            joint.body.current, -- 1001
            joint.targetPos, -- 1002
            joint.maxForce, -- 1003
            joint.frequency, -- 1004
            joint.damping or 0.7 -- 1005
        ) -- 1005
    end, -- 989
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1008
        local joint = enode.props -- 1009
        if joint.ref == nil then -- 1009
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1011
            return -- 1012
        end -- 1012
        if joint.bodyA.current == nil then -- 1012
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1015
            return -- 1016
        end -- 1016
        if joint.bodyB.current == nil then -- 1016
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1019
            return -- 1020
        end -- 1020
        local ____joint_ref_33 = joint.ref -- 1022
        local ____self_31 = dora.Joint -- 1022
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1022
        local ____joint_canCollide_30 = joint.canCollide -- 1023
        if ____joint_canCollide_30 == nil then -- 1023
            ____joint_canCollide_30 = false -- 1023
        end -- 1023
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1022
            ____self_31, -- 1022
            ____joint_canCollide_30, -- 1023
            joint.bodyA.current, -- 1024
            joint.bodyB.current, -- 1025
            joint.worldPos, -- 1026
            joint.axisAngle, -- 1027
            joint.lowerTranslation or 0, -- 1028
            joint.upperTranslation or 0, -- 1029
            joint.maxMotorForce or 0, -- 1030
            joint.motorSpeed or 0 -- 1031
        ) -- 1031
    end, -- 1008
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1034
        local joint = enode.props -- 1035
        if joint.ref == nil then -- 1035
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1037
            return -- 1038
        end -- 1038
        if joint.bodyA.current == nil then -- 1038
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1041
            return -- 1042
        end -- 1042
        if joint.bodyB.current == nil then -- 1042
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1045
            return -- 1046
        end -- 1046
        local ____joint_ref_37 = joint.ref -- 1048
        local ____self_35 = dora.Joint -- 1048
        local ____self_35_pulley_36 = ____self_35.pulley -- 1048
        local ____joint_canCollide_34 = joint.canCollide -- 1049
        if ____joint_canCollide_34 == nil then -- 1049
            ____joint_canCollide_34 = false -- 1049
        end -- 1049
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1048
            ____self_35, -- 1048
            ____joint_canCollide_34, -- 1049
            joint.bodyA.current, -- 1050
            joint.bodyB.current, -- 1051
            joint.anchorA or dora.Vec2.zero, -- 1052
            joint.anchorB or dora.Vec2.zero, -- 1053
            joint.groundAnchorA, -- 1054
            joint.groundAnchorB, -- 1055
            joint.ratio or 1 -- 1056
        ) -- 1056
    end, -- 1034
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1059
        local joint = enode.props -- 1060
        if joint.ref == nil then -- 1060
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1062
            return -- 1063
        end -- 1063
        if joint.bodyA.current == nil then -- 1063
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1066
            return -- 1067
        end -- 1067
        if joint.bodyB.current == nil then -- 1067
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1070
            return -- 1071
        end -- 1071
        local ____joint_ref_41 = joint.ref -- 1073
        local ____self_39 = dora.Joint -- 1073
        local ____self_39_revolute_40 = ____self_39.revolute -- 1073
        local ____joint_canCollide_38 = joint.canCollide -- 1074
        if ____joint_canCollide_38 == nil then -- 1074
            ____joint_canCollide_38 = false -- 1074
        end -- 1074
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1073
            ____self_39, -- 1073
            ____joint_canCollide_38, -- 1074
            joint.bodyA.current, -- 1075
            joint.bodyB.current, -- 1076
            joint.worldPos, -- 1077
            joint.lowerAngle or 0, -- 1078
            joint.upperAngle or 0, -- 1079
            joint.maxMotorTorque or 0, -- 1080
            joint.motorSpeed or 0 -- 1081
        ) -- 1081
    end, -- 1059
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1084
        local joint = enode.props -- 1085
        if joint.ref == nil then -- 1085
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1087
            return -- 1088
        end -- 1088
        if joint.bodyA.current == nil then -- 1088
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1091
            return -- 1092
        end -- 1092
        if joint.bodyB.current == nil then -- 1092
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1095
            return -- 1096
        end -- 1096
        local ____joint_ref_45 = joint.ref -- 1098
        local ____self_43 = dora.Joint -- 1098
        local ____self_43_rope_44 = ____self_43.rope -- 1098
        local ____joint_canCollide_42 = joint.canCollide -- 1099
        if ____joint_canCollide_42 == nil then -- 1099
            ____joint_canCollide_42 = false -- 1099
        end -- 1099
        ____joint_ref_45.current = ____self_43_rope_44( -- 1098
            ____self_43, -- 1098
            ____joint_canCollide_42, -- 1099
            joint.bodyA.current, -- 1100
            joint.bodyB.current, -- 1101
            joint.anchorA or dora.Vec2.zero, -- 1102
            joint.anchorB or dora.Vec2.zero, -- 1103
            joint.maxLength or 0 -- 1104
        ) -- 1104
    end, -- 1084
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1107
        local joint = enode.props -- 1108
        if joint.ref == nil then -- 1108
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1110
            return -- 1111
        end -- 1111
        if joint.bodyA.current == nil then -- 1111
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1114
            return -- 1115
        end -- 1115
        if joint.bodyB.current == nil then -- 1115
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1118
            return -- 1119
        end -- 1119
        local ____joint_ref_49 = joint.ref -- 1121
        local ____self_47 = dora.Joint -- 1121
        local ____self_47_weld_48 = ____self_47.weld -- 1121
        local ____joint_canCollide_46 = joint.canCollide -- 1122
        if ____joint_canCollide_46 == nil then -- 1122
            ____joint_canCollide_46 = false -- 1122
        end -- 1122
        ____joint_ref_49.current = ____self_47_weld_48( -- 1121
            ____self_47, -- 1121
            ____joint_canCollide_46, -- 1122
            joint.bodyA.current, -- 1123
            joint.bodyB.current, -- 1124
            joint.worldPos, -- 1125
            joint.frequency or 0, -- 1126
            joint.damping or 0 -- 1127
        ) -- 1127
    end, -- 1107
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1130
        local joint = enode.props -- 1131
        if joint.ref == nil then -- 1131
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1133
            return -- 1134
        end -- 1134
        if joint.bodyA.current == nil then -- 1134
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1137
            return -- 1138
        end -- 1138
        if joint.bodyB.current == nil then -- 1138
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1141
            return -- 1142
        end -- 1142
        local ____joint_ref_53 = joint.ref -- 1144
        local ____self_51 = dora.Joint -- 1144
        local ____self_51_wheel_52 = ____self_51.wheel -- 1144
        local ____joint_canCollide_50 = joint.canCollide -- 1145
        if ____joint_canCollide_50 == nil then -- 1145
            ____joint_canCollide_50 = false -- 1145
        end -- 1145
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1144
            ____self_51, -- 1144
            ____joint_canCollide_50, -- 1145
            joint.bodyA.current, -- 1146
            joint.bodyB.current, -- 1147
            joint.worldPos, -- 1148
            joint.axisAngle, -- 1149
            joint.maxMotorTorque or 0, -- 1150
            joint.motorSpeed or 0, -- 1151
            joint.frequency or 0, -- 1152
            joint.damping or 0.7 -- 1153
        ) -- 1153
    end -- 1130
} -- 1130
function ____exports.useRef(item) -- 1198
    local ____item_54 = item -- 1199
    if ____item_54 == nil then -- 1199
        ____item_54 = nil -- 1199
    end -- 1199
    return {current = ____item_54} -- 1199
end -- 1198
local function getPreload(preloadList, node) -- 1202
    if type(node) ~= "table" then -- 1202
        return -- 1204
    end -- 1204
    local enode = node -- 1206
    if enode.type == nil then -- 1206
        local list = node -- 1208
        if #list > 0 then -- 1208
            for i = 1, #list do -- 1208
                getPreload(preloadList, list[i]) -- 1211
            end -- 1211
        end -- 1211
    else -- 1211
        repeat -- 1211
            local ____switch261 = enode.type -- 1211
            local sprite, playable, model, spine, dragonBone, label -- 1211
            local ____cond261 = ____switch261 == "sprite" -- 1211
            if ____cond261 then -- 1211
                sprite = enode.props -- 1217
                preloadList[#preloadList + 1] = sprite.file -- 1218
                break -- 1219
            end -- 1219
            ____cond261 = ____cond261 or ____switch261 == "playable" -- 1219
            if ____cond261 then -- 1219
                playable = enode.props -- 1221
                preloadList[#preloadList + 1] = playable.file -- 1222
                break -- 1223
            end -- 1223
            ____cond261 = ____cond261 or ____switch261 == "model" -- 1223
            if ____cond261 then -- 1223
                model = enode.props -- 1225
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1226
                break -- 1227
            end -- 1227
            ____cond261 = ____cond261 or ____switch261 == "spine" -- 1227
            if ____cond261 then -- 1227
                spine = enode.props -- 1229
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1230
                break -- 1231
            end -- 1231
            ____cond261 = ____cond261 or ____switch261 == "dragon-bone" -- 1231
            if ____cond261 then -- 1231
                dragonBone = enode.props -- 1233
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1234
                break -- 1235
            end -- 1235
            ____cond261 = ____cond261 or ____switch261 == "label" -- 1235
            if ____cond261 then -- 1235
                label = enode.props -- 1237
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1238
                break -- 1239
            end -- 1239
        until true -- 1239
    end -- 1239
    getPreload(preloadList, enode.children) -- 1242
end -- 1202
function ____exports.preloadAsync(enode, handler) -- 1245
    local preloadList = {} -- 1246
    getPreload(preloadList, enode) -- 1247
    dora.Cache:loadAsync(preloadList, handler) -- 1248
end -- 1245
return ____exports -- 1245
