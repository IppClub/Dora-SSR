Dorothy builtin.Platformer
{store:Store} = Data

Store["Body_ObstacleS"] = with BodyDef!
	.type = BodyType.Static
	\attachPolygon 100,60,1,1,0

Store["Body_ObstacleM"] = with BodyDef!
	.type = BodyType.Static
	\attachPolygon 260,60,1,1,0

Store["Body_ObstacleC"] = with BodyDef!
	.type = BodyType.Dynamic
	.linearAcceleration = Vec2 0,-10
	\attachDisk 40,1,0.6,0.4
