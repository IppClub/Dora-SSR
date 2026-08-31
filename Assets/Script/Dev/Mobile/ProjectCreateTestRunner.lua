local Content <const> = Dora.Content
local Path <const> = Dora.Path

local searchPaths = Content.searchPaths
searchPaths[#searchPaths + 1] = Path(Content.assetPath, "Script")
Content.searchPaths = searchPaths

package.loaded["Dev.Mobile.ProjectCreateTest"] = nil
package.loaded["Dev.Mobile.ProjectCreate"] = nil
require("Dev.Mobile.ProjectCreateTest")
