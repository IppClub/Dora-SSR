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
local unzipDone = false -- 90
local function download() -- 92
    thread(function() -- 93
        progress = 0 -- 94
        local url, filename = table.unpack(getDownloadURL()) -- 95
        local targetFile = Path(Content.writablePath, ".download", filename) -- 96
        downloadTargetFile = targetFile -- 97
        Content:mkdir(Path(Content.writablePath, ".download")) -- 98
        downloadTitle = (zh and "正在下载：" or "Downloading: ") .. filename -- 99
        local success = HttpClient:downloadAsync( -- 100
            url, -- 101
            targetFile, -- 102
            30, -- 103
            function(current, total) -- 104
                if cancelDownload then -- 104
                    return true -- 106
                end -- 106
                progress = current / total -- 108
                return false -- 109
            end -- 104
        ) -- 104
        if success then -- 104
            downloadTitle = zh and "解压中：" .. filename or "Unziping: " .. filename -- 113
            local unzipPath = Path( -- 114
                Path:getPath(targetFile), -- 114
                Path:getName(targetFile) -- 114
            ) -- 114
            Content:remove(unzipPath) -- 115
            unzipDone = false -- 116
            targetUnzipPath = unzipPath -- 117
            if not Content:unzipAsync(targetFile, unzipPath) then -- 117
                Content:remove(unzipPath) -- 119
                targetUnzipPath = "" -- 120
                showPopup(zh and "解压失败" or "Failed to unzip ", zh and "无法解压文件：" .. filename or "Failed to unzip: " .. filename) -- 121
            else -- 121
                Content:remove(targetFile) -- 123
                unzipDone = true -- 124
                local pathForInstall = App.platform == "Windows" and unzipPath or Path(unzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 125
                App:install(pathForInstall) -- 126
            end -- 126
        else -- 126
            Content:remove(targetFile) -- 129
            downloadTitle = "" -- 130
            showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. url or "Failed to download from: " .. url) -- 131
        end -- 131
    end) -- 93
end -- 92
local ____App_0 = App -- 136
local themeColor = ____App_0.themeColor -- 136
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoNav", "NoMove"} -- 138
local messagePopupFlags = {"NoSavedSettings", "AlwaysAutoResize", "NoTitleBar"} -- 144
local inputTextFlags = {"AutoSelectAll"} -- 149
local proxyBuf = Buffer(100) -- 150
local function messagePopup() -- 152
    ImGui.Text(popupMessageTitle) -- 153
    ImGui.Separator() -- 154
    ImGui.PushTextWrapPos( -- 155
        300, -- 155
        function() -- 155
            ImGui.TextWrapped(popupMessage) -- 156
        end -- 155
    ) -- 155
    if ImGui.Button( -- 155
        zh and "确认" or "OK", -- 158
        Vec2(300, 30) -- 158
    ) then -- 158
        ImGui.CloseCurrentPopup() -- 159
    end -- 159
end -- 152
threadLoop(function() -- 163
    local ____App_visualSize_1 = App.visualSize -- 164
    local width = ____App_visualSize_1.width -- 164
    ImGui.SetNextWindowPos( -- 165
        Vec2(width - 10, 10), -- 165
        "Always", -- 165
        Vec2(1, 0) -- 165
    ) -- 165
    ImGui.SetNextWindowSize( -- 166
        Vec2(400, 0), -- 166
        "Always" -- 166
    ) -- 166
    ImGui.Begin( -- 167
        "Dora Updater", -- 167
        windowFlags, -- 167
        function() -- 167
            ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 168
            ImGui.SameLine() -- 169
            ImGui.TextDisabled("(?)") -- 170
            if ImGui.IsItemHovered() then -- 170
                ImGui.BeginTooltip(function() -- 172
                    ImGui.PushTextWrapPos( -- 173
                        300, -- 173
                        function() -- 173
                            ImGui.Text(zh and "使用该工具来检测和安装 Dora SSR 新版本的软件。" or "Use this tool to detect and install new versions of Dora SSR software.") -- 174
                        end -- 173
                    ) -- 173
                end) -- 172
            end -- 172
            ImGui.Separator() -- 178
            repeat -- 178
                local ____switch30 = App.platform -- 178
                local ____cond30 = ____switch30 == "Linux" -- 178
                if ____cond30 then -- 178
                    ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt-get 工具进行更新管理。详见官网的安装教程。" or "Please use apt-get to manage updates via the Dora SSR PPA. See the installation tutorial on the official website for details.") -- 181
                    return false -- 182
                end -- 182
                ____cond30 = ____cond30 or ____switch30 == "macOS" -- 182
                if ____cond30 then -- 182
                    ImGui.TextWrapped(zh and "请通过 Homebrew 工具进行更新管理。详见官网的安装教程。" or "Please use the Homebrew tool to manage updates. See the installation tutorial on the official website for details.") -- 184
                    return false -- 185
                end -- 185
            until true -- 185
            local _ = false -- 187
            _, currentProxy = ImGui.Combo(zh and "选择代理" or "Proxy Site", currentProxy, proxies) -- 188
            if latestVersion == "" then -- 188
                ImGui.InputText("##NewProxy", proxyBuf, inputTextFlags) -- 190
                ImGui.SameLine() -- 191
                if ImGui.Button(zh and "添加代理" or "Add Proxy") then -- 191
                    local proxyText = proxyBuf.text -- 193
                    if proxyText ~= "" then -- 193
                        proxies[#proxies + 1] = proxyText -- 195
                        proxyBuf.text = "" -- 196
                        currentProxy = #proxies -- 197
                    end -- 197
                end -- 197
            end -- 197
            ImGui.Separator() -- 201
            ImGui.TextColored(themeColor, zh and "当前版：" or "Current Version:") -- 202
            ImGui.SameLine() -- 203
            ImGui.Text(currentVersion) -- 204
            if latestVersion ~= "" then -- 204
                ImGui.TextColored(themeColor, zh and "最新版：" or "Latest Version:") -- 206
                ImGui.SameLine() -- 207
                ImGui.Text(latestVersion) -- 208
                if latestVersion ~= currentVersion then -- 208
                    ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update Available!") -- 210
                    if downloadTitle == "" then -- 210
                        if ImGui.Button(zh and "进行更新" or "Update") then -- 210
                            download() -- 213
                        end -- 213
                    end -- 213
                else -- 213
                    ImGui.TextColored(themeColor, zh and "已是最新版！" or "Already the latest version!") -- 217
                    if downloadTitle == "" then -- 217
                        if ImGui.Button(zh and "重新安装" or "Reinstall") then -- 217
                            download() -- 220
                        end -- 220
                    end -- 220
                end -- 220
            else -- 220
                if checking then -- 220
                    ImGui.BeginDisabled(function() -- 226
                        ImGui.Button(zh and "检查更新" or "Check Update") -- 227
                    end) -- 226
                else -- 226
                    if ImGui.Button(zh and "检查更新" or "Check Update") then -- 226
                        getLatestVersion() -- 231
                    end -- 231
                end -- 231
            end -- 231
            if unzipDone then -- 231
                if App.platform == "Android" then -- 231
                    if ImGui.Button(zh and "进行安装" or "Install") then -- 231
                        local pathForInstall = Path(targetUnzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 238
                        App:install(pathForInstall) -- 239
                    end -- 239
                end -- 239
            elseif downloadTitle ~= "" then -- 239
                ImGui.Separator() -- 243
                ImGui.Text(downloadTitle) -- 244
                ImGui.ProgressBar( -- 245
                    progress, -- 245
                    Vec2(-1, 30) -- 245
                ) -- 245
            end -- 245
            if popupShow then -- 245
                popupShow = false -- 248
                ImGui.OpenPopup("MessagePopup") -- 249
            end -- 249
            ImGui.BeginPopupModal("MessagePopup", messagePopupFlags, messagePopup) -- 251
        end -- 167
    ) -- 167
    return false -- 253
end) -- 163
local node = Node() -- 256
node:slot( -- 257
    "Cleanup", -- 257
    function() -- 257
        if 0 < progress and progress < 1 and downloadTargetFile ~= "" then -- 257
            cancelDownload = true -- 259
            Content:remove(downloadTargetFile) -- 260
        end -- 260
        if targetUnzipPath ~= "" then -- 260
            Content:remove(targetUnzipPath) -- 263
        end -- 263
    end -- 257
) -- 257
return ____exports -- 257