import { setLocationOfNode } from '../setLocationOfNode/setLocationOfNode.js'
export var SelectionBox = {
    setSelectionBox: function (layer, stage) {
        this.selectionRectangle = new Konva.Rect({
            fill: 'rgba(0,0,255,0.2)',
            visible: false
        });
        layer.add(this.selectionRectangle);
        var x1, y1, x2, y2;
        this.tr = new Konva.Transformer();
        layer.add(this.tr);
        stage.on('mousedown', (e) => {
            // do nothing if we mousedown on any shape
            if (e.target !== stage) {
                return;
            }
            x1 = (stage.getPointerPosition().x - stage.x()) / stage.scaleX();
            y1 = (stage.getPointerPosition().y - stage.y()) / stage.scaleY();
            y2 = (stage.getPointerPosition().x - stage.x()) / stage.scaleX();
            x2 = (stage.getPointerPosition().y - stage.y()) / stage.scaleY();

            this.selectionRectangle.visible(true);
            this.selectionRectangle.width(0);
            this.selectionRectangle.height(0);
            // setLocationOfNode.place(this.selectionRectangle, { x: x1, y: y1 }, stage);
            layer.draw();
        });
        stage.on('mousemove', () => {
            // no nothing if we didn't start selection
            if (!this.selectionRectangle.visible()) {
                return;
            }
            x2 = (stage.getPointerPosition().x - stage.x()) / stage.scaleX();
            y2 = (stage.getPointerPosition().y - stage.y()) / stage.scaleY();

            this.selectionRectangle.setAttrs({
                x: Math.min(x1, x2),
                y: Math.min(y1, y2),
                width: Math.abs(x2 - x1),
                height: Math.abs(y2 - y1),
            });
            layer.batchDraw();
        });
        stage.on('mouseup', () => {
            // no nothing if we didn't start selection
            if (!this.selectionRectangle.visible()) {
              return;
            }
            // update visibility in timeout, so we can check it in click event
            setTimeout(() => {
              this.selectionRectangle.visible(false);
              layer.batchDraw();
            });
    
            var shapes = stage.find((e) => {
                if(e.attrs.name == "a_shape" || e.attrs.name == "a_node")
                    return true;
                else return false;
            }).toArray();
            var box = this.selectionRectangle.getClientRect();
            var selected = shapes.filter((shape) =>
              Konva.Util.haveIntersection(box, shape.getClientRect())
            );
            for(let e of selected){
                // console.log(e);     
                e.attrs.stroke = 'black';    
            }
            this.tr.nodes(selected);
            layer.batchDraw();
          });
        //   stage.on('mousedown', (e) => {
        //       if(console.log(e.target));
        //   })
        //   setInterval(() => {console.log(this.tr)}, 5000);

    }
}