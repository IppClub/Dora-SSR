local Content <const> = Dora.Content
local Director <const> = Dora.Director
local Path <const> = Dora.Path

local searchPaths = Content.searchPaths
searchPaths[#searchPaths + 1] = Path(Content.assetPath, "Script")
Content.searchPaths = searchPaths

Director:clearSystemUI()
package.loaded["Dev.Mobile.RemixPreviewTest"] = nil
package.loaded["Dev.Mobile.Remix"] = nil
package.loaded["Dev.Mobile.Mascot"] = nil
require("Dev.Mobile.RemixPreviewTest")
