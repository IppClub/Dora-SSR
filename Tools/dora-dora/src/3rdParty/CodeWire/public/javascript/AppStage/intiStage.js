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
        });

        // Touch support: pinch-to-zoom and single-finger pan
        let lastDist = 0;
        let lastCenter = null;
        let isPanning = false;
        let panStart = null;

        function getTouchDist(t1, t2) {
            return Math.sqrt(Math.pow(t2.clientX - t1.clientX, 2) + Math.pow(t2.clientY - t1.clientY, 2));
        }
        function getTouchCenter(t1, t2) {
            return {
                x: (t1.clientX + t2.clientX) / 2,
                y: (t1.clientY + t2.clientY) / 2,
            };
        }
        function getStageRelativePos(clientX, clientY) {
            let rect = stage.container().getBoundingClientRect();
            return {
                x: clientX - rect.left,
                y: clientY - rect.top,
            };
        }

        stage.container().addEventListener('touchstart', (e) => {
            if (e.touches.length === 2) {
                e.preventDefault();
                isPanning = false;
                lastDist = getTouchDist(e.touches[0], e.touches[1]);
                lastCenter = getTouchCenter(e.touches[0], e.touches[1]);
            } else if (e.touches.length === 1) {
                // Only pan when touching the background (stage), not a node/pin
                let pos = getStageRelativePos(e.touches[0].clientX, e.touches[0].clientY);
                let shape = stage.getIntersection(pos);
                if (!shape || shape === stage) {
                    isPanning = true;
                    panStart = {
                        x: e.touches[0].clientX - stage.x(),
                        y: e.touches[0].clientY - stage.y(),
                    };
                }
            }
        }, { passive: false });

        stage.container().addEventListener('touchmove', (e) => {
            if (e.touches.length === 2) {
                e.preventDefault();
                let newDist = getTouchDist(e.touches[0], e.touches[1]);
                let newCenter = getTouchCenter(e.touches[0], e.touches[1]);
                let oldScale = stage.scaleX();
                let centerPos = getStageRelativePos(newCenter.x, newCenter.y);
                let pointTo = {
                    x: (centerPos.x - stage.x()) / oldScale,
                    y: (centerPos.y - stage.y()) / oldScale,
                };
                let checkScale = oldScale * (newDist / lastDist);
                let newScale = oldScale;
                if (checkScale > 0.175 && checkScale < 1.6) {
                    newScale = checkScale;
                }
                stage.scale({ x: newScale, y: newScale });
                let newPos = {
                    x: centerPos.x - pointTo.x * newScale,
                    y: centerPos.y - pointTo.y * newScale,
                };
                stage.position(newPos);
                stage.container().style.backgroundSize = `${stage.scaleX() * 10}rem ${stage.scaleY() * 10}rem`;
                stage.container().style.backgroundPosition = `${stage.position().x}px ${stage.position().y}px`;
                stage.batchDraw();
                lastDist = newDist;
                lastCenter = newCenter;
            } else if (e.touches.length === 1 && isPanning) {
                e.preventDefault();
                let newPos = {
                    x: e.touches[0].clientX - panStart.x,
                    y: e.touches[0].clientY - panStart.y,
                };
                stage.position(newPos);
                stage.container().style.backgroundPosition = `${stage.position().x}px ${stage.position().y}px`;
                stage.batchDraw();
            }
        }, { passive: false });

        stage.container().addEventListener('touchend', (e) => {
            lastDist = 0;
            lastCenter = null;
            if (e.touches.length === 0) {
                isPanning = false;
                panStart = null;
            }
        });

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