local wav
local ogg
local memory
local clone
local frames = 0
local cycle = 0

local function near(actual, expected, tolerance)
	return math.abs(actual - expected) <= tolerance
end

local function makeSoundData()
	local rate = 22050
	local samples = 2205
	local data = love.sound.newSoundData(samples, rate, 16, 1)
	for index = 0, samples - 1 do
		local envelope = math.min(1, index / 64, (samples - index) / 64)
		data:setSample(index, math.sin(2 * math.pi * 660 * index / rate) * 0.15 * envelope)
	end
	return data
end

local function startSources()
	wav:setLooping(true)
	wav:setVolume(0.2)
	wav:setPitch(1.05)
	assert(wav:isLooping() and near(wav:getVolume(), 0.2, 0.001))
	assert(near(wav:getPitch(), 1.05, 0.001))
	ogg:setVolume(0.15)
	memory:setVolume(0.1)
	assert(love.audio.play({wav, ogg, memory}))
	assert(wav:isPlaying() and ogg:isPlaying() and memory:isPlaying())
end

function love.load()
	love.audio.setVolume(0.7)
	assert(near(love.audio.getVolume(), 0.7, 0.001))
	wav = love.audio.newSource("fixture.wav", "static")
	ogg = love.audio.newSource("fixture.ogg", "stream")
	memory = love.audio.newSource(makeSoundData())
	clone = wav:clone()
	assert(wav:getChannelCount() == 1 and ogg:getChannelCount() == 2)
	assert(memory:getChannelCount() == 1)
	assert(near(wav:getDuration("seconds"), 0.25, 0.03))
	assert(near(ogg:getDuration("seconds"), 0.25, 0.03))
	startSources()
	print("LOVE_WEB_AUDIO_CREATED", love.audio.getActiveSourceCount())
end

function love.update()
	frames = frames + 1
	if frames == 4 then
		wav:pause()
		assert(wav:isPaused() and not wav:isPlaying())
	elseif frames == 6 then
		assert(wav:play() and wav:isPlaying())
		wav:seek(0.05, "seconds")
	elseif frames == 8 then
		ogg:stop()
		assert(not ogg:isPlaying())
		assert(ogg:play())
	elseif frames == 10 then
		clone:setVolume(0.05)
		assert(clone:play())
	elseif frames >= 12 and frames % 120 == 0 then
		cycle = cycle + 1
		memory:stop()
		assert(not memory:isPlaying())
		assert(memory:play())
		print("LOVE_WEB_AUDIO_CYCLE", cycle)
	end
	if frames == 12 then
		assert(love.audio.getActiveSourceCount() >= 3)
		print("LOVE_WEB_AUDIO_READY", love.audio.getActiveSourceCount())
	end
end

function love.draw()
	love.graphics.clear(0.02, 0.025, 0.04, 1)
end
