import "@site/src/languages/highlight";

# sleep

**Description:**

&emsp;&emsp;Yield the coroutine for a specified duration.

**Signature:**
```tl
sleep: function(duration?: number)
```

**Parameters:**

| Parameter | Type | Description |
| --- | --- | --- |
| duration | number | [optional] The duration to yield for, in seconds. If nil, the coroutine will be yielded for one frame. |