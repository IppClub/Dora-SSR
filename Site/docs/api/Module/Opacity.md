import "@site/src/languages/highlight";

# Opacity

**Description:**

&emsp;&emsp;Creates a definition for an action that animates the opacity of a Node from one value to another.

**Signature:**
```tl
Opacity: function(
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
| from | number | The starting opacity value of the Node (0-255). |
| to | number | The ending opacity value of the Node (0-255). |
| easing | EaseFunc | [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. |

**Returns:**

| Return Type | Description |
| --- | --- |
| ActionDef | An ActionDef object that can be used to run the animation on a Node. |