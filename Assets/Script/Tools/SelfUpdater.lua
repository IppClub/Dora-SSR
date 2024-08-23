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
        Content:mkdir(Path(Content.writablePath, ".download")) -- 96
        downloadTitle = (zh and "正在下载：" or "Downloading: ") .. filename -- 97
        local success = HttpClient:downloadAsync( -- 98
            url, -- 99
            targetFile, -- 100
            30, -- 101
            function(current, total) -- 102
                if cancelDownload then -- 102
                    return true -- 104
                end -- 104
                progress = current / total -- 106
                return false -- 107
            end -- 102
        ) -- 102
        if success then -- 102
            downloadTitle = zh and "解压中：" .. filename or "Unziping: " .. filename -- 111
            local unzipPath = App.platform == "Windows" and Path( -- 112
                Path:getPath(targetFile), -- 112
                Path:getName(targetFile) -- 112
            ) or Path:getPath(targetFile) -- 112
            targetUnzipPath = unzipPath -- 113
            if not Content:unzipAsync(targetFile, unzipPath) then -- 113
                Content:remove(unzipPath) -- 115
                targetUnzipPath = "" -- 116
                showPopup(zh and "解压失败" or "Failed to unzip ", zh and "无法解压文件：" .. filename or "Failed to unzip: " .. filename) -- 117
            else -- 117
                targetUnzipPath = "" -- 119
                Content:remove(targetFile) -- 120
                local pathForInstall = App.platform == "Windows" and unzipPath or Path(unzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 121
                App:install(pathForInstall) -- 122
            end -- 122
        else -- 122
            Content:remove(targetFile) -- 125
            downloadTitle = "" -- 126
            showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. url or "Failed to download from: " .. url) -- 127
        end -- 127
    end) -- 92
end -- 91
local ____App_0 = App -- 132
local themeColor = ____App_0.themeColor -- 132
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoNav", "NoMove"} -- 134
local messagePopupFlags = {"NoSavedSettings", "AlwaysAutoResize", "NoTitleBar"} -- 140
local inputTextFlags = {"AutoSelectAll"} -- 145
local proxyBuf = Buffer(100) -- 146
local function messagePopup() -- 148
    ImGui.Text(popupMessageTitle) -- 149
    ImGui.Separator() -- 150
    ImGui.PushTextWrapPos( -- 151
        300, -- 151
        function() -- 151
            ImGui.TextWrapped(popupMessage) -- 152
        end -- 151
    ) -- 151
    if ImGui.Button( -- 151
        zh and "确认" or "OK", -- 154
        Vec2(300, 30) -- 154
    ) then -- 154
        ImGui.CloseCurrentPopup() -- 155
    end -- 155
end -- 148
threadLoop(function() -- 159
    local ____App_visualSize_1 = App.visualSize -- 160
    local width = ____App_visualSize_1.width -- 160
    ImGui.SetNextWindowPos( -- 161
        Vec2(width - 10, 10), -- 161
        "Always", -- 161
        Vec2(1, 0) -- 161
    ) -- 161
    ImGui.SetNextWindowSize( -- 162
        Vec2(400, 0), -- 162
        "Always" -- 162
    ) -- 162
    ImGui.Begin( -- 163
        "Dora Updater", -- 163
        windowFlags, -- 163
        function() -- 163
            ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 164
            ImGui.SameLine() -- 165
            ImGui.TextDisabled("(?)") -- 166
            if ImGui.IsItemHovered() then -- 166
                ImGui.BeginTooltip(function() -- 168
                    ImGui.PushTextWrapPos( -- 169
                        300, -- 169
                        function() -- 169
                            ImGui.Text(zh and "使用该工具来检测和安装 Dora SSR 新版本的软件。" or "Use this tool to detect and install new versions of Dora SSR software.") -- 170
                        end -- 169
                    ) -- 169
                end) -- 168
            end -- 168
            ImGui.Separator() -- 174
            repeat -- 174
                local ____switch30 = App.platform -- 174
                local ____cond30 = ____switch30 == "Linux" -- 174
                if ____cond30 then -- 174
                    ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt-get 工具进行更新管理。详见官网的安装教程。" or "Please use apt-get to manage updates via the Dora SSR PPA. See the installation tutorial on the official website for details.") -- 177
                    return false -- 178
                end -- 178
                ____cond30 = ____cond30 or ____switch30 == "macOS" -- 178
                if ____cond30 then -- 178
                    ImGui.TextWrapped(zh and "请通过 Homebrew 工具进行更新管理。详见官网的安装教程。" or "Please use the homebrew tool to manage updates. See the installation tutorial on the official website for details.") -- 180
                    return false -- 181
                end -- 181
            until true -- 181
            local _ = false -- 183
            _, currentProxy = ImGui.Combo(zh and "选择代理" or "Proxy Site", currentProxy, proxies) -- 184
            if latestVersion == "" then -- 184
                ImGui.InputText("##NewProxy", proxyBuf, inputTextFlags) -- 186
                ImGui.SameLine() -- 187
                if ImGui.Button(zh and "添加代理" or "Add Proxy") then -- 187
                    local proxyText = proxyBuf.text -- 189
                    if proxyText ~= "" then -- 189
                        proxies[#proxies + 1] = proxyText -- 191
                        proxyBuf.text = "" -- 192
                        currentProxy = #proxies -- 193
                    end -- 193
                end -- 193
            end -- 193
            ImGui.Separator() -- 197
            ImGui.TextColored(themeColor, zh and "当前版：" or "Current Version:") -- 198
            ImGui.SameLine() -- 199
            ImGui.Text(currentVersion) -- 200
            if latestVersion ~= "" then -- 200
                ImGui.TextColored(themeColor, zh and "最新版：" or "Latest Version:") -- 202
                ImGui.SameLine() -- 203
                ImGui.Text(latestVersion) -- 204
                if latestVersion ~= currentVersion then -- 204
                    ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update Available!") -- 206
                    if downloadTitle == "" then -- 206
                        if ImGui.Button(zh and "进行更新" or "Update") then -- 206
                            download() -- 209
                        end -- 209
                    end -- 209
                else -- 209
                    ImGui.TextColored(themeColor, zh and "已是最新版！" or "Already the latest version!") -- 213
                    if downloadTitle == "" then -- 213
                        if ImGui.Button(zh and "重新安装" or "Reinstall") then -- 213
                            download() -- 216
                        end -- 216
                    end -- 216
                end -- 216
            else -- 216
                if checking then -- 216
                    ImGui.BeginDisabled(function() -- 222
                        ImGui.Button(zh and "检查更新" or "Check Update") -- 223
                    end) -- 222
                else -- 222
                    if ImGui.Button(zh and "检查更新" or "Check Update") then -- 222
                        getLatestVersion() -- 227
                    end -- 227
                end -- 227
            end -- 227
            if downloadTitle ~= "" then -- 227
                ImGui.Separator() -- 232
                ImGui.Text(downloadTitle) -- 233
                ImGui.ProgressBar( -- 234
                    progress, -- 234
                    Vec2(-1, 30) -- 234
                ) -- 234
            end -- 234
            if popupShow then -- 234
                popupShow = false -- 237
                ImGui.OpenPopup("MessagePopup") -- 238
            end -- 238
            ImGui.BeginPopupModal("MessagePopup", messagePopupFlags, messagePopup) -- 240
        end -- 163
    ) -- 163
    return false -- 242
end) -- 159
local node = Node() -- 245
node:slot( -- 246
    "Cleanup", -- 246
    function() -- 246
        if 0 < progress and progress < 1 then -- 246
            cancelDownload = true -- 248
            Content:remove(downloadTargetFile) -- 249
        end -- 249
        if targetUnzipPath ~= "" then -- 249
            Content:remove(targetUnzipPath) -- 252
        end -- 252
    end -- 246
) -- 246
return ____exports -- 246