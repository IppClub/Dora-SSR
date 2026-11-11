-- [ts]: View.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Color = ____Dora.Color -- 2
local Node = ____Dora.Node -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ImGui = require("ImGui") -- 3
local ____Manifest = require("Tools.SelfUpdater.Manifest") -- 5
local windowsUpdatePlatform = ____Manifest.windowsUpdatePlatform -- 5
local Updater = require("Tools.SelfUpdater.Service") -- 6
____exports.createUpdaterPanel = function() -- 8
	local node = Node() -- 9
	local confirm = false -- 10
	local ____opt_0 = Updater.getState().packagePlatform -- 10
	local backend = ____opt_0 and __TS__StringIncludes( -- 11
		Updater.getState().packagePlatform, -- 11
		"-opengl" -- 11
	) and 2 or 1 -- 11
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 12
	if Updater.getState().phase == "idle" then -- 12
		Updater.checkForUpdates() -- 13
	end -- 13
	node:schedule(function() -- 14
		local state = Updater.getState() -- 15
		local width = math.min(460, App.visualSize.width - 24) -- 16
		local height = math.min(600, App.visualSize.height - 24) -- 17
		ImGui.SetNextWindowPos( -- 18
			Vec2(App.visualSize.width / 2, App.visualSize.height / 2), -- 18
			"Always", -- 18
			Vec2(0.5, 0.5) -- 18
		) -- 18
		ImGui.SetNextWindowSize( -- 19
			Vec2(width, height), -- 19
			"Always" -- 19
		) -- 19
		ImGui.PushStyleVar( -- 20
			"WindowRounding", -- 20
			16, -- 20
			function() return ImGui.PushStyleVar( -- 20
				"WindowPadding", -- 20
				Vec2(20, 18), -- 20
				function() -- 20
					ImGui.Begin( -- 21
						"EngineUpdate", -- 21
						{"NoDecoration", "NoSavedSettings", "NoMove"}, -- 21
						function() -- 21
							ImGui.Text(zh and "引擎更新" or "Engine update") -- 22
							ImGui.SameLine(width - 70) -- 23
							if ImGui.Button( -- 23
								"X##close-update", -- 24
								Vec2(30, 30) -- 24
							) then -- 24
								node:removeFromParent(true) -- 24
							end -- 24
							ImGui.Separator() -- 25
							ImGui.BeginChild( -- 26
								"UpdateContent", -- 26
								Vec2(0, -62), -- 26
								function() -- 26
									local title = state.phase == "checking" and (zh and "正在检查更新…" or "Checking for updates…") or (state.phase == "ready" and (zh and "更新已准备好" or "Update ready") or (state.ignored and (zh and "已忽略此版本" or "This version is ignored") or (state.available and (zh and "有可用更新" or "Update available") or (state.comparison == 1 and (zh and "当前版本高于稳定版" or "Newer than stable") or (state.comparison == 0 and (zh and "版本相同" or "Matching release version") or (zh and "检查引擎更新" or "Check engine updates")))))) -- 27
									ImGui.TextColored(App.themeColor, title) -- 34
									if state.targetVersion then -- 34
										ImGui.Text(state.targetVersion) -- 35
									end -- 35
									ImGui.TextDisabled(((zh and "当前版本" or "Installed") .. " ") .. state.currentVersion) -- 36
									ImGui.Dummy(Vec2(0, 10)) -- 37
									ImGui.Text(state.platform .. (state.packagePlatform and " · " .. state.packagePlatform or "")) -- 38
									local disabled = state.prepared or state.phase == "checking" or state.phase == "downloading" or state.phase == "canceling" or state.phase == "installing" -- 39
									local function sources() -- 40
										local changed, index = ImGui.Combo(zh and "更新源" or "Source", state.source == "AtomGit" and 1 or 2, {"AtomGit", "GitHub"}) -- 41
										if changed then -- 41
											Updater.checkForUpdates(index == 1 and "AtomGit" or "GitHub") -- 42
										end -- 42
									end -- 40
									if disabled then -- 40
										ImGui.BeginDisabled(sources) -- 44
									else -- 44
										sources() -- 44
									end -- 44
									if state.publishedAt then -- 44
										ImGui.TextWrapped(((zh and "发布时间" or "Published") .. ": ") .. state.publishedAt) -- 45
									end -- 45
									if state.packageSize then -- 45
										ImGui.TextDisabled(string.format("%.1f", state.packageSize / 1048576) .. " MiB") -- 46
									end -- 46
									if state.usedCache then -- 46
										ImGui.TextWrapped(zh and "离线缓存结果，不作为新版本提示。请联网重新检查。" or "Offline cached result. Check again online to confirm availability.") -- 47
									end -- 47
									if state.source == "GitHub" and state.comparison == 0 then -- 47
										ImGui.TextWrapped(zh and "GitHub 无法判断发布修订；如需修复，可在安装选项中重新下载。" or "GitHub cannot compare release revisions. Redownload under installation options.") -- 48
									end -- 48
									if state.message ~= "" then -- 48
										ImGui.TextWrapped(state.message) -- 49
									end -- 49
									if state.canIgnore and ImGui.Button( -- 49
										zh and "忽略此版本" or "Ignore this version", -- 50
										Vec2(-1, 32) -- 50
									) then -- 50
										if Updater.ignoreUpdate() then -- 50
											node:removeFromParent(true) -- 51
										end -- 51
									end -- 51
									if state.progress then -- 51
										ImGui.TextWrapped(state.progress.message) -- 54
										ImGui.ProgressBar( -- 55
											state.progress.progress, -- 55
											Vec2(-1, 22) -- 55
										) -- 55
									end -- 55
									if state.releaseUrl and ImGui.Button( -- 55
										zh and "查看发布说明" or "Release notes", -- 57
										Vec2(-1, 32) -- 57
									) then -- 57
										App:openURL(state.releaseUrl) -- 57
									end -- 57
									if state.platform == "Linux" then -- 57
										ImGui.TextWrapped(zh and "请在引擎所在设备通过 PPA / apt 更新：\nsudo apt update\nsudo apt install --only-upgrade dora-ssr" or "Update on the engine device via PPA / apt:\nsudo apt update\nsudo apt install --only-upgrade dora-ssr")
									end -- 58
									if ImGui.CollapsingHeader(zh and "安装选项与校验信息" or "Installation and verification") then -- 58
										ImGui.TextWrapped(zh and "保留项目与设置。安装前验证文件大小和 SHA-256；AtomGit 同时验证发布签名。" or "Projects and settings are preserved. Size and SHA-256 are checked; AtomGit also verifies release signatures.") -- 60
										if state.platform == "macOS" then -- 60
											ImGui.TextWrapped(zh and "Homebrew 用户也可继续使用 brew upgrade。" or "Homebrew installations can also use brew upgrade.") -- 61
										end -- 61
										if state.windows and state.packagePlatform and not disabled then -- 61
											local changed, choice = ImGui.Combo(zh and "图形后端" or "Graphics backend", backend, {"D3D12", "OpenGL"}) -- 63
											if changed then -- 63
												backend = choice -- 64
											end -- 64
											local target = windowsUpdatePlatform( -- 65
												backend == 2 and "wgl" or "d3d12", -- 65
												__TS__StringEndsWith(state.packagePlatform, "-msi") -- 65
											) -- 65
											if target ~= state.packagePlatform and state.canDownload and ImGui.Button(zh and "下载切换版本" or "Download selected backend") then -- 65
												Updater.downloadUpdate(target) -- 66
											end -- 66
										end -- 66
										if state.canDownload and state.comparison == 0 and ImGui.Button(zh and "重新下载安装包" or "Redownload package") then -- 66
											Updater.downloadUpdate() -- 68
										end -- 68
										if state.prepared and state.phase ~= "installing" and ImGui.Button(zh and "丢弃安装包" or "Discard package") then -- 68
											confirm = false -- 69
											Updater.discardPrepared() -- 69
										end -- 69
									end -- 69
									if confirm then -- 69
										ImGui.TextWrapped(zh and "请先保存作品。确认后将退出并重启引擎，Android 将打开系统安装器。" or "Save your work first. Installation exits and restarts the engine, or opens the Android installer.") -- 71
									end -- 71
								end -- 26
							) -- 26
							ImGui.Separator() -- 73
							local cancelable = state.phase == "checking" or state.phase == "downloading" -- 74
							if ImGui.Button( -- 74
								confirm and (zh and "返回" or "Back") or (cancelable and (zh and "取消" or "Cancel") or (state.prepared and (zh and "稍后安装" or "Later") or (zh and "重新检查" or "Check again"))), -- 75
								Vec2((width - 52) / 2, 40) -- 75
							) then -- 75
								if confirm then -- 75
									confirm = false -- 76
								elseif cancelable then -- 76
									Updater.cancelOperation() -- 77
								elseif state.prepared then -- 77
									node:removeFromParent(true) -- 78
								else -- 78
									Updater.checkForUpdates() -- 79
								end -- 79
							end -- 79
							ImGui.SameLine() -- 81
							local function action() -- 82
								if ImGui.Button( -- 82
									state.prepared and (confirm and (zh and "确认安装" or "Confirm install") or (zh and "安装并重启" or "Install and restart")) or (zh and "下载更新" or "Download update"), -- 83
									Vec2((width - 52) / 2, 40) -- 83
								) then -- 83
									if state.prepared then -- 83
										if confirm then -- 83
											confirm = false -- 84
											Updater.installUpdate(true) -- 84
										else -- 84
											confirm = true -- 84
										end -- 84
									else -- 84
										Updater.downloadUpdate() -- 85
									end -- 85
								end -- 85
							end -- 82
							if state.comparison == -1 and state.canDownload or state.phase == "ready" then -- 82
								ImGui.PushStyleColor( -- 88
									"Button", -- 88
									App.themeColor, -- 88
									function() return ImGui.PushStyleColor( -- 88
										"Text", -- 88
										Color(4279702282), -- 88
										action -- 88
									) end -- 88
								) -- 88
							else -- 88
								ImGui.BeginDisabled(action) -- 89
							end -- 89
						end -- 21
					) -- 21
				end -- 20
			) end -- 20
		) -- 20
		return false -- 92
	end) -- 14
	return node -- 94
end -- 8
return ____exports -- 8
