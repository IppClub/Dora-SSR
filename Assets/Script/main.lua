--local View = require("View")
--View.scale = 2

local Content = require("Content")

Content:setSearchPaths{"Script","Script/Lib"}

require("moonscript")

require("Dev.entry")
