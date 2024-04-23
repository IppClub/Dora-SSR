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
function visitNode(nodeStack, node, parent) -- 1228
    if type(node) ~= "table" then -- 1228
        return -- 1230
    end -- 1230
    local enode = node -- 1232
    if enode.type == nil then -- 1232
        local list = node -- 1234
        if #list > 0 then -- 1234
            for i = 1, #list do -- 1234
                local stack = {} -- 1237
                visitNode(stack, list[i], parent) -- 1238
                for i = 1, #stack do -- 1238
                    nodeStack[#nodeStack + 1] = stack[i] -- 1240
                end -- 1240
            end -- 1240
        end -- 1240
    else -- 1240
        local handler = elementMap[enode.type] -- 1245
        if handler ~= nil then -- 1245
            handler(nodeStack, enode, parent) -- 1247
        else -- 1247
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1249
        end -- 1249
    end -- 1249
end -- 1249
function ____exports.toNode(enode) -- 1254
    local nodeStack = {} -- 1255
    visitNode(nodeStack, enode) -- 1256
    if #nodeStack == 1 then -- 1256
        return nodeStack[1] -- 1258
    elseif #nodeStack > 1 then -- 1258
        local node = dora.Node() -- 1260
        for i = 1, #nodeStack do -- 1260
            node:addChild(nodeStack[i]) -- 1262
        end -- 1262
        return node -- 1264
    end -- 1264
    return nil -- 1266
end -- 1254
____exports.React = {} -- 1254
local React = ____exports.React -- 1254
do -- 1254
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
    ["physics-world"] = function(nodeStack, enode, _parent) -- 931
        addChild( -- 932
            nodeStack, -- 932
            getPhysicsWorld(enode), -- 932
            enode -- 932
        ) -- 932
    end, -- 931
    contact = function(nodeStack, enode, _parent) -- 934
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 935
        if world ~= nil then -- 935
            local contact = enode.props -- 937
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 938
        else -- 938
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 940
        end -- 940
    end, -- 934
    body = function(nodeStack, enode, _parent) -- 943
        local def = enode.props -- 944
        if def.world then -- 944
            addChild( -- 946
                nodeStack, -- 946
                getBody(enode, def.world), -- 946
                enode -- 946
            ) -- 946
            return -- 947
        end -- 947
        local world = dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 949
        if world ~= nil then -- 949
            addChild( -- 951
                nodeStack, -- 951
                getBody(enode, world), -- 951
                enode -- 951
            ) -- 951
        else -- 951
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 953
        end -- 953
    end, -- 943
    ["rect-fixture"] = bodyCheck, -- 956
    ["polygon-fixture"] = bodyCheck, -- 957
    ["multi-fixture"] = bodyCheck, -- 958
    ["disk-fixture"] = bodyCheck, -- 959
    ["chain-fixture"] = bodyCheck, -- 960
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 961
        local joint = enode.props -- 962
        if joint.ref == nil then -- 962
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 964
            return -- 965
        end -- 965
        if joint.bodyA.current == nil then -- 965
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 968
            return -- 969
        end -- 969
        if joint.bodyB.current == nil then -- 969
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 972
            return -- 973
        end -- 973
        local ____joint_ref_13 = joint.ref -- 975
        local ____self_11 = dora.Joint -- 975
        local ____self_11_distance_12 = ____self_11.distance -- 975
        local ____joint_canCollide_10 = joint.canCollide -- 976
        if ____joint_canCollide_10 == nil then -- 976
            ____joint_canCollide_10 = false -- 976
        end -- 976
        ____joint_ref_13.current = ____self_11_distance_12( -- 975
            ____self_11, -- 975
            ____joint_canCollide_10, -- 976
            joint.bodyA.current, -- 977
            joint.bodyB.current, -- 978
            joint.anchorA or dora.Vec2.zero, -- 979
            joint.anchorB or dora.Vec2.zero, -- 980
            joint.frequency or 0, -- 981
            joint.damping or 0 -- 982
        ) -- 982
    end, -- 961
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 984
        local joint = enode.props -- 985
        if joint.ref == nil then -- 985
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 987
            return -- 988
        end -- 988
        if joint.bodyA.current == nil then -- 988
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 991
            return -- 992
        end -- 992
        if joint.bodyB.current == nil then -- 992
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 995
            return -- 996
        end -- 996
        local ____joint_ref_17 = joint.ref -- 998
        local ____self_15 = dora.Joint -- 998
        local ____self_15_friction_16 = ____self_15.friction -- 998
        local ____joint_canCollide_14 = joint.canCollide -- 999
        if ____joint_canCollide_14 == nil then -- 999
            ____joint_canCollide_14 = false -- 999
        end -- 999
        ____joint_ref_17.current = ____self_15_friction_16( -- 998
            ____self_15, -- 998
            ____joint_canCollide_14, -- 999
            joint.bodyA.current, -- 1000
            joint.bodyB.current, -- 1001
            joint.worldPos, -- 1002
            joint.maxForce, -- 1003
            joint.maxTorque -- 1004
        ) -- 1004
    end, -- 984
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 1007
        local joint = enode.props -- 1008
        if joint.ref == nil then -- 1008
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1010
            return -- 1011
        end -- 1011
        if joint.jointA.current == nil then -- 1011
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1014
            return -- 1015
        end -- 1015
        if joint.jointB.current == nil then -- 1015
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1018
            return -- 1019
        end -- 1019
        local ____joint_ref_21 = joint.ref -- 1021
        local ____self_19 = dora.Joint -- 1021
        local ____self_19_gear_20 = ____self_19.gear -- 1021
        local ____joint_canCollide_18 = joint.canCollide -- 1022
        if ____joint_canCollide_18 == nil then -- 1022
            ____joint_canCollide_18 = false -- 1022
        end -- 1022
        ____joint_ref_21.current = ____self_19_gear_20( -- 1021
            ____self_19, -- 1021
            ____joint_canCollide_18, -- 1022
            joint.jointA.current, -- 1023
            joint.jointB.current, -- 1024
            joint.ratio or 1 -- 1025
        ) -- 1025
    end, -- 1007
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 1028
        local joint = enode.props -- 1029
        if joint.ref == nil then -- 1029
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1031
            return -- 1032
        end -- 1032
        if joint.bodyA.current == nil then -- 1032
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1035
            return -- 1036
        end -- 1036
        if joint.bodyB.current == nil then -- 1036
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1039
            return -- 1040
        end -- 1040
        local ____joint_ref_25 = joint.ref -- 1042
        local ____self_23 = dora.Joint -- 1042
        local ____self_23_spring_24 = ____self_23.spring -- 1042
        local ____joint_canCollide_22 = joint.canCollide -- 1043
        if ____joint_canCollide_22 == nil then -- 1043
            ____joint_canCollide_22 = false -- 1043
        end -- 1043
        ____joint_ref_25.current = ____self_23_spring_24( -- 1042
            ____self_23, -- 1042
            ____joint_canCollide_22, -- 1043
            joint.bodyA.current, -- 1044
            joint.bodyB.current, -- 1045
            joint.linearOffset, -- 1046
            joint.angularOffset, -- 1047
            joint.maxForce, -- 1048
            joint.maxTorque, -- 1049
            joint.correctionFactor or 1 -- 1050
        ) -- 1050
    end, -- 1028
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1053
        local joint = enode.props -- 1054
        if joint.ref == nil then -- 1054
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1056
            return -- 1057
        end -- 1057
        if joint.body.current == nil then -- 1057
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1060
            return -- 1061
        end -- 1061
        local ____joint_ref_29 = joint.ref -- 1063
        local ____self_27 = dora.Joint -- 1063
        local ____self_27_move_28 = ____self_27.move -- 1063
        local ____joint_canCollide_26 = joint.canCollide -- 1064
        if ____joint_canCollide_26 == nil then -- 1064
            ____joint_canCollide_26 = false -- 1064
        end -- 1064
        ____joint_ref_29.current = ____self_27_move_28( -- 1063
            ____self_27, -- 1063
            ____joint_canCollide_26, -- 1064
            joint.body.current, -- 1065
            joint.targetPos, -- 1066
            joint.maxForce, -- 1067
            joint.frequency, -- 1068
            joint.damping or 0.7 -- 1069
        ) -- 1069
    end, -- 1053
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1072
        local joint = enode.props -- 1073
        if joint.ref == nil then -- 1073
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1075
            return -- 1076
        end -- 1076
        if joint.bodyA.current == nil then -- 1076
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1079
            return -- 1080
        end -- 1080
        if joint.bodyB.current == nil then -- 1080
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1083
            return -- 1084
        end -- 1084
        local ____joint_ref_33 = joint.ref -- 1086
        local ____self_31 = dora.Joint -- 1086
        local ____self_31_prismatic_32 = ____self_31.prismatic -- 1086
        local ____joint_canCollide_30 = joint.canCollide -- 1087
        if ____joint_canCollide_30 == nil then -- 1087
            ____joint_canCollide_30 = false -- 1087
        end -- 1087
        ____joint_ref_33.current = ____self_31_prismatic_32( -- 1086
            ____self_31, -- 1086
            ____joint_canCollide_30, -- 1087
            joint.bodyA.current, -- 1088
            joint.bodyB.current, -- 1089
            joint.worldPos, -- 1090
            joint.axisAngle, -- 1091
            joint.lowerTranslation or 0, -- 1092
            joint.upperTranslation or 0, -- 1093
            joint.maxMotorForce or 0, -- 1094
            joint.motorSpeed or 0 -- 1095
        ) -- 1095
    end, -- 1072
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1098
        local joint = enode.props -- 1099
        if joint.ref == nil then -- 1099
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1101
            return -- 1102
        end -- 1102
        if joint.bodyA.current == nil then -- 1102
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1105
            return -- 1106
        end -- 1106
        if joint.bodyB.current == nil then -- 1106
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1109
            return -- 1110
        end -- 1110
        local ____joint_ref_37 = joint.ref -- 1112
        local ____self_35 = dora.Joint -- 1112
        local ____self_35_pulley_36 = ____self_35.pulley -- 1112
        local ____joint_canCollide_34 = joint.canCollide -- 1113
        if ____joint_canCollide_34 == nil then -- 1113
            ____joint_canCollide_34 = false -- 1113
        end -- 1113
        ____joint_ref_37.current = ____self_35_pulley_36( -- 1112
            ____self_35, -- 1112
            ____joint_canCollide_34, -- 1113
            joint.bodyA.current, -- 1114
            joint.bodyB.current, -- 1115
            joint.anchorA or dora.Vec2.zero, -- 1116
            joint.anchorB or dora.Vec2.zero, -- 1117
            joint.groundAnchorA, -- 1118
            joint.groundAnchorB, -- 1119
            joint.ratio or 1 -- 1120
        ) -- 1120
    end, -- 1098
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1123
        local joint = enode.props -- 1124
        if joint.ref == nil then -- 1124
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1126
            return -- 1127
        end -- 1127
        if joint.bodyA.current == nil then -- 1127
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1130
            return -- 1131
        end -- 1131
        if joint.bodyB.current == nil then -- 1131
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1134
            return -- 1135
        end -- 1135
        local ____joint_ref_41 = joint.ref -- 1137
        local ____self_39 = dora.Joint -- 1137
        local ____self_39_revolute_40 = ____self_39.revolute -- 1137
        local ____joint_canCollide_38 = joint.canCollide -- 1138
        if ____joint_canCollide_38 == nil then -- 1138
            ____joint_canCollide_38 = false -- 1138
        end -- 1138
        ____joint_ref_41.current = ____self_39_revolute_40( -- 1137
            ____self_39, -- 1137
            ____joint_canCollide_38, -- 1138
            joint.bodyA.current, -- 1139
            joint.bodyB.current, -- 1140
            joint.worldPos, -- 1141
            joint.lowerAngle or 0, -- 1142
            joint.upperAngle or 0, -- 1143
            joint.maxMotorTorque or 0, -- 1144
            joint.motorSpeed or 0 -- 1145
        ) -- 1145
    end, -- 1123
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1148
        local joint = enode.props -- 1149
        if joint.ref == nil then -- 1149
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1151
            return -- 1152
        end -- 1152
        if joint.bodyA.current == nil then -- 1152
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1155
            return -- 1156
        end -- 1156
        if joint.bodyB.current == nil then -- 1156
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1159
            return -- 1160
        end -- 1160
        local ____joint_ref_45 = joint.ref -- 1162
        local ____self_43 = dora.Joint -- 1162
        local ____self_43_rope_44 = ____self_43.rope -- 1162
        local ____joint_canCollide_42 = joint.canCollide -- 1163
        if ____joint_canCollide_42 == nil then -- 1163
            ____joint_canCollide_42 = false -- 1163
        end -- 1163
        ____joint_ref_45.current = ____self_43_rope_44( -- 1162
            ____self_43, -- 1162
            ____joint_canCollide_42, -- 1163
            joint.bodyA.current, -- 1164
            joint.bodyB.current, -- 1165
            joint.anchorA or dora.Vec2.zero, -- 1166
            joint.anchorB or dora.Vec2.zero, -- 1167
            joint.maxLength or 0 -- 1168
        ) -- 1168
    end, -- 1148
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1171
        local joint = enode.props -- 1172
        if joint.ref == nil then -- 1172
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1174
            return -- 1175
        end -- 1175
        if joint.bodyA.current == nil then -- 1175
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1178
            return -- 1179
        end -- 1179
        if joint.bodyB.current == nil then -- 1179
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1182
            return -- 1183
        end -- 1183
        local ____joint_ref_49 = joint.ref -- 1185
        local ____self_47 = dora.Joint -- 1185
        local ____self_47_weld_48 = ____self_47.weld -- 1185
        local ____joint_canCollide_46 = joint.canCollide -- 1186
        if ____joint_canCollide_46 == nil then -- 1186
            ____joint_canCollide_46 = false -- 1186
        end -- 1186
        ____joint_ref_49.current = ____self_47_weld_48( -- 1185
            ____self_47, -- 1185
            ____joint_canCollide_46, -- 1186
            joint.bodyA.current, -- 1187
            joint.bodyB.current, -- 1188
            joint.worldPos, -- 1189
            joint.frequency or 0, -- 1190
            joint.damping or 0 -- 1191
        ) -- 1191
    end, -- 1171
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1194
        local joint = enode.props -- 1195
        if joint.ref == nil then -- 1195
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1197
            return -- 1198
        end -- 1198
        if joint.bodyA.current == nil then -- 1198
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1201
            return -- 1202
        end -- 1202
        if joint.bodyB.current == nil then -- 1202
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1205
            return -- 1206
        end -- 1206
        local ____joint_ref_53 = joint.ref -- 1208
        local ____self_51 = dora.Joint -- 1208
        local ____self_51_wheel_52 = ____self_51.wheel -- 1208
        local ____joint_canCollide_50 = joint.canCollide -- 1209
        if ____joint_canCollide_50 == nil then -- 1209
            ____joint_canCollide_50 = false -- 1209
        end -- 1209
        ____joint_ref_53.current = ____self_51_wheel_52( -- 1208
            ____self_51, -- 1208
            ____joint_canCollide_50, -- 1209
            joint.bodyA.current, -- 1210
            joint.bodyB.current, -- 1211
            joint.worldPos, -- 1212
            joint.axisAngle, -- 1213
            joint.maxMotorTorque or 0, -- 1214
            joint.motorSpeed or 0, -- 1215
            joint.frequency or 0, -- 1216
            joint.damping or 0.7 -- 1217
        ) -- 1217
    end, -- 1194
    ["custom-node"] = function(nodeStack, enode, parent) -- 1220
        local node = getCustomNode(enode) -- 1221
        if node ~= nil then -- 1221
            addChild(nodeStack, node, enode) -- 1223
        end -- 1223
    end, -- 1220
    ["custom-element"] = function() -- 1226
    end -- 1226
} -- 1226
function ____exports.useRef(item) -- 1269
    local ____item_54 = item -- 1270
    if ____item_54 == nil then -- 1270
        ____item_54 = nil -- 1270
    end -- 1270
    return {current = ____item_54} -- 1270
end -- 1269
local function getPreload(preloadList, node) -- 1273
    if type(node) ~= "table" then -- 1273
        return -- 1275
    end -- 1275
    local enode = node -- 1277
    if enode.type == nil then -- 1277
        local list = node -- 1279
        if #list > 0 then -- 1279
            for i = 1, #list do -- 1279
                getPreload(preloadList, list[i]) -- 1282
            end -- 1282
        end -- 1282
    else -- 1282
        repeat -- 1282
            local ____switch274 = enode.type -- 1282
            local sprite, playable, model, spine, dragonBone, label -- 1282
            local ____cond274 = ____switch274 == "sprite" -- 1282
            if ____cond274 then -- 1282
                sprite = enode.props -- 1288
                preloadList[#preloadList + 1] = sprite.file -- 1289
                break -- 1290
            end -- 1290
            ____cond274 = ____cond274 or ____switch274 == "playable" -- 1290
            if ____cond274 then -- 1290
                playable = enode.props -- 1292
                preloadList[#preloadList + 1] = playable.file -- 1293
                break -- 1294
            end -- 1294
            ____cond274 = ____cond274 or ____switch274 == "model" -- 1294
            if ____cond274 then -- 1294
                model = enode.props -- 1296
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1297
                break -- 1298
            end -- 1298
            ____cond274 = ____cond274 or ____switch274 == "spine" -- 1298
            if ____cond274 then -- 1298
                spine = enode.props -- 1300
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1301
                break -- 1302
            end -- 1302
            ____cond274 = ____cond274 or ____switch274 == "dragon-bone" -- 1302
            if ____cond274 then -- 1302
                dragonBone = enode.props -- 1304
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1305
                break -- 1306
            end -- 1306
            ____cond274 = ____cond274 or ____switch274 == "label" -- 1306
            if ____cond274 then -- 1306
                label = enode.props -- 1308
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1309
                break -- 1310
            end -- 1310
        until true -- 1310
    end -- 1310
    getPreload(preloadList, enode.children) -- 1313
end -- 1273
function ____exports.preloadAsync(enode, handler) -- 1316
    local preloadList = {} -- 1317
    getPreload(preloadList, enode) -- 1318
    dora.Cache:loadAsync(preloadList, handler) -- 1319
end -- 1316
return ____exports -- 1316