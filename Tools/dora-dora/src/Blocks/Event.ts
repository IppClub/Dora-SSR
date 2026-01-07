/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import * as Blockly from 'blockly';
import { luaGenerator, Order } from 'blockly/lua';
import Info from '../Info';
import Require from './Require';

const zh = Info.locale.match(/^zh/) !== null;

const eventCategory = {
	kind: 'category',
	name: zh ? '事件' : 'Event',
	categorystyle: 'procedure_category',
	contents: [] as {kind: string, type: string, inputs?: any}[],
};
export default eventCategory;

// onUpdate
const onUpdateBlock = {
	type: 'on_update',
	message0: zh ? '当节点 %1 更新时，更新间隔为 %2\n做 %3' : 'When node %1 updates, the delta time is %2\ndo %3',
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
	tooltip: zh ? '注册节点更新事件，每帧执行一次，在更新处理中返回 true 来停止。' : 'Register node update event, execute once per frame, return true in update processing to stop.',
	previousStatement: null,
	nextStatement: null,
	style: 'procedure_blocks',
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
	message0: zh ? '当节点 %1 的 %2 事件发生\n接收到参数 %3\n做 %4' : 'When node %1 %2 event occurs\nreceive parameter %3\ndo %4',
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
				['点击移动', 'TapMoved'],
				['点击结束', 'TapEnded'],
				['点击完成', 'Tapped'],
			] : [
				['Tap Began', 'TapBegan'],
				['Tap Filter', 'TapFilter'],
				['Tap Moved', 'TapMoved'],
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
	style: 'procedure_blocks',
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

// Disable Touch
const disableTouchBlock = {
	type: 'disable_touch',
	message0: zh ? '禁用点击 %1' : 'Disable touch %1',
	args0: [
		{
			type: 'field_variable',
			name: 'NODE',
			variable: 'touch',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'procedure_blocks',
};
Blockly.Blocks['disable_touch'] = { init: function() { this.jsonInit(disableTouchBlock); } };
luaGenerator.forBlock['disable_touch'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	return `${node}.enabled = false\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'disable_touch',
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
	message0: zh ? '当节点 %1 的 %2 事件发生\n触发按键为 %3\n做 %4' : 'When node %1 %2 event occurs\ntrigger key is %3\ndo %4',
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
	style: 'procedure_blocks',
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
	Require.add('Keyboard');
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
	message0: zh ? '当节点 %1 的 %2 事件发生\n控制器编号为 %3\n触发按钮为 %4\n做 %5' : 'When node %1 %2 event occurs\ncontroller id is %3\ntrigger button is %4\ndo %5',
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
	style: 'procedure_blocks',
};
Blockly.Blocks['on_button_event'] = { init: function() { this.jsonInit(onButtonEventBlock); } };
luaGenerator.forBlock['on_button_event'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const event = block.getFieldValue('EVENT');
	const id = luaGenerator.valueToCode(block, 'CONTROLLER_ID', Order.NONE);
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
	const id = luaGenerator.valueToCode(block, 'CONTROLLER_ID', Order.NONE);
	const button = luaGenerator.quote_(block.getFieldValue('BUTTON'));
	const state = block.getFieldValue('STATE');
	Require.add('Controller');
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

// onSensorEnter
const onSensorEnterBlock = {
	type: 'on_sensor_enter',
	message0: zh ? '当刚体节点 %1 的 %2 事件发生\n接收到触发刚体为 %3 感应器编号为 %4\n做 %5' : 'When body node %1 %2 event occurs\nreceive trigger body %3 sensor tag %4\ndo %5',
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
				['刚体进入感应器', 'BodyEnter'],
				['刚体离开感应器', 'BodyLeave'],
			] : [
				['Body Enter Sensor', 'BodyEnter'],
				['Body Leave Sensor', 'BodyLeave'],
			],
		},
		{
			type: 'field_variable',
			name: 'BODY',
			variable: 'body',
		},
		{
			type: 'field_variable',
			name: 'SENSOR_TAG',
			variable: 'tag',
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'procedure_blocks',
};
Blockly.Blocks['on_sensor_enter'] = { init: function() { this.jsonInit(onSensorEnterBlock); } };
luaGenerator.forBlock['on_sensor_enter'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const event = block.getFieldValue('EVENT');
	const body = luaGenerator.getVariableName(block.getFieldValue('BODY'));
	const sensorTag = luaGenerator.getVariableName(block.getFieldValue('SENSOR_TAG'));
	const action = luaGenerator.statementToCode(block, 'ACTION');
	return `${node}:on${event}(function(${body}, ${sensorTag})\n${action}end)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'on_sensor_enter',
});

// onContactFilter: function(self: Body, filter: function(other: Body): boolean)
const onContactFilterBlock = {
	type: 'on_contact_filter',
	message0: zh ? '当刚体节点 %1 的接触过滤事件发生\n接收到接触刚体为 %2\n做 %3' : 'When body node %1 contact filter event occurs\nreceive contact body %2\ndo %3',
	args0: [
		{
			type: 'field_variable',
			name: 'BODY',
			variable: 'temp',
		},
		{
			type: 'field_variable',
			name: 'OTHER',
			variable: 'other',
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'procedure_blocks',
};
Blockly.Blocks['on_contact_filter'] = { init: function() { this.jsonInit(onContactFilterBlock); } };
luaGenerator.forBlock['on_contact_filter'] = function(block: Blockly.Block) {
	const body = luaGenerator.getVariableName(block.getFieldValue('BODY'));
	const other = luaGenerator.getVariableName(block.getFieldValue('OTHER'));
	const action = luaGenerator.statementToCode(block, 'ACTION');
	return `${body}:onContactFilter(function(${other})\n${action}end)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'on_contact_filter',
	inputs: {
		ACTION: {
			block: {
				type: 'return_block',
				inputs: {
					VALUE: {
						shadow: {
							type: 'logic_boolean',
						},
					},
				},
			},
		},
	},
});

// onContactEvent
const onContactEventBlock = {
	type: 'on_contact_event',
	message0: zh ? '当刚体节点 %1 的 %2 事件发生\n接收到接触刚体为 %3 接触点为 %4 法向量为 %5 是否启用为 %6\n做 %7' : 'When body node %1 %2 event occurs\nreceive contact body %3 contact point %4 normal vector %5 enabled %6\ndo %7',
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
				['刚体碰撞接触开始', 'ContactStart'],
				['刚体碰撞接触结束', 'ContactEnd'],
			] : [
				['Body Contact Start', 'ContactStart'],
				['Body Contact End', 'ContactEnd'],
			],
		},
		{
			type: 'field_variable',
			name: 'OTHER',
			variable: 'other',
		},
		{
			type: 'field_variable',
			name: 'POINT',
			variable: 'point',
		},
		{
			type: 'field_variable',
			name: 'NORMAL',
			variable: 'normal',
		},
		{
			type: 'field_variable',
			name: 'ENABLED',
			variable: 'enabled',
		},
		{
			type: 'input_statement',
			name: 'ACTION',
		},
	],
	previousStatement: null,
	nextStatement: null,
	style: 'procedure_blocks',
};
Blockly.Blocks['on_contact_event'] = { init: function() { this.jsonInit(onContactEventBlock); } };
luaGenerator.forBlock['on_contact_event'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const event = block.getFieldValue('EVENT');
	const other = luaGenerator.getVariableName(block.getFieldValue('OTHER'));
	const point = luaGenerator.getVariableName(block.getFieldValue('POINT'));
	const normal = luaGenerator.getVariableName(block.getFieldValue('NORMAL'));
	const enabled = luaGenerator.getVariableName(block.getFieldValue('ENABLED'));
	const action = luaGenerator.statementToCode(block, 'ACTION');
	return `${node}:on${event}(function(${other}, ${point}, ${normal}, ${enabled})\n${action}end)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'on_contact_event',
});

type AnyDuringMigration = any;

export type NodeRegisterGlobalEventWithBlock = Blockly.Block & NodeRegisterGlobalEventWithMixin;
interface NodeRegisterGlobalEventWithMixin extends NodeRegisterGlobalEventWithMixinType {
	argCount_: number;
}
type NodeRegisterGlobalEventWithMixinType = typeof NODE_REGISTER_GLOBAL_EVENT;

const NODE_REGISTER_GLOBAL_EVENT = {
	init: function (this: NodeRegisterGlobalEventWithBlock) {
		this.setStyle('procedure_blocks');
		this.argCount_ = 3;
		this.updateShape_();
		this.setPreviousStatement(true);
		this.setNextStatement(true);
		this.setOutput(false);
		this.setMutator(
			new Blockly.icons.MutatorIcon(['arg_create_with_item'], this as unknown as Blockly.BlockSvg),
		);
	},
	mutationToDom: function (this: NodeRegisterGlobalEventWithBlock): Element {
		const container = Blockly.utils.xml.createElement('mutation');
		container.setAttribute('args', String(this.argCount_));
		return container;
	},
	domToMutation: function (this: NodeRegisterGlobalEventWithBlock, xmlElement: Element) {
		const args = xmlElement.getAttribute('args');
		if (!args) throw new TypeError('element did not have args');
		this.argCount_ = parseInt(args, 10);
		this.updateShape_();
	},
	saveExtraState: function (this: NodeRegisterGlobalEventWithBlock): {argCount: number} {
		return {
			'argCount': this.argCount_,
		};
	},
	loadExtraState: function (this: NodeRegisterGlobalEventWithBlock, state: AnyDuringMigration) {
		this.argCount_ = state['argCount'];
		this.updateShape_();
	},
	decompose: function (
		this: NodeRegisterGlobalEventWithBlock,
		workspace: Blockly.Workspace,
	): ArgContainerBlock {
		const containerBlock = workspace.newBlock(
			'arg_create_with_container',
		) as ArgContainerBlock;
		(containerBlock as Blockly.BlockSvg).initSvg();
		let connection = containerBlock.getInput('STACK')!.connection;
		for (let i = 0; i < this.argCount_; i++) {
			const argBlock = workspace.newBlock(
				'arg_create_with_item',
			) as ArgBlock;
			(argBlock as Blockly.BlockSvg).initSvg();
			if (!argBlock.previousConnection) {
				throw new Error('argBlock has no previousConnection');
			}
			connection!.connect(argBlock.previousConnection);
			connection = argBlock.nextConnection;
		}
		return containerBlock;
	},
	compose: function (this: NodeRegisterGlobalEventWithBlock, containerBlock: ArgContainerBlock) {
		let argBlock: ArgBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ArgBlock;
		const connections: Blockly.Connection[] = [];
		while (argBlock) {
			if (argBlock.isInsertionMarker()) {
				argBlock = argBlock.getNextBlock() as ArgBlock | null;
				continue;
			}
			connections.push(argBlock.valueConnection_ as Blockly.Connection);
			argBlock = argBlock.getNextBlock() as ArgBlock | null;
		}
		for (let i = 0; i < this.argCount_; i++) {
			const connection = this.getInput('ADD_SHADOW' + i)!.connection!.targetConnection;
			if (connection && !connections.includes(connection)) {
				connection.disconnect();
			}
		}
		this.argCount_ = connections.length;
		this.updateShape_();
		for (let i = 0; i < this.argCount_; i++) {
			connections[i]?.reconnect(this, 'ADD_SHADOW' + i);
		}
	},
	saveConnections: function (this: NodeRegisterGlobalEventWithBlock, containerBlock: Blockly.Block) {
		let argBlock: ArgBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ArgBlock;
		let i = 0;
		while (argBlock) {
			if (argBlock.isInsertionMarker()) {
				argBlock = argBlock.getNextBlock() as ArgBlock | null;
				continue;
			}
			const input = this.getInput('ADD_SHADOW' + i);
			argBlock.valueConnection_ = input?.connection!
			.targetConnection as Blockly.Connection;
			argBlock = argBlock.getNextBlock() as ArgBlock | null;
			i++;
		}
	},
	updateShape_: function (this: NodeRegisterGlobalEventWithBlock) {
		if (!this.getInput('EVENT')) {
			this.appendDummyInput()
				.appendField(zh ? '在节点' : 'On node')
				.appendField(Blockly.FieldVariable.fromJson({
					variable: 'temp',
				}), 'NODE');
			this.appendValueInput('EVENT').appendField(zh ? '上监听' : 'listen for');
			this.appendDummyInput('EVENT_TYPE')
				.appendField(Blockly.FieldDropdown.fromJson({
					options: zh ? [
						['全局事件', 'gslot'],
						['节点事件', 'slot'],
					] : [
						['Global event', 'gslot'],
						['Node event', 'slot'],
					],
				}), 'EVENT_TYPE');
		}
		if (!this.getInput('NEWLINE')) {
			this.appendEndRowInput('NEWLINE');
		}
		if (this.argCount_ && this.getInput('EMPTY')) {
			this.removeInput('EMPTY');
		} else if (!this.argCount_ && !this.getInput('EMPTY')) {
			this.appendDummyInput('EMPTY').appendField(
				zh ? '空参数列表' : 'empty arguments list',
			);
		}
		for (let i = 0; i < this.argCount_; i++) {
			if (!this.getInput('ADD' + i)) {
				this.appendValueInput('ADD_SHADOW' + i).setVisible(false);
				const input = this.appendDummyInput('ADD' + i);
				if (i === 0) {
					input.appendField(zh ? '接收参数列表' : 'receive arguments list');
				}
				input.appendField(Blockly.FieldVariable.fromJson({
					variable: 'arg' + i,
				}), 'ADD' + i);
			}
		}
		for (let i = this.argCount_; this.getInput('ADD' + i); i++) {
			this.removeInput('ADD' + i);
			this.removeInput('ADD_SHADOW' + i);
		}
		if (!this.getInput('ACTION')) {
			this.appendStatementInput('ACTION').appendField(zh ? '处理' : 'process');
		}
		this.moveInputBefore('ACTION', null);
	},
};
Blockly.Blocks['node_register_global_event'] = NODE_REGISTER_GLOBAL_EVENT;
luaGenerator.forBlock['node_register_global_event'] = function(block: Blockly.Block) {
	const node = luaGenerator.getVariableName(block.getFieldValue('NODE'));
	const event = luaGenerator.valueToCode(block, 'EVENT', Order.NONE);
	const eventType = block.getFieldValue('EVENT_TYPE');
	const args = [];
	for (let i = 0; i < (block as NodeRegisterGlobalEventWithBlock).argCount_; i++) {
		const arg = luaGenerator.getVariableName(block.getFieldValue('ADD' + i));
		if (arg !== '') {
			args.push(arg);
		}
	}
	const action = luaGenerator.statementToCode(block, 'ACTION');
	return `${node}:${eventType}(${event}, function(${args.join(', ')})\n${action}end)\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'node_register_global_event',
	inputs: {
		EVENT: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'event',
				},
			},
		},
	},
});

export type EmitGlobalEventWithBlock = Blockly.Block & EmitGlobalEventWithMixin;
interface EmitGlobalEventWithMixin extends EmitGlobalEventWithMixinType {
	argCount_: number;
}
type EmitGlobalEventWithMixinType = typeof EMIT_GLOBAL_EVENT;

const EMIT_GLOBAL_EVENT = {
	init: function (this: EmitGlobalEventWithBlock) {
		this.setStyle('logic_blocks');
		this.argCount_ = 1;
		this.updateShape_();
		this.setPreviousStatement(true);
		this.setNextStatement(true);
		this.setOutput(false);
		this.setInputsInline(false);
		this.setMutator(
			new Blockly.icons.MutatorIcon(['arg_create_with_item'], this as unknown as Blockly.BlockSvg),
		);
	},
	mutationToDom: function (this: EmitGlobalEventWithBlock): Element {
		const container = Blockly.utils.xml.createElement('mutation');
		container.setAttribute('args', String(this.argCount_));
		return container;
	},
	domToMutation: function (this: EmitGlobalEventWithBlock, xmlElement: Element) {
		const args = xmlElement.getAttribute('args');
		if (!args) throw new TypeError('element did not have args');
		this.argCount_ = parseInt(args, 10);
		this.updateShape_();
	},
	saveExtraState: function (this: EmitGlobalEventWithBlock): {argCount: number} {
		return {
			'argCount': this.argCount_,
		};
	},
	loadExtraState: function (this: EmitGlobalEventWithBlock, state: AnyDuringMigration) {
		this.argCount_ = state['argCount'];
		this.updateShape_();
	},
	decompose: function (
		this: EmitGlobalEventWithBlock,
		workspace: Blockly.Workspace,
	): ArgContainerBlock {
		const containerBlock = workspace.newBlock(
			'arg_create_with_container',
		) as ArgContainerBlock;
		(containerBlock as Blockly.BlockSvg).initSvg();
		let connection = containerBlock.getInput('STACK')!.connection;
		for (let i = 0; i < this.argCount_; i++) {
			const argBlock = workspace.newBlock(
				'arg_create_with_item',
			) as ArgBlock;
			(argBlock as Blockly.BlockSvg).initSvg();
			if (!argBlock.previousConnection) {
				throw new Error('argBlock has no previousConnection');
			}
			connection!.connect(argBlock.previousConnection);
			connection = argBlock.nextConnection;
		}
		return containerBlock;
	},
	compose: function (this: EmitGlobalEventWithBlock, containerBlock: ArgContainerBlock) {
		let argBlock: ArgBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ArgBlock;
		const connections: Blockly.Connection[] = [];
		while (argBlock) {
			if (argBlock.isInsertionMarker()) {
				argBlock = argBlock.getNextBlock() as ArgBlock | null;
				continue;
			}
			connections.push(argBlock.valueConnection_ as Blockly.Connection);
			argBlock = argBlock.getNextBlock() as ArgBlock | null;
		}
		for (let i = 0; i < this.argCount_; i++) {
			const connection = this.getInput('ADD' + i)!.connection!.targetConnection;
			if (connection && !connections.includes(connection)) {
				connection.disconnect();
			}
		}
		this.argCount_ = connections.length;
		this.updateShape_();
		for (let i = 0; i < this.argCount_; i++) {
			connections[i]?.reconnect(this, 'ADD' + i);
		}
	},
	saveConnections: function (this: EmitGlobalEventWithBlock, containerBlock: Blockly.Block) {
		let argBlock: ArgBlock | null = containerBlock.getInputTargetBlock(
			'STACK',
		) as ArgBlock;
		let i = 0;
		while (argBlock) {
			if (argBlock.isInsertionMarker()) {
				argBlock = argBlock.getNextBlock() as ArgBlock | null;
				continue;
			}
			const input = this.getInput('ADD' + i);
			argBlock.valueConnection_ = input?.connection!
			.targetConnection as Blockly.Connection;
			argBlock = argBlock.getNextBlock() as ArgBlock | null;
			i++;
		}
	},
	updateShape_: function (this: EmitGlobalEventWithBlock) {
		if (!this.getInput('EVENT')) {
			this.appendValueInput('EVENT').appendField(zh ? '发送全局事件' : 'Emit global event');
		}
		if (this.argCount_ && this.getInput('EMPTY')) {
			this.removeInput('EMPTY');
		} else if (!this.argCount_ && !this.getInput('EMPTY')) {
			this.appendDummyInput('EMPTY').appendField(
				zh ? '无参数' : 'no arguments',
			);
		}
		for (let i = 0; i < this.argCount_; i++) {
			if (!this.getInput('ADD' + i)) {
				const input = this.appendValueInput('ADD' + i).setAlign(Blockly.inputs.Align.RIGHT);
				if (i === 0) {
					input.appendField(zh ? '参数' : 'arguments');
				}
			}
		}
		for (let i = this.argCount_; this.getInput('ADD' + i); i++) {
			this.removeInput('ADD' + i);
		}
	},
};
Blockly.Blocks['emit_global_event'] = EMIT_GLOBAL_EVENT;
luaGenerator.forBlock['emit_global_event'] = function(block: Blockly.Block) {
	const event = luaGenerator.valueToCode(block, 'EVENT', Order.NONE);
	const args = [event];
	for (let i = 0; i < (block as EmitGlobalEventWithBlock).argCount_; i++) {
		const arg = luaGenerator.valueToCode(block, 'ADD' + i, Order.NONE);
		args.push(arg === '' ? 'nil' : arg);
	}
	Require.add('emit');
	return `emit(${args.join(', ')})\n`;
};
eventCategory.contents.push({
	kind: 'block',
	type: 'emit_global_event',
	inputs: {
		EVENT: {
			shadow: {
				type: 'text',
				fields: {
					TEXT: 'event',
				},
			},
		},
	},
});

export type ArgContainerBlock = Blockly.Block & ArgContainerMutator;
interface ArgContainerMutator extends ArgContainerMutatorType {}
type ArgContainerMutatorType = typeof ARG_CREATE_WITH_CONTAINER;

const ARG_CREATE_WITH_CONTAINER = {
	init: function (this: ArgContainerBlock) {
		this.setStyle('list_blocks');
		this.appendDummyInput().appendField(
			zh ? '参数列表' : 'Argument list',
		);
		this.appendStatementInput('STACK');
		this.contextMenu = false;
	},
};
Blockly.Blocks['arg_create_with_container'] = ARG_CREATE_WITH_CONTAINER;

export type ArgBlock = Blockly.Block & ArgMutator;
interface ArgMutator extends ArgMutatorType {
  valueConnection_?: Blockly.Connection;
}
type ArgMutatorType = typeof ARG_CREATE_WITH_ITEM;

const ARG_CREATE_WITH_ITEM = {
	init: function (this: ArgBlock) {
		this.setStyle('list_blocks');
		this.appendDummyInput().appendField(zh ? '参数' : 'Argument');
		this.setPreviousStatement(true);
		this.setNextStatement(true);
		this.contextMenu = false;
	},
};
Blockly.Blocks['arg_create_with_item'] = ARG_CREATE_WITH_ITEM;
