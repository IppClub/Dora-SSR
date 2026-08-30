local Content <const> = Dora.Content
local Path <const> = Dora.Path

local searchPaths = Content.searchPaths
searchPaths[#searchPaths + 1] = Path(Content.assetPath, "Script")
Content.searchPaths = searchPaths

package.loaded["Dev.Mobile.CatalogMobileTest"] = nil
package.loaded["Tools.ResourceDownloader.Catalog"] = nil
require("Dev.Mobile.CatalogMobileTest")
