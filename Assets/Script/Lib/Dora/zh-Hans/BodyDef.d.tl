local Object = require("Object").Type
local Vec2 = require("Vec2").Type
local FixtureDef = require("FixtureDef").Type

-- 描述物理体定义的类。
local record BodyDef

	-- 继承自`Object`。
	embed Object

	-- 物理体的类型
	enum BodyType

		-- 不会动的物理体。
		"Static"

		-- 可以移动的物理体，会受到外力的影响。
		"Dynamic"

		-- 可以移动但不受外力影响的物理体。
		"Kinematic"
	end

	-- 定义物理体的类型。
	type: BodyType

	-- 定义物理体的位置。
	position: Vec2

	-- 定义物理体的旋转角度。
	angle: number

	-- 定义物理体上挂载的可视图片或其它用于创建`Face`对象的字符串。
	face: string

	-- 定义物理体的可视组件的位置。
	facePos: Vec2

	-- 定义物理体的线性阻尼。
	linearDamping: number

	-- 定义物理体的旋转阻尼。
	angularDamping: number

	-- 定义物理体的初始线性加速度。
	linearAcceleration: Vec2

	-- 是否固定旋转（物理体不会发生旋转）。
	fixedRotation: boolean

	-- 是否为弹道物。
	-- 设置为“true”为物理体添加额外的子弹高速运动碰撞检查。
	bullet: boolean

	-- 将一个多边形的定义添加到物理体定义上。
	-- @param center (Vec2) 多边形的中心点。
	-- @param width (number) 多边形的宽度。
	-- @param height (number) 多边形的高度。
	-- @param angle (number) [可选] 多边形的角度（默认值为0.0）。
	-- @param density (number) [可选] 多边形的密度（默认值为0.0）。
	-- @param friction (number) [可选] 多边形的摩擦系数（默认值为0.4，应为0至1.0）。
	-- @param restitution (number) [可选] 多边形的弹性系数（默认值为0.0，应为0至1.0）。
	attachPolygon: function(self: BodyDef,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]],
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- 将一个多边形的定义添加到物理体定义上。
	-- @param width (number) 多边形的宽度。
	-- @param height (number) 多边形的高度。
	-- @param density (number) [可选] 多边形的密度（默认为 0.0）。
	-- @param friction (number) [可选] 多边形的摩擦系数（默认为 0.4，应在 0 到 1.0 之间）。
	-- @param restitution(number) [可选] 多边形的弹性系数（默认为 0.0，应为 0.0 到 1.0）。
	attachPolygon: function(self: BodyDef,
		width: number,
		height: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- 将一个多边形的定义添加到物理体定义上。
	-- @param vertices ({Vec2}) 多边形的顶点。
	-- @param density (number) [可选] 多边形的密度（默认值为0.0）。
	-- @param friction (number) [可选] 多边形的摩擦系数（默认值为0.4，应在0到1.0之间）。
	-- @param restitution (number) [可选] 多边形的弹性系数（默认值为0.0，应在0到1.0之间）。
	attachPolygon: function(self: BodyDef,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- 将由多个凸多边形组成的凹多边形定义添加到物理体定义上。
	-- @param vertices ({Vec2}) 包含构成凹多边形的每个凸多边形的顶点的列表。
	-- 列表中的每个凸多边形都应以Vec2(0.0, 0.0)结尾作为分隔。
	-- @param density (number) [可选] 凹多边形的密度（默认值为0.0）。
	-- @param friction (number) [可选] 凹多边形的摩擦系数（默认值为0.4，应在0到1.0之间）。
	-- @param restitution (number) [可选] 凹多边形的弹性系数（默认值为0.0，应在0到1.0之间）。
	attachMulti: function(self: BodyDef,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- 将一个圆盘定义添加物理体定义上。
	-- @param center (Vec2) 圆心点。
	-- @param radius (number) 圆盘的半径。
	-- @param density (number) [可选] 圆盘的密度（默认值为0.0）。
	-- @param friction (number) [可选] 圆盘的摩擦系数（默认值为0.4，应在0到1.0之间）。
	-- @param restitution (number) [可选] 圆盘的弹性系数（默认值为0.0，应在0到1.0之间）。
	attachDisk: function(self: BodyDef,
		center: Vec2,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- 将一个圆盘定义添加物理体定义上。
	-- @param radius (number) 圆盘的半径。
	-- @param density (number) [可选] 圆盘的密度（默认值为0.0）。
	-- @param friction (number) [可选] 圆盘的摩擦系数（默认值为0.4）。
	-- @param restitution (number) [可选] 圆盘的弹性系数（默认值为0.0）。
	attachDisk: function(self: BodyDef,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- 将链条形状定义添加到物理体定义上。链条形状是一组连续的线段，线段的两边都能触发碰撞。
	-- @param vertices ({Vec2}) 链条的顶点。
	-- @param friction (number) [可选] 链条的摩擦系数（默认值为0.4）。
	-- @param restitution (number) [可选] 链条的弹性系数（默认值为0.0）。
	attachChain: function(self: BodyDef,
		vertices: {Vec2},
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]])

	-- 将一个多边形感应器形状的定义添加到物理体定义上。
	-- @param tag (number) 感应器的标签编号。
	-- @param width (number) 感应器多边形的宽度。
	-- @param height (number) 感应器多边形的高度。
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		width: number,
		height: number)

	-- 将一个多边形感应器形状的定义添加到物理体定义上。
	-- @param tag (number) 感应器的标签编号。
	-- @param center (Vec2) 感应器多边形的中心点。
	-- @param width (number) 感应器多边形的宽度。
	-- @param height (number) 感应器多边形的高度。
	-- @param angle (number) [可选] 感应器多边形的角度（默认为0.0）。
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]])

	-- 将一个多边形感应器形状的定义添加到物理体定义上。
	-- @param tag (number) 感应器的标签编号。
	-- @param vertices ({Vec2}) 感应器的多边形定义的顶点。
	attachPolygonSensor: function(self: BodyDef,
		tag: integer,
		vertices: {Vec2})

	-- 将圆盘形状感应器的定义添加到物理体定义上。
	-- @param tag (number) 感应器的标签编号。
	-- @param center (Vec2) 圆盘的中心。
	-- @param radius (number) 圆盘的半径。
	attachDiskSensor: function(self: BodyDef,
		tag: integer,
		center: Vec2,
		radius: number)

	-- 将圆盘形状感应器的定义添加到物理体定义上。
	-- @param tag (number) 感应器的标签编号。
	-- @param radius (number) 圆盘的半径。
	attachDiskSensor: function(self: BodyDef,
		tag: integer,
		radius: number)
end

-- 用于创建 BodyDef 和 FixtureDef 对象的类。
local record BodyDefClass
	type Type = BodyDef

	-- 创建多边形形状的混合物的定义。
	-- @param width (number) 多边形的宽度。
	-- @param height (number) 多边形的高度。
	-- @param density (number) [可选] 多边形的密度（默认为 0.0）。
	-- @param friction (number) [可选] 多边形的摩擦力（默认为 0.4，应为 0.0 到 1.0）。
	-- @param restitution (number) [可选] 多边形的恢复力（默认为 0.0，应为 0.0 到 1.0）。
	-- @return (FixtureDef) 用于创建多边形混合物的定义对象。
	polygon: function(self: BodyDefClass,
		width: number,
		height: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- 使用指定的中心位置创建一个多边形混合物的定义。
	-- @param center (Vec2) 多边形的中心位置。
	-- @param width (number) 多边形的宽度。
	-- @param height (number) 多边形的高度。
	-- @param angle (number) [可选] 多边形的旋转角度，弧度制（默认为 0.0）。
	-- @param density (number) [可选] 多边形的密度（默认为 0.0）。
	-- @param friction (number) [可选] 多边形的摩擦力（默认为 0.4，应为 0.0 到 1.0）。
	-- @param restitution (number) [可选] 多边形的恢复力（默认为 0.0，应为 0.0 到 1.0）。
	-- @return (FixtureDef) 用于创建多边形混合物的定义对象。
	polygon: function(self: BodyDefClass,
		center: Vec2,
		width: number,
		height: number,
		angle?: number --[[0.0]],
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- 使用指定的顶点创建一个多边形混合物的定义。
	-- @param vertices ({Vec2}) 包含多边形顶点的表格。
	-- @param density (number) [可选] 多边形的密度（默认为 0.0）。
	-- @param friction (number) [可选] 多边形的摩擦力（默认为 0.4，应为 0.0 到 1.0）。
	-- @param restitution (number) [可选] 多边形的恢复力（默认为 0.0，应为 0.0 到 1.0）。
	-- @return (FixtureDef) 用于创建多边形混合物的定义对象。
	polygon: function(self: BodyDefClass,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- 创建由多个凸多边形组成的凹多边形混合物的定义。
	-- @param vertices ({Vec2}) 包含构成凹多边形的每个凸多边形的顶点的列表。
	-- 列表中的每个凸多边形都应以Vec2(0.0, 0.0)结尾作为分隔。
	-- @param density (number) [可选] 凹多边形的密度（默认值为0.0）。
	-- @param friction (number) [可选] 凹多边形的摩擦系数（默认值为0.4，应在0到1.0之间）。
	-- @param restitution (number) [可选] 凹多边形的弹性系数（默认值为0.0，应在0到1.0之间）。
	-- @return (FixtureDef) 用于创建凹多边形混合物的定义对象。
	multi: function(self: BodyDefClass,
		vertices: {Vec2},
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- 创建一个圆盘形混合物的定义。
	-- @param center (Vec2) 圆盘中心的坐标。
	-- @param radius (number) 圆盘的半径。
	-- @param density (number) [可选] 圆盘的密度（默认为0.0）。
	-- @param friction (number) [可选] 圆盘的摩擦系数（默认为0.4，应在0.0到1.0之间）。
	-- @param restitution (number) [可选] 圆盘的弹性系数（默认为0.0，应在0.0到1.0之间）。
	-- @return (FixtureDef) 用于创建圆盘形混合物的定义对象。
	disk: function(self: BodyDefClass,
		center: Vec2,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- 创建一个圆盘形混合物的定义。
	-- @param radius (number) 圆盘的半径。
	-- @param density (number) [可选] 圆盘的密度（默认为0.0）。
	-- @param friction (number) [可选] 圆盘的摩擦系数（默认为0.4，应在0.0到1.0之间）。
	-- @param restitution (number) [可选] 圆盘的弹性系数（默认为0.0，应在0.0到1.0之间）。
	-- @return (FixtureDef) 用于创建圆盘形混合物的定义对象。
	disk: function(self: BodyDefClass,
		radius: number,
		density?: number --[[0.0]],
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- 创建一个链条形状混合物的定义。链条形状是一组连续的线段，线段的两边都能触发碰撞。
	-- @param vertices ({Vec2}) 链条的顶点。
	-- @param friction (number) [可选] 链条的摩擦系数（默认值为0.4）。
	-- @param restitution (number) [可选] 链条的弹性系数（默认值为0.0）。
	-- @return (FixtureDef) 用于创建链条形混合物的定义对象。
	chain: function(self: BodyDefClass,
		vertices: {Vec2},
		friction?: number --[[0.4]],
		restitution?: number --[[0.0]]): FixtureDef

	-- 创建一个新的物理体定义的实例。
	-- @return (BodyDef) 新的物理体定义。
	metamethod __call: function(self: BodyDefClass): BodyDef
end

local bodyDefClass: BodyDefClass
return bodyDefClass
