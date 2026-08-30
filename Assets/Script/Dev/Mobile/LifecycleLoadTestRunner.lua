local Content <const> = Dora.Content
local Path <const> = Dora.Path

local searchPaths = Content.searchPaths
searchPaths[#searchPaths + 1] = Path(Content.assetPath, "Script")
Content.searchPaths = searchPaths

local resultPath = "/tmp/dora-mobile-lifecycle-load.result"
package.loaded["Dev.Mobile.Lifecycle"] = nil
package.loaded["Tools.ResourceDownloader.GitInstaller"] = nil
package.loaded["Tools.ResourceDownloader.Git"] = nil

local success, lifecycle = pcall(require, "Dev.Mobile.Lifecycle")
if success and type(lifecycle.prepareMobileResource) == "function" then
	Content:save(resultPath, "passed")
else
	Content:save(resultPath, "failed: " .. tostring(lifecycle))
end
