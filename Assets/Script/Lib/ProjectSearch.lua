local Dora = require("Dora")
local Content, Path = Dora.Content, Dora.Path

-- In insertion order: the Script directory takes precedence over the project root.
return function(root)
	if not root or root == "" then return {} end
	local script = Path(root, "Script")
	if Content:isdir(script) then return {root, script} end
	return {root}
end
