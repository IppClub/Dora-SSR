/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';

const zh = Info.locale.match(/^zh/) !== null;

const routineCategory = {
	kind: 'category',
	name: zh ? '协程' : 'Routine',
	categorystyle: 'dora_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default routineCategory;

// node thread
const nodeThreadBlock = {
	type: 'nodeThread',
	message0: zh ? '在节点 %1 上创建 %2 的 %3 线程\n%4' : 'For %1 node, create %2 %3 thread\n%4',
	inputsInline: true,
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'TYPE',
			options: zh ? [
				['执行一次', 'once'],
				['循环执行', 'loop'],
			] : [
				['Once', 'once'],
				['Loop', 'loop'],
			],
		},
		{
			type: 'field_dropdown',
			name: 'MODE',
			options: zh ? [
				['主', 'schedule'],
				['子', 'onUpdate'],
			] : [
				['Main', 'schedule'],
				['Sub', 'onUpdate'],
			],
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'dora_blocks',
};
Blockly.Blocks['nodeThread'] = {
	init: function() { this.jsonInit(nodeThreadBlock); },
};
luaGenerator.forBlock['nodeThread'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const mode = block.getFieldValue('MODE');
	const type = block.getFieldValue('TYPE');
	const action = luaGenerator.statementToCode(block, 'ACTION');
	Require.add(type);
	return `${node}:${mode}(${type}(function()\n${action}end))\n`;
};
routineCategory.contents.push({
	kind: 'block',
	type: 'nodeThread',
	inputs: {
		ACTION: {
			block: {
				type: 'sleep',
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
			},
		},
	},
});

// thread
const threadBlock = {
	type: 'thread',
	message0: zh ? '创建 %1 的线程\n%2' : 'Create %1 thread\n%2',
	inputsInline: true,
	args0: [
		{
			type: 'field_dropdown',
			name: 'TYPE',
			options: zh ? [
				['执行一次', 'thread'],
				['循环执行', 'threadLoop'],
			] : [
				['Once', 'thread'],
				['Loop', 'threadLoop'],
			],
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'dora_blocks',
};
Blockly.Blocks['thread'] = {
	init: function() { this.jsonInit(threadBlock); },
};
luaGenerator.forBlock['thread'] = function(block: Blockly.Block) {
	const type = block.getFieldValue('TYPE');
	const action = luaGenerator.statementToCode(block, 'ACTION');
	Require.add(type);
	return `${type}(function()\n${action}end)\n`;
};
routineCategory.contents.push({
	kind: 'block',
	type: 'thread',
	inputs: {
		ACTION: {
			block: {
				type: 'sleep',
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
			},
		},
	},
});

// sleep
const sleepBlock = {
	type: 'sleep',
	message0: zh ? '等待 %1 秒' : 'Wait %1 seconds',
	args0: [
		{
			type: 'input_value',
			name: 'TIME',
			check: 'Number',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'dora_blocks',
};
Blockly.Blocks['sleep'] = {
	init: function() { this.jsonInit(sleepBlock); },
};
luaGenerator.forBlock['sleep'] = function(block: Blockly.Block) {
	const time = luaGenerator.valueToCode(block, 'TIME', Order.NONE);
	Require.add('sleep');
	return `sleep(${time === '' ? '0' : time})\n`;
};
routineCategory.contents.push({
	kind: 'block',
	type: 'sleep',
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

// wait condition
const waitBlock = {
	type: 'wait',
	message0: zh ? '等待满足条件 %1' : 'Wait for condition %1',
	args0: [
		{
			type: 'input_value',
			name: 'CONDITION',
			check: 'Boolean',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'dora_blocks',
};
Blockly.Blocks['wait'] = {
	init: function() { this.jsonInit(waitBlock); },
};
luaGenerator.forBlock['wait'] = function(block: Blockly.Block) {
	const condition = luaGenerator.valueToCode(block, 'CONDITION', Order.NONE);
	Require.add('wait');
	return `wait(function() return ${condition === '' ? 'true' : condition} end)\n`;
};
routineCategory.contents.push({
	kind: 'block',
	type: 'wait',
	inputs: {
		CONDITION: {
			shadow: {
				type: 'logic_boolean',
				fields: {
					BOOL: 'TRUE',
				},
			},
		},
	},
});
