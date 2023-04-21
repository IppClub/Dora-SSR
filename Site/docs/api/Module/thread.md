import "@site/src/languages/highlight";

# thread

**Description:**

&emsp;&emsp;Creates a new coroutine from a function and executes it.

**Signature:**
```tl
thread: function(routine: function(): boolean): Routine.Job
```

**Parameters:**

| Parameter | Type | Description |
| --- | --- | --- |
| routine | function | A function to execute as a coroutine. |

**Returns:**

| Return Type | Description |
| --- | --- |
| Routine.Job | A handle to the coroutine that was created. |