-- @preview-file on clear
local Label <const> = require("Label")
local Director <const> = require("Director")

local label = Label("web-fixture", 32, true)
assert(not label is nil, "Teal Label example failed to create")
label.text = "Teal Web"
label.y = 300
Director.ui:addChild(label)

print("Dora Web example Teal Label verified")
