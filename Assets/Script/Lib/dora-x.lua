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
function visitNode(nodeStack, node, parent) -- 1165
    if type(node) ~= "table" then -- 1165
        return -- 1167
    end -- 1167
    local enode = node -- 1169
    if enode.type == nil then -- 1169
        local list = node -- 1171
        if #list > 0 then -- 1171
            for i = 1, #list do -- 1171
                local stack = {} -- 1174
                visitNode(stack, list[i], parent) -- 1175
                for i = 1, #stack do -- 1175
                    nodeStack[#nodeStack + 1] = stack[i] -- 1177
                end -- 1177
            end -- 1177
        end -- 1177
    else -- 1177
        local handler = elementMap[enode.type] -- 1182
        if handler ~= nil then -- 1182
            handler(nodeStack, enode, parent) -- 1184
        else -- 1184
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1186
        end -- 1186
    end -- 1186
end -- 1186
function ____exports.toNode(enode) -- 1191
    local nodeStack = {} -- 1192
    visitNode(nodeStack, enode) -- 1193
    if #nodeStack == 1 then -- 1193
        return nodeStack[1] -- 1195
    elseif #nodeStack > 1 then -- 1195
        local node = dora.Node() -- 1197
        for i = 1, #nodeStack do -- 1197
            node:addChild(nodeStack[i]) -- 1199
        end -- 1199
        return node -- 1201
    end -- 1201
    return nil -- 1203
end -- 1191
____exports.React = {} -- 1191
local React = ____exports.React -- 1191
do -- 1191
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
local function addChild(nodeStack, cnode, enode) -- 653
    if #nodeStack > 0 then -- 653
        local last = nodeStack[#nodeStack] -- 655
        last:addChild(cnode) -- 656
    end -- 656
    nodeStack[#nodeStack + 1] = cnode -- 658
    local ____enode_9 = enode -- 659
    local children = ____enode_9.children -- 659
    for i = 1, #children do -- 659
        visitNode(nodeStack, children[i], enode) -- 661
    end -- 661
    if #nodeStack > 1 then -- 661
        table.remove(nodeStack) -- 664
    end -- 664
end -- 653
local function drawNodeCheck(_nodeStack, enode, parent) -- 672
    if parent == nil or parent.type ~= "draw-node" then -- 672
        Warn(("label <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 674
    end -- 674
end -- 672
local function actionCheck(_nodeStack, enode, parent) -- 678
    local unsupported = false -- 679
    if parent == nil then -- 679
        unsupported = true -- 681
    else -- 681
        repeat -- 681
            local ____switch149 = enode.type -- 681
            local ____cond149 = ____switch149 == "action" or ____switch149 == "spawn" or ____switch149 == "sequence" -- 681
            if ____cond149 then -- 681
                break -- 684
            end -- 684
            do -- 684
                unsupported = true -- 685
                break -- 685
            end -- 685
        until true -- 685
    end -- 685
    if unsupported then -- 685
        Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn> or <sequence> to take effect") -- 689
    end -- 689
end -- 678
local function bodyCheck(_nodeStack, enode, parent) -- 693
    if parent == nil or parent.type ~= "body" then -- 693
        Warn(("label <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 695
    end -- 695
end -- 693
local actionMap = { -- 699
    ["anchor-x"] = dora.AnchorX, -- 702
    ["anchor-y"] = dora.AnchorY, -- 703
    angle = dora.Angle, -- 704
    ["angle-x"] = dora.AngleX, -- 705
    ["angle-y"] = dora.AngleY, -- 706
    width = dora.Width, -- 707
    height = dora.Height, -- 708
    opacity = dora.Opacity, -- 709
    roll = dora.Roll, -- 710
    scale = dora.Scale, -- 711
    ["scale-x"] = dora.ScaleX, -- 712
    ["scale-y"] = dora.ScaleY, -- 713
    ["skew-x"] = dora.SkewX, -- 714
    ["skew-y"] = dora.SkewY, -- 715
    ["move-x"] = dora.X, -- 716
    ["move-y"] = dora.Y, -- 717
    ["move-z"] = dora.Z -- 718
} -- 718
elementMap = { -- 721
    node = function(nodeStack, enode, parent) -- 722
        addChild( -- 723
            nodeStack, -- 723
            getNode(enode), -- 723
            enode -- 723
        ) -- 723
    end, -- 722
    ["clip-node"] = function(nodeStack, enode, parent) -- 725
        addChild( -- 726
            nodeStack, -- 726
            getClipNode(enode), -- 726
            enode -- 726
        ) -- 726
    end, -- 725
    playable = function(nodeStack, enode, parent) -- 728
        local cnode = getPlayable(enode) -- 729
        if cnode ~= nil then -- 729
            addChild(nodeStack, cnode, enode) -- 731
        end -- 731
    end, -- 728
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 734
        local cnode = getDragonBone(enode) -- 735
        if cnode ~= nil then -- 735
            addChild(nodeStack, cnode, enode) -- 737
        end -- 737
    end, -- 734
    spine = function(nodeStack, enode, parent) -- 740
        local cnode = getSpine(enode) -- 741
        if cnode ~= nil then -- 741
            addChild(nodeStack, cnode, enode) -- 743
        end -- 743
    end, -- 740
    model = function(nodeStack, enode, parent) -- 746
        local cnode = getModel(enode) -- 747
        if cnode ~= nil then -- 747
            addChild(nodeStack, cnode, enode) -- 749
        end -- 749
    end, -- 746
    ["draw-node"] = function(nodeStack, enode, parent) -- 752
        addChild( -- 753
            nodeStack, -- 753
            getDrawNode(enode), -- 753
            enode -- 753
        ) -- 753
    end, -- 752
    ["dot-shape"] = drawNodeCheck, -- 755
    ["segment-shape"] = drawNodeCheck, -- 756
    ["polygon-shape"] = drawNodeCheck, -- 757
    ["verts-shape"] = drawNodeCheck, -- 758
    grid = function(nodeStack, enode, parent) -- 759
        addChild( -- 760
            nodeStack, -- 760
            getGrid(enode), -- 760
            enode -- 760
        ) -- 760
    end, -- 759
    sprite = function(nodeStack, enode, parent) -- 762
        local cnode = getSprite(enode) -- 763
        if cnode ~= nil then -- 763
            addChild(nodeStack, cnode, enode) -- 765
        end -- 765
    end, -- 762
    label = function(nodeStack, enode, parent) -- 768
        local cnode = getLabel(enode) -- 769
        if cnode ~= nil then -- 769
            addChild(nodeStack, cnode, enode) -- 771
        end -- 771
    end, -- 768
    line = function(nodeStack, enode, parent) -- 774
        addChild( -- 775
            nodeStack, -- 775
            getLine(enode), -- 775
            enode -- 775
        ) -- 775
    end, -- 774
    particle = function(nodeStack, enode, parent) -- 777
        local cnode = getParticle(enode) -- 778
        if cnode ~= nil then -- 778
            addChild(nodeStack, cnode, enode) -- 780
        end -- 780
    end, -- 777
    menu = function(nodeStack, enode, parent) -- 783
        addChild( -- 784
            nodeStack, -- 784
            getMenu(enode), -- 784
            enode -- 784
        ) -- 784
    end, -- 783
    action = function(_nodeStack, enode, parent) -- 786
        if #enode.children == 0 then -- 786
            return -- 787
        end -- 787
        local action = enode.props -- 788
        if action.ref == nil then -- 788
            return -- 789
        end -- 789
        local function visitAction(actionStack, enode) -- 790
            local createAction = actionMap[enode.type] -- 791
            if createAction ~= nil then -- 791
                actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 793
                return -- 794
            end -- 794
            repeat -- 794
                local ____switch178 = enode.type -- 794
                local ____cond178 = ____switch178 == "delay" -- 794
                if ____cond178 then -- 794
                    do -- 794
                        local item = enode.props -- 798
                        actionStack[#actionStack + 1] = dora.Delay(item.time) -- 799
                        break -- 800
                    end -- 800
                end -- 800
                ____cond178 = ____cond178 or ____switch178 == "event" -- 800
                if ____cond178 then -- 800
                    do -- 800
                        local item = enode.props -- 803
                        actionStack[#actionStack + 1] = dora.Event(item.name, item.param) -- 804
                        break -- 805
                    end -- 805
                end -- 805
                ____cond178 = ____cond178 or ____switch178 == "hide" -- 805
                if ____cond178 then -- 805
                    do -- 805
                        actionStack[#actionStack + 1] = dora.Hide() -- 808
                        break -- 809
                    end -- 809
                end -- 809
                ____cond178 = ____cond178 or ____switch178 == "show" -- 809
                if ____cond178 then -- 809
                    do -- 809
                        actionStack[#actionStack + 1] = dora.Show() -- 812
                        break -- 813
                    end -- 813
                end -- 813
                ____cond178 = ____cond178 or ____switch178 == "move" -- 813
                if ____cond178 then -- 813
                    do -- 813
                        local item = enode.props -- 816
                        actionStack[#actionStack + 1] = dora.Move( -- 817
                            item.time, -- 817
                            dora.Vec2(item.startX, item.startY), -- 817
                            dora.Vec2(item.stopX, item.stopY), -- 817
                            item.easing -- 817
                        ) -- 817
                        break -- 818
                    end -- 818
                end -- 818
                ____cond178 = ____cond178 or ____switch178 == "spawn" -- 818
                if ____cond178 then -- 818
                    do -- 818
                        local spawnStack = {} -- 821
                        for i = 1, #enode.children do -- 821
                            visitAction(spawnStack, enode.children[i]) -- 823
                        end -- 823
                        actionStack[#actionStack + 1] = dora.Spawn(table.unpack(spawnStack)) -- 825
                        break -- 826
                    end -- 826
                end -- 826
                ____cond178 = ____cond178 or ____switch178 == "sequence" -- 826
                if ____cond178 then -- 826
                    do -- 826
                        local sequenceStack = {} -- 829
                        for i = 1, #enode.children do -- 829
                            visitAction(sequenceStack, enode.children[i]) -- 831
                        end -- 831
                        actionStack[#actionStack + 1] = dora.Sequence(table.unpack(sequenceStack)) -- 833
                        break -- 834
                    end -- 834
                end -- 834
                do -- 834
                    Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 837
                    break -- 838
                end -- 838
            until true -- 838
        end -- 790
        local actionStack = {} -- 841
        for i = 1, #enode.children do -- 841
            visitAction(actionStack, enode.children[i]) -- 843
        end -- 843
        if #actionStack == 1 then -- 843
            action.ref.current = actionStack[1] -- 846
        elseif #actionStack > 1 then -- 846
            action.ref.current = dora.Sequence(table.unpack(actionStack)) -- 848
        end -- 848
    end, -- 786
    ["anchor-x"] = actionCheck, -- 851
    ["anchor-y"] = actionCheck, -- 852
    angle = actionCheck, -- 853
    ["angle-x"] = actionCheck, -- 854
    ["angle-y"] = actionCheck, -- 855
    delay = actionCheck, -- 856
    event = actionCheck, -- 857
    width = actionCheck, -- 858
    height = actionCheck, -- 859
    hide = actionCheck, -- 860
    show = actionCheck, -- 861
    move = actionCheck, -- 862
    opacity = actionCheck, -- 863
    roll = actionCheck, -- 864
    scale = actionCheck, -- 865
    ["scale-x"] = actionCheck, -- 866
    ["scale-y"] = actionCheck, -- 867
    ["skew-x"] = actionCheck, -- 868
    ["skew-y"] = actionCheck, -- 869
    ["move-x"] = actionCheck, -- 870
    ["move-y"] = actionCheck, -- 871
    ["move-z"] = actionCheck, -- 872
    spawn = actionCheck, -- 873
    sequence = actionCheck, -- 874
    ["physics-world"] = function(nodeStack, enode, _parent) -- 875
        addChild( -- 876
            nodeStack, -- 876
            getPhysicsWorld(enode), -- 876
            enode -- 876
        ) -- 876
    end, -- 875
    contact = function(nodeStack, enode, _parent) -- 878
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 879
        if world ~= nil then -- 879
            local contact = enode.props -- 881
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 882
        else -- 882
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 884
        end -- 884
    end, -- 878
    body = function(nodeStack, enode, _parent) -- 887
        local def = enode.props -- 888
        if def.world then -- 888
            addChild( -- 890
                nodeStack, -- 890
                getBody(enode, def.world), -- 890
                enode -- 890
            ) -- 890
            return -- 891
        end -- 891
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 893
        if world ~= nil then -- 893
            addChild( -- 895
                nodeStack, -- 895
                getBody(enode, world), -- 895
                enode -- 895
            ) -- 895
        else -- 895
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 897
        end -- 897
    end, -- 887
    ["rect-fixture"] = bodyCheck, -- 900
    ["polygon-fixture"] = bodyCheck, -- 901
    ["multi-fixture"] = bodyCheck, -- 902
    ["disk-fixture"] = bodyCheck, -- 903
    ["chain-fixture"] = bodyCheck, -- 904
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 905
        local joint = enode.props -- 906
        if joint.ref == nil then -- 906
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 908
            return -- 909
        end -- 909
        if joint.bodyA.current == nil then -- 909
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 912
            return -- 913
        end -- 913
        if joint.bodyB.current == nil then -- 913
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 916
            return -- 917
        end -- 917
        local ____joint_ref_13 = joint.ref -- 919
        local ____self_11 = dora.Joint -- 919
        local ____self_11_distance_12 = ____self_11.distance -- 919
        local ____joint_canCollide_10 = joint.canCollide -- 920
        if ____joint_canCollide_10 == nil then -- 920
            ____joint_canCollide_10 = false -- 920
        end -- 920
        ____joint_ref_13.current = ____self_11_distance_12( -- 919
            ____self_11, -- 919
            ____joint_canCollide_10, -- 920
            joint.bodyA.current, -- 921
            joint.bodyB.current, -- 922
            joint.anchorA or dora.Vec2.zero, -- 923
            joint.anchorB or dora.Vec2.zero, -- 924
            joint.frequency or 0, -- 925
            joint.damping or 0 -- 926
        ) -- 926
    end, -- 905
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 928
        local joint = enode.props -- 929
        if joint.ref == nil then -- 929
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 931
            return -- 932
        end -- 932
        if joint.bodyA.current == nil then -- 932
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 935
            return -- 936
        end -- 936
        if joint.bodyB.current == nil then -- 936
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 939
            return -- 940
        end -- 940
        local ____joint_ref_17 = joint.ref -- 942
        local ____self_15 = dora.Joint -- 942
        local ____self_15_friction_16 = ____self_15.friction -- 942
        local ____joint_canCollide_14 = joint.canCollide -- 943
        if ____joint_canCollide_14 == nil then -- 943
            ____joint_canCollide_14 = false -- 943
        end -- 943
        ____joint_ref_17.current = ____self_15_friction_16( -- 942
            ____self_15, -- 942
            ____joint_canCollide_14, -- 943
            joint.bodyA.current, -- 944
            joint.bodyB.current, -- 945
            joint.worldPos, -- 946
            joint.maxForce, -- 947
            joint.maxTorque -- 948
        ) -- 948
    end, -- 928
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 951
        local joint = enode.props -- 952
        if joint.ref == nil then -- 952
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 954
            return -- 955
        end -- 955
        if joint.jointA.current == nil then -- 955
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 958
            return -- 959
        end -- 959
        if joint.jointB.current == nil then -- 959
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 962
            return -- 963
        end -- 963
        local ____joint_ref_21 = joint.ref -- 965
        local ____self_19 = dora.Joint -- 965
        local ____self_19_gear_20 = ____self_19.gear -- 965
        local ____joint_canCollide_18 = joint.canCollide -- 966
        if ____joint_canCollide_18 == nil then -- 966
            ____joint_canCollide_18 = false -- 966
        end -- 966
        ____joint_ref_21.current = ____self_19_gear_20( -- 965
            ____self_19, -- 965
            ____joint_canCollide_18, -- 966
            joint.jointA.current, -- 967
            joint.jointB.current, -- 968
            joint.ratio or 1 -- 969
        ) -- 969
    end, -- 951
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 972
        local joint = enode.props -- 973
        if joint.ref == nil then -- 973
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 975
            return -- 976
        end -- 976
        if joint.bodyA.current == nil then -- 976
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 979
            return -- 980
        end -- 980
        if joint.bodyB.current == nil then -- 980
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 983
            return -- 984
        end -- 984
        local ____joint_ref_25 = joint.ref -- 986
        local ____self_23 = dora.Joint -- 986
        local ____self_23_spring_24 = ____self_23.spring -- 986
        local ____joint_canCollide_22 = joint.canCollide -- 987
        if ____joint_canCollide_22 == nil then -- 987
            ____joint_canCollide_22 = false -- 987
        end -- 987
        ____joint_ref_25.current = ____self_23_spring_24( -- 986
            ____self_23, -- 986
            ____joint_canCollide_22, -- 987
            joint.bodyA.current, -- 988
            joint.bodyB.current, -- 989
            joint.linearOffset, -- 990
            joint.angularOffset, -- 991
            joint.maxForce, -- 992
            joint.maxTorque, -- 993
            joint.correctionFactor or 1 -- 994
        ) -- 994
    end, -- 972
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 997
        local joint = enode.props -- 998
        if joint.ref == nil then -- 998
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1000
            return -- 1001
        end -- 1001
        if joint.body.current == nil then -- 1001
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1004
            return -- 1005
        end -- 1005
        local ____joint_ref_29 = joint.ref -- 1007
        local ____self_27 = dora.Joint -- 1007
        local ____self_27_move_28 = ____self_27.move -- 1007
        local ____joint_canCollide_26 = joint.canCollide -- 1008
        if ____joint_canCollide_26 == nil then -- 1008
            ____joint_canCollide_26 = false -- 1008
        end -- 1008
        ____joint_ref_29.current = ____self_27_move_28( -- 1007
            ____self_27, -- 1007
            ____joint_canCollide_26, -- 1008
            joint.body.current, -- 1009
            joint.targetPos, -- 1010
            joint.maxForce, -- 1011
            joint.frequency, -- 1012
            joint.damping or 0.7 -- 1013
        ) -- 1013
    end, -- 997
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1016
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
        local ____joint_ref_33 = joint.ref -- 1030
        local ____self_31 = dora.Joint -- 1030
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1030
        local ____joint_canCollide_30 = joint.canCollide -- 1031
        if ____joint_canCollide_30 == nil then -- 1031
            ____joint_canCollide_30 = false -- 1031
        end -- 1031
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1030
            ____self_31, -- 1030
            ____joint_canCollide_30, -- 1031
            joint.bodyA.current, -- 1032
            joint.bodyB.current, -- 1033
            joint.worldPos, -- 1034
            joint.axisAngle, -- 1035
            joint.lowerTranslation or 0, -- 1036
            joint.upperTranslation or 0, -- 1037
            joint.maxMotorForce or 0, -- 1038
            joint.motorSpeed or 0 -- 1039
        ) -- 1039
    end, -- 1016
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1042
        local joint = enode.props -- 1043
        if joint.ref == nil then -- 1043
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1045
            return -- 1046
        end -- 1046
        if joint.bodyA.current == nil then -- 1046
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1049
            return -- 1050
        end -- 1050
        if joint.bodyB.current == nil then -- 1050
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1053
            return -- 1054
        end -- 1054
        local ____joint_ref_37 = joint.ref -- 1056
        local ____self_35 = dora.Joint -- 1056
        local ____self_35_pulley_36 = ____self_35.pulley -- 1056
        local ____joint_canCollide_34 = joint.canCollide -- 1057
        if ____joint_canCollide_34 == nil then -- 1057
            ____joint_canCollide_34 = false -- 1057
        end -- 1057
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1056
            ____self_35, -- 1056
            ____joint_canCollide_34, -- 1057
            joint.bodyA.current, -- 1058
            joint.bodyB.current, -- 1059
            joint.anchorA or dora.Vec2.zero, -- 1060
            joint.anchorB or dora.Vec2.zero, -- 1061
            joint.groundAnchorA, -- 1062
            joint.groundAnchorB, -- 1063
            joint.ratio or 1 -- 1064
        ) -- 1064
    end, -- 1042
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1067
        local joint = enode.props -- 1068
        if joint.ref == nil then -- 1068
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1070
            return -- 1071
        end -- 1071
        if joint.bodyA.current == nil then -- 1071
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1074
            return -- 1075
        end -- 1075
        if joint.bodyB.current == nil then -- 1075
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1078
            return -- 1079
        end -- 1079
        local ____joint_ref_41 = joint.ref -- 1081
        local ____self_39 = dora.Joint -- 1081
        local ____self_39_revolute_40 = ____self_39.revolute -- 1081
        local ____joint_canCollide_38 = joint.canCollide -- 1082
        if ____joint_canCollide_38 == nil then -- 1082
            ____joint_canCollide_38 = false -- 1082
        end -- 1082
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1081
            ____self_39, -- 1081
            ____joint_canCollide_38, -- 1082
            joint.bodyA.current, -- 1083
            joint.bodyB.current, -- 1084
            joint.worldPos, -- 1085
            joint.lowerAngle or 0, -- 1086
            joint.upperAngle or 0, -- 1087
            joint.maxMotorTorque or 0, -- 1088
            joint.motorSpeed or 0 -- 1089
        ) -- 1089
    end, -- 1067
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1092
        local joint = enode.props -- 1093
        if joint.ref == nil then -- 1093
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1095
            return -- 1096
        end -- 1096
        if joint.bodyA.current == nil then -- 1096
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1099
            return -- 1100
        end -- 1100
        if joint.bodyB.current == nil then -- 1100
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1103
            return -- 1104
        end -- 1104
        local ____joint_ref_45 = joint.ref -- 1106
        local ____self_43 = dora.Joint -- 1106
        local ____self_43_rope_44 = ____self_43.rope -- 1106
        local ____joint_canCollide_42 = joint.canCollide -- 1107
        if ____joint_canCollide_42 == nil then -- 1107
            ____joint_canCollide_42 = false -- 1107
        end -- 1107
        ____joint_ref_45.current = ____self_43_rope_44( -- 1106
            ____self_43, -- 1106
            ____joint_canCollide_42, -- 1107
            joint.bodyA.current, -- 1108
            joint.bodyB.current, -- 1109
            joint.anchorA or dora.Vec2.zero, -- 1110
            joint.anchorB or dora.Vec2.zero, -- 1111
            joint.maxLength or 0 -- 1112
        ) -- 1112
    end, -- 1092
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1115
        local joint = enode.props -- 1116
        if joint.ref == nil then -- 1116
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1118
            return -- 1119
        end -- 1119
        if joint.bodyA.current == nil then -- 1119
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1122
            return -- 1123
        end -- 1123
        if joint.bodyB.current == nil then -- 1123
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1126
            return -- 1127
        end -- 1127
        local ____joint_ref_49 = joint.ref -- 1129
        local ____self_47 = dora.Joint -- 1129
        local ____self_47_weld_48 = ____self_47.weld -- 1129
        local ____joint_canCollide_46 = joint.canCollide -- 1130
        if ____joint_canCollide_46 == nil then -- 1130
            ____joint_canCollide_46 = false -- 1130
        end -- 1130
        ____joint_ref_49.current = ____self_47_weld_48( -- 1129
            ____self_47, -- 1129
            ____joint_canCollide_46, -- 1130
            joint.bodyA.current, -- 1131
            joint.bodyB.current, -- 1132
            joint.worldPos, -- 1133
            joint.frequency or 0, -- 1134
            joint.damping or 0 -- 1135
        ) -- 1135
    end, -- 1115
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1138
        local joint = enode.props -- 1139
        if joint.ref == nil then -- 1139
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1141
            return -- 1142
        end -- 1142
        if joint.bodyA.current == nil then -- 1142
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1145
            return -- 1146
        end -- 1146
        if joint.bodyB.current == nil then -- 1146
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1149
            return -- 1150
        end -- 1150
        local ____joint_ref_53 = joint.ref -- 1152
        local ____self_51 = dora.Joint -- 1152
        local ____self_51_wheel_52 = ____self_51.wheel -- 1152
        local ____joint_canCollide_50 = joint.canCollide -- 1153
        if ____joint_canCollide_50 == nil then -- 1153
            ____joint_canCollide_50 = false -- 1153
        end -- 1153
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1152
            ____self_51, -- 1152
            ____joint_canCollide_50, -- 1153
            joint.bodyA.current, -- 1154
            joint.bodyB.current, -- 1155
            joint.worldPos, -- 1156
            joint.axisAngle, -- 1157
            joint.maxMotorTorque or 0, -- 1158
            joint.motorSpeed or 0, -- 1159
            joint.frequency or 0, -- 1160
            joint.damping or 0.7 -- 1161
        ) -- 1161
    end -- 1138
} -- 1138
function ____exports.useRef(item) -- 1206
    local ____item_54 = item -- 1207
    if ____item_54 == nil then -- 1207
        ____item_54 = nil -- 1207
    end -- 1207
    return {current = ____item_54} -- 1207
end -- 1206
local function getPreload(preloadList, node) -- 1210
    if type(node) ~= "table" then -- 1210
        return -- 1212
    end -- 1212
    local enode = node -- 1214
    if enode.type == nil then -- 1214
        local list = node -- 1216
        if #list > 0 then -- 1216
            for i = 1, #list do -- 1216
                getPreload(preloadList, list[i]) -- 1219
            end -- 1219
        end -- 1219
    else -- 1219
        repeat -- 1219
            local ____switch262 = enode.type -- 1219
            local sprite, playable, model, spine, dragonBone, label -- 1219
            local ____cond262 = ____switch262 == "sprite" -- 1219
            if ____cond262 then -- 1219
                sprite = enode.props -- 1225
                preloadList[#preloadList + 1] = sprite.file -- 1226
                break -- 1227
            end -- 1227
            ____cond262 = ____cond262 or ____switch262 == "playable" -- 1227
            if ____cond262 then -- 1227
                playable = enode.props -- 1229
                preloadList[#preloadList + 1] = playable.file -- 1230
                break -- 1231
            end -- 1231
            ____cond262 = ____cond262 or ____switch262 == "model" -- 1231
            if ____cond262 then -- 1231
                model = enode.props -- 1233
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1234
                break -- 1235
            end -- 1235
            ____cond262 = ____cond262 or ____switch262 == "spine" -- 1235
            if ____cond262 then -- 1235
                spine = enode.props -- 1237
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1238
                break -- 1239
            end -- 1239
            ____cond262 = ____cond262 or ____switch262 == "dragon-bone" -- 1239
            if ____cond262 then -- 1239
                dragonBone = enode.props -- 1241
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1242
                break -- 1243
            end -- 1243
            ____cond262 = ____cond262 or ____switch262 == "label" -- 1243
            if ____cond262 then -- 1243
                label = enode.props -- 1245
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1246
                break -- 1247
            end -- 1247
        until true -- 1247
    end -- 1247
    getPreload(preloadList, enode.children) -- 1250
end -- 1210
function ____exports.preloadAsync(enode, handler) -- 1253
    local preloadList = {} -- 1254
    getPreload(preloadList, enode) -- 1255
    dora.Cache:loadAsync(preloadList, handler) -- 1256
end -- 1253
return ____exports -- 1253
