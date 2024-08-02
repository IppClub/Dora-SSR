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
local ImGui = require("ImGui") -- 14
local nvg = require("nvg") -- 15
local ____Packer = require("TexturePacker.Packer") -- 16
local Packer = ____Packer.default -- 16
local Ruler = require("UI.Control.Basic.Ruler") -- 17
function getLabel(text) -- 59
    local label = Label( -- 60
        "sarasa-mono-sc-regular", -- 60
        math.tointeger(24 * pixelRatio) -- 60
    ) -- 60
    if label then -- 60
        label.text = text -- 62
    end -- 62
    return label -- 64
end -- 64
function displayClips(folder) -- 67
    if currentFolder == folder then -- 67
        return -- 69
    end -- 69
    scaledSize = 1 -- 71
    ruler.value = 1 -- 72
    clipHover = "-" -- 73
    currentFolder = folder -- 74
    local name = Path:getName(folder) -- 75
    local path = Path:getPath(folder) -- 76
    local clipFile = Path(path, name .. ".clip") -- 77
    local pngFile = Path(path, name .. ".png") -- 78
    if currentDisplay ~= nil then -- 78
        currentDisplay:removeFromParent() -- 79
    end -- 79
    if Content:exist(clipFile) and Content:exist(pngFile) then -- 79
        Cache:load(clipFile) -- 81
        local sprite = Sprite(clipFile) -- 82
        if sprite then -- 82
            sprite.filter = anisotropic and "Anisotropic" or "Point" -- 84
            local frame = Line( -- 85
                { -- 85
                    Vec2.zero, -- 86
                    Vec2(sprite.width, 0), -- 87
                    Vec2(sprite.width, sprite.height), -- 88
                    Vec2(0, sprite.height), -- 89
                    Vec2.zero -- 90
                }, -- 90
                Color(1157627903) -- 91
            ):addTo(sprite) -- 91
            local rects = Sprite:getClips(clipFile) -- 92
            if rects then -- 92
                for ____, rc in pairs(rects) do -- 94
                    frame:addChild(Line( -- 95
                        { -- 95
                            Vec2(rc.left, rc.bottom), -- 96
                            Vec2(rc.right, rc.bottom), -- 97
                            Vec2(rc.right, rc.top), -- 98
                            Vec2(rc.left, rc.top), -- 99
                            Vec2(rc.left, rc.bottom) -- 100
                        }, -- 100
                        Color(4294967295) -- 101
                    )) -- 101
                end -- 101
            end -- 101
            frame.scaleY = -1 -- 104
            frame.y = sprite.height -- 105
            if rects then -- 105
                frame:schedule(function() -- 107
                    local ____App_bufferSize_2 = App.bufferSize -- 108
                    local bw = ____App_bufferSize_2.width -- 108
                    local bh = ____App_bufferSize_2.height -- 108
                    local ____App_visualSize_3 = App.visualSize -- 109
                    local vw = ____App_visualSize_3.width -- 109
                    local pos = nvg.TouchPos():mul(bw / vw) -- 110
                    pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y) -- 111
                    local localPos = frame:convertToNodeSpace(pos) -- 112
                    clipHover = "-" -- 113
                    for name, rc in pairs(rects) do -- 114
                        if rc:containsPoint(localPos) then -- 114
                            clipHover = name -- 116
                        end -- 116
                    end -- 116
                    return false -- 119
                end) -- 107
            end -- 107
            currentDisplay = sprite -- 122
        else -- 122
            currentDisplay = getLabel(zh and "加载 .clip 文件失败。" or "Failed to load .clip file.") -- 124
        end -- 124
    else -- 124
        currentDisplay = getLabel(zh and "未生成文件。" or "Needs generating.") -- 127
    end -- 127
end -- 127
zh = false -- 19
do -- 19
    local res = string.match(App.locale, "^zh") -- 21
    zh = res ~= nil and ImGui.IsFontLoaded() -- 22
end -- 22
local function getAllClipFolders() -- 25
    local folders = {} -- 26
    local function visitFolders(parent) -- 27
        for ____, dir in ipairs(Content:getDirs(parent)) do -- 28
            local path = Path(parent, dir) -- 29
            if Path:getExt(path) == "clips" then -- 29
                folders[#folders + 1] = path -- 31
            else -- 31
                visitFolders(path) -- 33
            end -- 33
        end -- 33
    end -- 27
    visitFolders(Content.writablePath) -- 37
    return folders -- 38
end -- 25
local clipFolders = getAllClipFolders() -- 41
local clipNames = __TS__ArrayMap( -- 42
    clipFolders, -- 42
    function(____, f) return Path:getFilename(f) end -- 42
) -- 42
currentDisplay = nil -- 44
currentFolder = nil -- 45
pixelRatio = App.devicePixelRatio -- 47
scaledSize = 1 -- 48
ruler = Ruler({y = -150 * pixelRatio, width = pixelRatio * 300, height = 75 * pixelRatio, fontSize = 15 * pixelRatio}) -- 49
ruler.order = 2 -- 50
anisotropic = true -- 52
clipHover = "-" -- 53
if #clipFolders > 0 then -- 53
    displayClips(clipFolders[1]) -- 56
end -- 56
local function generateClips(folder) -- 131
    scaledSize = 1 -- 132
    ruler.value = 1 -- 133
    clipHover = "-" -- 134
    local padding = 2 -- 135
    local blocks = {} -- 136
    local blendFunc = BlendFunc("One", "Zero") -- 137
    for ____, file in ipairs(Content:getAllFiles(folder)) do -- 138
        do -- 138
            repeat -- 138
                local ____switch27 = Path:getExt(file) -- 138
                local ____cond27 = ____switch27 == "png" or ____switch27 == "jpg" or ____switch27 == "dds" or ____switch27 == "pvr" or ____switch27 == "ktx" -- 138
                if ____cond27 then -- 138
                    do -- 138
                        local path = Path(folder, file) -- 141
                        Cache:unload(path) -- 142
                        local sp = Sprite(path) -- 143
                        if not sp then -- 143
                            goto __continue26 -- 144
                        end -- 144
                        sp.filter = "Point" -- 145
                        sp.blendFunc = blendFunc -- 146
                        sp.anchor = Vec2.zero -- 147
                        blocks[#blocks + 1] = { -- 148
                            w = sp.width + padding * 2, -- 149
                            h = sp.height + padding * 2, -- 150
                            sp = sp, -- 151
                            name = Path:getName(file) -- 152
                        } -- 152
                        Cache:unload(path) -- 154
                    end -- 154
                    break -- 154
                end -- 154
            until true -- 154
        end -- 154
        ::__continue26:: -- 154
    end -- 154
    if currentDisplay ~= nil then -- 154
        currentDisplay:removeFromParent() -- 158
    end -- 158
    if #blocks == 0 then -- 158
        currentDisplay = getLabel(zh and "没有文件。" or "No content.") -- 160
        return -- 161
    end -- 161
    local packer = Packer() -- 163
    packer:fit(blocks) -- 164
    if packer.root == nil then -- 164
        return -- 166
    end -- 166
    local ____packer_root_6 = packer.root -- 168
    local width = ____packer_root_6.w -- 168
    local height = ____packer_root_6.h -- 168
    local frame = Line( -- 169
        { -- 169
            Vec2.zero, -- 170
            Vec2(width, 0), -- 171
            Vec2(width, height), -- 172
            Vec2(0, height), -- 173
            Vec2.zero -- 174
        }, -- 174
        Color(1157627903) -- 175
    ) -- 175
    local node = Node() -- 177
    for ____, block in ipairs(blocks) do -- 178
        if block.fit and block.sp then -- 178
            local x = block.fit.x + padding -- 180
            local y = height - block.fit.y - block.h + padding -- 181
            local w = block.sp.width -- 182
            local h = block.sp.height -- 183
            frame:addChild(Line({ -- 184
                Vec2(x, y), -- 185
                Vec2(x + w, y), -- 186
                Vec2(x + w, y + h), -- 187
                Vec2(x, y + h), -- 188
                Vec2(x, y) -- 189
            })) -- 189
            block.sp.position = Vec2(x, y) -- 191
            node:addChild(block.sp) -- 192
        end -- 192
    end -- 192
    if not node.hasChildren then -- 192
        node:cleanup() -- 196
        return -- 197
    end -- 197
    local target = RenderTarget( -- 200
        math.tointeger(width), -- 200
        math.tointeger(height) -- 200
    ) -- 200
    target:renderWithClear( -- 201
        node, -- 201
        Color(0) -- 201
    ) -- 201
    node.visible = false -- 202
    node:removeAllChildren() -- 203
    node:cleanup() -- 204
    local outputName = Path:getName(folder) -- 206
    local xml = ("<A A=\"" .. Path:getName(folder)) .. ".png\">" -- 208
    for ____, block in ipairs(blocks) do -- 209
        do -- 209
            if block.fit == nil then -- 209
                goto __continue37 -- 210
            end -- 210
            xml = xml .. ((((((((("<B A=\"" .. block.name) .. "\" B=\"") .. tostring(block.fit.x + padding)) .. ",") .. tostring(block.fit.y + padding)) .. ",") .. tostring(block.w - padding * 2)) .. ",") .. tostring(block.h - padding * 2)) .. "\"/>" -- 211
        end -- 211
        ::__continue37:: -- 211
    end -- 211
    xml = xml .. "</A>" -- 213
    local textureFile = Path( -- 215
        Path:getPath(folder), -- 215
        outputName .. ".png" -- 215
    ) -- 215
    local clipFile = Path( -- 216
        Path:getPath(folder), -- 216
        outputName .. ".clip" -- 216
    ) -- 216
    thread(function() -- 217
        Content:saveAsync(clipFile, xml) -- 218
        target:saveAsync(textureFile) -- 219
    end) -- 217
    local displaySprite = Sprite(target.texture) -- 222
    displaySprite.filter = anisotropic and "Anisotropic" or "Point" -- 223
    displaySprite:addChild(frame) -- 224
    displaySprite:runAction(Opacity(0.3, 0, 1)) -- 225
    currentDisplay = displaySprite -- 226
end -- 131
local length = Vec2(App.visualSize).length -- 229
local tapCount = 0 -- 230
toNode(React:createElement( -- 231
    "node", -- 231
    { -- 231
        order = 1, -- 231
        onTapBegan = function() -- 231
            tapCount = tapCount + 1 -- 234
        end, -- 233
        onTapEnded = function() -- 233
            tapCount = tapCount - 1 -- 237
        end, -- 236
        onTapMoved = function(touch) -- 236
            if currentDisplay then -- 236
                currentDisplay.position = currentDisplay.position:add(touch.delta) -- 241
            end -- 241
        end, -- 239
        onGesture = function(_center, fingers, deltaDist, _deltaAngle) -- 239
            if tapCount > 0 then -- 239
                return -- 245
            end -- 245
            if currentDisplay and tolua.cast(currentDisplay, "Sprite") and fingers == 2 then -- 245
                local ____currentDisplay_7 = currentDisplay -- 247
                local width = ____currentDisplay_7.width -- 247
                local height = ____currentDisplay_7.height -- 247
                local size = Vec2(width, height).length -- 248
                scaledSize = scaledSize + deltaDist * length * 10 / size -- 249
                scaledSize = math.max(0.5, scaledSize) -- 250
                scaledSize = math.min(5, scaledSize) -- 251
                local ____currentDisplay_9 = currentDisplay -- 252
                local ____scaledSize_8 = scaledSize -- 252
                currentDisplay.scaleY = ____scaledSize_8 -- 252
                ____currentDisplay_9.scaleX = ____scaledSize_8 -- 252
            end -- 252
        end -- 244
    } -- 244
)) -- 244
local current = 1 -- 258
local filterBuf = Buffer(20) -- 259
local windowFlags = { -- 260
    "NoDecoration", -- 261
    "NoSavedSettings", -- 262
    "NoFocusOnAppearing", -- 263
    "NoNav", -- 264
    "NoMove", -- 265
    "NoScrollWithMouse" -- 266
} -- 266
local inputTextFlags = {"AutoSelectAll"} -- 268
local filteredNames = clipNames -- 269
local filteredFolders = clipFolders -- 270
local scaleChecked = false -- 271
local themeColor = App.themeColor -- 272
threadLoop(function() -- 273
    local ____App_visualSize_10 = App.visualSize -- 274
    local width = ____App_visualSize_10.width -- 274
    ImGui.SetNextWindowPos( -- 275
        Vec2(width - 10, 10), -- 275
        "Always", -- 275
        Vec2(1, 0) -- 275
    ) -- 275
    ImGui.SetNextWindowSize( -- 276
        Vec2(230, 0), -- 276
        "Always" -- 276
    ) -- 276
    ImGui.Begin( -- 277
        "Texture Packer", -- 277
        windowFlags, -- 277
        function() -- 277
            ImGui.Text(zh and "纹理打包工具" or "Texture Packer") -- 278
            ImGui.SameLine() -- 279
            ImGui.TextDisabled("(?)") -- 280
            if ImGui.IsItemHovered() then -- 280
                ImGui.BeginTooltip(function() -- 282
                    ImGui.PushTextWrapPos( -- 283
                        300, -- 283
                        function() -- 283
                            ImGui.Text(zh and "将图像文件（png、jpg、ktx、pvr）放入一个以 '.clips' 结尾的文件夹中，然后重新加载纹理打包工具以找到该文件夹并创建一个打包图像文件。打包后的图像将保存为 '.png' 文件，并生成一个对应的描述文件，保存为 '.clip' 文件。例如，'items.clips' 会变成 'items.png' 和 'items.clip'。" or "Place image files (png, jpg, ktx, pvr) in a folder named with a '.clips' suffix. Reload the texture packer to locate the folder and create a packed image file. The packed image will be saved as a '.png' file, and a corresponding description file will be saved as a '.clip' file. For example, 'items.clips' becomes 'items.png' and 'items.clip'.") -- 284
                        end -- 283
                    ) -- 283
                end) -- 282
            end -- 282
            ImGui.Separator() -- 288
            ImGui.InputText("##FilterInput", filterBuf, inputTextFlags) -- 289
            ImGui.SameLine() -- 290
            if ImGui.Button(zh and "筛选" or "Filter") then -- 290
                local filterText = filterBuf.text -- 292
                if filterText == "" then -- 292
                    filteredNames = clipNames -- 294
                    filteredFolders = clipFolders -- 295
                    current = 1 -- 296
                    if #filteredFolders > 0 then -- 296
                        displayClips(filteredFolders[current]) -- 298
                    end -- 298
                else -- 298
                    local filtered = __TS__ArrayFilter( -- 301
                        __TS__ArrayMap( -- 301
                            clipNames, -- 301
                            function(____, n, i) return {n, clipFolders[i + 1]} end -- 301
                        ), -- 301
                        function(____, it, i) -- 301
                            local matched = string.match( -- 302
                                string.lower(it[1]), -- 302
                                filterText -- 302
                            ) -- 302
                            if matched ~= nil then -- 302
                                return true -- 304
                            end -- 304
                            return false -- 306
                        end -- 301
                    ) -- 301
                    filteredNames = __TS__ArrayMap( -- 308
                        filtered, -- 308
                        function(____, f) return f[1] end -- 308
                    ) -- 308
                    filteredFolders = __TS__ArrayMap( -- 309
                        filtered, -- 309
                        function(____, f) return f[2] end -- 309
                    ) -- 309
                    current = 1 -- 310
                    if #filteredFolders > 0 then -- 310
                        displayClips(filteredFolders[current]) -- 312
                    end -- 312
                end -- 312
            end -- 312
            if #filteredNames > 0 then -- 312
                local changed = false -- 317
                changed, current = ImGui.Combo(zh and "文件" or "File", current, filteredNames) -- 318
                if changed then -- 318
                    displayClips(filteredFolders[current]) -- 320
                end -- 320
                if ImGui.Button(zh and "生成切片图集" or "Generate Clip") then -- 320
                    generateClips(filteredFolders[current]) -- 323
                end -- 323
            end -- 323
            ImGui.Separator() -- 326
            ImGui.Text(zh and "预览" or "Preview") -- 327
            local sprite = tolua.cast(currentDisplay, "Sprite") -- 328
            if sprite then -- 328
                ImGui.TextColored(themeColor, zh and "尺寸：" or "Size:") -- 330
                ImGui.SameLine() -- 331
                ImGui.Text((tostring(math.tointeger(sprite.width)) .. " x ") .. tostring(math.tointeger(sprite.height))) -- 332
                ImGui.TextColored(themeColor, zh and "切片名称：" or "Clip Name:") -- 333
                ImGui.SameLine() -- 334
                ImGui.Text(clipHover) -- 335
            end -- 335
            local changed = false -- 337
            changed, anisotropic = ImGui.Checkbox(zh and "各向异性过滤" or "Anisotropic", anisotropic) -- 338
            if changed then -- 338
                if sprite then -- 338
                    sprite.filter = anisotropic and "Anisotropic" or "Point" -- 341
                end -- 341
            end -- 341
            ImGui.Separator() -- 344
            changed = false -- 345
            changed, scaleChecked = ImGui.Checkbox(zh and "缩放工具" or "Scale Helper", scaleChecked) -- 346
            if changed then -- 346
                if scaleChecked then -- 346
                    ruler:show( -- 349
                        scaledSize, -- 349
                        0.5, -- 349
                        5, -- 349
                        1, -- 349
                        function(value) -- 349
                            scaledSize = value -- 350
                            if currentDisplay and tolua.cast(currentDisplay, "Sprite") then -- 350
                                local ____currentDisplay_12 = currentDisplay -- 352
                                local ____scaledSize_11 = scaledSize -- 352
                                currentDisplay.scaleY = ____scaledSize_11 -- 352
                                ____currentDisplay_12.scaleX = ____scaledSize_11 -- 352
                            end -- 352
                        end -- 349
                    ) -- 349
                else -- 349
                    ruler:hide() -- 356
                end -- 356
            end -- 356
        end -- 277
    ) -- 277
    return false -- 360
end) -- 273
return ____exports -- 273