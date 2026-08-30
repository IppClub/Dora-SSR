local Content <const> = Dora.Content
local Path <const> = Dora.Path

local searchPaths = Content.searchPaths
searchPaths[#searchPaths + 1] = Content.assetPath
searchPaths[#searchPaths + 1] = Path(Content.assetPath, "Script")
Content.searchPaths = searchPaths

package.loaded["Dev.Mobile.RealCatalogFeedPreviewTest"] = nil
package.loaded["Dev.Mobile.Feed"] = nil
require("Dev.Mobile.RealCatalogFeedPreviewTest")
