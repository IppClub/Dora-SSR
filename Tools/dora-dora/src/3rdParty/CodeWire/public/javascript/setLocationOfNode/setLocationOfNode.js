export var setLocationOfNode = {
    place: function(node, location , stage){
        node.x((location.x - stage.x()) / stage.scaleX());
        node.y((location.y - stage.y()) / stage.scaleY());
    }
}