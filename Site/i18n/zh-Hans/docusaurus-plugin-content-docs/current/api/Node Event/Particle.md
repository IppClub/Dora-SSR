import "@site/src/languages/highlight";

# Particle的节点事件

**描述：**

&emsp;&emsp;可连接到粒子系统节点对象上可以监听的事件。
这只是一个事件定义的展示，定义事件名称和回调。

## Finished

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当粒子系统节点在启动之后又停止发射粒子，并等待所有已发射的粒子结束它们的生命周期时触发。

**签名：**
```tl
["Finished"]: function()
```