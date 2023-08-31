
export var InputBox = class{
    constructor(stage, layer, type, grp, position, colorMap, inputPin, iplabel, inputPinsPlaced, defValueContainer, defValueContainerForSave)
    {
        let rect = new Konva.Rect({
            width: (type == 'Boolean') ? 50 : 50,
            height: 14,
            stroke: colorMap['Text'],
            strokeWidth: 1,
        });
        this.focused = false;
        let text = new Konva.Text({
            text: '',
            fontSize: 11,
            fontFamily: 'Verdana',
            fill: colorMap['Text'],
            width: (type == 'Boolean') ? 50 : 50,
            height: 12,
            padding: 2,
        });
        this.inputBox = new Konva.Group();
        this.inputBox.add(rect);
        this.inputBox.add(text);
        this.inputBox.position(position);
        
        let htmlInputBox = null;
        let defaultValue = null;
        if(type == "Number")
        {
            defaultValue = defValueContainer.defValue;
            htmlInputBox = document.getElementById("number-ip");
        }
        else if(type == "Boolean")
        {
            defaultValue = defValueContainer.defValue;
            htmlInputBox = document.getElementById("bool-ip");
        }
        else if(type == "Array")
        {
            defaultValue = defValueContainer.defValue;
            htmlInputBox = document.getElementById("array-ip");
        }
        else 
        {
            // let x = 3;
            if(type == "String")
            {defaultValue = `${defValueContainer.defValue}`;}
            else
            {defaultValue = `${defValueContainer.defValue}`;}
            htmlInputBox = document.getElementById("string-ip");            
            // getComputedStyle(html)
        }
        text.text(defaultValue);
        layer.draw();
        this.inputBox.on("click", () => {
            this.focused = true;
            text.visible(false);
            layer.draw();
            htmlInputBox.value = text.text();
            let stageContainerBorderLeftWidth = parseInt(getComputedStyle(stage.getContainer()).borderLeftWidth);
            let stageContainerBorderTopWidth = parseInt(getComputedStyle(stage.getContainer()).borderTopWidth);
            htmlInputBox.style.left = stage.getContainer().getBoundingClientRect().x + stageContainerBorderLeftWidth + this.inputBox.getAbsolutePosition().x + "px";
            htmlInputBox.style.top = stage.getContainer().getBoundingClientRect().y + stageContainerBorderTopWidth + this.inputBox.getAbsolutePosition().y + "px";
            htmlInputBox.style.transform = `scale(${stage.scaleX()})`;
            htmlInputBox.style.display = "inline-block";
            htmlInputBox.focus();
        });
        stage.on("wheel", () => {
            htmlInputBox.blur();
        });
        htmlInputBox.addEventListener("blur", () => {
            text.visible(true);
            layer.draw();
            htmlInputBox.value = '';
            htmlInputBox.style.display = "none";
            this.focused = false;
        });
        htmlInputBox.addEventListener("input", () => {
            if(this.focused)
            {
                text.text(htmlInputBox.value);
                defValueContainerForSave.defValue = htmlInputBox.value;
            }
        });
        inputPin.on("wireconnected", (e) => {
            this.inputBox.visible(false);
            iplabel.position({ x: 28, y: 44 + 39 * inputPinsPlaced - 4 });    
        });
        inputPin.on("wireremoved", (e) => {
            if(e.isPinEmpty)
            {
                this.inputBox.visible(true);
                iplabel.position({ x: 28, y: 44 + 39 * inputPinsPlaced - 14 });    
            }
        });

        this.textBox = text;
        this.inputBox.on("mouseenter", (e) => {
            document.body.style.cursor = "text";
        });
        this.inputBox.on("mouseleave", (e) => {
            document.body.style.cursor = "default";
        });
        grp.add(this.inputBox);
    }
}