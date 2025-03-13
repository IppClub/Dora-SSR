import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const declareCategory = {
	kind: 'category',
	name: zh ? '声明' : 'Declare',
	categorystyle: 'variable_category',
	contents: [] as {kind: string, type: string}[],
};
export default declareCategory;

// Declare variable
const declareVariableBlock = {
	type: 'declare_variable',
	message0: zh ? '声明变量 %1 为 %2' : 'Declare variable %1 as %2',
	args0: [
		{
			type: 'field_variable',
			name: 'VAR',
			variable: 'temp',
		},
		{
			type: 'input_value',
			name: 'VALUE',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'variable_blocks',
};
Blockly.Blocks['declare_variable'] = { init: function() { this.jsonInit(declareVariableBlock); } };
luaGenerator.forBlock['declare_variable'] = function(block: Blockly.Block) {
	const variable = luaGenerator.getVariableName(block.getFieldValue('VAR'));
	const value = luaGenerator.valueToCode(block, 'VALUE', Order.NONE);
	if (value === '') {
		return `local ${variable}\n`;
	} else {
		return `local ${variable} = ${value}\n`;
	}
};
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
});
