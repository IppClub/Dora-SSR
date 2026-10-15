# 编写游戏角色动作模块

&emsp;&emsp;欢迎来到Dora SSR游戏引擎横版2D游戏开发教程的第四篇！在这篇教程中，我们将介绍如何编写游戏角色动作模块。在游戏中，角色的动作是非常重要的一部分，它们决定了角色的行为和反应。我们将使用Dora SSR游戏引擎的[UnitAction](/docs/api/Class%20Object/Platformer/UnitAction)类来定义和管理角色的动作。

&emsp;&emsp;首先，我们需要引入一些必要的模块：

```tl title="Script/Action.tl"
local once <const> = require("once")
local loop <const> = require("loop")
local sleep <const> = require("sleep")
local type Routine = require("Routine")
local Platformer <const> = require("Platformer")
local UnitAction <const> = Platformer.UnitAction
local type UnitType = Platformer.Unit.Type
```

&emsp;&emsp;接着，我们使用UnitAction的[add](/docs/api/Class%20Object/Platformer/UnitAction#add)方法来添加新的动作。每个动作都有一个名称和一组[参数](/docs/api/Class/Platformer/UnitActionParam)，这些参数定义了动作的行为。例如，我们可以定义一个"idle"动作，表示角色在空闲状态下的行为：

```tl title="Script/Action.tl"
UnitAction:add("idle", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self: UnitType): boolean
		return self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		-- 在动作初始执行时播放普通的待机动画
		local playable = self.playable
		playable.speed = 1.0
		playable:play("idle", true)

		-- 创建一个协程每隔3秒播放特殊的待机动画
		local playIdleSpecial = loop(function(): boolean
			sleep(3)
			sleep(playable:play("idle1"))
			playable:play("idle", true)
		end)

		-- 把新建协程对象的生命周期管理交给引擎
		-- 自从Lua 5.4新增__close元方法后，未变为`dead`状态的协程就不会被Lua自动释放，
		-- 需要手动调用coroutine.close()方法释放协程相关资源，所以建议将自建的协程对象
		-- 通过如下的方式交给引擎管理
		self.data.playIdleSpecial = playIdleSpecial

		-- 返回一个函数持续进行动作的逻辑处理
		return function(owner: UnitType): boolean
			coroutine.resume(playIdleSpecial)
			return not owner.onSurface
		end
	end
})
```

&emsp;&emsp;在这个例子中，我们设置了动作的优先级、反应时间和恢复时间。优先级决定了当多个动作同时触发时，哪个动作会被执行。反应时间决定了AI检查的周期时间，恢复时间主要影响动画模型在不同动作中播放动画做切换的动画过渡时间。我们还定义了一个[available](/docs/api/Class/Platformer/UnitActionParam#available)函数，用于检查角色是否可以执行这个动作。在这个例子中，角色只有在地面上时才可以执行"idle"动作。

&emsp;&emsp;[create](/docs/api/Class/Platformer/UnitActionParam#create)函数用于创建动作的初始状态，并返回一个函数或协程，用于处理动作的逻辑。当返回一个函数时，这个函数将会被每帧调用，直到函数返回值为true时，停止调用。如果返回的是一个协程，这个协程也会被每帧进行resume调度，直到协程在执行中抛出（yield）true的返回值。在这个例子中，我们创建了一个协程，用于循环播放角色的普通和特殊空闲动画，并同时反复检查角色和地面接触的状态，如果离了开地面，动作执行就会被终止。

&emsp;&emsp;当然，我们可以继续深入讲解"move"、"jump"和"fallOff"这三个动作的定义。

&emsp;&emsp;首先，我们来看"move"动作：

```tl title="Script/Action.tl"
UnitAction:add("move", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self: UnitType): boolean
		return self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		-- 在动作初始执行时播放行走动画
		local playable = self.playable
		playable.speed = 1
		playable:play("fmove", true)

		-- 返回一个函数持续进行动作的逻辑处理
		return function(self: UnitType, action: UnitAction.Type): boolean
			local eclapsedTime = action.eclapsedTime
			local recovery = action.recovery * 2
			local move = self.unitDef.move as number
			local moveSpeed: number = 1.0
			if eclapsedTime < recovery then
				moveSpeed = math.min(eclapsedTime / recovery, 1.0)
			end
			self.velocityX = moveSpeed * (self.faceRight and move or -move)
			return not self.onSurface
		end
	end
})
```

&emsp;&emsp;"move"动作的可用性条件是角色必须在地面上。在创建动作时，我们设置了角色的动画为"fmove"，并且在每一帧中，我们都会根据角色的面向方向和移动速度来更新角色的水平速度。如果动作的执行时间小于恢复时间的两倍，我们会逐渐增加角色的移动速度，以实现一个平滑的加速效果。

&emsp;&emsp;接下来是"jump"动作：

```tl title="Script/Action.tl"
UnitAction:add("jump", {
	priority = 3,
	reaction = 2.0,
	recovery = 0.1,
	queued = true,
	available = function(self: UnitType): boolean
		return self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		-- 在动作开始执行时改变角色的Y轴移动速度
		self.velocityY = self.unitDef.jump as number

		-- 在后续动作更新时播放跳跃动画并等待动画播放结束
		return once(function()
			local playable = self.playable
			playable.speed = 1
			sleep(playable:play("jump", false))
		end)
	end
})
```

&emsp;&emsp;"jump"动作的优先级比"idle"和"move"动作更高，这意味着当角色同时可以执行"jump"和其他动作时，"jump"动作会被优先执行。在create函数中，我们首先设置角色的速度，使其向上跳跃，然后播放跳跃动画。

&emsp;&emsp;最后是"fallOff"动作：

```tl title="Script/Action.tl"
UnitAction:add("fallOff", {
	priority = 2,
	reaction = -1,
	recovery = 0.3,
	available = function(self: UnitType): boolean
		return not self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		-- 检查并播放下落动画
		if self.playable.current ~= "jumping" then
			local playable = self.playable
			playable.speed = 1
			playable:play("jumping", true)
		end

		-- 检测角色落地状态并在播放落地动画后结束动作
		return loop(function(self: UnitType): boolean
			if self.onSurface then
				local playable = self.playable
				playable.speed = 1
				sleep(playable:play("landing", false))
				return true
			else
				return false
			end
		end)
	end
})
```

&emsp;&emsp;"fallOff"动作在角色不在地面上时可用，这通常意味着角色正在空中。在create函数中，我们首先检查角色当前是否正在播放跳跃动画，如果不是，则播放跳跃动画。然后在返回的函数中，我们检查角色是否已经落地，如果已经落地，则播放落地动画，并结束动作。

&emsp;&emsp;这就是"idle"、"move"、"jump"和"fallOff"这三个动作的定义。通过这些动作，我们可以控制角色在游戏中的行为，使其能够移动、跳跃和落地。

&emsp;&emsp;至此，我们的游戏角色动作模块就编写完成了。在接下来的教程中，我们将使用这些动作来控制角色的行为，并实现游戏的逻辑。希望你能跟上我们的步伐，一起学习Dora SSR游戏引擎的使用方法！