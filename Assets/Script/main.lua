local Content = require("Content")

Content.searchPaths = {
	Content.writablePath.."Script",
	Content.writablePath.."Script/Lib",
	"Script",
	"Script/Lib",
	"Image"
}

require("Dev.Entry")

print(moontolua([==[
UnitAction\add "fallOff",
	create: =>
		with @model
			.speed = 1.5
			.loop = true
			\resume "jump"
		=>
			if @onSurface
				return true
			false
	stop: =>
		@model\stop!

]==]))
