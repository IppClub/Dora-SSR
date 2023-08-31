import { deleteWire, deleteHalfWire } from '../Delete/delete.js'
import { colorMap } from '../ColorMap/colorMap.js'
let placeLocation = function (location, stage) {
    return {
        x: (location.x - stage.x()) / stage.scaleX(),
        y: (location.y - stage.y()) / stage.scaleY()
    };
}
export var Wiring = {
    enableWiring: function (stage, layer) {
        let currentPinType = null;
        let currentPinDataType = null;
        function isValidMatch(pinType, targetPinDataType) {
            if ((currentPinType == 'exec-out' && pinType == 'exec-in') || (currentPinType == 'exec-in' && pinType == 'exec-out'))
                return true;
            if ((currentPinType == 'outp' && pinType == 'inp') || (currentPinType == 'inp' && pinType == 'outp')) {
                if (currentPinDataType == targetPinDataType || targetPinDataType == 'Data' || currentPinDataType == 'Data')
                    return true;
            }
            return false;
        }
        let isWiring = false;
        let src = null;
        let dest = null;
        let wireLayer = new Konva.Layer({
            id: 'wireLayer',
        });

        let drawWire = null;
        let potentialTarget = null;
        let dir = 0;
        let wireColor = null;
        let originPreOccupied = null;
        stage.add(wireLayer);
        wireLayer.zIndex(0);
        stage.on('mousedown', (e) => {
            if (e.target.name() == 'pin' && e.evt.button == 0) {
                src = e.target;
                currentPinType = e.target.attrs.pinType;
                currentPinDataType = e.target.attrs.pinDataType;
                dir = (currentPinType == 'exec-out' || currentPinType == 'outp') ? 1 : -1;
                src.getParent().draggable(false);
                isWiring = true;
                let srcLoc = placeLocation(src.getAbsolutePosition(), stage);
                let destLoc = placeLocation(stage.getPointerPosition(), stage);
                wireColor = e.target.attrs.stroke;
                drawWire = new Konva.Line({
                    strokeWidth: 2,
                    stroke: wireColor,
                    hitStrokeWidth: 0,
                    src: null,
                    dest: null,
                    wireOrigin: src,
                    name: "isConnection",
                    bezier: true,
                });
                originPreOccupied = !(src.attrs.fill == '' || src.attrs.fill == 'transparent');
                src.fire('wiringstart',
                    {
                        type: 'wiringstart',
                        target: src,
                    });
                setWirePoints(destLoc, srcLoc, dir, drawWire);
                wireLayer.add(drawWire);
                wireLayer.draw();
            }
        });
        stage.on('mouseup', (e) => {
            handleMouseUp(e, true);
        });
        document.addEventListener("mouseup", (e) => {
            handleMouseUp(e, false);
        });
        // stage.on('mouseover', (e) => {
        //     if (e.target && src && e.target.name() == 'pin' && src != e.target && src.getParent() !== e.target.getParent() && isValidMatch(e.target.attrs.pinType, e.target.attrs.pinDataType)) {
        //         potentialTarget = e.target;
        //         let srcLoc = placeLocation(src.getAbsolutePosition(), stage);
        //         let destLoc = placeLocation(stage.getPointerPosition(), stage);
        //         setWirePoints(destLoc, srcLoc, dir, drawWire);
        //         wireLayer.draw();
        //     }
        //     else potentialTarget = null;
        // });
        stage.on('mousemove', (e) => {
            if (isWiring) {
                let srcLoc = placeLocation(src.getAbsolutePosition(), stage);
                let destLoc = placeLocation(stage.getPointerPosition(), stage);
                setWirePoints(destLoc, srcLoc, dir, drawWire);
                wireLayer.draw();
            }
        })


        function handleMouseUp(e, isStageEvent) {
            if (isStageEvent) {
                if (src && src.name() == 'pin' && e.evt.button == 0) {
                    deleteHalfWire(drawWire, originPreOccupied);
                    if (e.target && src && e.target.name() == 'pin' && src != e.target && src.getParent() !== e.target.getParent() && isValidMatch(e.target.attrs.pinType, e.target.attrs.pinDataType)) {
                        dest = e.target;
                        addConnectionWire(dest, src, stage, dir, wireLayer);
                    }
                    src.getParent().draggable(true);
                    src = null;
                    originPreOccupied = false;
                    dest = null;
                    isWiring = false;
                    dir = 0;
                    drawWire = null;
                    currentPinType = null;
                    currentPinDataType = null;
                    wireColor = null;
                    wireLayer.draw();
                    layer.draw();
                }
            }
            else {
                if (src) {
                    deleteHalfWire(drawWire, originPreOccupied);
                    src.getParent().draggable(true);
                    src = null;
                    originPreOccupied = false;
                    dest = null;
                    isWiring = false;
                    dir = 0;
                    drawWire = null;
                    currentPinType = null;
                    currentPinDataType = null;
                    wireColor = null;
                    wireLayer.draw();
                    layer.draw();
                }
            }
        }
    }

}

export function addConnectionWire(dest, src, stage, dir, wireLayer) {
    let connectionWire = new Konva.Line({
        strokeWidth: 2,
        stroke: dest.attrs.stroke,
        hitStrokeWidth: 15,
        src: null,
        dest: null,
        name: "isConnection",
        bezier: true,
    });
    connectionWire.on('mouseover', (e) => {
        connectionWire.strokeWidth(5);
        wireLayer.draw();
    });
    connectionWire.on('mouseleave', (e) => {
        connectionWire.strokeWidth(2);
        wireLayer.draw();
    })
    let srcLoc = placeLocation(src.getAbsolutePosition(), stage);
    let destLoc = placeLocation(dest.getAbsolutePosition(), stage);
    connectionWire.setAttr('src', src);
    connectionWire.setAttr('dest', dest);
    swapDestAndSrcIfOutOfOrder(connectionWire);
    setWirePoints(destLoc, srcLoc, dir, connectionWire);
    wireLayer.add(connectionWire);
    connectionWire.zIndex(0);
    if (connectionWire.attrs.src.attrs.pinType == 'exec-out') {
        let tmpA = connectionWire.attrs.src.attrs.helper.split('-');
        removePreviousWireIfExistOfExecOutType(connectionWire, tmpA);
        connectionWire.attrs.src.getParent().customClass.execOutPins[parseInt(tmpA[tmpA.length - 1])].wire = connectionWire;
    }
    if (connectionWire.attrs.src.attrs.pinType == 'outp') {
        let tmpA = connectionWire.attrs.src.attrs.helper.split('-');
        connectionWire.attrs.src.getParent().customClass.outputPins[parseInt(tmpA[tmpA.length - 1])].wire.push(connectionWire);
    }
    if (connectionWire.attrs.dest.attrs.pinType == 'exec-in') {
        connectionWire.attrs.dest.getParent().customClass.execInPins[0].wire.push(connectionWire);
    }
    if (connectionWire.attrs.dest.attrs.pinType == 'inp') {
        let tmpA = connectionWire.attrs.dest.attrs.helper.split('-');
        removePreviousWireIfExistOfOutputType(connectionWire, tmpA);
        connectionWire.attrs.dest.getParent().customClass.inputPins[parseInt(tmpA[tmpA.length - 1])].wire = connectionWire;
    }
    wireColorCorrection(connectionWire);
    let dragLayer = stage.findOne('#dragLayer');
    connectionWire.attrs.src.getParent().on('dragmove', (e) => {
        let sLoc = placeLocation(connectionWire.attrs.src.getAbsolutePosition(), stage);
        let dLoc = placeLocation(connectionWire.attrs.dest.getAbsolutePosition(), stage);
        setWirePoints(dLoc, sLoc, 1, connectionWire);
        dragLayer.draw();
    });
    connectionWire.attrs.dest.getParent().on('dragmove', (e) => {
        let sLoc = placeLocation(connectionWire.attrs.src.getAbsolutePosition(), stage);
        let dLoc = placeLocation(connectionWire.attrs.dest.getAbsolutePosition(), stage);
        setWirePoints(dLoc, sLoc, 1, connectionWire);
        dragLayer.draw();
    });
    connectionWire.attrs.dest.fire(
        'wireconnected',
        {
            type: 'wireconnected',
            target: connectionWire.attrs.dest,
        }
    );
    connectionWire.attrs.src.fire(
        'wireconnected',
        {
            type: 'wireconnected',
            target: connectionWire.attrs.src,
        }
    );
    wireLayer.draw();
}

function setWirePoints(destLoc, srcLoc, dir, wire) {
    let len = (destLoc.x - srcLoc.x) / 3;
    let diffY = Math.abs(destLoc.y - srcLoc.y);
    let diffX = Math.abs(destLoc.x - srcLoc.x);
    len = dir * (Math.abs(len) + diffY/4);
    let mid1 = {
        x: srcLoc.x + len,
        y: srcLoc.y
    };
    let mid2 = {
        x: destLoc.x - len,
        y: destLoc.y
    };
    wire.points([srcLoc.x, srcLoc.y, mid1.x, mid1.y, mid2.x, mid2.y, destLoc.x, destLoc.y]);
}

function swapDestAndSrcIfOutOfOrder(connectionWire) {
    if (connectionWire.attrs.dest.attrs.pinType == 'exec-out' || connectionWire.attrs.dest.attrs.pinType == 'outp') {
        let tmp = connectionWire.attrs.src;
        connectionWire.attrs.src = connectionWire.attrs.dest;
        connectionWire.attrs.dest = tmp;
    }
}

function wireColorCorrection(connectionWire) {
    let srcColor = connectionWire.attrs.src.attrs.stroke;
    let destColor = connectionWire.attrs.dest.attrs.stroke;
    if (srcColor != destColor) {
        if (srcColor != colorMap['Data']) {
            connectionWire.attrs.stroke = srcColor;
        }
        else {
            connectionWire.attrs.stroke = destColor;
        }
    }
}

function removePreviousWireIfExistOfOutputType(connectionWire, tmpA) {
    if (connectionWire.attrs.dest.getParent().customClass.inputPins[parseInt(tmpA[tmpA.length - 1])].wire) {
        let wireToBeRemoved = connectionWire.attrs.dest.getParent().customClass.inputPins[parseInt(tmpA[tmpA.length - 1])].wire;
        deleteWire(wireToBeRemoved); //from Delete.js
    }
}

function removePreviousWireIfExistOfExecOutType(connectionWire, tmpA) {
    if (connectionWire.attrs.src.getParent().customClass.execOutPins[parseInt(tmpA[tmpA.length - 1])].wire != null) {
        let wireToBeRemoved = connectionWire.attrs.src.getParent().customClass.execOutPins[parseInt(tmpA[tmpA.length - 1])].wire;
        deleteWire(wireToBeRemoved); //from Delete.js
    }
}
