import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Component, Ease, Entity, Event, Group, Node, Observer, ObserverEvent, Roll, Scale, Sequence, Slot, Sprite, TypeName, Vec2, tolua } from "dora";

const sceneGroup = Group(["scene"]);
const positionGroup = Group(["position"]);

function toNode(item: any) {
	return tolua.cast(item, TypeName.Node);
}

Observer(ObserverEvent.Add, ["scene"]).watch((_, scene: Node.Type) => {
	scene.touchEnabled = true;
	scene.slot(Slot.TapEnded, touch => {
		const {location} = touch;
		positionGroup.each(entity => {
			entity.target = location;
			return false;
		});
	});
});

Observer(ObserverEvent.Add, ["image"]).watch((entity, image: string) => {
	sceneGroup.each(e => {
		const scene = toNode(e.scene);
		if (scene !== null) {
			const sprite = Sprite(image);
			sprite.addTo(scene);
			sprite.runAction(Scale(0.5, 0, 0.5, Ease.OutBack));
			entity.sprite = sprite;
			return true;
		}
		return false;
	})
});

Observer(ObserverEvent.Remove, ["sprite"]).watch(entity => {
	const sprite = toNode(entity.oldValues.sprite);
	sprite?.removeFromParent();
});

Observer(ObserverEvent.Remove, ["target"]).watch(entity => {
	print("remove target from entity " + entity.index);
});

Group(["position", "direction", "speed", "target"]).watch(
	(entity, position: Vec2.Type, _direction: number, speed: number, target: Vec2.Type) => {
	if (target.equals(position)) return;
	const dir = target.sub(position).normalize();
	const angle = math.deg(math.atan(dir.x, dir.y));
	let newPos = position.add(dir.mul(speed));
	newPos = newPos.clamp(position, target);
	entity.position = newPos;
	entity.direction = angle;
	if (newPos.equals(target)) {
		entity.target = undefined;
	}
});

Observer(ObserverEvent.AddOrChange, ["position", "direction", "sprite"]).watch(
	(entity, position: Vec2.Type, direction: number, sprite: Sprite.Type) => {
	sprite.position = position
	const lastDirection = entity.oldValues.direction ?? sprite.angle;
	if (typeof lastDirection === "number") {
		if (math.abs(direction - lastDirection) > 1) {
			sprite.runAction(Roll(0.3, lastDirection, direction));
		}
	}
});

interface EntityDef extends Record<string, Component> {
	image: string;
	position: Vec2.Type;
	direction: number;
	speed: number;
}

Entity({scene: Node()});

let def: EntityDef = {
	image: "Image/logo.png",
	position: Vec2.zero,
	direction: 45.0,
	speed: 4.0
};
Entity(def);

def = {
	image: "Image/logo.png",
	position: Vec2(-100, 200),
	direction: 90.0,
	speed: 10.0
};
Entity(def);

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
Observer(ObserverEvent.Add, ["scene"]).watch(entity => {
	const scene = toNode(entity.scene);
	if (scene !== null) {
		scene.schedule(() => {
			const {width} = App.visualSize;
			ImGui.SetNextWindowBgAlpha(0.35);
			ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
			ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
			ImGui.Begin("ECS System", windowFlags, () => {
				ImGui.Text("ECS System")
				ImGui.Separator()
				ImGui.TextWrapped("Tap any place to move entities.")
				if (ImGui.Button("Create Random Entity")) {
					const def: EntityDef = {
						image: "Image/logo.png",
						position: Vec2(6 * math.random(1, 100), 6 * math.random(1, 100)),
						direction: 1.0 * math.random(0, 360),
						speed: 1.0 * math.random(1, 20)
					};
					Entity(def);
				}
				if (ImGui.Button("Destroy An Entity")) {
					Group(["sprite", "position"]).each(e => {
						e.position = undefined;
						const sprite = toNode(e.sprite);
						if (sprite !== null) {
							sprite.runAction(
								Sequence(
									Scale(0.5, 0.5, 0, Ease.InBack),
									Event("Destroy")
								)
							);
							sprite.slot("Destroy", () => {
								e.destroy();
							});
						}
						return true;
					});
				}
			});
			return false;
		});
	}
});