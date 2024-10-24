// @preview-file on
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Ease, Entity, Event, Group, Node, Observer, EntityEvent, Roll, Scale, Sequence, Sprite, TypeName, Vec2, tolua } from "Dora";

const sceneGroup = Group(["scene"]);
const positionGroup = Group(["position"]);

Observer(EntityEvent.Add, ["scene"]).watch((_entity, scene: Node.Type) => {
	scene.onTapEnded(touch => {
		const {location} = touch;
		positionGroup.each(entity => {
			entity.target = location;
			return false;
		});
	});
	return false;
});

Observer(EntityEvent.Add, ["image"]).watch((entity, image: string) => {
	sceneGroup.each(e => {
		const scene = tolua.cast(e.scene, TypeName.Node);
		if (scene) {
			const sprite = Sprite(image);
			if (sprite) {
				sprite.addTo(scene);
				sprite.runAction(Scale(0.5, 0, 0.5, Ease.OutBack));
				entity.sprite = sprite;
			}
			return true;
		}
		return false;
	});
	return false;
});

Observer(EntityEvent.Remove, ["sprite"]).watch(entity => {
	const sprite = tolua.cast(entity.oldValues.sprite, TypeName.Sprite);
	sprite?.removeFromParent();
	return false;
});

Observer(EntityEvent.Remove, ["target"]).watch(entity => {
	print("remove target from entity " + entity.index);
	return false;
});

Group(["position", "direction", "speed", "target"]).watch(
	(entity, position: Vec2.Type, _direction: number, speed: number, target: Vec2.Type) => {
	if (target.equals(position)) return false;
	const dir = target.sub(position).normalize();
	const angle = math.deg(math.atan(dir.x, dir.y));
	const newPos = position.add(dir.mul(speed));
	entity.position = newPos.clamp(position, target);
	entity.direction = angle;
	if (newPos.equals(target)) {
		entity.target = undefined;
	}
	return false;
});

Observer(EntityEvent.AddOrChange, ["position", "direction", "sprite"]).watch(
	(entity, position: Vec2.Type, direction: number, sprite: Sprite.Type) => {
	sprite.position = position
	const lastDirection = entity.oldValues.direction ?? sprite.angle;
	if (typeof lastDirection === "number") {
		if (math.abs(direction - lastDirection) > 1) {
			sprite.runAction(Roll(0.3, lastDirection, direction));
		}
	}
	return false;
});

Entity({scene: Node()});

interface EntityDef {
	image: string;
	position: Vec2.Type;
	direction: number;
	speed: number;
}

Entity<EntityDef>({
	image: "Image/logo.png",
	position: Vec2.zero,
	direction: 45.0,
	speed: 4.0,
});

Entity<EntityDef>({
	image: "Image/logo.png",
	position: Vec2(-100, 200),
	direction: 90.0,
	speed: 10.0
});

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
Observer(EntityEvent.Add, ["scene"]).watch(entity => {
	const scene = tolua.cast(entity.scene, TypeName.Node);
	if (scene !== null) {
		scene.schedule(() => {
			const {width} = App.visualSize;
			ImGui.SetNextWindowBgAlpha(0.35);
			ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
			ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
			ImGui.Begin("ECS System", windowFlags, () => {
				ImGui.Text("ECS System (Typescript)")
				ImGui.Separator()
				ImGui.TextWrapped("Tap any place to move entities.")
				if (ImGui.Button("Create Random Entity")) {
					Entity<EntityDef>({
						image: "Image/logo.png",
						position: Vec2(6 * math.random(1, 100), 6 * math.random(1, 100)),
						direction: 1.0 * math.random(0, 360),
						speed: 1.0 * math.random(1, 20)
					});
				}
				if (ImGui.Button("Destroy An Entity")) {
					Group(["sprite", "position"]).each(e => {
						e.position = undefined;
						const sprite = tolua.cast(e.sprite, TypeName.Sprite);
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
	return false;
});
