/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';
const zh = Info.locale.match(/^zh/) !== null;

const actionCategory = {
	kind: 'category',
	name: zh ? '动作' : 'Action',
	categorystyle: 'logic_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default actionCategory;

// 执行动作
const performActionBlock = {
	type: 'perform_action',
	message0: zh ? '为节点 %1 %2 动作\n%3\n返回执行一次的时间' : 'For node %1 %2 execute action\n%3\nreturn time of an execution',
	inputsInline: true,
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'MODE',
			options: zh ? [
				['执行一次', 'ONCE'],
				['重复执行', 'REPEATED'],
			] : [
				['Once', 'ONCE'],
				['Repeatedly', 'REPEATED'],
			],
		},
		{
			type: 'input_value',
			name: 'ACTION',
			check: 'Action',
		},
	],
	inlineInputs: false,
	output: 'Number',
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['perform_action'] = { init: function() { this.jsonInit(performActionBlock); } };
luaGenerator.forBlock['perform_action'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const mode = block.getFieldValue('MODE') === 'REPEATED' ? 'true' : 'false';
	const action = luaGenerator.valueToCode(block, 'ACTION', Order.NONE);
	if (block.outputConnection?.targetConnection) {
		return [`${node}:perform(${action === '' ? 'nil' : action}, ${mode})`, Order.ATOMIC];
	}
	return `${node}:perform(${action === '' ? 'nil' : action}, ${mode})\n`;
};
actionCategory.contents.push({
	kind: 'block',
	type: 'perform_action',
});

type AnyDuringMigration = any;

// sequence_create_with
export type SequenceCreateWithBlock = Blockly.Block & SequenceCreateWithMixin;
interface SequenceCreateWithMixin extends SequenceCreateWithMixinType {
  itemCount_: number;
}
type SequenceCreateWithMixinType = typeof SEQUENCE_CREATE_WITH;

const SEQUENCE_CREATE_WITH = {
	init: function (this: SequenceCreateWithBlock) {
		this.setStyle('logic_blocks');
		this.itemCount_ = 3;
		this.updateShape_();
		this.setOutput(true, 'Action');
		this.setMutator(
			new Blockly.icons.MutatorIcon(['action_create_with_item'], this as unknown as Blockly.BlockSvg),
		);
	},
	mutationToDom: function (this: SequenceCreateWithBlock): Element {
		const container = Blockly.utils.xml.createElement('mutation');
		container.setAttribute('items', String(this.itemCount_));
		return container;
	},
	domToMutation: function (this: SequenceCreateWithBlock, xmlElement: Element) {
		const items = xmlElement.getAttribute('items');
		if (!items) throw new TypeError('element did not have items');
		this.itemCount_ = parseInt(items, 10);
		this.updateShape_();
	},
	saveExtraState: function (this: SequenceCreateWithBlock): {itemCount: number} {
		return {
			'itemCount': this.itemCount_,
		};
	},
	loadExtraState: function (this: SequenceCreateWithBlock, state: AnyDuringMigration) {
		this.itemCount_ = state['itemCount'];
		this.updateShape_();
	},
	decompose: function (
		this: SequenceCreateWithBlock,
		workspace: Blockly.Workspace,
	): ContainerBlock {
		const containerBlock = workspace.newBlock(
			'action_create_with_container',
		) as ContainerBlock;
		(containerBlock as Blockly.BlockSvg).initSvg();
		let connection = containerBlock.getInput('STACK')!.connection;
		for (let i = 0; i < this.itemCount_; i++) {
			const itemBlock = workspace.newBlock(
				'action_create_with_item',
			) as ItemBlock;
			(itemBlock as Blockly.BlockSvg).initSvg();
			if (!itemBlock.previousConnection) {
				throw new Error('itemBlock has no previousConnection');
			}
			connection!.connect(itemBlock.previousConnection);
			connection = itemBlock.nextConnection;
		}
		return containerBlock;
	},
	compose: function (this: SequenceCreateWithBlock, containerBlock: Blockly.Block) {
		let itemBlock: ItemBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ItemBlock;
		const connections: Blockly.Connection[] = [];
		while (itemBlock) {
			if (itemBlock.isInsertionMarker()) {
				itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
				continue;
			}
			connections.push(itemBlock.valueConnection_ as Blockly.Connection);
			itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
		}
		for (let i = 0; i < this.itemCount_; i++) {
			const connection = this.getInput('ADD' + i)!.connection!.targetConnection;
			if (connection && !connections.includes(connection)) {
				connection.disconnect();
			}
		}
		this.itemCount_ = connections.length;
		this.updateShape_();
		for (let i = 0; i < this.itemCount_; i++) {
			connections[i]?.reconnect(this, 'ADD' + i);
		}
	},
	saveConnections: function (this: SequenceCreateWithBlock, containerBlock: Blockly.Block) {
		let itemBlock: ItemBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ItemBlock;
		let i = 0;
		while (itemBlock) {
			if (itemBlock.isInsertionMarker()) {
				itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
				continue;
			}
			const input = this.getInput('ADD' + i);
			itemBlock.valueConnection_ = input?.connection!
			.targetConnection as Blockly.Connection;
			itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
			i++;
		}
	},
	updateShape_: function (this: SequenceCreateWithBlock) {
		if (this.itemCount_ && this.getInput('EMPTY')) {
			this.removeInput('EMPTY');
		} else if (!this.itemCount_ && !this.getInput('EMPTY')) {
			this.appendDummyInput('EMPTY').appendField(
				zh ? '空序列动作列表' : 'empty sequence action list',
			);
		}
		for (let i = 0; i < this.itemCount_; i++) {
			if (!this.getInput('ADD' + i)) {
				const input = this.appendValueInput('ADD' + i).setAlign(Blockly.inputs.Align.RIGHT);
				input.setCheck('Action');
				if (i === 0) {
					input.appendField(zh ? '序列动作列表' : 'Sequence action list');
				}
			}
		}
		for (let i = this.itemCount_; this.getInput('ADD' + i); i++) {
			this.removeInput('ADD' + i);
		}
	},
};
Blockly.Blocks['sequence_create_with'] = SEQUENCE_CREATE_WITH;
luaGenerator.forBlock['sequence_create_with'] = function(block: Blockly.Block) {
	const items = [];
	for (let i = 0; i < (block as SequenceCreateWithBlock).itemCount_; i++) {
		const item = luaGenerator.valueToCode(block, 'ADD' + i, Order.NONE);
		if (item !== '') {
			items.push(item);
		}
	}
	Require.add('Sequence');
	return [`Sequence(${items.join(', ')})`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'sequence_create_with',
});

// spawn_create_with
export type SpawnCreateWithBlock = Blockly.Block & SpawnCreateWithMixin;
interface SpawnCreateWithMixin extends SpawnCreateWithMixinType {
	itemCount_: number;
}
type SpawnCreateWithMixinType = typeof SPAWN_CREATE_WITH;

const SPAWN_CREATE_WITH = {
	init: function (this: SpawnCreateWithBlock) {
		this.setStyle('logic_blocks');
		this.itemCount_ = 3;
		this.updateShape_();
		this.setOutput(true, 'Action');
		this.setMutator(
			new Blockly.icons.MutatorIcon(['action_create_with_item'], this as unknown as Blockly.BlockSvg),
		);
	},
	mutationToDom: function (this: SpawnCreateWithBlock): Element {
		const container = Blockly.utils.xml.createElement('mutation');
		container.setAttribute('items', String(this.itemCount_));
		return container;
	},
	domToMutation: function (this: SpawnCreateWithBlock, xmlElement: Element) {
		const items = xmlElement.getAttribute('items');
		if (!items) throw new TypeError('element did not have items');
		this.itemCount_ = parseInt(items, 10);
		this.updateShape_();
	},
	saveExtraState: function (this: SpawnCreateWithBlock): {itemCount: number} {
		return {
			'itemCount': this.itemCount_,
		};
	},
	loadExtraState: function (this: SpawnCreateWithBlock, state: AnyDuringMigration) {
		this.itemCount_ = state['itemCount'];
		this.updateShape_();
	},
	decompose: function (
		this: SpawnCreateWithBlock,
		workspace: Blockly.Workspace,
	): ContainerBlock {
		const containerBlock = workspace.newBlock(
			'action_create_with_container',
		) as ContainerBlock;
		(containerBlock as Blockly.BlockSvg).initSvg();
		let connection = containerBlock.getInput('STACK')!.connection;
		for (let i = 0; i < this.itemCount_; i++) {
			const itemBlock = workspace.newBlock(
				'action_create_with_item',
			) as ItemBlock;
			(itemBlock as Blockly.BlockSvg).initSvg();
			if (!itemBlock.previousConnection) {
				throw new Error('itemBlock has no previousConnection');
			}
			connection!.connect(itemBlock.previousConnection);
			connection = itemBlock.nextConnection;
		}
		return containerBlock;
	},
	compose: function (this: SpawnCreateWithBlock, containerBlock: Blockly.Block) {
		let itemBlock: ItemBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ItemBlock;
		const connections: Blockly.Connection[] = [];
		while (itemBlock) {
			if (itemBlock.isInsertionMarker()) {
				itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
				continue;
			}
			connections.push(itemBlock.valueConnection_ as Blockly.Connection);
			itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
		}
		for (let i = 0; i < this.itemCount_; i++) {
			const connection = this.getInput('ADD' + i)!.connection!.targetConnection;
			if (connection && !connections.includes(connection)) {
				connection.disconnect();
			}
		}
		this.itemCount_ = connections.length;
		this.updateShape_();
		for (let i = 0; i < this.itemCount_; i++) {
			connections[i]?.reconnect(this, 'ADD' + i);
		}
	},
	saveConnections: function (this: SpawnCreateWithBlock, containerBlock: Blockly.Block) {
		let itemBlock: ItemBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ItemBlock;
		let i = 0;
		while (itemBlock) {
			if (itemBlock.isInsertionMarker()) {
				itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
				continue;
			}
			const input = this.getInput('ADD' + i);
			itemBlock.valueConnection_ = input?.connection!
			.targetConnection as Blockly.Connection;
			itemBlock = itemBlock.getNextBlock() as ItemBlock | null;
			i++;
		}
	},
	updateShape_: function (this: SpawnCreateWithBlock) {
		if (this.itemCount_ && this.getInput('EMPTY')) {
			this.removeInput('EMPTY');
		} else if (!this.itemCount_ && !this.getInput('EMPTY')) {
			this.appendDummyInput('EMPTY').appendField(
				zh ? '空并行动作列表' : 'empty parallel action list',
			);
		}
		for (let i = 0; i < this.itemCount_; i++) {
			if (!this.getInput('ADD' + i)) {
				const input = this.appendValueInput('ADD' + i).setAlign(Blockly.inputs.Align.RIGHT);
				input.setCheck('Action');
				if (i === 0) {
					input.appendField(zh ? '并行动作列表' : 'Parallel action list');
				}
			}
		}
		for (let i = this.itemCount_; this.getInput('ADD' + i); i++) {
			this.removeInput('ADD' + i);
		}
	},
};
Blockly.Blocks['spawn_create_with'] = SPAWN_CREATE_WITH;
luaGenerator.forBlock['spawn_create_with'] = function(block: Blockly.Block) {
	const items = [];
	for (let i = 0; i < (block as SpawnCreateWithBlock).itemCount_; i++) {
		const item = luaGenerator.valueToCode(block, 'ADD' + i, Order.NONE);
		if (item !== '') {
			items.push(item);
		}
	}
	Require.add('Spawn');
	return [`Spawn(${items.join(', ')})`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'spawn_create_with',
});

const easingOptions = [
	['Linear', 'Linear'],
	['InQuad', 'InQuad'],
	['OutQuad', 'OutQuad'],
	['InOutQuad', 'InOutQuad'],
	['OutInQuad', 'OutInQuad'],
	['InCubic', 'InCubic'],
	['OutCubic', 'OutCubic'],
	['InOutCubic', 'InOutCubic'],
	['OutInCubic', 'OutInCubic'],
	['InQuart', 'InQuart'],
	['OutQuart', 'OutQuart'],
	['InOutQuart', 'InOutQuart'],
	['OutInQuart', 'OutInQuart'],
	['InQuint', 'InQuint'],
	['OutQuint', 'OutQuint'],
	['InOutQuint', 'InOutQuint'],
	['OutInQuint', 'OutInQuint'],
	['InSine', 'InSine'],
	['OutSine', 'OutSine'],
	['InOutSine', 'InOutSine'],
	['OutInSine', 'OutInSine'],
	['InExpo', 'InExpo'],
	['OutExpo', 'OutExpo'],
	['InOutExpo', 'InOutExpo'],
	['OutInExpo', 'OutInExpo'],
	['InCirc', 'InCirc'],
	['OutCirc', 'OutCirc'],
	['InOutCirc', 'InOutCirc'],
	['OutInCirc', 'OutInCirc'],
	['InElastic', 'InElastic'],
	['OutElastic', 'OutElastic'],
	['InOutElastic', 'InOutElastic'],
	['OutInElastic', 'OutInElastic'],
	['InBack', 'InBack'],
	['OutBack', 'OutBack'],
	['InOutBack', 'InOutBack'],
	['OutInBack', 'OutInBack'],
	['InBounce', 'InBounce'],
	['OutBounce', 'OutBounce'],
	['InOutBounce', 'InOutBounce'],
	['OutInBounce', 'OutInBounce'],
];

// Property action
const propertyActionBlock = {
	type: 'property_action',
	message0: zh ? '在 %1 秒内，持续改变 %2\n从 %3 到 %4\n应用缓动 %5' : 'In %1 seconds, change %2\nfrom %3 to %4\napply easing %5',
	args0: [
		{
			type: 'input_value',
			name: 'TIME',
			check: 'Number',
		},
		{
			type: 'field_dropdown',
			name: 'PROPERTY',
			options: zh ? [
				['X 坐标', 'X'],
				['Y 坐标', 'Y'],
				['Z 坐标', 'Z'],
				['宽度', 'Width'],
				['高度', 'Height'],
				['角度', 'Angle'],
				['X 角度', 'AngleX'],
				['Y 角度', 'AngleY'],
				['缩放', 'Scale'],
				['X 缩放', 'ScaleX'],
				['Y 缩放', 'ScaleY'],
				['不透明度', 'Opacity'],
			] : [
				['X', 'X'],
				['Y', 'Y'],
				['Z', 'Z'],
				['Width', 'Width'],
				['Height', 'Height'],
				['Angle', 'Angle'],
				['X Angle', 'AngleX'],
				['Y Angle', 'AngleY'],
				['X Scale', 'ScaleX'],
				['Y Scale', 'ScaleY'],
				['Opacity', 'Opacity'],
			],
		},
		{
			type: 'input_value',
			name: 'START',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'STOP',
			check: 'Number',
		},
		{
			type: 'field_dropdown',
			name: 'EASING',
			options: easingOptions,
		},
	],
	output: 'Action',
	style: 'logic_blocks',
};
Blockly.Blocks['property_action'] = {
	init: function() { this.jsonInit(propertyActionBlock); },
};
luaGenerator.forBlock['property_action'] = function(block: Blockly.Block) {
	const time = luaGenerator.valueToCode(block, 'TIME', Order.NONE);
	const property = block.getFieldValue('PROPERTY');
	const start = luaGenerator.valueToCode(block, 'START', Order.NONE);
	const stop = luaGenerator.valueToCode(block, 'STOP', Order.NONE);
	const easing = block.getFieldValue('EASING');
	Require.add(property);
	Require.add('Ease');
	return [`${property}(${time === '' ? '0' : time}, ${start === '' ? '0' : start}, ${stop === '' ? '0' : stop}, Ease.${easing})`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'property_action',
	inputs: {
		TIME: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 1,
				},
			},
		},
		START: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
		STOP: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 100,
				},
			},
		},
	},
});

// Move action
const moveActionBlock = {
	type: 'move_action',
	message0: zh ? '在 %1 秒内\n从坐标 %2\n移动到坐标 %3\n应用缓动 %4' : 'In %1 seconds\nmove from point %2\nto point %3\napply easing %4',
	args0: [
		{
			type: 'input_value',
			name: 'TIME',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'START',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'STOP',
			check: 'Vec2',
		},
		{
			type: 'field_dropdown',
			name: 'EASING',
			options: easingOptions,
		},
	],
	output: 'Action',
	style: 'logic_blocks',
};
Blockly.Blocks['move_action'] = {
	init: function() { this.jsonInit(moveActionBlock); },
};
luaGenerator.forBlock['move_action'] = function(block: Blockly.Block) {
	const time = luaGenerator.valueToCode(block, 'TIME', Order.NONE);
	const start = luaGenerator.valueToCode(block, 'START', Order.NONE);
	const stop = luaGenerator.valueToCode(block, 'STOP', Order.NONE);
	const easing = block.getFieldValue('EASING');
	Require.add('Move');
	Require.add('Ease');
	if (start === '' || stop === '') {
		Require.add('Vec2');
	}
	return [`Move(${time === '' ? '0' : time}, ${start === '' ? 'Vec2.zero' : start}, ${stop === '' ? 'Vec2.zero' : stop}, Ease.${easing})`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'move_action',
	inputs: {
		TIME: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 1,
				},
			},
		},
		START: {
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
								NUM: 0,
							},
						},
					},
				},
			},
		},
		STOP: {
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
								NUM: 0,
							},
						},
					},
				},
			},
		},
	},
});

// Delay action
const delayActionBlock = {
	type: 'delay_action',
	message0: zh ? '延迟 %1 秒' : 'Delay %1 seconds',
	args0: [
		{
			type: 'input_value',
			name: 'TIME',
			check: 'Number',
		},
	],
	output: 'Action',
	style: 'logic_blocks',
};
Blockly.Blocks['delay_action'] = {
	init: function() { this.jsonInit(delayActionBlock); },
};
luaGenerator.forBlock['delay_action'] = function(block: Blockly.Block) {
	const time = luaGenerator.valueToCode(block, 'TIME', Order.NONE);
	Require.add('Delay');
	return [`Delay(${time === '' ? '0' : time})`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'delay_action',
	inputs: {
		TIME: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 1,
				},
			},
		},
	},
});

// Visible action
const visibleActionBlock = {
	type: 'visible_action',
	message0: zh ? '切换可见性为 %1' : 'Toggle visibility %1',
	args0: [
		{
			type: 'field_dropdown',
			name: 'VISIBLE',
			options: zh ? [
				['显示', 'Show'],
				['隐藏', 'Hide'],
			] : [
				['Show', 'Show'],
				['Hide', 'Hide'],
			],
		},
	],
	output: 'Action',
	style: 'logic_blocks',
};
Blockly.Blocks['visible_action'] = {
	init: function() { this.jsonInit(visibleActionBlock); },
};
luaGenerator.forBlock['visible_action'] = function(block: Blockly.Block) {
	const visible = block.getFieldValue('VISIBLE');
	Require.add(visible);
	return [`${visible}()`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'visible_action',
});

type ContainerBlock = Blockly.Block & ContainerMutator;
interface ContainerMutator extends ContainerMutatorType {}
type ContainerMutatorType = typeof ACTION_CREATE_WITH_CONTAINER;

const ACTION_CREATE_WITH_CONTAINER = {
	init: function (this: ContainerBlock) {
		this.setStyle('list_blocks');
		this.appendDummyInput().appendField(
			zh ? '动作列表' : 'Action list',
		);
		this.appendStatementInput('STACK');
		this.contextMenu = false;
	},
};
Blockly.Blocks['action_create_with_container'] = ACTION_CREATE_WITH_CONTAINER;

type ItemBlock = Blockly.Block & ItemMutator;
interface ItemMutator extends ItemMutatorType {
  valueConnection_?: Blockly.Connection;
}
type ItemMutatorType = typeof ACTION_CREATE_WITH_ITEM;

const ACTION_CREATE_WITH_ITEM = {
	init: function (this: ItemBlock) {
		this.setStyle('list_blocks');
		this.appendDummyInput().appendField(zh ? '动作' : 'Action');
		this.setPreviousStatement(true);
		this.setNextStatement(true);
		this.contextMenu = false;
	},
};
Blockly.Blocks['action_create_with_item'] = ACTION_CREATE_WITH_ITEM;
