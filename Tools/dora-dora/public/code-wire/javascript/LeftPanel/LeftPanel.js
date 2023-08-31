import { colorMap } from '../ColorMap/colorMap.js'
import { variableList } from '../Variable/variable.js'
import { showAlert } from '../main/alertBox.js'
export class leftPanel {
    constructor() {
        let isBooleanValid = false;
        let isNumberValid = false;
        let isStringValid = false;
        let isArrayValid = false;

        // this.variablesNameList = {};
        document.getElementById("slide-left-panel").addEventListener("click", () => {
            document.getElementById("left-panel").classList.toggle("closed-left-panel");
            document.getElementById("slide-left-panel").children[0].classList.toggle("slider-icon-closed");
        });
        document.getElementById("list-of-variables").addEventListener("click", () => {
            // console.log("clicked");
            // document.getElementById("list-of-variables-down-icon").classList.toggle("list-of-variables-down-icon-closed");
            document.getElementById("list-of-variables-content").classList.toggle("hidden");
            document.getElementById("list-of-variables-down-icon").classList.toggle("left-panel-tab-arrow-up");
        });
        document.getElementById("add-variables").addEventListener("click", () => {
            document.getElementById("add-variables-content").classList.toggle("hidden");
            document.getElementById("add-variables-plus-icon").classList.toggle("left-panel-tab-arrow-up");
        });
        let createVariableForm = document.getElementById("create-variables");
        let forms = {
            numberForm: document.getElementById("number-default-form"),
            stringForm: document.getElementById("string-default-form"),
            boolForm: document.getElementById("bool-default-form"),
            arrayForm: document.getElementById("array-default-form"),
        }
        let formInputsField = {
            numberFormField: document.getElementById("number-default-value"),
            stringFormField: document.getElementById("string-default-value"),
            boolFormField: document.getElementById("bool-default-value"),
            arrayFormField: document.getElementById("array-default-value"),
        }
        let variableDataTypeForm = document.getElementById("variable-data-type");
        variableDataTypeForm.addEventListener("input", (e) => {
            let dataType = variableDataTypeForm.value;
            if (dataType == "Number") {
                for (let each in forms) {
                    forms[each].classList.toggle("hidden", true);
                }
                forms.numberForm.classList.toggle("hidden", false);
            }
            else if (dataType == "String") {
                for (let each in forms) {
                    forms[each].classList.toggle("hidden", true);
                }
                forms.stringForm.classList.toggle("hidden", false);
            }
            else if (dataType == "Boolean") {
                for (let each in forms) {
                    forms[each].classList.toggle("hidden", true);
                }
                forms.boolForm.classList.toggle("hidden", false);
            }
            else if (dataType == "Array") {
                for (let each in forms) {
                    forms[each].classList.toggle("hidden", true);
                }
                forms.arrayForm.classList.toggle("hidden", false);
            }
        });
        document.getElementById("create-btn").addEventListener("click", () => {
            let variableName = document.getElementById("variable-name").value;
            if (variableName.length == 0) {
                showAlert("Variable Name Can't be empty!");
            }
            else if (variableList.variables.some(value => value.name == variableName)) {
                showAlert("Variable Already Exist");
            }
            else if(variableName.includes(' ')){
                showAlert("Variable Name Can't Have Spaces");
            }
            else if(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].includes(variableName[0])){
                showAlert("Variable Name should start with an alphabet or '_'");
            }
            else {
                let value;
                let type = document.getElementById("variable-data-type").value;
                if (type == "Boolean") {
                    value = formInputsField.boolFormField.value;
                    isBooleanValid = true;
                }
                else if (type == "Number") {
                    if (formInputsField.numberFormField.value.length !== 0) {
                        value = formInputsField.numberFormField.value.toString();
                        isNumberValid = true;
                    }
                }
                else if (type == "String") {
                    if (formInputsField.stringFormField.value.length !== 0) {
                        value = formInputsField.stringFormField.value.toString();
                        value = `'${value}'`;
                        isStringValid = true;
                    }
                }
                else if (type == "Array") {
                    if (formInputsField.arrayFormField.value.length !== 0 && formInputsField.arrayFormField.value[0] == '[' && formInputsField.arrayFormField.value[formInputsField.arrayFormField.value.length - 1] == ']') {
                        value = formInputsField.arrayFormField.value.toString();
                        isArrayValid = true;
                    }
                }
                if (isBooleanValid || isNumberValid || isStringValid || isArrayValid) {
                    let variable = {
                        name: variableName,
                        dataType: document.getElementById("variable-data-type").value,
                        value: value,
                    };
                    // this.variablesNameList[variableName] = variableName;
                    variableList.addVariable(variable);
                    document.getElementById("list-of-variables-content").classList.toggle("hidden", false);
                    document.getElementById("list-of-variables-down-icon").classList.toggle("left-panel-tab-arrow-up", false);
                    isBooleanValid = isNumberValid = isStringValid = isArrayValid = false;
                }
                else {
                    showAlert("Empty/Invalid Input");
                    isBooleanValid = isNumberValid = isStringValid = isArrayValid = false;
                }
            }
        });
    }
}
// 'Number': '#00ffff',
//     'String': '#aaff00',
//     'Boolean': '#e60000', 