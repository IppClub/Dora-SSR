Dorothy!
ButtonView = require "UI.View.Control.Basic.Button"

-- [signals]
-- "Tapped",(button)->
-- [params]
-- text, x, y, width, height, fontName=18, fontSize=NotoSansHans-Regular
Class ButtonView,
	__init:(args)=>
		@_text = @label.text if @label

	text:property => @_text,
		(value)=>
			@_text = value
			@label.text = value if @label
