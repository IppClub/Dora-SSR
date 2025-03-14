import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const declareCategory = {
	kind: 'category',
	name: zh ? '声明' : 'Declare',
	categorystyle: 'variable_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
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
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
	inputs: {
		VALUE: {
			block: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
	},
});
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
	inputs: {
		VALUE: {
			block: {
				type: 'logic_boolean',
				fields: {
					BOOL: 'FALSE',
				},
			},
		},
	},
});
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
	inputs: {
		VALUE: {
			block: {
				type: 'text',
				fields: {
					TEXT: '',
				},
			},
		},
	},
});
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
	inputs: {
		VALUE: {
			block: {
				type: 'node_create',
			},
		},
	},
});
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
	inputs: {
		VALUE: {
			block: {
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
			},
		},
	},
});
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
	inputs: {
		VALUE: {
			block: {
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
			},
		},
	},
});