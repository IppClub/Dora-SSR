-- [teal]: Examples/TealLabel.tl
local Label = require("Label")
local Director = require("Director")

local label = Label("web-fixture", 32, true)
assert(not (label == nil), "Teal Label example failed to create")
label.text = "Teal Web"
label.y = 300
Director.ui:addChild(label)

print("Dora Web example Teal Label verified")
