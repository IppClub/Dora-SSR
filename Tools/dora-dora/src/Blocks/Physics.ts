/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';

const zh = Info.locale.match(/^zh/) !== null;

const physicsCategory = {
	kind: 'category',
	name: zh ? '物理' : 'Physics',
	categorystyle: 'colour_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default physicsCategory;

const newVec2 = (x: number, y: number, shadow: boolean) => {
	return {
		[shadow ? 'shadow' : 'block']: {
			type: 'vec2_create',
			inputs: {
				X: {
					shadow: {
						type: 'math_number',
						fields: {
							NUM: x,
						},
					},
				},
				Y: {
					shadow: {
						type: 'math_number',
						fields: {
							NUM: y,
						},
					},
				},
			},
		},
	};
};

const shadowVec2Zero = newVec2(0, 0, true);

// physics_world_create
const physicsWorldCreateBlock = {
	type: 'physics_world_create',
	message0: zh ? '创建物理世界节点' : 'Create physics world node',
	output: 'PhysicsWorld',
	style: 'colour_blocks',
};
Blockly.Blocks['physics_world_create'] = {
	init: function() {
		this.jsonInit(physicsWorldCreateBlock);
	},
};
luaGenerator.forBlock['physics_world_create'] = function(_block: Blockly.Block) {
	Require.add('PhysicsWorld');
	return [`PhysicsWorld()`, Order.ATOMIC];
};
physicsCategory.contents.push({
	kind: 'block',
	type: 'physics_world_create',
});

// set_group_collision_enabled
const setGroupCollisionEnabledBlock = {
	type: 'set_group_collision_enabled',
	message0: zh ? '设置物理世界节点 %1 的分组 %2 和分组 %3 %4' : 'Set world node %1 group %2 and group %3 %4',
	args0: [
		{
			type: 'field_variable',
			name: 'WORLD',
			variable: 'world',
		},
		{
			type: 'input_value',
			name: 'GROUP1',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'GROUP2',
			check: 'Number',
		},
		{
			type: 'field_dropdown',
			name: 'ENABLED',
			options: zh ? [
				['会碰撞', 'true'],
				['不会碰撞', 'false'],
			] : [
				['contact Enabled', 'true'],
				['contact Disabled', 'false'],
			],
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'colour_blocks',
};
Blockly.Blocks['set_group_collision_enabled'] = {
	init: function() {
		this.jsonInit(setGroupCollisionEnabledBlock);
	},
};
luaGenerator.forBlock['set_group_collision_enabled'] = function(block: Blockly.Block) {
	const world = luaGenerator.getVariableName(block.getFieldValue('WORLD'));
	const group1 = luaGenerator.valueToCode(block, 'GROUP1', Order.NONE);
	const group2 = luaGenerator.valueToCode(block, 'GROUP2', Order.NONE);
	const enabled = block.getFieldValue('ENABLED');
	return `${world}:setShouldContact(${group1}, ${group2}, ${enabled})\n`;
};
physicsCategory.contents.push({
	kind: 'block',
	type: 'set_group_collision_enabled',
	inputs: {
		GROUP1: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		GROUP2: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
	},
});

// body_create
const bodyCreateBlock = {
	type: 'body_create',
	message0: zh ? '为物理世界节点 %1 创建 %2 %3 的刚体节点\n在位置 %4 角度 %5 \n重力系数为 %6 分组为 %7\n组成形状包括 %8' : 'For world node %1\ncreate %2 %3 body node\nat position %4 angle %5\ngravity %6 group %7\nwith shapes %8',
	args0: [
		{
			type: 'field_variable',
			name: 'WORLD',
			variable: 'world',
		},
		{
			type: 'field_dropdown',
			name: 'TYPE',
			options: zh ? [
				['静态', 'Static'],
				['动态', 'Dynamic'],
				['可移动', 'Kinematic'],
			] : [
				['Static', 'Static'],
				['Dynamic', 'Dynamic'],
				['Kinematic', 'Kinematic'],
			],
		},
		{
			type: 'field_dropdown',
			name: 'FIXED',
			options: zh ? [
				['可旋转', 'false'],
				['固定旋转', 'true'],
			] : [
				['Rotatable', 'false'],
				['Fixed', 'true'],
			],
		},
		{
			type: 'input_value',
			name: 'POSITION',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'ANGLE',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'GRAVITY',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'GROUP',
			check: 'Number',
		},
		{
			type: 'input_statement',
			name: 'FIXTURES',
		},
	],
	output: 'Body',
	style: 'colour_blocks',
};
Blockly.Blocks['body_create'] = {
	init: function() {
		this.jsonInit(bodyCreateBlock);
	},
	onchange: function (this: Blockly.Block & {ALLOWED_FIXTURES: string[]}, e: Blockly.Events.Abstract) {
		if (
			((this.workspace as Blockly.WorkspaceSvg).isDragging &&
			(this.workspace as Blockly.WorkspaceSvg).isDragging()) ||
			(e.type !== Blockly.Events.BLOCK_MOVE && e.type !== Blockly.Events.BLOCK_CREATE)
		) {
			return;
		}
		let legal = true;
		this.setWarningText(null);
		const fixtures = this.getInput('FIXTURES');
		let fixtureBlock = fixtures?.connection?.targetConnection?.getSourceBlock();
		if (fixtureBlock) {
			if (!this.ALLOWED_FIXTURES.includes(fixtureBlock.type)) {
				legal = false;
				this.setWarningText(zh ? '使用无效的形状' : 'Invalid shape');
			} else {
				while (fixtureBlock) {
					const nextFixtureBlock: Blockly.Block | null = fixtureBlock.getNextBlock();
					if (nextFixtureBlock) {
						if (!this.ALLOWED_FIXTURES.includes(nextFixtureBlock.type)) {
							legal = false;
							this.setWarningText(zh ? '使用无效的形状' : 'Invalid shape');
						}
						fixtureBlock = nextFixtureBlock;
					} else {
						break;
					}
				}
			}
		}
		if (!this.isInFlyout) {
			try {
				Blockly.Events.setRecordUndo(false);
				this.setDisabledReason(!legal, 'INVALID_SHAPE');
			} finally {
				Blockly.Events.setRecordUndo(true);
			}
		}
	},
	ALLOWED_FIXTURES: [
		'disk_fixture',
		'rectangle_fixture',
		'polygon_fixture',
		'chain_fixture',
	]
};
const bodyDefStack: string[] = [];
luaGenerator.forBlock['body_create'] = function(block: Blockly.Block) {
	const bodyDefVar = luaGenerator.nameDB_?.getDistinctName('bodyDef', Blockly.Names.NameType.VARIABLE) ?? 'bodyDef';
	bodyDefStack.push(bodyDefVar);
	const world = luaGenerator.getVariableName(block.getFieldValue('WORLD'));
	const type = luaGenerator.quote_(block.getFieldValue('TYPE'));
	const fixed = block.getFieldValue('FIXED');
	const position = luaGenerator.valueToCode(block, 'POSITION', Order.NONE);
	const angle = luaGenerator.valueToCode(block, 'ANGLE', Order.NONE);
	const group = luaGenerator.valueToCode(block, 'GROUP', Order.NONE);
	const gravity = luaGenerator.valueToCode(block, 'GRAVITY', Order.NONE);
	const fixtures = luaGenerator.statementToCode(block, 'FIXTURES');
	bodyDefStack.pop();
	Require.add('BodyDef');
	Require.add('Body');
	return [`(function()
  local ${bodyDefVar} = BodyDef()
  ${bodyDefVar}.type = ${type}
  ${bodyDefVar}.fixedRotation = ${fixed}
  ${bodyDefVar}.group = ${group}
  ${bodyDefVar}.linearAcceleration = ${gravity}
${fixtures}  return Body(${bodyDefVar}, ${world}, ${position}, ${angle})
end)()`, Order.ATOMIC];
};
physicsCategory.contents.push({
	kind: 'block',
	type: 'body_create',
	inputs: {
		POSITION: shadowVec2Zero,
		ANGLE: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		GROUP: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		GRAVITY: {
			shadow: {
				type: 'vec2_create',
				inputs: {
					X: {
						shadow: {
							type: 'math_number',
							fields: {
								NUM: 0,
							},
						},
					},
					Y: {
						shadow: {
							type: 'math_number',
							fields: {
								NUM: -9.8,
							},
						},
					},
				},
			},
		},
	}
});

// rectangle_fixture
const rectangleFixtureBlock = {
	type: 'rectangle_fixture',
	message0: zh ? '矩形\n中心 %1\n宽度 %2 高度 %3 角度 %4\n密度 %5 摩擦力 %6 弹性 %7\n用作感应器的编号为 %8' : 'Rectangle\ncenter %1\nwidth %2 height %3 angle %4\ndensity %5 friction %6 restitution %7\nas sensor with tag %8',
	args0: [
		{
			type: 'input_value',
			name: 'CENTER',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'WIDTH',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'HEIGHT',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'ANGLE',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'DENSITY',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'FRICTION',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'RESTITUTION',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'SENSOR_TAG',
			check: 'Number'
		}
	],
	previousStatement: null,
	nextStatement: null,
	style: 'math_blocks',
};
Blockly.Blocks['rectangle_fixture'] = {
	init: function() {
		this.jsonInit(rectangleFixtureBlock);
	},
	onchange: function (this: Blockly.Block & {ALLOWED_FIXTURES: string[]}, e: Blockly.Events.Abstract) {
		if (
			((this.workspace as Blockly.WorkspaceSvg).isDragging &&
			(this.workspace as Blockly.WorkspaceSvg).isDragging()) ||
			(e.type !== Blockly.Events.BLOCK_MOVE && e.type !== Blockly.Events.BLOCK_CREATE)
		) {
			return;
		}
		let legal = false;
		// eslint-disable-next-line @typescript-eslint/no-this-alias
		let block = this;
		do {
			if (block.type === 'body_create') {
				legal = true;
				break;
			}
			block = block.getSurroundParent()!;
		} while (block);
		if (legal) {
			this.setWarningText(null);
		} else {
			this.setWarningText(zh ? '矩形形状必须嵌套在刚体创建块中' : 'Rectangle shape must be nested in a body create block');
		}
		if (!this.isInFlyout) {
			try {
				Blockly.Events.setRecordUndo(false);
				this.setDisabledReason(!legal, 'UNPARENTED_RECTANGLE');
			} finally {
				Blockly.Events.setRecordUndo(true);
			}
		}
	}
};
luaGenerator.forBlock['rectangle_fixture'] = function(block: Blockly.Block) {
	const center = luaGenerator.valueToCode(block, 'CENTER', Order.NONE);
	const width = luaGenerator.valueToCode(block, 'WIDTH', Order.NONE);
	const height = luaGenerator.valueToCode(block, 'HEIGHT', Order.NONE);
	const angle = luaGenerator.valueToCode(block, 'ANGLE', Order.NONE);
	const density = luaGenerator.valueToCode(block, 'DENSITY', Order.NONE);
	const friction = luaGenerator.valueToCode(block, 'FRICTION', Order.NONE);
	const restitution = luaGenerator.valueToCode(block, 'RESTITUTION', Order.NONE);
	const sensorTag = luaGenerator.valueToCode(block, 'SENSOR_TAG', Order.NONE);
	const bodyDefVar = bodyDefStack[bodyDefStack.length - 1];
	if (sensorTag === '' || sensorTag === 'nil') {
		return `${bodyDefVar}:attachPolygon(${center}, ${width}, ${height}, ${angle}, ${density}, ${friction}, ${restitution})\n`;
	} else {
		return `${bodyDefVar}:attachPolygonSensor(${sensorTag}, ${center}, ${width}, ${height}, ${angle})\n`;
	}
};
physicsCategory.contents.push({
	kind: 'block',
	type: 'rectangle_fixture',
	inputs: {
		CENTER: shadowVec2Zero,
		WIDTH: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 100,
				},
			},
		},
		HEIGHT: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 100,
				},
			},
		},
		ANGLE: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		DENSITY: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 1,
				},
			},
		},
		FRICTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0.4,
				},
			},
		},
		RESTITUTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		SENSOR_TAG: {
			shadow: {
				type: 'logic_null',
			},
		}
	}
});

// disk_fixture
const diskFixtureBlock = {
	type: 'disk_fixture',
	message0: zh ? '圆形\n中心 %1\n半径 %2\n密度 %3 摩擦力 %4 弹性 %5\n用作感应器的编号为 %6' : 'Circle\ncenter %1\nradius %2\ndensity %3 friction %4 restitution %5\nas sensor with tag %6',
	args0: [
		{
			type: 'input_value',
			name: 'CENTER',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'RADIUS',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'DENSITY',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'FRICTION',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'RESTITUTION',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'SENSOR_TAG',
			check: 'Number'
		}
	],
	previousStatement: null,
	nextStatement: null,
	style: 'math_blocks',
};
Blockly.Blocks['disk_fixture'] = {
	init: function() {
		this.jsonInit(diskFixtureBlock);
	},
	onchange: function (this: Blockly.Block & {ALLOWED_FIXTURES: string[]}, e: Blockly.Events.Abstract) {
		if (
			((this.workspace as Blockly.WorkspaceSvg).isDragging &&
			(this.workspace as Blockly.WorkspaceSvg).isDragging()) ||
			(e.type !== Blockly.Events.BLOCK_MOVE && e.type !== Blockly.Events.BLOCK_CREATE)
		) {
			return;
		}
		let legal = false;
		// eslint-disable-next-line @typescript-eslint/no-this-alias
		let block = this;
		do {
			if (block.type === 'body_create') {
				legal = true;
				break;
			}
			block = block.getSurroundParent()!;
		} while (block);
		if (legal) {
			this.setWarningText(null);
		} else {
			this.setWarningText(zh ? '圆形形状必须嵌套在刚体创建块中' : 'Circle shape must be nested in a body create block');
		}
		if (!this.isInFlyout) {
			try {
				Blockly.Events.setRecordUndo(false);
				this.setDisabledReason(!legal, 'UNPARENTED_CIRCLE');
			} finally {
				Blockly.Events.setRecordUndo(true);
			}
		}
	}
};
luaGenerator.forBlock['disk_fixture'] = function(block: Blockly.Block) {
	const center = luaGenerator.valueToCode(block, 'CENTER', Order.NONE);
	const radius = luaGenerator.valueToCode(block, 'RADIUS', Order.NONE);
	const density = luaGenerator.valueToCode(block, 'DENSITY', Order.NONE);
	const friction = luaGenerator.valueToCode(block, 'FRICTION', Order.NONE);
	const restitution = luaGenerator.valueToCode(block, 'RESTITUTION', Order.NONE);
	const sensorTag = luaGenerator.valueToCode(block, 'SENSOR_TAG', Order.NONE);
	const bodyDefVar = bodyDefStack[bodyDefStack.length - 1];
	if (sensorTag === '' || sensorTag === 'nil') {
		return `${bodyDefVar}:attachDisk(${center}, ${radius}, ${density}, ${friction}, ${restitution})\n`;
	} else {
		return `${bodyDefVar}:attachDiskSensor(${sensorTag}, ${center}, ${radius})\n`;
	}
};
physicsCategory.contents.push({
	kind: 'block',
	type: 'disk_fixture',
	inputs: {
		CENTER: shadowVec2Zero,
		RADIUS: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 100,
				},
			},
		},
		DENSITY: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 1,
				},
			},
		},
		FRICTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0.4,
				},
			},
		},
		RESTITUTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		SENSOR_TAG: {
			shadow: {
				type: 'logic_null',
			},
		}
	}
});

// polygon_fixture
const polygonFixtureBlock = {
	type: 'polygon_fixture',
	message0: zh ? '多边形\n顶点 %1\n密度 %2 摩擦力 %3 弹性 %4\n用作感应器的编号为 %5' : 'Polygon\nvertices %1\ndensity %2 friction %3 restitution %4\nas sensor with tag %5',
	args0: [
		{
			type: 'input_value',
			name: 'VERTICES',
			check: 'Array',
		},
		{
			type: 'input_value',
			name: 'DENSITY',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'FRICTION',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'RESTITUTION',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'SENSOR_TAG',
			check: 'Number'
		}
	],
	previousStatement: null,
	nextStatement: null,
	style: 'math_blocks',
};
Blockly.Blocks['polygon_fixture'] = {
	init: function() {
		this.jsonInit(polygonFixtureBlock);
	},
	onchange: function (this: Blockly.Block & {ALLOWED_FIXTURES: string[]}, e: Blockly.Events.Abstract) {
		if (
			((this.workspace as Blockly.WorkspaceSvg).isDragging &&
			(this.workspace as Blockly.WorkspaceSvg).isDragging()) ||
			(e.type !== Blockly.Events.BLOCK_MOVE && e.type !== Blockly.Events.BLOCK_CREATE)
		) {
			return;
		}
		let legal = false;
		// eslint-disable-next-line @typescript-eslint/no-this-alias
		let block = this;
		do {
			if (block.type === 'body_create') {
				legal = true;
				break;
			}
			block = block.getSurroundParent()!;
		} while (block);
		if (legal) {
			this.setWarningText(null);
		} else {
			this.setWarningText(zh ? '多边形形状必须嵌套在刚体创建块中' : 'Polygon shape must be nested in a body create block');
		}
		if (!this.isInFlyout) {
			try {
				Blockly.Events.setRecordUndo(false);
				this.setDisabledReason(!legal, 'UNPARENTED_POLYGON');
			} finally {
				Blockly.Events.setRecordUndo(true);
			}
		}
	}
};
luaGenerator.forBlock['polygon_fixture'] = function(block: Blockly.Block) {
	const vertices = luaGenerator.valueToCode(block, 'VERTICES', Order.NONE);
	const density = luaGenerator.valueToCode(block, 'DENSITY', Order.NONE);
	const friction = luaGenerator.valueToCode(block, 'FRICTION', Order.NONE);
	const restitution = luaGenerator.valueToCode(block, 'RESTITUTION', Order.NONE);
	const sensorTag = luaGenerator.valueToCode(block, 'SENSOR_TAG', Order.NONE);
	const bodyDefVar = bodyDefStack[bodyDefStack.length - 1];
	if (sensorTag === '' || sensorTag === 'nil') {
		return `${bodyDefVar}:attachPolygon(${vertices === '' ? 'nil' : vertices}, ${density}, ${friction}, ${restitution})\n`;
	} else {
		return `${bodyDefVar}:attachPolygonSensor(${sensorTag}, ${vertices === '' ? 'nil' : vertices})\n`;
	}
};
physicsCategory.contents.push({
	kind: 'block',
	type: 'polygon_fixture',
	inputs: {
		VERTICES: {
			block: {
				type: 'lists_create_with',
				extraState: {
					itemCount: 4,
				},
				inputs: {
					ADD0: newVec2(-100, -50, false),
					ADD1: newVec2(-100, 0, false),
					ADD2: newVec2(100, 0, false),
					ADD3: newVec2(100, -50, false),
				},
			},
		},
		DENSITY: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 1,
				},
			},
		},
		FRICTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0.4,
				},
			},
		},
		RESTITUTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		SENSOR_TAG: {
			shadow: {
				type: 'logic_null',
			},
		}
	},
});

// chain_fixture
const chainFixtureBlock = {
	type: 'chain_fixture',
	message0: zh ? '链条形\n顶点 %1\n摩擦力 %2 弹性 %3' : 'Chain\nvertices %1\nfriction %2 restitution %3',
	args0: [
		{
			type: 'input_value',
			name: 'VERTICES',
			check: 'Array',
		},
		{
			type: 'input_value',
			name: 'FRICTION',
			check: 'Number',
			fields: {
				NUM: 0.4,
			},
		},
		{
			type: 'input_value',
			name: 'RESTITUTION',
			check: 'Number',
			fields: {
				NUM: 0,
			},
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'math_blocks',
};
Blockly.Blocks['chain_fixture'] = {
	init: function() {
		this.jsonInit(chainFixtureBlock);
	},
	onchange: function (this: Blockly.Block & {ALLOWED_FIXTURES: string[]}, e: Blockly.Events.Abstract) {
		if (
			((this.workspace as Blockly.WorkspaceSvg).isDragging &&
			(this.workspace as Blockly.WorkspaceSvg).isDragging()) ||
			(e.type !== Blockly.Events.BLOCK_MOVE && e.type !== Blockly.Events.BLOCK_CREATE)
		) {
			return;
		}
		let legal = false;
		// eslint-disable-next-line @typescript-eslint/no-this-alias
		let block = this;
		do {
			if (block.type === 'body_create') {
				legal = true;
				break;
			}
			block = block.getSurroundParent()!;
		} while (block);
		if (legal) {
			this.setWarningText(null);
		} else {
			this.setWarningText(zh ? '链条形状必须嵌套在刚体创建块中' : 'Chain shape must be nested in a body create block');
		}
		if (!this.isInFlyout) {
			try {
				Blockly.Events.setRecordUndo(false);
				this.setDisabledReason(!legal, 'UNPARENTED_CHAIN');
			} finally {
				Blockly.Events.setRecordUndo(true);
			}
		}
	}
};
luaGenerator.forBlock['chain_fixture'] = function(block: Blockly.Block) {
	const vertices = luaGenerator.valueToCode(block, 'VERTICES', Order.NONE);
	const friction = luaGenerator.valueToCode(block, 'FRICTION', Order.NONE);
	const restitution = luaGenerator.valueToCode(block, 'RESTITUTION', Order.NONE);
	const bodyDefVar = bodyDefStack[bodyDefStack.length - 1];
	return `${bodyDefVar}:attachChain(${vertices === '' ? 'nil' : vertices}, ${friction}, ${restitution})\n`;
};
physicsCategory.contents.push({
	kind: 'block',
	type: 'chain_fixture',
	inputs: {
		VERTICES: {
			block: {
				type: 'lists_create_with',
				extraState: {
					itemCount: 2,
				},
				inputs: {
					ADD0: newVec2(0, 0, false),
					ADD1: newVec2(100, 0, false),
				},
			},
		},
		FRICTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0.4,
				},
			},
		},
		RESTITUTION: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
	},
});
