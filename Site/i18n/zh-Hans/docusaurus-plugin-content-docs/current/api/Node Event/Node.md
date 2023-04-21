import "@site/src/languages/highlight";

# Node的节点事件

**描述：**

&emsp;&emsp;节点可监听的事件的定义。
这只是一个演示记录，展示了信号插槽的名称和回调。

**用法示例：**
```tl
-- 可以使用如下示例代码注册监听这些事件：
node:slot("ActionEnd", function(action: Action, target: Node)
	print("Action end", action, target)
end)
```

## ActionEnd

**类型：** 节点事件。

**描述：**

&emsp;&emsp;ActionEnd事件会在节点执行完一个动作时触发。
在`node:runAction()`和`node:perform()`之后触发。

**签名：**
```tl
["ActionEnd"]: function(action: Action, target: Node)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| action | Action | 执行完成的动作。 |
| target | Node | 执行完成动作的节点。 |

## TapFilter

**类型：** 节点事件。

**描述：**

&emsp;&emsp;TapFilter事件在TapBegan插槽之前触发，可用于过滤某些点击事件。
在设置`node.touchEnabled = true`之后才会触发。

**签名：**
```tl
["TapFilter"]: function(touch: Touch)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| touch | Touch | 点击事件的消息对象。 |

## TapBegan

**类型：** 节点事件。

**描述：**

&emsp;&emsp;TapBegan事件在检测到点击时触发。
在设置`node.touchEnabled = true`之后才会触发。

**签名：**
```tl
["TapBegan"]: function(touch: Touch)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| touch | Touch | 点击事件的消息对象。 |

## TapEnded

**类型：** 节点事件。

**描述：**

&emsp;&emsp;TapEnded事件在点击结束时触发。
在设置`node.touchEnabled = true`之后才会触发。

**签名：**
```tl
["TapEnded"]: function(touch: Touch)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| touch | Touch | 点击事件的消息对象。 |

## Tapped

**类型：** 节点事件。

**描述：**

&emsp;&emsp;Tapped事件在检测到并结束点击时触发。
在设置`node.touchEnabled = true`之后才会触发。

**签名：**
```tl
["Tapped"]: function(touch: Touch)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| touch | Touch | 点击事件的消息对象。 |

## TapMoved

**类型：** 节点事件。

**描述：**

&emsp;&emsp;TapMoved事件在点击移动时触发。
在设置`node.touchEnabled = true`之后才会触发。

**签名：**
```tl
["TapMoved"]: function(touch: Touch)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| touch | Touch | 点击事件的消息对象。 |

## MouseWheel

**类型：** 节点事件。

**描述：**

&emsp;&emsp;MouseWheel事件在滚动鼠标滚轮时触发。
在设置`node.touchEnabled = true`之后才会触发。

**签名：**
```tl
["MouseWheel"]: function(delta: Vec2)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| delta | Vec2 | 滚动的向量。 |

## Gesture

**类型：** 节点事件。

**描述：**

&emsp;&emsp;Gesture事件在识别到多点手势时触发。
在设置`node.touchEnabled = true`之后才会触发。

**签名：**
```tl
["Gesture"]: function(center: Vec2, numFingers: integer, deltaDist: number, deltaAngle: number)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| center | Vec2 | 手势的中心点。 |
| numFingers | integer | 手势涉及的触摸点数量。 |
| deltaDist | number | 手势移动的距离。 |
| deltaAngle | number | 手势的变动角度。 |

## Enter

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当节点被添加到场景树中时，触发Enter事件。
当执行`node:addChild()`时触发。

**签名：**
```tl
["Enter"]: function()
```

## Exit

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当节点从场景树中移除时，触发Exit事件。
当执行`node:removeChild()`时触发。

**签名：**
```tl
["Exit"]: function()
```

## Cleanup

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当节点被清理时，触发Cleanup事件。
仅当执行`parent:removeChild(node, true)`时触发。

**签名：**
```tl
["Cleanup"]: function()
```

## KeyDown

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当按下某个键盘按键时，触发KeyDown事件。
在设置`node.keyboardEnabled = true`后才会触发。

**签名：**
```tl
["KeyDown"]: function(keyName: Keyboard.KeyName)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| keyName | string | 被按下的键的名称。 |

## KeyUp

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当释放某个键盘按键时，触发KeyUp事件。
在设置`node.keyboardEnabled = true`后才会触发。

**签名：**
```tl
["KeyUp"]: function(keyName: Keyboard.KeyName)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| keyName | string | 被释放的键的名称。 |

## KeyPressed

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当持续按下某个键时，触发KeyPressed事件。
在设置`node.keyboardEnabled = true`后才会触发。

**签名：**
```tl
["KeyPressed"]: function(keyName: Keyboard.KeyName)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| keyName | string | 被持续按下的键的名称。 |

## AttachIME

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当系统输入法（IME）开启到节点（调用`node: attachIME()`）时，会触发AttachIME事件。

**签名：**
```tl
["AttachIME"]: function()
```

## DetachIME

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当系统输入法（IME）关闭（调用`node: detachIME()`或手动关闭IME）时，会触发DetachIME事件。

**签名：**
```tl
["DetachIME"]: function()
```

## TextInput

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当接收到系统输入法文本输入时，会触发TextInput事件。
在调用`node:attachIME()`之后触发。

**签名：**
```tl
["TextInput"]: function(text: string)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| text | string | 输入的文本。 |

## TextEditing

**类型：** 节点事件。

**描述：**

&emsp;&emsp;当系统输入法文本正在被编辑时，会触发TextEditing事件。
在调用`node:attachIME()`之后触发。

**签名：**
```tl
["TextEditing"]: function(text: string, startPos: integer)
```

**参数：**

| 参数名 | 类型 | 描述 |
| --- | --- | --- |
| text | string | 正在编辑的文本。 |
| startPos | integer | 正在编辑的文本的起始位置。 |