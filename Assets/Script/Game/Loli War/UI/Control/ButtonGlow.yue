_ENV = Dorothy builtin.Platformer
import "UI.View.ButtonGlow"

export default Class ButtonGlow,
	__init:=>
		@slot "Tapped",(touch)->
			with Visual "Particle/select.par"
				.position = @convertToWorldSpace touch.location
				\addTo Director.ui
				\autoRemove!
				\start!

	glow:=>
		if not @scheduled
			Audio\play "Audio/select.wav"
			@schedule loop ->
				@up.visible = false
				@down.visible = true
				sleep 0.5
				@up.visible = true
				@down.visible = false
				sleep 0.5

	stopGlow:=>
		if @scheduled
			@unschedule!
			@up.visible = true
			@down.visible = false
