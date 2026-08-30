import { App, Content, Director, Label, Path, sleep, thread } from "Dora";
import { React, reference, toNode } from "DoraX";

const resultPath = Path(Content.writablePath, "dora-mobile-typography.result");
Content.save(resultPath, "running\n");
const fontName = "sarasa-mono-sc-regular";
const defaultRef = reference<Label.Type>();
const sdfRef = reference<Label.Type>();
const bitmapRef = reference<Label.Type>();
const optionalRef = reference<Label.Type>();
const optional: boolean | undefined = undefined;
const host = toNode(<node>
	<label ref={defaultRef} fontName={fontName} fontSize={16} text="默认文字 Remix" />
	<label ref={sdfRef} fontName={fontName} fontSize={16} sdf={true} text="显式 SDF" y={-40} />
	<label ref={bitmapRef} fontName={fontName} fontSize={16} sdf={false} text="显式位图" y={-80} />
	<label ref={optionalRef} fontName={fontName} fontSize={16} sdf={optional} text="可空参数" y={-120} />
</node>);

function expect(condition: boolean, message: string) {
	if (condition) return;
	Content.save(resultPath, `failed ${message}\n`);
	throw new Error(message);
}

expect(host !== undefined, "JSX scene creation failed");
host?.addTo(Director.systemUI);
thread(() => {
	const label = defaultRef.current;
	const explicit = sdfRef.current;
	const bitmap = bitmapRef.current;
	const nullable = optionalRef.current;
	expect(label !== undefined && explicit !== undefined && bitmap !== undefined && nullable !== undefined, "Label refs missing");
	if (!label || !explicit || !bitmap || !nullable || !host) return;
	const native = Label(fontName, 16);
	expect(native !== undefined, "native Label missing");
	expect(label.smooth.x > 0 && label.effect === native?.effect, "JSX default differs from native SDF default");
	expect(explicit.effect === label.effect && nullable.effect === label.effect, "explicit/undefined SDF differs from default");
	expect(bitmap.smooth.x === 0 && bitmap.smooth.y === 0 && bitmap.effect !== label.effect, "explicit false must preserve bitmap rendering");
	const width = label.width;
	const height = label.height;
	for (const scale of [1, 1.5, 2, 3]) {
		host.scaleX = scale;
		host.scaleY = scale;
		sleep(0.05);
		expect(label.width === width && label.height === height, "DPR changed logical text metrics");
	}
	label.text = "输入法你好 Remix";
	expect(defaultRef.current === label && label.text === "输入法你好 Remix", "live input Label reference broken");
	expect(label.effect === explicit.effect, "live text update disabled SDF");
	const customized = toNode(<label fontName={fontName} fontSize={16} smoothLower={0.65} smoothUpper={0.73} text="custom" />) as Label.Type;
	expect(customized !== undefined && math.abs(customized.smooth.x - 0.65) < 0.001 && math.abs(customized.smooth.y - 0.73) < 0.001, "custom smoothing regression");
	host.removeFromParent(true);
	Content.save(resultPath, `passed default=true explicit=true/false undefined=true customSmooth=true scales=1,1.5,2,3 dpr=${App.devicePixelRatio}\n`);
});
