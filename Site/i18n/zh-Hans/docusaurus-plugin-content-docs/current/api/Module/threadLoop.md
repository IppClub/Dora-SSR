import "@site/src/languages/highlight";

# threadLoop

**描述：**

&emsp;&emsp;用一个要被重复运行的任务函数创建一个新的协程任务。

**签名：**
```tl
threadLoop: function(routine: function(): boolean): Routine.Job
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| routine | function | 要进行重复执行的函数。 |

**返回值：**

| 返回类型 | 描述 |
| --- | --- |
| Routine.Job | 创建的协程任务对象。 |