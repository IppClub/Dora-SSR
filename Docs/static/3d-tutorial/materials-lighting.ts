import {Camera3D, Color, Color3, DirectionalLight3D, Director, Model3D, Vec3} from "Dora";

const view = Director.entry;
view.setEnvironmentMap("");
view.setEnvironmentIntensity(0.22, 0.18, 1.0);

const camera = Camera3D();
camera.lookAt(Vec3(4.8, 3.7, 6.5), Vec3(0, 0.25, 0));
Director.pushCamera(camera);

const ground = Model3D("Assets/Model/Ground.gltf");
ground.position = Vec3(0, -0.72, 0);
view.addChild(ground);

const duck = Model3D("Assets/Model/Duck.glb");
duck.position = Vec3(0, -0.7, 0);
duck.scale = Vec3(0.8, 0.8, 0.8);
view.addChild(duck);

const light = DirectionalLight3D();
light.color = Color3(0xfff0d8);
light.intensity = 4.5;
light.angleX = -48;
light.angleY = -35;
light.castShadow = true;
light.shadowBias = 0.004;
light.shadowNormalBias = 0.02;
light.shadowSoftness = 1;
view.shadowMapSize = 1024;
view.addChild(light);

const material = duck.getMaterial(0);
if (material) {
	material.baseColor = Color(0xff9bd7ff);
	material.metallic = 0.15;
	material.roughness = 0.42;
}
