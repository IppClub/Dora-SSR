_ENV = Dorothy!

hpGroup = Group {"hp"}
spGroup = Group {"sp"}

observer = Observer "Change", {"hp","mp"}

entity0 = with Entity!
	.hp = 100
	.mp = 998

entity1 = with Entity!
	.hp = 119
	.sp = 233

print "-- {hp} group"
hpGroup\each (e)-> print "entity", e.index

print "-- {sp} group"
spGroup\each (e)-> print "entity", e.index

print "-- {hp mp} observer"
entity0.hp = 1
entity1.hp -= 1
entity1.hp -= 99
observer\each (e)-> print "hp or mp change: entity", e.index

print "-- {hp} group"
hpGroup\each (e)-> print "entity", e.index,e.oldValues.hp,e.hp

print "remove hp from entity", entity1.index
entity1.hp = nil

print "-- {hp} group"
hpGroup\each (e)-> print "entity", e.index,e.oldValues.hp,e.hp

print "-- {sp} group"
spGroup\each (e)-> print "entity", e.index,e.oldValues.sp,e.sp
