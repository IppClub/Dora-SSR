import { setLocationOfNode } from '../setLocationOfNode/setLocationOfNode.js'
import { Nodes } from '../Nodes/nodes.js'
import { variableList } from '../Variable/variable.js'
import { deleteProgramNode, deleteWire } from '../Delete/delete.js'

export var ContextMenu = {
    contextMenu: function (stage, layer) {
        let contextMenu = document.getElementById("ctx-menu-container");
        let deleteCtxMenu = document.getElementById("delete-ctx-container");
        let getSetCtxMenu = document.getElementById("get-set-ctx-menu-container");
        let searchBar = document.getElementById("ctx-search-bar");
        let draggedVariableInfo = {
            name: null,
            dataType: null,
        };
        function toggleContextMenu(location, show) {
            if (show) {
                contextMenu.classList.toggle("hidden", false);
                contextMenu.style.left = location[0] + 'px';
                contextMenu.style.top = location[1] + 'px';
                searchBar.focus();
            }
            else {
                contextMenu.classList.toggle("hidden", true);
                searchBar.value = '';
                for (let ctxItem of contextMenu.children[1].children) {
                    ctxItem.classList.toggle("hidden", false);
                }
            }
        }
        function toggleDeleteCtxMenu(location, show) {
            if (show) {
                deleteCtxMenu.classList.toggle("hidden", false);
                deleteCtxMenu.style.left = location[0] + 'px';
                deleteCtxMenu.style.top = location[1] + 'px';

            }
            else {
                deleteCtxMenu.classList.toggle("hidden", true);
            }
        }
        function toggleGetSetCtxMenu(location, show) {
            if (show) {
                getSetCtxMenu.classList.toggle("hidden", false);
                getSetCtxMenu.style.left = location[0] + 'px';
                getSetCtxMenu.style.top = location[1] + 'px';
            }
            else {
                getSetCtxMenu.classList.toggle("hidden", true);
            }
        }
        ContextMenu.addEventToCtxMenuItems = function (e) {
            e.addEventListener('click', function () {
                makeNode(e, stage, layer, toggleContextMenu);
            });
        }
        searchBar.addEventListener("input", (e) => {
            let key = e.target.value.toLowerCase();
            // /\bhe/gmi
            // let patt = /\b(key)/gi;
            // let patt = new RegExp(`${key}`, "gis");
            // console.log(patt);
            for (let ctxItem of contextMenu.children[1].children) {
                if (ctxItem.innerHTML.toString().toLowerCase().includes(key)) {
                    ctxItem.classList.toggle("hidden", false);
                }
                else {
                    ctxItem.classList.toggle("hidden", true);
                }
            }

        });




        for (let e of contextMenu.children[1].children) {
            this.addEventToCtxMenuItems(e);
        };

        // let alreadyPresent = [];   // to prevent adding multiple eventListeners
        stage.on('contextmenu', function (e) {
            e.evt.preventDefault();
            if (e.target === stage) {
                let availY = stage.getContainer().getBoundingClientRect().height - e.evt.clientY;
                let offY = 0, offX = 0;
                if (availY <= 260) {
                    offY = -260;
                }
                let availX = stage.getContainer().getBoundingClientRect().width - e.evt.clientX;
                if (availX <= 200) {
                    offX = -200;
                }
                toggleContextMenu([e.evt.clientX + offX, e.evt.clientY + offY], true);
            }
            else {

                toggleDeleteCtxMenu([e.evt.clientX - 130, e.evt.clientY - 35], true);
                // console.log("xx");
                deleteCtxMenu.onclick = function () {
                    // console.log("x");
                    // console.log(e);
                    if (e.target.getParent().name() == 'aProgramNodeGroup') {
                        deleteProgramNode(e, layer, stage);
                        stage.draw();
                    }
                    else if (e.target.name() == "isConnection") {
                        deleteWire(e.target);
                        stage.draw();
                    }
                    toggleDeleteCtxMenu([e.evt.clientX - 130, e.evt.clientY - 35], false);
                }
            };

        });
        stage.on('click', function (e) {
            toggleContextMenu([e.evt.clientX, e.evt.clientY], false);
            toggleDeleteCtxMenu([], false);
            toggleGetSetCtxMenu([], false);
        });
        document.addEventListener("click", (e) => {
            if (e.target !== stage.getContainer() && e.target !== searchBar)
                toggleContextMenu([0, 0], false);
            if (e.target !== stage.getContainer()) {
                toggleDeleteCtxMenu([], false);
                toggleGetSetCtxMenu([], false);
            }
        });

        getSetCtxMenu.addEventListener("click", (e) => {
            let nodeType = e.target.innerHTML + " " + draggedVariableInfo.name;
            let xx = e.target.parentElement.getBoundingClientRect().x - stage.getContainer().getBoundingClientRect().x;
            let yy = e.target.parentElement.getBoundingClientRect().y - stage.getContainer().getBoundingClientRect().y;
            if (e.target.innerHTML == "Get") {
                Nodes.CreateNode(nodeType, { x: xx, y: yy }, layer, stage, "Get", draggedVariableInfo.dataType, null);
            }
            else {
                Nodes.CreateNode(nodeType, { x: xx, y: yy }, layer, stage, "Set", draggedVariableInfo.dataType, null);
            }
        });


        stage.getContainer().addEventListener('dragenter', (e) => {
            e.preventDefault();
            e.stopPropagation();
        });
        stage.getContainer().addEventListener('dragover', (e) => {
            e.preventDefault();
            e.stopPropagation();
        });
        stage.getContainer().addEventListener('drop', (e) => {
            e.preventDefault();
            if (e.dataTransfer.getData("variableName")) {
                toggleGetSetCtxMenu([e.clientX, e.clientY], true);
                draggedVariableInfo = {
                    name: e.dataTransfer.getData("variableName"),
                    dataType: e.dataTransfer.getData("dataType"),
                }
            }
            e.stopPropagation();
        });
    }
}



function makeNode(e, stage, layer, toggleContextMenu) {
    let xx = e.parentElement.getBoundingClientRect().x - stage.getContainer().getBoundingClientRect().x;
    let yy = e.parentElement.getBoundingClientRect().y - stage.getContainer().getBoundingClientRect().y;
    let node = undefined;
    let dataType;
    if (e.dataset.datatype)
        dataType = e.dataset.datatype;
    let tmp = e.innerHTML.split(" ");
    let isGetSet = "";
    if (tmp[0] == "Get")
        isGetSet = "Get";
    else if (tmp[0] == "Set")
        isGetSet = "Set";
    let defValue = null;
    // console.log(e.innerHTML);
    Nodes.CreateNode(e.innerHTML, { x: xx, y: yy }, layer, stage, isGetSet, dataType, defValue);
    layer.draw();
    toggleContextMenu([], false);
}
