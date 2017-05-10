Dorothy!
import run_with_scope from require "moon"

Class Node,
	__init:(isRoot=false)=>
		@_isRoot = isRoot
		if isRoot
			viewSize = View.size
			@size = viewSize
			@_viewSize = viewSize
			@position = Vec2(0.5,0.5) * viewSize
			@gslot "AppSizeChanged", ->
				viewSize = View.size
				if @_viewSize ~= viewSize
					@_viewSize = viewSize
					@size = viewSize
					@position = Vec2(0.5,0.5) * viewSize
					@eachChild (child)->
						child\emit "AlignLayout", viewSize.width, viewSize.height
		else
			@hAlign = "Center"
			@vAlign = "Center"
			@alignOffset = Vec2.zero
			@alignWidth = nil
			@alignHeight = nil
			@slot "AlignLayout", (w, h)->
				env = :w,:h
				oldSize = @size
				if @alignWidth
					widthFunc = loadstring "return #{@alignWidth}"
					@width = run_with_scope widthFunc, env
				if @alignHeight
					heightFunc = loadstring "return #{@alignHeight}"
					@height = run_with_scope heightFunc, env
				@x = switch @hAlign
					when "Left" then @width/2 + @alignOffset.x
					when "Center" then w/2 + @alignOffset.x
					when "Right" then w - @width/2 - @alignOffset.x
				@y = switch @vAlign
					when "Bottom" then @height/2 + @alignOffset.y
					when "Center" then h/2 + @alignOffset.y
					when "Top" then h - @height/2 - @alignOffset.y
				newSize = @size
				if oldSize ~= newSize
					@eachChild (child)->
						child\emit "AlignLayout", newSize.width, newSize.height

	alignLayout:=>
		if @_isRoot
			viewSize = View.size
			@eachChild (child)->
				child\emit "AlignLayout", viewSize.width, viewSize.height
		else
			size = @size
			@eachChild (child)->
				child\emit "AlignLayout", size.width, size.height
