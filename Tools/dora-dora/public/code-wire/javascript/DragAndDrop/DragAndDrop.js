export var DragAndDrop = {
    // events such as dragleave, dragenter, dragover, drop added
    // using dragstart, dragend, dragmove
    DragAndDrop: function (stage, layer) {
        let tempLayer = new Konva.Layer();
        stage.add(tempLayer);
        stage.on('dragstart', function (e) {
            if(e.target !== stage)
                e.target.moveTo(tempLayer);
            layer.draw();
        });

        var previousShape = undefined;
        stage.on('dragmove', function (evt) {
            var pos = stage.getPointerPosition();
            var shape = layer.getIntersection(pos);
            if (previousShape && shape) {
                if (previousShape !== shape) {
                    // leave from old targer
                    previousShape.fire(
                        'dragleave',
                        {
                            type: 'dragleave',
                            target: previousShape,
                            evt: evt.evt,
                            above: evt.target
                        },
                        true
                    );

                    // enter new targer
                    shape.fire(
                        'dragenter',
                        {
                            type: 'dragenter',
                            target: shape,
                            evt: evt.evt,
                            above: evt.target
                        },
                        true
                    );
                    previousShape = shape;
                } else {
                    previousShape.fire(
                        'dragover',
                        {
                            type: 'dragover',
                            target: previousShape,
                            evt: evt.evt,
                            above: evt.target
                        },
                        true
                    );
                }
            } else if (!previousShape && shape) {
                previousShape = shape;
                shape.fire(
                    'dragenter',
                    {
                        type: 'dragenter',
                        target: shape,
                        evt: evt.evt,
                        above: evt.target
                    },
                    true
                );
            } else if (previousShape && !shape) {
                previousShape.fire(
                    'dragleave',
                    {
                        type: 'dragleave',
                        target: previousShape,
                        evt: evt.evt,
                        above: evt.target
                    },
                    true
                );
                previousShape = undefined;
            }
        });
        stage.on('dragend', function (e) {
            var pos = stage.getPointerPosition();
            var shape = layer.getIntersection(pos);
            // console.log(e);
            if (shape) {
                previousShape.fire(
                    'drop',
                    {
                        type: 'drop',
                        target: previousShape,
                        evt: e.evt,
                        above: e.target
                    },
                    true
                );
            }
            previousShape = undefined;
            if(e.target !== stage)
                e.target.moveTo(layer);
            layer.draw();
            tempLayer.draw();
        });
    }
}