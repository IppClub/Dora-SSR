import "@site/src/languages/highlight";

# Spawn

**描述：**

&emsp;&emsp;创建一个定义，用于并行运行一组动作定义的动作。

**签名：**
```tl
Spawn: function(...: ActionDef): ActionDef
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| ... | ActionDef | 多个要同时运行的动作定义对象。 |

**返回值：**

| 返回类型 | 描述 |
| --- | --- |
| ActionDef | 一个动作定义对象，可用于在节点上运行该动作。 |