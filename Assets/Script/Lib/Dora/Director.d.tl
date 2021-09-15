local Color = require("Color").Type
local Scheduler = require("Scheduler").Type
local Node = require("Node").Type
local Camera = require("Camera").Type
local record Director
	userdata
	displayStats: boolean
	clearColor: Color
	scheduler: Scheduler
	const ui: Node
	const entry: Node
	const postNode: Node
	const systemScheduler: Scheduler
	const postScheduler: Scheduler
	const currentCamera: Camera
	const deltaTime: number
	pushCamera: function(self: Director, camera: Camera)
	popCamera: function(self: Director)
	removeCamera: function(self: Director, camera: Camera): boolean
	clearCamera: function(self: Director)
end
print(Director.entry)
print(Director.ui)
print(Director.clearColor)
print(Director.scheduler)
print(Director.postNode)
print(Director.systemScheduler)
print(Director.postScheduler)
print(Director.currentCamera)
local director: Director
return director
