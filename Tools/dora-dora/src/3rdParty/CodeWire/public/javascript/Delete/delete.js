
export var Delete = {
    enableDelete: function (stage, layer) {
        let ctrlIsPressed = false;
        // console.log(wireLayer);
        stage.on("click", (e) => {
            // console.log(e.target.getParent());
            if (e.target.name() == "isConnection" && ctrlIsPressed) {
                let aWire = e.target;
                deleteWire(aWire);
                let wireLayer = stage.findOne('#wireLayer');
                stage.draw();

            }
            else if (e.target !== stage && e.target.getParent().name() == "aProgramNodeGroup" && ctrlIsPressed) {
                // console.log(e);
                deleteProgramNode(e, layer, stage);

            }
        });
        stage.container().addEventListener("keydown", (e) => {
            e.preventDefault();
            if (e.code == "ControlLeft" && !ctrlIsPressed) {
                ctrlIsPressed = true;
                let wireLayer = stage.findOne('#wireLayer');
                let wireArray = wireLayer.find(".isConnection");
                wireArray.forEach(wire => {
                    wire.strokeWidth(5);
                    // wire.hitStrokeWidth(10);
                });
                stage.draw();
            }
        });
        stage.container().addEventListener("keyup", (e) => {
            e.preventDefault();
            let wireLayer = stage.findOne('#wireLayer');
            if (e.code == "ControlLeft") {
                let wireArray = wireLayer.find(".isConnection");
                wireArray.forEach(wire => {
                    // wire.hitStrokeWidth(0);
                    wire.strokeWidth(2);
                });
                // layer.toggleHitCanvas();
                stage.draw();
                ctrlIsPressed = false;
            }
        })
    }
}
export function deleteProgramNode(e, layer, stage) {
    let node = e.target.getParent();
    for (let each of node.customClass.execInPins) {
        let len = each.wire.length;
        for (let i = 0; i < len; i++) {
            if (each.wire[0]) { deleteWire(each.wire[0]); }
        }
    }
    for (let each of node.customClass.execOutPins) {
        if (each.wire) {
            deleteWire(each.wire);
            each.wire = null;
        }
    }
    for (let each of node.customClass.inputPins) {
        if (each.wire) {
            deleteWire(each.wire);
            each.wire = null;
        }
    }
    for (let each of node.customClass.outputPins) {
        let len = each.wire.length;
        for (let i = 0; i < len; i++) {
            if (each.wire[0]) { deleteWire(each.wire[0]); }
        }
    }
    // console.log(e.target.getParent());
    e.target.getParent().destroy();
    let wireLayer = stage.findOne('#wireLayer');
    stage.draw();

}

export function deleteWire(aWire) {
    let lineClone = aWire;
    // console.log(lineClone);
    if (lineClone.attrs.src.attrs.pinType == 'exec-out') {
        let tmpA = lineClone.attrs.src.attrs.helper.split('-');
        lineClone.attrs.src.getParent().customClass.execOutPins[parseInt(tmpA[tmpA.length - 1])].wire = null;
        lineClone.attrs.src.fire(
            'wireremoved',
            {
                type: 'wireremoved',
                target: lineClone.attrs.src,
                isPinEmpty: true,
            }
        );
    }
    if (lineClone.attrs.src.attrs.pinType == 'outp') {
        let tmpA = lineClone.attrs.src.attrs.helper.split('-');
        lineClone.attrs.src.getParent().customClass.outputPins[parseInt(tmpA[tmpA.length - 1])].wire.forEach((value, index) => {
            if (value == lineClone) {
                lineClone.attrs.src.getParent().customClass.outputPins[parseInt(tmpA[tmpA.length - 1])].wire.splice(index, 1);
            }
        });
        lineClone.attrs.src.fire(
            'wireremoved',
            {
                type: 'wireremoved',
                target: lineClone.attrs.src,
                isPinEmpty: (lineClone.attrs.src.getParent().customClass.outputPins[parseInt(tmpA[tmpA.length - 1])].wire.length == 0),
            }
        );

    }
    if (lineClone.attrs.dest.attrs.pinType == 'exec-in') {
        lineClone.attrs.dest.getParent().customClass.execInPins[0].wire.forEach((value, index) => {
            if (value == lineClone) {
                // console.log("req", value);
                lineClone.attrs.dest.getParent().customClass.execInPins[0].wire.splice(index, 1);
            }
        });
        lineClone.attrs.dest.fire(
            'wireremoved',
            {
                type: 'wireremoved',
                target: lineClone.attrs.dest,
                isPinEmpty: (lineClone.attrs.dest.getParent().customClass.execInPins[0].wire.length == 0),
            }
        );
    }
    if (lineClone.attrs.dest.attrs.pinType == 'inp') {
        let tmpA = lineClone.attrs.dest.attrs.helper.split('-');
        lineClone.attrs.dest.getParent().customClass.inputPins[parseInt(tmpA[tmpA.length - 1])].wire = null;
        lineClone.attrs.dest.fire(
            'wireremoved',
            {
                type: 'wireremoved',
                target: lineClone.attrs.dest,
                isPinEmpty: true,
            }
        );
    }
    lineClone.destroy();
    
}
export function deleteHalfWire(lineClone, originPreOccupied) {

    lineClone.attrs.wireOrigin.fire(
        'wireremoved',
        {
            type: 'wireremoved',
            target: lineClone.attrs.wireOrigin,
            isPinEmpty: !originPreOccupied,
        }
    );
    lineClone.destroy();
}

