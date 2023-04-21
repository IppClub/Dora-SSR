import "@site/src/languages/highlight";

# Body的节点事件

**描述：**

&emsp;&emsp;物理对象碰撞事件的信号槽定义。将物理体对象的“receivingContact“属性设置为true时，可以触发并接收到这些信号槽事件。

**用法示例：**
```tl
-- 可以使用以下形式的代码来注册监听这些事件：
body.receivingContact = true
body:slot("BodyEnter", function(other: Body, sensorTag: integer)
	print("感应器感应到了物理体", other, sensorTag)
end)
```

## BodyEnter

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当物理体对象与传感器对象碰撞时触发。

**签名：**
```tl
["BodyEnter"]: function(other: Body, sensorTag: integer)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| other | Body | 当前发生碰撞的物理体对象。 |
| sensorTag | integer | 触发此碰撞事件的传感器的标签编号。 |

## BodyLeave

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当物理体对象不再与传感器对象碰撞时触发。

**签名：**
```tl
["BodyLeave"]: function(other: Body, sensorTag: integer)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| other | Body | 当前结束碰撞的物理体对象。 |
| sensorTag | integer | 触发此碰撞事件的传感器的标签。 |

## ContactStart

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当一个物理体对象开始与另一个物理体碰撞时触发。

**签名：**
```tl
["ContactStart"]: function(other: Body, point: Vec2, normal: Vec2)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| other | Body | 被碰撞的物理体对象。 |
| point | Vec2 | 世界坐标系中的碰撞点。 |
| normal | Vec2 | 世界坐标系中的接触表面法向量。 |

## ContactEnd

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当一个物理体对象停止与另一个物理体碰撞时触发。

**签名：**
```tl
["ContactEnd"]: function(other: Body, point: Vec2, normal: Vec2)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| other | Body | 结束碰撞的物理体对象。 |
| point | Vec2 | 世界坐标系中的碰撞点。 |
| normal | Vec2 | 世界坐标系中的接触表面法向量。 |