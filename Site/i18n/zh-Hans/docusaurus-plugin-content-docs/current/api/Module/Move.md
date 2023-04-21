import "@site/src/languages/highlight";

# Move

**描述：**

&emsp;&emsp;创建一个动作定义，用于动态改变节点的位置。

**签名：**
```tl
Move: function(
		duration: number,
		from: Vec2,
		to: Vec2,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| duration | number | 动作的持续时间（秒）。 |
| from | Vec2 | 节点的起始位置。 |
| to | Vec2 | 节点的结束位置。 |
| easing | EaseFunc | [可选] 动作使用的缓动函数。如果未指定，默认为Ease.Linear。 |

**返回值：**

| 返回类型 | 描述 |
| --- | --- |
| ActionDef | 可用于在节点上运行动作的定义对象。 |