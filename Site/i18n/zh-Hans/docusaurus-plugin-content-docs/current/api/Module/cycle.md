import "@site/src/languages/highlight";

# cycle

**描述：**

&emsp;&emsp;在一段时间内每帧重复运行一个函数的携程。

**签名：**
```tl
cycle: function(duration: number, work: function(time: number))
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| duration | number | 持续运行的时间，以秒为单位。 |
| work | function | 在持续运行期间被重复执行的函数。将接收一个时间进度参数time，告知已经过的运行时间，参数值区间为0-1，0表示刚开始，1表示刚结束。 |