import "@site/src/languages/highlight";

# ScaleX

**Description:**

&emsp;&emsp;Creates a definition for an action that animates the x-axis scale of a Node from one value to another.

**Signature:**
```tl
ScaleX: function(
		duration: number,
		from: number,
		to: number,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef
```

**Parameters:**

| Parameter | Type | Description |
| --- | --- | --- |
| duration | number | The duration of the animation in seconds. |
| from | number | The starting value of the x-axis scale. |
| to | number | The ending value of the x-axis scale. |
| easing | EaseFunc | [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. |

**Returns:**

| Return Type | Description |
| --- | --- |
| ActionDef | An ActionDef object that can be used to run the animation on a Node. |