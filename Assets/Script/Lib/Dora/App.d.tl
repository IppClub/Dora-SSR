local Size = require("Size").Type
local record App
	userdata
	enum Platform
		"Windows"
		"Android"
		"macOS"
		"iOS"
		"Linux"
		"Unknown"
	end
	const frame: integer
	const bufferSize: Size
	const visualSize: Size
	const deviceRatio: number
	const platform: Platform
	const version: string
	const eclapsedTime: number
	const totalTime: number
	const runningTime: number
	const rand: integer
	const debugging: boolean
	seed: integer
	const testNames: {string}
	runTest: function(self: App, name: string): boolean
	shutdown: function(self: App)
end
local app: App
return app
