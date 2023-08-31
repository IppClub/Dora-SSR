import { variableList } from '../Variable/variable.js'
import { showAlert } from '../main/alertBox.js'
import { BuilInFunctions } from './builtInFunctions.js'
export var VSToJS = class {

    constructor(stage, layer, isRunOrCode) {
        this.script = '';
        this.builtin_functions = {};
        this.nodeCount = 0;
        this.isRunOrCode = isRunOrCode;
        for (let variable of variableList.variables) {
            // console.log(variable);
            this.script += `let ${variable.name} = ${variable.value};\n`;
        }
        let begin = this.getBegin(stage);
        if (begin) {
            try {
                this.coreAlgorithm(begin);
                // console.log(this.script);
                if (this.isRunOrCode == "Run") {
                    document.getElementById("console-window").classList.toggle("hidden", false);
                    let codeDoc = document.getElementById("console").contentWindow.document;
                    // console.log("run");
                    codeDoc.open();
                    codeDoc.writeln(
                        `<!DOCTYPE html>\n
                    <style>
                        html{
                            color: white;
                            margin: 20;
                        }
                    </style>
                    <body>
                    <p id="myLog"></p>
                    </body>
                    <script>
                    window.parent = null;
                    window.top = null;
                    window.console = {
                        log: function(str){
                          var node = document.createElement("div");
                          node.appendChild(document.createTextNode(JSON.stringify(str)));
                          document.getElementById("myLog").appendChild(node);
                        }
                      }
                    try{
                    ${this.script}
                    }
                    catch(err){
                        console.log("Error");
                        console.log(\`\${err}\`);
                    }
                    </script>
                    </html>
                    `
                    );
                    codeDoc.close();
                }
            }
            catch (err) {
                document.getElementById("console-window").classList.toggle("hidden", false);
                let codeDoc = document.getElementById("console").contentWindow.document;
                this.script = '';
                this.builtin_functions = {};
                codeDoc.open();
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
                    Recheck the nodes <br>
                    ${err.name === 'RangeError' ? 'CyclicDependence : Irresolvable Cycle(s) Exists' : `UnknownException: Improve The Editor By Opening Issue On GitHub(Just Attach The Exported Graph)`}
                    </code>
                    </body>
                    </html>
                    `
                );
            }
        }
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
            }
            else {
                // console.log(aNode.textBox);
                X.push({ node: aNode.textBox.textBox.text(), isWire: false, srcOutputPinNumber: null });
            }
        }
        return X;
    }
    coreAlgorithm(node) {
        if (node == null) return;
        let execOutPins = this.getExecOut(node);
        let inputPins = this.getInputPins(node);
        // console.log(node.customClass.type);
        // console.log(inputPins);
        if (node.customClass.type.isGetSet) {
            if (node.customClass.type.typeOfNode.slice(0, 3) == 'Set') {
                this.script += `${node.customClass.type.typeOfNode.slice(4)} = ${this.handleInputs(inputPins[0])};\n`;
                for (let each of execOutPins) {
                    this.coreAlgorithm(each);
                }
            }
        }
        else {
            switch (node.customClass.type.typeOfNode) {
                case "Begin": {
                    this.coreAlgorithm(execOutPins[0]);
                    let func_string = `/////////CodeWire Functions Space Begins/////////////
                    
                    `;
                    for (let each_function in this.builtin_functions) {
                        func_string = func_string + BuilInFunctions[each_function];
                    }
                    func_string += `
                    /////////CodeWire Functions Space Ends/////////////
                    //\n//\n/////////Generated JS Code Space Begins/////////////
                    `;
                    this.script = func_string + this.script;
                    this.script += `\n/////////Generated JS Code Space Ends/////////////`;
                }
                    break;
                case "Print": {
                    this.script += `console.log(${this.handleInputs(inputPins[0])});\n
                     `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "Alert": {
                    this.script += `alert(${this.handleInputs(inputPins[0])});\n
                    `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "Confirm": {
                    this.builtin_functions = { ...this.builtin_functions, _confirm: true };
                    this.script += `let _confirm_answer${node._id} = _confirm(${this.handleInputs(inputPins[0])});\n
                    `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "Prompt": {
                    this.builtin_functions = { ...this.builtin_functions, _prompt: true };
                    this.script += `let [_prompt_ok${node._id}, _prompt_value${node._id}] = _prompt(${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])});\n
                        `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "OpenWindow": {
                    this.builtin_functions = { ...this.builtin_functions, _newWindow: true };
                    this.script += `let _window_opened${node._id} = _newWindow(${this.handleInputs(inputPins[0])});\n
                        `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "If/Else": {
                    this.script += `if(${this.handleInputs(inputPins[0])}){\n`;
                    this.coreAlgorithm(execOutPins[0]);
                    this.script += `}\n`;
                    this.script += `else{\n`;
                    this.coreAlgorithm(execOutPins[1]);
                    this.script += `}\n`;
                    this.coreAlgorithm(execOutPins[2]);
                }
                    break;
                case "ForLoop": {
                    let forVar = `i${node._id}`;   //variable used inside the for loop 
                    this.script += `for(let ${forVar} = (${this.handleInputs(inputPins[0])}); ${forVar} < (${this.handleInputs(inputPins[1])}); ${forVar} += (${this.handleInputs(inputPins[2])})){\n`;
                    this.coreAlgorithm(execOutPins[0]);
                    this.script += `}\n`;
                    this.coreAlgorithm(execOutPins[1]);
                }
                    break;
                case "ForEachLoop": {
                    let forVar = `i${node._id}`;   //variable used inside the for loop 
                    this.script += `${this.handleInputs(inputPins[0])}.forEach((value${forVar}, ${forVar}, array${forVar}) => {\n`;
                    this.coreAlgorithm(execOutPins[0]);
                    this.script += `});\n`;
                    this.coreAlgorithm(execOutPins[1]);
                }
                    break;
                case "Break": {
                    this.script += `break;\n`;
                }
                    break;
                case "Continue": {
                    this.script += `continue;\n`;
                }
                    break;
                case "WhileLoop": {
                    this.script += ` while(${this.handleInputs(inputPins[0])}){\n`;
                    this.coreAlgorithm(execOutPins[0]);
                    this.script += `}\n`;
                    this.coreAlgorithm(execOutPins[1]);
                }
                    break;
                case "SetByPos": {
                    this.script += `${this.handleInputs(inputPins[2])}[${this.handleInputs(inputPins[0])}] = ${this.handleInputs(inputPins[1])};\n`;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "PushBack": {
                    this.script += `${this.handleInputs(inputPins[1])}.push(${this.handleInputs(inputPins[0])});\n`;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "PushFront": {
                    this.script += `${this.handleInputs(inputPins[1])}.unshift(${this.handleInputs(inputPins[0])});\n`;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "PopBack": {
                    this.script += `${this.handleInputs(inputPins[0])}.pop();\n`;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "PopFront": {
                    this.script += `${this.handleInputs(inputPins[0])}.shift();\n`;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "Insert": {
                    this.script += `${this.handleInputs(inputPins[2])}.splice(${this.handleInputs(inputPins[0])}, 0, ${this.handleInputs(inputPins[1])});\n`;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "Reverse": {
                    this.script += `${this.handleInputs(inputPins[0])}.reverse();
                    `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "Swap": {
                    this.script += `
                    [${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])}] = [${this.handleInputs(inputPins[1])}, ${this.handleInputs(inputPins[0])}];    //swap using array destructuring :) \n`;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "Sort(Num)": {
                    this.script += `
                        (${this.handleInputs(inputPins[1])}) ? ${this.handleInputs(inputPins[0])}.sort((a, b) => a-b) : ${this.handleInputs(inputPins[0])}.sort((a, b) => b-a);\n
                    `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "HttpRequest": {
                    this.builtin_functions = { ...this.builtin_functions, fetch_data: true };
                    this.script += `
                        fetch_data(${this.handleInputs(inputPins[0])})
                            .then((json_data${node._id}) => {
                                `;
                    this.coreAlgorithm(execOutPins[0]);
                    this.script += `
                            })
                            .catch((err) => {
                                `
                    this.coreAlgorithm(execOutPins[1]);
                    this.script += `
                            });
                    `;
                    this.coreAlgorithm(execOutPins[2]);
                }
                    break;
                case "StrToArray": {
                    this.script += `let strArray${node._id} = ${this.handleInputs(inputPins[0])}.split('');
                    `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
                case "ArrayToStr": {
                    this.script += `let arrayStr${node._id} = ${this.handleInputs(inputPins[0])}.join('');
                        `;
                    this.coreAlgorithm(execOutPins[0]);
                }
                    break;
            }
        }
    }
    handleInputs(inputNode) {

        if (!inputNode.isWire) {
            return inputNode.node;
        }
        let inputPins = this.getInputPins(inputNode.node);
        if (inputNode.node.customClass.type.isGetSet) {
            return `${inputNode.node.customClass.type.typeOfNode.slice(4)}`;
        }
        // if (inputNode.node.customClass.type.isFor) {
        //     return `(i${inputNode.node.customClass.type.isFor})`;
        // }
        let expr = ``;
        switch (inputNode.node.customClass.type.typeOfNode) {
            case "Add": {
                expr = `(${this.handleInputs(inputPins[0])} + ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Subtract": {
                expr = `(${this.handleInputs(inputPins[0])} - ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Multiply": {
                expr = `(${this.handleInputs(inputPins[0])} * ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Divide": {
                expr = `(${this.handleInputs(inputPins[0])} / ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Power": {
                expr = `Math.pow(${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Modulo": {
                expr = `(${this.handleInputs(inputPins[0])} % ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "AND": {
                expr = `(${this.handleInputs(inputPins[0])} && ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Ceil": {
                expr = `Math.ceil(${this.handleInputs(inputPins[0])})`;
            }
                break;
            case "Floor": {
                expr = `Math.floor(${this.handleInputs(inputPins[0])})`;
            }
                break;
            case "OR": {
                expr = `(${this.handleInputs(inputPins[0])} || ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "XOR": {
                expr = `(${this.handleInputs(inputPins[0])} ^ ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "NEG": {
                expr = `!(${this.handleInputs(inputPins[0])})`;
            }
                break;
            case "bAND": {
                expr = `(${this.handleInputs(inputPins[0])} & ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "bOR": {
                expr = `(${this.handleInputs(inputPins[0])} | ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "bXOR": {
                expr = `(${this.handleInputs(inputPins[0])} ^ ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "bNEG": {
                expr = `~${this.handleInputs(inputPins[0])}`;
            }
                break;
            case "Random": {
                expr = `Math.random()`;
            }
                break;
            case "Equals": {
                expr = `(${this.handleInputs(inputPins[0])} === ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Not Equals": {
                expr = `(${this.handleInputs(inputPins[0])} !== ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "LessEq": {
                expr = `(${this.handleInputs(inputPins[0])} <= ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Less": {
                expr = `(${this.handleInputs(inputPins[0])} < ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Greater": {
                expr = `(${this.handleInputs(inputPins[0])} > ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "GreaterEq": {
                expr = `(${this.handleInputs(inputPins[0])} >= ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Length": {
                expr = `${this.handleInputs(inputPins[0])}.length`;
            }
                break;
            case "GetByPos": {
                // console.log("GetByPos");
                expr = `${this.handleInputs(inputPins[1])}[${this.handleInputs(inputPins[0])}]`;
            }
                break;
            case "SetByPos": {
                expr = `${this.handleInputs(inputPins[2])}[${this.handleInputs(inputPins[0])}]`;
            }
                break;
            case "isEmpty": {
                expr = `(${this.handleInputs(inputPins[0])}.length == (0))`;
            }
                break;
            case "Reverse": {
                expr = `${this.handleInputs(inputPins[0])}`;
            }
                break;
            case "PushBack": {
                expr = `${this.handleInputs(inputPins[1])}`;
            }
                break;
            case "PushFront": {
                expr = `${this.handleInputs(inputPins[1])}`;
            }
                break;
            case "PopBack": {
                expr = `${this.handleInputs(inputPins[0])}`;
            }
                break;
            case "PopFront": {
                expr = `${this.handleInputs(inputPins[0])}`;
            }
                break;
            case "Front": {
                expr = `${this.handleInputs(inputPins[0])}[0]`;
            }
                break;
            case "Back": {
                expr = `${this.handleInputs(inputPins[0])}[${this.handleInputs(inputPins[0])}.length - 1]`;
            }
                break;
            case "Insert": {
                expr = `${this.handleInputs(inputPins[2])}`;
            }
                break;
            case "Swap": {
                expr = `${this.handleInputs(inputPins[inputNode.srcOutputPinNumber])}`;
            }
                break;
            case "ForLoop": {
                expr = `i${inputNode.node._id}`;
            }
                break;
            case "ForEachLoop": {
                expr = ``;
                if (inputNode.srcOutputPinNumber == 0)
                    expr = `valuei${inputNode.node._id}`;
                else if (inputNode.srcOutputPinNumber == 1)
                    expr = `i${inputNode.node._id}`;
                else
                    expr = `arrayi${inputNode.node._id}`;
            }
                break;
            case "Sort(Num)": {
                expr = `${this.handleInputs(inputPins[0])}`;
            }
                break;
            case "Max(Array)": {
                expr = `Math.max(...${this.handleInputs(inputPins[0])})`;
            }
                break;
            case "Min(Array)": {
                expr = `Math.min(...${this.handleInputs(inputPins[0])})`;
            }
                break;
            case "Max(Num)": {
                expr = `Math.max(${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Min(Num)": {
                expr = `Math.min(${this.handleInputs(inputPins[0])}, ${this.handleInputs(inputPins[1])})`;
            }
                break;
            case "Search": {
                expr = ``;
                if (inputNode.srcOutputPinNumber == 0) {
                    expr = `(${this.handleInputs(inputPins[1])}.find((value) => value === ${this.handleInputs(inputPins[0])}) === ${this.handleInputs(inputPins[0])})`;
                }
                else {
                    expr = `(${this.handleInputs(inputPins[1])}.findIndex((value) => value === ${this.handleInputs(inputPins[0])}))`;
                }
            }
                break;
            case "BinarySearch(Num)": {
                expr = ``;
                if (inputNode.srcOutputPinNumber == 0) {
                    this.builtin_functions = { ...this.builtin_functions, binary_search_exist: true };
                    expr = `binary_search_exist(${this.handleInputs(inputPins[1])}, ${this.handleInputs(inputPins[0])})`;
                }
                else if (inputNode.srcOutputPinNumber == 1) {
                    this.builtin_functions = { ...this.builtin_functions, lower_bound: true };
                    expr = `lower_bound(${this.handleInputs(inputPins[1])}, ${this.handleInputs(inputPins[0])})`;
                }
                else {
                    this.builtin_functions = { ...this.builtin_functions, upper_bound: true };
                    expr = `upper_bound(${this.handleInputs(inputPins[1])}, ${this.handleInputs(inputPins[0])})`;
                }
            }
                break;
            case "HttpRequest": {
                expr = `json_data${inputNode.node._id}`;
            }
                break;
            case "GetByName(JSON)": {
                expr = `${this.handleInputs(inputPins[0])}[${this.handleInputs(inputPins[1])}]`;
            }
                break;
            case "Confirm": {
                expr = `_confirm_answer${inputNode.node._id}`;
            }
                break;
            case "OpenWindow": {
                expr = `_window_opened${inputNode.node._id}`;
            }
                break;
            case "Prompt": {
                expr = ``;
                if (inputNode.srcOutputPinNumber == 0) {
                    expr = `_prompt_ok${inputNode.node._id}`;
                }
                else {
                    expr = `_prompt_value${inputNode.node._id}`;
                }
            }
                break;
            case "StrToArray": {
                expr = `strArray${inputNode.node._id}`;
            }
                break;
            case "ArrayToStr": {
                expr = `arrayStr${inputNode.node._id}`;
            }
                break;
        }
        return expr;
    }



};