/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/TIC80Node.h"

#include "Audio/Audio.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Event/Event.h"
#include "Input/Controller.h"
#include "Input/Keyboard.h"
#include "Input/TouchDispather.h"

#include "soloud.h"

extern "C" {
#include "3rdParty/tic80/tic.h"
}

NS_DORA_BEGIN

class TIC80AudioSource : public SoLoud::AudioSource {
public:
	TIC80AudioSource(tic80* tic, std::mutex* audioMutex)
		: _tic80(tic)
		, _audioMutex(audioMutex) {
	}

	virtual SoLoud::AudioSourceInstance* createInstance() override;

private:
	tic80* _tic80;
	std::mutex* _audioMutex;
};

class TIC80AudioSourceInstance : public SoLoud::AudioSourceInstance {
public:
	TIC80AudioSourceInstance(tic80* tic, std::mutex* audioMutex)
		: _tic80(tic)
		, _audioMutex(audioMutex)
		, _remainingBytes(0) {
		mBaseSamplerate = TIC80_SAMPLERATE;
		mChannels = TIC80_SAMPLE_CHANNELS;
	}

	virtual unsigned int getAudio(float* aBuffer, unsigned int aSamplesToRead, unsigned int aBufferSize) override {
		if (!_tic80 || !_tic80->samples.buffer) {
			// Clear buffer
			for (unsigned int i = 0; i < aSamplesToRead; i++) {
				for (unsigned int ch = 0; ch < mChannels; ch++) {
					aBuffer[ch * aBufferSize + i] = 0.0f;
				}
			}
			return aSamplesToRead;
		}

		unsigned int samplesWritten = 0;
		const float scale = 1.0f / std::numeric_limits<int16_t>::max();
		const unsigned int sampleSize = TIC80_SAMPLESIZE; // sizeof(int16_t) = 2

		// Fill buffer with samples
		while (samplesWritten < aSamplesToRead) {

			// If we've consumed all samples from current frame, generate new frame
			// when remaining <= 0, call tic80_sound()
			if (_remainingBytes <= 0) {
				{
					std::lock_guard<std::mutex> lock(*_audioMutex);
					tic80_sound(_tic80);
				}
				_remainingBytes = _tic80->samples.count * TIC80_SAMPLESIZE;
			}

			// Calculate how many samples we can copy from current frame
			unsigned int bytesAvailable = _remainingBytes;
			unsigned int samplesAvailable = bytesAvailable / sampleSize;
			unsigned int samplesToCopy = std::min(aSamplesToRead - samplesWritten, samplesAvailable);

			if (samplesToCopy > 0) {
				// Read samples from TIC80 buffer
				// TIC80 buffer format (interleaved): [L0, R0, L1, R1, ..., Ln, Rn] as int16_t
				// We need to convert to non-interleaved: [L0, L1, ..., Ln, R0, R1, ..., Rn] (11112222 format)
				unsigned int totalBytes = _tic80->samples.count * TIC80_SAMPLESIZE;
				unsigned int readOffset = totalBytes - _remainingBytes; // Byte offset from start of buffer

				// Extract left and right channel samples and convert to non-interleaved format
				// soloud expects: [L0, L1, ..., Ln, R0, R1, ..., Rn] (11112222 format)
				const int16_t* srcSamples = r_cast<const int16_t*>(_tic80->samples.buffer);

				for (unsigned int i = 0; i < samplesToCopy; i++) {
					// Calculate current byte position in buffer (similar to official example)
					// We read samples in pairs (L, R), so we need to find which pair we're at
					unsigned int currentBytePos = readOffset + (i * sampleSize);
					unsigned int sampleIndex = currentBytePos / sampleSize; // Sample index in interleaved buffer

					// TIC80 buffer is interleaved: [L0, R0, L1, R1, ..., Ln, Rn]
					// sampleIndex points to a sample in this interleaved array
					// We need to extract the left and right samples from the pair
					unsigned int pairIndex = sampleIndex / mChannels; // Which L/R pair (0, 1, 2, ...)

					// Get left and right samples from the pair
					unsigned int leftSampleIndex = pairIndex * mChannels + 0;
					unsigned int rightSampleIndex = pairIndex * mChannels + 1;

					int16_t leftSample = srcSamples[leftSampleIndex];
					int16_t rightSample = srcSamples[rightSampleIndex];

					// Write to non-interleaved format: all left samples, then all right samples (11112222)
					aBuffer[0 * aBufferSize + samplesWritten + i] = s_cast<float>(leftSample) * scale;
					aBuffer[1 * aBufferSize + samplesWritten + i] = s_cast<float>(rightSample) * scale;
				}

				_remainingBytes -= samplesToCopy * sampleSize;
				samplesWritten += samplesToCopy;
			} else {
				// No samples available, fill remaining with zeros
				break;
			}
		}

		// Fill remaining with zeros if needed
		if (samplesWritten < aSamplesToRead) {
			for (unsigned int i = samplesWritten; i < aSamplesToRead; i++) {
				for (unsigned int ch = 0; ch < mChannels; ch++) {
					aBuffer[ch * aBufferSize + i] = 0.0f;
				}
			}
		}

		// Return the number of samples we actually read
		// soloud expects this to be <= aSamplesToRead
		return samplesWritten;
	}

	virtual bool hasEnded() override {
		return false; // Continuous playback
	}

private:
	tic80* _tic80;
	std::mutex* _audioMutex;
	unsigned int _remainingBytes;
};

SoLoud::AudioSourceInstance* TIC80AudioSource::createInstance() {
	return new TIC80AudioSourceInstance(_tic80, _audioMutex);
}

static u64 counter(void*) {
	return s_cast<u64>(SharedApplication.getCurrentTime() * 1000000.0);
}

static u64 freq(void*) {
	return 1000000; // microseconds per second
}

TIC80Node::TIC80Node(String cartFile)
	: _cartFile(cartFile.toString())
	, _tic80(nullptr)
	, _audioHandle(0)
	, _keyMap{
		  {"A", tic_key_a},
		  {"B", tic_key_b},
		  {"C", tic_key_c},
		  {"D", tic_key_d},
		  {"E", tic_key_e},
		  {"F", tic_key_f},
		  {"G", tic_key_g},
		  {"H", tic_key_h},
		  {"I", tic_key_i},
		  {"J", tic_key_j},
		  {"K", tic_key_k},
		  {"L", tic_key_l},
		  {"M", tic_key_m},
		  {"N", tic_key_n},
		  {"O", tic_key_o},
		  {"P", tic_key_p},
		  {"Q", tic_key_q},
		  {"R", tic_key_r},
		  {"S", tic_key_s},
		  {"T", tic_key_t},
		  {"U", tic_key_u},
		  {"V", tic_key_v},
		  {"W", tic_key_w},
		  {"X", tic_key_x},
		  {"Y", tic_key_y},
		  {"Z", tic_key_z},
		  {"0", tic_key_0},
		  {"1", tic_key_1},
		  {"2", tic_key_2},
		  {"3", tic_key_3},
		  {"4", tic_key_4},
		  {"5", tic_key_5},
		  {"6", tic_key_6},
		  {"7", tic_key_7},
		  {"8", tic_key_8},
		  {"9", tic_key_9},
		  {"Space", tic_key_space},
		  {"Tab", tic_key_tab},
		  {"Return", tic_key_return},
		  {"BackSpace", tic_key_backspace},
		  {"Delete", tic_key_delete},
		  {"Insert", tic_key_insert},
		  {"Up", tic_key_up},
		  {"Down", tic_key_down},
		  {"Left", tic_key_left},
		  {"Right", tic_key_right},
		  {"Home", tic_key_home},
		  {"End", tic_key_end},
		  {"PageUp", tic_key_pageup},
		  {"PageDown", tic_key_pagedown},
		  {"Escape", tic_key_escape},
		  {"CapsLock", tic_key_capslock},
		  {"LCtrl", tic_key_ctrl},
		  {"RCtrl", tic_key_ctrl},
		  {"LShift", tic_key_shift},
		  {"RShift", tic_key_shift},
		  {"LAlt", tic_key_alt},
		  {"RAlt", tic_key_alt},
		  {"F1", tic_key_f1},
		  {"F2", tic_key_f2},
		  {"F3", tic_key_f3},
		  {"F4", tic_key_f4},
		  {"F5", tic_key_f5},
		  {"F6", tic_key_f6},
		  {"F7", tic_key_f7},
		  {"F8", tic_key_f8},
		  {"F9", tic_key_f9},
		  {"F10", tic_key_f10},
		  {"F11", tic_key_f11},
		  {"F12", tic_key_f12},
		  {"-", tic_key_minus},
		  {"=", tic_key_equals},
		  {"[", tic_key_leftbracket},
		  {"]", tic_key_rightbracket},
		  {"\\", tic_key_backslash},
		  {";", tic_key_semicolon},
		  {"'", tic_key_apostrophe},
		  {"`", tic_key_grave},
		  {",", tic_key_comma},
		  {".", tic_key_period},
		  {"/", tic_key_slash}}
	, _counterStart(0) {
	memset(&_currentInput, 0, sizeof(_currentInput));
}

TIC80Node::~TIC80Node() { }

static void dora_tic_trace(const char* text, u8) {
	Info("[TIC-80] {}", text);
}

void dora_tic_error(const char* info) {
	Error("[TIC-80] {}", info);
}

bool TIC80Node::init() {
	if (!Sprite::init()) return false;

	_tic80 = tic80_create(DORA_SAMPLERATE, TIC80_PIXEL_COLOR_RGBA8888);

	if (!_tic80) {
		Error("TIC80Node: failed to create TIC80 instance");
		return false;
	}

	_tic80->callback.trace = dora_tic_trace;
	_tic80->callback.error = dora_tic_error;

	auto cartData = SharedContent.load(_cartFile);
	if (!cartData.first || cartData.second == 0) {
		Error("TIC80Node: failed to load cart file: {}", _cartFile);
		tic80_delete(_tic80);
		_tic80 = nullptr;
		return false;
	}

	tic80_load(_tic80, cartData.first.get(), s_cast<s32>(cartData.second));

	bgfx::TextureHandle textureHandle = bgfx::createTexture2D(
		TIC80_FULLWIDTH,
		TIC80_FULLHEIGHT,
		false, 1,
		bgfx::TextureFormat::RGBA8);

	if (!bgfx::isValid(textureHandle)) {
		Error("TIC80Node: failed to create texture");
		tic80_delete(_tic80);
		_tic80 = nullptr;
		return false;
	}

	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info,
		TIC80_FULLWIDTH,
		TIC80_FULLHEIGHT,
		0, false, false, 1,
		bgfx::TextureFormat::RGBA8);

	auto texture = Texture2D::create(textureHandle, info, BGFX_TEXTURE_NONE);
	setTexture(texture);
	setTextureRect(Rect{
		TIC80_MARGIN_LEFT,
		TIC80_MARGIN_BOTTOM,
		s_cast<float>(TIC80_WIDTH),
		s_cast<float>(TIC80_HEIGHT)});
	setSize({s_cast<float>(TIC80_WIDTH), s_cast<float>(TIC80_HEIGHT)});
	setFilter(TextureFilter::Point);

	_audioSource = New<TIC80AudioSource>(_tic80, &_audioMutex);
	_audioHandle = SharedAudio.getSoLoud()->play(*_audioSource);
	if (_audioHandle != 0) {
		SharedAudio.getSoLoud()->setProtectVoice(_audioHandle, true);
	}

	setupInputHandlers();

	_counterStart = counter(nullptr);

	_scheduler = Scheduler::create();
	_scheduler->setFixedFPS(TIC80_FRAMERATE);
	_scheduler->scheduleFixed([this](double) {
		if (!_tic80) return true;
		{
			std::lock_guard<std::mutex> lock(_audioMutex);
			tic80_tick(_tic80, _currentInput, counter, freq);
		}
		return false;
	});

	scheduleUpdate();
	return true;
}

void TIC80Node::cleanup() {
	if (_flags.isOn(Node::Cleanup)) return;
	if (_audioHandle != 0) {
		SharedAudio.getSoLoud()->stop(_audioHandle);
		_audioHandle = 0;
	}

	if (_scheduler) {
		_scheduler->cleanup();
		_scheduler = nullptr;
	}
	_audioSource = nullptr;

	if (_tic80) {
		tic80_delete(_tic80);
		_tic80 = nullptr;
	}

	Sprite::cleanup();
}

void TIC80Node::setupInputHandlers() {
	setKeyboardEnabled(true);
	setControllerEnabled(true);
	setTouchEnabled(true);

	slot("KeyDown"_slice, [this](Event* event) {
		handleKeyboardEvent(event);
	});
	slot("KeyUp"_slice, [this](Event* event) {
		handleKeyboardEvent(event);
	});

	slot("ButtonDown"_slice, [this](Event* event) {
		handleControllerEvent(event);
	});
	slot("ButtonUp"_slice, [this](Event* event) {
		handleControllerEvent(event);
	});

	slot("TapBegan"_slice, [this](Event* event) {
		handleTouchEvent(event);
	});
	slot("TapMoved"_slice, [this](Event* event) {
		handleTouchEvent(event);
	});
	slot("TapEnded"_slice, [this](Event* event) {
		handleTouchEvent(event);
	});
}

void TIC80Node::handleKeyboardEvent(Event* event) {
	Slice keyName;
	if (!event->get(keyName)) return;

	tic_key key = mapKeyNameToTIC80Key(keyName);
	if (key == tic_key_unknown) return;

	bool isDown = event->getName() == "KeyDown"_slice;
	auto& first = _currentInput.gamepads.first;

	switch (key) {
		case tic_key_z: first.a = isDown; break;
		case tic_key_x: first.b = isDown; break;
		case tic_key_a: first.x = isDown; break;
		case tic_key_s: first.y = isDown; break;
		case tic_key_up: first.up = isDown; break;
		case tic_key_down: first.down = isDown; break;
		case tic_key_left: first.left = isDown; break;
		case tic_key_right: first.right = isDown; break;
	}

	if (isDown) {
		// Add key to keyboard buffer
		for (int i = 0; i < TIC80_KEY_BUFFER; i++) {
			if (_currentInput.keyboard.keys[i] == 0) {
				_currentInput.keyboard.keys[i] = key;
				break;
			}
		}
	} else {
		// Remove key from keyboard buffer
		for (int i = 0; i < TIC80_KEY_BUFFER; i++) {
			if (_currentInput.keyboard.keys[i] == key) {
				_currentInput.keyboard.keys[i] = 0;
				// Shift remaining keys
				for (int j = i; j < TIC80_KEY_BUFFER - 1; j++) {
					_currentInput.keyboard.keys[j] = _currentInput.keyboard.keys[j + 1];
				}
				_currentInput.keyboard.keys[TIC80_KEY_BUFFER - 1] = 0;
				break;
			}
		}
	}
}

void TIC80Node::handleControllerEvent(Event* event) {
	int controllerId;
	Slice buttonName;
	if (!event->get(controllerId, buttonName)) return;

	if (controllerId < 0 || controllerId > 3) return;

	String eventName = event->getName();
	bool isDown = (eventName == "ButtonDown"_slice);

	tic80_gamepad* pads[4] = {
		&_currentInput.gamepads.first,
		&_currentInput.gamepads.second,
		&_currentInput.gamepads.third,
		&_currentInput.gamepads.fourth
	};

	tic80_gamepad& gamepad = *pads[controllerId];

	switch (Switch::hash(buttonName)) {
		case "a"_hash: gamepad.a = isDown ? 1 : 0; break;
		case "b"_hash: gamepad.b = isDown ? 1 : 0; break;
		case "x"_hash: gamepad.x = isDown ? 1 : 0; break;
		case "y"_hash: gamepad.y = isDown ? 1 : 0; break;
		case "dpup"_hash: gamepad.up = isDown ? 1 : 0; break;
		case "dpdown"_hash: gamepad.down = isDown ? 1 : 0; break;
		case "dpleft"_hash: gamepad.left = isDown ? 1 : 0; break;
		case "dpright"_hash: gamepad.right = isDown ? 1 : 0; break;
		default: break;
	}
}

void TIC80Node::handleTouchEvent(Event* event) {
	Touch* touch = nullptr;
	if (!event->get(touch) || !touch) return;

	Vec2 location = touch->getLocation();
	String eventName = event->getName();

	// Convert to TIC80 screen coordinates (0-239, 0-135)
	tic80_mouse& mouse = _currentInput.mouse;
	mouse.x = s_cast<u8>(Math::clamp(
		location.x * TIC80_WIDTH / getWidth(), 0.0f,
		s_cast<float>(TIC80_WIDTH - 1)));
	mouse.y = TIC80_HEIGHT - s_cast<u8>(Math::clamp(
		location.y * TIC80_HEIGHT / getHeight(), 0.0f,
		s_cast<float>(TIC80_HEIGHT - 1)));

	switch (Switch::hash(eventName)) {
		case "TapBegan"_hash:
		case "TapMoved"_hash:
			mouse.left = 1;
			break;
		case "TapEnded"_hash:
			mouse.left = 0;
			break;
	}
}

tic_key TIC80Node::mapKeyNameToTIC80Key(String keyName) {
	auto it = _keyMap.find(keyName);
	if (it != _keyMap.end()) {
		return s_cast<tic_key>(it->second);
	}
	return tic_key_unknown;
}

void TIC80Node::updateTexture() {
	if (!_tic80 || !_tic80->screen) return;

	auto texture = getTexture();
	if (!texture || texture->getWidth() < TIC80_FULLWIDTH || texture->getHeight() < TIC80_FULLHEIGHT) {
		return;
	}

	const bgfx::Memory* mem = bgfx::copy(_tic80->screen, s_cast<uint32_t>(TIC80_FULLWIDTH * TIC80_FULLHEIGHT * sizeof(u32)));
	bgfx::updateTexture2D(texture->getHandle(), 0, 0, 0, 0,
		TIC80_FULLWIDTH,
		TIC80_FULLHEIGHT,
		mem);
}

bool TIC80Node::update(double deltaTime) {
	if (!_tic80) return true;
	_scheduler->update(deltaTime);
	updateTexture();
	return Sprite::update(deltaTime);
}

NS_DORA_END
