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
            function(current, total) -- 17
                if cancelDownload then -- 17
                    return true -- 19
                end -- 19
                if total > 1024 * 1024 then -- 19
                    print("file larger than 1MB, canceled") -- 22
                    return true -- 23
                end -- 23
                progress = current / total -- 25
                return false -- 26
            end -- 17
        ) -- 17
        if success then -- 17
            print("Downloaded: " .. url) -- 30
        else -- 30
            print("Download failed: " .. url) -- 32
        end -- 32
        if Content:remove(targetFile) then -- 32
            print(targetFile .. " is deleted") -- 35
        end -- 35
    end) -- 11
end -- 10
download() -- 40
local downloadFlags = { -- 42
    "NoResize", -- 43
    "NoSavedSettings", -- 44
    "NoTitleBar", -- 45
    "NoMove", -- 46
    "AlwaysAutoResize" -- 47
} -- 47
local buffer = Buffer(256) -- 49
local node = Node() -- 50
node:slot( -- 51
    "Cleanup", -- 51
    function() -- 51
        cancelDownload = true -- 52
        if Content:remove(targetFile) then -- 52
            print(targetFile .. " is deleted") -- 54
        end -- 54
    end -- 51
) -- 51
node:schedule(loop(function() -- 57
    local ____App_visualSize_0 = App.visualSize -- 58
    local width = ____App_visualSize_0.width -- 58
    local height = ____App_visualSize_0.height -- 58
    ImGui.SetNextWindowPos(Vec2(width / 2 - 180, height / 2 - 100)) -- 59
    ImGui.SetNextWindowSize( -- 60
        Vec2(300, 100), -- 60
        "FirstUseEver" -- 60
    ) -- 60
    ImGui.Begin( -- 61
        "Download", -- 61
        downloadFlags, -- 61
        function() -- 61
            ImGui.SameLine() -- 62
            ImGui.TextWrapped(url) -- 63
            ImGui.ProgressBar( -- 64
                progress, -- 64
                Vec2(-1, 30) -- 64
            ) -- 64
            ImGui.Separator() -- 65
            ImGui.Text("URL to download") -- 66
            ImGui.InputText("URL", buffer) -- 67
            if ImGui.Button("Download") then -- 67
                url = buffer.text -- 69
                download() -- 70
            end -- 70
        end -- 61
    ) -- 61
    return false -- 73
end)) -- 57
return ____exports -- 57