Dorothy!

print View.vsync, View.fieldOfView, View.standardDistance

testFunc = ->
	print 1+"sds"

thread ->
	Cache\loadAsync "Image/test.pvr", (file)->
		sp = Sprite file
		sp\schedule once ->
			sleep 2
			print "schedule end!"
		Director\pushEntry sp
	sleep 1
	Cache\loadAsync Content.writablePath.."test.par"
	print "1.hello"
	sleep 1
	print "2.moon"
	sleep 1
	print "3.script"
	Director\popEntry!
	sleep 1
	print "4.moonscript"
	--testFunc!
