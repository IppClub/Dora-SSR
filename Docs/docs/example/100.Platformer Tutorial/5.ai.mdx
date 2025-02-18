# Writing Game Character AI Module

&emsp;&emsp;Welcome to the fifth tutorial of the Dora SSR game engine side-scrolling 2D game development series! In this tutorial, we will learn how to write the AI module for game characters. This module is primarily responsible for triggering different actions based on player input and the state of the game character.

&emsp;&emsp;Firstly, we need to import some necessary modules:

```tl title="Script/AI.tl"
local Platformer <const> = require("Platformer")
local Decision <const> = Platformer.Decision
local Sel <const> = Decision.Sel
local Seq <const> = Decision.Seq
local Con <const> = Decision.Con
local Act <const> = Decision.Act
local Data <const> = Platformer.Data
local type UnitType = Platformer.Unit.Type
```

&emsp;&emsp;Next, we use the [decision tree framework](/docs/api/Class/Platformer/Decision) to create the AI. A decision tree is a commonly used AI design pattern that determines which action to execute based on a series of conditions. In this example, we utilize [Sel](/docs/api/Class/Platformer/Decision#sel) (selector node) and [Seq](/docs/api/Class/Platformer/Decision#seq) (sequence node) to organize the decision tree, [Con](/docs/api/Class/Platformer/Decision#con) (condition node) to check conditions, and [Act](/docs/api/Class/Platformer/Decision#act) (action node) to execute actions.

```tl title="Script/AI.tl"
Data.store["AI:playerControl"] = Sel {
	Seq {
		Con("move key down", function(self: UnitType): boolean
			return not (self.entity.keyLeft and self.entity.keyRight) and
			(
				(self.entity.keyLeft and self.faceRight) or
				(self.entity.keyRight and not self.faceRight)
			)
		end),
		Act("turn")
	},
	Seq {
		Con("is falling", function(self: UnitType): boolean
			return not self.onSurface
		end),
		Act("fallOff")
	},
	Seq {
		Con("jump key down", function(self: UnitType): boolean
			return self.entity.keyJump as boolean
		end),
		Act("jump")
	},
	Seq {
		Con("fmove key down", function(self: UnitType): boolean
			return (self.entity.keyLeft or self.entity.keyRight) as boolean
		end),
		Act("move")
	},
	Act("idle")
}
```

&emsp;&emsp;In this decision tree, we first check if a turn is needed, and if so, execute the turn action. Then, we check if the character is falling, and if true, execute the fallOff action. Next, we check if the jump key is pressed, and if so, execute the jump action. After that, we check if the move key is pressed, and if so, execute the move action. Finally, if none of the above conditions are met, we execute the idle action.

&emsp;&emsp;This decision tree design is very simple, yet it is capable of handling most of the game character control requirements. In actual game development, you may need to design more complex decision trees based on the specific needs of your game.

&emsp;&emsp;With this, our game character AI module is now complete. In the upcoming tutorials, we will use this AI to control the behavior of game characters. We hope you can keep up with us and learn how to use the Dora SSR game engine together!