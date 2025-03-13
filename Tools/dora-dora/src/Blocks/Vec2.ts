import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const vec2Category = {
	kind: 'category',
	name: zh ? '向量' : 'Vec2',
	categorystyle: 'math_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default vec2Category;

// Zero vec2
const vec2ZeroBlock = {
	type: 'vec2_zero',
	message0: zh ? '零二维向量' : 'Vec2 Zero',
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_zero'] = { init: function() { this.jsonInit(vec2ZeroBlock); } };
luaGenerator.forBlock['vec2_zero'] = function(_block: Blockly.Block) {
	return [`Vec2.zero`, Order.ATOMIC];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_zero',
});

// Create vec2
const vec2CreateBlock = {
	type: 'vec2_create',
	message0: zh ? '二维向量(%1, %2)' : 'Vec2(%1, %2)',
	args0: [
		{
			type: 'input_value',
			name: 'X',
			check: 'Number',
		},
		{
			type: 'input_value',
			name: 'Y',
			check: 'Number',
		},
	],
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_create'] = { init: function() { this.jsonInit(vec2CreateBlock); } };
luaGenerator.forBlock['vec2_create'] = function(block: Blockly.Block) {
	const x = luaGenerator.valueToCode(block, 'X', Order.ATOMIC);
	const y = luaGenerator.valueToCode(block, 'Y', Order.ATOMIC);
	return [`Vec2(${x === '' ? '0' : x}, ${y === '' ? '0' : y})`, Order.ATOMIC];
};
vec2Category.contents.push({
	kind: 'block',
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
});

// Get vec2 component
const vec2GetComponentBlock = {
	type: 'vec2_get_component',
	message0: zh ? '获取二维向量 %1 的 %2 分量' : 'Get vec2 %1 %2 component',
	args0: [
		{
			type: 'field_variable',
			name: 'VEC2',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'COMPONENT',
			options: [
				['X', 'x'],
				['Y', 'y'],
			],
		},
	],
	output: 'Number',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_get_component'] = { init: function() { this.jsonInit(vec2GetComponentBlock); } };
luaGenerator.forBlock['vec2_get_component'] = function(block: Blockly.Block) {
	const vec2 = luaGenerator.getVariableName(block.getFieldValue('VEC2'));
	const component = block.getFieldValue('COMPONENT');
	return [`${vec2}.${component}`, Order.ATOMIC];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_get_component',
});

// Binary operation
const vec2BinaryOperationBlock = {
	type: 'vec2_binary_operation',
	message0: zh ? '%1\n%2\n%3' : '%1\n%2\n%3',
	args0: [
		{
			type: 'input_value',
			name: 'VEC2_1',
			check: 'Vec2',
		},
		{
			type: 'field_dropdown',
			name: 'OPERATION',
			options: [
				['+', '+'],
				['-', '-'],
				['×', '*'],
				['÷', '/'],
			],
		},
		{
			type: 'input_value',
			name: 'VEC2_2',
			check: 'Vec2',
		},
	],
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_binary_operation'] = { init: function() { this.jsonInit(vec2BinaryOperationBlock); } };
luaGenerator.forBlock['vec2_binary_operation'] = function(block: Blockly.Block) {
	const vec2_1 = luaGenerator.valueToCode(block, 'VEC2_1', Order.HIGH);
	const operation = block.getFieldValue('OPERATION');
	const vec2_2 = luaGenerator.valueToCode(block, 'VEC2_2', Order.HIGH);
	let order = Order.HIGH;
	switch (operation) {
		case '+': case '-':
			order = Order.ADDITIVE;
			break;
		case '*': case '/':
			order = Order.MULTIPLICATIVE;
			break;
	}
	return [`${vec2_1} ${operation} ${vec2_2}`, order];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_binary_operation',
	inputs: {
		VEC2_1: {
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
		VEC2_2: {
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

// Get vec2 property
const vec2GetPropertyBlock = {
	type: 'vec2_get_property',
	message0: zh ? '获取二维向量 %1 的 %2 属性' : 'Get vec2 %1 %2 property',
	args0: [
		{
			type: 'field_variable',
			name: 'VEC2',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'PROPERTY',
			options: [
				['长度', 'length'],
				['角度', 'angle'],
			],
		},
	],
	output: 'Number',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_get_property'] = { init: function() { this.jsonInit(vec2GetPropertyBlock); } };
luaGenerator.forBlock['vec2_get_property'] = function(block: Blockly.Block) {
	const vec2 = luaGenerator.getVariableName(block.getFieldValue('VEC2'));
	const property = block.getFieldValue('PROPERTY');
	return [`${vec2}.${property}`, Order.ATOMIC];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_get_property',
});
