import {
	App,
	Billboard,
	Camera3D,
	Content,
	Director,
	Label,
	Size,
	Surface3D,
	Vec3,
	threadLoop,
} from "Dora";

const view = Director.entry;
const camera = Camera3D();
camera.lookAt(Vec3(0, 1.5, 5), Vec3(0, 1.5, 0));
Director.pushCamera(camera);

const label = Label("sarasa-mono-sc-regular", 24);
if (!label) throw new Error("failed to create label");
label.text = "Hello from 2D";

const surface = Surface3D(label, Size(3, 1), Size(512, 128));
if (!surface) throw new Error("failed to create Surface3D");
surface.position = Vec3(0, 1.5, 0);
surface.billboard = Billboard.YAxis;
view.addChild(surface);

let frames = 0;
threadLoop(() => {
	frames += 1;
	if (frames >= 60) {
		Content.save("/tmp/surface3d-tutorial.result", surface.content === label ? "passed" : "failed");
		return true;
	}
	return false;
});
