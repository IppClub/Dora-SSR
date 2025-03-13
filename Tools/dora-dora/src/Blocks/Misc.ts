import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const miscCategory = {
	kind: 'category',
	name: zh ? '杂项' : 'Misc',
	categorystyle: 'colour_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default miscCategory;

// print
const printBlock = {
	type: 'print_block',
	message0: zh ? '打印 %1' : 'Print %1',
	args0: [
		{
			type: 'input_value',
			name: 'ITEM',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['print_block'] = { init: function() { this.jsonInit(printBlock); } };
luaGenerator.forBlock['print_block'] = function(block: Blockly.Block) {
	const item = luaGenerator.valueToCode(block, 'ITEM', Order.ATOMIC);
	return `p(${item === '' ? '""' : item})\n`;
};
miscCategory.contents.push({
	kind: 'block',
	type: 'print_block',
	inputs: {
		ITEM: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: '',
				},
			},
		},
	},
});

// Comment
const commentBlock = {
	type: 'comment_block',
	message0: zh ? '标注 %1' : 'Note %1',
	args0: [
		{
			type: 'field_input',
			name: 'NOTE',
			text: '@preview-project on nolog clear',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'text_blocks',
};
Blockly.Blocks['comment_block'] = { init: function() { this.jsonInit(commentBlock); } };
luaGenerator.forBlock['comment_block'] = function(block: Blockly.Block) {
	const note = block.getFieldValue('NOTE');
	return `-- ${note}\n`;
};
miscCategory.contents.push({
	kind: 'block',
	type: 'comment_block',
});

// Colour HSV sliders
const colourHsvSlidersBlock = {
	type: 'colour_hsv_sliders',
	message0: zh ? '颜色 %1' : 'Color %1',
	args0: [
		{
			type: 'field_colour_hsv_sliders',
			name: 'COLOUR',
			colour: '#fac03d',
		},
	],
	output: 'Color3',
	style: 'colour_blocks',
};
Blockly.Blocks['colour_hsv_sliders'] = { init: function() { this.jsonInit(colourHsvSlidersBlock); } };
luaGenerator.forBlock['colour_hsv_sliders'] = function(block: Blockly.Block) {
	const colour = block.getFieldValue('COLOUR');
	return [`Color3(0x${colour.substring(1)})`, Order.ATOMIC];
};
miscCategory.contents.push({
	kind: 'block',
	type: 'colour_hsv_sliders',
});
