import { App, Camera3D, Color, Color3, Content, Director, DirectionalLight3D, Model3D, Node, PointLight3D, Texture2D, Vec3, View } from 'Dora';
import { resultRoot, caseNames, benchmark } from 'BaseColorPbrConfig';

const savedIDE = App.webIDEEnabled;
const savedFPS = App.fpsLimited;
const savedVSync = View.vsync;
const savedProfiler = Director.profilerSending;
App.webIDEEnabled = false;
if (benchmark) { App.fpsLimited = false; View.vsync = false; }
if (!Director.beginGameCapture()) error('Game capture is busy');
Director.clearColor = Color(0xff39414b);
const view = Director.entry;
const camera = Camera3D();
camera.lookAt(Vec3(0, 5, 7), Vec3(0, 0, 0));
Director.pushCamera(camera);
const sun = DirectionalLight3D();
sun.angleX = -50;
sun.angleY = 25;
sun.intensity = 3;
view.addChild(sun);
const point = PointLight3D();
point.position = Vec3(1, 3, 1);
point.color = Color3(0xff8080);
point.intensity = 12;
point.range = 10;
view.addChild(point);
const cases = caseNames;
const normal = Texture2D('normal.png');
let step = 0;
let activeStep = -1;
let elapsed = 0;
let pending = false;
let basic: Model3D.Type | undefined;
let full: Model3D.Type | undefined;
let caster: Model3D.Type | undefined;
let finished = false;
const rows: string[] = [];
function finish(message: string): void {
    Director.profilerSending = savedProfiler;
    Director.endGameCapture();
    App.fpsLimited = savedFPS;
    View.vsync = savedVSync;
    App.webIDEEnabled = savedIDE;
    Content.save(resultRoot + '/result.txt', message);
    finished = true;
}
const driver = Node();
driver.addTo(Director.ui);
if (benchmark) {
    Director.profilerSending = true;
    driver.gslot('AppWS', (event) => {
        if (event.type === 'Send' && elapsed >= 1.5 && elapsed <= 4.5
            && event.msg.indexOf('"name":"Profiler"') >= 0) {
            const name = cases[Math.floor(step / 2) % cases.length];
            const mode = step % 2 === 0 ? 'basic' : 'full';
            rows.push('{"case":"' + name + '","mode":"' + mode + '","round":'
                + Math.floor(step / (cases.length * 2)) + ',"sample":' + event.msg + '}');
            Content.save(resultRoot + '/profiler.jsonl', rows.join('\n'));
        }
    });
}
driver.schedule((dt) => {
    if (finished) return true;
    if (pending) return false;
    if (step >= cases.length * 2 * (benchmark ? 3 : 1)) {
        finish('passed');
        return true;
    }
    const name = cases[Math.floor(step / 2) % cases.length];
    if (step !== activeStep) {
        if (step % 2 === 0) {
            if (basic !== undefined) basic.removeFromParent();
            if (full !== undefined) full.removeFromParent();
            if (caster !== undefined) { caster.removeFromParent(); caster = undefined; }
            basic = Model3D(name + '.gltf');
            full = Model3D(name + '-full.gltf');
            if (basic === undefined || full === undefined) { finish('failed: load ' + name); return true; }
            basic.scale = Vec3(benchmark ? 20 : 7, 1, benchmark ? 20 : 7);
            full.scale = basic.scale;
            view.addChild(basic);
            view.addChild(full);
            if (name === 'runtime-normal' && normal !== undefined) {
                // Use identical external texture handles and sampler state in both paths.
                basic.getMaterial(0)?.setNormalTexture(normal);
                full.getMaterial(0)?.setNormalTexture(normal);
            }
            point.visible = name === 'point-light';
            sun.castShadow = name === 'shadow';
            if (name === 'shadow') {
                caster = Model3D('opaque.gltf');
                caster.scale = Vec3(2, 1, 2);
                caster.position = Vec3(0, 1, 0);
                caster.angleX = 25;
                view.addChild(caster);
            }
        }
        basic!.visible = step % 2 === 0;
        full!.visible = step % 2 === 1;
        activeStep = step;
        elapsed = 0;
        print('[PBR] ' + name + ' ' + (step % 2 === 0 ? 'automatic' : 'full'));
    }
    elapsed += dt;
    if (elapsed < (benchmark ? 5 : 0.8)) return false;
    const mode = step % 2 === 0 ? 'basic' : 'full';
    pending = true;
    const accepted = Director.captureGameAsync(resultRoot + '/' + name + '-' + mode + '.png', (success) => {
        pending = false;
        if (!success) { finish('failed: capture ' + name); return; }
        step++;
    });
    if (!accepted) { pending = false; finish('failed: capture rejected'); }
    return false;
});
