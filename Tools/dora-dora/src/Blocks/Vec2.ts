/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';

const zh = Info.locale.match(/^zh/) !== null;

const vec2Category = {
	kind: 'category',
	name: zh ? '向量' : 'Vec2',
	categorystyle: 'math_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default vec2Category;

const shadowVec2Zero = {
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
};

// Zero vec2
const vec2ZeroBlock = {
	type: 'vec2_zero',
	message0: zh ? '零二维向量' : 'Vec2 Zero',
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_zero'] = { init: function() { this.jsonInit(vec2ZeroBlock); } };
luaGenerator.forBlock['vec2_zero'] = function(_block: Blockly.Block) {
	Require.add('Vec2');
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
	inputsInline: true,
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_create'] = { init: function() { this.jsonInit(vec2CreateBlock); } };
luaGenerator.forBlock['vec2_create'] = function(block: Blockly.Block) {
	const x = luaGenerator.valueToCode(block, 'X', Order.NONE);
	const y = luaGenerator.valueToCode(block, 'Y', Order.NONE);
	Require.add('Vec2');
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

// Get vec2 property
const vec2GetPropertyBlock = {
	type: 'vec2_get_property',
	message0: zh ? '获取二维向量 %1 的 %2' : 'Get vec2 %1 %2',
	args0: [
		{
			type: 'field_variable',
			name: 'VEC2',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'PROPERTY',
			options: zh ? [
				['X 分量', 'x'],
				['Y 分量', 'y'],
				['长度', 'length'],
				['角度', 'angle'],
			] : [
				['X component', 'x'],
				['Y component', 'y'],
				['Length', 'length'],
				['Angle', 'angle'],
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

// Get normalized vec2
const vec2GetNormalizedBlock = {
	type: 'vec2_get_normalized',
	message0: zh ? '获取二维向量 %1 的归一化向量' : 'Get normalized vec2 %1',
	args0: [
		{
			type: 'input_value',
			name: 'VEC2',
			check: 'Vec2',
		},
	],
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_get_normalized'] = { init: function() { this.jsonInit(vec2GetNormalizedBlock); } };
luaGenerator.forBlock['vec2_get_normalized'] = function(block: Blockly.Block) {
	const vec2 = luaGenerator.valueToCode(block, 'VEC2', Order.HIGH);
	return [`${vec2}:normalize()`, Order.ATOMIC];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_get_normalized',
	inputs: {
		VEC2: {
			shadow: {
				type: 'variables_get',
			},
		},
	},
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
		VEC2_1: shadowVec2Zero,
		VEC2_2: shadowVec2Zero,
	},
});

// Binary op number
const vec2BinaryOpNumberBlock = {
	type: 'vec2_binary_op_number',
	message0: zh ? '%1\n%2\n%3' : '%1\n%2\n%3',
	args0: [
		{
			type: 'input_value',
			name: 'VEC2',
			check: 'Vec2',
		},
		{
			type: 'field_dropdown',
			name: 'OPERATION',
			options: [
				['*', '*'],
				['/', '/'],
			],
		},
		{
			type: 'input_value',
			name: 'NUMBER',
			check: 'Number',
		},
	],
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_binary_op_number'] = { init: function() { this.jsonInit(vec2BinaryOpNumberBlock); } };
luaGenerator.forBlock['vec2_binary_op_number'] = function(block: Blockly.Block) {
	const vec2 = luaGenerator.valueToCode(block, 'VEC2', Order.HIGH);
	const operation = block.getFieldValue('OPERATION');
	const number = luaGenerator.valueToCode(block, 'NUMBER', Order.HIGH);
	return [`${vec2} ${operation} ${number}`, Order.MULTIPLICATIVE];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_binary_op_number',
	inputs: {
		VEC2: shadowVec2Zero,
		NUMBER: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 1,
				},
			},
		},
	},
});

// Clamp vec2
const vec2ClampBlock = {
	type: 'vec2_clamp',
	message0: zh ? '限制二维向量 %1\n在 %2\n和 %3\n之间' : 'Clamp vec2 %1\nbetween %2\nand %3',
	args0: [
		{
			type: 'input_value',
			name: 'VEC2',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'MIN',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'MAX',
			check: 'Vec2',
		},
	],
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_clamp'] = { init: function() { this.jsonInit(vec2ClampBlock); } };
luaGenerator.forBlock['vec2_clamp'] = function(block: Blockly.Block) {
	const vec2 = luaGenerator.valueToCode(block, 'VEC2', Order.HIGH);
	const min = luaGenerator.valueToCode(block, 'MIN', Order.HIGH);
	const max = luaGenerator.valueToCode(block, 'MAX', Order.HIGH);
	return [`${vec2}:clamp(${min}, ${max})`, Order.ATOMIC];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_clamp',
	inputs: {
		VEC2: shadowVec2Zero,
		MIN: shadowVec2Zero,
		MAX: shadowVec2Zero,
	},
});

// Calculate between two vec2
const vec2CalculateBlock = {
	type: 'vec2_calculate',
	message0: zh ? '计算二维向量 %1\n和 %2\n的 %3' : 'Between\n%1\nand %2\ncalculate %3',
	args0: [
		{
			type: 'input_value',
			name: 'VEC2_1',
			check: 'Vec2',
		},
		{
			type: 'input_value',
			name: 'VEC2_2',
			check: 'Vec2',
		},
		{
			type: 'field_dropdown',
			name: 'CALCULATE',
			options: zh ? [
				['距离', 'distance'],
				['点积', 'dot'],
			] : [
				['Distance', 'distance'],
				['Dot Product', 'dot'],
			],
		},
	],
	output: 'Number',
	style: 'math_blocks',
};
Blockly.Blocks['vec2_calculate'] = { init: function() { this.jsonInit(vec2CalculateBlock); } };
luaGenerator.forBlock['vec2_calculate'] = function(block: Blockly.Block) {
	const vec2_1 = luaGenerator.valueToCode(block, 'VEC2_1', Order.HIGH);
	const vec2_2 = luaGenerator.valueToCode(block, 'VEC2_2', Order.HIGH);
	const calculate = block.getFieldValue('CALCULATE');
	return [`${vec2_1}:${calculate}(${vec2_2})`, Order.ATOMIC];
};
vec2Category.contents.push({
	kind: 'block',
	type: 'vec2_calculate',
	inputs: {
		VEC2_1: shadowVec2Zero,
		VEC2_2: shadowVec2Zero,
	},
});
