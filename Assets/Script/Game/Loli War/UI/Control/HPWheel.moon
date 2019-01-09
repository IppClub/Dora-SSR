Dorothy builtin.Platformer
HPWheelView = require "UI.View.HPWheel"
EPHint = require "UI.View.EPHint"
{:GroupPlayer,:GroupEnemy} = Data.store

Class HPWheelView,
	__init:=>
		@ep = 8
		@maxEP = 8
		@hp = 8
		@maxHP = 8
		@hints = {}

		@hpShow\slot "AnimationEnd",(name)->
			@hpShow\play "idle" if name == "hit"

		@gslot "HPChange",(group,value)->
			if group == GroupPlayer
				@hp = math.floor(math.max(math.min(@maxHP,@hp+value),0)+0.5)
				@hpShow.look = tostring @hp
				@hpShow\play "hit" if value < 0

		@gslot "EPChange",(group,value)->
			if group == GroupPlayer
				switch value
					when 1,-1,-2,6
						@ep = math.floor(math.max(math.min(@maxEP,@ep+value),0)+0.5)
						@fill\perform ScaleX 0.2,@fill.scaleX,@ep/@maxEP
						hint = with EPHint index:#@hints+1,clip:string.format("%+d",value)
							.index = #@hints+1
							\slot "DisplayEnd",(endHint)->
								index = endHint.index
								endHint\removeFromParent!
								table.remove @hints,index
								for i,v in ipairs @hints
									v\runAction X 0.2, v.x, 55+25*(i-1)
									v.index = i
						table.insert @hints,hint
						@energy\addChild hint

		@gslot "BlockChange",(group,value)->
			switch group
				when GroupPlayer
					@playerBlocks.value = value
				when GroupEnemy
					@enemyBlocks.value = value

