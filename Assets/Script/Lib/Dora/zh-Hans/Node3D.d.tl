local Object = require("Object").Type
local Vec3 = require("Vec3").Type

-- 用于构建 3D 对象层级树的类。
local record Node3D

	-- 继承自 `Object`。
	embed Object

	-- 节点在父节点子节点数组中的顺序。
	order: integer

	-- 节点的字符串标签。
	tag: string

	-- 节点是否可见。
	visible: boolean

	-- 父 3D 节点。
	const parent: Node3D | nil

	-- 子 3D 节点列表。
	const children: any

	-- 节点位置。
	position: Vec3

	-- 节点缩放。
	scale: Vec3

	-- 节点旋转。
	rotation: any

	-- 节点欧拉角旋转，单位为度。
	eulerAngles: Vec3

	-- 节点的世界变换矩阵。
	const worldMatrix: any

	-- 节点的 X 轴位置。
	x: number

	-- 节点的 Y 轴位置。
	y: number

	-- 节点的 Z 轴位置。
	z: number

	-- 节点绕 X 轴的旋转角度，单位为度。
	angleX: number

	-- 节点绕 Y 轴的旋转角度，单位为度。
	angleY: number

	-- 节点绕 Z 轴的旋转角度，单位为度。
	angleZ: number

	-- 节点的 X 轴缩放系数。
	scaleX: number

	-- 节点的 Y 轴缩放系数。
	scaleY: number

	-- 节点的 Z 轴缩放系数。
	scaleZ: number

	-- 添加子 3D 节点。
	-- @param child (Node3D) 要添加的子节点。
	-- @param order (integer) [可选] 子节点的绘制顺序。默认为 0。
	-- @param tag (string) [可选] 子节点的标签。默认为空字符串。
	addChild: function(
		self: Node3D,
		child: Node3D,
		order?: integer --[[0]],
		tag?: string --[[""]]
	)

	-- 移除子 3D 节点。
	-- @param child (Node3D) 要移除的子节点。
	-- @param cleanup (boolean) [可选] 是否清理子节点。默认为 true。
	removeChild: function(self: Node3D, child: Node3D, cleanup?: boolean --[[true]])

	-- 移除所有子 3D 节点。
	-- @param cleanup (boolean) [可选] 是否清理子节点。默认为 true。
	removeAllChildren: function(self: Node3D, cleanup?: boolean --[[true]])

	-- 从父节点中移除当前节点。
	-- @param cleanup (boolean) [可选] 是否清理当前节点。默认为 true。
	removeFromParent: function(self: Node3D, cleanup?: boolean --[[true]])

	-- 清理当前节点并释放 3D 资源。
	cleanup: function(self: Node3D)

	-- 将本地坐标点转换到世界坐标空间。
	-- @param localPoint (Vec3) 本地坐标点。
	-- @return (Vec3) 转换后的世界坐标点。
	convertToWorldSpace: function(self: Node3D, localPoint: Vec3): Vec3

	-- 将世界坐标点转换到本地坐标空间。
	-- @param worldPoint (Vec3) 世界坐标点。
	-- @return (Vec3) 转换后的本地坐标点。
	convertToNodeSpace: function(self: Node3D, worldPoint: Vec3): Vec3
end

local record Node3DClass
	type Type = Node3D

	-- 创建新的 Node3D 对象。
	-- @return (Node3D) 新的 Node3D 对象。
	metamethod __call: function(self: Node3DClass): Node3D
end

local node3DClass: Node3DClass
return node3DClass
