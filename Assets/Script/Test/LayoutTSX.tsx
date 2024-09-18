// @preview-file on
import { React, toNode } from 'DoraX';
import { App, Vec2, threadLoop, Node } from 'Dora';
import { SetCond, WindowFlag } from 'ImGui';
import * as ImGui from 'ImGui';

let current: Node.Type | null = null;

function Test(name: string, jsx: React.Element) {
	return {name, test: () => {
		current = toNode(
			<align-node windowRoot style={{padding: 10, flexDirection: 'row'}}>
				{jsx}
			</align-node>
		);
	}};
}

const tests = [

	Test("App",
		<align-node style={{width: 250, height: 475, padding: 10}} showDebug>
			<align-node style={{flex: 1, gap: [10, 0]}} showDebug>
				<align-node style={{height: 60}} showDebug/>
				<align-node style={{flex: 1, margin: 10}} showDebug/>
				<align-node style={{flex: 2, margin: 10}} showDebug/>
				<align-node showDebug
					style={{
						position: "absolute",
						width: "100%",
						bottom: 0,
						height: 64,
						flexDirection: "row",
						alignItems: "center",
						justifyContent: "space-around",
					}}
				>
					<align-node style={{height: 40, width: 40}} showDebug/>
					<align-node style={{height: 40, width: 40}} showDebug/>
					<align-node style={{height: 40, width: 40}} showDebug/>
					<align-node style={{height: 40, width: 40}} showDebug/>
				</align-node>
			</align-node>
		</align-node>
	),

	Test("Align Content",
		<align-node showDebug
			style={{
				width: 200,
				height: 250,
				padding: 10,
				alignContent: 'flex-start',
				flexWrap: 'wrap',
			}}>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
		</align-node>
	),

	Test("Align Items",
		<align-node showDebug
			style={{
				width: 200,
				height: 250,
				padding: 10,
				alignItems: 'flex-start',
			}}>
			<align-node showDebug
				style={{
					margin: 5,
					height: 50,
					width: 50,
					alignSelf: 'center',
				}}
			/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
		</align-node>
	),

	Test("Aspect Ratio",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
			}}>
			<align-node style={{margin: 5, height: 50, aspectRatio: 1.0}} showDebug/>
			<align-node style={{margin: 5, height: 50, aspectRatio: 1.5}} showDebug/>
		</align-node>
	),

	Test("Display",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
			}}>
			<align-node style={{margin: 5, height: 50, display: 'none'}} showDebug/>
			<align-node style={{margin: 5, height: 50, display: 'flex'}} showDebug/>
		</align-node>
	),

	Test("Flex Basis, Grow, and Shrink",
		<>
			<align-node showDebug
				style={{
					width: 200,
					height: 200,
					padding: 10,
				}}>
				<align-node style={{margin: 5, flexBasis: 50}} showDebug/>
			</align-node>

			<align-node showDebug
				style={{
					width: 200,
					height: 200,
					padding: 10,
				}}>
				<align-node style={{margin: 5, flexGrow: 0.25}} showDebug/>
				<align-node style={{margin: 5, flexGrow: 0.75}} showDebug/>
			</align-node>

			<align-node showDebug
				style={{
					width: 200,
					height: 200,
					padding: 10,
				}}>
				<align-node style={{margin: 5, flexShrink: 5, height: 150}} showDebug/>
				<align-node style={{margin: 5, flexShrink: 10, height: 150}} showDebug/>
			</align-node>
		</>
	),

	Test("Flex Direction",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
				flexDirection: 'column',
			}}>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
		</align-node>
	),

	Test("Flex Wrap",
		<align-node showDebug
			style={{
				width: 200,
				height: 150,
				padding: 10,
				flexWrap: 'wrap',
			}}>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
		</align-node>
	),

	Test("Gap",
		<align-node showDebug
			style={{
				width: 200,
				height: 250,
				padding: 10,
				flexWrap: 'wrap',
				gap: 10,
			}}>
			<align-node style={{height: 50, width: 50}} showDebug/>
			<align-node style={{height: 50, width: 50}} showDebug/>
			<align-node style={{height: 50, width: 50}} showDebug/>
			<align-node style={{height: 50, width: 50}} showDebug/>
			<align-node style={{height: 50, width: 50}} showDebug/>
		</align-node>
	),

	Test("Insets",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
			}}>
			<align-node showDebug
				style={{
					height: 50,
					width: 50,
					top: 50,
					left: 50,
				}}
			/>
		</align-node>
	),

	Test("Justify Content",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
				justifyContent: 'flex-end',
			}}>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
		</align-node>
	),

	Test("Layout Direction",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
				direction: 'rtl',
			}}>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
			<align-node style={{margin: 5, height: 50, width: 50}} showDebug/>
		</align-node>
	),

	Test("Margin, Padding, and Border",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
			}}>
			<align-node showDebug
				style={{
					margin: 5,
					padding: 20,
					border: 20,
					height: 50,
				}}
			/>
			<align-node style={{height: 50}} showDebug/>
		</align-node>
	),

	Test("Position",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
			}}>
			<align-node showDebug
				style={{
					margin: 5,
					height: 50,
					top: 20,
					position: 'relative',
				}}
			/>
		</align-node>
	),

	Test("Min/Max Width and Height",
		<align-node showDebug
			style={{
				width: 200,
				height: 250,
				margin: 20,
				padding: 10,
			}}>
			<align-node style={{margin: 5, height: 25}} showDebug/>
			<align-node showDebug
				style={{
					margin: 5,
					height: 100,
					maxHeight: 25,
				}}
			/>
			<align-node showDebug
				style={{
					margin: 5,
					height: 25,
					minHeight: 50,
				}}
			/>
			<align-node showDebug
				style={{
					margin: 5,
					height: 25,
					maxWidth: 25,
				}}
			/>
			<align-node showDebug
				style={{
					margin: 5,
					height: 25,
					width: 25,
					minWidth: 50,
				}}
			/>
		</align-node>
	),

	Test("Width and Height",
		<align-node showDebug
			style={{
				width: 200,
				height: 200,
				padding: 10,
			}}>
			<align-node showDebug
				style={{
					margin: 5,
					height: '50%',
					width: '65%',
				}}
			/>
		</align-node>
	)
];

tests[0].test();

const testNames = tests.map(t => t.name);

let currentTest = 1;
const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(200, 0), SetCond.Always);
	ImGui.Begin("Layout", windowFlags, () => {
		ImGui.Text("Layout (TSX)");
		ImGui.Separator();
		let changed = false;
		[changed, currentTest] = ImGui.Combo("Test", currentTest, testNames);
		if (changed) {
			if (current) {
				current.removeFromParent();
			}
			tests[currentTest - 1].test();
		}
	});
	return false;
});