local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local Size = require("Size").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local Scheduler = require("Scheduler").Type
local Array = require("Array").Type
local Rect = require("Rect").Type
local Dictionary = require("Dictionary").Type
local Action = require("Action").Type
local ActionDef = require("ActionDefBase")
local Slot = require("Slot").Type
local GSlot = require("GSlot").Type
local Touch = require("Touch").Type
local Routine = require("Routine")
local record Node
	embed Object
	order: integer
	angle: number
	angleX: number
	angleY: number
	scaleX: number
	scaleY: number
	x: number
	y: number
	z: number
	const position: Vec2
	skewX: number
	skewY: number
	visible: boolean
	anchor: Vec2
	width: number
	height: number
	size: Size
	tag: string
	opacity: number
	color: Color
	color3: Color3
	passOpacity: boolean
	passColor3: boolean
	transformTarget: Node
	scheduler: Scheduler
	const hasChildren: boolean
	const children: Array
	const parent: Node
	const boundingBox: Rect
	const running: boolean
	const updating: boolean
	const scheduled: boolean
	const actionCount: integer
	const data: Dictionary
	touchEnabled: boolean
	swallowTouches: boolean
	swallowMouseWheel: boolean
	keyboardEnabled: boolean
	renderGroup: boolean
	renderOrder: integer

	addChild: function(self: Node, child: Node, order: integer, tag: string)
	addChild: function(self: Node, child: Node, order: integer)
	addChild: function(self: Node, child: Node)

	addTo: function(self: Node, parent: Node, order: integer, tag: string): Node
	addTo: function(self: Node, parent: Node, order: integer): Node
	addTo: function(self: Node, parent: Node): Node

	removeChild: function(self: Node, child: Node, cleanup: boolean --[[true]])
	removeChildByTag: function(self: Node, tag: string, cleanup: boolean --[[true]])
	removeAllChildren: function(self: Node, cleanup: boolean --[[true]])
	removeFromParent: function(self: Node, cleanup: boolean --[[true]])

	cleanup: function(self: Node)

	getChildByTag: function(self: Node, tag: string): Node

	schedule: function(self: Node, func: function(number): boolean)
	schedule: function(self: Node, job: Routine.Job)
	unschedule: function(self: Node)

	convertToNodeSpace: function(self: Node, worldPoint: Vec2): Vec2
	convertToWorldSpace: function(self: Node, nodePoint: Vec2): Vec2
	convertToWindowSpace: function(self: Node, nodePoint: Vec2, callback: function(Vec2))

	eachChild: function(self: Node, func: function(Node): boolean): boolean
	traverse: function(self: Node, func: function(Node): boolean): boolean
	traverseAll: function(self: Node, func: function(Node): boolean): boolean

	runAction: function(self: Node, action: Action)
	runAction: function(self: Node, actionDef: ActionDef)
	stopAllActions: function(self: Node)
	perform: function(self: Node, action: Action)
	perform: function(self: Node, actionDef: ActionDef)
	stopAction: function(self: Node, action: Action)

	alignItemsVertically: function(self: Node, padding: number --[[10]]): Size
	alignItemsVertically: function(self: Node, size: Size, padding: number --[[10]]): Size
	alignItemsHorizontally: function(self: Node, padding: number --[[10]]): Size
	alignItemsHorizontally: function(self: Node, size: Size, padding: number --[[10]]): Size
	alignItems: function(self: Node, padding: number --[[10]]): Size
	alignItems: function(self: Node, size: Size, padding: number --[[10]]): Size
	moveAndCullItems: function(self: Node, delta: Vec2)

	attachIME: function(self: Node)
	detachIME: function(self: Node)

	gslot: function(self: Node, eventName: string): GSlot
	gslot: function(self: Node, eventName: string, handler: function(...: any))
	slot: function(self: Node, eventName: string): Slot
	slot: function(self: Node, eventName: string, handler: function(...: any))
	emit: function(self: Node, eventName: string, ...: any)
end
local record __SLOT__
	-- Node:runAction() | Node:perform()
	["ActionEnd"]: function(action: Action, target: Node)
	-- Node.touchEnabled = true
	["TapFilter"]: function(touch: Touch)
	["TapBegan"]: function(touch: Touch)
	["TapEnded"]: function(touch: Touch)
	["Tapped"]: function(touch: Touch)
	["TapMoved"]: function(touch: Touch)
	["MouseWheel"]: function(delta: Vec2)
	["Gesture"]: function(center: Vec2, numFingers: integer, deltaDist: number, deltaAngle: number)
	-- Node:addChild() | Node:removeChild()
	["Enter"]: function()
	["Exit"]: function()
	["Cleanup"]: function()
	-- Node.keyboardEnabled = true
	["KeyDown"]: function(keyName: string)
	["KeyUp"]: function(keyName: string)
	["KeyPressed"]: function(keyName: string)
	-- Node:attachIME() | Node:DetachIME()
	["AttachIME"]: function()
	["DetachIME"]: function()
	["TextInput"]: function(text: string)
	["TextEditing"]: function(text: string, startPos: integer)
end
local record __GSLOT__
	["AppQuit"]: function()
	["AppLowMemory"]: function()
	["AppWillEnterBackground"]: function()
	["AppDidEnterBackground"]: function()
	["AppWillEnterForeground"]: function()
	["AppDidEnterForeground"]: function()
	["AppSizeChanged"]: function()
end
local record NodeClass
	type Type = Node
	metamethod __call: function(cls: Node): Node
end
print(Node.position)
print(Node.anchor)
print(Node.size)
print(Node.color)
print(Node.color3)
print(Node.transformTarget)
print(Node.scheduler)
print(Node.children)
print(Node.parent)
print(Node.boundingBox)
print(Node.data)
print(Node:addTo())
print(Node:getChildByTag())
print(Node:convertToNodeSpace())
print(Node:convertToWorldSpace())
print(Node:alignItemsVertically())
print(Node:alignItemsHorizontally())
print(Node:alignItems())
print(Node:slot())
print(Node:gslot())
local nodeClass: NodeClass
return nodeClass
