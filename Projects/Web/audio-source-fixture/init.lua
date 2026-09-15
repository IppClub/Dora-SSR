local Dora = require("Dora")
local Audio, AudioSource, Director, Node = Dora.Audio, Dora.AudioSource, Dora.Director, Dora.Node
local root = Node():addTo(Director.entry)
local source = AudioSource("Audio/tone.wav", false):addTo(root)
source.looping = true
source.volume = 0.2
source:setMinMaxDistance(1, 100)
source:setAttenuation("InverseDistance", 1)
source.x, source.z = -2, 2
Audio:setListenerAt(0, 0, 1)
local ended = 0
source:slot("AudioEnd", function() ended = ended + 1 end)
assert(source:play3D(-1))
assert(source.playing and not source:play3D(-1))
local time, step, oneShot = 0, 0, nil
root:schedule(function(dt)
	time = time + dt
	if step == 0 and time > 0.3 then
		assert(source.playing)
		Audio:setPauseAllCurrent(true)
		source:seek(0.02)
		step = 1
	elseif step == 1 and time > 0.5 then
		assert(source.playing)
		Audio:setPauseAllCurrent(false)
		source.x = 2
		source:setVelocity(0, 0, -2)
		source:setDopplerFactor(0.5)
		source:setLoopPoint(0.01)
		source:setProtected(true)
		source.pan = 0.2
		step = 2
	elseif step == 2 and time > 0.8 then
		source:stop(0.05)
		step = 3
	elseif step == 3 and time > 1.2 then
		assert(not source.playing and ended == 1, "3D AudioEnd must occur exactly once")
		source.looping = false
		assert(source:playBackground())
		source:scheduleStop(0.05)
		step = 4
	elseif step == 4 and time > 1.6 then
		assert(not source.playing and ended == 2, "background scheduled stop must end")
		oneShot = AudioSource("Audio/tone.wav", true):addTo(root)
		oneShot:slot("AudioEnd", function() ended = ended + 1 end)
		assert(oneShot:play())
		step = 5
	elseif step == 5 and time > 3 then
		assert(not oneShot.playing and ended == 3 and oneShot.parent == nil, "one-shot autoRemove failed")
		source.looping = true
		assert(source:play3D(-1))
		Audio:stopAll()
		step = 6
	elseif step == 6 and time > 3.5 then
		assert(not source.playing and ended == 4, "stopAll must release worklet AudioSource references")
		-- Leave one looping 3D source for the host's stall/suspend/disposal checks.
		assert(source:play3D(-1))
		print("AUDIO_SOURCE_TEST_PASS")
		return true
	end
	return false
end)
