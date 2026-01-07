/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

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
				type: 'lists_create_with',
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
				type: 'dict_create',
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
declareCategory.contents.push({
	kind: 'block',
	type: 'declare_variable',
	inputs: {
		VALUE: {
			block: {
				type: 'physics_world_create',
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
				type: 'body_create',
				inputs: {
					POSITION: {
						shadow: {
							type: 'vec2_create',
							inputs: {
								X: {
									shadow: {
										type: 'math_number',
										fields: {
											NUM: 0,
										},
									},
								},
								Y: {
									shadow: {
										type: 'math_number',
										fields: {
											NUM: 0,
										},
									},
								},
							},
						}
					},
					ANGLE: {
						shadow: {
							type: 'math_number',
							fields: {
								NUM: 0,
							},
						},
					},
					GROUP: {
						shadow: {
							type: 'math_number',
							fields: {
								NUM: 0,
							},
						},
					},
					GRAVITY: {
						shadow: {
							type: 'vec2_create',
							inputs: {
								X: {
									shadow: {
										type: 'math_number',
										fields: {
											NUM: 0,
										},
									},
								},
								Y: {
									shadow: {
										type: 'math_number',
										fields: {
											NUM: -9.8,
										},
									},
								},
							},
						},
					},
				}
			},
		},
	},
});

