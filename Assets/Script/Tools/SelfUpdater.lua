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
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoMove"} -- 145
local messagePopupFlags = {"NoSavedSettings", "AlwaysAutoResize", "NoTitleBar"} -- 150
local inputTextFlags = {"AutoSelectAll"} -- 155
local proxyBuf = Buffer(100) -- 156
local function messagePopup() -- 158
	ImGui.Text(popupMessageTitle) -- 159
	ImGui.Separator() -- 160
	ImGui.PushTextWrapPos( -- 161
		300, -- 161
		function() -- 161
			ImGui.TextWrapped(popupMessage) -- 162
		end -- 161
	) -- 161
	if ImGui.Button( -- 161
		zh and "确认" or "OK", -- 164
		Vec2(300, 30) -- 164
	) then -- 164
		ImGui.CloseCurrentPopup() -- 165
	end -- 165
end -- 158
threadLoop(function() -- 169
	local ____App_visualSize_1 = App.visualSize -- 170
	local width = ____App_visualSize_1.width -- 170
	ImGui.SetNextWindowPos( -- 171
		Vec2(width - 10, 10), -- 171
		"Always", -- 171
		Vec2(1, 0) -- 171
	) -- 171
	ImGui.SetNextWindowSize( -- 172
		Vec2(400, 0), -- 172
		"Always" -- 172
	) -- 172
	ImGui.Begin( -- 173
		"Dora Updater", -- 173
		windowFlags, -- 173
		function() -- 173
			ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 174
			ImGui.SameLine() -- 175
			ImGui.TextDisabled("(?)") -- 176
			if ImGui.IsItemHovered() then -- 176
				ImGui.BeginTooltip(function() -- 178
					ImGui.PushTextWrapPos( -- 179
						300, -- 179
						function() -- 179
							ImGui.Text(zh and "使用该工具来检测和安装 Dora SSR 新版本的软件。" or "Use this tool to detect and install new versions of Dora SSR software.") -- 180
						end -- 179
					) -- 179
				end) -- 178
			end -- 178
			ImGui.Separator() -- 184
			repeat -- 184
				local ____switch32 = App.platform -- 184
				local ____cond32 = ____switch32 == "Linux" -- 184
				if ____cond32 then -- 184
					ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt-get 工具进行更新管理。详见官网的安装教程。" or "Please use apt-get to manage updates via the Dora SSR PPA. See the installation tutorial on the official website for details.") -- 187
					return false -- 188
				end -- 188
				____cond32 = ____cond32 or ____switch32 == "macOS" -- 188
				if ____cond32 then -- 188
					ImGui.TextWrapped(zh and "请通过 Homebrew 工具进行更新管理。详见官网的安装教程。" or "Please use the Homebrew tool to manage updates. See the installation tutorial on the official website for details.") -- 190
					return false -- 191
				end -- 191
			until true -- 191
			local _ = false -- 193
			_, currentProxy = ImGui.Combo(zh and "选择代理" or "Proxy Site", currentProxy, proxies) -- 194
			if latestVersion == "" then -- 194
				ImGui.InputText("##NewProxy", proxyBuf, inputTextFlags) -- 196
				ImGui.SameLine() -- 197
				if ImGui.Button(zh and "添加代理" or "Add Proxy") then -- 197
					local proxyText = proxyBuf.text -- 199
					if proxyText ~= "" then -- 199
						proxies[#proxies + 1] = proxyText -- 201
						proxyBuf.text = "" -- 202
						currentProxy = #proxies -- 203
					end -- 203
				end -- 203
			end -- 203
			ImGui.Separator() -- 207
			ImGui.TextColored(themeColor, zh and "当前版：" or "Current Version:") -- 208
			ImGui.SameLine() -- 209
			ImGui.Text(currentVersion) -- 210
			if latestVersion ~= "" then -- 210
				ImGui.TextColored(themeColor, zh and "最新版：" or "Latest Version:") -- 212
				ImGui.SameLine() -- 213
				ImGui.Text(latestVersion) -- 214
				if latestVersion ~= currentVersion then -- 214
					ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update Available!") -- 216
					if downloadTitle == "" then -- 216
						if ImGui.Button(zh and "进行更新" or "Update") then -- 216
							download() -- 219
						end -- 219
					end -- 219
				else -- 219
					ImGui.TextColored(themeColor, zh and "已是最新版！" or "Already the latest version!") -- 223
					if downloadTitle == "" then -- 223
						if ImGui.Button(zh and "重新安装" or "Reinstall") then -- 223
							download() -- 226
						end -- 226
					end -- 226
				end -- 226
			else -- 226
				if checking then -- 226
					ImGui.BeginDisabled(function() -- 232
						ImGui.Button(zh and "检查更新" or "Check Update") -- 233
					end) -- 232
				else -- 232
					if ImGui.Button(zh and "检查更新" or "Check Update") then -- 232
						getLatestVersion() -- 237
					end -- 237
				end -- 237
			end -- 237
			if unzipDone then -- 237
				if App.platform == "Android" then -- 237
					if ImGui.Button(zh and "进行安装" or "Install") then -- 237
						local pathForInstall = Path(targetUnzipPath, ("dora-ssr-" .. latestVersion) .. "-android.apk") -- 244
						App:install(pathForInstall) -- 245
					end -- 245
				end -- 245
			elseif downloadTitle ~= "" then -- 245
				ImGui.Separator() -- 249
				ImGui.Text(downloadTitle) -- 250
				ImGui.ProgressBar( -- 251
					progress, -- 251
					Vec2(-1, 30) -- 251
				) -- 251
			end -- 251
			if popupShow then -- 251
				popupShow = false -- 254
				ImGui.OpenPopup("MessagePopup") -- 255
			end -- 255
			ImGui.BeginPopupModal("MessagePopup", messagePopupFlags, messagePopup) -- 257
		end -- 173
	) -- 173
	return false -- 259
end) -- 169
local node = Node() -- 262
node:onCleanup(function() -- 263
	if 0 < progress and progress < 1 and downloadTargetFile ~= "" then -- 263
		cancelDownload = true -- 265
		Content:remove(downloadTargetFile) -- 266
	end -- 266
	if targetUnzipPath ~= "" then -- 266
		Content:remove(targetUnzipPath) -- 269
	end -- 269
end) -- 263
return ____exports -- 263