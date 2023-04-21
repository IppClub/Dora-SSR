import "@site/src/languages/highlight";

# SkewY

**Description:**

&emsp;&emsp;Creates a definition for an action that animates the skew of a Node along the y-axis.

**Signature:**
```tl
SkewY: function(
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
| from | number | The starting skew value of the Node on the y-axis (in degrees). |
| to | number | The ending skew value of the Node on the y-axis (in degrees). |
| easing | EaseFunc | [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. |

**Returns:**

| Return Type | Description |
| --- | --- |
| ActionDef | An ActionDef object that can be used to run the animation on a Node. |