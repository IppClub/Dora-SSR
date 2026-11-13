-- [yue]: Script/Tools/RepositoryImporter.yue
return function(repository) -- 1
	local View = require("Tools.RepositoryImporter.View") -- 2
	return View.start(repository) -- 3
end -- 1
