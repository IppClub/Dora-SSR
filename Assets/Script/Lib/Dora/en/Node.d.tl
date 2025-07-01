local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local Size = require("Size").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local Scheduler = require("Scheduler").Type
local Array = require("Array").Type
local Dictionary = require("Dictionary").Type
local Action = require("Action").Type
local ActionDef = require("Action").Def
local Slot = require("Slot").Type
local GSlot = require("GSlot").Type
local Touch = require("Touch").Type
local Routine = require("Routine")
local Camera = require("Camera").Type
local SpriteEffect = require("SpriteEffect").Type
local BlendFunc = require("BlendFunc").Type
local Keyboard = require("Keyboard")
local Controller = require("Controller")

-- Class used for building a hierarchical tree structure of game objects.
local record Node

	-- Inherits from `Object`.
	embed Object

	-- The order of the node in the parent's children array.
	order: integer

	-- The rotation angle of the node in degrees.
	angle: number

	-- The X-axis rotation angle of the node in degrees.
	angleX: number

	-- The Y-axis rotation angle of the node in degrees.
	angleY: number

	-- The X-axis scale factor of the node.
	scaleX: number

	-- The Y-axis scale factor of the node.
	scaleY: number

	-- The Z-axis scale factor of the node.
	scaleZ: number

	-- The X-axis position of the node.
	x: number

	-- The Y-axis position of the node.
	y: number

	-- The Z-axis position of the node.
	z: number

	-- The position of the node as a Vec2 object.
	position: Vec2

	-- The X-axis skew angle of the node in degrees.
	skewX: number

	-- The Y-axis skew angle of the node in degrees.
	skewY: number

	-- Whether the node is visible.
	visible: boolean

	-- The anchor point of the node as a Vec2 object.
	anchor: Vec2

	-- The width of the node.
	width: number

	-- The height of the node.
	height: number

	-- The size of the node as a Size object.
	size: Size

	-- The tag of the node as a string.
	tag: string

	-- The opacity of the node, should be 0 to 1.0.
	opacity: number

	-- The color of the node as a Color object.
	color: Color

	-- The color of the node as a Color3 object.
	color3: Color3

	-- Whether to pass the opacity value to child nodes.
	passOpacity: boolean

	-- Whether to pass the color value to child nodes.
	passColor3: boolean

	-- The target node acts as a parent node for transforming this node.
	transformTarget: Node

	-- The scheduler used for scheduling update and action callbacks.
	scheduler: Scheduler

	-- Whether the node has children.
	const hasChildren: boolean

	-- The children of the node as an Array object, could be nil.
	const children: Array

	-- The parent node of the node.
	const parent: Node

	-- Whether the node is currently running in a scene tree.
	const running: boolean

	-- Whether the node is currently scheduling a function or a coroutine for updates.
	const scheduled: boolean

	-- The number of actions currently running on the node.
	const actionCount: integer

	-- Additional data stored on the node as a Dictionary object.
	const data: Dictionary

	-- Whether touch events are enabled on the node.
	touchEnabled: boolean

	-- Whether the node should swallow touch events.
	swallowTouches: boolean

	-- Whether the node should swallow mouse wheel events.
	swallowMouseWheel: boolean

	-- Whether keyboard events are enabled on the node.
	keyboardEnabled: boolean

	-- Whether controller events are enabled on the node.
	controllerEnabled: boolean

	-- Whether to group the node's rendering with all its recursive children.
	renderGroup: boolean

	-- Whether debug graphic should be displayed for the node.
	showDebug: boolean

	-- The rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier.
	renderOrder: integer

	-- Adds a child node to the current node.
	-- @param child (Node) The child node to add.
	-- @param order (integer) [optional] The drawing order of the child node. Default is 0.
	-- @param tag (string) [optional] The tag of the child node. Default is an empty string.
	addChild: function(
		self: Node,
		child: Node,
		order?: integer --[[0]],
		tag?: string --[[""]]
	)

	-- Adds the current node to a parent node.
	-- @param parent (Node) The parent node to add the current node to.
	-- @param order (integer) [optional] The drawing order of the current node. Default is 0.
	-- @param tag (string) [optional] The tag of the current node. Default is an empty string.
	-- @return (Node) The current node.
	addTo: function(
		self: Node,
		parent: Node,
		order?: integer --[[0]],
		tag?: string --[[""]]
	): Node

	-- Removes a child node from the current node.
	-- @param child (Node) The child node to remove.
	-- @param cleanup (boolean) [optional] Whether to cleanup the child node. Default is true.
	removeChild: function(
		self: Node,
		child: Node,
		cleanup?: boolean --[[true]]
	)

	-- Removes a child node from the current node by tag.
	-- @param tag (string) The tag of the child node to remove.
	-- @param cleanup (boolean) [optional] Whether to cleanup the child node. Default is true.
	removeChildByTag: function(
		self: Node,
		tag: string,
		cleanup?: boolean --[[true]]
	)

	-- Removes all child nodes from the current node.
	-- @param cleanup (boolean) [optional] Whether to cleanup the child nodes. Default is true.
	removeAllChildren: function(
		self: Node,
		cleanup?: boolean --[[true]]
	)

	-- Removes the current node from its parent node.
	-- @param cleanup (boolean) [optional] Whether to cleanup the current node. Default is true.
	removeFromParent: function(
		self: Node,
		cleanup?: boolean --[[true]]
	)

	-- Moves the current node to a new parent node without triggering node events.
	-- @param parent (Node) The new parent node to move the current node to.
	moveToParent: function(self: Node, parent: Node)

	-- Cleans up the current node.
	cleanup: function(self: Node)

	-- Gets a child node by tag.
	-- @param tag (string) The tag of the child node to get.
	-- @return (Node) The child node, or nil if not found.
	getChildByTag: function(self: Node, tag: string): Node

	-- Schedules a main function to run every frame. Call this function again to replace the previous scheduled main function or coroutine.
	-- @param func (function) The main function to run, returns true to stop.
	schedule: function(self: Node, func: function(number): boolean)

	-- Schedules a main coroutine to run. Call this function again to replace the previous scheduled main function or coroutine.
	-- @param job (Routine.Job) The main coroutine to run, return or yield true to stop.
	schedule: function(self: Node, job: Routine.Job)

	-- Unschedules the current node's scheduled main function or coroutine.
	unschedule: function(self: Node)

	-- Schedules a function that runs in a coroutine once. Call this function to replace the previous scheduled main function or coroutine.
	-- @param func (function) The function to run once.
	once: function(self: Node, func: function())

	-- Schedules a function that runs in a coroutine in a loop. Call this function to replace the previous scheduled main function or coroutine.
	-- @param func (function) The function to run in a loop, returns true to stop.
	loop: function(self: Node, func: function(): boolean)

	-- Converts a point in world space to node space.
	-- @param worldPoint (Vec2) The point to convert.
	-- @return (Vec2) The converted point.
	convertToNodeSpace: function(self: Node, worldPoint: Vec2): Vec2

	-- Converts a point in world space to node space.
	-- @param worldPoint (Vec2) The point to convert.
	-- @param z (number) The z-coordinate of the point.
	-- @return (Vec2) The converted point.
	-- @return (number) The converted z-coordinate.
	convertToNodeSpace: function(self: Node, worldPoint: Vec2, z: number): Vec2, number

	-- Converts a point from node space to world space.
	-- @param nodePoint (Vec2) The point in node space.
	-- @return (Vec2) The converted point in world space.
	convertToWorldSpace: function(self: Node, nodePoint: Vec2): Vec2

	-- Converts a point from node space to world space.
	-- @param nodePoint (Vec2) The point in node space.
	-- @param z (number) The z coordinate in node space.
	-- @return (Vec2) The converted point in world space.
	-- @return (number) The converted z coordinate in world space .
	convertToWorldSpace: function(self: Node, nodePoint: Vec2, z: number): Vec2, number

	-- Converts a point from node space to window space.
	-- @param nodePoint (Vec2) The point in node space.
	-- @param callback (function) The callback function to receive the converted point in window space.
	convertToWindowSpace: function(self: Node, nodePoint: Vec2, callback: function(Vec2))

	-- Calls the given function for each child node of this node. The child nodes can not be added or removed during the iteration.
	-- @param func (function) The function to call for each child node. The function should return a boolean value indicating whether to continue the iteration. Return true to stop iteration.
	-- @return (boolean) False if all children have been visited, true if the iteration was interrupted by the function.
	eachChild: function(self: Node, func: function(Node): boolean): boolean

	-- Traverses the node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are not visited. The nodes can not be added or removed during the iteration.
	-- @param func (function) The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal. Return true to stop iteration.
	-- @return (boolean) False if all nodes have been visited, true if the traversal was interrupted by the function.
	traverse: function(self: Node, func: function(Node): boolean): boolean

	-- Traverses the entire node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are also visited. The nodes can not be added or removed during the iteration.
	-- @param func (function) The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal.
	-- @return (boolean) True if all nodes have been visited, false if the traversal was interrupted by the function.
	traverseAll: function(self: Node, func: function(Node): boolean): boolean

	-- Runs the given action on this node.
	-- @param action (Action) The action to run.
	-- @param loop (boolean) [optional] Whether to loop the action. Default is false.
	-- @return (number) The duration of the newly running action in seconds.
	runAction: function(self: Node, action: Action, loop?: boolean): number

	-- Runs an action defined by the given action definition on this node.
	-- @param actionDef (ActionDef) The action definition to run.
	-- @param loop (boolean) [optional] Whether to loop the action. Default is false.
	-- @return (number) The duration of the newly running action in seconds.
	runAction: function(self: Node, actionDef: ActionDef, loop?: boolean): number

	-- Stops all actions running on this node.
	stopAllActions: function(self: Node)

	-- Runs the given action immediately without adding it to the action queue.
	-- @param action (Action) The action to run.
	-- @param loop (boolean) [optional] Whether to loop the action. Default is false.
	-- @return (number) The duration of the newly running action.
	perform: function(self: Node, action: Action, loop?: boolean): number

	-- Runs an action defined by the given action definition right after clear all the previous running actions.
	-- @param actionDef (ActionDef) The action definition to run.
	-- @param loop (boolean) [optional] Whether to loop the action. Default is false.
	-- @return (number) The duration of the newly running action.
	perform: function(self: Node, actionDef: ActionDef, loop?: boolean): number

	-- Stops the given action running on this node.
	-- @param action (Action) The action to stop.
	stopAction: function(self: Node, action: Action)

	-- Vertically aligns all child nodes of this node.
	-- @param padding (number) [optional] The padding between child nodes. Defaults to 10.
	-- @return (Size) The size of the aligned child nodes.
	alignItemsVertically: function(
		self: Node,
		padding?: number --[[10]]
	): Size

	-- Vertically aligns all child nodes within the node using the given size and padding.
	-- @param size (Size) The size to use for alignment.
	-- @param padding (number) [optional] The amount of padding to use between each child node (default is 10).
	-- @return (Size) The size of the node after alignment.
	alignItemsVertically: function(
		self: Node,
		size: Size,
		padding?: number --[[10]]
	): Size

	-- Horizontally aligns all child nodes within the node using the given padding.
	-- @param padding (number) [optional] The amount of padding to use between each child node (default is 10).
	-- @return (Size) The size of the node after alignment.
	alignItemsHorizontally: function(
		self: Node,
		padding?: number --[[10]]
	): Size

	-- Horizontally aligns all child nodes within the node using the given size and padding.
	-- @param size (Size) The size to hint for alignment.
	-- @param padding (number) [optional] The amount of padding to use between each child node (default is 10).
	-- @return (Size) The size of the node after alignment.
	alignItemsHorizontally: function(
		self: Node,
		size: Size,
		padding?: number --[[10]]
	): Size

	-- Aligns all child nodes within the node using the given size and padding.
	-- @param padding (number) [optional] The amount of padding to use between each child node (default is 10).
	-- @return (Size) The size of the node after alignment.
	alignItems: function(
		self: Node,
		padding?: number --[[10]]
	): Size

	-- Aligns all child nodes within the node using the given size and padding.
	-- @param size (Size) The size to use for alignment.
	-- @param padding (number) [optional] The amount of padding to use between each child node (default is 10).
	-- @return (Size) The size of the node after alignment.
	alignItems: function(
		self: Node,
		size: Size,
		padding?: number --[[10]]
	): Size

	-- Moves and changes child nodes' visibility based on their position in parent's area.
	-- @param delta (Vec2) The distance to move its children.
	moveAndCullItems: function(self: Node, delta: Vec2)

	-- Attaches the input method editor (IME) to the node.
	-- Makes node recieving "AttachIME", "DetachIME", "TextInput", "TextEditing" events.
	attachIME: function(self: Node)

	-- Detaches the input method editor (IME) from the node.
	detachIME: function(self: Node)

	-- Gets the global event listener associated with the given event name in this node.
	-- @param eventName (string) The name of the global event.
	-- @return ({GSlot}) All the global event listeners associated with the event.
	gslot: function(self: Node, eventName: string): {GSlot}

	-- Associates the given event handler function with a global event.
	-- @param eventName (string) The name of the global event.
	-- @param handler (function) The handler function to associate with the event.
	-- @return (GSlot) The global event listener associated with the event in this node.
	gslot: function(self: Node, eventName: string, handler: function()): GSlot

	-- Gets the node event listener associated with the given node event name.
	-- @param eventName (string) The name of the node event.
	-- @return (Slot) The node event listener associated with the node event.
	slot: function(self: Node, eventName: string): Slot

	-- Associates the given handler function with the node event.
	-- @param eventName (string) The name of the node event.
	-- @param handler (function) The handler function to associate with the node event.
	slot: function(self: Node, eventName: string, handler: function())

	-- Emits a node event with a given event name and arguments.
	-- @param eventName (string) The name of the node event.
	-- @param ... (...any) The arguments to pass to the node event handler functions.
	emit: function(self: Node, eventName: string, ...: any)

	-- A grabber which is used to render a part of the scene to a texture
	-- by a grid of vertices.
	-- @usage
	-- local node = Node()
	-- node.size = Size(500, 500)
	-- local grabber = node:grab(true)
	-- grabber:moveUV(0, 0, Vec2(0, 0.1))
	record Grabber
		embed Object

		-- The camera used to render the texture.
		camera: Camera

		-- The sprite effect applied to the texture.
		effect: SpriteEffect

		-- The blend function applied to the texture.
		blendFunc: BlendFunc

		-- The clear color used to clear the texture.
		clearColor: Color

		-- Sets the position of a vertex in the grabber grid.
		-- @param x (integer) The x-index of the vertex in the grabber grid.
		-- @param y (integer) The y-index of the vertex in the grabber grid.
		-- @param pos (Vec2) The new position of the vertex.
		-- @param z (number) [optional] The new z-coordinate of the vertex (default: 0.0).
		setPos: function(self: Grabber, x: integer, y: integer, pos: Vec2, z?: number --[[0.0]])

		-- Gets the position of a vertex in the grabber grid.
		-- @param x (integer) The x-index of the vertex in the grabber grid.
		-- @param y (integer) The y-index of the vertex in the grabber grid.
		-- @return (Vec2) The position of the vertex.
		getPos: function(self: Grabber, x: integer, y: integer): Vec2

		-- Gets the color of a vertex in the grabber grid.
		-- @param x (integer) The x-index of the vertex in the grabber grid.
		-- @param y (integer) The y-index of the vertex in the grabber grid.
		-- @return (Color) The color of the vertex.
		getColor: function(self: Grabber, x: integer, y: integer): Color

		-- Sets the color of a vertex in the grabber grid.
		-- @param x (integer) The x-index of the vertex in the grabber grid.
		-- @param y (integer) The y-index of the vertex in the grabber grid.
		-- @param color (Color) The new color of the vertex.
		setColor: function(self: Grabber, x: integer, y: integer, color: Color)

		-- Sets the UV coordinates of a vertex in the grabber grid.
		-- @param x (integer) The x-index of the vertex in the grabber grid.
		-- @param y (integer) The y-index of the vertex in the grabber grid.
		-- @param offset (Vec2) The new UV coordinates of the vertex.
		moveUV: function(self: Grabber, x: integer, y: integer, offset: Vec2)
	end

	-- Creates or removes a texture grabber for the specified node.
	-- @param enabled (boolean) [optional] Whether to enable or disable the grabber. Default is true.
	-- @return (Grabber) A Grabber object with gridX == 1 and gridY == 1 when enabled.
	grab: function(
		self: Node,
		enabled?: boolean --[[true]]
	): Grabber

	-- Creates a texture grabber for the specified node with a specified grid size.
	-- @param gridX (number) The number of horizontal grid cells to divide the grabber into.
	-- @param gridY (number) The number of vertical grid cells to divide the grabber into.
	-- @return (Grabber) A Grabber object.
	grab: function(self: Node, gridX: number, gridY: number): Grabber

	-- Schedules a function to run every frame. Call this function again to schedule multiple functions.
	-- @param func (function) The function to run every frame, returns true to stop.
	-- 	@param deltaTime (number) The time interval in seconds since the last frame.
	-- 	@return (boolean) True to stop the function from running.
	onUpdate: function(self: Node, func: function(number): boolean)

	-- Schedules a coroutine to run every frame. Call this function again to schedule multiple coroutines.
	-- @param job (Routine.Job) The coroutine to run every frame.
	onUpdate: function(self: Node, job: Routine.Job)

	-- Registers a callback for event triggered when the node is entering the rendering phase. The callback is called every frame, and ensures that its call order is consistent with the rendering order of the scene tree, such as rendering child nodes after their parent nodes. Recommended for calling vector drawing functions.
	-- @param func (function) The function to call when the node is entering the rendering phase, returns true to stop.
	-- 	@param deltaTime (number) The time interval in seconds since the last frame.
	-- 	@return (boolean) True to stop the function from running.
	onRender: function(self: Node, func: function(number): boolean)

	-- Registers a callback for event triggered when an action is finished.
	-- @param callback (function) The callback function to register.
	-- 	@param action (Action) The action that has finished.
	-- 	@param target (Node) The node that the action is running on.
	onActionEnd: function(self: Node, callback: function(action: Action, target: Node))

	-- Registers a callback for event triggered before the TapBegan slot and can be used to filter out certain taps.
	-- This function also sets `node.touchEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param touch (Touch) The touch object that triggered the tap.
	onTapFilter: function(self: Node, callback: function(touch: Touch))

	-- Registers callback for event triggered when a tap is detected.
	-- This function also sets `node.touchEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param touch (Touch) The touch object that triggered the tap.
	onTapBegan: function(self: Node, callback: function(touch: Touch))

	-- Registers callback for event triggered when a tap ends.
	-- This function also sets `node.touchEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param touch (Touch) The touch object that triggered the tap.
	onTapEnded: function(self: Node, callback: function(touch: Touch))

	-- Registers callback for event triggered when a tap is detected and has ended.
	-- This function also sets `node.touchEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param touch (Touch) The touch object that triggered the tap.
	onTapped: function(self: Node, callback: function(touch: Touch))

	-- Registers callback for event triggered when a tap moves.
	-- This function also sets `node.touchEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param touch (Touch) The touch object that triggered the tap.
	onTapMoved: function(self: Node, callback: function(touch: Touch))

	-- Registers callback for event triggered when the mouse wheel is scrolled.
	-- This function also sets `node.touchEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param delta (Vec2) The delta of the mouse wheel scroll.
	onMouseWheel: function(self: Node, callback: function(delta: Vec2))

	-- Registers callback for event triggered when a gesture is recognized.
	-- This function also sets `node.touchEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param center (Vec2) The center of the gesture.
	-- 	@param numFingers (integer) The number of fingers used in the gesture.
	-- 	@param deltaDist (number) The distance moved in the gesture.
	-- 	@param deltaAngle (number) The angle rotated in the gesture.
	onGesture: function(self: Node, callback: function(center: Vec2, numFingers: integer, deltaDist: number, deltaAngle: number))

	-- Registers callback for event triggered when a node is added to the scene graph.
	-- @param callback (function) The callback function to register.
	onEnter: function(self: Node, callback: function())

	-- Registers callback for event triggered when a node is removed from the scene graph.
	-- @param callback (function) The callback function to register.
	onExit: function(self: Node, callback: function())

	-- Registers callback for event triggered when a node is cleaned up.
	-- @param callback (function) The callback function to register.
	onCleanup: function(self: Node, callback: function())

	-- Registers callback for event triggered when a key is pressed down.
	-- This function also sets `node.keyboardEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param keyName (Keyboard.KeyName) The key name to listen for.
	onKeyDown: function(self: Node, callback: function(keyName: Keyboard.KeyName))

	-- Registers callback for event triggered when a key is released.
	-- This function also sets `node.keyboardEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param keyName (Keyboard.KeyName) The key name to listen for.
	onKeyUp: function(self: Node, callback: function(keyName: Keyboard.KeyName))

	-- Registers callback for event triggered when a key is pressed.
	-- This function also sets `node.keyboardEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param keyName (Keyboard.KeyName) The key name to listen for.
	onKeyPressed: function(self: Node, callback: function(keyName: Keyboard.KeyName))

	-- Registers callback for event triggered when the input method editor (IME) is attached.
	-- @param callback (function) The callback function to register.
	onAttachIME: function(self: Node, callback: function())

	-- Registers callback for event triggered when the input method editor (IME) is detached.
	-- @param callback (function) The callback function to register.
	onDetachIME: function(self: Node, callback: function())

	-- Registers callback for event triggered when text input is received.
	-- @param callback (function) The callback function to register.
	-- 	@param text (string) The text input received.
	onTextInput: function(self: Node, callback: function(text: string))

	-- Registers callback for event triggered when text is being edited.
	-- @param callback (function) The callback function to register.
	-- 	@param text (string) The text being edited.
	-- 	@param startPos (integer) The starting position of the text being edited.
	onTextEditing: function(self: Node, callback: function(text: string, startPos: integer))

	-- Registers callback for event triggered when a button is pressed down on a controller.
	-- This function also sets `node.controllerEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param controllerId (integer) The ID of the controller that triggered the event.
	-- 	@param buttonName (Controller.ButtonName) The name of the button that was pressed.
	onButtonDown: function(self: Node, callback: function(controllerId: integer, buttonName: Controller.ButtonName))

	-- Registers callback for event triggered when a button is released on a controller.
	-- This function also sets `node.controllerEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param controllerId (integer) The ID of the controller that triggered the event.
	-- 	@param buttonName (Controller.ButtonName) The name of the button that was released.
	onButtonUp: function(self: Node, callback: function(controllerId: integer, buttonName: Controller.ButtonName))

	-- Registers callback for event triggered when a button is pressed on a controller.
	-- This function also sets `node.controllerEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param controllerId (integer) The ID of the controller that triggered the event.
	-- 	@param buttonName (Controller.ButtonName) The name of the button that was pressed.
	onButtonPressed: function(self: Node, callback: function(controllerId: integer, buttonName: Controller.ButtonName))

	-- Registers callback for event triggered when an axis is moved on a controller.
	-- This function also sets `node.controllerEnabled = true`.
	-- @param callback (function) The callback function to register.
	-- 	@param controllerId (integer) The ID of the controller that triggered the event.
	-- 	@param axisName (Controller.AxisName) The name of the axis that was moved.
	-- 	@param value (number) The value of the axis.
	onAxis: function(self: Node, callback: function(controllerId: integer, axisName: Controller.AxisName, value: number))

	-- Enumeration of application events.
	enum AppEventType

		-- The application is about to quit.
		"Quit"

		-- The application gets a low memory warning.
		"LowMemory"

		-- The application is about to enter the background.
		"WillEnterBackground"

		-- The application has entered the background.
		"DidEnterBackground"

		-- The application is about to enter the foreground.
		"WillEnterForeground"

		-- The application has entered the foreground.
		"DidEnterForeground"
	end

	-- Registers callback for event triggered when an application event occurs.
	-- @param callback (function) The callback function to register.
	-- 	@param eventType (AppEventType) The type of application event that occurred.
	onAppEvent: function(self: Node, callback: function(eventType: AppEventType))

	-- Enumeration of application settings.
	enum AppSettingName

		-- The application's locale.
		"Locale"

		-- The application's theme color.
		"Theme"

		-- The application window's fullscreen state.
		"FullScreen"

		-- The application window's position.
		"Position"

		-- The application window's size.
		"Size"
	end

	-- Registers callback for event triggered when an application setting changes.
	-- @param callback (function) The callback function to register.
	-- 	@param settingName (AppSettingName) The name of the application setting that changed.
	onAppChange: function(self: Node, callback: function(settingName: AppSettingName))

	-- Enumeration of application WebSocket events.
	enum AppWSEvent

		-- A WebSocket connection is opened.
		"Open"

		-- A WebSocket connection is closed.
		"Close"

		-- The WebSocket receives a message.
		"Send"

		-- The WebSocket broadcasts a message.
		"Receive"
	end

	-- Registers callback for event triggered when an application WebSocket event occurs.
	-- @param callback (function) The callback function to register.
	-- 	@param event (AppWSEvent) The type of WebSocket event that occurred.
	-- 	@param message (string) The message received or sent.
	onAppWS: function(self: Node, callback: function(event: AppWSEvent, message: string))
end

-- The available event slots for a Node.
-- This is just a demonstration record showing the signal slot names and callbacks.
-- @usage
-- -- you can register for these events using codes like:
-- node:slot("ActionEnd", function(action: Action, target: Node)
-- 	print("Action end", action, target)
-- end)
local record __SLOT__

	-- The ActionEnd slot is triggered when an action is finished.
	-- Triggers after `node:runAction()` and `node:perform()`.
	-- @param action (Action) The finished action.
	-- @param target (Node) The node that finished the action.
	["ActionEnd"]: function(action: Action, target: Node)

	-- The TapFilter slot is triggered before the TapBegan slot and can be used to filter out certain taps.
	-- Triggers after setting `node.touchEnabled = true`.
	-- @param touch (Touch) The touch that triggered the tap.
	["TapFilter"]: function(touch: Touch)

	-- The TapBegan slot is triggered when a tap is detected.
	-- Triggers after setting `node.touchEnabled = true`.
	-- @param touch (Touch) The touch that triggered the tap.
	["TapBegan"]: function(touch: Touch)

	-- The TapEnded slot is triggered when a tap ends.
	-- Triggers after setting `node.touchEnabled = true`.
	-- @param touch (Touch) The touch that triggered the tap.
	["TapEnded"]: function(touch: Touch)

	-- The Tapped slot is triggered when a tap is detected and has ended.
	-- Triggers after setting `node.touchEnabled = true`.
	-- @param touch (Touch) The touch that triggered the tap.
	["Tapped"]: function(touch: Touch)

	-- The TapMoved slot is triggered when a tap moves.
	-- Triggers after setting `node.touchEnabled = true`.
	-- @param touch (Touch) The touch that triggered the tap.
	["TapMoved"]: function(touch: Touch)

	-- The MouseWheel slot is triggered when the mouse wheel is scrolled.
	-- Triggers after setting `node.touchEnabled = true`.
	-- @param delta (Vec2) The amount of scrolling that occurred.
	["MouseWheel"]: function(delta: Vec2)

	-- The Gesture slot is triggered when a gesture is recognized.
	-- Triggers after setting `node.touchEnabled = true`.
	-- @param center (Vec2) The center of the gesture.
	-- @param numFingers (integer) The number of fingers involved in the gesture.
	-- @param deltaDist (number) The distance the gesture has moved.
	-- @param deltaAngle (number) The angle of the gesture.
	["Gesture"]: function(center: Vec2, numFingers: integer, deltaDist: number, deltaAngle: number)

	-- The Enter slot is triggered when a node is added to the scene graph.
	-- Triggers when doing `node:addChild()`.
	["Enter"]: function()

	-- The Exit slot is triggered when a node is removed from the scene graph.
	-- Triggers when doing `node:removeChild()`.
	["Exit"]: function()

	-- The Cleanup slot is triggered when a node is cleaned up.
	-- Triggers only when doing `parent:removeChild(node, true)`.
	["Cleanup"]: function()

	-- The KeyDown slot is triggered when a key is pressed down.
	-- Triggers after setting `node.keyboardEnabled = true`.
	-- @param keyName (Keyboard.KeyName) The name of the key that was pressed.
	["KeyDown"]: function(keyName: Keyboard.KeyName)

	-- The KeyUp slot is triggered when a key is released.
	-- Triggers after setting `node.keyboardEnabled = true`.
	-- @param keyName (Keyboard.KeyName) The name of the key that was released.
	["KeyUp"]: function(keyName: Keyboard.KeyName)

	-- The KeyPressed slot is triggered when a key is pressed.
	-- Triggers after setting `node.keyboardEnabled = true`.
	-- @param keyName (Keyboard.KeyName) The name of the key that was pressed.
	["KeyPressed"]: function(keyName: Keyboard.KeyName)

	-- The AttachIME slot is triggered when the input method editor (IME) is attached (calling `node:attachIME()`).
	["AttachIME"]: function()

	-- The DetachIME slot is triggered when the input method editor (IME) is detached (calling `node:detachIME()` or manually closing IME).
	["DetachIME"]: function()

	-- The TextInput slot is triggered when text input is received.
	-- Triggers after calling `node:attachIME()`.
	-- @param text (string) The text that was input.
	["TextInput"]: function(text: string)

	-- The TextEditing slot is triggered when text is being edited.
	-- Triggers after calling `node:attachIME()`.
	-- @param text (string) The text that is being edited.
	-- @param startPos (integer) The starting position of the text being edited.
	["TextEditing"]: function(text: string, startPos: integer)

	-- The ButtonDown slot is triggered when a game controller button is pressed down.
	-- Triggers after setting `node.controllerEnabled = true`.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param buttonName (Keyboard.KeyName) The name of the button that was pressed.
	["ButtonDown"]: function(controllerId: integer, buttonName: Controller.ButtonName)

	-- The ButtonUp slot is triggered when a game controller button is released.
	-- Triggers after setting `node.controllerEnabled = true`.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param buttonName (Keyboard.KeyName) The name of the button that was released.
	["ButtonUp"]: function(controllerId: integer, buttonName: Controller.ButtonName)

	-- The ButtonPressed slot is triggered when a game controller button is being pressed down.
	-- Triggers after setting `node.controllerEnabled = true`.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param buttonName (Keyboard.KeyName) The name of the button that was pressed.
	["ButtonPressed"]: function(controllerId: integer, buttonName: Controller.ButtonName)

	-- The Axis slot is triggered when a game controller axis changed.
	-- Triggers after setting `node.controllerEnabled = true`.
	-- @param controllerId (integer) The controller id, incrementing from 0 when multiple controllers connected.
	-- @param axisValue (number) The controller axis value ranging from -1.0 to 1.0.
	["Axis"]: function(controllerId: integer, axisValue: number)
end

-- A class object for the `Node` class.
local record NodeClass
	type Type = Node
	type AppEventType = Node.AppEventType
	type AppSettingName = Node.AppSettingName
	type AppWSEvent = Node.AppWSEvent

	-- Creates a new instance of the `Node` class.
	-- @usage
	-- local Node = require("Node")
	-- local node = Node()
	-- @return (Node) A new instance of the `Node` class.
	metamethod __call: function(self: NodeClass): Node
end

local nodeClass: NodeClass
return nodeClass
