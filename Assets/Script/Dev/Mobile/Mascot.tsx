import { React, reference } from "DoraX";
import { App, Rect, Sprite, TextureFilter, Vec2 } from "Dora";
import { MASCOT_CELL_SIZE, MASCOT_PIVOT_Y, mascotAnimationTime, mascotFrameAt, mascotFramePivotX, mascotLayout } from "Dev/Mobile/MascotModel";

export type DoraMascotState = "idle" | "waiting" | "thinking" | "working" | "success" | "failed";

const stateColor = (state: DoraMascotState) => state === "success" ? 0xff6dd58c
	: state === "failed" ? 0xffff6b6b
	: state === "working" ? 0xffffcc33
	: state === "thinking" ? 0xff72b7ff
	: state === "waiting" ? 0xffa8afbd
	: 0xfff4f1e8;

const stateMark = (state: DoraMascotState) => state === "success" ? "✓"
	: state === "failed" ? "!"
	: state === "working" ? "›"
	: state === "thinking" ? "…"
	: state === "waiting" ? "·"
	: "";

const stateRow = (state: DoraMascotState) => state === "waiting" ? 1
	: state === "thinking" ? 2
	: state === "working" ? 3
	: state === "success" ? 4
	: state === "failed" ? 5
	: 0;

const frameRect = (state: DoraMascotState, frame: number) => Rect(frame * MASCOT_CELL_SIZE, stateRow(state) * MASCOT_CELL_SIZE, MASCOT_CELL_SIZE, MASCOT_CELL_SIZE);

export function DoraMascot(props: { state: DoraMascotState; x: number; y: number; size?: number }) {
	const size = props.size ?? 48;
	const layout = mascotLayout(size);
	const snap = (value: number) => math.floor(value * App.devicePixelRatio + 0.5) / App.devicePixelRatio;
	const spriteRef = reference<Sprite.Type>();
	let frame = 0;
	let elapsed = 0;
	return <node tag={`mascot-${props.state}`} x={snap(props.x)} y={snap(props.y)} onMount={node => node.schedule(dt => {
		elapsed = mascotAnimationTime(elapsed, dt, App.reducedMotion);
		const nextFrame = mascotFrameAt(elapsed, props.state === "idle" ? 0.34 : 0.2);
		if (nextFrame === frame) return false;
		frame = nextFrame;
		const sprite = spriteRef.current;
		if (sprite) {
			sprite.textureRect = frameRect(props.state, frame);
			sprite.anchor = Vec2(mascotFramePivotX(stateRow(props.state), frame) / MASCOT_CELL_SIZE, 1 - MASCOT_PIVOT_Y / MASCOT_CELL_SIZE);
		}
		return false;
	})}>
		<sprite tag="mascot-sprite" ref={spriteRef} file="Image/Mobile/dora-remix-states.png" textureRect={frameRect(props.state, 0)}
			anchorX={mascotFramePivotX(stateRow(props.state), 0) / MASCOT_CELL_SIZE} anchorY={1 - MASCOT_PIVOT_Y / MASCOT_CELL_SIZE} y={layout.feetY}
			scaleX={layout.scale} scaleY={layout.scale} filter={TextureFilter.Point}
			onMount={sprite => { sprite.width = MASCOT_CELL_SIZE; sprite.height = MASCOT_CELL_SIZE; }} />
		{props.state !== "idle" ? <draw-node>
			<dot-shape x={size * 0.36} y={-size * 0.38} radius={size * 0.17} color={stateColor(props.state)} />
		</draw-node> : undefined}
		{props.state !== "idle" ? <label x={size * 0.36} y={-size * 0.38} fontName="sarasa-mono-sc-regular" fontSize={math.floor(size * 0.22)}
			text={stateMark(props.state)} color3={0x17130a} /> : undefined}
	</node>;
}
