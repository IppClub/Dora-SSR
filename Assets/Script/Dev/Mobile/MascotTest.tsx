import { App, Content, Director, Node, Size, Sprite, TextureFilter, Vec2, sleep, thread } from "Dora";
import { React, toNode } from "DoraX";
import { DoraMascot, type DoraMascotState } from "Dev/Mobile/Mascot";
import { MASCOT_CELL_SIZE, MASCOT_PIVOT_Y, mascotAnimationTime, mascotFrameAt, mascotFramePivotX, mascotLayout } from "Dev/Mobile/MascotModel";

const expect = (condition: boolean, message: string) => { if (!condition) throw new Error(message); };
function find(root: Node.Type, tag: string): Node.Type | undefined {
	if (root.tag === tag) return root;
	let found: Node.Type | undefined;
	root.eachChild(child => { found = find(child, tag); return found !== undefined; });
	return found;
}

thread(() => {
	let host: Node.Type | undefined;
	const previousSize = App.winSize;
	const hidden: Node.Type[] = [];
	try {
		for (const size of [42, 48, 52, 64]) {
			const layout = mascotLayout(size);
			expect(math.abs(layout.width-size)<0.0001, "Requested display size changed");
			expect(math.abs(layout.scale*MASCOT_CELL_SIZE-size)<0.0001, "Wrong display scale");
		}
		expect(mascotFrameAt(0, 0.2) === 0 && mascotFrameAt(0.41, 0.2) === 2 && mascotFrameAt(0.81, 0.2) === 0, "Frame timing mismatch");
		expect(mascotFrameAt(mascotAnimationTime(0.6, 0.1, true), 0.2) === 0, "Reduced motion must reset to first frame");
		expect(!App.reducedMotion, "Animation playback not_run: system reduced motion enabled");
		Director.systemUI.eachChild(node => { if (node.visible) { hidden.push(node); node.visible = false; } return false; });
		App.winSize = Size(780, 480);
		sleep(0.3);
		const states: DoraMascotState[] = ["idle", "waiting", "thinking", "working", "success", "failed"];
		host = toNode(<node tag="mascot-test" scaleX={App.devicePixelRatio} scaleY={App.devicePixelRatio}>
			<draw-node><rect-shape width={780} height={480} fillColor={0xff242b38} /></draw-node>
			{states.map((state,i) => <node x={-300+(i%3)*300} y={120-math.floor(i/3)*240}>
				<DoraMascot state={state} x={0} y={0} size={96} />
				<label y={-80} fontName="sarasa-mono-sc-regular" fontSize={16} text={state} />
			</node>)}
		</node>);
		if (!host) throw new Error("Missing test host");
		host.addTo(Director.systemUI);
		const sprites = states.map(state => find(find(host!, `mascot-${state}`)!, "mascot-sprite") as Sprite.Type);
		for (const filter of [TextureFilter.None, TextureFilter.Point, TextureFilter.Anisotropic]) {
			sprites[0].filter = filter;
			expect(sprites[0].filter === filter, "Sprite filter read-back mismatch");
		}
		sprites[0].filter = TextureFilter.Point;
		const pivots = sprites.map((sprite,i) => sprite.convertToWorldSpace(Vec2(mascotFramePivotX(i,0), MASCOT_CELL_SIZE-MASCOT_PIVOT_Y)));
		const observed: Record<string, boolean> = {};
		for (let tick=0; tick<20; tick++) {
			sleep(0.1);
			sprites.forEach((sprite,i) => {
				expect(sprite.filter === TextureFilter.Point, "Sprite filter changed");
				expect(sprite.width === MASCOT_CELL_SIZE && sprite.height === MASCOT_CELL_SIZE, "Wrong quad size");
				expect(sprite.textureRect.y === i*MASCOT_CELL_SIZE, "Wrong state row");
				expect(sprite.textureRect.width === MASCOT_CELL_SIZE && sprite.textureRect.height === MASCOT_CELL_SIZE, "Wrong frame crop");
				const frame=math.floor(sprite.textureRect.x/MASCOT_CELL_SIZE);
				const pivotX=mascotFramePivotX(i,frame);
				expect(math.abs(sprite.anchor.x-pivotX/MASCOT_CELL_SIZE)<0.0001, "Wrong frame anchor");
				const p=sprite.convertToWorldSpace(Vec2(pivotX, MASCOT_CELL_SIZE-MASCOT_PIVOT_Y));
				expect(math.abs(p.x-pivots[i].x)<0.001 && math.abs(p.y-pivots[i].y)<0.001, "Animated foot pivot moved");
				observed[`${i}:${math.floor(sprite.textureRect.x/MASCOT_CELL_SIZE)}`] = true;
			});
			if (tick%2===0) App.saveScreenshot(`/tmp/dora-mascot-anchor-runtime-${tick}`);
		}
		for(let row=0;row<6;row++) for(let frame=0;frame<4;frame++) expect(observed[`${row}:${frame}`]===true,`Frame not observed: ${row}:${frame}`);
		Content.save("/tmp/dora-mascot-anchor-runtime.result","passed sizes=4 frames=24 pivotDrift<0.001 pointFilter=1 filterReadBack=3 quadCrop=1 reducedMotionModel=1\n");
	} catch(error) { Content.save("/tmp/dora-mascot-anchor-runtime.result", `failed: ${error}`); }
	host?.removeFromParent(true);
	App.winSize = previousSize;
	sleep(0.3);
	hidden.forEach(node => { node.visible = true; });
});
