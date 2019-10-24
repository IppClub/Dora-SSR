Dorothy!

print Content\getFullPath("Game/Loli War")
Content\insertSearchPath 1, "Game/Loli War"

print Content\getFullPath("UI/Control/HPWheel.moon")
require = namespace "Game/Loli War"
require "Constant"
require "Bullet"
require "Unit"
require "AI"
require "Action"
require "Logic"
require "Control"
require "Scene"

Content\removeSearchPath "Game/Loli War"

