import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const actionCategory = {
	kind: 'category',
	name: zh ? '动作' : 'Action',
	categorystyle: 'logic_category',
	contents: [] as {kind: string, type: string}[],
};
export default actionCategory;

// 执行动作
const performActionBlock = {
	type: 'perform_action',
	message0: zh ? '为节点 %1 %2 动作 %3 返回执行一次的时间' : 'For node %1 %2 execute action %3 Return time of an execution',
	inputsInline: false,
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
				['只执行一次', 'ONCE'],
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
	return `${node}:perform(${action === '' ? 'nil' : action}, ${mode})`;
};
actionCategory.contents.push({
	kind: 'block',
	type: 'perform_action',
});

// Sequence
const sequenceActionBlock = {
	type: 'sequence_action',
	message0: zh ? '顺序动作列表 %1' : 'Sequence action list %1',
	args0: [
		{
			type: 'input_value',
			name: 'ACTION',
			check: 'Array',
		},
	],
	output: 'Action',
	style: 'logic_blocks',
};
Blockly.Blocks['sequence_action'] = {
	init: function() { this.jsonInit(sequenceActionBlock); },
};
luaGenerator.forBlock['sequence_action'] = function(block: Blockly.Block) {
	const action = luaGenerator.valueToCode(block, 'ACTION', Order.NONE);
	return [`Sequence(table.unpack(${action}))`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'sequence_action',
});

// Spawn
const spawnActionBlock = {
	type: 'spawn_action',
	message0: zh ? '并行动作列表 %1' : 'Spawn action list %1',
	args0: [
		{
			type: 'input_value',
			name: 'ACTION',
			check: 'Array',
		},
	],
	output: 'Action',
	style: 'logic_blocks',
};
Blockly.Blocks['spawn_action'] = {
	init: function() { this.jsonInit(spawnActionBlock); },
};
luaGenerator.forBlock['spawn_action'] = function(block: Blockly.Block) {
	const action = luaGenerator.valueToCode(block, 'ACTION', Order.NONE);
	return [`Spawn(table.unpack(${action}))`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'spawn_action',
});

// Property action
const propertyActionBlock = {
	type: 'property_action',
	message0: zh ? '在 %1 秒内，持续改变 %2 从 %3 到 %4\n应用缓动 %5' : 'In %1 seconds, change %2 from %3 to %4\nApply easing %5',
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
			options: [
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
			],
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
	return [`${property}(${time === '' ? '0' : time}, ${start === '' ? '0' : start}, ${stop === '' ? '0' : stop}, Ease.${easing})`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'property_action',
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
	return [`Delay(${time === '' ? '0' : time})`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'delay_action',
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
	return [`${visible}()`, Order.ATOMIC];
};
actionCategory.contents.push({
	kind: 'block',
	type: 'visible_action',
});
