# Writing Game Character Action Module

&emsp;&emsp;Welcome to the fourth tutorial of the Dora SSR game engine side-scrolling 2D game development series! In this tutorial, we will learn how to write the game character action module. In a game, the actions of the characters are a crucial part as they determine the behavior and reactions of the characters. We will use the [UnitAction](/docs/api/Class%20Object/Platformer/UnitAction) class from the Dora SSR game engine to define and manage the character actions.

&emsp;&emsp;Firstly, we need to import some necessary modules:

```tl title="Script/Action.tl"
local once <const> = require("once")
local loop <const> = require("loop")
local sleep <const> = require("sleep")
local type Routine = require("Routine")
local Platformer <const> = require("Platformer")
local UnitAction <const> = Platformer.UnitAction
local type UnitType = Platformer.Unit.Type
```

&emsp;&emsp;Next, we use the [add](/docs/api/Class%20Object/Platformer/UnitAction#add) method of UnitAction to add new actions. Each action has a name and a set of [parameters](/docs/api/Class/Platformer/UnitActionParam) that define its behavior. For example, we can define an "idle" action that represents the character's behavior in an idle state:

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
		-- Play a normal idle animation when the action is initially executed
		local playable = self.playable
		playable.speed = 1.0
		playable:play("idle", true)

		-- Create a coroutine to play a special idle animation every 3 seconds
		local playIdleSpecial = loop(function(): boolean
			sleep(3)
			sleep(playable:play("idle1"))
			playable:play("idle", true)
		end)

		-- Assign the newly created coroutine object to the engine for lifecycle management
		-- Since Lua 5.4 introduced the __close metamethod, coroutines that are not in the `dead` state
		-- will not be automatically released by Lua. Therefore, it is recommended to use the following
		-- method to assign self-built coroutine objects to the engine for management
		self.data.playIdleSpecial = playIdleSpecial

		-- Return a function that continuously handles the logic of the action
		return function(owner: UnitType): boolean
			coroutine.resume(playIdleSpecial)
			return not owner.onSurface
		end
	end
})
```

&emsp;&emsp;In this example, we set the priority, reaction time, and recovery time of the action. The priority determines which action will be executed when multiple actions are triggered simultaneously. The reaction time determines the period at which AI checks are performed, and the recovery time primarily affects the animation transition time when switching between different actions. We also define an [available](/docs/api/Class/Platformer/UnitActionParam#available) function to check if the character can perform this action. In this example, the character can only perform the "idle" action when it is on the ground.

&emsp;&emsp;The [create](/docs/api/Class/Platformer/UnitActionParam#create) function is used to create the initial state of the action and return a function or coroutine to handle the action's logic. When returning a function, this function will be called per frame until the function returns true, at which point the calls stop. If a coroutine is returned, it will also be scheduled for resume per frame until the coroutine yields (returns) true during execution. In this example, we create a coroutine that loops to play both the normal and special idle animations of the character and repeatedly checks the status of the character's contact with the ground. If the character leaves the ground, the action execution will be terminated.

&emsp;&emsp;Of course, we can continue to explain the definitions of the "move", "jump", and "fallOff" actions in more detail.

&emsp;&emsp;First, let's look at the "move" action:

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
		-- Play a walking animation when the action is initially executed
		local playable = self.playable
		playable.speed = 1
		playable:play("fmove", true)

		-- Return a function that continuously handles the logic of the action
		return function(self: UnitType, action: UnitAction.Type): boolean
			local elapsedTime = action.elapsedTime
			local recovery = action.recovery * 2
			local move = self.unitDef.move as number
			local moveSpeed: number = 1.0
			if elapsedTime < recovery then
				moveSpeed = math.min(elapsedTime / recovery, 1.0)
			end
			self.velocityX = moveSpeed * (self.faceRight and move or -move)
			return not self.onSurface
		end
	end
})
```

&emsp;&emsp;The "move" action is available when the character is on the ground. When creating the action, we set the character's animation to "fmove", and in each frame, we update the character's horizontal velocity based on the character's facing direction and movement speed. If the execution time of the action is less than twice the recovery time, we gradually increase the character's movement speed to achieve smooth acceleration.

&emsp;&emsp;Next is the "jump" action:

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
		-- Set the character's vertical velocity when the action starts executing
		self.velocityY = self.unitDef.jump as number

		-- Play the jump animation and wait for the animation to finish in subsequent action updates
		return once(function()
			local playable = self.playable
			playable.speed = 1
			sleep(playable:play("jump", false))
		end)
	end
})
```

&emsp;&emsp;The "jump" action has a higher priority than the "idle" and "move" actions, which means that when the character can perform both the "jump" action and another action simultaneously, the "jump" action takes priority. In the create function, we first set the character's velocity to make it jump upward, and then play the jump animation.

&emsp;&emsp;Lastly, the "fallOff" action:

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
		-- Check and play the falling animation
		if self.playable.current ~= "jumping" then
			local playable = self.playable
			playable.speed = 1
			playable:play("jumping", true)
		end

		-- Check the character's landing status and end the action after playing the landing animation
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

&emsp;&emsp;The "fallOff" action is available when the character is not on the ground, which typically means the character is in the air. In the create function, we first check if the character is currently playing the jump animation. If not, we play the jump animation. Then, in the returned function, we check if the character has landed. If the character has landed, we play the landing animation and end the action.

&emsp;&emsp;These are the definitions of the "idle", "move", "jump", and "fallOff" actions. With these actions, we can control the behavior of the character in the game, allowing it to move, jump, and land.

&emsp;&emsp;With this, we have completed the game character action module. In the upcoming tutorials, we will use these actions to control the character's behavior and implement the game logic. We hope you can keep up with us and learn how to use the Dora SSR game engine!