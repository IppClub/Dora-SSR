Dorothy builtin.Platformer

groundEntranceEnd = (name,playable)->
	return unless name == "groundEntrance"
	playable.parent\stop!

UnitAction\add "groundEntrance",
	priority: 6
	reaction: 999
	recovery: 0
	available: -> true
	create: =>
		@entity.lastGroup = @group
		@group = 0
		with @playable
			.speed = 1
			\slot "AnimationEnd",groundEntranceEnd
			\play "groundEntrance"
		-> false
	stop: =>
		@playable\slot("AnimationEnd")\remove groundEntranceEnd
		@group = @entity.lastGroup
		@entity.lastGroup = nil
		@entity.entered = true

UnitAction\add "fallOff",
	priority: 1
	reaction: 1
	recovery: 0
	available: => not @onSurface
	create: =>
		if @velocityY <= 0
			@entity.fallDown = true
			with @playable
				.speed = 1
				\play "fallOff"
		else @entity.fallDown = false
		(action)=>
			return true if @onSurface
			if not @entity.fallDown and
				@playable.currentAnimation ~= "fallOff" and
				@velocityY <= 0
				@entity.fallDown = true
				with @playable
					.speed = 1
					\play "fallOff"
			false

UnitAction\add "backJump",
	priority: 2
	reaction: 10
	recovery: 0
	available: => @onSurface
	create: =>
		@faceRight = not @faceRight
		with @playable
			.speed = 1
			\play "walk", true
		@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
		loop =>
			cycle 0.3,->
				@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
			@faceRight = not @faceRight
			cycle 0.1,->
				@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed	
			@velocityY = @jump
			@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
			with @playable
				.speed = 1
				\play "jump"
			sleep 0.2
			true
