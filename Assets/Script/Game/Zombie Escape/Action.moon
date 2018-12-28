Dorothy builtin.Platformer

groundEntranceEnd = (name,model)->
	return unless name == "groundEntrance"
	model.parent\stop!

UnitAction\add "groundEntrance",
	priority: 6
	reaction: 999
	recovery: 0
	available: -> true
	create: =>
		@entity.lastGroup = @group
		@group = 0
		with @model
			.speed = 1
			.loop = false
			\slot "AnimationEnd",groundEntranceEnd
			\play "groundEntrance"
		-> false,
	stop: =>
		@model\slot("AnimationEnd")\remove groundEntranceEnd
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
			with @model
				.speed = 1
				.loop = false
				\play "fallOff"
		else @entity.fallDown = false
		(action)=>
			return true if @onSurface
			if not @entity.fallDown and
				@model.currentAnimation ~= "fallOff" and
				@velocityY <= 0
				@entity.fallDown = true
				with @model
					.speed = 1
					.loop = false
					\play "fallOff"
			false,
	stop: =>
		@model\stop!

UnitAction\add "backJump",
	priority: 2
	reaction: 10
	recovery: 0
	available: => @onSurface
	create: =>
		@faceRight = not @faceRight
		with @model
			.speed = 1
			.loop = true
			\play "walk"
		@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
		loop =>
			cycle 0.3,->
				@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
			@faceRight = not @faceRight
			cycle 0.1,->
				@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed	
			@velocityY = @jump
			@velocityX = (@faceRight and 1 or -1)*@move*@moveSpeed
			with @model
				.speed = 1
				.loop = false
				\play "jump"
			sleep 0.2
			true
	stop: =>
		@model\stop!
