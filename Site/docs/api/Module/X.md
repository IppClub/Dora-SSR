import "@site/src/languages/highlight";

# X

**Description:**

&emsp;&emsp;Creates a definition for an action that animates the x-position of a Node.

**Signature:**
```tl
X: function(
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
| from | number | The starting x-position of the Node. |
| to | number | The ending x-position of the Node. |
| easing | EaseFunc | [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. |

**Returns:**

| Return Type | Description |
| --- | --- |
| ActionDef | An ActionDef object that can be used to run the animation on a Node. |