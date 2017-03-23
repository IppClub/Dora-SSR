Dorothy!

testFunc = ->
	print 1+"sds"

thread ->
	print "1.hello"
	sleep 1
	print "2.moon"
	sleep 1
	print "3.script"
	sleep 1
	print "4.moonscript"
	testFunc!
