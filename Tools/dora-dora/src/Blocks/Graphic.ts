/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';

const zh = Info.locale.match(/^zh/) !== null;

const graphicCategory = {
	kind: 'category',
	name: zh ? '图形' : 'Graphic',
	categorystyle: 'logic_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default graphicCategory;

// Create sprite
const spriteCreateBlock = {
	type: 'sprite_create',
	message0: zh ? '创建精灵节点，使用文件 %1' : 'Create sprite node from file %1',
	args0: [
		{
			type: 'input_value',
			name: 'FILE',
			check: "String",
		},
	],
	output: 'Sprite',
	style: 'logic_blocks',
};
Blockly.Blocks['sprite_create'] = { init: function() { this.jsonInit(spriteCreateBlock); } };
luaGenerator.forBlock['sprite_create'] = function(block: Blockly.Block) {
	const file = luaGenerator.valueToCode(block, 'FILE', Order.NONE);
	Require.add('Sprite');
	return [`Sprite(${file})`, Order.ATOMIC];
};
graphicCategory.contents.push({
	kind: 'block',
	type: 'sprite_create',
	inputs: {
		FILE: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'Image/logo.png',
				},
			},
		},
	},
});

// Create label
const labelCreateBlock = {
	type: 'label_create',
	message0: zh ? '创建文字节点\n字体为 %1\n大小为 %2' : 'Create label node\nfont is %1\nsize is %2',
	args0: [
		{
			type: 'input_value',
			name: 'FONT',
			check: "String",
		},
		{
			type: 'input_value',
			name: 'SIZE',
			check: "Number",
		},
	],
	output: 'Label',
	style: 'logic_blocks',
};
Blockly.Blocks['label_create'] = { init: function() { this.jsonInit(labelCreateBlock); } };
luaGenerator.forBlock['label_create'] = function(block: Blockly.Block) {
	const font = luaGenerator.valueToCode(block, 'FONT', Order.NONE);
	const size = luaGenerator.valueToCode(block, 'SIZE', Order.NONE);
	Require.add('Label');
	return [`Label(${font}, ${size === '' ? '16' : size})`, Order.ATOMIC];
};
graphicCategory.contents.push({
	kind: 'block',
	type: 'label_create',
	inputs: {
		FONT: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'sarasa-mono-sc-regular',
				},
			},
		},
		SIZE: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 16,
				},
			},
		},
	},
});

// Set label text
const labelSetTextBlock = {
	type: 'label_set_text',
	message0: zh ? '设置文字节点 %1 的文本为 %2' : 'Set label node %1 text to %2',
	args0: [
		{
			type: 'field_variable',
			name: 'LABEL',
			variable: 'temp',
		},
		{
			type: 'input_value',
			name: 'TEXT',
			check: "String",
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['label_set_text'] = { init: function() { this.jsonInit(labelSetTextBlock); } };
luaGenerator.forBlock['label_set_text'] = function(block: Blockly.Block) {
	const label = luaGenerator.getVariableName(block.getFieldValue('LABEL'));
	const text = luaGenerator.valueToCode(block, 'TEXT', Order.NONE);
	return `${label}.text = ${text === '' ? '""' : text}\n`;
};
graphicCategory.contents.push({
	kind: 'block',
	type: 'label_set_text',
	inputs: {
		TEXT: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: '',
				},
			},
		},
	},
});
