-- [ts]: DoraX.ts
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
local Dora = require("Dora") -- 11
function Warn(msg) -- 13
    print("[Dora Warning] " .. msg) -- 14
end -- 14
function visitNode(nodeStack, node, parent) -- 1345
    if type(node) ~= "table" then -- 1345
        return -- 1347
    end -- 1347
    local enode = node -- 1349
    if enode.type == nil then -- 1349
        local list = node -- 1351
        if #list > 0 then -- 1351
            for i = 1, #list do -- 1351
                local stack = {} -- 1354
                visitNode(stack, list[i], parent) -- 1355
                for i = 1, #stack do -- 1355
                    nodeStack[#nodeStack + 1] = stack[i] -- 1357
                end -- 1357
            end -- 1357
        end -- 1357
    else -- 1357
        local handler = elementMap[enode.type] -- 1362
        if handler ~= nil then -- 1362
            handler(nodeStack, enode, parent) -- 1364
        else -- 1364
            Warn(("unsupported tag <" .. enode.type) .. ">") -- 1366
        end -- 1366
    end -- 1366
end -- 1366
function ____exports.toNode(enode) -- 1371
    local nodeStack = {} -- 1372
    visitNode(nodeStack, enode) -- 1373
    if #nodeStack == 1 then -- 1373
        return nodeStack[1] -- 1375
    elseif #nodeStack > 1 then -- 1375
        local node = Dora.Node() -- 1377
        for i = 1, #nodeStack do -- 1377
            node:addChild(nodeStack[i]) -- 1379
        end -- 1379
        return node -- 1381
    end -- 1381
    return nil -- 1383
end -- 1371
____exports.React = {} -- 1371
local React = ____exports.React -- 1371
do -- 1371
    React.Component = __TS__Class() -- 17
    local Component = React.Component -- 17
    Component.name = "Component" -- 19
    function Component.prototype.____constructor(self, props) -- 20
        self.props = props -- 21
    end -- 20
    Component.isComponent = true -- 20
    React.Fragment = nil -- 17
    local function flattenChild(child) -- 30
        if type(child) ~= "table" then -- 30
            return child, true -- 32
        end -- 32
        if child.type ~= nil then -- 32
            return child, true -- 35
        elseif child.children then -- 35
            child = child.children -- 37
        end -- 37
        local list = child -- 39
        local flatChildren = {} -- 40
        for i = 1, #list do -- 40
            local child, flat = flattenChild(list[i]) -- 42
            if flat then -- 42
                flatChildren[#flatChildren + 1] = child -- 44
            else -- 44
                local listChild = child -- 46
                for i = 1, #listChild do -- 46
                    flatChildren[#flatChildren + 1] = listChild[i] -- 48
                end -- 48
            end -- 48
        end -- 48
        return flatChildren, false -- 52
    end -- 30
    function React.createElement(typeName, props, ...) -- 61
        local children = {...} -- 61
        repeat -- 61
            local ____switch14 = type(typeName) -- 61
            local ____cond14 = ____switch14 == "function" -- 61
            if ____cond14 then -- 61
                do -- 61
                    if props == nil then -- 61
                        props = {} -- 68
                    end -- 68
                    if props.children then -- 68
                        local ____props_1 = props -- 70
                        local ____array_0 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 70
                        __TS__SparseArrayPush(____array_0, ...) -- 70
                        ____props_1.children = {__TS__SparseArraySpread(____array_0)} -- 70
                    else -- 70
                        props.children = children -- 72
                    end -- 72
                    return typeName(props) -- 74
                end -- 74
            end -- 74
            ____cond14 = ____cond14 or ____switch14 == "table" -- 74
            if ____cond14 then -- 74
                do -- 74
                    if not typeName.isComponent then -- 74
                        Warn("unsupported class object in element creation") -- 78
                        return {} -- 79
                    end -- 79
                    if props == nil then -- 79
                        props = {} -- 81
                    end -- 81
                    if props.children then -- 81
                        local ____props_3 = props -- 83
                        local ____array_2 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 83
                        __TS__SparseArrayPush( -- 83
                            ____array_2, -- 83
                            table.unpack(children) -- 83
                        ) -- 83
                        ____props_3.children = {__TS__SparseArraySpread(____array_2)} -- 83
                    else -- 83
                        props.children = children -- 85
                    end -- 85
                    local inst = __TS__New(typeName, props) -- 87
                    return inst:render() -- 88
                end -- 88
            end -- 88
            do -- 88
                do -- 88
                    if props and props.children then -- 88
                        local ____array_4 = __TS__SparseArrayNew(__TS__Spread(props.children)) -- 88
                        __TS__SparseArrayPush( -- 88
                            ____array_4, -- 88
                            table.unpack(children) -- 92
                        ) -- 92
                        children = {__TS__SparseArraySpread(____array_4)} -- 92
                        props.children = nil -- 93
                    end -- 93
                    local flatChildren = {} -- 95
                    for i = 1, #children do -- 95
                        local child, flat = flattenChild(children[i]) -- 97
                        if flat then -- 97
                            flatChildren[#flatChildren + 1] = child -- 99
                        else -- 99
                            for i = 1, #child do -- 99
                                flatChildren[#flatChildren + 1] = child[i] -- 102
                            end -- 102
                        end -- 102
                    end -- 102
                    children = flatChildren -- 106
                end -- 106
            end -- 106
        until true -- 106
        if typeName == nil then -- 106
            return children -- 110
        end -- 110
        local ____typeName_6 = typeName -- 113
        local ____props_5 = props -- 114
        if ____props_5 == nil then -- 114
            ____props_5 = {} -- 114
        end -- 114
        return {type = ____typeName_6, props = ____props_5, children = children} -- 112
    end -- 61
end -- 61
local function getNode(enode, cnode, attribHandler) -- 123
    cnode = cnode or Dora.Node() -- 124
    local jnode = enode.props -- 125
    local anchor = nil -- 126
    local color3 = nil -- 127
    for k, v in pairs(enode.props) do -- 128
        repeat -- 128
            local ____switch31 = k -- 128
            local ____cond31 = ____switch31 == "ref" -- 128
            if ____cond31 then -- 128
                v.current = cnode -- 130
                break -- 130
            end -- 130
            ____cond31 = ____cond31 or ____switch31 == "anchorX" -- 130
            if ____cond31 then -- 130
                anchor = Dora.Vec2(v, (anchor or cnode.anchor).y) -- 131
                break -- 131
            end -- 131
            ____cond31 = ____cond31 or ____switch31 == "anchorY" -- 131
            if ____cond31 then -- 131
                anchor = Dora.Vec2((anchor or cnode.anchor).x, v) -- 132
                break -- 132
            end -- 132
            ____cond31 = ____cond31 or ____switch31 == "color3" -- 132
            if ____cond31 then -- 132
                color3 = Dora.Color3(v) -- 133
                break -- 133
            end -- 133
            ____cond31 = ____cond31 or ____switch31 == "transformTarget" -- 133
            if ____cond31 then -- 133
                cnode.transformTarget = v.current -- 134
                break -- 134
            end -- 134
            ____cond31 = ____cond31 or ____switch31 == "onUpdate" -- 134
            if ____cond31 then -- 134
                cnode:schedule(v) -- 135
                break -- 135
            end -- 135
            ____cond31 = ____cond31 or ____switch31 == "onActionEnd" -- 135
            if ____cond31 then -- 135
                cnode:slot("ActionEnd", v) -- 136
                break -- 136
            end -- 136
            ____cond31 = ____cond31 or ____switch31 == "onTapFilter" -- 136
            if ____cond31 then -- 136
                cnode:slot("TapFilter", v) -- 137
                break -- 137
            end -- 137
            ____cond31 = ____cond31 or ____switch31 == "onTapBegan" -- 137
            if ____cond31 then -- 137
                cnode:slot("TapBegan", v) -- 138
                break -- 138
            end -- 138
            ____cond31 = ____cond31 or ____switch31 == "onTapEnded" -- 138
            if ____cond31 then -- 138
                cnode:slot("TapEnded", v) -- 139
                break -- 139
            end -- 139
            ____cond31 = ____cond31 or ____switch31 == "onTapped" -- 139
            if ____cond31 then -- 139
                cnode:slot("Tapped", v) -- 140
                break -- 140
            end -- 140
            ____cond31 = ____cond31 or ____switch31 == "onTapMoved" -- 140
            if ____cond31 then -- 140
                cnode:slot("TapMoved", v) -- 141
                break -- 141
            end -- 141
            ____cond31 = ____cond31 or ____switch31 == "onMouseWheel" -- 141
            if ____cond31 then -- 141
                cnode:slot("MouseWheel", v) -- 142
                break -- 142
            end -- 142
            ____cond31 = ____cond31 or ____switch31 == "onGesture" -- 142
            if ____cond31 then -- 142
                cnode:slot("Gesture", v) -- 143
                break -- 143
            end -- 143
            ____cond31 = ____cond31 or ____switch31 == "onEnter" -- 143
            if ____cond31 then -- 143
                cnode:slot("Enter", v) -- 144
                break -- 144
            end -- 144
            ____cond31 = ____cond31 or ____switch31 == "onExit" -- 144
            if ____cond31 then -- 144
                cnode:slot("Exit", v) -- 145
                break -- 145
            end -- 145
            ____cond31 = ____cond31 or ____switch31 == "onCleanup" -- 145
            if ____cond31 then -- 145
                cnode:slot("Cleanup", v) -- 146
                break -- 146
            end -- 146
            ____cond31 = ____cond31 or ____switch31 == "onKeyDown" -- 146
            if ____cond31 then -- 146
                cnode:slot("KeyDown", v) -- 147
                break -- 147
            end -- 147
            ____cond31 = ____cond31 or ____switch31 == "onKeyUp" -- 147
            if ____cond31 then -- 147
                cnode:slot("KeyUp", v) -- 148
                break -- 148
            end -- 148
            ____cond31 = ____cond31 or ____switch31 == "onKeyPressed" -- 148
            if ____cond31 then -- 148
                cnode:slot("KeyPressed", v) -- 149
                break -- 149
            end -- 149
            ____cond31 = ____cond31 or ____switch31 == "onAttachIME" -- 149
            if ____cond31 then -- 149
                cnode:slot("AttachIME", v) -- 150
                break -- 150
            end -- 150
            ____cond31 = ____cond31 or ____switch31 == "onDetachIME" -- 150
            if ____cond31 then -- 150
                cnode:slot("DetachIME", v) -- 151
                break -- 151
            end -- 151
            ____cond31 = ____cond31 or ____switch31 == "onTextInput" -- 151
            if ____cond31 then -- 151
                cnode:slot("TextInput", v) -- 152
                break -- 152
            end -- 152
            ____cond31 = ____cond31 or ____switch31 == "onTextEditing" -- 152
            if ____cond31 then -- 152
                cnode:slot("TextEditing", v) -- 153
                break -- 153
            end -- 153
            ____cond31 = ____cond31 or ____switch31 == "onButtonDown" -- 153
            if ____cond31 then -- 153
                cnode:slot("ButtonDown", v) -- 154
                break -- 154
            end -- 154
            ____cond31 = ____cond31 or ____switch31 == "onButtonUp" -- 154
            if ____cond31 then -- 154
                cnode:slot("ButtonUp", v) -- 155
                break -- 155
            end -- 155
            ____cond31 = ____cond31 or ____switch31 == "onAxis" -- 155
            if ____cond31 then -- 155
                cnode:slot("Axis", v) -- 156
                break -- 156
            end -- 156
            do -- 156
                do -- 156
                    if attribHandler then -- 156
                        if not attribHandler(cnode, enode, k, v) then -- 156
                            cnode[k] = v -- 160
                        end -- 160
                    else -- 160
                        cnode[k] = v -- 163
                    end -- 163
                    break -- 165
                end -- 165
            end -- 165
        until true -- 165
    end -- 165
    if jnode.touchEnabled ~= false and (jnode.onTapFilter or jnode.onTapBegan or jnode.onTapMoved or jnode.onTapEnded or jnode.onTapped or jnode.onMouseWheel or jnode.onGesture) then -- 165
        cnode.touchEnabled = true -- 178
    end -- 178
    if jnode.keyboardEnabled ~= false and (jnode.onKeyDown or jnode.onKeyUp or jnode.onKeyPressed) then -- 178
        cnode.keyboardEnabled = true -- 185
    end -- 185
    if jnode.controllerEnabled ~= false and (jnode.onButtonDown or jnode.onButtonUp or jnode.onAxis) then -- 185
        cnode.controllerEnabled = true -- 192
    end -- 192
    if anchor ~= nil then -- 192
        cnode.anchor = anchor -- 194
    end -- 194
    if color3 ~= nil then -- 194
        cnode.color3 = color3 -- 195
    end -- 195
    if jnode.onMount ~= nil then -- 195
        jnode.onMount(cnode) -- 197
    end -- 197
    return cnode -- 199
end -- 123
local getClipNode -- 202
do -- 202
    local function handleClipNodeAttribute(cnode, _enode, k, v) -- 204
        repeat -- 204
            local ____switch44 = k -- 204
            local ____cond44 = ____switch44 == "stencil" -- 204
            if ____cond44 then -- 204
                cnode.stencil = ____exports.toNode(v) -- 211
                return true -- 211
            end -- 211
        until true -- 211
        return false -- 213
    end -- 204
    getClipNode = function(enode) -- 215
        return getNode( -- 216
            enode, -- 216
            Dora.ClipNode(), -- 216
            handleClipNodeAttribute -- 216
        ) -- 216
    end -- 215
end -- 215
local getPlayable -- 220
local getDragonBone -- 221
local getSpine -- 222
local getModel -- 223
do -- 223
    local function handlePlayableAttribute(cnode, enode, k, v) -- 225
        repeat -- 225
            local ____switch48 = k -- 225
            local ____cond48 = ____switch48 == "file" -- 225
            if ____cond48 then -- 225
                return true -- 227
            end -- 227
            ____cond48 = ____cond48 or ____switch48 == "play" -- 227
            if ____cond48 then -- 227
                cnode:play(v, enode.props.loop == true) -- 228
                return true -- 228
            end -- 228
            ____cond48 = ____cond48 or ____switch48 == "loop" -- 228
            if ____cond48 then -- 228
                return true -- 229
            end -- 229
            ____cond48 = ____cond48 or ____switch48 == "onAnimationEnd" -- 229
            if ____cond48 then -- 229
                cnode:slot("AnimationEnd", v) -- 230
                return true -- 230
            end -- 230
        until true -- 230
        return false -- 232
    end -- 225
    getPlayable = function(enode, cnode, attribHandler) -- 234
        if attribHandler == nil then -- 234
            attribHandler = handlePlayableAttribute -- 235
        end -- 235
        cnode = cnode or Dora.Playable(enode.props.file) or nil -- 236
        if cnode ~= nil then -- 236
            return getNode(enode, cnode, attribHandler) -- 238
        end -- 238
        return nil -- 240
    end -- 234
    local function handleDragonBoneAttribute(cnode, enode, k, v) -- 243
        repeat -- 243
            local ____switch52 = k -- 243
            local ____cond52 = ____switch52 == "hitTestEnabled" -- 243
            if ____cond52 then -- 243
                cnode.hitTestEnabled = true -- 245
                return true -- 245
            end -- 245
        until true -- 245
        return handlePlayableAttribute(cnode, enode, k, v) -- 247
    end -- 243
    getDragonBone = function(enode) -- 249
        local node = Dora.DragonBone(enode.props.file) -- 250
        if node ~= nil then -- 250
            local cnode = getPlayable(enode, node, handleDragonBoneAttribute) -- 252
            return cnode -- 253
        end -- 253
        return nil -- 255
    end -- 249
    local function handleSpineAttribute(cnode, enode, k, v) -- 258
        repeat -- 258
            local ____switch56 = k -- 258
            local ____cond56 = ____switch56 == "hitTestEnabled" -- 258
            if ____cond56 then -- 258
                cnode.hitTestEnabled = true -- 260
                return true -- 260
            end -- 260
        until true -- 260
        return handlePlayableAttribute(cnode, enode, k, v) -- 262
    end -- 258
    getSpine = function(enode) -- 264
        local node = Dora.Spine(enode.props.file) -- 265
        if node ~= nil then -- 265
            local cnode = getPlayable(enode, node, handleSpineAttribute) -- 267
            return cnode -- 268
        end -- 268
        return nil -- 270
    end -- 264
    local function handleModelAttribute(cnode, enode, k, v) -- 273
        repeat -- 273
            local ____switch60 = k -- 273
            local ____cond60 = ____switch60 == "reversed" -- 273
            if ____cond60 then -- 273
                cnode.reversed = v -- 275
                return true -- 275
            end -- 275
        until true -- 275
        return handlePlayableAttribute(cnode, enode, k, v) -- 277
    end -- 273
    getModel = function(enode) -- 279
        local node = Dora.Model(enode.props.file) -- 280
        if node ~= nil then -- 280
            local cnode = getPlayable(enode, node, handleModelAttribute) -- 282
            return cnode -- 283
        end -- 283
        return nil -- 285
    end -- 279
end -- 279
local getDrawNode -- 289
do -- 289
    local function handleDrawNodeAttribute(cnode, _enode, k, v) -- 291
        repeat -- 291
            local ____switch65 = k -- 291
            local ____cond65 = ____switch65 == "depthWrite" -- 291
            if ____cond65 then -- 291
                cnode.depthWrite = v -- 293
                return true -- 293
            end -- 293
            ____cond65 = ____cond65 or ____switch65 == "blendFunc" -- 293
            if ____cond65 then -- 293
                cnode.blendFunc = v -- 294
                return true -- 294
            end -- 294
        until true -- 294
        return false -- 296
    end -- 291
    getDrawNode = function(enode) -- 298
        local node = Dora.DrawNode() -- 299
        local cnode = getNode(enode, node, handleDrawNodeAttribute) -- 300
        local ____enode_7 = enode -- 301
        local children = ____enode_7.children -- 301
        for i = 1, #children do -- 301
            do -- 301
                local child = children[i] -- 303
                if type(child) ~= "table" then -- 303
                    goto __continue67 -- 305
                end -- 305
                repeat -- 305
                    local ____switch69 = child.type -- 305
                    local ____cond69 = ____switch69 == "dot-shape" -- 305
                    if ____cond69 then -- 305
                        do -- 305
                            local dot = child.props -- 309
                            node:drawDot( -- 310
                                Dora.Vec2(dot.x or 0, dot.y or 0), -- 311
                                dot.radius, -- 312
                                Dora.Color(dot.color or 4294967295) -- 313
                            ) -- 313
                            break -- 315
                        end -- 315
                    end -- 315
                    ____cond69 = ____cond69 or ____switch69 == "segment-shape" -- 315
                    if ____cond69 then -- 315
                        do -- 315
                            local segment = child.props -- 318
                            node:drawSegment( -- 319
                                Dora.Vec2(segment.startX, segment.startY), -- 320
                                Dora.Vec2(segment.stopX, segment.stopY), -- 321
                                segment.radius, -- 322
                                Dora.Color(segment.color or 4294967295) -- 323
                            ) -- 323
                            break -- 325
                        end -- 325
                    end -- 325
                    ____cond69 = ____cond69 or ____switch69 == "rect-shape" -- 325
                    if ____cond69 then -- 325
                        do -- 325
                            local rect = child.props -- 328
                            local centerX = rect.centerX or 0 -- 329
                            local centerY = rect.centerY or 0 -- 330
                            local hw = rect.width / 2 -- 331
                            local hh = rect.height / 2 -- 332
                            node:drawPolygon( -- 333
                                { -- 334
                                    Dora.Vec2(centerX - hw, centerY + hh), -- 335
                                    Dora.Vec2(centerX + hw, centerY + hh), -- 336
                                    Dora.Vec2(centerX + hw, centerY - hh), -- 337
                                    Dora.Vec2(centerX - hw, centerY - hh) -- 338
                                }, -- 338
                                Dora.Color(rect.fillColor or 4294967295), -- 340
                                rect.borderWidth or 0, -- 341
                                Dora.Color(rect.borderColor or 4294967295) -- 342
                            ) -- 342
                            break -- 344
                        end -- 344
                    end -- 344
                    ____cond69 = ____cond69 or ____switch69 == "polygon-shape" -- 344
                    if ____cond69 then -- 344
                        do -- 344
                            local poly = child.props -- 347
                            node:drawPolygon( -- 348
                                poly.verts, -- 349
                                Dora.Color(poly.fillColor or 4294967295), -- 350
                                poly.borderWidth or 0, -- 351
                                Dora.Color(poly.borderColor or 4294967295) -- 352
                            ) -- 352
                            break -- 354
                        end -- 354
                    end -- 354
                    ____cond69 = ____cond69 or ____switch69 == "verts-shape" -- 354
                    if ____cond69 then -- 354
                        do -- 354
                            local verts = child.props -- 357
                            node:drawVertices(__TS__ArrayMap( -- 358
                                verts.verts, -- 358
                                function(____, ____bindingPattern0) -- 358
                                    local color -- 358
                                    local vert -- 358
                                    vert = ____bindingPattern0[1] -- 358
                                    color = ____bindingPattern0[2] -- 358
                                    return { -- 358
                                        vert, -- 358
                                        Dora.Color(color) -- 358
                                    } -- 358
                                end -- 358
                            )) -- 358
                            break -- 359
                        end -- 359
                    end -- 359
                until true -- 359
            end -- 359
            ::__continue67:: -- 359
        end -- 359
        return cnode -- 363
    end -- 298
end -- 298
local getGrid -- 367
do -- 367
    local function handleGridAttribute(cnode, _enode, k, v) -- 369
        repeat -- 369
            local ____switch78 = k -- 369
            local ____cond78 = ____switch78 == "file" or ____switch78 == "gridX" or ____switch78 == "gridY" -- 369
            if ____cond78 then -- 369
                return true -- 371
            end -- 371
            ____cond78 = ____cond78 or ____switch78 == "textureRect" -- 371
            if ____cond78 then -- 371
                cnode.textureRect = v -- 372
                return true -- 372
            end -- 372
            ____cond78 = ____cond78 or ____switch78 == "depthWrite" -- 372
            if ____cond78 then -- 372
                cnode.depthWrite = v -- 373
                return true -- 373
            end -- 373
            ____cond78 = ____cond78 or ____switch78 == "blendFunc" -- 373
            if ____cond78 then -- 373
                cnode.blendFunc = v -- 374
                return true -- 374
            end -- 374
            ____cond78 = ____cond78 or ____switch78 == "effect" -- 374
            if ____cond78 then -- 374
                cnode.effect = v -- 375
                return true -- 375
            end -- 375
        until true -- 375
        return false -- 377
    end -- 369
    getGrid = function(enode) -- 379
        local grid = enode.props -- 380
        local node = Dora.Grid(grid.file, grid.gridX, grid.gridY) -- 381
        local cnode = getNode(enode, node, handleGridAttribute) -- 382
        return cnode -- 383
    end -- 379
end -- 379
local getSprite -- 387
do -- 387
    local function handleSpriteAttribute(cnode, _enode, k, v) -- 389
        repeat -- 389
            local ____switch82 = k -- 389
            local ____cond82 = ____switch82 == "file" -- 389
            if ____cond82 then -- 389
                return true -- 391
            end -- 391
            ____cond82 = ____cond82 or ____switch82 == "textureRect" -- 391
            if ____cond82 then -- 391
                cnode.textureRect = v -- 392
                return true -- 392
            end -- 392
            ____cond82 = ____cond82 or ____switch82 == "depthWrite" -- 392
            if ____cond82 then -- 392
                cnode.depthWrite = v -- 393
                return true -- 393
            end -- 393
            ____cond82 = ____cond82 or ____switch82 == "blendFunc" -- 393
            if ____cond82 then -- 393
                cnode.blendFunc = v -- 394
                return true -- 394
            end -- 394
            ____cond82 = ____cond82 or ____switch82 == "effect" -- 394
            if ____cond82 then -- 394
                cnode.effect = v -- 395
                return true -- 395
            end -- 395
            ____cond82 = ____cond82 or ____switch82 == "alphaRef" -- 395
            if ____cond82 then -- 395
                cnode.alphaRef = v -- 396
                return true -- 396
            end -- 396
            ____cond82 = ____cond82 or ____switch82 == "uwrap" -- 396
            if ____cond82 then -- 396
                cnode.uwrap = v -- 397
                return true -- 397
            end -- 397
            ____cond82 = ____cond82 or ____switch82 == "vwrap" -- 397
            if ____cond82 then -- 397
                cnode.vwrap = v -- 398
                return true -- 398
            end -- 398
            ____cond82 = ____cond82 or ____switch82 == "filter" -- 398
            if ____cond82 then -- 398
                cnode.filter = v -- 399
                return true -- 399
            end -- 399
        until true -- 399
        return false -- 401
    end -- 389
    getSprite = function(enode) -- 403
        local sp = enode.props -- 404
        local node = Dora.Sprite(sp.file) -- 405
        if node ~= nil then -- 405
            local cnode = getNode(enode, node, handleSpriteAttribute) -- 407
            return cnode -- 408
        end -- 408
        return nil -- 410
    end -- 403
end -- 403
local getLabel -- 414
do -- 414
    local function handleLabelAttribute(cnode, _enode, k, v) -- 416
        repeat -- 416
            local ____switch87 = k -- 416
            local ____cond87 = ____switch87 == "fontName" or ____switch87 == "fontSize" or ____switch87 == "text" -- 416
            if ____cond87 then -- 416
                return true -- 418
            end -- 418
            ____cond87 = ____cond87 or ____switch87 == "alphaRef" -- 418
            if ____cond87 then -- 418
                cnode.alphaRef = v -- 419
                return true -- 419
            end -- 419
            ____cond87 = ____cond87 or ____switch87 == "textWidth" -- 419
            if ____cond87 then -- 419
                cnode.textWidth = v -- 420
                return true -- 420
            end -- 420
            ____cond87 = ____cond87 or ____switch87 == "lineGap" -- 420
            if ____cond87 then -- 420
                cnode.lineGap = v -- 421
                return true -- 421
            end -- 421
            ____cond87 = ____cond87 or ____switch87 == "spacing" -- 421
            if ____cond87 then -- 421
                cnode.spacing = v -- 422
                return true -- 422
            end -- 422
            ____cond87 = ____cond87 or ____switch87 == "blendFunc" -- 422
            if ____cond87 then -- 422
                cnode.blendFunc = v -- 423
                return true -- 423
            end -- 423
            ____cond87 = ____cond87 or ____switch87 == "depthWrite" -- 423
            if ____cond87 then -- 423
                cnode.depthWrite = v -- 424
                return true -- 424
            end -- 424
            ____cond87 = ____cond87 or ____switch87 == "batched" -- 424
            if ____cond87 then -- 424
                cnode.batched = v -- 425
                return true -- 425
            end -- 425
            ____cond87 = ____cond87 or ____switch87 == "effect" -- 425
            if ____cond87 then -- 425
                cnode.effect = v -- 426
                return true -- 426
            end -- 426
            ____cond87 = ____cond87 or ____switch87 == "alignment" -- 426
            if ____cond87 then -- 426
                cnode.alignment = v -- 427
                return true -- 427
            end -- 427
        until true -- 427
        return false -- 429
    end -- 416
    getLabel = function(enode) -- 431
        local label = enode.props -- 432
        local node = Dora.Label(label.fontName, label.fontSize) -- 433
        if node ~= nil then -- 433
            local cnode = getNode(enode, node, handleLabelAttribute) -- 435
            local ____enode_8 = enode -- 436
            local children = ____enode_8.children -- 436
            local text = label.text or "" -- 437
            for i = 1, #children do -- 437
                local child = children[i] -- 439
                if type(child) ~= "table" then -- 439
                    text = text .. tostring(child) -- 441
                end -- 441
            end -- 441
            node.text = text -- 444
            return cnode -- 445
        end -- 445
        return nil -- 447
    end -- 431
end -- 431
local getLine -- 451
do -- 451
    local function handleLineAttribute(cnode, enode, k, v) -- 453
        local line = enode.props -- 454
        repeat -- 454
            local ____switch94 = k -- 454
            local ____cond94 = ____switch94 == "verts" -- 454
            if ____cond94 then -- 454
                cnode:set( -- 456
                    v, -- 456
                    Dora.Color(line.lineColor or 4294967295) -- 456
                ) -- 456
                return true -- 456
            end -- 456
            ____cond94 = ____cond94 or ____switch94 == "depthWrite" -- 456
            if ____cond94 then -- 456
                cnode.depthWrite = v -- 457
                return true -- 457
            end -- 457
            ____cond94 = ____cond94 or ____switch94 == "blendFunc" -- 457
            if ____cond94 then -- 457
                cnode.blendFunc = v -- 458
                return true -- 458
            end -- 458
        until true -- 458
        return false -- 460
    end -- 453
    getLine = function(enode) -- 462
        local node = Dora.Line() -- 463
        local cnode = getNode(enode, node, handleLineAttribute) -- 464
        return cnode -- 465
    end -- 462
end -- 462
local getParticle -- 469
do -- 469
    local function handleParticleAttribute(cnode, _enode, k, v) -- 471
        repeat -- 471
            local ____switch98 = k -- 471
            local ____cond98 = ____switch98 == "file" -- 471
            if ____cond98 then -- 471
                return true -- 473
            end -- 473
            ____cond98 = ____cond98 or ____switch98 == "emit" -- 473
            if ____cond98 then -- 473
                if v then -- 473
                    cnode:start() -- 474
                end -- 474
                return true -- 474
            end -- 474
            ____cond98 = ____cond98 or ____switch98 == "onFinished" -- 474
            if ____cond98 then -- 474
                cnode:slot("Finished", v) -- 475
                return true -- 475
            end -- 475
        until true -- 475
        return false -- 477
    end -- 471
    getParticle = function(enode) -- 479
        local particle = enode.props -- 480
        local node = Dora.Particle(particle.file) -- 481
        if node ~= nil then -- 481
            local cnode = getNode(enode, node, handleParticleAttribute) -- 483
            return cnode -- 484
        end -- 484
        return nil -- 486
    end -- 479
end -- 479
local getMenu -- 490
do -- 490
    local function handleMenuAttribute(cnode, _enode, k, v) -- 492
        repeat -- 492
            local ____switch104 = k -- 492
            local ____cond104 = ____switch104 == "enabled" -- 492
            if ____cond104 then -- 492
                cnode.enabled = v -- 494
                return true -- 494
            end -- 494
        until true -- 494
        return false -- 496
    end -- 492
    getMenu = function(enode) -- 498
        local node = Dora.Menu() -- 499
        local cnode = getNode(enode, node, handleMenuAttribute) -- 500
        return cnode -- 501
    end -- 498
end -- 498
local function getPhysicsWorld(enode) -- 505
    local node = Dora.PhysicsWorld() -- 506
    local cnode = getNode(enode, node) -- 507
    return cnode -- 508
end -- 505
local getBody -- 511
do -- 511
    local function handleBodyAttribute(cnode, _enode, k, v) -- 513
        repeat -- 513
            local ____switch109 = k -- 513
            local ____cond109 = ____switch109 == "type" or ____switch109 == "linearAcceleration" or ____switch109 == "fixedRotation" or ____switch109 == "bullet" or ____switch109 == "world" -- 513
            if ____cond109 then -- 513
                return true -- 520
            end -- 520
            ____cond109 = ____cond109 or ____switch109 == "velocityX" -- 520
            if ____cond109 then -- 520
                cnode.velocityX = v -- 521
                return true -- 521
            end -- 521
            ____cond109 = ____cond109 or ____switch109 == "velocityY" -- 521
            if ____cond109 then -- 521
                cnode.velocityY = v -- 522
                return true -- 522
            end -- 522
            ____cond109 = ____cond109 or ____switch109 == "angularRate" -- 522
            if ____cond109 then -- 522
                cnode.angularRate = v -- 523
                return true -- 523
            end -- 523
            ____cond109 = ____cond109 or ____switch109 == "group" -- 523
            if ____cond109 then -- 523
                cnode.group = v -- 524
                return true -- 524
            end -- 524
            ____cond109 = ____cond109 or ____switch109 == "linearDamping" -- 524
            if ____cond109 then -- 524
                cnode.linearDamping = v -- 525
                return true -- 525
            end -- 525
            ____cond109 = ____cond109 or ____switch109 == "angularDamping" -- 525
            if ____cond109 then -- 525
                cnode.angularDamping = v -- 526
                return true -- 526
            end -- 526
            ____cond109 = ____cond109 or ____switch109 == "owner" -- 526
            if ____cond109 then -- 526
                cnode.owner = v -- 527
                return true -- 527
            end -- 527
            ____cond109 = ____cond109 or ____switch109 == "receivingContact" -- 527
            if ____cond109 then -- 527
                cnode.receivingContact = v -- 528
                return true -- 528
            end -- 528
            ____cond109 = ____cond109 or ____switch109 == "onBodyEnter" -- 528
            if ____cond109 then -- 528
                cnode:slot("BodyEnter", v) -- 529
                return true -- 529
            end -- 529
            ____cond109 = ____cond109 or ____switch109 == "onBodyLeave" -- 529
            if ____cond109 then -- 529
                cnode:slot("BodyLeave", v) -- 530
                return true -- 530
            end -- 530
            ____cond109 = ____cond109 or ____switch109 == "onContactStart" -- 530
            if ____cond109 then -- 530
                cnode:slot("ContactStart", v) -- 531
                return true -- 531
            end -- 531
            ____cond109 = ____cond109 or ____switch109 == "onContactEnd" -- 531
            if ____cond109 then -- 531
                cnode:slot("ContactEnd", v) -- 532
                return true -- 532
            end -- 532
            ____cond109 = ____cond109 or ____switch109 == "onContactFilter" -- 532
            if ____cond109 then -- 532
                cnode:onContactFilter(v) -- 533
                return true -- 533
            end -- 533
        until true -- 533
        return false -- 535
    end -- 513
    getBody = function(enode, world) -- 537
        local def = enode.props -- 538
        local bodyDef = Dora.BodyDef() -- 539
        bodyDef.type = def.type -- 540
        if def.angle ~= nil then -- 540
            bodyDef.angle = def.angle -- 541
        end -- 541
        if def.angularDamping ~= nil then -- 541
            bodyDef.angularDamping = def.angularDamping -- 542
        end -- 542
        if def.bullet ~= nil then -- 542
            bodyDef.bullet = def.bullet -- 543
        end -- 543
        if def.fixedRotation ~= nil then -- 543
            bodyDef.fixedRotation = def.fixedRotation -- 544
        end -- 544
        bodyDef.linearAcceleration = def.linearAcceleration or Dora.Vec2(0, -9.8) -- 545
        if def.linearDamping ~= nil then -- 545
            bodyDef.linearDamping = def.linearDamping -- 546
        end -- 546
        bodyDef.position = Dora.Vec2(def.x or 0, def.y or 0) -- 547
        local extraSensors = nil -- 548
        for i = 1, #enode.children do -- 548
            do -- 548
                local child = enode.children[i] -- 550
                if type(child) ~= "table" then -- 550
                    goto __continue116 -- 552
                end -- 552
                repeat -- 552
                    local ____switch118 = child.type -- 552
                    local ____cond118 = ____switch118 == "rect-fixture" -- 552
                    if ____cond118 then -- 552
                        do -- 552
                            local shape = child.props -- 556
                            if shape.sensorTag ~= nil then -- 556
                                bodyDef:attachPolygonSensor( -- 558
                                    shape.sensorTag, -- 559
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 560
                                    shape.width, -- 561
                                    shape.height, -- 561
                                    shape.angle or 0 -- 562
                                ) -- 562
                            else -- 562
                                bodyDef:attachPolygon( -- 565
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 566
                                    shape.width, -- 567
                                    shape.height, -- 567
                                    shape.angle or 0, -- 568
                                    shape.density or 1, -- 569
                                    shape.friction or 0.4, -- 570
                                    shape.restitution or 0 -- 571
                                ) -- 571
                            end -- 571
                            break -- 574
                        end -- 574
                    end -- 574
                    ____cond118 = ____cond118 or ____switch118 == "polygon-fixture" -- 574
                    if ____cond118 then -- 574
                        do -- 574
                            local shape = child.props -- 577
                            if shape.sensorTag ~= nil then -- 577
                                bodyDef:attachPolygonSensor(shape.sensorTag, shape.verts) -- 579
                            else -- 579
                                bodyDef:attachPolygon(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 584
                            end -- 584
                            break -- 591
                        end -- 591
                    end -- 591
                    ____cond118 = ____cond118 or ____switch118 == "multi-fixture" -- 591
                    if ____cond118 then -- 591
                        do -- 591
                            local shape = child.props -- 594
                            if shape.sensorTag ~= nil then -- 594
                                if extraSensors == nil then -- 594
                                    extraSensors = {} -- 596
                                end -- 596
                                extraSensors[#extraSensors + 1] = { -- 597
                                    shape.sensorTag, -- 597
                                    Dora.BodyDef:multi(shape.verts) -- 597
                                } -- 597
                            else -- 597
                                bodyDef:attachMulti(shape.verts, shape.density or 1, shape.friction or 0.4, shape.restitution or 0) -- 599
                            end -- 599
                            break -- 606
                        end -- 606
                    end -- 606
                    ____cond118 = ____cond118 or ____switch118 == "disk-fixture" -- 606
                    if ____cond118 then -- 606
                        do -- 606
                            local shape = child.props -- 609
                            if shape.sensorTag ~= nil then -- 609
                                bodyDef:attachDiskSensor( -- 611
                                    shape.sensorTag, -- 612
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 613
                                    shape.radius -- 614
                                ) -- 614
                            else -- 614
                                bodyDef:attachDisk( -- 617
                                    Dora.Vec2(shape.centerX or 0, shape.centerY or 0), -- 618
                                    shape.radius, -- 619
                                    shape.density or 1, -- 620
                                    shape.friction or 0.4, -- 621
                                    shape.restitution or 0 -- 622
                                ) -- 622
                            end -- 622
                            break -- 625
                        end -- 625
                    end -- 625
                    ____cond118 = ____cond118 or ____switch118 == "chain-fixture" -- 625
                    if ____cond118 then -- 625
                        do -- 625
                            local shape = child.props -- 628
                            if shape.sensorTag ~= nil then -- 628
                                if extraSensors == nil then -- 628
                                    extraSensors = {} -- 630
                                end -- 630
                                extraSensors[#extraSensors + 1] = { -- 631
                                    shape.sensorTag, -- 631
                                    Dora.BodyDef:chain(shape.verts) -- 631
                                } -- 631
                            else -- 631
                                bodyDef:attachChain(shape.verts, shape.friction or 0.4, shape.restitution or 0) -- 633
                            end -- 633
                            break -- 639
                        end -- 639
                    end -- 639
                until true -- 639
            end -- 639
            ::__continue116:: -- 639
        end -- 639
        local body = Dora.Body(bodyDef, world) -- 643
        if extraSensors ~= nil then -- 643
            for i = 1, #extraSensors do -- 643
                local tag, def = table.unpack(extraSensors[i]) -- 646
                body:attachSensor(tag, def) -- 647
            end -- 647
        end -- 647
        local cnode = getNode(enode, body, handleBodyAttribute) -- 650
        if def.receivingContact ~= false and (def.onContactStart or def.onContactEnd) then -- 650
            body.receivingContact = true -- 655
        end -- 655
        return cnode -- 657
    end -- 537
end -- 537
local getCustomNode -- 661
do -- 661
    local function handleCustomNode(_cnode, _enode, k, _v) -- 663
        repeat -- 663
            local ____switch139 = k -- 663
            local ____cond139 = ____switch139 == "onCreate" -- 663
            if ____cond139 then -- 663
                return true -- 665
            end -- 665
        until true -- 665
        return false -- 667
    end -- 663
    getCustomNode = function(enode) -- 669
        local custom = enode.props -- 670
        local node = custom.onCreate() -- 671
        if node then -- 671
            local cnode = getNode(enode, node, handleCustomNode) -- 673
            return cnode -- 674
        end -- 674
        return nil -- 676
    end -- 669
end -- 669
local getAlignNode -- 680
do -- 680
    local function handleAlignNode(_cnode, _enode, k, _v) -- 682
        repeat -- 682
            local ____switch144 = k -- 682
            local ____cond144 = ____switch144 == "windowRoot" -- 682
            if ____cond144 then -- 682
                return true -- 684
            end -- 684
            ____cond144 = ____cond144 or ____switch144 == "style" -- 684
            if ____cond144 then -- 684
                return true -- 685
            end -- 685
            ____cond144 = ____cond144 or ____switch144 == "onLayout" -- 685
            if ____cond144 then -- 685
                return true -- 686
            end -- 686
        until true -- 686
        return false -- 688
    end -- 682
    getAlignNode = function(enode) -- 690
        local alignNode = enode.props -- 691
        local node = Dora.AlignNode(alignNode.windowRoot) -- 692
        if alignNode.style then -- 692
            local items = {} -- 694
            for k, v in pairs(alignNode.style) do -- 695
                local name = string.gsub(k, "%u", "-%1") -- 696
                name = string.lower(name) -- 697
                repeat -- 697
                    local ____switch148 = k -- 697
                    local ____cond148 = ____switch148 == "margin" or ____switch148 == "padding" or ____switch148 == "border" or ____switch148 == "gap" -- 697
                    if ____cond148 then -- 697
                        do -- 697
                            if type(v) == "table" then -- 697
                                local valueStr = table.concat( -- 702
                                    __TS__ArrayMap( -- 702
                                        v, -- 702
                                        function(____, item) return tostring(item) end -- 702
                                    ), -- 702
                                    "," -- 702
                                ) -- 702
                                items[#items + 1] = (name .. ":") .. valueStr -- 703
                            else -- 703
                                items[#items + 1] = (name .. ":") .. tostring(v) -- 705
                            end -- 705
                            break -- 707
                        end -- 707
                    end -- 707
                    do -- 707
                        items[#items + 1] = (name .. ":") .. tostring(v) -- 710
                        break -- 711
                    end -- 711
                until true -- 711
            end -- 711
            local styleStr = table.concat(items, ";") -- 714
            node:css(styleStr) -- 715
        end -- 715
        if alignNode.onLayout then -- 715
            node:slot("AlignLayout", alignNode.onLayout) -- 718
        end -- 718
        local cnode = getNode(enode, node, handleAlignNode) -- 720
        return cnode -- 721
    end -- 690
end -- 690
local function getEffekNode(enode) -- 725
    return getNode( -- 726
        enode, -- 726
        Dora.EffekNode() -- 726
    ) -- 726
end -- 725
local getTileNode -- 729
do -- 729
    local function handleTileNodeAttribute(cnode, _enode, k, v) -- 731
        repeat -- 731
            local ____switch157 = k -- 731
            local ____cond157 = ____switch157 == "file" or ____switch157 == "layers" -- 731
            if ____cond157 then -- 731
                return true -- 733
            end -- 733
            ____cond157 = ____cond157 or ____switch157 == "depthWrite" -- 733
            if ____cond157 then -- 733
                cnode.depthWrite = v -- 734
                return true -- 734
            end -- 734
            ____cond157 = ____cond157 or ____switch157 == "blendFunc" -- 734
            if ____cond157 then -- 734
                cnode.blendFunc = v -- 735
                return true -- 735
            end -- 735
            ____cond157 = ____cond157 or ____switch157 == "effect" -- 735
            if ____cond157 then -- 735
                cnode.effect = v -- 736
                return true -- 736
            end -- 736
            ____cond157 = ____cond157 or ____switch157 == "filter" -- 736
            if ____cond157 then -- 736
                cnode.filter = v -- 737
                return true -- 737
            end -- 737
        until true -- 737
        return false -- 739
    end -- 731
    getTileNode = function(enode) -- 741
        local tn = enode.props -- 742
        local ____tn_layers_9 -- 743
        if tn.layers then -- 743
            ____tn_layers_9 = Dora.TileNode(tn.file, tn.layers) -- 743
        else -- 743
            ____tn_layers_9 = Dora.TileNode(tn.file) -- 743
        end -- 743
        local node = ____tn_layers_9 -- 743
        if node ~= nil then -- 743
            local cnode = getNode(enode, node, handleTileNodeAttribute) -- 745
            return cnode -- 746
        end -- 746
        return nil -- 748
    end -- 741
end -- 741
local function addChild(nodeStack, cnode, enode) -- 752
    if #nodeStack > 0 then -- 752
        local last = nodeStack[#nodeStack] -- 754
        last:addChild(cnode) -- 755
    end -- 755
    nodeStack[#nodeStack + 1] = cnode -- 757
    local ____enode_10 = enode -- 758
    local children = ____enode_10.children -- 758
    for i = 1, #children do -- 758
        visitNode(nodeStack, children[i], enode) -- 760
    end -- 760
    if #nodeStack > 1 then -- 760
        table.remove(nodeStack) -- 763
    end -- 763
end -- 752
local function drawNodeCheck(_nodeStack, enode, parent) -- 771
    if parent == nil or parent.type ~= "draw-node" then -- 771
        Warn(("tag <" .. enode.type) .. "> must be placed under a <draw-node> to take effect") -- 773
    end -- 773
end -- 771
local function visitAction(actionStack, enode) -- 777
    local createAction = actionMap[enode.type] -- 778
    if createAction ~= nil then -- 778
        actionStack[#actionStack + 1] = createAction(enode.props.time, enode.props.start, enode.props.stop, enode.props.easing) -- 780
        return -- 781
    end -- 781
    repeat -- 781
        local ____switch168 = enode.type -- 781
        local ____cond168 = ____switch168 == "delay" -- 781
        if ____cond168 then -- 781
            do -- 781
                local item = enode.props -- 785
                actionStack[#actionStack + 1] = Dora.Delay(item.time) -- 786
                break -- 787
            end -- 787
        end -- 787
        ____cond168 = ____cond168 or ____switch168 == "event" -- 787
        if ____cond168 then -- 787
            do -- 787
                local item = enode.props -- 790
                actionStack[#actionStack + 1] = Dora.Event(item.name, item.param) -- 791
                break -- 792
            end -- 792
        end -- 792
        ____cond168 = ____cond168 or ____switch168 == "hide" -- 792
        if ____cond168 then -- 792
            do -- 792
                actionStack[#actionStack + 1] = Dora.Hide() -- 795
                break -- 796
            end -- 796
        end -- 796
        ____cond168 = ____cond168 or ____switch168 == "show" -- 796
        if ____cond168 then -- 796
            do -- 796
                actionStack[#actionStack + 1] = Dora.Show() -- 799
                break -- 800
            end -- 800
        end -- 800
        ____cond168 = ____cond168 or ____switch168 == "move" -- 800
        if ____cond168 then -- 800
            do -- 800
                local item = enode.props -- 803
                actionStack[#actionStack + 1] = Dora.Move( -- 804
                    item.time, -- 804
                    Dora.Vec2(item.startX, item.startY), -- 804
                    Dora.Vec2(item.stopX, item.stopY), -- 804
                    item.easing -- 804
                ) -- 804
                break -- 805
            end -- 805
        end -- 805
        ____cond168 = ____cond168 or ____switch168 == "spawn" -- 805
        if ____cond168 then -- 805
            do -- 805
                local spawnStack = {} -- 808
                for i = 1, #enode.children do -- 808
                    visitAction(spawnStack, enode.children[i]) -- 810
                end -- 810
                actionStack[#actionStack + 1] = Dora.Spawn(table.unpack(spawnStack)) -- 812
                break -- 813
            end -- 813
        end -- 813
        ____cond168 = ____cond168 or ____switch168 == "sequence" -- 813
        if ____cond168 then -- 813
            do -- 813
                local sequenceStack = {} -- 816
                for i = 1, #enode.children do -- 816
                    visitAction(sequenceStack, enode.children[i]) -- 818
                end -- 818
                actionStack[#actionStack + 1] = Dora.Sequence(table.unpack(sequenceStack)) -- 820
                break -- 821
            end -- 821
        end -- 821
        do -- 821
            Warn(("unsupported tag <" .. enode.type) .. "> under action definition") -- 824
            break -- 825
        end -- 825
    until true -- 825
end -- 777
local function actionCheck(nodeStack, enode, parent) -- 829
    local unsupported = false -- 830
    if parent == nil then -- 830
        unsupported = true -- 832
    else -- 832
        repeat -- 832
            local ____switch181 = parent.type -- 832
            local ____cond181 = ____switch181 == "action" or ____switch181 == "spawn" or ____switch181 == "sequence" -- 832
            if ____cond181 then -- 832
                break -- 835
            end -- 835
            do -- 835
                unsupported = true -- 836
                break -- 836
            end -- 836
        until true -- 836
    end -- 836
    if unsupported then -- 836
        if #nodeStack > 0 then -- 836
            local node = nodeStack[#nodeStack] -- 841
            local actionStack = {} -- 842
            visitAction(actionStack, enode) -- 843
            if #actionStack == 1 then -- 843
                node:runAction(actionStack[1]) -- 845
            end -- 845
        else -- 845
            Warn(("tag <" .. enode.type) .. "> must be placed under <action>, <spawn>, <sequence> or other scene node to take effect") -- 848
        end -- 848
    end -- 848
end -- 829
local function bodyCheck(_nodeStack, enode, parent) -- 853
    if parent == nil or parent.type ~= "body" then -- 853
        Warn(("tag <" .. enode.type) .. "> must be placed under a <body> to take effect") -- 855
    end -- 855
end -- 853
actionMap = { -- 859
    ["anchor-x"] = Dora.AnchorX, -- 862
    ["anchor-y"] = Dora.AnchorY, -- 863
    angle = Dora.Angle, -- 864
    ["angle-x"] = Dora.AngleX, -- 865
    ["angle-y"] = Dora.AngleY, -- 866
    width = Dora.Width, -- 867
    height = Dora.Height, -- 868
    opacity = Dora.Opacity, -- 869
    roll = Dora.Roll, -- 870
    scale = Dora.Scale, -- 871
    ["scale-x"] = Dora.ScaleX, -- 872
    ["scale-y"] = Dora.ScaleY, -- 873
    ["skew-x"] = Dora.SkewX, -- 874
    ["skew-y"] = Dora.SkewY, -- 875
    ["move-x"] = Dora.X, -- 876
    ["move-y"] = Dora.Y, -- 877
    ["move-z"] = Dora.Z -- 878
} -- 878
elementMap = { -- 881
    node = function(nodeStack, enode, parent) -- 882
        addChild( -- 883
            nodeStack, -- 883
            getNode(enode), -- 883
            enode -- 883
        ) -- 883
    end, -- 882
    ["clip-node"] = function(nodeStack, enode, parent) -- 885
        addChild( -- 886
            nodeStack, -- 886
            getClipNode(enode), -- 886
            enode -- 886
        ) -- 886
    end, -- 885
    playable = function(nodeStack, enode, parent) -- 888
        local cnode = getPlayable(enode) -- 889
        if cnode ~= nil then -- 889
            addChild(nodeStack, cnode, enode) -- 891
        end -- 891
    end, -- 888
    ["dragon-bone"] = function(nodeStack, enode, parent) -- 894
        local cnode = getDragonBone(enode) -- 895
        if cnode ~= nil then -- 895
            addChild(nodeStack, cnode, enode) -- 897
        end -- 897
    end, -- 894
    spine = function(nodeStack, enode, parent) -- 900
        local cnode = getSpine(enode) -- 901
        if cnode ~= nil then -- 901
            addChild(nodeStack, cnode, enode) -- 903
        end -- 903
    end, -- 900
    model = function(nodeStack, enode, parent) -- 906
        local cnode = getModel(enode) -- 907
        if cnode ~= nil then -- 907
            addChild(nodeStack, cnode, enode) -- 909
        end -- 909
    end, -- 906
    ["draw-node"] = function(nodeStack, enode, parent) -- 912
        addChild( -- 913
            nodeStack, -- 913
            getDrawNode(enode), -- 913
            enode -- 913
        ) -- 913
    end, -- 912
    ["dot-shape"] = drawNodeCheck, -- 915
    ["segment-shape"] = drawNodeCheck, -- 916
    ["rect-shape"] = drawNodeCheck, -- 917
    ["polygon-shape"] = drawNodeCheck, -- 918
    ["verts-shape"] = drawNodeCheck, -- 919
    grid = function(nodeStack, enode, parent) -- 920
        addChild( -- 921
            nodeStack, -- 921
            getGrid(enode), -- 921
            enode -- 921
        ) -- 921
    end, -- 920
    sprite = function(nodeStack, enode, parent) -- 923
        local cnode = getSprite(enode) -- 924
        if cnode ~= nil then -- 924
            addChild(nodeStack, cnode, enode) -- 926
        end -- 926
    end, -- 923
    label = function(nodeStack, enode, parent) -- 929
        local cnode = getLabel(enode) -- 930
        if cnode ~= nil then -- 930
            addChild(nodeStack, cnode, enode) -- 932
        end -- 932
    end, -- 929
    line = function(nodeStack, enode, parent) -- 935
        addChild( -- 936
            nodeStack, -- 936
            getLine(enode), -- 936
            enode -- 936
        ) -- 936
    end, -- 935
    particle = function(nodeStack, enode, parent) -- 938
        local cnode = getParticle(enode) -- 939
        if cnode ~= nil then -- 939
            addChild(nodeStack, cnode, enode) -- 941
        end -- 941
    end, -- 938
    menu = function(nodeStack, enode, parent) -- 944
        addChild( -- 945
            nodeStack, -- 945
            getMenu(enode), -- 945
            enode -- 945
        ) -- 945
    end, -- 944
    action = function(_nodeStack, enode, parent) -- 947
        if #enode.children == 0 then -- 947
            Warn("<action> tag has no children") -- 949
            return -- 950
        end -- 950
        local action = enode.props -- 952
        if action.ref == nil then -- 952
            Warn("<action> tag has no ref") -- 954
            return -- 955
        end -- 955
        local actionStack = {} -- 957
        for i = 1, #enode.children do -- 957
            visitAction(actionStack, enode.children[i]) -- 959
        end -- 959
        if #actionStack == 1 then -- 959
            action.ref.current = actionStack[1] -- 962
        elseif #actionStack > 1 then -- 962
            action.ref.current = Dora.Sequence(table.unpack(actionStack)) -- 964
        end -- 964
    end, -- 947
    ["anchor-x"] = actionCheck, -- 967
    ["anchor-y"] = actionCheck, -- 968
    angle = actionCheck, -- 969
    ["angle-x"] = actionCheck, -- 970
    ["angle-y"] = actionCheck, -- 971
    delay = actionCheck, -- 972
    event = actionCheck, -- 973
    width = actionCheck, -- 974
    height = actionCheck, -- 975
    hide = actionCheck, -- 976
    show = actionCheck, -- 977
    move = actionCheck, -- 978
    opacity = actionCheck, -- 979
    roll = actionCheck, -- 980
    scale = actionCheck, -- 981
    ["scale-x"] = actionCheck, -- 982
    ["scale-y"] = actionCheck, -- 983
    ["skew-x"] = actionCheck, -- 984
    ["skew-y"] = actionCheck, -- 985
    ["move-x"] = actionCheck, -- 986
    ["move-y"] = actionCheck, -- 987
    ["move-z"] = actionCheck, -- 988
    spawn = actionCheck, -- 989
    sequence = actionCheck, -- 990
    loop = function(nodeStack, enode, _parent) -- 991
        if #nodeStack > 0 then -- 991
            local node = nodeStack[#nodeStack] -- 993
            local actionStack = {} -- 994
            for i = 1, #enode.children do -- 994
                visitAction(actionStack, enode.children[i]) -- 996
            end -- 996
            if #actionStack == 1 then -- 996
                node:runAction(actionStack[1], true) -- 999
            else -- 999
                local loop = enode.props -- 1001
                if loop.spawn then -- 1001
                    node:runAction( -- 1003
                        Dora.Spawn(table.unpack(actionStack)), -- 1003
                        true -- 1003
                    ) -- 1003
                else -- 1003
                    node:runAction( -- 1005
                        Dora.Sequence(table.unpack(actionStack)), -- 1005
                        true -- 1005
                    ) -- 1005
                end -- 1005
            end -- 1005
        else -- 1005
            Warn("tag <loop> must be placed under a scene node to take effect") -- 1009
        end -- 1009
    end, -- 991
    ["physics-world"] = function(nodeStack, enode, _parent) -- 1012
        addChild( -- 1013
            nodeStack, -- 1013
            getPhysicsWorld(enode), -- 1013
            enode -- 1013
        ) -- 1013
    end, -- 1012
    contact = function(nodeStack, enode, _parent) -- 1015
        local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1016
        if world ~= nil then -- 1016
            local contact = enode.props -- 1018
            world:setShouldContact(contact.groupA, contact.groupB, contact.enabled) -- 1019
        else -- 1019
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1021
        end -- 1021
    end, -- 1015
    body = function(nodeStack, enode, _parent) -- 1024
        local def = enode.props -- 1025
        if def.world then -- 1025
            addChild( -- 1027
                nodeStack, -- 1027
                getBody(enode, def.world), -- 1027
                enode -- 1027
            ) -- 1027
            return -- 1028
        end -- 1028
        local world = Dora.tolua.cast(nodeStack[#nodeStack], "PhysicsWorld") -- 1030
        if world ~= nil then -- 1030
            addChild( -- 1032
                nodeStack, -- 1032
                getBody(enode, world), -- 1032
                enode -- 1032
            ) -- 1032
        else -- 1032
            Warn(("tag <" .. enode.type) .. "> must be placed under <physics-world> or its derivatives to take effect") -- 1034
        end -- 1034
    end, -- 1024
    ["rect-fixture"] = bodyCheck, -- 1037
    ["polygon-fixture"] = bodyCheck, -- 1038
    ["multi-fixture"] = bodyCheck, -- 1039
    ["disk-fixture"] = bodyCheck, -- 1040
    ["chain-fixture"] = bodyCheck, -- 1041
    ["distance-joint"] = function(_nodeStack, enode, _parent) -- 1042
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
        local ____joint_ref_14 = joint.ref -- 1056
        local ____self_12 = Dora.Joint -- 1056
        local ____self_12_distance_13 = ____self_12.distance -- 1056
        local ____joint_canCollide_11 = joint.canCollide -- 1057
        if ____joint_canCollide_11 == nil then -- 1057
            ____joint_canCollide_11 = false -- 1057
        end -- 1057
        ____joint_ref_14.current = ____self_12_distance_13( -- 1056
            ____self_12, -- 1056
            ____joint_canCollide_11, -- 1057
            joint.bodyA.current, -- 1058
            joint.bodyB.current, -- 1059
            joint.anchorA or Dora.Vec2.zero, -- 1060
            joint.anchorB or Dora.Vec2.zero, -- 1061
            joint.frequency or 0, -- 1062
            joint.damping or 0 -- 1063
        ) -- 1063
    end, -- 1042
    ["friction-joint"] = function(_nodeStack, enode, _parent) -- 1065
        local joint = enode.props -- 1066
        if joint.ref == nil then -- 1066
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1068
            return -- 1069
        end -- 1069
        if joint.bodyA.current == nil then -- 1069
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1072
            return -- 1073
        end -- 1073
        if joint.bodyB.current == nil then -- 1073
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1076
            return -- 1077
        end -- 1077
        local ____joint_ref_18 = joint.ref -- 1079
        local ____self_16 = Dora.Joint -- 1079
        local ____self_16_friction_17 = ____self_16.friction -- 1079
        local ____joint_canCollide_15 = joint.canCollide -- 1080
        if ____joint_canCollide_15 == nil then -- 1080
            ____joint_canCollide_15 = false -- 1080
        end -- 1080
        ____joint_ref_18.current = ____self_16_friction_17( -- 1079
            ____self_16, -- 1079
            ____joint_canCollide_15, -- 1080
            joint.bodyA.current, -- 1081
            joint.bodyB.current, -- 1082
            joint.worldPos, -- 1083
            joint.maxForce, -- 1084
            joint.maxTorque -- 1085
        ) -- 1085
    end, -- 1065
    ["gear-joint"] = function(_nodeStack, enode, _parent) -- 1088
        local joint = enode.props -- 1089
        if joint.ref == nil then -- 1089
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1091
            return -- 1092
        end -- 1092
        if joint.jointA.current == nil then -- 1092
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointA is invalid") -- 1095
            return -- 1096
        end -- 1096
        if joint.jointB.current == nil then -- 1096
            Warn(("not creating instance of tag <" .. enode.type) .. "> because jointB is invalid") -- 1099
            return -- 1100
        end -- 1100
        local ____joint_ref_22 = joint.ref -- 1102
        local ____self_20 = Dora.Joint -- 1102
        local ____self_20_gear_21 = ____self_20.gear -- 1102
        local ____joint_canCollide_19 = joint.canCollide -- 1103
        if ____joint_canCollide_19 == nil then -- 1103
            ____joint_canCollide_19 = false -- 1103
        end -- 1103
        ____joint_ref_22.current = ____self_20_gear_21( -- 1102
            ____self_20, -- 1102
            ____joint_canCollide_19, -- 1103
            joint.jointA.current, -- 1104
            joint.jointB.current, -- 1105
            joint.ratio or 1 -- 1106
        ) -- 1106
    end, -- 1088
    ["spring-joint"] = function(_nodeStack, enode, _parent) -- 1109
        local joint = enode.props -- 1110
        if joint.ref == nil then -- 1110
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1112
            return -- 1113
        end -- 1113
        if joint.bodyA.current == nil then -- 1113
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1116
            return -- 1117
        end -- 1117
        if joint.bodyB.current == nil then -- 1117
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1120
            return -- 1121
        end -- 1121
        local ____joint_ref_26 = joint.ref -- 1123
        local ____self_24 = Dora.Joint -- 1123
        local ____self_24_spring_25 = ____self_24.spring -- 1123
        local ____joint_canCollide_23 = joint.canCollide -- 1124
        if ____joint_canCollide_23 == nil then -- 1124
            ____joint_canCollide_23 = false -- 1124
        end -- 1124
        ____joint_ref_26.current = ____self_24_spring_25( -- 1123
            ____self_24, -- 1123
            ____joint_canCollide_23, -- 1124
            joint.bodyA.current, -- 1125
            joint.bodyB.current, -- 1126
            joint.linearOffset, -- 1127
            joint.angularOffset, -- 1128
            joint.maxForce, -- 1129
            joint.maxTorque, -- 1130
            joint.correctionFactor or 1 -- 1131
        ) -- 1131
    end, -- 1109
    ["move-joint"] = function(_nodeStack, enode, _parent) -- 1134
        local joint = enode.props -- 1135
        if joint.ref == nil then -- 1135
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1137
            return -- 1138
        end -- 1138
        if joint.body.current == nil then -- 1138
            Warn(("not creating instance of tag <" .. enode.type) .. "> because body is invalid") -- 1141
            return -- 1142
        end -- 1142
        local ____joint_ref_30 = joint.ref -- 1144
        local ____self_28 = Dora.Joint -- 1144
        local ____self_28_move_29 = ____self_28.move -- 1144
        local ____joint_canCollide_27 = joint.canCollide -- 1145
        if ____joint_canCollide_27 == nil then -- 1145
            ____joint_canCollide_27 = false -- 1145
        end -- 1145
        ____joint_ref_30.current = ____self_28_move_29( -- 1144
            ____self_28, -- 1144
            ____joint_canCollide_27, -- 1145
            joint.body.current, -- 1146
            joint.targetPos, -- 1147
            joint.maxForce, -- 1148
            joint.frequency, -- 1149
            joint.damping or 0.7 -- 1150
        ) -- 1150
    end, -- 1134
    ["prismatic-joint"] = function(_nodeStack, enode, _parent) -- 1153
        local joint = enode.props -- 1154
        if joint.ref == nil then -- 1154
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1156
            return -- 1157
        end -- 1157
        if joint.bodyA.current == nil then -- 1157
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1160
            return -- 1161
        end -- 1161
        if joint.bodyB.current == nil then -- 1161
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1164
            return -- 1165
        end -- 1165
        local ____joint_ref_34 = joint.ref -- 1167
        local ____self_32 = Dora.Joint -- 1167
        local ____self_32_prismatic_33 = ____self_32.prismatic -- 1167
        local ____joint_canCollide_31 = joint.canCollide -- 1168
        if ____joint_canCollide_31 == nil then -- 1168
            ____joint_canCollide_31 = false -- 1168
        end -- 1168
        ____joint_ref_34.current = ____self_32_prismatic_33( -- 1167
            ____self_32, -- 1167
            ____joint_canCollide_31, -- 1168
            joint.bodyA.current, -- 1169
            joint.bodyB.current, -- 1170
            joint.worldPos, -- 1171
            joint.axisAngle, -- 1172
            joint.lowerTranslation or 0, -- 1173
            joint.upperTranslation or 0, -- 1174
            joint.maxMotorForce or 0, -- 1175
            joint.motorSpeed or 0 -- 1176
        ) -- 1176
    end, -- 1153
    ["pulley-joint"] = function(_nodeStack, enode, _parent) -- 1179
        local joint = enode.props -- 1180
        if joint.ref == nil then -- 1180
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1182
            return -- 1183
        end -- 1183
        if joint.bodyA.current == nil then -- 1183
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1186
            return -- 1187
        end -- 1187
        if joint.bodyB.current == nil then -- 1187
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1190
            return -- 1191
        end -- 1191
        local ____joint_ref_38 = joint.ref -- 1193
        local ____self_36 = Dora.Joint -- 1193
        local ____self_36_pulley_37 = ____self_36.pulley -- 1193
        local ____joint_canCollide_35 = joint.canCollide -- 1194
        if ____joint_canCollide_35 == nil then -- 1194
            ____joint_canCollide_35 = false -- 1194
        end -- 1194
        ____joint_ref_38.current = ____self_36_pulley_37( -- 1193
            ____self_36, -- 1193
            ____joint_canCollide_35, -- 1194
            joint.bodyA.current, -- 1195
            joint.bodyB.current, -- 1196
            joint.anchorA or Dora.Vec2.zero, -- 1197
            joint.anchorB or Dora.Vec2.zero, -- 1198
            joint.groundAnchorA, -- 1199
            joint.groundAnchorB, -- 1200
            joint.ratio or 1 -- 1201
        ) -- 1201
    end, -- 1179
    ["revolute-joint"] = function(_nodeStack, enode, _parent) -- 1204
        local joint = enode.props -- 1205
        if joint.ref == nil then -- 1205
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1207
            return -- 1208
        end -- 1208
        if joint.bodyA.current == nil then -- 1208
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1211
            return -- 1212
        end -- 1212
        if joint.bodyB.current == nil then -- 1212
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1215
            return -- 1216
        end -- 1216
        local ____joint_ref_42 = joint.ref -- 1218
        local ____self_40 = Dora.Joint -- 1218
        local ____self_40_revolute_41 = ____self_40.revolute -- 1218
        local ____joint_canCollide_39 = joint.canCollide -- 1219
        if ____joint_canCollide_39 == nil then -- 1219
            ____joint_canCollide_39 = false -- 1219
        end -- 1219
        ____joint_ref_42.current = ____self_40_revolute_41( -- 1218
            ____self_40, -- 1218
            ____joint_canCollide_39, -- 1219
            joint.bodyA.current, -- 1220
            joint.bodyB.current, -- 1221
            joint.worldPos, -- 1222
            joint.lowerAngle or 0, -- 1223
            joint.upperAngle or 0, -- 1224
            joint.maxMotorTorque or 0, -- 1225
            joint.motorSpeed or 0 -- 1226
        ) -- 1226
    end, -- 1204
    ["rope-joint"] = function(_nodeStack, enode, _parent) -- 1229
        local joint = enode.props -- 1230
        if joint.ref == nil then -- 1230
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1232
            return -- 1233
        end -- 1233
        if joint.bodyA.current == nil then -- 1233
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1236
            return -- 1237
        end -- 1237
        if joint.bodyB.current == nil then -- 1237
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1240
            return -- 1241
        end -- 1241
        local ____joint_ref_46 = joint.ref -- 1243
        local ____self_44 = Dora.Joint -- 1243
        local ____self_44_rope_45 = ____self_44.rope -- 1243
        local ____joint_canCollide_43 = joint.canCollide -- 1244
        if ____joint_canCollide_43 == nil then -- 1244
            ____joint_canCollide_43 = false -- 1244
        end -- 1244
        ____joint_ref_46.current = ____self_44_rope_45( -- 1243
            ____self_44, -- 1243
            ____joint_canCollide_43, -- 1244
            joint.bodyA.current, -- 1245
            joint.bodyB.current, -- 1246
            joint.anchorA or Dora.Vec2.zero, -- 1247
            joint.anchorB or Dora.Vec2.zero, -- 1248
            joint.maxLength or 0 -- 1249
        ) -- 1249
    end, -- 1229
    ["weld-joint"] = function(_nodeStack, enode, _parent) -- 1252
        local joint = enode.props -- 1253
        if joint.ref == nil then -- 1253
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1255
            return -- 1256
        end -- 1256
        if joint.bodyA.current == nil then -- 1256
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1259
            return -- 1260
        end -- 1260
        if joint.bodyB.current == nil then -- 1260
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1263
            return -- 1264
        end -- 1264
        local ____joint_ref_50 = joint.ref -- 1266
        local ____self_48 = Dora.Joint -- 1266
        local ____self_48_weld_49 = ____self_48.weld -- 1266
        local ____joint_canCollide_47 = joint.canCollide -- 1267
        if ____joint_canCollide_47 == nil then -- 1267
            ____joint_canCollide_47 = false -- 1267
        end -- 1267
        ____joint_ref_50.current = ____self_48_weld_49( -- 1266
            ____self_48, -- 1266
            ____joint_canCollide_47, -- 1267
            joint.bodyA.current, -- 1268
            joint.bodyB.current, -- 1269
            joint.worldPos, -- 1270
            joint.frequency or 0, -- 1271
            joint.damping or 0 -- 1272
        ) -- 1272
    end, -- 1252
    ["wheel-joint"] = function(_nodeStack, enode, _parent) -- 1275
        local joint = enode.props -- 1276
        if joint.ref == nil then -- 1276
            Warn(("not creating instance of tag <" .. enode.type) .. "> because it has no reference") -- 1278
            return -- 1279
        end -- 1279
        if joint.bodyA.current == nil then -- 1279
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyA is invalid") -- 1282
            return -- 1283
        end -- 1283
        if joint.bodyB.current == nil then -- 1283
            Warn(("not creating instance of tag <" .. enode.type) .. "> because bodyB is invalid") -- 1286
            return -- 1287
        end -- 1287
        local ____joint_ref_54 = joint.ref -- 1289
        local ____self_52 = Dora.Joint -- 1289
        local ____self_52_wheel_53 = ____self_52.wheel -- 1289
        local ____joint_canCollide_51 = joint.canCollide -- 1290
        if ____joint_canCollide_51 == nil then -- 1290
            ____joint_canCollide_51 = false -- 1290
        end -- 1290
        ____joint_ref_54.current = ____self_52_wheel_53( -- 1289
            ____self_52, -- 1289
            ____joint_canCollide_51, -- 1290
            joint.bodyA.current, -- 1291
            joint.bodyB.current, -- 1292
            joint.worldPos, -- 1293
            joint.axisAngle, -- 1294
            joint.maxMotorTorque or 0, -- 1295
            joint.motorSpeed or 0, -- 1296
            joint.frequency or 0, -- 1297
            joint.damping or 0.7 -- 1298
        ) -- 1298
    end, -- 1275
    ["custom-node"] = function(nodeStack, enode, _parent) -- 1301
        local node = getCustomNode(enode) -- 1302
        if node ~= nil then -- 1302
            addChild(nodeStack, node, enode) -- 1304
        end -- 1304
    end, -- 1301
    ["custom-element"] = function() -- 1307
    end, -- 1307
    ["align-node"] = function(nodeStack, enode, _parent) -- 1308
        addChild( -- 1309
            nodeStack, -- 1309
            getAlignNode(enode), -- 1309
            enode -- 1309
        ) -- 1309
    end, -- 1308
    ["effek-node"] = function(nodeStack, enode, _parent) -- 1311
        addChild( -- 1312
            nodeStack, -- 1312
            getEffekNode(enode), -- 1312
            enode -- 1312
        ) -- 1312
    end, -- 1311
    effek = function(nodeStack, enode, parent) -- 1314
        if #nodeStack > 0 then -- 1314
            local node = Dora.tolua.cast(nodeStack[#nodeStack], "EffekNode") -- 1316
            if node then -- 1316
                local effek = enode.props -- 1318
                local handle = node:play( -- 1319
                    effek.file, -- 1319
                    Dora.Vec2(effek.x or 0, effek.y or 0), -- 1319
                    effek.z or 0 -- 1319
                ) -- 1319
                if handle >= 0 then -- 1319
                    if effek.ref then -- 1319
                        effek.ref.current = handle -- 1322
                    end -- 1322
                    if effek.onEnd then -- 1322
                        local onEnd = effek.onEnd -- 1322
                        node:slot( -- 1326
                            "EffekEnd", -- 1326
                            function(h) -- 1326
                                if handle == h then -- 1326
                                    onEnd(nil) -- 1328
                                end -- 1328
                            end -- 1326
                        ) -- 1326
                    end -- 1326
                end -- 1326
            else -- 1326
                Warn(("tag <" .. enode.type) .. "> must be placed under a <effek-node> to take effect") -- 1334
            end -- 1334
        end -- 1334
    end, -- 1314
    ["tile-node"] = function(nodeStack, enode, parent) -- 1338
        local cnode = getTileNode(enode) -- 1339
        if cnode ~= nil then -- 1339
            addChild(nodeStack, cnode, enode) -- 1341
        end -- 1341
    end -- 1338
} -- 1338
function ____exports.useRef(item) -- 1386
    local ____item_55 = item -- 1387
    if ____item_55 == nil then -- 1387
        ____item_55 = nil -- 1387
    end -- 1387
    return {current = ____item_55} -- 1387
end -- 1386
local function getPreload(preloadList, node) -- 1390
    if type(node) ~= "table" then -- 1390
        return -- 1392
    end -- 1392
    local enode = node -- 1394
    if enode.type == nil then -- 1394
        local list = node -- 1396
        if #list > 0 then -- 1396
            for i = 1, #list do -- 1396
                getPreload(preloadList, list[i]) -- 1399
            end -- 1399
        end -- 1399
    else -- 1399
        repeat -- 1399
            local ____switch309 = enode.type -- 1399
            local sprite, playable, model, spine, dragonBone, label -- 1399
            local ____cond309 = ____switch309 == "sprite" -- 1399
            if ____cond309 then -- 1399
                sprite = enode.props -- 1405
                preloadList[#preloadList + 1] = sprite.file -- 1406
                break -- 1407
            end -- 1407
            ____cond309 = ____cond309 or ____switch309 == "playable" -- 1407
            if ____cond309 then -- 1407
                playable = enode.props -- 1409
                preloadList[#preloadList + 1] = playable.file -- 1410
                break -- 1411
            end -- 1411
            ____cond309 = ____cond309 or ____switch309 == "model" -- 1411
            if ____cond309 then -- 1411
                model = enode.props -- 1413
                preloadList[#preloadList + 1] = "model:" .. model.file -- 1414
                break -- 1415
            end -- 1415
            ____cond309 = ____cond309 or ____switch309 == "spine" -- 1415
            if ____cond309 then -- 1415
                spine = enode.props -- 1417
                preloadList[#preloadList + 1] = "spine:" .. spine.file -- 1418
                break -- 1419
            end -- 1419
            ____cond309 = ____cond309 or ____switch309 == "dragon-bone" -- 1419
            if ____cond309 then -- 1419
                dragonBone = enode.props -- 1421
                preloadList[#preloadList + 1] = "bone:" .. dragonBone.file -- 1422
                break -- 1423
            end -- 1423
            ____cond309 = ____cond309 or ____switch309 == "label" -- 1423
            if ____cond309 then -- 1423
                label = enode.props -- 1425
                preloadList[#preloadList + 1] = (("font:" .. label.fontName) .. ";") .. tostring(label.fontSize) -- 1426
                break -- 1427
            end -- 1427
        until true -- 1427
    end -- 1427
    getPreload(preloadList, enode.children) -- 1430
end -- 1390
function ____exports.preloadAsync(enode, handler) -- 1433
    local preloadList = {} -- 1434
    getPreload(preloadList, enode) -- 1435
    Dora.Cache:loadAsync(preloadList, handler) -- 1436
end -- 1433
return ____exports -- 1433