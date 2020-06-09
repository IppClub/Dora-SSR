_ENV = Dorothy builtin.Platformer
import "UI.View.HPWheel"
import "UI.View.EPHint"
{
	:GroupPlayer
	:GroupEnemy
	:GroupPlayerBlock
	:GroupEnemyBlock
	:MaxEP
	:MaxHP
} = Data.store

export default Class HPWheel,
	__init:=>
		@ep = MaxEP
		@hp = MaxHP
		@hints = {}

		@hpShow\slot "AnimationEnd",(name)->
			@hpShow\play "idle" if name == "hit"

		@gslot "HPChange",(group,value)->
			if group == GroupPlayer
				newHP = math.max @hp+value,0
				@hp = math.floor(math.max(math.min(MaxHP,newHP),0)+0.5)
				@hpShow.look = tostring @hp
				@hpShow\play "hit" if value < 0

		@gslot "EPChange",(group,value)->
			if group == GroupPlayer
				switch value
					when 1,-1,-2,6
						@ep = math.floor(math.max(math.min(MaxEP,@ep+value),0)+0.5)
						@fill\perform ScaleX 0.2,@fill.scaleX,@ep/MaxEP
						hint = with EPHint index:#@hints+1,clip:string.format("%+d",value)
							.index = #@hints+1
							\slot "DisplayEnd",->
								index = hint.index
								hint\removeFromParent!
								table.remove @hints,index
								for i,v in ipairs @hints
									v\runAction X 0.2, v.x, 55+25*(i-1)
									v.index = i
						table.insert @hints,hint
						@energy\addChild hint

		@gslot "BlockValue",(group,value)->
			switch group
				when GroupPlayer
					@playerBlocks.value = value
				when GroupEnemy
					@enemyBlocks.value = value

		@gslot "BlockChange",(group,value)->
			switch group
				when GroupPlayer
					@playerBlocks.value = math.max @playerBlocks.value+value,0
				when GroupEnemy
					@enemyBlocks.value = math.max @enemyBlocks.value+value,0
