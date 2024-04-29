// @preview-file off
import { React, toNode, useRef } from 'dora-x';
import { Body, BodyMoveType, Ease, Label, Line, Scale, TypeName, Vec2, tolua } from 'dora';

toNode(<sprite file='Image/logo.png' scaleX={0.2} scaleY={0.2}/>);

interface BoxProps {
	num: number;
	x?: number;
	y?: number;
	children?: any | any[];
}

const Box = (props: BoxProps) => {
	const numText = props.num.toString();
	return (
		<body type={BodyMoveType.Dynamic} scaleX={0} scaleY={0} x={props.x} y={props.y} tag={numText}>
			<rect-fixture width={100} height={100}/>
			<draw-node>
				<rect-shape width={100} height={100} fillColor={0x8800ffff} borderWidth={1} borderColor={0xff00ffff}/>
			</draw-node>
			<label fontName='sarasa-mono-sc-regular' fontSize={40}>{numText}</label>
			{props.children}
		</body>
	);
};

const bird = useRef<Body.Type>();
const score = useRef<Label.Type>();

let start = Vec2.zero;
let delta = Vec2.zero;

const line = Line();

toNode(
	<physics-world
		onTapBegan={(touch) => {
			start = touch.location;
			line.clear();
		}}
		onTapMoved={(touch) => {
			delta = delta.add(touch.delta);
			line.set([start, start.add(delta)]);
		}}
		onTapEnded={() => {
			if (!bird.current) return;
			bird.current.velocity = delta.mul(Vec2(10, 10));
			start = Vec2.zero;
			delta = Vec2.zero;
			line.clear();
		}}
	>
		<body type={BodyMoveType.Static}>
			<rect-fixture centerY={-200} width={2000} height={10}/>
			<draw-node>
				<rect-shape centerY={-200} width={2000} height={10} fillColor={0xfffbc400}/>
			</draw-node>
		</body>

		{
			[10, 20, 30, 40, 50].map((num, i) =>
				<Box num={num} x={200} y={-150 + i * 100}>
					<sequence>
						<delay time={i * 0.2}/>
						<scale time={0.3} start={0} stop={1}/>
					</sequence>
				</Box>
			)
		}

		<body ref={bird} type={BodyMoveType.Dynamic} x={-200} y={-150} onContactStart={(other) => {
			if (other.tag !== '' && score.current) {
				const sc = parseFloat(score.current.text) + parseFloat(other.tag);
				score.current.text = sc.toString();
				const label = tolua.cast(other.children?.last, TypeName.Label);
				if (label) label.text = '';
				other.tag = '';
				other.perform(Scale(0.2, 0.7, 1.0));
			}
		}}>
			<disk-fixture radius={50}/>
			<draw-node>
				<dot-shape radius={50} color={0xffff0088}/>
			</draw-node>
			<label ref={score} fontName='sarasa-mono-sc-regular' fontSize={40}>0</label>
			<scale time={0.4} start={0.3} stop={1.0} easing={Ease.OutBack}/>
		</body>
	</physics-world>
);
