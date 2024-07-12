local Color = require("Color").Type
local Scheduler = require("Scheduler").Type
local Node = require("Node").Type
local Camera = require("Camera").Type

-- A singleton class manages the game scene trees and provides access to root scene nodes for different game uses.
-- @usage
-- local Director = require("Director")
-- Director.entry:addChild(node)
local record Director
	userdata

	-- The background color for the game world.
	clearColor: Color

	-- Provides access to the game scheduler, which is used for scheduling tasks like animations and gameplay events.
	scheduler: Scheduler

	-- The root node for 2D user interface elements like buttons and labels.
	const ui: Node

	-- The root node for 3D user interface elements with 3D projection effect.
	const ui3D: Node

	-- The root node for the starting point of a game.
	const entry: Node

	-- The root node for post-rendering scene tree.
	const postNode: Node

	-- Provides access to the system scheduler, which is used for low-level system tasks, should not put any game logic in it.
	const systemScheduler: Scheduler

	-- Provides access to the scheduler used for processing post game logic.
	const postScheduler: Scheduler

	-- The current active camera in Director's camera stack.
	const currentCamera: Camera

	-- The flag to enable or disable frustum culling.
	frustumCulling: boolean

	-- The flag to enable or disable sending collected statistics via built-in Web Socket server. For Web IDE use only.
	profilerSending: boolean

	-- Adds a new camera to Director's camera stack and sets it to the current camera.
	-- @param camera (Camera) The camera to add.
	pushCamera: function(self: Director, camera: Camera)

	-- Removes the current camera from Director's camera stack.
	popCamera: function(self: Director)

	-- Removes a specified camera from Director's camera stack.
	-- @param camera (Camera) The camera to remove.
	-- @return (boolean) True if the camera was removed, false otherwise.
	removeCamera: function(self: Director, camera: Camera): boolean

	-- Removes all cameras from Director's camera stack.
	clearCamera: function(self: Director)

	-- Cleans up all resources managed by the Director, including scene trees and cameras.
	cleanup: function(self: Director)
end

local director: Director
return director
