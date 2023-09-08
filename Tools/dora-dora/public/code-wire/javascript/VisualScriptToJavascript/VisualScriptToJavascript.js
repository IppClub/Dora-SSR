import { variableList } from '../Variable/variable.js'
import { showAlert } from '../main/alertBox.js'
export var VSToJS = class {
	constructor(stage, layer, isRunOrCode) {
		this.script = '';
		this.nodeCount = 0;
		this.isRunOrCode = isRunOrCode;
		this.indent = 0;
		let begin = this.getBegin(stage);
		if (begin) {
			for (let variable of variableList.variables) {
				this.script += `local ${variable.name} = ${variable.value} -- ${begin._id}\n`;
			}
			try {
				this.coreAlgorithm(begin);
			} catch (err) {
				document.getElementById("console-window").classList.toggle("hidden", false);
				let codeDoc = document.getElementById("console").contentWindow.document;
				this.script = '';
				codeDoc.open();
				let errDesc = `UnknownException`;
				switch (err.name) {
					case 'RangeError':
						errDesc = 'CyclicDependence : Irresolvable Cycle(s) Exists';
						break;
					case 'InputError':
						errDesc = err.message;
						break;
				}
				codeDoc.writeln(
					`<!DOCTYPE html>\n
					<style>
						html{
							color: white;
							margin: 20;
						}
					</style>
					<body>
					<code>
					Recheck the nodes<br>
					${errDesc}
					</code>
					</body>
					</html>
					`
				);
			}
		}
	}
	getIndent() {
		return "\t".repeat(this.indent);
	}
	getBegin(stage) {
		let X = stage.find("#Begin");
		if (X.length == 0) {
			showAlert("Include Begin Node");
		}
		else if (X.length > 1) {
			showAlert("Multiple Begin Nodes");
		}
		else return X[0];
	}
	getExecOut(node) {
		let X = [];
		for (let aNode of node.customClass.execOutPins) {
			if (aNode.wire)
				X.push(aNode.wire.attrs.dest.getParent());
			else
				X.push(null);
		}
		// console.log(X);
		return X;
	}
	getSrcOutputPinNumber(grp, aNodeWire) {
		let c = 0;
		for (let eachPin of grp.customClass.outputPins) {
			for (let aWire of eachPin.wire) {
				if (aWire === aNodeWire) {
					return c;
				}
			}
			c++;
		}
	}
	getInputPins(node) {
		let X = [];
		for (let aNode of node.customClass.inputPins) {
			if (aNode.wire) {
				X.push({ node: aNode.wire.attrs.src.getParent(), isWire: true, srcOutputPinNumber: this.getSrcOutputPinNumber(aNode.wire.attrs.src.getParent(), aNode.wire) });
			} else {
				// console.log(aNode.textBox);
				X.push({ node: aNode.textBox ? aNode.textBox.textBox.text() : null, isWire: false, srcOutputPinNumber: null });
			}
		}
		return X;
	}
	checkInput(nodeId, inputPins, index) {
		const inputNode = inputPins[index];
		if (inputNode === undefined || inputNode === null || (!inputNode.wire && (inputNode.node === null || inputNode.node === ''))) {
			let err = new Error(`node ${nodeId}, expecting value for input pin ${index}`);
			err.name = "InputError";
			throw err;
		}
	}
	coreAlgorithm(node) {
		if (node == null) {
			return;
		}
		let execOutPins = this.getExecOut(node);
		let inputPins = this.getInputPins(node);
		let nodeId = node._id;
		const nl = ` -- ${nodeId}\n`;
		// console.log(node.customClass.type);
		// console.log(inputPins);
		if (node.customClass.type.isGetSet) {
			if (node.customClass.type.typeOfNode.slice(0, 3) == 'Set') {
				this.checkInput(nodeId, inputPins, 0);
				this.script += this.getIndent() + `${node.customClass.type.typeOfNode.slice(4)} = ${this.handleInputs(inputPins[0])}${nl}`;
				for (let each of execOutPins) {
					this.coreAlgorithm(each);
				}
			}
		} else {
			switch (node.customClass.type.typeOfNode) {
				case "Begin": {
					this.coreAlgorithm(execOutPins[0]);
					//this.script = '-- Generated Code Space Begins\n' + this.script + '-- Generated Code Space Ends\n';
					break;
				}
				case "Print": {
					this.checkInput(nodeId, inputPins, 0);
					this.script += this.getIndent() + `print(${this.handleInputs(inputPins[0])})${nl}`;
					this.coreAlgorithm(execOutPins[0]);
					break;
				}
				case "If/Else": {
					this.checkInput(nodeId, inputPins, 0);
					this.script += this.getIndent() + `if ${this.handleInputs(inputPins[0])} then${nl}`;
					this.indent++;
					this.coreAlgorithm(execOutPins[0]);
					this.indent--;
					if (execOutPins[1] !== null) {
						this.script += this.getIndent() + `else${nl}`;
						this.indent++;
						this.coreAlgorithm(execOutPins[1]);
						this.indent--;
					}
					this.script += this.getIndent() + `end${nl}`;
					this.coreAlgorithm(execOutPins[2]);
					break;
				}
				case "ForLoop": {
					this.checkInput(nodeId, inputPins, 0);
					this.checkInput(nodeId, inputPins, 1);
					this.checkInput(nodeId, inputPins, 2);
					let forVar = `i${nodeId}`;
					this.script += this.getIndent() + `for ${forVar} = (${this.handleInputs(inputPins[0])}), (${this.handleInputs(inputPins[1])})`;
					if (inputPins[2] !== null) {
						this.script += `, (${this.handleInputs(inputPins[2])}) do${nl}`;
					} else {
						this.script += ` do${nl}`;
					}
					this.indent++;
					this.coreAlgorithm(execOutPins[0]);
					this.indent--;
					this.script += this.getIndent() + `end${nl}`;
					this.coreAlgorithm(execOutPins[1]);
					break;
				}
				case "ForEachLoop": {
					this.checkInput(nodeId, inputPins, 0);
					let forVar = `i${nodeId}`;
					let valueVar = `valuei${nodeId}`;
					const arrVar = this.handleInputs(inputPins[0]);
					this.script += this.getIndent() + `for ${forVar} = 1, #${arrVar} do${nl}`;
					this.indent++;
					this.script += this.getIndent() + `local ${valueVar} = ${arrVar}[${forVar}]${nl}`;
					this.coreAlgorithm(execOutPins[0]);
					this.indent--;
					this.script += this.getIndent() + `end${nl}`;
					this.coreAlgorithm(execOutPins[1]);
					break;
				}
				case "WhileLoop": {
					this.checkInput(nodeId, inputPins, 0);
					this.script += this.getIndent() + `while ${this.handleInputs(inputPins[0])} do${nl}`;
					this.indent++;
					this.coreAlgorithm(execOutPins[0]);
					this.indent--;
					this.script += this.getIndent() + `end${nl}`;
					this.coreAlgorithm(execOutPins[1]);
					break;
				}
				case "Break": {
					this.script += this.getIndent() + `break${nl}`;
					break;
				}
				case "SetIndex": {
					this.checkInput(nodeId, inputPins, 0);
					this.checkInput(nodeId, inputPins, 1);
					this.checkInput(nodeId, inputPins, 2);
					this.script += this.getIndent() + `${this.handleInputs(inputPins[0])}[${this.handleInputs(inputPins[1])}] = ${this.handleInputs(inputPins[2])}${nl}`;
					this.coreAlgorithm(execOutPins[0]);
					break;
				}
				case "Append": {
					this.checkInput(nodeId, inputPins, 0);
					this.checkInput(nodeId, inputPins, 1);
					this.script += this.getIndent() + `table.insert(${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])})${nl}`;
					this.coreAlgorithm(execOutPins[0]);
					break;
				}
				case "Insert": {
					this.checkInput(nodeId, inputPins, 0);
					this.checkInput(nodeId, inputPins, 1);
					this.checkInput(nodeId, inputPins, 2);
					this.script += this.getIndent() + `table.insert(${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])}, ${this.handleInputs(inputPins[2])})${nl}`;
					this.coreAlgorithm(execOutPins[0]);
					break;
				}
				case "RemoveAt": {
					this.checkInput(nodeId, inputPins, 0);
					this.checkInput(nodeId, inputPins, 1);
					this.script += this.getIndent() + `table.remove(${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])})${nl}`;
					this.coreAlgorithm(execOutPins[0]);
					break;
				}
				case "RemoveLast": {
					this.checkInput(nodeId, inputPins, 0);
					this.script += this.getIndent() + `table.remove(${this.handleInputs(inputPins[0])})${nl}`;
					this.coreAlgorithm(execOutPins[0]);
					break;
				}
			}
		}
	}
	handleInputs(inputNode) {
		if (!inputNode.isWire) {
			return inputNode.node;
		}
		let nodeId = inputNode.node._id;
		let inputPins = this.getInputPins(inputNode.node);
		if (inputNode.node.customClass.type.isGetSet) {
			return `${inputNode.node.customClass.type.typeOfNode.slice(4)}`;
		}
		// if (inputNode.node.customClass.type.isFor) {
		//	 return `(i${inputNode.node.customClass.type.isFor})`;
		// }
		let expr = ``;
		switch (inputNode.node.customClass.type.typeOfNode) {
			case "ForLoop": {
				expr = `i${nodeId}`;
				break;
			}
			case "ForEachLoop": {
				if (inputNode.srcOutputPinNumber == 0) {
					expr = `i${nodeId}`;
				} else {
					expr = `valuei${nodeId}`;
				}
				break;
			}
			case "Add": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} + ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Subtract": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} - ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Multiply": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} * ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Divide": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} / ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Power": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} ^ ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Modulo": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} % ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Ceil": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `math.ceil(${this.handleInputs(inputPins[0])})`;
				break;
			}
			case "Floor": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `math.floor(${this.handleInputs(inputPins[0])})`;
				break;
			}
			case "And": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} and ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Or": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} or ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Not": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `not (${this.handleInputs(inputPins[0])})`;
				break;
			}
			case "BitAnd": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} & ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "BitOr": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} | ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "BitXOr": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} ~ ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "BitNeg": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `~${this.handleInputs(inputPins[0])}`;
				break;
			}
			case "Random": {
				expr = `math.random()`;
				break;
			}
			case "Equals": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} == ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Not Equals": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} ~= ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "LessEq": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} <= ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Less": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} < ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Greater": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} > ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "GreaterEq": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `(${this.handleInputs(inputPins[0])} >= ${this.handleInputs(inputPins[1])})`;
				break;
			}
			case "Length": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `#${this.handleInputs(inputPins[0])}`;
				break;
			}
			case "GetIndex": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `${this.handleInputs(inputPins[0])}[${this.handleInputs(inputPins[1])}]`;
				break;
			}
			case "SetIndex": {
				this.checkInput(nodeId, inputPins, 0);
				this.checkInput(nodeId, inputPins, 1);
				expr = `${this.handleInputs(inputPins[0])}[${this.handleInputs(inputPins[1])}]`;
				break;
			}
			case "IsEmpty": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `(#${this.handleInputs(inputPins[0])} == 0)`;
				break;
			}
			case "First": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `${this.handleInputs(inputPins[0])}[1]`;
				break;
			}
			case "Last": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `${this.handleInputs(inputPins[0])}[#${this.handleInputs(inputPins[0])}]`;
				break;
			}
			case "Append" : {
				this.checkInput(nodeId, inputPins, 0);
				expr = `${this.handleInputs(inputPins[0])}`;
				break;
			}
			case "Insert": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `${this.handleInputs(inputPins[0])}`;
				break;
			}
			case "RemoveAt": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `${this.handleInputs(inputPins[0])}`;
				break;
			}
			case "RemoveLast": {
				this.checkInput(nodeId, inputPins, 0);
				expr = `${this.handleInputs(inputPins[0])}`;
				break;
			}
		}
		return expr;
	}
};