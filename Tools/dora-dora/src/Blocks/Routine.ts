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
	message0: zh ? '创建线程 %1' : 'Create thread %1',
	inputsInline: false,
	args0: [
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
	const action = luaGenerator.statementToCode(block, 'ACTION');
	return `thread(function()\n${action}end)`;
};
routineCategory.contents.push({
	kind: 'block',
	type: 'thread',
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
