// GPU regression for dynamic texture uploads, including A8 -> RGBA emulation.
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>
#define SDL_MAIN_HANDLED
#include <SDL.h>
#include <SDL_syswm.h>
#include <array>
#include <cstdio>
#include <stdexcept>

static void require(bool condition, const char* message) {
	if (!condition) throw std::runtime_error(message);
}

static void waitReadback(bgfx::TextureHandle texture, void* data) {
	// Texture updates are batched; submit them before recording the readback.
	bgfx::touch(0);
	bgfx::frame();
	const uint32_t ready = bgfx::readTexture(texture, data);
	uint32_t frame = 0;
	for (int i = 0; i < 16; ++i) {
		SDL_PumpEvents();
		bgfx::touch(0);
		frame = bgfx::frame();
		if (frame >= ready && i >= 7) return;
	}
	throw std::runtime_error("texture readback did not finish");
}

static void testMask(bgfx::TextureFormat::Enum format, const char* name, size_t rgbaChannel) {
	const bool emulated = !(bgfx::getCaps()->formats[format] & BGFX_CAPS_FORMAT_TEXTURE_2D);
	std::array<uint8_t, 64> expected{};
	auto texture = bgfx::createTexture2D(8, 8, false, 1, format,
		BGFX_TEXTURE_READ_BACK);
	require(bgfx::isValid(texture), "mask texture creation failed");
	bgfx::updateTexture2D(texture, 0, 0, 0, 0, 8, 8, bgfx::copy(expected.data(), uint32_t(expected.size())));
	bgfx::frame();
	const uint8_t packed[] = {11, 22, 33, 44, 55, 66, 77, 88, 99};
	bgfx::updateTexture2D(texture, 0, 0, 1, 1, 3, 3, bgfx::copy(packed, sizeof(packed)));
	for (int y = 0; y < 3; ++y) for (int x = 0; x < 3; ++x)
		expected[(y + 1) * 8 + x + 1] = packed[y * 3 + x];
	// Padding must not become texels, and the destination stride is RGBA when emulated.
	const uint8_t padded[] = {101, 102, 103, 231, 231, 231, 231, 201, 202, 203, 231, 231, 231, 231};
	bgfx::updateTexture2D(texture, 0, 0, 4, 5, 3, 2, bgfx::copy(padded, sizeof(padded)), 7);
	for (int y = 0; y < 2; ++y) for (int x = 0; x < 3; ++x)
		expected[(y + 5) * 8 + x + 4] = padded[y * 7 + x];
	std::array<uint8_t, 272> pixels;
	pixels.fill(0xcd);
	waitReadback(texture, pixels.data());
	for (size_t i = 0; i < expected.size(); ++i)
		require(pixels[emulated ? i * 4 + rgbaChannel : i] == expected[i], "mask packed/padded update pixel mismatch");
	for (size_t i = emulated ? 256 : 64; i < pixels.size(); ++i)
		require(pixels[i] == 0xcd, "mask readback exceeded its storage");
	bgfx::destroy(texture);
	std::printf("PASS: %s packed and padded subrectangles (%s)\n", name, emulated ? "RGBA emulation" : "native");
}

static void testRgba() {
	std::array<uint8_t, 256> expected{};
	auto texture = bgfx::createTexture2D(8, 8, false, 1, bgfx::TextureFormat::RGBA8,
		BGFX_TEXTURE_READ_BACK);
	require(bgfx::isValid(texture), "RGBA8 texture creation failed");
	bgfx::updateTexture2D(texture, 0, 0, 0, 0, 8, 8, bgfx::copy(expected.data(), uint32_t(expected.size())));
	bgfx::frame();
	const uint8_t packed[] = {1, 2, 3, 255, 4, 5, 6, 254, 7, 8, 9, 253, 10, 11, 12, 252};
	bgfx::updateTexture2D(texture, 0, 0, 1, 1, 2, 2, bgfx::copy(packed, sizeof(packed)));
	for (int y = 0; y < 2; ++y) for (int x = 0; x < 8; ++x)
		expected[(y + 1) * 32 + 4 + x] = packed[y * 8 + x];
	const uint8_t padded[] = {21, 22, 23, 251, 24, 25, 26, 250, 231, 231, 231, 231,
		31, 32, 33, 249, 34, 35, 36, 248, 231, 231, 231, 231};
	bgfx::updateTexture2D(texture, 0, 0, 5, 4, 2, 2, bgfx::copy(padded, sizeof(padded)), 12);
	for (int y = 0; y < 2; ++y) for (int x = 0; x < 8; ++x)
		expected[(y + 4) * 32 + 20 + x] = padded[y * 12 + x];
	std::array<uint8_t, 256> pixels{};
	waitReadback(texture, pixels.data());
	if (pixels != expected) {
		int count = 0;
		for (size_t i = 0; i < pixels.size() && count < 12; ++i) if (pixels[i] != expected[i]) {
			std::printf("RGBA byte %zu: got %u expected %u\n", i, pixels[i], expected[i]);
			++count;
		}
	}
	require(pixels == expected, "RGBA8 packed/padded update pixel mismatch");
	bgfx::destroy(texture);
	std::puts("PASS: RGBA8 packed and padded subrectangles");
}

int main() {
	SDL_SetMainReady();
	SDL_Window* window = nullptr;
	bool initialized = false;
	int result = 1;
	try {
		require(SDL_Init(SDL_INIT_VIDEO) == 0, SDL_GetError());
		window = SDL_CreateWindow("OpenGL texture upload regression", SDL_WINDOWPOS_UNDEFINED,
			SDL_WINDOWPOS_UNDEFINED, 32, 32, SDL_WINDOW_HIDDEN);
		require(window != nullptr, SDL_GetError());
		SDL_SysWMinfo wm{};
		SDL_VERSION(&wm.version);
		require(SDL_GetWindowWMInfo(window, &wm) == SDL_TRUE, SDL_GetError());
		bgfx::Init init;
		init.type = bgfx::RendererType::OpenGL;
#if defined(_WIN32)
		init.platformData.nwh = wm.info.win.window;
#else
#error This regression runner currently uses the Windows WGL window adapter.
#endif
		init.resolution.width = 32;
		init.resolution.height = 32;
		bgfx::renderFrame(); // Run the renderer on this thread, including readbacks.
		initialized = bgfx::init(init);
		require(initialized, "OpenGL initialization failed");
		require(bgfx::getCaps()->supported & BGFX_CAPS_TEXTURE_READ_BACK, "GPU texture readback is unavailable");
		bgfx::setViewRect(0, 0, 0, 32, 32);
		testRgba();
		testMask(bgfx::TextureFormat::A8, "A8", 3);
		testMask(bgfx::TextureFormat::R8, "R8", 0);
		result = 0;
	} catch (const std::exception& error) {
		std::fprintf(stderr, "FAIL: %s\n", error.what());
	}
	if (initialized) bgfx::shutdown();
	if (window) SDL_DestroyWindow(window);
	SDL_Quit();
	return result;
}
