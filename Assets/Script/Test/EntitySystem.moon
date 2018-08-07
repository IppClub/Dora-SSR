Dorothy!

world = EntityWorld!

hpGroup = world\group {"hp"}
spGroup = world\group {"sp"}

observer = world\observe "Change", {"hp","mp"}

entity0 = with world\entity!
	.hp = 100
	.mp = 998

entity1 = with world\entity!
	.hp = 119
	.sp = 233

print "-- {hp} group"
hpGroup\each (e)-> print "entity", e.id

print "-- {sp} group"
spGroup\each (e)-> print "entity", e.id

print "-- {hp mp} observer"
entity0.hp = 1
entity1.hp = 999
observer\each (e)-> print "hp or mp change: entity", e.id

print "remove hp from entity", entity1.id
entity1.hp = nil

print "-- {hp} group"
hpGroup\each (e)-> print "entity", e.id

print "-- {sp} group"
spGroup\each (e)-> print "entity", e.id
