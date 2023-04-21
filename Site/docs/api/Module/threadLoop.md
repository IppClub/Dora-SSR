import "@site/src/languages/highlight";

# threadLoop

**Description:**

&emsp;&emsp;Create a new coroutine from a function that runs repeatedly.

**Signature:**
```tl
threadLoop: function(routine: function(): boolean): Routine.Job
```

**Parameters:**

| Parameter | Type | Description |
| --- | --- | --- |
| routine | function | A function to execute repeatedly as a coroutine. |

**Returns:**

| Return Type | Description |
| --- | --- |
| Routine.Job | A handle to the coroutine that was created. |