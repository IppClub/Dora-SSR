import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const graphicCategory = {
	kind: 'category',
	name: zh ? '图形' : 'Graphic',
	categorystyle: 'logic_category',
	contents: [] as {kind: string, type: string}[],
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
	const file = luaGenerator.valueToCode(block, 'FILE', Order.ATOMIC);
	return [`Sprite(${file})`, Order.ATOMIC];
};
graphicCategory.contents.push({
	kind: 'block',
	type: 'sprite_create',
});

// Create label
const labelCreateBlock = {
	type: 'label_create',
	message0: zh ? '创建文字节点\n字体为 %1\n大小为 %2' : 'Create label node\nfont is %1\nsize is %2',
	args0: [
		{
			type: 'field_input',
			name: 'FONT',
			text: 'sarasa-mono-sc-regular',
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
	const font = luaGenerator.quote_(block.getFieldValue('FONT'));
	const size = luaGenerator.valueToCode(block, 'SIZE', Order.ATOMIC);
	return [`Label(${font}, ${size === '' ? '16' : size})`, Order.ATOMIC];
};
graphicCategory.contents.push({
	kind: 'block',
	type: 'label_create',
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
	const text = luaGenerator.valueToCode(block, 'TEXT', Order.ATOMIC);
	return `${label}.text = ${text === '' ? '""' : text}\n`;
};
graphicCategory.contents.push({
	kind: 'block',
	type: 'label_set_text',
});
