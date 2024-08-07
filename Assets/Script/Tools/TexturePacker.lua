-- [tsx]: TexturePacker.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local getLabel, displayClips, zh, currentDisplay, currentFolder, pixelRatio, scaledSize, ruler, anisotropic, clipHover -- 1
local ____DoraX = require("DoraX") -- 11
local React = ____DoraX.React -- 11
local toNode = ____DoraX.toNode -- 11
local ____Dora = require("Dora") -- 12
local App = ____Dora.App -- 12
local BlendFunc = ____Dora.BlendFunc -- 12
local Buffer = ____Dora.Buffer -- 12
local Cache = ____Dora.Cache -- 12
local Color = ____Dora.Color -- 12
local Content = ____Dora.Content -- 12
local Label = ____Dora.Label -- 12
local Line = ____Dora.Line -- 12
local Node = ____Dora.Node -- 12
local Opacity = ____Dora.Opacity -- 12
local Path = ____Dora.Path -- 12
local RenderTarget = ____Dora.RenderTarget -- 12
local Sprite = ____Dora.Sprite -- 12
local Vec2 = ____Dora.Vec2 -- 12
local thread = ____Dora.thread -- 12
local threadLoop = ____Dora.threadLoop -- 12
local tolua = ____Dora.tolua -- 12
local Mouse = ____Dora.Mouse -- 12
local ImGui = require("ImGui") -- 14
local ____Packer = require("TexturePacker.Packer") -- 15
local Packer = ____Packer.default -- 15
local Ruler = require("UI.Control.Basic.Ruler") -- 16
function getLabel(text) -- 58
    local label = Label( -- 59
        "sarasa-mono-sc-regular", -- 59
        math.tointeger(24 * pixelRatio) -- 59
    ) -- 59
    if label then -- 59
        label.text = text -- 61
    end -- 61
    return label -- 63
end -- 63
function displayClips(folder) -- 66
    if currentFolder == folder then -- 66
        return -- 68
    end -- 68
    scaledSize = 1 -- 70
    ruler.value = 1 -- 71
    clipHover = "-" -- 72
    currentFolder = folder -- 73
    local name = Path:getName(folder) -- 74
    local path = Path:getPath(folder) -- 75
    local clipFile = Path(path, name .. ".clip") -- 76
    local pngFile = Path(path, name .. ".png") -- 77
    if currentDisplay ~= nil then -- 77
        currentDisplay:removeFromParent() -- 78
    end -- 78
    if Content:exist(clipFile) and Content:exist(pngFile) then -- 78
        Cache:load(clipFile) -- 80
        local sprite = Sprite(clipFile) -- 81
        if sprite then -- 81
            sprite.filter = anisotropic and "Anisotropic" or "Point" -- 83
            local frame = Line( -- 84
                { -- 84
                    Vec2.zero, -- 85
                    Vec2(sprite.width, 0), -- 86
                    Vec2(sprite.width, sprite.height), -- 87
                    Vec2(0, sprite.height), -- 88
                    Vec2.zero -- 89
                }, -- 89
                Color(1157627903) -- 90
            ):addTo(sprite) -- 90
            local rects = Sprite:getClips(clipFile) -- 91
            if rects then -- 91
                for ____, rc in pairs(rects) do -- 93
                    frame:addChild(Line( -- 94
                        { -- 94
                            Vec2(rc.left, rc.bottom), -- 95
                            Vec2(rc.right, rc.bottom), -- 96
                            Vec2(rc.right, rc.top), -- 97
                            Vec2(rc.left, rc.top), -- 98
                            Vec2(rc.left, rc.bottom) -- 99
                        }, -- 99
                        Color(4294967295) -- 100
                    )) -- 100
                end -- 100
            end -- 100
            frame.scaleY = -1 -- 103
            frame.y = sprite.height -- 104
            if rects then -- 104
                frame:schedule(function() -- 106
                    local ____App_bufferSize_2 = App.bufferSize -- 107
                    local bw = ____App_bufferSize_2.width -- 107
                    local bh = ____App_bufferSize_2.height -- 107
                    local ____App_visualSize_3 = App.visualSize -- 108
                    local vw = ____App_visualSize_3.width -- 108
                    local pos = Mouse.position:mul(bw / vw) -- 109
                    pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y) -- 110
                    local localPos = frame:convertToNodeSpace(pos) -- 111
                    clipHover = "-" -- 112
                    for name, rc in pairs(rects) do -- 113
                        if rc:containsPoint(localPos) then -- 113
                            clipHover = name -- 115
                        end -- 115
                    end -- 115
                    return false -- 118
                end) -- 106
            end -- 106
            currentDisplay = sprite -- 121
        else -- 121
            currentDisplay = getLabel(zh and "加载 .clip 文件失败。" or "Failed to load .clip file.") -- 123
        end -- 123
    else -- 123
        currentDisplay = getLabel(zh and "未生成文件。" or "Needs generating.") -- 126
    end -- 126
end -- 126
zh = false -- 18
do -- 18
    local res = string.match(App.locale, "^zh") -- 20
    zh = res ~= nil and ImGui.IsFontLoaded() -- 21
end -- 21
local function getAllClipFolders() -- 24
    local folders = {} -- 25
    local function visitFolders(parent) -- 26
        for ____, dir in ipairs(Content:getDirs(parent)) do -- 27
            local path = Path(parent, dir) -- 28
            if Path:getExt(path) == "clips" then -- 28
                folders[#folders + 1] = path -- 30
            else -- 30
                visitFolders(path) -- 32
            end -- 32
        end -- 32
    end -- 26
    visitFolders(Content.writablePath) -- 36
    return folders -- 37
end -- 24
local clipFolders = getAllClipFolders() -- 40
local clipNames = __TS__ArrayMap( -- 41
    clipFolders, -- 41
    function(____, f) return Path:getFilename(f) end -- 41
) -- 41
currentDisplay = nil -- 43
currentFolder = nil -- 44
pixelRatio = App.devicePixelRatio -- 46
scaledSize = 1 -- 47
ruler = Ruler({y = -150 * pixelRatio, width = pixelRatio * 300, height = 75 * pixelRatio, fontSize = 15 * pixelRatio}) -- 48
ruler.order = 2 -- 49
anisotropic = true -- 51
clipHover = "-" -- 52
if #clipFolders > 0 then -- 52
    displayClips(clipFolders[1]) -- 55
end -- 55
local function generateClips(folder) -- 130
    scaledSize = 1 -- 131
    ruler.value = 1 -- 132
    clipHover = "-" -- 133
    local padding = 2 -- 134
    local blocks = {} -- 135
    local blendFunc = BlendFunc("One", "Zero") -- 136
    for ____, file in ipairs(Content:getAllFiles(folder)) do -- 137
        do -- 137
            repeat -- 137
                local ____switch27 = Path:getExt(file) -- 137
                local ____cond27 = ____switch27 == "png" or ____switch27 == "jpg" or ____switch27 == "dds" or ____switch27 == "pvr" or ____switch27 == "ktx" -- 137
                if ____cond27 then -- 137
                    do -- 137
                        local path = Path(folder, file) -- 140
                        Cache:unload(path) -- 141
                        local sp = Sprite(path) -- 142
                        if not sp then -- 142
                            goto __continue26 -- 143
                        end -- 143
                        sp.filter = "Point" -- 144
                        sp.blendFunc = blendFunc -- 145
                        sp.anchor = Vec2.zero -- 146
                        blocks[#blocks + 1] = { -- 147
                            w = sp.width + padding * 2, -- 148
                            h = sp.height + padding * 2, -- 149
                            sp = sp, -- 150
                            name = Path:getName(file) -- 151
                        } -- 151
                        Cache:unload(path) -- 153
                    end -- 153
                    break -- 153
                end -- 153
            until true -- 153
        end -- 153
        ::__continue26:: -- 153
    end -- 153
    if currentDisplay ~= nil then -- 153
        currentDisplay:removeFromParent() -- 157
    end -- 157
    if #blocks == 0 then -- 157
        currentDisplay = getLabel(zh and "没有文件。" or "No content.") -- 159
        return -- 160
    end -- 160
    local packer = Packer() -- 162
    packer:fit(blocks) -- 163
    if packer.root == nil then -- 163
        return -- 165
    end -- 165
    local ____packer_root_6 = packer.root -- 167
    local width = ____packer_root_6.w -- 167
    local height = ____packer_root_6.h -- 167
    local frame = Line( -- 168
        { -- 168
            Vec2.zero, -- 169
            Vec2(width, 0), -- 170
            Vec2(width, height), -- 171
            Vec2(0, height), -- 172
            Vec2.zero -- 173
        }, -- 173
        Color(1157627903) -- 174
    ) -- 174
    local node = Node() -- 176
    for ____, block in ipairs(blocks) do -- 177
        if block.fit and block.sp then -- 177
            local x = block.fit.x + padding -- 179
            local y = height - block.fit.y - block.h + padding -- 180
            local w = block.sp.width -- 181
            local h = block.sp.height -- 182
            frame:addChild(Line({ -- 183
                Vec2(x, y), -- 184
                Vec2(x + w, y), -- 185
                Vec2(x + w, y + h), -- 186
                Vec2(x, y + h), -- 187
                Vec2(x, y) -- 188
            })) -- 188
            block.sp.position = Vec2(x, y) -- 190
            node:addChild(block.sp) -- 191
        end -- 191
    end -- 191
    if not node.hasChildren then -- 191
        node:cleanup() -- 195
        return -- 196
    end -- 196
    local target = RenderTarget( -- 199
        math.tointeger(width), -- 199
        math.tointeger(height) -- 199
    ) -- 199
    target:renderWithClear( -- 200
        node, -- 200
        Color(0) -- 200
    ) -- 200
    node.visible = false -- 201
    node:removeAllChildren() -- 202
    node:cleanup() -- 203
    local outputName = Path:getName(folder) -- 205
    local xml = ("<A A=\"" .. Path:getName(folder)) .. ".png\">" -- 207
    for ____, block in ipairs(blocks) do -- 208
        do -- 208
            if block.fit == nil then -- 208
                goto __continue37 -- 209
            end -- 209
            xml = xml .. ((((((((("<B A=\"" .. block.name) .. "\" B=\"") .. tostring(block.fit.x + padding)) .. ",") .. tostring(block.fit.y + padding)) .. ",") .. tostring(block.w - padding * 2)) .. ",") .. tostring(block.h - padding * 2)) .. "\"/>" -- 210
        end -- 210
        ::__continue37:: -- 210
    end -- 210
    xml = xml .. "</A>" -- 212
    local textureFile = Path( -- 214
        Path:getPath(folder), -- 214
        outputName .. ".png" -- 214
    ) -- 214
    local clipFile = Path( -- 215
        Path:getPath(folder), -- 215
        outputName .. ".clip" -- 215
    ) -- 215
    thread(function() -- 216
        Content:saveAsync(clipFile, xml) -- 217
        target:saveAsync(textureFile) -- 218
    end) -- 216
    local displaySprite = Sprite(target.texture) -- 221
    displaySprite.filter = anisotropic and "Anisotropic" or "Point" -- 222
    displaySprite:addChild(frame) -- 223
    displaySprite:runAction(Opacity(0.3, 0, 1)) -- 224
    currentDisplay = displaySprite -- 225
end -- 130
local length = Vec2(App.visualSize).length -- 228
local tapCount = 0 -- 229
toNode(React:createElement( -- 230
    "node", -- 230
    { -- 230
        order = 1, -- 230
        onTapBegan = function() -- 230
            tapCount = tapCount + 1 -- 233
        end, -- 232
        onTapEnded = function() -- 232
            tapCount = tapCount - 1 -- 236
        end, -- 235
        onTapMoved = function(touch) -- 235
            if currentDisplay then -- 235
                currentDisplay.position = currentDisplay.position:add(touch.delta) -- 240
            end -- 240
        end, -- 238
        onGesture = function(_center, fingers, deltaDist, _deltaAngle) -- 238
            if tapCount > 0 then -- 238
                return -- 244
            end -- 244
            if currentDisplay and tolua.cast(currentDisplay, "Sprite") and fingers == 2 then -- 244
                local ____currentDisplay_7 = currentDisplay -- 246
                local width = ____currentDisplay_7.width -- 246
                local height = ____currentDisplay_7.height -- 246
                local size = Vec2(width, height).length -- 247
                scaledSize = scaledSize + deltaDist * length * 10 / size -- 248
                scaledSize = math.max(0.5, scaledSize) -- 249
                scaledSize = math.min(5, scaledSize) -- 250
                local ____currentDisplay_9 = currentDisplay -- 251
                local ____scaledSize_8 = scaledSize -- 251
                currentDisplay.scaleY = ____scaledSize_8 -- 251
                ____currentDisplay_9.scaleX = ____scaledSize_8 -- 251
            end -- 251
        end -- 243
    } -- 243
)) -- 243
local current = 1 -- 257
local filterBuf = Buffer(20) -- 258
local windowFlags = { -- 259
    "NoDecoration", -- 260
    "NoSavedSettings", -- 261
    "NoFocusOnAppearing", -- 262
    "NoNav", -- 263
    "NoMove", -- 264
    "NoScrollWithMouse" -- 265
} -- 265
local inputTextFlags = {"AutoSelectAll"} -- 267
local filteredNames = clipNames -- 268
local filteredFolders = clipFolders -- 269
local scaleChecked = false -- 270
local themeColor = App.themeColor -- 271
threadLoop(function() -- 272
    local ____App_visualSize_10 = App.visualSize -- 273
    local width = ____App_visualSize_10.width -- 273
    ImGui.SetNextWindowPos( -- 274
        Vec2(width - 10, 10), -- 274
        "Always", -- 274
        Vec2(1, 0) -- 274
    ) -- 274
    ImGui.SetNextWindowSize( -- 275
        Vec2(230, 0), -- 275
        "Always" -- 275
    ) -- 275
    ImGui.Begin( -- 276
        "Texture Packer", -- 276
        windowFlags, -- 276
        function() -- 276
            ImGui.Text(zh and "纹理打包工具" or "Texture Packer") -- 277
            ImGui.SameLine() -- 278
            ImGui.TextDisabled("(?)") -- 279
            if ImGui.IsItemHovered() then -- 279
                ImGui.BeginTooltip(function() -- 281
                    ImGui.PushTextWrapPos( -- 282
                        300, -- 282
                        function() -- 282
                            ImGui.Text(zh and "将图像文件（png、jpg、ktx、pvr）放入一个以 '.clips' 结尾的文件夹中，然后重新加载纹理打包工具以找到该文件夹并创建一个打包图像文件。打包后的图像将保存为 '.png' 文件，并生成一个对应的描述文件，保存为 '.clip' 文件。例如，'items.clips' 会变成 'items.png' 和 'items.clip'。" or "Place image files (png, jpg, ktx, pvr) in a folder named with a '.clips' suffix. Reload the texture packer to locate the folder and create a packed image file. The packed image will be saved as a '.png' file, and a corresponding description file will be saved as a '.clip' file. For example, 'items.clips' becomes 'items.png' and 'items.clip'.") -- 283
                        end -- 282
                    ) -- 282
                end) -- 281
            end -- 281
            ImGui.Separator() -- 287
            ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 288
            ImGui.SameLine() -- 289
            if ImGui.Button(zh and "筛选" or "Filter") then -- 289
                local filterText = filterBuf.text -- 291
                if filterText == "" then -- 291
                    filteredNames = clipNames -- 293
                    filteredFolders = clipFolders -- 294
                    current = 1 -- 295
                    if #filteredFolders > 0 then -- 295
                        displayClips(filteredFolders[current]) -- 297
                    end -- 297
                else -- 297
                    local filtered = __TS__ArrayFilter( -- 300
                        __TS__ArrayMap( -- 300
                            clipNames, -- 300
                            function(____, n, i) return {n, clipFolders[i + 1]} end -- 300
                        ), -- 300
                        function(____, it, i) -- 300
                            local matched = string.match( -- 301
                                string.lower(it[1]), -- 301
                                filterText -- 301
                            ) -- 301
                            if matched ~= nil then -- 301
                                return true -- 303
                            end -- 303
                            return false -- 305
                        end -- 300
                    ) -- 300
                    filteredNames = __TS__ArrayMap( -- 307
                        filtered, -- 307
                        function(____, f) return f[1] end -- 307
                    ) -- 307
                    filteredFolders = __TS__ArrayMap( -- 308
                        filtered, -- 308
                        function(____, f) return f[2] end -- 308
                    ) -- 308
                    current = 1 -- 309
                    if #filteredFolders > 0 then -- 309
                        displayClips(filteredFolders[current]) -- 311
                    end -- 311
                end -- 311
            end -- 311
            if #filteredNames > 0 then -- 311
                local changed = false -- 316
                changed, current = ImGui.Combo(zh and "文件" or "File", current, filteredNames) -- 317
                if changed then -- 317
                    displayClips(filteredFolders[current]) -- 319
                end -- 319
                if ImGui.Button(zh and "生成切片图集" or "Generate Clip") then -- 319
                    generateClips(filteredFolders[current]) -- 322
                end -- 322
            end -- 322
            ImGui.Separator() -- 325
            ImGui.Text(zh and "预览" or "Preview") -- 326
            local sprite = tolua.cast(currentDisplay, "Sprite") -- 327
            if sprite then -- 327
                ImGui.TextColored(themeColor, zh and "尺寸：" or "Size:") -- 329
                ImGui.SameLine() -- 330
                ImGui.Text((tostring(math.tointeger(sprite.width)) .. " x ") .. tostring(math.tointeger(sprite.height))) -- 331
                ImGui.TextColored(themeColor, zh and "切片名称：" or "Clip Name:") -- 332
                ImGui.SameLine() -- 333
                ImGui.Text(clipHover) -- 334
            end -- 334
            local changed = false -- 336
            changed, anisotropic = ImGui.Checkbox(zh and "各向异性过滤" or "Anisotropic", anisotropic) -- 337
            if changed then -- 337
                if sprite then -- 337
                    sprite.filter = anisotropic and "Anisotropic" or "Point" -- 340
                end -- 340
            end -- 340
            ImGui.Separator() -- 343
            changed = false -- 344
            changed, scaleChecked = ImGui.Checkbox(zh and "缩放工具" or "Scale Helper", scaleChecked) -- 345
            if changed then -- 345
                if scaleChecked then -- 345
                    ruler:show( -- 348
                        scaledSize, -- 348
                        0.5, -- 348
                        5, -- 348
                        1, -- 348
                        function(value) -- 348
                            scaledSize = value -- 349
                            if currentDisplay and tolua.cast(currentDisplay, "Sprite") then -- 349
                                local ____currentDisplay_12 = currentDisplay -- 351
                                local ____scaledSize_11 = scaledSize -- 351
                                currentDisplay.scaleY = ____scaledSize_11 -- 351
                                ____currentDisplay_12.scaleX = ____scaledSize_11 -- 351
                            end -- 351
                        end -- 348
                    ) -- 348
                else -- 348
                    ruler:hide() -- 355
                end -- 355
            end -- 355
        end -- 276
    ) -- 276
    return false -- 359
end) -- 272
return ____exports -- 272