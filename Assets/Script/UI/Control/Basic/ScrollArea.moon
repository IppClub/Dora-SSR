Dorothy!
import "UI.View.Control.Basic.ScrollArea"
import "UI.View.Shape.SolidRect"

-- [signals]
-- "ScrollTouchBegan",->
-- "ScrollTouchEnded",->
-- "ScrollStart",->
-- "ScrollEnd",->
-- "Scrolled",(delta)->
-- [params]
-- x,y,width,height,
-- paddingX,paddingY,
-- viewWidth,viewHeight
export default Class ScrollArea,
	__init: (args)=>
		{:width,:height} = args
		screenSize = (Vec2 View.size).length
		viewWidth = math.max args.viewWidth or width,width
		viewHeight = math.max args.viewHeight or height,height
		moveY = viewHeight - height
		moveX = viewWidth - width
		deltaX,deltaY = 0,0
		paddingX = args.paddingX or 200
		paddingY = args.paddingY or 200
		posX,posY = 0,0
		timePassed = 0
		S = Vec2.zero
		V = Vec2.zero
		deltaMoveLength = 0
		@contentSize = Size width,height
		@setupMenuScroll @view

		@view\slot "Tapped",->
			enabled = @view.touchEnabled
			@view.touchEnabled = false
			@view\schedule once ->
				sleep!
				@view.touchEnabled = enabled

		updateReset = (deltaTime)->
			local x,y
			timePassed += deltaTime
			t = math.min timePassed*4,1
			with Ease
				if posX < -moveX
					tmp = deltaX
					deltaX = posX - (moveX+posX) * \func .OutQuad,t
					x = deltaX - tmp
				elseif posX > 0
					tmp = deltaX
					deltaX = posX - posX * \func .OutQuad,t
					x = deltaX - tmp
				if posY < 0
					tmp = deltaY
					deltaY = posY - posY * \func .OutQuad,t
					y = deltaY - tmp
				elseif posY > moveY
					tmp = deltaY
					deltaY = posY + (moveY-posY) * \func .OutQuad,t
					y = deltaY - tmp
			x or= 0
			y or= 0
			@emit "Scrolled",Vec2(x,y)
			if t == 1
				@unschedule!
				@emit "ScrollEnd"
			false

		isReseting = ->
			not @dragging and (deltaX > 0 or deltaX < -moveX or deltaY > moveY or deltaY < 0)

		startReset = ->
			posX = deltaX
			posY = deltaY
			timePassed = 0
			@schedule updateReset

		setOffset = (delta, touching)->
			dPosX = delta.x
			dPosY = delta.y
			newPosX = deltaX + dPosX
			newPosY = deltaY + dPosY

			newPosX = math.min newPosX, paddingX
			newPosX = math.max newPosX, -moveX-paddingX
			newPosY = math.max newPosY, -paddingY
			newPosY = math.min newPosY, moveY+paddingY
			dPosX = newPosX - deltaX
			dPosY = newPosY - deltaY

			if touching
				lenY = if newPosY < 0
					(0-newPosY)/paddingY
				elseif newPosY > moveY
					(newPosY-moveY)/paddingY
				else 0
				lenX = if newPosX > 0
					(newPosX-0)/paddingX
				elseif newPosX < -moveX
					(-moveX-newPosX)/paddingX
				else 0

				if lenY > 0
					v = lenY*3
					dPosY = dPosY / math.max v*v,1
				if lenX > 0
					v = lenX*3
					dPosX = dPosX / math.max v*v,1

			deltaX += dPosX
			deltaY += dPosY

			@emit "Scrolled",Vec2(dPosX,dPosY)

			startReset! if not touching and
			(newPosY < -paddingY*0.5 or
			newPosY > moveY+paddingY*0.5 or
			newPosX > paddingX*0.5 or
			newPosX < -moveX-paddingX*0.5)

		accel = screenSize*2
		updateSpeed = (dt)->
			V = S / dt
			if V.length > accel
				V\normalize!
				V = V * accel
			S = Vec2.zero
			false

		updatePos = (dt)->
			dir = Vec2 V.x,V.y
			dir\normalize!
			A = dir * -accel
			incX = V.x > 0
			incY = V.y > 0
			V = V + A * dt * 0.5
			decX = V.x < 0
			decY = V.y < 0
			if incX == decX and incY == decY
				if isReseting!
					startReset!
				else
					@unschedule!
					@emit "ScrollEnd"
			else
				dS = V * dt
				setOffset dS,false
			false

		@slot "TapFilter",(touch)->
			if touch.id ~= 0 or not Rect(-width/2,-height/2,width,height)\containsPoint touch.location
				touch.enabled = false

		@slot "TapBegan",(touch)->
			deltaMoveLength = 0
			S = Vec2.zero
			V = Vec2.zero
			@schedule updateSpeed
			@emit "ScrollTouchBegan"

		@slot "TapEnded",->
			@dragging = false
			if isReseting!
				startReset!
			elseif V ~= Vec2.zero and deltaMoveLength > 10
				@schedule updatePos
			else
				@emit "ScrollEnd"
			@emit "ScrollTouchEnded"

		@slot "TapMoved",(touch)->
			lastMoveLength = deltaMoveLength
			S = touch.delta
			deltaMoveLength += S.length
			if deltaMoveLength > 10
				setOffset S,true
				if lastMoveLength <= 10
					@dragging = true
					@emit "ScrollStart"

		switch App.platform
			when "macOS", "Windows"
				getScrollBarX = ->
					return @barX if @barX
					barX = SolidRect width:50,height:10,color:0x6600ffff
					barBgX = SolidRect width:@area.width,height:10,color:0x2200ffff
					barBgX\addChild barX
					@area\addChild barBgX
					@barX = barX
					@barBgX = barBgX
					barX
				getScrollBarY = ->
					return @barY if @barY
					barY = SolidRect width:10,height:50,color:0x6600ffff
					barBgY = SolidRect width:10,height:@area.height,color:0x2200ffff
					barBgY.x = @area.width-10
					barBgY\addChild barY
					@area\addChild barBgY
					@barY = barY
					@barBgY = barBgY
					barY
				fadeSeq = Sequence(
					Show!
					Opacity 0,1,1
					Delay 1
					Opacity 0.4,1,0,Ease.OutQuad
					Hide!
				)
				fadeBarX = Action fadeSeq
				fadeBarY = Action fadeSeq
				@slot "Scrolled",(delta)->
					if delta.x ~= 0
						barX = getScrollBarX!
						barX.x = (@area.width-50) * math.max(math.min((-@offset.x/(viewWidth-width)),1),0)
						@barBgX\perform fadeBarX
					if delta.y ~= 0
						barY = getScrollBarY!
						barY.y = (@area.height-50) * math.max(math.min((1-@offset.y/(viewHeight-height)),1),0)
						@barBgY\perform fadeBarY

				@area\slot "MouseWheel",(delta)->
					px,py = paddingX,paddingY
					paddingX,paddingY = 0,0
					setOffset delta*-20
					paddingX,paddingY = px,py

		@slot "Enter",-> @emit "Scrolled", Vec2.zero

		@scroll = (delta)=>
			if delta
				deltaX += delta.x
				deltaY += delta.y
				@emit "Scrolled",Vec2(delta.x,delta.y)
			startReset! if isReseting!

		@scrollTo = (offset)=>
			delta = offset - Vec2 deltaX,deltaY
			deltaX = offset.x
			deltaY = offset.y
			@emit "Scrolled",delta

		@updatePadding = (padX,padY)=>
			paddingX = padX
			paddingY = padY
			@scroll Vec2.zero

		@getPadding = -> Vec2 paddingX,paddingY
		@getViewSize = -> Size viewWidth,viewHeight
		@getTotalDelta = -> Vec2 deltaX,deltaY
		@resetSize = (w,h,viewW,viewH)=>
			offset = @offset
			@offset = Vec2.zero
			width,height = w,h
			viewWidth = math.max viewW or w,w
			viewHeight = math.max viewH or h,h
			moveY = viewHeight - height
			moveX = viewWidth - width
			size = Size w,h
			@contentSize = size
			@area.size = size
			@view.size = size
			@area.stencil = SolidRect width:w,height:h
			@offset = offset
			if @barBgX
				@area\removeChild @barBgX
				@barBgX = nil
				@barX = nil
			if @barBgY
				@area\removeChild @barBgY
				@barBgY = nil
				@barY = nil

	offset:property (=> @getTotalDelta!),
		(offset)=> @scroll offset-@getTotalDelta!

	viewSize:property (=> @getViewSize!),
		(size)=> @resetSize @contentSize.width,@contentSize.height,size.width,size.height

	padding:property (=> @getPadding!),
		(padding)=> @updatePadding padding.x,padding.y

	setupMenuScroll:(menu)=>
		@slot "Scrolled",(delta)->
			menu\moveAndCullItems delta -- reduce draw calls
		menuEnabled = true
		@slot "ScrollStart",->
			menuEnabled = menu.enabled
			menu.enabled = false
		@slot "ScrollTouchEnded",->
			menu.enabled = menuEnabled if not menu.enabled

	adjustSizeWithAlign:(alignMode="auto",padding=10,size=@area.size,viewSize)=> -- alignMode:auto,vertical,horizontal
		viewSize or= size
		offset = @offset
		@offset = Vec2.zero
		viewSize = switch alignMode
			when "auto"
				@view\alignItems Size(viewSize.width,size.height), padding
			when "vertical"
				@view\alignItemsVertically size, padding
			when "horizontal"
				@view\alignItemsHorizontally size, padding
		@resetSize size.width,size.height,viewSize.width,viewSize.height
		@offset = offset

	scrollToPosY:(posY,time=0.3)=>
		{:height} = @contentSize
		offset = @offset
		viewHeight = @viewSize.height
		deltaY = height/2-posY
		startY = offset.y
		endY = startY+deltaY
		if viewHeight <= height
			endY = 0
		else
			endY = math.max endY,0
			endY = math.min endY,viewHeight-height
		@schedule once ->
			changeY = endY-startY
			cycle time,(progress)->
				offset.y = startY + changeY * Ease\func Ease.OutQuad,progress
				@scrollTo offset
			offset.y = endY
			@scrollTo offset
