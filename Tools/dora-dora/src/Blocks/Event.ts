import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';

const zh = Info.locale.match(/^zh/) !== null;

const eventCategory = {
	kind: 'category',
	name: zh ? '事件' : 'Event',
	categorystyle: 'dora_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default eventCategory;

// onUpdate
const onUpdateBlock = {
	type: 'on_update',
	message0: zh ? '当节点 %1 更新时，更新间隔为 %2\n做 %3' : 'When node %1 updates, the delta time is %2\nDo %3',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_variable',
			name: 'DELTA_TIME',
			variable: 'dt',
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['on_update'] = { init: function() { this.jsonInit(onUpdateBlock); } };
luaGenerator.forBlock['on_update'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const deltaTime = luaGenerator.getVariableName(block.getFieldValue('DELTA_TIME'));
	const action = luaGenerator.statementToCode(block, 'ACTION');
	return `${node}:onUpdate(function(${deltaTime})\n${action}end)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'on_update',
});

// onTapEvent
const onTapEventBlock = {
	type: 'on_tap_event',
	message0: zh ? '当节点 %1 的 %2 事件发生\n接收到参数 %3\n做 %4' : 'When node %1 %2 event occurs\nReceive parameter %3\nDo %4',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'EVENT',
			options: zh ? [
				['点击开始', 'TapBegan'],
				['点击过滤', 'TapFilter'],
				['点击结束', 'TapEnded'],
				['点击完成', 'Tapped'],
			] : [
				['Tap Began', 'TapBegan'],
				['Tap Filter', 'TapFilter'],
				['Tap Ended', 'TapEnded'],
				['Tapped', 'Tapped'],
			],
		},
		{
			type: 'field_variable',
			name: 'TOUCH',
			variable: 'touch',
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['on_tap_event'] = { init: function() { this.jsonInit(onTapEventBlock); } };
luaGenerator.forBlock['on_tap_event'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const event = block.getFieldValue('EVENT');
	const touch = luaGenerator.getVariableName(block.getFieldValue('TOUCH'));
	const action = luaGenerator.statementToCode(block, 'ACTION');
	return `${node}:on${event}(function(${touch})\n${action}end)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'on_tap_event',
});

// Get touch vec2 attribute
const getTouchVec2AttributeBlock = {
	type: 'get_touch_vec2_attribute',
	message0: zh ? '获取点击 %1 的 %2 向量' : 'Get touch %1 %2 Vec2',
	args0: [
		{
			type: 'field_variable',
			name: 'TOUCH',
			variable: 'touch',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['本地坐标', 'location'],
				['世界坐标', 'worldLocation'],
				['位移量', 'delta'],
			] : [
				['Location', 'location'],
				['World location', 'worldLocation'],
				['Delta move', 'delta'],
			],
		},
	],
	output: 'Vec2',
	style: 'math_blocks',
};
Blockly.Blocks['get_touch_vec2_attribute'] = { init: function() { this.jsonInit(getTouchVec2AttributeBlock); } };
luaGenerator.forBlock['get_touch_vec2_attribute'] = function(block: Blockly.Block) {
	const touch = luaGenerator.getVariableName(block.getFieldValue('TOUCH'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	return [`${touch}.${attribute}`, Order.ATOMIC];
};
eventCategory.contents.push({
	kind: 'block',
	type: 'get_touch_vec2_attribute',
});

// Get touch number attribute
const getTouchNumberAttributeBlock = {
	type: 'get_touch_number_attribute',
	message0: zh ? '获取点击 %1 的 %2 数值' : 'Get touch %1 %2 number',
	args0: [
		{
			type: 'field_variable',
			name: 'TOUCH',
			variable: 'touch',
		},
		{
			type: 'field_dropdown',
			name: 'ATTRIBUTE',
			options: zh ? [
				['编号', 'id'],
				['X 坐标', 'x'],
				['Y 坐标', 'y'],
				['世界 X 坐标', 'worldX'],
				['世界 Y 坐标', 'worldY'],
			] : [
				['ID', 'id'],
				['X', 'x'],
				['Y', 'y'],
				['World X', 'worldX'],
				['World Y', 'worldY'],
			],
		},
	],
	output: 'Number',
	style: 'math_blocks',
};
Blockly.Blocks['get_touch_number_attribute'] = { init: function() { this.jsonInit(getTouchNumberAttributeBlock); } };
luaGenerator.forBlock['get_touch_number_attribute'] = function(block: Blockly.Block) {
	const touch = luaGenerator.getVariableName(block.getFieldValue('TOUCH'));
	const attribute = block.getFieldValue('ATTRIBUTE');
	if (attribute === 'x') {
		return [`${touch}.location.x`, Order.ATOMIC];
	} else if (attribute === 'y') {
		return [`${touch}.location.y`, Order.ATOMIC];
	} else if (attribute === 'worldX') {
		return [`${touch}.worldLocation.x`, Order.ATOMIC];
	} else if (attribute === 'worldY') {
		return [`${touch}.worldLocation.y`, Order.ATOMIC];
	} else if (attribute === 'id') {
		return [`${touch}.id`, Order.ATOMIC];
	}
	return ['0', Order.ATOMIC];
};
eventCategory.contents.push({
	kind: 'block',
	type: 'get_touch_number_attribute',
});

const keyNameOptions = zh ? [
	['回车', 'Return'],
	['ESC', 'Escape'],
	['退格', 'BackSpace'],
	['Tab', 'Tab'],
	['空格', 'Space'],
	['!', '!'],
	['"', '"'],
	['#', '#'],
	['%', '%'],
	['$', '$'],
	['&', '&'],
	['\'', '\''],
	['(', '('],
	[')', ')'],
	['*', '*'],
	['+', '+'],
	[',', ','],
	['-', '-'],
	['.', '.'],
	['/', '/'],
	['1', '1'],
	['2', '2'],
	['3', '3'],
	['4', '4'],
	['5', '5'],
	['6', '6'],
	['7', '7'],
	['8', '8'],
	['9', '9'],
	['0', '0'],
	[':', ':'],
	[';', ';'],
	['<', '<'],
	['=', '='],
	['>', '>'],
	['?', '?'],
	['@', '@'],
	['[', '['],
	['\\', '\\'],
	[']', ']'],
	['^', '^'],
	['_', '_'],
	['`', '`'],
	['A', 'A'],
	['B', 'B'],
	['C', 'C'],
	['D', 'D'],
	['E', 'E'],
	['F', 'F'],
	['G', 'G'],
	['H', 'H'],
	['I', 'I'],
	['J', 'J'],
	['K', 'K'],
	['L', 'L'],
	['M', 'M'],
	['N', 'N'],
	['O', 'O'],
	['P', 'P'],
	['Q', 'Q'],
	['R', 'R'],
	['S', 'S'],
	['T', 'T'],
	['U', 'U'],
	['V', 'V'],
	['W', 'W'],
	['X', 'X'],
	['Y', 'Y'],
	['Z', 'Z'],
	['删除', 'Delete'],
	['CapsLock', 'CapsLock'],
	['F1', 'F1'],
	['F2', 'F2'],
	['F3', 'F3'],
	['F4', 'F4'],
	['F5', 'F5'],
	['F6', 'F6'],
	['F7', 'F7'],
	['F8', 'F8'],
	['F9', 'F9'],
	['F10', 'F10'],
	['F11', 'F11'],
	['F12', 'F12'],
	['PrintScreen', 'PrintScreen'],
	['ScrollLock', 'ScrollLock'],
	['Pause', 'Pause'],
	['Insert', 'Insert'],
	['Home', 'Home'],
	['PageUp', 'PageUp'],
	['End', 'End'],
	['PageDown', 'PageDown'],
	['右', 'Right'],
	['左', 'Left'],
	['下', 'Down'],
	['上', 'Up'],
	['系统键', 'Application'],
	['左Ctrl', 'LCtrl'],
	['左Shift', 'LShift'],
	['左Alt', 'LAlt'],
	['左Gui', 'LGui'],
	['右Ctrl', 'RCtrl'],
	['右Shift', 'RShift'],
	['右Alt', 'RAlt'],
	['右Gui', 'RGui'],
] : [
	['Return', 'Return'],
	['Escape', 'Escape'],
	['BackSpace', 'BackSpace'],
	['Tab', 'Tab'],
	['Space', 'Space'],
	['!', '!'],
	['"', '"'],
	['#', '#'],
	['%', '%'],
	['$', '$'],
	['&', '&'],
	['\'', '\''],
	['(', '('],
	[')', ')'],
	['*', '*'],
	['+', '+'],
	[',', ','],
	['-', '-'],
	['.', '.'],
	['/', '/'],
	['1', '1'],
	['2', '2'],
	['3', '3'],
	['4', '4'],
	['5', '5'],
	['6', '6'],
	['7', '7'],
	['8', '8'],
	['9', '9'],
	['0', '0'],
	[':', ':'],
	[';', ';'],
	['<', '<'],
	['=', '='],
	['>', '>'],
	['?', '?'],
	['@', '@'],
	['[', '['],
	['\\', '\\'],
	[']', ']'],
	['^', '^'],
	['_', '_'],
	['`', '`'],
	['A', 'A'],
	['B', 'B'],
	['C', 'C'],
	['D', 'D'],
	['E', 'E'],
	['F', 'F'],
	['G', 'G'],
	['H', 'H'],
	['I', 'I'],
	['J', 'J'],
	['K', 'K'],
	['L', 'L'],
	['M', 'M'],
	['N', 'N'],
	['O', 'O'],
	['P', 'P'],
	['Q', 'Q'],
	['R', 'R'],
	['S', 'S'],
	['T', 'T'],
	['U', 'U'],
	['V', 'V'],
	['W', 'W'],
	['X', 'X'],
	['Y', 'Y'],
	['Z', 'Z'],
	['Delete', 'Delete'],
	['CapsLock', 'CapsLock'],
	['F1', 'F1'],
	['F2', 'F2'],
	['F3', 'F3'],
	['F4', 'F4'],
	['F5', 'F5'],
	['F6', 'F6'],
	['F7', 'F7'],
	['F8', 'F8'],
	['F9', 'F9'],
	['F10', 'F10'],
	['F11', 'F11'],
	['F12', 'F12'],
	['PrintScreen', 'PrintScreen'],
	['ScrollLock', 'ScrollLock'],
	['Pause', 'Pause'],
	['Insert', 'Insert'],
	['Home', 'Home'],
	['PageUp', 'PageUp'],
	['Delete', 'Delete'],
	['End', 'End'],
	['PageDown', 'PageDown'],
	['Right', 'Right'],
	['Left', 'Left'],
	['Down', 'Down'],
	['Up', 'Up'],
	['Application', 'Application'],
	['LCtrl', 'LCtrl'],
	['LShift', 'LShift'],
	['LAlt', 'LAlt'],
	['LGui', 'LGui'],
	['RCtrl', 'RCtrl'],
	['RShift', 'RShift'],
	['RAlt', 'RAlt'],
	['RGui', 'RGui'],
];

// onKeyboardEvent
const onKeyboardEventBlock = {
	type: 'on_keyboard_event',
	message0: zh ? '当节点 %1 的 %2 事件发生\n触发按键为 %3\n做 %4' : 'When node %1 %2 event occurs\nTrigger key is %3\nDo %4',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'EVENT',
			options: zh ? [
				['键盘按下', 'KeyDown'],
				['键盘抬起', 'KeyUp'],
				['键盘按住', 'KeyPressed'],
			] : [
				['Key Down', 'KeyDown'],
				['Key Up', 'KeyUp'],
				['Key Pressed', 'KeyPressed'],
			],
		},
		{
			type: 'field_dropdown',
			name: 'KEY',
			options: keyNameOptions,
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['on_keyboard_event'] = { init: function() { this.jsonInit(onKeyboardEventBlock); } };
luaGenerator.forBlock['on_keyboard_event'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const event = block.getFieldValue('EVENT');
	const key = luaGenerator.quote_(block.getFieldValue('KEY'));
	const action = luaGenerator.statementToCode(block, 'ACTION');
	const keyName = luaGenerator.nameDB_?.getDistinctName('key', Blockly.Names.NameType.VARIABLE) ?? 'key_';
	return `${node}:on${event}(function(${keyName})\n  if ${keyName} == ${key} then\n${action}  end\nend)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'on_keyboard_event',
});

// check key
const checkKeyBlock = {
	type: 'check_key',
	message0: zh ? '检测到键盘按键 %1 状态为 %2' : 'Checked if keyboard %1 is %2',
	args0: [
		{
			type: 'field_dropdown',
			name: 'KEY',
			options: keyNameOptions,
		},
		{
			type: 'field_dropdown',
			name: 'KEY_STATE',
			options: zh ? [
				['按下', 'KeyDown'],
				['抬起', 'KeyUp'],
				['按住', 'KeyPressed'],
			] : [
				['Down', 'KeyDown'],
				['Up', 'KeyUp'],
				['Pressed', 'KeyPressed'],
			],
		},
	],
	output: 'Boolean',
	style: 'math_blocks',
};
Blockly.Blocks['check_key'] = { init: function() { this.jsonInit(checkKeyBlock); } };
luaGenerator.forBlock['check_key'] = function(block: Blockly.Block) {
	const key = luaGenerator.quote_(block.getFieldValue('KEY'));
	const keyState = block.getFieldValue('KEY_STATE');
	return [`Keyboard:is${keyState}(${key})`, Order.ATOMIC];
};
eventCategory.contents.push({
	kind: 'block',
	type: 'check_key',
});

const controllerButtonOptions = zh ? [
	['A', 'a'],
	['B', 'b'],
	['X', 'x'],
	['Y', 'y'],
	['开始', 'start'],
	['返回', 'back'],
	['上', 'dpup'],
	['下', 'dpdown'],
	['左', 'dpleft'],
	['右', 'dpright'],
	['左肩键', 'leftshoulder'],
	['左摇杆', 'leftstick'],
	['右肩键', 'rightshoulder'],
	['右摇杆', 'rightstick'],
] : [
	['A', 'a'],
	['B', 'b'],
	['X', 'x'],
	['Y', 'y'],
	['Start', 'start'],
	['Back', 'back'],
	['Up', 'dpup'],
	['Down', 'dpdown'],
	['Left', 'dpleft'],
	['Right', 'dpright'],
	['LeftShoulder', 'leftshoulder'],
	['LeftStick', 'leftstick'],
	['RightShoulder', 'rightshoulder'],
	['RightStick', 'rightstick'],
];

// onButtonEvent
const onButtonEventBlock = {
	type: 'on_button_event',
	message0: zh ? '当节点 %1 的 %2 事件发生\n控制器编号为 %3\n触发按钮为 %4\n做 %5' : 'When node %1 %2 event occurs\nController id is %3\nTrigger button is %4\nDo %5',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'temp',
		},
		{
			type: 'field_dropdown',
			name: 'EVENT',
			options: [
				['按钮按下', 'ButtonDown'],
				['按钮抬起', 'ButtonUp'],
				['按钮按住', 'ButtonPressed'],
			],
		},
		{
			type: 'input_value',
			name: 'CONTROLLER_ID',
			check: 'Number',
		},
		{
			type: 'field_dropdown',
			name: 'BUTTON',
			options: controllerButtonOptions,
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'logic_blocks',
};
Blockly.Blocks['on_button_event'] = { init: function() { this.jsonInit(onButtonEventBlock); } };
luaGenerator.forBlock['on_button_event'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const event = block.getFieldValue('EVENT');
	const id = luaGenerator.valueToCode(block, 'CONTROLLER_ID', Order.ATOMIC);
	const button = luaGenerator.quote_(block.getFieldValue('BUTTON'));
	const action = luaGenerator.statementToCode(block, 'ACTION');
	const idName = luaGenerator.nameDB_?.getDistinctName('id', Blockly.Names.NameType.VARIABLE) ?? 'id_';
	const buttonName = luaGenerator.nameDB_?.getDistinctName('button', Blockly.Names.NameType.VARIABLE) ?? 'button_';
	return `${node}:on${event}(function(${idName}, ${buttonName})\n  if ${idName} == ${id === '' ? '0' : id} and ${buttonName} == ${button} then\n${action}  end\nend)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'on_button_event',
	inputs: {
		CONTROLLER_ID: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
	},
});

// check controller button
const checkControllerButtonBlock = {
	type: 'check_controller_button',
	message0: zh ? '检测到控制器编号为 %1 的按钮 %2 状态为 %3' : 'Checked if controller with id %1 button %2 is %3',
	args0: [
		{
			type: 'input_value',
			name: 'CONTROLLER_ID',
			check: 'Number',
		},
		{
			type: 'field_dropdown',
			name: 'BUTTON',
			options: controllerButtonOptions,
		},
		{
			type: 'field_dropdown',
			name: 'STATE',
			options: zh ? [
				['按下', 'ButtonDown'],
				['抬起', 'ButtonUp'],
				['按住', 'ButtonPressed'],
			] : [
				['Down', 'ButtonDown'],
				['Up', 'ButtonUp'],
				['Pressed', 'ButtonPressed'],
			],
		},
	],
	output: 'Boolean',
	style: 'math_blocks',
};
Blockly.Blocks['check_controller_button'] = { init: function() { this.jsonInit(checkControllerButtonBlock); } };
luaGenerator.forBlock['check_controller_button'] = function(block: Blockly.Block) {
	const id = luaGenerator.valueToCode(block, 'CONTROLLER_ID', Order.ATOMIC);
	const button = luaGenerator.quote_(block.getFieldValue('BUTTON'));
	const state = block.getFieldValue('STATE');
	return [`Controller:is${state}(${id === '' ? '0' : id}, ${button})`, Order.ATOMIC];
};
eventCategory.contents.push({
	kind: 'block',
	type: 'check_controller_button',
	inputs: {
		CONTROLLER_ID: {
			shadow: {
				type: 'math_number',
				fields: {
					NUM: 0,
				},
			},
		},
	},
});
