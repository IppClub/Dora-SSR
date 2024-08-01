-- [tsx]: TexturePacker.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local ____exports = {} -- 1
local getLabel, displayClips, currentDisplay, currentFolder, pixelRatio, scaledSize, ruler, filterMode -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local BlendFunc = ____Dora.BlendFunc -- 3
local Buffer = ____Dora.Buffer -- 3
local Cache = ____Dora.Cache -- 3
local Color = ____Dora.Color -- 3
local Content = ____Dora.Content -- 3
local Label = ____Dora.Label -- 3
local Line = ____Dora.Line -- 3
local Node = ____Dora.Node -- 3
local Opacity = ____Dora.Opacity -- 3
local Path = ____Dora.Path -- 3
local RenderTarget = ____Dora.RenderTarget -- 3
local Sprite = ____Dora.Sprite -- 3
local Vec2 = ____Dora.Vec2 -- 3
local thread = ____Dora.thread -- 3
local threadLoop = ____Dora.threadLoop -- 3
local tolua = ____Dora.tolua -- 3
local ImGui = require("ImGui") -- 5
local ____Packer = require("TexturePacker.Packer") -- 6
local Packer = ____Packer.default -- 6
local Ruler = require("UI.Control.Basic.Ruler") -- 7
function getLabel(text) -- 42
    local label = Label( -- 43
        "sarasa-mono-sc-regular", -- 43
        math.tointeger(24 * pixelRatio) -- 43
    ) -- 43
    if label then -- 43
        label.text = text -- 45
    end -- 45
    return label -- 47
end -- 47
function displayClips(folder) -- 50
    if currentFolder == folder then -- 50
        return -- 52
    end -- 52
    scaledSize = 1 -- 54
    ruler.value = 1 -- 55
    currentFolder = folder -- 56
    local name = Path:getName(folder) -- 57
    local path = Path:getPath(folder) -- 58
    local clipFile = Path(path, name .. ".clip") -- 59
    local pngFile = Path(path, name .. ".png") -- 60
    if currentDisplay ~= nil then -- 60
        currentDisplay:removeFromParent() -- 61
    end -- 61
    if Content:exist(clipFile) and Content:exist(pngFile) then -- 61
        Cache:load(clipFile) -- 63
        local sprite = Sprite(clipFile) -- 64
        if sprite then -- 64
            sprite.filter = filterMode == 1 and "Anisotropic" or "Point" -- 66
            local frame = Line( -- 67
                { -- 67
                    Vec2.zero, -- 68
                    Vec2(sprite.width, 0), -- 69
                    Vec2(sprite.width, sprite.height), -- 70
                    Vec2(0, sprite.height), -- 71
                    Vec2.zero -- 72
                }, -- 72
                Color(1157627903) -- 73
            ):addTo(sprite) -- 73
            local rects = Sprite:getClips(clipFile) -- 74
            if rects then -- 74
                for ____, rc in pairs(rects) do -- 76
                    frame:addChild(Line( -- 77
                        { -- 77
                            Vec2(rc.left, rc.bottom), -- 78
                            Vec2(rc.right, rc.bottom), -- 79
                            Vec2(rc.right, rc.top), -- 80
                            Vec2(rc.left, rc.top), -- 81
                            Vec2(rc.left, rc.bottom) -- 82
                        }, -- 82
                        Color(4294967295) -- 83
                    )) -- 83
                end -- 83
            end -- 83
            frame.scaleY = -1 -- 86
            frame.y = sprite.height -- 87
            currentDisplay = sprite -- 88
        else -- 88
            currentDisplay = getLabel("Failed to load clip file.") -- 90
        end -- 90
        Cache:unload(clipFile) -- 92
    else -- 92
        currentDisplay = getLabel("Needs generating.") -- 94
    end -- 94
end -- 94
local function getAllClipFolders() -- 9
    local folders = {} -- 10
    local function visitFolders(parent) -- 11
        for ____, dir in ipairs(Content:getDirs(parent)) do -- 12
            local path = Path(parent, dir) -- 13
            if Path:getExt(path) == "clips" then -- 13
                folders[#folders + 1] = path -- 15
            else -- 15
                visitFolders(path) -- 17
            end -- 17
        end -- 17
    end -- 11
    visitFolders(Content.writablePath) -- 21
    return folders -- 22
end -- 9
local clipFolders = getAllClipFolders() -- 25
local clipNames = __TS__ArrayMap( -- 26
    clipFolders, -- 26
    function(____, f) return Path:getFilename(f) end -- 26
) -- 26
currentDisplay = nil -- 28
currentFolder = nil -- 29
pixelRatio = App.devicePixelRatio -- 31
scaledSize = 1 -- 32
ruler = Ruler({y = -150 * pixelRatio, width = pixelRatio * 300, height = 75 * pixelRatio, fontSize = 15 * pixelRatio}) -- 33
ruler.order = 2 -- 34
filterMode = 1 -- 36
if #clipFolders > 0 then -- 36
    displayClips(clipFolders[1]) -- 39
end -- 39
local function generateClips(folder) -- 98
    scaledSize = 1 -- 99
    ruler.value = 1 -- 100
    local padding = 2 -- 101
    local blocks = {} -- 102
    local blendFunc = BlendFunc("One", "Zero") -- 103
    for ____, file in ipairs(Content:getAllFiles(folder)) do -- 104
        do -- 104
            repeat -- 104
                local ____switch22 = Path:getExt(file) -- 104
                local ____cond22 = ____switch22 == "png" or ____switch22 == "jpg" or ____switch22 == "dds" or ____switch22 == "pvr" or ____switch22 == "ktx" -- 104
                if ____cond22 then -- 104
                    do -- 104
                        local path = Path(folder, file) -- 107
                        Cache:unload(path) -- 108
                        local sp = Sprite(path) -- 109
                        if not sp then -- 109
                            goto __continue21 -- 110
                        end -- 110
                        sp.filter = "Point" -- 111
                        sp.blendFunc = blendFunc -- 112
                        sp.anchor = Vec2.zero -- 113
                        blocks[#blocks + 1] = { -- 114
                            w = sp.width + padding * 2, -- 115
                            h = sp.height + padding * 2, -- 116
                            sp = sp, -- 117
                            name = Path:getName(file) -- 118
                        } -- 118
                        Cache:unload(path) -- 120
                    end -- 120
                    break -- 120
                end -- 120
            until true -- 120
        end -- 120
        ::__continue21:: -- 120
    end -- 120
    if currentDisplay ~= nil then -- 120
        currentDisplay:removeFromParent() -- 124
    end -- 124
    if #blocks == 0 then -- 124
        currentDisplay = getLabel("No content.") -- 126
        return -- 127
    end -- 127
    local packer = Packer() -- 129
    packer:fit(blocks) -- 130
    if packer.root == nil then -- 130
        return -- 132
    end -- 132
    local ____packer_root_4 = packer.root -- 134
    local width = ____packer_root_4.w -- 134
    local height = ____packer_root_4.h -- 134
    local frame = Line( -- 135
        { -- 135
            Vec2.zero, -- 136
            Vec2(width, 0), -- 137
            Vec2(width, height), -- 138
            Vec2(0, height), -- 139
            Vec2.zero -- 140
        }, -- 140
        Color(1157627903) -- 141
    ) -- 141
    local node = Node() -- 143
    for ____, block in ipairs(blocks) do -- 144
        if block.fit and block.sp then -- 144
            local x = block.fit.x + padding -- 146
            local y = height - block.fit.y - block.h + padding -- 147
            local w = block.sp.width -- 148
            local h = block.sp.height -- 149
            frame:addChild(Line({ -- 150
                Vec2(x, y), -- 151
                Vec2(x + w, y), -- 152
                Vec2(x + w, y + h), -- 153
                Vec2(x, y + h), -- 154
                Vec2(x, y) -- 155
            })) -- 155
            block.sp.position = Vec2(x, y) -- 157
            node:addChild(block.sp) -- 158
        end -- 158
    end -- 158
    if not node.hasChildren then -- 158
        node:cleanup() -- 162
        return -- 163
    end -- 163
    local target = RenderTarget( -- 166
        math.tointeger(width), -- 166
        math.tointeger(height) -- 166
    ) -- 166
    target:renderWithClear( -- 167
        node, -- 167
        Color(0) -- 167
    ) -- 167
    node.visible = false -- 168
    node:cleanup() -- 169
    local outputName = Path:getName(folder) -- 171
    local xml = ("<A A=\"" .. Path:getName(folder)) .. ".png\">" -- 173
    for ____, block in ipairs(blocks) do -- 174
        do -- 174
            if block.fit == nil then -- 174
                goto __continue32 -- 175
            end -- 175
            xml = xml .. ((((((((("<B A=\"" .. block.name) .. "\" B=\"") .. tostring(block.fit.x + padding)) .. ",") .. tostring(block.fit.y + padding)) .. ",") .. tostring(block.w - padding * 2)) .. ",") .. tostring(block.h - padding * 2)) .. "\"/>" -- 176
        end -- 176
        ::__continue32:: -- 176
    end -- 176
    xml = xml .. "</A>" -- 178
    local textureFile = Path( -- 180
        Path:getPath(folder), -- 180
        outputName .. ".png" -- 180
    ) -- 180
    local clipFile = Path( -- 181
        Path:getPath(folder), -- 181
        outputName .. ".clip" -- 181
    ) -- 181
    thread(function() -- 182
        Content:saveAsync(clipFile, xml) -- 183
        target:saveAsync(textureFile) -- 184
    end) -- 182
    local displaySprite = Sprite(target.texture) -- 187
    displaySprite.filter = filterMode == 1 and "Anisotropic" or "Point" -- 188
    displaySprite:addChild(frame) -- 189
    displaySprite:runAction(Opacity(0.3, 0, 1)) -- 190
    currentDisplay = displaySprite -- 191
end -- 98
local length = Vec2(App.visualSize).length -- 194
local tapCount = 0 -- 195
toNode(React:createElement( -- 196
    "node", -- 196
    { -- 196
        order = 1, -- 196
        onTapBegan = function() -- 196
            tapCount = tapCount + 1 -- 199
        end, -- 198
        onTapEnded = function() -- 198
            tapCount = tapCount - 1 -- 202
        end, -- 201
        onTapMoved = function(touch) -- 201
            if currentDisplay then -- 201
                currentDisplay.position = currentDisplay.position:add(touch.delta) -- 206
            end -- 206
        end, -- 204
        onGesture = function(_center, fingers, deltaDist, _deltaAngle) -- 204
            if tapCount > 0 then -- 204
                return -- 210
            end -- 210
            if currentDisplay and tolua.cast(currentDisplay, "Sprite") and fingers == 2 then -- 210
                local ____currentDisplay_5 = currentDisplay -- 212
                local width = ____currentDisplay_5.width -- 212
                local height = ____currentDisplay_5.height -- 212
                local size = Vec2(width, height).length -- 213
                scaledSize = scaledSize + deltaDist * length * 10 / size -- 214
                scaledSize = math.max(0.5, scaledSize) -- 215
                scaledSize = math.min(5, scaledSize) -- 216
                local ____currentDisplay_7 = currentDisplay -- 217
                local ____scaledSize_6 = scaledSize -- 217
                currentDisplay.scaleY = ____scaledSize_6 -- 217
                ____currentDisplay_7.scaleX = ____scaledSize_6 -- 217
            end -- 217
        end -- 209
    } -- 209
)) -- 209
local current = 1 -- 223
local filterBuf = Buffer(20) -- 224
local windowFlags = { -- 225
    "NoDecoration", -- 226
    "NoSavedSettings", -- 227
    "NoFocusOnAppearing", -- 228
    "NoNav", -- 229
    "NoMove" -- 230
} -- 230
local inputTextFlags = {"AutoSelectAll"} -- 232
local filteredNames = clipNames -- 233
local filteredFolders = clipFolders -- 234
local scaleChecked = false -- 235
threadLoop(function() -- 236
    local ____App_visualSize_8 = App.visualSize -- 237
    local width = ____App_visualSize_8.width -- 237
    ImGui.SetNextWindowPos( -- 238
        Vec2(width - 10, 10), -- 238
        "Always", -- 238
        Vec2(1, 0) -- 238
    ) -- 238
    ImGui.SetNextWindowSize( -- 239
        Vec2(200, 0), -- 239
        "Always" -- 239
    ) -- 239
    ImGui.Begin( -- 240
        "Texture Packer", -- 240
        windowFlags, -- 240
        function() -- 240
            ImGui.Text("Texture Packer") -- 241
            ImGui.Separator() -- 242
            if ImGui.InputText("Filter", filterBuf, inputTextFlags) then -- 242
                local filterText = filterBuf.text -- 244
                if filterText == "" then -- 244
                    filteredNames = clipNames -- 246
                    filteredFolders = clipFolders -- 247
                    current = 1 -- 248
                    if #filteredFolders > 0 then -- 248
                        displayClips(filteredFolders[current]) -- 250
                    end -- 250
                else -- 250
                    local filtered = __TS__ArrayFilter( -- 253
                        __TS__ArrayMap( -- 253
                            clipNames, -- 253
                            function(____, n, i) return {n, clipFolders[i + 1]} end -- 253
                        ), -- 253
                        function(____, it, i) -- 253
                            local matched = string.match( -- 254
                                string.lower(it[1]), -- 254
                                filterText -- 254
                            ) -- 254
                            if matched ~= nil then -- 254
                                return true -- 256
                            end -- 256
                            return false -- 258
                        end -- 253
                    ) -- 253
                    filteredNames = __TS__ArrayMap( -- 260
                        filtered, -- 260
                        function(____, f) return f[1] end -- 260
                    ) -- 260
                    filteredFolders = __TS__ArrayMap( -- 261
                        filtered, -- 261
                        function(____, f) return f[2] end -- 261
                    ) -- 261
                    current = 1 -- 262
                    if #filteredFolders > 0 then -- 262
                        displayClips(filteredFolders[current]) -- 264
                    end -- 264
                end -- 264
            end -- 264
            if #filteredNames > 0 then -- 264
                local changed = false -- 269
                changed, current = ImGui.Combo("File", current, filteredNames) -- 270
                if changed then -- 270
                    displayClips(filteredFolders[current]) -- 272
                end -- 272
                if ImGui.Button("Generate") then -- 272
                    generateClips(filteredFolders[current]) -- 275
                end -- 275
            end -- 275
            ImGui.Separator() -- 278
            ImGui.Text("Display") -- 279
            local changed = false -- 280
            changed, filterMode = ImGui.RadioButton("Anisotropic", filterMode, 1) -- 281
            if changed then -- 281
                local sprite = tolua.cast(currentDisplay, "Sprite") -- 283
                if sprite then -- 283
                    sprite.filter = filterMode == 1 and "Anisotropic" or "Point" -- 285
                end -- 285
            end -- 285
            changed, filterMode = ImGui.RadioButton("Point", filterMode, 2) -- 288
            if changed then -- 288
                local sprite = tolua.cast(currentDisplay, "Sprite") -- 290
                if sprite then -- 290
                    sprite.filter = filterMode == 1 and "Anisotropic" or "Point" -- 292
                end -- 292
            end -- 292
            ImGui.Separator() -- 295
            changed = false -- 296
            changed, scaleChecked = ImGui.Checkbox("Scale Helper", scaleChecked) -- 297
            if changed then -- 297
                if scaleChecked then -- 297
                    ruler:show( -- 300
                        scaledSize, -- 300
                        0.5, -- 300
                        5, -- 300
                        1, -- 300
                        function(value) -- 300
                            scaledSize = value -- 301
                            if currentDisplay and tolua.cast(currentDisplay, "Sprite") then -- 301
                                local ____currentDisplay_10 = currentDisplay -- 303
                                local ____scaledSize_9 = scaledSize -- 303
                                currentDisplay.scaleY = ____scaledSize_9 -- 303
                                ____currentDisplay_10.scaleX = ____scaledSize_9 -- 303
                            end -- 303
                        end -- 300
                    ) -- 300
                else -- 300
                    ruler:hide() -- 307
                end -- 307
            end -- 307
        end -- 240
    ) -- 240
    return false -- 311
end) -- 236
return ____exports -- 236