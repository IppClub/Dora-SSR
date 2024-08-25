-- [ts]: SelfUpdater.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 9
local HttpClient = ____Dora.HttpClient -- 9
local json = ____Dora.json -- 9
local thread = ____Dora.thread -- 9
local App = ____Dora.App -- 9
local threadLoop = ____Dora.threadLoop -- 9
local Vec2 = ____Dora.Vec2 -- 9
local Buffer = ____Dora.Buffer -- 9
local Path = ____Dora.Path -- 9
local Content = ____Dora.Content -- 9
local Node = ____Dora.Node -- 9
local ImGui = require("ImGui") -- 11
local zh = false -- 13
do -- 13
    local res = string.match(App.locale, "^zh") -- 15
    zh = res ~= nil and ImGui.IsFontLoaded() -- 16
end -- 16
local major, minor, patch, _revision = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 19
local currentVersion = (((("v" .. major) .. ".") .. minor) .. ".") .. patch -- 20
local currentProxy = 1 -- 22
local proxies = zh and ({"kkgithub.com", "github.com"}) or ({"github.com", "kkgithub.com"}) -- 23
local popupMessageTitle = "" -- 35
local popupMessage = "" -- 36
local popupShow = false -- 37
local function showPopup(title, msg) -- 39
    popupMessageTitle = title -- 40
    popupMessage = msg -- 41
    popupShow = true -- 42
end -- 39
local latestVersion = "" -- 45
local checking = false -- 46
local function getLatestVersion() -- 47
    checking = true -- 48
    latestVersion = "" -- 49
    thread(function() -- 50
        local proxy = proxies[currentProxy] -- 51
        local url = ("https://api." .. proxy) .. "/repos/IppClub/Dora-SSR/releases/latest" -- 52
        local res = HttpClient:getAsync(url) -- 53
        local success = false -- 54
        if res then -- 54
            local info = json.load(res) -- 56
            if info then -- 56
                latestVersion = info.tag_name -- 58
                success = true -- 59
            end -- 59
        end -- 59
        if not success then -- 59
            showPopup(zh and "获取更新失败" or "Failed to check", zh and "无法读取仓库地址，请检查网络情况。" or "Unable to read the repo URL, please check the network status.") -- 63
        end -- 63
        checking = false -- 65
    end) -- 50
end -- 47
local function getDownloadURL() -- 69
    repeat -- 69
        local ____switch10 = App.platform -- 69
        local ____cond10 = ____switch10 == "Android" -- 69
        if ____cond10 then -- 69
            do -- 69
                local filename = ("dora-ssr-" .. latestVersion) .. "-android.zip" -- 72
                return {(((("https://" .. proxies[currentProxy]) .. "/IppClub/Dora-SSR/releases/download/") .. latestVersion) .. "/") .. filename, filename} -- 73
            end -- 73
        end -- 73
        ____cond10 = ____cond10 or ____switch10 == "Windows" -- 73
        if ____cond10 then -- 73
            do -- 73
                local filename = ("dora-ssr-" .. latestVersion) .. "-windows-x86.zip" -- 76
                return {(((("https://" .. proxies[currentProxy]) .. "/IppClub/Dora-SSR/releases/download/") .. latestVersion) .. "/") .. filename, filename} -- 77
            end -- 77
        end -- 77
        do -- 77
            do -- 77
                error("invalid platform") -- 80
            end -- 80
        end -- 80
    until true -- 80
end -- 69
local cancelDownload = false -- 85
local downloadTitle = "" -- 86
local progress = 0 -- 87
local downloadTargetFile = "" -- 88
local targetUnzipPath = "" -- 89
local function download() -- 91
    thread(function() -- 92
        progress = 0 -- 93
        local url, filename = table.unpack(getDownloadURL()) -- 94
        local targetFile = Path(Content.writablePath, ".download", filename) -- 95
        downloadTargetFile = targetFile -- 96
        Content:mkdir(Path(Content.writablePath, ".download")) -- 97
        downloadTitle = (zh and "正在下载：" or "Downloading: ") .. filename -- 98
        local success = HttpClient:downloadAsync( -- 99
            url, -- 100
            targetFile, -- 101
            30, -- 102
            function(current, total) -- 103
                if cancelDownload then -- 103
                    return true -- 105
                end -- 105
                progress = current / total -- 107
                return false -- 108
            end -- 103
        ) -- 103
        if success then -- 103
            downloadTitle = zh and "解压中：" .. filename or "Unziping: " .. filename -- 112
            local unzipPath = Path( -- 113
                Path:getPath(targetFile), -- 113
                Path:getName(targetFile) -- 113
            ) -- 113
            targetUnzipPath = unzipPath -- 114
            Content:remove(unzipPath) -- 115
            if not Content:unzipAsync(targetFile, unzipPath) then -- 115
                Content:remove(unzipPath) -- 117
                targetUnzipPath = "" -- 118
                showPopup(zh and "解压失败" or "Failed to unzip ", zh and "无法解压文件：" .. filename or "Failed to unzip: " .. filename) -- 119
            else -- 119
                Content:remove(targetFile) -- 121
                local pathForInstall = App.platform == "Windows" and unzipPath or Path(unzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 122
                App:install(pathForInstall) -- 123
            end -- 123
        else -- 123
            Content:remove(targetFile) -- 126
            downloadTitle = "" -- 127
            showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. url or "Failed to download from: " .. url) -- 128
        end -- 128
    end) -- 92
end -- 91
local ____App_0 = App -- 133
local themeColor = ____App_0.themeColor -- 133
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoNav", "NoMove"} -- 135
local messagePopupFlags = {"NoSavedSettings", "AlwaysAutoResize", "NoTitleBar"} -- 141
local inputTextFlags = {"AutoSelectAll"} -- 146
local proxyBuf = Buffer(100) -- 147
local function messagePopup() -- 149
    ImGui.Text(popupMessageTitle) -- 150
    ImGui.Separator() -- 151
    ImGui.PushTextWrapPos( -- 152
        300, -- 152
        function() -- 152
            ImGui.TextWrapped(popupMessage) -- 153
        end -- 152
    ) -- 152
    if ImGui.Button( -- 152
        zh and "确认" or "OK", -- 155
        Vec2(300, 30) -- 155
    ) then -- 155
        ImGui.CloseCurrentPopup() -- 156
    end -- 156
end -- 149
threadLoop(function() -- 160
    local ____App_visualSize_1 = App.visualSize -- 161
    local width = ____App_visualSize_1.width -- 161
    ImGui.SetNextWindowPos( -- 162
        Vec2(width - 10, 10), -- 162
        "Always", -- 162
        Vec2(1, 0) -- 162
    ) -- 162
    ImGui.SetNextWindowSize( -- 163
        Vec2(400, 0), -- 163
        "Always" -- 163
    ) -- 163
    ImGui.Begin( -- 164
        "Dora Updater", -- 164
        windowFlags, -- 164
        function() -- 164
            ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 165
            ImGui.SameLine() -- 166
            ImGui.TextDisabled("(?)") -- 167
            if ImGui.IsItemHovered() then -- 167
                ImGui.BeginTooltip(function() -- 169
                    ImGui.PushTextWrapPos( -- 170
                        300, -- 170
                        function() -- 170
                            ImGui.Text(zh and "使用该工具来检测和安装 Dora SSR 新版本的软件。" or "Use this tool to detect and install new versions of Dora SSR software.") -- 171
                        end -- 170
                    ) -- 170
                end) -- 169
            end -- 169
            ImGui.Separator() -- 175
            repeat -- 175
                local ____switch30 = App.platform -- 175
                local ____cond30 = ____switch30 == "Linux" -- 175
                if ____cond30 then -- 175
                    ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt-get 工具进行更新管理。详见官网的安装教程。" or "Please use apt-get to manage updates via the Dora SSR PPA. See the installation tutorial on the official website for details.") -- 178
                    return false -- 179
                end -- 179
                ____cond30 = ____cond30 or ____switch30 == "macOS" -- 179
                if ____cond30 then -- 179
                    ImGui.TextWrapped(zh and "请通过 Homebrew 工具进行更新管理。详见官网的安装教程。" or "Please use the homebrew tool to manage updates. See the installation tutorial on the official website for details.") -- 181
                    return false -- 182
                end -- 182
            until true -- 182
            local _ = false -- 184
            _, currentProxy = ImGui.Combo(zh and "选择代理" or "Proxy Site", currentProxy, proxies) -- 185
            if latestVersion == "" then -- 185
                ImGui.InputText("##NewProxy", proxyBuf, inputTextFlags) -- 187
                ImGui.SameLine() -- 188
                if ImGui.Button(zh and "添加代理" or "Add Proxy") then -- 188
                    local proxyText = proxyBuf.text -- 190
                    if proxyText ~= "" then -- 190
                        proxies[#proxies + 1] = proxyText -- 192
                        proxyBuf.text = "" -- 193
                        currentProxy = #proxies -- 194
                    end -- 194
                end -- 194
            end -- 194
            ImGui.Separator() -- 198
            ImGui.TextColored(themeColor, zh and "当前版：" or "Current Version:") -- 199
            ImGui.SameLine() -- 200
            ImGui.Text(currentVersion) -- 201
            if latestVersion ~= "" then -- 201
                ImGui.TextColored(themeColor, zh and "最新版：" or "Latest Version:") -- 203
                ImGui.SameLine() -- 204
                ImGui.Text(latestVersion) -- 205
                if latestVersion ~= currentVersion then -- 205
                    ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update Available!") -- 207
                    if downloadTitle == "" then -- 207
                        if ImGui.Button(zh and "进行更新" or "Update") then -- 207
                            download() -- 210
                        end -- 210
                    end -- 210
                else -- 210
                    ImGui.TextColored(themeColor, zh and "已是最新版！" or "Already the latest version!") -- 214
                    if downloadTitle == "" then -- 214
                        if ImGui.Button(zh and "重新安装" or "Reinstall") then -- 214
                            download() -- 217
                        end -- 217
                    end -- 217
                end -- 217
            else -- 217
                if checking then -- 217
                    ImGui.BeginDisabled(function() -- 223
                        ImGui.Button(zh and "检查更新" or "Check Update") -- 224
                    end) -- 223
                else -- 223
                    if ImGui.Button(zh and "检查更新" or "Check Update") then -- 223
                        getLatestVersion() -- 228
                    end -- 228
                end -- 228
            end -- 228
            if targetUnzipPath == "" then -- 228
                if downloadTitle ~= "" then -- 228
                    ImGui.Separator() -- 234
                    ImGui.Text(downloadTitle) -- 235
                    ImGui.ProgressBar( -- 236
                        progress, -- 236
                        Vec2(-1, 30) -- 236
                    ) -- 236
                end -- 236
            elseif App.platform == "Android" then -- 236
                if ImGui.Button(zh and "进行安装" or "Install") then -- 236
                    local pathForInstall = Path(targetUnzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 240
                    App:install(pathForInstall) -- 241
                end -- 241
            end -- 241
            if popupShow then -- 241
                popupShow = false -- 245
                ImGui.OpenPopup("MessagePopup") -- 246
            end -- 246
            ImGui.BeginPopupModal("MessagePopup", messagePopupFlags, messagePopup) -- 248
        end -- 164
    ) -- 164
    return false -- 250
end) -- 160
local node = Node() -- 253
node:slot( -- 254
    "Cleanup", -- 254
    function() -- 254
        if 0 < progress and progress < 1 and downloadTargetFile ~= "" then -- 254
            cancelDownload = true -- 256
            Content:remove(downloadTargetFile) -- 257
        end -- 257
        if targetUnzipPath ~= "" then -- 257
            Content:remove(targetUnzipPath) -- 260
        end -- 260
    end -- 254
) -- 254
return ____exports -- 254