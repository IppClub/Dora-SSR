export var AppStage = {
    zoomScale: 1.05,
    shapeIsDragging: false,
    shapeTouchingDirection: [],    // can be array of 'top', 'bottom', 'left', 'right'
    getStage: function (width, height, container_name) {
        let stage = new Konva.Stage({
            container: container_name,
            width: width,
            height: height,
            draggable: false,
        });
        AppStage.zoomScale = 1.05;
        stage.on('wheel', (e) => {
            e.evt.preventDefault();
            var oldScale = stage.scaleX();
            var pointer = stage.getPointerPosition();

            var mousePointTo = {
                x: (pointer.x - stage.x()) / oldScale,
                y: (pointer.y - stage.y()) / oldScale,
            };
            var newScale = oldScale;
            var checkScale = e.evt.deltaY > 0 ? oldScale / AppStage.zoomScale : oldScale * AppStage.zoomScale;
            if (checkScale > 0.175 && checkScale < 1.6) {
                newScale = checkScale;
            }
            // console.log(stage.x() + pointer.x + " " + stage.y() + pointer.y)
            stage.scale({ x: newScale, y: newScale });

            var newPos = {
                x: pointer.x - mousePointTo.x * newScale,
                y: pointer.y - mousePointTo.y * newScale,
            };
            stage.container().style.backgroundSize = `${stage.scaleX() * 10}rem ${stage.scaleY() * 10}rem`;
            stage.position(newPos);
            stage.batchDraw();
            stage.container().style.backgroundPosition = `${stage.position().x}px ${stage.position().y}px`;
            // console.log(stage.scaleX());
        });
        stage.container().tabIndex = 1;
        stage.container().focus();

        stage.on('mousedown', function (e) {
            if (e.target === stage && (e.evt.button == 0 || e.evt.button == 1)) {
                stage.draggable(true);
            }
        });
        stage.on('mouseup', function (e) {
            if (e.evt.button == 0 || e.evt.button == 1) {
                stage.draggable(false);
            }
        });
        stage.on('dragmove', (e) => {
            if (e.target == stage) {
                stage.container().style.backgroundPosition = `${stage.position().x}px ${stage.position().y}px`;
            }
        })
        window.addEventListener('resize', () => {
            let container = document.querySelector('#container');
            // console.log("Resized");
            let containerWidth = container.offsetWidth;
            let scale = containerWidth / stage.width();
            stage.width(container.offsetWidth);
            stage.height(container.offsetHeight);
            stage.draw();
        });
        return stage;
    }
}