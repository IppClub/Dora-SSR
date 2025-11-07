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
	zh = res ~= nil -- 16
end -- 16
local major, minor, patch, _revision = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 19
local currentVersion = (((("v" .. major) .. ".") .. minor) .. ".") .. patch -- 20
local currentProxy = 1 -- 22
local proxies = zh and ({"OpenAtom", "github.com"}) or ({"github.com", "OpenAtom"}) -- 23
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
		local url = "https://api.github.com/repos/IppClub/Dora-SSR/releases/latest" -- 51
		local res = HttpClient:getAsync(url) -- 52
		local success = false -- 53
		if res then -- 53
			local info = (json.decode(res)) -- 55
			if info then -- 55
				latestVersion = info.tag_name -- 57
				success = true -- 58
			end -- 58
		end -- 58
		if not success then -- 58
			showPopup(zh and "获取更新失败" or "Failed to check", zh and "无法读取仓库地址，请检查网络情况。" or "Unable to read the repo URL, please check the network status.") -- 62
		end -- 62
		checking = false -- 64
	end) -- 50
end -- 47
local function getDownloadURL() -- 68
	repeat -- 68
		local ____switch10 = App.platform -- 68
		local ____cond10 = ____switch10 == "Android" -- 68
		if ____cond10 then -- 68
			do -- 68
				local filename = ("dora-ssr-" .. latestVersion) .. "-android.zip" -- 71
				local proxy = proxies[currentProxy] -- 72
				if proxy == "OpenAtom" then -- 72
					return {"http://39.155.148.157:8866/zips/" .. filename, filename} -- 74
				end -- 74
				return {(((("https://" .. proxy) .. "/IppClub/Dora-SSR/releases/download/") .. latestVersion) .. "/") .. filename, filename} -- 76
			end -- 76
		end -- 76
		____cond10 = ____cond10 or ____switch10 == "Windows" -- 76
		if ____cond10 then -- 76
			do -- 76
				local filename = ("dora-ssr-" .. latestVersion) .. "-windows-x86.zip" -- 79
				local proxy = proxies[currentProxy] -- 80
				if proxy == "OpenAtom" then -- 80
					return {"http://39.155.148.157:8866/zips/" .. filename, filename} -- 82
				end -- 82
				return {(((("https://" .. proxy) .. "/IppClub/Dora-SSR/releases/download/") .. latestVersion) .. "/") .. filename, filename} -- 84
			end -- 84
		end -- 84
		do -- 84
			do -- 84
				error("invalid platform") -- 87
			end -- 87
		end -- 87
	until true -- 87
end -- 68
local cancelDownload = false -- 92
local downloadTitle = "" -- 93
local progress = 0 -- 94
local downloadTargetFile = "" -- 95
local targetUnzipPath = "" -- 96
local unzipDone = false -- 97
local function download() -- 99
	thread(function() -- 100
		progress = 0 -- 101
		local url, filename = table.unpack( -- 102
			getDownloadURL(), -- 102
			1, -- 102
			2 -- 102
		) -- 102
		local targetFile = Path(Content.writablePath, ".download", filename) -- 103
		downloadTargetFile = targetFile -- 104
		Content:mkdir(Path(Content.writablePath, ".download")) -- 105
		downloadTitle = (zh and "正在下载：" or "Downloading: ") .. filename -- 106
		local success = HttpClient:downloadAsync( -- 107
			url, -- 108
			targetFile, -- 109
			30, -- 110
			function(current, total) -- 111
				if cancelDownload then -- 111
					return true -- 113
				end -- 113
				progress = current / total -- 115
				return false -- 116
			end -- 111
		) -- 111
		if success then -- 111
			downloadTitle = zh and "解压中：" .. filename or "Unziping: " .. filename -- 120
			local unzipPath = Path( -- 121
				Path:getPath(targetFile), -- 121
				Path:getName(targetFile) -- 121
			) -- 121
			Content:remove(unzipPath) -- 122
			unzipDone = false -- 123
			targetUnzipPath = unzipPath -- 124
			if not Content:unzipAsync(targetFile, unzipPath) then -- 124
				Content:remove(unzipPath) -- 126
				targetUnzipPath = "" -- 127
				showPopup(zh and "解压失败" or "Failed to unzip ", zh and "无法解压文件：" .. filename or "Failed to unzip: " .. filename) -- 128
			else -- 128
				Content:remove(targetFile) -- 130
				unzipDone = true -- 131
				local pathForInstall = App.platform == "Windows" and unzipPath or Path(unzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 132
				App:install(pathForInstall) -- 133
			end -- 133
		else -- 133
			Content:remove(targetFile) -- 136
			downloadTitle = "" -- 137
			showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. url or "Failed to download from: " .. url) -- 138
		end -- 138
	end) -- 100
end -- 99
local ____App_0 = App -- 143
local themeColor = ____App_0.themeColor -- 143
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoNav", "NoMove"} -- 145
local messagePopupFlags = {"NoSavedSettings", "AlwaysAutoResize", "NoTitleBar"} -- 151
local inputTextFlags = {"AutoSelectAll"} -- 156
local proxyBuf = Buffer(100) -- 157
local function messagePopup() -- 159
	ImGui.Text(popupMessageTitle) -- 160
	ImGui.Separator() -- 161
	ImGui.PushTextWrapPos( -- 162
		300, -- 162
		function() -- 162
			ImGui.TextWrapped(popupMessage) -- 163
		end -- 162
	) -- 162
	if ImGui.Button( -- 162
		zh and "确认" or "OK", -- 165
		Vec2(300, 30) -- 165
	) then -- 165
		ImGui.CloseCurrentPopup() -- 166
	end -- 166
end -- 159
threadLoop(function() -- 170
	local ____App_visualSize_1 = App.visualSize -- 171
	local width = ____App_visualSize_1.width -- 171
	ImGui.SetNextWindowPos( -- 172
		Vec2(width - 10, 10), -- 172
		"Always", -- 172
		Vec2(1, 0) -- 172
	) -- 172
	ImGui.SetNextWindowSize( -- 173
		Vec2(400, 0), -- 173
		"Always" -- 173
	) -- 173
	ImGui.Begin( -- 174
		"Dora Updater", -- 174
		windowFlags, -- 174
		function() -- 174
			ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 175
			ImGui.SameLine() -- 176
			ImGui.TextDisabled("(?)") -- 177
			if ImGui.IsItemHovered() then -- 177
				ImGui.BeginTooltip(function() -- 179
					ImGui.PushTextWrapPos( -- 180
						300, -- 180
						function() -- 180
							ImGui.Text(zh and "使用该工具来检测和安装 Dora SSR 新版本的软件。" or "Use this tool to detect and install new versions of Dora SSR software.") -- 181
						end -- 180
					) -- 180
				end) -- 179
			end -- 179
			ImGui.Separator() -- 185
			repeat -- 185
				local ____switch32 = App.platform -- 185
				local ____cond32 = ____switch32 == "Linux" -- 185
				if ____cond32 then -- 185
					ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt-get 工具进行更新管理。详见官网的安装教程。" or "Please use apt-get to manage updates via the Dora SSR PPA. See the installation tutorial on the official website for details.") -- 188
					return false -- 189
				end -- 189
				____cond32 = ____cond32 or ____switch32 == "macOS" -- 189
				if ____cond32 then -- 189
					ImGui.TextWrapped(zh and "请通过 Homebrew 工具进行更新管理。详见官网的安装教程。" or "Please use the Homebrew tool to manage updates. See the installation tutorial on the official website for details.") -- 191
					return false -- 192
				end -- 192
			until true -- 192
			local _ = false -- 194
			_, currentProxy = ImGui.Combo(zh and "选择代理" or "Proxy Site", currentProxy, proxies) -- 195
			if latestVersion == "" then -- 195
				ImGui.InputText("##NewProxy", proxyBuf, inputTextFlags) -- 197
				ImGui.SameLine() -- 198
				if ImGui.Button(zh and "添加代理" or "Add Proxy") then -- 198
					local proxyText = proxyBuf.text -- 200
					if proxyText ~= "" then -- 200
						proxies[#proxies + 1] = proxyText -- 202
						proxyBuf.text = "" -- 203
						currentProxy = #proxies -- 204
					end -- 204
				end -- 204
			end -- 204
			ImGui.Separator() -- 208
			ImGui.TextColored(themeColor, zh and "当前版：" or "Current Version:") -- 209
			ImGui.SameLine() -- 210
			ImGui.Text(currentVersion) -- 211
			if latestVersion ~= "" then -- 211
				ImGui.TextColored(themeColor, zh and "最新版：" or "Latest Version:") -- 213
				ImGui.SameLine() -- 214
				ImGui.Text(latestVersion) -- 215
				if latestVersion ~= currentVersion then -- 215
					ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update Available!") -- 217
					if downloadTitle == "" then -- 217
						if ImGui.Button(zh and "进行更新" or "Update") then -- 217
							download() -- 220
						end -- 220
					end -- 220
				else -- 220
					ImGui.TextColored(themeColor, zh and "已是最新版！" or "Already the latest version!") -- 224
					if downloadTitle == "" then -- 224
						if ImGui.Button(zh and "重新安装" or "Reinstall") then -- 224
							download() -- 227
						end -- 227
					end -- 227
				end -- 227
			else -- 227
				if checking then -- 227
					ImGui.BeginDisabled(function() -- 233
						ImGui.Button(zh and "检查更新" or "Check Update") -- 234
					end) -- 233
				else -- 233
					if ImGui.Button(zh and "检查更新" or "Check Update") then -- 233
						getLatestVersion() -- 238
					end -- 238
				end -- 238
			end -- 238
			if unzipDone then -- 238
				if App.platform == "Android" then -- 238
					if ImGui.Button(zh and "进行安装" or "Install") then -- 238
						local pathForInstall = Path(targetUnzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 245
						App:install(pathForInstall) -- 246
					end -- 246
				end -- 246
			elseif downloadTitle ~= "" then -- 246
				ImGui.Separator() -- 250
				ImGui.Text(downloadTitle) -- 251
				ImGui.ProgressBar( -- 252
					progress, -- 252
					Vec2(-1, 30) -- 252
				) -- 252
			end -- 252
			if popupShow then -- 252
				popupShow = false -- 255
				ImGui.OpenPopup("MessagePopup") -- 256
			end -- 256
			ImGui.BeginPopupModal("MessagePopup", messagePopupFlags, messagePopup) -- 258
		end -- 174
	) -- 174
	return false -- 260
end) -- 170
local node = Node() -- 263
node:onCleanup(function() -- 264
	if 0 < progress and progress < 1 and downloadTargetFile ~= "" then -- 264
		cancelDownload = true -- 266
		Content:remove(downloadTargetFile) -- 267
	end -- 267
	if targetUnzipPath ~= "" then -- 267
		Content:remove(targetUnzipPath) -- 270
	end -- 270
end) -- 264
return ____exports -- 264