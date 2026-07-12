local Object = require("Object").Type
local Vec3 = require("Vec3").Type

-- Class used for building a hierarchical tree of 3D objects.
local record Node3D

	-- Inherits from `Object`.
	embed Object

	-- The order of the node in the parent's children array.
	order: integer

	-- The tag of the node as a string.
	tag: string

	-- Whether the node is visible.
	visible: boolean

	-- The parent 3D node.
	const parent: Node3D | nil

	-- Whether the node has child 3D nodes.
	const hasChildren: boolean

	-- The node position.
	position: Vec3

	-- The node scale.
	scale: Vec3

	-- The node rotation quaternion.
	rotation: any

	-- The node Euler rotation in degrees.
	eulerAngles: Vec3

	-- The node world transform matrix.
	const worldMatrix: any

	-- The X-axis position of the node.
	x: number

	-- The Y-axis position of the node.
	y: number

	-- The Z-axis position of the node.
	z: number

	-- The X-axis rotation angle of the node in degrees.
	angleX: number

	-- The Y-axis rotation angle of the node in degrees.
	angleY: number

	-- The Z-axis rotation angle of the node in degrees.
	angleZ: number

	-- The X-axis scale factor of the node.
	scaleX: number

	-- The Y-axis scale factor of the node.
	scaleY: number

	-- The Z-axis scale factor of the node.
	scaleZ: number

	-- Adds a child 3D node to the current node.
	-- @param child (Node3D) The child node to add.
	-- @param order (integer) [optional] The drawing order of the child node. Default is 0.
	-- @param tag (string) [optional] The tag of the child node. Default is an empty string.
	addChild: function(
		self: Node3D,
		child: Node3D,
		order?: integer --[[0]],
		tag?: string --[[""]]
	)

	-- Removes a child 3D node from the current node.
	-- @param child (Node3D) The child node to remove.
	-- @param cleanup (boolean) [optional] Whether to cleanup the child node. Default is true.
	removeChild: function(self: Node3D, child: Node3D, cleanup?: boolean --[[true]])

	-- Removes all child 3D nodes from the current node.
	-- @param cleanup (boolean) [optional] Whether to cleanup the child nodes. Default is true.
	removeAllChildren: function(self: Node3D, cleanup?: boolean --[[true]])

	-- Removes the current node from its parent node.
	-- @param cleanup (boolean) [optional] Whether to cleanup the current node. Default is true.
	removeFromParent: function(self: Node3D, cleanup?: boolean --[[true]])

	-- Cleans up the current node and releases its 3D resources.
	cleanup: function(self: Node3D)

	-- Converts a point from node space to world space.
	-- @param localPoint (Vec3) The point in node space.
	-- @return (Vec3) The converted point in world space.
	convertToWorldSpace: function(self: Node3D, localPoint: Vec3): Vec3

	-- Converts a point in world space to node space.
	-- @param worldPoint (Vec3) The point in world space.
	-- @return (Vec3) The converted point in node space.
	convertToNodeSpace: function(self: Node3D, worldPoint: Vec3): Vec3
end

local record Node3DClass
	type Type = Node3D

	-- Creates a new Node3D object.
	-- @return (Node3D) A new Node3D object.
	metamethod __call: function(self: Node3DClass): Node3D
end

local node3DClass: Node3DClass
return node3DClass
