local Color = require("Color").Type
local Scheduler = require("Scheduler").Type
local Node = require("Node").Type
local Camera = require("Camera").Type

-- The Director module manages the game scene graph and provides access to root scene nodes for different parts of the game.
local record Director
	userdata

	-- The displayStats field controls whether debug statistics are displayed on the screen during gameplay.
	displayStats: boolean

	-- The clearColor field specifies the background color for the game world.
	clearColor: Color

	-- The scheduler field provides access to the game scheduler, which is used for scheduling tasks like animations and gameplay events.
	scheduler: Scheduler

	-- The ui field is the root node for 2D user interface elements like buttons and labels.
	const ui: Node

	-- The ui3D field is the root node for 3D user interface elements with 3D projection effect.
	const ui3D: Node

	-- The entry field is the root node for the starting point of a game.
	const entry: Node

	-- The postNode field is the root node for post-rendering scene tree.
	const postNode: Node

	-- The systemScheduler field provides access to the system scheduler, which is used for low-level system tasks, should not put any game logic in it.
	const systemScheduler: Scheduler

	-- The postScheduler field provides access to the scheduler used for processing post game logic.
	const postScheduler: Scheduler

	-- The currentCamera field specifies the current active camera in the game world.
	const currentCamera: Camera

	-- The deltaTime field specifies the time in seconds since the last frame update.
	const deltaTime: number

	-- The pushCamera method adds a new camera to the game world.
	-- @param camera (Camera) The camera to add.
	pushCamera: function(self: Director, camera: Camera)

	-- The popCamera method removes the current camera from the game world.
	popCamera: function(self: Director)

	-- The removeCamera method removes a specified camera from the game world.
	-- @param camera (Camera) The camera to remove.
	-- @return (boolean) True if the camera was removed, false otherwise.
	removeCamera: function(self: Director, camera: Camera): boolean

	-- The clearCamera method removes all cameras from the game world.
	clearCamera: function(self: Director)

	-- The cleanup method cleans up all resources managed by the Director, including scene trees and cameras.
	cleanup: function(self: Director)
end

-- @usage
-- local Director = require("Director")
-- Director.entry:addChild(node)
local director: Director
return director
