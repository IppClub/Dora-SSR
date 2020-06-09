_ENV = Dorothy builtin.Platformer
import "UI.Control.Basic.AlignNode"
import "UI.View.Shape.Rectangle"
import "UI.View.Shape.Circle"
import "UI.View.Shape.Star"
import "UI.Control.Basic.CircleButton"
{store:Store} = Data

Store.controlPlayer = "KidW"
playerGroup = Group {"player"}
updatePlayerControl = (key,flag)->
	player = nil
	playerGroup\each => player = @ if @unit.tag == Store.controlPlayer
	player[key] = flag if player
uiScale = App.deviceRatio

with AlignNode isRoot:true
	.visible = false
	\addChild with AlignNode!
		.hAlign = "Left"
		.vAlign = "Bottom"
		\addChild with Menu!
			\addChild with CircleButton {
					text: "Left"
					x: 20*uiScale
					y: 60*uiScale
					radius: 30*uiScale
					fontSize: 18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyLeft",true
				\slot "TapEnded",-> updatePlayerControl "keyLeft",false
			\addChild with CircleButton {
					text: "Right"
					x: 90*uiScale
					y: 60*uiScale
					radius: 30*uiScale
					fontSize: 18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyRight",true
				\slot "TapEnded",-> updatePlayerControl "keyRight",false
	\addChild with AlignNode!
		.hAlign = "Right"
		.vAlign = "Bottom"
		\addChild with Menu!
			\addChild with CircleButton {
					text: "Jump"
					x: -80*uiScale
					y: 60*uiScale
					radius: 30*uiScale
					fontSize: 18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyUp",true
				\slot "TapEnded",-> updatePlayerControl "keyUp",false
			\addChild with CircleButton {
					text: "Shoot"
					x: -150*uiScale
					y: 60*uiScale
					radius: 30*uiScale
					fontSize: 18*uiScale
				}
				.anchor = Vec2.zero
				\slot "TapBegan",-> updatePlayerControl "keyShoot",true
				\slot "TapEnded",-> updatePlayerControl "keyShoot",false
	\addTo with Director.ui
		.renderGroup = true

Store.keyboardEnabled = false
keyboardControl = ->
	return unless Store.keyboardEnabled
	updatePlayerControl "keyLeft", Keyboard\isKeyPressed "A"
	updatePlayerControl "keyRight", Keyboard\isKeyPressed "D"
	updatePlayerControl "keyUp", Keyboard\isKeyPressed "K"
	updatePlayerControl "keyShoot", Keyboard\isKeyPressed "J"

Director.entry\addChild with Node!
	\schedule keyboardControl
