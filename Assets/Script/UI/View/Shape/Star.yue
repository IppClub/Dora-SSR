_ENV = Dorothy!

StarVertices = (radius,line=true)->
	a = math.rad 36
	c = math.rad 72
	f = math.sin(a)*math.tan(c)+math.cos(a)
	R = radius
	r = R/f
	return for i = 9+(line and 1 or 0),0,-1
		angle = i*a
		cr = i%2 == 1 and r or R
		Vec2 cr*math.sin(angle), cr*math.cos(angle)

export default (args)->
	with Node!
		.position = Vec2 args.x or 0, args.y or 0
		if args.fillColor
			\addChild with DrawNode!
				\drawPolygon StarVertices(args.size,false),Color args.fillColor
				.renderOrder = args.fillOrder if args.fillOrder
		if args.borderColor
			\addChild with Line StarVertices(args.size),Color args.borderColor
				.renderOrder = args.lineOrder if args.lineOrder
