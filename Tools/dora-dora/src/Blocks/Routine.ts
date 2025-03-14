import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const routineCategory = {
	kind: 'category',
	name: zh ? '协程' : 'Routine',
	categorystyle: 'dora_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default routineCategory;

// thread
const threadBlock = {
	type: 'thread',
	message0: zh ? '创建 %1 的线程 %2' : 'Create %1 thread %2',
	inputsInline: false,
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
