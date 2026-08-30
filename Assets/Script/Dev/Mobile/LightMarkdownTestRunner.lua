local Content <const> = Dora.Content
local Path <const> = Dora.Path

local searchPaths = Content.searchPaths
searchPaths[#searchPaths + 1] = Path(Content.assetPath, "Script")
Content.searchPaths = searchPaths

package.loaded["Dev.Mobile.LightMarkdownTest"] = nil
package.loaded["Dev.Mobile.LightMarkdown"] = nil
require("Dev.Mobile.LightMarkdownTest")
