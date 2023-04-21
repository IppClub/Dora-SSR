import "@site/src/languages/highlight";

# emit

**描述：**

&emsp;&emsp;向通过`node:gslot()`函数注册的所有监听器发送包含特定事件名称和参数的全局事件。

**签名：**
```tl
emit: function(eventName: string, ...: any)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| eventName | string | 要发送的全局事件的名称。 |
| ... | ...any | 要发送给全局事件监听器的参数数据。 |