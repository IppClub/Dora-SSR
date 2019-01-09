Dorothy builtin.Platformer
ButtonGlowView = require "UI.View.ButtonGlow"

Class ButtonGlowView,
	__init:=>
		@slot "Tapped",(touch)->
			with Visual "Particle/select.par"
				.position = @convertToWorldSpace touch.location
				\addTo Director.ui
				\autoRemove!
				\start!

	glow:=>
		if not @scheduled
			@schedule loop ->
				@up.visible = false
				@down.visible = true
				sleep 0.5
				@up.visible = true
				@down.visible = false
				sleep 0.5

	stopGlow:=>
		if @scheduled
			@unschedule()
			@up.visible = true
			@down.visible = false
