_ENV = Dorothy!

num = 20

newP = (index, radius)->
	angle = 2*math.pi*index/num
	Vec2(radius*math.cos(angle),radius*math.sin(angle)) + Vec2(radius,radius)

export default (args)->
	with Line [newP index, args.radius for index = 0, num], args.color and Color args.color or 0xffffffff
		.position = Vec2 args.x or 0,args.y or 0
		.renderOrder = args.renderOrder or 0

