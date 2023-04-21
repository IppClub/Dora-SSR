import "@site/src/languages/highlight";

# Move

**Description:**

&emsp;&emsp;Creates a definition for an action that animates the position of a Node from one Vec2 value to another.

**Signature:**
```tl
Move: function(
		duration: number,
		from: Vec2,
		to: Vec2,
		easing?: Ease.EaseFunc --[[Ease.Linear]]
	): ActionDef
```

**Parameters:**

| Parameter | Type | Description |
| --- | --- | --- |
| duration | number | The duration of the animation in seconds. |
| from | Vec2 | The starting position of the Node. |
| to | Vec2 | The ending position of the Node. |
| easing | EaseFunc | [optional] The easing function to use for the animation. Defaults to Ease.Linear if not specified. |

**Returns:**

| Return Type | Description |
| --- | --- |
| ActionDef | An ActionDef object that can be used to run the animation on a Node. |