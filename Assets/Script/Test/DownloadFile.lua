-- [ts]: DownloadFile.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local HttpClient = ____Dora.HttpClient -- 1
local Path = ____Dora.Path -- 1
local thread = ____Dora.thread -- 1
local HttpServer = ____Dora.HttpServer -- 1
local Content = ____Dora.Content -- 1
local loop = ____Dora.loop -- 1
local App = ____Dora.App -- 1
local Vec2 = ____Dora.Vec2 -- 1
local Buffer = ____Dora.Buffer -- 1
local Node = ____Dora.Node -- 1
local ImGui = require("ImGui") -- 2
local url = ("http://" .. HttpServer.localIP) .. ":8866/Doc/zh-Hans/welcome.md" -- 5
local targetFile = Path(Content.writablePath, ".download", "testDownloadFile") -- 6
local cancelDownload = false -- 7
local progress = 0 -- 8
local function download() -- 10
    thread(function() -- 11
        progress = 0 -- 12
        Content:mkdir(Path(Content.writablePath, ".download")) -- 13
        local success = HttpClient:downloadAsync( -- 14
            url, -- 15
            targetFile, -- 16
            10, -- 17
            function(current, total) -- 18
                if cancelDownload then -- 18
                    return true -- 20
                end -- 20
                if total > 1024 * 1024 then -- 20
                    print("file larger than 1MB, canceled") -- 23
                    return true -- 24
                end -- 24
                progress = current / total -- 26
                return false -- 27
            end -- 18
        ) -- 18
        if success then -- 18
            print("Downloaded: " .. url) -- 31
        else -- 31
            print("Download failed: " .. url) -- 33
        end -- 33
        if Content:remove(targetFile) then -- 33
            print(targetFile .. " is deleted") -- 36
        end -- 36
    end) -- 11
end -- 10
download() -- 41
local downloadFlags = { -- 43
    "NoResize", -- 44
    "NoSavedSettings", -- 45
    "NoTitleBar", -- 46
    "NoMove", -- 47
    "AlwaysAutoResize" -- 48
} -- 48
local buffer = Buffer(256) -- 50
local node = Node() -- 51
node:onCleanup(function() -- 52
    cancelDownload = true -- 53
    if Content:remove(targetFile) then -- 53
        print(targetFile .. " is deleted") -- 55
    end -- 55
end) -- 52
node:schedule(loop(function() -- 58
    local ____App_visualSize_0 = App.visualSize -- 59
    local width = ____App_visualSize_0.width -- 59
    local height = ____App_visualSize_0.height -- 59
    ImGui.SetNextWindowPos(Vec2(width / 2 - 180, height / 2 - 100)) -- 60
    ImGui.SetNextWindowSize( -- 61
        Vec2(300, 100), -- 61
        "FirstUseEver" -- 61
    ) -- 61
    ImGui.Begin( -- 62
        "Download", -- 62
        downloadFlags, -- 62
        function() -- 62
            ImGui.SameLine() -- 63
            ImGui.TextWrapped(url) -- 64
            ImGui.ProgressBar( -- 65
                progress, -- 65
                Vec2(-1, 30) -- 65
            ) -- 65
            ImGui.Separator() -- 66
            ImGui.Text("URL to download") -- 67
            ImGui.InputText("URL", buffer) -- 68
            if ImGui.Button("Download") then -- 68
                url = buffer.text -- 70
                download() -- 71
            end -- 71
        end -- 62
    ) -- 62
    return false -- 74
end)) -- 58
return ____exports -- 58