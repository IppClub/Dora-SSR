_ENV = Dorothy!

Director.entry\addChild with Spine "dragon-ess.skel","dragon.atlas"
	\play "flying", true
	\slot "AnimationEnd", (name)-> print "#{name} end!"
