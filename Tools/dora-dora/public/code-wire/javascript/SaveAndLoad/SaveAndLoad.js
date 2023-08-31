import { Nodes } from '../Nodes/nodes.js'
import { addConnectionWire } from '../Wiring/Wiring.js'
import { variableList } from '../Variable/variable.js'
import {showAlert, vscriptOnLoad} from '../main/alertBox.js'
function writeError(err, msg) {
    document.getElementById("console-window").classList.toggle("hidden", false);
    let codeDoc = document.getElementById("console").contentWindow.document;
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
                "${msg}"<br>
                ${err}
                </code>
                </body>
                </html>
                `
    );
    codeDoc.close();
}
let placeLocation = function (location) {
    //"this" is stage
    return {
        x: (location.x - this.x()) / this.scaleX(),
        y: (location.y - this.y()) / this.scaleY()
    };
}
export class Export {
    constructor(stage, layer, wireLayer) {
        document.getElementById('export').addEventListener("click", (e) => {
            let exportScript = [];
            let nodesData = [];
            let wireData = [];
            layer.find('.aProgramNodeGroup').forEach((node, index) => {
                if (node.name() == 'aProgramNodeGroup') {
                    let nodeData = {
                        position: node.position(),
                        nodeDescription: node.customClass.nodeDescription,
                    };
                    nodesData.push(nodeData);
                }
            });
            wireLayer.find('.isConnection').forEach((aWire, index) => {
                if (aWire.name() == 'isConnection') {
                    let wireD = {
                        srcId: aWire.attrs.src.id(),
                        destId: aWire.attrs.dest.id(),
                    }
                    wireData.push(wireD);
                }
            })
            exportScript = {
                variables: variableList.variables,
                nodesData: nodesData,
                wireData: wireData,
            }
            let dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(exportScript));
            let exportAnchorElem = document.getElementById('exportAnchorElem');
            exportAnchorElem.setAttribute("href", dataStr);
            exportAnchorElem.setAttribute("download", "wireScript.json");
            exportAnchorElem.click();

            // console.log(JSON.stringify(exportScript));
            // console.log(JSON.parse(JSON.stringify(exportScript)));
        });
    }
}
export function refresh(layer, wireLayer) {
    layer.destroyChildren();
    wireLayer.destroyChildren();
    variableList.deleteAllVariables();
    layer.draw();
    wireLayer.draw();
}

export class Import {
    constructor(stage, layer, wireLayer, script) {
        refresh(layer, wireLayer);
        let json = null;
        try {
            json = JSON.parse(script);
        }
        catch (err) {
            writeError(err, "Error In Loading JSON(JSON TEMPERED)");
        }
        // console.log(json);
        printContent(json, stage, layer, wireLayer);
    }
}
export class Save {
    constructor(stage, layer, wireLayer) {
        document.getElementById('save').addEventListener("click", (e) => {
            let exportScript = [];
            let nodesData = [];
            let wireData = [];
            layer.find('.aProgramNodeGroup').forEach((node, index) => {
                if (node.name() == 'aProgramNodeGroup') {
                    let nodeData = {
                        position: node.position(),
                        nodeDescription: node.customClass.nodeDescription,
                    };
                    nodesData.push(nodeData);
                }
            });
            wireLayer.find('.isConnection').forEach((aWire, index) => {
                if (aWire.name() == 'isConnection') {
                    let wireD = {
                        srcId: aWire.attrs.src.id(),
                        destId: aWire.attrs.dest.id(),
                    }
                    wireData.push(wireD);
                }
            })
            exportScript = {
                variables: variableList.variables,
                nodesData: nodesData,
                wireData: wireData,
            }
            localStorage.setItem('lastLoadWireScriptJSON', JSON.stringify(exportScript));
            let savingWindow = document.getElementById("saving");
            // let importMenu = document.getElementById("import-menu");
            [...document.getElementsByClassName("sidebox")].forEach(value => {
                if (value !== savingWindow) {
                    value.classList.toggle("hidden", true);
                }
                else {
                    value.classList.toggle("hidden", false);
                }
            })
            setTimeout(() => {
                savingWindow.classList.toggle("hidden", true);
            }, 600);

        });
        window.addEventListener("load", () => {
            // console.log("loaded");
            prompLastSave(stage, layer, wireLayer);
        })
    }
}

export function prompLastSave(stage, layer, wireLayer) {
    let saveMenu = document.getElementById("save-menu");
    [...document.getElementsByClassName("sidebox")].forEach(value => {
        value.classList.toggle("hidden", true);
    });
    // document.getElementById("saving").classList.toggle("hidden", true);
    // document.getElementById("import-menu").classList.toggle("hidden", true);
    if (localStorage.getItem('lastLoadWireScriptJSON') && localStorage.getItem('lastLoadWireScriptJSON') != "{\"variables\":[],\"nodesData\":[],\"wireData\":[]}") {
        saveMenu.classList.toggle("hidden", false);
        document.getElementById("load-btn").onclick = function () {
            new Import(stage, layer, wireLayer, localStorage.getItem('lastLoadWireScriptJSON'));
            saveMenu.classList.toggle("hidden", true);
        };
        document.getElementById("load-cancel-btn").onclick = function () {
            saveMenu.classList.toggle("hidden", true);
        };
    }
    else{
        vscriptOnLoad(stage);
        showAlert('No Previous Save Was Found');
    }
}

function printContent(json, stage, layer, wireLayer) {
    for (let aNode of json.nodesData) {
        try {
            new Nodes.ProgramNode(aNode.nodeDescription, { x: aNode.position.x * stage.scaleX() + stage.x(), y: aNode.position.y * stage.scaleY() + stage.y() }, layer, stage);

        }
        catch (err) {
            writeError(err, "Error Occurred In Importing The JSON(Node Description Not Valid)");
        }
    }
    // let X = layer.findOne('Group');
    // console.log(layer.children);
    // console.log(X); 
    for (let aWire of json.wireData) {
        // console.log(`${aWire.srcId}`, `${aWire.destId}`);
        let src = layer.findOne(`#${aWire.srcId}`);
        let dest = layer.findOne(`#${aWire.destId}`);
        // console.log(src, dest);
        try {
            addConnectionWire(dest, src, stage, 1, wireLayer);
        }
        catch (err) {
            writeError(err, "Error Occurred In Importing The JSON(Wire Data Not Valid)");
        }
    }
    for (let aVariable of json.variables) {
        try {
            variableList.addVariable(aVariable);
        }
        catch (err) {
            writeError(err, "Error Occurred In Importing The JSON(Variable Data Not Valid)");
        }
    }
    layer.draw();
    wireLayer.draw();
}
