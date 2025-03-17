import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const nodeCategory = {
	kind: 'category',
	name: zh ? '节点' : 'Node',
	categorystyle: 'logic_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default nodeCategory;

// Create node
const nodeCreateBlock = {
	type: 'node_create',
	message0: zh ? '创建节点' : 'Create node',
	output: 'Node',
	style: 'logic_blocks',
};
Blockly.Blocks['node_create'] = { init: function() { this.jsonInit(nodeCreateBlock); } };
luaGenerator.forBlock['node_create'] = function(block: Blockly.Block) {
	return [`Node()`, Order.ATOMIC];
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_create',
});

// Remove node
const nodeRemoveBlock = {
	type: 'node_remove',
	message0: zh ? '删除节点 %1' : 'Remove node %1',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['node_remove'] = { init: function() { this.jsonInit(nodeRemoveBlock); } };
luaGenerator.forBlock['node_remove'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	return `${node}:removeFromParent()\n`;
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_remove',
});

// Add child
const nodeAddChildBlock = {
	type: 'node_add_child',
	message0: zh ? '添加子节点 %1 到父节点 %2 顺序为 %3' : 'Add child node %1 to parent %2 order %3',
	args0: [
		{
			type: 'field_variable',
			name: 'CHILD',
			variable: 'temp',
		},
		{
			type: 'field_variable',
			name: 'PARENT',
			variable: 'parent',
		},
		{
			type: 'input_value',
			name: 'ORDER',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['node_add_child'] = { init: function() { this.jsonInit(nodeAddChildBlock); } };
luaGenerator.forBlock['node_add_child'] = function(block: Blockly.Block) {
	const child = luaGenerator.getVariableName(block.getFieldValue('CHILD'));
	const parent = luaGenerator.getVariableName(block.getFieldValue('PARENT'));
	const order = luaGenerator.valueToCode(block, 'ORDER', Order.NONE);
	return `${child}:addTo(${parent}, ${order})\n`;
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_add_child',
	inputs: {
		ORDER: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
	},
});

// Set vec2 attribute
const nodeSetVec2AttributeBlock = {
	type: 'node_set_vec2_attribute',
	message0: zh ? '设置 %1 的 %2 向量为 %3' : 'Set %1 %2 Vec2 to %3',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['位置', 'position'],
				['大小', 'size'],
				['缩放', 'scale'],
				['锚点', 'anchor'],
			] : [
				['Position', 'position'],
				['Size', 'size'],
				['Scale', 'scale'],
				['Anchor', 'anchor'],
			],
		},
		{
			type: 'input_value',
			name: 'VEC2',
			check: "Vec2",
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['node_set_vec2_attribute'] = { init: function() { this.jsonInit(nodeSetVec2AttributeBlock); } };
luaGenerator.forBlock['node_set_vec2_attribute'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	let vec2 = luaGenerator.valueToCode(block, 'VEC2', Order.NONE);
	if (vec2 === '') {
		vec2 = 'Vec2.zero';
	}
	if (attribute === 'position') {
		return `${node}.position = ${vec2}\n`;
	} else if (attribute === 'size') {
		return `${node}.size = Size(${vec2})\n`;
	} else if (attribute === 'scale') {
		const scaleVar = luaGenerator.nameDB_?.getDistinctName("scale", Blockly.Names.NameType.VARIABLE);
		return `local ${scaleVar} = ${vec2}\n${node}.scaleX = ${scaleVar}.x\n${node}.scaleY = ${scaleVar}.y\n`;
	} else if (attribute === 'anchor') {
		return `${node}.anchor = ${vec2}\n`;
	}
	return '';
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_set_vec2_attribute',
	inputs: {
		VEC2: {
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

// Set boolean attribute
const nodeSetBooleanAttributeBlock = {
	type: 'node_set_boolean_attribute',
	message0: zh ? '设置 %1 的 %2 布尔值为 %3' : 'Set %1 %2 boolean to %3',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['可见', 'visible'],
				['调试可见', 'showDebug'],
			] : [
				['Visible', 'visible'],
				['Show Debug', 'showDebug'],
			],
		},
		{
			type: 'input_value',
			name: 'VALUE',
			check: "Boolean",
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['node_set_boolean_attribute'] = { init: function() { this.jsonInit(nodeSetBooleanAttributeBlock); } };
luaGenerator.forBlock['node_set_boolean_attribute'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	const value = luaGenerator.valueToCode(block, 'VALUE', Order.NONE);
	return `${node}.${attribute} = ${value === '' ? 'true' : value}\n`;
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_set_boolean_attribute',
	inputs: {
		VALUE: {
			shadow: {
				type: 'logic_boolean',
				fields: {
					BOOL: 'TRUE',
				},
			},
		},
	},
});

// Set number attribute
const nodeSetNumberAttributeBlock = {
	type: 'node_set_number_attribute',
	message0: zh ? '设置 %1 的 %2 数值为 %3' : 'Set %1 %2 number to %3',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['X 坐标', 'x'],
				['Y 坐标', 'y'],
				['Z 坐标', 'z'],
				['宽度', 'width'],
				['高度', 'height'],
				['角度', 'angle'],
				['X 角度', 'angleX'],
				['Y 角度', 'angleY'],
				['缩放', 'scale'],
				['X 缩放', 'scaleX'],
				['Y 缩放', 'scaleY'],
				['不透明度', 'opacity'],
			] : [
				['X', 'x'],
				['Y', 'y'],
				['Z', 'z'],
				['Width', 'width'],
				['Height', 'height'],
				['Angle', 'angle'],
				['AngleX', 'angleX'],
				['AngleY', 'angleY'],
				['Scale', 'scale'],
				['ScaleX', 'scaleX'],
				['ScaleY', 'scaleY'],
				['Opacity', 'opacity'],
			],
		},
		{
			type: 'input_value',
			name: 'VALUE',
			check: "Number",
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['node_set_number_attribute'] = { init: function() { this.jsonInit(nodeSetNumberAttributeBlock); } };
luaGenerator.forBlock['node_set_number_attribute'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	const value = luaGenerator.valueToCode(block, 'VALUE', Order.NONE);
	if (attribute === 'scale') {
		const scaleVar = luaGenerator.nameDB_?.getDistinctName("scale", Blockly.Names.NameType.VARIABLE);
		return `local ${scaleVar} = ${value === '' ? '0' : value}\n${node}.scaleX = ${scaleVar}\n${node}.scaleY = ${scaleVar}\n`;
	} else {
		return `${node}.${attribute} = ${value === '' ? '0' : value}\n`;
	}
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_set_number_attribute',
	inputs: {
		VALUE: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
	},
});

// Set color
const nodeSetColorBlock = {
	type: 'node_set_color',
	message0: zh ? '设置 %1 的颜色为 %2' : 'Set %1 color to %2',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'input_value',
			name: 'COLOR',
			check: "Color3",
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['node_set_color'] = { init: function() { this.jsonInit(nodeSetColorBlock); } };
luaGenerator.forBlock['node_set_color'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const color = luaGenerator.valueToCode(block, 'COLOR', Order.NONE);
	return `${node}.color3 = ${color === '' ? 'Color3(0xffffff)' : color}\n`;
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_set_color',
	inputs: {
		COLOR: {
			shadow: {
				type: 'colour_hsv_sliders',
			},
		},
	},
});

// Get vec2 attribute
const nodeGetVec2AttributeBlock = {
	type: 'node_get_vec2_attribute',
	message0: zh ? '获取 %1 的 %2 向量' : 'Get %1 %2 Vec2',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['位置', 'position'],
				['大小', 'size'],
				['缩放', 'scale'],
				['锚点', 'anchor'],
			] : [
				['Position', 'position'],
				['Size', 'size'],
				['Scale', 'scale'],
				['Anchor', 'anchor'],
			],
		},
	],
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['node_get_vec2_attribute'] = { init: function() { this.jsonInit(nodeGetVec2AttributeBlock); } };
luaGenerator.forBlock['node_get_vec2_attribute'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	if (attribute === 'position') {
		return [`${node}.position`, Order.ATOMIC];
	} else if (attribute === 'size') {
		return [`Vec2(${node}.size)`, Order.ATOMIC];
	} else if (attribute === 'scale') {
		return [`Vec2(${node}.scaleX, ${node}.scaleY)`, Order.ATOMIC];
	} else if (attribute === 'anchor') {
		return [`${node}.anchor`, Order.ATOMIC];
	}
	return ['Vec2.zero', Order.ATOMIC];
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_get_vec2_attribute',
});

// Get boolean attribute
const nodeGetBooleanAttributeBlock = {
	type: 'node_get_boolean_attribute',
	message0: zh ? '获取 %1 的 %2 布尔值' : 'Get %1 %2 boolean',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['可见', 'visible'],
				['调试可见', 'showDebug'],
			] : [
				['Visible', 'visible'],
				['Show Debug', 'showDebug'],
			],
		},
	],
	output: 'Boolean',
	style: 'math_blocks',
};
Blockly.Blocks['node_get_boolean_attribute'] = { init: function() { this.jsonInit(nodeGetBooleanAttributeBlock); } };
luaGenerator.forBlock['node_get_boolean_attribute'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	if (attribute === 'visible') {
		return [`${node}.visible`, Order.ATOMIC];
	} else if (attribute === 'showDebug') {
		return [`${node}.showDebug`, Order.ATOMIC];
	}
	return ['false', Order.ATOMIC];
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_get_boolean_attribute',
});

// Get number attribute
const nodeGetNumberAttributeBlock = {
	type: 'node_get_number_attribute',
	message0: zh ? '获取 %1 的 %2 数值' : 'Get %1 %2 number',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['X 坐标', 'x'],
				['Y 坐标', 'y'],
				['Z 坐标', 'z'],
				['宽度', 'width'],
				['高度', 'height'],
				['角度', 'angle'],
				['X 角度', 'angleX'],
				['Y 角度', 'angleY'],
				['X 缩放', 'scaleX'],
				['Y 缩放', 'scaleY'],
				['X 锚点', 'anchorX'],
				['Y 锚点', 'anchorY'],
				['不透明度', 'opacity'],
			] : [
				['X', 'x'],
				['Y', 'y'],
				['Z', 'z'],
				['Width', 'width'],
				['Height', 'height'],
				['Angle', 'angle'],
				['AngleX', 'angleX'],
				['AngleY', 'angleY'],
				['ScaleX', 'scaleX'],
				['ScaleY', 'scaleY'],
				['AnchorX', 'anchorX'],
				['AnchorY', 'anchorY'],
				['Opacity', 'opacity'],
			],
		},
	],
	output: 'Number',
	style: 'math_blocks',
};
Blockly.Blocks['node_get_number_attribute'] = { init: function() { this.jsonInit(nodeGetNumberAttributeBlock); } };
luaGenerator.forBlock['node_get_number_attribute'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	if (attribute === 'anchorX') {
		return [`${node}.anchor.x`, Order.ATOMIC];
	} else if (attribute === 'anchorY') {
		return [`${node}.anchor.y`, Order.ATOMIC];
	} else {
		return [`${node}.${attribute}`, Order.ATOMIC];
	}
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_get_number_attribute',
});

// Get color
const nodeGetColorBlock = {
	type: 'node_get_color',
	message0: zh ? '获取 %1 的颜色' : 'Get %1 color',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
	],
	output: 'Color3',
	style: 'math_blocks',
};
Blockly.Blocks['node_get_color'] = { init: function() { this.jsonInit(nodeGetColorBlock); } };
luaGenerator.forBlock['node_get_color'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	return [`${node}.color3`, Order.ATOMIC];
};
nodeCategory.contents.push({
	kind: 'block',
	type: 'node_get_color',
});
