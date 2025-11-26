/* Copyright (c) 2017-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const dictCategory = {
	kind: 'category',
	name: zh ? '字典' : 'Dictionary',
	categorystyle: 'colour_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default dictCategory;

// Create empty dictionary
const dictCreateBlock = {
	type: 'dict_create',
	message0: zh ? '创建空字典' : 'Create empty dictionary',
	output: 'Dict',
	style: 'colour_blocks',
};
Blockly.Blocks['dict_create'] = { init: function() { this.jsonInit(dictCreateBlock); } };
luaGenerator.forBlock['dict_create'] = function(_block: Blockly.Block) {
	return ['{}', Order.ATOMIC];
};
dictCategory.contents.push({
	kind: 'block',
	type: 'dict_create',
});

// Get value from dictionary by key
const dictGetBlock = {
	type: 'dict_get',
	message0: zh ? '从字典 %1 获取键 %2 的值' : 'Get value with key %2 from dictionary %1',
	args0: [
		{
			type: 'input_value',
			name: 'DICT',
			check: 'Dict',
		},
		{
			type: 'input_value',
			name: 'KEY',
			check: ['String', 'Number'],
		},
	],
	output: null,
	style: 'colour_blocks',
	tooltip: zh ? '获取字典中指定键的值' : 'Get the value for the specified key from the dictionary',
};
Blockly.Blocks['dict_get'] = { init: function() { this.jsonInit(dictGetBlock); } };
luaGenerator.forBlock['dict_get'] = function(block: Blockly.Block) {
	const dict = luaGenerator.valueToCode(block, 'DICT', Order.ATOMIC);
	const key = luaGenerator.valueToCode(block, 'KEY', Order.NONE);
	return [`${dict}[${key}]`, Order.HIGH];
};
dictCategory.contents.push({
	kind: 'block',
	type: 'dict_get',
	inputs: {
		DICT: {
			shadow: {
				type: 'variables_get',
			},
		},
		KEY: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'key',
				},
			},
		},
	},
});

// Set value in dictionary
const dictSetBlock = {
	type: 'dict_set',
	message0: zh ? '在字典 %1 中设置键 %2 的值为 %3' : 'Set key %2 in dictionary %1 to value %3',
	args0: [
		{
			type: 'input_value',
			name: 'DICT',
			check: 'Dict',
		},
		{
			type: 'input_value',
			name: 'KEY',
			check: ['String', 'Number'],
		},
		{
			type: 'input_value',
			name: 'VALUE',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'colour_blocks',
	tooltip: zh ? '在字典中设置指定键的值' : 'Set the value for the specified key in the dictionary',
};
Blockly.Blocks['dict_set'] = { init: function() { this.jsonInit(dictSetBlock); } };
luaGenerator.forBlock['dict_set'] = function(block: Blockly.Block) {
	const dict = luaGenerator.valueToCode(block, 'DICT', Order.ATOMIC);
	const key = luaGenerator.valueToCode(block, 'KEY', Order.NONE);
	const value = luaGenerator.valueToCode(block, 'VALUE', Order.NONE);
	return `${dict}[${key}] = ${value || 'nil'}\n`;
};
dictCategory.contents.push({
	kind: 'block',
	type: 'dict_set',
	inputs: {
		DICT: {
			shadow: {
				type: 'variables_get',
			},
		},
		KEY: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'key',
				},
			},
		},
		VALUE: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'value',
				},
			},
		},
	},
});

// Check if key exists in dictionary
const dictHasKeyBlock = {
	type: 'dict_has_key',
	message0: zh ? '字典 %1 包含键 %2' : 'Dictionary %1 has key %2',
	args0: [
		{
			type: 'input_value',
			name: 'DICT',
			check: 'Dict',
		},
		{
			type: 'input_value',
			name: 'KEY',
			check: ['String', 'Number'],
		},
	],
	output: 'Boolean',
	style: 'colour_blocks',
	tooltip: zh ? '检查字典是否包含指定的键' : 'Check if the dictionary contains the specified key',
};
Blockly.Blocks['dict_has_key'] = { init: function() { this.jsonInit(dictHasKeyBlock); } };
luaGenerator.forBlock['dict_has_key'] = function(block: Blockly.Block) {
	const dict = luaGenerator.valueToCode(block, 'DICT', Order.ATOMIC);
	const key = luaGenerator.valueToCode(block, 'KEY', Order.NONE);
	return [`${dict}[${key}] ~= nil`, Order.RELATIONAL];
};
dictCategory.contents.push({
	kind: 'block',
	type: 'dict_has_key',
	inputs: {
		DICT: {
			shadow: {
				type: 'variables_get',
			},
		},
		KEY: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'key',
				},
			},
		},
	},
});

// Remove key from dictionary
const dictRemoveKeyBlock = {
	type: 'dict_remove_key',
	message0: zh ? '从字典 %1 中删除键 %2' : 'Remove key %2 from dictionary %1',
	args0: [
		{
			type: 'input_value',
			name: 'DICT',
			check: 'Dict',
		},
		{
			type: 'input_value',
			name: 'KEY',
			check: ['String', 'Number'],
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'colour_blocks',
	tooltip: zh ? '从字典中删除指定的键及其值' : 'Remove the specified key and its value from the dictionary',
};
Blockly.Blocks['dict_remove_key'] = { init: function() { this.jsonInit(dictRemoveKeyBlock); } };
luaGenerator.forBlock['dict_remove_key'] = function(block: Blockly.Block) {
	const dict = luaGenerator.valueToCode(block, 'DICT', Order.ATOMIC);
	const key = luaGenerator.valueToCode(block, 'KEY', Order.NONE);
	return `${dict}[${key}] = nil\n`;
};
dictCategory.contents.push({
	kind: 'block',
	type: 'dict_remove_key',
	inputs: {
		DICT: {
			shadow: {
				type: 'variables_get',
			},
		},
		KEY: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'key',
				},
			},
		},
	},
});
